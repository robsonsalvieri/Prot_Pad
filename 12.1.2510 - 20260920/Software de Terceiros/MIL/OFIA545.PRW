#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'OFIA545.CH'
#INCLUDE "FWMVCDEF.CH"


static oModel01 := NIL
static cContaSel := ""
static cSegmentoSel := ""
static oView
static aOpcoes := {}
static aContas := {}
static lSegmento := .F.


/*/{Protheus.doc} OFIA545
    Programa usado para seleção rapida de conta RPM
	Caso exista somente uma conta ele vai retornar direto sem que o usuario precise selecionar nada a menos que o segmento seja obrigatorio

    @author Vinicius Gati
    @since  10/09/2021
/*/
Function OFIA545(lSegObr)
	local nX := 1
	Private oArrHelper := DMS_ArrayHelper():New()
	Private cValids    := ""
	lSegmento  := lSegObr
	aContas    := OA5120074_BuscaContasRPM()
	aOpcoes    := {}

	if len(aContas) == 1 .and. lSegObr == .F.
		// Se tiver apenas uma conta, e nao precisa do segmento, retorna ela direto
		return { aContas[1], " " }
	endif

	if len(aContas) == 0
		FMX_HELP("OFIA545", STR0001) //"Nenhuma conta RPM cadastrada. Verifique as configurações."
		return .F.
	else
		for nX := 1 to len(aContas)
			aadd(aOpcoes, alltrim(cvaltochar(nX)) + "=" + alltrim(cvaltochar(aContas[nX])))
			if ! empty(cValids)
				cValids += ","
			endif
			cValids += alltrim(cValtoChar(nX))
		next
	endif
	
	FWExecView(STR0002, "OFIA545", MODEL_OPERATION_INSERT,,,,50) //"Selecione a conta RPM para continuar..."
	
	if empty(cSegmentoSel) .or. cSegmentoSel == "-"
		cSegmentoSel := " "
	endif
	if empty(cContaSel)
		return { space(20), " " }
	endif
Return { cContaSel, cSegmentoSel }

/*/{Protheus.doc} ViewDef
	Definicao da view
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1

	oStr1 := oModel01:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('BASE', oStr1, 'BASE')

	// 1 divisao
	oView:CreateHorizontalBox('BOX', 100)

	// ABA GERAL
	oView:SetOwnerView('BASE','BOX')
	
	// modelo que vai na aba pecas

	oView:EnableTitleView('BASE', "")

	oView:AddUserButton("Confirmar","BUTTON", { |oView| OA50300154_CancelarSimulacao() }) // Finalizar Simulação

	// Retira o botão de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.T.})
	oView:SetModified(.t.)
return oView

/*/{Protheus.doc} ModelDef
	Definicao do modelo
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
static function ModelDef()
	Local oModel
	Local oStr1

	If oModel01 == NIL
		oModel01 := GetModel01()
	EndIf

	oStr1 := oModel01:GetModel()

	oModel := MPFormModel():New('OFIA545',,,{ |oModel| OA54500014_Confirmar(oModel) })
	oModel:SetDescription(STR0003) // "Seleção de conta"
	
	oModel:AddFields("BASE",,oStr1,,,{|| Load01Dados() })
	oModel:GetModel("BASE"):SetDescription(STR0003) //"Seleção de conta"

	oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
Static Function GetModel01()
	Local nX   := 1
	Local oMd1 := OFDMSStruct():New()

	DbSelectArea("VAI")
	Dbsetorder(4)
	If VAI->(MsSeek(xFilial("VAI") + __cUserID))
		if empty(VAI->VAI_ACCRPM)
			cContaSel := " "
		else
			for nX := 1 to len(aContas)
				if alltrim(aContas[nX]) == alltrim(VAI->VAI_ACCRPM)
					cContaSel := alltrim(cvaltochar(nX))
				endif
			next
		endif

		if empty(VAI->VAI_SEGRPM)
			cSegmentoSel := '-'
		else
			cSegmentoSel := VAI->VAI_SEGRPM
		endif
	EndIf

	oMd1:AddField({;
		{'cTitulo'     , STR0004 },; // STR0004
		{'cIdField'    , "CONTA" },;
		{'nTamanho'    , 1       },;
		{'aComboValues', aOpcoes },;
		{'bValid'      , { |a,b,c,d| OA50300074_ValidaOpcao(a,b,alltrim(c),d, cValids) }},;
		{'bInit'       , { ||cContaSel }},;
		{'lObrigat'    , .T.     },;
		{'cTooltip'    , STR0005 } ; //"Conta do RPM configuradas no programa OFIA512"
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0006    },; //"SEGMENTO"
		{'cIdField'    , "SEGMENTO" },;
		{'nTamanho'    , 1          },;
		{'aComboValues', {"-=Nenhum","0="+STR0007,"1="+STR0008}},;// agricola & construcao
		{'bValid'      , { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1,-") }},;
		{'bInit'       , { ||cSegmentoSel }},;
		{'lObrigat'    , lSegmento  },;
		{'cTooltip'    , STR0009    } ; // segmento da filial utilizada, será usado para descobrir o dealer code
	})
return oMd1

/*/{Protheus.doc} Load01Dados
	Retorna os valores de inicio do modelo 01
	
	@type function
	@author Vinicius Gati
	@since 14/11/2025
/*/
Static Function Load01Dados()
	local nX := 1

	DbSelectArea("VAI")
	Dbsetorder(4)
	If VAI->(DbSeek(xFilial("VAI") + __cUserID))
		if !empty(VAI->VAI_ACCRPM)
			for nX := 1 to len(aContas)
				if alltrim(aContas[nX]) == alltrim(VAI->VAI_ACCRPM)
					cContaSel := alltrim(cvaltochar(nX))
				endif
			next
		endif

		if !empty(VAI->VAI_SEGRPM)
			cSegmentoSel := VAI->VAI_SEGRPM
		endif
	EndIf

return {;
	{;
		iif(len(aContas) == 1, "1", " "),;
		iif(empty(cSegmentoSel), "-", cSegmentoSel) ;
	}, 0;
}

/*/{Protheus.doc} OA54500014_Confirmar
	Ação confirmar da tela
	
	@type function
	@author Vinicius Gati
	@since 14/11/2025
/*/
Static Function OA54500014_Confirmar(oModel)
//    local jTodasConfig := JsonObject():New()
//	local nIndex := 1


	cContaSel    := aContas[val(oModel:GetValue("BASE", "CONTA"))]
	cSegmentoSel := oModel:GetValue("BASE", "SEGMENTO")

	if ! empty(cSegmentoSel) .and. cSegmentoSel != "-"
		oJdConfig := OFJDConfig():New( , cContaSel)

		if oJdConfig:AnyWithSegmento(cSegmentoSel)
			return .t.
		else
			FMX_HELP("HOFIA5451", STR0011) //"Nenhum Dealer Code encontrado na conta para segmento selecionado"
		endif
	endif

return .F.
