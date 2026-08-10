/*
Estrutura do arquivo, segundo layout proceda 3.1
Reg000 - Cabeçalho de intercambio
--- Reg310         OCCURS = 200 (P/ CADA REG. "000") Cabeçalho do documento
----- Reg311       OCCURS = 10  (P/ CADA REG. "310") Dados da embarcadora
------- Reg312     OCCURS = 500 (P/ CADA REG. "311") Dados do destinatário da mercadoria
--------- Reg313   OCCURS = 40  (P/ CADA REG. "312") Dados de nota fiscal
----------- Reg333 OCCURS = 1   (P/ CADA REG. "313") Dados complementares de nota fiscal
----------- Reg315 OCCURS = 1   (P/ CADA REG. "313") Dados do consignatario da mercadoria
----------- Reg314 OCCURS = 5   (P/ CADA REG. "313") Mercadoria da nota fiscal
----------- Reg316 OCCURS = 1   (P/ CADA REG. "313") Dados para resdespacho da mercadoria
----------- Reg317 OCCURS = 1   (P/ CADA REG. "313") Dados do responsável pelo frete
----- Reg318       OCCURS = 1   (P/ CADA REG. "310") Valores totais do documento
*/

#INCLUDE "GFEA110.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
Static __nTamSrDC := Nil
Static __lCpoSr   := Nil
 
 // SonarQube - CA1003: Uso não permitido de chamada de API em LOOP
Static lPEA11005	:= ExistBlock("GFEA1105")
Static lPEA11007	:= ExistBlock("GFE11007")
Static lPEA1108 	:= ExistBlock("GFEA1108")
Static lPEA11009    := ExistBlock("GFE11009")
Static s_CRIRAT		:= SuperGetMv("MV_CRIRAT",,"1")
Static s_INTTMS		:= SuperGetMv("MV_INTTMS", .F., .F.)
Static s_GFEEDIL	:= SuperGetMV('MV_GFEEDIL',,'1')
 
//--------------------------------------------------------------------
/*/{Protheus.doc} GFEA110

Exportar Notas Fiscais

@author Lidiomar Fernando dos S. Machado
@since 28/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA110()
	Local cVersaoLayout
	
	If __lCpoSr == Nil
		__lCpoSr   := TamSX3("GW1_SERDC")[1] == 14
	EndIf

	/*Caso não seja executado por Schedule, será aberta a tela para seleção do layout.
	  Caso seja por schedule, deverá ser parametrizado GFEA110 para execução da versão 3.1 e GFEA110B para versão 5. 
	  Por este motivo cVersaoLayout é definido com valor fixo 1 no Else abaixo. 
	*/
	If !IsBlind()
		If !Pergunte("GFEA110X",.T.)
			Return Nil
		EndIf

		cVersaoLayout := MV_PAR01
	Else
		cVersaoLayout := 1
	EndIf
	
	If cVersaoLayout == 1
		// Layout 3.1
		GFEA110A()
	Else
		// Layout 5.0
		GFEA110B()
	EndIf
Return

Function GFEA110A()
	Local   lRetPE      := .F.
	Private cAliasQry
	Private cArqTxt     := ""
	Private nVlTotNf    := 0
	Private nPesoTotNf  := 0
	Private nTotVol     := 0
	Private nQtTotVol   := 0
	Private nVlCobrado  := 0
	Private nVlTotSeg   := 0
	Private nSeq        := 0
	Private cCGCSMO     := ""
	Private cCxEdiRemet := ""
	Private cCxEdiDest  := ""
	Private lRatearDC	:= .T.	// Apenas para agrupamento de notas
	Private GFELog110   := GFELog():New("EDI_NotFis_Exportacao", "EDI NotFis 3.1", s_GFEEDIL)
	Private GFEResult 	:= GFEViewProc():New()
	Private lVldGrav := .F.
	Private aArrayTran := {} //Dados do transportador, para envio de email
	/*Dados para envio de email para transportadores, usado quando o mesmo arquivo for enviado
	para vários transportadores (Saida = Arquivo).
		aDadoDirEm[1] = Nome do arquivo
		aDadoDirEm[2] = diretorio do arquivo
	*/
	Private aDadoDirEm[2]
	Private aEmailTran := {} //Transportadores do arquivo, para opção "Arquivo"

	// >> Parametros do pergunte
	Private cFilDe
	Private cFilAte
	Private cSerDe
	Private cSerAte
	Private cNrDocDe
	Private cNrDocAte
	Private dDtSaiDe
	Private dDtSaiAte
	Private dDtEmisDe
	Private dDtEmisAte
	Private cGrpEmit
	Private cTranspDe
	Private cTranspAte
	Private cEmbarcado
	Private cRomDe
	Private cRomAte
	Private cEnvSemDt
	Private cAgrpItem
	Private cReenvDoc
	Private cSaida
	Private cDestino
	Private cAgrDest
	Private cEnvEmail
	Private cTRBAGRU
	// <<
	Private cDiretorio
	
	/*TUFUTB*/
	Public cCdTrpPEnt := ""

	If !IsBlind()
		// Ponto de entrada para substituir o grupo de perguntas padrão
		If ExistBlock("GFE11008")
			If !ExecBlock("GFE11008",.F.,.F.)
				Return Nil
			EndIf
		Else
			If !Pergunte("GFEA110",.T.)
				Return Nil
			EndIf
		EndIf
	EndIf

	If lPEA11009
		lRetPE := ExecBlock("GFE11009",.f.,.f.)
		If ValType(lRetPE) != "L" .And. !lRetPE
			Return Nil
		EndIf
	EndIf

	cFilDe     := MV_PAR01
	cFilAte    := MV_PAR02
	cSerDe     := MV_PAR03
	cSerAte    := MV_PAR04
	cNrDocDe   := MV_PAR05
	cNrDocAte  := MV_PAR06
	dDtSaiDe   := MV_PAR07
	dDtSaiAte  := MV_PAR08
	dDtEmisDe  := MV_PAR09
	dDtEmisAte := MV_PAR10
	cGrpEmit   := MV_PAR11
	cTranspDe  := MV_PAR12
	cTranspAte := MV_PAR13
	cEmbarcado := MV_PAR14
	cRomDe     := MV_PAR15
	cRomAte    := MV_PAR16
	cEnvSemDt  := MV_PAR17
	cAgrpItem  := MV_PAR18
	cReenvDoc  := MV_PAR19
	cSaida     := MV_PAR20
	cDestino   := MV_PAR21
	cAgrDest   := MV_PAR22
	cEnvEmail  := MV_PAR23

	GFELog110:ShowParameters("GFEA110")

	If cEmbarcado == 2 .And. (!Empty(cRomDe) .Or. !Empty(cRomAte))
		GFELog110:Add("- Faixa de Romaneio ignorada")
		MsgInfo("O parâmetro 'Somente Embarcados' está informado como 'Não' e foi informada faixa de romaneios. Essa faixa não será considerada.")
	EndIf


	If (Empty(cGrpEmit) .And. Empty(cTranspAte))
		MsgInfo(STR0009, STR0010) //"Não foi gerado nenhum arquivo, pois, é necessário informar pelo menos uma faixa de transportador." ### "Exportação"
		Return Nil
	EndIf

	If Empty(cDestino)
		MsgInfo("Não foi gerado nenhum arquivo,é necessário informar o destino do(s) arquivo(s)", STR0010) //"Não foi gerado nenhum arquivo, pois, é necessário informar pelo menos uma faixa de transportador." ### "Exportação"
		Return Nil
	EndIf

	GFELog110:NewLine()
	GFELog110:Add("Iniciando Exportação")

	consSQL() //Chamada para função que executa a query

		//Criar tabela temporaria para os registro vinculados ao calculo
	/*********************************************************************/
	aDBFAgr := {{"FILIAL"    ,"C", 	TAMSX3("GW1_FILIAL")[1]  ,0},; //Tipo Documento
				{"CDTPDC"    ,"C", 	TAMSX3("GW1_CDTPDC")[1]  ,0},; //Tipo Documento
				{"EMISDC"    ,"C", 	TAMSX3("GW1_EMISDC")[1]  ,0},; //Remetente Cálculo
				{"SERDC"     ,"C",	TAMSX3("GW1_SERDC" )[1]  ,0},; //Serie
				{"NRDC"      ,"C",	TAMSX3("GW1_NRDC"  )[1]  ,0},; //Numero do Documento
				{"VLFRPESVOL","N",15,4},; //VALOR DO FRETE PESO VOLUME
				{"VLADVAL"   ,"N",15,4},; //VALOR AD VALOREM
				{"VLTOTTX"   ,"N",15,4},; //VALOR TOTAL DAS TAXAS
				{"VLTOTFRT"  ,"N",15,4},; //VALOR TOTAL DO FRETE
				{"VLICMS"    ,"N",15,4},; //VALOR DO ICMS
				{"VLICMSRE"  ,"N",15,4}}  //VALOR DO ICMS RETIDO

	cTRBAGRU := GFECriaTab({ aDBFAgr,{"FILIAL+EMISDC+CDTPDC+SERDC+NRDC"} })

	/*********************************************************************/

	If IsBlind()
		ProcessNot(cSaida)
	Else
		Processa({|| ProcessNot(cSaida) }, "Exportando dados")
	EndIf

	If !lVldGrav
		GFELog110:Add("Nenhum arquivo exportado.",1)
		GFELog110:Add("Possíveis causas",1)
		GFELog110:Add("- Tipo de Documento de Carga não configurado para enviar por EDI (GV5_EDI).",1)
		GFELog110:Add("- Parametros informados em tela não correspondem a documentos registrados no sistema.",1)
		GFELog110:Add("- Os documentos de Carga já foram exportados. Para serem exportados novamente, o parametro em tela 'Reenvia Documentos' deve estar como 'Sim'.",1)
		GFELog110:Add("- Os documentos de Carga estão com a situação (GW1_SIT) Bloqueados.",1)
		GFELog110:Add("- Habilitando o Log do EDI (MV_GFEEDIL) outras informações são geradas, inclusive o comando SQL utilizado para encontrar os Documentos de Carga a serem exportados.",1)
		GFEResult:AddDetail("Nenhum arquivo exportado.",1)
		GFEResult:AddDetail("Possíveis causas",1)
		GFEResult:AddDetail("- Tipo de Documento de Carga não configurado para enviar por EDI (GV5_EDI).",1)
		GFEResult:AddDetail("- Parametros informados em tela não correspondem a documentos registrados no sistema.",1)
		GFEResult:AddDetail("- Os documentos de Carga já foram exportados. Para serem exportados novamente, o parametro em tela 'Reenvia Documentos' deve estar como 'Sim'.",1)
		GFEResult:AddDetail("- Os documentos de Carga estão com a situação (GW1_SIT) Bloqueados.",1)
		GFEResult:AddDetail("- Habilitando o Log do EDI (MV_GFEEDIL) outras informações são geradas, inclusive o comando SQL utilizado para encontrar os Documentos de Carga a serem exportados.",1)
	EndIf
	
	If !IsBlind() 
		GFEResult:Show("Exportação de EDI NOTFIS","Detalhes","Detalhes",IIF(lVldGrav,"Alguns documentos encontrados na faixa de parâmetros não puderam ser enviados. Clique no botão 'Detalhes' para mais detalhes:",Nil))
	EndIf	
	
	(cAliasQry)->(dbCloseArea())
	//Deletando tabela temporaria
	GFEDelTab(cTRBAGRU)

	If cEnvEmail == 1 .AND. lVldGrav
		EnEmailEDI()
	EndIf

	GFELog110:EndLog()

Return

Static Function EnEmailEDI()
	Private GFEResEDI := GFEViewProc():New()
	If IsBlind()
		EmailEDI()
	Else
		Processa({|| EmailEDI() }, "Enviando Emails, aguarde")
	EndIf

	If !IsBlind()
		GFEResEDI:Show("Envio de Emails","Detalhes","Erros",IIF(lVldGrav,"Alguns documentos não puderam ser enviados por email. Clique no botão 'Erros' para mais detalhes:",Nil))
	EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} consSQL()

