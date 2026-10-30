#include "TBICONN.CH"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "OFIA503.CH"


Static oModel01
Static oModel02
Static oModel03
Static oModel04
Static oModel05
Static oModel06
Static oModel07
Static oModel08
Static oModel09
Static oModel10
Static oModel11
Static oModel12
Static oArrHelper
Static oStrHelper := DMS_StringHelper():New()
Static cStaticConta := ""
Static cAliasTmp1   := "TRBOA503"
Static aCacheCpoChv := OA50300297_array_campos_chaves()

/*/{Protheus.doc} OFIA503
	Tela para configuracoes gerais de integrações John Deere

	Esta rotina irá unificar as  configurações da marca John Deere, aos poucos traremos tudo para cá.

	Inicialmente teremos as seguintes configurações :

	- Configurações de Filiais:
		* código da filial (protheus)
		* código jd (dealer code) MV_MIL0005
		* Armazéns de venda
		* Armazéns Linha Verde
		* Armazéns Linha Amarela

	- Configurações Gerais:
		* Modo debug?
		* Visualiza estoque ao digitar pedido?
		* Motivos de venda perdida balcão
		* Motivos de venda perdida oficina
		* Grupos de peças controladas
		* Localização dos arquivos gerados
		* Localização dos arquivos à importar
		* Geração Delta habilitada? MV_MIL0068
		* MV_MIL0054 - Origem Adicionais da peça (SB5 ou SBZ)
		* MV_MIL0088 MV_MIL0089 - Email origem de mensagens RPM via email
		* MV_MIL0102 - Destinatário para emails de erro

	@author Vinicius Gati
	@since  05/06/2024
/*/
function OFIA503(cConta)
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	Private oConfig := OFJDConfig():New(nil, cConta)
	Private cMotivo := "000004"
	Private M->VG8_CODMAR := FMX_RETMAR("JD ") // Filtro para grupo de servico
	
	if lNovoCombo 
		if empty(cConta)
			//"Não é possível acessar essa rotina diretamente quando usando configuração combo Latam, utilize programa: "
			Alert(STR0102+" OFIA512->"+STR0103+"->"+STR0104) // "Ações Relacionadas" //"Configurações RPM"
			return .F.
		else
			cStaticConta := cConta
		endif
	endif

	oObjTempTable := OFDMSTempTable():New()
	oObjTempTable:cAlias := cAliasTmp1
	oObjTempTable:aVetCampos := OA50300227_cpo_tabela_temp()
	oObjTempTable:AddIndex(, {"GAR_DEACOD", "GAR_FILIAL", "GAR_SEGMEN"})	
	oObjTempTable:CreateTable()
	OA50300277_carregar_tabela_temp()

	FWExecView(STR0177, "OFIA503", MODEL_OPERATION_UPDATE) // "Manutenção"

	If oObjTempTable <> Nil
		oObjTempTable:CloseTable()
	endif

return .t.

/*/{Protheus.doc} ViewDef
	Definicao da view
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1
	Local oStr3
	Local oStr4
	Local oStr5
	Local oStr6
	Local oStr7
	Local oStr8
	Local oStr9
	Local oStr10
	Local oStr11
	Local oStr12

	oStr1 := oModel01:GetView()
	oStr3 := oModel03:GetView()
	oStr4 := oModel04:GetView()
	oStr5 := oModel05:GetView()
	oStr6 := oModel06:GetView()
	oStr7 := oModel07:GetView()
	oStr8 := oModel08:GetView()
	oStr9 := oModel09:GetView()
	oStr10 := oModel10:GetView()
	oStr11 := oModel11:GetView()
	oStr12 := oModel12:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('BASE', oStr1, 'BASE')
	oView:AddField('BASE_DEBUG', oStr8, 'BASE_DEBUG')
	oView:AddField('BASE_JDPRISM', oStr9, 'BASE_JDPRISM')
	oView:AddGrid('GRID_GRUPOS_DE_PECAS', oStr3, 'GRID_GRUPOS_DE_PECAS')
	oView:AddGrid('GRID_GRUPOS_DE_MOTIVOS_BALCAO', oStr4, 'GRID_GRUPOS_DE_MOTIVOS_BALCAO')
	oView:AddGrid('GRID_GRUPOS_DE_MOTIVOS_OFICINA', oStr5, 'GRID_GRUPOS_DE_MOTIVOS_OFICINA')
	oView:AddGrid('GRID_FILIAIS', oStr6, 'GRID_FILIAIS')
	oView:AddGrid('GRID_ARMAZENS', oStr7, 'GRID_ARMAZENS')
	oView:AddGrid('GRID_GERACOES_JDPRISM', oStr10, 'GRID_GERACOES_JDPRISM')
	
	oView:AddGrid('GRID_FILIAIS_GARANTIA', oStr11, 'GRID_FILIAIS_GARANTIA')		
	oView:SetViewProperty("GRID_FILIAIS_GARANTIA", "CHANGELINE", {{ || OA50300317_change_line() }} )
	
	oView:AddField('BASE_PARAMETROS_GARANTIA', oStr12, 'BASE_PARAMETROS_GARANTIA')

	// 1 divisao
	oView:CreateHorizontalBox('BOX', 100)

	// 1 folder
	oView:CreateFolder('FOLDER', 'BOX')

	// 3 sheets
	oView:AddSheet('FOLDER', 'ABA_GERAL', STR0070)//"Geral")
	oView:AddSheet('FOLDER', 'ABA_JDPRISM', "Jdprism")
	oView:AddSheet('FOLDER', 'ABA_FILIAIS', STR0071) //"Filiais")
	oView:AddSheet('FOLDER', 'ABA_PECAS', STR0072)//"Peças")
	oView:AddSheet('FOLDER', 'ABA_DEBUG', STR0073)//"Debug")
	oView:AddSheet('FOLDER', 'ABA_PARAMETROS_GARANTIA', STR0105) //"Parametros da Garantia"
		
	// ABA GERAL
	oView:CreateHorizontalBox('BOX_ABA_GERAL',100,,,'FOLDER','ABA_GERAL')
	oView:SetOwnerView('BASE','BOX_ABA_GERAL')
	
	// Aba JDPRISM
	oView:CreateHorizontalBox('BOX_ABA_JDPRISM',60,,,'FOLDER','ABA_JDPRISM')
	oView:CreateHorizontalBox('BOX_ABA_JDPRISM_GERACOES',40,,,'FOLDER','ABA_JDPRISM')
	oView:SetOwnerView('BASE_JDPRISM', 'BOX_ABA_JDPRISM')
	oView:SetOwnerView('GRID_GERACOES_JDPRISM', 'BOX_ABA_JDPRISM_GERACOES')

	//ABA FILIAIS
	oView:CreateHorizontalBox('BOX_ABA_FILIAIS_CIMA' ,30,,,'FOLDER','ABA_FILIAIS')
	oView:CreateHorizontalBox('BOX_ABA_FILIAIS_BAIXO',70,,,'FOLDER','ABA_FILIAIS')
	oView:SetOwnerView('GRID_FILIAIS','BOX_ABA_FILIAIS_CIMA')
	oView:SetOwnerView('GRID_ARMAZENS','BOX_ABA_FILIAIS_BAIXO')

	oView:CreateVerticalBox("BOX_DEBUG",100,,,"FOLDER", "ABA_DEBUG")
	oView:SetOwnerView('BASE_DEBUG','BOX_DEBUG')

	// ABA PECAS 3 divisoes
	oView:CreateHorizontalBox('BOX_ABA_PECAS_CIMA',50,,,'FOLDER','ABA_PECAS')
	oView:CreateHorizontalBox('BOX_ABA_PECAS_BAIXO',50,,,'FOLDER','ABA_PECAS')

	oView:CreateVerticalBox("MOTIVOS_ESQUERDA_1",50,'BOX_ABA_PECAS_BAIXO', .f., "FOLDER", "ABA_PECAS")
	oView:CreateVerticalBox("MOTIVOS_DIREITA_1",50,'BOX_ABA_PECAS_BAIXO', .f., "FOLDER", "ABA_PECAS")
	oView:SetOwnerView('GRID_GRUPOS_DE_MOTIVOS_BALCAO','MOTIVOS_ESQUERDA_1')
	oView:SetOwnerView('GRID_GRUPOS_DE_MOTIVOS_OFICINA','MOTIVOS_DIREITA_1')


	oView:CreateVerticalBox("MOTIVOS_ESQUERDA_2",99,'BOX_ABA_PECAS_CIMA', .f., "FOLDER", "ABA_PECAS")
	oView:CreateVerticalBox("MOTIVOS_DIREITA_2",1,'BOX_ABA_PECAS_CIMA', .f., "FOLDER", "ABA_PECAS")
	oView:SetOwnerView('GRID_GRUPOS_DE_PECAS','MOTIVOS_ESQUERDA_2')

	//ABA PARAMETROS DA GARANTIA
	oView:CreateHorizontalBox('BOX_ABA_PARAMETROS_GARANTIA_CIMA' ,30,,,'FOLDER','ABA_PARAMETROS_GARANTIA')
	oView:CreateHorizontalBox('BOX_ABA_PARAMETROS_GARANTIA_BAIXO',70,,,'FOLDER','ABA_PARAMETROS_GARANTIA')
	oView:SetOwnerView('GRID_FILIAIS_GARANTIA','BOX_ABA_PARAMETROS_GARANTIA_CIMA')
	oView:SetOwnerView('BASE_PARAMETROS_GARANTIA','BOX_ABA_PARAMETROS_GARANTIA_BAIXO')

	// modelo que vai na aba pecas

	oView:EnableTitleView('BASE', STR0002)
	oView:EnableTitleView('GRID_GRUPOS_DE_PECAS', STR0050) //"Grupos de peças"
	oView:EnableTitleView('GRID_GRUPOS_DE_MOTIVOS_BALCAO', STR0004) //"Motivos Venda Perdida Balção"
	oView:EnableTitleView('GRID_GRUPOS_DE_MOTIVOS_OFICINA', STR0005) //"Motivos Venda Perdida Oficina"
	oView:EnableTitleView('GRID_ARMAZENS', STR0051) //"Configuração dos armazéns"
	oView:EnableTitleView('GRID_FILIAIS', STR0052) //"Filiais x Dealer Code"
	oView:EnableTitleView('BASE_DEBUG', STR0068) //"Configuração de Debug".
	oView:EnableTitleView('BASE_JDPRISM', STR0069) // "Configurações JDPRISM"
	oView:EnableTitleView('GRID_GERACOES_JDPRISM', STR0074)//"Gerações Programadas")
	oView:EnableTitleView('GRID_FILIAIS_GARANTIA', STR0106) //"Filiais/Dealer Code" 
	oView:EnableTitleView('BASE_PARAMETROS_GARANTIA', STR0107) //"Parametros da Garantia" 

	oView:AddUserButton(STR0108,"BUTTON", { |oView| OA50300134_ImportaArquivos() }) // Importar Arquivos
	oView:AddUserButton(STR0109,"BUTTON", { |oView| OA50300144_SimularScheduler() }) // Simular Scheduler
	oView:AddUserButton(STR0110,"BUTTON", { |oView| OA50300154_CancelarSimulacao() }) // Finalizar Simulação
	oView:AddUserButton(STR0111,"BUTTON", { || OA50300337_replicar(oModel) }) //"Replicar Parametro Garantia" 

	oView:SetVldFolder({ |cFolderID, nOldSheet, nSelSheet | OA50300327_change_folder(cFolderID, nOldSheet, nSelSheet, oModel) })

	// Retira o botão de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.T.})
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
	Local oStr3
	Local oStr4
	Local oStr5
	Local oStr6
	Local oStr7
	Local oStr8
	Local oStr9
	Local oStr10
	Local oStr11
	Local oStr12
	local cTitle := STR0001

	If oModel01 == NIL
		oArrHelper := DMS_ArrayHelper():New()
		oModel01 := GetModel01()
		oModel03 := GetModel03()
		oModel04 := GetModel04()
		oModel05 := GetModel05()
		oModel06 := GetModel06()
		oModel07 := GetModel07()
		oModel08 := GetModel08()
		oModel09 := GetModel09()
		oModel10 := GetModel10()
		oModel11 := GetModel11()
		oModel12 := GetModel12()
	EndIf

	oStr1 := oModel01:GetModel()
	oStr3 := oModel03:GetModel()
	oStr4 := oModel04:GetModel()
	oStr5 := oModel05:GetModel()
	oStr6 := oModel06:GetModel()
	oStr7 := oModel07:GetModel()
	oStr8 := oModel08:GetModel()
	oStr9 := oModel09:GetModel()
	oStr10 := oModel10:GetModel()
	oStr11 := oModel11:GetModel() 
	oStr12 := oModel12:GetModel() 

	if ! empty(cStaticConta)
		cTitle := STR0001 + " - " + cStaticConta
	endif

	oModel := MPFormModel():New('OFIA503',,,{ |oModel| OA50300014_Confirmar(oModel) })
	oModel:SetDescription(cTitle) // Configuração John Deere
	
	oModel:AddFields("BASE",,oStr1,,,{|| Load01Dados() })
	oModel:GetModel("BASE"):SetDescription(STR0002) //Configurações Base

	oModel:AddFields("BASE_DEBUG","BASE",oStr8,,,{|| Load08Dados() })
	oModel:GetModel("BASE_DEBUG"):SetDescription(STR0068) //Configurações Debug

	oModel:AddFields("BASE_JDPRISM", "BASE", oStr9,,,{|| Load09Dados() })
	oModel:GetModel("BASE_JDPRISM"):SetDescription(STR0069)

	oModel:AddGrid("GRID_GRUPOS_DE_PECAS","BASE", oStr3,,,,,{|| Load03Dados() })
	oModel:GetModel("GRID_GRUPOS_DE_PECAS"):SetDescription(STR0003) //"Grupos de peças controlados"
	oModel:GetModel("GRID_GRUPOS_DE_PECAS"):SetOptional(.F.)
	oModel:GetModel("GRID_GRUPOS_DE_PECAS"):SetUniqueLine({"GRUPO_PECA"})

	oModel:AddGrid("GRID_GRUPOS_DE_MOTIVOS_BALCAO","BASE", oStr4,,,,,{|| Load04Dados() })
	oModel:GetModel("GRID_GRUPOS_DE_MOTIVOS_BALCAO"):SetDescription(STR0004) // "Motivos de venda perdida balcão"
	oModel:GetModel("GRID_GRUPOS_DE_MOTIVOS_BALCAO"):SetUniqueLine({"MOTIVO"})

	oModel:AddGrid("GRID_GRUPOS_DE_MOTIVOS_OFICINA","BASE", oStr5,,,,,{|| Load05Dados() })
	oModel:GetModel("GRID_GRUPOS_DE_MOTIVOS_OFICINA"):SetDescription(STR0005) //"Motivos de venda perdida oficina"
	oModel:GetModel("GRID_GRUPOS_DE_MOTIVOS_OFICINA"):SetUniqueLine({"MOTIVO"})

	oModel:AddGrid("GRID_FILIAIS","BASE", oStr6,,,,,{|| Load06Dados() })
	oModel:GetModel("GRID_FILIAIS"):SetDescription(STR0006) //"Motivos de venda perdida oficina"
	oModel:GetModel("GRID_FILIAIS"):SetUniqueLine({"FILIAL","SEGMENTO"})

	oModel:AddGrid("GRID_ARMAZENS","BASE", oStr7,,,,{|oGrid| OA50300164_TudoOkArms(oGrid, oArrHelper) },{|| Load07Dados() })
	oModel:GetModel("GRID_ARMAZENS"):SetDescription(STR0007) //"Configurações de Armazéns")
	oModel:GetModel("GRID_ARMAZENS"):SetUniqueLine({"CODIGO_ARMAZEM", "FILIAL", "SEGMENTO"})

	oModel:AddGrid("GRID_GERACOES_JDPRISM", "BASE", oStr10,,,,, {|| Load10Dados() })
	oModel:GetModel("GRID_GERACOES_JDPRISM"):SetDescription(STR0074)//"Gerações programadas")
	oModel:GetModel("GRID_GERACOES_JDPRISM"):SetOptional(.t.)

 	oModel:AddGrid("GRID_FILIAIS_GARANTIA","BASE", oStr11,,,,,)
	oModel:GetModel("GRID_FILIAIS_GARANTIA"):SetDescription(STR0112) // "Filiais/Dealer Code"
	oModel:GetModel("GRID_FILIAIS_GARANTIA"):SetUniqueLine({"FILIAL","SEGMENTO"})

	oModel:AddFields("BASE_PARAMETROS_GARANTIA","BASE", oStr12,,,{|| Load12Dados() })	
	oModel:GetModel("BASE_PARAMETROS_GARANTIA"):SetDescription(STR0113) //"Parametros de Garantia"
	
	oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
Static Function GetModel01()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'  , STR0057 },; // "Cód. Conta Principal"
		{'cIdField' , "CFG_ACCOUNT" },;
		{'nTamanho' , 6 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0058 } ; //"Código da conta principal para o nome dos arquivos"
	})
	oMd1:AddField({;
		{'cTitulo'  , STR0012 },; // "Origem Adicionais da peça"
		{'cIdField' , "CFG_ORI_ADC_PECAS" },;
		{'nTamanho' , 1 },;
		{'aComboValues', {"0=SB5", "1=SBZ"}},;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0013 } ; //"Antigo MV_MIL0054 para identificar de onde virão os dados adicionais das peças"
	})
	oMd1:AddField({;
		{'cTitulo'  , STR0014 },; // "Visualiza estoque ao digitar pedido?"
		{'cIdField' , "CFG_VIS_ESTOQUE" },;
		{'nTamanho' , 1 },;
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'lObrigat' , .T.                 },;
		{'cTooltip' , STR0015  } ; //"Ao digitar o pedido será possível ver o estoque? isso pode afetar o nível de atendimento"
	})
	oMd1:AddField({;
		{'cTitulo'  , STR0016 },; // "Caminho dos arquivos gerados"
		{'cIdField' , "CFG_LOCAL_ARQUIVOS" },;
		{'nTamanho' , 400 },;
		{'bValid', { |a,b,c,d| OA50300034_SelecionaArquivo(a,b,c,d) }},;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0017 } ; //"Caminho onde os arquivos serão gerados"
	})
	oMd1:AddField({;
		{'cTitulo'  , STR0018 },; // "Caminho dos arquivos para importar"
		{'cIdField' , "CFG_LOCAL_ARQUIVOS_IMPORTAR" },;
		{'nTamanho' , 400 },;
		{'bValid', { |a,b,c,d| OA50300034_SelecionaArquivo(a,b,c,d) }},;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0019 } ; //"Caminho de onde os arquivos serão importados"
	})
	oMd1:AddField({;
		{'cTitulo'  , STR0020 },; // "Geração Delta Habilitada?"
		{'cIdField' , "CFG_DELTA_LIBERADO" },;
		{'nTamanho' , 1 },;
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0021 } ; //"Libera a geração do delta? Deve-se estar conforme liberação da John Deere para sua conta"
	})
return oMd1

/*/{Protheus.doc} Load01Dados
	default values for the filter
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
static function Load01Dados()
return {;
	{;
		oConfig:GetValue('CFG_ACCOUNT', space(6)),;
		oConfig:GetValue('CFG_ORI_ADC_PECAS', '0'),;
		oConfig:GetValue('CFG_VIS_ESTOQUE', '0'),;
		oStrHelper:ljust(oConfig:GetValue('CFG_LOCAL_ARQUIVOS', space(400)), 400),;
		oStrHelper:ljust(oConfig:GetValue('CFG_LOCAL_ARQUIVOS_IMPORTAR', space(400)), 400),;
		oConfig:GetValue('CFG_DELTA_LIBERADO', '0') ;
	}, 0;
}

