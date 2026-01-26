#include "PROTHEUS.CH"
#include "OFIOA560.CH"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                               //
//   # # # # # # #   # # # # # # #   # # # # # #   # # #     # #   # # # # # #   # # # # # # #   # # # # # # #   //
//   # #       # #        # #        # #           # #  #    # #   # #           # #       # #   # #       # #   //
//   # # # # # # #        # #        # # # # #     # #   #   # #   # #           # # # # # # #   # #       # #   //
//   # #       # #        # #        # #           # #    #  # #   # #           # #       # #   # #       # #   //
//   # #       # #        # #        # # # # # #   # #     # # #   # # # # # #   # #       # #   # # # # # # #   //
//                                                                                                               //
//    Qualquer inclusão/alteração no fonte OFIOA560 será necessário ALTERAR o conteudo da string "cVersao" na    //
//    primeira função "OA5600071_Versao_PRW()" para que a rotina construa a tabela VX5 com todos os idiomas.     //
//    Utilizar como código de versão a data que esta realizando a manutenção. Exemplo: 20240210                  //
//                                                                                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} OA5600071_Versao_PRW
	Retorna a Versão do PRW para ser comparado com a Versão que está gravado na Tabela VX5

	@author Andre Luis Almeida
	@since  07/02/2024
/*/
Function OA5600071_Versao_PRW()
Local cVersao := "20250916" // Data de Alteração do PRW ( Versao )
Return cVersao

/*/{Protheus.doc} OFIOA560
	Cadastro de Tabelas Genericas do Gestao de Concessionarias ( VX5 )

	@author Andre Luis Almeida
	@since  04/06/2013
/*/
Function OFIOA560(cParTab)
Local aSize       := FWGetDialogSize( oMainWnd )
Private aVX5      := {}
Private cVX5      := ""
Private cCadastro := ""
Private cTabBloq  := "028/_FL/" // Tabelas que não podem ser alteradas
Default cParTab   := ""

DbSelectArea("VX5")
DbSetOrder(1)

// Carregar o vetor aVX5 com os registros das Tabelas e Filhos
oProcExec := MsNewProcess():New({ |lEnd| OA5600051_Atualizar_VX5(.t.) },STR0713,"",.f.) // Levantando Tabelas
oProcExec:Activate()

oDlgVX5 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Tabelas Genericas do Gestao de Concessionarias

	oWorkArea := FWUIWorkArea():New( oDlgVX5 )
	oWorkArea:CreateHorizontalBox( "LINE01", 40 )
	oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
	oWorkArea:CreateHorizontalBox( "LINE02", 60 )
	oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
	oWorkArea:Activate()

	oBrwReg := FWMBrowse():New()
	oBrwReg:SetAlias("VX5")
	oBrwReg:SetOwner(oWorkarea:GetPanel("OBJ2"))
	oBrwReg:SetDescription("")
	oBrwReg:SetMenuDef("OFIOA560") // Montagem com MenuDef
	oBrwReg:ForceQuitButton(.T.)
	oBrwReg:DisableDetails()
	oBrwReg:Activate()

	oBrwTab := FWMBrowse():New()
	oBrwTab:SetOwner(oWorkarea:GetPanel("OBJ1"))
	oBrwTab:SetDescription(STR0001) // Tabelas Genericas do Gestao de Concessionarias
	oBrwTab:SetMenuDef("")
	oBrwTab:SetDataQuery(.T.)
	oBrwTab:SetAlias("SQLVX5")
	oBrwTab:SetQuery(OA5600021_Query_Browse_SQL(cParTab,"1","","1"))
	oBrwTab:SetColumns(OA5600031_Colunas_Browse_SQL())
	oBrwTab:AddButton(STR0712,{|| OA5600041_Filtrar_Browse_SQL(cParTab) , cVX5 := left(SQLVX5->VX5_CODIGO,3) , oBrwReg:SetFilterDefault("@ VX5_CHAVE = '" + cVX5 + "'") , oBrwReg:Refresh() },,2,2) // Filtrar
	oBrwTab:bChange := { || cVX5 := left(SQLVX5->VX5_CODIGO,3) , oBrwReg:SetFilterDefault("@ VX5_CHAVE = '" + cVX5 + "'") }
	oBrwTab:ForceQuitButton(.T.)
	oBrwTab:DisableDetails()
	oBrwTab:DisableLocate()
	oBrwTab:SetAmbiente(.F.)
	oBrwTab:SetWalkthru(.F.)
	oBrwTab:SetInsert(.f.)
	oBrwTab:SetUseFilter(.f.)
	oBrwTab:lOptionReport := .f.
	oBrwTab:DisableSeek()
	oBrwTab:Activate()

oDlgVX5:Activate( , , , , , , ) //ativa a janela

DbSelectArea("VX5")

Return()

/*/{Protheus.doc} OA560PAI()
	Adiciona os registros correspondentes as Tabelas VX5 - PADRAO VX5

	aVX5[n,1] = 000 - Agrupador de Tabelas
	aVX5[n,2] = Codigo da Tabela
	aVX5[n,3] = Descrição da Tabela quando utilizado "#STR#", a rotina vai traduzir utilizando o STR correspondente ao codigo que esta na 7ª coluna do vetor ( aVX5[n,7] )
	aVX5[n,4] = Proprietario "S"
	aVX5[n,5] = Campo Padrao a ser utilizado para buscar o tamanho do Codigo dos registros na Tabela
	aVX5[n,6] = Tamanho Default do Codigo dos registros na Tabela quando nao existe o campo no SX3 ( Default 10 )
	aVX5[n,7] = Numero do STR a ser utilizado, quando for 0 não será traduzido e ficara com texto fixo ( aVX5[n,3] )

	@author Andre Luis Almeida
	@since  25/01/2024
/*/
Static Function OA560PAI()
//
aAdd(aVX5,{"000","001","#STR#"							,"S","VMN_MODEND"	,0,  14}) // Modalidade de Endividamento
aAdd(aVX5,{"000","002","#STR#"							,"S","VMV_TIPINS"	,0,  15}) // Tipos de Infra
aAdd(aVX5,{"000","003","#STR#"							,"S","VMK_CODCUL"	,0,  16}) // Culturas
aAdd(aVX5,{"000","025","#STR#"							,"S","VDL_PERFIL"	,0,  17}) // Perfil do Cliente
aAdd(aVX5,{"000","026","#STR#"							,"S","VDM_CAMPOP"	,0,  18}) // Campanha da Oportunidade  de Negócio
aAdd(aVX5,{"000","027","#STR#"							,"S","VDM_TIPMID"	,0,  19}) // Tipos de Mídia
aAdd(aVX5,{"000","028","#STR#"							,"S","VE1_MARFAB"	,0,  20}) // Marcas
aAdd(aVX5,{"000","030","#STR#"							,"S","VAR_CODBCO"	,3,  21}) // Bancos
aAdd(aVX5,{"000","031","#STR#"							,"S","VDM_FASFIN"	,0,  22}) // Fase Financiamento
aAdd(aVX5,{"000","032","#STR#"							,"S","VDM_LINCRE"	,0,  23}) // Linha de Credito
aAdd(aVX5,{"000","033","#STR#"							,"S","VCF_CODSEG"	,0,  24}) // Segmentos de Mercados
aAdd(aVX5,{"000","034","#STR#"							,"S","VST_CODFAL"	,0,  25}) // Codigos de Falha
aAdd(aVX5,{"000","035","#STR#"							,"S","VER_AGRUPA"	,0,  26}) // Agrupadores Metas de Vendas
aAdd(aVX5,{"000","037","#STR#"							,"S",""				,0,  28}) // LOG ALTERACOES GRUPO
aAdd(aVX5,{"000","038","#STR#"							,"S","VG6_TPCUST"	,0,  29}) // TIPOS DE CUSTO GARANTIA SCANIA
aAdd(aVX5,{"000","043","#STR#"							,"S","VQM_TIPSER"	,0,  51}) // Tipo de Serviço para Prestação de Serviços Diversos
aAdd(aVX5,{"000","044","#STR#"							,"S","VDM_DECVDA"	,0,  52}) // Decisão de Venda
aAdd(aVX5,{"000","045","#STR#"							,"S","VQQ_CMPMOT"	,0,  54}) // Complemento do Motor
aAdd(aVX5,{"000","046","#STR#"							,"S",""				,0,  60}) // Grupo de Checklist
aAdd(aVX5,{"000","047","#STR#"							,"S",""				,0,  61}) // Tipo de Ordem de Serviço
aAdd(aVX5,{"000","048","#STR#"							,"S",""				,0,  63}) // Tipo de Manutenção
aAdd(aVX5,{"000","049","#STR#"							,"S",""				,0,  64}) // Origem Evento do Diário
aAdd(aVX5,{"000","050","#STR#"							,"S","VO1_TPATEN"	,0,  56}) // Tipo de Atendimento
aAdd(aVX5,{"000","052","#STR#"							,"S","VAI_CLAHAB"	,1,  59}) // Classificação da Habilidade do Técnico
aAdd(aVX5,{"000","053","#STR#"							,"S","VQW_TIPSIN"	,4,  62}) // Tipo de Sinistro (Cad.Seguros)
aAdd(aVX5,{"000","075","#STR#"							,"S","VJT_ORIGEM"	,1, 112}) // Origem para alerta de alteração de campos
aAdd(aVX5,{"000","076","#STR#"							,"S","VV1_COMVEI"	,1,  65}) // Combustiveis
aAdd(aVX5,{"000","077","#STR#"							,"S","VS1_PRISEP"	,2,  85}) // Prioridade Separação/Conferência
aAdd(aVX5,{"000","066","#STR#"							,"S","VV2_CORINT",TamSX3("VV2_CORINT")[1], 120}) // Cor Interna - Modelo de Veículo
aAdd(aVX5,{"000","067","#STR#"							,"S","VV2_COREXT",TamSX3("VV2_COREXT")[1], 121}) // Cor Externa - Modelo de Veículo
aAdd(aVX5,{"000","068","#STR#"							,"S","VV2_OPCION",TamSX3("VV2_OPCION")[1], 122}) // Opcional - Modelo de Veículo
aAdd(aVX5,{"000","070","#STR#"							,"S","VX0_TIPO"  	,4, 123}) // Tipo de Evento - Log Genérico
aAdd(aVX5,{"000","081","#STR#"							,"S","VCF_MERLBM"	,3, 124}) // Merchandising Cliente
aAdd(aVX5,{"000","083","#STR#" 							,"S",""				,2, 126}) // Mensagem WS
aAdd(aVX5,{"000","084","#STR#" 							,"S",""				,2, 127}) // Tipo de Dado - LOG WS
aAdd(aVX5,{"000","085","#STR#" 							,"S",""				,2, 128}) // Origem - LOG WS
aAdd(aVX5,{"000","087","#STR#" 							,"S",""				,2, 129}) // Tipo de Requisição de Reserva
aAdd(aVX5,{"000","088","#STR#" 							,"S",""				,2, 130}) // Tipo de Devolução de Reserva
aAdd(aVX5,{"000","089","#STR#"							,"S",""				,2, 131}) // Tipo de Conferência
aAdd(aVX5,{"000","090","#STR#" 							,"S",""				,2, 132}) // Atribuições
aAdd(aVX5,{"000","091","#STR#" 							,"S","VAR_AGFINA"	,5, 715}) // Agente Financeiro
aAdd(aVX5,{"000","092","#STR#" 							,"S",""				,10,716}) // Cliente por Filial Mercado Internacional
//
// cCodMar == "JD" // Tabelas especificas para a marca John Deere
//
aAdd(aVX5,{"000","004","#STR# - John Deere"		,"S","VMY_CTYPE"	,0,  86}) // Tipo de Cliente
aAdd(aVX5,{"000","005","#STR# - John Deere"		,"S","VMB_UNIMED"	,0,  87}) // Unidade de Medida
aAdd(aVX5,{"000","006","#STR# - John Deere"		,"S","VMB_TIPGAR"	,0,  88}) // Tipo de Garantia
aAdd(aVX5,{"000","007","#STR# - John Deere"		,"S","VMY_MKTCOD"	,0,  89}) // Finalidade
aAdd(aVX5,{"000","008","#STR# - John Deere"		,"S","VMB_APLICA"	,0,  90}) // Aplicacao para Garantia de Bateria
aAdd(aVX5,{"000","009","#STR# - John Deere"		,"S","VMB_APLICA"	,0,  91}) // Aplicacao para Garantia de Track
aAdd(aVX5,{"000","010","#STR# - John Deere"		,"S","VMB_SUBGAR"	,0,  92}) // Subtipo de Garantia
aAdd(aVX5,{"000","011","#STR# - John Deere"		,"S","VMB_FALHA"	,0,  93}) // Falha
aAdd(aVX5,{"000","012","#STR# - John Deere"		,"S","VMB_MAQPAR"	,0,  94}) // Tempo de Maquina Parada
aAdd(aVX5,{"000","013","#STR# - John Deere"		,"S","VMB_TIPESP"	,0,  95}) // Tipo de Autorizacao Especial
aAdd(aVX5,{"000","014","#STR# - John Deere"		,"S","VMB_INTSRV"	,0,  96}) // Intervalo de Servico
aAdd(aVX5,{"000","015","#STR# - John Deere"		,"S","VMB_TIPMAQ"	,0,  97}) // Tipo de Maquina
aAdd(aVX5,{"000","016","#STR# - John Deere"		,"S",""				,0,  98}) // Status de Garantia
aAdd(aVX5,{"000","017","#STR# - John Deere"		,"S","VMC_TIPTRA"	,0,  99}) // Tipo de Servico
aAdd(aVX5,{"000","018","#STR# - John Deere"		,"S",""				,0, 100}) // Localidade de Servico
aAdd(aVX5,{"000","019","#STR# - John Deere"		,"S",""				,0, 101}) // Tipo de Pmp
aAdd(aVX5,{"000","020","#STR# - John Deere"		,"S",""				,0, 102}) // Tipo de Garantia
aAdd(aVX5,{"000","021","#STR# - John Deere"		,"S",""				,0, 103}) // Status de Contrato
aAdd(aVX5,{"000","022","#STR# - John Deere"		,"S","VMC_CODMAT"	,0, 104}) // Cód. Outros Creditos
aAdd(aVX5,{"000","023","#STR# - John Deere"		,"S",""				,0, 105}) // Status de Maquina
aAdd(aVX5,{"000","024","#STR# - John Deere"		,"S","VMB_FALHA"	,0, 106}) // Falha (Bateria)
aAdd(aVX5,{"000","029","#STR# - John Deere"		,"S",""				,0, 134}) // Codigo de Troca
aAdd(aVX5,{"000","036","#STR# - John Deere"		,"S",""				,25, 133}) // Tipos de Pedido
aAdd(aVX5,{"000","051","#STR# - John Deere"		,"S","VQ0_EVENTO"	,0, 111}) // Eventos para Bonus de Pedido
aAdd(aVX5,{"000","082","#STR# - John Deere"		,"S",""				,6, 125}) // Base Codes
aAdd(aVX5,{"000","071","JDQUOTE - #STR#"		,"S",""				,0, 116}) // QUOTE TYPE
aAdd(aVX5,{"000","072","JDQUOTE - #STR#"		,"S",""				,0, 117}) // QUOTE STATUS
aAdd(aVX5,{"000","073","JDQUOTE - #STR#"		,"S",""				,0, 118}) // MOTIVO VENDA PERDIDA
aAdd(aVX5,{"000","074","JDQUOTE - #STR#"		,"S",""				,0, 119}) // ULTIMA MARCA
//
// cCodMar == "NHC" // Tabelas especificas para a marca New Holland Construction
//
aAdd(aVX5, {"000","039","#STR# - NEW HOLLAND CONSTRUCTION"	,"S",""				,0, 107}) // Tipo de Garantia
aAdd(aVX5, {"000","040","#STR# - NEW HOLLAND CONSTRUCTION"	,"S","VGH_FALHA"	,0, 108}) // Codigo de Falha
aAdd(aVX5, {"000","041","#STR# - NEW HOLLAND CONSTRUCTION"	,"S","VGH_TIPREC"	,0, 109}) // Tipo de Reclamação
aAdd(aVX5, {"000","042","#STR# - NEW HOLLAND CONSTRUCTION"	,"S","VGH_CGAR"		,0, 110}) // Condição de Garantia
//
// cCodMar $ "CHL-MSF-VAL-FDT" // Especificos para as marcas Challenger, Massey Ferguson e Valtra (AGCO)
//
aAdd(aVX5,{"000", "078", "#STR#"				,"S","VFF_CODGRF"	,4, 113}) // Gerencial Referencial DFS AGCO
aAdd(aVX5,{"000", "079", "#STR#"				,"S","VFF_CODDRF"	,4, 114}) // Gerencial Referencial DFS AGCO
aAdd(aVX5,{"000", "080", "#STR#"				,"S",""				,4, 115}) // Plano Contábil DFS AGCO

aAdd(aVX5,{"000", "093", "#STR#"				,"S",""				,4, 717}) // Tabelas para VRX
//
// cCodMar == "CNH"		// Case New Holland
//
aAdd(aVX5,{"000", "059", "#STR#"                ,"S", ""  			,1, 729})	//Canais Venda PRIM"
aAdd(aVX5,{"000", "060", "#STR#"                ,"S", ""  			,9, 730})	//Motivos Compra PRIM"
aAdd(aVX5,{"000", "062", "#STR#"                ,"S", ""  			,1, 732})	//Status Sublinha PRIM"
aAdd(aVX5,{"000", "063", "#STR#"                ,"S", ""  			,2, 733})	//Tipos Pedidos PRIM"
aAdd(aVX5,{"000", "065", "#STR#"                ,"S", ""  			,3, 735})	//Subcanais"
Return

/*/{Protheus.doc} OA560FILHO()
	Adiciona os registros filhos PADRAO das Tabelas VX5

	aVX5[n,1] = Codigo da Tabela
	aVX5[n,2] = Codigo do Registro
	aVX5[n,3] = Descrição do Registro quando utilizado "#STR#", a rotina vai traduzir utilizando o STR correspondente ao codigo que esta na 7ª coluna do vetor ( aVX5[n,7] )
	aVX5[n,4] = Proprietario "S"
	aVX5[n,5] = Elemento utilizado somente no Pai - Agrupamento das Tabelas ( quando Codigo da Tabela for 000 )
	aVX5[n,6] = Elemento utilizado somente no Pai - Agrupamento das Tabelas ( quando Codigo da Tabela for 000 )
	aVX5[n,7] = Numero do STR a ser utilizado, quando for 0 não será traduzido e ficara com texto fixo ( aVX5[n,3] )
		
	@author Andre Luis Almeida
	@since  25/01/2024