Função que retorna a consulta SQL, de acordo com o parâmetros.

@author Lidiomar Fernando dos S. Machado
@since 28/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function consSQL()
	Local aRetQuery := {}
	Local cQuery := ""
	Local cAdd := ""
	
	If __nTamSrDC == Nil
		__nTamSrDC   := TamSx3(SerieNfId("GW1",3,"GW1_SERDC"))[1]
	EndIf

	// Início Ponto de Entrada
	If ExistBlock("GFEA1101")
		aRetQuery := ExecBlock("GFEA1101",.f.,.f.)
	EndIf
	// Temp-table com estrutura da GWU, ordenada pela transportadora
	cAliasQry := GetNextAlias()
	cQuery :=      " SELECT GWU.GWU_FILIAL,"
	cQuery +=             " GWU.GWU_CDTRP,"
	cQuery +=             " GWU.GWU_CDTPDC,"
	cQuery +=             " GWU.GWU_EMISDC,"
	cQuery +=             " GWU.GWU_SERDC,"
	cQuery +=             " GWU.GWU_NRDC,"
	cQuery +=             " GWU.GWU_SEQ,"
	cQuery +=             " GU3.GU3_MODAL,"
	cQuery +=             " GW1.GW1_DTEMIS,"
	cQuery +=             " GW1.GW1_CDDEST,"
	cQuery +=             " GW1.GW1_CDREM,"
	cQuery +=             " GW1.GW1_SIT,"
	cQuery +=             " GW1.GW1_ENVEDI"
	
	//Permite adicionar campos
	If lPEA11007
		cAdd := ExecBlock("GFE11007",.f.,.f.,{"3.1",-1,1,""})
		If !Empty(cAdd) .And. ValType(cAdd) == "C"
			cQuery += cAdd
		EndIf
	EndIf
	cQuery +=        " FROM "+RetSQLName("GWU")+" GWU"
	cQuery +=       " INNER JOIN "+RetSQLName("GU3")+" GU3"
	cQuery +=          " ON GU3.GU3_FILIAL = '"+xFilial("GU3")+"'"
	cQuery +=         " AND GU3.GU3_CDEMIT = GWU.GWU_CDTRP OR GWU.GWU_CDTRP = ' ' "
	// Faixa Transportador
	If !Empty(cGrpEmit)
		cQuery +=     " AND GU3.GU3_CDGRED = '"+cGrpEmit +"'"
	EndIf
	cQuery +=         " AND GU3.D_E_L_E_T_ = ' '"
	cQuery +=       " INNER JOIN "+RetSQLName("GW1")+" GW1"
	cQuery +=          " ON GW1.GW1_FILIAL = GWU.GWU_FILIAL"
	cQuery +=         " AND GW1.GW1_CDTPDC = GWU.GWU_CDTPDC"
	cQuery +=         " AND GW1.GW1_EMISDC = GWU.GWU_EMISDC"
	cQuery +=         " AND GW1.GW1_SERDC = GWU.GWU_SERDC"
	cQuery +=         " AND GW1.GW1_NRDC = GWU.GWU_NRDC"
	// Faixa por data de saída
	If cEnvSemDt == 2
		If !Empty(dDtSaiDe)
			cQuery += " AND GW1.GW1_DTSAI >= '"+DToS(dDtSaiDe)+"'"
		EndIf
		If !Empty(dDtSaiAte)
			cQuery += " AND GW1.GW1_DTSAI <= '"+DToS(dDtSaiAte)+"'"
		EndIf
	EndIf
	// Faixa por data de emissão
	If !Empty(dDtEmisDe)
		cQuery +=     " AND GW1.GW1_DTEMIS >= '"+DToS(dDtEmisDe)+"'"
	EndIf
	If !Empty(dDtEmisAte)
		cQuery +=     " AND GW1.GW1_DTEMIS <= '"+DToS(dDtEmisAte)+"'"
	EndIf
	// Documentos que não estejam bloqueados
	cQuery +=         " AND GW1.GW1_SIT <> '2'"
	 // Reenvia documentos
	If cReenvDoc == 2
		cQuery +=     " AND GW1.GW1_ENVEDI = '2'"
	EndIf
	// Somente embarcados
	If cEmbarcado == 1
		cQuery +=    " AND GW1.GW1_NRROM <> ' '"
	EndIf
	// Faixa de Romaneios
	If !Empty(cRomDe)
		cQuery +=    " AND GW1.GW1_NRROM >= '"+AllTrim(cRomDe)+"'"
	EndIf
	If !Empty(cRomAte)
		cQuery +=    " AND GW1.GW1_NRROM <= '"+AllTrim(cRomAte)+"'"
	EndIf
	cQuery +=         " AND GW1.D_E_L_E_T_ = ' '"
	cQuery +=       " INNER JOIN "+RetSQLName("GV5")+" GV5"
	cQuery +=          " ON GV5.GV5_FILIAL = '"+xFilial("GV5")+"'"
	cQuery +=         " AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC"
	cQuery +=         " AND GV5.GV5_EDI <> '2'"
	cQuery +=         " AND GV5.D_E_L_E_T_ = ' '"
	// Ponto de Entrada
	If !Empty(aRetQuery)
		If !Empty(aRetQuery[1])
			cQuery += aRetQuery[1] // Caracter - Irá retornar comandos JOIN para serem adicionados ao comando SQL original para referenciar a tabela GWU.
		EndIf
	EndIf
	cQuery +=       " WHERE GWU.D_E_L_E_T_ = ' '"
	// Faixa por Filial
	If !Empty(cFilDe)
		cQuery +=     " AND GWU.GWU_FILIAL >= '"+AllTrim(cFilDe)+ "'"
	EndIf

	If !Empty(cFilAte)
		cQuery +=     " AND GWU.GWU_FILIAL <= '"+AllTrim(cFilAte)+"'"
	EndIf
	// Faixa por Serie
	If !Empty(cSerDe)
		cQuery +=     " AND GWU."+SerieNfId("GWU",3,"GWU_SERDC")+" >= '"+PadR(cSerDe,__nTamSrDC)+"'"
	EndIf
	If !Empty(cSerAte)
		cQuery +=     " AND GWU."+SerieNfId("GWU",3,"GWU_SERDC")+" <= '"+PadR(cSerAte,__nTamSrDC)+"'"
	EndIf
	// Faixa Documento de Carga
	If !Empty(cNrDocDe)
		cQuery +=     " AND GWU.GWU_NRDC >= '"+AllTrim(cNrDocDe)+"'"
	EndIf
	If !Empty(cNrDocAte)
		cQuery +=     " AND GWU.GWU_NRDC <= '"+AllTrim(cNrDocAte)+"'"
	EndIf
	// Faixa Transportador
	If Empty(cGrpEmit)
		If !Empty(cTranspDe)
			cQuery += " AND GWU.GWU_CDTRP >= '"+AllTrim(cTranspDe)+"'"
		EndIf
		If !Empty(cTranspAte)
			cQuery += " AND GWU.GWU_CDTRP <= '"+AllTrim(cTranspAte)+"'"
		EndIf
	EndIf
	
	cQuery += " AND (GV5.GV5_EDI = '1' AND GWU.GWU_PAGAR = '1' OR GV5.GV5_EDI = '3' AND GWU.GWU_PAGAR IN ('1','2'))"

	// Ponto de Entrada
	If !Empty(aRetQuery)
		If !Empty(aRetQuery[2])
			cQuery += aRetQuery[2] // Caracter - Irá retornar comandos SQL que serão adicionadas a clausula WHERE do comando SQL original.
		EndIf
	EndIf
	// Agrupamento de calculo
	// Permite adicionar campos
	If lPEA11007
		cAdd := ExecBlock("GFE11007",.f.,.f.,{"3.1",-1,2,""})
		If ValType(cAdd) != "C"
			cAdd := ""
		EndIf
	Else
		cAdd := ""
	EndIf
	// Agrupa destino
	If cAgrDest == 1
		If cSaida == 1
			cQuery += " ORDER BY "+cAdd+" GW1.GW1_CDREM,"
			cQuery +=           " GW1.GW1_CDDEST,"
			cQuery +=           " GWU_CDTRP,"
			cQuery +=           " GWU_NRDC,"
			cQuery +=           " GWU_SERDC ASC"
		Else
			cQuery += " ORDER BY GWU_CDTRP,"
			cQuery +=          " "+cAdd+" GW1.GW1_CDREM,"
			cQuery +=          " GW1.GW1_CDDEST,"
			cQuery +=          " GWU_NRDC,"
			cQuery +=          " GWU_SERDC ASC"
		EndIf
	Else
		cQuery +=     " ORDER BY GWU_CDTRP,"
		cQuery +=              " "+cAdd+" GW1.GW1_CDREM,"
		cQuery +=              " GWU_NRDC,"
		cQuery +=              " GWU_SERDC ASC"
	EndIf
	
	GFELog110:AddDebug("Query SQL: " + cQuery)
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessNot(cSaida)

Função de processamento das notas fiscais, de acordo com o valor retornado na consulta SQL.

Parâmetros:
	cSaida: Determina a forma de armazenamentos dos dados - 1:Arquivo 2:Diretório

