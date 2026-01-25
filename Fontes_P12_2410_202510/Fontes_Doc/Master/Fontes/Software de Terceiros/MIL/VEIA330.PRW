#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA330.CH"

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA330
Processa a Efetivação

@author Andre Luis Almeida
@since 09/03/2023
/*/
Function VEIA330()
Local cTitProc := ""
Local nQtdProc := 0
Local oProcess // nao deixa cancelar tela
DbSelectArea("VFJ")
If VFJ->VFJ_STATUS $ "0/3" // 0 = Digitado / 3 = Efetivação Pendente ( problema para Efetivar )
	Do Case
		Case VFJ->VFJ_PROCES == "1" // Agrega (Individual)
			cTitProc := STR0001 // Agrega (Individual)
			nQtdProc := 6 // validações gerais / inicia processo / ajusta custo / saida veiculo / entrada veiculo / finaliza processo
			If VFJ->VFJ_TIPPRO == "1" // Notas Fiscais
				nQtdProc++ // selecionar as series
			EndIf
			If VFJ->VFJ_TIPITE == "2" // 2=Peças
				nQtdProc++ // saida peças ou entrada peças
			EndIf
		Case VFJ->VFJ_PROCES == "2" // Desagrega (Individual)
			cTitProc := STR0002 // Desagrega (Individual)
			nQtdProc := 7 // validações gerais / inicia processo / ajusta custo / saida veiculo / entrada veiculo / finaliza processo / entrada peças ou saida peças ou inclusao AMS
			If VFJ->VFJ_TIPPRO == "1" // Notas Fiscais
				nQtdProc++ // selecionar as series
			EndIf
		Case VFJ->VFJ_PROCES == "3" // Transferência
			cTitProc := STR0003 // Transferência
			nQtdProc := 10 // validações gerais / inicia processo / ajusta custo 1 / saida veiculo 1 / entrada veiculo 1 / ajusta custo 2 / saida veiculo 2 / entrada veiculo 2 / finaliza processo / entrada peças ou saida peças ou inclusao AMS
			If VFJ->VFJ_TIPPRO == "1" // Notas Fiscais
				nQtdProc++ // selecionar as series
			EndIf
			If VFJ->VFJ_TIPITE == "2" // 2=Peças
				nQtdProc++ // saida peças ou entrada peças
			EndIf
		Case VFJ->VFJ_PROCES == "4" // Troca
			cTitProc := STR0004 // Troca
			nQtdProc := 17 // validações gerais / inicia processo / ajusta custo 1 / saida veiculo 1 / entrada veiculo 1 / ajusta custo 2 / saida veiculo 2 / entrada veiculo 2 / entrada peças ou saida peças ou inclusao AMS / ajusta custo 2 / saida veiculo 2 / entrada veiculo 2 / ajusta custo 1 / saida veiculo 1 / entrada veiculo 1 / finaliza processo / entrada peças ou saida peças ou inclusao AMS
			If VFJ->VFJ_TIPPRO == "1" // Notas Fiscais
				nQtdProc++ // selecionar as series
			EndIf
			If VFJ->VFJ_TIPITE == "2" // 2=Peças
				nQtdProc++ // saida peças ou entrada peças
			EndIf
	EndCase
	If MsgYesNo(cTitProc,STR0005) // Efetivar Processo?
		oProcess := MsNewProcess():New({|lEnd| VA3300011_Efetivar( @oProcess , @lEnd , cTitProc , nQtdProc ) },cCadastro,cTitProc,.T.) 
		oProcess:Activate()
	EndIf
ElseIf VFJ->VFJ_STATUS == "1" // 1 = Efetivado
	Help("",1,"VEIA330",,STR0006,1,0) // Processo já Efetivado. Impossível continuar.
ElseIf VFJ->VFJ_STATUS == "2" // 2 = Cancelado
	Help("",1,"VEIA330",,STR0007,1,0) // Processo já Cancelado. Impossível continuar.
EndIf
Return

/*/{Protheus.doc} VA3300011_Efetivar
Efetivar Processo

