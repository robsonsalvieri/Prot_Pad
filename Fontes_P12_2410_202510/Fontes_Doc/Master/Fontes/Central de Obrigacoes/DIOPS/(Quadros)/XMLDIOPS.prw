#Include 'Protheus.ch'
#include 'Fileio.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"

#Define F_BLOCK 		512
#DEFINE PDTE_VALID		"1" // Pendente Validação
#DEFINE VALIDO			"2" // Valido
#DEFINE INVALIDO		"3" // Inválido
#DEFINE APTRANS			"Microsiga Protheus"
#DEFINE HASHDIOPS		"hashdiops.tmp"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCNXMLDIO

Gera o arquivo XML para o DIOPS
@param cTipo		Tipo da obrigação

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLXMLDIOPS(cTipo, lAuto)
	Local cTexto		:= ""
	Local cDirDIOPS    	:= ""
	Local lOk			:= .T.
	Local lB8K_PLACC 	:= B8K->(FieldPos("B8K_PLACC") > 0)

	Private nArqHash	:= 0
	Private cArqLog 	:= "PLSDIOPS_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" // Nome do arquivo de log da execucao
	Private lDiopsSmp := .F.

	Default lAuto 		:= .F.
	Default cTipo 		:= ""

	If cTipo="3" //DIOPS
		If Pergunte("PDIOPSXML",.T.)

			iF lAuto
				LDIOPSSMP:=.F.
			EndIF

			lDiopsSmp := iif(!lAuto .aND. MV_PAR03 == 1, .T., .F.)

			//Valido se os XSDs estão na pasta do DIOPS
			if !existDir("\diops")
				nRet := makeDir( "\diops" )
				if nRet != 0
					lOk := .F.
					cTexto := "Não foi possível criar o diretório " + GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()) + "\diops" + " "
					cTexto += Replicate("-",30) + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
				endIf
			endif

			if lOk

				cDirDIOPS := PLSMUDSIS("\diops")

				cArq := ""

				If !lDiopsSmp
					aArqSch := directory(cDirDIOPS + PLSMUDSIS("\Diops") + IIf(B3D->B3D_ANO == "2020", "2019", B3D->B3D_ANO) + ".xsd")
				Else 	
					aArqSch := directory(cDirDIOPS + PLSMUDSIS("\Diops") + IIf(B3D->B3D_ANO == "2024", "2024", B3D->B3D_ANO) + "_Mensal.xsd")
				Endif

				If Len(aArqSch) == 0
					If !lDiopsSmp
						cArq := "Diops" + IIf(B3D->B3D_ANO == "2020", "2019", B3D->B3D_ANO) + ".xsd"
					Else 
						cArq := "Diops" + IIf(B3D->B3D_ANO == "2024", "2024", B3D->B3D_ANO) + "_Mensal.xsd"
					EndIf
				EndIf

				If !Empty(cArq)
					cTexto += "O arquivo "+ cDirDIOPS +PLSMUDSIS("\") + cArq + " não foi encontrado no servidor." + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
					if !lAuto
						LogGerArq(cTexto)
					EndIf
				EndIf

				If Empty(cArq) .OR. lAuto
					//Organiza o XML para envio.
					if lHabMetric .and. lLibSupFw .and. lVrsAppSw
						FWMetrics():addMetrics("Gera Arquivo de Envio - DIOPS", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
					endif

					if lAuto
						Processa( {||MontaXml(lAuto) } , "Processando" , "Aguarde geração do XML DIOPS" , .F. )
					Else

						Processa( {||MontaXml() } , "Processando" , "Aguarde geração do XML DIOPS" , .F. )
					EndIf
				EndIf
			Else
				if !lAuto
					LogGerArq(cTexto)
				EndIf
			EndIf
		EndIf
	Else

		Alert("Operação não disponível para este tipo de obrigação.")

	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaXml

Monta as mensagens do DIOPS XML

@param cSequen Sequencial do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaXml(lAuto)

	Local cMsg		:= "" // Mensagem a ser apresentada no log e ao termino do processamento
	Local nRegua	:= 0 // tamanho da regua
	Local lCriaLog  := .F. // Gerar aquivo log
	Private cDir    := "" // Diretorio
	Default lAuto	:= .F.

	cDir     	:= AllTrim(mv_par01)

	If lAuto
		lCriaLog := .T.
	Else
		lCriaLog 	:= If(mv_par02 == 1,.T.,.F.)
	EndIf

	If lCriaLog // Cabecalho do log
		cMsg := "Geração do arquivo do DIOPS - Início: " + Dtos(dDatabase) + " " + Time() + CRLF
		cMsg += "Parâmetros informados para processamento: " + CRLF

		cMsg += "Diretório: " + cDir + CRLF
		cMsg += "Gera arquivo log: " + If(lCrialog,"Sim","Não") + CRLF
		PlsLogFil(cMsg,cArqLog)
	EndIf

	If CriaArqTmp()

		nRegua := 4 //Nº de incproc que tem no fonte
		ProcRegua(nRegua)

		IncProc("Gerando cabeçalho...")
		PrintCab()

		IncProc("Gerando dados do corpo do arquivo...")
		PrintBody(lAuto)

		IncProc("Gerando fim do arquivo...")
		PrintFooter()

		IncProc("Gravando arquivo a ser enviado ...")
		EscreveArq()

		MsgAlert("Geração do XML Financeiro concluída","Informativo")

	Else
		MsgAlert("Não foi possível criar o arquivo temporário. XML não gerado","Erro")
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaArqTmp
Monta o cabeçalho do XML

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaArqTmp()

	Local cXmlTempFile	:= Alltrim(cDir)+"diopsbuffer.xml"
	Local nArqTmp := FCreate(cXmlTempFile,0,,.F.) // criacao do arquivo

	FClose(nArqTmp)
Return nArqTmp > 0
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintCab
Monta o cabeçalho do XML

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrintCab()
	Local cCabXml	:= ''
	Local cCnpj := ''
	Local cMesDiops := MV_PAR04

	nArqHash := FCreate(HASHDIOPS,0,,.F.)
	cCNPJ := PLSBCNOPE(B3D->B3D_CODOPE)

	If !lDiopsSmp

		cCabXml += '<diops xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+;
		' xmlns="http://www.ans.gov.br/ws/diops/financeiro/schema"'+;
		' xsi:schemaLocation="http://www.ans.gov.br/padroes/diops/' +;
		IIf(B3D->B3D_ANO == "2020", "2019", B3D->B3D_ANO) + '/schemas/Diops' +;
			IIf(B3D->B3D_ANO == "2020", "2019", B3D->B3D_ANO) + '.xsd"> ' + CRLF

		InsInXMLTemp(cCabXml)
		InsInXMLTemp(MontaTag(2,'identificacao','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(4,'registro',B3D->B3D_CODOPE,.T.,.T.,.F.,.F.) )
		InsInXMLTemp(MontaTag(4,'cnpj',cCNPJ,.T.,.T.,.F.) )
		InsInXMLTemp(MontaTag(4,'ano',B3D->B3D_ANO,.T.,.T.,.F.,.F.) )
		InsInXMLTemp(MontaTag(4,'trimestre',AllTrim(str(val(B3D->B3D_CODIGO))),.T.,.T.,.F.,.F.) )
		InsInXMLTemp(MontaTag(2,'identificacao','',.F.,.T.,.T.) )

	Else 

		cCabXml += '<diops xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+;
		' xmlns="http://www.ans.gov.br/ws/diops/financeiro/schema"'+;
		' xsi:schemaLocation="http://www.ans.gov.br/padroes/diops/' +;
		IIf(B3D->B3D_ANO == "2024", "2024", B3D->B3D_ANO) + '_Mensal/schemas/Diops' +;
			IIf(B3D->B3D_ANO == "2024", "2024", B3D->B3D_ANO) + '_Mensal.xsd"> ' + CRLF

		InsInXMLTemp(cCabXml)
		InsInXMLTemp(MontaTag(2,'identificacao','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(4,'registro',B3D->B3D_CODOPE,.T.,.T.,.F.,.F.) )
		InsInXMLTemp(MontaTag(4,'cnpj',cCNPJ,.T.,.T.,.F.) )
		InsInXMLTemp(MontaTag(4,'ano',B3D->B3D_ANO,.T.,.T.,.F.,.F.) )
		InsInXMLTemp(MontaTag(4,'mes',cMesDiops,.T.,.T.,.F.,.F.) )
		InsInXMLTemp(MontaTag(2,'identificacao','',.F.,.T.,.T.) )

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintBody
Monta o corpo do XML

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrintBody(lAuto)// Gravacao do arquivo SBX
	Local cTipoOpe := RetTipOpe(B3D->B3D_CODOPE) //Recupero o tipo de operadora: 1=padrao;2=cooperativa;3=administradora;
	Local lB8K_PLACC 	:= B8K->(FieldPos("B8K_PLACC") > 0)
	Default lAuto := .F.

	InsInXMLTemp(MontaTag(2,'financeiro xsi:type="'+cTipoOpe+'"','',.T.,.F.,.T.) )

	iF lAuto
		LDIOPSSMP:=.F.
	EndIF

	If lDiopsSmp
		Balancete() //Balancete
		FluxoCaixa() //Fluxo de Caixa
	Else
		//Quadros em comum entre todas as modalidades
		Balancete() //Balancete
		AtivGarant() //Ativos Garantidores
		FluxoCaixa() //Fluxo de Caixa
		IdadeSaldo() //Idade de Saldo
		LucrosPreju() //Lucros e Prejuízos
		
		If cTipoOpe $ "cooperativa;padrao"
			SldProvEvn() //Saldo da Provisão de Eventos Sinistros a Liquidar
			CoberAssis() //Cobertura Assistencial
			If cTipoOpe $ "cooperativa"
				ConCorCoop() //Conta-Corrente Cooperado
				ContaTribu() //Conta Tributo Passivo
			EndIf
			MvtEvntInd() //Movimentação de Eventos Indenizáveis
			MvtAgrCont(lB8K_PLACC) //Movimentação de Agrupamento de Contratos
			MvtFunCom()	//Quadro de Programas-Fundos Comuns de Despesas Assistenciais (2018)
			MvtContCoc()

			If Val(B3D->B3D_ANO) <= 2023
				MvtContPec() //Contraprestações Pecuniárias / Prêmios por Período de Cobertura
			Else 
				If cTipoOpe $ "padrao"  
					MvtContPec() //Contraprestações Pecuniárias / Prêmios por Período de Cobertura
				Endif
			Endif

			MvtTap() // Teste de Adequação do Passivo
			MvtMPCap() //Modelo Padrão de Capital
			//MvtEvtCor() Descontinuado	// Eventos em Corresponsabilidade (2018) DSAUCEN-1840
		EndIf

		If cTipoOpe $ "administradora" .OR. lAuto
			ContraEstip() //Contratos Estipulados
			SegMontCont() //Segregação do Montante de Contraprestações a Repassar
		EndIf
		IF FWAliasInDic("B6X", .F.)
			CreDebOp()
			DetFunInv()
		EndIf

		If (cTipoOpe $ "administradora" .Or. lAuto) .And. FWAliasInDic("B7W", .F.) .And. Val(B3D->B3D_ANO)>=2022
			Inadimple()
		EndIf

		If FWAliasInDic("BVU", .F.)
			CapBasRisco() // Capital Baseado em Risco
		EndIf
	EndIf
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Balancete
Monta a tag do Balancete

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function Balancete()

	InsInXMLTemp(MontaTag(2,'balancete','',.T.,.F.,.T.) )
	TagContas("1","ativo")
	TagContas("2","passivo")
	TagContas("3","receita")
	TagContas("4","despesa")
	//	TagContas("7","conta")
	InsInXMLTemp(MontaTag(2,'balancete','',.F.,.T.,.T.) )

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagContas
Recupera os valores das contas e coloca os registros nas tags

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagContas(cConta,cTag)

	If TemConta(cConta)

		Do While !TRBCON->(Eof())

			InsInXMLTemp(MontaTag(4,cTag,'',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'conta',AllTrim(TRBCON->B8A_CONTA),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'saldoInicial',AllTrim(Str(TRBCON->SALANT)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'debitos',AllTrim(Str(TRBCON->DEBITO)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'creditos',AllTrim(Str(TRBCON->CREDIT)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'saldoFinal',AllTrim(Str(TRBCON->SALFIN)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,cTag,'',.F.,.T.,.T.) )

			TRBCON->(DbSkip())

		EndDo
	EndIf
	TRBCON->(DbCloseArea())

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemConta
Recupera os valores das contas e coloca

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemConta(cConta)
	Local cSql := ""
	Local lRet := .T.
	Local cMesDiops := MV_PAR04
	Local lNaoMesCm := .F.


	lNaoMesCm:= B8A->(fieldpos("B8A_MESCMP")) > 0  .And. PlSDIOCPM(B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,B3D->B3D_CODOPE,'1')

	//B8A_FILIAL+B8A_CODOPE+B8A_CODOBR+B8A_ANOCMP+B8A_CDCOMP+B8A_CONTA
	If !lDiopsSmp .And. B8A->(fieldpos("B8A_MESCMP")) > 0 .And. lNaoMesCm 
		//Retorna o mes ini e fin do trimestre para retorno do salant e salfin
		aMesTri := chkMesTri(B3D->B3D_CODIGO)

		cSql := " SELECT B8A_CONTA, 
		cSql += " ( SELECT B8A_SALANT
		cSql += " 	FROM " + RetSqlName("B8A")
		cSql += " 	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
        cSql += "      AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' "
        cSql += "      AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' "
        cSql += "      AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "
        cSql += "      AND B8A_MESCMP = '" + aMesTri[1] + "' "
		cSql += " 	  AND D_E_L_E_T_ = ''
		cSql += "     AND B8A_CONTA  = B8A.B8A_CONTA
        cSql += " ) AS SALANT ,  
		cSql += "  SUM(B8A_DEBITO) AS DEBITO,  SUM(B8A_CREDIT) AS CREDIT,  
		cSql += " ( SELECT B8A_SALFIN
        cSql += "   FROM " + RetSqlName("B8A")
        cSql += "   WHERE  B8A_FILIAL = '" + xFilial("B8A") + "' " 
        cSql += "      AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' "
        cSql += "      AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' "
        cSql += "      AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "
        cSql += "      AND B8A_MESCMP = '" + aMesTri[2] + "' "
        cSql += "      AND D_E_L_E_T_ = ''
        cSql += "      AND B8A_CONTA  = B8A.B8A_CONTA
        cSql += " ) AS SALFIN FROM " + RetSqlName("B8A") + " B8A "
	Else 
		cSql := " SELECT B8A_CONTA,B8A_SALANT AS SALANT ,B8A_DEBITO AS DEBITO ,B8A_CREDIT AS CREDIT ,B8A_SALFIN AS SALFIN FROM " + RetSqlName("B8A")
	Endif

	cSql += " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
	cSql += " AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8A_CODOPE = '" + B3D->B3D_CODOPE + "' "
		
	If lDiopsSmp .and. B8A->(fieldpos("B8A_MESCMP")) > 0 .And. lNaoMesCm
		cSql += " AND B8A_MESCMP= '" + cMesDiops + "' "
	Endif	

	cSql += " AND B8A_CONTA like '" + cConta + "%' "
	cSql += " AND B8A_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' '"
	
	If !lDiopsSmp 
		If UPPER(FUNNAME()) == 'RPC' .oR. !lNaoMesCm
			cSql += " GROUP BY B8A_CONTA,B8A_SALANT ,B8A_DEBITO ,B8A_CREDIT ,B8A_SALFIN  "
		Else 
			cSql += " GROUP BY B8A_CONTA "
		EndIf 
	Endif

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)
	
	lRet := !TRBCON->(Eof())

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtivGarant
Monta a tag do AtivGarant

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtivGarant()
	InsInXMLTemp(MontaTag(2,'ativoGarantidor','',.T.,.F.,.T.) )
	TagAtivoImob()
	InsInXMLTemp(MontaTag(2,'ativoGarantidor','',.F.,.T.,.T.) )

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagAtivoImob
Monta a tag do TagAtivoImob

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagAtivoImob()

	If TemImob()

		Do While !TRBIMO->(Eof())

			InsInXMLTemp(MontaTag(4,'ativoImobiliario','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'rgi',AllTrim(TRBIMO->B8C_CODRGI),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'redePropria',IIf(TRBIMO->B8C_REDPRO=="1",'true','false'),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'assistencial',IIf(TRBIMO->B8C_ASSIST=="1",'true','false'),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorContabil',AllTrim(Str(TRBIMO->B8C_VLRCON)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,'ativoImobiliario','',.F.,.T.,.T.) )

			TRBIMO->(DbSkip())

		EndDo
	EndIf
	TRBIMO->(DbCloseArea())
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemConta
Recupera os valores das contas e coloca

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemImob()
	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B8C_CODOPE,B8C_CODRGI,B8C_REDPRO,B8C_ASSIST,B8C_VLRCON, "
	cSql += " B8C_VIGINI,B8C_VIGFIN "
	cSql += " FROM " + RetSqlName("B8C")
	cSql += " WHERE B8C_FILIAL = '" + xFilial("B8C") + "' "
	cSql += " AND B8C_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8C_VIGINI <= '" + DataTrimestre(B3D->B3D_ANO, val(B3D->B3D_CODIGO),"2") + "' "
	cSql += " AND (B8C_VIGFIN = '' OR B8C_VIGFIN >= '" + DataTrimestre(B3D->B3D_ANO, val(B3D->B3D_CODIGO),"1") + "') "
	cSql += " AND B8C_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBIMO",.F.,.T.)

	lRet := !TRBIMO->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaData
Ajusta a data para o formato do XML

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function AjustaData(cData)
Return cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FluxoCaixa
Monta a tag do FluxoCaixa

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function FluxoCaixa()
	If TemFlxCaixa()

		InsInXMLTemp(MontaTag(2,'fluxoCaixa','',.T.,.F.,.T.) )

		Do While !TRBFLX->(Eof())

			InsInXMLTemp(MontaTag(4,'lancamento','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'conta',AllTrim(TRBFLX->B8H_CODIGO),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(ABS(TRBFLX->VLRCON))),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,'lancamento','',.F.,.T.,.T.) )
			TRBFLX->(DbSkip())

		EndDo
		InsInXMLTemp(MontaTag(2,'fluxoCaixa','',.F.,.T.,.T.) )

	EndIf
	TRBFLX->(DbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdadeSaldo
Monta a tag do IdadeSaldo

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IdadeSaldo()

	InsInXMLTemp(MontaTag(2,'idadeSaldo','',.T.,.F.,.T.) )

	TemPassivos()
	TemAtivos()

	InsInXMLTemp(MontaTag(2,'idadeSaldo','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LucrosPreju
Monta a tag do <lucrosPrejuizos>

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function LucrosPreju()

	InsInXMLTemp(MontaTag(2,'lucrosPrejuizos','',.T.,.F.,.T.) )
	TagLcrPMvt()
	InsInXMLTemp(MontaTag(2,'lucrosPrejuizos','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagLcrPMvt
Monta a tag do <movimentacao>

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagLcrPMvt()

	If TemLcrPreju()

		Do While !TRBLCR->(Eof())

			InsInXMLTemp(MontaTag(4,'movimentacao','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'conta',AllTrim(TRBLCR->B8E_DESCRI),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(ABS(TRBLCR->B8E_VLRCON))),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,'movimentacao','',.F.,.T.,.T.) )
			TRBLCR->(DbSkip())

		EndDo

	EndIf
	TRBLCR->(DbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemLcrPreju
Recupera os valores de lucros e prejuízos

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemLcrPreju()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B8E_DESCRI,B8E_VLRCON "
	cSql += " FROM " + RetSqlName("B8E")
	cSql += " WHERE B8E_FILIAL = '" + xFilial("B8E") + "' "
	cSql += " AND B8E_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8E_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8E_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8E_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8E_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBLCR",.F.,.T.)

	lRet := !TRBLCR->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SldProvEvn
Monta a tag do SldProvEvn

@author Roger C
@since 12/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SldProvEvn()
	Local lGdePorte	:= .F.
	Local nMaxBen	:= IIf(B3D->B3D_ANO<'2018',100000,20000)
	Local lNew22	:= Val(B3D->B3D_ANO) >= 2022

	If TemIntPESL()

		If !lNew22
			lGdePorte	:= ( TRBPES->B8J_QTDE > nMaxBen )
			InsInXMLTemp(MontaTag(2,'saldoProvEventosSinistrosLiq grandePorte="'+IIf(lGdePorte,'true','false')+'"','',.T.,.F.,.T.) )

		Else
			InsInXMLTemp(MontaTag(2,'saldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )

		EndIf

		Do While !TRBPES->(Eof())
			If !lNew22
				InsInXMLTemp(MontaTag(6,'eventosSinistrosAte',AllTrim(Str(TRBPES->B8J_EVULTI)),.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(6,'eventosSinistrosPos',AllTrim(Str(TRBPES->B8J_EVMAIS)),.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(6,'eventosSinistrosCorrespAte',AllTrim(Str(TRBPES->B8J_CAULTI)),.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(6,'eventosSinistrosCorrespPos',AllTrim(Str(TRBPES->B8J_CAMAIS)),.T.,.T.,.T.) )
			Else

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVA",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PSUS",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_UMMSUS)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVA",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PCPO",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_UMCARP)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVA",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PCAO",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_UMCOAS)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVE",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PSUS",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_DOMSUS)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVE",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PCPO",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_DOCARP)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVE",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PCAO",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_DOCOAS)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVP",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PSUS",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_TRMSUS)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVP",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PCPO",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_TRCARP)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(6,'contrato',IIF(AllTrim(TRBPES->B8J_TIPOES)="1","PRE","POS"),.T.,.T.,.T.) ) //pre OU POS
				InsInXMLTemp(MontaTag(6,'aviso',"EVP",.T.,.T.,.T.) )                    //EVA EVE EVP Eventos/Sinistros avisados há mais de 60 dias
				InsInXMLTemp(MontaTag(6,'atendimento',"PCAO",.T.,.T.,.T.) )              //PSUS PCPO PCAO
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(TRBPES->B8J_TRCOAS)),.T.,.T.,.T.) )                    //VALOR
				InsInXMLTemp(MontaTag(2,'lancSaldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

			EndIf
			TRBPES->(DbSkip())
		EndDo

		InsInXMLTemp(MontaTag(2,'saldoProvEventosSinistrosLiq','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'saldoProvEventosSinistrosLiq','',.T.,.T.,.T.) )

	EndIf
	TRBPES->(DbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CoberAssis
Monta a tag do CoberAssis

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function CoberAssis()
	Local nVez		:= 0
	Local nValor	:= 0
	Local cPlano	:= ''
	Local nQtdOrig	:= IIf( B3D->B3D_ANO>='2018', 5, 4 )

	If TemCobAssis()

		InsInXMLTemp(MontaTag(2,'coberturaAssistencial','',.T.,.F.,.T.) )

		Do While !TRBCOA->(Eof())

			cPlano := AllTrim(TRBCOA->B8I_PLANO)

			// Processa seis campos de cada registro - NAO MUDAR NUMERACAO, É USADA DESSA FORMA NO XML
			For nVez := 0 to nQtdOrig

				Do Case
					Case nVez == 0	// Consulta
						nValor	:= TRBCOA->B8I_CONSUL
					Case nVez == 1	// Exames
						nValor	:= TRBCOA->B8I_EXAMES
					Case nVez == 2	// Terapias
						nValor	:= TRBCOA->B8I_TERAPI
					Case nVez == 3	// Internações
						nValor	:= TRBCOA->B8I_INTERN
					Case nVez == 4	// Outros Atendimentos
						nValor	:= TRBCOA->B8I_OUTROS
					Case nVez == 5	// Demais Despesas
						nValor	:= TRBCOA->B8I_DEMAIS
				EndCase

				// Se valor negativo ou nulo, pula campo
				If nValor <= 0
					Loop
				EndIf

				InsInXMLTemp(MontaTag(4,'lancCoberturaAssistencial','',.T.,.F.,.T.) )

				InsInXMLTemp(MontaTag(6,'plano',cPlano,.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(6,'procedimento',AllTrim(Str(nVez)),.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(6,'origem',AllTrim(TRBCOA->B8I_ORIGEM),.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(6,'valor',AllTrim(Str(nValor)),.T.,.T.,.T.) )

				InsInXMLTemp(MontaTag(4,'lancCoberturaAssistencial','',.F.,.T.,.T.) )

			Next

			TRBCOA->(DbSkip())

		EndDo

		InsInXMLTemp(MontaTag(2,'coberturaAssistencial','',.F.,.T.,.T.) )

		// ANS não aceita se não tiver o tag 'coberturaAssistencial'
	EndIf

	TRBCOA->(DbCloseArea())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtAgrCont
Monta a tag do Movimento de Agrupamento de Contratos

@author Roger C
@since 11/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtAgrCont(lB8K_PLACC)

	Local aRet := {0,0,0,0,0,0,0,0}

	if lB8K_PLACC
		aRet := {0,0,0,0,0,0,0,0,0,0,0,0}
	EndIf

	If TemMovAgCn(lB8K_PLACC)

		Do While !TRBAGC->(Eof())

			If TRBAGC->B8K_TIPO == '1'				// Agregados

				//Plano Coletivo por Adesão
				aRet[1]	:= TRBAGC->B8K_PLACE 		// Contraprestacao Emitida
				if lB8K_PLACC
					aRet[2] := TRBAGC->B8K_PLACC	// Correspondencia Cedida
				EndIf
				aRet[3]	:= TRBAGC->B8K_PLAEV		// Eventos a Liquidar

				//Plano Coletivo Empresarial
				aRet[4]	:= TRBAGC->B8K_PCECE		// Contraprestação Emitida
				if lB8K_PLACC
					aRet[5] := TRBAGC->B8K_PCECC	// Correspondencia Cedida
				EndIf
				aRet[6]	:= TRBAGC->B8K_PCEEV		// Eventos a Liquidar
			Else									// Demais Contratos

				//Plano Coletivo por Adesão
				aRet[7]	:= TRBAGC->B8K_PLACE		// Contraprestacao Emitida
				if lB8K_PLACC
					aRet[8] := TRBAGC->B8K_PLACC	// Correspondencia Cedida
				EndIf
				aRet[9]	:= TRBAGC->B8K_PLAEV		// Eventos a Liquidar

				//Plano Coletivo Empresarial
				aRet[10] := TRBAGC->B8K_PCECE		// Contraprestação Emitida
				if lB8K_PLACC
					aRet[11] := TRBAGC->B8K_PCECC	// Correspondencia Cedida
				EndIf
				aRet[12] := TRBAGC->B8K_PCEEV		// Eventos a Liquidar

			EndIf
			TRBAGC->(dbSkip())
		EndDo

		InsInXMLTemp(MontaTag(2,'agrupamentoContratos','',.T.,.F.,.T.) )

		// Coletivo por Adesão - Agregados
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'plano','PLA',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','80',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'contraEmitida',AllTrim(Str(aRet[1])),.T.,.T.,.T.) )
		If lB8K_PLACC
			InsInXMLTemp(MontaTag(6,'correspCedida',AllTrim(Str(aRet[2])),.T.,.T.,.T.) )
		EndIf
		InsInXMLTemp(MontaTag(6,'eventosConhecidos',AllTrim(Str(aRet[3])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.F.,.T.,.T.) )

		// Coletivo por Adesão - Demais Contratos
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'plano','PLA',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','81',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'contraEmitida',AllTrim(Str(aRet[7])),.T.,.T.,.T.) )
		If lB8K_PLACC
			InsInXMLTemp(MontaTag(6,'correspCedida',AllTrim(Str(aRet[8])),.T.,.T.,.T.) )
		EndIf
		InsInXMLTemp(MontaTag(6,'eventosConhecidos',AllTrim(Str(aRet[9])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.F.,.T.,.T.) )

		// Coletivo Empresarial - Agregados
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'plano','PCE',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','80',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'contraEmitida',AllTrim(Str(aRet[4])),.T.,.T.,.T.) )
		If lB8K_PLACC
			InsInXMLTemp(MontaTag(6,'correspCedida',AllTrim(Str(aRet[5])),.T.,.T.,.T.) )
		EndIf
		InsInXMLTemp(MontaTag(6,'eventosConhecidos',AllTrim(Str(aRet[6])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.F.,.T.,.T.) )

		// Coletivo Empresarial - Demais Contratos
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'plano','PCE',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','81',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'contraEmitida',AllTrim(Str(aRet[10])),.T.,.T.,.T.) )
		If lB8K_PLACC
			InsInXMLTemp(MontaTag(6,'correspCedida',AllTrim(Str(aRet[11])),.T.,.T.,.T.) )
		EndIf
		InsInXMLTemp(MontaTag(6,'eventosConhecidos',AllTrim(Str(aRet[12])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4,'lancAgrupamentoContratos','',.F.,.T.,.T.) )
		InsInXMLTemp(MontaTag(2,'agrupamentoContratos','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'agrupamentoContratos','',.T.,.T.,.T.) )
	EndIf

	TRBAGC->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtEvtCor
Monta a tag do Movimento de Eventos Corresponsabilidade

@author Roger C
@since 28/03/2018
/*/
//--------------------------------------------------------------------------------------------------
/*
Descontinuado DSAUCEN-1840

Static Function MvtEvtCor()
	Local aRet	:= {0,0,0,0}

	If TemMovEvCo()
		Do While !TRBEVC->(Eof())
			// Há um único registro por competência
			aRet[1]	:= TRBEVC->B5R_EVEOPE
			aRet[2]	:= TRBEVC->B5R_OUTOPE
			aRet[3]	:= TRBEVC->B5R_EVECOA
			aRet[4]	:= TRBEVC->B5R_OUTCOA
			TRBEVC->(dbSkip())
		EndDo

		InsInXMLTemp(MontaTag(2,'eventoCorresponsabilidade','',.T.,.F.,.T.) )

		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','82',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasEventos',AllTrim(Str(aRet[1])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasOutros',AllTrim(Str(aRet[2])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.F.,.T.,.T.) )

		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','83',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasEventos',AllTrim(Str(aRet[3])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasOutros',AllTrim(Str(aRet[4])),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.F.,.T.,.T.) )

		InsInXMLTemp(MontaTag(2,'eventoCorresponsabilidade','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'eventoCorresponsabilidade','',.T.,.F.,.T.) )

		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','82',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasEventos',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasOutros',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.F.,.T.,.T.) )

		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.T.,.F.,.T.) )
		InsInXMLTemp(MontaTag(6,'movimentacao','83',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasEventos',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'despesasOutros',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(4, 'lancEventoCorresponsabilidade','',.F.,.T.,.T.) )

		InsInXMLTemp(MontaTag(2,'eventoCorresponsabilidade','',.F.,.T.,.T.) )

	EndIf

	TRBEVC->(dbCloseArea())

Return

*/



//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtFunCom
Monta a tag do Movimento de Fundos Comuns

@author Roger C
@since 28/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtFunCom()
	Local aRet	:= {0,0,0,0}
	// B6R_TIPO, B6R_CNPJ, B6R_NOME, B6R_SLDCRD, B6R_SLDDEB
	If TemMovFuCo()

		InsInXMLTemp(MontaTag(2,'fundosComuns','',.T.,.F.,.T.) )

		Do While !TRBFUC->(Eof())

			InsInXMLTemp(MontaTag(4,'lancFundosComuns xsi:type="lancFundosComuns'+IIf(TRBFUC->B6R_TIPO=='FCA','Adm','Part')+'Operadora"','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(6,'partFundo',AllTrim(TRBFUC->B6R_TIPO),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'programaFundo',RetPonto(AllTrim(TRBFUC->B6R_NOME)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'saldoCredor',AllTrim(Str(TRBFUC->B6R_SLDCRD)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'saldoDevedor',AllTrim(Str(TRBFUC->B6R_SLDDEB)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,IIf(TRBFUC->B6R_TIPO=='FCA','registroAns','regANSCnpj'),IIf(TRBFUC->B6R_TIPO=='FCA',AllTrim(TRBFUC->B6R_OPEPAR),PLSBCNOPE(AllTrim(TRBFUC->B6R_OPEADM))),.T.,.T.,.T.) )

			InsInXMLTemp(MontaTag(4,'lancFundosComuns','',.F.,.T.,.T.) )

			TRBFUC->(dbSkip())
		EndDo

		InsInXMLTemp(MontaTag(2,'fundosComuns','',.F.,.T.,.T.) )

		// Não há ELSE, envio não obrigatório, se não houver dados não manda no XML
	EndIf

	TRBFUC->(dbCloseArea())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtMPCap
Monta a tag do Modelo Padrão de Capital

@author lima.everton
@since 24/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtMPCap()

	Local   aRet  := {0,0,0,0}

	If TemMovMPC()

		InsInXMLTemp(MontaTag(2,'modeloPadraoCapital','',.T.,.F.,.T.) )

		Do While !TRBMPC->(Eof())

			InsInXMLTemp(MontaTag(4,'lancModeloPadraoCapital','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'contrapBenefRemissaoTemp',AllTrim(Str(TRBMPC->B82_SMRMTP)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'contrapBenefRemissaoVital',AllTrim(Str(TRBMPC->B82_SMRMVI)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'benefRemissaoTemp',AllTrim(Str(TRBMPC->B82_NMRMTP)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'benefRemissaoVital',AllTrim(Str(TRBMPC->B82_NMRMVI)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'despBenefRemissaoTemp',AllTrim(Str(TRBMPC->B82_SMDETP)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'despBenefRemissaoVital',AllTrim(Str(TRBMPC->B82_SMDEVI)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,'lancModeloPadraoCapital','',.F.,.T.,.T.) )
			TRBMPC->(dbSkip())

		EndDo
		InsInXMLTemp(MontaTag(2,'modeloPadraoCapital','',.F.,.T.,.T.) )
	EndIf

	TRBMPC->(dbCloseArea())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtTap
Monta a tag do Modelo Padrão de Capital

@author lima.everton
@since 24/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtTap()

	Local aRet	:= {0,0,0,0}

	If TemMovTAP()

		InsInXMLTemp(MontaTag(2,'testeAdequacaoPassivo','',.T.,.F.,.T.) )

		Do While !TRBTAP->(Eof())

			InsInXMLTemp(MontaTag(4,'lancTesteAdequacaoPassivo ','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(6,'tipoAgregacaoContratos',TRBTAP->B89_TIPPLA,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'ajusteTabuaBiometrica',TRBTAP->B89_AJUTAB,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'percentTxCancContratos',AllTrim(Str(TRBTAP->B89_TXCANC)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'percentInflacaoMedica',AllTrim(Str(TRBTAP->B89_INFMED)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'percentReajPlanoInd',AllTrim(Str(TRBTAP->B89_REAMAX)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'percentReajPlanoCol',AllTrim(Str(TRBTAP->B89_REACUS)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'utilizacaoFaixaEtaria',TRBTAP->B89_FAIETA,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'metodoInterpolacao',TRBTAP->B89_METINT,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorEstFluxoCaixa',AllTrim(Str(TRBTAP->B89_ESTFLX)),.T.,.T.,.T.) )

			InsInXMLTemp(MontaTag(4, 'lancTesteAdequacaoPassivo','',.F.,.T.,.T.) )

			TRBTAP->(dbSkip())
		EndDo

		InsInXMLTemp(MontaTag(2,'testeAdequacaoPassivo','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'testeAdequacaoPassivo','',.T.,.F.,.T.) )

		InsInXMLTemp(MontaTag(4, 'lancTesteAdequacaoPassivo','',.T.,.F.,.T.) )

		InsInXMLTemp(MontaTag(6,'tipoAgregacaoContratos','',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'ajusteTabuaBiometrica','',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'percentTxCancContratos',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'percentInflacaoMedica',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'percentReajPlanoInd',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'percentReajPlanoCol',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'utilizacaoFaixaEtaria',AllTrim(Str(0)),.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'metodoInterpolacao','',.T.,.T.,.T.) )
		InsInXMLTemp(MontaTag(6,'valorEstFluxoCaixa',AllTrim(Str(0)),.T.,.T.,.T.) )

		InsInXMLTemp(MontaTag(4, 'lancTesteAdequacaoPassivo','',.F.,.T.,.T.) )

		InsInXMLTemp(MontaTag(2,'testeAdequacaoPassivo','',.F.,.T.,.T.) )
	EndIf

	TRBTAP->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtEvntInd
Monta a tag da Movimentação de Eventos Indenizáveis

@author RogerC
@since 04/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtEvntInd()
	Local nMes	:= 0

	If TemMovEvIn()

		InsInXMLTemp(MontaTag(2,'eventosIndenizaveis','',.T.,.F.,.T.) )

		cAno	:= B3D->B3D_ANO
		cMes 	:= IIf(B3D->B3D_CODIGO=='001', '1', IIf(B3D->B3D_CODIGO=='002', '4', IIf(B3D->B3D_CODIGO=='003', '7', '10' ) ) )

		// Fará um loop 3 vezes para gravar separadamente cada mes
		For nMes := 1 to 3

			InsInXMLTemp(MontaTag(4,'lancEventosIndenizaveis','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(6,'mes',cAno+'-'+StrZero(Val(cMes),2,0),.T.,.T.,.T.) )

			TRBEVI->(dbGoTop())
			Do While !TRBEVI->(Eof())

				InsInXMLTemp(MontaTag(8,'prePagamento','',.T.,.F.,.T.) )

				InsInXMLTemp(MontaTag(10,'movimentacao',TRBEVI->B8L_CODIGO,.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(10,'valor',AllTrim(Str(&( 'TRBEVI->B8L_VLMES'+StrZero(nMes,1,0) ))),.T.,.T.,.T.) )

				InsInXMLTemp(MontaTag(8,'prePagamento','',.F.,.T.,.T.) )

				TRBEVI->(DbSkip())

			EndDo

			InsInXMLTemp(MontaTag(4,'lancEventosIndenizaveis','',.F.,.T.,.T.) )

			cMes := Soma1(cMes)

		Next

		InsInXMLTemp(MontaTag(2,'eventosIndenizaveis','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'eventosIndenizaveis','',.T.,.T.,.T.) )
	EndIf

	TRBEVI->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtContCoc
Monta a tag da Movimentação de Contraprestação de Corresponsabilidade Cedida

@author Jose Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtContCoc()
	Local nMes	:= 0

	If TemMovCCC()

		InsInXMLTemp(MontaTag(2,'corresponsabilidadeCedida','',.T.,.F.,.T.) )

		cAno	:= B3D->B3D_ANO
		cMes 	:= IIf(B3D->B3D_CODIGO=='001', '1', IIf(B3D->B3D_CODIGO=='002', '4', IIf(B3D->B3D_CODIGO=='003', '7', '10' ) ) )

		// Fará um loop 3 vezes para gravar separadamente cada mes
		For nMes := 1 to 3

			InsInXMLTemp(MontaTag(4,'lancCorresponsabilidadeCedida','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(6,'mes',cAno+'-'+StrZero(Val(cMes),2,0),.T.,.T.,.T.) )

			TRBMCC->(dbGoTop())
			Do While !TRBMCC->(Eof())

				InsInXMLTemp(MontaTag(8,'prePagamento','',.T.,.F.,.T.) )

				InsInXMLTemp(MontaTag(10,'movimentacao',TRBMCC->B36_CODIGO,.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(10,'valor',AllTrim(Str(&( 'TRBMCC->B36_VLMES'+StrZero(nMes,1,0) ))),.T.,.T.,.T.) )

				InsInXMLTemp(MontaTag(8,'prePagamento','',.F.,.T.,.T.) )

				TRBMCC->(DbSkip())

			EndDo

			InsInXMLTemp(MontaTag(4,'lancCorresponsabilidadeCedida','',.F.,.T.,.T.) )

			cMes := Soma1(cMes)

		Next

		InsInXMLTemp(MontaTag(2,'corresponsabilidadeCedida','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'corresponsabilidadeCedida','',.T.,.T.,.T.) )
	EndIf

	TRBMCC->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContraEstip
Monta a tag do ContraEstip

@author Roger C
@since 28/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ContraEstip()
	Local lNew:= BUP->(fieldpos("BUP_CONREP")) > 0 .And. Val(B3D->B3D_ANO)>=2022

	If TemMovCoEs(lNew)

		InsInXMLTemp(MontaTag(2,'contratosEstipulados','',.T.,.F.,.T.) )

		TRBCOE->(dbGoTop())
		Do While !TRBCOE->(Eof())
			InsInXMLTemp(MontaTag(4,'contrato','',.T.,.F.,.T.) )
			If lNew
				InsInXMLTemp(MontaTag(8,'tipoContrato',IIF(TRBCOE->BUP_CONESP=="1","CES","CNE"),.T.,.T.,.T.) )
			EndIf
			InsInXMLTemp(MontaTag(8,'operadora',TRBCOE->BUP_OPECOE,.T.,.T.,.T.) )
			If lNew
				InsInXMLTemp(MontaTag(8,'quantidadeVidas',CVALTOCHAR(TRBCOE->BUP_QTDVIA),.T.,.T.,.T.) )
			EndIf
			InsInXMLTemp(MontaTag(8,'valor',AllTrim(Str(&(IIF(lNew,'TRBCOE->BUP_CONREP','TRBCOE->BUP_VLRFAT')))),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,'contrato','',.F.,.T.,.T.) )

			TRBCOE->(DbSkip())

		EndDo

		InsInXMLTemp(MontaTag(2,'contratosEstipulados','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'contratosEstipulados','',.T.,.T.,.T.) )
	EndIf

	TRBCOE->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SegMontCont
Monta a tag do SegMontCont

@author Roger C
@since 08/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function SegMontCont()
	Local nMes	:= 0

	If TemMovSMCR()

		InsInXMLTemp(MontaTag(2,'contraprestacaoRepassar','',.T.,.F.,.T.) )

		cAno	:= B3D->B3D_ANO
		cMes 	:= IIf(B3D->B3D_CODIGO=='001', '1', IIf(B3D->B3D_CODIGO=='002', '4', IIf(B3D->B3D_CODIGO=='003', '7', '10' ) ) )

		// Fará um loop 3 vezes para gravar separadamente cada mes
		For nMes := 1 to 3

			InsInXMLTemp(MontaTag(4,'segContraprestacaoRepassar','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(6,'mes',cAno+'-'+StrZero(Val(cMes),2,0),.T.,.T.,.T.) )

			TRBMCR->(dbGoTop())
			Do While !TRBMCR->(Eof())

				InsInXMLTemp(MontaTag(8,'lancamento','',.T.,.F.,.T.) )

				InsInXMLTemp(MontaTag(10,'movimentacao',TRBMCR->BVS_CODIGO,.T.,.T.,.T.) )
				InsInXMLTemp(MontaTag(10,'valor',AllTrim(Str(&( 'TRBMCR->BVS_VLMES'+StrZero(nMes,1,0) ))),.T.,.T.,.T.) )

				InsInXMLTemp(MontaTag(8,'lancamento','',.F.,.T.,.T.) )

				TRBMCR->(DbSkip())

			EndDo

			InsInXMLTemp(MontaTag(4,'segContraprestacaoRepassar','',.F.,.T.,.T.) )

			cMes := Soma1(cMes)

		Next

		InsInXMLTemp(MontaTag(2,'contraprestacaoRepassar','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'contraprestacaoRepassar','',.T.,.T.,.T.) )
	EndIf

	TRBMCR->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContaTribu
Monta a tag do ContaTribu

@author timoteo.bega
@since 02/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ContaTribu()

	If TemTriPas()

		InsInXMLTemp(MontaTag(2,'tributoPassivo','',.T.,.F.,.T.) )

		Do While !TRBCTP->(Eof())

			InsInXMLTemp(MontaTag(4,'lancTributoPassivo','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(6,'codigo',TRBCTP->BUY_CONTA,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'dataCompetencia',AllTrim(AjustaData(TRBCTP->BUY_DTCOMP)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorInicial',AllTrim(Str(TRBCTP->BUY_VLRINI)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorPago',AllTrim(Str(TRBCTP->BUY_VLRPAG)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorAtualMone',AllTrim(Str(TRBCTP->BUY_ATUMON)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorSaldoFinal',AllTrim(Str(TRBCTP->BUY_SLDFIN)),.T.,.T.,.T.) )

			InsInXMLTemp(MontaTag(4,'lancTributoPassivo','',.F.,.T.,.T.) )

			TRBCTP->(dbSkip())

		EndDo

		InsInXMLTemp(MontaTag(2,'tributoPassivo','',.F.,.T.,.T.) )

	EndIf

	TRBCTP->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintFooter
Monta o fim do XML

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrintFooter()

	//Epilogo()

	InsInXMLTemp(MontaTag(2,'financeiro','',.F.,.T.,.T.) )
	InsInXMLTemp(MontaTag(0,'diops','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsInXMLTemp
Monta o fim do XML

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function InsInXMLTemp(cXMLText)

	Local nFile			:=	0
	Local cBuffer 		:= Space(F_BLOCK)
	Local cDir 			:= IIf(alltrim(MV_PAR01)=="","C:\",alltrim(MV_PAR01))
	Local cXmlTempFile	:= Alltrim(cDir)+"diopsbuffer.xml"

	nFile := FOpen(cXmlTempFile,FO_READWRITE + FO_SHARED)
	If nFile > 0
		FSeek(nFile, 0, FS_END) //Posiciona no fim do arquivo
		FWrite(nFile,cXmlText )
	EndIf
	FClose(nFile)

Return cXmlTempFile

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EscreveArq
Monta o fim do XML

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function EscreveArq()

	Local cDir 			:= IIf(alltrim(MV_PAR01)=="","C:\",alltrim(MV_PAR01))
	Local cNamArq 		:= cDir + B3D->B3D_CODOPE + Dtos(dDataBase) + Replace(Time(),":","") + ".XML" // Nome do arquivo de envio do DIOPS a ser gerado
	Local cBuffer 		:= Space(F_BLOCK)
	Local cXmlVld 		:= ""
	Local cError 		:= ""
	Local cWarning 		:= ""
	Local cXmlTempFile	:= Alltrim(cDir)+"diopsbuffer.xml"
	local cXSD			:= "\diops\Diops"+B3D->B3D_ANO+".xsd"
	Local nArqDiops 	:= FCreate(cNamArq,0,,.F.) // criacao do arquivo

	If nArqDiops > 0

		lFinal := .F. // Vou apendar o arquivo temporario no arquivo SBX
		nTmpXml := FOpen(cXmlTempFile,FO_READWRITE + FO_SHARED)
		If nTmpXml > 0
			Do While !lFinal
				nBytes := FRead(nTmpXml, @cBuffer, F_BLOCK)
				cXmlVld += cBuffer
				If FWrite(nArqDiops,cBuffer,nBytes) < nBytes
					lFinal := .T.
				Else
					lFinal := (nBytes == 0)
				EndIf
			EndDo
			FClose(nTmpXml)
			FErase(cXmlTempFile)
		EndIf

		FClose(nArqDiops)

		If !XmlSVldSch(cXmlVld,cXSD, @cError, @cWarning )

			cTexto := "Log da validação com o Schema da ANS "+CHR(13)+CHR(10)
			cTexto += "Erros: "+CHR(13)+CHR(10) + cError +CHR(13)+CHR(10)
			cTexto += "Avisos: "+CHR(13)+CHR(10) + cWarning

			// Chamada para exibir a tela com os possiveis erros e avisos
			// Comentado por motivos de inconsistencias com o validador indicado no site da ANS.
			//LogGerArq(cTexto)

		EndIf

	Else
		MsgInfo("Não foi possível criar o arquivo " + cDir+cNamArq)
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogGerArq

Monta tela para exibir o log da geração

@param cTexto Texto do Log

@author Everton.Mateus
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function LogGerArq(cTexto)

	Local oDlg
	Local cFile	:= ""
	Local cMask	:= "Arquivos Texto (*.TXT) |*.txt|"

	//__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

	DEFINE FONT oFont NAME "Mono AS" SIZE 8,18

	DEFINE MSDIALOG oDlg TITLE "XML DIOPS." From 3,0 to 340,417 PIXEL

	@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL

	oMemo:bRClicked := {||AllwaysTrue() }

	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga

	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

	ACTIVATE MSDIALOG oDlg CENTER

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaTag
Monta a Tag
@param nSpc     espaco para identar o arquivo
@param cTag     nome da tab
@param cVal     valor da tag
@param lIni     abertura de tag
@param lFin     fechamento de tag
@param lPerNul  permitido nulo na tag
@param lRetPto  retira caracteres especiais

@author Everton.Mateus
@since 11/04/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaTag(nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag)

	Local cRetTag := "" // Tag a ser gravada no arquivo texto
	Default lRetPto := .T.
	Default lEnvTag := .T.

	If !Empty(cVal) .Or. lPerNul

		If lIni // Inicializa a tag ?
			cRetTag += '<' + cTag + '>'
			cRetTag += AllTrim(cVal)
		EndIf

		If lFin // Finaliza a tag ?
			cRetTag += '</' + cTag + '>'
		EndIf

		cRetTag := Space(nSpc) + cRetTag + CRLF // Identa o arquivo

		If nArqHash > 0
			FWrite(nArqHash,AllTrim(cVal))
		EndIf

	EndIf

Return Iif(lEnvTag,cRetTag,"")

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DataTrimestre

Funcao criada para transformar a data em trimestre valido para o SIP

@param cData	Data (AAAAMMDD) que sera transformata em trimestre (AAAAMM) ou AAAAMMDD inicial ou final do trimestre
@param nOpc		Tipo de retorno
					1 - monto o retorno da data AAAAMMDD inicial
					2 - monto o retorno da data AAAAMMDD final
					3 - default - monto o retorno do trimestre AAAAMM

@return cTrimestre	Retorno o trimestre identificado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function DataTrimestre(cAno,nTrimestre,cOpc)

	Local cTrimestre	:= ""
	Local aPeriodos	:= {}
	Local cData		:= DTOS(dDataBase)
	Default cOpc		:= ""// "" - AAAADD, "1" - AAAAMMDD inicial, "2" - AAAAMMDD final
	Default nTrimestre	:= 1

	aAdd(aPeriodos,{"01","02","03"})
	aAdd(aPeriodos,{"04","05","06"})
	aAdd(aPeriodos,{"07","08","09"})
	aAdd(aPeriodos,{"10","11","12"})

	If cOpc == "1"//monto o retorno da data AAAAMMDD inicial

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,1]
		cTrimestre += "01"

	ElseIf cOpc == "2"//monto o retorno da data AAAAMMDD final

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,3]
		If nTrimestre == 1
			If SubStr(cTrimestre,5,2) == "02"
				If Val(SubStr(cTrimestre,1,4)) % 4 == 0
					cTrimestre += "29"
				Else
					cTrimestre += "28"
				EndIf
			Else
				cTrimestre += "31"
			EndIf
		Else
			If SubStr(cTrimestre,5,2) $ "04,06,09,10"
				cTrimestre += "30"
			Else
				cTrimestre += "31"
			EndIf
		EndIf

	Else//monto o retorno do trimestre AAAAMM
		cTrimestre := Substr(cData,1,4)+PADL(Alltrim(Str(nTrimestre)),2,"0")
	EndIf

Return cTrimestre

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemIdaSld

Funcao criada para Verificar se existe dados de idade de saldos a serem enviados

@author timoteo.bega
@since 19/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemIdaSld(nPasAtv)
	Local lRet			:= .F.
	Local cSql			:= ""
	Default nPasAtv	:= 1

	If nPasAtv == 1 //Ativo
		cSql := "SELECT B8F_VENCTO, B8F_EVESUS, B8F_EVENTO, B8F_COMERC, B8F_DEBOPE, B8F_OUDBOP, B8F_TITSEN, B8F_DEPBEN, B8F_SERASS, B8F_AQUCAR, B8F_OUDBPG  FROM " + RetSqlName("B8F") + " WHERE B8F_FILIAL='" + xFilial("B8F") + "' AND B8F_CODOPE='" + B3D->B3D_CODOPE + "' AND B8F_CODOBR='" + B3D->B3D_CDOBRI + "' AND B8F_ANOCMP='" + B3D->B3D_ANO + "' "
		cSql += "AND B8F_CDCOMP='" + B3D->B3D_CODIGO + "' AND B8F_STATUS='" + VALIDO + "' AND D_E_L_E_T_=' '
	Else//Passivo
		// Normativa RN 430 insere novas regras a partir da competencia 2018
		cSql := "SELECT B8G_VENCTO, B8G_INDPRE, B8G_INDPOS, B8G_COLPRE, B8G_COLPOS, B8G_CREADM, B8G_PARBEN, B8G_OUCROP, B8G_CROPPO, B8G_OUCRPL, B8G_OUTCRE FROM " + RetSqlName("B8G") + " WHERE B8G_FILIAL='" + xFilial("B8G") + "' AND B8G_CODOPE='" + B3D->B3D_CODOPE + "' AND B8G_CODOBR='" + B3D->B3D_CDOBRI + "' AND B8G_ANOCMP='" + B3D->B3D_ANO + "' "
		cSql += "AND B8G_CDCOMP='" + B3D->B3D_CODIGO + "' AND B8G_STATUS='" + VALIDO + "' AND D_E_L_E_T_=' '
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBID",.F.,.T.)

	lRet := !TRBID->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemPassivos

Funcao criada para escrever os dados de passivos no xml financeiro

@author timoteo.bega
@since 19/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemPassivos()

	If TemIdaSld(1)

		While !TRBID->(Eof())

			InsInXMLTemp(MontaTag(4,'passivo','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'vencimento',AllTrim(TRBID->B8F_VENCTO),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'eventos',AllTrim(Str(TRBID->B8F_EVENTO)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'comercial',AllTrim(Str(TRBID->B8F_COMERC)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'debOper',AllTrim(Str(TRBID->B8F_DEBOPE)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'outrosDebOper',AllTrim(Str(TRBID->B8F_OUDBOP)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'depBenConSegRec',AllTrim(Str(TRBID->B8F_DEPBEN)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'prestServAS',AllTrim(Str(TRBID->B8F_SERASS)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'depAquisCarre',AllTrim(Str(TRBID->B8F_AQUCAR)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'outrosDebPagar',AllTrim(Str(TRBID->B8F_OUDBPG)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'eventossus',AllTrim(Str(TRBID->B8F_EVESUS)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'titulosencargos',AllTrim(Str(TRBID->B8F_TITSEN)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,'passivo','',.F.,.T.,.T.) )
			TRBID->(dbSkip())

		EndDo

	EndIf

	TRBID->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemAtivos

Funcao criada para escrever os dados de ativos no xml financeiro

@author timoteo.bega
@since 19/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemAtivos()

	If TemIdaSld(2)

		While !TRBID->(Eof())

			cVencto := Iif( TRBID->B8G_VENCTO == "099","999",TRBID->B8G_VENCTO )

			InsInXMLTemp(MontaTag(4,'ativo','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'vencimento',cVencto,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'individualPre',AllTrim(Str(TRBID->B8G_INDPRE)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'individualPos',AllTrim(Str(TRBID->B8G_INDPOS)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'coletivoPre',AllTrim(Str(TRBID->B8G_COLPRE)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'coletivoPos',AllTrim(Str(TRBID->B8G_COLPOS)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'credAdminBenef',AllTrim(Str(TRBID->B8G_CREADM)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'partBenefES',AllTrim(Str(TRBID->B8G_PARBEN)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'credOperPre',AllTrim(Str(TRBID->B8G_OUCROP)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'credOperPos',AllTrim(Str(TRBID->B8G_CROPPO)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'outrosCredComPlano',AllTrim(Str(TRBID->B8G_OUCRPL)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'outrosCredSemPlano',AllTrim(Str(TRBID->B8G_OUTCRE)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(4,'ativo','',.F.,.T.,.T.) )
			TRBID->(dbSkip())

		EndDo

	EndIf

	TRBID->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemFlxCaixa
Recupera os valores do Fluxo de Caixa

@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemFlxCaixa()

	Local cSql := ""
	Local lRet := .T.
	Local cMesDiops := MV_PAR04
	Local lNaoMesCm := .F.

	iF UPPER(FUNNAME()) == 'RPC'
		LDIOPSSMP:=.F.
	EndIF

	lNaoMesCm:= B8H->(fieldpos("B8H_MESCMP")) > 0  .And. PlSDIOCPM(B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,B3D->B3D_CODOPE,'2')

	If !lDiopsSmp
		cSql := " SELECT B8H_CODIGO, SUM(B8H_VLRCON) AS VLRCON "
	Else
		cSql := " SELECT B8H_CODIGO,B8H_VLRCON AS VLRCON "
	EndIf

	cSql += " FROM " + RetSqlName("B8H")
	cSql += " WHERE B8H_FILIAL = '" + xFilial("B8H") + "' "
	cSql += " AND B8H_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8H_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8H_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8H_ANOCMP = '" + B3D->B3D_ANO + "' "
	
	If lDiopsSmp .And. B8H->(fieldpos("B8H_MESCMP")) > 0 .And. lNaoMesCm
		cSql += " AND B8H_MESCMP= '" + cMesDiops + "' "
	Endif	

	cSql += " AND B8H_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B8H_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	
	If !lDiopsSmp
		cSql += " GROUP BY B8H_CODIGO"
	Endif

	cSql += " ORDER BY B8H_CODIGO "
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBFLX",.F.,.T.)

	lRet := !TRBFLX->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemCobAssis
Recupera os valores do Cobertura Assistencial

@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemCobAssis()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B8I_PLANO, B8I_ORIGEM, B8I_CONSUL, B8I_EXAMES, B8I_TERAPI, B8I_INTERN, B8I_OUTROS, B8I_DEMAIS "
	cSql += " FROM " + RetSqlName("B8I")
	cSql += " WHERE B8I_FILIAL = '" + xFilial("B8I") + "' "
	cSql += " AND B8I_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8I_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8I_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8I_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8I_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B8I_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8I_PLANO, B8I_ORIGEM "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOA",.F.,.T.)

	lRet := !TRBCOA->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemIntPESL
Recupera os valores do PESL

@author Roger C
@since 12/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemIntPESL()

	Local cSql := ""
	Local lRet := .T.
	Local lNew22 := Val(B3D->B3D_ANO) >= 2022

	If !lNew22
		cSql := " SELECT B8J_QTDE, B8J_EVULTI, B8J_EVMAIS, B8J_CAULTI, B8J_CAMAIS "
	Else
		cSql := " SELECT B8J_UMMSUS,B8J_UMCARP,B8J_UMCOAS,B8J_DOMSUS,B8J_DOCARP,B8J_DOCOAS,B8J_TRMSUS,B8J_TRCARP,B8J_TRCOAS,B8J_TIPOES "
	EndIf
	cSql += " FROM " + RetSqlName("B8J")
	cSql += " WHERE B8J_FILIAL = '" + xFilial("B8J") + "' "
	cSql += " AND B8J_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8J_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8J_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8J_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8J_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B8J_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	iF lNew22
		cSql += " ORDER BY B8J_TIPOES "
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPES",.F.,.T.)

	iF !lNew22
		TcSetField("TRBPES", "B8J_QTDE",   "N", 16, 0 )
		TcSetField("TRBPES", "B8J_EVULTI", "N", 16, 2 )
		TcSetField("TRBPES", "B8J_EVMAIS", "N", 16, 2 )
		TcSetField("TRBPES", "B8J_CAULTI", "N", 16, 2 )
		TcSetField("TRBPES", "B8J_CAMAIS", "N", 16, 2 )
	EndIf

	lRet := !TRBPES->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovAgCn
Recupera os valores do Movimento de Agrupamento de Contratos

@author Roger C
@since 11/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovAgCn(lB8K_PLACC)

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B8K_TIPO, B8K_PLACE, B8K_PLAEV, B8K_PCECE, B8K_PCEEV "
	if lB8K_PLACC
		cSql += " ,B8K_PLACC, B8K_PCECC "
	EndIf
	cSql += " FROM " + RetSqlName("B8K")
	cSql += " WHERE B8K_FILIAL = '" + xFilial("B8K") + "' "
	cSql += " AND B8K_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8K_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8K_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8K_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8K_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B8K_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8K_TIPO "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBAGC",.F.,.T.)
	TcSetField("TRBAGC", "B8K_PLACE",  "N", 16, 2 )
	TcSetField("TRBAGC", "B8K_PLAEV",  "N", 16, 2 )
	TcSetField("TRBAGC", "B8K_PCECE",  "N", 16, 2 )
	TcSetField("TRBAGC", "B8K_PCEEV",  "N", 16, 2 )
	if lB8K_PLACC
		TcSetField("TRBAGC", "B8K_PLACC",  "N", 16, 2 )
		TcSetField("TRBAGC", "B8K_PCECC",  "N", 16, 2 )
	EndIf

	lRet := !TRBAGC->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovEvCo
Recupera os valores do Movimento de Eventos Corresponsabilidade

@author Roger C
@since 11/12/2017
/*/
//--------------------------------------------------------------------------------------------------
/*

Descontinuado DSAUCEN-1840

Static Function TemMovEvCo()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B5R_EVEOPE, B5R_OUTOPE, B5R_EVECOA, B5R_OUTCOA "
	cSql += " FROM " + RetSqlName("B5R")
	cSql += " WHERE B5R_FILIAL = '" + xFilial("B5R") + "' "
	cSql += " AND B5R_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B5R_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B5R_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B5R_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B5R_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B5R_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B5R_REFERE "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBEVC",.F.,.T.)
	TcSetField("TRBEVC", "B5R_EVEOPE",  "N", 16, 2 )
	TcSetField("TRBEVC", "B5R_OUTOPE",  "N", 16, 2 )
	TcSetField("TRBEVC", "B5R_EVECOA",  "N", 16, 2 )
	TcSetField("TRBEVC", "B5R_OUTCOA",  "N", 16, 2 )

	lRet := !TRBEVC->(Eof())

Return lRet

*/


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovFuCo
Recupera os valores do Fundo Comum

@author Roger C
@since 28/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovFuCo()

	Local cSql := ""
	Local lRet := .T.
	cSql := " SELECT B6R_TIPO, B6R_OPEPAR, B6R_OPEADM, B6R_NOME, B6R_SLDCRD, B6R_SLDDEB "
	cSql += " FROM " + RetSqlName("B6R")
	cSql += " WHERE B6R_FILIAL = '" + xFilial("B6R") + "' "
	cSql += " AND B6R_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B6R_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B6R_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B6R_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B6R_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B6R_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B6R_TIPO, B6R_CNPJ "
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBFUC",.F.,.T.)
	TcSetField("TRBFUC", "B6R_SLDCRD",  "N", 16, 2 )
	TcSetField("TRBFUC", "B6R_SLDDEB",  "N", 16, 2 )
	lRet := !TRBFUC->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovEvIn
Recupera os valores do Movimento de Eventos Indenizáveis

@author RogerC
@since 04/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovEvIn()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B8L_CODIGO, B8L_VLMES1, B8L_VLMES2, B8L_VLMES3 "
	cSql += " FROM " + RetSqlName("B8L")
	cSql += " WHERE B8L_FILIAL = '" + xFilial("B8L") + "' "
	cSql += " AND B8L_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8L_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8L_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B8L_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8L_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B8L_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8L_CODIGO "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBEVI",.F.,.T.)
	TcSetField("TRBEVI", "B8L_VLMES1",  "N", 16, 2 )
	TcSetField("TRBEVI", "B8L_VLMES2",  "N", 16, 2 )
	TcSetField("TRBEVI", "B8L_VLMES3",  "N", 16, 2 )

	lRet := !TRBEVI->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovCCC
Recupera os valores do Movimento de Corresponsabilidade

@author RogerC
@since 04/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovCCC()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B36_CODIGO, B36_VLMES1, B36_VLMES2, B36_VLMES3 "
	cSql += " FROM " + RetSqlName("B36")
	cSql += " WHERE B36_FILIAL = '" + xFilial("B36") + "' "
	cSql += " AND B36_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B36_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B36_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B36_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B36_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B36_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B36_CODIGO "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMCC",.F.,.T.)
	TcSetField("TRBMCC", "B36_VLMES1",  "N", 16, 2 )
	TcSetField("TRBMCC", "B36_VLMES2",  "N", 16, 2 )
	TcSetField("TRBMCC", "B36_VLMES3",  "N", 16, 2 )

	lRet := !TRBMCC->(Eof())

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovCoEs
Recupera os valores de Contratos Estipulados

@author RogerC
@since 28/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovCoEs(lNew)

	Local cSql 	:= ""
	Local lRet 	:= .T.
	Default lNew:= .F.

	If !lNew
		cSql := " SELECT BUP_OPECOE, BUP_VLRFAT "
	Else
		cSql := " SELECT BUP_OPECOE, BUP_QTDVIA, BUP_CONREP, BUP_CONESP "
	EndIf

	cSql += " FROM " + RetSqlName("BUP")
	cSql += " WHERE BUP_FILIAL = '" + xFilial("BUP") + "' "
	cSql += " AND BUP_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BUP_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BUP_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND BUP_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND BUP_REFERE = '" + B3DRefere() + "' "
	cSql += " AND BUP_STATUS = '" + VALIDO + "' "
	If lNew
		cSql += " AND BUP_CONESP <> ' ' "
	EndIf
	cSql += " AND D_E_L_E_T_ = ' ' "

	If lNew
		cSql += " ORDER BY BUP_CONESP, BUP_OPECOE "
	Else
		cSql += " ORDER BY BUP_OPECOE "
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOE",.F.,.T.)
	TcSetField("TRBCOE", "BUP_VLRFAT",  "N", 16, 2 )

	lRet := !TRBCOE->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovSMCR
Recupera os valores da Segregação do Montante de Contraprestações a Repassar

@author RogerC
@since 08/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovSMCR()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT BVS_CODIGO, BVS_VLMES1, BVS_VLMES2, BVS_VLMES3 "
	cSql += " FROM " + RetSqlName("BVS")
	cSql += " WHERE BVS_FILIAL = '" + xFilial("BVS") + "' "
	cSql += " AND BVS_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BVS_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BVS_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND BVS_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND BVS_REFERE = '" + B3DRefere() + "' "
	cSql += " AND BVS_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BVS_CODIGO "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMCR",.F.,.T.)
	TcSetField("TRBMCR", "BVS_VLMES1",  "N", 16, 2 )
	TcSetField("TRBMCR", "BVS_VLMES2",  "N", 16, 2 )
	TcSetField("TRBMCR", "BVS_VLMES3",  "N", 16, 2 )

	lRet := !TRBMCR->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Epilogo

Funcao criada para escrever o epilogo do arquivo xml

@author timoteo.bega
@since 19/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Epilogo()

	InsInXMLTemp( MontaTag(4,'epilogo','',.T.,.F.,.T.) )
	InsInXMLTemp( MontaTag(8,'hash',RetornaHash(),.T.,.T.,.T.) )
	InsInXMLTemp( MontaTag(4,'epilogo','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaHash

Funcao criada para retornar o hash do arquivo

@author timoteo.bega
@since 19/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaHash()
	Local cHash	:= ""

	If nArqHash > 0

		FClose(nArqHash)
		cHash := MD5File(HASHDIOPS)
		FErase(HASHDIOPS)
		nArqHash := 0

	EndIf

Return cHash

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ConCorCoop
Monta a tag do quadro Conta Corrente Cooperado

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ConCorCoop()

	If TemConCor()

		InsInXMLTemp(MontaTag(2,'contaCorrenteCooperado','',.T.,.F.,.T.) )

		Do While !TRBCCC->(Eof())

			InsInXMLTemp(MontaTag(4,'lancContaCorrenteCooperado','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(6,'tipoImposto',TRBCCC->BUW_TIPO,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'nomeImposto',AllTrim(TRBCCC->BUW_DENOMI),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'dataCompetencia',AllTrim(AjustaData(TRBCCC->BUW_DTCOMP)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'dataAdesaoRefis',AllTrim(AjustaData(TRBCCC->BUW_DTREFI)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'qtdeParcelas',AllTrim(Str(TRBCCC->BUW_NUMPAR)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorTotalFinanciado',AllTrim(Str(TRBCCC->BUW_VLRFIN)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorTotalPago',AllTrim(Str(TRBCCC->BUW_VLRPAG)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorSaldoTrim',AllTrim(Str(TRBCCC->BUW_SLDINI)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'qtdeParcelasDevidas',AllTrim(Str(TRBCCC->BUW_QTPAIN)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorPagoTrim',AllTrim(Str(TRBCCC->BUW_VLPGTR)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'qtdeParcelasPagas',AllTrim(Str(TRBCCC->BUW_QTPAPG)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorAtualMone',AllTrim(Str(TRBCCC->BUW_ATUMON)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(6,'valorSaldoFinalTrim',AllTrim(Str(TRBCCC->BUW_SLDFIN)),.T.,.T.,.T.) )

			InsInXMLTemp(MontaTag(4,'lancContaCorrenteCooperado','',.F.,.T.,.T.) )

			TRBCCC->(dbSkip())

		EndDo

		InsInXMLTemp(MontaTag(2,'contaCorrenteCooperado','',.F.,.T.,.T.) )

	EndIf

	TRBCCC->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemConCor
Verifica se existem dados para o quadro conta corrente cooperado

@author timoteo.bega
@since 20/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemConCor()
	Local cSql		:= ""
	Local lRet		:= .T.

	cSql := "SELECT BUW_TIPO, BUW_DENOMI,BUW_SLDINI, BUW_DTCOMP, BUW_DTREFI, BUW_NUMPAR, BUW_VLRFIN, BUW_VLRPAG, BUW_SLDFIN, BUW_QTPAIN, BUW_VLPGTR, BUW_QTPAPG, BUW_ATUMON, BUW_SLDFIN "
	cSql += "FROM " + RetSqlName("BUW") + " WHERE BUW_FILIAL = '" + xFilial("BUW") + "' "
	cSql += " AND BUW_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BUW_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BUW_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND BUW_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND BUW_REFERE = '" + B3DRefere() + "' "
	cSql += " AND BUW_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCCC",.F.,.T.)

	lRet := !TRBCCC->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemTriPas
Verifica se existem dados para o quadro conta tributo passivo

@author timoteo.bega
@since 02/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemTriPas()
	Local cSql		:= ""
	Local lRet		:= .T.

	cSql := "SELECT BUY_CONTA, BUY_DTCOMP, BUY_VLRINI, BUY_VLRPAG, BUY_ATUMON, BUY_SLDFIN "
	cSql += "FROM " + RetSqlName("BUY") + " WHERE BUY_FILIAL = '" + xFilial("BUY") + "' "
	cSql += " AND BUY_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND BUY_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND BUY_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND BUY_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND BUY_REFERE = '" + B3DRefere() + "' "
	cSql += " AND BUY_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCTP",.F.,.T.)

	lRet := !TRBCTP->(Eof())

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovMPC
Recupera os valores do Modelo Padrão de Capital

@author lima.everton
@since 24/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovMPC()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT  B82_SMRMTP, B82_SMRMVI, B82_NMRMTP, B82_NMRMVI, B82_SMDETP, B82_SMDEVI "
	cSql += " FROM " + RetSqlName("B82")
	cSql += " WHERE B82_FILIAL = '" + xFilial("B82") + "' "
	cSql += " AND B82_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B82_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B82_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B82_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B82_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B82_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMPC",.F.,.T.)

	TcSetField("TRBMPC", "B82_SMRMTP", "N", 16, 2 )
	TcSetField("TRBMPC", "B82_SMRMVI", "N", 16, 2 )
	TcSetField("TRBMPC", "B82_NMRMTP", "N", 16, 2 )
	TcSetField("TRBMPC", "B82_NMRMVI", "N", 16, 2 )
	TcSetField("TRBMPC", "B82_SMDETP", "N", 16, 2 )
	TcSetField("TRBMPC", "B82_SMDEVI", "N", 16, 2 )

	lRet := !TRBMPC->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovTAP
Recupera os valores do Modelo Padrão de Capital

@author lima.everton
@since 24/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovTAP()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B89_TIPPLA, B89_AJUTAB, B89_TXCANC, B89_INFMED, B89_REAMAX, B89_REACUS, B89_FAIETA, B89_METINT, B89_ESTFLX "
	cSql += " FROM " + RetSqlName("B89")
	cSql += " WHERE B89_FILIAL = '" + xFilial("B89") + "' "
	cSql += " AND B89_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B89_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B89_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B89_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B89_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B89_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBTAP",.F.,.T.)

	lRet := !TRBTAP->(Eof())

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetTipOpe
Classifica o tipo de operadora para geração do XML

@author Roger C
@since 14/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetTipOpe(cCodOpe)

	Local aArea	:= GetArea()
	Default cCodOpe	:= ''

	B8M->(dbSetOrder(1))
	If B8M->(msSeek(xFilial('B8M')+cCodOpe))
		cRet	:= IIf(B8M->B8M_MODALI =='ADMIN', 'administradora', IIf(B8M->B8M_MODALI $ 'COOPM/COOPO', 'cooperativa', 'padrao' ) )
	Else
		MsgAlert('Não foi identificado o Tipo de Operadora. Será gerado o modelo padrão do XML.', 'Atenção: Verifique o Cadastro de Operadora.' )
		cRet	:= 'padrao'
	EndIf

Return(cRet)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetPonto
Remove acentos e caracteres inválidos no XML

@author Roger C
@since 28/06/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetPonto(cExp)
	Default cExp := ''

	cExp := StrTran(cExp,"-"," ")
	cExp := StrTran(cExp,"."," ")
	cExp := StrTran(cExp,"´"," ")
	cExp := StrTran(cExp,","," ")
	cExp := StrTran(cExp,"("," ")
	cExp := StrTran(cExp,")"," ")
	cExp := StrTran(cExp,"/"," ")
	cExp := StrTran(cExp,"\"," ")
	cExp := StrTran(cExp,":"," ")
	cExp := StrTran(cExp,"^"," ")
	cExp := StrTran(cExp,"*"," ")
	cExp := StrTran(cExp,"$"," ")
	cExp := StrTran(cExp,"#"," ")
	cExp := StrTran(cExp,"!"," ")
	cExp := StrTran(cExp,"["," ")
	cExp := StrTran(cExp,"]"," ")
	cExp := StrTran(cExp,"?"," ")
	cExp := StrTran(cExp,";"," ")
	cExp := StrTran(cExp,"ç","c")
	cExp := StrTran(cExp,"`"," ")
	cExp := StrTran(cExp,Chr(166)," ")
	cExp := StrTran(cExp,Chr(167)," ")
	cExp := StrTran(cExp,"á","a")
	cExp := StrTran(cExp,"ã","a")
	cExp := StrTran(cExp,"à","a")
	cExp := StrTran(cExp,"â","a")
	cExp := StrTran(cExp,"é","e")
	cExp := StrTran(cExp,"è","e")
	cExp := StrTran(cExp,"ê","e")
	cExp := StrTran(cExp,"í","i")
	cExp := StrTran(cExp,"ì","i")
	cExp := StrTran(cExp,"ó","o")
	cExp := StrTran(cExp,"ò","o")
	cExp := StrTran(cExp,"õ","o")
	cExp := StrTran(cExp,"ô","o")
	cExp := StrTran(cExp,"ú","u")
	cExp := StrTran(cExp,"ù","u")
	cExp := StrTran(cExp,"Á","A")
	cExp := StrTran(cExp,"À","A")
	cExp := StrTran(cExp,"Â","A")
	cExp := StrTran(cExp,"Ã","A")
	cExp := StrTran(cExp,"É","E")
	cExp := StrTran(cExp,"È","E")
	cExp := StrTran(cExp,"Ê","E")
	cExp := StrTran(cExp,"Í","I")
	cExp := StrTran(cExp,"Ì","I")
	cExp := StrTran(cExp,"Ó","O")
	cExp := StrTran(cExp,"Ò","O")
	cExp := StrTran(cExp,"Õ","O")
	cExp := StrTran(cExp,"Ô","O")
	cExp := StrTran(cExp,"Ú","U")
	cExp := StrTran(cExp,"Ç","C")
	cExp := StrTran(cExp,"@"," ")
	cExp := StrTran(cExp,"%"," ")
	cExp := StrTran(cExp,"~"," ")
	cExp := StrTran(cExp,"¨"," ")
	cExp := StrTran(cExp,"{"," ")
	cExp := StrTran(cExp,"}"," ")
	cExp := StrTran(cExp,"+"," ")
	cExp := StrTran(cExp,"-"," ")
	cExp := StrTran(cExp,"="," ")
	cExp := StrTran(cExp,"_"," ")
	cExp := StrTran(cExp,"<"," ")
	cExp := StrTran(cExp,">"," ")
	cExp := StrTran(cExp,"&"," ")
	cExp := StrTran(cExp,"|"," ")

Return(cExp)


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MvtContPec
Monta a tag do MvtContPec

@author Roger C
@since 28/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MvtContPec()

	If TemMovContPec()

		InsInXMLTemp(MontaTag(2,'contraprestacoesPecuniarias','',.T.,.F.,.T.) )

		TRBCOP->(dbGoTop())
		Do While !TRBCOP->(Eof())

			InsInXMLTemp(MontaTag(4,'lancContraprestacoesPecuniarias','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(8,'plano',AllTrim(TRBCOP->B37_PLANO),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'cobertura',IIF(SUBSTR(AllTrim(TRBCOP->B37_PERCOB),1,1)=='0',SUBSTR(AllTrim(TRBCOP->B37_PERCOB),2,2),AllTrim(TRBCOP->B37_PERCOB)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'valorLiquido',AllTrim(Str(TRBCOP->B37_EMITID)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'valorRecebido',AllTrim(Str(TRBCOP->B37_RECEBI)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'valorVencido',AllTrim(Str(TRBCOP->B37_VENCID)),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'valorVencer',AllTrim(Str(TRBCOP->B37_AVENCE)),.T.,.T.,.T.) )

			InsInXMLTemp(MontaTag(4,'lancContraprestacoesPecuniarias','',.F.,.T.,.T.) )

			TRBCOP->(DbSkip())

		EndDo

		InsInXMLTemp(MontaTag(2,'contraprestacoesPecuniarias','',.F.,.T.,.T.) )

	Else
		InsInXMLTemp(MontaTag(2,'contraprestacoesPecuniarias','',.T.,.T.,.T.) )
	EndIf

	TRBCOP->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovContPec
Recupera os valores de Contraprestações Pecuniárias / Prêmios por Período de Cobertura

@author RogerC
@since 28/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovContPec()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B37_PLANO, B37_PERCOB, B37_EMITID, B37_RECEBI, B37_VENCID, B37_AVENCE "
	cSql += " FROM " + RetSqlName("B37")
	cSql += " WHERE B37_FILIAL = '" + xFilial("B37") + "' "
	cSql += " AND B37_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B37_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B37_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B37_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B37_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B37_PLANO, B37_PERCOB "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOP",.F.,.T.)
	TcSetField("TRBCOP", "B37_EMITID",  "N", 16, 2 )
	TcSetField("TRBCOP", "B37_RECEBI",  "N", 16, 2 )
	TcSetField("TRBCOP", "B37_VENCID",  "N", 16, 2 )
	TcSetField("TRBCOP", "B37_AVENCE",  "N", 16, 2 )

	lRet := !TRBCOP->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSBCNOPE
Busca CNPJ da Operadora Participante

@author josé Paulo
@since 29/07/2019
/*/
//--------------------------------------------------------------------------------------------------
FUNCTION PLSBCNOPE(cCnpj)
	Local    cSQL:= ""
	Local 	 cRet:= ""
	Default cCnpj:= ""

	cSql := " SELECT B8M_CNPJOP "
	cSql += " FROM " + RetSqlName("B8M")
	cSql += " WHERE B8M_FILIAL = '" + xFilial("B8M") + "' "
	cSql += " AND B8M_CODOPE = '" + cCnpj + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCNOP",.F.,.T.)

	If !TRBCNOP->(Eof())
		cRet:=TRBCNOP->B8M_CNPJOP
	EndIf

	TRBCNOP->(dbCloseArea())

Return cRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CREDEBOP
Monta a tag Crédito Débitos com Operadora

@author jose.paulo
@since 31/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function CREDEBOP()
	Local nFor	:= 0

	If TemMovCrD()

		InsInXMLTemp(MontaTag(2,'creditosDebitosCRC','',.T.,.F.,.T.) )

		TRBCRDE->(dbGoTop())
		Do While !TRBCRDE->(Eof())

			InsInXMLTemp(MontaTag(4,'lancOperadoraCreditosDebitosCRC','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(6,'operadora',TRBCRDE->B6X_OPECRD,.T.,.T.,.T.) )

			For nFor:=2 to 10
				InsInXMLTemp(MontaTag(8,'lancCreditosDebitosCRC','',.T.,.F.,.T.) )
				InsInXMLTemp(MontaTag(10,'movimentacao',"CAMPO"+cValToChar(nFor)+"",.T.,.T.,.T.) )
				If nFor == 1
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_OPECRD'),"@E 9,999,999,999,999.99")),.T.,.T.,.T.) )
				elseIf nFor == 2
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLRCOS'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 3
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLRIAR'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 4
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLROCO'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 5
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLRPPS'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 6
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLROCP'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 7
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLRPPC'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 8
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLRDOA'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 9
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLRPES'),"9999999999999.99")),.T.,.T.,.T.) )
				elseIf nFor == 10
					InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBCRDE->B6X_VLRODN'),"9999999999999.99")),.T.,.T.,.T.) )
				endif
				InsInXMLTemp(MontaTag(8,'lancCreditosDebitosCRC','',.F.,.T.,.T.) )
			Next
			InsInXMLTemp(MontaTag(4,'lancOperadoraCreditosDebitosCRC','',.F.,.T.,.T.) )

			TRBCRDE->(DbSkip())

		EndDo

		InsInXMLTemp(MontaTag(2,'creditosDebitosCRC','',.F.,.T.,.T.) )

	EndIf

	TRBCRDE->(dbCloseArea())

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovCrD
Recupera os valores dos créditos débitos com operadoras

@author jose.paulo
@since 31/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovCrD()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B6X_OPECRD,B6X_VLRCOS,B6X_VLRIAR,B6X_VLROCO,B6X_VLRPPS,B6X_VLROCP,B6X_VLRPPC,B6X_VLRDOA,B6X_VLRPES,B6X_VLRODN "
	cSql += " FROM " + RetSqlName("B6X")
	cSql += " WHERE B6X_FILIAL = '" + xFilial("B6X") + "' "
	cSql += " AND B6X_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B6X_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B6X_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B6X_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B6X_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B6X_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCRDE",.F.,.T.)

	lRet := !TRBCRDE->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DetFunInv
Monta a tag CBR - Risco de Crédito - Parcela 2

@author jose.paulo
@since 31/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function DetFunInv()
	Local nFor	:= 0

	If TemMovFIn()

		InsInXMLTemp(MontaTag(2,'fundosInvestimentosCRC','',.T.,.F.,.T.) )

		TRBDFIN->(dbGoTop())
		Do While !TRBDFIN->(Eof())

			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(10,'movimentacao',"CAMPO1",.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBDFIN->B6Z_VLRTAQ'),"9999999999999.99")),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.F.,.T.,.T.) )

			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(10,'movimentacao',"CAMPO2",.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'valor',cValtoChar(TRBDFIN->B6Z_PERFPR),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.F.,.T.,.T.) )

			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(10,'movimentacao',"CAMPO3",.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBDFIN->B6Z_VLRTAF'),"9999999999999.99")),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.F.,.T.,.T.) )

			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(10,'movimentacao',"CAMPO4",.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'valor',cValtoChar(TRBDFIN->B6Z_PERTAQ),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.F.,.T.,.T.) )

			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(10,'movimentacao',"CAMPO5",.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'valor',Alltrim(Transform(&('TRBDFIN->B6Z_VLRTAI'),"9999999999999.99")),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'lancFundosInvestimentosCRC','',.F.,.T.,.T.) )

			TRBDFIN->(DbSkip())

		EndDo

		InsInXMLTemp(MontaTag(2,'fundosInvestimentosCRC','',.F.,.T.,.T.) )

	EndIf

	TRBDFIN->(dbCloseArea())

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovFIn

@author jose.paulo
@since 31/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovFIn()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B6Z_VLRTAQ,B6Z_PERFPR,B6Z_VLRTAF,B6Z_PERTAQ,B6Z_VLRTAI "
	cSql += " FROM " + RetSqlName("B6Z")
	cSql += " WHERE B6Z_FILIAL = '" + xFilial("B6Z") + "' "
	cSql += " AND B6Z_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B6Z_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B6Z_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B6Z_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B6Z_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B6Z_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBDFIN",.F.,.T.)

	lRet := !TRBDFIN->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SegMontCont
Monta a tag do SegMontCont

@author Roger C
@since 08/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Inadimple()
	Local nMes	:= 0

	If TemMovInad()
		InsInXMLTemp(MontaTag(2,'inadimplenciaADMBN','',.T.,.F.,.T.) )
		TRBINA->(dbGoTop())
		Do While !TRBINA->(Eof())

			InsInXMLTemp(MontaTag(8,'lancInadimplenciaADMBN','',.T.,.F.,.T.) )
			InsInXMLTemp(MontaTag(10,'possuiMetodologia',IIF(TRBINA->B7W_PMPAUT=="1","true","false")        ,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'percentualApurado',cValtoChar(TRBINA->B7W_PERCAP),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(8,'lancInadimplenciaADMBN','',.F.,.T.,.T.) )
			TRBINA->(DbSkip())
		EndDo
		InsInXMLTemp(MontaTag(2,'inadimplenciaADMBN','',.F.,.T.,.T.) )

	EndIf

	TRBINA->(dbCloseArea())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemMovInad
valores do queadro Inadimplência

@author jose.paulo
@since 16/03/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function TemMovInad()

	Local cSql := ""
	Local lRet := .T.

	cSql := " SELECT B7W_PMPAUT, B7W_PERCAP "
	cSql += " FROM " + RetSqlName("B7W")
	cSql += " WHERE B7W_FILIAL = '" + xFilial("B7W") + "' "
	cSql += " AND B7W_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B7W_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B7W_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B7W_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B7W_REFERE = '" + B3DRefere() + "' "
	cSql += " AND B7W_STATUS = '" + VALIDO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBINA",.F.,.T.)

	lRet := !TRBINA->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Capital Baseado em Riscos
Monta a tag do Capital Baseado em Riscos

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------

Static Function CapBasRisco()

	Local cSinal := ""
	Local cIndex := ""

	If TemCapBasRisco()

		InsInXMLTemp(MontaTag(2,'quadroRiscoMercado','',.T.,.F.,.T.) )		

		Do While !TRBRIS->(Eof())

			cSinal := SinalRis(TRBRIS->BVU_ESCX)
			cIndex := IndexRis(TRBRIS->BVU_INDEXA)			

			InsInXMLTemp(MontaTag(8,'lancQuadroRiscoMercado','',.T.,.F.,.T.) )

			InsInXMLTemp(MontaTag(10,'nrAnoReferencia',TRBRIS->BVU_ANOCMP,.T.,.T.,.T.) ) 
			InsInXMLTemp(MontaTag(10,'tpTrimestreReferencia',Substr(TRBRIS->BVU_REFERE,2,2),.T.,.T.,.T.) )	
			InsInXMLTemp(MontaTag(10,'cdContaContabil',AllTrim(TRBRIS->BVU_CONTA),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'vlValor',Alltrim(Transform((TRBRIS->BVU_VALOR),"9999999999999.99")),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'tpSinal',cSinal,.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'vlPrazoPonderadoFluxo',StrZero(TRBRIS->BVU_MESES,3),.T.,.T.,.T.) )
			InsInXMLTemp(MontaTag(10,'tpIndexador',cIndex,.T.,.T.,.T.) )			

			InsInXMLTemp(MontaTag(8,'lancQuadroRiscoMercado','',.F.,.T.,.T.) )

			TRBRIS->(DbSkip())

		EndDo
		
		InsInXMLTemp(MontaTag(2,'quadroRiscoMercado','',.F.,.T.,.T.) )

	EndIf

	IIF(SELECT("TRBRIS")>0,TRBRIS->(DbCloseArea()),"")

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemCapBasRisco
Consulta quadros de Capital Baseados em Riscos cadastrados 

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------

Static Function TemCapBasRisco()

	Local cSql := ""
	Local cB3DTri := B3D->B3D_ANO + B3D->B3D_CODIGO
	Local lRet := .F.

	Default cTri := "2023003"

	If cB3DTri >= cTri

		cSql := " SELECT BVU_CONTA,BVU_VALOR,BVU_ESCX,BVU_MESES,BVU_INDEXA,BVU_ANOCMP,BVU_REFERE"
		cSql += " FROM " + RetSqlName("BVU")
		cSql += " WHERE BVU_FILIAL = '" + xFilial("BVU") + "' "
		cSql += " AND BVU_CODOPE = '" + B3D->B3D_CODOPE + "' "
		cSql += " AND BVU_CODOBR = '" + B3D->B3D_CDOBRI + "' "
		cSql += " AND BVU_ANOCMP = '" + B3D->B3D_ANO + "' "
		cSql += " AND BVU_CDCOMP = '" + B3D->B3D_CODIGO + "' "
		cSql += " AND BVU_REFERE = '" + B3DRefere() + "' "
		cSql += " AND D_E_L_E_T_ = ' ' "

		cSql := ChangeQuery(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBRIS",.F.,.T.)

		lRet := !TRBRIS->(Eof())

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SinalRis
De/para Sinal Quadro Capital Baseado em Riscos - Risco de Mercado - ALM

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------

Static Function SinalRis(cSinal)

	Local cTpSinal := ""

	Do Case 
		Case cSinal == "0"
			cTpSinal := "P"
		Case cSinal == "1"
			cTpSinal := "N"
	EndCase	

Return cTpSinal

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IndexRis
De/ para Indice Quadro Capital Baseado em Riscos - Risco de Mercado - ALM

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------

Static Function IndexRis(cIndex)

	cIndice := ""

	Do Case
		Case cIndex == "0"
			cIndice := "PRE"
		Case cIndex == "1"
			cIndice := "POS"
		Case cIndex == "2"
			cIndice := "IPCA"
		Case cIndex == "3"
			cIndice := "IGPM"
		Case cIndex == "4"
			cIndice := "CAMBIAL"
	EndCase

Return cIndice

/*/{Protheus.doc} PlDiopsMes
	Valida se foi informado um mês de competência valido.
	@type  Function
	@author PLS Team
	@since 03/05/2024
	@version version
/*/
Function PlDiopsMes()

	Local lRet := .T.
	Local xMes := Alltrim(&(ReadVar()))

	If  Len(xMes) != 2
		lRet := .F.
		MSGALERT("Tamanho do campo inválido.")
	Else 
		If ! (xMes >= "01" .and. xMes <= "12") 	
			lRet := .F.
			MSGALERT("Informar um mês de competência válido! De Jan a Dez.")
		EndIf
	Endif	
	
Return lRet

Function PlSDIOCPM(cCodObr,cAno,cCodigo,cCodOpe,cTipo)
	Local cSql      := ""
	Local lOk       := .F.
	lOCAL nQtd      := 0
	Default cCodObr := ""
	Default cAno    := ""		
	Default cCodigo := ""
	Default cCodOpe := ""
	Default cTipo   := ""

	If cTipo == "1" 
		cSql := " SELECT COUNT(*) TOTAL " 
		cSql += " 	FROM " + RetSqlName("B8A") +""		
		cSql += " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
		cSql += " 	AND B8A_CODOBR = '" + cCodObr + "' "
		cSql += " 	AND B8A_ANOCMP = '" + cAno + "' "
		cSql += " 	AND B8A_CDCOMP = '" + cCodigo + "' "
		cSql += " 	AND B8A_CODOPE = '" + cCodOpe + "' "
		cSql += " 	AND B8A_MESCMP <> ' ' "
		cSql += "	AND D_E_L_E_T_ = ' '"
	else 
		cSql := " SELECT COUNT(*) TOTAL " 
		cSql += " 	FROM " + RetSqlName("B8H") +""		
		cSql += " WHERE B8H_FILIAL = '" + xFilial("B8H") + "' "
		cSql += " 	AND B8H_CODOBR = '" + cCodObr + "' "
		cSql += " 	AND B8H_ANOCMP = '" + cAno + "' "
		cSql += " 	AND B8H_CDCOMP = '" + cCodigo + "' "
		cSql += " 	AND B8H_CODOPE = '" + cCodOpe + "' "
		cSql += " 	AND B8H_MESCMP <> ' ' "
		cSql += "	AND D_E_L_E_T_ = ' '"
	EndIf

	nQtd := MPSysExecScalar(cSql, "TOTAL")

Return nQtd > 0