/*/
Static Function OA560FILHO()
//
aAdd(aVX5,{"028","CHY","CHERY"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","GM" ,"DAFRA"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","FI" ,"FIAT"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","FD" ,"FORD"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","GM" ,"GENERAL MOTORS"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","HON","HONDA"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","HY" ,"HYUNDAI"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","KIA","KIA MOTORS"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","LIF","LIFAN"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","MAN","MAN"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","MIT","MITSUBISHI"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","NIS","NISSAN"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","REN","RENAULT"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","SCA","SCANIA"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","TOY","TOYOTA"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","VW" ,"VOLKSWAGEN"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","PEG","PEUGEOT"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","YAM","YAMAHA"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","JD" ,"JOHN DEERE"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","TMK","THERMO KING"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","NHA","NEW HOLLAND AGRICULTURE"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","NHC","NEW HOLLAND CONSTRUCTION"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","ATL","ATLAS COPCO"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","GHL","GHEL"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","KOM","KOMATSU"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","CHL","CHALLENGER"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","CSA","CASE AGRICULTURE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","CSC","CASE CONSTRUCTION"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","VAL","VALTRA"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","MSF","MASSEY FERGUSON"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","GRS","GREEN SYSTEM - JOHN DEERE"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","PLA","PLA - JOHN DEERE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","MHY","MONTADORA - HYUNDAI"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","FDT","FENDT"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","JDC","JOHN DEERE CONSTRUCTION"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"028","HCM","HITACHI - JOHN DEERE"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5,{"038","MAT","#STR#"							,"S","",0,  49}) // MATERIAL DE TERCEIRO
aAdd(aVX5,{"038","OLL","#STR#"							,"S","",0,  50}) // OLEO E LUBRIFICANTE
aAdd(aVX5,{"038","MOT","#STR#"							,"S","",0,  30}) // MAO DE OBRA TERCEIRO
aAdd(aVX5,{"038","RR ","#STR#"							,"S","",0,  31}) // SOCORRO KM PICKUP
aAdd(aVX5,{"038","TO ","#STR#"							,"S","",0,  32}) // SOCORRO KM GUINCHO
aAdd(aVX5,{"038","MO ","#STR#"							,"S","",0,  33}) // MAO DE OBRA NAO CATALOGADA
aAdd(aVX5,{"038","O01","#STR#"							,"S","",0,  34}) // OLEO MOTOR - MINERAL
aAdd(aVX5,{"038","O02","#STR#"							,"S","",0,  35}) // OLEO DIFERENCIAL - MINERAL (EIXO TRASEIRO)
aAdd(aVX5,{"038","O03","#STR#"							,"S","",0,  36}) // OLEO CX. TRANSMISSAO - MINERAL
aAdd(aVX5,{"038","O05","#STR#"							,"S","",0,  37}) // OLEO DE RETARDER
aAdd(aVX5,{"038","O07","#STR#"							,"S","",0,  38}) // OLEO HIDRAULICO CAIXA DE DIRECAO
aAdd(aVX5,{"038","O08","#STR#"							,"S","",0,  39}) // OLEO CAIXA ZF G701
aAdd(aVX5,{"038","O09","#STR#"							,"S","",0,  40}) // OLEO CAIXA ZF AUTOMATICA
aAdd(aVX5,{"038","O11","#STR#"							,"S","",0,  41}) // OLEO MOTOR SINTETICO
aAdd(aVX5,{"038","O12","#STR#"							,"S","",0,  42}) // OLEO DIFERENCIAL SINTETICO (EIXO TRASEIRO)
aAdd(aVX5,{"038","O13","#STR#"							,"S","",0,  43}) // OLEO CX. TRANSMISSAO SINTETICO
aAdd(aVX5,{"038","O15","#STR#"							,"S","",0,  44}) // OLEO DO VENTILADOR
aAdd(aVX5,{"038","M04","#STR#"							,"S","",0,  45}) // GRAXA
aAdd(aVX5,{"038","M10","#STR#"							,"S","",0,  46}) // GRAXA CRUZETA
aAdd(aVX5,{"038","M14","#STR#"							,"S","",0,  47}) // GRAXA EP
aAdd(aVX5,{"038","M06","#STR#"							,"S","",0,  48}) // FLUIDO DE EMBREAGEM
//
// cCodMar == "JD" // Especificos para a marca John Deere
//
aAdd(aVX5,{"007","13","#STR#"					,"S","",0, 139}) // ANIMAIS / LACTACAO / ALIMENTACAO
aAdd(aVX5,{"007","15","#STR#"					,"S","",0, 140}) // PLANTAS / GRAOS PEQUENOS
aAdd(aVX5,{"007","16","#STR#"					,"S","",0, 141}) // CULTIVO ESPECIAL
aAdd(aVX5,{"007","17","#STR#"					,"S","",0, 142}) // UTILIDADES GERAIS
aAdd(aVX5,{"007","41","#STR#"					,"S","",0, 143}) // CONTRUCAO CASAS & EDIFICIOS
aAdd(aVX5,{"007","43","#STR#"					,"S","",0, 144}) // SISTEMAS DE AGUA E ESGOTO
aAdd(aVX5,{"007","49","#STR#"					,"S","",0, 145}) // RODOVIAS & RUAS
aAdd(aVX5,{"007","71","#STR#"					,"S","",0, 146}) // AEROPORTOS
aAdd(aVX5,{"007","74","#STR#"					,"S","",0, 147}) // FERROVIARIA
aAdd(aVX5,{"007","81","#STR#"					,"S","",0, 148}) // COMPANHIA DE TELEFONE
aAdd(aVX5,{"007","82","#STR#"					,"S","",0, 149}) // GAS, AGUA E ELETRICIDADE
aAdd(aVX5,{"007","84","#STR#"					,"S","",0, 150}) // ATERROS (LIXO)
aAdd(aVX5,{"007","87","#STR#"					,"S","",0, 151}) // PARQUES
aAdd(aVX5,{"007","89","#STR#"					,"S","",0, 152}) // RESIDENCIAL
aAdd(aVX5,{"007","90","#STR# - JOHN DEERE"		,"S","",0, 153}) // CONCESSIONARIO
aAdd(aVX5,{"007","92","#STR#"					,"S","",0, 154}) // MOVIMENTO DE RODOVIAS
aAdd(aVX5,{"007","93","#STR#"					,"S","",0, 155}) // VIVEIROS E JARDINS
aAdd(aVX5,{"007","94","#STR#"					,"S","",0, 156}) // CAMPOS DE GOLF
aAdd(aVX5,{"007","95","#STR#"					,"S","",0, 157}) // INSTITUICÕES
aAdd(aVX5,{"007","96","#STR#"					,"S","",0, 158}) // EMPRESA DE ALUGUEL INDEPENDENTE
aAdd(aVX5,{"007","98","#STR#"					,"S","",0, 159}) // INDEFINIDO
//
aAdd(aVX5,{"004","01","#STR#"					,"S","",0, 160}) // COMERCIAL
aAdd(aVX5,{"004","02","#STR#"					,"S","",0, 161}) // GOVERNO FEDERAL
aAdd(aVX5,{"004","03","#STR#"					,"S","",0, 162}) // ESTADO / REGIAO
aAdd(aVX5,{"004","04","#STR#"					,"S","",0, 163}) // PAIS
aAdd(aVX5,{"004","05","#STR#"					,"S","",0, 164}) // CIDADE
aAdd(aVX5,{"004","06","#STR#"					,"S","",0, 165}) // FORCAS ARMADAS
aAdd(aVX5,{"004","07","#STR#"					,"S","",0, 166}) // CONTA NACIONAL
aAdd(aVX5,{"004","08","#STR#"					,"S","",0, 167}) // RESIDENCIAL
aAdd(aVX5,{"004","09","#STR#"					,"S","",0, 168}) // FAZENDA
aAdd(aVX5,{"004","L ","#STR# (25-74)"			,"S","",0, 169}) // FROTA GRANDE
aAdd(aVX5,{"004","M ","#STR# (10-24)"			,"S","",0, 170}) // FROTA MÉDIA
aAdd(aVX5,{"004","S ","#STR# (<10)"				,"S","",0, 171}) // FROTA PEQUENA
aAdd(aVX5,{"004","V ","#STR# (>74)"				,"S","",0, 172}) // FROTA MUITO GRANDE
//
aAdd(aVX5,{"005","Acre"  ,"#STR#"				,"S","",0, 173}) // ACRES
aAdd(aVX5,{"005","D"     ,"#STR#"				,"S","",0, 174}) // DIAS
aAdd(aVX5,{"005","H"     ,"#STR#"				,"S","",0, 175}) // HORAS
aAdd(aVX5,{"005","Hectar","#STR#"				,"S","",0, 176}) // HECTARES
aAdd(aVX5,{"005","Hrs"   ,"SEPARATOR HOURS"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"005","Km"    ,"#STR#"				,"S","",0, 177}) // KILOMETROS
aAdd(aVX5,{"005","Mile"  ,"#STR#"				,"S","",0, 178}) // MILHAS
aAdd(aVX5,{"005","Pc"    ,"#STR#"				,"S","",0, 179}) // FARDO
//
aAdd(aVX5,{"006","ZNRM","#STR#"					,"S","",0, 180}) // NORMAL
aAdd(aVX5,{"006","ZPIP","PMP (PIP)"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"006","ZPAR","#STR#"					,"S","",0, 181}) // PECAS
aAdd(aVX5,{"006","ZSPA","#STR#"					,"S","",0, 182}) // AUTORIZACAO ESPECIAL
aAdd(aVX5,{"006","ZZTK","#STR#"					,"S","",0, 183}) // ESTEIRAS
aAdd(aVX5,{"006","ZZBT","#STR#"					,"S","",0, 184}) // BATERIA
aAdd(aVX5,{"006","ZZMK","#STR#"					,"S","",0, 185}) // MARKETING
//
aAdd(aVX5,{"008","AUTO","#STR#"					,"S","",0, 186}) // CARRO/CAMINHONETE MENOS DE 1T
aAdd(aVX5,{"008","COPR","#STR#"					,"S","",0, 187}) // PRODUTO DO CONSUMIDOR
aAdd(aVX5,{"008","CVEH","#STR#"					,"S","",0, 188}) // VEICULO COMERCIAL
aAdd(aVX5,{"008","FIND","#STR#"					,"S","",0, 189}) // AGRICOLA OU INDUSTRIAL
aAdd(aVX5,{"008","OTHR","#STR#"					,"S","",0, 190}) // OUTRO
//
aAdd(aVX5,{"009","AGRI","#STR#"					,"S","",0, 191}) // AGRICULTURA
aAdd(aVX5,{"009","CONS","#STR#"					,"S","",0, 192}) // CONSTRUCAO
//
aAdd(aVX5,{"010","MTC","#STR#"					,"S","",0, 193}) // PLANO DE MANUTECAO
//
aAdd(aVX5,{"011","01","#STR#"					,"S","",0, 194}) // CURVADO/TORCIDO/DESALINHADO
aAdd(aVX5,{"011","02","#STR#"					,"S","",0, 195}) // SOPRANDO
aAdd(aVX5,{"011","03","#STR#"					,"S","",0, 196}) // QUEBRADO/RACHADO
aAdd(aVX5,{"011","04","#STR#"					,"S","",0, 197}) // QUEIMADO
aAdd(aVX5,{"011","05","#STR#"					,"S","",0, 198}) // CALIBRACAO
aAdd(aVX5,{"011","06","#STR#"					,"S","",0, 199}) // FROUXO
aAdd(aVX5,{"011","07","#STR#"					,"S","",0, 200}) // BATIDO
aAdd(aVX5,{"011","08","#STR#"					,"S","",0, 201}) // CORROIDO
aAdd(aVX5,{"011","09","#STR#"					,"S","",0, 202}) // CORTE
aAdd(aVX5,{"011","10","#STR#"					,"S","",0, 203}) // CONEXAO ELETRICA
aAdd(aVX5,{"011","11","#STR#"					,"S","",0, 204}) // FALHA ELETRICA
aAdd(aVX5,{"011","12","#STR#"					,"S","",0, 205}) // AJUSTE IMPROPRIO
aAdd(aVX5,{"011","13","#STR#"					,"S","",0, 206}) // FALTA DE POTENCIA
aAdd(aVX5,{"011","14","#STR#"					,"S","",0, 207}) // VAZAMENTO
aAdd(aVX5,{"011","15","#STR#"					,"S","",0, 208}) // CONSUMO DE OLEO
aAdd(aVX5,{"011","16","#STR#"					,"S","",0, 209}) // OMITIDO/FALTANDO
aAdd(aVX5,{"011","17","#STR#"					,"S","",0, 210}) // OUTRO (REQUER EXPLICACAO)
aAdd(aVX5,{"011","18","#STR#"					,"S","",0, 211}) // FORA DO AJUSTE
aAdd(aVX5,{"011","19","#STR#"					,"S","",0, 212}) // SUPERAQUECIDO
aAdd(aVX5,{"011","20","#STR#"					,"S","",0, 213}) // ORIFICIO ALARGADO/POROSO
aAdd(aVX5,{"011","21","#STR#"					,"S","",0, 214}) // PRESSAO BAIXA/ELEVADA
aAdd(aVX5,{"011","22","#STR#"					,"S","",0, 215}) // ROTEAMENTO
aAdd(aVX5,{"011","23","#STR#"					,"S","",0, 216}) // MARCADO/RANHURAS
aAdd(aVX5,{"011","24","#STR#"					,"S","",0, 217}) // CURTO CIRCUITO/ENCIRCUITADO
aAdd(aVX5,{"011","25","#STR#"					,"S","",0, 218}) // ENGATE DE MARCHA
aAdd(aVX5,{"011","26","#STR#"					,"S","",0, 219}) // SOFTWARE REPROGRAMADO
aAdd(aVX5,{"011","27","#STR#"					,"S","",0, 220}) // DESMANCHADO
aAdd(aVX5,{"011","28","#STR#"					,"S","",0, 221}) // FUNDIDO
aAdd(aVX5,{"011","29","#STR#"					,"S","",0, 222}) // VIBRACAO
aAdd(aVX5,{"011","30","#STR#"					,"S","",0, 223}) // DESGASTADO
aAdd(aVX5,{"011","31","#STR#"					,"S","",0, 224}) // INSTALADO PECA ERRADA
//
aAdd(aVX5,{"012","10","#STR#"					,"S","",0, 225}) // NENHUM TEMPO DE MAQUINA PARADA
aAdd(aVX5,{"012","20","#STR#"					,"S","",0, 226}) // MENOS DE 4 HORAS
aAdd(aVX5,{"012","30","#STR#"					,"S","",0, 227}) // MENOS DE 1 DIA
aAdd(aVX5,{"012","40","#STR#"					,"S","",0, 228}) // MAIS DO QUE 1 DIA
aAdd(aVX5,{"012","50","#STR#"					,"S","",0, 229}) // MAIS DO QUE 1 SEMANA
aAdd(aVX5,{"012","60","#STR#"					,"S","",0, 230}) // DESCONHECIDO
//
aAdd(aVX5,{"013","01","#STR#"					,"S","",0, 231}) // ADMINIS. POR CONCESSIONARIA (C&F)
aAdd(aVX5,{"013","02","#STR#"					,"S","",0, 232}) // GESTO DE BOA VONTADE
aAdd(aVX5,{"013","03","#STR#"					,"S","",0, 233}) // PRODUTO
aAdd(aVX5,{"013","04","#STR#"					,"S","",0, 234}) // EXPERIMENTAL/ENGENHARIA
aAdd(aVX5,{"013","05","#STR#"					,"S","",0, 235}) // VENDAS
aAdd(aVX5,{"013","06","#STR#"					,"S","",0, 236}) // POLITICA DE PROCESSAMENTO
aAdd(aVX5,{"013","07","#STR#"					,"S","",0, 237}) // SERVICO PECA COM DEFEITO
aAdd(aVX5,{"013","08","FIU"						,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"013","09","#STR#"					,"S","",0, 238}) // SEGURO DE DESGASTE (C&F)
aAdd(aVX5,{"013","10","#STR#"					,"S","",0, 239}) // SEGURO DE GIRO LUBRIFICAD (C&F)
aAdd(aVX5,{"013","11","STRUCTURAL (C&F)"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5,{"014","PDI" ,"#STR#"					,"S","",0, 240}) // INSPECAO DE PRÉ ENTREGA
aAdd(aVX5,{"014","ADI" ,"#STR#"					,"S","",0, 241}) // INSPECAO APÓS A ENTREGA
aAdd(aVX5,{"014","BRKN","BREAK-IN"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"014","PRMO","#STR#"					,"S","",0, 242}) // PROMOCIONAL
aAdd(aVX5,{"014","INST","#STR#"					,"S","",0, 243}) // INSTALACAO
aAdd(aVX5,{"014","MNT1","#STR#"					,"S","",0, 244}) // PRIMEIRA MANUTENCAO
aAdd(aVX5,{"014","MNT2","#STR#"					,"S","",0, 245}) // SEGUNDA MANUTENCAO
aAdd(aVX5,{"014","MNT3","#STR#"					,"S","",0, 246}) // TERCEIRA MANUTENCAO
aAdd(aVX5,{"014","MNT4","#STR#"					,"S","",0, 247}) // QUARTA MANUTENCAO
aAdd(aVX5,{"014","MNT5","#STR#"					,"S","",0, 248}) // QUINTA MANUTENCAO
aAdd(aVX5,{"014","MNT6","#STR#"					,"S","",0, 249}) // SEXTA MANUTENCAO
aAdd(aVX5,{"014","MNT7","#STR#"					,"S","",0, 250}) // SETIMA MANUTENCAO
aAdd(aVX5,{"014","MNT8","#STR#"					,"S","",0, 251}) // OITAVA MANUTENCAO
//
aAdd(aVX5,{"015","NORM" ,"#STR#"				,"S","",0, 180}) // NORMAL
aAdd(aVX5,{"015","AMS"  ,"#STR#"				,"S","",0, 252}) // COM AMS
aAdd(aVX5,{"015","TRACK","WITH TRACK NOT WHEELS","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"015","TRAMS","TRACK WITH AMS"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5,{"016","01","#STR#"					,"S","",0, 253}) // NOVO
aAdd(aVX5,{"016","02","#STR#"					,"S","",0, 254}) // ENVIADO
aAdd(aVX5,{"016","03","#STR#"					,"S","",0, 255}) // APROVADO (PAGO)
aAdd(aVX5,{"016","04","#STR#"					,"S","",0, 256}) // REJEITADO
aAdd(aVX5,{"016","05","#STR#"					,"S","",0, 257}) // DELETADO
aAdd(aVX5,{"016","06","#STR#"					,"S","",0, 258}) // ENCAMINHADO
aAdd(aVX5,{"016","07","#STR#"					,"S","",0, 259}) // RETORNADO
aAdd(aVX5,{"016","08","#STR#"					,"S","",0, 260}) // REVISADO
aAdd(aVX5,{"016","09","#STR#"					,"S","",0, 261}) // AGUARDANDO NF
aAdd(aVX5,{"016","12","#STR#"					,"S","",0, 262}) // NF ATUALIZADA
aAdd(aVX5,{"016","15","#STR#"					,"S","",0, 263}) // DEBITADO
//
aAdd(aVX5,{"017","WTYLABORA","#STR#"			,"S","",0, 264}) // CONSERTAR
aAdd(aVX5,{"017","WTYLABORB","#STR#"			,"S","",0, 265}) // LIMPAR
aAdd(aVX5,{"017","WTYLABORC","#STR#"			,"S","",0, 266}) // SOLDAR
aAdd(aVX5,{"017","WTYLABORD","#STR#"			,"S","",0, 267}) // SERVICO ESPECIAL
aAdd(aVX5,{"017","WTYLABORI","#STR#"			,"S","",0, 268}) // REMOVER
aAdd(aVX5,{"017","WTYLABORJ","#STR#"			,"S","",0, 269}) // TEMPO DESLOCAMENTO
aAdd(aVX5,{"017","WTYLABORK","#STR#"			,"S","",0, 270}) // PULVERIZAR
aAdd(aVX5,{"017","WTYLABORL","#STR#"			,"S","",0, 271}) // DIAGNOSTICO
aAdd(aVX5,{"017","WTYLABORM","#STR#"			,"S","",0, 272}) // TEMPO ACESSO
//
aAdd(aVX5,{"018","01","#STR#"					,"S","",0, 273}) // OFICINA
aAdd(aVX5,{"018","02","#STR#"					,"S","",0, 274}) // CAMPO
//
aAdd(aVX5,{"019","FASF","#STR#"					,"S","",0, 275}) // TROCA QUANDO FALHA
aAdd(aVX5,{"019","MALF","#STR#"					,"S","",0, 276}) // OBRIGATORIO
aAdd(aVX5,{"019","OPT" ,"#STR#"					,"S","",0, 277}) // OPCIONAL
aAdd(aVX5,{"019","PEP" ,"#STR#"					,"S","",0, 278}) // PROGRAMA DE MELHORAMENTO DE PRODUTO
aAdd(aVX5,{"019","SAFT","#STR#"					,"S","",0, 279}) // SEGURANCA
//
aAdd(aVX5,{"020","B","#STR#"					,"S","",0, 280}) //GARANTIA BASICA
aAdd(aVX5,{"020","C","WEAR ASSURANCE"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","D","#STR#"					,"S","",0, 281}) // GARANTIA PREDETERMINADA
aAdd(aVX5,{"020","E","#STR#"					,"S","",0, 282}) // GARANTIA DE MOTOR
aAdd(aVX5,{"020","F","MAIN FRAME"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","G","EXTENDED WARRANTY (ENGINE)","S","",0,  0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","H","EXTENDED WARRANTY (POWERTRAIN & HYDRAULIC)","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","J","JD PROMISE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","M","EMISSIONS WARRANTY"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","P","EXTENDED WARRANTY (POWERTRAIN)","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","Q","LIMITED BASIC"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","S","STRUCTUREALL"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","U","FACTORY UNDERCARRIAGE"	,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","V","MAX LIFE"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","W","WET TURN"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"020","X","EXTENDED WARRANTY (COMPREHENSIVE)","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5,{"021","AVAL","#STR#"					,"S","",0, 283}) // DISPONIVEL
//
aAdd(aVX5,{"022","WTYSUBL1","#STR#"				,"S","",0, 284}) // TAXAS MEIO AMBIENTE
aAdd(aVX5,{"022","WTYSUBL2","#STR#"				,"S","",0, 285}) // SUBLOCACAO
aAdd(aVX5,{"022","WTYSUBL3","#STR#"				,"S","",0, 286}) // REEMBOLSO REFRIG./ADITIVO
aAdd(aVX5,{"022","WTYSUBL4","HAULING (U.S. SOUTH DAKOTA DEALERS ONLY)","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"022","WTYSUBL5","#STR#"				,"S","",0, 287}) // DESLOCAMENTO - KM
aAdd(aVX5,{"022","WTYSUBL6","#STR#"				,"S","",0, 288}) // DESLOCAMENTO - MILHAS
aAdd(aVX5,{"022","WTYSUBL7","#STR#"				,"S","",0, 289}) // OUTROS
aAdd(aVX5,{"022","WTYSUBL8","#STR#"				,"S","",0, 290}) // DESLOCAMENTO - FIXO
//
aAdd(aVX5,{"023","NEW" ,"#STR#"					,"S","",0, 291}) // MAQUINA NOVA
aAdd(aVX5,{"023","USED","#STR#"					,"S","",0, 292}) // MAQUINA USADA
aAdd(aVX5,{"023","PRNT","PREVIOUSLY RENTED"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","RNTL","RENTAL MACHINE"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","CHCK","CONSULT MACHINE NOTES"	,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","CVFM","CONVERSION FORM REQUIRED","S","",0, 0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","DEMO","#STR#"					,"S","",0, 293}) // DEMONSTRACAO
aAdd(aVX5,{"023","DMGD","DAMAGED"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","LCUK","LOCATION UNKNOWN"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","MGRT","MIGRATED"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","ONRT","RENTAL MACHINE"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","PRMS","JD PROMISE"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","STL1","SECURITY ISSUE"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","STL2","SECURITY ISSUE"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","STLP","#STR#"					,"S","",0, 294}) // PROB. PLACA DE NUMERO SERIE
aAdd(aVX5,{"023","SUSP","#STR#"					,"S","",0, 295}) // GARANTIA SUSPENSA
aAdd(aVX5,{"023","VOID","#STR#"					,"S","",0, 296}) // GARANTIA ANULADA
aAdd(aVX5,{"023","WTOF","INSURANCE WRITE-OFF"	,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","WXT1","APPROVED FOR WTY EXT WHEN SOLD","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","WXT2","WARRANTY ALLOWED WHEN SOLD"	,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","WXT3","WARRANTY END DATE EXTENDED"	,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"023","FOWN","#STR#"					,"S","",0, 297}) // PRIMEIRO DONO
aAdd(aVX5,{"023","SCRP","SCRAPPED"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5,{"024","71","#STR#"					,"S","",0, 298}) // BATERIA CELULA MORTA
aAdd(aVX5,{"024","72","#STR#"					,"S","",0, 299}) // CASO DEFEITUOSO
aAdd(aVX5,{"024","73","#STR#"					,"S","",0, 300}) // POLARIDADE INVERTIDA
aAdd(aVX5,{"024","74","#STR#"					,"S","",0, 301}) // NAO SEGURA CARGA
aAdd(aVX5,{"024","75","#STR#"					,"S","",0, 302}) // OUTRO (REQUER EXPLICACAO)
	  //
aAdd(aVX5,{"029","0","#STR#"					,"S","",0, 303}) // NENHUMA PECA DEVE SER RETORNADA
aAdd(aVX5,{"029","1","#STR#"					,"S","",0, 304}) // PECA DEVE SER RETORNADA
aAdd(aVX5,{"029","2","#STR#"					,"S","",0, 305}) // ALGUMAS PECAS DEVEM SER RETORNADA
aAdd(aVX5,{"029","3","#STR#"					,"S","",0, 306}) // TODAS AS PECAS RECEBIDAS
aAdd(aVX5,{"029","4","#STR#"					,"S","",0, 307}) // NENHUMA PECA RECEBIDA
aAdd(aVX5,{"029","5","#STR#"					,"S","",0, 308}) // ALGUMAS PECAS RETORNADAS
aAdd(aVX5,{"029","6","#STR#"					,"S","",0, 309}) // TODAS AS PECAS RETORNADAS
aAdd(aVX5,{"029","7","#STR#"					,"S","",0, 310}) // NENHUMA PECA RETORNADA
aAdd(aVX5,{"029","8","#STR#"					,"S","",0, 311}) // PECA ERRADA RETORNADA
//
aAdd(aVX5,{"036","ORD_EMER","MD"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"036","ORD_ISO" ,"IS"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"036","ORD_SO"  ,"SO"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"036","ORD_TS"  ,"TS"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"036","ORD_WO"  ,"WO"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"036","ORD_PFS" ,"PF"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5,{"050","0" , "#STR#"					,"S","",0,  57}) // Interno
aAdd(aVX5,{"050","1" , "#STR#"					,"S","",0,  58}) // Externo
   //
aAdd(aVX5,{"071","2" , "#STR#"					,"S","",0, 312}) // Compra
//
aAdd(aVX5,{"072","1" , "#STR#"					,"S","",0, 313}) // Ativo
aAdd(aVX5,{"072","2" , "#STR#"					,"S","",0, 314}) // Expirado
aAdd(aVX5,{"072","4" , "#STR#"					,"S","",0, 315}) // Venda Fechada
aAdd(aVX5,{"072","14", "Inquiry"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"072","16", "#STR#"					,"S","",0, 316}) // Venda Perdida
aAdd(aVX5,{"072","17", "#STR#"					,"S","",0, 317}) // Sem Compra
aAdd(aVX5,{"072","18", "#STR#"					,"S","",0, 318}) // Comprou equipamento usado
//
aAdd(aVX5,{"073","7" , "#STR#"					,"S","",0, 319}) // Suporte de Pós Vendas
aAdd(aVX5,{"073","8" , "#STR#"					,"S","",0, 320}) // Confiabilidade do Produto
aAdd(aVX5,{"073","9" , "#STR#"					,"S","",0, 321}) // Desempenho do Produto
aAdd(aVX5,{"073","10", "#STR#"					,"S","",0, 322}) // Disponibilidade do Produto
aAdd(aVX5,{"073","11", "#STR#"					,"S","",0, 323}) // Especificações do Produto
aAdd(aVX5,{"073","12", "Product knowledge (demonstration)","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"073","13", "Residual value"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"073","14", "#STR#"					,"S","",0, 324}) // Oferta de Usado
aAdd(aVX5,{"073","15", "#STR#"					,"S","",0, 325}) // Fidelidade à marca ou distribuidor concorrente
aAdd(aVX5,{"073","16", "#STR#"					,"S","",0, 326}) // Preço
aAdd(aVX5,{"073","17", "#STR#"					,"S","",0, 327}) // Opções de Financiamento
aAdd(aVX5,{"073","18", "#STR#"					,"S","",0, 328}) // Custo de manutenção
aAdd(aVX5,{"073","19", "#STR#"					,"S","",0, 329}) // Outros
//
aAdd(aVX5,{"074", "1"  ,"AGRIFAC"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "2"  ,"AGRITECHNOLOGICAL CENTRE","S","",0, 0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "3"  ,"AGROTEKHMASH"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "4"  ,"ALKO"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "5"  ,"ALÖ QUICKE"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "6"  ,"AMAZONE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "7"  ,"AMITY"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "8"  ,"ATV"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "9"  ,"AUTOFARM"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "10" ,"BALTIETS"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "11" ,"BARGAM"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "12" ,"BATEMAN"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "13" ,"BERTHOUD"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "14" ,"BISO"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "15" ,"BOURGAULT"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "16" ,"BRYANSKSELMASH"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "17" ,"CAPELLO"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "18" ,"CASE IH"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "19" ,"CASTEL GARDEN"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "20" ,"CHAFER"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "21" ,"CHALLENGER / AGCO"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "22" ,"CLAAS"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "23" ,"CNH"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "24" ,"CRESSONI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "25" ,"DAMMAN"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "26" ,"DEGELMANN"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "27" ,"DEUTZ-FAHR"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "28" ,"DOMINONI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "29" ,"EINBOCK"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "30" ,"EVRARD"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "31" ,"FAHR"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "32" ,"FANTINI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "33" ,"FELLA"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "34" ,"FENDT"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "35" ,"FERABOLLI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "36" ,"FLEXICOIL"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "37" ,"GASPARDO"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "38" ,"GERINGHOFF"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "39" ,"GHERARDI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "40" ,"GREAT PLAINS"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "41" ,"GREGOIRE BESSON"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "42" ,"HARDI"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "43" ,"HATZENBICHLER"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "44" ,"HAUER"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "45" ,"HAYTER"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "46" ,"HONDA"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "47" ,"HONEY BEE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "48" ,"HORSCH"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "49" ,"HOUSEHAM"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "50" ,"HTZ"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "51" ,"HURLIMANN"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "52" ,"HUSQVARNA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "53" ,"HYDRAC"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "54" ,"IDAAS"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "55" ,"ISAGRI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "56" ,"ISEKI"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "57" ,"JACOBSON"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "58" ,"JACTO"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "59" ,"JCB"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "60" ,"JOHN DEERE"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "61" ,"KINZE"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "62" ,"KIOTI"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "63" ,"KNIGHT"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "64" ,"KRASNOYARSKIY COMBINE PLANT","S","",0,  0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "65" ,"KRAUSE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "66" ,"KRONE"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "67" ,"KUBOTA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "68" ,"KUHN"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "69" ,"KV - RAU"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "70" ,"KVERNELAND"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "71" ,"LA FORGE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "72" ,"LAMBORGHINI"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "73" ,"LANDINI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "74" ,"LAVERDA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "75" ,"LEMKEN"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "76" ,"MAC HALE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "77" ,"MACDON"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "78" ,"MAILLEUX"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "79" ,"MANIP"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "80" ,"MASCHIO GASPARDO"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "81" ,"MASSEY FERGUSSON"		,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "82" ,"MATERMACC"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "83" ,"MATROT"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "84" ,"MCCORMICK"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "85" ,"MILLER"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "86" ,"MISC."					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "87" ,"MONOSEM"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "88" ,"MONTANA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "89" ,"MORESIL"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "90" ,"MORRIS"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "91" ,"MTD"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "92" ,"MTZ"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "93" ,"MUELLER ELECTRONIC"	,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "94" ,"NEW HOLLAND"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "95" ,"OLIMAC"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "96" ,"PEGORARO"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "97" ,"PETERSBURG TRACTOR PLANT (KIROVETS)","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "98" ,"PLA"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "99" ,"POTTINGER"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "100","RANSOMES"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "101","ROSTSELMASH"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "102","S.E.P."				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "103","SALFORD"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "104","SAME"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "105","SANDS"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "106","SATPLAN"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "107","SHIBAURA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "108","STOLL"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "109","STRAWMASTER"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "110","STROM"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "111","SUNFLOWER"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "112","TARUP"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "113","TECNOMA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "114","TOPCON"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "115","TORO"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "116","TRIMA-BAAS"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "117","TRIMBLE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "118","UNIA"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "119","VADERSTAD"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "120","VALPADANA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "121","VALTRA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "122","VERSATILE"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "123","VICON"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "124","VIKING"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "125","VLADIMIR TRACTOR PLANT","S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "126","VOGEL & NOOT"			,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "127","VOLGOGRAD TRACTOR PLANT","S","",0,  0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "128","WELGER"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "129","WOLF"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "130","YAMAHA"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "131","YANMAR"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "132","ZUCCHETTI"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "133","ZUERN"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "134","OTHER"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "135","NONE"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "136","POLARIS"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "142","ZETOR"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "143","URSUS"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
aAdd(aVX5,{"074", "144","PRONAR"				,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
// cCodMar == "NHC" // Especificos para a marca New Holland Construction
//
aAdd(aVX5, {"039", "1", "#STR#"					,"S","",0, 330}) // ESTOQUE
aAdd(aVX5, {"039", "3", "#STR#"					,"S","",0, 331}) // CLIENTES
//
aAdd(aVX5, {"040","01","#STR#"					,"S","",0, 332}) // REVISOES - INSPECOES
aAdd(aVX5, {"040","02","#STR#"					,"S","",0, 333}) // REGULAGEM, CALIBRACAO OU AJUSTE INTERNO
aAdd(aVX5, {"040","03","#STR#"					,"S","",0, 334}) // REPARO DE SERVICO AUTORIZADO
aAdd(aVX5, {"040","06","#STR#"					,"S","",0, 335}) // NAO FUNCIONAMENTO
aAdd(aVX5, {"040","07","#STR#"					,"S","",0, 336}) // DESEMPENHO INSUFICIENTE
aAdd(aVX5, {"040","08","#STR#"					,"S","",0, 337}) // PARTIDA DIFICIL
aAdd(aVX5, {"040","09","#STR#"					,"S","",0, 338}) // EXCESSO DE RUIDOS
aAdd(aVX5, {"040","10","#STR#"					,"S","",0, 339}) // EXCESSO DE VIBRACAO
aAdd(aVX5, {"040","11","#STR#"					,"S","",0, 340}) // EXCESSO DE FUMACA
aAdd(aVX5, {"040","12","#STR#"					,"S","",0, 341}) // LUBRIFICACAO INSUFICIENTE
aAdd(aVX5, {"040","15","#STR#"					,"S","",0, 342}) // PERDAS DE PRESSAO
aAdd(aVX5, {"040","16","#STR#"					,"S","",0, 343}) // PRESSAO IRREGULAR OU INSUFICIENTE
aAdd(aVX5, {"040","17","#STR#"					,"S","",0, 344}) // CONSUMO EXCESSIVO DE COMBUSTIVEL
aAdd(aVX5, {"040","18","#STR#"					,"S","",0, 345}) // CONSUMO EXCESSO DE OLEO LUBRIFICANTE
aAdd(aVX5, {"040","24","#STR#"					,"S","",0, 346}) // ABERTURA EM APURACAO
aAdd(aVX5, {"040","25","#STR#"					,"S","",0, 347}) // DIFICULDADE DE OPERACAO ESFORCO EXCESSIVO
aAdd(aVX5, {"040","26","#STR#"					,"S","",0, 348}) // DIFICULDADE NA ABERTURA OU FECHAMENTO
aAdd(aVX5, {"040","27","#STR#"					,"S","",0, 349}) // DESENGATE ESPONTANEO
aAdd(aVX5, {"040","28","#STR#"					,"S","",0, 350}) // VIBRACAO
aAdd(aVX5, {"040","29","#STR#"					,"S","",0, 351}) // PATINAMENTO
aAdd(aVX5, {"040","30","#STR#"					,"S","",0, 352}) // FALHA NA SEGURANCA
aAdd(aVX5, {"040","31","#STR#"					,"S","",0, 353}) // ENDURECIMENTO
aAdd(aVX5, {"040","32","#STR#"					,"S","",0, 354}) // TRAVAMENTO
aAdd(aVX5, {"040","33","#STR#"					,"S","",0, 355}) // INTERFERENCIA
aAdd(aVX5, {"040","34","#STR#"					,"S","",0, 356}) // CURSO IRREGULAR
aAdd(aVX5, {"040","35","#STR#"					,"S","",0, 357}) // FALHA NO RETORNO
aAdd(aVX5, {"040","38","#STR#"					,"S","",0, 358}) // FIXACAO INSUFICIENTE
aAdd(aVX5, {"040","39","#STR#"					,"S","",0, 359}) // FOLGA EXCESSIVA
aAdd(aVX5, {"040","40","#STR#"					,"S","",0, 360}) // DESALINHAMENTO OU FORA DO ESQUADRO
aAdd(aVX5, {"040","44","#STR#"					,"S","",0, 361}) // ONDULACAO - ENRUGAMENTO
aAdd(aVX5, {"040","45","#STR#"					,"S","",0, 362}) // DEFORMACAO - EMPENAMENTO
aAdd(aVX5, {"040","46","#STR#"					,"S","",0, 363}) // CORROSAO - DESCAMACAO
aAdd(aVX5, {"040","47","#STR#"					,"S","",0, 364}) // DESGASTE - FORMACAO DE SULCOS
aAdd(aVX5, {"040","48","#STR#"					,"S","",0, 365}) // RUPTURA - TRINCA
aAdd(aVX5, {"040","49","#STR#"					,"S","",0, 366}) // RUPTURA DA ROSCA
aAdd(aVX5, {"040","50","#STR#"					,"S","",0, 367}) // RACHADURA
aAdd(aVX5, {"040","51","#STR#"					,"S","",0, 368}) // DESGASTE
aAdd(aVX5, {"040","52","#STR#"					,"S","",0, 369}) // SUPER AQUECIMENTO
aAdd(aVX5, {"040","53","#STR#"					,"S","",0, 370}) // QUEIMA
aAdd(aVX5, {"040","54","#STR#"					,"S","",0, 371}) // CURTO - CIRCUITO
aAdd(aVX5, {"040","55","#STR#"					,"S","",0, 372}) // MAU CONTATO
aAdd(aVX5, {"040","58","#STR#"					,"S","",0, 373}) // VAZAMENTO DE OLEO
aAdd(aVX5, {"040","59","#STR#"					,"S","",0, 374}) // VAZAMENTO DE COMBUSTIVEL
aAdd(aVX5, {"040","60","#STR#"					,"S","",0, 375}) // VAZAMENTO DE AGUA E ADITIVO
aAdd(aVX5, {"040","61","#STR#"					,"S","",0, 376}) // VAZAMENTO DE FREON
aAdd(aVX5, {"040","63","#STR#"					,"S","",0, 377}) // NIVEL DE FLUIDO BAIXO
aAdd(aVX5, {"040","64","#STR#"					,"S","",0, 378}) // FALTA DE PECAS NA MONTAGEM
aAdd(aVX5, {"040","66","#STR#"					,"S","",0, 379}) // MONTAGEM DEFEITUOSA
aAdd(aVX5, {"040","67","#STR#"					,"S","",0, 380}) // DEFEITO DO PROCESSO
aAdd(aVX5, {"040","68","#STR#"					,"S","",0, 381}) // DEFEITO NA SOLDA
aAdd(aVX5, {"040","69","#STR#"					,"S","",0, 382}) // DEFEITOS DE FUNDICAO
aAdd(aVX5, {"040","75","#STR#"					,"S","",0, 383}) // ENTUPIMENTO, OBSTRUCAO
aAdd(aVX5, {"040","76","#STR#"					,"S","",0, 384}) // PRESENCA DE MATERIAL ESTRANHO OU IMPUREZAS
aAdd(aVX5, {"040","78","#STR#"					,"S","",0, 385}) // INFILTRACAO OU ACUMULO DE AGUA
aAdd(aVX5, {"040","79","#STR#"					,"S","",0, 386}) // INFILTRACAO DE AR
aAdd(aVX5, {"040","80","#STR#"					,"S","",0, 387}) // ENTRADA DE POEIRA
aAdd(aVX5, {"040","81","#STR#"					,"S","",0, 388}) // ENTRADA DE GAS DE ESCAPE
aAdd(aVX5, {"040","86","#STR#"					,"S","",0, 389}) // AMASSADO
aAdd(aVX5, {"040","87","#STR#"					,"S","",0, 390}) // OXIDACAO - CORROSAO
aAdd(aVX5, {"040","88","#STR#"					,"S","",0, 391}) // FALHA DE VEDACAO
aAdd(aVX5, {"040","90","#STR#"					,"S","",0, 392}) // DEFORMADO DA PINTURA
aAdd(aVX5, {"040","91","#STR#"					,"S","",0, 393}) // MANCHAS OU ALTERACAO DA COR
aAdd(aVX5, {"040","93","#STR#"					,"S","",0, 394}) // ARRANHAO, DESCASCADO
aAdd(aVX5, {"040","94","#STR#"					,"S","",0, 395}) // PINTURA INSUFICIENTE
aAdd(aVX5, {"040","95","#STR#"					,"S","",0, 396}) // PINTURA RACHADA
aAdd(aVX5, {"040","96","#STR#"					,"S","",0, 397}) // BOLHAS NA PINTURA
//
aAdd(aVX5, {"041","10","#STR#"					,"S","",0, 180}) // NORMAL
aAdd(aVX5, {"041","19","#STR#"					,"S","",0, 398}) // BALCAO
aAdd(aVX5, {"041","23","PMP"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5, {"042","STD","STD"					,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
// cCodMar $ "CHL-MSF-VAL-FDT" // Especificos para as marcas Challenger, Massey Ferguson e Valtra (AGCO)
//
aAdd(aVX5,{"078","9111","#STR#"					,"S","",0, 399}) // Diretores
aAdd(aVX5,{"078","9112","#STR#"					,"S","",0, 400}) // Gerentes
aAdd(aVX5,{"078","9113","#STR#"					,"S","",0, 401}) // Supervisores
aAdd(aVX5,{"078","9114","#STR#"					,"S","",0, 402}) // Coordenadores
aAdd(aVX5,{"078","9115","#STR#"					,"S","",0, 403}) // Vendedores
aAdd(aVX5,{"078","9116","#STR#"					,"S","",0, 404}) // Analistas
aAdd(aVX5,{"078","9117","#STR#"					,"S","",0, 405}) // Assistentes
aAdd(aVX5,{"078","9118","#STR#"					,"S","",0, 406}) // Auxiliares
aAdd(aVX5,{"078","9119","#STR#"					,"S","",0, 399}) // Diretores
aAdd(aVX5,{"078","9211","#STR#"					,"S","",0, 407}) // Novos
aAdd(aVX5,{"078","9212","#STR#"					,"S","",0, 408}) // Usados
aAdd(aVX5,{"078","9213","#STR#"					,"S","",0, 409}) // Outros Negócios
aAdd(aVX5,{"078","9311","#STR#"					,"S","",0, 410}) // Trator
aAdd(aVX5,{"078","9312","#STR#"					,"S","",0, 411}) // Colheitadeira
aAdd(aVX5,{"078","9313","#STR#"					,"S","",0, 412}) // Colhedora
aAdd(aVX5,{"078","9314","#STR#"					,"S","",0, 413}) // Plantadeira
aAdd(aVX5,{"078","9315","#STR#"					,"S","",0, 414}) // Pulverizador
aAdd(aVX5,{"078","9316","#STR#"					,"S","",0, 415}) // Plataforma
aAdd(aVX5,{"078","9317","#STR#"					,"S","",0, 416}) // Implementos
aAdd(aVX5,{"078","9318","#STR#"					,"S","",0, 329}) // Outros
aAdd(aVX5,{"078","9411","#STR#"					,"S","",0, 410}) // Trator
aAdd(aVX5,{"078","9412","#STR#"					,"S","",0, 411}) // Colheitadeira
aAdd(aVX5,{"078","9413","#STR#"					,"S","",0, 412}) // Colhedora
aAdd(aVX5,{"078","9414","#STR#"					,"S","",0, 413}) // Plantadeira
aAdd(aVX5,{"078","9415","#STR#"					,"S","",0, 414}) // Pulverizador
aAdd(aVX5,{"078","9416","#STR#"					,"S","",0, 415}) // Plataforma
aAdd(aVX5,{"078","9417","#STR#"					,"S","",0, 416}) // Implementos
aAdd(aVX5,{"078","9418","#STR#"					,"S","",0, 329}) // Outros
aAdd(aVX5,{"078","9419","#STR#"					,"S","",0, 411}) // Colheitadeira
aAdd(aVX5,{"078","9420","#STR#"					,"S","",0, 412}) // Colhedora
aAdd(aVX5,{"078","9421","#STR#"					,"S","",0, 413}) // Plantadeira
aAdd(aVX5,{"078","9422","#STR#"					,"S","",0, 414}) // Pulverizador
aAdd(aVX5,{"078","9423","#STR#"					,"S","",0, 415}) // Plataforma
aAdd(aVX5,{"078","9424","#STR#"					,"S","",0, 416}) // Implementos
aAdd(aVX5,{"078","9511","#STR#"					,"S","",0, 417}) // Horas Disponíveis
aAdd(aVX5,{"078","9512","#STR#"					,"S","",0, 418}) // Horas Faturadas
aAdd(aVX5,{"078","9513","#STR#"					,"S","",0, 419}) // Tempo de O.S.
aAdd(aVX5,{"078","9514","#STR#"					,"S","",0, 420}) // Valor O.S. em Aberto
aAdd(aVX5,{"078","9611","#STR#"					,"S","",0, 421}) // Tempo de Pedido
aAdd(aVX5,{"078","9612","#STR#"					,"S","",0, 418}) // Horas Faturadas
aAdd(aVX5,{"078","9613","#STR#"					,"S","",0, 422}) // Valor Pedidos Abertos
//
aAdd(aVX5,{"079","1101","#STR#"					,"S","",0, 423}) // Máquinas Novas
aAdd(aVX5,{"079","1102","#STR#"					,"S","",0, 424}) // Máquinas Usadas
aAdd(aVX5,{"079","1201","#STR#"					,"S","",0, 425}) // Peças
aAdd(aVX5,{"079","1301","#STR#"					,"S","",0, 426}) // Serviços
aAdd(aVX5,{"079","1401","#STR#"					,"S","",0, 427}) // Administrativo
aAdd(aVX5,{"079","1501","#STR#"					,"S","",0, 409}) // Outros Negócios
//
aAdd(aVX5,{"080","1111","#STR#"					,"S","",0, 428}) // Disponibilidades Imediatas
aAdd(aVX5,{"080","1121","#STR#"					,"S","",0, 429}) // Contas a Receber Maquinas Novas
aAdd(aVX5,{"080","1122","#STR#"					,"S","",0, 430}) // Contas a Receber Maquinas Usadas
aAdd(aVX5,{"080","1123","#STR#"					,"S","",0, 431}) // Contas a Receber Peças
aAdd(aVX5,{"080","1124","#STR#"					,"S","",0, 432}) // Contas a Receber Serviços
aAdd(aVX5,{"080","1125","#STR#"					,"S","",0, 433}) // Contas a Receber Comissões e Consórcios
aAdd(aVX5,{"080","1126","#STR#"					,"S","",0, 434}) // Contas a Receber Outros
aAdd(aVX5,{"080","1127","#STR#"					,"S","",0, 435}) // Empresas Coligadas
aAdd(aVX5,{"080","1128","#STR#"					,"S","",0, 436}) // Consorcio em Andamento
aAdd(aVX5,{"080","1131","#STR#"					,"S","",0, 437}) // Adiantamentos Fornecedores
aAdd(aVX5,{"080","1132","#STR#"					,"S","",0, 438}) // Adiantamentos Funcionários
aAdd(aVX5,{"080","1133","#STR#"					,"S","",0, 439}) // Despesas Antecipadas - Curto Prazo
aAdd(aVX5,{"080","1139","#STR#"					,"S","",0, 440}) // Outros Adiantamentos
aAdd(aVX5,{"080","1141","#STR#"					,"S","",0, 441}) // Impostos a Compensar e Recuperar Curto Prazo
aAdd(aVX5,{"080","1151","#STR#"					,"S","",0, 442}) // Máquinas e Implementos AGCO - Novos
aAdd(aVX5,{"080","1152","#STR#"					,"S","",0, 443}) // Máquinas e Implementos AGCO - Usados
aAdd(aVX5,{"080","1153","#STR#"					,"S","",0, 444}) // Máquinas e Implementos Outras Marcas - Novos
aAdd(aVX5,{"080","1154","#STR#"					,"S","",0, 445}) // Máquinas e Implementos Outras Marcas - Usados
aAdd(aVX5,{"080","1155","#STR#"					,"S","",0, 446}) // Peças AGCO
aAdd(aVX5,{"080","1156","#STR#"					,"S","",0, 447}) // Peças Outras Marcas
aAdd(aVX5,{"080","1157","#STR#"					,"S","",0, 448}) // Estoque de Outros Negócios - AGCO
aAdd(aVX5,{"080","1158","#STR#"					,"S","",0, 449}) // Estoque de Outros Negócios
aAdd(aVX5,{"080","1159","(-) #STR#"				,"S","",0, 450}) // Estoques - Ajuste a Valor Presente
aAdd(aVX5,{"080","1160","(-) #STR#"				,"S","",0, 451}) // Provisão de Estoque Obsoleto
aAdd(aVX5,{"080","1194","(-) #STR#"				,"S","",0, 452}) // Devolução de Vendas
aAdd(aVX5,{"080","1195","#STR#"					,"S","",0, 453}) // Valores em Transito
aAdd(aVX5,{"080","1196","(-) #STR#"				,"S","",0, 454}) // Contas a Receber - Ajuste a Valor Presente
aAdd(aVX5,{"080","1197","(-) #STR#"				,"S","",0, 455}) // PCLD - Provisão de Créditos Duvidosos
aAdd(aVX5,{"080","1198","#STR#"					,"S","",0, 456}) // Outros Créditos
aAdd(aVX5,{"080","1199","#STR#"					,"S","",0, 457}) // Fundo AGCO
aAdd(aVX5,{"080","1211","#STR#"					,"S","",0, 458}) // Contas a Receber - Vendas - Longo Prazo - Novos
aAdd(aVX5,{"080","1212","#STR#"					,"S","",0, 459}) // Contas a Receber - Vendas - Longo Prazo - Usados
aAdd(aVX5,{"080","1213","#STR#"					,"S","",0, 460}) // Aplicações Financeiras - Longo Prazo
aAdd(aVX5,{"080","1214","#STR#"					,"S","",0, 461}) // Consórcio
aAdd(aVX5,{"080","1215","#STR#"					,"S","",0, 462}) // Créditos com Partes Relacionadas - LP
aAdd(aVX5,{"080","1216","(-) #STR#"				,"S","",0, 463}) // Investimentos Permanentes - Ajuste a Valor Presente
aAdd(aVX5,{"080","1217","(-) #STR#"				,"S","",0, 464}) // Contas a Receber LP - Ajuste a Valor Presente
aAdd(aVX5,{"080","1221","#STR#"					,"S","",0, 465}) // Impostos Diferidos
aAdd(aVX5,{"080","1225","#STR#"					,"S","",0, 466}) // Despesas Antecipadas - Longo Prazo
aAdd(aVX5,{"080","1229","#STR#"					,"S","",0, 456}) // Outros Créditos
aAdd(aVX5,{"080","1231","#STR#"					,"S","",0, 467}) // Terrenos
aAdd(aVX5,{"080","1232","#STR#"					,"S","",0, 468}) // Construções e Prédios
aAdd(aVX5,{"080","1233","#STR#"					,"S","",0, 469}) // Máquinas/equipamentos e ferramentas
aAdd(aVX5,{"080","1234","#STR#"					,"S","",0, 470}) // Móveis e Utensílios
aAdd(aVX5,{"080","1235","#STR#"					,"S","",0, 471}) // Veículos
aAdd(aVX5,{"080","1236","#STR#"					,"S","",0, 472}) // Frota para Locação
aAdd(aVX5,{"080","1237","#STR#"					,"S","",0, 473}) // Imobilizado outros
aAdd(aVX5,{"080","1238","#STR#"					,"S","",0, 474}) // Benfeitorias em prédio de Terceiros
aAdd(aVX5,{"080","1239","#STR#"					,"S","",0, 475}) // Consorcios em Andamentos para Imobilizado
aAdd(aVX5,{"080","1240","#STR#"					,"S","",0, 476}) // Computadores e Perifericos
aAdd(aVX5,{"080","1296","(-) #STR#"				,"S","",0, 477}) // Aplicações Financeiras LP - Ajuste a Valor Presente
aAdd(aVX5,{"080","1297","(-) #STR#"				,"S","",0, 478}) // Ativo Imobilizado - Ajuste a Valor Presente
aAdd(aVX5,{"080","1298","#STR#"					,"S","",0, 479}) // Intangível
aAdd(aVX5,{"080","1299","(-) #STR#"				,"S","",0, 480}) // Depreciação e Amortização
aAdd(aVX5,{"080","2111","#STR#"					,"S","",0, 481}) // Fornecedores Maquinas Novas
aAdd(aVX5,{"080","2112","#STR#"					,"S","",0, 482}) // Fornecedores Maquinas Usadas
aAdd(aVX5,{"080","2113","#STR#"					,"S","",0, 483}) // Fornecedores Peças
aAdd(aVX5,{"080","2114","#STR#"					,"S","",0, 484}) // Fornecedores Serviços
aAdd(aVX5,{"080","2115","#STR#"					,"S","",0, 485}) // Fornecedores Outros
aAdd(aVX5,{"080","2116","#STR#"					,"S","",0, 486}) // Contas a Pagar Partes Relacionadas
aAdd(aVX5,{"080","2117","#STR#"					,"S","",0, 487}) // Outras contas a pagar
aAdd(aVX5,{"080","2118","#STR#"					,"S","",0, 488}) // Contas a Pagar Empresas Coligadas
aAdd(aVX5,{"080","2121","#STR#"					,"S","",0, 489}) // Financiamentos AGCO FINANCE CP
aAdd(aVX5,{"080","2122","#STR#"					,"S","",0, 490}) // Empréstimos Bancários CP
aAdd(aVX5,{"080","2123","#STR#"					,"S","",0, 491}) // Outros Empréstimos CP
aAdd(aVX5,{"080","2124","#STR#"					,"S","",0, 492}) // Financiamentos Outros Bancos CP
aAdd(aVX5,{"080","2125","#STR#"					,"S","",0, 493}) // Empréstimos de Sócios CP
aAdd(aVX5,{"080","2126","#STR#"					,"S","",0, 494}) // Leasing a Pagar CP
aAdd(aVX5,{"080","2127","#STR#"					,"S","",0, 495}) // Duplicatas Descontadas
aAdd(aVX5,{"080","2128","#STR#"					,"S","",0, 496}) // Financiamentos FINAME
aAdd(aVX5,{"080","2130","(-) #STR#"				,"S","",0, 497}) // Ajuste a Valor Presente - Empréstimos
aAdd(aVX5,{"080","2131","#STR#"					,"S","",0, 498}) // Salários e Bônus a Pagar
aAdd(aVX5,{"080","2132","#STR#"					,"S","",0, 499}) // Obrigações Trabalhistas a Recolher
aAdd(aVX5,{"080","2133","#STR#"					,"S","",0, 500}) // Provisões Trabalhistas
aAdd(aVX5,{"080","2141","#STR#"					,"S","",0, 501}) // Obrigações Tributárias a Recolher
aAdd(aVX5,{"080","2142","#STR#"					,"S","",0, 502}) // Outras Obrigações Fiscais a Recolher
aAdd(aVX5,{"080","2151","#STR#"					,"S","",0, 503}) // Adiantamento de Clientes
aAdd(aVX5,{"080","2152","#STR#"					,"S","",0, 504}) // Outros Adiantamentos
aAdd(aVX5,{"080","2161","#STR#"					,"S","",0, 505}) // Dividendos a Pagar
aAdd(aVX5,{"080","2162","#STR#"					,"S","",0, 506}) // Consórcios a Pagar
aAdd(aVX5,{"080","2163","#STR#"					,"S","",0, 507}) // Faturamento para Entrega Futura
aAdd(aVX5,{"080","2164","#STR#"					,"S","",0, 508}) // Receitas e Custos Diferidos
aAdd(aVX5,{"080","2165","#STR#"					,"S","",0, 509}) // Impostos Diferidos
aAdd(aVX5,{"080","2166","#STR#"					,"S","",0, 510}) // Valores em Transito
aAdd(aVX5,{"080","2197","(-) #STR#"				,"S","",0, 511}) // Devoluções de Compras
aAdd(aVX5,{"080","2198","(-) #STR#"				,"S","",0, 512}) // Contas a Pagar - Reclassificação para Longo Prazo
aAdd(aVX5,{"080","2199","(-) #STR#"				,"S","",0, 513}) // Ajuste a Valor Presente - Contas a Pagar
aAdd(aVX5,{"080","2211","#STR#"					,"S","",0, 514}) // Financiamentos AGCO FINANCE LP
aAdd(aVX5,{"080","2212","#STR#"					,"S","",0, 515}) // Financiamentos Outros Bancos LP
aAdd(aVX5,{"080","2213","#STR#"					,"S","",0, 516}) // Empréstimos Bancários LP
aAdd(aVX5,{"080","2214","(-) #STR#"				,"S","",0, 517}) // Ajuste a Valor Presente - Empréstimos
aAdd(aVX5,{"080","2221","#STR#"					,"S","",0, 518}) // Contas a Pagar - Empresas Coligadas LP
aAdd(aVX5,{"080","2222","#STR#"					,"S","",0, 519}) // Contas a Pagar e Fornecedores LP
aAdd(aVX5,{"080","2223","#STR#"					,"S","",0, 520}) // Outros Investimentos a pagar
aAdd(aVX5,{"080","2224","#STR#"					,"S","",0, 521}) // Contas a Pagar de Partes Relacionadas LP
aAdd(aVX5,{"080","2225","#STR#"					,"S","",0, 522}) // Outros Empréstimos LP
aAdd(aVX5,{"080","2226","#STR#"					,"S","",0, 523}) // Parcelamento de Tributos
aAdd(aVX5,{"080","2227","#STR#"					,"S","",0, 524}) // Provisões para Contigências
aAdd(aVX5,{"080","2231","#STR#"					,"S","",0, 525}) // Capital Social Integralizado
aAdd(aVX5,{"080","2232","#STR#"					,"S","",0, 526}) // Adiantamentos para Futuro Aumento de Capital
aAdd(aVX5,{"080","2233","#STR#"					,"S","",0, 527}) // Reservas de Lucro
aAdd(aVX5,{"080","2234","#STR#"					,"S","",0, 528}) // Reservas de Capital
aAdd(aVX5,{"080","2235","(-) #STR#"				,"S","",0, 529}) // Ações/Quotas em Tesouraria
aAdd(aVX5,{"080","2236","(-) #STR#"				,"S","",0, 530}) // Dividendos Distribuídos
aAdd(aVX5,{"080","2237","(-) #STR#"				,"S","",0, 531}) // Juros Capital Próprio
aAdd(aVX5,{"080","2238","(-) #STR#"				,"S","",0, 532}) // Prejuízos Acumulado
aAdd(aVX5,{"080","2239","#STR#"					,"S","",0, 533}) // Resultado do Exercício
aAdd(aVX5,{"080","2299","(-) #STR#"				,"S","",0, 534}) // Ajuste a Valor Presente - Outras Contas a Pagar LP
aAdd(aVX5,{"080","3111","#STR#"					,"S","",0, 535}) // Comissões sobre Vendas - Consórcio
aAdd(aVX5,{"080","3112","(-) #STR#"				,"S","",0, 536}) // Dedução de Comissões sobre Vendas - Consórcio
aAdd(aVX5,{"080","3113","#STR#"					,"S","",0, 537}) // Comissões sobre Vendas de Máquinas
aAdd(aVX5,{"080","3114","(-) #STR#"				,"S","",0, 538}) // Dedução de Comissões sobre Vendas de Máquinas
aAdd(aVX5,{"080","3115","#STR#"					,"S","",0, 539}) // Receita com Outras Comissões
aAdd(aVX5,{"080","3116","(-) #STR#"				,"S","",0, 540}) // Dedução de Outras Comissões
aAdd(aVX5,{"080","3117","#STR#"					,"S","",0, 541}) // Máquinas AGCO - Novos
aAdd(aVX5,{"080","3118","(-) #STR#"				,"S","",0, 542}) // Dedução de Máquinas AGCO - Novos
aAdd(aVX5,{"080","3119","#STR#"					,"S","",0, 543}) // Implementos AGCO - Novos
aAdd(aVX5,{"080","3120","(-) #STR#"				,"S","",0, 544}) // Dedução de Implementos AGCO - Novos
aAdd(aVX5,{"080","3121","#STR#"					,"S","",0, 545}) // Implementos Outras Marcas - Novos
aAdd(aVX5,{"080","3122","(-) #STR#"				,"S","",0, 546}) // Dedução de Máquinas Outras Marcas - Novos
aAdd(aVX5,{"080","3131","#STR#"					,"S","",0, 547}) // Máquinas e Implementos AGCO - Usados
aAdd(aVX5,{"080","3132","(-) #STR#"				,"S","",0, 548}) // Dedução de Máquinas e Implementos AGCO - Usados
aAdd(aVX5,{"080","3133","#STR#"					,"S","",0, 549}) // Máquinas e implementos Outras Marcas - Usados
aAdd(aVX5,{"080","3134","(-) #STR#"				,"S","",0, 550}) // Dedução de Máquinas e Implementos Outras Marcas - Usado
aAdd(aVX5,{"080","3211","#STR#"					,"S","",0, 551}) // Receita com Comissões Sobre Vendas de Peças
aAdd(aVX5,{"080","3212","(-) #STR#"				,"S","",0, 552}) // Dedução de Comissões Sobre Vendas de Peças
aAdd(aVX5,{"080","3213","#STR#"					,"S","",0, 553}) // Receitas Peças  AGCO
aAdd(aVX5,{"080","3214","#STR#"					,"S","",0, 554}) // Receitas Peças Oficina AGCO
aAdd(aVX5,{"080","3215","(-) #STR#"				,"S","",0, 555}) // Dedução de Peças AGCO
aAdd(aVX5,{"080","3216","(-) #STR#"				,"S","",0, 556}) // Dedução de Peças Oficina AGCO
aAdd(aVX5,{"080","3221","#STR#"					,"S","",0, 557}) // Peças Outras Marcas
aAdd(aVX5,{"080","3222","#STR#"					,"S","",0, 558}) // Peças Oficina Outras Marcas
aAdd(aVX5,{"080","3223","(-) #STR#"				,"S","",0, 559}) // Dedução de Peças Outras Marcas
aAdd(aVX5,{"080","3224","(-) #STR#"				,"S","",0, 560}) // Dedução de Peças Oficina Outras Marcas
aAdd(aVX5,{"080","3225","#STR#"					,"S","",0, 561}) // Lubrificantes
aAdd(aVX5,{"080","3226","(-) #STR#"				,"S","",0, 562}) // Dedução de Lubrificantes
aAdd(aVX5,{"080","3311","#STR#"					,"S","",0, 563}) // Receita com Serviços Prestados a Clientes
aAdd(aVX5,{"080","3312","(-) #STR#"				,"S","",0, 564}) // Dedução de Serviços Prestados a Clientes
aAdd(aVX5,{"080","3313","#STR#"					,"S","",0, 565}) // Receita com Serviços Internos
aAdd(aVX5,{"080","3314","(-) #STR#"				,"S","",0, 566}) // Dedução de Serviços Internos
aAdd(aVX5,{"080","3315","#STR#"					,"S","",0, 567}) // Receita com Serviços de Garantia
aAdd(aVX5,{"080","3316","(-) #STR#"				,"S","",0, 568}) // Dedução de Serviços de Garantia
aAdd(aVX5,{"080","3317","#STR#"					,"S","",0, 569}) // Receita com Serviços Recall
aAdd(aVX5,{"080","3318","(-) #STR#"				,"S","",0, 570}) // Dedução de Serviços Recall
aAdd(aVX5,{"080","3319","#STR#"					,"S","",0, 571}) // Receita com KM de Serviços de Assistência a Campo
aAdd(aVX5,{"080","3320","(-) #STR#"				,"S","",0, 572}) // Dedução de KM de Serviços de Assistência a Campo
aAdd(aVX5,{"080","3321","#STR#"					,"S","",0, 573}) // Receita com deslocamento de Assistência a Campo
aAdd(aVX5,{"080","3322","(-) #STR#"				,"S","",0, 574}) // Dedução de deslocamento de Assistência a Campo
aAdd(aVX5,{"080","3323","#STR#"					,"S","",0, 575}) // Serviços Realizados por Terceiros
aAdd(aVX5,{"080","3324","(-) #STR#"				,"S","",0, 576}) // Dedução de Serviços Realizados por Terceiros
aAdd(aVX5,{"080","3411","#STR#"					,"S","",0, 577}) // Receitas de Tecnologia - ACGO
aAdd(aVX5,{"080","3412","#STR#"					,"S","",0, 578}) // Receita Outros Negócios AGCO
aAdd(aVX5,{"080","3413","(-) #STR#"				,"S","",0, 579}) // Dedução de Receitas Tecnologia - AGCO
aAdd(aVX5,{"080","3414","(-) #STR#"				,"S","",0, 580}) // Dedução de Receitas com Outros Negócios - AGCO
aAdd(aVX5,{"080","3511","#STR#"					,"S","",0, 581}) // Receita Outros Negócios
aAdd(aVX5,{"080","3512","(-) #STR#"				,"S","",0, 582}) // Dedução de Receitas com Outros Negócios
aAdd(aVX5,{"080","4117","#STR#"					,"S","",0, 583}) // Custo Máquinas AGCO - Novos
aAdd(aVX5,{"080","4119","#STR#"					,"S","",0, 584}) // Custo Impllementos AGCO - Novos
aAdd(aVX5,{"080","4121","#STR#"					,"S","",0, 585}) // Custo Máquinas Outras Marcas - Novos
aAdd(aVX5,{"080","4131","#STR#"					,"S","",0, 586}) // Custo Máquinas e Implementos AGCO - Usados
aAdd(aVX5,{"080","4133","#STR#"					,"S","",0, 587}) // Custo Máquinas e implementos Outras Marcas - Usados
aAdd(aVX5,{"080","4213","#STR#"					,"S","",0, 588}) // Custo Peças AGCO
aAdd(aVX5,{"080","4214","#STR#"					,"S","",0, 589}) // Custo Peças Oficina AGCO
aAdd(aVX5,{"080","4221","#STR#"					,"S","",0, 590}) // Peças Outras Marcas
aAdd(aVX5,{"080","4222","#STR#"					,"S","",0, 591}) // Peças Oficina Outras Marcas
aAdd(aVX5,{"080","4311","#STR#"					,"S","",0, 592}) // Materiais de Consumo - Oficina
aAdd(aVX5,{"080","4312","#STR#"					,"S","",0, 593}) // Salários e Encargos dos Técnicos
aAdd(aVX5,{"080","4313","#STR#"					,"S","",0, 594}) // Custos Serviços Realizados por Terceiros
aAdd(aVX5,{"080","4314","#STR#"					,"S","",0, 595}) // Custo com deslocamento técnicos
aAdd(aVX5,{"080","4315","#STR#"					,"S","",0, 596}) // Custos com Pós - Venda/Garantias Indeferidas e Retrabalhos
aAdd(aVX5,{"080","4319","#STR#"					,"S","",0, 597}) // Uso e Consumo Oficina
aAdd(aVX5,{"080","4320","#STR#"					,"S","",0, 598}) // Ferramental de pequeno valor
aAdd(aVX5,{"080","4399","#STR#"					,"S","",0, 599}) // Outros Custos Sobre Serviços
aAdd(aVX5,{"080","4411","#STR#"					,"S","",0, 600}) // Custo de Tecnologia ACGO
aAdd(aVX5,{"080","4412","#STR#"					,"S","",0, 601}) // Custo com Outros Negócios - AGCO
aAdd(aVX5,{"080","4511","#STR#"					,"S","",0, 602}) // Custo com Outros Negócios
aAdd(aVX5,{"080","5111","#STR#"					,"S","",0, 603}) // Brindes
aAdd(aVX5,{"080","5112","#STR#"					,"S","",0, 604}) // Comissões e Encargo Folha de Pagamento
aAdd(aVX5,{"080","5113","#STR#"					,"S","",0, 605}) // Bônus e Participação nos Resultados
aAdd(aVX5,{"080","5114","#STR#"					,"S","",0, 606}) // Despesas com Ajustes de Acordo Comercial
aAdd(aVX5,{"080","5116","#STR#"					,"S","",0, 607}) // Perdas com Devedores Duvidosos
aAdd(aVX5,{"080","5117","#STR#"					,"S","",0, 608}) // Taxa Flat de Financiamento
aAdd(aVX5,{"080","5118","#STR#"					,"S","",0, 609}) // Despesas de Consumo Interno Oficina
aAdd(aVX5,{"080","5119","#STR#"					,"S","",0, 610}) // Fretes
aAdd(aVX5,{"080","5120","#STR#"					,"S","",0, 611}) // Despesa com reforma de máquinas usadas
aAdd(aVX5,{"080","5121","#STR#"					,"S","",0, 612}) // Remuneração Dirigentes
aAdd(aVX5,{"080","5122","#STR#"					,"S","",0, 613}) // Salários - Gerência e Supervisão
aAdd(aVX5,{"080","5123","#STR#"					,"S","",0, 614}) // Salários - Funcionários
aAdd(aVX5,{"080","5124","#STR#"					,"S","",0, 615}) // Provisões - 13o. Sal. e Férias
aAdd(aVX5,{"080","5125","#STR#"					,"S","",0, 616}) // Encargos Sociais - todos
aAdd(aVX5,{"080","5126","#STR#"					,"S","",0, 617}) // Benefícios
aAdd(aVX5,{"080","5127","#STR#"					,"S","",0, 618}) // Água, Luz e Gás
aAdd(aVX5,{"080","5128","#STR#"					,"S","",0, 619}) // Aluguel
aAdd(aVX5,{"080","5129","#STR#"					,"S","",0, 620}) // Amortizações e Depreciações
aAdd(aVX5,{"080","5130","#STR#"					,"S","",0, 621}) // Despesa com Alimentação
aAdd(aVX5,{"080","5131","#STR#"					,"S","",0, 622}) // Despesas com Material de Segurança e Uniformes
aAdd(aVX5,{"080","5132","#STR#"					,"S","",0, 623}) // Despesas com Móveis e Utensílios
aAdd(aVX5,{"080","5133","#STR#"					,"S","",0, 624}) // Despesas de Comunicação
aAdd(aVX5,{"080","5134","#STR#"					,"S","",0, 625}) // Donativos e Contribuições
aAdd(aVX5,{"080","5135","#STR#"					,"S","",0, 626}) // Eventos e Confraternização
aAdd(aVX5,{"080","5136","#STR#"					,"S","",0, 627}) // Garantias Recusadas - AGCO
aAdd(aVX5,{"080","5137","#STR#"					,"S","",0, 628}) // Impostos e Taxas Diversos
aAdd(aVX5,{"080","5138","#STR#"					,"S","",0, 629}) // Leasing
aAdd(aVX5,{"080","5139","#STR#"					,"S","",0, 630}) // Legais e Auditoria
aAdd(aVX5,{"080","5140","#STR#"					,"S","",0, 631}) // Manutenção de Veículos frota da Adm
aAdd(aVX5,{"080","5141","#STR#"					,"S","",0, 632}) // Manutenção Predial
aAdd(aVX5,{"080","5142","#STR#"					,"S","",0, 633}) // Materiais Diversos / Escritório
aAdd(aVX5,{"080","5143","#STR#"					,"S","",0, 634}) // Multas
aAdd(aVX5,{"080","5144","#STR#"					,"S","",0, 635}) // Processamento Dados - Terceiros
aAdd(aVX5,{"080","5145","#STR#"					,"S","",0, 636}) // Propaganda e Promoção de Vendas
aAdd(aVX5,{"080","5146","#STR#"					,"S","",0, 637}) // Publicações, Assinaturas e Assoc.
aAdd(aVX5,{"080","5147","#STR#"					,"S","",0, 638}) // Retorno de Garantia ( Peças e Serviços )
aAdd(aVX5,{"080","5148","#STR#"					,"S","",0, 639}) // Seguros
aAdd(aVX5,{"080","5149","#STR#"					,"S","",0, 640}) // Serviços Profissionais - Terceiros
aAdd(aVX5,{"080","5150","#STR#"					,"S","",0, 641}) // Treinamento
aAdd(aVX5,{"080","5151","#STR#"					,"S","",0, 642}) // Combustíveis e Lubrificantes
aAdd(aVX5,{"080","5152","#STR#"					,"S","",0, 643}) // Viagens, Represent. e Hospitalidade
aAdd(aVX5,{"080","5153","#STR#"					,"S","",0, 644}) // Taxas Associativas
aAdd(aVX5,{"080","5154","#STR#"					,"S","",0, 645}) // Sistemas, Software e Informática
aAdd(aVX5,{"080","5155","#STR#"					,"S","",0, 646}) // Postagens, Correios e Telegrafos
aAdd(aVX5,{"080","5156","#STR#"					,"S","",0, 647}) // Aviso Prévio
aAdd(aVX5,{"080","5157","#STR#"					,"S","",0, 648}) // Ações Trabalhistas
aAdd(aVX5,{"080","5158","#STR#"					,"S","",0, 649}) // Estágio
aAdd(aVX5,{"080","5199","#STR#"					,"S","",0, 650}) // Outros Despesas
aAdd(aVX5,{"080","6111","#STR#"					,"S","",0, 651}) // Rendimento Aplicações Financeiras
aAdd(aVX5,{"080","6112","#STR#"					,"S","",0, 652}) // Juros Recebidos
aAdd(aVX5,{"080","6113","#STR#"					,"S","",0, 653}) // Variações Monetarias Ativas
aAdd(aVX5,{"080","6114","#STR#"					,"S","",0, 654}) // Descontos Obtidos
aAdd(aVX5,{"080","6115","#STR#"					,"S","",0, 655}) // Juros de CAR
aAdd(aVX5,{"080","6121","#STR#"					,"S","",0, 656}) // Despesas Financeiras s/ Capital Giro
aAdd(aVX5,{"080","6122","#STR#"					,"S","",0, 657}) // IOF
aAdd(aVX5,{"080","6123","#STR#"					,"S","",0, 658}) // Despesa com Juros
aAdd(aVX5,{"080","6124","#STR#"					,"S","",0, 659}) // Multas Financeiras
aAdd(aVX5,{"080","6125","#STR#"					,"S","",0, 660}) // Juros sobre Capital Próprio
aAdd(aVX5,{"080","6126","#STR#"					,"S","",0, 661}) // Variações Monetarias Passivas
aAdd(aVX5,{"080","6127","#STR#"					,"S","",0, 662}) // Despesas Bancárias
aAdd(aVX5,{"080","6128","#STR#"					,"S","",0, 663}) // Descontos Passivos
aAdd(aVX5,{"080","7111","#STR#"					,"S","",0, 664}) // Ganho com Venda de Ativo Imobilizado
aAdd(aVX5,{"080","7112","#STR#"					,"S","",0, 665}) // Outras Receitas
aAdd(aVX5,{"080","7121","#STR#"					,"S","",0, 666}) // Perda com Venda de Ativo
aAdd(aVX5,{"080","7122","#STR#"					,"S","",0, 667}) // Outras Despesas
aAdd(aVX5,{"080","8111","#STR#"					,"S","",0, 668}) // IRPJ
aAdd(aVX5,{"080","8112","#STR#"					,"S","",0, 669}) // CSLL
//
AADD(aVX5, {"070","PVAA","#STR#"						,"S","",0, 670}) // ALTERAÇÃO STATUS - ABERTO
AADD(aVX5, {"070","PVAP","#STR#"						,"S","",0, 671}) // ALTERAÇÃO STATUS - PENDENTE APROVAÇÃO
AADD(aVX5, {"070","PVAO","#STR#"						,"S","",0, 672}) // ALTERAÇÃO STATUS - PRE-APROVADO
AADD(aVX5, {"070","PVAL","#STR#"						,"S","",0, 673}) // ALTERAÇÃO STATUS - APROVADO
AADD(aVX5, {"070","PVAR","#STR#"						,"S","",0, 674}) // ALTERAÇÃO STATUS - REPROVADO
AADD(aVX5, {"070","PVAF","#STR#"						,"S","",0, 675}) // ALTERAÇÃO STATUS - FINALIZADO
AADD(aVX5, {"070","PVAC","#STR#"						,"S","",0, 676}) // ALTERAÇÃO STATUS - CANCELADO
//
aAdd(aVX5,{"075","001","CGPoll"							,"S","",0,   0}) // 0 na posição 7 -> Mantem a mesma descrição fixa para todos os Idiomas
//
aAdd(aVX5, {"076", "0", "#STR#"							,"S","",0,  66}) // Gasolina
aAdd(aVX5, {"076", "1", "#STR#"							,"S","",0,  67}) // Alcool
aAdd(aVX5, {"076", "2", "#STR#"							,"S","",0,  68}) // Diesel
aAdd(aVX5, {"076", "3", "#STR#"							,"S","",0,  69}) // Gas Natural Veicular
aAdd(aVX5, {"076", "4", "#STR#"							,"S","",0,  70}) // Alcool/Gasolina
aAdd(aVX5, {"076", "5", "#STR#"							,"S","",0,  71}) // Alcool/Gasolina/GNV
aAdd(aVX5, {"076", "9", "#STR#"							,"S","",0,  72}) // Sem Combustivel
aAdd(aVX5, {"076", "A", "#STR#"							,"S","",0,  73}) // Gasogenio
aAdd(aVX5, {"076", "B", "#STR#"							,"S","",0,  74}) // Gas Metano
aAdd(aVX5, {"076", "C", "#STR#"							,"S","",0,  75}) // Eletrico/Fonte Interna
aAdd(aVX5, {"076", "D", "#STR#"							,"S","",0,  76}) // Eletrico/Fonte Externa
aAdd(aVX5, {"076", "E", "#STR#"							,"S","",0,  77}) // Gasol/Gas Natural Combustivel
aAdd(aVX5, {"076", "F", "#STR#"							,"S","",0,  78}) // Alcool/Gas Natural Combustivel
aAdd(aVX5, {"076", "G", "#STR#"							,"S","",0,  79}) // Diesel/Gas Natural Combustivel
aAdd(aVX5, {"076", "H", "#STR#"							,"S","",0,  80}) // Alcool/Gas Natural Veicular
aAdd(aVX5, {"076", "I", "#STR#"							,"S","",0,  81}) // Gasolina/Gas Natural Veicular
aAdd(aVX5, {"076", "J", "#STR#"							,"S","",0,  82}) // Diesel/Gas Natural Veicular
aAdd(aVX5, {"076", "K", "#STR#"							,"S","",0,  83}) // Gasolina/Eletrico
//
aAdd(aVX5, {"083", "01", "LocationCreatedInDbs","S","",0})
aAdd(aVX5, {"083", "02", "LocationUpdatedInDbs","S","",0})
aAdd(aVX5, {"083", "03", "LocationRemovedInDbs","S","",0})
aAdd(aVX5, {"083", "04", "FileList","S","",0})
aAdd(aVX5, {"083", "05", "FileDownload","S","",0})
aAdd(aVX5, {"083", "06", "FileUpload","S","",0})
aAdd(aVX5, {"083", "07", "CustomerCreatedInDbs","S","",0})
aAdd(aVX5, {"083", "08", "CustomerUpdatedInDbs","S","",0})
aAdd(aVX5, {"083", "09", "CustomerRemovedInDbs","S","",0})
aAdd(aVX5, {"083", "10", "ContactCreatedInDbs","S","",0})
aAdd(aVX5, {"083", "11", "ContactUpdatedInDbs","S","",0})
aAdd(aVX5, {"083", "12", "ContactRemovedInDbs","S","",0})

aAdd(aVX5, {"083", "13", "EquipmentMakeCreatedInDbs","S","",0})
aAdd(aVX5, {"083", "14", "EquipmentMakeUpdatedInDbs","S","",0})
aAdd(aVX5, {"083", "15", "EquipmentMakeRemovedInDbs","S","",0})

aAdd(aVX5, {"083", "16", "EquipmentModelCreatedInDbs","S","",0})
aAdd(aVX5, {"083", "17", "EquipmentModelUpdatedInDbs","S","",0})
aAdd(aVX5, {"083", "18", "EquipmentModelRemovedInDbs","S","",0})

aAdd(aVX5, {"083", "19", "EquipmentCreatedInDbs","S","",0})
aAdd(aVX5, {"083", "20", "EquipmentUpdatedInDbs","S","",0})
aAdd(aVX5, {"083", "21", "EquipmentRemovedInDbs","S","",0})

aAdd(aVX5, {"083", "22", "EquipmentMeterUpdatedInDbs","S","",0})

aAdd(aVX5, {"083", "23", "EquipmentOptionAddedInDbs","S","",0})
aAdd(aVX5, {"083", "24", "EquipmentOptionUpdatedInDbs","S","",0})
aAdd(aVX5, {"083", "25", "EquipmentOptionRemovedInDbs","S","",0})
aAdd(aVX5, {"083", "26", "FileCreate","S","",0})
aAdd(aVX5, {"083", "27", "FileOpen","S","",0})

aAdd(aVX5, {"084", "00", "Mobile"            ,"S","",0 })
aAdd(aVX5, {"084", "01", "John Deere - Dynamics" ,"S","",0 })
aAdd(aVX5, {"084", "02", "DTF" ,"S","",0 })
aAdd(aVX5, {"084", "03", "CIFT" ,"S","",0 })

aAdd(aVX5, {"085", "00", "John Deere - Dynamics" , "S", "", 0 })
aAdd(aVX5, {"085", "01", "DBS"       , "S", "", 0 })
aAdd(aVX5, {"085", "02", "Mobile"    , "S", "", 0 })
//
aAdd(aVX5, {"087", "01", "#STR#"						,"S","",0, 677}) // Reserva Manual - Orçamento Balcão
aAdd(aVX5, {"087", "02", "#STR#"						,"S","",0, 678}) // Reserva Automática - Orçamento Balcão (R)
aAdd(aVX5, {"087", "03", "#STR#"						,"S","",0, 679}) // Reserva Automática - Orçamento Balcão (T)
aAdd(aVX5, {"087", "04", "#STR#"						,"S","",0, 680}) // Reserva Automática - Orçamento Balcão (LOJA)
aAdd(aVX5, {"087", "05", "#STR#"						,"S","",0, 681}) // Reserva Automática - Orçamento Balcão (NF)
aAdd(aVX5, {"087", "06", "#STR#"						,"S","",0, 682}) // Reserva Manual - Pedido de Orçamento
aAdd(aVX5, {"087", "07", "#STR#"						,"S","",0, 683}) // Reserva Automática - Orçamento Transferência (XFER)
aAdd(aVX5, {"087", "08", "#STR#"						,"S","",0, 684}) // Reserva Automática - Orçamento de Transferência
aAdd(aVX5, {"087", "09", "#STR#"						,"S","",0, 685}) // Reserva Manual - Orçamento Oficina
aAdd(aVX5, {"087", "10", "#STR#"						,"S","",0, 686}) // Reserva Automática - Exportação Orçamento Oficina
aAdd(aVX5, {"087", "11", "#STR#"						,"S","",0, 687}) // Reserva Automática - Sugestão de Compra - Orçamento
aAdd(aVX5, {"087", "12", "#STR#"						,"S","",0, 688}) // Reserva Automática - Sugestão de Compra - Oficina
aAdd(aVX5, {"087", "13", "#STR#"						,"S","",0, 689}) // Reserva Automática - Peças da OS
aAdd(aVX5, {"087", "14", "#STR#"						,"S","",0, 690}) // Reserva Automática - Transferência de Reserva Pedido de Orçamento x Orçamento
aAdd(aVX5, {"087", "15", "#STR#"						,"S","",0, 691}) // Reserva Automática - Sugestão de Compra - Transferência entre Filiais
aAdd(aVX5, {"087", "16", "#STR#"						,"S","",0, 691}) // Reserva Manual - Processa Reserva                                                                                                                                                                      
//
aAdd(aVX5, {"088", "01", "#STR#"						,"S","",0, 692}) // Desreserva Manual - Orçamento Balcão
aAdd(aVX5, {"088", "02", "#STR#"						,"S","",0, 693}) // Desreserva Automática - Exclusão Orçamento Balcão
aAdd(aVX5, {"088", "03", "#STR#"						,"S","",0, 694}) // Desreserva Automática - Orçamento Balcão
aAdd(aVX5, {"088", "04", "#STR#"						,"S","",0, 695}) // Desreserva Automática - Orçamento Balcão (LOJA)
aAdd(aVX5, {"088", "05", "#STR#"						,"S","",0, 696}) // Desreserva Automática - Exclusão Pedido de Orçamento
aAdd(aVX5, {"088", "06", "#STR#"						,"S","",0, 697}) // Desreserva Manual - Pedido de Orçamento
aAdd(aVX5, {"088", "07", "#STR#"						,"S","",0, 698}) // Desreserva Automática - Pedido de Orçamento
aAdd(aVX5, {"088", "08", "#STR#"						,"S","",0, 699}) // Desreserva Automática - Orçamento de Transferência
aAdd(aVX5, {"088", "09", "#STR#"						,"S","",0, 700}) // Desreserva Manual - Orçamento Oficina
aAdd(aVX5, {"088", "10", "#STR#"						,"S","",0, 701}) // Desreserva Automática - Exclusão Orçamento Oficina
aAdd(aVX5, {"088", "11", "#STR#"						,"S","",0, 702}) // Desreserva Automática - Transferência de Reserva Orçamento x Ordem de Serviço
aAdd(aVX5, {"088", "12", "#STR#"						,"S","",0, 703}) // Desreserva Automática - Requisição - Oficina
aAdd(aVX5, {"088", "13", "#STR#"						,"S","",0, 704}) // Desreserva Automática - Liberação - Oficina
aAdd(aVX5, {"088", "14", "#STR#"						,"S","",0, 705}) // Desreserva Automática - Cancelamento - Oficina
aAdd(aVX5, {"088", "15", "#STR#"						,"S","",0, 706}) // Desreserva Manual - Divergência na Conferência de Itens - Orçamento
aAdd(aVX5, {"088", "16", "#STR#"						,"S","",0, 707}) // Desreserva Automática - Peças da OS
aAdd(aVX5, {"088", "17", "#STR#"						,"S","",0, 708}) // Desreserva Automática - Transferência de Reserva Pedido de Orçamento x Orçamento
aAdd(aVX5, {"088", "18", "#STR#"						,"S","",0, 709}) // Desreserva Manual - Divergência na Conferência de Itens - Oficina
//
aAdd(aVX5, {"089", "01", "#STR#"						,"S","",0, 710}) // Divergência na Conferência - Orçamento
aAdd(aVX5, {"089", "02", "#STR#"						,"S","",0, 711}) // Divergência na Conferência - Oficina
//
aAdd(aVX5, {"093", "01", "#STR#"						,"S","",0, 718}) // Campos de Checklists
//
// case cCodmar == "CNH" // Case New Holland
//
aAdd(aVX5, {"059", "A"        , "#STR#" ,"S","",0, 736 })	//Oficina Interna
aAdd(aVX5, {"059", "B"        , "#STR#" ,"S","",0, 737 })	//Balcão
aAdd(aVX5, {"059", "C"        , "#STR#" ,"S","",0, 738 })	//Ajuste Estoque
aAdd(aVX5, {"059", "D"        , "#STR#" ,"S","",0, 739 })	//Descarte
aAdd(aVX5, {"059", "3"        , "#STR#" ,"S","",0, 740 })	//Recompra/Retorno de material
aAdd(aVX5, {"059", "4"        , "#STR#" ,"S","",0, 741 })	//Transferências
aAdd(aVX5, {"059", "V"        , "#STR#" ,"S","",0, 742 })	//Outros
aAdd(aVX5, {"060", "Reposicao", "#STR#" ,"S","",0, 743 })	//Reposição
aAdd(aVX5, {"060", "M. Parada", "#STR#" ,"S","",0, 744 })	//Máquina Parada
aAdd(aVX5, {"060", "Revisao"  , "#STR#" ,"S","",0, 745 })	//Revisão
aAdd(aVX5, {"060", "Reforma"  , "#STR#" ,"S","",0, 746 })	//Reforma
aAdd(aVX5, {"060", "Consignad", "#STR#" ,"S","",0, 747 })	//Consignado
aAdd(aVX5, {"062", "L"        , "#STR#" ,"S","",0, 774 })	//DELIMITADO
aAdd(aVX5, {"062", "P"        , "#STR#" ,"S","",0, 775 })	//CONFIRMADO
aAdd(aVX5, {"062", "M"        , "#STR#" ,"S","",0, 776 })	//RESERVADO
aAdd(aVX5, {"062", "E"        , "#STR#" ,"S","",0, 777 })	//ATRIBUÍDO
aAdd(aVX5, {"062", "D"        , "#STR#" ,"S","",0, 778 })	//EXPEDIDO
aAdd(aVX5, {"062", "S"        , "#STR#" ,"S","",0, 779 })	//SUSPENSO
aAdd(aVX5, {"062", "N"        , "#STR#" ,"S","",0, 780 })	//PENDENTE
aAdd(aVX5, {"062", "I"        , "#STR#" ,"S","",0, 781 })	//EMBALADO
aAdd(aVX5, {"062", "A"        , "#STR#" ,"S","",0, 782 })	//CANCELADO
aAdd(aVX5, {"062", "Q"        , "#STR#" ,"S","",0, 783 })	//FATURADO
aAdd(aVX5, {"062", "X"        , "#STR#" ,"S","",0, 784 })	//TECNICAMENTE CANCELADO
aAdd(aVX5, {"062", "C"        , "#STR#" ,"S","",0, 775 })	//CONFIRMADO
aAdd(aVX5, {"063", "00"       , "#STR#" ,"S","",0, 785 })	//BDA
aAdd(aVX5, {"063", "01"       , "#STR#" ,"S","",0, 786 })	//Unidade
aAdd(aVX5, {"063", "02"       , "#STR#" ,"S","",0, 787 })	//Emergência
aAdd(aVX5, {"063", "05"       , "#STR#" ,"S","",0, 788 })	//Normal
aAdd(aVX5, {"063", "24"       , "#STR#" ,"S","",0, 789 })	//PMP Garantia
AADD(AVX5, {"065", "CA"       , "#STR#" ,"S","",0, 720 })//Concessionário CNH
AADD(AVX5, {"065", "CB"       , "#STR#" ,"S","",0, 721 })//Administração Pública
AADD(AVX5, {"065", "CC"       , "#STR#" ,"S","",0, 722 })//Revendedor Não Autorizado
AADD(AVX5, {"065", "A1"       , "#STR#" ,"S","",0, 723 })//Conta Chave
AADD(AVX5, {"065", "C1"       , "#STR#" ,"S","",0, 724 })//Cliente Agrícola
AADD(AVX5, {"065", "C2"       , "#STR#" ,"S","",0, 725 })//Cliente Construção
AADD(AVX5, {"065", "D1"       , "#STR#" ,"S","",0, 726 })//Outra filial de posse
AADD(AVX5, {"065", "D2"       , "#STR#" ,"S","",0, 727 })//Interno como transferências ou CNH
AADD(AVX5, {"065", "D3"       , "#STR#" ,"S","",0, 728 })//Diversos



Return()

/*/{Protheus.doc} OFIOA560I
Incluir Registro do VX5