@author Andre Luis Almeida
@since 23/02/2023
/*/
Static Function VA3300011_Efetivar( oProcess , lEnd , cTitProc , nQtdProc )
Local lOk         := .t.
Local cCodVDV     := ""
Local nRecVDV     := 0
Local nRecVV1     := 0
Local nNroExec    := 0
Local cTitDoc     := ""
Local cChassi     := ""
Local cTipReg     := ""
Local cQuery      := ""
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
Private cSerie    := ""
Private cNumero   := ""
Private aDocTela  := {}
Private aNumNFSF2 := {}
Private aNumNFSF1 := {}
Private aIteNFSF2 := {}
Private aIteNFSF1 := {}
Private aVDV      := {}
Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lMsFinalAuto := .f.
Default lEnd      := .f.
Default cTitProc  := ""
Default nQtdProc  := 0
//
If VFJ->VFJ_STATUS == "3" // 3 = Efetivação Pendente
	cQuery := "SELECT COUNT(*) AS QTDE "
	cQuery += "  FROM "+RetSQLName("VDV")
	cQuery += " WHERE VDV_FILIAL = '"+xFilial("VDV")+"'"
	cQuery += "   AND VDV_STATUS = '1'"
	cQuery += "   AND VDV_FILEXE = '"+VFJ->VFJ_FILIAL+"'"
	cQuery += "   AND VDV_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nNroExec := FM_SQL(cQuery) // Qtde de Registros gerados na Execução
EndIf
//
oProcess:SetRegua1(nQtdProc)
//
VA3300091_Regua( oProcess , STR0008 ) // Validações para Efetivação
If VA300014D_Validacoes_Efetivacao() // Validações antes de Efetivar: Custo, Estoque, Cliente/Fornecedor, ...
	//
	INCLUI := .t. // Necessário nos VEIXX000 e VEIXX001
	nOpc   := 3   // Necessário nos VEIXX000 e VEIXX001
	//
	If VFJ->VFJ_TIPPRO == "1" // Notas Fiscais
		VA3300091_Regua( oProcess , "Seleção das Series das Notas Fiscais" ) // Seleção das Series das Notas Fiscais
		If !VA3300041_Selecionar_Serie_NFs() // Cancelou as Telas para escolha das Numerações das Notas Fiscais
			Return
		EndIf
	EndIf
	//
	Do Case
		Case VFJ->VFJ_PROCES $ "12" // 1=Agrega(Individual) ou 2=Desagrega(Individual)
			//
			If nNroExec == 0
				//
				aAdd(aDocTela,{ "" , "---" , cTitProc })
				aAdd(aDocTela,{ "" , "---" , "" })
				//
				VA3300091_Regua( oProcess , STR0009 ) // Iniciando Processo
				//
				VA3300091_Regua( oProcess , STR0010 ) // Ajusta Custos Veic./Máq./Equip. 1
				VA330010D_AjustaCustos( "1" , VFJ->VFJ_PROCES ) // Ajusta Custos do Veiculo/Máquina 1
				//
				BEGIN TRANSACTION
				//
				VA3000151_Grava_Status( VFJ->VFJ_FILIAL , VFJ->VFJ_CODIGO , "3" ) // Mudar Status do Processo para 3=Não Efetivado
				//
				aVDV := {}
				aAdd(aVDV,{ "VDV_FILEXE" , VFJ->VFJ_FILIAL }) // Filial da Execução do Processo
				aAdd(aVDV,{ "VDV_CODEXE" , VFJ->VFJ_CODIGO }) // Codigo de Execução do Processo
				aAdd(aVDV,{ "VDV_AGRDES" , VFJ->VFJ_PROCES }) // 1=Agrega(Individual) ou 2=Desagrega(Individual)
				aAdd(aVDV,{ "VDV_CHAINT" , VFJ->VFJ_VV1001 }) // CHAINT da Maquina 1
				aAdd(aVDV,{ "VDV_TIPDOC" , VFJ->VFJ_TIPPRO }) // Tipo ( 1=Notas Fiscais / 2=Movimentações Internas )
				nRecVDV := VA3180011_MVC_CAD_VDV( 0 , aVDV ) // 0 = Cria VDV
				If nRecVDV > 0
					cCodVDV := VDV->VDV_CODIGO
					aVDV := {}
					If lOk .and. VFJ->VFJ_PROCES == "2" .and. VFJ->VFJ_TIPITE == "1" // 2=Desagrega(Individual) e 1=AMS
						VA3300091_Regua( oProcess , STR0011+" - "+cSiglaAMS ) // Inclusão
						lOk := VA3300081_VV1_AMS() // Criação/Alteração do VV1/VFP referente aos AMS que serão desegregados
					EndIf
					If lOk
						VV1->(DbSetOrder(1))
						VV1->(DbSeek(xFilial("VV1")+VFJ->VFJ_VV1001))
						nRecVV1 := VV1->(RecNo())
						cChassi := VV1->VV1_CHASSI
						VA3300091_Regua( oProcess , STR0012 ) // Gerando Saida do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Saida Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 1=Saida Veículo/Máquina/Equipamento 1
						cTipReg := "1"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300021_SAIDA_VV0VVA( cTipReg , "1" , VFJ->VFJ_CODIGO , VFJ->VFJ_PROCES , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSAT1 , cCodVDV , cTitDoc ) // Saida Veiculo 1
					EndIf
					If lOk .and. VFJ->VFJ_PROCES == "1" .and. VFJ->VFJ_TIPITE == "2" // 1=Agrega(Individual) e 2=Peças
						VA3300091_Regua( oProcess , STR0013 ) // Gerando Saida das Peças
						// Nota Fiscal: 2=NF Saida Peças Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 2=Saida Peças Veículo/Máquina/Equipamento 1
						cTipReg := "2"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300051_SAIDA_PECAS( cTipReg , "1" , VFJ->VFJ_CODIGO , VFJ->VFJ_PROCES , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Saida Peças para o Veiculo 1
					EndIf
					If lOk
						VA3300091_Regua( oProcess , STR0014 ) // Gerando Entrada do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Entrada Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 5=Entrada Veículo/Máquina/Equipamento 1
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","1","5") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300031_ENTRADA_VVFVVG( cTipReg , "1" , VFJ->VFJ_CODIGO , VFJ->VFJ_PROCES , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSFT1 , cCodVDV , cTitDoc ) // Entrada Veiculo 1
					EndIf
					If lOk .and. VFJ->VFJ_PROCES == "2" .and. VFJ->VFJ_TIPITE == "2" // 2=Desagrega(Individual) e 2=Peças
						VA3300091_Regua( oProcess , STR0015 ) // Gerando Entrada das Peças
						// Nota Fiscal: 2=NF Entrada Peças Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 6=Entrada Peças para Desagregar do 1
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","2","6") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300061_ENTRADA_PECAS( cTipReg , "1" , VFJ->VFJ_CODIGO , VFJ->VFJ_PROCES , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Entrada Peças para o Veiculo 1
					EndIf
					If lOk
						If len(aVDV) > 0
							nRecVDV := VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
						EndIf
						FGX_AMOVVEI(xFilial("VV1"),cChassi) // Ajusta os dados das ultimas movimentações do VV1
					EndIf
					If !lOk .or. cDebugMIL == "VEIA330001"
						DisarmTransaction()
						MostraErro()
						Break
					EndIf
				EndIf
				//
				If lOk
					VA3300091_Regua( oProcess , STR0016 ) // Finalizando Processo
					VA3000151_Grava_Status( VFJ->VFJ_FILIAL , VFJ->VFJ_CODIGO , "1" ) // Mudar Status do Processo para 1=Efetivado
				EndIf
				//
				END TRANSACTION
				//
			EndIf
			//
		Case VFJ->VFJ_PROCES == "3" // 3=Transferencia
			//
			If nNroExec == 0
				//
				aAdd(aDocTela,{ "gr_blue01" , "---" , STR0029 }) // Desagrega
				//
				VA3300091_Regua( oProcess , STR0009 ) // Iniciando Processo
				//
				VA3300091_Regua( oProcess , STR0010 ) // Ajusta Custos Veic./Máq./Equip. 1
				VA330010D_AjustaCustos( "1" , "2" ) // Ajusta Custos do Veiculo/Máquina 1 - Desagregando do Veiculo 1
				//
				BEGIN TRANSACTION
				//
				VA3000151_Grava_Status( VFJ->VFJ_FILIAL , VFJ->VFJ_CODIGO , "3" ) // Mudar Status do Processo para 3=Não Efetivado
				//
				aVDV := {}
				aAdd(aVDV,{ "VDV_FILEXE" , VFJ->VFJ_FILIAL }) // Filial da Execução do Processo
				aAdd(aVDV,{ "VDV_CODEXE" , VFJ->VFJ_CODIGO }) // Codigo de Execução do Processo
				aAdd(aVDV,{ "VDV_AGRDES" , "2" }) // 1=Agrega(Individual) ou 2=Desagrega(Individual)
				aAdd(aVDV,{ "VDV_CHAINT" , VFJ->VFJ_VV1001 }) // CHAINT da Maquina 1
				aAdd(aVDV,{ "VDV_TIPDOC" , VFJ->VFJ_TIPPRO }) // Tipo ( 1=Notas Fiscais / 2=Movimentações Internas )
				nRecVDV := VA3180011_MVC_CAD_VDV( 0 , aVDV ) // 0 = Cria VDV
				If nRecVDV > 0
					cCodVDV := VDV->VDV_CODIGO
					aVDV := {}
					If lOk .and. VFJ->VFJ_TIPITE == "1" // 1=AMS
						VA3300091_Regua( oProcess , STR0011+" - "+cSiglaAMS ) // Inclusão
						lOk := VA3300081_VV1_AMS() // Criação/Alteração do VV1/VFP referente aos AMS que serão desegregados
					EndIf
					If lOk
						VV1->(DbSetOrder(1))
						VV1->(DbSeek(xFilial("VV1")+VFJ->VFJ_VV1001))
						nRecVV1 := VV1->(RecNo())
						cChassi := VV1->VV1_CHASSI
						VA3300091_Regua( oProcess , STR0012 ) // Gerando Saida do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Saida Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 1=Saida Veículo/Máquina/Equipamento 1
						cTipReg := "1"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300021_SAIDA_VV0VVA( cTipReg , "1" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSAT1 , cCodVDV , cTitDoc ) // Saida Veiculo 1
					EndIf
					If lOk
						VA3300091_Regua( oProcess , STR0014 ) // Gerando Entrada do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Entrada Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 5=Entrada Veículo/Máquina/Equipamento 1
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","1","5") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300031_ENTRADA_VVFVVG( cTipReg , "1" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSFT1 , cCodVDV , cTitDoc ) // Entrada Veiculo 1
					EndIf
					If lOk .and. VFJ->VFJ_TIPITE == "2" // 2=Peças
						VA3300091_Regua( oProcess , STR0015 ) // Gerando Entrada das Peças
						// Nota Fiscal: 2=NF Entrada Peças para Desagregar do 1
						// Movimentação Interna: 6=Entrada Peças para Desagregar do 1
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","2","6") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300061_ENTRADA_PECAS( cTipReg , "1" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Entrada Peças para o Veiculo 1
					EndIf
					If lOk
						If len(aVDV) > 0
							nRecVDV := VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
						EndIf
						FGX_AMOVVEI(xFilial("VV1"),cChassi) // Ajusta os dados das ultimas movimentações do VV1
					EndIf
				EndIf
				//
				If !lOk .or. cDebugMIL == "VEIA330002"
					DisarmTransaction()
					MostraErro()
					Break
				EndIf
				//
				END TRANSACTION
				//
			EndIf
			//
			If nNroExec <= 1
				//
				aAdd(aDocTela,{ "gr_blue02" , "---" , STR0028 }) // Agrega
				//
				VA3300091_Regua( oProcess , STR0017 ) // Ajusta Custos Veic./Máq./Equip. 2
				VA330010D_AjustaCustos( "2" , "1" ) // Ajusta Custos do Veiculo/Máquina 2 - Agregando no Veiculo 2
				//
				BEGIN TRANSACTION
				//
				aVDV := {}
				aAdd(aVDV,{ "VDV_FILEXE" , VFJ->VFJ_FILIAL }) // Filial da Execução do Processo
				aAdd(aVDV,{ "VDV_CODEXE" , VFJ->VFJ_CODIGO }) // Codigo de Execução do Processo
				aAdd(aVDV,{ "VDV_AGRDES" , "1" }) // 1=Agrega(Individual) ou 2=Desagrega(Individual)
				aAdd(aVDV,{ "VDV_CHAINT" , VFJ->VFJ_VV1002 }) // CHAINT da Maquina 2
				aAdd(aVDV,{ "VDV_TIPDOC" , VFJ->VFJ_TIPPRO }) // Tipo ( 1=Notas Fiscais / 2=Movimentações Internas )
				nRecVDV := VA3180011_MVC_CAD_VDV( 0 , aVDV ) // 0 = Cria VDV
				If nRecVDV > 0
					cCodVDV := VDV->VDV_CODIGO
					aVDV := {}
					If lOk
						VV1->(DbSetOrder(1))
						VV1->(DbSeek(xFilial("VV1")+VFJ->VFJ_VV1002))
						nRecVV1 := VV1->(RecNo())
						cChassi := VV1->VV1_CHASSI
						VA3300091_Regua( oProcess , STR0018 ) // Gerando Saida do Veic./Máq./Equip. 2
						// Nota Fiscal: 3=NF Saida Veículo/Máquina/Equipamento 2
						// Movimentação Interna: 3=Saida Veículo/Máquina/Equipamento 2
						cTipReg := "3"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300021_SAIDA_VV0VVA( cTipReg , "2" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSAT2 , cCodVDV , cTitDoc ) // Saida Veiculo 2
					EndIf
					If lOk .and. VFJ->VFJ_TIPITE == "2" // 2=Peças
						VA3300091_Regua( oProcess , STR0013 ) // Gerando Saida das Peças
						// Nota Fiscal: 4=NF Saida Peças para Agregar no 2
						// Movimentação Interna: 4=Saida Peças para Agregar no 2
						cTipReg := "4"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300051_SAIDA_PECAS( cTipReg , "2" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Saida Peças para o Veiculo 2
					EndIf
					If lOk
						VA3300091_Regua( oProcess , STR0019 ) // Gerando Entrada do Veic./Máq./Equip. 2
						// Nota Fiscal: 3=NF Entrada Veículo/Máquina/Equipamento 2
						// Movimentação Interna: 7=Entrada Veículo/Máquina/Equipamento 2
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","3","7") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300031_ENTRADA_VVFVVG( cTipReg , "2" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSFT2 , cCodVDV , cTitDoc ) // Entrada Veiculo 2
					EndIf
					If lOk
						If len(aVDV) > 0
							nRecVDV := VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
						EndIf
						FGX_AMOVVEI(xFilial("VV1"),cChassi) // Ajusta os dados das ultimas movimentações do VV1
					EndIf
					If !lOk .or. cDebugMIL == "VEIA330003"
						DisarmTransaction()
						MostraErro()
						Break
					EndIf
				EndIf
				//
				If lOk
					VA3300091_Regua( oProcess , STR0016 ) // Finalizando Processo
					VA3000151_Grava_Status( VFJ->VFJ_FILIAL , VFJ->VFJ_CODIGO , "1" ) // Mudar Status do Processo para 1=Efetivado
				EndIf
				//
				END TRANSACTION
				//
			EndIf
			//
		Case VFJ->VFJ_PROCES == "4" // 4=Troca
			//
			If nNroExec == 0
				//
				aAdd(aDocTela,{ "gr_blue01" , "---" , STR0029 }) // Desagrega
				//
				VA3300091_Regua( oProcess , STR0009 ) // Iniciando Processo
				//
				VA3300091_Regua( oProcess , STR0010 ) // Ajusta Custos Veic./Máq./Equip. 1
				VA330010D_AjustaCustos( "1" , "2" ) // Ajusta Custos do Veiculo/Máquina 1 - Desagregando do Veiculo 1
				//
				BEGIN TRANSACTION
				//
				VA3000151_Grava_Status( VFJ->VFJ_FILIAL , VFJ->VFJ_CODIGO , "3" ) // Mudar Status do Processo para 3=Não Efetivado
				//
				aVDV := {}
				aAdd(aVDV,{ "VDV_FILEXE" , VFJ->VFJ_FILIAL }) // Filial da Execução do Processo
				aAdd(aVDV,{ "VDV_CODEXE" , VFJ->VFJ_CODIGO }) // Codigo de Execução do Processo
				aAdd(aVDV,{ "VDV_AGRDES" , "2" }) // 1=Agrega(Individual) ou 2=Desagrega(Individual)
				aAdd(aVDV,{ "VDV_CHAINT" , VFJ->VFJ_VV1001 }) // CHAINT da Maquina 1
				aAdd(aVDV,{ "VDV_TIPDOC" , VFJ->VFJ_TIPPRO }) // Tipo ( 1=Notas Fiscais / 2=Movimentações Internas )
				nRecVDV := VA3180011_MVC_CAD_VDV( 0 , aVDV ) // 0 = Cria VDV
				If nRecVDV > 0
					cCodVDV := VDV->VDV_CODIGO
					aVDV := {}
					If lOk .and. VFJ->VFJ_TIPITE == "1" // 1=AMS
						VA3300091_Regua( oProcess , STR0011+" - "+cSiglaAMS ) // Inclusão
						lOk := VA3300081_VV1_AMS() // Criação/Alteração do VV1/VFP referente aos AMS que serão desegregados
					EndIf
					If lOk
						VV1->(DbSetOrder(1))
						VV1->(DbSeek(xFilial("VV1")+VFJ->VFJ_VV1001))
						nRecVV1 := VV1->(RecNo())
						cChassi := VV1->VV1_CHASSI
						VA3300091_Regua( oProcess , STR0012 ) // Gerando Saida do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Saida Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 1=Saida Veículo/Máquina/Equipamento 1
						cTipReg := "1"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300021_SAIDA_VV0VVA( cTipReg , "1" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSAT1 , cCodVDV , cTitDoc ) // Saida Veiculo 1
					EndIf
					If lOk
						VA3300091_Regua( oProcess , STR0014 ) // Gerando Entrada do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Entrada Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 5=Entrada Veículo/Máquina/Equipamento 1
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","1","5") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300031_ENTRADA_VVFVVG( cTipReg , "1" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSFT1 , cCodVDV , cTitDoc ) // Entrada Veiculo 1
					EndIf
					If lOk .and. VFJ->VFJ_TIPITE == "2" // 2=Peças
						VA3300091_Regua( oProcess , STR0015 ) // Gerando Entrada das Peças
						// Nota Fiscal: 2=NF Entrada Peças para Desagregar do 1
						// Movimentação Interna: 6=Entrada Peças para Desagregar do 1
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","2","6") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300061_ENTRADA_PECAS( cTipReg , "1" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Entrada Peças para o Veiculo 1
					EndIf
					If lOk
						If len(aVDV) > 0
							nRecVDV := VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
						EndIf
						FGX_AMOVVEI(xFilial("VV1"),cChassi) // Ajusta os dados das ultimas movimentações do VV1
					EndIf
				EndIf
				//
				If !lOk .or. cDebugMIL == "VEIA330004"
					DisarmTransaction()
					MostraErro()
					Break
				EndIf
				//
				END TRANSACTION
				//
			EndIf
			//
			If nNroExec <= 1
				//
				aAdd(aDocTela,{ "gr_blue02" , "---" , STR0028 }) // Agrega
				//
				VA3300091_Regua( oProcess , STR0017 ) // Ajusta Custos Veic./Máq./Equip. 2
				VA330010D_AjustaCustos( "2" , "1" ) // Ajusta Custos do Veiculo/Máquina 2 - Agregando no Veiculo 2
				//
				BEGIN TRANSACTION
				//
				aVDV := {}
				aAdd(aVDV,{ "VDV_FILEXE" , VFJ->VFJ_FILIAL }) // Filial da Execução do Processo
				aAdd(aVDV,{ "VDV_CODEXE" , VFJ->VFJ_CODIGO }) // Codigo de Execução do Processo
				aAdd(aVDV,{ "VDV_AGRDES" , "1" }) // 1=Agrega(Individual) ou 2=Desagrega(Individual)
				aAdd(aVDV,{ "VDV_CHAINT" , VFJ->VFJ_VV1002 }) // CHAINT da Maquina 2
				aAdd(aVDV,{ "VDV_TIPDOC" , VFJ->VFJ_TIPPRO }) // Tipo ( 1=Notas Fiscais / 2=Movimentações Internas )
				nRecVDV := VA3180011_MVC_CAD_VDV( 0 , aVDV ) // 0 = Cria VDV
				If nRecVDV > 0
					cCodVDV := VDV->VDV_CODIGO
					aVDV := {}
					If lOk
						VV1->(DbSetOrder(1))
						VV1->(DbSeek(xFilial("VV1")+VFJ->VFJ_VV1002))
						nRecVV1 := VV1->(RecNo())
						cChassi := VV1->VV1_CHASSI
						VA3300091_Regua( oProcess , STR0018 ) // Gerando Saida do Veic./Máq./Equip. 2
						// Nota Fiscal: 3=NF Saida Veículo/Máquina/Equipamento 2
						// Movimentação Interna: 3=Saida Veículo/Máquina/Equipamento 2
						cTipReg := "3"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300021_SAIDA_VV0VVA( cTipReg , "2" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSAT2 , cCodVDV , cTitDoc ) // Saida Veiculo 2
					EndIf
					If lOk .and. VFJ->VFJ_TIPITE == "2" // 2=Peças
						VA3300091_Regua( oProcess , STR0013 ) // Gerando Saida das Peças
						// Nota Fiscal: 4=NF Saida Peças para Agregar no 2
						// Movimentação Interna: 4=Saida Peças para Agregar no 2
						cTipReg := "4"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300051_SAIDA_PECAS( cTipReg , "2" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Saida Peças para o Veiculo 2
					EndIf
					If lOk
						VA3300091_Regua( oProcess , STR0019 ) // Gerando Entrada do Veic./Máq./Equip. 2
						// Nota Fiscal: 3=NF Entrada Veículo/Máquina/Equipamento 2
						// Movimentação Interna: 7=Entrada Veículo/Máquina/Equipamento 2
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","3","7") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300031_ENTRADA_VVFVVG( cTipReg , "2" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSFT2 , cCodVDV , cTitDoc ) // Entrada Veiculo 2
					EndIf
					If lOk
						If len(aVDV) > 0
							nRecVDV := VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
						EndIf
						FGX_AMOVVEI(xFilial("VV1"),cChassi) // Ajusta os dados das ultimas movimentações do VV1
					EndIf
				EndIf
				//
				If !lOk .or. cDebugMIL == "VEIA330005"
					DisarmTransaction()
					MostraErro()
					Break
				EndIf
				//
				END TRANSACTION
				//
			EndIf
			//
			If nNroExec <= 2
				//
				aAdd(aDocTela,{ "gr_blue03" , "---" , STR0029 }) // Desagrega
				//
				VA3300091_Regua( oProcess , STR0017 ) // Ajusta Custos Veic./Máq./Equip. 2
				VA330010D_AjustaCustos( "2" , "2" ) // Ajusta Custos do Veiculo/Máquina 2 - Desagregando do Veiculo 2
				//
				BEGIN TRANSACTION
				//
				aVDV := {}
				aAdd(aVDV,{ "VDV_FILEXE" , VFJ->VFJ_FILIAL }) // Filial da Execução do Processo
				aAdd(aVDV,{ "VDV_CODEXE" , VFJ->VFJ_CODIGO }) // Codigo de Execução do Processo
				aAdd(aVDV,{ "VDV_AGRDES" , "2" }) // 1=Agrega(Individual) ou 2=Desagrega(Individual)
				aAdd(aVDV,{ "VDV_CHAINT" , VFJ->VFJ_VV1002 }) // CHAINT da Maquina 2
				aAdd(aVDV,{ "VDV_TIPDOC" , VFJ->VFJ_TIPPRO }) // Tipo ( 1=Notas Fiscais / 2=Movimentações Internas )
				nRecVDV := VA3180011_MVC_CAD_VDV( 0 , aVDV ) // 0 = Cria VDV
				If nRecVDV > 0
					cCodVDV := VDV->VDV_CODIGO
					aVDV := {}
					If lOk .and. VFJ->VFJ_TIPITE == "1" // 1=AMS
						VA3300091_Regua( oProcess , STR0011+" - "+cSiglaAMS ) // Inclusão
						lOk := VA3300081_VV1_AMS() // Criação/Alteração do VV1/VFP referente aos AMS que serão desegregados
					EndIf
					If lOk
						VV1->(DbSetOrder(1))
						VV1->(DbSeek(xFilial("VV1")+VFJ->VFJ_VV1002))
						nRecVV1 := VV1->(RecNo())
						cChassi := VV1->VV1_CHASSI
						VA3300091_Regua( oProcess , STR0018 ) // Gerando Saida do Veic./Máq./Equip. 2
						// Nota Fiscal: 3=NF Saida Veículo/Máquina/Equipamento 2
						// Movimentação Interna: 3=Saida Veículo/Máquina/Equipamento 2
						cTipReg := "3"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300021_SAIDA_VV0VVA( cTipReg , "2" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSAT2 , cCodVDV , cTitDoc ) // Saida Veiculo 2
					EndIf
					If lOk
						VA3300091_Regua( oProcess , STR0019 ) // Gerando Entrada do Veic./Máq./Equip. 2
						// Nota Fiscal: 3=NF Entrada Veículo/Máquina/Equipamento 2
						// Movimentação Interna: 7=Entrada Veículo/Máquina/Equipamento 2
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","3","7") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300031_ENTRADA_VVFVVG( cTipReg , "2" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSFT2 , cCodVDV , cTitDoc ) // Entrada Veiculo 2
					EndIf
					If lOk .and. VFJ->VFJ_TIPITE == "2" // 2=Peças
						VA3300091_Regua( oProcess , STR0015 ) // Gerando Entrada das Peças
						// Nota Fiscal: 4=NF Entrada Peças para Desagregar do 2
						// Movimentação Interna: 8=Entrada Peças para Desagregar do 2
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","4","8") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300061_ENTRADA_PECAS( cTipReg , "2" , VFJ->VFJ_CODIGO , "2" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Entrada Peças para o Veiculo 2
					EndIf
					If lOk
						If len(aVDV) > 0
							nRecVDV := VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
						EndIf
						FGX_AMOVVEI(xFilial("VV1"),cChassi) // Ajusta os dados das ultimas movimentações do VV1
					EndIf
				EndIf
				//
				If !lOk .or. cDebugMIL == "VEIA330006"
					DisarmTransaction()
					MostraErro()
					Break
				EndIf
				//
				END TRANSACTION
				//
			EndIf
			//
			If nNroExec <= 3
				//
				aAdd(aDocTela,{ "gr_blue04" , "---" , STR0028 }) // Agrega
				//
				VA3300091_Regua( oProcess , STR0010 ) // Ajusta Custos Veic./Máq./Equip. 1
				VA330010D_AjustaCustos( "1" , "1" ) // Ajusta Custos do Veiculo/Máquina 1 - Agregando no Veiculo 1
				//
				BEGIN TRANSACTION
				//
				aVDV := {}
				aAdd(aVDV,{ "VDV_FILEXE" , VFJ->VFJ_FILIAL }) // Filial da Execução do Processo
				aAdd(aVDV,{ "VDV_CODEXE" , VFJ->VFJ_CODIGO }) // Codigo de Execução do Processo
				aAdd(aVDV,{ "VDV_AGRDES" , "1" }) // 1=Agrega(Individual) ou 2=Desagrega(Individual)
				aAdd(aVDV,{ "VDV_CHAINT" , VFJ->VFJ_VV1001 }) // CHAINT da Maquina 1
				aAdd(aVDV,{ "VDV_TIPDOC" , VFJ->VFJ_TIPPRO }) // Tipo ( 1=Notas Fiscais / 2=Movimentações Internas )
				nRecVDV := VA3180011_MVC_CAD_VDV( 0 , aVDV ) // 0 = Cria VDV
				If nRecVDV > 0
					cCodVDV := VDV->VDV_CODIGO
					aVDV := {}
					If lOk
						VV1->(DbSetOrder(1))
						VV1->(DbSeek(xFilial("VV1")+VFJ->VFJ_VV1001))
						nRecVV1 := VV1->(RecNo())
						cChassi := VV1->VV1_CHASSI
						VA3300091_Regua( oProcess , STR0012 ) // Gerando Saida do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Saida Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 1=Saida Veículo/Máquina/Equipamento 1
						cTipReg := "1"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300021_SAIDA_VV0VVA( cTipReg , "1" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSAT1 , cCodVDV , cTitDoc ) // Saida Veiculo 1
					EndIf
					If lOk .and. VFJ->VFJ_TIPITE == "2" // 2=Peças
						VA3300091_Regua( oProcess , STR0013 ) // Gerando Saida das Peças
						// Nota Fiscal: 2=NF Saida Peças para Agregar no 1
						// Movimentação Interna: 2=Saida Peças para Agregar no 1
						cTipReg := "2"
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","S","M"),cTipReg)
						lOk := VA3300051_SAIDA_PECAS( cTipReg , "1" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , cCodVDV , cTitDoc ) // Saida Peças para o Veiculo 1
					EndIf
					If lOk
						VA3300091_Regua( oProcess , STR0014 ) // Gerando Entrada do Veic./Máq./Equip. 1
						// Nota Fiscal: 1=NF Entrada Veículo/Máquina/Equipamento 1
						// Movimentação Interna: 5=Entrada Veículo/Máquina/Equipamento 1
						cTipReg := IIf(VFJ->VFJ_TIPPRO=="1","1","5") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
						cTitDoc := VA3300141_RetornaTitulo(IIf(VFJ->VFJ_TIPPRO=="1","E","M"),cTipReg)
						lOk := VA3300031_ENTRADA_VVFVVG( cTipReg , "1" , VFJ->VFJ_CODIGO , "1" , VFJ->VFJ_TIPPRO , VFJ->VFJ_TIPITE , nRecVV1 , VFJ->VFJ_CUSFT1 , cCodVDV , cTitDoc ) // Entrada Veiculo 1
					EndIf
					If lOk
						If len(aVDV) > 0
							nRecVDV := VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
						EndIf
						FGX_AMOVVEI(xFilial("VV1"),cChassi) // Ajusta os dados das ultimas movimentações do VV1
					EndIf
					If !lOk .or. cDebugMIL == "VEIA330007"
						DisarmTransaction()
						MostraErro()
						Break
					EndIf
				EndIf
				//
				If lOk
					VA3300091_Regua( oProcess , STR0016 ) // Finalizando Processo
					VA3000151_Grava_Status( VFJ->VFJ_FILIAL , VFJ->VFJ_CODIGO , "1" ) // Mudar Status do Processo para 1=Efetivado
				EndIf
				//
				END TRANSACTION
				//
			EndIf
	EndCase
EndIf
//
If lOk .and. len(aDocTela) > 0
	VA3300131_MostrarDocumentosTela(aDocTela,"")
EndIf
//
Return

/*/{Protheus.doc} VA3300021_SAIDA_VV0VVA
Criação dos Registros de SAIDA (VV0/VVA) do VV1

