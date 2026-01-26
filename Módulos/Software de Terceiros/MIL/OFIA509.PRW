#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'OFIA509.ch'

static oModel01
static oModel02
static oArrHelper


/*/{Protheus.doc} OFIA509
	Tela para transferências internas DMS

	@author Vinicius Gati
	@since  05/10/2024
/*/
function OFIA509(cNUMORC,cNUMOS)

	Default cNUMORC := ""
	Default cNUMOS  := ""

	Private cVS1NUMORC := cNUMORC
	Private oConfig := OFJDConfig():New()
	Private cVSJNUMOS  := cNUMOS

	FWExecView(STR0001, "OFIA509", MODEL_OPERATION_UPDATE) //"Confirmação de transferências automáticas"
return .t.

static function ModelDef()
	Local oModel
	Local oStr1
	Local oStr2

	if oModel01 == nil
		oArrHelper := DMS_ArrayHelper():New()
		oModel01 := GetModel01()
		oModel02 := GetModel02()
	endif

	oStr1 := oModel01:GetModel()
	oStr2 := oModel02:GetModel()

	oModel := MPFormModel():New('OFIA509',,,{ |oModel| OA50900014_Confirmar(oModel) })
	oModel:SetDescription(STR0002) //"Sugestão de transferências automáticas"
	
	oModel:AddFields("BASE",,oStr1,,,{|| Load01Dados() })
	oModel:GetModel("BASE"):SetDescription(STR0003) //"Movimentações automáticas"

	oModel:AddGrid("GRID_ARMAZENS","BASE", oStr2,,,,,{|| Load02Dados() })
	oModel:GetModel("GRID_ARMAZENS"):SetDescription(STR0004) //"Movimentações sugeridas para peças indisponíveis"
	oModel:GetModel("GRID_ARMAZENS"):SetOptional(.F.)
	oModel:GetModel("GRID_ARMAZENS"):SetUniqueLine({"CODIGO_PECA","CODIGO_ARMAZEM_VENDA","CODIGO_ARMAZEM_CEDENTE"})
	oModel:SetPrimaryKey({})

	oModel:InstallEvent("OFIA509EVDEF", /*cOwner*/, OFIA509EVDEF():New() )

return oModel


static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1 := oModel01:GetView()
	Local oStr2 := oModel02:GetView()


	If Empty(cVSJNUMOS)
		oStr1:RemoveField("NUMERO_OS")
	Else
		oStr1:RemoveField("NUMERO_ORCAMENTO")
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('BASE', oStr1, 'BASE')
	oView:AddGrid('GRID_ARMAZENS', oStr2, 'GRID_ARMAZENS')

	oView:CreateHorizontalBox('BOX_TOPO' , 20)
	oView:CreateHorizontalBox('BOX_BAIXO', 80)

	oView:SetOwnerView("BASE", "BOX_TOPO")
	oView:SetOwnerView("GRID_ARMAZENS", "BOX_BAIXO")

	oView:EnableTitleView('BASE', STR0005) // dados base
	oView:EnableTitleView('GRID_ARMAZENS', STR0006) //"Sugestões de transferências"

	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 
	oView:SetModified(.t.)
	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)
	oView:SetCloseOnOk({||.T.})
	oView:ApplyModifyToViewByModel()
return oView

