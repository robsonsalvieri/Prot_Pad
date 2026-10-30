#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIC050.CH"

#DEFINE PulaLinha CHR(13) + CHR(10)

/*/{Protheus.doc} VEIC050
	Consulta Execucoes
	Browse's das Execucoes / Clientes / Veiculos

	@author Andre Luis Almeida
	@since 11/03/2019
/*/
Function VEIC050()

Local oDlgVC050
Local aBotEnch := {}
Local aSize    := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 //STR0001 # "SCRM Scania - Clientes / Veiculos - Execuções"
Private oBrwExe as OBJECT
Private oBrwCli as OBJECT
Private oBrwVei as OBJECT
Private oCAB_EXE as OBJECT
Private oCAB_CLI as OBJECT
Private oCAB_VEI as OBJECT
Private aBrwExe := {}
Private aBrwCli := {}
Private aBrwVei := {}
Private aBrwVCF := {}
Private oFontTitulo := TFont():New(,11,24,,.T.,,,,,,,,,,,) // Fonte BOLD

AADD(aBotEnch, {"E5",{|| VC0500031_Acionamento_Botoes(1) },STR0002} ) //STR0002 # Gerar Carga Inicial
AADD(aBotEnch, {"E5",{|| VC0500031_Acionamento_Botoes(2) },STR0003} ) //STR0003 # Gerar Diario
AADD(aBotEnch, {"E5",{|| VC0500031_Acionamento_Botoes(3) },STR0004} ) //STR0004 # Excluir
AADD(aBotEnch, {"E5",{|| VC0500031_Acionamento_Botoes(4) },STR0015} ) //STR0015 # Reenviar Clientes ao SCRM

DbSelectArea("VEF")

VC0500011_Montagem_Dados_do_Browse(0) // 0 - Inicial ( Lista Execuções )

oDlgVC050 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

// Cria Layer e as linhas
oLayer := FWLayer():New()
oLayer:Init(oDlgVC050, .F., .T.)
oLayer:AddLine("CAB_EXE", 4, .F.)   // Título Execuções
oLayer:AddLine("OBJEXE" , 30, .F.)
oLayer:AddLine("CAB_CLI", 4, .F.)   // Título Clientes
oLayer:AddLine("OBJCLI" , 27, .F.)
oLayer:AddLine("CAB_VEI", 4, .F.)   // Título Veículos
oLayer:AddLine("OBJVEI" , 26, .F.)

oCAB_EXE := oLayer:GetLinePanel("CAB_EXE")
@ 0, 0 SAY STR0021 SIZE 200, 15 FONT oFontTitulo COLOR CLR_BLUE OF oCAB_EXE PIXEL //STR0021 # "Execuções de Arquivos"
oCAB_CLI := oLayer:GetLinePanel("CAB_CLI")
@ 0, 0 SAY STR0022 SIZE 200, 15 FONT oFontTitulo COLOR CLR_BLUE OF oCAB_CLI PIXEL //STR0022 # "Clientes"
oCAB_VEI := oLayer:GetLinePanel("CAB_VEI") 
@ 0, 0 SAY STR0023 SIZE 200, 15 FONT oFontTitulo COLOR CLR_BLUE OF oCAB_VEI PIXEL //STR0023 # "Veículos Vinculados"

oBrwExe:= FWFormBrowse():New()
oBrwExe:SetOwner(oLayer:getLinePanel("OBJEXE"))
oBrwExe:SetDataArray()
oBrwExe:SetArray(aBrwExe)
oBrwExe:SetColumns(VC0500021_Monta_Colunas_Browse(1))
oBrwExe:DisableReport()
oBrwExe:DisableConfig()
oBrwExe:Activate()
// ATENCAO: setar CHANGE depois do Activate para nao chamar a funcao na montagem da TELA
oBrwExe:SetChange({ || VC0500011_Montagem_Dados_do_Browse(1) }) // 1 - Ao correr no browse das Execucoes - Lista Clientes/Veiculos da Execução posicionada