@author Andre Luis Almeida
@since 06/03/2023
/*/
Static Function VA3300021_SAIDA_VV0VVA( cTpReg , cNroVeic , cCodExe , cPro_VEIA , cTip_VEIA , cIte_VEIA , nRecVV1 , nCustoVV1 , cCodVDV , cTitDoc )
Local lRet        := .t.
Local cQuery      := ""
Local cSQLAlias   := "SQLAUX"
Local xSAutoCab   := {}
Local xSAutoItens := {}
Local xAutoIt     := {}
Local aVltFilDes  := {}
Local aVFK        := {}
Local nCntFor     := 0
Local nRecSB1     := 0
Local nRecNo      := 0
Local nTotVV0     := 0
Local cGruVei     := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Local oModelVV1   := FWLoadModel( 'VEIA070' ) // VV1
Local aSM0        := {}
Local aCposVV0A   := {}
//
DbSelectArea("VV1")
DbGoTo(nRecVV1)
FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
nRecSB1 := SB1->(RecNo())
SB1->(dbSetOrder(1))
//
If cTip_VEIA == "1" // Notas Fiscais
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFK")
	cQuery += " WHERE VFK_FILIAL = '"+xFilial("VFK")+"'"
	cQuery += "   AND VFK_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFK_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFK_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		VFK->(DbGoTo(nRecNo))
		aadd( aCposVV0A , VFK->VFK_CODCLI ) // 01 - Código do Cliente
		aadd( aCposVV0A , VFK->VFK_LOJCLI ) // 02 - Loja do Cliente
		aadd( aCposVV0A , VFK->VFK_CODBCO ) // 03 - Banco
		aadd( aCposVV0A , VFK->VFK_FORPAG ) // 04 - Forma de Pagamento
		aadd( aCposVV0A , VFK->VFK_NATURE ) // 05 - Natureza
		aadd( aCposVV0A , VFK->VFK_CODVEN ) // 06 - Código do Vendedor
		aadd( aCposVV0A , VFK->VFK_MENPAD ) // 07 - Mensagem Padrão
		aadd( aCposVV0A , VFK->VFK_MENNOT ) // 08 - Mensagem Nota
		aadd( aCposVV0A , VFK->VFK_PRECPA ) // 09 - Presença
		aadd( aCposVV0A , VFK->VFK_CODTES ) // 10 - TES
		aadd( aCposVV0A , VFK->VFK_CENCUS ) // 11 - Centro de Custo
		aadd( aCposVV0A , VFK->VFK_CONTA  ) // 12 - Conta Contabil
		aadd( aCposVV0A , VFK->VFK_ITEMCT ) // 13 - Item Conta Contabil
		aadd( aCposVV0A , VFK->VFK_CLVL   ) // 14 - Classe Valor
		aadd( aCposVV0A , VFK->VFK_CODESP ) // 15 - Especie
		aadd( aCposVV0A , VFK->VFK_OBSNOT ) // 16 - Observação NF
	EndIf
Else // cTip_VEIA == "2" // Movimentações Internas
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFO")
	cQuery += " WHERE VFO_FILIAL = '"+xFilial("VFO")+"'"
	cQuery += "   AND VFO_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFO_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFO_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		VFO->(DbGoTo(nRecNo))
		aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt)
		SA1->(DBSetOrder(3))
		SA1->(DbSeek(xFilial("SA1")+aSM0[SM0_CGC]))
		SA1->(DBSetOrder(1))
		aadd( aCposVV0A , SA1->A1_COD     ) // 01 - Código do Cliente
		aadd( aCposVV0A , SA1->A1_LOJA    ) // 02 - Loja do Cliente
		aadd( aCposVV0A , ""              ) // 03 - Banco
		aadd( aCposVV0A , ""              ) // 04 - Forma de Pagamento
		aadd( aCposVV0A , ""              ) // 05 - Natureza
		aadd( aCposVV0A , ""              ) // 06 - Código do Vendedor
		aadd( aCposVV0A , ""              ) // 07 - Mensagem Padrão
		aadd( aCposVV0A , ""              ) // 08 - Mensagem Nota
		aadd( aCposVV0A , ""              ) // 09 - Presença
		aadd( aCposVV0A , ""              ) // 10 - TES
		aadd( aCposVV0A , VFO->VFO_CENCUS ) // 11 - Centro de Custo
		aadd( aCposVV0A , VFO->VFO_CONTA  ) // 12 - Conta Contabil
		aadd( aCposVV0A , VFO->VFO_ITEMCT ) // 13 - Item Conta Contabil
		aadd( aCposVV0A , VFO->VFO_CLVL   ) // 14 - Classe Valor
		aadd( aCposVV0A , ""              ) // 15 - Especie
		aadd( aCposVV0A , ""              ) // 16 - Observação NF
	EndIf
EndIf
//

If len(aCposVV0A) > 0
	aAdd(xSAutoCab,{ "VV0_FILIAL" , xFilial("VV0")                              , Nil })
	aAdd(xSAutoCab,{ "VV0_FORPRO" , "1"                                         , Nil })
	aAdd(xSAutoCab,{ "VV0_DATMOV" , dDataBase                                   , Nil })
	aAdd(xSAutoCab,{ "VV0_CLIFOR" , "C"                                         , Nil })
	aAdd(xSAutoCab,{ "VV0_CODCLI" , aCposVV0A[01]                               , Nil })
	aAdd(xSAutoCab,{ "VV0_LOJA"   , aCposVV0A[02]                               , Nil })
	aAdd(xSAutoCab,{ "VV0_CODBCO" , aCposVV0A[03]                               , Nil })
	aAdd(xSAutoCab,{ "VV0_FORPAG" , IIf(!Empty(aCposVV0A[04]),aCposVV0A[04],RetCondVei()) , Nil })
	If !Empty( aCposVV0A[5] )
		aAdd(xSAutoCab,{ "VV0_NATFIN" , aCposVV0A[05]                           , Nil })
	EndIf
	aAdd(xSAutoCab,{ "VV0_CODVEN" , aCposVV0A[06]                               , Nil })
	If VV0->(ColumnPos("VV0_MENPAD")) > 0 .and. !Empty( aCposVV0A[07] )
		aAdd(xSAutoCab,{ "VV0_MENPAD" , aCposVV0A[07]                           , Nil })
	EndIf
	If VV0->(ColumnPos("VV0_MENNOT")) > 0 .and. !Empty( aCposVV0A[08] )
		aAdd(xSAutoCab,{ "VV0_MENNOT" , aCposVV0A[08]                           , Nil })
	EndIf
	If VV0->(ColumnPos("VV0_INDPRE")) > 0 .and. !Empty( aCposVV0A[09] )
		aAdd(xSAutoCab,{ "VV0_INDPRE" , aCposVV0A[09]                           , Nil })
	EndIf
	aAdd(xSAutoCab,{"VV0_TIPMOV", cPro_VEIA                                     , Nil }) // 1=Agregar / 2=Desagregar
	nTotVV0 += nCustoVV1
	VVG->(DbSetOrder(1)) // VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
	VVG->(DbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA + VV1->VV1_CHAINT ))
	xAutoIt := {}
	aAdd(xAutoIt,{ "VVA_FILIAL" , xFilial("VVA")                                , Nil })
	aAdd(xAutoIt,{ "VVA_CHASSI" , VV1->VV1_CHASSI                               , Nil })
	If !Empty( aCposVV0A[10] )
		aAdd(xAutoIt,{ "VVA_CODTES" , aCposVV0A[10]                             , Nil })
	EndIf
	aAdd(xAutoIt,{ "VVA_VALVDA" , VVG->VVG_VALUNI                               , Nil })
	aAdd(xAutoIt,{ "VVA_VALMOV" , nCustoVV1                                     , Nil })
	aAdd(xAutoIt,{ "VVA_CENCUS" , aCposVV0A[11]                                 , Nil })
	aAdd(xAutoIt,{ "VVA_CONTA"  , aCposVV0A[12]                                 , Nil })
	aAdd(xAutoIt,{ "VVA_ITEMCT" , aCposVV0A[13]                                 , Nil })
	aAdd(xAutoIt,{ "VVA_CLVL"   , aCposVV0A[14]                                 , Nil })
	aAdd(xSAutoItens,aClone(xAutoIt))
EndIf
If cPro_VEIA == "1" .and. cIte_VEIA == "1" // Agrega AMS (Saida)
	cQuery := "SELECT VFM_CHAINT , VFM_CODTES , VFM_CENCUS , VFM_CONTA , VFM_ITEMCT , VFM_CLVL , VFM_CUSUNI "
	cQuery += "  FROM "+RetSQLName("VFM")
	cQuery += " WHERE VFM_FILIAL = '"+xFilial("VFM")+"'"
	cQuery += "   AND VFM_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFM_VEIMAQ = '"+cNroVeic+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		VV1->(DbSetOrder(1))
		VV1->(DbSeek(xFilial("VV1")+(cSQLAlias)->( VFM_CHAINT )))
		VVG->(DbSetOrder(1)) // VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
		VVG->(DbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA + VV1->VV1_CHAINT ))
		xAutoIt := {}
		aAdd(xAutoIt,{ "VVA_FILIAL" , xFilial("VVA")                            , Nil })
		aAdd(xAutoIt,{ "VVA_CHASSI" , VV1->VV1_CHASSI                           , Nil })
		If !Empty( (cSQLAlias)->( VFM_CODTES ) )
			aAdd(xAutoIt,{ "VVA_CODTES" , (cSQLAlias)->( VFM_CODTES )           , Nil })
		EndIf
		aAdd(xAutoIt,{ "VVA_VALVDA" , VVG->VVG_VALUNI                           , Nil })
		aAdd(xAutoIt,{ "VVA_VALMOV" , (cSQLAlias)->( VFM_CUSUNI )               , Nil })
		aAdd(xAutoIt,{ "VVA_CENCUS" , (cSQLAlias)->( VFM_CENCUS )               , Nil })
		aAdd(xAutoIt,{ "VVA_CONTA"  , (cSQLAlias)->( VFM_CONTA )                , Nil })
		aAdd(xAutoIt,{ "VVA_ITEMCT" , (cSQLAlias)->( VFM_ITEMCT )               , Nil })
		aAdd(xAutoIt,{ "VVA_CLVL"   , (cSQLAlias)->( VFM_CLVL )                 , Nil })
		aAdd(xSAutoItens,aClone(xAutoIt))
		nTotVV0 += (cSQLAlias)->( VFM_CUSUNI )
		// adicionado para voltar o FILENT após integração que está zerando o campo por motivos que não vamos alterar a função gerla para não ocasionar maiores problemas e esforço.
		If !Empty(VV1->VV1_FILENT)
			AADD(aVltFilDes,{ VV1->(RecNo()) , VV1->VV1_FILENT })
		EndIf
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
EndIf
If cTip_VEIA == "2" // Movimentações Internas
	aAdd(xSAutoCab,{ "VV0_VALMOV" , nTotVV0                                     , Nil })
	aAdd(xSAutoCab,{ "VV0_VALTOT" , nTotVV0                                     , Nil })
EndIf
//
DbSelectArea("SB1")
DbGoTo(nRecSB1)
//
DbSelectArea("VV1")
DbGoTo(nRecVV1)
//
lMsErroAuto := .f.
//
If cTip_VEIA == "1" // Notas Fiscais
	If aNumNFSF2[3] == aNumNFSF1[3] // Mesma Serie de Saida e Entrada
		If aNumNFSF2[2] < aNumNFSF1[2] // Nro da NF é menor que o gerado no SF1
			aNumNFSF2[2] := aNumNFSF1[2]
		EndIf
	EndIf
EndIf
//
MSExecAuto({|x,y,w,z,k,l,m,n,o,p,q| VEIXX001(x,y,w,z,k,l,m,n,o,p,q)},xSAutoCab,xSAutoItens,{},3,"0",NIL,.f.,aNumNFSF2,cTip_VEIA,cCodVDV,"VA3300021_SAIDA_VV0VVA") // SAIDA POR VENDA
//
If lMsErroAuto .or. cDebugMIL == "VEIA330008"
	Return .f.
Else
	For nCntFor := 1 to len(aVltFilDes)
		DbSelectArea("VV1")
		DbGoTo(aVltFilDes[nCntFor,1])
		oModelVV1:SetOperation( MODEL_OPERATION_UPDATE )
		If oModelVV1:Activate()
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_FILENT" , aVltFilDes[nCntFor,2] )
			If ( lRet := oModelVV1:VldData() )
				if ( lRet := oModelVV1:CommitData() )
				EndIf
			EndIf
			oModelVV1:DeActivate()
		EndIf
	Next
EndIf
ConfirmSx8() // Confirm do Nro NF
//
aAdd(aVDV,{ "VDV_FILVV0" , xFilial("VV0")  })
aAdd(aVDV,{ "VDV_NUMTRA" , VV0->VV0_NUMTRA })
If cTip_VEIA == "1" // Notas Fiscais
	aNumNFSF2[2] := SF2->F2_DOC
	aNumNFSF2[3] := SF2->F2_SERIE
	aAdd(aVDV,{ "VDV_SFILNF" , xFilial("SF2")  }) // Filial da NF Saida
	aAdd(aVDV,{ "VDV_SNUMNF" , SF2->F2_DOC     }) // Nro da NF Saida
	aAdd(aVDV,{ "VDV_SSERNF" , SF2->F2_SERIE   }) // Serie da NF Saida
	If VDV->(ColumnPos("VDV_SDOCS")) > 0 .and. SF2->(ColumnPos("F2_SDOC")) > 0
		aAdd(aVDV,{ "VDV_SDOCS" , SF2->F2_SDOC })
	EndIf
	If !Empty(aCposVV0A[15])
		// Gravar campos no SF2
		DbSelectArea("SF2")
		RecLock("SF2",.f.)
			SF2->F2_ESPECIE := aCposVV0A[15] // Especie do Documento
		MsUnLock()
	EndIf
EndIf
//
DbSelectArea("VV1")
DbGoTo(nRecVV1)
oModelVV1:SetOperation( MODEL_OPERATION_UPDATE )
If oModelVV1:Activate()
	oModelVV1:SetValue( "MODEL_VV1" , "VV1_ULTMOV" , "S" ) // Gravar S = SAIDA para nao bloquear ENTRADA
	If ( lRet := oModelVV1:VldData() )
		if ( lRet := oModelVV1:CommitData() )
		EndIf
	EndIf
	oModelVV1:DeActivate()
EndIf
//
DbSelectArea("VV0")
If !Empty(aCposVV0A[16])
	MSMM(VV0->VV0_OBSMNF,TamSx3("VV0_OBSENF")[1],,aCposVV0A[16],1,,,"VV0","VV0_OBSMNF")
EndIf
//
If cTip_VEIA == "1" // Notas Fiscais
	aAdd(aVFK,{ "VFK_NUMNFI" , SF2->F2_DOC })
	aAdd(aVFK,{ "VFK_SERNFI" , SF2->F2_SERIE })
	lRet := VA3200011_MVC_CAD_VFK( nRecNo , aVFK )
	aAdd(aDocTela,{ "BR_VERDE" , Alltrim(SF2->F2_DOC)+"-"+Alltrim(SF2->F2_SERIE) , cTitDoc })
Else // cTip_VEIA == "2" // Movimentações Internas
	aAdd(aDocTela,{ "BR_VERDE" , STR0026 , cTitDoc }) // Mov.Interna
EndIf
//
FreeObj(oModelVV1)
//
Return lRet

/*/{Protheus.doc} VA3300031_ENTRADA_VVFVVG
Criação dos Registros de ENTRADA (VVF/VVG) do VV1

