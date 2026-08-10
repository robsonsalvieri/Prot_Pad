#INCLUDE "GFEXFUNB.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/* 
 	GFEXFBA - Classe Array/Tabela temporária
 	GFEXFBB - Classe de eliminação de cálculos e respectivos vínculos
 	GFEXFBD - Classe da criação das tabelas temporárias
 	GFEXFBF - Classe gravação de LOG 

 	GFEXFBE - Seleção Tabela de Frete - Array 
 	GFEXFBG - Seleção Tabela de Frete - Tabela temporária
 	GFEXFBH - Cálculo do frete
 	GFEXFBJ - Gravação do cálculo de frete
	GFEXFBK - ICMS de Pauta
*/

// Identificadores   dos elementos do array aCompCalc, usado em vários pontos da rotina
#DEFINE _CDCOMP 1 // Codigo do  componente
#DEFINE _CATVAL 2 // Categoria do componente
#DEFINE _VALOR  3 // Valor do componente
#DEFINE _QTDE   4 // Quantidade usada para calculo
#DEFINE _TOTFRE 5 // Indica se o componente soma no total do frete
#DEFINE _BASIMP 6 // Indica se o componente soma na base de calculo do ICMS/ISS
#DEFINE _BAPICO 7 // Indica se o componente soma na base de calculo do PIS/COFINS
#DEFINE _FREMIN 8 // Indica se o componente soma no valor usado para comparação com o frete mínimo
#DEFINE _NRCALC 9 // Numero da unidade de calculo
#DEFINE _VALOR_TOTAL 11 // Valor total, aplicável à taxa

// Constantes usadas na função AddToLog()
#DEFINE _LOG_BEGIN 1
#DEFINE _LOG_END   2

// SonarQube - CA1003: Uso não permitido de chamada de API em LOOP
Static lPEXFB02	:= ExistBlock("GFEXFB02")
Static lPEXFB17	:= ExistBlock("GFEXFB17")
Static lPEXFB08	:= ExistBlock("GFEXFB08")
Static lPEXFB10	:= ExistBlock("GFEXFB10")
Static lPEXFB15	:= ExistBlock("GFEXFB15")
Static lPEXFB16	:= ExistBlock("GFEXFB16")
Static lPEXFB22	:= ExistBlock("GFEXFB22")
Static lPEXFB23	:= ExistBlock("GFEXFB23")

Static lPEAgru	  := ExistBlock("XGFEAGRU")
Static lOCOVL	  := ExistBlock("GFEOCOVL")

Static s_TREENTR  := SuperGetMv('MV_TREENTR',.F.,"0")
Static s_UMPESO	  := SuperGetMv("MV_UMPESO",,"KG")
Static s_DPSERV	  := SuperGetMV("MV_DPSERV", .F., "1")
Static s_SERVTO	  := SuperGetMV("MV_SERVTO",.F.,"2")
Static s_GFETROT  := SuperGetMv("MV_GFETROT",.F.,"1")
Static s_GFEGVR	  := SuperGetMv("MV_GFEGVR",.F.,"1") == "1" // 2-Não utiliza a tabela GVR / 1-Realiza consulta na tabela GVR
Static s_GFEGUL	  := SuperGetMv("MV_GFEGUL",.F.,"1") == "1" // 2-Não utiliza a tabela GUL / 1-Realiza consulta na tabela GUL
Static s_GFEVIN	  := SuperGetMv("MV_GFEVIN",.F.,"1") == "1" // 2-Não utiliza o cadastro de tabela vínculo / 1-Realiza consulta o cadastro de tabela vínculo
Static s_MULFIL   := SuperGetMV("MV_MULFIL",.F.,"2")

Static lExiCDESP  := GFXCP12116("GWF","GWF_CDESP")

/*----------------------------------------------------------------------------
{Protheus.doc} GFECLCFRT
Calculo de Frete.
Uso Generico.

@param  aAgrFrt        Agrupadores de Frete -> Romaneios
@param  aDocCarg       Documentos de Carga -> NF, etc.
@param  aTrchDoc       Trechos do Documento de Carga
@param  aItDoc         Itens do Documento de Carga
@param  [aTblFrt]      Tabela de Frete
@param  [lReal]        Calculo Real? (ou simulacao) default = .T.
@param  [iLogProc]     Apresenta log ao final do processo? 0: Não apresentar, 1: Somente erros, 2: Sempre
@param  [nTabProv]     Cálculo de Provisão? 0: Não, 1: Sim, utilizando tabela dos parametros, 2: Sim, utilizando tabela do transportador. Default = 0
@param  [lParCons]     Considerar Tabelas de frete com a situação 'Em negociação'? default = .F.
@param  [iTpSimul]     Tipo de simulação: 0=simulação geral, 1=simulação específica 
@param  lCalcLote       Recebe ".T." se rotina que chamou a função é GFEA081.
@param	lHideProgress	Esconde a barra de progresso
@param lLog				Indica se deve ou não salvar arquivo de log. Default ".T."
@param lServ         	Indica se o cálculo deve ser de Serviço. Default ".F."
@param pServTpImp		Indica o tipo de imposto que o cálculo de serviço irá usar [1: Conforme regra cidade origem x destino, 2: ISS - Cidade Origem, 3: ISS - Cidade Destino]
@param lShowTabFr		Indica se vai mostrar a tela de seleção de tabela de frete 
@param dDtCalcPed       Utilizado na simulação de frete, utiliza a data de entrega do pedido de venda como data base do cálculo

@sample GFECLCFRT(aAgrFrt,aDocCarg,aTrchDoc,aItDoc,aTblFrt,lReal,iLogProc,nTabProv,lParCons,iTpSim,lCalcLote,lHideProgress,lLog,lServ,aNoCalc,lShowTabFr,dDtCalcPed)

@Return Vetor contendo dados do cálculo
[1] Sucesso (Sim/Não)
[2] Arquivo de Log Gerado
[3] Texto do processo do cálculo (Texto do arquivo de log)

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Function GFECLCFRT(aAgrFrt1, aDocCarg1, aTrchDoc, aItDoc, aTblFrt, lReal, iLogProc, nTabProv, lParCons, iTpSimul, lCalcLote, lHideProgress, lLog, lServ, pServTpImp, pCalcDataBase,aNoCalc,lShowTabFr, dDtCalcPed)
	Local nX
	Local cNow
	Local cNrRomLock := ""
	Local cLogAlt	 := ""
	Local cMV_EMIPRO
	Local cMV_TABPRO
	Local cMV_NEGPRO
	Local axItDoc
	Local aRet		 := {}
	Local aErroDoc   := {}
	Local cAgrFrt    := Nil
	Local lLockFunb  := .F.

	Default lShowTabFr  := .T.

	Private oGFEXFBFLog := GFEXFBFLog():New()
	Private aTcfQtd := {}
	Private aComps2
	Private aComps3 := {}
	// As três variáveis a seguir são utilizadas pela função SaveLog()
	Private cArqLog
	Private cTxtLog  := ""    	// Variável utilizada em todo o programa para geracao de arquivo de log
	Private lSaveLog 	:= .T. 	// Indica se salva ou não o log (arquivo)
	Private lError   := .F.   // Indica se houve erro durante uma das etapas do processo de calculo
	Private oProcess := nil   // Variável que receberá a regua de processamento
	Private lSimulacao		  // Indica se é simulação ou não
	Private lConsNeg 		  // Recebe o parâmetro lConsNeg
	Private lDelDBF  		  // Indica se os arquivos temporários devem ser eliminados
	Private iTipoSim      	  // Recebe o parâmetro iTpSimul
	Private aTabFrete		  // Recebe os dados de tabela de frete para cálculo.
	Private aErroCalc := {} //Recebe o número do cálculo relacionado ao número do erro.
	Private lOrigLote
	Private lHideProcess
	Private lCalcServ
	Private nNumRegSTF // Numero de registros da tabela temporário TRBSTF
	Private cServTpImp
	Private lCalcDataBase := .T.
	Private lSimNegEspec  := .F. // Indica se a simulação é específica com negociação informada, nesse caso Class Frete, Tipo Operação e Vigência são desconsiderados
	Private lErrSelTab    := .F.
	Private aTcfTodas     := {}

	Private nPesCub:=0, nQtdFaixa, nQtPrazo
	Private cTrcDes
	Private cTrpDes
	Private cCepDsGU3 := ""
	Private lLstTre   := .F.
	Private lRegDC    := .F.
	Private cDCDest   := ""
	Private lGW1Enc
	Private cPedRom  := ""
	Private aDelTpVc := {} //Indica se deverá deletar as outras tabelas selecionadas caso encontrar uma tabela válida por carga fechada.
	Private lTabInf := .F.
	Private cGW1CDDEST := CriaVar('GW1_CDDEST',.F.)
	Private cGW1CDREM  := CriaVar('GW1_CDREM',.F.)
	Private cGW1CDTPDC := CriaVar('GW1_CDTPDC',.F.)
	Private cGW1EMISDC := CriaVar('GW1_EMISDC',.F.)
	Private cGW1ENTNRC := CriaVar('GW1_ENTNRC',.F.)
	Private cGW1NRDC   := CriaVar('GW1_NRDC',.F.)
	Private cGW1NRREG  := ""
	Private cGW1SERDC  := CriaVar('GW1_SERDC',.F.)
	Private cGW1FILIAL := CriaVar('GW1_FILIAL',.F.)

	Private aCompLiq   := {}

	/*************************************************************/
	/* VARIAVEIS QUE SERÃO UTILIZADAS DENTRO DO FONTE GFEXFBA.PRW*/
	/*************************************************************/
	Private aAgrFrt := {}
	Private idpGRU := 1 // posição do array de agrupamento cTRBAGRU
	Private idxGRU := 1 // Indice da array de agrupamento cTRBAGRU
	Private _aCmpGRU := {"NRAGRU",;	//Numero do Agrupador
						 "CDTRP" ,;	//Transportador
						 "CDTPVC",;	//Tipo de Veiculo
						 "CDCLFR",;	//Classificacao de Frete
						 "CDTPOP",;	//Tipo de Operacao
						 "DISTAN",;	//Distancia Percorrida
						 "NRCIDD",;	//Cidade Destino
						 "CEPD"  ,;	//CEP Destino
						 "ERRO"  }	//Parametro criado para verificação de erro no momento da montagem do cálculo do romaneio
	
	/*************************************************************/

	Private aDocCarg := {}
	Private aDocCar2
	Private idpDOC := 1 // posição do array de Documentos de carga cTRBDOC
	Private idxDOC := 1 // Indice da array de Documentos de carga cTRBDOC
	Private _aCmpDOC := {"EMISDC",; //Emitente do Documento
						 "SERDC" ,; //Serie do Documento
						 "NRDC"  ,; //Numero do Documento
						 "CDTPDC",; //Tipo do Documento
						 "CDREM" ,; //Remetente do Documento
						 "CDDEST",; //Destinatario do Documento
						 "ENTEND",; //Endereco de Entrega
						 "ENTBAI",; //Bairro de entrega
						 "ENTNRC",; //Cidade de Entrega
						 "ENTCEP",; //CEP de Entrega
						 "NRREG" ,; //Região de destino
						 "TPFRET",; //Tipo de Frete
						 "ICMSDC",; //ICMS?
						 "USO"   ,; //Finalidade da mercadoria
						 "CARREG",; //Número do carregamento
						 "NRAGRU",; //Numero do Agrupador
						 "QTUNIT",; //Quantidade de Unitizadores
						 "UNITIZ",; //Codigo Unitizador
						 "FILIAL" } //Filial do Documento

	/*************************************************************/

	Private aTRBSTF1 // Indice 1
	Private aTRBSTF2 // Indice 2
	Private aTRBSTF3 // Indice 3

	Private idpSTF := 1 // posição do array de Documentos de carga cTRBSTF
	Private idxSTF := 1 // Indice da array de Documentos de carga cTRBSTF
	Private _aCmpSTF := {"NRROM"  ,; //Numero do Romaneio
						 "DOCS"   ,; //Documentos de Carga
						 "CDTRP"  ,; //Codigo do Transportador (Base ou Vinculo)
						 "NRTAB"  ,; //Numero da Tabela (Base ou Vinculo)
						 "NRNEG"  ,; //Negociacao (Base ou Vinculo)
						 "NRCALC" ,; //Numero do Calculo
						 "CDCLFR" ,; //Classificacao de Frete
						 "CDTPOP" ,; //Tipo Operacao
						 "CDFXTV" ,; //Seq. Faixa
						 "CDTPVC" ,; //Tipo de Veiculo
						 "NRROTA" ,; //Rota
						 "DESROT" ,; //Descricao da Rota
						 "DTVALI" ,; //Data Vigencia Inicio
						 "DTVALF" ,; //Data Vigencia Fim
						 "VLFRT"  ,; //Valor Frete
						 "PRAZO"  ,; //Prazo Entrega
						 "TPTAB"  ,; //Tipo Tabela (1=Normal; 2=Vinculo)
						 "EMIVIN" ,; //Emitente Vinculo (Original)
						 "TABVIN" ,; //Tabela Vinculo (Original)
						 "NRTAB1" ,; //Não usado. Mantido por compatibilidade.
						 "ATRFAI" ,; //Atributo da Faixa
						 "QTKGM3" ,; //K3/M3 - Fator de Cubagem
						 "UNIFAI" ,; //Unidade da Faixa
						 "TPLOTA" ,; //Tipo Lotacao
						 "TPVCFX" ,; //Grava se foi selecionada uma faixa ou um tipo de veiculo, usado na Simulação do Calculo de frete
						 "DEMCID" ,; //Indica se rota eh demais cidades
						 "QTFAIXA",; //Quantidade usada para determinação da faixa, usada como quantidade para calculo quando a rota eh selecionada
						 "CONTPZ" ,; //Indica a forma de contagem do prazo, dias corridos, uteis ou horas
						 "QTCOTA" ,; //Cota Do tipo de Veículo, para validação
						 "VLALUG" ,; //Valor da locação do tipo Veículo, para validação
						 "FRQKM"  ,;  //Franquia em km, para validação
						 "VLKMEX" ,;  //Valor excedente da franquia, para validação
						 "ERRO"   ,;
						 "TPROTA"} //Tipo da rota

	/*************************************************************/

	Private aTRBSIM1 := {} // Indice 1
	Private aTRBSIM2 := {} // Indice 2

	Private idpSIM := 1 // posição do array de Documentos de carga cTRBSIM
	Private idxSIM := 1 // Indice da array de Documentos de carga cTRBSIM

	Private _aCmpSIM :={"NRROM"  ,; //Numero do Romaneio
						"DOCS"   ,;
						"CDTRP"  ,;
						"NRTAB"  ,;
						"NRNEG"  ,;
						"NRCALC" ,;
						"CDCLFR" ,;
						"CDTPOP" ,;
						"CDFXTV" ,;
						"CDTPVC" ,;
						"NRROTA" ,;
						"DESROT" ,;
						"DTVALI" ,;
						"DTVALF" ,;
						"VLFRT"  ,;
						"PRAZO"  ,;
						"TPTAB"  ,;
						"EMIVIN" ,;
						"TABVIN" ,;
						"NRTAB1" ,;
						"ATRFAI" ,;
						"QTKGM3" ,;
						"UNIFAI" ,;
						"TPLOTA" ,;
						"DEMCID" ,;
						"QTFAIXA",;
						"TPVCFX" ,;
						"SELEC"  ,;
						"VALROT" ,;
						"VALFAI" ,;
						"VALTPVC",;
						"VALDATA",;
						"ROTSEL" ,;
						"ERRO"}

	/*************************************************************/
	Private aTRBGRB1 := {} // Indice 1
	Private aTRBGRB3 := {} // Indice 3

	Private idpGRB := 1 // posição do array de Documentos de carga
	Private idxGRB := 1 // Indice da array de Documentos de carga

	Private _aCmpGRB :={"NRGRUP",;
						"EMISDC",;
						"SERDC" ,;
						"NRDC"  ,;
						"CDTPDC",;
						"CDREM" ,;
						"CDDEST",;
						"ENTEND",;
						"ENTBAI",;
						"ENTNRC",;
						"ENTCEP",;
						"NRREG" ,;
						"TPFRET",;
						"USO"   ,;
						"CARREG",;
						"NRAGRU",;
						"QTUNIT"}
	/*************************************************************/
	Private aTRBTCF1 := {} // Indice 1
	Private aTRBTCF2 := {} // Indice 2

	Private idpTCF := 1 // posição do array de Documentos de carga cTRBTCF
	Private idxTCF := 1 // Indice da array de Documentos de carga cTRBTCF

	Private _aCmpTCF := {"NRCALC"   ,; //1
						 "CDCLFR"   ,; //2
						 "CDTPOP"   ,; //3
						 "SEQ"      ,; //4
						 "DTVIGE"   ,; //5
						 "ITEM"     ,; //6
						 "CDTRP"    ,; //7
						 "NRTAB"    ,; //8
						 "NRNEG"    ,; //9
						 "CDFXTV"   ,; //10
						 "CDTPVC"   ,; //11
						 "NRROTA"   ,; //12
						 "QTCALC"   ,; //13
						 "QTDE"     ,; //14
						 "PESOR"    ,; //15
						 "PESCUB"   ,; //16
						 "QTDALT"   ,; //17
						 "VALOR"    ,; //18
						 "VOLUME"   ,; //19
						 "NRGRUP"   ,; //20
						 "CDEMIT"   ,; //21
						 "PEDROM"   ,; //22
						 "PESPED"   ,; //23
						 "PRAZO"    ,; //24
						 "DELETADO" ,;
						 "PERCOUT"  ,; //26
						 "PESORORG"  ,;//27
						 "PESCUBORG" ,;//28
						 "VALORORG"  ,;//29
						 "VOLUMEORG" ,;//30
						 "QTDEORG"   ,;//31
						 "VALLIQ"     ;//32 VALOR LIQUIDO
						 }

	/*************************************************************/
	Private aTRBUNC1 := {} // Indice 1
	Private aTRBUNC2 := {} // Indice 2
	Private aTRBUNC3 := {} // Indice 3
	Private aTRBUNC4 := {} // Indice 4

	Private idpUNC := 1 // posição do array cTRBUNC
	Private idxUNC := 1 // Indice  da array cTRBUNC
	Private _aCmpUNC := {"NRCALC",; // 1
						 "TIPO"  ,; // 2
						 "FINALI",; // 3
						 "DTPREN",; // 4
						 "HRPREN",; // 5
						 "TPTRIB",; // 6
						 "BASICM",; // 7
						 "PCICMS",; // 8
						 "VLICMS",; // 9
						 "ICMRET",; // 10
						 "BASISS",; // 11
						 "PCISS" ,; // 12
						 "VLISS" ,; // 13
						 "BAPICO",; // 14
						 "VLPIS" ,; // 15
						 "VLCOFI",; // 16
						 "PCREIC",; // 17
						 "VALTAB",; // 18
						 "NRAGRU",; // 19
						 "IDFRVI",; // 20
						 "SEQTRE",; // 21
						 "CALBAS",; // 22
						 "ADICIS",; // 23
						 "CHVGWU",; // 24
						 "DELETADO",; // 25
						 "NRLCENT",;  // 26
						 "GRURAT",;   // 27
						 "BASIBS",;   // 28
						 "PCIBS",;    // 29
						 "VLRIBS",;   // 30
						 "BASCBS",;   // 31
						 "PCCBS",;    // 32
						 "VLRCBS",;   // 33
						 "IDTRIB"}    // 34




	/*************************************************************/
	Private aTRBTRE1 := {} // Indice 1
	Private aTRBTRE2 := {} // Indice 2
	Private aTRBTRE3 := {} // Indice 3
	Private aTRBTRE4 := {} // Indice 4

	Private idpTRE := 1 // posição do array cTRBTRE
	Private idxTRE := 1 // Indice  da array cTRBTRE
	Private _aCmpTRE := {"EMISDC",;  // 1
						 "SERDC" ,;  // 2
						 "NRDC"  ,;  // 3
						 "CDTPDC",;  // 4
						 "SEQ"   ,;  // 5
						 "CDTRP" ,;  // 6
						 "NRCIDD",;  // 7
						 "CDTPVC",;  // 8
						 "PAGAR" ,;  // 9
						 "NRCIDO",;  // 10
						 "CEPO"  ,;  // 11
						 "CEPD"  ,;  // 12
						 "CDCLFR",;  // 13
						 "CDTPOP",;  // 14
						 "ORIGEM",;  // 15
						 "DESTIN",;  // 16
						 "NRGRUP",;  // 17
						 "NRCALC",;  // 18
						 "DELETADO",; // 19 
						 "FILIAL"} // 20
	/*************************************************************/

	Private aTRBITE1 := {} // Indice 1
	Private aTRBITE2 := {} // Indice 2

	Private idpITE := 1 // posição do array cTRBITE
	Private idxITE := 1 // Indice  da array cTRBITE
	Private _aCmpITE := {"EMISDC",; // 1
						 "SERDC" ,; // 2
						 "NRDC"	,; // 3
						 "CDTPDC",; // 4
						 "ITEM"  ,; // 5
						 "CDCLFR",; // 6
						 "TPITEM",; // 7
						 "QTDE"  ,; // 8
						 "PESOR" ,; // 9
						 "PESOC" ,; // 10
						 "QTDALT",; // 11
						 "VALOR" ,; // 12
						 "VOLUME",; // 13
						 "TRIBP" ,; // 14
						 "VALLIQ",; // 15 VALOR LIQUIDO
						 "NRGRUP",; // 16 
						 "FILIAL"}  // 17
	/*************************************************************/

	Private aTRBCCF1 := {} // Indice 1
	Private aTRBCCF2 := {} // Indice 2
	Private aTRBCCF3 := {} // Indice 3

	Private idpCCF := 1 // posição do array cTRBCCF
	Private idxCCF := 1 // Indice  da array cTRBCCF
	Private _aCmpCCF := {"NRCALC" ,; // 1
						 "CDCLFR" ,; // 2
						 "CDTPOP" ,; // 3
						 "SEQ"    ,; // 4
						 "CDCOMP" ,; // 5
						 "CATVAL" ,; // 6
						 "QTDE"   ,; // 7
						 "VALOR"  ,; // 8
						 "TOTFRE" ,; // 9
						 "BASIMP" ,; // 10
						 "BAPICO" ,; // 11
						 "FREMIN" ,; // 12
						 "IDMIN"  ,; // 13
						 "VLFRMI" ,; // 14
						 "DELETADO" ,; // 15
						 "NRLCENT",; // 16
						 "CPEMIT"}   // 17
	/*************************************************************/
	Private aTRBPED := {} // Indice 2

	Private idpPED := 1 // posição do array cTRBPED
	Private idxPED := 1 // Indice  da array cTRBPED
	Private _aCmpPED := {"NRCALC" ,; // 1
						 "CDCLFR" ,; // 2
						 "CDTPOP" ,; // 3
						 "CDTRP"  ,; // 4
						 "NRTAB"  ,; // 5
						 "NRNEG"  ,; // 6
						 "TPLOTA" ,; // 7
						 "CDFXTV" ,; // 8
						 "CDTPVC" ,; // 9
						 "NRROTA" ,; // 10
						 "ATRFAI" ,; // 11
						 "UNIFAI" ,; // 12
						 "UNICAL" ,; // 13
						 "QTDE"   ,; // 14
						 "PESOR"  ,; // 15
						 "PESCUB" ,; // 16
						 "QTDALT" ,; // 17
						 "VALOR"  ,; // 18
						 "VOLUME" ,; // 19
						 "VLPED"  ,; // 20
						 "QTCALC" ,; // 21
						 "CDCOMP" ,; // 22
						 "VALLIQ"  ; // 23
						}   
	/*************************************************************/
	Private aTRBENT1 := {} // Indice 1
	Private aTRBENT2 := {} // Indice 2
	Private aTRBENT3 := {} // Indice 3
	
	Private idpENT := 1 // posição do array cTRBTRE
	Private idxENT := 1 // Indice  da array cTRBTRE
	Private _aCmpENT := {"NRLCENT",; // Local Entrega
						 "CDTRP" ,; // Transportador
						 "SEQTRE",; // Sequencia do Trecho
						 "ORIGEM",; // Cidade de Origem
						 "DESTIN",; // Cidade de Destino
						 "CDREM" ,; // Remetente
						 "CDDEST",;// Destinatário
						 "ENTNRC",; //Cidade de Entrega
						 "ENTEND",; //Endereco de Entrega
						 "ENTBAI",; //Bairro de entrega
						 "CDCOMP",; // Componente
						 "CDCLFR",; // Classificacao de Frete
						 "CDTPOP",; // Tipo de Operacao
						 "QTDCOMP",;	// Quantidade de Componentes Entrega compartilhado.
						 "QTDENTR"}	// Quantidade de UNIDADES Entrega compartilhado.
	/*************************************************************/
	
	Private idpROT := 1 // posição do array cTRBTRE
	Private idxROT := 1 // Indice  da array cTRBTRE
	Private aTRBROT1 := {} // Indice 1	"NRCALC" "CDTRP" "NRTAB" "NRNEG" "NRROTA" "CDFXTV" "PRIORI"				 
	Private _aCmpROT := {"NRCALC"  ,; //Numero do Calculo
						 "CDTRP"   ,; //Chave negociação pai
						 "NRTAB"   ,; //Chave negociação pai
						 "NRNEG"   ,; //Chave negociação pai
						 "NRROTA"   ,; //Chave negociação pai
						 "CDFXTV"  ,; //Chave negociação pai
						 "CDTRPCOD",; //Chave negociação filha
						 "NRTABCOD",; //Chave negociação filha
						 "NRNEGCOD",; //Chave negociação filha
						 "PRIORI"  ,; //Prioridade
						 "PRIFAI"  ,; //Prioridade faixa
						 "NRRTTOD" ,; //Todas as rotas
						 "CDFXTOD" }  //Todas as faixas
	
	/*************************************************************/

	/*************************************************************/
	/* VARIAVEIS QUE SERÃO UTILIZADAS DENTRO DO FONTE GFEXFBA.PRW*/
	/*************************************************************/
	Private lNovoMod 		:= .T. 
	Private lTabTemp 		:= .F.
	Private nClones 		:= 0
	Private aTabelaFrt

	Private pdtCalcPed      := dDtCalcPed

	Default aAgrFrt1  		:= {}
	Default aTblFrt  		:= {}
	Default lReal    		:= .T.
	Default iLogProc 		:= 2 // Sempre apresenta tela de finalização do cálculo
	Default nTabProv 		:= 0
	Default lParCons 		:= .F.
	Default iTpSimul 		:= 0 // Simulação geral (todas as opções)
	Default lCalcLote		:= .F.
	Default lHideProgress 	:= .F.
	Default lLog			:= .T.
	Default lServ			:= .F.
	Default pServTpImp		:= "1"
	Default pCalcDataBase 	:= .T.
	Default aNoCalc 		:= {}
	
	If Type("aTblFrFUNB") == "U"
		aTblFrFUNB := {}
	EndIf
	
	paNoCalc := aNoCalc

	If ValType(nTabProv) != "N"
		nTabProv := 0
	EndIf
 
	If !FWIsInCallStack("GFEA050")
		CheckSuaviza(@aDocCarg1, @aTrchDoc, @aItDoc)
	EndIf

	// Transfere os parâmetros recebidos para as variáveis "private"
	aAgrFrt 		:= aAgrFrt1
	aDocCarg		:= aDocCarg1
	lSimulacao 		:= !lReal
	lDelDBF    		:= lReal
	lConsNeg   		:= lParCons
	iTipoSim   		:= iTpSimul
	aTabelaFrt 		:= aTblFrt
	lOrigLote  		:= lCalcLote
	lHideProcess	:= lHideProgress
	lSaveLog		:= lLog
	lCalcServ     	:= lServ
	cServTpImp		:= pServTpImp
	lCalcDataBase	:= pCalcDataBase

	lTabTemp := !lNovoMod 
	
	oGFEXFBFLog:setSaveLog(lSaveLog)
	
	// Realiza a alteração para o tipo de veículo dos Agrupadores
	For nX := 1 To Len(aAgrFrt)
		If !Empty(aAgrFrt[nX][3]) .And. GFXCP12118("GV3_TPVCCL") .And. GV3->(dbSeek(xFilial("GV3") + aAgrFrt[nX][3]))
			If !Empty(GV3->GV3_TPVCCL)
				cLogAlt += "Modificado o Tipo de Veículo do Agrupador " + aAgrFrt[nX][1] + " de acordo com o Tipo de Veículo Alternativo(GV3_TPVCCL)" + CRLF
				cLogAlt += "Valor Antigo: " + AllTrim(aAgrFrt[nX][3]) + "-" + AllTrim(GV3->GV3_DSTPVC) + CRLF
				aAgrFrt[nX][3] := GV3->GV3_TPVCCL
				cLogAlt += "Valor Alterado: " + AllTrim(aAgrFrt[nX][3]) + "-" + AllTrim(Posicione("GV3",1,xFilial("GV3") + aAgrFrt[nX][3],"GV3_DSTPVC")) + CRLF + CRLF
			EndIf
		EndIf
	Next nX
	
	// Realiza a alteração para o tipo de veículo dos Trechos
	For nX := 1 To Len(aTrchDoc)
		If !Empty(aTrchDoc[nX][8]) .And. GFXCP12118("GV3_TPVCCL") .And. GV3->(dbSeek(xFilial("GV3") + aTrchDoc[nX][8]))
			If !Empty(GV3->GV3_TPVCCL)
				cLogAlt += "Modificado o Tipo de Veículo do Trecho " + aTrchDoc[nX][5] + " de acordo com o Tipo de Veículo Alternativo(GV3_TPVCCL)" + CRLF
				cLogAlt += "Valor Antigo: " + AllTrim(aTrchDoc[nX][8]) + "-" + AllTrim(GV3->GV3_DSTPVC) + CRLF
				aTrchDoc[nX][8] := GV3->GV3_TPVCCL
				cLogAlt += "Valor Alterado: " + AllTrim(aTrchDoc[nX][8]) + "-" + AllTrim(Posicione("GV3",1,xFilial("GV3") + aTrchDoc[nX][8],"GV3_DSTPVC")) + CRLF + CRLF
			EndIf
		EndIf
	Next nX
	
	// Suavização do campo GW8_VALLIQ
	if Len(aItDoc[1]) <= 14
		axItDoc := aClone(aItDoc)
		aSize(aItDoc, 0 ) 
		aItDoc := {}
		For nX := 1 To Len(axItDoc)
			AADD(aItDoc,{	axItDoc[nX,01],;
							axItDoc[nX,02],;
							axItDoc[nX,03],;
							axItDoc[nX,04],;
							axItDoc[nX,05],;
							axItDoc[nX,06],;
							axItDoc[nX,07],;
							axItDoc[nX,08],;
							axItDoc[nX,09],;
							axItDoc[nX,10],;
							axItDoc[nX,11],;
							axItDoc[nX,12],;
							axItDoc[nX,13],;
							axItDoc[nX,14],;
							0}) // GW8_VALLIQ ?? Assumir o valor axItDoc[nX,12] ou zero?? 
		Next nX
	EndIf


	If !Empty(aAgrFrt[1][1])
		cAgrFrt := AllTrim(aAgrFrt[1][1])
	EndIf
	
	cNow := GFENOW()

	oGFEXFBFLog:setAgrFrt(cAgrFrt)
	oGFEXFBFLog:NovoLog()
	cArqLog := oGFEXFBFLog:getArqLog() 
	
	if lSaveLog
		GFETrace(GFETraceCfg(), "[Calculo de Frete] Inicio [" + GFENOW(,, " ",,,.F.) + "]")
		GFETrace(GFETraceCfg(), "[Calculo de Frete] Otimização de performance (Novo Modo): " + cValToChar(lNovoMod))
		GFETrace(GFETraceCfg(), "[Calculo de Frete] Armazenamento em Array: " + cValToChar(!lTabTemp))
		GFETrace(GFETraceCfg(), "[Calculo de Frete] Gravar Log: " + cValToChar(lSaveLog))
	EndIF
	
	AddToLog(STR0001 + DTOC(DATE()) + STR0002 + TIME() + CRLF + CRLF) //"LOG DE CALCULO DE FRETE - Iniciado em "###", as "
	AddToLog(STR0003 + IF(lReal,STR0004,STR0005) + CRLF) //"Gravar cálculos ou apenas simular? "###"GRAVAR"###"SIMULAR"
	AddToLog(IIF(lNovoMod,  'TABELA TEMPORARIA: NAO / ARRAY: SIM','TABELA TEMPORARIA: SIM / ARRAY: NAO') + CRLF)
	AddToLog('Realiza consulta tabela GVR (MV_GFEGVR): ' + IIF(s_GFEGVR,'SIM','NAO') + CRLF)
	AddToLog('Realiza consulta tabela GUL (MV_GFEGUL): ' + IIF(s_GFEGUL,'SIM','NAO') + CRLF)
	AddToLog('Realiza consulta tabela de frete de vinculo (MV_GFEVIN): ' + IIF(s_GFEVIN,'SIM','NAO') + CRLF)
	If !lReal
		AddToLog(STR0499 + IF(iTpSimul==0,STR0500,STR0501) + CRLF) //"Tipo de Simulação: "###"TODAS OPÇÔES"###"OPÇÂO ÚNICA"
	EndIf

	Do Case
		Case iLogProc == 0 // Não mostrar Log em tela
			AddToLog(STR0006 + STR0502 + CRLF) //"Log do processo: " //"NÃO MOSTRAR LOG EM TELA"
		Case iLogProc == 1 // Somente quando ocorrer Erro
			AddToLog(STR0006 + STR0008 + CRLF) //"Log do processo: "###"SOMENTE QUANDO ERRO"
		Case iLogProc == 2 // Mostrar Sempre 
			AddToLog(STR0006 + STR0007 + CRLF) //"Log do processo: "###"MOSTRAR SEMPRE" 
	EndCase

	AddToLog(STR0009 + IF(nTabProv != 0,STR0010,STR0011) + CRLF) //"Calculando provisão? "###"SIM"###"NÂO"
	If lCalcServ
		If !IsInCallStack("GFEA032CA")
			AddToLog("Calculando serviço? SIM - POR ROMANEIO" + CRLF)
		Else
			AddToLog("Calculando serviço? SIM - POR OCORRÊNCIA" + CRLF)
		EndIf
	Else
		AddToLog("Calculando serviço? NÃO" + CRLF)
	EndIf

	If s_MULFIL == "1"
		AddToLog("Calcular Romaneio com DCs de Filiais diferentes? SIM" + CRLF)
	Else
		AddToLog("Calcular Romaneio com DCs de Filiais diferentes? NÃO" + CRLF)
	EndIf

	If aTabelaFrt != NIL .AND. len(aTabelaFrt) > 0
	
		If Len(aTabelaFrt) == 19
			aSize(aTabelaFrt,20)
			aTabelaFrt[20] := ""
			aTabelaFrt[21] := ""
		EndIf
		
		If Len(aTabelaFrt) == 20
			aSize(aTabelaFrt,21)
			aTabelaFrt[21] := ""
		EndIf

		If aTabelaFrt[19] == Nil
			aTabelaFrt[19] := {{{}}}
		ElseIf Len(aTabelaFrt[19]) == 0
			aTabelaFrt[19] := {{{}}}
		EndIf
		
		if !Empty(aTabelaFrt[21]) 
			AddToLog("Tabela de Frete Informada em Contrato de Transporte: " + aTabelaFrt[21] + CRLF)
		EndIf
		
		AddToLog(STR0503 + aTabelaFrt[1] + STR0067 + aTabelaFrt[2] + STR0068 + aTabelaFrt[20] + CRLF) //"Tabela de frete informada: Transp. "###"; Tabela "###"; Negoc. "
		
		If !Empty(aTabelaFrt[1]) .And. !Empty(aTabelaFrt[2]) .And. !Empty(aTabelaFrt[20])
			lSimNegEspec := .T.
		EndIf
		
	EndIf

	AddToLog(CRLF)

	// Validação dos parâmetros de provisao
	If nTabProv == 1
		cMV_EMIPRO := SuperGetMv("MV_EMIPRO",.F.,"")
		cMV_TABPRO := SuperGetMv("MV_TABPRO",.F.,"")
		cMV_NEGPRO := SuperGetMv("MV_NEGPRO",.F.,"")
		If (ValType(cMV_EMIPRO) == "L" .AND. !cMv_EMIPRO) .OR. (ValType(cMV_EMIPRO) == "C" .AND. AllTrim(cMV_EMIPRO) == "")
			AddToLog(STR0012 + CRLF ) //"ERRO!!! Parâmetro MV_EMIPRO não foi definido ou não possui valor!!!"
			GFEXFBAEC("GEN", 1)
			lError := .T.
		EndIf
		If (ValType(cMV_TABPRO) == "L" .AND. !cMv_TABPRO) .OR. (ValType(cMV_TABPRO) == "C" .AND. AllTrim(cMV_TABPRO) == "")
			AddToLog(STR0013 + CRLF ) //"ERRO!!! Parâmetro MV_TABPRO não foi definido ou não possui valor!!!"
			GFEXFBAEC("GEN", 2)
			lError := .T.
		EndIf
		If (ValType(cMV_NEGPRO) == "L" .AND. !cMv_NEGPRO) .OR. (ValType(cMV_NEGPRO) == "C" .AND. AllTrim(cMV_NEGPRO) == "")
			AddToLog(STR0014 + CRLF ) //"ERRO!!! Parâmetro MV_NEGPRO não foi definido ou não possui valor!!!"
			GFEXFBAEC("GEN", 3)
			lError := .T.
		EndIf
		If lError	// Quando ocorrer erro aqui, as tabelas temporárias não serão criadas, logo não será necessário apagá-las
			AddToLog(STR0015 + CRLF ) //"Não é possível continuar o cálculo de provisão sem informar o(s) parâmetro(s) acima!"
			lDelDBF := .F.
		EndIf
	EndIf
	
	cNrRomLock := Alltrim(aAgrFrt[1][1])
	
	/*Chamado TUGIDW - Controle por semáforo*/
	If !lSimulacao
		lLockFunb := LockByName("GFEA050" + cNrRomLock ,.T.,.T.)
	EndIf
	
	//************************************
	//  CRIACAO DAS TABELAS TEMPORARIAS
	//************************************
	If !lError

		// Ponto de entrada para permitir a emissão de mensagem na geração
		// automática de romaneio a partir criação de embarque no ERP
		If ExistBlock("GFEXFB06")
			lRet := ExecBlock("GFEXFB06",.F.,.F.,{aAgrFrt[1][2], aAgrFrt[1][5]})
		EndIf

		IF lTabTemp
			If Type("cTRBAGRU") == "U" .Or. Select(cTRBAGRU) == 0
				XFUNBTRB() //Criação das tabelas temporárias
				lDelTRB := .T.
			ElseIf FindFunction("GFEDelTbData")
				GFEDelTbData(cTRBAGRU)// Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBDOC) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBTCF) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBUNC) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBTRE) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBITE) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBCCF) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBENT) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBSTF) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBSIM) // Apaga os dados da tabela temporária.
				GFEDelTbData(cTRBPED) // Apaga os dados da tabela temporária.
				lDelTRB := .F.
			EndIf
		Else
			cTRBAGRU := ''
			cTRBDOC  := ''
			cTRBTCF  := ''
			cTRBUNC  := ''
			cTRBTRE  := ''
			cTRBITE  := ''
			cTRBCCF  := ''
			cTRBENT  := ''
			For nX:= 1 to Len(aDocCarg)
				aDocCarg[nX,01] := PADR(ALLTRIM(aDocCarg[nX,01]),TamSX3("GU3_CDEMIT")[1])
				aDocCarg[nX,02] := PADR(ALLTRIM(aDocCarg[nX,02]),TamSX3("GW1_SERDC")[1])
				aDocCarg[nX,03] := PADR(ALLTRIM(aDocCarg[nX,03]),16)
				aDocCarg[nX,04] := PADR(ALLTRIM(aDocCarg[nX,04]),05)
				aDocCarg[nX,05] := PADR(ALLTRIM(aDocCarg[nX,05]),TamSX3("GU3_CDEMIT")[1])
				aDocCarg[nX,06] := PADR(ALLTRIM(aDocCarg[nX,06]),TamSX3("GU3_CDEMIT")[1])
				aDocCarg[nX,07] := PADR(ALLTRIM(aDocCarg[nX,07]),50)
				aDocCarg[nX,08] := PADR(ALLTRIM(aDocCarg[nX,08]),50)
				aDocCarg[nX,09] := PADR(ALLTRIM(aDocCarg[nX,09]),50)
				aDocCarg[nX,10] := PADR(ALLTRIM(aDocCarg[nX,10]),08)
				aDocCarg[nX,11] := PADR(ALLTRIM(aDocCarg[nX,11]),06)
				aDocCarg[nX,12] := PADR(ALLTRIM(aDocCarg[nX,12]),01)
				aDocCarg[nX,13] := PADR(ALLTRIM(aDocCarg[nX,13]),01)
				aDocCarg[nX,14] := PADR(ALLTRIM(aDocCarg[nX,14]),01)
				aDocCarg[nX,15] := PADR(ALLTRIM(aDocCarg[nX,15]),12)
				aDocCarg[nX,16] := PADR(ALLTRIM(aDocCarg[nX,16]),TamSX3("GWN_NRROM")[1])
			Next
		EndIf
		
		/*Chamado TUGIDW - Controle por semáforo*/
		If !lLockFunb .And. !lSimulacao
			AddToLog("O Documento " + cNrRomLock + " está sendo calculado por outro usuário. Tente mais tarde." + CRLF) 
	       lError := .T.
	       GFEXFBAEC('GEN', 26, {cNrRomLock,"GWN"})
	       aAdd(aRet, !lError)	// [1] Cálculo Ok/ Cálculo com Erro
	       aAdd(aRet, cArqLog) // [2] Arquivo de log
	       aAdd(aRet, aErroCalc) // [3] Array com os erros dos Cálculos.
	       aAdd(aRet, {'',''})
	       aAdd(aRet, '')
	       aAdd(aRet, '')
	       aAdd(aRet, .F.)
	    EndIf

		If !lError
			If IsBlind() .OR. lHideProcess
				AddToLog(cLogAlt)
			
				RunProc(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, nTabProv, lShowTabFr)
			Else
				AddToLog(cLogAlt)
				
				oProcess := MsNewProcess():New({|| RunProc(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, nTabProv, lShowTabFr)}, "Calculando frete", "Iniciando processo...")
				oProcess:Activate()
			EndIf			
		EndIf		
	EndIf	// !lError

	AddToLog(CRLF + "*** " + STR0565 + DTOC(DATE()) + STR0002 + TIME() + CRLF ) //"Cálculo de frete finalizado em " 

	If lSaveLog
		GFETrace(GFETraceCfg(), "[Calculo de Frete] Fim [" + GFENOW(,, " ",,,.F.)+ "]")
	EndIf

	oGFEXFBFLog:SaveLog()

	// Início Ponto de Entrada - Usina Fortaleza
	If ExistBlock("GFEXFB07")
		ExecBlock("GFEXFB07",.f.,.f.,{lError})
	EndIf
	// Fim Ponto de Entrada - Usina Fortaleza
	
	If !FwIsInCallStack("GFECalcCarga")
		If iLogProc == 1 
			If lError .And. !IsBlind()
				ShowErrLog(cArqLog)
			EndIf
		Else
			If iLogProc == 2 .And. !IsBlind()
				ShowErrLog(cArqLog)
			EndIf
		EndIf
	EndIf
	
	If lLockFunb .And. !lSimulacao
		UnlockByName("GFEA050" + cNrRomLock ,.T.,.T.)
	EndIf

	If (Type("cTRBAGRU") == "C" .And. !Empty(cTRBAGRU)) .OR. lTabTemp
		GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
		While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
			If GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO") == "1"
				AADD(aErroDoc,GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0) 
		EndDo
	EndIf

	/* Adiciona valores no vetor aRet para o retorno da função*/
	aAdd(aRet, !lError)	// [1] Cálculo Ok/ Cálculo com Erro
	aAdd(aRet, cArqLog) // [2] Arquivo de log
	aAdd(aRet, aErroCalc) // [3] Array com os erros dos Cálculos.
	aAdd(aRet, aErroDoc)

	//***********************************
	//*EXCLUSAO DAS TABELAS TEMPORARIAS *
	//***********************************
	If (lDelDBF .Or. !lSimulacao /*lSaveLog*/ ) .And. Type("cTRBAGRU") == "C" .And. !Empty(cTRBAGRU) // Verificar se as tabelas foram criadas
		IF lTabTemp .And. lDelTRB
			XFUNBDLTRB() //Deleção das tabelas temporárias
		EndIf
		IIF(aTRBGRB3==NIL,,aSize(aTRBGRB3,0))
		IIF(aTRBTCF1==NIL,,aSize(aTRBTCF1,0))
		IIF(aTRBUNC1==NIL,,aSize(aTRBUNC1,0))
		IIF(aTRBTRE1==NIL,,aSize(aTRBTRE1,0))
		IIF(aTRBCCF3==NIL,,aSize(aTRBCCF3,0))
		aTRBGRB3 := Nil
		aTRBTCF1 := Nil
		aTRBUNC1 := Nil
		aTRBTRE1 := Nil
		aTRBCCF3 := Nil
	Else
		aAdd(aRet, aTRBGRB3)	// Array para ser utilizado para listar a simulações
		aAdd(aRet, aTRBTCF1)
		aAdd(aRet, lTabTemp)
		aAdd(aRet, aTRBUNC1)
		aAdd(aRet, aTRBTRE1)
		aAdd(aRet, aTRBCCF3)
		aAdd(aRet, aTRBSIM1)
		aAdd(aRet, cTRBCCF )
	EndIf

	Iif(aDocCar2==NIL,,aSize(aDocCar2, 0 ) )
	aSize(_aCmpDOC, 0 ) 
	aSize(_aCmpGRU, 0 )
	aSize(_aCmpSIM, 0 )
	aSize(_aCmpGRB, 0 )
	aSize(_aCmpTCF, 0 )
	aSize(_aCmpUNC, 0 )
	aSize(_aCmpTRE, 0 )
	aSize(_aCmpITE, 0 )
	aSize(_aCmpSTF, 0 )
	aSize(_aCmpCCF, 0 )
	IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
	IIF(aTRBSTF2==NIL,,aSize(aTRBSTF2,0))
	IIF(aTRBSTF3==NIL,,aSize(aTRBSTF3,0))
	IIF(aTRBGRB1==NIL,,aSize(aTRBGRB1,0))
	IIF(aTRBTCF2==NIL,,aSize(aTRBTCF2,0))
	IIF(aTRBUNC2==NIL,,aSize(aTRBUNC2,0))
	IIF(aTRBUNC3==NIL,,aSize(aTRBUNC3,0))
	IIF(aTRBTRE2==NIL,,aSize(aTRBTRE2,0))
	IIF(aTRBTRE3==NIL,,aSize(aTRBTRE3,0))
	IIF(aTRBTRE4==NIL,,aSize(aTRBTRE4,0))
	IIF(aTRBITE2==NIL,,aSize(aTRBITE2,0))
	IIF(aTRBCCF1==NIL,,aSize(aTRBCCF1,0))
	IIF(aTRBCCF2==NIL,,aSize(aTRBCCF2,0))
	IIF(aTRBENT1==NIL,,aSize(aTRBENT1,0))
	IIF(aTRBENT2==NIL,,aSize(aTRBENT2,0))
	IIF(aTRBENT3==NIL,,aSize(aTRBENT3,0))
	aDocCar2 := Nil
	_aCmpDOC := Nil
	_aCmpGRU := Nil
	_aCmpSIM := Nil
	_aCmpGRB := Nil
	_aCmpUNC := Nil
	_aCmpTRE := Nil
	_aCmpITE := Nil
	_aCmpCCF := Nil
	_aCmpSTF := Nil
	_aCmpTCF := Nil
	aTRBSTF1 := Nil
	aTRBSTF2 := Nil
	aTRBSTF3 := Nil
	aTRBGRB1 := Nil
	aTRBTCF2 := Nil
	aTRBUNC2 := Nil
	aTRBUNC3 := Nil
	aTRBUNC4 := Nil
	aTRBTRE2 := Nil
	aTRBTRE3 := Nil
	aTRBTRE4 := Nil
	aTRBITE2 := Nil
	aTRBCCF1 := Nil
	aTRBCCF2 := Nil
	aTRBENT1 := Nil
	aTRBENT2 := Nil
	aTRBENT3 := Nil
	
	oGFEXFBFLog:Destroy()
	
Return aRet // FIM GFEClcFrt()

/*----------------------------------------------------------------------------
{Protheus.doc} RunProc
Agrupa as rotinas de cálculo em uma única função para uso na régua de processamento

@sample RunProc(aAgrFrt,aDocCarg,aTrchDoc,aItDoc,nTabProv,lShowTabFr)

@author Luciano de Araujo
@since 19/05/10
@version 1.0
----------------------------------------------------------------------------*/
Static Function RunProc(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, nTabProv, lShowTabFr)
	Local nX, nY
	Local aDBFAgr
	Local aDBFDoc
	Local aDBFTre
	Local aDBFIte
	Local aChave        := {}
	Local lLocalEntrega := IIf(s_TREENTR == "1",.T.,.F.) 
	Local lNaoPagoPto   := .F.
	Local cInfoLine     := If(!lSimulacao,"1;","2;") // Linha que será adicionada no início do Log contendo com informações dos DC's
	Local oGFETempTable	:= GFEXFBTempTable():New()
	Local lRedespacho	:= .F.
	Local aAux          := {}
	Local aNfCalc       := {}
	Local cOriPres      := ""
	Local cMV_CALRET    := SuperGetMv("MV_CALRET",.F.,"2")
	Local cNumCalc      := ""
	Local cTipoCalc     := ""
	Local cOriCalc      := "" 
	Local cAliasDoc     := ""
	Local cAliasCalc    := ""

	Private aAereo      := {}

	oGFETempTable:ClearData()
	oGFETempTable:setAgrupadoresCarga()
	aDBFAgr := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setDocumentoCarga()
	aDBFDoc := oGFETempTable:getTableStruct()
	
	oGFETempTable:ClearData()
	oGFETempTable:setTrechoCarga()
	aDBFTre := oGFETempTable:getTableStruct()
	
	oGFETempTable:ClearData()
	oGFETempTable:setItensCarga()
	aDBFIte := oGFETempTable:getTableStruct()
	
	oGFETempTable:Destroy()

	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua1(5)
		oProcess:incRegua1(OemToAnsi(STR0016)) //"Processando dados de entrada..."
	EndIf

	// Reordenação dos arrays para corrigir entradas fora da sequencia
	aSort(aAgrFrt ,,,{|x,y| x[1]  < y[1]})
	//aSort(aDocCarg,,,{|x,y| x[1]+x[2]+x[3]+x[4]      < y[1]+y[2]+y[3]+y[4]})
	aSort(aDocCarg,,,{|x,y| x[16]+x[1]+x[2]+x[3]      < y[16]+y[1]+y[2]+y[3]})
	aSort(aTrchDoc,,,{|x,y| x[01]+x[2]+x[3]+x[4]+x[5] < y[01]+y[2]+y[3]+y[4]+y[5]})
	aSort(aItDoc  ,,,{|x,y| x[01]+x[2]+x[3]+x[4]      < y[01]+y[2]+y[3]+y[4]})
	
	//***********************************
	// ALIMENTA TABELAS TEMPORARIAS
	//***********************************

	//alimenta as tabelas temporarias com o conteudo dos vetores (parametros)
	AddToLog(STR0566 + CRLF + CRLF) //"1. Gravação dos dados recebidos em arquivos temporários..."

	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(len(aAgrFrt))
	EndIf
	AddToLog(STR0567 + CRLF) //"  > Agrupadores"
	IIF(lTabTemp,dbSelectArea(cTRBAGRU),)
	For nX := 1 To Len(aAgrFrt)
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(OemToAnsi("Agrupadores de Carga..."))
		EndIf
		IIF(lTabTemp,RecLock(cTRBAGRU,.T.),)
		For nY := 1 To (Len(aDBFAgr)-1)
			IIF(lTabTemp,&("(cTRBAGRU)->"+(aDBFAgr[nY,1])) := aAgrFrt[nX,nY],)
			If aDBFAgr[nY,1] == "NRAGRU"
				cInfoLine += "A"+AllTrim(cValToChar(aAgrFrt[nX,nY]))+";" //salva os agrupadores na variável que será aplicada na primeira linha.
			EndIf
			AddToLog(IF(nY==1,"  ","") + cValToChar(aAgrFrt[nX,nY]) + If(nY != Len(aDBFAgr), "|", CRLF),,.F.)
		Next nY
		IIF(lTabTemp,&("(cTRBAGRU)->"+(aDBFAgr[9,1])) := "0",) //Preenche o campo ERRO da tabela temporaria
		IIF(lTabTemp,(cTRBAGRU)->(MsUnLock()),)
		IIF(!lTabTemp,aAgrFrt[nX,1] := PADR(aAgrFrt[nX,1],TamSX3("GWN_NRROM")[1]),)  
	Next nX

	AddToLog(CRLF)

	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(len(aDocCarg))
	EndIf
	AddToLog(CRLF + STR0569 + CRLF) //"  > Documentos de Carga"
	IIF(lTabTemp,dbSelectArea(cTRBDOC),)
	For nX := 1 To Len(aDocCarg)
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(OemToAnsi("Documentos de Carga..."))
		EndIf
		IIF(lTabTemp,RecLock(cTRBDOC,.T.),)
		For nY := 1 To Len(aDBFDoc)
			IIF(lTabTemp,&("(cTRBDOC)->"+(aDBFDoc[nY,1])) := aDocCarg[nX,nY],)
			If aDBFDoc[nY,1] == "NRDC"
				cInfoLine += "D"+AllTrim(cValToChar(aDocCarg[nX,nY]))+";" //salva os documentos de carga na variável que será aplicada na primeira linha do log.
			EndIf
			AddToLog(IF(nY==1, "  ", "") + cValToChar(aDocCarg[nX,nY]) + If(nY != Len(aDBFDoc), "|", CRLF),,.F.)
		Next nY
		IIF(lTabTemp,(cTRBDOC)->(MsUnLock()),)
		IIF(!lTabTemp,aDocCarg[nX,16] := PADR(aDocCarg[nX,16],TamSX3("GWN_NRROM")[1]),)  
	Next nX
	
	oGFEXFBFLog:setInfoLine(cInfoLine) 
	
	aDocCar2 := aClone(aDocCarg)
	aSort(aDocCar2,,,{|x,y| x[4]+x[1]+x[2]+x[3]      < y[4]+y[1]+y[2]+y[3]})
	
	AddToLog(CRLF)

	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(len(aTrchDoc))
	EndIf
	
	For nX := 1 To Len(aTrchDoc)
		If Len(aTrchDoc[nX]) < 14
			aAdd(aTrchDoc[nX],"")
			aAdd(aTrchDoc[nX],"")
			aAdd(aTrchDoc[nX],"")
			aAdd(aTrchDoc[nX],"")
			aAdd(aTrchDoc[nX],"")
		EndIf
	Next nX
	
	AddToLog(CRLF + STR0571 + CRLF) //"  > Trechos dos Documentos de Carga"
	IIF(lTabTemp,dbSelectArea(cTRBTRE),)
	For nX := 1 To Len(aTrchDoc)
		if aTrchDoc[nX,05] == '02'
			lRedespacho	:= .T.
		EndIf
		IIF(lTabTemp,RecLock(cTRBTRE,.T.),)
		For nY := 1 To (Len(aDBFTre)-4)  //Campos "ORIGEM", "DESTIN", "NRGRUP" e "NRCALC" sao internos
			If !IsBlind() .AND. lHideProcess == .F.
				oProcess:incRegua2(OemToAnsi("Trechos dos Documentos de Carga...")	)
			EndIf
			IIF(lTabTemp,&("(cTRBTRE)->"+(aDBFTre[nY,1])) := aTrchDoc[nX,nY],)
			AddToLog(IF(nY==1, "  ", "") + cValToChar(aTrchDoc[nX,nY]) + If(nY != Len(aDBFTre)-4, "|", CRLF),,.F.)
		Next nY
		IIF(lTabTemp,(cTRBTRE)->(MsUnLock()),)
		IF !lTabTemp
			AADD(aTRBTRE2,{	aTrchDoc[nX,01],;
							aTrchDoc[nX,02],;
							aTrchDoc[nX,03],;
							aTrchDoc[nX,04],;
							aTrchDoc[nX,05],;
							aTrchDoc[nX,06],;
							aTrchDoc[nX,07],;
							aTrchDoc[nX,08],;
							aTrchDoc[nX,09],;
							aTrchDoc[nX,10],;
							aTrchDoc[nX,11],;
							aTrchDoc[nX,12],;
							aTrchDoc[nX,13],;
							aTrchDoc[nX,14],;
							Space(TamSx3("GU3_NRCID")[1]),;
							Space(TamSx3("GU3_NRCID")[1]),;
							Space(06),;
							Space(06),;
							"0",;
							aTrchDoc[nX,15]})
		EndIf
	Next nX
	
	IF !lTabTemp
		aSort(aTRBTRE2,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
	EndIf

	AddToLog(CRLF)

	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(len(aItDoc))
	EndIf
	AddToLog(CRLF + STR0573 + CRLF) //"  > Itens dos Documentos de Carga"
	For nX := 1 To Len(aItDoc)
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(OemToAnsi("Itens dos Documentos de Carga..."))
		EndIf
		IIF(lTabTemp,RecLock(cTRBITE,.T.),)
		For nY := 1 To (Len(aDBFIte)-1)  //Campo "NRGRUP" eh interno
			IIF(lTabTemp,&("(cTRBITE)->"+(aDBFIte[nY,1])) := aItDoc[nX,nY],)
			AddToLog(IF(nY==1, "  ", "") + cValToChar(aItDoc[nX,nY]) + If(nY != Len(aDBFIte)-1, "|", CRLF),,.F.)
		Next nY
		IF lTabTemp
			(cTRBITE)->(MsUnLock())
		Else
			AADD(aTRBITE1,{	aItDoc[nX,01],;
							aItDoc[nX,02],;
							aItDoc[nX,03],;
							aItDoc[nX,04],;
							aItDoc[nX,05],;
							aItDoc[nX,06],;
							aItDoc[nX,07],;
							aItDoc[nX,08],;
							aItDoc[nX,09],;
							aItDoc[nX,10],;
							aItDoc[nX,11],;
							aItDoc[nX,12],;
							aItDoc[nX,13],;
							aItDoc[nX,14],;
							aItDoc[nX,15],;
							Space(06),;
							aItDoc[nX,16]})
		EndIf
	Next nX

	IF !lTabTemp
		aSort(aTRBITE1,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
	EndIf

	//Alimenta campos internos "ORIGEM" e "DESTIN"
	AddToLog(CRLF + STR0575 + CRLF + CRLF) //"  # Definição de 'Cidade Origem' e 'Cidade Destino' para os trechos:"
	cOriPres := ""
	cDestin  := ""
	cOrigem  := ""
	cChave   := ""

	//So pode calcular ICMS se o transportador for pessoa Juridica
	GFEXFB_BORDER(lTabTemp,cTRBTRE,02,7)
	GFEXFB_2TOP(lTabTemp, cTRBTRE, @aTRBTRE2, 7) 
	Do While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE2, 7)
		//Verifica se a origem do prestador de serviço está preechida
		If !Empty(cOriPres)
			cOrigem	:= cOriPres
		Else
			// A origem do 1o trecho sempre é o remetente do documento de carga
			// A partir do 2o trecho, a origem do trecho é o destino do trecho anterior
			If cChave != GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")
				GWN->(dbSetOrder(01) )
				If GWN->(dbSeek(xFilial("GWN")+GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")) .AND.  GFEVerCmpo({"GWN_NRCIDO"}) .AND. !Empty(GWN->GWN_NRCIDO) )
					cOrigem := GWN->GWN_NRCIDO
				Else
					cOrigem := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDO")
					
					If Empty(cOrigem)
						GFEXFB_BORDER(lTabTemp,cTRBDOC,2,1) 
						If GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")}) 
							cOrigem := Posicione("GU3",1,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDREM"),"GU3_NRCID") //GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDREM"),"GU3_NRCID")
						EndIf
					EndIf
				EndIf
			Else
				If Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDO"))
					cOrigem := If(Empty(cDestin) , Posicione("GU3",1,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP"),"GU3_NRCID") , cDestin)
				Else
					cOrigem := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDO")
				EndIf
			EndIf
		EndIf
		// Na geração de cálculos de serviço para documentos de carga com redespacho,
		// é necessário enviar todos os trechos para buscar corretamente a Origem e Destino
		If IsInCallStack("GFEA032CA") .And. lCalcServ .And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP") != GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTRP")

			cChave :=  GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC")+ GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC")+ GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC")+ GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")
			aChave := {GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")}
			

			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"PAGAR","2")
			cDestin := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDD")
		Else
			cChave :=  GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC")+ GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC")+ GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC")+ GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")
			aChave := {GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")}
			nRecTRE := GFEXFB_GRECNO(lTabTemp, cTRBTRE, 7) 

			cDestin := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDD")

			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
			If !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE2, 7) .And. cChave == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")
				//Se houver destino informado no trecho assume a cidade destino informado, caso contrario assume a cidade do
				//transportador do trecho seguinte, exceto o ultimo trecho, que tem outro tratamento
				if Empty(cDestin)
					cDestin := Posicione("GU3",1,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP"),"GU3_NRCID")
				EndIf
			Else
				if !lCalcServ // Ultimo trecho
					cDestin := GFECidDest(aChave)
				EndIf
			EndIf
			GFEXFB_HGOTO(lTabTemp, cTRBTRE, 7, nRecTRE)

			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"ORIGEM",cOrigem)
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"DESTIN",cDestin)

			AddToLog("    " + 	STR0576 + " (" + ;
								STR0577 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC") + "; " + ;
								STR0578 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC") + "; " + ;
								STR0579 + " " + Transform(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"), "!!!")  + "; " + ; //"Trecho" ### "Tp.Doc." ### "Emis." ### "Série"
								STR0580 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")   + "; " + ;
								STR0581 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ")    + ") -> " + ;
								STR0582 + " " + AllTrim(cOrigem) + ", " + ;
								STR0583 + " " + AllTrim(cDestin) + CRLF) //"Nr.Doc." ### "Seq." ### "Origem" ### "Destino"

		Endif
		GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
	EndDo

	AddToLog(CRLF + STR0584 + CRLF + CRLF) //"  # Selecionando apenas trechos pagos para calculo..."

	IF !lTabTemp
		aTRBTRE1 := {}
	EndIf
	GFEXFB_2TOP(lTabTemp, cTRBTRE, @aTRBTRE2, 7)
	While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE2, 7)
		lNaoPagoPto := .F.
		AddToLog("    " + STR0576 + " (" + ;
							STR0577 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC") + "; " + ;
							STR0578 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC") + "; " + ;
							STR0579 + " " + Transform(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"), "!!!")  + "; " + ; //"Trecho" ### "Tp.Doc." ### "Emis." ### "Série"
							STR0580 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")   + "; " + ;
							STR0581 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ") + ")") //"Nr.Doc." ### "Seq."
		
		//Ponto de entrada validação Vicunha
		If lPEXFB08
			lNaoPagoPto := ExecBlock("GFEXFB08",.f.,.f.,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ")})
		EndIf
		

		//Agrupamento Frete Aéreo	
		If GFXCP12130("GU3_AGRDC")
	
			If !empty(aAux) //Não é a primeira nota
				
				//Verifica se é o trecho seguinte da mesma nota
				If aAux[1] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC") .And. ;
				   aAux[2] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC") .And. ;
				   aAux[3] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC") .And. ;
				   aAux[4] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC") 
				
				   
				   	//Inclui Transportador de Destino no Array
					aAdd(aAux,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP")) //9
					
					//Inclui Trecho no array de Transporte Aereo
					aAdd(aAereo,aAux)
					
					aAux := {}
					 
				EndIf 
			EndIF
			
		EndIF
		
		If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"PAGAR") == "2" .Or. lNaoPagoPto	// Trecho nao é pago
			If !lLocalEntrega .Or. lNaoPagoPto
	  			if lTabTemp
	  				(cTRBTRE)->(dbDelete())
	  			Else
	  				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"DELETADO","1")
	  			EndIf
			EndIf
			AddToLog(STR0585 + CRLF) //" NÃO é pago. Retirando do processo de calculo."
		Else
			
			//Agrupamento Frete Aéreo	
			If GFXCP12130("GU3_AGRDC")
				
				//Verifica se tem frete aéreo e Agrupamento por Redespachante 
				lTemAereo := Posicione("GU3",01,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP"),"GU3_AGRDC") == "2"
				
				//Se tem frete aéreo e agrupamento por transportador, inclui no array
				IF lTemAereo
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC") ) //1
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC") ) //2
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC") )  //3
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC") )   //4
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ") )    //5
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDO") ) //6
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP") )  //7
					aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDD") ) //8
				EndIf
			EndIf
				
			// Faz a copia do registro 
			IF !lTabTemp
				AADD(aTRBTRE1,{	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDD"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPVC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"PAGAR"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDO"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CEPO"  ),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CEPD"  ),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDCLFR"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPOP"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"ORIGEM"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"DESTIN"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRGRUP"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCALC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"DELETADO"),;
								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"FILIAL")})
			EndIf
			AddToLog(STR0586 + CRLF)
		EndIf
		GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
	EndDo

	IF !lTabTemp
		aTRBTRE3 := aClone(aTRBTRE1)
		aTRBTRE2 := aClone(aTRBTRE1)
		aSort(aTRBTRE2,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
		aSort(aTRBTRE3,,,{|x,y| x[17]+x[05]+x[15]+x[16]       < y[17]+y[05]+y[15]+y[16]})
	EndIf

	// Salva o conteudo de cTxtLog no arquivo indicado por cArqLog
	oGFEXFBFLog:SaveLog()
	
	if lRedespacho 
		If aTabelaFrt != NIL .AND. len(aTabelaFrt) > 0
			if !Empty(aTabelaFrt[21])
				AddToLog(CRLF)
				AddToLog("!!Tabela de Frete Informada em Contrato de Transporte: " + aTabelaFrt[21] + " será desconsiderada do cálculo pois existe redespacho"+ CRLF)
				AddToLog("!!Somente Romaneio sem redespacho é considerado para negociação informada em Contrato de Transporte"+ CRLF)
				lSimNegEspec := .F.
				aSize(aTabelaFrt, 0 )
				aTabelaFrt := {}
			EndIf
		EndIf
	EndIf

	//***************************************************************************
	//DEFINIR UNIDADES DE CALCULO
	//***************************************************************************
	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:incRegua1("Definindo unidades de cálculo...")
	Endif
	DefUnidCalc()
	oGFEXFBFLog:SaveLog()

	If !lError
		If !IsBlind() .AND. lHideProcess == .F. .And. lLocalEntrega 
			oProcess:incRegua1("Definindo locais de entrega...")
		Endif
		
		//------------------------------------------------------------------------------
		//Local Entrega                                                            
		//------------------------------------------------------------------------------
		If lLocalEntrega
			AddToLog(CRLF + "  # Parâmetro MV_TREENTR habilitado..." + CRLF + CRLF)
			LocEntrg()
		EndIf
	EndIf

	//***************************************************************************
	//SELECAO DE TABELA DE FRETE
	//***************************************************************************
	If !lError .Or. lOrigLote
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua1("Selecionando tabelas para cálculo...")
		EndIf
		SELTABFRT(nTabProv,lShowTabFr) // NOVA FUNÇAO GFEXFBE
		lErrSelTab := lError
		oGFEXFBFLog:SaveLog()
	EndIF

	//------------------------------------------------------------------------------
	//CALCULAR FRETE
	//------------------------------------------------------------------------------
	If !lError .Or. lOrigLote
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua1("Calculando valores de frete...")
		EndIf
		GFECalcFrete()
		oGFEXFBFLog:SaveLog()
	EndIf
	
	If cMV_CALRET == "1"	
		cOriCalc  := "1" // Indica que a origem da chamada é pelo Romaneio 
	EndIf
	
	//------------------------------------------------------------------------------
	//GRAVAR FRETE
	//------------------------------------------------------------------------------
	If !lError .AND. !lSimulacao
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua1("Gravando valores de frete...")
		EndIf
		GFEGravaFrete(nTabProv,cOriCalc)
		oGFEXFBFLog:SaveLog()
	EndIf
	
	// Atribui % de Devolução no Cálculo de Retorno
	If cMV_CALRET == "1"
		cAliasDoc := GetNextAlias()
		
		AddToLog(CRLF + "  # Parâmetro MV_CALRET habilitado..." + CRLF + CRLF)
		BeginSql Alias cAliasDoc
			SELECT GV5.GV5_TPTRP 
			FROM %Table:GV5% GV5
			WHERE GV5.GV5_FILIAL = %Exp:FWxFilial("GV5")% 
			AND GV5.GV5_CDTPDC   = %Exp:aTRBTRE2[1][4]%
			AND GV5.GV5_TPTRP    = '2'
			AND GV5.GV5_SENTID IN ('0','1')
			AND GV5.%NotDel%
		EndSql
	
		While ((cAliasDoc)->(!Eof())) 
			cAliasCalc    := GetNextAlias()	
			
			BeginSql Alias cAliasCalc
				SELECT GWF.GWF_NRCALC
				FROM %Table:GWF% GWF 
				WHERE GWF.GWF_FILIAL = %Exp:aTRBTRE2[1][20]%
				AND GWF.GWF_NRROM    = %Exp:aTRBUNC1[1][19]%
				AND GWF.%NotDel%
			EndSql
			
			While ((cAliasCalc)->(!Eof())) 
				cNumCalc  := (cAliasCalc)->GWF_NRCALC
				cTipoCalc := "5" // Calculo de devolução
					
				AADD(aNfCalc,{aTRBTRE3[1][1],;
							aTRBTRE3[1][2],;
							aTRBTRE3[1][3],;
							aTRBTRE3[1][4],})

				AddToLog(CRLF + "  Atribuindo % de Devolução no Cálculo " + cNumCalc + " de Retorno..." + CRLF + CRLF)
				GFECalcMan(aNfCalc,cNumCalc,,cTipoCalc,0,,.F.,,cOriCalc) 
			
				(cAliasCalc)->(DbSkip())
			EndDo

			(cAliasCalc)->(dbCloseArea())
		
			(cAliasDoc)->(DbSkip())
		EndDo

		(cAliasDoc)->(dbCloseArea())
	EndIF

	aSize( aChave, 0 )
	aChave := nil

Return .T.	//FIM RunProc()


/*----------------------------------------------------------------------------
Retorna o numero da cidade de destino, baseando-se num dos documentos de carga
da unidade de cálculo.
----------------------------------------------------------------------------*/
Static Function GFECidDest(aChaveDC)

	Local cCidDest := ""
	Local aAreaDOC  := GFEXFB_9GETAREA(lTabTemp, cTRBDOC, 1)
	Local aAreaAGRU := GFEXFB_9GETAREA(lTabTemp, cTRBAGRU, 0)
	Local aAreaTRE  := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7)
	Local aAreaGU3  := GU3->(getArea())
	Local nRecTRE := GFEXFB_GRECNO(lTabTemp, cTRBTRE, 7)

	GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1)
	If GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,aChaveDC)

		// Verifica se foi informada cidade de destino no agrupador de documentos de carga
		GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)

		// Em caso positivo, assume esta cidade como cidade de destino
		if GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"NRAGRU")}) .AND. ;
			!Empty(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRCIDD"))
			cCidDest := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRCIDD")
		Else
			If !Empty(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"ENTNRC")) .AND. GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"ENTNRC") != PADR("0",50)
				// Se a cidade de entrega do documento foi informada, esta sera a cidade de destino
				cCidDest := GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"ENTNRC")
			Else
				GFEXFB_BORDER(lTabTemp,cTRBTRE,02,7)
				if GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE2, 7,aChaveDC)
					While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE2, 7) ;
						.And. aChaveDC[1]+aChaveDC[2]+aChaveDC[3]+aChaveDC[4] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")
						
						cCidDest := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDD")
					GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
					EndDo
				EndIf
				
				If Empty(cCidDest)
				// Senao assume a cidade destino do destinatario do documento
					cCidDest := Posicione("GU3",1,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDDEST"),"GU3_NRCID")
				EndIf
			EndIf
		EndIf
	EndIf

	GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7)
	GFEXFB_ARESTAREA(lTabTemp,aAreaDOC,1)
	GFEXFB_ARESTAREA(lTabTemp,aAreaAGRU,0)
	RestArea(aAreaGU3)
	GFEXFB_HGOTO(lTabTemp, cTRBTRE, 7, nRecTRE)
Return LEFT(cCidDest,TamSx3("GU3_NRCID")[1])

/*----------------------------------------------------------------------------
{Protheus.doc} DefUnidCalc
Define Unidades de Calculo.
Uso: GFECLCFRT

@sample DefUnidCalc()

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Static Function DefUnidCalc()

	Local nNumGrup := nNumCalc := 1
	Local cNumGrup
	Local nQtdDoc  := 0
	Local nMaxDoc  := 999
	Local cChave   := ""
	Local nUnCalc
	Local nCalc
	Local nX	:= 0
	Local nY	:= 0
	Local nQtdTCF   := 0
	Local nPerRatTCF
	Local cNrRom := ""
	Local cCriRat := If(Empty(GetNewPar("MV_CRIRAT", "1")), "1", GetNewPar("MV_CRIRAT", "1"))
	Local cCpoCrgTCF := GFETcfCampoCrg(cCriRat)
	Local nComps2
	Local _aPE15 := {.F.,''}
	Local aAreaTRE
	Local cMV_INTTMS := SuperGetMv("MV_INTTMS",.F.,.F.)
	Local lFirst := .T.
	Local aAereoCalc := {}
	Local nI       := 0
	Local nPosAgr  := 0
	Local nPosCalc := 0

	AddToLog(CRLF + STR0017 + CRLF + CRLF) //"2. Definindo unidades de cálculo..."

	GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
	GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)

	//Caso nao seja informado um agrupador de carga, sera considerado que todos
	//os documentos de carga informados a rotina pertencem a uma unica carga
	AddToLog(STR0018 + CRLF + CRLF) //"  # Agrupando documentos em entregas..."
	If GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0) 						

		// Criar um agrupador ficticio
		GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU", "99999999")

		// atualizar o mesmo nos documentos de carga recebidos
		GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1)
		GFEXFB_2TOP(lTabTemp, cTRBDOC, @aDocCarg, 1)
		while !GFEXFB_3EOF(lTabTemp, cTRBDOC, @aDocCarg, 1)
			GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU", GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))
			GFEXFB_8SKIP(lTabTemp, cTRBDOC, 1)
		EndDo

		// Agrupar em entregas
		GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1)
		GFEXFB_2TOP(lTabTemp, cTRBDOC, @aDocCarg, 1)
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:setRegua2(GFEXFB_FRECCOUNT(lTabTemp, cTRBDOC, @aDocCarg))
		EndIf
		While !GFEXFB_3EOF(lTabTemp, cTRBDOC, @aDocCarg, 1)
			If !IsBlind() .AND. lHideProcess == .F.
				oProcess:incRegua2(OemtoAnsi(STR0019)) //"Agrupando documentos em entregas..."
			EndIf
			AddToLog(STR0020 + StrZero(nNumGrup,06) + CRLF + CRLF) //"    Carga única: "
			AADD(aTRBGRB1,{	StrZero(nNumGrup,06),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDREM"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDDEST"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTEND"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTBAI"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTNRC"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTCEP"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRREG"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"TPFRET"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"USO"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CARREG"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"QTUNIT")})

			GFEAtribGrp(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC"),;
						GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC"), ;
						GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC"),  ;
						GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC"),;
						StrZero(nNumGrup,06))

			GFEXFB_8SKIP(lTabTemp, cTRBDOC, 1)
			AddToLog(CRLF)
		EndDo
	Else

		// Cria subgrupos de carga que identificam uma entrega,
		// subdividindo os documentos (cTRBDOC) dos agrupamentos (cTRBAGRU)
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:setRegua2(Len(aAgrFrt)) 
		EndIf
		While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0) 
			If !IsBlind() .AND. lHideProcess == .F.
				oProcess:incRegua2(OemtoAnsi(STR0019)) //"Agrupando documentos em entregas..."
			EndIf
			GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1)
			GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCarg, 1,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")}) 

			While !GFEXFB_3EOF(lTabTemp, cTRBDOC, @aDocCarg, 1) .And. GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU") 

				GFEXFB_BORDER(.F.,,04,4)
				
				If lPEXFB10
					cNumGrup := ExecBlock("GFEXFB10",.f.,.f.,{GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC"),;
																	GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC"), ;
																	GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC"),;
																	GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC"),;  
																	GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU")})
				Else
					if GFEXFB_CSEEK(.F.,, @aTRBGRB1, 4,{GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU"),;
																	 GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDREM")  ,;
																	 GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDDEST") ,;
																	 GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTNRC") ,;
																	 GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTBAI") ,;
																	 GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTEND")})
						cNumGrup := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRGRUP")
					Else
						cNumGrup := StrZero(nNumGrup++,06)
					EndIf
				EndIf
				
				AddToLog(STR0021 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU") + ;
						 STR0022 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC") + ;
						 STR0023 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC") + ;
						 STR0024 + Transform(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC"), "!!!")  + ;
						 STR0025 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC")   + ;
						 STR0026 + cNumGrup + CRLF + CRLF) //"    Agrupador "###", Doc.Carga (Tp.Doc. "###"; Emis. "###"; Série " "; Nr.Doc. "###") -> Grupo de Entrega "

				AADD(aTRBGRB1,{	cNumGrup,;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDREM"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDDEST"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTEND"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTBAI"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTNRC"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTCEP"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRREG"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"TPFRET"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"USO"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CARREG"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU"),;
								GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"QTUNIT")})

				GFEAtribGrp(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC"),;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC") ,;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC")  ,;
							GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC"), cNumGrup)

				GFEXFB_8SKIP(lTabTemp, cTRBDOC, 1)
				AddToLog(CRLF)
			EndDo

			GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0)
		EndDo
	EndIf

	//Agrupamento Frete Aéreo	
	If GFXCP12130("GU3_AGRDC")
		
		//Verifica todos os trechos da nota 
		/*GFEXFB_1AREA(lTabTemp,cTRBTRE, @aTRBTRE2) 
		GFEXFB_BORDER(lTabTemp,cTRBTRE,02,7) 
		GFEXFB_2TOP(lTabTemp, cTRBTRE, @aTRBTRE2, 7) 
		While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE2, 7) 
	
			If !empty(aAux) //Não é a primeira nota
				
				//Verifica se é o trecho seguinte da mesma nota
				If aAux[1] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC") .And. ;
				   aAux[2] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC") .And. ;
				   aAux[3] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC") .And. ;
				   aAux[4] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC") 
				
				   	//Inclui Transportador de Destino no Array
					aAdd(aAux,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP")) //9
					
					//Inclui Trecho no array de Transporte Aereo
					aAdd(aAereo,aAux)
					 
				EndIf 
			EndIF
		
			//Verifica se tem frete aéreo e Agrupamento por Redespachante 
			aAux := {}
			lTemAereo := Posicione("GU3",01,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP"),"GU3_AGRDC") == "2"
			
			//Se tem frete aéreo e agrupamento por transportador, inclui no array
			IF lTemAereo
				
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC") ) //1
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC") ) //2
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC") )  //3
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC") )   //4
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ") )    //5
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDO") ) //6
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTRP") )  //7
				aAdd( aAux, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRCIDD") ) //8
			EndIf
			
			GFEXFB_1AREA(lTabTemp,cTRBTRE, @aTRBTRE2)
			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
			
		EndDo*/
		
		If !empty(aAereo)
		
			//Reordena o array por origem + transp + destino + redespachante
			aSort(aAereo,,,{|x,y| x[06]+x[07]+x[08]+x[09] < y[06]+y[07]+y[08]+y[09]})
			
			cOrigDest := ""
			
			//Agrupa os trechos conforme regras específicas frete aéreo
			For nI := 1 to Len(aAereo)
				
				If empty(cOrigDest) .Or. cOrigDest <> aAereo[nI][6]+aAereo[nI][7]+aAereo[nI][8]+aAereo[nI][9]
					
					cOrigDest := aAereo[nI][6]+aAereo[nI][7]+aAereo[nI][8]+aAereo[nI][9]
					cNumGrup := StrZero(nNumGrup++,06)
				
				EndIF
				
				aAdd(aAereo[nI], cNumGrup ) //10
				
			Next nI
		EndIf
	EndIF
		
		
	If !lTabTemp

		aTRBITE2 := aClone(aTRBITE1)
		aSort(aTRBITE1,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
		aSort(aTRBITE2,,,{|x,y| x[16]+x[06]+x[05]             < y[16]+y[06]+y[05]})

		IIF(aTRBTRE1==NIL,,aSize(aTRBTRE1,0))
		aTRBTRE1 := {}
		For nX := 1 to len(aTRBTRE2)
			if aTRBTRE2[nX,19] == "0"
				AADD(aTRBTRE1, {aTRBTRE2[nx,01], aTRBTRE2[nx,02], aTRBTRE2[nx,03], aTRBTRE2[nx,04], aTRBTRE2[nx,05], aTRBTRE2[nx,06], aTRBTRE2[nx,07],; 
								aTRBTRE2[nx,08], aTRBTRE2[nx,09], aTRBTRE2[nx,10], aTRBTRE2[nx,11], aTRBTRE2[nx,12], aTRBTRE2[nx,13], aTRBTRE2[nx,14],;
								aTRBTRE2[nx,15], aTRBTRE2[nx,16], aTRBTRE2[nx,17], aTRBTRE2[nx,18], aTRBTRE2[nx,19], aTRBTRE2[nx,20]})
			EndIf
		Next Nx

		aTRBTRE2 := aClone(aTRBTRE1)
		aTRBTRE3 := aClone(aTRBTRE1)
		aTRBTRE4 := aClone(aTRBTRE1)
		aSort(aTRBTRE1,,,{|x,y| x[18]                         < y[18]})
		aSort(aTRBTRE2,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
		aSort(aTRBTRE3,,,{|x,y| x[17]+x[05]+x[15]+x[16]       < y[17]+y[05]+y[15]+y[16]})
		aSort(aTRBTRE4,,,{|x,y| x[17]+x[03]+x[05]+x[15]+x[16] < y[17]+y[03]+y[05]+y[15]+y[16]})
	EndIf

	//Cria unidades de calculo conforme redespacho, baseado nas sub-divisoes dos agrupamentos de documentos (entregas).
	AddToLog(STR0027 + CRLF + CRLF) //"  # Criando unidades de cálculo baseado nos trechos..."

	//Para cada trecho alimenta Unidade de Calculo respectiva.
	GFEXFB_BORDER(lTabTemp,cTRBTRE,03,7)
	GFEXFB_2TOP(lTabTemp, cTRBTRE, @aTRBTRE3, 7)
	
	
	If Type("aTcomps") == 'U'
       aComps2 := GFEXCOMP(aTblFrFUNB)
    Else
       aComps2 := aTcomps
    EndIf
    
	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(IIF(lTabTemp,GFENumReg(cTRBTRE)*Len(aComps2),Len(aTRBTRE3)*Len(aComps2)))
	EndIf
	
	While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE3, 7) //
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(Oemtoansi(STR0028)) //"Criando Unidades de Calculo..."
		EndIf
		
		If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"PAGAR") == "2"
			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
			Loop
		EndIf
		
		lFirst := .T.
		cChave := 	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRGRUP") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"ORIGEM") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"DESTIN") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTRP")
		
		If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"PAGAR") != "2"
			cNumCalc := StrZero(nNumCalc++,06)
		EndIf
		If !Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTRP")) .AND. Posicione("GU3",01,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTRP"),"GU3_MAXDOC") > 0
			nMaxDoc := Posicione("GU3",01,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTRP"),"GU3_MAXDOC")
		EndIf
		nQtdDoc := 0

		// Início Ponto de Entrada Britania
		If lPEAgru
			aRotAdic := ExecBlock("XGFEAGRU",.f.,.f.,{nMaxDoc,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTPDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"EMISDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SERDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRDC")})
			nMaxDoc := aRotAdic
		EndIf
		// Fim Ponto de Entrada Britania
		
		While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE3, 7) .And. ;
				cChave == 	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRGRUP") + ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ")    + ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"ORIGEM") + ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"DESTIN") + ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTRP")
			If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"PAGAR") != "2"
			
				_aPE15[1] := .F.
				_aPE15[2] := '' // Critério de agrupamento padrão. No momento não tem nenhum, mas poderá ser criado um padrão
				If lPEXFB15
					_aPE15 := ExecBlock("GFEXFB15",.f.,.f.,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTPDC"),;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"EMISDC"),;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SERDC"),;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRDC"),;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ"),;
															_aPE15[2]}) // Critério de agrupamento padrão. No momento não tem nenhum, mas poderá ser criado um padrão
				EndIf

				If ++nQtdDoc > nMaxDoc .OR. _aPE15[1]
					if _aPE15[1]
						AddToLog(CRLF + "Ponto de Entrada GFEX015 criou nova unidade de cálculo. Valor rateio por romaneio poderá ser modificado conforme novo agrupador" + CRLF)
					Else
						AddToLog(CRLF + STR0029 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTRP") + " - " + STR(nMaxDoc) + STR0030 + CRLF) //"      [Numero máximo de documentos atingido: Transp. "###" documentos]"
					EndIf
					nQtdDoc := 1
					cNumCalc := StrZero(nNumCalc++,06)
				EndIf
			
				//Verifica se é frete aéreo, neste caso tem regra diferente de agrupamento
				nPosAgr :=  aScan( aAereo,{ |x| x[1]+x[2]+x[3]+x[4]+x[5] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTPDC") + ;
				  														    GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"EMISDC") +; 	
																		    GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SERDC") + ;
																		    GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRDC") + ;
																		    GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ") }) 
				 
				If nPosAgr > 0
			 	 	//Verifica se o agrupamento já tem unidade de cálculo relacionada
			 	 	nPosCalc := aScan( aAereoCalc , { |x| x[1] == aAereo[nPosAgr][10]  }) 
			 	 	If nPosCalc > 0 
			 	 		//Relaciona a unidade de cálculo já existente
			 	 		cNumCalc := aAereoCalc[nPosCalc][2]
				 		If lFirst
			 				nNumCalc--
		 				EndIF
			 		Else
			 			//Define nova unidade de cálculo para o agrupamento aéreo
			 			If !lFirst
			 				cNumCalc := StrZero(nNumCalc++,06)
	 					EndIF
		 				aAdd(aAereoCalc,{ aAereo[nPosAgr][10], cNumCalc } )
			 		EndIF
				 	
				EndIf
				lFirst := .F.
				
				AddToLog(	STR0031 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTPDC") + ;
							STR0023 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"EMISDC") + ;
							STR0024 + Transform(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SERDC"),"!!!")  + ;
							STR0025 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRDC")   + ; //"    Trecho (Tp.Doc. "###"; Emis. "###"; Série "###"; Nr.Doc. "###
							STR0032 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ")    + ;
							STR0033 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRGRUP") + ;
							STR0034 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTRP")  + ;
							STR0035 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"ORIGEM") + ;
							STR0036 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"DESTIN")) //"; Seq. "###"), Grupo "###", Transp. "###", Orig. "###"; Dest. "
							
				GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
				If !GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC1, 6,{cNumCalc})
					
  					GFEXFB_BORDER(.F.,,03,4)
  					GFEXFB_CSEEK(.F., , @aTRBGRB1, 4,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRGRUP")}) 
					If lTabTemp
						RecLock(cTRBUNC,.T.)
						(cTRBUNC)->NRCALC := cNumCalc
						(cTRBUNC)->TIPO   := If(Val(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ")) > 1,"1","2")
						(cTRBUNC)->FINALI := ""
						(cTRBUNC)->VALTAB := .T.
  						(cTRBUNC)->NRAGRU := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU")
						(cTRBUNC)->IDFRVI := "2"
						(cTRBUNC)->SEQTRE := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ")
						(cTRBUNC)->GRURAT := _aPE15[2]
						(cTRBUNC)->CHVGWU := 	xFilial("GWU") + ;
												GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTPDC") + ;
												GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"EMISDC") + ;
												GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SERDC")  + ;
												GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRDC")   + ;
												GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ")
						(cTRBUNC)->(MsUnLock())
					Else
						AADD(aTRBUNC1,{	cNumCalc,; 												//"NRCALC"
										If(Val(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ")) > 1,"1","2"),; 					//"TIPO"  
										Space(01),;  											//"FINALI"
										StoD("  \  \  "),;  									//"DTPREN"
										Space(05),;  											//"HRPREN"
										Space(01),;  											//"TPTRIB"
										0,;  													//"BASICM"
										0,;  													//"PCICMS"
										0,;  													//"VLICMS"
										0,;  													//"ICMRET"
										0,;  													//"BASISS"
										0,;  													//"PCISS" 
										0,;  													//"VLISS" 
										0,;  													//"BAPICO"
										0,;  													//"VLPIS" 
										0,;  													//"VLCOFI"
										0,;  													//"PCREIC"
										.T.,; 													//"VALTAB"
	  									GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU"),; //"NRAGRU"
										"2",; 													//"IDFRVI"
										GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ"),; 	//"SEQTRE"
										Space(06),; 											//"CALBAS"
										Space(01),; 											//"ADICIS"
										GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"FILIAL") + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"CDTPDC") + ;
																								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"EMISDC") + ;
																								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SERDC")  + ;
																								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRDC")   + ;
																								GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"SEQ"),; //"CHVGWU"
										"0",;
										Space(6),;
										_aPE15[2],;
										0,;														//"BASIBS"
										0,;														//"PCIBS"
										0,;														//"VLRIBS"
										0,; 													//"BASCBS"
										0,; 													//"PCCBS"
										0,; 													//"VLRCBS"
										""}) 													//"IDTRIB"
					EndIf
				EndIf
				
				AddToLog(STR0037 + cNumCalc + CRLF) //" -> Unid. cálculo "
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE3, 7,"NRCALC",cNumCalc)
			
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
		EndDo
		
	EndDo
	
	If !lTabTemp
		aTRBUNC2 := aClone(aTRBUNC1)
		aTRBUNC3 := aClone(aTRBUNC1)
		aSort(aTRBUNC1  ,,,{|x,y| x[01]             < y[01]})
		aSort(aTRBUNC2  ,,,{|x,y| x[19]+x[01]       < y[19]+y[01]})
		aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})

		aTRBTRE1 := aClone(aTRBTRE3)
		aTRBTRE2 := aClone(aTRBTRE3)
		aTRBTRE4 := aClone(aTRBTRE3)
		aSort(aTRBTRE1,,,{|x,y| x[18]                         < y[18]})
		aSort(aTRBTRE2,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
		aSort(aTRBTRE3,,,{|x,y| x[17]+x[05]+x[15]+x[16]       < y[17]+y[05]+y[15]+y[16]})
		aSort(aTRBTRE4,,,{|x,y| x[17]+x[03]+x[05]+x[15]+x[16] < y[17]+y[03]+y[05]+y[15]+y[16]})
	EndIf
	
	If lCalcServ
		GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
		GFEXFB_2TOP(lTabTemp, cTRBTRE, @aTRBTRE1, 7)
		If lTabTemp
			aStruUNC := (cTRBUNC)->(dbStruct())
			aStruTRE := (cTRBTRE)->(dbStruct())
		EndIf
	
		aCopiaTRE := {}
		
		GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
		GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
		
		While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
			aAdd(aComps2[1,6],{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"),{}})
			GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
		EndDo
	EndIf
	
	If lCalcServ .And. Len(aComps2) >= 2 //Cria as unidades adicionais para receber os componentes
		While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) //
			cChave := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") 
			If !Empty(cChave)
				For nComps2 := 2 to Len(aComps2)
					GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
					GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC1, 6,{cChave})
					
					cNumCalc := StrZero(nNumCalc++,06)
					nPos := aScan(aComps2[1,6],{|x| x[1] == cChave})
					aAdd(aComps2[1,6,nPos,2],cNumCalc)
					If lTabTemp
						aLinha := {}
						For nX := 1 To Len(aStruUNC)
							aAdd(aLinha,(cTRBUNC)->(FieldGet(nX)))
						Next nX
						aLinha := {aClone(aLinha)}
						idpUNC := 1
						GFEXFB_5CMP(.F., , @aLinha, 6,"NRCALC"  , cNumCalc)
						RecLock(cTRBUNC,.T.)
						For nX := 1 To Len(aStruUNC)
							(cTRBUNC)->(FieldPut(nX, aLinha[1,nX] ))
						Next nX
						(cTRBUNC)->(msUnlock())
					Else
						aLinha := {aClone(aTRBUNC1[idpUNC])}
						idpUNC := 1
						GFEXFB_5CMP(.F., , @aLinha, 6,"NRCALC"  , cNumCalc)
						aAdd(aTRBUNC1,aClone(aLinha[1]))
						idpUNC := Len(aTRBUNC1)
					EndIf
					
					If lTabTemp
						aAreaTre := (cTRBTRE)->(GetArea())
					Else
						idpAnt2 := idpTRE
					EndIf
					While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == cChave
						
						If lTabTemp
							aLinha := {}
							For nX := 1 To Len(aStruTRE)
								aAdd(aLinha,(cTRBTRE)->(FieldGet(nX)))
							Next nX
							aLinha := {aClone(aLinha)}
							idpTRE := 1
							GFEXFB_5CMP(.F., , @aLinha, 7,"NRCALC"  , cNumCalc)
							aAdd(aCopiaTRE,aClone(aLinha[1]))
						Else
							idpAnt := idpTRE
							aLinha := {aClone(aTRBTRE1[idpTRE])}
							idpTRE := 1
							GFEXFB_5CMP(.F., , @aLinha, 7,"NRCALC"  , cNumCalc)
							idpTRE := idpAnt
							aAdd(aCopiaTRE,aClone(aLinha[1]))
						EndIf
					
						GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
					EndDo
					If Len(aComps2) != nComps2
						If lTabTemp
							RestArea(aAreaTre)
						Else
							idpTRE := idpAnt2 
						EndIf
					EndIf
				Next nComps2
			Else
				GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
			EndIf
		EndDo
		For nX := 1 To Len(aCopiaTRE)
			If !IsBlind() .AND. lHideProcess == .F.
				oProcess:incRegua2(Oemtoansi(STR0028)) //"Criando Unidades de Calculo..."
			EndIf
			If lTabTemp
				RecLock(cTRBTRE,.T.)
				For nY := 1 To Len(aStruTRE)
					(cTRBTRE)->(FieldPut(nY, aCopiaTRE[nX,nY] ))
				Next nX
				(cTRBTRE)->(msUnlock())
			Else
				aAdd(aTRBTRE1,aClone(aCopiaTRE[nX]))
			EndIf
		Next nX
	EndIf
	nClones := Len(aComps2)
	If !lTabTemp
		aTRBUNC2 := aClone(aTRBUNC1)
		aTRBUNC3 := aClone(aTRBUNC1)
		aSort(aTRBUNC1  ,,,{|x,y| x[01]             < y[01]})
		aSort(aTRBUNC2  ,,,{|x,y| x[19]+x[01]       < y[19]+y[01]})
		aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})

		aTRBTRE2 := aClone(aTRBTRE1)
		aTRBTRE3 := aClone(aTRBTRE1)
		aTRBTRE4 := aClone(aTRBTRE1)
		aSort(aTRBTRE1,,,{|x,y| x[18]                         < y[18]})
		aSort(aTRBTRE2,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
		aSort(aTRBTRE3,,,{|x,y| x[17]+x[05]+x[15]+x[16]       < y[17]+y[05]+y[15]+y[16]})
		aSort(aTRBTRE4,,,{|x,y| x[17]+x[03]+x[05]+x[15]+x[16] < y[17]+y[03]+y[05]+y[15]+y[16]})
	EndIf


	// Cria Tabela de Calculo de Frete, separando as unidades de calculo
	// por Classificacao de Frete e Tipo de Operacao
	AddToLog(CRLF + STR0038 + CRLF) //"  # Criando tabela de cálculo de frete..."
	GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
	GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(Len(aTRBUNC1))
	EndIf
	
	GWN->(dbSetOrder(1))
	
	While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
		
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(Oemtoansi(STR0039)) //"Identificando classificações/tipos de operação..."
		EndIf
		AddToLog(CRLF + STR0040 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") + CRLF) //"    Unid. cálculo "
		//localiza os trechos do calculo
		GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
		GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 
		While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC")

			//identifica o documento origem e percorre seus itens
			AddToLog(CRLF + STR0041 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") + ;
							STR0023 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") + ;
							STR0024 + Transform(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC"), "!!!")  + ;
							STR0025 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")   + ")" + CRLF) //"      Doc.Carga (Tp.Doc. "###"; Emis. "###"; Série "###"; Nr.Doc. "

			GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1)
			GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCarg, 1,{	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") , ;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC") }) 
			GFEXFB_BORDER(lTabTemp,cTRBITE,01,8)
			GFEXFB_CSEEK(lTabTemp, cTRBITE, @aTRBITE1, 8,{	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") , ;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") , ;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  , ;
															GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")})

			While !GFEXFB_3EOF(lTabTemp, cTRBITE, @aTRBITE1, 8) .And. ;
					GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDTPDC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") .And. ;
					GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"EMISDC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") .And. ;
					GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"SERDC")  == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  .And. ;
					GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRDC")   == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")

				cCdClFr := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDCLFR")
				cTpOper := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPOP")
				
				If Empty(cCdClFr) .Or. Empty(cTpOper)
					
					//pesquisa no grupo subdividido
					GFEXFB_BORDER(.F.,,03,4)
					If GFEXFB_CSEEK(.F.,, @aTRBGRB1, 4,{GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRGRUP")}) 
						//pesquisa no agrupamento(romaneio) do grupo
						GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
						If GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU")})
							If Empty(cCdClFr)
								cCdClFr := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDCLFR")
							EndIf
							If Empty(cTpOper)
								cTpOper := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPOP")
							EndIf
						EndIf
					EndIf
					
				EndIf

				//separando por classificacao de frete e tipo de operacao
				AddToLog(STR0042 + If(Empty(cCdClFr),GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR"),cCdClFr) + STR0043 + cTpOper + CRLF) //"        Class.Frete "###", Tp.Oper "
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
				If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), If(Empty(cCdClFr),GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR"),cCdClFr), cTpOper})
					AddToLog(STR0044 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE"  )) + ;
							 STR0045 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR" )) + ;
							 STR0046 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR" )) + ;
							 STR0047 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME")) + CRLF) //"        + Qtde. "###", Peso Real "###", Valor "###", Volume "
					If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE") == '01'
						nQtdTCF   += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8, cCpoCrgTCF)
					EndIf
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"  ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"  ) + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE")  ) 
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" ) + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR") )
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT",GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT") + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDALT"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" ) + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR") )
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME",GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME") + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ" ) + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALLIQ") )
				Else
					AddToLog(STR0048 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE"))  + ;
							 STR0045 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR")) + ;
							 STR0046 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR")) + ;
							 STR0047 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME")) + CRLF) //"          Qtde. "###", Peso Real "###", Valor "###", Volume "
					If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE") == '01'
						nQtdTCF += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8, cCpoCrgTCF)
					EndIf
					
					nPos := aScan(aTcfQtd, {|x|x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")})
					If nPos == 0
						aAdd(aTcfQtd,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"),0,0})
						nPos := Len(aTcfQtd)
					EndIf
					aTcfQtd[nPos,2]++
					if lTabTemp
						RecLock(cTRBTCF,.T.)
						(cTRBTCF)->NRCALC := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
						(cTRBTCF)->CDCLFR := If(Empty(cCdClFr),GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR"),cCdClFr)
						(cTRBTCF)->CDTPOP := cTpOper
						(cTRBTCF)->SEQ    := STRZERO((cTRBTCF)->(RecCount()) +1,4)
						
						(cTRBTCF)->ITEM  := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"ITEM")
						(cTRBTCF)->CDTRP := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP")
						(cTRBTCF)->QTDE   := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE")
						(cTRBTCF)->PESOR  := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR")
						(cTRBTCF)->QTDALT := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDALT")
						(cTRBTCF)->VALOR  := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR")
						(cTRBTCF)->VOLUME := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME")
						(cTRBTCF)->NRGRUP := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRGRUP")
						(cTRBTCF)->CDEMIT := GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDDEST")	// O destinatario será considerado para calcular os componentes por emitente da tabela encontrada
						(cTRBTCF)->VALLIQ := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALLIQ")
						(cTRBTCF)->(MsUnLock())
					Else
						AADD(aTRBTCF1,{	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"),;	//"NRCALC"
										If(Empty(cCdClFr),GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR"),cCdClFr),;//"CDCLFR"
										cTpOper,; 												//"CDTPOP"
										STRZERO(Len(aTRBTCF1) +1,4),; //"SEQ"   
										StoD("  \  \  "),; 										//"DTVIGE"
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"ITEM"),; 	//"ITEM"  
										GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"),; 	//"CDTRP" 
										Space(06),; 											//"NRTAB" 
										Space(06),; 											//"NRNEG" 
										Space(04),; 											//"CDFXTV"
										Space(10),; 											//"CDTPVC"
										Space(04),; 											//"NRROTA"
										0,; 													//"QTCALC"
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE"),; 	//"QTDE"  
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR"),; 	//"PESOR" 
										0,; 													//"PESCUB"
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDALT"),; //"QTDALT"
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR"),;	//"VALOR" 
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME"),; //"VOLUME"
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRGRUP"),; //"NRGRUP"
										GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDDEST"),; //"CDEMIT"
										Space(01),; 											//"PEDROM"
										Space(01),; 											//"PESPED"
										0,; 													//"PRAZO"
										"0",;													// DELETE
										0,;                                                     //"PERCOUT"
										0,;                                                     //"PESORORG" 
										0,;                                                     //"PESCUBORG"
										0,;                                                     //"VALORORG" 
										0,;                                                     //"VOLUMEORG"
										0,;                                                     //"QTDEORG"
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALLIQ"),;	//"VALLIQ"
										GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"FILIAL") ;	//"FILIAL"
										})
					EndIf

				EndIf
				// Caso se esteja assumindo a classificação de frete do agrupador de carga,
				// atualiza classificacao de frete no item do documento de carga
				// para calcular o peso cubado por classificacao de frete corretamente
				If !Empty(cCdClFr) .AND. GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR") != cCdClFr
					GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR", cCdClFr)
				EndIf

				GFEXFB_8SKIP(lTabTemp, cTRBITE, 8)
			EndDo
			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
		EndDo
		
		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
	EndDo
	
	// Carga compartilhada
	If !lSimulacao
		GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
		GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
		
		While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
			
			If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE") == '01'
	
				If Empty(cNrRom)
					cNrRom := Padr(aAgrFrt[1][1],Len(GWN->GWN_NRROM))
				EndIf
				
				If !Empty(cNrRom) .And. ( (GWN->GWN_FILIAL == xFilial('GWN') .And. GWN->GWN_NRROM == cNrRom) .Or. GWN->(msSeek(xFilial('GWN') + cNrRom))) .And. ;
					TemCrgComp(.T.)
					
					AddToLog("Adicionando quantidades para o cálculo " + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") + CRLF)
					
					GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
					if GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 
						While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
							
							AddToLog(STR0537 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0106 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + CRLF) //"    Class. Frete "###", Tipo Oper. "
							nPerRatTCF := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,cCpoCrgTCF) / nQtdTCF
							
							AddToLog("Rateio classificação: " + cValtoChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,cCpoCrgTCF)) + '/' + cValToChar(nQtdTCF) + '=' + cValToChar(nPerRatTCF*100) + '%' + CRLF)
							
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PERCOUT"  ,(nPerRatTCF * GFEVlrCrg(cCriRat)) / ( GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, cCpoCrgTCF) + (nPerRatTCF * GFEVlrCrg(cCriRat) ) ) )
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESORORG" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" ))
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUBORG",GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"))
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALORORG" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" ))
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUMEORG",GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"))
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDEORG"  ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"  )) 
							
							AddToLog("Peso anterior: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" )))
							If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" ) == 0
								AddToLog(" -> Quantidade do romaneio zerada. ")
							Else
								AddToLog(CRLF)
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" ) + (nPerRatTCF * GWN->GWN_CPESO) )
							EndIf
							AddToLog("Novo peso: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR" )) + CRLF)
							
							AddToLog("Valor anterior: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" )))
							If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" ) == 0
								AddToLog(" -> Quantidade do romaneio zerada. ")
							Else
								AddToLog(CRLF)
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" ) + (nPerRatTCF * GWN->GWN_CVAL) )
							EndIf
							AddToLog("Novo valor: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR" )) + CRLF)
							
							AddToLog("Volume anterior: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME" )))
							If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME" ) == 0
								AddToLog(" -> Quantidade do romaneio zerada. ")
							Else
								AddToLog(CRLF)
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME" ) + (nPerRatTCF * GWN->GWN_CVOL) )
							EndIf
							AddToLog("Novo volume: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME" )) + CRLF)
							
							AddToLog("Quantidade anterior: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE" )))
							If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE" ) == 0
								AddToLog(" -> Quantidade do romaneio zerada. ")
							Else
								AddToLog(CRLF)
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE" ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE" ) + (nPerRatTCF * GWN->GWN_CQTDE) )
							EndIf
							AddToLog("Nova Quantidade: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE" )) + CRLF)
							
							
							AddToLog("Redução do valor do critério: " +                            cValtoChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PERCOUT"  )*100) + '%' + CRLF)
							
							GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
						EndDo
					EndIf
				EndIf
			EndIf
			
			GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
		EndDo
	
	EndIf
	
	aSort(aTRBTCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})

	// Ao final do processamento, deve ter gerado pelo menos uma unidade de calculo (cTRBUNC), com pelo menos uma tabela a localizar (cTRBTCF)
	GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
	GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
	While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0)

		nUnCalc := 0
		nCalc   := 0

		GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
		GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
		While	!GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .And.;
		 		GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

			nUnCalc++

			GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
			If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
				nCalc++
			EndIf

			GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
		EndDo

		If nUnCalc == 0 .Or. nCalc == 0
			GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1)
			GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCarg, 1,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})

			bTrechoNPago := .F.

			While !GFEXFB_3EOF(lTabTemp, cTRBDOC, @aDocCarg, 1) .And. GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") /*(cTRBAGRU)->NRAGRU */ .And. !bTrechoNPago
				//Percorre os trechos do documento de carga
				GWU->(dbSetOrder(1))
				GWU->(dbSeek((xFilial("GWU")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC"))))
				While !GWU->(EOF() ) .And. GWU->GWU_CDTPDC == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC");
				.And.GWU->GWU_EMISDC == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC") .And. GWU->GWU_SERDC == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC");
				.And. GWU->GWU_NRDC == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC")
					// Caso haja um documento de carga do tipo FOB, e trecho não pago, altera a variavel bTrechoNPago para .T.
					If GWU->GWU_PAGAR == "2" .AND. (GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"TPFRET") == "3" .Or. GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"TPFRET") == "4")
						bTrechoNPago := .T.
						Exit
					EndIf
					//Quando for integração com TMS, apaga cálculo já realizado.
					If cMV_INTTMS == .T. 
						GWH->( dbSetOrder(2) )
						GWH->( dbSeek(GWU->GWU_FILIAL+GWU->GWU_CDTPDC+GWU->GWU_EMISDC+GWU->GWU_SERDC+GWU->GWU_NRDC) )
						While GWH->(!EOF()) .And.  GWU->GWU_FILIAL+GWU->GWU_CDTPDC+GWU->GWU_EMISDC+GWU->GWU_SERDC+GWU->GWU_NRDC == ;
							  GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC
							GWF->( dbSetOrder(1) )
							GWF->( dbSeek(GWH->GWH_FILIAL+GWH->GWH_NRCALC) )
							
							If Empty(GWF->GWF_NRPREF)
								GFEDelCalc(GWF->GWF_NRCALC)
							EndIf
							GWH->( dbSkip() )
						EndDo
					EndIf
					GWU->(dbSkip())
				EndDo
				GFEXFB_8SKIP(lTabTemp, cTRBDOC, 1) 
			EndDo
			// Caso não seja gerado nenhum cálculo mostra mensagem de erro.
			If !bTrechoNPago
				GFEXFBAEC("GEN", 4, {GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")/*(cTRBAGRU)->NRAGRU*/, "GWN"})

				GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
				GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO", '1')

				lError := .T.
				AddToLog(STR0049 + CRLF) //"    *** Nenhuma unidade de calculo foi gerada, ou não há classificacao de frete/tipo de operacao para localizar tabela de frete!!"
				// Caso não seja gerado nenhum cálculo MAS só haja notas de saída, tipo FOB e com  trecho não pago, não necessidade de cálculo.
			Else
				AddToLog("*** Existem somente notas não pagas no agrupador, sem necessidade de geração de cálculo." + CRLF) //"    *** Somente notas não pagas no romaneio, sem necessidade de geração de cálculo."
			EndIf
		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0)
	EndDo

	//Verifica necessidade de apresentar tela de erros
	If lError
		AddToLog(CRLF + CRLF, _LOG_BEGIN)
	EndIf
	
	aTRBGRB3 := aClone(aTRBGRB1)
	aSort(aTRBGRB1,,,{|x,y| x[16]+x[06]+x[07]+x[05]+x[13]+x[12]+x[14]+x[15]+x[10]+x[09]+x[08] < y[16]+y[06]+y[07]+y[05]+y[13]+y[12]+y[14]+y[15]+y[10]+y[09]+y[08]})
	aSort(aTRBGRB3,,,{|x,y| x[01] < y[01]})

Return Nil	// FIM DefUnidCalc()

/*----------------------------------------------------------------------------
Verifica se foi informado array com dados de tabela de frete
----------------------------------------------------------------------------*/
Function GFEXFBUAT()

Return (len(aTabelaFrt) > 2 .AND. Empty(aTabelaFrt[2]) /* Tabela não informada */ .AND. !Empty(aTabelaFrt[19,1,1])) // Foi informado pelo menos um componente

/*----------------------------------------------------------------------------
Gera unidades de cálculo adicionais para cada combinação de rotas possíveis
encontradas durante a simulação geral
Recebe o número da última unidade de cálculo gerada, a partir da qual serão
geradas as demais.
----------------------------------------------------------------------------*/
Function GFECalcSim(nNrUltCalc)

	Local aRecnoTCF := {}
	Local aGrupos   := {}
	Local nX        := 0
	Local aTRBTCF   := {} // Array usada para copiar o registro da tabela cTRBTCF caso seja uma simulação
	Local cChave    := ""
	Local aAux      := {}
	Local aTRBUNC   := {} // Array usada para copiar o registro da tabela cTRBUNC caso seja uma simulação
	Local aAreaUNC  := {}
	Local cNrCalc   := ""
	Local aCombTCF  := {}
	Local cRecnoTCF := ""
	Local nFatorCub := 0
	Local nY        := 0
	Local aTCFTmp	:= {}
	Local cAuxNrCalc := ""
	Local cAuxCdEmit := ""
	Local cAuxNrTab  := ""
	Local cAuxNrNeg  := ""

	// Armazena o número dos registros originais da tabela, antes da criação das cópias
	GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
	if GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 
		While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
			aAdd(aRecnoTCF,GFEXFB_GRECNO(lTabTemp, cTRBTCF, 5))

			If !lTabTemp // Somente com array é necessário armazenar o conteudo da chave. Mais abaixo é necessário ajustar a array aRecnoTCF para calcular corretamente. 
				aAdd(aTCFTMP,{	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), ;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"), ;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"), ;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ")})
			EndIf

			GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
		EndDo
	EndIf

	AddToLog(CRLF + STR0536 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") + CRLF) //"  # Rotas selecionadas para o cálculo "

	For nX := 1 to len(aRecnoTCF)

		// Posiciona no registro indicado pela posição do array
		GFEXFB_HGOTO(lTabTemp,cTRBTCF, 5, aRecnoTCF[nX])

		AddToLog(CRLF + STR0537 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0106 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + CRLF) //"    Class. Frete "###", Tipo Oper. "

		// Salva o registro corrente num array
		aTRBTCF := {GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"ITEM")  ,;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") ,;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") ,;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") ,;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")  ,;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") ,;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") ,;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRGRUP"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDEMIT"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PEDROM"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESPED"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ") ;
					}

		GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
		GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM2, 3,{	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
														GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
														GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")}) 
		While  !GFEXFB_3EOF(lTabTemp, cTRBSIM, @aTRBSIM2, 3)  .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")   == GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRCALC") .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")   == GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDCLFR") .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")   == GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTPOP")

			// Considerar apenas rotas válidas
			if GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"SELEC") != "1"
				GFEXFB_8SKIP(lTabTemp, cTRBSIM, 3) 
				Loop
			EndIf

			GV6->(dbSetOrder(01))
			IF GV6->(dbSeek(xFilial("GV6")+;
					  GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTRP")+;
					  GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRTAB")+;
					  GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRNEG")+;
					  GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDFXTV")+;
					  GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRROTA")))
				If Empty(aTRBTCF[7]) .And. Empty(aTRBTCF[8]) // Tabela e negociação vazias

					nFatorCub := Posicione("GV9",1,xFilial("GV9")+;
											GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTRP")+;
											GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRTAB")+;
											GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRNEG"),"GV9_QTKGM3")

					//grava tabela encontrada para o calculo de frete
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP" , GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"EMIVIN"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB" , GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"TABVIN"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG" , GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRNEG"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA", GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRROTA"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC", GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTPVC"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV", GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDFXTV"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE", GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"DTVALI"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB", GFEPesoCub(nFatorCub,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC", GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"QTFAIXA"))   //quantidade para calculo
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PRAZO" , GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"PRAZO"))
					aTRBTCF[7]        := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")
					aTRBTCF[8]        := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")
				Else
					if lTabTemp
						RecLock(cTRBTCF,.T.)
						(cTRBTCF)->NRCALC  := aTRBTCF[1]
						(cTRBTCF)->CDCLFR  := aTRBTCF[2]
						(cTRBTCF)->CDTPOP  := aTRBTCF[3]
						(cTRBTCF)->SEQ     := STRZERO((cTRBTCF)->(RecCount()) +1,4)
						(cTRBTCF)->DTVIGE  := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"DTVALI")
						(cTRBTCF)->ITEM    := aTRBTCF[5]
						(cTRBTCF)->CDTRP   := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"EMIVIN")
						(cTRBTCF)->NRTAB   := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"TABVIN")
						(cTRBTCF)->NRNEG   := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRNEG")
						(cTRBTCF)->CDFXTV  := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDFXTV")
						(cTRBTCF)->CDTPVC  := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTPVC")
						(cTRBTCF)->NRROTA  := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRROTA")
						(cTRBTCF)->QTCALC  := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"QTFAIXA")
						(cTRBTCF)->QTDE    := aTRBTCF[13]
						(cTRBTCF)->PESOR   := aTRBTCF[14]
						(cTRBTCF)->PESCUB  := aTRBTCF[15]
						(cTRBTCF)->VALOR   := aTRBTCF[16]
						(cTRBTCF)->VOLUME  := aTRBTCF[17]
						(cTRBTCF)->NRGRUP  := aTRBTCF[18]
						(cTRBTCF)->CDEMIT  := aTRBTCF[19]
						(cTRBTCF)->PEDROM  := aTRBTCF[20]
						(cTRBTCF)->PESPED  := aTRBTCF[21]
						(cTRBTCF)->QTDALT  := aTRBTCF[22]
						(cTRBTCF)->PRAZO   := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"PRAZO")
						(cTRBTCF)->VALLIQ  := aTRBTCF[23]
						(cTRBTCF)->(MsUnLock())
					Else
						AADD(aTRBTCF1,{	aTRBTCF[1],; 														//"NRCALC"
										aTRBTCF[2],;														//"CDCLFR"
										aTRBTCF[3],; 														//"CDTPOP"
										STRZERO(Len(aTRBTCF1) +1,4)    ,;	//"SEQ"   
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"DTVALI"),; 			//"DTVIGE"
										aTRBTCF[5],;								 						//"ITEM"
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"EMIVIN"),; 			//"CDTRP" 
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"TABVIN"),; 			//"NRTAB"
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRNEG"),;				//"NRNEG"
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDFXTV"),; 			//"CDFXTV"
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTPVC"),; 			//"CDTPVC"
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRROTA"),; 			//"NRROTA"
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"QTFAIXA"),; 			//"QTCALC"
										aTRBTCF[13],; 														//"QTDE"
										aTRBTCF[14],; 														//"PESOR" 
										aTRBTCF[15],; 														//"PESCUB"
										aTRBTCF[22],; 														//"QTDALT"
										aTRBTCF[16],;														//"VALOR" 
										aTRBTCF[17],; 														//"VOLUME"
										aTRBTCF[18],; 														//"NRGRUP"
										aTRBTCF[19],; 														//"CDEMIT"
										aTRBTCF[20],; 														//"PEDROM"
										aTRBTCF[21],; 														//"PESPED"
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"PRAZO"),; 				//"PRAZO"
										"0",; 																//"DELETADO"
										0,;                                                                 //"PERCOUT"
										0,;                                                                 //"PESORORG" 
										0,;                                                                 //"PESCUBORG"
										0,;                                                                 //"VALORORG" 
										0,;                                                                 //"VOLUMEORG"
										0,;                                                                 //"QTDEORG"
										aTRBTCF[23] ;														//"VALOR LIQUIDO VALLIQ"
										})    
										
						GFEXFB_4IDX(5,.T.)
						GFEXFB_IBOTTOM(lTabTemp, cTRBTCF, @aTRBTCF1, 5, 5)
					EndIf
				EndIf

				AddToLog(CRLF + STR0091 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + STR0067 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") + ;
								STR0068 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") + STR0069 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA") + ;
								STR0092 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") +; //"      *** Seleção finalizada -> Tabela "###"; Negoc. "###"; Rota "###"; Faixa "
								STR0093 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC") + STR0094 + DTOC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE")) + ;
								STR0095 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC")) + ;
								STR0096 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"PRAZO")) +; //"; Tp.Veic. "###"; Vigência "###"; Qtd.Calculo "###"; Prazo(h) "
								STR0097 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VLFRT")) + CRLF) //"; Vl.Frete "
			Else
				// Não tem tarifa, tabela invalida
				AddToLog(STR0098 + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTRP")   + ;
						 STR0067 + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRTAB")   + ;
						 STR0068 + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRNEG")   + ;
						 STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRROTA")  + ;
						 STR0092 + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDFXTV")  + ; //"      *** Foi encontrada tabela, mas não há tarifas para a mesma -> Transp. "###; Tabela "###"; Negoc. "###"; Rota "###"; Faixa "
						 STR0093 + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTPVC") + ;
						 STR0094 + DTOC(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"DTVALI")) + ;
						 STR0095 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"QTFAIXA")) + CRLF) //"; Tp.Veic. "###"; Vigência "###"; Qtd.Calculo "

			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBSIM, 3)
		EndDo
	Next nX	// aRecnoTCF
	
	IF !lTabTemp
		aSort(aTRBTCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})
		
		// Como a array foi reordenado, é necessário ajustar os valores do array aRecnoTCF para o cálculo ser realizado corretamente.
		aRecnoTCF := {}
		
		GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
		for nX:= 1 to Len(aTCFTMP)
			if GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{aTCFTMP[nX][1], aTCFTMP[nX][2], aTCFTMP[nX][3], aTCFTMP[nX][4] })
				aAdd(aRecnoTCF,GFEXFB_GRECNO(lTabTemp, cTRBTCF, 5))
			EndIf
		next
	EndIf
	
	// Agrupa todos os TCFs do cálculo corrente
	GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
	if GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 
		cChave  :=	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
		aAux    := {}
		aGrupos := {}
	EndIf
	While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
		if cChave !=	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + ;
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
			aAdd(aGrupos,aAux)
			aAux := {}
		EndIf
		aAdd(aAux,GFEXFB_GRECNO(lTabTemp, cTRBTCF, 5))
		cChave  := 	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")

		GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
	EndDo
	aAdd(aGrupos,aAux)

	// Retorna um array onde cada posição possui uma lista de recno's separados por virgula representando
	// as unidades de calculo que serão criadas
	aCombTCF := {}
	GFECombTCF(aCombTCF,aGrupos,1,"")

	// Salva o estado corrente da tabela cTRBUNC
	aAreaUNC := GFEXFB_9GETAREA(lTabTemp, cTRBUNC, 6) 

	// Armazena os dados da unidade de calculo que serão utilizados mais a frente
	aTRBUNC := {GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"TIPO"),;
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU"),;
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE"),;
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"CHVGWU"),;
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"GRURAT")}
	cNrCalc := 	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")		// Usado para guardar o calculo corrente

	// Converte os registros de TCF originais em uma lista de recno's separada por virgula
	cRecnoTCF := ""
	For nX := 1 to len(aRecnoTCF)
		cRecnoTCF += if(!Empty(cRecnoTCF),",","")+cValToChar(aRecnoTCF[nX])
	Next nX

	// Valida a lista de registros quanto a ter a mesma transportadora. Se não possuir, uma nova lista deve ser obtida
	If !ValCombTCF(cRecnoTCF)
		For nX := 1 to len(aCombTCF)
			if ValCombTCF(aCombTCF[nX])

				// Eliminar os TCFs anteriores
				aAux := StrTokArr(cRecnoTCF,",")
				For nY := 1 to len(aAux)
					GFEXFB_HGOTO(lTabTemp,cTRBTCF, 5, val(aAux[nY]))
					IF lTabTemp
						(cTRBTCF)->(dbDelete())
					Else
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DELETADO","1")
					EndIf 
				Next nY
				cRecnoTCF := aCombTCF[nX]
				Exit
			EndIf
		Next nX
	EndIf

	// Criar as unidades de calculo com base nas combinações.
	// Manter a primeira combinação com as TCFs originais.
	For nX := 1 to len(aCombTCF)

		// Valida a combinação gerada, onde todos os TCFs devem ser do mesmo transportador
		If !ValCombTCF(aCombTCF[nX])
			Loop
		EndIf

		// Uma das combinações utilizará os registros originais de TCF, portanto não precisa fazer cópia
		If cRecnoTCF != aCombTCF[nX]
			// Cria um novo calculo
			If ltabTemp
				RecLock(cTRBUNC,.T.)
				(cTRBUNC)->NRCALC := STRZERO(++nNrUltCalc,6)
				(cTRBUNC)->VALTAB := .T.
				(cTRBUNC)->IDFRVI := "2"
				(cTRBUNC)->CALBAS := cNrCalc
				(cTRBUNC)->TIPO   := aTRBUNC[1]
				(cTRBUNC)->NRAGRU := aTRBUNC[2]
				(cTRBUNC)->SEQTRE := aTRBUNC[3]
				(cTRBUNC)->CHVGWU := aTRBUNC[4]
				(cTRBUNC)->GRURAT := aTRBUNC[5]
				(cTRBUNC)->(MsUnLock())
			Else
				AADD(aTRBUNC2,{	STRZERO(++nNrUltCalc,6),; 								//"NRCALC"
								aTRBUNC[1],; 											//"TIPO"  
								Space(01),;  											//"FINALI"
								StoD("  \  \  "),;  									//"DTPREN"
								Space(05),;  											//"HRPREN"
								Space(01),;  											//"TPTRIB"
								0,;  													//"BASICM"
								0,;  													//"PCICMS"
								0,;  													//"VLICMS"
								0,;  													//"ICMRET"
								0,;  													//"BASISS"
								0,;  													//"PCISS" 
								0,;  													//"VLISS" 
								0,;  													//"BAPICO"
								0,;  													//"VLPIS" 
								0,;  													//"VLCOFI"
								0,;  													//"PCREIC"
								.T.,; 													//"VALTAB"
								aTRBUNC[2],; 											//"NRAGRU"
								"2",; 													//"IDFRVI"
								aTRBUNC[3],; 											//"SEQTRE"
								cNrCalc,; 												//"CALBAS"
								Space(01),; 											//"ADICIS"
								aTRBUNC[4],; 											//"CHVGWU"
								"0",;
								Space(6),;
								aTRBUNC[5],;
								0,;														//"BASIBS"
								0,; 													//"PCIBS"
								0,;														//"VLRIBS"
								0,;														//"BASCBS"
								0,;														//"PCCBS"
								0})														//"VLRCBS"

			EndIf

			// Criar os registros de TCF da combinação e vincular ao novo calculo
			aAux := StrTokArr(aCombTCF[nX],",")
			For nY := 1 to len(aAux)
				GFEXFB_HGOTO(lTabTemp,cTRBTCF, 5, val(aAux[nY])) 

				if 	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") != cNrCalc .OR. ;
					ValorNaLista(ALLTRIM(STR(GFEXFB_GRECNO(lTabTemp, cTRBTCF, 5))), cRecnoTCF)
					// Cria uma copia do registro, atualizando o numero do calculo
					// Salva o registro corrente num array
					aTRBTCF := {GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"ITEM")  ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")  ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRGRUP"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDEMIT"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PEDROM"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESPED"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PRAZO") ,;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ") ;
								}

					// Cria um novo TCF para corresponder à combinação indicada em aCombTCF
					if lTabTemp
						RecLock(cTRBTCF,.T.)
						(cTRBTCF)->NRCALC  := STRZERO(nNrUltCalc,6)
						(cTRBTCF)->SEQ     := STRZERO((cTRBTCF)->(RecCount()) +1,4)
						(cTRBTCF)->CDCLFR  := aTRBTCF[2]
						(cTRBTCF)->CDTPOP  := aTRBTCF[3]
						(cTRBTCF)->DTVIGE  := aTRBTCF[4]
						(cTRBTCF)->ITEM    := aTRBTCF[5]
						(cTRBTCF)->CDTRP   := aTRBTCF[6]
						(cTRBTCF)->NRTAB   := aTRBTCF[7]
						(cTRBTCF)->NRNEG   := aTRBTCF[8]
						(cTRBTCF)->CDFXTV  := aTRBTCF[9]
						(cTRBTCF)->CDTPVC  := aTRBTCF[10]
						(cTRBTCF)->NRROTA  := aTRBTCF[11]
						(cTRBTCF)->QTCALC  := aTRBTCF[12]
						(cTRBTCF)->QTDE    := aTRBTCF[13]
						(cTRBTCF)->PESOR   := aTRBTCF[14]
						(cTRBTCF)->PESCUB  := aTRBTCF[15]
						(cTRBTCF)->VALOR   := aTRBTCF[16]
						(cTRBTCF)->VOLUME  := aTRBTCF[17]
						(cTRBTCF)->NRGRUP  := aTRBTCF[18]
						(cTRBTCF)->CDEMIT  := aTRBTCF[19]
						(cTRBTCF)->PEDROM  := aTRBTCF[20]
						(cTRBTCF)->PESPED  := aTRBTCF[21]
						(cTRBTCF)->PRAZO   := aTRBTCF[22]
						(cTRBTCF)->QTDALT  := aTRBTCF[23]
						(cTRBTCF)->VALLIQ  := aTRBTCF[24]
						(cTRBTCF)->(MsUnLock())
					Else
						AADD(aTRBTCF1,{	STRZERO(nNrUltCalc,6),; 										//"NRCALC"
										aTRBTCF[2],;													//"CDCLFR"
										aTRBTCF[3],; 													//"CDTPOP"
										STRZERO(GFEXFB_FRECCOUNT(lTabTemp,cTRBTCF, aTRBTCF1) +1,4)    ,;//"SEQ"    
										aTRBTCF[4],; 													//"DTVIGE"
										aTRBTCF[5],; 													//"ITEM"  
										aTRBTCF[6],; 													//"CDTRP" 
										aTRBTCF[7],; 													//"NRTAB" 
										aTRBTCF[8],; 													//"NRNEG" 
										aTRBTCF[9],; 													//"CDFXTV"
										aTRBTCF[10],; 													//"CDTPVC"
										aTRBTCF[11],; 													//"NRROTA"
										aTRBTCF[12],; 													//"QTCALC"
										aTRBTCF[13],; 													//"QTDE"  
										aTRBTCF[14],; 													//"PESOR" 
										aTRBTCF[15],; 													//"PESCUB"
										aTRBTCF[23],; 													//"QTDALT"
										aTRBTCF[16],;													//"VALOR" 
										aTRBTCF[17],; 													//"VOLUME"
										aTRBTCF[18],; 													//"NRGRUP"
										aTRBTCF[19],; 													//"CDEMIT"
										aTRBTCF[20],; 													//"PEDROM"
										aTRBTCF[21],; 													//"PESPED"
										aTRBTCF[22],; 													//"PRAZO"
										"0",;															// DELETE
										0,;                                                    		    //"PERCOUT"
										0,;                                                             //"PESORORG" 
										0,;                                                             //"PESCUBORG"
										0,;                                                             //"VALORORG" 
										0,;                                                             //"VOLUMEORG"
										0,;                                                             //"QTDEORG"
										aTRBTCF[24] ;                                                   //"VALLIQ"
										})    
					EndIf
				Else // if !ALLTRIM(STR((cTRBTCF)->(Recno())))$cRecnoTCF
					// Ajusta o número de calculo do TCF que foi criado na simulação
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC",STRZERO(nNrUltCalc,6))

					cAuxNrCalc := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
					cAuxCdEmit := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")
					cAuxNrTab  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")
					cAuxNrNeg  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")

					If GFEXFB_CSEEK(lTabTemp, , aTRBROT1, 13, {GFEXFB_5CMP(lTabTemp, , @aTRBROT1, 13,"NRCALC"),cAuxCdEmit,cAuxNrTab,cAuxNrNeg})
						While !GFEXFB_3EOF(lTabTemp, , @aTRBROT1, 13) .And. GFEXFB_5CMP(lTabTemp, , @aTRBROT1, 13,"NRCALC") <> cAuxNrCalc;
																 .And. GFEXFB_5CMP(lTabTemp, , @aTRBROT1, 13,"CDTRP") == cAuxCdEmit;
																 .And. GFEXFB_5CMP(lTabTemp, , @aTRBROT1, 13,"NRTAB") == cAuxNrTab;
																 .And. GFEXFB_5CMP(lTabTemp, , @aTRBROT1, 13,"NRNEG") == cAuxNrNeg

							GFEXFB_5CMP(lTabTemp, , @aTRBROT1, 13,"NRCALC", cAuxNrCalc)

							GFEXFB_8SKIP(lTabTemp, , 13)
						EndDo
					EndIf
				EndIf
			Next nY
		EndIf

		GFEAPPEDUC(aCombTCF[nX], StrZero(nNrUltCalc,6), .F.)

	Next nX

	IF !lTabTemp
		aTRBTCF2 := aClone(aTRBTCF1)
		aTRBTCF1 := {}
		For nX := 1 to len(aTRBTCF2)
			if aTRBTCF2[nX,25] == "0"
				AADD(aTRBTCF1, {aTRBTCF2[nx,01], aTRBTCF2[nx,02], aTRBTCF2[nx,03], aTRBTCF2[nx,04], aTRBTCF2[nx,05], aTRBTCF2[nx,06], aTRBTCF2[nx,07],; 
								aTRBTCF2[nx,08], aTRBTCF2[nx,09], aTRBTCF2[nx,10], aTRBTCF2[nx,11], aTRBTCF2[nx,12], aTRBTCF2[nx,13], aTRBTCF2[nx,14],;
								aTRBTCF2[nx,15], aTRBTCF2[nx,16], aTRBTCF2[nx,17], aTRBTCF2[nx,18], aTRBTCF2[nx,19], aTRBTCF2[nx,20], aTRBTCF2[nx,21],;
								aTRBTCF2[nx,22], aTRBTCF2[nx,23], aTRBTCF2[nx,24], aTRBTCF2[nx,25], aTRBTCF2[nx,26], aTRBTCF2[nx,27], aTRBTCF2[nx,28],;
								aTRBTCF2[nx,29], aTRBTCF2[nx,30], aTRBTCF2[nx,31], aTRBTCF2[nx,32]})
			EndIf
		Next Nx

		aSort(aTRBTCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})
		IIF(aTRBTCF2==NIL,,aSize(aTRBTCF2,0))
		aTRBTCF2 := {}
	EndIf

	// Reposiciona no registro salvo antes da criação dos novos UNCs
	GFEXFB_ARESTAREA(lTabTemp,aAreaUNC,6) //RestArea(aAreaUNC) //cTRBUNC

Return NIL	// FIM GFECalcSim()

/*----------------------------------------------------------------------------
Verifica se um dado valor está contido na lista fornecida.
----------------------------------------------------------------------------*/
Static Function ValorNaLista(cValor,cLista)

	Local lTemValor := .F.
	Local aAux      := StrTokArr(cLista,",")
	Local nI        := 0
	Local nLen      := 0

	nLen := Len(aAux)
	For nI := 1 To nLen
		If aAux[nI] == cValor
			lTemValor := .T.
			Exit
		EndIf
	Next nI

Return lTemValor

/*----------------------------------------------------------------------------
Verifica se a lista de registros da combinação possuem o mesmo transportador.
A lista foi gerada pela função GFECombTCF e contem os Recno's da tabela cTRBTCF
----------------------------------------------------------------------------*/
Static Function ValCombTCF(cLista)

	Local lIgual    := .T.
	Local nX        := 0
	Local aComb     := StrTokArr(cLista,",")
	Local aAreaTCF  := GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5) 
	Local cCdTrp    := ""
	Local nLen      := 0

	If !Empty(aComb)
		GFEXFB_HGOTO(lTabTemp,cTRBTCF, 5, val(aComb[1])) 
		cCdTrp := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")

		nLen := Len(aComb)
		For nX := 2 to nLen
			GFEXFB_HGOTO(lTabTemp,cTRBTCF, 5, val(aComb[nX])) 
			If cCdTrp != GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")
				lIgual := .F.
				Exit
			EndIf
		Next nX
	Else
		lIgual := .F.
	Endif

	GFEXFB_ARESTAREA(lTabTemp, aAreaTCF, 5) //RestArea(aAreaTCF)

Return lIgual

/*----------------------------------------------------------------------------
Retorna o peso cubado para os itens de uma classificação de frete
Se a classificação estiver em branco, retorna o peso cubado para os itens do cálculo
----------------------------------------------------------------------------*/
Function GFEPesoCub(nFatorCub, cCdClFr, cNrCalc, nVolTCF)

	Local nPesoCubado := 0
	Local aAreaTRE := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7) 
	Local aAreaITE := GFEXFB_9GETAREA(lTabTemp, cTRBITE, 8) 
	Local lCalcPc := SuperGetMv("MV_GFEOPC",.F.,"0") == "1" // Calcula o peso cubado
	Local nVolumeOrg := 0
	Default nVolTCF := 0 // Volume já adicionado pela carga compartilhada
	
	GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
	GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNrCalc}) 
	While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. cNrCalc == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC")
		GFEXFB_BORDER(lTabTemp,cTRBITE,01,8)
		GFEXFB_CSEEK(lTabTemp, cTRBITE, @aTRBITE1, 8,{	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") , ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")})

		//percorre todos os itens para calcular peso cubado
		While  !GFEXFB_3EOF(lTabTemp, cTRBITE, @aTRBITE1, 8) .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") == GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDTPDC") .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") == GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"EMISDC") .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  == GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"SERDC")  .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")   == GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRDC")

			// Quando a classificacao de frete não é informada à função, devem ser somados todos os itens do cálculo
			// Do contrário, somam-se apenas os itens com classificação de frete igual a informada
			If Empty(cCdClFr) .OR. GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR") == cCdClFr
				nVolumeOrg += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME")
				If GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOC") == 0 .Or. lCalcPC // Sempre calcula o fator de cubagem por classificação independente do informado nos itens
					If GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME") > 0
						nPesoCubado += (GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME") * nFatorCub)
					EndIf
				Else
					nPesoCubado += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOC")
				EndIf
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBITE, 8) 
		EndDo
		GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
	EndDo
	
	If nVolTcf > 0 .And. nPesoCubado > 0 .And. (nVolTcf - nVolumeOrg) > 0
		nPesoCubado += ( nVolTcf - nVolumeOrg ) *  nFatorCub
	EndIf

	// Início Ponto de Entrada Wetzel
	If ExistBlock("XGFEPESC")
		if !lTabTemp
			GFEConout("INFO","Atenção!! Devido evolução do produto, o ponto de entrada XGFEPESC precisa ser alterado")
		EndIf
		nPesoCubado := ExecBlock("XGFEPESC",.f.,.f.,{nPesoCubado,(cTRBITE),(cTRBTRE), cNrCalc, cCdClFr})
	EndIf
	// Fim Ponto de Entrada Wetzel

	GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7) //RestArea(aAreaTRE)
	GFEXFB_ARESTAREA(lTabTemp,aAreaITE,8) //RestArea(aAreaITE)

Return nPesoCubado

/*----------------------------------------------------------------------------
Recursivamente, combina os elementos de aGrupos, armazenando os valores combinados
em aCombTCF
nNivel indica para função o limite da recursividade
cElem contem o valor parcial recebido do nível anterior
----------------------------------------------------------------------------*/
Static Function GFECombTCF(aCombTCF,aGrupos,nNivel,cElem)
	Local nI   := 0
	Local nLen := 0

	If !Empty(cElem)
		cElem += ","
	EndIf

	nLen := Len(aGrupos[nNivel])
	For nI := 1 To nLen
		If nNivel = len(aGrupos)
			aAdd(aCombTCF,cElem+cValToChar(aGrupos[nNivel,nI]))	// Adiciona um elemento no array
		Else
			GFECombTCF(aCombTCF,aGrupos,nNivel+1,cElem+cValToChar(aGrupos[nNivel,nI]))
		EndIf
	Next nI

Return NIL	// FIM GFECombTCF()

/*----------------------------------------------------------------------------
{Protheus.doc} GFEESCTAB
Escolha da tabela de frete.
Uso: GFECLCFRT

@sample GFEESCTAB()

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Function GFEESCTAB(lShowTabFr)

	Local cCadastro := OemToAnsi(STR0309) //"Seleção de Tabela de Frete"
	Local nAlt := (GetScreenRes()[2]-150)
	Local nLrg := (GetScreenRes()[1]-150)
	Local oDlg
	Local oListDoc
	Local aItens := {}
	Local aRet := {}
	Local aAreaTcf
	Local nPerc := 1
	Default lShowTabFr := .f.

	If lTabTemp
		If GFENumReg(cTRBSTF) == 0
			Return .T.
		Endif
	Else
		If Len(aTRBSTF1) == 0
			Return .T.
		EndIf
	EndIf
	
	GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
	// Início Ponto de Entrada Usina Colombo - TUHOTD		    	
	If ExistBlock("GFEXFB05")  
	   	aRet := ExecBlock("GFEXFB05",.f.,.f.,{ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROM"), lTabTemp, cTRBSTF, @aTRBSTF1})
	    AddToLog(aRet[2] + CRLF)
	    If aRet[1] == .T.
	    	Return .T. 
	    Endif
	EndIf      	
	// Fim Ponto de Entrada Usina Colombo
	aAreaTCF := GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5) 
	GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
	while !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
		nPerc := 1
		If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDCLFR"), GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPOP")})
			nPerc := 1 - GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PERCOUT")
			If nPerc != 1
				GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLFRT", GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLFRT") * nPerc)
			EndIf
		EndIf
		
		AADD(aItens,{	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN") ,; 
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") ,;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")  ,;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDCLFR") ,;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPOP") ,;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV") ,;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPVC") ,;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA") ,;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DESROT") ,;
						Transform(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLFRT"),"@E 999,999,999.99"),;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO"),;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROM"),;
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")})
		GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) //
	End
	GFEXFB_ARESTAREA(lTabTemp,aAreaTCF,5)
	GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
	
	If lShowTabFr
		Define MsDialog oDlg Title cCadastro From 0,0 To nAlt*0.4,nLrg*0.8 Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
		oDlg:lEscClose := .F.
	
		oPnlC := tPanel():New(00,00,,oDlg,,,,,,0,20,.F.,.F.)
		oPnlC:Align := CONTROL_ALIGN_BOTTOM
	
		oPnlC1 := tPanel():New(05,01,,oPnlC,,,,,,50,10,.F.,.F.)
		oPnlC1:Align := CONTROL_ALIGN_RIGHT
		oBtnOK := TButton():New( 05, 05, STR0310,oPnlC1,{|| oDlg:End() },35,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"OK"
	
		oPnlA := tPanel():New(00,00,,oDlg,,,,,,0,16,.F.,.F.)
		oPnlA:Align := CONTROL_ALIGN_TOP
	
		Private oFont12  := TFont():New("Arial",,-11,,.F.,,,,.T.,.F.)
		Private oFont12B := TFont():New("Arial",,-11,,.T.,,,,.T.,.F.)
	
		@ 05,05 SAY STR0311 Pixel Of oPnlA Font oFont12B //"Romaneio: "
		@ 05,40 SAY GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROM") Pixel Of oPnlA Font oFont12
	
		@ 05,105 SAY STR0312 Pixel Of oPnlA Font oFont12B //"Documentos de Carga: "
		@ 05,175 SAY GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DOCS") Pixel Of oPnlA Font oFont12
	
		oPnlB := tPanel():New(00,00,,oDlg,,,,,,0,0,.F.,.F.)
		oPnlB:Align := CONTROL_ALIGN_ALLCLIENT
		@ 0,0 Listbox oListDoc Fields HEADERS STR0313, STR0314, STR0315, STR0316, STR0317, STR0318, STR0319, STR0320, STR0321, STR0623, STR0322, "Info 1", "Info 2" ;
		Size 140,290 Pixel Of oPnlB ;
		FieldSizes 45,25,33,33,40,30,35,36,120,50,48,16,25,45
	
		oListDoc:Align := CONTROL_ALIGN_ALLCLIENT
		oListDoc:blDblClick := {||oDlg:End()}
		//oListDoc:blDblClick := {||GFEESCTA(aItens[oListDoc:nAt,12],aItens[oListDoc:nAt,13],aItens[oListDoc:nAt,03],aItens[oListDoc:nAt,08])}
		oListDoc:SetArray(aItens)
		oListDoc:bLine := {||{	aItens[oListDoc:nAt, 1],;
								aItens[oListDoc:nAt, 2],;
								aItens[oListDoc:nAt, 3],;
								aItens[oListDoc:nAt, 4],;
								aItens[oListDoc:nAt, 5],;
								aItens[oListDoc:nAt, 6],;
								aItens[oListDoc:nAt, 7],;
								aItens[oListDoc:nAt, 8],;
								aItens[oListDoc:nAt, 9],;
								aItens[oListDoc:nAt,10],;
								aItens[oListDoc:nAt,11],;
								aItens[oListDoc:nAt,12],;
								aItens[oListDoc:nAt,13]}}
		oListDoc:bChange := {||GFEESCTA(aItens[oListDoc:nAt,12],aItens[oListDoc:nAt,13],aItens[oListDoc:nAt,03],aItens[oListDoc:nAt,08])}
	
		ACTIVATE MSDIALOG oDlg CENTERED
//	Else
//		While nTblFrFUNB <= Len(aTblFrFUNB)
//			If GFEESCTA(aTblFrFUNB[nTblFrFUNB][1], aTblFrFUNB[nTblFrFUNB][2], aTblFrFUNB[nTblFrFUNB][3], aTblFrFUNB[nTblFrFUNB][4])
//				nTblFrFUNB++
//				Exit
//			Else
//				nTblFrFUNB++
//			EndIf
//		EndDo
	EndIf

Return .T.	// FIM GFEEscTab()

Static Function GFEESCTA(cPar1, cPar2, cPar3, cPar4)
Return GFEXFB_CSEEK(lTabTemp, cTRBSTF, @aTRBSTF1, 2,{cPar1, cPar2, cPar3, cPar4})

/*---------------------------------------------------------------------------
{Protheus.doc} ShowErrLog
Apresentacao do log de processo/erro em tela.
Uso: GFECLCFRT

@param  cTxtLog        texto log para apresentacao

@sample ShowErrLog(cTxtLog)

@author Felipe Nathan Welter, Luiz Fernando Soares, Octávio Augusto Felippe de Macedo
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Static Function ShowErrLog(cArqLog)

	Local cPrograma := Substr(ProcName(1),3,Len(ProcName(1)))
	Local oDlg
	Local oButton1, oButton2, oButton3, oButton4, oButton5
	Local oPanel2, oPanel3, oPanel4, oPanel5, oPanel7
	Local oMGet3
	Local oDbTree
	Local oFolder1, oFolder2, oFolder3
	Local cProb := ""
	Local cSolu := ""
	Local cLog  := ""
	Local lErro
	Local lAviso :=.F.
	Local aAreaAG := GFEXFB_9GETAREA(lTabTemp, cTRBAGRU, 0) 
	Local aAreaCF := GFEXFB_9GETAREA(lTabTemp, cTRBUNC, 6) 
	Local aAreaTR := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7) 
	Local aAreaDC := GFEXFB_9GETAREA(lTabTemp, cTRBDOC, 1) 
	Local nI
	Local nCount  := 0
	Local cIniDoc := ""
	Local cText   := ""
	Local cInner  := ""
	Local cAliasGWN := ""

	Local aItemText := {}
	Local aFilDocs := {}
	Local nItemSel := 1
	Local nTotRom
	Local nRow
	Local cDesc
	Local cTit
	Private oSay1, oSay2, oSay03, oList1
	Private oMGet1, oMGet2

	cDesc := IIf(lCalcServ .And. !IsInCallStack("GFE050CALC"), "Ocorrência ", "Romaneio ")
	cTit  := IIf(lCalcServ, "Resumo - Memória de Cálculo - Serviços", "Resumo - Memória de Cálculo")

		If !lSaveLog
			cLog := "O sistema está parametrizado para não gerar arquivo de log"
		EndIf

    DEFINE MSDIALOG oDlg TITLE cTit FROM 000, 000  TO 542, 664 COLORS 0, 16777215 PIXEL


		oPanel2 := tPanel():New(0, 0,, oDlg,,,,,, 0, 0, .F., .F.)
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

		oPanel3 := tPanel():New(0, 0,, oPanel2,,,,,, 0, 0, .F., .F.)
		oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

		oPanel4 := tPanel():New(0, 0,, oPanel3,,,,,, 138, 72, .F., .F.)
		oPanel4:Align := CONTROL_ALIGN_LEFT

		oFolder1 := TFolder():New(0, 0, {"Cálculos"}, {"Cálculos"}, oPanel4,,,, .T., , 0, 0)
		oFolder1:Align := CONTROL_ALIGN_ALLCLIENT

		oDbTree := dbTree():New(0, 0, 0, 0, oFolder1:aDialogs[1], {|| GFEErrProb(oDbTree:GetCargo(), @cProb, @cSolu, @cText, @aItemText)},, .T.)
		oDbTree:Align := CONTROL_ALIGN_ALLCLIENT

		If lError .Or. lSimulacao

			GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
			GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)

			If GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0)

				lErro := AScan(aErroCalc, {|x| x[1] == "GEN"}) != 0

				oDbTree:AddTree("Gerais", .T., IIf(lErro, "UPDERROR", "OK"),,,, "GEN0")

				For nI := 1 To Len(aErroCalc)

					If aErroCalc[nI][1] == "GEN"
						oDbTree:AddTreeItem("Erro " + AllTrim(Str(++nCount)), "BEND",, "GEN" + AllTrim(Str(nI)))
					EndIf

				Next

				oDbTree:EndTree()

			Else

				While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0) 

					lErro := AScan(aErroCalc, {|x| x[3] == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") }  ) != 0

					GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6) 
					GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")}) 

					If GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) 
						nRow := 0
					Else
						nRow := GFEXFB_GRECNO(lTabTemp, cTRBUNC, 6) 
					EndIF

					nTotRom := 0

					While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

						nTotRom += GFETotFret(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) //Função para totalizar um cálculo temporário dentro da rotina de cálculo de frete

						GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 

					EndDo									

					oDbTree:AddTree(IIf(lSimulacao, "Agrupador ", cDesc) + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")) + " - Total: " + PadR(AllTrim(Transform(nTotRom, "@E 999,999,999.99")), 14), .T., IIf(lErro, "UPDERROR", "OK"),,,, "AGR" + GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))

					If nRow > 0
						GFEXFB_HGOTO(lTabTemp, cTRBUNC, 6, nRow) 
					EndIF

					cIniDoc := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
					While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")
					
						lErro  := AScan(aErroCalc, {|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") .And. x[5] == .F.}) != 0
						lAviso := AScan(aErroCalc, {|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") .And. x[5] == .T.}) != 0

						// Se houve erro na seleção da tabela de frete e não existe erro nessa unidade de cálculo, o valor do trecho
						// estará zerado porque houve erro em outra unidade e portanto o cálculo de frete não foi realizado
						If lErrSelTab .And. !lErro
							GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), 27)
						EndIf

						oDbTree:AddTree("Unid. Cálc. " + AllTrim(Str(Val(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")))) + " - Valor: " + AllTrim(Transform(GFETotFret(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")), "@E 999,999,999.99")) , .T., IIf(lErro, "UPDERROR", IIf(lAviso,"pmsinfo","OK")),,,, GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

						GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
						GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{IIf(Empty(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CALBAS")), GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CALBAS"))}) //
						While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == IIf(Empty(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CALBAS")), GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CALBAS"))

							GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1) 
							If GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
																			 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
																			 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC"), ;
																			 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")}) 

								oDbTree:AddTreeItem("DC: " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")) + " Trecho: " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ"), "PMSDOC",, GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

							EndIf

							GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
						EndDo

						oDbTree:EndTree()

						GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
					EndDo

					lErro := AScan(aErroCalc, {|x| x[1] == "GEN" .And. x[3] == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")}) != 0

					oDbTree:AddTree("Gerais", .T., IIf(lErro, "UPDERROR", "OK"),,,, "GEN0")

					For nI := 1 To Len(aErroCalc)

						If aErroCalc[nI][1] == "GEN" .And. aErroCalc[nI][3] == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")
							oDbTree:AddTreeItem("Erro " + AllTrim(Str(++nCount)), "BEND",, "GEN" + AllTrim(Str(nI)))
						EndIf

					Next

					oDbTree:EndTree()

					oDbTree:EndTree()

					GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0) 

				EndDo

			EndIf

		Else
			GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
			GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0) 
			While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0)

				cInner := "GWN.GWN_NRROM AND GW1.GW1_FILIAL = GWN.GWN_FILIAL"
				If GFXCP1212210('GW1_FILROM')
					cInner := " GWN.GWN_NRROM AND GW1.GW1_FILROM = GWN.GWN_FILIAL"
				EndIf
				cInner := "%" + cInner + "%"

				cAliasGWN := GetNextAlias()
				// Busca as Filiais dos Doc Carga associados ao romaneio calculado para listagem de todos documentos.
				BeginSql Alias cAliasGWN
					SELECT GW1_FILIAL AS FILIAL
					FROM %Table:GWN% GWN
					INNER JOIN %Table:GW1% GW1
					ON GW1.GW1_NRROM = %Exp:cInner%
					AND GW1.%NotDel%
					WHERE GWN.GWN_FILIAL = %xFilial:GWN%
					AND GWN.GWN_NRROM = %Exp:PadR(AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")), TamSX3("GWN_NRROM")[1])%
					AND GWN.%NotDel%
				EndSql
        		If (cAliasGWN)->( !Eof() )
					Do While (cAliasGWN)->( !Eof() )
						nPos := aScan(aFilDocs, {|x| x == (cAliasGWN)->FILIAL})
						If nPos == 0
							aadd(aFilDocs, (cAliasGWN)->FILIAL)
						EndIf
						
						(cAliasGWN)->( DbSkip() )
					EndDo
				Else
				    aadd(aFilDocs, xFilial("GWN"))
			  	EndIf
				(cAliasGWN)->( dbCloseArea() )

				If !lCalcServ  .Or. IsInCallStack("GFE050CALC")
					GWF->(dbSetOrder(4) )
				Else
					GWF->(dbSetOrder(5) )
				EndIf

				nTotRom := 0

				For nI := 1 To Len(aFilDocs)
					GWF->(dbSeek(aFilDocs[nI] + PadR(AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")), TamSX3("GWN_NRROM")[1])) )

					If GWF->(EOF())
						nRow := 0
					Else
						nRow := GWF->(RecNo()) // Evita um segundo (dbseek) para a mesma sequencia de registros
					EndIf

					If lCalcServ .And. !IsInCallStack("GFE050CALC")
						While !GWF->(EOF() ) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. AllTrim(GWF->GWF_NROCO) == AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))

							if !(GWF->GWF_TPCALC $ '7') // Apresentar no resumo somente os cálculos de serviço
								GWF->(dbSkip())
								Loop
							EndIf
							nTotRom += VLTOTFRET(GWF->GWF_NRCALC) // Função que totaliza um cálculo existente na base somando os componentes, essa função está no GFEXFUNA
							GWF->(dbSkip() )

						EndDo
					Else
						While !GWF->(EOF() ) .And. GWF->GWF_FILIAL == aFilDocs[nI] .And. AllTrim(GWF->GWF_NRROM) == AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))

							If (lCalcServ .And. GWF->GWF_TPCALC == "7" .And. (!IsInCallStack("GFE050CALC") .Or. Empty(GWF->GWF_NROCO))) .Or. (!lCalcServ .And. GWF->GWF_TPCALC $ '156')
								nTotRom += VLTOTFRET(GWF->GWF_NRCALC) // Função que totaliza um cálculo existente na base somando os componentes, essa função está no GFEXFUNA
							EndIf
							GWF->(dbSkip() )

						EndDo
					Endif

					If nI == Len(aFilDocs)
						oDbTree:AddTree(cDesc + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")) + " - Total: " + PadR(AllTrim(Transform(nTotRom, "@E 999,999,999.99")), 14), .T., IIf(lAviso,"pmsinfo","OK"),,,, PADR("AGR" + GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),50," "))
					EndIf
				Next

				For nI := 1 To Len(aFilDocs)
					GWF->(dbSeek(aFilDocs[nI] + PadR(AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")), TamSX3("GWN_NRROM")[1])) )

					nRow := 0
					If GWF->(!EOF())
						nRow := GWF->(RecNo()) // Evita um segundo (dbseek) para a mesma sequencia de registros
					EndIf

					lAviso := AScan(aErroCalc, {|x| x[3] == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") .And. x[5] == .T.}) != 0

					If nRow > 0
						GWF->(dbGoto(nRow))
					EndIf
					If !Empty(cIniDoc)
						cIniDoc := GWF->GWF_NRCALC
					EndIf

					If lCalcServ .And. !IsInCallStack("GFE050CALC")

						While !GWF->(EOF() ) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. AllTrim(GWF->GWF_NROCO) == AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))
							If !(GWF->GWF_TPCALC $ '7') // Apresentar no resumo somente os cálculos de serviço
								GWF->(dbSkip())
								Loop
							EndIf
							lAviso := AScan(aErroCalc, {|x| x[1] == GWF->GWF_NRCALC .And. x[3] == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") .And. x[5] == .T. }) != 0
							oDbTree:AddTree("Cálculo " + GWF->GWF_NRCALC + " - Valor: " + AllTrim(Transform(VLTOTFRET(GWF->GWF_NRCALC), "@E 999,999,999.99")) , .T., IIf(lAviso,"pmsinfo","OK"),,,, GWF->GWF_FILIAL + ";" + GWF->GWF_NRCALC)

							GWH->(dbSetOrder(1) )
							GWH->(dbSeek(xFilial("GWH") + GWF->GWF_NRCALC) )
							While !GWH->(EOF() ) .And. GWH->GWH_FILIAL == xFilial("GWH") .And. GWH->GWH_NRCALC = GWF->GWF_NRCALC

								GWU->(dbSetOrder(1) )
								If GWU->(dbSeek(xFilial("GWU") + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + ;
								GWH->GWH_NRDC + GWF->GWF_SEQTRE) )

									oDbTree:AddTreeItem("DC: " + AllTrim(GWH->GWH_NRDC) + " Trecho: " + GWF->GWF_SEQTRE, "PMSDOC",, GWF->GWF_FILIAL + ";" + GWF->GWF_NRCALC)

								EndIf

								GWH->(dbSkip() )

							EndDo

							oDbTree:EndTree()

							GWF->(dbSkip() )

						EndDo
					Else
						While !GWF->(EOF() ) .And. GWF->GWF_FILIAL == aFilDocs[nI] .And. AllTrim(GWF->GWF_NRROM) == AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))
							If (lCalcServ .And. GWF->GWF_TPCALC == "7" .And. (!IsInCallStack("GFE050CALC") .Or. Empty(GWF->GWF_NROCO))) .Or. (!lCalcServ .And. GWF->GWF_TPCALC $ '156')
							
								If aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(GWF->GWF_NRCALC)}) > 0
									GFEXFBAEC(GWF->GWF_NRCALC, 12,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},,.T.,1)
								EndIf
		
								lAviso := AScan(aErroCalc, {|x| x[1] == GWF->GWF_NRCALC .And. x[3] == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") .And. x[5] == .T. }) != 0
								oDbTree:AddTree("Cálculo " + GWF->GWF_NRCALC + " - Valor: " + AllTrim(Transform(VLTOTFRET(GWF->GWF_NRCALC), "@E 999,999,999.99")) , .T., IIf(lAviso,"pmsinfo","OK"),,,, GWF->GWF_FILIAL + ";" + GWF->GWF_NRCALC)
		
								GWH->(dbSetOrder(1) )
								GWH->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC) )
								While !GWH->(EOF() ) .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC = GWF->GWF_NRCALC
								
									GWU->(dbSetOrder(1) )
									If GWU->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC + GWF->GWF_SEQTRE) )
										oDbTree:AddTreeItem("DC: " + AllTrim(GWH->GWH_NRDC) + " Trecho: " + GWF->GWF_SEQTRE, "PMSDOC",, GWF->GWF_FILIAL + ";" + GWF->GWF_NRCALC)
									EndIf

									GWH->(dbSkip() )
								EndDo
								
								oDbTree:EndTree()
							EndIf

							GWF->(dbSkip() )
						EndDo

					EndIf
				Next

				oDbTree:EndTree()

				GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0) 

			EndDo

		EndIf

		oPanel5 := tPanel():New(0, 0,, oPanel3,,,,,, 0, 0, .F., .F.)
		oPanel5:Align := CONTROL_ALIGN_ALLCLIENT

		oFolder2 := TFolder():New(0, 0, {"Detalhes"}, {"Detalhes"}, oPanel5,,,, .T., , 0, 0)
		oFolder2:Align := CONTROL_ALIGN_ALLCLIENT

		oSay1 := tSay():New( 3, 6, {||"Problema: "}, oFolder2:aDialogs[1],, ,,,, .T.,, CLR_WHITE, 60, 8) //"Log Cálculo: "

		oMGet1:= tMultiget():New(11, 5, {|u| if(Pcount()>0, cProb:=u, cProb)}, oFolder2:aDialogs[1] , 185, 36,,,,,, .T.,,,,,, .T.)
		oMGet1:EnableVScroll(.T.)
		oMGet1:EnableHScroll(.T.)
		oMGet1:oFont := TFont():New('Courier New', 6, 16)

		oSay2 := tSay():New(48, 6, {||"Solução: "}, oFolder2:aDialogs[1],, ,,,, .T.,, CLR_WHITE, 60, 8) // "Ação: "

		oMGet2:= tMultiget():New(57, 5, {|u| if(Pcount()>0, cSolu:=u, cSolu)}, oFolder2:aDialogs[1] , 185, 36,,,,,, .T.,,,,,, .T.)
		oMGet2:EnableVScroll(.T.)
		oMGet2:EnableHScroll(.T.)
		oMGet2:oFont := TFont():New('Courier New', 6, 16)

		oList1 := tListbox():New(0, 0, {|u| if( Pcount( )>0, nItemSel:= u, nItemSel )}, aItemText ,200, 100,,oFolder2:aDialogs[1],,,,.T.,,,,,,,,,,,)
		oList1:Hide()
		oPanel4 := tPanel():New(0, 0,, oPanel2,,,,,, 400, 138, .F., .F.)
		oPanel4:Align := CONTROL_ALIGN_BOTTOM

		oFolder3 := TFolder():New(0, 0, {"Memória de Cálculo"}, {"Memória de Cálculo"}, oPanel4,,,, .T., , 0, 0)
		oFolder3:Align := CONTROL_ALIGN_ALLCLIENT

		oMGet3:= tMultiget():New(0,0,{|u| if(Pcount()>0, cLog:=u, cLog)}, oFolder3:aDialogs[1], 0, 0,,,,,, .T.,,,,,, .T.)
		oMGet3:EnableVScroll(.T.)
		oMGet3:EnableHScroll(.T.)
		oMGet3:Align := CONTROL_ALIGN_ALLCLIENT
		oMGet3:oFont := TFont():New('Courier New', 6, 16 )
		oMGet3:lWordWrap := .F.

		oPanel7 := tPanel():New(0, 0,, oDlg,,,,,, 31, 20, .F., .F.)
		oPanel7:Align := CONTROL_ALIGN_BOTTOM

		@ 005, 005 BUTTON oButton2 PROMPT "Detalhes" SIZE 037, 012 OF oPanel7 PIXEL ACTION Iif(Empty(cLog) .And. !oPanel4:lVisible,;
		Processa({|| CarregaLog(@cLog,cArqLog,oDlg,oPanel4,.T.,.T.)},"Detalhes"),;
		CarregaLog(cLog,cArqLog,oDlg,oPanel4,.F.,.T.))

		If !lError .And. !lSimulacao
			@ 005, 156 BUTTON oButton5 PROMPT "Visu. Calc" SIZE 037, 012 OF oPanel7 PIXEL ACTION GFEVisuCalc(oDbTree:GetCargo())
		EndIf

		@ 005, 198 BUTTON oButton4 PROMPT "Salvar"   SIZE 037, 012 OF oPanel7 PIXEL ACTION (Iif(Empty(cLog),;
		(Processa({|| CarregaLog(@cLog,cArqLog,,,.T.)},"Imprimir"),GFECalcSav(cLog)),;
		GFECalcSav(cLog)),;
		oDlg:End())
		@ 005, 240 BUTTON oButton3 PROMPT "Imprimir" SIZE 037, 012 OF oPanel7 PIXEL ACTION Iif(Empty(cLog),;
		(Processa({|| CarregaLog(@cLog,cArqLog,,,.T.)},"Salvar"),LOGPRINT(cLog,cPrograma)),;
		LOGPRINT(cLog,cPrograma))
		@ 005, 282 BUTTON oButton1 PROMPT "Fechar"  SIZE 037, 012 OF oPanel7 PIXEL ACTION oDlg:End()

		oPanel4:Hide()
		oDlg:nHeight -= 275

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT GFEErrProb(oDbTree:GetCargo(), @cProb, @cSolu, @cText, aItemText)

		GFEXFB_ARESTAREA(lTabTemp,aAreaAG,0) //RestArea(aAreaAG)
		GFEXFB_ARESTAREA(lTabTemp,aAreaCF,6) //RestArea(aAreaCF)
		GFEXFB_ARESTAREA(lTabTemp,aAreaTR,7) //RestArea(aAreaTR)
		GFEXFB_ARESTAREA(lTabTemp,aAreaDC,1) //RestArea(aAreaDC)

Return NIL // FIM ShowErrLog()

//---------------------------------------

Static Function GFEVisuCalc(cCalc)
	Local aAuxCalc := STRTOKARR( cCalc , ";" )
	Local cFilCalc := ""
	Local cNrCalc  := ""

	If Len(aAuxCalc) == 2 
		cFilCalc := aAuxCalc[1]
	 	cNrCalc  := aAuxCalc[2]
		If !Empty(cFilCalc) .And. !Empty(cNrCalc)
			GWF->(dbSetOrder(1) )
			If GWF->(dbSeek(cFilCalc + cNrCalc) )
				FWExecView("Visualizar", "GFEC080", 1,, {||.T.})
			EndIf
		EndIf
	EndIf
Return

//---------------------------------------

Static Function GFECalcSav(cLog)

	Local cMask := STR0323 //"Arquivos Texto (*.TXT) |*.txt|"
	Local cFile := ''

	cFile := cGetFile(cMask,OemToAnsi(STR0327))

	If !Empty(cFile)
		MemoWrite(cFile,cLog)
	EndIf

Return

//---------------------------------------

Function GFETotFret(cNrCalc)

	Local aAreaCCF := GFEXFB_9GETAREA(lTabTemp, cTRBCCF, 9) 
	Local nVlTot   := 0

	GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9) 
	GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{cNrCalc}) 
	While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == cNrCalc

		If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE") == "1"
			nVlTot += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9) 
	EndDo

	GFEXFB_ARESTAREA(lTabTemp,aAreaCCF,9) //RestArea(aAreaCCF)

Return nVlTot

//---------------------------------------

Static Function GFEErrProb(cCalc, cProb, cSolu, cText, aItemText)

	Local nPos
	Local aErr
	Local nX
	Local nY
	Local cDesc := Iif(lCalcServ .And. !IsInCallStack("GFE050CALC"), "Ocorrência ","Romaneio ")
	Private cSeparador := CRLF + "--------------------------------------------------------" + CRLF
	If SubStr(cCalc, 1, 3) == "GEN" // erro na geração do romaneio

		nX := Val(SubStr(cCalc, 4))

		If nX == 0 .And. (nX := AScan(aErroCalc, {|x| x[1] == "GEN"})) == 0

			Return

		EndIf

		aErr := GFECalcErr(aErroCalc[nX][2])

		oMGet1:Show()
		oMGet2:Show()

		oSay1:Show()
		oSay2:Show()
		oList1:Hide()

		cProb := aErr[1]
		cSolu := aErr[2]

		oMGet1:Refresh()
		oMGet2:Refresh()

	ElseIf SubStr(cCalc, 1, 3) == "AGR" //agrupador ou romaneio

		If (nX := AScan(aErroCalc, {|x| x[3] == SubStr(cCalc, 4)})) == 0

			aItemText:= {IIf(lSimulacao, "Agrupador ", cDesc) + AllTrim(SubStr(cCalc, 4)) + " calculado com sucesso."}
			oMGet1:Hide()
			oMGet2:Hide()

			oSay1:Hide()
			oSay2:Hide()
			oList1:SetArray(aItemText)
			oList1:Show()
			oList1:Refresh()
		Else

			nX := AScan(aErroCalc, {|x| x[3] == SubStr(cCalc, 4) .And. x[5] == .F.})

			If nX > 0 //tem erros
				cProb := cSolu := ""
				nX := AScan(aErroCalc, {|x| x[3] == SubStr(cCalc, 4) .And. x[1] == "" .And. x[5] == .F.})
				If nX > 0 // é um erro do romaneio
					For nX := 1 To Len(aErroCalc)
						If aErroCalc[nX][3] == SubStr(cCalc, 4) .And. aErroCalc[nX][1] == "" .And. aErroCalc[nX][5] == .F.
							aErr:=GFECalcErr(aErroCalc[nX][2])
							For nY:= 1 to Len(aErroCalc[nX][4])
								aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aErroCalc[nX][4][nY])
							Next
							If !Empty(cProb)
								cProb += cSeparador
								cSolu += cSeparador
							EndIf
							cProb += aErr[1]
							cSolu += aErr[2]
						EndIf
					Next
					oMGet1:Show()
					oMGet2:Show()

					oSay1:Show()
					oSay2:Show()
					oList1:Hide()

					oMGet1:Refresh()
					oMGet2:Refresh()
				Else // é um erro do cálculo
					aItemText := {}
					If AScan(aErroCalc, {|x| x[3] == SubStr(cCalc, 4) .And. x[1] != "" .And. x[5] == .F. .And. x[2]>= 16 .And. x[2] <= 19}) != 0
						aAdd(aItemText,IIf(lSimulacao, "Agrupador ", cDesc) + "possui cálculos com valores acima do limite.")
					Else
						aAdd(aItemText,IIf(lSimulacao, "Agrupador ", cDesc) + "possui um ou mais erros no cálculo.")
					EndIf

					aAdd(aItemText,IIf(lSimulacao, "Agrupador ", cDesc) + "calculado com erros.")
					oMGet1:Hide()
					oMGet2:Hide()

					oSay1:Hide()
					oSay2:Hide()
					oList1:SetArray(aItemText)
					oList1:Show()
					oList1:Refresh()
				EndIf

			Else

				aItemText := {}
				For nX := 1 To Len(aErroCalc)
					If aErroCalc[nX][3] ==SubStr(cCalc, 4) .And. aErroCalc[nX][1] == ""
						aErr:=GFECalcErr(aErroCalc[nX][2])

						For nY:= 1 to Len(aErroCalc[nX][4])
							aErr[3] := StrTran(aErr[3],"[" + cValToChar(nY) + "]",aErroCalc[nX][4][nY])
						Next

						//						aErr[3] := IIf(lSimulacao, "Agrupador ", "Romaneio ") + SubStr(cCalc, 4) + aErr[3]
						aAdd(aItemText,aErr[3])
					EndIf
				Next nX

				If AScan(aErroCalc, {|x| x[3] == SubStr(cCalc, 4)  .And. x[1] != ""}) > 0
					aAdd(aItemText,IIf(lSimulacao, "Agrupador ", cDesc) + AllTrim(SubStr(cCalc, 4)) + " possui alertas.")
				EndIf

				aAdd(aItemText,IIf(lSimulacao, "Agrupador ", cDesc) + AllTrim(SubStr(cCalc, 4)) + " calculado com sucesso.")

				oMGet1:Hide()
				oMGet2:Hide()

				oSay1:Hide()
				oSay2:Hide()
				oList1:SetArray(aItemText)
				oList1:Show()
				oList1:Refresh()
			EndIf

		EndIf


	ElseIf (nPos := AScan(aErroCalc, {|x| AllTrim(x[1]) == AllTrim(cCalc)})) != 0 //cálculo ou unid de calc

		nX := AScan(aErroCalc, {|x| AllTrim(x[1]) == AllTrim(cCalc)})

		If nX > 0 
			If aErroCalc[nX][6] == 1 //Tipo Problema/Solução
				MostraErro(cCalc,@cProb,@cSolu)
			Else
				MostraAviso(cCalc)
			EndIf
		EndIf

	Else

		If lError .Or. lSimulacao
			aItemText := {"Unidade de Cálculo " + AllTrim(Str(Val(cCalc))) + " realizada com sucesso."}
		Else
			aItemText := {"Cálculo " + Alltrim(cCalc) + " realizado com sucesso."}
		EndIf

		oMGet1:Hide()
		oMGet2:Hide()

		oSay1:Hide()
		oSay2:Hide()
		oList1:SetArray(aItemText)
		oList1:Show()
		oList1:Refresh()
	EndIf

Return

/*----------------------------------------------------------------------------
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
----------------------------------------------------------------------------*/
Static Function AddToLog(cTexto, nPosicao, lTime)
	Default lTime	 := .T.
	Default nPosicao := _LOG_END

	If !lSaveLog
		Return
	EndIf
	
	oGFEXFBFLog:setPosicao(nPosicao)
	oGFEXFBFLog:setTime(lTime)
	oGFEXFBFLog:setSaveLog(lSaveLog)
	oGFEXFBFLog:setTexto(cTexto)
Return NIL

/*----------------------------------------------------------------------------
{Protheus.doc} LOGPRINT
Impressao do log.
Uso: ShowErrLog

@param  aLog        array contendo o conteudo para impressao
@param  cPrograma   programa que chama a impressao

@sample GFEESCTAB()

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Static Function LOGPRINT(cLog,cPrograma)
	Local aTitle := {If(lError,STR0324,STR0325)+STR0326} //"Inconsistência"###"Log de Processo"###" - Cálculo de Frete"
	Local aLog   := {}
	AAdd(aLog,{cLog})
	CursorWait()
	fMakeLog( aLog,aTitle,,.T.,cPrograma,aTitle[1],"G","P",,.F.)
	CursorArrow()
Return NIL

/*----------------------------------------------------------------------------
{Protheus.doc} GFEConvUM
Conversao de Unidades de Medida para a rotina de calculo de frete.
Uso: GFECLCFRT

@param  cUMOri      Unidade Origem
@param  cUMDes      Unidade Destino
@param  nQtd        Quantidade para Conversao

@sample GFEConvUM(cUMOri,cUMDes,nQtd)

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Function GFEConvUM(cUMOri,cUMDes,nQtd)

	cUMOri := PadR(cUMOri,TamSX3("GUV_UNIDE")[1])
	cUMDes := PadR(cUMDes,TamSX3("GUV_UNIPAR")[1])

	If AllTrim(cUMOri) <> AllTrim(cUMDes)
		GUV->(dbSetOrder(01))
		If GUV->(dbSeek(xFilial("GUV")+cUMOri+cUMDes))
			nQtd := (nQtd/GUV->GUV_QTDDE) * GUV->GUV_QTDPAR
		Else
			If GUV->(dbSeek(xFilial("GUV")+cUMDes+cUMOri))
				nQtd := (nQtd/GUV->GUV_QTDPAR) * GUV->GUV_QTDDE
			Else
				AddToLog(STR0329 + cUMOri + STR0330 + cUMDes + STR0331 + CRLF) //" ERRO!!! Conversão de Unidades de "###" para "###" não cadastrada."
				GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), 13)
				lError := .T.
				nQtd := 0
			EndIf
		EndIf
	EndIf

Return nQtd

/*----------------------------------------------------------------------------
{Protheus.doc} GFEVldMovCtb
Verifica se o calculo de frete possui movimentos contabeis enviados para o ERP. Neste caso o
calculo de frete nao pode ser eliminado.

Uso: GFEVldMovCtb(cNrCalc)

@param  cNrCalc    		Número do calculo de frete a verificar

@sample GFEVldMovCtb("00000001")

@author Luciano de Araujo
@since 14/04/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEVldMovCtb(cNrCalc, cFilCalc)
	Local lApaga := .T.

	Default cFilCalc := xFilial("GWA")

	GWA->(dbSetOrder(01))
	If GWA->(dbSeek(cFilCalc + "1"/*Tp.Docto*/ + PadR("",5)/*Esp.Doc.*/ + PadR("",9)/*Emit.*/ + PadR("",5)/*Serie*/ + cNrCalc))
		While !GWA->(Eof()) .AND. GWA->GWA_FILIAL == xFilial("GWA");
		.AND. GWA->GWA_TPDOC  == "1" /*Cálculo de frete*/;
		.AND. GWA->GWA_CDESP  == PadR("",5);
		.AND. GWA->GWA_CDEMIT == PadR("",TamSX3("GU3_CDEMIT")[1]);
		.AND. GWA->GWA_SERIE  == PadR("",5);
		.AND. AllTrim(GWA->GWA_NRDOC) == AllTrim(cNrCalc)
			If GWA->GWA_SITCTB $ "24"	// Situacao do movimento igual a 2 (Pendente) ou 4 (Atualizado)
				lApaga := .F.
				Exit
			EndIf
			GWA->(dbSkip())
		EndDo
	EndIf

Return lApaga

/*----------------------------------------------------------------------------
{Protheus.doc} GFEVldDocFrete
Verifica se os documentos de carga do cálculo estão associados a um documento de frete, retornando
falso(.F.) quando houver o vínculo.

Uso: GFEVldDocFrete(cNrCalc)

@param  cNrCalc    		Número do cálculo de frete a verificar

@sample GFEVldDocFrete("00000001")

@author Luciano de Araujo
@since 11/05/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEVldDocFrete(cNrCalc, lTpDf, cFilCalc)
	Local lApaga 	 := .T.
	Local cMV_GFE005 := SuperGetMv("MV_GFE005",.F.,"1") 
	Default lTpDf 	 := .F.
	Default cFilCalc := xFilial("GWH")
	
	If Empty(cMV_GFE005)
		cMV_GFE005 := "1"
	EndIf

	GW3->(dbSetOrder(01))
	GWF->(dbSetOrder(01))
	GWH->(dbSetOrder(01))

	GWH->(dbSeek(cFilCalc + cNrCalc))
	While lApaga .And. !GWH->(Eof()) .and. GWH->GWH_NRCALC == cNrCalc

		// Verifica se o documento de carga do calculo esta vinculado a um documento de frete
		GW4->(dbSetOrder(02))
		If GW4->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC + GWH->GWH_CDTPDC))
			While !GW4->(Eof()) .And. GWH->GWH_FILIAL + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC + GWH->GWH_CDTPDC == GW4->(GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC)
				GWF->(dbseek(cFilCalc + cNrCalc))
				GW3->(dbSeek(GW4->(GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS))))
				If GW3->GW3_TPDF == GWF->GWF_TPCALC .And. ;
				   ((!lExiCDESP .Or. (s_DPSERV == "2")) .Or. GWF->(GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DTOS(GWF_DTEMDF)) == GW3->(GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)))

					If (cMV_GFE005 == "1" .Or. (cMV_GFE005 == "2" .And. GW3->GW3_SIT $ "34"))
						lApaga := .F.
						Exit
					EndIf
				EndIf
				
				GW4->(dbSkip())
			EndDo
		EndIf

		GWH->(dbSkip())
	EndDo

Return lApaga

/*----------------------------------------------------------------------------
{Protheus.doc} GFEVldDocCalc
Verifica se os documentos de carga do cálculo de frete foram considerados na geracao do calculo.
Se algum documento de carga nao foi considerado, significa que o novo calculo esta gerando
um novo agrupamento de documentos de carga.

Uso: GFEVldDocCalc(cNrCalc,aDoctoCarga)

@param  cNrCalc    		Número do calculo de frete a verificar
@param  [aDoctoCarga]	Array com os documentos de carga do processo de calculo. Opcional.

@sample GFEVldDocCalc("00000001",)

@author Luciano de Araujo
@since 19/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEVldDocCalc(cNrCalc, aDoctoCarga, cFilCalc)

	Local lApaga := .T.

	Default aDoctoCarga := {}
	Default cFilCalc    := xFilial("GWH")

	GWH->(dbSetOrder(01))
	GWH->(dbSeek(cFilCalc + cNrCalc))
	While !GWH->(Eof()) .And. GWH->GWH_NRCALC == cNrCalc

		// Verifica se o documento de carga do calculo consta na lista de documentos de carga recebidos para calcular
		// Quando aDoctoCarga é maior que zero, significa que a funcao foi chamada da rotina de calculo
		if len(aDoctoCarga) > 0 .and. aScan(aDoctoCarga,{|cChave| cChave == GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC}) == 0
			lApaga := .F.
			Exit
		EndIf

		GWH->(dbSkip())
	EndDo

Return lApaga


/*----------------------------------------------------------------------------
{Protheus.doc} GFEVldPreFat
Verifica se o calculo de frete esta vinculado a uma pre-fatura, retornando .T.
caso nao possua tal vinculo.

Uso: GFEVldPreFat(cNrCalc)

@param  cNrCalc     Número do calculo de frete a verificar

@sample GFEVldPreFat("00000001")

@author Luciano de Araujo
@since 19/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEVldPreFat(cNrCalc, cFilCalc)
	Local lApaga := .T.

	Default cFilCalc := xFilial("GWF")

	GWF->(dbSetOrder(01))
	If GWF->(dbSeek(cFilCalc + cNrCalc)) .AND. !Empty(GWF->GWF_NRPREF)
		lApaga := .F.
	EndIf

Return lApaga

/*/{Protheus.doc} GFEVldLotProvisao
//TODO Verifica se o Numero do cálculo encontra-se em um Lote de Previsão.
@author andre.wisnheski
@since 07/09/2017
@version 1.0
@return ${lApaga}, ${Retorna se o cálculo pode ou não se apagado}
@param cNrCalc, characters, Numero do cálculo 
@type function
/*/
Function GFEVldLotProvisao(cNrCalc, cFilCalc)
	Local lApaga := .T.

	Default cFilCalc := xFilial("GXD")

	GXD->(dbSetOrder(02))
	If GXD->(dbSeek(cFilCalc + cNrCalc))
		lApaga := .F.
	EndIf

Return lApaga

/*----------------------------------------------------------------------------
{Protheus.doc} GFEVldContr
Verifica se o calculo de frete esta vinculado a um contrato com autonomos,
retornando .T. caso nao possua tal vinculo.

Uso: GFEVldContr(cNrCalc)

@param  cNrCalc     Número do calculo de frete a verificar

@sample GFEVldContr("00000001")

@author Luciano de Araujo
@since 19/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEVldContr(cNrCalc, cFilCalc)
	Local lApaga := .T.

	Default cFilCalc := xFilial("GWF")

	GWF->(dbSetOrder(01))
	If GWF->(dbSeek(cFilCalc + cNrCalc)) .And. !Empty(GWF->GWF_NRCONT)
		lApaga := .F.
	EndIf

Return lApaga

/*----------------------------------------------------------------------------
{Protheus.doc} GFEDelCalc
Elimina o calculo de frete e seus relacionamentos

Uso: GFEDelCalc(cNrCalc, [ cFilCalc ] )

@param  cNrCalc	Número do calculo de frete a eliminar
@param  cFilCalc	Filial do calculo de frete a eliminar. Em branco utiliza a filial corrente
@param  lDeleta	Opcional, evita ou permite a exclusão de cálculo ORIGEM = 4 (Simulação)
@param  aNrCalc	Permite passar um array com os números de cálculos para serem deletados.

@sample GFEDelCalc("00000001", "01")

@author Luciano de Araujo
@since 19/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEDelCalc(cNrCalc, cFilCalc, lDeleta, aNrCalc,cOriCalc)
	
	Local oDelCalc := GFEXFBB():New()
	Local nX
	
	Default aNrCalc  := Nil
	Default cOriCalc := "2" 
	
	If cFilCalc != Nil
		oDelCalc:setFilCalc(cFilCalc)
	EndIf
	If lDeleta != Nil
		oDelCalc:setDeleta(lDeleta)
	EndIf
	
	If !Empty(aNrCalc)
        For nX := 1 To Len(aNrCalc)		// Remove dados ddo calculo
			If Len(aNrCalc[nX]) > 1
				oDelCalc:setNrCalc(aNrCalc[nX][1])
				oDelCalc:setFilCalc(aNrCalc[nX][2])
			Else
				oDelCalc:setNrCalc(aNrCalc[nX])
			EndIf
        	oDelCalc:Deletar()
        Next nX
    Else 		// Remove dados ddo calculo
    	oDelCalc:setNrCalc(cNrCalc)
        oDelCalc:Deletar()
	EndIf
	 
	If !Empty(oDelCalc)
	 	oDelCalc:= Nil
	EndIf 	
Return

/*----------------------------------------------------------------------------
{Protheus.doc} GFETratDec
Retorna o valor recebido com decimais de acordo com a parametrização da tabela de frete
Uso: GFETratDec

@param  nValor     Valor a ser tratado e retornado
@param  [nPad]     Quantidade de espaços em branco antes de mostrar a mensagem no log

@sample GFETratDec(nValor,6)

@author Luciano de Araujo
@since 25/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFETratDec(nValor,nPad,lArred)

	Default nPad := 0
	Default lArred := .F.

	If lArred //Arredondar PIS, COFINS, ICMS, ISS
		nValor := Round(nValor,2)
	else
		If GVA->GVA_TPARRE == "1" //Truncar
			nValor := NoRound(nValor,2)
		Else //Arredondar
			nValor := Round(nValor,2)
		EndIf
	Endif

	If nPad > 0
		AddToLog(PadR("",nPad) + "[" + Iif(lArred, STR0333, Iif(GVA->GVA_TPARRE == "1", STR0332, STR0333)) + " -> " + cValToChar(nValor) + "]" + CRLF) //"Truncando"###"Arredondando"
	EndIf

Return nValor

/*----------------------------------------------------------------------------
{Protheus.doc} GFECalcComp
Calcula o valor dos componentes para uma tarifa recebida

Uso: GFECalcComp(cNrCalc, cCdClFr, cCdTpOp, cCdTrp, cNumTab, cNrNeg, cCdFxTv, cNrRota, cCdTpVc, nQtCalc, @nVlFretMin, @aNegMin)

@param  cNrCalc		Numero da unidade de calculo
@param	cCdClFr		Código da classificacao de frete
@param	cCdTpOp		Código do tipo de operacao
@param	cCdTrp		Código do emitente transportador
@param	cNumTab		Número da tabela de frete
@param	cNrNeg		Número da negociacao de frete
@param	cCdFxTv		Número da faixa/tipo de veículo
@param	cNrRota		Número da rota
@param  cCdTpVc     Código do tipo de veiculo
@param  nQtCalc     Quantidade para calculo
@param  nVlFretMin	Valor de referencia para frete minimo que será atualizado pela função
@param  aNegMin     Array que será atualizado com a negociacao do frete minimo
@param lSimulFrt    Verifica se a função é chamada pela GfeSimulFret

@sample GFECalcComp("00000001","1","","1","1","1,"0001","0001","CAMINHAO",100,@nValFretMin,)

@author Luciano de Araujo
@since 29/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFECalcComp(cNrCalc, cCdClFr, cCdTpOp, cCdTrp, cNumTab, cNrNeg, cCdFxTv, cNrRota, cCdTpVc, nQtCalc, nVlFretMin, aNegMin, aValFV, lSimulFrt, lUtlFrMin)
	Local cCdEmit, cNrTab, cCatVal
	Local lVinculo    	:= .T.
	Local nPos        	:= 0
	Local nQtEntregas 	:= 0
	Local nMulVin, nAdcVin, nMul, nAdc, nQtde, nQtdePed, nQtdeFai, nFaixa
	Local nValCpn, nValor, nVlFretTot, nVlFrete, nVlFxEntr
	Local aCompCalc 	:= {}  // Array com os componentes calculados, que serao retornados pela funcao
	Local aComps    	:= {}  // Array com os componentes a serem calculados, combinando os componentes da tarifa com os componentes por emitente
	Local aCompVlFr 	:= {}  // Array com os componentes que são calculados sobre o valor do frete
	Local aFaixa    	:= {}  // Array com as faixas soma vinculadas à faixa principal
	Local aInfoTab  	:= {}  // Array com informações de vinculo de uma tabela de frete
	Local aAreaTRBTCF  	:= GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5) 
	Local aAreaTRBUNC  	:= GFEXFB_9GETAREA(lTabTemp, cTRBUNC, 6) 
	Local cNrAgru
	Local lServ        	:= .F.
	Local lServErro    	:= .F.
	Local lErroServ   	:= .F.
	Local aCompServ   	:= {}
	Local cTpLocEntr 	:= s_TREENTR
	Local lSeek
	Local idpRotArea
	Local aComTarifa 	:= {}
	Local aStru 		:= {}
	Local cFxTod
	Local cRotTod
	Local aLinha
	Local nX
	Local nY
	Local nZ
	Local nQ
	Local nU
	Local lEspaco
	Local cSeek
	Local lLoop        	:= .F.
	Local lDevol       	:= .F.
	Local lReent       	:= .F.
	Local cAliasCalc   	:= NIL
	Local cTipoCalc  	:= " "

	Private nVlPe20	   	:= 0
	Private lPEXFB20   	:= ExistBlock("GFEXFB20") 
		
	Default nVlFretMin 	:= 0
	Default aNegMin    	:= {}
	Default aValFV     	:= {}
	Default lSimulFrt  	:= .F.
	Default lUtlFrMin  	:= .T.

	If cTpLocEntr != "1"
		cTpLocEntr := ""
	EndIf

	GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6) //
	GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC1, 6,{cNrCalc}) //
	cNrAgru := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")

	GFEXFB_ARESTAREA(lTabTemp,aAreaTRBUNC,6) //RestArea(aAreaTRBUNC)

	GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
	GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{cNrCalc, cCdClFr, cCdTpOp}) 

	While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. ;
			cNrCalc + cCdClFr + cCdTpOp == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") .And. lVinculo
			lLoopTCF := .F.
		// Retorna as informações de vinculo de uma tabela
		aInfoTab := GFEInfoTab(cCdTrp,cNumTab)
		lVinculo := aInfoTab[1]
		cCdEmit  := aInfoTab[2]
		cNrTab   := aInfoTab[3]
		nMulVin  := aInfoTab[4]
		nAdcVin  := aInfoTab[5]

		AddToLog(STR0334 + cCdEmit + STR0067 + cNrTab + STR0246 + cNrNeg + STR0069 + cNrRota + STR0092 + cCdFxTv + ") " +; //"    Tarifa (Transp. "###"; Tabela "###"; Negoc "###"; Rota "###"; Faixa "
		STR0335 + If(lVinculo, STR0336, STR0076) + If(lVinculo, CRLF + STR0337 + cValToChar(nMulVin) + STR0338 + cValToChar(nAdcVin) + CRLF, CRLF)) //"; Tipo Tab. "###"Vínculo"###"Normal"###"      Multiplicar valores da tarifa por "###", adicionar "

		//Verifica o tipo de lotação da negociação da tabela
		GV9->(dbSetOrder(01))
		GV9->(dbSeek(xFilial("GV9")+cCdEmit+cNrTab+cNrNeg))

		If GV9->GV9_TPLOTA $ "2;3"	 //Carga Fechada ou Veículo Dedicado
			//************************
			//*TIPO VEICULO			 *
			//************************
			//Procura faixa pelo tipo de veiculo
			
			If !Empty(cCdFxTv)
				cSeek := cCdFxTv
				GV7->(dbSetOrder(01))
			Else
				cSeek := cCdTpVc
				GV7->(dbSetOrder(02))
			EndIf
			
			If GV7->(dbSeek(xFilial("GV7")+cCdEmit+cNrTab+cNrNeg+cSeek))
				// Imprimi mensagem
				AddToLog(STR0624 + cCdTpVc + STR0058 + GV7->GV7_CDFXTV + CRLF) //"    Tipo Veículo (" ### ") -> Faixa "
				// Cria o array com a unica faixa de tipo de veiculo, somente existira uma faixa.
				aAdd(aFaixa,{GV7->GV7_CDFXTV,/*Qtde p/ calculo*/,/*Qtde convertida*/,GV7->(RecNo()),0})

			EndIf
		Else
			//************************
			//* FAIXA     			 *
			//************************
			nFaixa := 0
			GV7->(dbSetOrder(01))
			If GV7->(dbSeek(xFilial("GV7")+cCdEmit+cNrTab+cNrNeg+cCdFxTv))

				aAdd(aFaixa,{cCdFxTv,/*Qtde p/ calculo*/,/* Qtde convertida*/,GV7->(RecNo()),0})
				nFaixa++

				AddToLog(CRLF + STR0339 + cCdFxTv) //"    Faixas ("

				While !Empty(GV7->GV7_FXSOMA) .And. (aScan(aFaixa, {|x| x[1] == GV7->GV7_FXSOMA}) == 0)
					GV7->(dbSetOrder(01))
					If GV7->(dbSeek(xFilial("GV7")+cCdEmit+cNrTab+cNrNeg+GV7->GV7_FXSOMA))

						// Grava na faixa anterior o valor final da faixa corrente
						// Este valor será usado adiante para definir as quantidades para calculo por faixa
						aFaixa[nFaixa,5] := GV7->GV7_QTFXFI

						//grava o array com as informações das várias faixas que podem existir
						aAdd(aFaixa,{GV7->GV7_CDFXTV,,,GV7->(RecNo()),0})
						nFaixa++
						AddToLog(" -> " + GV7->GV7_CDFXTV)
					EndIf
				EndDo
				AddToLog(")" + CRLF)
			EndIf
		EndIf

		nQtdePed := 0
		nQtdeFai := 0

		//verifica se existem tarifas para cada faixa encontrada com a rota selecionada,
		//no caso de tipo de veiculo entra, mas não grava as posicoes 2 e 3 do array aFaixa
		//pois esses valores somente serao utilizados se o calculo for por faixa
		For nX := 1 To Len(aFaixa)

			// Faixa da tabela de frete
			GV7->(dbSetOrder(01))
			If GV7->(dbSeek(xFilial("GV7")+cCdEmit+cNrTab+cNrNeg+aFaixa[nX,1]))

				// Verifica se existe componente para a faixa
				GV1->(dbSetOrder(01))
				If GV1->(dbSeek(xFilial("GV1")+cCdEmit+cNrTab+cNrNeg+aFaixa[nX,1]+cNrRota))

					nQtdeFai := IF(GV9->GV9_TPLOTA=="1",GFEConvUM(GV9->GV9_UNIFAI,GV7->GV7_UNICAL,nQtCalc),nQtCalc)

					// Tarifa do componente
					GV6->(dbSetOrder(01))
					If GV6->(dbSeek(xFilial("GV6")+cCdEmit+cNrTab+cNrNeg+aFaixa[nX,1]+cNrRota))

						// Verifica o valor minimo de frete da negociacao
						// Quando ha faixas soma, considera o valor apenas da 1a faixa
						If nX == 1
							AddToLog(STR0340 + cValToChar(GV6->GV6_FRMIN) + STR0341 + cValToChar(nVlFretMin) + CRLF) //"      *** Frete mínimo da faixa: "###" x Frete mínimo selecionado: "
							If nVlFretMin < GV6->GV6_FRMIN
								nVlFretMin := GV6->GV6_FRMIN
								aNegMin := {GV6->GV6_CDEMIT,GV6->GV6_NRTAB,GV6->GV6_NRNEG}
							EndIf
						EndIf

						// Verifica a quantidade minima de calculo para a tarifa. Já está na unidade de medida da tarifa (GV7_UNICAL)
						If lUtlFrMin
							IF nQtdeFai < GV6->GV6_QTMIN
								nQtdeFai := GV6->GV6_QTMIN

								If GV9->GV9_TPLOTA == "1"
									nQtCalc := GFEConvUM(GV7->GV7_UNICAL,GV9->GV9_UNIFAI,GV6->GV6_QTMIN)	// Converte a qtde minima para a unidade da faixa
								Else
									nQtCalc := GV6->GV6_QTMIN
								EndIf
	
								AddToLog(STR0342 + cValToChar(nQtdeFai) + CRLF) //"      *** Usando qtde. mínima da faixa: "
							EndIf
						EndIf
					EndIf

					// Tratamento da quantidade para calculo quando ha mais de uma faixa (faixas soma). Carga fechada não tem faixa soma.
					IF Len(aFaixa) > 1
						If aFaixa[nX,5] > 0
							nQtdeFai -= GFEConvUM(GV9->GV9_UNIFAI,GV7->GV7_UNICAL,aFaixa[nX,5])	// Desconta o valor final da faixa anterior da quantidade para calculo
							nQtCalc  -= aFaixa[nX,5]
						Else
							nQtdeFai = GFEConvUM(GV9->GV9_UNIFAI,GV7->GV7_UNICAL,GV7->GV7_QTFXFI)	// Na ultima faixa, utiliza o valor final da faixa
							nQtCalc  = GV7->GV7_QTFXFI
						EndIf
					EndIf

					// Acumula a quantidade original para utilizar no cálculo do pedágio
					nQtdePed += nQtCalc

					aFaixa[nX,2] := nQtCalc
					// Quando 1-carga fracionada, converte a quantidade para calculo da unidade da faixa para a unidade para calculo
					aFaixa[nX,3] := IF(GV9->GV9_TPLOTA == "1",GFEConvUM(GV9->GV9_UNIFAI,GV7->GV7_UNICAL,aFaixa[nX,2]),nQtCalc)

					AddToLog(STR0343 + aFaixa[nX,1] + STR0344 + cValToChar(aFaixa[nX,3]) +; //"      Faixa: "###" Qtde. Cálculo: "
					IF(GV9->GV9_TPLOTA=="1", " (" + GV9->GV9_UNIFAI+  " -> " + GV7->GV7_UNICAL + ")" + CRLF, CRLF))
				Else
					AddToLog(STR0345 + aFaixa[nX,1] + STR0346 + AllTrim(cNrRota) + "." + CRLF) //"      Não encontrada tarifa para faixa "###"e rota "
				EndIf
			EndIf
		Next nX

		AddToLog(CRLF + STR0347 + CRLF + CRLF) //"    # Calculando valores dos componentes para as faixas encontradas..."

		For nX := 1 to Len(aFaixa)

			AddToLog(STR0348 + aFaixa[nX,1] + CRLF + CRLF) //"      # Calculando faixa "

			aComps := {}	// Cada faixa pode ter um conjunto diferente de componentes

			AddCompsGUC(aComps,cCdEmit,cNrTab,cNrNeg,aFaixa[nX,1],cNrRota)
			
			AddToLog(CRLF)
			
			If (lSeek := GFEXFB_CSEEK(.F., , aTRBROT1, 13, {cNrCalc,cCdEmit,cNrTab,cNrNeg}))
				idpRotArea := idpROT
				AddToLog("      # Listando componentes aplicáveis para emitente em ")
				lEspaco := .F.
				While !GFEXFB_3EOF(.F., , @aTRBROT1, 13) .And.;
					cNrCalc == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC") .And.;
					cCdEmit == GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRP" ) .And.;
					cNrTab  == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTAB" ) .And.;
					cNrNeg  == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEG" )
					
					If !Empty(GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA")) .And. GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA") != cNrRota
						GFEXFB_8SKIP(.F., , 13)
						Loop
					EndIf
					
					If !Empty(GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV")) .And. GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV") != aFaixa[nX,1]
						GFEXFB_8SKIP(.F., , 13)
						Loop
					EndIf
					
					cRotTod := GFEXFB_5CMP(.F., , @aTRBROT1, 13,"NRRTTOD")
					cFxTod  := GFEXFB_5CMP(.F., , @aTRBROT1, 13,"CDFXTOD")
					If lEspaco
						AddToLog("      # ")
					EndIf
					If !Empty(cRotTod)
						AddToLog("todas as rotas ")
					EndIf
					
					If !Empty(cFxTod)
						If !Empty(cRotTod)
							AddToLog("e ")
						EndIf
						AddToLog("todas as faixas")
					EndIf
					
					AddToLog(" da rota: " + If(!Empty(cRotTod),cRotTod,cNrRota))
					AddToLog(" da faixa: " + If(!Empty(cFxTod),cFxTod,aFaixa[nX,1]))
					
					AddToLog(CRLF)
					
					If AddCompsGUC(aComps,;
									GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRPCOD" ),;
									GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTABCOD" ),;
									GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEGCOD" ),;
									If(!Empty(cFxTod),cFxTod,aFaixa[nX,1]),;
									If(!Empty(cRotTod),cRotTod,cNrRota),.T.)
						aAdd(aComTarifa,{GFEXFB_GRECNO(lTabTemp, cTRBTCF, 5),GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRPCOD" ),GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTABCOD" ),GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEGCOD" ),If(!Empty(cFxTod),cFxTod,aFaixa[nX,1]),If(!Empty(cRotTod),cRotTod,cNrRota),GFEXFB_5CMP(.F., , aTRBROT1, 13,"PRIORI" ),GFEXFB_5CMP(.F., , aTRBROT1, 13,"PRIFAI" )})
						
					EndIf
					
					
					AddToLog(CRLF)
					 
					lEspaco := .T.
					GFEXFB_8SKIP(.F., , 13)
				EndDo
				
				AddToLog("      # Fim da listagem")
				AddToLog(CRLF)
				idpROT := idpRotArea
			EndIf
			
			AddComps(aComps,cCdEmit,cNrTab,cNrNeg,aFaixa[nX,1],cNrRota)
			
			If lSeek
				idpRotArea := idpROT
				
				AddToLog("      # Listando componentes aplicáveis em ")
				lEspaco := .F.
				While !GFEXFB_3EOF(.F., , @aTRBROT1, 13) .And.;
					cNrCalc == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC") .And.;
					cCdEmit == GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRP" ) .And.;
					cNrTab  == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTAB" ) .And.;
					cNrNeg  == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEG" )
					
					If !Empty(GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA")) .And. GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA") != cNrRota
						GFEXFB_8SKIP(.F., , 13)
						Loop
					EndIf
					
					If !Empty(GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV")) .And. GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV") != aFaixa[nX,1]
						GFEXFB_8SKIP(.F., , 13)
						Loop
					EndIf
					
					cRotTod := GFEXFB_5CMP(.F., , @aTRBROT1, 13,"NRRTTOD")
					cFxTod  := GFEXFB_5CMP(.F., , @aTRBROT1, 13,"CDFXTOD")
					
					cRotTod := If(!Empty(cRotTod),cRotTod,cNrRota   )
					cFxTod  := If(!Empty(cFxTod),cFxTod,aFaixa[nX,1])
					
					If aScan(aComTarifa,{|x| x[2] == cCdEmit .And. x[3] == cNrTab .And. x[4] == cNrNeg .And. x[5] == cFxTod .And. x[6] == cRotTod}) == 0
						GFEXFB_8SKIP(.F., , 13)
						Loop
					EndIf
					
					cRotTod := GFEXFB_5CMP(.F., , @aTRBROT1, 13,"NRRTTOD")
					cFxTod  := GFEXFB_5CMP(.F., , @aTRBROT1, 13,"CDFXTOD")
					If lEspaco
						AddToLog("      # ")
					EndIf
					If !Empty(cRotTod)
						AddToLog("todas as rotas ")
					EndIf
					
					If !Empty(cFxTod)
						If !Empty(cRotTod)
							AddToLog("e ")
						EndIf
						AddToLog("todas as faixas")
					EndIf
					
					AddToLog(" da rota: " +  If(!Empty(cRotTod),cRotTod,cNrRota   ))
					AddToLog(" da faixa: " + If(!Empty(cFxTod),cFxTod,aFaixa[nX,1]))
					
					AddToLog(CRLF)
					AddComps(aComps,;
							GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRPCOD" ),;
							GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTABCOD" ),;
							GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEGCOD" ),;
							If(!Empty(cFxTod),cFxTod,aFaixa[nX,1]),;
							If(!Empty(cRotTod),cRotTod,cNrRota))
					AddToLog(CRLF)
					lEspaco := .T.
					GFEXFB_8SKIP(.F., , 13)
				EndDo
				
				AddToLog("      # Fim da listagem")
				AddToLog(CRLF)
				idpROT := idpRotArea
			EndIf

			If lCalcServ .and. Len(aComps) == 0 .And. !lSimulFrt 
				Exit
			Endif

			if lCalcServ
				aServErro := {}
				aServ2 := {}
			Endif

			For nY := 1 to Len(aComps)
				lDevol := .F.
				lReent := .F.
				nValor := nQtde := 0

				GV2->(dbSetOrder(01))
				If GV2->(dbSeek(xFilial("GV2")+aComps[nY,_CDCOMP]))

					if !lCalcServ
						If GV2->GV2_SERVI == "1"
							// Componente de serviço não é considerado no cálculo de frete normal
							AddToLog(Space(8)+STR0555 + aComps[nY,_CDCOMP] + STR0556 + CRLF + CRLF) //"Componente "###" configurado para Serviço. Passando ao próximo componente da faixa..."
							Loop

						ElseIf GV2->GV2_CATVAL == "5"
							AddToLog("        Desconsiderando componente de categoria IMPOSTO: " + Alltrim(aComps[nY,_CDCOMP]) + " - " + Posicione("GV2",1,xFilial("GV2")+aComps[nY,_CDCOMP],"GV2_DSCOMP") + CRLF + CRLF)
							Loop

						Else
							// Identifica se Doc. Carga possui romaneio é de retorno, se for desconsidera componente marcado como não no campo GUY_REENT
							GWU->(dbSetOrder(1))
							If GWU->(dbSeek(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CHVGWU")))
								GW1->(dbSetOrder(1))
								If GW1->(dbSeek(GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC))
									
									GWF->(dbSetOrder(1))
									If GWF->(dbSeek(xFilial("GWF") + GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC")))
										cTipoCalc := GWF->GWF_TPCALC
									EndIf

									If !Empty(cTipoCalc)
										cAliasCalc := GetNextAlias()
										BeginSql Alias cAliasCalc
											SELECT GV5.R_E_C_N_O_ AS RECNUM
											FROM %Table:GV5% GV5
											WHERE GV5.GV5_FILIAL = %xFilial:GV5%
											AND GV5.GV5_CDTPDC = %Exp:GW1->GW1_CDTPDC%
											AND GV5.GV5_TPTRP = '2'
											AND GV5.GV5_SENTID IN ('0','1')
											AND GV5.%NotDel%
										EndSql
										Do While (cAliasCalc)->( !Eof() )
											If cTipoCalc $ "4" // 4 - Reentrega
												If Posicione("GUY", 1, xFilial("GUY") + cCdTrp + cNumTab + cNrNeg + aComps[nY,1],"GUY_REENT") == "2"
													lReent := .T.
												EndIf
											EndIf

											If cTipoCalc $ "5" // 5 - Devolucao
												If Posicione("GUY", 1, xFilial("GUY") + cCdTrp + cNumTab + cNrNeg + aComps[nY,1],"GUY_DEVOL") == "2"
													lDevol := .T.
												EndIf
											EndIf

											(cAliasCalc)->( DbSkip() )
										EndDo

										(cAliasCalc)->( dbCloseArea() )
									EndIf
								EndIf
							EndIf

							If lDevol .Or. lReent
								AddToLog("        Desconsiderando componente: " + Alltrim(aComps[nY,_CDCOMP]) + " - " + Posicione("GV2",1,xFilial("GV2")+aComps[nY,_CDCOMP],"GV2_DSCOMP") + CRLF + CRLF)
								Loop
							Else
								AddToLog(STR0353 + aComps[nY,_CDCOMP] + " - " + Posicione("GV2",1,xFilial("GV2")+aComps[nY,_CDCOMP],"GV2_DSCOMP") + CRLF) //"        Calculando componente: "
							EndIf
						EndIf
					Else								//GV2_CALSER e GV2_UNIT vem no mesmo pacote de dicionário
						If GV2->GV2_SERVI != "1" .OR. ( GFXCP12117("GV2_UNIT") .And. GV2->GV2_CALSER $ '1 ' .And. IsInCallStack("GFE050CALC") ) 
							// Componente que não é de serviço não é considerado no cálculo de frete de serviço realizado pelo GFEA032
							//AddToLog(Space(8)+STR0555 + aComps[nY,_CDCOMP] + STR0556 + CRLF + CRLF) //"Componente "###" configurado para Serviço. Passando ao próximo componente da faixa..."
							Loop
						ELSE
							If aComps2[1][4] <> "TODOS"
								lLoop := .t.
								For nZ := 1 To Len(aComps2)
									nPos := aScan(aComps2[nZ,2],xFilial("GV1")+cCdEmit+cNumTab+cNrNeg+cCdFxTv+cNrRota)
									If nPos > 0 // é a negociação do componente de serviço

										If aComps2[1][4] == "CDTPSE" //Por Tipo de Serviço
											If aScan(aComps2[nZ][3],GV2->GV2_CDCOMP) <> 0  //Encontrou o Componente
												nPos := aScan(aComps2[1,6],{|x|x[1] == cnrcalc})
												If nPos > 0 //É um cálculo original
													
													nPos := aScan(aComps3,{|x|x[1] == cnrcalc})
													If nPos > 0
														If aComps3[nPos,2] == aComps2[nZ][1] // Mesmo tipo de serviço
															lLoop := .f.
														EndIf
													Else
														aAdd(aComps3,{cnrcalc,aComps2[nZ][1]})
														lLoop := .f.
													EndIf
												
												Else
	
													For nQ := 1 To Len(aComps2[1,6])
														nPos := aScan(aComps2[1,6,nQ,2],cnrcalc )
														If nPos > 0 //É um cálculo clonado
															cNrOrig := aComps2[1,6,nQ,1]
															Exit
														EndIf
													Next nQ
													
													nPos := aScan(aComps3,{|x|x[1] == cNrOrig})
													If aComps3[nPos,2] == aComps2[nZ][1] // Tipo pertence ao original
														Exit
													Else
														nPos := 0
														For nU := 1 To Len(aComps2[1,6,nQ,2])
															nPos := aScan(aComps3,{|x|x[1] == aComps2[1,6,nQ,2,nU]})
															If nPos > 0
																If aComps3[nPos,2] == aComps2[nZ][1] .Or. aComps3[nPos,1] == cnrCalc
																	Exit
																Else
																	nPos := 0
																EndIf
															EndIf
														Next nU
														If nPos == 0// Não há o tipo em clones
															aAdd(aComps3,{cnrcalc,aComps2[nZ][1]})
															lLoop := .f.
														ElseIf aComps3[nPos,2] == aComps2[nZ][1] .And. aComps3[nPos,1] == cnrCalc //Em mais de uma negociação para o mesmo cálculo
															lLoop := .f.
														EndIf
													EndIf
													
												EndIf
												Exit
											EndIf
										ElseIf aComps2[nZ][1] == GV2->GV2_CDCOMP
											nPos := aScan(aComps2[1,6],{|x|x[1] == cnrcalc})
											If nPos > 0 //É um cálculo original
												
												nPos := aScan(aComps3,{|x|x[1] == cnrcalc})
												If nPos > 0
													If aComps3[nPos,2] == GV2->GV2_CDCOMP // Mesmo componente em duas negociações diferentes
														lLoop := .f.
													EndIf
												Else
													aAdd(aComps3,{cnrcalc,GV2->GV2_CDCOMP})
													lLoop := .f.
												EndIf
											
											Else

												For nQ := 1 To Len(aComps2[1,6])
													nPos := aScan(aComps2[1,6,nQ,2],cnrcalc )
													If nPos > 0 //É um cálculo clonado
														cNrOrig := aComps2[1,6,nQ,1]
														Exit
													EndIf
												Next nQ
												
												nPos := aScan(aComps3,{|x|x[1] == cNrOrig})
												If aComps3[nPos,2] == GV2->GV2_CDCOMP // Componente pertence ao original
													Exit
												Else
													nPos := 0
													For nU := 1 To Len(aComps2[1,6,nQ,2])
														nPos := aScan(aComps3,{|x|x[1] == aComps2[1,6,nQ,2,nU]})
														If nPos > 0
															If aComps3[nPos,2] == GV2->GV2_CDCOMP .Or. aComps3[nPos,1] == cnrCalc
																Exit
															Else
																nPos := 0
															EndIf
														EndIf
													Next nU
													If nPos == 0// Não há o componente em clones
														aAdd(aComps3,{cnrcalc,GV2->GV2_CDCOMP})
														lLoop := .f.
													ElseIf aComps3[nPos,2] == GV2->GV2_CDCOMP .And. aComps3[nPos,1] == cnrCalc //Em mais de uma negociação para o mesmo cálculo
														lLoop := .f.
													EndIf
												EndIf
												
											EndIf
										
											Exit
										EndIf
										
									EndIf
									
								Next nZ
							EndIf
							If lLoop
								Loop // Passa para o proximo componente
							EndIf
						
							aAdd(aCompServ,GV2->GV2_CDCOMP)
							if s_SERVTO == "1"
								lServ := .F.
								If Len(aCServ) = 0
									lServ := .T.
								EndIf
								For nZ := 1 to Len(aCServ)

									if aCServ[nz] == GV2->GV2_CDCOMP
										lServ = .T.
										aAdd(aServErro,GV2->GV2_CDCOMP)
									EndIf
								Next nZ

								if lServ == .F.
									Loop
								endif

							EndIf

							AddToLog(STR0353 + aComps[nY,_CDCOMP] + " - " + Posicione("GV2",1,xFilial("GV2")+aComps[nY,_CDCOMP],"GV2_DSCOMP") + CRLF) //"        Calculando componente: "

						EndIf

					endif

					// Quando há faixas para soma, o calculo deve considerar os componentes do tipo frete valor, pedagio e taxas apenas da 1a faixa.
					// Os componentes do tipo frete unidade são considerados de todas as faixas identificadas
					If nX != 1 .And. GV2->GV2_CATVAL != "1"	// Não é primeira Faixa e componente não é frete unidade
						AddToLog(STR0354 + CRLF + CRLF) //"          Categoria diferente de Frete Unidade. Passando ao próximo componente da faixa..."
						Loop // Passa para o proximo componente
					EndIf

					AddToLog(STR0355 + GFEFldInfo("GV2_ATRCAL",GV2->GV2_ATRCAL,2)) //"          Atributo: "
					nValCpn := 0

					// Quando carga fracionada e atributo de calculo da faixa e do componente são igual, assume a quantidade da faixa para cálculo
					If GV9->GV9_TPLOTA == "1" .AND. GV2->GV2_ATRCAL == Posicione("GV9",1,xFilial("GV9")+cCdEmit+cNrTab+cNrNeg,"GV9_ATRFAI")
						If GV2->GV2_ATRCAL == '5 ' .And. GFXCP12117("GV2_UNIT") .And. !Empty(GV2->GV2_UNIT)
							GUY->(dbSetOrder(1) )
							If GUY->(dbSeek(xFilial("GUY") + cCdEmit + cNrTab + cNrNeg + aComps[nY,_CDCOMP]) )

								cIDVLAG := "1"
								If (GV2->GV2_CATVAL == "4") .OR. (GV2->GV2_IDVLRC == "2")
									cIDVLAG := "1"
								Else
									cIDVLAG := GV2->GV2_IDVLAG									
								EndIf
								// Quando for frete viagem com maior tarifa, um romaneio por cálculo e a quantidade de cálculo zerada (nQtCalc),
								// Utiliza o valor da quantidade de cálculo informada
								If GV9->GV9_FREVIA == "1" .AND. GV9->GV9_TIPVAL == "2" .AND. !Empty(aValFV) /*GV9->GV9_QTDCAL == "1" .AND.*/

									nValCpn := GFEQtdeComp( cNrAgru,;			// Agrupador
															cNrCalc,;			// Número do Cálculo
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;	// Classificação de Frete
															GV2->GV2_ATRCAL,;   // AtribCalc
															aValFV[1],;			// Qtde
															aValFV[2],; 	    // PesoReal
															aValFV[3],; 	    // Valor
															aValFV[10],;		// VALLIQ
															aValFV[4],;         // Volume
															aValFV[5],;         // Fator Cub
															aValFV[6],;
															aValFV[7],;
															aValFV[8],;
															IIf(GUY->GUY_FREMIN == "1", GV6->GV6_QTMIN, 0),;
															cIDVLAG,;
															GetTpEntr( cTpLocEntr,cIDVLAG),;
															GFEXFBLOCE( cNrCalc ),;
															lUtlFrMin ,;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
															IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''))
								Else

									nValCpn := GFEQtdeComp(	cNrAgru,;			// Agrupador
															cNrCalc,;			// Número do Cálculo
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;	// Classificação de Frete
															GV2->GV2_ATRCAL,;   // AtribCalc
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;  	// Qtde
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),; 	// PesoReal
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),; 	// Valor
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ"),; // Valor Liquido
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),; // Volume
															GV9->GV9_QTKGM3,;   // Fator Cub
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),; //
															GV7->GV7_UNICAL,;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
															IIf(GUY->GUY_FREMIN == "1", GV6->GV6_QTMIN, 0),;
															cIDVLAG,;
															GetTpEntr( cTpLocEntr,cIDVLAG),;
															GFEXFBLOCE( cNrCalc ),;
															lUtlFrMin ,;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
															IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''))
								EndIf

							EndIf
						Else
							// Quando categoria do componente for Pedagio, utiliza a quantidade total e não a quantidade da faixa
							nValCpn := IF(GV2->GV2_CATVAL == "4",GFEConvUM(GV9->GV9_UNIFAI,GV7->GV7_UNICAL,nQtdePed), aFaixa[nX,3])
							AddToLog(STR0356) //" (Atributo Componente igual Atributo Faixa)"

							If GFXCP2510('GV2_ATRPED')
								If GV2->GV2_CATVAL == "4"
									// Não necessita tratar a regra de GV2_ATRPED == 1 (Maior entre peso bruto/cubado) pois esta fazendo isso na atribuição acima
									If Alltrim(GV2->GV2_ATRPED) == "1"
										nValCpn := If(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB") > GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"))
									ElseIf Alltrim(GV2->GV2_ATRPED) == "2"
										nValCpn := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
										AddToLog(" - Alterado peso considerado - Real: " + cValToChar(nValCpn))
									ElseIf Alltrim(GV2->GV2_ATRPED) == "3"
										nValCpn := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
										AddToLog(" - Alterado peso considerado - Cubado: " + cValToChar(nValCpn))
									EndIf
								EndIf
							EndIf
						EndIf	
					Else
						// Quando carga fechada ou atributos de cálculo da faixa e do componentes são diferentes, é necessário determinar a quantidade para cálculo
						AddToLog(IF(GV9->GV9_TPLOTA == "1", STR0357, "")) //" (Atributo Componente diferente do Atributo Faixa)"

						If AllTrim(GV2->GV2_ATRCAL) != "9"	// Valor do Frete

							GUY->(dbSetOrder(1) )
							If GUY->(dbSeek(xFilial("GUY") + cCdEmit + cNrTab + cNrNeg + aComps[nY,_CDCOMP]) )

								cIDVLAG := "1"
								If (GV2->GV2_CATVAL == "4") .OR. (GV2->GV2_IDVLRC == "2")
									cIDVLAG := "1"
								Else
									cIDVLAG := GV2->GV2_IDVLAG									
								EndIf
								// Quando for frete viagem com maior tarifa, um romaneio por cálculo e a quantidade de cálculo zerada (nQtCalc),
								// Utiliza o valor da quantidade de cálculo informada
								If GV9->GV9_FREVIA == "1" .AND. GV9->GV9_TIPVAL == "2" .AND. !Empty(aValFV) /*GV9->GV9_QTDCAL == "1" .AND.*/

									nValCpn := GFEQtdeComp( cNrAgru,;			// Agrupador
															cNrCalc,;			// Número do Cálculo
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;	// Classificação de Frete
															GV2->GV2_ATRCAL,;   // AtribCalc
															aValFV[1],;			// Qtde
															aValFV[2],; 	    // PesoReal
															aValFV[3],; 	    // Valor
															aValFV[10],;		// VALLIQ
															aValFV[4],;         // Volume
															aValFV[5],;         // Fator Cub
															aValFV[6],;
															aValFV[7],;
															aValFV[8],;
															IIf(GUY->GUY_FREMIN == "1", GV6->GV6_QTMIN, 0),;
															cIDVLAG,;
															GetTpEntr( cTpLocEntr,cIDVLAG),;
															GFEXFBLOCE( cNrCalc ),;
															lUtlFrMin ,;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
															IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''),;
															aComps[nY,_CDCOMP])	// 22 Componente posicionado
								Else
									nValCpn := GFEQtdeComp(	cNrAgru,;			// Agrupador
															cNrCalc,;			// Número do Cálculo
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;	// Classificação de Frete
															GV2->GV2_ATRCAL,;   // AtribCalc
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;  	// Qtde
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),; 	// PesoReal
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),; 	// Valor
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ"),; // Valor
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),; // Volume
															GV9->GV9_QTKGM3,;   // Fator Cub
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),; //
															GV7->GV7_UNICAL,;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
															IIf(GUY->GUY_FREMIN == "1", GV6->GV6_QTMIN, 0),;
															cIDVLAG,;
															GetTpEntr( cTpLocEntr,cIDVLAG),;
															GFEXFBLOCE( cNrCalc ),;
															lUtlFrMin ,;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
															IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''),;
															aComps[nY,_CDCOMP])	// 22 Componente posicionado
								EndIf

							EndIf

						Else
							// O ULTIMO A SER CALCULADO, SOMATORIA DO VALOR TOTAL DO FRETE (TODOS OS COMPONENTES JA CALCULADOS)
							// Gravar o componente no array para calcular posteriormente							
							nPos := aScan(aCompVlFr,{|x| x[1] == aComps[nY,_CDCOMP]})
							If nPos <= 0	// Não grava componentes repetidos
								aAdd(aCompVlFr,aComps[nY])
								AddToLog(STR0358 + CRLF + CRLF) //" - Cálculo postergado!"
							EndIf
							Loop	// Passa para o proximo componente
						EndIf
					EndIf

					If lPEXFB02
						nValCpn := ExecBlock("GFEXFB02",.f.,.f.,{ nValCpn })
					EndIf
					
					AddToLog(STR0198 + cValToChar(nValCpn) + CRLF) //" - Qtde. Cálculo: "

					// Aplica os multiplicadores e adicionais da tabela de vinculo, se houver
					If lVinculo
						//verifica se existe multiplicador e adicional para o componente
						GVB->(dbSetOrder(01))
						If GVB->(dbSeek(xFilial("GVB")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") + GV2->GV2_CDCOMP))
							nMul := GVB->GVB_VLMULT
							nAdc := GVB->GVB_VLADIC
							AddToLog(STR0359 + cValToChar(nMul) + STR0338 + cValToChar(nAdc) + CRLF) //"          Usando valores do componente, multiplicar por "###", adicionar "
						Else
							AddToLog(STR0360 + CRLF) //"          Multiplicador e adicional não encontrados para o componente. Usando valores da tabela."
							nMul := nMulVin
							nAdc := nAdcVin
						EndIf
					EndIf

					// Verifica se a cidade de destino usa taxa suframa
					AddToLog(Space(10) + STR0547 + GFEFldInfo("GV2_TABSUF",GV2->GV2_TABSUF,2) + CRLF) //"Aplicação de Taxa Suframa para o componente: "
					lSuframa := .F.
					IF GV2->GV2_TABSUF != "1" // Não se aplica
						GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
						if GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNrCalc}) 
							cCidDest := GFECidDest({GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"),;
													GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"),;
													GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC"), ;
													GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")})
							lSuframa := (Posicione("GU7",1,xFilial("GU7")+cCidDest,"GU7_SUFRAM") == "1")
						EndIf
					EndIf

					if GV2->GV2_TABSUF == "3" // Tabela Suframa por Faixa
						if lSuframa
							AddToLog(Space(10) + STR0548 + DTOC(dDataBase) + STR0549 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")) + CRLF) //"Suframa baseado na tabela por faixas. Data referencia: "###", Valor Merc. "
							nValor := GFEVlSuframa(dDataBase, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"))
							nQtde  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
						Else
							AddToLog(Space(10) + STR0550 + cCidDest + " - " + Posicione("GU7",1,xFilial("GU7")+cCidDest,"GU7_NMCID") + ")" + CRLF) //"Cidade destino não utiliza Taxa Suframa ("
							nValor := 0
						EndIf
					Else
						If GV2->GV2_TABSUF == "1" /* Não se aplica */ .OR.;
						(GV2->GV2_TABSUF == "2" /* Tarifa Tab. Frete */ .AND. lSuframa)
							// Calculo do valor do componente
							nValor := GFEVlComp(aComps[nY],nValCpn,@nQtde,nMul,nAdc)
							
							If lPEXFB17
								nValor := ExecBlock("GFEXFB17",.f.,.f.,{ nValor, (aComps[nY][1])})
								AddToLog("Valor resultante do cálculo do componente alterado para: "+ cValToChar(nValor) +" pelo PE GFEXFB17"+ CRLF) 
							EndIF
						Else
							AddToLog(Space(10) + STR0550 + cCidDest + " - " + Posicione("GU7",1,xFilial("GU7")+cCidDest,"GU7_NMCID") + ")" + CRLF) //"Cidade destino não utiliza Taxa Suframa ("
							nValor := 0
						EndIF
					EndIf

					if s_SERVTO == "1"
						if lCalcServ .And. GV2->GV2_ATRCAL == "11" // Qtde Serviço
							nValor := nValor * nQtServ
							if nQtServ == 0
								aAdd(aServ2,GV2->GV2_CDCOMP)
								AddToLog("Componente de Frete " + cValToChar(GV2->GV2_CDCOMP) + " utiliza a Quantidade de Serviço informada na Ocorrência, porém, a Quantidade está zerada." + CRLF + CRLF)
							EndIf
						endif
					EndIf

					If (s_SERVTO == "2" .and. lCalcServ)
						If nQtServ > 0 .And. aComps[nY][2] > 0
							nValor := aComps[nY][2] * nQtServ
						EndIf
					EndIf

					// Gravacao do componente na lista de componentes calculados
					nPos := aScan(aCompCalc,{|x| x[1] == aComps[nY,_CDCOMP]})	// Componente já consta na lista?
					If nPos > 0
						AddToLog(STR0361 + cValToChar(nValor) + " (+" + AllTrim(STR(aCompCalc[nPos,_VALOR])) + STR0362 + cValToChar(nQtde) + "(+" + AllTrim(STR(aCompCalc[nPos,_QTDE])) + ")" + CRLF + CRLF) //"          Somando com faixa anterior: Valor: "###"); Qtde.: "
						aCompCalc[nPos,_VALOR] += nValor
						aCompCalc[nPos,_QTDE]  += nQtde
					Else
						// Componente padrao da negociacao
						GUY->(dbSetOrder(01))
						If GUY->(dbSeek(xFilial("GUY")+cCdEmit+cNrTab+cNrNeg+aComps[nY,_CDCOMP]))

							// Verificando se componente é usado para frete garantia
							If GV6->GV6_COMFRG == aComps[nY,1]
								AddToLog(STR0363 + cValToChar(nValor) + STR0364 + cValToChar(nVlFretMin) + ")" + CRLF) //"          Componente é usado para FRETE GARANTIA. Comparando valor ("###") com o frete mínimo atual ("
								If nValor > nVlFretMin
									nVlFretMin := nValor
									aNegMin := {GV6->GV6_CDEMIT,GV6->GV6_NRTAB,GV6->GV6_NRNEG}
									AddToLog(STR0365 + cValToChar(nValor) + STR0366 + CRLF) //"          Assumindo valor do componente ("###") como frete mínimo."
								Else
									AddToLog(STR0367 + cValToChar(nVlFretMin) + ")." + CRLF) //"          Mantendo valor de frete mínimo ("
								EndIf

								/*Identificacao dos elementos no array aCompCalc: 1-Componente, 2-Categoria, 3-Valor, 4-Qtde., 5-Total Frete ,6-Base Imposto ,7-Base Pis/Cof, 8-Frete Min*/
								aAdd(aCompCalc,{aComps[nY,_CDCOMP],GV2->GV2_CATVAL,nValor,nQtde,"2","2","2","2",aComps[nY,12]})
							Else
								/*Identificacao dos elementos no array aCompCalc: 1-Componente, 2-Categoria, 3-Valor, 4-Qtde., 5-Total Frete ,6-Base Imposto ,7-Base Pis/Cof, 8-Frete Min*/
								aAdd(aCompCalc,{aComps[nY,_CDCOMP],GV2->GV2_CATVAL,nValor,nQtde,GUY->GUY_TOTFRE,GUY->GUY_BASIMP,GUY->GUY_BAPICO,GUY->GUY_FREMIN,aComps[nY,12]})
							EndIf
							AddToLog(STR0368 + AllTrim(STR(nValor)) + STR0369 + AllTrim(Str(nQtde)) + STR0370 + GFEFldInfo("GV2_CATVAL",GV2->GV2_CATVAL,2) + CRLF + CRLF) //"          Calculado para esta faixa: Valor: "###"; Qtde.: "###"; Categoria: "
						EndIf
					EndIf
				Else
					AddToLog(CRLF + STR0371 + AllTrim(aComps[nY,_CDCOMP]) + STR0372 + CRLF) //"          ERRO!!! Componente "###" não está cadastrado!!!"
					GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), 14)
					lError := .T.
				EndIf	// Componente existe na GV2?

			Next nY // array de componentes da tarifa + componentes do emitente
		Next nX	// Faixas da tabela de frete

		if lCalcServ

			if (Len(aServErro) < Len(aCServ))

				For nX := 1 to Len(aCServ)
					lServErro := .F.
					For nZ := 1 to Len(aServErro)

						If aCServ[nX] == aServErro[nZ]
							lServErro := .T.
						Endif
					Next nZ
					if !lServErro
						AddToLog(CRLF + "Componente de Serviço " + AllTrim(aCServ[nX]) + " não está cadastrado na tabela de frete" + CRLF)
						lErroServ := .T. // Utilizado para limpar o array dos componentes caso não encontre nenhum de serviço
					EndIf
				Next nX

				If !lSimulFrt .and. nNumRegSTF <= 1
					GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), 22)
					lError := .T.
				EndIf
			EndIf

			If Len(aServ2) != 0
				GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), 23)
				lErroServ := .T.
				lError := .T.
			Endif

			If Len(aCompServ) == 0 .And. aScan(acomps3,{|x|x[1] == cNrCalc}) == 0
				AddToLog(CRLF + "Componente de Serviço não está cadastrado na tabela de frete" + CRLF)
				lErroServ := .T. // Utilizado para limpar o array dos componentes caso não encontre nenhum de serviço
				If !lSimulFrt
					nPos := aScan(aTcfQtd, {|x|x[1] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")})
					aTcfQtd[nPos,3]++
				EndIf
			EndIf
		EndIf

		/************************************************/
		/*****      TAXA DE ENTREGA POR FAIXA       *****/
		/************************************************/

		//Chamado TTB847 - Quando o cálculo é de serviço não calcula taxa de entrega.
		If !lCalcServ
			// Obtem o valor total do frete calculado ate aqui
			nVlFrete := 0
			For nX := 1 to len(aCompCalc)
				IF aCompCalc[nX,_TOTFRE] == "1" // Componente soma no total do frete
					nVlFrete += aCompCalc[nX,_VALOR]
				EndIf
			Next nX
	
			nVlFretTot := nVlFrete
	
			AddToLog(CRLF + STR0379 + CRLF + CRLF) //"      # Calculando Taxa de Entrega por Faixa..."
			nQtEntregas := GFEQtdeEntr(cNrAgru, If(!Empty(cTpLocEntr),'1',''), GFEXFBLOCE(cNrCalc))
			nVlFxEntr   := 0
			nVlFrete    := nVlFretTot
	
			AddToLog(STR0380 + cValToChar(nVlFrete) + CRLF +; //"        Valor de frete: "
			STR0381 + cValToChar(nQtEntregas) + CRLF) //"        Qtde. Entregas: "
			GUZ->(dbSetOrder(01))
			GUZ->(dbSeek(xFilial("GUZ")+cCdEmit+cNrTab+cNrNeg))
			while !GUZ->(Eof()) .AND. GUZ->GUZ_FILIAL == xFilial("GUZ") .AND. GUZ->GUZ_CDEMIT == cCdEmit .AND. GUZ->GUZ_NRTAB == cNrTab .AND. GUZ->GUZ_NRNEG == cNrNeg
	
				If nQtEntregas <= GUZ->GUZ_VLFXFI
					AddToLog(STR0382 + cValToChar(GUZ->GUZ_VLFXFI) + STR0383 + cValToChar(GUZ->GUZ_PCENTR) + STR0384 + cValToChar(GUZ->GUZ_VLENTR) + CRLF) //"        Até "###" entregas -> Percentual: "###"; Vl.Adicional: "
					nVlFxEntr := (nVlFrete * GUZ->GUZ_PCENTR / 100) + GUZ->GUZ_VLENTR
					AddToLog(STR0385 + cValToChar(nVlFxEntr) + " -> (" + cValToChar(nVlFrete) + " x " + cValToChar(GUZ->GUZ_PCENTR) + " / 100) + " + cValToChar(GUZ->GUZ_VLENTR) + CRLF) //"        Valor Taxa = "
					// Truncar ou Arredondar
					nVlFxEntr := GFETratDec(nVlFxEntr,8)
					Exit
				EndIf
	
				GUZ->(dbSkip())
			EndDo
	
			If nVlFxEntr > 0
	
				nVlFretTot += nVlFxEntr
	
				// Adiciona o componente da taxa de entrega por faixa na lista de componentes calculados
				GUY->(dbSetOrder(01))
				If GUY->(dbSeek(xFilial("GUY") + cCdEmit + cNrTab + cNrNeg + GV9->GV9_COMFXE))
	
					AddToLog(STR0386 + GV9->GV9_COMFXE + CRLF + CRLF) //"        Gravando valor da taxa no componente "
	
					/*Identificacao dos elementos no array aCompCalc: 1-Componente, 2-Categoria, 3-Valor, 4-Qtde., 5-Total Frete ,6-Base Imposto ,7-Base Pis/Cof, 8-Frete Min*/
					aAdd(aCompCalc,{GV9->GV9_COMFXE,Posicione("GV2",1,xFilial("GV2")+GV9->GV9_COMFXE,"GV2_CATVAL"),nVlFxEntr,nQtEntregas,GUY->GUY_TOTFRE,GUY->GUY_BASIMP,GUY->GUY_BAPICO,GUY->GUY_FREMIN,"0"})
	
				Else
					AddToLog(STR0387 + IF(nVlFxEntr > 0,STR0388,"") + CRLF + CRLF) //"        Componente para Taxa de Entrega por Faixa nao foi informado ou não consta dentre os componentes da negociação!"###" Valor da taxa não será gravado!"
				EndIf
			Else
				AddToLog(STR0389 + CRLF + CRLF) //"        Taxa de Entrega por Faixa não está configurada para esta negociação OU valor calculado é igual a zero!"
			EndIf

			AddToLog(STR0390 + cValToChar(nVlFretTot) + CRLF + CRLF) //"    -> Valor de Frete para esta tarifa: "
		EndIf

		/************************************************/
		/*****      FRETE SOBRE O VALOR DO FRETE    *****/
		/************************************************/
		AddToLog(STR0373 + CRLF) //"      # Calculando componentes cujo atributo de cálculo é Valor do Frete..."

		// Obtem o valor total do frete calculado ate aqui
		nVlFrete := 0
		For nX := 1 to len(aCompCalc)
			IF aCompCalc[nX,_TOTFRE] == "1" // Componente soma no total do frete
				nVlFrete += aCompCalc[nX,_VALOR]
			EndIf
		Next nX

		// Ponto de Entrada
		If lPEXFB20 
			nVlPe20  := ExecBlock("GFEXFB20",.f.,.f.,{ nVlFrete, aCompCalc })
			IF ValType(nVlPe20) == "N" .And. !Empty(nVlPe20)
				nVlFrete := nVlPe20
			EndIf		
		EndIf			

		nVlFretTot := nVlFrete

		If Empty(aCompVlFr)
			AddToLog(CRLF + STR0374 + CRLF) //"        Não há componentes para cálculo sobre o valor do frete."
		EndIf

		For nX := 1 to len(aCompVlFr)

			AddToLog(STR0353 + aCompVlFr[nX,_CDCOMP] + " - " + Posicione("GV2",1,xFilial("GV2")+aCompVlFr[nX,_CDCOMP],"GV2_DSCOMP") + CRLF) //"        Calculando componente: "
			AddToLog(STR0375 + cValToChar(nVlFrete) + CRLF) //"          Valor de frete atual: "

			// Aplica os multiplicadores e adicionais da tabela de vinculo, se houver
			If lVinculo
				//verifica se existe multiplicador e adicional para o componente
				GVB->(dbSetOrder(01))
				If GVB->(dbSeek(xFilial("GVB")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")+GV2->GV2_CDCOMP))
					nMul := GVB->GVB_VLMULT
					nAdc := GVB->GVB_VLADIC
					AddToLog(STR0376 + cValToChar(nMul) + STR0338 + cValToChar(nAdc) + CRLF) //"        Usando valores do componente, multiplicar por "###", adicionar "
				Else
					AddToLog(STR0377 + CRLF) //"        Multiplicador e adicional não encontrados para o componente. Usando valores da tabela."
					nMul := nMulVin
					nAdc := nAdcVin
				EndIf
			EndIf

			cCatVal := Posicione("GV2", 1, xFilial("GV2") + aCompVlFr[nX,_CDCOMP], "GV2_CATVAL")
			nValor  := GFEVlComp(aCompVlFr[nX], nVlFrete, 0, nMul, nAdc)

			// Adicionar o valor de cada componente ao valor final de frete
			nVlFretTot += nValor

			// Componente padrao da negociacao
			GUY->(dbSetOrder(01))
			If GUY->(dbSeek(xFilial("GUY")+cCdEmit+cNrTab+cNrNeg+aCompVlFr[nX,_CDCOMP]))

				// Adiciona o componente na lista de componentes calculados
				aAdd(aCompCalc,{aCompVlFr[nX,_CDCOMP],cCatVal,nValor,/*nVlFrete*/ 0 ,GUY->GUY_TOTFRE,GUY->GUY_BASIMP,GUY->GUY_BAPICO,GUY->GUY_FREMIN, "0"})

				AddToLog(STR0378 + AllTrim(STR(nValor)) + STR0369 + AllTrim(Str(nVlFrete)) + STR0370 + GFEFldInfo("GV2_CATVAL",cCatVal,2) + CRLF) //"        Componente calculado. Valor: "###"; Qtde.: "###"; Categoria: "

			EndIf

		Next nX

		GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
		//limpando o Array
		aFaixa := {}
		aComps    := {}  // Array com os componentes a serem calculados, combinando os componentes da tarifa com os componentes por emitente
		aCompVlFr := {}
	EndDo
	If !lSimulFrt
		If lTabTemp
			aStru := (cTRBTCF)->(dbStruct())
		EndIf
		For nX := 1 To Len(aComTarifa) // Com tarifa para todas as rotas, deve adicionar num Array para incluir a tcf no fim do cálculo
			GFEXFB_HGOTO(lTabTemp, cTRBTCF, 5, aComTarifa[nX,1])
			If aComTarifa[nX,5] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") .And. aComTarifa[nX,6] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA")
				Loop
			EndIf
			//validar duplicado GWG
			If aScan(aTcfTodas,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") .And.;
								    x[2] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") .And.;
								    x[3] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") .And.;
								    x[7] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") .And.;
								    x[8] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") .And.;
								    x[9] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") .And.;
								    x[10] == aComTarifa[nX,5] .And.;
								    x[12] == aComTarifa[nX,6] }) == 0
				If lTabTemp
					aLinha := {{}}
					For nY := 1 To Len(aStru)
						aAdd(aLinha[1],(cTRBTCF)->(Fieldget(nY)))
					Next nY
				Else
					aLinha := {aClone(aTRBTCF1[idpTCF])}
				EndIf
				idpTCF := 1
				GFEXFB_5CMP(.F., , @aLinha, 5,"CDTRP",aComTarifa[nX,2])
				GFEXFB_5CMP(.F., , @aLinha, 5,"NRTAB",aComTarifa[nX,3])
				GFEXFB_5CMP(.F., , @aLinha, 5,"NRNEG",aComTarifa[nX,4])
				GFEXFB_5CMP(.F., , @aLinha, 5,"CDFXTV",aComTarifa[nX,5])
		        If aComTarifa[nX,5] != GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")
					GFEXFB_5CMP(.F., , @aLinha, 5,"CDTPVC","")
				EndIf
				GFEXFB_5CMP(.F., , @aLinha, 5,"NRROTA",aComTarifa[nX,6])
				aAdd(aTcfTodas,aClone(aLinha[1]))
				aAdd(aTcfTodas[Len(aTcfTodas)],aComTarifa[nX,7])
				aAdd(aTcfTodas[Len(aTcfTodas)],aComTarifa[nX,8])
				
			EndIf
		Next nX
	EndIf

	if lCalcServ .and. lErroServ
		aCompCalc := {}
	Endif

	GFEXFB_ARESTAREA(lTabTemp,aAreaTRBTCF,5) //RestArea(aAreaTRBTCF)

Return aCompCalc

/*----------------------------------------------------------------------------
{Protheus.doc} GFEVlComp
Retorna o valor do componente
Uso: GFEVlComp

@param  aDadosComp     Array com os dados para cálculo do componente.
[ 1] Código do componente
[ 2] Valor Fixo Normal
[ 3] Percentual Normal
[ 4] Valor Unitário Normal
[ 5] Valor da Fração Normal
[ 6] Valor Mínimo Normal
[ 7] Valor Limite
[ 8] Valor Fixo Extra
[ 9] Percentual Extra
[10] Valor Unitário Extra
[11] Forma de cálculo diferença
@param  nValCpn        Valor base para cálculo do componente (Ex. Peso da mercadoria, valor da mercadoria, etc.).
@param  nQtd           Acumulador do valor base para cálculo do componente.
@param  [nMulti]       Opcional - Multiplicador a ser aplicado sobre o valor do componente. Default = 1
@param  [nAdic]        Opcional - Adicional a ser somado ao valor do componente. Default = 0

@author Luciano de Araujo
@since 09/04/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEVlComp(aDadosComp, nValCpn, nQtd, nMulti, nAdic)

	Local nValor     := 0
	Local nFracExced := 0
	Local cAux
	Local nValExt, nTExtra
	Local cGV2ATRCAL := AllTrim(Posicione("GV2", 1, xFilial("GV2") + aDadosComp[1], "GV2_ATRCAL"))
	Local lPEXFB18	 := ExistBlock("GFEXFB18") 
	Local lFracExced := GFXCP2510("GV1_FRACEX")

	Default nMulti := 1
	Default nAdic  := 0

	// Caso o atributo de cálculo do compoenente é de '2'(Valor Mercadoria) ou '9'(Valor Frete), zera os outros valores.
	If (cGV2ATRCAL $ "29" .OR. cGV2ATRCAL == "12")
		aDadosComp[2]  := 0
		aDadosComp[4]  := 0
		aDadosComp[5]  := 0
		//aDadosComp[6]  := 0 //Não zerar o valor mínimo
		aDadosComp[8]  := 0
		aDadosComp[10] := 0
	EndIf

	//Valor Fixo Tarifa Normal
	If !Empty(aDadosComp[2])
		nValor += aDadosComp[2]
		AddToLog(STR0391 + cValToChar(aDadosComp[2]) + CRLF) //"          + Valor Fixo Tarifa Normal: "

		If AllTrim(Posicione("GV2",1,xFilial("GV2")+aDadosComp[1],"GV2_ATRCAL")) $ "8"
			If nValCpn > aDadosComp[7] .AND. aDadosComp[7] > 0
				nQtd += aDadosComp[7]
			Else
				nQtd += nValCpn
			EndIf
			Return nValor
		EndIf
	Else
		AddToLog(STR0392 + CRLF) //"          + Valor Fixo Tarifa Normal: 0"
	EndIf

	//Valor Unitário Tarifa Normal
	If !Empty(aDadosComp[5])
		cAux := cValToChar(nValCpn/aDadosComp[5])
		nValor += If(At('.',cAux) > 0, Val(SubStr(cAux,1,At('.',cAux)))+1 , Val(cAux) ) * aDadosComp[4]
		AddToLog(STR0395 + cAux + ; 
				 STR0396 + cValToChar(aDadosComp[5]) + "): " +; //"          + Valor Unitario Tarifa Normal ("###" fração(ões) de "
				 cValToChar(If(At('.',cAux) > 0, Val(SubStr(cAux,1,At('.',cAux)))+1,Val(cAux))) + " x " + cValToChar(aDadosComp[4]) +;
				 " = " + cValToChar(If(At('.',cAux) > 0, Val(SubStr(cAux,1,At('.',cAux)))+1 , Val(cAux) ) * aDadosComp[4]) + CRLF)
		nQtde := nValCpn := val(cAux)    //Atualização da Quantidade;	
	Else
		// Se o valor do componente exceder o limite, calcula até o limite
		If aDadosComp[7] > 0
			nValor += (MIN(nValCpn, aDadosComp[7]) * aDadosComp[4])
		Else
			nValor += nValCpn * aDadosComp[4]
		EndIf

		AddToLog(STR0397 + cValToChar(nValCpn) + " (desconsiderando o excedente ao limite) x " + cValToChar(aDadosComp[4]) + " = " + cValToChar(nValor) + CRLF) //"          + Valor Unitario Tarifa Normal: "
	EndIf
	
	//Verifica se ultrapassou o limite estabelecido
	nValExt := 0
	If nValCpn > aDadosComp[7] .AND. aDadosComp[7] > 0
		nValExt := nValCpn - aDadosComp[7]
		nValCpn := aDadosComp[7]
		AddToLog(STR0402 + cValToChar(nValCpn) + STR0403 + cValToChar(aDadosComp[7]) + STR0404 + cValToChar(nValExt) + CRLF) //"            Qtde. calc.: "###"; Limite: "###"; Excedente: "
	Else
		AddToLog(STR0402 + cValToChar(nValCpn) + STR0403 + cValToChar(aDadosComp[7]) + STR0405 + CRLF) //"            Qtde. calc.: "###"; Limite: "###"; Excedente: 0"
	EndIf

	//Percentual Tarifa Normal: Apenas componentes com atributo de cálculo 2 (Valor Merc.) ou 9 (Valor Frete) calculam sobre o percentual
	If (cGV2ATRCAL $ "29" .OR. cGV2ATRCAL == '12')
		nValor += (nValCpn*(aDadosComp[3]/100))
		AddToLog(STR0393 + cValToChar(nValCpn) + " x " + cValToChar(aDadosComp[3]/100) + " = " + cValToChar((nValCpn*(aDadosComp[3]/100))) + CRLF) //"          + Percentual Tarifa Normal: "
	Else
		AddToLog(STR0394 + CRLF) //"          + Percentual Tarifa Normal: 0"
	EndIf	

	//Valor Minimo
	If nValor < aDadosComp[6]
		AddToLog(STR0398 + cValToChar(nValor) + STR0399 + cValToChar(aDadosComp[6]) + STR0400 + CRLF) //"            Valor calc.: "###" Minimo: "###" -> Valor mínimo assumido"
		nValor := aDadosComp[6]
	Else
		AddToLog(STR0398 + cValToChar(nValor) + STR0399 + cValToChar(aDadosComp[6]) + STR0401 + CRLF) //"            Valor calc.: "###" Minimo: "###" -> Valor calculado mantido"
	EndIf
	
	nQtd += nValCpn

	If nValExt > 0

		nTExtra := 0

		AddToLog(STR0406 + CRLF) //"          Tarifa extra:"

		//Valor fixo para tarifa extra
		If aDadosComp[8] > 0
			nTExtra := aDadosComp[8]
			AddToLog(STR0407 + cValToChar(nTExtra) + CRLF) //"          Valor fixo tarifa extra: "
		EndIf

		//Calcula tarifa extra sobre a diferenca

		If aDadosComp[11] == "1"

			AddToLog(STR0408 + CRLF) //"          Tarifa extra sobre a diferença:"

			If aDadosComp[9] != 0	// percentual sobre a diferença
				nTExtra += ((nValExt)*(aDadosComp[9]/100))
				AddToLog(STR0409 + cValToChar(nValExt) + " x " + cValToChar(aDadosComp[9]/100) + " = " + cValToChar(((nValExt)*(aDadosComp[9]/100))) + CRLF) //"            Percentual: "
			EndIf

			If aDadosComp[10] > 0 // valor unitário
				If lFracExced .And. aDadosComp[13] > 0
					// Calcula quantas frações existem no peso excedente e arredonda para cima
					nFracExced := Ceiling(nValExt / aDadosComp[13])

					// Calcula o valor total do excedente
					nTExtra := nFracExced * aDadosComp[10]
					AddToLog(STR0410 + cValToChar(nValExt) + " x " + cValToChar(aDadosComp[10]) + " = " + cValToChar(nTExtra) + " [" + cValToChar(nFracExced) + " fração(ões)]" + CRLF) //"            Vl. Unitário:"
				Else
					nTExtra += nValExt * aDadosComp[10]
					AddToLog(STR0410 + cValToChar(nValExt) + " x " + cValToChar(aDadosComp[10]) + " = " + cValToChar(((nValExt)*(aDadosComp[10]))) + CRLF) //"            Vl. Unitário:"
				EndIf
			EndIf

			AddToLog(STR0413 + cValToChar(nTExtra) + CRLF) //"          + Tarifa Extra: "
			nValor += nTExtra

			//Calcula tarifa extra sobre o total
		ElseIf aDadosComp[11] == "2"

			AddToLog(STR0411 + CRLF) //"          Tarifa extra sobre o total:"

			If aDadosComp[9] != 0	// percentual sobre o total
				nTExtra += ((nValCpn+nValExt)*(aDadosComp[9]/100))
				AddToLog(STR0409 + cValToChar((nValCpn+nValExt)) + " x " + cValToChar(aDadosComp[9]/100) + " = " + cValToChar((((nValCpn+nValExt))*(aDadosComp[9]/100))) + CRLF) //"            Percentual: "
			EndIf
			If aDadosComp[10] > 0 // valor unitário
				If lFracExced .And. aDadosComp[13] > 0
					// Calcula quantas frações existem no peso excedente e arredonda para cima
					nFracExced := Ceiling((nValCpn+nValExt) / aDadosComp[13])

					// Calcula o valor total do excedente
					nTExtra := nFracExced * aDadosComp[10]
					AddToLog(STR0410 + cValToChar(nValExt) + " x " + cValToChar(aDadosComp[10]) + " = " + cValToChar(nTExtra) + " [" + cValToChar(nFracExced) + " fração(ões)]" + CRLF) //"            Vl. Unitário:"
				Else
					nTExtra += ((nValCpn+nValExt)*aDadosComp[10])
					AddToLog(STR0412 + cValToChar((nValCpn+nValExt)) + " x " + cValToChar(aDadosComp[10]) + " = " + cValToChar((((nValCpn+nValExt))*(aDadosComp[10]))) + CRLF) //"            Vl. Unitário: "
				EndIf
			EndIf

			AddToLog(STR0413 + cValToChar(nTExtra) + CRLF) //"          + Tarifa Extra: "
			nValor := nTExtra
		EndIf

		AddToLog("          Valor com a tarifa extra calculada pelo excedente: " + cValToChar(nTExtra) + CRLF)

	Else
		AddToLog(STR0414 + CRLF) //"          + Tarifa extra: 0"
	EndIf

	//Aplicando multiplicador e adicional
	AddToLog(STR0415 + CRLF) //"          Aplicando multiplicador e adicional..."
	AddToLog("          " + cValToChar(nValor) + " x " + cValToChar(nMulti))
	nValor *= nMulti
	AddToLog(" = " + cValToChar(nValor) + CRLF + "          " + cValToChar(nValor) + " + " + cValToChar(nAdic))
	nValor += nAdic
	AddToLog(" = " + cValToChar(nValor) + CRLF)

	// trunca ou arredonda
	nValor := GFETratDec(nValor,10)

	AddToLog(STR0416 + cValToChar(nValor) + CRLF) //"          = Valor do componente: "
	
	If lPEXFB18
		nValor := ExecBlock("GFEXFB18",.f.,.f.,{ (nValor), (aDadosComp[1])})
		AddToLog("Valor do componente alterado para: "+ cValToChar(nValor) +" pelo PE GFEXFB18"+ CRLF) 
	EndIF

Return nValor

/*----------------------------------------------------------------------------
Retorna a quantidade de entregas, verificando os grupos de entrega criados
para o agrupador informado.
----------------------------------------------------------------------------*/
Function GFEQtdeEntr(cAgrupador, cTipo, cNrLocEnt)

	Local nQtdeEntr := 0
	Local cGrupo    := ""
	Local aAreaGRU  := GFEXFB_9GETAREA(.F.,, 4)
	Local aAreaEnt  := GFEXFB_9GETAREA(lTabTemp, cTRBENT, 12) 
	If Empty(cTipo)
		GFEXFB_BORDER(.F.,,01,4)
		If GFEXFB_CSEEK(.F.,, @aTRBGRB1, 4,{cAgrupador})
			While  !GFEXFB_3EOF(.F.,, @aTRBGRB1, 4) .And. ;
					GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU") == cAgrupador
				If cGrupo != GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRGRUP")
					nQtdeEntr++
					cGrupo := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRGRUP")
				EndIf
				GFEXFB_8SKIP(.F.,, 4) 
			EndDo
		EndIf
	Else
		If cTipo == '1' // Quantidade de entregas para componente
			GFEXFB_BORDER(lTabTemp,cTRBENT,01,12)    
			If GFEXFB_CSEEK(lTabTemp, cTRBENT, @aTRBENT1, 12,{cNrLocEnt})
				cNrLocEnt := GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDTRP")
				GFEXFB_BORDER(lTabTemp,cTRBENT,02,12)    
				GFEXFB_CSEEK(lTabTemp, cTRBENT, @aTRBENT2, 12,{cNrLocEnt})
				While !GFEXFB_3EOF(lTabTemp, cTRBENT, @aTRBENT2, 12) .And. ;
					GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT2, 12,"CDTRP") == cNrLocEnt
					nQtdeEntr++
					GFEXFB_8SKIP(lTabTemp, cTRBENT, 12) 
				EndDo
			EndIf
		ElseIf cTipo == '2'
			nQtdeEntr := 1		
		EndIf
	EndIf
	GFEXFB_ARESTAREA(.F.,aAreaGRU,4) //RestArea(aAreaGRU)
	GFEXFB_ARESTAREA(lTabTemp,aAreaEnt,12) //RestArea(aAreaEnt)

Return nQtdeEntr

/*----------------------------------------------------------------------------
Simula o valor de frete das tabelas encontradas
----------------------------------------------------------------------------*/
Function GFESimulFret()

	Local aComps, nX, nVlFrete, cTxtLogAux
	Local cCdClfrete
	Local cTpOper
	AddToLog(CRLF + STR0417 + CRLF + CRLF) //"      # Simulando valor de frete para as tabelas encontradas..."

	GFEXFB_BORDER(lTabTemp,cTRBSTF,01,2) 
	GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
	while !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 

		if !lTabTemp
			If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ERRO") == "1"
				GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
				Loop
			EndIf
		EndIf

		AddToLog(STR0418 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN") + ;
				 STR0177 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") + ;
				 STR0178 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")  + ;
				 STR0092 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV") + ;
				 STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA") + "), ") //"        Tarifa (Transp. "###"; Tab. "###"; Neg. "###"; Faixa "###"; Rota "
		AddToLog(STR0131 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDCLFR") + ;
				 STR0106 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPOP") + " -> ") //"Class. Frete "###", Tipo Oper. "

		// Salva o log até este ponto
		cTxtLogAux := cTxtLog

		If Empty(cCdClfrete :=GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDCLFR"))
			cCdClfrete := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
		EndIf
		If Empty(cTpOper:=GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPOP"))
			cTpOper := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
		EndIf
		/*Identificacao dos elementos no array: 1-Componente, 2-Categoria, 3-Valor, 4-Qtde., 5-Total Frete ,6-Base Imposto ,7-Base Pis/Cof, 8-Frete Min*/
		aComps := GFECalcComp(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRCALC"), ;
							  cCdClfrete,;
							  cTpOper,;
							  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP"), ;
							  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN"), ;
							  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),  ;
							  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV"), ;
							  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA"), ;
							  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPVC"), ;
							  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTFAIXA"),,,,.T.)

		// Sobrepõe o texto gerado pela função GFECalcComp
		cTxtLog := cTxtLogAux

		nVlFrete := 0
		For nX := 1 to len(aComps)
			IF aComps[nX,_TOTFRE] == "1"	// Componente soma no total do frete
				nvlFrete += aComps[nX,_VALOR]	// Valor do componente
			EndIf
		Next nX

		if lCalcServ .and. len(aComps) == 0 
			If IsInCallStack("GFEA032CA")
				if lTabTemp
					RecLock(cTRBSTF,.F.)
					(cTRBSTF)->(dbdelete())
					(cTRBSTF)->(MsUnLock())
				Else
					GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ERRO","1")
				EndIf
	
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
		Else
			AddToLog(STR0419 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")) + ;
					 STR0420 + cValToChar(nVlFrete) + CRLF) //"Prazo(h) "###", Valor Frete "

			GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLFRT",nVlFrete)
			GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
		EndIf

	EndDo
	
	If !lTabTemp
		aTRBSTF3 := aClone(aTRBSTF1)
		IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
		aTRBSTF1 := {}
		For nX:= 1 to Len(aTRBSTF3)
			If aTRBSTF3[nx,33] == '0'
				AADD(aTRBSTF1, {aTRBSTF3[nx,01], aTRBSTF3[nx,02], aTRBSTF3[nx,03], aTRBSTF3[nx,04], aTRBSTF3[nx,05], aTRBSTF3[nx,06], aTRBSTF3[nx,07],; 
								aTRBSTF3[nx,08], aTRBSTF3[nx,09], aTRBSTF3[nx,10], aTRBSTF3[nx,11], aTRBSTF3[nx,12], aTRBSTF3[nx,13], aTRBSTF3[nx,14],;
								aTRBSTF3[nx,15], aTRBSTF3[nx,16], aTRBSTF3[nx,17], aTRBSTF3[nx,18], aTRBSTF3[nx,19], aTRBSTF3[nx,20], aTRBSTF3[nx,21],;
								aTRBSTF3[nx,22], aTRBSTF3[nx,23], aTRBSTF3[nx,24], aTRBSTF3[nx,25], aTRBSTF3[nx,26], aTRBSTF3[nx,27], aTRBSTF3[nx,28],;
								aTRBSTF3[nx,29], aTRBSTF3[nx,30], aTRBSTF3[nx,31], aTRBSTF3[nx,32], aTRBSTF3[nx,33], aTRBSTF3[nx,34]})
			EndIf
		next
		aSort(aTRBSTF1  ,,,{|x,y| x[01]+x[04]+x[05]+x[11]      < y[01]+y[04]+y[05]+y[11]})
		aTRBSTF3 := aClone(aTRBSTF1)
		aSort(aTRBSTF3  ,,,{|x,y| x[18]+x[19]+x[05]+x[11]      < y[18]+y[19]+y[05]+y[11]})
	EndIf

Return

/*----------------------------------------------------------------------------
Posiciona na rota com menor valor de frete
----------------------------------------------------------------------------*/
Function GFEXFBETVL()

	Local aComps, nX, nVlFrete, nVlFreteMin, nRecno, cTxtLogAux
	Local cCdClfrete
	Local cTpOper
	Local aRet := {}

	nVlFreteMin := 999999999

	AddToLog(CRLF + STR0421 + CRLF + CRLF) //"      # Selecionando tabelas de frete com base no menor valor de frete..."

	GFEXFB_BORDER(lTabTemp,cTRBSTF,01,2) 
	GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
	
	// Início Ponto de Entrada Usina Colombo - TUHOTD		    	
	If ExistBlock("GFEXFB05")  
	   	aRet := {}
	   	aRet := ExecBlock("GFEXFB05",.f.,.f.,{ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROM"), lTabTemp, cTRBSTF, @aTRBSTF1})
	    AddToLog(aRet[2] + CRLF)
	    if aRet[1] == .T.
	    	Return .T. 
	    endif
	EndIf      	
	// Fim Ponto de Entrada Usina Colombo
	while !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 

		// Salva o log até este ponto
		cTxtLogAux := cTxtLog

		If Empty(cCdClfrete :=GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDCLFR"))
			cCdClfrete := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
		EndIf
		If Empty(cTpOper:=GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPOP"))
			cTpOper := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
		EndIf
		// Calcula o valor de frete para os componentes da rota
		aComps := GFECalcComp(	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRCALC"), ;
								cCdClfrete, ;
								cTpOper, ; 
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP"), ;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"), ;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"), ;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV"), ;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA"), ;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPVC"), ;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTFAIXA"),,,,.T.)

		// Sobrepõe o texto de log gerado pela função GFECalcComp
		cTxtLog := cTxtLogAux

		// Obtem o frete total da rota, somando os componentes
		nVlFrete := 0
		For nX := 1 to len(aComps)
			/*Posicoes no array aComps: 1-Componente,2-Categoria,3-Valor,4-Qtde.,5-Total Frete,6-Base Imposto,7-Base Pis/Cof,8-Frete Min*/
			IF aComps[nX,_TOTFRE] == "1"
				nvlFrete += aComps[nX,_VALOR]
			EndIf
		Next nX

		// Para cálculo de serviço ignora negociações que não possuam componentes de serviço
		If lCalcServ .and. len(aComps) == 0
			if lTabTemp
				RecLock(cTRBSTF,.F.)
				(cTRBSTF)->(dbdelete())
				(cTRBSTF)->(MsUnLock())
			Else
				GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ERRO","1")
			EndIf

		Else

			// Grava o valor na rota
			GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLFRT",nVlFrete)

			AddToLog(STR0418 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN") + ;
					 STR0177 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") + ;
					 STR0178 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")  + ;
					 STR0092 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV") + ;
					 STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA") + ") -> ") //"        Tarifa (Transp. "###"; Tab. "###"; Neg. "###"; Faixa "###"; Rota "
			AddToLog(STR0422 + cValToChar(nVlFrete) + CRLF) //"Valor Frete "

			// Identifica a rota com o menor valor
			If nVlFrete < nVlFreteMin
				nVlFreteMin := nVlFrete
				nRecno := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2) 
			EndIf

		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 

	EndDo

	// Seleciona a rota com menor valor
	If !empty(nRecno)
		GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, nRecno) 
	Endif
Return

/*----------------------------------------------------------------------------
Posiciona na rota com menor prazo de entrega
----------------------------------------------------------------------------*/
Function GFEXFBETPE()

	Local nPrzEntMin
	Local nRecno
	Local cContPz      //Dias úteis ou corridos | Anterior
	Local cContPzCor   //Dias úteis ou corridos | Corrente no cursor
	Local cConsPz		 //0=Tabela Prazos 1=Tarifas 2=Nao Calcula
	Local nRetPrzCorr
	AddToLog(CRLF + STR0423 + CRLF + CRLF) //"      # Selecionando tabelas de frete com base no menor prazo de entrega..."

	GFEXFB_BORDER(lTabTemp,cTRBSTF,01,2) 
	GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2)

	nPrzEntMin := GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")
	nRecno     := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2)
	cContPz    := Posicione("GV6",1,xFilial("GV6")+;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")+;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")+;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")+;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV")+;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA");
									,"GV6->GV6_CONTPZ")
	AddToLog(STR0418 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN") + STR0177 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") + STR0178 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG") + STR0092 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV") + STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA") + ") -> ") //"        Tarifa (Transp. "###"; Tab. "###"; Neg. "###"; Faixa "###"; Rota "
	AddToLog(STR0419 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")) + CRLF) //"Prazo(h) "
	
	GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 

	While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
		cTpPraz    := Posicione("GV6",1,xFilial("GV6")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA");
								,"GV6->GV6_TPPRAZ") //1=dias; 2=Horas
		cConsPz    := Posicione("GV6",1,xFilial("GV6")+;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")+;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")+;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")+;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV")+;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA");
										,"GV6->GV6_CONSPZ")
		cContPzCor := GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CONTPZ")
		If cConsPz == "0" //Tabela de prazos
			//Tarifas: Contador de prazo:
			//1 - Dias Corridos
			//2 - Dias Uteis
			//Tabela de prazo: Contador de prazo:
			//0 - Dias Uteis
			//1 - Dias Corridos
			//2 - Horas
			//"Converte":
			If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CONTPZ") == "0"
				cContPzCor = "2"
			ElseIf GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CONTPZ") == "1"
				cContPzCor = "1"
			ElseIf GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CONTPZ") == "2"
				cTpPraz = "2"
			EndIf
		EndIf

		If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO") != Nil //No caso de estar configurado para buscar o prazo na tabela de prazos, mas não existir cadastro na mesma
			If (cContPzCor == "1" .AND. cContPz == "1" ) .Or. (cContPzCor == "2" .AND. cContPz == "2" ) .Or. cTpPraz == "2"
				If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO") < nPrzEntMin
					nPrzEntMin := GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")
					cContPz    := cContPzCor
					nRecno     := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2)
				EndIf
			Else
				If cContPzCor == "1" .AND. cContPz == "2"
					nRetPrzCorr := GFEPrzCorr(nPrzEntMin)

					If !Empty(nRetPrzCorr)
						If nRetPrzCorr > GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")
							nPrzEntMin := GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")
							cContPz    := cContPzCor
							nRecno     := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2)
						EndIf
					EndIf

				ElseIf cContPzCor == "2" .AND. cContPz == "1"
					nRetPrzCorr := GFEPrzCorr(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO"))

					If !Empty(nRetPrzCorr)
						If nRetPrzCorr < nPrzEntMin
							nPrzEntMin := GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")
							cContPz    := cContPzCor
							nRecno     := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		AddToLog(STR0418 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN") + STR0177 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") + STR0178 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG") + STR0092 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV") + STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA") + ") -> ") //"        Tarifa (Transp. "###"; Tab. "###"; Neg. "###"; Faixa "###"; Rota "
		AddToLog(STR0419 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")) + CRLF) //"Prazo(h) "

		GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
	EndDo

	// Seleciona a rota com menor valor
	GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, nRecno)

Return

/*----------------------------------------------------------------------------
Retorna informações de vinculo da tabela de frete
Dados retornados pela função no array aInfoTab
1-Tabela é de vinculo,
2-Transportador Tabela Base,
3-Nr. Tabela Base,
4-Multip. Tabela Vinculo,
5-Adic. Tabela Vinculo
----------------------------------------------------------------------------*/
Function GFEInfoTab(cCdTrp, cNrTab)

	Local aInfoTab := {.F.,cCdTrp,cNrTab,1,0}
	Local aAreaGVA := GVA->(getArea())

	//Posiciona na tabela de frete a ser utilizada
	GVA->(dbSetOrder(01))
	GVA->(dbSeek(xFilial("GVA")+cCdTrp+cNrTab))
	If (GVA->GVA_TPTAB == "2") //Tabela de Vinculo
		aInfoTab[1] := .T.
		aInfoTab[2] := GVA->GVA_EMIVIN
		ainfoTab[3] := GVA->GVA_TABVIN
		aInfoTab[4] := GVA->GVA_VLMULT
		aInfoTab[5] := GVA->GVA_VLADIC
	EndIf

	RestArea(aAreaGVA)

Return aInfoTab

/*----------------------------------------------------------------------------
Retorna informações sobre um campo do dicionario que tenha lista de opcoes
iInfoType: 1-Codigo, 2-Descricao
----------------------------------------------------------------------------*/
Function GFEFldInfo(cNmFld,cValue,iInfoType)
	Local aAux
	Local aAux2
	Local nX
	If iInfoType <> 1 .AND. iInfoType <> 2
		Return ""
	EndIf

	If Empty(cValue)
		cValue := "0"
	Endif

	aAux := StrTokArr(Posicione("SX3",2,cNmFld,"X3_CBOX"),';')
	For nX := 1 To Len(aAux)
		aAux2 := StrTokArr(aAux[nX],"=")
		If AllTrim(aAux2[1]) == AllTrim(cValue)
			Return aAux2[iInfoType]
		EndIf
	Next nX

Return ""


/*----------------------------------------------------------------------------
Retorna o valor para calculo de acordo com o atributo do componente
cAgrup       Número do Agrupador
cNrCalculo   Número da Unidade de Cálculo
cCdClFr      Código da Classificação de Frete
cAtribCalc   Atributo de cálculo da faixa/componente
nQtde        Quantidade de itens
nPesoReal    Peso real dos itens
nValor       Valor total dos itens
nVolume      Volume ocupado pelos itens
nFatorCub    Fator de cubagem para calculo do peso cubado
[nPesoCub]   Peso cubado a ser atualizado pela função
[cUnidMedFx] Unidade de medida da faixa
cTpEntr		 Tipo de atributo faixa/componentes
cNrLocEnt	 Número de local de entrega
cUnit        Código do unitilizador
?
cCdTpOp      Tipo de Operacao, chave da tcf
cSeq          sequencia, chave da tcf
----------------------------------------------------------------------------*/
Function GFEQtdeComp(cAgrup, cNrCalculo, cCdClFr, cAtribCalc, nQtde, nPesoReal, nValor, nValLiq, nVolume, nFatorCub, nPesoCubado, cUnidMedFx, nPesoAlter, nQtdMin, cIDVLAG, cTpEntr, cNrLocEnt, lUtlFrMin, cCdTpOp, cSeq, cUnit, cCodComp)
	Local nValCpn  := 0

	Local aAreaTRE    := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7) 
	Local aAreaITE    := GFEXFB_9GETAREA(lTabTemp, cTRBITE, 8) 
	Local aAreaDOC    := GFEXFB_9GETAREA(lTabTemp, cTRBDOC, 1) 
	Local aAreaAGR    := GFEXFB_9GETAREA(lTabTemp, cTRBAGRU, 0) 
	Local aAreaTCF    := GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5) 
	Local aAreaGRU    := GFEXFB_9GETAREA(.F., , 4)
	Local nTQtde      := 0
	Local nTPesoReal  := 0
	Local nTValor     := 0
	Local nTValLiq    := 0
	Local nTVolume    := 0
	Local nTPesCub    := 0
	Local nTPesoAlter := 0
	Local nVolTCF     := 0
	Local nPesoCubCrg := 0 // Peso cubado com a carga compartilhada
	Local lTemCrgCmp  := .F.
	Local aRetPE      := {}
	local aDocCarg2   := {}

	Default nPesoCubado    := 0
	Default cUnidMedFx := ""
	Default nQtdMin    := 0
	Default cIDVLAG    := "1"
	Default cTpEntr    := ""
	Default cUnit      := ""
	Default cCodComp   := ""
	
	GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
	GFEXFB_2TOP(lTabTemp, cTRBTCF, @aTRBTCF1, 5)
	lTemCrgCmp := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, "PERCOUT") != 0
	GFEXFB_ARESTAREA(lTabTemp,aAreaTCF,5)
	
	If cIDVLAG == "2"

		//Se é por romaneio o que importa é a soma dos itens para o cálculo do componente.
		GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
		GFEXFB_2TOP(lTabTemp, cTRBTCF, @aTRBTCF1, 5)
		If lTemCrgCmp //Quanto tem carga compartilhada, as quantidades foram adicionados de forma rateada no tcf
			While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5)
				If Empty(cCdClFr) .OR. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") == cCdClFr
					nVolTCF += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
				EndIf
				
				nTQtde      += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
				nTPesoReal  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
				nTValor     += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
				nTVolume    += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
				nTValliq    += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ")
				GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
			EndDo
			GFEXFB_ARESTAREA(lTabTemp,aAreaTCF,5)

			GFEXFB_BORDER(lTabTemp,cTRBITE,01,8) 
			GFEXFB_2TOP(lTabTemp, cTRBITE, @aTRBITE1, 8) 
			While !GFEXFB_3EOF(lTabTemp, cTRBITE, @aTRBITE1, 8) 
	
				nTPesoAlter += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDALT")
				GFEXFB_8SKIP(lTabTemp, cTRBITE, 8) 
			EndDo
			
		Else
		
			GFEXFB_BORDER(lTabTemp,cTRBITE,01,8) 
			GFEXFB_2TOP(lTabTemp, cTRBITE, @aTRBITE1, 8) 
			While !GFEXFB_3EOF(lTabTemp, cTRBITE, @aTRBITE1, 8) 
	
				nTQtde      += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE")
				nTPesoReal  += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR")
				nTValor     += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR")
				nTVolume    += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME")
				nTPesCub    += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOC")
				nTPesoAlter += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDALT")
				nTValLiq    += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALLIQ")
				
				GFEXFB_8SKIP(lTabTemp, cTRBITE, 8) 
			EndDo
			
		EndIf		

		nQtde      := nTQtde
		nPesoReal  := nTPesoReal
		nValor     := nTValor
		nVolume    := nTVolume
		nPesoCubado:= nTPesCub
		nPesoAlter := nTPesoAlter
		nValLiq    := nTValLiq
	EndIf

	cAtribCalc := AllTrim(cAtribCalc)

	If cAtribCalc $ "1;5" // 1- Peso Mercadoria, 5-Qtde Volumes

		If cAtribCalc == "1"
			
			If nPesoCubado == 0	// Peso da mercadoria
				
				If !lTemCrgCmp
					nPesoCubado := GFEPesoCub(nFatorCub, cCdClFr, cNrCalculo)
				Else
					nPesoCubado := GFEPesoCub(nFatorCub, cCdClFr, cNrCalculo)
					If (!Empty(cCdTpOp) .Or. !Empty(cSeq))
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUBORG",nPesoCubado)
					EndIf
					nPesoCubCrg := GFEPesoCub(nFatorCub, cCdClFr, cNrCalculo, If((nVolTCF > 0), nVolTCF, nVolume))
					If nPesoCubado > 0 .And. nPesoCubCrg > 0 .And. nPesoCubCrg > nPesoReal .And. nPesoCubCrg > nPesoCubado
						If (!Empty(cCdTpOp) .Or. !Empty(cSeq)) .And. GetNewPar("MV_CRIRAT", "5") == '1'
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, "PERCOUT" , (nPesoCubCrg - nPesoCubado) / ( nPesoCubCrg ) )
						EndIf
						nPesoCubado := nPesoCubCrg
					EndIf
				EndIf
				
			ElseIf lTemCrgCmp
				
				nPesoCubado := GFEPesoCub(nFatorCub, cCdClFr, cNrCalculo)
				If (!Empty(cCdTpOp) .Or. !Empty(cSeq))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUBORG", nPesoCubado)
				EndIf
				nPesoCubCrg := GFEPesoCub(nFatorCub, cCdClFr, cNrCalculo, If((nVolTCF > 0), nVolTCF, nVolume))
				
				If nPesoCubado > 0 .And. nPesoCubCrg > 0 .And. nPesoCubCrg > nPesoReal .And. nPesoCubCrg > nPesoCubado
					If (!Empty(cCdTpOp) .Or. !Empty(cSeq)) .And. GetNewPar("MV_CRIRAT", "5") == '1'
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, "PERCOUT" , (nPesoCubCrg - nPesoCubado) / ( nPesoCubCrg ) )
					EndIf
					nPesoCubado := nPesoCubCrg
				EndIf
				
			EndIf

		Else	// Qtde Volumes
			
			//posiciona e percorre trechos com mesmo Numero Calculo
			GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
			GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNrCalculo}) 
			nValCpn := 0
			aDocCarg2 := aClone(aDocCarg)
			While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. cNrCalculo == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC")

				GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1) 
				GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
															  GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
															  GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") , ;
															  GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")}) 

				// percorre todos os documentos de carga do trecho para obter a quantidade de volumes/unitizadores
				While !GFEXFB_3EOF(lTabTemp, cTRBDOC, @aDocCar2, 1) .AND.; 
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDTPDC") .And.;
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"EMISDC") .And.;
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"SERDC")  .And.;
				GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")   == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"NRDC")
					If !Empty(cUnit) .And. Len(@aDocCarg2[1]) >= 18 .And. Valtype(@aDocCarg2[1][18]) == "A"
						nPosDoc := aScan(aDocCarg2,{|x|x[1] == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"EMISDC") .And. ;
										 x[2] == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"SERDC").And. ;
										 x[3] == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"NRDC") .And. ;
										 x[4] == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDTPDC")})
						
						nPos := aScan(aDocCarg2[nPosDoc][18],{|x|x[1] == cUnit })
						If nPos > 0
							nValCpn += aDocCarg2[nPosDoc][18][nPos][2]
						EndIf
					Else
						nValCpn += GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"QTUNIT")
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBDOC, 1) 
				EndDo
				GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
			EndDo
		EndIf

		If cAtribCalc == "1"	// Peso da mercadoria
			// Ponto de entrada que permite a escolha do peso a ser utilizado no cálculo do componente
			If ExistBlock("GFEXFB11")
				aRetPE  := ExecBlock("GFEXFB11",.F.,.F.,{cCdClFr,nPesoCubado,nPesoReal})
				nValCpn := aRetPE[1]
				AddToLog(aRetPE[2])
			Else
				//determina o peso para calculo
				nValCpn := If(nPesoCubado > nPesoReal, nPesoCubado, nPesoReal)
				AddToLog(If(nPesoCubado > nPesoReal, STR0424 + cValtoChar(nFatorCub) + " KG/M3) ", STR0425)) //" - Cubado ("###" - Real "

				If GFXCP2510('GV2_ATRPED')
					GV2->(dbSetOrder(01))
					If !Empty(cCodComp) .And. GV2->(dbSeek(xFilial("GV2") + cCodComp))
						If GV2->GV2_CATVAL == "4"
							// Não necessita tratar a regra de GV2_ATRPED == 1 (Maior entre peso bruto/cubado) pois esta fazendo isso na atribuição acima
							If Alltrim(GV2->GV2_ATRPED) == "2"
								nValCpn := nPesoReal
								AddToLog(" - Alterado peso considerado - Real: " + cValToChar(nValCpn))
							ElseIf Alltrim(GV2->GV2_ATRPED) == "3"
								nValCpn := nPesoCubado
								AddToLog(" - Alterado peso considerado - Cubado: " + cValToChar(nValCpn))
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			//conversao de unidades
			If !Empty(cUnidMedFx)
				nValCpn := GFEConvUM(s_UMPESO,cUnidMedFx,nValCpn)
				AddToLog(STR0426 + s_UMPESO + STR0427 + cUnidMedFx + STR0428) //", Conversão de "###" (Sistema) para "###" (Faixa) - "
			EndIf

		EndIf

	ElseIf cAtribCalc == "2" //2=Valor Mercad.

		nValCpn := nValor

	ElseIf cAtribCalc == "3" //3=Qtde Itens

		nValCpn := nQtde

	ElseIf cAtribCalc == "10" //10=Quantidade/Peso Alternativo


		If lPEXFB23
			aRetPE  := ExecBlock("GFEXFB23",.F.,.F.,{(cTRBITE),(cTRBTRE), cNrCalculo, cCdClFr, nFatorCub})
			nValCpn := aRetPE[1]
			AddToLog(aRetPE[2])
		Endif


		IF EMPTY(nValCpn) .or. nValCpn == 0
			nValCpn := nPesoAlter
		ENDIF


		If !Empty(cUnidMedFx)
			nValCpn := GFEConvUM(s_UMPESO,cUnidMedFx,nValCpn)
			AddToLog(STR0426 + s_UMPESO + STR0427 + cUnidMedFx + STR0428) //", Conversão de "###" (Sistema) para "###" (Faixa) - "
		EndIf

	ElseIf cAtribCalc == "4" //4=Volume Mercad.

		nValCpn := nVolume

	ElseIf cAtribCalc == "6" //6=Dist. Percorrida

		//pesquisa no agrupamento(romaneio) do grupo
		GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
		If GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{cAgrup}) 
			nValCpn := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"DISTAN")
		EndIf

	ElseIf cAtribCalc == "7" //7=Qtde Entregas

		nValCpn := GFEQtdeEntr(cAgrup,cTpEntr,cNrLocEnt)

	ElseIf cAtribCalc == "12" //12=Valor Líquido

		nValCpn := nValLiq

	EndIf

	If lUtlFrMin
		If nQtdMin > nValCpn
			nValCpn := nQtdMin
		EndIf
	EndIf

	GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7)
	GFEXFB_ARESTAREA(lTabTemp,aAreaITE,8)
	GFEXFB_ARESTAREA(lTabTemp,aAreaDOC,1)
	GFEXFB_ARESTAREA(lTabTemp,aAreaAGR,0)
	GFEXFB_ARESTAREA(lTabTemp,aAreaTCF,5)
	GFEXFB_ARESTAREA(.F.,aAreaGRU,4)

Return nValCpn

/*----------------------------------------------------------------------------
Atribui o grupo aos itens e trechos do documento de carga informado
----------------------------------------------------------------------------*/
Static Function GFEAtribGrp(cEmisDc, cSerieDC, cNrDC, cCdTpDC, cNumGrup)

	AddToLog(STR0475 + STR0476 + CRLF) //"    # Atribuir grupo de entregas aos trechos e itens do documento de carga: "

	//Alimenta campo interno "NRGRUP" (trechos)
	GFEXFB_BORDER(lTabTemp,cTRBTRE,02,7) 
	GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE2, 7,{cCdTpDC, cEmisDC, cSerieDC, cNrDC}) 
	While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE2, 7) .And. ;
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC") + ;
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC") + ;
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC")  + ;
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC") == cCdTpDC+cEmisDC+cSerieDC+cNrDC
		AddToLog(STR0477 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ") + STR0478 + cNumGrup + CRLF) //"      Trecho "###" -> Grupo "
		GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRGRUP",cNumGrup)
		GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
	EndDo

	//Alimenta campo interno "NRGRUP" (itens)
	GFEXFB_BORDER(lTabTemp,cTRBITE,01,8) 
	GFEXFB_CSEEK(lTabTemp, cTRBITE, @aTRBITE1, 8,{cCdTpDC, cEmisDC, cSerieDC, cNrDC})
	While  !GFEXFB_3EOF(lTabTemp, cTRBITE, @aTRBITE1, 8) .And. ;
			GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDTPDC") + ;
			GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"EMISDC") + ;
			GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"SERDC") + ;
			GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRDC") == cCdTpDC+cEmisDC+cSerieDC+cNrDC
		
		AddToLog(STR0479 + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"ITEM") + STR0480 + cNumGrup + CRLF) //"      Item "###" -> Grupo: "
		
		GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRGRUP",cNumGrup)
		GFEXFB_8SKIP(lTabTemp, cTRBITE, 8) 
	EndDo

Return

/*----------------------------------------------------------------------------
Rateia o valor recebido entre os cálculos do romaneio, proporcional ao valor de frete
de cada calculo.
cNrAgrup	Número do agrupador de frete (romaneio)
nVlFrtRat	Valor de frete a ratear entre os cálculos do agrupador
aVlFrtCalc	Array contendo os valores de frete para cada cálculo do agrupador
[1] - Número da unidade de cálculo
[2] - Valor de frete considerando frete mínimo
[3] - Valor de frete desconsiderando frete mínimo
[4] - Valor do frete mínimo
----------------------------------------------------------------------------*/
Static Function GFERatVlFr(cNrAgrup,nVlFrtRat,aVlFrtCalc)

	Local nFrtComMinTot := 0
	Local nPos      := 0
	Local nValor    := 0
	Local nTotRat   := 0
	Local nRecNo    := 0
	Local nMaior    := 0
	Local nVlFrMin  := 0
	Local nQtComMin := 0
	Local cTxtAux   := 0

	AddToLog(STR0481 + cValToChar(nVlFrtRat) + STR0482 + cNrAgrup + CRLF) //"    Rateando valor do frete mínimo ("###") entre os cálculos do agrupador "

	// Obtem o valor total de frete do romaneio
	GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
	GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{cNrAgrup})
	while !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == cNrAgrup

		// para cada calculo do romaneio, verifica se tem valor de frete
		nPos := aScan(aVlFrtCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
		If nPos > 0
			nFrtComMinTot += aVlFrtCalc[nPos,2]
		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
	EndDo

	AddToLog(STR0483 + cValToChar(nFrtComMinTot) + CRLF) //"    Valor total do agrupador: "

	// Efetua o rateio do valor de frete recebido entre os cálculos do romaneio
	GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
	GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{cNrAgrup})
	while !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == cNrAgrup

		nPos := aScan(aVlFrtCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
		If nPos > 0

			// Calcula a parcela do valor de frete correspondente ao valor do cálculo de frete
			nValor := nVlFrtRat * (aVlFrtCalc[nPos,2] / nFrtComMinTot)
			AddToLog(STR0484 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + ": " + cValToChar(nValor) + ; //"    Valor da parcela para o cálculo "
			" => " + cValtoChar(nVlFrtRat) + " * (" + cValTochar(aVlFrtCalc[nPos,2]) + "/" + cValtoChar(nFrtComMinTot) + ")" + CRLF)

			// Identifica em qual cálculo foi gravada a maior parcela do rateio
			If nMaior < nValor
				nMaior := nValor
				nRecNo := GFEXFB_GRECNO(lTabTemp, cTRBUNC, 6)
			EndIf
			nTotRat += nValor

			GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
			GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
		
			GV9->(dbSetOrder(01))
			GV9->(dbSeek(xFilial("GV9") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") + ;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")))

			// Totaliza o frete normal dos componentes que receberam o frete minimo
			nVlFrMin  := 0
			nQtComMin := 0
			GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
			If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})

				While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
						
					//If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"IDMIN") == "1"	// Indica que o componente recebeu o valor minimo
					if GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") == GV9->GV9_COMMIN
						nVlFrMin += (GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") - GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI"))
						nQtComMin++
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
				EndDo
			EndIf

			// Atualiza a parcela do rateio nos componentes usados para receber o frete mínimo
			GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
			GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
			While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
					GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")


				//If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"IDMIN") == "1"	// Indica que o componente recebeu o valor minimo
				if GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") == GV9->GV9_COMMIN

					AddToLog(STR0485 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + CRLF) //"    Atualizando valor de frete mínimo no componente: "
					AddToLog(STR0486 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI")) + CRLF) //"    Valor atual: "
					GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"IDMIN","1")
					GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") - GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI"))	// Desconta o valor de frete minimo adicionado anteriormente
					If nVlFrMin > 0
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI",(nValor * (GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") / nVlFrMin)))
						AddToLog(STR0487 + CRLF) //"    Rateio proporcional ao valor do componente..."
						cTxtAux := " -> " + cValToChar(nValor) + " * ( " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + " / " + cValToChar(nVlFrMin) + " )"
					Else
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI",nValor	/ nQtComMin)
						AddToLog(STR0488 + CRLF) //"    Rateio proporcional a quantidade de componentes..."
						cTxtAux := " -> " + cValToChar(nValor) + " / " + cValToChar(nQtComMin)
					EndIf
					GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI")) // Adiciona o novo valor de frete mínimo
					AddToLog(STR0489 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI")) + cTxtAux + CRLF) //"    Novo valor: "

				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
			EndDo
		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
	EndDo

	If (nTotRat != nVlFrtRat)

		AddToLog(STR0490 + CRLF) //"    Ajustando diferença em função do rateio..."

		// Se houver diferença entre a soma das parcelas de rateio e o valor a ratear, joga esta diferença
		// no 1o componente do cálculo que recebeu a maior parcela
		GFEXFB_HGOTO(lTabTemp, cTRBUNC, 6, nRecNo)

		GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
		If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
			While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
				If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"IDMIN") == "1"	// Indica que o componente recebeu o valor minimo
					AddToLog(STR0491 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + CRLF) //"    Atualizando diferença no componente marcado para frete mínimo: "
					GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI") + (nTotRat - nVlFrtRat)) 
					AddToLog(STR0492 + cValToChar(nTotRat - nVlFrtRat) + CRLF)				 //"    Valor somado: "
					Exit
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
			EndDo
		EndIf
	EndIf

Return

/*----------------------------------------------------------------------------
Atualiza o array de parametros com o componente recebido
aCompToAdd
[1] - Código do componente
[2] - Indica se o componente soma no total do frete
[3] - Indica se o componente soma na base de calculo do imposto (ISS/ICMS)
[4] - Indica se o componente soma na base de calculo de PIS/COFINS
[5] - Indica se o componente é considerado na comparação do frete minimo
[6] - Número da unidade de cálculo ao qual o componente está associado
aParam - array ao qual será adicionado o array aCompToAdd
----------------------------------------------------------------------------*/
Function GFEParamComp(aCompToAdd,aParam)

	Local nI := 0

	/*
	Supondo a seguinte configuração de componentes padrao da negociacao (tabela GUY)
	+------+-------------+--------+-------+----------+--------+
	|Negoc |Componente   |TotFrete|BaseImp|BasePISCOF|FreteMin|
	+------+-------------+--------+-------+----------+--------+
	|1     |FRETE PESO   |1       |1      |1         |2       |
	|      |PEDAGIO      |1       |2      |2         |1       |
	|2     |FRETE VALOR  |1       |2      |2         |2       |
	|      |PEDAGIO      |1       |1      |1         |2       |
	+------+-------------+--------+-------+----------+--------+

	O array aParamComp deve conter o seguinte, apos passar por todos os componentes e negociacoes
	+-------------+--------+-------+----------+--------+
	|Componente   |TotFrete|BaseImp|BasePISCOF|FreteMin|
	+-------------+--------+-------+----------+--------+
	|FRETE PESO   |1       |1      |1         |2       |
	|PEDAGIO      |1       |1      |1         |1       |
	|FRETE VALOR  |1       |2      |2         |2       |
	+-------------+--------+-------+----------+--------+

	Observe que para o componente PEDAGIO, que aparece duas vezes na tabela GUY
	prevaleceu o valor "1" para os parãmetros.
	*/

// Adiciona o componente no array de parametros, prevalecendo os parametros ativos
nI := aScan(aParam,{|x| x[1] == aCompToAdd[1] .AND. x[6] == aCompToAdd[6]})
if nI == 0
	aAdd(aParam,aCompToAdd)
Else
	aParam[nI,2] := IF(aCompToAdd[2] == "1",aCompToAdd[2],aParam[nI,2])
	aParam[nI,3] := IF(aCompToAdd[3] == "1",aCompToAdd[3],aParam[nI,3])
	aParam[nI,4] := IF(aCompToAdd[4] == "1",aCompToAdd[4],aParam[nI,4])
	aParam[nI,5] := IF(aCompToAdd[5] == "1",aCompToAdd[5],aParam[nI,5])
EndIf

Return

/*----------------------------------------------------------------------------
Valida se o transportador do cálculo corresponde ao transportador do romaneio.
----------------------------------------------------------------------------*/
Function GFETrpTrecho(cNrAgrup,cNrCalc)

	Local aAreaTRE   := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7) 
	Local aAreaAGRU  := GFEXFB_9GETAREA(lTabTemp, cTRBAGRU, 0) 
	Local cCdTrpCalc := ""
	Local lRet       := .F.

	GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
	if GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNrCalc}) 
		cCdTrpCalc := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP")
	EndIf

	GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
	GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
	GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{cNrAgrup})
	
	lRet := (GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTRP") == cCdTrpCalc)

	GFEXFB_ARESTAREA(lTabTemp,aAreaTRE ,7) //RestArea(aAreaTRE)
	GFEXFB_ARESTAREA(lTabTemp,aAreaAGRU,0) //RestArea(aAreaAGRU)

Return lRet

/*----------------------------------------------------------------------------
Retorna a descrição do critério de rateio
----------------------------------------------------------------------------*/
Function GFEDsCriRat(cCriRat)

	Local cDsCriRat

	If val(cCriRat) > 0 .AND. val(cCriRat) < 5
		cDsCriRat := {STR0494,STR0495,STR0496,STR0497}[val(cCriRat)] //"Peso"###"Valor"###"Volume (m3)"###"Quantidade"
	Else
		cDsCriRat := STR0498 + cCriRat + ")" //"Critério inválido ("
	EndIf

Return cDsCriRat

/*----------------------------------------------------------------------------
{Protheus.doc} GFECalcMan
Calcula Frete Manual de Devolução e Reentrega.
Uso: GFEA083

@param aNfCalc   Array bidimensional contendo os documentos de carga a vincular no novo calculo
[N][1] Caracter - Emissor do documento de carga
[N][2] Caracter - Série do documento de carga
[N][3] Caracter - Número do documento de carga
[N][4] Caracter - Tipo do documento de carga
@param cNrCalc   Número do novo cálculo de frete
@param cNrBase   Número do cálculo de frete usado como base
@param cTipoCalc Tipo de cálculo a ser gerado
@param nQt       Quantidade a ser multiplicada pelo valor de serviço
@param nServ     Valor de frete informado pelo usuário. Opcional.
@param lOcor     Indica se a rotina foi chamada a partir de ocorrência
@param cOriCalc   1 - Indica que a rotina foi chamada a partir do romaneio
				  2 - Indica que a rotina foi chamada pela ocorrencia

@sample GFECalcMan(aNfCalc)

@author Luiz Fernando Soares
@since 03/08/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFECalcMan(aNfCalc, cNrCalc, cNrBase, cTipoCalc, nQt, nServ, lOcor, cOcor, cOriCalc)

	Local lRet        := .T.
	Local aArea       := GetArea()
	LOcal nPercDev    := 0
	Local nPercReen   := 0
	Local nPerPisCal  := SuperGetMV('MV_PCPIS',,'1')
	Local nPerCofCal  := SuperGetMV('MV_PCCOFI',,'1')
	Local nTotCompCa  := 0
	Local nTotCpReen  := 0 // Base de cálculo para cálculo de Reentrega
	Local nTotOcor    := 0
	Local nVlCompSrv  := 0
	Local nMaxReen    := 0
	Local nPcPis      := 0
	Local nPcCofi	  := 0
	Local cEmitTab    := ""
	Local cNrTab      := ""
	Local cNrNegoc 	  := ""
	Local cNrRota  	  := ""
	Local cAdIcmsFre  := ""
	Local cRatImp	  := ""
	Local cCompImp	  := ""
	Local lSair       := .F.
	Local aInfoTab    := {}
	Local aAux        := {}
	Local aAreaGWD
	Local cCompServ   := ""	// Componente de Serviço Customizado - XGFEOCSV
	Local cCdCompServ := ""	// Código do Componente de Serviço escolhido
	Local nVlCompServ := 0	// Valor do Componente de Serviço escolhido
	Local nMinReen    := 0
	Local cTransp
	/* >>> Variaveis usadas no cálculo de devolução*/
	Local cCdTrp      := ""
	Local cCdRem   	  := ""
	Local cCdDest  	  := ""
	Local cOrigem     := ""
	Local cDestin     := ""
	Local cUsoCarga   := ""
	Local cTpItens    := ""
	Local cTpClass    := ""
	Local cTribIcms   := ""
	Local cRomTpOp    := ""
	Local aGFEOCOVL[5]
	Local cGWGCLFR    := ""
	Local cGWGTPOP    := ""
	Local cNrBasCal	  := ""
	Local cMV_CALCIMP := SuperGetMV("MV_CALCIMP", ,"0")
	Local nVlrImp     := 0
	Local cAliqIss    := NIL
	Local cTipOper    := Nil
	Local cAliasGWM   := Nil
	/* <<< */

	Local cICMSPT	  := SuperGetMV("MV_ICMSPA",.F.,"2")
	Local nImpPaut	  := 0

	Local nTotPeso	  := 0
	Local cAliasGW8	  := ""
	Local cTpOpDoc    := ""

	Local cGUY_DEVOL  := ""
	Local cGUY_REENT  := ""

	Local cCodTrpRee  := ""
	Local lCalcComb	  := .F.
	Local cNumEmit 	  := ""
	Local cNumTabAux  := ""
	Local cNumNeg     := ""

	Private aTRBSEL   := {} // Indice 1
	Private idpSEL    := 1 // posição do array cTRBNFSel
	Private idxSEL    := 1 // Indice  da array cTRBNFSel
	Private _aCmpSEL  := {	"EMISDC",;
							"SERDC" ,;
							"NRDC"  ,;
							"CDTPDC"}

	Default nServ 	  := 0
	Default cOcor 	  := ""
	Default cOriCalc  := "2"

	If ExistBlock("XGFEOCSV")
		aAreaGWD := GWD->(GetArea())
		GWD->(dbSetOrder(1))
		If GWD->(dbSeek(xFilial("GWD") + cOcor))
			GU5->(dbSetOrder(1))
			If GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO))
				If GU5->GU5_TPCALC == "3"
					cCompServ := ExecBlock("XGFEOCSV",.f.,.f.,{GWD->GWD_FILIAL, GWD->GWD_NROCO, GWD->GWD_CDTIPO, GWD->GWD_CDMOT})
				EndIf
			Endif
		EndIf
		RestArea(aAreaGWD)
	EndIf

	If cOriCalc == "2" //Indica que a chamada é via ocorrencia

		// Transfere os documentos de carga do array para uma tabela temporária
		aTRBSEL := aClone(aNfCalc)
		aSort(aTRBSEL  ,,,{|x,y| x[04]+x[01]+x[02]+x[03]      < y[04]+y[01]+y[02]+y[03]})
		
		// Cria um novo cálculo (cNrCalc) com base no cálculo original (cNrBase)
		GWF->(dbSetOrder(01))
		if GWF->(dbSeek(xFilial("GWF")+cNrBase))

			nBaIcmsImp := GWF->GWF_BASICM
			nBaIssImp  := GWF->GWF_BASISS
			//GFEXCOPREG já verifica se o campo existe.
			GFEXCOPREG( "GWF", {	{'GWF_NRCALC', cNrCalc}, {'GWF_TPCALC', cTipoCalc}, {'GWF_NROCO', cOcor},;
									{"GWF_CDESP"," "}, {"GWF_EMISDF"," "}, {"GWF_SERDF"," "}, {"GWF_NRDF"," "},;
									{"GWF_DTEMDF",STOD(Space(8))}, {"GWF_CDTPSE"," "} } )

			GWF->(dbSetOrder(1) )
			GWF->(dbSeek(xFilial("GWF")+cNrCalc) )
			RecLock( "GWF", .F. )
			GWF->GWF_DTCRIA := DDATABASE
			GWF->GWF_HRCRIA := SubStr(TIME(), 1, 5)
			GWF->GWF_DTPREN := StoD("  \  \  ")
			GWF->GWF_USUCRI := cUserName 
			GWF->GWF_ORIGEM := "1" 
			GWF->GWF_HRPREN := "    "
			GWF->GWF_NRCONT := "        "
			GWF->GWF_FILPRE := "        "
			GWF->GWF_NRPREF := "        "
			GWF->GWF_VLAJUS := 0
			GWF->(MsUnlock())

			GWF->(dbSeek(xFilial("GWF")+cNrBase))
		endif

		//Vincula as notas recebidas ao novo cálculo
		GFEXFB_BORDER(.F.,'',01,11)
		GFEXFB_2TOP(.F.,'', @aTRBSEL, 11)
		while !GFEXFB_3EOF(.F.,'', @aTRBSEL, 11)
			GWH->(dbSetOrder(02))
			GWH->(dbSeek(xFilial("GWH")+GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"CDTPDC") + GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"EMISDC") + GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"SERDC") + GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"NRDC") + cNrBase))
			while !GWH->(EOF()).and. GWH->GWH_NRDC == GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"NRDC") .and. GWH->GWH_NRCALC  == cNrBase

				GFEXCOPREG( "GWH", { { 'GWH_NRCALC', cNrCalc } } )

				GWH->(dbSkip())
			enddo
			GFEXFB_8SKIP(.F.,'', 11)
		end

		// Copia os componentes do cálculo base para o novo calculo
		If  cTipoCalc == "7" // Serviço

			lSair := .F.
			GWG->(dbSetOrder(01))
			if GWG->(dbSeek(xFilial("GWG")+cNrBase))
				While !GWG->(Eof()) .AND. !lSair .AND. xFilial("GWG") == GWG->GWG_FILIAL .AND. cNrBase == GWG->GWG_NRCALC

					aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
					cEmitTab := aInfoTab[2]
					cNrTab   := aInfoTab[3]

					GV1->(dbSetOrder(01))
					If GV1->(dbSeek(xFilial("GV1")+cEmitTab+cNrTab+GWG->GWG_NRNEG+GWG->GWG_CDFXTV+GWG->GWG_NRROTA))
						While !GV1->(Eof()) .AND. xFilial("GV1")  == GV1->GV1_FILIAL;
											.AND. cEmitTab        == GV1->GV1_CDEMIT;
											.AND. cNrTab          == GV1->GV1_NRTAB;
											.AND. GWG->GWG_NRNEG  == GV1->GV1_NRNEG;
											.AND. GWG->GWG_CDFXTV == GV1->GV1_CDFXTV;
											.AND. GWG->GWG_NRROTA == GV1->GV1_NRROTA

							// Componente da tarifa da tabela base é de Serviço
							if Posicione("GV2",1,xFilial("GV2")+GV1->GV1_CDCOMP,"GV2_SERVI") == "1"

								If !Empty(cCompServ)
									If AllTrim(cCompServ) == AllTrim(GV1->GV1_CDCOMP)
										cCdCompServ := GV1->GV1_CDCOMP
										nVlCompServ := If(nServ > 0, nServ, GV1->GV1_VLFIXN) * nQt
										lSair := .T.
										cGWGCLFR := GWG->GWG_CDCLFR
										cGWGTPOP := GWG->GWG_CDTPOP
										Exit
									EndIf

									// Garante que pelo menos o primeiro componente de serviço seja escolhido
									If Empty(cCdCompServ)
										cCdCompServ := GV1->GV1_CDCOMP
										nVlCompServ := If(nServ > 0, nServ, GV1->GV1_VLFIXN) * nQt
										cGWGCLFR := GWG->GWG_CDCLFR
										cGWGTPOP := GWG->GWG_CDTPOP
									EndIf
								Else
									cCdCompServ := GV1->GV1_CDCOMP
									nVlCompServ := If(nServ > 0, nServ, GV1->GV1_VLFIXN) * nQt

									lSair := .T.
									cGWGCLFR := GWG->GWG_CDCLFR
									cGWGTPOP := GWG->GWG_CDTPOP
									Exit
									
								EndIf
							EndIf

							GV1->(dbSkip())
						EndDo

						If !Empty(cCdCompServ)
							/*
							ID | Campo relativo | Tipo |Descrição
							---|----------------|--------------------------------------
							1  | GWI_CDCOMP 		|	C	| Codigo do Componente
							2  | GWI_VLFRET		|	N	| Valor Frete
							3  | GWI_QTCALC		| 	N	| Quantidade Calculo
							4  | GWI_IDMIN		| 	C	| Minimo?
							5  | GWI_TOTFRE		| 	C	| Soma no total do frete?
							*/
aGFEOCOVL[1] := cCdCompServ
aGFEOCOVL[2] := nVlCompServ
aGFEOCOVL[3] := 0
aGFEOCOVL[4] := "2"
aGFEOCOVL[5] := "1"


// Ponto de entrada para customizar o valor do cálculo da ocorrência
If lOcor .AND. lOCOVL
	aAreaGWD := GWD->(GetArea())
	GWD->(dbSetOrder(1))
	If GWD->(dbSeek(xFilial("GWD") + cOcor))
		aGFEOCOVL := ExecBlock("GFEOCOVL",.f.,.f.,{xFilial("GWF"), cNrCalc, GWD->GWD_FILIAL, GWD->GWD_NROCO, GWD->GWD_CDTIPO, GWD->GWD_CDMOT, aGFEOCOVL})
	Else
		aGFEOCOVL := ExecBlock("GFEOCOVL",.f.,.f.,{xFilial("GWF"), cNrCalc, "", "", "", "", aGFEOCOVL})
	EndIf
	RestArea(aAreaGWD)
EndIf

// Criar o componente no cálculo novo e atribuir o valor
RecLock("GWI",.T.)
GWI->GWI_FILIAL := xFilial("GWI")
GWI->GWI_NRCALC := cNrCalc
GWI->GWI_CDCOMP := aGFEOCOVL[1]
GWI->GWI_VLFRET := aGFEOCOVL[2]
GWI->GWI_QTCALC := aGFEOCOVL[3]
GWI->GWI_IDMIN  := aGFEOCOVL[4]
GWI->GWI_TOTFRE := aGFEOCOVL[5]
GWI->GWI_CDCLFR := cGWGCLFR
GWI->GWI_CDTPOP := cGWGTPOP
GWI->(MsUnLock())
EndIf
EndIf

GWG->(dbSkip())
EndDo
EndIf

GWI->(dbSetOrder(01))
If !GWI->(dbSeek(xFilial("GWI")+cNrCalc))
	GFEMsgErro(STR0551) //"Cálculo não foi gerado. Não encontrado componente de serviço"
	Finalizar(.F., cNrCalc, aArea, aTRBSEL)
Return .F.
EndIf
Else
	cNrBasCal := IIF(lOcor,cNrBase,cNrCalc)
	IF cTipoCalc = "5"
		GWG->(dbSetOrder(01))
		GWG->(dbSeek(xFilial("GWG") + cNrBasCal))
		cNumEmit := GWG->GWG_CDEMIT
		cNumTabAux := GWG->GWG_NRTAB
		cNumNeg := GWG->GWG_NRNEG

		// Busca apenas os componentes da GWI que fazem parte do calculo de devolução.
		cAliasGWI := GetNextAlias()
		cQuery := "SELECT DISTINCT GWI_VLFRET"
		cQuery += " FROM "+RetSqlName("GWI") + " GWI"
		cQuery += " INNER JOIN "+RetSqlName("GUY") + " GUY"
 		cQuery += " ON GWI.GWI_CDCOMP = GUY.GUY_CDCOMP"
		cQuery += " WHERE GWI.GWI_FILIAL = ?"
		cQuery += " AND GUY.GUY_FILIAL = ?"
		cQuery += " AND GUY.GUY_CDEMIT = ?"
		cQuery += " AND GUY.GUY_NRTAB = ?"
		cQuery += " AND GUY.GUY_NRNEG = ?"
		cQuery += " AND GUY.GUY_DEVOL = ?"
		cQuery += " AND GWI.GWI_NRCALC = ?"
		cQuery += "	AND GWI.D_E_L_E_T_ = ''"
		cQuery += "	AND GUY.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery)

		oQry:SetString(1,xFilial("GWI"))
		oQry:SetString(2,xFilial("GUY"))
		oQry:SetString(3,cNumEmit)
		oQry:SetString(4,cNumTabAux)
		oQry:SetString(5,cNumNeg)
		oQry:SetString(6,'1')
		oQry:SetString(7,cNrBasCal)

		cAliasGWI := oQry:OpenAlias()
		(cAliasGWI)->(dbGoTop())
		Do While (cAliasGWI)->(!EoF())
			nTotCompCa += (cAliasGWI)->GWI_VLFRET // Grava o total dos componentes de devolução 
			(cAliasGWI)->(dbSkip())
		EndDo
		(cAliasGWI)->(dbCloseArea())

		GWI->(dbSetOrder(01))
		GWI->(dbSeek(xFilial("GWI")+cNrBasCal))
		While !GWI->(EOF()) .and. GWI->GWI_NRCALC  == cNrBasCal
			If lOcor
				GFEXCOPREG( "GWI", { { 'GWI_NRCALC', cNrCalc } } )
			EndIf
			GWI->(dbSkip())
		EndDO
	Else
		GWI->(dbSetOrder(01))
		GWI->(dbSeek(xFilial("GWI")+cNrBasCal))
		While !GWI->(EOF()) .and. GWI->GWI_NRCALC  == cNrBasCal
			nTotCompCa += GWI->GWI_VLFRET
			If lOcor
				GFEXCOPREG( "GWI", { { 'GWI_NRCALC', cNrCalc } } )
				If  cTipoCalc == "4" .and. GFXCP12117("GUY_REENT") // Monta a base de cálculo de reentrega
					GWG->(dbSetOrder(01))
					If GWG->(dbSeek(xFilial("GWG") + cNrBase))
						aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
						cEmitTab := aInfoTab[2]
						cNrTab   := aInfoTab[3]
						If Posicione("GUY",1,xFilial("GUY") + cEmitTab + cNrTab + GWG->GWG_NRNEG + GWI->GWI_CDCOMP,"GUY_REENT") == "1"
							nTotCpReen += GWI->GWI_VLFRET
						EndIf
					Else
						nTotCpReen += GWI->GWI_VLFRET
						lCalcComb  := .T.
					EndIf
				EndIf
			EndIf
			GWI->(dbSkip())
		EndDo
	EndIf
Endif
// Copia as tabelas do cálculo base para o novo calculo
GWG->(dbSetOrder(01))
GWG->(dbSeek(xFilial("GWG")+cNrBase))
While !GWG->(EOF()) .and. GWG->GWG_NRCALC == cNrBase

	GFEXCOPREG( "GWG", { { 'GWG_NRCALC', cNrCalc } } )

	GWG->(dbSkip())
EndDo
Else // Chamada via Romaneio, busca todos os componentes relacionados ao calculo.

	// Define o tipo do calculo como Devolução
	GWF->(dbSetOrder(01))
	If GWF->(dbSeek(xFilial("GWF")+cNrCalc))
		RecLock( "GWF", .F. )
		GWF->GWF_TPCALC := cTipoCalc
		GWF->(MsUnlock())
	EndIf

	GWI->(dbSeek(xFilial("GWI")+cNrCalc))
	While !GWI->(EOF()) .and. GWI->GWI_NRCALC  == cNrCalc
		nTotCompCa += GWI->GWI_VLFRET
		GWG->(dbSetOrder(01))
		GWG->(dbSeek(xFilial("GWG") + cNrCalc))
		aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
		cEmitTab := aInfoTab[2]
		cNrTab   := aInfoTab[3]
		If Posicione("GUY",1,xFilial("GUY") + cEmitTab + cNrTab + GWG->GWG_NRNEG + GWI->GWI_CDCOMP,"GUY_REENT") == "1"
			nTotCpReen += GWI->GWI_VLFRET
		EndIf
		GWI->(dbSkip())
	EndDo
EndIf

// Cálculos de reentrega e devolucao criados a partir da ocorrencia
If cTipoCalc <> "7" /* Servico  */ .AND. (lOcor .Or. cOriCalc == "1")
	// Obter os percentuais de reentrega, devolução e Adicional Imposto
	// Para os percentuais serão obtidos os maiores valores dentre as tabelas do calculo base
	// Para o adicional de ICMS, será considerado o da 1a tabela do cálculo base
	aAux := GFEPcReenDev(cNrCalc,cTipoCalc)
	nPercReen := aAux[1]
	nMaxReen  := aAux[2]
	nPercDev  := aAux[3]
	nMinReen  := aAux[4]
	cTransp   := aAux[5]

	GWG->(dbSetOrder(01))
	If GWG->(dbSeek(xFilial("GWG")+cNrCalc))
		While !GWG->(Eof()) .AND. GWG->GWG_FILIAL+GWG->GWG_NRCALC == xFilial("GWG") + cNrCalc

			// Retorna o emitente e tabela corretos, dependendo do tipo da tabela (normal ou vinculo)
			aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
			cEmitTab := aInfoTab[2]
			cNrTab   := aInfoTab[3]

			If Empty(cAdIcmsFre)
				cAdIcmsFre := Posicione("GV9",1,xFilial("GV9")+cEmitTab+cNrTab+GWG->GWG_NRNEG,"GV9_ADICMS")
			EndIf

			If Empty(cRatImp)
				cRatImp := Posicione("GV9",1,xFilial("GV9")+cEmitTab+cNrTab+GWG->GWG_NRNEG,"GV9_RATIMP")
				If cRatImp == "2"
					cCompImp := Posicione("GV9",1,xFilial("GV9")+cEmitTab+cNrTab+GWG->GWG_NRNEG,"GV9_COMIMP")
				EndIf
			EndIf

			GWG->(dbSkip())
		EndDo
	EndIf

	If cTipoCalc == "4" /*Reentrega*/ .AND. nMaxReen == 0
		GFEMsgErro(STR0552) //"Valor máximo de reentrega está zerado! Cálculo de frete não foi gerado."
		Finalizar(.F., cNrCalc, aArea, aTRBSEL)
		Return .F.
	EndIf

	If cTipoCalc == "4" .And. lCalcComb
		nPercReen := 100
	EndIf

	// Ajusta os percentuais (divide por 100)
	If nPercReen > 0
		nPercReen /= 100
	EndIf

	If nPercDev > 0
		nPercDev  /= 100
	EndIf

	// se valor é informado, calcula os percentuais com base no novo valor
	If nServ > 0
		nPercReen :=(nServ / nTotCpReen)
		nPercDev := (nServ / nTotCompCa)
		nTotOcor := nServ
		If cTipoCalc == "4" .And. nServ > nMaxReen
			nPercReen := (nMaxReen / nTotCompCa)
			nTotOcor  := nMaxReen
		EndIf
		If cTipoCalc == "4" .And. nServ < nMinReen
			nPercReen := (nMinReen / nTotCompCa)
			nTotOcor  := nMinReen
		EndIf
	Else
		If cTipoCalc == "4"
			nTotOcor := nTotCompCa * nPercReen
		EndIf

		If cTipoCalc == "5"
			nTotOcor := nTotCompCa * nPercDev
		EndIf
	EndIf
Elseif !lOcor
	nTotOcor := nTotCompCa
EndIf

// Atribuição dos valores de frete aos componentes do novo cálculo
GWI->(dbSetOrder(01))
GWI->(dbSeek(xFilial("GWI") + cNrCalc))
while !GWI->(Eof()) .and. xFilial("GWI") + GWI->GWI_NRCALC == xFilial("GWF") + cNrCalc

	If cTipoCalc $ "45" .And. (lOcor .Or. cOriCalc == "1") // 4 - Reentrega, 5 - Devolucao
		RecLock( "GWI", .F. )
		If cOriCalc == "2" //Indica que a chamada é via ocorrencia
			GWG->(dbSetOrder(01))
			If GWG->(dbSeek(xFilial("GWG") + cNrBase))
				aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
				cEmitTab := aInfoTab[2]
				cNrTab   := aInfoTab[3]

				cGUY_DEVOL := Posicione("GUY",1,xFilial("GUY") + cEmitTab + cNrTab + GWG->GWG_NRNEG + GWI->GWI_CDCOMP,"GUY_DEVOL")
				cGUY_REENT := Posicione("GUY",1,xFilial("GUY") + cEmitTab + cNrTab + GWG->GWG_NRNEG + GWI->GWI_CDCOMP,"GUY_REENT")

				// Verifica se os componentes da tabela de frete serão considerados na Reentrega/Devolução
				If (cTipoCalc == "5" .And. Posicione("GUY",1,xFilial("GUY") + cEmitTab + cNrTab + GWG->GWG_NRNEG + GWI->GWI_CDCOMP,"GUY_DEVOL") == "1") .Or.;
					cTipoCalc == "4" .And. Posicione("GUY",1,xFilial("GUY") + cEmitTab + cNrTab + GWG->GWG_NRNEG + GWI->GWI_CDCOMP,"GUY_REENT") == "1"

					GWI->GWI_VLFRET *= if(cTipoCalc == "4", nPercReen, nPercDev)
					GWI->GWI_QTCALC *= if(cTipoCalc == "4", nPercReen, nPercDev)
					If GFXCP12130("GWI_VLLIQ")
						GWI->GWI_VLLIQ  *= if(cTipoCalc == "4", nPercReen, nPercDev)
					EndIf
				Else
					GWI->(dbDelete())
				EndIf
			Else
				GWI->GWI_VLFRET *= if(cTipoCalc == "4", nPercReen, nPercDev)
				GWI->GWI_QTCALC *= if(cTipoCalc == "4", nPercReen, nPercDev)
				If GFXCP12130("GWI_VLLIQ")
					GWI->GWI_VLLIQ  *= if(cTipoCalc == "4", nPercReen, nPercDev)
				EndIf
			EndIf
		Else
			GWI->GWI_VLFRET *= if(cTipoCalc == "4", nPercReen, nPercDev)
			GWI->GWI_QTCALC *= if(cTipoCalc == "4", nPercReen, nPercDev)
			If GFXCP12130("GWI_VLLIQ")
				GWI->GWI_VLLIQ  *= if(cTipoCalc == "4", nPercReen, nPercDev)
			EndIf
		EndIf
		GWI->(MsUnlock())
	Elseif cTipoCalc == "7" // 7 - Serviço
		nVlCompSrv += GWI->GWI_VLFRET
	EndIf

	GWI->(dbSkip())
EndDo

//trecho responsavel por acrescentar ou tirar 0,01 dos arredondamentos
If cTipoCalc <> "7" // Serviço
	nVlTotal := 0
	nVlMaior := 0

	// Obtem o valor total com base nos componentes
	GWI->(dbSetOrder(01))
	GWI->(dbSeek(xFilial("GWI")+cNrCalc))
	While !GWI->(eof()) .and. GWI->GWI_NRCALC == cNrCalc
		nVlMaior := Max(GWI->GWI_VLFRET, nVlMaior)
		nVlTotal := GWI->GWI_VLFRET + nVlTotal
		GWI->(dbSkip())
	EndDo

	// A soma dos componentes é diferente do valor total original
	If nTotOcor != nVlTotal
		GWI->(dbSeek(xFilial("GWI") + cNrCalc))
		While !GWI->(Eof()) .And. GWI->GWI_NRCALC == cNrCalc
			// Busca o componente de maior valor para fazer a compensação
			If GWI->GWI_VLFRET == nVlMaior
				RecLock( "GWI", .F. )
				GWI->GWI_VLFRET += (nTotOcor - nVlTotal)
				GWI->(MsUnlock())
				Exit
			EndIf
			GWI->(dbSkip())
		EndDo
	EndIF
EndIf

nTotCompCa := nTotOcor

//**********************IMPOSTOS**************************//
nPcPis  := SuperGetMv("MV_PCPIS",, 0)
nPcCofi	:= SuperGetMv("MV_PCCOFI",, 0)

GWF->(dbSetOrder(01))
If GWF->(dbSeek(xFilial("GWF")+cNrCalc))
	RecLock( "GWF", .F. )
	If cTipoCalc == "7" // Serviço
		If GWF->GWF_IMPOST == "1"  .or. empty(GWF->GWF_IMPOST)   //ICMS
			GWF->GWF_BASICM :=  nVlCompSrv
			GWF->GWF_VLICMS :=  GWF->GWF_BASICM * (GWF->GWF_PCICMS/100)
		Elseif GWF->GWF_IMPOST == "2"  //ISS
			GWF->GWF_BASISS :=  nVlCompSrv
			GWF->GWF_VLISS  :=  GWF->GWF_BASISS * (GWF->GWF_PCISS/100)
		Endif

		GWF->GWF_BAPICO :=  nVlCompSrv
		GWF->GWF_VLPIS  :=  GWF->GWF_BAPICO * (nPerPisCal/100)
		GWF->GWF_VLCOFI :=  GWF->GWF_BAPICO * (nPerCofCal/100)

	Elseif cTipoCalc <> "7" // Diferente de serviço, ou seja, reentrega e devolução
		nTotPeso := 0

		cAliasGW8 := GetNextAlias()

		BeginSQL Alias cAliasGW8
				SELECT SUM(GW8.GW8_PESOR) AS GW8_PESOR
				FROM %Table:GW1% GW1
				INNER JOIN %Table:GW8% GW8
				ON GW8.GW8_FILIAL = GW1.GW1_FILIAL
				AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
				AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
				AND GW8.GW8_SERDC = GW1.GW1_SERDC
				AND GW8.GW8_NRDC = GW1.GW1_NRDC
				AND GW8.%NotDel%
				WHERE GW1.GW1_FILIAL = %Exp:xFilial("GW1")%
				AND GW1.GW1_NRROM = %Exp:GWF->GWF_NRROM%
				AND GW1.%NotDel%
		EndSQL

		If (cAliasGW8)->(!EoF())
			nTotPeso := (cAliasGW8)->GW8_PESOR
		EndIf

		(cAliasGW8)->(dbCloseArea())

		If cTipoCalc == "4"  // Reentrega

			cCidOri  := GWF->GWF_CIDORI
			cCidDest := GWF->GWF_CIDDES

			cTipOper := Posicione("GWN", 1, xFilial("GWN") + GWF->GWF_NRROM, "GWN_CDTPOP")
			cTpClass := Posicione("GWN", 1, xFilial("GWN") + GWF->GWF_NRROM, "GWN_CDCLFR")

			If cMV_CALCIMP == "1"	// Refaz Calculo com base em nova origem da Reentrega/Devolução
				// Posiciona na GV8 para considerar transportador da reentrega
				GWG->(dbSetOrder(01))
				If GWG->(dbSeek(xFilial("GWG") + cNrBase))
					If !GWG->(Eof()) .And. xFilial("GWG") == GWG->GWG_FILIAL .And. cNrBase == GWG->GWG_NRCALC

						aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
						cEmitTab := aInfoTab[2]
						cNrTab   := aInfoTab[3]
						cNrNegoc := GWG->GWG_NRNEG
						cNrRota  := GWG->GWG_NRROTA

						GV8->(dbSetOrder(1))
						If GV8->(dbSeek( xFilial("GV1") + cEmitTab + cNrTab + cNrNegoc + cNrRota ))
							cCodTrpRee := GV8->GV8_TRPREE
						EndIf

						If Empty(cCodTrpRee) // Se não tiver transp de reentrega mantem do calculo normal.
							cCodTrpRee := cEmitTab
						EndIf
					EndIf
				EndIf

				If !Empty(cCodTrpRee)
					cCidOri  := Posicione("GU3", 1, xFilial("GU3") + cCodTrpRee, "GU3_NRCID")
				EndIf
				
				If !Empty(cCidOri)
					If cMV_CALCIMP == "1" .And. GFXCP12130("GWI_VLLIQ")
						cAliasGWI := GetNextAlias()

						BeginSQL Alias cAliasGWI
								SELECT SUM(GWI.GWI_VLLIQ) GWI_VLLIQ
								FROM %Table:GWI% GWI
								WHERE GWI.GWI_FILIAL = %Exp:GWF->GWF_FILIAL%
								AND GWI.GWI_NRCALC = %Exp:GWF->GWF_NRCALC%
								AND GWI.%NotDel%
						EndSQL

						If (cAliasGWI)->(!EoF())
							nTotCompCa := (cAliasGWI)->GWI_VLLIQ
						EndIf

						(cAliasGWI)->(dbCloseArea())
					EndIf

					If cCidDest != cCidOri	// ICMS
						// Verifica a aliquota do imposto
						GW1->(dbSetOrder(9))
						If GW1->( DbSeek(xFilial("GW1") + GWF->GWF_NRROM) )
							cTpOpDoc := Posicione("GWU", 4, xFilial("GWU") + GW1->GW1_NRDC,"GWU_CDTPOP")
							GW8->( dbSetOrder(1) )
							GW8->( dbSeek(xFilial("GW8") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
							If GW8->(!Eof())

								aRetIcm := GFEFnIcms(cCodTrpRee, ;			// Código do transportador
								GWF->GWF_EMIREM, ;   	// Código do remetente
								GWF->GWF_EMIDES, ;	  	// Código do destinatario
								cCidOri, ;			  	// Número da cidade de origem
								cCidDest, ;		  		// Número da cidade de destino
								GW1->GW1_USO, ;	  		// Forma de utilização da mercadoria
								GW8->GW8_TPITEM, ;   	// Tipo de item
								GW8->GW8_CDCLFR, ;   	// Classificação de frete
								GW1->GW1_ICMSDC, ;   	// Mercadoria é tributada de ICMS?
								IIF(!Empty(cTpOpDoc),cTpOpDoc,cTipOper),;				// Tipo de Operação do Agrupador do Documento de Carga
								xFilial("GWF"))   		// Filial do cálculo

								If aRetIcm[1] == 0
									GWF->GWF_TPTRIB = "2"
								EndIf

								If cICMSPT == "1"
									nImpPaut := GFEICMPAUT(cCodTrpRee,;
										GWF->GWF_EMIREM, ; // Código do remetente
									GWF->GWF_EMIDES,; // Código do destinatario
									cCidOri,;
										cCidDest,; // Número da cidade de destino
									cTpClass,; // Classificação de frete
									cTipOper,;
										nTotPeso,;
										.F.)
								EndIf

								If nImpPaut > nTotCompCa
									GWF->GWF_BASICM := nImpPaut
								Else
									If cMV_CALCIMP == "1" .And. cAdIcmsFre == "1"
										GWF->GWF_BASICM := nTotCompCa / (1-(aRetIcm[1]/100))
									Else 
										GWF->GWF_BASICM := nTotCompCa
									EndIf
								EndIf

								GWF->GWF_PCICMS := aRetIcm[1]

								nVlrImp := GWF->GWF_BASICM  * (aRetIcm[1]/100)
								GWF->GWF_VLICMS := nVlrImp
							EndIf
						EndIf

					Else // ISS
						cAliqIss := 0
						GU3->(dbSetOrder(1) )
						GU3->(dbSeek(xFilial("GU3") + GWF->GWF_TRANSP) )
						If GU3->GU3_CONISS == "1"
							cAliqIss := Posicione("GU3", 1, xFilial("GU3") + cCidOri, "GU3_PCISS")
							If Empty(cAliqIss)
								cAliqIss := Posicione("GU7", 1, xFilial("GU7") + cCidOri, "GU7_PCISS")
							EndIf
						EndIf

						GWF->GWF_IMPOST := "2"

						If cMV_CALCIMP == "1" .And. cAdIcmsFre == "1"
							GWF->GWF_BASISS := nTotCompCa / (1 - (cAliqIss/100))
						Else
							GWF->GWF_BASISS :=  nTotCompCa
						EndIf
						GWF->GWF_PCISS  := cAliqIss

						nVlrImp := (GWF->GWF_PCISS/100) * GWF->GWF_BASISS
						GWF->GWF_VLISS  := nVlrImp

						// Zerando valores de ICMS para nao listar do calculo original
						GWF->GWF_BASICM := 0
						GWF->GWF_PCICMS := 0
						GWF->GWF_PCREIC := 0
						GWF->GWF_VLICMS := 0
					Endif

					// Atribuição dos valores de frete aos componentes do novo cálculo
					If nVlrImp > 0 .And. cAdIcmsFre == "1"
						If cRatImp == "1"
							GWI->(dbSetOrder(1))
							GWI->(dbSeek(xFilial("GWI") + cNrCalc))
							Do While !GWI->(Eof()) .And. xFilial("GWI") + GWI->GWI_NRCALC == xFilial("GWF") + cNrCalc

								GUY->( dbSetOrder(1) )
								GUY->( dbSeek(xFilial("GUY") + cEmitTab + cNrTab + cNrNegoc + GWI->GWI_CDCOMP) )
								If GUY->GUY_REENT <> "2"
									RecLock( "GWI", .F. )
									If GFXCP12130("GWI_VLLIQ")
										GWI->GWI_VLFRET := GWI->GWI_VLLIQ + ( ((nVlrImp * GWI->GWI_VLLIQ) / nTotCompCa) )
									Else
										GWI->GWI_VLFRET := GWI->GWI_VLFRET + ( ((nVlrImp * GWI->GWI_VLFRET) / nTotCompCa) )
									EndIf
									GWI->(MsUnlock())
								EndIf

								GWI->(dbSkip())
							EndDo
						Else
							cAliasGWI := GetNextAlias()

							BeginSQL Alias cAliasGWI
									SELECT GWI.R_E_C_N_O_ RECNOGWI
									FROM %Table:GWI% GWI
									WHERE GWI.GWI_FILIAL = %Exp:GWF->GWF_FILIAL%
									AND GWI.GWI_NRCALC = %Exp:GWF->GWF_NRCALC%
									AND GWI.GWI_CDCOMP = %Exp:cCompImp%
									AND GWI.%NotDel%
							EndSQL

							If (cAliasGWI)->(!Eof())
								GWI->(dbGoTo((cAliasGWI)->RECNOGWI))

								RecLock( "GWI", .F. )
								GWI->GWI_VLFRET := nVlrImp
								GWI->(MsUnlock())
							EndIf

							(cAliasGWI)->(dbCloseArea())
						EndIf
					EndIf
				Else
					If GWF->GWF_IMPOST == "1"	// ICMS
						If cICMSPT == "1"
							nImpPaut := GFEICMPAUT(GWF->GWF_TRANSP,;
								GWF->GWF_EMIREM, ; // Código do remetente
							GWF->GWF_EMIDES,; // Código do destinatario
							cCidOri,;
								cCidDest,; // Número da cidade de destino
							cTpClass,; // Classificação de frete
							cTipOper,;
								nTotPeso,;
								.F.)
						EndIf

						If nImpPaut > nTotCompCa
							GWF->GWF_BASICM := nImpPaut
						Else
							GWF->GWF_BASICM := nTotCompCa
						EndIf
						GWF->GWF_VLICMS := (GWF->GWF_BASICM * (GWF->GWF_PCICMS/100))
					Else
						GWF->GWF_BASISS :=  nTotCompCa
						GWF->GWF_VLISS  :=  (GWF->GWF_PCISS/100) * GWF->GWF_BASISS
					EndIf
				EndIf
			Else					// mantem tratamento original
				If GWF->GWF_IMPOST == "1"	// ICMS
					If cICMSPT == "1"
						nImpPaut := GFEICMPAUT(GWF->GWF_TRANSP,;
							GWF->GWF_EMIREM, ; // Código do remetente
						GWF->GWF_EMIDES,; // Código do destinatario
						cCidOri,;
							cCidDest,; // Número da cidade de destino
						cTpClass,; // Classificação de frete
						cTipOper,;
							nTotPeso,;
							.F.)
					EndIf

					If nImpPaut > nTotCompCa
						GWF->GWF_BASICM := nImpPaut
					Else
						GWF->GWF_BASICM := nTotCompCa
					EndIf
					GWF->GWF_VLICMS := (GWF->GWF_BASICM * (GWF->GWF_PCICMS/100))
				Else
					GWF->GWF_BASISS :=  nTotCompCa
					GWF->GWF_VLISS  :=  (GWF->GWF_PCISS/100) * GWF->GWF_BASISS
				Endif
			EndIf
		Else
			If cMV_CALCIMP == "1" .And. GFXCP12130("GWI_VLLIQ")
				cAliasGWI := GetNextAlias()

				BeginSQL Alias cAliasGWI
						SELECT SUM(GWI.GWI_VLLIQ) GWI_VLLIQ
						FROM %Table:GWI% GWI
						WHERE GWI.GWI_FILIAL = %Exp:GWF->GWF_FILIAL%
						AND GWI.GWI_NRCALC = %Exp:GWF->GWF_NRCALC%
						AND GWI.%NotDel%
				EndSQL

				If (cAliasGWI)->(!EoF())
					nTotCompCa := (cAliasGWI)->GWI_VLLIQ
				EndIf

				(cAliasGWI)->(dbCloseArea())
			EndIf

			cCdTrp   := GWF->GWF_TRANSP
			cCdRem   := GWF->GWF_EMIDES
			cCdDest  := GWF->GWF_EMIREM
			cOrigem  := GWF->GWF_CIDORI
			cDestin  := GWF->GWF_CIDDES

			cTipOper := Posicione("GWN", 1, xFilial("GWN") + GWF->GWF_NRROM, "GWN_CDTPOP")
			cTpClass := Posicione("GWN", 1, xFilial("GWN") + GWF->GWF_NRROM, "GWN_CDCLFR")

			GFEXFB_BORDER(.F.,'',01,11)
			GFEXFB_2TOP(.F.,'', @aTRBSEL, 11)

			GW1->(dbSetOrder(1))
			If GW1->(dbSeek(xFilial("GW1") + GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"CDTPDC") + GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"EMISDC") + GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"SERDC") + GFEXFB_5CMP(.F.,'', @aTRBSEL, 11,"NRDC")))
				GW8->(dbSetOrder(1) )
				If GW8->(dbSeek( xFilial("GW8") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
					cUsoCarga:= GW1->GW1_USO
					cTpItens := GW8->GW8_TPITEM
					cTpClass := GW8->GW8_CDCLFR
					cTribIcms:= GW1->GW1_ICMSDC
					cRomTpOp := Posicione("GWN", 1, xFilial("GWN") + GW1->GW1_NRROM, "GWN_CDTPOP")
				EndIf
			EndIf

			If GWF->GWF_IMPOST == "1"	// ICMS
				// TODO: Verificar o conceito correto de adição de ICMS no frete para reentrega e devolução.
				// Não deveria adicionar o ICMS pois este já vem adicionado sobre o frete original
				//#### Comentado para nao adicionar ICMS no campo base ICMS - chamado TFOLV9 ####
				If cMV_CALCIMP == "1" .And. cTipoCalc == "5" .And. cOriCalc = '2'
					cOrigem := GWF->GWF_CIDDES
					cDestin := GWF->GWF_CIDORI
				EndIf

				cTpOpDoc := Posicione("GWU", 4, xFilial("GWU") + GW1->GW1_NRDC,"GWU_CDTPOP")
				aRet    := GFEFnIcms(cCdTrp, cCdRem, cCdDest, cOrigem, cDestin, cUsoCarga, cTpItens, cTpClass, cTribIcms, IIF(!Empty(cTpOpDoc),cTpOpDoc,cRomTpOp))

				GWF->GWF_PCICMS := aRet[1]
				GWF->GWF_TPTRIB := Iif(aRet[1] > 0, aRet[2], "2")

				If cICMSPT == "1"
					nImpPaut := GFEICMPAUT(cCdTrp,;
						cCdRem, ; // Código do remetente
					cCdDest,; // Código do destinatario
					cOrigem,;
						cDestin,; // Número da cidade de destino
					cTpClass,; // Classificação de frete
					cTipOper,;
						nTotPeso,;
						.F.)
				EndIf

				If nImpPaut > nTotCompCa
					GWF->GWF_BASICM := nImpPaut
				Else
					If cMV_CALCIMP == "1" .And. cAdIcmsFre == "1"
						GWF->GWF_BASICM := nTotCompCa / (1 - (aRet[1]/100))
					Else
						GWF->GWF_BASICM := nTotCompCa
					EndIf
				EndIf

				nVlrImp := GWF->GWF_BASICM  * (aRet[1]/100)
				GWF->GWF_VLICMS := nVlrImp
			Else
				GWF->GWF_IMPOST := "2"

				cAliqIss := 0
				GU3->(dbSetOrder(1) )
				GU3->(dbSeek(xFilial("GU3") + cCdTrp) )
				If GU3->GU3_CONISS == "1"
					cAliqIss := Posicione("GU3", 1, xFilial("GU3") + cOrigem, "GU3_PCISS")
					If Empty(cAliqIss)
						cAliqIss := Posicione("GU7", 1, xFilial("GU7") + cOrigem, "GU7_PCISS")
					EndIf
				EndIf

				If cMV_CALCIMP == "1" .And. cAdIcmsFre == "1"
					GWF->GWF_BASISS := nTotCompCa / (1 - (cAliqIss/100))
				Else
					GWF->GWF_BASISS :=  nTotCompCa
				EndIf

				nVlrImp := (cAliqIss/100) * GWF->GWF_BASISS

				GWF->GWF_PCISS  := cAliqIss
				GWF->GWF_VLISS  := nVlrImp					// GWF->GWF_VLISS  :=  GWF->GWF_BASISS * (GWF->GWF_PCISS/100)
			EndIf

			If cMV_CALCIMP == "1" .And. cTipoCalc == "5" .And. nVlrImp > 0 .And. cAdIcmsFre == "1"
				If cRatImp == "1"
					GWI->(dbSetOrder(1))
					GWI->(dbSeek(xFilial("GWI") + cNrCalc))
					Do While !GWI->(Eof()) .And. xFilial("GWI") + GWI->GWI_NRCALC == xFilial("GWF") + cNrCalc

						GUY->( dbSetOrder(1) )
						GUY->( dbSeek(xFilial("GUY") + cEmitTab + cNrTab + cNrNegoc + GWI->GWI_CDCOMP) )
						If GUY->GUY_REENT <> "2"
							RecLock( "GWI", .F. )
							If GFXCP12130("GWI_VLLIQ")
								GWI->GWI_VLFRET := GWI->GWI_VLLIQ + ( ((nVlrImp * GWI->GWI_VLLIQ) / nTotCompCa) )
							Else
								GWI->GWI_VLFRET := GWI->GWI_VLFRET + ( ((nVlrImp * GWI->GWI_VLFRET) / nTotCompCa) )
							EndIf
							GWI->(MsUnlock())
						EndIf

						GWI->(dbSkip())
					EndDo
				Else
					cAliasGWI := GetNextAlias()

					BeginSQL Alias cAliasGWI
							SELECT GWI.R_E_C_N_O_ RECNOGWI
							FROM %Table:GWI% GWI
							WHERE GWI.GWI_FILIAL = %Exp:GWF->GWF_FILIAL%
							AND GWI.GWI_NRCALC = %Exp:GWF->GWF_NRCALC%
							AND GWI.GWI_CDCOMP = %Exp:cCompImp%
							AND GWI.%NotDel%
					EndSQL

					If (cAliasGWI)->(!Eof())
						GWI->(dbGoTo((cAliasGWI)->RECNOGWI))

						RecLock( "GWI", .F. )
						GWI->GWI_VLFRET := nVlrImp
						GWI->(MsUnlock())
					EndIf

					(cAliasGWI)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
		GWF->GWF_BAPICO :=  nTotCompCa
		GWF->GWF_VLPIS  :=  GWF->GWF_BAPICO * (nPerPisCal/100)
		GWF->GWF_VLCOFI :=  GWF->GWF_BAPICO * (nPerCofCal/100)
	EndIf
	GWF->(MsUnlock())
EndIf

If lRet
	aRetRateio := GFERatCal(.F., cNrCalc)
	If aRetRateio[1] == .F.
		GFEMsgErro(STR0304 + cNrCalc) //"Não foi possível gerar movimentos contábeis para o cálculo: "
	Endif
Endif

If lRet .and. !empty(cTransp)
	GWF->(dbSetOrder(01))
	If GWF->(dbSeek(xFilial("GWF")+cNrCalc))
		cAliasGWM := GetNextAlias()

		BeginSql Alias cAliasGWM
				SELECT GWM.R_E_C_N_O_ RECNOGWM
				FROM %Table:GWL% GWL
				INNER JOIN %table:GWM% GWM 
				ON GWM.GWM_FILIAL		= GWL.GWL_FILDC
				AND GWM.GWM_CDTPDC		= GWL.GWL_TPDC
				AND GWM.GWM_EMISDC		= GWL.GWL_EMITDC
				AND GWM.GWM_SERDC		= GWL.GWL_SERDC
				AND GWM.GWM_NRDC		= GWL.GWL_NRDC
				AND GWM.GWM_NRDOC		= %Exp:cNrCalc%
				AND GWM.%NotDel%
				WHERE GWL.GWL_FILIAL 	= %xFilial:GWL% 
				AND GWL.GWL_NROCO 	= %Exp:cOcor%
				AND GWL.%NotDel%
		EndSql

		Do While (cAliasGWM)->(!Eof())
			GWM->(dbGoTo((cAliasGWM)->RECNOGWM))
			RecLock( "GWM", .F. )
			GWM->GWM_CDTRP := cTransp
			GWM->(MsUnlock())
			(cAliasGWM)->(dbSkip())
		EndDo
		(cAliasGWM)->(dbCloseArea())

		GWA->(dbSetOrder(03))
		If GWA->(dbSeek(xFilial("GWA")+'1'+cNrCalc))
			RecLock( "GWA", .F. )
			GWA->GWA_CDEMIT := cTransp
			GWA->(MsUnlock())
		EndIf

		RecLock( "GWF", .F. )
		GWF->GWF_TRANSP := cTransp
		GWF->(MsUnlock())
	EndIf
Endif

Finalizar(lRet, cNrCalc, aArea, aTRBSEL)

Return lRet

/*----------------------------------------------------------------------------
Retorna os percentuais de reentrega e devolução e o máximo de reentrega das tabelas
usadas no cálculo de frete informado.
----------------------------------------------------------------------------*/
Function GFEPcReenDev(cNrCalculo,cTpCalc )

	Local aPcReenDev := {0,999999999,0,0,'','','','',''}
	Local nValor
	Local cValor
	Local cEmitTab
	Local cNrTab

	If ExistBlock('GFEXFB25')
		ExecBlock("GFEXFB25",.F.,.F.,{ cNrCalculo, cTpCalc })
	EndIf

	GWG->(dbSetOrder(01))
	If GWG->(dbSeek(xFilial("GWG")+cNrCalculo))
		While !GWG->(Eof()) .AND. xFilial("GWG")+GWG->GWG_NRCALC == xFilial("GWF")+cNrCalculo

			// Retorna o emitente e tabela corretos, dependendo do tipo da tabela (normal ou vinculo)
			aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
			cEmitTab := aInfoTab[2]
			cNrTab   := aInfoTab[3]

			nValor := Posicione("GV8",1,xFilial("GV8")+PadR(cEmitTab, TamSX3("GV8_CDEMIT")[1])+PadR(cNrTab, TamSX3("GV8_NRTAB")[1])+GWG->GWG_NRNEG+GWG->GWG_NRROTA,"GV8_PCREEN")
			If nValor > aPcReenDev[1]
				aPcReenDev[1] := nValor
				If cTpCalc == "4"
					aPcReenDev[6] := cEmitTab
					aPcReenDev[7] := cNrTab
					aPcReenDev[8] := GWG->GWG_NRNEG
					aPcReenDev[9] := GWG->GWG_NRROTA
				EndIf
			EndIf
			
			nValor := Posicione("GV8",1,xFilial("GV8")+PadR(cEmitTab, TamSX3("GV8_CDEMIT")[1])+PadR(cNrTab, TamSX3("GV8_NRTAB")[1])+GWG->GWG_NRNEG+GWG->GWG_NRROTA,"GV8_VLMXRE")

			aPcReenDev[2] := nValor
			If cTpCalc == "5"
				aPcReenDev[6] := cEmitTab
				aPcReenDev[7] := cNrTab
				aPcReenDev[8] := GWG->GWG_NRNEG
				aPcReenDev[9] := GWG->GWG_NRROTA
			EndIf

			nValor := Posicione("GV8",1,xFilial("GV8")+PadR(cEmitTab, TamSX3("GV8_CDEMIT")[1])+PadR(cNrTab, TamSX3("GV8_NRTAB")[1])+GWG->GWG_NRNEG+GWG->GWG_NRROTA,"GV8_PCDEV")
			aPcReenDev[3] := Max(aPcReenDev[3], nValor)

			If GfeVerCmpo({"GV8_VLMINR"})
				nValor := Posicione("GV8",1,xFilial("GV8")+PadR(cEmitTab, TamSX3("GV8_CDEMIT")[1])+PadR(cNrTab, TamSX3("GV8_NRTAB")[1])+GWG->GWG_NRNEG+GWG->GWG_NRROTA,"GV8_VLMINR")
				aPcReenDev[4] := Max(aPcReenDev[4], nValor)
			Endif

			If cTpCalc == "4" .And. GfeVerCmpo({"GV8_TRPREE"})
				cValor := Posicione("GV8",1,xFilial("GV8")+PadR(cEmitTab, TamSX3("GV8_CDEMIT")[1])+PadR(cNrTab, TamSX3("GV8_NRTAB")[1])+GWG->GWG_NRNEG+GWG->GWG_NRROTA,"GV8_TRPREE")
				aPcReenDev[5] := if(!Empty(cValor),cValor,aPcReenDev[5])
			EndIf
			
			If Empty(aPcReenDev[6]) //devolução ou reentrega não preenchidos
				aPcReenDev[6] := cEmitTab
				aPcReenDev[7] := cNrTab
				aPcReenDev[8] := GWG->GWG_NRNEG
				aPcReenDev[9] := GWG->GWG_NRROTA
			EndIf

			GWG->(dbSkip())
		EndDo
	EndIf

Return aPcReenDev

/*-------------------------------------------------------------------
Retorna o valor de servico da tabela do cálculo informado
-------------------------------------------------------------------*/
Function GFEVlServ(cNrCalc, cFilOco, cNrOco)
	Local nVlServ  := 0
	Local aInfoTab := {}
	Local cEmitTab := ""
	Local cNrTab   := ""
	Local lSair    := .F. // Variavel de controle, indica que encontrou componente de serviço
	Local aAreaGWD
	Local cCompServ := ""	// Componente de Serviço Customizado - XGFEOCSV
	Local cCompEnco := ""
	Local cNrNeg 	:= ""
	Local cNrRota 	:= ""
	Local cCdFaixa 	:= ""
	Default cFilOco := xFilial("GWD")
	Default cNrOco  := ""
	If Type("GFELog032") != "O"
		GFELog032 := GFELogMock():New()
	EndIf
	
	If ExistBlock("XGFEOCSV")
		aAreaGWD := GWD->(GetArea())
		GWD->(dbSetOrder(1))
		If GWD->(dbSeek(cFilOco + cNrOco))
			GU5->(dbSetOrder(1))
			If GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO))
				If GU5->GU5_TPCALC == "3"
					cCompServ := ExecBlock("XGFEOCSV",.f.,.f.,{GWD->GWD_FILIAL, GWD->GWD_NROCO, GWD->GWD_CDTIPO, GWD->GWD_CDMOT})
				EndIf
			Endif
		EndIf
		RestArea(aAreaGWD)
	EndIf

	GWG->(dbSetOrder(01))
	GWG->(dbSeek(xFilial("GWG")+cNrCalc))
	While !GWG->(Eof())                   .AND.;
		!lSair                            .AND.;
		GWG->GWG_FILIAL == xFilial("GWG") .AND.;
		GWG->GWG_NRCALC == cNrCalc

		// Verifica se a tabela é normal ou de vinculo
		aInfoTab := GFEInfoTab(GWG->GWG_CDEMIT, GWG->GWG_NRTAB)
		cEmitTab := aInfoTab[2]
		cNrTab   := aInfoTab[3]

		GV1->(dbSetOrder(01))
		If GV1->(dbSeek(xFilial("GV1")+cEmitTab+cNrTab+GWG->GWG_NRNEG+GWG->GWG_CDFXTV+GWG->GWG_NRROTA))
			While !GV1->(Eof()) .AND.;
			xFilial("GV1")  == GV1->GV1_FILIAL .AND.;
			cEmitTab        == GV1->GV1_CDEMIT .AND.;
			cNrTab          == GV1->GV1_NRTAB  .AND.;
			GWG->GWG_NRNEG  == GV1->GV1_NRNEG  .AND.;
			GWG->GWG_CDFXTV == GV1->GV1_CDFXTV .AND.;
			GWG->GWG_NRROTA == GV1->GV1_NRROTA

				// Componente da tarifa da tabela base é de Serviço
				If Posicione("GV2",1,xFilial("GV2")+GV1->GV1_CDCOMP,"GV2_SERVI") == "1"
					// XGFEOCSV
					If !Empty(cCompServ)
						If AllTrim(cCompServ) == AllTrim(GV1->GV1_CDCOMP)
							nVlServ := GV1->GV1_VLFIXN
							lSair := .T.
							GFELog032:NewLine()
							GFELog032:Add("Componente encontrado: " +  GV1->GV1_CDCOMP + " - Valor: " + Transform(GV1->GV1_VLFIXN,"@E 999,999,999.99"))
							GFELog032:Add("Emitente..: " + cEmitTab + " - Tabela: " + cNrTab)
							GFELog032:Add("Negociação: " + GWG->GWG_NRNEG + " - Rota: " + GWG->GWG_NRROTA)
							GFELog032:Add("Faixa.....: " + GWG->GWG_CDFXTV )
							Exit
						EndIf

						// Garante que pelo menos o primeiro componente seja escolhido
						If !lSair .AND. nVlServ == 0
							nVlServ := GV1->GV1_VLFIXN
							cCompEnco := GV1->GV1_CDCOMP
							cNrNeg := GWG->GWG_NRNEG
							cNrRota := GWG->GWG_NRROTA
							cCdFaixa := GWG->GWG_CDFXTV
						EndIf
					Else
						GFELog032:NewLine()
						GFELog032:Add("Componente encontrado: " +  GV1->GV1_CDCOMP + " - Valor: " + Transform(GV1->GV1_VLFIXN,"@E 999,999,999.99"))
						GFELog032:Add("Emitente..: " + cEmitTab + " - Tabela: " + cNrTab)
						GFELog032:Add("Negociação: " + GWG->GWG_NRNEG + " - Rota: " + GWG->GWG_NRROTA)
						GFELog032:Add("Faixa.....: " + GWG->GWG_CDFXTV )
						nVlServ := GV1->GV1_VLFIXN
						lSair := .T.
						Exit
					EndIf
				EndIf

				GV1->(dbSkip())
			EndDo
		EndIf
		GWG->(dbSkip())
	EndDo
	
	If !Empty(cCompEnco) .And. !lSair
		GFELog032:NewLine()
		GFELog032:Add("Componente encontrado: " +  cCompEnco + " - Valor: " + Transform(nVlServ,"@E 999,999,999.99"))
		GFELog032:Add("Emitente..: " + cEmitTab + " - Tabela: " + cNrTab)
		GFELog032:Add("Negociação: " + cNrNeg + " - Rota: " + cNrRota)
		GFELog032:Add("Faixa.....: " + cCdFaixa )
	EndIf

Return nVlServ

/*----------------------------------------------------------------------------
----------------------------------------------------------------------------*/
Static Function Finalizar(lOk, cNrCalc, aArea, aTRBSEL)
	
	If !lOk
		GWF->(dbSetOrder(01))
		If GWF->(dbSeek(xFilial("GWF")+cNrCalc))
			RecLock( "GWF", .F. )
				GWF->(dbDelete())
			GWF->(MsUnlock())
		EndIf

		GWG->(dbSetOrder(01))
		GWG->(dbSeek(xFilial("GWG")+cNrCalc))
		While !GWG->(Eof()) .AND. GWG->GWG_NRCALC == cNrCalc
			RecLock( "GWG", .F. )
				GWG->(dbDelete())
			GWG->(MsUnlock())
			GWG->(dbSkip())
		EndDo

		GWH->(dbSetOrder(01))
		GWH->(dbSeek(xFilial("GWH")+cNrCalc))
		While !GWH->(EOF()) .and. GWH->GWH_NRCALC == cNrCalc
			RecLock( "GWH", .F. )
				GWH->(dbDelete())
			GWH->(MsUnlock())
			GWH->(dbSkip())
		EndDo

		GWI->(dbSetOrder(01))
		GWI->(dbSeek(xFilial("GWI")+cNrCalc))
		While !GWI->(EOF())  .and. GWI->GWI_NRCALC == cNrCalc
			RecLock( "GWI", .F. )
				GWI->(dbDelete())
			GWI->(MsUnlock())
			GWI->(dbSkip())
		EndDo
	Endif
	IIF(aTRBSEL==NIL,,aSize(aTRBSEL,0))
	aTRBSEL := {}
	RestArea( aArea )

Return NIL

/*----------------------------------------------------------------------------
Retorna a estrutura da tabela temporária de documentos de carga
----------------------------------------------------------------------------*/
Static Function GetStrNfSel()

	Local aNfSel := {	{"EMISDC", "C", TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente do Documento
						{"SERDC" , "C", TamSX3("GW1_SERDC")[1] ,0},; //Serie do Documento
						{"NRDC"  , "C", TamSX3("GW1_NRDC")[1] ,0},; //Numero do Documento
						{"CDTPDC", "C", TamSX3("GW1_CDTPDC")[1] ,0}}  //Tipo de documento de carga

	aIndexes := {"CDTPDC+EMISDC+SERDC+NRDC"}

Return {aNfSel,aIndexes}

/*----------------------------------------------------------------------------
Cria o cálculo complementar
----------------------------------------------------------------------------*/
Function GFECalComp(aCompDF,cTpCal,cEmisDF,CNrDF,cSerDF,cTipoDF,cEspecie,dDtEmissao,nAliqImpDC,nValImpDC,nBaseCalcN,nAliqICMS,nAliqISS)
	Local nX
	local lRet 		   	:= .T.
	local cCodCalc   	:= GETSXENUM("GWF","GWF_NRCALC")
	Local nVlTotCoDC 	:= 0
	Local nPerPis    	:= SuperGetMV('MV_PCPIS',,'1')
	Local nPerCof    	:= SuperGetMV('MV_PCCOFI',,'1')
	Local cAliasGWF  	:= Nil
	Local cCidOrigem 	:= ""
	Local cCidDestin 	:= ""
	Local cSeqTrecho 	:= ""
	Local cPagador 		:= ""
	Local cTpFrete 		:= ""
	Local cTpTrib 		:= ""
	Local cGerCredICMS 	:= ""
	Local nLen       	:= 0

	// As três variáveis a seguir são utilizadas pela função SaveLog()
	Private cArqLog
	Private cTxtLog  := "" // Variável utilizada em todo o programa para geracao de arquivo de log
	Private lSaveLog := Iif(SuperGetMV("MV_LOGCALC",,'1') == '2',.F., .T.) //Indica se será gerado ou não o log de cálculo
	Private oGFEXFBFLog := GFEXFBFLog():New()

	GW3->(dbSetOrder(01))
	If GW3->(dbSeek(xFilial("GW3")+cEspecie+cEmisDF+cSerDF+CNrDF+dtos(dDtEmissao)))
		
		// Consulta calculo do Doc. Frete para identificar o trecho
		cAliasGWF := GetNextAlias()
		BeginSql Alias cAliasGWF
			SELECT GWF_SEQTRE
			     , GWF_CIDORI
				 , GWF_CIDDES
				 , GWF_EMIPAG
				 , GWF_TPFRET
				 , GWF_TPTRIB
				 , GWF_CRDICM
			FROM %Table:GWF% GWF
			WHERE GWF.GWF_FILIAL = %Exp:GW3->GW3_FILIAL%
			AND GWF.GWF_CDESP = %Exp:GW3->GW3_CDESP%
			AND GWF.GWF_EMISDF = %Exp:GW3->GW3_EMISDF%
			AND GWF.GWF_SERDF = %Exp:GW3->GW3_SERDF%
			AND GWF.GWF_NRDF = %Exp:GW3->GW3_NRDF%
			AND GWF.GWF_DTEMDF = %Exp:GW3->GW3_DTEMIS%
			AND GWF.%NotDel%
		EndSql
		If (cAliasGWF)->(!Eof())
			cCidOrigem := (cAliasGWF)->GWF_CIDORI
			cCidDestin := (cAliasGWF)->GWF_CIDDES
			cSeqTrecho := (cAliasGWF)->GWF_SEQTRE
			cPagador := (cAliasGWF)->GWF_EMIPAG
			cTpFrete := (cAliasGWF)->GWF_TPFRET
			cTpTrib := (cAliasGWF)->GWF_TPTRIB
			cGerCredICMS := (cAliasGWF)->GWF_CRDICM
		EndIf
		(cAliasGWF)->(dbCloseArea())		
		
		//GRAVA AS INFORMACOES DE TODAS AS TABELAS REFERENTES AO CALCULO
		GWF->(dbSetOrder(01))

		RecLock("GWF",.T.)
			GWF->GWF_FILIAL := xFilial("GWF")
			GWF->GWF_NRCALC := cCodCalc
			GWF->GWF_EMIREM := GW3->GW3_CDREM
			GWF->GWF_EMIDES := GW3->GW3_CDDEST
			GWF->GWF_TRANSP := GW3->GW3_EMISDF
			GWF->GWF_ORIGEM := "2"
			GWF->GWF_TPCALC := cTpCal 
			GWF->GWF_EMIPAG := cPagador
			GWF->GWF_TPFRET := cTpFrete
			GWF->GWF_TPTRIB := cTpTrib
			GWF->GWF_CRDICM := cGerCredICMS
			GWF->GWF_DTCRIA := DDATABASE
			GWF->GWF_HRCRIA := SubStr(TIME(), 1, 5)
			GWF->GWF_AGRUP  := "2"
			GWF->GWF_USUCRI := cUserName
			GWF->GWF_CIDORI := cCidOrigem
			GWF->GWF_CIDDES := cCidDestin
			GWF->GWF_SEQTRE := cSeqTrecho
			GWF->GWF_IDFRVI := "2"
		GWF->(MsUnLock())

		GW4->(dbSetOrder(01))
		GW4->(dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+dtos(GW3->GW3_DTEMIS)))
		While !GW4->(Eof()) .and. GW4->GW4_NRDF == GW3->GW3_NRDF .and. GW4->GW4_EMISDF == GW3->GW3_EMISDF .and. GW4->GW4_CDESP == GW3->GW3_CDESP .and. GW4->GW4_SERDF == GW3->GW3_SERDF

			RecLock("GWH",.T.)
				GWH->GWH_FILIAL := xFilial("GWH")
				GWH->GWH_NRCALC := GWF->GWF_NRCALC
				GWH->GWH_CDTPDC := GW4->GW4_TPDC
				GWH->GWH_EMISDC := GW4->GW4_EMISDC
				GWH->GWH_SERDC  := GW4->GW4_SERDC
				GWH->GWH_NRDC   := GW4->GW4_NRDC
				GWH->GWH_TRECHO := cSeqTrecho
			GWH->(MsUnLock())

			GW4->(dbSkip())
		EndDo

		GW1->(dbSetOrder(01))
		GW1->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
		
		If cTpCal == "2"
			nLen := Len(aCompDF)
			For nX := 1 To nLen
				GWI->(dbSetOrder(01))
				If !Empty(aCompDF[nX,2] )
					RecLock("GWI",.T.)
					GWI->GWI_FILIAL := xFilial("GWI")
					GWI->GWI_NRCALC := GWF->GWF_NRCALC
					GWI->GWI_CDCOMP := aCompDF[nX,2]
					GWI->GWI_VLFRET := aCompDF[nX,3]
					GWI->GWI_TOTFRE := "1"
					GWI->(MsUnLock())
					nVlTotCoDC += GWI->GWI_VLFRET
				Endif
			Next nX

			GWF->(dbSetOrder(01))
			If GWF->(dbSeek(xFilial("GWF")+cCodCalc))
				GVT->(dbSetOrder(01))
				If GVT->(dbSeek(xFilial("GVT")+cEspecie))
					If GVT->GVT_TPIMP == "1" // ICMS
						RecLock("GWF",.F.)
							GWF->GWF_BASICM 	:= nVlTotCoDC
							GWF->GWF_PCICMS 	:= nAliqICMS
							GWF->GWF_VLICMS 	:= GFETratDec(nVlTotCoDC * (nAliqICMS/100),0,.T.)
							GWF->GWF_IMPOST  	:= GVT->GVT_TPIMP
							GWF->GWF_BAPICO 	:= nVlTotCoDC
							GWF->GWF_VLPIS  	:= GFETratDec(nVlTotCoDC * (nPerPis/100),0,.T.)
							GWF->GWF_VLCOFI 	:= GFETratDec(nVlTotCoDC * (nPerCof/100),0,.T.)
							If GFXCP1212210('GWF_FILROM') .And. GFXCP1212210('GW1_FILROM')
								GWF->GWF_FILROM	:= GW1->GW1_FILROM
							EndIf
							GWF->GWF_NRROM 		:= GW1->GW1_NRROM
							GWF->GWF_FINCAL  	:= "1"
						GWF->(MsUnLock())
					Elseif GVT->GVT_TPIMP == "2" //ISS
						RecLock("GWF",.F.)
							GWF->GWF_BASISS 	:= nVlTotCoDC //nBaseCalcN
							GWF->GWF_PCISS  	:= nAliqISS
							GWF->GWF_VLISS  	:= GFETratDec(nVlTotCoDC * (nAliqISS/100),0,.T.)
							GWF->GWF_IMPOST 	:= GVT->GVT_TPIMP
							GWF->GWF_BAPICO 	:= nVlTotCoDC
							GWF->GWF_VLPIS  	:= GFETratDec( nVlTotCoDC * (nPerPis/100),0,.T.)
							GWF->GWF_VLCOFI 	:= GFETratDec( nVlTotCoDC * (nPerCof/100),6,.T.)
							If GFXCP1212210('GWF_FILROM') .And. GFXCP1212210('GW1_FILROM')
								GWF->GWF_FILROM	:= GW1->GW1_FILROM
							EndIf
							GWF->GWF_NRROM 		:= GW1->GW1_NRROM
							GWF->GWF_FINCAL  	:= "2"
						GWF->(MsUnLock())
					ElseIf GVT->GVT_TPIMP == "3" //Nenhum
						RecLock("GWF",.F.)
							If GFXCP1212210('GWF_FILROM') .And. GFXCP1212210('GW1_FILROM')
								GWF->GWF_FILROM	:= GW1->GW1_FILROM
							EndIf
							GWF->GWF_NRROM	:= GW1->GW1_NRROM
							GWF->GWF_FINCAL := "1"
						GWF->(MsUnLock())
					Endif
				Endif
			Endif

		Elseif cTpCal == "3"

			For nX := 1 To 1
				GWI->(dbSetOrder(01))
				If !empty(aCompDF[nX,2] )
					RecLock("GWI",.T.)
					GWI->GWI_FILIAL := xFilial("GWI")
					GWI->GWI_NRCALC := GWF->GWF_NRCALC
					GWI->GWI_CDCOMP := aCompDF[nX,2]
					GWI->GWI_VLFRET := 0	// nValImpDC
					GWI->GWI_TOTFRE := "1"
					GWI->(MsUnLock())
					nVlTotCoDC += GWI->GWI_VLFRET
				EndIf
			Next nX

			GWF->(dbSetOrder(01))
			If GWF->(dbSeek(xFilial("GWF")+cCodCalc))
				GVT->(dbSetOrder(01))
				If GVT->(dbSeek(xFilial("GVT")+cEspecie))
					If GVT->GVT_TPIMP == "1" // ICMS
						RecLock("GWF",.F.)
						GWF->GWF_BASICM 	:= nBaseCalcN
						GWF->GWF_PCICMS 	:= nAliqImpDC
						GWF->GWF_VLICMS 	:= GFETratDec(nValImpDC,0,.T.)
						GWF->GWF_IMPOST	:= GVT->GVT_TPIMP
						GWF->GWF_BAPICO 	:= nValImpDC
						GWF->GWF_VLPIS  	:= GFETratDec(nValImpDC * (nPerPis/100),0,.T.)
						GWF->GWF_VLCOFI 	:= GFETratDec(nValImpDC * (nPerCof/100),0,.T.)
						If GFXCP1212210('GWF_FILROM') .And. GFXCP1212210('GW1_FILROM')
							GWF->GWF_FILROM	:= GW1->GW1_FILROM
						EndIf
						GWF->GWF_NRROM 	:= GW1->GW1_NRROM
						GWF->(MsUnLock())
					ElseIf GVT->GVT_TPIMP == "2" //ISS
						RecLock("GWF",.F.)
						GWF->GWF_BASISS 	:= nBaseCalcN
						GWF->GWF_PCISS  	:= nAliqImpDC
						GWF->GWF_VLISS  	:= GFETratDec( nValImpDC,0,.T.)
						GWF->GWF_IMPOST 	:= GVT->GVT_TPIMP
						GWF->GWF_BAPICO 	:= nValImpDC
						GWF->GWF_VLPIS  	:= GFETratDec(nValImpDC * (nPerPis/100),0,.T.)
						GWF->GWF_VLCOFI 	:= GFETratDec(nValImpDC * (nPerCof/100),0,.T.)
						If GFXCP1212210('GWF_FILROM') .And. GFXCP1212210('GW1_FILROM')
							GWF->GWF_FILROM	:= GW1->GW1_FILROM
						EndIf
						GWF->GWF_NRROM 	:= GW1->GW1_NRROM 
						GWF->(MsUnLock())
					Endif
				Endif
			Endif
		Endif
	Endif

	ConfirmSX8()
	If lRet
		aRetRateio := GFERatCal(.F., cCodCalc)
		If aRetRateio[1] == .F.
			Alert(STR0304 + cCodCalc) //"Não foi possível gerar movimentos contábeis para o cálculo: "
		Endif

		MsgInfo(STR0553 + CRLF + STR0554 + " " + cCodCalc, "Cálculo de Frete") // "Cálculo gerado com sucesso!" "Número do novo cálculo: "######"
	EndIf
	oGFEXFBFLog:Destroy()

Return lRet

/*----------------------------------------------------------------------------
Cria copia de um registro da tabela informada
----------------------------------------------------------------------------*/
Function GFEXCOPREG( cTabela, aCposAlt )
	Local aStru   := (cTabela)->(dbStruct() )
	Local aDados  := {}
	Local nI      := 0
	Local nPosOri := (cTabela)->( Recno() )
	Local nAux    := 0
	Local aArea   := GetArea()

	For nI := 1 To Len( aStru )
		aAdd( aDados, { PadR( aStru[nI][1], 10 ), (cTabela)->( FieldGet( nI ) ) } )
	Next

	For nI := 1 To Len( aCposAlt )
		If ( nAux := aScan( aDados, { |x| x[1] == PadR( aCposAlt[nI][1], 10 ) } ) ) > 0
			aDados[nAux][2] := aCposAlt[nI][2]
		Endif
	Next

	RecLock( cTabela, .T. )
	For nI := 1 To Len( aDados )
		(cTabela)->(FieldPut( nI, aDados[nI][2] ) )
	Next
	(cTabela)->(MsUnlock())

	(cTabela)->(dbGoTo( nPosOri ) )

	RestArea( aArea )
Return NIL

/*----------------------------------------------------------------------------
Retorna o valor da taxa de suframa, de acordo com a data de referencia e o valor
de mercadoria informados
----------------------------------------------------------------------------*/
Function GFEVlSuframa(dDtRef, nVlMerc)

	Local nVlSuframa := 0
	Local cFiltro    := ""

	GVN->(dbSetOrder(1))
	GVN->(dbSetFilter({|| DTOS(GVN->GVN_INIVIG) <= DTOS(dDtRef)},""))
	If GVN->(dbSeek(xFilial("GVN")))
		While !GVN->(Eof()) .AND. xFilial("GVN") == GVN->GVN_FILIAL

			If DTOS(GVN->GVN_FINVIG) >= DTOS(dDtRef) .OR. Empty(GVN->GVN_FINVIG)

				cFiltro := GVN->GVN_FILIAL+GVN->GVN_TABSUF
				GVO->(dbSetOrder(1))
				GVO->(dbSetFilter({|| GVO->GVO_FILIAL+GVO->GVO_TABSUF == cFiltro .AND. GVO->GVO_VALINI <= nVlMerc .AND. GVO->GVO_VALFIN >= nVlMerc},""))
				GVO->(dbGoTop())
				If !GVO->(Eof())
					nVlSuframa := GVO->GVO_VALTAX
				EndIf
				GVO->(dbClearFilter())
			EndIf

			GVN->(dbSkip())
		EndDo
	EndIf

	GVN->(dbClearFilter())

Return nVlSuframa

/*----------------------------------------------------
Função para validar se uma unidade de cálculo
possui diferentes tipos de aplicação de pedágio
cPedRom -> String com os RecNo's das tabelas de frete separados por vírgula
cUniCalc -> Número da unidade de cálculo apenas para informar no log
lReal -> Se a operação é real ou simulação, pois, na simulação não encerra o cálculo
----------------------------------------------------*/

Function GFEAPPEDUC(cPedRom, cUniCalc, lReal) //VldAplicPedUC
	Local aAux
	Local nX
	Local aPedRom := {}
	Local cPed
	Local aAreaTCF := GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5) 

	If Empty(cPedRom)
		Return
	EndIf

	aAux := StrTokArr(cPedRom,",")

	For nX := 1 to Len(aAux)
		GFEXFB_HGOTO(lTabTemp, cTRBTCF, 5, Val(aAux[nX])) 

		AAdd(aPedRom, Posicione("GV9", 1, xFilial("GV9") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"), "GV9_PEDROM"))

	Next nX

	cPed := aPedRom[1]

	If AScan(aPedRom,{|x| x != cPed}) != 0

		If lReal
			AddToLog(CRLF + "    *** A Unidade de Cálculo " + cUniCalc + " possui Rotas com Negociações de valores Aplicação de Pedágio diferentes." + ;
			"O cálculo não será realizado!!!" + CRLF)
			GFEXFBAEC(cUniCalc, 15)
			lError := .T.
		Else
			AddToLog(CRLF + "    *** A Unidade de Cálculo " + cUniCalc + " possui Rotas com Negociações de valores Aplicação de Pedágio diferentes." + CRLF)
		EndIf

	EndIf

	GFEXFB_ARESTAREA(lTabTemp,aAreaTCF,5) //RestArea(aAreaTCF)

Return

/*----------------------------------------------------
Função que lista os possíveis erros do cálculo de frete
e retorna o problema e solução conforme o número do erro
passado por parâmetro. Pode se utilzar de parametros
como posicoes de array, usado na GFEXFBAEC, para mostrar
algum valor dinamico,ex:
valor do cálculo [1] ultrapassa o limite [2] parametrizado
----------------------------------------------------*/

Function GFECalcErr(nErr)
	Local aErr := {}

	Do Case
		Case nErr == 1
			aErr := { ;
			;//Problema
			"Parâmetro 'Emitente da Tabela de Provisão' (MV_EMIPRO) não foi definido ou não possui valor!", ;
			;//Solução
			"Para realizar gerar os Cálculos de Frete com finalidade exclusiva de provisionamento " + ;
			"o código do Emitente da Tabela de Frete a ser usada deve ser informado nos Parâmetros " + ;
			"do Módulo (ou pelo módulo Configurador, parâmetro MV_EMIPRO).", ;
			;//Alerta
			"";
			}
		Case nErr == 2
			aErr := { ;
			;//Problema
			"Parâmetro 'Tabela de Provisão' (MV_TABPRO) não foi definido ou não possui valor!", ;
			;//Solução
			"Para realizar gerar os Cálculos de Frete com finalidade exclusiva de provisionamento " + ;
			"o número da Tabela de Frete a ser usada deve ser informado nos Parâmetros do Módulo " + ;
			"(ou pelo módulo Configurador, parâmetro MV_TABPRO).", ;
			;//Alerta
			"";
			}
		Case nErr == 3
			aErr := { ;
			;//Problema
			"Parâmetro 'Negociação da Tabela de Provisão' (MV_NEGPRO) não foi definido ou não possui valor!", ;
			;//Solução
			"Para realizar gerar os Cálculos de Frete com finalidade exclusiva de provisionamento " + ;
			"o número da Negociação (da Tabela de Frete) a ser usada deve ser informado nos Parâmetros " + ;
			"do Módulo (ou pelo módulo Configurador, parâmetro MV_NEGPRO). ",  ;
			;//Alerta
			"";
			}
		Case nErr == 4
			aErr := { ;
			;//Problema
			"Nenhuma Unidade de Cálculo foi gerada, ou não há Classificação de Frete/Tipo de Operação para localizar a Tabela de Frete!", ;
			;//Solução
			"Nenhum Cálculo de Frete foi gerado para o Romaneio. Verifique se existem trechos " + ;
			"pagos pelo Embarcador nos Documentos de Carga do Romaneio e se o Tipo de Operação do Romaneio e a " + ;
			"Classificação de Frete do Romaneio (opcional) e dos Itens dos Documentos de Carga (obrigatórias) são válidos.", ;
			;//Alerta
			"";
			}
		Case nErr == 5
			aErr := { ;
			;//Problema
			"Não foi encontrada Tabela de Frete válida para a Unidade de Cálculo.", ;
			;//Solução
			"Verifique se o Transportador do Romaneio possui Tabelas de Frete e Negociações liberadas, " + ;
			"vigentes nesta data e compatíveis com o Tipo de Operação do Romaneio e Classificação de Frete do Romaneio " + ;
			"e/ou Itens dos Documentos de Carga.", ;
			;//Alerta
			"";
			}
		Case nErr == 6
			aErr := { ;
			;//Problema
			"Não foi encontrada Tabela de Frete válida para a Unidade de Cálculo.", ;
			;//Solução
			"Verifique se o Transportador do Romaneio possui Tabelas de Frete e Negociações liberadas, " + ;
			"vigentes nesta data e compatíveis com o Tipo de Operação do Romaneio e Classificação de Frete do Romaneio " + ;
			"e/ou Itens dos Documentos de Carga. Havendo Tabelas e Negociações válidas verifique se as Faixas ou Tipos de veículo " + ;
			"e as Rotas correspondentes a todas as origens e destinos do Romaneio estão cadastrados e se essas Rotas e " + ;
			"Faixas ou Tipos de Veículo possuem Tarifas informadas.", ;
			;//Alerta
			"";
			}
		Case nErr == 7
			aErr := { ;
			;//Problema
			"Não foi encontrada Tabela de Frete válida para a Unidade de Cálculo.", ;
			;//Solução
			"Verifique se o Transportador do Romaneio possui Tabelas de Frete e Negociações liberadas, " + ;
			"vigentes nesta data e compatíveis com o Tipo de Operação do Romaneio e Classificação de Frete do Romaneio " + ;
			"e/ou Itens dos Documentos de Carga.", ;
			;//Alerta
			"";
			}
		Case nErr == 8
			aErr := { ;
			;//Problema
			"Foi encontrada Tabela de Frete, mas não há Tarifas cadastradas.", ;
			;//Solução
			"Verifique se as Faixas ou Tipos de Veículo e as Rotas correspondentes a todas as origens " + ;
			"e destinos do Romaneio estão cadastrados e se essas Rotas e Faixas ou Tipos de Veículo possuem tarifas informadas.", ;
			;//Alerta
			"";
			}
		Case nErr == 9
			aErr := { ;
			;//Problema
			"Não foi encontrado componente 'Frete Unidade' para considerar a Maior Tarifa.", ;
			;//Solução
			"Verifique dentre as tarifas da Rota x Faixa ou Tipo de Veículo se há pelo menos um Componente de Frete " + ;
			"que calcula sobre o Peso da Carga (cadastro de Componentes de Frete). Esse tipo de Componente de Frete " + ;
			"é utilizado no cálculo dos fretes com Negociação do tipo 'Frete Viagem' com critério de cálculo que " + ;
			"considera a 'Maior Tarifa'.", ;
			;//Alerta
			"";
			}
		Case nErr == 10
			aErr := { ;
			;//Problema
			"Não foi encontrado componente 'Frete Unidade' para considerar a Maior Tarifa. ", ;
			;//Solução
			"Verifique dentre as tarifas da Rota x Faixa ou Tipo de Veículo se há pelo menos um Componente de Frete" + ;
			" que calcula sobre o Peso da Carga (cadastro de Componentes de Frete). Esse tipo de Componente de Frete " + ;
			"é utilizado no cálculo dos fretes com Negociação do tipo 'Frete Viagem' com critério de cálculo que considera a 'Maior Tarifa'.", ;
			;//Alerta
			"";
			}
		Case nErr == 11
			aErr := { ;
			;//Problema
			"Componente de Frete não cadastrado.", ;
			;//Solução
			"Verifique se há pelo menos um Componentes de Frete relacionado à(s) Negociação(ões) da(s) Tabela(s) de Frete do Transportador.", ;
			;//Alerta
			"";
			}
		Case nErr == 12
			aErr := { ;
			;//Problema
			"Não foi possível gravar as Unidades de Cálculo geradas. Um ou mais Cálculos de Frete " + ;
			"existentes para os Documentos de Carga não puderam ser eliminados. ", ;
			;//Solução
			"O recálculo do frete não foi realizado por um dos seguintes motivos: " + CRLF + ;
			"1) Um ou mais cálculos gerados anteriormente para o Romaneio já foram relacionados à Pré-fatura;" + CRLF + ;
			"2) Um ou mais Documentos de Carga do Romaneio já foram relacionados a um Documento de Frete;" + CRLF + ;
			"3) Um ou mais cálculos gerados anteriormente para o Romaneio já foram relacionados à Lote de Provisão." + CRLF + ;
			"Realize os seguintes procedimento conforme cada caso:" + CRLF + ;
			"1) Cancele a Pré-fatura;" + CRLF + ;
			"2) Desvincule os Documentos de Carga do Documento de Frete;" + CRLF + ;
			"3) Realize a exclusão do Lote de Provisão.", ;
			;//Alerta
			"";
			}
		Case nErr == 13
			aErr := { ;
			;//Problema
			"Conversão entre as Unidades de Medida não cadastrada.", ;
			;//Solução
			"O fator de conversão da unidade de medida de quilogramas para a unidade de medida da faixa " + ;
			"ou dos componentes não foi encontrado. Verifique na Negociação quais são as Unidades de Medida da Faixa " + ;
			"e dos Componentes e cadastre o fator de conversão  manutenção de Conversão de Unidades de Medida. ", ;
			;//Alerta
			"";
			}
		Case nErr == 14
			aErr := { ;
			;//Problema
			"Componente de Frete não cadastrado.", ;
			;//Solução
			"Há pelo menos um componente informado nas Tarifas ou Negociações da Tabela de Frete que não foi encontrado. " + ;
			"Cadastre o Componente de Frete ou substitua-o por um Componente de Frete corretamente cadastrado.", ;
			;//Alerta
			"";
			}
		Case nErr == 15
			aErr := { ;
			;//Problema
			"Há Negociações de Frete selecionadas para as rotas com Aplicações de Pedágio diferentes.", ;
			;//Solução
			"Não é possível determinar qual critério de cálculo de pedágio considerar para a unidade de cálculo " + ;
			"pois há duas ou mais Negpciações com critérios distintos. Revise o cadastramento das Negociações da Tabela de Frete " + ;
			"para que tenham o mesmo critério de cálculo de pedágio.", ;
			;//Alerta
			"";
			}
		Case nErr == 16
			aErr := { ;
			;//Problema
			"Cálculo de valor [1] acima do valor limite de [2] com parametrização para desfazer o cálculo.", ;
			;//Solução
			"Verifique se os valores dos Documentos de Carga estão informados corretamente, assim como os valores das " + ;
			"tarifas da Tabela de Frete que podem causar um valor excessivo incorretamente.", ;
			;//Alerta
			"Valor [1] acima do valor limite de [2]";
			}
		Case nErr == 17
			aErr := { ;
			;//Problema
			"Romaneio de valor [1] acima do valor limite de [2] com parametrização para desfazer o cálculo.", ;
			;//Solução
			"Verifique se os valores dos Documentos de Carga estão informados corretamente, assim como os valores das " + ;
			"tarifas da Tabela de Frete que podem causar um valor excessivo incorretamente.", ;
			;//Alerta
			"Valor [1] acima do valor limite de [2]";
			}
		Case nErr == 18
			aErr := { ;
			;//Problema
			"Percentual do valor de cálculo em relação ao valor da carga [1]% acima do limite de [2]% com "+;
			"parametrização para desfazer o cálculo.", ;
			;//Solução
			"Verifique se os valores dos itens dos Documentos de Carga estão informados corretamente, assim como os valores das " + ;
			"tarifas da Tabela de Frete que podem causar um valor excessivo incorretamente.", ;
			;//Alerta
			"Percentual valor/carga de [1]% acima do valor limite de [2]%";
			}
		Case nErr == 19
			aErr := { ;
			;//Problema
			"Valor de cálculo em relação ao peso(ton) da carga [1] acima do limite de [2] com "+;
			"parametrização para desfazer o cálculo.", ;
			;//Solução
			"Verifique se os pesos dos itens dos Documentos de Carga estão informados corretamente, assim como os valores das " + ;
			"tarifas da Tabela de Frete que podem causar um valor excessivo incorretamente.", ;
			;//Alerta
			"Valor/peso(ton) de [1] acima do valor limite de [2]";
			}
		Case nErr == 20
			aErr := { ;
			;//Problema
			"", ;
			;//Solução
			"", ;
			;//Alerta
			"Possuí redespacho e o tipo de lotação da tabela de negociação é 3=Veículo Dedicado.";
			}
		Case nErr == 21
			aErr := { ;
			;//Problema
			"Há Negociações de Frete selecionadas com divergências entre [1]", ;
			;//Solução
			"Verifique se os Documentos de Carga deste Romaneio correspondem a Negociações " + ;
			"de Frete com Tipo de Lotação com Veículo Dedicado e critérios de negociação " + ;
			"diferentes (Cotas, Locação, Excedente). Classificações de Frete diferentes entre os itens dos Documentos "+;
			"de Carga direcionam a rotina à utilização de mais de uma Negociação durante o cálculo do frete", ;
			;//Alerta
			"";
			}
		Case nErr == 22
			aErr := { ;
			;//Problema
			"Componente de Frete não cadastrado", ;
			;//Solução
			"No Tipo da Ocorrência há Componentes de Serviço cadastrados " + ;
			"que não estão vinculados a Tabela de Frete", ;
			;//Alerta
			"";
			}
		Case nErr == 23
			aErr := { ;
			;//Problema
			"Quantidade de Serviço não foi informada", ;
			;//Solução
			"Para que o Componente de Frete de serviço seja calculado " + ;
			"é necessário que a Quantidade de Serviço seja informada na ocorrência", ;
			;//Alerta
			"";
			}
		Case nErr == 24
			aErr := { ;
			;//Problema
			"Componente de Frete não cadastrado", ;
			;//Solução
			"Verifique se há pelo menos um Componentes de Serviço relacionado à(s) Negociação(ões) da(s) Tabela(s) de Frete do Transportador.", ;
			;//Alerta
			"";
			}
		Case nErr == 25
			aErr := { ;
			;//Problema
			"Valor do cálculo esta zerado", ;
			;//Solução
			"Verifique se há valores relacionados aos componentes na tarifa da Tabela de Frete de todos os trechos.", ;
			;//Alerta
			"";
			}
		Case nErr == 26
			aErr := { ;
			;//Problema
			"O Documento está sendo calculado por outro usuário.", ;
			;//Solução
			"Tente novamente mais tarde.", ;
			;//Alerta
			"";
			}
		Case nErr == 27
			aErr := { ;
			;//Problema
			"Cálculo de frete não realizado por erro em outra Unidade de Cálculo.", ;
			;//Solução
			"Verifique os erros apontados nas Unidades de Cálculo.", ;
			;//Alerta
			"";
			}
		Case nErr == 28
		aErr := { ;
		;//Problema
		"Não foram encontrado(s) grupo(s) de contas para rateio. Cálculo desfeito.", ;
		;//Solução
		"Conforme o parâmetro MV_ACGRRAT, não é possível gravar o cálculo quando não for localizado um " + ;
		"grupo de contas para rateio dos itens do cálculo. Verifique os cadastros de contabilização e os" + ;
		" parâmetros de grupos contábeis no cadastro de parâmetros módulo, aba Contabilização." + ;
		" Adicionalmente, consulte o log do rateio contábil.", ;
		;//Alerta
		"Não foram encontrado(s) grupo(s) de contas para rateio.";
		}
		Case nErr == 29
		aErr := { ;
		;//Problema
		"Tipo de serviço [2] do componente [1] não permite inserir uma recorrência.",;
		;//Solução
		"Conforme a validação do tipo de serviço, não é possível inserir uma recorrência. " + ;
		"Documento de carga possui outro cálculo do tipo.", ;
		;//Alerta
		"";
		}
		Case nErr == 30
		aErr := { ;
		;//Problema
		"Valor de pedágio informado no romaneio é maior ou igual ao valor do cálculo de frete. Não é possível efetuar o desconto do valor.",;
		;//Solução
		"Com a soma do valor dos documentos aptos para rateio, o valor de pedágio está igual ou maior. " + ;
		"Verifique valor no campo Valor Pedág do Romaneio.", ;
		;//Alerta
		"";
		}
		Case nErr == 31
			aErr := { ;
			;//Problema
			"Soma dos cálculos referentes ao contrato de frete acima do valor limite de [2].", ;
			;//Solução
			"Verifique o valor limite do contrato.", ;
			;//Alerta
			"Valor [1] acima do valor limite de [2]";
			}			
				
	EndCase

	aErr[1] = "Erro (" + AllTrim(Str(nErr)) + ") - " + aErr[1]

Return aErr

/*----------------------------------------------------
Função que adiciona no array de erros dos cálculos
um array contendo o número do cálculo e o número do erro
relacionado, além de uma lista de informações para
serem adicionadas no texto do log.
----------------------------------------------------*/

Function GFEXFBAEC(cCalc, nErr, aRom, aVal, lAviso, nTipo)
	Local nX
	Local cRom     := ""
	Local aAreaGWF := GWF->( GetArea() )

	Default aRom   := {}
	Default aVal   := {} //Valores para serem substituidos nos erros conhecidos, usar array com strings!
	Default lAviso := .F. // O padrão é um erro
	Default nTipo  := If(lAviso,2,1)//Formato da mensagem: 1= erro/solução, 2=alerta

	If ((Type("cTRBAGRU") == "C" .And. !Empty(cTRBAGRU)) .OR. (aAgrFrt != Nil)).And. !Empty(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))
		cRom := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")
	ElseIf ((Type("cTRBUNC") == "C" .And. !Empty(cTRBUNC)) .OR. (aTRBUNC2 != Nil)) .And. !Empty(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"))
		cRom := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU")
	ElseIf !Empty(aRom)
		If aRom[2] == "GWF"
			GWF->(dbSetOrder(1) )
			If GWF->(dbSeek(aRom[3] + aRom[1]) )
				cRom := GWF->GWF_NRROM
			EndIf
		ElseIf aRom[2] == "GWN"
			cRom := aRom[1]
		EndIf
	EndIf

	cRom := PadR(cRom, TamSX3("GWN_NRROM")[1])

	For nX := 1 to Len(aVal)
		Do Case
			Case ValType( aVal[nX]) == "N"
				aVal[nX] := cValTochar(aVal[nX])
			Case ValType( aVal[nX]) == "D"
				aVal[nX] := DTOS(aVal[nX])
		EndCase
	Next nX

	AAdd(aErroCalc, {cCalc, nErr, cRom, aVal, lAviso,nTipo})

	RestArea(aAreaGWF)

Return Nil

/*----------------------------------------------------
Função que retorna todos os erros de um referido
----------------------------------------------------*/

Function GFERomErro(aErro, cRom)

	Local nI
	Local nY
	Local cMotCalc := ""
	Local aErr
	
	For nI := 1 To Len(aErro)
		If AllTrim(aErro[nI][3]) == cRom .And. aErro[nI][5] == .F.
			aErr:=GFECalcErr(aErro[nI][2])
			For nY:= 1 to Len(aErro[nI][4])
				aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aErro[nI][4][nY])
			Next
			cMotCalc += aErr[1] + CRLF + "----" + CRLF
		EndIf
	Next

Return cMotCalc

/*----------------------------------------------------
Função de retorna o número de registros das tabelas
temporárias.
----------------------------------------------------*/
Function GFENumReg(cAliasTab)
	Local nNrReg := 0
	Local aAreaAnt := (cAliasTab)->(getArea())
	
	(cAliasTab)->(dbGoTop())
	While !(cAliasTab)->(Eof())
		If !(cAliasTab)->(Deleted())
			nNrReg++
		EndIf
		(cAliasTab)->(dbSkip())
	EndDo
	RestArea(aAreaAnt)
Return nNrReg

/*----------------------------------------------------
Função que posiciona, gera romaneio e dispara a rotina
de cálculo do romaneio para documentos do sentido entrada.
----------------------------------------------------*/
Function GFECalCAut()
	Local lRet 		 	:= .T.
	Local cNrRom 	 	:= GW1->GW1_NRROM
	Local aErros 	 	:= {}
	Local aRetRom 	 	:= {}
	Local lCalc 	 	:= .T.
	Local cChaveGW1	 	:= GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC
	Local cFili 	 	:= GW1->GW1_FILIAL
	Local cNrDoc 	 	:= GW1->GW1_NRDC
	Local cSerDoc 	 	:= GW1->GW1_SERDC
	Local cCarreg 	 	:= GW1->GW1_CARREG
	Local dDtImplGW1 	:= GW1->GW1_DTIMPL
	Local aAreaGV5 
	Local aAreaGW1 
	Local aAreaGWN 
	Local aAreaGWB 
	Local aAreaGWU 
	Local aAreaGW8
	Local nCont			:= 1
	Local lDtEntAut 	:= .F.
	Local cBloqPF 		:= "2"
	Local cQuery
	Local nTimeCalc 	:= 0
	Local cGFETrace 	:= GFETraceCfg()
	Local lNFSaida  	:= .F.
	Local lCalcular 	:= .T.
	Local cERPGFE 		:= SuperGetMV("MV_ERPGFE",,"2")
	Local cAliGW1		:= ""

	Private dDataCalc //Variavel necessaria para calculo de frete
	
	If Posicione("GV5", 1, xFilial("GV5") + GW1->GW1_CDTPDC, "GV5_SENTID") == "2"
		lNFSaida  := .T.
	EndIf

	//Declaração de uso de tabelas
	
	aAreaGV5 := GV5->(GetArea())
	aAreaGW1 := GW1->(GetArea())
	aAreaGWN := GWN->(GetArea())
	aAreaGWB := GWB->(GetArea())
	aAreaGWU := GWU->(GetArea())
	aAreaGW8 := GW8->(GetArea())

	GV5->(dbSetOrder(1))
	GV5->(dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC))

	If !GFEVerCmpo( {"GV5_CALC","GV5_EMITPF","GV5_DTENAT","GW1_CALCAT","GV4_LBRMAT"})
		lRet := .F.
		GFETrace(cGFETrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(cNrDoc) + ", Carreg: " + AllTrim(cCarreg) + "]       ** Para utilizar a função de cálculo automático, faz-se necessário a atualização do pacote ou execução de update")
		aAdd(aErros,"Para utilizar a função de calculo automatico, faz-se necessário a atualizacao do pacote ou execucao de update")
	EndIf

	If lRet .And. !GW1->(Eof())	.And. (!Empty(GW1->GW1_CALCAT) .And. GW1->GW1_CALCAT != "1")
		lRet := .F.
		GFETraceVerbose(cGFETrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(cNrDoc) + ", Carreg: " + AllTrim(cCarreg) + "]       ** Situacao do calulo automatico deve ser 1=Calculo aut. pendente")
		aAdd(aErros,"Situação do cálulo automático deve ser 1=Cálculo aut. pendente")
	EndIf

	If lRet .And. !GW1->(Eof())	.And. !(GW1->GW1_SIT $ "1345") // pode ser que venha embarcado da integração
		lRet := .F.
		GFETrace(cGFETrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(cNrDoc) + ", Carreg: " + AllTrim(cCarreg) + "]       ** Situacao do Documento de Carga deve ser 1=Digitado;3=Liberado;4=embarcado;5=Entregue")
		aAdd(aErros,"Situação do Documento de Carga deve ser 1=Digitado;3=Liberado;4=embarcado;5=Entregue")
	EndIf

	If lRet .And. !GV5->(Eof())	.And. GV5->GV5_CALC != "2"
		lRet := .F.
		GFETraceVerbose(cGFETrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(cNrDoc) + ", Carreg: " + AllTrim(cCarreg) + "]       ** Tipo de documento de carga nao é 2=calculo automatico")
		aAdd(aErros,"Tipo de documento de carga não é 2=cálculo automático")
		RecLock("GW1", .F.)
			GW1->GW1_CALCAT := "0"
		GW1->(MsUnlock())
	EndIf

	If lRet
		lDtEntAut := GV5->GV5_DTENAT == "1" 		
		If Empty(cNrRom)
			//Busca Romaneio de Documentos do mesmo carrregamento
			GW1->(dbSetOrder(14))
			If !Empty(cCarreg) .And. GW1->(dbSeek(cFili + cCarreg))
				While !GW1->(Eof()) .AND. ;
				GW1->GW1_FILIAL == cFili .AND. ;
				GW1->GW1_CARREG == cCarreg
					//Documento não deve ser o próprio que está sendo gerado/selecionado
					//Deve Estar embarcado
					//Deve possuir mesma data de criação do romaneio
					If cChaveGW1 != GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC
						If Empty(cNrRom) 																  .AND. ;
						((GW1->GW1_SIT == "4") .OR. (lDtEntAut .AND. GW1->GW1_SIT == "5")) 			  .AND. ;
						Posicione("GWN",1,GW1->GW1_FILIAL + GW1->GW1_NRROM,"GWN_DTIMPL") == dDtImplGW1 .AND. ;
						Posicione("GWN",1,GW1->GW1_FILIAL + GW1->GW1_NRROM,"GWN_CDTRP")  == Posicione("GWU",1,cChaveGW1,"GWU_CDTRP")

							cNrRom := GW1->GW1_NRROM
							Exit
						EndIf
					EndIf

					GW1->(dbSkip())
				EndDo
			EndIf
			RestArea(aAreaGW1)

			If Empty(cNrRom) //Gerar romaneio pois não encontrou pelo numero de carregamento
				aRetRom:= GFEA44NVR( cBloqPF )
				If aRetRom[1] == .T.
					cNrRom := aRetRom[2]
				Else
					For nCont := 1 To Len(aRetRom[3])
						aAdd(aErros, aRetRom[3][nCont])
					Next nCont
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .AND. lNFSaida
		// Verifica se todos os documentos de carga do carregamento estão liberados
		// - Integração Datasul x GFE
		// - Apenas para notas de saída
		// - Apenas se o existir número de Romaneio ou Carregamento
		
		If cERPGFE == "1"
			 If (!Empty(cNrRom) .OR. !Empty(cCarreg))
				cQuery := "SELECT COUNT(*) AS TOTAL_BLOQUEADOS FROM " + RetSQLName("GW1") + " GW1 WHERE GW1_FILIAL = '" + xFilial("GW1") + "' "
				
				If !Empty(cNrRom)
					cQuery += " AND GW1.GW1_NRROM = '" + cNrRom + "'"
				ElseIf !Empty(cCarreg)
					cQuery += " AND GW1.GW1_CARREG = '" + cCarreg + "'" 
				EndIf
				
				cQuery += " AND GW1.GW1_NRDC != '" + cNrDoc + "' AND GW1.GW1_SIT = '2' AND GW1.D_E_L_E_T_ = ''"
				cQuery := ChangeQuery(cQuery)
			
				cGW1Bloq := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW1Bloq, .F., .T.)
			
				(cGW1Bloq)->(dbGoTop() )
				If !(cGW1Bloq)->(Eof())
					If (cGW1Bloq)->TOTAL_BLOQUEADOS > 0
						lCalcular := .F.
					EndIf
				EndIf
				
				(cGW1Bloq)->(dbCloseArea() )
			EndIf
		EndIf
			
		// Verifica se todos os documentos de carga da carga já foram integrados e faturados no OMS
		// - Integração OMS x GFE
		// - Integração Direta
		// - Carga do OMS como Integrar (MV_GFEI12)
		// - Apenas para notas de saída
		// - Apenas para os documentos de carga com Romaneio informado
		If cERPGFE == "2" .AND. !Empty(cNrRom)
			If SuperGetMV('MV_GFEI12',,'2') == "1" .AND. SuperGetMv("MV_INTGFE",.F.,.F.) .AND. SuperGetMv("MV_INTGFE2",.F.,"2") $ "1S"
				lCalcular := UltDocCargaOMS(cGFETrace)
			EndIf
		EndIf
	EndIf

	If lRet
		If !Empty(cNrRom)
			cBloqPF := If( (GV5->GV5_EMITPF == "1" .Or. Empty(GV5->GV5_EMITPF)), "2", "1")
			
			GWN->(dbSetOrder(1) )
			If GWN->(dbSeek(cFili + cNrRom) )
				RecLock ("GWN", .F.)
					GWN->GWN_BLOQPF := cBloqPF // Indica bloqueio de préfatura
				GWN->(MsUnlock())
			EndIf

			RecLock("GW1",.F.)
				GW1->GW1_NRROM := cNrRom
				If GFXCP1212210('GW1_FILROM')
					GW1->GW1_FILROM := GWN->GWN_FILIAL
				EndIf
				If GW1->GW1_SIT != "5"
					GW1->GW1_SIT := "4"	
				EndIf
			GW1->(MsUnlock())

			// Se todos os documentos de carga do carregamento estiverem liberados, realiza o cálculo de frete
			If lCalcular
				GFE50LbRom() // Verificar e liberar romaneio
				If cGFETrace == "1"
					nTimeCalc := SECONDS()
				EndIf

				lCalc := GFE050CALC() // Calcula!

				GFETrace(cGFETrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(cNrDoc) + ;
																	  ", Serie: " + AllTrim(cSerDoc) + ;
																	  ", Romaneio: " + AllTrim(cNrRom) + ;
																	  IIf(!Empty(cCarreg), ", Carregamento: " + AllTrim(cCarreg), "") + ;
																	  "] [Tempo de calculo: " + PrintElapsed(nTimeCalc) + "]")

				RestArea(aAreaGW1)

				GW1->(dbSetOrder(14))
				If !Empty(cCarreg) .And. GW1->(dbSeek(cFili + cCarreg))
					While !GW1->(Eof()) .AND. ;
							GW1->GW1_FILIAL == cFili 	.AND. ;
							GW1->GW1_CARREG == cCarreg

						If GW1->GW1_SIT != "2"
							RecLock("GW1",.F.)
								If lCalc == .T.
									GW1->GW1_CALCAT := "2" // Sucesso no cálculo do romaneio
								Else
									GW1->GW1_CALCAT := "3" // Falha no cálculo do romaneio
								EndIf
							GW1->(MsUnlock())
						EndIf

						GW1->(dbSkip())
					EndDo
					RestArea(aAreaGW1)
				Else
					cAliGW1 := GetNextAlias()

					BeginSQL Alias cAliGW1
						SELECT GW1.R_E_C_N_O_ RECNOGW1
						FROM %Table:GW1% GW1
						WHERE GW1.GW1_FILIAL = %Exp:cFili%
						AND GW1.GW1_NRROM = %Exp: cNrRom%
					EndSQL

					While (cAliGW1)->(!EoF())
						GW1->(dbGoTo((cAliGW1)->RECNOGW1))

						RecLock("GW1",.F.)
							If lCalc == .T.
								GW1->GW1_CALCAT := "2" // Sucesso no cálculo do romaneio
							Else
								GW1->GW1_CALCAT := "3" // Falha no cálculo do romaneio
							EndIf
						GW1->(MsUnlock())

						(cAliGW1)->(dbSkip())
					EndDo
					
					(cAliGW1)->(dbCloseArea())

					RestArea(aAreaGW1)
				EndIf
			Else
				aAdd(aErros,"Todos os documentos de carga devem estar desbloqueados para realizar o cálculo automático.")			
			EndIf
		Else
			RecLock("GW1",.F.)
				GW1->GW1_CALCAT := "4" // Sem Sucesso na geração/vinculo do romaneio ao documento			
			GW1->(MsUnlock())
		EndIf
	EndIf

	RestArea(aAreaGV5)
	RestArea(aAreaGW1)
	RestArea(aAreaGWN)
	RestArea(aAreaGWB)
	RestArea(aAreaGWU)
	RestArea(aAreaGW8)
Return {lRet,cNrRom,aErros}

/*----------------------------------------------------------------------------
PrintElapsed
Retorna o tempo decorrido com base em um tempo inicial e o tempo atual
----------------------------------------------------------------------------*/
Static Function PrintElapsed(nTempoIni)
	Local nTempoTotal
	Local cRet := ""

	nTempoTotal := SECONDS() - nTempoIni

	If nTempoTotal > 60
		cRet := cValToChar(NoRound(nTempoTotal / 60, 1)) + " Minutos"
	Else
		cRet := cValToChar(NoRound(nTempoTotal, 1)) + " Segundos"
	EndIf

Return(cRet)

/*----------------------------------------------------------------------------
{Protheus.doc} UltDocCargaOMS
Integração OMS x GFE
Verifica se todos os documentos do OMS foram integrados no GFE, verificando
se a carga já foi faturada.

Função utilizada para executar o cálculo automático apenas quando o documento
integrado for o último da carga.

Retorno:
	A função retornará 'false' apenas quando for encontrado todos os registros
	necessários para a verificação da carga (DAK).
	Caso falhe em achar algum registro fundamental para a verificação, por exemplo, 
	o código do Cliente ou o registro com o relacionamento da carga e documentos (DAI)
	a função retornará 'true'.


@author  Israel Alcantara Possoli
@since   02/07/2015
@version 1.0
----------------------------------------------------------------------------*/
Static Function UltDocCargaOMS(cTrace)
	Local lNumProp := SuperGetMv("MV_EMITMP",.F.,"1") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
	Local cClient
	Local cLoja
	Local cCGCDest
	Local cCodCarga := ""
	Local cSeqCarga := ""
	Local cQuery
	Default cTrace	:= "0"
	
	If lNumProp
		GU3->(dbSetOrder(1))
		If GU3->(dbSeek(xFilial("GU3") + GW1->GW1_CDDEST))
			cClient := GU3->GU3_CDERP
			cLoja	:= GU3->GU3_CDCERP
		Else
			GFETraceErro(cTrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(GW1->GW1_NRDC) + ", Serie: " + AllTrim(GW1->GW1_SERDC) + "] ** Emitente não encontrado com o código: " + GW1->GW1_CDDEST)
			Return(.T.)
		EndIf
	Else
		cCGCDest := POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_IDFED")
		
		SA1->(dbSetOrder(3))
		
		If SA1->(dbSeek(xFilial("SA1") + cCGCDest))
			cClient	:= SA1->A1_COD
			cLoja	:= SA1->A1_LOJA
		Else
			GFETraceErro(cTrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(GW1->GW1_NRDC) + ", Serie: " + AllTrim(GW1->GW1_SERDC) + "] ** Cliente não encontrado com o CNPJ/CPF: " + cCGCDest)
			Return(.T.)
		EndIf
	EndIf
	
	If Empty(cClient)
		GFETraceErro(cTrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(GW1->GW1_NRDC) + ", Serie: " + AllTrim(GW1->GW1_SERDC) + "] ** Codigo da loja nao informado no cadastro de emitente do GFE. Emitente:  " + GW1->GW1_CDDEST)
		Return(.T.)
	EndIf

	// Busca o código da Carga com base no documento de carga selecionado	
	cQuery := "SELECT DAI_COD, DAI_SEQCAR FROM " + RetSQLName("DAI") + " DAI"
	cQuery += " WHERE DAI_FILIAL = '" + GW1->GW1_FILIAL + "' AND DAI_NFISCA = '" + GW1->GW1_NRDC + "' AND DAI_SERIE = '" + GW1->GW1_SERDC + "' AND DAI_CLIENT = '" + cClient + "' AND DAI_LOJA = '" + cLoja + "'"
	cQuery += " AND DAI.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	
	cAliasDAI := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDAI, .F., .T.)
	
	(cAliasDAI)->(dbGoTop() )
	If !(cAliasDAI)->(Eof())
		cCodCarga := (cAliasDAI)->DAI_COD
		cSeqCarga := (cAliasDAI)->DAI_SEQCAR
	Else
		GFETraceErro(cTrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(GW1->GW1_NRDC) + ", Serie: " + AllTrim(GW1->GW1_SERDC) + "] ** Codigo da carga não encontrado com base no documento de carga.")
		
		(cAliasDAI)->(dbCloseArea() )
		Return(.T.)
	EndIf
	
	(cAliasDAI)->(dbCloseArea() )
	
	If DAK->( FieldPos("DAK_FEZNF") ) > 0
		// Busca a carga relacionada ao romaneio
		cQuery := "SELECT DAK_FEZNF FROM " + RetSQLName("DAK") + " DAK"
		cQuery += " WHERE DAK_FILIAL = '" + GW1->GW1_FILIAL + "' AND DAK_COD = '" + cCodCarga + "' AND DAK_SEQCAR = '" + cSeqCarga + "'"
		cQuery += " AND DAK.D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)
		
		cAliasDAI := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDAI, .F., .T.)
		
		(cAliasDAI)->(dbGoTop() )
		If !(cAliasDAI)->(Eof())
			// Verifica se a carga está faturada
			If (cAliasDAI)->DAK_FEZNF != "1"
				GFETraceVerbose(cTrace, "[GFEXFUNB] [CALCULO AUTOMATICO] [Doc: " + AllTrim(GW1->GW1_NRDC) + ", Serie: " + AllTrim(GW1->GW1_SERDC) + ", Romaneio: " + AllTrim(GW1->GW1_NRROM) + "] [SKIP] ** Carga nao foi faturada totalmente, documento deve ser o ultimo da integracao. Filial: " + GW1->GW1_FILIAL + ", Carga: " + AllTrim(cCodCarga) + ", Seq: " + AllTrim(cSeqCarga))
				(cAliasDAI)->(dbCloseArea() )
				Return(.F.)
			Else
				(cAliasDAI)->(dbCloseArea() )
				Return(.T.)
			EndIf
		EndIf		
	EndIf
	
	(cAliasDAI)->(dbCloseArea() )
		
Return(.T.)

/*
Função GFEVerCmpo verifica se determinados campos existem nas tabelas padrão
Utilizar com cautela
*/
Function GFEVerCmpo(aCampos)
	Local lRet := .T.
	Local nCount := 1

	If Len(aCampos) == 0
		Return .F.
	End If

	For nCount := 1 To Len(aCampos)
		If SUBSTR(aCampos[nCount],4,1) != "_"
			Return .F.
		EndIf
		If Empty( &(SUBSTR(aCampos[nCount],1,3)+"->(FieldPos('"+aCampos[nCount]+"'))" ) )
			Return .F.
		EndIf
	Next nCount
Return lRet

// Verifica se o update passado como parametro foi aplicado
Function GFEVerComp(cUpdate,cMensagem)
	GW0->(dbSetOrder(1))

	If !GW0->(dbSeek(Space(TamSX3("GW0_FILIAL")[1])+PadR("GFEUMAN", 20)+cUpdate)) .And. !GW0->(dbSeek(Space(TamSX3("GW0_FILIAL")[1])+PadR("GFEUDES", 20)+cUpdate))
		If cMensagem!= Nil .And. !Empty(cMensagem)
			MsgStop( cMensagem )
		EndIf
		Return .F.
	Else
		Return .T.
	EndIf
Return


Function GFEServFrete (aComp, aAgrFrt, aDocCarg, aTrchDoc, aItDoc, nServico, cNumOcor, lGfea117, cTipoImp, cCdTipo,lSimular,lShowTabFr,lnocalc,aNoCalc)
	Local aRet := {}
	Local nLog := 2
	Default lnocalc := .F.
	Default cTipoImp := "1"
	Default lSimular := .F.
	Default lShowTabFr := .t.

	Private aCServ 	:= aComp
	Private aServ2 	:= {}
	Private aServErro	:= {}
	Private nQtServ 	:= nServico
	Private cNrOcor 	:= cNumOcor
	Private cTpOcor 	:= cCdTipo
	Private lEdi    	:= lGfea117

	// Se for chamado pelo programa de importação de ocorrência através de EDI
	// o log não deve ser mostrado
	if lGfea117 .Or. lnocalc
		nLog := 0
	Endif

	If lSimular
		nLog := 2
	EndIf

	aAgrFrt2 := aClone(aAgrFrt)
	aDocCarg2 := aClone(aDocCarg)
	aTrchDoc2 := aClone(aTrchDoc)
	aItDoc2 := aClone(aItDoc)

	aRet := GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, , !lSimular, nLog, 0, .F., 1, .F., lnocalc, .T., .T.,cTipoImp,,aNoCalc,lShowTabFr)


Return aRet

/*/{Protheus.doc} GfeAtuPesC

Atualiza o peso cubado dos itens dos cálculos, recuperando sempre as tabelas do primeiro cálculo, normal ou redespacho(o que vier primeiro) daquele documento
utilizando um agrupador(romaneio) como filtro, acelerando o processamento.

@author siegklenes.beulke
@since 20/11/2014
@version 1.0
@param cAgruPc, char, nr de romaneio separados em com virgula para uso na clausula in
@example
GfeAtuPesC("'0000001','0000002'")

/*/
Function GfeAtuPesC(cAgruPc)
	Local cQuery := ""
	Local cMsg := ""
	Local cAliasQry := GetNextAlias()

	cQuery += " SELECT GV9.GV9_QTKGM3 ,"
	cQuery += "		GW8.GW8_FILIAL ,"
	cQuery += "		GW8.GW8_CDTPDC ,"
	cQuery += "		GW8.GW8_EMISDC ,"
	cQuery += "		GW8.GW8_NRDC  ,"
	cQuery += "		GW8.GW8_SERDC ,"
	cQuery += "		GW8.GW8_SEQ   "
	cQuery += "		FROM " + RetSqlName("GW8") + " GW8 "
	cQuery += "		INNER JOIN " + RetSqlName("GWH") + " GWH "
	cQuery += "		ON GWH.GWH_FILIAL 	= GW8.GW8_FILIAL "
	cQuery += "	AND GWH.GWH_CDTPDC 		= GW8.GW8_CDTPDC "
	cQuery += "	AND GWH.GWH_EMISDC 		= GW8.GW8_EMISDC "
	cQuery += "	AND GWH.GWH_NRDC   		= GW8.GW8_NRDC "
	cQuery += "	AND GWH.GWH_SERDC  		= GW8.GW8_SERDC "
	cQuery += "	AND GWH.D_E_L_E_T_ = '' "
	cQuery += "	AND GW8.D_E_L_E_T_ = '' "
	cQuery += "	"
	cQuery += "		INNER JOIN " + RetSqlName("GWG") + " GWG "
	cQuery += "		ON GWG.GWG_FILIAL	= GWH.GWH_FILIAL "
	cQuery += "	AND GWG.GWG_NRCALC		= GWH.GWH_NRCALC "
	cQuery += "	AND GWG.D_E_L_E_T_		= '' "
	cQuery += "	"
	cQuery += "		INNER JOIN " + RetSqlName("GWF") + " GWF "
	cQuery += "		ON GWG.GWG_FILIAL	= GWF.GWF_FILIAL "
	cQuery += "	AND GWG.GWG_NRCALC		= GWF.GWF_NRCALC "
	cQuery += "	AND GWF.GWF_TPCALC		= '1' "
	cQuery += "	AND GWF.D_E_L_E_T_		= '' "
	cQuery += "	"
	cQuery += "		INNER JOIN 	" + RetSqlName("GVA") + " GVA "
	cQuery += "	 	ON GVA.GVA_FILIAL = '" + xFilial("GVA") + "' AND GVA.GVA_NRTAB = GWG.GWG_NRTAB AND GVA.GVA_CDEMIT = GWG.GWG_CDEMIT "
	cQuery += "		INNER JOIN " + RetSqlName("GV9") + " GV9 "
	cQuery += "		ON GV9.GV9_FILIAL	= '" + xFilial("GV9") + "' "
	cQuery += "			AND GV9.GV9_CDEMIT = CASE  "
	cQuery += "										WHEN GVA.GVA_TPTAB = '1'  THEN GWG.GWG_CDEMIT"
	cQuery += "										ELSE GVA.GVA_EMIVIN "
	cQuery += "									END "
	cQuery += "			AND GV9.GV9_NRTAB = CASE "
	cQuery += "										WHEN GVA.GVA_TPTAB = '1'  THEN GWG.GWG_NRTAB "
	cQuery += "  										ELSE GVA.GVA_TABVIN "
	cQuery += "									END "
	cQuery += "	AND GV9.GV9_NRNEG		= GWG.GWG_NRNEG "
	cQuery += "	AND GV9.D_E_L_E_T_		= '' "
	cQuery += "	"
	cQuery += "	INNER JOIN " + RetSqlName("GWN") + " GWN "
	cQuery += "		ON GWF.GWF_FILIAL	= GWN.GWN_FILIAL "
	cQuery += "	AND GWN.GWN_NRROM		= GWF.GWF_NRROM "
	cQuery += "	AND GWN.GWN_NRROM		IN (" + cAgruPc + ") "
	cQuery += "	AND GWN.D_E_L_E_T_		= '' "
	cQuery += "	"
	cQuery += "	WHERE GWG.GWG_CDCLFR = GW8.GW8_CDCLFR AND GW8.GW8_FILIAL = '" + xFilial("GW8") + "' "
	cQuery += "  GROUP BY GW8.GW8_FILIAL , "
	cQuery += "  GW8.GW8_CDTPDC , "
	cQuery += "  GW8.GW8_EMISDC , "
	cQuery += "  GW8.GW8_NRDC ,  "
	cQuery += "  GW8.GW8_SERDC, GW8.GW8_SEQ , GV9.GV9_QTKGM3 "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasQry, .F., .T.)

	GW8->(dbSetOrder(2))
	(cAliasQry)->(dbGoTop())
	While !(cAliasQry)->(Eof())
		If GW8->(dbSeek((cAliasQry)->(GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ)))
			RecLock("GW8",.F.)
			GW8->GW8_PESOC := (cAliasQry)->GV9_QTKGM3 * GW8->GW8_VOLUME
			GW8->(MsUnLock())
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	If lPEXFB22
		ExecBlock("GFEXFB22",.f.,.f.,{ cAgruPc, cQuery })
	EndIf

Return cMsg

/*----------------------------------------------------------------------------
{Protheus.doc}
Função para carregar o log do cálculo de frete apenas ao clicar no botão Detalhes

Obs: Necessidade econtrada no chamado TREEPC.
Quando o log de cálculo é extenso e gravado em um local fora do AppServer,
por exemplo, em um diretório no lado do client (C:\TEMP\), o sistema
apresenta lentidão para carregar a tela de resultado do cálculo.

@author  Guilherme Alexandre Metzger
@since   20/01/2015
@version 1.0
----------------------------------------------------------------------------*/
Static Function CarregaLog(cLog,cArqLog,oDlg,oPanel4,lProcess,lDetail)

	Default lDetail := .F.

	If lProcess
		ProcRegua(2)
		IncProc("Carregando Log...")
	EndIf

	If lDetail .And. oPanel4:lVisible
		Eval({|| oDlg:nHeight -= 275, oPanel4:Hide(), oDlg:Refresh()})
	Else
		If lSaveLog .And. Empty(cLog)
			//Carrega o log efetivamente
			cLog := GFEX1MEMO(AllTrim(cArqLog))
			IncProc("Carregando Log...")
		EndIf
		If lDetail
			Eval({|| oDlg:nHeight += 275, oPanel4:Show(), oDlg:Refresh()})
		EndIf
	EndIf

Return .T.

Function LocEntrg(lRatComp)
	// Armazena a quantidade de entregas compartilhadas do cálculo
	// Para que dois cálculos compartilhem da mesma entrega, Transportador, sequencia, origem, destino, remetente e destinatário devem ser o mesmo.
	Local nCalc
	Local cEmiRed 		:= ""
	Local cEmiOri 		:= ""
	Local cNrCalcs 		:= ""
	Local cNrDocs 		:= ""
	Local cEntrNc 		:= ""
	Local aAreaAGRU 	:= GFEXFB_9GETAREA(lTabTemp, cTRBAGRU, 0)
	Local aAreaGV2 		:= GV2->(GetArea())
	Local aAreaCCF 		:= GFEXFB_9GETAREA(lTabTemp, cTRBCCF, 9)
	Local aAreaUNC 		:= GFEXFB_9GETAREA(lTabTemp, cTRBUNC, 6)
	Local aAreaTRE 		:= GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7)
	Local aAreaGRU 		:= GFEXFB_9GETAREA(.F.,, 4)
	Local cNrAgru
	Local cNrCalc
	Local aCopy			:= {}
	Local nI
	Local nX
	Local aReg
	Local aChave
	Local aNrCalcs		:= {}
	Local aAuxCalcs		:= {}
	Local aNrDocs		:= {}
	Local nNovoVal		:= 0
	
	Default lRatComp 	:= .F.
	
	If !lRatComp
		AddToLog(CRLF + "  # Identificando e agrupando locais de entrega..." + CRLF + CRLF)
	Else
		AddToLog(CRLF + "  # Identificando e agrupando locais de entrega e seus componentes de taxas de entrega..." + CRLF + CRLF)
	EndIf
	
	GV2->(dbSetOrder(1))
	
	GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
	
	GFEXFB_BORDER(lTabTemp,cTRBENT,02,12)    
	
	GFEXFB_BORDER(lTabTemp,cTRBAGRU,01,0) 
	GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
	
	GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
	
	GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
	
	GFEXFB_BORDER(.F.,,03,4)
	
	nCalc := 0
	
	While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0) 
		cNrAgru := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")
		GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{cNrAgru}) 
		
		While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6)  .And. cNrAgru == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU")
			cNrCalc := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
			GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNrCalc})
			
			While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == cNrCalc
				cNrGru := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRGRUP")
				GFEXFB_CSEEK(.F.,, @aTRBGRB3, 4,{cNrGru})
			
	
				aAreaTRE  := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7)
				
				cEmiRed := ""
				cEmiOri := ""
				cEntrNc := ""
				
				While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .AND. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == cNrCalc
					nSeq := VAL(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ")) // grava a sequencia do trecho corrente
					nSeq++             //acrescenta mais um na sequencia
		
					aAreaTRE2  := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7)
					GFEXFB_BORDER(lTabTemp,cTRBTRE,04,7) 
					aChave := {GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRGRUP"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC"),STRZERO(nSeq,2)}
					
					If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE4, 7,aChave)// verifica se existe um trecho seguinte e então grava o cEmiRed
						GFEXFB_ARESTAREA(lTabTemp,aAreaTRE2,7)// RestArea(aAreaTRE2)
						If nSeq-1 > 1 // Não é o primeiro trecho
							cEmiOri := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP")
						EndIf
						cEntrNc := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")
					Else //último trecho
						GFEXFB_ARESTAREA(lTabTemp,aAreaTRE2,7)// RestArea(aAreaTRE2)
						
						If nSeq-1 > 1
							cEmiOri := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP")
						EndIf
					EndIf

					GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
		
				EndDo
				GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
				GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7)//RestArea(aAreaTRE)
				
				If Empty(cEmiOri)
					cEmiOri := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDREM")
				EndIf
				
				If Empty(cEmiRed) .And. s_TREENTR == "1"
					If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ") == "01"; 
					   .And. (Posicione("GW1",1,xFilial("GW1") +;
					   							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") +;
					   							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") +;
					   							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  +;
					   							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC"), "GW1_TPFRET") $ "24")
						
						cEmiRed := Posicione("GWU",1,xFilial("GWU") +;
													 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") +;
													 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") +;
													 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  +;
													 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC") +;
													 "02", "GWU_CDTRP")
					EndIf
				EndIf
				
				If Empty(cEmiRed)
					cEmiRed := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDDEST")
				EndIf
				
				If Empty(cEntrNc)//Destino do último trecho
					cEntrNc := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC")
					If Empty(cEntrNc)
						cEntrNc := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")
					EndIf
				EndIf
				
				If !lRatComp
				
					cChave := {GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"),;
							   GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE"),;
							   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"),;
							   cEntrNc,cEmiOri,cEmiRed}
					
					If !GFEXFB_CSEEK(lTabTemp, cTRBENT, @aTRBENT2, 12,cChave)
						If lTabTemp
							RecLock(cTRBENT,.T.)
								(cTRBENT)->CDTRP	:= (cTRBTRE)->CDTRP
								(cTRBENT)->SEQTRE	:= (cTRBUNC)->SEQTRE
								(cTRBENT)->ORIGEM	:= (cTRBTRE)->ORIGEM
								(cTRBENT)->DESTIN	:= cEntrNc
								(cTRBENT)->CDREM	:= cEmiOri
								(cTRBENT)->CDDEST	:= cEmiRed
								(cTRBENT)->QTDCOMP:= 0
								(cTRBENT)->QTDENTR:= 0
								(cTRBENT)->NRLCENT:= STRZERO(++nCalc,6)
								(cTRBENT)->ENTNRC := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC")
								(cTRBENT)->ENTEND := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTEND")
								(cTRBENT)->ENTBAI := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTBAI")
							(cTRBENT)->(MsUnLock())
						Else
							aAdd(aTRBENT2,{	STRZERO(++nCalc,6),;                                       //"NRLCENT" 1    
											GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"),; //"CDTRP"   2   
											GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE"),;//"SEQTRE"  3  
											GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"),;//"ORIGEM"  4  
											cEntrNc,;                                              //"DESTIN"  5    
											cEmiOri,;                                              //"CDREM"   6  
											cEmiRed,;                                              //"CDDEST"  7    
											GFEXFB_5CMP(.F.     ,        , @aTRBGRB3, 4,"ENTNRC"),;//"ENTNRC"  8    
											GFEXFB_5CMP(.F.     ,        , @aTRBGRB3, 4,"ENTEND"),;//"ENTEND"  9    
											GFEXFB_5CMP(.F.     ,        , @aTRBGRB3, 4,"ENTBAI"),;//"ENTBAI"  10    
											'',;                                                   //"CDCOMP"  11   
											'',;                                                   //"CDCLFR"  12    
											'',;                                                   //"CDTPOP"  13    
											0,;                                                    //"QTDCOMP" 14    
											0,;                                                    //"QTDENTR" 15
											""})												   //"UNICALC" 16
							
							idpENT := Len(aTRBENT2)
							aReg := aTRBENT2[idpENT]
							aTRBENT1 := {}
							aTRBENT3 := {}
							aTRBENT1 := GFEXFB_JCLONE(aTRBENT2)
							aTRBENT3 := GFEXFB_JCLONE(aTRBENT2)
							aSort(aTRBENT2,,,{|x,y| x[2] + x[3] + x[4] + x[5] + x[6] + x[7] < y[2] + y[3] + y[4] + y[5] + y[6] + y[7]})
							aSort(aTRBENT1,,,{|x,y| x[1] + x[11] < y[1] + y[11]})
							aSort(aTRBENT3,,,{|x,y| x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[11] + x[12] + x[13] < y[2] + y[3] + y[4] + y[5] + y[6] + y[7] + y[11] + y[12] + y[13]})
						EndIf
					ElseIf !lTabTemp
						aReg := aTRBENT2[idpENT]
					EndIf
					
					If lTabTemp
						If Empty((cTRBUNC)->NRLCENT)
							RecLock(cTRBENT,.F.)
								(cTRBENT)->QTDENTR++
							(cTRBENT)->(MsUnLock())
						EndIf
					ElseIf Empty(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRLCENT"))
						aReg[15]++
					EndIf
					
					If lTabTemp
						RecLock(cTRBUNC,.F.)
						(cTRBUNC)->NRLCENT := (cTRBENT)->NRLCENT
						(cTRBUNC)->(MsUnLock())
					Else
						GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRLCENT",aReg[1])
					EndIf
				Else
					GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
					While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
						GV2->(dbSeek(xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")))
						If AllTrim(GV2->GV2_ATRCAL) == "7" .And. GV2->GV2_CATVAL == "3" .And. GV2->GV2_IDVLRC == "1" .And. GV2->GV2_IDVLAG == "1"
							cChave := {GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"),;
									   GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE"),;
									   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"),;
									   cEntrNc,;
									   cEmiOri,;
									   cEmiRed,;
									   GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"),;
									   GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR"),;
									   GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP")}
							GFEXFB_BORDER(lTabTemp,cTRBENT,03,12)    
							If GFEXFB_CSEEK(lTabTemp, cTRBENT, @aTRBENT3, 12,cChave)
								If Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRLCENT"))
									If lTabTemp
										RecLock(cTRBENT,.F.)
											(cTRBENT)->QTDCOMP++
										(cTRBENT)->(MsUnLock())
										RecLock(cTRBCCF,.F.)
											(cTRBCCF)->NRLCENT := (cTRBENT)->NRLCENT
										(cTRBCCF)->(MsUnLock())
									Else
										aTRBENT3[idpENT,14]++
										aTRBCCF1[idpCCF,16] := aTRBENT3[idpENT,1]
									EndIf
								EndIf
							Else
								
								cChave := {GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"),;
										   GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE"),;
										   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"),;
										   cEntrNc,;
										   cEmiOri,;
										   cEmiRed}
								GFEXFB_BORDER(lTabTemp,cTRBENT,02,12)    
								GFEXFB_CSEEK(lTabTemp, cTRBENT, @aTRBENT2, 12,cChave)
								If !GFEXFB_3EOF(lTabTemp, cTRBENT, @aTRBENT2, 12) ;
									.And. cChave[1] + cChave[2] + cChave[3] + cChave[4] + cChave[5] + cChave[6] ==; 
									GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT2, 12,"CDTRP")+;
									GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT2, 12,"SEQTRE")+;
									GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT2, 12,"ORIGEM")+;
									cEntrNc+;
									GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT2, 12,"CDREM")+;
									GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT2, 12,"CDDEST")
									If Empty(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT2, 12,"CDCOMP"))
										If Empty( GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRLCENT") )
											If lTabTemp
												RecLock(cTRBENT,.F.)
													(cTRBENT)->QTDCOMP++
													(cTRBENT)->CDCOMP:= (cTRBCCF)->CDCOMP
													(cTRBENT)->CDCLFR:= (cTRBCCF)->CDCLFR
													(cTRBENT)->CDTPOP:= (cTRBCCF)->CDTPOP
												(cTRBENT)->(MsUnLock())
												RecLock(cTRBCCF,.F.)
													(cTRBCCF)->NRLCENT := (cTRBENT)->NRLCENT
												(cTRBCCF)->(MsUnLock())
											Else
												aTRBENT2[idpENT,14]++
												aTRBENT2[idpENT,11] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")
												aTRBENT2[idpENT,12] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR")
												aTRBENT2[idpENT,13] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP")
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRLCENT",aTRBENT2[idpENT,1])
												aSort(aTRBENT3,,,{|x,y| x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[11] + x[12] + x[13] < y[2] + y[3] + y[4] + y[5] + y[6] + y[7] + y[11] + y[12] + y[13]})
											EndIf
										EndIf
									EndIf
								EndIf
								If Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRLCENT"))
									If !GFEXFB_3EOF(lTabTemp, cTRBENT, @aTRBENT2, 12)
										If lTabTemp
											aCopy := {}
											For nX := 1 To Len((cTRBENT)->(dbStruct()))
												aAdd(aCopy,(cTRBENT)->(FieldGet(nX)))
											Next nX
											RecLock(cTRBENT,.T.)
												For nX := 1 To Len(aCopy)
													(cTRBENT)->(FieldPut(nX,aCopy[nX]))
												Next nX
											(cTRBENT)->(MsUnLock())
											RecLock(cTRBENT,.F.)
												(cTRBENT)->QTDCOMP := 1
												(cTRBENT)->CDCOMP:= (cTRBCCF)->CDCOMP
												(cTRBENT)->CDCLFR:= (cTRBCCF)->CDCLFR
												(cTRBENT)->CDTPOP:= (cTRBCCF)->CDTPOP
											(cTRBENT)->(MsUnLock())
											RecLock(cTRBCCF,.F.)
												(cTRBCCF)->NRLCENT := (cTRBENT)->NRLCENT
											(cTRBCCF)->(MsUnLock())
										ElseIf idpENT > 0
											aAdd(aTRBENT2,aClone(aTRBENT2[idpENT]))
											idpENT := Len(aTRBENT2)
											aTRBENT2[idpENT,14] := 1
											aTRBENT2[idpENT,11] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")
											aTRBENT2[idpENT,12] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR")
											aTRBENT2[idpENT,13] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP")
											GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRLCENT",aTRBENT2[idpENT,1])
											aAdd(aTRBENT1,aTRBENT2[idpENT])
											aAdd(aTRBENT3,aTRBENT2[idpENT])
											aSort(aTRBENT3,,,{|x,y| x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[11] + x[12] + x[13] < y[2] + y[3] + y[4] + y[5] + y[6] + y[7] + y[11] + y[12] + y[13]})
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
					EndDo
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
			EndDo
			GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
		EndDo
		GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0)
	EndDo
	
	aSort(aTRBENT2,,,{|x,y| x[2] + x[3] + x[4] + x[5] + x[6] + x[7]  < y[2] + y[3] + y[4] + y[5] + y[6] + y[7]})
	aSort(aTRBENT1,,,{|x,y| x[1] + x[11] < y[1] + y[11]})
	aSort(aTRBENT3,,,{|x,y| x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[11] + x[12] + x[13] < y[2] + y[3] + y[4] + y[5] + y[6] + y[7] + y[11] + y[12] + y[13]})
	aTRBCCF2 := aClone(aTRBCCF1)
	aTRBCCF3 := aClone(aTRBCCF1)
	aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
	aSort(aTRBCCF2  ,,,{|x,y| x[01]+x[05]                  < y[01]+y[05]})
	aSort(aTRBCCF3  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})
	aTRBUNC1 := aClone(aTRBUNC2)
	aTRBUNC3 := aClone(aTRBUNC2)
	aTRBUNC4 := aClone(aTRBUNC2)
	aSort(aTRBUNC1  ,,,{|x,y| x[01]             < y[01]})
	aSort(aTRBUNC2  ,,,{|x,y| x[19]+x[01]       < y[19]+y[01]})
	aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})
	aSort(aTRBUNC4  ,,,{|x,y| x[26]             < y[26]})
	
	GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
		
	GFEXFB_BORDER(lTabTemp,cTRBENT,01,12)    
		
	GFEXFB_BORDER(lTabTemp,cTRBUNC,04,6) 
		
	GFEXFB_2TOP(lTabTemp, cTRBENT, @aTRBENT1, 12) 
	While !GFEXFB_3EOF(lTabTemp, cTRBENT, @aTRBENT1, 12)
		If !lRatComp .And. lSaveLog
			AddToLog("##### Local de entrega: " + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"NRLCENT") + CRLF)
			AddToLog("    # Emitente de origem  - ")
			If GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"SEQTRE") == "01"
				AddToLog("Remente: ")
			Else
				AddToLog("Transportador: ")
			EndIf
				
			AddToLog( AllTrim(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDREM")) + " - " + AllTrim(Posicione("GU3",1,xFilial("GU3") + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDREM"),"GU3_NMEMIT")) + CRLF)
				
			AddToLog("    # Emitente de destino - ")
				
			If GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDTRP") == GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDDEST")
				AddToLog("Transportador: ")
			Else
				AddToLog("Destinatário: ")
			EndIf
			
			AddToLog( AllTrim(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDDEST")) + " - " + AllTrim(Posicione("GU3",1,xFilial("GU3") + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDDEST"),"GU3_NMEMIT")) + CRLF)
			
			AddToLog("    # Cidade origem: " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ORIGEM")) + " - " + AllTrim(Posicione("GU7",1,xFilial("GU7") + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ORIGEM")	,"GU7_NMCID")) + CRLF)
				
			If GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDTRP") != GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"CDDEST") //último trecho
				If Empty(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTNRC")+GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTBAI")+GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTEND"))
					AddToLog("    # Cidade destino: " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"DESTIN")) + " - " + AllTrim(Posicione("GU7",1,xFilial("GU7") + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"DESTIN"),"GU7_NMCID")) + CRLF)
				Else
					AddToLog("    # Endereço destino: " + CRLF)
					AddToLog("        Cidade  : " + AllTrim(If (Empty(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTNRC")),GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"DESTIN"),GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTNRC"))) + " - " + AllTrim(Posicione("GU7",1,xFilial("GU7") + If (Empty(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTNRC")),GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"DESTIN"),GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTNRC")),"GU7_NMCID")) + CRLF)
					AddToLog("        Endereço: " + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTEND") + CRLF)
					AddToLog("        Bairro  : " + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"ENTBAI") + CRLF)
				EndIf
			Else
				AddToLog("    # Cidade destino: " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"DESTIN")) + " - " + AllTrim(Posicione("GU7",1,xFilial("GU7") + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"DESTIN"),"GU7_NMCID")) + CRLF)
			EndIf
		EndIf
		
		GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC4, 6,{GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"NRLCENT")})
		cNrCalcs 	:= ""
		cNrDocs 	:= ""
		aAuxCalcs 	:= {}
		While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC4, 6) .And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC4, 6,"NRLCENT") == GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"NRLCENT")
				
			GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC4, 6,"NRCALC")})
			If !Empty(cNrCalcs)
				cNrCalcs += ","
			EndIf
			aAdd(aAuxCalcs, GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC4, 6,"NRCALC"))
			cNrCalcs += GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC4, 6,"NRCALC")
			While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC4, 6,"NRCALC")
				If !Empty(cNrDocs)
					cNrDocs += ","
				EndIf
				cNrDocs += AllTrim(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC"))
				GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
			EndDo
			GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
		EndDo
			
		If lRatComp
			aAdd(aNrCalcs, aAuxCalcs)
			aAdd(aNrDocs,{cNrDocs})
		EndIf
			
		If !lRatComp .And. lSaveLog
			AddToLog("    # Unidades: " + cNrCalcs + CRLF)
			AddToLog("    # Documentos: " + cNrDocs + CRLF)
			AddToLog("    # Trecho: " + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"SEQTRE") + CRLF + CRLF)
		EndIf
		GFEXFB_8SKIP(lTabTemp, cTRBENT, 12)
	EndDo
	
	If lRatComp .And. s_TREENTR == "1"
		GFEXFB_BORDER(lTabTemp,cTRBENT,01,12)
		
		nI := 1
		
		GFEXFB_2TOP(lTabTemp, cTRBENT, @aTRBENT1, 12) 
		While !GFEXFB_3EOF(lTabTemp, cTRBENT, @aTRBENT1, 12)
			AddToLog("		Validando quantidade de entregas... " + CRLF)
			AddToLog("    	Agrupador de entrega: " + GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"NRLCENT") + CRLF)
			AddToLog("    	Quantidade de unidades de cálculo: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDENTR")) + CRLF + CRLF)
			
			If GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDENTR") > 1
				For nX := 1 To Len(aNrCalcs[nI])
					GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9) 
					If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9, {aNrCalcs[nI][nX]})
						While GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == aNrCalcs[nI][nX] .And.; 
							  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9)
							GV2->(dbSetOrder(1))
							If GV2->(dbSeek(xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")))
								If AllTrim(GV2->GV2_ATRCAL) == "7"
									nNovoVal := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") / GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDENTR")
									
									AddToLog("    	Efetuando o cálculo do novo valor... " + CRLF)
									AddToLog("		Unidade de Cálculo: " + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") + CRLF)
									AddToLog("    	Valor Original: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF)
									AddToLog("    	Fator de Rateio (1/" + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDENTR")) + ") = " + cValToChar(1/GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDENTR")) + CRLF)
									AddToLog("    	Novo Valor: " + cValToChar(nNovoVal) + CRLF + CRLF)
									
									aTRBCCF1[idpCCF,8] := nNovoVal
								EndIf
							EndIf
							GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
						EndDo
					EndIf
				Next nX	
			Else
				AddToLog("		A entrega possui apenas uma unidade de cálculo, não necessita de rateio. " + CRLF + CRLF)
			EndIf
				
			nI++
				
			GFEXFB_8SKIP(lTabTemp, cTRBENT, 12)
		EndDo
	EndIf

	GFEXFB_ARESTAREA(lTabTemp,aAreaAGRU,0)
	RestArea(aAreaGV2)
	GFEXFB_ARESTAREA(lTabTemp,aAreaCCF,9)
	GFEXFB_ARESTAREA(lTabTemp,aAreaUNC,6)
	GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7)
	GFEXFB_ARESTAREA(.F.,aAreaGRU,4)	
Return

Function GetTpentr(cTpLocEntr,cIDVLAG) 
Local cTpEntr := ''
	//Quando o tipo do componente for taxa,entrega,valor por romaneio e valor por entrega, a quantidade sempre será 1 na função GFEQtdeEntr 
	If !Empty( cTpLocEntr )
		If  GV2->GV2_IDVLRC == '2' .OR. (GV2->GV2_CATVAL == '3' .And. AllTrim(GV2->GV2_ATRCAL) == '7' .And. GV2->GV2_IDVLRC == '1' .And. cIDVLAG == '1')
			cTpEntr := '2'
		Else
			cTpEntr := '1'
		EndIf
	EndIf
Return cTpEntr

Function GFEXFBLOCE(cNrCalc) //GFEXFBLOCE

Local aAreaUNC := GFEXFB_9GETAREA(lTabTemp, cTRBUNC, 6)
Local cLocEntr := ""
	GFEXFB_BORDER(lTabTemp,cTRBUNC,1,6) 
	If GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC1, 6,{cNrCalc})
		cLocEntr := GFEXFB_5CMP(lTabTemp, cTrbUNC, @aTRBUNC1, 6,"NRLCENT")
	EndIf
	
GFEXFB_ARESTAREA(lTabTemp, aAreaUNC, 6)
Return cLocEntr

/*/{Protheus.doc} TemCrgComp
	Retorna se o romaneio posicionado tem carga compartilhada.
	É considerado se tem carga compartilhada quando o campo que contém a informação coincidente com o critério de rateio está preenchido
@author siegklenes.beulke
@since 15/06/2016
@version 1.0
@example
TemCrgComp()
/*/
Function TemCrgComp(lLog)
	Local lRet := .F.
	Local cCriRat
	Local nVal
	Default lLog := .F.
	While .T.
		
		cCriRat := If(Empty(GetNewPar("MV_CRIRAT", "1")), "1", GetNewPar("MV_CRIRAT", "1"))
			
		If lLog
			AddToLog(CRLF + "Verificando compartilhamento de carga" + CRLF )
			AddToLog("Critério de rateio: " + GFEDsCriRat(cCriRat) )
		EndIf
		If !(cCriRat $ "1;2;3;4") .And. !Empty(cCriRat)
			If lLog
				AddToLog(" --->Não atendido" + CRLF)
			EndIf
			Exit
		Else
			If lLog
				AddToLog(" --->OK" + CRLF)
			EndIf
		EndIf
			
		If lLog
			AddToLog("Origem da quantidade para rateio" + GFEDsCrgComp(cCriRat) + ": " )
		EndIf
		nVal := GFEVlrCrg(cCriRat)
			
		If nVal != 0
			If lLog
				AddToLog(cValToChar(nVal) + " --->OK" + CRLF)
			EndIf
		Else
			If lLog
				AddToLog(cValToChar(nVal) + " --->Não atendido" + CRLF)
			EndIf
			Exit
		EndIf
		lRet := .T.
		
		Exit
	EndDo
	
Return lRet

Static Function GFECampoCrg(cCriterio)
Return {"GWN_CPESO","GWN_CVAL","GWN_CVOL","GWN_CQTDE"}[Val(cCriterio)]

Static Function GFEVlrCrg(cCriterio)
	Local nVal := 0
	Do Case
		Case Val(cCriterio) == 1
			nVal := GWN->GWN_CPESO
		Case Val(cCriterio) == 2
			nVal := GWN->GWN_CVAL
		Case Val(cCriterio) == 3
			nVal := GWN->GWN_CVOL
		Case Val(cCriterio) == 4
			nVal := GWN->GWN_CQTDE
		OtherWise
			nVal := GWN->GWN_CPESO
	EndCase
Return nVal

Static Function GFETcfCampoCrg(cCriterio)
Return {"PESOR","VALOR","VOLUME","QTDE"}[Val(cCriterio)]

Static Function GFEDsCrgComp(cCriterio)
	Local cCampo := GFECampoCrg(cCriterio)
	Local cAlBkp := Alias()
	
	Static _DescrCpo := {"","","",""}
	
	If Empty(_DescrCpo[Val(cCriterio)])
		
		SX3->(dbsetorder(2))
		SX3->(dbSeek(cCampo))
		_DescrCpo[Val(cCriterio)] := X3Titulo()
		
	EndIf
	
	If cAlBkp != Nil .And. !Empty(cAlBkp)
		dbSelectArea(cAlBkp)
	EndIf
Return _DescrCpo[Val(cCriterio)]

Function GULLocaliza(cCepDes,cSelDC,cDs,lRota,lFx)
	Local cAl
	Local cQuery := ""
	Local aArea := GetArea()

	cCepDes := GetDtoVal(cCepDes)
	cQuery += "SELECT GUL_CEPINI, GUL_CEPFIM, GU9_NMREG, GUL.R_E_C_N_O_ GULRECNO"
	cQuery += "	FROM " + RetSqlName("GUL") + " GUL INNER JOIN " + RetSqlName("GU9") + " GU9"
	cQuery += "	ON GU9_NRREG = GUL_NRREG "
	cQuery += "WHERE GU9_FILIAL = '" + xFilial("GU9") + "'"
	cQuery += "	AND GUL_FILIAL = '" + xFilial("GUL") + "'"
	cQuery += "	AND GUL.D_E_L_E_T_ = ' '"
	cQuery += "	AND GU9.D_E_L_E_T_ = ' '"
	cQuery += "	AND (GUL_CEPINI <= '" + StrZero(cCepDes, 8) + "'"
	cQuery += "	AND GUL_CEPFIM >= '" + StrZero(cCepDes, 8) + "' )"
	cQuery += "	AND GU9_NRREG = '" + cSelDC + "'"
	cQuery += "	AND GU9_SIT = '1'"
	If GFXTB12117("GVR") .AND. s_GFEGVR
		cQuery += "UNION "
		cQuery += "SELECT GUL_CEPINI, GUL_CEPFIM, GU9B.GU9_NMREG, GUL.R_E_C_N_O_ GULRECNO"
		cQuery += "	FROM " + RetSqlName("GUL") + " GUL INNER JOIN " + RetSqlName("GVR") + " GVR"
		cQuery += "	ON GVR_NRREGR = GUL_NRREG"
		cQuery += "	INNER JOIN " + RetSqlName("GU9") + " GU9A"
		cQuery += "	ON GVR_NRREGR = GU9A.GU9_NRREG"
		cQuery += "	INNER JOIN " + RetSqlName("GU9") + " GU9B"
		cQuery += "	ON GVR_NRREG = GU9B.GU9_NRREG "
		cQuery += "WHERE GU9A.GU9_FILIAL = '" + xFilial("GU9") + "'"
		cQuery += "	AND GU9B.GU9_FILIAL = '" + xFilial("GU9") + "'"
		cQuery += "	AND GUL_FILIAL = '" + xFilial("GUL") + "'"
		cQuery += "	AND GVR_FILIAL = '" + xFilial("GVR") + "'"
		cQuery += "	AND GUL.D_E_L_E_T_ = ' '"
		cQuery += "	AND GU9A.D_E_L_E_T_ = ' '"
		cQuery += "	AND GU9B.D_E_L_E_T_ = ' '"
		cQuery += "	AND GVR.D_E_L_E_T_ = ' '"
		cQuery += "	AND (GUL_CEPINI <= '" + StrZero(cCepDes, 8) + "'"
		cQuery += "	AND GUL_CEPFIM >= '" + StrZero(cCepDes, 8) + "' ) "
		cQuery += "	AND GVR_NRREG = '" + cSelDC + "'"
		cQuery += "	AND GU9A.GU9_SIT = '1'"
		cQuery += "	AND GU9B.GU9_SIT = '1'"
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAl := MpSysOpenQuery(cQuery)
	
	If !(cAl)->(Eof()) .And. !Empty((cAl)->GULRECNO)
		cDs := AllTrim((cAl)->GU9_NMREG) + "; " + STR0626 + " : " + (cAl)->GUL_CEPINI + ", " + STR0627 + " : " + (cAl)->GUL_CEPFIM + ". " + STR0628 + " : " + AllTrim(Str(cCepDes)) // "Faixa de CEP inicial" ### "Final" ### "CEP selecionado"
		lRota := .T.
		lFx   := .T.
	EndIf

	(cAl)->(dbCloseArea())
	RestArea(aArea)
	
Return

Static Function AddCompsGUC(aComps,cCdEmit,cNrTab,cNrNeg,cFaixa,cNrRota,lTodos)
	Local nAdd 		:= 0
	Local lGFEXFB04 := ExistBlock("GFEXFB04")
	Local lRetPE    := .T.
	Local cAliasGUC	:= GetNextAlias()
	Local cAliasGU3 := GetNextAlias()
	Local cGerEmi	:= PADR("*", TamSX3("GUC_EMICOM")[1])
	Local cGerFXTV	:= PADR("*", TamSX3("GUC_CDFXTV")[1])
	Local cGerRota	:= PADR("*", TamSX3("GUC_NRROTA")[1])
	Local aAuxComps := {}
	Local aPreComps	:= {}
	Local nX		:= 0
	Local nPriorit	:= 0
	Local lExiNRCID := GFXCP2610("GUC_NRCID")
	Local lExiNATUR := GFXCP2610("GUC_NATUR")
	Local cGerNrCid := ""
	Local cGerNatur	:= ""
	Local cVzNatur  := ""
	Local cEmiCid	:= ""
	Local cEmiNat	:= ""
	Local cWhere	:= ""
	Local cEmiCom	:= GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDEMIT")
	
	Default lTodos 	:= .F.

	BeginSQL Alias cAliasGU3
		SELECT GU3.GU3_NRCID NRCID,
			   GU3.GU3_NATUR NATUR
		FROM %Table:GU3% GU3
		WHERE GU3.GU3_CDEMIT = %Exp:cEmiCom%
		AND Gu3.%NotDel%
	EndSQL

	If !((cAliasGU3)->(EoF()))
		cEmiCid := (cAliasGU3)->NRCID
		cEmiNat := (cAliasGU3)->NATUR
	EndIf

	(cAliasGU3)->(dbCloseArea())

	cWhere := "%"
	cCampos := "%"
	
	If lExiNRCID
		cGerNrCid := Space(TamSX3("GUC_NRCID")[1])

		cCampos += " GUC.GUC_NRCID NRCID,"
		cWhere += "AND (GUC.GUC_NRCID = '" + cEmiCid + "' OR GUC.GUC_NRCID = '" + cGerNrCid + "')"
	EndIf

	If lExiNATUR
		cGerNatur := PADR("*", TamSX3("GUC_NATUR")[1])
		cVzNatur  := PADR("", TamSX3("GUC_NATUR")[1])

		cCampos += " GUC.GUC_NATUR NATUR,"
		cWhere += "AND (GUC.GUC_NATUR = '" + cEmiNat + "' OR GUC.GUC_NATUR = '" + cGerNatur + "' OR GUC.GUC_NATUR = '" + cVzNatur + "')"
	EndIf

	cWhere += "%"
	cCampos += "%"

	BeginSQL Alias cAliasGUC
		SELECT GUC.GUC_CDCOMP CDCOMP,
			   GUC.GUC_EMICOM EMICOM,
			   GUC.GUC_CDFXTV CDFXTV,
			   GUC.GUC_NRROTA NRROTA,
			   %Exp:cCampos%
			   GUC.R_E_C_N_O_ RECNOGUC
		FROM %Table:GUC% GUC
		WHERE GUC.GUC_FILIAL = %xFilial:GUC%
		AND GUC.GUC_CDEMIT = %Exp:cCdEmit%
		AND GUC.GUC_NRTAB = %Exp:cNrTab%
		AND GUC.GUC_NRNEG = %Exp:cNrNeg%
		AND (GUC.GUC_CDFXTV = %Exp:cFaixa% OR GUC.GUC_CDFXTV = %Exp:cGerFXTV%)
		AND (GUC.GUC_NRROTA = %Exp:cNrRota% OR GUC.GUC_NRROTA = %Exp:cGerRota%)
		AND (GUC.GUC_EMICOM = %Exp:cEmiCom% OR GUC.GUC_EMICOM = %Exp:cGerEmi%)
		%Exp:cWhere%
		AND GUC.%NotDel%
	EndSQL

	Do While (cAliasGUC)->(!Eof())
		GUC->(dbGoTo((cAliasGUC)->RECNOGUC))

		//Ponto de Entrada que permite indicar quais os componentes adicionais
		//por emitente podem ser utilizados no cálculo do frete
		If lGFEXFB04
			lRetPE := ExecBlock("GFEXFB04",.F.,.F.)
			lRetPE := Iif(ValType(lRetPE)=="L",lRetPE,.F.)
		EndIf

		If lRetPE
			nPriorit := 0

			If (cAliasGUC)->CDFXTV <> cGerFXTV .And. (cAliasGUC)->NRROTA <> cGerRota
				nPriorit += 1000
			EndIf

			If (cAliasGUC)->EMICOM <> cGerEmi
				nPriorit += 100
			EndIf

			If lExiNRCID .And. (cAliasGUC)->NRCID <> cGerNrCid
				nPriorit += 50
			EndIf

			If lExiNATUR .And. (cAliasGUC)->NATUR <> cGerNatur
				nPriorit += 20
			EndIf
		
			aAdd(aAuxComps,{(cAliasGUC)->CDCOMP,(cAliasGUC)->RECNOGUC,nPriorit})
		EndIf
		
		(cAliasGUC)->(dbSkip())
	EndDo

	For nX := 1 To Len(aAuxComps)
		nIndice := aScan(aPreComps,{|x| x[1] == aAuxComps[nX][1]})

		If nIndice == 0
			aAdd(aPreComps, aAuxComps[nX])
		Else
			If aAuxComps[nX][3] > aPreComps[nIndice][3]
				aPreComps[nIndice][2] := aAuxComps[nX][2]
				aPreComps[nIndice][3] := aAuxComps[nX][3]
			EndIf
		EndIf
	Next nX

	For nX := 1 To Len(aPreComps)
		GUC->(dbGoTo(aPreComps[nX][2]))

		aAdd(aComps,{GUC->GUC_CDCOMP,GUC->GUC_VLFIXN,GUC->GUC_PCNORM,GUC->GUC_VLUNIN,GUC->GUC_VLFRAC,GUC->GUC_VLMINN,GUC->GUC_VLLIM,GUC->GUC_VLFIXE,GUC->GUC_PCEXTR,GUC->GUC_VLUNIE,GUC->GUC_CALCEX,"1", GUC->GUC_EMICOM})
	Next nX

	If Len(aComps) == 0
		AddToLog(STR0351 + CRLF) //"        Não há componentes cadastrados para o emitente nesta faixa."
	ElseIf nAdd == 0
		AddToLog("        Não há novos componentes aplicáveis para o emitente nesta faixa." + CRLF)
	EndIf

Return .T.

Static Function AddComps(aComps,cCdEmit,cNrTab,cNrNeg,cFaixa,cNrRota)
	Local nAdd := 0
	Local lFracExced := GFXCP2510("GV1_FRACEX")

	AddToLog(CRLF + STR0352 + cFaixa + ":" + CRLF)	 //"        Componentes gerais da tarifa na faixa "

	//Componentes da tarifa da tabela de frete
	GV1->(dbSetOrder(01))
	GV1->(dbSeek(xFilial("GV1")+cCdEmit+cNrTab+cNrNeg+cFaixa+cNrRota,.T.))
	While !GV1->(Eof()) ;
		.And. GV1->GV1_FILIAL == xFilial("GV1") ;
		.And. GV1->GV1_CDEMIT == cCdEmit ;
		.And. GV1->GV1_NRTAB  == cNrTab ;
		.And. GV1->GV1_NRNEG  == cNrNeg ;
		.And. GV1->GV1_CDFXTV == cFaixa ;
		.And. GV1->GV1_NRROTA == cNrRota

		// Só adiciona se nao existir no array aComps
		If aScan(aComps,{|aComp| aComp[1] == GV1->GV1_CDCOMP}) == 0
			AddToLog("        " + GV1->GV1_CDCOMP + CRLF)
			aAdd(aComps,{GV1->GV1_CDCOMP,GV1->GV1_VLFIXN,GV1->GV1_PCNORM,GV1->GV1_VLUNIN,GV1->GV1_VLFRAC,GV1->GV1_VLMINN,GV1->GV1_VLLIM,GV1->GV1_VLFIXE,GV1->GV1_PCEXTR,GV1->GV1_VLUNIE,GV1->GV1_CALCEX,"0", iif(lFracExced, GV1->GV1_FRACEX, 0)})
			nAdd++
		EndIf

		GV1->(dbSkip())
	EndDo
	If nAdd == 0
		AddToLog("        Não há novos componentes aplicáveis nesta faixa." + CRLF)
	EndIf
Return

Static Function GetBit(cStrBit,nPosBit)
	Local cBit := " "
	Local nBit := nPosBit - 1
	
	If Len(cStrBit) > nBit .And. nBit > 0
		cBit := SubStr(cStrBit,Len(cStrBit) - nBit, 1)
	EndIf

Return cBit

Function GFEXFBDROT(aSeek)

	Local cTpRotas
	
	// SE FOR ARRAY, PODE EXECUTAR ESTE PROCEDIMENTO
	if lNovoMod == .T.
		GFEXFB_CSEEK(.F., , aTRBROT1, 13, aSeek)
		While !GFEXFB_3EOF(.F., , aTRBROT1, 13) .And.;
			aSeek[1] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC") .And.;
			aSeek[2] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRP" ) .And.;
			aSeek[3] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTAB" ) .And.;
			aSeek[4] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEG" ) .And.;
			aSeek[5] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA" )
			
			cTpRotas := NTOC(GFEXFB_5CMP(.F., , aTRBROT1, 13,"PRIORI" ),2)
			If GetBit(cTpRotas,6) != "1" .And. GetBit(cTprotas,12) != "1" // Não é uma rota do tipo todas as rotas
				ADel(aTRBROT1,idpRot)
				ASize(aTRBROT1,Len(aTRBROT1)-1)
			EndIf
			GFEXFB_8SKIP(.F., , 13)
		EndDo
	EndIf
Return

Function GFEAddTodFx(cTodFaixa,cCodFaixa) //AddTodFx
	Local aLinhaRot := {}
	Local nX
	If GFEXFB_4IDX(13) == Nil
		Return
	EndIf
	If Empty(cTodFaixa) .And. s_GFETROT == "2" 
		cTodFaixa := cCodFaixa
	EndIf
	If !Empty(cTodFaixa) .And. !GFEXFB_CSEEK(.F., , aTRBROT1, 13, {GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"),;
																	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
																	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"),;
																	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),;
																	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
		aAdd(aTRBROT1,  {GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC") ,; //Numero do Calculo
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") ,; //Chave negociação pai
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") ,; //Chave negociação pai
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG" ),; //Chave negociação pai
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA") ,; //Chave negociação pai
						 ""                ,; //Chave negociação pai         
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") ,; //Chave negociação filha
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") ,; //Chave negociação filha
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG" ),; //Chave negociação filha
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TPROTA") ,; //Prioridade
						  0                ,; //Prioridade Faixa             
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA") ,; //Todas as rotas
						 ""  })               //Todas as faixas
		idpROT := Len(aTRBROT1)
	ElseIf idpROT == 0
		idpROT := 99999999
	EndIf
	
	While !GFEXFB_3EOF(.F., , aTRBROT1, 13) .And.;
		GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC") == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC") .And.;
		GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") == GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRP" ) .And.;
		GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTAB" ) .And.;
		GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG" ) == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEG" ) .And.;
		GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA") == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA" )
		If !Empty(cTodFaixa)
			GFEXFB_5CMP(.F., ,  aTRBROT1, 13, "CDFXTV" , cCodFaixa)
			GFEXFB_5CMP(.F., ,  aTRBROT1, 13, "CDFXTOD", cTodFaixa)
			GFEXFB_5CMP(.F., ,  aTRBROT1, 13, "PRIFAI", 2 )
			If cTodFaixa != cCodFaixa
				aAdd(aLinhaRot,aClone(aTRBROT1[idpROT]))
			EndIf
		EndIf
		GFEXFB_8SKIP(.F., , 13) 
	EndDo

	For nX := 1 To Len(aLinhaRot)
		aAdd(aTRBROT1,aClone(aLinhaRot[nX]))
		idpROT := Len(aTRBROT1)
		GFEXFB_5CMP(.F., ,  aTRBROT1, 13, "CDFXTV" , cCodFaixa)
		GFEXFB_5CMP(.F., ,  aTRBROT1, 13, "CDFXTOD", cCodFaixa)
		GFEXFB_5CMP(.F., ,  aTRBROT1, 13, "PRIFAI", 1 )
	Next nX
Return

Function GFEXFBMTR()
	Local lAdd := .F.
	Local aTodRota := {}
	Local nX,nY
	Local nPos
	
	If !lTabTemp
		aTRBSTF2 := aClone(aTRBSTF1)
		aSort(aTRBSTF2,,,{|x,y| x[5] + x[6] + x[7] < y[5] + y[6] + y[7]})
	EndIf
	
	GFEXFB_BORDER(lTabTemp,cTRBSTF,02,2)
	GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF2, 2)
	
	While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF2, 2)
		cTprotas := NTOC(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"TPROTA"),2)
		
		nPos := aScan(aTodRota,{|x|x[1] == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"TABVIN")})
		If nPos == 0
			aAdd(aTodRota,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"TABVIN"),{},.F.})
			nPos := Len(aTodRota)
		EndIf
		
		If s_GFETROT == "2" .Or. GetBit(cTpRotas,6) == "1" .Or. GetBit(cTprotas,12) == "1"
			aAdd(aTodRota[nPos,2],{GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2),GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"TPROTA"),GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRROTA")})
		Else
			aTodRota[nPos,3] := .T.
		EndIf
		GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
	EndDo
	
	If Len(aTodRota) > 0
	
		If s_GFETROT == "1"
			For nX := 1 To Len(aTodRota)
				For nY := 1 To Len(aTodRota[nX,2])
					GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, aTodRota[nX,2,nY,1])
					aSeek := {GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRCALC"),;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"EMIVIN"),;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"TABVIN"),;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRNEG" ),;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRROTA")}
					GFEXFB_CSEEK(.F., , aTRBROT1, 13, aSeek)
					
					While !GFEXFB_3EOF(.F., , @aTRBROT1, 13) .And.;
						aSeek[1] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC") .And.;
						aSeek[2] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRP" ) .And.;
						aSeek[3] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTAB" ) .And.;
						aSeek[4] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEG" ) .And.;
						aSeek[5] == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA")
						idpAnt := idpROT
						If Len(aSeek) == 5
							aAdd(aSeek,GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"CDFXTV"))
						EndIf
						If !Empty(GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV")) .And. GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV") != aSeek[6]
							GFEXFB_8SKIP(.F., , 13)
							Loop
						EndIf
						GFEXFB_CSEEK(lTabTemp, cTRBSTF, @aTRBSTF2, 2,{GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC")})
						While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF2, 2) .And. (!lTabTemp .Or. !(cTRBSTF)->(DELETED())) .And. GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRCALC") == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC")
							idpROT := idpAnt
							aAdd(aTRBROT1,aClone(aTRBROT1[idpROT]))
							idpROT := Len(aTRBROT1)
							GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRP" , GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"CDTRP" ))
						    GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTAB" , GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRTAB" ))
						    GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEG" , GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRNEG" ))
						    GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA", GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRROTA"))
						    GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV", GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"CDFXTV"))
						    GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
					    ENDDO
					    idpROT := idpAnt
						GFEXFB_8SKIP(.F., , 13)
					EndDo
				Next nY
			Next nX
		EndIf
		For nY := 1 To Len(aTodRota)
			If aTodRota[nY,3] //Se há rotas específicas, não é necessário manter o todas as rotas
				
				For nX := 1 To Len(aTodRota[nY,2])
					
					GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, aTodRota[nY,2,nX,1])
					If lTabTemp
						RecLock(cTRBSTF, .F.)
						(cTRBSTF)->(dbDelete())
						(cTRBSTF)->(MsUnlock())
					Else
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"ERRO","1")
					EndIf
					
				Next nX
				
			Else
				
				aSort(aTodRota[nY,2],,,{|x,y| x[2] < y[2] .Or. (x[2] == y[2] .And. x[3] < y[3])}) //Eliminar primeiro o todas as rotas que é menos especifico para o mais específico + todas rotas
				
				For nX := 2 To Len(aTodRota[nY,2])
					GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, aTodRota[nY,2,nX,1])
					If lTabTemp
						RecLock(cTRBSTF, .F.)
						(cTRBSTF)->(dbDelete())
						(cTRBSTF)->(MsUnlock())
					Else
						 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"ERRO","1")
					EndIf
				Next nX
			
			EndIf
		Next nY
		If s_GFETROT == "2"
			For nY := 1 To Len(aTodRota)
				GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, aTodRota[nY,2,1,1])
				GFEXFB_CSEEK(.F., , aTRBROT1, 13, {GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRCALC")})
				While !GFEXFB_3EOF(.F., , @aTRBROT1, 13) .And.;
					GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRCALC") == GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRCALC")
					If GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRTAB") == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRTAB" )
					    GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDTRP" , GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"CDTRP" ))
					    GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRNEG" , GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRNEG" ))
					    GFEXFB_5CMP(.F., , aTRBROT1, 13,"NRROTA", GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"NRROTA"))
					    GFEXFB_5CMP(.F., , aTRBROT1, 13,"CDFXTV", GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"CDFXTV"))
				    EndIf
					GFEXFB_8SKIP(.F., , 13)
				EndDo
			Next nY		
		EndIf
		
		If !lTabTemp
			aTRBSTF1 := {}
			For nX := 1 To Len(aTRBSTF2)
				idpSTF := nX
				If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF2, 2,"ERRO" ) != "1"
					aAdd(aTRBSTF1,aClone(aTRBSTF2[nX]))
				EndIf
			Next nX
			aTRBSTF3 := aClone(aTRBSTF1)
			aSort(aTRBSTF1  ,,,{|x,y| x[01]+x[04]+x[05]+x[11]      < y[01]+y[04]+y[05]+y[11]})
			aSort(aTRBSTF3  ,,,{|x,y| x[18]+x[19]+x[05]+x[11]      < y[18]+y[19]+y[05]+y[11]})
		EndIf
		lAdd := .T.
	EndIf					
Return lAdd

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNBTRB
Criação das tabelas temporárias.

@author Elynton Fellipe Bazzo
@since  26/01/2016
/*/
//-------------------------------------------------------------------
Function XFUNBTRB()
	Local oGFETempTable
	If SuperGetMv("MV_GFEBRF",.F.,"1") != "1"
		If (Type("cTRBAGRU") == "U" .Or. Select(cTRBAGRU) == 0)
			
			oGFETempTable	:= GFEXFBTempTable():New()
			
			oGFETempTable:ClearData()	//DEFINIR AGRUPADORES DE CARGA
			oGFETempTable:setAgrupadoresCarga()
			oGFETempTable:CriaTempTable()
			cAliGRU := oGFETempTable:getTableName()
			cTRBAGRU := cAliGRU
			_SetOwnerPrvt("cTRBAGRU",cAliGRU)
			
			oGFETempTable:ClearData()	//DOCUMENTOS DE CARGA
			oGFETempTable:setDocumentoCarga()
			oGFETempTable:CriaTempTable()
			cAliDOC := oGFETempTable:getTableName()
			cTRBDOC := cAliDOC
			_SetOwnerPrvt("cTRBDOC",cAliDOC)
			
			oGFETempTable:ClearData()	//TABELA DO CALCULO DE FRETE
			oGFETempTable:setTabelaCalculoFrete()
			oGFETempTable:CriaTempTable()
			cAliTCF := oGFETempTable:getTableName()
			cTRBTCF := cAliTCF
			_SetOwnerPrvt("cTRBTCF",cAliTCF)
			
			oGFETempTable:ClearData()	//UNIDADES DE CALCULO
			oGFETempTable:setUnidadeCalculo()
			oGFETempTable:CriaTempTable()
			cAliUNC := oGFETempTable:getTableName()
			cTRBUNC := cAliUNC	
			_SetOwnerPrvt("cTRBUNC",cAliUNC)
			
			oGFETempTable:ClearData()	//TRECHOS DA CARGA
			oGFETempTable:setTrechoCarga()
			oGFETempTable:CriaTempTable()
			cAliTRE := oGFETempTable:getTableName()
			cTRBTRE := cAliTRE
			_SetOwnerPrvt("cTRBTRE",cAliTRE)
			
			oGFETempTable:ClearData()	//ITENS DA CARGA
			oGFETempTable:setItensCarga()
			oGFETempTable:CriaTempTable()
			cAliITE := oGFETempTable:getTableName()
			cTRBITE := cAliITE
			_SetOwnerPrvt("cTRBITE",cAliITE)
			
			oGFETempTable:ClearData()	//COMPONENTE DO CALCULO DE FRETE
			oGFETempTable:setComponenteCalculoFrete()
			oGFETempTable:CriaTempTable()
			cAliCCF := oGFETempTable:getTableName()
			cTRBCCF := cAliCCF
			_SetOwnerPrvt("cTRBCCF",cAliCCF)
			
			oGFETempTable:ClearData()
			oGFETempTable:setLocalUnidadeCalculo()
			oGFETempTable:CriaTempTable()
			cAliENT := oGFETempTable:getTableName()
			cTRBENT := cAliENT
			_SetOwnerPrvt("cTRBENT",cAliENT)
			
			oGFETempTable:ClearData()
			oGFETempTable:setSelecaoTabelaFrete()
			oGFETempTable:CriaTempTable()
			cAliSTF := oGFETempTable:getTableName()
			cTRBSTF := cAliSTF
			_SetOwnerPrvt("cTRBSTF",cAliSTF)
			
			oGFETempTable:ClearData()
			oGFETempTable:setSimulacaoFrete()
			oGFETempTable:CriaTempTable()
			cAliSIM := oGFETempTable:getTableName()
			cTRBSIM := cAliSIM
			_SetOwnerPrvt("cTRBSIM",cAliSIM)
			
			oGFETempTable:ClearData()
			oGFETempTable:setCalculoPedagio()
			oGFETempTable:CriaTempTable()
			cAliPED := oGFETempTable:getTableName()
			cTRBPED := cAliPED
			_SetOwnerPrvt("cTRBPED",cAliPED)
			
			If !Empty(oGFETempTable)
				oGFETempTable:= Nil
			EndIf
		EndIf
	Else
		cAliGRU := Nil
		cTRBAGRU := Nil
		_SetOwnerPrvt("cTRBAGRU",cAliGRU)
		
		cAliDOC	:= Nil
		cTRBDOC := Nil
		_SetOwnerPrvt("cTRBDOC",cAliDOC)
		
		cAliTCF	:= Nil
		cTRBTCF := Nil
		_SetOwnerPrvt("cTRBTCF",cAliTCF)
		
		cAliUNC	:= Nil
		cTRBUNC := Nil
		_SetOwnerPrvt("cTRBUNC",cAliUNC)
		
		cAliTRE	:= Nil
		cTRBTRE := Nil
		_SetOwnerPrvt("cTRBTRE",cAliTRE)
		
		cAliITE	:= Nil
		cTRBITE := Nil
		_SetOwnerPrvt("cTRBITE",cAliITE)
		
		cAliCCF	:= Nil
		cTRBCCF := Nil
		_SetOwnerPrvt("cTRBCCF",cAliCCF)
		
		cAliENT := Nil
		cTRBENT := Nil
		_SetOwnerPrvt("cTRBENT",cAliENT)
		
		//TABELAS DE FRETE (STF = Selecao Tabela Frete)
		//arquivo temporario que armazena as tabelas pre-selecionadas
		//com objetivo de realizar um filtro e excluir tabelas invalidas
		cAliSTF := Nil
		cTRBSTF := Nil
		_SetOwnerPrvt("cTRBSTF",cAliSTF)
		
		cAliSIM := Nil
		cTRBSIM := Nil
		_SetOwnerPrvt("cTRBSIM",cAliSIM)
		
		cAliPED := Nil
		cTRBPED := Nil
		_SetOwnerPrvt("cTRBPED",cAliPED)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XFUNBDLTRB
Deleção das tabelas temporárias.

@author Elynton Fellipe Bazzo
@since  26/01/2016
/*/
//-------------------------------------------------------------------
Function XFUNBDLTRB()
	If SuperGetMv("MV_GFEBRF",.F.,"1") != "1"
		GFEDelTab(cTRBAGRU)
		GFEDelTab(cTRBDOC)
		GFEDelTab(cTRBTCF)
		GFEDelTab(cTRBUNC)
		GFEDelTab(cTRBTRE)
		GFEDelTab(cTRBITE)
		GFEDelTab(cTRBCCF)
		GFEDelTab(cTRBENT)
		GFEDelTab(cTRBSTF)
		GFEDelTab(cTRBSIM)
		GFEDelTab(cTRBPED)
	EndIf
Return
/*/{Protheus.doc} XFBGWUDC
	Retorna o array de trechos utilizado no cálculo de frete
@author siegklenes.beulke
@since 30/01/2017
@version undefined
@param cNrRom, characters, Romaneio, se informado, buscará todos os documentos de carga relacionados ao romaneio.
@param cGW1_FILIAL, characters, Filial do documento de carga, usado para recuperar todos os trechos de apenas um documento de carga
@param cGW1_CDTPDC, characters, Tipo do documento de carga, usado para recuperar todos os trechos de apenas um documento de carga
@param cGW1_EMISDC, characters, Emissor do documento de carga, usado para recuperar todos os trechos de apenas um documento de carga
@param cGW1_SERDC, characters, Série do documento de carga, usado para recuperar todos os trechos de apenas um documento de carga
@param cGW1_NRDC, characters, Número do documento de carga, usado para recuperar todos os trechos de apenas um documento de carga
@example
aTrechos := XFBGWUDC(,GW1->GW1_FILIAL,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC)
			For nX := 1 To Len(aTrechos)
				aAdd(aTrchDoc,aClone(aTrechos[nX]))
			Next nX
@see (links_or_references)
/*/
Function XFBGWUDC(cNrRom,cGW1_FILIAL,cGW1_CDTPDC,cGW1_EMISDC,cGW1_SERDC,cGW1_NRDC,cGWU_SEQ)
	Static cAlQryTrc := GetNextAlias()
	Local aTrcDoc := {}
	Local cQuery := "SELECT GWU_FILIAL,"  

	cQuery += "GWU_SEQ,"
	cQuery += "GWU_CDTRP,"
	If !Empty(cNrRom)
		cQuery += "GWU_CDTPDC,"
		cQuery += "GWU_EMISDC,"
		cQuery += "GWU_SERDC ,"
		cQuery += "GWU_NRDC  ,"
	EndIf
	cQuery += "GWU_NRCIDD,"
	cQuery += "GWU_CDTPVC,"
	cQuery += "GWU_PAGAR,"
	If GFXCP12117("GWU_NRCIDO")
		cQuery += "GWU_NRCIDO,"
		cQuery += "GWU_CEPO,"
		cQuery += "GWU_CEPD,"
		cQuery += "GWU_CDCLFR,"
		cQuery += "GWU_CDTPOP "
	Else
		cQuery += "' ' GWU_NRCIDO,"
		cQuery += "' ' GWU_CEPO  ,"
		cQuery += "' ' GWU_CEPD  ,"
		cQuery += "' ' GWU_CDCLFR,"
		cQuery += "' ' GWU_CDTPOP "
	EndIf
	cQuery += "	FROM " + RetSqlName("GWU")+ " GWU "
	
	If !Empty(cNrRom)
		cQuery += " INNER JOIN " + RetSQLName("GW1") + " GW1 "
		cQuery += "    ON GWU_FILIAL = GW1_FILIAL AND GWU_CDTPDC = GW1_CDTPDC"
		cQuery += "   AND GWU_EMISDC = GW1_EMISDC AND GWU_SERDC = GW1_SERDC AND GWU_NRDC = GW1_NRDC"
	EndIf
	cQuery += "	WHERE GWU.D_E_L_E_T_ = ' '"
	If Empty(cNrRom)
		cQuery += "	AND GWU_FILIAL = '" + cGW1_FILIAL + "'"
		cQuery += "	AND GWU_CDTPDC = '" + cGW1_CDTPDC + "'"
		cQuery += "	AND GWU_EMISDC = '" + cGW1_EMISDC + "'"
		cQuery += "	AND GWU_SERDC = '" + cGW1_SERDC + "'"
		cQuery += "	AND GWU_NRDC = '" + cGW1_NRDC + "'"
	Else
		cQuery += "	AND GW1.D_E_L_E_T_ = ' '"
		cQuery += "	AND GW1_NRROM      = '" + cNrRom + "'"
	EndIf
	If !Empty(cGWU_SEQ)
		cQuery += "	AND GWU_SEQ = '" + cGWU_SEQ + "'"
	EndIf
	
	MPSysOpenQuery(ChangeQuery(cQuery),cAlQryTrc)
	If Empty(cNrRom)
		While !(cAlQryTrc)->(Eof())
	
			aAdd(aTrcDoc, { cGW1_EMISDC,; //Emitente do Documento
							cGW1_SERDC,;  //Serie do Documento
							cGW1_NRDC,;   //Numero do Documento
							cGW1_CDTPDC,; //Tipo do Documento
							(cAlQryTrc)->GWU_SEQ,;    //Sequencia do Trecho
							(cAlQryTrc)->GWU_CDTRP,;  //Transportador do Trecho
							(cAlQryTrc)->GWU_NRCIDD,; //Cidade Destino
							(cAlQryTrc)->GWU_CDTPVC,; //Tipo de Veiculo do Trecho
							(cAlQryTrc)->GWU_PAGAR,;  //Pagar trecho ou nao
							(cAlQryTrc)->GWU_NRCIDO,;
							(cAlQryTrc)->GWU_CEPO  ,;
							(cAlQryTrc)->GWU_CEPD  ,;
							(cAlQryTrc)->GWU_CDCLFR,;
							(cAlQryTrc)->GWU_CDTPOP,;
							cGW1_FILIAL })
	
			(cAlQryTrc)->(dbSkip())					  
		EndDo
	Else
		While !(cAlQryTrc)->(Eof())
	
			aAdd(aTrcDoc, {;
			(cAlQryTrc)->GWU_EMISDC,; //Emitente do Documento
			(cAlQryTrc)->GWU_SERDC,;  //Serie do Documento
			(cAlQryTrc)->GWU_NRDC,;   //Numero do Documento
			(cAlQryTrc)->GWU_CDTPDC,; //Tipo do Documento
			(cAlQryTrc)->GWU_SEQ,;    //Sequencia do Trecho
			(cAlQryTrc)->GWU_CDTRP,;  //Transportador do Trecho
			(cAlQryTrc)->GWU_NRCIDD,; //Cidade Destino
			(cAlQryTrc)->GWU_CDTPVC,; //Tipo de Veiculo do Trecho
			(cAlQryTrc)->GWU_PAGAR,;  //Pagar trecho ou nao
			(cAlQryTrc)->GWU_NRCIDO,;
			(cAlQryTrc)->GWU_CEPO  ,;
			(cAlQryTrc)->GWU_CEPD  ,;
			(cAlQryTrc)->GWU_CDCLFR,;
			(cAlQryTrc)->GWU_CDTPOP})
	
			(cAlQryTrc)->(dbSkip())					  
		EndDo
	EndIf
	
	(cAlQryTrc)->(dbCloseArea())	  
	aSort(aTrcDoc,,,{|x,y| x[4]+x[1]+x[2]+x[3]+x[5]      < y[4]+y[1]+y[2]+y[3]+y[5]})
Return aTrcDoc

Static Function MostraErro(cCalc,cProb,cSolu)
	Local nX,nY
	cProb := cSolu := ""
	For nX := 1 To Len(aErroCalc)
		If AllTrim(AllTrim(aErroCalc[nX][1])) == AllTrim(cCalc)
			aErr:=GFECalcErr(aErroCalc[nX][2])
			For nY:= 1 to Len(aErroCalc[nX][4])
				aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aErroCalc[nX][4][nY])
			Next
			If !Empty(cProb)
				cProb += cSeparador
				cSolu += cSeparador
			EndIf
			cProb += aErr[1]
			cSolu += aErr[2]
		EndIf
	Next
	oMGet1:Show()
	oMGet2:Show()

	oSay1:Show()
	oSay2:Show()
	//oSay3:Hide()
	oList1:Hide()

	oMGet1:Refresh()
	oMGet2:Refresh()
Return

Static Function MostraAviso(cCalc)
	Local nX,nY
	aItemText := {}
	For nX := 1 To Len(aErroCalc)
		If AllTrim(aErroCalc[nX][1]) == AllTrim(cCalc)
			aErr:=GFECalcErr(aErroCalc[nX][2])

			For nY:= 1 to Len(aErroCalc[nX][4])
				aErr[3] := StrTran(aErr[3],"[" + cValToChar(nY) + "]",aErroCalc[nX][4][nY])
			Next

			//						aErr[3] := IIf(lError .Or. lSimulacao, "Unid. de Cálc ", "Cálculo ") + AllTrim(Str(Val(cCalc))) + " " +  aErr[3]
			aAdd(aItemText,aErr[3])
		EndIf
	Next nX


	aAdd(aItemText,IIf(lError .Or. lSimulacao, "Unid. de Cálc ", "Cálculo ") +AllTrim(Str(Val(cCalc))) + " gerado com sucesso.")

	oMGet1:Hide()
	oMGet2:Hide()

	oSay1:Hide()
	oSay2:Hide()
	oList1:SetArray(aItemText)
	oList1:Show()
	oList1:Refresh()

Return


/*/{Protheus.doc} GFEXCOMP
	Retorna os componentes.
@author marcos.wagner
@since 24/10/2016
@version 1.0
@example
GFEXCOMP(aTblFrFUNB)
/*/
Function GFEXCOMP(aTblFrFUNB)
Local aOldArea := GetArea()
Local aComps := {}
Local nI := 0
Local nPos := 0 
Local cAgrupa := "TODOS"
Local cChaveGV1 := ""
Local lTemCpServ := .F.

If GFXCP12117("GV9_AGRSE") .And. Len(aTblFrFUNB) > 0
	GV9->(dbSetOrder(01))
	If GV9->(dbSeek(xFilial("GV9")+aTblFrFUNB[1][6]+aTblFrFUNB[1][2]+aTblFrFUNB[1][3]))
		If GV9->GV9_AGRSE $ "1 " //1=Nao Agrupar;2=Agrupar Todos;3=Agrupar por Tipo de Servico
			cAgrupa := 'COMP'			
		ElseIf GV9->GV9_AGRSE == "2" 
			cAgrupa := 'TODOS' //Continua como está hoje				
		ElseIf GV9->GV9_AGRSE == "3"
			cAgrupa := 'CDTPSE'
		EndIf
	EndIf
	nI := 1 
	While nI <= Len(aTblFrFUNB)
		GV1->(dbSetOrder(1))
		If GV1->(dbSeek(xFilial("GV1")+aTblFrFUNB[nI][6]+aTblFrFUNB[nI][2]+aTblFrFUNB[nI][3]+aTblFrFUNB[nI][5]+aTblFrFUNB[nI][4]))
			lTemCpServ := .F.
			While !GV1->(Eof()) .AND. GV1->GV1_FILIAL == xFilial("GV1")    .And.;
									  GV1->GV1_CDEMIT == aTblFrFUNB[nI][6] .And.;
									  GV1->GV1_NRTAB  == aTblFrFUNB[nI][2] .And.;
									  GV1->GV1_NRNEG  == aTblFrFUNB[nI][3] .And.;
									  GV1->GV1_CDFXTV == aTblFrFUNB[nI][5] .And.;
									  GV1->GV1_NRROTA == aTblFrFUNB[nI][4]

				cChaveGV1 := xFilial("GV1")+aTblFrFUNB[nI][6]+aTblFrFUNB[nI][2]+aTblFrFUNB[nI][3]+aTblFrFUNB[nI][5]+aTblFrFUNB[nI][4]
				
				GV2->(dbSetOrder(1))
				
				If GV2->(dbSeek(xFilial("GV2")+GV1->GV1_CDCOMP)) .AND. GV2->GV2_SERVI == "1" .And. GV2->GV2_CALSER == '2' //GV2_CDTPSE
					lTemCpServ := .T.
					If cAgrupa == 'CDTPSE'
						nPos := aScan(aComps,{|x| x[1] == GV2->GV2_CDTPSE })
						If nPos == 0
							aAdd(aComps,{GV2->GV2_CDTPSE,{cChaveGV1},{GV1->GV1_CDCOMP},cAgrupa,.T.,{}})
						Else
							If aScan(aComps[nPos][3],GV1->GV1_CDCOMP) == 0 //Verifica o componente
								aAdd(aComps[nPos][3],GV1->GV1_CDCOMP)
							EndIf
							If aScan(aComps[nPos][2],cChaveGV1) == 0 //Verifica a chave
								aAdd(aComps[nPos][2],cChaveGV1)
							EndIf
						EndIf
					ElseIf cAgrupa == 'COMP'
						nPos := aScan(aComps,{|x| x[1] == GV1->GV1_CDCOMP })
						If nPos == 0
							aAdd(aComps,{GV1->GV1_CDCOMP,{cChaveGV1},GV2->GV2_CDTPSE,cAgrupa,.T.,{}})
						Else
							If aScan(aComps[nPos][2],cChaveGV1) == 0 //Verifica a chave
								aAdd(aComps[nPos][2],cChaveGV1)
							EndIf
						EndIf
					Else
						If Len(aComps) == 0
							aAdd(aComps,{,,,cAgrupa,.T.,{}})
						Else
							Exit
						EndIf
					EndIf
				EndIf
		
				GV1->(dbSkip())
			EndDo
			If !lTemCpServ
				aDel(aTblFrFUNB,nI)
				aSize(aTblFrFUNB,Len(aTblFrFUNB)-1)
				Loop
			EndIf
		EndIf
		nI++
	EndDo
EndIf

If Len(aComps) == 0
	aAdd(aComps,{,,,cAgrupa,.F.,{}})
EndIf

RestArea(aOldArea)

Return aComps

/*/{Protheus.doc} CalcRatPed
Calcula o rateio do desconto de pedágio
@author Leonardo Ribas Jimenez Hernandez
@since 04/09/2017
@version 1.0
@param  aParamComp        Array que resume os parametros dos componentes
@param  nVlrPed           Valor do pedágio informado no Romaneio
@example
CalcRatPed()
/*/
Function CalcRatPed(aParamComp, nVlrPed, cNrRom)
	Local lErro			:= .F.
	Local lCompInfor	:= .F.
	Local cCdTrp, cNrTab, cNrNeg
	Local aRatPed 		:= {}
	Local nX 			:= 0
	Local nCont			:= 0
	Local cNrCalc,cCdClFr, cCdTpOp, cCdComp, cCatVal, nQtde, cTotFre, cBasImp, cBapIco, cFreMin, cIdMin, nVlrMi
	Local nValor 		:= 0
	Local nValorTotal 	:= 0
	Local nVlRat        := 0
	Local nVlRatTot 	:= 0
	Local aVlRoteiro	:= {} // {Numero Cálculo, Sequencia do Trecho, Valor para rateio, Valor total do Cálculo, Quantidade de cálculos por Unidade de cálculo, Realiza Rateio}
	Local nRoteiro		:= 0
	Local aCpPE         := {}
	Local lRet          := .T.
	local cAliasGVA 	:= ""

	AddToLog(CRLF + "  # Calculando Rateio de Desconto Pedágio..." + CRLF + CRLF) // "# Calculando Rateio de Pedágio..."

	// Ponto de Entrada refêrente a utilização do pedágio na Usina Colombo.
	If lPEXFB16
		aCpPE := ExecBlock("GFEXFB16",.f.,.f.)
		If ValType(aCpPE) == "A" .And. !Empty(aCpPE)
			aVlRoteiro    := aCpPE[1]
			aRatPed       := aCpPE[2]
			lRet          := aCpPE[3]
		EndIf	
	EndIf	

	GWT->(DbSetOrder(1))
	if GWT->(dbSeek(xFilial("GWT") + cNrRom))
		While (!GWT->(Eof()) .AND. GWT->GWT_NRROM == cNrRom)
			if GWT->GWT_VPVAL > 0 .AND. GWT->GWT_ADTPDG == "1" 
				aAdd(aVlRoteiro,{'', GWT->GWT_SEQ, GWT->GWT_VPVAL, 0,0,.F.})
			EndIf
			GWT->(dbSkip())
		Enddo
	EndIf
	
	If Len(aVlRoteiro) == 0
		if nVlrPed > 0
			aAdd(aVlRoteiro,{'','01',nVlrPed,0,0,.F.})
		Else
			Return lErro
		EndIf
	EndIf
	
	If lRet 

		GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
		GFEXFB_2TOP(lTabTemp, cTRBTCF, @aTRBTCF1, 5)

		GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
		While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5)

			cNrCalc := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
			cCdTrp  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")
			cNrTab  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")
			cNrNeg  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")
			cCdClFr := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
			cCdTpOp := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")

			GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
			If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE2, 7,{cNrCalc})

				// VERIFICA SE A SEQUENCIA TEM O VALOR DO ROTEIRO INFORMADO.
				nRoteiro := aScan(aVlRoteiro,{|x| x[2] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SEQ")})
				
				If nRoteiro > 0

					GVA->(dbSetOrder(01))
					GVA->(dbSeek(xFilial("GVA")+cCdTrp+cNrTab))
					If (GVA->GVA_TPTAB == "2") //Tabela de Vinculo
						
						cAliasGVA := GetNextAlias()
						BeginSql Alias cAliasGVA
							SELECT GVA.GVA_CDEMIT, GVA.GVA_NRTAB
							FROM %Table:GVA% GVA
							WHERE GVA.GVA_FILIAL = %xFilial:GVA%
							AND GVA.GVA_CDEMIT = %Exp:GVA->GVA_EMIVIN%
							AND GVA.GVA_NRTAB = %Exp:GVA->GVA_TABVIN%
							AND GVA.%NotDel%
						EndSql

						If (cAliasGVA)->(!EoF()) 
							cCdTrp := (cAliasGVA)->GVA_CDEMIT
							cNrTab := (cAliasGVA)->GVA_NRTAB
						EndIf
						
						(cAliasGVA)->(dbCloseArea())
					EndIf

					GV9 -> (dbSetOrder(01))
					If GV9->(dbSeek(xFilial("GV9")+cCdTrp+cNrTab+cNrNeg)	)

						If !Empty(GV9->GV9_DESPED) // Somente tabelas que tem configurado o componente de desconto de pedágio pode participar do cálculo 

							nValor  := GFETotFret(cNrCalc)
							cCdComp := GV9->GV9_DESPED
 
							GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9) 
							If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{cNrCalc,cCdClFr, cCdTpOp,cCdComp}) 
								cCatVal := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CATVAL")
								nQtde   := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE")
								cTotFre := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE")
								cBasImp := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"BASIMP")
								cBapIco := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"BAPICO")
								cFreMin := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"FREMIN")
								cIdMin  := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"IDMIN")
								nVlrMi  := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI")
							Else
								cCatVal := Posicione("GV2", 1, xFilial("GV2") + cCdComp, "GV2_CATVAL")
								nQtde   := 0
								GUY -> (dbSetOrder(01))
								If GUY->(dbSeek(xFilial("GUY") + cCdTrp + cNrTab + cNrNeg + cCdComp ))
									cTotFre := GUY->GUY_TOTFRE
									cBasImp := GUY->GUY_BASIMP
									cBapIco := GUY->GUY_BAPICO
									cFreMin := GUY->GUY_FREMIN
								EndIf
								cIdMin  := "2"
								nVlrMi  := 0
							EndIf
							lCompInfor := .T.
							AddToLog("    Adicionando Unidade de Cálculo: " + AllTrim(cNrCalc) + " Valor: " + cValToChar(nValor) + CRLF) //" Adicionando Unidade de Cálculo: cNrCalc Valor: nValor"
							AddToLog("    Transportador: " + AllTrim(cCdTrp) + " Tabela: " + AllTrim(cNrTab) + " Negociação: " + AllTrim(cNrNeg) + CRLF) //" Transportador: cCdTrp Tabela: cNrTab Negociação: cNrNeg"
							AddToLog("    Componente informado na tabela de frete: " + AllTrim(cCdComp) + CRLF + CRLF) // "  Componente informado na tabela de frete: cCdComp"

							If aScan(aRatPed,{|x| x[1] == cNrCalc}) == 0
								nValorTotal := nValorTotal + nValor 
							EndIf
							
							aVlRoteiro[nRoteiro][1] = cNrCalc
							aVlRoteiro[nRoteiro][4] += nValor
							aVlRoteiro[nRoteiro][5] += 1
							aVlRoteiro[nRoteiro][6] := .T.
							aAdd(aRatPed, {cNrCalc,cCdClFr, cCdTpOp, cCdComp, cCatVal, nQtde, nValor, cTotFre, cBasImp, cBapIco, cFreMin, cIdMin, nVlrMi, aVlRoteiro[nRoteiro][2], GV9->GV9_ACVPED})
						EndIf
					EndIf
				EndIf
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
		EndDo

		aSort(aVlRoteiro,,,{|x,y| x[2]      < y[2]})
		aSort(aRatPed,,,   {|x,y| x[14]+cValToChar(x[7]) < y[14]+cValToChar(y[7])})
		
		AddToLog("    # Efetuando o rateio de desconto de pedágio..." + CRLF)
		For nRoteiro:= 1 to Len(aVlRoteiro)
			nVlrPed		:= aVlRoteiro[nRoteiro][3]
			nValorTotal	:= aVlRoteiro[nRoteiro][4]
		
			If aVlRoteiro[nRoteiro][6] == .T.
				AddToLog(CRLF + "      > Trecho: " + aVlRoteiro[nRoteiro][2] +" > Valor Total: " + cValToChar(nValorTotal) + " > Valor de Pedágio: " + cValToChar(nVlrPed) + CRLF)
				IF nValorTotal >= nVlrPed 
			
					nX			:= aScan(aRatPed,{|x| x[14] == aVlRoteiro[nRoteiro][2]})
					nCont		:= 1
					nVlRat		:= 0
					nVlRatTot	:= 0
					while(aRatPed[nX][14] == aVlRoteiro[nRoteiro][2])
						
						AddToLog(CRLF)  
						AddToLog("                    Cálculo: " + aRatPed[nX][1] + CRLF) 
						AddToLog("         Valor do Documento: " + cValToChar(aRatPed[nX][7]) + CRLF)
											
						if aVlRoteiro[nRoteiro][5] == 1
							aRatPed[nX][7] := nVlrPed * IIF(aRatPed[nX][15] == '2', 1, -1)
							AddToLog("            Valor de Rateio: " + cValToChar(nVlrPed))
							AddToLog("        --> (Unidade de cálculo única, não houve rateio...)" + CRLF)
						Else
							If nCont == aVlRoteiro[nRoteiro][5]
								aRatPed[nX][7] := GFETratDec((nVlrPed - nVlRatTot))
								AddToLog("            Valor de Rateio: (" + cValToChar(nVlrPed) + " - " + cValToChar(nVlRatTot)+ ") = " + cValToChar(aRatPed[nX][7]))
								AddToLog("         -->  (Último registro, só faz a diferença...)" + CRLF)
								aRatPed[nX][7] := aRatPed[nX][7] * IIF(aRatPed[nX][15] == '2', 1, -1)
							Else
								nVlRat := GFETratDec((nVlrPed / nValorTotal) * aRatPed[nX][7])
								AddToLog("            Valor de Rateio: ((" + cValToChar(nVlrPed) + " / " + cValToChar(nValorTotal) + ")" + " * " + cValToChar(aRatPed[nX][7])+") = " + cValToChar(nVlRat))
								AddToLog("         -->  (Efetuado operação de valor de rateio...)" + CRLF)
								aRatPed[nX][7] := nVlRat * IIF(aRatPed[nX][15] == '2', 1, -1)
								nVlRatTot += nVlRat 
							EndIf
						EndIf					
											
						nCont++
						nX++
						if nX > Len(aRatPed)
							Exit
						EndIf
					EndDo
				Else
		
					AddToLog("    *** Erro - Valor Total: " + cValToChar(nValorTotal) + ", Menor ou igual ao Valor de Pedágio: " + cValToChar(nVlrPed) + CRLF  + CRLF) //"  Valor Total: nValorTotal, maior que Valor de Pedágio: nVlrPed "
		
					GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
					GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
					While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 30)
						lErro := .T.
			
						GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
					EndDo
				EndIf
			Else
				AddToLog(CRLF  +"      > Trecho: " + aVlRoteiro[nRoteiro][2] +" não possui configuração na tabela de frete para realizar rateio." +  CRLF)
			EndIf
		next

			if !lErro
				AddToLog(CRLF + "    # Selecionando qual componente receberá o valor de adiantamento de pedágio..." + CRLF ) //"  Selecionando qual componente receberá o valor de adiantamento de pedágio..." 
				For nX := 1 to Len(aRatPed)
			
					GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
			
					If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{aRatPed[nX][1], ;
									aRatPed[nX][2], ;
									aRatPed[nX][3], ;
									aRatPed[nX][4]})
						AddToLog(CRLF) 
						AddToLog("                 Cálculo: " + aRatPed[nX][1] + CRLF) 
						AddToLog("              Componente: " + AllTrim(aRatPed[nX][4]))
						AddToLog("        --> (Componente faz parte do cálculo...)" + CRLF)
						AddToLog("         Valor do Rateio: " + cValToChar(aRatPed[nX][7]) + CRLF)
						AddToLog("              Calculando: (" + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + ") + (" + cValToChar(aRatPed[nX][7]) + ")")
						AddToLog("          --> (Desconto realizado no componente...)" + CRLF)
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + aRatPed[nX][7])
						AddToLog("              Novo Valor: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF)
					Else
						AddToLog(CRLF) 
						AddToLog("                 Cálculo: " + aRatPed[nX][1] + CRLF)
						AddToLog("              Componente: " + AllTrim(aRatPed[nX][4]))
						AddToLog("        --> (Componente adicionado ao cálculo...)" + CRLF)
						AddToLog("         Valor do Rateio: " + cValToChar(aRatPed[nX][7]) + CRLF)
			
						If lTabTemp
							RecLock(cTRBCCF,.T.)
							(cTRBCCF)->NRCALC := aRatPed[nX][1]
							(cTRBCCF)->CDCLFR := aRatPed[nX][2]
							(cTRBCCF)->CDTPOP := aRatPed[nX][3]
							(cTRBCCF)->CDCOMP := aRatPed[nX][4]
							(cTRBCCF)->CATVAL := aRatPed[nX][5]
							(cTRBCCF)->VALOR  := aRatPed[nX][7]
							(cTRBCCF)->QTDE   := aRatPed[nX][6]
							(cTRBCCF)->TOTFRE := aRatPed[nX][8]
							(cTRBCCF)->BASIMP := aRatPed[nX][9]
							(cTRBCCF)->BAPICO := aRatPed[nX][10]
							(cTRBCCF)->FREMIN := aRatPed[nX][11]
							(cTRBCCF)->IDMIN  := "2"
							(cTRBCCF)->(MsUnLock())
						Else
							aAdd(aTRBCCF1,{	aRatPed[nX][1],; //NRCALC
											aRatPed[nX][2],; //CDCLFR
											aRatPed[nX][3],; // CDTPOP
											Space(04),; //SEQ
											aRatPed[nX][4],; //CDCOMP 
											aRatPed[nX][5],; //CATVAL
											aRatPed[nX][6],; //QTDE
											aRatPed[nX][7],; //VALOR
											aRatPed[nX][8],; //TOTFRE
											aRatPed[nX][9],; //BASIMP
											aRatPed[nX][10],; //BAPICO
											aRatPed[nX][11],; //FREMIN
											"2",; //IDMIN
											0,; //VLFRMI
											"0",; //DELETADO
											Space(6),; //NRLCENT
											Space(1)}) //CPEMIT
						EndIf
						GFEParamComp({	aRatPed[nX,4], ;
						aRatPed[nX,8], ;
						aRatPed[nX,9], ;
						aRatPed[nX,10], ;
						aRatPed[nX,11], ;
						aRatPed[nX,1]},@aParamComp) 
					EndIf
				Next nX
			
			
				If !lTabTemp
					aTRBCCF2 := aClone(aTRBCCF1)
					aTRBCCF3 := aClone(aTRBCCF1)
					aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
					aSort(aTRBCCF2  ,,,{|x,y| x[01]+x[05]                  < y[01]+y[05]})
					aSort(aTRBCCF3  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})
				EndIf
			EndIf
	EndIf

	AddToLog(CRLF + "  # Cálculo de Rateio de Desconto de Pedágio Finalizado..." + CRLF + CRLF) //"  Cálculo de Rateio de Desconto de Pedágio Finalizado..."    

Return lErro

// Função para adequação do tamanho dos arrays para funcionamento correto do calculo devido a alteração para calculo com documento de filiais diferentes.
// Rotinas externas ao romaneio (simulação, contratos...) pode chamar o calculo e passar os arrays incompletos, desse modo precisamos completar e repassar a informação de filial
Static Function CheckSuaviza(aDocCarg1, aTrchDoc, aItDoc)
	Local nX   := 0
	Local nY   := 0
	Local nLen := 0
	Local aAux := Nil

	If Len(aDocCarg1) > 0 .And. Len(aTail(aDocCarg1)) < Len(_aCmpDOC)
		aAux := {}
		For nX := 1 To Len(aDocCarg1)
			nLen := Len(aDocCarg1[nX])
			aadd(aAux, Array(Len(_aCmpDOC)))

			For nY := 1 To Len(aTail(aAux))
				If nY <= nLen
					atail(aAux)[nY] := aDocCarg1[nX][nY]
				ElseIf nY == Len(aTail(aAux))
					atail(aAux)[nY] := xFilial("GW1")
				Else
					atail(aAux)[nY] := Nil
				EndIf
			Next
		Next
		aDocCarg1 := aAux
	EndIf

	If Len(aTrchDoc) > 0 .And. Len(aTail(aTrchDoc)) < Len(_aCmpTRE)
		aAux := {}
		For nX := 1 to Len(aTrchDoc)
			nLen := Len(aTrchDoc[nX])
			aadd(aAux, Array(Len(_aCmpTRE)))

			For nY := 1 To Len(aTail(aAux))
				If nY <= nLen .And. nY <> 15
					aTail(aAux)[nY] := aTrchDoc[nX][nY]
				ElseIf nY == Len(aTail(aAux)) .Or. nY == 15	// posição 15 contem origem do trecho = filial, por isso passamos o xFilial como usado anteriormente
					aTail(aAux)[nY] := xFilial("GWU")
				Else
					aTail(aAux)[nY] := Nil
				EndIf
			Next
		Next
		aTrchDoc := aAux
	EndIf

	If Len(aItDoc) > 0 .And. Len(aTail(aItDoc)) < Len(_aCmpITE)
		aAux := {}
		For nX := 1 to Len(aItDoc)
			nLen := Len(aItDoc[nX])
			aadd(aAux, Array(Len(_aCmpITE)))

			For nY := 1 To Len(aTail(aAux))
				If nY <= nLen
					aTail(aAux)[nY] := aItDoc[nX][nY]
				ElseIf nY == Len(aTail(aAux))
					aTail(aAux)[nY] := xFilial("GW8")
				Else
					aTail(aAux)[nY] := 0
				EndIf
			Next
		Next
		aItDoc := aAux
	EndIf

Return