oBrwCli:= FWFormBrowse():New()
oBrwCli:SetOwner(oLayer:getLinePanel("OBJCLI"))
oBrwCli:SetDataArray()
oBrwCli:SetArray(aBrwCli)
oBrwCli:SetColumns(VC0500021_Monta_Colunas_Browse(2))
oBrwCli:DisableReport()
oBrwCli:DisableConfig()
oBrwCli:Activate()
// ATENCAO: setar CHANGE depois do Activate para nao chamar a funcao na montagem da TELA
oBrwCli:SetChange({ || VC0500011_Montagem_Dados_do_Browse(2) }) // 1 - Ao correr no browse dos Clientes - Lista Veiculos do Cliente posicionado

oBrwVei:= FWFormBrowse():New()
oBrwVei:SetOwner(oLayer:getLinePanel("OBJVEI"))
oBrwVei:SetDataArray()
oBrwVei:SetArray(aBrwVei)
oBrwVei:SetColumns(VC0500021_Monta_Colunas_Browse(3))
oBrwVei:DisableReport()
oBrwVei:DisableConfig()
oBrwVei:Activate()

ACTIVATE MSDIALOG oDlgVC050 ON INIT EnchoiceBar(oDlgVC050,{|| oDlgVC050:End()},{|| oDlgVC050:End()},,aBotEnch)

Return

/*/{Protheus.doc} VC0500011_Montagem_Dados_do_Browse
Monta os Dados dos Browses de Execucoes, Clientes da Execucao e Veiculos do Cliente
@author Andre Luis Almeida
@since 14/03/2019
@param nTp, numérico, Tipo: 1-Execucoes / 2-Clientes da Execucao / 3-Veiculos do Cliente
@type function
/*/
Static Function VC0500011_Montagem_Dados_do_Browse(nTp)
Local cQuery  := ""
Local cQAlias := "SQLALIAS"
Local nLinExe := 0
Local nLinCli := 0

Local oConfig := Nil
Local jConfig := Nil
Local lClienteCarteiraVinculada := .F.

If nTp == 0 .or. nTp == 3
	aBrwExe := {}
	cQuery := "SELECT VEF_TPEXEC , VEF_DTEXEC , VEF_HREXEC , COUNT(*) AS QTDE "
	cQuery += "  FROM " + RetSqlName("VEF")
	cQuery += " WHERE VEF_FILIAL='"+xFilial("VEF")+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	cQuery += " GROUP BY VEF_TPEXEC , VEF_DTEXEC , VEF_HREXEC"
	cQuery += " ORDER BY VEF_DTEXEC DESC , VEF_HREXEC DESC"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
	Do While !( cQAlias )->( Eof() )
		aAdd(aBrwExe,{	( cQAlias )->( VEF_TPEXEC ) ,;
						( cQAlias )->( VEF_DTEXEC ) ,;
						( cQAlias )->( VEF_HREXEC ) ,;
						( cQAlias )->( QTDE ) })
		( cQAlias )->(dbSkip())
	Enddo
	( cQAlias )->( dbCloseArea() )
	If len(aBrwExe) > 0 
		nLinExe := 1
	EndIf
	If nTp == 3
		oBrwExe:SetArray(aBrwExe)
		oBrwExe:Refresh()
		oBrwExe:GoTop()
	EndIf