@author Andre Luis Almeida
@since 06/03/2023
/*/
Static Function VA3300031_ENTRADA_VVFVVG( cTpReg , cNroVeic , cCodExe , cPro_VEIA , cTip_VEIA , cIte_VEIA , nRecVV1 , nCustoVV1 , cCodVDV , cTitDoc )
Local lRet        := .t.
Local cQuery      := ""
Local cSQLAlias   := "SQLAUX"
Local xEAutoCab   := {}
Local xEAutoItens := {}
Local xAutoIt     := {}
Local aVFL        := {}
Local nRecSB1     := 0
Local nRecNo      := 0
Local nTotVVF     := 0
Local cGruVei     := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Local cLocPad     := ""
Local oModelVV1   := FWLoadModel( 'VEIA070' ) // VV1
Local aSM0        := {}
Local aCposVVFG   := {}
//
DbSelectArea("VV1")
DbGoTo(nRecVV1)
FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
nRecSB1 := SB1->(RecNo())
SB1->(dbSetOrder(1))
//
If cTip_VEIA == "1" // Notas Fiscais
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFL")
	cQuery += " WHERE VFL_FILIAL = '"+xFilial("VFL")+"'"
	cQuery += "   AND VFL_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFL_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFL_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		VFL->(DbGoTo(nRecNo))
		aadd( aCposVVFG , VFL->VFL_CODFOR ) // 01 - Código do Fornecedor
		aadd( aCposVVFG , VFL->VFL_LOJFOR ) // 02 - Loja do Fornecedor
		aadd( aCposVVFG , VFL->VFL_FORPAG ) // 03 - Forma de Pagamento
		aadd( aCposVVFG , VFL->VFL_NATURE ) // 04 - Natureza
		aadd( aCposVVFG , VFL->VFL_CODESP ) // 05 - Especie
		aadd( aCposVVFG , VFL->VFL_MENPAD ) // 06 - Mensagem Padrão
		aadd( aCposVVFG , VFL->VFL_MENNOT ) // 07 - Mensagem Nota
		aadd( aCposVVFG , VFL->VFL_CODTES ) // 08 - TES
		aadd( aCposVVFG , VFL->VFL_CENCUS ) // 09 - Centro de Custo
		aadd( aCposVVFG , VFL->VFL_CONTA  ) // 10 - Conta Contabil
		aadd( aCposVVFG , VFL->VFL_ITEMCT ) // 11 - Item Conta Contabil
		aadd( aCposVVFG , VFL->VFL_CLVL   ) // 12 - Classe Valor
		aadd( aCposVVFG , VFL->VFL_OBSNOT ) // 13 - Observação NF
	EndIf
Else // cTip_VEIA == "2" // Movimentações Internas
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFO")
	cQuery += " WHERE VFO_FILIAL = '"+xFilial("VFO")+"'"
	cQuery += "   AND VFO_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFO_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFO_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		VFO->(DbGoTo(nRecNo))
		aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt)
		SA2->(DbSetOrder(3))
		IIf(!SA2->(DbSeek(xFilial("SA2")+aSM0[SM0_CGC])),SA2->(DbSeek(xFilial("SA2")+left(aSM0[SM0_CGC],8))),.t.)
		SA2->(DbSetOrder(1))
		aadd( aCposVVFG , SA2->A2_COD     ) // 01 - Código do Fornecedor
		aadd( aCposVVFG , SA2->A2_LOJA    ) // 02 - Loja do Fornecedor
		aadd( aCposVVFG , ""              ) // 03 - Forma de Pagamento
		aadd( aCposVVFG , ""              ) // 04 - Natureza
		aadd( aCposVVFG , ""              ) // 05 - Especie
		aadd( aCposVVFG , ""              ) // 06 - Mensagem Padrão
		aadd( aCposVVFG , ""              ) // 07 - Mensagem Nota
		aadd( aCposVVFG , ""              ) // 08 - TES
		aadd( aCposVVFG , VFO->VFO_CENCUS ) // 09 - Centro de Custo
		aadd( aCposVVFG , VFO->VFO_CONTA  ) // 10 - Conta Contabil
		aadd( aCposVVFG , VFO->VFO_ITEMCT ) // 11 - Item Conta Contabil
		aadd( aCposVVFG , VFO->VFO_CLVL   ) // 12 - Classe Valor
		aadd( aCposVVFG , ""              ) // 13 - Observação NF
	EndIf
EndIf
//
If len(aCposVVFG) > 0
	cLocPad := IIf(!Empty(VV1->VV1_LOCPAD) , VV1->VV1_LOCPAD , IIf(VV1->VV1_ESTVEI<>'1',GETMV("MV_LOCVEIN"),GETMV("MV_LOCVEIU")) ) // Novo / Usado
	aAdd(xEAutoCab,{ "VVF_FILIAL" , xFilial("VVF")                              , Nil })
	aAdd(xEAutoCab,{ "VVF_FORPRO" , "1"                                         , Nil })
	aAdd(xEAutoCab,{ "VVF_CLIFOR" , "F"                                         , Nil })
	aAdd(xEAutoCab,{ "VVF_CODFOR" , aCposVVFG[01]                               , Nil })
	aAdd(xEAutoCab,{ "VVF_LOJA "  , aCposVVFG[02]                               , Nil })
	aAdd(xEAutoCab,{ "VVF_DATEMI" , dDataBase                                   , Nil })
	aAdd(xEAutoCab,{ "VVF_FORPAG" , IIf(!Empty(aCposVVFG[03]),aCposVVFG[03],RetCondVei()) , Nil })
	If !Empty( aCposVVFG[04] )
		aAdd(xEAutoCab,{ "VVF_NATURE" , aCposVVFG[04]                           , Nil })
	EndIf
	If !Empty( aCposVVFG[05] )
		aAdd(xEAutoCab,{ "VVF_ESPECI" , aCposVVFG[05]                           , Nil })
	EndIf
	If VVF->(ColumnPos("VVF_MENPAD")) > 0 .and. !Empty( aCposVVFG[06] )
		aAdd(xEAutoCab,{ "VVF_MENPAD" , aCposVVFG[06]                           , Nil })
	EndIf
	If VVF->(ColumnPos("VVF_MENNOT")) > 0 .and. !Empty( aCposVVFG[07] )
		aAdd(xEAutoCab,{ "VVF_MENNOT" , aCposVVFG[07]                           , Nil })
	EndIf
	aAdd(xEAutoCab,{"VVF_TIPMOV", cPro_VEIA                                     , Nil }) // 1=Agregar / 2=Desagregar
	nTotVVF += nCustoVV1
	xAutoIt := {}
	aAdd(xAutoIt,{ "VVG_FILIAL" , xFilial("VVG")                                , Nil })
	aAdd(xAutoIt,{ "VVG_CHAINT" , VV1->VV1_CHAINT                               , Nil })
	aAdd(xAutoIt,{ "VVG_CHASSI" , VV1->VV1_CHASSI                               , Nil })
	If !Empty( aCposVVFG[08] )
		aAdd(xAutoIt,{ "VVG_CODTES" , aCposVVFG[08]                             , Nil })
	EndIf
	aAdd(xAutoIt,{ "VVG_LOCPAD" , cLocPad                                       , Nil })
	aAdd(xAutoIt,{ "VVG_VALUNI" , nCustoVV1                                     , Nil })
	aAdd(xAutoIt,{ "VVG_ESTVEI" , VV1->VV1_ESTVEI                               , Nil })
	aAdd(xAutoIt,{ "VVG_CODORI" , VV1->VV1_CODORI                               , Nil })
	aAdd(xAutoIt,{ "VVG_SITTRI" , VV1->VV1_PROVEI                               , Nil })
	aAdd(xAutoIt,{ "VVG_CENCUS" , aCposVVFG[09]                                 , Nil })
	aAdd(xAutoIt,{ "VVG_CONTA"  , aCposVVFG[10]                                 , Nil })
	aAdd(xAutoIt,{ "VVG_ITEMCT" , aCposVVFG[11]                                 , Nil })
	aAdd(xAutoIt,{ "VVG_CLVL"   , aCposVVFG[12]                                 , Nil })
	aAdd(xEAutoItens,aClone(xAutoIt))
EndIf
If cPro_VEIA == "2" .and. cIte_VEIA == "1" // Desagrega AMS (Entrada)
	cQuery := "SELECT VFP_CHAINT , VFP_CODTES , VFP_CENCUS , VFP_CONTA , VFP_ITEMCT , VFP_CLVL , VFP_CUSUNI "
	cQuery += "  FROM "+RetSQLName("VFP")
	cQuery += " WHERE VFP_FILIAL = '"+xFilial("VFP")+"'"
	cQuery += "   AND VFP_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFP_VEIMAQ = '"+cNroVeic+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		VV1->(DbSetOrder(1))
		VV1->(DbSeek(xFilial("VV1")+(cSQLAlias)->( VFP_CHAINT )))
		if empty ( VV1->VV1_GRASEV )
			DbSelectArea("VV1")
			oModelVV1:SetOperation( MODEL_OPERATION_UPDATE )
			If oModelVV1:Activate()
				oModelVV1:SetValue( "MODEL_VV1" , "VV1_GRASEV" , "6" )
				If oModelVV1:VldData()
					oModelVV1:CommitData()
				EndIf
				oModelVV1:DeActivate()
			EndIf
		endif

		cLocPad := IIf( !Empty(VV1->VV1_LOCPAD) , VV1->VV1_LOCPAD , IIf(VV1->VV1_ESTVEI<>'1',GETMV("MV_LOCVEIN"),GETMV("MV_LOCVEIU")) ) // Novo / Usado
		xAutoIt := {}
		aAdd(xAutoIt,{ "VVG_FILIAL" , xFilial("VVG")                            , Nil })
		aAdd(xAutoIt,{ "VVG_CHAINT" , VV1->VV1_CHAINT                           , Nil })
		aAdd(xAutoIt,{ "VVG_CHASSI" , VV1->VV1_CHASSI                           , Nil })
		If !Empty( (cSQLAlias)->( VFP_CODTES ) )
			aAdd(xAutoIt,{ "VVG_CODTES" , (cSQLAlias)->( VFP_CODTES )           , Nil })
		EndIf
		aAdd(xAutoIt,{ "VVG_LOCPAD" , cLocPad                                   , Nil })
		aAdd(xAutoIt,{ "VVG_VALUNI" , (cSQLAlias)->( VFP_CUSUNI )               , Nil })
		aAdd(xAutoIt,{ "VVG_ESTVEI" , VV1->VV1_ESTVEI                           , Nil })
		aAdd(xAutoIt,{ "VVG_CODORI" , VV1->VV1_CODORI                           , Nil })
		aAdd(xAutoIt,{ "VVG_SITTRI" , VV1->VV1_PROVEI                           , Nil })
		aAdd(xAutoIt,{ "VVG_CENCUS" , (cSQLAlias)->( VFP_CENCUS )               , Nil })
		aAdd(xAutoIt,{ "VVG_CONTA"  , (cSQLAlias)->( VFP_CONTA )                , Nil })
		aAdd(xAutoIt,{ "VVG_ITEMCT" , (cSQLAlias)->( VFP_ITEMCT )               , Nil })
		aAdd(xAutoIt,{ "VVG_CLVL"   , (cSQLAlias)->( VFP_CLVL )                 , Nil })
		aAdd(xEAutoItens,aClone(xAutoIt))
		nTotVVF += (cSQLAlias)->( VFP_CUSUNI )
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
EndIf
//
If cTip_VEIA == "2" // Movimentações Internas
	aAdd(xEAutoCab,{ "VVF_VALMOV" , nTotVVF                                     , Nil })
EndIf
//
DbSelectArea("SB1")
DbGoTo(nRecSB1)
//
DbSelectArea("VV1")
DbGoTo(nRecVV1)
//
If cTip_VEIA == "1" // Notas Fiscais
	cSerie  := aNumNFSF1[3]
	cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
	aNumNFSF1[2] := cNumero
	If aNumNFSF1[3] == aNumNFSF2[3] // Mesma Serie de Entrada e Saida
		aNumNFSF1[2] := IIf( aNumNFSF1[2]<aNumNFSF2[2] , aNumNFSF2[2] ,aNumNFSF1[2] ) // Nro da NF é menor que o gerado no SF2
	EndIf
EndIf
//
lMsErroAuto := .f.
//
MSExecAuto({|x,y,w,z,k,l,m,n,o,p,q| VEIXX000(x,y,w,z,k,l,m,n,o,p,q)},xEAutoCab,xEAutoItens,{},3,"0",NIL,.f.,aNumNFSF1,cTip_VEIA,cCodVDV,"VA3300031_ENTRADA_VVFVVG") // ENTRADA POR COMPRA
//
If lMsErroAuto .or. cDebugMIL == "VEIA330009"
	Return .f.
EndIf
//
ConfirmSx8() // Confirm do Nro NF
//
aAdd(aVDV,{ "VDV_FILVVF" , xFilial("VVF")  })
aAdd(aVDV,{ "VDV_TRACPA" , VVF->VVF_TRACPA })
If cTip_VEIA == "1" // Notas Fiscais
	aNumNFSF1[2] := SF1->F1_DOC
	aNumNFSF1[3] := SF1->F1_SERIE
	aAdd(aVDV,{ "VDV_EFILNF" , xFilial("SF1")  }) // Filial da NF Entrada
	aAdd(aVDV,{ "VDV_ENUMNF" , SF1->F1_DOC     }) // Nro da NF Entrada
	aAdd(aVDV,{ "VDV_ESERNF" , SF1->F1_SERIE   }) // Serie da NF Entrada
	aAdd(aVDV,{ "VDV_ECDFOR" , SF1->F1_FORNECE }) // Fornecedor
	aAdd(aVDV,{ "VDV_ELJFOR" , SF1->F1_LOJA    }) // Loja
	If VDV->(ColumnPos("VDV_SDOCE")) > 0 .and. SF1->(ColumnPos("F1_SDOC")) > 0
		aAdd(aVDV,{ "VDV_SDOCE" , SF1->F1_SDOC })
	EndIf
EndIf
//
DbSelectArea("VV1")
DbGoTo(nRecVV1)
oModelVV1:SetOperation( MODEL_OPERATION_UPDATE )
If oModelVV1:Activate()
	oModelVV1:SetValue( "MODEL_VV1" , "VV1_ULTMOV" , "E" ) // Gravar E = ENTRADA para nao bloquear SAIDA
	If ( lRet := oModelVV1:VldData() )
		if ( lRet := oModelVV1:CommitData() )
		EndIf
	EndIf
	oModelVV1:DeActivate()
EndIf
//
DbSelectArea("VVF")
If !Empty(aCposVVFG[13])
	MSMM(VVF->VVF_OBSMNF,TamSx3("VVF_OBSENF")[1],,aCposVVFG[13],1,,,"VVF","VVF_OBSMNF")
EndIf
//
If cTip_VEIA == "1" // Notas Fiscais
	aAdd(aVFL,{ "VFL_NUMNFI" , SF1->F1_DOC })
	aAdd(aVFL,{ "VFL_SERNFI" , SF1->F1_SERIE })
	lRet := VA3210011_MVC_CAD_VFL( nRecNo , aVFL )
	aAdd(aDocTela,{ "BR_VERDE" , Alltrim(SF1->F1_DOC)+"-"+Alltrim(SF1->F1_SERIE) , cTitDoc })
Else // cTip_VEIA == "2" // Movimentações Internas
	aAdd(aDocTela,{ "BR_VERDE" , STR0026 , cTitDoc }) // Mov.Interna
EndIf
//
FreeObj(oModelVV1)
//
Return lRet

/*/{Protheus.doc} VA3300041_Selecionar_Serie_NFs
Selecionar as Series das Notas Fiscais

