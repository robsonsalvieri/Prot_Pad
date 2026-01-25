#include "Protheus.ch"
#include "VEIXX000.CH"
#include "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
 
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VEIXX000   | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Entrada de Veiculos                                          |##
##|          | Executa a entrada de veiculos por todas as modalidades.      |##
##|          | Possui interface de integracao.                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/

////////////////////////////////////////
//       Operacoes (VVF_OPEMOV)       //
//                                    //
//  0=Normal                          //
//  1=Ped.Fabrica                     //
//  2=Remessa                         //
//  3=Transferencia                   //
//  4=Consignacao                     //
//  5=Devolucao                       //
//  6=Frete                           //
//  7=Retorno de Remessa              //
//  8=Retorno de Consignacao          //
//                                    //
////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// xTIPDOC -> "1" = Gera nota fiscal de Entrada - SD1/SF1                                                               //
//            "2" = Gera movimentacao interna - SD3                                                                     //
//            "3" = Nao gera movimentacao de entrada Back Office (Nota Fiscal de Entrada / Mov. Interna de Estoque)     //
//                  Opcao utilizada na integração com CAOA, neste caso o veiculo pode ser importado e a nota fiscal     //
//                  já foi digitada no BackOffice                                                                       //
//            "4" = Nao gera movimentacao de entrada Back Office (Nota Fiscal de Entrada / Mov. Interna de Estoque)     //
//                  Opcao utilizada na integração com CAOA, neste caso o veiculo foi produzido pela montadora através   //
//                  de uma Ordem de Produção no PCP                                                                     //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov,xAutoAux,xMostraMsg,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
Local aBotAux := {}
//
Local nTamGru := TamSx3("B1_GRUPO")[1]	// Tamanho da variavel de grupo
//
Private bRefresh := { || .t. }				// Variavel necessaria ao MAFISREF
Private aCampos  := {}							// Variavel de integracao com o VEIVA010
Private cChassi  := {}							// Variavel de integracao com o VEIVA010
Private aIteParc := { { ctod("") , 0 , {} } }	// Vetor contendo os titulos a pagar
Private aParcCust := {}							// Vetor com os Campos Customizados no Como Pagar
//
Private cGruVei  := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))
Private cUsaGrVA := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
//
Private lAbortPrint	:= .f.	// Variavel de Aborto de Operacao
Private cX0OpeMov := xOpeMov		// Tipo de Operacao de entrada
Private cSerie, cNumero					// Serie e numero da NF quando formulario proprio
Private lMudouNum := .f. 				// Indica se houve mudanca da sequencia de nota fiscal
Private lLivreDebito := .f.				// Indica se sera gerado titulo (avaliacao de veiculos)
// Variaveis de integracao
Private lMostraMsg := IIF(xMostraMsg==NIL,.t.,xMostraMsg)
Private aAutoCab := {} 					// Cabecalho da NF (VVF)
Private aAutoItens := {}				// Itens da NF (VVG)
Private aAutoIteParc := {}				// Como pagar (SE2)
Private aAutoAux := {}					// Auxiliar (para retornos de remessa/consignado)
// 'lVX000Auto' indica se todos os vetores de integracao foram preenchidos
Private lVX000Auto := ( xAutoCab<>NIL .and. xAutoItens<> NIL .and. xAutoCP<>NIL .and. nOpc<>NIL .and. xOpeMov<>NIL )
// VARIAVEIS DE CONTROLE DA TELA (OBJETOS)
Private aTitulo := {STR0001,STR0002}	// Dados da Nota Fiscal","Como Pagar # Titulo dos folders
Private oFnt1 := TFont():New( "System", , 12 )
Private oSayE34
Private oSayE21
Private oGetE21
Private oGetE101 // Necessario para refresh na tela - Total Frete
Private oGetE72  // Necessario para refresh na tela - Peso Liquido
Private oGetE73  // Necessario para refresh na tela - Peso Bruto
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
//
Private aCposUser := {} // Campos customizáveis do cabeçalho (VVF)
//
// Variaveis do Folder 2 - Como Pagar
Private dDataIni := ctod(" ")
Private nDias1P
Private nParcel
Private nInterv
Private lImpXml := ( FM_PILHA("U_IMPXMLV") .or. FM_PILHA("U_IXMLVJD") )
Private n := 1
Private cCliForA := ""//GetNewPar("MV_CLFRRC","")
Private aOrc     := {}
Private aOrcDynHeader := {}
Private aOrcDynFooter := {}
Private nRecVVF  := 0
// Variáveis do Folder 3 - Moeda
Private nMoedaCor
Private nTaxaMoeda
If cPaisLoc <> "BRA"
	Private aMoedaOld := {}
EndIf
//
Private aNewBot  := {}
//
Private lAtuFiscal := .t. // Atualiza Fiscal
Private lMoeda     := VVF->(FieldPos("VVF_MOEDA")) > 0 .Or. VVF->(FieldPos("VVF_TXMOED")) > 0
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV     := ""
Default xAutoCab    := {}
Default xAutoItens  := {}
Default xAutoCP     := {}
Default cRotOrigem  := ProcName(1)
Default cTpFatR     := "1" // 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura / 5=Não grava, é utilizado somente para gerar Remito Entrega Futura / 6=Não grava, é utilizado somente para DEVOLVER uma Venda sem Entrega (não possui REMITO de SAIDA)

//
Private PARxTIPDOC := xTIPDOC
//
If cPaisLoc $ "ARG|MEX"
	If cTpFatR == "3" // 3=Fatura pelo Remito
		nOpc := 4 // Quando Fatura com Remito não deve criar outro VVF. Forçar 4 = ALTERAR
	EndIf
	If Type("xTpFatR") == "U" // Variável Private utilizada somente na Argentina
		Private xTpFatR := "" // 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura / 5=Não grava, é utilizado somente para gerar Remito Entrega Futura / 6=Não grava, é utilizado somente para DEVOLVER uma Venda sem Entrega (não possui REMITO de SAIDA)
	EndIf
	xTpFatR := cTpFatR // 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura / 5=Não grava, é utilizado somente para gerar Remito Entrega Futura / 6=Não grava, é utilizado somente para DEVOLVER uma Venda sem Entrega (não possui REMITO de SAIDA)
	If xTpFatR == "5" // Remito Entrega Futura
		cTpFatR := "2" // 2=Remito
	ElseIf xTpFatR == "6" // DEVOLUCAO de Venda sem Entrega (não possui REMITO de SAIDA)
		cTpFatR := "2" // 2=Remito
	EndIf
EndIf
//
If lMoeda
	aAdd(aTitulo, STR0107) // Moeda # Título dos folders
EndIf

If xTIPDOC == "2" // SD3 ( Mov.Internas )
	lAtuFiscal := .f. // NAO atualizar Fiscal quando Mov.Internas
EndIf
If xTIPDOC == "3" // Integracao com SIGAEIC
EndIf
If xTIPDOC == "4" // Integracao com o SIGAPCP
	lAtuFiscal := .f.
EndIf
//
//if !(FindFunction("FMX_CNPJLB")) .or. !FMX_CNPJLB()
//	If !AMIIn(11) .or. (!FMX_AMIIn({"VEIVC140", "VEIXA001", "VEIXA002", "VEIXA003", "VEIXA004", "VEIXA005", "VEIXA006", "VEIXA007", "VEIXA008", "VEIXA012", "VEIXA016", "VEIXA017" ,"VEIXA021", "VEIXA026", "VEIXA027","OFIIA340","VEIXA340","VEIXA018","VEIXA030","VEIXA040","VEIVC210","IMPXMLV","VEIVC260"}))
//		Return()
//	EndIf
//endif
If cX0OpeMov != nil
	If cX0OpeMov == "0" // O botão somente deve aparecer em casos de Entrada por Compra
		// Inclusão de AMS no Outras Ações
		If nOpc == 3 // Somente na Opção Incluir
			aadd(aNewBot,{"BMPVISUAL", {|| VX000IAMS() } , STR0106+" "+GetNewPar("MV_MIL0106","AMS") })  // Incluir AMS
		Endif
	Endif
	If ( ExistBlock("VX000BOT") )
		aBotAux := ExecBlock("VX000BOT",.F.,.F.,{nOpc,cX0OpeMov,aNewBot})
		If ( ValType(aBotAux) == "A" )
			aNewBot := aClone(aBotAux)
		EndIf
	EndIf
EndIf
//
If ! lVX000Auto .AND. cCadastro == NIL
	cCadastro := STR0003 //Entrada de Veiculos
EndIf
// Se for detectado que trata-se de integracao faz os vetores receberem os parametros
If lVX000Auto
	aAutoCab	 := xAutoCab
	aAutoItens	 := xAutoItens
	aAutoIteParc := xAutoCP
	aIteParc	 := xAutoCP
	aAutoAux 	 := IIF(xAutoAux==NIL,{},xAutoAux)
EndIf
// Na integracao as variaveis abaixo nao existirao,
// por isso precisamos carrega-las manualmente
INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5
//#############################################################################
//# Chama a tela contendo os dados do veiculo                                 #
//#############################################################################
DBSelectArea("VVF")
lRet := VX000EXEC(alias(),Recno(),nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
If lRet .and. nRecVVF > 0
	VVF->(DbGoto(nRecVVF))
EndIf
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Programa  | VX000EXEC  |Autor  | Luis Delorme          | Data | 11/12/08 |##
##+----------+------------+-------+-----------------------+------+----------´##
##|Descri‡„o | Entrada de Veiculos                                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000EXEC(cAlias,nReg,nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
Local lRet      := .f.
//
Local nCntFor
Local nCntFor2
Local nPos
Local aObjects 	:= {}
Local aObjects1	:= {}
Local aObjects2	:= {}
Local aSizeAut	:= MsAdvSize(.t.)
Local ni        := 0
Local nLinha    := 0
Local nColuna   := 0
Local nLinCpo   := 0
Local nColCpo   := 0
Local aInfo := {}
Local nQtdVei   := 99 // Default - quantidade de linhas na aCols de Veiculos
Local cCposNAO  := "" // Campos que nao devem ser alterados
Local aAltVVG   // Deixar NIL como default para alterar os campos padrões

Private aCliFor  := X3CBOXAVET("VVF_CLIFOR","0")
Private cCombo   := {}
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV     := ""
Default cTpFatR     := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura
//
aParcCust := {}
If (FM_PILHA("VEIXA001")) // Somente Entrada de Veiculos por Compra
	If ExistBlock("VX000CCP")
		aParcCust := ExecBlock("VX000CCP",.f.,.f.) // Campos Customizados na Grid de Parcelas
		// aParcCust[x,1] Titulo da Coluna no ListBox
		// aParcCust[x,2] Campo do SE2 ( se informado será gravado na integracao com o FINA - Geração do Titulo )
		// aParcCust[x,3] Picture do Campo
		// aParcCust[x,4] Tamanho da Coluna no ListBox
		// aParcCust[x,5] Posicionamento - Alinhamento no ListBox: LEFT / RIGHT
		// aParcCust[x,6] Conteudo default
		VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
	EndIf
EndIf
//
/*
1 -> Linha inicial area trabalho
2 -> Coluna inicial area trabalho
3 -> Linha final area trabalho
4 -> Coluna final area trabalho
5 -> Coluna final dialog
6 -> Linha final dialog
7 -> Linha inicial dialog
*/
If ! lVX000Auto

	If nOpc == 3 .and. cPaisLoc $ "ARG|MEX" // Inclusao Manual na Argentina
		If cX0OpeMov == "0" // 0=Compra		
			If cPaisLoc == "MEX"
				nTpFatura := Aviso(STR0139,STR0140,{STR0141,STR0142,STR0143},2) // Entrada de Veículos/Máquinas / Deseja informar? / Fatura sem Remito / Remito / Cancela
				nTpFatura := IIF(nTpFatura==3,4,nTpFatura)								
			Else
				// 1= Fatura sem Remito / 2=Remito / 3=Entrega Futura / 4=Cancela
				nTpFatura := Aviso(STR0139,STR0140,{STR0141,STR0142,STR0147,STR0143},2) // Entrada de Veículos/Máquinas / Deseja informar? / Fatura sem Remito / Remito / Entrega Futura / Cancela
			EndIf						
			If nTpFatura == 0 .or. nTpFatura == 4 // Cancelou
				Return .f.
			EndIf
			nTpFatura := If(nTpFatura == 3, 4, nTpFatura) // Ajusta o retorno da opção Entrega Futura: no botão é 3 mas na variável é 4
			cTpFatR := strzero(nTpFatura,1) // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura
		ElseIf cX0OpeMov $ "234578" // 2=Remessa / 3=Transferencia / 4=Consignacao / 5=Devolucao / 7=Retorno de Remessa / 8=Retorno de Consignacao
			cTpFatR := "2" // Sempre 2=Remito quando o movimento for algum dos definidos acima
		EndIf
		xTpFatR := cTpFatR // 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura
	EndIf

	// Local bCampo	  := { |nCPO| Field(nCPO) }
	//
	// MONTA ESPACAMENTO DAS TELAS
	//
	nResAltura := GetScreenRes()[2]
	// TELA SUPERIOR (ENCHOICE) - TAMANHO VERTICAL FIXO
	AAdd( aObjects, { 0, iif(nResAltura <= 600 , 60 , iif( nResAltura <= 768 , 80 , 140 )) , .T., .F. } )
	// TELA CENTRAL (GETDADOS) - TAMANHO VERTICAL VARIAVEL
	AAdd( aObjects, { 0,	20, .T., .T. } )
	// TELA INFERIOR (FOLDER) - TAMANHO VERTICAL FIXO
	AAdd( aObjects, { 0,	iif( nResAltura <= 768 , 75, 100 ) , .T., .F. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	// ESPACAMENTO DA TELA DE FOLDER - QUATRO LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 0, .T., .T. } )
	aAbaInt := {0, 0, aPosObj[3,4]-aPosObj[3,2], aPosObj[3,3]-aPosObj[3,1]-14, 3, 3}
	aPosAba1 := MsObjSize( aAbaInt, aObjects1 )
	// ESPACAMENTO DA TELA DE CABECALHO -  DOZE LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 1
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 2
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 3
	If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
		AAdd( aObjects2, { 0, 08, .T., .f. } ) // 4
	Else
		AAdd( aObjects2, { 0, -3, .T., .f. } ) // 4 - desconsiderar linha
	EndIf
	if cPaisLoc == "BRA"
		AAdd( aObjects2, { 0, 08, .T., .f. } ) // 5
	Else
		AAdd( aObjects2, { 0, -3, .T., .f. } ) // 5 - desconsiderar linha
	EndIf
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 6
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 7
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 8
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 9
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 10
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 11
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 12
	AAdd( aObjects2, { 0, 08, .T., .f. } ) // 13
	If cPaisLoc $ "ARG|MEX"
		AAdd( aObjects2, { 0, 08, .T., .f. } ) // 14
	Else
		AAdd( aObjects2, { 0, -3, .T., .f. } ) // 14 - desconsiderar linha
	EndIf
	//
	AAdd( aObjects2, { 0, 0, .T., .T. } )
	aAbaCab := { aPosObj[1,2], aPosObj[1,2], aPosObj[1,4], aPosObj[1,3] , 3, 3 }
	aPosAbaCab := MsObjSize( aAbaCab, aObjects2 )
EndIf
//
// Zera variaveis de controle dos objetos
//
aIteParc := { { ctod("") , 0 , {} } }
VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)

dDataIni 	:= ctod(" ")
nDias1P 		:= 0
nParcel 		:= 0
nInterv 		:= 0
nMoedaCor       := 1
nTaxaMoeda      := 1
//##########################################
//# Cria variaveis M->????? da Enchoice    #
//##########################################
dbSelectArea("VVF")
dbSetOrder(1)
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVF")
//
// FILTRA OS CAMPOS DA ENCHOICE DEPENDENDO DO TIPO DE NOTA DE ENTRADA
//
cFiltrVVFS := "VVF_CONFRE#VVF_TESFRE#VVF_OPEMOV#VVF_NUMTRA#VVF_TRACPA#VVF_VALMOV#"
cFiltrVVFS += "VVF_TOTSEG#VVF_TOTFRE#VVF_VBAIPI#VVF_ALIIPI#VVF_VALIPI#VVF_VBAICM#"
cFiltrVVFS += "VVF_TOTICM#VVF_ICMRET#VVF_NUMPED#VVF_ALIICM#VVF_TIPMOV#VVF_TIPDOC#"
cFiltrVVFS += "VVF_MOEDA#VVF_TXMOED#"

if cPaisLoc == "ARG"
	cFiltrVVFS += "VVF_PROVEN#"
EndIf
If cPaisLoc $ 'ARG,MEX'
	cFiltrVVFS += "VVF_REMITO#VVF_SERREM#"
endif

Do Case
	Case cX0OpeMov $ "015" // COMPRA / PED.FABRICA / DEVOLUCAO
		cFiltrVVG := "VVG_PICOSB#"
	Case cX0OpeMov $ "23478" // REMESSA / TRANSFERENCIA / CONSIGNACAO / RETORNO DE REMESSA / RETORNO DE CONSIGNACAO
		cFiltrVVG := "VVG_VCNVEI#VVG_CODIND#VVG_CONFRE#VVG_PICOSB#"
EndCase

If !(cPaisLoc == "BRA")
	cFiltrVVG += "VVG_VBAIPI#VVG_ALIIPI#VVG_VALIPI#VVG_VBAICM#VVG_ALIICM#VVG_ICMCOM#"
	cFiltrVVG += "VVG_VBICRT#VVG_ICMRET#VVG_PISENT#VVG_COFENT#VVG_VALDES#VVG_BASCOF#"
	cFiltrVVG += "VVG_ALICOF#VVG_VALCOF#VVG_BASPIS#VVG_ALIPIS#VVG_VALPIS#VVG_BAIMP5"
	cFiltrVVG += "#VVG_ALIMP5#VVG_VLIMP5#VVG_BAIMP6#VVG_ALIMP6#VVG_VLIMP6#VVG_CF#"
endif
//
// CAMPOS DE VISUALIZACAO DO FOLDER 1
//
aOrc := {}
If lAtuFiscal // Atualiza Fiscal
	aAdd(aOrc, {'MaFisRet(,"NF_VALMERC")',  STR0031, 0, "SF1->F1_VALMERC"})   //Valor Mercadorias
	aAdd(aOrc, {'MaFisRet(,"NF_DESCONTO")', STR0032, 0, "SF1->F1_DESCONT"})   //Desconto
	aAdd(aOrc, {'MaFisRet(,"NF_SEGURO")',   STR0033, 0, "SF1->F1_SEGURO"})    //Seguro
	aAdd(aOrc, {'MaFisRet(,"NF_DESPESA")',  STR0034, 0, "SF1->F1_DESPESA"})   //Despesa
	aAdd(aOrc, {'MaFisRet(,"NF_FRETE")',    STR0035, 0, "SF1->F1_FRETE"})     //Frete
	If (cPaisLoc == "BRA")
		aAdd(aOrc, {'MaFisRet(,"NF_VALICM")', STR0036, 0, "SF1->F1_VALICM"})  //ICMS
		aAdd(aOrc, {'MaFisRet(,"NF_VALSOL")', STR0037, 0, "SF1->F1_ICMSRET"}) //ICMS ST
		aAdd(aOrc, {'MaFisRet(,"NF_VALPIS")', STR0108, 0, "SF1->F1_VALPIS"})  //PIS
		aAdd(aOrc, {'MaFisRet(,"NF_VALCOF")', STR0109, 0, "SF1->F1_VALCOFI"}) //COFINS
		aAdd(aOrc, {'MaFisRet(,"NF_VALPS2")', STR0110, 0, "SF1->F1_VALIMP6"}) //PS2
		aAdd(aOrc, {'MaFisRet(,"NF_VALCF2")', STR0111, 0, "SF1->F1_VALIMP5"}) //CF2
	endif
	aAdd(aOrc, {'MaFisRet(,"NF_TOTAL")',    STR0038, 0, "SF1->F1_VALBRUT"})   //Total

	if cPaisLoc $ "ARG|MEX"
		aAdd(aOrcDynHeader, {'MaFisRet(,"NF_VALMERC")',STR0031,0,"SF1->F1_VALMERC"})   //Valor Mercadorias

		aAdd(aOrcDynFooter, {'MaFisRet(,"NF_DESCONTO")', STR0032, 0, "SF1->F1_DESCONT"})   //Desconto
		aAdd(aOrcDynFooter, {'MaFisRet(,"NF_SEGURO")',   STR0033, 0, "SF1->F1_SEGURO"})    //Seguro
		aAdd(aOrcDynFooter, {'MaFisRet(,"NF_DESPESA")',  STR0034, 0, "SF1->F1_DESPESA"})   //Despesa
		aAdd(aOrcDynFooter, {'MaFisRet(,"NF_FRETE")',    STR0035, 0, "SF1->F1_FRETE"})     //Frete
		aAdd(aOrcDynFooter, {'MaFisRet(,"NF_TOTAL")',    STR0038, 0, "SF1->F1_VALBRUT"})   //Total
	endif

EndIf
//
// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aOrc
//
If ExistBlock("VX000MF1")
	ExecBlock("VX000MF1",.f.,.f.)
EndIf
//
aCpoEncS  := {} // ARRAY DE CAMPOS DA ENCHOICE
//
While !Eof().and.(x3_arquivo=="VVF")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(alltrim(x3_Campo) $ cFiltrVVFS)
		AADD(acpoEncS,x3_campo)
	EndIf
	If Inclui
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Else
		If x3_context == "V"
			&("M->"+x3_campo):= &(X3_RELACAO)
		Else
			&("M->"+x3_campo):= &("VVF->"+x3_campo)
		EndIf
	EndIf
	DbSkip()
EndDo  
If cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
	M->VVF_NUMNFI := Space(TamSx3("VVF_NUMNFI")[1])
	M->VVF_SERNFI := Space(TamSx3("VVF_SERNFI")[1])
EndIf
M->VVF_TPFATR := cTpFatR // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura
If ! lVX000Auto
	If cPaisLoc $ "ARG|MEX" // Argentina
		If nOpc == 3 // Inclusao somente 1=Fatura ou 2=Remito
			If M->VVF_TPFATR == "2" // 2= Remito
				M->VVF_ESPECI := "RCN"
			Else // 1=Fatura
				M->VVF_ESPECI := "NF"
			EndIf
		ElseIf nOpc == 4 // Alteração (3=Fatura com Remito)
			M->VVF_ESPECI := "NF"
		EndIf
	EndIf
EndIf

If !(cPaisLoc == "BRA") // Formulário Próprio somente no Brasil
	M->VVF_FORPRO := "0"
EndIf

If lImpXml
	Do Case
		Case FM_PILHA("U_IMPXMLV")
			M->VVF_CLIFOR := "F"
			M->VVF_FORPRO := "0"
			M->VVF_DATEMI := dEmissao
			M->VVF_OPEMOV := "0"
			M->VVF_DATMOV := dDataBase
			M->VVF_SITNFI := "1"
			M->VVF_NUMNFI := cNF_XML
			M->VVF_SERNFI := cSerie_XML
			M->VVF_CODFOR := SA2->A2_COD
			M->VVF_LOJA   := SA2->A2_LOJA
			M->VVF_NOMFOR := SA2->A2_NOME
			M->VVF_FORPAG := cCondicao
			M->VVF_NATURE := cNaturez
			M->VVF_CHVNFE := cChNFe
		Case FM_PILHA("U_IXMLVJD") // IXMLVJD
			For nCntFor := 1 to len(aAutoCab)
				&("M->"+aAutoCab[nCntFor,1]) := aAutoCab[nCntFor,2]
			Next
			If len(aAutoIteParc) > 0
				aIteParc := aClone(aAutoIteParc)
			EndIf
	EndCase
EndIf
M->VVF_OPEMOV := cX0OpeMov

If cTpFatR == "3" // 3=Fatura com Remito
	aAltVVG := {} // Deve carregar os campos que podem ser alterados
	cCposNAO := "VVG_CHASSI/VVG_ESTVEI/VVG_CODORI/VVG_LOCALI/VVG_LOCPAD/" // Campos que nao podem ser alterados
EndIf

//#####################################
//# Cria aHeader e aCols da GetDados  #
//#####################################
nUsadoV:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVG")
aHeaderV:={}
While !Eof().And.(x3_arquivo=="VVG")

	If (X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrVVG) .or. ( alltrim(x3_Campo) == "VVG_CHAINT" )

		nUsadoV := nUsadoV+1
		Aadd(aHeaderV,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )

		If cTpFatR == "3" .and. x3_visual <> "V" .and. !(x3_campo $ cCposNAO ) // 3=Fatura com Remito
			aAdd(aAltVVG,x3_campo) // somente campos que podem ser alterados quando Fatura com Remito
		EndIf

	EndIf
	If Inclui
		&("M->"+x3_campo) := CriaVar(x3_campo)
	EndIf
	DbSkip()
EndDo
//  CRIA ACOLS

If lImpXml

	aColsV := {}

	Do Case
		Case FM_PILHA("U_IMPXMLV")

			aColsV := { Array(nUsadoV+1) }
			aColsV[Len(aColsV),nUsadoV+1] := .F.

			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			DBSetOrder(1)
			cTESEnt := MaTesInt(1,Alltrim(cOper),SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)

			M->VVG_CHASSI := VV1->VV1_CHASSI
			M->VVG_CHAINT := VV1->VV1_CHAINT
			M->VVG_ESTVEI := VV1->VV1_ESTVEI
			M->VVG_LOCPAD := VV1->VV1_LOCPAD
			M->VVG_CODORI := VV1->VV1_CODORI
			//M->VVG_SITTRI := IIF(VV1->VV1_PROVEI=="1","0","1")
			M->VVG_VALUNI := nTValMerc
			M->VVG_CODTES := cTesEnt
			M->VVG_VBAIPI := val(nBaseIPI)
			M->VVG_ALIIPI := val(nAliIPI)
			M->VVG_VALIPI := val(nValIPI)
			M->VVG_VBAICM := val(nBaseICM)
			M->VVG_ALIICM := val(nAliICM)
			M->VVG_ICMCOM := val(nValICM)
			M->VVG_VBICRT := val(nBICMST)
			M->VVG_ICMRET := val(nValST)
			
			For nCntFor:=1 to nUsadoV
				aColsV[1,nCntFor]:=CriaVar(aHeaderV[nCntFor,2])
			Next

			M->VVG_OPER   := Alltrim(cOper)
			aColsV[1,FG_POSVAR("VVG_CHASSI","aHeaderV")] := M->VVG_CHASSI
			aColsV[1,FG_POSVAR("VVG_CHAINT","aHeaderV")] := M->VVG_CHAINT
			aColsV[1,FG_POSVAR("VVG_ESTVEI","aHeaderV")] := M->VVG_ESTVEI
			aColsV[1,FG_POSVAR("VVG_LOCPAD","aHeaderV")] := M->VVG_LOCPAD
			//aColsV[1,FG_POSVAR("VVG_SITTRI","aHeaderV")] := M->VVG_SITTRI
			aColsV[1,FG_POSVAR("VVG_VALUNI","aHeaderV")] := M->VVG_VALUNI
			aColsV[1,FG_POSVAR("VVG_OPER","aHeaderV")]   := M->VVG_OPER
			aColsV[1,FG_POSVAR("VVG_CODTES","aHeaderV")] := M->VVG_CODTES
			aColsV[1,FG_POSVAR("VVG_CODORI","aHeaderV")] := M->VVG_CODORI
			aColsV[1,FG_POSVAR("VVG_VBAIPI","aHeaderV")] :=	M->VVG_VBAIPI
			aColsV[1,FG_POSVAR("VVG_ALIIPI","aHeaderV")] :=	M->VVG_ALIIPI
			aColsV[1,FG_POSVAR("VVG_VALIPI","aHeaderV")] :=	M->VVG_VALIPI
			aColsV[1,FG_POSVAR("VVG_VBAICM","aHeaderV")] :=	M->VVG_VBAICM
			aColsV[1,FG_POSVAR("VVG_ALIICM","aHeaderV")] :=	M->VVG_ALIICM
			aColsV[1,FG_POSVAR("VVG_ICMCOM","aHeaderV")] :=	M->VVG_ICMCOM
			aColsV[1,FG_POSVAR("VVG_VBICRT","aHeaderV")] :=	M->VVG_VBICRT
			aColsV[1,FG_POSVAR("VVG_ICMRET","aHeaderV")] :=	M->VVG_ICMRET

		Case FM_PILHA("U_IXMLVJD") // IXMLVJD

			For nCntFor := 1 to len(aAutoItens)
				AADD(aColsV,Array(nUsadoV+1))
				For nCntFor2:=1 to nUsadoV
					aColsV[len(aColsV),nCntFor2]:=CriaVar(aHeaderV[nCntFor2,2])
				Next
				For nCntFor2:=1 to len(aAutoItens[nCntFor])
					nPos := FG_POSVAR(aAutoItens[nCntFor,nCntFor2,1],"aHeaderV")
					If nPos > 0
						aColsV[len(aColsV),nPos] := aAutoItens[nCntFor,nCntFor2,2]
					EndIf
					&("M->"+aAutoItens[nCntFor,nCntFor2,1]) := aAutoItens[nCntFor,nCntFor2,2]
				Next
				aColsV[Len(aColsV),nUsadoV+1]:=.F.
			Next

	EndCase

Else

	If INCLUI
		aColsV := { Array(nUsadoV+1) }
		aColsV[1,nUsadoV+1] := .F.
		For nCntFor:=1 to nUsadoV
			aColsV[1,nCntFor]:=CriaVar(aHeaderV[nCntFor,2])
		Next
	Else
		aColsV:={}
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		While !eof() .and. VVG->VVG_FILIAL == xFilial("VVG");
			.and. VVF->VVF_TRACPA == VVG->VVG_TRACPA
			AADD(aColsV,Array(nUsadoV+1))
			For nCntFor:=1 to nUsadoV
				If aHeaderV[nCntFor,10]  <> "V"
					aColsV[Len(aColsV),nCntFor] := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
					&("M->"+aHeaderV[nCntFor,2]) := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
				EndIf
			Next
			aColsV[Len(aColsV),nUsadoV+1]:=.F.
			DbSkip()
		EndDo
	EndIf
EndIf
//
If xTIPDOC == "1" .OR. lAtuFiscal // 1=NF / 2=SD3 (Mov.Internas)
	// ZERA A PILHA FISCAL
	MaFisEnd()
EndIf
//
If ! lVX000Auto
	//####################################################
	//# Monta condicao de pagamento e dados da NF        #
	//####################################################
	If !INCLUI
		VX000LOADCP()
		VX000LOADNF()

		If lMoeda
			VX0000016_LoadMoeda()
		EndIf
	EndIf
	// FUNCOES DE TECLA //// ƒ€
	SETKEY(VK_F4,{||VX000KEYF4()})
	// FUNCOES DE CONTROLE DE EVENTOS DA GETDADOS
	cLinOk        :="VX000LINOK('"+xTIPDOC+"')"
	cFieldOk      :="VX000FIELDOK()"
	cTudoOk		  :="VX000TUDOK("+strzero(nOpc,1)+",'"+xTIPDOC+"')"
	// COPIA VETORES DA ACOLS MONTADA PARA AS VARIAVEIS PADRAO DA ACOLS
	aCols	:= aClone(aColsV)
	aHeader	:= aClone(aHeaderV)
	If cPaisLoc <> "BRA"
		aMoedaOld := {}
		AAdd(aMoedaOld, nMoedaCor    )
		AAdd(aMoedaOld, nTaxaMoeda   )
		AAdd(aMoedaOld, aClone(aCols))
	EndIf
	// MONTAGEM DA TELA
	// VARIAVEIS PARA DIVISAO DAS LINHAS NA ABA UM DO FOLDER
	dy5 := (aPosAba1[1,4] - aPosAba1[1,2])/5	// STEP DA POSICAO INICIAL
	sl5 := (aPosAba1[2,4] - aPosAba1[2,2])/5	// LARGURA DA CELULA
	sc5 :=  aPosAba1[2,3] - aPosAba1[2,1]			// COMPRIMENTO DA CELULA
	//#############################################################################
	//# Monta a tela da nota fiscal de entrada enchoice + acols + folders         #
	//#############################################################################
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (cCadastro) Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Documento de Entrada
	oDlg:lEscClose := .F.
	//#############
	//# ENCHOICE  #
	//#############
	aCombo := {"1="+STR0004,"0="+STR0005} //Sim - Nao
	dyc7 := (aPosAbaCab[1,4] - aPosAbaCab[1,2])/7	// STEP DA POSICAO INICIAL
	scc7 := aPosAbaCab[2,3] - aPosAbaCab[2,1]		// COMPRIMENTO DA CELULA
	spc := 45
	
	If nOpc == 3 // Somente INCLUIR
		If cX0OpeMov $ "245" // remessa / consignacao / devolucao
			M->VVF_CLIFOR := "C"
		Else
			if cX0OpeMov $ "78" // retorno de remessa / retorno de consignacao 
				M->VVF_CLIFOR := "C"
			Else
				M->VVF_CLIFOR := "F"
			Endif
		Endif
	Endif

	// Cabeçalho
	oTScroll := TScrollBox():New(oDlg, aPosObj[1,1], aPosObj[1,2], aPosObj[1,3] - 015,  ;
		aPosObj[1,4] - 004, .T., .T., .T.)

	// L I N H A  1
	If cX0OpeMov $ "0"
		cCFWhen := .f.
	Else
		cCFWhen := "(Empty(M->VVF_CODFOR) .or. Empty(M->VVF_LOJA))"
	Endif
	FSX_POSCPO("VVF_CLIFOR", "oSayE12", aPosAbaCab[1,1]-1, aPosAbaCab[1,2],               ;
		spc, "aCliFor",,,, "oTScroll", "oGetE12", cCFWhen)
	FSX_POSCPO("VVF_FORPRO", "oSayE11", aPosAbaCab[1,1]-1, aPosAbaCab[1,2] + 2.4 * dyc7,  ;
		spc, "aCombo",,,, "oTScroll", "oGetE11", Iif(cPaisLoc == "BRA",.T.,.F.)) // Formulário Próprio somente no Brasil

	If cTpFatR == "3" // 3=Fatura com Remito
		// Necessário incluir manualmente o campo que pode ser alterado no Faturamento
		oSayE13 := TSay():New(aPosAbaCab[1,1],aPosAbaCab[1,2] + 4.8 * dyc7,{|| &("'"+RetTitle("VVF_DATEMI")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_DATEMI"),CLR_HBLUE,CLR_BLACK),,45,8)
		@ aPosAbaCab[1,1] - 1,spc+aPosAbaCab[1,2] + 4.8 * dyc7 MSGET oGetE13 VAR M->VVF_DATEMI PICTURE SX3->(X3Picture("VVF_DATEMI")) VALID &(GetSX3Cache("VVF_DATEMI","X3_VALID")) SIZE 45,8 PIXEL OF oTScroll
	Else
		FSX_POSCPO("VVF_DATEMI", "oSayE13", aPosAbaCab[1,1], aPosAbaCab[1,2] + 4.8 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE13")
	EndIf

	// L I N H A  2
	FSX_POSCPO("VVF_CODFOR", "oSayE21", aPosAbaCab[2,1], aPosAbaCab[2,2],             ;
		spc,, RetTitle("VV0_CODCLI"), "SA1",, "oTScroll", "oGetE21")
	FSX_POSCPO("VVF_CODFOR", "oSayE34", aPosAbaCab[2,1], aPosAbaCab[2,2],             ;
		spc,, RetTitle("VVF_CODFOR"), "FOR",, "oTScroll", "oGetE21")
	FSX_POSCPO("VVF_LOJA", "oSayE22", aPosAbaCab[2,1], aPosAbaCab[2,2] + 2.4 * dyc7,  ;
		spc,, RetTitle("A1_LOJA"),,, "oTScroll", "oGetE22")
	FSX_POSCPO("VVF_NOMFOR", "oSayE23", aPosAbaCab[2,1], aPosAbaCab[2,2] + 4.8 * dyc7,;
		spc,, STR0097,,, "oTScroll", "oGetE23") // Nome
	If M->VVF_CLIFOR == "C"
		oSayE34:lVisible := .f.
	Else
		oSayE21:lVisible := .f.
	EndIf

	// L I N H A  3
	If cPaisLoc $ "ARG|MEX" .and. ( INCLUI .or. ALTERA )
		// Necessário incluir manualmente o campo que pode ser alterado no Faturamento
		If (cTpFatR $ "1/3/4".And.cPaisLoc == 'ARG').Or.(cTpFatR $ "1/3".And.cPaisLoc == 'MEX') // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
			oSayE31 := TSay():New(aPosAbaCab[3,1],aPosAbaCab[3,2],{|| &("'"+RetTitle("VVF_NUMNFI")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_NUMNFI"),CLR_HBLUE,CLR_BLACK),,45,8)
			oSayE32 := TSay():New(aPosAbaCab[3,1],aPosAbaCab[3,2]+ 2.4 * dyc7,{|| &("'"+RetTitle("VVF_SERNFI")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_SERNFI"),CLR_HBLUE,CLR_BLACK),,45,8)
		Else // 2=Remito
			oSayE31 := TSay():New(aPosAbaCab[3,1],aPosAbaCab[3,2],{|| &("'"+RetTitle("VVF_REMITO")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_REMITO"),CLR_HBLUE,CLR_BLACK),,45,8)
			oSayE32 := TSay():New(aPosAbaCab[3,1],aPosAbaCab[3,2]+ 2.4 * dyc7,{|| &("'"+RetTitle("VVF_SERREM")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_SERREM"),CLR_HBLUE,CLR_BLACK),,45,8)
		EndIf
		@ aPosAbaCab[3,1] - 1,spc+aPosAbaCab[3,2] MSGET oGetE31 VAR M->VVF_NUMNFI VALID FSX_VALIDCPO("",.f.) PICTURE SX3->(X3Picture("VVF_NUMNFI")) SIZE 45,8 PIXEL OF oTScroll
		@ aPosAbaCab[3,1] - 1,spc+aPosAbaCab[3,2]+ 2.4 * dyc7 MSGET oGetE32 VAR M->VVF_SERNFI VALID FSX_VALIDCPO("",.f.) PICTURE SX3->(X3Picture("VVF_SERNFI")) VALID &(GetSX3Cache("VVF_SERNFI","X3_VALID")) SIZE 25,8 PIXEL OF oTScroll
	Else
		FSX_POSCPO("VVF_NUMNFI", "oSayE31", aPosAbaCab[3,1], aPosAbaCab[3,2],               ;
			spc,,,,, "oTScroll", "oGetE31")
		FSX_POSCPO("VVF_SERNFI", "oSayE32", aPosAbaCab[3,1], aPosAbaCab[3,2] + 2.4 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE32")
	EndIf
	FSX_POSCPO("VVF_NUMPED", "oSayE33", aPosAbaCab[3,1], aPosAbaCab[3,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE33")

	// L I N H A  4
	If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
		If cTpFatR == "3" // 3=Fatura com Remito
			// Necessário incluir manualmente o campo que pode ser alterado no Faturamento
			oSayE41 := TSay():New(aPosAbaCab[4,1],aPosAbaCab[4,2],{|| &("'"+RetTitle("VVF_FORPAG")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_FORPAG"),CLR_HBLUE,CLR_BLACK),,45,8)
			@ aPosAbaCab[4,1] - 1,spc+aPosAbaCab[4,2] MSGET oGetE41 VAR M->VVF_FORPAG PICTURE SX3->(X3Picture("VVF_FORPAG")) VALID &(GetSX3Cache("VVF_FORPAG","X3_VALID")) F3 GetSX3Cache("VVF_FORPAG","X3_F3") SIZE 45,8 PIXEL OF oTScroll
			oSayE43 := TSay():New(aPosAbaCab[4,1],aPosAbaCab[4,2] + 4.8 * dyc7,{|| &("'"+RetTitle("VVF_NATURE")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_NATURE"),CLR_HBLUE,CLR_BLACK),,45,8)
			@ aPosAbaCab[4,1] - 1,spc+aPosAbaCab[4,2] + 4.8 * dyc7 MSGET oGetE43 VAR M->VVF_NATURE PICTURE SX3->(X3Picture("VVF_NATURE")) VALID &(GetSX3Cache("VVF_NATURE","X3_VALID")) F3 GetSX3Cache("VVF_NATURE","X3_F3") SIZE 45,8 PIXEL OF oTScroll
		Else // Fatura
			FSX_POSCPO("VVF_FORPAG", "oSayE41", aPosAbaCab[4,1], aPosAbaCab[4,2],               ;
			spc,,,,, "oTScroll", "oGetE41")
			FSX_POSCPO("VVF_NATURE", "oSayE43", aPosAbaCab[4,1], aPosAbaCab[4,2] + 4.8 * dyc7,  ;
				spc,,,,, "oTScroll", "oGetE43")
		EndIf
		FSX_POSCPO("VVF_DESFPG", "oSayE42", aPosAbaCab[4,1], aPosAbaCab[4,2] + 2.4 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE42")
	EndIf

	if cPaisLoc == "BRA"
		// L I N H A  5
		FSX_POSCPO("VVF_CODBCO", "oSayE51", aPosAbaCab[5,1], aPosAbaCab[5,2],               ;
			spc,,,,, "oTScroll", "oGetE51")
		FSX_POSCPO("VVF_CODAGE", "oSayE52", aPosAbaCab[5,1], aPosAbaCab[5,2] + 2.4 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE52")
		FSX_POSCPO("VVF_CODCOM", "oSayE53", aPosAbaCab[5,1], aPosAbaCab[5,2] + 4.8 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE53")
	EndIf

	// L I N H A  6
	FSX_POSCPO("VVF_DESACE", "oSayE61", aPosAbaCab[6,1], aPosAbaCab[6,2],               ;
		spc,,,,, "oTScroll", "oGetE61",,,,,, .t.)
	FSX_POSCPO("VVF_TRANSP", "oSayE62", aPosAbaCab[6,1], aPosAbaCab[6,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE62")
	FSX_POSCPO("VVF_ESPEC1", "oSayE63", aPosAbaCab[6,1], aPosAbaCab[6,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE63")

	// L I N H A  7
	FSX_POSCPO("VVF_VOLUM1", "oSayE71", aPosAbaCab[7,1], aPosAbaCab[7,2],               ;
		spc,,,,, "oTScroll", "oGetE71")
	FSX_POSCPO("VVF_PLIQUI", "oSayE72", aPosAbaCab[7,1], aPosAbaCab[7,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE72")
	FSX_POSCPO("VVF_PBRUTO", "oSayE73", aPosAbaCab[7,1], aPosAbaCab[7,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE73")

	// L I N H A  8
	If cPaisLoc $ "ARG|MEX" // Na ARGENTINA/MEXICO o campo não deve ser alterado
		oSayE81 := TSay():New(aPosAbaCab[8,1],aPosAbaCab[8,2],{|| &("'"+RetTitle("VVF_ESPECI")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_ESPECI"),CLR_HBLUE,CLR_BLACK),,45,8)
		@ aPosAbaCab[8,1] - 1,spc+aPosAbaCab[8,2] MSGET oGetE81 VAR M->VVF_ESPECI PICTURE SX3->(X3Picture("VVF_ESPECI")) SIZE 20,8 PIXEL OF oTScroll WHEN .f.
	Else
		FSX_POSCPO("VVF_ESPECI", "oSayE81", aPosAbaCab[8,1], aPosAbaCab[8,2],               ;
			spc,,,,, "oTScroll", "oGetE81")
	EndIf

	oSayE71 := TSay():New(aPosAbaCab[8,1], aPosAbaCab[8,2] + 2.4 * dyc7, {|| RetTitle("VVF_OBSERV") },;
		oTScroll,, oFnt3,,,, .t., IIf(X3Obrigat("VVF_OBSMEM"), CLR_HBLUE, CLR_BLACK),, spc, 8)
	If INCLUI .or. ALTERA
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 2.4 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSERV OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL MEMO
	Else
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 2.4 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSERV OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL READONLY MEMO
	EndIf
	//
	oSayE71 := TSay():New(aPosAbaCab[8,1], aPosAbaCab[8,2] + 4.8 * dyc7, {|| RetTitle("VVF_OBSENF") },;
		oTScroll,, oFnt3,,,, .t., IIf(X3Obrigat("VVF_OBSMNF"), CLR_HBLUE, CLR_BLACK),, spc, 8)
	If INCLUI .or. ALTERA
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 4.8 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSENF OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL MEMO
	Else
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 4.8 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSENF OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL READONLY MEMO
	EndIf

	If cPaisLoc == "BRA"

		// L I N H A  9
		FSX_POSCPO("VVF_CHVNFE", "oSayE91", aPosAbaCab[9,1], aPosAbaCab[9,2],                    ;
			spc,,,,, "oTScroll")

	EndIf

	If At("VVF_TOTFRE",cFiltrVVFS) <> 0
		FSX_POSCPO("VVF_TOTFRE", "oSayE101", aPosAbaCab[10,1], aPosAbaCab[10,2],               ;
			spc,,,,, "oTScroll", "oGetE101",,,,,, .t.)
	EndIf

	// Veículo Transportador (Integração MATA103 - CI 008022)
	FSX_POSCPO("VVF_VEICU1", "oSayE111", aPosAbaCab[11,1], aPosAbaCab[11,2],               ;
		spc,,,,, "oTScroll", "oGetE111")

	FSX_POSCPO("VVF_VEICU2", "oSayE112", aPosAbaCab[11,1], aPosAbaCab[11,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE112")

	FSX_POSCPO("VVF_VEICU3", "oSayE113", aPosAbaCab[11,1], aPosAbaCab[11,2] + 4.8 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE113")

	aCBOX_TPFret := X3CBOXAVET("VVF_TPFRET","1")
	FSX_POSCPO("VVF_TPFRET", "oSayE123", aPosAbaCab[12,1]-1, aPosAbaCab[12,2] ,  ;	
		spc, "aCBOX_TPFret",,,, "oTScroll", "oGetE123")

	if cPaisLoc == "BRA" .and. ( M->VVF_FORPRO == "1" .or. INCLUI .or. ALTERA )
		FSX_POSCPO("VVF_MENPAD", "oSayE121", aPosAbaCab[12,1], aPosAbaCab[12,2] + 2.4 * dyc7,             ;
			spc,,,,, "oTScroll", "oGetE121")
		FSX_POSCPO("VVF_MENNOT", "oSayE122", aPosAbaCab[12,1], aPosAbaCab[12,2] + 4.8 * dyc7,;
			spc,,,,, "oTScroll", "oGetE122")
	Endif

	If cPaisLoc $ "ARG|MEX" .and. nOpc <> 3 // Mosta campos de REMITO quando não for inclusão
		FSX_POSCPO("VVF_REMITO", "oSayE121R", aPosAbaCab[12,1], aPosAbaCab[12,2] + 2.4 * dyc7,             ;
			spc,,,,, "oTScroll", "oGetE121R")
		FSX_POSCPO("VVF_SERREM", "oSayE122S", aPosAbaCab[12,1], aPosAbaCab[12,2] + 4.8 * dyc7,;
			spc,,,,, "oTScroll", "oGetE122S")
	EndIf

	nLinha := 13 // Sequência

	// Placa do Veículo Transportador (Integração MATA103 - CI 012236)
	If VVF->(FieldPos("VVF_PLACA")) > 0
		nLinha++
		FSX_POSCPO("VVF_PLACA", "oSayE124", aPosAbaCab[13,1], aPosAbaCab[13,2],               ;
			spc,,,"DA302",, "oTScroll", "oGetE124")
	EndIf

	if cPaisLoc $ "ARG|MEX"
		If cPaisLoc == 'ARG'
			If cTpFatR == "3" // 3=Fatura com Remito
				// Necessário incluir manualmente o campo que pode ser alterado no Faturamento
				oSayE125 := TSay():New(aPosAbaCab[13,1],aPosAbaCab[13,2] + 2.4 * dyc7,{|| &("'"+RetTitle("VVF_PROVEN")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_PROVEN"),CLR_HBLUE,CLR_BLACK),,45,8) // Provincia de Venda 
				@ aPosAbaCab[13,1] - 1,spc+aPosAbaCab[13,2] + 2.4 * dyc7 MSGET oGetE125 VAR M->VVF_PROVEN PICTURE SX3->(X3Picture("VVF_PROVEN")) VALID &(GetSX3Cache("VVF_PROVEN","X3_VALID")) F3 "12" SIZE 30,8 PIXEL OF oTScroll
			Else
				FSX_POSCPO("VVF_PROVEN", "oSayE125", aPosAbaCab[13,1], aPosAbaCab[13,2] + 2.4 * dyc7,  ; // Provincia de Venda 
					spc,,,"12",, "oTScroll", "oGetE125")
			EndIf
		nLinha++
		EndIf
		If cX0OpeMov == "0" .And. cPaisLoc == "ARG"  // Somente Entrada por Compra deve apresentar os campos referente ao CAE
			If cTpFatR == "3" // 3=Fatura com Remito
				// Necessário incluir manualmente o campo que pode ser alterado no Faturamento
				oSayE126 := TSay():New(aPosAbaCab[14,1],aPosAbaCab[14,2],{|| &("'"+RetTitle("VVF_CAE")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_CAE"),CLR_HBLUE,CLR_BLACK),,45,8)
				@ aPosAbaCab[14,1] - 1,spc+aPosAbaCab[14,2] MSGET oGetE126 VAR M->VVF_CAE PICTURE SX3->(X3Picture("VVF_CAE")) SIZE 55,8 PIXEL OF oTScroll
				oSayE127 := TSay():New(aPosAbaCab[14,1],aPosAbaCab[14,2]+ 2.4 * dyc7,{|| &("'"+RetTitle("VVF_VCTCAE")+"'") },oTScroll,,oFnt3,,,,.t.,IIf(X3Obrigat("VVF_VCTCAE"),CLR_HBLUE,CLR_BLACK),,45,8)
				@ aPosAbaCab[14,1] - 1,spc+aPosAbaCab[14,2]+ 2.4 * dyc7 MSGET oGetE127 VAR M->VVF_VCTCAE PICTURE SX3->(X3Picture("VVF_VCTCAE")) SIZE 45,8 PIXEL OF oTScroll
			Else
				FSX_POSCPO("VVF_CAE"   , "oSayE126", aPosAbaCab[14,1], aPosAbaCab[14,2],  ; // CAE
					spc,,,,, "oTScroll", "oGetE126")
				FSX_POSCPO("VVF_VCTCAE", "oSayE127", aPosAbaCab[14,1], aPosAbaCab[14,2] + 2.4 * dyc7,  ; // VENCIMENTO CAE
					spc,,,,, "oTScroll", "oGetE127")
			EndIf
			nLinha++
		EndIf
	EndIf

	// Ponto de Entrada para adicionar campos customizáveis da VVF
	If ExistBlock("VX000CPO")
		aCposUser := ExecBlock("VX000CPO", .f., .f.)
	EndIf

	If Len(aCposUser) > 0
		nColuna := 1
		nLinCpo := aPosAbaCab[nLinha,1]
		nColCpo := aPosAbaCab[1,2]

		For ni := 1 to Len(aCposUser)
			SX3->(DbSetOrder(2))

			If !Empty(aCposUser[ni]) .And. SX3->(DbSeek(aCposUser[ni]))
				If SX3->X3_CONTEXT <> "V" .And. SX3->X3_TIPO <> "M" // Somente campos Reais (não Memos)
					cCombo  := {}

					If SX3->X3_TIPO == "C" .And. !Empty(SX3->X3_CBOX)
						cCombo := X3CBOXAVET(SX3->X3_CAMPO, "0")
					EndIf

					FSX_POSCPO(aCposUser[ni], "oSayE" + Alltrim(Str(nLinha)) + Alltrim(Str(nColuna)),   ;
						nLinCpo, nColCpo, spc, Iif(Len(cCombo) > 0 .And. !Empty(cCombo[1]), "cCombo", ""),;
						,,, "oTScroll", "oGetE" + Alltrim(Str(nLinha)) + Alltrim(Str(nColuna)))

					nColuna++
					If nColuna == 2
						nColCpo := aPosAbaCab[1,2] + 2.4 * dyc7
					ElseIf nColuna == 3
						nColCpo := aPosAbaCab[1,2] + 4.8 * dyc7
					Else
						nLinha++
						nColuna := 1
						nLinCpo := aPosAbaCab[2,1] - aPosAbaCab[1,1] + nLinCpo
						nColCpo := aPosAbaCab[1,2]
					EndIf
				Else
					aCposUser[ni] := "" // CAMPO NAO EXISTE NA BASE - NAO GRAVAR
				EndIf
			Else
				aCposUser[ni] := "" // CAMPO NAO EXISTE NA BASE - NAO GRAVAR
			EndIf
		Next

		SX3->(DbSetOrder(1))
	EndIf

	If cTpFatR == "3" // 3=Fatura com Remito
		nQtdVei := len(aColsV) // limita para NAO deixar criar novas linhas
	EndIf	

	//#############################################################################
	//# GETDADOS                                                                  #
	//#############################################################################
	nLinha := 20 // Altura entre TScrollBox e MsGetDados
	oGetDados := MsGetDados():New(aPosObj[2,1] + nLinha, aPosObj[2,2], aPosObj[2,3],;
		aPosObj[2,4], nOpc, cLinOK, cTudoOk, "",;
		IIf(nOpc > 2 .and. nOpc < 5, .t., .f.),aAltVVG,,,nQtdVei, cFieldOk,,,, oDlg)
	//
	If (INCLUI .Or. ALTERA) .and. cTpFatR $ "1/2/4" // 1=Fatura / 2=Remito / 4=Entrega Futura
		oGetDados:oBrowse:bDelete := {|| VX000DLIN(.t.), oGetDados:oBrowse:Refresh() }
	Else
		oGetDados:oBrowse:bDelete := {|| .f. }
	EndIf
	//
	oFolder := TFolder():New(aPosObj[3,1], aPosObj[3,2], aTitulo, {},;
		oDlg,,,, .t., .f., aPosObj[3,4] - aPosObj[3,2], aPosObj[3,3] - aPosObj[3,1])
	//#############################################################################
	//# FOLDER                                                                    #
	//#############################################################################
	// A B A  1
	@ aPosAba1[1,1], aPosAba1[1,2] LISTBOX olBox FIELDS HEADER          ;
		OemToAnsi(STR0006), OemToAnsi(STR0007) COLSIZES sl5 * 2, sl5 * 2  ; // Descricao / Valor
		SIZE aPosAba1[5,4] - aPosAba1[1,2], aPosAba1[5,3] - aPosAba1[1,1] ;
		OF oFolder:aDialogs[1] PIXEL
	//
	olBox:SetArray(aOrc)
	//
	olBox:bLine := {|| { aOrc[olBox:nAt,2],;
		FG_AlinVlrs(Transform(aOrc[olBox:nAt,3], "@E 999,999,999.99")) }}

	If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
		// A B A  2
		oSay21 := TSay():New(aPosAba1[1,1], aPosAba1[1,2],                               ;
			{|| STR0008 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Data Inicial
		//
		oDatIni:= TGet():New(aPosAba1[1,1], aPosAba1[1,2] + dy5,                         ;
			{|u| If(PCount() > 0, dDataIni := u, dDataIni)}, oFolder:aDialogs[2], sl5, sc5,;
			"@D",,,,,,, .T.,,,,,,,,,, "dDataIni")
		//
		oSay22 := TSay():New(aPosAba1[2,1], aPosAba1[2,2],                               ;
			{|| STR0009 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Dias 1a.Parc
		//
		oDias1P:= TGet():New(aPosAba1[2,1], aPosAba1[2,2] + dy5,                         ;
			{|u| IIf(PCount() > 0, nDias1P := u, nDias1P)}, oFolder:aDialogs[2], sl5, sc5, ;
			"@E 9999",,,,,,, .T.,,,,,,,,,, "nDias1P")
		//
		oSay23 := TSay():New(aPosAba1[3,1], aPosAba1[3,2],                               ;
			{|| STR0010 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Parcelas
		//
		oParcel:= TGet():New(aPosAba1[3,1], aPosAba1[3,2] + dy5,                         ;
			{|u| If(PCount() > 0, nParcel := u, nParcel)}, oFolder:aDialogs[2], sl5, sc5,  ;
			"@E 9999",,,,,,, .T.,,,,,,,,,, "nParcel")
		//
		oSay24 := TSay():New(aPosAba1[4,1], aPosAba1[4,2],                               ;
			{|| STR0011 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Intervalo
		//
		oInterv:= TGet():New(aPosAba1[4,1], aPosAba1[4,2] + dy5,                         ;
			{|u| If(PCount() > 0, nInterv := u, nInterv)}, oFolder:aDialogs[2], sl5, sc5,  ;
			"@E 9999",,,,,,, .T.,,,,,,,,,, "nInterv")

		// BOTOES DO COMO PAGAR
		oBtnCalc := tButton():New(aPosAba1[1,1], aPosAba1[1,2] + 2 * dy5,                ;
			STR0012, oFolder:aDialogs[2], {|| VX000CANPAR(1), VX000ATUCP()}, sl5, sc5,,,, .T.) // Calcular
		oBtnDesf := tButton():New(aPosAba1[2,1], aPosAba1[2,2] + 2 * dy5,                ;
			STR0013, oFolder:aDialogs[2], {|| VX000CANPAR(0)}, sl5, sc5,,,, .T.) // Desfazer

		// LISTBOX DO COMO PAGAR
		oLbParc := TWBrowse():new(aPosAba1[1,1], aPosAba1[1,2] + 3 * dy5 , 2 * dy5 , aPosAba1[5,3] - aPosAba1[1,1] ,,,,oFolder:aDialogs[2],,,,,{ || VX000ALTFIN(oLbParc:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
		oLbParc:addColumn( TCColumn():new( STR0014 , { || Transform(aIteParc[oLbParc:nAt,1],"@D") }                ,,,, "LEFT"  , 40 ,.F.,.F.,,,,.F.,) ) // Data
		oLbParc:addColumn( TCColumn():new( STR0007 , { || Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99") } ,,,, "RIGHT" , 50 ,.F.,.F.,,,,.F.,) ) // Valor
		If len(aParcCust) > 0
			For nCntFor := 1 to len(aParcCust)
				oLbParc:addColumn( TCColumn():new( &("aParcCust["+str(nCntFor)+",1]") , &("{ || Transform(aIteParc[oLbParc:nAt,3,"+str(nCntFor)+"],aParcCust["+str(nCntFor)+",3]) }") ,,,, &("aParcCust["+str(nCntFor)+",5]") , &("aParcCust["+str(nCntFor)+",4]") ,.F.,.F.,,,,.F.,) ) // Campos Customizados no aIteParc
			Next
		EndIf
		oLbParc:nAt := 1
		oLbParc:setArray( aIteParc )
		//
		oDatIni:disable()
		oDias1P:disable()
		oParcel:disable()
		oInterv:disable()
		//
	EndIf
	
	If lMoeda
		// A B A  3
		If VVF->(FieldPos("VVF_MOEDA")) > 0
			oSay31 := TSay():New(aPosAba1[1,1], aPosAba1[1,2],;
				{|| RetTitle("VVF_MOEDA") }, oFolder:aDialogs[3],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Moeda

			oMoeda := TGet():New(aPosAba1[1,1], aPosAba1[1,2] + dy5,;
				{|u| If(PCount() > 0, nMoedaCor := u, nMoedaCor)}, oFolder:aDialogs[3], sl5, sc5,;
				X3Picture("VVF_MOEDA"), {|| nMoedaCor <= MoedFin() .And. nMoedaCor <> 0 .And. VX0000026_AtualizaTaxa(oMoeda, oTaxa, oSay31) };
				,,,,,, .T.,,,,,,,,,, "nMoedaCor")
			oMoeda:lReadOnly := IIF((INCLUI .Or. ALTERA), .f., .t.)
		EndIf

		If VVF->(FieldPos("VVF_TXMOED")) > 0
			oSay32 := TSay():New(aPosAba1[2,1], aPosAba1[2,2],;
				{|| RetTitle("VVF_TXMOED") }, oFolder:aDialogs[3],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Taxa Moeda

			oTaxa := TGet():New(aPosAba1[2,1], aPosAba1[2,2] + dy5,;
				{|u| If(PCount() > 0, nTaxaMoeda := u, nTaxaMoeda)}, oFolder:aDialogs[3], sl5, sc5,;
				X3Picture("VVF_TXMOED"), {|| VX000ATUCP()},,,,,, .T.,,,,,,,,,, "nTaxaMoeda")
				oTaxa:lReadOnly := IIF((INCLUI .Or. ALTERA) .And. nMoedaCor <> 1, .f., .t.)
		EndIf
	EndIf
	//
	// INICIALMENTE APENAS O CABECALHO DA TELA ESTARA HABILITADA QUANDO FOR INCLUSAO
	If INCLUI
		If !lImpXml
			oGetDados:disable()
			oFolder:disable()
		Endif
	ElseIf !ALTERA
		oBtnCalc:disable()
		oBtnDesf:disable()
	EndIf
	//
	If cPaisLoc $ "ARG|MEX" // Necessário disparar o Fiscal na Argentina ao abrir a Tela
		VX0000081_Inicializa_Fiscal() // Inicializar o Fiscal na Abertura da Tela
	EndIf
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| lRet := IIf(VX000TUDOK(nOpc,xTIPDOC),VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR),.f.)},{|| IIf(VX000TSAIR(nOpc,cX0OpeMov),(nOpca:=0,oDlg:End()),.t.)},,aNewBot), VX000RDVFor() )
	//
Else
	lRet := .t.
	//################################################################
	//# Monta Enchoice e GetDados automaticamente para a integracao  #
	//################################################################
	aCols	:= {}
	aHeader := aClone(aHeaderV)
	// Cancelamento
	If nOpc == 5
		nRecVVF := VX000POSVVF(aAutoCab)
		If nRecVVF <> 0

			VVF->(dbGoTo(nRecVVF))

			aCols := {}
			dbSelectArea("VVG")
			dbSetOrder(1)
			dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
			While !eof() .and. VVG->VVG_FILIAL == xFilial("VVG") .and. VVF->VVF_TRACPA == VVG->VVG_TRACPA
				AADD(aCols,Array(nUsadoV+1))

				For nCntFor:=1 to nUsadoV
					aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
					If aHeaderV[nCntFor,2]  <> "V"
						&("M->"+aHeaderV[nCntFor,2]) := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
					EndIf
				Next

				aCols[Len(aCols),nUsadoV+1]:=.F.
				DbSkip()
			EndDo

			If Len(aCols) == 0
				FMX_HELP("VEIX000E14",STR0114,STR0115 + " - " + VVF->VVF_TRACPA ) // "Erro ao carregar itens do movimento." // "Verifique o movimento
			Else
				lRet := VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
			EndIf

		Else
			lRet := .f.
		EndIf
	Else
		If EnchAuto("VVF",aAutoCab)
			MsGetDAuto(aAutoItens,"VX000LINOK('"+xTIPDOC+"')",{|| VX000TUDOK(nOpc,xTIPDOC).And.VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)},aAutoCab,nOpc)
		Else
			lRet := .f.
		EndIf
	EndIf
EndIf
//
VVF->(DbSetOrder(1))
//
SET KEY VK_F4 TO
Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000LOADNF | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Traz dados do folder 1 (dados da nf)                         |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000LOADNF()
Local nCntFor
If VVF->VVF_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	Return
EndIf
//
If VVF->VVF_SITNFI == "0" // Nf Cancelada
	set delete off
Endif
//
if VVF->VVF_RECSF1 > 0
	DBSelectArea("SF1")
	DbGoTo(VVF->VVF_RECSF1)
Else
	DBSelectArea("SF1")
	DBSetOrder(1)
	DBSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
Endif
if cPaisLoc $ "ARG|MEX"
	VX0000063_ResumoImpostosArgentina()
else
	for nCntFor := 1 to Len(aOrc)
		aOrc[nCntFor,3] := &(aOrc[nCntFor,4])
	next
endif
//
If VVF->VVF_SITNFI == "0" // Nf Cancelada
	set delete on
Endif
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000LOADCP | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Traz dados do folder 2 (dados do como pagar)                 |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000LOADCP()
Local nCntFor := 0
//
aIteParc := {}
//
If VVF->VVF_TIPDOC == "2" .or. ( cPaisLoc $ "ARG|MEX" .and. VVF->VVF_TPFATR == "2" ) // 1 = NF / 2 = Mov.Internas (SD3)   ou   Argentina Remito
	aAdd(aIteParc,{ ctod("") , 0 , {} })
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
	Return
EndIf

set delete off
DBSelectArea("SF1")
DBSetOrder(1)
If DBSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
	//
	cAlSE2 := "SQLSE2"
	cQuery := "SELECT E2_VENCREA, E2_VALOR "
	//
	If len(aParcCust) > 0
		For nCntFor := 1 to len(aParcCust)
			cQuery += ", "+aParcCust[nCntFor,2]
		Next
	EndIf
	//
	cQuery += "  FROM "+RetSqlName("SE2")+" "
	cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
	cQuery += "   AND E2_PREFIXO = '"+SF1->F1_PREFIXO+"'"
	cQuery += "   AND E2_NUM = '"+VVF->VVF_NUMNFI+"'"
	cQuery += "   AND E2_FORNECE = '"+VVF->VVF_CODFOR+"'"
	cQuery += "   AND E2_LOJA = '"+VVF->VVF_LOJA+"'"
	if VVF->VVF_SITNFI =="0"
		cQuery += " AND D_E_L_E_T_ <> ' '"
	else
		cQuery += " AND D_E_L_E_T_ = ' '"
	endif
	cQuery += " ORDER BY E2_VENCREA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlSE2, .F., .T. )
	While !( cAlSE2 )->( Eof() )
		aAdd(aIteParc,{ stod( ( cAlSE2 )->( E2_VENCREA )), ( cAlSE2 )->( E2_VALOR ) , {} } )
		If len(aParcCust) > 0
			For nCntFor := 1 to len(aParcCust)
				aAdd(aIteParc[len(aIteParc),3],&("( cAlSE2 )->( "+aParcCust[nCntFor,2]+" )"))
			Next
		EndIf
		( cAlSE2 )->( DBSkip() )
	EndDo
	( cAlSE2 )->( dbCloseArea() )
	//
EndIf
set delete on
If Empty(aIteParc)
	aAdd(aIteParc,{ ctod("") , 0 , {} })
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
EndIf

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000VLDENC | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Rotina de validacao da ENCHOICE                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000VLDENC()
//
Local nCntFor
Local aFilAtu    := FWArrFilAtu()
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()
Local lAtualParc  := .f. // Atualiza parcela automaticamente?

// INICIALIZA CODIGO DO FORNECEDOR
If ReadVar() == "M->VVF_CODFOR"
	If !Empty(M->VVF_CLIFOR)
		cCliForA := M->VVF_CLIFOR
	Endif
	If !Empty(M->VVF_CODFOR)
		If cCliForA == "C"
			DBSelectArea("SA1")
			DBSetOrder(1)
			If lVX000Auto
				If !DbSeek(xFilial("SA1")+M->VVF_CODFOR+Alltrim(SA1->A1_LOJA)).and.;
					!DbSeek(xFilial("SA1")+M->VVF_CODFOR)
				ElseIf !DbSeek(xFilial("SA1")+M->VVF_CODFOR)
					Return .f.
				EndIf
			Else
				If M->VVF_CODFOR == SA1->A1_COD .and. DbSeek(xFilial("SA1")+M->VVF_CODFOR+Alltrim(SA1->A1_LOJA))
					M->VVF_LOJA := SA1->A1_LOJA
				ElseIf !DbSeek(xFilial("SA1")+M->VVF_CODFOR)
					Return .f.
				EndIf

			EndIf
		Else
			DBSelectArea("SA2")
			DBSetOrder(1)
			If lVX000Auto
				If !DbSeek(xFilial("SA2")+M->VVF_CODFOR+Alltrim(SA2->A2_LOJA)).and.;
					!DbSeek(xFilial("SA2")+M->VVF_CODFOR)
				ElseIf !DbSeek(xFilial("SA2")+M->VVF_CODFOR)
					Return .f.
				EndIf
			Else
				If M->VVF_CODFOR == SA2->A2_COD .and. DbSeek(xFilial("SA2")+M->VVF_CODFOR+Alltrim(SA2->A2_LOJA))
					M->VVF_LOJA := SA2->A2_LOJA
				ElseIf !DbSeek(xFilial("SA2")+M->VVF_CODFOR)
					Return .f.
				EndIf
			EndIf
		EndIf
		If !Empty(M->VVF_CODFOR) .and. !Empty(M->VVF_LOJA)
			If cCliForA == "C"
				If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					Return .f.
				EndIf
			Else
				If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
					Return .f.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
// INICIALIZA-SE A FUNCAO FISCAL ASSIM QUE O FORNECEDOR EH ESCOLHIDO
If ReadVar() == "M->VVF_LOJA" //.or. lForn
	If Empty(M->VVF_LOJA)
		Return .t.
	EndIf
	If cCliForA == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA1")+M->VVF_CODFOR+M->VVF_LOJA)
			Return .f.
		EndIf
		if Empty(M->VVF_NATURE)
			if !Empty(GetNewPar("MV_NATVEIE",""))
				M->VVF_NATURE := Left( GetNewPar("MV_NATVEIE","") +space(20),TamSX3("VVF_NATURE")[1])
			elseif !Empty(SA1->A1_NATUREZ)
				M->VVF_NATURE := SA1->A1_NATUREZ
			endif
		endif
		If Empty(M->VVF_FORPAG) .and. !Empty(SA1->A1_COND)
			M->VVF_FORPAG := SA1->A1_COND
			lAtualParc := .t.
		EndIf

		IF cPaisLoc $ "ARG|MEX"
			IF VVF->(FieldPos("VVF_PROVEN")) <> 0 .and. EMPTY(m->VVF_PROVEN) .And. cPaisLoc == 'ARG'
				M->VVF_PROVEN := SA1->A1_EST
			ENDIF
			IF EMPTY(m->VVF_SERNFI)
				If M->VVF_TPFATR == "2" // 2= Remito
					M->VVF_SERNFI :=LocXTipSer('SA1','R')
				Else
					M->VVF_SERNFI :=LocXTipSer('SA1',MVNOTAFIS)
				EndIf
			ENDIF
		endif

	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA2")+M->VVF_CODFOR+M->VVF_LOJA)
			Return .f.
		EndIf
		if Empty(M->VVF_NATURE)
			if !Empty(GetNewPar("MV_NATVEIE",""))
				M->VVF_NATURE := Left( GetNewPar("MV_NATVEIE","") +space(20),TamSX3("VVF_NATURE")[1])
			elseif !Empty(SA2->A2_NATUREZ)
				M->VVF_NATURE := SA2->A2_NATUREZ
			endif
		endif
		If Empty(M->VVF_FORPAG) .and. !Empty(SA2->A2_COND)
			M->VVF_FORPAG := SA2->A2_COND
			lAtualParc := .t.
		EndIf

		IF cPaisLoc $ "ARG|MEX"
			if VVF->(FieldPos("VVF_PROVEN")) <> 0 .and. EMPTY(M->VVF_PROVEN)
				M->VVF_PROVEN := SA2->A2_EST
			endif
			IF EMPTY(M->VVF_SERNFI)
				If M->VVF_TPFATR == "2" // 2= Remito
					M->VVF_SERNFI :=LocXTipSer('SA2','R')
				Else
					M->VVF_SERNFI :=LocXTipSer('SA2',MVNOTAFIS)
				EndIf
			ENDIF
		ENDIF

	EndIf
	If !Empty(M->VVF_CODFOR) .and. !Empty(M->VVF_LOJA)
		If cCliForA == "C"
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
		Else
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
		EndIf
	EndIf
	M->VVF_NOMFOR := IIf(cCliForA == "C",SA1->A1_NOME,SA2->A2_NOME)
	If lAtuFiscal // Atualiza Fiscal
		If !MaFisFound('NF')
			If cCliForA == "F" .and. ( cX0OpeMov <> "5" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) == 0 ) )
				MaFisIni(M->VVF_CODFOR,M->VVF_LOJA,'F','N',, MaFisRelImp("VEIXX000",{"VVF","VVG"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos Genéricos*/)
			ElseIf cCliForA == "C" .and. ( cX0OpeMov <> "5" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) == 0 ) )
				MaFisIni(M->VVF_CODFOR,M->VVF_LOJA,'C','B',, MaFisRelImp("VEIXX000",{"VVF","VVG"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos Genéricos*/)
			elseif cX0OpeMov $ "5" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) > 0 ) 	//  Devolucao
				MaFisIni(M->VVF_CODFOR,M->VVF_LOJA,'C','D',, MaFisRelImp("VEIXX000",{"VVF","VVG"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos Genéricos*/)
			EndIf
			// HABILITA DIGITACAO DOS ITENS CASO A ROTINA NAO SEJA AUTOMATICA
			If !lVX000Auto .and. !lImpXml
				oGetDados:Enable()
				oFolder:Enable()
			EndIf
		Else
			MaFisRef("NF_CODCLIFOR","VVG00",M->VVF_CODFOR)
			MaFisRef("NF_LOJA","VVG00",M->VVF_LOJA)
			// CHAMAMOS A FUNCAO FIELDOK CADA VEZ QUE ALGUM
			// CAMPO QUE INTREFIRA NO FISCAL FOR ALTERADO
			if !lVX000Auto
				VX000FIELDOK()
			endif
		EndIf

		if cPaisLoc $ "ARG|MEX"
			MaFisRef('NF_SERIENF',"VVG00",M->VVF_SERNFI)
			If cPaisLoc == 'ARG'
				MaFisRef("NF_UFDEST","VVG00",M->VVF_PROVEN)
				MaFisRef("NF_PROVENT","VVG00",M->VVF_PROVEN)
			EndIf
		EndIf
	EndIf

	FG_Seek("SA6","M->VVF_CODBCO",1,.f.)
	M->VVF_CODAGE := SA6->A6_AGENCIA
	If !lAtualParc // Se nao atualiza a parcela, deve dar return .t.
		Return .t.
	EndIf
EndIf
// QUANDO DIGITAR A FORMA DE PAGAMENTO DEVEMOS ATUALIZAR
//O COMO PAGAR CASO A INTEGRACAO FISCAL EXISTA
If lAtuFiscal .and. ( ReadVar() == "M->VVF_FORPAG" .or. lAtualParc ) // Atualiza Fiscal
	If !MaFisFound('NF')
		If ReadVar() == "M->VVF_FORPAG"
			Return .t.
		EndIf
	Else
		VX000ATUCP()
		If SE4->(FieldPos("E4_MSBLQL")) > 0 .and. SE4->E4_MSBLQL == "1"
			If ReadVar() == "M->VVF_FORPAG"
				HELP(" ",1,"REGBLOQ")
				Return .F.
			Else // lAtualParc
				M->VVF_FORPAG := space(TamSx3("VVF_FORPAG")[1])
			EndIf
		Endif
	EndIf
EndIf
// DEVEMOS VERIFICAR SE JA FOI DADA ENTRADA DA NOTA DIGITADA
If ReadVar() == "M->VVF_NUMNFI" .OR. ReadVar() == "M->VVF_SERNFI" .OR. lVX000Auto  
	If !Empty(M->VVF_NUMNFI) .AND. !Empty(M->VVF_SERNFI)
		If PARxTIPDOC == "1"
			aFil    := {}
			aAdd( aFil , { "  " , STR0015 })  //Compartilhado
			For nCont := 1 to Len(aSM0)
				cFilAnt := aSM0[nCont]
				aFilial := FWArrFilAtu(cEmpAnt,cFilAnt)
				aAdd( aFil , { cFilAnt , aFilial[5] })
			Next
			cFilAnt := cBkpFilAnt
			dbSelectArea("SF1")
			dbSetOrder(1)
			For nCntFor := 1 to Len(aFil)
				If dbSeek(aFil[nCntFor,1] + M->VVF_NUMNFI + M->VVF_SERNFI + M->VVF_CODFOR + M->VVF_LOJA)
					FMX_HELP("VEIX000E05", STR0016) //NF de Entrada ja existe para este fornecedor.","Atencao!
					Return .f.
					Exit
				EndIf
			Next
		ElseIf PARxTIPDOC == "3"
			dbSelectArea("SF1")
			dbSetOrder(1)
			If ! dbSeek(xFilial("SF1") + M->VVF_NUMNFI + M->VVF_SERNFI + M->VVF_CODFOR + M->VVF_LOJA)
				FMX_HELP("VEIX000E06", STR0116 ) // "Nota Fiscal de Entrada não encontrada para este fornecedor."
				Return .f.
			EndIf

			cSQL := "SELECT VVF_TRACPA " +;
				" FROM " + RetSQLName("VVF") + " VVF " +;
				" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
				  " AND VVF.VVF_CODFOR = '" + M->VVF_CODFOR + "'" +;
				  " AND VVF.VVF_LOJA   = '" + M->VVF_LOJA   + "'" +;
				  " AND VVF.VVF_NUMNFI = '" + M->VVF_NUMNFI + "'" +;
				  " AND VVF.VVF_SERNFI = '" + M->VVF_SERNFI + "'" +;
				  " AND VVF.VVF_SITNFI = '1' " +;
				  " AND VVF.D_E_L_E_T_ = ' '"
			cNumTraDig := FM_SQL(cSQL)
			If ! Empty(cNumTraDig)
				FMX_HELP("VEIX000E07", STR0117 + CHR(13) + CHR(10) + RetTitle("VVF_TRACPA") + ": " + cNumTraDig) // "Movimento de entrada já foi criado para a Nota Fiscal de Entrada informada."
				Return .f.
			EndIf
		EndIf
	EndIf
EndIf
//
If ReadVar() == "M->VVF_NUMOP"
	cSQL := "SELECT R_E_C_N_O_ " + ;
		" FROM " + RetSQLName("SD3") + " D3 " + ;
		" WHERE D3.D3_FILIAL = '" + xFilial("SD3") + "' " + ;
		  " AND D3.D3_OP = '" + M->VVF_NUMOP + "'" +;
		  " AND D3.D3_CF LIKE 'PR%'" +; // Movimento de Producao do SIGAPCP
		  " AND D3.D3_ESTORNO = ' '" +; // Movimentos validos 
		  " AND D3.D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) == 0
		FMX_HELP("VEIX000E16", STR0118 + CHR(13) + CHR(10) + RetTitle("VVF_NUMOP") + ": " + M->VVF_NUMOP, STR0119 ) // "Lançamento de Produção não encontrado na tabela de movimentações." // "Verifique se existe um lançamento de produção válido na tabela de movimentação para a ordem de produção informada."
		Return .f.
	EndIf

	cSQL := "SELECT VVF_TRACPA " +;
		" FROM " + RetSQLName("VVF") + " VVF " +;
		" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
			" AND VVF.VVF_NUMOP = '" + M->VVF_NUMOP + "'" +;
			" AND VVF.VVF_SITNFI = '1' " +;
			" AND VVF.D_E_L_E_T_ = ' '"
	cNumTraDig := FM_SQL(cSQL)
	If ! Empty(cNumTraDig)
		FMX_HELP("VEIX000E15", STR0120 + CHR(13) + CHR(10) + RetTitle("VVF_TRACPA") + ": " + cNumTraDig) // "Movimento de entrada já foi criado para a Ordem de Produção informada."
		Return .f.
	EndIf

EndIf

If ReadVar() == "M->VVF_SERNFI"
	If cPaisLoc $ "ARG|MEX"
		MaFisRef('NF_SERIENF',"VVG00",M->VVF_SERNFI)
	EndIf
endif

If ReadVar() == "M->VVF_PROVEN"
	If cPaisLoc == "ARG"
		MaFisRef("NF_UFDEST","VVG00",M->VVF_PROVEN)
		MaFisRef("NF_PROVENT","VVG00",M->VVF_PROVEN)
	EndIf
endif

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | VX000Inc   | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o |  Funcao de Inclusao de Veiculos atraves da Entrada           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000INC(cAlias,nReg,nOpc)
//
Local nCntFor   := 0
Local aSM0      := {}
Local oVeiculos := DMS_Veiculo():New()
Local nRecVV1   := 0
Local nRecSB1   := 0
Local cQuery    := ""
Local cFatDes   := ""
Local lVldSA1   := .f.
Local aCliARG   := {}
Local lVXA001    := FWSX1Util():ExistPergunte("VXA001")
Local lSomaPeso  := .T.
local lSavInclui as logical

// Desconsiderar CHASSI em branco
If Empty(M->VVG_CHASSI)
	Return .f.
EndIf

// Nao deixar alterar quando o Item for AMS - Veiculos SEM CHASSI ( VV1_GRASEV = '6' )
If FM_SQL("SELECT VV1.R_E_C_N_O_ FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI='"+aCols[n,FG_POSVAR("VVG_CHASSI")]+"' AND VV1.VV1_GRASEV='6' AND VV1.D_E_L_E_T_=' '") > 0
	Return .f.
EndIf

// TENTA PROCURAR O CHASSI NO CADASTRO SE ENCONTRAR VERIFICA SE JA NAO ESTA NO
// ESTOQUE CASO CONTRARIO CADASTRA O VEICULO CHAMANDO A FUNCAO DO VEIVA010
lAchou := FG_POSVEI("M->VVG_CHASSI","VV1->VV1_CHASSI")
If !lAchou
	// SE A ROTINA FOR AUTOMATICA NAO EH PERMITIDO CADASTRO DE VEICULOS
	If lVX000Auto
		Return .f.
	EndIf

	cChassi := M->VVG_CHASSI 			// preenchimento da variavel de integracao
	cTmpVarObs := M->VVF_OBSERV
	lRetVA010 := VA0700103_InclusaoNovoChassi(cChassi)
	M->VVF_OBSERV := cTmpVarObs

	If !lRetVA010
		Return .f.
	Else
		M->VVG_CHASSI := VV1->VV1_CHASSI
		aCols[n,FG_POSVAR("VVG_CHASSI")] := M->VVG_CHASSI
	EndIf
Else
	cGruVei := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VV1->VV1_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))

	If VV1->VV1_SITVEI == "8" // veiculo EM PEDIDO
//		If !FM_PILHA("U_IXMLVJD") 
			lSavInclui := INCLUI // Salva o valor original, semelhante a ISSUE DVARMIL-7073
			//VXA010A("VV1",VV1->(RecNo()),3)
			VA0700113_AlteracaoChassi()
			INCLUI := lSavInclui // Restaura o valor original, semelhante a ISSUE DVARMIL-7073
//		EndIf
		If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			Return .f.
		EndIf
		M->VVG_CHASSI := VV1->VV1_CHASSI
	EndIf

	// Chassi Bloqueado
	If oVeiculos:Bloqueado("", M->VVG_CHASSI)
		Return .f. // A mensagem já é exibida dentro da função Bloqueado()
	EndIf
EndIf

cChassi := M->VVG_CHASSI
If VV1->VV1_SITVEI <> "8" // Veiculo nao eh EM PEDIDO
	FGX_AMOVVEI(xFilial("VV1"),cChassi, "VX000INC")
Else // Pedido
	If !lVX000Auto .and. !Empty(VV1->VV1_FILENT) .and. ( VV1->VV1_FILENT <> xFilial("SD1") )
		If !MsgYesNo(STR0098+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0099+": "+VV1->VV1_FILENT+CHR(13)+CHR(10)+;
					STR0100+": "+xFilial("SD1"),STR0017) // O Chassi esta Pedido para outra Filial. Deseja continuar? / Filial do Pedido / Filial Atual  / Atencao
			Return .f.
		EndIf
	EndIf
EndIf

// ##########################################################
// # VERIFICA RESTRICOES DE MOVIMENTACAO PARA VALIDAR       #
// # SE O VEICULO PODE REALIZAR A ENTRADA                   #
// ##########################################################
//
//	SE A ULTIMA MOVIMENTACAO FOR DE ENTRADA NAO PODEMOS REALIZAR NENHUMA OUTRA ENTRADA
If VV1->VV1_ULTMOV == "E" .AND. !(FM_PILHA("VEIXA040")) //VEIXA040 = Agrega/Desagrega
	DBSelectArea("VVF")
	DBSetOrder(1)
	DBSeek(VV1->VV1_FILENT+VV1->VV1_TRACPA)
	Do Case
		Case VVF->VVF_OPEMOV=="0"
			cOpeTxt := STR0018	//COMPRA
		Case VVF->VVF_OPEMOV=="1"
			cOpeTxt := STR0019	//COMPRA//PED.FABRICA
		Case VVF->VVF_OPEMOV=="2"
			cOpeTxt := STR0020	//REMESSA
		Case VVF->VVF_OPEMOV=="3"
			cOpeTxt := STR0021	//TRANSFERENCIA
		Case VVF->VVF_OPEMOV=="4"
			cOpeTxt := STR0022	//CONSIGNACAO
		Case VVF->VVF_OPEMOV=="5"
			cOpeTxt := STR0023	//DEVOLUCAO
		Case VVF->VVF_OPEMOV=="6"
			cOpeTxt := STR0024	//FRETE
		Case VVF->VVF_OPEMOV=="7"
			cOpeTxt := STR0025	//RETORNO DE REMESSA
		Case VVF->VVF_OPEMOV=="8"
			cOpeTxt := STR0026	//RETORNO DE CONSIGNACAO
	EndCase
	//
	cFatDes := STR0030+": " + Alltrim(VVF->VVF_NUMNFI)+"-"+Alltrim(VVF->VVF_SERNFI) // NF
	If cPaisLoc $ "ARG|MEX"
		cFatDes += CHR(13) + CHR(10) +STR0142+": "+Alltrim(VVF->VVF_REMITO)+"-"+Alltrim(VVF->VVF_SERREM) // Remito
	EndIf
	MsgStop(STR0027 + CHR(13) + CHR(10) + CHR(13) + CHR(10)+;
		STR0028+" " + cOpeTxt + "." +;
		CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0029+": " + VVF->VVF_FILIAL +;
		CHR(13) + CHR(10) + cFatDes,STR0017)//Impossivel continuar. # A ultima movimentacao do veiculo foi uma ENTRADA por # Filial # Atencao
	//
	Return .f.
EndIf

If cPaisLoc $ "ARG|MEX" .and. !cX0OpeMov$'578' // 5=Devolucao / 7=Retorno de Remessa / 8=Retorno de Consignacao
	If VV1->VV1_ULTMOV == "S" // Ultima Movimentação foi uma Saida
		cQuery := "SELECT R_E_C_N_O_ AS RECVV0 "
		cQuery += "  FROM "+RetSqlName("VV0")
		cQuery += " WHERE VV0_FILIAL = '"+VV1->VV1_FILSAI+"'"
		cQuery += "   AND VV0_NUMTRA = '"+VV1->VV1_NUMTRA+"'"
		cQuery += "   AND VV0_OPEMOV = '0'" // Saida por Venda
		cQuery += "   AND VV0_SITNFI = '1'" // Valida
		cQuery += "   AND VV0_TPFATR = '2'" // 2=Remito
		cQuery += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQuery) > 0 // Ultima Movimentação: Saida por Venda Valida e ainda não tem Fatura
			FMX_HELP("VX000INC_ERR001",;
				 STR0134,; // A ultima movimentação desse Veículo/Máquina gerou apenas Remito.
				STR0135) // Necessário efetivar a Fatura de Saida do Remito antes de realizar a Entrada do Veículo/Máquina.
			Return .f.
		EndIf
	EndIf
EndIf

// VERIFICA RESTRICOES DA ENTRADA x SAIDA
If !(FM_PILHA("VEIXA006")) .and. !(FM_PILHA("VEIXA007"))  .and. !(FM_PILHA("VEIXA008")) .and. !(FM_PILHA("VEIXA002")) .and. !(FM_PILHA("VEIXA004")) .and. !(FM_PILHA("VEIXA040")) .and. !(FM_PILHA("VEIVM006"))
	DBSelectArea("VV0")
	DBSetOrder(1)
	DBSeek(VV1->VV1_FILSAI+VV1->VV1_NUMTRA)
EndIf
//
DBSelectArea("SA1")
dbSetOrder(1)
if FWModeAccess("SA1",3) == "E"
	SA1->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_CODCLI+VV0->VV0_LOJA))
else
	SA1->(DBSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
endif
//
cOpeTXT := " "
Do Case
	Case VV0->VV0_OPEMOV=="0"
		cOpeTxt := STR0112	//VENDA
	Case VV0->VV0_OPEMOV=="1"
		cOpeTxt := STR0113	//SIMULACAO
	Case VV0->VV0_OPEMOV=="2"
		cOpeTxt := STR0021	//TRANSFERENCIA
	Case VV0->VV0_OPEMOV=="3"
		cOpeTxt := STR0020	//REMESSA
	Case VV0->VV0_OPEMOV=="4"
		cOpeTxt := STR0023	//DEVOLUCAO
	Case VV0->VV0_OPEMOV=="5"
		cOpeTxt := STR0022	//CONSIGNACAO
	Case VV0->VV0_OPEMOV=="6"
		cOpeTxt := STR0025	//RETORNO DE REMESSA
	Case VV0->VV0_OPEMOV=="7"
		cOpeTxt := STR0026	//RETORNO DE CONSIGNACAO
EndCase

// ABAIXO VERIFICAMOS SE TRATA-SE DE UMA MOVIMENTACAO DE SAIDA/ENTRADA
// PARA TRANSFERENCIA, REMESSA OU CONSIGNADO (RESPECTIVAMENTE)
lRemFilial = .f.
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)

If cPaisLoc $ "ARG|MEX"
	aCliARG := FGX_SM0SA1(cFilAnt) // Retorna o Cliente/Loja correspondete ao SM0 posicionado
	lVldSA1 := ( SA1->A1_COD+SA1->A1_LOJA == aCliARG[1]+aCliARG[2] )
Else
	lVldSA1 := ( SA1->A1_CGC == aSM0[18] )
EndIf

If !((VV0->VV0_OPEMOV = "2" .AND. cX0OpeMov == "3") .or.;
	(VV0->VV0_OPEMOV = "3" .AND. cX0OpeMov == "7") .or.;
	(VV0->VV0_OPEMOV = "5" .AND. cX0OpeMov == "8")) .and.;
	!(cX0OpeMov $ "01245")
	if ((cX0OpeMov == "3" .and. VV0->VV0_OPEMOV == "3") .or.;
		(cX0OpeMov == "4" .and. VV0->VV0_OPEMOV == "5") .or.;
		(cX0OpeMov == "7" .and. VV0->VV0_OPEMOV == "6") .or.;
		(cX0OpeMov == "8" .and. VV0->VV0_OPEMOV == "7") ) .and.;
		lVldSA1
		if !(FM_PILHA("VEIXA008"))
			MsgStop(STR0039+" "+STR0040,STR0017) // Entradas por remessa, consignacao ou retornos entre filiais devem # ser realizadas na rotina de remessas entre filiais. # Atencao
			Return .f.
		else
			lRemFilial = .t.
		endif
	endif
	//
	if !lRemFilial
		MsgStop(STR0027 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
		STR0041+" " + cOpeTxt + "." +;
		CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0029 +": " + VV0->VV0_FILIAL +;
		" "+STR0030+":" + Alltrim(VV0->VV0_NUMNFI) + "-" + Alltrim(VV0->VV0_SERNFI),STR0017) //Impossivel continuar.#  ultima movimentacao do veiculo foi uma SAIDA por #  "Filial: " + VV0->VV0_FILIAL # NF # atencao
		//
		Return .f.
	endif
EndIf
//
// VERIFICA SE O CHASSI JA FOI DIGITADO EM UMA LINHA ANTERIOR
//
For nCntFor := 1 to Len(aCols)
	If !aCols[nCntFor,len(aHeader)+1]
		If nCntFor # n .and. aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] == M->VVG_CHASSI
			FMX_HELP("VEIX000E07", STR0042)//Chassi ja digitado.
			M->VVG_CHAINT := ""
			aCols[n,FG_POSVAR("VVG_CHAINT")] := ""
			M->VVG_CODTES := ""
			aCols[n,FG_POSVAR("VVG_CODTES")] := ""
			Return .f.
		EndIf
	EndIf
Next
// #######################################################
// # FIM DAS VERIFICACOES DE RESTRICOES DE MOVIMENTACAO  #
// # PARA VALIDAR SE O VEICULO PODE REALIZAR A ENTRADA   #
// #######################################################
cTipoMov := "X" // TODO: nao tem tes padrao para os retornos
Do Case
	Case cX0OpeMov $ "0178"
		cTipoMov := "N"
	Case cX0OpeMov == "2"
		cTipoMov := "R"
	Case cX0OpeMov == "3"
		cTipoMov := "T"
	Case cX0OpeMov == "4"
		cTipoMov := "C"
EndCase

// SUGERE ALMOXARIFADO
VX000ALMVEI()
//
// PREENCHE OS CAMPOS LIGADOS AO VEICULO
DBSelectArea("VV1")
DBSetOrder(2)
DBSeek(xFilial("VV1")+cChassi)

If FindFunction('FGX_ValidRequiredFieds')
	If !FGX_ValidRequiredFieds(VV1->(Recno()), "VV1", /*lShowMessage*/)
		Return (.F.)
	Endif
Endif

FGX_VV1SB1("CHASSI", cChassi, cUsaGrVA , cGruVei )
If lAtuFiscal // Atualiza Fiscal
	// SETA VARIAVEL FISCAL
	if cPaisLoc == "MEX"   
		MaFisIniLoad(n,{SB1->B1_COD,;
						SF4->F4_CODIGO,;
						"",;
						1 ,;
						"",;
						"",;
						SB1->(RecNo()),;  //IT_RECNOSB1
						SF4->(RecNo()),;  //IT_RECNOSF4
						0})               //IT_RECORI
	EndIF
	MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
	FMX_FISITEMI(n, "VVG00", .F.)
EndIf
//M->VVG_SITTRI := SB1->B1_ORIGEM
//acols[n,FG_POSVAR("VVG_SITTRI")] := SB1->B1_ORIGEM
M->VVG_CHASSI := VV1->VV1_CHASSI
aCols[n,FG_POSVAR("VVG_CHASSI")] := VV1->VV1_CHASSI
M->VVG_CHAINT := VV1->VV1_CHAINT
aCols[n,FG_POSVAR("VVG_CHAINT")] := VV1->VV1_CHAINT
M->VVG_ESTVEI := VV1->VV1_ESTVEI
acols[n,FG_POSVAR("VVG_ESTVEI")] := VV1->VV1_ESTVEI
M->VVG_CODORI := VV1->VV1_CODORI
acols[n,FG_POSVAR("VVG_CODORI")] := VV1->VV1_CODORI
M->VVG_LOCPAD := VV1->VV1_LOCPAD
acols[n,FG_POSVAR("VVG_LOCPAD")] := VV1->VV1_LOCPAD

If VV1->(FieldPos("VV1_CONTA")) > 0
	If !Empty(VV1->VV1_CONTA)
		If FG_POSVAR("VVG_CONTA") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_CONTA")])
			M->VVG_CONTA := acols[n,FG_POSVAR("VVG_CONTA")] := VV1->VV1_CONTA
		EndIf
	EndIf
	If !Empty(VV1->VV1_CC)
		If FG_POSVAR("VVG_CENCUS") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_CENCUS")])
			M->VVG_CENCUS := acols[n,FG_POSVAR("VVG_CENCUS")] := VV1->VV1_CC
		EndIf
	EndIf
	If !Empty(VV1->VV1_ITEMCC)
		If FG_POSVAR("VVG_ITEMCT") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_ITEMCT")])
			M->VVG_ITEMCT := acols[n,FG_POSVAR("VVG_ITEMCT")] := VV1->VV1_ITEMCC
		EndIf
	EndIf
	If !Empty(VV1->VV1_CLVL)
		If FG_POSVAR("VVG_CLVL") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_CLVL")])
			M->VVG_CLVL := acols[n,FG_POSVAR("VVG_CLVL")] := VV1->VV1_CLVL
		EndIf
	EndIf
EndIf

// VERIFICA SE EXISTE AVALIACAO VALIDA E ALTERA PRECO DE COMPRA
if cX0OpeMov == "0" .and. cPaisLoc == "BRA"
	DBSelectArea("VAZ")
	DBSetOrder(1)
	DBSeek(xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")])
	while xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")] == VAZ->VAZ_FILIAL + VAZ->VAZ_CHASSI
		if VAZ->VAZ_APROVA == "1" .or. VAZ->VAZ_APROVA == "2"
			M->VVG_VALUNI := acols[n,FG_POSVAR("VVG_VALUNI")] := VAZ->VAZ_VALCOM
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
			EndIf
		endif
		DBSkip()
	enddo
endif
//
// Totalizar Peso dos Veiculos na cabeça da NF //
//
nRecVV1 := VV1->(RecNo())
nRecSB1 := SB1->(RecNo())

If lVXA001 //Existe o grupo de pergunta
	Pergunte("VXA001", .F.)
	lSomaPeso := MV_PAR01 <> 2 //Parametrização específica se vai somar os pesos ou não.
EndIf

If lSomaPeso

	M->VVF_PLIQUI := 0
	M->VVF_PBRUTO := 0
	for nCntFor := 1 to Len(aCols) // Totalizar variaveis para calculo proporcional
		// pula itens deletados
		if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
			FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
			M->VVF_PLIQUI += SB1->B1_PESO // Atualiza PESO LIQUIDO na tela
			M->VVF_PBRUTO += SB1->B1_PESBRU // Atualiza PESO BRUTO na tela
		EndIf
	Next
	If ValType(oGetE72) == "O" // Existe o Objeto
		oGetE72:Refresh() // M->VVF_PLIQUI -> Necessario para refresh na tela - Peso Liquido
		oGetE73:Refresh() // M->VVF_PBRUTO -> Necessario para refresh na tela - Peso Bruto
	EndIf
EndIf
VV1->(DbGoTo(nRecVV1))
SB1->(DbGoTo(nRecSB1))
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000ALMVEI | Autor | Manoel                | Data | 27/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o |  Oferece AlmoxarIfado do Veiculo                             |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/

Function VX000ALMVEI()
//
Local lTesvazio
//
lTesvazio := Empty(M->VVG_CODTES)
If !lVX000Auto // A ROTINA AUTOMATICA NUNCA DEVE REFERENCIAR OBJETOS VISUAIS
	// PARA AS ENTRADAS EXCETO VDI/FROTISTA:
	If cX0OpeMov $ "02345678"
		// SE FOR VEICULO NOVO E TEM PARAMETRO
		If M->VVG_ESTVEI == "0" .and. Trim(GETMV("MV_LOCVEIN")) <> ""
			// ENTAO USA O PARAMETRO DE VEICULO NOVO
			M->VVG_LOCPAD := GETMV("MV_LOCVEIN")
			// SENAO SE FOR USADO E TEM PARAMETRO
		ElseIf  M->VVG_ESTVEI == "1" .and. Trim(GETMV("MV_LOCVEIU")) <> ""
			// ENTAO USA O PARAMETRO DE VEICULO USADO
			M->VVG_LOCPAD := GETMV("MV_LOCVEIU")
		Else
			// SENAO DEIXA O LOCAL PADRAO EM BRANCO
			M->VVG_LOCPAD := "  "
		EndIf
		// PARA VDI/FROTISTA
	ElseIf cX0OpeMov == "1"
		// SE TEM O PARAMETRO
		If !Empty(GETMV("MV_LOCVEIC"))
			// ENTAO USA O PARAMETRO
			M->VVG_LOCPAD := GETMV("MV_LOCVEIC")
		Else
			// DEIXA O LOCAL PADRAO EM BRANCO
			M->VVG_LOCPAD := "  "
		EndIf
	Else
		// DEIXA O LOCAL PADRAO EM BRANCO
		M->VVG_LOCPAD := "  "
	EndIf
	// ATUALIZA O ACOLS E DA REFRESH NA ACOLS
	aCols[n,FG_POSVAR("VVG_LOCPAD")] := M->VVG_LOCPAD
	oGetDados:oBrowse:Refresh(.t.)
EndIf
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000FIELDOK| Autor |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK do aCols - Atualiza os campos com o fiscal.          |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000FIELDOK()
Local aMovVei := {}
Local lRet    := .t.
Local aArea   := GetArea()
Local cQuery  := ""
Local cTesPE   := ""
//Local cMsgHlp  := ""
//Local cSolHlp  := ""
//
// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
if ReadVar() == "M->VVG_CHASSI"
	//
	DBSelectArea("VV1")
	DBSetOrder(2)
	DbSeek(xFilial("VV1")+M->VVG_CHASSI)
	If VV1->VV1_ULTMOV == "S"  .and. M->VVG_ESTVEI <> "1"
		If MsgYesNo(STR0096,STR0017)
			M->VVG_ESTVEI := "1"
			aCols[n,FG_POSVAR("VVG_ESTVEI")] := M->VVG_ESTVEI
		Endif
	Endif
	If cUsaGrVA == "1" // Usa Veiculos de forma Agrupada por Modelo no SB1
		If !FGX_VV2SB1()
			MsgStop(STR0095,STR0017) //
			lRet := .f.
		Endif
	Endif
	//
	If lRet .and. !lVX000Auto .and. VV1->VV1_ULTMOV == "S" // Ultima Movimentação: Saida
		If FM_PILHA("VEIXA005") // Esta realizando: Entrada por Consignação
			cQuery := "SELECT R_E_C_N_O_ AS RECVV0 "
			cQuery += "  FROM "+RetSqlName("VV0")
			cQuery += " WHERE VV0_FILIAL = '"+VV1->VV1_FILSAI+"'"
			cQuery += "   AND VV0_NUMTRA = '"+VV1->VV1_NUMTRA+"'"
			cQuery += "   AND VV0_OPEMOV = '3'" // Saida por Remessa
			cQuery += "   AND VV0_SITNFI = '1'" // Valida
			cQuery += "   AND D_E_L_E_T_ = ' '"
			If FM_SQL(cQuery) > 0 // Ultima Movimentação: Saida por Remessa Valida
				lRet := MsgYesNo(STR0133,STR0017) // A última movimentação válida deste CHASSI foi uma Saída por Remessa. O próximo processo padrão deveria ser a Entrada Retorno de Remessa. Deseja continuar com este CHASSI na Entrada por Consignação? / Atencao
			EndIf
		EndIf
	EndIf
	If cPaisLoc $ "ARG|MEX" .AND. lRet .AND. cX0OpeMov=='0' .AND. ExistBlock('VXX00TEB')//Ponto de entrada para tratamento da TES
		aRet := ExecBlock("VXX00TEB", .f., .f., { xTpFatR , VVF->VVF_FILIAL , VVF->VVF_TRACPA })
		cTesPE := aRet[1]
	Endif
	//
Elseif ReadVar() == "M->VVG_ESTVEI"
	//
	DBSelectArea("VV1")
	DBSetOrder(2)
	DbSeek(xFilial("VV1")+M->VVG_CHASSI)
	If VV1->VV1_ULTMOV == "S"
		if M->VVG_ESTVEI == "0"
			aMovVei := FGX_VEIMOVS(M->VVG_CHASSI)
			If (aMovVei[1,5] <> "4") .or. (aMovVei[1,5] == "4" .and. VV1->VV1_ESTVEI <> "0") // Não foi uma Devolucao de Compra e o Veículo ja nao era mais NOVO
				//				MsgInfo(STR0094,STR0017)
				//				Return(.f.)
			Endif
		Endif
	Endif
	//
Elseif ReadVar() == "M->VVG_ITPED"
	//
	if  Empty(M->VVG_ITPED)
		Return .t.
	endif
	DBSelectArea("SC7")
	if !DBSeek(xFilial("SC7")+M->VVG_NUMPED+M->VVG_ITPED)
		lRet := .f.
	endif
	if lRet .and. SC7->C7_FORNECE + SC7->C7_LOJA != M->VVF_CODFOR+M->VVF_LOJA
		MsgStop(STR0069+Alltrim(SC7->C7_FORNECE)+"-"+Alltrim(SC7->C7_LOJA)+")",STR0017) // "O fornecedor escolhido é diferente do fornecedor do pedido de compra ("
		lRet := .f.
	endif
	//
	if lRet .and. Empty(M->VVG_CHASSI)
		MsgStop(STR0070,STR0017) // "Preencha o campo CHASSI antes de escolher o item do pedido de compra."
		lRet := .f.
	endif
	//
	If lRet
		DBSelectArea("VV1")
		DBSetOrder(2)
		DbSeek(xFilial("VV1")+M->VVG_CHASSI)
		//
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
		SB1->(DBSetOrder(1))
		if SB1->B1_COD != SC7->C7_PRODUTO
			MsgStop(STR0071,STR0017)   // "O modelo do veículo não corresponde ao modelo do pedido de compra para o item escolhido."
			lRet := .f.
		EndIf
		If lRet
			M->VVG_VALUNI := aCols[n,FG_POSVAR("VVG_VALUNI")] := SC7->C7_PRECO
			M->VVG_VALDES := aCols[n,FG_POSVAR("VVG_VALDES")] := ( SC7->C7_DESC1 + SC7->C7_DESC2 + SC7->C7_DESC3 )
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_DESCONTO","VVG00",M->VVG_VALDES)
			EndIf
		Endif
	Endif
	//
ElseIf ReadVar() == "M->VVG_VALUNI" .and. cX0OpeMov == "0" .and. cPaisLoc == "BRA"
	//
	DBSelectArea("VAZ")
	DBSetOrder(1)
	DBSeek(xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")])
	while xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")] == VAZ->VAZ_FILIAL + VAZ->VAZ_CHASSI
		if (VAZ->VAZ_APROVA == "1" .or. VAZ->VAZ_APROVA == "2") .and. M->VVG_VALUNI != VAZ->VAZ_VALCOM .and. VAZ->VAZ_VALCOM > 0
			M->VVG_VALUNI := VAZ->VAZ_VALCOM
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
			EndIf
			lRet := .f.
			exit
		endif
		DBSkip()
	enddo
	//
ElseIf ReadVar() == "M->VVG_CODIND"
	//
	If !Empty(M->VVG_CODIND)
		DBSelectArea("VVH")
		DBSetOrder(1)
		If DbSeek(xFilial("VVH")+M->VVG_CODIND)
			aCols[n,FG_POSVAR("VVG_DIACAR")] := M->VVG_DIACAR := VVH->VVH_DIACAR
		Else
			lRet := .f.
		EndIf
	EndIf
	//
ElseIf ReadVar() == "M->VVG_CODTES" .and. cPaisLoc $ "ARG|MEX" .and. Type("M->VVG_CODTES") <> Nil .and. ValType(M->VVG_CODTES) == "C"
	lRet := VX0000145_ValidacaoTES(xTpFatR,M->VVG_CODTES)
EndIf
//
If lRet
	//
	If lAtuFiscal .and. MaFisFound("IT",n) // Atualiza Fiscal
		//
		if cX0OpeMov $ "57" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) > 0 )
			DBSelectArea("SD2")
			DBSetOrder(3)
			if !Empty(VV0->VV0_CLIALI) .and. VV0->VV0_CATVEN=="7"
				DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CLIALI+VV0->VV0_LOJALI+SB1->B1_COD)
			else
				DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
			endif
			MaFisAlt("IT_RECORI",SD2->(Recno()),n)
		Endif
		If ReadVar() == "M->VVG_OPER" .and. !Empty(M->VVG_OPER)
			cTESEnt := MaTesInt(1,M->VVG_OPER,M->VVF_CODFOR,M->VVF_LOJA,iif(cCliForA == "C","C","F"),SB1->B1_COD)
			MaFisRef("IT_TES","VVG00",cTESEnt)
		Endif
		M->VVG_CODTES := aCols[n,FG_POSVAR("VVG_CODTES")] := MaFisRet(n,"IT_TES")
		M->VVG_VALUNI := aCols[n,FG_POSVAR("VVG_VALUNI")] := MaFisRet(n,"IT_VALMERC")

		MaFisRef("IT_QUANT","VVG00",1)
		MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)

		M->VVG_TOTSEG := aCols[n,FG_POSVAR("VVG_TOTSEG")] := MaFisRet(n,"IT_SEGURO")
		M->VVG_TOTFRE := aCols[n,FG_POSVAR("VVG_TOTFRE")] := MaFisRet(n,"IT_FRETE")
		M->VVG_DESACE := aCols[n,FG_POSVAR("VVG_DESACE")] := MaFisRet(n,"IT_DESPESA")
		If FG_POSVAR("VVG_II") > 0
			M->VVG_II := aCols[n,FG_POSVAR("VVG_II")] := MaFisRet(n,"IT_VALII")
		EndIf
		If FG_POSVAR("VVG_ALIQII") > 0
			M->VVG_ALIQII := aCols[n,FG_POSVAR("VVG_ALIQII")] := MaFisRet(n,"IT_ALIQII")
		EndIf
		// CAMPOS LOCALIZADOS BRASIL
		If cPaisLoc == "BRA"
			if FG_POSVAR("VVG_VBAIPI") > 0
				M->VVG_VBAIPI := aCols[n,FG_POSVAR("VVG_VBAIPI")] := MaFisRet(n,"IT_BASEIPI")
			endif
			if FG_POSVAR("VVG_ALIIPI") > 0
				M->VVG_ALIIPI := acols[n,FG_POSVAR("VVG_ALIIPI")] := MaFisRet(n,"IT_ALIQIPI")
			endif
			if FG_POSVAR("VVG_VALIPI") > 0
				M->VVG_VALIPI := aCols[n,FG_POSVAR("VVG_VALIPI")] := MaFisRet(n,"IT_VALIPI")
			endif
			if FG_POSVAR("VVG_VBAICM") > 0
				M->VVG_VBAICM := aCols[n,FG_POSVAR("VVG_VBAICM")] := MaFisRet(n,"IT_BASEICM")
			endif
			if FG_POSVAR("VVG_ALIICM") > 0
				M->VVG_ALIICM := aCols[n,FG_POSVAR("VVG_ALIICM")] := MaFisRet(n,"IT_ALIQICM")
			endif
			if FG_POSVAR("VVG_ICMCOM") > 0
				M->VVG_ICMCOM := aCols[n,FG_POSVAR("VVG_ICMCOM")] := MaFisRet(n,"IT_VALICM")
			endif
			if FG_POSVAR("VVG_VBICRT") > 0
				M->VVG_VBICRT := acols[n,FG_POSVAR("VVG_VBICRT")] := MaFisRet(n,"IT_BASESOL")
			endif
			if FG_POSVAR("VVG_ICMRET") > 0
				M->VVG_ICMRET := acols[n,FG_POSVAR("VVG_ICMRET")] := MaFisRet(n,"IT_VALSOL")
			endif
			if FG_POSVAR("VVG_PISENT") > 0
				M->VVG_PISENT := aCols[n,FG_POSVAR("VVG_PISENT")] := ( MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2") )
			endif
			if FG_POSVAR("VVG_COFENT") > 0
				M->VVG_COFENT := aCols[n,FG_POSVAR("VVG_COFENT")] := ( MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2") )
			endif
			If FG_POSVAR("VVG_BASCOF") > 0
				M->VVG_BASCOF := aCols[n, FG_POSVAR("VVG_BASCOF")] := MaFisRet(n, "IT_BASECOF")
			EndIf
			If FG_POSVAR("VVG_ALICOF") > 0
				M->VVG_ALICOF := aCols[n, FG_POSVAR("VVG_ALICOF")] := MaFisRet(n, "IT_ALIQCOF")
			EndIf
			If FG_POSVAR("VVG_VALCOF") > 0
				M->VVG_VALCOF := aCols[n, FG_POSVAR("VVG_VALCOF")] := MaFisRet(n, "IT_VALCOF")
			EndIf
			If FG_POSVAR("VVG_BASPIS") > 0
				M->VVG_BASPIS := aCols[n, FG_POSVAR("VVG_BASPIS")] := MaFisRet(n, "IT_BASEPIS")
			EndIf
			If FG_POSVAR("VVG_ALIPIS") > 0
				M->VVG_ALIPIS := aCols[n, FG_POSVAR("VVG_ALIPIS")] := MaFisRet(n, "IT_ALIQPIS")
			EndIf
			If FG_POSVAR("VVG_VALPIS") > 0
				M->VVG_VALPIS := aCols[n, FG_POSVAR("VVG_VALPIS")] := MaFisRet(n, "IT_VALPIS")
			EndIf
			If FG_POSVAR("VVG_BAIMP5") > 0
				M->VVG_BAIMP5 := aCols[n, FG_POSVAR("VVG_BAIMP5")] := MaFisRet(n, "IT_BASECF2")
			EndIf
			If FG_POSVAR("VVG_ALIMP5") > 0
				M->VVG_ALIMP5 := aCols[n, FG_POSVAR("VVG_ALIMP5")] := MaFisRet(n, "IT_ALIQCF2")
			EndIf
			If FG_POSVAR("VVG_VLIMP5") > 0
				M->VVG_VLIMP5 := aCols[n, FG_POSVAR("VVG_VLIMP5")] := MaFisRet(n, "IT_VALCF2")
			EndIf
			If FG_POSVAR("VVG_BAIMP6") > 0
				M->VVG_BAIMP6 := aCols[n, FG_POSVAR("VVG_BAIMP6")] := MaFisRet(n, "IT_BASEPS2")
			EndIf
			If FG_POSVAR("VVG_ALIMP6") > 0
				M->VVG_ALIMP6 := aCols[n, FG_POSVAR("VVG_ALIMP6")] := MaFisRet(n, "IT_ALIQPS2")
			EndIf
			If FG_POSVAR("VVG_VLIMP6") > 0
				M->VVG_VLIMP6 := aCols[n, FG_POSVAR("VVG_VLIMP6")] := MaFisRet(n, "IT_VALPS2")
			EndIf
			If FG_POSVAR("VVG_CF") > 0
				M->VVG_CF := aCols[n, FG_POSVAR("VVG_CF")] := MaFisRet(n, "IT_CF")
			EndIf
		endif
		//
		// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
		//
		VX000ATUF1("DESPESA")
		VX000ATUF1("FRETE")
		// ATUALIZA COMO PAGAR
		VX000ATUCP()
		//
	EndIf
//
Endif

//Caso a tes tenha sido preenchida pelo pe VXX00TEB (pela digitação do chassi) deve-se disparar o fiscal para atualizacao do campo no acols
If lret .AND. !Empty(cTesPE)
	__ReadVar := "M->VVG_CODTES"
	M->VVG_CODTES := aCols[n,FG_POSVAR("VVG_CODTES")] := cTesPE
	 If lAtuFiscal .and. MaFisFound("IT",n) 
		MaFisRef("IT_TES"    ,"VVG00",M->VVG_CODTES) //Atualizar o fiscal
	Endif
	VX000FIELDOK()
Endif
RestArea( aArea )
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000LINOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verifica se a linha da aCols esta coerente                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000LINOK(xTIPDOC)
Local nCntFor   := 0
Local cCposObr  := ""
Local aRetPE    := {}
Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )

// VERIFICA OS CAMPOS OBRIGATORIOS
// O CAMPO VVG_LOCPAD INDICA O ALMOXARIFADO DE ENTRADA DO VEICULO E NAO PODE NUNCA
// ESTAR VAZIO ESSE CAMPO DEVE SER OBRIGATORIO EM UMA PROXIMA ATUALIZACAO DO ATUSX
//
// pula registros deletados
If aCols[n,len(aHeader)+1]
	Return .t.
EndIf

// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cCposObr := "VVG_CODTES/VVG_LOCPAD/VVG_CODORI/VVG_ESTVEI/"
EndIf
For nCntFor:=1 to Len(aHeader)
	If ( aHeader[nCntFor,2] $ cCposObr .or. X3Obrigat(aHeader[nCntFor,2]) ) .and. Empty(aCols[n,nCntFor])
		Help("VX000LINOK",1,"OBRIGAT2",,RetTitle(aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next
// CASO ESTEJA NA ROTINA AUTOMATICA DEVEMOS CHAMAR O FIELDOK
// UMA VEZ PARA INICIALIZAR AS VARIAVEIS FISCAIS
If lVX000Auto
	VX000FIELDOK()
EndIf
//
if GetNewPar("MV_PCOMVEI","0") == "1"
	cStatus := Posicione("VV1",2,xFilial("VV1")+GDFieldGet("VVG_CHASSI",n),"VV1_ESTVEI")
	If cStatus == "0" .And. cX0OpeMov == "0"
		If Empty(GDFieldGet("VVG_NUMPED",n))
			Aviso(STR0017,STR0072,{"Ok"})//"Veiculo novo. Favor informar numero do pedido de compra!"
			return .f.
		EndIf
	EndIf
endif
//
If ExistBlock('PEV000LOK')
	aRetPE := ExecBlock('PEV000LOK')
	if aRetPE[1]
		if !Empty(aRetPE[2])
			M->VVF_FORPRO := "1"
			M->VVF_SERNFI := "R"
			M->VVF_NUMNFI := aRetPE[2]
		endif
		return .t.
	else
		return .f.
	endif
EndIf

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000TUDOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |                                                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function VX000TUDOK(nOpc,xTIPDOC)
Local nCntFor   := 0
Local nConta    := 0
Local cCposObr  := ""
Local nValorPar := 0
Local nValorDoc := 0
Local oVeiculos := DMS_Veiculo():New()
Local cObrigat2 := ""
Local lMultMoeda := FGX_MULTMOEDA() // Trabalha com MultMoeda ?
Local lCheckVAZ := ( !lVX000Auto .and. cX0OpeMov == "0" .and. cPaisLoc <> "BRA" ) // Somente verificar a diferença no Valor da Avaliação se a Entrada por Compra não for execauto e também não for BRASIL
Local nTotVVF   := 0
Local nTotVAZ   := 0
Local cMsgVAZ   := ""
Local cQVAZ_Ini := ""
Local cQVAZ_Fin := ""

Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )

If FindFunction('FGX_ValidRequiredFieds')
	For nCntFor := 1 To Len(aCols)
		VV1->(DBSetOrder(1))
		If VV1->(DBSeek(xFilial("VV1") + aCols[nCntFor][2])) // Posicionar na VV1 com o CHAINT do aCols
			If !FGX_ValidRequiredFieds(VV1->(Recno()), "VV1", /*lShowMessage*/)
				VA0700113_AlteracaoChassi()
				Return (.F.)
			Endif
		Endif
	Next
Endif

If (cPaisLoc == "ARG" .and. ( xTpFatR == "5" .or. xTpFatR == "3" )).Or.(cPaisLoc == "MEX" .and. xTpFatR == "3") // Remito Entrega Futura // Fatura sobre Remito
	If Empty(M->VVF_NUMNFI)
		cObrigat2 += If(Empty(cObrigat2),"","/") + AllTrim(RetTitle("VVF_REMITO"))
	EndIf
	If Empty(M->VVF_SERNFI)
		cObrigat2 += If(Empty(cObrigat2),"","/") + AllTrim(RetTitle("VVF_SERREM"))
	EndIf
	If !Empty(cObrigat2)
		Help(" ",1,"OBRIGAT2",,cObrigat2,4,1)
		Return .f.
	EndIf
EndIf

If nOpc == 2 .or. nOpc == 5
	Return .t.
EndIf

If xTIPDOC == "2" // 2 = Mov.Interna (SD3)\
	Return .t.
EndIf

If xTIPDOC == "4" // 4 = Movimento de Producao - SIGAPCP
	Return .t.
EndIf

// SE DER OK NA JANELA DIRETO DO ACOLS NAO PASSA PELO LINOK. CHAMA-SE A FUNCAO AQUI
If !lVX000Auto .and. !VX000LINOK(xTIPDOC)
	Return .f.
EndIf

If lCheckVAZ // Checar Valor da Avaliação - somente se não for ExecAuto
	cQVAZ_Ini := "SELECT "
	If lMultMoeda .and. nMoedaCor == 2
		cQVAZ_Ini += " VAZ_VALCO2 "
	Else
		cQVAZ_Ini += " VAZ_VALCOM "
	EndIf
	cQVAZ_Ini += "  FROM "+RetSqlName("VAZ")
	cQVAZ_Ini += " WHERE VAZ_FILIAL = '"+xFilial("VAZ")+"'"
	cQVAZ_Ini += "   AND VAZ_CHASSI = '"
	cQVAZ_Fin := "'  AND VAZ_APROVA IN ('1','2')"
	cQVAZ_Fin += "   AND D_E_L_E_T_ = ' '"
	nTotVVF := MaFisRet(,"NF_TOTAL") // Total da Fatura 
EndIf

// VERIFICA O NRO DE LINHAS DIGITADAS
For nCntFor = 1 to len(aCols)
	If !aCols[nCntFor,len(aCols[nCntFor])]
		If cPaisLoc $ "ARG|MEX" .and. xTpFatR <> "6" // Somente validar o TES se nao for DEVOLUCAO de Fatura sem Entrega (sem Remito de Saida)
			lRet := VX0000145_ValidacaoTES(M->VVF_TPFATR,aCols[nCntFor,FG_POSVAR("VVG_CODTES")])
			If !lRet
				Return .f.
			EndIf
		EndIf
		If lCheckVAZ // Checar Valor da Avaliação - somente se não for ExecAuto
			nTotVAZ += FM_SQL(cQVAZ_Ini+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")]+cQVAZ_Fin)
		EndIf
		nConta++
	EndIf
Next
If nConta == 0
	FMX_HELP("VEIX000E04",STR0043) //Nao existe nenhuma linha valida nos itens da nota fiscal. ## atencao
	Return .f.
EndIf
//
If lCheckVAZ .and. nTotVAZ > 0 // Checar Valor da Avaliação - somente se não for ExecAuto
	If nTotVVF <> nTotVAZ
		cMsgVAZ := STR0169+CHR(13)+CHR(10)+CHR(13)+CHR(10) // O total da Fatura de Entrada não corresponde ao valor da Avaliação do Veículo Usado. Deseja continuar?
		cMsgVAZ += STR0170+Transform(nTotVVF,"@E 999,999,999,999.99")+CHR(13)+CHR(10) // Total da Fatura de Entrada:
		cMsgVAZ += STR0171+Transform(nTotVAZ,"@E 999,999,999,999.99") // Valor Avaliação de Usados:
		If !MsgYesNo(cMsgVAZ,STR0017) // Atenção
			Return .f. // Se usuário não quer passar com divergencia entre o Valor da Avaliação e da Fatura de Entrada
		EndIf
	EndIf
EndIf
//
// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" .and. M->VVF_TPFATR $ "1/3" // 1=NF / 2=SD3 (Mov.Internas) e 1=Fatura / 3=Fatura com Remito
	cCposObr := "VVF_FORPAG/"
EndIf
// VERIFICACOES DOS CAMPOS OBRIGATORIOS DA ENCHOICE
For nCntFor:=1 to Len(acpoEncS)
	If ( acpoEncS[nCntFor] $ cCposObr .or. X3Obrigat(acpoEncS[nCntFor]) ) .and. Empty(&("M->"+acpoEncS[nCntFor]))
		Help(" ",1,"OBRIGAT2",,acpoEncS[nCntFor],4,1)
		Return .f.
	EndIf
Next
//
If M->VVF_FORPRO == "0"
	If Empty(M->VVF_NUMNFI)
		Help(" ",1,"OBRIGAT2",,RetTitle("VVF_NUMNFI"),4,1)
		Return .f.
	EndIf
EndIf
If lAtuFiscal .and. nOpc == 3 // Atualiza Fiscal
	If !MaFisFound('NF')
		VX000RDVFOR()
		If !MaFisFound('NF')
			// TRANSFORMAR EM HELP
			HELP(" ",1,"NVAZIO",,STR0044,4,1)//Favor preencher os dados da nota fiscal.
			Return .f.
		EndIf
	EndIf
	// CARREGA AITEPARC
	If lVX000Auto
		// Ajusta valor do Frete neste ponto, pois quando se trata de ExecAuto,
		//	o frete estava sendo ZERADO no fiscal...
		If M->VVF_TOTFRE > 0
			MaFisRef("NF_FRETE","VVG00",M->VVF_TOTFRE)
		EndIf
		//
		VX000ATUCP()
	EndIf

	If M->VVF_TPFATR $ "1/3" // 1=Fatura / 3=Fatura com Remito

		// VERIFICACOES DE COMO PAGAR
		// Valor das Parcelas
		nValorPar := 0
		For nCntFor := 1 to Len(aIteParc)
			nValorPar += aIteParc[nCntFor,2]
		Next

		// Valor do Documento
		nValorDoc := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()

		// Verificação de valores divergentes
		If nValorPar # nValorDoc .and. !(cX0OpeMov $ "578") .and. !PARxTIPDOC $ "3/4"
			// TRANSFORMAR EM HELP
			HELP(" ",1,"NVAZIO",,STR0045,4,1)//Valor dos titulos diverge do valor da nota fiscal
			Return .f.
		EndIf

	EndIf

EndIf

If M->VVF_TPFATR $ "1/2" // 1=Fatura / 2=Remito
	// Validar Data da Movimentacao de cada Veiculo e verificar ARMAZENS
	For nCntFor := 1 to len(aCols)

		If !aCols[nCntFor,len(aHeader)+1]
			If oVeiculos:DtUltimaMovimentacao(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")]) > M->VVF_DATMOV // Valida referente a Data do Movimento
				FMX_HELP("VX000TUDOK",STR0130 + CRLF + CRLF + aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] ) // Chassi com movimentacao posterior a data deste movimento.
				Return .f.
			EndIf
			DBSelectArea("NNR")
			If !DBSeek(xFilial("NNR") + aCols[nCntFor,FG_POSVAR("VVG_LOCPAD")])
				If !(MsgYesNo(STR0046+" '"+aCols[nCntFor,FG_POSVAR("VVG_LOCPAD")]+"' "+STR0047+CHR(10)+CHR(13)+STR0048+" '"+Alltrim(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])+"' ?"))//O armazem # nao existe no sistema # Deseja cria-lo para o chassi
					Return .f.
				EndIf
			EndIf
			If cCliForA == "F" .and. cX0OpeMov $ "24" // Utilizou Fornecedor -> 2=REMESSA ou 4=CONSIGNACAO
				cQuery := "SELECT F4_PODER3 "
				cQuery += "  FROM "+RetSqlName("SF4")
				cQuery += " WHERE F4_FILIAL = '"+xFilial("SF4")+"'"
				cQuery += "   AND F4_CODIGO = '"+aCols[nCntFor,FG_POSVAR("VVG_CODTES")]+"'"
				cQuery += "   AND D_E_L_E_T_= ' '"
				If FM_SQL(cQuery) == 'R' // TES controla Poder de Rerceiro (F4_PODER3='R')
					FMX_HELP("VX000TUDOK",STR0131 + CRLF + CRLF + STR0132 ) // Impossível realizar o processo de Entrada para Fornecedor utilizando TES com Poder de Terceiro. / Utilize Cliente ou um TES que não controla Poder de Terceiro.
					Return .f.
				EndIf
			EndIf
		EndIf

	Next
EndIf
//
// Ponto de Entrada para validacao
If ( ExistBlock("VX000TOK") )
	lRet := ExecBlock("VX000TOK",.F.,.F.)
	If !lRet
		return .f.
	EndIf
EndIf
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |VX000TSAIR  | Autor | Andre Luis Almeida    | Data | 25/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | SAIR DA JANELA PRINCIPAL VEIXX000                            |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function VX000TSAIR(nOpc,cX0OpeMov)
Local lRet := .t.
// Ponto de Entrada para validacao
If ( ExistBlock("VX000SAI") )
	lRet := ExecBlock("VX000SAI",.F.,.F.,{nOpc,cX0OpeMov})
EndIf
Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000ALTFIN |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Permite alteracao das datas dos titulos                      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000ALTFIN(nCel)
//
Local nOpca := 0
Local nPar1  := 0
Local nSoma1 := nSoma2 := nSoma3 := 0
Local dNovaData := aIteParc[nCel,1]
Local nNovoValor:= aIteParc[nCel,2]
Local valorMax := 0
Local nCntFor
//
//If nCel == Len(aIteParc)
//	Return
//EndIf
//
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VVF_FORPAG)
//
For nCntFor :=1 to Len(aIteParc)
	nSoma1 += aIteParc[nCntFor,2]
Next
//
For nCntFor := 1 to nCel - 1
	valorMax += aIteParc[nCntFor,2]
Next
//
valorMax := nSoma1 - valorMax - (Len(aIteParc)-nCel)
//
If Empty(dNovaData) .and. (nNovoValor = 0)
	Return
EndIf

DEFINE MSDIALOG oDlgFin TITLE STR0010 From 18,43 to 25,76 of oMainWnd //Parcelas

@ 010, 025 SAY STR0014 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE//data
@ 010, 048 MSGET oNovaData  VAR dNovaData  PICTURE "@D" VALID !EMPTY(dNovaData) ;
SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_HBLUE WHEN (Alltrim(SE4->E4_TIPO)=="A")
@ 021, 025 SAY   STR0007 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE //valor
@ 021, 048 MSGET oNovoValor VAR nNovoValor PICTURE "@E 999,999,999.99" ;
VALID (nNovoValor > 0 .AND. nNovoValor<=valorMax )  SIZE 58,08 OF oDlgFin ;
PIXEL COLOR CLR_HBLUE WHEN (nCel # Len(aIteParc).and.Alltrim(SE4->E4_TIPO)=="A")
//

DEFINE SBUTTON FROM 38,60 TYPE 1 ACTION (nOpca := 1,oDlgFin:End()) ENABLE OF oDlgFin
DEFINE SBUTTON FROM 38,95 TYPE 2 ACTION (nOpca := 2,oDlgFin:End()) ENABLE OF oDlgFin
ACTIVATE MSDIALOG oDlgFin CENTER

if nOpca == 1
	aIteParc[nCel,1] := dNovaData
	aIteParc[nCel,2] := nNovoValor
	For nCntFor:=1 to nCel
		nSoma2 := nSoma2 + aIteParc[nCntFor,2]
	Next
	nPar1:= (Len(aIteParc)-nCel)
	nSoma3 := Round( (nSoma1 - nSoma2) / nPar1 ,2)
	nResto := nSoma2
	For nCntFor:=nCel+1 to Len(aIteParc)
		nResto += nSoma3
		aIteParc[nCntFor,2] := nSoma3
	Next
	nResto := nSoma1 - nResto
	If nCel+1 <= Len(aIteParc)
		aIteParc[nCel+1,2] += nResto
	EndIf
	//
	oLbParc:Refresh()
EndIf
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000ATUCP  |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza contas a pagar                                      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000ATUCP()
//
Local nCntFor := 0
Local nValor  := 0
Local aAux    := {}

If cPaisLoc $ "ARG|MEX" .and. M->VVF_TPFATR == "2" // 2=Remito
	Return
EndIf
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VVF_FORPAG)
//
If lAtuFiscal // Atualiza Fiscal
	If lVX000Auto
		If Alltrim(SE4->E4_TIPO) # "A"
			// Verificação de Moeda e Taxa Moeda
			nValor := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
			aAux   := Condicao(nValor, M->VVF_FORPAG,, M->VVF_DATEMI)
			aIteParc := {}
			For nCntFor := 1 to len(aAux)
				aAdd(aIteParc,{aAux[nCntFor,1],aAux[nCntFor,2],{}})
				VX0000041_CarregaDefaultCamposCustomizadosParcelas(len(aIteParc))
			Next
		EndIf
		//
		Return
	EndIf
	If Alltrim(SE4->E4_TIPO) # "A"
		dDataIni := ctod(" ")
		nDias1P := 0
		nParcel := 0
		nInterv := 0

		// Verificação de Moeda e Taxa Moeda
		nValor := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
		aAux   := Condicao(nValor, M->VVF_FORPAG,, M->VVF_DATEMI)
		aIteParc := {}
		For nCntFor := 1 to len(aAux)
			aAdd(aIteParc,{aAux[nCntFor,1],aAux[nCntFor,2],{}})
			VX0000041_CarregaDefaultCamposCustomizadosParcelas(len(aIteParc))
		Next

		oDatIni:disable()
		oDias1P:disable()
		oParcel:disable()
		oInterv:disable()
	Else
		If nDias1P==0 .and. nParcel==0 .and. nInterv==0
			dDataIni := M->VVF_DATEMI
			oDatIni:enable()
			oDias1P:enable()
			oParcel:enable()
			oInterv:enable()
			nParcel := 1
			If Len(aIteParc)<=1
				VX000CALPAR()
			Endif
		Else
			If Len(aIteParc)<=1
				VX000CALPAR()
			Endif
		EndIf
	EndIf
EndIf
If Empty(aIteParc)
	aIteParc := { { ctod("") , 0 , {} } }
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
EndIf

If (FM_PILHA("VEIXA001")) // Somente Entrada de Veiculos por Compra
	If Alltrim(SE4->E4_TIPO) == "A" // Somente quando SE4 for do tipo Negociada
		If ExistBlock("VX000PAR") // chamar PE que possibilita customizar o aIteParc e/ou preencher os campos adicionais customizadaos no aIteParc[x,3]
			aIteParc := ExecBlock("VX000PAR",.f.,.f.,{aIteParc,aParcCust})
		EndIf
	EndIf
EndIf

oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:refresh()
oDatIni:refresh()
oDias1P:refresh()
oParcel:refresh()
oInterv:refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000CALPAR |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Calcula as parcelas do contas a pagar                        |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000CALPAR()
Local nCntFor := 0
Local nValor  := 0
If lAtuFiscal // Atualiza Fiscal
	// Verificação de Moeda e Taxa Moeda
	nValor := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
EndIf
if nValor == 0
	return .t.
endif
//
If Empty(M->VVF_FORPAG)
	MsgInfo(STR0049,STR0017) //A forma de pagamento nao foi preenchida. # Atencao
	Return
EndIf
If (nParcel < 1) .or. (nParcel > nValor)
	MsgInfo(STR0050,STR0017)//Os dados para calculo das percelas nao foram preenchidos corretamente. # Atencao
	Return
EndIf

aIteParc := {}
nValBase := Round(nValor / nParcel ,2)

For nCntFor := 1 to nParcel
	aAdd(aIteParc, {(dDataIni + nDias1P) + ((nCntFor - 1)*nInterv ) , nValBase , {} } )
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(len(aIteParc))
Next
//
nResto := nValor - (nValBase * nParcel)
//
aIteParc[1,2] += nResto
//
oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:refresh()
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000CANPAR |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Cancela contas a pagar                                       |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000CANPAR(nTp)
Default nTp := 0
aIteParc := { { ctod("") , 0 , {} } }
VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
If nTp == 0
	dDataIni := ctod(" ")
	nDias1P := 0
	nParcel := 0
	nInterv := 0
EndIf
oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000GRV    |Autor  |  Luis Delorme         | Data | 20/12/08 |##
##+----------+--------------+-------+---------------------+------+----------+##
##|Descri‡„o | Gravacao da nota fiscal de entrada                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
0#+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
Local lRet          := .f.
Local lExcluiNF     := .t.
Local cQuery        := ""  
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV     := ""
Default cTpFatR     := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura
//
lMsErroAuto := .f.
//
If nOpc == 5
	If cPaisLoc $ "ARG|MEX" .and. !Empty(VVF->VVF_REMITO) // ARGENTINA|MEXICO
		cQuery := "SELECT R_E_C_N_O_ AS RECVV0 "
		cQuery += "  FROM "+RetSqlName("VV0")
		cQuery += " WHERE VV0_FILIAL = '"+VVF->VVF_FILIAL+"'"
		cQuery += "   AND VV0_NUMNFI = '"+VVF->VVF_REMITO+"'"
		cQuery += "   AND VV0_SERNFI = '"+VVF->VVF_SERREM+"'"
		cQuery += "   AND VV0_CODCLI = '"+VVF->VVF_CODFOR+"'"
		cQuery += "   AND VV0_LOJA   = '"+VVF->VVF_LOJA  +"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQuery) > 0 // Verifica se o Nro. do Remito é igual ao Nro. da Fatura de Saida - Isso quer dizer que foi Devolução de Venda com Entrega Futura e não possui Remito de Saida
			lExcluiNF := .f. // Não deve Excluir a NF
		EndIf
	EndIf
	//#############################################################################
	//# CANCELAMENTO DA NOTA FISCAL                                               #
	//#############################################################################
	lRet := VX000CANCEL(cRotOrigem,lExcluiNF)
	If !lRet
		If ! lVX000Auto
			If lMsErroAuto
				MostraErro()
			EndIf
		EndIf
		Return .f.
	EndIf
	// Ponto de Entrada Depois do Cancelamento da Nota Fiscal
	If lRet
		If ExistBlock("VX000DCA")
			ExecBlock("VX000DCA",.f.,.f.,{nOpc,cX0OpeMov})
		EndIf
	EndIf
ElseIf nOpc == 3 .or. nOpc == 4
	//#############################################################################
	//# EMISSAO DA NOTA FISCAL                                                    #
	//#############################################################################
	// SE A ROTINA FISCAL SE PERDEU POR ALGUM MOTIVO O PROCESSO DEVE SER REINICIADO
	If lAtuFiscal .and. !MaFisFound('NF')
		MsgInfo(STR0069,STR0053+": VX000E01")//Ocorreu um erro inesperado # Favor contactar o administrador do sistema. # Codigo
		Return .f.
	EndIf
	// Ponto de Entrada Antes da Gravacao da Nota Fiscal
	If ExistBlock("VX000ANF")
		ExecBlock("VX000ANF",.f.,.f.,{nOpc,cX0OpeMov})
	EndIf
	//
	lRet := VX000EMINF(nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
	If !lRet
		If lMsErroAuto
			MostraErro()
		EndIf
		Return .f.
	EndIf
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	If lRet
		If ExistBlock("VX000DNF")
			ExecBlock("VX000DNF",.f.,.f.,{nOpc,cX0OpeMov})
		EndIf
	EndIf
EndIf
//
If !lVX000Auto
	oDlg:End()
EndIf
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000EMINF  | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Gravacao e Integracao de Veiculos Normais                     |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000EMINF(nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
Local nCntFor, nCntFor2
Local cClasFis     := ""
Local nL

Local cQuery       := ""
Local cVVAFil      := ""
Local cQAlAux      := "SQLAUX"
Local cQAlVAZ      := "SQLVAZ"
Local cQAlVS9      := "SQLVS9"
Local cQAlSE1      := "SQLSE1"
Local cMsgVAZ      := ""
Local c9Parcel     := ""
Local c9TipPag     := ""
Local cNumTit      := ""
Local cDMSPrefOri  := GetNewPar("MV_PREFVEI","VEI")
Local nRecNoVS9    := 0
Local nRecNoVAZ    := 0
Local lBaixarSE1   := .f.
Local aChassiMov   := {}
Local nCntForDel
Local aSB1SD3      := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local cFilVVA      := "("
Local lVV1Comp     := .t.
Local cFilVV1      := xFilial("VV1")
Local cSqlVVA      := "SQLVVA"
Local aVV1         := {}
Local i            := 0
Local lD1_CC       := SD1->(FieldPos("D1_CC")) > 0
Local lVVGCENCUS   := VVG->(FieldPos("VVG_CENCUS")) > 0
Local lD1CONTA     := SD1->(FieldPos("D1_CONTA")) > 0
Local lVVGCONTA    := VVG->(FieldPos("VVG_CONTA")) > 0
Local lD1ITECT     := SD1->(FieldPos("D1_ITEMCTA")) > 0
Local lVVGITECT    := VVG->(FieldPos("VVG_ITEMCT")) > 0
Local lD1CLVL      := SD1->(FieldPos("D1_CLVL")) > 0
Local lVVGCLVL     := VVG->(FieldPos("VVG_CLVL")) > 0
Local lVVGFCICD    := VVG->(FieldPos("VVG_FCICOD")) > 0
Local lD1FCICOD    := SD1->(FieldPos("D1_FCICOD")) > 0
Local lCpoALIQII   := SD1->(FieldPos("D1_ALIQII")) > 0 .And. VVG->(FieldPos("VVG_ALIQII")) > 0
Local lCpoII       := SD1->(FieldPos("D1_II")) > 0 .And. VVG->(FieldPos("VVG_II")) > 0
Local lCpoBASCOF   := SD1->(FieldPos("D1_BASECOF")) > 0 .And. VVG->(FieldPos("VVG_BASCOF")) > 0
Local lCpoALICOF   := SD1->(FieldPos("D1_ALQCOF")) > 0 .And. VVG->(FieldPos("VVG_ALICOF")) > 0
Local lCpoVALCOF   := SD1->(FieldPos("D1_VALCOF")) > 0 .And. VVG->(FieldPos("VVG_VALCOF")) > 0
Local lCpoBASPIS   := SD1->(FieldPos("D1_BASEPIS")) > 0 .And. VVG->(FieldPos("VVG_BASPIS")) > 0
Local lCpoALIPIS   := SD1->(FieldPos("D1_ALQPIS")) > 0 .And. VVG->(FieldPos("VVG_ALIPIS")) > 0
Local lCpoVALPIS   := SD1->(FieldPos("D1_VALPIS")) > 0 .And. VVG->(FieldPos("VVG_VALPIS")) > 0
Local lCpoBAIMP5   := SD1->(FieldPos("D1_BASIMP5")) > 0 .And. VVG->(FieldPos("VVG_BAIMP5")) > 0
Local lCpoALIMP5   := SD1->(FieldPos("D1_ALQIMP5")) > 0 .And. VVG->(FieldPos("VVG_ALIMP5")) > 0
Local lCpoVLIMP5   := SD1->(FieldPos("D1_VALIMP5")) > 0 .And. VVG->(FieldPos("VVG_VLIMP5")) > 0
Local lCpoBAIMP6   := SD1->(FieldPos("D1_BASIMP6")) > 0 .And. VVG->(FieldPos("VVG_BAIMP6")) > 0
Local lCpoALIMP6   := SD1->(FieldPos("D1_ALQIMP6")) > 0 .And. VVG->(FieldPos("VVG_ALIMP6")) > 0
Local lCpoVLIMP6   := SD1->(FieldPos("D1_VALIMP6")) > 0 .And. VVG->(FieldPos("VVG_VLIMP6")) > 0
Local lCpoCF       := SD1->(FieldPos("D1_CF")) > 0 .And. VVG->(FieldPos("VVG_CF")) > 0
//
Local lCpoNFORI    := SD1->(FieldPos("D1_NFORI"))   > 0 .and. VVG->(FieldPos("VVG_NFORI"))  > 0
Local lCpoSERORI   := SD1->(FieldPos("D1_SERIORI")) > 0 .and. VVG->(FieldPos("VVG_SERORI")) > 0
Local lCpoITEORI   := SD1->(FieldPos("D1_ITEMORI")) > 0 .and. VVG->(FieldPos("VVG_ITEORI")) > 0
//
Local lCpoPROVEN   := SD1->(FieldPos("D1_PROVENT")) > 0 .and. VVF->(FieldPos("VVF_PROVEN")) > 0 
//
Local lRet         := .t.
Local nOpcSB1      := 3
Local aVetSB1      := {}
Local oVeiculos    := DMS_Veiculo():New()
//
Local cFilOrig := "" // Filial de Origem ( Filial da Saida )
//
Local lVVD_FILENT := VVD->(FieldPos("VVD_FILENT")) <> 0
//
Local cTpFrete := ""
Local lErro    := .F.
Local nTotDesp := 0
//
Local cSeekSF1 := ""
Local cSeekSD1 := ""
Local aCliARG  := {}
//
Local aNF := {}
Local cNomeFunc := ""
//
Local lCriaSF1 := .t. // Cria SF1/SD1 ?
//
Private aIteNFE    := {}
Private aCabNFE    := {}
Private cDebugMIL  := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
Private cNomeDlg   := ""
Private aCfgNF	   :=	{}

Default xSX5NumNota:= {.t.,"",""}
Default xTIPDOC    := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV    := ""
Default cTpFatR    := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito / 4=Entrega Futura

if cX0OpeMov == "0" // Entrada p/ Compra
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		If lVV1Comp .and. cFilVV1 <> xFilial("VV1") // Verifica se o VV1 nao eh compartilhado
			lVV1Comp := .f.
		EndIf
		cFilVVA += "'"+xFilial("VVA")+"',"
	Next
	cFilAnt := cBkpFilAnt
	cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
Endif
lReturn := VX000Help(M->VVF_FORPRO,M->VVF_ESPECI)
if !lReturn
	Return(.f.)
Endif

If cPaisLoc $ "ARG|MEX" // ARGENTINA
	If cX0OpeMov == "5" .and. xTpFatR == "6" // Devolução de Venda sem Remito de Saida
		lCriaSF1 := .f. // SE NAO FEZ O REMITO DA SAIDA, ENTAO NAO DEVE CRIAR O REMITO DA ENTRADA - SERA GERADO APENAS VVF/VVG PARA COMPATIBILIDADE DO VV1
	EndIf
EndIf

//
// TODAS AS VERIFICACOES JA FORAM REALIZADAS
// AS ROTINAS FISCAIS ESTAO CARREGADAS E DISPONIVEIS
// RESTA AGORA GRAVAR AS TABELAS VVF,VVG,SB1,VV1 e INTEGRAR COM FATURAMENTO
// MATA103 (NFE) e COM FINANCEIRO FINA050
//
For nCntFor := 1 to len(acols)
	n := nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVG_CHASSI")], cRotOrigem + " - " + "VX000EMINF_1")
next
//#######################
//# Gravacao do VVF     #
//#######################
dbSelectArea("VVF")

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	if cPaisLoc == "BRA"
		If M->VVF_FORPRO == "1" //Formulario Proprio = Sim
			If xSX5NumNota[1]
				lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
			Else
				lRet := .t.
				cNumero := xSX5NumNota[2]
				cSerie  := xSX5NumNota[3]
			EndIf
			If !lRet
				Return .f.
			EndIf
			If GetNewPar("MV_TPNRNFS","1") == "3" // SD9
				cNumero := ""
			Endif
		EndIf
	else
		If M->VVF_FORPRO == "1".And.cPaisLoc=='ARG'  //Formulario Proprio = Sim

			If cPaisLoc == "ARG"
				cLocxNFPV := ""
				If FindFunction("OA5300051_Retorna_Ponto_de_Venda")
					Do Case
						Case cX0OpeMov == "7" // Entrada por Retorno de remessa
							cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_ENTRETREMESSA") // Remito
						Case cX0OpeMov == "8" // Entrada por Retorno de remessa
							cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_ENTRETCONSIG") // Remito
					EndCase
				EndIf
				lRet := .t.
				If Empty(cLocxNFPV) .and. lVX000Auto // Via EXECAUTO
					Pergunte("PVXARG",.f.)
					cLocxNFPV := MV_PAR01
				EndIf
				If !Empty(cLocxNFPV)
					cPV410    := cLocxNFPV // Variavel Private utilizada no a468nFatura
					lLocxAuto  := .F.
					cIdPVArg := cIdPV := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
					lRet := F083ExtSFP(cLocxNFPV, .T.)
				Endif
				If !lRet
					Return .F.
				EndIf
			EndIf

			lRet := .t.
			cNomeDlg := "oMainWnd"
			aCfgNF := MontaCfgNf(51, { .f., .f., .f., .f., .f. }, .t.)

			cNomeFunc := FunName()
			SetFunName("MATA462DN")
			aNF := LocXFatAut()
			SetFunName(cNomeFunc)

			If Empty(aNF)
				FMX_HELP("ERRVX000EMINF001",STR0145, STR0146) // "Existe algum problema na configuração do ponto de venda, controle de formulário ou numeração da nota fiscal. Por favor, verifique."###"Configuração de Nota Fiscal"
				Return .F.
			Else
				cNumero := aNF[1]
				cSerie  := Padr(aNF[2],TAMSX3("F1_SERIE")[1])
			Endif
		endif
	endif
EndIf
//#############################################################################
//# INICIO DO CONTROLE DE TRANSACAO                                           #
//#############################################################################
BEGIN TRANSACTION

// QUANDO FOR FORMULARIO PROPRIO IGUAL A SIM E O PARAMETRO MV_TPNRNFS FOR IGUAL A 3 -> EMISSAO DE NOTAS PELO SD9
// O CONTEUDO DA VARIVEL cNumero PODE SER ALTERADO NO MOMENTO DA CHAMADA DO MATA103
dbSelectArea("VVF")
If cTpFatR $ "1/2/4" // 1=Fatura / 2=Remito / 4=Entrega Futura
	If cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
		nRecVVF := VVF->(RecNo())
	Else
		M->VVF_TRACPA := GetSxENum("VVF","VVF_TRACPA")
		ConfirmSx8()
	EndIf
Else
	nRecVVF := VVF->(RecNo())
EndIf

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	If M->VVF_FORPRO == "1" //Formulario Proprio = Sim
		M->VVF_NUMNFI := cNumero
		M->VVF_SERNFI := cSerie
	Else
		cNumero := M->VVF_NUMNFI
		cSerie := M->VVF_SERNFI
	EndIf
	If cTpFatR == "2" // 2=Remito
		M->VVF_REMITO := M->VVF_NUMNFI
		M->VVF_SERREM := M->VVF_SERNFI
		M->VVF_NUMNFI := ""
		M->VVF_SERNFI := ""
		If cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
			M->VVF_NUMNFI := VVF->VVF_NUMNFI
			M->VVF_SERNFI := VVF->VVF_SERNFI
		EndIf
	EndIf
	//
	dbSelectArea("VVF")
	dbSetOrder(6)
	// SE FOI ENCONTRADA NF PARA ESSA TRANSACAO HOUVE UM ERRO
	// Essa validação somente será feita no Brasil pois na argentina o numero do documento quando o formulario é proprio é gerado pelo LOCXNF
	If cPaisLoc == "BRA" .and. VVF->(dbSeek(xFilial("VVF")+cNumero+cSerie + M->VVF_CODFOR + M->VVF_LOJA))
		If VVF->VVF_SITNFI # "0"
			MsgInfo(STR0058,STR0017) //Ja existe nota fiscal com a numeracao escolhida. # atencao
			DisarmTransaction()
			lMSErroAuto := .t.
			lErro := .T.
			break
		EndIf
	EndIf
EndIf
// CALCULA O NUMERO DE VEICULOS DIGITADOS
M->VVF_QTDVEI := 0
For nCntFor = 1 to len(aCols)
	If !aCols[nCntFor,len(aCols[nCntFor])]
		M->VVF_QTDVEI := M->VVF_QTDVEI + 1
	EndIf
Next
lNewVVFVVG := .t.
If cTpFatR == "3" // 3=Fatura com Remito
	lNewVVFVVG := .f.
	VVF->(DbGoTo(nRecVVF))
EndIf
If cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
	lNewVVFVVG := .f.
	VVF->(DbGoTo(nRecVVF))
EndIf
// MONTA OS CAMPOS DO VVF DEPENDENTES DE FISCAL
If lAtuFiscal // Atualiza Fiscal
	DBSelectArea("SX3")
	DBSetOrder(1)
	DBSeek("VVF")
	while SX3->X3_ARQUIVO=="VVF"
		cValid	:= AllTrim(UPPER(SX3->X3_VALID))
		If "MAFISREF"$cValid
			nPosRef := AT('MAFISREF("',cValid) + 10
			if AT('","VX000",',cValid) > 0
				cRefCols:=Substr(cValid,nPosRef,AT('","VX000",',cValid)-nPosRef )
				&("M->"+X3_CAMPO):= MaFisRet(,cRefCols)
			endif
		EndIf
		DbSkip()
	enddo
EndIf

dbSelectArea("VVF")
RecLock("VVF", lNewVVFVVG ) // RECLOCK NA TABELA PARA INCLUIR/ALTERAR REGISTRO

M->VVF_ALIICM := 0

If cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
	// Remito Entrega Futura faz todo o processamento com cTpFatR == "2" // 2=Remito
	// Finalizar o processamento com cTpFatR == "3" // 3=Fatura com Remito
	M->VVF_TPFATR := "3" // 3=Fatura com Remito
EndIf

// GRAVA TODOS OS CAMPOS QUE ESTAO NA MEMORIA
FG_GRAVAR("VVF")
//
If lNewVVFVVG

	VVF->VVF_FILIAL := xFilial("VVF")
	VVF->VVF_SITNFI := "1" // Valida
	VVF->VVF_QTDVEI := M->VVF_QTDVEI
	VVF->VVF_DTHEMI := FGX_DTHEMI() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo GMT
	VVF->VVF_OPEMOV := cX0OpeMov

	If Empty(VVF->VVF_TIPMOV)
		VVF->VVF_TIPMOV := "0" // 0 = Normal
	EndIf

	VVF->VVF_TIPDOC := xTIPDOC // 1=NF / 2=SD3 (Mov.Internas)

EndIf

If lMoeda
	VVF->VVF_MOEDA  := nMoedaCor
	VVF->VVF_TXMOED := nTaxaMoeda
EndIf

// Gravar campos customizáveis da VVF
If Len(aCposUser) > 0
	For nCntFor := 1 to Len(aCposUser)
		If !Empty(aCposUser[nCntFor]) .And. GetSx3Cache(aCposUser[nCntFor], "X3_PROPRI") == "U";
			.And. GetSx3Cache(aCposUser[nCntFor], "X3_CONTEXT") == "R" // Campo customizável real
			&("VVF->" + aCposUser[nCntFor]) := &("M->" + aCposUser[nCntFor])
		EndIf
	Next
EndIf
//
MSMM(VVF->VVF_OBSMEM,TamSx3("VVF_OBSERV")[1],,VVF_OBSERV,1,,,"VVF","VVF_OBSMEM")
MSMM(VVF->VVF_OBSMNF,TamSx3("VVF_OBSENF")[1],,VVF_OBSENF,1,,,"VVF","VVF_OBSMNF")
VVF->(MsUnlock())
//#############################
//# Fim da Gravacao do VVF    #
//#############################
nRecVVF := VVF->(Recno())
nSlv := n			// Salva a variavel n do acols

nCntForDel := 0
For nCntFor = 1 to len(acols)
	// JANELA DE ABORTO
	If VX000ABORT()
		DisarmTransaction()
		RollBackSX8()
		lErro := .T.
		break
	EndIf
	n := nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	nCntForDel ++
	//################################################
	//# Calculo do Custo do Veiculo                  #
	//################################################
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])

	if cX0OpeMov == "0" // Entrada p/ Compra
		aAdd(aVV1,{VV1->(Recno())})
	Endif

	DBSelectArea("VV2")
	DBSetOrder(1)
	DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD)
	DBSelectArea("VVH")
	DBSetOrder(1)
	DbSeek(xFilial("VVH")+VVG->VVG_CODIND)
	DBSelectArea("VVG")
	FG_MEMVAR()

	nCustoVeiculo := 0
	If M->VVG_ESTVEI == "0" //Novo
		If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
			nCustoVeiculo := FGX_FORMULA(VV2->VV2_FORCUS)
 		ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
			nCustoVeiculo := FGX_FORMULA(VE4->VE4_FORCTB)
		EndIf
	Else // Usado
		cFor := GetMv("MV_VUCCTB")
		If !Empty(cFor)
			nCustoVeiculo := FG_FORMULA(cFor)
		EndIf
	EndIf
	If nCustoVeiculo <= 0
		If lAtuFiscal .and. MaFisFound('NF') // Atualiza Fiscal
			nCustoVeiculo := MaFisRet(nCntFor,"IT_TOTAL")
		Else
			nCustoVeiculo := M->VVG_VALUNI
		EndIf
	EndIf

	lGrCodInd := .f.
	if cX0OpeMov $ "24578" // Remessa / Consignado / Devolução / Ret Remessa / Ret Consig
		aMovsRem := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] , "S")
		if Len(aMovsRem) > 0
			DBSelectArea("VVA")
			DBSetOrder(1)
			DBSeek(aMovsRem[1,2]+aMovsRem[1,3]+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
			nCustoVeiculo := VVA->VVA_VCAVEI
			cCodIndRem :=  VVA->VVA_CODIND
			lGrCodInd := .t.
		endif
	Elseif cX0OpeMov == "3" // Tranferencia
		aMovsTrf := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] , "S")
		if Len(aMovsTrf) > 0
			DBSelectArea("VVA")
			DBSetOrder(1)
			DBSeek(aMovsTrf[1,2]+aMovsTrf[1,3]+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
			cCodIndRem :=  VVA->VVA_CODIND
			lGrCodInd := .t.
			cFilOrig := aMovsTrf[1,2] // Filial de Origem - referente a Saida por Transferencia
		endif
	endif
	//################################################################
	//# Gravacao do VVG                                              #
	//################################################################
	DBSelectArea("VV1")
	DBSetOrder(2)
	If !(DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")]))
		DisarmTransaction()
		RollBackSX8()
		MsgInfo(STR0070,STR0053+": VX000E03")//Ocorreu um erro inesperado # Favor contactar o administrador do sistema # Codigo
		lErro := .T.
		break
	EndIf
	If !lNewVVFVVG // // Deve ALTERAR o VVG já criado anteriormente
		DbSelectArea("VVG")
		DbSetOrder(1) // VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
		DbSeek( xFilial("VVG") + VVF->VVF_TRACPA + VV1->VV1_CHAINT )
	EndIf
	dbSelectArea("VVG")
	RecLock("VVG",lNewVVFVVG)
	FG_GRAVAR("VVG",aCols,aHeader,nCntFor)
	If lNewVVFVVG
		VVG->VVG_FILIAL := xFilial("VVG")
		VVG->VVG_TRACPA := VVF->VVF_TRACPA
		VVG->VVG_CHAINT := VV1->VV1_CHAINT
	EndIf
	if !cX0OpeMov $ "03" .or. xTIPDOC == "2" .or. xTIPDOC == "4" // ( Compra e Transferencia ) OU ( Gerar SD3 (Mov.Interna) ) OU Prov. Producao - SIGAPCP
		VVG->VVG_VCNVEI := nCustoVeiculo
	Endif
	if lGrCodInd
		VVG->VVG_CODIND := cCodIndRem
	endif
	//
	If Len(aAutoAux) >= nCntFor
		If lCpoNFORI
			nPos := ascan(aAutoAux[nCntFor],{|x| x[1] == "D1_NFORI" })
			If nPos > 0
				VVG->VVG_NFORI := aAutoAux[nCntFor,nPos,2]
			EndIf
		EndIf
		If lCpoSERORI
			nPos := ascan(aAutoAux[nCntFor],{|x| x[1] == "D1_SERIORI" })
			If nPos > 0
				VVG->VVG_SERORI := aAutoAux[nCntFor,nPos,2]
			EndIf
		EndIf
		If lCpoITEORI
			nPos := ascan(aAutoAux[nCntFor],{|x| x[1] == "D1_ITEMORI" })
			If nPos > 0
				VVG->VVG_ITEORI := aAutoAux[nCntFor,nPos,2]
			EndIf
		EndIf
	EndIf
	//
	VVG->(MsUnlock())
	lLivreDebito := .f.
	if cX0OpeMov == "0" // compra
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica baixa do veículo dado como entrada em atendimentos  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If VS9->(FieldPos("VS9_PARCEL"))>0

			If VV1->VV1_CHASSI == aCols[nCntFor,FG_POSVAR("VVG_CHASSI")]
				cMsgVAZ := ""
				lBaixarSE1 := .f.
				////////////////////////////////////////////////////
				// Utilizar somente a ultima AVALIACAO do Veiculo //
				////////////////////////////////////////////////////
				cQuery := "SELECT VAZ.R_E_C_N_O_ VAZRECNO , VAZ.VAZ_CODIGO , VAZ.VAZ_TIPAVA , VAZ.VAZ_APROVA FROM "+RetSqlName("VAZ")+" VAZ WHERE "
				cQuery += "VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CHASSI='"+VV1->VV1_CHASSI+"' AND VAZ.D_E_L_E_T_=' '"
				cQuery += "ORDER BY VAZ.VAZ_REVISA DESC"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
				If !( cQAlVAZ )->( Eof() )
					If ( cQAlVAZ )->( VAZ_APROVA ) == "0" // Avaliacao nao Aprovada
						cMsgVAZ := STR0073+VV1->VV1_CHASSI+". "+ STR0074// "Existe avaliação não aprovada para o chassi " "Impossivel continuar."
					Else
						If ( cQAlVAZ )->( VAZ_TIPAVA ) == "1" // Troca
							///////////////////////////
							// Verificar Atendimento //
							///////////////////////////
							cQuery := "SELECT VV9.VV9_STATUS , VV9.VV9_NUMATE , VV0.VV0_NUMNFI , VS9.R_E_C_N_O_ VS9RECNO , VS9.VS9_PARCEL , VS9.VS9_DATBAI , VS9.VS9_TIPPAG FROM "+RetSqlName("VS9")+" VS9 "
							cQuery += "INNER JOIN "+RetSQLName("VV0")+" VV0 ON 	( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA=VS9.VS9_NUMIDE AND VV0.D_E_L_E_T_=' ' ) "
							cQuery += "INNER JOIN "+RetSQLName("VV9")+" VV9 ON 	( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
							cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_TIPOPE='V' AND VS9.VS9_REFPAG='"+( cQAlVAZ )->( VAZ_CODIGO )+"' AND VS9.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS9, .F., .T. )
							If !( cQAlVS9 )->( Eof() )
								////////////////////////////////////////////////////////////////
								// Verificar se o Atendimento esta 'Aprovado' ou 'Finalizado' //
								////////////////////////////////////////////////////////////////
								If !( ( cQAlVS9 )->( VV9_STATUS ) $ "L/F" ) .and. GetNewPar("MV_BLQVEIU","S") == "S"
									cMsgVAZ := STR0075+( cQAlVS9 )->( VV9_NUMATE )+STR0076+VV1->VV1_CHASSI+"."+STR0074
								Else

									/////////////////////////////////////////////////////////////////////
									// Baixar automaticamente o Titulo correspondente ao Veiculo Usado //
									/////////////////////////////////////////////////////////////////////
									If Empty(( cQAlVS9 )->( VS9_DATBAI )) .and. GetNewPar("MV_BCRVEIU","S") == "S"
										cNumTit := "V"+Right(( cQAlVS9 )->( VV9_NUMATE ),TamSx3("E1_NUM")[1]-1)
										If GetNewPar("MV_TITATEN","0") == "0" // Gera Titulo na Finalizacao
											If !Empty(( cQAlVS9 )->( VV0_NUMNFI ))
												cNumTit := ( cQAlVS9 )->( VV0_NUMNFI )
											EndIf
										EndIf
										c9Parcel   := ( cQAlVS9 )->( VS9_PARCEL )
										c9TipPag   := ( cQAlVS9 )->( VS9_TIPPAG )
										lBaixarSE1 := .t.
									EndIf
								EndIf
							Else
								cMsgVAZ := STR0077+VV1->VV1_CHASSI+STR0074
							EndIf
							nRecNoVS9  := ( cQAlVS9 )->( VS9RECNO )
							nRecNoVAZ  := ( cQAlVAZ )->( VAZRECNO )
							( cQAlVS9 )->( dbCloseArea() )
						EndIf
					EndIf
				EndIf
				( cQAlVAZ )->( dbCloseArea() )
				DbSelectArea("VAZ")
				If !Empty(cMsgVAZ)
					MsgStop(cMsgVAZ,STR0017)
					DisarmTransaction()
					RollBackSX8()
					lErro := .T.
					break
				EndIf
				If cPaisLoc == "BRA" .and. lBaixarSE1
					//
					DBSelectArea("SF4")
					DBSetOrder(1)
					DBSeek(xFilial("SF4")+aCols[nCntFor,FG_POSVAR("VVG_CODTES")])
					if Alltrim(SF4->F4_DUPLIC) == "S"
						MsgStop(STR0078,STR0017) // "Para compra de veiculos envolvidos em troca utilize um T.E.S. que não gere titulos. Impossivel continuar."
						DisarmTransaction()
						RollBackSX8()
						lErro := .T.
						break
					Endif
					//
					lLivreDebito := .t.
					//
					///////////////////////////////////////////////////////////////////
					// Baixar Titulo no SE1 - Titulo correspondente ao Veiculo Usado //
					///////////////////////////////////////////////////////////////////
					cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM " + RetSQLName("SE1") + " SE1 WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "' AND SE1.E1_NUM='"+cNumTit+"' AND SE1.E1_PREFORI='"+cDMSPrefOri+"' AND "
					cQuery += "SE1.E1_PARCELA='"+Alltrim(c9Parcel)+"' AND SE1.E1_TIPO='"+Alltrim(c9TipPag)+"' AND SE1.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSE1, .F., .T. )
					While !( cQAlSE1 )->(Eof())
						DbSelectArea("SE1")
						DbGoTo(( cQAlSE1 )->RECSE1)
						aBaixa  := {{"E1_PREFIXO" ,E1_PREFIXO         ,Nil } ,;
						{"E1_NUM"	   ,E1_NUM             ,Nil } ,;
						{"E1_PARCELA"  ,E1_PARCELA         ,Nil } ,;
						{"E1_TIPO"	   ,E1_TIPO            ,Nil } ,;
						{"AUTMOTBX"	   ,"NOR"              ,Nil } ,;
						{"AUTDTBAIXA"  ,dDataBase          ,Nil } ,;
						{"AUTDTCREDITO",dDataBase          ,Nil } ,;
						{"AUTHIST"	  ,"BAIXA VEIC USADO"  ,Nil } ,;
						{"AUTVALREC"   ,SE1->E1_VALOR      ,Nil }}
						MSExecAuto({|x| FINA070(x)},aBaixa)
						If lMsErroAuto .or. cDebugMIL == "VEIXX000BX"
							( cQAlSE1 )->( dbCloseArea() )
							DbSelectArea("SE1")
							DisarmTransaction()
							RollBackSX8()
							MostraErro()
							lErro := .T.
							break
						EndIf
						( cQAlSE1 )->(dbSkip())
					EndDo
					( cQAlSE1 )->( dbCloseArea() )
					//////////////////////////
					// Atualiza arquivo VS9 //
					//////////////////////////
					DbSelectArea("VS9")
					DbGoto(nRecNoVS9)
					RecLock("VS9",.f.)
					VS9->VS9_DATBAI := ddatabase
					MsUnLock()
					//
				endif
				If nRecNoVAZ <> 0
					//////////////////////////
					// Atualiza arquivo VAZ //
					//////////////////////////
					DbSelectArea("VAZ")
					DbGoto(nRecNoVAZ)
					RecLock("VAZ",.f.)
					VAZ->VAZ_TRACPA := VVF->VVF_TRACPA
					VAZ->VAZ_FILENT := VVF->VVF_FILIAL
					MsUnLock()
					//
				EndIf
				DbSelectArea("SE1")
			endif
		endif
	EndIf
	//
	// Monta e verifica localização
	//
	//cLocaliz := left(GetNewPar("MV_RECVEIC","RECEPCAO VEIC")+space(TamSX3("D3_LOCALIZ")[1]),TamSX3("D3_LOCALIZ")[1])
	if GetNewPar("MV_LOCVZL","N")=="S" .and. !Empty(VVG->VVG_LOCPAD) .and. !Empty(VVG->VVG_LOCALIZ)  // USA LOCALIZACAO DE VEICULOS
		cLocaliz := VVG->VVG_LOCALIZ
		DBSelectArea("VZL")
		DBSetOrder(1)
		if DBSeek(xFilial("VZL")+VVG->VVG_LOCPAD+VVG->VVG_LOCALIZ)
			if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
				msunlock()
			else
				DisarmTransaction()
				RollBackSX8()
				MsgInfo(STR0079+Alltrim(VVG->VVG_LOCPAD)+"/"+Alltrim(VVG->VVG_LOCALIZ)+STR0080,STR0017)
				lErro := .T.
				break
			endif
		endif
	endif
	//
	SF4->(DbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+VVG->VVG_CODTES))
	//################################################################
	//# Gravacao do VV1                                              #
	//################################################################
	If cX0OpeMov $ "0135" // COMPRAS, TRANSFERENCIA e DEVOLUCAO 
		// Le SA1 e posiciona no codigo da propria concessionaria
		// O SA1 ficara, entao, posicionado no cliente que
		// representa a propria concessionaria
		DBSelectArea("SA1")
		lAchouSA1 := .F.
		aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
		cTexto = aSM0[18]
		nAt = At("-",cTexto)
		while nAt != 0
			cTexto := Subs(cTexto,1,nAt-1) + Subs(cTexto,nAt+1)
			nAt = At("-",cTexto)
		enddo
		nAt = At(".",cTexto)
		while nAt != 0
			cTexto := Subs(cTexto,1,nAt-1) + Subs(cTexto,nAt+1)
			nAt = At(".",cTexto)
		enddo
		If cPaisLoc $ "ARG|MEX"
			aCliARG := FGX_SM0SA1(cFilAnt) // Retorna o Cliente/Loja correspondete ao SM0 posicionado
			SA1->(dbSetOrder(1))
			lAchouSA1 := SA1->(dbSeek(xFilial("SA1")+aCliARG[1]+aCliARG[2]))
		Else
			SA1->(dbSetOrder(3))
			lAchouSA1 := SA1->(dbSeek(xFilial("SA1")+cTexto))
		EndIf
		If !lAchouSA1
			FMX_HELP("VEIX000E02",STR0081+" ["+aSM0[18]+"] "+STR0082+" "+STR0083)//A empresa com CNPJ nro ## nao esta cadastrada ## corretamente no cadastro de clientes. CNPJ nao encontrado
			DisarmTransaction()
			RollBackSX8()
			lErro := .T.
			break
		EndIf
	ElseIf cX0OpeMov $ "24" // REMESSA e CONSIGNADO
		// NESSE CASO O CLIENTE JA ESTA POSICIONADO NO PREENCHIMENTO DA NF.
		// ELE EH O PROPRIETARIO DO VEICULO
		DBSelectArea("SA1")
		dbSetOrder(1)
		DBSeek(xFilial("SA1")+M->VVF_CODFOR+M->VVF_LOJA)
		lAchouSA1 := .t.
	EndIf
	//
	If cTpFatR $ "1/2/4" // 1=Fatura / 2=Remito / 4=Entrega Futura
		VX0000053_AtualizaVV1()
	EndIf

	//#############################################################################
	//# Gravacao do SB1                                                           #
	//#############################################################################
	If GetNewPar("MV_MIL0003","1") == "1"
		nOpcSB1 := 3 // Incluir
		dbSelectArea("SB1")
		cAuxCodSB1 := ""
		If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			nOpcSB1 := 4 // Alterar
			cAuxCodSB1 := SB1->B1_COD
		endif
		aVetSB1 := {}
		aAdd(aVetSB1,{"B1_LOCPAD"  ,VVG->VVG_LOCPAD })
		If nOpcSB1 == 3 .OR. (nOpcSB1 == 4 .AND. Alltrim(SB1->B1_TE) == '')
			aAdd(aVetSB1,{"B1_TE"      ,VVG->VVG_CODTES })
		Endif
		If cPaisLoc == "BRA"
			aAdd(aVetSB1,{"B1_IPI"     ,VVG->VVG_ALIIPI })
		Endif	
		If VV1->(FieldPos("VV1_CONTA")) > 0
			If !Empty(VV1->VV1_CONTA)
				aAdd(aVetSB1,{"B1_CONTA"   ,VV1->VV1_CONTA  })
			EndIf
			If !Empty(VV1->VV1_CC)
				aAdd(aVetSB1,{"B1_CC"      ,VV1->VV1_CC     })
			EndIf
			If !Empty(VV1->VV1_ITEMCC)
				aAdd(aVetSB1,{"B1_ITEMCC"  ,VV1->VV1_ITEMCC })
			EndIf
			If !Empty(VV1->VV1_CLVL)
				aAdd(aVetSB1,{"B1_CLVL"    ,VV1->VV1_CLVL   })
			EndIf
		Else
			If !Empty(VVG->VVG_CONTA)
				aAdd(aVetSB1,{"B1_CONTA"   ,VVG->VVG_CONTA  })
			EndIf
			If !Empty(VVG->VVG_CENCUS)
				aAdd(aVetSB1,{"B1_CC"      ,VVG->VVG_CENCUS })
			EndIf
			If !Empty(VVG->VVG_ITEMCT)
				aAdd(aVetSB1,{"B1_ITEMCC"  ,VVG->VVG_ITEMCT })
			EndIf
			If !Empty(VVG->VVG_CLVL)
				aAdd(aVetSB1,{"B1_CLVL"    ,VVG->VVG_CLVL   })
			EndIf
		EndIf
		aAdd(aVetSB1,{"B1_PRV1"            ,VV1->VV1_SUGVDA })
		If !Empty(VV1->VV1_GRTRIB)
			aAdd(aVetSB1,{"B1_GRTRIB"      ,VV1->VV1_GRTRIB })
		EndIf
		If !Empty(VVG->VVG_SITTRI)
			aAdd(aVetSB1,{"B1_ORIGEM"      ,left(VVG->VVG_SITTRI,TamSX3("B1_ORIGEM")[1]) })
		Endif

		// Grupo TI
		If VV1->(FieldPos("VV1_GRPTI")) > 0 .and. SB1->(FieldPos("B1_GRPTI")) > 0
			aAdd(aVetSB1,{"B1_GRPTI"       ,VV1->VV1_GRPTI })
		EndIf
		//
		DbSelectArea("VV1")
		RegToMemory("VV1",.f.) // Cria variaveis de Memoria que podem ser utilizadas no PE VA010AB1
		//
		lRet := oVeiculos:CriaPeca(VV1->VV1_CHAINT,nOpcSB1,aVetSB1,"VA010AB1",cAuxCodSB1) // Inclui/Altera SB1 do Veiculo
		If !lRet
			DisarmTransaction()
			RollBackSX8()
			MostraErro()
			lErro := .T.
			break
		Endif
		//
	EndIf
	//
	dbSelectArea("SB1")
	dbSetOrder(1)
	If cUsaGrVA == "1" .or. cDebugMIL == "VEIXX000VV2" // Usa Veiculos de forma Agrupada por Modelo no SB1
		If ! FGX_VV2SB1() .or. cDebugMIL == "VEIXX000VV2"
			FMX_HELP("VEIX000E03",STR0121 + "(SB1)") // "Produto referente ao modelo de veículo não encontrado no cadastro de produtos."
			DisarmTransaction()
			RollBackSX8()
			lErro := .T.
			break
		EndIf
	EndIf
	//
	if cX0OpeMov $ "57" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) > 0 ) // Devolução // Retorno de Remessa
		DBSelectArea("SD2")
		DBSetOrder(3)
		if !Empty(VV0->VV0_CLIALI) .and. VV0->VV0_CATVEN=="7"
			DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CLIALI+VV0->VV0_LOJALI+SB1->B1_COD)
		else
			DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
		endif
		If lAtuFiscal // Atualiza Fiscal
			MaFisAlt("IT_RECORI",SD2->(Recno()),nCntFor)
		EndIf
		If VVF->(ColumnPos("VVF_TPFRET")) == 0
			DBSelectArea("SF2")
			DBSetOrder(1)
			If DBSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
				cTpFrete := SF2->F2_TPFRETE // Se Devolução, utilizar o mesmo Tipo de Frete da Saida
			EndIf
		EndIf
	Endif
	//
	cClasFis := VVG->VVG_SITTRI
	If Empty(Right(VVG->VVG_SITTRI,2))
	//	cClasFis := SB1->B1_ORIGEM+SF4->F4_SITTRIB
		cClasFis := ""
	Endif
	//
	aTemp := {}

	If xTIPDOC == "1" .and. lCriaSF1 // 1=NF / 2=SD3 (Mov.Internas)

		// O número da nota fiscal para formulario proprio é atribuido automaticamente no execauto somente para o Brasil.
		// Na argentina o numero foi adquirido e está nas variáveis cNumero e cSerie e nesse ponto já está gravado na tabela VVF.
		if cPaisLoc $ "ARG|MEX" .or. VVF->VVF_FORPRO == "0"  
			If  !(cPaisLoc $ "ARG|MEX") .or. ;
				(cPaisLoc == 'ARG' .and. cTpFatR $ "1/3/4") .or. ; // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
				(cPaisLoc == 'MEX' .and. cTpFatR $ "1/3") // 1=Fatura / 3=Fatura com Remito
				aAdd(aTemp,{"D1_DOC"     ,VVF->VVF_NUMNFI						,Nil})
				aAdd(aTemp,{"D1_SERIE"   ,VVF->VVF_SERNFI						,Nil})
			Else // cTpFatR == "2" // 2=Remito
				aAdd(aTemp,{"D1_DOC"     ,VVF->VVF_REMITO						,Nil})
				aAdd(aTemp,{"D1_SERIE"   ,VVF->VVF_SERREM						,Nil})
			EndIf
		else
			aAdd(aTemp,{"D1_SERIE"	,VVF->VVF_SERNFI						,Nil})
		endif

		aAdd(aTemp,{"D1_ITEM"    ,strzero(nCntForDel,TamSX3("D1_ITEM")[1])	,Nil})
		aAdd(aTemp,{"D1_COD"     ,SB1->B1_COD             					,Nil})
		aAdd(aTemp,{"D1_UM"      ,SB1->B1_UM             					,Nil})
		aAdd(aTemp,{"D1_QUANT"   ,1											,Nil})
		aAdd(aTemp,{"D1_VUNIT"   ,MaFisRet(nCntFor,"IT_VALMERC")			,Nil})
		aAdd(aTemp,{"D1_TOTAL"   ,MaFisRet(nCntFor,"IT_VALMERC")			,Nil})
		aAdd(aTemp,{"D1_EMISSAO" ,VVF->VVF_DATEMI							,Nil})
		aAdd(aTemp,{"D1_TES"     ,MaFisRet(nCntFor,"IT_TES")				,Nil})
		aAdd(aTemp,{"D1_VALFRE"  ,MaFisRet(nCntFor,"IT_FRETE")				,Nil})
		aAdd(aTemp,{"D1_PESO"    ,SB1->B1_PESBRU							,Nil})
		aAdd(aTemp,{"D1_RATEIO"  ,'2'                      					,Nil})
		aAdd(aTemp,{"D1_VALIPI"  ,MaFisRet(nCntFor,"IT_VALIPI")				,Nil})
		aAdd(aTemp,{"D1_IPI"     ,MaFisRet(nCntFor,"IT_ALIQIPI")			,Nil})
		aAdd(aTemp,{"D1_BASEIPI" ,MaFisRet(nCntFor,"IT_BASEIPI")			,Nil})
		aAdd(aTemp,{"D1_PICM"    ,MaFisRet(nCntFor,"IT_ALIQICM")			,Nil})
		aAdd(aTemp,{"D1_VALICM"  ,MaFisRet(nCntFor,"IT_VALICM")				,Nil})
		aAdd(aTemp,{"D1_BRICMS"  ,MaFisRet(nCntFor,"IT_BASESOL")			,Nil})
		aAdd(aTemp,{"D1_ICMSRET" ,MaFisRet(nCntFor,"IT_VALSOL") 			,Nil})
		aAdd(aTemp,{"D1_BASEICM" ,MaFisRet(nCntFor,"IT_BASEICM")			,Nil})
		aAdd(aTemp,{"D1_VALICM"  ,MaFisRet(nCntFor,"IT_VALICM")				,Nil})
		aAdd(aTemp,{"D1_VALDESC" ,MaFisRet(nCntFor,"IT_DESCONTO")			,Nil})
		aAdd(aTemp,{"D1_LOCAL"   ,VVG->VVG_LOCPAD          					,Nil})
		if !cX0OpeMov $ "03" // Compra e Transferencia
			aAdd(aTemp,{"D1_CUSTO"   ,nCustoVeiculo            				,Nil})
		Endif
		if ! empty(cClasFis)
			aAdd(aTemp,{"D1_CLASFIS" ,cClasFis	            					,Nil})
		endif
		aAdd(aTemp,{"D1_CHASSI" ,VV1->VV1_CHASSI           					,Nil})
		aAdd(aTemp,{"D1_PLACA"  ,VV1->VV1_PLAVEI           					,Nil})

		if lD1_CC .and. lVVGCENCUS .and. !Empty(VVG->VVG_CENCUS)
			aAdd(aTemp,{"D1_CC"  ,VVG->VVG_CENCUS          					,Nil})
		Endif
		if lD1CONTA .and. lVVGCONTA .and. !Empty(VVG->VVG_CONTA)
			aAdd(aTemp,{"D1_CONTA"  ,VVG->VVG_CONTA        					,Nil})
		Endif
		if lD1ITECT .and. lVVGITECT .and. !Empty(VVG->VVG_ITEMCT)
			aAdd(aTemp,{"D1_ITEMCTA"  ,VVG->VVG_ITEMCT     					,Nil})
		Endif
		if lD1CLVL .and. lVVGCLVL .and. !Empty(VVG->VVG_CLVL)
			aAdd(aTemp,{"D1_CLVL"  ,VVG->VVG_CLVL       					,Nil})
		Endif
		
		if lD1FCICOD .and. lVVGFCICD .and. !Empty(VVG->VVG_FCICOD)
			aAdd(aTemp,{"D1_FCICOD"  ,VVG->VVG_FCICOD     					,Nil})
		Endif

		If nOpc == 3 .and. cX0OpeMov == "5" // Somente INCLUIR e devolucao de Venda
			aAdd(aTemp,{"D1_DESPESA",0										,Nil}) // Zerar DESPESA, pois a Saida por Venda não utiliza o Valor da Despesa para calculo TOTAL do SF2.
		EndIf

		// Origem: NF / Serie / Item
		If lCpoNFORI .and. !Empty(VVG->VVG_NFORI)
			aAdd(aTemp,{"D1_NFORI",VVG->VVG_NFORI       					,Nil})
		Endif		
		If lCpoSERORI .and. !Empty(VVG->VVG_SERORI)
			aAdd(aTemp,{"D1_SERIORI",VVG->VVG_SERORI     					,Nil})
		Endif
		If lCpoITEORI .and. !Empty(VVG->VVG_ITEORI)
			aAdd(aTemp,{"D1_ITEMORI",VVG->VVG_ITEORI     					,Nil})
		Endif

		// Valor Importação
		If lCpoALIQII .And. !Empty(VVG->VVG_ALIQII)
			aAdd(aTemp,{"D1_ALIQII"  ,MaFisRet(nCntFor,"IT_ALIQII")			,Nil})
		EndIf
		If lCpoII .And. !Empty(VVG->VVG_II)
			aAdd(aTemp,{"D1_II"      ,MaFisRet(nCntFor,"IT_VALII")			,Nil})
		EndIf

		If (cPaisLoc == "BRA")
			// Cofins
			If lCpoBASCOF .And. !Empty(VVG->VVG_BASCOF)
				aAdd(aTemp,{"D1_BASECOF"  ,MaFisRet(nCntFor,"IT_BASECOF")		,Nil})
			EndIf
			If lCpoALICOF .And. !Empty(VVG->VVG_ALICOF)
				aAdd(aTemp,{"D1_ALQCOF"   ,MaFisRet(nCntFor,"IT_ALIQCOF")		,Nil})
			EndIf
			If lCpoVALCOF .And. !Empty(VVG->VVG_VALCOF)
				aAdd(aTemp,{"D1_VALCOF"  ,MaFisRet(nCntFor,"IT_VALCOF")			,Nil})
			EndIf

			// Pis
			If lCpoBASPIS .And. !Empty(VVG->VVG_BASPIS)
				aAdd(aTemp,{"D1_BASEPIS"  ,MaFisRet(nCntFor,"IT_BASEPIS")		,Nil})
			EndIf
			If lCpoALIPIS .And. !Empty(VVG->VVG_ALIPIS)
				aAdd(aTemp,{"D1_ALQPIS"   ,MaFisRet(nCntFor,"IT_ALIQPIS")		,Nil})
			EndIf
			If lCpoVALPIS .And. !Empty(VVG->VVG_VALPIS)
				aAdd(aTemp,{"D1_VALPIS"  ,MaFisRet(nCntFor,"IT_VALPIS")			,Nil})
			EndIf

			// CF2
			If lCpoBAIMP5 .And. !Empty(VVG->VVG_BAIMP5)
				aAdd(aTemp,{"D1_BASIMP5"  ,MaFisRet(nCntFor,"IT_BASECF2")		,Nil})
			EndIf
			If lCpoALIMP5 .And. !Empty(VVG->VVG_ALIMP5)
				aAdd(aTemp,{"D1_ALQIMP5"  ,MaFisRet(nCntFor,"IT_ALIQCF2")		,Nil})
			EndIf
			If lCpoVLIMP5 .And. !Empty(VVG->VVG_VLIMP5)
				aAdd(aTemp,{"D1_VALIMP5"  ,MaFisRet(nCntFor,"IT_VALCF2")		,Nil})
			EndIf

			// PS2
			If lCpoBAIMP6 .And. !Empty(VVG->VVG_BAIMP6)
				aAdd(aTemp,{"D1_BASIMP6"  ,MaFisRet(nCntFor,"IT_BASEPS2")		,Nil})
			EndIf
			If lCpoALIMP6 .And. !Empty(VVG->VVG_ALIMP6)
				aAdd(aTemp,{"D1_ALQIMP6"  ,MaFisRet(nCntFor,"IT_ALIQPS2")		,Nil})
			EndIf
			If lCpoVLIMP6 .And. !Empty(VVG->VVG_VLIMP6)
				aAdd(aTemp,{"D1_VALIMP6"  ,MaFisRet(nCntFor,"IT_VALPS2")		,Nil})
			EndIf

			// Código Fiscal
			If lCpoCF .And. !Empty(VVG->VVG_CF)
				aAdd(aTemp,{"D1_CF"  ,MaFisRet(nCntFor,"IT_CF")					,Nil})
			EndIf
		EndIf

		if (cPaisLoc $ "ARG|MEX")
			If lCpoPROVEN .And. cPaisLoc == 'ARG'
				aAdd(aTemp,{"D1_PROVENT"  ,VVF->VVF_PROVEN ,Nil})
			EndIf
			If cTpFatR == "3" // 3=Fatura com Remito
				aAdd(aTemp,{"D1_REMITO" ,VVF->VVF_REMITO						,Nil})
				aAdd(aTemp,{"D1_SERIREM",VVF->VVF_SERREM						,Nil})
				aAdd(aTemp,{"D1_ITEMREM",VX0000071_Item_Remito( VVF->VVF_REMITO , VVF->VVF_SERREM , VVF->VVF_CODFOR , VVF->VVF_LOJA , SB1->B1_COD ),Nil})
			EndIf
		endif

		if Len(aAutoAux) >= nCntFor
			for nCntFor2 := 1 to Len(aAutoAux[nCntFor])
				aAdd(aTemp,aAutoAux[nCntFor,nCntFor2])
			next
		endif
		//
		aAdd(aIteNFE,aclone(aTemp))
	
		//Totaliza despesas para quando não vier calculado no VVF
		If nOpc == 3 .and. cX0OpeMov == "5" // Somente INCLUIR e devolucao de Venda
			nTotDesp += 0 // Zerar DESPESA, pois a Saida por Venda não utiliza o Valor da Despesa para calculo TOTAL do SF2.
		Else
			nTotDesp += MaFisRet(nCntFor,"IT_DESPESA")
		EndIf

	EndIf

Next
//
If VVF->VVF_FORPRO == "0" //Formulario Proprio = Nao
	cFormul := "N"
Else
	cFormul := "S"
EndIf
//
If cCliForA == "C"
	DBSelectArea("SA1")
	DBSetOrder(1)
	DbSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
Endif
//
If cPaisLoc == "BRA" .and. xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cEspecie:=Space(5)
	cTiposDoc:=Alltrim(SuperGetMv('MV_ESPECIE'))
	cTiposDoc:=StrTran(cTiposDoc,";",chr(13)+chr(10))
	nLinhas:=MLCount(cTiposDoc)
	For nL:=1 to nLinhas
		cEspecie:=Alltrim(StrTran(MemoLine(cTiposDoc,,nL),Chr(13),Chr(10)))
		nPosSign:=Rat("=",cEspecie)
		If nPosSign>0 .and. Alltrim(cSerie)==Alltrim(Substr(cEspecie,1,nPosSign-1)) // Heverson
			cEspecie:=Substr(cEspecie,nPosSign+1)
			SX5->(MsSeek(xFilial("SX5")+"42"+cEspecie))
			If SX5->(!Found())
				cEspecie:=Space(5)
			Endif
			Exit
		Else
			cEspecie:=Space(5)
		Endif
	Next
	//
EndIf

// VVF_OPEMOV: 0=Normal;1=Ped.Fabrica;2=Remessa;3=Transferencia;4=Consignacao;5=Devolucao;6=Frete;7=Retorno de Remessa;8=Retorno de Consignacao
cF1Tipo := "N"
Do Case
	Case cX0OpeMov <> "5" // Diferente de Devolucao
		If cCliForA == "C" // utiliza Cliente
			cF1Tipo := "B" // Beneficiamento
		EndIf

	Case cX0OpeMov $ "5" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) > 0 ) // Devolucao
		cF1Tipo := "D" // D-Devolucao

EndCase

SA2->(DbGoTop())
SA2->(dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA))

If xTIPDOC == "1" .and. lCriaSF1 // 1=NF / 2=SD3 (Mov.Internas)

	aAdd(aCabNFE,{"F1_TIPO"		, cF1Tipo	,Nil})
	aAdd(aCabNFE,{"F1_FORMUL"	, cFormul       	 										,Nil})

	// O número da nota fiscal para formulario proprio é atribuido automaticamente no execauto somente para o Brasil.
	// Na argentina o numero foi adquirido e está nas variáveis cNumero e cSerie e nesse ponto já está gravado na tabela VVF.
	if cPaisLoc $ "ARG|MEX" .or. VVF->VVF_FORPRO == "0" 
		If  !(cPaisLoc $ "ARG|MEX") .or. ;
			(cPaisLoc == 'ARG' .and. cTpFatR $ "1/3/4") .or. ; // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
			(cPaisLoc == 'MEX' .and. cTpFatR $ "1/3") // 1=Fatura / 3=Fatura com Remito
			aAdd(aCabNFE,{"F1_DOC"		,VVF->VVF_NUMNFI										,Nil})
			aAdd(aCabNFE,{"F1_SERIE"	,VVF->VVF_SERNFI										,Nil})
		Else // cTpFatR == "2" // 2=Remito
			aAdd(aCabNFE,{"F1_DOC"		,VVF->VVF_REMITO										,Nil})
			aAdd(aCabNFE,{"F1_SERIE"	,VVF->VVF_SERREM										,Nil})
		EndIf
	else
		aAdd(aCabNFE,{"F1_SERIE"	,VVF->VVF_SERNFI										,Nil})
	endif

	aAdd(aCabNFE,{"F1_EMISSAO"	,VVF->VVF_DATEMI											,Nil})

	If cF1Tipo <> "D" .and. cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
		aAdd(aCabNFE,{"F1_COND"		,VVF->VVF_FORPAG 										,Nil})
	Endif
	aAdd(aCabNFE,{"F1_FORNECE"	,VVF->VVF_CODFOR											,Nil})
	aAdd(aCabNFE,{"F1_LOJA"		,VVF->VVF_LOJA  											,Nil})
	
	If VVF->VVF_DESACE > 0
		aAdd(aCabNFE,{"F1_DESPESA"	,VVF->VVF_DESACE  											,Nil})
	Else
		aAdd(aCabNFE,{"F1_DESPESA"	,nTotDesp  											,Nil})
	EndIf
	aAdd(aCabNFE,{"F1_BRICMS"	,MaFisRet(,"NF_BASESOL")									,Nil})
	aAdd(aCabNFE,{"F1_ICMSRET"	,MaFisRet(,"NF_VALSOL")										,Nil})
	aAdd(aCabNFE,{"F1_FRETE"	,MaFisRet(,"NF_FRETE")										,Nil})
	If !Empty(cTpFrete)
		aAdd(aCabNFE,{"F1_TPFRETE"	,cTpFrete												,Nil})
	Else
		If VVF->(ColumnPos("VVF_TPFRET")) <> 0 .and. ! Empty(VVF->VVF_TPFRET)
			aAdd(aCabNFE,{"F1_TPFRETE"	,VVF->VVF_TPFRET										,Nil})
		EndIf
	EndIf
	aAdd(aCabNFE,{"F1_SEGURO"	,MaFisRet(,"NF_SEGURO")										,Nil})
	aAdd(aCabNFE,{"F1_VALMERC"	,MaFisRet(,"NF_VALMERC")									,Nil})
	aAdd(aCabNFE,{"F1_VALBRUT"	,MaFisRet(,"NF_TOTAL")										,Nil})
	aAdd(aCabNFE,{"F1_BASEICM"	,MaFisRet(,"NF_BASEICM")									,Nil})
	aAdd(aCabNFE,{"F1_VALICM"	,MaFisRet(,"NF_VALICM")										,Nil})
	aAdd(aCabNFE,{"F1_BASEIPI"	,MaFisRet(,"NF_BASEIPI")									,Nil})
	aAdd(aCabNFE,{"F1_VALIPI"	,MaFisRet(,"NF_VALIPI")										,Nil})
	aAdd(aCabNFE,{"F1_EST"		,iIf(cCliForA == "C",SA1->A1_EST,SA2->A2_EST)				,Nil})
	If VVF->(FieldPos("VVF_DEVMER")) > 0 .and. !Empty(VVF->VVF_DEVMER)
		aAdd(aCabNFE,{"F1_DEVMERC"	,VVF->VVF_DEVMER										,Nil})
	EndIf
	aAdd(aCabNFE,{"F1_PLIQUI"		,VVF->VVF_PLIQUI   ,Nil})
	aAdd(aCabNFE,{"F1_PBRUTO"		,VVF->VVF_PBRUTO   ,Nil})
	If !Empty(VVF->VVF_TRANSP)
		aAdd(aCabNFE,{"F1_TRANSP"  ,VVF->VVF_TRANSP  ,Nil})
	Endif
	aAdd(aCabNFE,{"F1_ESPECI1",VVF->VVF_ESPEC1  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME1" ,VVF->VVF_VOLUM1  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECI2",VVF->VVF_ESPEC2  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME2" ,VVF->VVF_VOLUM2  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECI3",VVF->VVF_ESPEC3  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME3" ,VVF->VVF_VOLUM3  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECI4",VVF->VVF_ESPEC4  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME4" ,VVF->VVF_VOLUM4  ,Nil})

	If (cPaisLoc == "BRA")
		If M->VVF_FORPRO == "1"//Formulario Proprio = Sim
			If VVF->(FieldPos("VVF_ESPECI")) <> 0 .AND. !Empty(VVF->VVF_ESPECI)
				aAdd(aCabNFE,{"F1_ESPECIE"	,AllTrim(VVF->VVF_ESPECI)    ,Nil})
			Else
				aAdd(aCabNFE,{"F1_ESPECIE" , AllTrim(cEspecie) ,Nil})
			Endif
			if VVF->(FieldPos("VVF_MENPAD")) > 0 .and. SF1->(FieldPos("F1_MENPAD")) > 0
				aAdd(aCabNFE,{"F1_MENPAD" , VVF->VVF_MENPAD ,Nil})
			Endif
			if VVF->(FieldPos("VVF_MENNOT")) > 0 .and. SF1->(FieldPos("F1_MENNOTA")) > 0
				aAdd(aCabNFE,{"F1_MENNOTA" , VVF->VVF_MENNOT ,Nil})
			Endif
		Else
			if VVF->(FieldPos("VVF_ESPECI")) <> 0 .and. !Empty(VVF->VVF_ESPECI)
				aAdd(aCabNFE,{"F1_ESPECIE" , AllTrim(VVF->VVF_ESPECI) ,Nil})
			else
				aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
			endif
		Endif
	Else
		If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
			aAdd(aCabNFE,{"F1_TIPODOC"	,IIf(cF1Tipo$"B/D","12","10")								,Nil})
		Else // cTpFatR == "2" // 2=Remito
			aAdd(aCabNFE,{"F1_TIPODOC"	,"60"														,Nil})
		EndIf
		aAdd(aCabNFE,{"F1_ESPECIE"	,AllTrim(VVF->VVF_ESPECI)										,Nil})
	endif

	If VVF->(FieldPos("VVF_CHVNFE")) > 0 .and. ! empty( VVF->VVF_CHVNFE )
		aAdd(aCabNFE,{"F1_CHVNFE"		,VVF->VVF_CHVNFE   ,Nil})
	endif

	If !Empty(cFilOrig) .and. SF1->(FieldPos("F1_FILORIG")) > 0
		aAdd(aCabNFE,{"F1_FILORIG"		, cFilOrig ,Nil}) // Filial de Origem ( Filial da Saida )
	EndIf

	// Veículo Transportador (Integração MATA103 - CI 008022)
	aAdd(aCabNFE,{"F1_VEICUL1"		,VVF->VVF_VEICU1   ,Nil})
	aAdd(aCabNFE,{"F1_VEICUL2"		,VVF->VVF_VEICU2   ,Nil})
	aAdd(aCabNFE,{"F1_VEICUL3"		,VVF->VVF_VEICU3   ,Nil})

	aAdd(aCabNFE,{"F1_FORRET"		,VVF->VVF_CLIRET   ,Nil})
	aAdd(aCabNFE,{"F1_LOJARET"		,VVF->VVF_LOJRET   ,Nil})
	aAdd(aCabNFE,{"F1_FORENT"		,VVF->VVF_CLIENT   ,Nil})
	aAdd(aCabNFE,{"F1_LOJAENT"		,VVF->VVF_LOJENT   ,Nil})

	// Moeda
	If VVF->(FieldPos("VVF_MOEDA")) > 0
		aAdd(aCabNFE,{"F1_MOEDA"		,VVF->VVF_MOEDA    ,Nil})
	EndIf
	If VVF->(FieldPos("VVF_TXMOED")) > 0
		aAdd(aCabNFE,{"F1_TXMOEDA"		,VVF->VVF_TXMOED   ,Nil})
	EndIf

	//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
	If VVF->(FieldPos("VVF_PLACA")) > 0
		aAdd(aCabNFE,{"F1_PLACA"		,VVF->VVF_PLACA   ,Nil})
	EndIf

	if cPaisLoc == "ARG"		
		aAdd(aCabNFE,{"F1_PROVENT",VVF->VVF_PROVEN ,Nil})		
		aAdd(aCabNFE,{"F1_CAE"    ,VVF->VVF_CAE    ,Nil})
		aAdd(aCabNFE,{"F1_VCTOCAE",VVF->VVF_VCTCAE ,Nil})
	endif

	aAdd(aCabNFE,{"E2_NATUREZ"	,VVF->VVF_NATURE													,Nil})
	//
	// JANELA DE ABORTO
	//
	//
	//Chamada do MATA103 (Nota Fiscal de Entrada)
	//
	SF1->(dbSetOrder(1))
	SD1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	//
	If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
		cPosSF1 := xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA
	Else // cTpFatR == "2" // 2=Remito
		cPosSF1 := xFilial("SF1")+VVF->VVF_REMITO+VVF->VVF_SERREM+VVF->VVF_CODFOR+VVF->VVF_LOJA
	EndIf

	DbSelectArea("SF1")
	dbSetOrder(1)
	If dbSeek(cPosSF1)
		DisarmTransaction()
		RollBackSX8()
		FMX_HELP("VEIX000E01",STR0059) //Numeracao de Nota Fiscal ja existente..."
		lErro := .T.
		break
	EndIf
	//
	nAnt    := MAFISSAVE()
	MAFISEND()

EndIf

// Chamada de PE Antes da gravação da chamada do ExecAuto do Mata103
If ExistBlock("VX000AIN")
	ExecBlock("VX000AIN",.f.,.f.,{nOpc,cX0OpeMov})
Endif
//

If xTIPDOC == "1" .and. lCriaSF1 // 1=NF / 2=SD3 (Mov.Internas)

	If !(cPaisLoc == "BRA")
		If (cTpFatR $ "1/3/4".And.cPaisLoc!='MEX').Or.(cTpFatR $ "1/3".And.cPaisLoc=='MEX') // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
			cNomeFunc := FunName()
			SetFunName("MATA101N")
			MsExecAuto({|x,y,z| MATA101N(x,y,z) },aCabNFE,aIteNFE,3)
			SetFunName(cNomeFunc)
		Else // cTpFatR == "2" // 2=Remito
			If cX0OpeMov $ "578"
				mv_par01 := Iif(VVF->VVF_FORPRO == "1" , 1, 2)
				MsExecAuto({ |v,w,x,y,z| LocxNf(v,w,x,y,z) }, Iif(VVF->VVF_FORPRO=="1", 51, 53), aCabNFE, aIteNFE, 3, "MATA462DN")
			Else
				MsExecAuto({|x,y,z| MATA102N(x,y,z) },aCabNFE,aIteNFE,3)
				SF1->(DbSetOrder(1))
				SF1->(DbSeek(xFilial("SF1")+VVF->VVF_REMITO+VVF->VVF_SERREM+VVF->VVF_CODFOR+VVF->VVF_LOJA))
			EndIf
		EndIf
	else
//  	if M->VVF_FORPRO == "1" .and. xSX5NumNota[1] // Não é um Remito e Formulario Proprio = SIM
//			cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1")) // Incrementa Nro Nota + 1
//		EndIf
		aCampos := {}
		MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,aIteNFE)
	endif

	MAFISRESTORE(nAnt)

ElseIf xTIPDOC == "2" // 1=NF / 2=SD3 (Mov.Internas) - Agrega/Desagrega

	aSB1SD3    := {}
	SB1->(DbSetOrder(7))
	For nCntFor := 1 to len(aCols)
		FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
		// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
		aAdd(aSB1SD3,{	SB1->B1_COD ,;
						1 ,;
						aCols[nCntFor,FG_POSVAR("VVG_VALUNI")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_CENCUS")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_CONTA")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_ITEMCT")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_CLVL")] })
	Next
	SB1->(DbSetOrder(1))
	If !VA3300071_Movimentacoes_Internas( "1" , "1" , xCodVDV , GetNewPar("MV_MIL0114","") , aSB1SD3 ) .or. cDebugMIL == "VEIXX000SD3" // Mov.Interna Peça ( 1=Entrada , 1=Tp.Normal , Codigo VDV , D3_TM , aSB1 )
		DisarmTransaction()
		RollBackSX8()
		lErro := .T.
		break
	EndIf

EndIf
//
If lMsErroAuto
	DisarmTransaction()
	RollBackSX8()
	lErro := .T.
	break
EndIf
// JANELA DE ABORTO
If VX000ABORT()
	DisarmTransaction()
	RollBackSX8()
	lErro := .T.
	break
EndIf

if cX0OpeMov == "0" // Entrada p/ Compra
	For i := 1 to Len(aVV1)
		dbSelectArea("VV1")
		dbGoto(aVV1[i,1])
		cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA "
		cQuery +=  " FROM " + RetSqlName("VVA") + " VVA "
		cQuery += "INNER JOIN "+RetSQLName("VV9")+" VV9 ON  VV9.VV9_FILIAL  = VVA.VVA_FILIAL AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA AND VV9.VV9_STATUS NOT IN ('F','C') AND VV9.D_E_L_E_T_=' ' "
		If lVV1Comp // VV1 Compartilhado
			cQuery += " WHERE VVA.VVA_FILIAL IN " + cFilVVA + " AND "
		Else // VV1 Exclusivo
			cQuery += " WHERE VVA.VVA_FILIAL = '" + cFilVV1 + "' AND "
		Endif
		cQuery += "VVA.VVA_CHAINT = '" + VV1->VV1_CHAINT + "' AND VVA.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSqlVVA, .F., .T. )
		While !(cSqlVVA)->(Eof())
			DBSelectArea("VVA")
			DbGoTo((cSqlVVA)->(RECVVA))
			RecLock("VVA",.f.)
			If VVA->(FieldPos("VVA_CODMAR")) > 0 .and. !Empty(VVA->VVA_CODMAR)
				VVA->VVA_VCAVEI := FGX_CUSVEI(VVA->VVA_CHAINT , VVA->VVA_CODMAR , VVA->VVA_MODVEI , VV2->VV2_SEGMOD , VVA->VVA_CORVEI , dDataBase )
			Else
				VVA->VVA_VCAVEI := FGX_CUSVEI(VVA->VVA_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_SEGMOD , VV1->VV1_CORVEI , dDataBase )
			EndIf
			nTotImp := 0
			if cPaisLoc == "BRA"
				VVA->VVA_TOTCUS := FG_FORMULA(GetNewPar("MV_TOTCUFN","VVA->VVA_VCAVEI-VVA->VVA_REDCUS+VVA->VVA_JUREST+VVA->VVA_ACESSO+VVA->VVA_VDESCO+VVA->VVA_PISENT+VVA->VVA_COFENT"))
				VVA->VVA_TOTIMP := VVA->VVA_ICMVEN+VVA->VVA_ISSCVD+VVA->VVA_PISVEN+VVA->VVA_COFVEN+VVA->VVA_ISSRTE+VVA->VVA_PISRTE+VVA->VVA_ISSBFB+VVA->VVA_PISBFB
				nTotImp := VVA->VVA_TOTIMP
			elseif cPaisLoc $ "ARG|MEX"
				VVA->VVA_TOTCUS := FG_FORMULA(GetNewPar("MV_TOTCUFN","VVA->VVA_VCAVEI-VVA->VVA_REDCUS+VVA->VVA_JUREST+VVA->VVA_ACESSO+VVA->VVA_VDESCO"))
			endif
			VVA->VVA_LUCBRU := VVA->VVA_FATTOT-nTotImp-VVA->VVA_VCAVEI
			VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT //LUCRO MARGINAL
			VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)
			VVA->(MsUnlock())
			dbSelectArea(cSqlVVA)
			(cSqlVVA)->(dbSkip())
		Enddo
		(cSqlVVA)->(DbCloseArea())
	Next
Endif

DbSelectArea("VVF")
DbGoTo(nRecVVF)

If xTIPDOC == "1" .and. lCriaSF1 // 1=NF / 2=SD3 (Mov.Internas)

	If M->VVF_FORPRO == "1" // Formulario Proprio = SIM
		DbSelectArea("VVF")
		RecLock("VVF",.f.)
		VVF->VVF_NUMNFI := Iif(SF1->(!Eof()), SF1->F1_DOC, VVF->VVF_NUMNFI)
		MsUnlock()
		cNumero := VVF->VVF_NUMNFI
		M->VVF_NUMNFI := cNumero
	Endif

	if cX0OpeMov $ "03" // Compra e Transferencia
		//
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSelectArea("VVG")
		dbSetOrder(1)
		//
		If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
			While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
				DbSelectArea("SB1")
				If FGX_VV1SB1("CHAINT", VVG->VVG_CHAINT , /* cMVMIL0010 */ , cGruVei )
					If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
						cSeekSD1 := xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD
					Else // cTpFatR == "2" // 2=Remito
						cSeekSD1 := xFilial("SD1")+VVF->VVF_REMITO+VVF->VVF_SERREM+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD
					EndIf
					If SD1->(dbSeek(cSeekSD1))
							RecLock("VVG",.F.)
							VVG->VVG_VCNVEI := SD1->D1_CUSTO
							MsUnLock()
					EndIf
				Endif
				dbSelectArea("VVG")
				DbSkip()
			Enddo
		Endif
		//
	EndIf

	If VVG->(FieldPos("VVG_NUMPED"))>0
		//VVF=Cabecalho da entrada de veiculo / VVG=Itens da entrada de veiculo
		dbSelectArea("VVG")
		dbSetOrder(1)
		If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)

			While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
				
				If !Empty(VVG->VVG_NUMPED)
				
					//verifica se existe o pedido
					dbSelectArea("SC7")
					dbSetOrder(1)
					If dbSeek(xFilial("SC7")+VVG->VVG_NUMPED+VVG->VVG_ITPED) .or. cDebugMIL == "VEIXX000SC7"
						if 	SC7->C7_ENCER == "E" .or. cDebugMIL == "VEIXX000SC7" //Encerrado
							MsgStop(STR0084+Alltrim(SC7->C7_PRODUTO),STR0017) //"Não há saldo suficiente no pedido de compra para o produto "
							DisarmTransaction()
							RollBackSX8()
							lErro := .T.
							break
						endif
						// Grava os dados na tabela SC7
						RecLock("SC7",.F.)
						SC7->C7_QUJE := SC7->C7_QUJE + 1     //Sempre somo um pq no VVG cada item eh um registro
						//Verifica Saldo Pedido
						If SC7->C7_QUANT == SC7->C7_QUJE
							SC7->C7_ENCER := "E" //Encerrado
						EndIf
						MsUnLock()
						//Localiza o codigo do produto no SB1
						FGX_VV1SB1("CHAINT", VVG->VVG_CHAINT , /* cMVMIL0010 */ , cGruVei )
						If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
							cSeekSD1 := xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD
						Else // cTpFatR == "2" // 2=Remito
							cSeekSD1 := xFilial("SD1")+VVF->VVF_REMITO+VVF->VVF_SERREM+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD
						EndIf
						//Grava dados SD1
						dbSelectArea("SD1")
						dbSetOrder(1)
						If dbSeek(cSeekSD1)
							RecLock("SD1",.F.)
							D1_PEDIDO := VVG->VVG_NUMPED
							D1_ITEMPC := VVG->VVG_ITPED
							MsUnLock()
						EndIf

					EndIf

				EndIf

				dbSelectArea("VVG")
				DbSkip()
			Enddo
		EndIf
	EndIf

	//#############################################################################
	//# Gravacao dos Titulos a Pagar                                              #
	//#############################################################################
	// TODO: Considera Beneficiamento na geracao do titulo?
	If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
		cSeekSF1 := xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA
	ElseIf cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
		cSeekSF1 := xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA
	Else // cTpFatR == "2" // 2=Remito
		cSeekSF1 := xFilial("SF1")+VVF->VVF_REMITO+VVF->VVF_SERREM+VVF->VVF_CODFOR+VVF->VVF_LOJA
	EndIf
	DBSelectArea("SF1")
	DBSetOrder(1)
	DbSeek(cSeekSF1)
	//
	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	VVF->VVF_TIPO := SF1->F1_TIPO
	VVF->VVF_RECSF1 := SF1->(Recno())

	If cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
		// Remito Entrega Futura faz todo o processamento com cTpFatR == "2" // 2=Remito
		// Finalizar o processamento com cTpFatR == "3" // 3=Fatura com Remito
		VVF->VVF_TPFATR := "3" // 3=Fatura com Remito
	EndIf

	MsUnlock()

	lGeraTitulo := .f.
	If !Empty(SF1->F1_COND)
		DBSelectArea("SE4")
		DBSetOrder(1)
		DBSeek(xFilial("SE4")+SF1->F1_COND)
		lGeraTitulo:= (SE4->E4_TIPO == "A" .and. !lLivreDebito .and. Alltrim(SF4->F4_DUPLIC) == "S" .and. cX0OpeMov != "5")
	EndIf

	If lGeraTitulo
		dbSelectArea("SF1")
		RecLock("SF1",.f.)
		SF1->F1_DUPL    := SF1->F1_DOC
		SF1->F1_PREFIXO := &(GetNewPar("MV_2DUPREF","cSerie"))
		MsUnlock()
		//
		cCodBco2 := M->VVF_CODBCO
		cNumBord2:= ""
		dDatBord2:= cTod("")
		FG_Seek("SA6","cCodBco2",1,.f.)
		If SA6->A6_BORD == "0"
			cNumBord2 := "BCO"+SA6->A6_COD
			dDatBord2 := dDataBase
		EndIf
		For nCntFor := 1 to Len(aIteParc)
			aVetDesp := {}
			aAdd(aVetDesp,{"E2_PREFIXO"  ,&(GetNewPar("MV_2DUPREF","cSerie"))				,Nil})
			aAdd(aVetDesp,{"E2_NUM"      ,VVF->VVF_NUMNFI    								,Nil})
			aAdd(aVetDesp,{"E2_TIPO"     ,Iif(cX0OpeMov$"245","NCC","DP ")					,Nil})
			aAdd(aVetDesp,{"E2_NATUREZ"  ,VVF->VVF_NATURE    								,Nil})
			aAdd(aVetDesp,{"E2_PARCELA"  ,Strzero(nCntFor,TamSx3("E2_PARCELA")[1])			,Nil})
			aAdd(aVetDesp,{"E2_FORNECE"  ,M->VVF_CODFOR      								,Nil})
			aAdd(aVetDesp,{"E2_LOJA"     ,M->VVF_LOJA        								,Nil})
			aAdd(aVetDesp,{"E2_EMISSAO"  ,M->VVF_DATEMI										,Nil})
			aAdd(aVetDesp,{"E2_VENCTO"   ,aIteParc[nCntFor,1]								,Nil})
			aAdd(aVetDesp,{"E2_VALOR"    ,aIteParc[nCntFor,2]								,Nil})
			aAdd(aVetDesp,{"E2_VLCRUZ"   ,aIteParc[nCntFor,2]								,Nil})
			aAdd(aVetDesp,{"E2_NUMBOR"   ,cNumBord2   										,Nil})
			aAdd(aVetDesp,{"E2_PORTADO"  ,cCodBco2    										,Nil})
			If lMoeda .and. VVF->VVF_MOEDA > 0
				aAdd(aVetDesp,{"E2_MOEDA",VVF->VVF_MOEDA									,Nil})
			EndIf
			If len(aIteParc[nCntFor]) >= 3
				For nCntFor2 := 1 to len(aParcCust)
					aAdd(aVetDesp,{aParcCust[nCntFor2,2], aIteParc[nCntFor,3,nCntFor2]		,Nil})
				Next
			EndIf
			If ExistBlock("VX000ICP") // Ponto de Entrada para alterar informações do Contas a Pagar
				aVetDesp := ExecBlock("VX000ICP", .f., .f., {aVetDesp})
			EndIf

			pergunte("FIN050",.F.)
			MsExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp)
			If lMsErroAuto
				DisarmTransaction()
				RollBackSX8()
				lErro := .T.
				break
			EndIf
			cAliAntG := alias()
			DbSelectArea("SE2")
			reclock("SE2",.f.)
			SE2->E2_ORIGEM := "MATA100"
			SE2->E2_LA := "S"
			msunlock()
			DBSelectArea(cAliAntG)
		Next
	EndIf
	//#############################################################################
	//# Fim da Emissao da Nota Fiscal de Entrada                                  #
	//#############################################################################
	MAFISEND()
	// JANELA DE ABORTO

EndIf

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	if cX0OpeMov $ "5/7/8" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) > 0 )// DEVOLUCAO/ RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
		// ATUALIZA O STATUS DA NF PARA DEVOLVIDA
		cChave := ""
		if Len(aAutoAux) > 0
			cChave += xFilial("VV0")
			nPos := ascan(aAutoAux[1],{|x| x[1] == "D1_FILORI" })
			if nPos != 0
				cChave := aAutoAux[1,nPos,2]
			endif
			nPos := ascan(aAutoAux[1],{|x| x[1] == "D1_NFORI" })
			if nPos != 0
				cChave += aAutoAux[1,nPos,2]
			endif
			nPos := ascan(aAutoAux[1],{|x| x[1] == "D1_SERIORI" })
			if nPos != 0
				cChave += aAutoAux[1,nPos,2]
			endif
			DBSelectArea("VV0")
			DBSetOrder(4) // VV0_FILIAL+VV0_NUMNFI+VV0_SERNFI
			if DBSeek(cChave)
				reclock("VV0",.f.)
				VV0->VV0_SITNFI := "2"
				msunlock()
			else
				DbSetOrder(7) // VV0_FILIAL+VV0_REMITO+VV0_SERREM
				if DBSeek(cChave)
					reclock("VV0",.f.)
					VV0->VV0_SITNFI := "2"
					msunlock()
				endif
			endif
		endif
	endif

EndIf

// Integracao com BackOffice - NF de Entrada é digitada no BackOffice (SIGAEIC)
If xTIPDOC == "3"
	SF1->(DbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA))
	//
	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	VVF->VVF_TIPO := SF1->F1_TIPO
	VVF->VVF_RECSF1 := SF1->(Recno())
	MsUnlock()
	
	if cX0OpeMov $ "03" // Compra e Transferencia
		//
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA

			If FGX_VV1SB1("CHAINT", VVG->VVG_CHAINT , /* cMVMIL0010 */ , cGruVei )

				If SD1->(dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD))
					RecLock("VVG",.F.)
					VVG->VVG_VCNVEI := SD1->D1_CUSTO
					MsUnLock()
				EndIf

			Endif
			dbSelectArea("VVG")
			DbSkip()
		Enddo
	Endif

EndIf

// ###############################################
// ATUALIZA O STATUS DO VEICULO                  #
// ###############################################
// ALTERA STATUS DOS VEICULOS
aChassiMov := {}

For nCntFor = 1 to len(acols)
	n := nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf

	aAdd(aChassiMov,{ aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] })

	dbSelectArea("SB1")
	dbSetOrder(7)
	DBSelectArea("SF4")
	DBSetOrder(1)
	MsSeek(xFilial("SF4")+aCols[nCntFor,FG_POSVAR("VVG_CODTES")])
	if SF4->F4_ESTOQUE == "S" .and. SF4->F4_PODER3 == "N"
		dbSelectArea("SB1")
		// Posiciona no Produto Correto 
		If FGX_VV1SB1("CHAINT", aChassiMov[Len(aChassiMov),1] , /* cMVMIL0010 */ , cGruVei )
			DbSelectArea("SB5")
			DbSetOrder(1)
			DbSeek( xFilial("SB5") + SB1->B1_COD )
			RecLock("SB5",!Found())
			SB5->B5_FILIAL  := xFilial("SB5")
			SB5->B5_COD     := SB1->B1_COD
			SB5->B5_LOCALI2 := M->VVG_LOCALIZ //GetNewPar("MV_RECVEIC","RECEPCAO VEIC")
			MsUnlock()
		EndIf
	endif
	// ATUALIZA IMOBILIZADO
	If ( Alltrim(SF4->F4_CF) == "1551" .or. SF4->F4_OPEMOV == "07" ) .and. VV1->VV1_IMOBI $ "0. "
		DbSelectArea("VV1")
		RecLock("VV1",.f.)
		VV1->VV1_IMOBI := "1"	// Imobilizado
		MsUnlock()
	Endif

	If cX0OpeMov == "0" .and. VV1->(FieldPos("VV1_DEMONS")) > 0 .and. VVG->(FieldPos("VVG_DEMONS")) > 0
		DbSelectArea("VV1")
		RecLock("VV1",.f.)
		VV1->VV1_DEMONS := aCols[nCntFor,FG_POSVAR("VVG_DEMONS")]	// Compra do equipamento realizada para demonstração ? 0=Nã0 ; 1=Sim
		MsUnlock()
	Endif

Next

If cX0OpeMov <> "0" .and. cX0OpeMov <> "7" .and. cX0OpeMov <> "8"  // Diferente de Entrada por  0-Compra  7-Ret.Remessa  8-Ret.Consignacao
	////////////////////////////////////////
	// Levanta todas as Filiais VVA / VVD //
	////////////////////////////////////////
	cVVAFil := ""
	cQuery  := "SELECT DISTINCT VVA_FILIAL FROM "+RetSQLName("VVA")+" WHERE D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
	While !( cQAlAux )->( Eof() )
		cVVAFil += "'"+( cQAlAux )->( VVA_FILIAL )+"',"
		( cQAlAux )->( dbSkip() )
	EndDo
	( cQAlAux )->( dbCloseArea() )
	cVVAFil := IIf(!Empty(cVVAFil),left(cVVAFil,len(cVVAFil)-1),"'"+xFilial("VVA")+"'")
	//
	For nCntFor := 1 to Len(aChassiMov)
		/////////
		// VV1 //
		/////////
		VV1->(DbSetOrder(1)) // CHAINT
		VV1->(DbSeek(xFilial("VV1")+aChassiMov[nCntFor,1])) // CHAINT
		/////////
		// VVA //
		/////////
		cQuery := "SELECT R_E_C_N_O_ RECVVA FROM "+RetSQLName("VVA")+" WHERE "
		cQuery += "VVA_FILIAL IN ("+cVVAFil+") AND VVA_CHAINT='"+VV1->VV1_CHAINT+"' AND "
		cQuery += "VVA_FILENT='"+VV1->VV1_FILENT+"' AND VVA_TRACPA='"+VV1->VV1_TRACPA+"' AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		While !( cQAlAux )->( Eof() )
			DbSelectArea("VVA")
			DbGoto(( cQAlAux )->( RECVVA ))
			RecLock("VVA",.f.)
			VVA->VVA_FILENT := VVF->VVF_FILIAL // Novo FILENT
			VVA->VVA_TRACPA := VVF->VVF_TRACPA // Novo TRACPA
			MsUnLock()
			( cQAlAux )->( dbSkip() )
		EndDo
		( cQAlAux )->( dbCloseArea() )
		/////////
		// VVD //
		/////////
		cQuery := "SELECT R_E_C_N_O_ RECVVD FROM "+RetSQLName("VVD")+" WHERE "
		If !lVVD_FILENT
			cQuery += "VVD_FILIAL='"+VV1->VV1_FILENT+"'"
		Else
			cQuery += "( ( VVD_FILIAL = '" + xFilial("VVD")  + "' AND VVD_FILENT = '" + VV1->VV1_FILENT + "' ) " // novos registros
			cQuery += "OR (VVD_FILIAL = '" + VV1->VV1_FILENT + "' AND VVD_FILENT = ' ' ) ) " // registro antigos
		Endif
		cQuery += " AND VVD_CHAINT='"+VV1->VV1_CHAINT+"'"
		cQuery += " AND VVD_TRACPA='"+VV1->VV1_TRACPA+"' AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		While !( cQAlAux )->( Eof() )
			DbSelectArea("VVD")
			DbGoto(( cQAlAux )->( RECVVD ))
			RecLock("VVD",.f.)
			VVD->VVD_FILIAL := VVF->VVF_FILIAL // Novo FILENT
			VVD->VVD_TRACPA := VVF->VVF_TRACPA // Novo TRACPA
			MsUnLock()
			( cQAlAux )->( dbSkip() )
		EndDo
		( cQAlAux )->( dbCloseArea() )

	Next
EndIf
//
End Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

If cPaisLoc $ "ARG|MEX" .and. cX0OpeMov == "5" // 5=Devolucao
	DbSelectArea("VVF")
	DbGoTo(nRecVVF)

	// Guarda o recno do VVF para gerar NCC
	If !Empty(VV0->VV0_NUMNFI) .and. !Empty(VV0->VV0_SERNFI)
		nRecVVFNCC := If( (!lMsErroAuto .and. ! lErro) , nRecVVF, 0) // Variável declarada no VEIXA002 (nRecVVFNCC)
	EndIf

	// Atualiza o status da NCC
	RecLock("VVF",.f.)
	VVF->VVF_STANCC := If(nRecVVFNCC > 0, "1", "0") // 0=Sem NCC;1=Falta NCC;2=NCC Gerada
	MsUnlock()
EndIf

If !lMsErroAuto .and. ! lErro

	DbSelectArea("VVF")
	DbGoTo(nRecVVF)

	If lMostraMsg
		If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
			If cTpFatR $ "1/3/4" // 1=Fatura / 3=Fatura com Remito / 4=Entrega Futura
				FMX_TELAINF( "1" , { { Alltrim(VVF->VVF_SERNFI) , Alltrim(VVF->VVF_NUMNFI) , If( cPaisLoc == "BRA" , STR0060, STR0166 ) } } ) // "EMITIDO" # GENERADA
			Else // cTpFatR == "2" // 2=Remito
				FMX_TELAINF( "1" , { { Alltrim(VVF->VVF_SERREM) , Alltrim(VVF->VVF_REMITO) , If( cPaisLoc == "BRA" , STR0060, STR0166 ) } } ) // "EMITIDO"
			EndIf
		Else
			FMX_TELAINF( "4" , { { STR0102 , If( cPaisLoc == "BRA" , STR0060, STR0166 ) } } ) // Mov.Interna / EMITIDO
		EndIf
	endif

	//
	// ALTERA STATUS DOS VEICULOS
	For nCntFor := 1 to Len(aChassiMov)
		//
		FGX_AMOVVEI(xFilial("VV1"),aChassiMov[nCntFor,2], cRotOrigem + " - " + "VX000EMINF_2", .t. )

		If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

			VV1->(dbSetOrder(2))
			VV1->(DBSEEK(xFilial("VV1")+aChassiMov[nCntFor,2]))

			If GetNewPar("MV_PERGVTR","N") == "S"

				If VV1->VV1_SITVEI == "0"
					// Declaracao da ParamBox
					aRet := {}
					aParamBox := {}
					aCombo := {"0-"+OemtoAnsi(STR0091),"2-"+OemtoAnsi(STR0092)}
					aAdd(aParamBox,{2,OemtoAnsi(STR0093),"1",aCombo,70,"",.F.}) // Tipo caractere
					//
					While !(ParamBox(aParamBox,"",@aRet))
					Enddo
					//
					cSitVei := Left(aRet[1],1)
					If cSitVei == "2"

						VX0000073_AtuVV1SitVei(cSitVei)

						If VV1->VV1_SITVEI == "2"
							DbSelectArea("VZK")
							RecLock("VZK",.t.)
							VZK_FILIAL := xFilial("VZK")
							VZK_CHASSI := VV1->VV1_CHASSI
							VZK_NUMNFI := VVF->VVF_NUMNFI
							VZK_SERNFI := VVF->VVF_SERNFI
							VZK_CODFOR := VVF->VVF_CODFOR
							VZK_LOJA   := VVF->VVF_LOJA
							VZK_DATENT := dDataBase // Data de Entrada do Veiculo em Transito
							MsUnlock()
						Endif
					Endif
				Endif
			Endif

		EndIf

	next
	//
	DbSelectArea("VVF")
	DbGoTo(nRecVVF)
	//
	//ConfirmSx8()
	//
	If VVF->VVF_FORPRO == "1"
		If ExistBlock("NFENTVEI")
			//Impressao da Nota Fiscal de Entrada
			ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_CODFOR,VVF->VVF_LOJA})
		Endif
	Endif
	//
	// Imprime termo de responsabilidade de multas do veiculo
	if GetNewPar("MV_RESPMUL","1") == "2"
		If ExistBlock("VA610MUL")
			ExecBlock("VA610MUL",.f.,.f.,{"2"})
		Endif
	Endif
EndIf
//

If cPaisLoc == "ARG" .and. xTpFatR == "5" // Remito Entrega Futura
	M->VVF_NUMNFI := Space(TamSx3("VVF_NUMNFI")[1])
	M->VVF_SERNFI := Space(TamSx3("VVF_SERNFI")[1])
EndIf

Return ! lErro
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000CANCEL | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Cancelamento de Nota Fiscal - Veiculos Normais                |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000CANCEL(cRotOrigem,lExcluiNF)
Local nCntFor
Local cNumTit
Local cDMSPrefOri := GetNewPar("MV_PREFVEI","VEI")
Local lMVBCRVEIU  := (GetNewPar("MV_BCRVEIU","S") == "S")
Local cAliasSE1   := "TSE1"
Local aUltMov     := {}
Local nRecSF4     := 0
Local nRecVV1     := 0
local cQVW0 := "TVW0"
Local lErro       := .F.
Local cChaveOri   := ""
Local cStrSE2     := ""
Local aCabNFE     := {}
Local aIteNFE     := {}
Local aInfo       := {}
Local lFound      := .t.
Local cNomeFunc   := ""

Default lExcluiNF := .t.

Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")

If VVF->VVF_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	MsgInfo(STR0101,STR0017) // Esta Entrada se trata de Mov.Interna. Impossivel continuar! / Atencao
	Return .f.
EndIf
If VVF->VVF_TIPDOC $ "3/4" .and. cPaisLoc == "BRA" // 3 = SIGAEIC - Nota Fiscal foi digitada no modulo de importacao / 4 = Mov. Interna de Produção - SIGAPCP
	lExcluiNF := .f.
EndIf
//
// VERIFICA SE A NF ESTA CANCELADA OU DEVOLVIDA
If VVF->VVF_SITNFI # "1"   // NF nao-valida
	FMX_HELP("VEIX000E08",STR0062 ) //Nota Fiscal esta cancelada ou devolvida # atencao
	lMsErroAuto := .t.
	Return .f.
EndIf
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ponto de Entrada para validacao do Cancelamento de NF |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VX000CNF")
	lRet := ExecBlock("VX000CNF",.f.,.f.)
	If !lRet
		lMsErroAuto := .t.
		Return.f.
	EndIf
EndIf
//
If VVF->VVF_TIPDOC $ "1/3"
	If !Empty(VVF->VVF_NUMNFI)
		DBSelectArea("SF1")
		DBSetOrder(1)
		If !dbSeek(xFilial("SF1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA)
			FMX_HELP("VEIX000E09", STR0144 +" SF1 - "+RetTitle("VVF_NUMNFI") ) // Registro não encontrado.
			lMsErroAuto := .t.
			Return .f.
		EndIf
		//
		dbSelectArea("SD1")
		dbSetOrder(1)
		If !dbSeek(xFilial("SD1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA)
			FMX_HELP("VEIX000E10", STR0144 +" SD1 - "+RetTitle("D1_ITEM") ) // Registro não encontrado.
			lMsErroAuto := .t.
			Return .f.
		EndIf
		// ARMAZENA A NF DE ORIGEM PARA ALTERAR STATUS DELA PARA
		// VALIDA CASO HAJA CANCELAMENTO (quando cX0OpeMov = "5")
		cChaveOri := SD1->D1_NFORI+SD1->D1_SERIORI
		//
		cStrSE2 := xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC
		//
	EndIf
	If cPaisLoc $ "ARG|MEX" .and. !Empty(VVF->VVF_REMITO) .and. lExcluiNF
		DBSelectArea("SF1")
		DBSetOrder(1)
		If !dbSeek(xFilial("SF1") + VVF->VVF_REMITO + VVF->VVF_SERREM + VVF->VVF_CODFOR + VVF->VVF_LOJA)
			FMX_HELP("VEIX000E21", STR0144 +" SF1 - "+RetTitle("VVF_REMITO") ) // Registro não encontrado.
			lMsErroAuto := .t.
			Return .f.
		EndIf
		//
		dbSelectArea("SD1")
		dbSetOrder(1)
		If !dbSeek(xFilial("SD1") + VVF->VVF_REMITO + VVF->VVF_SERREM + VVF->VVF_CODFOR + VVF->VVF_LOJA)
			FMX_HELP("VEIX000E22", STR0144 +" SD1 - "+RetTitle("D1_ITEMREM") ) // Registro não encontrado.
			lMsErroAuto := .t.
			Return .f.
		EndIf
		cChaveOri := SD1->D1_NFORI+SD1->D1_SERIORI
	ElseIf cPaisLoc $ "ARG|MEX" .and. !Empty(VVF->VVF_REMITO) .and. !lExcluiNF
		cChaveOri := VVF->VVF_REMITO + VVF->VVF_SERREM // Essa situação é que houve uma Devolução de uma Venda com Entrega Futura sem Remito
	EndIf
EndIf
//
// Se existir Frete para a NF a ser cancelada, deve-se excluir o Conhecimento para
// so depois cancelar a NF Entrada. Caso haja mais NF's referente ao Conhecimento,
// deve-se incluir novamente este Conhecimento para ratear novamente seu valor as
// NF's restantes
//
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// JANELA DE ABORTO
	If VX000ABORT()
		Return .f.
	EndIf
	//
	// VERIFICAR SE A MOVIMENTACAO SELECIONADA EH A ULTIMA
	//
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVG_CHASSI")], cRotOrigem + " - " + "VX000CANCEL_1")
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
	If !(FM_PILHA("VEIXA040"))
		aUltMov := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] , , )
		If len(aUltMov) > 0
			If aUltMov[1,1] == "S" .or. aUltMov[1,2] <> VVF->VVF_FILIAL .or. aUltMov[1,3] <> VVF->VVF_TRACPA
				FMX_HELP("VEIX000E11",;
					STR0027 + CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0064 + " " + STR0065 + CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0066 + ": "+Alltrim(VV1->VV1_CHASSI)) ////Impossivel continuar # Um dos veiculos constantes da nota fiscal sofreu movimentacao # posterior a sua emissao # Chassi # Atencao
				lMSErroAuto := .t.
				Return .f.
			EndIf
		EndIf
	EndIf
Next
//#################################################################
//# Montagem dos Itens para integracao MATA103                    #
//#################################################################
aIteNFE := {}
BEGIN TRANSACTION
//
DbSelectArea("VS9")
if cX0OpeMov == "0" .and. VS9->(FieldPos("VS9_PARCEL"))>0 .or. cDebugMIL == "VEIXX000BX"

	cQryAl001 := GetNextAlias()
	cQuery := "SELECT VS9.VS9_PARCEL, VS9.VS9_TIPPAG, VS9.VS9_NUMIDE, VS9.R_E_C_N_O_ VS9RECNO, VAZ.R_E_C_N_O_ VAZRECNO , VV0_NUMNFI , VV0_NUMTRA "
	cQuery +=  " FROM "+RetSqlName("VAZ")+" VAZ JOIN "+RetSqlName("VS9")+" VS9 ON VS9.VS9_FILIAL ='"+xFilial("VS9")+"' AND VS9.VS9_REFPAG = VAZ.VAZ_CODIGO AND VS9.D_E_L_E_T_=' ' "
	cQuery +=  " JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL = '"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA = VS9.VS9_NUMIDE AND VV0.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VAZ.VAZ_FILIAL ='"+xFilial("VAZ")+"'"
	cQuery +=   " AND VAZ.VAZ_TRACPA ='" + VVF->VVF_TRACPA + "'"
	cQuery +=   " AND VAZ.VAZ_FILENT ='" + VVF->VVF_FILIAL + "'"
	cQuery +=   " AND VAZ.D_E_L_E_T_ =' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	While !(cQryAl001)->(Eof())

		// Estorna a baixa do titulo referente ao veiculo usado utilizado em atendimento
		If lMVBCRVEIU .or. cDebugMIL == "VEIXX000BX"
			cNumTit := "V"+Right(( cQryAl001 )->( VV0_NUMTRA ),TamSx3("E1_NUM")[1]-1)
			If GetNewPar("MV_TITATEN","0") == "0" // Gera Titulo na Finalizacao
				If !Empty(( cQryAl001 )->( VV0_NUMNFI ))
					cNumTit := ( cQryAl001 )->( VV0_NUMNFI )
				EndIf
			EndIf

			cQuery := "SELECT E1_PREFIXO , E1_NUM , E1_PARCELA , E1_TIPO "
			cQuery +=  " FROM " + RetSQLName("SE1") + " SE1 "
			cQuery += " WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "'"
			cQuery +=   " AND SE1.E1_NUM='"+cNumTit+"'"
			cQuery +=   " AND SE1.E1_PREFORI='"+cDMSPrefOri+"'"
			cQuery +=   " AND SE1.E1_PARCELA='"+Alltrim((cQryAl001)->VS9_PARCEL)+"'"
			cQuery +=   " AND SE1.E1_TIPO='"+Alltrim((cQryAl001)->VS9_TIPPAG)+"'"
			cQuery +=   " AND SE1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSE1, .F., .T. )
			If !(cAliasSE1)->(Eof())
				aBaixa  := {;
					{"E1_PREFIXO"	,(cAliasSE1)->E1_PREFIXO	,Nil } ,;
					{"E1_NUM"		,(cAliasSE1)->E1_NUM		,Nil } ,;
					{"E1_PARCELA"	,(cAliasSE1)->E1_PARCELA	,Nil } ,;
					{"E1_TIPO"		,(cAliasSE1)->E1_TIPO	,Nil } ,;
					{"AUTMOTBX"		,"NOR"		,Nil } ,;
					{"AUTDTBAIXA"	,dDataBase	,Nil } ,;
					{"AUTDTCREDITO"	,dDataBase	,Nil }}
				//
				MSExecAuto({|x,y| FINA070(x,y)},aBaixa,5)
				//
				If lMsErroAuto .or. cDebugMIL == "VEIXX000BX"
					(cQryAl001)->(dbCloseArea())
					(cAliasSE1)->(dbCloseArea())
					dbSelectArea("VVF")
					DisarmTransaction()
					MostraErro()
					lErro := .T.
					break
				EndIf
			EndIf
			(cAliasSE1)->(dbCloseArea())
			//
			DBSelectArea("VS9")
			DBGoto((cQryAl001)->(VS9RECNO))
			reclock("VS9",.f.)
			VS9->VS9_DATBAI := ctod("00/00/00")
			msunlock()
			//
		EndIf // lMVBCRVEIU
		//

		DBSelectArea("VAZ")
		DBGoto((cQryAl001)->(VAZRECNO))
		reclock("VAZ",.f.)
		VAZ->VAZ_TRACPA := ""
		VAZ->VAZ_FILENT := ""
		msunlock()

		(cQryAl001)->(DBSkip())

	End
	(cQryAl001)->(dbCloseArea())
	dbSelectArea("VVF")

endif
//
if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
	//
	// Decrementa Localização
	//
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA)
	While !eof() .and. xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA == ;
		SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
		DBSelectArea("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+SD1->D1_COD)
		//
		DBSelectArea("SB5")
		DBSetOrder(1)
		DBSeek(xFilial("SB5")+SD1->D1_COD)
		//
		if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD + SB5->B5_LOCALI2)
			if VZL->VZL_QTDATU > 0
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU - 1
				msunlock()
			endif
		endif
		//
		DBSelectArea("SD1")
		DbSkip()
	enddo
	//
endif
If lExcluiNF
	//#############################################################################
	//# Montagem do cabecalho para integracao MATA103                             #
	//#############################################################################
	If !Empty(VVF->VVF_NUMNFI)
		AAdd(aInfo, { Alltrim(VVF->VVF_SERNFI) , Alltrim(VVF->VVF_NUMNFI) , STR0067} ) // "CANCELADO"
		aCabNFE := VX0000091_Carrega_Cabec_SF1( VVF->VVF_NUMNFI , VVF->VVF_SERNFI , VVF->VVF_CODFOR , VVF->VVF_LOJA )
		aIteNFE := VX0000101_Carrega_Itens_SD1( VVF->VVF_NUMNFI , VVF->VVF_SERNFI , VVF->VVF_CODFOR , VVF->VVF_LOJA )
	EndIf
	//
	lMsErroAuto := .f.
	If !(cPaisLoc == "BRA")
		If !Empty(VVF->VVF_NUMNFI)
			// É necessário que seja enviado para a integração o F1_TIPODOC
			aAdd(aCabNFE,{"F1_TIPODOC"	,SF1->F1_TIPODOC,Nil})
			cNomeFunc := FunName()
			SetFunName("MATA101N")
			MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabNFE,aIteNFE,5) // Exclui a Fatura
			SetFunName(cNomeFunc)
		EndIf
		If !lMsErroAuto .and. !Empty(VVF->VVF_REMITO)
			AAdd(aInfo, { Alltrim(VVF->VVF_SERREM) , Alltrim(VVF->VVF_REMITO) , STR0067} ) // "CANCELADO"
			aCabNFE := VX0000091_Carrega_Cabec_SF1( VVF->VVF_REMITO , VVF->VVF_SERREM , VVF->VVF_CODFOR , VVF->VVF_LOJA )
			aIteNFE := VX0000101_Carrega_Itens_SD1( VVF->VVF_REMITO , VVF->VVF_SERREM , VVF->VVF_CODFOR , VVF->VVF_LOJA )

			If cX0OpeMov $ "578" .And. cPaisLoc == 'ARG'
				Pergunte("PVXARG", .F.)
				MsExecAuto({ |v,w,x,y,z| LocxNf(v,w,x,y,z) }, Iif(VVF->VVF_FORPRO=="1", 51, 53), aCabNFE, aIteNFE, 5, "MATA462DN")
			Else
				aAdd(aCabNFE,{"F1_TIPODOC"	,SF1->F1_TIPODOC,Nil})
				MsExecAuto({|x,y,z| MATA102N(x,y,z) },aCabNFE,aIteNFE,5)
			EndIf
		EndIf
	Else
		MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIteNFE,5)
	EndIf
	//
	If lMsErroAuto
		DisarmTransaction()
		lErro := .T.
		break
	EndIf
EndIf
//
cTipoDP := Left("DP"+space(10),TamSX3("E2_TIPO")[1])
// Ponto de Entrada p/ excluir outros titulos
If ExistBlock("VM000EXC")
	ExecBlock("VM000EXC",.f.,.f.)
EndIf
//
If lExcluiNF .and. !Empty(cStrSE2)
	DBSelectArea("SE2")
	DBSetOrder(6)
	DBSeek(cStrSE2)
	//
	while !eof() .and.	cStrSE2 == SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
		// JANELA DE ABORTO
		If VX000ABORT()
			lErro := .T.
			break
		EndIf
		DBSelectArea("SE2")
		//
		aVetDesp := {}
		aAdd(aVetDesp,{"E2_PREFIXO"  ,SE2->E2_PREFIXO	,Nil})
		aAdd(aVetDesp,{"E2_NUM"      ,SE2->E2_NUM    	,Nil})
		aAdd(aVetDesp,{"E2_TIPO"     ,SE2->E2_TIPO		,Nil})
		aAdd(aVetDesp,{"E2_NATUREZ"  ,SE2->E2_NATUREZ	,Nil})
		aAdd(aVetDesp,{"E2_PARCELA"  ,SE2->E2_PARCELA	,Nil})
		aAdd(aVetDesp,{"E2_FORNECE"  ,SE2->E2_FORNECE	,Nil})
		aAdd(aVetDesp,{"E2_LOJA"     ,SE2->E2_LOJA		,Nil})
		aAdd(aVetDesp,{"E2_EMISSAO"  ,SE2->E2_EMISSAO	,Nil})
		aAdd(aVetDesp,{"E2_VENCTO"   ,SE2->E2_VENCTO	,Nil})
		aAdd(aVetDesp,{"E2_VALOR"    ,SE2->E2_VALOR		,Nil})
		aAdd(aVetDesp,{"E2_VLCRUZ"   ,SE2->E2_VLCRUZ	,Nil})
		//
		pergunte("FIN050",.F.)
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp,,5)
		If lMsErroAuto
			DisarmTransaction()
			lErro := .T.
			break
		EndIf
		dbSelectArea("SE2")
		dbskip()
	enddo
	//
EndIf
If VVG->(FieldPos("VVG_NUMPED"))>0
	dbSelectArea("VVG")
	dbSetOrder(1)
	dbGotop()
	If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
			cNumPed := VVG->VVG_NUMPED
			cItPed	:= VVG->VVG_ITPED
			if !Empty(cNumPed)
				//verifica se existe o pedido
				dbSelectArea("SC7")
				dbSetOrder(1)
				If dbSeek(xFilial("SC7")+cNumPed+cItPed)
					// Grava os dados na tabela SC7
					RecLock("SC7",.F.)
					//Se o pedido estiver encerrado, reabre o pedido
					If SC7->C7_QUANT == SC7->C7_QUJE
						SC7->C7_ENCER := "" //Reabre o pedido
					EndIf
					//
					If SC7->C7_QUJE > 0
						SC7->C7_QUJE := SC7->C7_QUJE - 1     //Sempre subtraio um pq no VVG cada item eh um registro
					EndIf
					MsUnLock()
				EndIf
			endif
			dbSelectArea("VVG")
			DbSkip()
		Enddo
	EndIf
endif
//
dbSelectArea("VVF")
RecLock("VVF",.f.)
VVF->VVF_SITNFI := "0"
MsUnlock()
//
if ( cX0OpeMov $ "5/7/8" .or. ( cX0OpeMov == "3" .and. Len(aAutoAux) > 0 ) ) .and. !Empty(cChaveOri) // DEVOLUCAO/ RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
	// ATUALIZA O STATUS DA NF DE "DEVOLVIDA" PARA "VALIDA"
	DBSelectArea("VV0")
	DBSetOrder(4)
	lFound := .t.
	if !DBSeek(xFilial("VV0")+cChaveOri) .and. cPaisLoc != "BRA"
		DbSetOrder(7)
		if !DBSeek(xFilial("VV0")+cChaveOri)
			lFound := .f.
		endif
	endif
	if lFound
		RecLock("VV0",.f.)
		VV0->VV0_SITNFI := "1"
		MsUnlock()
	endif
endif

if FWAliasInDic("VW0")
	cQuery := "SELECT R_E_C_N_O_ VW0RECNO FROM " + RetSQLName("VW0") + " VW0 WHERE VW0.VW0_FILENT = '" + VVF->VVF_FILIAL + "' AND VW0.VW0_TRACPA = '" + VVF->VVF_TRACPA + "' AND VW0.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQVW0, .F., .T. )
	While ! (cQVW0)->(Eof())

		VW0->(dbGoTo( (cQVW0)->VW0RECNO ) )
		reclock("VW0",.f.)
		VW0->VW0_STENT := "0"
		VW0->(MsUnlock())
		(cQVW0)->(dbSkip())
	end
	(cQVW0)->(DBCloseArea())
endif

// ATUALIZA STATUS DE IMOBILIZACAO DO VEICULO
dbSelectArea("VVG")
dbSetOrder(1)
dbGotop()
If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
	While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA

		nRecSF4 := FM_SQL("SELECT SF4.R_E_C_N_O_ FROM "+RetSqlName("SF4")+" SF4 WHERE  SF4.F4_FILIAL='"+xFilial("SF4")+"' AND  SF4.F4_CODIGO='"+VVG->VVG_CODTES+"' AND SF4.D_E_L_E_T_=' '")
		nRecVV1 := FM_SQL("SELECT VV1.R_E_C_N_O_ FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI='"+VVG->VVG_CHASSI+"' AND VV1.D_E_L_E_T_=' '")
		SF4->(DbGoTo(nRecSF4))
		VV1->(DbGoTo(nRecVV1))
		If ( Alltrim(SF4->F4_CF) == "1551" .or. SF4->F4_OPEMOV == "07" ) .and. VV1->VV1_IMOBI == "1"
			DbSelectArea("VV1")
			RecLock("VV1",.f.)
			VV1->VV1_IMOBI := "0" // Cancela Imobilização
			MsUnlock()
		Endif

		DbSelectArea("VVG")
		DbSkip()

	Enddo

Endif

// Movimentos gerados por integração com SIGAEIC e SIGAPCP serão deletados da base quando CANCELADOS
If VVF->VVF_TIPDOC $ "3/4"

	dbSelectArea("VVG")
	dbSetOrder(1)
	dbSeek(xFilial("VVG") + VVF->VVF_TRACPA )
	While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
		RecLock("VVG",.f.)
		VVG->(dbDelete())
		MsUnlock()
		dbSkip()
	End

	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	VVF->(dbDelete())
	MsUnlock()
EndIf

// ###############################################
// # FINAL DA TRANSACAO                          #
// ###############################################
End Transaction

if ! lErro
	// ###############################################
	// # ATUALIZA O STATUS DO VEICULO                #
	// ###############################################
	For nCntFor = 1 to len(acols)
		n = nCntFor
		// pula registros deletados
		If aCols[nCntFor,len(aHeader)+1]
			loop
		EndIf
		// ALTERA STATUS DOS VEICULOS
		FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVG_CHASSI")], cRotOrigem + " - " + "VX000CANCEL_2")
	Next
	//
	dbSelectArea("VVF")
	//
	If lExcluiNF
		if lMostraMsg .and. !lMsErroAuto
			FMX_TELAINF( "1" , aInfo )
		endif
	Else
		MsgInfo(STR0122) // "Movimento cancelado."
	EndIf
endif
Return ! lErro
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000DLIN   | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000DLIN(lValidVV1)
Default lValidVV1 := .t.
If lValidVV1
	If !Empty(aCols[n,FG_POSVAR("VVG_CHAINT")])
		VV1->(DbSetOrder(1))
		If VV1->(DbSeek(xFilial("VV1")+aCols[n,FG_POSVAR("VVG_CHAINT")]))
			If VV1->VV1_GRASEV == "6" // '6' = SEM CHASSI
				Return()
			EndIf
		EndIf
	EndIf
EndIf
//
If aCols[n,Len(aCols[n])]
	aCols[n,Len(aCols[n])] := .f.
Else
	aCols[n,Len(aCols[n])] := .t.
EndIf
//
If lAtuFiscal // Atualiza Fiscal
	MaFisDel(n,aCols[n,Len(aCols[n])])
EndIf
//
VX000FIELDOK()
//
oGetDados:obrowse:SetFocus()
//
Return()
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000KEYF4  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Chamada da tecla de atalho <F4>. Executa comandos dependen-  |##
##|Descri‡„o | do do campo selecionado ( ReadVar() ).                       |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000KEYF4()
//
If ReadVar() == "M->VVG_CHASSI"
	DBSelectArea("VV1")
	DBSetOrder(2)
	If DBSeek(xFilial("VV1")+M->VVG_CHASSI)
		//VXA010A("VV1",RecNo(),3)
		VA0700113_AlteracaoChassi()
	EndIf
EndIf
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000ABORT  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Janela de aborto. Podera ser chamada apenas dentro de tran-  |##
##|          | sacoes. Exibe uma mensagem e seta o lMsErroAuto para .t.     |##
##|          | caso o usuario tenha optado por abortar a operacao           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000ABORT()
//
If lAbortPrint
	//"Tem certeza que deseja abortar esta operacao ?", STR0017
	If MsgYesNo(STR0068,STR0017)//Tem certeza que deseja abortar esta operacao ?","Atencao
		Help("  ",1,"M160PROABO")
		DisarmTransaction()
		lMSErroAuto := .t.
		Return .t.
	Else
		lAbortPrint := .F.
	EndIf
EndIf
//
Return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000BRWNOME| Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Browse do Nome do Cliente/Fornecedor - Depependendo do tipo  |##
##|          | de operacao a funcao retorna o cliente ou o fornecedor.      |##
##|          | As operacoes de remessa, consignacao e devolucao tomam o     |##
##|          | cliente ao inves do fornecedor. As demais utilizam o forne-  |##
##|          | cedor (padrao).                                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000BRWNOME()
Local cAlias := Alias()
Local nRecSA1 := SA1->(RecNo())
Local nRecSA2 := SA2->(RecNo())
Local cNome   := ""
if !Empty(VVF->VVF_CLIFOR)
	If VVF->VVF_CLIFOR == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		DBSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
		cNome :=  SA1->A1_NREDUZ
	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		DBSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
		cNome :=  SA2->A2_NREDUZ
	EndIf
Endif
//
SA1->(DBGoTo(nRecSA1))
SA1->(DBGoTo(nRecSA2))
//
DBSelectArea(cAlias)
//
Return cNome
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000BRWNOME| Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Browse do Nome do Cliente/Fornecedor - Depependendo do tipo  |##
##|          | de operacao a funcao retorna o cliente ou o fornecedor.      |##
##|          | As operacoes de remessa, consignacao e devolucao tomam o     |##
##|          | cliente ao inves do fornecedor. As demais utilizam o forne-  |##
##|          | cedor (padrao).                                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000ATUF1(cCampo)
Local cVar1, cVar2
Local nCntFor
Local cRatDesp := GetMv("MV_RATDESP")
Local cTipo    := "0" // 0=Qtde Default - Rateio por: 1=Valor / 2=Peso
Local nAux     := 0
Local nTot     := 0
Local aTot     := {}
Local cObj     := ""

Default cCampo := "DESPESA"

If cCampo == "DESPESA"
	// DESPESA
	cVar1 := "DESPESA"
	cVar2 := "DESACE"
	cTipo := SubStr(cRatDesp,At("DESP=",cRatDesp)+5,1)
Else
	// FRETE
	cVar1 := "FRETE"
	cVar2 := "TOTFRE"
	cTipo := SubStr(cRatDesp,At("FR=",cRatDesp)+3,1)
	If ValType(oGetE101) == "O" // Existe o Objeto
		cObj  := "oGetE101" // Necessario para refresh na tela - Total Frete
	EndIf
EndIf

If lAtuFiscal .and. MaFisFound('NF') // Atualiza Fiscal

	If ReadVar() == "M->VVG_DESACE" // nao deixa alterar o campo de despesa
		M->VVG_DESACE := aCols[n,FG_POSVAR("VVG_DESACE")]
		MaFisRef("IT_DESPESA","VVG00", M->VVG_DESACE ) // Volta - Não Altera a Despesa, pois ela é calculada novamente no MATA103
	EndIf

	if ReadVar() <> "M->VVG_TOTFRE"

		for nCntFor := 1 to Len(aCols) // Totalizar variaveis para calculo proporcional
			nAux := 0
			// pula itens deletados
			if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
				Do Case
					Case cTipo == "1" // Valor
						nAux := aCols[nCntFor,FG_POSVAR("VVG_VALUNI")]
					Case cTipo == "2" // Peso
						FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
						nAux := SB1->B1_PESBRU
					OtherWise
						nAux := 1
				EndCase
			EndIf
			nTot += nAux
			aAdd(aTot,{nAux,0})
		Next
		For nCntFor := 1 to Len(aTot)
			aTot[nCntFor,2] := (aTot[nCntFor,1]/nTot) // indice para % correspondente
		Next

		If ReadVar() == "M->VVF_TOTFRE"
			nAnt := n
			for nCntFor := 1 to Len(aCols)
				// pula itens deletados
				if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
					n := nCntFor
					MaFisRef("IT_"+cVar1,"VVG00",&("M->VVF_"+cVar2)*aTot[nCntFor,2])
				endif
			next
			n := nAnt
		EndIf

	Else // Recalcula o TOTAL do Frete na cabeca da NF
		&("M->VVF_"+cVar2) := 0
		nTot := &("M->VVG_"+cVar2)
		for nCntFor := 1 to Len(aCols)
			// pula itens deletados
			if n <> nCntFor .and. !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
				nTot += aCols[nCntFor,FG_POSVAR("VVG_"+cVar2)]
			EndIf
		next
		&("M->VVF_"+cVar2) := nTot
		If !Empty(cObj)
			&(cObj+":Refresh()") // Necessario para refresh na tela - Total
		EndIf
	EndIf

	If &("M->VVF_"+cVar2) > 0
		MaFisAlt("NF_"+cVar1,&("M->VVF_"+cVar2))
	EndIf
	if cPaisLoc $ "ARG|MEX"
		aOrc := VX0000063_ResumoImpostosArgentina()
	else
		for nCntFor := 1 to Len(aOrc)
			aOrc[nCntFor,3] := &(aOrc[nCntFor,1])
		next
	endif
	If ReadVar() == "M->VVF_TOTFRE"
		for nCntFor := 1 to Len(aCols)
			// pula itens deletados
			if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
				&("M->VVG_"+cVar2) := aCols[nCntFor,FG_POSVAR("VVG_"+cVar2)] := MaFisRet(nCntFor,"IT_"+cVar1)
			endif
		next
	Endif
	If !lVX000Auto
		oGetDados:oBrowse:refresh()
		olBox:nAt := 1
		olBox:SetArray(aOrc)
		olBox:bLine := { || { aOrc[olBox:nAt,2],;
			FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
		olBox:Refresh()
	EndIf
EndIf
return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  VX000RB1  | Autor |  Luis Delorme         | Data | 12/11/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para trigeer do tes inteligente (ver sx7)             |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000RB1()
	FGX_VV1SB1("CHAINT", M->VVG_CHAINT , /* cMVMIL0010 */ , /* cGruVei */ )
return SB1->B1_COD

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VXVlChvNfe  | Autor |  Manoel               | Data | 01/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para chamada da a103ConsNfeSef()                      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VXVlChvNfe(cPar01,cPar02)

Local lRet := .f.
Local lSlv103Auto

Private cFormul  := ""
Private cEspecie := ""

If cPar01 == "0" // Formulario Proprio = Nao
	cFormul := "N"
Endif
cEspecie := cPar02 // Especie da NF

//lSlv103Auto	:= IIF(l103Auto==NIL,.f.,l103Auto)
lSlv103Auto	:= IIF(Type("l103Auto")=="U",.f.,l103Auto)
l103Auto := .f.
lRet := a103ConsNfeSef()
l103Auto := lSlv103Auto

Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000VLD    | Autor |  Luis Delorme         | Data | 30/01/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Função de Validação para compatibilidade com VM000VLD        |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000VLD()

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ VX000Help    ºAutor  ³Thiago           º Data ³  20/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Função para exibir os Helps do campo VVF_CHVNFE ao finalizarº±±
±±            o documento de entrada                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³                                               		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000Help(cFormul,cEspecie)

Local lDigChv := GetNewPar("MV_DCHVNFE",.F.)
Local lRetorno := .T.
cFormul := Iif(cFormul == "1","S","N")

DbselectArea("SX3")
DbSetOrder(2)

If lDigChv
	If VVF->(FieldPos("VVF_CHVNFE"))>0
		If (cFormul == "N" .and. AllTrim(cEspecie) == "SPED") .or. (cFormul == "N" .and. AllTrim(cEspecie) == "CTE")
			If Empty(M->VVF_CHVNFE)
				Help(" ",1,"DCHVNFE")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX000CLIFORºAutor  ³Thiago              º Data ³  10/04/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do campo VVF_CLIFOR.							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 11                                              		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000CLIFOR()

If !(FM_PILHA("VEIXA006")) .and. !(FM_PILHA("VEIXA007"))  .and. !(FM_PILHA("VEIXA008")) .and. !(FM_PILHA("VEIXA002")) .and. !(FM_PILHA("VEIXA004")) .and. !(FM_PILHA("VEIXA040")) .and. !(FM_PILHA("VEIVM006"))
	If ReadVar() == "M->VVF_CLIFOR"
		If !Empty(M->VVF_CLIFOR)
			cCliForA := M->VVF_CLIFOR
		Endif
	Endif

	If ! lVX000Auto
		if cCliForA == "C" //cOpeMov $ "35" .and. cCliForA == "C"
			oSayE34:lVisible := .f.
			oSayE21:lVisible := .t.
			oGetE21:cf3 := "SA1"
		Else
			oSayE21:lVisible := .f.
			oSayE34:lVisible := .t.
			oGetE21:cf3 := "FOR"
		Endif
	EndIf
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX000RDVForºAutor  ³Thiago/Manoel         Data ³  12/06/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Força o ReadVar quando chamada pelo IMPXML				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000RDVFOR()
Local nCntFor  := 0
Local nCntFor2 := 0

If lImpXML
	// Faz o get Automático do Fornecedor/Loja e Nota Fiscal e Série quando utilizado o IMPXMLV
	__ReadVar := "M->VVF_CODFOR"
	VX000VLDENC()
	__ReadVar := "M->VVF_LOJA"
	VX000VLDENC()
	__ReadVar := "M->VVF_NUMNFI"
	VX000VLDENC()
	__ReadVar := "M->VVF_SERNFI"
	VX000VLDENC()
	__ReadVar := "M->VVF_FORPAG"
	VX000VLDENC()

	Do Case
		Case FM_PILHA("U_IMPXMLV")
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			// SETA VARIAVEL FISCAL
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_TES","VVG00",M->VVG_CODTES)
			EndIf
			// Faz o get Automático dos campos da GetDados quando utilizado o IMPXMLV
			__ReadVar := "M->VVG_CHASSI"
			VX000FIELDOK()
		
		Case FM_PILHA("U_IXMLVJD")

			For nCntFor := 1 to len(aColsV)
				For nCntFor2:=1 to len(aHeaderV)
					&("M->"+aHeaderV[nCntFor2,2]) := aColsV[nCntFor,nCntFor2]
				Next
				VV1->(DbSetOrder(1))
				VV1->(DbSeek(xFilial("VV1")+M->VVG_CHAINT))
				FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
				// SETA VARIAVEL FISCAL
				If lAtuFiscal // Atualiza Fiscal
					n := nCntFor
					MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
					MaFisRef("IT_PRCUNI" ,"VVG00",M->VVG_VALUNI)
					MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
					MaFisRef("IT_TES"    ,"VVG00",M->VVG_CODTES)
					MaFisRef("IT_BASEICM","VVG00",M->VVG_VBAICM)
					MaFisRef("IT_ALIQICM","VVG00",M->VVG_ALIICM)
					MaFisRef("IT_VALICM" ,"VVG00",M->VVG_ICMCOM)
					MaFisRef("IT_ALIQCOF","VVG00",M->VVG_ALICOF)
					MaFisRef("IT_ALIQPIS","VVG00",M->VVG_ALIPIS)
					MaFisRef("IT_BASEIPI","VVG00",M->VVG_VBAIPI)
					MaFisRef("IT_ALIQIPI","VVG00",M->VVG_ALIIPI)
					MaFisRef("IT_VALIPI" ,"VVG00",M->VVG_VALIPI)
				EndIf
				// Faz o get Automático dos campos da GetDados quando utilizado o IMPXMLV
				__ReadVar := "M->VVG_CHASSI"
				VX000FIELDOK()
			Next
			
	EndCase

Endif

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX000IAMS rºAutor  ³   Manoel             Data ³  27/06/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Insere AMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000IAMS()
Local cQuery     := ""
Local cAlVV1     := "SQLVV1"
Local nCntFor    := 0
Local nForX3     := 0
Local aVeicAms   := {}
Local aIntCab    := {}
Local aIntIte    := {}
Local aRet       := {}
Local _aVRetVIS  := {}
Local lOpcDisp   := .f.
Local cTxtAMS    := GetNewPar("MV_MIL0106","AMS") // Nome Padrao: "AMS"
//
// HABILITA DIGITACAO DOS ITENS CASO A ROTINA NAO SEJA AUTOMATICA
If !lVX000Auto .and. !lImpXml
	If lAtuFiscal // Atualiza Fiscal
		If MaFisFound('NF')
			lOpcDisp := .t. // Habilitar opção caso iniciou o Fiscal
		EndIf
	EndIf
EndIf
If !lOpcDisp // Se opção NAO esta disponivel ainda
	If !lVX000Auto .and. !lImpXml
		MsgAlert(STR0103,STR0017) // Favor preencher os Dados da Entrada por Compra. / Atenção
	EndIf
	Return
EndIf
//
aRet := {}
aParamBox := {}
aAdd(aParamBox,{2,cTxtAMS,STR0104,{STR0104,STR0105},70,"",.f.,".t."}) // Existentes / Existentes / Novos
aAdd(aParamBox,{1,RetTitle("VVG_OPER")  ,Space(TamSX3("VVG_OPER")[1]),"@!","Existcpo('SX5','DJ'+MV_Par02)" ,"DJ ","",0,.f.})
//
If !ParamBox(aParamBox,STR0106+" "+cTxtAMS,@aRet,,,,,,,,.f.) // Incluir
	Return
EndIf
M->VVG_OPER := aRet[2]
If aRet[1] == STR0105 // Novos
	//
	aVeicAms := VXA010IAMS()
	If ValType(aVeicAms) == "A"
		If Len(aVeicAms) == 0
			Return
		Endif
	Else
		Return
	Endif
	For nCntFor := 1 to len(aVeicAms)
		aAdd(_aVRetVIS,{ .t. , aVeicAms[nCntFor,1] , aVeicAms[nCntFor,2] ,aVeicAms[nCntFor,3] , aVeicAms[nCntFor,4] })
	Next
	//
Else
	//
	cQuery := "SELECT VV1_CHAINT, VV1_CHASSI , VV1_CODMAR , VV1_MODVEI "
	cQuery += "FROM "+RetSqlName("VV1")+" "
	cQuery += "WHERE VV1_FILIAL = '"+xFilial("VV1")+"' AND "
	cQuery += "VV1_GRASEV = '6' AND "
	cQuery += "VV1_FILENT = ' ' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VV1_CHASSI"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlVV1, .F., .T. )
	While !( cAlVV1 )->( Eof() )
		aAdd(aIntIte,{ ( cAlVV1 )->( VV1_CHAINT ) , ( cAlVV1 )->( VV1_CHASSI ) , ( cAlVV1 )->( VV1_CODMAR )  , ( cAlVV1 )->( VV1_MODVEI ) })
		( cAlVV1 )->( DBSkip() )
	EndDo
	( cAlVV1 )->( dbCloseArea() )
	DbSelectArea("VV1")
	//
	aAdd(aIntCab,{ RetTitle("VV1_CHAINT"), "C" ,  40 , "@!" })
	aAdd(aIntCab,{ RetTitle("VV1_CHASSI"), "C" ,  80 , "@!" })
	aAdd(aIntCab,{ RetTitle("VV1_CODMAR"), "C" ,  25 , "@!" })
	aAdd(aIntCab,{ RetTitle("VV1_MODVEI"), "C" , 150 , "@!" })
	//
	FGX_VISINT( cCadastro , cTxtAMS+" - "+aRet[1] , aIntCab , aIntIte , .t., @_aVRetVIS ) //
	//
EndIf
//
For nCntFor := 1 to Len(_aVRetVIS)
	//
	If _aVRetVIS[nCntFor,1] .and. ascan(aCols,{|x| x[FG_POSVAR("VVG_CHAINT")] == _aVRetVIS[nCntFor,2] }) == 0 // CHAINT NAO DIGITADO
		//
		DbSelectArea("VV1")
		DbSetOrder(1)
		If DbSeek(xFilial("VV1")+_aVRetVIS[nCntFor,2])
			VV1->(DbSetOrder(2))
			//
			If !Empty(aCols[len(aCols),FG_POSVAR("VVG_CHAINT")])
				aAdd(aCols,Array(nUsadoV+1))
			EndIf
			n := nLin := Len(aCols)
			aCols[nLin,nUsadoV+1] := .F.
			//
			DBSelectArea("SB1")
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			DBSetOrder(1)
			cTESEnt := SB1->B1_TE
			For nForX3 := 1 to nUsadoV
				aCols[nLin,nForX3] := CriaVar(aHeaderV[nForX3,2])
			Next
			//
			aCols[nLin,FG_POSVAR("VVG_CHASSI","aHeaderV")] := M->VVG_CHASSI := VV1->VV1_CHASSI
			aCols[nLin,FG_POSVAR("VVG_CHAINT","aHeaderV")] := M->VVG_CHAINT := VV1->VV1_CHAINT
			aCols[nLin,FG_POSVAR("VVG_ESTVEI","aHeaderV")] := M->VVG_ESTVEI := VV1->VV1_ESTVEI
			aCols[nLin,FG_POSVAR("VVG_OPER"  ,"aHeaderV")] := M->VVG_OPER   := aRet[2]
			aCols[nLin,FG_POSVAR("VVG_LOCPAD","aHeaderV")] := M->VVG_LOCPAD := VV1->VV1_LOCPAD
			aCols[nLin,FG_POSVAR("VVG_CODORI","aHeaderV")] := M->VVG_CODORI := VV1->VV1_CODORI
			//aCols[nLin,FG_POSVAR("VVG_SITTRI","aHeaderV")] := M->VVG_SITTRI := IIF(VV1->VV1_PROVEI=="1","0","1") - debito tecnico
			aCols[nLin,FG_POSVAR("VVG_VALUNI","aHeaderV")] := M->VVG_VALUNI := VV1->VV1_SUGVDA
			//
			MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
			MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
			MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
			//
			__ReadVar := "M->VVG_OPER"
			VX000FIELDOK()
			If Empty(aRet[2])
				aCols[nLin,FG_POSVAR("VVG_CODTES","aHeaderV")] := M->VVG_CODTES := cTESEnt
			EndIf
			MaFisRef("IT_TES","VVG00",M->VVG_CODTES)
			//
			__ReadVar := "M->VVG_CHASSI"
			VX000FIELDOK()
			//
		Endif
		//
	Endif
	//
Next
//
oGetDados:oBrowse:Refresh()
//
Return



Function VX000POSVVF(aAutoCab)
	Local nRecRet := 0

	nPosNUMTRA := aScan(aAutoCab, { |x| x[1] == "VVF_NUMTRA"})
	If nPosNUMTRA <> 0
		VVF->(dbSetOrder(1))
		If !VVF->(dbSeek(xFilial("VVF") + aAutoCab[nPosNUMTRA,2]))
			FMX_HELP("REGNOIS",STR0123) // "Movimento de entrada não encontrado."
			Return nRecRet
		EndIf
		Return VVF->(Recno())
	EndIf

	nPosNUMNFI := aScan(aAutoCab, { |x| x[1] == "VVF_NUMNFI" })
	If nPosNUMNFI <> 0
		nPosSERNFI := aScan(aAutoCab, { |x| x[1] == "VVF_SERNFI" })
		nPosCODFOR := aScan(aAutoCab, { |x| x[1] == "VVF_CODFOR" })
		nPosLOJA   := aScan(aAutoCab, { |x| x[1] == "VVF_LOJA"   })

		cSQL := " FROM " + RetSQLName("VVF") + " VVF " +;
				" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
					" AND VVF.VVF_CODFOR = '" + aAutoCab[ nPosCODFOR , 2 ] + "'" +;
					" AND VVF.VVF_LOJA   = '" + aAutoCab[ nPosLOJA   , 2 ] + "'" +;
					" AND VVF.VVF_NUMNFI = '" + aAutoCab[ nPosNUMNFI , 2 ] + "'" +;
					" AND VVF.VVF_SERNFI = '" + aAutoCab[ nPosSERNFI , 2 ] + "'" +;
					" AND VVF.D_E_L_E_T_ = ' '"
		nRecRet := FM_SQL("SELECT R_E_C_N_O_ VVFRECNO " + cSQL + " AND VVF.VVF_SITNFI = '1' ")
		If nRecRet <> 0
			Return nRecRet
		EndIf

		If FM_SQL("SELECT COUNT(*) " + cSQL + " AND VVF.VVF_SITNFI <> '1' ") > 0
			FMX_HELP("VEIX000E13",STR0124) // "Nota fiscal não está válida para permitir o cancelamento do movimento de entrada."
			Return nRecRet
		Endif

		If FM_SQL("SELECT COUNT(*) " + cSQL) == 0
			FMX_HELP("REGNOIS",STR0125) // "Nota Fiscal não encontrada na tabela de Movimento de Entrada de Veículos."
			Return nRecRet
		EndIf
	EndIf

	
	nPosNUMOP := aScan(aAutoCab, { |x| x[1] == "VVF_NUMOP" })
	If nPosNUMOP <> 0

		cSQL := " FROM " + RetSQLName("VVF") + " VVF " +;
				" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
					" AND VVF.VVF_NUMOP = '" + aAutoCab[ nPosNUMOP , 2 ] + "'" +;
					" AND VVF.D_E_L_E_T_ = ' ' "

		nRecRet := FM_SQL("SELECT R_E_C_N_O_ VVFRECNO " + cSQL + " AND VVF.VVF_SITNFI = '1' ")
		If nRecRet <> 0
			Return nRecRet
		EndIf

		If FM_SQL("SELECT COUNT(*) " + cSQL + " AND VVF.VVF_SITNFI <> '1' ") > 0
			FMX_HELP("VEIX000E17",STR0126) // "Movimento de produção não está válido para permitir o cancelamento do movimento de entrada."
			Return nRecRet
		Endif

		If FM_SQL("SELECT COUNT(*) " + cSQL) == 0
			FMX_HELP("REGNOIS",STR0127) // "Movimento de produção não encontrado na tabela de Movimento de Entrada de Veículos."
			Return nRecRet
		EndIf
	EndIf

	FMX_HELP("VEIX000E12",STR0128, STR0129 ) // "Movimento de entrada não pode ser encontrado.","Modifique a chave de pesquisa."

Return nRecRet
/*/{Protheus.doc} VX0000016_LoadMoeda
Atualiza Taxa da Moeda
@author Fernando Vitor Cavani
@since 24/10/2018
@version undefined
@type function
/*/
Static Function VX0000016_LoadMoeda()
nMoedaCor  := VVF->VVF_MOEDA
nTaxaMoeda := VVF->VVF_TXMOED
Return

/*/{Protheus.doc} VX0000026_AtualizaTaxa
Atualiza Taxa da Moeda
@author Fernando Vitor Cavani
@since 24/10/2018
@version undefined
@param oMoeda    , objeto, Moeda
@param oTaxaMoeda, objeto, Taxa Moeda
@param oSayMoeda , objeto, Descrição Moeda
@type function
/*/
Static Function VX0000026_AtualizaTaxa(oMoeda, oTaxaMoeda, oSayMoeda)
Local cMoeda := ""
Local cCampo := ReadVar()

cMoeda := SuperGetMv("MV_MOEDA" + AllTrim(Str(nMoedaCor, 2)))

If nMoedaCor <> 1
	If !"NTAXA" $ Upper(cCampo)
		If nTaxaMoeda <> 0
			MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
		EndIf

		If nTaxaMoeda == 0
			nTaxaMoeda := MaFisRet(, "NF_TXMOEDA")
		EndIf

		If nTaxaMoeda == 0
			nTaxaMoeda := xMoeda(1, nMoedaCor, MaFisRet(, "NF_MOEDA"), M->VVF_DATEMI, TamSx3("VVF_TXMOED")[2])
			MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
		EndIf

		If ("NMOEDA"$Upper(cCampo))
			nTaxaMoeda := RecMoeda(M->VVF_DATEMI, nMoedaCor)
			MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
		EndIf
	Else
		MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
	EndIf
Else
	nTaxaMoeda := 1
	MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
EndIf

// Atualizar Como Pagar
VX000ATUCP()

If oMoeda <> Nil
	oMoeda:Refresh()
EndIf

If oTaxaMoeda <> Nil
	oTaxaMoeda:lReadOnly := IIF((INCLUI .Or. ALTERA) .And. nMoedaCor <> 1, .f., .t.)
	oTaxaMoeda:Refresh()
EndIf

If oSayMoeda <> Nil
	If nMoedaCor == 1
		cMoeda := RetTitle("VVF_MOEDA")
	EndIf
	oSayMoeda:SetText(cMoeda)
EndIf
If cPaisLoc <> "BRA"
	If aMoedaOld[1] <> nMoedaCor .or. (nMoedaCor <> 1 .and. aMoedaOld[2] <> nTaxaMoeda)
		aMoedaOld[1] := nMoedaCor
		aMoedaOld[2] := nTaxaMoeda
		aCols := Aclone(aMoedaOld[3])
		N := 1
		FG_MEMVAR(aHeader, aCols, N) // Cria a partir de um aheader/acols variaveis de memoria
		oGetDados:oBrowse:Refresh()
		If PARxTIPDOC == "1" .OR. lAtuFiscal // 1=NF / 2=SD3 (Mov.Internas)
			MaFisEnd()
			__ReadVar := "M->VVF_LOJA"
			VX000VLDENC() // Rotina de validacao da ENCHOICE
		EndIf
		VX000ATUCP() // Atualizar Como Pagar
	EndIf
EndIf
Return

/*/{Protheus.doc} VX0010093_ResumoImpostosArgentina
	Resumo impostos Argentina

@type function
@author Andre Luis Almeida
@since 15/07/2024
/*/
Function VX0000063_ResumoImpostosArgentina()
	Local aRelImpostos
	Local nCntFor
	local xValor
	Local aRetResImp

	aRelImpostos := MaFisRodape(;
		1 /* nTipo */   , /* oJanela */   , /* aImpostos */ , /* aPosicao */  , /* bValidPrg */ , /* lVisual */   , /* cFornIss */  ,;
		/* cLojaIss */  , /* aRecSE2 */   , /* cDirf */     , /* cCodRet */   , /* oCodRet */   , /* nCombo */    , /* oCombo */    ,;
		/* dVencIss */  , /* aCodR */     , /* cRecIss */   , /* oRecIss */   , /* lEditImp */  , /* cDescri */   , .t. /* lAPI */  )

	aRetResImp := {}
	for nCntFor := 1 to Len(aOrcDynHeader)
		xValor := &(aOrcDynHeader[nCntFor,1])
		AAdd(aRetResImp, {'', aOrcDynHeader[nCntFor,2], xValor, '' })
	next

	for nCntFor := 1 to Len(aRelImpostos)
		if ! empty(aRelImpostos[nCntFor,6])
			xValor := &('MaFisRet(,"NF_VAL' + aRelImpostos[nCntFor,6] + '")')
			AAdd(aRetResImp, {'', aRelImpostos[nCntFor,2], xValor, '' })
		endif
	next nCntFor

	for nCntFor := 1 to Len(aOrcDynFooter)
		xValor := &(aOrcDynFooter[nCntFor,1])
		AAdd(aRetResImp, {'', aOrcDynFooter[nCntFor,2], xValor, '' })
	next

return aClone(aRetResImp)

/*/{Protheus.doc} VX0000036_AtualizaValorPelaMoedaETaxaMoeda
Atualiza Valor caso houve mudança da Moeda e Taxa da Moeda
@author Fernando Vitor Cavani
@since 28/12/2018
@version undefined
@return nValor, numérico, Valor Total
@type function
/*/
Static Function VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
Local nValor := MaFisRet(,"NF_BASEDUP")

If nValor > 0 .And. lMoeda .And. cPaisLoc == "BRA"
	If nMoedaCor <> 1 .And. nTaxaMoeda > 0
		nValor := Round(xMoeda(nValor, MaFisRet(,"NF_MOEDA"), nMoedaCor, VVF->VVF_DATEMI, Nil, Nil, nTaxaMoeda), 2)
	EndIf
EndIf
Return nValor

/*/{Protheus.doc} VX0000041_CarregaDefaultCamposCustomizadosParcelas
SOMENTE para ENTRADA POR COMPRA - Carrega Valor Default dos Campos Customizados das Parcelas aIteParc
@author Andre Luis Almeida
@since 03/06/2019
@version undefined
@type function
/*/
Static Function VX0000041_CarregaDefaultCamposCustomizadosParcelas(nLinha)
Local nCntFor  := 0
Default nLinha := 1
If (FM_PILHA("VEIXA001")) // Somente Entrada de Veiculos por Compra
	For nCntFor := 1 to len(aParcCust)
		aAdd(aIteParc[nLinha,3],aParcCust[nCntFor,6])
	Next
EndIf
Return

/*/{Protheus.doc} VX0000053_AtualizaVV1
	Atualiza VV1

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Static Function VX0000053_AtualizaVV1()

	local aFldVV1 := {}
	local oVV1_AtVeiAMov
	local aAreaSA1 := SA1->(getArea())

	// 0=Normal
	// 1=Ped.Fabrica
	// 3=Transferencia
	// 5=Devolucao
	If cX0OpeMov $ "0135" // COMPRAS, TRANSFERENC e DEVOLUCAO
		
		//if VV1->VV1_PROATU == SA1->A1_COD
		//else
		//	AADD( aFldVV1 , { "VV1_PROATU" , SA1->A1_COD } )
		//endif
//
		//if VV1->VV1_LJPATU == SA1->A1_LOJA
		//else
		//	AADD( aFldVV1 , { "VV1_LJPATU" , SA1->A1_LOJA } )
		//endif
//
		//if VV1->VV1_DOCIND == SA1->A1_CGC
		//else
		//	AADD( aFldVV1 , { "VV1_DOCIND" , SA1->A1_CGC } )
		//endif

		if VV1->VV1_ESTVEI == VVG->VVG_ESTVEI
		else
			AADD( aFldVV1 , { "VV1_ESTVEI" , VVG->VVG_ESTVEI } )
		endif

	EndIf

	// VEICULO JA VENDIDO E ESTA REALIZANDO UMA ENTRADA POR COMPRA OU POR DEVOLUCAO
	// 0=Normal
	// 5=Devolucao
	If VV1->VV1_SITVEI == "1" .and. cX0OpeMov $ "05" 
		if VV1->VV1_RESERV <> "0" .and. ! empty(VV1->VV1_RESERV)
			AADD( aFldVV1 , { "VV1_RESERV" , "0" } )
		endif
		//AADD( aFldVV1 , { "VV1_HORRES" ,  stod("00000000") } )
		//AADD( aFldVV1 , { "VV1_HORVEN" ,  stod("00000000") } )
	EndIf

	if VV1->VV1_LOCPAD == VVG->VVG_LOCPAD
	else
		AADD( aFldVV1 , { "VV1_LOCPAD" , VVG->VVG_LOCPAD } )
	endif

	if len(aFldVV1) == 0
		conout("VX0000053_AtualizaVV1 -> Nao eh necessaria alteracao do veiculo - " + vv1->VV1_CHASSI)
		return
	endif

	oVV1_AtVeiAMov := FWLoadModel( 'VEIA070' )
	lRetMVCAuto := FwMvcRotAuto(oVV1_AtVeiAMov,"VV1",4,{ {"MODEL_VV1",aFldVV1} },/*lSeek*/ .f. ,.f.)
	if ! lRetMVCAuto
		MostraErro()
	endif
	oVV1_AtVeiAMov:DeActivate()
	
	restArea(aAreaSA1)
Return

/*/{Protheus.doc} VX0000073_AtuVV1SitVei
	Atualiza Sitvei do veiculo

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Function VX0000073_AtuVV1SitVei(cSitVei)

	local oVV1_AtVeiAMov
	local aAreaSA1 := SA1->(getArea())

	oVV1_AtVeiAMov := FWLoadModel( 'VEIA070' )
	lRetMVCAuto := FwMvcRotAuto(oVV1_AtVeiAMov,"VV1",4,{ {"MODEL_VV1",{{"VV1_SITVEI",cSitVei}}} },/*lSeek*/ .f. ,.f.)
	if ! lRetMVCAuto
		MostraErro()
	endif
	oVV1_AtVeiAMov:DeActivate()
	restArea(aAreaSA1)

Return

/*/{Protheus.doc} VX0000055_A143GeraNF


cTipoNFE - Tipo de Geração (5-FOB/6-Flete/7-Seguro/8-CIF/9-DUA/A-Gastos)
lGerou - Indicação de geração da Nota fiscal de entrada
cF1DOC - Número da Nota Fiscal
cF1SERIE - Código da Série da NF
cF1FORNECE - Código do Fornecedor da NF
cF1LOJA - Código da Loja da NF

@author Renato Vinicius
@since 10/05/2024
@version undefined
@type function
/*/
Function VX0000055_A143GeraNF(cTipoNFE,lGerou,cF1DOC,cF1SERIE,cF1FORNECE,cF1LOJA)

	Local xAutoCab := {} // Campos Cabecalho
	Local xAutoItens := {} // Campos Itens
	Local xAutoIt := {}
	Local aItem   := {}

	If cTipoNFE == "5" .and. lGerou

		SF1->(dbSetOrder(1))
		If !SF1->(dbSeek(xFilial("SF1") + cF1DOC + cF1SERIE + cF1FORNECE + cF1LOJA ))
			Return
		EndIf

		aAdd(xAutoCab,{"VVF_CLIFOR"  ,"F"               ,Nil})
		aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"               ,Nil})
		aAdd(xAutoCab,{"VVF_OPEMOV"  ,"0"               ,Nil})
		aAdd(xAutoCab,{"VVF_DATMOV"  ,dDataBase         ,Nil})
		aAdd(xAutoCab,{"VVF_DATEMI"  ,SF1->F1_EMISSAO   ,Nil})
		aAdd(xAutoCab,{"VVF_CODFOR"  ,SF1->F1_FORNECE   ,Nil})
		aAdd(xAutoCab,{"VVF_LOJA"    ,SF1->F1_LOJA      ,Nil})
		aAdd(xAutoCab,{"VVF_FORPAG"  ,RetCondVei()      ,Nil})
		aAdd(xAutoCab,{"VVF_ESPECI"  ,SF1->F1_ESPECIE   ,Nil})
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,SF1->F1_DOC       ,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,SF1->F1_SERIE     ,Nil})
		aAdd(xAutoCab,{"VVF_CHVNFE"  ,SF1->F1_CHVNFE    ,Nil})

		xAutoItens:= {} // Campos Itens

		cQuery := "SELECT SD1.D1_COD, SD1.D1_TES, SD1.D1_TOTAL "
		cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
		cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
		cQuery += " AND SD1.D1_DOC = '" + cF1DOC + "' "
		cQuery += " AND SD1.D1_SERIE = '" + cF1SERIE + "' "
		cQuery += " AND SD1.D1_FORNECE = '" + cF1FORNECE + "' "
		cQuery += " AND SD1.D1_LOJA = '" + cF1LOJA + "' "
		cQuery += " AND SD1.D_E_L_E_T_ = ' ' "

		TcQuery cQuery New Alias "TMPSD1"
		
		While !TMPSD1->(Eof())

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + TMPSD1->D1_COD))

			VV1->(dbSetOrder(1))
			If !VV1->(dbSeek( xFilial("VV1") + SB1->B1_CODITE ))
				TMPSD1->(DbSkip())
				Loop
			EndIf

			xAutoIt := {}
			aAdd(xAutoIt,{"VVG_CHASSI"  ,VV1->VV1_CHASSI		,Nil})
			aAdd(xAutoIt,{"VVG_CODTES"  ,TMPSD1->D1_TES			,Nil})
			aAdd(xAutoIt,{"VVG_LOCPAD"  ,VV1->VV1_LOCPAD		,Nil})
			aAdd(xAutoIt,{"VVG_VALUNI"  ,TMPSD1->D1_TOTAL		,Nil})
			aAdd(xAutoItens,aClone(xAutoIt))

			TMPSD1->(DbSkip())

		EndDo

		TMPSD1->(DbCloseArea())

		Private lMsHelpAuto := .t.
		Private lMsErroAuto := .f.

		Begin Transaction

			cBkpFunName := FunName()
			nBkpMod := nModulo
			SetFunName('VEIXA001')
			nModulo := 11

			MSExecAuto(	{ |a,b,c,d,e,f,g,h,i| VEIXX000(a,b,c,d,e,f,g,h,i) }, xAutoCab,xAutoItens,{} ,3 ,"0" , ,.f. , ,"3" )

			SetFunName(cBkpFunName)
			nModulo := nBkpMod
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				Break
			EndIf

			/*Atualiza pedido*/
			VQ0->(DbSetOrder(3))
			VQ0->(DbSeek(xFilial("VQ0")+VV1->VV1_CHAINT))

			aItem := {}
			aadd(aItem,{"VQ0_CODIGO" , VQ0->VQ0_CODIGO			, Nil})
			aadd(aItem,{"VQ0_CHASSI" , VV1->VV1_CHASSI			, Nil})

			oModelVQ0 := FWLoadModel( 'VEIA142' )
			FWMVCRotAuto(oModelVQ0,"VQ0",4,{{"VQ0MASTER",aItem}})

			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				Break
			EndIf

		End Transaction

	EndIf

Return

/*/{Protheus.doc} VX0000061_Fatura_com_Remito
	Fatura com Remito (ARGENTINA/MEXICO)

@type function
@author Andre Luis Almeida
@since 25/07/2024
/*/
Function VX0000061_Fatura_com_Remito()
If VVF->VVF_TIPDOC == "1" // 1=NF
	If VVF->VVF_SITNFI == "1" // VVF Valido
		If Empty(VVF->VVF_NUMNFI) .and. !Empty(VVF->VVF_REMITO)
			VEIXX000(,,,4,VVF->VVF_OPEMOV,,,,,,,"3") // Gerar Fatura com Remito que esta posicionado no browse VVF
		Else
			FMX_HELP("VEIX000E18", STR0136 ) // Fatura já foi Efetivada. Impossivel continuar!
		EndIf
	Else // NAO esta valido o VV0
		FMX_HELP("VEIX000E19", STR0137 ) // A Entrada de Veículos/Máquinas não esta Valida. Impossivel continuar!
	EndIf
Else // 2=SD3 (Mov.Internas)
	FMX_HELP("VEIX000E20", STR0138 ) // Tipo de Entrada de Veículos/Máquinas é uma Movimentação Interna. Impossivel continuar!
EndIf
Return

/*/{Protheus.doc} VX0000071_Item_Remito
	Retorna o D1_ITEM do Remito (ARGENTINA)

@type static function
@author Andre Luis Almeida
@since 26/07/2024
/*/
Static Function VX0000071_Item_Remito( cNroDoc , cSerDoc , cCodFor , cLojFor , cB1_COD )
Local cQuery := ""
cQuery := "SELECT D1_ITEM "
cQuery += "  FROM "+RetSqlName("SD1")
cQuery += " WHERE D1_FILIAL  = '"+xFilial("SD1")+"'"
cQuery += "   AND D1_DOC     = '"+cNroDoc+"'"
cQuery += "   AND D1_SERIE   = '"+cSerDoc+"'"
cQuery += "   AND D1_FORNECE = '"+cCodFor+"'"
cQuery += "   AND D1_LOJA    = '"+cLojFor+"'"
cQuery += "   AND D1_COD     = '"+cB1_COD+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
Return FM_SQL(cQuery)

/*/{Protheus.doc} VX0000081_Inicializa_Fiscal
	Incializa Fiscal quando entrar na TELA ARGENTINA

@type static function
@author Andre Luis Almeida
@since 29/07/2024
/*/
Static Function VX0000081_Inicializa_Fiscal()
Local nCntFor := 0
Local lvxx00teb := ExistBlock('VXX00TEB')
//
__ReadVar := "M->VVF_CODFOR"
VX000VLDENC()
__ReadVar := "M->VVF_LOJA"
VX000VLDENC()
//
dbSelectArea("VVG")
dbSetOrder(1)
dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)


While !eof() .and. VVG->VVG_FILIAL == xFilial("VVG") .and. VVF->VVF_TRACPA == VVG->VVG_TRACPA
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+VVG->VVG_CHAINT))
	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	n := ++nCntFor // SETA VARIAVEL FISCAL
	MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
	MaFisRef("IT_PRCUNI" ,"VVG00",VVG->VVG_VALUNI)
	MaFisRef("IT_VALMERC","VVG00",VVG->VVG_VALUNI)
	M->VVG_CODTES := VVG->VVG_CODTES
	If ((cPaisLoc == 'ARG' .AND. xTpFatR $ "3,5").Or.(cPaisLoc == 'MEX' .AND. xTpFatR $ "3" )).AND. lvxx00teb
		aRet := ExecBlock("VXX00TEB", .f., .f., { xTpFatR , VVF->VVF_FILIAL , VVF->VVF_TRACPA })
		cTesPE := IIF(Len(aRet)>0,aRet[1],"")
		If !Empty(cTesPE)
			M->VVG_CODTES:= cTesPE
		Endif
	Endif
	MaFisRef("IT_TES"    ,"VVG00",M->VVG_CODTES)

	VVG->(dbSkip())
EndDo
//
// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
//
VX000ATUF1("DESPESA")
VX000ATUF1("FRETE")
//
If !Empty(M->VVF_FORPAG)
	__ReadVar := "M->VVF_FORPAG"
	VX000VLDENC()
EndIf
Return

/*/{Protheus.doc} VX0000091_Carrega_Cabec_SF1
	Retorna Vetor com o Cabeçalho SF1 para poder ser cancelado

@type static function
@author Andre Luis Almeida
@since 08/08/2024
/*/
Static Function VX0000091_Carrega_Cabec_SF1( cDoc , cSer , cFor , cLoj )
Local aRet := {}
//
SF1->(DbSetOrder(1))
SF1->(DbSeek(xFilial("SF1")+cDoc+cSer+cFor+cLoj))
//
aAdd(aRet,{"F1_DOC"		,SF1->F1_DOC    ,Nil})
aAdd(aRet,{"F1_SERIE"	,SF1->F1_SERIE  ,Nil})
aAdd(aRet,{"F1_FORNECE"	,SF1->F1_FORNECE,Nil})
aAdd(aRet,{"F1_LOJA" 	,SF1->F1_LOJA   ,Nil})
aAdd(aRet,{"F1_TIPO"	,SF1->F1_TIPO   ,Nil})
aAdd(aRet,{"F1_FORMUL"	,SF1->F1_FORMUL ,Nil})
aAdd(aRet,{"F1_EMISSAO"	,SF1->F1_EMISSAO,Nil})
aAdd(aRet,{"F1_ESPECIE"	,SF1->F1_ESPECIE,Nil})
aAdd(aRet,{"F1_COND"	,SF1->F1_COND   ,Nil})
aAdd(aRet,{"F1_EST"		,SF1->F1_EST    ,Nil})
If !Empty(VVF->VVF_TRANSP)
	aAdd(aRet,{"F1_TRANSP",VVF->VVF_TRANSP ,Nil})
EndIf
aAdd(aRet,{"F1_ESPECIE1",VVF->VVF_ESPEC1  ,Nil})
aAdd(aRet,{"F1_VOLUME1" ,VVF->VVF_VOLUM1  ,Nil})
aAdd(aRet,{"F1_ESPECIE2",VVF->VVF_ESPEC2  ,Nil})
aAdd(aRet,{"F1_VOLUME2" ,VVF->VVF_VOLUM2  ,Nil})
aAdd(aRet,{"F1_ESPECIE3",VVF->VVF_ESPEC3  ,Nil})
aAdd(aRet,{"F1_VOLUME3" ,VVF->VVF_VOLUM3  ,Nil})
aAdd(aRet,{"F1_ESPECIE4",VVF->VVF_ESPEC4  ,Nil})
aAdd(aRet,{"F1_VOLUME4" ,VVF->VVF_VOLUM4  ,Nil})
//
Return aRet

/*/{Protheus.doc} VX0000101_Carrega_Itens_SD1
	Retorna Vetor com os Itens SD1 para poder ser cancelado

@type static function
@author Andre Luis Almeida
@since 08/08/2024
/*/
Static Function VX0000101_Carrega_Itens_SD1( cDoc , cSer , cFor , cLoj )
Local aTemp := {}
Local aRet  := {}
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1") + cDoc + cSer + cFor + cLoj)
While !eof() .and. xFilial("SD1")+cDoc+cSer+cFor+cLoj == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	//
	aTemp := {}
	//
	aAdd(aTemp,{"D1_DOC"    ,SD1->D1_DOC    ,Nil})
	aAdd(aTemp,{"D1_SERIE"  ,SD1->D1_SERIE  ,Nil})
	aAdd(aTemp,{"D1_FORNECE",SD1->D1_FORNECE,Nil})
	aAdd(aTemp,{"D1_LOJA"   ,SD1->D1_LOJA   ,Nil})
	aAdd(aTemp,{"D1_COD"    ,SD1->D1_COD    ,Nil})
	aAdd(aTemp,{"D1_ITEM"   ,SD1->D1_ITEM   ,Nil})
	If !Empty( SD1->D1_NFORI + SD1->D1_SERIORI )
		aAdd(aTemp,{"D1_NFORI"  ,SD1->D1_NFORI  ,Nil})
		aAdd(aTemp,{"D1_SERIORI",SD1->D1_SERIORI,Nil})
	EndIf
	//
	aAdd(aRet,aclone(aTemp))
	//
	DBSelectArea("SD1")
	DbSkip()
enddo
Return aRet

/*/{Protheus.doc} VX0000119_RemitoEntregaFutura
	Remito Entrega Futura (ARGENTINA)

@type function
@author João Carlos da Silva
@since 27/09/2024
/*/
Function VX0000119_RemitoEntregaFutura()
If VVF->VVF_TIPDOC == "1" // 1=NF
	If VVF->VVF_SITNFI == "1" // VVF Valido
		If VVF->VVF_TPFATR == "4" // 4=Entrega Futura
			If !Empty(VVF->VVF_NUMNFI) .and. Empty(VVF->VVF_REMITO)
				VEIXX000(,,,4,VVF->VVF_OPEMOV,,,,,,,"5") // Gerar Remito para a Entrega Futura que esta posicionada no browse VVF
			Else
				FMX_HELP("VEIX000E24", STR0136 ) // Fatura já foi Efetivada. Impossivel continuar!
			EndIf
		Else
			FMX_HELP("VEIX000E23", STR0148 ) // Esta entrada não é Entrega Futura. Impossivel continuar!
		EndIf
	Else // NAO esta valido
		FMX_HELP("VEIX000E25", STR0137 ) // A Entrada de Veículos/Máquinas não esta Valida. Impossivel continuar!
	EndIf
Else // 2=SD3 (Mov.Internas)
	FMX_HELP("VEIX000E26", STR0138 ) // Tipo de Entrada de Veículos/Máquinas é uma Movimentação Interna. Impossivel continuar!
EndIf
Return

/*/{Protheus.doc} VX0000129_GeraNCC
Função para gerar NCC na rotina Entrada por Devolução de Venda para a Argentina
@type function
@version 1.0
@author João Carlos da Silva
@since 10/10/2024
@param nRecVVF, numeric, Recno do VVF
@return logical, Se a NCC foi gerada com sucesso
/*/
Function VX0000129_GeraNCC(nRecVVF) // Gera NCC
Local aArea      := GetArea()
Local aAreaVVF   := VVF->(GetArea())
Local aCfgNFOld  := If(Type("aCfgNF") <> "U", aClone(aCfgNF), {})
Local cEspecOld  := If(Type("cEspecie") <> "U", cEspecie, "")
Local aGerarOld  := If(Type("aGerarCFD") <> "U", aClone(aGerarCFD), {})
Local lGerarOld  := If(Type("lGerarCFD") <> "U", lGerarCFD, .F.)
Local aCab       := {}
Local aItens     := {}
Local aItens0    := {}
Local aNumeroX   := {}
Local aPerg      := {}
Local aPergs     := {}
Local aVetNCC    := {}
Local aCliTotais := {}
Local nCliTotais := 0
Local nF1_FORNECE:= 0
Local nF1_LOJA   := 0
Local nF1_EST    := 0
Local nF1_NFORIG := 0
Local nF1_SERORIG:= 0
Local nF1_SERIE  := 0
Local nF1_DOC    := 0
Local nF1_DUPL   := 0
Local nF1_PREFIXO:= 0
Local nD1_VUNIT  := 0
Local nD1_TOTAL  := 0
Local nD1_NFORI  := 0
Local nD1_SERIORI:= 0
Local nD1_ITEMORI:= 0
Local cVV0NUMTRA := ""
Local lRet       := .t.
Local lVez       := .t.
Local lTelaTES   := .t.
Local cCond      := Space(Len(SF2->F2_COND))
Local cTes       := Space(Len(SD2->D2_TES))
Local cCfo       := Space(Len(SF4->F4_CF))
Local aParamBox  := {}
Local aRet       := {}
Local xCadastro  := ""
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cStaNCC    := ""
Local cNumNCC    := ""
Local cSerNCC    := ""
Local lSaidSemRem := .f. // Saida somente com Fatura e sem Remito
Local lvxx00tea := ExistBlock('VXX00TEA')

VVF->(dbGoTo(nRecVVF)) // Posiciona no VVF
If VVF->VVF_STANCC <> "1" // 0=Sem NCC;1=Falta NCC;2=NCC Gerada
	FMX_HELP("VEIX000E23", STR0149) // "Status do movimento de entrada não permite gerar NCC. Impossivel continuar!"
	VVF->(RestArea(aAreaVVF))
	RestArea(aArea)
	Return .f.
EndIf

cQuery := "SELECT R_E_C_N_O_ AS RECVV0 "
cQuery += "  FROM "+RetSqlName("VV0")
cQuery += " WHERE VV0_FILIAL = '"+VVF->VVF_FILIAL+"'"
cQuery += "   AND VV0_NUMNFI = '"+VVF->VVF_REMITO+"'"
cQuery += "   AND VV0_SERNFI = '"+VVF->VVF_SERREM+"'"
cQuery += "   AND VV0_CODCLI = '"+VVF->VVF_CODFOR+"'"
cQuery += "   AND VV0_LOJA   = '"+VVF->VVF_LOJA  +"'"
cQuery += "   AND VV0_REMITO = ' '"
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0 // Verifica se o Nro. do Remito é igual ao Nro. da Fatura de Saida - Isso quer dizer que foi Devolução de Venda com Entrega Futura e não possui Remito de Saida
	lSaidSemRem := .t. // Saida somente com Fatura e sem Remito
EndIf

cQuery := "SELECT DISTINCT"
cQuery += " SF2NF.F2_COND"
cQuery += ", SD2NF.D2_TES"
cQuery += ", SF2NF.F2_CLIENTE"
cQuery += ", SF2NF.F2_LOJA"
cQuery += ", SF2NF.F2_EST"
cQuery += ", SF2NF.F2_MOEDA"
cQuery += ", SF2NF.F2_TXMOEDA"
cQuery += ", SF2NF.F2_VEND1"
cQuery += ", SF2NF.F2_DOC"
cQuery += ", SF2NF.F2_SERIE"
cQuery += ", SD2NF.D2_COD"
cQuery += ", SD2NF.D2_UM"
cQuery += ", SD2NF.D2_QUANT"
cQuery += ", SD2NF.D2_PRCVEN"
cQuery += ", SD2NF.D2_TOTAL"
cQuery += ", SD2NF.D2_LOCAL"
cQuery += ", SD2NF.D2_DOC"
cQuery += ", SD2NF.D2_SERIE"
cQuery += ", SD2NF.D2_ITEM"
cQuery += ", SF4NF.F4_TESDV"
If cPaisLoc == "ARG"
	cQuery += ", VVF.VVF_PROVEN"
EndIf
cQuery += ", VV0.VV0_NUMTRA"
cQuery += " FROM " + RetSqlName("VVF") + " VVF"
cQuery += " JOIN " + RetSqlName("VVG") + " VVG ON VVG.D_E_L_E_T_=' ' AND VVG_FILIAL='" + xFilial("VVG") + "' AND VVG_TRACPA=VVF_TRACPA"
If lSaidSemRem // Saida somente com Fatura e sem Remito
	cQuery += " JOIN " + RetSqlName("VV0") + " VV0 ON VV0.D_E_L_E_T_=' ' AND VV0_FILIAL='" + xFilial("VV0") + "' AND VV0_NUMNFI=VVG_NFORI AND VV0_SERNFI=VVG_SERORI"
	cQuery += " JOIN " + RetSqlName("SF2") + " SF2 ON SF2.D_E_L_E_T_=' ' AND SF2.F2_FILIAL='" + xFilial("SF2") + "' AND SF2.F2_DOC=VV0_NUMNFI AND SF2.F2_SERIE=VV0_SERNFI AND SF2.F2_CLIENTE=VV0_CODCLI AND SF2.F2_LOJA=VV0_LOJA"
Else // Default
	cQuery += " JOIN " + RetSqlName("VV0") + " VV0 ON VV0.D_E_L_E_T_=' ' AND VV0_FILIAL='" + xFilial("VV0") + "' AND VV0_NUMNFI<>' ' AND VV0_SERNFI<>' ' AND VV0_REMITO=VVG_NFORI AND VV0_SERREM=VVG_SERORI"
	cQuery += " JOIN " + RetSqlName("SF2") + " SF2 ON SF2.D_E_L_E_T_=' ' AND SF2.F2_FILIAL='" + xFilial("SF2") + "' AND SF2.F2_DOC=VV0_REMITO AND SF2.F2_SERIE=VV0_SERREM AND SF2.F2_CLIENTE=VV0_CODCLI AND SF2.F2_LOJA=VV0_LOJA"
EndIf
cQuery += " JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D_E_L_E_T_=' ' AND SD2.D2_FILIAL='" + xFilial("SD2") + "' AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D2_CLIENTE=SF2.F2_CLIENTE AND SD2.D2_LOJA=SF2.F2_LOJA"
cQuery += " JOIN " + RetSqlName("SF2") + " SF2NF ON SF2NF.D_E_L_E_T_=' ' AND SF2NF.F2_FILIAL='" + xFilial("SF2") + "' AND SF2NF.F2_DOC=VV0_NUMNFI AND SF2NF.F2_SERIE=VV0_SERNFI AND SF2NF.F2_CLIENTE=VV0_CODCLI AND SF2NF.F2_LOJA=VV0_LOJA"
cQuery += " JOIN " + RetSqlName("SD2") + " SD2NF ON SD2NF.D_E_L_E_T_=' ' AND SD2NF.D2_FILIAL='" + xFilial("SD2") + "' AND SD2NF.D2_DOC=SF2NF.F2_DOC AND SD2NF.D2_SERIE=SF2NF.F2_SERIE AND SD2NF.D2_CLIENTE=SF2NF.F2_CLIENTE AND SD2NF.D2_LOJA=SF2NF.F2_LOJA"
cQuery += " AND SD2NF.D2_COD IN (SELECT B1_COD FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.D_E_L_E_T_=' ' AND B1_FILIAL='" + xFilial("SB1") + "' AND B1_CODITE=VVG_CHAINT)"
cQuery += " JOIN " + RetSqlName("SF4") + " SF4NF ON SF4NF.D_E_L_E_T_=' ' AND SF4NF.F4_FILIAL='" + xFilial("SF4") + "' AND SF4NF.F4_CODIGO=SD2NF.D2_TES"
cQuery += " WHERE VVF.D_E_L_E_T_=' '"
cQuery += " AND VVF_FILIAL='" + xFilial("VVF") + "'"
cQuery += " AND VVF_TRACPA='" + VVF->VVF_TRACPA + "'""

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .F., .T. )

While (cAlias)->(!Eof())
	If lVez
		lVez := .f.

		cVV0NUMTRA := (cAlias)->( VV0_NUMTRA )

		cTes  := (cAlias)->F4_TESDV

		If lvxx00tea // Ponto de Entrada para manipular o TES Argentina 
			aRet     := ExecBlock("VXX00TEA", .f., .f., { "1" , VVF->VVF_FILIAL , VVF->VVF_TRACPA })
			cTes     := aRet[1]
			lTelaTES := aRet[2]
			aRet     := {}
		EndIf

		If lTelaTES
			AADD(aParamBox,{1,STR0150,cTes ,"@!","VX0000139_Valida_TES_ARG('6',MV_PAR01)","SF4",".T.",50,.T.}) // "Informe o TES"
			AADD(aParamBox,{1,STR0151,cCond,"@!","VX0000151_ValidCondicaoPadrao(MV_PAR02)","SE4",".T.",50,.T.}) // "Informe a Cond.Pagto"
			xCadastro := cCadastro // Salva o cCadastro
			cCadastro := STR0152 // "GERAÇÃO DA NCC"
			If ParamBox(aParamBox,STR0153,@aRet,,,,,,,,.f.) // "NOTA DE CRÉDITO CLIENTE"
				cTes  := aRet[1]
				cCond := aRet[2]
				cCadastro := xCadastro // Restaura o cCadastro
			Else
				cCadastro := xCadastro // Restaura o cCadastro
				lRet := .f.
				Exit
			EndIf
		EndIf

		If !VX0000139_Valida_TES_ARG("6",cTes)
			lRet := .f.
			Exit
		EndIf

		SF4->(dbSetOrder(1)) // F4_FILIAL+F4_CODIGO
		SF4->(dbSeek(xFilial("SF4")+cTes)) // Posiciona no SF4
		cCfo  := SF4->F4_CF

		cEspecie  := "NCC" // Variável Private utilizada nas funções localizadas
		aGerarCFD := {}    // Variável Private utilizada nas funções localizadas
		lGerarCFD := .F.   // Variável Private utilizada nas funções localizadas

		// Busca o número da nota fiscal da Argentina
		If cPaisLoc == 'ARG'
			cLocxNFPV := ""
			If FindFunction("OA5300051_Retorna_Ponto_de_Venda")
				cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_NCC_DEVVENDA") // Fatura NCC
			EndIf
			lRet := .t.
			If Empty(cLocxNFPV)
				If Pergunte("PVXARG",.T.) .and. !Empty(MV_PAR01)
					cLocxNFPV := MV_PAR01
				Else
					lRet := .f.
				EndIf
			EndIf
			If !Empty(cLocxNFPV)
				cPV410    := cLocxNFPV // Variavel Private utilizada no a468nFatura
				lLocxAuto  := .F.
				cIdPVArg := cIdPV := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
				lRet := F083ExtSFP(cLocxNFPV, .T.)
			Endif
			If !lRet
				Exit
			EndIf
		EndIf
		
		aPerg := {'MTXRED',.F.}
		Pergunte(aPerg[1],aPerg[2])
		LoadPergs(aPerg,@aPergs)
		AAdd(aPergs,.F.)
		aCfgNF := MontaCfgNf(4,aPergs,.F.) // Variável Private utilizada nas funções localizadas
		If !Empty(aCfgNF)
			//          LocXSx5NF(oDlgPae,lLocxAuto,aAutoCab,lNumNCC,lTransf, cFunName  )
			aNumeroX := LocXSx5NF(Nil    ,.f.      ,Nil     ,Nil    ,Nil    , "MATA465N")
		EndIf
		lRet := ( Len(aNumeroX) >= 2 )
		If lRet
			aCab := {}
			aadd( aCab, { "F1_FORNECE", (cAlias)->F2_CLIENTE, Nil } )
			aadd( aCab, { "F1_LOJA"   , (cAlias)->F2_LOJA   , Nil } )
			aadd( aCab, { "F1_SERIE"  , aNumeroX[2]         , Nil } )
			aadd( aCab, { "F1_DOC"    , aNumeroX[1]         , Nil } )
			aadd( aCab, { "F1_DUPL"   , aNumeroX[1]         , Nil } )
			aadd( aCab, { "F1_COND"   , cCond               , Nil } )
			aadd( aCab, { "F1_EMISSAO", dDataBase           , Nil } )
			aadd( aCab, { "F1_EST"    , (cAlias)->F2_EST    , Nil } )
			aadd( aCab, { "F1_TIPO"   , "D"                 , Nil } )
			aadd( aCab, { "F1_ESPECIE", cEspecie            , Nil } )
			aadd( aCab, { "F1_PREFIXO", aNumeroX[2]         , Nil } )
			aadd( aCab, { "F1_MOEDA"  , (cAlias)->F2_MOEDA  , Nil } )
			aadd( aCab, { "F1_TXMOEDA", (cAlias)->F2_TXMOEDA, Nil } )
			aadd( aCab, { "F1_FORMUL" , "S"                 , Nil } )
			aadd( aCab, { "F1_TIPODOC", "04"                , Nil } )
			aadd( aCab, { "F1_TPVENT" , "B"                 , Nil } )
			aadd( aCab, { "F1_VEND1"  , (cAlias)->F2_VEND1  , Nil } )
			aadd( aCab, { "F1_NFORIG" , (cAlias)->F2_DOC    , Nil } )
			aadd( aCab, { "F1_SERORIG", (cAlias)->F2_SERIE  , Nil } )
			If cPaisLoc == 'ARG'
				aadd( aCab, { "F1_PV"     , cLocxNFPV           , Nil } )
			EndIf
		EndIf
	EndIf

	If Len(aCab) > 0
		aItens0 := {}
		aadd( aItens0, { "D1_COD"    , (cAlias)->D2_COD    , Nil } )
		aadd( aItens0, { "D1_UM"     , (cAlias)->D2_UM     , Nil } )
		aadd( aItens0, { "D1_QUANT"  , (cAlias)->D2_QUANT  , Nil } )
		aadd( aItens0, { "D1_VUNIT"  , (cAlias)->D2_PRCVEN , Nil } )
		aadd( aItens0, { "D1_TOTAL"  , (cAlias)->D2_TOTAL  , Nil } )
		aadd( aItens0, { "D1_TES"    , cTes                , Nil } )
		aadd( aItens0, { "D1_LOCAL"  , (cAlias)->D2_LOCAL  , Nil } )
		aadd( aItens0, { "D1_CF"     , cCfo                , Nil } )
		aadd( aItens0, { "D1_NFORI"  , (cAlias)->F2_DOC    , Nil } )
		aadd( aItens0, { "D1_SERIORI", (cAlias)->F2_SERIE  , Nil } )
		aadd( aItens0, { "D1_ITEMORI", (cAlias)->D2_ITEM   , Nil } )
		If cPaisLoc == 'ARG'
			aadd( aItens0, { "D1_PROVENT", (cAlias)->VVF_PROVEN, Nil } )
		EndIf
		aadd( aItens, aItens0)
	EndIf

	(cAlias)->(dbSkip())
End
(cAlias)->(dbCloseArea())

aVetNCC    := {}
cNumNCC    := ""
cSerNCC    := ""

If lRet
	If Len(aCab) > 0 .and. Len(aItens) > 0
		aCliTotais := VXI010031_Totais_por_Cliente( cVV0NUMTRA , .f. , .f. , )
		If len(aCliTotais) > 1 // Somente na ARGENTINA que pode vir mais de um registro de cliente (COTITULARES)
			nF1_FORNECE := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_FORNECE"})
			nF1_LOJA    := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_LOJA"   })
			nF1_EST     := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_EST"    })
			nF1_NFORIG  := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_NFORIG" })
			nF1_SERORIG := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_SERORIG"})
			nF1_SERIE   := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_SERIE"  })
			nF1_DOC     := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_DOC"    })
			nF1_DUPL    := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_DUPL"   })
			nF1_PREFIXO := aScan(aCab     ,{|x| AllTrim(x[1])=="F1_PREFIXO"})
			nD1_VUNIT   := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_VUNIT"  })
			nD1_TOTAL   := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_TOTAL"  })
			nD1_NFORI   := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_NFORI"  })
			nD1_SERIORI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_SERIORI"})
			nD1_ITEMORI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_ITEMORI"})
		EndIf
		For nCliTotais := 1 to len(aCliTotais)
			If cPaisLoc $ "ARG|MEX" .and. len(aCliTotais) > 1 .and. nCliTotais > 1 // Somente na ARGENTINA que pode vir mais de um registro de cliente (COTITULARES)
				aNumeroX := LocXSx5NF(Nil    ,.f.      ,Nil     ,Nil    ,Nil    , "MATA465N")
				// Ajustar vetores aCab e aItens para Integração NCC de cada Cliente COTITULAR
				SF2->(DbSetOrder(1))
				SF2->(DbSeek(xFilial("SF2")+aCliTotais[nCliTotais,6]+aCliTotais[nCliTotais,7]+aCliTotais[nCliTotais,1]+aCliTotais[nCliTotais,2]))
				aCab[ nF1_FORNECE , 2 ] := aCliTotais[nCliTotais,1]
				aCab[ nF1_LOJA    , 2 ] := aCliTotais[nCliTotais,2]
				aCab[ nF1_EST     , 2 ] := SF2->F2_EST
				aCab[ nF1_NFORIG  , 2 ] := SF2->F2_DOC
				aCab[ nF1_SERORIG , 2 ] := SF2->F2_SERIE
				aCab[ nF1_SERIE   , 2 ] := aNumeroX[2]
				aCab[ nF1_DOC     , 2 ] := aNumeroX[1]
				aCab[ nF1_DUPL    , 2 ] := aNumeroX[1]
				aCab[ nF1_PREFIXO , 2 ] := aNumeroX[2]
				// ARGENTINA tem somente 1 Veiculo/Máquina SD2
				SD2->(DbSetOrder(3))
				SD2->(DbSeek(xFilial("SD2")+aCliTotais[nCliTotais,6]+aCliTotais[nCliTotais,7]+aCliTotais[nCliTotais,1]+aCliTotais[nCliTotais,2]))
				aItens[ 1 , nD1_VUNIT   , 2 ] := SD2->D2_PRCVEN
				aItens[ 1 , nD1_TOTAL   , 2 ] := SD2->D2_TOTAL
				aItens[ 1 , nD1_NFORI   , 2 ] := SF2->F2_DOC
				aItens[ 1 , nD1_SERIORI , 2 ] := SF2->F2_SERIE
				aItens[ 1 , nD1_ITEMORI , 2 ] := SD2->D2_ITEM
			EndIf
			If lRet
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| MATA465N(x,y,z)}, aCab, aItens, 3)
				If lMsErroAuto
					MostraErro()
					cStaNCC := "1" // 0=Sem NCC;1=Falta NCC;2=NCC Gerada
				Else
					cStaNCC := "2" // 0=Sem NCC;1=Falta NCC;2=NCC Gerada
					If Empty(cNumNCC) // Gravar no VVF apenas a NCC do Cliente principal
						cNumNCC := aNumeroX[1]
						cSerNCC := aNumeroX[2]
					EndIf
					aAdd(aVetNCC,{ Alltrim(aNumeroX[2]) , Alltrim(aNumeroX[1]) , If( cPaisLoc == "BRA" , STR0154, STR0167 ) }) // "NCC EMITIDA" # NCC GENERADA
				EndIf
			EndIf
		Next
	Else
		cStaNCC := "0" // 0=Sem NCC;1=Falta NCC;2=NCC Gerada
	EndIf
Else
	cStaNCC := "1" // 0=Sem NCC;1=Falta NCC;2=NCC Gerada
EndIf

DbSelectArea("VVF")
DbGoTo(nRecVVF)

// Atualiza o status da NCC
RecLock("VVF",.f.)
VVF->VVF_STANCC := cStaNCC
VVF->VVF_NUMNCC := cNumNCC
VVF->VVF_SERNCC := cSerNCC
MsUnlock()

If cStaNCC == "2" // 0=Sem NCC;1=Falta NCC;2=NCC Gerada
	FMX_TELAINF( "1" , aVetNCC )
EndIf

aCfgNF    := Aclone(aCfgNFOld)
cEspecie  := cEspecOld
aGerarCFD := Aclone(aGerarOld)
lGerarCFD := lGerarOld

VVF->(RestArea(aAreaVVF))
RestArea(aArea)

Return(cStaNCC == "2")

/*/{Protheus.doc} VX0000139_Valida_TES_ARG
Validação de TES ARGENTINA
@type function
@version 1.0
@author João Carlos da Silva
@since 23/10/2024
@param cTp, character, Tipo da Movimentação: 1=Fatura ou 2=Remito
@param cTES, character, TES a ser validado
@return logical, Se o TES é válido
/*/
Function VX0000139_Valida_TES_ARG(cTp,cTES)
Local lRet    := .f.

If MaAvalTes('E',cTES)
	lRet := VX0000145_ValidacaoTES(cTp,cTES)
EndIf
Return lRet

/*/{Protheus.doc} VX0000145_ValidacaoTES
Validação de TES
@type function
@version 1.0
@author Renato Santos
@since 12/12/2024
@param cTp, character, Tipo da Movimentação: 1=Fatura ou 2=Remito
@param cTES, character, TES a ser validado
@return logical, Se o TES é válido
/*/
Function VX0000145_ValidacaoTES(cTpFatR,cTES)

	Local lRet := .t.

	Default cTES    := ""
	Default cTpFatR := ""

	IF !Empty(cTES)
		DBSelectArea("SF4")
		DBSetOrder(1)
		DBSeek(xFilial("SF4")+cTES)
		Do Case
			Case cTpFatR == "1" // 1=Fatura (default)
				lRet := AllTrim(SF4->F4_ESTOQUE) == "S" .and. AllTrim(SF4->F4_DUPLIC) == "S"
				cMsgHlp := STR0155 // TES para Fatura
				cSolHlp := STR0162 // Utilize somente TES que gere financeiro e  movimenta estoque.
			Case cTpFatR == "2" // 2=Remito 
				lRet := AllTrim(SF4->F4_ESTOQUE) == "S"
				cMsgHlp := STR0159 // TES para Remito
				cSolHlp := STR0164 // Utilize somente TES que movimenta estoque.
			Case cTpFatR == "3" // 3=Fatura com Remito
				lRet := AllTrim(SF4->F4_DUPLIC) == "S"
				cMsgHlp := STR0160 // TES para Fatura com Remito 
				cSolHlp := STR0165 // Utilize somente TES que gere financeiro.
			Case cTpFatR == "4" // 4=Entrega Futura
				lRet := AllTrim(SF4->F4_ESTOQUE) == "N" .and. AllTrim(SF4->F4_DUPLIC) == "S"
				cMsgHlp := STR0161 // TES para Entrega futura 
				cSolHlp := STR0156 // Utilize somente TES que não movimenta estoque e gere financeiro.
			Case cTpFatR == "5" // 5=Não grava, é utilizado somente para gerar Remito Entrega Futura
				lRet := AllTrim(SF4->F4_ESTOQUE) == "S" .and. AllTrim(SF4->F4_DUPLIC) == "N"
				cMsgHlp := STR0163 // TES para Remito Entrega futura 
				cSolHlp := STR0158 // Utilize somente TES que  movimenta estoque e não gere financeiro.
			Case cTpFatR == "6" // Valida TES para NCC 
				lRet := AllTrim(SF4->F4_ESTOQUE) == "N" .and. AllTrim(SF4->F4_DUPLIC) == "S"
				cMsgHlp := STR0168 // TES para NCC
				cSolHlp := STR0156 // Utilize somente TES que não movimenta estoque e gere financeiro.
		EndCase
		If !lRet // Apresenta Help somente se der problema
			FMX_HELP("VEIX000E27",cMsgHlp,cSolHlp) 
		Endif
	EndIf

Return lRet

/*/{Protheus.doc} VX0000151_ValidCondicaoPadrao
Validação na Condição de Pagamento - Deixa somente PADRAO

@type function
@version 1.0
@author Andre Luis Almeida
@since 07/05/2025
@param cCond, character, Condição de Pagamento
@return logical, Se a Condição é válido
/*/
Function VX0000151_ValidCondicaoPadrao(cCond)
Local lRet := .t.
SE4->(DbSetOrder(1))
lRet := SE4->(DbSeek(xFilial("SE4")+cCond))
If lRet .and. SE4->E4_TIPO $ "9/A"
	lRet := .f. // Não deixa escolher uma Condição NEGOCIADA
EndIf
If !lRet .or. Empty(cCond)
	FMX_HELP("VEIX000E28",STR0172,STR0173) // Condição de Pagamento inválida. / Utilize uma Condição de Pagamento Padrão (Tipo 1).
EndIf
Return lRet