elseif nTp == 4 // VCF - Reenvio Clientes (Nova funcionalidade)

        aBrwVCF := {}
		oConfig := OFScaniaConfig():New("SCRM", "OFIA541")
		jConfig := oConfig:GetConfig()

		If jConfig['SCRM_APENAS_CLIENTES'] == "1"
			lClienteCarteiraVinculada := .T.
		Endif
        
        // Colunas VCF + SA1 (para coerência)
        cQuery := "SELECT VCF.VCF_CODCLI, VCF.VCF_LOJCLI, VCF.VCF_SCRMID, VCF.VCF_SCRMED, VCF.VCF_SCRMSC, SA1.A1_NOME, SA1.A1_CGC "
        cQuery += "  FROM " + RetSqlName("VCF") + " VCF"
        cQuery += "  JOIN " + RetSqlName("SA1") + " SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VCF.VCF_CODCLI AND SA1.A1_LOJA=VCF.VCF_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
        cQuery += " WHERE VCF.VCF_FILIAL='"+xFilial("VCF")+"'"
        cQuery += "   AND VCF.D_E_L_E_T_=' '"
		cQuery += "   AND VCF.VCF_SCRMED = '1'"
		if lClienteCarteiraVinculada
			cQuery += "   AND VCF.VCF_VENVEI<>' '"
		endif		
        cQuery += " ORDER BY VCF.VCF_CODCLI"
        
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
        
        Do While !( cQAlias )->( Eof() )
            AAdd(aBrwVCF,{   .F. ,; // 1. NOVO CAMPO LÓGICO PARA MARCAÇÃO
                            ( cQAlias )->( VCF_CODCLI ) ,; // 2
                            ( cQAlias )->( VCF_LOJCLI ) ,; // 3
                            ( cQAlias )->( A1_NOME ) ,;    // 4 (SA1)
                            Alltrim(( cQAlias )->( A1_CGC )) ,; // 5 (SA1)
                            ( cQAlias )->( VCF_SCRMID ) ,; // 6
                            ( cQAlias )->( VCF_SCRMED ) ,; // 7
                            ( cQAlias )->( VCF_SCRMSC ) }) // 8
            ( cQAlias )->(dbSkip())
        Enddo
        
        ( cQAlias )->( dbCloseArea() )
        Return
Else
	nLinExe := oBrwExe:At()
	nLinCli  := oBrwCli:At()
EndIf
If nLinExe > 0
	If Len(aBrwExe) == 0
		aBrwCli := {}
	Endif
	If (nTp == 0 .or. nTp == 1) .and. Len(aBrwExe) > 0
		aBrwCli := {}
		cQuery := "SELECT VEF.VEF_CODCLI , VEF.VEF_LOJCLI , SA1.A1_NOME , SA1.A1_CGC , VEF.VEF_DEALER , VEF.VEF_ARQUIV , VEF.VEF_CODIGO"
		cQuery += "  FROM " + RetSqlName("VEF") + " VEF"
		cQuery += "  JOIN " + RetSqlName("SA1") + " SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VEF.VEF_CODCLI AND SA1.A1_LOJA=VEF.VEF_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += " WHERE VEF.VEF_FILIAL='"+xFilial("VEF")+"'"
		cQuery += "   AND VEF.VEF_TPEXEC='"+aBrwExe[nLinExe,1]+"'"
		cQuery += "   AND VEF.VEF_DTEXEC='"+aBrwExe[nLinExe,2]+"'"
		cQuery += "   AND VEF.VEF_HREXEC='"+aBrwExe[nLinExe,3]+"'"
		cQuery += "   AND VEF.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
		Do While !( cQAlias )->( Eof() )
			aAdd(aBrwCli,{	( cQAlias )->( VEF_DEALER ) ,;
							( cQAlias )->( VEF_CODCLI ) ,;
							( cQAlias )->( VEF_LOJCLI ) ,;
							( cQAlias )->( A1_NOME ) ,;
							Alltrim(( cQAlias )->( A1_CGC )) ,;
							( cQAlias )->( VEF_ARQUIV ) ,;
							( cQAlias )->( VEF_CODIGO ) })
			( cQAlias )->(dbSkip())
		Enddo
		( cQAlias )->( dbCloseArea() )
		nLinCli := 1
	EndIf
	If nTp == 1
		oBrwCli:SetArray(aBrwCli)
		oBrwCli:Refresh()
		oBrwCli:GoTop()
	EndIf
	aBrwVei := {}
	If nLinCli > 0 .and. Len(aBrwCli) > 0
		cQuery := "SELECT VEV.VEV_CHASSI , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_FABMOD , VEV.VEV_ARQUIV"
		cQuery += "  FROM " + RetSqlName("VEV")+ " VEV "
		cQuery += "  JOIN " + RetSqlName("VV1")+ " VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI=VEV.VEV_CHASSI AND VV1.D_E_L_E_T_=' ' ) "
		cQuery += "  LEFT JOIN " + RetSqlName("VV2")+ " VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD=VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_=' ' ) "
		cQuery += " WHERE VEV.VEV_FILIAL='"+xFilial("VEV")+"'"
		cQuery += "   AND VEV.VEV_CODVEF='"+aBrwCli[nLinCli,7]+"'"
		cQuery += "   AND VEV.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
		Do While !( cQAlias )->( Eof() )
			aAdd(aBrwVei,{	( cQAlias )->( VEV_CHASSI ) ,;
							( cQAlias )->( VV1_CODMAR ) ,;
							( cQAlias )->( VV2_DESMOD ) ,;
							( cQAlias )->( VV1_FABMOD ) ,;
							( cQAlias )->( VEV_ARQUIV )	})
			( cQAlias )->(dbSkip())
		Enddo
		( cQAlias )->( dbCloseArea() )
	EndIf
	If nTp == 1 .or. nTp == 2
		oBrwVei:SetArray(aBrwVei)
		oBrwVei:Refresh()
		oBrwVei:GoTop()
	EndIf
