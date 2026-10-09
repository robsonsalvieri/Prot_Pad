#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA190G.ch"

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

#DEFINE LEGAGENDA	01
#DEFINE LEGSTATUS	02
#DEFINE GRUPO		03
#DEFINE DATREF		04
#DEFINE DATAAG		05
#DEFINE DIASEM		06
#DEFINE HORINI		07
#DEFINE HORFIM		08
#DEFINE CODTEC		09
#DEFINE NOMTEC		10
#DEFINE TIPO		11
#DEFINE ATENDIDA	12
#DEFINE CODABB		13
#DEFINE TURNO		14
#DEFINE SEQ			15
#DEFINE ITEM		16
#DEFINE KEYTGY		17
#DEFINE ITTGY		18
#DEFINE EXSABB		19
#DEFINE HORASTRAB   20
#DEFINE DALOFIM     21
#DEFINE ARRTDV      22
#DEFINE DESCCONF    23

#DEFINE TAMANHO		23

Static aManutPla	:= {}
Static oMdl190D 	:= Nil
Static lAlocAvuls	:= .F.
Static lDelConf     := .F.
Static cSitABB      := "BR_VERDE"
Static lMesaPOUI	:= .F.
Static nOpcaoPOUI	:= 0
Static cF3Ret       := ""

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190G - Mesa Operacional - Alocação Por Horas
 	ModelDef
 		Definição do modelo de Dados

@author	Augusto Albuquerque
@since	03/04/2020
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel  := Nil
	Local oStrAA1 := FWFormModelStruct():New()
	Local oStrALC := FWFormModelStruct():New()
	Local oStrTOT := Nil
	Local aFields := {}
	Local nX      := 0
	Local nY      := 0
	Local aTables := {}
	Local xAux    := {}
	Local bCommit := { |oModel| AT190GCmt(oModel) }
	Local bValid  := { |oModel| AT190GVld(oModel) }

	If lAlocAvuls
		oStrAA1:AddTable("   ",{}, STR0060) //"Alocação Avulsa"
	Else
		oStrAA1:AddTable("   ",{}, STR0001) //"Alocação Por Hora"
	EndIf
	oStrALC:AddTable("   ",{}, "   ")

	AADD(aTables, {oStrAA1, "AA1"})
	AADD(aTables, {oStrALC, "ALC"})
	If !lAlocAvuls
		oStrTOT	:= FWFormModelStruct():New()
		oStrTOT:AddTable("   ",{}, "   ")
		AADD(aTables, {oStrTOT, "TOT"})
	EndIf

	For nY := 1 To LEN(aTables)
		aFields := AT190GDef(aTables[nY][2], .T.)

		For nX := 1 TO LEN(aFields)
			aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO],;
							aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
							aFields[nX][DEF_IDENTIFICADOR	],;
							aFields[nX][DEF_TIPO_DO_CAMPO	],;
							aFields[nX][DEF_TAMANHO_DO_CAMPO],;
							aFields[nX][DEF_DECIMAL_DO_CAMPO],;
							aFields[nX][DEF_CODEBLOCK_VALID	],;
							aFields[nX][DEF_CODEBLOCK_WHEN	],;
							aFields[nX][DEF_LISTA_VAL		],;
							aFields[nX][DEF_OBRIGAT			],;
							aFields[nX][DEF_CODEBLOCK_INIT	],;
							aFields[nX][DEF_CAMPO_CHAVE		],;
							aFields[nX][DEF_RECEBE_VAL		],;
							aFields[nX][DEF_VIRTUAL			],;
							aFields[nX][DEF_VALID_USER		])
		Next nX
	Next nY

	xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_NOMTEC',;
		'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_NOMTEC")', .F. )
		oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ALC_DATREF', 'ALC_DATDIA',;
		'FwFldGet("ALC_DATREF")', .F. )
		oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ALC_DATDIA', 'ALC_SEMANA',;
		'TECCdow(Dow(FwFldGet("ALC_DATDIA")))', .F. )
		oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ALC_SAIDA', 'ALC_TOTHRS',;
		'AT190GHrsT("ALC_ENTRADA")', .F. )
		oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ALC_ENTRADA', 'ALC_TOTHRS',;
		'AT190GHrsT("ALC_SAIDA")', .F. )
		oStrALC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		
	oModel := MPFormModel():New('TECA190G',/*bPreValidacao*/, bValid, bCommit,/*bCancel*/)
	oModel:SetDescription( STR0001 ) //"Alocação Por Hora" 

	oModel:addFields('AA1MASTER',,oStrAA1)
	oModel:SetPrimaryKey({"AA1_FILIAL","AA1_CODTEC"})

	oModel:addGrid('ALCDETAIL','AA1MASTER', oStrALC,{|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| AT190GPrAL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)},;
	{|oMdlG,nLine,cAcao,cCampo| AT190GPoAL(oMdlG, nLine, cAcao, cCampo)})

	oModel:GetModel('ALCDETAIL'):SetOnlyQuery(.T.)


	oModel:GetModel('ALCDETAIL'):SetOptional(.T.)

	oModel:GetModel('AA1MASTER'):SetDescription(STR0061)	//"Informações do Atendente"
	oModel:GetModel('ALCDETAIL'):SetDescription(STR0002)	//"Projeção de Alocação"

	If !lAlocAvuls
		oModel:addFields('TOTDETAIL','AA1MASTER',oStrTOT)
		oModel:GetModel('TOTDETAIL'):SetOnlyQuery(.T.)
		oModel:GetModel('TOTDETAIL'):SetOptional(.T.)
		oModel:GetModel('TOTDETAIL'):SetDescription(STR0048) //"Total de Horas" 
	EndIf

	oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Augusto Albuquerque
@since 03/04/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local aTables  := {}
	Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local nX       := 0
	Local nY       := 0
	Local oModel   := ModelDef()
	Local oStrAA1  := FWFormViewStruct():New()
	Local oStrALC  := FWFormViewStruct():New()
	Local oStrTOT  := Nil
	Local oView    := Nil

	AADD(aTables, {oStrAA1, "AA1"})
	AADD(aTables, {oStrALC, "ALC"})

	If !lAlocAvuls
		oStrTOT	:= FWFormViewStruct():New()
		AADD(aTables, {oStrTOT, "TOT"})
	EndIf

	For nY := 1 to LEN(aTables)
		
		aFields := AT190GDef(aTables[nY][2])

		For nX := 1 to LEN(aFields)
			aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR],;
							aFields[nX][DEF_ORDEM],;
							aFields[nX][DEF_TITULO_DO_CAMPO],;
							aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
							aFields[nX][DEF_HELP],;
							aFields[nX][DEF_TIPO_CAMPO_VIEW],;
							aFields[nX][DEF_PICTURE],;
							aFields[nX][DEF_PICT_VAR],;
							aFields[nX][DEF_LOOKUP],;
							aFields[nX][DEF_CAN_CHANGE],;
							aFields[nX][DEF_ID_FOLDER],;
							aFields[nX][DEF_ID_GROUP],;
							aFields[nX][DEF_COMBO_VAL],;
							aFields[nX][DEF_TAM_MAX_COMBO],;
							aFields[nX][DEF_INIC_BROWSE],;
							aFields[nX][DEF_VIRTUAL],;
							aFields[nX][DEF_PICTURE_VARIAVEL],;
							aFields[nX][DEF_INSERT_LINE],;
							aFields[nX][DEF_WIDTH])
			If aTables[nY][2] == "AA1" .AND. !(aFields[nX][DEF_IDENTIFICADOR] $ "AA1_CODTEC|AA1_NOMTEC")
				aTables[nY][1]:RemoveField(aFields[nX][DEF_IDENTIFICADOR])
			EndIf
		Next nX
	Next nY


	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')
	oView:AddGrid('DETAIL_ALC', oStrALC, 'ALCDETAIL')
	If !lAlocAvuls
		oView:AddField('DETAIL_TOT', oStrTOT, 'TOTDETAIL')
		If lMonitor
			oView:CreateHorizontalBox( 'REALOC_AA1' , 35 )
			oView:CreateHorizontalBox( 'REALOC_ALOC', 60 )
			oView:CreateHorizontalBox( 'TOTAL_HRS', 05 )
		Else
			oView:CreateHorizontalBox( 'REALOC_AA1' , 15 )
			oView:CreateHorizontalBox( 'REALOC_ALOC', 70 )
			oView:CreateHorizontalBox( 'TOTAL_HRS', 15 )
		EndIf
		oView:SetOwnerView('DETAIL_TOT','TOTAL_HRS')
	Else
		oView:CreateHorizontalBox( 'REALOC_AA1' , 15 )
		oView:CreateHorizontalBox( 'REALOC_ALOC', 85 )
		oStrALC:RemoveField("ALC_TOTHRS")
	EndIf

	oStrALC:RemoveField("ALC_DATDIA")

	oView:SetOwnerView('VIEW_MASTER','REALOC_AA1')
	oView:SetOwnerView('DETAIL_ALC','REALOC_ALOC')
	If lMonitor
		oView:SetContinuousForm()
	EndIf
	If lAlocAvuls
		oView:SetDescription(STR0060) //"Alocação Avulsa"
	Else
		oView:SetDescription(STR0001) //"Alocação Por Hora" 
	EndIf
	oView:EnableTitleView('VIEW_MASTER', 	STR0061) //"Informações do Atendente"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	Augusto Albuquerque
@since	03/04/2020
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlAA1     := oModel:GetModel("AA1MASTER")
Local oStrAA1     := oMdlAA1:GetStruct()
Local oMdlALC     := Nil
Local cHoraIni    := ""
Local cHoraFim    := ""
Local cChaveTGY   := ""
Local dDataPerIni := Ctod("")
Local dDataPerFim := Ctod("") 
Local dDataAtual  := Ctod("")
Local nDifHoras   := 0
Local nHorasRest  := 0
Local nI          := 0

	aManutPla := {}

	oMdlAA1:SetValue("AA1_CODTEC", oMdl190d:GetValue("AA1MASTER","AA1_CODTEC"))
	oStrAA1:SetProperty("AA1_CODTEC", MODEL_FIELD_WHEN, {|| .F.})
	oStrAA1:SetProperty("AA1_NOMTEC", MODEL_FIELD_WHEN, {|| .F.})

	If oMdl190d:GetId() == 'TECA190D' .AND. oModel:GetId() == 'TECA190F' 
		oMdlAA1:SetValue("AA1_CODTEC", oMdl190d:GetValue("AA1MASTER","AA1_CODTEC"))
		oStrAA1:SetProperty("AA1_CODTEC", MODEL_FIELD_WHEN, {|| .F.})
		oStrAA1:SetProperty("AA1_NOMTEC", MODEL_FIELD_WHEN, {|| .F.})
		oMdlDTA:SetValue("DTA_DTINI",dDataBase)
		oMdlDTA:SetValue("DTA_DTFIM",dDataBase)
	EndIf

	If !lAlocAvuls
		cChaveTGY   := oMdl190d:GetValue("TGYMASTER", "TGY_FILIAL") + oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD")
		cHoraIni    := POSICIONE("TFF", 1, cChaveTGY, "TFF_HORAIN") // Hora inicial
		cHoraFim    := POSICIONE("TFF", 1, cChaveTGY, "TFF_HORAFI") // Hora final
		dDataPerInI := POSICIONE("TFF", 1, cChaveTGY, "TFF_PERINI") // Data de início do contrato
		dDataPerFim := POSICIONE("TFF", 1, cChaveTGY, "TFF_PERFIM") // Data de término do contrato 
		nHorasRest  := TecConvHr(POSICIONE("TFF", 1, cChaveTGY, "TFF_HRSSAL")) // Total no saldo de horas a serem trabalhadas

		nDifHoras  := SubHoras(cHoraFim, cHoraIni)  // Diferença de Horas , entre ini e fim
		dDataAtual := dDataPerInI
		If !Empty(cHoraIni) .And. !empty(cHoraFim) .And. nHorasRest > 0
			oMdlALC := oModel:GetModel("ALCDETAIL")
			nI := oMdlALC:GetQtdLine()
			While dDataAtual <= dDataPerFim .And. nHorasRest > 0
				
				If nI > 1 
					oMdlALC:AddLine()
				EndIf

				oMdlALC:GoLine(oMdlALC:GetQtdLine())
				
				If nHorasRest >= nDifHoras
					nHorasRest := SubHoras(TecConvHr(nHorasRest), TecConvHr(nDifHoras))
					oMdlALC:setValue("ALC_DATREF", dDataAtual)
					oMdlALC:setValue("ALC_ENTRADA", cHoraIni)
					oMdlALC:setValue("ALC_SAIDA", cHoraFim)
				Else
					oMdlALC:setValue("ALC_DATREF", dDataAtual)
					oMdlALC:setValue("ALC_ENTRADA", cHoraIni)
					oMdlALC:setValue("ALC_SAIDA", TecConvHr(SomaHoras(TecConvHr(cHoraIni), TecConvHr(nHorasRest))))
					nHorasRest := 0
				EndIf
				
				dDataAtual++
				nI++
			EndDo
		EndIf
	Else
		oMdlALC := oModel:GetModel("ALCDETAIL")
		oMdlALC:setValue("ALC_DATREF", dDataBase)
	EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GDef
