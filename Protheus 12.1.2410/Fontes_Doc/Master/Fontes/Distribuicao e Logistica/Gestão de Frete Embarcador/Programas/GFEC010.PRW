#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

 
/*{Protheus.doc} GFEC010 
Painel Transportador - Cargas
Uso Interno

aParametros
[1]	Código Emitente
[2] Período Inicial
[3] Período Final
[4] Filiais

@author Israel A. Possoli / Alan Victor Lamb
@since 07/05/12
@version 1.0                                                                                      
*/

Function GFEC010(aParametros)
	Local aCoors := FWGetDialogSize( oMainWnd )
	Private oLayer
	Private oTree
	Private oTituloBar
	Private oPanelAtual, oPanelBar, oPanelGra
	Private oChartBar
	Private cFilialIni, cFilialFim
	Private cDataRefIni, cDataRefFim
	Private cNodeTree := "GW1"  //Variavel responsavel por armazenar o nó atual, ela começa setada para o nó GW11
	Private oProcess := nil     // Variável que receberá a regua de processamento
	
	Private oPanelGW1, oBrwGW1,;
			oPanelGWV, oBrwGWV,;
			oPanelGWN, oBrwGWN,;
			oPanelGWD, oBrwGWD,;
			oPanelGV9, oBrwGV9,;
			oPanelGWF, oBrwGWF,;
			oPanelGWO, oBrwGWO,;
			oPanelGWJ, oBrwGWJ,;
			oPanelGW3, oBrwGW3,;
			oPanelGW6, oBrwGW6,;
			oPanelGW2, oBrwGW2

	Private FiltroGW1[5], TotaisGW1[6], ;
			FiltroGWV[1], TotaisGWV[2], ;
			FiltroGWN[3], TotaisGWN[4], ;
			FiltroGWN[4], TotaisGWN[5], ;
			FiltroGWD[1], TotaisGWD[2], ;
			FiltroGV9[1], TotaisGV9[2], ;
			FiltroGWF[2], TotaisGWF[3], ;
			FiltroGWO[1], TotaisGWO[2], ;
			FiltroGWJ[3], TotaisGWJ[4], ;
			FiltroGW3[2], TotaisGW3[3], ;
			FiltroGW6[2], TotaisGW6[3], ;
			FiltroGW2[2], TotaisGW2[3]  
			
	If !Pergunte("GFEC010")
		Return .F.
	EndIf
	
	cFilialIni	  := MV_PAR01
	cFilialFim	  := MV_PAR02
	cDataRefIni  := MV_PAR03
	cDataRefFim  := MV_PAR04
	
	Define MsDialog oDlgPrinc Title 'Sumário - Pendências' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	// Layers de layout da tela ----------------
	oLayer := FWLayer():New()
	oLayer:Init(oDlgPrinc, .F.)
	oLayer:AddLine('LINE', 100, .T.)
	oLayer:AddCollumn('COL_LEFT',  20, .T., "LINE")
	oLayer:AddCollumn('COL_RIGHT', 80, .T., "LINE") 
	
	oProcess := MsNewProcess():New({||CarregarConsultas()}, "Carregando consultas", "Iniciando processo...") 
	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	oDlgPrinc:Activate(,,,.T.,,,{||oProcess:Activate()})
Return