EndIf
Return

/*/{Protheus.doc} VC0500021_Monta_Colunas_Browse
Monta as Colunas/Campos dos Browses de Execucoes, Clientes da Execucao e Veiculos do Cliente
@author Andre Luis Almeida
@since 14/03/2019
@param nTp, numérico, Tipo: 1-Execucoes / 2-Clientes da Execucao / 3-Veiculos do Cliente
@return aColumns, vetor, Colunas do Browse
@type function
/*/
Static Function VC0500021_Monta_Colunas_Browse(nTp)
Local aColumns := {}
Do Case 
	Case nTp == 1 // Execucoes
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| IIf(aBrwExe[oBrwExe:At(),1]=='1','Carga Inicial','Diário') }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEF_TPEXEC"))
		aColumns[len(aColumns)]:SetSize(30) // 30 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| Transform(stod(aBrwExe[oBrwExe:At(),2]),'@D') }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEF_DTEXEC"))
		aColumns[len(aColumns)]:SetSize(20) // 20 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| Transform(aBrwExe[oBrwExe:At(),3],'@R 99:99') }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEF_HREXEC"))
		aColumns[len(aColumns)]:SetSize(20) // 20 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| Transform(aBrwExe[oBrwExe:At(),4],'@E 99999999') }"))
		aColumns[len(aColumns)]:SetTitle("Qtde Clientes")
		aColumns[len(aColumns)]:SetSize(30) // 30 %
	Case nTp == 2 // Clientes
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwCli[oBrwCli:At(),1] }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEF_DEALER"))
		aColumns[len(aColumns)]:SetSize(8) // 8 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwCli[oBrwCli:At(),2] }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEF_CODCLI"))
		aColumns[len(aColumns)]:SetSize(10) // 10 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwCli[oBrwCli:At(),3] }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEF_LOJCLI"))
		aColumns[len(aColumns)]:SetSize(7) // 7 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwCli[oBrwCli:At(),4] }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("A1_NOME"))
		aColumns[len(aColumns)]:SetSize(25) // 25 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| Transform(aBrwCli[oBrwCli:At(),5],IIf(len(aBrwCli[oBrwCli:At(),5])>11,'@R! NN.NNN.NNN/NNNN-99','@R! NNN.NNN.NNN-99')) }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("A1_CGC"))
		aColumns[len(aColumns)]:SetSize(20) // 20 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwCli[oBrwCli:At(),6] }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEF_ARQUIV"))
		aColumns[len(aColumns)]:SetSize(30) // 30 %
	Case nTp == 3 // Veiculos
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwVei[oBrwVei:At(),1] }"))
		aColumns[len(aColumns)]:SetTitle("Veiculos do Cliente"+" - "+RetTitle("VEV_CHASSI"))
		aColumns[len(aColumns)]:SetSize(25) // 25 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwVei[oBrwVei:At(),2] }"))
		aColumns[len(aColumns)]:SetTitle("Marca")
		aColumns[len(aColumns)]:SetSize(7) // 7 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwVei[oBrwVei:At(),3] }"))
		aColumns[len(aColumns)]:SetTitle("Modelo")
		aColumns[len(aColumns)]:SetSize(18) // 18 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| Transform(aBrwVei[oBrwVei:At(),4],'@R 9999/9999') }"))
		aColumns[len(aColumns)]:SetTitle("Fab/Mod")
		aColumns[len(aColumns)]:SetSize(10) // 10 %
		AAdd(aColumns, FWBrwColumn():New())
		aColumns[len(aColumns)]:SetData(&("{|| aBrwVei[oBrwVei:At(),5] }"))
		aColumns[len(aColumns)]:SetTitle(RetTitle("VEV_ARQUIV"))
		aColumns[len(aColumns)]:SetSize(40) // 40 %
	Case nTp == 4 // Reenvio SCRM 
		ADD MARKCOLUMN oColumn DATA { || If(aBrwVCF[oBrwVCF:nAt,1], 'LBOK', 'LBNO') } DOUBLECLICK { || VC050005F_MarcaLinhaVCF() } HEADERCLICK { || VC050006F_MarcaTodosVCF() } OF oBrwVCF       
        Add COLUMN oColumn Data &("{|| aBrwVCF[oBrwVCF:nAt,2]}") Title RetTitle("VCF_CODCLI") Picture X3Picture("VCF_CODCLI") Of oBrwVCF
        Add COLUMN oColumn Data &("{|| aBrwVCF[oBrwVCF:nAt,3]}") Title RetTitle("VCF_LOJCLI") Picture X3Picture("VCF_LOJCLI") Of oBrwVCF
        Add COLUMN oColumn Data &("{|| aBrwVCF[oBrwVCF:nAt,4]}") Title RetTitle("A1_NOME") Picture X3Picture("A1_NOME") Of oBrwVCF
		Add COLUMN oColumn Data &("{|| Transform(aBrwVCF[oBrwVCF:At(),5],IIf(len(aBrwVCF[oBrwVCF:At(),5])>11,'@R! NN.NNN.NNN/NNNN-99','@R! NNN.NNN.NNN-99')) }") Title RetTitle("A1_CGC") Of oBrwVCF
		Add COLUMN oColumn Data &("{|| aBrwVCF[oBrwVCF:nAt,6]}") Title RetTitle("VCF_SCRMID") Picture X3Picture("VCF_SCRMID") Of oBrwVCF
        Add COLUMN oColumn Data &("{|| X3COMBO('VCF_SCRMED', aBrwVCF[oBrwVCF:nAt,7])}") Title RetTitle("VCF_SCRMED") Of oBrwVCF
        Add COLUMN oColumn Data &("{|| X3COMBO('VCF_SCRMSC', aBrwVCF[oBrwVCF:nAt,8])}") Title RetTitle("VCF_SCRMSC") Of oBrwVCF       