@description Criação dos campos
@return aRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GDef(cTable, lAtualiza)
	Local aRet     := {}
	Local lCampHrs := TecABBPRHR()
	Local nAux     := 0
	Local nTamHora := 2

	If lCampHrs
		nTamHora := TamSX3("TFF_QTDHRS")[1]
	EndIf

	Default lAtualiza := .F.

	If lAtualiza
		oMdl190d := Nil
		oMdl190d := FwModelActive()
	EndIf

	If cTable == "AA1"
		aRet := AT190DDef(cTable) 
	ElseIf cTable == "ALC"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0003 //"Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0003 //"Agenda"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_SITABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "BT"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID]  := {||At330AGtLA()}
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| "BR_VERDE"}
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "01"
		aRet[nAux][DEF_PICTURE]          := ""
		aRet[nAux][DEF_CAN_CHANGE]       := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0005 //"Data da Alocação"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005 //"Data da Alocação"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_DATREF"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| dDataBase}
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "02"
		aRet[nAux][DEF_PICTURE]          := ""
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_HELP]             := {STR0006} //"Dia que o atendente estará alocado."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0007	//"Dia da Semana"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007	//"Dia da Semana"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_SEMANA"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL]       := .F.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "03"
		aRet[nAux][DEF_PICTURE]          := "@!"
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| TECCdow(Dow(dDataBase))}
		aRet[nAux][DEF_CAN_CHANGE]       := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0008	//"Hora de Entrada"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008	//"Hora de Entrada"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_ENTRADA"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
		aRet[nAux][DEF_CODEBLOCK_VALID]  := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
		aRet[nAux][DEF_OBRIGAT]          := .T.	
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "04"
		aRet[nAux][DEF_PICTURE]          := "99:99"
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_HELP]             := {STR0009}	//"Horario inicial da agenda"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0010	//"Hora de Saída"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010	//"Hora de Saída"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_SAIDA"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
		aRet[nAux][DEF_CODEBLOCK_VALID]  := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_OBRIGAT]          := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "05"
		aRet[nAux][DEF_PICTURE]          := "99:99"
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_HELP]             := {STR0011}	//"Horario final da agenda"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0012 //"Turno" 
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012 //"Turno" 
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_TURNO"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 3
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_RECEBE_VAL]       := .F.
		aRet[nAux][DEF_OBRIGAT]          := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "06"
		aRet[nAux][DEF_PICTURE]          := "@!"
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| GetTurnTGY( "TURNO" ) }		
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_LOOKUP]           := "SR6TUR"
		aRet[nAux][DEF_HELP]             := {STR0013} //"Selecione o turno do atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0014 //"Sequencia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Sequencia"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_SEQ"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL]       := .F.
		aRet[nAux][DEF_OBRIGAT]          := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| GetTurnTGY( "SEQ" ) }
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| WhensALC("ALC_TURNO")}
		aRet[nAux][DEF_ORDEM]            := "07"
		aRet[nAux][DEF_PICTURE]          := "@!"
		aRet[nAux][DEF_LOOKUP]           := "T19SEQ"
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_HELP]             := {STR0015} //"Selecione a Sequencia do Turno"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0016	//"Tipo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016	//"Tipo"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_TIPO"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_LISTA_VAL]        := {"S=" + STR0017, "N=" + STR0044} //"Trabalhado"#"Não Trabalhado"
		aRet[nAux][DEF_COMBO_VAL]        := {"S=" + STR0017, "N=" + STR0044} //"Trabalhado"#"Não Trabalhado"
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| "S" }
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_ORDEM]            := "08"
		aRet[nAux][DEF_PICTURE]          := "@!"
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| .T.}
		aRet[nAux][DEF_HELP]             := {STR0023} //"Tipo de dia: Trabalhado, não trabalhado, folga ou DSR."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0024 //"Total de Horas"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024 //"Total de Horas"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_TOTHRS"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := nTamHora
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_RECEBE_VAL]       := .F.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "09"
		aRet[nAux][DEF_CAN_CHANGE]       := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| .F.}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0053 //"Saída intervalo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0053 //"Saída intervalo"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_INTERV"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_LISTA_VAL]        := {"S="+STR0055,"N="+STR0056}
		aRet[nAux][DEF_COMBO_VAL]        := {"S="+STR0055,"N="+STR0056}
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| "N" }
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_ORDEM]            := "10"
		aRet[nAux][DEF_PICTURE]          := "@!"
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| .T.}
		aRet[nAux][DEF_HELP]             := {STR0054} //"Este campo replica a funcionalidade do campo 1a.S.Interb na Tabela de Horários. Marque-o como SIM caso exista outra alocação avulsa e o período entre as duas alocações represente o intervalo. Ex: 08 as 12 / 13 as 18 Se das 12 as 13 não for intervalo, deve-se informar NÃO"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0057 //"Data Dia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0057 //"Data Dia"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_DATDIA"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| dDataBase}
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "11"
		aRet[nAux][DEF_PICTURE]          := ""
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_HELP]             := {STR0006} //"Dia que o atendente estará alocado."


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0058	//"Intrajornada?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0058	//"Intrajornada?"
		aRet[nAux][DEF_IDENTIFICADOR]    := "ALC_HEPLAN"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_LISTA_VAL]        := {"1="+STR0055,"2="+STR0056} //"Sim"##"Não"
		aRet[nAux][DEF_COMBO_VAL]        := {"1="+STR0055,"2="+STR0056} //"Sim"##"Não"
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| "1" }
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_ORDEM]            := "12"
		aRet[nAux][DEF_PICTURE]          := "@!"
		aRet[nAux][DEF_CAN_CHANGE]       := .T.
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| .T.}
		aRet[nAux][DEF_HELP]             := {STR0059} //"Caso selecione como Sim, o sistema ira quebrar as agendas e realizar as manutenções planejadas, caso tenha."

	ElseIf cTable == 'TOT'
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0025  //"Saldo de Horas"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0025 //"Saldo de Horas"
		aRet[nAux][DEF_IDENTIFICADOR]    := "TOT_SALHRS"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := nTamHora
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "01"
		aRet[nAux][DEF_CAN_CHANGE]       := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| .F.}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0035 //"Horas do Contrato" 
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0035 //"Horas do Contrato" 
		aRet[nAux][DEF_IDENTIFICADOR]    := "TOT_CTRSAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := nTamHora
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "02"
		aRet[nAux][DEF_CODEBLOCK_INIT]   := {|| POSICIONE("TFF",1,oMdl190d:GetValue("TGYMASTER", "TGY_FILIAL")+oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD"),"TFF_HRSSAL") }
		aRet[nAux][DEF_CAN_CHANGE]       := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| .F.}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0034  //"Horas Restantes" 
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0034 //"Horas Restantes" 
		aRet[nAux][DEF_IDENTIFICADOR]    := "TOT_RESTSAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO]    := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW]  := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := nTamHora
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT]          := .F.
		aRet[nAux][DEF_RECEBE_VAL]       := .T.
		aRet[nAux][DEF_VIRTUAL]          := .T.
		aRet[nAux][DEF_ORDEM]            := "03"
		aRet[nAux][DEF_CAN_CHANGE]       := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN]   := {|| .F.}
	EndIf