@author Andre Luis Almeida
@since 04/06/2013
@type function
/*/
Function OFIOA560I()
Local cFilVX5   := xFilial("VX5")
Local cCod      := ""
Local cDesc     := space(200)
Local cDescEsp  := space(200)
Local cDescIng  := space(200)
Local aRet      := {}
Local aParamBox := {}
Local nPos      := 0
Local nTam      := 10 // Declarar como NIL para funcionar o carregamento no TamSX3
Local cTab      := ""
Local lEspIng   := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )

If cVX5 $ cTabBloq
	MsgStop(STR0027) // Nao e possivel incluir registros na tabela selecionada
	Return
EndIf

DbSelectArea("VX5")

nPos := aScan(aVX5, {|x| x[1]+x[2] == "000"+cVX5 }) // Pesquisa a Tabela
If nPos > 0 .And. Len(aVX5[nPos]) > 4
	If !Empty(aVX5[nPos,5])
		cTab := left(aVX5[nPos,5],At("_",aVX5[nPos,5])-1)
		If len(cTab) == 2
			cTab := "S"+cTab // Tabelas Padrao TOTVS
		EndIf
		If &( cTab+"->(FieldPos('"+aVX5[nPos,5]+"')) > 0" ) // Campo Padrao
			nTam := TamSX3(aVX5[nPos,5])[1] // Utiliza Tamanho do Campo Padrao
		ElseIf aVX5[nPos,6] > 0 // Tamanho Default
			nTam := aVX5[nPos,6] // Utiliza Tamanho Default passado no Vetor das Tabelas
		EndIf
	ElseIf aVX5[nPos,6] > 0 // Tamanho Default
		nTam := aVX5[nPos,6] // Utiliza Tamanho Default passado no Vetor das Tabelas
	EndIf
EndIf
cCod := space(nTam) // Tamanho do Codigo do VX5

AADD(aParamBox,{1,STR0003,cCod,"@!","","",".t.",50,.t.}) // Codigo
AADD(aParamBox,{1,STR0004+" - "+STR0135,cDesc,"@!","","",".t.",110,.t.}) // Descricao / Portugues
If lEspIng
	AADD(aParamBox,{1,STR0004+" - "+STR0136,cDescEsp,"@!","","",".t.",110,.t.}) // Descricao / Espanhol
	AADD(aParamBox,{1,STR0004+" - "+STR0137,cDescIng,"@!","","",".t.",110,.t.}) // Descricao / Ingles
EndIf
If ParamBox(aParamBox,OFIOA560DS("000",cVX5),@aRet,,,,,,,,.f.)
	cCod  := aRet[01] // Codigo
	cDesc := aRet[02] // Descricao Portugues
	If lEspIng
		cDescEsp := aRet[03] // Descricao Espanhol
		cDescIng := aRet[04] // Descricao Ingles
	EndIf
	If MpSysExecScalar("SELECT R_E_C_N_O_ AS RECVX5 FROM "+RetSQLName("VX5")+" WHERE VX5_FILIAL='"+cFilVX5+"' AND VX5_CHAVE='"+cVX5+"' AND VX5_CODIGO='"+cCod+"' AND D_E_L_E_T_=' '","RECVX5") <= 0
		DbSelectArea("VX5")
		RecLock("VX5",.t.)
    	VX5->VX5_FILIAL := cFilVX5
		VX5->VX5_CHAVE  := cVX5
		VX5->VX5_CODIGO := cCod
		VX5->VX5_DESCRI := cDesc
		If lEspIng
			VX5->VX5_DESESP := cDescEsp
			VX5->VX5_DESING := cDescIng
		EndIf
		VX5->VX5_PROPRI := "U"
		if VX5->(fieldpos('VX5_DATINC')) > 0
			VX5->VX5_DATINC := FGX_Timestamp()
		endif
		if VX5->(fieldpos('VX5_UUID')) > 0
			VX5->VX5_UUID := FWUUIDV4(.t.)
		endif
		MsUnLock()
	Else
		MsgAlert(STR0006,STR0005) // Código informado ja existente! Impossivel Incluir!  / Atenção
	EndIf
EndIf
Return()

/*/{Protheus.doc} OFIOA560A
Alterar Registro do VX5

