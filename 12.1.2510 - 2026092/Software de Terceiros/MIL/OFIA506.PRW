#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'OFIA506.ch'

static oModel01
static oModel02
static oArrHelper


/*/{Protheus.doc} OFIA506
	Tela para transferências internas DMS

	@author Vinicius Gati
	@since  05/10/2024
/*/
function OFIA506(cB1COD, nQtdNec, cNNRCodDest)
	Private oConfig := OFJDConfig():New()
	Private cPB1COD := cB1COD
	Private nPQtdNec := nQtdNec
	Private cPNNRCodDest := cNNRCodDest
	Private oOFJDConfig := OFJDConfig():New()

	if nPQtdNec < 0
		nPQtdNec := 0
	endif

	if len(Load02Dados()) == 0
		FMX_HELP("OA506ER01", STR0019, STR0020) //"Peça indisponível" "Nenhuma armazém de venda possui saldo"
		return .f.
	endif

	FWExecView(STR0001, "OFIA506", MODEL_OPERATION_UPDATE) //"Transferências internas DMS"
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

	oModel := MPFormModel():New('OFIA506',,,{ |oModel| OA50600014_Confirmar(oModel) })
	oModel:SetDescription(STR0001) //Transferências internas
	
	oModel:AddFields("BASE",,oStr1,,,{|| Load01Dados() })
	oModel:GetModel("BASE"):SetDescription(STR0002) // Detalhes da requisição

	oModel:AddGrid("GRID_ARMAZENS","BASE", oStr2,,,,,{|| Load02Dados() })
	oModel:GetModel("GRID_ARMAZENS"):SetDescription(STR0003) //"Armazéns de venda disponíveis"
	oModel:GetModel("GRID_ARMAZENS"):SetOptional(.F.)
	oModel:GetModel("GRID_ARMAZENS"):SetUniqueLine({"CODIGO_ARMAZEM"})

	oModel:SetPrimaryKey({})
return oModel


static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1 := oModel01:GetView()
	Local oStr2 := oModel02:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('BASE', oStr1, 'BASE')
	oView:AddGrid('GRID_ARMAZENS', oStr2, 'GRID_ARMAZENS')

	oView:CreateHorizontalBox('BOX_TOPO' , 20)
	oView:CreateHorizontalBox('BOX_BAIXO', 80)

	oView:SetOwnerView("BASE", "BOX_TOPO")
	oView:SetOwnerView("GRID_ARMAZENS", "BOX_BAIXO")

	oView:EnableTitleView('BASE', "Dados base")
	oView:EnableTitleView('GRID_ARMAZENS', STR0003) //"Armazéns disponíveis"

	oView:SetCloseOnOk({||.T.})
return oView

