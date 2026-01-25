#INCLUDE "GFEA050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CPESO 1
#DEFINE CVAL  2
#DEFINE CVOL  3
#DEFINE CQTDE 4

// Códigos de mensagens padronizadas
#DEFINE GFEA050001 'GFEA050001'
#DEFINE GFEA050002 'GFEA050002'
#DEFINE GFEA050003 'GFEA050003'
#DEFINE GFEA050004 'GFEA050004'
#DEFINE GFEA050005 'GFEA050005'
#DEFINE GFEA050006 'GFEA050006'
#DEFINE GFEA050007 'GFEA050007'
#DEFINE GFEA050008 'GFEA050008'
#DEFINE GFEA050009 'GFEA050009'
#DEFINE GFEA050010 'GFEA050010'
#DEFINE GFEA050011 'GFEA050011'
#DEFINE GFEA050012 'GFEA050012'
#DEFINE GFEA050013 'GFEA050013'
#DEFINE GFEA050014 'GFEA050014'
#DEFINE GFEA050015 'GFEA050015'
#DEFINE GFEA050016 'GFEA050016'
#DEFINE GFEA050017 'GFEA050017'
#DEFINE GFEA050018 'GFEA050018'
#DEFINE GFEA050019 'GFEA050019'
#DEFINE GFEA050020 'GFEA050020'
#DEFINE GFEA050021 'GFEA050021'
#DEFINE GFEA050022 'GFEA050022'
#DEFINE GFEA050023 'GFEA050023'
#DEFINE GFEA050024 'GFEA050024'
#DEFINE GFEA050025 'GFEA050025'

// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
Static s_GFEI20_1 := SuperGetMV("MV_GFEI20",, '1')
Static s_GFEI20_2 := SuperGetMV('MV_GFEI20',,'2')
Static s_INTFRE   := SuperGetMV('MV_INTFRE',.F.,'1')
Static s_RENTNP   := SuperGetMV("MV_RENTNP",.F.,"1")
Static s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050
Cadastro de Romaneios
Generico.

@sample
GFEA050()