/*/{Protheus.doc} GetModel03
	Configurações de grupos de peças controlados pelo DPM
	Ele vai gravar o campo BM_VAIDPM = 1 além de gravar no json
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
Static Function GetModel03()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0026 },; //"Grupo das Peças"
		{'cIdField' , "GRUPO_PECA" },;
		{'nTamanho' , GetSX3Cache("BM_GRUPO","X3_TAMANHO") },;
		{'bValid', { |a,b,c,d| OA50300044_AtualizaPorGrupo(a,b,c,d) }},;
		{'cLookUp'  , "SBM" },;
		{'cTooltip' , STR0026 } ;
	})
	oMd:AddField({;
		{'cTitulo'  , STR0027 },; //"Descrição"
		{'cIdField' , "GRUPO_DESCRICAO" },;
		{'nTamanho' , GetSX3Cache("BM_DESC","X3_TAMANHO") },;
		{'lCanChange',.F. },;
		{'cTooltip' , STR0028 } ; //"Descrição do grupo da peça selecionado"
	})
return oMd

/*/{Protheus.doc} GetModel04

	@type function
	@author Vinicius Gati
	@since 04/06/2024
/*/
Static Function GetModel04()
	Local oMd := OFDMSStruct():New()

	oMd:AddField({;
		{'cTitulo'  , STR0029 },; //"Motivo para venda perdida"
		{'cIdField' , "MOTIVO" },;
		{'nTamanho' , GetSX3Cache("VS0_CODMOT","X3_TAMANHO") },;
		{'bValid', { |a,b,c,d| OA50300064_MotivoBalcao(a,b,c,d) }},;
		{'cLookUp'  , "VS0" },;
		{'cTooltip' , STR0030 } ; //"Motivos para venda perdida balcão"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0031 },; //"Descrição do Motivo"
		{'cIdField' , "MOTIVO_DESCRICAO" },;
		{'nTamanho' , GetSX3Cache("VS0_DESMOT","X3_TAMANHO") },;
		{'cTooltip' , STR0031 } ; //"Descrição do Motivo"
	})
return oMd

/*/{Protheus.doc} GetModel05

	@type function
	@author Vinicius Gati
	@since 04/06/2024
/*/
Static Function GetModel05()
	Local oMd := OFDMSStruct():New()

	oMd:AddField({;
		{'cTitulo'  , STR0032 },; //"Motivo para venda perdida oficina"
		{'cIdField' , "MOTIVO" },;
		{'nTamanho' , GetSX3Cache("VS0_CODMOT","X3_TAMANHO") },;
		{'bValid', { |a,b,c,d| OA50300124_MotivoOficina(a,b,c,d) }},;
		{'cLookUp'  , "VS0CO" },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0032 } ;
	})
	oMd:AddField({;
		{'cTitulo'  , STR0031 },; //"Descrição do Motivo"
		{'cIdField' , "MOTIVO_DESCRICAO" },;
		{'nTamanho' , GetSX3Cache("VS0_DESMOT","X3_TAMANHO") },;
		{'lCanChange', .F.},;
		{'cTooltip' , STR0031 } ; //"Descrição do Motivo"
	})
return oMd

/*/{Protheus.doc} GetModel06

	@type function
	@author Vinicius Gati
	@since 04/06/2024
/*/
Static Function GetModel06()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0033 },; //"Filial"
		{'cIdField' , "FILIAL" },;
		{'nTamanho' , GetSX3Cache("VS3_FILIAL","X3_TAMANHO") },;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, OA50300084_OpcoesFiliais()) .and. OA50300172_LimpaSegmentoAposFilial(a) }},;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0036 } ; //"Filial que será controlada"
	})
	oMd:AddField({;
		{'cTitulo'  , "Principal" },; //"Filial"
		{'cIdField' , "PRINCIPAL" },;
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},; // S ou N
		{'nTamanho' , 1 },;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") .and. OA50300114_ValidaPrincipal(a,b,c,d) }},;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0056 } ; //"Informa se a filial será usada como padrão caso não seja identificado o segmento"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0034 },; //"Segmento"
		{'cIdField' , "SEGMENTO" },;
		{'aComboValues', OA50300204_GetSegmentos()},; // agricola & construcao
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1,2,3") .and. OA50300162_ValidaSegmentoDuplicado(a,c) }},;
		{'nTamanho' , 1 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0035 } ; //"Indica a linha do dealer code"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0039 + " (Dealer Code)" },; //"Código John Deere da Filial"
		{'cIdField' , "DEALER_CODE" },;
		{'bValid', { |a,b,c,d| OA50300182_ValidaCodeDealerDuplicado(a,c) }},;
		{'nTamanho' , 6   },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0040 } ; //"Dealer code da filial que será controlada"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0090 },; //"E-mail Origem Mensagens RPM"
		{'cIdField' , "EMAIL_ORIGEM_RPM" },;
		{'nTamanho' , 255 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0040 } ; //"Dealer code da filial que será controlada"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0091 },; //"E-mail Destinatário Mensagens RPM"
		{'cIdField' , "EMAIL_DESTINATARIO_RPM" },;
		{'nTamanho' , 255 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0040 } ; //"Dealer code da filial que será controlada"
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

/*/{Protheus.doc} GetModel07

	@type function
	@author Vinicius Gati
	@since 04/06/2024
