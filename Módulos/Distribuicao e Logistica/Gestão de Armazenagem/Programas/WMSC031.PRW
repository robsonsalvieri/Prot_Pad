#INCLUDE "WMSC030.CH"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"

Static aFieldCC := {}
Static nTotCusRH := 0
Static nTotCusRF := 0
//-----------------------------------------------------------
/*/{Protheus.doc}
Consulta Cálculo de Custo

@author  Tiago Filipe da Silva
@version P11
@Since	  21/10/13
@obs

/*/
//-----------------------------------------------------------
Function WMSC031()
Local aCoors := FWGetDialogSize (oMainWnd)
Local oLayerCC
Local oPanelCC
Local oBrwCC
Local aColsSX3 := {}

	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WMSC030()
	EndIf

	If Pergunte("WMSC030")
		// Cria tabela temporária
		CriaTemp()
		// Carrega a tabela temporária
		CarregaTemp()
		// Trata a altura da janela de acordo com a resolução
		Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel // Calculo de Custo
		// Cria conteiner para os browses
		oLayerCC := FWLayer():New()
		oLayerCC:Init(oDlgPrinc, .F., .T.)

		oLayerCC:AddLine(STR0001, 94, .F.) // 'Consulta Custos'
		oPanelCC := oLayerCC:GetLinePanel (STR0001) // 'Consulta Custos'

		oLayerCC:AddLine( 'SaldoCC', 6, .F.)
		oPanelCCS := oLayerCC:GetLinePanel ('SaldoCC')

		TSay():New( 7,365,{|| STR0002},oPanelCCS,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Total RH
		oSaldoRH := TGet():New( 5,390,{|| nTotCusRH}, oPanelCCS, 70, 9,"!@",,,,,,,.T.,,,{|| .F.},,,,,,,STR0002,,,,.T.) // 'Total RH'

		TSay():New( 7,470,{|| STR0003},oPanelCCS,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Total RF
		oSaldoRH := TGet():New( 5,495,{|| nTotCusRF}, oPanelCCS, 70, 9,"!@",,,,,,,.T.,,,{|| .F.},,,,,,,STR0003,,,,.T.) // 'Total RF'

		// Campos do Browse
		If MV_PAR11 == 1           // Consolidar
			If MV_PAR12 == 1       // Recurso Humano
				aColsCC := {;
					{buscarSX3('DCD_CODFUN',,aColsSX3)       ,{|| ('WMSCALC')->CC_CODFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;         // Titulo, Máscara, Tipo, Alinhamento, Tamanho, Decimal, Editavel,,,,,,,,Carga
					{buscarSX3('DCD_NOMFUN',STR0009,aColsSX3),{|| ('WMSCALC')->CC_NOMFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Nome Funcionário
					{buscarSX3('D05_CODREC',STR0010,aColsSX3),{|| ('WMSCALC')->CC_CODREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Recurso Físico
					{buscarSX3('D05_DESREC',STR0011,aColsSX3),{|| ('WMSCALC')->CC_DESREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Recurso Físico
					{buscarSX3('D12_DATINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRINI}  ,'N',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_DATFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATAFIM},'D',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRFIM}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{STR0004                                 ,{|| ('WMSCALC')->CC_TMPGAST},'C',"@!",2,5,2,.F.,,,,,,,,1},; // Tempo Gasto
					{buscarSX3('DCD_CUSHR',STR0005,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORH},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Custo RH
					{buscarSX3('D05_CUSHR',STR0006,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORF},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Custo RF
					{buscarSX3('D12_DOC',,aColsSX3)          ,{|| ('WMSCALC')->CC_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_PRODUT',,aColsSX3)       ,{|| ('WMSCALC')->CC_PRODUTO},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_LOCORI',,aColsSX3)       ,{|| ('WMSCALC')->CC_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_CLIFOR',STR0012,aColsSX3),{|| ('WMSCALC')->CC_CLIFOR} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Cliente/Fornecedor
					{buscarSX3('A1_NOME',STR0013,aColsSX3)   ,{|| ('WMSCALC')->CC_NOMCLI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Nome Cliente/Fornecedor
					{buscarSX3('D12_RHFUNC',,aColsSX3)       ,{|| ('WMSCALC')->CC_RHFUNC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('RJ_DESC',STR0014,aColsSX3)   ,{|| ('WMSCALC')->CC_DESCFUN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Desc. Função RH
					{buscarSX3('D12_SERVIC',,aColsSX3)       ,{|| ('WMSCALC')->CC_SERVIC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('X5_DESCRI',STR0015,aColsSX3) ,{|| ('WMSCALC')->CC_DESCSER},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1}; // Desc. Serviço
				}
			ElseIf MV_PAR12 == 2   // Recurso Físico
				aColsCC := {;
					{buscarSX3('D05_CODREC',STR0010,aColsSX3),{|| ('WMSCALC')->CC_CODREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Recurso Físico
					{buscarSX3('D05_DESREC',STR0011,aColsSX3),{|| ('WMSCALC')->CC_DESREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Recurso Físico
					{buscarSX3('DCD_CODFUN',,aColsSX3)       ,{|| ('WMSCALC')->CC_CODFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('DCD_NOMFUN',STR0009,aColsSX3),{|| ('WMSCALC')->CC_NOMFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Nome Funcionário
					{buscarSX3('D12_DATINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRINI}  ,'N',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_DATFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATAFIM},'D',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRFIM}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{STR0004                                 ,{|| ('WMSCALC')->CC_TMPGAST},'C',"@!",2,5,2,.F.,,,,,,,,1},; // Tempo Gasto
					{buscarSX3('DCD_CUSHR',STR0005,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORH},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Custo RH
					{buscarSX3('D05_CUSHR',STR0006,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORF},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Custo RF
					{buscarSX3('D12_DOC',,aColsSX3)          ,{|| ('WMSCALC')->CC_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_PRODUT',,aColsSX3)       ,{|| ('WMSCALC')->CC_PRODUTO},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_LOCORI',,aColsSX3)       ,{|| ('WMSCALC')->CC_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_CLIFOR',STR0012,aColsSX3),{|| ('WMSCALC')->CC_CLIFOR} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Cliente/Fornecedor
					{buscarSX3('A1_NOME',STR0013,aColsSX3)   ,{|| ('WMSCALC')->CC_NOMCLI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Nome Cliente/Fornecedor
					{buscarSX3('D12_RHFUNC',,aColsSX3)       ,{|| ('WMSCALC')->CC_RHFUNC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('RJ_DESC',STR0014,aColsSX3)   ,{|| ('WMSCALC')->CC_DESCFUN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Desc. Função RH
					{buscarSX3('D12_SERVIC',,aColsSX3)       ,{|| ('WMSCALC')->CC_SERVIC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('X5_DESCRI',STR0015,aColsSX3) ,{|| ('WMSCALC')->CC_DESCSER},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1}; // Desc. Serviço
					}
			ElseIf MV_PAR12 == 3    // Cliente
				aColsCC := {;
					{buscarSX3('D12_CLIFOR',STR0012,aColsSX3),{|| ('WMSCALC')->CC_CLIFOR} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Cliente/Fornecedor
					{buscarSX3('A1_NOME',STR0013,aColsSX3)   ,{|| ('WMSCALC')->CC_NOMCLI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Nome Cliente/Fornecedor
					{buscarSX3('DCD_CODFUN',,aColsSX3)       ,{|| ('WMSCALC')->CC_CODFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('DCD_NOMFUN',STR0009,aColsSX3),{|| ('WMSCALC')->CC_NOMFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Nome Funcionário
					{buscarSX3('D05_CODREC',STR0010,aColsSX3),{|| ('WMSCALC')->CC_CODREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Recurso Físico
					{buscarSX3('D05_DESREC',STR0011,aColsSX3),{|| ('WMSCALC')->CC_DESREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Recurso Físico
					{buscarSX3('D12_DATINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRINI}  ,'N',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_DATFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATAFIM},'D',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRFIM}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{STR0004                                 ,{|| ('WMSCALC')->CC_TMPGAST},'C',"@!",2,5,2,.F.,,,,,,,,1},; // Tempo Gasto
					{buscarSX3('DCD_CUSHR',STR0005,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORH},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RH
					{buscarSX3('D05_CUSHR',STR0006,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORF},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RF
					{buscarSX3('D12_DOC',,aColsSX3)          ,{|| ('WMSCALC')->CC_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_PRODUT',,aColsSX3)       ,{|| ('WMSCALC')->CC_PRODUTO},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_LOCORI',,aColsSX3)       ,{|| ('WMSCALC')->CC_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_RHFUNC',,aColsSX3)       ,{|| ('WMSCALC')->CC_RHFUNC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('RJ_DESC',STR0014,aColsSX3)   ,{|| ('WMSCALC')->CC_DESCFUN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Função RH
					{buscarSX3('D12_SERVIC',,aColsSX3)       ,{|| ('WMSCALC')->CC_SERVIC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('X5_DESCRI',STR0015,aColsSX3) ,{|| ('WMSCALC')->CC_DESCSER},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1}; // Desc. Serviço
							 }
			ElseIf MV_PAR12 == 4    // Serviço
				aColsCC := {;
					{buscarSX3('D12_SERVIC',,aColsSX3)        ,{|| ('WMSCALC')->CC_SERVIC},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;	// Titulo, Máscara, Tipo, Alinhamento, Tamanho, Decimal, Editavel,,,,,,,,Carga
					{buscarSX3('X5_DESCRI',STR0015,aColsSX3) ,{|| ('WMSCALC')->CC_DESCSER},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Desc. Serviço
					{buscarSX3('DCD_CODFUN',,aColsSX3)       ,{|| ('WMSCALC')->CC_CODFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('DCD_NOMFUN',STR0009,aColsSX3),{|| ('WMSCALC')->CC_NOMFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Nome Funcionário
					{buscarSX3('D05_CODREC',STR0010,aColsSX3),{|| ('WMSCALC')->CC_CODREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Recurso Físico
					{buscarSX3('D05_DESREC',STR0011,aColsSX3),{|| ('WMSCALC')->CC_DESREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Recurso Físico
					{buscarSX3('D12_DATINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRINI}  ,'N',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_DATFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATAFIM},'D',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRFIM}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{STR0004                                 ,{|| ('WMSCALC')->CC_TMPGAST},'C',"@!",2,5,2,.F.,,,,,,,,1},; // Tempo Gasto
					{buscarSX3('DCD_CUSHR',STR0005,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORH},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RH
					{buscarSX3('D05_CUSHR',STR0006,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORF},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RF
					{buscarSX3('D12_DOC',,aColsSX3)          ,{|| ('WMSCALC')->CC_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_PRODUT',,aColsSX3)       ,{|| ('WMSCALC')->CC_PRODUTO},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_LOCORI',,aColsSX3)       ,{|| ('WMSCALC')->CC_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_CLIFOR',STR0012,aColsSX3),{|| ('WMSCALC')->CC_CLIFOR} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Cliente/Fornecedor
					{buscarSX3('A1_NOME',STR0013,aColsSX3)   ,{|| ('WMSCALC')->CC_NOMCLI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;   // Nome Cliente/Fornecedor
					{buscarSX3('D12_RHFUNC',,aColsSX3)       ,{|| ('WMSCALC')->CC_RHFUNC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('RJ_DESC',STR0014,aColsSX3)   ,{|| ('WMSCALC')->CC_DESCFUN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};  // Desc. Função RH
							 }
			ElseIf MV_PAR12 == 5    // Função
				aColsCC := {;
					{buscarSX3('D12_RHFUNC',,aColsSX3)       ,{|| ('WMSCALC')->CC_RHFUNC},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('RJ_DESC',STR0014,aColsSX3)   ,{|| ('WMSCALC')->CC_DESCFUN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Função RH
					{buscarSX3('DCD_CODFUN',,aColsSX3)       ,{|| ('WMSCALC')->CC_CODFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Titulo, Máscara, Tipo, Alinhamento, Tamanho, Decimal, Editavel,,,,,,,,Carga
					{buscarSX3('DCD_NOMFUN',STR0009,aColsSX3),{|| ('WMSCALC')->CC_NOMFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Nome Funcionário
					{buscarSX3('D05_CODREC',STR0010,aColsSX3),{|| ('WMSCALC')->CC_CODREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Recurso Físico
					{buscarSX3('D05_DESREC',STR0011,aColsSX3),{|| ('WMSCALC')->CC_DESREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Recurso Físico
					{buscarSX3('D12_DATINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRINI}  ,'N',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_DATFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATAFIM},'D',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRFIM}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{STR0004                                 ,{|| ('WMSCALC')->CC_TMPGAST},'C',"@!",2,5,2,.F.,,,,,,,,1},; // Tempo Gasto
					{buscarSX3('DCD_CUSHR',STR0005,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORH},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RH
					{buscarSX3('D05_CUSHR',STR0006,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORF},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RF
					{buscarSX3('D12_DOC',,aColsSX3)          ,{|| ('WMSCALC')->CC_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_PRODUT',,aColsSX3)       ,{|| ('WMSCALC')->CC_PRODUTO},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_LOCORI',,aColsSX3)       ,{|| ('WMSCALC')->CC_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_CLIFOR',STR0012,aColsSX3),{|| ('WMSCALC')->CC_CLIFOR} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Cliente/Fornecedor
					{buscarSX3('A1_NOME',STR0013,aColsSX3)   ,{|| ('WMSCALC')->CC_NOMCLI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;   // Nome Cliente/Fornecedor
					{buscarSX3('D12_SERVIC',,aColsSX3)       ,{|| ('WMSCALC')->CC_SERVIC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('X5_DESCRI',STR0015,aColsSX3) ,{|| ('WMSCALC')->CC_DESCSER},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1}; // Desc. Serviço
							}
			EndIf
		Else
			aColsCC:= {;
					{buscarSX3('DCD_CODFUN',,aColsSX3)       ,{|| ('WMSCALC')->CC_CODFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Titulo, Máscara, Tipo, Alinhamento, Tamanho, Decimal, Editavel,,,,,,,,Carga
					{buscarSX3('DCD_NOMFUN',STR0009,aColsSX3),{|| ('WMSCALC')->CC_NOMFUN} ,'C',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Nome Funcionário
					{buscarSX3('D05_CODREC',STR0010,aColsSX3),{|| ('WMSCALC')->CC_CODREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Recurso Físico
					{buscarSX3('D05_DESREC',STR0011,aColsSX3),{|| ('WMSCALC')->CC_DESREC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Recurso Físico
					{buscarSX3('D12_DATINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_RHFUNC',,aColsSX3)       ,{|| ('WMSCALC')->CC_RHFUNC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('RJ_DESC',STR0014,aColsSX3)   ,{|| ('WMSCALC')->CC_DESCFUN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;  // Desc. Função RH
					{buscarSX3('D12_HORINI',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRINI}  ,'N',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_DATFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_DATAFIM},'D',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_HORFIM',,aColsSX3)       ,{|| ('WMSCALC')->CC_HRFIM}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{STR0004                                 ,{|| ('WMSCALC')->CC_TMPGAST},'C',"@!",2,5,2,.F.,,,,,,,,1},; // Tempo Gasto
					{buscarSX3('DCD_CUSHR',STR0005,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORH},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RH
					{buscarSX3('D05_CUSHR',STR0006,aColsSX3) ,{|| ('WMSCALC')->CC_CUSTORF},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Custo RF
					{buscarSX3('D12_DOC',,aColsSX3)          ,{|| ('WMSCALC')->CC_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_PRODUT',,aColsSX3)       ,{|| ('WMSCALC')->CC_PRODUTO},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_LOCORI',,aColsSX3)       ,{|| ('WMSCALC')->CC_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('D12_CLIFOR',STR0012,aColsSX3),{|| ('WMSCALC')->CC_CLIFOR} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Cliente/Fornecedor
					{buscarSX3('A1_NOME',STR0013,aColsSX3)   ,{|| ('WMSCALC')->CC_NOMCLI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;   // Nome Cliente/Fornecedor
					{buscarSX3('D12_SERVIC',,aColsSX3)       ,{|| ('WMSCALC')->CC_SERVIC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
					{buscarSX3('X5_DESCRI',STR0015,aColsSX3) ,{|| ('WMSCALC')->CC_DESCSER},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1}; // Desc. Serviço
						}
		EndIf
	
		oBrwCC := FWMBrowse():New()
		oBrwCC:SetAlias('WMSCALC')
		oBrwCC:SetOwner(oPanelCC)
		oBrwCC:SetFields(aColsCC)
		oBrwCC:SetMenuDef('')
		oBrwCC:AddButton(STR0007, {|| oDlgPrinc:End()},, 2, 0) // Sair
		If MV_PAR11 == 1
			oBrwCC:SetGroup({ || IIf(('WMSCALC')->CC_ORDEM == '0',.T.,.F.)},.F.)
		EndIf
		oBrwCC:SetAmbiente(.F.)
		oBrwCC:SetWalkThru(.F.)
		oBrwCC:DisableDetails()
		oBrwCC:SetFixedBrowse(.T.)
		oBrwCC:SetDescription(STR0008) // Consulta Custos
		oBrwCC:SetProfileID('1')
		oBrwCC:SetTotalColumns()
	
		oBrwCC:Activate()
	
		// Ativa a janela e efetua a carga das consultas e criação dos browsers
		Activate MsDialog oDlgPrinc Center
	
		delTabTmp('WMSCALC')
	EndIf
Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc}
Cria tabela temporária

@author  Tiago Filipe da Silva
@version P12
@Since	22/10/13
@version 1.0
@obs

/*/
//-----------------------------------------------------------
Static Function CriaTemp()
Local aColsSX3 := {}
	//-------------------------------
	// Cria tabela temporária para Consulta
	//-------------------------------
	aFieldCC := {}

	AAdd(aFieldCC,{'CC_SEQUEN' ,'C',6,0})

	buscarSX3('DCD_CODFUN',,aColsSX3)
	AAdd(aFieldCC,{'CC_CODFUN' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DCD_NOMFUN',,aColsSX3)
	AAdd(aFieldCC,{'CC_NOMFUN' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_DATINI',,aColsSX3)
	AAdd(aFieldCC,{'CC_DATA' ,'D',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_HORINI',,aColsSX3)
	AAdd(aFieldCC,{'CC_HRINI' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_DATFIM',,aColsSX3)
	AAdd(aFieldCC,{'CC_DATAFIM' ,'D',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_HORFIM',,aColsSX3)
	AAdd(aFieldCC,{'CC_HRFIM' ,'C',aColsSX3[3],aColsSX3[4]})

	AAdd(aFieldCC,{'CC_TMPGAST' ,'C',5,0})

	AAdd(aFieldCC,{'CC_ORDEM' ,'C',1,0})

	buscarSX3('DCD_CUSHR',,aColsSX3)
	AAdd(aFieldCC,{'CC_CUSTORH' ,'N',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D05_CODREC',,aColsSX3)
	AAdd(aFieldCC,{'CC_CODREC' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D05_DESREC',,aColsSX3)
	AAdd(aFieldCC,{'CC_DESREC' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D05_CUSHR',,aColsSX3)
	AAdd(aFieldCC,{'CC_CUSTORF' ,'N',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_DOC',,aColsSX3)
	AAdd(aFieldCC,{'CC_DOC' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_PRODUT',,aColsSX3)
	AAdd(aFieldCC,{'CC_PRODUTO' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_LOCORI',,aColsSX3)
	AAdd(aFieldCC,{'CC_LOCAL' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_CLIFOR',,aColsSX3)
	AAdd(aFieldCC,{'CC_CLIFOR' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('A1_NOME',,aColsSX3)
	AAdd(aFieldCC,{'CC_NOMCLI' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_RHFUNC',,aColsSX3)
	AAdd(aFieldCC,{'CC_RHFUNC' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('RJ_DESC',,aColsSX3)
	AAdd(aFieldCC,{'CC_DESCFUN' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D12_SERVIC ',,aColsSX3)
	AAdd(aFieldCC,{'CC_SERVIC' ,'C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('X5_DESCRI ',,aColsSX3)
	AAdd(aFieldCC,{'CC_DESCSER' ,'C',aColsSX3[3],aColsSX3[4]})

	If MV_PAR11 == 1
		If MV_PAR12 == 1
			criaTabTmp(aFieldCC,{'CC_CODFUN+CC_CODREC+DtoS(CC_DATA)+CC_SEQUEN'},'WMSCALC')
		ElseIf MV_PAR12 == 2
			criaTabTmp(aFieldCC,{'CC_CODREC+CC_CODFUN+DtoS(CC_DATA)+CC_SEQUEN'},'WMSCALC')
		ElseIf MV_PAR12 == 3
			criaTabTmp(aFieldCC,{'CC_CLIFOR+CC_CODFUN+CC_CODREC+DtoS(CC_DATA)+CC_SEQUEN'},'WMSCALC')
		ElseIf MV_PAR12 == 4
			criaTabTmp(aFieldCC,{'CC_SERVIC+CC_CODFUN+CC_CODREC+DtoS(CC_DATA)+CC_SEQUEN'},'WMSCALC')
		ElseIf MV_PAR12 == 5
			criaTabTmp(aFieldCC,{'CC_RHFUNC+CC_CODFUN+CC_CODREC+DtoS(CC_DATA)+CC_SEQUEN'},'WMSCALC')
		EndIf
	Else
		criaTabTmp(aFieldCC,{'CC_CODFUN+CC_CODREC+DtoS(CC_DATA)+CC_SEQUEN'},'WMSCALC')
	EndIf
Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc}
Carrega tabela temporária

@author  Tiago Filipe da Silva
@version P12
@Since	31/10/13
@version 1.0
@obs Função para popular a tabela temporária do Calculo de Custo

/*/
//-----------------------------------------------------------
Static Function CarregaTemp()
Local cAliasQuery := GetNextAlias()
Local cOrder      := ''
Local cCampoAgru  := ''
Local cCodigoFun  := ''
Local cNomeFun    := ''
Local cCodRecFis  := ''
Local cDesRecFis  := ''
Local cCliFor     := ''
Local cNomCli     := ''
Local cServico    := ''
Local cDescServ   := ''
Local cFuncaoRH   := ''
Local cDescFunc   := ''
Local cSequen     := '000000'
Local cQuery      := ''
Local nTotLinRH   := 0
Local nTotLinRF   := 0
Local nTempoGas   := 0
Local nTotTmpGas  := 0
Local nCustoRH    := 0
Local nCustoRF    := 0
Local aDadosCC    := {}

	If MV_PAR11 == 1
		If MV_PAR12 == 1
			cOrder     := 'DCD_CODFUN, D05_CODREC, D12_DATINI'
			cCampoAgru := 'DCD_CODFUN'
		ElseIf MV_PAR12 == 2
			cOrder     := 'D05_CODREC, DCD_CODFUN, D12_DATINI'
			cCampoAgru := 'D05_CODREC'
		ElseIf MV_PAR12 == 3
			cOrder     := 'D12_CLIFOR, DCD_CODFUN, D05_CODREC, D12_DATINI'
			cCampoAgru := 'D12_CLIFOR'
		ElseIf MV_PAR12 == 4
			cOrder     := 'D12_SERVIC, DCD_CODFUN, D05_CODREC, D12_DATINI'
			cCampoAgru := 'D12_SERVIC'
		ElseIf MV_PAR12 == 5
			cOrder     := 'D12_RHFUNC, DCD_CODFUN, D05_CODREC, D12_DATINI'
			cCampoAgru := 'D12_RHFUNC'
		EndIf
	Else
		cOrder     := 'DCD_CODFUN, D05_CODREC, D12_DATINI'
		cCampoAgru := 'D12_RHFUNC'
	EndIf

	cQuery :=  " SELECT DCD.DCD_CODFUN, "
	cQuery +=         " DCD.DCD_NOMFUN, "
	cQuery +=         " DCD.DCD_CUSHR, "
	cQuery +=         " D12.D12_DATINI, "
	cQuery +=         " D12.D12_HORINI, "
	cQuery +=         " D12.D12_DATFIM, "
	cQuery +=         " D12.D12_HORFIM, "
	cQuery +=         " D12.D12_DOC, "
	cQuery +=         " D12.D12_PRODUT, "
	cQuery +=         " D12.D12_LOCORI, "
	cQuery +=         " D12.D12_CLIFOR, "
	cQuery +=         " D12.D12_RHFUNC, "
	cQuery +=         " D12.D12_SERVIC, "
	cQuery +=         " D05.D05_CUSHR, "
	cQuery +=         " D05.D05_CODREC, "
	cQuery +=         " D05.D05_DESREC "
	cQuery +=    " FROM "+RETSQLNAME("DCD")+" DCD "
	cQuery +=   " INNER JOIN "+RETSQLNAME("D12")+" D12 "
	cQuery +=      " ON D12.D12_RECHUM = DCD.DCD_CODFUN "
	cQuery +=     " AND D12.D12_FILIAL = '"+xFilial("D12")+"' "
	cQuery +=     " AND D12.D_E_L_E_T_ = ' ' "
	cQuery +=   " INNER JOIN "+RETSQLNAME("D05")+" D05 "
	cQuery +=      " ON D05.D05_CODREC = D12.D12_RECFIS "
	cQuery +=     " AND D05.D05_FILIAL = '"+xFilial("D05")+"' "
	cQuery +=     " AND D05.D_E_L_E_T_ = ' ' "
	cQuery +=   " WHERE DCD.DCD_FILIAL = '"+xFilial("DCD")+"' "
	cQuery +=     " AND DCD_CODFUN BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery +=     " AND D05_CODREC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQuery +=     " AND D12_CLIFOR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery +=     " AND D12_SERVIC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cQuery +=     " AND D12_DATINI BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"' "
	cQuery +=     " AND D12_STATUS = '1' "
	cQuery +=     " AND DCD.D_E_L_E_T_ = ' ' "
	cQuery +=   " ORDER BY " + cOrder
	
	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQuery,.F.,.T.)
	TCSETFIELD( cAliasQuery,'D12_DATINI','D')
	TCSETFIELD( cAliasQuery,'D12_DATFIM','D')

	DBSelectArea(cAliasQuery)
	(cAliasQuery)->( dbGoTop() )
	While (cAliasQuery)->( !Eof() )
		cAgrup := (cAliasQuery)->&cCampoAgru
		While (cAliasQuery)->( !Eof() ) .And. (cAliasQuery)->&cCampoAgru = cAgrup
			// Calculo de custo e tempo gasto
			nTempoGas := WMSCALTIME((cAliasQuery)->D12_DATINI,(cAliasQuery)->D12_HORINI,(cAliasQuery)->D12_DATFIM,(cAliasQuery)->D12_HORFIM)  // Tempo Gasto na tarefa
			nCustoRH  := nTempoGas * (cAliasQuery)->DCD_CUSHR
			nCustoRF  := nTempoGas * (cAliasQuery)->D05_CUSHR
			cSequen   := Soma1(cSequen)
			cTempoGas := NtoH(nTempoGas)

			cNomCli   := POSICIONE("SA1",1,xFilial("SA1")+(cAliasQuery)->D12_CLIFOR,"A1_NOME")
			cDescFunc := POSICIONE("SRJ",1,xFilial("SRJ")+(cAliasQuery)->D12_RHFUNC,"RJ_DESC")
			cDescServ := FWGetSX5("L4",(cAliasQuery)->D12_SERVIC)[1,4]

			AAdd(aDadosCC,{cSequen,(cAliasQuery)->DCD_CODFUN,(cAliasQuery)->DCD_NOMFUN,(cAliasQuery)->D12_DATINI,(cAliasQuery)->D12_HORINI, (cAliasQuery)->D12_DATFIM,(cAliasQuery)->D12_HORFIM, cTempoGas, '1', nCustoRH, (cAliasQuery)->D05_CODREC, (cAliasQuery)->D05_DESREC, nCustoRF, (cAliasQuery)->D12_DOC, (cAliasQuery)->D12_PRODUT, (cAliasQuery)->D12_LOCORI, (cAliasQuery)->D12_CLIFOR, cNomCli, (cAliasQuery)->D12_RHFUNC, cDescFunc, (cAliasQuery)->D12_SERVIC, cDescServ})

			// Totalizadores
			nTotLinRF  += Round(nCustoRF,2)
			nTotLinRH  += Round(nCustoRH,2)
			nTotTmpGas += nTempoGas
			cCodigoFun := (cAliasQuery)->DCD_CODFUN
			cNomeFun   := (cAliasQuery)->DCD_NOMFUN
			cCodRecFis := (cAliasQuery)->D05_CODREC
			cDesRecFis := (cAliasQuery)->D05_DESREC
			cCliFor    := (cAliasQuery)->D12_CLIFOR
			cServico   := (cAliasQuery)->D12_SERVIC
			cFuncaoRH  := (cAliasQuery)->D12_RHFUNC

			(cAliasQuery)->( dbSkip() )
		Enddo

		nTotCusRH  += nTotLinRH
		nTotCusRF  += nTotLinRF

		If MV_PAR11 == 1
			cSequen := Soma1(cSequen)
			nTotCusRH  := Round(nTotCusRH,2)
			nTotCusRF  := Round(nTotCusRF,2)
			nTotTmpGas := NtoH(nTotTmpGas)

			If MV_PAR12 == 1     // Recurso Humano
				AAdd(aDadosCC,{cSequen, cCodigoFun, cNomeFun, StoD('  /  /  '), '', StoD('  /  /  '), '', nTotTmpGas, '0', nTotLinRH, '', '', nTotLinRF, '', '', '', '', '', '', '', '', ''})
			ElseIf MV_PAR12 == 2  // Recurso Físico
				AAdd(aDadosCC,{cSequen, '', '',StoD('  /  /  '), '', StoD('  /  /  '), '', nTotTmpGas, '0', nTotLinRH, cCodRecFis, cDesRecFis, nTotLinRF, '', '', '', '', '', '', '', '', ''})
			ElseIf MV_PAR12 == 3  // Cliente
				AAdd(aDadosCC,{cSequen, '', '',StoD('  /  /  '), '', StoD('  /  /  '), '', nTotTmpGas, '0', nTotLinRH, '', '', nTotLinRF, '', '', '', cCliFor, cNomCli, '', '', '', ''})
			ElseIf MV_PAR12 == 4  // Serviço
				AAdd(aDadosCC,{cSequen, '', '',StoD('  /  /  '), '', StoD('  /  /  '), '', nTotTmpGas, '0', nTotLinRH, '', '', nTotLinRF, '', '', '', '', '', '', '', cServico, cDescServ})
			ElseIf MV_PAR12 == 5  // Função
				AAdd(aDadosCC,{cSequen, '', '',StoD('  /  /  '), '', StoD('  /  /  '), '', nTotTmpGas, '0', nTotLinRH, '', '', nTotLinRF, '', '', '', '', '', cFuncaoRH, cDescFunc, '', ''})
			EndIf
		EndIf

		nTotLinRH  := 0
		nTotLinRF  := 0
		nTotTmpGas := 0

	Enddo
	(cAliasQuery)->( DBCloseArea())
	// Ordenação dos resultados
	If MV_PAR11 == 1
		If MV_PAR12 == 1  // Recurso Humano
			aSort(aDadosCC,,, {|x,y| y[2]+y[9]+y[11]+DtoS(y[4])+y[5] > x[2]+x[9]+x[11]+DtoS(x[4])+x[5]})
		ElseIf MV_PAR12 == 2 // Recurso Físico
			aSort(aDadosCC,,, {|x,y| y[11]+y[9]+y[2]+DtoS(y[4])+y[5] > x[11]+x[9]+x[2]+DtoS(x[4])+x[5]})
		ElseIf MV_PAR12 == 3 // Cliente
			aSort(aDadosCC,,, {|x,y| y[17]+y[9]+y[2]+y[11]+DtoS(y[4])+y[5] > x[17]+x[9]+x[2]+x[11]+DtoS(x[4])+x[5]})
		ElseIf MV_PAR12 == 4 // Serviço
			aSort(aDadosCC,,, {|x,y| y[21]+y[9]+y[2]+y[11]+DtoS(y[4])+y[5] > x[21]+x[9]+x[2]+x[11]+DtoS(x[4])+x[5]})
		ElseIf MV_PAR12 == 5 // Função
			aSort(aDadosCC,,, {|x,y| y[19]+y[9]+y[2]+y[11]+DtoS(y[4])+y[5] > x[19]+x[9]+x[2]+x[11]+DtoS(x[4])+x[5]})
		EndIf
	Else
		aSort(aDadosCC,,, {|x,y| y[2]+y[9]+y[11]+DtoS(y[4])+y[5] > x[2]+x[9]+x[11]+DtoS(x[4])+x[5]})
	EndIf
	// Carrega a tabela temporária com os dados da query
	MntCargDad('WMSCALC',aDadosCC, aFieldCC)
Return .T.