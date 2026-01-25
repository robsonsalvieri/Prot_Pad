#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "VEIA300.CH"

CLASS VEIA300EVDEF FROM FWModelEvent

	Data lEftetiva // Efetiva?
	Data cVV1001   // CHAINT 1
	Data cVV1002   // CHAINT 2
	Data cPRW_VEIA // PRW da Execução VEIA301 a VEIA316
	Data cPro_VEIA // Processo: 1=Agrega (Individual) / 2=Desagrega (Individual) / 3=Transferência / 4=Troca
	Data cTip_VEIA // Tipo: 1=Notas Fiscais / 2=Movimentações Internas
	Data cIte_VEIA // Item: 1=AMS / 2=Peças
	Data aCli_VEIA // Cliente
	Data aFor_VEIA // Fornecedor
	Data cD3_TME   // Tipo de movimentação interna de Entrada
	Data cD3_TMS   // Tipo de movimentação interna de Saida

	METHOD New() CONSTRUCTOR
	METHOD VldActivate()
	METHOD Activate()
	METHOD FieldPreVld()
	METHOD GridLinePreVld()
	METHOD ModelPosVld()
	METHOD AfterTTS()
	METHOD CalculaCusto()
	METHOD AtualizaCustoFuturo()
	METHOD PosicionaVV1SB1()
	METHOD PosicionaSB2()
	METHOD ReplicaDadosLinha()
	METHOD Destroy()

ENDCLASS

// New //
METHOD New() CLASS VEIA300EVDEF
	::lEftetiva := .f.           // Efetiva?
	::cVV1001   := ""            // CHAINT 1
	::cVV1002   := ""            // CHAINT 2
	::cPRW_VEIA := ""            // PRW da Execução VEIA301 a VEIA316
	::cPro_VEIA := ""            // Processo: 1=Agrega (Individual) / 2=Desagrega (Individual) / 3=Transferência / 4=Troca
	::cTip_VEIA := ""            // Tipo: 1=Notas Fiscais / 2=Movimentações Internas
	::cIte_VEIA := ""            // Item: 1=AMS / 2=Peças
	::aCli_VEIA := {"","","",""} // Cliente (A1_COD, A1_LOJA, A1_NOME, A1_TIPO)
	::aFor_VEIA := {"","","",""} // Fornecedor (A2_COD, A2_LOJA, A2_NOME, A2_TIPO)
	::cD3_TME   := ""            // Tipo de movimentação interna de Entrada
	::cD3_TMS   := ""            // Tipo de movimentação interna de Saida
RETURN .T.

//Validação antes da abertura da tela
METHOD VldActivate(oModel, cModelId) CLASS VEIA300EVDEF	
Local nOperation := oModel:GetOperation()	
Local lRet  := .t.
Local cProc := VA3000061_PRW( 1 , cModelID ) // Retorna o Processo + Tipo + Item do Fonte executado
Local aCli_VEIA := {}
Local aFor_VEIA := {}
::lEftetiva := .f.
::cPRW_VEIA := cModelID // PRW da Execução VEIA301 a VEIA316
::cPro_VEIA := substr(cProc,1,1) // Processo: 1=Agrega (Individual) / 2=Desagrega (Individual) / 3=Transferência / 4=Troca
::cTip_VEIA := substr(cProc,2,1) // Tipo: 1=Notas Fiscais / 2=Movimentações Internas
::cIte_VEIA := substr(cProc,3,1) // Item: 1=AMS / 2=Peças
If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	//
	aCli_VEIA := VA300017D_RetornaCliente()//Cliente
	aFor_VEIA := VA300018D_RetornaFornecedor()//Fornecedor
	//
	lRet := ( Len(aCli_VEIA) > 0 .and. Len(aFor_VEIA) > 0 )//É necessário existir cliente e fornecedor cadastrados para a filial logada.
	If lRet
		::aCli_VEIA := aClone(aCli_VEIA)// Cliente
		::aFor_VEIA := aClone(aFor_VEIA)//Fornecedor
	EndIf
	//
	If lRet .and. ::cTip_VEIA == "2" // Somente na inclusão quando 2 = Movimentação Internas
		::cD3_TME   := GetNewPar("MV_MIL0114","") // MV_MIL0114 - Tipo de movimentação interna de entrada
		::cD3_TMS   := GetNewPar("MV_MIL0115","") // MV_MIL0115 - Tipo de movimentação interna de saída
		If Empty(::cD3_TME)
			Help("",1,"VLDACTIVATE",,STR0075,1,0) // Para realizar movimentações internas é necessário o preenchimento do parâmetro MV_MIL0114.
			lRet := .f.
		Else
			DBSelectArea("SF5")
			DBSetOrder(1)
			If !DbSeek(xFilial("SF5")+::cD3_TME)
				Help("",1,"VLDACTIVATE",,STR0076,1,0) // Tipo de Entrada informado não encontrado no Cadastro de Tipos de Movimentação.
				lRet := .f.
			EndIf
		EndIf
		If Empty(::cD3_TMS)
			Help("",1,"VLDACTIVATE",,STR0077,1,0) // Para realizar movimentações internas é necessário o preenchimento do parâmetro MV_MIL0115.
			lRet := .f.
		Else
			DBSelectArea("SF5")
			DBSetOrder(1)
			If !DbSeek(xFilial("SF5")+::cD3_TMS)
				Help("",1,"VLDACTIVATE",,STR0078,1,0) // Tipo de Saida informado não encontrado no Cadastro de Tipos de Movimentação.
				lRet := .f.
			EndIf
		EndIf
	EndIf
EndIf
RETURN lRet