@author Lidiomar Fernandos dos S. Machado
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function ProcessNot(cSaida)
	Local cCdDestAnt := ""
	Local cAgrXpto := ""
	Local cRetXpto := ""
	Local cMensagem := ""
	Local nI
	Local aNotas := {}
	Local lRet := .T.
	Local cChave := ""

	Private cCdTranAnt := ""
	Private cCdRemAnt
	Private nCountRem
	Private p_ERPINT     := SuperGetMV("MV_ERPGFE",,'1')

	(cAliasQry)->( dbGoTop() )
	//----------------------------------------------------------//
	//---- Inicia arquivo(caso a saida seja "arquivo" terá -----//
	//---- apenas um cabeçalho gerado)--------------------------//
	//----------------------------------------------------------//
	Reg000() //Cabeçalho de intercambio
	Reg310()//Cabeçalho do documento
	DefineDir((cAliasQry)->GWU_CDTRP)

	If !IsBlind()
		ProcRegua(0)
	EndIf
	GFEResult:Add("Dados das notas fiscais processadas na exportação:",1)
	While !(cAliasQry)->( Eof() )
		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek((cAliasQry)->GWU_FILIAL+(cAliasQry)->GWU_CDTPDC+(cAliasQry)->GWU_EMISDC+(cAliasQry)->GWU_SERDC+(cAliasQry)->GWU_NRDC) )
			cMensagem := "> Filial: " + alltrim((cAliasQry)->GWU_FILIAL) + ", Tipo Doc: " + alltrim((cAliasQry)->GWU_CDTPDC) + ", Emissor: " + alltrim((cAliasQry)->GWU_EMISDC) + ", Série: " + alltrim(Transform( (cAliasQry)->GWU_SERDC, "!!!" )) + If(__lCpoSr,", Dt.Emissão: " + DTOC(STOD((cAliasQry)->GW1_DTEMIS)),"") + ", Número: " + alltrim((cAliasQry)->GWU_NRDC)
			cChave := (cAliasQry)->GWU_FILIAL+(cAliasQry)->GWU_CDTPDC+(cAliasQry)->GWU_EMISDC+(cAliasQry)->GWU_SERDC+(cAliasQry)->GWU_NRDC+(cAliasQry)->GWU_CDTRP

			If len(aNotas) > 0
				If AScan(aNotas,cChave) == 0
					lRet := .T.  
				Else
					lRet := .F.
				EndIf
			EndIf
			
			If lRet == .T.
				
				AADD(aNotas,(cAliasQry)->GWU_FILIAL+(cAliasQry)->GWU_CDTPDC+(cAliasQry)->GWU_EMISDC+(cAliasQry)->GWU_SERDC+(cAliasQry)->GWU_NRDC+(cAliasQry)->GWU_CDTRP)
				
				GFELog110:Add( cMensagem, 1)
	
				If !GFEResult:StrContain(cMensagem, .F.)
					GFEResult:Add(cMensagem, 1)
				EndIf
	
				If !IsBlind()
					IncProc("Nr.: " + AllTrim((cAliasQry)->GWU_NRDC) + " Série: " + AllTrim((cAliasQry)->GWU_SERDC))
				EndIf
	
				If lPEA11007 //Ponto de entrada para definir o agrupamento
					cRetXpto := ExecBlock("GFE11007",.f.,.f.,{"3.1",GW1->(RecNo()),3,cAliasQry})
					If (cRetXpto != cAgrXpto) .Or. ( IIF(cSaida == 2, cCdTranAnt != (cAliasQry)->GWU_CDTRP,.F.))
						Reg311()// Dados da embarcadora
						Reg312()// Dados do destinatário da mercadoria
					EndIf
					cAgrXpto := cRetXpto
				Else
					If cCdRemAnt != (cAliasQry)->GW1_CDREM
						Reg311()
					EndIf
					
					If cAgrDest == 1 //Agrupar por destinatário
						If ((cCdDestAnt != GW1->GW1_CDDEST) .OR. (cCdRemAnt != (cAliasQry)->GW1_CDREM) .Or. ;
						(IIF(cSaida == 2, cCdTranAnt != (cAliasQry)->GWU_CDTRP,.F.)) )
							Reg312()// Dados do destinatário da mercadoria
						EndIf
					Else
						Reg312()// Dados do destinatário da mercadoria
					EndIf
				EndIf
				
	
				Reg313()// Dados de nota fiscal
				Reg333()// Dados complementares de nota fiscal
	
				If cAgrpItem == 1
					Reg314() //Mercadoria da nota fiscal
				ElseIf cAgrpItem == 3
					 Reg314AGR() //Mercadoria da nota fiscal agrupada por classificação de frete
				EndIf
				
				Reg316() // Dados Redespachante
				Reg317(GW1->GW1_FILIAL) // Dados Responsável pelo frete		
			EndIf

				cCdDestAnt := GW1->GW1_CDDEST
				cCdRemAnt  := GW1->GW1_CDREM
				cCdTranAnt := (cAliasQry)->GWU_CDTRP
				
				//Agrupa as notas por transportador (Caso a saída seja "Diretório")
				GeraTotal() //Salva na string os valores totais
				StatusEDI()
				
				lVldGrav := .T. //Valida se o arquivo deverá ser gerado, utilizado para saida do tipo "Arquivo"
		EndIf
	EndDo

	// Início Ponto de Entrada
	If ExistBlock("GFEA1103")
		If cSaida == 1
			For nI := 1 To len(aEmailPEnt)
				ExecBlock("GFEA1103",.f.,.f.,{cDiretorio,aEmailPEnt[nI]})
			Next nI
		Else
			ExecBlock("GFEA1103",.f.,.f.,{cDiretorio,cCdTrpPEnt})
		EndIf
	EndIf
	// Fim Ponto de Entrada
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraTotal()

Gera o total do documento.
Caso a saída seja "Diretório", irá ser gerado o cabeçalho do documento do próximo transportador.