static function getModel01()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'   , STR0007 },; //"Orçamento"
		{'cIdField'  , "NUMERO_ORCAMENTO" },;
		{'nTamanho'  , GetSX3Cache("B1_COD","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0008 } ; //"Número do orçamento que será alterado"
	})
	oMd:AddField({;
		{'cTitulo'   , "Ordem Serviço" },; //"Orçamento"
		{'cIdField'  , "NUMERO_OS" },;
		{'nTamanho'  , GetSX3Cache("B1_COD","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0008 } ; //"Número do orçamento que será alterado"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0009 },; //"Data e Hora"
		{'cIdField'  , "DATA_CRIACAO" },;
		{'nTamanho'  , 16 },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0010 } ;//"Data e hora de criação do orçamento"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0011 },; //"Data de Vencimento"
		{'cIdField'  , "DATA_VENCIMENTO" },;
		{'nTamanho'  , GetSX3Cache("VS1_DATVAL","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0012 } ;//"Data de vencimento do orçamento"
	})
return oMd

static function Load01Dados()

	If Empty(cVSJNUMOS)

		DBSelectArea("VS1")
		DBSetOrder(1)
		MsSeek(xFilial("VS1") + cVS1NUMORC)

		cCpo1 := cVS1NUMORC
		cCpo2 := cVSJNUMOS
		cCpo3 := OA50900024_DESC_DATAHORA(VS1->VS1_DATORC, VS1->VS1_HORORC)
		cCpo4 := VS1->VS1_DATVAL

	Else

		DBSelectArea("VO1")
		DBSetOrder(1)
		MsSeek(xFilial("VO1") + cVSJNUMOS)

		cCpo1 := cVS1NUMORC
		cCpo2 := cVSJNUMOS
		cCpo3 := OA50900024_DESC_DATAHORA(VO1->VO1_DATABE,VO1->VO1_HORABE)
		cCpo4 := VSJ->VSJ_DATREQ

	EndIf

return {;
	{;
		cCpo1,;
		cCpo2,;
		cCpo3,;
		cCpo4 ;
	}, 0;
}

static function getModel02()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'   , STR0013 },; //"Aceitar?"
		{'cIdField'  , "CHK_ACEITO" },;
		{'cTipo'     , "Check" },;
		{'nTamanho'  , 1   },;
		{'lCanChange', .T. },;
		{'cTooltip'  , STR0014 } ;//"Indica se será aceita a movimentação ou não"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0015 },; //"Código da Peça"
		{'cIdField'  , "CODIGO_PECA" },;
		{'nTamanho'  , GetSX3Cache("B1_COD","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0016 } ;//"Código da peça que será movimentada"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0017 },; //"Descrição da peça"
		{'cIdField'  , "DESCRICAO_PECA" },;
		{'nTamanho'  , GetSX3Cache("B1_DESC","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0018 } ;//"Descrição da peça que será movimentada"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0019 },; //Origem
		{'cIdField'  , "CODIGO_ARMAZEM_CEDENTE" },;
		{'nTamanho'  , GetSX3Cache("VS3_QTDITE","X3_TAMANHO") },;
		{'nDecimal'  , GetSX3Cache("VS3_QTDITE","X3_DECIMAL") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0020 } ; //"Armazém origem da quantidade necessária"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0021 },; //"Armazém Destino"
		{'cIdField'  , "CODIGO_ARMAZEM_VENDA" },;
		{'nTamanho'  , GetSX3Cache("NNR_CODIGO","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0022 } ;//"Código do armazém que receberá a quantidade"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0023 },; //"Quantidade Sugerida"
		{'cTipo'     , "N" },;
		{'cIdField'  , "QTD_TRANSFERIR" },;
		{'nTamanho'  , GetSX3Cache("VS3_QTDITE","X3_TAMANHO") },;
		{'nDecimal'  , GetSX3Cache("VS3_QTDITE","X3_DECIMAL") },;
		{'lCanChange', .t. },;
		{'cPicture'  , "@E "+Replicate("9",GetSX3Cache("VS3_QTDITE","X3_TAMANHO")) + "." + Replicate("9", GetSX3Cache("VS3_QTDITE","X3_DECIMAL")) },;
		{'cTooltip'  , STR0024 } ; //"Quantidade que será movimentada"
	})
	oMd:AddField({;
		{'cTitulo'   , "" },;
		{'cIdField'  , "ESPACO" },;
		{'nTamanho'  , 500 },;
		{'lObrigat'  , .F. },;
		{'lCanChange', .F. },;
		{'cTooltip'  , "" } ;
	})
return oMd

static function Load02Dados()
	Local aData  := {}
	Local nX     := 1
	Local nY     := 1
	Local aArms  := oConfig:ArmazensParaTransferencia()

	Local aArea      := GetArea()
	Local aAreaB2    := SB2->(GetArea())

	Local aItens     := {}

	Pergunte("MTA260",.F.) // pega config de saldo de terceiros para o MV_PAR03

	dbSelectArea("SB2")
	dbSetOrder(1)

	OA50900045_LevantaItens(cVSJNUMOS,cVS1NUMORC,@aItens)

	for nX := 1 to len(aItens)
		jItem := aItens[nX]
		jItem := OA50900034_Processa(jItem)

		DBSelectArea("SB1")
		DBSetOrder(7)
		MsSeek(xFilial("SB1") + jItem["GRUITE"] + jItem["CODITE"])

		if empty(jItem["LOCAL"])
			loop
		endif
	
		for nY := 1 to len(aArms)
			if aArms[nY]["CODIGO_ARMAZEM"] == jItem["LOCAL"]
				loop // mesmo armazem do destino. pula
			endif

			if jItem["FALTANTE"] == 0
				loop // item nao precisa de transferencia
			endif

			DBSelectArea("SB2")
			DBSetOrder(1)
			if SB2->(dbSeek(xFiliaL("SB2") + SB1->B1_COD + aArms[nY]["CODIGO_ARMAZEM"]))
				nSaldo := SaldoMov(,,, If(MV_PAR03 == 1, .F., .T.),,,,)

				if nSaldo > 0
					if nSaldo > jItem["FALTANTE"]
						aadd(aData, { nX, {;
							.T.,;
							SB1->B1_COD,;
							SB1->B1_DESC,;
							SB2->B2_LOCAL,;
							jItem["LOCAL"],;
							jItem["FALTANTE"],;
							"";
						}})
						jItem["FALTANTE"] := 0
					else // atendimento parcial do saldo faltante
						jItem["FALTANTE"] := jItem["FALTANTE"] - nSaldo
						aadd(aData, { nX, {;
							.T.,;
							SB1->B1_COD,;
							SB1->B1_DESC,;
							SB2->B2_LOCAL,;
							jItem["LOCAL"],;
							nSaldo,;
							"";
						}})
					endif
				else
					aadd(aData, { nX, {;
						.F.,;
						SB1->B1_COD,;
						SB1->B1_DESC,;
						SB2->B2_LOCAL,;
						jItem["LOCAL"],;
						0,;
						"";
					}})
				endif
			endif
		next
	next

	RestArea( aAreaB2 )
	RestArea( aArea   )

	if len(aData) == 0
		FMX_HELP("OA509ER01", STR0031, STR0032) //"Peça indisponível" "Nenhuma armazém de venda possui saldo"


	endif
return aData

function OA50900014_Confirmar(oModel)
	local nX         := 1
	local oTransf    := DMS_Estoque():New()
	local oMdlGrid   := oModel:GetModel("GRID_ARMAZENS")
	local aResumo    := { STR0030 } // "Transferências efetuadas com sucesso"
	local aErros     := { STR0028 } // "Não foi possível realizar as transferências:"

	begin transaction
		for nX := 1 to oMdlGrid:Length()
			oMdlGrid:GoLine(nX)
			if ! oMdlGrid:IsDeleted()
				if oMdlGrid:GetValue("CHK_ACEITO") == .T.

					if oTransf:Transfere(;
							oMdlGrid:GetValue("CODIGO_PECA"),;
							oMdlGrid:GetValue("CODIGO_ARMAZEM_CEDENTE"),;
							oMdlGrid:GetValue("CODIGO_ARMAZEM_VENDA"),;
							oMdlGrid:GetValue("QTD_TRANSFERIR");
						)
						aadd(aResumo, STR0025 /*origem*/+ oMdlGrid:GetValue("CODIGO_ARMAZEM_CEDENTE") + STR0026 /*destino*/ + " " + oMdlGrid:GetValue("CODIGO_ARMAZEM_VENDA") + " " +STR0027/*" Quantidade: "*/ + " " + cValtoChar(oMdlGrid:GetValue("QTD_TRANSFERIR")))
					else
						aadd(aErros, STR0025 /*origem*/+ oMdlGrid:GetValue("CODIGO_ARMAZEM_CEDENTE") + STR0026 /*destino*/ + " " + oMdlGrid:GetValue("CODIGO_ARMAZEM_VENDA") + " " +STR0027/*" Quantidade: "*/ + " " + cValtoChar(oMdlGrid:GetValue("QTD_TRANSFERIR")))
					endif

				endif
			endif
		next
	end transaction

	if len(aResumo) > 1
		MsgInfo(oArrHelper:Join(aResumo, chr(13) + chr(10)), STR0029) //"Resumo"
	endif
	if len(aErros) > 1
		MsgInfo(oArrHelper:Join(aErros, chr(13) + chr(10)), STR0026)//"Erros"
	endif
return .t.

/*/{Protheus.doc} OA50900024_DESC_DATAHORA
	Retorna data e hora da abertura do orçamento

	@type method
	@author Vinicius Gati
	@since 16/12/2024
/*/
Function OA50900024_DESC_DATAHORA(dData, nHora)
	local cHora := iif(nHora <= 999, "0", "") + cValToChar(nHora)

	cHora := Left(cHora, 2) + ":" + Right(cHora,2)

	if ! Empty(dData) .and. ! Empty(nHora)
		return dtoc(dData) + " " + cHora
	endif
Return " /  /   00:00"

/*/{Protheus.doc} OA50900034_Processa
	Processa o item do orçamento para que tenhamos a informação de quantidade faltante

	@type method
	@author Vinicius Gati
	@since 16/12/2024
/*/
Function OA50900034_Processa(jItem)
	local nFaltante := 0
	local nSaldo    := 0
	Local lVSJQTDTRA:= VSJ->(FieldPos("VSJ_QTDTRA")) > 0

	jItem["FALTANTE"] := 0

	nFaltante := jItem["QTDITE"]
	nFaltante -= jItem["QTDRES"]
	nFaltante -= jItem["QTDAGU"]

	If lVSJQTDTRA
		nFaltante -= jItem["QTDTRA"]
	EndIf

	if empty(jItem["LOCAL"])
		return jItem
	endif

	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1") + jItem["GRUITE"] + jItem["CODITE"])
	
	Pergunte("MTA260", .F.) // pega config de saldo de terceiros para o MV_PAR03
	DBSelectArea("SB2")
	DBSetOrder(1)
	if SB2->(dbSeek(xFiliaL("SB2") + SB1->B1_COD + jItem["LOCAL"]))
		nSaldo := SaldoMov(,,, If(MV_PAR03 == 1, .F., .T.),,,,)
	endif

	if nFaltante > nSaldo
		jItem["FALTANTE"] := nFaltante - nSaldo
	endif
return jItem


/*/{Protheus.doc} OA50900034_Processa
	Processa o item do orçamento para que tenhamos a informação de quantidade faltante

	@type method
	@author Vinicius Gati
	@since 16/12/2024
/*/
Function OA50900045_LevantaItens(cVSJNUMOS,cVS1NUMORC,aItens)

	Local lVSJQTDTRA:= VSJ->(FieldPos("VSJ_QTDTRA")) > 0
	Local cQuery := ""
	Local oSql   := DMS_SqlHelper():New()

	Default cVSJNUMOS  := ""
	Default cVS1NUMORC := ""

	If Empty(cVSJNUMOS)

		cQuery += " SELECT VS3_CODITE AS CODITE, VS3_GRUITE AS GRUITE, VS3_QTDITE AS QTDITE, VS3_QTDRES AS QTDRES, VS3_QTDAGU AS QTDAGU, VS3_LOCAL AS LOCAL, VS3_QTDTRA AS QTDTRA "
		cQuery += "   FROM " + RetSqlName("VS3") + " VS3 "
		cQuery += "  WHERE VS3_FILIAL = '"+xFilial('VS3')+"' "
		cQuery += "    AND VS3_NUMORC = '"+ cVS1NUMORC +"' "
		cQuery += "    AND VS3_MOTPED = ' ' "
		cQuery += "    AND VS3.D_E_L_E_T_ = ' ' "

	Else

		cQuery += " SELECT VSJ_CODITE AS CODITE, VSJ_GRUITE AS GRUITE, VSJ_QTDITE AS QTDITE, VSJ_QTDRES AS QTDRES, VSJ_QTDAGU AS QTDAGU, VSJ_LOCAL AS LOCAL "

		If lVSJQTDTRA
			cQuery  += " , VSJ_QTDTRA AS QTDTRA "
		else
			cQuery  += " , 0 AS QTDTRA "
		EndIf

		cQuery += "   FROM " + RetSqlName("VSJ") + " VSJ "
		cQuery += "  WHERE VSJ_FILIAL = '"+xFilial('VSJ')+"' "
		cQuery += "    AND VSJ_NUMOSV = '"+ cVSJNUMOS +"' "
		cQuery += "    AND VSJ_MOTPED = ' ' "
		cQuery += "    AND VSJ.D_E_L_E_T_ = ' ' "

	EndIf

	aItens := oSql:GetSelectJson({"CODITE", "GRUITE", "QTDITE", "QTDRES", "QTDAGU" , "LOCAL" , "QTDTRA" }, cQuery)

Return