@author Andre Luis Almeida
@since 04/06/2013
@type function
/*/
Function OFIOA560A()
Local cCod      := ""
Local cDesc     := ""
Local cDescEsp  := ""
Local cDescIng  := ""
Local aRet      := {}
Local aParamBox := {}
Local lEspIng   := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
If VX5->VX5_PROPRI == "U"
	cCod  := VX5->VX5_CODIGO
	cDesc := VX5->VX5_DESCRI
	If lEspIng
		cDescEsp := VX5->VX5_DESESP
		cDescIng := VX5->VX5_DESING
	EndIf
	AADD(aParamBox,{1,STR0003,cCod,"@!","","",".f.",50,.t.}) // Codigo
	AADD(aParamBox,{1,STR0004+" - "+STR0135,cDesc,"@!","","",".t.",110,.t.}) // Descricao / Portugues
	If lEspIng
		AADD(aParamBox,{1,STR0004+" - "+STR0136,cDescEsp,"@!","","",".t.",110,.t.}) // Descricao / Espanhol
		AADD(aParamBox,{1,STR0004+" - "+STR0137,cDescIng,"@!","","",".t.",110,.t.}) // Descricao / Ingles
	EndIf
	If ParamBox(aParamBox,OFIOA560DS("000",cVX5),@aRet,,,,,,,,.f.)
		cDesc := aRet[02] // Descricao
		If lEspIng
			cDescEsp := aRet[03] // Descricao Espanhol
			cDescIng := aRet[04] // Descricao Ingles
		EndIf
		If !Empty(cDesc)
			DbSelectArea("VX5")
			RecLock("VX5",.f.)
			VX5->VX5_DESCRI := cDesc
			If lEspIng
				VX5->VX5_DESESP := cDescEsp
				VX5->VX5_DESING := cDescIng
			EndIf
			if VX5->(fieldpos('VX5_DATALT')) > 0
				VX5->VX5_DATALT := FGX_Timestamp()
			endif
			MsUnLock()
		EndIf
	EndIf
Else
	MsgStop(STR0007,STR0005) // Registro padrão do sistema. Impossivel Alterar! / Atenção
EndIf
Return()

/*/{Protheus.doc} OFIOA560E
Excluir Registro do VX5