@author Andre Luis Almeida
@since 06/03/2023
/*/
Static Function VA3300041_Selecionar_Serie_NFs()
Local lRet := .t.
If lRet
	lRet := .f.
	If MsgYesNo(STR0021,STR0020) // Deseja selecionar a SERIE da NF de SAIDA do Veículo/Máquina/Equipamento? / Atencao
		lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio SAIDA
		cNumero := IIf( GetNewPar("MV_TPNRNFS","1") == "3" , "" , cNumero )
		aNumNFSF2 := {.f.,cNumero,cSerie}
	EndIf
EndIf
If lRet .and. VFJ->VFJ_TIPITE == "2" .and. VFJ->VFJ_PROCES $ "1/3/4" // 2=PEÇAS e 1=Agrega(Individual)/3=Transferencia/4=Troca  
	lRet := .f.
	If MsgYesNo(STR0022,STR0020) // Deseja selecionar a SERIE da NF de SAIDA da(s) Peca(s)? / Atencao
		lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio SAIDA
		cNumero := IIf( GetNewPar("MV_TPNRNFS","1") == "3" , "" , cNumero )
		aIteNFSF2 := {.f.,cNumero,cSerie}
	EndIf
EndIf
If lRet
	lRet := .f.
	If MsgYesNo(STR0023,STR0020) // Deseja selecionar a SERIE da NF de ENTRADA do Veículo/Máquina/Equipamento? / Atencao
		lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio ENTRADA
		cNumero := IIf( GetNewPar("MV_TPNRNFS","1") == "3" , "" , cNumero )
		aNumNFSF1 := {.f.,cNumero,cSerie}
	EndIf
EndIf
If lRet .and. VFJ->VFJ_TIPITE == "2" .and. VFJ->VFJ_PROCES $ "2/3/4" // 2=PEÇAS e 2=Desagrega(Individual)/3=Transferencia/4=Troca  
	lRet := .f.
	If MsgYesNo(STR0024,STR0020) // Deseja selecionar a SERIE da NF de ENTRADA da(s) Peca(s)? / Atencao
		lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio ENTRADA
		cNumero := IIf( GetNewPar("MV_TPNRNFS","1") == "3" , "" , cNumero )
		aIteNFSF1 := {.f.,cNumero,cSerie}
	EndIf
EndIf
If lRet
	cNumero := aNumNFSF2[2]
	cSerie  := aNumNFSF2[3]
EndIf
Return lRet

/*/{Protheus.doc} VA3300051_SAIDA_PECAS
Gera SAIDA das Peças

@author Andre Luis Almeida
@since 14/03/2023
/*/
Static Function VA3300051_SAIDA_PECAS( cTpReg , cNroVeic , cCodExe , cPro_VEIA , cTip_VEIA , cIte_VEIA , cCodVDV , cTitDoc )
Local cQuery      := ""
Local cSQLAlias   := "SQLAUX"
Local cNumIte     := strzero(0,GetSX3Cache("C6_ITEM","X3_TAMANHO"))
Local nRecNo      := 0
Local nQtdLib     := 0
Local cNumPed     := ""
Local cMsgSC9     := ""
Local lCredito    := .t.
Local lEstoque    := .t.
Local lLiber      := .t.
Local lTransf     := .f.
Local aPvlNfs     := {}
Local aVFK        := {}
Local aSB1SD3     := {}
Local xAutoIt     := {}
Private xSAutoCab   := {} // Private para ser possivel manipular no Ponto de Entrada VXX040PV
Private xSAutoItens := {} // Private para ser possivel manipular no Ponto de Entrada VXX040PV
//
If cTip_VEIA == "1" // 1=Notas Fiscais
	//
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFK")
	cQuery += " WHERE VFK_FILIAL = '"+xFilial("VFK")+"'"
	cQuery += "   AND VFK_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFK_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFK_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		VFK->(DbGoTo(nRecNo))
		//
		aAdd(xSAutoCab,{ "C5_TIPO"    , "N"                                     , Nil })
		aAdd(xSAutoCab,{ "C5_CLIENTE" , VFK->VFK_CODCLI                         , Nil })
		aAdd(xSAutoCab,{ "C5_LOJACLI" , VFK->VFK_LOJCLI                         , Nil })
		aAdd(xSAutoCab,{ "C5_VEND1"   , VFK->VFK_CODVEN                         , Nil })
		aAdd(xSAutoCab,{ "C5_CONDPAG" , IIf(!Empty(VFK->VFK_FORPAG),VFK->VFK_FORPAG,RetCondVei()) , Nil })
		aAdd(xSAutoCab,{ "C5_COMIS1"  , 0                                       , Nil })
		aAdd(xSAutoCab,{ "C5_EMISSAO" , ddatabase                               , Nil })
		If !Empty( VFK->VFK_MENPAD )
			aAdd(xSAutoCab,{ "C5_MENPAD"  , VFK->VFK_MENPAD                     , Nil })
		EndIf
		If !Empty( VFK->VFK_MENNOT )
			aAdd(xSAutoCab,{ "C5_MENNOTA" , VFK->VFK_MENNOT                     , Nil })
		EndIf
		aAdd(xSAutoCab,{ "C5_BANCO"   , VFK->VFK_CODBCO                         , Nil })
		If !Empty(VFK->VFK_NATURE) .and. SC5->(ColumnPos("C5_NATUREZ")) > 0
			aAdd(xSAutoCab,{ "C5_NATUREZ" , VFK->VFK_NATURE                     , Nil })
		EndIf
		aAdd(xSAutoCab,{ "C5_TIPOCLI" , FM_SQL("SELECT A1_TIPO FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+VFK->VFK_CODCLI+"' AND A1_LOJA='"+VFK->VFK_LOJCLI+"' AND D_E_L_E_T_=' '") , Nil })
		If SC5->(ColumnPos( "C5_INDPRES" )) > 0 .and. !Empty( VFK->VFK_PRECPA )
			aAdd(xSAutoCab,{ "C5_INDPRES" , VFK->VFK_PRECPA                     , Nil })
		EndIf
		//
		cQuery := "SELECT VFN_CODSB1 , VFN_CODTES , VFN_CENCUS , VFN_CONTA , VFN_ITEMCT , VFN_CLVL , VFN_QUANT , VFN_CUSUNI "
		cQuery += "  FROM "+RetSQLName("VFN")
		cQuery += " WHERE VFN_FILIAL = '"+xFilial("VFN")+"'"
		cQuery += "   AND VFN_CODEXE = '"+cCodExe+"'"
		cQuery += "   AND VFN_VEIMAQ = '"+cNroVeic+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
		While !(cSQLAlias)->(Eof())
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+(cSQLAlias)->( VFN_CODSB1 )))
			xAutoIt := {}
			cNumIte := SOMA1(cNumIte)
			aAdd(xAutoIt,{ "C6_ITEM"    , cNumIte                                                  , nil })
			aAdd(xAutoIt,{ "C6_PRODUTO" , SB1->B1_COD                                              , nil })
			aAdd(xAutoIt,{ "C6_QTDVEN"  , (cSQLAlias)->( VFN_QUANT )                               , nil })
			aAdd(xAutoIt,{ "C6_ENTREG"  , dDataBase                                                , nil })
			aAdd(xAutoIt,{ "C6_UM"      , SB1->B1_UM                                               , nil })
			aAdd(xAutoIt,{ "C6_TES"     , (cSQLAlias)->( VFN_CODTES )                              , nil })
			aAdd(xAutoIt,{ "C6_LOCAL"   , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")                 , nil })
			aAdd(xAutoIt,{ "C6_PRUNIT"  , round((cSQLAlias)->( VFN_CUSUNI ),2)                     , nil })
			aAdd(xAutoIt,{ "C6_PRCVEN"  , round((cSQLAlias)->( VFN_CUSUNI ),2)                     , nil })
			aAdd(xAutoIt,{ "C6_VALOR"   , round((cSQLAlias)->( VFN_CUSUNI ) * (cSQLAlias)->( VFN_QUANT ),2) , nil })
			aAdd(xAutoIt,{ "C6_VALDESC" , 0                                                        , nil })
			aAdd(xAutoIt,{ "C6_COMIS1"  , 0                                                        , nil })
			aAdd(xAutoIt,{ "C6_CLI"     , VFK->VFK_CODCLI                                          , nil })
			aAdd(xAutoIt,{ "C6_LOJA"    , VFK->VFK_LOJCLI                                          , nil })
			aAdd(xAutoIt,{ "C6_CC"      , (cSQLAlias)->( VFN_CENCUS )                              , nil })
			aAdd(xAutoIt,{ "C6_CONTA"   , (cSQLAlias)->( VFN_CONTA )                               , nil })
			aAdd(xAutoIt,{ "C6_ITEMCTA" , (cSQLAlias)->( VFN_ITEMCT )                              , nil })
			aAdd(xAutoIt,{ "C6_CLVL"    , (cSQLAlias)->( VFN_CLVL )                                , nil })
			aAdd(xSAutoItens,aClone(xAutoIt))
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		//
		// Ponto de Entrada antes do Pedido de Venda - Possibilidade de alterar os vetores xSAutoCab e xSAutoItens que são private
		// 
		If ExistBlock("VXX040PV")
			ExecBlock("VXX040PV",.f.,.f.)
		Endif
		//
		DbSelectArea("VFK")
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z|Mata410(x,y,z)},xSAutoCab,xSAutoItens,3)
		If lMsErroAuto .or. cDebugMIL == "VEIA330010"
			DisarmTransaction()
			MostraErro()
			Return .f.
		EndIf
		//
		cNumPed := SC5->C5_NUM
		//
		lCredito := .t.
		lEstoque := .t.
		lLiber   := .t.
		lTransf  := .f.
		//
		SC9->(dbSetOrder(1))
		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xFilial("SC6") + cNumPed + "01"))
		While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
			//
			If !SC9->(dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
				nQtdLib := SC6->C6_QTDVEN
				nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.t.,lLiber,lTransf)
			EndIf
			//
			SC6->(dbSkip())
		Enddo
		//
		aPvlNfs := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Selecionando Itens para Faturamento ... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsgSC9 := ""
		SB1->(dbSetOrder(1))
		SC5->(dbSetOrder(1))
		SC6->(dbSetOrder(1))
		SB5->(dbSetOrder(1))
		SB2->(dbSetOrder(1))
		SF4->(dbSetOrder(1))
		SE4->(dbSetOrder(1))
		SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
		While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
			If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
				SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
				SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
				SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
				SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
				SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
				SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
				SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
				aAdd(aPvlNfs,{	SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								SC9->C9_PRCVEN,;
								SC9->C9_PRODUTO,;
								.F.,;
								SC9->(RecNo()),;
								SC5->(RecNo()),;
								SC6->(RecNo()),;
								SE4->(RecNo()),;
								SB1->(RecNo()),;
								SB2->(RecNo()),;
								SF4->(RecNo())})
			EndIf
			cMsgSC9 += IIf(!Empty(SC9->C9_BLCRED),AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13)+CHR(10),"")
			cMsgSC9 += IIf(!Empty(SC9->C9_BLEST) ,AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST")) +": "+SC9->C9_BLEST +CHR(13)+CHR(10),"")
			SC9->(dbSkip())
		Enddo
		If !Empty(cMsgSC9) .or. ( len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.)) .or. cDebugMIL == "VEIA330011" // Verifica SC5 bloqueado
			If !Empty(cMsgSC9) .or. cDebugMIL == "VEIA330011"
				MsgStop(STR0025+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0020) // Pedido sem itens liberados! / Atenção
			EndIf
			DisarmTransaction()
			Return .f.
		EndIf
		//
		ConfirmSx8()
		//
		cNumero := aIteNFSF2[2]
		cSerie  := aIteNFSF2[3]
		If Len(aPvlNfs) > 0
			PERGUNTE("MT460A",.f.)
			cNota := MaPvlNfs(aPvlNfs,cSerie,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
		EndIf
		//
		if lMsErroAuto .or. cDebugMIL == "VEIA330012"
			DisarmTransaction()
			MostraErro()
			Return .f.
		Endif
		//
		ConfirmSx8() // Confirm do Nro NF
		//
		cNumero := aIteNFSF2[2] := SF2->F2_DOC
		//
		aAdd(aVFK,{ "VFK_NUMNFI" , SF2->F2_DOC })
		aAdd(aVFK,{ "VFK_SERNFI" , SF2->F2_SERIE })
		If !VA3200011_MVC_CAD_VFK( nRecNo , aVFK ) .or. cDebugMIL == "VEIA330013"
			Return .f.
		Endif
		//
		aAdd(aVDV,{ "VDV_SNUMNP" , SF2->F2_DOC   }) // Nro da NF Saida de Pecas
		aAdd(aVDV,{ "VDV_SSERNP" , SF2->F2_SERIE }) // Serie da NF Saida de Pecas
		//
		// Gravar campos no SF2
		DbSelectArea("SF2")
		RecLock("SF2",.f.)
			If Empty(SF2->F2_PREFORI)
				SF2->F2_PREFORI := GetNewPar("MV_PREFBAL","BAL") // Prefixo de Origem
			EndIf
			SF2->F2_DUPL := IIf( Empty(SF2->F2_DUPL) .and. FMX_VALFIN( SF2->F2_PREFIXO , SF2->F2_DOC , SF2->F2_CLIENTE , SF2->F2_LOJA ) <> 0 , SF2->F2_DOC , SF2->F2_DUPL ) // Nro Duplicata - Titulo
			If !Empty(VFK->VFK_CODESP)
				SF2->F2_ESPECIE := VFK->VFK_CODESP // Especie do Documento
			EndIf
		MsUnLock()
		//
		If !Empty(SF2->F2_DUPL)
			//
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL)
			While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO==SF2->F2_PREFIXO .and. SE1->E1_NUM==SF2->F2_DUPL
				If !( SE1->E1_TIPO $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT )
					If Empty(SE1->E1_PREFORI) .and. !Empty(SF2->F2_PREFORI)
						// Gravar campos no SE1
						RecLock("SE1",.f.)
							SE1->E1_PREFORI := SF2->F2_PREFORI // Prefixo de Origem
						MsUnLock()
					EndIf
				EndIf
				DbSelectArea("SE1")
				DbSkip()
			EndDo
			//
		EndIf
		//
		aAdd(aDocTela,{ "BR_VERDE" , Alltrim(SF2->F2_DOC)+"-"+Alltrim(SF2->F2_SERIE) , cTitDoc })
		//
	EndIf

Else // 2=Movimentações Internas -> Geração do SD3

	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFO")
	cQuery += " WHERE VFO_FILIAL = '"+xFilial("VFO")+"'"
	cQuery += "   AND VFO_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFO_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFO_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND VFO_TIPMOV <> ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo == 0 .or. cDebugMIL == "VEIA330014"
		Return .f.
	Else
		VFO->(DbGoTo(nRecNo))
	EndIf
	cQuery := "SELECT VFN_CODSB1 , VFN_CENCUS , VFN_CONTA , VFN_ITEMCT , VFN_CLVL , VFN_QUANT , VFN_CUSUNI "
	cQuery += "  FROM "+RetSQLName("VFN")
	cQuery += " WHERE VFN_FILIAL = '"+xFilial("VFN")+"'"
	cQuery += "   AND VFN_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFN_VEIMAQ = '"+cNroVeic+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		aAdd(aSB1SD3,{	(cSQLAlias)->( VFN_CODSB1 )                                           ,; // Codigo SB1
						(cSQLAlias)->( VFN_QUANT )                                            ,; // Qtde
						round( (cSQLAlias)->( VFN_QUANT ) * (cSQLAlias)->( VFN_CUSUNI ) , 2 ) ,; // Valor Total
						(cSQLAlias)->( VFN_CENCUS )                                           ,; // Centro de Custo
						(cSQLAlias)->( VFN_CONTA )                                            ,; // Conta Contabil
						(cSQLAlias)->( VFN_ITEMCT )                                           ,; // Item Conta
						(cSQLAlias)->( VFN_CLVL )                                             }) // Classe Valor
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VFO")
	If len(aSB1SD3) > 0 
		If !VA3300071_Movimentacoes_Internas( "2" , "1" , cCodVDV , VFO->VFO_TIPMOV , aSB1SD3 ) .or. cDebugMIL == "VEIA330015" // Mov.Interna Peça ( 2=Saida , 1=Tp.Normal , Codigo VDV , Tp.Movimento , aSB1 )
			Return .f.
		EndIf
		aAdd(aDocTela,{ "BR_VERDE" , STR0026 , cTitDoc }) // Mov.Interna
	EndIf

EndIf

Return .t.

/*/{Protheus.doc} VA3300061_ENTRADA_PECAS
Gera ENTRADA das Peças