@author Equipe Frete Embarcador
@since 29/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA050()
	Local l050Leg  := ExistBlock("GFE50LEG")
	Private dData
	Private cHora
	Private oBrowse
	Private cParamF12 := 2 // Inicializado para não mostrar filtro antes de abrir a tela de doc. de carga
	Private lCopy     := .F.
	Private lExcluir  := .F.
	Private aRotina   := MenuDef()

	// Função para preenchimento de campo FILROM em caso de sem conteudo em registros antigos a melhoria - Remover posteriormente
	chkFilromaneio()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWN")                              // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA050")                        // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)                      // Descrição do browse //"Romaneios de Carga"
	oBrowse:AddLegend("GWN_SIT=='1'", "WHITE" , STR0036) //"Digitado"
	oBrowse:AddLegend("GWN_SIT=='2'", "BLUE", "Emitido") //"Emitido"
	oBrowse:AddLegend("GWN_SIT=='3'", "GREEN" , STR0038) //"Liberado"
	oBrowse:AddLegend("GWN_SIT=='4'", "RED"   , STR0039) //"Encerrado"

	If l050Leg
		ExecBlock("GFE50LEG",.F.,.F.)
	EndIf

	Pergunte("GFEA050F12",.F.)
	If !Empty(MV_PAR01)
		cParamF12 := MV_PAR01
		SetKey(VK_F12, {||ParamF12()})
	EndIf

	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
	Local aRotina   := {}
	Local aRotina2  := {} //Submenu

	Aadd(aRotina2, {"Incluir", "GFEA50REDP(1)", 0, 4 } )
	Aadd(aRotina2, {"Alterar/Excluir", "GFEA50REDP(2)", 0, 4 } )

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"                 						OPERATION  1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEC050"          						OPERATION  2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA050"          						OPERATION  3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "GFEA050ALT()"             						OPERATION  4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "GFEA050EXC()"             						OPERATION  5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0014 ACTION "GFEDOCCAR()"              						OPERATION 14 ACCESS 0 //"Doc. Carga"
	ADD OPTION aRotina TITLE STR0010 ACTION "GFE050CALC()"             						OPERATION 12 ACCESS 0 //"Calcular"
	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA050BLO()"             						OPERATION  9 ACCESS 0 //"Bloq./Desbloq."
	ADD OPTION aRotina TITLE STR0008 ACTION "GFEA050LIB(,,,,.T.)"      						OPERATION 10 ACCESS 0 //"Liberar"
	ADD OPTION aRotina TITLE STR0126 ACTION "GFEA050INF()"             						OPERATION 10 ACCESS 0 //"Inf. Rastr."
	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA050REA()"             						OPERATION 11 ACCESS 0 //"Reabrir"
	ADD OPTION aRotina TITLE STR0011 ACTION "GFEA050ENT()"             						OPERATION 13 ACCESS 0 //"Entrega"
	ADD OPTION aRotina TITLE STR0127 ACTION "GFEA050RET()"             						OPERATION 14 ACCESS 0 //"Retorno"
	ADD OPTION aRotina TITLE STR0045 ACTION "GFE050AJUS()"             						OPERATION 15 ACCESS 0 //"Ajuste"
	ADD OPTION aRotina TITLE STR0128 ACTION "GFE050PMAI()"             						OPERATION 15 ACCESS 0 //"Enviar xml nfe"
	ADD OPTION aRotina TITLE STR0129 ACTION aRotina2                   						OPERATION  4 ACCESS 0 //"Redespachantes"
	ADD OPTION aRotina TITLE STR0130 ACTION "GFE050PVIA()"             						OPERATION 16 ACCESS 0 //"Partida Viagem"
	ADD OPTION aRotina TITLE STR0012 ACTION "GFEA50COPY()"             						OPERATION 6  ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0013 ACTION "VIEWDEF.GFEA050"          						OPERATION 8  ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE STR0131 ACTION "GFE050COMB()"             						OPERATION 17 ACCESS 0 //"Combinar"
	ADD OPTION aRotina TITLE STR0132 ACTION "GFEA050E(GWN->GWN_NRROM)" 						OPERATION 16 ACCESS 0 //"Roteiro"
	ADD OPTION aRotina TITLE STR0133 ACTION "GFE050DESC()"             						OPERATION 18 ACCESS 0 //"Desfazer Combinado"
	ADD OPTION aRotina TITLE STR0134 ACTION "MsDocument('GWN',GWN->(RecNo()), 3)"         	OPERATION  4 ACCESS 0 //"Anexos"
	ADD OPTION aRotina TITLE STR0135 ACTION "GFEA50VCAL(GWN->GWN_FILIAL, GWN->GWN_NRROM)" 	OPERATION 20 ACCESS 0 //"Visualizar Cálculos"
	ADD OPTION aRotina TITLE STR0136 ACTION "GFEX201(GWN->GWN_FILIAL, GWN->GWN_NRROM)"    	OPERATION 21 ACCESS 0 //"Integração FreteBras"

	If ExistBlock("XGFEA050")
		aRotAdic := ExecBlock("XGFEA050 ",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf
Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF---------------------------//
//-------------------------------------------------------------------//

Static Function ModelDef()
	Local oModel
	Local oStructGWN := FWFormStruct(1,"GWN")
	Local aAux

	aAux := FwStruTrigger('GWN_VIAGEM'     ,; // Campo de Dominio (tem que existir no Model)
	'GWN_VIAGEM'   ,; // Campo de ContraDominio (tem que existir no Model)
	'GFEA050PVG()' ,; // Regra de Preenchimento
	,;                // Se posicionara ou não antes da execução do gatilhos (Opcional)
	,;                // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
	,;                // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
	,;                // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
	)                 // Condição para execução do gatilho (Opcional)

	//  aAux tem o conteudo
	// [01] Id do campo de origem
	// [02] Id do campo de destino
	// [03] Bloco de codigo de validação da execução do gatilho
	// [04] Bloco de codigo de execução do gatilho
	oStructGWN:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	// cID     IdentIficador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA050", /*bPre*/, { |oX| GFEA050POS( oX ) } /*bPost*/, {|oX| GFEA50CMT(oX)}/*bCommit*/, /*bCancel*/)
	// cId          IdentIficador do modelo
	// cOwner       IdentIficador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA050_GWN", Nil, oStructGWN,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GWN_FILIAL", "GWN_NRROM"})
	oModel:SetActivate({|oMod| GFEA50ACT(oMod)})
	oModel:SetVldActivate({|oModel| GFEA50VLD(oModel)})
Return oModel

Function GFEA050PVG()
	Local nVal    := 0
	Local oMdlAct := FwModelActive()
	Local oVwAct  := FwViewActive()
	Local aQtdes  := {}
	Local cViagem := oMdlAct:GetModel("GFEA050_GWN"):GetValue("GWN_VIAGEM")

	oMdlAct:lModify := .T.
	If !Empty(cViagem)

		If oMdlAct:GetOperation() == MODEL_OPERATION_INSERT
			aQtdes := GFE58OUTCARGA('','',cViagem)
		Else
			aQtdes := GFE58OUTCARGA(GWN->GWN_FILIAL,GWN->GWN_NRROM,cViagem)
		EndIf

		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CPESO")
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CPESO", aQtdes[CPESO])
		EndIf

		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVAL" )
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVAL" , aQtdes[CVAL ])
		EndIf

		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVOL" )
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVOL" , aQtdes[CVOL ])
		EndIf

		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CQTDE")
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CQTDE", aQtdes[CQTDE])
		EndIf

		nVal := aQtdes[CPESO]
	Else
		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CPESO")
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CPESO", 0)
		EndIf
		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVAL" )
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVAL" , 0)
		EndIf
		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CVOL" )
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CVOL" , 0)
		EndIf
		If oMdlAct:GetModel("GFEA050_GWN"):HasField("GWN_CQTDE")
			oMdlAct:GetModel("GFEA050_GWN"):LoadValue("GWN_CQTDE", 0)
		EndIf
	EndIf

	If oVwAct != Nil .AND. oVwAct:LACTIVATE
		oVwAct:lModify := .T.
		oVwAct:Refresh()
	EndIf
Return cViagem

//-------------------------------------------
//Função para validar a manipulação do model
//-------------------------------------------

Function GFEA50VLD(oModel)
	Local lRet := .T.
	Local nOp  := oModel:GetOperation()

	If (nOp == MODEL_OPERATION_UPDATE .OR. nOp == MODEL_OPERATION_DELETE)
		If GWN->GWN_SIT == "3"
			lRet := .F.
			GFEMessage(5, GFEA050011, STR0154, STR0155)	// "O Romaneio está liberado, portanto, não poderá ser alterado nem excluído.", "Reabra o Romaneio para permitir alterações ou exclusões."
		ElseIf GWN->GWN_SIT == "4"
			lRet := .F.
			GFEMessage(5, GFEA050012, STR0156, STR0155) // "O Romaneio está encerrado, portando não poderá ser alterado nem excluído.", "Reabra o Romaneio para permitir alterações ou exclusões."
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//

Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEA050")
	Local oView      := Nil
	Local oStructGWN := FWFormStruct(2,"GWN")
	Local nI         := 0
	Local nF         := 0
	Local aRetPE     := {}
	Default lExcluir := .F.

	oStructGWN:AddGroup("GrpId" , "Identificação"        , "", 2) // "Identificação"
	oStructGWN:AddGroup("GrpClc", "Cálculo de Frete"     , "", 2) // "Cálculo de Frete"
	oStructGWN:AddGroup("GrpMot", "Motoristas e Veículos", "", 2) // "Motoristas e Veículos"
	oStructGWN:AddGroup("GrpVig", "Viagem"               , "", 2) // "Viagem"
	oStructGWN:AddGroup("GrpViag","Consolidação de carga", "", 2) // "Consolidação de carga"
	oStructGWN:AddGroup("GrpObs", "Observações"          , "", 2) // "Observações"
	oStructGWN:AddGroup("GrpRea", "Reabertura"           , "", 2) // "Reabertura"
	oStructGWN:AddGroup("GrpCtr", "Controle"             , "", 2) // "Controle"

	oStructGWN:SetProperty("GWN_NRROM", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWN:SetProperty("GWN_CDTRP", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWN:SetProperty("GWN_DSTRP", MVC_VIEW_GROUP_NUMBER, "GrpId")

	If oStructGWN:HasField("GWN_TOTALT")
		// Mostra os campos totalizadores somente se for configurado como browse
		If GetSx3Cache("GWN_TOTVOL","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTVOL")
		EndIf
		If GetSx3Cache("GWN_TOTPER","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTPER")
		EndIf
		If GetSx3Cache("GWN_TOTPEC","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTPEC")
		EndIf
		If GetSx3Cache("GWN_TQTVOL","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TQTVOL")
		EndIf
		If GetSx3Cache("GWN_TOTALT","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTALT")
		EndIf
	EndIf

	If oStructGWN:HasField("GWN_VIAGEM")
		oStructGWN:SetProperty("GWN_VIAGEM", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf

	If oStructGWN:HasField("GWN_CPESO")
		oStructGWN:SetProperty("GWN_CPESO", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf

	If oStructGWN:HasField("GWN_CVOL")
		oStructGWN:SetProperty("GWN_CVOL", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf

	If oStructGWN:HasField("GWN_CVAL")
		oStructGWN:SetProperty("GWN_CVAL", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf

	If oStructGWN:HasField("GWN_CQTDE")
		oStructGWN:SetProperty("GWN_CQTDE", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf

	oStructGWN:SetProperty("GWN_CDTPOP", MVC_VIEW_GROUP_NUMBER, "GrpClc")
	oStructGWN:SetProperty("GWN_CDCLFR", MVC_VIEW_GROUP_NUMBER, "GrpClc")
	oStructGWN:SetProperty("GWN_DSCLFR", MVC_VIEW_GROUP_NUMBER, "GrpClc")
	oStructGWN:SetProperty("GWN_CDTPVC", MVC_VIEW_GROUP_NUMBER, "GrpClc")

	oStructGWN:SetProperty("GWN_CDMTR" , MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_NMMTR" , MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_CDMTR2", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_NMMTR2", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_PLACAD", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_PLACAM", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_PLACAT", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_LACRE",  MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_NRCIDD", MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_NMCIDD", MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_CEPD"  , MVC_VIEW_GROUP_NUMBER, "GrpVig")
	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_NRCIDO"}) != 0
		oStructGWN:SetProperty("GWN_CEPO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_NRCIDO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_NMCIDO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
	EndIf
	oStructGWN:SetProperty("GWN_RASTR" , MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_PRIOR" , MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_DISTAN", MVC_VIEW_GROUP_NUMBER, "GrpVig")

	oStructGWN:SetProperty("GWN_DTIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_HRIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_DTSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_HRSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_CALC"  , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_MTCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_DTCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_HRCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	If GFXCP12117("GWN_ENVNFE") == .T.
		oStructGWN:SetProperty("GWN_ENVNFE", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf
	If GFXCP12117("GWN_MOTNFE") == .T.
		oStructGWN:SetProperty("GWN_MOTNFE", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf

	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_VPVAL"}) != 0
		oStructGWN:SetProperty("GWN_VPVAL", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VPNUM", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VPCDOP", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VPNMOP", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VALEP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf

	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_AGRUP"}) != 0
		oStructGWN:SetProperty("GWN_AGRUP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf

	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_DSREAL"}) != 0
		oStructGWN:SetProperty("GWN_HODRET", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_HODSAI", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_DSREAL", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_DTRET", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
		oStructGWN:SetProperty("GWN_HRRET", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
		oStructGWN:SetProperty("GWN_FECHAM", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
		oStructGWN:SetProperty("GWN_DTFECH", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf

	oStructGWN:SetProperty("GWN_BLOQPF", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_ORI"   , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_USUIMP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")

	oStructGWN:SetProperty("GWN_OBS", MVC_VIEW_GROUP_NUMBER, "GrpObs")

	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_MOTREA"}) != 0
		oStructGWN:SetProperty("GWN_MOTREA", MVC_VIEW_GROUP_NUMBER, "GrpRea")
		oStructGWN:SetProperty("GWN_DTREAB", MVC_VIEW_GROUP_NUMBER, "GrpRea")
		oStructGWN:SetProperty("GWN_HRREAB", MVC_VIEW_GROUP_NUMBER, "GrpRea")
		oStructGWN:SetProperty("GWN_USUREA", MVC_VIEW_GROUP_NUMBER, "GrpRea")
	EndIf

	//PE para possibilitar posicionar campos customizados no agrupador "Viagem"
	//retorno deve ser um array no formato:
	//aRetPE[1] (Caracter) ID do Campo
	//aRetPE[2] (Numérico) Agrupamento do Campo
	If ExistBlock("GFE05012")
		aRetPE := ExecBlock('GFE05012',.F.,.F.)
		If ValType(aRetPE) == 'A' .AND. !Empty(aRetPE)
			nF := Len(aRetPE)
			For nI := 1 To nF
				If GFXCP12127(aRetPE[nI][1])
					oStructGWN:SetProperty(aRetPE[nI][1], aRetPE[nI][2], "GrpVig")
				EndIf
			Next nI
		EndIf
	EndIf

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA050_GWN" , oStructGWN, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

	oView:CreateHorizontalBox( "MASTER" , 100 )
	oView:SetOwnerView( "GFEA050_GWN" , "MASTER" )

	oView:AddUserButton('Pesquisar Negociações', 'MAGIC_BMP', {|oModel| GFE50VERNG(oModel)})
	oView:AddUserButton('Viagem/Consolidação', 'MAGIC_BMP', {|oModel| GFE50NVG()})

	If GFXCP12118("GWT_NRROM")
		If lExcluir = .T.
			oView:AddUserButton( STR0132, 'MAGIC_BMP', {|oModel| GFEA050E(GWN_NRROM,,2)} ) //"Roteiro"
		EndIf
	EndIf
	lExcluir := .F.
Return oView

/*
Integração Com OMS - Desabilita campos
X3_WHEN do campo GWN_CDTRP.
*/
Function GFEA050WCT()
Return Inclui .OR. SuperGetMV('MV_GFEI12',,'1') $ "2N" .OR. GWN->GWN_ORI $ "14"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEDOCCAR
Rotina para permitir ao usuário relacionar os documentos de carga ao romaneio
Uso Geral.

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEDOCCAR()
	Local lPedHD 	:= .F.
	
	Private aAuxDc 	:= {}

	//Ponto de entrada validação Vicunha
	If ExistBlock("GFEA0506")
		If ExecBlock("GFEA0506",.F.,.F.,{"1"})
			Return
		EndIf
	EndIf

	// Integração com OMS e registro de origem ERP
	If GFEERPOMS()
		GFEMessage(5, GFEA050013, STR0157, STR0158)	// "A integração com o SIGAOMS está ativada, esta operação deverá ser realizada naquele módulo", "Acesse o modulo SIGAOMS para realizar a operação."
		Return
	EndIf

	//Integração com o SIGATMS e registro de origem TMS
	If GFEINTTMS()
		GFEMessage(5, GFEA050014, STR0159, STR0160)	//"Não é permitido alterar a relação de Documentos de um Romaneio gerado pela integração com o SIGATMS.", "Acesse o modulo SIGATMS para efetuar alterações na relação de documentos com o Romaneio."
		Return
	EndIf

	If GWN->GWN_SIT == "3"
		GFEMessage(5,GFEA050015, STR0025, STR0155) // "Romaneio já foi liberado" / "Reabra o Romaneio para permitir alterações ou exclusões."
	ElseIf GWN->GWN_SIT == "4"
		GFEMessage(5, GFEA050016, STR0161, STR0162) // "Romaneio já foi encerrado." / "Realize o estorno de todo o processo para permitir manutenções no Romaneio."
	Else
		If ExistBlock("XAliMKB2")
			lPedHD := ExecBlock("XAliMKB2",.F.,.F.,nil)
		EndIf

		If IIf(lPedHD,GFEA050B(cParamF12),GFEA050A(cParamF12))  // 1-Romaneio Calculado

			If GWN->GWN_CALC != "2"
				RecLock("GWN", .F.)
				GWN->GWN_CALC := "4" // Romaneio necessita recálculo
				GWN->GWN_MTCALC := "Foram adicionados ou retirados Documentos de Carga relacionados ao Romaneio."
				GWN->GWN_DTCALC := CToD("  /  /    ")
				GWN->GWN_HRCALC := ""
				GWN->(MsUnLock())
			EndIf

			If !Empty(GWN->GWN_VIAGEM)
				GFE58ATVG(GWN->GWN_VIAGEM,'4',"Foram adicionados ou retirados Documentos de Carga relacionados ao Romaneio " + GWN->GWN_NRROM + ".",CToD("  /  /    "),'',GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
			EndIf
			If GWN->GWN_CALC != "2"
				// Verifica se há algum documento de carga vinculado ao romaneio
				If GFXCP1212210('GW1_FILROM')
					cAliasClc := GetNextAlias()
					BeginSql Alias cAliasClc
						SELECT R_E_C_N_O_ AS RECNUM
						FROM %Table:GW1% GW1
						WHERE GW1.GW1_FILROM = %Exp:GWN->GWN_FILIAL%
						AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
						AND GW1.%NotDel%
						ORDER BY GW1_FILIAL
					EndSql
					If (cAliasClc)->( !Eof() )
						If MsgYesNo(STR0046,STR0014)	// "Deseja recalcular este romaneio?" // "Doc. Carga"
							GW1->(dbGoto( (cAliasClc)->RECNUM) )
							GFE050CALC() // Recalcula o romaneio
						EndIf
					EndIf
					(cAliasClc)->( dbCloseArea() )
				Else
					GW1->( dbSetOrder(09) )
					If GW1->( dbSeek(xFilial("GW1")+GWN->GWN_NRROM) )
						If MsgYesNo(STR0046,STR0014)	// "Deseja recalcular este romaneio?" // "Doc. Carga"
							GFE050CALC() // Recalcula o romaneio
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		GFE50LbRom() // verifica e libera o romaneio posicionado
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEERPOMS
Verifica se há integração com OMS e se o registro tem origem ERP
Se ambos forem verdadeiro, retorna .T.
Esta função desabilita funcionalidades que deverão ser tratadas no módulo de OMS:
Vínculo de Documento de Carga, Eliminar o Romaneio ou Alterar a Transportadora

@author Israel Alcantara Possoli
@since 13/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEERPOMS()
Return SuperGetMV('MV_GFEI12',,'1') $ "1S" .AND. GWN->GWN_ORI == "2"
//-------------------------------------------------------------------
/*GFEINTTMS
Verifica se há integração com TMS e se o registro tem origem SIGATMS
Se ambos forem verdadeiro, retorna .T.
Esta função desabilita funcionalidades que deverão ser tratadas no módulo de SIGATMS:
Vínculo de Documento de Carga, Eliminar o Romaneio ou Alterar a Transportadora

@author Felipe mendes
@since 13/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEINTTMS()
Return SuperGetMv("MV_TMSGFE",.F.,.F.) .AND. GWN->GWN_ORI == "3"
//-------------------------------------------------------------------
/*GFEINT3TMS
Verifica se há integração com TMS e se o registro tem origem SIGATMS
Se ambos forem verdadeiro, retorna .T.
Esta função desabilita funcionalidades que deverão ser tratadas no módulo de SIGATMS:
Vínculo de Documento de Carga, Eliminar o Romaneio ou Alterar a Transportadora

@author 
@since 
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEINT3TMS()
Return SuperGetMv("MV_TMS3GFE",.F.,.F.) $ "F;S;C" .AND. GWN->GWN_ORI == "3"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050ALT
Rotina para chamar a alteração
Uso Geral.

@author Israel Alcantara Possoli
@since 13/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050ALT()
	Local lRet := .T.

	//Ponto de entrada validação Vicunha
	If ExistBlock("GFEA0506")
		If ExecBlock("GFEA0506",.F.,.F.,{"4"})
			lRet := .F.
		EndIf
	EndIf
	If lRet
		FWExecView("",'GFEA050',4,,{||.T.})
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050EXC
Rotina para chamar a exclusão
Uso Geral.

@author Israel Alcantara Possoli
@since 13/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050EXC()
	Local lRet := .T.

	// Integração com OMS e registro de origem ERP
	If GFEERPOMS()
		GFEMessage(5,GFEA050009,GFEMsgFmt(STR0149,{{"[VAR01]", "SIGAOMS"}}),GFEMsgFmt(STR0150,{{"[VAR01]", "SIGAOMS"}})) //"Operação não permitida, a integração com o módulo [VAR01] está ativada." , "Operação deverá ser realizada no módulo [VAR01]!"
		lRet := .F.
	EndIf

	//Integração com o SIGATMS e registro de origem TMS
	If GFEINTTMS()
		GFEMessage(5,GFEA050010,GFEMsgFmt(STR0149,{{"[VAR01]", "SIGATMS"}}),GFEMsgFmt(STR0150,{{"[VAR01]", "SIGATMS"}})) //"Operação não permitida, a integração com o módulo [VAR01] está ativada." , "Operação deverá ser realizada no módulo [VAR01]!"
		lRet := .F.
	EndIf
	
	If lRet
		//Ponto de entrada validação Vicunha
		If ExistBlock("GFEA0506")
			If ExecBlock("GFEA0506",.F.,.F.,{"3"})
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		lExcluir := .T. // Variável para criar grid de roteiro se for exclusão
		FWExecView("", 'GFEA050', MODEL_OPERATION_DELETE,, {|| .T.})
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050REA
Rotina para realizar a reabertura do romaneio
Uso Geral.

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050REA(lAuto)
	Local oDlg      := Nil
	Local aAreaGWF  := GWF->( GetArea() )
	Local aAreaGW1  := GW1->( GetArea() )
	Local aAreaGWH  := GWH->( GetArea() )
	Local aAreaGWJ  := GWJ->( GetArea() )
	Local lRet      := .T.
	Local aRetPE    := {}
	Local cAliasGWF := Nil
	Local cAliasGW1 := Nil
	Local cWhere    := Nil

	Default lAuto  := .F.

	Private cTexto1

	If GWN->GWN_SIT != "3"	// Liberado
		If !lAuto
			GFEMessage(5,GFEA050001,STR0017,STR0141) //"Romaneio não está liberado" , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
		EndIf

		lRet := .F.
	EndIf

	If lRet .And.GWN->GWN_AGRUP == "1"
		If !lAuto
			GFEMessage(5,GFEA050002,STR0142,STR0143) //"Romaneio possui um agrupamento de cálculos!" , "Para realizar a reabertura é necessário a exclusão deste cálculo no programa de Frete Combinado."
		EndIf

		lRet := .F.
	EndIf

	If lRet .And. GFEVerCmpo({"GWN_FECHAM"}) .AND. GWN->GWN_FECHAM == "3"
		If !lAuto
			GFEMessage(5,GFEA050003,STR0144,STR0141) //"Apuração do período de fechamento foi efetuada, portanto não é possível reabrir o Romaneio." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
		EndIf
		
		lRet := .F.
	EndIf

	If lRet .And. !Empty(GWN->GWN_VIAGEM)
		If PosicionaGWP()
			If GWP->GWP_SIT == '2'
				If !lAuto
					GFEMessage(5,GFEA050004,GFEMsgFmt(STR0145,{{"[VAR01]", GWP->GWP_VIAGEM}}),STR0141) //"Já ocorreu a partida da viagem [VAR01] que está relacionada, portanto não é possível reabrir o Romaneio." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
				EndIf
				
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

	//Ponto de entrada validação Vicunha
	If lRet .And. ExistBlock("GFEA0506")
		If ExecBlock("GFEA0506",.F.,.F.,{"2"})
			lRet := .F.
		EndIf
	EndIf

	// Validar se o romaneio possui cálculos vinculados a contrato com autônomo
	If lRet
		If GFXCP1212210('GW1_FILROM')
			cWhere := "GWF.GWF_FILROM = '" + GWN->GWN_FILIAL + "'"
		Else
			cWhere := "GWF.GWF_FILIAL = '" + GWN->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGWF := GetNextAlias()
		BeginSql Alias cAliasGWF
			SELECT GWF_FILPRE, GWF_NRPREF, GWF_NRCONT, GWF.R_E_C_N_O_ AS GWFRECNO
			FROM %table:GWF% GWF
			WHERE %Exp:cWhere%
			AND GWF.GWF_NRROM = %Exp:GWN->GWN_NRROM%
			AND GWF.%NotDel%
			ORDER BY GWF.GWF_FILIAL,GWF.GWF_NRCALC
		EndSql
		While !(cAliasGWF)->(Eof()) .And. lRet
			If !Empty((cAliasGWF)->GWF_NRCONT)
				If !lAuto
					GFEMessage(5,GFEA050005,STR0089,STR0141) //"Romaneio possui cálculos vinculados a contrato com autônomo e não pode ser reaberto." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
				EndIf

				lRet := .F.
			EndIf
			
			If lRet
				GWJ->( dbSetOrder(1) )
				If GWJ->( dbSeek((cAliasGWF)->GWF_FILPRE + (cAliasGWF)->GWF_NRPREF) ).AND. GWJ->GWJ_SIT <> "4"
					If !lAuto
						GFEMessage(5,GFEA050006,STR0103 + ". " + STR0020 + ".",STR0141) //"Romaneio possui pré-fatura "  , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
					EndIf

					lRet := .F.
				EndIf
			EndIf

			(cAliasGWF)->(dbSkip())
		EndDo	
		(cAliasGWF)->(dbCloseArea())
	EndIf
	
	If lRet
		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		While !(cAliasGW1)->(Eof()) .And. lRet
			GW4->( dbSetOrder(2) )
			If GW4->( dbSeek(xFilial("GW4") + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + (cAliasGW1)->GW1_CDTPDC) )
				If !lAuto
					GFEMessage(5,GFEA050008, STR0102,STR0141) //"O Romaneio possui documentos de frete relacionados aos seus documentos de carga, portanto, não poderá ser reaberto." , "Verifique o romaneio selecionado ou a ação escolhida para esse romaneio."
				EndIf
				
				lRet := .F.
			EndIf

			(cAliasGW1)->(dbSkip())
		EndDo	
		(cAliasGW1)->(dbCloseArea())
	EndIf
	
	//Ponto de entrada para validação adicional da reabertura do romaneio,
	//sendo que o retorno deve ser um array no seguinte formato:
	//aRetPE[1] (Lógico)    Verdadeiro ou falso (.T. ou .F.), resultado da validação do romaneio
	//aRetPE[2] (Caracter)  Mensagem de erro, caso o retorno do primeiro elemento do array seja falso
	If ExistBlock('GFEA0502')
		aRetPE := ExecBlock('GFEA0502',.F.,.F.)
		
		//Verifica se o retorno do ponto de entrada é válido
		If ValType(aRetPE) == 'A' .And. !Empty(aRetPE)
			If !aRetPE[1]
				GFEMsgErro(aRetPE[2])
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaGW1)
	RestArea(aAreaGWH)
	RestArea(aAreaGWF)
	RestArea(aAreaGWJ)

	If lRet
		If !lAuto .And. !GFEINT3TMS()
			DEFINE MSDIALOG oDlg TITLE STR0015 From 4,0 To 16,60 OF oMainWnd //"Reabrir Romaneio"
			@ 4, 006  SAY STR0016 SIZE 70,7 PIXEL OF oDlg //"Motivo da Reabertura:"
			// Usando o New
			oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTexto1:=u,cTexto1)},;
			oDlg,225,60,,,,,,.T.)

			oButtonOK   := tButton():New(75,5,'OK',oDlg,{|| If(GFEABTREA(),oDlg:End(),NIL)},25,10,,,,.T.)
			oButtonCanc := tButton():New(75,35,STR0112,oDlg,{||(oDlg:End())},25,10,,,,.T.) //"Cancelar"

			ACTIVATE MSDIALOG oDlg
		Else
			If IsInCallStack("GFEX101VAL")
				cTexto1:= STR0147 //"Reabertura automatica realizada pelo Processo de Liberação do Doc Carga Datasul."
				Processa({|| lRet:= GFEABTREA()})
			Else
				cTexto1:= STR0148 //"Reabertura automatica realizado pelo Modulo SIGATMS."
				Processa({|| lRet:= GFEABTREA()})
			EndIf
		EndIf
	EndIf

	//Ponto de entrada Vicunha
	If lRet .And. ExistBlock("GFEA0507")
		ExecBlock("GFEA0507",.F.,.F.)
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEABTREA
Rotina para fazer as validacoes da reabertura e gravar as informacoes na tabela

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEABTREA()
	Local nOpc      := 0
	Local lRet      := .T.
	Local cAliasGW1 := Nil
	Local cWhere    := Nil
	Local aAreaGW1  := GW1->( GetArea() )

	If !Empty(cTexto1)
		RecLock('GWN', nOpc == 4 )
		GWN->GWN_SIT := "1"
		GWN->GWN_DTSAI := STOD("  /  /  ")
		GWN->GWN_HRSAI := ""
		If GFEVerCmpo({"GWN_FECHAM"})
			GWN->GWN_DTRET := STOD("  /  /  ")
			GWN->GWN_HRRET := ""
			GWN->GWN_HODSAI := 0
			GWN->GWN_HODRET := 0
		EndIf
		If GFEVerCmpo({"GWN_MOTREA"})
			GWN->GWN_MOTREA := cTexto1
			GWN->GWN_DTREAB := dDatabase
			GWN->GWN_HRREAB := Time()
			GWN->GWN_USUREA := cUserName
		EndIf
		GWN->( MsUnLock() )

		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		While !(cAliasGW1)->(Eof())
			GW1->(dbGoTo( (cAliasGW1)->GW1RECNO ))

			RecLock('GW1', .F.)
			GW1->GW1_DTSAI := STOD("  /  /  ")
			GW1->GW1_HRSAI := ""
			If s_GFEI20_1 == '1'
				If GFEVerCmpo({"GW1_SITFT"})
					GW1->GW1_SITFT := "5"
				EndIf
			EndIf
			GW1->( MsUnLock() )

			//Limpa a data de previsão de entrega dos trechos
			GWU->( dbSetOrder(1) )
			GWU->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
			Do While GWU->(!Eof()) .And. GW1->GW1_FILIAL == GWU->GWU_FILIAL;
								   .And. GW1->GW1_CDTPDC == GWU->GWU_CDTPDC;
								   .And. GW1->GW1_EMISDC == GWU->GWU_EMISDC;
								   .And. GW1->GW1_SERDC == GWU->GWU_SERDC;
								   .And. GW1->GW1_NRDC == GWU->GWU_NRDC

				RecLock('GWU', .F.)
					GWU->GWU_DTPENT	:= STOD("  /  /  ")
					GWU->GWU_HRPENT	:= ""
				If GFXCP12137("GWU_DTPENO")	
					GWU->GWU_DTPENO := STOD("  /  /  ")
					GWU->GWU_HRPENO := ""
					GWU->GWU_QTPRAZ := 0
					GWU->GWU_TPPRAZ := ""
				EndIf
				GWU->( MsUnLock() )
				GWU->(dbSkip())
			EndDo

			(cAliasGW1)->(dbSkip())
		EndDo	
		(cAliasGW1)->(dbCloseArea())

	Else
		GFEMsgErro(STR0018) //"Informe motivo da reabertura"
		lRet := .F.
	EndIf
	RestArea( aAreaGW1 )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050BLO
Rotina para realizar o bloqueio do romaneio, referente pre-fatura.

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050BLO()
	Local lRet := .T.
	Local nOpc := 0

	If GWN->GWN_SIT == "4"
		GFEMessage(5, GFEA050017, STR0163, STR0164)	//"Romaneio já está encerrado, portanto não poderá ser bloqueado." / "Somente Romaneios não encerrados podem ser bloqueados."
		Return
	EndIf

	//Ponto de entrada validação Vicunha
	If ExistBlock("GFEA0506")
		If ExecBlock("GFEA0506",.F.,.F.,{"5"})
			Return
		EndIf
	EndIf

	GW1->( dbSetOrder(9) )
	GW1->( dbSeek(xFilial("GW1") + GWN->GWN_NRROM) )

	Do While GW1->( !Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_NRROM == GWN->GWN_NRROM
		GWH->( dbSetOrder(2) )
		GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )

		Do While GWH->( !Eof() ) ;
			.And. GWH->GWH_FILIAL == xFilial("GWH") ;
			.And. GWH->GWH_CDTPDC == GW1->GW1_CDTPDC ;
			.And. GWH->GWH_EMISDC == GW1->GW1_EMISDC ;
			.And. GWH->GWH_SERDC == GW1->GW1_SERDC ;
			.And. GWH->GWH_NRDC == GW1->GW1_NRDC

			GWF->( dbSetOrder(1) )
			If GWF->( dbSeek(xFilial("GWF") + GWH->GWH_NRCALC) )
				GWJ->( dbSetOrder(1) )
				If GWJ->( dbSeek(xFilial("GWJ") + GWF->GWF_NRPREF) )
					If GWJ->GWJ_SIT <> "4"
						/*PutHelp("PFRM050C",{STR0019},{STR0019},{STR0019}) //"Não é possível bloquear romaneio"
						PutHelp("SFRM050C",{STR0020},{STR0020},{STR0020}) //"Romaneio possui pré-fatura"
						HELP(" ",1,"FRM050C","FRM050C" )*/
						GFEMsgErro(STR0019+". "+STR0020+".") //"Não é possível bloquear romaneio" , "Romaneio possui pré-fatura "
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
			GWH->( dbSkip() )
		EndDo

		If !lRet
			Exit
		EndIf
		GW1->( dbSkip() )
	EndDo

	If lRet == .T.
		If GWN->GWN_BLOQPF == "2"
			If msgyesno(STR0040) //"Deseja bloquear romaneio?" //"Deseja bloquear romaneio para emissão de pre-fatura?"
				RecLock('GWN', nOpc == 4 )
					GWN->GWN_BLOQPF := "1"
				GWN->( MsUnLock() )
			EndIf
		else
			If msgyesno(STR0041) //"Deseja desbloquear romaneio?" //"Deseja desbloquear romaneio para emissão de pre-fatura?"
				RecLock('GWN', nOpc == 4 )
					GWN->GWN_BLOQPF := "2"
				GWN->( MsUnLock() )
			EndIf
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050LIB
Rotina para liberar o romaneio

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050LIB(lAuto,cMsg,dData,cHora,lValida)//sempre passar o parametro cMsg por referencia
	Local oDlg       := Nil
	Local cFilRom    := GWN->GWN_FILIAL
	Local cNrRom     := GWN->GWN_NRROM
	Local cRastr     := GWN->GWN_RASTR
	Local nHod       := 0
	Local lRet       := .T.
	Local lWhenHod   := .T.
	Local aRetPE     := {}
	Local cPicHodSai := Alltrim(GetSx3Cache("GWN_HODSAI", "X3_PICTURE"))
	Local cAliasGW1  := Nil
	Local cWhere     := Nil
	Local lWhenDtS   := .t.
	Local lWhenHrS   := .t.
	Local lPE18		 := ExistBlock("GFE05018")

	Default dData   := DDATABASE
	Default cHora   := SubStr(Time(), 1, 5)
	Default lAuto   := .F.
	Default cMsg    := ""
	Default lValida := .F.

	If GfeVerCmpo({"GWN_HODSAI"})
		nHod := GWN->GWN_HODSAI
	Else
		nHod := 0
		lWhenHod := .F.
	EndIf

	If GWN->GWN_SIT == "3" .And. lValida
		If Type("_lSemHelp") == "U"  // Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
			GFEMessage(5, GFEA050018, STR0025, STR0165) 	//"Selecione um Romaneio que não esteja liberado." / "Romaneio já foi liberado"
		EndIf
		cMsg := STR0025
		lRet := .F.
	ElseIf GWN->GWN_SIT == "4"
		If Type("_lSemHelp") == "U" // Definir varivel " Private _lSemHelp := .F."varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
			GFEMessage(5, GFEA050019, STR0166, STR0167)	 	//"Romaneio já está encerrado." / "Selecione um Romaneio que não esteja encerrado para continuar."
		EndIf
		cMsg := STR0166	//"Romaneio já está encerrado."
		lRet := .F.
	EndIf

	If lRet
		lRet := GFE50VALVP(GWN->GWN_CDTPOP,GWN->GWN_VPVAL, GWN->GWN_CDTRP, @cMsg)
	EndIf

	//PE para possibilitar impedimento da liberação do romaneio, retorno deve ser um array no formato:
	//aRetPE[1] (Lógico)    Verdadeiro ou falso, conforme resultado da validação 
	//aRetPE[2] (Caracter)  Mensagem de erro, caso o retorno do primeiro elemento do array seja falso
	If ExistBlock("GFE05013")
		aRetPE := ExecBlock('GFE05013',.F.,.F.)
		If ValType(aRetPE) == 'A' .AND. !Empty(aRetPE)
			If !aRetPE[1]
				GFEMsgErro(aRetPE[2])
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lPE18
		aRetPE := ExecBlock("GFE05018",.F.,.F., {GWN->GWN_FILIAL, GWN->GWN_NRROM, dData, cHora})
		lWhenDtS := aRetPE[1]
		lWhenHrS := aRetPE[2]
		dData    := aRetPE[3]
		cHora    := aRetPE[4]
	EndIf

	If lRet
		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + Alltrim(cFilRom) + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + Alltrim(cFilRom) + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_SIT, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM  = %Exp:cNrRom%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		While !(cAliasGW1)->(Eof())
			If (cAliasGW1)->GW1_SIT = '2'
				If !IsBlind() .And. !IsInCallStack("GFEA054")
					GFEMessage(2, GFEA050020, STR0168, " ")
					lRet := .F.
					Exit
				Else
					cMsg := STR0168 //"Há um ou mais Documentos de Carga com situação bloqueado vinculado ao Romaneio de Carga. Não é possível liberar. Visualize o Romaneio e na aba de Documentos, verifique o campo Situação."
					lRet := .F.
				EndIf
			EndIf

			(cAliasGW1)->(dbSkip())
		EndDo	
		(cAliasGW1)->(dbCloseArea())
	EndIf

	If lRet
		If !lAuto
			DEFINE MSDIALOG oDlg TITLE STR0008 From 4,0 To 16,40 OF oMainWnd //"Liberar"

			@  4, 006  SAY STR0030 SIZE 70,7 PIXEL OF oDlg //"Romaneio:"
			@ 19, 006  SAY STR0023 SIZE 70,7 PIXEL OF oDlg //"Data de Saída:"
			@ 34, 006  SAY STR0024 SIZE 70,7 PIXEL OF oDlg //"Hora de Saída:"
			@ 49, 006  SAY STR0151 SIZE 70,7 PIXEL OF oDlg //"Hora de Saída:"
			@ 64, 006  SAY STR0152 SIZE 70,7 PIXEL OF oDlg //"Código de Rastream"

			@  3, 060  MSGET cNrRom When .F. SIZE 40,7 PIXEL OF oDlg hasbutton
			@ 18, 060  MSGET dData  When lWhenDtS PICTURE "99/99/9999" SIZE 45,7 PIXEL OF oDlg hasbutton Valid GFEVLDATE(dData)
			@ 33, 060  MSGET cHora  When lWhenHrS picture "99:99" 	SIZE 15,7 PIXEL OF oDlg Valid GFEVLDHR(cHora)
			@ 48, 060  MSGET nHod   When lWhenHod PICTURE cPicHodSai SIZE 15,7 PIXEL OF oDlg
			@ 63, 060  MSGET cRastR When .T. SIZE 45,7 PIXEL OF oDlg

			oButtonOK   := tButton():New(80,5,'OK',oDlg,{||If(GFEABTOK(lAuto,dData,cHora,cRastr,nHod),oDlg:End(),lRet:=.F.)},25,10,,,,.T.)
			oButtonCanc := tButton():New(80,35,"Cancelar",oDlg,{||lRet:=.F.,oDlg:End()},25,10,,,,.T.) //"Cancelar"

			ACTIVATE MSDIALOG oDlg
		Else
			If !IsBlind()
				Processa({|| lRet:= GFEABTOK(lAuto,dData,cHora,GWN->GWN_RASTR,,@cMsg) })
			Else
				lRet:= GFEABTOK(lAuto,dData, cHora,GWN->GWN_RASTR,,@cMsg)
			EndIf
		EndIf
	EndIf

	//Ponto de entrada validação Vicunha
	If lRet .AND. ExistBlock("GFEA0505")
		ExecBlock("GFEA0505",.F.,.F.)
	EndIf
	
	If lRet
		If !IsBlind()
			Processa({|| GFE050MAIL(.F.)},'Enviando e-mail aos destinatários do romaneio ' + GWN->GWN_NRROM)
		Else
			GFE050MAIL(.F.)
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEVLDATE
Valida o campo Data
@author  André Eduardo Pérez Álvarez
@since   15.03.2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function GFEVLDATE(dData)
	Local lRet := .T.

	If Empty(dData)
		lRet := .F.
		GFEMessage(5, GFEA050021, STR0169, STR0170)	//"Data inválida." / "Informe uma data valida para continuar."
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA50LIBL
Rotina para liberar uma faixa de romaneios

@author Alexandre José Cuchi
@since 26/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA50LIBL()
	Local   lNotBlind  := !IsBlind()
	
	Private lPergunte  := Pergunte("GFEA050A",.T.)
	Private cFilialDe  := ""
	Private cFilialAte := ""
	Private cRomanDe   := ""
	Private cRomanAte  := ""
	Private dDtCriaDe  := Nil
	Private dDtCriaAte := Nil
	Private dDtSai     := Nil
	Private cHrSai     := ""
	Private _lSemHelp  := .F.// Variável para não exibir os Help's da função GFEA50LIB()

	If lPergunte .And. lNotBlind
		Processa({|| GFEA50LIExec(), STR0153}) // "Liberando romaneios por lote... Aguarde"
	Else
		GFEA50LIExec()
	EndIf
Return

Function GFEA50LIExec() // Faz a liberação por lote
	Local cMsg       := ""
	Local dDtSai     := Nil
	Local nTotRomanP := 0
	Local nErroRoman := 0
	Local nCalcRoman := 0
	Local GFELog     := GFEViewProc():New()
	Local cFiltro    := "@"
	Local cFilAtu    := cFilAnt

	cFilialDe  := MV_PAR01
	cFilialAte := MV_PAR02
	cRomanDe   := MV_PAR03
	cRomanAte  := MV_PAR04
	dDtCriaDe  := MV_PAR05
	dDtCriaAte := MV_PAR06
	dDtSai     := MV_PAR07
	cHrSai     := MV_PAR08

	GWN->( dbSetOrder(1) )
	GWN->(dbClearFilter())
	cFiltro += "GWN_FILIAL >='" + cFilialDe + "'"
	cFiltro += " AND GWN_FILIAL <='" + cFilialAte + "'"
	cFiltro += " AND GWN_NRROM >='" + cRomanDe + "'"
	cFiltro += " AND GWN_NRROM <='" + cRomanAte + "'"

	GWN->(dbSetFilter({||},cFiltro))
	GWN->(dbGoTop())

	ProcRegua(0)

	Do While GWN->( !Eof() )
		If (Empty(dDtCriaDe ) .Or. DToS(GWN->GWN_DTIMPL) >= DToS(dDtCriaDe ));
			.And. (Empty(dDtCriaAte) .Or. DToS(GWN->GWN_DTIMPL) <= DToS(dDtCriaAte))
			
			nTotRomanP++
			cFilAnt := GWN->GWN_FILIAL
			IncProc("Liberando Romaneio... Filial: " + cFilAnt + " Nr.: " + GWN->GWN_NRROM)
			If GFEA050LIB(.T., @cMsg,dDtSai,cHrSai)
				GFELog:Add(Replicate('-',50))
				GFELog:Add(Space(4) + "Filial: " + GWN->GWN_FILIAL + ", Romaneio " + GWN->GWN_NRROM + ": ")
				GFELog:Add(Space(7) + "Foi Liberado com sucesso")
				GFELog:Add("")
				nCalcRoman++
			Else
				GFELog:AddErro(Replicate('-',50))
				GFELog:AddErro(Space(4) +"Filial: " + GWN->GWN_FILIAL + ",Romaneio " + GWN->GWN_NRROM + ": ")
				GFELog:AddErro(Space(7)+"Motivo: " + cMsg)
				GFELog:AddErro("")
				nErroRoman++
			EndIf
		EndIf
		GWN->( dbSkip() )
	EndDo

	cFilAnt := cFilAtu
	GWN->(dbClearFilter())

	GFELog:Add(Replicate('-',50))
	GFELog:Add("")
	GFELog:Add("Total de romaneios processados :" + cValToChar(nTotRomanP))
	GFELog:Add("Total de romaneios Liberados : "  + cValToChar(nCalcRoman))
	GFELog:Add("Total de romaneios com erros : "  + cValToChar(nErroRoman))
	If !IsBlind()
		GFELog:Show("Liberação de Romaneio", "Romaneios Liberados", "Erros", "Um ou mais Romaneios não foram liberados, clique no botão 'Erros' para mais detalhes.")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEABTOK
Rotina para validar a opcao de liberar o romaneio e gravar na tabela

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEABTOK(lAuto,dData, cHora, cRastr,nHodo,cMsg) // Sempre passar o parametro cMsg por referencia
	Local lRet      	:= .T.
	Local lCalcAuto		:= .F.
	Local lSitFT    	:= .F.
	Local aRetVld   	:= {}
	Local aAreaGW1  	:= GW1->(GetArea())
	Local cMV_PLROADE 	:= SuperGetMv("MV_PLROADE",.F.,"2")
	Local cAliasGW1 	:= Nil
	Local cWhere    	:= Nil
		
	Default lAuto   := .F.
	Default cMsg    := ""

	If !(GWN->GWN_NRROM == GW1->GW1_NRROM)
		GW1->(dbSetOrder(09))
		GW1->(dbSeek(xFilial("GW1")+GWN->GWN_NRROM))
	EndIf

	If GFEVerCmpo( {"GV5_CALC","GW1_CALCAT"}) .AND. GW1->GW1_NRROM == GWN->GWN_NRROM  .AND.;
		 (GW1->GW1_CALCAT == "1" .OR. Empty(GW1->GW1_CALCAT)) .AND. Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_CALC") == "2"

		lCalcAuto := .T.
	EndIf
	
	If DTOS(dData) == DTOS(GWN->GWN_DTIMPL)
		If cHora < GWN->GWN_HRIMPL
			cHora := GWN->GWN_HRIMPL
		EndIf
	Else
		If DTOS(GW1->GW1_DTEMIS) > DTOS(dData) .And. cMV_PLROADE == "2"
			If !lAuto
				If !lCalcAuto .And. Type("_lSemHelp") == "U"// Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
					GFEMessage(5, GFEA050022, STR0171, STR0172)	// "Romaneio não pode ser liberado" / "Informe uma data e/ou hora maior ou igual a data de implantação."
				EndIf
				cMsg := STR0171 + STR0172 // "Romaneio não pode ser liberado. Informe uma data e/ou hora maior ou igual a data de implantação."
				lRet := .F.	
			EndIf
		EndIf
	EndIf

	If lRet .And. !lAuto .And. dData > dDataBase
		lRet := .F.
		GFEMessage(5, GFEA050023, STR0173, STR0174)	//// "Romaneio não pode ser liberado" / "Informe uma data menor ou igual a data corrente."
	EndIf

	If lRet
		aRetVld := GFE50AVLIB(GWN->GWN_FILIAL, GWN->GWN_NRROM, dData, cHora, nHodo, cRastr)

		If aRetVld[1] = .F. .And. cMV_PLROADE == "2"
			lRet := .F.
			GFEMessage(5, GFEA050024, GFEMsgFmt(STR0175, {{"[VAR01]", aRetVld[2]}}), STR0176)	//"Romaneio não pode ser liberado: [VAR01]" / "Informe uma data superior a data de emissão do Documento de Carga."
		EndIf
	EndIf

	If lRet
		lSitFT := GfeVerCmpo({"GW1_SITFT"})

		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		If !(cAliasGW1)->(Eof())
			While !(cAliasGW1)->(Eof())
				GW1->(dbGoTo( (cAliasGW1)->GW1RECNO ))
				RecLock('GW1', .F.)
					GW1->GW1_DTSAI := dData
					GW1->GW1_HRSAI := cHora
				GW1->( MsUnLock() )

				If lSitFT
					GV5->( dbSetorder(1) )
					If (GV5->( dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC) ) .AND. GV5->GV5_SENTID == '1') .OR. s_GFEI20_2 != '1'
						RecLock('GW1', .F.)
							GW1->GW1_SITFT := "6"
						GW1->( MsUnLock() )
					Else
						RecLock('GW1', .F.)
							GW1->GW1_SITFT := "2"
						GW1->( MsUnLock() )
					EndIf
				EndIf

				(cAliasGW1)->(dbSkip())
			EndDo	

			RecLock('GWN', .F.)
				GWN->GWN_DTSAI := dData
				GWN->GWN_HRSAI := cHora
				GWN->GWN_SIT   := "3"
				GWN->GWN_RASTR := cRastR
				If GfeVerCmpo({"GWN_HODSAI"}) .AND. nHodo != Nil
					GWN->GWN_HODSAI := nHodo
				EndIf
			GWN->( MsUnlock() )

			aAreaGW1:= GW1->(GetArea())
			GFEA050ALI(GWN->GWN_FILIAL+GWN->GWN_NRROM) // Verifica se o cálculo do documento pode ser liberado
			RestArea(aAreaGW1)
			
			// Início Ponto de Entrada
			If ExistBlock("GFEA0501")
				aPontEnt := ExecBlock("GFEA0501",.F.,.F.,{GWN->GWN_FILIAL, GWN->GWN_NRROM})
			EndIf
			// Fim Ponto de Entrada
		Else
			If !lCalcAuto  .And. Type("_lSemHelp") == "U" // Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
				GFEMessage(5, GFEA050025, STR0042, STR0177)	// "Romaneio não possui documento de carga relacionado." / "Selecione um Romaneio que possua ao menos um Documento de Carga relacionado para continuar."
			EndIf
			cMsg := STR0042 // "Romaneio não possui documento de carga relacionado."
			lRet := .F.
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf

	If lRet
		PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, dData, cHora)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050POS
Rotina para fazer validações antes da gravacao do registro

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA050POS(oModel)
	Local cAliasGW1 := Nil
	Local cWhere    := Nil
	Local aVinc     := {}
	Local lDif      := .F.
	Local cCdTrp    := FwFldGet('GWN_CDTRP')
	Local nOpc      := oModel:GetOperation()
	Local oModelGWN := oModel:GetModel('GFEA050_GWN')

	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		If !GFEA50RLMT(FwFldGet('GWN_CDMTR'), FwFldGet('GWN_CDMTR2'), "1", .F.)
			Return .F.
		EndIf

		If !GFEA50RLMT(FwFldGet('GWN_CDMTR'), FwFldGet('GWN_CDMTR2'), "2", .F.)
			Return .F.
		EndIf

		If nOpc == MODEL_OPERATION_INSERT
			If !GFEA050UNQ()
				Return .F.
			EndIf
		EndIf

		//Vale pedágio
		If !GFE50VALVP(FwFldGet("GWN_CDTPOP"),FwFldGet("GWN_VPVAL"), FwFldGet("GWN_CDTRP"))
			Return .F.
		EndIF

		If !Empty(FwFldGet("GWN_VIAGEM"))
			dbSelectarea('GWP')
			If Posicione('GWP',1,xFilial('GWP') + FwFldGet("GWN_VIAGEM"), "GWP_CDTRP") != FwFldGet("GWN_CDTRP")
				GFEMsgErro("Não é possível alterar o transportador quando o romaneio está relacionado a uma viagem.")
				dbSelectArea('GWN')
				Return .F.
			EndIf
			dbSelectArea('GWN')
		EndIf
		
		If GFXCP12117('GU8_CDTPOP')
			GU8->(dbSetOrder(2))
			If GU8->(dbSeek(xFilial('GU8')+FwFldGet('GWN_PLACAD')))
				If !Empty(GU8->GU8_CDTPOP) .And. Alltrim(GU8->GU8_CDTPOP) != Alltrim(FwFldGet('GWN_CDTPOP'))
					Help(,,'HELP',,'O tipo de operação do romaneio deve ser igual ao tipo de operação do veículo informado.',1,0,) 
					Return .F.
				EndIf
			EndIf
		EndIf

		If GFXCP12121('GWN_NRCT')
			// Valida contrato de transporte para o transportador
			If !Empty(FwFldGet("GWN_NRCT"))
				GXT->( dbSetOrder(01) )
				If !GXT->( dbSeek(xFilial("GXT")+FwFldGet("GWN_NRCT")) )
					GFEHelp("Contrato de transporte (" + FwFldGet("GWN_NRCT") + ") não existe ","Informe um contrato de transporte (GFEA079) válido. ","Contrato de Transporte")
					Return .F.
				Else
					If GXT->GXT_CDTRP !=FwFldGet("GWN_CDTRP")
						GFEHelp("Contrato de transporte (" + FwFldGet("GWN_NRCT") + ") pertence ao transportador (" + GXT->GXT_CDTRP + ").","Informe um contrato de transporte (GFEA079) válido para o transportador (" + FwFldGet("GWN_CDTRP") +").","Contrato de Transporte")
						Return .F.
					EndIf 
				EndIf
			EndIf
		EndIf
	EndIf

	If nopc == MODEL_OPERATION_UPDATE
		If GWN->GWN_CDTRP <> cCdTrp .And. SuperGetMv("MV_GFETRP",.F.,"1") == "2"
			If GFXCP1212210('GW1_FILROM')
				cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
			Else
				cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
			EndIf
			cWhere := "%" + cWhere + "%"

			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
				FROM %table:GW1% GW1
				WHERE %Exp:cWhere%
				AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
				AND GW1.%NotDel%
				ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
			EndSql
			While !(cAliasGW1)->(Eof())
				GWU->(dbSetOrder(1))
				GWU->(dbSeek(GW1->((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + "01")))
				If GWU->GWU_CDTRP <> cCdTrp
					lDif := .T.
					Exit
				EndIf

				(cAliasGW1)->(dbSkip())
			EndDo	
			(cAliasGW1)->(dbCloseArea())

			If lDif
				GFEMsgErro("Conforme definido pelos Parâmetros do Módulo, não é permitido redefinir o Transportador das Cargas pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho dos Documentos de Carga")
				Return .F.
			EndIf
		EndIf

		If FwFldGet( 'GWN_SIT' ) == "3"
			PutHelp("PFRM050A",{STR0027},{STR0027},{STR0027}) //"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa" //"Romaneio Liberado"###"Romaneio Liberado"###"Romaneio Liberado"
			PutHelp("SFRM050A",{STR0028},{STR0028},{STR0028}) //"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou Faixa de CEP" //"Não é possível alterar"###"Não é possível alterar"###"Não é possível alterar"
			HELP(" ",1,"FRM050A","FRM050A" )
			Return .F.
		EndIf

		GWN->(dbSetOrder(1))

		If  (GWN->GWN_CDCLFR <> FwFldGet( 'GWN_CDCLFR' ) .Or. GWN->GWN_CDTRP  <> FwFldGet( 'GWN_CDTRP'  );
			.Or. GWN->GWN_CDTPVC <> FwFldGet( 'GWN_CDTPVC' ) .Or. GWN->GWN_CDTPOP <> FwFldGet( 'GWN_CDTPOP' );
			.Or. GWN->GWN_NRCIDD <> FwFldGet( 'GWN_NRCIDD' ) .Or. GWN->GWN_CEPD   <> FwFldGet( 'GWN_CEPD'   );
			.Or. GWN->GWN_DISTAN <> FwFldGet( 'GWN_DISTAN' ) .Or. TrocouCrgComp(oModelGWN) ;
			) .And. FwFldGet( 'GWN_CALC' ) != "2" .And. GWN->GWN_SIT <> "3"
			
			If IsInCallStack("GFEP001")
				MsgInfo(STR0029) //"Este romaneio precisa ser recalculado"
			EndIf

			RecLock('GWN', .F.)
				GWN->GWN_CALC := "4"
				GWN->GWN_MTCALC := "Foram alteradas informações do Romaneio utilizadas no Cálculo."
				GWN->GWN_DTCALC := CToD("  /  /    ")
				GWN->GWN_HRCALC := ""
			GWN->( MsUnlock() )

		EndIf

		If GWN->GWN_CDTPOP <> FwFldGet('GWN_CDTPOP')
			If GFXCP1212210('GW1_FILROM')
				cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
			Else
				cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
			EndIf
			cWhere := "%" + cWhere + "%"

			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW1.R_E_C_N_O_ AS GW1RECNO
				FROM %table:GW1% GW1
				WHERE %Exp:cWhere%
				AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
				AND GW1.%NotDel%
				ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
			EndSql
			Do While !(cAliasGW1)->(Eof())
				GW1->(dbGoTo((cAliasGW1)->GW1RECNO))

				GV4->( dbSetOrder(1) )
				If GV4->( dbSeek(xFilial("GV4") + FwFldGet('GWN_CDTPOP')) )
					If GV4->GV4_SENTID <> "0"
						GV5->( dbSetOrder(1) )
						If GV5->( dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC) )
							If GV5->GV5_SENTID <> GV4->GV4_SENTID
								Help( ,, 'HELP',, STR0051 + GW1->GW1_NRDC + STR0052, 1, 0,) //"Não é possível alterar tipo de operação. Tipo do Documento de Carga, Nr. :  "###" dIfere do sentido do tipo de operação."
								Return .F.
							EndIf
						EndIf
					EndIf
				EndIf

				(cAliasGW1)->(dbSkip())
			EndDo	
			(cAliasGW1)->(dbCloseArea())
		EndIf

		//Altera o transportador dos trechos do Doc carga vinculados ao romaneio
		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		While !(cAliasGW1)->(Eof())
			GW1->(dbGoTo((cAliasGW1)->GW1RECNO))

			GWU->( dbSetOrder(1) )
			If GWU->( dbSeek(xFilial('GWU') + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
				RecLock('GWU', .F.)
					GWU->GWU_CDTRP  := FwFldGet('GWN_CDTRP')
					GWU->GWU_CDTPVC := FwFldGet('GWN_CDTPVC')
				GWU->( MsUnLock() )
			EndIf

			(cAliasGW1)->(dbSkip())
		EndDo	
		(cAliasGW1)->(dbCloseArea())
	EndIf

	If nOpc == MODEL_OPERATION_DELETE // Eliminar
		If GWN->GWN_SIT == "3"
			Help( ,, 'HELP',, STR0025, 1, 0,) // "Romaneio já foi liberado"
			Return .F.
		EndIf
		
		If !ValCalcLot()
			GFEMsgErro("Romaneio possui cálculos vinculados a Lote de Provisão") 
			Return .F.
		EndIf
		GFEA050DES(GWN->GWN_NRROM)
	EndIf

	If nOpc != MODEL_OPERATION_DELETE

		AAdd(aVinc, {FwFldGet("GWN_CDMTR") , "1"})
		AAdd(aVinc, {FwFldGet("GWN_CDMTR2"), "1"})
		AAdd(aVinc, {FwFldGet("GWN_PLACAD"), "2"})
		AAdd(aVinc, {FwFldGet("GWN_PLACAM"), "2"})
		AAdd(aVinc, {FwFldGet("GWN_PLACAT"), "2"})

		GFEA050VIN(aVinc, FwFldGet("GWN_CDTRP"))

		//Vale pedágio
		If GFEVerCmpo({"GWN_VPVAL"}) .AND. oModel:IsFieldUpdated("GFEA050_GWN","GWN_VPVAL")
			If !Empty(oModel:GetValue("GFEA050_GWN","GWN_VPVAL")) .AND. oModel:GetValue("GFEA050_GWN","GWN_VPVAL") >0
				oModel:LoadValue("GFEA050_GWN", "GWN_VALEP", "2") // Não conferido
			Else
				oModel:LoadValue("GFEA050_GWN", "GWN_VALEP", "1") // Não se aplica
			EndIf
		EndIf

		If GFEVerCmpo({"GWN_VPVAL"}) .AND. Posicione("GV4",1,xFilial("GV4") + oModel:GetValue("GFEA050_GWN","GWN_CDTPOP"),"GV4_PEDAG") == "1"
			oModel:LoadValue("GFEA050_GWN", "GWN_VALEP", "1") // Não se aplica
		EndIf
	EndIf
Return .T.

/*{Protheus.doc} GFEA050VIN

Função para vincular os motoristas e veículos com o transportador informado.

@param	aVinc[n][1] código do Motorista ou Veículo
aVinc[n][2] tipo (Motorista ou Veículo)
cTransp Transportador para informar no Motorista ou Veículo

@author Octávio Augusto Felippe de Macedo
@since 05/03/2012
@version 1.0
*/

Function GFEA050VIN(aVinc, cTransp)
	Local nCount  := 0
	Local nFCount := 0
	Local cTpProp := ""

	nFCount := Len(aVinc)
	For nCount := 1 To nFCount
		If aVinc[nCount][2] == "1"
			GUU->( dbSetOrder(1) )
			If GUU->( dbSeek(xFilial("GUU") + aVinc[nCount][1]) ) .AND. Empty(GUU->GUU_CDTRP)
				RecLock("GUU", .F.)
				GUU->GUU_CDTRP := cTransp
				GUU->( MsUnlock() )
			EndIf
		ElseIf aVinc[nCount][2] == "2" //não utilizado else, para ter ceteza que virá apenas 1 ou 2.
			GU3->( dbSetOrder(1) )
			If GU3->( dbSeek(xFilial("GU3") + cTransp) )
				cTpProp := IIf(GU3->GU3_EMFIL == "1", "2", "1")
			EndIf

			GU8->( dbSetOrder(2) )
			If GU8->( dbSeek(xFilial("GU8") + aVinc[nCount][1]) ) // Removido para cadastrar o mesmo veículo para proprietarios diferentes.AND. Empty(GU8->GU8_CDPROP)
				RecLock("GU8", .F.)
				GU8->GU8_CDPROP := cTransp
				GU8->GU8_TPPROP := cTpProp
				GU8->( MsUnlock() )
			EndIf
		EndIf
	Next nCount
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050DES
Desvincula/Exclúi todos relacionamentos de tabelas relacionados ao romaneio
- Documentos de Carga
- Cálculo
- Rateio

@param	nNRROM	Número do Romaneio

@author Israel Alcantara Possoli
@since 13/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050DES(nNRROM)
	Local aAreaGWN  := GWN->( GetArea() )
	Local aAreaGW1  := GW1->( GetArea() )
	Local aAreaGWH  := GWH->( GetArea() )
	Local aAreaGWF  := GWF->( GetArea() )
	Local aAreaGWM  := GWM->( GetArea() )
	Local aAreaGWA  := GWA->( GetArea() )
	Local aAreaGWT	:= {}
	Local aAreaGWR	:= {}
	Local aAreaGWS	:= {}
	Local aDocCarg  := {}
	Local nDC       := 0
	Local nFDC      := 0

	If GFXCP12117('GWT_NRROM')
		aAreaGWT  := GWT->( GetArea() )
		aAreaGWR  := GWS->( GetArea() )
		aAreaGWS  := GWS->( GetArea() )
	EndIf

	// Documentos de Carga vinculado ao romaneio
	GW1->( dbSetOrder(9) )
	GW1->( dbSeek(xFilial("GW1") + nNRROM) )
	Do While GW1->( !Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_NRROM == nNRROM
		AAdd(aDocCarg, GW1->( RecNo() ))
		GW1->( dbSkip() )
	EndDo

	nFDC := Len(aDocCarg)
	For nDC := 1 To NFDC
		GW1->( dbGoTo(aDocCarg[nDC]) )

		// Desvincula o Documento de Carga do romaneio
		RecLock("GW1", .F.)
		GW1->GW1_NRROM  := ""
		If GW1->GW1_SIT == "4"
			GW1->GW1_SIT    := "3"
		EndIf
		GW1->( MsUnLock() )

		If GFXCP12117("GW1_SITFRE") .And. s_INTFRE == '2'
			If GW1->GW1_ORIGEM == "2" .And. GW1->GW1_SITFRE != '6'
				RecLock("GW1", .F.)
				GW1->GW1_SITFRE := "2"
				GW1->GW1_MOTFRE := "GFEA050 - Exclusão do Romaneio"
				GW1->GW1_DTFRE  := Date()
				GW1->( MsUnLock() )
			EndIf
		EndIf

		// Busca os cálculos do Documento de Carga para a eliminação
		GWH->( dbSetOrder(02) )
		GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
		Do While GWH->( !Eof() ) ;
				.And. GWH->GWH_FILIAL == xFilial("GWH") ;
				.And. GWH->GWH_EMISDC == GW1->GW1_EMISDC;
				.And. GWH->GWH_SERDC == GW1->GW1_SERDC ;
				.And. GWH->GWH_NRDC == GW1->GW1_NRDC

			// Elimina o calculo e seus relacionamentos, na função já verifica se o cálculo existe na base,
			// fazendo com que se houver o mesmo cálculo para DC's diferentes não haja problema
			GFEDelCalc(GWH->GWH_NRCALC)
			GWH->( dbSkip() )
		EndDo
	Next nDC

	If GFXCP12117('GWT_NRROM')
		GWT->( dbSetOrder(01) )
		GWT->( dbSeek(xFilial("GWT") + nNRROM) )
		Do While GWT->( !Eof() ) .and. GWT->GWT_NRROM == nNRROM
			RecLock("GWT",.F.)
			GWT->(dbDelete())
			GWT->( MsUnlock() )
			GWT->( dbSkip() )
		EndDo

		GWR->( dbSetOrder(01) )
		GWR->( dbSeek(xFilial("GWR") + nNRROM) )
		Do While GWR->( !Eof() ) .and. GWR->GWR_NRROM == nNRROM
			RecLock("GWR",.F.)
			GWR->(dbDelete())
			GWR->( MsUnlock() )
			GWR->( dbSkip() )
		EndDo

		GWS->( dbSetOrder(01) )
		GWS->( dbSeek(xFilial("GWS") + nNRROM) )
		Do While GWS->( !Eof() ) .and. GWS->GWS_NRROM == nNRROM
			RecLock("GWS",.F.)
			GWS->(dbDelete())
			GWS->( MsUnlock() )
			GWS->( dbSkip() )
		EndDo
	EndIf

	RestArea(aAreaGW1)
	RestArea(aAreaGWH)
	RestArea(aAreaGWF)
	RestArea(aAreaGWM)
	RestArea(aAreaGWA)
	RestArea(aAreaGWN)

	If GFXCP12117('GWT_NRROM')
		RestArea(aAreaGWT)
		RestArea(aAreaGWR)
		RestArea(aAreaGWS)
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050ENT
Grava a data de entrega do primeiro trecho do documento de carga

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050ENT()
	Local lRet      := .T.
	Local oDlg      := Nil
	Local cDSTRAN   := ""
	Local cCadastro := STR0011 //"Entrega"
	Local dDataEnt  := Ctod(Space(8))
	Local cHrEnt    := "     "
	Local oSize     := Nil'
	Local cX3Rel    := ""

	cX3Rel := &(GetSx3Cache("GWU_HRENT", "X3_RELACAO"))
	If !Empty(cX3Rel)
		cHrEnt := cX3Rel
	EndIf

	If ExistBlock("GFEA0504")
		If ExecBlock("GFEA0504",.F.,.F.,{GWN->GWN_FILIAL, GWN->GWN_NRROM})
			lRet := .F.
		EndIf
	EndIf

	If lRet
		aNewButton := {}

		oSize := FWDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "ENCHOICE", 100, 100, .T., .T. ) // Adiciona enchoice
		oSize:SetWindowSize({500, 200, 730, 820})
		oSize:lLateral     := .F.  // Calculo vertical
		oSize:Process() //executa os calculos

		//--------------------------
		// Montagem da tela
		//--------------------------
		Define MsDialog oDlg Title cCadastro ;
			From oSize:aWindSize[1],oSize:aWindSize[2];
			To oSize:aWindSize[3],oSize:aWindSize[4];
			Of oMainWnd Color CLR_WHITE /*,RGB(225,225,225)*/ Pixel

		oDlg:lEscClose := .F.

		oPanel1:= tPanel():New(oSize:GetDimension("ENCHOICE","LININI"),;
			oSize:GetDimension("ENCHOICE","COLINI"),;
			"",oDlg,,,,,,;
			oSize:GetDimension("ENCHOICE","XSIZE"),;
			oSize:GetDimension("ENCHOICE","YSIZE"))

		//----- Painel superior da tela principal, com as informacoes do romaneio -----//
		//oPnlA := tPanel():New(00,00,,oDlg,,,,,,10,80,.F.,.F.)
		//oPnlA:Align := CONTROL_ALIGN_TOP

		// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
		cDSTRAN := posicione("GU3",1,xFilial("GU3")+GWN->GWN_CDTRP,"GU3_NMEMIT")

		@ 07,10  Say STR0030 Of oPanel1 COLOR CLR_BLACK Pixel //"Romaneio: "
		@ 05,55  MSGET GWN->GWN_NRROM Picture "@!" Of oPanel1 When .F.   Pixel

		@ 22,10 Say STR0031            Of oPanel1 COLOR CLR_BLACK Pixel //"Transportadora: "
		@ 20,55 MSGET GWN->GWN_CDTRP  Picture "@!" Of oPanel1 When .F.   Pixel
		@ 20,145 MSGET cDSTRAN Picture "@!" SIZE 160,10 Of oPanel1 When .F.   Pixel

		@ 37,10  Say STR0032 Of oPanel1 COLOR CLR_BLACK Pixel //"Data Liberação: "
		@ 35,55  MSGET GWN->GWN_DTSAI Picture "  /  /  " Of oPanel1 When .F.   Pixel hasbutton

		@ 37,145  Say "Hr Liberação: " Of oPanel1 COLOR CLR_BLACK Pixel //"Hr Liberação: "
		@ 35,185  MSGET GWN->GWN_HRSAI PICTURE "99:99" When .F. SIZE 30,10 PIXEL OF oPanel1 hasbutton

		@ 52,10  Say STR0033 Of oPanel1 COLOR CLR_BLACK Pixel //"Data Entrega: "
		@ 50,55  MSGET dDataEnt When .T. SIZE 40,7 Valid (!Empty(dDataEnt)) PIXEL OF oPanel1 hasbutton

		@ 67,10  Say STR0105 Of oPanel1 COLOR CLR_BLACK Pixel //"Hora Entrega: "
		@ 65,55  MSGET cHrEnt Picture "99:99" When .T. SIZE 30,7 Valid GFEVLDHR(cHrEnt) PIXEL OF oPanel1
		//---------Fim da criacao dos fields ----------//

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA050OK(dDataEnt, cHrEnt),ODlg:End(),NIL)},;
			{||If(APMSGYESNO(STR0034),ODlg:End(),)},,aNewButton) CENTERED //"Deseja cancelar esse processo?"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050OK
Rotina para fazer validações antes da gravacao do registro da data de entrega (GWU)

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050OK(dDataEnt, cHrEnt)
	Local cListDC   := ""
	Local nTrcPag   := 0
	Local cTrecho   := ""
	Local lEntregue := .T.
	Local aDocGW1 	:= {}
	Local nI 		:= 0

	If GWN->GWN_SIT == "5"
		Help( ,, 'HELP',, "O Romaneio já está encerrado.", 1, 0,) //"O Romaneio já está encerrado."
		Return .F.
	ElseIf GWN->GWN_SIT == "3"

		If dDataEnt > Date()
			Help(,, 'HELP',, "A data informada não pode ser maior que hoje.", 1, 0)
			Return .F.
		ElseIf dDataEnt == Date() .AND. SubStr(cHrEnt, 1, 2) > SubStr(Time(), 1, 2)
			Help(,, 'HELP',, "A hora informada não pode ser maior que a hora atual.", 1, 0)
			Return .F.
		ElseIf dDataEnt == Date() .AND. SubStr(cHrEnt, 1, 2) == SubStr(Time(), 1, 2) .AND. SubStr(cHrEnt, 4, 2) > SubStr(Time(), 4, 2)
			Help(,, 'HELP',, "A hora informada não pode ser maior que a hora atual.", 1, 0)
			Return .F.
		ElseIf dDataEnt < GWN->GWN_DTSAI
			Help(,, 'HELP',, "A data informada não pode ser menor que a Data de Liberação.", 1, 0)
			Return .F.
		ElseIf dDataEnt == GWN->GWN_DTSAI .AND. SubStr(cHrEnt, 1, 2) < SubStr(GWN->GWN_HRSAI, 1, 2)
			Help(,, 'HELP',, "A hora informada não pode ser menor que a Hora de Liberação.", 1, 0)
			Return .F.
		ElseIf dDataEnt == GWN->GWN_DTSAI .AND. SubStr(cHrEnt, 1, 2) == SubStr(GWN->GWN_HRSAI, 1, 2) .AND. SubStr(cHrEnt, 4, 2) < SubStr(GWN->GWN_HRSAI, 4, 2)
			Help(,, 'HELP',, "A hora informada não pode ser menor que a Hora de Liberação.", 1, 0)
			Return .F.
		EndIf

		If dDataEnt < GWN->GWN_DTSAI .AND. StrTran(cHrEnt,":","") < StrTran(GWN->GWN_HRSAI,":","")
			Help( ,, 'HELP',, STR0035, 1, 0,) //"Data entrega menor que data de liberação"
			Return .F.
		EndIf

		If Empty(cHrEnt)
			Help(,, 'HELP',, "A hora de entrega é obrigatória.", 1, 0)
			Return .F.
		EndIf

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.GW1_FILIAL,
				GW1_CDTPDC,
				GW1_EMISDC,
				GW1_SERDC,
				GW1.GW1_NRDC,
				GW1.GW1_NRROM,
				GW1.R_E_C_N_O_
			FROM %table:GW1% GW1
			WHERE GW1.%notDel%
			AND GW1.GW1_FILIAL = %xFilial:GW1%
			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_NRDC
		EndSql

		While !(cAliasGW1)->(Eof())
			AaDD(aDocGW1,{(cAliasGW1)->GW1_FILIAL,;
				(cAliasGW1)->GW1_CDTPDC,;
				(cAliasGW1)->GW1_EMISDC,;
				(cAliasGW1)->GW1_SERDC,;
				(cAliasGW1)->GW1_NRDC,;
				(cAliasGW1)->GW1_NRROM,;
				(cAliasGW1)->R_E_C_N_O_})
			(cAliasGW1)->(dbSkip())
		EndDo
		(cAliasGW1)->(dbCloseArea())

		For nI:= Len(aDocGW1) To 1 Step -1

			GW1->(dbGoTo(aDocGW1[nI,07]))
			If GW1->GW1_SIT == "5"
				cListDC += AllTrim(GW1->GW1_NRDC) + " -> [delivered]" + CRLF
				GW1->( dbSkip() )
				Loop
			EndIf

			GWU->( dbSetOrder(1) )
			GWU->(dbSeek(aDocGW1[nI,01] + aDocGW1[nI,02] + aDocGW1[nI,03] + aDocGW1[nI,04] + aDocGW1[nI,05]))
			Do While GWU->( !Eof() );
					.And. GWU->GWU_FILIAL == aDocGW1[nI,01] ;
					.And. GWU->GWU_CDTPDC == aDocGW1[nI,02] ;
					.And. GWU->GWU_EMISDC == aDocGW1[nI,03] ;
					.And. GWU->GWU_SERDC  == aDocGW1[nI,04] ;
					.And. GWU->GWU_NRDC   == aDocGW1[nI,05]

				If (GWU->GWU_PAGAR == "1" .OR. s_RENTNP == "2") .And. Empty(GWU->GWU_DTENT)
					nTrcPag++
					cTrecho := GWU->GWU_SEQ
					Exit
				EndIf
				GWU->( dbSkip() )
			EndDo

			If nTrcPag != 1
				cListDC += AllTrim(aDocGW1[nI,05]) + If(nTrcPag == 0, " -> [emptystretch]", " -> [morethanonestretch]") + CRLF
				nTrcPag := 0
				lEntregue := .F.
				Loop
			EndIf

			GWU->(dbSetOrder(1))
			If GWU->(dbSeek(aDocGW1[nI,01] + aDocGW1[nI,02] + aDocGW1[nI,03] + aDocGW1[nI,04] + aDocGW1[nI,05] + cTrecho))
				If Empty(GWU->GWU_DTENT) .And. Empty(GWU->GWU_HRENT)
					RecLock("GWU", .F.)
					GWU->GWU_DTENT := dDataEnt
					GWU->GWU_HRENT := cHrEnt
					GWU->(MsUnlock())
				EndIf
			EndIf

			If GW1->GW1_SIT != "6"
				RecLock ("GW1", .F.)
				GW1->GW1_SIT := "5"
				GW1->(MsUnlock())
			EndIf
			// Comentario SAMSUNG
			GFE51IENT() // Integra a data de entrega do último trecho pago com a nota de saída do protheus.

			// Verifica e executa auditoria de Doc Frete se existir Doc Frete Bloqueado
			GFE050AUDIT(aDocGW1[nI,01], aDocGW1[nI,02],aDocGW1[nI,03],aDocGW1[nI,04],aDocGW1[nI,05])

			GW1->( dbSetOrder(9) )
			GW1->( dbSeek(aDocGW1[nI,01] + (aDocGW1[nI,06]) + (aDocGW1[nI,02]) + (aDocGW1[nI,03]) + (aDocGW1[nI,04]) + (aDocGW1[nI,05])) )
			If GW1->GW1_SIT == "5"
				cListDC += AllTrim(aDocGW1[nI,05]) + " -> [delivered]" + CRLF
			ElseIf GW1->GW1_SIT == "6"
				cListDC += AllTrim(aDocGW1[nI,05]) + " -> [returned]" + CRLF
			EndIf

			nTrcPag := 0
		Next nI

		If lEntregue
			RecLock ("GWN", .F.)
			GWN->GWN_SIT := "4"
			GWN->(MsUnlock())
		EndIf

		cListDC := StrTran(cListDC, "[delivered]"         , STR0107) //"Entregue."
		cListDC := StrTran(cListDC, "[emptystretch]"      , STR0108) //"Não Entregue. Documento de Carga não possui trechos pagos."
		cListDC := StrTran(cListDC, "[morethanonestretch]", STR0109) //"Não Entregue. Documento de Carga possui mais de 1 trecho pago."
		cListDC := StrTran(cListDC, "[notExt_Outflow]"    , STR0110) //"Não Entregue. Documento de Carga não é de 'Saída' ou 'Externo'."
		cListDC := StrTran(cListDC, "[returned]"    	  , "Retornado.")

		MsgInfo(STR0111 + GWN->GWN_NRROM + ": " + CRLF + cListDC, "") //"Documentos de carga do romaneio "
	Else
		Help( ,, 'HELP',, STR0017, 1, 0,) //"Romaneio não está liberado"
		Return .F.
	EndIf

	If ExistBlock("GFEA0500")
		If ExecBlock("GFEA0500",.F.,.F.)
			Return .T.
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050CALC
Calcula o frete de um romaneio

@param
lDatabase	Verifica se usa a data base na data da criação do cálculo (GWN_DTCALC)

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE050CALC(lDatabase,lHelp,cMsg,aRetCalc,lTstAuto,cArqLog)
	Local aAreaGWN   := {}
	Local lCalcAuto  := .F.
	Local lLog       := IIF(SuperGetMv("MV_LOGCALC",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log de cálculo, de acordo com os parametros do módulo
	Local nQtPern    := 0
	Local cGU5_TPIMP := ""
	Local cNrOcor    := ""
	Local nX         := 0
	Local nY         := 0
	Local nF         := 0
	Local aDocsCarg  := {}
	Local aNoCalc    := {}
	Local aTcomps    := {}
	Local cAliasQry  := Nil
	Local lCalcrom   := .F.
	Local aRetGXT    := {}

	Private lEdi       := .f.
	Private aTblFrFUNB := {}
	Private aCompsAux  := {}
	Private nTblFrFUNB := 1
	Private nAux2      := 1
	Private cCalAntigo := ''

	// Parâmetro utilizado para realizar nova conferênica Doc Frete
	// Deve estar como Private pois é utilizado dentro de outra função chamada por esta
	Private cMV_GFE005 := SuperGetMv("MV_GFE005",.F.,"1")
	Private aDFReConf  := {}

	Private lFirstMsg  := .F.

	Default lDatabase  := .T.
	Default lHelp      := .T.
	Default cMsg       := ""
	Default aRetCalc   := {}
	Default lTstAuto   := .F.

	If Empty(cMV_GFE005)
		cMV_GFE005 := "1"
	EndIf

	If lHelp .And. !Empty(GWN->GWN_VIAGEM) .And. !IsInCallStack("GF58ExecPVIA") // Quando lhelp é falso, o cálculo deve ser em lote
		If PosicionaGWP(lHelp,@cMsg)
			Return GFEA58CVIA(GWN->GWN_NRROM) // Calcula todos romaneios da viagem
		Else
			Return .F.
		EndIf
	EndIf
	//Verifica se está sendo calculado para um docmento automático para suprimir mensagens
	If !lTstAuto
		If  !(GWN->GWN_NRROM == GW1->GW1_NRROM)
			GW1->( dbSetOrder(09) )
			GW1->( dbSeek(xFilial("GW1")+GWN->GWN_NRROM) )
		EndIf
		If (GW1->GW1_CALCAT == "1" .OR. Empty(GW1->GW1_CALCAT)) ;
				.And. Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_CALC") == "2"

			lCalcAuto := .T.
		EndIf
	Else
		lCalcAuto := .T.
	EndIf

	aAgrFrt  := {}
	aDocCarg := {}
	aTrchDoc := {}
	aItDoc   := {}

	aAreaGWN := GWN->( GetArea() )
	// Validações em relação ao documento de carga
	GWN->( dbSetOrder(1) )
	aDocsCarg := {.F.,{}}
	If GWN->(dbSeek(xFilial("GWN") + GWN->GWN_NRROM))
		aDocsCarg := GF50VLROM(GWN->GWN_NRROM,lCalcAuto,"ROMANEIO") // Valida e retorna os documentos recalculáveis
	EndIf

	// [1]: 0=Todos podem calcular; 1=alguns podem calcular; 2=Nenhum pode calcular; 3=Romaneio calculado no ERP
	// [2]: Dados de DCs localizados.
	// [3]: Mensagem de problemas identificados
	// [4]: Num Calculo pré existente nos DCs localizados
	If Len(aDocsCarg[2]) == 0
		If GW1->GW1_SIT == "2"
			cMsg := "O Documento de Carga relacionado ao Romaneio está bloqueado."
		Else
			cMsg := "Não há documentos relacionados ao Romaneio."
		EndIf

		If lCalcAuto == .F. .AND. lHelp
			Help( ,, 'HELP',, cMsg, 1, 0)
		EndIf
		Return .F.
	ElseIf aDocsCarg[1] == 3
		cMsg := aDocsCarg[2,Len(aDocsCarg[2]),2]
		If lCalcAuto == .F. .AND. lHelp
			Help( ,, 'HELP',, cMsg, 1, 0)
		EndIf
		Return .F.
	ElseIf aDocsCarg[1] == 2
		cMsg := "Não foi possível recalcular nenhum frete para documentos relacionados ao romaneio." + CRLF  + CRLF + "Motivos: "
		nF := Len(aDocsCarg[3])
		For nX := 1 To nf
			cMsg += aDocsCarg[3,nX] + CRLF
		Next nX
		If lCalcAuto == .F. .AND. lHelp
			Help( ,, 'Cálculo de Frete',, cMsg, 1, 0)
		EndIf
		Return .F.
	ElseIf aDocsCarg[1] == 1
		cMsg := "As seguintes situações impedem o recálculo de alguns documentos relacionados:" + CRLF
		nF := Len(aDocsCarg[3])
		For nX := 1 To nF
			cMsg += aDocsCarg[3,nX] + CRLF
		Next nX
		If lCalcAuto == .F. .AND. lHelp .And. !IsBlind() .And. !MsgYesNo(cMsg +  "Deseja prosseguir?")
			cMsg := ""
			Return .F.
		EndIf
	EndIf
	// Início Ponto de Entrada Britania
	If ExistBlock("XGFECALI")
		aRotAdic := ExecBlock("XGFECALI",.F.,.F.,{GWN->GWN_NRROM})
	EndIf
	// Fim Ponto de Entrada Britania
	RestArea(aAreaGWN)

	GWN->(dbSetOrder(1))
	If GWN->(dbSeek(xFilial("GWN") + GWN->GWN_NRROM))

		aAdd(aAgrFrt, { GWN->GWN_NRROM ,; //Numero do Agrupador
		GWN->GWN_CDTRP ,; //Transportador
		GWN->GWN_CDTPVC,; //Tipo de Veiculo
		GWN->GWN_CDCLFR,; //ClassIficacao de Frete
		GWN->GWN_CDTPOP,; //Tipo de Operacao
		GWN->GWN_DISTAN,; //Distancia Percorrida
		GWN->GWN_NRCIDD,; //Cidade Destino
		GWN->GWN_CEPD,;   //CEP Destino
		'0'})             //ERRO

		aDocCarg := {}
		aItDoc   := {}
		aTrchDoc := {}
		aNoCalc  := {}

		GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)
	EndIf

	If (Len(aTrchDoc) == 0 .Or. Len(aItDoc) == 0) .And. aDocsCarg[1] != 2
		cMsg := "Documento de Carga não possui item ou trecho."
		If lCalcAuto == .F. .And. lHelp
			Help( ,, 'HELP',, cMsg, 1, 0)
		EndIf
		Return .F.
	EndIf

	// Executa o cálculo e armazena o retorno em um vetor
	// [1] Sucesso (True/Não)
	// [2] Arquivo de log
	// [3] Array de Erros
	/*@param  aAgrFrt        Agrupadores de Frete -> Romaneios
	@param  aDocCarg       Documentos de Carga -> NF, etc.
	@param  aTrchDoc       Trechos do Documento de Carga
	@param  aItDoc         Itens do Documento de Carga
	@param  [aTblFrt]      Tabela de Frete
	@param  [lReal]        Calculo Real? (ou simulacao) default = .T.
	@param  [iLogProc]     Apresenta log ao final do processo? 0: Não apresentar, 1: Somente erros, 2: Sempre
	@param  [lTabProv]     Cálculo de Provisão? default = .F.
	@param  [lParCons]     Considerar Tabelas de frete com a situação 'Em negociação'? default = .F.
	@param  [iTpSimul]     Tipo de simulação: 0=simulação geral, 1=simulação específica
	@param  lCalcLote       Recebe ".T." se rotina que chamou a função é GFEA081.
	@param	lHideProgress	Esconde a barra de progresso

	@sample GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, aTblFrt, lReal, iLogProc, nTabProv, lParCons, iTpSimul, lCalcLote, lHideProgress, lLog, lServ, pServTpImp, pCalcDataBase) */

	aAgrFrt2  := aClone(aAgrFrt)
	aDocCarg2 := aClone(aDocCarg)
	aTrchDoc2 := aClone(aTrchDoc) 
	aItDoc2   := aClone(aItDoc)

	If aDocsCarg[1] != 2
		//Ponto de Entrada Negociação de Frete
		If ExistBlock("GFE05010")
			aItDoc := ExecBlock("GFE05010",.f.,.f.,{GWN->GWN_PLACAD,aItDoc})
		EndIf
		//Fim Ponto de Entrada

		aRetGXT := GFEA50GXT()		
		aRetCalc := GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, IIF(aRetGXT[1]== .T.,aRetGXT[2],Nil), .T.,If( lCalcAuto .OR. !lHelp ,0,2),,,,,lCalcAuto .OR. !lHelp,lLog, /* lServ */, /* pServTpImp */, lDatabase,aNoCalc)
		
		lCalcrom := aRetCalc[1]
		cArqLog := aRetCalc[2]
		If aRetCalc[1]
			GWN->(dbSetOrder(1))
			If GWN->(dbSeek(xFilial("GWN") + aAgrFrt[1,1]))
				RecLock('GWN', .F. )
					GWN->GWN_CALC   := "1"
					GWN->GWN_MTCALC := "Calculado com sucesso"
					If lDatabase
						GWN->GWN_DTCALC := DDATABASE
					Else
						GWN->GWN_DTCALC := Date()
					EndIf

					GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)				

					If  !Empty(GWN->GWN_DTSAI) .AND. !Empty(GWN->GWN_HRSAI)
						PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, GWN->GWN_DTSAI, GWN->GWN_HRSAI)
					EndIf
					
					If GFXCP12127("GXY_NRCT")
					
						GWF->(dbSetOrder(04) )
						GWF->(dbSeek(xFilial("GWF")+GWN->GWN_NRROM) ) 
						Do While GWF->(!Eof()) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. GWF->GWF_NRROM == GWN->GWN_NRROM
							GXY->(dbSetOrder(2))
							GXY->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
							Do While GXY->(!Eof() ) .And. GXY->GXY_FILCA == GWF->GWF_FILIAL .And. GXY->GXY_NRCALC == GWF->GWF_NRCALC
								GWN->GWN_NRCT := GXY->GXY_NRCT
								GXY->(dbSkip())
							EndDo
						
							GWF->(dbSkip())
						EndDo
					EndIf
				
				GWN->(MsUnlock())
			EndIf
			
			If cMV_GFE005 == "2"
				nF := Len(aDFReConf)
				For nX := 1 To nF
					GW3->(dbSetOrder(1))
					If GW3->(dbSeek(aDFReConf[nX][1] + aDFReConf[nX][2] + aDFReConf[nX][3] + aDFReConf[nX][4] + aDFReConf[nX][5] + aDFReConf[nX][6]))
						GFE50DFCONF()
					EndIf
				Next nX
			EndIF
		Else
			GWN->(dbSetOrder(1))
			If GWN->(dbSeek(xFilial("GWN") + aAgrFrt[1,1]))
				RecLock('GWN', .F. )
					GWN->GWN_CALC   := "3"
					
					aErr:= GFECalcErr(aRetCalc[3][1][2])
					nF := Len(aRetCalc[3][1][4])
					For nY:= 1 To nF
						aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aRetCalc[3][1][4][nY])
					Next nY
					
					GWN->GWN_MTCALC := " " + aErr[1] + CRLF + "----" + CRLF
				
					If Empty(GWN->GWN_MTCALC)
						GWN->GWN_MTCALC := "Falha no cálculo"
					EndIf
					GWN->GWN_DTCALC := CToD("  /  /    ")
					GWN->GWN_HRCALC := ""
				GWN->( MsUnLock() )
				
				If  !Empty(GWN->GWN_DTSAI) .AND. !Empty(GWN->GWN_HRSAI)
					PrevEntreg(GWN->GWN_FILIAL, GWN->GWN_NRROM, GWN->GWN_DTSAI, GWN->GWN_HRSAI)
				EndIf
			EndIf
		EndIf
	Else	
		lCalcrom := .T. //Significa que já foi recebido os documentos de frete do cálculo normal/redespacho
	EndIf
	
	If lCalcrom .And. GFXCP12117("GV9_TPIMP") == .T. 
		aTblFrFUNB := {}
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GWG.GWG_CDEMIT,
					GWG.GWG_NRTAB,
					GWG.GWG_NRNEG,
					GWG.GWG_NRROTA,
					GWG.GWG_CDFXTV,
					GWF.R_E_C_N_O_ AS RECNOGWF
			FROM %Table:GWF% GWF
			INNER JOIN %Table:GWG% GWG
			ON GWG.GWG_FILIAL = GWF.GWF_FILIAL
			AND GWG.GWG_NRCALC = GWF.GWF_NRCALC
			AND GWG.%NotDel%
			WHERE GWF.GWF_FILIAL = %xFilial:GWF%
			AND GWF.GWF_NRROM = %Exp:GWN->GWN_NRROM%
			AND GWF.%NotDel%
			GROUP BY GWG.GWG_CDEMIT,
						GWG.GWG_NRTAB,
						GWG.GWG_NRNEG,
						GWG.GWG_NRROTA,
						GWG.GWG_CDFXTV,
						GWF.R_E_C_N_O_
		EndSql
		Do While (cAliasQry)->(!Eof())
			GWF->(dbGoTo( (cAliasQry)->RECNOGWF ))

			If GWF->GWF_TPCALC == "7" .And. ChkCompServ() // Verifica se o calculo anterior usado teve componentes de serviço, se sim exclui calculo
				GFEDelCalc( GWF->GWF_NRCALC )	// Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contábeis
			Else
				aADD(aTblFrFUNB,{GWN->GWN_NRROM,(cAliasQry)->GWG_NRTAB,(cAliasQry)->GWG_NRNEG,(cAliasQry)->GWG_NRROTA,(cAliasQry)->GWG_CDFXTV,(cAliasQry)->GWG_CDEMIT})
			EndIf

			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())

		aTcomps := GFEXCOMP(aTblFrFUNB)
	    
		aDocsCarg := GF50VLROM(GWN->GWN_NRROM,lCalcAuto,"SERVICO")
		
		aDocCarg := {}
		aItDoc   := {}
		aTrchDoc := {}
		aNoCalc  := {}
		
		If aDocsCarg[1] == 2
			cMsg := "Não foi possível recalcular nenhum serviço para documentos relacionados ao romaneio. Motivos:" + CRLF
			nF := Len(aDocsCarg[3])
			For nX := 1 To nF
				cMsg += aDocsCarg[3,nX] + CRLF
			Next nX 
			If lCalcAuto == .F. .AND. lHelp
				Help( ,, 'HELP',, cMsg, 1, 0)
			EndIf
			Return .F.
		EndIf
		
		GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)//Alimenta os arrays do cálculo
	
		aDocCarg2 := aClone(aDocCarg)
		aTrchDoc2 := aClone(aTrchDoc) 
		aItDoc2 := aClone(aItDoc)
	
		If !Empty(aTblFrFUNB)
			GV9->(dbSetOrder(1))
			If GV9->(dbSeek(xFilial("GV9")+aTblFrFUNB[1][6]+aTblFrFUNB[1][2]+aTblFrFUNB[1][3])) //GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG
				If Empty(GV9->GV9_TPIMP)
					cGU5_TPIMP := '1'
				Else
					cGU5_TPIMP := GV9->GV9_TPIMP
				EndIf
			EndIf

			If Len(aTcomps) > 0 .And. aTcomps[1][5] == .T.
				GFEServFrete({}, aAgrFrt2, aDocCarg2, aTrchDoc2, aItDoc2, nQtPern, cNrOcor, IsInCallStack('GFEA117'), cGU5_TPIMP, ,.f.,.f.,lCalcAuto .OR. !lHelp,aNoCalc) //Função que realiza o cálculo de serviço
			EndIf	
		EndIf
		
	EndIf

	// Início Ponto de Entrada Britania
	If ExistBlock("XGFECALF")
		aRotAdic := ExecBlock("XGFECALF",.F.,.F.,{GWN->GWN_NRROM})
	EndIf
	// Fim Ponto de Entrada Britania

	//Ponto de entrada validação Vicunha
	If ExistBlock("GFEA0508")
		ExecBlock("GFEA0508",.F.,.F.)
	EndIf
Return lCalcRom

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050AJUS

Função de ajuste de cálculo de frete chamada no programa de romaneio

@author Jorge Matos Valcanaia
@since 14/05/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE050AJUS()
	Local oDlg      := Nil
	Local nAlt      := 550
	Local nLrg      := 850
	Local cDsTransp := ""
	Local oCombo    := Nil
	Local cCombo    := ""
	Local oGet      := Nil
	Local cAliasQry := Nil
	Local aTpCalc   := RetSx3Box(Posicione('SX3',2,'GWF_TPCALC','X3CBox()'),,,1)
	Local nTpCalc   := 0
	Local aItems    := {}
	Local lRet      := .T.
	Local lPE17		:= ExistBlock("GFE05017")

	Private nVlFrete     := 0
	Private nVlTotAj     := 0
	Private nVlFinal     := 0
	Private nVlAjust     := 0
	Private lImpEmbutido := .F.
	Private nImpAliquota := 0
	Private nImpValor    := 0
	Private cJustIfi     := ""

	Private cCadastro := STR0055 //"Ajuste do Romaneio de Carga"
	Private cMarca    := GetMark()

	//Ponto de entrada validação Vicunha
	If ExistBlock("GFEA0506")
		If ExecBlock("GFEA0506",.F.,.F.,{"6"})
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. GWN->GWN_CALC != "1"
		Help( ,, 'HELP',, STR0056, 1, 0)	 //"Romaneio de Carga não pode ser Ajustado pois ainda não foi Cálculado."
		lRet := .T.
	EndIf
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	If lRet
		aMKB :=    {{"DTAJUS" ,"D",08 ,0},;
					{"HRAJUS" ,"C",05 ,0},;
					{"VLAJUS" ,"N",12 ,2},;
					{"SIT"    ,"C",20 ,0},;
					{"DTAPRO" ,"D",08 ,0},;
					{"HRAPRO" ,"C",05 ,0}}

		aCpMKB  := {{"DTAJUS"  ,NIL,STR0057,""  },; //"Data Ajuste"
					{"HRAJUS"  ,NIL,STR0058,"@!"},; //"Hora Ajuste"
					{"SIT"     ,NIL,STR0059,"@!"},; //"Situação"
					{"VLAJUS"  ,NIL,STR0060,"@E 999,999,999.99"},; //"Valor Ajuste"
					{"DTAPRO"  ,NIL,STR0061,""  },; //"Data Aprovação/Reprovação"
					{"HRAPRO"  ,NIL,STR0062,"@!"}} //"Hora Aprovação/Reprovação"

		cAliMKB := GFECriaTab({aMKB,{"DTAJUS"}})

		CursorWait()

		//--------------------------
		// Montagem da tela
		//--------------------------
		Define MsDialog oDlg Title cCadastro From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
		oDlg:lEscClose := .F.

		oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,135,.F.,.F.)
		oPnlA:Align := CONTROL_ALIGN_TOP
		oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
		oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GWF.GWF_NRCALC,
					GWF.GWF_TPCALC,
					GWF.GWF_DTCRIA,
					GU3.GU3_NMEMIT
			FROM %Table:GWF% GWF
			INNER JOIN %Table:GU3% GU3
			ON GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDEMIT = GWF.GWF_TRANSP
			AND GU3.%NotDel%
			WHERE GWF.GWF_FILIAL = %xFilial:GWF%
			AND GWF.GWF_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GWF.GWF_TPCALC <> '8' // 8 - Estimativa
			AND GWF.%NotDel%
		EndSql
		TCSetField(cAliasQry,"GWF_DTCRIA","D",8,0)
		If (cAliasQry)->(!Eof())
			Do While (cAliasQry)->(!Eof())
				nTpCalc := Val(AllTrim((cAliasQry)->GWF_TPCALC))
				// Adiciona o cálculo no array
				Aadd(aItems,STR0070 + (cAliasQry)->GWF_NRCALC + " | " + PadR((cAliasQry)->GU3_NMEMIT,50) + " | " + PadR(aTpCalc[nTpCalc,3],20) + " | " + DtoC((cAliasQry)->GWF_DTCRIA)) //"Cálculo: "
				(cAliasQry)->(dbSkip())
			EndDo
			
			//Indica que o Combo sera carregado no primeiro item do array
			cCombo:= aItems[1]
			
			cDsTransp := posicione("GU3",1,xFilial("GU3")+GWN->GWN_CDTRP,"GU3_NMEMIT")

			@ 07,15  Say STR0071 Of oPnlA COLOR CLR_BLACK Pixel //"Número Romaneio: "
			@ 05,63  MSGET GWN->GWN_NRROM   Picture "@!" Of oPnlA When .F.   Pixel

			@ 22,25 Say STR0072              Of oPnlA COLOR CLR_BLACK Pixel //"Transportador: "
			@ 20,63 MSGET GWN->GWN_CDTRP  Picture "@!" Of oPnlA When .F.   Pixel

			@ 20,118 MSGET cDsTransp Picture "@!" Of oPnlA When .F.   Pixel

			@ 37,18 Say STR0073              Of oPnlA COLOR CLR_BLACK Pixel //"Cálculo a Ajustar: "
			oCombo:= tComboBox():New(36,63,{|u|If(PCount()>0,cCombo:=u,cCombo)},aItems,300,10,oPnlA,,{||GFEA050COB(cCombo)},,,,.T.,,,,,,,,,'cCombo')

			//Chamada da Função para carregar os valores do cálculo
			GFEA050COB(cCombo)

			@ 53,32 Say STR0074              Of oPnlA COLOR CLR_BLACK Pixel //"Valor Frete: "
			@ 51,63 MSGET nVlFrete Picture "@! 999,999,999.99" Of oPnlA When .F.   Pixel

			@ 68,132 Say STR0075              Of oPnlA COLOR CLR_BLACK Pixel            //"Valor Total Ajustes: "
			@ 66,180 MSGET nVlTotAj Picture "@! 999,999,999.99" Of oPnlA When .F.   Pixel

			@ 53,151 Say STR0076              Of oPnlA COLOR CLR_BLACK Pixel            //"Valor Final: "
			@ 51,180 MSGET nVlFinal Picture "@! 999,999,999.99" Of oPnlA When .F.   Pixel

			@ 68,29 Say STR0077              Of oPnlA COLOR CLR_BLACK Pixel   //"Valor Ajuste: "
			@ 66,63 Get oGet Var nVlAjust Picture '@E 999,999,999.99' Pixel OF oPnlA
			oGet:bChange := {||/* GFE050AJ()*/ }

			@ 83,26 Say STR0078              Of oPnlA COLOR CLR_BLACK Pixel     	 //"Motivo Ajuste: "
			oTMultiget1 := TMultiget():New(83,63,{|u|If(Pcount()>0,cJustIfi:=u,cJustIfi)},oPnlA,300,45,,,,,,.T.,,,,,,.F.,{|u| If(len(cJustIfi) > 254, GFEMsgErro("O tamanho máximo de caracteres para a descrição do motivo é de 254."+CRLF+CRLF+"- A descrição informada possui "+Alltrim(Str(Len(cJustIfi)))+ " caracteres."),.T. )})
			oTMultiget1:EnableVScroll( .T. )
			oTMultiget1:GoEnd()
			oTMultiget1:Refresh()

			oTButton3 := TButton():Create( oPnlA,65,250,STR0079,{||GFEA050EAJ(cJustIfi, cCombo)},50,11,,,,.T.,,,,,,)         //"Efetivar Ajuste"

			Processa({|lEnd| GFE50ACGAJU(cCombo)},STR0080,STR0081) //"Processando informações"###"Aguarde"

			CursorArrow()

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||,ODlg:End()},{||,ODlg:End(),},,/*oMark:oBrowse:Gotop()*/) CENTERED

			GFEDelTab(cAliMKB)
		Else
			Help( ,, 'HELP',, "Romaneio não possui cálculo a ser ajustado", 1, 0)
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	// Ponto de Entrada IMERYS PERLITA PAULINIA MINERAIS LTDA
	If lRet .And. lPE17
		ExecBlock("GFE05017",.F.,.F., {GWN->GWN_FILIAL, GWN->GWN_NRROM})	
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA050COB(cCombo)

Função que carrega o valor dos ajustes já realizados para aquele cálculo

@param cCombo -> Recebe o conteudo do Combo que está sendo exibido na tela

@author Jorge Matos Valcanaia
@since 14/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050COB(cCombo,lAtuLista)
	Local cNrCalc     := Substring(cCombo,10,8) //Pega dentro da Variavel cCombo o Valor que representa o número daquele Cálculo
	
	Default lAtuLista := .T.
	
	nVlFrete     := 0
	nVlTotAj     := 0
	lImpEmbutido := .F.
	nImpValor    := 0
	cJustIfi     := ""

	If lAtuLista
		//Limpa Tabela Temporaria
		dbSelectArea(cAliMKB)
		ZAP
	EndIf
	//Recebe o retorno da função VLTOTFRET que retorna o valor do cálculo do frete
	GWF->(dbSetOrder(1))
	If GWF->(dbSeek(xFilial("GWF") + cNrCalc))
		IF GWF->GWF_ADICIS == "1"
			lImpEmbutido := .T.
			If GWF->GWF_IMPOST == "1" // ICMS
				nImpValor    := GWF->GWF_VLICMS
				nImpAliquota := GWF->GWF_PCICMS
			Else // ISS
				nImpValor    := GWF->GWF_VLISS
				nImpAliquota := GWF->GWF_PCISS
			EndIf
		EndIf

		GWI->(dbSetOrder(1))
		GWI->(dbSeek(xFilial("GWI") + GWF->GWF_NRCALC))
		Do While GWI->(!Eof()) .And. xFilial("GWI") == GWI->GWI_FILIAL .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
			If GWI->GWI_TOTFRE == "1"
				nVlFrete += GWI->GWI_VLFRET
			EndIf
			GWI->(dbSkip())
		EndDo
	EndIf

	GWO->(dbSetOrder(1))
	GWO->(dbSeek(xFilial("GWO")+cNrCalc))
	Do While GWO->(!Eof()) .And. xFilial("GWO") == GWO->GWO_FILIAL .And. GWO->GWO_NRCALC == cNrCalc
		//Soma o valor dos ajustes ja realizados
		If GWO->GWO_SITAJU <> "3"
			nVlTotAj += GWO->GWO_VLAJUS
		EndIf
		GWO->(dbSkip())
	EndDo

	// Atualiza o Valor Final do Frete
	GFE050AJ()
	
	If lAtuLista
		Processa({|lEnd| GFE50ACGAJU(cCombo)},STR0080,STR0081) //"Processando informações"###"Aguarde"
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050AJ(cCombo)

Função que atualiza o valor final do frete

Obs: Todas as variaveis definidas na função GFE050AJUS

@author Jorge Matos Valcanaia
@since 14/05/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE050AJ()
	//nVlFinal - Valor Final  - Private
	//nVlFrete - Valor Frete  - Private
	//nVlAjust - Valor Ajuste - Private
	If lImpEmbutido
		nVlFinal := (nVlFrete - nImpValor) + nVlTotAj
		nVlFinal := NoRound(nVlFinal / ((100 - nImpAliquota) / 100), 2)
	Else
		nVlFinal := nVlFrete + nVlTotAj
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE50ACGAJU(cCombo)

Função de Carregamento da tela principal aonde é exibida a tabela temporaria com os valores em tela

@param cCombo -> Recebe o conteudo do Combo que está sendo exibido na tela

@author Jorge Matos Valcanaia
@since 14/05/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE50ACGAJU(cCombo)
	Local cNrCalc := Substring(cCombo,10,8)
	Local cDesSit := ""

	//Limpa Tabela Temporaria
	dbSelectArea(cAliMKB)
	ZAP

	GWO->( dbSetOrder(1) )
	GWO->( dbSeek(xFilial("GWO") + cNrCalc) )
	Do While GWO->(!Eof()) .And. xFilial("GWO") == GWO->GWO_FILIAL .And. GWO->GWO_NRCALC == cNrCalc
		//Carrega a Variavel cDesSit com a descrição da situação
		If GWO->GWO_SITAJU == "1"
			cDesSit	:= STR0082 //"Solicitado"
		ElseIf GWO->GWO_SITAJU == "2"
			cDesSit := STR0083 //"Aprovado"
		ElseIf GWO->GWO_SITAJU == "3"
			cDesSit := STR0084 //"Reprovado"
		EndIf

		//Grava o registro encontrado na Tabela Temporaria
		RecLock(cAliMKB,.T.)
			(cAliMKB)->DTAJUS := GWO->GWO_DTAJUS
			(cAliMKB)->HRAJUS := Transform(StrTran(GWO->GWO_HRAJUS,":",""),"@R 99:99")
			(cAliMKB)->VLAJUS := GWO->GWO_VLAJUS
			(cAliMKB)->SIT    := cDesSit
			(cAliMKB)->DTAPRO := GWO->GWO_DTAPRP
			(cAliMKB)->HRAPRO := GWo->GWO_HRAPRP
		(cAliMKB)->(MsUnLock())
		GWO->( dbSkip() )
	EndDo

	(cAliMKB)->(dbSetOrder(01))
	(cAliMKB)->(dbGoTop())

	oMark := MsSelect():New(cAliMKB,,,aCpMKB,,,{0,0,0,0},,,oPnlB)
	oMark:oBrowse:cToolTip := STR0085 //"Visualização"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:OBrowse:Refresh()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GF50VLDAJ
	Validação de ajuste do cálculo escolhido
@author siegklenes.beulke
@since 23/01/2017
@param cJustIfi, characters, justificativa
@param cCombo, characters, Combo do cálculo escolhido
@example
(examples)
@see (links_or_references)
/*/
Function GF50VLDAJ(cJustIfi, cCombo, lAjusteMenor, cMsg)
	Local nFreteFinal    := 0
	Local nFrtSemAj      := 0
	Default lAjusteMenor := .F.
	// Validações private
	If lImpEmbutido 
		nFreteFinal := (nVlFrete - nImpValor) + nVlTotAj + nVlAjust
		nFreteFinal := NoRound(nFreteFinal / ((100 - nImpAliquota) / 100), 2)
		nFrtSemAj := (nVlFrete - nImpValor) + nVlTotAj
	Else
		nFreteFinal := (nVlFrete + nVlTotAj + nVlAjust)
		nFrtSemAj := (nVlFrete - nImpValor) + nVlTotAj
	EndIf
	
	//Se o valor do ajuste estiver como Zero apresenta mensagem de Erro
	If nVlAjust == 0
		If cMsg == Nil
			Help( ,, 'HELP',, STR0086, 1, 0)   //"Não foi informado o valor do ajuste"
		EndIf
		cMsg := STR0086 //"Não foi informado o valor do ajuste"
		Return .F.
	EndIf

	If nFreteFinal <= 0 .And. !lAjusteMenor
		If lImpEmbutido
			If cMsg == Nil
				Help( ,, 'HELP',, "O valor final do frete deve ser maior que zero." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Observação: Este cálculo de frete possui o valor do imposto embutido. O valor do ajuste será calculado juntamente com o imposto.", 1, 0)
			EndIf
			cMsg := "O valor final do frete deve ser maior que zero." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Observação: Este cálculo de frete possui o valor do imposto embutido. O valor do ajuste será calculado juntamente com o imposto."
		Else
			If cMsg == Nil
				Help( ,, 'HELP',, "O valor final do frete deve ser maior que zero.", 1, 0)
			EndIf
			cMsg := "O valor final do frete deve ser maior que zero."
		EndIf
		Return .F.
	EndIf

	//Se o motivo da JustIficativa estiver em branco Apresenta mensagem de erro
	If Empty(cJustIfi)
		If cMsg == Nil
			Help( ,, 'HELP',, STR0088, 1, 0)   //"Motivo do Ajuste deve ser informada."
		EndIf
		cMsg := STR0088 //"Motivo do Ajuste deve ser informada."
		Return .F.
	EndIf
	
Return GF50VLDCLC(cCombo,@cMsg)

//Validaçõs para geração de um ajuste de cálculo
Function GF50VLDCLC(cCombo,cMsg)
	Local lCalCDoc := GFEA050CAL(SubStr(cCombo,10,8),,@cMsg)
	
	If lCalCDoc
		Return .F.
	EndIf

	GWF->(dbSetOrder(1))
	If GWF->(dbSeek(xFilial("GWF") + SubStr(cCombo,10,8)))
		GWJ->(dbSetOrder(1))
		If GWJ->(dbSeek(GWF->GWF_FILPRE + GWF->GWF_NRPREF))
			If GWJ->GWJ_SIT == "3" //Confirmada
				If cMsg == Nil
					Help( ,, 'HELP',, 'Cálculo de frete vinculado a pré-fatura já confirmada.', 1, 0)
				EndIf
				cMsg := 'Cálculo de frete vinculado a pré-fatura já confirmada.'
				Return .F.
			EndIf
			If GWJ->GWJ_SITFIN == "4" //ATUALIZADO
				If cMsg == Nil
					Help( ,, 'HELP',, 'Cálculo de frete vinculado a pré-fatura atualizada no financeiro, não pode ser reajustado.', 1, 0)
				EndIf
				cMsg := 'Cálculo de frete vinculado a pré-fatura atualizada no financeiro, não pode ser reajustado.'
				Return .F.
			EndIf
		EndIf
	EndIf
Return .T.

Function GFEA050EAJ(cJustIfi, cCombo, cMsg, lAjusteMenor,cData,cTime)
	Local xAux    := Nil

	Default cData        := DDATABASE
	Default cTime        := TIME()
	Default lAjusteMenor := .F.
	
	If !GF50VLDAJ(cJustIfi, cCombo,lAjusteMenor,@cMsg) //Validações
		Return .F.
	EndIf

	cTime := SubStr(cTime,1,5)

	GWO->(dbSetOrder(1))
	GWO->(dbSeek(xFilial("GWO") + SubStr(cCombo,10,8) + DToS(cData) + PadR(cTime,Len(GWO->GWO_HRAJUS))))
	Do While GWO->(!Eof()) .And. GWO->GWO_NRCALC == SubStr(cCombo,10,8) .And. GWO->GWO_DTAJUS == cData .And. GWO->GWO_HRAJUS == PadR(cTime,Len(GWO->GWO_HRAJUS))
		xAux := SubStr(cTime,1,2)
		cTime := Val(SubStr(cTime,4,2)) + 1
		If cTime == 60
			xAux := Val(xAux) + 1
			If xAux == 24
				cData++
				cTime := "00:00"
			Else
				cTime := AllTrim(PADL(xAux, 2, "0")) + ":00"
			EndIf
		Else
			cTime := AllTrim(PADL(xAux, 2, "0")) + ":00"
		EndIf
		GWO->(dbSkip())
	EndDo

	//Grava o Ajuste na GWO
	RecLock("GWO",.T.)
		GWO->GWO_FILIAL := GWN->GWN_FILIAL
		GWO->GWO_NRROM  := GWN->GWN_NRROM
		GWO->GWO_DTAJUS := cData
		GWO->GWO_HRAJUS := cTime
		GWO->GWO_USRAJU := cUserName
		GWO->GWO_VLFRET := nVlFrete + nVlTotAj
		GWO->GWO_VLAJUS := nVlAjust
		GWO->GWO_MOTAJU := SubStr(STRTRAN(cJustIfi,CRLF,""),1,254)// Utilizada para não gravar as quebras de linha
		GWO->GWO_SITAJU := "1"
		GWO->GWO_NRCALC := Substring(cCombo,10,8)
	GWO->(MsUnLock())

	nVlAjust := 0   //Zera a Variavel do Valor do Ajuste
	If !lAjusteMenor
		//Chamada da Função para carregar os valores do cálculo
		GFEA050COB(cCombo)
	EndIf
Return .T.

//-----------------------------------------------------
/*
{Protheus.doc}
GFEA50RLMT(cCdMtr,cNumMt)

Função para validação dos campos de motorista do romaneio

@param cCdMtr -> Recebe qual motorista está referenciando (motorista 1, motorista 2)
cNumMt -> Recebe o valor de qual motorista está sendo verIficado.

@author Octávio Augusto Felippe de Macedo
@since 28/12/2010
@version 1.0
*/

Function GFEA50RLMT(cCdMtr, cCdMtr2, cNumMt, lPerg)
	Local cValMtr := IIf(cNumMt == "1", cCdMtr, cCdMtr2)

	If !Empty(cValMtr)
		If !(GFEExistC("GUU",, cValMtr,"GUU->GUU_SIT=='1'"))
			Help( ,, 'HELP',, StrTran(STR0091,"[n]",cNumMt), 1, 0) //"O motorista [n] precisa existir e estar ativo."
			Return .F.
		EndIf

		If cCdMtr == cCdMtr2
			Help( ,, 'HELP',, STR0093, 1, 0) //"Os motoristas não podem ser iguais."
			Return .F.
		EndIf
	EndIf
Return .T.

//----------------------------------------------------------
/*
{Protheus.doc}
GFEA50PLC(cPlaca,cTpPlc)

Função para verIficar a integridade das placas dianteira, traseira e meio.

@param cPlaca -> Recebe o valor da placa digitada
cTpPlc -> Recebe qual é a placa que está sendo verIficada.

@author Octávio Augusto Felippe de Macedo
@since 28/12/2010
@version 1.0
*/

Function GFEA50PLC(cPlacaD, cPlacaT, cPlacaM, cTpPlc, lPerg, cRomaneio)
	Local lValPlc
	Local cCdTpVc

	If cTpPlc == "D"
		lValPlc := cPlacaD
	ElseIf cTpPlc == "T"
		lValPlc := cPlacaT
	ElseIf cTpPlc == "M"
		lValPlc := cPlacaM
	EndIf

	IIf(lPerg, cCdTpVc := Posicione("GWN", 1, xFilial("GWN") + cRomaneio, "GWN_CDTPVC"), cCdTpVc := FwFldGet('GWN_CDTPVC'))

	If !Empty(lValPlc)
		If !GFEExistC("GU8", 2, lValPlc, "GU8->GU8_SIT=='1'")
			Help(,, 'HELP',, STR0094, 1, 0) //A placa do veículo deve existir e estar ativa.
			Return .F.
		EndIf

		If cTpPlc == "D"
			If cPlacaD == cPlacaT
				Help(,, 'HELP',, STR0095, 1, 0,) //A placa dianteira não pode ser igual a placa traseira.
				Return .F.
			EndIf

			If cPlacaD == cPlacaM
				Help(,, 'HELP',, STR0096, 1, 0,) //A placa dianteira não pode ser igual a placa do meio.
				Return .F.
			EndIf
		ElseIf cTpPlc == "T"
			If cPlacaT == cPlacaM
				Help(,, 'HELP',, STR0097, 1, 0,) //A placa traseira não pode ser igual a placa do meio.
				Return .F.
			EndIf

			If cPlacaT == cPlacaD
				Help(,, 'HELP',, STR0098, 1, 0,) //A placa traseira não pode ser igual a placa dianteira.
				Return .F.
			EndIf

		ElseIf cTpPlc == "M"
			If cPlacaM == cPlacaT
				Help(,, 'HELP',, STR0099, 1, 0,) //A placa do meio não pode ser igual a placa traseira.
				Return .F.
			EndIf

			If cPlacaM == cPlacaD
				Help(,, 'HELP',, STR0100, 1, 0,) //A placa do meio não pode ser igual a placa dianteira.
				Return .F.
			EndIf

		EndIf

		GU8->(dbSetOrder(2))
		If cTpPlc == "D"
			If GU8->(dbSeek(xFilial('GU8') + cPlacaD))
				GV3->(dbSetOrder(1))
				If GV3->(dbSeek(xFilial('GV3') + GU8->GU8_CDTPVC))
					If GV3->GV3_POSCOM <> "1"
						Help( ,, 'HELP',, STR0047, 1, 0,) //"Placa dianteira deve ser de veículo principal"
						Return .F.
					EndIf

					If !Empty(cCdTpVc) .AND. cCdTpVc <> GV3->GV3_CDTPVC
						Help( ,, 'HELP',, STR0048, 1, 0,) //"Tipo de veículo do romaneio dIferente do veículo principal"
						Return .F.
					EndIf
				EndIf
			EndIf
		Else
			If GU8->(dbSeek(xFilial('GU8') + lValPlc))
				GV3->( dbSetOrder(1) )
				If GV3->(dbSeek(xFilial('GV3')+GU8->GU8_CDTPVC))
					If GV3->GV3_POSCOM <> "2"
						Help( ,, 'HELP',, If(cTpPlc=="T",STR0049,STR0050), 1, 0,) //"Placa traseira deve ser do tipo reboque"
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

/*
{Protheus.doc}
GFEA50TPVC(cTpVc)

Função para verificar a integridade do campo do tipo do veículo.

@param cTpVc -> Recebe o valor do tipo de veículo

@author Octávio Augusto Felippe de Macedo
@since 28/12/2010
@version 1.0
*/

Function GFEA50TPVC(cTpVc)

	If AllTrim(cTpVc) != ""
		If !GFEExistC("GV3",, M->GWN_CDTPVC, "GV3->GV3_SIT=='1'")
			Help(,, 'HELP',, STR0101, 1, 0,) //O tipo de veículo deve existir e estar ativo.
			Return .F.
		EndIf

		If !IsInCallStack("GFEX010") .And. AllTrim(FwFldGet('GWN_PLACAD')) != ""
			GU8->(dbSetOrder(2))
			If GU8->(dbSeek(xFilial('GU8') + FwFldGet('GWN_PLACAD')))
				GV3->(dbSetOrder(1))
				If GV3->(dbSeek(xFilial('GV3') + GU8->GU8_CDTPVC))
					If cTpVc <> GV3->GV3_CDTPVC
						Help(,, 'HELP',, STR0048, 1, 0,) //"Tipo de veículo do romaneio dIferente do veículo principal"
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

/*
{Protheus.doc}
GFEA50TRPL()

Função para filtrar os registros na consulta de placas

@author Octávio Augusto Felippe de Macedo
@since 19/01/2011
@version 1.0
*/
Function GFEA50TRPL()
Return .T. //(GU8->GU8_SIT == "1" .AND. (Empty(GU8->GU8_CDPROP) .OR. Empty(M->GWN_CDTRP) .OR. M->GWN_CDTRP == GU8->GU8_CDPROP))

/*{Protheus.doc} GFEA50TRMT

Função utilizada pela consulta padrão de motoristas (GUUMTR) para filtrá-los.

@author Octávio Augusto Felippe de Macedo
@since 05/03/2012
@version 1.0
*/

Function GFEA50TRMT()
Return (GUU->GUU_SIT=="1" .AND. (Empty(GUU->GUU_CDTRP) .OR. Empty(M->GWN_CDTRP) .OR. M->GWN_CDTRP==GUU->GUU_CDTRP))

//---------------------------------------------------------

Function GFEA50TPLP()
Return (GU8->GU8_SIT=="1" .AND. (Empty(GU8->GU8_CDPROP) .OR. Empty(Posicione("GWN", 1, xFilial("GWN")+MV_PAR02, "GWN_CDTRP")) .OR. Posicione("GWN", 1, xFilial("GWN")+MV_PAR02, "GWN_CDTRP")==GU8->GU8_CDPROP))

//----------------------------------------------------------
/*
{Protheus.doc}
GFEA050EAI()

Função de recebimento do XML do EAI
Trata os campos a3ntes de validar no Model

@author Israel A Possoli
@since 30/06/2011
@version 1.0
*/
//----------------------------------------------------------
Function GFEA050EAI(oModel, cXML)
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local aAreaGWN := GWN->( GetArea() )

	If !Empty( cError )
		Return NIL
	EndIf

	cNrRom := PadR( oXML:_GFEA050:_GFEA050_GWN:_GWN_NRROM:_VALUE:TEXT, TamSX3("GWN_NRROM")[1] )
	GWN->(dbSetOrder(1))

	If oModel:GetOperation() == MODEL_OPERATION_DELETE .AND. GWN->(dbSeek(xFilial("GWN")+cNrRom))
		Return .T.
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. GWN->(dbSeek(xFilial("GWN")+cNrRom))
		oModel:SetErrorMessage(,,,,,"Já existe um Embarque cadastrado com a chave informada")
		Return .F.
	EndIf

	If Empty(GetNewPar('MV_TPOPEMB'))
		oModel:SetErrorMessage(,,,,,"Parâmetro MV_TPOPEMB não possui valor")
		Return .F.
	EndIf

	oModel:GetModel("GFEA050_GWN"):LoadValue("GWN_CDTPOP",GetNewPar('MV_TPOPEMB'))

	RestArea(aAreaGWN)
Return .T.

/*
{Protheus.doc}
GFEA050INF()

Função para mostrar informações de romaneio e gravação de código de rastreamento.

@author Lidiomar Fernando dos Santos Machado
@since 10/10/2012
@version 1.0
*/

Function GFEA050INF()
	Local aFields := {"GWN_NRROM", "GWN_CDTRP", "GWN_DSTRP", "GWN_RASTR", "NOUSER"}
	Local oSize   := Nil

	If GWN->GWN_SIT != "3"
		Help( ,, 'HELP',, STR0017, 1, 0,) //"Romaneio não está liberado"
		Return .F.
	EndIf

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 20, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 300, 600})
	oSize:lLateral     := .F.  // Calculo vertical
	oSize:Process() //executa os calculos

	DEFINE MSDIALOG oDlg TITLE "Informação de rastreamento";
		FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
		TO oSize:aWindSize[3],oSize:aWindSize[4] ;
		PIXEL OF oMainWnd

	RegToMemory("GWN", .F.)

	oComp := MsmGet():New("GWN",, MODEL_OPERATION_UPDATE,,,, aFields,{100, 20,,},{"GWN_RASTR"},;
		,,,, oDlg,,.T.,.T.,,.T.,,,,,,)

	oComp:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIf(GFEA050RAS(), oDlg:End(), Nil)}, ;
		{|| oDlg:End()},, {}) CENTERED

Return .T.

/*
{Protheus.doc}
GFEA050RAS()

Função para de update de código de rastreamento do romaneio de carga.

@author Lidiomar Fernando dos Santos Machado
@since 10/10/2012
@version 1.0
*/
Function GFEA050RAS()
	RecLock("GWN", .F.)
	GWN->GWN_RASTR := M->GWN_RASTR
	GWN->(MsUnlock())
Return .T.
/*
{Protheus.doc}
GFEA050CID()

Função do gatilho do campo GWN_CEPD
Retorna a primeira cidade encontrada, que tenha o CEP informado dentro de sua faixa.

@author Lidiomar Fernando dos Santos Machado
@since 25/02/2013
@version 1.0
*/

Function GFEA050CID()
	Local cRet := ""

	If !Empty(M->GWN_CEPD)
		GU7->(dbSetFilter({|| VAL(GU7->GU7_CEPINI) <= VAL(M->GWN_CEPD) .AND. VAL(GU7->GU7_CEPFIM) >= VAL(M->GWN_CEPD) .AND. !Empty(GU7->GU7_CEPINI) .AND. !Empty(GU7->GU7_CEPFIM) }, ""))
		GU7->(dbSetOrder(1))
		GU7->(dbGoTop())
		If GU7->(dbSeek(xFilial("GU7")))
			cRet := GU7->GU7_NRCID
		EndIf
		GU7->(dbClearFilter())
	EndIf
Return cRet
/*
{Protheus.doc}
GFEA050UNQ()

Função de validacao da chave do romaneio quando tentativo de inclusão pelo ERP

@author Felipe Machado de Oliveira
@since 21/06/2013
@version 1.0
*/
Function GFEA050UNQ()
	Local lRet     := .T.
	Local aAreaGWN := GWN->( GetArea() )

	If FwFldGet("GWN_ORI") == "2" //Origem ERP
		GWN->( dbSetOrder(1))
		GWN->( dbSeek( xFilial("GWN")+FwFldGet("GWN_NRROM")))
		If GWN->(!Eof()) .And. GWN->GWN_FILIAL == xFilial("GWN") .And. GWN->GWN_NRROM == FwFldGet("GWN_NRROM")
			Help( ,, 'HELP',, "Já existe um Romaneio com a chave informada.", 1, 0,)
			lRet := .F.
		EndIf
	EndIf
	RestArea( aAreaGWN )
Return lRet

/*
Função que libera um romaneio, se estiver parametrizado em seu tipo de operação
*/
Function GFE50LbRom()
	Local lRet 	     := .F.
	Local aAreaGWN   := GWN->(GetArea())
	Local aAreaGW1   := GW1->(GetArea())
	Local cNrRom     := GWN->GWN_FILIAL + GWN->GWN_NRROM
	Local dDataMaior := Nil
	Local cHoraMaior := ""

	_lSemHelp := .T.

	//Ao vincular romaneio, preencher dt e hr de saida do romaneio com maior data de seus documentos
	//chamando a rotina padrão de liberação

	GW1->(dbSetOrder(9))
	GW1->(dbSeek(cNrRom))
	If GFEVerCmpo({"GV4_LBRMAT"}) .And. Posicione("GV4",1,xFilial("GV4") + GWN->GWN_CDTPOP,"GV4_LBRMAT") $ "1;2"
		dDataMaior := GW1->GW1_DTEMIS
		cHoraMaior := Time()

		Do While GW1->(!Eof()) .And. GW1->GW1_FILIAL + GW1->GW1_NRROM == cNrRom
			If dDataMaior < GW1->GW1_DTEMIS
				dDataMaior := GW1->GW1_DTEMIS
				cHoraMaior := Time()
			EndIF
			GW1->(dbSkip())
		EndDo
		If GV4->GV4_LBRMAT == '2' .And. GWN->GWN_DTIMPL > dDataMaior
			dDataMaior := GWN->GWN_DTIMPL
			cHoraMaior := Time()
		EndIf
		RestArea(aAreaGW1)
		lRet := GFEA050LIB(.T.,,dDataMaior,cHoraMaior)
	EndIf
	RestArea(aAreaGWN)
	RestArea(aAreaGW1)
Return lRet

/*/{Protheus.doc} GFE50CDOP

@author siegklenes.beulke
@since 10/09/2013
@version 1.0

@description
Uso do dicionário
Verifica o valor padrão GWN_VPCDOP

@example

GFE50CDOP()

/*/

Function GFE50CDOP()
	Local cRet := ""
	Local cGv4 := ""

	If !Empty(M->GWN_CDTPOP)
		cGv4:= Posicione("GV4",1,xFilial("GV4") + M->GWN_CDTPOP,"GV4_PEDAG")
		If !Empty(cGv4) .And. cGv4 != "1" .And. !Empty(M->GWN_CDTRP) .And. Posicione("GU3",1,xFilial("GU3") + M->GWN_CDTRP,"GU3_VALEP") == "1"
			GU3->(dbSetOrder(1))
			If GU3->(dbSeek(xFilial("GU3") + SuperGetMV("MV_GFEOVP",.F.,""))) .And. GU3->GU3_SIT == "1" .And. GU3->GU3_FORN == "1"
				cRet := GU3->GU3_CDEMIT
			EndIf
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} GFE50VERVP

@author siegklenes.beulke
@since 10/09/2013
@version 1.0

@description
Uso do dicionário
Bloqueia a edição dos campos vale pedágio se o transportador não receber o vale pedágio

@example

lRet := GFE50VERVP()

/*/

Function GFE50VERVP()
	Local lRet   := .T.
	Local oModel := FWModelActive()
	If IsInCallStack("GFEX300")
		If !Empty(oModel:GetValue("GWN_CDTRP")) ;
				.And. (Posicione("GU3",1,xFilial("GU3") + oModel:GetValue("GWN_CDTRP"),"GU3_VALEP" ) $ " 2";
				.Or. Posicione("GV4",1,xFilial("GV4") + oModel:GetValue("GWN_CDTPOP"),"GV4_PEDAG") $ " 1")

			lRet := .F.
		EndIf
	Else
		If !Empty(oModel:GetValue("GFEA050_GWN","GWN_CDTRP")) ;
				.And. (Posicione("GU3",1,xFilial("GU3") + oModel:GetValue("GFEA050_GWN","GWN_CDTRP"),"GU3_VALEP" ) $ " 2";
				.Or. Posicione("GV4",1,xFilial("GV4") + oModel:GetValue("GFEA050_GWN","GWN_CDTPOP"),"GV4_PEDAG") $ " 1")

			lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} GFE50VALVP()

@author siegklenes.beulke
@since 10/09/2013
@version 1.0

@description

Função que verifica se o vale pedagio impede a gravação dos dados

@example

lRet := GFE50VALVP(cTipoOp, nVpValor)

/*/
Function GFE50VALVP(cTipoOp, nVpValor,cTransp,cMsg)
	Default cTipoOp  := Space(TamSx3("GWN_CDTPOP")[1])
	Default nVpValor := 0
	Default cTransp  := Space(TamSx3("GWN_CDTRP")[1])

	If GfeVerCmpo({'GU3_VALEP'})
		If Posicione("GU3",1,xFilial("GU3") + cTransp,"GU3_VALEP") == "1" ;
				.And. Posicione("GV4",1,xFilial("GV4") + cTipoOp,"GV4_PEDAG") == "3";
				.And. (Empty(nVpValor) .OR. nVpValor <= 0)

			If Type("_lSemHelp") == "U" // Definir varivel " Private _lSemHelp := .F.", varivel foi declarada nas funções GFEA050LIBL() e  GFEA081.CalculaRomaneios()
				Help(,,'HELP',,"O Tipo de Operação determina que o Valor do pedágio é obrigatório",1,0,)
			EndIf
			cMsg := "O Tipo de Operação determina que o Valor do pedágio é obrigatório"
			Return .F.
		EndIf
	EndIf
Return .T.

//Valida o carregamento da tela de negociação

Function GFE50VERNG(oModel)

	If cValToChar(oModel:GetOperation()) $ '25'
		Help(,,'HELP',,"Esta ação não está disponível durante a visualização ou exclusão de um registro",1,0)
		Return
	EndIf
	GFEA50NEG(oModel:GetValue("GFEA050_GWN","GWN_CDTRP"),"GFE50GRNEG",oModel)
Return

/*/{Protheus.doc} GFEA50NEG

Lista Tipos de Operação, classificação de frete e tipo de veículo com negociações vigentes
através de um MsSelect
@author siegklenes.beulke
@param cCDTRP, código transportadora
@param 	uRetorno, string ou bloco de código com a função que irá gravar os dados,;
recebe como parametro um array [1]:= tipo de operação ,[2]:= Classificação de frete ,[3]código tipo de veículo;
[GV9_CDTPOP,GV9_CDCLFR,GV7_CDTPVC]
@param 	oModel , uso restrito GFE50GRNEG que trabalha com o Model GFEA50
@since 13/09/2013
@version 1.0

/*/

Function GFEA50NEG(cCDTRP, uRetorno, oModel)
	Local oDlg   := Nil
	Local nAlt   := (GetScreenRes()[2])
	Local nLrg   := (GetScreenRes()[1]-100)
	Local aMKB   := {}
	Local aCpMKB := {}
	Local oMark  := Nil

	Private cAliMKB
	Private cCadastro := "Negociações Vigentes"
	Private cMarca    := GetMark()
	Private _uRetorno := uRetorno
	Private aRetorno  := {}
	Private oMod      := oModel
	Private cTransp   := cCDTRP

	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------

	aMKB :=    {{"OK"       	,"C",02,0},;
		{"GV9_CDTPOP" ,"C",TamSx3("GV9_CDTPOP")[1],0},;
		{"GV4_DSTPOP"	,"C",TamSx3("GV4_DSTPOP")[1],0},;
		{"GV9_CDCLFR" ,"C",TamSx3("GV9_CDCLFR")[1],0},;
		{"GUB_DSCLFR" 	,"C",TamSx3("GUB_DSCLFR")[1],0},;
		{"GV7_CDTPVC" ,"C",TamSx3("GV7_CDTPVC")[1],0},;
		{"GV3_DSTPVC" ,"C",TamSx3("GV3_DSTPVC")[1],0},;
		{"GV9_NRTAB"  ,"C",TamSx3("GV9_NRTAB")[1],0},;
		{"GV9_NRNEG" 	,"C",TamSx3("GV9_NRNEG")[1],0}}

	aCpMKB  := {{"OK"        	,NIL,"",""},;
		{"GV9_CDTPOP" ,NIL,"Código do Tipo de Operação","@!"},;
		{"GV4_DSTPOP" ,NIL,"Descrição do Tipo de Operação","@!"},;
		{"GV9_CDCLFR" ,NIL,"Código da Classificação de Frete","@!"},;
		{"GUB_DSCLFR" ,NIL,"Descrição da Classificação de Frete","@!"},;
		{"GV7_CDTPVC" ,NIL,"Código do Tipo de Veículo","@!"},;
		{"GV3_DSTPVC" ,NIL,"Descrição do Tipo de Veículo","@!"},;
		{"GV9_NRTAB"  ,NIL,"Número da Tabela de Frete","@!"},;
		{"GV9_NRNEG"	,NIL,"Número da Negociação","@!"}}

	// o segundo indice facilita a busca por registro marcados
	cAliMKB := GFECriaTab({aMKB,{"GV9_NRTAB+GV9_NRNEG+GV7_CDTPVC","OK"}})

	CursorWait()

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	(cAliMKB)->(dbSetOrder(1))
	(cAliMKB)->(dbGoTop())

	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlB)
	oMark:oBrowse:bLDblClick := { || GFE50CHK() }
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Processa({|lEnd| GFE50NGCRG(cTransp)},"Processando informações","Aguarde")

	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(Len(aRetorno:=GFE50NEGOK())>0,GFE50NGEND(oDlg),NIL)},;
		{||ODlg:End()},,) CENTERED

	GFEDelTab(cAliMKB)