EndCase
Return aColumns

/*/{Protheus.doc} VC0500031_Acionamento_Botoes
Acionamento/Clique dos Botoes de geração Carga Inicial e Diaria
@author Andre Luis Almeida
@since 14/03/2019
@param nBotAcionado, numérico, Botao: 1-Carga Inicial / 2-Diario / 3-Excluir
/*/
Static Function VC0500031_Acionamento_Botoes(nBotAcionado)
Local nLinExe   := 0
Local cMsgYesNo := ""
Local cTitTela  := ""
Local cQuery    := ""
Local aSize := FWGetDialogSize( oMainWnd )
local aBotVCF := {}
private oDlgVCF // Nova janela de reenvio SCRM
private oBrwVCF // Nova janela de reenvio SCRM
private aSeekVCF := {}

Do Case
	Case nBotAcionado <= 2 // 1-Carga Inicial / 2-Diario
		If nBotAcionado == 1
			cMsgYesNo := STR0005 + PulaLinha+PulaLinha + STR0006 //STR0005 # "ATENÇÃO: este processo pode demorar." //STR0006 # "Deseja Iniciar o processo de Carga Inicial?"
			cTitTela  := STR0007 //STR0007 # "Carga Inicial - SCRM Scania"
		Else //nBotAcionado == 2
			cMsgYesNo := STR0008 //STR0008 # "Deseja Iniciar o processo?"
			cTitTela  := STR0009 //STR0009 # "Diário - SCRM Scania"
		EndIf
		cQuery := "SELECT R_E_C_N_O_ "
		cQuery += "  FROM " + RetSqlName("VEF")
		cQuery += " WHERE VEF_FILIAL='"+xFilial("VEF")+"'"
		cQuery += "   AND VEF_TPEXEC = '"+strzero(nBotAcionado,1)+"'"
		cQuery += "   AND VEF_DTEXEC = '"+dtos(dDataBase)+"'"
		cQuery += "   AND VEF_HREXEC = '"+substr(Time(),1,2)+substr(Time(),4,2)+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			MsgStop(STR0010,cTitTela) //STR0010 # "Execução já existente na mesma DATA/HORA. Impossivel continuar."
		Else
			If MsgYesNo(cMsgYesNo,cTitTela)
				If VEIA120({"","",nBotAcionado})
					MsgInfo(STR0011,cTitTela) //STR0011 # "Processo finalizado com sucesso!"
					VC0500011_Montagem_Dados_do_Browse(3) // Lista Execuções
					VC0500011_Montagem_Dados_do_Browse(1) // Lista Clientes/Veiculos da Execução selecionada
				Else
					MsgStop(STR0012,cTitTela) //STR0012 # "Não foram encontradas novas informações. Impossivel gerar o arquivo!"
				EndIf
			EndIf
		EndIf
	Case nBotAcionado == 3 // 3-Exclusao
		If len(aBrwExe) > 0
			nLinExe  := oBrwExe:At()
			cTitTela := IIf(aBrwExe[nLinExe,1]=="1",STR0007,STR0009) //STR0007 # "Carga Inicial - SCRM Scania" //STR0009 # "Diário - SCRM Scania"
			If FWAlertYesNo(STR0013+PulaLinha+PulaLinha+"- "+;
				Transform(stod(aBrwExe[nLinExe,2]),"@D")+" "+;
				Transform(aBrwExe[nLinExe,3],"@R 99:99"),;
				cTitTela) //STR0013 # "Deseja Excluir o processo?"
				//
				VA1200211_Excluir( aBrwExe[nLinExe,1] , aBrwExe[nLinExe,2] , aBrwExe[nLinExe,3] ) // Excluir registros VEF/VEV/TXT's
				FWAlertSuccess(STR0014,cTitTela) //STR0014 # "Execução excluida com sucesso!"
				VC0500011_Montagem_Dados_do_Browse(3) // Lista Execuções
				VC0500011_Montagem_Dados_do_Browse(1) // Lista Clientes/Veiculos da Execução selecionada
				//
			EndIf
		EndIf
	Case nBotAcionado == 4 //REENVIO CLIENTES SCRM //Criando tela secundaria
		cTitTela := STR0015 // STR0015 # "Reenviar Clientes ao SCRM"

		VC0500011_Montagem_Dados_do_Browse(4) 

		if len(aBrwVCF) > 0
			oDlgVCF := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitTela, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

			oLayerVCF := FWLayer():New()
			oLayerVCF:Init(oDlgVCF, .F., .T.) // Inicializa o layer na janela secundária
			oLayerVCF:AddLine("OBJVCF", 90, .F.) // Adiciona uma linha 90% de altura

			oBrwVCF := FWBrowse():New() 
			oBrwVCF:SetOwner(oLayerVCF:getLinePanel("OBJVCF"))
			oBrwVCF:SetProfileID("BRVCF") 
			oBrwVCF:SetDataArray()
			oBrwVCF:SetArray(aBrwVCF)

			VC0500021_Monta_Colunas_Browse(4)

			aSeekVCF := {}
			VC050007F_Adiciona_Campo_Filtro(@aSeekVCF, "VCF_CODCLI")
			VC050007F_Adiciona_Campo_Filtro(@aSeekVCF, "A1_NOME")
			VC050007F_Adiciona_Campo_Filtro(@aSeekVCF, "A1_CGC")			
			oBrwVCF:SetSeek(, aSeekVCF)

			oBrwVCF:DisableReport()
			oBrwVCF:DisableConfig()
			oBrwVCF:Activate() // Ativa o browse

			ACTIVATE MSDIALOG oDlgVCF CENTERED ON INIT EnchoiceBar(oDlgVCF,{|| VC050004F_Reenvio_SCRM(aBrwVCF) },{|| oDlgVCF:End()})
		else
			FMX_HELP(STR0016, STR0015) //STR0016#"Nenhum cliente elegível encontrado para reenvio." //STR0015#"Reenviar Clientes ao SCRM.
		endif