@author Andre Luis Almeida
@since 20/03/2023
/*/
Static Function VA3300061_ENTRADA_PECAS( cTpReg , cNroVeic , cCodExe , cPro_VEIA , cTip_VEIA , cIte_VEIA , cCodVDV , cTitDoc )
Local xEAutoCab   := {}
Local xEAutoItens := {}
Local xAutoIt     := {}
Local cQuery      := ""
Local cSQLAlias   := "SQLAUX"
Local cNumIte     := strzero(0,GetSX3Cache("D1_ITEM","X3_TAMANHO"))
Local nRecNo      := 0
Local aVFL        := {}
Local aSB1SD3     := {}
//
If cTip_VEIA == "1" // 1=Notas Fiscais
	//
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFL")
	cQuery += " WHERE VFL_FILIAL = '"+xFilial("VFL")+"'"
	cQuery += "   AND VFL_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFL_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFL_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		VFL->(DbGoTo(nRecNo))
		//
		cSerie  := aIteNFSF1[3]
		cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
		aIteNFSF1[2] := cNumero
		//
		aAdd(xEAutoCab,{ "F1_TIPO"    , "N"                                     , Nil })
		aAdd(xEAutoCab,{ "F1_FORMUL"  , "S"                                     , Nil })
		aAdd(xEAutoCab,{ "F1_DOC"     , cNumero                                 , Nil })
		aAdd(xEAutoCab,{ "F1_SERIE"   , cSerie                                  , Nil })
		aAdd(xEAutoCab,{ "F1_EMISSAO" , ddatabase                               , Nil })
		aAdd(xEAutoCab,{ "F1_FORNECE" , VFL->VFL_CODFOR                         , Nil })
		aAdd(xEAutoCab,{ "F1_LOJA"    , VFL->VFL_LOJFOR                         , Nil })
		aAdd(xEAutoCab,{ "F1_ESPECIE" , VFL->VFL_CODESP                         , Nil })
		aAdd(xEAutoCab,{ "F1_COND"    , IIf(!Empty(VFL->VFL_FORPAG),VFL->VFL_FORPAG,RetCondVei()) , Nil })
		aAdd(xEAutoCab,{ "F1_EST"     , FM_SQL("SELECT A2_EST FROM "+RetSQLName("SA2")+" WHERE A2_FILIAL='"+xFilial("SA2")+"' AND A2_COD='"+VFL->VFL_CODFOR+"' AND A2_LOJA='"+VFL->VFL_LOJFOR+"' AND D_E_L_E_T_=' '") , Nil })
		If !Empty( VFL->VFL_MENPAD )
			aAdd(xEAutoCab,{ "F1_MENPAD"  , VFL->VFL_MENPAD                     , Nil })
		EndIf
		If !Empty( VFL->VFL_MENNOT )
			aAdd(xEAutoCab,{ "F1_MENNOTA" , VFL->VFL_MENNOT                     , Nil })
		EndIf
		//
		cQuery := "SELECT VFQ_CODSB1 , VFQ_CODTES , VFQ_CENCUS , VFQ_CONTA , VFQ_ITEMCT , VFQ_CLVL , VFQ_QUANT , VFQ_CUSUNI "
		cQuery += "  FROM "+RetSQLName("VFQ")
		cQuery += " WHERE VFQ_FILIAL = '"+xFilial("VFQ")+"'"
		cQuery += "   AND VFQ_CODEXE = '"+cCodExe+"'"
		cQuery += "   AND VFQ_VEIMAQ = '"+cNroVeic+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
		While !(cSQLAlias)->(Eof())
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+(cSQLAlias)->( VFQ_CODSB1 )))
			xAutoIt := {}
			cNumIte := SOMA1(cNumIte)
			aAdd(xAutoIt,{ "D1_ITEM"    , cNumIte	                                                            , Nil })
			aAdd(xAutoIt,{ "D1_COD"     , SB1->B1_COD                                                           , Nil })
			aAdd(xAutoIt,{ "D1_UM"      , SB1->B1_UM	                                                        , Nil })
			aAdd(xAutoIt,{ "D1_QUANT"   , (cSQLAlias)->( VFQ_QUANT )                                            , Nil })
			aAdd(xAutoIt,{ "D1_VUNIT"   , (cSQLAlias)->( VFQ_CUSUNI )                                           , Nil })
			aAdd(xAutoIt,{ "D1_TOTAL"   , round( (cSQLAlias)->( VFQ_CUSUNI ) * (cSQLAlias)->( VFQ_QUANT ) , 2 ) , Nil })
			aAdd(xAutoIt,{ "D1_EMISSAO" , dDataBase                                                             , Nil })
			aAdd(xAutoIt,{ "D1_LOCAL"   , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")                              , Nil })
			aAdd(xAutoIt,{ "D1_TES"     , (cSQLAlias)->( VFQ_CODTES )                                           , Nil })
			aAdd(xAutoIt,{ "D1_CC"      , (cSQLAlias)->( VFQ_CENCUS )                                           , Nil })
			aAdd(xAutoIt,{ "D1_CONTA"   , (cSQLAlias)->( VFQ_CONTA )                                            , Nil })
			aAdd(xAutoIt,{ "D1_ITEMCTA" , (cSQLAlias)->( VFQ_ITEMCT )                                           , Nil })
			aAdd(xAutoIt,{ "D1_CLVL"    , (cSQLAlias)->( VFQ_CLVL )                                             , Nil })
			aAdd(xEAutoItens,aClone(xAutoIt))
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		DbSelectArea("VFL")
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| MATA103(x,y,z)},xEAutoCab,xEAutoItens,3)
		If lMsErroAuto .or. cDebugMIL == "VEIA330016"
			lMostraErro	:=.T.
			RollBAckSx8()
			DisarmTransaction()
			MostraErro()
			Return .f.
		EndIf
		//
		ConfirmSx8() // Confirm do Nro NF
		//
		if GetNewPar("MV_TPNRNFS","1") <> "3"
			DbSelectArea("SF1")
			DbSetOrder(1)
			DbSeek( xFilial("SF1") + padr(cNumero,GetSX3Cache("F1_DOC","X3_TAMANHO")) + padr(cSerie,GetSX3Cache("F1_SERIE","X3_TAMANHO")) + VFL->VFL_CODFOR + VFL->VFL_LOJFOR )
		Endif
		//
		aIteNFSF1[2] := SF1->F1_DOC
		aIteNFSF1[3] := SF1->F1_SERIE
		//
		aAdd(aVFL,{ "VFL_NUMNFI" , SF1->F1_DOC })
		aAdd(aVFL,{ "VFL_SERNFI" , SF1->F1_SERIE })
		If !VA3210011_MVC_CAD_VFL( nRecNo , aVFL ) .or. cDebugMIL == "VEIA330017"
			Return .f.
		Endif
		//
		aAdd(aVDV,{ "VDV_ENUMNP" , SF1->F1_DOC   }) // Nro da NF Saida de Pecas
		aAdd(aVDV,{ "VDV_ESERNP" , SF1->F1_SERIE }) // Serie da NF Saida de Pecas
		aAdd(aVDV,{ "VDV_ECDFOP" , SF1->F1_FORNECE }) // Fornecedor da NF Saida de Pecas
		aAdd(aVDV,{ "VDV_ELJFOP" , SF1->F1_LOJA  }) // Loja do Fornecedor da NF Saida de Pecas
		//
		aAdd(aDocTela,{ "BR_VERDE" , Alltrim(SF1->F1_DOC)+"-"+Alltrim(SF1->F1_SERIE) , cTitDoc })
		//
	EndIf

Else // 2=Movimentações Internas -> Geração do SD3

	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VFO")
	cQuery += " WHERE VFO_FILIAL = '"+xFilial("VFO")+"'"
	cQuery += "   AND VFO_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFO_TIPREG = '"+cTpReg+"'"
	cQuery += "   AND VFO_AGRDES = '"+cPro_VEIA+"'"
	cQuery += "   AND VFO_TIPMOV <> ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo == 0 .or. cDebugMIL == "VEIA330018"
		Return .f.
	Else
		VFO->(DbGoTo(nRecNo))
	EndIf
	cQuery := "SELECT VFQ_CODSB1 , VFQ_CENCUS , VFQ_CONTA , VFQ_ITEMCT , VFQ_CLVL , VFQ_QUANT , VFQ_CUSUNI "
	cQuery += "  FROM "+RetSQLName("VFQ")
	cQuery += " WHERE VFQ_FILIAL = '"+xFilial("VFQ")+"'"
	cQuery += "   AND VFQ_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND VFQ_VEIMAQ = '"+cNroVeic+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		aAdd(aSB1SD3,{	(cSQLAlias)->( VFQ_CODSB1 )                                           ,; // Codigo SB1
						(cSQLAlias)->( VFQ_QUANT )                                            ,; // Qtde
						round( (cSQLAlias)->( VFQ_QUANT ) * (cSQLAlias)->( VFQ_CUSUNI ) , 2 ) ,; // Valor Total
						(cSQLAlias)->( VFQ_CENCUS )                                           ,; // Centro de Custo
						(cSQLAlias)->( VFQ_CONTA )                                            ,; // Conta Contabil
						(cSQLAlias)->( VFQ_ITEMCT )                                           ,; // Item Conta
						(cSQLAlias)->( VFQ_CLVL )                                             }) // Classe Valor
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VFO")
	If len(aSB1SD3) > 0 
		If !VA3300071_Movimentacoes_Internas( "1" , "1" , cCodVDV , VFO->VFO_TIPMOV , aSB1SD3 ) .or. cDebugMIL == "VEIA330019" // Mov.Interna Peça ( 1=Entrada , 1=Tp.Normal , Codigo VDV , Tp.Movimento , aSB1 )
			Return .f.
		EndIf
		aAdd(aDocTela,{ "BR_VERDE" , STR0026 , cTitDoc }) // Mov.Interna
	EndIf

EndIf

Return .t.

/*/{Protheus.doc} VA3300071_Movimentacoes_Internas
ExecAuto das Movimentações Internas - SD3 - função também chamada pelo VEIXX000 e VEIXX001