Return

/*/{Protheus.doc} GFE50NGCRG

@author siegklenes.beulke
@since 13/09/2013
@version 1.0

@description

Carrega a tabela temporaria cAliMKB usada no MarkBrowse
Uso GFEA50NEG

@example

GFE50NGCRG()

/*/
Static Function GFE50NGCRG(cCdTrp)
	Local aAreaGV9 := GV9->(GetArea())
	Local aAreaGV7 := GV7->(GetArea())

	GV4->(dbSetOrder(1))
	GUB->(dbSetOrder(1))
	GV7->(dbSetOrder(2))
	GV9->(dbSetOrder(1))

	If !Empty(cCdTrp)
		GV9->(dbSeek(xFilial("GV9")  + cCdTrp))
	EndIf

	Do While GV9->(!Eof()) .And. GV9->GV9_FILIAL == xFilial("GV9") .And. GV9->GV9_CDEMIT ==  cCdTrp
		If  GV9->GV9_SIT == "2" .And. DTOS(GV9->GV9_DTVALI) <= DTOS(Date()) .And. (DTOS(GV9->GV9_DTVALF) >= DTOS(Date()) .OR. Empty(GV9->GV9_DTVALF))
			RecLock(cAliMKB,.T.)
			(cAliMKB)->GV9_CDTPOP := GV9->GV9_CDTPOP
			If !Empty(GV9->GV9_CDTPOP)
				(cAliMKB)->GV4_DSTPOP := Posicione("GV4",1,xFilial("GV4") + GV9->GV9_CDTPOP, "GV4_DSTPOP")
			EndIf
			(cAliMKB)->GV9_CDCLFR := GV9->GV9_CDCLFR
			If !Empty(GV9->GV9_CDCLFR)
				(cAliMKB)->GUB_DSCLFR := Posicione("GUB",1,xFilial("GUB") + GV9->GV9_CDCLFR, "GUB_DSCLFR")
			EndIf
			(cAliMKB)->GV9_NRTAB  := GV9->GV9_NRTAB
			(cAliMKB)->GV9_NRNEG  := GV9->GV9_NRNEG
			If GV7->( dbSeek( xFilial("GV7") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG ) )
				(cAliMKB)->GV7_CDTPVC := GV7->GV7_CDTPVC
				If !Empty(GV7->GV7_CDTPVC)
					(cAliMKB)->GV3_DSTPVC := Posicione("GV3",1,xFilial("GV7") + GV7->GV7_CDTPVC, "GV3_DSTPVC")
				EndIf
			EndIF
			(cAliMKB)->(MsUnlock())

			GV7->(dbSkip())
			Do While GV7->(!Eof()) .And. xFilial("GV7") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG == xFilial("GV7") + GV7->GV7_CDEMIT + GV7->GV7_NRTAB + GV7->GV7_NRNEG
				RecLock(cAliMKB,.T.)
				(cAliMKB)->GV9_CDTPOP := GV9->GV9_CDTPOP
				If !Empty(GV9->GV9_CDTPOP)
					(cAliMKB)->GV4_DSTPOP := Posicione("GV4",1,xFilial("GV4") + GV9->GV9_CDTPOP, "GV4_DSTPOP")
				EndIf
				(cAliMKB)->GV9_CDCLFR := GV9->GV9_CDCLFR
				If !Empty(GV9->GV9_CDCLFR)
					(cAliMKB)->GUB_DSCLFR := Posicione("GUB",1,xFilial("GUB") + GV9->GV9_CDCLFR, "GUB_DSCLFR")
				EndIf
				(cAliMKB)->GV9_NRTAB  := GV9->GV9_NRTAB
				(cAliMKB)->GV9_NRNEG  := GV9->GV9_NRNEG
				(cAliMKB)->GV7_CDTPVC := GV7->GV7_CDTPVC
				If !Empty(GV7->GV7_CDTPVC)
					(cAliMKB)->GV3_DSTPVC := Posicione("GV3",1,xFilial("GV7") + GV7->GV7_CDTPVC, "GV3_DSTPVC")
				EndIf
				(cAliMKB)->(MsUnlock())
				GV7->(dbSkip())
			Enddo
		EndIF
		GV9->(dbSkip())
	EndDo
	(cAliMKB)->(dbGoTop())
	RestArea(aAreaGV7)
	RestArea(aAreaGV9)