/*/
Static Function GetModel07()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0041 },;//"Armazém"
		{'cIdField' , "CODIGO_ARMAZEM" },;
		{'nTamanho' , GetSX3Cache("NNR_CODIGO","X3_TAMANHO") },;
		{'bValid', { |a,b,c,d| OA50300054_AtualizaDescNNR(a,b,c,d) }},;
		{'cTooltip' , "Código do armazém" } ;
	})
	oMd:AddField({;
		{'cTitulo'  , STR0042 },; //"Descrição do Armazém"
		{'cIdField' , "DESCRICAO" },;
		{'nTamanho' , GetSX3Cache("NNR_DESCRI","X3_TAMANHO") },;
		{'lObrigat' , .F. },;
		{'cTooltip' ,  STR0043 } ; //"Dealer code da filial que será controlada"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0033 },;//"Filial"
		{'cIdField' , "FILIAL" },;
		{'nTamanho' , GetSX3Cache("VS3_FILIAL","X3_TAMANHO") },;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, OA50300084_OpcoesFiliais()) }},;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0036 } ; //"Filial que será controlada"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0044 },; //"Considerar Linha"
		{'cIdField' , "SEGMENTO" },;
		{'aComboValues', OA50300204_GetSegmentos()},; // agricola & construcao
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1,2,3") }},;
		{'nTamanho' , 1 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0045 } ; //"Indica a linha considerada caso venda tenha origem nesse armazém"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0046 },; //"Considera nas vendas?"
		{'cIdField' , "ARMAZEM_DE_VENDA" },;
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'nTamanho' , 1 },;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0047 } ; //"Configura se esse armazém é considerado na hora da venda para estoque e nível de atendimento"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0087 },; // Permite Transferências Para Faturamento
		{'cIdField' , "PERMITE_TRANSFERENCIAS" },;
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'nTamanho' , 1 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0047 } ; // Permite usar saldo deste orçamento para cobrir orçamentos de balcão com falta de saldo, não utilizar "SIM" para armazéns de reserva
	})
	oMd:AddField({;
		{'cTitulo'  , STR0054 },; //"Código JD do Armazém"
		{'cIdField' , "CODIGO_JD_ARMAZEM" },;
		{'nTamanho' , 10 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0055 } ; //"Código do 'wharehouse' na John Deere"
	})
	oMd:AddField({;
		{'cTitulo'  , "Principal" },; //"Principal"
		{'cIdField' , "PRINCIPAL" },;
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},; // S ou N
		{'nTamanho' , 1 },;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'lObrigat' , .F. },;
		{'cTooltip' , "" } ; //"Indica que em caso de entradas e saidas esse armazem deve ser utilizado para o codigo JD do wharehouse, isso é necessário por conta do Merge de armazéns"
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

Static Function GetModel08()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0008 },; // Modo Debug
		{'cIdField' , "DEBUGANDO" },;
		{'nTamanho' , 1 },;
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0011  } ; //"Habilita o modo debug nas rotinas relacionadas a John Deere"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0088 },;
		{'cIdField' , "LISTA_PECAS_DEBUG" },;
		{'nTamanho' , 254 },;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0081  } ;//"Peças separado por ; para logs específicos."
	})
	oMd:AddField({;
		{'cTitulo'  , STR0082 },; //"Lista de Filiais"
		{'cIdField' , "LISTA_FILIAIS_DEBUG" },;
		{'nTamanho' , 254 },;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0089 } ; //"Lista de filiais separadas por ; para logs específicos."
	})
	oMd:AddField({;
		{'cTitulo'  , STR0083 },; //"Segmentos"
		{'cIdField' , "LISTA_SEGMENTOS_DEBUG" },;
		{'nTamanho' , 254 },;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0084 } ;
	})
return oMd

Static Function GetModel09()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0059 },; //"Fornecedor"
		{'cIdField' , "FORNCOD" },;
		{'nTamanho' , GetSX3Cache("A2_COD", "X3_TAMANHO") },;
		{'cLookUp'  , 'FOR'},;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0061 } ; // Código do fornecedor que será usado para transferencias no jdprism
	})
	oMd:AddField({;
		{'cTitulo'  , STR0060 },; // Loja do fornecedor
		{'cIdField' , "FORNLOJA" },;
		{'nTamanho' , GetSX3Cache("A2_LOJA", "X3_TAMANHO") },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0061 } ; // "Loja do fornecedor para transferência jdprism"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0062 },; // Condicao de pagamento
		{'cIdField' , "CONDPAG_PEDIDOS" },;
		{'nTamanho' , GetSX3Cache("E4_CODIGO", "X3_TAMANHO") },;
		{'lObrigat' , .T. },;
		{'cLookUp'  , 'SE4'},;
		{'cTooltip' , STR0063  } ; // Condição de pagamento para Pedidos JDPrism
	})
	If cPaisLoc == "BRA"
		oMd:AddField({;
			{'cTitulo'  , STR0064 },; // operacao
			{'cIdField' , "OPERACAO_TRANSFER" },;
			{'nTamanho' , GetSX3Cache("VS3_OPER", "X3_TAMANHO") },;
			{'lObrigat' , .T. },;
			{'cLookUp'  , 'DJ'},;
			{'cTooltip' , STR0065 } ; // "Operação para Transferências recebidas via jdprism"
		})
	Else // Demais paises
		oMd:AddField({;
			{'cTitulo'  , STR0092 },; // TES Entrada para Transfers
			{'cIdField' , "TES_ENTRADA_TRANSFER" },;
			{'nTamanho' , GetSX3Cache("VS3_CODTES", "X3_TAMANHO") },;
			{'lObrigat' , .T. },;
			{'cLookUp'  , 'SF4'},;
			{'cTooltip' , STR0093 } ; // "TES Entrada para Transferências"
		})
		oMd:AddField({;
			{'cTitulo'  , STR0094 },; // TES Saida para Transfers
			{'cIdField' , "TES_SAIDA_TRANSFER" },;
			{'nTamanho' , GetSX3Cache("VS3_CODTES", "X3_TAMANHO") },;
			{'lObrigat' , .T. },;
			{'cLookUp'  , 'SF4'},;
			{'cTooltip' , STR0095 } ; // "TES Saida para Transferências"
		})
	EndIf
	oMd:AddField({;
		{'cTitulo'  , STR0066 },; //"Formula de preços para Transfers"
		{'cIdField' , "FORMULA_TRANSFER" },;
		{'nTamanho' , GetSX3Cache("VS3_FORMUL", "X3_TAMANHO") },;
		{'lObrigat' , .T. },;
		{'cLookUp'  , 'VEG'},;
		{'cTooltip' , STR0067 } ; //"Formula de preços para Transfers recebidas via jdprism"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0096 },; //"Formula de preços para Pedidos"
		{'cIdField' , "FORMULA_ORDER" },;
		{'nTamanho' , GetSX3Cache("VS3_FORMUL", "X3_TAMANHO") },;
		{'lObrigat' , .T. },;
		{'cLookUp'  , 'VEG'},;
		{'cTooltip' , STR0067 } ; //"Formula de preços para Transfers recebidas via jdprism"
	})
return oMd

Static Function GetModel10()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0075 },; // Tipo da geração
		{'cIdField' , "JDPRISM_TIPO_GERACAO" },;
		{'nTamanho' , 1 },;
		{'cTooltip' , STR0086 } ; // "O tipo da geração de arquivo diário"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0076 },; // Horário
		{'cIdField' , "JDPRISM_HORARIO" },;
		{'cTooltip' , STR0085 } ; // "Horário da geração"
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

Static Function GetModel11()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0033 },; //"Filial"
		{'cIdField' , "FILIAL" },;
		{'nTamanho' , GetSX3Cache("VS3_FILIAL","X3_TAMANHO") },;
		{'lObrigat' , .F. },;
		{'cTooltip' , STR0036 } ; //"Filial que será controlada"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0034 },; //"Segmento"
		{'cIdField' , "SEGMENTO" },;
		{'aComboValues', OA50300204_GetSegmentos()},; // agricola & construcao
		{'nTamanho' , 1 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0035 } ; //"Indica a linha do dealer code"
	})
	oMd:AddField({;
		{'cTitulo'  , STR0039 + " (Dealer Code)" },; //"Código John Deere da Filial"
		{'cIdField' , "DEALER_CODE" },;
		{'nTamanho' , 6   },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0040 } ; //"Dealer code da filial que será controlada"
	})
return oMd

Static Function GetModel12()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({; // 00
		{"cTitulo"  ,STR0114 },; //"Dealer"
		{"cIdField" , "DEALER_CODE_FORM" },;
		{"nTamanho" , 6 },;
		{"bValid", { || .T. }},;
		{"lCanChange", .F. },;			
		{"cTooltip" , STR0036 } ; // //"Filial que será controlada"
	})	
	oMd:AddField({; // 01
		{"cTitulo"  , STR0115 },; //"TT Peça (Esp. Cliente)?"
		{"cIdField" , "TT_PECA_CLIENTE" },;
		{"nTamanho" , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO") },;
		{"bValid", { || OA50300287_vld_cpo("VOI", "TT_PECA_CLIENTE") }},;
		{"cLookUp"  , "VOI" },;
		{"cTooltip" , STR0115 } ; // "TT Peça (Esp. Cliente)?"
	})
	oMd:AddField({; // 02
		{"cTitulo"  , STR0116 },; //"TT Srvc (Esp. Cliente) ?"
		{"cIdField" , "TT_SERVICO_CLIENTE" },;
		{"nTamanho" , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOI", "TT_SERVICO_CLIENTE") }},;
		{"cLookUp"  , "VOI" },;
		{"cTooltip" , STR0116  } ; //"TT Srvc (Esp. Cliente) ?"
	})	
	oMd:AddField({; // 03
		{"cTitulo"  , STR0117 },; //"Grupo Srvc (Esp. Cliente) ?"
		{"cIdField" , "GRP_SERVICO_CLIENTE" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_CLIENTE", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0117  } ;//"Grupo Srvc (Esp. Cliente) ?"
	})	
	oMd:AddField({; // 04
		{"cTitulo"  , STR0118 },; //"Cod. Serviço (Esp. Cliente) ?"
		{"cIdField" , "COD_SERVICO_CLIENTE" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_CLIENTE", 4) }},;		
		{"cTooltip" , STR0118  } ;//"Cod. Serviço (Esp. Cliente) ?"
	})	
	oMd:AddField({; // 05
		{"cTitulo"  , STR0119 },; //"Tipo Serviço (Esp. Cliente) ?"
		{"cIdField" , "TIPO_SERVICO_CLIENTE" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_CLIENTE") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0119  } ;//"Tipo Serviço (Esp. Cliente) ?"
	})	
	oMd:AddField({; // 06
		{"cTitulo"  , STR0120 },; //"Grupo Srvc O. Cred.(Esp. Cli ?"
		{"cIdField" , "GRP_SERVICO_CRED_CLIENTE" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_CRED_CLIENTE", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0120  } ; //"Grupo Srvc O. Cred.(Esp. Cli ?"
	})
	oMd:AddField({; // 07
		{"cTitulo"  , STR0121 },; //"Cod. Srvc O. Cred. (Esp. Cli ?"
		{"cIdField" , "COD_SERVICO_CRED_CLIENTE" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_CRED_CLIENTE", 4) }},;		
		{"cTooltip" , STR0121  } ;//"Cod. Srvc O. Cred. (Esp. Cli ?"
	})	
	oMd:AddField({; // 08
		{"cTitulo"  , STR0122 },; //"Tipo Srvc O. Cred. (Esp. Cli ?"
		{"cIdField" , "TIPO_SERVICO_CRED_CLI" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_CRED_CLI") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0122  } ;//"Tipo Srvc O. Cred. (Esp. Cli ?"
	})	
	oMd:AddField({; // 09
		{"cTitulo"  , STR0123 },; //"TT Peça (Esp. Interno) ?"
		{"cIdField" , "TT_PECA_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOI", "TT_PECA_INTERNO") }},;
		{"cLookUp"  , "VOI" },;
		{"cTooltip" , STR0123  } ;//"TT Peça (Esp. Interno) ?"
	})	
	oMd:AddField({; // 10
		{"cTitulo"  , STR0124 },; //"TT Srvc (Esp. Interno) ?"
		{"cIdField" , "TT_SERVICO_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOI", "TT_SERVICO_INTERNO") }},;
		{"cLookUp"  , "VOI" },;
		{"cTooltip" , STR0124  } ;//"TT Srvc (Esp. Interno) ?"
	})	
	oMd:AddField({; // 11
		{"cTitulo"  , STR0125 },; //"Grupo Srvc (Esp. Interno) ?"
		{"cIdField" , "GRP_SERVICO_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_INTERNO", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0125  } ;//"Grupo Srvc (Esp. Interno) ?"
	})
	oMd:AddField({; // 12
		{"cTitulo"  , STR0126 },; //"Cod. Serviço (Esp. Interno) ?"
		{"cIdField" , "COD_SERVICO_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_INTERNO", 4) }},;		
		{"cTooltip" , STR0126  } ;//"Cod. Serviço (Esp. Interno) ?"
	})
	oMd:AddField({; // 13
		{"cTitulo"  , STR0127 },; //"Tipo Serviço (Esp. Interno) ?"
		{"cIdField" , "TIPO_SERVICO_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_INTERNO") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0127  } ; //"Tipo Serviço (Esp. Interno) ?"
	})
	oMd:AddField({; // 14
		{"cTitulo"  , STR0128 },; //"Grupo Srvc O. Cred.(Esp. Int ?" 
		{"cIdField" , "GRP_SERVICO_CRED_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_CRED_INTERNO", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0128  } ;//"Grupo Srvc O. Cred.(Esp. Int ?"
	})
	oMd:AddField({; // 15
		{"cTitulo"  , STR0129 },; //"Cod. Srvc O. Cred. (Esp. Int ?"
		{"cIdField" , "COD_SERVICO_CRED_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_CRED_INTERNO", 4) }},;		
		{"cTooltip" , STR0129  } ;//"Cod. Srvc O. Cred. (Esp. Int ?"
	})
	oMd:AddField({; // 16
		{"cTitulo"  , STR0130 },; //"Tipo Srvc O. Cred. (Esp. Int ?"
		{"cIdField" , "TIPO_SERVICO_CRED_INTERNO" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_CRED_INTERNO") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0130  } ;//"Tipo Srvc O. Cred. (Esp. Int ?"
	})
	oMd:AddField({; // 17
		{"cTitulo"  , STR0131 },; //"Motivo de Cancelamento ?"
		{"cIdField" , "MOT_CANCELAMENTO" },;
		{"nTamanho" , GetSX3Cache("VS0_CODMOT","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VS0", "MOT_CANCELAMENTO", , ,cMotivo) }},;
		{"cLookUp"  , "VS0" },;
		{"cTooltip" , STR0131  } ; //"Motivo de Cancelamento ?"
	})
	oMd:AddField({; // 18
		{"cTitulo"  , STR0132 },; //"Operação (G. Especial) ?"
		{"cIdField" , "OPERACAO" },;
		{"nTamanho" , 2 },;	
		{"bValid", { || OA50300287_vld_cpo("SX5", "OPERACAO", , , "DJ") }},;
		{"cLookUp"  , "DJ" },;
		{"cTooltip" , STR0132  } ;//"Operação (G. Especial) ?"
	})
	oMd:AddField({; // 19
		{"cTitulo"  , STR0133 },; //"TES (G. Especial) ?"
		{"cIdField" , "TES_ESPECIAL" },;
		{"nTamanho" , GetSX3Cache("F4_CODIGO","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("SF4", "TES_ESPECIAL") }},;
		{"cLookUp"  , "SF4" },;
		{"cTooltip" , STR0133  } ; // "TES (G. Especial) ?"
	})
	oMd:AddField({; // 20
		{"cTitulo"  , STR0134 },; //"Grupo Srvc. Desloc. (Rev./PM ?"
		{"cIdField" , "GRP_SERVICO_DESLOC" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_DESLOC", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0134  } ;//"Grupo Srvc. Desloc. (Rev./PM ?"
	})
	oMd:AddField({; // 21
		{"cTitulo"  , STR0135 },; //"Cod. Srvc. Desloc. (Rev./PMP ?" 
		{"cIdField" , "COD_SERVICO_DESLOC" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_DESLOC", 4) }},;		
		{"cTooltip" , STR0135  } ;//"Cod. Srvc. Desloc. (Rev./PMP ?"
	})
	oMd:AddField({; // 22
		{"cTitulo"  , STR0136 },; //"Tipo Srvc. Desloc. (Rev./PMP ?"
		{"cIdField" , "TIPO_SERVICO_DESLOC" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_DESLOC") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0136  } ; // "Tipo Srvc. Desloc. (Rev./PMP ?"
	})
	oMd:AddField({; // 23
		{"cTitulo"  , STR0137 },; //"TT Serviço (Revisão) ?"
		{"cIdField" , "TT_SERVICO_REVISAO" },;
		{"nTamanho" , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOI", "TT_SERVICO_REVISAO") }},;
		{"cLookUp"  , "VOI" },;
		{"cTooltip" , STR0137  } ;//"TT Serviço (Revisão) ?"
	})	
	oMd:AddField({; // 24
		{"cTitulo"  , STR0138 },; //"Grupo Srvc (Revisão) ?"
		{"cIdField" , "GRP_SERVICO_REVISAO" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_REVISAO", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0138  } ; //"Grupo Srvc (Revisão) ?"
	})	
	oMd:AddField({; // 25
		{"cTitulo"  , STR0139 },; //"Cod. Seção (Revisão) ?"
		{"cIdField" , "COD_SECAO_REVISAO" },;
		{"nTamanho" , GetSX3Cache("VOD_CODSEC","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOD", "COD_SECAO_REVISAO") }},;
		{"cLookUp"  , "VOD" },;
		{"cTooltip" , STR0139  } ;//"Cod. Seção (Revisão) ?"
	})	
	oMd:AddField({; // 26
		{"cTitulo"  , STR0140 },; //"Depto. Garantia (Revisão) ?"
		{"cIdField" , "DEPTO_GARANTIA_REVISAO" },;
		{"nTamanho" , 1 },;	
		{"bValid", { || OA50300287_vld_cpo("SX5", "DEPTO_GARANTIA_REVISAO", , ,"VF") }},;
		{"cLookUp"  , "VF" },;
		{"cTooltip" , STR0140  } ;//"Depto. Garantia (Revisão) ?"
	})	
	oMd:AddField({; // 27
		{"cTitulo"  , STR0141 },; //"Tipo Srvc (Revisão) ?"
		{"cIdField" , "TIPO_SERVICO_REVISAO" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_REVISAO") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0141  } ;//"Tipo Srvc (Revisão) ?"
	})	
	oMd:AddField({; // 28
		{"cTitulo"  , STR0142 },; //"TT Peça (PMP) ?"
		{"cIdField" , "TT_PECAS_PMP" },;
		{"nTamanho" , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOI", "TT_PECAS_PMP") }},;
		{"cLookUp"  , "VOI" },;
		{"cTooltip" , STR0142  } ;//"TT Peça (PMP) ?"
	})	
	oMd:AddField({; // 29
		{"cTitulo"  , STR0143 },; //"TT Serviço (PMP) ?"
		{"cIdField" , "TT_SERVICO_PMP" },;
		{"nTamanho" , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOI", "TT_SERVICO_PMP") }},;
		{"cLookUp"  , "VOI" },;
		{"cTooltip" , STR0143  } ;//"TT Serviço (PMP) ?"
	})	
	oMd:AddField({; // 30
		{"cTitulo"  , STR0144 },; //"Grupo Srvc (PMP) ?"
		{"cIdField" , "GRP_SERVICO_PMP" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_PMP", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0144 } ;//"Grupo Srvc (PMP) ?"
	})	
	oMd:AddField({; // 31
		{"cTitulo"  , STR0145 },; //"Cod. Seção (PMP) ?" 
		{"cIdField" , "COD_SECAO_PMP" },;
		{"nTamanho" , GetSX3Cache("VOD_CODSEC","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOD", "COD_SECAO_PMP") }},;
		{"cLookUp"  , "VOD" },;
		{"cTooltip" , STR0145 } ;//"Cod. Seção (PMP) ?" 
	})	
	oMd:AddField({; // 32
		{"cTitulo"  , STR0146 },; //"Depto. Garantia (PMP) ?"
		{"cIdField" , "DEPTO_GARANTIA_PMP" },;
		{"nTamanho" , 1 },;	
		{"bValid", { || OA50300287_vld_cpo("SX5", "DEPTO_GARANTIA_PMP", , , "VF") }},;
		{"cLookUp"  , "VF" },;
		{"cTooltip" , STR0146 } ;//"Depto. Garantia (PMP) ?"
	})	
	oMd:AddField({; // 33
		{"cTitulo"  , STR0147 },; //"Tipo Srvc (PMP) ?" 
		{"cIdField" , "TIPO_SERVICO_PMP" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_PMP") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0147 } ;//"Tipo Srvc (PMP) ?" 
	})	
	oMd:AddField({; // 34
		{"cTitulo"  , STR0148 },; //"Cod. Srvc M. Reembolso(PMP) ?" 
		{"cIdField" , "COD_SERVICO_REEMB_PMP" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_REEMB_PMP", 4) }},;		
		{"cTooltip" , STR0148 } ;//"Cod. Srvc M. Reembolso(PMP) ?" 
	})	
	oMd:AddField({; // 35
		{"cTitulo"  , STR0149 },; //"Cod Srvc (PMP) ?"
		{"cIdField" , "COD_SERVICO_PMP" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_PMP", 4) }},;		
		{"cTooltip" , STR0149 } ; //"Cod Srvc (PMP) ?"
	})	
	oMd:AddField({; // 36
		{"cTitulo"  , STR0150 },; //"Tipo de Veiculo de TURF ?" 
		{"cIdField" , "TIPO_VEIC_TURF" },;
		{"nTamanho" , 30 },;	
		{"bValid", { || OA50300287_vld_cpo(, "TIPO_VEIC_TURF") }},;		
		{"cTooltip" , STR0150 } ;//"Tipo de Veiculo de TURF ?" 
	})	
	oMd:AddField({; // 37
		{"cTitulo"  , STR0151 },; //"Tipo de Veiculo de GOLF ?" 
		{"cIdField" , "TIPO_VEIC_GOLF" },;
		{"nTamanho" , 30 },;	
		{"bValid", { || OA50300287_vld_cpo(, "TIPO_VEIC_GOLF") }},;		
		{"cTooltip" , STR0151 } ;//"Tipo de Veiculo de GOLF ?" 
	})	
	oMd:AddField({; // 38
		{"cTitulo"  , STR0152 },; //"Conversão de Unid. Med. ?" 
		{"cIdField" , "CONVERSAO_UNID_MED" },;
		{"nTamanho" , 30 },;	
		{"bValid", { || OA50300287_vld_cpo(, "CONVERSAO_UNID_MED") }},;		
		{"cTooltip" , STR0152 } ;//"Conversão de Unid. Med. ?" 
	})	
	oMd:AddField({; // 39
		{"cTitulo"  , STR0153 },; //"Mensagem na Nota Fiscal ?" 
		{"cIdField" , "MENS_NOTA_FISCAL" },;
		{"nTamanho" , 1 },;	
		{'aComboValues', {"0="+STR0009,"1="+STR0010}},;
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") .and. OA50300287_vld_cpo(, "MENS_NOTA_FISCAL")}},;		
		{"cTooltip" , STR0153 } ;//"Mensagem na Nota Fiscal ?" 
	})	
	oMd:AddField({; // 40
		{"cTitulo"  , STR0154 },; //"Mensagem Padrão ?" 
		{"cIdField" , "MENS_PADRAO" },;
		{"nTamanho" , GetSX3Cache("M4_CODIGO","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("SM4", "MENS_PADRAO") }},;
		{"cLookUp"  , "SM4" },;
		{"cTooltip" , STR0154 } ;//"Mensagem Padrão ?" 
	})	
	oMd:AddField({; // 41
		{"cTitulo"  , STR0155 },; //"Tipo de Serviço Gratuito ?" 
		{"cIdField" , "TIPO_SERVICO_GRATUITO" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_GRATUITO", , .T.) }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0155 } ;//"Tipo de Serviço Gratuito ?" 
	})	
	oMd:AddField({; // 42
		{"cTitulo"  , STR0156 },; //"Operação (Esp. Int) ?" 
		{"cIdField" , "OPERACAO_ESPECIAL_INTERNA" },;
		{"nTamanho" , 2 },;	
		{"bValid", { || OA50300287_vld_cpo("SX5", "OPERACAO_ESPECIAL_INTERNA", , ,"DJ") }},;
		{"cLookUp"  , "DJ" },;
		{"cTooltip" , STR0156 } ;//"Operação (Esp. Int) ?" 
	})	
	oMd:AddField({; // 43
		{"cTitulo"  , STR0157 },; //"TES (Esp. Int) ?" 
		{"cIdField" , "TES_ESPECIAL_INTERNA" },;
		{"nTamanho" , GetSX3Cache("F4_CODIGO","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("SF4", "TES_ESPECIAL_INTERNA") }},;
		{"cLookUp"  , "SF4" },;
		{"cTooltip" , STR0157 } ;//"TES (Esp. Int) ?" 
	})
	oMd:AddField({; // 44
		{"cTitulo"  , STR0158 },; //"Codigo Item Aditivo ?" 
		{"cIdField" , "COD_ITEM_ADITIVO" },;
		{"nTamanho" , GetSX3Cache("B1_COD","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("SB1", "COD_ITEM_ADITIVO") }},;
		{"cLookUp"  , "SB1" },;
		{"cTooltip" , STR0158 } ; //"Codigo Item Aditivo ?" 
	})
	oMd:AddField({; // 45
		{"cTitulo"  , STR0159 },; //"TES Aditvo ?" 
		{"cIdField" , "TES_ITEM_ADITIVO" },;
		{"nTamanho" , GetSX3Cache("F4_CODIGO","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("SF4", "TES_ITEM_ADITIVO") }},;
		{"cLookUp"  , "SF4" },;
		{"cTooltip" , STR0159 } ;//"TES Aditvo ?" 
	})
	oMd:AddField({; // 46
		{"cTitulo"  , STR0178 },; //"Grupo Srvc Aditivo"
		{"cIdField" , "GRP_SERVICO_ADITIVO" },;
		{"nTamanho" , GetSX3Cache("VOS_CODGRU","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOS", "GRP_SERVICO_ADITIVO", 2) }},;
		{"cLookUp"  , "VOS" },;
		{"cTooltip" , STR0178 } ;//"Grupo Srvc Aditivo"
	})
	oMd:AddField({; // 47
		{"cTitulo"  , STR0160 },; //"Codigo Serviço Aditivo ?" 
		{"cIdField" , "COD_SERVICO_ADITIVO" },;
		{"nTamanho" , GetSX3Cache("VO6_CODSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VO6", "COD_SERVICO_ADITIVO", 4) }},;		
		{"cTooltip" , STR0160 } ; //"Codigo Serviço Aditivo ?" 
	})
	oMd:AddField({; // 48
		{"cTitulo"  , STR0161 },; //"Tipo Serviço Aditvo ?" 
		{"cIdField" , "TIPO_SERVICO_ADITIVO" },;
		{"nTamanho" , GetSX3Cache("VOK_TIPSER","X3_TAMANHO") },;	
		{"bValid", { || OA50300287_vld_cpo("VOK", "TIPO_SERVICO_ADITIVO") }},;
		{"cLookUp"  , "VOK" },;
		{"cTooltip" , STR0161 } ;//"Tipo Serviço Aditvo ?" 
	})
return oMd

/*/{Protheus.doc} OA50300014_Confirmar
	Salva os dados preenchidos na tela
	
	@type function
	@author Vinicius Gati
	@since 31/05/2019