// Abertura TELA //
METHOD Activate(oModel, lCopy) CLASS VEIA300EVDEF
	Local oModNFS
	Local oModNFE
	Local oModMov
	Local oModVFM
	Local oModVFP
	Local nCntFor := 0
	Local nCusAtu := 0
	Local nLinNFS := 1
	Local nLinNFE := 1
	Local nLinMov := 1
	If oModel:GetOperation() == MODEL_OPERATION_INSERT // Incluir
		oModel:LoadValue( "VFJMASTER", "VFJ_PROCES", ::cPro_VEIA ) // Processo
		oModel:LoadValue( "VFJMASTER", "VFJ_TIPPRO", ::cTip_VEIA ) // Tipo
		oModel:LoadValue( "VFJMASTER", "VFJ_TIPITE", ::cIte_VEIA ) // Item
		If ::cTip_VEIA == "1" // 1 = Notas Fiscais
			/////////////////
			// NFs Saida   //
			/////////////////
			oModNFS := oModel:GetModel("VFKDETAIL")
			oModNFS:SetNoInsertLine(.f.)
			oModNFS:GoLine(nLinNFS++)
			If ::cPro_VEIA $ "1/2" // 1 = Agrega (Individual) / 2 = Desagrega (Individual)
				oModNFS:LoadValue("VFK_AGRDES" , ::cPro_VEIA )
			ElseIf ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModNFS:LoadValue("VFK_AGRDES" , "2" ) // 2 = Desagrega
			EndIf
			oModNFS:LoadValue("VFK_TIPREG" , "1" ) // 1 = NF Saida Equipamento 1
			If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S21" ) )
			EndIf
			oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
			oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
			oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
			oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
			Do Case
				Case ::cPro_VEIA == "1" // 1 = Agrega
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFS:AddLine()
						oModNFS:GoLine(nLinNFS++)
						oModNFS:LoadValue("VFK_AGRDES" , "1" ) // 1 = Agrega
						oModNFS:LoadValue("VFK_TIPREG" , "2" ) // 2 = NF Saida Peça para Agregar no 1
						oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
						oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
						oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
						oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					EndIf
				Case ::cPro_VEIA == "3" // 3 = Transferencia
					oModNFS:AddLine()
					oModNFS:GoLine(nLinNFS++)
					oModNFS:LoadValue("VFK_AGRDES" , "1" ) // 1 = Agrega
					oModNFS:LoadValue("VFK_TIPREG" , "3" ) // 3 = NF Saida Equipamento 2
					oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S13" ) )
					oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
					oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
					oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
					oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFS:AddLine()
						oModNFS:GoLine(nLinNFS++)
						oModNFS:LoadValue("VFK_AGRDES" , "1" ) // 1 = Agrega
						oModNFS:LoadValue("VFK_TIPREG" , "4" ) // 4 = NF Saida Peça para Agregar 2
						oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S14" ) )
						oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
						oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
						oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
						oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					EndIf
				Case ::cPro_VEIA == "4" // 4 = Troca
					oModNFS:AddLine()
					oModNFS:GoLine(nLinNFS++)
					oModNFS:LoadValue("VFK_AGRDES" , "1" ) // 1 = Agrega
					oModNFS:LoadValue("VFK_TIPREG" , "3" ) // 3 = NF Saida Equipamento 2
					oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S13" ) )
					oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
					oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
					oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
					oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFS:AddLine()
						oModNFS:GoLine(nLinNFS++)
						oModNFS:LoadValue("VFK_AGRDES" , "1" ) // 1 = Agrega
						oModNFS:LoadValue("VFK_TIPREG" , "4" ) // 4 = NF Saida Peça para Agregar 2
						oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S14" ) )
						oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
						oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
						oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
						oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					EndIf
					oModNFS:AddLine()
					oModNFS:GoLine(nLinNFS++)
					oModNFS:LoadValue("VFK_AGRDES" , "2" ) // 2 = Desagrega
					oModNFS:LoadValue("VFK_TIPREG" , "3" ) // 3 = NF Saida Equipamento 2
					oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S23" ) )
					oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
					oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
					oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
					oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					oModNFS:AddLine()
					oModNFS:GoLine(nLinNFS++)
					oModNFS:LoadValue("VFK_AGRDES" , "1" ) // 1 = Agrega
					oModNFS:LoadValue("VFK_TIPREG" , "1" ) // 1 = NF Saida Equipamento 1
					oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S11" ) )
					oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
					oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
					oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
					oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFS:AddLine()
						oModNFS:GoLine(nLinNFS++)
						oModNFS:LoadValue("VFK_AGRDES" , "1" ) // 1 = Agrega
						oModNFS:LoadValue("VFK_TIPREG" , "2" ) // 2 = NF Saida Peça para Agregar no 1
						oModNFS:LoadValue("EVENTO" , VA3000121_CorEvento( "VFK" , "S12" ) )
						oModNFS:LoadValue("VFK_CODIGO",GetSXENum("VFK","VFK_CODIGO"))
						oModNFS:LoadValue("VFK_CODCLI",::aCli_VEIA[1])
						oModNFS:LoadValue("VFK_LOJCLI",::aCli_VEIA[2])
						oModNFS:LoadValue("VFK_NOMCLI",Left(::aCli_VEIA[3],GetSX3Cache("VFK_NOMCLI", "X3_TAMANHO")))
					EndIf
			EndCase
			oModNFS:GoLine(1)
			oModNFS:SetNoInsertLine(.t.)
			/////////////////
			// NFs Entrada //
			/////////////////
			oModNFE := oModel:GetModel("VFLDETAIL")
			oModNFE:SetNoInsertLine(.f.)
			oModNFE:GoLine(nLinNFE++)
			If ::cPro_VEIA $ "1/2" // 1 = Agrega (Individual) / 2 = Desagrega (Individual)
				oModNFE:LoadValue("VFL_AGRDES" , ::cPro_VEIA )
			ElseIf ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModNFE:LoadValue("VFL_AGRDES" , "2" ) // 2 = Desagrega
			EndIf
			oModNFE:LoadValue("VFL_TIPREG" , "1" ) // 1 = NF Entrada Equipamento 1
			If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E21" ) )
			EndIf
			oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
			oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
			oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
			oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
			Do Case
				Case ::cPro_VEIA == "2" // 2 = Desagrega
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFE:AddLine()
						oModNFE:GoLine(nLinNFE++)
						oModNFE:LoadValue("VFL_AGRDES" , "2" ) // 2 = Desagrega
						oModNFE:LoadValue("VFL_TIPREG" , "2" ) // 2 = NF Entrada Peça para Desagregar 1
						oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
						oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
						oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
						oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
					EndIf
				Case ::cPro_VEIA == "3" // 3 = Transferencia
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFE:AddLine()
						oModNFE:GoLine(nLinNFE++)
						oModNFE:LoadValue("VFL_AGRDES" , "2" ) // 2 = Desagrega
						oModNFE:LoadValue("VFL_TIPREG" , "2" ) // 2 = NF Entrada Peça para Desagregar 1
						oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E22" ) )
						oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
						oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
						oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
						oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
					EndIf
					oModNFE:AddLine()
					oModNFE:GoLine(nLinNFE++)
					oModNFE:LoadValue("VFL_AGRDES" , "1" ) // 1 = Agrega
					oModNFE:LoadValue("VFL_TIPREG" , "3" ) // 3 = NF Entrada Equipamento 2
					oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E13" ) )
					oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
					oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
					oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
					oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
				Case ::cPro_VEIA == "4" // 4 = Troca
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFE:AddLine()
						oModNFE:GoLine(nLinNFE++)
						oModNFE:LoadValue("VFL_AGRDES" , "2" ) // 2 = Desagrega
						oModNFE:LoadValue("VFL_TIPREG" , "2" ) // 2 = NF Entrada Peça para Desagregar 1
						oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E22" ) )
						oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
						oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
						oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
						oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
					EndIf
					oModNFE:AddLine()
					oModNFE:GoLine(nLinNFE++)
					oModNFE:LoadValue("VFL_AGRDES" , "1" ) // 1 = Agrega
					oModNFE:LoadValue("VFL_TIPREG" , "3" ) // 3 = NF Entrada Equipamento 2
					oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E13" ) )
					oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
					oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
					oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
					oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
					oModNFE:AddLine()
					oModNFE:GoLine(nLinNFE++)
					oModNFE:LoadValue("VFL_AGRDES" , "2" ) // 2 = Desagrega
					oModNFE:LoadValue("VFL_TIPREG" , "3" ) // 3 = NF Entrada Equipamento 2
					oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E23" ) )
					oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
					oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
					oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
					oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
					If ::cIte_VEIA == "2" // 2 = Peças
						oModNFE:AddLine()
						oModNFE:GoLine(nLinNFE++)
						oModNFE:LoadValue("VFL_AGRDES" , "2" ) // 2 = Desagrega
						oModNFE:LoadValue("VFL_TIPREG" , "4" ) // 4 = NF Entrada Peça para Desagregar 2
						oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E24" ) )
						oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
						oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
						oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
						oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
					EndIf
					oModNFE:AddLine()
					oModNFE:GoLine(nLinNFE++)
					oModNFE:LoadValue("VFL_AGRDES" , "1" ) // 1 = Agrega
					oModNFE:LoadValue("VFL_TIPREG" , "1" ) // 1 = NF Entrada Equipamento 1
					oModNFE:LoadValue("EVENTO" , VA3000121_CorEvento( "VFL" , "E11" ) )
					oModNFE:LoadValue("VFL_CODIGO",GetSXENum("VFL","VFL_CODIGO"))
					oModNFE:LoadValue("VFL_CODFOR",::aFor_VEIA[1])
					oModNFE:LoadValue("VFL_LOJFOR",::aFor_VEIA[2])
					oModNFE:LoadValue("VFL_NOMFOR",Left(::aFor_VEIA[3],GetSX3Cache("VFL_NOMFOR", "X3_TAMANHO")))
			EndCase
			oModNFE:GoLine(1)
			oModNFE:SetNoInsertLine(.t.)
			//
		ElseIf ::cTip_VEIA == "2" // 2 = Movimentações Internas
			//
			oModMov := oModel:GetModel("VFODETAIL")
			oModMov:SetNoInsertLine(.f.)
			oModMov:GoLine(nLinMov++)
			oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
			If ::cPro_VEIA $ "1/2" // 1 = Agrega (Individual) / 2 = Desagrega (Individual)
				oModMov:LoadValue("VFO_AGRDES" , ::cPro_VEIA )
			ElseIf ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModMov:LoadValue("VFO_AGRDES" , "2" ) // 2 = Desagrega
			EndIf
			oModMov:LoadValue("VFO_TIPREG" , "1" ) // 1 = Saida Veículo/Máquina/Equipamento 1
			If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M21" ) )
			EndIf
			oModMov:LoadValue("VFO_TIPMOV", ::cD3_TMS)
			If ::cPro_VEIA == "1" // 1 = Agrega
				If ::cIte_VEIA == "2" // 2 = Peças
					oModMov:AddLine()
					oModMov:GoLine(nLinMov++)
					oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
					oModMov:LoadValue("VFO_AGRDES" , "1" ) // 1 = Agrega
					oModMov:LoadValue("VFO_TIPREG" , "2" ) // 2 = Saida Peças para Agregar no 1
					oModMov:LoadValue("VFO_TIPMOV", ::cD3_TMS)
				EndIf
			EndIf
			oModMov:AddLine()
			oModMov:GoLine(nLinMov++)
			oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
			If ::cPro_VEIA $ "1/2" // 1 = Agrega (Individual) / 2 = Desagrega (Individual)
				oModMov:LoadValue("VFO_AGRDES" , ::cPro_VEIA )
			ElseIf ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModMov:LoadValue("VFO_AGRDES" , "2" ) // 2 = Desagrega
			EndIf
			oModMov:LoadValue("VFO_TIPREG" , "5" ) // 5 = Entrada Veículo/Máquina/Equipamento 1
			If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M25" ) )
			EndIf
			oModMov:LoadValue("VFO_TIPMOV", ::cD3_TME)
			If ::cPro_VEIA $ "2/3/4" // 2 = Desagrega / 3 = Transferencia / 4 = Troca"
				If ::cIte_VEIA == "2" // 2 = Peças
					oModMov:AddLine()
					oModMov:GoLine(nLinMov++)
					oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
					oModMov:LoadValue("VFO_AGRDES" , "2" ) // 2 = Desagrega
					oModMov:LoadValue("VFO_TIPREG" , "6" ) // 6 = Entrada Peças para Desagregar do 1
					If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
						oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M26" ) )
					EndIf
					oModMov:LoadValue("VFO_TIPMOV", ::cD3_TME)
				Endif
			EndIf
			If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				oModMov:AddLine()
				oModMov:GoLine(nLinMov++)
				oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
				oModMov:LoadValue("VFO_AGRDES" , "1" ) // 1 = Agrega
				oModMov:LoadValue("VFO_TIPREG" , "3" ) // 3 = Saida Veículo/Máquina/Equipamento 2
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M13" ) )
				oModMov:LoadValue("VFO_TIPMOV", ::cD3_TMS)
				If ::cIte_VEIA == "2" // 2 = Peças
					oModMov:AddLine()
					oModMov:GoLine(nLinMov++)
					oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
					oModMov:LoadValue("VFO_AGRDES" , "1" ) // 1 = Agrega
					oModMov:LoadValue("VFO_TIPREG" , "4" ) // 4 = Saida Peças para Agregar no 2
					oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M14" ) )
					oModMov:LoadValue("VFO_TIPMOV", ::cD3_TMS)
				EndIf
				oModMov:AddLine()
				oModMov:GoLine(nLinMov++)
				oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
				oModMov:LoadValue("VFO_AGRDES" , "1" ) // 1 = Agrega
				oModMov:LoadValue("VFO_TIPREG" , "7" ) // 7 = Entrada Veículo/Máquina/Equipamento 2
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M17" ) )
				oModMov:LoadValue("VFO_TIPMOV", ::cD3_TME)
			EndIf
			If ::cPro_VEIA == "4" // 4 = Troca
				oModMov:AddLine()
				oModMov:GoLine(nLinMov++)
				oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
				oModMov:LoadValue("VFO_AGRDES" , "2" ) // 2 = Desagrega
				oModMov:LoadValue("VFO_TIPREG" , "3" ) // 3 = Saida Veículo/Máquina/Equipamento 2
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M23" ) )
				oModMov:LoadValue("VFO_TIPMOV", ::cD3_TMS)
				oModMov:AddLine()
				oModMov:GoLine(nLinMov++)
				oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
				oModMov:LoadValue("VFO_AGRDES" , "2" ) // 2 = Desagrega
				oModMov:LoadValue("VFO_TIPREG" , "7" ) // 7 = Entrada Veículo/Máquina/Equipamento 2
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M27" ) )
				oModMov:LoadValue("VFO_TIPMOV", ::cD3_TME)
				If ::cIte_VEIA == "2" // 2 = Peças
					oModMov:AddLine()
					oModMov:GoLine(nLinMov++)
					oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
					oModMov:LoadValue("VFO_AGRDES" , "2" ) // 2 = Desagrega
					oModMov:LoadValue("VFO_TIPREG" , "8" ) // 8 = Entrada Peças para Desagregar do 2
					oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M28" ) )
					oModMov:LoadValue("VFO_TIPMOV", ::cD3_TME)
				EndIf
				oModMov:AddLine()
				oModMov:GoLine(nLinMov++)
				oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
				oModMov:LoadValue("VFO_AGRDES" , "1" ) // 1 = Agrega
				oModMov:LoadValue("VFO_TIPREG" , "1" ) // 1 = Saida Veículo/Máquina/Equipamento 1
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M11" ) )
				oModMov:LoadValue("VFO_TIPMOV", ::cD3_TMS)
				If ::cIte_VEIA == "2" // 2 = Peças
					oModMov:AddLine()
					oModMov:GoLine(nLinMov++)
					oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
					oModMov:LoadValue("VFO_AGRDES" , "1" ) // 1 = Agrega
					oModMov:LoadValue("VFO_TIPREG" , "2" ) // 2 = Saida Peças para Agregar no 1
					oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M12" ) )
					oModMov:LoadValue("VFO_TIPMOV", ::cD3_TMS)
				EndIf
				oModMov:AddLine()
				oModMov:GoLine(nLinMov++)
				oModMov:LoadValue("VFO_CODIGO",GetSXENum("VFO","VFO_CODIGO"))
				oModMov:LoadValue("VFO_AGRDES" , "1" ) // 1 = Agrega
				oModMov:LoadValue("VFO_TIPREG" , "5" ) // 5 = Entrada Veículo/Máquina/Equipamento 1
				oModMov:LoadValue("EVENTO" , VA3000121_CorEvento( "VFO" , "M15" ) )
				oModMov:LoadValue("VFO_TIPMOV", ::cD3_TME)
			EndIf
			oModMov:GoLine(1)
			oModMov:SetNoInsertLine(.t.)
			//
		EndIf
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE // Alterar
		::cVV1001 := oModel:GetValue( "VFJMASTER", "VFJ_VV1001")
		::cVV1002 := oModel:GetValue( "VFJMASTER", "VFJ_VV1002")
		oModel:SetValue( "VFJMASTER", "VFJ_CODIGO", VFJ->VFJ_CODIGO ) // Necessario para possibilitar dar OK sem precisar alterar os dados na Alteração
		If !Empty(::cVV1001) .and. ::PosicionaVV1SB1(::cVV1001)
			If ::PosicionaSB2()
				nCusAtu := round(SB2->B2_CM1,2) // Custo Atual
				oModel:SetValue( "VFJMASTER", "VFJ_CUSAT1", nCusAtu)
				oModel:SetValue( "VFJTOTAIS", "VFJ_CUSAT1", nCusAtu)
			EndIf
		EndIf
		If !Empty(::cVV1002) .and. ::PosicionaVV1SB1(::cVV1002)
			If ::PosicionaSB2()
				nCusAtu := round(SB2->B2_CM1,2) // Custo Atual
				oModel:SetValue( "VFJMASTER", "VFJ_CUSAT2", nCusAtu)
				oModel:SetValue( "VFJTOTAIS", "VFJ_CUSAT2", nCusAtu)
			EndIf
		EndIf
		If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
			::AtualizaCustoFuturo("1",::cPro_VEIA)
		ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
			::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
			::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
		ElseIf ::cPro_VEIA == "4" // 4 = Troca
			nCusAtu := ::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
			::AtualizaCustoFuturo("1","1",nCusAtu) // ChaInt 1 - Agregar
			nCusAtu := ::AtualizaCustoFuturo("2","2") // ChaInt 2 - Desagregar
			::AtualizaCustoFuturo("2","1",nCusAtu) // ChaInt 2 - Agregar
		EndIf
	EndIf
	If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
		If oModel:GetOperation() <> MODEL_OPERATION_INSERT // Diferente de Incluir
			If ::cIte_VEIA == "1" // 1 = AMS
				oModel  := FWModelActive()
				oModVFM := oModel:GetModel("VFMDETAIL")
				oModVFP := oModel:GetModel("VFPDETAIL")
				For nCntFor := 1 to oModVFP:Length()
					oModVFP:GoLine(nCntFor)
					oModVFM:GoLine(nCntFor)
					If !Empty( oModVFP:GetValue("VFP_REFSAI") ) // Preencher campos da aba PARA quando não for Incluir
						oModVFM:LoadValue( "VFM_CHAINT" , oModVFP:GetValue("VFP_CHAINT") )
						oModVFM:LoadValue( "VFM_CHASSI" , oModVFP:GetValue("VFP_CHASSI") )
						oModVFM:LoadValue( "VFM_CODMAR" , oModVFP:GetValue("VFP_CODMAR") )
						oModVFM:LoadValue( "VFM_MODVEI" , oModVFP:GetValue("VFP_MODVEI") )
						oModVFM:LoadValue( "VFM_SEGMOD" , oModVFP:GetValue("VFP_SEGMOD") )
						oModVFM:LoadValue( "VFM_CORVEI" , oModVFP:GetValue("VFP_CORVEI") )
					EndIf
					If ::cPro_VEIA == "4" // 4 = Troca
						oModVFP:LoadValue( "EVENTO" , IIf(oModVFP:GetValue("VFP_VEIMAQ")=="1","gr_blue01","gr_blue03") ) // Legenda - Sequencial dos Eventos
						oModVFM:LoadValue( "EVENTO" , IIf(oModVFM:GetValue("VFM_VEIMAQ")=="2","gr_blue02","gr_blue04") ) // Legenda - Sequencial dos Eventos
					EndIf
				Next
				oModVFM:GoLine(1)
				oModVFP:GoLine(1)
			ElseIf ::cIte_VEIA == "2" // 2 = Peças
				If ::cPro_VEIA == "4" // 4 = Troca
					oModel  := FWModelActive()
					oModVFN := oModel:GetModel("VFNDETAIL")
					oModVFQ := oModel:GetModel("VFQDETAIL")
					For nCntFor := 1 to oModVFQ:Length()
						oModVFQ:GoLine(nCntFor)
						oModVFN:GoLine(nCntFor)
						oModVFQ:LoadValue( "EVENTO" , IIf(oModVFQ:GetValue("VFQ_VEIMAQ")=="1","gr_blue01","gr_blue03") ) // Legenda - Sequencial dos Eventos
						oModVFN:LoadValue( "EVENTO" , IIf(oModVFN:GetValue("VFN_VEIMAQ")=="2","gr_blue02","gr_blue04") ) // Legenda - Sequencial dos Eventos
					Next
					oModVFN:GoLine(1)
					oModVFQ:GoLine(1)
				EndIf
			EndIf
		EndIf
	EndIf