Return
/*/{Protheus.doc} GFE50CHK

@author siegklenes.beulke
@since 13/09/2013
@version 1.0

@description

Realiza a marcação de um registro na tabela temporária
Uso em GFEA50NEG

@example

GFE50CHK()

/*/
Static Function GFE50CHK()
	Local nMark := 0
	Local aArea := (cAliMKB)->(GetArea())

	(cAliMKB)->(dbSetOrder(2))
	(cAliMKB)->(dbSeek(cMarca))
	Do While (cAliMKB)->(!Eof()) .And. nMark <= 1
		If IsMark('OK',cMarca)
			nMark++
		EndIf
		(cAliMKB)->(dbSkip())
	EndDo
	RestArea(aArea)
	If nMark == 1 .And. !IsMark('OK',cMarca)
		Help(,,'HELP',, "Somente um registro pode estar selecionado", 1, 0)
		lRet := .F.
	Else
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		(cAliMKB)->(MsUnLock())
	EndIf
Return

/*/{Protheus.doc} GFE50NEGOK

@author siegklenes.beulke
@since 13/09/2013
@version 1.0

@description

Retorna um array com as informações de tipo de operação, classificação de frete e código do tipo de veiculo

@example

aRet := GFE50NEGOK() // [GV9_CDTPOP,GV9_CDTPOP,GV7_CDTPVC]

/*/

Static Function GFE50NEGOK()
	Local lRet     := .T.
	Local nMark    := 0
	Local aAreaMKB := (cAliMKB)->(GetArea())

	(cAliMKB)->(dbSetOrder(2))
	(cAliMKB)->(dbSeek(cMarca))
	Do While (cAliMKB)->(!Eof()) .And. nMark <= 1
		If IsMark('OK',cMarca)
			nMark++
			Exit
		EndIf
		(cAliMKB)->(dbSkip())
	EndDo

	If nMark == 0
		Help(,,'HELP',, "É necessário selecionar ao menos um registro", 1, 0)
		lRet := .F.
	EndIF

	If lRet
		(cAliMKB)->(dbSeek(cMarca))
		If (cAliMKB)->(!Eof())
			aAdd(aRetorno,(cAliMKB)->GV9_CDTPOP)
			aAdd(aRetorno,(cAliMKB)->GV9_CDCLFR)
			aAdd(aRetorno,(cAliMKB)->GV7_CDTPVC)
		EndIf
	EndIf
	RestArea(aAreaMKB)