/*/
static function OA50300014_Confirmar(oModel)
	Local nX := 1
	Local aGrpPecas := {}
	Local aMotivos := {}
	Local aMotsOfi := {}
	Local aArmas := {}
	Local aFiliais := {}
	Local jFil, jArm, jMot
	local aInGrpPec := {}
	local aInNNRs := {}
	Local oBase := oModel:GetModel("BASE")
	Local oDebug := oModel:GetModel("BASE_DEBUG")
	Local oJdprism := oModel:GetModel("BASE_JDPRISM")
	Local oGridPecas := oModel:GetModel("GRID_GRUPOS_DE_PECAS")
	Local oGridFiliais := oModel:GetModel("GRID_FILIAIS")
	Local oGridMotPec := oModel:GetModel("GRID_GRUPOS_DE_MOTIVOS_BALCAO")
	Local oGridOfiMotivo := oModel:GetModel("GRID_GRUPOS_DE_MOTIVOS_OFICINA")
	Local oGridArmas := oModel:GetModel("GRID_ARMAZENS")
	Local jJson := JsonObject():New()

	jJson["CFG_ACCOUNT"] := oBase:GetValue('CFG_ACCOUNT')
	jJson["CFG_ORI_ADC_PECAS"] := oBase:GetValue('CFG_ORI_ADC_PECAS')
	jJson["CFG_VIS_ESTOQUE"] := oBase:GetValue('CFG_VIS_ESTOQUE')
	jJson["CFG_LOCAL_ARQUIVOS"] := STRTRAN(oBase:GetValue('CFG_LOCAL_ARQUIVOS'), '//', '/')
	jJson["CFG_LOCAL_ARQUIVOS_IMPORTAR"] := STRTRAN(oBase:GetValue('CFG_LOCAL_ARQUIVOS_IMPORTAR'), '//', '/')
	jJson["CFG_DELTA_LIBERADO"] := oBase:GetValue('CFG_DELTA_LIBERADO')
	jJson["DEBUGANDO"] := oDebug:GetValue('DEBUGANDO')
	jJson["LISTA_FILIAIS_DEBUG"] := oDebug:GetValue('LISTA_FILIAIS_DEBUG')
	jJson["LISTA_SEGMENTOS_DEBUG"] := oDebug:GetValue('LISTA_SEGMENTOS_DEBUG')
	jJson["LISTA_PECAS_DEBUG"] := oDebug:GetValue('LISTA_PECAS_DEBUG')
	jJson["FORNECEDOR_CODIGO"] := oJdprism:GetValue('FORNCOD')
	jJson["FORNECEDOR_LOJA"] := oJdprism:GetValue('FORNLOJA')
	jJson["CONDPAG_PEDIDOS"] := oJdprism:GetValue('CONDPAG_PEDIDOS')
	If cPaisLoc == "BRA"
		jJson["OPERACAO_TRANSFER"] := oJdprism:GetValue('OPERACAO_TRANSFER')
	Else // Demais paises
		jJson["TES_ENTRADA_TRANSFER"] := oJdprism:GetValue('TES_ENTRADA_TRANSFER')
		jJson["TES_SAIDA_TRANSFER"] := oJdprism:GetValue('TES_SAIDA_TRANSFER')
	EndIf	
	jJson["FORMULA_TRANSFER"] := oJdprism:GetValue('FORMULA_TRANSFER')
	jJson["FORMULA_ORDER"] := oJdprism:GetValue('FORMULA_ORDER')

	for nX := 1 to oGridPecas:Length()
		oGridPecas:GoLine(nX)
		if ! oGridPecas:IsDeleted()
			jFil := JsonObject():New()
			jFil['GRUPO_PECA'] := oGridPecas:GetValue('GRUPO_PECA')
			jFil['GRUPO_DESCRICAO'] := oGridPecas:GetValue('GRUPO_DESCRICAO')
			aadd(aInGrpPec, "'" + oGridPecas:GetValue('GRUPO_PECA') + "'")
			AADD(aGrpPecas, jFil)
		endif
	next
	jJson["GRUPOS_DE_PECAS"] := aGrpPecas

	OA50300104_AtualizaBMVAIDPM(aInGrpPec)

	for nX := 1 to oGridFiliais:Length()
		oGridFiliais:GoLine(nX)
		if ! oGridFiliais:IsDeleted()
			jFil := JsonObject():New()
			jFil["FILIAL"] := oGridFiliais:GetValue('FILIAL')
			jFil["SEGMENTO"] := oGridFiliais:GetValue('SEGMENTO')
			jFil["PRINCIPAL"] := oGridFiliais:GetValue('PRINCIPAL')
			jFil["DEALER_CODE"] := oGridFiliais:GetValue('DEALER_CODE')
			jFil["EMAIL_ORIGEM_RPM"] := oGridFiliais:GetValue("EMAIL_ORIGEM_RPM")
			jFil["EMAIL_DESTINATARIO_RPM"] := oGridFiliais:GetValue("EMAIL_DESTINATARIO_RPM")
			aadd(aFiliais, jFil)
		endif
	Next
	jJson["FILIAIS"] := aFiliais

	for nX := 1 to oGridArmas:Length()
		oGridArmas:GoLine(nX)
		if ! oGridArmas:IsDeleted()
			jArm := JsonObject():New()
			jArm["CODIGO_ARMAZEM"] := oGridArmas:GetValue('CODIGO_ARMAZEM')
			jArm["FILIAL"] := oGridArmas:GetValue('FILIAL')
			jArm["DESCRICAO"] := oGridArmas:GetValue('DESCRICAO')
			jArm["SEGMENTO"] := oGridArmas:GetValue('SEGMENTO')
			jArm["ARMAZEM_DE_VENDA"] := oGridArmas:GetValue('ARMAZEM_DE_VENDA')
			jArm["CODIGO_JD_ARMAZEM"] := oGridArmas:GetValue('CODIGO_JD_ARMAZEM')
			jArm["PERMITE_TRANSFERENCIAS"] := oGridArmas:GetValue('PERMITE_TRANSFERENCIAS')
			jArm["PRINCIPAL"] := iif(! empty(oGridArmas:GetValue('PRINCIPAL')), oGridArmas:GetValue('PRINCIPAL'), space(GetSX3Cache("NNR_CODIGO","X3_TAMANHO")))
			if jArm["ARMAZEM_DE_VENDA"] == "1"
				aadd(aInNNRs, "'" + oGridArmas:GetValue("CODIGO_ARMAZEM") + "'")
			endif
			aadd(aArmas, jArm)
		endif
	next
	jJson["ARMAZENS"] := aArmas

	OA50300094_AtualizaNNRVDADMS(aInNNRs)

	for nX := 1 to oGridMotPec:Length()
		oGridMotPec:GoLine(nX)
		if ! oGridMotPec:IsDeleted()
			jMot := JsonObject():New()
			jMot["MOTIVO"] := oGridMotPec:GetValue('MOTIVO')
			jMot["MOTIVO_DESCRICAO"] := oGridMotPec:GetValue('MOTIVO_DESCRICAO')
			aadd(aMotivos, jMot)
		endif
	next
	jJson["MOTIVOS_BALCAO"] := aMotivos

	for nX := 1 to oGridOfiMotivo:Length()
		oGridOfiMotivo:GoLine(nX)
		if ! oGridOfiMotivo:IsDeleted()
			jMot := JsonObject():New()
			jMot["MOTIVO"] := oGridOfiMotivo:GetValue('MOTIVO')
			jMot["MOTIVO_DESCRICAO"] := oGridOfiMotivo:GetValue('MOTIVO_DESCRICAO')
			aadd(aMotsOfi, jMot)
		endif
	next
	jJson["MOTIVOS_OFICINA"] := aMotsOfi

	jJson["PARAMETRO_GARANTIA"] := OA50300267_salvar_dados_garantia()

	oConfig:Save(jJson)
return .t.

/*/{Protheus.doc} Load03Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 04/06/2024
/*/
static function Load03Dados()
	local aData := {}
	local nX := 1
	local aDados := oConfig:GetValue("GRUPOS_DE_PECAS", {})

	for nX := 1 to len(aDados)
		aadd(aData, {;
			nX,;
			{; 
				aDados[nX]['GRUPO_PECA'],;
				aDados[nX]['GRUPO_DESCRICAO'],;
				" ";
			};
		})
	next
return aData

/*/{Protheus.doc} Load04Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 04/06/2024
/*/
static function Load04Dados()
	local aData := {}
	local nX := 1
	local aDados := oConfig:GetValue("MOTIVOS_BALCAO", {})

	for nX := 1 to len(aDados)
		aadd(aData, {;
			nX,;
			{; 
				aDados[nX]['MOTIVO'],;
				aDados[nX]['MOTIVO_DESCRICAO'],;
				" ";
			};
		})
	next
return aData

/*/{Protheus.doc} Load05Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 05/06/2024
/*/
static function Load05Dados()
	local aData := {}
	local nX := 1
	local aDados := oConfig:GetValue("MOTIVOS_OFICINA", {})

	for nX := 1 to len(aDados)
		aadd(aData, {;
			nX,;
			{; 
				aDados[nX]['MOTIVO'],;
				aDados[nX]['MOTIVO_DESCRICAO'],;
				" ";
			};
		})
	next
return aData

/*/{Protheus.doc} Load06Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 05/06/2024
/*/
static function Load06Dados()
	local aData := {}
	local nX := 1
	local aDados := oConfig:GetValue("FILIAIS", {})

	for nX := 1 to len(aDados)
		aadd(aData, {;
			nX,;
			{; 
				aDados[nX]['FILIAL'],;
				aDados[nX]['PRINCIPAL'],;
				aDados[nX]['SEGMENTO'],;
				aDados[nX]['DEALER_CODE'],;
				aDados[nX]['EMAIL_ORIGEM_RPM'],;
				aDados[nX]['EMAIL_DESTINATARIO_RPM'],;
				" ";
			};
		})
	next
return aData

/*/{Protheus.doc} Load07Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 05/06/2024
/*/
static function Load07Dados()
	local aData := {}
	local nX := 1
	local aDados := oConfig:GetValue("ARMAZENS", {})

	for nX := 1 to len(aDados)
		aadd(aData, {;
			nX,;
			{; 
				aDados[nX]['CODIGO_ARMAZEM'],;
				aDados[nX]['DESCRICAO'],;
				aDados[nX]['FILIAL'],;
				aDados[nX]['SEGMENTO'],;
				aDados[nX]['ARMAZEM_DE_VENDA'],;
				iif(empty(aDados[nX]['PERMITE_TRANSFERENCIAS']),space(1), aDados[nX]['PERMITE_TRANSFERENCIAS']),;
				aDados[nX]['CODIGO_JD_ARMAZEM'],;
				iif(empty(aDados[nX]['PRINCIPAL']),space(GetSX3Cache("NNR_CODIGO","X3_TAMANHO")), aDados[nX]['PRINCIPAL']),;
				" ";
			};
		})
	next
return aData


/*/{Protheus.doc} Load08Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 05/06/2024
/*/
static function Load08Dados()
return {;
	{;
		oConfig:GetValue("DEBUGANDO", "0"),;
		oConfig:GetValue("LISTA_PECAS_DEBUG", space(254)),;
		oConfig:GetValue("LISTA_FILIAIS_DEBUG", space(254)),;
		oConfig:GetValue("LISTA_SEGMENTOS_DEBUG", space(254)) ;
	}, 0;
}

/*/{Protheus.doc} Load09Dados
	default values for jdprism data fields
	
	@type function
	@author Vinicius Gati
	@since 05/06/2024