@author Lidiomar Fernandos dos S. Machado/Hercilio H. Neto
@since 09/04/2014
@version 2.0
/*///------------------------------------------------------------------------------------------------
Static Function GeraTotal()

	Public aEmailPEnt := {}
	
	(cAliasQry)->( dbSkip() )
	If cCdTranAnt != (cAliasQry)->GWU_CDTRP .And. cSaida == 1 .And. ASCAN(aEmailTran,cCdTranAnt) == 0
		AADD(aEmailTran,cCdTranAnt) //Adiciona no array os transportadores que devem receber o arquivo por email
		AADD(aEmailPEnt,cCdTranAnt)
	EndIf
	If cCdRemAnt != (cAliasQry)->GW1_CDREM
		nCountRem++
	EndIf
	If (cAliasQry)->( Eof())
		Reg318()// Valores totais do documento
		GeraTxt()
	ElseIf cCdTranAnt != (cAliasQry)->GWU_CDTRP .And. cSaida == 2
		Reg318()// Valores totais do documento
		GeraTxt()
		cCdTrpPEnt := cCdTranAnt
		DefineDir((cAliasQry)->GWU_CDTRP)
		Reg000() //Cabeçalho de intercambio
		Reg310()//Cabeçalho do documento
	ElseIf nCountRem == 10
		Reg318()// Valores totais do documento
		Reg310()//Cabeçalho do documento
	EndIf
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg000()

Grava no arquivo os dados referentes ao registro "000" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//000 - CABEÇALHO DE INTERCÂMBIO
//--------------------------------------
Static Function Reg000()
	Local cAno := SUBSTR ( ALLTRIM( STR(YEAR(DDATABASE) )) ,3,2  )
	Local cCxEdiRemet
	Local cCxEdiDest
	Local cArqTxt := ''

	cCgcSMO := GetAdvFVal('SM0', 'M0_CGC', cEmpAnt + cFilAnt, 1, '')
	cCgcSMO := StrTran ( cCgcSMO,"-","")
	GFELog110:Add("- CNPJ da Filial corrente..: " + cCgcSMO)

	dbSelectArea("GU3")
	dbSetOrder(11)
	If dbSeek(xFilial("GU3")+cCgcSMO)
		cCxEdiRemet := GU3->GU3_CXEDI
		GFELog110:Add("- Caixa Postal Remetente...:  " + cCxEdiRemet)
	EndIf

	dbSelectArea("GU3")
	dbSetOrder(1)
	If dbSeek(xFilial("GU3")+(cAliasQry)->GWU_CDTRP)
		cCxEdiDest := GU3->GU3_CXEDI
		GFELog110:Add("- Caixa Postal Destinatário:  " + cCxEdiDest)
	EndIf


	cArqTxt += "000"
	cArqTxt += PadR(Alltrim(cCxEdiRemet),35)
	cArqTxt += PadR(Alltrim(cCxEdiDest),35)

	cArqTxt += GFEADTDM()+cAno

	cArqTxt += GFEAHRMN()
	cArqTxt += "NOT"+GFEADTDM()+GFEAHRMN()+"0"
	cArqTxt += PadR("",145)
	cArqTxt += CRLF

	AddString(cArqTxt)
Return


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg310()

Grava no arquivo os dados referentes ao registro "000" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//310 - CABEÇALHO DE DOCUMENTO
//--------------------------------------
Static Function Reg310()
	Local cArqTxt := ''
	
	cCdRemAnt := ''
	nCountRem := 0
	
	cArqTxt += "310"
	cArqTxt += "NOTFI"
	cArqTxt += GFEADTDM()
	cArqTxt += GFEAHRMN()
	cArqTxt += Alltrim(STR(nSeq))
	cArqTxt += PadR("",223)
	cArqTxt += CRLF

	nSeq += 1
	If nSeq == 9
		nSeq := 0
	EndIf
	AddString(cArqTxt)
Return


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg311()

Grava no arquivo os dados referentes ao registro "311" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//311 - DADOS DA EMBARCADORA
//--------------------------------------
Static Function Reg311()
	Local cArqTxt := ""
	Local cIdFed
	Local cIe
	Local cEnder
	Local cNmCid
	Local cUf
	Local nCep
	Local cNmEmit
	Local cCdEmis := GW1->GW1_CDREM
	
	
	If ExistBlock("GFE11006")
		cCdEmis := ExecBlock("GFE11006",.f.,.f.,{"3.1",GW1->(RecNo())})
	EndIf
	
	dbSelectArea("GU3")
	dbSetOrder(1)
	If Empty(cCdEmis)
		dbSeek(xFilial("GU3")+GW1->GW1_CDREM)
	Else
		dbSeek(xFilial("GU3")+cCdEmis)
	EndIf

	cIdFed  := GU3->GU3_IDFED   //CGC
	cIe     := GFEFormIE(GU3->GU3_IE) // INSCRIÇÃO ESTADUAL
	cEnder  := GU3->GU3_ENDER   // ENDEREÇO
	nCep    := GU3->GU3_CEP     //CEP
	cNmEmit := GU3->GU3_NMEMIT  //Nome emitente

	dbSelectArea("GU7")
	dbSetOrder(1)
	IF dbSeek(xFilial("GU7")+GU3->GU3_NRCID)
		cNmCid := GU7->GU7_NMCID
		cUf    := GU7->GU7_CDUF
	Endif

	cArqTxt += "311"
	cArqTxt += PadR(cIdFed ,14)
	cArqTxt += PadR(cIe    ,15)
	cArqTxt += PadR(cEnder ,40)
	cArqTxt += PadR(cNmCid ,35)
	cArqTxt += PadR(nCep   ,9 )
	cArqTxt += PadR(cUf    ,9 )
	cArqTxt += GFEADTDM()+ALLTRIM(STR(YEAR(DDATABASE)))
	cArqTxt += PadR(cNmEmit,40)
	cArqTxt += PadR(""     ,67)
	cArqTxt += CRLF
	AddString(cArqTxt)
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg312()

Grava no arquivo os dados referentes ao registro "312" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//312 - DADOS DO DESTINATÁRIO DA MERCADORIA
//--------------------------------------
Static Function Reg312()
	Local cArqTxt := ""
	Local cNmDest
	Local cIdFedDes
	Local cIeDes
	Local cEndDes
	Local cBairDes
	Local cCidDes
	Local cCepDes
	Local cCdCidDes
	Local cUfDes
	Local cFoneDes
	Local cTpIdDes


	dbSelectArea("GU3")
	dbSetOrder(1)
	If dbSeek(xFilial("GU3")+GW1->GW1_CDDEST)
		cNmDest   := GU3->GU3_NMEMIT //Nome destinatário
		cIdFedDes := GU3->GU3_IDFED  //CPF - CNPJ
		cIeDes    := GFEFormIE(GU3->GU3_IE) //Inscrição Estadual RG
		cFoneDes  := GU3->GU3_FONE1 //Telefone

		//Natureza
		If GU3->GU3_NATUR == "J"
			cTpIdDes := "1"
		Else
			cTpIdDes := "2"
		Endif

		If (Empty(GW1->GW1_ENTEND) .AND. Empty(GW1->GW1_ENTNRC))
			cEndDes   := GU3->GU3_ENDER // Endereço
			cBairDes  := GU3->GU3_BAIRRO //Bairro
			cCdCidDes := GU3->GU3_NRCID //Cidade
			cCepDes   := GU3->GU3_CEP   //CEP

			dbSelectArea("GU7")
			dbSetOrder(1)
			IF dbSeek(xFilial("GU7")+GU3->GU3_NRCID)
				cCidDes := GU7->GU7_NMCID //Nome da cidade
				cUfDes  := GU7->GU7_CDUF  //UF
			Endif

		Else
			cEndDes   := GW1->GW1_ENTEND // Endereço
			cBairDes  := GW1->GW1_ENTBAI //Bairro
			cCdCidDes := GW1->GW1_ENTNRC //Cidade
			cCepDes   := GW1->GW1_ENTCEP   //CEP

			dbSelectArea("GU7")
			dbSetOrder(1)
			IF dbSeek(xFilial("GU7")+GW1->GW1_ENTNRC)
				cCidDes := GU7->GU7_NMCID //Nome da cidade
				cUfDes  := GU7->GU7_CDUF  //UF
			Endif
		EndIf
	EndIf

	cArqTxt += "312"
	cArqTxt += PadR(cNmDest   ,40)
	cArqTxt += PadL(AllTrim(cIdFedDes) ,14,"0")
	cArqTxt += PadR(cIeDes    ,15)
	cArqTxt += PadR(cEndDes   ,40)
	cArqTxt += PadR(cBairDes  ,20)
	cArqTxt += PadR(cCidDes   ,35)
	cArqTxt += PadR(cCepDes   ,9 )
	cArqTxt += PadR(cCdCidDes ,9 )
	cArqTxt += PadR(cUfDes    ,9 )
	cArqTxt += PadR(""        ,4 )
	cArqTxt += PadR(cFoneDes  ,35)
	cArqTxt += PadR(cTpIdDes  ,1 )
	cArqTxt += PadR(""        ,6 )
	cArqTxt += CRLF
	AddString(cArqTxt)
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg313()

Grava no arquivo os dados referentes ao registro "313" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//313 - DADOS DE NOTA FISCAL
//--------------------------------------
Static Function Reg313()
	Local cArqTxt     := ""
	Local cTpTrib     := "S"
	Local cTpFret     := ""
	Local cTpUso      := ""
	Local cPlaca      := ""
	Local cMeioTransp := "1" // Default Rodoviário
	Local cAcaoDoc    := ""
	Local nQtVol      := 0
	Local nValor      := 0
	Local nPesoR      := 0
	Local nVol        := 0
	Local lTMSAtivo   := SuperGetMv("MV_INTTMS", .F., .F.) == .T.
	Local cAliGXP     := Nil
	Local cGW1_FILIAL := GW1->GW1_FILIAL
	Local cGW1_CDTPDC := GW1->GW1_CDTPDC
	Local cGW1_EMISDC := GW1->GW1_EMISDC
	Local cGW1_SERDC  := GW1->GW1_SERDC
	Local cGW1_NRDC   := GW1->GW1_NRDC
	Local cGW1_NRROM  := GW1->GW1_NRROM
	Local cGW1_NRREG  := GW1->GW1_NRREG

	Local dGW1_DTEMIS := GW1->GW1_DTEMIS
	Local cGW1_DSESP  := GW1->GW1_DSESP

	Private aRetor[6]
	
	//Meio de transporte.
	If (cAliasQry)->GU3_MODAL $ '1|2|6|7' //Nao informado - Rodoviario - Dutoviario - Multimodal
		cMeioTransp := "1"
	ElseIf (cAliasQry)->GU3_MODAL == '3' //Ferroviario
		cMeioTransp := "5" 
	ElseIf (cAliasQry)->GU3_MODAL == '4' //Aereo
		cMeioTransp := "2"
	ElseIf (cAliasQry)->GU3_MODAL == '5' //Aquaviario
		cMeioTransp := "3"
	EndIf

	dbSelectArea("GW8")
	dbSetOrder(1)
	dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
	While !Eof() .And. GW1->GW1_FILIAL == GW8->GW8_FILIAL .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC
		nValor += GW8->GW8_VALOR
		nPesoR += GW8->GW8_PESOR
		nVol += GW8->GW8_VOLUME
		dbSelectArea("GW8")
		dbSkip()
	EndDo

	nQtVol := GW1->GW1_QTVOL

	//Ponto de entrada para retornar a quantidade de volumes da nota fiscal
	If ExistBlock("GFEA1104")
		nQtVol := ExecBlock("GFEA1104",.f.,.f.)
	EndIf
	
	nPesoR := Round(nPesoR,2)
	nVol   := Round(nVol,2)

	If GW1->GW1_ICMSDC == "2"
		cTpTrib := "N"
	EndIf

	GFEARATDC()

	If GW1->GW1_TPFRET == "1" .Or. GW1->GW1_TPFRET == "2"
		cTpFret := "C"
	Else
		cTpFret := "F"
	Endif

	If GW1->GW1_USO == "1"
		cTpUso := STR0001 //"Industrialização/Venda"
	Else
		cTpUso := STR0002 //"Uso/Consumo"
	Endif

	If GW1->GW1_SIT == '7' .And. GW1->GW1_ENVEDI == '1'
		cAcaoDoc := "E"
	Else
		cAcaoDoc := "I"
	EndIf

	dbSelectArea("GWN")
	dbSetOrder(1)
	If dbSeek(GW1->GW1_FILIAL+GW1->GW1_NRROM)
		cPlaca := GWN->GWN_PLACAD
	Endif

	cAliGXP := GFEA110GXP({cGW1_FILIAL,cGW1_CDTPDC,cGW1_EMISDC,cGW1_SERDC,cGW1_NRDC})		// Listagem de dados das NFs em Tabela GXP
	If Empty(GW1->GW1_DANFE) .And. lTMSAtivo .And. (cAliGXP)->(!EoF())
		While (cAliGXP)->(!EoF())

			cGW1_NRDC   := (cAliGXP)->NUMNFC
			dGW1_DTEMIS := StoD((cAliGXP)->EMINFC)

			cArqTxt += "313" //1
			cArqTxt += PadR(cGW1_NRROM,15) //4
			cArqTxt += PadR(cGW1_NRREG,7) //19
			cArqTxt += cMeioTransp
			cArqTxt += PadR("2",1) //27
			cArqTxt += PadR("2",1) //28
			cArqTxt += PadR(cTpFret,1) //29
			cArqTxt += PadR((cAliGXP)->SERNFC,3) //30
			cArqTxt += IIf(Len(AllTrim(cGW1_NRDC)) > 8, SubStr(AllTrim(cGW1_NRDC), Len(AllTrim(cGW1_NRDC)) -7), PadL(AllTrim(cGW1_NRDC), 8, "0")) //33
			cArqTxt += PadR(Substr(StrTran(DTOC(dGW1_DTEMIS),"/"),1,4) + Alltrim(Str(Year(dGW1_DTEMIS))),8) //41
			cArqTxt += PadR(cTpUso,15) //49

			If p_ERPINT == "1"
				GWB->(dbSetOrder(2))
				If GWB->(dbSeek(cGW1_FILIAL + cGW1_CDTPDC + cGW1_EMISDC + cGW1_SERDC + cGW1_NRDC))
					cDsUnit := Posicione("GUG", 1, xFilial("GUG") + GWB->GWB_CDUNIT, "GUG_DSUNIT")
					cArqTxt += PadR(cDsUnit, 15) //  3. Marca dos Volumes Transportados
				Else
					cArqTxt += PadR("", 15)
				EndIf
			Else
				cArqTxt += PadR(cGW1_DSESP,15)//64
			EndIf

			// validação para caso extrapole o tamanho do campo (3,2), imprima 00000 
			cVol := StrZero(Round((cAliGXP)->VOLUME,2) * 100,5)
			If cVol = "*****"
				cVol := "00000"
				nVol := 0
			EndIf

			cArqTxt += StrZero((cAliGXP)->QTDD * 100, 7)  												//79 - QUANTIDADE DE VOLUMES 7
			cArqTxt += STRZERO((cAliGXP)->VALOR * 100, 15) 												//86 - VALOR TOTAL DA NOTA
			cArqTxt += STRZERO((cAliGXP)->PESO * 100, 7)  												//101 - PESO TOTAL DA MERCADORIA
			cArqTxt += cVol    																			//108 - PESO DENSIDADE CUBAGEM
			cArqTxt += PadR(cTpTrib,1)        															//113 - TIPO DE ICMS
			cArqTxt += PadR("N",1)            															//114 - SEGURO JÁ EFETUADO (S/N)?
			cArqTxt += STRZERO((cAliGXP)->VALSEG,15)          											//115 - VALOR DO SEGURO ?
			cArqTxt += STRZERO(0,15)          															//130 - VALORA SER COBRADO ?
			cArqTxt += PadR(cPlaca,7)         															//145 - NO DA PLACA CAMINHÃO OU DA CARRETA
			cArqTxt += PadR("N",1)            															//152 - PLANO DE CARGA RÁPIDA (S/N)?
			cArqTxt += Iif(aRetor[1] == Nil, STRZERO(0,15), STRZERO(aRetor[1]*100,15) ) 				//153 VALOR DO FRETE PESO VOLUME
			cArqTxt += Iif(aRetor[2] == Nil, STRZERO(0,15), STRZERO(aRetor[2]*100,15) ) 				//168 VALOR AD VALOREM
			cArqTxt += Iif(aRetor[3] == Nil, STRZERO(0,15), STRZERO(aRetor[3]*100,15) ) 				//183 VALOR TOTAL DAS TAXAS
			cArqTxt += Iif(aRetor[4] == Nil, STRZERO(0,15), STRZERO(aRetor[4]*100,15) ) 				//198 VALOR TOTAL DO FRETE
			cArqTxt += PadR(cAcaoDoc,1)       															//213 - AÇÃO DO DOCUMENTO
			cArqTxt += Iif(aRetor[5] == Nil, STRZERO(0,12), STRZERO((cAliGXP)->VALICM * 100,12) ) 		//214 VALOR DO ICMS
			cArqTxt += Iif(aRetor[6] == Nil, STRZERO(0,12), STRZERO(aRetor[6]*100,12) ) 				//226 VALOR DO ICMS RETIDO
			cArqTxt += PadR("N",1)            															//238 - INDICAÇÃO DE BONIFICAÇÃO (S/N)
			cArqTxt += SUBSTRING((cAliGXP)->DANFE,1,44) 												//239 - FILLER -  PREENCHER COM BRANCOS
			cArqTxt += CRLF                   															//283

			nVlTotNf   += (cAliGXP)->VALOR
			nPesoTotNf += (cAliGXP)->PESO
			nTotVol    += nVol
			nQtTotVol  += nQtVol

			(cAliGXP)->(dbSkip())
		EndDo

	Else
		cArqTxt += "313"//1
		cArqTxt += PadR(cGW1_NRROM,15)//4
		cArqTxt += PadR(cGW1_NRREG,7)//19
		cArqTxt += cMeioTransp
		cArqTxt += PadR("2",1)//27
		cArqTxt += PadR("2",1)//28
		cArqTxt += PadR(cTpFret,1)//29
		cArqTxt += PadR(SerieNfId("GW1",2,"GW1_SERDC"),3) //30
		cArqTxt += IIf(Len(AllTrim(cGW1_NRDC)) > 8, SubStr( AllTrim(cGW1_NRDC), Len(AllTrim(cGW1_NRDC)) -7 ), PadL(AllTrim(cGW1_NRDC), 8, "0"))//33
		cArqTxt += PadR(Substr(STRTRAN(DTOC(dGW1_DTEMIS),"/"),1,4)+ALLTRIM(STR(YEAR(dGW1_DTEMIS))),8)//41
		cArqTxt += PadR(cTpUso,15)//49

		If p_ERPINT == "1"
			GWB->(dbSetOrder(2))
			If GWB->(dbSeek(cGW1_FILIAL + cGW1_CDTPDC + cGW1_EMISDC + cGW1_SERDC + cGW1_NRDC))
				cDsUnit := POSICIONE("GUG",1, xFilial("GUG") + GWB->GWB_CDUNIT, "GUG_DSUNIT")
				cArqTxt += PadR(cDsUnit, 15) //  3. Marca dos Volumes Transportados
			Else
				cArqTxt += PadR("", 15)
			EndIf
		Else
			cArqTxt += PadR(cGW1_DSESP,15)//64
		EndIf

		// validação para caso extrapole o tamanho do campo (3,2), imprima 00000 
		cVol := STRZERO(nVol*100,5)
		If cVol = "*****"
			cVol := "00000"
			nVol := 0
		EndIf

		cArqTxt += STRZERO(nQtVol*100,7)  //79 - QUANTIDADE DE VOLUMES 7
		cArqTxt += STRZERO(nValor*100,15) //86 - VALOR TOTAL DA NOTA
		cArqTxt += STRZERO(nPesoR*100,7)  //101 - PESO TOTAL DA MERCADORIA
		cArqTxt += cVol    //108 - PESO DENSIDADE CUBAGEM
		cArqTxt += PadR(cTpTrib,1)        //113 - TIPO DE ICMS
		cArqTxt += PadR("N",1)            //114 - SEGURO JÁ EFETUADO (S/N)?
		cArqTxt += STRZERO(0,15)          //115 - VALOR DO SEGURO ?
		cArqTxt += STRZERO(0,15)          //130 - VALORA SER COBRADO ?
		cArqTxt += PadR(cPlaca,7)         //145 - NO DA PLACA CAMINHÃO OU DA CARRETA
		cArqTxt += PadR("N",1)            //152 - PLANO DE CARGA RÁPIDA (S/N)?
		cArqTxt += Iif(aRetor[1] == Nil, STRZERO(0,15), STRZERO(aRetor[1]*100,15) ) //153 VALOR DO FRETE PESO VOLUME
		cArqTxt += Iif(aRetor[2] == Nil, STRZERO(0,15), STRZERO(aRetor[2]*100,15) ) //168 VALOR AD VALOREM
		cArqTxt += Iif(aRetor[3] == Nil, STRZERO(0,15), STRZERO(aRetor[3]*100,15) ) //183 VALOR TOTAL DAS TAXAS
		cArqTxt += Iif(aRetor[4] == Nil, STRZERO(0,15), STRZERO(aRetor[4]*100,15) ) //198 VALOR TOTAL DO FRETE
		cArqTxt += PadR(cAcaoDoc,1)       //213 - AÇÃO DO DOCUMENTO
		cArqTxt += Iif(aRetor[5] == Nil, STRZERO(0,12), STRZERO(aRetor[5]*100,12) ) //214 VALOR DO ICMS
		cArqTxt += Iif(aRetor[6] == Nil, STRZERO(0,12), STRZERO(aRetor[6]*100,12) ) //226 VALOR DO ICMS RETIDO
		cArqTxt += PadR("N",1)            //238 - INDICAÇÃO DE BONIFICAÇÃO (S/N)
		cArqTxt += SUBSTRING(GW1->GW1_DANFE,1,44) //239 - FILLER -  PREENCHER COM BRANCOS
		cArqTxt += CRLF                   //283

		nVlTotNf   += nValor
		nPesoTotNf += nPesoR
		nTotVol    += nVol
		nQtTotVol  += nQtVol
	EndIf
	
	AddString(cArqTxt)

	If Select( cAliGXP ) > 0
		(cAliGXP)->(dbCloseArea())
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg333()

Grava no arquivo os dados referentes ao registro "333" (segundo o layout proceda 3.1)

@author Lidiomar Fernando dos S. Machado
@since 01/04/13
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//333 - DADOS COMPLEMENTARES DA NOTA FISCAL
//--------------------------------------
Static Function Reg333()
	Local cArqTxt := ""
	Local cCfop := ''
	Local cTpEnt := '0' // No periodo
	Local cDtIniEnt := ''
	Local cHrIniEnt := ''
	Local cDtFinEnt := ''

	dbSelectArea("GW8")
	dbSetOrder(1)
	dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
	While !GW8->(Eof()) .AND. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .AND. GW8->GW8_EMISDC == GW1->GW1_EMISDC ;
		.AND. GW8->GW8_SERDC == GW1->GW1_SERDC .AND. GW8->GW8_NRDC == GW1->GW1_NRDC
		If !Empty(GW8->GW8_CFOP)
			cCfop := GW8->GW8_CFOP
			Exit
		EndIf
		GW8->(dbSkip())
	EndDo

	dbSelectArea("GWU")
	dbSetOrder(1)

	dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
	If !Empty(GWU->GWU_DTENT)
		cTpEnt := '1' // Na data
		cDtIniEnt := STRTRAN(dtoc(GWU->GWU_DTENT),"/","")
	ElseIf !Empty(GWU->GWU_DTPENT)
		cTpEnt := '4' // No periodo
		cDtIniEnt := STRTRAN(dtoc(GWU->GWU_DTPENT),"/","") // data prevista
		cHrIniEnt := STRTRAN(GWU->GWU_HRPENT,":","") // hora prevista
		cDtFinEnt := STRTRAN(dtoc(GWU->GWU_DTPENT),"/","")// data prevista
	EndIf

	cArqTxt += "333"							//001 -  IDENTIFICADOR DE REGISTRO	
	cArqTxt += PadL(Alltrim(cCfop),4,"0") 	// 004 - CÓDIGO DA OPERAÇÃO FISCAL NOTA FISCAL
	cArqTxt += PadR(cTpEnt,1)  				// 008 - TIPO DE PERÍODO DE ENTREGA
	cArqTxt += PadR(cDtIniEnt, 8)  			// 009 - DATA INICIAL DE ENTREGA
	cArqTxt += PadR(cHrIniEnt,4)   			//017 - HORA INICIAL DE ENTREGAhora inicial de entrega
	cArqTxt += PadR(cDtFinEnt,8)  			// 021 -  DATA FINAL DE ENTREGA	
	cArqTxt += Space(4)   					//029 -  HORA INICIAL DE ENTREGA 			
	cArqTxt += Space(15)  					//033 -  IDENTIFICAÇÃO DO LOCAL DE DESEMBARQUE	        
	cArqTxt += PadR("N",1) 					//048 -  CÁLCULO DE FRETE DIFERENCIADO? (S/N)	 S = SIM, CÁLCULO DIFERENCIADO, USO DE UMA TABELA DE PREÇO DIFERENTE DA TABELA PADRÃO ACORDADA ENTRE AS PARTES N = NÃO, CÁLCULO NÃO DIFERENCIADO. USO DA TABELA PADRÃO PREVIAMENTE ACORDADA.
	cArqTxt += Space(10) 					//049 -  IDENTIFICAÇÃO TABELA DE PREÇO DE FRETE	            

	//DADOS DE ENTREGA CASADA (OUTRAS NFs) - 1:
	cArqTxt += Space(15) //059 -  C.G.C. DO EMISSOR DA NOTA FISCAL A SER ENTREGUE		
	cArqTxt += Space(3)	//074 -  SÉRIE DA NOTA FISCAL 	
	cArqTxt += Space(8)	//077 -  NÚMERO DA NOTA FISCAL			
	//DADOS DE ENTREGA CASADA (OUTRAS NFs) - 2:
	cArqTxt += Space(15) //085 -  C.G.C. DO EMISSOR DA NOTA FISCAL A SER ENTREGUE	
	cArqTxt += Space(3) 	//100 -  SÉRIE DA NOTA FISCAL				
	cArqTxt += Space(8)	//103 -  NÚMERO DA NOTA FISCAL	
	//DADOS DE ENTREGA CASADA (OUTRAS NFs) - 3:
	cArqTxt += Space(15)	//111 -  C.G.C. DO EMISSOR DA NOTA FISCAL A SER ENTREGUE      
	cArqTxt += Space(3)	//126 -  SÉRIE DA NOTA FISCAL                      
	cArqTxt += Space(8)	//129 -  NÚMERO DA NOTA FISCAL	                
	//DADOS DE ENTREGA CASADA (OUTRAS NFs) - 4:
	cArqTxt += Space(15)	//137 -  C.G.C. DO EMISSOR DA NOTA FISCAL A SER ENTREGUE     
	cArqTxt += Space(3)	//152 -  SÉRIE DA NOTA FISCAL              
	cArqTxt += Space(8)	//155 -  NÚMERO DA NOTA FISCAL	 
	//DADOS DE ENTREGA CASADA (OUTRAS NFs) - 5:
	cArqTxt += Space(15)	//163 -  C.G.C. DO EMISSOR DA NOTA FISCAL A SER ENTREGUE     
	cArqTxt += Space(3)	//178 -  SÉRIE DA NOTA FISCAL        
	cArqTxt += Space(8)	//181 -  NÚMERO DA NOTA FISCAL	                 

	cArqTxt += Space(15) //189 -  VALOR DE DESPESAS ADICIONAIS DE TRANSPORTE	

	cArqTxt += Space(5)	//204 -  TIPO DO VEÍCULO DE TRANSPORTE (CONTINUAÇÃO)		    
	cArqTxt += Space(10)	//209 -  FILIAL EMIS. CONHECIMENTO – TRANSP. CONTRATANTE	    
	cArqTxt += Space(5)	//219 -  SÉRIE DO CONHECIMENTO DA TRANSPORT. CONTRATANTE	    
	cArqTxt += Space(12)	//224 -  NÚMERO DO CONHECIMENTO DA TRANSP. CONTRATANTE	    
	cArqTxt += Space(5)	//236 -  FILLER

	cArqTxt += CRLF
	AddString(cArqTxt)
Return


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg314()

Grava no arquivo os dados referentes ao registro "314" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//314 - MERCADORIA DA NOTA FISCAL
//--------------------------------------

Static Function Reg314()
	Local cArqTxt := ""
	Local cItens := ""
	Local nQtVol := 0
	Local nQtItens := 0

	dbSelectArea("GW8")
	dbSetOrder(1)
	If dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
		cItens += "314"
		While !Eof() .AND. ;
				GW8->GW8_FILIAL == GW1->GW1_FILIAL .AND. ;
				GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .AND. ;
				GW8->GW8_EMISDC == GW1->GW1_EMISDC .AND. ;
				GW8->GW8_SERDC  == GW1->GW1_SERDC  .AND. ;
				GW8->GW8_NRDC   == GW1->GW1_NRDC

			nQtItens++
			If nQtItens > 4
				cArqTxt += PadR(cItens,240) + CRLF
				nQtItens := 1
				cItens := ""
				cItens += "314" 			
			EndIf				

			nQtVol := GW8->GW8_QTDE

			//Ponto de entrada para retornar a quantidade de volumes dos itens da nota fiscal
			If lPEA11005
					nQtVol := ExecBlock("GFEA1105", .F., .F.)
			EndIf

			cItens += STRZERO(nQtVol * 100, 7)
			If p_ERPINT == "1"
				GWB->(dbSetOrder(2))
				If GWB->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
				 	cDsUnit := POSICIONE("GUG",1, xFilial("GUG") + GWB->GWB_CDUNIT, "GUG_DSUNIT")
					cItens += PadR(cDsUnit, 15)	
				Else
					cItens += PadR("", 15)
				EndIf
			Else
				cItens += PadR(GW1->GW1_DSESP ,15)
			EndIf	
			
			cItens += PadR(GW8->GW8_ITEM, 30)

			GW8->(dbSkip())
		EndDo
	EndIf
	
	If nQtItens <= 4
		cArqTxt += PadR(cItens,240) + CRLF
	EndIf
	AddString(cArqTxt)
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg314agr()

Grava no arquivo os dados referentes ao registro "314" (segundo o layout proceda 3.1)
(agrupados por classificação de frete)
@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//314 - MERCADORIA DA NOTA FISCAL
//--------------------------------------
Static Function Reg314AGR()
	Local cArqTxt := ""
//	Local nLen := 0
	Local cItens := ""
//	Local nLinha := 1
//	Local nRest
//	Local cCdClFrAnt := Nil
	Local nQtVol := 0
	Local aClfFrtIt := {} // Array com o agrupamento por classificação de frete
	Local aDadosSom[2] // Array com a somatoria da quantidade dos itens
	Local nPos
	Local nCont := 1
	Local nQtItens := 0

	dbSelectArea("GW8")
	dbSetOrder(1)
	dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
	While !Eof() .AND. ;
			GW1->GW1_FILIAL == GW8->GW8_FILIAL .AND. ;
			 GW1->GW1_CDTPDC == GW8->GW8_CDTPDC .AND. ;
			 GW1->GW1_EMISDC == GW8->GW8_EMISDC .AND. ;
			 GW1->GW1_SERDC  == GW8->GW8_SERDC  .AND. ;
			 GW1->GW1_NRDC   == GW8->GW8_NRDC


		nPos := AScan(aClfFrtIt, {|x| x[1] == GW8->GW8_CDCLFR})

		nQtVol := GW8->GW8_QTDE

		//Ponto de entrada para retornar a quantidade de volumes dos itens da nota fiscal
		If lPEA11005
				nQtVol := ExecBlock("GFEA1105",.f.,.f.)
		EndIf

		If nPos == 0
			aDadosSom[1] := GW8->GW8_CDCLFR
			aDadosSom[2] := nQtVol
			AADD(aClfFrtIt, AClone(aDadosSom))
		Else
			aClfFrtIt[nPos][2] += nQtVol
		EndIf

		dbselectArea("GW8")
		dbSkip()
		nCont++
	EndDo

	cItens += "314"
	For nCont := 1 To Len(aClfFrtIt)
		nQtItens++
		If nQtItens > 4
			cArqTxt += PadR(cItens,240) + CRLF
			nQtItens := 1
			cItens := ""
			cItens += "314" 			
		EndIf
		
		cItens += STRZERO(aClfFrtIt[nCont][2]*100, 7)
		
		If p_ERPINT == "1"
				GWB->(dbSetOrder(2))
				If GWB->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
					cDsUnit := POSICIONE("GUG",1, xFilial("GUG") + GWB->GWB_CDUNIT, "GUG_DSUNIT")
					cItens += PadR(cDsUnit, 15)	
				Else 
					cItens += PadR("", 15)
				EndIf
			Else
				cItens += PadR(GW1->GW1_DSESP ,15)
			EndIf	
		cItens += PadR(aClfFrtIt[nCont][1], 30)     		
	Next
	
	If nQtItens <= 4
		cArqTxt += PadR(cItens,240) + CRLF
	EndIf
	AddString(cArqTxt)		
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg316()

Grava no arquivo os dados referentes ao registro "316" (segundo o layout proceda 3.1)

@author Lidiomar Fernando dos S. Machado
@since 28/03/2014
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//316 - DADOS PARA REDESPACHO DA MERCADORIA
//--------------------------------------
Static Function Reg316()
	Local cArqTxt := ""
	Local cCdTrp := ""
	Local cNmCid := ""
	Local cUf    := ""

	dbSelectArea("GWU")
	dbSetOrder(1)
	dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
	While !Eof() .And. GW1->GW1_FILIAL == GWU->GWU_FILIAL .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC
		  If val(GWU->GWU_SEQ) > val((cAliasQry)->GWU_SEQ)
			If GWU->GWU_CDTRP <> GW1->GW1_EMISDC .And. GWU->GWU_CDTRP != (cAliasQry)->GWU_CDTRP
				dbSelectArea("GU3")
				dbSetOrder(1)
				If dbSeek(xFilial("GU3")+GWU->GWU_CDTRP)
					cNmCid := Posicione("GU7", 1, xFilial("GU7") + GU3->GU3_NRCID, "GU7_NMCID")
					cUf	   := Posicione("GU7", 1, xFilial("GU7") + GU3->GU3_NRCID, "GU7_CDUF")

					cArqTxt += "316"
					cArqTxt += PadR(GU3->GU3_NMEMIT             ,40)
					cArqTxt += PadR(GU3->GU3_IDFED              ,14)
					cCdTrp 	:= Posicione("GU3",11,xFilial("GU3")+GU3->GU3_IDFED,"GU3_CDEMIT")
					cArqTxt += PadR(GFEFormIE(GU3->GU3_IE)       ,15)
					cArqTxt += PadR(GU3->GU3_ENDER              ,40)
					cArqTxt += PadR(GU3->GU3_BAIRRO             ,20)
					cArqTxt += PadR(cNmCid                      ,35)
					cArqTxt += PadR(GU3->GU3_CEP                ,9 )
					cArqTxt += PadR(GU3->GU3_NRCID              ,9 )
					cArqTxt += PadR(cUf                         ,9 )
					cArqTxt += PadR(""                          ,4 )
					cArqTxt += PadR(GU3->GU3_FONE1+GU3->GU3_FAX ,35)
					cArqTxt += PadR(""                          ,7 )
					cArqTxt += CRLF
				
					Exit
				Endif
			Endif
		Endif
		dbSelectArea("GWU")
		dbSkip()
	EndDo
	AddString(cArqTxt)
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg317()

Grava no arquivo os dados referentes ao registro "317" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//317 - DADOS RESPONSÁVEL PELO FRETE
//--------------------------------------
Static Function Reg317(cFilGW1)
	Local cArqTxt		:= ""
	Local cRaSoResp		:= ""
	Local cCgcResp		:= ""
	Local cIeREsp		:= ""
	Local cEndResp		:= ""
	Local cBairResp		:= ""
	Local cNmCidResp	:= ""
	Local cCepResp		:= ""
	Local cCdCidResp	:= ""
	Local cUfResp		:= ""
	Local cNumComResp	:= ""
	Local cNmCid		:= ""
	Local cUf			:= ""
	Local cRespFre		:= ""
	Local cFilConsulta	:= cFilGW1
  	Local cRet := "" 

	//Quando integrado com o TMS Protheus, é um transportador que utiliza o GFE
	// Desta forma, os dados do responsável pelo frete é a propria filial
	If s_INTTMS == .T.
		If Empty(cFilGW1)
			cFilConsulta := cFilAnt
		EndIf

		GFELog110:Add("- Parametro (MV_INTTMS) habilitado. Registro 317 será exportado com os dados da filial " + cFilConsulta,1)
		
		SM0->(dbSetOrder(1)) // CÓDIGO + Cod. Filial
		If SM0->(dbSeek(FWGrpCompany() + cFilConsulta))  // Pesquisa com Código + Cód. Filial selecionado.
			GU3->(dbSetOrder(11))
			If GU3->(dbSeek(xFilial("GU3") + SM0->M0_CGC))
				cRespFre	:= GU3->GU3_CDEMIT
			Else
				GFEResult:AddDetail("Registro 317 não gerado pois o CNPJ da filial "+cFilConsulta+" não está cadastrado no cadastro de emitentes (GU3).",1)
				GFELog110:Add("Registro 317 não gerado pois o CNPJ da filial "+cFilConsulta+" não está cadastrado no cadastro de emitentes (GU3).")
			EndIf
		EndIf
	Else
		If GW1->GW1_TPFRET == "1" .Or. GW1->GW1_TPFRET == "2"
			cRespFre := GW1->GW1_CDREM
		Else
			cRespFre := GW1->GW1_CDDEST
		EndIf
	EndIf
	
	If lPEA1108
		cRet := ExecBlock("GFEA1108",.f.,.f.,{317})
		if !Empty(cRet)
			cRespFre := cRet
		Endif
	EndIf	
	
	GU3->(dbSetOrder(1))
	If GU3->(dbSeek(xFilial("GU3") + cRespFre))
	 	cNmCid      := Posicione("GU7", 1, xFilial("GU7") + GU3->GU3_NRCID, "GU7_NMCID")
	 	cUf	        := Posicione("GU7", 1, xFilial("GU7") + GU3->GU3_NRCID, "GU7_CDUF" )
	 	cRaSoResp   := GU3->GU3_NMEMIT
		cCgcResp    := GU3->GU3_IDFED
		cIeREsp     := GFEFormIE(GU3->GU3_IE)
		cEndResp    := GU3->GU3_ENDER
		cBairResp   := GU3->GU3_BAIRRO
		cNmCidResp  := cNmCid
		cCepResp    := GU3->GU3_CEP
		cCdCidResp  := GU3->GU3_NRCID
		cUfResp     := cUf
		cNumComResp	:= GU3->GU3_FONE1 + GU3->GU3_FAX
	Endif
	

	If ExistBlock("GFEA1106")
		cRet := ExecBlock("GFEA1106",.f.,.f.,{})
		if !Empty(cRet)
			cIeREsp := cRet
		Endif
	EndIf

	cArqTxt += "317"
	cArqTxt += PadR(cRaSoResp  ,40)
	cArqTxt += PadR(cCgcResp   ,14)
	cArqTxt += PadR(cIeREsp    ,15)
	cArqTxt += PadR(cEndResp   ,40)
	cArqTxt += PadR(cBairResp  ,20)
	cArqTxt += PadR(cNmCidResp ,35)
	cArqTxt += PadR(cCepResp   ,9 )
	cArqTxt += PadR(cCdCidResp ,9 )
	cArqTxt += PadR(cUfResp    ,9 )
	cArqTxt += PadR(cNumComResp,35)
	cArqTxt += PadR(""         ,11)
	cArqTxt += CRLF

	AddString(cArqTxt)
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg318()

Grava no arquivo os dados referentes ao registro "318" (segundo o layout proceda 3.1)

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

//--------------------------------------
	//318 - VALORES TOTAIS DO DOCUMENTO (ARQ.)
//--------------------------------------
Static Function Reg318()
	Local cArqTxt := ""
	cArqTxt += "318"
	cArqTxt += STRZERO(Round(nVlTotNf, 2)*100   ,15 ) // VALOR TOTAL NOTAS FISCAIS
	cArqTxt += STRZERO(Round(nPesoTotNf,2)*100 ,15 ) // PESO TOTAL NOTAS
	cArqTxt += STRZERO(Round(nTotVol,2)*100    ,15 ) // PESO TOTAL DENSIDADE/CUBAGEM
	cArqTxt += STRZERO(Round(nQtTotVol,2)*100  ,15 ) // QUANTIDADE DE VOLUME
	cArqTxt += STRZERO(nVlCobrado*100 ,15 ) // VALOR TOTAL A SER COBRADO
	cArqTxt += STRZERO(nVlTotSeg*100  ,15 ) // VALOR TOTAL DO SEGURO
	cArqTxt += PadR(""        ,147) 		 // FILLER
	cArqTxt += CRLF

	nVlTotNf   := 0
	nPesoTotNf := 0
	nTotVol    := 0
	nQtTotVol  := 0
	nVlCobrado := 0
	nVlTotSeg  := 0

	AddString(cArqTxt)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTxt


Função que cria o TXT

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraTxt()

	Private nHdl
	
	If !FILE(cDiretorio) //Se o arquivo ainda não foi criado...
		nHdl := fCreate(cDiretorio)
		If nHdl == -1
			GFEResult:AddDetail(STR0003+cDiretorio+STR0004,1)//"O arquivo de nome "###" não pode ser executado! Verifique os parâmetros."###"Atenção!"
			GFELog110:AddDebug(STR0003+cDiretorio+STR0004,1)
			Return .F.
		Endif
	Else //Se já foi criado, abre a altera o arquivo existente
		nHdl := fOpen(cDiretorio,FO_READWRITE)
		If nHdl == -1
			GFEResult:AddDetail(STR0003+cDiretorio+STR0004,1)//"O arquivo de nome "###" não pode ser executado! Verifique os parâmetros."###"Atenção!"
			GFELog110:AddDebug(STR0003+cDiretorio+STR0004,1)
			Return .F.
		Else
			FSEEK(nHdl, 0, 2)
		Endif
	EndIf
	//Grava os dados no arquivo
	
	If fWrite(nHdl,cArqTxt,Len(cArqTxt)) != Len(cArqTxt)
		GFEResult:AddDetail("Ocorreu um erro na gravação de arquivo.",1)
		If !(IsBlind())
			If !MsgAlert(STR0006+STR0007,STR0005)//"Ocorreu um erro na gravação do arquivo."###"Continua?"###"Atenção!"
				Return .F.
			Endif
		EndIf
	Endif
	//Fecha o arquivo
	fClose(nHdl)

	cArqTxt := ""
Return .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} SchedDef()

Função chamada na execução do schedule.

/*/
//-------------------------------------------------------------------