@author Andre Luis Almeida
@since 20/03/2023
/*/
Function VA3300071_Movimentacoes_Internas( cSaiEnt , cTipMov , cCodVDV , cD3_TM , aSB1SD3 )
Local aItem         := {}
Local aVBH          := {}
Local cD3_DOC       := ""
Local cLocPad       := ""
Local nCntFor       := 0
Local nCusto        := 0
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
Private lMsErroAuto := .f. // necessario a criacao
Default cSaiEnt     := ""
Default cTipMov     := "1"
Default cCodVDV     := VDV->VDV_CODIGO // VDV posicionado
Default cD3_TM      := IIf( cSaiEnt == "1" , GetNewPar("MV_MIL0114","") , GetNewPar("MV_MIL0115","") ) // TM de Entrada / TM de Saida
Default aSB1SD3     := {}
//
SB1->(DbSetOrder(1))
SB2->(DbSetOrder(1))	
For nCntFor := 1 to len(aSB1SD3)
	//
	cD3_DOC  := Criavar("D3_DOC")
	cD3_DOC	:= IIf(Empty(cD3_DOC),NextNumero("SD3",2,"D3_DOC",.T.),cD3_DOC)
	cD3_DOC	:= A261RetINV(cD3_DOC)
	//
	SB1->( DbSeek( xFilial("SB1") + aSB1SD3[nCntFor,1] ) )
	cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	SB2->( DbSeek( xFilial("SB2") + SB1->B1_COD + cLocPad ) )
	nCusto := IIf( aSB1SD3[nCntFor,3] > 0 , aSB1SD3[nCntFor,3] , round( SB2->B2_CM1 , 2 ) * aSB1SD3[nCntFor,2] ) // Custo Total
	//
	aItem := {}
	aadd(aItem,{ "D3_DOC"     , cD3_DOC                                                           , NIL })
	aadd(aItem,{ "D3_TM"      , cD3_TM                                                            , NIL })
	aadd(aItem,{ "D3_COD"     , SB1->B1_COD                                                       , NIL })
	aadd(aItem,{ "D3_UM"      , SB1->B1_UM                                                        , NIL })
	aadd(aItem,{ "D3_QUANT"   , aSB1SD3[nCntFor,2]                                                , NIL })
	aadd(aItem,{ "D3_LOCAL"   , cLocPad                                                           , NIL })
	aadd(aItem,{ "D3_CC"      , IIf(!Empty(aSB1SD3[nCntFor,4]),aSB1SD3[nCntFor,4],SB1->B1_CC)     , NIL })
	aadd(aItem,{ "D3_CONTA"   , IIf(!Empty(aSB1SD3[nCntFor,5]),aSB1SD3[nCntFor,5],SB1->B1_CONTA)  , NIL })
	aadd(aItem,{ "D3_ITEMCTA" , IIf(!Empty(aSB1SD3[nCntFor,6]),aSB1SD3[nCntFor,6],SB1->B1_ITEMCC) , NIL })
	aadd(aItem,{ "D3_CLVL"    , IIf(!Empty(aSB1SD3[nCntFor,7]),aSB1SD3[nCntFor,7],SB1->B1_CLVL)   , NIL })
	aadd(aItem,{ "D3_EMISSAO" , dDataBase                                                         , NIL })
	aadd(aItem,{ "D3_CUSTO1"  , nCusto                                                            , NIL })
	lMsHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x| MATA240(x)},aItem)
	If lMsErroAuto .or. cDebugMIL == "VEIA330020"
		Return .f.
	EndIf
	//
	aVBH := {}
	aAdd(aVBH,{ "VBH_CODVDV" , cCodVDV         }) // Código VDV
	aAdd(aVBH,{ "VBH_DOCSD3" , SD3->D3_DOC     }) // Documento SD3
	aAdd(aVBH,{ "VBH_NUMSEQ" , SD3->D3_NUMSEQ  }) // Numero de Sequencia SD3
	aAdd(aVBH,{ "VBH_SAIENT" , cSaiEnt         }) // Entrada / Saida
	aAdd(aVBH,{ "VBH_TIPMOV" , cTipMov         }) // Tipo de Movimento
	aAdd(aVBH,{ "VBH_CODSB1" , SB1->B1_COD     }) // Código SB1
	aAdd(aVBH,{ "VBH_CC"     , SD3->D3_CC      }) // Centro de Custo
	aAdd(aVBH,{ "VBH_CONTA"  , SD3->D3_CONTA   }) // Conta
	aAdd(aVBH,{ "VBH_ITEMCT" , SD3->D3_ITEMCTA }) // Item Conta
	aAdd(aVBH,{ "VBH_CLVL"   , SD3->D3_CLVL    }) // Classe Valor
	If VA3190011_MVC_CAD_VBH( 0 , aVBH ) == 0 .or. cDebugMIL == "VEIA330021"
		Return .f.
	EndIf
	//
Next
//
Return .t.

/*/{Protheus.doc} VA3300081_VV1_AMS
Criação/Alteração do VV1/VFP referente aos AMS que serão desegregados

@author Andre Luis Almeida
@since 01/03/2023
/*/
Static Function VA3300081_VV1_AMS()
Local lRet        := .t.
Local lVV1_MSBLQL := VV1->(ColumnPos("VV1_MSBLQL")) > 0
Local cGTr        := ""
Local cNCM        := ""
Local oModelVV1   := FWLoadModel( 'VEIA070' ) // VV1
Local aVV1AMS     := {}
Local aVFP        := {}
Local aVFM        := {}
Local cChaIntVV1  := ""
Local cGruVei     := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Local nCntFor     := 0

Local aCliLoja    := VA300017D_RetornaCliente()//Retorna o cliente da filial logada.
//	
DbSelectArea("VFP")
DbSetOrder(2) // VFP_FILIAL+VFP_CODEXE
DbSeek( xFilial("VFP") + VFJ->VFJ_CODIGO )
Do While !VFP->(Eof()) .and. VFP->VFP_FILIAL == xFilial("VFP") .and. VFP->VFP_CODEXE == VFJ->VFJ_CODIGO .and. lRet
	cChaIntVV1 := VFP->VFP_CHAINT
	If !Empty(VFP->VFP_CHASSI)
		cChaIntVV1 := FM_SQL("SELECT VV1_CHAINT FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI='"+VFP->VFP_CHASSI+"' AND D_E_L_E_T_=' '")
	EndIf
	If Empty(cChaIntVV1) // Não possui VV1 - Criar
		cGTr := ""
		cNCM := ""
		If Empty(VFP->VFP_GRTRIB) .or. Empty(VFP->VFP_POSIPI)
			VV2->(DbSetOrder(1))
			If VV2->(DbSeek(xFilial("VV2")+VFP->VFP_CODMAR+VFP->VFP_MODVEI)) .and. !Empty(VV2->VV2_PRODUT) .or. cDebugMIL == "VEIA330022"
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1")+VV2->VV2_PRODUT)) .or. cDebugMIL == "VEIA330022"
					cGTr := SB1->B1_GRTRIB
					cNCM := SB1->B1_POSIPI
				EndIf
			EndIf
		EndIf
		oModelVV1:SetOperation( MODEL_OPERATION_INSERT )
		If oModelVV1:Activate()
			cChaIntVV1 := oModelVV1:GetValue("MODEL_VV1","VV1_CHAINT")
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_CHASSI" , IIf(!Empty(VFP->VFP_CHASSI),VFP->VFP_CHASSI,cSiglaAMS+"_"+cChaIntVV1) )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_CODMAR" , VFP->VFP_CODMAR )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_MODVEI" , VFP->VFP_MODVEI )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_SEGMOD" , VFP->VFP_SEGMOD )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_CORVEI" , VFP->VFP_CORVEI )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_SITVEI" , "0"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_ESTVEI" , "0"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_LOCPAD" , VFP->VFP_LOCPAD )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_GRASEV" , "6"             ) // SEM CHASSI ( AMS )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_DTHEMI" , dToc(Date())+" "+Time() )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_FABMOD" , StrZero(Year(dDataBase),4)+StrZero(Year(dDataBase),4) )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_COMVEI" , "9"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_CODORI" , IIf(!Empty(VFP->VFP_CODORI),VFP->VFP_CODORI,"2") )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_PROVEI" , IIf(!Empty(VFP->VFP_PROVEI),VFP->VFP_PROVEI,"1") )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_INDCAL" , "0"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_VEIACO" , "0"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_TIPVEI" , "1"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_PROMOC" , "0"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_BLQPRO" , "0"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_FOTOS"  , "0"             )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_GRTRIB" , IIf(!Empty(VFP->VFP_GRTRIB),VFP->VFP_GRTRIB,cGTr) )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_POSIPI" , IIf(!Empty(VFP->VFP_POSIPI),VFP->VFP_POSIPI,cNCM) )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_CC"     , VFP->VFP_CENCUS )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_CONTA"  , VFP->VFP_CONTA  )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_ITEMCC" , VFP->VFP_ITEMCT )
			oModelVV1:SetValue( "MODEL_VV1" , "VV1_CLVL"   , VFP->VFP_CLVL   )

			If lVV1_MSBLQL
				oModelVV1:SetValue( "MODEL_VV1" , "VV1_MSBLQL" , "2" )
			EndIf
			If Len(aCliLoja) > 0
				oModelVV1:SetValue( "MODEL_VV1" , "VV1_PROATU"   , aCliLoja[1])
				oModelVV1:SetValue( "MODEL_VV1" , "VV1_LJPATU"   , aCliLoja[2])
			Endif
			
				oModelVV1:SetValue( "MODEL_VV1" , "VV1_ROTINA"   , "VA3300081_VV1_AMS" )
			
			If ( lRet := oModelVV1:VldData() )
				if ( lRet := oModelVV1:CommitData() )
				EndIf
			EndIf
			If !lRet
				Help("",1,"COMMITVV1",,oModelVV1:GetErrorMessage()[6] + " - " + oModelVV1:GetErrorMessage()[2],1,0)
			EndIf
			oModelVV1:DeActivate()
		EndIf
	EndIf
	If lRet .and. !Empty(cChaIntVV1)
		aAdd(aVV1AMS, { VFP->(RecNo()) , cChaIntVV1 } )
	EndIf
	VFP->(dbSkip())
EndDo
// Ajustar os CHAINT e CHASSI na VV1 e VFP
If lRet
	For nCntFor := 1 to len(aVV1AMS)
		aVFP := {}
		VFP->(DbGoTo(aVV1AMS[nCntFor,1]))
		If Empty(VFP->VFP_CHAINT)
			aAdd(aVFP,{ "VFP_CHAINT" , aVV1AMS[nCntFor,2] }) // CHAINT
		EndIf
		If Empty(VFP->VFP_CHASSI)
			aAdd(aVFP,{ "VFP_CHASSI" , cSiglaAMS+"_"+aVV1AMS[nCntFor,2] }) // CHASSI
		EndIf
		If len(aVFP) > 0
			VA3220011_MVC_CAD_VFP( aVV1AMS[nCntFor,1] , aVFP ) // Atualiza VFP
		EndIf
		If !Empty(VFP->VFP_REFSAI)
			VFM->(DbSetOrder(1))
			If VFM->(DbSeek(xFilial("VFM")+VFP->VFP_REFSAI)) .and. Empty(VFM->VFM_CHAINT)
				aVFM := {}
				aAdd(aVFM,{ "VFM_CHAINT" , aVV1AMS[nCntFor,2] }) // CHAINT
				VA3280011_MVC_CAD_VFM( VFM->(RecNo()) , aVFM ) // Atualiza VFM
			EndIf
		EndIf
		// Neste ponto de entrada poderá ser gravadas informações complementares nas tabelas VV1 e SB1 referente aos AMS.
		VV1->(DbSetOrder(1))
		VV1->(DbSeek(xFilial("VV1")+aVV1AMS[nCntFor,2]))
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
		If ExistBlock("VXX040DG")
			ExecBlock("VXX040DG",.f.,.f.)
		EndIf
	Next
EndIf
//
FreeObj(oModelVV1)
//
Return lRet


/*/{Protheus.doc} VA3300091_Regua
Regua do Processo

@author Andre Luis Almeida
@since 20/03/2023
/*/
Static Function VA3300091_Regua( oProcess , cTitRegua )
oProcess:IncRegua1()
oProcess:SetRegua2(0)
oProcess:IncRegua2(cTitRegua)
Return

/*/{Protheus.doc} VA330010D_AjustaCustos
Ajusta Custos dos Veiculos/Maquinas 1 e 2 - antes de Efetivar Processo

@author Francisco
@since 29/03/2023
/*/
Static Function VA330010D_AjustaCustos( cNroVeic , cPro_VEIA )
Local aAux      := {} // { Campo , Valor }
Local cCampoAt  := ("VFJ_CUSAT"+cNroVeic) // Custo Atual: 1 = Veic/Maq. 1, 2 = Veic/Maq. 2
Local cCampoFt  := ("VFJ_CUSFT"+cNroVeic) // Custo Futuro: 1 = Veic/Maq. 1, 2 = Veic/Maq. 2
Local cChaInt   := IIf(cNroVeic=="1",VFJ->VFJ_VV1001,VFJ->VFJ_VV1002) // ChaInt : 1 = Veic/Maq. 1, 2 = Veic/Maq. 2
Local nCusAt    := 0
Local nCusFt    := 0
Local nCusto    := 0
Local nAux      := 0
Local cQuery    := ""
Local cSQLAlias := "SQLAUX"
If !Empty(cChaInt)
	nCusAt := VA3300111_CHAINT_retorna_B2_CM1( cChaInt )
	nCusFt := nCusAt // Custo Futuro inicia com o Custo Atual
	If VFJ->VFJ_TIPITE == "1" // 1 = AMS (Tabela VFM/VFP)
		If cPro_VEIA == "1" // 1 = Agrega ( Saida )
			cQuery := "SELECT VFM_CHAINT , VFM_CUSUNI , R_E_C_N_O_ AS RECVFM "
			cQuery += "  FROM "+RetSQLName("VFM")
			cQuery += " WHERE VFM_FILIAL = '"+xFilial("VFM")+"'"
			cQuery += "   AND VFM_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
			cQuery += "   AND VFM_VEIMAQ = '"+cNroVeic+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
			While !(cSQLAlias)->(Eof())
				nCusto := round( (cSQLAlias)->( VFM_CUSUNI ) , 2 )
				If !Empty((cSQLAlias)->( VFM_CHAINT ))
					nAux := round( VA3300111_CHAINT_retorna_B2_CM1( (cSQLAlias)->( VFM_CHAINT ) ) , 2 )
					If nAux > 0 .and. nAux <> nCusto
						nCusto := nAux
						aAux := {}
						aAdd(aAux,{"VFM_CUSUNI", nCusto}) // Corrige VFM->VFM_CUSUNI
						VA3280011_MVC_CAD_VFM( (cSQLAlias)->( RECVFM ) , aAux ) // Atualiza VFM
					EndIf
				EndIf
				nCusFt += round( nCusto , 2 )
				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
			DbSelectArea("VFM")
		Else // 2 = Desagrega ( Entrada )
			cQuery := "SELECT VFP_CHAINT , VFP_CUSUNI , R_E_C_N_O_ AS RECVFP "
			cQuery += "  FROM "+RetSQLName("VFP")
			cQuery += " WHERE VFP_FILIAL = '"+xFilial("VFP")+"'"
			cQuery += "   AND VFP_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
			cQuery += "   AND VFP_VEIMAQ = '"+cNroVeic+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
			While !(cSQLAlias)->(Eof())
				nCusto := round( (cSQLAlias)->( VFP_CUSUNI ) , 2 )
				If !Empty((cSQLAlias)->( VFP_CHAINT ))
					nAux := round( VA3300111_CHAINT_retorna_B2_CM1( (cSQLAlias)->( VFP_CHAINT ) ) , 2 )
					If ( nAux > 0 .and. nAux <> nCusto ) .or. cDebugMIL == "VEIA330023"
						nCusto := nAux
						aAux := {}
						aAdd(aAux,{"VFP_CUSUNI", nCusto}) // Corrige VFP->VFP_CUSUNI
						VA3220011_MVC_CAD_VFP( (cSQLAlias)->( RECVFP ) , aAux ) // Atualiza VFP
					EndIf
				EndIf
				nCusFt -= round( nCusto , 2 )
				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
			DbSelectArea("VFP")
		EndIf
	Elseif VFJ->VFJ_TIPITE == "2" // 2 = Peças (Tabela VFN/VFQ)
		If cPro_VEIA == "1" // 1 = Agrega ( Saida do Estoque )
			cQuery := "SELECT VFN_CODSB1 , VFN_QUANT , VFN_CUSUNI , R_E_C_N_O_ AS RECVFN "
			cQuery += "  FROM "+RetSQLName("VFN")
			cQuery += " WHERE VFN_FILIAL = '"+xFilial("VFN")+"'"
			cQuery += "   AND VFN_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
			cQuery += "   AND VFN_VEIMAQ = '"+cNroVeic+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
			While !(cSQLAlias)->(Eof())
				nCusto := round( (cSQLAlias)->( VFN_CUSUNI ) , 2 )
				nAux := round( VA3300121_CODSB1_retorna_B2_CM1( (cSQLAlias)->( VFN_CODSB1 ) ) , 2 )
				If nAux > 0 .and. nAux <> nCusto
					nCusto := nAux
					aAux := {}
					aAdd(aAux,{ "VFN_CUSUNI" , nCusto }) // Corrige VFN->VFN_CUSUNI
					VA3290011_MVC_CAD_VFN( (cSQLAlias)->( RECVFN ) , aAux ) // Atualiza VFN
				EndIf
				nCusFt += round( (cSQLAlias)->( VFN_QUANT ) * nCusto , 2 )
				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
			DbSelectArea("VFN")
		Else // 2 = Desagrega ( Entrada no Estoque )
			cQuery := "SELECT VFQ_CODSB1 , VFQ_QUANT , VFQ_CUSUNI , R_E_C_N_O_ AS RECVFQ "
			cQuery += "  FROM "+RetSQLName("VFQ")
			cQuery += " WHERE VFQ_FILIAL = '"+xFilial("VFQ")+"'"
			cQuery += "   AND VFQ_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
			cQuery += "   AND VFQ_VEIMAQ = '"+cNroVeic+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
			While !(cSQLAlias)->(Eof())
				nCusto := round( (cSQLAlias)->( VFQ_CUSUNI ) , 2 )
				nCusFt -= round( (cSQLAlias)->( VFQ_QUANT ) * nCusto , 2 )
				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
			DbSelectArea("VFQ")
		EndIf
	Endif
	aAux := {}
	aAdd(aAux,{ cCampoAt , nCusAt }) // Custo Atual  -> { Campo , Valor }
	aAdd(aAux,{ cCampoFt , nCusFt }) // Custo Futuro -> { Campo , Valor }
	VA3170011_MVC_CAD_VFJ( VFJ->(RecNo()) , aAux )
EndIf
Return nCusFt

/*/{Protheus.doc} VA3300111_CHAINT_retorna_B2_CM1
Retorna B2_CM1 do Veiculo (CHAINT)