RETURN .T.

// Campos Cabeçalho VFJ //
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA300EVDEF
Local lRet      := .t.
Local oVeiculos 
Local oModel
If cModelId == "VFJMASTER"
	If cAction == "SETVALUE" // Valid do campo
		If cId $ "VFJ_VV1001/VFJ_VV1002/"
			If cId == "VFJ_VV1001" .and. FWFldGet("VFJ_VV1001") <> xValue
				oSubModel:LoadValue( "VFJ_MAR001" , "" )
				oSubModel:LoadValue( "VFJ_MOD001" , "" )
				oSubModel:LoadValue( "VFJ_CHA001" , "" )
				oSubModel:LoadValue( "VFJ_CUSAT1", 0)
				oSubModel:LoadValue( "VFJ_CUSFT1", 0)
				oModel := FWModelActive()
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSAT1" , 0 )
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT1" , 0 )
				::cVV1001 := xValue
			Elseif cId == "VFJ_VV1002" .and. FWFldGet("VFJ_VV1001") <> xValue
				oSubModel:LoadValue( "VFJ_MAR002" , "" )
				oSubModel:LoadValue( "VFJ_MOD002" , "" )
				oSubModel:LoadValue( "VFJ_CHA002" , "" )
				oSubModel:LoadValue( "VFJ_CUSAT2", 0)
				oSubModel:LoadValue( "VFJ_CUSFT2", 0)
				oModel := FWModelActive()
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSAT2" , 0 )
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT2" , 0 )
				::cVV1002 := xValue
			EndIf
			If !Empty(xValue)
				DbSelectArea("VV1")
				DbSetOrder(1) // CHAINT
				If DbSeek( xFilial("VV1") + xValue )
					oVeiculos := DMS_Veiculo():New()
					If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
						lRet := .f. // A mensagem já é exibida dentro da função Bloqueado()
					EndIf
					If lRet .and. oVeiculos:DtUltimaMovimentacao(VV1->VV1_CHASSI) > dDataBase // Valida referente a DataBase
						Help("",1,"FIELDPREVLD "+cId,,STR0079,1,0) // Chassi com movimentacao posterior a data atual.
						lRet := .f.
					EndIf
					If lRet
						If VV1->VV1_SITVEI == '0' .and. VV1->VV1_GRASEV <> '6' .and. VV1->VV1_FILENT == xFilial("VVF")
							If cId == "VFJ_VV1001"
								If xValue == oSubModel:GetValue("VFJ_VV1002")
									Help("",1,"FIELDPREVLD "+cId,,STR0080,1,0) // Veículo/Máquina/Equipamento 1 precisa ser diferente do 2.
									lRet := .f.
								EndIf
							ElseIf cId == "VFJ_VV1002"
								If xValue == oSubModel:GetValue("VFJ_VV1001")
									Help("",1,"FIELDPREVLD "+cId,,STR0081,1,0) // Veículo/Máquina/Equipamento 2 precisa ser diferente do 1.
									lRet := .f.
								EndIf
							EndIf
						Else
							Help("",1,"FIELDPREVLD "+cId,,STR0082,1,0) // Veículo/Máquina/Equipamento não encontrado em estoque na Filial logada.
							lRet := .f.
						EndIf
					EndIf
				Else
					Help("",1,"FIELDPREVLD "+cId,,STR0083,1,0) // Veículo/Máquina/Equipamento não encontrado.
					lRet := .f.
				EndIf
			EndIf
			If lRet
				If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
					::CalculaCusto(IIf(cId=="VFJ_VV1001","1","2"),::cPro_VEIA)
				ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
					If cId == "VFJ_VV1001"
						::CalculaCusto("1","2") // ChaInt 1 - Desagregar
					ElseIf cId == "VFJ_VV1002"
						::CalculaCusto("2","1") // ChaInt 2 - Agregar
					EndIf
				ElseIf ::cPro_VEIA == "4" // 4 = Troca
					::CalculaCusto("1","4") // ChaInt 1 - Desagregar + Agregar
					::CalculaCusto("2","4") // ChaInt 2 - Desagregar + Agregar 
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RETURN lRet