Return (aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GCmt
@description Commit do modelo
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GCmt(oModel)
Local aHorEsca	:= {}
Local aAgenda 	:= {}
Local cEscala	:= ""
Local cTurno	:= ""
Local cSeq		:= ""
Local cTipo		:= ""
Local dDataRef	:= SToD("")
Local dDataAux	:= SToD("")
Local lRet      := .T.
Local lSubtrai	:= .F.
Local lSaida	:= .F.
Local lManut	:= .F.
Local nLinha    := 1
Local nDifHr	:= 0
Local nPrimeira	:= 0
Local nHorTot	:= ""
Local oMdlAlc   := oModel:GetModel("ALCDETAIL")
Local oMdlAlc19 := oMdl190D:GetModel("ALCDETAIL")
Local nX        := 0
Local nY        := 0

aManutPla := {}

oMdlAlc19:SetNoInsertLine(.F.)
oMdlAlc19:SetNoDeleteLine(.F.) 
oMdlAlc19:ClearData()
oMdlAlc19:InitLine()

If TableInDic("TXH")
	For nX := 1 To oMdlAlc:Length()
		If nX == nPrimeira
			Exit
		EndIf
		oMdlAlc:GoLine(nX)
		aHorEsca := {}
		lSaida := .F.
		lSubtrai := .F.

		If !oMdlAlc:IsDeleted() .AND. oMdlAlc:GetValue("ALC_HEPLAN") == "1" .AND. oMdlAlc:GetValue("ALC_SITABB") $ cSitABB
			cTurno := oMdlAlc:GetValue("ALC_TURNO")
			cSeq := oMdlAlc:GetValue("ALC_SEQ")
			cTipo := oMdlAlc:GetValue("ALC_TIPO")
			If !At190gTurno(cTurno)
				cEscala := GetEscala(cTurno, cSeq)
			Else
				cEscala := oMdl190d:GetValue("TGYMASTER", "TGY_ESCALA") 
			EndIf	
			nHorTot := TecConvHr(ElapTime( oMdlAlc:GetValue("ALC_ENTRADA") + ":00", oMdlAlc:GetValue("ALC_SAIDA") + ":00"))
			nTurTot := TecConvHr(HrTotTurno( cTurno, cSeq, cValToChar(Dow(oMdlAlc:GetValue("ALC_DATREF"))), @aHorEsca ))
			If nHorTot == nTurTot
				If HoraToInt(oMdlAlc:GetValue("ALC_ENTRADA")) > HoraToInt(aHorEsca[1][1]) .OR. HoraToInt(oMdlAlc:GetValue("ALC_SAIDA")) > HoraToInt(aHorEsca[Len(aHorEsca)][2])
					nDifHr := TecConvHr(ElapTime( aHorEsca[1][1] + ":00", oMdlAlc:GetValue("ALC_ENTRADA") + ":00"))
				Else
					nDifHr := TecConvHr(ElapTime( oMdlAlc:GetValue("ALC_ENTRADA") + ":00", aHorEsca[1][1] + ":00"))
					lSubtrai := .T.
				EndIf
				lManut := EscalManut( cEscala, cTurno, cSeq, cValToChar(Dow(oMdlAlc:GetValue("ALC_DATREF"))), aHorEsca, nDifHr, oMdlAlc:GetValue("ALC_DATREF"), lSubtrai, @lSaida, oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD") )
				If !Empty(cEscala) .AND. VldEscala(0, cEscala, oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD")) 
					dDataRef := oMdlAlc:GetValue("ALC_DATREF")
					dDataAux := oMdlAlc:GetValue("ALC_DATREF")
					If ViraDiaHR(aHorEsca, nDifHr, lSubtrai)
						For nY := 1 To Len(aHorEsca)
							If nY == 1
								If lSubtrai
									oMdlAlc:LoadValue("ALC_SAIDA", TecConvHr(SubHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								Else
									oMdlAlc:LoadValue("ALC_SAIDA", TecConvHr(SomaHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								EndIf
								If Len(aHorEsca) == 2 .And. oMdlAlc:GetValue("ALC_INTERV") == "N"
									oMdlAlc:LoadValue("ALC_INTERV",	"S")
								EndIf
							Else
								If aHorEsca[nY-1][2] > aHorEsca[nY][1]
									dDataAux := DaySum(dDataAux,1)
								EndIf
								nLinha := oMdlAlc:AddLine()
								If nPrimeira == 0
									nPrimeira := nLinha
								EndIf
								oMdlAlc:GoLine(nLinha)
								oMdlAlc:SetValue("ALC_DATREF", 	dDataRef)
								oMdlAlc:SetValue("ALC_DATDIA", 	dDataAux)
								If lSubtrai
									oMdlAlc:LoadValue("ALC_ENTRADA", TecConvHr(SubHoras(TecConvHr(aHorEsca[nY][1]), nDifHr)))
									oMdlAlc:LoadValue("ALC_SAIDA", 	TecConvHr(SubHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								Else
									oMdlAlc:LoadValue("ALC_ENTRADA", TecConvHr(SomaHoras(TecConvHr(aHorEsca[nY][1]), nDifHr)))
									oMdlAlc:LoadValue("ALC_SAIDA", 	TecConvHr(SomaHoras(TecConvHr(aHorEsca[nY][2]), nDifHr)))
								EndIf
								oMdlAlc:LoadValue("ALC_TIPO",	cTipo)
								oMdlAlc:LoadValue("ALC_SEQ",	cSeq)
								oMdlAlc:LoadValue("ALC_TURNO",	cTurno)
								If lSaida
									oMdlAlc:LoadValue("ALC_HEPLAN",	"1")
								EndIf
							EndIf
							If TecConvHr(aHorEsca[nY][2]) < TecConvHr(aHorEsca[nY][1])
								dDataAux := DaySum(dDataAux,1)
							EndIf
						Next nY 
					EndIf
				EndIf
			EndIf
		EndIf

	Next nX
EndIf

nLinha := 1

For nX := 1 To oMdlAlc:Length()
	oMdlAlc:GoLine(nX)
	
	If !oMdlAlc:IsDeleted()
		AADD( aAgenda, { oMdlAlc:GetValue("ALC_DATREF"),;
						 oMdlAlc:GetValue("ALC_DATDIA"),;
						 oMdlAlc:GetValue("ALC_ENTRADA"),;
						 oMdlAlc:GetValue("ALC_SAIDA"),;
						 oMdlAlc:GetValue("ALC_TIPO"),;
						 oMdlAlc:GetValue("ALC_SEQ"),;
						 oMdlAlc:GetValue("ALC_TURNO"),;
						 oMdlAlc:GetValue("ALC_INTERV"),;
						 oMdlAlc:GetValue("ALC_SITABB")})
	EndIf
Next nX
ASORT(aAgenda,,, { |x, y| x[1] < y[1]} )

For nX := 1 To Len(aAgenda)	
	If !oMdlAlc19:IsEmpty()
		nLinha := oMdlAlc19:AddLine()
	EndIf

	oMdlAlc19:GoLine(nLinha)

	oMdlAlc19:LoadValue("ALC_SITABB", aAgenda[nX][9])
	oMdlAlc19:LoadValue("ALC_GRUPO", 	1)
	oMdlAlc19:LoadValue("ALC_DATREF", aAgenda[nX][1])
	oMdlAlc19:LoadValue("ALC_DATA", 	aAgenda[nX][2])
	oMdlAlc19:LoadValue("ALC_SEMANA", TECCdow(Dow(aAgenda[nX][2])))
	oMdlAlc19:LoadValue("ALC_ENTRADA", aAgenda[nX][3])
	oMdlAlc19:LoadValue("ALC_SAIDA", 	aAgenda[nX][4])
	oMdlAlc19:LoadValue("ALC_TIPO",	aAgenda[nX][5])
	oMdlAlc19:LoadValue("ALC_SEQ",	aAgenda[nX][6])
	oMdlAlc19:LoadValue("ALC_TURNO",	aAgenda[nX][7])
	oMdlAlc19:LoadValue("ALC_INTERV",	aAgenda[nX][8])
Next nX

lRet := At190dExec("GravaAloc2( .F., @xPar, .T., @xPar2, @xPar3 )", @cSitABB, @oMdl190D, @lDelConf)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GHrsT
@description Função de Calculo para o total de horas do periodo
@return nTot	
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GHrsT()
	Local oModel	:= FwModelActive()
	Local oMdlALC	:= oModel:GetModel("ALCDETAIL")
	Local cRet		:= "00:00"

	If !Empty(oMdlALC:GetValue("ALC_ENTRADA")) .AND. !Empty(oMdlALC:GetValue("ALC_SAIDA"))
		cRet := Left(ElapTime(oMdlALC:GetValue("ALC_ENTRADA")+":00", oMdlALC:GetValue("ALC_SAIDA")+":00"), 5)
	EndIf
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GSalH
@description Função de Calculo de saldo de horas
@return nTotal
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GSalH( lSubtrai, cOldValue, cNewValue )
Local oModel	:= FwModelActive()
Local oMdlTOT	:= oModel:GetModel("TOTDETAIL")
Local cTotal  := "00:00"
Local lTrataData := .T.

If lSubtrai
	cTotal := TecConvHr(SomaHoras(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS"), lTrataData), TecConvHr(cOldValue, lTrataData)), TecConvHr(cNewValue, lTrataData)), lTrataData)
Else
	cTotal := TecConvHr(SomaHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS"), lTrataData), TecConvHr(cNewValue, lTrataData)), lTrataData)
EndIf

oMdlTOT:LoadValue("TOT_SALHRS", cTotal)

oMdlTOT:LoadValue("TOT_RESTSAL", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL"), lTrataData), TecConvHr(cTotal, lTrataData)), lTrataData))

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GPrAL
@description Realiza validações da linha do modelo ALC
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GPrAL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
	Local lRet 			:= .T.
	Local aSaveLines	:= FWSaveRows()
	Local aArea			:= GetArea()
	Local oMdlTOT		:= Nil
	Local lSubtrai		:= .F.

	If !lAlocAvuls
		If cAcao == 'DELETE'
			If TecConvHr(oMdlG:GetValue("ALC_TOTHRS")) > 0
				oMdlTOT := oMdlG:GetModel():GetModel("TOTDETAIL")
				oMdlTOT:LoadValue("TOT_SALHRS", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")), TecConvHr(oMdlG:GetValue("ALC_TOTHRS")))))
				oMdlTOT:LoadValue("TOT_RESTSAL", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL")), TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")))))
			EndIf
		EndIf

		If cAcao == 'UNDELETE'
			If TecConvHr(oMdlG:GetValue("ALC_TOTHRS")) > 0
				oMdlTOT := oMdlG:GetModel():GetModel("TOTDETAIL")
				oMdlTOT:LoadValue("TOT_SALHRS", TecConvHr(SomaHoras(TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")), TecConvHr(oMdlG:GetValue("ALC_TOTHRS")))))
				oMdlTOT:LoadValue("TOT_RESTSAL", TecConvHr(SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL")), TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")))))
			EndIf
		EndIf
	EndIf
	If cAcao == 'SETVALUE'

		If cCampo == "ALC_TURNO"
			If !EMPTY(xValue)
				lRet := CheckSR6(AT190dLimp(xValue))
				If !lRet
					Help(,,"AT190GPrAL",, STR0026 ,1,0) //"O turno digitado não foi encontrado."
				EndIf
			EndIf
			WhensALC("ALC_TURNO")
		ElseIf cCampo == "ALC_SEQ"
			If !EMPTY(xValue)
				lRet := CheckSPJ(AT190dLimp(xValue), , oMdlG:GetValue("ALC_TURNO") )
				If !lRet
					Help(,,"AT190GPrAL",, STR0027 ,1,0) //"A sequencia digitada não foi encontrada."
				EndIf
			EndIf
		EndIf
		If (cCampo == "ALC_ENTRADA" .OR. cCampo == "ALC_SAIDA")
			If LEN(ALLTRIM(xValue)) == 5 .AND. AT(":",xValue) == 0
				lRet := .F.
				Help( " ", 1, "AT190GPrAL", Nil, STR0038, 1 )	//"Horário inválido. Por favor, insira um horário no formato HH:MM"
			EndIf
			If AT(":",xValue) == 0 .AND. AtJustNum(Alltrim(xValue)) == Alltrim(xValue) .AND. lRet
				If LEN(Alltrim(xValue)) == 4
					xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
				ElseIf LEN(Alltrim(xValue)) == 2
					xValue := Alltrim(xValue) + ":00"
				ElseIf LEN(Alltrim(xValue)) == 1
					xValue := "0" + Alltrim(xValue) + ":00"
				EndIf
			EndIf
			If lRet
				lRet := AtVldHora(Alltrim(xValue)) .And. At190GVldHr(oMdlG, xValue)
			EndIf
		ElseIf cCampo == "ALC_DATREF"
			lRet := At190GVldDtRef(oMdlG, xValue)
			If lRet .and. lAlocAvuls .and. !Empty(xValue)
				lRet := At190GAvul(oMdlG, xValue)
			EndIf
		EndIf
		If cCampo == 'ALC_TOTHRS'
			If TecConvHr(xValue) < 0 
				Help(,,"AT190GPrAL",, STR0028 ,1,0) //"O total de Horas do dia não pode ser menor que o total de horas restante."
				lRet := .F.
			EndIf
			If !Empty(xOldValue)
				lSubtrai := .T.
			EndIf
			If !lAlocAvuls
				AT190GSalH( lSubtrai, xOldValue, xValue )
			EndIf
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GVld
@description Realiza validações do modelo ALC
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GVld( oModel )
Return ChecarConf( oModel )
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GPoAL
@description Realiza validações pos linha da ALC
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
function AT190GPoAL(oMdlG, nLine, cAcao, cCampo)
	Local aAgenda    := {}
	Local aArea      := GetArea()
	Local aSaveLines := FWSaveRows()
	Local lRet       := .T.
	Local nLinha     := 0
	Local oMdlFull   := oMdlG:GetModel()
	Local oMdlTOT    := Nil

	If !lAlocAvuls
		oMdlTOT		:= oMdlFull:GetModel("TOTDETAIL")

		If TecConvHr(oMdlG:GetValue("ALC_TOTHRS")) == 0
			Help(,,"AT190GPoAL",, STR0028 ,1,0) //"O total de Horas do dia não pode ser menor que o total de horas restante."
			lRet := .F.
		ElseIf TecConvHr(oMdlTOT:GetValue("TOT_SALHRS")) < 0
			Help(,,"AT190GPoAL",, STR0030 ,1,0) // "O saldo de horas não pode ser negativo"
			lRet := .F.
		ElseIf SubHoras(TecConvHr(oMdlTOT:GetValue("TOT_CTRSAL")), TecConvHr(oMdlTOT:GetValue("TOT_SALHRS"))) < 0
			Help(,,"AT190GPoAL	",, STR0036 ,1,0) // "O Total de Horas usada para aloação não pode ser maior que o do contrato."
			lRet := .F.
		EndIf
	Else
		If oMdlG:Length() > 1
			for nLinha := 1 To oMdlG:Length()
				oMdlG:GoLine(nLinha)
				AADD( aAgenda, {oMdlG:GetValue("ALC_DATREF"),;
								oMdlG:GetValue("ALC_ENTRADA"),;
								oMdlG:GetValue("ALC_SAIDA")})
			next nLinha
			
			lRet := At190GVldC(aAgenda)
		EndIf
	EndIF

	FWRestRows( aSaveLines )
	RestArea(aArea)

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecarConf
@description Mensagem de espera para fazer a checagem
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function ChecarConf( oModel )
Local lRet := .T.
FwMsgRun(Nil,{|| ChkConf(@lRet, oModel)}, Nil, STR0032) // "Realizando a checagem de conflitos!"
Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkConf
@description Checa conflitos
@return lOpc
@author Serviços
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ChkConf( lRet, oModel )
	Local oMdlALC    := oModel:GetModel("ALCDETAIL")
	Local oView      := FwViewActive()
	Local aFieldsQry := {'AA1_FILIAL','AA1_CODTEC','AA1_NOMTEC','ABB_DTINI','ABB_HRINI','ABB_DTFIM',;
						 'ABB_HRFIM','RA_SITFOLH','RA_ADMISSA','RA_DEMISSA','RF_DATAINI','RF_DFEPRO1','RF_DATINI2',;
						 'RF_DFEPRO2','RF_DATINI3','RF_DFEPRO3','R8_DATAINI','R8_DATAFIM',;
						 "DTINI", "DTFIM", 'HRINI' ,"HRFIM", "ATIVO", "DTREF"}
	Local aAgenda    := {}
	Local aArrAdi    := {}
	Local aArrAfast  := {}
	Local aArrConfl  := {}
	Local aArrDem    := {}
	Local aArrDFer   := {}
	Local aArrDFer2  := {}
	Local aArrDFer3  := {}
	Local aAux       := {}
	Local aAuxAgenda := {}
	Local aAuxDT     := {}
	Local cAlocEftv  := POSICIONE("TCU",1, xFilial( 'TCU' ) + oMdl190d:GetValue("TGYMASTER", "TGY_TIPALO"), "TCU_ALOCEF")
	Local cCodTec    := FwFldGet("AA1_CODTEC")
	Local cCodTff    := oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD")
	Local cFilTFF    := xFilial( "TFF", cFilAnt )
	Local cNotIdcFal := ""
	Local dDatFim    := CtoD("")
	Local dDatIni    := CtoD("")
	Local dDtCnfFim  := CtoD("")
	Local dDtCnfIni  := CtoD("")
	Local dDtEnce    := CtoD("")
	Local dMenorDt   := CtoD("")
	Local lAterouSeq := .F.
	Local lContinua  := .T.
	Local lEnceDT    := FindFunction("TecEncDtFt") .AND. TecEncDtFt()
	Local lGSVERHR   := SuperGetMV("MV_GSVERHR",,.F.)
	Local lHasConfl  := .F.
	Local lHelp      := .T.
	Local lIntermi   := .F.
	Local lPergunte  := .F.
	Local lPostoEnc  := .F.
	Local lProcessa  := .T.
	Local lResRHTXB  := TableInDic("TXB")
	Local lRestrFT   := .F.
	Local lRestrRH   := .F.
	Local nC         := 0
	Local nDelet     := 0
	Local nHrFim     := 0
	Local nHrFimAge  := 0
	Local nHrIni     := 0
	Local nHrIniAge  := 0
	Local nLineBckp  := oMdlALC:GetLine()
	Local nOpc       := 1
	Local nPos       := 0
	Local nPosdFim   := 0
	Local nPosdIni   := 0
	Local nPosDtRef  := 0
	Local nPosHrFim  := 0
	Local nPosHrIni  := 0
	Local nPosTipMov := 0
	Local nTXBDtFim  := 0
	Local nTXBDtIni  := 0
	Local nX         := 0
	
	SPJ->(dbSetOrder(1))

	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))

	If SRA->(DbSeek(Posicione("AA1",1,xFilial("AA1")+AA1->AA1_CODTEC,"AA1_FUNFIL")+AA1->AA1_CDFUNC))
		If SRA->RA_TPCONTR == "3"
			lIntermi := .T.
		EndIf
	EndIf

	For nX := 1 To oMdlALC:Length()
		oMdlAlc:GoLine(nX)
		If !oMdlAlc:IsDeleted()
			If ! SPJ->(dbSeek(xFilial("SPJ") + oMdlAlc:GetValue("ALC_TURNO") + oMdlAlc:GetValue("ALC_SEQ")))
				Aviso(STR0049, STR0050 + oMdlAlc:GetValue("ALC_SEQ") + STR0051 + oMdlAlc:GetValue("ALC_TURNO") + STR0052) //Atenção ## a sequência ## do turno ## é inválida
				nOpc := 0
				lRet := .F.
				Exit
			Endif
			
			If lGSVERHR
				If AsCan( aAgenda,{|e| e[1] == oMdlAlc:GetValue("ALC_DATREF") .AND. (e[2] >= oMdlAlc:GetValue("ALC_ENTRADA") .And.;
							e[3] <= oMdlAlc:GetValue("ALC_SAIDA"))}) > 0
					lContinua := .F.
					lRestrRH := .T.
				EndIf
			Else
				If AsCan( aAgenda,{|e| e[1] == oMdlAlc:GetValue("ALC_DATREF")}) > 0 
					lContinua := .F.
					lRestrRH := .T.
				EndIf
			EndIf
			If lIntermi
				aPeriodo := Tec190QPer(AA1->AA1_CDFUNC, AA1->AA1_CODTEC,oMdlAlc:GetValue("ALC_DATREF"), oMdlAlc:GetValue("ALC_DATREF"), Posicione("AA1",1,xFilial("AA1")+AA1->AA1_CODTEC,"AA1_FUNFIL"))
				If Empty(aPeriodo)
					lRet := .F.
					oMdlALC:LoadValue("ALC_SITABB", "BR_AZUL" )
					loop
				Endif	
			EndIf
			AADD( aAgenda, {oMdlAlc:GetValue("ALC_DATREF"),;
							oMdlALc:GetValue("ALC_SAIDA"),;
							oMdlALc:GetValue("ALC_ENTRADA")})
			If lContinua
				cHorIni := oMdlALc:GetValue("ALC_ENTRADA")
				cHorFim := oMdlALc:GetValue("ALC_SAIDA")
				dDatIni := oMdlALc:GetValue("ALC_DATREF")
				dDatFim := If( cHorFim < cHorIni, dDatIni + 1, dDatIni)
				If lEnceDT
					dDtEnce := POSICIONE("TFF",1,cFilTFF+cCodTff,"TFF_DTENCE") 	
				EndIf			

				If lEnceDT .AND. POSICIONE("TFF",1,cFilTFF+cCodTff,"TFF_ENCE") == '1' .AND. dDatIni >= dDtEnce
					nOpc := 0
					lRet := .F.
					lPostoEnc := .T.					
					Help( " ", 1, "AT190GHrsT", Nil,STR0062+DToC(dDtEnce)+STR0063, 1 )	//	"Não é possível gerar nova(s) agenda(s), pois o posto possui encerramento para o dia " ## ". Com isso não é possível gerar agenda após essa data."
				EndIf	
			EndIf
			If lContinua .And. lRet 
				aAteABB := At330AVerABB( dDatIni, dDatFim, cCodTff, cFilTFF, cCodTec, @cNotIdcFal )

				ChkCfltAlc(dDatIni, dDatFim, cCodTec, /*cHoraIni*/, /*cHoraFim*/, .F., @aFieldsQry,;
											@aArrConfl, @aArrDem, @aArrAfast, @aArrDFer, @aArrDFer2, @aArrDFer3,;
											cNotIdcFal, .T./*lCheckRT*/,/*cFilABB*/,/*dDtRef*/,/*cIdcFal*/,@aArrAdi)
				If !EMPTY(aAteABB)
						aAuxAgenda := ACLONE(aAteABB)
						ASORT(aAuxAgenda,,, { |x, y| x[1] < y[1] } )
					If dDatIni <= aAuxAgenda[1][1] .AND. dDatFim > aAuxAgenda[LEN(aAuxAgenda)][1]
							cSeq := aAuxAgenda[1][8]
							lAterouSeq := .T.
					EndIf
				EndIf

				If lResRHTXB
					nTXBDtIni := AScan(aFieldsQry,{|e| e == 'TXB_DTINI'})
					nTXBDtFim := AScan(aFieldsQry,{|e| e == 'TXB_DTFIM'})
				Endif

				nPosdIni   := AScan(aFieldsQry,{|e| e == 'DTINI'})
				nPosdFim   := AScan(aFieldsQry,{|e| e == 'DTFIM'})
				nPosHrIni  := AScan(aFieldsQry,{|e| e == 'HRINI'})
				nPosHrFim  := AScan(aFieldsQry,{|e| e == 'HRFIM'})
				nPosDtRef  := AScan(aFieldsQry,{|e| e == 'DTREF'})
				nPosTipMov := AScan(aFieldsQry,{|e| e == 'TCU_ALOCEF'})

				aAux := Array(TAMANHO)
				lRestrRH := .F.

				If !lRestrRH .And. Len(aArrDFer) > 0  
					nPos := Ascan(aArrDFer,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
					If (lRestrRH :=  nPos > 0)
						lHasConfl := .T.
					EndIf
				EndIf

				If !lRestrRH .And. Len(aArrDFer2) > 0  
					nPos := Ascan(aArrDFer2,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
					If (lRestrRH :=  nPos > 0)
						lHasConfl := .T.
					EndIf
				EndIf  

				If !lRestrRH .And. Len(aArrDFer3) > 0  
					nPos := Ascan(aArrDFer3,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
					If (lRestrRH := nPos > 0)
						lHasConfl := .T.
					EndIf
				EndIf

				If !lRestrRH .And. Len(aArrAdi) > 0  
					nPos := Ascan(aArrAdi,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND.  dDatIni <= x[2] } )
					If (lRestrRH := nPos > 0)
						lHasConfl := .T.
					EndIf
				EndIf

				If !lRestrRH .And. Len(aArrDem) > 0  
					nPos := Ascan(aArrDem,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND.  dDatIni >= x[2] } )
					If (lRestrRH := nPos > 0)
						lHasConfl := .T.
					EndIf
				EndIf

				If !lRestrRH .And. Len(aArrAfast) > 0  
					nPos := Ascan(aArrAfast,{|x| Alltrim(x[1]) == Alltrim(cCodTec) .AND. dDatIni >= x[2] .And. dDatIni <= x[3] } )
					If (lRestrRH := nPos > 0)
						lHasConfl := .T.
					EndIf
				EndIf

				If !lRestrRH .And. Len(aArrConfl) > 0 .And. lResRHTXB
					nPos := Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(cCodTec) .AND.;
					!Empty(x[nTXBDtIni]) .AND. dDatIni >= sTod(x[nTXBDtIni]) .And.;
					( Empty(x[nTXBDtFim]) .Or. dDatIni <= sTod(x[nTXBDtFim]) ) } )
					If (lRestrRH := nPos > 0)
						lHasConfl := .T.
					EndIf
				EndIf

				If !lRestrRH .And. Len(aArrConfl) > 0  
					nLastPos := 0
					lProcessa := .T.

					Do While lProcessa
						nLastPos++
						nPos := Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(cCodTec) .And.;
								( dDatIni == x[nPosdIni] .Or.  dDatIni == x[nPosdFim] .Or. dDatFim == x[nPosdIni] .Or.;
								dDatFim == x[nPosdFim] ) }, nLastPos )
						nLastPos := nPos
						If nPos > 0				
							lRestrRH     := .T.				
							aAux[EXSABB] := "1"		

							nHrIniAge := VAL(AtJustNum(cHorIni))
							nHrFimAge := VAL(AtJustNum(cHorFim))	
							nHrIni    := VAL(AtJustNum(aArrConfl[nPos,nPosHrIni]))
							nHrFim    := VAL(AtJustNum(aArrConfl[nPos,nPosHrFim]))
							dDtCnfIni := aArrConfl[nPos,nPosdIni]
							dDtCnfFim := aArrConfl[nPos,nPosdFim]
							lRestrFT  := aArrConfl[nPos,nPosTipMov] == "2" .And. cAlocEftv == "2"

							dMenorDt := CtoD("")
							aAuxDT := {dDtCnfIni,dDtCnfFim,dDatIni,dDatFim}
							For nC := 1 To LEN(aAuxDT)
								If EMPTY(dMenorDt) .OR. dMenorDt > aAuxDT[nC]
									dMenorDt := aAuxDT[nC]
								EndIf
							Next nC

							nHrIni    += 2400 * (dDtCnfIni - dMenorDt)
							nHrFim    += 2400 * (dDtCnfFim - dMenorDt)
							nHrIniAge += 2400 * (dDatIni - dMenorDt)
							nHrFimAge += 2400 * (dDatFim - dMenorDt)

							If nHrIniAge >= nHrIni .AND. nHrIniAge <= nHrFim
								lRestrRH     := .T.
								aAux[EXSABB] := "1"
								lProcessa    := .F.
							ElseIf nHrFimAge >= nHrIni .AND. nHrFimAge <= nHrFim
								lRestrRH := .T.
								aAux[EXSABB] := "1"
								lProcessa := .F.
							ElseIf nHrIniAge <= nHrIni .AND. nHrFimAge >= nHrFim
								lRestrRH := .T.
								aAux[EXSABB] := "1"
								lProcessa := .F.
							ElseIf nHrIniAge >= nHrIni .AND. nHrFimAge <= nHrFim
								lRestrRH := .T.
								aAux[EXSABB] := "1"
								lProcessa := .F.		
							Else
								lRestrRH     := .F.
								aAux[EXSABB] := "2"
							EndIf
							If !lGSVERHR .AND. !lRestrRH
								If Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(cCodTec) .And. (dDatIni == x[nPosDtRef]) }, nLastPos ) > 0
									lRestrRH := .T.
									aAux[EXSABB] := "1"
									lProcessa := .F.
								EndIf
							EndIf			
						Else		
							aAux[EXSABB] := "2"
							lProcessa := .F.
						EndIf
					End 
				Else			
					aAux[EXSABB] := "2"
				EndIf

				If aAux[EXSABB] == "1"
					lHasConfl := .T.
				EndIf	
			EndIf	
		EndIf
		If oMdlALC:Isdeleted()
			nDelet++
		Endif
		oMdlALC:LoadValue("ALC_SITABB", At330ACLgA( , , , lRestrRH))
		If lRestrRH .AND. !lPergunte
			lPergunte := .T.
		EndIf
		lContinua := .T.
	Next nX

	oMdlALC:GoLine(nLineBckp)
	
	If !lHelp .OR. lPergunte
		If lMesaPOUI
			nOpc := nOpcaoPOUI
		Else
			nOpc := Aviso( STR0039, STR0040, {STR0041, STR0042}) // "Atenção" ## "Uma ou mais agendas possui confilto deseja continuar com as validações ou visualizar as agendas?" ## "Continuar" ## "Visualizar"
		EndIf
	EndIf	
	If nOpc == 1 .And. lRet
		lRet := At190dExec("VldGrvAloc( @xPar, @xPar2, Nil, @xPar3 )", @cSitABB, @lDelConf, @lRestrFT)
	else
		lRet := .F.
	EndIf
	If !lRet .AND. !IsBlind()
		If !lMesaPOUI .And. !lRestrFT
			Help(,,"AT190GHrsT",, STR0043 ,1,0) // "Operação Cancelada."
		EndIf
		If lPostoEnc	
			If !lMesaPOUI	
				Help( " ", 1, "AT190GHrsT", Nil,STR0062+DToC(dDtEnce)+STR0063, 1 )	//	"Não é possível gerar nova(s) agenda(s), pois o posto possui encerramento para o dia " ## ". Com isso não é possível gerar agenda após essa data."
			Else
				oMdlALC:SetErrorMessage(oMdlALC:GetId(),,oMdlALC:GetId(),,"AT190GHrsT",;
				STR0062+DToC(dDtEnce)+STR0063, " ")
			EndIf
		EndIf
		oView:Refresh("DETAIL_ALC")	
	EndIf

	IF oMdlALC:Length() == nDelet
		lRet := .F.
		Help(,,"AT190GHrsT",, STR0064 ,1,0) // "Operação Cancelada."
	Endif

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WhensALC@description Faz o travamento do campo na estrutura ALC
@return lOpc
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function WhensALC( cCampo )
Local oModel := FwModelActive()
Local oMdlALC := oModel:GetModel("ALCDETAIL")
Local lOpc := .T.

If Empty(oMdlALC:GetValue(cCampo))
	lOpc := .F.
EndIf

Return lOpc

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckSR6
@description Fazer a checagem na tabela SR6 para ver se o registro existe
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CheckSR6( xValue, cFilCtr )
Local cQry
Local lRet := .T.
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Default cFilCtr := cFilAnt
cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("SR6") + " SR6 "
cQry += " WHERE SR6.R6_FILIAL = '" +  xFilial('SR6', IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
cQry += " SR6.D_E_L_E_T_ = ' ' "
cQry += " AND SR6.R6_TURNO = '" + xValue + "' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckSPJ
@description Fazer a checagem na tabela SPJ para ver se o registro existe
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CheckSPJ( xValue, cFilCtr, cTurno )
Local cQry
Local lRet := .T.
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Default cFilCtr := cFilAnt
cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("SPJ") + " SPJ "
cQry += " WHERE SPJ.PJ_FILIAL = '" +  xFilial('SPJ', IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
cQry += " SPJ.D_E_L_E_T_ = ' ' "
cQry += " AND SPJ.PJ_TURNO = '" + cTurno + "' "
cQry += " AND SPJ.PJ_SEMANA = '" + xValue + "' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} QryEOF()

Executa uma qry e retorna se EOF

@author boiani
@since 29/07/2019
/*/
//------------------------------------------------------------------------------
Static Function QryEOF(cSql, lChangeQry)
Local lRet := .F.
Local cAliasQry := GetNextAlias()
Default lChangeQry := .T.
If lChangeQry
	cSql := ChangeQuery(cSql)
EndIf
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
lRet := (cAliasQry)->(EOF())
(cAliasQry)->(DbCloseArea())
Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTurnTGY
@description retorno do ultimo turno da TGY
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetTurnTGY(cCampo,cQry)

	Local nOrder     := 1
	Local oExec      := Nil
	Local cAliasQry  := GetNextAlias()
	Local cRet       := ""

	cF3Ret  := FwFldGet("ALC_TURNO")
	
	If !lAlocAvuls	
		cQry := "SELECT TOP 1 "
		cQry +=        "TGY.TGY_TURNO AS CODIGO, "		
		cQry +=        "TGY.TGY_TURNO AS DESCRICAO, "
		cQry +=        "TGY.TGY_ULTALO, "
		cQry +=        "TGY.TGY_SEQ, "
		cQry +=        "TGY.TGY_CODTDX, "
		cQry +=        "'TGY - Último Efetivo' AS ORIGEM "
		cQry += "FROM   ? TGY "
		cQry += "WHERE  TGY.TGY_FILIAL = ? "
		cQry +=        "AND TGY.TGY_ATEND = ? "
		cQry +=        "AND TGY.D_E_L_E_T_ = ' ' "
		cQry += "ORDER BY TGY_ULTALO DESC "

		oExec := FwExecStatement():New(cQry)

		nOrder:= 1
		oExec:SetUnsafe( nOrder++, RetSQLName("TGY") )
		oExec:SetString( nOrder++, xFilial("TGY") )
		oExec:SetString( nOrder++, oMdl190d:GetValue("AA1MASTER","AA1_CODTEC") )
		
		cAliasQry := oExec:OpenAlias()
		If !(cAliasQry)->(EOF())
			If cCampo == 'TURNO'
				cRet := (cAliasQry)->CODIGO
			Else
				cRet := (cAliasQry)->TGY_SEQ
			EndIf
			cCodTDX := (cAliasQry)->TGY_CODTDX
		EndIf

		(cAliasQry)->(DbCloseArea())

		If Empty(cRet)
			If cCampo == 'TURNO'
				cContCamp := "TFF_TURNO"
			Else
				cContCamp := "TFF_SEQTRN"
			EndIf
			cRet := POSICIONE("TFF",1,oMdl190d:GetValue("TGYMASTER", "TGY_FILIAL")+oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD"), cContCamp)
		EndIf

		cQry := oExec:GetFixQuery()
		oExec:Destroy()
		FwFreeObj(oExec)
	Else
		If VALTYPE(oMdl190D) == "O" .AND. oMdl190D:GetId() = "TECA190D" .AND. !EMPTY(oMdl190D:GetValue("TGYMASTER","TGY_ESCALA"))
			If cCampo == 'TURNO'
				cQry := "SELECT TOP 1 "
    			cQry +=        "COALESCE(TDX.TDX_TURNO, '') AS CODIGO, "  
    			cQry +=        "CAST(COALESCE(SR6.R6_DESC, '') AS VARCHAR(30)) AS DESCRICAO, "  
    			cQry +=        "COALESCE(TDX.TDX_SEQTUR, '') AS SEQUENCIA,"  
    			cQry +=        "CAST('TDX - Posto' AS VARCHAR(23)) AS ORIGEM "  			    
				cQry += "FROM ? SR6 "
				cQry +=        "LEFT JOIN ? TDX "
				cQry +=               "ON TDX.TDX_FILIAL = ? "   
				cQry +=                  "AND TDX.TDX_TURNO = SR6.R6_TURNO "   
				cQry +=                  "AND TDX.D_E_L_E_T_ = ' ' " 				
				cQry += "WHERE  TDX.TDX_FILIAL = ? "
				cQry +=        "AND TDX.TDX_CODTDW = ? "
				cQry +=        "AND SR6.D_E_L_E_T_ = ' ' "
				cQry += "UNION ALL "
				cQry += "SELECT TOP 1 "
				cQry +=        "COALESCE(SRA.RA_TNOTRAB, '') AS CODIGO, "  
				cQry +=        "CAST(COALESCE(SR6.R6_DESC, '') AS VARCHAR(30)) AS DESCRICAO, " 
				cQry +=        "COALESCE(SRA.RA_SEQTURN, '') AS SEQUENCIA, "       
				cQry +=        "CAST('SRA - Turno Funcionário' AS VARCHAR(23)) AS ORIGEM "       
				cQry += "FROM ? AA1 "
				cQry +=        "LEFT JOIN ? SRA "
				cQry +=               "ON SRA.RA_FILIAL = AA1.AA1_FUNFIL "  
				cQry +=                  "AND SRA.RA_MAT = AA1.AA1_CDFUNC "     
				cQry +=                  "AND SRA.D_E_L_E_T_ = ' ' " 				
				cQry +=        "LEFT JOIN ? SR6 "
				cQry +=               "ON SR6.R6_FILIAL = ? "
				cQry +=                  "AND SR6.R6_TURNO = SRA.RA_TNOTRAB "
				cQry +=                  "AND SR6.D_E_L_E_T_ = ' ' "
				cQry += "WHERE  AA1.AA1_FILIAL = ? "   
				cQry +=        "AND AA1.AA1_CODTEC = ? "   
				cQry +=        "AND AA1.D_E_L_E_T_ = ' ' "
				cQry += "UNION ALL "
				cQry += "SELECT TOP 1 "
				cQry +=        "COALESCE(TGY.TGY_TURNO, '') AS CODIGO, "  
				cQry +=        "CAST(COALESCE(SR6.R6_DESC, '') AS VARCHAR(30)) AS DESCRICAO, " 
				cQry +=        "COALESCE(TGY.TGY_SEQ, '') AS SEQUENCIA, "    	    
				cQry +=        "CAST('TGY - Último Efetivo' AS VARCHAR(23)) AS ORIGEM "    	    
				cQry += "FROM ? TGY "			
				cQry +=        "LEFT JOIN ? SR6 "
				cQry +=               "ON SR6.R6_FILIAL = ? "
				cQry +=                  "AND SR6.R6_TURNO = TGY.TGY_TURNO "
				cQry +=                  "AND SR6.D_E_L_E_T_ = ' ' "
				cQry += "WHERE  TGY.TGY_FILIAL = ? "   
				cQry +=        "AND TGY.TGY_ATEND = ? "   
				cQry +=        "AND TGY.D_E_L_E_T_ = ' ' "

				oExec := FwExecStatement():New(cQry)

				nOrder:= 1
				oExec:SetUnsafe( nOrder++, RetSQLName("SR6") )
				oExec:SetUnsafe( nOrder++, RetSQLName("TDX") )
				oExec:SetString( nOrder++, xFilial("TDX") )	
				oExec:SetString( nOrder++, xFilial("TDX") )	
				oExec:SetString( nOrder++, oMdl190D:GetValue("TGYMASTER","TGY_ESCALA") )

				oExec:SetUnsafe( nOrder++, RetSQLName("AA1") )
				oExec:SetUnsafe( nOrder++, RetSQLName("SRA") )
				oExec:SetUnsafe( nOrder++, RetSQLName("SR6") )
				oExec:SetString( nOrder++, xFilial("SR6") )
				oExec:SetString( nOrder++, xFilial("AA1") )
				oExec:SetString( nOrder++, oMdl190d:GetValue("AA1MASTER","AA1_CODTEC") )

				oExec:SetUnsafe( nOrder++, RetSQLName("TGY") )
				oExec:SetUnsafe( nOrder++, RetSQLName("SR6") )
				oExec:SetString( nOrder++, xFilial("SR6") )	
				oExec:SetString( nOrder++, xFilial("TGY") )	
				oExec:SetString( nOrder++, oMdl190d:GetValue("AA1MASTER","AA1_CODTEC") )
				
				cAliasQry := oExec:OpenAlias()

				If !(cAliasQry)->(EOF())
						cRet := (cAliasQry)->CODIGO
				EndIf

				(cAliasQry)->(DbCloseArea())
				cQry := oExec:GetFixQuery()
				oExec:Destroy()
				FwFreeObj(oExec)
			
			EndIf		
		EndIf 
	EndIf	

Return cRet

/*/{Protheus.doc} At190GAlAv()

Função utilizada para instanciar o modelo desconsiderando a alocação por hora

@author boiani
@since 28/08/2020
/*/
//------------------------------------------------------------------
Function At190GAlAv(cCodAtend)

Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
                    {.T.,STR0046},{.T.,STR0047},{.T.,Nil},{.T.,Nil},{.T.,Nil},; //"Salvar"##"Cancelar"
                    {.T.,Nil},{.T.,Nil},{.T.,Nil}}
lAlocAvuls := .T.
FwExecView( STR0045, "VIEWDEF.TECA190G", MODEL_OPERATION_INSERT, /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) //"Alocação Avulsa"
lAlocAvuls := .F.
Return 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecGetAvul
@description retorno a variavel static para saber se é alocação por hora ou avulsa.
@author Augusto Albuquerque
@since  13/01/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecGetAvul()
Return lAlocAvuls

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EscalManut
@description Realiza a logica a popula o array para ser usado na manutenção planejada.
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function EscalManut( cEscala, cTurno, cSeq, cDiaSem, aHorEsca, nDifHr, dDataRef, lSubtrai, lSaida, cCodTFF )
Local cAliasTDX	:= GetNextAlias()
Local cQuery 	:= ""
Local cSpcCdTFF	:= Space(TamSx3("TFF_COD")[1])
Local cHrIni	:= ""
Local cHrFim	:= ""
Local lMtFilTFF := TXH->( ColumnPos("TXH_MTFIL")) > 0
Local lFeriad   := TXH->( ColumnPos("TXH_FERIAD")) > 0
Local lRet		:= .F.
Local nCount	:= 0
Local nAux		:= 0

cQuery := ""
cQuery += " SELECT TXH.TXH_CODTCU, TXH.TXH_CODTFF, TXH.TXH_HORAFI, TXH.TXH_HORAIN, TXH.TXH_MANUT, TXH.TXH_CODPAI, TXH.TXH_CODIGO, "
cQuery += " TDX.TDX_SEQTUR, TGW.TGW_DIASEM, TGW.TGW_HORINI, TGW.TGW_HORFIM, TGW.TGW_EFETDX "
If lMtFilTFF
	cQuery += " , TXH.TXH_MTFIL "
EndIf
If lFeriad
	cQuery += " , TXH.TXH_FERIAD "
EndIf
cQuery += " FROM " + RetSqlName("TXH") + " TXH "
cQuery += " INNER JOIN " + RetSqlName("TGW") + " TGW "
cQuery += " ON TGW.TGW_FILIAL = '" + xFilial("TGW") + "' "
cQuery += " AND TGW.TGW_COD = TXH.TXH_CODPAI "
cQuery += " AND TGW.TGW_STATUS = '1' "
cQuery += " AND TGW.TGW_DIASEM = '" + cDiaSem + "' "
cQuery += " AND TGW.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName("TDX") + " TDX "
cQuery += " ON TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.TDX_COD = TGW.TGW_EFETDX "
cQuery += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cQuery += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cQuery += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
cQuery += " AND TDX.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TXH.TXH_FILIAL = '" + xFilial("TXH") + "' "
cQuery += " AND TXH.D_E_L_E_T_ = ' ' "
cQuery += " AND (TXH.TXH_CODTFF = '" + cCodTFF + "' OR TXH.TXH_CODTFF = '" + cSpcCdTFF +"') " 

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTDX, .F., .T.)

While !(cAliasTDX)->(EOF())
	nCount++
	If nCount > 1
		lSaida := .T.
	EndIf
	nAux := At580GEnSa(	(cAliasTDX)->(TGW_EFETDX)	,;
						(cAliasTDX)->(TGW_DIASEM),;
						(cAliasTDX)->(TGW_HORINI),;
						(cAliasTDX)->(TGW_HORFIM) )

	cHrIni	:= aHorEsca[nAux][1]
	cHrFim	:= aHorEsca[nAux][2]
	If (cAliasTDX)->(TGW_HORINI) <> TecConvHr((cAliasTDX)->(TXH_HORAIN))
		cHrIni := IntToHora(Round((HoraToInt((cAliasTDX)->(TXH_HORAIN))-HoraToInt(TecConvHr((cAliasTDX)->(TGW_HORINI))))+HoraToInt(cHrIni),2))
	Endif
	
	If (cAliasTDX)->(TGW_HORFIM) <> TecConvHr((cAliasTDX)->(TXH_HORAFI))
		cHrFim := IntToHora(Round((HoraToInt((cAliasTDX)->(TXH_HORAFI))-HoraToInt(TecConvHr((cAliasTDX)->(TGW_HORFIM))))+HoraToInt(cHrFim),2))
	Endif
	
	AADD(aManutPla, {(cAliasTDX)->(TXH_CODTCU),;	//[1]
					(cAliasTDX)->(TXH_CODTFF),;	//[2]
					IIF(lSubtrai, TecConvHr(SubHoras(TecConvHr(cHrFim), nDifHr)), TecConvHr(SomaHoras(TecConvHr(cHrFim), nDifHr))),;				//[3]
					IIF(lSubtrai, TecConvHr(SubHoras(TecConvHr(cHrIni), nDifHr)), TecConvHr(SomaHoras(TecConvHr(cHrIni), nDifHr))),;				//[4]
					(cAliasTDX)->(TXH_MANUT),;	//[5]
					(cAliasTDX)->(TDX_SEQTUR),;	//[6]
					(cAliasTDX)->(TGW_DIASEM),;	//[7]
					IIF(lSubtrai, SubHoras(TecConvHr( aHorEsca[nAux][1] ), nDifHr), SomaHoras(TecConvHr( aHorEsca[nAux][1] ), nDifHr)),;	//[8]
					IIF(lSubtrai, SubHoras(TecConvHr( aHorEsca[nAux][2] ), nDifHr), SomaHoras(TecConvHr( aHorEsca[nAux][2] ), nDifHr)),;  //[9]
					Iif(lMtFilTFF ,(cAliasTDX)->(TXH_MTFIL),""),; //[10]
					IIF(lFeriad, IIF(EMPTY((cAliasTDX)->(TXH_FERIAD)),"3",(cAliasTDX)->(TXH_FERIAD)), "3"),;	//[11]
					(cAliasTDX)->(TXH_CODPAI),;  //[12]
					(cAliasTDX)->(TXH_CODIGO)})  //[14]
	lRet := .T.
	(cAliasTDX)->(DbSkip())
EndDo
(cAliasTDX)->(DbCloseArea())
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetEscala
@description Retorna a escala conforme o turno e sequencia
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetEscala( cTurno, cSeq )
Local cAliasTDX	:= GetNextAlias()
Local cQuery 	:= ""
Local cRet		:= ""

cQuery += " SELECT TDX.TDX_CODTDW "
cQuery += " FROM " + RetSqlName("TDX") + " TDX "
cQuery += " Where TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cQuery += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cQuery += " AND TDX.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTDX, .F., .T.)

If !(cAliasTDX)->(EOF())
	cRet := (cAliasTDX)->TDX_CODTDW
EndIf
(cAliasTDX)->(DbCloseArea())
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HorTotEsca
@description Função para retornar o horario total trabalhado na escala
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function HorTotEsca( cEscala, cTurno, cSeq, cDiaSem, aHorEsca )
Local cAliasTDX	:= GetNextAlias()
Local cQuery 	:= ""
Local cRet		:= TecConvHr(0)
Local cHorIni	:= ""
Local cHorFim	:= ""

cQuery += " SELECT TGW.TGW_HORINI, TGW.TGW_HORFIM "
cQuery += " FROM " + RetSqlName("TDX") + " TDX "
cQuery += " INNER JOIN " + RetSqlName("TGW") + " TGW "
cQuery += " ON TGW.TGW_FILIAL = '" + xFilial('TGW') + "' "
cQuery += " AND TDX.TDX_COD = TGW.TGW_EFETDX "
cQuery += " AND TGW.TGW_STATUS != '3' "
cQuery += " AND TGW.TGW_DIASEM = '" + cDiaSem + "' "
cQuery += " AND TGW.D_E_L_E_T_ = ' ' "
cQuery += " Where TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cQuery += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cQuery += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
cQuery += " AND TDX.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTDX, .F., .T.)

While !(cAliasTDX)->(EOF())
	If Empty(cHorIni)
		cHorIni := TecConvHr((cAliasTDX)->TGW_HORINI)
	EndIf
	cHorFim := TecConvHr((cAliasTDX)->TGW_HORFIM)
	AADD( aHorEsca, {TecConvHr((cAliasTDX)->TGW_HORINI),;
					TecConvHr((cAliasTDX)->TGW_HORFIM)})
	(cAliasTDX)->(DbSkip())
EndDo
(cAliasTDX)->(DbCloseArea())

If !Empty(cHorIni) .AND. !Empty(cHorFim)
	cRet := ElapTime(cHorIni + ":00", cHorFim + ":00")
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetManutPla
@description retorno a variavel static para ser usada na manutenção planejada.
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetManutPla()
Return aManutPla

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GManP
@description Retorna se o mesmo deve entrar para a manutenção planejada ou não.
@author Augusto Albuquerque
@since  30/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190GManP( dDataRef )
Local oModel	:= FwModelActive()
Local oMdlAlc	:= oModel:GetModel("ALCDETAIL")
Local lRet		:= .F.

oMdlAlc:GoLine(1)

If oMdlAlc:SeekLine({{"ALC_DATREF",dDataRef}})
	lRet := oMdlAlc:GetValue("ALC_HEPLAN") == "1"
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViraDiaHR
@description Verifica se a virada de dia é na mesma entrada ou saida
@author Augusto Albuquerque
@since  14/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViraDiaHR(aHorEsca, nDifHr, lSubtrai)
Local lRet		:= .T.
Local cAux		:= ""
Local nViraNew 	:= 0
Local nViraEsc 	:= 0
Local nHorIni	:= 0
Local nHorFim	:= 0
Local nHrInPr	:= 0
Local nTotal	:= Len(aHorEsca)
Local nX

For nX := 1 To nTotal
	nHorIni := TecConvHr(aHorEsca[nX][1])
	nHorFim := TecConvHr(aHorEsca[nX][2])
	If  nHorIni > nHorFim .OR. (nX < nTotal .AND. nHorFim > TecConvHr(aHorEsca[nX+1][1]) )
		nViraEsc := nX
	EndIf

	If lSubtrai
		If (nHorIni := SubHoras(nHorIni, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorIni), 2)) 
			nHorIni := (24 - Int(nHorIni)) + TecConvHr(cAux)
		EndIf

		If (nHorFim := SubHoras(nHorFim, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorFim), 2)) 
			nHorFim := (24 - Int(nHorFim)) + TecConvHr(cAux)
		EndIf

		If nX < nTotal .AND. (nHrInPr := SubHoras(TecConvHr(aHorEsca[nX+1][1]), nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHrInPr), 2)) 
			nHrInPr := (24 - Int(nHrInPr)) + TecConvHr(cAux)
		EndIf
	Else
		If (nHorIni := SomaHoras(nHorIni, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorIni), 2)) 
			nHorIni := (24 - Int(nHorIni)) + TecConvHr(cAux)
		EndIf

		If (nHorFim := SomaHoras(nHorFim, nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHorFim), 2)) 
			nHorFim := (24 - Int(nHorFim)) + TecConvHr(cAux)
		EndIf

		If nX < nTotal .AND. (nHrInPr := SomaHoras(TecConvHr(aHorEsca[nX+1][1]), nDifHr)) >= 24
			cAux := "0." + (right(TecConvHr(nHrInPr), 2)) 
			nHrInPr := (24 - Int(nHrInPr)) + TecConvHr(cAux)
		EndIf
	EndIf

	If nHorIni > nHorFim .OR. ( nX < nTotal .AND. nHorFim > nHrInPr )
		nViraNew := nX
	EndIf
Next nX

lRet := nViraEsc == nViraNew

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViraDiaHR
@description Verifica se o turno utilizado é diferente da escala do posto
@author Luiz Gabriel
@since  26/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At190gTurno(cTurno)
Local lRet		:= .T.
Local cAliasQry := GetNextAlias()
Local cQry		:= ""

cQry := ""
cQry += " SELECT TDX.TDX_TURNO FROM " + RetSqlName("TDX") + " TDX "
cQry += " WHERE TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_FILIAL = '" +  xFilial('TDX') + "' AND "
cQry += " TDX.TDX_CODTDW = '" + oMdl190D:GetValue("TGYMASTER","TGY_ESCALA") + "' "
cQry += " AND TDX.TDX_TURNO = '" + cTurno + "' "

cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)
If (cAliasQry)->(EOF())
	lRet := .F.
EndIf
(cAliasQry)->(DbCloseArea())
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190GPOUI
@description Seta as variaveis estáticas para desvio de componentes 
			 de interface ao vir do planejamento operacional (Mesa POUI)
@author Jack Junior
@since  31/05/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190GPOUI(lBool, nOpcao, lAvulsa)
Default lMesaPOUI  := .F.
Default lAlocAvuls := .F.
Default nOpcaoPOUI := 2

lMesaPOUI  := lBool
lAlocAvuls := lAvulsa
nOpcaoPOUI := nOpcao
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190GVldDtRef

Valida se a data informada está dentro do periodo informado no posto

@author Breno Gomes
@since 26/02/2025
/*/
//------------------------------------------------------------------------------
Static Function At190GVldDtRef(oModel, xNewValue)
	Local lRet        := .T.
	Local cChaveTGY   := oMdl190d:GetValue("TGYMASTER", "TGY_FILIAL") + oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD")
	Local dDataPerInI := POSICIONE("TFF", 1, cChaveTGY, "TFF_PERINI") // Data de início do contrato
	Local dDataPerFim := POSICIONE("TFF", 1, cChaveTGY, "TFF_PERFIM") // Data de término do contrato 

	If xNewValue < dDataPerInI .Or. xNewValue > dDataPerFim
		Help( " ", 1, "At190GVldDtRef", Nil, i18N(STR0065, {DToC(dDataPerInI),DToC(dDataPerFim)}), 1 )//"Data referência se encontra fora do periodo do contrato " 	
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190GVldHr

Valida se a hora informada está dentro do horario inicial e final informado no posto

@author Breno Gomes
@since 26/02/2025
/*/
//------------------------------------------------------------------------------
Static Function At190GVldHr(oModel, xNewValue)

    Local lRet      := .T.
    Local cChaveTGY := oMdl190d:GetValue("TGYMASTER", "TGY_FILIAL") + oMdl190d:GetValue("TGYMASTER", "TGY_TFFCOD")
    Local cHoraIni  := POSICIONE("TFF", 1, cChaveTGY, "TFF_HORAIN")
    Local cHoraFim  := POSICIONE("TFF", 1, cChaveTGY, "TFF_HORAFI")
    Local lVdlHora  := !Empty(cHoraIni) .And. !Empty(cHoraFim) .And. !lAlocAvuls
    Local aAreaTFF  := TFF->(GetArea())
    If lVdlHora
        If cHoraIni <= cHoraFim
            If xNewValue < cHoraIni .Or. xNewValue > cHoraFim
                lRet := .F.
            EndIf
        Else
            If !( xNewValue >= cHoraIni .Or. xNewValue <= cHoraFim )
                lRet := .F.
            EndIf
        EndIf
        If !lRet
            Help(" ", 1, "At190GVldHr", Nil,i18N(STR0066, {cHoraIni, cHoraFim}), 1 )
        EndIf
    EndIf
    RestArea(aAreaTFF)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190GVldC

Valida se há conflito de data + horaini + horafim

@author Breno Gomes
@since 26/09/2025
/*/
//------------------------------------------------------------------------------
Static Function At190GVldC(aAgenda)
    Local nI, nJ
    Local dData1, dData2
    Local nHrIni1, nHrFim1
    Local nHrIni2, nHrFim2
    Local lRet := .T.

    // Primeiro ordena por data
	ASort(aAgenda,,, {|x, y| x[1] < y[1] })

	// Ordena por hora inicial
	ASort(aAgenda,,, {|x, y| Val(StrTran(x[2], ":", "")) < Val(StrTran(y[2], ":", "")) })

	For nI := 1 To Len(aAgenda)
		dData1   := aAgenda[nI, 1]
		nHrIni1  := Val(StrTran(aAgenda[nI, 2], ":", ""))
		nHrFim1  := Val(StrTran(aAgenda[nI, 3], ":", ""))

		// Comparar com as linhas seguintes
		For nJ := nI + 1 To Len(aAgenda)
			dData2   := aAgenda[nJ, 1]
			nHrIni2  := Val(StrTran(aAgenda[nJ, 2], ":", ""))
			nHrFim2  := Val(StrTran(aAgenda[nJ, 3], ":", ""))

			If dData1 == dData2
				// Regra de conflito: sobreposição ou horários iguais
				If (nHrIni1 < nHrFim2) .AND. (nHrFim1 > nHrIni2)
					lRet := .F.
					Help( " ", 1, "At190GVldC", Nil,i18N(STR0067, {DToC(dData1), aAgenda[nI,2], aAgenda[nI,3], aAgenda[nJ,2], aAgenda[nJ,3]}), 1 )//"Conflito encontrado na data #1 entre #2 - #3 e #4 - #5"	
					Return lRet
				EndIf
			Else
				Exit
			EndIf
		Next nJ
	Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AT190GRet()
Retorno da consulta especifica

@author Amilton Pereira
@since  17/04/2026
/*/
//------------------------------------------------------------------
Function AT190GRet()

Return cF3Ret

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190GF3Tur

@description Função responsavel por criar o browse para consulta padrão com query
@author Amilton Pereira
@since	22/04/2026
/*/
//------------------------------------------------------------------------------
Function AT190GF3Tur()

	Local cAlias      := GetNextAlias()
	Local aCampoAdv   := {}
	Local aColumns    := {}
	Local cTitulo     := STR0002
	Local cDescricao  := STR0012
	Local aSeek       := {}
	Local cRetorno    := ""
	Local nI          := 0
	Local cQuery      := ""
	Local cQry        := ""
	Local cCampo      := "CODIGO"

	cQuery := GetTurnTGY("TURNO",@cQry)
	cF3Ret  := FwFldGet("ALC_TURNO")

	aAdd(aCampoAdv, {"CODIGO", STR0068})
	aAdd(aCampoAdv, {"DESCRICAO", STR0069})
	aAdd(aCampoAdv, {"ORIGEM", STR0070})

	//Definição das colunas do browse
	For nI := 1 To Len(aCampoAdv)
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[nI]:SetData( &("{||" + aCampoAdv[nI][1] + "}") )
		aColumns[nI]:SetTitle(aCampoAdv[nI][2])
	Next nI 
		
	TecFrmBrw(cAlias, aColumns, cTitulo, cDescricao, cQry, aSeek, "", cCampo, "", @cRetorno)

	cF3Ret := cRetorno // Preenche o campo Valor = ALC_TURNO

Return .T.

/*/{Protheus.doc} At190GAvul
	Dispara o preenchimento automatico da linha de alocacao avulsa a partir da data.
	@type Static Function
	@author Anderson F. Gomes
	@since 15/05/2026
	@param oMdlALC, object, modelo da ALC
	@param dDataRef, date, data de referencia para preenchimento dos dados
	@return lRet, logical, indica se o preenchimento foi realizado com sucesso
	@example
	lRet := At190GAvul(oMdlALC, dDataRef)
/*/
Static Function At190GAvul(oMdlALC, dDataRef)
	Local lRet := .T.

	If IsBlind()
		lRet := At190GAloc(oMdlALC, dDataRef)
	Else
		MsgRun(STR0071, STR0072, {|| lRet := At190GAloc(oMdlALC, dDataRef)}) // "Preenchendo dados da alocação..." # "Alocação Avulsa"
	EndIf

Return lRet

/*/{Protheus.doc} At190GAloc
	Preenche automaticamente os campos de horario, intrajornada, turno, sequencia e tipo (trabalhado/nao trabalhado).
	@type Static Function
	@author Anderson F. Gomes
	@since 15/05/2026
	@param oMdlALC, object, modelo da ALC
	@param dDataRef, date, data de referencia para preenchimento dos dados
	@return lRet, logical, indica se o preenchimento foi realizado com sucesso
	@example
	lRet := At190GAloc(oMdlALC, dDataRef)
/*/
Static Function At190GAloc(oMdlALC, dDataRef)
	Local aPosto := {}
	Local oView  := FwViewActive()
	Local lRet   := .T.

	If At190GEscP(@aPosto, dDataRef, oMdlALC)
		oMdlALC:LoadValue("ALC_DATDIA", dDataRef)
		oMdlALC:LoadValue("ALC_SEMANA", TECCdow(Dow(dDataRef)))
		oMdlALC:LoadValue("ALC_ENTRADA", aPosto[1])
		oMdlALC:LoadValue("ALC_SAIDA", aPosto[2])
		oMdlALC:LoadValue("ALC_HEPLAN", aPosto[3])
		oMdlALC:LoadValue("ALC_INTERV", aPosto[4])
		If !Empty(aPosto[1]) .and. !Empty(aPosto[2])
			oMdlALC:LoadValue("ALC_TOTHRS", Left(ElapTime(aPosto[1] + ":00", aPosto[2] + ":00"), 5))
		EndIf
		oMdlALC:LoadValue("ALC_SEQ", aPosto[5])
		oMdlALC:LoadValue("ALC_TURNO", aPosto[6])
		oMdlALC:LoadValue("ALC_TIPO", aPosto[7])
	Else
		Help(, , "At190GAloc", , STR0073, 1, 0) // "Não foi possível localizar os horários da escala do posto."
	EndIf

	If !IsBlind() .and. ValType(oView) == "O" .and. !FwIsInCallStack("InitDados")
		oView:Refresh("DETAIL_ALC")
	EndIf

Return lRet

/*/{Protheus.doc} At190GEscP
	Retorna entrada, saida e intrajornada da escala do posto selecionado na TECA190D.
	@type Static Function
	@author Anderson F. Gomes
	@since 15/05/2026
	@param aRet, array, array de retorno com os dados da escala do posto (entrada, saida, horas planejadas e se tem intervalo)
	@param dDataRef, date, data de referencia para preenchimento dos dados
	@param oMdlALC, object, modelo da ALC
	@return lRet, logical, indica se a consulta foi realizada com sucesso
	@example
	lRet := At190GEscP(aRet, dDataRef)
/*/
Static Function At190GEscP(aRet, dDataRef, oMdlALC)
	Local cFilTFF    := ""
	Local cCodTFF    := ""
	Local cEscala    := ""
	Local cTurnoAtte := ""
	Local cTurnoTFF  := ""
	Local cSeqAtte   := ""
	Local cSeqTFF    := PadL("1", FWSX3Util():GetFieldStruct("TGY_SEQ")[3], "0")
	Local cAliasQry  := ""
	Local cQry       := ""
	Local cHrIni     := ""
	Local cHrFim     := ""
	Local cIntrajor  := "N"
	Local cTipo      := "N"
	Local dPerIni    := CToD("")
	Local dPdIniAtte := CToD("")
	Local nOrder     := 1
	Local oExec      := Nil
	Local lRet       := .F.
	Local lMultFil   := SuperGetMV("MV_GSMSFIL",,.F.)

	cFilTFF := oMdl190D:GetValue("TGYMASTER", "TGY_FILIAL")
	cCodTFF := oMdl190D:GetValue("TGYMASTER", "TGY_TFFCOD")
	cEscala := oMdl190D:GetValue("TGYMASTER", "TGY_ESCALA")
	cTurnoTFF := Posicione("TFF", 1, cFilTFF + cCodTFF, "TFF_TURNO")
	cCodTec := oMdl190D:GetValue("AA1MASTER", "AA1_CODTEC")
	At190GTGYC(cCodtec, dDataRef, @cTurnoAtte, @cSeqAtte, @dPdIniAtte)
	If Empty(cTurnoAtte)
		cTurnoAtte := cTurnoTFF
	EndIf
	If Empty(cSeqAtte)
		cSeqAtte := PadL("1", FWSX3Util():GetFieldStruct("TGY_SEQ")[3], "0")
	EndIf

	dPerIni := Posicione("TFF", 1, cFilTFF + cCodTFF, "TFF_PERINI")
	If Empty(dPdIniAtte)
		dPdIniAtte := dPerIni
	EndIf

	cSeqTFF := GSAGetSeq(cSeqTFF, cTurnoTFF, dDataRef, dPerIni)
	If !Empty(cEscala)
		cQry := "SELECT TGW.TGW_COD,
		cQry +=        "TGW.TGW_HORINI, "
		cQry +=        "TGW.TGW_HORFIM, "
		cQry +=        "TGW.TGW_STATUS "
		cQry += "FROM   ? TGW "
		cQry +=        "INNER JOIN ? TDX "
		If lMultFil
			cQry +=            "ON ? "
		Else
			cQry +=            "ON TDX.TDX_FILIAL = ? "
		EndIf
		cQry +=                   "AND TDX.TDX_COD = TGW.TGW_EFETDX "
		cQry +=                   "AND TDX.D_E_L_E_T_ = ' ' "
		cQry += "WHERE TDX.TDX_CODTDW = ? "
		cQry +=       "AND TDX.TDX_TURNO = ? "
		cQry +=       "AND TDX.TDX_SEQTUR = ? "
		cQry +=       "AND TGW.TGW_DIASEM = ? "
		cQry +=       "AND TGW.D_E_L_E_T_ = ' ' "
		cQry += "ORDER BY TGW.TGW_COD "

		oExec := FwExecStatement():New(cQry)
		oExec:SetUnsafe(nOrder++, RetSqlName("TGW"))
		oExec:SetUnsafe(nOrder++, RetSqlName("TDX"))
		If lMultFil
			oExec:SetUnsafe(nOrder++, FWJoinFilial("TDX" , "TGW" , "TDX", "TGW", .T.))
		Else
			oExec:SetString(nOrder++, FwxFilial("TDX"))
		EndIf
		oExec:SetString(nOrder++, cEscala)
		oExec:SetString(nOrder++, cTurnoTFF)
		oExec:SetString(nOrder++, cSeqTFF)
		oExec:SetString(nOrder++, cValToChar(DoW(dDataRef)))

		cAliasQry := oExec:OpenAlias()
		While (cAliasQry)->(!EoF())
			If cIntrajor == "N"
				If !Empty(posicione("TXH", 2, FwxFilial("TXH") + (cAliasQry)->TGW_COD, "TXH_CODIGO"))
					cIntrajor := "S"
				Else
					cIntrajor := "N"
				EndIf
			EndIf
			If Empty(cHrIni)
				cHrIni := TecConvHr((cAliasQry)->TGW_HORINI)
			EndIf
			cHrFim := TecConvHr((cAliasQry)->TGW_HORFIM)
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		oExec:Destroy()
		FwFreeObj(oExec)
	EndIf

	cSeqAtte := GSAGetSeq(cSeqAtte, cTurnoAtte, dDataRef, dPdIniAtte)
	If !Empty(cTurnoAtte) .And. !Empty(cSeqAtte)
		cQry := "SELECT SPJ.PJ_TPDIA "
		cQry += "FROM ? SPJ "
		cQry += "WHERE SPJ.PJ_FILIAL = ? "
		cQry +=       "AND SPJ.PJ_TURNO = ? "
		cQry +=       "AND SPJ.PJ_SEMANA = ? "
		cQry +=       "AND SPJ.PJ_DIA = ? "
		cQry +=       "AND SPJ.D_E_L_E_T_ = ' ' "
		nOrder := 1
		oExec := FwExecStatement():New(cQry)
		oExec:SetUnsafe(nOrder++, RetSqlName("SPJ"))
		oExec:SetString(nOrder++, FwxFilial("SPJ"))
		oExec:SetString(nOrder++, cTurnoAtte)
		oExec:SetString(nOrder++, cSeqAtte)
		oExec:SetString(nOrder++, cValToChar(DoW(dDataRef)))

		cAliasQry := oExec:OpenAlias()
		If (cAliasQry)->(!EoF())
			If (cAliasQry)->PJ_TPDIA <> "S"
				cTipo := "N"
			Else
				cTipo := "S"
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
		oExec:Destroy()
		FwFreeObj(oExec)
	EndIf

	aRet := {cHrIni, cHrFim, "1", cIntrajor, cSeqAtte, cTurnoAtte, cTipo}
	lRet := .T.

Return lRet

/*/{Protheus.doc} At190GTGYC
	Retorna o turno e sequencia do dia para o tecnico, caso haja alocacao.
	@type Static Function
	@author Anderson F. Gomes
	@since 18/05/2026
	@param cCodtec, string, codigo do tecnico
	@param dDtRef, date, data de referencia para pesquisa
	@param cTurno, string, turno para pesquisa
	@param cSeq, string, sequencia para pesquisa
	@param dPerIni, date, data de inicio do periodo
	@return nil, nil, nulo
	@example
	At190GTGYC(cCodtec, dDtRef, cTurno, cSeq, dPerIni)
/*/
Static Function At190GTGYC(cCodtec, dDtRef, cTurno, cSeq, dPerIni)
	Local cQry      := ""
	Local cAliasQry := ""
	Local oExec     := nil
	Local nOrder    := 1

	cQry := "SELECT TGY.TGY_TURNO, "
	cQry +=        "TGY.TGY_ESCALA, "
	cQry +=        "TGY.TGY_SEQ, "
	cQry +=        "TGY.TGY_DTINI "
	cQry += "FROM   ? TGY "
	cQry += "WHERE  TGY.TGY_FILIAL = ? "
	cQry +=        "AND TGY.TGY_ATEND = ? "
	cQry +=        "AND ? >= TGY.TGY_DTINI "
	cQry +=        "AND ? <= TGY.TGY_DTFIM "
	cQry +=        "AND TGY.D_E_L_E_T_ = ' ' "
	cQry += "ORDER  BY TGY.TGY_ULTALO DESC "

	oExec := FwExecStatement():New(cQry)
	oExec:SetUnsafe(nOrder++, RetSqlName("TGY"))
	oExec:SetString(nOrder++, FwxFilial("TGY"))
	oExec:SetString(nOrder++, cCodtec)
	oExec:SetString(nOrder++, dtos(dDtRef))
	oExec:SetString(nOrder++, dtos(dDtRef))

	cAliasQry := oExec:OpenAlias()
	If (cAliasQry)->(!EoF())
		cTurno := (cAliasQry)->TGY_TURNO
		cSeq := (cAliasQry)->TGY_SEQ
		dPerIni := StoD((cAliasQry)->TGY_DTINI)
	EndIf

	(cAliasQry)->(DbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)
Return nil

/*/{Protheus.doc} HrTotTurno
	Retorna a quantidade de horas totais do turno e as horas de entrada e saida para cada periodo da escala do posto.
	@type Static Function
	@author Anderson F. Gomes
	@since 15/06/2026
	@param cTurno, character, codigo do turno
	@param cSequencia, character, codigo da sequencia
	@param cDiaSem, character, codigo do dia da semana
	@param aHorEsca, array, vetor para armazenar as horas da escala do posto
	@return nRet, numeric, quantidade de horas totais do turno
/*/
Static Function HrTotTurno(cTurno, cSequencia, cDiaSem, aHorEsca)
	Local nRet	    := 0
	Local nOrder    := 1
	Local cQry	    := ""
	Local cAliasQry := ""
	Local oExec     := nil

	cQry := "SELECT SPJ.PJ_ENTRA1, "
	cQry +=        "SPJ.PJ_SAIDA1, "
	cQry +=        "SPJ.PJ_ENTRA2, "
	cQry +=        "SPJ.PJ_SAIDA2, "
	cQry +=        "SPJ.PJ_ENTRA3, "
	cQry +=        "SPJ.PJ_SAIDA3, "
	cQry +=        "SPJ.PJ_ENTRA4, "
	cQry +=        "SPJ.PJ_SAIDA4 "
	cQry += "FROM ? SPJ "
	cQry += "WHERE SPJ.PJ_FILIAL = ? "
	cQry +=       "AND SPJ.PJ_TURNO = ? "
	cQry +=       "AND SPJ.PJ_SEMANA = ? "
	cQry +=       "AND SPJ.PJ_DIA = ? "
	cQry +=       "AND SPJ.D_E_L_E_T_ = ' ' "

	oExec := FwExecStatement():New(cQry)
	oExec:SetUnsafe(nOrder++, RetSqlName("SPJ"))
	oExec:SetString(nOrder++, FwxFilial("SPJ"))
	oExec:SetString(nOrder++, cTurno)
	oExec:SetString(nOrder++, cSequencia)
	oExec:SetString(nOrder++, cDiaSem)

	cAliasQry := oExec:OpenAlias()
	If (cAliasQry)->(!EoF())
		If !Empty((cAliasQry)->PJ_ENTRA1) .And. !Empty((cAliasQry)->PJ_SAIDA1)
			AAdd( aHorEsca, {TecConvHr((cAliasQry)->PJ_ENTRA1), TecConvHr((cAliasQry)->PJ_SAIDA1)})
			nRet := ElapTime( TecConvHr((cAliasQry)->PJ_ENTRA1)+":00", TecConvHr((cAliasQry)->PJ_SAIDA1)+":00")
		EndIf
		If !Empty((cAliasQry)->PJ_ENTRA2) .And. !Empty((cAliasQry)->PJ_SAIDA2)
			AAdd( aHorEsca, {TecConvHr((cAliasQry)->PJ_ENTRA2), TecConvHr((cAliasQry)->PJ_SAIDA2)})
			nRet := ElapTime( TecConvHr((cAliasQry)->PJ_ENTRA1)+":00", TecConvHr((cAliasQry)->PJ_SAIDA2)+":00")
		EndIf
		If !Empty((cAliasQry)->PJ_ENTRA3) .And. !Empty((cAliasQry)->PJ_SAIDA3)
			AAdd( aHorEsca, {TecConvHr((cAliasQry)->PJ_ENTRA3), TecConvHr((cAliasQry)->PJ_SAIDA3)})
			nRet := ElapTime( TecConvHr((cAliasQry)->PJ_ENTRA1)+":00", TecConvHr((cAliasQry)->PJ_SAIDA3)+":00")
		EndIf
		If !Empty((cAliasQry)->PJ_ENTRA4) .And. !Empty((cAliasQry)->PJ_SAIDA4)
			AAdd( aHorEsca, {TecConvHr((cAliasQry)->PJ_ENTRA4), TecConvHr((cAliasQry)->PJ_SAIDA4)})
			nRet := ElapTime( TecConvHr((cAliasQry)->PJ_ENTRA1)+":00", TecConvHr((cAliasQry)->PJ_SAIDA4)+":00")
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)
Return nRet