/*/
static function Load09Dados()
Local aRet := {}
If cPaisLoc == "BRA"
	aRet := {;
		{;
		oConfig:GetValue("FORNECEDOR_CODIGO", space(GetSX3Cache("A2_COD", "X3_TAMANHO"))),;
		oConfig:GetValue("FORNECEDOR_LOJA"  , space(GetSX3Cache("A2_LOJA", "X3_TAMANHO"))),;
		oConfig:GetValue("CONDPAG_PEDIDOS"  , space(GetSX3Cache("E4_CODIGO", "X3_TAMANHO"))),;
		oConfig:GetValue("OPERACAO_TRANSFER", space(GetSX3Cache("VS3_OPER", "X3_TAMANHO"))),;
		oConfig:GetValue("FORMULA_TRANSFER" , space(GetSX3Cache("VS3_FORMUL", "X3_TAMANHO"))),;
		oConfig:GetValue("FORMULA_ORDER"    , space(GetSX3Cache("VS3_FORMUL", "X3_TAMANHO"))) ;
		}, 0;
	}
Else // Demais paises
	aRet := {;
		{;
		oConfig:GetValue("FORNECEDOR_CODIGO", space(GetSX3Cache("A2_COD", "X3_TAMANHO"))),;
		oConfig:GetValue("FORNECEDOR_LOJA"  , space(GetSX3Cache("A2_LOJA", "X3_TAMANHO"))),;
		oConfig:GetValue("CONDPAG_PEDIDOS"     , space(GetSX3Cache("E4_CODIGO", "X3_TAMANHO"))),;
		oConfig:GetValue("TES_ENTRADA_TRANSFER", space(GetSX3Cache("VS3_CODTES", "X3_TAMANHO"))),;
		oConfig:GetValue("TES_SAIDA_TRANSFER", space(GetSX3Cache("VS3_CODTES", "X3_TAMANHO"))),;
		oConfig:GetValue("FORMULA_TRANSFER" , space(GetSX3Cache("VS3_FORMUL", "X3_TAMANHO"))), ;
		oConfig:GetValue("FORMULA_ORDER" , space(GetSX3Cache("VS3_FORMUL", "X3_TAMANHO"))) ;
		}, 0;
	}
EndIf
return aRet


static function Load10Dados()
	local aData := {}
	local nX := 1
	local oSched := DMS_DPMSched():New(cStaticConta)
	
	oSched:UpdateGers()
	aGers := oSched:aGeracoes
	for nX := 1 to len(aGers)
		oGer := aGers[nX]
		aadd(aData, {;
			nX,;
			{; 
				oGer:cTipo,;
				oGer:cDia + " " + oGer:cHora,;
				" ";
			};
		})
	next
return aData

static function Load12Dados()
	Local aRet := {}
	aRet :=  {;
		{;
		oConfig:GetValue("DEALER_CODE_FORM",          SPACE(6)									   ),; //00
		oConfig:GetValue("TT_PECA_CLIENTE",           SPACE(GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"))),; //01
		oConfig:GetValue("TT_SERVICO_CLIENTE",        SPACE(GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"))),; //02	
		oConfig:GetValue("GRP_SERVICO_CLIENTE",       SPACE(GetSX3Cache("VOS_CODGRU","X3_TAMANHO"))),; //03	
		oConfig:GetValue("COD_SERVICO_CLIENTE",       SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //04	
		oConfig:GetValue("TIPO_SERVICO_CLIENTE",      SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //05	
		oConfig:GetValue("GRP_SERVICO_CRED_CLIENTE",  SPACE(GetSX3Cache("VOS_CODGRU","X3_TAMANHO"))),; //06	
		oConfig:GetValue("COD_SERVICO_CRED_CLIENTE",  SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //07	
		oConfig:GetValue("TIPO_SERVICO_CRED_CLI",     SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //08	
		oConfig:GetValue("TT_PECA_INTERNO",           SPACE(GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"))),; //09	
		oConfig:GetValue("TT_SERVICO_INTERNO",        SPACE(GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"))),; //10	
		oConfig:GetValue("GRP_SERVICO_INTERNO",       SPACE(GetSX3Cache("VOS_CODGRU","X3_TAMANHO"))),; //11	
		oConfig:GetValue("COD_SERVICO_INTERNO",       SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //12	
		oConfig:GetValue("TIPO_SERVICO_INTERNO",      SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //13	
		oConfig:GetValue("GRP_SERVICO_CRED_INTERNO",  SPACE(GetSX3Cache("VOS_CODGRU","X3_TAMANHO"))),; //14	
		oConfig:GetValue("COD_SERVICO_CRED_INTERNO",  SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //15	
		oConfig:GetValue("TIPO_SERVICO_CRED_INTERNO", SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //16	
		oConfig:GetValue("MOT_CANCELAMENTO",          SPACE(GetSX3Cache("VS0_CODMOT","X3_TAMANHO"))),; //17	
		oConfig:GetValue("OPERACAO",                  SPACE(2)),;									   //18
		oConfig:GetValue("TES_ESPECIAL",              SPACE(GetSX3Cache("F4_CODIGO","X3_TAMANHO"))),;  //19	
		oConfig:GetValue("GRP_SERVICO_DESLOC",        SPACE(GetSX3Cache("VOS_CODGRU","X3_TAMANHO"))),; //20	
		oConfig:GetValue("COD_SERVICO_DESLOC",        SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //21	
		oConfig:GetValue("TIPO_SERVICO_DESLOC",       SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //22	
		oConfig:GetValue("TT_SERVICO_REVISAO",        SPACE(GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"))),; //23	
		oConfig:GetValue("GRP_SERVICO_REVISAO",       SPACE(GetSX3Cache("VOS_CODGRU","X3_TAMANHO"))),; //24	
		oConfig:GetValue("COD_SECAO_REVISAO",         SPACE(GetSX3Cache("VOD_CODSEC","X3_TAMANHO"))),; //25	
		oConfig:GetValue("DEPTO_GARANTIA_REVISAO",    SPACE(1)),;									   //26
		oConfig:GetValue("TIPO_SERVICO_REVISAO",      SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //27	
		oConfig:GetValue("TT_PECAS_PMP",              SPACE(GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"))),; //28	
		oConfig:GetValue("TT_SERVICO_PMP",            SPACE(GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"))),; //29	
		oConfig:GetValue("GRP_SERVICO_PMP",           SPACE(GetSX3Cache("VOS_CODGRU","X3_TAMANHO"))),; //30	
		oConfig:GetValue("COD_SECAO_PMP",             SPACE(GetSX3Cache("VOD_CODSEC","X3_TAMANHO"))),; //31	
		oConfig:GetValue("DEPTO_GARANTIA_PMP",        SPACE(1)),;	 								   //32
		oConfig:GetValue("TIPO_SERVICO_PMP",          SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //33	
		oConfig:GetValue("COD_SERVICO_REEMB_PMP",     SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //34	
		oConfig:GetValue("COD_SERVICO_PMP",           SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //35	
		oConfig:GetValue("TIPO_VEIC_TURF",            SPACE(30)),;									   //36
		oConfig:GetValue("TIPO_VEIC_GOLF",            SPACE(30)),;	 								   //37
		oConfig:GetValue("CONVERSAO_UNID_MED",        SPACE(30)),;	 								   //38
		oConfig:GetValue("MENS_NOTA_FISCAL",          SPACE(1)),;		 							   //39
		oConfig:GetValue("MENS_PADRAO",               SPACE(GetSX3Cache("M4_CODIGO","X3_TAMANHO"))),;  //40	
		oConfig:GetValue("TIPO_SERVICO_GRATUITO", 	  SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO"))),; //41	
		oConfig:GetValue("OPERACAO_ESPECIAL_INTERNA", SPACE(2)),;	 								   //42
		oConfig:GetValue("TES_ESPECIAL_INTERNA",      SPACE(GetSX3Cache("F4_CODIGO","X3_TAMANHO"))),;  //43			
		oConfig:GetValue("COD_ITEM_ADITIVO",          SPACE(GetSX3Cache("B1_COD","X3_TAMANHO"))),;     //44			
		oConfig:GetValue("TES_ITEM_ADITIVO",          SPACE(GetSX3Cache("F4_CODIGO","X3_TAMANHO"))),;  //45			
		oConfig:GetValue("GRP_SERVICO_ADITIVO",       SPACE(GetSX3Cache("VO6_GRUSER","X3_TAMANHO"))),; //46			
		oConfig:GetValue("COD_SERVICO_ADITIVO",       SPACE(GetSX3Cache("VO6_CODSER","X3_TAMANHO"))),; //47			
		oConfig:GetValue("TIPO_SERVICO_ADITIVO",      SPACE(GetSX3Cache("VOK_TIPSER","X3_TAMANHO")));  //48
		}, 0;
	}
return aRet

/*/{Protheus.doc} OA50300034_SelecionaArquivo

    @author Vinicius Gati
    @since  07/06/2024