// Campos Filhos //
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA300EVDEF
Local lRet      := .t.
Local cNroVeic  := ""
Local cTESInt   := ""
Local cSiglaAMS := ""
Local aQUltMov  := {}
Local nCusFut   := 0
Local nCusAtu   := 0
Local oVeiculos
Local oModel
Local oModVFM
Local oModVFN
Local oView
Local oPeca
Local cGruVei   := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Private cGruIte := Criavar("B1_GRUPO")
Private cCodIte := Criavar("B1_CODITE")
Do Case
	Case cModelID == "VFMDETAIL" // AMS	- Saida
		If cAction == "SETVALUE"
			If cId == "VFM_CHAINT"
				oSubModel:LoadValue("VFM_CUSUNI", 0)
				If !Empty(xValue)
					If ::PosicionaVV1SB1( xValue )
						cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS
						oVeiculos := DMS_Veiculo():New()
						If oVeiculos:DtUltimaMovimentacao(VV1->VV1_CHASSI) > dDataBase // Valida referente a DataBase
							Help("",1,"FIELDPREVLD "+cId,,cSiglaAMS + " - " + STR0079,1,0) // Chassi com movimentacao posterior a data atual.
							lRet := .f.
						EndIf
						If lRet .and. !(VV1->VV1_SITVEI == '0' .and. VV1->VV1_GRASEV == '6' .and. VV1->VV1_FILENT == xFilial("VVF"))
							Help("",1,"FIELDPREVLD "+cId,,cSiglaAMS + " - " +STR0084,1,0) // Registro não encontrado em estoque na Filial logada.
							lRet := .f.
						EndIf
					Else
						Help("",1,"FIELDPREVLD "+cId,,STR0085,1,0) // Registro não encontrado.
						lRet := .f.
					EndIf
					If lRet
						If ::PosicionaSB2()
							oSubModel:LoadValue("VFM_CUSUNI", round(SB2->B2_CM1,2))
						EndIf
					EndIf
				EndIf
				If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
					::AtualizaCustoFuturo("1",::cPro_VEIA)
				EndIf
			Elseif cId == "VFM_TIPOPE"
				If !Empty(xValue)
					If !::PosicionaVV1SB1(FWFldGet("VFM_CHAINT"),FWFldGet("VFM_CODMAR"),FWFldGet("VFM_MODVEI"),FWFldGet("VFM_SEGMOD"))
						Help("",1,"FIELDPREVLD "+cId,,STR0086,1,0) // TES Inteligente - Produto não encontrado.
						lRet := .f.
					EndIf
					If lRet
						cTESInt := MaTesInt(2,xValue,::aCli_VEIA[1],::aCli_VEIA[2],"C",SB1->B1_COD,,::aCli_VEIA[4])
						If !Empty(cTESInt)
							oSubModel:LoadValue( "VFM_CODTES", cTESInt)
							oSubModel:LoadValue( "VFM_TIPOPE", "")
						EndIf
					EndIf
				EndIf
			EndIf
			//Preenchimento automático dos campos que estão nas demais linhas do grid
			If cId $ "VFM_TIPOPE/VFM_CODTES/VFM_CENCUS/VFM_CONTA/VFM_CLVL/VFM_ITEMCT/"
				::ReplicaDadosLinha(oSubModel,cId,xValue,"VFM","")
			EndIf
		Elseif cAction == "UNDELETE"
			cNroVeic := FWFldGet("VFM_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFM_CUSUNI")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
			EndIf
		Elseif cAction == "DELETE"
			cNroVeic := FWFldGet("VFM_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFM_CUSUNI")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
			EndIf
		EndIf
	Case cModelID == "VFPDETAIL" // AMS - Entrada
		If cAction == "CANSETVALUE" 
			If cId $ "VFP_MODVEI/VFP_SEGMOD/VFP_CORVEI/" 
				cMarVeiF3 :=  FWFldGet("VFP_CODMAR") // Variavel utilizada no F3 de Modelo VV2 -> SXB: 'MCF'
			EndIf
			If cId $ "VFP_CODMAR/VFP_MODVEI/VFP_SEGMOD/VFP_CORVEI/" 
				If !Empty(FWFldGet("VFP_CHAINT"))
					lRet := .f.
				EndIf
			EndIf
		Elseif cAction == "SETVALUE"
			If cId == "VFP_CHASSI"
				oSubModel:LoadValue("VFP_CHAINT", "")
				oSubModel:LoadValue("VFP_CODMAR", "")
				oSubModel:LoadValue("VFP_MODVEI", "")
				oSubModel:LoadValue("VFP_SEGMOD", "")
				oSubModel:LoadValue("VFP_CORVEI", "")
				oSubModel:LoadValue("VFP_CUSUNI", 0 )
				oSubModel:LoadValue("VFP_CODORI", "")
				oSubModel:LoadValue("VFP_GRTRIB", "")
				oSubModel:LoadValue("VFP_POSIPI", "")
				oSubModel:LoadValue("VFP_PROVEI", "")
				oSubModel:LoadValue("VFP_CENCUS", "")
				oSubModel:LoadValue("VFP_CONTA" , "")
				oSubModel:LoadValue("VFP_ITEMCT", "")
				oSubModel:LoadValue("VFP_CLVL"  , "")
				oSubModel:LoadValue("VFP_LOCPAD", "")
				If !Empty(xValue)
					DbSelectArea("VV1")
					DbSetOrder(2) // CHASSI
					If DbSeek(xFilial("VV1") + xValue)
						aQUltMov := FM_VEIUMOV( xValue , , )
						If ( (VV1->VV1_GRASEV <> "6" .and. len(aQUltMov) > 0) .or. ;// Veiculo (Não AMS) com movimentação
							( VV1->VV1_GRASEV == "6" .and. VV1->VV1_SITVEI == '0') ) // AMS em Estoque
							Help("",1,"FIELDPREVLD "+cId,,STR0087,1,0) // Chassi possui movimentações.
							lRet := .f.
						Else
							MsgInfo(STR0088,STR0025) // Chassi já cadastrado, os dados serão carregados. / Atenção
							oSubModel:LoadValue("VFP_CHAINT", VV1->VV1_CHAINT)
							oSubModel:LoadValue("VFP_CODMAR", VV1->VV1_CODMAR)
							oSubModel:LoadValue("VFP_MODVEI", VV1->VV1_MODVEI)
							oSubModel:LoadValue("VFP_SEGMOD", VV1->VV1_SEGMOD)
							oSubModel:LoadValue("VFP_CORVEI", VV1->VV1_CORVEI)
							oSubModel:LoadValue("VFP_CODORI", VV1->VV1_CODORI)
							oSubModel:LoadValue("VFP_GRTRIB", VV1->VV1_GRTRIB)
							oSubModel:LoadValue("VFP_POSIPI", left(VV1->VV1_POSIPI,GetSX3Cache("VFP_POSIPI","X3_TAMANHO")))
							oSubModel:LoadValue("VFP_PROVEI", VV1->VV1_PROVEI)
							If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT, /* cMVMIL0010 */ , cGruVei )
								oSubModel:LoadValue("VFP_CENCUS", SB1->B1_CC)
								oSubModel:LoadValue("VFP_CONTA" , SB1->B1_CONTA)
								oSubModel:LoadValue("VFP_ITEMCT", SB1->B1_ITEMCC)
								oSubModel:LoadValue("VFP_CLVL"  , SB1->B1_CLVL)
								oSubModel:LoadValue("VFP_LOCPAD", SB1->B1_LOCPAD)
								If ::PosicionaSB2()
									oSubModel:LoadValue("VFP_CUSUNI", round(SB2->B2_CM1,2))
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
					::AtualizaCustoFuturo("1",::cPro_VEIA)
				EndIf
			Elseif cId == "VFP_CODMAR"
				If xValue != xCurrentValue
					oSubModel:LoadValue("VFP_MODVEI", "")
					oSubModel:LoadValue("VFP_SEGMOD", "")
					oSubModel:LoadValue("VFP_CORVEI", "")
					oSubModel:LoadValue("VFP_CENCUS", "")
					oSubModel:LoadValue("VFP_CONTA" , "")
					oSubModel:LoadValue("VFP_ITEMCT", "")
					oSubModel:LoadValue("VFP_CLVL"  , "")
					oSubModel:LoadValue("VFP_LOCPAD", "")
					oSubModel:LoadValue("VFP_CUSUNI", 0 )
					If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
						::AtualizaCustoFuturo("1",::cPro_VEIA)
					EndIf
				EndIf
			Elseif cId == "VFP_MODVEI"
				If xValue != xCurrentValue
					oSubModel:LoadValue("VFP_CENCUS", "")
					oSubModel:LoadValue("VFP_CONTA" , "")
					oSubModel:LoadValue("VFP_ITEMCT", "")
					oSubModel:LoadValue("VFP_CLVL"  , "")
					oSubModel:LoadValue("VFP_LOCPAD", "")
					oSubModel:LoadValue("VFP_CUSUNI", 0 )
					DBSelectArea("VV2")
					DBSetOrder(1)
					If DBSeek(xFilial("VV2")+FWFldGet("VFP_CODMAR")+xValue)
						DBSelectArea("SB1")
						DBSetOrder(1)
						If DbSeek( xFilial("SB1") + VV2->VV2_PRODUT)
							oSubModel:LoadValue("VFP_CENCUS", SB1->B1_CC)
							oSubModel:LoadValue("VFP_CONTA" , SB1->B1_CONTA)
							oSubModel:LoadValue("VFP_ITEMCT", SB1->B1_ITEMCC)
							oSubModel:LoadValue("VFP_CLVL"  , SB1->B1_CLVL)
							oSubModel:LoadValue("VFP_LOCPAD", SB1->B1_LOCPAD)
							oSubModel:LoadValue("VFP_GRTRIB", SB1->B1_GRTRIB)
							oSubModel:LoadValue("VFP_POSIPI", left(SB1->B1_POSIPI,GetSX3Cache("VFP_POSIPI","X3_TAMANHO")))
							oSubModel:LoadValue("VFP_PROVEI", SB1->B1_ORIGEM)
							If ::PosicionaSB2()
								oSubModel:LoadValue("VFP_CUSUNI", round(SB2->B2_CM1,2))
							EndIf
						EndIf
					EndIf
					If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
						::AtualizaCustoFuturo("1",::cPro_VEIA)
					EndIf
				EndIf
			Elseif cId == "VFP_SEGMOD"
				If !Empty(xValue)
					DbSelectArea("VVX")
					DbSetOrder(1)
					If !DbSeek(xFilial("VVX")+FWFldGet("VFP_CODMAR")+xValue)
						Help("",1,"FIELDPREVLD "+cId,,STR0089,1,0) // Segmento do modelo não encontrado.
						lRet := .f.
					Else
						DbSelectArea("VV2")
						DbSetOrder(1)
						If !DbSeek(xFilial("VV2")+FWFldGet("VFP_CODMAR")+FWFldGet("VFP_MODVEI")+xValue)
							Help("",1,"FIELDPREVLD "+cId,,STR0090,1,0) // Segmento não relacionado ao modelo informado.
							lRet := .f.
						Else
							DBSelectArea("SB1")
							DBSetOrder(1)
							If DbSeek( xFilial("SB1") + VV2->VV2_PRODUT)
								oSubModel:LoadValue("VFP_CENCUS", SB1->B1_CC)
								oSubModel:LoadValue("VFP_CONTA" , SB1->B1_CONTA)
								oSubModel:LoadValue("VFP_ITEMCT", SB1->B1_ITEMCC)
								oSubModel:LoadValue("VFP_CLVL"  , SB1->B1_CLVL)
								oSubModel:LoadValue("VFP_LOCPAD", SB1->B1_LOCPAD)
								If ::PosicionaSB2()
									oSubModel:LoadValue("VFP_CUSUNI", round(SB2->B2_CM1,2))
									If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
										::AtualizaCustoFuturo("1",::cPro_VEIA)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					DbSelectArea("VV2")
					DbSetOrder(1)
					If !DbSeek(xFilial("VV2")+FWFldGet("VFP_CODMAR")+FWFldGet("VFP_MODVEI")+" ")
						Help("",1,"FIELDPREVLD "+cId,,STR0091,1,0) // Modelo não encontrado sem segmento.
						lRet := .f.
					EndIf	
				EndIf	
			Elseif cId == "VFP_TIPOPE"
				If !Empty(xValue)
					If Empty(FWFldGet("VFP_CHAINT")) // Desagrega sem Chaint
						DBSelectArea("VV2")
						DBSetOrder(1)
						If DbSeek(xFilial("VV2")+FWFldGet("VFP_CODMAR")+FWFldGet("VFP_MODVEI"))
							DBSelectArea("SB1")
							DbSetOrder(1)
							If !DbSeek( xFilial("SB1") + VV2->VV2_PRODUT )
								Help("",1,"FIELDPREVLD "+cId,,STR0086,1,0) // TES Inteligente - Produto não encontrado.
								lRet := .f.
							EndIf
						EndIf
					Else  //Desagrega com Chaint
						If !::PosicionaVV1SB1(FWFldGet("VFP_CHAINT"),FWFldGet("VFP_CODMAR"),FWFldGet("VFP_MODVEI"),FWFldGet("VFP_SEGMOD"))
							Help("",1,"FIELDPREVLD "+cId,,STR0086,1,0) // TES Inteligente - Produto não encontrado.
							lRet := .f.
						EndIf
					EndIf
					If lRet
						cTESInt := MaTesInt(1,xValue,::aFor_VEIA[1],::aFor_VEIA[2],"F",SB1->B1_COD,,::aFor_VEIA[4])
						If !Empty(cTESInt)
							oSubModel:LoadValue( "VFP_CODTES", cTESInt)
							oSubModel:LoadValue( "VFP_TIPOPE", "")
						EndIf
					EndIf
				EndIf
			ElseIf cId == "VFP_CUSUNI"
				cNroVeic := FWFldGet("VFP_VEIMAQ")
				If !Empty(cNroVeic)
					oModel  := FWModelActive()
					nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
					nCusFut += xCurrentValue // Soma o Valor que estava na linha do AMS
					nCusFut -= xValue // Subtrai o Valor novo da linha do AMS
					oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut )
					oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut )
					If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
						cNroVeic := IIf(cNroVeic=="1","2","1")
						nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
						nCusFut -= xCurrentValue // Subtrai o Valor que estava na linha do AMS
						nCusFut += xValue // Soma o Valor novo da linha do AMS
						oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut )
						oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut )
					EndIf
				EndIf
			ElseIf cId == "VFP_VEIMAQ"
				If ::cPro_VEIA == "4" // 4 = Troca
					oSubModel:LoadValue( "EVENTO" , IIf(xValue=="1","gr_blue01","gr_blue03") ) // Legenda - Sequencial dos Eventos
				EndIf
				oModel  := FWModelActive()
				oModVFM := oModel:GetModel("VFMDETAIL")
				If nLine <= oModVFM:Length()
					oModVFM:GoLine(nLine)
					oModVFM:LoadValue( "VFM_VEIMAQ" , IIf(xValue=="1","2","1") )
					If ::cPro_VEIA == "4" // 4 = Troca
						oModVFM:LoadValue( "EVENTO" , IIf(xValue=="1","gr_blue02","gr_blue04") ) // Legenda - Sequencial dos Eventos
					EndIf
				EndIf
			EndIf
			If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				If cId $ "VFP_CHAINT/VFP_CHASSI/VFP_CODMAR/VFP_MODVEI/VFP_SEGMOD/VFP_CORVEI/VFP_CUSUNI/" // Replicar campos entre abas "De" e "Para"
					If Empty(oSubModel:GetValue("VFP_VEIMAQ"))
						oSubModel:LoadValue("VFP_VEIMAQ","1") // Default: 1 - Veiculo / Maquina 1
					EndIf
					oModel  := FWModelActive()
					oModVFM := oModel:GetModel("VFMDETAIL")
					oModVFM:SetNoInsertLine(.f.)
					If nLine > oModVFM:Length()
						oModVFM:AddLine()
					EndIf
					oModVFM:GoLine(nLine)
					If ::cPro_VEIA == "3" // 3 = Transferencia
						oModVFM:LoadValue( "EVENTO" , "gr_blue02" ) // Sequencial 2 dos Eventos
					ElseIf ::cPro_VEIA == "4" // 4 = Troca
						oModVFM:LoadValue( "EVENTO" , IIf(oSubModel:GetValue("VFP_VEIMAQ")=="1","gr_blue02","gr_blue04") ) // Legenda - Sequencial dos Eventos
					EndIf
					oModVFM:LoadValue( "VFM_VEIMAQ" , IIf(oSubModel:GetValue("VFP_VEIMAQ")=="1","2","1") )
					oModVFM:LoadValue( "VFM_CHAINT" , IIf(lRet,IIf(cId=="VFP_CHAINT",xValue,oSubModel:GetValue("VFP_CHAINT")),"") )
					oModVFM:LoadValue( "VFM_CHASSI" , IIf(lRet,IIf(cId=="VFP_CHASSI",xValue,oSubModel:GetValue("VFP_CHASSI")),"") )
					oModVFM:LoadValue( "VFM_CODMAR" , IIf(lRet,IIf(cId=="VFP_CODMAR",xValue,oSubModel:GetValue("VFP_CODMAR")),"") )
					oModVFM:LoadValue( "VFM_MODVEI" , IIf(lRet,IIf(cId=="VFP_MODVEI",xValue,oSubModel:GetValue("VFP_MODVEI")),"") )
					oModVFM:LoadValue( "VFM_SEGMOD" , IIf(lRet,IIf(cId=="VFP_SEGMOD",xValue,oSubModel:GetValue("VFP_SEGMOD")),"") )
					oModVFM:LoadValue( "VFM_CORVEI" , IIf(lRet,IIf(cId=="VFP_CORVEI",xValue,oSubModel:GetValue("VFP_CORVEI")),"") )
					oModVFM:LoadValue( "VFM_CUSUNI" , IIf(lRet,IIf(cId=="VFP_CUSUNI",xValue,oSubModel:GetValue("VFP_CUSUNI")), 0) )
					oModVFM:SetNoInsertLine(.t.)
					oModVFM:GoLine(1)
					oView := FWViewActive()
					oView:Refresh("VIEW_VFM")
					If ::cPro_VEIA == "3" // 3 = Transferencia
						If cId <> "VFP_CUSUNI"
							::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
						EndIf
						::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
					EndIf
				EndIf
			EndIf
			//Preenchimento automático dos campos que estão nas demais linhas do grid
			If cId $ "VFP_TIPOPE/VFP_CODTES/VFP_LOCPAD/VFP_CODORI/VFP_GRTRIB/VFP_POSIPI/VFP_PROVEI/VFP_CENCUS/VFP_CONTA/VFP_CLVL/VFP_ITEMCT/"
				::ReplicaDadosLinha(oSubModel,cId,xValue,"VFP","")
			EndIf
		Elseif cAction == "UNDELETE"
			cNroVeic := FWFldGet("VFP_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFP_CUSUNI")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
				If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
					oModVFM := oModel:GetModel("VFMDETAIL")
					oModVFM:SetNoDeleteLine(.f.)
					oModVFM:GoLine(nLine)
					oModVFM:UnDeleteLine()
					oModVFM:SetNoDeleteLine(.t.)
				EndIf
			EndIf
		Elseif cAction == "DELETE"
			cNroVeic := FWFldGet("VFP_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFP_CUSUNI")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
				If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
					oModVFM := oModel:GetModel("VFMDETAIL")
					If oModVFM:Length() >= nLine
						oModVFM:SetNoDeleteLine(.f.)
						oModVFM:GoLine(nLine)
						oModVFM:DeleteLine()
						oModVFM:SetNoDeleteLine(.t.)
					EndIf
				EndIf
			EndIf
		EndIf
	Case cModelID == "VFNDETAIL" // Peças - Saida
		If cAction == "CANSETVALUE"
			If cId == "VFN_CODITE"
				cGrupoA := FWFldGet("VFN_GRUITE") // Variavel utilizada no F3 do Produto SB1 -> SXB: 'B23'
			EndIf
		ElseIf cAction == "SETVALUE"
			If cId == "VFN_CODSB1"
				If !Empty(xValue)
					DBSelectArea("SB1")
					DBSetOrder(1)
					DBSeek(xFilial("SB1")+xValue)
					oPeca := DMS_Peca():New()
					If oPeca:Bloqueado(xValue,,,.F.) // Já faz o posicionamento na tabela SB1
						Help("",1,"FIELDPREVLD "+cId,,STR0072+xValue,1,0) // Produto bloqueado.
						lRet := .f.
					Else
						If ::PosicionaSB2()
							oSubModel:LoadValue("VFN_CUSUNI", round(SB2->B2_CM1,2)) // Custo unitário 
							oSubModel:LoadValue("VFN_QUANT" , 1) // Quantidade
							oSubModel:LoadValue("VFN_CUSTOT", FWFldGet("VFN_CUSUNI")*FWFldGet("VFN_QUANT")) // Custo Total
							If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
								::AtualizaCustoFuturo("1",::cPro_VEIA)
							ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
								::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
								::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
							ElseIf ::cPro_VEIA == "4" // 4 = Troca
								nCusAtu := ::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
								::AtualizaCustoFuturo("1","1",nCusAtu) // ChaInt 1 - Agregar
								nCusAtu := ::AtualizaCustoFuturo("2","2") // ChaInt 2 - Desagregar
								::AtualizaCustoFuturo("2","1",nCusAtu) // ChaInt 2 - Agregar
							EndIf
						EndIf
					EndIf
				EndIf
			Elseif cId == "VFN_PESQB1"
				If !Empty(xValue)
					cCodIte := xValue
					cGruIte := FwFldGet("VFN_GRUITE")
					If !FG_POSSB1("cCodIte","SB1->B1_CODITE","cGruIte")
						Help("",1,"FIELDPREVLD "+cId,,STR0092+":"+CHR(13)+CHR(10)+xValue,1,0) // Item não encontrado.
						lRet := .f.
					Else
						oSubModel:LoadValue("VFN_GRUITE", SB1->B1_GRUPO)
						oSubModel:SetValue("VFN_CODITE", SB1->B1_CODITE) // Utilizado o SetValue pois é necessários disparar o gatilho para preenchimento do campo VFN_CODSB1
					EndIf
				Endif
			Elseif cId $ "VFN_GRUITE/VFN_CODITE/"
				oSubModel:LoadValue("VFN_CUSUNI", 0) // Custo unitário 
				oSubModel:LoadValue("VFN_QUANT" , 1) // Quantidade
				oSubModel:LoadValue("VFN_CUSTOT", 0) // Custo Total
				If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
					::AtualizaCustoFuturo("1",::cPro_VEIA)
				ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
					::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
					::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
				ElseIf ::cPro_VEIA == "4" // 4 = Troca
					nCusAtu := ::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
					::AtualizaCustoFuturo("1","1",nCusAtu) // ChaInt 1 - Agregar
					nCusAtu := ::AtualizaCustoFuturo("2","2") // ChaInt 2 - Desagregar
					::AtualizaCustoFuturo("2","1",nCusAtu) // ChaInt 2 - Agregar
				EndIf
				If cId == "VFN_GRUITE"
					If !Empty(xValue)
						DBSelectArea("SBM")
						DBSetOrder(1)
						If !DBSeek(xFilial("SBM")+xValue) .or. SBM->BM_TIPGRU $ "4 /7 /12/"
							Help("",1,"FIELDPREVLD "+cId,,STR0093+CHR(13)+CHR(10)+xValue,1,0) // Grupo não encontrado ou não cadastrado como peças.
							lRet := .f.
						EndIf
					Else	
						oSubModel:LoadValue("VFN_DESITE", "")
					EndIf		
				EndIf
			Elseif cId == "VFN_TIPOPE"
				If !Empty(xValue)
					If !Empty(FWFldGet("VFN_CODSB1"))
						cTESInt := MaTesInt(2,xValue,::aCli_VEIA[1],::aCli_VEIA[2],"C",FWFldGet("VFN_CODSB1"),,::aCli_VEIA[4])
						If !Empty(cTESInt)
							oSubModel:LoadValue( "VFN_CODTES", cTESInt)
							oSubModel:LoadValue( "VFN_TIPOPE", "")
						EndIf
					EndIf
				EndIf
			Elseif cId == "VFN_QUANT"
				If !Empty(xValue)
					oSubModel:LoadValue("VFN_CUSTOT", FWFldGet("VFN_CUSUNI")*xValue)
					If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
						::AtualizaCustoFuturo("1",::cPro_VEIA)
					EndIf
				EndIf
			EndIf
			//Preenchimento automático dos campos que estão nas demais linhas do grid
			If cId $ "VFN_TIPOPE/VFN_CODTES/VFN_CENCUS/VFN_CONTA/VFN_CLVL/VFN_ITEMCT/"
				::ReplicaDadosLinha(oSubModel,cId,xValue,"VFN","")
			EndIf
		Elseif cAction == "UNDELETE"
			cNroVeic := FWFldGet("VFN_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFN_CUSTOT")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
			EndIf
		Elseif cAction == "DELETE"
			cNroVeic := FWFldGet("VFN_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFN_CUSTOT")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
			EndIf
		EndIf
	Case cModelID == "VFQDETAIL" // Peças - Entrada
		If cAction == "CANSETVALUE"
			If cId == "VFQ_CODITE"
				cGrupoA := FWFldGet("VFQ_GRUITE") // Variavel utilizada no F3 do Produto SB1 -> SXB: 'B23'
			EndIf
		Elseif cAction == "SETVALUE"
			If cId == "VFQ_CODSB1"
				If !Empty(xValue)
					DBSelectArea("SB1")
					DBSetOrder(1)
					DBSeek(xFilial("SB1")+xValue)
					oPeca := DMS_Peca():New()
					If oPeca:Bloqueado(xValue,,,.F.) // Já faz o posicionamento na tabela SB1
						Help("",1,"FIELDPREVLD "+cId,,STR0072+xValue,1,0) // Produto bloqueado.
						lRet := .f.
					Else
						If ::PosicionaSB2()
							oSubModel:LoadValue("VFQ_CUSUNI", round(SB2->B2_CM1,2)) // Custo unitário 
							oSubModel:LoadValue("VFQ_QUANT" , 1) // Quantidade
							oSubModel:LoadValue("VFQ_CUSTOT", FWFldGet("VFQ_CUSUNI")*FWFldGet("VFQ_QUANT")) // Custo Total
							If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
								::AtualizaCustoFuturo("1",::cPro_VEIA)
							ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
								::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
								::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
							ElseIf ::cPro_VEIA == "4" // 4 = Troca
								nCusAtu := ::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
								::AtualizaCustoFuturo("1","1",nCusAtu) // ChaInt 1 - Agregar
								nCusAtu := ::AtualizaCustoFuturo("2","2") // ChaInt 2 - Desagregar
								::AtualizaCustoFuturo("2","1",nCusAtu) // ChaInt 2 - Agregar
							EndIf
						EndIf
					EndIf
				EndIf
			Elseif cId == "VFQ_PESQB1"
				If !Empty(xValue)
					cCodIte := xValue
					cGruIte := FwFldGet("VFQ_GRUITE")
					If !FG_POSSB1("cCodIte","SB1->B1_CODITE","cGruIte")
						Help("",1,"FIELDPREVLD "+cId,,STR0092+":"+CHR(13)+CHR(10)+xValue,1,0) // Item não encontrado.
						lRet := .f.
					Else
						oSubModel:LoadValue("VFQ_GRUITE", SB1->B1_GRUPO)
						oSubModel:SetValue("VFQ_CODITE", SB1->B1_CODITE) // Utilizado o SetValue pois é necessários disparar o gatilho para preenchimento do campo VFQ_CODSB1
					EndIf
				Endif
			Elseif cId $ "VFQ_GRUITE/VFQ_CODITE/"
				oSubModel:LoadValue("VFQ_CUSUNI", 0) // Custo unitário 
				oSubModel:LoadValue("VFQ_QUANT" , 1) // Quantidade
				oSubModel:LoadValue("VFQ_CUSTOT", 0) // Custo Total
				If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
					::AtualizaCustoFuturo("1",::cPro_VEIA)
				ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
					::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
					::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
				ElseIf ::cPro_VEIA == "4" // 4 = Troca
					nCusAtu := ::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
					::AtualizaCustoFuturo("1","1",nCusAtu) // ChaInt 1 - Agregar
					nCusAtu := ::AtualizaCustoFuturo("2","2") // ChaInt 2 - Desagregar
					::AtualizaCustoFuturo("2","1",nCusAtu) // ChaInt 2 - Agregar
				EndIf
				If cId == "VFQ_GRUITE"
					If !Empty(xValue)
						DBSelectArea("SBM")
						DBSetOrder(1)
						If !DBSeek(xFilial("SBM")+xValue) .or. SBM->BM_TIPGRU $ "4 /7 /12/"
							Help("",1,"FIELDPREVLD "+cId,,STR0093+CHR(13)+CHR(10)+xValue,1,0) // Grupo não encontrado ou não cadastrado como peças.
							lRet := .f.
						EndIf
					Else	
						oSubModel:LoadValue("VFQ_DESITE", "")		
					EndIf		
				EndIf
			Elseif cId == "VFQ_TIPOPE"
				If !Empty(xValue)
					If !Empty(FWFldGet("VFQ_CODSB1"))
						cTESInt := MaTesInt(1,xValue,::aFor_VEIA[1],::aFor_VEIA[2],"F",FWFldGet("VFQ_CODSB1"),,::aFor_VEIA[4])
						If !Empty(cTESInt)
							oSubModel:LoadValue( "VFQ_CODTES", cTESInt)
							oSubModel:LoadValue( "VFQ_TIPOPE", "")
						EndIf
					EndIf
				EndIf
			Elseif cId == "VFQ_QUANT"
				If !Empty(xValue)
					oSubModel:LoadValue("VFQ_CUSTOT", FWFldGet("VFQ_CUSUNI")*xValue)
					If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
						::AtualizaCustoFuturo("1",::cPro_VEIA)
					ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
						::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
						::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
					ElseIf ::cPro_VEIA == "4" // 4 = Troca
						oModel  := FWModelActive()
						oModVFN := oModel:GetModel("VFNDETAIL")
						If nLine <= oModVFN:Length()
							oModVFN:GoLine(nLine)
							oModVFN:LoadValue("VFN_QUANT" , xValue )
							oModVFN:LoadValue("VFN_CUSTOT", FWFldGet("VFN_CUSUNI")*xValue)
							nCusAtu := ::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
							::AtualizaCustoFuturo("1","1",nCusAtu) // ChaInt 1 - Agregar
							nCusAtu := ::AtualizaCustoFuturo("2","2") // ChaInt 2 - Desagregar
							::AtualizaCustoFuturo("2","1",nCusAtu) // ChaInt 2 - Agregar
						EndIf
					EndIf
				EndIf//
			Elseif cId == "VFQ_CUSUNI"
				If !Empty(xValue)
					oSubModel:LoadValue("VFQ_CUSTOT", FWFldGet("VFQ_QUANT")*xValue)
					If ::cPro_VEIA $ "1/2" // 1 = Agrega Individual / 2 = Desagrega Indivudual
						::AtualizaCustoFuturo("1",::cPro_VEIA)
					ElseIf ::cPro_VEIA == "3" // 3 = Transferencia
						::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
						::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
					ElseIf ::cPro_VEIA == "4" // 4 = Troca
						oModel  := FWModelActive()
						oModVFN := oModel:GetModel("VFNDETAIL")
						If nLine <= oModVFN:Length()
							oModVFN:GoLine(nLine)
							oModVFN:LoadValue("VFN_CUSUNI" , xValue )
							oModVFN:LoadValue("VFN_CUSTOT", FWFldGet("VFN_QUANT")*xValue)
							nCusAtu := ::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
							::AtualizaCustoFuturo("1","1",nCusAtu) // ChaInt 1 - Agregar
							nCusAtu := ::AtualizaCustoFuturo("2","2") // ChaInt 2 - Desagregar
							::AtualizaCustoFuturo("2","1",nCusAtu) // ChaInt 2 - Agregar
						EndIf
					EndIf
				EndIf
			ElseIf cId == "VFQ_VEIMAQ"
				If ::cPro_VEIA == "4" // 4 = Troca
					oSubModel:LoadValue( "EVENTO" , IIf(xValue=="1","gr_blue01","gr_blue03") ) // Legenda - Sequencial dos Eventos
				EndIf
				oModel  := FWModelActive()
				oModVFN := oModel:GetModel("VFNDETAIL")
				If nLine <= oModVFN:Length()
					oModVFN:GoLine(nLine)
					oModVFN:LoadValue( "VFN_VEIMAQ" , IIf(xValue=="1","2","1") )
					If ::cPro_VEIA == "4" // 4 = Troca
						oModVFN:LoadValue( "EVENTO" , IIf(xValue=="1","gr_blue02","gr_blue04") ) // Legenda - Sequencial dos Eventos
					EndIf
				EndIf
			EndIf
			If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
				If cId $ "VFQ_CODSB1/VFQ_GRUITE/VFQ_CODITE/VFQ_QUANT/" // Replicar campos entre abas "De" e "Para"
					If Empty(oSubModel:GetValue("VFQ_VEIMAQ"))
						oSubModel:LoadValue("VFQ_VEIMAQ","1") // Default: 1 - Veiculo / Maquina 1
					EndIf
					oModel  := FWModelActive()
					oModVFN := oModel:GetModel("VFNDETAIL")
					oModVFN:SetNoInsertLine(.f.)
					If nLine > oModVFN:Length()
						oModVFN:AddLine()
					EndIf
					oModVFN:GoLine(nLine)
					If ::cPro_VEIA == "3" // 3 = Transferencia
						oModVFN:LoadValue( "EVENTO" , "gr_blue02" ) // Sequencial 2 dos Eventos
					ElseIf ::cPro_VEIA == "4" // 4 = Troca
						oModVFN:LoadValue( "EVENTO" , IIf(oSubModel:GetValue("VFQ_VEIMAQ")=="1","gr_blue02","gr_blue04") ) // Legenda - Sequencial dos Eventos
					EndIf
					oModVFN:LoadValue( "VFN_VEIMAQ" , IIf(oSubModel:GetValue("VFQ_VEIMAQ")=="1","2","1") )
					If cId == "VFQ_CODSB1"
						oModVFN:SetValue( "VFN_CODSB1" , xValue ) // SetValue para disparar Gatilhos (Grupo/CodIte/Descrição)
					Else
						oModVFN:LoadValue( "VFN_GRUITE" , IIf(lRet,IIf(cId=="VFQ_GRUITE",xValue,oSubModel:GetValue("VFQ_GRUITE")),"") )
						oModVFN:LoadValue( "VFN_CODITE" , IIf(lRet,IIf(cId=="VFQ_CODITE",xValue,oSubModel:GetValue("VFQ_CODITE")),"") )
						oModVFN:LoadValue( "VFN_DESITE" , IIf(lRet,IIf(cId=="VFQ_DESITE",xValue,oSubModel:GetValue("VFQ_DESITE")),"") )
						If cId $ "VFQ_GRUITE/VFQ_CODITE" .and. Empty(xValue)
							oModVFN:LoadValue( "VFN_CODITE" , "" )
							oModVFN:LoadValue( "VFN_DESITE" , "" )
						EndIf
						If cId == "VFQ_CODITE" .and. !Empty(xValue)
							SB1->(DbSetOrder(7))
							SB1->(DbSeek(xFilial("SB1")+oSubModel:GetValue("VFQ_GRUITE")+xValue))
							oModVFN:LoadValue( "VFN_DESITE" , SB1->B1_DESC )
							oModVFN:SetValue( "VFN_CODTES" , SB1->B1_TS )
						EndIf
					EndIf
					oModVFN:LoadValue( "VFN_CUSUNI" , IIf(lRet,IIf(cId=="VFQ_CUSUNI",xValue,oSubModel:GetValue("VFQ_CUSUNI")), 0) )
					oModVFN:LoadValue( "VFN_QUANT"  , IIf(lRet,IIf(cId=="VFQ_QUANT" ,xValue,oSubModel:GetValue("VFQ_QUANT")) , 0) )
					oModVFN:LoadValue( "VFN_CUSTOT" , IIf(lRet,IIf(cId=="VFQ_CUSTOT",xValue,oSubModel:GetValue("VFQ_CUSTOT")), 0) )
					oModVFN:SetNoInsertLine(.t.)
					oModVFN:GoLine(1)
					oView := FWViewActive()
					oView:Refresh("VIEW_VFN")
					If ::cPro_VEIA == "3" // 3 = Transferencia
						If cId <> "VFQ_CUSUNI"
							::AtualizaCustoFuturo("1","2") // ChaInt 1 - Desagregar
						EndIf
						::AtualizaCustoFuturo("2","1") // ChaInt 2 - Agregar
					EndIf
				EndIf
			EndIf
			//Preenchimento automático dos campos que estão nas demais linhas do grid
			If cId $ "VFQ_TIPOPE/VFQ_CODTES/VFQ_CENCUS/VFQ_CONTA/VFQ_CLVL/VFQ_ITEMCT/"
				::ReplicaDadosLinha(oSubModel,cId,xValue,"VFQ","")
			EndIf
		Elseif cAction == "UNDELETE"
			cNroVeic := FWFldGet("VFQ_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFQ_CUSTOT")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut-nVlrAux ) // Custo Futuro (Subtrai)
				If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
					oModVFN := oModel:GetModel("VFNDETAIL")
					oModVFN:SetNoDeleteLine(.f.)
					oModVFN:GoLine(nLine)
					oModVFN:UnDeleteLine()
					oModVFN:SetNoDeleteLine(.t.)
				EndIf
			EndIf
		Elseif cAction == "DELETE"
			cNroVeic := FWFldGet("VFQ_VEIMAQ")
			If !Empty(cNroVeic)
				nVlrAux := FWFldGet("VFQ_CUSTOT")
				oModel  := FWModelActive()
				nCusFut := oModel:GetValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic )
				oModel:LoadValue( "VFJMASTER" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
				oModel:LoadValue( "VFJTOTAIS" , "VFJ_CUSFT"+cNroVeic , nCusFut+nVlrAux ) // Custo Futuro (Soma)
				If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca	
					oModVFN := oModel:GetModel("VFNDETAIL")
					If oModVFN:Length() >= nLine
						oModVFN:SetNoDeleteLine(.f.)
						oModVFN:GoLine(nLine)
						oModVFN:DeleteLine()
						oModVFN:SetNoDeleteLine(.t.)
					EndIf
				EndIf
			EndIf
		EndIf
	Case cModelID == "VFKDETAIL" // NF Saida
		If cAction == "CANSETVALUE" 
			If cId $ "VFK_TIPOPE/VFK_CODTES/VFK_CENCUS/VFK_CONTA/VFK_ITEMCT/VFK_CLVL/" // Nao deixa alterar campos na aba de NF que serão digitados na ABA de Peças
				If FWFldGet("VFK_TIPREG") $ "/2/4/"	
					lRet := .f.
				EndIf
			EndIf
		Elseif cAction == "SETVALUE"
			If cId == "VFK_TIPOPE"
				If !Empty(xValue)
					If ::PosicionaVV1SB1(::cVV1001)
						cTESInt := MaTesInt(2,xValue,::aCli_VEIA[1],::aCli_VEIA[2],"C",SB1->B1_COD,,::aCli_VEIA[4])
						If !Empty(cTESInt)
							oSubModel:LoadValue( "VFK_CODTES", cTESInt)
							oSubModel:LoadValue( "VFK_TIPOPE", "")
						EndIf
					Else	
						Help("",1,"FIELDPREVLD "+cId,,STR0086,1,0) // TES Inteligente - Produto não encontrado.
						lRet := .f.
					EndIf
				EndIf
			EndIf
			//Preenchimento automático dos campos que estão nas demais linhas do grid
			If ::cPro_VEIA == "1" .and. ::cIte_VEIA == "2" //Somente Agrega/Peças
				If cId $ "VFK_CODESP/VFK_CODVEN/VFK_FORPAG/VFK_NATURE/VFK_CODBCO/VFK_CENCUS/VFK_CONTA/VFK_CLVL/VFK_PRECPA/VFK_ITEMCT/"
					::ReplicaDadosLinha(oSubModel,cId,xValue,"VFK","")
				EndIf
			ElseIf ::cPro_VEIA $ "3/4" // 3 = Transferência / 4 = Troca
				If cId $ "VFK_TIPOPE/VFK_CODTES/" 
					::ReplicaDadosLinha(oSubModel,cId,xValue,"VFK","1/3")
				ElseIf cId $ "VFK_CODESP/VFK_CODVEN/VFK_FORPAG/VFK_NATURE/VFK_CODBCO/VFK_CENCUS/VFK_CONTA/VFK_CLVL/VFK_PRECPA/VFK_ITEMCT/"
					::ReplicaDadosLinha(oSubModel,cId,xValue,"VFK","")
				EndIf
			EndIf
		EndIf
	Case cModelID == "VFLDETAIL" // NF Entrada
		If cAction == "CANSETVALUE" 
			If cId $ "VFL_TIPOPE/VFL_CODTES/VFL_CENCUS/VFL_CONTA/VFL_ITEMCT/VFL_CLVL/" // Nao deixa alterar o TES na aba de NF, sera apenas digitado na ABA de Peças
				If FWFldGet("VFL_TIPREG") $ "/2/4/"
					lRet := .f.
				EndIf
			EndIf
		ElseIf cAction == "SETVALUE"
			If cId == "VFL_TIPOPE"
				If !Empty(xValue)
					If ::PosicionaVV1SB1(::cVV1001)
						cTESInt := MaTesInt(1,xValue,::aFor_VEIA[1],::aFor_VEIA[2],"F",SB1->B1_COD,,::aFor_VEIA[4])
						If !Empty(cTESInt)
							oSubModel:LoadValue( "VFL_CODTES", cTESInt)
							oSubModel:LoadValue( "VFL_TIPOPE", "")
						EndIf	
					Else	
						Help("",1,"FIELDPREVLD "+cId,,STR0086,1,0) // TES Inteligente - Produto não encontrado.
						lRet := .f.
					EndIf
				EndIf
			EndIf
			//Preenchimento automático dos campos que estão nas demais linhas do grid
			If ::cPro_VEIA == "2" .and. ::cIte_VEIA == "2" //Somente Desagrega/Peças
				If cId $ "VFL_CODESP/VFL_FORPAG/VFL_NATURE/VFL_CENCUS/VFL_CONTA/VFL_CLVL/VFL_ITEMCT/"
					::ReplicaDadosLinha(oSubModel,cId,xValue,"VFL","")
				EndIf
			ElseIf ::cPro_VEIA $ "3/4" // 3 = Transferência / 4 = Troca
				If cId $ "VFL_TIPOPE/VFL_CODTES/"
					::ReplicaDadosLinha(oSubModel,cId,xValue,"VFL","1/3/")
				ElseIf cId $ "VFL_CODESP/VFL_FORPAG/VFL_NATURE/VFL_CENCUS/VFL_CONTA/VFL_CLVL/VFL_ITEMCT/"
					::ReplicaDadosLinha(oSubModel,cId,xValue,"VFL","")
				EndIf
			EndIf
		EndIf
	Case cModelID == "VFODETAIL" // Movimentação Interna
		If cAction == "CANSETVALUE" 
			If cId $ "VFO_CENCUS/VFO_CONTA/VFO_ITEMCT/VFO_CLVL/" // Nao deixa alterar os campos que serão considerados na ABA de Peças
				If FWFldGet("VFO_TIPREG") $ "/2/4/6/8/"
					lRet := .f.
				EndIf
			EndIf
		EndIf	
		//Preenchimento automático dos campos que estão nas demais linhas do grid
		If cId $ "VFO_CENCUS/VFO_CONTA/VFO_ITEMCT/VFO_CLVL/"
			::ReplicaDadosLinha(oSubModel,cId,xValue,"VFO","1/3/5/7/")
		EndIf
EndCase
RETURN lRet

// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS VEIA300EVDEF
	Local cAux    := ""
	Local nAux    := 0
	Local nCntFor := 0
	Local aVFM    := {}
	Local aVFN    := {}
	Local oModAux
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE // Incluir ou Alterar
		If ::cPro_VEIA $ "1/3/4" // 1 = Agrega Individual / 3 = Transferencia / 4 = Troca
			If ::cIte_VEIA == "1" // AMS
				oModAux := oModel:GetModel("VFMDETAIL")
				For nCntFor := 1 to oModAux:Length()
					oModAux:GoLine(nCntFor)
					If !oModAux:IsDeleted() .and. Empty(oModAux:GetValue("VFM_CODIGO"))
						cAux := GetSXENum("VFM","VFM_CODIGO")
						aAdd(aVFM,cAux)
						oModAux:LoadValue( "VFM_CODIGO" , cAux )
					EndIf
				Next
			ElseIf ::cIte_VEIA == "2" // Peças
				oModAux := oModel:GetModel("VFNDETAIL")
				For nCntFor := 1 to oModAux:Length()
					oModAux:GoLine(nCntFor)
					If !oModAux:IsDeleted() .and. Empty(oModAux:GetValue("VFN_CODIGO"))
						cAux := GetSXENum("VFN","VFN_CODIGO")
						aAdd(aVFN,cAux)
						oModAux:LoadValue( "VFN_CODIGO" , cAux )
					EndIf
				Next
			EndIf
		EndIf
		If ::cPro_VEIA $ "2/3/4" // 2 = Desagrega Individual / 3 = Transferencia / 4 = Troca
			If ::cIte_VEIA == "1" // AMS
				nAux    := 1
				oModAux := oModel:GetModel("VFPDETAIL")
				For nCntFor := 1 to oModAux:Length()
					oModAux:GoLine(nCntFor)
					If !oModAux:IsDeleted() .and. Empty(oModAux:GetValue("VFP_CODIGO"))
						oModAux:LoadValue( "VFP_CODIGO" , GetSXENum("VFP","VFP_CODIGO"))
						If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
							oModAux:LoadValue( "VFP_REFSAI" , aVFM[nAux++] ) // relaciona o Codigo da Saida
						EndIf
					EndIf
				Next
			ElseIf ::cIte_VEIA == "2" // Peças
				nAux    := 1
				oModAux := oModel:GetModel("VFQDETAIL")
				For nCntFor := 1 to oModAux:Length()
					oModAux:GoLine(nCntFor)
					If !oModAux:IsDeleted() .and. Empty(oModAux:GetValue("VFQ_CODIGO"))
						oModAux:LoadValue( "VFQ_CODIGO" , GetSXENum("VFQ","VFQ_CODIGO"))
						If ::cPro_VEIA $ "3/4" // 3 = Transferencia / 4 = Troca
							oModAux:LoadValue( "VFQ_REFSAI" , aVFN[nAux++] ) // relaciona o Codigo da Saida
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	EndIf
RETURN .t.

// Chamado apos a Gravação padrão //
METHOD AfterTTS(oModel, cModelId) CLASS VEIA300EVDEF
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	::lEftetiva := .t.
EndIf
RETURN .t.

// Preencher o Custo Atual //
METHOD CalculaCusto(cNroVeic,cProcesso) CLASS VEIA300EVDEF
Local cChaInt   := IIf(cNroVeic=="1",::cVV1001,::cVV1002)
Local cCampoAtu := "VFJ_CUSAT"+cNroVeic // Custo Atual: 1 = Veic/Maq. 1, 2 = Veic/Maq. 2
Local cCampoFut := "VFJ_CUSFT"+cNroVeic // Custo Futuro: 1 = Veic/Maq. 1, 2 = Veic/Maq. 2
Local nCusAtu   := 0
Local oModel
If !Empty(cChaInt)
	If ::PosicionaVV1SB1(cChaInt) .and. ::PosicionaSB2()
		nCusAtu := round(SB2->B2_CM1,2) // Custo Atual
		oModel := FWModelActive()
		oModel:LoadValue( "VFJMASTER", cCampoAtu, nCusAtu) // Custo Atual  
		oModel:LoadValue( "VFJTOTAIS", cCampoAtu, nCusAtu) // Custo Atual  
		If cProcesso $ "1/2" // 1 = Agrega / 2 = Desagrega
			::AtualizaCustoFuturo(cNroVeic,cProcesso)
		ElseIf cProcesso == "4" // 4 = Troca
			nCusAtu := ::AtualizaCustoFuturo(cNroVeic,"2") // Desagregar
			::AtualizaCustoFuturo(cNroVeic,"1",nCusAtu) // Agregar
		EndIf
	EndIf
Else
	oModel := FWModelActive()
	oModel:LoadValue( "VFJMASTER", cCampoFut, 0 ) // Custo Futuro
	oModel:LoadValue( "VFJTOTAIS", cCampoFut, 0 ) // Custo Futuro
EndIf
Return 

// Realizar o cálculo e batiza o Custo Futuro //
Method AtualizaCustoFuturo(cNroVeic,cProcesso,nCusAtu) CLASS VEIA300EVDEF
Local oModelAux 
Local cModelAux := ""
Local oModel    := FWModelActive()
Local cCampoAtu := "VFJ_CUSAT"+cNroVeic // Custo Atual: 1 = Veic/Maq. 1, 2 = Veic/Maq. 2
Local cCampoFut := "VFJ_CUSFT"+cNroVeic // Custo Futuro: 1 = Veic/Maq. 1, 2 = Veic/Maq. 2
Local cCampoCus := ""
Local cCampoVei := ""
Local nCusFut   := 0
Local nCntFor   := 0
Local nLinhaAtu := 0
Default nCusAtu := oModel:GetValue( "VFJTOTAIS", cCampoAtu )
nCusFut := nCusAtu // Custo Futuro inicia com o Custo Atual
If cProcesso == "1" // 1 = Agrega
	cModelAux := IIf(::cIte_VEIA=="1","VFMDETAIL" ,"VFNDETAIL" ) // 1 = AMS Saida (Tabela VFM), 2 = Peças Saida (Tabela VFN)
	cCampoCus := IIf(::cIte_VEIA=="1","VFM_CUSUNI","VFN_CUSTOT") // 1 = AMS Saida (Tabela VFM), 2 = Peças Saida (Tabela VFN)
	cCampoVei := IIf(::cIte_VEIA=="1","VFM_VEIMAQ","VFN_VEIMAQ") // 1 = AMS Saida (Tabela VFM), 2 = Peças Saida (Tabela VFN)
ElseIf cProcesso == "2" // 2 = Desagrega
	cModelAux := IIf(::cIte_VEIA=="1","VFPDETAIL" ,"VFQDETAIL" ) // 1 = AMS Entrada (Tabela VFP), 2 = Peças Entrada (Tabela VFQ)
	cCampoCus := IIf(::cIte_VEIA=="1","VFP_CUSUNI","VFQ_CUSTOT") // 1 = AMS Entrada (Tabela VFP), 2 = Peças Entrada (Tabela VFQ)
	cCampoVei := IIf(::cIte_VEIA=="1","VFP_VEIMAQ","VFQ_VEIMAQ") // 1 = AMS Saida (Tabela VFM), 2 = Peças Saida (Tabela VFN)
EndIf
If !Empty(cModelAux)
	oModelAux := oModel:GetModel(cModelAux)
	nLinhaAtu := oModelAux:GetLine()
	For nCntFor := 1 to oModelAux:Length()
		oModelAux:GoLine(nCntFor)
		If !oModelAux:IsDeleted() .and. !Empty(FWFldGet(cCampoCus)) .and. FWFldGet(cCampoVei) == cNroVeic
			If cProcesso == "1" // 1 = Agrega
				nCusFut += round(FWFldGet(cCampoCus),2)
			Elseif cProcesso == "2" // 2 = Desagrega
				nCusFut -= round(FWFldGet(cCampoCus),2)
			EndIf
		EndIf
	Next
	oModel:LoadValue( "VFJMASTER", cCampoFut, nCusFut) // Custo Futuro
	oModel:LoadValue( "VFJTOTAIS", cCampoFut, nCusFut) // Custo Futuro
	oModelAux:GoLine(nLinhaAtu)
EndIf
Return nCusFut

// Posiciona no VV1 e SB1 //
METHOD PosicionaVV1SB1( cChaInt , cCodMar , cModVei , cSegMod ) CLASS VEIA300EVDEF
Local lRet      := .f.
Local cGruVei   := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Default cCodMar := ""
Default cModVei := ""
Default cSegMod := ""
If !Empty(cChaInt)
	DBSelectArea("VV1")
	DBSetOrder(1)
	If DBSeek(xFilial("VV1")+cChaInt)
		If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT, /* cMVMIL0010 */ , cGruVei ) // Posiciona no SB1
			lRet := .t.
		EndIf
	EndIf