@author Andre Luis Almeida
@since 04/06/2013
@type function
/*/
Function OFIOA560E()
Local cCod      := ""
Local cDesc     := ""
Local cDescEsp  := ""
Local cDescIng  := ""
Local aRet      := {}
Local aParamBox := {}
Local lEspIng   := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
If VX5->VX5_PROPRI == "U"
	cCod  := VX5->VX5_CODIGO
	cDesc := VX5->VX5_DESCRI
	If lEspIng
		cDescEsp := VX5->VX5_DESESP
		cDescIng := VX5->VX5_DESING
	EndIf
	AADD(aParamBox,{1,STR0003,cCod,"@!","","",".f.",50,.t.}) // Codigo
	AADD(aParamBox,{1,STR0004+" - "+STR0135,cDesc,"@!","","",".F.",110,.f.}) // Descricao / Portugues
	If lEspIng
		AADD(aParamBox,{1,STR0004+" - "+STR0136,cDescEsp,"@!","","",".F.",110,.f.}) // Descricao / Espanhol
		AADD(aParamBox,{1,STR0004+" - "+STR0137,cDescIng,"@!","","",".F.",110,.f.}) // Descricao / Ingles
	EndIf
	If ParamBox(aParamBox,OFIOA560DS("000",cVX5),@aRet,,,,,,,,.f.)
		DbSelectArea("VX5")
		RecLock("VX5",.f.,.t.)
			if VX5->(fieldpos('VX5_DATALT')) > 0
				VX5->VX5_DATALT := FGX_Timestamp()
			endif
			VX5->(dbDelete())
		MsUnLock()
	EndIf
Else
	MsgStop(STR0008,STR0005) // Registro padrão do sistema. Impossivel Excluir! / Atencao
EndIf
Return()

/*/{Protheus.doc} OFIOA560V
Visualizar Registro do VX5

