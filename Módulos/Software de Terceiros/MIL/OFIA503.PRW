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
Static oArrHelper
Static oStrHelper := DMS_StringHelper():New()

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
function OFIA503()
	Private oConfig := OFJDConfig():New()
	Private cMotivo := "000004"
	FWExecView(STR0001, "OFIA503", MODEL_OPERATION_UPDATE)
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

	oStr1 := oModel01:GetView()
	oStr3 := oModel03:GetView()
	oStr4 := oModel04:GetView()
	oStr5 := oModel05:GetView()
	oStr6 := oModel06:GetView()
	oStr7 := oModel07:GetView()
	oStr8 := oModel08:GetView()
	oStr9 := oModel09:GetView()
	oStr10 := oModel10:GetView()

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

	oView:AddUserButton("Importar Arquivos","BUTTON", { |oView| OA50300134_ImportaArquivos() }) // Importar Arquivos
	oView:AddUserButton("Simular Scheduler","BUTTON", { |oView| OA50300144_SimularScheduler() }) // Simular Scheduler
	oView:AddUserButton("Finalizar Simulação","BUTTON", { |oView| OA50300154_CancelarSimulacao() }) // Finalizar Simulação

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

	oModel := MPFormModel():New('OFIA503',,,{ |oModel| OA50300014_Confirmar(oModel) })
	oModel:SetDescription(STR0001) // Configuração John Deere
	
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

	oModel:AddGrid("GRID_ARMAZENS","BASE", oStr7,,,,,{|| Load07Dados() })
	oModel:GetModel("GRID_ARMAZENS"):SetDescription(STR0007) //"Configurações de Armazéns")
	oModel:GetModel("GRID_ARMAZENS"):SetUniqueLine({"CODIGO_ARMAZEM", "FILIAL", "SEGMENTO"})

	oModel:AddGrid("GRID_GERACOES_JDPRISM", "BASE", oStr10,,,,, {|| Load10Dados() })
	oModel:GetModel("GRID_GERACOES_JDPRISM"):SetDescription(STR0074)//"Gerações programadas")
	oModel:GetModel("GRID_GERACOES_JDPRISM"):SetOptional(.t.)

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
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, OA50300084_OpcoesFiliais()) }},;
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
		{'cTitulo'  , STR0034 },; //"Linha"
		{'cIdField' , "SEGMENTO" },;
		{'aComboValues', {"0="+STR0037,"1="+STR0038,"2="+STR0053}},; // agricola & construcao
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1,2,3,4,5") }},;
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
		{'aComboValues', {"0="+STR0037,"1="+STR0038,"2="+STR0053}},; // agricola & construcao
		{'bValid', { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1,2,3,4,5") }},;
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
		{'cIdField' , "FORNECEDOR_CODIGO" },;
		{'nTamanho' , GetSX3Cache("A2_COD", "X3_TAMANHO") },;
		{'cLookUp'  , 'FOR'},;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0061 } ; // Código do fornecedor que será usado para transferencias no jdprism
	})
	oMd:AddField({;
		{'cTitulo'  , STR0060 },; // Loja do fornecedor
		{'cIdField' , "FORNECEDOR_LOJA" },;
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
	jJson["CFG_LOCAL_ARQUIVOS"] := oBase:GetValue('CFG_LOCAL_ARQUIVOS')
	jJson["CFG_LOCAL_ARQUIVOS_IMPORTAR"] := oBase:GetValue('CFG_LOCAL_ARQUIVOS_IMPORTAR')
	jJson["CFG_DELTA_LIBERADO"] := oBase:GetValue('CFG_DELTA_LIBERADO')
	jJson["DEBUGANDO"] := oDebug:GetValue('DEBUGANDO')
	jJson["LISTA_FILIAIS_DEBUG"] := oDebug:GetValue('LISTA_FILIAIS_DEBUG')
	jJson["LISTA_SEGMENTOS_DEBUG"] := oDebug:GetValue('LISTA_SEGMENTOS_DEBUG')
	jJson["LISTA_PECAS_DEBUG"] := oDebug:GetValue('LISTA_PECAS_DEBUG')
	jJson["FORNECEDOR_CODIGO"] := oJdprism:GetValue('FORNECEDOR_CODIGO')
	jJson["FORNECEDOR_LOJA"] := oJdprism:GetValue('FORNECEDOR_LOJA')
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
	local oSched := DMS_DPMSched():New()
	
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
	local oConf := DMS_DPMConfig():New("SCHEDULER")
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