Static Function SchedDef()
	Local aParam
	Local aOrd := {}
	aParam := {;
				"P"                                ,;  // Tipo: R para relatorio P para processo
				"GFEA110"						   ,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
				"GW1"                              ,;  // Alias
				aOrd                               ,;  // Array de ordens
			  }

Return aParam

//---------------------------
/*/{Protheus.doc} ValidGW1

@author Lidiomar Fernando dos S. Machado
@since 28/03/2014
@version 1.0

Validações:

	- Verifica se o tipo do documento de carga permite o envio EDI
	- Altera o status do documento de carga para "ENVIADO"

/*/
//-------------------------------------------------------------------




//-------------------------------------------------------------------
/*/{Protheus.doc} StatusEDI

Altera o status do documento de carga para a opção "1 = Enviado"

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function StatusEDI()
	RecLock("GW1",.F.)
	GW1->GW1_ENVEDI := "1"
	MsUnLock("GW1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEADTDM

Realiza tratamento na Data e o Mes corrente

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEADTDM()
	Local dDataDM
	dDataDM := Substring(DTOC(DDATABASE),1,2)
	dDataDM += Substring(DTOC(DDATABASE),4,2)
Return dDataDM

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAHRMN

Realiza Tratamento da Hora e o Mes Corrente

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEAHRMN()
	Local cHrMn
	cHrMn := Substring(TIME(),1,2)
	cHrMn += Substring(TIME(),4,2)
Return cHrMn

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEARATDC

Função de rateio dos documentos de carga

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEARATDC()
	Local nQtdDoc   := 0
	Local nVlDoc    := 0
	Local nQtM3Doc  := 0
	Local nPesoDoc  := 0
	Local nPesoCDoc := 0
	Local nQtVol    := 0
	Local aTaxas[6]
	Local lNoCalc := .T.
	Local aTaxas1  :={}

	Local nVLICMS := 0
	Local nICMRET := 0

	aTaxas[1] := 0
	aTaxas[2] := 0
	aTaxas[3] := 0
	aTaxas[4] := 0
	aTaxas[5] := 0
	aTaxas[6] := 0

	(cTRBAGRU)->(dbSetOrder(1))
	If (cTRBAGRU)->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_CDTPDC+GW1->GW1_SERDC+GW1->GW1_NRDC))

		GWH->(dbSetOrder(2))
		If GWH->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
			While GWH->(!Eof()) .And. GW1->GW1_FILIAL == GWH->GWH_FILIAL .And. GWH->GWH_CDTPDC == GW1->GW1_CDTPDC .And. GWH->GWH_EMISDC == GW1->GW1_EMISDC .And. GWH->GWH_SERDC == GW1->GW1_SERDC .And. GWH->GWH_NRDC == GW1->GW1_NRDC
				If Empty(aTaxas[4]) 
					aTaxas1  := GFERatDocCarga({GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC}, {GWH->GWH_FILIAL,GWH->GWH_NRCALC}, s_CRIRAT,1)
					aTaxas[4] := aTaxas1[1]
				Else 
					Exit
				EndIf

				dbSelectArea("GWF")
				GWF->(dbSetOrder(1))
				If GWF->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_NRCALC))
					While !GWF->( Eof() ) .And. GWH->(GWH_FILIAL+GWH_NRCALC) == GWF->(GWF_FILIAL+GWF_NRCALC)
						If GWH->GWH_TRECHO == (cAliasQry)->GWU_SEQ
							//Calcula o valor de frete peso, frete valor, pedágio e taxas.
							GFEA110CCF(GWF->GWF_FILIAL, GWF->GWF_NRCALC, @aTaxas)

							aTaxas[5] := GWF->GWF_VLICMS
							aTaxas[6] := GWF->GWF_ICMRET
						EndIf

						GWF->( dbSkip() )
					EndDo
				EndIf

				GWH->(dbSkip())
			EndDo
		EndIf

	Else
		dbselectArea("GW8")
		GW8->(dbSetOrder(1))
		GW8->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
		While GW8->(!Eof()) .And. GW8->GW8_FILIAL == GW1->GW1_FILIAL .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC

			nQtVol := GW8->GW8_QTDE
			//Ponto de entrada para retornar a quantidade de volumes dos itens da nota fiscal
			If lPEA11005
				nQtVol := ExecBlock("GFEA1105",.f.,.f.)
			EndIf

			nQtdDoc   += nQtVol
			nVlDoc    += GW8->GW8_VALOR
			nQtM3Doc  += GW8->GW8_VOLUME
			nPesoDoc  += GW8->GW8_PESOR
			nPesoCDoc += GW8->GW8_PESOC

			GW8->(dbSkip())
		EndDo

		dbSelectArea("GWH")
		GWH->(dbSetOrder(2))
		GWH->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
		While GWH->(!Eof()) .And. GW1->GW1_FILIAL == GWH->GWH_FILIAL .And. GWH->GWH_CDTPDC == GW1->GW1_CDTPDC .And. GWH->GWH_EMISDC == GW1->GW1_EMISDC .And. GWH->GWH_SERDC == GW1->GW1_SERDC .And. GWH->GWH_NRDC == GW1->GW1_NRDC
			If GWH->GWH_TRECHO == (cAliasQry)->GWU_SEQ
				dbSelectArea("GWF")
				GWF->(dbSetOrder(1))
				If GWF->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_NRCALC))
					While GWF->(!Eof()) .And. GWH->(GWH_FILIAL+GWH_NRCALC) == GWF->(GWF_FILIAL+GWF_NRCALC)
						If GWF->GWF_TPCALC != "8"

							//>>>Chave da tabela temporária
							cSeek := (cTRBAGRU)->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_CDTPDC+GW1->GW1_SERDC+GW1->GW1_NRDC))

							//Calcula o valor de frete peso, frete valor, pedágio e taxas.
							GFEA110CCF(GWF->GWF_FILIAL, GWF->GWF_NRCALC, @aTaxas)											

							If lRatearDC
								If Empty(aTaxas[4]) 
									aTaxas1  := GFERatDocCarga({GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC}, {GWF->GWF_FILIAL, GWF->GWF_NRCALC}, s_CRIRAT,1)
									aTaxas[4]:= aTaxas1[1]
								EndIf
							Else
								aTaxas[4] := VLTOTFRET(GWF->GWF_NRCALC) //+ soma do valor do frete com as taxas
							EndIf

							aTaxas[5] := GWF->GWF_VLICMS
							aTaxas[6] := GWF->GWF_ICMRET
							If GWH->GWH_TRECHO == (cAliasQry)->GWU_SEQ
								nVLICMS := GWF->GWF_VLICMS
								nICMRET := GWF->GWF_ICMRET
							EndIf

							RecLock(cTRBAGRU, IIF(cSeeK, .F., .T.))
								(cTRBAGRU)->FILIAL := GW1->GW1_FILIAL
								(cTRBAGRU)->CDTPDC := GW1->GW1_CDTPDC
								(cTRBAGRU)->EMISDC := GW1->GW1_EMISDC
								(cTRBAGRU)->SERDC  := GW1->GW1_SERDC
								(cTRBAGRU)->NRDC   := GW1->GW1_NRDC
								//<<<

								(cTRBAGRU)->VLFRPESVOL := aTaxas[1]   //VALOR DO FRETE PESO VOLUME
								(cTRBAGRU)->VLADVAL    := aTaxas[2]   //VALOR AD VALOREM
								(cTRBAGRU)->VLTOTTX    := aTaxas[3]   //VALOR TOTAL DAS TAXAS
								(cTRBAGRU)->VLTOTFRT   := aTaxas[4]   //VALOR TOTAL DO FRETE
								(cTRBAGRU)->VLICMS     := aTaxas[5]   //VALOR DO ICMS
								(cTRBAGRU)->VLICMSRE   := aTaxas[6]   //VALOR DO ICMS RETIDO
							MsUnLock(cTRBAGRU)

							lNoCalc := .F.
						EndIf
						GWF->( dbSkip() )
					EndDo
				Endif
				
				//Caso não tenha sido encontrado um cálculo normal, reposiciona na GWF
				//no cálculo de estimativa.
				If lNoCalc
					dbSelectArea("GWF")
					dbSetOrder(1)
					If dbSeek(GWH->GWH_FILIAL+GWH->GWH_NRCALC)
						//>>>Chave da tabela temporária
						cSeek := (cTRBAGRU)->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_CDTPDC+GW1->GW1_SERDC+GW1->GW1_NRDC))

						//Calcula o valor de frete peso, frete valor, pedágio e taxas.
						GFEA110CCF(GWF->GWF_FILIAL, GWF->GWF_NRCALC, @aTaxas)											

						If lRatearDC
							aTaxas1 	:= GFERatDocCarga({GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC}, {GWF->GWF_FILIAL, GWF->GWF_NRCALC}, s_CRIRAT,1)
							aTaxas[4]	:= aTaxas1[1]
						Else
							aTaxas[4] := VLTOTFRET(GWF->GWF_NRCALC) //+ soma do valor do frete com as taxas
						EndIf
						aTaxas[5] := GWF->GWF_VLICMS
						aTaxas[6] := GWF->GWF_ICMRET

						RecLock(cTRBAGRU, IIF(cSeeK, .F., .T.))
							(cTRBAGRU)->FILIAL := GW1->GW1_FILIAL
							(cTRBAGRU)->CDTPDC := GW1->GW1_CDTPDC
							(cTRBAGRU)->EMISDC := GW1->GW1_EMISDC
							(cTRBAGRU)->SERDC  := GW1->GW1_SERDC
							(cTRBAGRU)->NRDC   := GW1->GW1_NRDC
							//<<<

							(cTRBAGRU)->VLFRPESVOL := aTaxas[1]   //VALOR DO FRETE PESO VOLUME
							(cTRBAGRU)->VLADVAL    := aTaxas[2]   //VALOR AD VALOREM
							(cTRBAGRU)->VLTOTTX    := aTaxas[3]   //VALOR TOTAL DAS TAXAS
							(cTRBAGRU)->VLTOTFRT   := aTaxas[4]   //VALOR TOTAL DO FRETE
							(cTRBAGRU)->VLICMS     := aTaxas[5]   //VALOR DO ICMS
							(cTRBAGRU)->VLICMSRE   := aTaxas[6]   //VALOR DO ICMS RETIDO
						MsUnLock(cTRBAGRU)
					EndIf
				EndIf
			EndIf

			dbSelectArea("GWH")
			GWH->(dbSkip())
		EndDo

		If nVLICMS > 0 .Or. nICMRET > 0
			aTaxas[5] := nVLICMS
			aTaxas[6] := nICMRET
		EndIf
	EndIf

	aRetor[1] := Round(aTaxas[1],2)
	aRetor[2] := Round(aTaxas[2],2)
	aRetor[3] := Round(aTaxas[3],2)
	aRetor[4] := Round(aTaxas[4],2)
	aRetor[5] := Round(aTaxas[5],2)
	aRetor[6] := Round(aTaxas[6],2)

Return aRetor

//---------------------------
/*/{Protheus.doc} GFEA110GRP

 - Função chamada pelo dicionário (validação do grupo de transportadores).