@author Andre Luis Almeida
@since 19/01/2024
@type function
/*/
Function OFIOA560V()
Local cCod      := ""
Local cDesc     := ""
Local cDescEsp  := ""
Local cDescIng  := ""
Local aRet      := {}
Local aParamBox := {}
Local lEspIng   := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
cCod  := VX5->VX5_CODIGO
cDesc := VX5->VX5_DESCRI
If lEspIng
	cDescEsp := VX5->VX5_DESESP
	cDescIng := VX5->VX5_DESING
EndIf
AADD(aParamBox,{1,STR0003,cCod,"@!","","",".f.",50,.t.}) // Codigo
AADD(aParamBox,{1,STR0004+" - "+STR0135,cDesc,"@!","","",".F.",110,.f.}) // Descricao / Portugues
If lEspIng
	AADD(aParamBox,{1,STR0004+" - "+STR0136,cDescEsp,"@!","","",".F.",110,.f.}) // Descricao / Espanhol
	AADD(aParamBox,{1,STR0004+" - "+STR0137,cDescIng,"@!","","",".F.",110,.f.}) // Descricao / Ingles
EndIf
ParamBox(aParamBox,OFIOA560DS("000",cVX5),@aRet,,,,,,,,.f.)
Return()

/*/{Protheus.doc} OFIOA560CB
Funcao auxiliar para criar opção em um Combo