/*/
function  OA50300034_SelecionaArquivo(oModel, cField, xValue, xValueAntigo)
	Local oView := FWViewActive()

	cPath := cGetFile('', STR0048, 1, '', .F., GETF_RETDIRECTORY) //"Selecione o caminho"
	If Empty(cPath)
		Return
	Endif
	oModel:LoadValue(cField, cPath)
	oView:Refresh()
return .t.

/*/{Protheus.doc} OA50300044_AtualizaPorGrupo
	Atualiza a descrição do grupo selecionado

    @author Vinicius Gati
    @since  07/06/2024
/*/
function OA50300044_AtualizaPorGrupo(oModel, cField, xValue, xValueAntigo)
	Local oView := FWViewActive()
	Local cDesc := FM_SQL("SELECT BM_DESC FROM "+RetSqlName("SBM")+" WHERE BM_FILIAL = '"+xFilial('SBM')+"' and BM_GRUPO = '"+cValToChar(xValue)+"' and D_E_L_E_T_ = ' ' ")
	if ! Empty(cDesc)
		oModel:LoadValue("GRUPO_DESCRICAO", cDesc, .T.)
	else
		oModel:LoadValue("GRUPO_DESCRICAO", STR0049, .T.) //"INVALIDO"
	endif
	oView:Refresh()
Return .t.

/*/{Protheus.doc} OA50300054_AtualizaDescNNR
	Atualiza a descrição do local de estoque selecionado

    @author Vinicius Gati
    @since  07/06/2024
/*/
function OA50300054_AtualizaDescNNR(oModel, cField, xValue, xValueAntigo)
	Local oView := FWViewActive()
	Local cDesc := FM_SQL("SELECT NNR_DESCRI FROM "+RetSqlName("NNR")+" WHERE NNR_FILIAL = '"+xFilial('NNR')+"' and NNR_CODIGO = '"+cValToChar(xValue)+"' and D_E_L_E_T_ = ' ' ")
	if ! Empty(cDesc)
		oModel:LoadValue("DESCRICAO", cValToChar(cDesc))
	else
		oModel:LoadValue("DESCRICAO", STR0049) //"INVALIDO"
	endif
	oView:Refresh()
Return .t.

/*/{Protheus.doc} OA50300064_MotivoBalcao
	Atualiza a descrição do motivo selecionado

    @author Vinicius Gati
    @since  07/06/2024
/*/
function OA50300064_MotivoBalcao(oModel, cField, xValue, xValueAntigo)
	Local cAssuntoB := "000004" // motivo da venda perdida balcão
	Local oView := FWViewActive()
	Local cDesc := FM_SQL("SELECT VS0_DESMOT FROM "+RetSqlName("VS0")+" WHERE VS0_FILIAL = '"+xFilial('VS0')+"' and VS0_TIPASS = '"+cAssuntoB+"' and VS0_CODMOT = '"+cValToChar(xValue)+"' and D_E_L_E_T_ = ' ' ")
	if ! Empty(cDesc)
		oModel:LoadValue("MOTIVO_DESCRICAO", cValToChar(cDesc), .T.)
	else
		oModel:LoadValue("MOTIVO_DESCRICAO", STR0049, .T.)
	endif
	oView:Refresh()
Return .t.

/*/{Protheus.doc} OA50300074_ValidaOpcao
	Valida se o valor atual esta nas opcoes disponiveis

	@type method
	@author Vinicius Gati
	@since 10/06/2024
/*/
function OA50300074_ValidaOpcao(oModel, cField, xValue, xValueAntigo, cOpcoesDisponiveis)
	Local aOpcoes := StrTokArr(cOpcoesDisponiveis,",")
	local nX := 1

	for nX := 1 to len(aOpcoes)
		if xValue == aOpcoes[nX]
			return .t.
		endif
	next
Return .f.

/*/{Protheus.doc} OA50300084_OpcoesFiliais()
	Retorna as filiais disponiveis para o usuario

	@type method
	@author Vinicius Gati
	@since 10/06/2024
/*/
Function OA50300084_OpcoesFiliais()
	local aFils := fwAllFilial(,,,.f.)
	local oArrHelper := DMS_ArrayHelper():New()
Return oArrHelper:join(aFils, ",")

/*/{Protheus.doc} OA50300094_AtualizaNNRVDADMS()
	Vai atualizar o campo nnr_vdadms para manter compatibilidade

	@type method
	@author Vinicius Gati
	@since 10/06/2024
/*/
Function OA50300094_AtualizaNNRVDADMS(aInNNRs)
	local oArrHelper := DMS_ArrayHelper():New()
	local cInNNRs := oArrHelper:Join(aInNNRs, ",")
	TCSqlExec(" UPDATE "+RetSqlName("NNR")+" SET NNR_VDADMS = '0' where NNR_FILIAL = '"+xFilial("NNR")+"' and NNR_CODIGO not in (" + cInNNRs + ") and D_E_L_E_T_ = ' ' ")
	TCSqlExec(" UPDATE "+RetSqlName("NNR")+" SET NNR_VDADMS = '1' where NNR_FILIAL = '"+xFilial("NNR")+"' and NNR_CODIGO in     (" + cInNNRs + ") and D_E_L_E_T_ = ' ' ")
Return

/*/{Protheus.doc} OA50300104_AtualizaBMVAIDPM()
	Vai atualizar o campo bm_vaidpm para manter compatibilidade

	@type method
	@param aInGrpPec array de grupos de pecas
	@param lUsaBMVAIDPM booleano para usar ou nao o campo adicionado para que seja possivel fazer testes unitarios da funcao
	@author Vinicius Gati
	@since 10/06/2024
/*/
Function OA50300104_AtualizaBMVAIDPM(aInGrpPec, lUsaBMVAIDPM)
	local oArrHelper := DMS_ArrayHelper():New()
	local cInPecas := oArrHelper:Join(aInGrpPec, ",")
	default lUsaBMVAIDPM := SBM->(FieldPos("BM_VAIDPM"))
	if lUsaBMVAIDPM > 0
		TCSqlExec(" UPDATE "+RetSqlName("SBM")+" SET BM_VAIDPM = '0' where BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO not in (" + cInPecas + ") and D_E_L_E_T_ = ' ' ")
		TCSqlExec(" UPDATE "+RetSqlName("SBM")+" SET BM_VAIDPM = '1' where BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO in     (" + cInPecas + ") and D_E_L_E_T_ = ' ' ")
	endif
Return

/*/{Protheus.doc} OA50300114_ValidaPrincipal
	Valida se tem mais de 1 principal por filial para dar erro na tela

	@type  Function
	@author Vinicius Gati
	@since 26/09/2024
/*/
Function OA50300114_ValidaPrincipal(oModel, cField, xValue, xValueAntigo)
	local nX := 1
	local oGridFiliais := oModel
	local nQtdPricipal := 0
	local cFlalSel := oGridFiliais:GetValue("FILIAL")
	local nLineStart := oGridFiliais:GetLine()

	for nX := 1 to oGridFiliais:Length()
		oGridFiliais:GoLine(nX)
		if ! oGridFiliais:IsDeleted()
			if oGridFiliais:GetValue('PRINCIPAL') == "1" .and. oGridFiliais:GetValue("FILIAL") == cFlalSel
				nQtdPricipal++
			endif
		endif
	Next

	oGridFiliais:GoLine(nLineStart)
Return nQtdPricipal <= 1


/*/{Protheus.doc} OA50300124_MotivoOficina
	Traz desc do motivo oficina

	@type method
	@author Vinicius Gati
	@since 01/10/2024
/*/
Function OA50300124_MotivoOficina(oModel, cField, xValue, xValueAntigo)
	Local cMotOfi := "000002"
	Local oView := FWViewActive()
	Local cDesc := FM_SQL("SELECT VS0_DESMOT FROM "+RetSqlName("VS0")+" WHERE VS0_FILIAL = '"+xFilial('VS0')+"' and VS0_TIPASS = '"+cMotOfi+"' and VS0_CODMOT = '"+cValToChar(xValue)+"' and D_E_L_E_T_ = ' ' ")
	if ! Empty(cDesc)
		oModel:LoadValue("MOTIVO_DESCRICAO", cValToChar(cDesc), .T.)
	else
		oModel:LoadValue("MOTIVO_DESCRICAO", STR0049, .T.)
	endif
	oView:Refresh()
Return .t.

/*/{Protheus.doc} OA50300134_ImportaArquivos
	Importa arquivos disponíveis na pasta configurada

	@type method
	@author Vinicius Gati
	@since 04/10/2024
/*/
Function OA50300134_ImportaArquivos()
	local oConf := DMS_DPMConfig():New("SCHEDULER", cStaticConta)
	OD35074_ImportaArquivos(oConf)
	MsgInfo(STR0080)//"Arquivos pendentes importados")
Return .t.


/*/{Protheus.doc} OA50300144_SimularScheduler
	Rodar o ofinjd35 simulando scheduler até ser cancelada a tela

	@type method
	@author Vinicius Gati
	@since 04/10/2024
/*/
Function OA50300144_SimularScheduler()
	if MsgNoYes(STR0077, STR0078) //"Este recurso vai gravar o parametro MV_MILDBG, deseja continuar?", "Atenção")
		PUTMV("MV_MILDBG","OFINJD35SCH")
		StartJob("OFINJD35", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), __cUserId }) //  usa grupo
	endif
Return 

/*/{Protheus.doc} OA50300154_CancelarSimulacao
	Grava o parametro que fecha a simulacao do OFINJD35

	@type method
	@author Vinicius Gati
	@since 04/10/2024
/*/
Function OA50300154_CancelarSimulacao()
	Local oLogger := DMS_Logger():New()
	PUTMV("MV_MILDBG","")
	oLogger:LogToTable({; // salva arquivo já importado para não fazer 2 vezes pro mesmo grupo
		{'VQL_AGROUP' , "OFINJD35" },;
		{'VQL_TIPO'   , 'SCH_STOP' },;
		{'VQL_DADOS'  , 'SIMULADO VIA OFIA503' } ;
	})
	MsgInfo(STR0079)//"Simulação irá fechar em breve")
Return

/*/{Protheus.doc} OA50300164_TudoOkArms
	Validação para o grid de armazens, a ideia é dar mensagens de validação ao salvar

	@type method
	@author Vinicius Gati
	@since 11/08/2025
/*/
Function OA50300164_TudoOkArms(oGridModel, oArrHelper)
	local aGrouped
	local aArmData     := {}
	local nX           := 1
	local nY           := 1
	default oArrHelper := DMS_ArrayHelper():New()

	for nX := 1 to oGridModel:Length()
		oGridModel:GoLine(nX)
		aadd(aArmData, {;
			oGridModel:GetValue('CODIGO_ARMAZEM'),;
			oGridModel:GetValue('FILIAL'),;
			oGridModel:GetValue('DESCRICAO'),;
			oGridModel:GetValue('SEGMENTO'),;
			oGridModel:GetValue('ARMAZEM_DE_VENDA'),;
			oGridModel:GetValue('CODIGO_JD_ARMAZEM'),;
			oGridModel:GetValue('PERMITE_TRANSFERENCIAS'),;
			iif(! empty(oGridModel:GetValue('PRINCIPAL')), oGridModel:GetValue('PRINCIPAL'), space(GetSX3Cache("NNR_CODIGO","X3_TAMANHO"))),;
		})
	next


	// validar se todos os armazens iguais tem pelo menos 1 principal
	aGrouped := oArrHelper:GroupBy(aArmData, 6) // CODIGO_JD_ARMAZEM
	aGrouped := oArrHelper:Select(aGrouped, {|aDados| len(aDados[2]) > 1 }) // somente os que tem mais de 1 armazem agrupando
	for nX := 1 to len(aGrouped)
		aData := aGrouped[nX]
		aArmsGrp := aData[2]
		lHasPrincipal := .F.

		for nY := 1 to len(aArmsGrp)
			if aArmsGrp[nY, 8] == "1"
				lHasPrincipal := .T.
				exit
			endif
		next

		if ! lHasPrincipal
			MsgInfo(STR0097 + aData[1]) // "Nenhum armazém principal para grupo de armazéns com código john deere:"
			return .F.
		endif
	next

return .T.
/*/{Protheus.doc} OA50300162_ValidaSegmentoDuplicado
	Valida se o segemtno não tem duplicado para mesma
	filial, tanto na GRID como nas outras CONTAS

	@type method
	@author Bruno Forcato
	@since 26/09/2025
/*/
Function OA50300162_ValidaSegmentoDuplicado(oModel, cValue)
	local oGridFiliais := oModel
	local cFlalSel     := oGridFiliais:GetValue("FILIAL")
	local nLinhaAtual  := oGridFiliais:GetLine()
	local nIdx

	// Verifica duplicados no grid (sem considerar a linha atual)
	for nIdx := 1 to oGridFiliais:Length()
		oGridFiliais:GoLine(nIdx)

		if !oGridFiliais:IsDeleted() .and. nIdx <> nLinhaAtual
			if oGridFiliais:GetValue("SEGMENTO") == cValue .and. ;
				oGridFiliais:GetValue("FILIAL")  == cFlalSel
				FMX_HELP("RPM013", STR0098) // Essa conta já possui segmento com essa filial
				oGridFiliais:GoLine(nLinhaAtual)
				return .f.
			endif
		endif
	next

	// Se não encontrou no grid, valida contra regra externa
	if !oConfig:VerificaSegmentoDuplicado(cFlalSel, cValue)
		FMX_HELP("RPM013", STR0099) // Outra conta já possui esse segmento com essa filial
		oGridFiliais:GoLine(nLinhaAtual)
		return .f.
	endif

	// Volta pra linha atual, sem isso ele traz problemas
	oGridFiliais:GoLine(nLinhaAtual)
return .t.

/*/{Protheus.doc} OA50300172_LimpaSegmentoAposFilial
	Limpa o campo de segmento apos selecionar a filial,
	para que não ocorra problemas com duplicidade

	@type method
	@author Bruno Forcato
	@since 26/09/2025
/*/
Function OA50300172_LimpaSegmentoAposFilial(oModel)
	local oGridFiliais := oModel
	oGridFiliais:ClearField("SEGMENTO")
return .t.

/*/{Protheus.doc} OA50300182_ValidaCodeDealerDuplicado
	Valida se o Code Dealer não tem duplicado para mesma
	filial, tanto na GRID como nas outras CONTAS

	@type method
	@author Bruno Forcato
	@since 28/09/2025