Else
	DBSelectArea("VV2")
	DBSetOrder(1)
	If DBSeek( xFilial("VV2") + cCodMar + cModVei + cSegMod )
		DBSelectArea("SB1")
		DBSetOrder(1)
		If DbSeek( xFilial("SB1") + VV2->VV2_PRODUT )
			lRet := .t.
		EndIf
	EndIf
EndIf
Return lRet

// Posiciona no SB2 - Precisa estar com o SB1 posicionado //
METHOD PosicionaSB2() CLASS VEIA300EVDEF
Local lRet    := .f.
Local cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
DBSelectArea("SB2")
DBSetOrder(1)
If DbSeek(xFilial("SB2")+SB1->B1_COD+cLocAux)
	lRet := .t.
EndIf
Return lRet

//Preenchimento automático dos campos que estão nas demais linhas do grid
METHOD ReplicaDadosLinha(oSubModel,cId,xValue,cTab,cTpReg) Class VEIA300EVDEF
Local oView
Local cValAux := ""
Local nCntFor := 0
If oSubModel:GetLine() == 1
	cValAux := xValue
	For nCntFor := 2 to oSubModel:Length()
		oSubModel:GoLine(nCntFor)
		If Empty(cTpReg) .or. FWFldGet(cTab+"_TIPREG") $ cTpReg
			If Empty(oSubModel:GetValue(cId))
				oSubModel:SetValue(cId, cValAux)
			EndIf
		EndIf
	Next
	oSubModel:GoLine(1)
	oView := FWViewActive()
	oView:Refresh("VIEW_"+cTab)
EndIf
Return

// Final do processo, destroi objeto
METHOD Destroy() Class VEIA300EVDEF
If ::lEftetiva
	VEIA330() // Executa a EFETIVAÇÃO
EndIf
Return