//------------------------------------------------------------------------------------------------
/* CarregarConsultas
Carrega as consultas e os valores pré-calculados
Quando a base possui muitos registros, pode levar algum tempo para a carga
Utiliza o ProcessBar para acompanhar a carga dos dados

@author ISRAEL A. POSSOLI
@since 17/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function CarregarConsultas()
	oProcess:setRegua1(5)

	oProcess:incRegua1("Iniciando Gerencial") //"Processando dados de entrada..."
   	
	CriaPaineis(oLayer:GetColPanel('COL_RIGHT','LINE'))
	
	oProcess:incRegua1()
	DefineFiltros()    
	
	oProcess:incRegua1()
	CriaBrowsers(oLayer:GetColPanel('COL_RIGHT','LINE'))

	oProcess:incRegua1()
	CalculaTotais()           

	oProcess:incRegua1()
	CriaTreeView(oLayer:GetColPanel('COL_LEFT','LINE'))
Return


//------------------------------------------------------------------------------------------------
/* CriaPaineis
Criação dos Painéis para os browsers e o painél da barra de ferramentas

@author Israel A. Possoli / Alan Victor Lamb
@since 14/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function DefineFiltros()
	oProcess:setRegua2(12)
		
	// Documentos de Carga
	oProcess:incRegua2("Definindo Filtros - Documentos de Carga")
	FiltroGW1[1] := "(Empty(GW1_NRROM) .OR. GW1_NRROM == '0') .AND. GW1_SIT == '3' " + FiltroFilialData("GW1", "GW1_DTEMIS") 
	FiltroGW1[2] := "GW1_ENVEDI == '2' .AND. GW1_SIT != '2' .AND. GW1_SIT != '7' .AND. GW1_SIT != '8' " + FiltroFilialData("GW1", "GW1_DTEMIS") 
	FiltroGW1[3] := "GW1_SIT != '6' .And. GW1_SIT != '5' .AND. GW1_SIT != '2' .AND. GW1_SIT != '7' .AND. GW1_SIT != '8' " + FiltroFilialData("GW1", "GW1_DTEMIS")
	FiltroGW1[4] :="@D_E_L_E_T_ = ' ' AND NOT EXISTS (select GW4_FILIAL FROM " + RetSqlName("GW4") + " WHERE GW4_FILIAL = GW1_FILIAL AND GW4_TPDC = GW1_CDTPDC AND GW4_EMISDC = GW1_EMISDC AND GW4_SERDC = GW1_SERDC AND GW4_NRDC = GW1_NRDC AND D_E_L_E_T_ = ' ' ) AND GW1_DTEMIS >= '"+DToS(MV_PAR03)+"' AND GW1_DTEMIS <= '"+DToS(MV_PAR04)+ "' AND GW1_FILIAL >= '"+MV_PAR01+"' AND GW1_FILIAL <= '"+MV_PAR02+"' "
	FiltroGW1[5] := "@GW1_NRROM = '' and (not (GW1_SIT in ('2','7','8'))) and exists (select GV5_CALC from " + RetSqlName("GV5") + " where GV5_CDTPDC = GW1_CDTPDC AND GV5_CALC = '2') AND GW1_DTEMIS >= '"+DToS(MV_PAR03)+"' AND GW1_DTEMIS <= '"+DToS(MV_PAR04)+ "' AND GW1_FILIAL >= '"+MV_PAR01+"' AND GW1_FILIAL <= '"+MV_PAR02+"' " 
	//FiltroGW1[5] := "@isnull(GW1_NRROM,'') = '' and (not (GW1_SIT in ('2','7','8'))) and exists (select GV5_CALC from " + RetSqlName("GV5") + " where GV5_CDTPDC = GW1_CDTPDC AND GV5_CALC = '2') AND GW1_DTEMIS >= '"+DToS(MV_PAR03)+"' AND GW1_DTEMIS <= '"+DToS(MV_PAR04)+ "' "

	// Agendamentos 
	oProcess:incRegua2("Definindo Filtros - Agendamentos ")
	FiltroGWV[1] := "GWV_SIT == '1'"  + FiltroFilialData("GWV", "GWV_DTAGEN")
	
	// Romaneios   
	oProcess:incRegua2("Definindo Filtros - Romaneios  ")
	FiltroGWN[1] := "(GWN_SIT == '1' .OR. GWN_SIT == '2') " + FiltroFilialData("GWN", "GWN_DTIMPL")
	FiltroGWN[2] := "GWN_CALC != '1'"					  + FiltroFilialData("GWN", "GWN_DTIMPL")
	FiltroGWN[3] := "GWN_SIT == '3'"					  + FiltroFilialData("GWN", "GWN_DTIMPL")
	If GFXCP12117("GWN_ENVNFE")
		FiltroGWN[4] := "GWN_ENVNFE = '2'"					  + FiltroFilialData("GWN", "GWN_DTIMPL")
	EndIf

	// Ocorrências 
	oProcess:incRegua2("Definindo Filtros - Ocorrências   ")
	FiltroGWD[1] := "GWD_SIT == '1' "	+ FiltroFilialData("GWD", "GWD_DTOCOR")
	
	// Negociações da Tabela de Fretes
	oProcess:incRegua2("Definindo Filtros - Tabela de Fretes   ")
	FiltroGV9[1] := "GV9_SIT == '1'"	+ FiltroFilialData("GV9", "GV9_DTCRIA")
	
	// Cálculo de Frete  
	oProcess:incRegua2("Definindo Filtros - Cálculo de Frete    ")
	FiltroGWF[1] := "Empty(GWF_NRPREF)"							+ FiltroFilialData("GWF", "GWF_DTCRIA")
	FiltroGWF[2] := "Empty(GWF_NRCONT) .AND. GWF_FINCAL == '3'"	+ FiltroFilialData("GWF", "GWF_DTCRIA")
	
	// Ajuste de Frete  
	oProcess:incRegua2("Definindo Filtros - Ajuste de Frete   ")
	FiltroGWO[1] := "GWO_SITAJU == '1'" + FiltroFilialData("GWO", "GWO_DTAJUS")
	
	// Pré Fatura   
	oProcess:incRegua2("Definindo Filtros -  Pré Fatura    ")
	FiltroGWJ[1] := "GWJ_SIT == '1'" 	+ FiltroFilialData("GWJ", "GWJ_DTIMPL")
	FiltroGWJ[2] := "GWJ_SIT == '2'" 	+ FiltroFilialData("GWJ", "GWJ_DTIMPL")
	FiltroGWJ[3] := "Empty(GWJ_NRFAT)" 	+ FiltroFilialData("GWJ", "GWJ_DTIMPL")
	
	// Documento de Frete    
	oProcess:incRegua2("Definindo Filtros - Documento de Frete      ")
	FiltroGW3[1] := "(GW3_SIT == '1' .OR. GW3_SIT == '2' .OR. GW3_SIT == '5') "	+ FiltroFilialData("GW3", "GW3_DTENT")
	FiltroGW3[2] := "Empty(GW3_NRFAT)"				   		+ FiltroFilialData("GW3", "GW3_DTENT")
	
	// Fatura 
	oProcess:incRegua2("Definindo Filtros - Fatura  ")
	FiltroGW6[1] := "GW6_SITAPR == '1'" + FiltroFilialData("GW6", "GW6_DTEMIS")
	FiltroGW6[2] := "GW6_SITAPR == '2'" + FiltroFilialData("GW6", "GW6_DTEMIS")
	
	// Contrato  
	oProcess:incRegua2("Definindo Filtros - Contrato       ")
	FiltroGW2[1] := "GW2_SITCON == '1'"		+ FiltroFilialData("GW2", "GW2_DTCRIA")
	FiltroGW2[2] := "GW2_SITCON == '2'"		+ FiltroFilialData("GW2", "GW2_DTCRIA")
Return

//------------------------------------------------------------------------------------------------
/* FiltroFilialData
Retorna o filtro para o Browse de Filial e Data de Referência

@author Israel A. Possoli
@since 28/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function FiltroFilialData(cTabela, cCampoData, lSQL, lAnd)
	Local cFiltro 		:= ""
	Local cFiltroFilial := ""
	Local cFiltroData 	:= ""
	Default lSQL := .F.
	Default lAnd := .T.
	
	If !Empty(cFilialIni) .AND. !Empty(cFilialFim)
		If lSQL
			cFiltroFilial := cTabela + "_FILIAL >= '" + cFilialIni + "' AND " + cTabela + "_FILIAL <= '" + cFilialFim + "'"
		Else
			cFiltroFilial := cTabela + "->" + cTabela + "_FILIAL >= '" + cFilialIni + "' .AND. " + cTabela + "->" + cTabela + "_FILIAL <= '" + cFilialFim + "'"
		EndIf
	EndIf
	
	If !Empty(cDataRefIni) .AND. !Empty(cDataRefFim)
		If lSQL
			cFiltroData := cCampoData + " >= '" + DTOS(cDataRefIni) + "' AND " + cCampoData + " <= '" + DTOS(cDataRefFim) + "'"
		Else
			cFiltroData := "DTOS(" + cTabela + "->" + cCampoData + ") >= '" + DTOS(cDataRefIni) + "' .AND. DTOS(" + cTabela + "->" + cCampoData + ") <= '" + DTOS(cDataRefFim) + "'"
		EndIf
	EndIf

	If lSQL  
		cFiltro := AllTrim(cFiltroFilial + If(!Empty(cFiltroFilial) .AND. !Empty(cFiltroData)," AND ","") + cFiltroData)
	Else                                                     
		cFiltro := AllTrim(cFiltroFilial + If(!Empty(cFiltroFilial) .AND. !Empty(cFiltroData)," .AND. ","") + cFiltroData)
	EndIf
	

	If !Empty(cFiltro) .AND. lAnd
		If lSQL
			cFiltro := " AND " + cFiltro
		Else
		 	cFiltro := " .AND. " + cFiltro
		EndIf
	EndIf

Return (cFiltro)
//Return  '' 

//------------------------------------------------------------------------------------------------
/* CalculaTotais
Calcula o total do registros de acordo com os filtros
	
@author Israel A. Possoli / Alan Victor Lamb
@since 22/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function CalculaTotais()
	Local cQuery 
	Local cQueryTmp
	Local cFilGW1 := "GW1.GW1_SIT != '2' AND GW1.GW1_SIT != '7' AND GW1.GW1_SIT != '8'"
	
	oProcess:setRegua2(11)
		
	// Documento de Cargas
	oProcess:incRegua2("Calculando Totais - Documento de Cargas ")
	
	TotaisGW1[1] := TotalRecords(GeraQueryTot("GW1", "GW1_DTEMIS", cFilGW1 + " AND (GW1.GW1_NRROM = '' OR GW1.GW1_NRROM = '0') AND GW1_SIT = '3' "))
	TotaisGW1[2] := TotalRecords(GeraQueryTot("GW1", "GW1_DTEMIS", cFilGW1 + " AND GW1.GW1_ENVEDI = '2'"))
	TotaisGW1[3] := TotalRecords(GeraQueryTot("GW1", "GW1_DTEMIS", cFilGW1 + " AND GW1_SIT != '5' AND GW1_SIT != '6'"))
	
	cQueryTmp := FiltroFilialData("GW1", "GW1.GW1_DTEMIS", .T., .F.)
	If !Empty(cQueryTmp)
		cQueryTmp := cQueryTmp + " AND " + cFilGW1 + " AND "
	Else
		cQueryTmp := cFilGW1 + " AND "
	EndIf
	
	// Total de documentos de carga sem documentos de frete
	cQuery := ""	
	cQuery += "  SELECT COUNT(CASE WHEN GW4.GW4_EMISDF IS NULL THEN 1 END) TOTAL "
	cQuery += "    FROM " + RetSqlName("GW1") + " GW1 "
	cQuery += "    LEFT JOIN " + RetSqlName("GW4") + " GW4 ON GW4.GW4_FILIAL = GW1.GW1_FILIAL "
	cQuery += "					   AND GW4.GW4_TPDC = GW1.GW1_CDTPDC "
	cQuery += "					   AND GW4.GW4_EMISDC = GW1.GW1_EMISDC "
	cQuery += "					   AND GW4.GW4_SERDC = GW1.GW1_SERDC "
	cQuery += "					   AND GW4.GW4_NRDC = GW1.GW1_NRDC "
	cQuery += "					   AND GW4.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE " + cQueryTmp + " GW1.D_E_L_E_T_ = ' ' "
	
	TotaisGW1[4] := TotalRecords(cQuery)
	
	//Documentos de Carga de cálculo automático sem romaneio
	If GFEVerCmpo( {"GV5_CALC"}) //Somente se os campos existirem, indica compatibilizador rodado
		cQuery := ""
		cQuery += "SELECT"
		cQuery += "	COUNT(GW1_NRDC) TOTAL"
		cQuery += "	FROM " + RetSqlName("GW1") + " GW1"
		cQuery += "	INNER JOIN " + RetSqlName("GV5") + " GV5"
		cQuery += "	ON GV5.GV5_CDTPDC = GW1.GW1_CDTPDC"
		cQuery += "	WHERE " + cQueryTmp + " GV5.GV5_CALC = '2' AND (GW1.GW1_NRROM = '" + Space(TamSX3("GW1_NRROM" )[1]) + "') "
		cQuery += "	AND GW1.D_E_L_E_T_ = ' ' "
		TotaisGW1[5] := TotalRecords(cQuery)
	EndIf
	//Total de Documentos da filial e periodo
	TotaisGW1[6] := TotalRecords(GeraQueryTot("GW1", "GW1_DTEMIS", cFilGW1))
	
	// Agendamentos 
	oProcess:incRegua2("Calculando Totais - Agendamentos ")
	TotaisGWV[1] := TotalRecords(GeraQueryTot("GWV", "GWV_DTAGEN", "GWV_SIT = '1'"))
	TotaisGWV[2] := TotalRecords(GeraQueryTot("GWV", "GWV_DTAGEN"))
	
	// Romaneios  
	oProcess:incRegua2("Calculando Totais - Romaneios ")
	TotaisGWN[1] := TotalRecords(GeraQueryTot("GWN", "GWN_DTIMPL", " (GWN_SIT = '1' OR GWN_SIT = '2')"))
	TotaisGWN[2] := TotalRecords(GeraQueryTot("GWN", "GWN_DTIMPL", "GWN_CALC != '1'"))
	TotaisGWN[3] := TotalRecords(GeraQueryTot("GWN", "GWN_DTIMPL", "GWN_SIT = '3'"))
	If GFXCP12117("GWN_ENVNFE")
		TotaisGWN[4] := TotalRecords(GeraQueryTot("GWN", "GWN_DTIMPL", "GWN_ENVNFE = '2' "))
	EndIf
	TotaisGWN[5] := TotalRecords(GeraQueryTot("GWN", "GWN_DTIMPL"))
	
	// Ocorrências  
	oProcess:incRegua2("Calculando Totais - Ocorrências ")
	TotaisGWD[1] := TotalRecords(GeraQueryTot("GWD", "GWD_DTOCOR", "GWD_SIT = '1'"))
	TotaisGWD[2] := TotalRecords(GeraQueryTot("GWD", "GWD_DTOCOR"))
	
	// Tabela de Fretes      
	oProcess:incRegua2("Calculando Totais - Tabela de Fretes ")
	TotaisGV9[1] := TotalRecords(GeraQueryTot("GV9", "GV9_DTCRIA", "GV9_SIT = '1'"))
	TotaisGV9[2] := TotalRecords(GeraQueryTot("GV9", "GV9_DTCRIA"))
	
	// Cálculo de Frete 
	oProcess:incRegua2("Calculando Totais - Cálculo de Frete ")
	TotaisGWF[1] := TotalRecords(GeraQueryTot("GWF", "GWF_DTCRIA", "GWF_NRPREF = ''"))
	TotaisGWF[2] := TotalRecords(GeraQueryTot("GWF", "GWF_DTCRIA", "GWF_NRCONT = '' AND GWF_FINCAL = '3'"))
	TotaisGWF[3] := TotalRecords(GeraQueryTot("GWF", "GWF_DTCRIA"))
	
	// Ajuste de Frete
	oProcess:incRegua2("Calculando Totais - Ajuste de Frete ")
	TotaisGWO[1] := TotalRecords(GeraQueryTot("GWO", "GWO_DTAJUS", "GWO_SITAJU = '1'"))
	TotaisGWO[2] := TotalRecords(GeraQueryTot("GWO", "GWO_DTAJUS"))
	
	// Pré Fatura 
	oProcess:incRegua2("Calculando Totais - Pré Fatura  ")
	TotaisGWJ[1] := TotalRecords(GeraQueryTot("GWJ", "GWJ_DTIMPL", "GWJ_SIT = '1'"))
	TotaisGWJ[2] := TotalRecords(GeraQueryTot("GWJ", "GWJ_DTIMPL", "GWJ_SIT = '2'"))
	TotaisGWJ[3] := TotalRecords(GeraQueryTot("GWJ", "GWJ_DTIMPL", "GWJ_NRFAT = ''"))
	TotaisGWJ[4] := TotalRecords(GeraQueryTot("GWJ", "GWJ_DTIMPL"))
	
	// Documento de Frete  
	oProcess:incRegua2("Calculando Totais - Documento de Frete ")
	TotaisGW3[1] := TotalRecords(GeraQueryTot("GW3", "GW3_DTENT", "(GW3_SIT = '1' OR GW3_SIT = '2' OR GW3_SIT = '5')"))
	TotaisGW3[2] := TotalRecords(GeraQueryTot("GW3", "GW3_DTENT", "GW3_NRFAT = ''"))
	TotaisGW3[3] := TotalRecords(GeraQueryTot("GW3", "GW3_DTENT"))
	
	// Fatura 
	oProcess:incRegua2("Calculando Totais - Fatura ")
	TotaisGW6[1] := TotalRecords(GeraQueryTot("GW6", "GW6_DTEMIS", "GW6_SITAPR = '1'"))
	TotaisGW6[2] := TotalRecords(GeraQueryTot("GW6", "GW6_DTEMIS", "GW6_SITAPR = '2'"))
	TotaisGW6[3] := TotalRecords(GeraQueryTot("GW6", "GW6_DTEMIS"))
	
	// Contrato  
	oProcess:incRegua2("Calculando Totais - Contrato  ")
	TotaisGW2[1] := TotalRecords(GeraQueryTot("GW2", "GW2_DTCRIA", "GW2_SITCON = '1'"))
	TotaisGW2[2] := TotalRecords(GeraQueryTot("GW2", "GW2_DTCRIA", "GW2_SITCON = '2'"))
	TotaisGW2[3] := TotalRecords(GeraQueryTot("GW2", "GW2_DTCRIA"))
Return

//------------------------------------------------------------------------------------------------
/* CamposParametros
Retorna um array com a estrutura de campos para o cabeçalho dos parâmetros

As chaves de indicação dos itens devem seguir este padrão:
 [*] Nível superior
 	 3 Caracteres + '_'. Exemplo: DOC_
 [*] Sub-itens
 	3 Caracteres igual ao nível superior + número identificação. Exemplo DOC1
 	
Estas instruções são necessárias pelas seguintes limitações:
- A função de evento de clique é uma só e retorna de forma geral a chave de identifcação do item selecionado,
assim, a função que trata o evento de seleção do item (clique) pode tratar qual item foi selecionado.
- A chave de identificação do sub-item é limitada a quantidade de caracteres do nível superior em que o item pertence
	
@author Israel A. Possoli
@since 14/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function CriaTreeView(oOwner)
	Local cTabela
	Local cImgFiltro := "NEXT_PQ"
	
	oProcess:setRegua2(3)
	
	oFont := TFont():New('Arial',,-12,.T.)
	
	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()  					// Método de criação do objeto da classe.
	oFWLayer:Init(oOwner,.F.)  					   // Através desse método você define a inicialização do objeto como quem será o objeto pai

	oFWLayer:AddLine( 'LINE_TOP', 100, .F. ) 					// Cria uma "linha" com 10% da tela
	oFWLayer:AddCollumn( 'COL_TOP'  , 100, .T., 'LINE_TOP' ) 	// Na "linha" criada eu crio uma coluna com 50% da tamanho dela
	oFWLayer:addWindow('COL_TOP','WIN_TOP','Sumário',100,.T.,.F.,,'LINE_TOP',)
    oWIN_TOP := oFWLayer:getWinPanel('COL_TOP','WIN_TOP', 'LINE_TOP')
	
	oTree := DbTree():New(0,0,0,0,oWIN_TOP,{|| ChangeItem()},,.T.,,oFont)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
 
 	oProcess:incRegua2("Criando Tree - Controle de Cargas  ")
    //Controle de Cargas
	oTree:AddItem("Controle de Cargas             ", "CON" + Space(1), "FOLDER5" ,,,,1)    
	If oTree:TreeSeek("CON" + Space(1))    
	    // Documento de Carga
	    cTabela := "GW1"
	    oTree:AddItem("Documento de Carga", cTabela + Space(1), "BUDGET" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Embarcar (" + ALLTRIM(STR(TotaisGW1[1]))+")" ,	cTabela + "1", cImgFiltro,,,,3)
	      oTree:AddItem("para Enviar EDI (" + ALLTRIM(STR(TotaisGW1[2]))+")" ,  cTabela + "2", cImgFiltro,,,,3)
	      oTree:AddItem("sem Entrega (" + ALLTRIM(STR(TotaisGW1[3]))+")" ,	cTabela + "3", cImgFiltro,,,,3)
	      oTree:AddItem("sem Doc Frete (" + ALLTRIM(STR(TotaisGW1[4]))+")" ,	cTabela + "4", cImgFiltro,,,,3)
	      If GFEVerCmpo( {"GV5_CALC"}) //Somente se os campos existirem, indica compatibilizador rodado
	      	oTree:AddItem("sem Roman Carga (" + ALLTRIM(STR(TotaisGW1[5]))+")" ,	cTabela + "5", cImgFiltro,,,,3)
	      EndIf
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("CON" + Space(1))
	    
	    // Agendamentos
	    cTabela := "GWV"
	    oTree:AddItem("Agendamentos", cTabela + Space(1), "S4SB014N" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1)) 
	      oTree:AddItem("Abertos (" + ALLTRIM(STR(TotaisGWV[1]))+")", cTabela + "1", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("CON" + Space(1))  
	    
	    // Romaneios
	    cTabela := "GWN"
	    oTree:AddItem("Romaneios", cTabela + Space(1), "CONTAINR" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Liberar (" + ALLTRIM(STR(TotaisGWN[1]))+")", 	cTabela + "1", cImgFiltro,,,,3)
	      oTree:AddItem("para Calcular (" + ALLTRIM(STR(TotaisGWN[2]))+")",	cTabela + "2", cImgFiltro,,,,3)
	      If SuperGetMv("MV_NFEENV",.F.,"1") <> "1"
	      	oTree:AddItem("para enviar XML NFe (" + ALLTRIM(STR(TotaisGWN[4]))+")",	cTabela + "4", cImgFiltro,,,,3)
	      EndIf
	      oTree:AddItem("em Trânsito (" + ALLTRIM(STR(TotaisGWN[3]))+")", 		cTabela + "3", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("CON" + Space(1))  
	    
	    // Ocorrências
	    cTabela := "GWD"
	    oTree:AddItem("Ocorrências", cTabela + Space(1), "TPOPAGTO1" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Aprovar (" + ALLTRIM(STR(TotaisGWD[1]))+")", cTabela + "1", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("CON" + Space(1))  
	
	EndIf  
	oProcess:incRegua2("Criando Tree - Negociação Frete  ")	
	//Negociação de Frete
	oTree:AddItem("Negociação Frete", "NEG" + Space(1), "FOLDER5" ,,,,1)    
	If oTree:TreeSeek("NEG" + Space(1))    
		
	    // Tabelas de Frete
	    cTabela := "GV9"
	    oTree:AddItem("Tabelas de Frete", cTabela + Space(1), "TAB1" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("em Negociação (" + ALLTRIM(STR(TotaisGV9[1]))+")", cTabela + "1", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("NEG" + Space(1)) 
	    
	    // Cálculos de Frete
	    cTabela := "GWF"
	    oTree:AddItem("Cálculos de Frete", cTabela + Space(1), "CARGASEQ" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("sem Pré-fatura (" + ALLTRIM(STR(TotaisGWF[1]))+")", cTabela + "1", cImgFiltro,,,,3)
	      oTree:AddItem("sem Contrato (" + ALLTRIM(STR(TotaisGWF[2]))+")",   cTabela + "2", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("NEG" + Space(1)) 
	    
	    // Ajuste de Frete
	    cTabela := "GWO"
	    oTree:AddItem("Ajustes de Frete", cTabela + Space(1), "NOTE" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Aprovar (" + ALLTRIM(STR(TotaisGWO[1]))+")", cTabela + "1", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("NEG" + Space(1)) 
	    
	    // Pré-faturas
	    cTabela := "GWJ"
	    oTree:AddItem("Pré-faturas", cTabela + Space(1), "BAIXATIT" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Enviar (" + ALLTRIM(STR(TotaisGWJ[1]))+")", 	  cTabela + "1", cImgFiltro,,,,3)
	      oTree:AddItem("para Confirmar (" + ALLTRIM(STR(TotaisGWJ[2]))+")", cTabela + "2", cImgFiltro,,,,3)
	      oTree:AddItem("sem Fatura (" + ALLTRIM(STR(TotaisGWJ[3]))+")", 	  cTabela + "3", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
    	oTree:TreeSeek("NEG" + Space(1))
    EndIf     
	oProcess:incRegua2("Criando Tree - Controle de Fretes  ")	    
  	//Controle de Frete
	oTree:AddItem("Controle de Fretes", "COF" + Space(1), "FOLDER5" ,,,,1)    
	If oTree:TreeSeek("COF" + Space(1))    
  
	    // Documento de Frete
	    cTabela := "GW3"
	    oTree:AddItem("Documentos de Frete", cTabela + Space(1), "PRECO" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Aprovar (" + ALLTRIM(STR(TotaisGW3[1]))+")",  cTabela + "1", cImgFiltro,,,,3)
	      oTree:AddItem("sem Fatura (" + ALLTRIM(STR(TotaisGW3[2]))+")",    cTabela + "2", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("COF" + Space(1))   
	    
	    // Faturas de Frete
	    cTabela := "GW6"
	    oTree:AddItem("Faturas de Frete", cTabela + Space(1), "SIMULACAO" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Conferir (" + ALLTRIM(STR(TotaisGW6[1]))+")", cTabela + "1", cImgFiltro,,,,3)
	      oTree:AddItem("para Aprovar (" + ALLTRIM(STR(TotaisGW6[2]))+")", cTabela + "2", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
	    oTree:TreeSeek("COF" + Space(1))   
	    
	    // Contratos
	    cTabela := "GW2"
	    oTree:AddItem("Contratos", cTabela + Space(1), "PARAMETROS" ,,,,2)
	    If oTree:TreeSeek(cTabela + Space(1))
	      oTree:AddItem("para Confirmar (" + ALLTRIM(STR(TotaisGW2[1]))+")", cTabela + "1", cImgFiltro,,,,3)
	      oTree:AddItem("para Emitir (" + ALLTRIM(STR(TotaisGW2[2]))+")",  cTabela + "2", cImgFiltro,,,,3)
	    EndIf
	    //oTree:TreeSeek(cTabela + Space(1))
		oTree:TreeSeek("COF" + Space(1))   

	EndIf 

	oTree:TreeSeek("CON" + Space(1))
    oTree:EndTree()
    
    /* Seleciona o primeiro item da lista */
    oTree:TreeSeek("GW11")
    ChangeItem()