/*/
//-------------------------------------------------------------------

Function GFEA110GRP()

	If Empty(MV_PAR11)
		Return .T.
	EndIf

	dbSelectArea("GU1")
	GU1->( dbSetOrder(1) )
	If GU1->( dbSeek(xFilial("GU1") + MV_PAR11) )

		If GU1->GU1_SIT == "1" .And. GU1->GU1_TPGRP == "3"
			Return .T.
		Else
			Help(,, 'HELP',, "O Grupo de Emitente deve estar ativo e ser do tipo 'EDI'.", 1, 0)
		EndIf

	Else
		Help(,, 'HELP',, "Não foi encontrado Grupo de Emitente com o número informado.", 1, 0)
	EndIf

Return .F.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EmailEDI(cSaida)

Envia o arquivo EDI para os transportadores correspondentes.

@author Lidiomar Fernandos dos S. Machado
@since 09/04/2014
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function EmailEDI()
	Local 	nI
	Local 	cNmEmit
	Local 	cDir
	Local   cNmArqEmai
	Local	aRetMail

	If (cSaida == 1 .AND. Empty(aEmailTran)) .OR. (cSaida == 2 .AND. Empty(aArrayTran))
		GFEResEDI:AddDetail("Não há dados suficientes para o envio de email.",1)
		GFELog110:Add("Não há dados suficientes para o envio de email.",1)
		Return
	EndIf


	GFELog110:Add("Iniciando envio de emails:", 1)
	If cSaida == 1 //O mesmo arquivo para todos transportadores

		If !IsBlind()
			ProcRegua(len(aEmailTran))
		EndIf

		cDir    	:= aDadoDirEm[1]
		cNmArqEmai 	:= aDadoDirEm[2]

		//Necessário para enviar por email, o arquivo precisa estar no ROOTPATH
		Copy File&(cDir) To &(cNmArqEmai)
		For nI := 1 To len(aEmailTran)
			dbSelectArea("GU3")
			dbSetOrder(1) //GU3_FILIAL+GU3_CDEMIT
			If dbSeek(xFilial("GU3")+ aEmailTran[nI])
				cNmEmit 	:= GU3->GU3_NMEMIT
				eEmail  	:= GU3->GU3_EMAIL

				If !IsBlind()
					IncProc("Transp.: " + AllTrim(cNmEmit))
				EndIf
				aRetMail := GFEMail(eEmail, "Nota fiscal EDI","Segue anexo arquivo EDI com os dados das notas fiscais.", .F., {cNmArqEmai} )
				If !aRetMail[1]
					GFEResEDI:AddDetail("**Não foi possível enviar o arquivo: "+cNmArqEmai+" para o transportador "+AllTrim(cNmEmit)+". "+ CRLF + aRetMail[2],1)
					GFELog110:Add("**Não foi possível enviar o arquivo: "+cNmArqEmai+" para o transportador "+AllTrim(cNmEmit)+". "+ CRLF + aRetMail[2],1)
					If Empty(eEmail)
						GFEResEDI:AddDetail("*Transportador '"+AllTrim(cNmEmit)+"' não possui email cadastrado.",1)
						GFELog110:Add("*Transportador '"+AllTrim(cNmEmit)+"' não possui email cadastrado.",1)
					EndIf
				Else
					GFEResEDI:Add("**Foi enviado para o email '"+AllTrim(eEmail)+"' do transportador '"+AllTrim(cNmEmit) +"', o arquivo: "+cNmArqEmai+".",1)
					GFELog110:Add("**Foi enviado para o email '"+AllTrim(eEmail)+"' do transportador '"+AllTrim(cNmEmit) +"', o arquivo: "+cNmArqEmai+".",1)
				EndIf
			EndIf
		Next nI
		//Remove o arquivo do ROOTPATH
		FERASE(cNmArqEmai)
	Else //Um arquivo por transportador
		If !IsBlind()
			ProcRegua(len(aArrayTran))
		EndIf
		For nI := 1 to len(aArrayTran)
			dbSelectArea("GU3")
			dbSetOrder(1) //GU3_FILIAL+GU3_CDEMIT
			If dbSeek(xFilial("GU3")+ aArrayTran[nI][1])
				cNmEmit 	:= GU3->GU3_NMEMIT
				eEmail  	:= GU3->GU3_EMAIL
				cDir    	:= aArrayTran[nI][2]
				cNmArqEmai 	:= aArrayTran[nI][3]

				If !IsBlind()
					IncProc("Transp.: " + AllTrim(cNmEmit))
				EndIf

				//Necessário para enviar por email, o arquivo precisa estar no ROOTPATH
				Copy File&(cDir) To &("\"+cNmArqEmai)

				aRetMail := GFEMail(eEmail, "Nota fiscal EDI","Segue anexo arquivo EDI com os dados das notas fiscais.", .F., {"\"+cNmArqEmai} )
				If !aRetMail[1]
					GFEResEDI:AddDetail(CRLF + "**Não foi possível enviar o arquivo: "+cNmArqEmai+" para o transportador "+AllTrim(cNmEmit)+". "+ CRLF + aRetMail[2],1)
					GFELog110:Add(CRLF + "**Não foi possível enviar o arquivo: "+cNmArqEmai+" para o transportador "+AllTrim(cNmEmit)+". "+ CRLF + aRetMail[2],1)
					If Empty(eEmail)
						GFEResEDI:AddDetail("*Transportador '"+AllTrim(cNmEmit)+"' não possui email cadastrado.",1)
						GFELog110:Add("*Transportador '"+AllTrim(cNmEmit)+"' não possui email cadastrado.",1)
					EndIf
				Else
					GFEResEDI:Add(CRLF + "**Foi enviado para o email '"+AllTrim(eEmail)+"' do transportador '"+AllTrim(cNmEmit) +"', o arquivo: "+cNmArqEmai+".",1)
					GFELog110:Add(CRLF + "**Foi enviado para o email '"+AllTrim(eEmail)+"' do transportador '"+AllTrim(cNmEmit) +"', o arquivo: "+cNmArqEmai+".",1)
				EndIf
				//Remove o arquivo do ROOTPATH
				FERASE("\"+cNmArqEmai)
			EndIf
		Next nI
	EndIf
Return

Static Function AddString(cReg)
	If LEN(cArqTxt) + LEN(cReg) >= 1000000
		GeraTxt()
	EndIf
	cArqTxt+= cReg
Return

Static Function DefineDir(cCdTrp)
	Local   cNomArq
	Local   cNmArqEmai
	Local 	aDadosTran := {}
	/*cCdTrp = Usado somente quando a saída for "diretório",
	criará um arquivo por transportador, o nome do arquivo irá conter o cd do transportador.*/
	Default cCdTrp := ""

	// Início Ponto de Entrada
	If ExistBlock("GFEA1102")
			cNomArq := ExecBlock("GFEA1102",.f.,.f.,{cCdTrp})
	EndIf
	// Fim Ponto de Entrada

	IF cSaida == 1
		cDiretorio :=  Alltrim(cDestino)

		IF RAT("\",Alltrim(cDestino)) > RAT("/",Alltrim(cDestino))
			cNmArqEmai := Substr( Alltrim(cDestino),rat("\",Alltrim(cDestino)))
		Else
			cNmArqEmai := Substr( Alltrim(cDestino),rat("/",Alltrim(cDestino)))
		EndIf

		If !Empty(cNomArq)
			cDiretorio := Alltrim(cDestino)+"\"+cNomArq
			cNmArqEmai := cNomArq
		EndIf
	Else
		cDiretorio :=  Alltrim(cDestino)+"\"+"NF"+"_"+Alltrim("TRANSP")+"_"+AllTrim(cCdTrp)+"_"+DTOS(DDATABASE)+"_"+GFENOW()/*strtran(TIME(),":","")*/+".TXT"
		cNmArqEmai := "NF"+"_"+Alltrim("TRANSP")+"_"+AllTrim(cCdTrp)+"_"+DTOS(DDATABASE)+"_"+GFENOW()/*strtran(TIME(),":","")*/+".TXT"
		If !Empty(cNomArq)
			cDiretorio := Alltrim(cDestino)+"\"+cNomArq
			cNmArqEmai := cNomArq
		EndIf
	Endif

	If cEnvEmail == 1
		If cSaida == 2 .AND. aScan(aArrayTran, {|x| x[1] == cCdTrp}) == 0
			aDadosTran := {cCdTrp,cDiretorio,cNmArqEmai}
			AADD(aArrayTran,aDadosTran)
		ElseIf cSaida == 1 .AND. (Empty(aDadoDirEm[1]).AND.Empty(aDadoDirEm[2]))
			aDadoDirEm[1] = cDiretorio
			aDadoDirEm[2] = cNmArqEmai
		EndIf
	EndIf
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA110CCF(cFil, cNrCalc, aTaxas)
Efetua o cálculo do componente de frete de acordo com a categoria.
Usado para cálculo de valor de frete peso/volume, frete valor, pedágio e taxas

@author Wander Horongoso
@since 15/12/2015
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function GFEA110CCF(cFil, cNrCalc, aTaxas)

	dbSelectArea("GWI")
	dbSetOrder(1)
	dbSeek(cFil + cNrCalc)
	While !GWI->(Eof()) .AND. ;
		GWI->GWI_FILIAL == GWF->GWF_FILIAL .And. ;
		GWI->GWI_NRCALC == GWF->GWF_NRCALC

	    dbSelectArea("GV2")
	    dbSetOrder(1)
	    dbSeek(xFilial("GV2") + GWI->GWI_CDCOMP)    

		Do Case
			Case GV2->GV2_CATVAL == '1'	.And. !(UPPER(Alltrim(GV2->GV2_CDCOMP)) $ "PEDAGIO")		// Valor do Frete por Peso/Volume
				aTaxas[1] += GWI->GWI_VLFRET
			Case GV2->GV2_CATVAL == '2'			// Frete Valor
				aTaxas[2] += GWI->GWI_VLFRET
			Case GV2->GV2_CATVAL == '3'			//Taxas			
				aTaxas[3] += GWI->GWI_VLFRET
			Case GV2->GV2_CATVAL == '4'	.Or. UPPER(Alltrim(GV2->GV2_CDCOMP)) $ "PEDAGIO"		//Pedágio (Somado às taxas)
				aTaxas[3] += GWI->GWI_VLFRET
		EndCase

		dbSelectArea("GWI")
		dbSkip()
	EndDo

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA110GXP()
Listagem de NFs relacionadas do Documento de Carga usado de origem no TMS

@author
@since 25/05/2021
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA110GXP(aDocCarga)
	Local cAliGXP := GetNextAlias()

	BeginSQL Alias cAliGXP
		SELECT DTC.DTC_NFEID AS DANFE
		     , DTC.DTC_VALOR AS VALOR
			 , DTC.DTC_QTDVOL AS QTDD
			 , DTC.DTC_PESO AS PESO
			 , DTC.DTC_PESOM3 AS PESOM3
			 , DTC.DTC_METRO3 AS VOLUME
			 , DTC.DTC_VALSEG AS VALSEG
			 , DTC.DTC_VALICM AS VALICM
			 , DTC.DTC_NUMNFC AS NUMNFC
			 , DTC.DTC_SERNFC AS SERNFC
			 , DTC.DTC_EMINFC AS EMINFC
			 , DTC.DTC_BASICM AS BASICM
			 , DTC.DTC_VALICM AS VALICM
			 , DTC.DTC_BASESU AS BASESU
			 , DTC.DTC_VALIST AS VALIST
			 , DTC.DTC_ICMRET AS ICMRET
		FROM %Table:GXP% GXP
		INNER JOIN %Table:GU3% GU3
		ON GU3.GU3_FILIAL = %xFilial:GU3%
		AND GU3.GU3_CDEMIT = GXP.GXP_EMIORI
		AND GU3.%NotDel%
		INNER JOIN %Table:DTC% DTC
		ON DTC.DTC_FILORI = GXP.GXP_FILORI
		AND DTC.DTC_CLIREM = GU3.GU3_CDERP
		AND DTC.DTC_LOJREM = GU3.GU3_CDCERP
		AND DTC.DTC_NUMNFC = GXP.GXP_DOCORI
		AND DTC.DTC_SERNFC = GXP.GXP_SERORI
		AND DTC.DTC_NFEID = GXP.GXP_DANFE
		AND DTC.%NotDel%
		WHERE GXP.GXP_FILIAL = %Exp:aDocCarga[1]%
		AND GXP.GXP_CDTPDC = %Exp:aDocCarga[2]%
		AND GXP.GXP_EMISDC = %Exp:aDocCarga[3]%
		AND GXP.GXP_SERDC = %Exp:aDocCarga[4]%
		AND GXP.GXP_NRDC = %Exp:aDocCarga[5]%
		AND GXP.%NotDel%
	EndSQL

Return cAliGXP