@author Andre Luis Almeida
@since 04/06/2013
@type function
/*/
Function OFIOA560CB(cChave, nTamChave)

Local cSQL
Local cRetorno := ""
Local cAliasVX5 := "TVX5"
Local cArea := GetArea()

If !Empty(RetSQLName("VX5"))
	cSQL := "SELECT VX5_CODIGO, "+OA5600011_Campo_Idioma()+" AS DESCRI "
	cSQL +=  " FROM " + RetSQLName("VX5") + " VX5"
	cSQL += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
	cSQL +=   " AND VX5_CHAVE  = '" + cChave + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VX5_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5, .F., .T. )
	While !((cAliasVX5)->(Eof()))
		cRetorno += Left((cAliasVX5)->VX5_CODIGO,nTamChave) + "=" + AllTrim( (cAliasVX5)->DESCRI ) + ";"
		(cAliasVX5)->(dbSkip())
	End
	If !Empty(cRetorno)
		cRetorno := Left(cRetorno,Len(cRetorno)-1)
	EndIf

	(cAliasVX5)->(dbCloseArea())
	RestArea( cArea )
EndIf

Return cRetorno

/*/{Protheus.doc} OFIOA560PCB
Funcao auxiliar para crirar array para ser utilizada em um combo de Parambox

@author Rubens Takahashi 
@since 04/06/2013
@type function
/*/
Function OFIOA560PCB(cChave, nTamChave)

	Local cSQL
	Local cAliasVX5 := "TVX5"
	Local cArea := GetArea()
	Local aRetorno := {}

	cSQL := "SELECT VX5_CODIGO, "+OA5600011_Campo_Idioma()+" AS DESCRI "
	cSQL +=  " FROM " + RetSQLName("VX5") + " VX5"
	cSQL += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
	cSQL +=   " AND VX5_CHAVE  = '" + cChave + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VX5_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5, .F., .T. )
	While !((cAliasVX5)->(Eof()))
		AADD( aRetorno , Left((cAliasVX5)->VX5_CODIGO,nTamChave) + "=" + AllTrim( (cAliasVX5)->DESCRI ) )
		(cAliasVX5)->(dbSkip())
	End

	(cAliasVX5)->(dbCloseArea())
	RestArea( cArea )

Return aClone(aRetorno)

/*/{Protheus.doc} OFIOA560DS
Funcao auxiliar para retornar a descricao

@author Rubens Takahashi 
@since 04/06/2013
@type function
/*/
Function OFIOA560DS(cTabela,cCodigo)
Local cCampo := OA5600011_Campo_Idioma()
Local cRet   := MpSysExecScalar( "SELECT "+cCampo+" FROM " + RetSQLName("VX5") + " WHERE VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5_CHAVE = '" + cTabela + "' AND VX5_CODIGO = '" + cCodigo + "' AND D_E_L_E_T_ = ' '" , cCampo ) // Retorna a Descrição do Idioma selecionado
Return cRet

/*/{Protheus.doc} OFIOA560VL
Funcao auxiliar para retornar se existe a chave digitada e grava a descricao em uma variavel enviada por parametro

@author Rubens Takahashi 
@since 24/02/2015
@type function
/*/
Function OFIOA560VL(cTabela,cCodigo,cCpoDescri,lExibeMsg)

Local cSQL
Local cAliasVX5 := "TVX5"
Local lRetorno := .f.
Local cCampo := OA5600011_Campo_Idioma()

Default lExibeMsg := .t.

cSQL := "SELECT "+cCampo+" AS DESCRI "
cSQL +=  " FROM " + RetSQLName("VX5")
cSQL += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
cSQL +=   " AND VX5_CHAVE = '" + cTabela + "'"
cSQL +=   " AND VX5_CODIGO = '" + cCodigo + "'"
cSQL +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5 , .F., .T. )
If !(cAliasVX5)->(Eof())
	lRetorno := .t.
	If cCpoDescri <> NIL
		cCpoDescri := (cAliasVX5)->DESCRI
	EndIf
Else
	If lExibeMsg
		HELP(" ",1,"REGNOIS",,STR0002 + ": " + cTabela + CHR(13) + CHR(10) + STR0003 + ": " + cCodigo,4,1)
	EndIf
	If cCpoDescri <> NIL
		cCpoDescri := Space(TamSX3(cCampo)[1])
	EndIf
End
(cAliasVX5)->(dbCloseArea())

Return lRetorno

/*/{Protheus.doc} OFIOA560FL
Funcao auxiliar para filtrar Consulta Padrao

@author Rubens Takahashi 
@since 04/06/2013
@type function
/*/
Function OFIOA560FL(cFiltro,cFilVX5,lCriaVar)

Local lRetorno := .f.
Local cIdiom   := ""
Local cNomeSXB := "VX5AUX" // Antigo SXB
Default cFiltro := ReadVar()
Default cFilVX5 := ""
Default lCriaVar := .t.
If lCriaVar // Cria variavel cFiltroVX5
	Private cFiltroVX5 := cFilVX5
EndIf
If Empty(cFiltroVX5) .and. lCriaVar // Cria variavel cFiltroVX5
	Do Case
		Case cFiltro == "M->VMY_MKTCOD"
			cFiltroVX5 := "007"
		Case cFiltro == "M->VMY_CTYPE"
			cFiltroVX5 := "004"
		Case AllTrim(cFiltro) $ "M->VMY_UN1/M->VMY_UN2/M->VMB_UNIMED/M->VMB_UNUSPC"
			cFiltroVX5 := "005"
		Case cFiltro == "M->VMB_TIPGAR"
			cFiltroVX5 := "006"
		Case cFiltro == "M->VMB_SUBGAR"
			cFiltroVX5 := "010"
		Case cFiltro == "M->VMB_APLICA"
			cFiltroVX5 := IIF(M->VMB_TIPGAR="ZZBT","008","009")
		Case cFiltro == "M->VMB_FALHA"
			cFiltroVX5 := IIF(M->VMB_TIPGAR="ZZBT","024","011")
		Case cFiltro == "M->VMB_MAQPAR"
			cFiltroVX5 := "012"
		Case cFiltro == "M->VMB_TIPESP"
			cFiltroVX5 := "013"
		Case cFiltro == "M->VMB_INTSRV"
			cFiltroVX5 := "014"
		Case cFiltro == "M->VMB_TIPMAQ"
			cFiltroVX5 := "015"
		Case cFiltro == "M->VMC_TIPTRA"
			cFiltroVX5 := "017"
		Case cFiltro == "M->VMC_CODMAT"
			cFiltroVX5 := "022"
		Case cFiltro == "M->VDL_PERFIL"
			cFiltroVX5 := "025"
		Case cFiltro $  "M->VDM_CAMPOP/M->VDY_CAMPOP/M->VDQ_CAMPOP/M->VDI_CAMPOP/M->VDJ_CAMPOP"
			cFiltroVX5 := "026"
		Case cFiltro $  "M->VDM_TIPMID/M->VS1_TIPMID/M->VDQ_TIPMID/M->VDI_TIPMID/M->VDJ_TIPMID"
			cFiltroVX5 := "027"
		Case cFiltro == "M->VDM_FASFIN"
			cFiltroVX5 := "031"
		Case cFiltro == "M->VDM_LINCRE"
			cFiltroVX5 := "032"
		Case cFiltro == "M->VCF_CODSEG"
			cFiltroVX5 := "033"
		Case cFiltro $  "M->A1_SATIV5/M->A1_SATIV6/M->A1_SATIV7/M->A1_SATIV8"
			cFiltroVX5 := "033"
		Case cFiltro == "M->VST_CODFAL"
			cFiltroVX5 := "034"
		Case cFiltro == "M->VER_AGRUPA"
			cFiltroVX5 := "035"
		Case cFiltro == "M->VG6_TPCUST"
			cFiltroVX5 := "038"
		Case cFiltro == "M->VGH_CGAR"
			cFiltroVX5 := "042"
		Case cFiltro == "M->VGH_TIPREC"
			cFiltroVX5 := "041"
		Case cFiltro == "M->VGH_FALHA"
			cFiltroVX5 := "040"
		Case cFiltro == "M->VDM_DECVDA"
			cFiltroVX5 := "044"
		Case cFiltro == "M->VQQ_CMPMOT"
			cFiltroVX5 := "045"
		Case cFiltro $  "M->VO1_TPATEN/M->VS1_TPATEN/M->VSO_TPATEN/M->VCP_TPATEN" .OR. FunName() == "OFIOR450"
			cFiltroVX5 := "050"
		Case cFiltro == "M->VAI_CLAHAB"
			cFiltroVX5 := "052"
		Case cFiltro == "M->VV2_CORINT" .or. cFiltro == "M->VRK_CORINT"
			cFiltroVX5 := "066"
		Case cFiltro == "M->VV2_COREXT" .or. cFiltro == "M->VRK_COREXT"
			cFiltroVX5 := "067"
		Case cFiltro == "M->VV2_OPCION" .or. cFiltro == "M->VRK_OPCION"
			cFiltroVX5 := "068"
		Case cFiltro == "M->VJJ_QTYPE"
			cFiltroVX5 := "071"
		Case cFiltro == "M->VJJ_QSTATU"
			cFiltroVX5 := "072"
		Case cFiltro == "M->VQW_TIPSIN"
			cFiltroVX5 := "053"
		Case cFiltro == "M->VFF_CODGRF"
			cFiltroVX5 := "078"
		Case cFiltro == "M->VFF_CODDRF"
			cFiltroVX5 := "079"
		Case cFiltro == "M->VS1_PRISEP" .or. cFiltro == "M->VM3_PRISEP"
			cFiltroVX5 := "077"
		Case cFiltro == "M->VV2_CORINT" .or. cFiltro == "M->VRK_CORINT"
			cFiltroVX5 := "066"
		Case cFiltro == "M->VV2_COREXT" .or. cFiltro == "M->VRK_COREXT"
			cFiltroVX5 := "067"
		Case cFiltro == "M->VV2_OPCION" .or. cFiltro == "M->VRK_OPCION"
			cFiltroVX5 := "068"
		Case cFiltro == "M->VJR_EVENTO"
			cFiltroVX5 := "051"
		Case cFiltro == "M->VK1_CULTUR"
			cFiltroVX5 := "003"
		Case cFiltro $ "M->VCF_MERLBM/M->VCF_MERLBT/M->VCF_MERLBH/M->VCF_MERBAT/M->VCF_MERGRX/M->VCF_MERADT/M->VCF_MERBAC/M->VCF_MERLQA/M->VCF_MERPRA/M->VCF_MERSBG/M->VCF_MERTSE"
			cFiltroVX5 := "081"
		Case cFiltro $ "M->VN0_BASCOD/M->PARBASCOD/"
			cFiltroVX5 := "082"
		Case cFiltro == "M->VAL_ATRIB"
			cFiltroVX5 := "090"
		Case cFiltro == "M->VAR_AGFINA"
			cFiltroVX5 := "091"
		Case cFiltro == "M->VAR_CODBCO"
			cFiltroVX5 := "030"
		Case cFiltro == "M->VBE_STSUBL"
			cFiltroVX5 := "062"
		OtherWise // CUSTOMIZADO
			If ExistBlock("OF560VX5")
				cFiltroVX5 := ExecBlock("OF560VX5",.f.,.f.,{ "2" , cFiltro }) // 2 = Qual tabela VX5 deve ser utilizada no F3 de um determinado campo ?
			EndIf
	EndCase
EndIf

If ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 ) // Possui os campos por Idioma
	cIdiom   := FwRetIdiom()
	cNomeSXB := "VX5BRA" // SXB por Idioma --> Portugues
	cNomeSXB := IIf(cIdiom=='es',"VX5ESP",cNomeSXB) // SXB por Idioma --> Espanhol
	cNomeSXB := IIf(cIdiom=='en',"VX5ING",cNomeSXB) // SXB por Idioma --> Ingles
EndIf
dbSelectArea("VX5")
lRetorno := ConPad1( , , , cNomeSXB , , , .F. )

Return lRetorno

/*/{Protheus.doc} OFIOA560ADD
Criação de registros no VX5