static function getModel01()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'   , STR0004 },; //"Código Peça"
		{'cIdField'  , "CODIGO_PECA" },;
		{'nTamanho'  , GetSX3Cache("B1_COD","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0005 } ; //"Código da peça que necessita transferência"
	})
	oMd:AddField({;
		{'cTitulo'   , "Descrição da Peça" },; //"Descrição da Peça"
		{'cIdField'  , "DESCRICAO_PECA" },;
		{'nTamanho'  , GetSX3Cache("B1_COD","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0006 } ;//"Descrição da peça que necessita transferência"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0007 },; //"Quantidade necessária"
		{'cIdField' , "QUANTIDADE_NECESSARIA" },;
		{'cTipo'    , "N" },;
		{'nTamanho' , GetSX3Cache("VS3_QTDITE","X3_TAMANHO") },;
		{'nDecimal' , GetSX3Cache("VS3_QTDITE","X3_DECIMAL") },;
		{'lCanChange', .f. },;
		{'cTooltip' , STR0008 } ; //"Quantidade de peças necessárias"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0009 },; //"Armazém Destino"
		{'cIdField'  , "ARMAZEM_DESTINO" },;
		{'nTamanho'  , GetSX3Cache("NNR_CODIGO","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0010 } ; //"Código da peça que necessita transferência"
	})
return oMd

static function Load01Dados()
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(xFilial("SB1") + cPB1COD)
return {;
	{;
		cPB1COD,;
		SB1->B1_DESC,;
		nPQtdNec,;
		cPNNRCodDest ;
	}, 0;
}

static function getModel02()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0011 },; //"Código Armazém"
		{'cIdField' , "CODIGO_ARMAZEM" },;
		{'nTamanho' , GetSX3Cache("NNR_CODIGO","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip' , STR0012 } ;//"Código da peça que necessita transferência"
	})
	oMd:AddField({;
		{'cTitulo'   , STR0013 },; //"Local"
		{'cTipo'     , 'N' },;
		{'cIdField'  , "DESCRICAO_LOCAL" },;
		{'nTamanho'  , GetSX3Cache("B1_DESC","X3_TAMANHO") },;
		{'lCanChange', .f. },;
		{'cTooltip'  , STR0014 } ; //"Descrição da peça que necessita transferência"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0015 },; //Quantidade
		{'cTipo'    , 'N' },;
		{'cIdField' , "DISPONIVEL" },;
		{'cTipo'	, 'N'},;
		{'nTamanho' , GetSX3Cache("VS3_QTDITE","X3_TAMANHO") },;
		{'nDecimal' , GetSX3Cache("VS3_QTDITE","X3_DECIMAL") },;
		{'lCanChange', .f. },;
		{'cPicture' , '@E 999,999,999.99' } ,;
		{'cTooltip' , STR0016 } ; //"Quantidade que será transferida"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0017 },; //"Quantidade à Transferir"
		{'cIdField' , "QTD_TRANSFERIR" },;
		{'cTipo'    , 'N' },;
		{'nTamanho' , GetSX3Cache("VS3_QTDITE","X3_TAMANHO") },;
		{'nDecimal' , GetSX3Cache("VS3_QTDITE","X3_DECIMAL") },;
		{'cPicture' , '@E 999,999,999.99' } ,;
		{'bValid'   , {|| .t. } } ,;
		{'cTooltip' , STR0018 } ;//"Quantidade de peças necessárias"
	})
return oMd

static function Load02Dados()
	Local aData := {}
	Local nX := 1
	Local aArms := oConfig:ArmazensDeVenda()

	Pergunte("MTA260",.F.) // pega config de saldo de terceiros para o MV_PAR03

	dbSelectArea("SB2")
	dbSetOrder(1)

	for nX := 1 to len(aArms)
		if aArms[nX]["CODIGO_ARMAZEM"] == cPNNRCodDest
			loop // sai fora do que precisa de saldo
		endif

		if ! SB2->(dbSeek(xFiliaL("SB2") + SB1->B1_COD + aArms[nX]["CODIGO_ARMAZEM"]))
			loop
		endif

		aadd(aData, { nX, {;
			aArms[nX]["CODIGO_ARMAZEM"],;
			aArms[nX]["DESCRICAO"],;
			SaldoMov(,,, If(MV_PAR03 == 1, .F., .T.),,,,),;
			0 ;
		}})
	next
return aData

function OA50600014_Confirmar(oModel)
	Local nX := 1
	Local oTransf := DMS_Estoque():New()
	Local oModelBase := oModel:GetModel("BASE")
	Local oMdlGrid := oModel:GetModel("GRID_ARMAZENS")
	local nSomaTrf := 0
	Local aResumo := {}
	local aErros := {}

	for nX := 1 to oMdlGrid:Length()
		oMdlGrid:GoLine(nX)
		if ! oMdlGrid:IsDeleted()
			nSomaTrf += oMdlGrid:GetValue("QTD_TRANSFERIR")
		endif
	next

	if nSomaTrf < oModelBase:GetValue("QUANTIDADE_NECESSARIA") .and. oModelBase:GetValue("QUANTIDADE_NECESSARIA") > 0
		if ! MsgYesNo(STR0027, STR0028) //"A quantidade à transferir é menor que o necessário, deseja continuar?" atencao
			return
		endif
	endif

	nSomaTrf := 0
	for nX := 1 to oMdlGrid:Length()
		oMdlGrid:GoLine(nX)
		if ! oMdlGrid:IsDeleted()
			if oMdlGrid:GetValue("QTD_TRANSFERIR") > 0
				if oMdlGrid:GetValue("QTD_TRANSFERIR") > oMdlGrid:GetValue("DISPONIVEL")
					aadd(aErros, STR0021 /*origem*/+ oMdlGrid:GetValue("CODIGO_ARMAZEM") + STR0022) //" quantidade indisponível para transferência."
					loop
				endif
				if oTransf:Transfere(;
						oModelBase:GetValue("CODIGO_PECA"),;
						oMdlGrid:GetValue("CODIGO_ARMAZEM"),;
						oModelBase:GetValue("ARMAZEM_DESTINO"),;
						oMdlGrid:GetValue("QTD_TRANSFERIR");
					)
					nSomaTrf += oMdlGrid:GetValue("QTD_TRANSFERIR")
					aadd(aResumo, STR0021 /*origem*/+ oMdlGrid:GetValue("CODIGO_ARMAZEM") + STR0023 /*destino*/ + oModelBase:GetValue("ARMAZEM_DESTINO") + STR0024/*" Quantidade: "*/ + cValtoChar(oMdlGrid:GetValue("QTD_TRANSFERIR")))
				else
					aadd(aErros, STR0021 /*origem*/+ oMdlGrid:GetValue("CODIGO_ARMAZEM") + STR0023 /*destino*/ + oModelBase:GetValue("ARMAZEM_DESTINO") + STR0024/*" Quantidade: "*/ + cValtoChar(oMdlGrid:GetValue("QTD_TRANSFERIR")))
				endif
			endif
		endif
	next

	if len(aResumo) > 0 .and. nSomaTrf > 0
		aadd(aResumo, STR0029/*"Você transferiu um total de "*/ + " " + cvaltochar(nSomaTrf) + " " + STR0030)//"Peça(s)")
		MsgInfo(oArrHelper:Join(aResumo, chr(13) + chr(10)), STR0025)//"Resumo")
	endif
	if len(aErros) > 0
		aadd(aResumo, STR0031) // /*"Não foi possível realizar as transferências os itens listados acima"*/
		MsgInfo(oArrHelper:Join(aErros, chr(13) + chr(10)), STR0026)//"Erros")
	endif
return .t.