/*/
Function OA50300182_ValidaCodeDealerDuplicado(oModel, cValue)
	local oGridFiliais := oModel
	local nLinhaAtual  := oGridFiliais:GetLine()
	local nIdx

	// Verifica duplicados no grid (sem considerar a linha atual)
	for nIdx := 1 to oGridFiliais:Length()
		oGridFiliais:GoLine(nIdx)

		if !oGridFiliais:IsDeleted() .and. nIdx <> nLinhaAtual
			if oGridFiliais:GetValue("DEALER_CODE") == cValue
				FMX_HELP("RPM013", STR0100) // Essa conta já possui esse código John Deere
				oGridFiliais:GoLine(nLinhaAtual)
				return .f.
			endif
		endif
	next

	// Se não encontrou no grid, valida contra regra externa
	if !oConfig:VerificaDealerCodeDuplicado(cValue)
		FMX_HELP("RPM013", STR0101) // Outra conta já possui esse código John Deere
		oGridFiliais:GoLine(nLinhaAtual)
		return .f.
	endif

	// Volta pra linha atual, sem isso ele traz problemas
	oGridFiliais:GoLine(nLinhaAtual)
return .t.

/*/{Protheus.doc} OA50300192_abrirConfiguracaoOKTA
	Abre a configuração do OKTA para conta selecionada

	@type method
	@author Bruno Forcato
	@since 15/10/2025
/*/
Function OA50300192_abrirConfiguracaoOKTA()
	OFIA280(cStaticConta)
return .t.

/*/{Protheus.doc} OA50300204_GetSegmentos
	Retorna os segmentos disponiveis

	@type method
	@author Vinicius Gati
	@since 24/11/2025
/*/
Function OA50300204_GetSegmentos()
	cCbox := OFIOA560CB("097", 1)
	aCbox := StrTokArr(cCbox, ";")
Return aCbox

/*/{Protheus.doc} OA50300214_GetSegDesc
	Retorna a descrição do segmento

	@type method
	@author Vinicius Gati
	@since 24/11/2025
/*/
Function OA50300214_GetSegDesc(cVal)
return OFIOA560DS("097", alltrim(cVal))

/*/{Protheus.doc} OA50300227_cpo_tabela_temp
	Montando a matriz com os campos/tipo/tamanho da tabela temporaria
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Static Function OA50300227_cpo_tabela_temp()
	Local aVetCampos := {}
	Local nY         := 0

	for nY := 1 to len(aCacheCpoChv)		
		aadd(aVetCampos,{aCacheCpoChv[nY][1], aCacheCpoChv[nY][3], aCacheCpoChv[nY][4], aCacheCpoChv[nY][5] })
	Next

Return aVetCampos

/*/{Protheus.doc} OA50300237_carregar_dados_dealer_garantia
	Carrega os dados na grid das filiais/Codigo Dealer apos acionar/clicar folder de "Parametros de Garantia"

	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300237_carregar_dados_dealer_garantia(oModel)
	Local oGridFiliais    := oModel:GetModel("GRID_FILIAIS")
	Local oGridFilGarant  := oModel:GetModel("GRID_FILIAIS_GARANTIA")
	Local oView           := FWViewActive()   
	Local nX              := 0	
	
	oModel:GetModel("GRID_FILIAIS_GARANTIA"):SetNoInsertLine( .F. )
	oModel:GetModel("GRID_FILIAIS_GARANTIA"):SetNoUpdateLine( .F. )

	If oGridFilGarant:CanClearData()
		oGridFilGarant:ClearData()
	EndIf

	DbSelectArea(cAliasTmp1)
	(cAliasTmp1)->(DbSetOrder(1))

	for nX := 1 to oGridFiliais:Length()
		oGridFiliais:GoLine(nX)
		if ! oGridFiliais:IsDeleted()
			
			oGridFilGarant:AddLine()
			oGridFilGarant:LoadValue("FILIAL", oGridFiliais:GetValue('FILIAL'))			
			oGridFilGarant:LoadValue("SEGMENTO", oGridFiliais:GetValue('SEGMENTO'))
			oGridFilGarant:LoadValue("DEALER_CODE", oGridFiliais:GetValue('DEALER_CODE'))		
						
			If (cAliasTmp1)->(DbSeek(oGridFiliais:GetValue('DEALER_CODE')))
				// Se existir na tabela temporaia somente atualiza a filial e o segmento que pode ter sofrido alteração na folder "Filiais"						
				RecLock(cAliasTmp1, .F.)
				(cAliasTmp1)->GAR_FILIAL := oGridFiliais:GetValue('FILIAL')
				(cAliasTmp1)->GAR_SEGMEN := oGridFiliais:GetValue('SEGMENTO')
				(cAliasTmp1)->(MsUnlock())
			Else
				OA50300257_incluir_dados_tabela_temp(oGridFiliais:GetValue('FILIAL'), oGridFiliais:GetValue('SEGMENTO'), oGridFiliais:GetValue('DEALER_CODE'))			
			EndIf

		Endif
	Next

	oGridFiliais:GoLine(1)
	oGridFiliais:SetLine(1)
	oView:Refresh()

	oModel:GetModel("GRID_FILIAIS_GARANTIA"):SetNoInsertLine( .T. )
	oModel:GetModel("GRID_FILIAIS_GARANTIA"):SetNoUpdateLine( .T. )

Return 

/*/{Protheus.doc} OA50300257_incluir_dados_tabela_temp
	Validando dos dados existentes na tabela temporária e validando os dados da folder "Filiais", pois, possa ter incluido uma nova Filial x Dealer Code onde ainda não foi confirmado/gravado os regsitros.
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Static Function OA50300257_incluir_dados_tabela_temp(cFilTmp, cSegTemp, cDealerTmp)
	Local nY := 0
	
	RecLock(cAliasTmp1, .T.)
	(cAliasTmp1)->GAR_FILIAL := cFilTmp                                        
	(cAliasTmp1)->GAR_SEGMEN := cSegTemp                                       
	(cAliasTmp1)->GAR_DEACOD := cDealerTmp   
	for nY := 1 to len(aCacheCpoChv)
		if ! aCacheCpoChv[nY][1] $ ("GAR_FILIAL/GAR_SEGMEN/GAR_DEACOD")
			(cAliasTmp1)->&(aCacheCpoChv[nY][1]) := SPACE(aCacheCpoChv[nY][4])
		EndIf
	Next		                                  	
	(cAliasTmp1)->(MsUnlock())

Return

/*/{Protheus.doc} OA50300267_salvar_dados_garantia
	Preparando os dados no objeto para gravar a VRN
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Static Function OA50300267_salvar_dados_garantia()
	Local jGarantia := Nil
	Local aGarantia := {}
	Local nY        := 0

	DbSelectArea(cAliasTmp1)
	(cAliasTmp1)->(DBGoTop())
	(cAliasTmp1)->(DbSetOrder(1))
	While ! (cAliasTmp1)->(Eof())
		jGarantia := JsonObject():New()
		for nY := 1 to len(aCacheCpoChv)
			jGarantia[aCacheCpoChv[nY][2]] := (cAliasTmp1)->&(aCacheCpoChv[nY][1])
		Next			
		aadd(aGarantia, jGarantia)
		(cAliasTmp1)->(DBSkip())
	EndDO
	
Return aGarantia

/*/{Protheus.doc} OA50300277_carregar_tabela_temp
	Carregando os dados na tabela temporaria ao acessar a rotina
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Static Function OA50300277_carregar_tabela_temp()
	local nX      := 0
	local nY      := ""
	local aDados  := oConfig:GetValue("PARAMETRO_GARANTIA", {})
		
	for nX := 1 to len(aDados)
		RecLock(cAliasTmp1, .T.)
		for nY := 1 to len(aCacheCpoChv)
			(cAliasTmp1)->&(aCacheCpoChv[nY][1]) := aDados[nX][aCacheCpoChv[nY][2]]
		Next		
		(cAliasTmp1)->(MsUnlock())
	next
return 