@author Andre Luis Almeida
@since 13/04/2023
/*/
Static Function VA3300111_CHAINT_retorna_B2_CM1( cChaInt )
Local cGruVei := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Local cQuery  := "" 
Local cLocAux := ""
Local nB2_CM1 := 0
DBSelectArea("VV1")
DBSetOrder(1)
If DBSeek(xFilial("VV1")+cChaInt)
	If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT, /* cMVMIL0010 */ , cGruVei ) // Posiciona no SB1
		cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		cQuery  := "SELECT B2_CM1 FROM "+RetSQLName("SB2")+" WHERE B2_FILIAL='"+xFilial("SB2")+"' AND B2_COD='"+SB1->B1_COD+"' AND B2_LOCAL='"+cLocAux+"' AND D_E_L_E_T_ = ' '"
		nB2_CM1 := FM_SQL(cQuery)
	EndIf
EndIf
Return nB2_CM1

/*/{Protheus.doc} VA3300121_CODSB1_retorna_B2_CM1
Retorna B2_CM1 da Peça (B1_COD)

@author Andre Luis Almeida
@since 13/04/2023
/*/
Static Function VA3300121_CODSB1_retorna_B2_CM1( cCodSB1 )
Local cQuery  := "" 
Local cLocAux := ""
Local nB2_CM1 := 0
DBSelectArea("SB1")
DBSetOrder(1)
If DBSeek(xFilial("SB1")+cCodSB1)
	cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	cQuery  := "SELECT B2_CM1 FROM "+RetSQLName("SB2")+" WHERE B2_FILIAL='"+xFilial("SB2")+"' AND B2_COD='"+cCodSB1+"' AND B2_LOCAL='"+cLocAux+"' AND D_E_L_E_T_ = ' '"
	nB2_CM1 := FM_SQL(cQuery)
EndIf
Return nB2_CM1

/*/{Protheus.doc} VA3300131_MostrarDocumentosTela
Visualiza Documentos Gerados

@author Andre Luis Almeida
@since 09/05/2023
/*/
Function VA3300131_MostrarDocumentosTela( aDocTela , cCodVDV )
Local cSQLAlias  := "SQLVDV"
Local cCor       := ""
Local cQuery     := ""
Local cTitProc   := ""
Local cTipReg    := ""
Local cTitDoc    := ""
Local cPROCES    := ""
Local nCntFor    := 0
Local nSeqVDV    := 0
Local aLegDoc    := {}
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
Default aDocTela := {}
Default cCodVDV  := ""
If !Empty(cCodVDV)
	VDV->(DbSetOrder(1))
	VDV->(DbSeek( xFilial("VDV") + cCodVDV ))
	cPROCES := VDV->VDV_AGRDES
Else
	cPROCES := VFJ->VFJ_PROCES
	If cPROCES == "3" // Transferência
		cTitProc := " - "+STR0003 // Transferência
	ElseIf cPROCES == "4" // Troca
		cTitProc := " - "+STR0004 // Troca
	EndIf
EndIf
If len(aDocTela) <= 0
	If cPROCES == "1" // Agrega
		aAdd(aDocTela,{ "" , "---" , STR0001 }) // Agrega (Individual)
		aAdd(aDocTela,{ "" , "---" , "" })
	ElseIf cPROCES == "2" // Desagrega
		aAdd(aDocTela,{ "" , "---" , STR0002 }) // Desagrega (Individual)
		aAdd(aDocTela,{ "" , "---" , "" })
	EndIf
	cQuery := "SELECT R_E_C_N_O_ AS RECVDV "
	cQuery += "  FROM "+RetSQLName("VDV")
	cQuery += " WHERE VDV_FILIAL = '"+xFilial("VDV")+"'"
	If !Empty(cCodVDV)
		cQuery += "   AND VDV_CODIGO = '"+cCodVDV+"'"
	Else
		cQuery += "   AND VDV_FILEXE = '"+VFJ->VFJ_FILIAL+"'"
		cQuery += "   AND VDV_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
	EndIf
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VDV_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		VDV->(DbGoTo( (cSQLAlias)->( RECVDV ) ))
		nSeqVDV++
		cCor := IIf(VDV->VDV_STATUS=="0","BR_VERMELHO","BR_VERDE")
		If cPROCES $ "1/2" // Agrega / Desagrega
			// Nota Fiscal: 1=NF Saida Veículo/Máquina/Equipamento 1
			// Movimentação Interna: 1=Saida Veículo/Máquina/Equipamento 1
			cTipReg := "1"
			cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
			aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNF)+"-"+Alltrim(VDV->VDV_SSERNF),STR0026) , cTitDoc }) // Mov.Interna
			If !Empty(VDV->VDV_SNUMNP) .or. ( VDV->VDV_TIPDOC == "2" .and. VDV->VDV_AGRDES == "1" .and. VA3300151_MovInternaPecas( VDV->VDV_CODIGO ) )
				// Nota Fiscal: 2=NF Saida Peças Veículo/Máquina/Equipamento 1
				// Movimentação Interna: 2=Saida Peças Veículo/Máquina/Equipamento 1
				cTipReg := "2"
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNP)+"-"+Alltrim(VDV->VDV_SSERNP),STR0026) , cTitDoc }) // Mov.Interna
			EndIf
			// Nota Fiscal: 1=NF Entrada Veículo/Máquina/Equipamento 1
			// Movimentação Interna: 5=Entrada Veículo/Máquina/Equipamento 1
			cTipReg := IIf(VDV->VDV_TIPDOC=="1","1","5") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
			cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
			aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNF)+"-"+Alltrim(VDV->VDV_ESERNF),STR0026) , cTitDoc }) // Mov.Interna
			If !Empty(VDV->VDV_ENUMNP) .or. ( VDV->VDV_TIPDOC == "2" .and. VDV->VDV_AGRDES == "2" .and. VA3300151_MovInternaPecas( VDV->VDV_CODIGO ) )
				// Nota Fiscal: 2=NF Entrada Peças Veículo/Máquina/Equipamento 1
				// Movimentação Interna: 6=Entrada Peças para Desagregar do 1
				cTipReg := IIf(VDV->VDV_TIPDOC=="1","2","6") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNP)+"-"+Alltrim(VDV->VDV_ESERNP),STR0026) , cTitDoc }) // Mov.Interna
			EndIf
		ElseIf cPROCES $ "3/4" // Transferencia / Troca
			If nSeqVDV == 1
				aAdd(aDocTela,{ "gr_blue01" , "---" , STR0029 }) // Desagrega
				// Nota Fiscal: 1=NF Saida Veículo/Máquina/Equipamento 1
				// Movimentação Interna: 1=Saida Veículo/Máquina/Equipamento 1
				cTipReg := "1"
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNF)+"-"+Alltrim(VDV->VDV_SSERNF),STR0026) , cTitDoc }) // Mov.Interna
				// Nota Fiscal: 1=NF Entrada Veículo/Máquina/Equipamento 1
				// Movimentação Interna: 5=Entrada Veículo/Máquina/Equipamento 1
				cTipReg := IIf(VDV->VDV_TIPDOC=="1","1","5") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNF)+"-"+Alltrim(VDV->VDV_ESERNF),STR0026) , cTitDoc }) // Mov.Interna
				If !Empty(VDV->VDV_ENUMNP) .or. ( VDV->VDV_TIPDOC == "2" .and. VDV->VDV_AGRDES == "2" .and. VA3300151_MovInternaPecas( VDV->VDV_CODIGO ) )
					// Nota Fiscal: 2=NF Entrada Peças Veículo/Máquina/Equipamento 1
					// Movimentação Interna: 6=Entrada Peças para Desagregar do 1
					cTipReg := IIf(VDV->VDV_TIPDOC=="1","2","6") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
					cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
					aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNP)+"-"+Alltrim(VDV->VDV_ESERNP),STR0026) , cTitDoc }) // Mov.Interna
				EndIf
			ElseIf nSeqVDV == 2
				aAdd(aDocTela,{ "gr_blue02" , "---" , STR0028 }) // Agrega
				// Nota Fiscal: 3=NF Saida Veículo/Máquina/Equipamento 2
				// Movimentação Interna: 3=Saida Veículo/Máquina/Equipamento 2
				cTipReg := "3"
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNF)+"-"+Alltrim(VDV->VDV_SSERNF),STR0026) , cTitDoc }) // Mov.Interna
				If !Empty(VDV->VDV_SNUMNP) .or. ( VDV->VDV_TIPDOC == "2" .and. VDV->VDV_AGRDES == "1" .and. VA3300151_MovInternaPecas( VDV->VDV_CODIGO ) )
					// Nota Fiscal: 4=NF Saida Peças para Agregar no 2
					// Movimentação Interna: 4=Saida Peças para Agregar no 2
					cTipReg := "4"
					cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
					aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNP)+"-"+Alltrim(VDV->VDV_SSERNP),STR0026) , cTitDoc }) // Mov.Interna
				EndIf
				// Nota Fiscal: 3=NF Entrada Veículo/Máquina/Equipamento 2
				// Movimentação Interna: 7=Entrada Veículo/Máquina/Equipamento 2
				cTipReg := IIf(VDV->VDV_TIPDOC=="1","3","7") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNF)+"-"+Alltrim(VDV->VDV_ESERNF),STR0026) , cTitDoc }) // Mov.Interna
			ElseIf nSeqVDV == 3
				aAdd(aDocTela,{ "gr_blue03" , "---" , STR0029 }) // Desagrega
				// Nota Fiscal: 3=NF Saida Veículo/Máquina/Equipamento 2
				// Movimentação Interna: 3=Saida Veículo/Máquina/Equipamento 2
				cTipReg := "3"
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNF)+"-"+Alltrim(VDV->VDV_SSERNF),STR0026) , cTitDoc }) // Mov.Interna
				// Nota Fiscal: 3=NF Entrada Veículo/Máquina/Equipamento 2
				// Movimentação Interna: 7=Entrada Veículo/Máquina/Equipamento 2
				cTipReg := IIf(VDV->VDV_TIPDOC=="1","3","7") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNF)+"-"+Alltrim(VDV->VDV_ESERNF),STR0026) , cTitDoc }) // Mov.Interna
				If !Empty(VDV->VDV_ENUMNP) .or. ( VDV->VDV_TIPDOC == "2" .and. VDV->VDV_AGRDES == "2" .and. VA3300151_MovInternaPecas( VDV->VDV_CODIGO ) )
					// Nota Fiscal: 4=NF Entrada Peças para Desagregar do 2
					// Movimentação Interna: 8=Entrada Peças para Desagregar do 2
					cTipReg := IIf(VDV->VDV_TIPDOC=="1","4","8") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
					cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
					aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNP)+"-"+Alltrim(VDV->VDV_ESERNP),STR0026) , cTitDoc }) // Mov.Interna
				EndIf
			ElseIf nSeqVDV == 4
				aAdd(aDocTela,{ "gr_blue04" , "---" , STR0028 }) // Agrega
				// Nota Fiscal: 1=NF Saida Veículo/Máquina/Equipamento 1
				// Movimentação Interna: 1=Saida Veículo/Máquina/Equipamento 1
				cTipReg := "1"
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNF)+"-"+Alltrim(VDV->VDV_SSERNF),STR0026) , cTitDoc }) // Mov.Interna
				If !Empty(VDV->VDV_SNUMNP) .or. ( VDV->VDV_TIPDOC == "2" .and. VDV->VDV_AGRDES == "1" .and. VA3300151_MovInternaPecas( VDV->VDV_CODIGO ) )
					// Nota Fiscal: 2=NF Saida Peças para Agregar no 1
					// Movimentação Interna: 2=Saida Peças para Agregar no 1
					cTipReg := "2"
					cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","S","M"),cTipReg)
					aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_SNUMNP)+"-"+Alltrim(VDV->VDV_SSERNP),STR0026) , cTitDoc }) // Mov.Interna
				EndIf
				// Nota Fiscal: 1=NF Entrada Veículo/Máquina/Equipamento 1
				// Movimentação Interna: 5=Entrada Veículo/Máquina/Equipamento 1
				cTipReg := IIf(VDV->VDV_TIPDOC=="1","1","5") // Tipo de Registro diferente para Nota Fiscal e Movimentação Interna
				cTitDoc := VA3300141_RetornaTitulo(IIf(VDV->VDV_TIPDOC=="1","E","M"),cTipReg)
				aAdd(aDocTela,{ cCor , IIf(VDV->VDV_TIPDOC=="1",Alltrim(VDV->VDV_ENUMNF)+"-"+Alltrim(VDV->VDV_ESERNF),STR0026) , cTitDoc }) // Mov.Interna
			EndIf
		EndIf
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VDV")
EndIf
If len(aDocTela) > 2 // Possui linhas de Documentos Gerados
	For nCntFor := 1 to len(aDocTela)
		If aDocTela[nCntFor,2] == "---"
			aAdd(aLegDoc,{ aDocTela[nCntFor,1] , aDocTela[nCntFor,3] })
		Else
			aAdd(aLegDoc,{ aDocTela[nCntFor,1] , aDocTela[nCntFor,2]+": "+aDocTela[nCntFor,3] })
		EndIf
	Next
	BrwLegenda(STR0027+cTitProc,"",aLegDoc) // Documentos Gerados
EndIf
Return

/*/{Protheus.doc} VA3300141_RetornaTitulo
Retorna o Titulo da linha

@author Andre Luis Almeida
@since 11/05/2023
/*/
Static Function VA3300141_RetornaTitulo(cTp,cTipReg)
Local cTitDoc    := ""
Local aComboNFS  := {}
Local aComboNFE  := {}
Local aComboMov  := {}
If cTp == "S" // NF Saida
	aComboNFS  := X3CBOXAVET("VFK_TIPREG","0") // NFs Saidas
	cTitDoc := substr(aComboNFS[val(cTipReg)],3)
ElseIf cTp == "E" // NF Entrada
	aComboNFE  := X3CBOXAVET("VFL_TIPREG","0") // NFs Entradas
	cTitDoc := substr(aComboNFE[val(cTipReg)],3)
Else // cTp == "M" // Movimentação Interna
	aComboMov  := X3CBOXAVET("VFO_TIPREG","0") // Movimentações Internas
	cTitDoc := substr(aComboMov[val(cTipReg)],3)
EndIf
Return cTitDoc

/*/{Protheus.doc} VA3300151_MovInternaPecas
Retorna se trata de uma Movimentação Interna de Peças

@author Andre Luis Almeida
@since 11/05/2023
/*/
Static Function VA3300151_MovInternaPecas( cCodVDV )
Local cGruVei := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Local cQuery  := ""
cQuery := "SELECT VBH.R_E_C_N_O_ AS RECVBH"
cQuery += "  FROM "+RetSQLName("VBH")+" VBH"
cQuery += "  JOIN "+RetSQLName("SB1")+" SB1"
cQuery += "    ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND SB1.B1_COD = VBH.VBH_CODSB1 AND SB1.B1_GRUPO <> '"+cGruVei+"' AND SB1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VBH.VBH_FILIAL = '"+xFilial("VBH")+"'"
cQuery += "   AND VBH.VBH_CODVDV = '"+cCodVDV+"'"
cQuery += "   AND VBH.D_E_L_E_T_ = ' '"
Return FM_SQL(cQuery) > 0