EndCase
Return

/*/{Protheus.doc} VC050004F_Reenvio_SCRM
Processa o Reenvio dos Clientes Selecionados no Browse
@author Emanuel Furtado
@since 26/11/2025
@param aBrwData, array, Array com os dados do Browse VCF (aBrwVCF).
/*/
Static Function VC050004F_Reenvio_SCRM(aBrwData)
Local aClientes := {}
Local nI := 0
Local nContagem := 0

For nI := 1 To Len(aBrwData)
    If aBrwData[nI][1] //'Marque' = .t.
        AAdd(aClientes, { aBrwData[nI][2] , aBrwData[nI][3] } ) // { VCF_CODCLI, VCF_LOJCLI }
    EndIf
next nI

nContagem := Len(aClientes)

If nContagem == 0
    MsgStop(STR0017, STR0015) //STR0017#"Nenhum cliente foi selecionado para reenvio." //STR0015#"Reenviar Clientes ao SCRM.
    Return .F.
Else    
    If MsgYesNo(STR0018+" ( "+CValToChar(nContagem)+" ) ", STR0015) //STR0018#"Deseja reenviar essa quantidade de cliente(s) para o SCRM?" //STR0015#"Reenviar Clientes ao SCRM.        
        If VEIA120({"","",3,aClientes})            
			VC0500011_Montagem_Dados_do_Browse(3) //atualiza tela principal: Execuções
			VC0500011_Montagem_Dados_do_Browse(1) //atualiza Clientes/Veiculos da Execução selecionada
			oDlgVCF:End()			
        EndIf
    EndIf