Return

//------------------------------------------------------------------------------------------------
/* CriaPaineis
Criação dos Painéis para os browsers e o painel da barra de ferramentas

	
@author Israel A. Possoli
@since 14/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function CriaPaineis(oOwner)
  	oProcess:setRegua2(13)          
  	
  	oProcess:incRegua2("Criando Gráficos")
   	// Barra dos gráficos
   	oPanelGra := tPanel():New(0,0,,oOwner,,,,,,0,50)
   	oPanelGra:Align := CONTROL_ALIGN_BOTTOM
   	
	oChartBar := GFEGRABARC():New(oPanelGra, 400)
	oChartBar:SetTotal(Space(150), 0)
	oChartBar:AddSerie(Space(150), 0)
	oChartBar:Build()
	oChartBar:Hide()

	oProcess:incRegua2("Criando Painéis")
	// Criação dos painéis dos browser
	oPanelGW1 := tPanel():New(0,0,,oOwner,,,,,,0,0)
	oPanelGW1:Align := CONTROL_ALIGN_ALLCLIENT   
	
	oProcess:incRegua2()
	oPanelGWV := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGWV:Align := CONTROL_ALIGN_ALLCLIENT
	
	oProcess:incRegua2()
	oPanelGWN := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGWN:Align := CONTROL_ALIGN_ALLCLIENT 
	
	oProcess:incRegua2()
	oPanelGWD := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGWD:Align := CONTROL_ALIGN_ALLCLIENT
	
	oProcess:incRegua2()
	oPanelGV9 := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGV9:Align := CONTROL_ALIGN_ALLCLIENT 
	
	oProcess:incRegua2()
	oPanelGWF := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGWF:Align := CONTROL_ALIGN_ALLCLIENT 
	
	oProcess:incRegua2()
	oPanelGWO := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGWO:Align := CONTROL_ALIGN_ALLCLIENT
	
	oProcess:incRegua2()
	oPanelGWJ := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGWJ:Align := CONTROL_ALIGN_ALLCLIENT
	
	oProcess:incRegua2()
	oPanelGW3 := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGW3:Align := CONTROL_ALIGN_ALLCLIENT  
	
	oProcess:incRegua2()
	oPanelGW6 := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGW6:Align := CONTROL_ALIGN_ALLCLIENT 
	
	oProcess:incRegua2()
	oPanelGW2 := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPanelGW2:Align := CONTROL_ALIGN_ALLCLIENT 
	
	oProcess:incRegua2()
	oPanelAtual := oPanelGW1
	oPanelGW1:Hide()
	
	oPanelGWV:Hide()
	oPanelGWN:Hide()
	oPanelGWD:Hide()
	oPanelGV9:Hide()
	oPanelGWF:Hide()
	oPanelGWO:Hide()
	oPanelGWJ:Hide()
	oPanelGW3:Hide()
	oPanelGW6:Hide()
	oPanelGW2:Hide()
Return

//------------------------------------------------------------------------------------------------
/* CriaBrowsers
Criação dos Browsers dentro dos painéis

@author Israel A. Possoli
@since 14/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function CriaBrowsers(oOwner)   
     
  	//oProcess:setRegua2(13)   
  	oProcess:setRegua2(12)
  	
  	oProcess:incRegua2("Criando Browsers - Documento de Carga")
	oBrwGW1 := FWMBrowse():New()
	oBrwGW1:SetDescription("Documento de Carga")
	oBrwGW1:SetAlias('GW1')
	oBrwGW1:SetOwner(oPanelGW1)
	//oBrwGW1:SetOnlyFields({'GW1_FILIAL', 'GW1_CDTPDC', 'GW1_EMISDC', 'GW1_DTEMIS', 'GW1_SERDC', 'GW1_NRDC', 'GW1_CDREM', 'GW1_CDDEST'})
	oBrwGW1:SetProfileID('GW1')  
	oBrwGW1:DisableDetails()
	oBrwGW1:ForceQuitButton(.T.)
	oBrwGW1:AddButton("Visualizar"   , "VIEWDEF.GFEC040",, 2, 0)
	oBrwGW1:AddLegend("GW1_SIT=='1'", "WHITE" , "Digitado ") //"Digitado "
	oBrwGW1:AddLegend("GW1_SIT=='2'", "YELLOW", "Bloqueado") //"Bloqueado"
	oBrwGW1:AddLegend("GW1_SIT=='3'", "GRAY"  , "Liberado ") //"Liberado "
	oBrwGW1:AddLegend("GW1_SIT=='4'", "BLUE"  , "Embarcado") //"Embarcado"
	oBrwGW1:AddLegend("GW1_SIT=='5'", "GREEN" , "Entregue ") //"Entregue "
	oBrwGW1:AddLegend("GW1_SIT=='6'", "ORANGE", "Retornado") //"Retornado"
	oBrwGW1:AddLegend("GW1_SIT=='7'", "RED"   , "Cancelado") //"Cancelado"
	
  	oProcess:incRegua2("Criando Browsers - Agendamento")		
	oBrwGWV  := FWMBrowse():New()
	oBrwGWV:SetDescription("Agendamento")
	oBrwGWV:SetAlias('GWV')
	oBrwGWV:SetOwner(oPanelGWV)
	//oBrwGWV:SetOnlyFields({'GWV_FILIAL', 'GWV_NRAGEN', 'GWV_DTCRIA', 'GWV_DTAGEN', 'GWV_CDOPER'})
	oBrwGWV:SetProfileID('GWV')
	oBrwGWV:AddButton("Visualizar", "VIEWDEF.GFEA517",, 2, 0)
	oBrwGWV:SetFilterDefault(FiltroGWV[1])  
	oBrwGWV:DisableDetails()
	oBrwGWV:ForceQuitButton(.T.)
	
  	oProcess:incRegua2("Criando Browsers - Romaneios")	
	oBrwGWN  := FWMBrowse():New()
	oBrwGWN:SetDescription("Romaneio")
	oBrwGWN:SetAlias('GWN')
	oBrwGWN:SetOwner(oPanelGWN)
	//oBrwGWN:SetOnlyFields({'GWN_FILIAL', 'GWN_NRROM', 'GWN_DTIMPL', 'GWN_DTSAI', 'GWN_CDTPOP'})
	oBrwGWN:SetProfileID('GWN')   
	oBrwGWN:DisableDetails()
	oBrwGWN:ForceQuitButton(.T.)
	oBrwGWN:AddButton("Visualizar"   , "VIEWDEF.GFEC050",, 2, 0)
	oBrwGWN:AddLegend("GWN_SIT=='1'", "WHITE" , "Digitado") //"Digitado"
	oBrwGWN:AddLegend("GWN_SIT=='2'", "YELLOW", "Impresso") //"Impresso"
	oBrwGWN:AddLegend("GWN_SIT=='3'", "GREEN" , "Liberado") //"Liberado"
	oBrwGWN:AddLegend("GWN_SIT=='4'", "RED"   , "Encerrado") //"Encerrado"
	
  	oProcess:incRegua2("Criando Browsers - Ocorrências")	
	oBrwGWD  := FWMBrowse():New()
	oBrwGWD:SetDescription("Ocorrências")
	oBrwGWD:SetAlias('GWD')
	oBrwGWD:SetOwner(oPanelGWD)
	//oBrwGWD:SetOnlyFields({'GWD_FILIAL', 'GWD_DTOCOR', 'GWD_NROCO', 'GWD_DSOCOR', 'GWD_CDTIPO', 'GWD_DSTIPO', 'GWD_CDMOT', 'GWD_DSMOT'})
	oBrwGWD:SetProfileID('GWD')
	oBrwGWD:SetFilterDefault(FiltroGWD[1])
	oBrwGWD:DisableDetails()
	oBrwGWD:ForceQuitButton(.T.)
	oBrwGWD:AddButton("Visualizar"   , "VIEWDEF.GFEC032",, 2, 0)	
	oBrwGWD:AddLegend("GWD_SIT=='1'", "BLUE" , "Pendente") //"Pendente"
	oBrwGWD:AddLegend("GWD_SIT=='2'", "GREEN", "Aprovada") //"Aprovada"
	oBrwGWD:AddLegend("GWD_SIT=='3'", "RED"  , "Reprovada") //"Reprovada"
	
  	oProcess:incRegua2("Criando Browsers - Tabelas de Frete")
	oBrwGV9  := FWMBrowse():New()
	oBrwGV9:SetDescription("Tabelas de Frete")
	oBrwGV9:SetAlias('GV9')
	oBrwGV9:SetOwner(oPanelGV9)
	//oBrwGV9:SetOnlyFields({'GV9_FILIAL', 'GV9_CDEMIT', 'GV9_NMEMIT', 'GV9_NRTAB', 'GV9_DTCRIA', 'GV9_SIT'})
	oBrwGV9:SetProfileID('GV9')
	oBrwGV9:SetFilterDefault(FiltroGV9[1])
	oBrwGV9:DisableDetails()
	oBrwGV9:ForceQuitButton(.T.)
	oBrwGV9:AddButton("Visualizar", "GFEC010NEG()",, 2, 0)	
	
  	oProcess:incRegua2("Criando Browsers - Cálculo de Frete")		
	oBrwGWF  := FWMBrowse():New()
	oBrwGWF:SetDescription("Cálculo de Frete")
	oBrwGWF:SetAlias('GWF')
	oBrwGWF:SetOwner(oPanelGWF)
	//oBrwGWF:SetOnlyFields({'GWF_FILIAL', 'GWF_DTCRIA', 'GWF_NRCALC', 'GWF_EMIREM', 'GWF_NMREM', 'GWF_EMIDES', 'GWF_NMDEST', 'GWF_TRANSP'})
	oBrwGWF:SetProfileID('GWF')    
	oBrwGWF:DisableDetails()
	oBrwGWF:ForceQuitButton(.T.) 
	oBrwGWF:AddButton("Visualizar"   , "VIEWDEF.GFEC080",, 2, 0)
	
  	oProcess:incRegua2("Criando Browsers - Ajuste de Frete")	
	oBrwGWO  := FWMBrowse():New()
	oBrwGWO:SetDescription("Ajuste de Frete")
	oBrwGWO:SetAlias('GWO')
	oBrwGWO:SetOwner(oPanelGWO)
	//oBrwGWO:SetOnlyFields({'GWO_FILIAL', 'GWO_NRROM', 'GWO_DTAJUS', 'GWO_USRAJU', 'GWO_VLFRET', 'GWO_VLAJUS', 'GWO_SITAJU'})
	oBrwGWO:SetProfileID('GWO')
	oBrwGWO:SetFilterDefault(FiltroGWO[1])       
	oBrwGWO:DisableDetails()
	oBrwGWO:ForceQuitButton(.T.)
	
  	oProcess:incRegua2("Criando Browsers - Pré-Faturas")		
	oBrwGWJ  := FWMBrowse():New()
	oBrwGWJ:SetDescription("Pré-Faturas")
	oBrwGWJ:SetAlias('GWJ')
	oBrwGWJ:SetOwner(oPanelGWJ)
	//oBrwGWJ:SetOnlyFields({'GWJ_FILIAL', 'GWJ_NRPF', 'GWJ_CDTRP', 'GWJ_NMTRP', 'GWJ_SIT', 'GWJ_DTVCTO', 'GWJ_DTIMPL', 'GWJ_SITFIN'})
	oBrwGWJ:SetProfileID('GWJ')  
	oBrwGWJ:DisableDetails()
	oBrwGWJ:ForceQuitButton(.T.) 
	oBrwGWJ:AddButton("Visualizar"   , "GFEC010PREF()",, 2, 0)
	oBrwGWJ:AddLegend( "GWJ_SIT=='1'", "GRAY" , "Pendente" ) // Legenda //"Pendente"
	oBrwGWJ:AddLegend( "GWJ_SIT=='2'", "BLUE" , "Enviada" ) // Legenda //"Enviada"
	oBrwGWJ:AddLegend( "GWJ_SIT=='3'", "GREEN", "Confirmada" ) // Legenda //"Confirmada"
	oBrwGWJ:AddLegend( "GWJ_SIT=='4'", "RED"  , "Cancelada" ) // Legenda //"Cancelada"

  	oProcess:incRegua2("Criando Browsers - Documento de Frete")		
	oBrwGW3  := FWMBrowse():New()
	oBrwGW3:SetDescription("Documento de Frete")
	oBrwGW3:SetAlias('GW3')
	oBrwGW3:SetOwner(oPanelGW3)
	//oBrwGW3:SetOnlyFields({'GW3_FILIAL', 'GW3_CDESP', 'GW3_EMISDF', 'GW3_NMEMIS', 'GW3_SERDF', 'GW3_NRDF', 'GW3_DTEMIS', 'GW3_SIT'})
	oBrwGW3:SetProfileID('GW3') 
	oBrwGW3:DisableDetails()
	oBrwGW3:ForceQuitButton(.T.)   
	oBrwGW3:AddButton("Visualizar"   , "VIEWDEF.GFEC065",, 2, 0)
	oBrwGW3:AddLegend("GW3_SIT=='1'", "WHITE", "Recebido") //"Recebido"
	oBrwGW3:AddLegend("GW3_SIT=='2'", "RED",   "Bloqueado") //"Bloqueado"
	oBrwGW3:AddLegend("GW3_SIT=='3'", "BLUE",  "Aprovado pelo Sistema") //"Aprovado pelo Sistema"
	oBrwGW3:AddLegend("GW3_SIT=='4'", "GREEN", "Aprovado pelo Usuário")	//"Aprovado pelo Usuário"
	oBrwGW3:AddLegend("GW3_SIT=='5'", "YELLOW", "Bloqueado por Entrega")	//"Bloqueado por Entrega"
	
  	oProcess:incRegua2("Criando Browsers - Fatura")	
	oBrwGW6  := FWMBrowse():New()
	oBrwGW6:SetDescription("Fatura")
	oBrwGW6:SetAlias('GW6')
	oBrwGW6:SetOwner(oPanelGW6)
	//oBrwGW6:SetOnlyFields({'GW6_FILIAL', 'GW6_EMIDAT', 'GW6_NMEMIT', 'GW6_SERFAT', 'GW6_NRFAT', 'GW6_DTEMIS'})
	oBrwGW6:SetProfileID('GW6')
	oBrwGW6:SetFilterDefault(FiltroGW6[1])
	oBrwGW6:DisableDetails()
	oBrwGW6:ForceQuitButton(.T.)
	oBrwGW6:AddButton("Visualizar"   , "VIEWDEF.GFEC070",, 2, 0)	
	oBrwGW6:AddLegend("GW6_SITAPR == '1'", "BLACK" , "Recebida") //Legenda do Browser //"Recebida"
	oBrwGW6:AddLegend("GW6_SITAPR == '2'", "RED"   , "Bloqueado") //"Bloqueado"
	oBrwGW6:AddLegend("GW6_SITAPR == '3'", "GREEN" , "Aprovada Sistema") //"Aprovada Sistema"
	oBrwGW6:AddLegend("GW6_SITAPR == '4'", "BLUE"  , "Aprovada Usuario" ) //"Aprovada Usuario" 
	
  	oProcess:incRegua2("Criando Browsers - Contrato")		
	oBrwGW2  := FWMBrowse():New()
	oBrwGW2:SetDescription("Contrato")
	oBrwGW2:SetAlias('GW2')
	oBrwGW2:SetOwner(oPanelGW2)
	//oBrwGW2:SetOnlyFields({'GW2_FILIAL', 'GW2_NRCONT', 'GW2_SITCON', 'GW2_DTCRIA', 'GW2_DTVENC', 'GW2_CDPROP'})
	oBrwGW2:SetProfileID('GW2')   
	oBrwGW2:DisableDetails()
	oBrwGW2:ForceQuitButton(.T.) 
	oBrwGW2:AddButton("Visualizar"   , "VIEWDEF.GFEC100",, 2, 0)
	oBrwGW2:AddLegend("GW2_SITCON=='1'", "WHITE", "Criado")     //"Criado"
	oBrwGW2:AddLegend("GW2_SITCON=='2'", "GREEN", "Confirmado") //"Confirmado"
	oBrwGW2:AddLegend("GW2_SITCON=='3'", "BLUE" , "Impresso")   //"Impresso"
	oBrwGW2:AddLegend("GW2_SITCON=='4'", "RED"  , "Cancelado")  //"Cancelado"	

  	oProcess:incRegua2("Criando Browsers - Ativando GW1")	
	oBrwGW1:Activate()
	oProcess:incRegua2("Criando Browsers - Ativando GWV")
	oBrwGWV:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GWN")
	oBrwGWN:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GWD")
	oBrwGWD:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GV9")
	oBrwGV9:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GWF")
	oBrwGWF:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GWO")
	oBrwGWO:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GWJ")
	oBrwGWJ:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GW3")
	oBrwGW3:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GW6")
	oBrwGW6:Activate()                               
	oProcess:incRegua2("Criando Browsers - Ativando GW2")
	oBrwGW2:Activate()
Return

//
// Chama ViewDEF das negociações
//
Function GFEC010NEG()
	//
	// Variáveis utilizadas no programa GFEA061A.
	// Devem ser definidas para que a view funcione
	//
	Private cTB_CDEMIT
	Private cTB_NRTAB
	cTB_CDEMIT = GVA->GVA_CDEMIT
	cTB_NRTAB  = GVA->GVA_NRTAB
	
	FWExecView("Visualizar", "GFEA061A", 1,, {||.T.})	
Return Nil

//------------------------------------------------------------------------------------------------
/* ChangeItem
Evento de mudança de item no TreeView
 - Alterna os painéis com os browsers segunda o item selecionado
 - Muda o filtro do browse de acordo com o sub-item
 - Altera o filtro do browse, caso o Browse possuir mais de um filtro
 - No caso de browse que só possui um filtro, presume que ele já foi setado na criação do mesmo para aumentar a performance
 - Altera o título do Browse

	
@author Israel A. Possoli / Alan Victor Lamb
@since 14/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function ChangeItem()
	Local cTabela 	    := AllTrim(Substr(oTree:GetCargo(), 1, 3))
	Local cSubItem 	:= AllTrim(Substr(oTree:GetCargo(), 4, 1))
	Local cTabelaDesc
	Local cFiltroDesc
	
	If Empty(cSubItem) // Verifica se o nó selecionado é um nó raiz, se sim volta para o ultimo nó selecionado  
		//oTree:TreeSeek(cNodeTree)
		Return 
	EndIf
	
	CursorWait()     
	
	// Armazena o nó atual
	cNodeTree := oTree:GetCargo()   
	nCount    := 0
	
	// Localiza a descrição da tabela
	oTree:TreeSeek(cTabela + Space(1))
	cTabelaDesc := AllTrim(oTree:GetPrompt())
	oTree:TreeSeek(cTabela + cSubItem)
	
	cFiltroDesc := cTabelaDesc + " " + AllTrim(oTree:GetPrompt())
	
	// Mostra/Esconde os painéis de acordo com o item selecionado
	oPanelAtual:Hide()
	oPanelAtual := &("oPanel" + cTabela)
	oPanelAtual:Show()
	
	// Seta filtro do Browse
	If Empty(cSubItem)
		cSubItem := "1"
	EndIf
	
	If Len(&("Filtro" + cTabela)) > 1
		&("oBrw" + cTabela + ":SetFilterDefault(Filtro" + cTabela + "[" + cSubItem + "])")
		&("oBrw" + cTabela + ":Refresh()")
	EndIf
	
	// Atualiza gráfico
	oChartBar:UpdateTotal(cTabelaDesc + " (" + ALLTRIM(STR(&("Totais" + cTabela + "[Len(Totais" + cTabela + ")]"))) + ")", &("Totais" + cTabela + "[Len(Totais" + cTabela + ")]"))
	oChartBar:UpdateSerie(2, cFiltroDesc, &("Totais" + cTabela + "[" + cSubItem + "]"))
	oChartBar:Refresh()
	If !oChartBar:IsVisible()
		oChartBar:Show()
	EndIf
	
	CursorArrow()
Return


Static Function TotalRecords(cQuery)
	Local cTmp := ""
	Local nTotal := 0
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp) 
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		nTotal := (cTmp)->TOTAL
	EndIf
	  
	(cTmp)->(dbCloseArea())
Return nTotal

Static Function GeraQueryTot(cTabela, cCampoData, cWhere)
	Local cQuery
	Local cFilialData
	Local cWhereTmp := ""
	Default cWhere := ""
	
	cFilialData := FiltroFilialData(cTabela, cCampoData, .T., .F.)
	
	If !Empty(cWhere) .OR. !Empty(cFilialData)
		cWhereTmp := " AND " + cWhere
		
		If !Empty(cWhere) .AND. !Empty(cFilialData)
			cWhereTmp := cWhereTmp + " AND " + cFilialData
		Else
			cWhereTmp := cWhereTmp + cFilialData
		EndIf
	EndIf
	
	cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName(cTabela) + " " + cTabela +  " WHERE D_E_L_E_T_ = ' ' " + cWhereTmp 
	
Return cQuery
// Função responsável por executar a retirada dos filtros da tabela GW1 - Documento de Cargas
// e após realizar a execução da visualização da pré-fatura, foi realizado dessa forma para
// que seja possível visualizar os documentos de carga relacionados a pré-fatura
Function GFEC010PREF()
	// Executado para realizar a limpeza dos filtros do browser da GW1
	oBrwGW1:SetFilterDefault("")
	// Realiza a execução do View do programa GFEC055 - Consulta pré-faturas
	FWExecView("Pré-Faturas","GFEC055",,,{|| .T.}) // Visualiza
Return