Return aRetorno

// Função que avalia um bloco de código ou uma string com nome de função e executa

Static Function GFE50NGEND(oDlg)
	If Type("_uRetorno") == "C"
		&(_uRetorno+"(aRetorno)")
	ElseIf Type("_uRetorno") == "B"
		Eval(_uRetorno,aRetorno)
	EndIf
	GfeDelTab(cAliMKB)
	oDlg:End()
Return

// Função que grava no model ativo as alterações

Function GFE50GRNEG(aRet)
	Local oModel := FWModelActive()
	Local oView  := FWViewActive()

	oModel:LoadValue("GFEA050_GWN","GWN_CDTPOP",aRet[1])
	oModel:LoadValue("GFEA050_GWN","GWN_CDCLFR",aRet[2])
	oModel:LoadValue("GFEA050_GWN","GWN_CDTPVC",aRet[3])

	oMod:LMODIFY :=.T.
	oView:Refresh()
Return

// Efetua o retorno de um romaneio de frota dedica
Function GFEA050RET()
	Local dDataRet
	Local cHoraRet
	Local cPicHodRet := Alltrim(GetSx3Cache("GWN_HODRET", "X3_PICTURE"))

	If Empty(GWN->GWN_DTSAI) .OR. Empty(GWN->GWN_HRSAI)
		HELP(,,'HELP',, "Necessário preencher a data e hora de saída do Romaneio.",1,0)
		Return .F.
	EndIf

	dDataRet := GWN->GWN_DTRET
	cHoraRet := GWN->GWN_HRRET
	nHod     := GWN->GWN_HODRET

	If Empty(dDataRet)
		dDataRet:= Date()
	EndIf

	If Empty(cHoraRet)
		cHoraRet:= SubStr(Time(),1,5)
	EndIf

	DEFINE MSDIALOG oDlgRet TITLE "Informar o Retorno" From 4,0 To 13,34 OF oMainWnd //"Liberar"

	@  4, 006  SAY "Data do Retorno" SIZE 70,7 PIXEL OF oDlgRet //"Romaneio:"
	@ 19, 006  SAY "Hora do Retorno" SIZE 70,7 PIXEL OF oDlgRet //"Data de Saída:"
	@ 34, 006  SAY "Hodômetro Retorno" SIZE 70,7 PIXEL OF oDlgRet //"Hora de Saída:"

	@  3, 060  MSGET dDataRet  When .T. PICTURE "99/99/9999" SIZE 45,7 PIXEL OF oDlgRet hasbutton Valid GFEVLDATE(dDataRet)
	@ 18, 060  MSGET cHoraRet  When .T. PICTURE "@R 99:99" SIZE 15,7 PIXEL OF oDlgRet Valid GFEVLDHR(cHoraRet)
	@ 33, 060  MSGET nHod	   When .T. PICTURE cPicHodRet SIZE 15,7 PIXEL OF oDlgRet

	TButton():New( 50, 5, "OK", oDlgRet,{||If (GFE50GRAVR(dDataRet,cHoraRet,nHod),oDlgRet:End(),Nil)},;
		25, 10,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New( 50, 35, "Cancelar", oDlgRet,{||oDlgRet:End()},25, 10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

	ACTIVATE MSDIALOG oDlgRet CENTERED
Return

Function GFE50GRAVR(cDataRet,cHoraRet,nHod)
	Local lRet    := .T.
	Local nDistan := 0
	Local lPE15		:= ExistBlock("GFE05015")
	Local lPE16		:= ExistBlock("GFE05016")

	If !Empty(GWN->GWN_DTSAI) .AND. !Empty(cDataRet) .AND. DTOS(GWN->GWN_DTSAI)>= DTOS(cDataRet)
		If !Empty(GWN->GWN_HRSAI) .AND. !Empty(cHoraRet) .AND. StrTran(GWN->GWN_HRSAI,":") > cHoraRet
			HELP(,,"HELP",,"Data/Hora de Retorno não pode ser menor que a Data de Saída (" + DTOC(GWN->GWN_DTSAI) + " " + GWN->GWN_HRSAI +  ")",1,0)
			lRet:= .F.
		ElseIf DTOS(GWN->GWN_DTSAI)> DTOS(cDataRet)
			HELP(,,"HELP",,"Data de Retorno não pode ser menor que a Data de Saída (" + DTOC(GWN->GWN_DTSAI) + ")",1,0)
			lRet := .F.
		EndIf
	ElseIf !Empty(cDataRet) .AND. Empty(cHoraRet)
		HELP(,,"HELP",,"Hora de Retorno deve estar preenchido caso a Data de Retorno esteja.",1,0)
		lRet:= .F.
	EndIf

	If GWN->GWN_HODSAI > nHod
		HELP(,,"HELP",,"Valor do hodômetro de retorno deve ser maior do que hodômetro de saída.",1,0)
		lRet:= .F.
	EndIf

	If lPE15
		aRet := ExecBlock("GFE05015",.F.,.F., {GWN->GWN_FILIAL, GWN->GWN_NRROM, cDataRet, cHoraRet, nHod})
		If ValType(aRet) == "A" .and. !Empty(aRet)
			If !aRet[1]
				lRet :=  aRet[1]
				HELP(,,"HELP",,aRet[2],1,0)
			EndIf
		EndIf
	Endif

	If lRet
		nDistan := GFEDISTAN(nHod,GWN_HODSAI)

		Reclock("GWN",.F.)
		GWN->GWN_DTRET 	:= cDataRet
		GWN->GWN_HRRET 	:= cHoraRet
		GWN->GWN_HODRET	:= nHod
		GWN->GWN_DSREAL := nDistan
		GWN->(MsUnlock())

		MSGINFO("Informações gravadas com sucesso!")
	EndIf

	If lPE16
		ExecBlock("GFE05016",.F.,.F., )
	EndIf

Return lRet

/*/{Protheus.doc} GFEA050EXPer

@author Alexandre José Cuchi
@since 28/03/2014
@version 1.0

@description

Função para verificar a existencia de grupo de perguntas ou existencia de pergunta, retorna .T. caso encontre o grupo, se não retorna .F.

@Param

cGrupo := Nome do grupo de perguntas, Tipo Caracter

cOrdem := Ordem do pergunte pesquisado

cPergunta := nome do campo do pergunte para ser comparado

lRet := retorna .T. caso encontre o registro procurado.

@example

If GFEA050EXPer("GFEA000",'01',"Filial ?")
EndIf
/*/

Function GFEA050ExPer(cGrupo,cOrdem,cPergunta) // Função verifica a existencia do pergunte
	Local   AreaSX1   := SX1->(GetArea())
	Local   lRet      := .F.
	Default cPergunta := ""
	Default cOrdem    := ""

	dbSelectArea("SX1")
	SX1->( dbSetOrder(1) )

	If SX1->( dbSeek( PadR(cGrupo,10) + cOrdem ) )
		If Empty(cPergunta)
			lRet := .T.
		Else
			If AllTrim( X1Pergunt() ) == AllTrim( cPergunta )
				lRet := .T.
			EndIf
		EndIf
	EndIf
	RestArea(AreaSX1)
Return lRet

Static Function ParamF12()
	If Pergunte("GFEA050F12", .T.)
		cParamF12 := MV_PAR01
	EndIf
Return

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA50ACT
Função chamada após a ativação do Model

@sample
GFEA50ACT(oModel)

@author Lucas Manolli de Oliveira Cristo
@since 14/08/2014
@version 1.0
--------------------------------------------------------------------------------------------------*/

Function GFEA50ACT(oModel)
	Local oModelGWN := oModel:GetModel("GFEA050_GWN")
	Local aFieldGWN := oModelGWN:GetStruct():aFields
	Local nI        := 0
	Local nF        := 0
	//Neste array contem os campos que será copiado do romaneio pai - caso necessite que um campo seja limpado é so retira-lo deste array
	Local aCmpGWN   := {"GWN_FILIAL",;
						"GWN_NRROM",;
						"GWN_CDTPOP",;
						"GWN_CDCLFR",;
						"GWN_CDTRP",;
						"GWN_CDMTR",;
						"GWN_CDMTR2",;
						"GWN_CDTPVC",;
						"GWN_PLACAD",;
						"GWN_PLACAT",;
						"GWN_PLACAM",;
						"GWN_SIT",;
						"GWN_DTIMPL",;
						"GWN_HRIMPL",;
						"GWN_CALC",;
						"GWN_USUIMP",;
						"GWN_ORI",;
						"GWN_PRIOR",;
						"GWN_DISTAN",;
						"GWN_NRCIDD",;
						"GWN_NMCIDD",;
						"GWN_CEPD", ;
						"GWN_BLOQPF",;
						"GWN_OBS",  ;
						"GWN_MTCALC",;
						"GWN_RASTR",  ;
						"GWN_DTRET", ;
						"GWN_HRRET", ;
						"GWN_HODSAI", ;
						"GWN_HODRET", ;
						"GWN_FECHAM", ;
						"GWN_DTFECH", ;
						"GWN_NRCIDO", ;
						"GWN_NMCIDO", ;
						"GWN_CEPO", ;
						"GWN_MOTREA",;
						"GWN_DTREAB", ;
						"GWN_HRREAB", ;
						"GWN_DSREAL",;
						"GWN_VPNMOP",;
						"GWN_DSCLFR",;
						"GWN_USUREA"}

	If IsInCallStack("GFEA050") .AND. lCopy
		nF := Len(aFieldGWN)
		For nI := 1 To nF
			If aFieldGWN[nI][3] == "GWN_SIT"
				oModelGWN:SetValue(aFieldGWN[nI][3], "1")
			ElseIf aFieldGWN[nI][3] == "GWN_FILIAL"
				oModelGWN:SetValue(aFieldGWN[nI][3], xFilial())
			ElseIf aFieldGWN[nI][3] == "GWN_NRROM"
				// necesario deixar assim somente para startar o getxnum do dicionario
			ElseIf aFieldGWN[nI][3] == "GWN_CALC"
				oModelGWN:SetValue(aFieldGWN[nI][3], "2")
			ElseIf aFieldGWN[nI][3] == "GWN_USUIMP"
				oModelGWN:SetValue(aFieldGWN[nI][3], cUserName)
			ElseIf aFieldGWN[nI][3] == "GWN_AGRUP"
				oModelGWN:SetValue(aFieldGWN[nI][3], "2")
			ElseIf aFieldGWN[nI][3] == "GWN_DTIMPL"
				oModelGWN:SetValue(aFieldGWN[nI][3], Date())
			ElseIf aFieldGWN[nI][3] == "GWN_ORI"
				oModelGWN:SetValue(aFieldGWN[nI][3], "1")
			ElseIf aFieldGWN[nI][3] == "GWN_HRIMPL"
				oModelGWN:SetValue(aFieldGWN[nI][3], SUBSTR(TIME(), 1, 2)+":"+SUBSTR(TIME(), 4, 2))
			ElseIf aFieldGWN[nI][14]
				Loop
			ElseIf aScan( aCmpGWN, {|x| x == aFieldGWN[nI][3] } ) > 0
				oModelGWN:SetValue(aFieldGWN[nI][3], &("GWN->"+aFieldGWN[nI][3]))
			Else
				oModel:ClearField("GFEA050_GWN", aFieldGWN[nI][3])
			EndIf
		Next nI
		lCopy := .F.
	EndIf
Return Nil

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA44COPY
Rotina que executa a view quando for cópia do Romaneio

@sample
GFEA50COPY()

@author Lucas Manolli de Oliveira Cristo
@since 06/08/2014
@version 1.0
--------------------------------------------------------------------------------------------------*/

Function GFEA50COPY()

	lCopy := .T.
	FWExecView("Cópia","GFEA050",3,,{|| .T.}) //"Cópia"
Return
//--------------------------------------------------------
/*/{Protheus.doc} GFEA050CPT
Função que calcula os totais de volume, peso real e peso cubado dos itens
dos documentos de carga (GW8) associados ao romaneio de carga (GWN).

@author felipe.m
@since 12/01/2016
@version 1.0
@param cNrRom, Caracter, Número do romaneio
/*/
//--------------------------------------------------------
Function GFEA050CPT(cNrRom)
	Local aAreaAnt  := GetArea()
	Local cAliasQry := ""
	Local cFilBkp   := cFilAnt

	Static _aGWN_TOTVOL := {}
	Static _aGWN_TOTPER := {}
	Static _aGWN_TOTPEC := {}
	Static _aGWN_TOTALT := {}
	Static _nFieldCont := 0
	Static _aTotais := {0,0,0,0}

	// Apenas realiza o select uma vez por registro GWN
	// Caso os 4 campos totalizadores estejam ativados (BROWSE == 'S') esta função realizará o
	// select apenas a primeira vez, e para os demais campos é apenas retornado o valor do
	// parâmetro
	If !Empty(cNrRom) .AND. _nFieldCont == 0

		cFilAnt := GWN->GWN_FILIAL
		If Empty(_aGWN_TOTVOL)
			// Precisa carregar apenas uma vez
			_aGWN_TOTVOL := TamSx3("GWN_TOTVOL")
			_aGWN_TOTPER := TamSx3("GWN_TOTPER")
			_aGWN_TOTPEC := TamSx3("GWN_TOTPEC")
			_aGWN_TOTALT := TamSx3("GWN_TOTALT")
		EndIf

		// Conta quantos campos estão ativos para mostra no browse
		If GetSx3Cache("GWN_TOTVOL","X3_BROWSE") == "S"
			_nFieldCont++
		EndIf
		If GetSx3Cache("GWN_TOTPER","X3_BROWSE") == "S"
			_nFieldCont++
		EndIf
		If GetSx3Cache("GWN_TOTPEC","X3_BROWSE") == "S"
			_nFieldCont++
		EndIf
		If GetSx3Cache("GWN_TOTALT","X3_BROWSE") == "S"
			_nFieldCont++
		EndIf

		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SUM(GW8.GW8_VOLUME) GWN_TOTVOL,
					SUM(GW8.GW8_PESOR) GWN_TOTPER,
					SUM(GW8.GW8_PESOC) GWN_TOTPEC,
					SUM(GW8.GW8_QTDALT) GWN_TOTALT
			FROM %Table:GWN% GWN
			INNER JOIN %Table:GW1% GW1
			ON GW1.GW1_FILIAL = %xFilial:GW1%
			AND GW1.GW1_NRROM = GWN.GWN_NRROM
			AND GW1.%NotDel%
			INNER JOIN %Table:GW8% GW8
			ON GW8.GW8_FILIAL = %xFilial:GW8%
			AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
			AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
			AND GW8.GW8_SERDC = GW1.GW1_SERDC
			AND GW8.GW8_NRDC = GW1.GW1_NRDC
			AND GW8.%NotDel%
			WHERE GWN.GWN_FILIAL = %xFilial:GWN%
			AND GWN.GWN_NRROM = %Exp:cNrRom%
			AND GWN.%NotDel%
		EndSql
		TCSetField(cAliasQry,'GWN_TOTVOL','N',_aGWN_TOTVOL[1],_aGWN_TOTVOL[2])
		TCSetField(cAliasQry,'GWN_TOTPER','N',_aGWN_TOTPER[1],_aGWN_TOTPER[2])
		TCSetField(cAliasQry,'GWN_TOTPEC','N',_aGWN_TOTPEC[1],_aGWN_TOTPEC[2])
		TCSetField(cAliasQry,'GWN_TOTALT','N',_aGWN_TOTALT[1],_aGWN_TOTALT[2])
		If (cAliasQry)->(!Eof())
			_aTotais := (cAliasQry)->({GWN_TOTVOL,GWN_TOTPER,GWN_TOTPEC,GWN_TOTALT})
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	_nFieldCont--

	RestArea(aAreaAnt)
	cFilAnt := cFilBkp
Return _aTotais
//--------------------------------------------------------
/*/{Protheus.doc} GFEA050CVT
Função que calcula o total da quantidade de volumes dos
documentos de carga (GW1) associados ao romaneio de carga (GWN).

@author felipe.m
@since 25/01/2016
@version 1.0
@param cNrRom, Caracter, Número do romaneio
/*/
//--------------------------------------------------------
Function GFEA050CVT(cNrRom)
	Local aAreaAnt    := GetArea()
	Local nTotQtVol   := 0
	Local cAliasQry   := Nil
	Local aGWN_TQTVOL := TamSx3("GWN_TQTVOL")
	Local cFilBkp     := cFilAnt

	If !Empty(cNrRom)
		cFilAnt := GWN->GWN_FILIAL
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SUM(GW1.GW1_QTVOL) GWN_TQTVOL
			FROM %Table:GWN% GWN
			INNER JOIN %Table:GW1% GW1
			ON GW1.GW1_FILIAL = %xFilial:GW1%
			AND GW1.GW1_NRROM = GWN.GWN_NRROM
			AND GW1.%NotDel%
			WHERE GWN.GWN_FILIAL = %xFilial:GW1%
			AND GWN.GWN_NRROM = %Exp:cNrRom%
			AND GWN.%NotDel%
		EndSql
		TCSetField(cAliasQry,'GWN_TQTVOL','N',aGWN_TQTVOL[1],aGWN_TQTVOL[2])
		If (cAliasQry)->(!Eof())
			nTotQtVol := (cAliasQry)->GWN_TQTVOL
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
	cFilAnt := cFilBkp
Return nTotQtVol
/* alterado para commit */
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA50REDP
Rotina que executa a view de manutenção de transportadoras redespachantes.

@sample
GFEA50REDP()

@author Amanda Vieira
@since 12/01/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA50REDP(nOpc)
	Local aAreaGW1 := GW1->(GetArea())
	Local aAreaGWU := GWU->(GetArea())

	If !Empty(SuperGetMv("MV_INTTMS",.F.,.F.)) .And. SuperGetMv("MV_INTTMS",.F.,.F.) .And. SuperGetMv("MV_TMSGFE",.F.,.F.)
		MsgAlert("Opção não disponível quando integração de Redespachos com SIGATMS está ativa")
		Return
	EndIf

	//Ponto de entrada validação Vicunha
	If ExistBlock("GFEA0506")
		If ExecBlock("GFEA0506",.F.,.F.,{"7"})
			Return
		EndIf
	EndIf

	//Realiza validações do romaneio e chama a view para executar inclusão ou alteração
	If nOpc == 1
		If GFE050VLRED(nOpc)
			FWExecView("Incluir","GFEA050C", MODEL_OPERATION_INSERT ,, { || .T. } ,, )
		EndIf
	ElseIf  nOpc == 2
		If GFE050VLRED(nOpc)
			FWExecView("Alterar","GFEA050D", MODEL_OPERATION_UPDATE ,, { || .T. } ,, )
		EndIf
	EndIf

	RestArea(aAreaGW1)
	RestArea(aAreaGWU)
Return
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE050VLRED
Realiza validações antes de abrir a tela de manutenção de redespachantes.

@sample
GFE050VLRED()

@author Amanda Vieira
@since 19/02/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/

Static Function GFE050VLRED(nOpc)
	Local cAliasQry := ""
	Local cWhere    := ""
	Local lRet      := .T.
	Local lEsp      := .T.
	Local cMsg		:= ""
	Local cTxt		:= ""

	If nOpc == 1
		cTxt := "Incluir"
	Else
		cTxt := "Alterar / Excluir"
	EndIf

	GW1->(dbSetOrder(9)) //GW1_FILIAL+GW1_NRROM
	GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
	GWH->(dbSetOrder(2)) //GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC+GWH_NRCALC
	GXD->(dbSetOrder(2)) //GXD_FILCAL+GXD_NRCALC
	GXE->(dbSetOrder(1)) //GXE_FILIAL+GXE_CODLOT

	If !Empty(GWN->GWN_VIAGEM)
		If PosicionaGWP()
			If GWP->GWP_SIT == '2'
				cMsg := "Já ocorreu a partida da viagem " + GWP->GWP_VIAGEM + " que está relacionada, portanto não é possível alterar o Redespachante do Romaneio."
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

	//Verica se há Trechos do Itinerário(GWU) do romaneio selecionado.
	If GW1->(dbSeek(xFilial('GW1')+GWN->GWN_NRROM))
		If GWU->(!dbSeek(xFilial('GWU')+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
			If Empty(cMsg)
				cMsg := "Não há trechos para manutenção. "
			EndIf
			lRet := .F.
		EndIf
	Else
		If Empty(cMsg)
			cMsg := "Não há documentos relacionados ao romaneio. "
		EndIf
		lRet := .F.
	EndIf

	If GFXCP1212210('GW1_FILROM')
		cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
	Else
		cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
	EndIf
	cWhere := "%" + cWhere + "%"

	//Caso a opção escolhida foi "alterar", verifica se no romaneio possui documentos de carga com tipo de frete de redespacho
	If nOpc == 2
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GW1.GW1_NRDC
			FROM %Table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
			AND GW1.GW1_TPFRET IN ('2','4','6')
			AND GW1.%NotDel%
		EndSql
		If (cAliasQry)->(Eof())
			If Empty(cMsg)
				cMsg := "No romaneio selecionado não existem documentos de carga que são do tipo CIF com Redespacho, FOB com Redespacho ou Consignado com Redespacho. "
			EndIf
			lRet := .F.
		EndIf

		(cAliasQry)->(dbCloseArea())
	EndIf

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT GW1.GW1_NRDC, 
			   GW1.GW1_TPFRET, 
			   GW1.GW1_CDTPDC, 
			   GW1.GW1_EMISDC, 
			   GW1.GW1_SERDC, 
			   GXE.GXE_SIT, 
			   GWF.GWF_NRCALC,
			   GWF.GWF_ORIGEM
		FROM %Table:GW1% GW1
		LEFT JOIN %Table:GWH% GWH
		ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
		AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
		AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
		AND GWH.GWH_SERDC = GW1.GW1_SERDC
		AND GWH.GWH_NRDC = GW1.GW1_NRDC
		AND GWH.%NotDel%
		LEFT JOIN %Table:GWF% GWF 
		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
		AND GWF.GWF_NRCALC = GWH_NRCALC
		AND GWF.%NotDel%
		LEFT JOIN %Table:GXD% GXD
		ON GXD.GXD_FILCAL = GWH.GWH_FILIAL
		AND GXD.GXD_NRCALC = GWH.GWH_NRCALC
		AND GXD.%NotDel%
		LEFT JOIN %Table:GXE% GXE
		ON GXE.GXE_FILIAL = GXD.GXD_FILIAL
		AND GXE.GXE_CODLOT = GXD.GXD_CODLOT
		AND GXE.%NotDel%
		WHERE %Exp:cWhere%
		AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
		AND GW1.%NotDel%
	EndSql

	//Verifica se a origem de cálculos é válida
	Do While lRet .And. (cAliasQry)->(!Eof())
		If !Empty((cAliasQry)->GWF_NRCALC) .And. (Empty((cAliasQry)->GWF_ORIGEM) .Or. (cAliasQry)->GWF_ORIGEM $ "3")
			If Empty(cMsg)
				cMsg := "O Romaneio possuí cálculos de origem 3=Apuracao Periodo,a alteração de Redespachantes não é permitida para cálculos com essa origem."
			EndIf
			lRet := .F.
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	//Ponto de entrada validação Camil
	If ExistBlock("GFEA0509")
		lEsp := ExecBlock("GFEA0509",.F.,.F.,{nOpc})
	EndIf

	If lEsp == .T.
		(cAliasQry)->(dbGoTop())
		//Verifica se há cálculo de provisão vinculado
		Do While lRet .And. (cAliasQry)->(!Eof())
			If !Empty((cAliasQry)->GXE_SIT) .OR. (cAliasQry)->GXE_SIT $ '2|3|4|5'
				If Empty(cMsg)
					cMsg := "Existem documentos do romaneio selecionado que possuem cálculo de provisão relacionado em um lote de provisão contábil já integrado. "
				EndIf
				lRet := .F.
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf

	(cAliasQry)->(dbCloseArea())

	If GWN->GWN_SIT == "4"
		If nOpc == 2
			If Empty(cMsg)
				cMsg := "O Romaneio está encerrado, portando não poderá ser alterado o Redespachante. "
			EndIf
			lRet := .F.
		ElseIf Empty(cMsg)
			If !(MsgYesNo("Deseja incluir um trecho de redespacho para um romaneio encerrado?","Resdespachante"))
				lRet := .F.
			EndIf
		EndIf
	//Caso o romaneio encontra-se liberado é necessário reabrir o romaneio por meio da decisão do usuário
	ElseIf GWN->GWN_SIT == "3"  .and. lEsp == .T.
		If MsgYesNo("Deseja reabrir o romaneio para " + cTxt + " o trecho de redespacho?","Resdespachante")
			//Grava a data para reliberar o romaneio
			dData := GWN->GWN_DTSAI
			cHora := GWN->GWN_HRSAI
			If !GFEA050REA()
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If !lRet .And. !Empty(cMsg)
		Help( ,, 'HELP',, cMsg, 1, 0,)
	EndIf
Return lRet

Function GFE050PVIA()
	Local aArea      := GetArea()
	Local aAreaGWP   := GWP->(GetArea())
	Local lProssegue := .T.
	
	If GFXCP12116('GWP','GWP_VIAGEM')
		If Empty(GWN->GWN_VIAGEM)
			GfeMsgErro('Romaneio não está relacionado a uma viagem')
			lProssegue := .F.
		EndIf
	
		If lProssegue
			lProssegue := PosicionaGWP()
			If lProssegue
				GFEA58PVIA(,,,GWN->GWN_NRROM)
			EndIf
		EndIf
		RestArea(aAreaGWP)
		RestArea(aArea)
	Else
		Help(,,'HELP',,'Funcionalidade disponível a partir da versão 12.1.16.',1,0,)
	EndIf
Return

Static Function PosicionaGWP(lHelp,cMsg)
	Local lRet    := .T.
	Local aArea   := GetArea()
	Local cAlBkp  := Alias()

	Default lHelp := .T.
	Default cMsg  := ""

	GWP->(dbOrderNickName('VIAGEM'))
	If !GWP->(dbSeek(xFilial('GWP') + GWN->GWN_VIAGEM))
		cMsg := 'Viagem ' + GWN->GWN_VIAGEM + ' não localizada'
		If lHelp
			GfeMsgErro(cMsg)
		EndIf
		lRet := .F.
	EndIf
	RestArea(aArea)

	If cAlBkp != Nil .And. !Empty(cAlBkp)
		dbSelectArea(cAlBkp)
	EndIf
Return lRet

Function GFE50NVG()
	Local oMdlAct := FwModelActive()
	Local oVwAct  := FwViewActive()
	Local cRet    := ""
	Local cNrDc   := ""

	If Empty(FwFldGet("GWN_CDTRP"))
		GfeMsgErro("É necessário preencher o transportador antes de utilizar a ação")
		Return
	EndIf

	If oMdlAct:GetOperation() == MODEL_OPERATION_DELETE
		Return
	EndIf
	If oMdlAct:GetOperation() == MODEL_OPERATION_UPDATE
		If !GFEA058RVG(,@cNrDc)
			GfeMsgErro("Não é possível vincular romaneio que possui o documento " + AllTrim(cNrDc) + " com frete combinado/simulação com origem erp.")
			Return .F.
		EndIf
	EndIf

	cRet := GFEA058A(FwFldGet("GWN_NRROM"),FwFldGet("GWN_CDTRP"),FwFldGet("GWN_VIAGEM"))
	FwModelActive(oMdlAct)
	FwViewActive(oVwAct)

	If !Empty(cRet)
		oMdlAct:GetModel("GFEA050_GWN"):SetValue("GWN_VIAGEM",cRet)
		oMdlAct:lModify := .T.
	EndIf
Return

Function GFEA50CMT(oModel)
	Local lRet      := .T.
	Local cViagem   := ""
	Local cViagAnt  := ""
	Local nop       := oModel:GetOperation()
	Local oModelGWN := oModel:GetModel("GFEA050_GWN")
	Local aDados    := {}
	Local nX        := 0
	Local nF        := 0

	If oModelGWN:HasField("GWN_VIAGEM") 
		If nOp <> MODEL_OPERATION_INSERT
			cViagAnt := GWN->GWN_VIAGEM
		EndIf

		If nOp <> MODEL_OPERATION_DELETE
			cViagem := oModelGWN:GetValue('GWN_VIAGEM')
		EndIf

		lRet := FwFormCommit(oModel)

		If oModelGWN:HasField("GWN_CPESO")
			aAdd(aDados,{"GWN_CPESO",oModelGWN:GetValue("GWN_CPESO")})
		EndIf

		If oModelGWN:HasField("GWN_CVAL" )
			aAdd(aDados,{"GWN_CVAL",oModelGWN:GetValue("GWN_CVAL")})
		EndIf

		If oModelGWN:HasField("GWN_CVOL" )
			aAdd(aDados,{"GWN_CVOL",oModelGWN:GetValue("GWN_CVOL")})
		EndIf

		If oModelGWN:HasField("GWN_CQTDE")
			aAdd(aDados,{"GWN_CQTDE",oModelGWN:GetValue("GWN_CQTDE")})
		EndIf

		If !Empty(cViagem) .OR. !Empty(cViagAnt)
			GFE58ATVG(cViagem,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.,cViagAnt)
		EndIf

		If Len(aDados) > 0 .AND. nOp <> MODEL_OPERATION_DELETE
			RecLock('GWN',.F.)
			nF := Len(aDados)
			For nX := 1 To nF
				&("GWN->" + aDados[nX][1]) := aDados[nX][2]
			Next nX
			GWN->(MsUnlock())
		EndIf
	Else
		lRet := FwFormCommit(oModel)
	EndIf
Return lRet

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE050COMB
Informa os Documentos de Carga na tela de Frete Combinado

@sample
GFE050COMB()

@author Helder Fuckner dos Santos
@since 22/01/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFE050COMB()
	Local oFWMVCWindow := Nil
	Local aCoors       := Nil
	Local lRet         := .T.
	Local oView        := FWLoadView('GFEA084')
	Local oModel       := FWLoadModel('GFEA084')
	
	Private lMulFilDC  := .F.

	GW1->( dbSetOrder(9) )
	If !GW1->(MsSeek(xFilial("GW1") + GWN->GWN_NRROM))
		MsgStop("Relacione documentos de carga antes de combinar um frete.","Atenção")
		Return .F.
	EndIf
	
	If !ValCalcLot()
		Help( ,, 'HELP',, 'Não é possível combinar frete. Romaneio possui cálculos vinculados a lote de provisão.', 1, 0)
		Return .F.
	EndIf

	aTrecho := GetTrecho()
	lRet 	:= !Empty(aTrecho)

	If lMulFilDC .And. s_MULFIL == "1"
		Help( ,, 'HELP', 'Frete Combinado', 'Não é possível combinar frete quando habilitado uso de multiplas filiais (MV_MULFIL) atravez da rotina de Romaneio de Carga.' + CRLF + 'Realize a operação diretamente na rotina Frete Combinado (GFEA084).', 1, 0)
		Return .F.
	EndIf

	If lRet
		aCoors := FWGetDialogSize(oMainWnd)
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		If AbreCadastro(oModel,aTrecho)
			oView:SetModel(oModel)
			oView:EnableControlBar(.T.)
			oView:SetOperation(MODEL_OPERATION_INSERT)
			oView:SetUseCursor(.F.)
			oView:SetCloseOnOk({|| .T.})

			oFWMVCWindow := FWMVCWindow():New()
			oFWMVCWindow:SetUseControlBar(.T.)
			oFWMVCWindow:SetView(oView)
			oFWMVCWindow:SetCentered(.T.)
			oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
			oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
			oFWMVCWindow:SetTitle("Frete Combinado")
			oFWMVCWindow:Activate(,,Nil,.F.)
		EndIf
		oModel:Deactivate()
		FreeObJ(oModel)
	Else
		Help( ,, 'HELP',, 'Verifique se existem trechos pagos e se o transportador permite frete combinado.', 1, 0)
	EndIf
Return lRet

Static Function AbreCadastro(oModel, aTrecho)
	Local oModelGWH := oModel:GetModel('GFEA084_GWH')
	Local aEntregas := GWNEntregas(,,aTrecho[2], aTrecho[1])
	Local nI        := 0
	Local nJ        := 0
	Local nF        := 0

	oModel:SetValue("GFEA084_GWF", "GWF_IDFRVI", "1")
	nF := Len(aEntregas)
	For nI := 1 To nF
		For nJ := 1 To Len(aEntregas[nI])
			If !Empty(oModelGWH:GetValue('GWH_NRDC'))
				oModelGWH:AddLine(.T.)
			EndIf

			oModelGWH:SetValue('GWH_FILIAL',	aEntregas[nI][nJ][NPOSFILIAL])
			oModelGWH:SetValue('GWH_NRDC', 		aEntregas[nI][nJ][NPOSNRDC])
			oModelGWH:SetValue('GWH_CDTPDC', 	aEntregas[nI][nJ][NPOSTPDC])
			oModelGWH:SetValue('GWH_EMISDC', 	aEntregas[nI][nJ][NPOSEMIS])
			oModelGWH:SetValue('GWH_SERDC',		aEntregas[nI][nJ][NPOSSERDC])
			oModelGWH:SetValue('GWH_TRECHO',	aEntregas[nI][nJ][NPOSSEQ])
			If oModelGWH:VldLinedata() != .T.
				oModelGWH:DeleteLine()
			EndIf
		Next nJ
	Next nI
Return .T.

// Ref Ao retorno da função GWNEntregas
Static NPOSFILIAL := 1
Static NPOSTPDC   := 2
Static NPOSEMIS   := 3
Static NPOSSERDC  := 4
Static NPOSNRDC   := 5
Static NPOSCDTRP  := 6
Static NPOSSEQ    := 7
Static NPOSCDREM  := 8
Static NPOSCDDEST := 9
Static NPOSENTNRC := 10
Static NPOSENTBAI := 11
Static NPOSENTEND := 12
Static NPOSORIGEM := 13
Static NPOSDESTIN := 14

/*/{Protheus.doc} AgrupaEntregas
(long_description)
@author alan.victor
@since 18/03/2015
@version 1.0
@param aDocCarga, array,
@param cCdTrp, character, Código do transportador, para filtrar as entregas. Em branco retorna de todos os tranportadores.
@param cTrecho, character, Sequência do trecho, para filtrar as entregas. Em branco retorna de todos os trechos.
@return ${return}, ${return_description}
/*/
Function GF50AGRENT(aDocCarga, cCdTrp, cTrecho)
	Local aEntregas := {}
	Local nF        := 0
	Local nI        := 0
	Local nJ        := 0
	Local nCount    := 0
	Local nEntAgrup := 0
	Local aInfoEnt  := {}
	Local nMaxDoc   := 0
	Local cOrigem   := ""
	Local cDestin   := ""
	Local areaGWN := GWN->(GetArea())
	
	GWN->(dbSetOrder(1))
	nF := Len(aDocCarga)
	For nCount := 1 To nF
		GW1->(dbSetOrder(1))
		If GW1->(dbSeek( aDocCarga[nCount][NPOSFILIAL] + aDocCarga[nCount][NPOSTPDC] + aDocCarga[nCount][NPOSEMIS] + aDocCarga[nCount][NPOSSERDC] + aDocCarga[nCount][NPOSNRDC] ))
			GWU->(dbSetOrder(1))
			If GWU->(dbSeek( GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC ))
				Do While GWU->(!Eof()) ;
					.And. GWU->GWU_FILIAL == GW1->GW1_FILIAL ;
					.And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC ;
					.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC ;
					.And. GWU->GWU_SERDC == GW1->GW1_SERDC ;
					.And. GWU->GWU_NRDC == GW1->GW1_NRDC

					If GWU->GWU_SEQ == '01'
						If GFXCP12117("GWU_NRCIDO") .And. !Empty(GWU->GWU_NRCIDO)
							cOrigem := GWU->GWU_NRCIDO
						Else
							GWN->(msSeek(xFilial("GWN") + GW1->GW1_NRROM))
							If !Empty(GWN->GWN_NRCIDO)
								cOrigem := GWN->GWN_NRCIDO
							Else
								cOrigem := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDREM,"GU3_NRCID")
							EndIf
						EndIf
					Else
						If GFXCP12117("GWU_NRCIDO") .And. !Empty(GWU->GWU_NRCIDO)
							cOrigem := GWU->GWU_NRCIDO
						Else
							cOrigem := If(Empty(cDestin) , Posicione("GU3",1,xFilial("GU3")+GWU->GWU_CDTRP,"GU3_NRCID") , cDestin)
						EndIf
					EndIf
					
					cDestin := GWU->GWU_NRCIDD
					
					GWU->(dbSkip())
					
					If GWU->(!Eof()) ;
						.And. GWU->GWU_FILIAL == GW1->GW1_FILIAL ;
						.And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC ;
						.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC ;
						.And. GWU->GWU_SERDC  == GW1->GW1_SERDC ;
						.And. GWU->GWU_NRDC   == GW1->GW1_NRDC
						
						//Se houver destino informado no trecho assume a cidade destino informado, caso contrario assume a cidade do
						//transportador do trecho seguinte, exceto o ultimo trecho, que tem outro tratamento
						if Empty(cDestin)
							cDestin := Posicione("GU3",1,xFilial("GU3")+GWU->GWU_CDTRP,"GU3_NRCID")
						EndIf
						GWU->(dbSkip(-1))
					Else
						GWU->(dbSkip(-1))
						GWN->(msSeek(xFilial("GWN") + GW1->GW1_NRROM))
						If !Empty(GWN->GWN_NRCIDD)
							cDestin := GWN->GWN_NRCIDD
						Else
							If !Empty(GW1->GW1_ENTNRC) .AND. GW1->GW1_ENTNRC != PADR("0",50)
								cDestin := GW1->GW1_ENTNRC
							Else
								cDestin := GWU->GWU_NRCIDD
							EndIf
						EndIf
					EndIf
					
					If GWU->GWU_PAGAR == "1" .And. (Empty(cCdTrp) .Or. GWU->GWU_CDTRP == cCdTrp) .And. (Empty(cTrecho) .Or. GWU->GWU_SEQ == cTrecho)						
						aInfoEnt   := { GWU->GWU_FILIAL,;
										GWU->GWU_CDTPDC,;
										GWU->GWU_EMISDC,;
										GWU->GWU_SERDC,;
										GWU->GWU_NRDC,;
										GWU->GWU_CDTRP,;
										GWU->GWU_SEQ,;
										GW1->GW1_CDREM,;
										GW1->GW1_CDDEST,;
										GW1->GW1_ENTNRC,;
										GW1->GW1_ENTBAI,;
										GW1->GW1_ENTEND,;
										cOrigem,;
										cDestin}

						nMaxDoc := Posicione("GU3", 1, xFilial("GU3")+GWU->GWU_CDTRP, "GU3_MAXDOC")

						If Len(aEntregas) == 0
							aAdd(aEntregas, {aInfoEnt})
						Else
							nEntAgrup := 0

							For nI := 1 To Len(aEntregas)
								For nJ := 1 To Len(aEntregas[nI])
									// Agrupar na mesma entrega
									If aEntregas[nI][nJ][NPOSCDTRP]  == GWU->GWU_CDTRP .AND. ;
									aEntregas[nI][nJ][NPOSCDREM]  == GW1->GW1_CDREM .AND. ;
									aEntregas[nI][nJ][NPOSCDDEST] == GW1->GW1_CDDEST .AND. ;
									aEntregas[nI][nJ][NPOSENTNRC] == GW1->GW1_ENTNRC .And. ;
									aEntregas[nI][nJ][NPOSENTBAI] == GW1->GW1_ENTBAI .And. ;
									aEntregas[nI][nJ][NPOSENTEND] == GW1->GW1_ENTEND .AND. ;
									aEntregas[nI][nJ][NPOSORIGEM] == cOrigem .And. ;
									aEntregas[nI][nJ][NPOSDESTIN] == cDestin .AND. ;
									nMaxDoc > 1 .AND. Len(aEntregas[nI]) < nMaxDoc

										nEntAgrup := nI

									EndIf
								Next nJ
							Next nI

							If nEntAgrup > 0
								aAdd(aEntregas[nEntAgrup], aInfoEnt)
							Else
								aAdd(aEntregas, {aInfoEnt})
							EndIf
						EndIf
					EndIf

					GWU->(dbSkip())
				EndDo
			EndIf
		EndIf
	Next nCount
	RestArea(areaGWN)
Return aEntregas

/*/{Protheus.doc} GWNEntregas
(long_description)
@author alan.victor
@since 17/03/2015
@version 1.0
@param cFilRom, character, Filial do Romaneio (em branco pega o registro posicionado)
@param cNrRom, character, Número do Romaneio (em branco pega o registro posicionado)
@param cCdTrp, character, Código do transportador, para filtrar as entregas. Em branco retorna de todos os tranportadores.
@param cTrecho, character, Sequência do trecho, para filtrar as entregas. Em branco retorna de todos os trechos.
@return aEntregas, array contendo todas as entregas e documentos de carga de cada uma.
/*/
Function GWNEntregas(cFilRom, cNrRom, cCdTrp, cTrecho)
	Local aEntregas  := {}
	Local aDocCarga  := {}
	Local aArea      := {}
	Local cAliasGW1  := Nil
	Local cWhere     := Nil

	Default cFilRom  := GWN->GWN_FILIAL
	Default cNrRom   := GWN->GWN_NRROM
	Default cCdTrp   := ""
	Default cTrecho  := ""

	aArea := GWN->(GetArea())
	GWN->(dbSetOrder(1))
	If GWN->(dbSeek(cFilRom + cNrRom))
		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		While !(cAliasGW1)->(Eof())
			aAdd(aDocCarga, {(cAliasGW1)->GW1_FILIAL, (cAliasGW1)->GW1_CDTPDC, (cAliasGW1)->GW1_EMISDC, (cAliasGW1)->GW1_SERDC, (cAliasGW1)->GW1_NRDC})

			(cAliasGW1)->(dbSkip())
		EndDo	
		(cAliasGW1)->(dbCloseArea())
	EndIf
	RestArea(aArea)
	aEntregas := GF50AGRENT(aDocCarga, cCdTrp, cTrecho)
Return aEntregas

/*/{Protheus.doc} GFE050DESC
Função responsável por deletar todos os cálculos combinados de um romaneio.
@author Leandro Conradi Zmovirzynski
@since 26/03/2018
@version 1.0
/*/
Function GFE050DESC()
	Local aCalc     := {}
	Local cAliasGW1 := Nil
	Local cWhere    := Nil
	Local oRetValid := GFEXFBB():New()
	
	If msgyesno("Deseja excluir todos os cálculos do tipo combinado vinculado a este romaneio?")
		GWF->(dbSetOrder(7))
		If !GWF->(dbSeek(GWN->GWN_FILIAL + GWN->GWN_NRROM) )
			MsgInfo('Não há calculo relacionado ao romaneio', 'Frete Combinado')
			Return
		EndIf
		
		Do While GWF->(!Eof()) .And. GWF->GWF_FILROM == GWN->GWN_FILIAL .And. GWF->GWF_NRROM == GWN->GWN_NRROM
			//Valida se o cálculo pode ser deletado.
			oRetValid:SetFilCalc(GWF->GWF_FILIAL)
			oRetValid:SetNrCalc(GWF->GWF_NRCALC)
			oRetValid:SetOrigem(GWF->GWF_ORIGEM)
			oRetValid:Validar()
			If(!oRetValid:getStatus())
				MsgInfo(oRetValid:getMensagem())
				oRetValid:Destroy()
				Return
			EndIf
		
			aAdd(aCalc, {GWF->GWF_NRCALC, GWF->GWF_FILIAL})
			GWF->(dbSkip())
		EndDo
	
		GFEDelCalc(,,.T.,aCalc)		
		
		GWN->(dbSetOrder(1))
		If GWN->(dbSeek(GWN->GWN_FILIAL + GWN->GWN_NRROM))
			RecLock("GWN", .F.)
				GWN->GWN_CALC   := "4"
				GWN->GWN_MTCALC := ""
				GWN->GWN_DTCALC := CToD("  /  /    ")
				GWN->GWN_HRCALC := ""
				If GWN->GWN_AGRUP == "1"
					GWN->GWN_AGRUP := "2"
				EndIf
			GWN->(MsUnLock())
		EndIf

		cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		While !(cAliasGW1)->(Eof())
			GWU->(dbSetOrder(4))
			If GWU->(dbSeek((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_NRDC))
				Do While GWU->(!Eof()) .And. (GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC == (cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC)
					RecLock("GWU",.F.)
						GWU->GWU_DTPENT := CToD("  /  /    ")
						GWU->GWU_HRPENT	:= ""
					GWU->(MsUnLock())
					GWU->(dbSkip())
				EndDo
			EndIf

			(cAliasGW1)->(dbSkip())
		EndDo	
		(cAliasGW1)->(dbCloseArea())
	EndIf
	oRetValid:Destroy()
Return

Static Function GetTrecho()
	Local nI, nJ    := 0
	Local aRet      := {}
	Local aRet2     := {}
	Local cAliasTmp := Nil
	Local cAuxFil   := Nil
	Local aAuxDC    := Nil

	// GW1	Documentos de Carga
	// GWU	Trechos do Itinerario
	// GU3	Emitentes
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT DISTINCT GWU.GWU_SEQ, GWU.GWU_CDTRP, GU3.GU3_NMEMIT
		FROM %Table:GW1% GW1
		INNER JOIN %Table:GWU% GWU
		ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
		AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
		AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
		AND GWU.GWU_SERDC = GW1.GW1_SERDC
		AND GWU.GWU_NRDC = GW1.GW1_NRDC
		AND GWU.GWU_PAGAR  = '1'
		AND GWU.%NotDel%
		INNER JOIN %Table:GU3% GU3
		ON GU3.GU3_CDEMIT = GWU.GWU_CDTRP
		AND GU3.GU3_FRCOMB = '1'
		AND GU3.%NotDel%
		WHERE GW1.GW1_FILROM = %Exp:GWN->GWN_FILIAL%
		AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
		AND GW1.%NotDel%
		ORDER BY GWU.GWU_SEQ, GWU.GWU_CDTRP
	EndSql
	Do While (cAliasTmp)->(!Eof())
		aAdd(aRet, {((cAliasTmp)->GWU_SEQ == "01"), (cAliasTmp)->GWU_SEQ, (cAliasTmp)->GWU_CDTRP, (cAliasTmp)->GU3_NMEMIT})

		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea())

	If Len(aRet) > 1
		If s_MULFIL <> "1"
			aRet2 := TelaTrecho(aRet)
		Else
			aRet2 := {aRet[1][2],aRet[1][3],aRet[1][4]}

			aAuxDC := GWNEntregas(,,aRet2[2], aRet2[1])
			For nI := 1 To Len(aAuxDC)
				For nJ := 1 To Len(aAuxDC[nI])
					If Empty(cAuxFil)
						cAuxFil := aAuxDC[nI][nJ][1]
					EndIf

					If aAuxDC[nI][nJ][1] <> cAuxFil
						lMulFilDC := .T.
					EndIf
				Next nJ
			Next nI
		EndIf
	Else 
		if Len(aRet) > 0
			aDel(aRet[1],1)
			aSize(aRet[1], Len(aRet[1])-1)
			aRet2 := aRet[1]
		EndIf
	EndIf

Return aRet2

Static Function TelaTrecho(aTrechos)
	Local oDlgTrc   := Nil
	Local oBrowse   := Nil
	Local nAlt      := 300
	Local nLrg      := 490
	Local aTrecho   := {}
	Local oOK       := LoadBitmap(GetResources(),"LBOK")
	Local oNO       := LoadBitmap(GetResources(),"LBNO")
	Local aColsName := {"","Trecho","Transp","Nome Transportador"}
	Local aColsSize := {20,25,60,70}
	Local bConfirm  := Nil
	Local bCancel   := Nil

	Private aRetTrecho := aTrechos

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlgTrc Title "Selecionar Trecho" From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlgTrc:lEscClose := .F.

	oBrowse := TWBrowse():New(0,0,248,120,,aColsName,aColsSize,oDlgTrc,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse:SetArray( aTrechos )
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowse:bLine := {|| { If(aRetTrecho[oBrowse:nAt,01],oOK,oNO),aRetTrecho[oBrowse:nAt,02], aRetTrecho[oBrowse:nAt,03],aRetTrecho[oBrowse:nAt,04] } }
	// Troca a imagem no duplo click do mouse
	oBrowse:bLDblClick := {|| DlgTrcDblClick(aRetTrecho, oBrowse) }

	bConfirm	:= {|| IIf( VerTlTre(aRetTrecho) , (aTrecho := aRetTrecho[oBrowse:nAt], aDel(aTrecho,1), aSize(aTrecho, Len(aTrecho)-1), oDlgTrc:End() ), .F. ) }
	bCancel	:= {|| oDlgTrc:End() }
	ACTIVATE MSDIALOG oDlgTrc ON INIT EnchoiceBar(oDlgTrc, bConfirm, bCancel,, ) CENTERED
Return aTrecho

Static Function DlgTrcDblClick(aRetTrecho, oBrowse)
	Local nX         := 0
	Local nF         := 0
	Local nPosMarcar := oBrowse:nAt
	nF := Len(aRetTrecho)
	For nX := 1 To nF
		aRetTrecho[nX][1] := nX == nPosMarcar
	Next nX
	oBrowse:Refresh()
Return

Static Function VerTlTre(aRetTrecho)
	Local lRet := .T.
	Local nInd := 0
	Local nX   := 0
	Local nF   := 0

	nF := Len(aRetTrecho)
	For nX := 1 To nF
		If aRetTrecho[nX][1] == .T.
			nInd += 1
		EndIf
	Next nX
	
	If nInd == 0
		MsgInfo('É necessário selecionar um Trecho!', 'Frete Combinado')
		lRet := .F.
	EndIf

	If nInd > 1
		MsgInfo('Selecione somente um Trecho!', 'Frete Combinado')
		lRet := .F.
	EndIf
Return lRet

Static Function TrocouCrgComp(oModelGwn)
	Local lRet1 := .F.
	Local lRet2 := .F.
	Local lRet3 := .F.
	Local lRet4 := .F.
	Local lRet5 := .F.

	If oModelGwn:HasField('GWN_VIAGEM')
		lRet1 := GWN->GWN_VIAGEM <> FwFldGet( 'GWN_VIAGEM')
	EndIf

	If oModelGwn:HasField('GWN_CPESO')
		lRet2 := GWN->GWN_CPESO <> FwFldGet( 'GWN_CPESO')
	EndIf

	If oModelGwn:HasField('GWN_CVAL')
		lRet3 := GWN->GWN_CVAL <> FwFldGet( 'GWN_CVAL')
	EndIf

	If oModelGwn:HasField('GWN_CVOL')
		lRet4 := GWN->GWN_CVOL <> FwFldGet( 'GWN_CVOL')
	EndIf

	If oModelGwn:HasField('GWN_CQTDE')
		lRet5 := GWN->GWN_CQTDE <> FwFldGet( 'GWN_CQTDE')
	EndIf
Return lRet1 .Or. lRet2 .Or. lRet3 .Or. lRet4 .Or. lRet5

/*/{Protheus.doc} GFE050PMAI
Barra de Processa envio do e-mail
@author Leonardo Ribas Jimenez Hernandez
@since 14/12/2016
@version 1.0
@param 
/*/
Function GFE050PMAI()
	
	If GFXCP12117("GU2_RECNFE") == .T.
		Processa({|| GFE050MAIL(.T.)},'Enviando e-mail aos destinatários do romaneio ' + GWN->GWN_NRROM)
	Else
		Help(,,'HELP',,'Funcionalidade disponível a partir da versão 12.1.17.',1,0,)
	EndIf
Return 

/*/{Protheus.doc} GFE050MAIL
(long_description)
@author marcos.wagner
@since 10/11/2016
@version 1.0
@param lMenu, Boolean, Indica se a função foi chamada via menu ou não
/*/
Function GFE050MAIL(lMenu)
	Local aOldArea 	 := GetArea()
	Local cTit 		 := "Envio de arquivo XML NFe"
	Local aFileEmail := {}
	Local aFiles     := {}
	Local nF         := 0
	Local nI         := 0
	Local nJ         := 0
	Local nScan      := 0
	Local nScan2     := 0
	Local cMV_NFEDIR := GetNewPar("MV_NFEDIR","")
	Local cEnvXMLNFE := GetNewPar("MV_NFEENV","1")
	Local cMailTxtOr := "Anexo os arquivos XML das notas fiscais referente ao Embarque [" + AllTrim(GWN->GWN_FILIAL) + " / " + GWN->GWN_NRROM + "]."
	Local cMailTxtAu := ''
	Local cMailNtFis := ''
	Local cDocGW1 	 := ''
	Local cBARRAS 	 := "", cNovoArq := "", cMsgErro := ""
	Local lTemContat := .F.
	Local lRet 		 := .T.
	Local lExisDoc 	 := .F.
	Local aContatos  := {}
	Local nDocRom 	 := 0
	Local lEnvEdi    := .T.
	Local lIsBlind := IsBlind()

	If lIsBlind
		lMenu := .F.
	EndIf
	
	If lMenu
		If cEnvXMLNFE == '1'
			cMsgErro := "Para enviar os arquivos XML para os transportadores, verifique o parâmetro 'Envio XML NFe'."
			If !lIsBlind .And. lMenu
				GFEMsgErro(cMsgErro)
			EndIf
			lRet := .F.
		EndIf
	Else
		If cEnvXMLNFE <> '2' //Automática
	       Return .F.
		EndIf
	EndIf
	
	If lRet
		If Empty(cMV_NFEDIR)
			cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. 'Diretório XML NFe' deve ser informado nos Parâmetros do Módulo."
			If !lIsBlind .And. lMenu
				GFEMsgErro(cMsgErro)
			EndIf
			lRet := .F.
		Else
			If !ExistDir(cMV_NFEDIR)
				cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Diretório XML NFe não encontrado."
				If !lIsBlind .And. lMenu
					GFEMsgErro(cMsgErro)
				EndIf
				lRet := .F.
			EndIf
		EndIf

		If lRet
			If Right(AllTrim(cMV_NFEDIR),1) != "\"
			cMV_NFEDIR := AllTrim(cMV_NFEDIR) + "\"
			EndIf
			
			// Varre o diretório e procura pelas páginas gravadas.
			aFiles := Directory( cMV_NFEDIR + "*.xml" )

			GW1->(dbSetOrder(9))
			If GW1->(dbSeek(xFilial("GW1")+GWN->GWN_NRROM)) //GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
				Do While GW1->(!Eof()) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_NRROM == GWN->GWN_NRROM
					nDocRom := nDocRom +1
					GV5->(dbSetOrder(1))
					If GV5->(dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC)) .And. GV5->GV5_EDI == '1'
						// Monta um Vetor com o path e nome do arquivo em cada linha para passar via email
						nF := Len(aFiles)
						For nI:= 1 To nF
							lExisDoc := .F.
							cMailNtFis := ''
							If AllTrim(GW1->GW1_DANFE) $ aFiles[nI][1]
								lExisDoc := .T.
							Else
								GXP->(dbSetOrder(1))
								If GXP->(dbSeek(xFilial("GXP")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
									Do While GXP->(!Eof()) ;
										.And. GXP->GXP_FILIAL == xFilial("GXP") ;
										.And. GXP->GXP_CDTPDC == GW1->GW1_CDTPDC ;
										.And. GXP->GXP_EMISDC == GW1->GW1_EMISDC ;
										.And. GXP->GXP_SERDC == GW1->GW1_SERDC ;
										.And. GXP->GXP_NRDC == GW1->GW1_NRDC

										If AllTrim(GXP->GXP_DANFE) $ aFiles[nI][1]
											lExisDoc := .T.
											nDocRom := nDocRom +1
											cMailNtFis := " [" + AllTrim(GXP->GXP_SERORI) +" / " + AllTrim(GXP->GXP_DOCORI) +"]"
											Exit
										EndIf
										GXP->(dbSkip())	
									EndDo
								EndIf
							EndIf
							aContatos := {} 

							//Buscando os contatos - Inicio
							aAdd(aContatos,{GW1->GW1_EMISDC})
							GWU->(dbSetOrder(4))
							If GWU->(dbSeek(xFilial("GWU")+GW1->GW1_NRDC))
								Do While GWU->(!Eof()) .And. GWU->GWU_FILIAL+GWU->GWU_NRDC == xFilial("GWU")+GW1->GW1_NRDC
									nScan := aScan(aContatos,{|x| x[1] == GWU->GWU_CDTRP})
									If nScan == 0
										If GWU->GWU_PAGAR == '1'
											aAdd(aContatos,{GWU->GWU_CDTRP})
										EndIf
									EndIf
									GWU->(dbSkip())
								EndDo
							EndIf
							//Buscando os contatos - Fim
							nF := Len(aContatos)
							For nJ := 1 To nF
								GU2->(dbSetOrder(1))
								If GU2->(dbSeek(xFilial("GU2")+aContatos[nJ][1]))
									Do While GU2->(!Eof()) .And. GU2->GU2_FILIAL == xFilial("GU2") .And. GU2->GU2_CDEMIT == aContatos[nJ][1]
										If GU2->GU2_RECNFE == '1' .And. GU2->GU2_SIT == '1'
											nScan := aScan(aFileEmail,{|x| x[1] == GU2->GU2_EMAIL})
											If nScan == 0
												If Empty(GW1->GW1_DANFE)
													cDocGW1 := ""
												Else
													cDocGW1	:= "[ " + AllTrim(GW1->GW1_SERDC) +" / " + AllTrim(GW1->GW1_NRDC) + "]"
												EndIf
												cMailTxtAu := cMailTxtOr + Char(13) + Chr(10) +;
												"Notas Fiscais: " + cDocGW1
												cMailTxtAu := cMailTxtAu + cMailNtFis 
												If lExisDoc
													AADD(aFileEmail,{GU2->GU2_EMAIL, {aFiles[nI][1]}, cMailTxtAu,{}})
												Else
													AADD(aFileEmail,{GU2->GU2_EMAIL, {}, cMailTxtAu,{}})
												EndIf
											Else
												If lExisDoc
													nScan2 := aScan(aFileEmail[nScan][2], {|x| x == aFiles[nI][1] } )
													If nScan2 == 0
														AADD(aFileEmail[nScan][2],aFiles[nI][1])
														lTemContat := .T.
													EndIf
												EndIf

												If At(AllTrim(GW1->GW1_SERDC) +" / " + AllTrim(GW1->GW1_NRDC),aFileEmail[nScan][3]) == 0 .And.;
													!Empty(GW1->GW1_DANFE)
													cMailTxtAu := aFileEmail[nScan][3] + " ; [" + AllTrim(GW1->GW1_SERDC) +" / " + AllTrim(GW1->GW1_NRDC) +"]"
													aFileEmail[nScan][3] := cMailTxtAu
												EndIf
												
												If !Empty(cMailNtFis) .And.;
													At(AllTrim(GXP->GXP_SERORI) +" / " + AllTrim(GXP->GXP_DOCORI),aFileEmail[nScan][3]) == 0 .And.;
													!Empty(GXP->GXP_DANFE) 
													cMailTxtAu := cMailTxtAu + cMailNtFis 
													aFileEmail[nScan][3] := cMailTxtAu
												EndIf
											EndIf
										EndIf
										GU2->(dbSkip())
									EndDo
								EndIf
							Next nJ
						Next nI
					EndIf
					If GV5->GV5_EDI == '2'
						lEnvEdi := .F.
						Exit
					EndIf
					GW1->(dbSkip())
				EndDo
			EndIf

			If Len(aFileEmail) > 0
				cBARRAS := If(isSRVunix(),"/","\")
				cRootPath := Alltrim(GetSrvProfString("RootPath",cBARRAS))
				If Right(AllTrim(cRootPath),1) != cBARRAS
					cRootPath := AllTrim(cRootPath) + cBARRAS
				EndIf
				If !ExistDir(cRootPath+"XMLGFE")
					MakeDir(cRootPath+"XMLGFE")
				EndIf
			
				If !lIsBlind
					ProcRegua(Len(aFileEmail))
				Endif
				nF := Len(aFileEmail)
				For nI := 1 To nF //Copia os arquvios a serem enviados por email para o Rootpath, pois a função GFEEnvMail está preparada para tal.
					If !lIsBlind
						IncProc("Enviando...")
					EndIf
					If !Empty(aFileEmail[nI][1])
						For nJ := 1 to Len(aFileEmail[nI][2])
							cNovoArq := cBARRAS+'XMLGFE'+cBARRAS+aFileEmail[nI][2][nJ]
							__copyfile(cMV_NFEDIR+aFileEmail[nI][2][nJ],cNovoArq)
							aFileEmail[nI][2][nJ] := cNovoArq
						Next nJ
						
						If Len(aFileEmail[nI][2]) <= nDocRom .AND. Len(aFileEmail[nI][2]) != 0
							//Zipando os XMLs
							tarCompress( aFileEmail[nI][2], "\xmlgfe\xml.tar" )
							GzCompress( "\xmlgfe\xml.tar", "\xmlgfe\xml.tar.gz" )
							AADD(aFileEmail[nI][4],"\xmlgfe\xml.tar.gz")
							If SubStr(aFileEmail[nI][3],Len(aFileEmail[nI][3]),1) == ";"
								aFileEmail[nI][3] := SubStr(aFileEmail[nI][3],1,Len(aFileEmail[nI][3])-1)
							Endif
							aRet := GFEMail(aFileEmail[nI][1], cTit, aFileEmail[nI][3], .F., aFileEmail[nI][4])
							If !aRet[1]
								cMsgErro := aRet[2]
								GFEMsgErro(cMsgErro)
								lRet := .F.
							EndIf
		
							//Deleta os arquivos do diretório temporário - Inicio
							For nJ := 1 to Len(aFileEmail[nI][2])
								FErase(aFileEmail[nI][2][nJ])
							Next nJ
							FErase("\xmlgfe\xml.tar")
							FErase("\xmlgfe\xml.tar.gz")
							//Deleta os arquivos do diretório temporário - Fim
						Else
							cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Um ou mais arquivos não foram localizados no diretório informado."
							If !lIsBlind .And. lMenu
								GFEMsgErro(cMsgErro)
							EndIf
							lRet := .F.
						EndIf
					EndIf
				Next nI
			Else
				If !lEnvEdi 
				cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe.Verifique se o tipo de documento de carga está marcado para Envia EDI/NFe."
					If !lIsBlind .And. lMenu
						GFEMsgErro(cMsgErro)
					EndIf
					lRet := .F.	
				Else   		
					If Len(aFiles) == 0 .OR. !lExisDoc
					cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Um ou mais arquivos não foram localizados no diretório informado."
						If !lIsBlind .And. lMenu
							GFEMsgErro(cMsgErro)
						EndIf
						lRet := .F.
					Else
						If !lTemContat
							cMsgErro := "Não foi possível realizar o envio dos arquivos de NFe. Não há contato cadastrado para recebimento dos arquivos XML NFe."
							If !lIsBlind .And. lMenu
								GFEMsgErro(cMsgErro)
							EndIf
							lRet := .F.	
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cEnvXMLNFE == "1"
		cGWNENVNFE := "3" //Enviado ? Não se aplica
	Else
		If lRet
			cGWNENVNFE := "1" //Enviado ? Sim
		Else
			cGWNENVNFE := "2" //Enviado ? Não
		EndIf
	EndIf

	//Atualiza o status para "Enviado"
	Reclock("GWN",.F.)
	If GFXCP12117("GWN_ENVNFE") == .T.
		GWN->GWN_ENVNFE := cGWNENVNFE
	EndIf
	If GFXCP12117("GWN_MOTNFE") == .T.
		GWN->GWN_MOTNFE := cMsgErro
	EndIf
	GWN->(MsUnlock())
	RestArea(aOldArea)
Return lRet

/*/{Protheus.doc} GFEA050CAL
	Função genérica que verifica se o Cálculo (recebido por parâmetro) possui Documento de Frete atrelado.
@author marcos.wagner
@since 20/09/2016
@version 1.0
@param cNrCalc, character, Número do Calculo
@param lEncontrou, logic, Indica se encontrou documento de frete para o cálculo
/*/
Function GFEA050CAL(cNrCalc,lEncontrou,cMsg,lBloqueio)
	Local lCalCDoc     := .F.  // Calculo com documento de frete
	Local oModel65     := Nil
	Local cAliasQry    := Nil
	Default lEncontrou := .F.
	Default lBloqueio  := .F.

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT GW3.GW3_NRDF
		FROM %Table:GWF% GWF
		INNER JOIN %Table:GWH% GWH
		ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
		AND GWH.GWH_NRCALC = GWF.GWF_NRCALC
		AND GWH.%NotDel%
		INNER JOIN %Table:GW4% GW4
		ON GW4.GW4_FILIAL = GWH.GWH_FILIAL
		AND GW4.GW4_TPDC = GWH.GWH_CDTPDC
		AND GW4.GW4_SERDC = GWH.GWH_SERDC
		AND GW4.GW4_EMISDC = GWH.GWH_EMISDC
		AND GW4.GW4_NRDC = GWH.GWH_NRDC
		AND GW4.%NotDel%
		INNER JOIN %Table:GW3% GW3
		ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
		AND GW3.GW3_CDESP = GW4.GW4_CDESP
		AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
		AND GW3.GW3_SERDF = GW4.GW4_SERDF
		AND GW3.GW3_NRDF = GW4.GW4_NRDF
		AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
		AND GW3.GW3_SITFIS = '4'
		AND GW3.%NotDel%
		WHERE GWF.GWF_FILIAL = %xFilial:GWF%
		AND GWF.GWF_NRCALC = %Exp:cNrCalc%
		AND GWF.GWF_NRDF <> ' '
		AND GWF.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		lCalCDoc := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

	If lCalCDoc
		If SuperGetMv("MV_GFEAJDF",,'1') == '1'
			If cMsg == Nil
				Help( ,, 'HELP',, 'Cálculo de frete que já possui um Documento de Frete com o mesmo tipo, não podem ser reajustados.', 1, 0)
			EndIf
			cMsg := 'Cálculo de frete que já possui um Documento de Frete com o mesmo tipo, não podem ser reajustados.'
			lBloqueio := .T.
		Else
			oModel65 := FwLoadModel("GFEA065")
			oModel65:SetOperation(MODEL_OPERATION_UPDATE)
			If oModel65:Activate()
				lCalCDoc := .F. //Utilizado no GFEA050 apenas
				lBloqueio := .F.
			Else
				lCalCDoc := .T. //Utilizado no GFEA050 apenas
				If cMsg == Nil
					Help( ,, 'HELP',, "Não foi possível efetivar/aprovar o ajuste: " +  oModel65:GetErrorMessage()[6], 1, 0)
				EndIf
				cMsg := oModel65:GetErrorMessage()[6]
				lBloqueio := .T.
			EndIf
			oModel65:DeActivate()
			oModel65:Destroy()
			FreeObj(oModel65)
			lEncontrou := .T. //Utilizado no GFEA085 apenas
		EndIf
	Else
		lBloqueio := .F.
	EndIf
Return lCalCDoc

/*/{Protheus.doc} GF50VLROM
	Função que valida e lista os trechos que poderão ser recalculados.
@author siegklenes.beulke
@since 20/09/2016
@version 1.0
@param cNrRom, character, Número do Romaneio
@param lCalcAuto, logico, Uso dde quando utilizar o cálculo automático
/*/
Function GF50VLROM(cNrRom,lCalcAuto,cCalculando)
	Local cAlQuery     := ""
	Local cAlQryGWO    := ""
	Local cQyGWF       := ""
	Local aRet         := {0,{},{},{}} // 0=Todos poderão ser recalculados; 1=alguns poderão ser recalculados; 2= Nenhum poderá ser recalculado; 3= Romaneio calculado no ERP
	Local nCount       := 0
	Local nCntErro     := 0
	Local nF           := 0
	Local nX           := 0
	Local nY           := 0
	Local nPos         := 0
	Local cTrecho      := ""
	Local cQuery       := ""
	Local lOk          := .F.
	Local cGWF_TPCALC  := ""
	Local cGWF_NROCO   := ""
	Local cGWF_NRPREF  := ""
	Local cMV_DPSERV   := SuperGetMV("MV_DPSERV", .F., "1")
	Local cGW3SIT      := ''
	Local lCheck       := GFXCP12116("GWF","GWF_EMISDF") == .T. .And. cMV_DPSERV == "1"
	Local cCampos	   := ""
	Local clftGW4	   := ""
	Local cWhere       := ""
	Local lVerifTrecho := .T.

	If lCheck
		cCampos := " GW4.GW4_NRDC,"
		cCampos += " GWF.GWF_FILIAL GW3_FILIAL,"
		cCampos += " GWF.GWF_NRDF GW3_NRDF," 
		cCampos += " GWF.GWF_CDESP GW3_CDESP,"
		cCampos += " GWF.GWF_EMISDF GW3_EMISDF,"
		cCampos += " GWF.GWF_SERDF GW3_SERDF,"
		cCampos += " GWF.GWF_DTEMDF GW3_DTEMIS"

		clftGW4 := " AND GW4.GW4_EMISDF = GWF.GWF_EMISDF"
		clftGW4 += " AND GW4.GW4_CDESP = GWF.GWF_CDESP"
		clftGW4 += " AND GW4.GW4_SERDF = GWF.GWF_SERDF"
		clftGW4 += " AND GW4.GW4_NRDF = GWF.GWF_NRDF"
		clftGW4 += " AND GW4.GW4_DTEMIS = GWF.GWF_DTEMDF"
	Else
		cCampos := "GW4.GW4_NRDC,"
		cCampos += "GW3.GW3_FILIAL,"
		cCampos += "GW3.GW3_NRDF," 
		cCampos += "GW3.GW3_CDESP,"
		cCampos += "GW3.GW3_EMISDF,"
		cCampos += "GW3.GW3_SERDF,"
		cCampos += "GW3.GW3_DTEMIS"		

		cQuery := " LEFT JOIN " + RetSqlName("GW3") + " GW3"
		cQuery += " ON GW3_FILIAL = '" + xFilial("GW3") + "'"
		cQuery += " AND GW4_EMISDF = GW3_EMISDF"
		cQuery += " AND GW4_CDESP = GW3_CDESP"
		cQuery += " AND GW4_SERDF = GW3_SERDF"
		cQuery += " AND GW4_NRDF  = GW3_NRDF"
		cQuery += " AND GW4_DTEMIS = GW3_DTEMIS"
		cQuery += " AND GW3_TPDF = GWF_TPCALC"
		cQuery += " AND GW3.D_E_L_E_T_ = ' '" 
	EndIf

	If GFXCP1212210('GW1_FILROM')
		cWhere += " GW1.GW1_FILROM = '" + xFilial("GW1") + "'"
	Else
		cWhere += " GW1.GW1_FILIAL = '" + xFilial("GW1") + "'"
	EndIf
	cWhere += " AND GW1.GW1_NRROM = '" + cNrRom + "'"

	cCampos := "%" + cCampos + "%"
	cQuery  := "%" + cQuery + "%"
	cWhere  := "%" + cWhere + "%"
	clftGW4 := "%" + clftGW4 + "%"

	cAlQuery := GetNextAlias()

	BeginSQL Alias cAlQuery
		SELECT DISTINCT GW1.R_E_C_N_O_ GW1_RECNO,
			            GW1.GW1_EMISDC,
						GW1.GW1_SERDC,
						GW1.GW1_NRDC,
						GW1.GW1_CDTPDC,
						GW1.GW1_CDREM,
						GW1.GW1_CDDEST,
						GW1.GW1_ENTEND,
						GW1.GW1_ENTBAI,
						GW1.GW1_ENTNRC,
						GW1.GW1_ENTCEP,
						GW1.GW1_NRREG,
						GW1.GW1_TPFRET,
						GW1.GW1_ICMSDC,
						GW1.GW1_USO,
						GW1.GW1_CARREG,
						GW1.GW1_NRROM,
						GW1.GW1_QTVOL,
						GW1.GW1_FILIAL,
						GW4.GW4_EMISDF,
						GWF.GWF_FILIAL,
						GWF.GWF_NRCALC,
						GWU.GWU_SEQ,
						%Exp: cCampos%
		FROM %Table:GW1% GW1
		INNER JOIN %Table:GWU% GWU
		ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
		AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC 
		AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
		AND GWU.GWU_SERDC = GW1.GW1_SERDC
		AND GWU.GWU_NRDC = GW1.GW1_NRDC
		AND GWU.%NotDel%
		LEFT JOIN %Table:GWH% GWH 
		ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
		AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC 
		AND GWH.GWH_EMISDC = GW1.GW1_EMISDC 
		AND GWH.GWH_SERDC = GW1.GW1_SERDC 
		AND GWH.GWH_NRDC = GW1.GW1_NRDC
		AND GWH.GWH_TRECHO = GWU.GWU_SEQ
		AND GWH.%NotDel%
		LEFT JOIN %Table:GWF% GWF 
		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL 
		AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
		AND GWF.%NotDel%
		LEFT JOIN %Table:GW4% GW4 
		ON GW4.GW4_FILIAL = GWF.GWF_FILIAL
		%Exp:clftGW4%
		AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
		AND GW4.GW4_SERDC = GW1.GW1_SERDC
		AND GW4.GW4_NRDC = GW1.GW1_NRDC
		AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
		AND GW4.%NotDel%
		%Exp:cQuery%
		WHERE %Exp:cWhere%
		AND GW1.GW1_SIT IN ('4','5')
		AND GW1.%NotDel%		
		ORDER BY GW1.R_E_C_N_O_, GWU.GWU_SEQ
	EndSQL

	Do While (cAlQuery)->(!Eof())
		
		nCount++

		cQyGWF := GetNextAlias()
		
		If cCalculando == "ROMANEIO"
			cQuery := " AND GWF.GWF_TPCALC IN ('1','6')"
		Else
			cQuery := " AND GWF.GWF_TPCALC IN ('7')"
			cQuery += " AND GWF.GWF_NROCO = ' '" 
		EndIf

		cQuery := "%" + cQuery + "%"

		BeginSQL Alias cQyGWF
			SELECT GWF.GWF_FILIAL, 
				   GWF.GWF_NRCALC, 
				   GW4.GW4_NRDF, 
				   GWH.GWH_NRCALC, 
				   GW4.GW4_NRDC
			FROM %Table:GWF% GWF
			INNER JOIN %Table:GWH% GWH 
			ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
			AND GWH.GWH_NRCALC = GWF.GWF_NRCALC 
			AND GWH.%NotDel%
			INNER JOIN %Table:GW4% GW4 
			ON GW4.GW4_FILIAL = GWH.GWH_FILIAL
			AND GW4.GW4_TPDC = GWH.GWH_CDTPDC
			AND GW4.GW4_EMISDC = GWH.GWH_EMISDC
			AND GW4.GW4_SERDC = GWH.GWH_SERDC
			AND GW4.GW4_NRDC = GWH.GWH_NRDC
			AND GW4.%NotDel%
			WHERE GWF.GWF_FILIAL = %Exp:(cAlQuery)->GWF_FILIAL%
			AND GWF.GWF_NRCALC = %Exp:(cAlQuery)->GWF_NRCALC%
			AND GWF.GWF_SEQTRE = %Exp:(cAlQuery)->GWU_SEQ%
			AND GW4.GW4_EMISDC = %Exp:(cAlQuery)->GW1_EMISDC%
			AND GW4.GW4_SERDC = %Exp:(cAlQuery)->GW1_SERDC%
			AND GW4.GW4_NRDC = %Exp:(cAlQuery)->GW1_NRDC%
			AND GW4.GW4_TPDC = %Exp:(cAlQuery)->GW1_CDTPDC%
			AND GWF.%NotDel%
			%Exp:cQuery%
		EndSQL
		
		If (cQyGWF)->(!Eof()) .Or. Empty((cAlQuery)->GWF_NRCALC) 
			cGW3SIT := ''
			
			If !Empty((cAlQuery)->GW3_NRDF)
				GW3->(dbSetOrder(1))
				GW3->(dbSeek((cAlQuery)->GW3_FILIAL + (cAlQuery)->GW3_CDESP + (cAlQuery)->GW3_EMISDF + (cAlQuery)->GW3_SERDF + (cAlQuery)->GW3_NRDF + (cAlQuery)->GW3_DTEMIS))
				cGW3SIT := GW3->GW3_SIT
			EndIf

			If (!Empty((cAlQuery)->GW3_NRDF) .And. ;
				(cMV_GFE005 == "1" .Or. (cMV_GFE005 == "2" .And. cGW3SIT $ "34")))
				nCntErro++
				aRet[1] := 1
				aAdd(aRet[2],{.F.,"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
								(cAlQuery)->GW1_EMISDC,;
								(cAlQuery)->GW1_SERDC ,;
								(cAlQuery)->GW1_NRDC  ,;
								(cAlQuery)->GW1_CDTPDC,;
								(cAlQuery)->GW1_CDREM ,;
								(cAlQuery)->GW1_CDDEST,;
								(cAlQuery)->GW1_ENTEND,;
								(cAlQuery)->GW1_ENTBAI,;
								(cAlQuery)->GW1_ENTNRC,;
								(cAlQuery)->GW1_ENTCEP,;
								(cAlQuery)->GW1_NRREG ,;
								(cAlQuery)->GW1_TPFRET,;
								(cAlQuery)->GW1_ICMSDC,;
								(cAlQuery)->GW1_USO   ,;
								(cAlQuery)->GW1_CARREG,;
								(cAlQuery)->GW1_NRROM ,;
								(cAlQuery)->GW1_QTVOL ,;
								(cAlQuery)->GWF_NRCALC,;
								(cAlQuery)->GWU_SEQ,;
								(cAlQuery)->GW4_NRDC,;
								(cAlQuery)->GW4_EMISDF,;
								(cAlQuery)->GW3_NRDF,;
								(cAlQuery)->GW1_FILIAL })

				aAdd(aRet[3],"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
				(cAlQuery)->( dbSkip() )
				(cQyGWF)->(dbCloseArea())
				Loop
			EndIf

			If cGW3SIT $ '12'
				If !Empty((cAlQuery)->GW3_NRDF)
					If ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GW3_FILIAL .And.;
											X[2] == (cAlQuery)->GW3_CDESP  .And.;
											X[3] == (cAlQuery)->GW3_EMISDF .And.;
											X[4] == (cAlQuery)->GW3_SERDF  .And.;
											X[5] == (cAlQuery)->GW3_NRDF   .And.;
											X[6] == (cAlQuery)->GW3_DTEMIS}) == 0
					
						aAdd(aDFReConf, {(cAlQuery)->GW3_FILIAL,;
											(cAlQuery)->GW3_CDESP,;
											(cAlQuery)->GW3_EMISDF,;
											(cAlQuery)->GW3_SERDF,;
											(cAlQuery)->GW3_NRDF,;
											(cAlQuery)->GW3_DTEMIS})
					EndIf

				ElseIf lCheck .And. !Empty((cAlQuery)->GW4B_NRDF)
					nPos := ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GW4B_FILIAL .And.;
												 X[2] == (cAlQuery)->GW4B_CDESP  .And.;
												 X[3] == (cAlQuery)->GW4B_EMISDF .And.;
												 X[4] == (cAlQuery)->GW4B_SERDF  .And.;
												 X[5] == (cAlQuery)->GW4B_NRDF   .And.;
												 X[6] == (cAlQuery)->GW4B_DTEMIS})
					
					If nPos == 0
						aAdd(aDFReConf, {(cAlQuery)->GW4B_FILIAL,;
										 (cAlQuery)->GW4B_CDESP,;
										 (cAlQuery)->GW4B_EMISDF,;
										 (cAlQuery)->GW4B_SERDF,;
										 (cAlQuery)->GW4B_NRDF,;
										 (cAlQuery)->GW4B_DTEMIS})
					EndIf
				EndIf
			EndIf

			(cAlQuery)->(aAdd(aRet[2],{.T.,"OK",GW1_RECNO,;
										GW1_EMISDC,;
										GW1_SERDC ,;
										GW1_NRDC  ,;
										GW1_CDTPDC,;
										GW1_CDREM ,;
										GW1_CDDEST,;
										GW1_ENTEND,;
										GW1_ENTBAI,;
										GW1_ENTNRC,;
										GW1_ENTCEP,;
										GW1_NRREG ,;
										GW1_TPFRET,;
										GW1_ICMSDC,;
										GW1_USO   ,;
										GW1_CARREG,;
										GW1_NRROM ,;
										GW1_QTVOL ,;
										GWF_NRCALC,;
										GWU_SEQ,;
										"",;
										"",;
										"",;
										GW1_FILIAL}))
		EndIf
		(cQyGWF)->(dbCloseArea())
		
		(cAlQuery)->(dbSkip())
	EndDo
	(cAlQuery)->(DbCloseArea())

	If lCheck
		cCampos := " GWF.GWF_FILIAL,"
		cCampos += " GWF.GWF_CDESP,"
		cCampos += " GWF.GWF_EMISDF,"
		cCampos += " GWF.GWF_SERDF,"
		cCampos += " GWF.GWF_NRDF,"
		cCampos += " GWF.GWF_DTEMDF

		cQuery := " AND GW4.GW4_EMISDF = GWF.GWF_EMISDF"
		cQuery += " AND GW4.GW4_CDESP = GWF.GWF_CDESP"
		cQuery += " AND GW4.GW4_SERDF = GWF.GWF_SERDF"
		cQuery += " AND GW4.GW4_NRDF = GWF.GWF_NRDF"
		cQuery += " AND GW4.GW4_DTEMIS = GWF.GWF_DTEMDF"
	Else
		cCampos := " GW4.GW4_FILIAL GWF_FILIAL,"
		cCampos += " GW4.GW4_CDESP AS GWF_CDESP,"
		cCampos += " GW4.GW4_EMISDF AS GWF_EMISDF,"
		cCampos += " GW4.GW4_SERDF AS GWF_SERDF,"
		cCampos += " GW4.GW4_NRDF AS GWF_NRDF,"
		cCampos += " GW4.GW4_DTEMIS AS GWF_DTEMDF"

		cQuery := ""
	EndIf

	cCampos := "%" + cCampos + "%"
	cQuery  := "%" + cQuery + "%"

	cAlQuery := GetNextAlias()
	
	BeginSQL Alias cAlQuery
		SELECT DISTINCT GW1.R_E_C_N_O_ GW1_RECNO,
					    GW1.GW1_EMISDC,
						GW1.GW1_SERDC,
						GW1.GW1_NRDC,
						GW1.GW1_CDTPDC,
						GW1.GW1_CDREM,
						GW1.GW1_CDDEST,
						GW1.GW1_ENTEND,
						GW1.GW1_ENTBAI,
						GW1.GW1_ENTNRC,
						GW1.GW1_ENTCEP,
						GW1.GW1_NRREG,
						GW1.GW1_TPFRET,
						GW1.GW1_ICMSDC,
						GW1.GW1_USO,
						GW1.GW1_CARREG,
						GW1.GW1_NRROM,
						GXD.GXD_CODLOT,
						GWU.GWU_PAGAR,
						GW1.GW1_QTVOL,
						GWF.GWF_ORIGEM,
						GWF.GWF_TPCALC,
						GWF.GWF_NRCALC,
						GWF.GWF_NRPREF,
						GWU.GWU_SEQ,
						GWF.GWF_TRANSP,
						GWF.GWF_NROCO,
						GW1.GW1_FILIAL,
						%Exp:cCampos%	
		FROM %Table:GW1% GW1
		INNER JOIN %Table:GWU% GWU
		ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
		AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
		AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
		AND GWU.GWU_SERDC = GW1.GW1_SERDC
		AND GWU.GWU_NRDC = GW1.GW1_NRDC
		AND GWU.%NotDel%
		LEFT JOIN %Table:GWH% GWH 
		ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
		AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
		AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
		AND GWH.GWH_SERDC = GW1.GW1_SERDC
		AND GWH.GWH_NRDC = GW1.GW1_NRDC
		AND GWH.%NotDel%
		LEFT JOIN %Table:GWF% GWF
		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL 
		AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
		AND GWF.GWF_SEQTRE = GWU.GWU_SEQ
		AND GWF.%NotDel%
		LEFT JOIN %Table:GW4% GW4 
		ON GW4.GW4_FILIAL = GWF.GWF_FILIAL
		%Exp:cQuery%
		AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
		AND GW4.GW4_SERDC = GW1.GW1_SERDC
		AND GW4.GW4_NRDC = GW1.GW1_NRDC
		AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
		AND GW4.%NotDel%
		LEFT JOIN %Table:GXD% GXD 
		ON GXD.GXD_FILCAL = GWH.GWH_FILIAL 
		AND GXD.GXD_NRCALC = GWH.GWH_NRCALC
		AND GXD.%NotDel%
		WHERE %Exp:cWhere%
		AND GW1.GW1_SIT IN ('4','5')
		AND GW1.%NotDel%
		ORDER BY GW1.R_E_C_N_O_, GWF.GWF_NRCALC DESC, GWU.GWU_SEQ
	EndSQL

	Do While (cAlQuery)->(!Eof())
		
		cGWF_TPCALC	:= (cAlQuery)->GWF_TPCALC // 1=Normal;2=Compl Valor;3=Compl Imposto;4=Reentrega;5=Devolucao;6=Redespacho;7=Servico;8=Estimativa
		cGWF_NROCO	:= (cAlQuery)->GWF_NROCO
		cGWF_NRPREF	:= (cAlQuery)->GWF_NRPREF
		CGW1_TPFRET := (cAlQuery)->GW1_TPFRET
		CGWU_PAGAR	:= (cAlQuery)->GWU_PAGAR
		
		If CGWU_PAGAR != "2"
			lVerifTrecho := .F.
		EndIf
		nCount++
		
		If cCalculando == "ROMANEIO"
			lOk := ((cGWF_TPCALC=="1") .OR. (cGWF_TPCALC=="6")) .OR. (CGWU_PAGAR == '2' .AND. CGW1_TPFRET == '3')
		Else
			lOk := ((cGWF_TPCALC=="7") .AND. Empty(cGWF_NROCO))
		EndIf

		If lOk
			If !Empty(cGWF_NRPREF)
				nCntErro++
				aRet[1] := 1
				aAdd(aRet[2],{.F.,"Há cálculos vinculados a Pré-Faturas. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
								(cAlQuery)->GW1_EMISDC,;
								(cAlQuery)->GW1_SERDC ,;
								(cAlQuery)->GW1_NRDC  ,;
								(cAlQuery)->GW1_CDTPDC,;
								(cAlQuery)->GW1_CDREM ,;
								(cAlQuery)->GW1_CDDEST,;
								(cAlQuery)->GW1_ENTEND,;
								(cAlQuery)->GW1_ENTBAI,;
								(cAlQuery)->GW1_ENTNRC,;
								(cAlQuery)->GW1_ENTCEP,;
								(cAlQuery)->GW1_NRREG ,;
								(cAlQuery)->GW1_TPFRET,;
								(cAlQuery)->GW1_ICMSDC,;
								(cAlQuery)->GW1_USO   ,;
								(cAlQuery)->GW1_CARREG,;
								(cAlQuery)->GW1_NRROM ,;
								(cAlQuery)->GW1_QTVOL ,;
								(cAlQuery)->GWF_NRCALC,;
								(cAlQuery)->GWU_SEQ,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GWF_TRANSP,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GW1_FILIAL })
				
				aAdd(aRet[3],"Há cálculos vinculados a Pré-Faturas. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
				(cAlQuery)->(dbSkip())
				Loop
			EndIf
			cGW3SIT := ''
			if !Empty((cAlQuery)->GWF_NRDF)
				GW3->(dbSetOrder(1))
				GW3->(dbSeek((cAlQuery)->GWF_FILIAL + (cAlQuery)->GWF_CDESP + (cAlQuery)->GWF_EMISDF + (cAlQuery)->GWF_SERDF + (cAlQuery)->GWF_NRDF + (cAlQuery)->GWF_DTEMDF)) 
				cGW3SIT := GW3->GW3_SIT
			EndIf

			If (GFXCP12116("GWF","GWF_EMISDF") == .T. .And. !Empty((cAlQuery)->GWF_NRDF) .And. cMV_DPSERV == "1" .And. ;
				(cMV_GFE005 == "1" .Or. (cMV_GFE005 == "2" .And. cGW3SIT $ "34")))
				
				nCntErro++
				aRet[1] := 1
				aAdd(aRet[2],{.F.,"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
								(cAlQuery)->GW1_EMISDC,;
								(cAlQuery)->GW1_SERDC ,;
								(cAlQuery)->GW1_NRDC  ,;
								(cAlQuery)->GW1_CDTPDC,;
								(cAlQuery)->GW1_CDREM ,;
								(cAlQuery)->GW1_CDDEST,;
								(cAlQuery)->GW1_ENTEND,;
								(cAlQuery)->GW1_ENTBAI,;
								(cAlQuery)->GW1_ENTNRC,;
								(cAlQuery)->GW1_ENTCEP,;
								(cAlQuery)->GW1_NRREG ,;
								(cAlQuery)->GW1_TPFRET,;
								(cAlQuery)->GW1_ICMSDC,;
								(cAlQuery)->GW1_USO   ,;
								(cAlQuery)->GW1_CARREG,;
								(cAlQuery)->GW1_NRROM ,;
								(cAlQuery)->GW1_QTVOL ,;
								(cAlQuery)->GWF_NRCALC,;
								(cAlQuery)->GWU_SEQ,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GWF_TRANSP,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GW1_FILIAL })

				aAdd(aRet[3],"Há documentos de carga vinculados a documento de frete. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
				(cAlQuery)->(dbSkip())
				Loop
			Else
				If !Empty((cAlQuery)->GWF_NRDF) .AND. cGW3SIT $ '12'
					if ASCAN(aDFReConf,{|X| X[1] == (cAlQuery)->GWF_FILIAL .And.;
											X[2] == (cAlQuery)->GWF_CDESP  .And.;
											X[3] == (cAlQuery)->GWF_EMISDF .And.;
											X[4] == (cAlQuery)->GWF_SERDF  .And.;
											X[5] == (cAlQuery)->GWF_NRDF   .And.;
											X[6] == (cAlQuery)->GWF_DTEMDF}) == 0

						aAdd(aDFReConf,{(cAlQuery)->GWF_FILIAL,;
										(cAlQuery)->GWF_CDESP,;
										(cAlQuery)->GWF_EMISDF,;
										(cAlQuery)->GWF_SERDF,;
										(cAlQuery)->GWF_NRDF,;
										(cAlQuery)->GWF_DTEMDF})
					EndIf
				EndIf
			EndIf
			
			If !Empty((cAlQuery)->GXD_CODLOT)
				nCntErro++
				aRet[1] := 1
				aAdd(aRet[2],{.F.,"Há cálculos vinculados a Lotes de Provisão. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
								(cAlQuery)->GW1_EMISDC,;
								(cAlQuery)->GW1_SERDC ,;
								(cAlQuery)->GW1_NRDC  ,;
								(cAlQuery)->GW1_CDTPDC,;
								(cAlQuery)->GW1_CDREM ,;
								(cAlQuery)->GW1_CDDEST,;
								(cAlQuery)->GW1_ENTEND,;
								(cAlQuery)->GW1_ENTBAI,;
								(cAlQuery)->GW1_ENTNRC,;
								(cAlQuery)->GW1_ENTCEP,;
								(cAlQuery)->GW1_NRREG ,;
								(cAlQuery)->GW1_TPFRET,;
								(cAlQuery)->GW1_ICMSDC,;
								(cAlQuery)->GW1_USO   ,;
								(cAlQuery)->GW1_CARREG,;
								(cAlQuery)->GW1_NRROM ,;
								(cAlQuery)->GW1_QTVOL ,;
								(cAlQuery)->GWF_NRCALC,;
								(cAlQuery)->GWU_SEQ,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GWF_TRANSP,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GW1_FILIAL })
				
				aAdd(aRet[3],"Há cálculos vinculados a Lotes de Provisão. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
				(cAlQuery)->(dbSkip())
				Loop
			EndIf
	
			If (cAlQuery)->GWF_ORIGEM $ "2;4" .AND. cGWF_TPCALC $ "16"
				nCntErro++
				aRet[1] := 1
				If !lCalcAuto
					aAdd(aRet[2],{.F.,"Há frete combinado ou simulado. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,; //"Romaneio já possui Frete Combinado"
								(cAlQuery)->GW1_EMISDC,;
								(cAlQuery)->GW1_SERDC ,;
								(cAlQuery)->GW1_NRDC  ,;
								(cAlQuery)->GW1_CDTPDC,;
								(cAlQuery)->GW1_CDREM ,;
								(cAlQuery)->GW1_CDDEST,;
								(cAlQuery)->GW1_ENTEND,;
								(cAlQuery)->GW1_ENTBAI,;
								(cAlQuery)->GW1_ENTNRC,;
								(cAlQuery)->GW1_ENTCEP,;
								(cAlQuery)->GW1_NRREG ,;
								(cAlQuery)->GW1_TPFRET,;
								(cAlQuery)->GW1_ICMSDC,;
								(cAlQuery)->GW1_USO   ,;
								(cAlQuery)->GW1_CARREG,;
								(cAlQuery)->GW1_NRROM ,;
								(cAlQuery)->GW1_QTVOL ,;
								(cAlQuery)->GWF_NRCALC,;
								(cAlQuery)->GWU_SEQ,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GWF_TRANSP,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GW1_FILIAL })
					
					aAdd(aRet[3],"Há frete combinado ou simulado. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
					aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
				EndIF
				(cAlQuery)->( dbSkip() )
				Loop
			EndIf
			

				// Ajustes não cancelados relacionados à ocorrência.
				cAlQryGWO := GetNextAlias()

				BeginSQL Alias cAlQryGWO
					SELECT GWO.R_E_C_N_O_ GWO_RECNO 
					FROM %Table:GWO% GWO
					WHERE GWO_FILIAL = %xFilial:GWO%
					AND GWO_NRCALC = %Exp:(cAlQuery)->GWF_NRCALC%
					AND GWO_NROCO <> ' '
					AND GWO_SITAJU IN ('1','2')
					AND GWO.%NotDel%
				EndSQL

				If (cAlQryGWO)->(!Eof())
					nCntErro++
					aRet[1] := 1
					aAdd(aRet[2],{.F.,"Há cálculos cancelados por ocorrência. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.",(cAlQuery)->GW1_RECNO,;
									(cAlQuery)->GW1_EMISDC,;
									(cAlQuery)->GW1_SERDC,;
									(cAlQuery)->GW1_NRDC,;
									(cAlQuery)->GW1_CDTPDC,;
									(cAlQuery)->GW1_CDREM,;
									(cAlQuery)->GW1_CDDEST,;
									(cAlQuery)->GW1_ENTEND,;
									(cAlQuery)->GW1_ENTBAI,;
									(cAlQuery)->GW1_ENTNRC,;
									(cAlQuery)->GW1_ENTCEP,;
									(cAlQuery)->GW1_NRREG,;
									(cAlQuery)->GW1_TPFRET,;
									(cAlQuery)->GW1_ICMSDC,;
									(cAlQuery)->GW1_USO,;
									(cAlQuery)->GW1_CARREG,;
									(cAlQuery)->GW1_NRROM,;
									(cAlQuery)->GW1_QTVOL,;
									(cAlQuery)->GWF_NRCALC,;
									(cAlQuery)->GWU_SEQ,;
									(cAlQuery)->GWF_NRDF,;
									(cAlQuery)->GWF_TRANSP,;
									(cAlQuery)->GWF_NRDF,;
									(cAlQuery)->GW1_FILIAL})

					aAdd(aRet[3],"Há cálculos cancelados por ocorrência. Os novos cálculos gerados podem apresentar valores diferentes do cálculo original.")
					aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)

					(cAlQryGWO)->(dbCloseArea())
					(cAlQuery)->(dbSkip())
					Loop
				EndIf

				(cAlQryGWO)->(dbCloseArea())


			If CGW1_TPFRET == '3' .And. CGWU_PAGAR == '2' 
				nCntErro++
				aRet[1] := 1
				aAdd(aRet[2],{.F.,"Documentos de carga com sentido saída e tipo de frete FOB não efetuam cálculo.",(cAlQuery)->GW1_RECNO,;
								(cAlQuery)->GW1_EMISDC,;
								(cAlQuery)->GW1_SERDC ,;
								(cAlQuery)->GW1_NRDC  ,;
								(cAlQuery)->GW1_CDTPDC,;
								(cAlQuery)->GW1_CDREM ,;
								(cAlQuery)->GW1_CDDEST,;
								(cAlQuery)->GW1_ENTEND,;
								(cAlQuery)->GW1_ENTBAI,;
								(cAlQuery)->GW1_ENTNRC,;
								(cAlQuery)->GW1_ENTCEP,;
								(cAlQuery)->GW1_NRREG ,;
								(cAlQuery)->GW1_TPFRET,;
								(cAlQuery)->GW1_ICMSDC,;
								(cAlQuery)->GW1_USO   ,;
								(cAlQuery)->GW1_CARREG,;
								(cAlQuery)->GW1_NRROM ,;
								(cAlQuery)->GW1_QTVOL ,;
								(cAlQuery)->GWF_NRCALC,;
								(cAlQuery)->GWU_SEQ,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GWF_TRANSP,;
								(cAlQuery)->GWF_NRDF,;
								(cAlQuery)->GW1_FILIAL})
				
				aAdd(aRet[3],"Documentos de carga com sentido saída e tipo de frete FOB não efetuam cálculo.")
				aAdd(aRet[4],(cAlQuery)->GWF_NRCALC)
				(cAlQuery)->(dbSkip())
				Loop
			EndIf

		EndIf
		aAdd(aRet[2],{.T.,"OK" ,(cAlQuery)->GW1_RECNO,;
						(cAlQuery)->GW1_EMISDC,;
						(cAlQuery)->GW1_SERDC ,;
						(cAlQuery)->GW1_NRDC  ,;
						(cAlQuery)->GW1_CDTPDC,;
						(cAlQuery)->GW1_CDREM ,;
						(cAlQuery)->GW1_CDDEST,;
						(cAlQuery)->GW1_ENTEND,;
						(cAlQuery)->GW1_ENTBAI,;
						(cAlQuery)->GW1_ENTNRC,;
						(cAlQuery)->GW1_ENTCEP,;
						(cAlQuery)->GW1_NRREG ,;
						(cAlQuery)->GW1_TPFRET,;
						(cAlQuery)->GW1_ICMSDC,;
						(cAlQuery)->GW1_USO   ,;
						(cAlQuery)->GW1_CARREG,;
						(cAlQuery)->GW1_NRROM ,;
						(cAlQuery)->GW1_QTVOL ,;
						(cAlQuery)->GWF_NRCALC,;
						(cAlQuery)->GWU_SEQ,;
						"",;
						(cAlQuery)->GWF_TRANSP,;
						"",;
						(cAlQuery)->GW1_FILIAL })
		(cAlQuery)->(dbSkip())
	EndDo

	(cAlQuery)->(dbCloseArea())

	aSort(aRet[2],,,{|x,y| x[7]+x[4]+x[5]+x[6]+x[22]      < y[7]+y[4]+y[5]+y[6]+y[22]})
	
	nX := 1
	nF := Len(aRet[2])
	Do While nX <= nF
		cTrecho := aRet[2,nX,7]+aRet[2,nX,4]+aRet[2,nX,5]+aRet[2,nX,6]+aRet[2,nX,22]
		nY := nX + 1
		Do While nY <= Len(aRet[2]) .And. cTrecho == aRet[2,nY,7]+aRet[2,nY,4]+aRet[2,nY,5]+aRet[2,nY,6]+aRet[2,nY,22]
			If aRet[2,nY,1] == .F.
				aRet[2,nX,1] := .F.
				aRet[2,nX,2] := aRet[2,nY,2]
			EndIf
			aDel(aRet[2],nY)
			aSize(aRet[2],nF-1)
			nF--
		EndDo
		nX++
	EndDo
	
	aSort(aRet[2],,,{|x,y| x[21]+x[7]+x[4]+x[5]+x[6]      < y[21]+y[7]+y[4]+y[5]+y[6]})
	// Remover todos os trechos que não puderem ser recalculados dentro de um cálculo. 
	// Caso o documento possua um trecho que se encaixe em outro cálculo e não houver impedimento, esse outro cálculo será recalculado.
	nF := Len(aRet[2])
	For nX := 1 To nF
		If aRet[2,nX,1] == .F.
			If !Empty(aRet[2,nX,21])
				nPos := aScan(aRet[2],{|y|y[21] == aRet[2,nX,21]})
			Else
				nPos := Len(aRet[2]) + 1
			EndIf
			Do While nPos <= Len(aRet[2]) .And. aRet[2,nPos,21] == aRet[2,nX,21]
				If aRet[2,nPos,1]
					nCntErro++
				EndIf
				aRet[2,nPos,1] := .F.
				nPos++
			EndDo
		EndIf
	Next nX

	nCount := Len(aRet[2])
	nCntErro := 0
		For nX := 1 To nCount
			If aRet[2,nX,1] == .F.
				nCntErro++
			Else
				If Posicione("GWU", 1, xFilial("GW1") + aRet[2,nX,7] + aRet[2,nX,4] + aRet[2,nX,5] + aRet[2,nX,6] + aRet[2,nX,22],"GWU_PAGAR") == "2"	// Posiciona no trecho e veja se o pagar é não
					nCntErro++
					aAdd(aRet[3],"Documento(s) de carga relacionado(s) ao romaneio possui trecho(s) não pago(s).")
				EndIf
			EndIf
		Next nX
	
	aSort(aRet[3])
	nX := 1
	nF := Len(aRet[3])
	Do While nX <= nF
		cTrecho := aRet[3,nX]
		nY := nX + 1
		Do While nY <= Len(aRet[3]) .And. cTrecho == aRet[3,nY]
			aDel(aRet[3],nY)
			aSize(aRet[3],nF-1)
			nF--
		EndDo
		nX++
	EndDo

	If nCount == nCntErro
		aRet[1] := 2
	ElseIf nCount > nCntErro .And. nCntErro > 0 .and. lVerifTrecho == .T.
		aRet[1] := 1
	EndIf
	aSort(aRet[2],,,{|x,y| StrZero(x[3],10) + x[22] < StrZero(y[3],10) + y[22]})
Return aRet

Function GF50ARCLC(aDocsCarg,aDocCarg,aItDoc,aTrchDoc,aNoCalc)
	Local nQtdeUnit  := 0
	Local aTrechos   := {}
	Local nF         := 0
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0
	Local nChave     := 0
	Local aUnitiliz  := {}
	Local lGW8VALLIQ := GFXCP12118("GW8_VALLIQ") .Or. SuperGetMv("MV_ERPGFE",.F.,"2") == "4" // LOGIX - tratamento de contorno para falha de teste de existência do campo durante o cálculo automático executado pela integração via adapter EAI
	Local lGFE05014  := ExistBlock("GFE05014")
	Local aCtcPE     := nil

	nF := Len(aDocsCarg[2])
	For nX := 1 To nF
		If aDocsCarg[2,nX,1]
			If nChave != aDocsCarg[2,nX,3]// É permitido recalcular e o documento não repetiu
				aUnitiliz := {}
				nChave := aDocsCarg[2,nX,3]
				// Obtem a quantidade de unitizadores (embalagens) do documento de carga
				nQtdeUnit := 0

				GWB->( dbSetOrder(2) )
				GWB->( dbSeek(aDocsCarg[2,nX,26] + aDocsCarg[2,nX,7] + aDocsCarg[2,nX,4] + aDocsCarg[2,nX,5] + aDocsCarg[2,nX,6]) )
				Do While GWB->( !Eof() ) ;
						.And. GWB->GWB_FILIAL == aDocsCarg[2,nX,26] ;
						.And. GWB->GWB_CDTPDC == aDocsCarg[2,nX,7] ;
						.And. GWB->GWB_EMISDC == aDocsCarg[2,nX,4] ;
						.And. GWB->GWB_SERDC  == aDocsCarg[2,nX,5] ;
						.And. GWB->GWB_NRDC   == aDocsCarg[2,nX,6]

					nQtdeUnit += GWB->GWB_QTDE

					nPos := aScan(aUnitiliz,{|x|x[1] == GWB->GWB_CDUNIT })
					If nPos == 0
						aAdd(aUnitiliz,{GWB->GWB_CDUNIT,GWB->GWB_QTDE})
					Else
						aUnitiliz[nPos][2] += GWB->GWB_QTDE
					EndIf
					GWB->( dbSkip() )
				EndDo
				aAdd(aDocCarg, {aDocsCarg[2,nX,4],; //Emitente do Documento
				aDocsCarg[2,nX,5],; //Serie do Documento
				aDocsCarg[2,nX,6],; //Numero do Documento
				aDocsCarg[2,nX,7],; //Tipo do Documento
				aDocsCarg[2,nX,8],; //Remetente do Documento
				aDocsCarg[2,nX,9],; //Destinatario do Documento
				aDocsCarg[2,nX,10],; //Endereco de Entrega
				aDocsCarg[2,nX,11],; //Bairro de entrega
				aDocsCarg[2,nX,12],; //Cidade de Entrega
				aDocsCarg[2,nX,13],; //CEP de Entrega
				aDocsCarg[2,nX,14],; //Região de destino
				aDocsCarg[2,nX,15],; //Tipo de Frete
				aDocsCarg[2,nX,16],; //ICMS?
				aDocsCarg[2,nX,17],; //Finalidade da mercadoria
				aDocsCarg[2,nX,18],; //Número do carregamento
				aDocsCarg[2,nX,19],; //Numero do Agrupador
				If(nQtdeUnit > 0, nQtdeUnit, aDocsCarg[2,nX,20]),; //Quantidade de Unitizadores ou qtde de volumes do documento de carga
					aUnitiliz,; //Codigo do Unitilizador + Quantidade do Unitilizador
					aDocsCarg[2,nX,26]}) //Codigo do Unitilizador + Quantidade do Unitilizador

					GW8->( dbSetOrder(1) )
					GW8->( dbSeek(aDocsCarg[2,nX,26] + aDocsCarg[2,nX,7] + aDocsCarg[2,nX,4] + aDocsCarg[2,nX,5] + aDocsCarg[2,nX,6]) )
					Do While GW8->( !Eof() ) ;
							.And. GW8->GW8_FILIAL == aDocsCarg[2,nX,26] ;
							.And. GW8->GW8_CDTPDC == aDocsCarg[2,nX,7] ;
							.And. GW8->GW8_EMISDC == aDocsCarg[2,nX,4] ;
							.And. GW8->GW8_SERDC == aDocsCarg[2,nX,5] ;
							.And. GW8->GW8_NRDC == aDocsCarg[2,nX,6]

						aAdd(aItDoc, {GW8->GW8_EMISDC,; // Emitente do Documento
						GW8->GW8_SERDC ,; // Serie do Documento
						GW8->GW8_NRDC  ,; // Numero do Documento
						GW8->GW8_CDTPDC,; // Tipo do Documento
						GW8->GW8_ITEM  ,; // Item
						GW8->GW8_CDCLFR,; // ClassIficacao de Frete
						GW8->GW8_TPITEM,; // ClassIficacao de Frete
						GW8->GW8_QTDE  ,; // Quantidade do Item
						GW8->GW8_PESOR ,; // Peso do Item
						GW8->GW8_PESOC ,; // Peso Cubado
						GW8->GW8_QTDALT,; // Quantidade/Peso Alternativo
						GW8->GW8_VALOR ,; // Valor do Item
						GW8->GW8_VOLUME,; // Volume ocupado (m3)
						GW8->GW8_TRIBP, ; // Frete tributado PIS
						IIf(lGW8VALLIQ,GW8->GW8_VALLIQ,0),; // Valor Liquido
						GW8->GW8_FILIAL }) // Valor Liquido
						GW8->( dbSkip() )
					EndDo
				EndIf

				aTrechos := XFBGWUDC(,aDocsCarg[2,nX,26],aDocsCarg[2,nX,7],aDocsCarg[2,nX,4],aDocsCarg[2,nX,5],aDocsCarg[2,nX,6],aDocsCarg[2,nX,22])
				nZ := Len(aTrechos)
				For nY := 1 To nZ
					aAdd(aTrchDoc,aClone(aTrechos[nY]))
				Next nY
			Else

				aTrechos := XFBGWUDC(,aDocsCarg[2,nX,26],aDocsCarg[2,nX,7],aDocsCarg[2,nX,4],aDocsCarg[2,nX,5],aDocsCarg[2,nX,6],aDocsCarg[2,nX,22])
				nZ := Len(aTrechos)
				For nY := 1 To nZ
					aTrechos[nY,9] := "2" // Considera não pago.
					aAdd(aTrchDoc,aClone(aTrechos[nY]))
				Next nY
			EndIf
		Next nX
		aNoCalc := aDocsCarg[4]

		// Ponto de entrada
		If lGFE05014
			aCtcPE := ExecBlock("GFE05014",.F.,.F.,{aTrchDoc})
			If ValType(aCtcPE) == 'A' .And. !Empty(aCtcPE)
				aTrchDoc := aCtcPE
			EndIf
		EndIf
		Return

/*/{Protheus.doc} GFE50NRROM
//TODO Gerar a numeração do romaneio. É utilizada no GFEA044 e pode ser utilizada na inicialização padrão do campo GWN_NRROM.
@author andre.wisnheski
@since 19/02/2018
@version 1.0
@return ${return}, ${Novo número do romaneio}

@type function
/*/
function GFE50NRROM()
	Local lAtrNewCod := !(IsInCallStack('OMSA200') .Or. IsInCallStack('OMSXCPL7') .Or. IsInCallStack('OMSATPR2') .Or. IsInCallStack('OMSM011DAK') .Or. IsInCallStack('GFEM011DAK'))
	Local cNewCod    := ""
	Local cSeqCar    := '01'

	If lAtrNewCod	//Caso o cliente queira fazer uma numeração própria
		If ExistBlock("GFE05011")
			cNewCod := ExecBlock("GFE05011",.F.,.F.)
		Else
			If SuperGetMv("MV_ERPGFE",.F.,"1") == "2" .And. SuperGetMv("MV_GFEI12",.F.,"2") == "1"
				cNewCod := GetSXENum("DAK","DAK_COD") + cSeqCar
				Do While (GFEA50GWN(xFilial("GWN"),cNewCod))
					ConfirmSX8()
					cNewCod := GetSXENum("DAK","DAK_COD") + cSeqCar
				EndDo
			Else
				cNewCod := GetSXENum("GWN","GWN_NRROM")
				Do While (GFEA50GWN(xFilial("GWN"),cNewCod))
					ConfirmSX8()
					cNewCod := GetSXENum("GWN","GWN_NRROM")
				EndDo
			EndIf
		EndIf
	EndIf

Return cNewCod

/*/{Protheus.doc} GFEA50GWN
//TODO Verifica se o numero do romaneio solicitado já existe na base de dados.
@author andre.wisnheski
@since 19/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilGWN, characters, Filial
@param cNrGWN, characters, Romaneio
@type function
/*/
Function GFEA50GWN(cFilGWN, cNrGWN)
	Local lRet      := .T.
	Local cAliasGWN := GetNextAlias()

	BeginSql Alias cAliasGWN
		SELECT GWN.GWN_FILIAL
		FROM %Table:GWN% GWN
		WHERE GWN.GWN_FILIAL = %Exp:cFilGWN%
		AND GWN.GWN_NRROM = %Exp:cNrGWN%
		AND GWN.%NotDel%
	EndSql
	lRet := (cAliasGWN)->(!Eof())
	(cAliasGWN)->(dbCloseArea())
Return lRet

Function GFEA50GXT(cFilRom, cNrRom)
	Local aTblFrt := Array(21)
	Local lRet    := .F.

	aTblFrt[21]:= ''

	If GFXCP12121('GWN_NRCT')
		// Valida contrato de transporte para o transportador
		if cFilRom != Nil
			//Localiza o Romaneio
			GWN->(dbSetOrder(01))
			GWN->(DbSeek(cFilRom + cNrRom))
		EndIf
		If !Empty(GWN->GWN_NRCT)
			GXT->( dbSetOrder(01) )
			If GXT->( dbSeek(xFilial("GXT") + GWN->GWN_NRCT) )
				aTblFrt[1] := GXT->GXT_CDTRP
				aTblFrt[2] := GXT->GXT_NRTAB
				aTblFrt[20]:= GXT->GXT_NRNEG
				aTblFrt[21]:= GWN->GWN_NRCT
				lRet := .T.
			EndIf
		EndIf
	EndIf
Return {lRet, aTblFrt}

Function GFE50DFCONF(lmsg)
	Local cRet      := ""
	Local oModelPai := FWLoadModel("GFEA065")
	Local oModelGW3 := oModelPai:GetModel("GFEA065_GW3")

	Default lmsg := .T.

	oModelPai:SetOperation(MODEL_OPERATION_UPDATE)
	If oModelPai:Activate()
		If !oModelGW3:SetValue("GW3_SIT","1")
			Help(,,"HELP",, oModelPai:GetErrorMessage()[6],1,0)
		EndIf

		If oModelPai:VldData()
			oModelPai:CommitData()
		Else
			Help(,,"HELP",, oModelPai:GetErrorMessage()[6],1,0)
		EndIf
	ElseIf FwIsInCallStack("GFEA065")
		If lmsg
			Help(,,"HELP",, "Tentativa de recálculo de Frete. Motivo de não ser executado o recálculo: " + oModelPai:GetErrorMessage()[6],1,0)
		Else
			cRet := "Tentativa de recálculo de Frete. Motivo de não ser executado o recálculo: " + oModelPai:GetErrorMessage()[6]
		EndIf
	EndIf

	oModelPai:Deactivate()
	oModelPai:Destroy(oModelPai)
	oModelPai := Nil
Return cRet

Function GFEDISTAN(nHODRET,nHODSAI)
	Local nDistan := 0

	If nHODRET > nHODSAI
		nDistan := nHODRET - nHODSAI
	EndIf

	If nHODRET < nHODSAI
		nDistan:= (nHODRET+1000000)-nHODSAI
	EndIf
Return nDistan

Function GFEA50VCAL(cFilRom, nNrRom)
	Local oSize      := Nil
	Local oFWLayer   := Nil
	Local oLayerTot  := Nil
	Local oLayerCalc := Nil
	Local aNewButton := {}
	Local aColDef    := {}
	Local cAliasTmp  := ""
	Local cAliasAux  := ""
	Local aOrigem    := RetSx3Box(Posicione('SX3',2,'GWF_ORIGEM','X3CBox()'),,,1)
	Local aTpCalc    := RetSx3Box(Posicione('SX3',2,'GWF_TPCALC','X3CBox()'),,,1)
	Local aTpFret    := RetSx3Box(Posicione('SX3',2,'GWF_TPFRET','X3CBox()'),,,1)
	Local aFinCal    := RetSx3Box(Posicione('SX3',2,'GWF_FINCAL','X3CBox()'),,,1)
	Local aIdFrVi    := RetSx3Box(Posicione('SX3',2,'GWF_IDFRVI','X3CBox()'),,,1)
	Local aAgrup     := RetSx3Box(Posicione('SX3',2,'GWF_AGRUP' ,'X3CBox()'),,,1)
	Local nRomVlFrt  := 0
	Local nCalcVlFrt := 0
	Local nFrtNormal := 0
	Local nFrtRedesp := 0
	Local nRomAjus	 := 0
	Local nQtdCalc	 := 0

	Default cFilRom  := ""
	Default nNrRom   := ""

	Private aData    := {}
	Private oGrid    := Nil

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 100, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 400, 800})
	oSize:lLateral := .T.  // Calculo vertical
	oSize:Process() //executa os calculos

	DEFINE MSDIALOG oDlgCalc TITLE "Cálculos do Romaneio" ;
		FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
		TO oSize:aWindSize[3],oSize:aWindSize[4] ;
		COLORS 0, 16777215 PIXEL

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgCalc, .F., .T.)

	oFWLayer:AddLine('TOTAL', 20, .T.)
	oFWLayer:AddCollumn('COL1', 100, .T., 'TOTAL')
	oFWLayer:AddLine('CALC', 80, .T.)
	oFWLayer:AddCollumn('COL2', 100, .T., 'CALC')

	oLayerTot  := oFWLayer:GetColPanel('COL1', 'TOTAL')
	oLayerCalc := oFWLayer:GetColPanel('COL2', 'CALC')

	Aadd(aColDef, {1, "Valor de Frete"      , 85, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {2, "Filial"			    , 70, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {3, "Nr Cálculo"			, 70, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {4, "Transportador"		, 100,CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {5, "Nome Transportador"  , 150,CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {6, "Origem Valor"		, 85, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {7, "Tipo de Cálculo"	    , 85, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {8, "Tipo Frete"			, 70, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {9, "Finalidade"			, 70, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {10, "Valor Ajuste"		, 70, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {11, "Frete Viagem"		, 70, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {12, "Agrupado"			, 70, CONTROL_ALIGN_LEFT})
	Aadd(aColDef, {13, "Sequência"			, 70, CONTROL_ALIGN_LEFT})

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT GWF.GWF_FILIAL,
				GWF.GWF_NRCALC,
				GWF.GWF_VLAJUS,
				GWF.GWF_TPCALC,
				GWF.GWF_TRANSP,
				GWF.GWF_ORIGEM,
				GWF.GWF_TPFRET,
				GWF.GWF_FINCAL,
				GWF.GWF_IDFRVI,
				GWF.GWF_AGRUP,
				GWF.GWF_SEQTRE
		FROM %Table:GWF% GWF
		WHERE GWF.GWF_FILROM = %Exp:cFilRom%
		AND GWF.GWF_NRROM = %Exp:nNrRom%
		AND GWF.%NotDel%
	EndSql

	nRomVlFrt  := 0
	nFrtNormal := 0
	nFrtRedesp := 0
	nRomAjus   := 0
	nQtdCalc   := 0

	Do While (cAliasTmp)->(!Eof())
		nCalcVlFrt := 0
		nQtdCalc++

		cAliasAux := GetNextAlias()
		BeginSql Alias cAliasAux
			SELECT SUM(GWI.GWI_VLFRET) AS GWI_VLFRET
			FROM %Table:GWI% GWI
			WHERE GWI.GWI_FILIAL = %Exp:(cAliasTmp)->GWF_FILIAL%
			AND GWI.GWI_NRCALC = %Exp:(cAliasTmp)->GWF_NRCALC%
			AND GWI.%NotDel%
		EndSql

		nCalcVlFrt := (cAliasAux)->GWI_VLFRET + (cAliasTmp)->GWF_VLAJUS
		nRomVlFrt  += nCalcVlFrt

		If (cAliasTmp)->GWF_TPCALC == "1"
			nFrtNormal += (cAliasAux)->GWI_VLFRET
		ElseIf (cAliasTmp)->GWF_TPCALC == "6"
			nFrtRedesp += (cAliasAux)->GWI_VLFRET
		EndIf
		(cAliasAux)->(dbCloseArea())

		nRomAjus += (cAliasTmp)->GWF_VLAJUS

		Aadd(aData, {Transform(nCalcVlFrt,"@E 999,999.99"),;
			(cAliasTmp)->GWF_FILIAL,;
			(cAliasTmp)->GWF_NRCALC,;
			(cAliasTmp)->GWF_TRANSP,;
			Posicione("GU3",1,xFilial("GU3")+(cAliasTmp)->GWF_TRANSP,"GU3_NMEMIT"),;
			aOrigem[Val((cAliasTmp)->GWF_ORIGEM)][3],;
			aTpCalc[Val((cAliasTmp)->GWF_TPCALC)][3],;
			aTpFret[Val((cAliasTmp)->GWF_TPFRET)][3],;
			aFinCal[Val((cAliasTmp)->GWF_FINCAL)][3],;
			Transform((cAliasTmp)->GWF_VLAJUS,"@E 999,999.99"),;
			aIdFrVi[Val((cAliasTmp)->GWF_IDFRVI)][3],;
			aAgrup[Val((cAliasTmp)->GWF_AGRUP)][3],;
			(cAliasTmp)->GWF_SEQTRE})

		(cAliasTmp)->(dbSkip())
	EndDo

	@ 10, 015  SAY "Filial:" SIZE 25,7 PIXEL OF oLayerTot
	@ 10, 045 MSGET cFilRom When .F. SIZE 40,7 PIXEL OF oLayerTot

	@ 10, 100  SAY "Romaneio:" SIZE 25,7 PIXEL OF oLayerTot
	@ 10, 130 MSGET nNrRom When .F. SIZE 40,7 PIXEL OF oLayerTot

	@ 10, 185  SAY "Qtd Calc:" SIZE 25,7 PIXEL OF oLayerTot
	@ 10, 215 MSGET nQtdCalc When .F. SIZE 40,7 PIXEL OF oLayerTot

	@ 25, 015  SAY "Frt Total:" SIZE 25,7 PIXEL OF oLayerTot
	@ 25, 045 MSGET Transform(nRomVlFrt,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

	@ 25, 100  SAY "Frt Norm:" SIZE 25,7 PIXEL OF oLayerTot
	@ 25, 130 MSGET Transform(nFrtNormal,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

	@ 25, 185  SAY "Frt Redes:" SIZE 25,7 PIXEL OF oLayerTot
	@ 25, 215 MSGET Transform(nFrtRedesp,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

	@ 25, 270  SAY "Frt Ajuste:" SIZE 25,7 PIXEL OF oLayerTot
	@ 25, 300 MSGET Transform(nRomAjus,"@E 999,999.99") When .F. SIZE 40,7 PIXEL OF oLayerTot

	oGrid:= GFEGrid():New(oLayerCalc,aData,8,120,390,aColDef,"{ ||GFEA50DET()}")
	oGrid:SetFreeze(1)
	(cAliasTmp)->(dbCloseArea())
	ACTIVATE MSDIALOG oDlgCalc ON INIT EnchoiceBar(oDlgCalc,{||oDlgCalc:End()},{||oDlgCalc:End()},,aNewButton) CENTERED
Return

Function GFEA50DET()
	Local aCurPos := {}
	Local nLinha  := 0

	aCurPos := oGrid:GetCursorPos()
	nLinha := aCurPos[1] + 1
	If nLinha > 0
		GWF->(dbSetOrder(1))
		If GWF->(dbSeek(aData[nLinha][2] + aData[nLinha][3]))
			FWExecView("Visualiza", "GFEC080", 1,,{|| .T.})
		EndIf
	EndIf
Return

Static Function ValCalcLot()
	Local lRet := .T.
	// Validar se o romaneio possui cálculos vinculados a lotes de provisão
	GWF->( dbSetOrder(4) )
	GWF->( dbSeek(xFilial("GWF") + GWN->GWN_NRROM) )
	Do While lRet .And. GWF->( !Eof() ) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. GWF->GWF_NRROM == GWN->GWN_NRROM

		GXD->(DbSetOrder(2))
		If GXD->(DbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
			lRet := .F.
		EndIf
		GWF->( dbSkip() )
	EndDo
Return lRet

// Função para verificar se o(s) Documento(s) de Carga relacionados possuem Documento de Frete.
// Se o documento frete estiver na situação bloqueado, executar a rotina de auditoria de frete. 
Function GFE050AUDIT(cFilDc, cCDTPDC,cEMISDC,cSERDC,cNRDC)
	Local aAreaGW3  := GW3->(GetArea())
	Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT GW3.R_E_C_N_O_ AS GW3Recno
		  FROM %Table:GW1% GW1
		 INNER JOIN %Table:GW4% GW4
		ON GW4.GW4_FILIAL = GW1.GW1_FILIAL
		AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
		AND GW4.GW4_SERDC = GW1.GW1_SERDC
		AND GW4.GW4_NRDC = GW1.GW1_NRDC
		AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
		AND GW4.%NotDel%
		INNER JOIN %Table:GW3% GW3
		ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
		AND GW3.GW3_CDESP = GW4.GW4_CDESP
		AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
		AND GW3.GW3_SERDF = GW4.GW4_SERDF
		AND GW3.GW3_NRDF = GW4.GW4_NRDF
		AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
		AND GW3.GW3_SIT IN ('2','5')
		AND GW3.GW3_TPDF IN ('1','4','5','6','7')
		AND GW3.%NotDel%
		WHERE GW1.GW1_FILIAL = %Exp:cFilDc%
		AND GW1.GW1_CDTPDC = %Exp:cCDTPDC%
		AND GW1.GW1_EMISDC = %Exp:cEMISDC%
		AND GW1.GW1_SERDC = %Exp:cSERDC%
		AND GW1.GW1_NRDC = %Exp:cNRDC%
		AND GW1.%NotDel%
		ORDER BY %Order:GW1%
	EndSql
	Do While (cAliasQry)->(!Eof())
		GW3->( DbGoTo( (cAliasQry)->GW3Recno ) )
		GFE50DFCONF()
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaGW3)
Return

// Função para verificar se calculo usado possui algum componente ativo do tipo serviço que calcula por romaneio.
Static Function ChkCompServ()
	Local lRet      := .F.
	Local cAliasQry := GetNextAlias()
	Local cCodFil   := GWF->GWF_FILIAL
	Local cCodTrp   := GWF->GWF_TRANSP
	Local cNrCalc   := GWF->GWF_NRCALC

	BeginSql Alias cAliasQry
		SELECT GWG.R_E_C_N_O_ AS RECNOGWG
		FROM %Table:GWG% GWG					// Tabela do Calculo de Frete
		INNER JOIN %Table:GWI% GWI				// Componentes do calculo de Frete
		ON GWI.GWI_FILIAL = GWG.GWG_FILIAL
		AND GWI.GWI_NRCALC = GWG.GWG_NRCALC
		AND GWI.GWI_CDCLFR = GWG.GWG_CDCLFR
		AND GWI.GWI_CDTPOP = GWG.GWG_CDTPOP
		AND GWI.%NotDel%
		INNER JOIN %Table:GV2% GV2				// Cadastro de Componentes
		ON GV2.GV2_FILIAL = %xFilial:GV2%
		AND GV2.GV2_CDCOMP = GWI.GWI_CDCOMP
		AND GV2.GV2_SERVI = '1'
		AND GV2.GV2_CALSER = '2'				// 1-Ocorrencia, 2-Romaneio
		AND GV2.%NotDel%
		WHERE GWG.GWG_FILIAL = %Exp:cCodFil%
		AND GWG.GWG_NRCALC = %Exp:cNrCalc%
		AND GWG.GWG_CDEMIT = %Exp:cCodTrp%
		AND GWG.%NotDel%
	EndSql
	If (cAliasQry)->( !Eof() )
		lRet := .T.

		(cAliasQry)->(dbSkip())
	EndIf
	(cAliasQry)->(dbCloseArea())

Return lRet

// Manipula dados do romaneio para atualização de tabela agrupador para Relatorio de Movimentação de Documento de Carga
Static Function LoadMovtoDoc(nOpc)
	Local i 		:= 0
	Local aAuxGX0   := {}
	Local cAliasGX0 := Nil
	Local cAliasGW1 := Nil
	Local cAliasGW8 := Nil
	Local cAliasGWU := Nil
	Local oMovDocto := GFEMovtoCarga():New()

	Default aAuxDc := {}

	If !Empty(nOpc)

		If nOpc == MODEL_OPERATION_INSERT
			oMovDocto:setBranch(GWN->GWN_FILIAL)
			oMovDocto:setFilRomaneio(GWN->GWN_FILIAL)
			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
			oMovDocto:setClassFrete(GWN->GWN_CDCLFR)
			oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB")+GWN->GWN_CDCLFR, "GUB_DSCLFR"))
			oMovDocto:setTipoOper(GWN->GWN_CDTPOP)
			oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4")+GWN->GWN_CDTPOP, "GV4_DSTPOP"))

			cAliasGW1 := oMovDocto:SearchDCByRomaneio()
			While (cAliasGW1)->(!Eof())
				GW1->(dbGoTo( (cAliasGW1)->RECNUM ))

				cCidDest := Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDDEST, "GU3_NRCID")
				cCidRem  := Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDREM, "GU3_NRCID")

				oMovDocto:setBranch(GW1->GW1_FILIAL)
				oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
				oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
				oMovDocto:setSerieNF(GW1->GW1_SERDC)
				oMovDocto:setNumeroNF(GW1->GW1_NRDC)
				oMovDocto:setDataNF(GW1->GW1_DTEMIS)
				oMovDocto:setNomeEmitente(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_EMISDC, "GU3_NMEMIT"))
				oMovDocto:setDestinatarioNF(GW1->GW1_CDDEST)
				oMovDocto:setNomeDestinat(Alltrim(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDDEST, "GU3_NMEMIT")))
				oMovDocto:setCidDestinat(cCidDest)
				oMovDocto:setUFDestinat(Posicione("GU7", 1, xFilial("GU7")+cCidDest, "GU7_CDUF"))
				oMovDocto:setDataSaida(GW1->GW1_DTSAI)
				oMovDocto:setRepresentante(GW1->GW1_REPRES)
				oMovDocto:setRemetente(GW1->GW1_CDREM)
				oMovDocto:setNomeRemetente(Alltrim(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDREM, "GU3_NMEMIT")))
				oMovDocto:setCidRemetente(cCidRem)
				oMovDocto:setUFRemetente(Posicione("GU7", 1, xFilial("GU7")+cCidRem, "GU7_CDUF"))
				oMovDocto:setRegComercial(GW1->GW1_REGCOM)

				// Atribuição de dados GW8
				cAliasGW8 := GetNextAlias()
				BeginSQL Alias cAliasGW8
					SELECT GW8.GW8_FILIAL, CASE WHEN COUNT(DISTINCT GW8.GW8_UNINEG) > 1 THEN ' ' ELSE MAX(GW8.GW8_UNINEG) END GW8_UNINEG
						 , SUM(ROUND(GW8.GW8_VALOR, 2)) GW8_VALOR, SUM(ROUND(GW8.GW8_PESOR, 2)) GW8_PESOR, SUM(ROUND(GW8.GW8_VOLUME, 2)) GW8_VOLUME, SUM(ROUND(GW8.GW8_PESOC, 2)) GW8_PESOC
					FROM %Table:GW8% GW8
					WHERE GW8.GW8_FILIAL = %Exp:GW1->GW1_FILIAL%
					AND GW8.GW8_CDTPDC = %Exp:GW1->GW1_CDTPDC%
					AND GW8.GW8_EMISDC = %Exp:GW1->GW1_EMISDC%
					AND GW8.GW8_SERDC = %Exp:GW1->GW1_SERDC%
					AND GW8.GW8_NRDC = %Exp:GW1->GW1_NRDC%
					AND GW8.%NotDel%
					GROUP BY GW8.GW8_FILIAL
				EndSQL
				If (cAliasGW8)->(!EoF())
					oMovDocto:setValorNF((cAliasGW8)->GW8_VALOR)
					oMovDocto:setPesoNF((cAliasGW8)->GW8_PESOR)
					oMovDocto:setVolumeNF((cAliasGW8)->GW8_VOLUME)
					oMovDocto:setPesoCubado((cAliasGW8)->GW8_PESOC)
					oMovDocto:setUnidNegocio((cAliasGW8)->GW8_UNINEG)
				EndIf
				(cAliasGW8)->(dbCloseArea())

				// Atribuição de dados GWU
				cAliasGWU := GetNextAlias()
				BeginSQL Alias cAliasGWU
					SELECT GWU_SEQ, GWU_CDTRP, GWU_DTENT
					FROM %Table:GWU% GWU
					WHERE GWU.GWU_FILIAL = %Exp:GW1->GW1_FILIAL%
					AND GWU.GWU_CDTPDC = %Exp:GW1->GW1_CDTPDC%
					AND GWU.GWU_EMISDC = %Exp:GW1->GW1_EMISDC%
					AND GWU.GWU_SERDC = %Exp:GW1->GW1_SERDC%
					AND GWU.GWU_NRDC = %Exp:GW1->GW1_NRDC%
					AND GWU.%NotDel%
					ORDER BY GWU_SEQ
				EndSQL
				While (cAliasGWU)->(!EoF())
					oMovDocto:setSeqTrecho((cAliasGWU)->GWU_SEQ)
					oMovDocto:setTransportador((cAliasGWU)->GWU_CDTRP)
					oMovDocto:setNomeTransport(Posicione("GU3", 1, xFilial("GU3")+(cAliasGWU)->GWU_CDTRP, "GU3_NMEMIT"))
					oMovDocto:setDataEntrega(StoD((cAliasGWU)->GWU_DTENT))

					oMovDocto:IncludeRomaneio()		// Inclusão de Registros na tabela GX0

					(cAliasGWU)->(dbSkip())
				EndDo
				(cAliasGWU)->(dbCloseArea())

				(cAliasGW1)->(DbSkip())
			EndDo
			(cAliasGW1)->(dbCloseArea())

		ElseIf nOpc == MODEL_OPERATION_UPDATE
			oMovDocto:setBranch(GWN->GWN_FILIAL)
			oMovDocto:setFilRomaneio(GWN->GWN_FILIAL)
			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
			oMovDocto:setClassFrete(GWN->GWN_CDCLFR)
			oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB")+GWN->GWN_CDCLFR, "GUB_DSCLFR"))
			oMovDocto:setTipoOper(GWN->GWN_CDTPOP)
			oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4")+GWN->GWN_CDTPOP, "GV4_DSTPOP"))

			// Verifica se todos DCs associados ao romaneio estão na GX0
			cAliasGW1 := oMovDocto:SearchDCByRomaneio()
			If (cAliasGW1)->(!Eof())
				While (cAliasGW1)->(!Eof())
					GW1->(dbGoTo( (cAliasGW1)->RECNUM ))

					aadd(aAuxGX0, {GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC, GW1->GW1_DTEMIS})

					oMovDocto:setBranch(GW1->GW1_FILIAL)
					oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
					oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
					oMovDocto:setSerieNF(GW1->GW1_SERDC)
					oMovDocto:setNumeroNF(GW1->GW1_NRDC)

					cAliasGX0 := oMovDocto:SearchByDC()	// Caso ja exista registro desse DC, atualiza campos referentes ao romaneio.
					If (cAliasGX0)->(!EoF())
						While (cAliasGX0)->(!EoF()) .And. (cAliasGX0)->GX0_FILIAL == GW1->GW1_FILIAL ;
								.And. (cAliasGX0)->GX0_CDTPDC == GW1->GW1_CDTPDC ;
								.And. (cAliasGX0)->GX0_EMISDC == GW1->GW1_EMISDC ;
								.And. (cAliasGX0)->GX0_SERDC == GW1->GW1_SERDC ;
								.And. (cAliasGX0)->GX0_NRDC == GW1->GW1_NRDC
							GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
							oMovDocto:UpdateRomaneio()		// Alteração de Registros na tabela GX0

							(cAliasGX0)->(dbSkip())
						EndDo
					EndIf
					(cAliasGX0)->(dbCloseArea())

					(cAliasGW1)->(DbSkip())
				EndDo
			EndIf
			(cAliasGW1)->(dbCloseArea())

			// Remove associações que não existem mais
			For i := 1 To Len(aAuxDc)
				If AScan(aAuxGX0, {|x| x[1] == aAuxDc[i][1] .And. x[2] == aAuxDc[i][2] .And. x[3] == aAuxDc[i][3] .And. x[4] == aAuxDc[i][4] .And. x[5] == aAuxDc[i][5]}) == 0
					oMovDocto:setBranch(aAuxDc[i][1])
					oMovDocto:setTipoNF(aAuxDc[i][2])
					oMovDocto:setEmissorNF(aAuxDc[i][3])
					oMovDocto:setSerieNF(aAuxDc[i][4])
					oMovDocto:setNumeroNF(aAuxDc[i][5])

					cAliasGX0 := oMovDocto:SearchByDC()	// Caso ja exista registro desse DC, atualiza campos referentes ao romaneio.
					If (cAliasGX0)->(!EoF())
						While (cAliasGX0)->(!EoF()) .And. (cAliasGX0)->GX0_FILIAL == aAuxDc[i][1] ;
								.And. (cAliasGX0)->GX0_CDTPDC == aAuxDc[i][2] ;
								.And. (cAliasGX0)->GX0_EMISDC == aAuxDc[i][3] ;
								.And. (cAliasGX0)->GX0_SERDC == aAuxDc[i][4] ;
								.And. (cAliasGX0)->GX0_NRDC == aAuxDc[i][5]

							GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
							oMovDocto:setBranch(GX0->GX0_FILIAL)
							oMovDocto:setTipoNF(GX0->GX0_CDTPDC)
							oMovDocto:setEmissorNF(GX0->GX0_EMISDC)
							oMovDocto:setSerieNF(GX0->GX0_SERDC)
							oMovDocto:setNumeroNF(GX0->GX0_NRDC)
							oMovDocto:setFilRomaneio(" ")
							oMovDocto:setNumRomaneio(" ")
							oMovDocto:setClassFrete(" ")
							oMovDocto:setDescClassFrete(" ")
							oMovDocto:setTipoOper(" ")
							oMovDocto:setDescTipoOperacao(" ")

							oMovDocto:UpdateRomaneio()		// Remoção de associação de DC de Registros na tabela GX0

							(cAliasGX0)->(dbSkip())
						EndDo
					EndIf
					(cAliasGX0)->(dbCloseArea())
				EndIf
			Next

		ElseIf nOpc == MODEL_OPERATION_DELETE

			oMovDocto:setBranch(GWN->GWN_FILIAL)
			oMovDocto:setNumRomaneio(GWN->GWN_NRROM)

			If s_MULFIL == "1"
				cAliasGX0 := GetNextAlias()
				BeginSQL Alias cAliasGX0
					SELECT GX0.R_E_C_N_O_ as RECNUM
					FROM %Table:GX0% GX0
					WHERE GX0.GX0_FILROM = %Exp:GWN->GWN_FILIAL%
					AND GX0.GX0_NRROM = %Exp:GWN->GWN_NRROM%
					AND GX0.%NotDel%
				EndSQL
			Else
				cAliasGX0 := oMovDocto:SearchByRomaneio()
			EndIf

			While (cAliasGX0)->(!EoF())
				GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
				oMovDocto:setBranch(GX0->GX0_FILIAL)
				oMovDocto:setTipoNF(GX0->GX0_CDTPDC)
				oMovDocto:setEmissorNF(GX0->GX0_EMISDC)
				oMovDocto:setSerieNF(GX0->GX0_SERDC)
				oMovDocto:setNumeroNF(GX0->GX0_NRDC)
				oMovDocto:setFilRomaneio(" ")
				oMovDocto:setNumRomaneio(" ")
				oMovDocto:setClassFrete(" ")
				oMovDocto:setDescClassFrete(" ")
				oMovDocto:setTipoOper(" ")
				oMovDocto:setDescTipoOperacao(" ")

				oMovDocto:UpdateRomaneio()		// Não deleta GX0, apenas remove dados do romaneio nos registros da tabela GX0

				(cAliasGX0)->(DbSkip())
			EndDo
			(cAliasGX0)->(dbCloseArea())
		EndIf
	EndIf

	oMovDocto:Destroy( oMovDocto )
Return

Static Function chkFilromaneio()
	Local cQuery    := Nil
	Local cAliasGW1 := Nil
	Local cAliasGWF := Nil

	If GFXCP1212210('GW1_FILROM')	// Verifica se existe DC sem o campos GW1_FILROM preenchido caso o campo exista no dicionario de dados
		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE GW1.GW1_FILROM = ' '
			AND GW1_NRROM != ' '
			AND GW1.%NotDel%
		EndSql
		If (cAliasGW1)->(!Eof())
			cQuery := "UPDATE " + RetSQLName("GW1") + " "
			cQuery += " SET GW1_FILROM = GW1_FILIAL"
			cQuery += " WHERE GW1_FILROM = ' '"
			cQuery += " AND GW1_NRROM != ' '"
			cQuery += " AND D_E_L_E_T_ = ' '"
			TCSQLExec(cQuery)
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf

	If GFXCP1212210('GWF_FILROM')	// Verifica se existe DC sem o campos GWF_FILROM preenchido caso o campo exista no dicionario de dados
		cAliasGWF := GetNextAlias()
		BeginSql Alias cAliasGWF
			SELECT GWF.R_E_C_N_O_ AS GWFRECNO
			FROM %table:GWF% GWF
			WHERE GWF.GWF_FILROM = ' '
			AND GWF_NRROM != ' '
			AND GWF.%NotDel%
		EndSql
		If (cAliasGWF)->(!Eof())
			cQuery := "UPDATE " + RetSQLName("GWF") + " "
			cQuery += " SET GWF_FILROM = GWF_FILIAL"
			cQuery += " WHERE GWF_FILROM = ' '"
			cQuery += " AND GWF_NRROM != ' '"
			cQuery += " AND D_E_L_E_T_ = ' '"
			TCSQLExec(cQuery)
		EndIf
		(cAliasGWF)->(dbCloseArea())
	EndIf
Return

/*/--------------------------------------------------------------------------------------------------
	{Protheus.doc} GFECalcCarga
	Chamada de função para calculo dos romaneios criados conforme as cargas. Uso em caso de faturamento de pedido particionado em diversas notas causando retrabalho com calculos.
	Integração de notas faturadas via montagem de carga onde parametrização de calculo automatico precisa ser desligado.

	@sample
	GFECalcCarga(aCargas)

	@author Equipe Frete Embarcador
	@since 16/01/2024
	@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFECalcCarga(aCargas)
	Local nCont       := 0
	Local cCodFil     := Nil
	Local cNrRom      := Nil
	Local cAliasGWN   := Nil
	Local lClcAutoOMS := SuperGetMv("MV_CLCCRG",,.F.)	// Parametro para habilitar ou não o calculo do romaneio gerado pelas cargas

	If lClcAutoOMS .And. Len(aCargas) > 0
		For nCont := 1 To Len(aCargas)
			cCodFil := Alltrim(aCargas[nCont][1])
			cNrRom  := Alltrim(aCargas[nCont][2]) + Alltrim(aCargas[nCont][3])

			cAliasGWN := GetNextAlias()
			BeginSql Alias cAliasGWN
				SELECT GWN.R_E_C_N_O_ AS GWNRECNO
				FROM %table:GWN% GWN
				WHERE GWN.GWN_FILIAL = %Exp:cCodFil%
				AND GWN.GWN_NRROM = %Exp:cNrRom%
				AND GWN.%NotDel%
			EndSql
			While (cAliasGWN)->(!Eof())
				GWN->(DbGoTo( (cAliasGWN)->GWNRECNO ))	// Posiciona no romaneio

				GFE050CALC() // Executa o calculo para o romaneio posicionado

				(cAliasGWN)->(DbSkip())
			EndDo
			(cAliasGWN)->(dbCloseArea())
		Next
	EndIf
Return

/*/{Protheus.doc} GFE50VLLIB
//TODO Descrição Valida se os a data de liberação é menor do que a data de emissão dos documentos de carga. A data de liberação deve ser maior ou igual a data e hora de emissão dos documentos de Carga.
@author andre.wisnheski
@since 22/01/2018
@version 1.0
@return ${lRet}, ${Permite ou não a liberação do romaneio}
@return ${cMsg}, ${Mensagem a ser exibida quando não permite a liberação}
@param cFilRom, characters, Filial do Romaneio
@param cRom, characters, Número do Romaneio
@param dDtLib, date, Data da liberação
@param dHrLib, date, Hora da liberação (Utilizado somente no PE)
@param nHodo, numerico, Hodômetro do Romaneio (Utilizado somente no PE)
@param cRastr, characters, Rastreio do Romaneio (Utilizado somente no PE)
@type function
/*/
Static Function GFE50AVLIB(cFilRom, cRom, dDtLib, dHrLib, nHodo, cRastr)
	Local lRet			:= .T.
	Local cMsg			:= ""
	Local cQuery		:= ""
	Local cAliasGW1		:= ""
	Local lPE04			:= ExistBlock("GFEA05A4")
	Local cMV_PLROADE	:= SuperGetMv("MV_PLROADE",.F.,"2")
	Local nTipo			:= 0
	Local cTitle		:= "SIGAGFE"
	Local cSolu			:= ""

	If lPE04
		aRet := ExecBlock("GFEA05A4",.F.,.F., {cFilRom, cRom, dDtLib, dHrLib, nHodo, cRastr})

		If aRet[1] = .F.
			lRet 	:= .F.
			nTipo 	:= 5
			cTitle	:= "GFEA05A4"
			cMsg	:= aRet[2] // Mensagem retornada pelo ponto de entrada
		EndIf
	ElseIf cMV_PLROADE == "2"
		cQuery := "SELECT GW1.GW1_NRDC NRDC, GW1.GW1_DTEMIS DTEMIS "
		cQuery += " FROM " + RetSQLName("GW1") + " GW1 "
		If GFXCP1212210('GW1_FILROM')
			cQuery += " WHERE GW1.GW1_FILROM = '" + cFilRom + "'"
		Else
			cQuery += " WHERE GW1.GW1_FILIAL = '" + cFilRom + "'"
		EndIf
		cQuery += "   AND GW1.GW1_NRROM = '" + cRom + "'"
		cQuery += "   AND GW1.GW1_DTEMIS > '" + DtoS(dDtLib) + "'"
		cQuery += "   AND GW1.D_E_L_E_T_ = ' ' "

		cAliasGW1 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)

		If !(cAliasGW1)->(Eof())
			lRet 	:= .F.
			nTipo 	:= 5
			cTitle	:= GFEA050024
			cMsg 	:= "Documento de Carga " + (cAliasGW1)->NRDC + " tem a data de Emissão Maior que a data de saída informada: " + CRLF +;
				"Data de Emissão do Documento de Carga: " + Dtoc(Stod((cAliasGW1)->DtEmis)) + CRLF +;
				"Data de Saída: " + DtoC(dDtLib)
			cMsg	:= GFEMsgFmt(STR0175, {{"[VAR01]", cMsg}})
			cSolu	:= STR0176
		EndIf

		(cAliasGW1)->(dbCloseArea())
	EndIf
Return {lRet, nTipo, cTitle, cMsg, cSolu}