EndIf

Return .T.

/*/{Protheus.doc} VC050005F_MarcaLinhaVCF
Função de DoubleClick para marcar/desmarcar a linha atual no Browse VCF.
@author Emanuel Furtado
@since 26/11/2025
/*/
Static Function VC050005F_MarcaLinhaVCF()
Local nLinha := oBrwVCF:nAt // nAt é a linha atual no browse

If nLinha > 0 .And. nLinha <= Len(aBrwVCF)
    aBrwVCF[nLinha][1] := !aBrwVCF[nLinha][1]
    oBrwVCF:Refresh()
EndIf

Return

/*/{Protheus.doc} VC050006F_MarcaTodosVCF
Função de HeaderClick para marcar/desmarcar todos os registros no Browse VCF.
@author Emanuel Furtado
@since 26/11/2025
/*/
Static Function VC050006F_MarcaTodosVCF()
Local nI 		:= 0
Local lMarcar 	:= .T.

// desmarcar todos
For nI := 1 To Len(aBrwVCF)
    If aBrwVCF[nI][1]
        lMarcar := .F. 
        Exit
    EndIf
Next nI

For nI := 1 To Len(aBrwVCF)
    aBrwVCF[nI][1] := lMarcar
Next nI

oBrwVCF:Refresh()

Return


/*/{Protheus.doc} VC050007F_Adiciona_Campo_Filtro
Adiciona um campo ao array de busca (aSeek) para uso com SetSeek em FWBrowse.
@author Emanuel Furtado
@since 10/12/2025
@param aSeekArray, array, Array que armazena as definições de busca (aSeek).
@param cCampoSX3, string, Nome do campo no dicionário SX1 (ex: "VCF_CODCLI", "A1_NOME").
/*/
Static Function VC050007F_Adiciona_Campo_Filtro(aSeekArray, cCampoSX3)
Local cTitulo := GetSx3Cache(cCampoSX3, "X3_TITULO")
Local cTipo   := GetSx3Cache(cCampoSX3, "X3_TIPO")
Local nTamanho:= GetSx3Cache(cCampoSX3, "X3_TAMANHO")
Local nDecimal:= GetSx3Cache(cCampoSX3, "X3_DECIMAL")

AAdd(aSeekArray, {cTitulo, {{"", cTipo, nTamanho, nDecimal, cTitulo}}})

Return