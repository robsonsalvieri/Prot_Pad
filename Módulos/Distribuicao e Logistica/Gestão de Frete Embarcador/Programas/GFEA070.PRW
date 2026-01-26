#INCLUDE "GFEA070.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __lLogIntP := IIF(SuperGetMv("MV_GFELPR",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log da integração com o ERP Protheus

// Constante usada na função AddToLog()
#DEFINE _LOG_END   2

#DEFINE GFEA070001 'GFEA070001'

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070
Digitação de Faturas de Frete  
Generico

@sample
GFEA070()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070()
	Local l070Leg  := ExistBlock("GFE70LEG")

	Private oBrowse
	Private lCopy   := .F.
	Private lAltFat := .F.
	Private aAuxDF  := Nil
	Private aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW6")							            // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA070")					            // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	 // Descrição do browse     //"Faturas de Frete"

	oBrowse:AddLegend("GW6_SITAPR == '1'", "BLACK" , STR0002) 	//Legenda do Browser //"Recebida"
	oBrowse:AddLegend("GW6_SITAPR == '2'", "RED"   , STR0003) 	//"Bloqueado"
	oBrowse:AddLegend("GW6_SITAPR == '3'", "GREEN" , STR0004) 	//"Aprovada Sistema"
	oBrowse:AddLegend("GW6_SITAPR == '4'", "BLUE"  , STR0005) 	//"Aprovada Usuario"

	If l070Leg
		ExecBlock("GFE70LEG",.F.,.F.)
	EndIf

	oBrowse:Activate()
Return(Nil)

//------------------------------------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}
	Local aArea := GetArea()

	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA070ALT" 	  OPERATION 4  ACCESS 0	// "Alterar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA070" OPERATION 3  ACCESS 0	// "Incluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA070CC()"     OPERATION 2  ACCESS 0	// "Visualizar"
	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1  ACCESS 0	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0010 ACTION "GFEA070EXC()"    OPERATION 5  ACCESS 0	// "Excluir"
	ADD OPTION aRotina TITLE STR0015 ACTION "GFE070COPY()" OPERATION 9  ACCESS 0	// "Copiar"
	ADD OPTION aRotina TITLE "Documentos de Frete" ACTION "GFEA070A() "     OPERATION 10 ACCESS 0 // "Documentos de Frete"
	ADD OPTION aRotina TITLE "Busca pré-faturas" ACTION "GFEA070BPF()"     OPERATION 10 ACCESS 0 // "Busca pré-faturas"
	ADD OPTION aRotina TITLE STR0014 ACTION "GFEA070B() "     OPERATION 10 ACCESS 0	// "Pré-faturas"
	ADD OPTION aRotina TITLE STR0016 ACTION "VIEWDEF.GFEA070" OPERATION 8  ACCESS 0	// "Imprimir"
	ADD OPTION aRotina TITLE STR0011 ACTION "GFEA070CO()" 	  OPERATION 10 ACCESS 0	// "Conferir"
	ADD OPTION aRotina TITLE "Dados da Conferência" ACTION "GFEA070CF()"     OPERATION 4  ACCESS 0	// "Dados da Conferência"
	ADD OPTION aRotina TITLE "Atualizar Financeiro ERP"	ACTION "GFEA070X()" OPERATION 10 ACCESS 0 // "Atualizar Financeiro ERP"
	ADD OPTION aRotina TITLE "Desatualiz Financeiro ERP" ACTION "GFEA070DX()" OPERATION 4 ACCESS 0 // "Desatualiz Financeiro ERP"
	ADD OPTION aRotina TITLE "Atualizar Doc Frete Fiscal ERP" ACTION "GFEA070ADF()" OPERATION 4 ACCESS 0 // "Atualizar Doc Frete Fiscal ERP"
	If SuperGetMv("MV_ERPGFE",.F.,"2") == "1" .And. SuperGetMv("MV_FTMLA",.F.,"1") $ "2|3|4"
		If Select('SX2') > 0
			ADD OPTION aRotina TITLE "Desatualizar MLA" ACTION "GFEA070DMA" OPERATION 10 ACCESS 0
		EndIf
	EndIf

	ADD OPTION aRotina TITLE "Anexos" ACTION "ValX2Unico()"  OPERATION 4 ACCESS 0  // "Anexo"

	// Início Ponto de Entrada Ellece
	If ExistBlock("GFEA0706")
		aRotina := ExecBlock("GFEA0706",.f.,.f.,{aRotina})
	EndIf
	// Fim Ponto de Entrada Ellece

	RestArea(aArea)
Return aRotina

//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local cTpInt   := SuperGetMv("MV_ERPGFE", .F., "")
	Local oStruGW6 := FWFormStruct(1, 'GW6') // Estrutura da tabela
	Local oStruGW7 := FWFormStruct(1, 'GW7') // Estrutura da tabela
	Local oStruGWJ := FWFormStruct(1, 'GWJ') // Estrutura da tabela

	Default lAltFat := .F.

	//Valor da pré-fatura
	//Retirado temporáriamente, precisa corrigir função com o retorno do valor, não utilizar quando não houver pré-fatura vinculada