/*/{Protheus.doc} OA50300287_vld_cpo
	Carregando os dados na tabela temporaria ao acessar a rotina
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300287_vld_cpo(cAliasCpo, cField, nIndice, lPergEsp, cTexto)
	Local lRet        := .F.
	Local oModel 	  := FwModelActive()
	Local oBaseGarant := oModel:GetModel("BASE_PARAMETROS_GARANTIA")
	Local oGridFilGar := oModel:GetModel("GRID_FILIAIS_GARANTIA")
	Local xValue      := oBaseGarant:GetValue(cField)
	Local cDealerCode := oGridFilGar:GetValue('DEALER_CODE')
	Local nPos        := 0
	
	Default cAliasCpo := ""
	Default nIndice   := 1
	Default lPergEsp  := .f.	
	Default cTexto    := ""

	IF !Empty(cAliasCpo)	
		DbSelectArea(cAliasCpo)
		If lPergEsp .AND. !Empty(xValue)
			lRet := .T.
			VOK->(dbSetOrder(1))
			If !VOK->(dbSeek(xFilial("VOK") + xValue))
				HELP(" ",1,"REGNOIS",,xValue,4,1)
				lRet := .F.
			Else
				If VOK->VOK_INCMOB <> "0"
					ShowHelpDlg("OA503VLDCPO", { STR0162 }) // "Informe um registro configurado como Mão de Obra Gratuita."
					lRet := .F.
				eNDiF
			EndIf
		Else
			DbSelectArea(cAliasCpo)	
			(cAliasCpo)->(DBGoTop())
			(cAliasCpo)->(dbSetOrder(nIndice))
			if (cAliasCpo)->(dbSeek(xFilial(cAliasCpo) + cTexto + xValue)) .OR. Empty(xValue) // Uilizando o ExistCPO estava apresentando duas mensagens. A mensagem padrão (ExistCPO) e a mensagem metodo AddField da classe OFDMSStruct da proprieade bValid.
				lRet := .T.	
			EndIF
			(cAliasCpo)->(DBCloseArea())
		EndIf
	Else
		lRet := .T.		
	EndIf

	IF lRet // Se Verdadeiro, grava a informação do campo na tabela temporaria
		nPos := aScan(aCacheCpoChv, {|x| x[2] == cField})

		DbSelectArea(cAliasTmp1)
		(cAliasTmp1)->(DbSetOrder(1))
		 If (cAliasTmp1)->(DbSeek(cDealerCode))
		 	RecLock(cAliasTmp1, .F.)
		 	(cAliasTmp1)->&(aCacheCpoChv[nPos][1]) := xValue		 	
		 	(cAliasTmp1)->(MsUnlock())
		 EndIf
	EndIf

Return lRet

Static Function OA50300297_array_campos_chaves()
	Local aCpoChaves := {}

	//                 CPO TAB TEMP   CHAVE (JSON)                 TIPO   TAMANHO                                 DECIMAL
	aAdd(aCpoChaves , {"GAR_FILIAL" , "FILIAL"                    , "C"  , GetSX3Cache("VOI_FILIAL","X3_TAMANHO"),  0    }) // "FILIAL"	
	aAdd(aCpoChaves , {"GAR_SEGMEN" , "SEGMENTO"                  , "C"  , 1                                     ,  0    }) // "SEGMENTO"
	aAdd(aCpoChaves , {"GAR_DEACOD" , "DEALER_CODE_FORM"          , "C"  , 6                                     ,  0    }) // "DEALER_CODE"
	aAdd(aCpoChaves , {"GAR_TTPECL" , "TT_PECA_CLIENTE"           , "C"  , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"),  0    }) // "TT_PECA_CLIENTE"
	aAdd(aCpoChaves , {"GAR_TTSRVC" , "TT_SERVICO_CLIENTE"        , "C"  , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"),  0    }) // "TT_SERVICO_CLIENTE"
	aAdd(aCpoChaves , {"GAR_GRPSVC" , "GRP_SERVICO_CLIENTE"       , "C"  , GetSX3Cache("VOS_CODGRU","X3_TAMANHO"),  0    }) // "GRP_SERVICO_CLIENTE"
	aAdd(aCpoChaves , {"GAR_CODSVC" , "COD_SERVICO_CLIENTE"       , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_CLIENTE"
	aAdd(aCpoChaves , {"GAR_TIPSVC" , "TIPO_SERVICO_CLIENTE"      , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_CLIENTE"
	aAdd(aCpoChaves , {"GAR_GPSVCR" , "GRP_SERVICO_CRED_CLIENTE"  , "C"  , GetSX3Cache("VOS_CODGRU","X3_TAMANHO"),  0    }) // "GRP_SERVICO_CRED_CLIENTE"
	aAdd(aCpoChaves , {"GAR_CSVCRC" , "COD_SERVICO_CRED_CLIENTE"  , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_CRED_CLIENTE"
	aAdd(aCpoChaves , {"GAR_TPSVCR" , "TIPO_SERVICO_CRED_CLI"     , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_CRED_CLI"
	aAdd(aCpoChaves , {"GAR_TTPEIN" , "TT_PECA_INTERNO"           , "C"  , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"),  0    }) // "TT_PECA_INTERNO"
	aAdd(aCpoChaves , {"GAR_TTSVIN" , "TT_SERVICO_INTERNO"        , "C"  , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"),  0    }) // "TT_SERVICO_INTERNO"
	aAdd(aCpoChaves , {"GAR_GPSVIN" , "GRP_SERVICO_INTERNO"       , "C"  , GetSX3Cache("VOS_CODGRU","X3_TAMANHO"),  0    }) // "GRP_SERVICO_INTERNO"
	aAdd(aCpoChaves , {"GAR_COSVIN" , "COD_SERVICO_INTERNO"       , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_INTERNO"
	aAdd(aCpoChaves , {"GAR_TPSVIN" , "TIPO_SERVICO_INTERNO"      , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_INTERNO"
	aAdd(aCpoChaves , {"GAR_GPSVCI" , "GRP_SERVICO_CRED_INTERNO"  , "C"  , GetSX3Cache("VOS_CODGRU","X3_TAMANHO"),  0    }) // "GRP_SERVICO_CRED_INTERNO"
	aAdd(aCpoChaves , {"GAR_COSVCI" , "COD_SERVICO_CRED_INTERNO"  , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_CRED_INTERNO"
	aAdd(aCpoChaves , {"GAR_TPSVCI" , "TIPO_SERVICO_CRED_INTERNO" , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_CRED_INTERNO"
	aAdd(aCpoChaves , {"GAR_MOTCAN" , "MOT_CANCELAMENTO"          , "C"  , GetSX3Cache("VS0_CODMOT","X3_TAMANHO"),  0    }) // "MOT_CANCELAMENTO"
	aAdd(aCpoChaves , {"GAR_OPERAC" , "OPERACAO"                  , "C"  , 2                                     ,  0    }) // "OPERACAO"
	aAdd(aCpoChaves , {"GAR_TESESP" , "TES_ESPECIAL"              , "C"  , GetSX3Cache("F4_CODIGO","X3_TAMANHO" ),  0    }) // "TES_ESPECIAL"
	aAdd(aCpoChaves , {"GAR_GPSRDE" , "GRP_SERVICO_DESLOC"        , "C"  , GetSX3Cache("VOS_CODGRU","X3_TAMANHO"),  0    }) // "GRP_SERVICO_DESLOC"
	aAdd(aCpoChaves , {"GAR_COSVDE" , "COD_SERVICO_DESLOC"        , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_DESLOC"
	aAdd(aCpoChaves , {"GAR_TPSVDE" , "TIPO_SERVICO_DESLOC"       , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_DESLOC"
	aAdd(aCpoChaves , {"GAR_TTSVRE" , "TT_SERVICO_REVISAO"        , "C"  , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"),  0    }) // "TT_SERVICO_REVISAO"
	aAdd(aCpoChaves , {"GAR_GPSVRE" , "GRP_SERVICO_REVISAO"       , "C"  , GetSX3Cache("VOS_CODGRU","X3_TAMANHO"),  0    }) // "GRP_SERVICO_REVISAO"
	aAdd(aCpoChaves , {"GAR_COSCRE" , "COD_SECAO_REVISAO"         , "C"  , GetSX3Cache("VOD_CODSEC","X3_TAMANHO"),  0    }) // "COD_SECAO_REVISAO"
	aAdd(aCpoChaves , {"GAR_DPTORE" , "DEPTO_GARANTIA_REVISAO"    , "C"  , 1                                     ,  0    }) // "DEPTO_GARANTIA_REVISAO"
	aAdd(aCpoChaves , {"GAR_TPSVRE" , "TIPO_SERVICO_REVISAO"      , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_REVISAO"
	aAdd(aCpoChaves , {"GAR_TTPEPM" , "TT_PECAS_PMP"              , "C"  , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"),  0    }) // "TT_PECAS_PMP"
	aAdd(aCpoChaves , {"GAR_TTSVPM" , "TT_SERVICO_PMP"            , "C"  , GetSX3Cache("VOI_TIPTEM","X3_TAMANHO"),  0    }) // "TT_SERVICO_PMP"
	aAdd(aCpoChaves , {"GAR_GPSVPM" , "GRP_SERVICO_PMP"           , "C"  , GetSX3Cache("VOS_CODGRU","X3_TAMANHO"),  0    }) // "GRP_SERVICO_PMP"
	aAdd(aCpoChaves , {"GAR_COSEPM" , "COD_SECAO_PMP"             , "C"  , GetSX3Cache("VOD_CODSEC","X3_TAMANHO"),  0    }) // "COD_SECAO_PMP"
	aAdd(aCpoChaves , {"GAR_DPTOPM" , "DEPTO_GARANTIA_PMP"        , "C"  , 1                                     ,  0    }) // "DEPTO_GARANTIA_PMP"
	aAdd(aCpoChaves , {"GAR_TPSVPM" , "TIPO_SERVICO_PMP"          , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_PMP"
	aAdd(aCpoChaves , {"GAR_COSRRE" , "COD_SERVICO_REEMB_PMP"     , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_REEMB_PMP"
	aAdd(aCpoChaves , {"GAR_COSVPM" , "COD_SERVICO_PMP"           , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_PMP"
	aAdd(aCpoChaves , {"GAR_TPVEIT" , "TIPO_VEIC_TURF"            , "C"  , 30                                    ,  0    }) // "TIPO_VEIC_TURF"	
	aAdd(aCpoChaves , {"GAR_TPVEIG" , "TIPO_VEIC_GOLF"            , "C"  , 30                                    ,  0    }) // "TIPO_VEIC_GOLF"
	aAdd(aCpoChaves , {"GAR_CONVUM" , "CONVERSAO_UNID_MED"        , "C"  , 30                                    ,  0    }) // "CONVERSAO_UNID_MED"	
	aAdd(aCpoChaves , {"GAR_MENSNF" , "MENS_NOTA_FISCAL"          , "C"  , 1                                     ,  0    }) // "MENS_NOTA_FISCAL"	
	aAdd(aCpoChaves , {"GAR_MENSPD" , "MENS_PADRAO"               , "C"  , GetSX3Cache("M4_CODIGO","X3_TAMANHO" ),  0    }) // "MENS_PADRAO"
	aAdd(aCpoChaves , {"GAR_TPSVGR" , "TIPO_SERVICO_GRATUITO"     , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_GRATUITO"
	aAdd(aCpoChaves , {"GAR_OPESPI" , "OPERACAO_ESPECIAL_INTERNA" , "C"  , 2                                     ,  0    }) // "OPERACAO_ESPECIAL_INTERNA"
	aAdd(aCpoChaves , {"GAR_TESESI" , "TES_ESPECIAL_INTERNA"      , "C"  , GetSX3Cache("F4_CODIGO","X3_TAMANHO") ,  0    }) // "TES_ESPECIAL_INTERNA"	
	aAdd(aCpoChaves , {"GAR_ITEADT" , "COD_ITEM_ADITIVO"          , "C"  , GetSX3Cache("B1_COD","X3_TAMANHO")    ,  0    }) // "COD_ITEM_ADITIVO"
	aAdd(aCpoChaves , {"GAR_TESADT" , "TES_ITEM_ADITIVO"          , "C"  , GetSX3Cache("F4_CODIGO","X3_TAMANHO") ,  0    }) // "TES_ITEM_ADITIVO"
	aAdd(aCpoChaves , {"GAR_GPSVAT" , "GRP_SERVICO_ADITIVO"       , "C"  , GetSX3Cache("VO6_GRUSER","X3_TAMANHO"),  0    }) // "GRP_SERVICO_ADITIVO"
	aAdd(aCpoChaves , {"GAR_SRVADT" , "COD_SERVICO_ADITIVO"       , "C"  , GetSX3Cache("VO6_CODSER","X3_TAMANHO"),  0    }) // "COD_SERVICO_ADITIVO"
	aAdd(aCpoChaves , {"GAR_TPADTI" , "TIPO_SERVICO_ADITIVO"      , "C"  , GetSX3Cache("VOK_TIPSER","X3_TAMANHO"),  0    }) // "TIPO_SERVICO_ADITIVO"

return aCpoChaves

/*/{Protheus.doc} OA50300317_change_line
	
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300317_change_line()
	Local oView	       := FWViewActive()
	local oModel       := FWModelActive()
	Local oGridFilGar  := oModel:GetModel("GRID_FILIAIS_GARANTIA")
	Local cDealerCode  := oGridFilGar:GetValue('DEALER_CODE')	
	Local nY           := 0
	Local oObjForm     := Nil
	Local oObjGrid     := Nil
	Local oDetBrws     := Nil
	Local oTGrid       := Nil
	
	if oView != Nil	 
		oObjGrid := oView:GetViewObject("GRID_FILIAIS_GARANTIA")[3]
		if oObjGrid != Nil	
			oDetBrws :=	oObjGrid:oBrowse
			oTGrid   := oDetBrws:oBrowse		
			oTGrid:SetSelectedRow(oTGrid:GetCursorPos()[1])
			oTGrid:setRowColor()
			oTGrid:setRowColor(oTGrid:GetCursorPos()[1], CLR_LIGHTGRAY )
			oTGrid:SetSelectionMode(1)
		EndIf		
	EndIf
			
	DbSelectArea(cAliasTmp1)
	(cAliasTmp1)->(DbSetOrder(1))
	If (cAliasTmp1)->(DbSeek(cDealerCode))
		for nY := 1 to len(aCacheCpoChv)
			if ! aCacheCpoChv[nY][1] $ ("GAR_FILIAL/GAR_SEGMEN")
				FWFldPut(aCacheCpoChv[nY][2], (cAliasTmp1)->&(aCacheCpoChv[nY][1]),,oModel,.F., .T.)
			EndIf
		Next	
	EndIf

	if oView != Nil	 	
		oObjForm := oView:GetViewObject("BASE_PARAMETROS_GARANTIA")[3]
		if oObjForm != Nil
			oObjForm:Refresh( .T. /* lEvalChanges */, .F. /* lGoTop */)
		EndIf
		EndIf

Return

/*/{Protheus.doc} OA50300327_change_folder
	
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300327_change_folder(cFolderID, nOldSheet, nSelSheet, oModel)
		
	If nSelSheet == 6 // ABA_PARAMETROS_GARANTIA
		cMotivo := "000002" 
		OA50300237_carregar_dados_dealer_garantia(oModel)
	else
		cMotivo := "000004"
	EndIf
	
Return

/*/{Protheus.doc} OA50300337_replicar
	
	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300337_replicar(oModel)
	Local oView	      := FWViewActive()
	Local aFolderAtv  := oView:GetFolderActive(oView:AFOLDERS[1][1],2 )
	Local oGridFilGar := oModel:GetModel("GRID_FILIAIS_GARANTIA")
	Local aPergs      := {}
	Local cTodos      := "2"
	Local cDealerDe   := oGridFilGar:GetValue('DEALER_CODE')
	Local cDealerPa   := Space(6)
	Local cCompMsg    := ""
	 
	If aFolderAtv[1] == 6 // ABA_PARAMETROS_GARANTIA
		aAdd(aPergs, {1, STR0163, cDealerDe, "", ".T.", "", ".F.", 80,  .F.}) // "Do Cod. Dealer:   "
		aAdd(aPergs, {2, STR0164, cTodos   , {"1="+STR0010+"","2="+STR0009}, 80, ".T.", .F.}) // "Replicar p/ Todos?"
		aAdd(aPergs, {1, STR0165, cDealerPa, "", "vazio() .or. OA50300347_valid_dealer()", "", ".T.", 80,  .F.}) // "Para Cod. Dealer: "

		If ParamBox(aPergs, STR0166)			
			if Empty(MV_PAR03) .AND. MV_PAR02 == "2"
				MsgInfo(STR0167) // "Codigo dealer não informado, verifique." 
			Else
				cCompMsg := IIF(MV_PAR02 == "1",STR0168, STR0169 + MV_PAR03+"?") // " para todos os outros codigos dealers?" | " para o codigo dealer "  
				iF MsgNoYes(STR0170+cDealerDe + cCompMsg) // "Deseja replicar as informações do codigo dealer " 
					MsgRun(STR0171,STR0172,{||OA50300357_relicar_dados_dealer(cDealerDe, MV_PAR03, MV_PAR02)})    //"Aguarde..." | "Processando"
				EndIf
			EndIf
		EndIf
	Else
	 	MsgInfo(STR0173) // "Permissão para replicação somente acessando a pasta 'Parametros de Garantia'." 
	 EndIf
	
Return

/*/{Protheus.doc} OA50300347_valid_dealer
	Valida a existencia do codigo dealer

	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300347_valid_dealer(cCodDealer)
	Local oModel       := FWModelActive()
	Local oGridFilGar  := oModel:GetModel("GRID_FILIAIS_GARANTIA")	
	Local lRet         := .F.
	Local nIdx

	for nIdx := 1 to oGridFilGar:Length()
		oGridFilGar:GoLine(nIdx)
		if oGridFilGar:GetValue('DEALER_CODE') == MV_PAR03
			lRet := .T.
			Exit
		EndIf
	next

	if !lRet
		MsgInfo(STR0174) // "Codigo dealer inválido, verifique." 
	EndIf

return lRet

/*/{Protheus.doc} OA50300357_relicar_dados_dealer
	Replicado os dados entre os codigo dealer na aba parametros de garantias

	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300357_relicar_dados_dealer(cDealerDo, cDealerPara, cTodosDealer)
	Local nY        := 0
	Local aDealerDo := {}

	// Armazenando os dados do dealer que enviará os dados replicado
	DbSelectArea(cAliasTmp1)
	(cAliasTmp1)->(DBGoTop())
	(cAliasTmp1)->(DbSetOrder(1))
	If (cAliasTmp1)->(DbSeek(cDealerDo))
		for nY := 1 to len(aCacheCpoChv)
			aAdd(aDealerDo, {aCacheCpoChv[nY][1] , (cAliasTmp1)->&(aCacheCpoChv[nY][1])} )
		Next	
	EndIf

	DbSelectArea(cAliasTmp1)
	(cAliasTmp1)->(DBGoTop())
	(cAliasTmp1)->(DbSetOrder(1))
	if cTodosDealer == "2" 
		// Replicação para o codigo dealer especifico
		If (cAliasTmp1)->(DbSeek(cDealerPara))
			RecLock(cAliasTmp1, .F.)
			for nY := 1 to len(aDealerDo)
				IF ! aDealerDo[nY][1] $ ("GAR_FILIAL/GAR_SEGMEN/GAR_DEACOD")
					(cAliasTmp1)->&(aDealerDo[nY][1]) := aDealerDo[nY][2]		 	
				EndIf
			Next		
		 	(cAliasTmp1)->(MsUnlock())
		EndIf
	Else 
		// Replicação para todos os codigos dealers
		While ! (cAliasTmp1)->(Eof())
			RecLock(cAliasTmp1, .F.)
			for nY := 1 to len(aDealerDo)
				IF ! aDealerDo[nY][1] $ ("GAR_FILIAL/GAR_SEGMEN/GAR_DEACOD") .AND. (cAliasTmp1)->GAR_DEACOD <> cDealerDo
					(cAliasTmp1)->&(aDealerDo[nY][1]) := aDealerDo[nY][2]		 	
				EndIf
			Next	
			(cAliasTmp1)->(MsUnlock())			
			(cAliasTmp1)->(DBSkip())
		EndDo
	EndIf
Return

/*/{Protheus.doc} OA50300367_dados_parametro_garantia
	Retorna os paramtros de garantias para as rotinas OFINJD15 e OFINJD18

	@type method
	@author Leandro Rodrigues
	@since 03/08/2026
/*/
Function OA50300367_dados_parametro_garantia(cNumOsv, jParamMV)
	Local aAreaVO1    := VO1->(GetArea())
	Local oConfig     := OFJDConfig():New(nil, Nil)
	Local cDealerCode := ""
	Local aDados      := {}
	Local lRet        := .F.
	Local nX          := 0
	
	VO1->(dbSetOrder(1))
	VO1->(dbSeek( xFilial("VO1") + cNumOsv ))
	
	cDealerCode := oConfig:DealerCodeDoSegmento(VO1->VO1_SEGMTO, VO1->VO1_FILIAL)

	aDados := oConfig:GetValue("PARAMETRO_GARANTIA", {}) 

	for nX := 1 to len(aDados)
		if AllTrim(aDados[nX]:DEALER_CODE_FORM) == cDealerCode
			jParamMV := aDados[nX]
			lRet := .T.
			Exit
		EndIf
	next
	
	If ! lRet
		FMX_HELP("OA503DEALER",STR0175 + IIF(cDealerCode == Nil,"",cDealerCode), STR0176)// "Nenhuma configuração de parametros de garantia encontrada para o codido dealer: XXXXX | "Acessa a rotina Configurações JD (OFIA503) e realize o cadastro para continuar."
	EndIf

	RestArea(aAreaVO1)
Return lRet