@author Rubens Takahashi 
@since 30/10/2019
@type function
/*/
Function OFIOA560ADD(cVX5, cCod, cDesc, cPropri, cDescEsp, cDescIng)
	Local lEspIng    := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
	Local lVX5_DATINC := ( VX5->(FieldPos("VX5_DATINC")) > 0 )
	Local lVX5_UUID  := ( VX5->(FieldPos("VX5_UUID")) > 0 )
	Default cPropri  := "S"
	Default cDescEsp := cDesc
	Default cDescIng := cDesc
	RecLock("VX5",.t.)
		VX5->VX5_FILIAL := FWxFilial("VX5")
		VX5->VX5_CHAVE  := cVX5
		VX5->VX5_CODIGO := cCod
		VX5->VX5_DESCRI := cDesc
		If lEspIng
			VX5->VX5_DESESP := cDescEsp
			VX5->VX5_DESING := cDescIng
		EndIf
		If lVX5_DATINC
			VX5->VX5_DATINC := FGX_Timestamp()
		EndIf
		if lVX5_UUID
			VX5->VX5_UUID := FWUUIDV4(.t.)
		endif
		VX5->VX5_PROPRI := cPropri
	VX5->(MsUnLock())
Return

/*/{Protheus.doc} MenuDef
Monta MenuDef - aRotina

@author Andre Luis Almeida
@since 04/06/2013
@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aRotina := {{ STR0009 ,"AxPesqui" ,0,1},;	// Pesquisar
			{ STR0010 ,"OFIOA560V" ,0,2},;	// Visualizar
			{ STR0011 ,"OFIOA560I" ,0,3},;	// Incluir
			{ STR0012 ,"OFIOA560A" ,0,4},;	// Alterar
			{ STR0013 ,"OFIOA560E" ,0,5}}	// Excluir
Return aRotina

/*/{Protheus.doc} OA5600011_Campo_Idioma
Retorna o nome do campo devido ao Idioma

@author Andre Luis Almeida
@since 17/01/2024
@type function
/*/
Function OA5600011_Campo_Idioma()
Local cIdiom      := FwRetIdiom()
Local cCampo      := "VX5_DESCRI" // Portugues (PADRÃO)
Local lEspIng     := Select("VX5") > 0 .and. ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
If lEspIng .and. cIdiom $ "es/en"
	cCampo := IIf(cIdiom=="es","VX5_DESESP","VX5_DESING") // Espanhol / Ingles
EndIf
Return cCampo

/*/{Protheus.doc} OA5600021_Query_Browse_SQL
    Retorna a Query do Browse da Tabela ( browse em SQL )

    @author Andre Luis Almeida
    @since  19/01/2024
/*/
Static Function OA5600021_Query_Browse_SQL(cParTab,cCampo,cTexto,cOrdem)
Local lEspIng := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
Local cQuery  := "SELECT VX5_CODIGO , VX5_DESCRI "
If lEspIng
	cQuery += " , VX5_DESESP , VX5_DESING "
EndIf
cQuery += "  FROM "+RetSQLName("VX5")
cQuery += " WHERE VX5_FILIAL = '"+xFilial("VX5")+"'"
cQuery += "   AND VX5_CHAVE  = '000'"
If !Empty(cParTab)
	cQuery += " AND VX5_CODIGO = '"+cParTab+"'"
EndIf
cQuery += "   AND D_E_L_E_T_ = ' '"
If !Empty(cTexto)
	cQuery += IIf(cCampo=="1"," AND VX5_CODIGO LIKE '"+cTexto+"%'","")
	cQuery += IIf(cCampo=="2"," AND VX5_DESCRI LIKE '"+cTexto+"%'","")
	cQuery += IIf(cCampo=="3"," AND VX5_DESESP LIKE '"+cTexto+"%'","")
	cQuery += IIf(cCampo=="4"," AND VX5_DESING LIKE '"+cTexto+"%'","")
EndIf
cQuery += IIf(cOrdem=="1"," ORDER BY VX5_CODIGO","")
cQuery += IIf(cOrdem=="2"," ORDER BY VX5_DESCRI","")
cQuery += IIf(cOrdem=="3"," ORDER BY VX5_DESESP","")
cQuery += IIf(cOrdem=="4"," ORDER BY VX5_DESING","")
Return cQuery

/*/{Protheus.doc} OA5600031_Colunas_Browse_SQL()
    Retorna as Colunas do Browse de Detalhes ( browse em SQL )

    @author Andre Luis Almeida
    @since  19/01/2024
/*/
Static Function OA5600031_Colunas_Browse_SQL()
Local aColumns := {}
Local lEspIng  := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
AAdd(aColumns,FWBrwColumn():New())
    aColumns[1]:SetData( &("{|| VX5_CODIGO }") ) 
    aColumns[1]:SetTitle(RetTitle("VX5_CODIGO")) // Codigo
    aColumns[1]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[2]:SetData( &("{|| VX5_DESCRI }") ) 
    aColumns[2]:SetTitle(RetTitle("VX5_DESCRI")) // Desc.Portugues
    aColumns[2]:SetSize(30) // 30 %
If lEspIng
	AAdd(aColumns,FWBrwColumn():New())
	    aColumns[3]:SetData( &("{|| VX5_DESESP }") ) 
	    aColumns[3]:SetTitle(RetTitle("VX5_DESESP")) // Desc.Espanhol
	    aColumns[3]:SetSize(30) // 30 %
	AAdd(aColumns,FWBrwColumn():New())
	    aColumns[4]:SetData( &("{|| VX5_DESING }") ) 
	    aColumns[4]:SetTitle(RetTitle("VX5_DESING")) // Desc.Ingles
	    aColumns[4]:SetSize(30) // 30 %
EndIf
Return aColumns

/*/{Protheus.doc} OA5600041_Filtrar_Browse_SQL()
	Filtrar o Browse superior ( Tabelas VX5 )

	@author Andre Luis Almeida
	@since  22/01/2024
/*/
Static Function OA5600041_Filtrar_Browse_SQL(cParTab)
Local lEspIng   := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
Local cTexto    := space(200)
Local aRet      := {}
Local aParamBox := {}
Local aComb     := {}
Local cQuery    := ""
Local cOrd      := "1"
//
aAdd(aComb,"1="+STR0003) // Codigo
If Empty(cParTab)
	aAdd(aComb,"2="+STR0004+" - "+STR0135) // Descrição - Português
	If lEspIng
		aAdd(aComb,"3="+STR0004+" - "+STR0136) // Descrição - Espanhol
		aAdd(aComb,"4="+STR0004+" - "+STR0137) // Descrição - Inglês
	EndIf
EndIf
//
AADD(aParamBox,{2,STR0712,"",aComb,100,"",.F.}) // Filtrar
If Empty(cParTab)
	AADD(aParamBox,{1,STR0138,cTexto,"@!","","",".T.",100,.f.}) // Texto
Else
	AADD(aParamBox,{1,STR0138,cParTab,"@!","","",".F.",100,.f.}) // Texto
EndIf
//
If ParamBox(aParamBox,STR0712,@aRet,,,,,,,,.f.) // Filtrar
	cQuery := OA5600021_Query_Browse_SQL(cParTab,left(aRet[1],1),Alltrim(aRet[2]),"")
	cOrd := left(aRet[1],1)
Else
	cQuery := OA5600021_Query_Browse_SQL(cParTab,"1","","")
EndIf
If FM_SQL("SELECT COUNT(*) FROM ( "+cQuery+" ) TEMP") == 0
	MsgStop(STR0714,STR0005) // Nenhuma tabela encontrada! / Atenção
Else
	oBrwTab:SetQuery(cQuery+" ORDER BY "+cOrd)
	SQLVX5->(DbGoTop())
	oBrwTab:nAt := 1
	oBrwTab:SetFocus()
	oBrwTab:Refresh()
EndIf
//
Return

/*/{Protheus.doc} OA5600051_Atualizar_VX5()
	Atualizar Tabelas - VX5

	FwRetIdiom() // Retorna o Idioma selecionado pelo usuario
	FwSetIdiom("pt-br") // Seta Portugues Brasil
	FwSetIdiom("es") // Seta Espanhol
	FwSetIdiom("en") // Seta Ingles
	FWI18NLang("OFIOA560","STR0010",10) // Exemplo: Retorna STR0010 de acordo com o Idioma Setado (ultima coluna que diz qual STR é)

    @author Andre Luis Almeida
    @since  25/01/2024
/*/
Function OA5600051_Atualizar_VX5(lRegua)
Local nCntFor     := 0
Local aAux        := {}
Local lErro       := .f.
Default lRegua    := .t.
//
If lRegua
	oProcExec:SetRegua1(0)
	oProcExec:IncRegua1(STR0713) // Levantando Tabelas
EndIf
//
aVX5 := {}
//
OA560PAI() // Adiciona os registros correspondentes as Tabelas VX5 - PADRAO VX5
//
OA560FILHO() // Adiciona os registros filhos PADRAO das Tabelas VX5
//
// TABELAS CUSTOMIZADAS //
//
If ExistBlock("OF560VX5")
	aAux := ExecBlock("OF560VX5",.f.,.f.,{ "1" , "" }) // 1 = Tabelas Customizadas de "Z00" a "ZZZ"
	If ValType(aAux) == "A"
		lErro := .f.
		For nCntFor := 1 to len(aAux)
			If len(aAux[nCntFor,1]) == 3 .and. aAux[nCntFor,1] >= "Z00" .and. aAux[nCntFor,1] <= "ZZZ"
				If Len(aAux[nCntFor]) > 2
					aAdd(aVX5,{ '000' , aAux[nCntFor,1] , aAux[nCntFor,2] , 'U' , aAux[nCntFor,3] , aAux[nCntFor,4] , 0 }) // Tabela Z?? customizada no VX5
				Else
					aAdd(aVX5,{ '000' , aAux[nCntFor,1] , aAux[nCntFor,2] , 'U' }) // Tabela Z?? customizada no VX5
				EndIf
			Else
				lErro := .t.
				Exit
			EndIf
		Next
		If lErro
			MsgStop(STR0053,STR0005) // Os códigos das tabelas customizadas devem ser de "Z00" a "ZZZ". / Atenção
		EndIf
	EndIf
EndIf
//
OA5600061_Gravar_VX5(lRegua) // Gravar as Tabelas no VX5
//
Return()

/*/{Protheus.doc} OA5600061_Gravar_VX5()
    Gravar Tabelas - VX5

    @author Andre Luis Almeida
    @since  25/01/2024
/*/
Static Function OA5600061_Gravar_VX5(lRegua)
Local cIdiom      := FwRetIdiom() // Salva Idioma ORIGINAL - selecionado na entrada do sistema
Local nCntFor     := 0
Local cDesc       := ""
Local cDescEsp    := ""
Local cDescIng    := ""
Local lVX5_UUID   := ( VX5->(FieldPos("VX5_UUID")) > 0 )
Local lVX5_DATALT := ( VX5->(FieldPos("VX5_DATALT")) > 0 )
Local lEspIng     := ( VX5->(ColumnPos("VX5_DESESP")) <> 0 .and. VX5->(ColumnPos("VX5_DESING")) <> 0 )
Local lFoundVX5   := .f.
Local lGrava      := .f.
Local cFilVX5     := xFilial("VX5")
Local cQuebra     := "INICIAL"
Local nTamVX5CODIGO := len( VX5->VX5_CODIGO )
Default lRegua    := .t.
//
DbSelectArea("VX5")
DbSetOrder(1)
//
If lRegua
	oProcExec:SetRegua2(0)
EndIf
//
For nCntFor := 1 to len(aVX5)
	//
	If lRegua .and. cQuebra <> aVX5[nCntFor,1]
		cQuebra := aVX5[nCntFor,1]
		oProcExec:IncRegua2(STR0003+": "+aVX5[nCntFor,1]) // Codigo
	EndIf
	//
	lGrava    := .f. // Não gravar VX5
	cDesc     := aVX5[nCntFor,3]
	cDescEsp  := ""
	cDescIng  := ""
	//
	lFoundVX5 := VX5->(DbSeek(cFilVX5+aVX5[nCntFor,1]+padR(aVX5[nCntFor,2],nTamVX5CODIGO)))
	//
	If lFoundVX5 .and. VX5->VX5_PROPRI == "U" // Ja tem VX5 e é customizado
		cDesc := VX5->VX5_DESCRI
		If lEspIng
			cDescEsp := IIf(!Empty(VX5->VX5_DESESP),VX5->VX5_DESESP,cDesc)
			cDescIng := IIf(!Empty(VX5->VX5_DESING),VX5->VX5_DESING,cDesc)
		EndIf
		lGrava := .t. // Gravar VX5
	Else // Não tem VX5 ou é registro padrão do Sistema DMS
		If lFoundVX5 // Ja tem VX5
			If lEspIng .and. ( Empty(VX5->VX5_DESESP) .or. Empty(VX5->VX5_DESING) ) // Esta sem Descrição em Espanhol ou Ingles
				lGrava := .t. // Gravar VX5
			EndIf
		Else // Não tem VX5
			lGrava := .t. // Gravar VX5
		EndIf
		If lGrava .and. len(aVX5[nCntFor]) >= 7
			If aVX5[nCntFor,7] > 0 // Possui o STR no CH
				FwSetIdiom("pt-br") // Seta Portugues Brasil
				cDesc := STRTRAN(aVX5[nCntFor,3], "#STR#",FWI18NLang("OFIOA560","STR"+strzero(aVX5[nCntFor,7],4),aVX5[nCntFor,7])) // Monta Texto em Portugues
				If lEspIng
					FwSetIdiom("es") // Seta Espanhol
					cDescEsp := STRTRAN(aVX5[nCntFor,3], "#STR#",FWI18NLang("OFIOA560","STR"+strzero(aVX5[nCntFor,7],4),aVX5[nCntFor,7])) // Monta Texto em Espanhol
					FwSetIdiom("en") // Seta Ingles
					cDescIng := STRTRAN(aVX5[nCntFor,3], "#STR#",FWI18NLang("OFIOA560","STR"+strzero(aVX5[nCntFor,7],4),aVX5[nCntFor,7])) // Monta Texto em Ingles
				EndIf
			Else
				cDescEsp  := cDescIng  := cDesc // Não tem Tradução - mantem o mesmo texto nos 3 idiomas (Portugues, Espanhol e Ingles)
			EndIf
		EndIf
	EndIf
	If lGrava
		RecLock("VX5",!lFoundVX5)
		VX5->VX5_FILIAL := cFilVX5
		VX5->VX5_CHAVE  := aVX5[nCntFor,1]
		VX5->VX5_CODIGO := padR(aVX5[nCntFor,2],nTamVX5CODIGO)
		VX5->VX5_DESCRI := cDesc // Portugues
		If lEspIng
			VX5->VX5_DESESP := cDescEsp // Espanhol
			VX5->VX5_DESING := cDescIng // Ingles
		EndIf
		VX5->VX5_PROPRI := aVX5[nCntFor,4]
		if lVX5_UUID .and. empty(VX5->VX5_UUID)
			VX5->VX5_UUID := FWUUIDV4(.t.)
		endif
		if lVX5_DATALT
			if lFoundVX5
				VX5->VX5_DATALT := FGX_Timestamp()
			else
				VX5->VX5_DATINC := FGX_Timestamp()
			endif
		endif
		MsUnLock()
	EndIf
Next
//
FwSetIdiom(cIdiom) // Seta Idioma ORIGINAL - selecionado na entrada do sistema
//
OA5600091_Grava_Versao_VX5(OA5600071_Versao_PRW()) // Gravar na Tabela VX5 a versão que rodou
//
Return

/*/{Protheus.doc} OA5600081_Versao_VX5_gravado
	Retorna a Versão que esta gravada na Tabela VX5

	@author Andre Luis Almeida
	@since  02/02/2024
/*/
Function OA5600081_Versao_VX5_gravado()
Return Alltrim(MpSysExecScalar( "SELECT VX5_DESCRI FROM " + RetSQLName("VX5") + " WHERE VX5_FILIAL = '"+FWxFilial("VX5")+"' AND VX5_CHAVE = 'VX5' AND VX5_CODIGO = 'VX5' AND D_E_L_E_T_=' '" , "VX5_DESCRI" ))

/*/{Protheus.doc} OA5600091_Grava_Versao_VX5
	Grava a Versão na Tabela VX5 - Registro que controla a Atualização na VX5

	@author Andre Luis Almeida
	@since  06/02/2024
/*/
Static Function OA5600091_Grava_Versao_VX5(cVersao)
Local lVX5_UUID   := ( VX5->(FieldPos("VX5_UUID")) > 0 )
Local lVX5_DATALT := ( VX5->(FieldPos("VX5_DATALT")) > 0 )
Default cVersao   := ""
DbSelectArea("VX5")
nRecVX5 := MpSysExecScalar( "SELECT R_E_C_N_O_ AS RECVX5 FROM " + RetSQLName("VX5") + " WHERE VX5_FILIAL = '"+FWxFilial("VX5")+"' AND VX5_CHAVE = 'VX5' AND VX5_CODIGO = 'VX5' AND D_E_L_E_T_=' '" , "RECVX5" )
If nRecVX5 > 0
	VX5->(DbGoTo(nRecVX5)) // Posiciona no Registro do VX5 que controla a Versao
EndIf
RecLock("VX5", nRecVX5 == 0 )
If nRecVX5 == 0
	VX5->VX5_FILIAL := FWxFilial("VX5")
	VX5->VX5_CHAVE  := "VX5"
	VX5->VX5_CODIGO := "VX5"
EndIf
VX5->VX5_DESCRI := cVersao // Portugues
VX5->VX5_PROPRI := "S"
if lVX5_UUID .and. Empty(VX5->VX5_UUID)
	VX5->VX5_UUID := FWUUIDV4(.t.)
endif
if lVX5_DATALT
	if nRecVX5 <> 0
		VX5->VX5_DATALT := FGX_Timestamp()
	Else
		VX5->VX5_DATINC := FGX_Timestamp()
	endif
endif
MsUnLock()
Return