//	oStruGWJ:AddField ("Valor Pré-Fatura"    , "Valor Pré-Fatura"   , "GWJ_VLPF" , "N", 12, 2           , /*bVALID*/,{||.T.}/*bWHEN*/,/*@aVALUES*/,, FWBuildFeature(3, "GFEA055VL(.T.)")/*bINIT*/,/*lKEY*/,/*lNOUPD*/,.T./*lVIRTUAL*/)
	oStruGWJ:AddField ("Valor Pré-Fatura"    , "Valor Pré-Fatura"   , "GWJ_VLPF" , "N", 12, 2           , /*bVALID*/,{||.T.}/*bWHEN*/,/*@aVALUES*/,, FWBuildFeature(3, "IIF(INCLUI,0,GFEA055VL(.T.))")/*bINIT*/,/*lKEY*/,/*lNOUPD*/,.T./*lVIRTUAL*/)

	// Acrescenta um campo a estrutura antes a criação do model
	oStruGW6:AddField( ;                    // Ord. Tipo Desc.
	STR0036         , ; // [01]  C   Titulo do campo  // "Frete A Pagar"
	STR0036         , ; // [02]  C   ToolTip do campo // "Frete A Pagar"
	'GW6_CTFRET'	, ; // [03]  C   Id do Field
	'C'             , ; // [04]  C   Tipo do campo
	20              , ; // [05]  N   Tamanho do campo
	0               , ; // [06]  N   Decimal do campo
	NIL             , ; // [07]  B   Code-block de validação do campo
	NIL             , ; // [08]  B   Code-block de validação When do campo
	NIL             , ; // [09]  A   Lista de valores permitido do campo
	NIL             , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
	{|| '0'}        , ; // [11]  B   Code-block de inicializacao do campo
	NIL             , ; // [12]  L   Indica se trata-se de um campo chave
	NIL             , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.             )   // [14]  L   Indica se o campo é virtual

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA070", /*bPre*/, {|oX| GFEA070PV(oX)}/*bPost*/, {|oX| GFEA070CMT(oX) }/*bCommit*/, /*bCancel*/)
	//oModel:SetVldActivate ( )

	If GFXCP12130("GW6_NATURE") .And. !isBlind()
		oStruGW6:SetProperty("GW6_NATURE", MODEL_FIELD_WHEN , {|| iif(cTpInt=="2", .T., .F.)})
	EndIf

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	//oModel:AddFields("GFEA070_GW6", Nil, FWFormStruct(1,"GW6"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddFields("GFEA070_GW6", Nil, oStruGW6,/*bPre*/,/*bPost*/,/*bLoad*/)

	//Apenas associa as tabelas GW7 e GWJ ao model se for chamado pelo envio de Fatura
	oModel:AddGrid("GFEA070_GW7", "GFEA070_GW6", oStruGW7, /*bLinePre*/, /**/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetRelation("GFEA070_GW7",{{"GW7_FILIAL", "GW6_FILIAL"},{"GW7_EMIFAT", "GW6_EMIFAT"},{"GW7_SERFAT", "GW6_SERFAT"},{"GW7_NRFAT", "GW6_NRFAT"}}, "GW7_FILIAL+GW7_EMIFAT+GW7_SERFAT+GW7_NRFAT")

	oModel:AddGrid( "GFEA070_GWJ" , "GFEA070_GW6" , oStruGWJ ,/*bLinePre*/,/**/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA070_GWJ",{{"GWJ_FILFAT", "GW6_FILIAL"},{"GWJ_EMIFAT", "GW6_EMIFAT"},{"GWJ_SERFAT", "GW6_SERFAT"},{"GWJ_NRFAT", "GW6_NRFAT"},{"GWJ_DTEMFA", "GW6_DTEMIS"}},"GWJ_FILFAT+GWJ_EMIFAT+GWJ_SERFAT+GWJ_NRFAT+GWJ_DTEMFA")
	oModel:SetOnlyQuery("GFEA070_GWJ" )

	oModel:GetModel( "GFEA070_GW7" ):SetOptional(.T.)
	oModel:GetModel( "GFEA070_GWJ" ):SetOptional(.T.)

	oModel:SetPrimaryKey({"GW6_FILIAL", "GW6_EMIFAT", "GW6_SERFAT", "GW6_NRFAT", "GW6_DTEMIS"})

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)

	oModel:SetActivate({|oMod| GF70_GW6ACT(oMod)})

Return oModel

//------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oView   := Nil
	Local oModel  := FWLoadModel("GFEA070")
	Local oStruct := FWFormStruct(2,"GW6")

	oStruct:AddGroup("GrpGrl", STR0038, "1", 2) // "Geral"
	oStruct:AddGroup("GrpVal", STR0039, "1", 2) // "Valores"
	oStruct:AddGroup("GrpImp", STR0040, "1", 2) // "Impostos"
	oStruct:AddGroup("GrpObs", STR0041, "1", 2) // "Observações"

	oStruct:AddGroup("GrpBlq", STR0042, "2", 2) // "Bloqueio"
	oStruct:AddGroup("GrpApr", STR0043, "2", 2) // "Aprovação"
	oStruct:AddGroup("GrpInt", STR0044, "2", 2) // "Integração"

	oStruct:SetProperty("GW6_EMIFAT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_NMEMIT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_SERFAT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_NRFAT" , MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_DTEMIS", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_DTCRIA", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_DTVENC", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStruct:SetProperty("GW6_SITAPR", MVC_VIEW_GROUP_NUMBER, "GrpGrl")

	oStruct:SetProperty("GW6_VLFATU", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStruct:SetProperty("GW6_VLDESC", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStruct:SetProperty("GW6_VLJURO", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	If GFXCP12118("GW6_DINDEN")
		oStruct:SetProperty("GW6_DINDEN", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	EndIf
	oStruct:SetProperty("GW6_VLISS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_VLISRE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_DSISCD", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_DSISCL", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_VLICMS", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_VLICRE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_DSICCD", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_DSICCL", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_DSESPF", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_PRNAT" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStruct:SetProperty("GW6_MATREX", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	If GFXCP12130("GW6_VLIRRF") .And. GFXCP12130("GW6_NATURE")
		oStruct:SetProperty("GW6_VLIRRF", MVC_VIEW_GROUP_NUMBER, "GrpImp")
		oStruct:SetProperty("GW6_NATURE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	EndIf

	oStruct:SetProperty("GW6_OBS"   , MVC_VIEW_GROUP_NUMBER, "GrpObs")
	oStruct:SetProperty("GW6_USUIMP", MVC_VIEW_GROUP_NUMBER, "GrpObs")

	oStruct:SetProperty("GW6_DTBLOQ", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStruct:SetProperty("GW6_HRBLOQ", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStruct:SetProperty("GW6_USUBLO", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStruct:SetProperty("GW6_MOTBLO", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStruct:SetProperty("GW6_MOTDES", MVC_VIEW_GROUP_NUMBER, "GrpBlq")

	oStruct:SetProperty("GW6_DTAPR" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStruct:SetProperty("GW6_HRAPR" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStruct:SetProperty("GW6_USUAPR", MVC_VIEW_GROUP_NUMBER, "GrpApr")

	oStruct:SetProperty("GW6_MOTFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStruct:SetProperty("GW6_SITFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStruct:SetProperty("GW6_DTFIN" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStruct:SetProperty("GW6_HRFIN" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStruct:SetProperty("GW6_USUFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	If GFXCP12127("GW6_DTLIQD")
		oStruct:SetProperty("GW6_DTLIQD", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	EndIf

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField("GFEA070_GW6", oStruct, /*cLinkID*/)
	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

	oView:CreateHorizontalBox('MASTER', 100)

	// Associa um View a um box
	oView:SetOwnerView("GFEA070_GW6", "MASTER")

Return oView

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070ALT()
Validação de alteração
Generico

@sample
GFEA070ALT()

@author Israel Possoli
@since 02/03/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070ALT()
	Local nRet   := 0
	Local lRet   := .T.

	// Não permite alterar documentos com situação financeiro Pendente
	If GW6->GW6_SITFIN == "2"
		Help( ,, 'HELP',, "Não é possível alterar um Documento Pendente", 1, 0,) //"Não é possível alterar um Documento Pendente"
		lRet := .F.
		// Não permite alterar documentos com situação financeiro Atualizado
	ElseIf GW6->GW6_SITFIN == "4"
		Help( ,, 'HELP',, "Não é possível alterar um Documento Atualizado", 1, 0,) //"Não é possível alterar um Documento Atualizado"
		lRet := .F.
		// Não permite alterar documentos com situação financeiro Pendente desatualização
	ElseIf GW6->GW6_SITFIN == "5"
		Help( ,, 'HELP',, "Não é possível alterar um Documento pendente de desatualização", 1, 0,) //"Não é possível alterar um Documento pendente de desatualização"
		lRet := .F.
	Endif

	If lRet
		lAltFat := .T.
		nRet := FWExecView("", "GFEA070", 4, , {|| .T.})
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA070EXC
Rotina para exclusão da Fatura
Usada também da exclusão da Fatura via integração

@author Israel Alcantara Possoli
@since 30/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA070EXC()
	Local lAprovMLA := SuperGetMv("MV_ERPGFE",.F.,"1") == "1" .And. SuperGetMv("MV_FTMLA",.F.,"1") $ "2|3|4"

	// Fatura Pendente
	If GW6->GW6_SITFIN == "2"
		Help( ,, 'HELP',, "Não é possível excluir a Fatura, pois a mesma está pendente no Financeiro.", 1, 0,)
		Return
	EndIf

	// Fatura pendente de desatualização no Financeiro
	If GW6->GW6_SITFIN == "5"
		Help( ,, 'HELP',, "A Fatura está Pendente de Desatualização no Financeiro, aguarde retorno.", 1, 0,)
		Return
	EndIf

	If GW6->GW6_SITFIN == "4"	// Fatura atualizada será marcada como excluída
		Help( ,, 'HELP',, "A Fatura está Atualizada no Financeiro. Primeiramente a Fatura deve ser desatualizada para então poder ser excluída.", 1, 0,)
		Return
	EndIf

	If GfeVerCmpo({"GW6_SITMLA"})
		// Validação para não excluir antes de desatualizar a fatura no MLA
		If lAprovMLA .And. !(GW6->GW6_SITMLA $ "1|6" .Or. Empty(GW6->GW6_SITMLA))
			Help(,,'HELP',,"Fatura está integrada ao MLA ou pendente de integração, realize a desatualização para esta operação.",1,0)
			Return
		EndIf
	EndIf

	// Exclusão padrão quando a situação no financeiro estiver como Não Enviada (1) ou Rejeitada (3)
	FWExecView("", "GFEA070", 5,, {|| .T.})

Return

//---------------------------------------------------------------------------------------------------
/*
{Protheus.doc} GFEA070PV(oModel)
Digitação de Faturas de Frete
Generico

@param  oModel  	Objeto modelo

@sample
GFEA070PV(oModel)

@author Felipe M.
@since 23/11/09
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Function GFEA070PV(oModel)
	Local nI
	Local nOp       	:= oModel:GetOperation()
	Local oModelGW6 	:= oModel:GetModel("GFEA070_GW6")
	Local cUniFat   	:= GetNewPar("MV_GFEVLFT", "3")
	Local cChaveFat 	:= ""
	Local aAreaGW6  	:= GW6->( GetArea() )
	Local aDocFrete 	:= {}
	Local aPreFat   	:= {}
	Local aRet      	:= {.T.,"",""}
	Local cValCaractere := ""
	Local cNovoNumFat   := ""
	Local cVarSol		:= ""

	aAuxDF := Nil	// Usado para compatibilização e identificação da associação entre Fatura e DF dentro da função de commit

	//Se for chamado pela integração, não efetua as validações.
	If IsInCallStack("GFEA070In")
		If nOp == MODEL_OPERATION_UPDATE
			If FWFldGet("GW6_SITFIN") $ "25" //"Atualizar Financeiro ERP"
				GFEA070IPG(FWFldGet("GW6_SITFIN"),oModel,@aRet)
				If !Empty(aRet[2])
					If !aRet[1] //Retoro falso
						oModel:SetValue( 'GFEA070_GW6', 'GW6_SITFIN', "3") //Situação Rejeitado
						oModel:SetValue( 'GFEA070_GW6', 'GW6_MOTFIN', AllTrim(aRet[3]) )

					Else //Retoro verdadeiro
						oModel:SetValue( 'GFEA070_GW6', 'GW6_SITFIN', "4") //Situação Atualizado
						oModel:SetValue( 'GFEA070_GW6', 'GW6_MOTFIN', " ")
					EndIf
				EndIf
			EndIf
		EndIf
		Return .T.
	EndIf

	If nOp == MODEL_OPERATION_INSERT
		If Empty(cUniFat)
			cUniFat := "3"
		EndIf

		If cUniFat == "1"
			cChaveFat := (oModelGW6:GetValue("GW6_NRFAT"))
			cVarSol   := STR0049
		ElseIf cUniFat == "2"
			cChaveFat := (oModelGW6:GetValue("GW6_NRFAT")) + (oModelGW6:GetValue("GW6_SERFAT"))
			cVarSol   := STR0050
		ElseIf cUniFat == "3"
			cChaveFat := (oModelGW6:GetValue("GW6_NRFAT")) + (oModelGW6:GetValue("GW6_SERFAT")) + DToS(oModelGW6:GetValue("GW6_DTEMIS"))
			cVarSol   := STR0051
		EndIf

		GW6->( dbSetOrder(2) )
		If GW6->( dbSeek(xFilial("GW6") + oModelGW6:GetValue("GW6_EMIFAT") + cChaveFat) )
			GFEMessage(5,GFEA070001,GFEMsgFmt(STR0047,{{"[VAR01]",xFilial("GW6")}}),GFEMsgFmt(STR0048,{{"[VAR01]",cVarSol}}))

			RestArea(aAreaGW6)
			Return .F.
		EndIf
		
		For nI := 1 To Len(AllTrim(oModelGW6:GetValue("GW6_NRFAT")))
			cValCaractere := SUBSTR(AllTrim(oModelGW6:GetValue("GW6_NRFAT")),nI,1)
			
			If(cValCaractere == "'")
				cValCaractere := '"'
			EndIf

			cNovoNumFat += cValCaractere
		Next

		oModelGW6:SetValue("GW6_NRFAT",cNovoNumFat)

		cValSerie := AllTrim(oModelGW6:GetValue("GW6_SERFAT"))
		oModelGW6:SetValue("GW6_SERFAT",cValSerie)

		RestArea(aAreaGW6)
	EndIf

	//	Obrigar informar um valor maior que zero
	If nOp == MODEL_OPERATION_INSERT .OR. nOp == MODEL_OPERATION_UPDATE  // Se for inclusao ou alteração
		If oModel:GetValue('GFEA070_GW6', 'GW6_VLFATU') <= 0
			Help( ,, 'Help',, STR0018, 1, 0 )  //"Favor informar um valor maior que zero para Valor Bruto da Fatura"
			Return .F.
		EndIf

		If (oModelGW6:GetValue("GW6_VLDESC")) >= (oModelGW6:GetValue("GW6_VLFATU"))
			oModel:SetErrorMessage(,,,,,"Informe um valor de desconto menor que o valor Fatura.")
			Return .F.
		EndIf

		If nOp == MODEL_OPERATION_UPDATE .AND. !oModel:isFieldUpdated('GFEA070_GW6','GW6_SITFIN')	// Quando muda situação de integração, não altera situação de aprovação
			oModel:LoadValue( 'GFEA070_GW6', 'GW6_SITAPR', "1")

			// Eliminação dos movimentos contábeis para a fatura
			If GW6->GW6_SITFIN != "4"
				GFECTBFATD(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
			EndIf

			// Retorna a PF para situação Enviada, se for o caso
			GFEA071CON("2")
		EndIf
	EndIf

	If nOp == MODEL_OPERATION_DELETE // Se for exclusão
		If GW6->GW6_SITFIN == "2"
			Help( ,, 'Help',, "Fatura com a situação pendente no Financeiro não pode ser excluida", 1, 0 )
			Return .F.
		EndIf

		GFECTBFATD(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)

		//Eliminar o relacionamento dos documentos de frete da fatura;
			dbSelectArea("GW3")
		GW3->( dbSetOrder(8) ) //GW3_FILFAT+GW3_EMIFAT+GW3_SERFAT+GW3_NRFAT+DTOS(GW3_DTEMFA)
		GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
		While !Eof() .AND. GW6->GW6_FILIAL+GW6->GW6_EMIFAT+GW6->GW6_SERFAT+GW6->GW6_NRFAT+DtoS(GW6->GW6_DTEMIS) == ;
				GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DTOS(GW3->GW3_DTEMFA)

			AAdd(aDocFrete, GW3->( RecNo() ))

			GW3->( dbSkip() )
		EndDo

		aAuxDF := aDocFrete

		For nI := 1 To Len(aDocFrete)
			GW3->( dbGoTo(aDocFrete[nI]) )

			RecLock("GW3", .F.)
			GW3->GW3_FILFAT := ""
			GW3->GW3_EMIFAT := ""
			GW3->GW3_SERFAT := ""
			GW3->GW3_NRFAT  := ""
			GW3->GW3_DTEMFA := Ctod("  /  /  ")
			GW3->( MsUnlock() )
		Next nI

		dbSelectArea("GWJ")
		GWJ->( dbSetOrder(7) )//GWJ_FILIAL+GWJ_FILFAT+GWJ_EMIFAT+GWJ_SERFAT+GWJ_NRFAT
		GWJ->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
		While !GWJ->( Eof() ) .And. GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS) == ;
				GWJ->GWJ_FILFAT + GWJ->GWJ_EMIFAT + GWJ->GWJ_SERFAT + GWJ->GWJ_NRFAT + DToS(GWJ->GWJ_DTEMFA)

			AAdd(aPreFat, GWJ->( RecNo() ))

			GWJ->( dbSkip() )
		EndDo

		// Retorna a PF para situação Enviada, se for o caso
		GFEA071CON("2")
		For nI := 1 To Len(aPreFat)
			GWJ->( dbGoTo(aPreFat[nI]) )

			RecLock("GWJ", .F.)
			GWJ->GWJ_FILFAT := ""
			GWJ->GWJ_EMIFAT := ""
			GWJ->GWJ_SERFAT := ""
			GWJ->GWJ_NRFAT  := ""
			GWJ->GWJ_DTEMFA := Ctod("  /  /  ")
			GWJ->( MsUnlock() )
		Next nI
	EndIf

	FatCalcIRRF(oModel)

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070AV()
Validação de campo emissor
Generico

@sample
GFEA070AV()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070AV()

	If Posicione("GU3", 1, xFilial("GU3") + M->GW6_EMIFAT, "GU3_TRANSP") != "1"
		Help( ,, 'Help',, STR0020, 1, 0 ) //"Não é permitido incluir emissor que não seja um transportador"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070CC()
Aprovação
Generico

@sample
GFEA070CC()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070CC()
	FWExecView(STR0007, "GFEC070", 1,,{|| .T.}) //"Visualizar"
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070VD()
Validação de Data de emissão da Fatura e Data de Vencimento
Generico

@sample
GFEA070VD()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070VD()
	Local oModel := FWModelActive()
	Local nOp    := oModel:GetOperation()

	If M->GW6_DTEMIS > dDataBase
		Help( ,, 'Help',, "A Data de Emissão não pode ser maior que a data atual.", 1, 0 ) // "A Data de Emissão não pode ser maior que a data atual."
		Return .F.
	EndIf

	If nOp == 4 .AND. M->GW6_DTEMIS > M->GW6_DTVENC .AND. !Empty(M->GW6_DTEMIS) .AND. !Empty(M->GW6_DTVENC)
		Help( ,, 'Help',, "Data de vencimento da fatura deve ser maior que a data de emissão", 1, 0 ) //"Data de vencimento da fatura deve ser maior que a data de emissão"
		Return .F.
	ElseIf nOp == 3 .AND. M->GW6_DTEMIS > M->GW6_DTVENC .And. !Empty(M->GW6_DTVENC)
		Help( ,, 'Help',, "Data de vencimento da fatura deve ser maior que a data de emissão", 1, 0 )  //"Data de vencimento da fatura deve ser maior que a data de emissão"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070CF()
Função responsavel por trazer a tela de conferencia
Generico

@sample
GFEA070CF()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070CF()
	Private oMemo, cMemo := GW6->GW6_MOTDES
	Private dDtCalc, cFatura, cDocFret, cPreFat, cDocFret2, cCalccDifer, cVaria, cVaria2, cIcms, cIcms2, cDifer2, cIss, cIss2, cDifer3 , CDTVENC
	Private cTpImp, cAliMKB
	Private nVlFat, nVLPFat, nVLDocF, nFVLVAR, nFPCVAR, nVLDocFret, nVlImpDF, nVlImpC
	Private dDtVencM1, dDtVencC1

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Browse de conferencia de Doc Frete
	//----------------------------------------------
	aMKB := {{"GW3_SIT"  , "C", 02, 0},;
		{"FILIAL"   , "C", Len(cFilAnt), 0},;
		{"TIPO"     , "C", 05, 0},;
		{"SERIE"    , "C", 05, 0},;
		{"DOCUM"    , "C", 16, 0},;
		{"TPCALC"   , "C", 09, 0},;
		{"VLINFO"   , "N", 10, 2},;
		{"VLCALC"   , "N", 10, 2},;
		{"DIFVALOR" , "N", 10, 2},;
		{"VLIMPINF" , "N", 10, 2},;
		{"VLIMPCALC", "N", 10, 2},;
		{"DIFVLIMP" , "N", 10, 2},;
		{"EMISDF"   , "C", TamSX3("GU3_CDEMIT")[1],0},;
		{"DTEMIS"   , "D", 08, 0}}

	cAliMKB := GFECriaTab({aMKB, {"TIPO+DOCUM"}})

	Processa({|| GFEA071RA(.F.)}, STR0023, STR0024) // Função responsavel pela geração de dados para a tela de conferencia //"Processando informações"###"Aguarde"

	GFEA071CF() // função responsavel por criar a tela de conferencia

	//------ Limpa as tabelas temporarias -----//
	GFEDelTab(cAliMKB)

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070CO()
Função responsavel por validar e chamar a conferencia
Generico

@sample
GFEA070CO()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070CO()
	Local lRetDesc	  := .T.

	dbSelectArea("GW3")
	GW3->( dbSetOrder(8) )
	If GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DtoS(GW6->GW6_DTEMIS)) )
		//não deve ser possivel conferir a fatura se a mesma estivar aprovada
		If GW6->GW6_SITAPR $ "3/4"
			Help( ,, 'Help',, STR0037, 1, 0 ) //"Não é possivel conferir a fatura se a mesma já estiver aprovada."
			Return .F.
		Else
			If GFXCP12118("GW6_DINDEN")
				lRetDesc := GFEA070IND()
			EndIf

			If lRetDesc
				GFECTBFATD(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
				GFEA071RA(.T.)
			Else
				Return .F.
			EndIf
		EndIf
	Else
		Help(,, 'Help',, STR0025, 1, 0 ) //"Não é possivel Conferir uma Fatura sem Documento de Frete"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} cha()
Integração com EMS
Generico

@sample
GFEA070X()

@param
lAutom := Indica se a rotina foi chamada pela Integração automatica

@author Israel Possoli
@since 02/03/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070X(lAutom,lMsg)
	Local aRet		 := {}
	Local aIntegr	 := {}
	local aDocFrete  := {}
	Local lOk      	 := .F.
	Local lRet     	 := .T.
	Local dData	   	 := Date()
	Local nI 		 := 0
	Local cParInt  	 := SuperGetMV('MV_GFEI16',,'1') //  Parametro Int Pré-fatura com Financeiro
	Local lIntGFE  	 := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 	 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cIntFisc   := SuperGetMv("MV_GFEI23",.F.,"2")
	Local s_GFEA0707 := ExistBlock("GFEA0707")
	Local cIntGFEI13 := SuperGetMV('MV_GFEI13',,'1')
	Local cIntGFEI14 := SuperGetMV('MV_GFEI14',,'1')
	Local nRecnoGW3  := 0
	Local nTotMov    := 0

	Private cParData := SuperGetMV('MV_DSDTAP',,'1') // Parametro Int Origem Data de Integração

	Default lAutom   := .F.
	Default lMsg 	 := .T.

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)

	If Empty(cParData)
		cParData := "1"
	EndIf

	If cParInt != "3"
		If GW6->GW6_SITAPR == "3" .Or. GW6->GW6_SITAPR == "4"

			If GW6->GW6_SITFIN == "1" .Or. GW6->GW6_SITFIN == "3"


				GW7->(dbSetOrder(1))
				If GW7->(dbSeek( GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS )))

					While !GW7->( Eof() ) .AND. ;
							GW7->GW7_FILIAL == GW6->GW6_FILIAL .AND. ;
							GW7->GW7_EMIFAT == GW6->GW6_EMIFAT .AND. ;
							GW7->GW7_SERFAT == GW6->GW6_SERFAT .AND. ;
							GW7->GW7_NRFAT  == GW6->GW6_NRFAT  .AND. ;
							GW7->GW7_DTEMIS == GW6->GW6_DTEMIS

						nTotMov += GW7->GW7_VLMOV

						GW7->( dbSkip() )
					EndDo
				EndIF

				If nTotMov == GW6->GW6_VLFATU .Or. nTotMov == 0
					If SuperGetMV("MV_ERPGFE",,"2") == '2' //quando o ERP for Protheus a data de integração/transação será atribuída pelo sistema com a data corrente
						dData := dDataBase
						lOK := .T.
					Else

						If SuperGetMv("MV_FTMLA",.F.,"1") == "4" .And. GW6->GW6_SITMLA != "4"
							Help( ,, 'Help',, "Para integrar com o Financeiro, a fatura deve ter aprovação de pagamento através do módulo MLA.", 1, 0 )
							Return .F.
						EndIf

						If s_GFEA0707
							aIntegr 	:= ExecBlock("GFEA0707",.f.,.f.)
							s_GFEA0707 	:= aIntegr[1]
							dData 		:= aIntegr[2]
							lOK   		:= aIntegr[3]
						EndIf

						If !s_GFEA0707
							If cParData == "3" //Informada Usuário

								DEFINE DIALOG oDlg TITLE STR0028 FROM 180,180 TO 350,460 PIXEL //"Seleciona a Data"
								// Cria objeto
								oMsCalend := MsCalend():New(01,01,oDlg,.F.)

								// Define o dia a ser exibido no calendário
								oMsCalend:dDiaAtu := dData

								// Code-Block para mudança de Dia
								//oMsCalend:bChange := {|| Alert('Dia Selecionado: ' + dtoc(oMsCalend:dDiaAtu)) }
								oMsCalend:bChange := {|| dData := oMsCalend:dDiaAtu}

								// Code-Block para mudança de mes
								//oMsCalend:bChangeMes := {|| alert('Mes alterado') }

								oTButton1 := TButton():New( 070, 30, STR0029,oDlg,{||lOk := .T.,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Ok"
								oTButton1 := TButton():New( 070, 75, STR0030,oDlg,{||oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
								lOK := .T.

								ACTIVATE DIALOG oDlg CENTERED

							ElseIf cParData == "1" 		//Data Corrente
								dData := DDATABASE
								lOK := .T.
							ElseIf cParData == "2" 		//Data Criação
								dData := GW6->GW6_DTCRIA
								lOK := .T.
							EndIf
						EndIf
					EndIf
				Else
					Help( ,, 'Help',, STR0053, 1, 0 ) // "O total dos Rateios deve ser igual ao total da fatura."
					lOk := .F.
				EndIf

				If dData < GW6->GW6_DTEMIS
					Help( ,, 'Help',, STR0031, 1, 0 )  //"A data de transação deve ser maior que a data de emissão"
					lOk := .F.
				EndIf

				If lOk .And. dData < SuperGetMv("MV_DTULFE",,"20000101")
					Help( ,, 'Help',, STR0032 + DTOC(SuperGetMv("MV_DTULFE",,"20000101")) + STR0035, 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: " //" (Parâmetro MV_DTULFE)"
					lOk := .F.
				EndIf

				/*---------- INTEGRA FINANCEIRO SOMENTE APÓS TODOS DOCTO FRETE ATUALIZADOS NO FISCAL -----------------*/
				If cIntFisc == "1"
					GW3->(dbSetOrder(8))
					If GW3->(dbSeek( GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS )))

						While !GW3->( Eof() ) .AND. ;
								GW3->GW3_FILFAT == GW6->GW6_FILIAL .AND. ;
								GW3->GW3_EMIFAT == GW6->GW6_EMIFAT .AND. ;
								GW3->GW3_SERFAT == GW6->GW6_SERFAT .AND. ;
								GW3->GW3_NRFAT  == GW6->GW6_NRFAT  .AND. ;
								GW3->GW3_DTEMFA == GW6->GW6_DTEMIS

							// Teste para integrar com o Datasul
							For nI := 1 to 3
								nRecnoGW3 := GW3->(Recno())
								GW3->(dbGoto(nRecnoGW3))

								If (cIntGFEI13 == "2" .AND. GW3->GW3_SITFIS == "2") .OR. (cIntGFEI14 == "2" .AND. GW3->GW3_SITREC == "2")
									Sleep(10000)
								EndIf
							Next nI

							// Verifica a situação da integração Fiscal
							If ( GW3->GW3_SITFIS != "4" .AND. GW3->GW3_SITFIS != "6" .AND. GW3->GW3_SITREC == "6" ) .OR.; //SIT. REC == 6 GARANTE QUE NÃO É DOC. FRETE SOBRE ENTRADAS
								(GW3->GW3_SITREC != "4" .AND. GW3->GW3_SITREC != "6") //ERP=DATASUL E ATUALIZA FISCAL VIA RECEBIMENTO E A SITUACAO REC <> ATUALIZADA OU <> NÃO SE APLICA

								If LEN(aDocFrete) = 0
									AADD(aDocFrete, "Atualize os seguintes Documentos de Frete no Fiscal ERP: ")
								EndIf

								AADD(aDocFrete, GW3->GW3_NRDF + "; ")
							EndIF

							GW3->( dbSkip() )
						EndDo
					EndIF

					If LEN(aDocFrete) > 0
						lOk := .F.
						Help( ,, 'Help',, "Para integrar com o financeiro, todos os Documentos de Frete da fatura devem estar atualizados no fiscal.", 1,,,,,,,aDocFrete )
					EndIf
				EndIf
				/*----*/					

				// Início Ponto de Entrada Britania
				If ExistBlock("XGFEENFN")
					aRetorno := ExecBlock("XGFEENFN",.f.,.f.,{GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS})
					If aRetorno == .F.
						Return {.F., {,,,,,"Retornado erro pelo ponto de entrada XGFEENFN"}}
					EndIf
				EndIf
				// Fim Ponto de Entrada Britania

				If lOk
					//Chama a função para vincular as pré-faturas que por ventura ainda não foram vinculadas.
					GFEVINCPFC(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS,, .T.)

					aRet := GFEA070In("2", dData)

					If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
						If lMsg
							If aRet[1]
								If !(cParInt == "2")
									MsgInfo("Fatura enviada para atualização no Financeiro.")
								EndIf
							Else
								Alert("Fatura não foi enviada para atualização no Financeiro por causa do seguinte erro: " + aRet[2][6])
							EndIf
						Endif
					EndIf
				EndIf
			Else
				Help( ,, 'Help',, STR0033, 1, 0 )  //"Documento Pendente ou já Atualizado"
			EndIf
		Else
			Help( ,, 'Help',, STR0034, 1, 0 )  //"Fatura não aprovada"
		EndIf

	ElseIf cParInt == "3" //Não Integrar
		Help( ,, 'Help',, "Sistema parametrizado como Não Integrar Fatura com o Financeiro", 1, 0 )
	EndIf

	If lOk
		If ExistBlock("GFEA0708")
			ExecBlock("GFEA0708",.F.,.F.,{})
		EndIf
	EndIf

Return {lRet, aRet}

/*
{Protheus.doc} GFEA070DX
Função para desatualizar a Fatura posicionada(GW6) no Financeiro.

@sample
GFEA070DX()

@author Octávio Augusto Felippe de Macedo
@since 15/05/2012
@version 1.0
*/
Function GFEA070DX()
	Local cERPGFE	:= SuperGetMV("MV_ERPGFE",,"1")
	Local aRetVld	:= {}
	Local aRetDes	:= {}

	aRetVld := VldDesAtuFatura()

	If aRetVld[1] == .T.
		If MsgNoYes("Deseja desatualizar a Fatura no Financeiro?", "Aviso")
			RecLock("GW6",.F.)
			GW6->GW6_SITFIN := "5" // Pendente Desatualização
			GW6->GW6_USUFIN := cUserName
			GW6->(MsUnLock())

			If cERPGFE == "1"
				MsgInfo("Fatura enviada para desatualização no Financeiro.")
			ElseIf cERPGFE == "2"
				aRetDes := DesAtuFatura()
				If aRetDes[1] //Desatualização da Fatura no Financeiro
					//Manipular fatura após Desatualização no Financeiro
					If ExistBlock("GFEA0703")
						ExecBlock("GFEA0703",.F.,.F.,{})
					EndIf

					RecLock("GW6", .F.)
					GW6->GW6_SITFIN := "1"
					GW6->GW6_MOTFIN := ""
					GW6->( MsUnlock() )

					MsgInfo("Fatura desatualizada no Financeiro.")
				Else
					RecLock("GW6", .F.)
					GW6->GW6_SITFIN := "4"
					GW6->GW6_MOTFIN := aRetDes[2]
					GW6->( MsUnlock() )

					Alert("Fatura não foi desatualizada no Financeiro. Motivo: " + aRetDes[2])
				EndIf
			EndIf
		EndIf
	Else
		Help( ,, 'HELP',, aRetVld[2], 1, 0,)
	EndIf
Return

/*
{Protheus.doc} GFEA070ADF
Função para atualizar os Documentos de Frete da Fatura no Fiscal

@sample
GFEA070ADF()

@author Octávio Augusto Felippe de Macedo
@since 04/12/2012
@version 1.0
*/
Function GFEA070ADF(lMsg, dDtOf)
	Local aIntDF     := {}
	Local nDF        := 1
	Local cTexto     := ""
	Local dData      := Nil
	Local lDataAFFin := SuperGetMv("MV_DSOFDT")
	Local nERPInt    := SuperGetMv("MV_ERPGFE" ,.F.,"2")
	Local lIntDocF   := SuperGetMv('MV_DSCTB',, '1') == "2"
	Local lRetPE     := .T.
	Local nVlMov     := 0
	Local s_DTULFE   := SuperGetMv("MV_DTULFE",,"20000101")
	Local cIntGFEI13 := SuperGetMV('MV_GFEI13',,'1')

	Default lMsg  := .T.
	Default dDtOf := Nil

	If cIntGFEI13 == "3"
		Help( ,, 'Help',, "Sistema parametrizado como Não Integrar Doc Frete com o Fiscal.", 1, 0 ) // "Sistema parametrizado como Não Integrar Doc Frete com o Fiscal."
		Return
	EndIf

	If lDataAFFin != "3"
		dData := dDatabase
	EndIf

	If GW6->GW6_SITFIN != "4" .AND. lDataAFFin == "2"
		Help( ,, 'Help',, "A Fatura deve estar atualizada no Financeiro para enviar os Documentos de Frete relacionados para o Fiscal.", 1, 0 ) //"A Fatura deve estar atualizada no Financeiro para enviar os Documentos de Frete relacionados para o Fiscal."
		Return
	EndIf

	// Ponto de entrada para permitir a inclusão de consistência
	// adicional na funcionalidade "Atualizar Doc Frete Fiscal ERP"
	If ExistBlock("GFEA0702")
		lRetPE := ExecBlock("GFEA0702",.F.,.F.)
		If ValType(lRetPE) == 'L' .And. !lRetPE
			Return .F.
		EndIf
	EndIf

	GW3->( dbSetOrder(8) )
	GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
	While !GW3->( Eof() ) .And. GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS) == ;
			GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA)

		If GW3->GW3_SITFIS $ "1;3" .Or. (GW3->GW3_SITFIS == "6" .And. GW3->GW3_SITREC $ "1;3")
			If nERPInt == "1"
				If lDataAFFin == "4"
					dData := Date()
				ElseIf lDataAFFin == "3" // Data Informada (3)
					If dDtOf == Nil
						If dData == Nil
							dData := GFEA065DT()
						EndIf
					Else
						dData := dDtOf
					EndIf
				ElseIf lDataAFFin == "2" // Data Financeira (2)
					dData := GW6->GW6_DTFIN
				ElseIf lDataAFFin == "1" // Data de Entrada (1)
					dData := GW3->GW3_DTENT
				EndIf
			EndIF

			If Empty(dData)
				AAdd(aIntDF, {GW3->GW3_NRDF, "Data de transação em branco.", .F.})
				GW3->( dbSkip() )
				Loop
			EndIf

			If dData <= s_DTULFE
				AAdd(aIntDF, {GW3->GW3_NRDF, "Data de transação deve ser posterior a data do último fechamento: " + DToC(s_DTULFE) + " (Parâmetro MV_DTULFE)", .F.})
				GW3->( dbSkip() )
				Loop
			EndIf

			If lIntDocF
				nVlMov := 0 //Somatória dos valores dos lançamentos contábeis do documento de frete

				GWA->(dbSetOrder(1))//GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)
				If GWA->(dbSeek(GW3->GW3_FILIAL+"2" +GW3->GW3_CDESP+GW3->GW3_EMISDF+GW3->GW3_SERDF+GW3->GW3_NRDF+ DTOS(GW3->GW3_DTEMIS)))
					While GWA->(!Eof()) .AND. GWA->GWA_FILIAL == GW3->GW3_FILIAL;
							.AND. GWA->GWA_TPDOC  == "2"; // Docto Frete
						.AND. GWA->GWA_CDESP  == GW3->GW3_CDESP;
							.AND. GWA->GWA_CDEMIT == GW3->GW3_EMISDF;
							.AND. GWA->GWA_SERIE  == GW3->GW3_SERDF;
							.AND. GWA->GWA_NRDOC  == GW3->GW3_NRDF;
							.AND. GWA->GWA_DTEMIS == GW3->GW3_DTEMIS

						nVlMov += GWA->GWA_VLMOV

						GWA->(DbSkip())
					EndDo
				EndIf

				If	nVlMov != GW3->GW3_VLDF
					AAdd(aIntDF, {GW3->GW3_NRDF, "No modo de integração fiscal pelo Recebimento, o valor do documento "+GW3->GW3_NRDF+"/"+GW3->GW3_SERDF+": "+ cValToChar(GW3->GW3_VLDF) +" deve ser igual ao total dos rateios contábeis: "+ cValToChar(nVlMov), .F.})
					GW3->( dbSkip() )
					Loop
				EndIf
			EndIf

			If GW3->GW3_SIT != "3" .And. GW3->GW3_SIT != "4"
				AAdd(aIntDF, {GW3->GW3_NRDF, "Somente Documentos de Frete Aprov.Sistema ou Aprov.Usuario podem ser integrados. Não é permitido realizar integrações de Documentos de Frete que não estão aprovados, realize a aprovação do documento antes de realizar a integração.", .F.})
				GW3->( dbSkip() )
				Loop
			EndIf

			If nERPInt = "1"
				If GW3->GW3_SITFIS == "6"
					RecLock("GW3", .F.)
					GW3->GW3_SITREC := "2"
					GW3->GW3_MOTREC := ""
					GW3->GW3_DTREC := dData
					GW3->( MsUnlock() )
					AAdd(aIntDF, {GW3->GW3_NRDF, "Atualizado para ser integrado.", .T.})
				Else
					RecLock("GW3", .F.)
					GW3->GW3_SITFIS := "2"
					GW3->GW3_MOTFIS := ""
					GW3->GW3_DTFIS := dData
					GW3->( MsUnlock() )
					AAdd(aIntDF, {GW3->GW3_NRDF, "Atualizado para ser integrado.", .T.})
				EndIf 
			Else
				aRet := GFEA065In("2", dData, "3","1")
				If aRet[1]
					AAdd(aIntDF, {GW3->GW3_NRDF, "Integração realizada com sucesso.", .T.})
				Else
					AAdd(aIntDF, {GW3->GW3_NRDF, "Erro na Integração. " + CRLF + "Motivo: " + aRet[2][6], .T.})
				EndIf
			EndIf
		EndIf

		GW3->( dbSkip() )
	EndDo

	If AScan(aIntDF, {|x| !x[3]}) > 0 
		cTexto := "Alguns Documentos de Frete não puderam ser enviados: " + CRLF + CRLF
	Else
		cTexto := "Documentos de Frete enviados para o Fiscal: " + CRLF + CRLF
	EndIf

	For nDF := 1 To Len(aIntDF)
		cTexto += "Nr Doc Frete: " + aIntDF[nDF][1] + CRLF
		cTexto += "Situação: " + If(ValType(aIntDF[nDF][2])=="A",aIntDF[nDF][2][6],aIntDF[nDF][2])
		cTexto += CRLF + CRLF
	Next nDF

	If lMsg
		DEFINE MSDIALOG oDlg TITLE "Atualização no fiscal" From 0,0 To 18,70 OF oMainWnd
		@ 4, 006 SAY "Resumo: " SIZE 130,7 PIXEL OF oDlg

		oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTexto:=u,cTexto)},oDlg,265,105,,,,,,.T.,,,,,,.T.)
		oButtonOK   := tButton():New(125,5,'OK',oDlg,{|| oDlg:End()},25,10,,,,.T.)
		ACTIVATE MSDIALOG oDlg CENTER
	Endif

Return cTexto

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070In()
Função utilizada em Integração.
Generico

@sample
GFEA070In()

@author Israel Possoli
@since 02/03/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA070In(cSituacao, dData)
	Local oModel := FWLoadModel("GFEA070")
	Local aRet   := {.T., {}}

	oModel:SetOperation( 4 )
	oModel:Activate()

	oModel:SetValue('GFEA070_GW6', 'GW6_SITFIN', AllTrim(cSituacao)) // SITUAÇÃO NO FINANCEIRO

	If cSituacao != "5"
		oModel:SetValue('GFEA070_GW6', 'GW6_DTFIN', dData) // DATA ENVIO AO FINANCEIRO -à Data informada pelo usuário
		oModel:SetValue('GFEA070_GW6', 'GW6_HRFIN', SubStr(Time(), 1, 5)) // HORA ENVIO AO FINANCEIRO
	EndIf

	If cSituacao == "2"
		oModel:ClearField('GFEA070_GW6', 'GW6_MOTFIN')
	EndIf
	oModel:SetValue('GFEA070_GW6', 'GW6_USUFIN', cUserName)// USUARIO ENVIO FINANCEIRO

	// Busca a conta de frete da filial

	If oModel:VldData()
		oModel:CommitData()
	Else
		aRet := {.F., oModel:GetErrorMessage()}
	EndIf

	oModel:Deactivate()

Return aRet
//------------------------------------------------------------------------------------------------

Function GFEA070BPF()
	Local aRet

	aRet := GFEVINCPFC(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)

	If !empty(aRet)
		MsgInfo("Foram adicionadas pré-faturas ao documento.")
		//Mudar Situação
		If GW6->GW6_SITAPR != "1"
			RecLock("GW6", .F.)
			GW6->GW6_SITAPR := "1"
			GW6->( MsUnLock() )
		EndIf
	else
		MsgInfo("Não foram adicionadas pré-faturas ao documento.")
	endIf

Return

//-----------------------------------------------------
/*/ Integração de Documentos de Frete como Documento de Entrada
	@author Felipe Machado de Oliveira
	@version P11
	@since 30/05/2013
/*/
//------------------------------------------------------
Function GFEA070IPG(cSituacao,oModel,aRet)
	Local cMsg := ""
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE := SuperGetMV("MV_ERPGFE",,"2")

	Private _oGFEXFBFL := GFEXFBFLog():New()

	If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"
		_oGFEXFBFL:setSaveLog(__lLogIntP)
		_oGFEXFBFL:setAgrFrt(GW6->GW6_NRFAT)
		If cSituacao == "2"
			If !AtuFatura(oModel,@cMsg) //Atualização da Fatura no Financeiro
				aRet := {.F.,"2",cMsg}
			Else
				aRet := {.T.,"2",""}
			EndIf
		EndIf
		_oGFEXFBFL:SaveLog()
	EndIf

Return

//-----------------------------------------------------
/*/	Atualização do documento de frete no Protheus
	@author Felipe Machado de Oliveira
	@version P11
	@since 30/05/2013
/*/
//------------------------------------------------------
Static Function AtuFatura(oModel,cMsg)
	Local aFatura   	:= {}
	Local aRatCont  	:= {}
	Local aRatAll   	:= {}
	Local aPreFat   	:= {}
	Local aPreAll   	:= {}
	Local aForLoj   	:= GFEA055GFL(GW6->GW6_EMIFAT)
	Local oModelGW7 	:= oModel:GetModel("GFEA070_GW7")
	Local oModelGWJ 	:= oModel:GetModel("GFEA070_GWJ")
	Local nI
	Local lErro     	:= .F.
	Local nOperacao 	:= 3
	Local aErro 		:= {}
	Local nX 			:= 0
	Local oRetPE		// Retorno do ponto de entrada
	Local nTamFat   	:= Len(AllTrim(GW6->GW6_NRFAT))
	Local nTamE2Num 	:= TamSx3("E2_NUM")[1]
	Local nTamSer   	:= Len(AllTrim(GW6->GW6_SERFAT))
	Local nTamE2Ser 	:= TamSx3("E2_PREFIXO")[1]
	Local nPercent 		:= 0
	Local nAcPercent	:= 0
	Local nVLDESC 		:= 0
	Local nDINDEN   	:= 0
	Local cFilAtu 		:= ""
	Local lPE70A6	 	:= ExistBlock("GFEA70A6")
	Local nY			:= 0
	Local nMsgFatAtuFin := 0

	Default cMsg 	    := ""
	Default cParData    := SuperGetMV('MV_DSDTAP',,'1') // Parametro Int Origem Data de Integração

	Private cRotinaInt  := "Fatura de Frete - Atualizar Financeiro ERP"
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.
	Private aParamValue	:= {}

	ParInt70()

	IF lPE70A6
		nMsgFatAtuFin := ExecBlock("GFEA70A6",.F.,.F.)
	Endif

	If Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	If SuperGetMV("MV_ERPGFE",.F.,'2') == '2' .And. nTamFat > nTamE2Num
		cMsg := "Incompatibilidade entre quantidade de dígitos da fatura ("+AllTrim(Str(nTamFat))+") e tamanho do campo Número do Título ("+AllTrim(Str(nTamE2Num))+") no Protheus." + CRLF
		cMsg += "Sugestão: Ajuste o tamanho do campo Número do Título (E2_NUM) ou altere a fatura para uma numeração aceitável no Protheus."
		lErro := .T.
	EndIf

	If SuperGetMV("MV_ERPGFE",.F.,'2') == '2' .And. nTamSer > nTamE2Ser
		cMsg := "Incompatibilidade entre quantidade de dígitos da série da fatura ("+AllTrim(Str(nTamSer))+") e tamanho do campo Série ("+AllTrim(Str(nTamE2Ser))+") no Protheus." + CRLF
		cMsg += "Sugestão: Ajuste o tamanho do campo Série (E2_PREFIXO) ou altere a fatura para uma numeração aceitável no Protheus."
		lErro := .T.
	EndIf

	If GFXCP12118("GW6_DINDEN")
		nDINDEN := GW6->GW6_DINDEN
	EndIf

	If !lErro
		aForLoj[2] := IIF( Empty(aForLoj[2]),"01",aForLoj[2] )
		nVLDESC := GW6->GW6_VLDESC + nDINDEN

		//Dados da Fatura
		aFatura := {  {"E2_PREFIXO" , Pad(GW6->GW6_SERFAT, TamSx3("E2_PREFIXO")[1])								, Nil },;
			{"E2_NUM"     , Pad(GW6->GW6_NRFAT , TamSx3("E2_NUM"    )[1])								, Nil },;
			{"E2_PARCELA" , Pad("1"            , TamSx3("E2_PARCELA")[1])								, Nil },;
			{"E2_TIPO"    , Pad("FT"           , TamSx3("E2_TIPO"   )[1])								, Nil },;
			{"E2_NATUREZ" , iif(GFXCP12130("GW6_NATURE"),GW6->GW6_NATURE, SuperGetMv("MV_NTFGFE",,"")), Nil },;
			{"E2_EMISSAO" , GW6->GW6_DTEMIS    														, Nil },;
			{"E2_VENCTO"  , GW6->GW6_DTVENC    														, Nil },;
			{"E2_VENCREA" , DataValida(GW6->GW6_DTVENC, .T.)   										, Nil },;
			{"E2_VALOR"   , GW6->GW6_VLFATU    														, Nil },;
			{"E2_VLCRUZ"  , GW6->GW6_VLFATU    														, Nil },;
			{"E2_FORNECE" , aForLoj[1]         														, Nil },;
			{"E2_LOJA"    , aForLoj[2]         														, Nil },;
			{"E2_VALJUR"  , GW6->GW6_VLJURO    														, Nil },;
			{"E2_DECRESC" , nVLDESC			 														, Nil },;
			{"E2_ISS"     , GW6->GW6_VLISRE    														, Nil },;
			{"E2_IRRF"    , iif(GFXCP12130("GW6_VLIRRF"), GW6->GW6_VLIRRF, 0)							, Nil },;
			{"E2_ORIGEM"  , "TOTVSGFE"         														, Nil } }

		For nI := 1 to oModelGW7:Length()
			If nI != 1
				oModelGW7:GoLine( nI )
			EndIf

			If Empty(FWFldGet("GW7_CTACTB"))
				Exit
			EndIf

			If nI == 1
				Aadd(aFatura, {"E2_RATEIO", "S", Nil} )
			EndIf

			If FWFldGet("GW7_LANCTO") != "1"
				loop
			Endif

			If nI == oModelGW7:Length()
				nPercent := 100 - nAcPercent
			Else
				nPercent := (100 * FWFldGet("GW7_VLMOV")) / GW6->GW6_VLFATU
				nAcPercent += nPercent
			EndIf

			//Dados dos Rateios
			aRatCont := { {"CTJ_DEBITO", FWFldGet("GW7_CTACTB") , Nil },;
				{"CTJ_CCD"   , FWFldGet("GW7_CCUSTO") , Nil },;
				{"CTJ_PERCEN", nPercent 				, Nil },;
				{"CTJ_VALOR" , FWFldGet("GW7_VLMOV") 	, Nil } }

			Aadd(aRatAll, aRatCont)
		Next

		For nI := 1 to oModelGWJ:Length()
			If nI != 1
				oModelGWJ:GoLine( nI )
			EndIf

			If Empty(FWFldGet("GWJ_NRPF"))
				Exit
			EndIf

			//Dados das Pré-Faturas
			aPreFat := { {"E2_PREFIXO"  , Space( (TamSX3("E2_PREFIXO")[1]) )                                                                 , Nil},;
				{"E2_NUM"     , AllTrim(FWFldGet("GWJ_NRPF"))+Space( (TamSX3("E2_NUM")[1])-(Len( AllTrim(FWFldGet("GWJ_NRPF")) )) ) , Nil},;
				{"E2_PARCELA" , AllTrim("1")+Space( (TamSX3("E2_PARCELA")[1])-(Len( AllTrim("1") )) )                               , Nil },;
				{"E2_TIPO"    , AllTrim("PR")+Space( (TamSX3("E2_TIPO")[1])-(Len( AllTrim("PR") )) )                                , Nil },;
				{"E2_FORNECE" , GFEA055GFL(oModelGWJ:GetValue("GWJ_CDTRP"))[1]                                                                                          , Nil },;
				{"E2_LOJA"    , GFEA055GFL(oModelGWJ:GetValue("GWJ_CDTRP"))[2]                                                                                          , Nil } }

			Aadd(aPreAll, aPreFat)
			nOperacao := 6
		Next

		// Ponto de entrada para customizar os dados de integração
		If ExistBlock("GFE070IN")
			oRetPE    := ExecBlock("GFE070IN",.f.,.f.,{aFatura, aRatAll, aPreAll, nOperacao})
			aFatura   := oRetPE[1]
			aRatAll   := oRetPE[2]
			aPreAll   := oRetPE[3]
			nOperacao := oRetPE[4]
		EndIf

		_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus

		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
		AddToLog('Atualização' + CRLF)
		AddToLog("Rotina Da Integração: GFEA070" + CRLF)
		AddToLog(cRotinaInt + CRLF + CRLF)
		AddToLog("--------------------------------------------------------"+ CRLF)
		AddToLog("Parâmetros da Integração" + CRLF)
		For nX := 1 To Len(aParamValue[1])
			AddToLog(aParamValue[1][nx,1] + aParamValue[1][nx,2] + CRLF)
		Next nX
		AddToLog("--------------------------------------------------------"+ CRLF)

		AddToLog('Fatura' + CRLF)

		For nX := 1 To Len(aFatura)
			AddToLog(aFatura[nx,1] + " - " + cValToChar(aFatura[nx,2]) + CRLF)
		Next nX
		AddToLog("--------------------------------------------------------"+ CRLF)

		If !Empty(aRatAll)
			AddToLog(CRLF + 'Rateio' + CRLF)

			For nY := 1 To Len(aRatAll)
				If nY > 1
					AddToLog("--------------------------------------------------------"+ CRLF)
				EndIf

				For nX := 1 To Len(aRatAll[nY])
					AddToLog(aRatAll[nY,nX,1] + " - " + cValToChar(aRatAll[nY,nX,2]) + CRLF)
				Next nX
			Next nY
		EndIf

		If !Empty(aPreAll)
			AddToLog(CRLF + 'Pré-Fatura' + CRLF)

			For nY := 1 To Len(aPreAll)
				If nY > 1
					AddToLog('------------------------------------------' + CRLF)
				EndIf

				For nX := 1 To Len(aPreAll[nY])
					AddToLog(aPreAll[nY,nX,1] + " - " + cValToChar(aPreAll[nY,nX,2]) + CRLF)
				Next nX
			Next nY
		EndIf

		//Utilizado para que não seja atribuida a filial do usuário logado
		// dentro do módulo de compras
		cFilAtu := cFilAnt
		IF FWModeAccess("GW6", 1) == "E"
			cFilAnt := GW6->GW6_FILIAL
			If GFXCP12137('GW6_FILTOM') .AND. !Empty(GW6->GW6_FILTOM)
				cFilAnt := GW6->GW6_FILTOM
			EndIf
		EndIf

		//Execução da operação de inclusão no FINA050
		//3 - Inclusão
		//6 - Substituição (Caso a Fatura possua Pré-Faturas)
		MsExecAuto({ |a,b,c,d| FINA050(a,,b,,,,,c,d)}, aFatura,nOperacao,aRatAll,aPreAll )
		If lMsErroAuto
			aErro := GetAutoGrLog()
			cMsg  := ""

			For nX := 1 To Len(aErro)
				cMsg += aErro[nX] + CRLF
			Next nX

			lErro := .T.

			AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
			AddToLog(cMsg + CRLF)
		Else
			//Manipular fatura após Atualização no Financeiro - Estornar Títulos
			If ExistBlock("GFEA0704")
				ExecBlock("GFEA0704",.F.,.F.,{})
			EndIf

			AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
		EndIf

		cFilAnt := cFilAtu
		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "
	EndIf

	// Somente apresenta as mensagens se configurado para 1 = Exibir todas ou 1 = Somente Erro
	If nMsgFatAtuFin <> 2
		If lErro
			// Apresenta mensagem de erro se não foi chamado pelos programas GFEA097, GFEA095 e configurado para 1 = Exibir todas ou 1 = Somente Erro
			If !IsInCallStack("GFEA097") .And. !IsInCallStack("GFEA095") .And. nMsgFatAtuFin <= 1
				MsgInfo("Fatura não enviada para atualização. Verificar motivo no campo 'Mot Rej Fin'.")
			EndIf
		ElseIf nMsgFatAtuFin == 0
			If !IsInCallStack("GFEA097") .And. !IsInCallStack("GFEA095")
				MsgInfo("Fatura atualizada no Financeiro.")
			EndIf
		EndIf
	EndIf

Return !lErro

//-----------------------------------------------------
/*/	Atualização do documento de frete no Protheus
	@author Felipe Machado de Oliveira
	@version P11
	@since 30/05/2013
/*/
//------------------------------------------------------
Function DesAtuFatura()
	Local lRet 	 	 := .T.
	Local aFatura 	 := {}
	Local aForLoj 	 := GFEA055GFL(GW6->GW6_EMIFAT)
	Local aErro 	 := {}
	Local nX 		 := 0
	Local aFaturaRet := {}
	Local cFilAtu	 := ""
	Local cMsg       := ""
	Local lIntGFE	 := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2	 := SuperGetMv("MV_INTGFE2",.F.,"2")

	Private cRotinaInt := "Fatura de Frete - Desatualiz Financeiro ERP"
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private _oGFEXFBFL 	   := GFEXFBFLog():New()
	Private aParamValue	   := {}

	_oGFEXFBFL:setSaveLog(__lLogIntP)
	_oGFEXFBFL:setAgrFrt(GW6->GW6_NRFAT)

	ParInt70()

	If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
		cMsg := "Verifique se os seguintes parâmetros estão ativos: MV_INTGFE, MV_INTGFE2, MV_ERPGFE"
		lRet := .F.
	EndIf

	If lRet .And. Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lRet := .F.
	EndIf

	If lRet
		aForLoj[2] := IIF( Empty(aForLoj[2]),"01",aForLoj[2] )

		//Dados da Fatura
		aFatura := {{"E2_PREFIXO" , Pad( GW6->GW6_SERFAT , TamSx3("E2_PREFIXO")[1] ) 										, Nil },;
			{"E2_NUM"     , AllTrim(GW6->GW6_NRFAT)+Space( (TamSX3("E2_NUM")[1])-(Len( AllTrim(GW6->GW6_NRFAT) )) ) , Nil },;
			{"E2_PARCELA" , AllTrim("1")+Space( (TamSX3("E2_PARCELA")[1])-(Len( AllTrim("1") )) )                   , Nil },;
			{"E2_TIPO"    , AllTrim("FT")+Space( (TamSX3("E2_TIPO")[1])-(Len( AllTrim("FT") )) )                    , Nil },;
			{"E2_FORNECE" , aForLoj[1] 																				, Nil },;
			{"E2_LOJA"    , aForLoj[2] 																				, Nil } }

		//Ponto de entrada Polenghi
		If ExistBlock("GFEA0705")
			aFaturaRet := ExecBlock("GFEA0705",.f.,.f.,{aFatura})
			aFatura := aFaturaRet
		EndIf

		_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus

		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
		AddToLog('Desatualização' + CRLF)
		AddToLog("Rotina Da Integração: GFEA070" + CRLF)
		AddToLog(cRotinaInt + CRLF + CRLF)
		AddToLog("--------------------------------------------------------"+ CRLF)
		AddToLog("Parâmetros da Integração" + CRLF)
		For nX := 1 To Len(aParamValue[1])
			AddToLog(aParamValue[1][nx,1] + aParamValue[1][nx,2] + CRLF)
		Next nX
		AddToLog("--------------------------------------------------------"+ CRLF)

		AddToLog('Fatura' + CRLF)

		For nX := 1 To Len(aFatura)
			AddToLog(aFatura[nx,1] + " - " + cValToChar(aFatura[nx,2]) + CRLF)
		Next nX
		AddToLog("--------------------------------------------------------"+ CRLF)

		//Utilizado para que não seja atribuida a filial do usuário logado
		// dentro do módulo de compras
		cFilAtu := cFilAnt
		IF FWModeAccess("GW6", 1) == "E"
			cFilAnt := GW6->GW6_FILIAL
			If GFXCP12137('GW6_FILTOM') .AND. !Empty(GW6->GW6_FILTOM)
				cFilAnt := GW6->GW6_FILTOM
			Endif
		ENDIF

		//Execução da operação de exclusão no FINA050
		MsExecAuto({ |a,b| FINA050(a,,b)}, aFatura,5, )
		If lMsErroAuto
			aErro := GetAutoGrLog()
			cMsg  := ""

			For nX := 1 To Len(aErro)
				cMsg += aErro[nX] + CRLF
			Next nX

			lRet := .F.

			AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
			AddToLog(cMsg + CRLF)
		Else
			AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
		EndIf
		cFilAnt := cFilAtu
		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "
	EndIf

	_oGFEXFBFL:SaveLog()

Return {lRet, cMsg}

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE070COPY
Rotina que executa a view quando for cópia da fatura

@sample
GFE61ACOPY()

@author Ana Claudia da Silva
@since 16/06/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFE070COPY()

	lCopy := .T.

	FWExecView("Copiar","GFEA070",9,,{|| .T.}) //"Copiar"

Return  

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GF70_GW6ACT
Muda os valores dos campos para a copia

@sample
GFE61ACOPY()

@author Ana Claudia da Silva
@since 16/06/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function GF70_GW6ACT(oModel)
	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:SetValue( 'GFEA070_GW6', 'GW6_DTCRIA', dDataBase )
	EndIf

	//Se for chamado pela integração, não efetua as validações.
	If IsInCallStack("GFEA070") .And. lCopy
		oModel:SetValue( 'GFEA070_GW6', 'GW6_SITAPR', "1") //Sit. Aprov. 1=Recebida;2=Bloqueada;3=Aprovada Sistema;4=Aprovada Usuario
		oModel:SetValue( 'GFEA070_GW6', 'GW6_EMIFAT', GW6->GW6_EMIFAT )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_DTCRIA', dDataBase )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_DTVENC',   StoD("  \  \    ") )

		//Inf Bloqueio
		oModel:SetValue( 'GFEA070_GW6', 'GW6_OBS',  " " )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_DTBLOQ',  StoD("  \  \    ") )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_HRBLOQ',  " " )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_USUBLO',  " " )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_MOTBLO',  " " )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_MOTDES',  " " )

		oModel:SetValue( 'GFEA070_GW6', 'GW6_SITFIN',  "1" )	 // Sit. Financ. 1=Nao Enviada;2=Pendente;3=Rejeitada;4=Atualizada;5=Pendente Desatualizacao	
		oModel:SetValue( 'GFEA070_GW6', 'GW6_MOTFIN',  " " )						
		oModel:SetValue( 'GFEA070_GW6', 'GW6_DTFIN',  StoD("  \  \    ") )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_HRFIN',  "  " )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_USUFIN',  " " )
		If GFXCP12127("GW6_DTLIQD")
			oModel:SetValue( 'GFEA070_GW6', 'GW6_DTLIQD',  StoD("  \  \    ") )		
		EndIf

		oModel:SetValue( 'GFEA070_GW6', 'GW6_DTAPR',  StoD("  \  \    ") )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_HRAPR',  "  " )
		oModel:SetValue( 'GFEA070_GW6', 'GW6_USUAPR',  " " )
							
		lCopy := .F.	
	EndIf

Return Nil

//--------------------------------------------------------------
/*/{Protheus.doc} GFEA070DMA
Dasatualização da Fatura no MLA
@author felipe.m
@since 11/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------
Function GFEA070DMA()
	Local lRet := .T.
	Local nRecnoGW6 := GW6->(Recno())
	
	If !(GW6->GW6_SITMLA $ "3|4|7") // 3=Rejeitado ou 4=Atualizado ou 7-Enviado/aguardando.
		Help(,,'HELP',,"Fatura ainda não foi integrada ao MLA.",1,0)
		lRet := .F.
	EndIf
	
	If lRet .And. MsgNoYes("Deseja desatualizar a Fatura no MLA?", "Aviso")
		GW6->(dbGoto(nRecnoGW6))
		RecLock("GW6",.F.)
		GW6->GW6_SITMLA := "5"
		MsUnlock("GW6")
		
		MsgInfo("Fatura enviada para desatualização no MLA.")
	EndIf
Return lRet

/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Integração de Mensagem Unica 
@author Estela Baratto
@since 04/10/2017
@version 1.000
@param cXml     : Xml definido de acordo com o XSD da mensagem de envio/recebimento.
@param nType    : numeric / Informa o tipo de Mensagem tratada: 0=Response;1=Envio;
@param cTypeMsg : Informa qual o tipo de mensagem que será processada se é uma: Business Message, Receipt Message, WhoIs Message 
@type function
=========================================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMsg)
	Local  aResult := {}

	aResult := GFEI070(cXml,nType,cTypeMsg)
Return aResult

/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Desconto Indenizatório para receber o valor total de indenizações relacionadas à Fatura de Frete
@author Administração de Frete
@since 26/03/2018
@version 1.000
=========================================================================================================
*/
Function GFEA070IND()
	Local aDocs		:= {}
	Local nI	 	:= 0
	Local cTexto    := ""
	Local cOcorren	:= ""
	Local nValor 	:= 0
	Local nValor1	:= 0
	Local nDescTot 	:= 0
	Local lretDesc 	:= .T.
	Local s_GFEIND  := SuperGetMV('MV_GFEIND',,'0')
	Local s_GFEDCFA := SuperGetMV("MV_GFEDCFA", .F., "2")

	Default nValor 	:= 0

	If s_GFEIND == "1"
		GW3->( dbSetOrder(8) )
		GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
		While !GW3->( Eof() ) .And. GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA) == ;
				GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)
			GW4->(dbSetOrder(1) )
			If GW4->(dbSeek(GW3->(GW3_FILIAL+GW3_EMISDF+GW3_CDESP+GW3_SERDF+GW3_NRDF)))
				While !Eof() .And. GW4->GW4_FILIAL + GW4->GW4_CDESP + GW4->GW4_EMISDF + GW4->GW4_SERDF + GW4->GW4_NRDF + DtoS(GW4->GW4_DTEMIS) == GW3->GW3_FILIAL + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF + DToS(GW3->GW3_DTEMIS)

					GW1->( dbSetOrder(1) )
					GW1->( dbSeek(GW4->GW4_FILIAL + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC) )
					While !GW1->( Eof() ) .And. GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC == GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC

						GWL->( dbSetOrder(5) )
						If GWL->( dbSeek(xFilial("GWL") + GW1->GW1_EMISDC + GW1->GW1_CDTPDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
							GWD->( dbSetOrder(1) )
							If GWD->( dbSeek(GWL->GWL_FILIAL + GWL->GWL_NROCO) )
								If (GWL->GWL_NROCO != cOcorren .or. cOcorren == "0") .and. GWD->GWD_VALIND > 0
									nValor1 := nValor
									nValor := GWD->GWD_VALIND + nValor1
									cOcorren := GWL->GWL_NROCO
								EndIf
								If GWD->GWD_VALIND > 0
									AAdd(aDocs, {"/ " + GW1->GW1_SERDC + GW1->GW1_NRDC +  "- R$  " + Alltrim(STR(GWD->GWD_VALIND)), .T.})
								EndIf
							EndIf
						EndIf
						GW1->( dbSkip() )
					EndDo
					GW4->( dbSkip() )
				EndDo
			EndIf
			GW3->( dbSkip() )
		EndDo
	Endif

	If GFXCP12127("GW3_VLDIV")

		GW3->( dbSetOrder(8) )
		GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
		While !GW3->( Eof() ) .And. GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA) == ;
				GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)

			// Compensação Divergência
			if GW3->GW3_VLDIV > 0
				If GW3->GW3_SIT == '2' // Documento bloqueado, utiliza a opção do parâmetro

					If s_GFEDCFA == '1'
						nValor += GW3->GW3_VLDIV
						AAdd(aDocs, {"/ " + GW3->GW3_SERDF + GW3->GW3_NRDF +  "- R$  " + Alltrim(STR(GW3->GW3_VLDIV)), .T.})
					Endif
				Else // Documento aprovado, verifica se deve ser realizada a compensação
					If GW3->GW3_SITDIV == '1'
						nValor += GW3->GW3_VLDIV
						AAdd(aDocs, {"/ " + GW3->GW3_SERDF + GW3->GW3_NRDF +  "- R$  " + Alltrim(STR(GW3->GW3_VLDIV)), .T.})
					Endif
				Endif
			Endif

			GW3->( dbSkip() )
		EndDo
	Endif

	cTexto += "Desconto indenizatório de R$ " + Alltrim(STR(nValor))  + " referente aos seguintes documentos:" + CRLF

	For nI := 1 To Len(aDocs)
		cTexto += STRZERO(nI, 3, 0)
		cTexto += AllTrim(aDocs[nI][1]) + CRLF
	Next nI

	nDescTot := nValor + GW6->GW6_VLDESC
	If 	nDescTot >= GW6->GW6_VLFATU
		Help( ,, 'HELP',, 'Verifique o total de descontos R$ '+ Alltrim(STR(nDescTot))  + ', pois é maior que o valor Fatura R$ ' + Alltrim(STR(GW6->GW6_VLFATU)) + '.', 1, 0,)
		cTexto += 'Total de descontos R$ '+ Alltrim(STR(nDescTot))  + ' maior que o valor Fatura R$ ' + Alltrim(STR(GW6->GW6_VLFATU)) + '.'  + CRLF
		lretDesc := .F.
	EndIF

	RecLock("GW6", .F.)
	GW6->GW6_DINDEN := nValor
	If nValor > 0
		GW6->GW6_OBS := cTexto
	EndIF
	GW6->( MsUnlock() )

Return lretDesc

//--------------------------------------------------------------
/*/ {Protheus.doc} ValX2Unico
// Verifica a chave única pelo SX2
	@author Gabriela Lima
	@since 22/02/2019
/*/
//--------------------------------------------------------------
Function ValX2Unico()
	Local cUnico := ""

	If FwSX2Util():SeekX2File("GW6")
		If !Empty(FWX2Unico("GW6"))
			cUnico := FWX2Unico("GW6")
			If Alltrim(cUnico) == "GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+DTOS(GW6_DTEMIS)"
				MsDocument('GW6',GW6->(RecNo()), 2)
			Else
				Help( ,, "Atenção",, "Recomendamos a atualização da SX2.", 1, 0,,,,,,;
					{"Necessário alteração na chave única da tabela GW6 conforme abaixo:"+CRLF+CRLF+;
					"GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT"+CRLF+"+GW6_NRFAT+DTOS(GW6_DTEMIS)"})
				Return .F.
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} AddToLog
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
@author silvana.torres
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTexto, characters, descricao
@param nPosicao, numeric, descricao
@param lTime, logical, descricao
@type function
/*/
Static Function AddToLog(cTexto, nPosicao, lTime)
	Default lTime	:= .T.
	Default nPosicao := _LOG_END

	If !__lLogIntP
		Return
	EndIf

	_oGFEXFBFL:setPosicao(nPosicao)
	_oGFEXFBFL:setTime(lTime)
	_oGFEXFBFL:setSaveLog(__lLogIntP)
	_oGFEXFBFL:setTexto(cTexto)
Return NIL

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEVLDNAT
	Valida a natureza financeira selecionada

@Author	Jefferson Hita
@since	06/04/2020
/*/
//-----------------------------------------------------------------------------------------------------
Function GFEVldNat( )
	Local lRet     := .T.
	Local aAreaSED := SED->( GetArea() )
	Local cCampo   := iif(lAltFat, GW6->GW6_NATURE, M->GW6_NATURE)

	If !Empty( cCampo )
		SED->( DbSetOrder( 1 ) )
		If SED->( DbSeek( xFilial( "SED" ) + cCampo ) )
			If SED->ED_MSBLQL == "1"
				lRet	:= .F.
				Help(" ", 1, "NATBLOQ", , "Não é possivel selecionar uma natureza financeira que esteja bloqueada.", 1, 0,,,,,,{"Solicite o desbloqueio ao departamento responsável."} )
			EndIf
		Else
			lRet	:= .F.
			Help( " ", 1, "NATNAOENC",, "A natureza não foi encontrada!!", 1, 0,,,,,,{"Solicite a criação da Natureza Financeira informada ao departamento responsável."} )
		EndIf
	EndIf

	RestArea( aAreaSED )
Return lRet

Function FatCalcIRRF(oModel)
	Local nVlrFat     := 0
	Local nVlrIRRF    := 0
	Local nBaseIRRF   := 0
	Local nMV_ALQIRRF := SuperGetMv("MV_ALQIRRF", , 0)
	Local nMV_IRFPRED := SuperGetMv("MV_IRFPRED", , 0)
	Local nOp         := Nil
	Local cEmiFat	  := ""


	If !FWIsInCallStack("GFEA071")
		cEmiFat := oModel:GetValue("GFEA070_GW6","GW6_EMIFAT")
	Else
		cEmiFat := GW6->GW6_EMIFAT
	EndIf

	If GFXCP12130("GW6_VLIRRF")
		GU3->( DbSetOrder(1))
		GU3->( DbSeek(xFilial("GU3") + cEmiFat))
		If !FWIsInCallStack("GFEA071")
			nOp := oModel:GetOperation()
			If nOp == MODEL_OPERATION_INSERT
				nVlrFat := oModel:GetValue("GFEA070_GW6","GW6_VLFATU")
				If GU3->GU3_CATTRP == "3"
					nBaseIRRF := nVlrFat - (nVlrFat * (nMV_IRFPRED / 100))
					nVlrIRRF  := nBaseIRRF * (nMV_ALQIRRF / 100)
					// Faz a gravação do valor calculado no campo referente ao IRRF
					oModel:SetValue("GFEA070_GW6","GW6_VLIRRF", nVlrIRRF)
				EndIf
			EndIf

			If nOp == MODEL_OPERATION_UPDATE
				nVlrFat := oModel:GetValue("GFEA070_GW6","GW6_VLFATU")
				If  GU3->GU3_CATTRP == "3"
					nBaseIRRF := nVlrFat - (nVlrFat * (nMV_IRFPRED / 100))
					nVlrIRRF  := nBaseIRRF * (nMV_ALQIRRF / 100)

					// Faz a gravação do valor calculado no campo referente ao IRRF
					RecLock("GW6", .F.)
					GW6->GW6_VLIRRF := nVlrIRRF
					GW6->( MsUnLock() )
				EndIF
			EndIf

		Else
			// Bloco para calculo quando for aprovação de fatura
			If  GU3->GU3_CATTRP == "3"
				nBaseIRRF := GW6->GW6_VLFATU - (GW6->GW6_VLFATU * (nMV_IRFPRED / 100))
				nVlrIRRF  := nBaseIRRF * (nMV_ALQIRRF / 100)

				// Faz a gravação do valor calculado no campo referente ao IRRF
				RecLock("GW6", .F.)
				GW6->GW6_VLIRRF := nVlrIRRF
				GW6->( MsUnLock() )
			EndIf
		EndIf

	EndIf

Return .T.

Function GFEA070CMT(oModel)
	Local lRet 		 := .T.

	lRet := FWFormCommit(oModel, /*[ bBefore ]*/,/*[ bAfter ]*/, {|oModel| GFE70AFTERSTTS( oModel )},{|oModel| GFE70INTTS( oModel )}, /*[ bABeforeTTS ]*/, /*<bIntegEAI >*/)

Return lRet

Function GFE70INTTS(oModel)
	Local nOp 		 := oModel:GetOperation()
	Local cFilFat    := xFilial("GW6", IIf(!Empty(oModel:GetModel("GFEA070_GW6"):GetValue("GW6_FILIAL")),oModel:GetModel("GFEA070_GW6"):GetValue("GW6_FILIAL"),Nil) )

	If nOp == MODEL_OPERATION_INSERT

		If Alltrim(GW6->GW6_FILIAL) <> Alltrim(cFilFat)
			RecLock("GW6", .F.)
			GW6->GW6_FILIAL := cFilFat
			GW6->(MsUnlock())
		EndIf

	EndIf

Return .T.

Function GFE70AFTERSTTS(oModel)
	Local nOp 		 := oModel:GetOperation()
	Local cGw6Fil	 := oModel:GetModel("GFEA070_GW6"):GetValue("GW6_FILIAL")
	Local cGw6Emi	 := oModel:GetModel("GFEA070_GW6"):GetValue("GW6_EMIFAT")
	Local cGw6Ser	 := oModel:GetModel("GFEA070_GW6"):GetValue("GW6_SERFAT")
	Local cGw6Nr	 := oModel:GetModel("GFEA070_GW6"):GetValue("GW6_NRFAT")
	Local cGw6Dte	 := DTOS(oModel:GetModel("GFEA070_GW7"):GetValue("GW7_DTEMIS"))
	Local cAliasGWA  := ""

	If nOp == MODEL_OPERATION_INSERT

		cAliasGWA  := GetNextAlias()

		BeginSQL Alias cAliasGWA
			SELECT  R_E_C_N_O_ as RECNOGW7
			FROM %Table:GW7% GW7
			WHERE GW7.GW7_FILIAL = %Exp:cGw6Fil%
			AND GW7.GW7_EMIFAT = %Exp:cGw6Emi%
			AND GW7.GW7_SERFAT = %Exp:cGw6Ser%
			AND GW7.GW7_NRFAT = %Exp:cGw6Nr%
			AND GW7.GW7_DTEMIS = %Exp:cGw6Dte%
			AND GW7.%NotDel%
		EndSQL

		While (cAliasGWA)->(!Eof() )
			GW7->(dbGoTo((cAliasGWA)->RECNOGW7))
			RecLock("GW7", .F.)
			GW7->GW7_FILIAL := xFilial("GW7")
			GW7->(MsUnlock())

			(cAliasGWA)->(dbSkip())
		EndDo

		(cAliasGWA)->( dbCloseArea() )
	EndIf
Return .T.

Function VldDesAtuFatura()
	Local lRet		:= .T.
	Local cRet		:= ""
	Local cERPGFE	:= SuperGetMV("MV_ERPGFE",,"1")
	Local cDSDTRE	:= SuperGetMV('MV_DSDTRE',,'1')
	Local cDSOFDT	:= SuperGetMv("MV_DSOFDT",,"1")

	If GW6->GW6_SITFIN != "4"
		cRet := "A Fatura deve estar atualizada no Financeiro para poder desatualizá-la." //"A Fatura deve estar atualizada no Financeiro"
		lRet := .F.
	EndIf

	If !Empty(GW6->GW6_DTFIN) .And. GW6->GW6_DTFIN <= SuperGetMv("MV_DTULFE",,"20000101")
		cRet := STR0032 + DToC(SuperGetMv("MV_DTULFE",,"20000101")) + STR0035 //"Data de transação deve ser posterior a data do último fechamento: " //" (Parâmetro MV_DTULFE)"
		lRet := .F.
	EndIf

	//Integração com Datasul
	If cERPGFE == "1"
		If FwIsInCallStack("GFEA070") .And. SuperGetMv("MV_FTMLA",.F.,"1") $ "2|3" .And. GW6->GW6_SITMLA != "4"
			cRet := "A Fatura deve estar aprovada no MLA para poder desatualizá-la." // "A Fatura deve estar aprovada no MLA para poder desatualizá-la."
			lRet := .F.
		EndIf

		//Verifica se existem documentos de frete atualizados no recebimento:
		GW3->(dbSetOrder(8))
		If GW3->(dbSeek(xFilial("GW3")+GW6->GW6_EMIFAT+GW6->GW6_SERFAT+GW6->GW6_NRFAT+DTOS(GW6->GW6_DTEMIS)))
			While !GW3->(EOF()) .AND. GW3->GW3_FILIAL == xFilial("GW3");
					.AND. GW3->GW3_EMIFAT == GW6->GW6_EMIFAT .AND. GW3->GW3_SERFAT == GW6->GW6_SERFAT;
					.AND. GW3->GW3_NRFAT == GW6->GW6_NRFAT .AND. GW3->GW3_DTEMFA == GW6->GW6_DTEMIS

				// Data integração recebimento |1=Data corrente 2=Data Criação 3=Informada Usuário 4=Financeiro
				If cDSDTRE == "4" .And. GW3->GW3_SITREC == "4"
					cRet := "Para desatualizar o financeiro é necessário que os documentos de frete sejam desatualizados no recebimento"
					lRet := .F.
				EndIf

				// Data transação documento Fiscal 1=Entrada 2=Financeira 3=Informada
				If cDSOFDT == "2" .And. GW3->GW3_SITFIS == "4"
					cRet := "Para desatualizar o financeiro é necessário que os documentos de frete sejam desatualizados no fiscal"
					lRet := .F.
				EndIf

				GW3->( dbSkip())
			EndDo
		EndIf
	EndIf

	// Início Ponto de Entrada Britania
	If ExistBlock("XGFEINTF")
		aRetorno := ExecBlock("XGFEINTF",.f.,.f.,{GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS})
		if aRetorno == .F.
			lRet := .F.
			cRet := "Impedida a desatualização da fatura através do Ponto de Entrada XGFEINTF"
		EndIf
	EndIf
	// Fim Ponto de Entrada Britania

Return {lRet, cRet}

Function ParInt70()
	Local lIntGFE	 := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2   := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cParData   := SuperGetMV('MV_DSDTAP',,'1') // Parametro Int Origem Data de Integração
	Local cParInt    := SuperGetMV('MV_GFEI16',,'1') //  Parametro Int Pré-fatura com Financeiro //PARAM INTEGRAÇÃO FATURA FINANCEIRO - AUTO OU NAO - PARAM PARA O GFEA070 - CONTEUDO - 1 - 2=AUTO
	Local cIntFisc   := SuperGetMv("MV_GFEI23",.F.,"2")
	Local cERPGFE    := SuperGetMv("MV_ERPGFE",.F.,"1")
	Local cIntGFEI13 := SuperGetMV('MV_GFEI13',,'1')
	Local cIntGFEI14 := SuperGetMV('MV_GFEI14',,'1')
	Local cParTES    := SuperGetMV('MV_TESGFE') // CONT PADRAO MV_TESGFE - 3 - ATRIBUIDO CFOP

	If Empty(cParData)
		cParData := "1"
	EndIf

	aadd(aParamValue, {;
		{"MV_INTGFE:  GFE Ativo - "                          ,cValToChar(lIntGFE)},;
		{"MV_INTGFE2: Modo de Integração - PROTHEUS/ GFE - "        ,cIntGFE2},;
		{"MV_DSDTAP:  Parametro Int Origem Data de Integração - " 	,cParData},;
		{"MV_GFEI16:  Parametro Int Pré-fatura com Financeiro  - " 	,cParInt},;
		{"MV_GFEI23:  Fiscal Pré-requisito para Atualizar Fatura com Financ. - ", cIntFisc},;
		{"MV_ERPGFE:  ERP Integrado - "								, cERPGFE},;
		{"MV_GFEI13:  Doc. Frete Fiscal - "  						,cIntGFEI13},;
		{"MV_GFEI14:  Doc. Frete Custo - " 							,cIntGFEI14},;
		{"MV_TESGFE:  TES Doc. Frete - "							,cParTES};
		})


Return aParamValue
