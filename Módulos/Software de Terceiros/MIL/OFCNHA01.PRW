#include "TOTVS.CH"
#include 'TBICONN.CH'
#include "OFCNHA01.CH"
#include "OFIXDEF.CH"

/*/{Protheus.doc} OFCNHA01
	Rotina responsável pela geracao de dados e do arquivo PRIM2
	@type function
	@author Vinicius Gati
	@since  21/02/2018
/*/
function OFCNHA01( aParam )
default aParam := { "01", "01" }
Private lDebug := .F.

	if select("SX2") == 0
		prepare environment Empresa aParam[1] Filial aParam[2] Modulo "OFI"
	endif

	BatchProcess(STR0001,STR0002,,{ || OFCNHA0101_Processo() })		// #"Geração de dados PRIM2"	#"Este processo funciona via agendador e é responsável por gerar arquivo PRIM2"
Return .T.


/*/{Protheus.doc} SchedDef
	Função padrão scheduler
	@author Vinicius Gati
	@since 16/01/2018
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"",;
	"",;
	"",;
	"" ;
	}
Return aParam


/*/{Protheus.doc} Processo
	Função principal que gera os dados
	@type function
	@author Vinicius Gati
	@since 16/01/2018
/*/
function OFCNHA0101_Processo(aData)
local   nX          := 1
local   cAlias      := getNextAlias()
local   cCpoDtHr
local   cFilePath   := ""
Private oSqlHlp     := DMS_SqlHelper():New()
Private oConf       := OFCNHPrimConfig():New( .T. )
Private oPrim       := OFCNHPrim():New( oConf )
Private oCanalVenda := OFCNHPrimCanalVenda():New()
Private oLogger     := DMS_Logger():New("PRIM02_"+DTOS(dDatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
Private lDebug      := alltrim(oConf:oConfig["LOGS"]) == "1"
Private aVBBs       := {}
Private aArms       := {}
Private cError      := ""
Private cUltExt     := ""
private cMsgLog     := ""
private cSD1Seq     := ""
private cSD2Seq     := ""
private cSD3Seq     := ""
private cSD1Max     := ""
private cSD2Max     := ""
private cSD3Max     := ""
private cDatExt     := FwTimeStamp(1) // data da extracao atual
private cSGBD       := TcGetDb()
Default aData       := oPrim:PRIMPadrao( cFilAnt )

	cCpoDtHr := oSqlHlp:Concat({'VBB_DATA2', 'VBB_HORA2'})

	cMsgLog += "OFCNHA01 - "+STR0001+" - " + DtoC(date()) + " " + time() + CRLF		// #Geração PRIM2
	if lDebug
	    FWLogMsg("INFO",,"OFCNHA01",,,,cFilAnt + STR0001)

		cMsgLog += STR0003 + CRLF + "-----------------------" + CRLF	// #"Parâmetros:"

		for nX := 1 to len( aData )
			cMsgLog += "#" + cValToChar(nX) + CRLF
			cMsgLog += " - "+ STR0004 + aData[nX,1] + CRLF	// #Filial: 
			cMsgLog += " - "+ STR0005 + aData[nX,2] + CRLF	// #Armazém: 
			cMsgLog += " - "+ STR0006 + DtoC( aData[nX,3] ) + " a " + DtoC( aData[nX,4] ) + CRLF	// #Data: 
			cMsgLog += " - "+ STR0007 + iif(aData[nX,5], STR0008, "") + " - " + iif(aData[nX,8], STR0009, "") + CRLF	//#Geração: 	#"Estoque"		#"Venda"
			cMsgLog += " - "+ STR0010 + iif( aData[nX,7] == oPrim:CodGerExcepcional(), STR0011, STR0012 ) + CRLF + CRLF	// #Tipo	#"Excepcional"	#"Normal"
		next
	endif

	oLogger:Log({"TIMESTAMP", STR0061 + cFilAnt})	// #"Iniciando Geração de dados para filial: "

	// coleta data da ultima geração
	cQuery := "select"
	cQuery += " coalesce( MAX(?), ? ) ULTEXTR,"
	cQuery += " coalesce( MAX(VBB_SD1SEQ), '000000') SD1SEQ,"
	cQuery += " coalesce( MAX(VBB_SD2SEQ), '000000') SD2SEQ,"
	cQuery += " coalesce( MAX(VBB_SD3SEQ), '000000') SD3SEQ"
	cQuery += " FROM "+retSqlName("VBB")+" VBB"
	cQuery += " WHERE VBB_FILIAL = ?"
	cQuery += " AND VBB.D_E_L_E_T_ = ?"
	OFCNHA015C_ExecQuery( @cQuery, {{'U',cCpoDtHr},{'C',cDatExt},{'C',xFilial("VBB")},{'C',space(1)}}, cAlias )
	if ! (cAlias)->( eof() )
		cUltExt := (cAlias)->ULTEXTR
		cSD1Seq := (cAlias)->SD1SEQ
		cSD2Seq := (cAlias)->SD2SEQ
		cSD3Seq := (cAlias)->SD3SEQ
	endif
	(cAlias)->( dbCloseArea() )

	for nX := 1 to LEN(aData)
		OFCNHA0112_GeraDados(;
			aData[nX, 01],;
			aData[nX, 02],;
			aData[nX, 03],;
			aData[nX, 04],;
			aData[nX, 05],;
			aData[nX, 06],;
			aData[nX, 07],;
			aData[nX, 08],;
			aData[nX, 09],;
			aData[nX, 10],;
			aData[nX, 11],;
			@aData[nX, 12])
	next
	if len(aVBBs) > 0
		cFilePath := oPrim:GeraArquivo(aVBBs)
		OFCNHA0109_GravaCheckPoint(aData) // grava os numseq para geracoes normais

		cMsgLog += STR0013 + aData[1,12] + CRLF		// #"Número envio: "
		cMsgLog += STR0014 + transform(cUltExt, "@R 9999-99-99 99:99:99" ) + CRLF		// #"Extração anterior: "
		cMsgLog += STR0016 + cFilePath + CRLF + CRLF		// #"arquivo gerado: "
		cMsgLog += "OFCNHA01 - "+STR0015+" - " + DtoC(date()) + " " + time() + CRLF
	endif

	OA060004C_log( /*cAgroup*/ "PRIM", /*cTipo*/ "PRIM2", cMsgLog, /*lSendMail*/ .T. )

	if lDebug
	    FWLogMsg("INFO",,"OFCNHA01",,,,cFilAnt + STR0015)
	endif

	freeobj(oSqlHlp)
	freeobj(oConf)
	freeobj(oPrim)
	freeobj(oCanalVenda)
	freeobj(oLogger)
return cFilePath


/*/{Protheus.doc} OFCNHA0102_GeraEstoque
	Gera o cabecalho de estoque do arquivo prim2
	
	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0102_GeraEstoque(cArm, cTipoGer, dDtEst, cNumProgr, cDatEst)
local cQuery   := ''
local nI
local cCodMerc := oConf:cMarket
local cCodCorp := oConf:cDealerCode
local aGrupos  := {"NAOTRAZERNADA"}
local aBind    := {}

	for nI := 1 to len( oConf:oConfig["LOCAIS"] )
		if oConf:oConfig["LOCAIS"][nI]["WAREHOUSE"] == cArm
			aAdd( aGrupos, alltrim(oConf:oConfig["LOCAIS"][nI]["GRUPO"]) )
		endif
	next

	oLogger:Log({"TIMESTAMP",STR0018})		// #"Coletando peças movimentadas para estoque"
	cQuery := " UPDATE "+retsqlname('VBF')
	cQuery += " SET VBF_FLGARQ = ?"
	cQuery += " WHERE VBF_PRODUT IN ("
	cQuery += 	" SELECT B2_COD"
	cQuery += 	" FROM " + oSqlHlp:Nolock('SB2')
	cQuery += 	" JOIN " + oSqlHlp:Nolock('SB1')
	cQuery +=		" on  B1_FILIAL = ?"
	cQuery +=		" and B1_COD = B2_COD"
	cQuery +=		" and B1_GRUPO in (?)"
	cQuery += 		" and SB1.D_E_L_E_T_ = ?"
	cQuery += 	" JOIN " + oSqlHlp:Nolock('NNR')
	cQuery += 		" on  NNR_FILIAL = ?"
	cQuery +=		" and NNR_CODIGO = B2_LOCAL"
	cQuery +=		" and NNR_VDADMS = ?"
	cQuery +=		" and NNR.D_E_L_E_T_ = ?"
	cQuery += 	" where SB2.D_E_L_E_T_ = ?"
	cQuery += 	" GROUP BY B2_COD"
	cQuery += " )"
	cQuery += " AND VBF_FLGUSO = ?"
	cQuery += " AND D_E_L_E_T_ = ?" // criando cache
	aAdd( aBind, {'C','S'} )
	aAdd( aBind, {'C',xFilial("SB1")})
	aAdd( aBind, {'A',aGrupos})
	aAdd( aBind, {'C',space(1)})
	aAdd( aBind, {'C',xFilial("NNR")})
	aAdd( aBind, {'C','1'})
	aAdd( aBind, {'C',space(1)})
	aAdd( aBind, {'C',space(1)})
	aAdd( aBind, {'C','1'})
	aAdd( aBind, {'C',space(1)})
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0019)
	oLogger:Log({"TIMESTAMP",STR0020})	// # "Finalizado"

	reclock('VBB', .T.)
	VBB->VBB_FILIAL  := xFilial('VBB')
	VBB->VBB_CODIGO  := GetSxeNum('VBB', 'VBB_CODIGO'); confirmSx8()
	VBB->VBB_CATREG  := 'T'
	VBB->VBB_IDENTI  := 'ST'
	VBB->VBB_DATA    := SToD(LEFT(cUltExt, 8))
	VBB->VBB_HORA    := RIGHT( cUltExt, 6)
	VBB->VBB_DATA2   := SToD(LEFT(cDatExt, 8))
	VBB->VBB_HORA2   := RIGHT( cDatExt , 6)
	VBB->VBB_CODCOR  := '01' // fixo
	VBB->VBB_CODMER  := cCodMerc
	VBB->VBB_CODUNI  := cCodCorp
	VBB->VBB_LOCCNH   := cArm
	VBB->VBB_FILEQU  := 0
	VBB->VBB_CATTRA  := cTipoGer
	VBB->VBB_NUMTRA  := 0
	VBB->VBB_NUMREG  := 0
	VBB->VBB_TIPGER  := oPrim:CodArqEst()
	VBB->VBB_CODPRG := cNumProgr
	VBB->VBB_DATP01 := iif( cTipoGer == oPrim:CodGerExcepcional(), cDatEst, '' )
	VBB->(MsUnlock())

	OFCNHA0103_GeraItensEstoque(cArm, cTipoGer, VBB->VBB_CODIGO, dDtEst, aGrupos)
	AADD(aVBBs, VBB->VBB_CODIGO)
return .t.


/*/{Protheus.doc} OFCNHA0103_GeraItensEstoque
	Gera os itens do estoque prim2
	
	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0103_GeraItensEstoque(cArm, cTipoGer, cCodVBB, dDtEst, aGrupos)
local cAl        := GetNextAlias()
local nSizeDes   := tamsx3('VBC_DESPRO')[1]
local aQAtuCust  := {}
local nParam03   := 0
local cQuery     := "select NNR_CODIGO from "+RetSqlName("NNR")+" NNR where NNR_FILIAL=? and NNR_VDADMS = ? and NNR.D_E_L_E_T_ = ?"
local aLocais    := {}
local lSBZ       := SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
local cPrdList   := ""
local nRegs      := 0
local aBind      := {}
local aProdutos  := {}

	OFCNHA015C_ExecQuery( @cQuery, {{'C',xFilial("NNR")},{'C','1'},{'C',space(1)}},,,.T. )
	TcSqlToArr( cQuery, aLocais )

	Pergunte("MTA260",.F.)
	nParam03 := MV_PAR03

	cSD1Max := cSD1Seq
	cSD2Max := cSD2Seq
	cSD3Max := cSD3Seq

	SB1->( dbSetOrder(1) )
	SB2->( dbSetOrder(1) )

	oLogger:Log({"TIMESTAMP","  |> "+STR0022})	// #Gerando Itens de estoque

//	if cArm == "D01"	// Armazém Não Gerenciado
	if cArm != "F01"	// Armazém Gerenciado
		cQuery := "select B1_COD, B1_DESC, MAX(D3_NUMSEQ) NUMSEQ, 'SD3' ORIGEM"
		cQuery += " FROM " + retSqlName('SB1') + " SB1 "
		cQuery += " JOIN " + retSqlName("SD3") + " SD3 "
		cQuery += 	" ON  D3_FILIAL = ?"
		cQuery += 	" AND D3_COD = B1_COD"
		cQuery += 	" AND SD3.D_E_L_E_T_ = ?"
		cQuery += " WHERE B1_FILIAL = ? "
		cQuery += " AND B1_GRUPO in (?)"
		cQuery += " AND SB1.D_E_L_E_T_ = ?"
		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " AND D3_NUMSEQ > ?"
		endif
		cQuery += " GROUP BY B1_COD, B1_DESC"

		cQuery += " UNION ALL "

		cQuery += "select B1_COD, B1_DESC, MAX(D2_NUMSEQ) NUMSEQ, 'SD2' ORIGEM"
		cQuery += " FROM " + retSqlName('SB1') + " SB1 "
		cQuery += " JOIN " + retSqlName("SD2") + " SD2 "
		cQuery += 	" ON  D2_FILIAL = ?"
		cQuery += 	" AND D2_COD = B1_COD"
		cQuery += 	" AND SD2.D_E_L_E_T_ = ?"
		cQuery += " WHERE B1_FILIAL = ? "
		cQuery += " AND B1_GRUPO in (?)"
		cQuery += " AND SB1.D_E_L_E_T_ = ?"
		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " AND D2_NUMSEQ > ?"
		endif
		cQuery += " GROUP BY B1_COD, B1_DESC"

		cQuery += " UNION ALL "

		cQuery += "select B1_COD, B1_DESC, MAX(D1_NUMSEQ) NUMSEQ, 'SD1' ORIGEM"
		cQuery += " FROM " + retSqlName('SB1') + " SB1 "
		cQuery += " JOIN " + retSqlName("SD1") + " SD1 "
		cQuery += 	" ON  D1_FILIAL = ?"
		cQuery += 	" AND D1_COD = B1_COD"
		cQuery += 	" AND SD1.D_E_L_E_T_ = ?"
		cQuery += " WHERE B1_FILIAL = ? "
		cQuery += " AND B1_GRUPO in (?)"
		cQuery += " AND SB1.D_E_L_E_T_ = ?"
		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " AND D1_NUMSEQ > ?"
		endif
		cQuery += " GROUP BY B1_COD, B1_DESC"

		if cTipoGer == oPrim:CodGerNormal()

			cQuery += " UNION ALL "

			cQuery += " SELECT VBD_PRODUT,B1_DESC,D2_NUMSEQ, 'SF3' ORIGEM "
			cQuery += " FROM " + retSqlName('SD2') + " SD2 "
			cQuery += " JOIN " + retSqlName('SF3') + " SF3 "
			cQuery += "     ON F3_FILIAL= ? "
			cQuery += "         AND F3_NFISCAL = D2_DOC "
			cQuery += "         AND F3_SERIE = D2_SERIE "
			cQuery += "         AND SF3.D_E_L_E_T_= ? "
			cQuery += " JOIN " + retSqlName('VBD') + " VBD " 
			cQuery += "     ON VBD_FILIAL= ? "
			cQuery += "         AND VBD_PRODUT = D2_COD "
			cQuery += "         AND VBD_NUMNFI = D2_DOC "
			cQuery += "         AND VBD_SERORI = D2_SERIE "
			cQuery += "         AND VBD_INDDEV <> ? "//'S'
			cQuery += "         AND VBD_INDCAN <> ? "//'Y'
			cQuery += "         AND VBD.D_E_L_E_T_= ? "
			cQuery += "         AND VBD_CODIGO = "
			cQuery += "     (SELECT MAX(VBD_CODIGO) "
			cQuery += "     FROM " + retSqlName('VBD') "
			cQuery += "     WHERE VBD_FILIAL= ? "
			cQuery += "             AND VBD_PRODUT = D2_COD "
			cQuery += "             AND VBD_NUMNFI = D2_DOC "
			cQuery += "             AND VBD_SERORI = D2_SERIE "
			cQuery += "             AND VBD_INDDEV <> ? "// 'S'
			cQuery += "             AND VBD_INDCAN <> ? " //'Y'
			cQuery += "             AND D_E_L_E_T_= ?) "
			cQuery += " JOIN " + retSqlName('SB1') + " SB1 "
			cQuery += " 	ON B1_FILIAL =  ? "
			cQuery += " 	AND B1_CODFAB = VBD_PRODUT "
			cQuery += " 	        AND SB1.D_E_L_E_T_=? "
			cQuery += " WHERE SD2.D2_FILIAL= ? "
			cQuery += "         AND D2_GRUPO IN (?) "
			cQuery += "         AND F3_DTCANC IN (?) "
			cQuery += "         AND NOT EXISTS "
			cQuery += "         (SELECT 1 FROM " + retSqlName('VBD') + " DELTA "
			cQuery += "     WHERE DELTA.VBD_FILIAL = VBD.VBD_FILIAL "
			cQuery += "             AND DELTA.VBD_PRODUT = VBD.VBD_PRODUT " 
			cQuery += "             AND DELTA.VBD_NUMNFI = VBD.VBD_NUMNFI "
			cQuery += "             AND DELTA.VBD_SERORI = VBD.VBD_SERORI "
			cQuery += "             AND DELTA.VBD_CODCLI = VBD.VBD_CODCLI "
			cQuery += "             AND DELTA.VBD_LOJCLI = VBD.VBD_LOJCLI "
			cQuery += "             AND DELTA.VBD_QTDFAT = VBD.VBD_QTDFAT "
			cQuery += "             AND DELTA.VBD_INDCAN = ? "// 'Y'
			cQuery += "             AND DELTA.D_E_L_E_T_= ? ) "
			cQuery += "         AND SD2.D_E_L_E_T_= ? " //'*'
			cQuery += " GROUP BY VBD_PRODUT,B1_DESC,D2_NUMSEQ "
		endif

		aAdd( aBind, { 'C', xFilial("SD3")} )
		aAdd( aBind, { 'C', ' '} )
		aAdd( aBind, { 'C', xFilial("SB1")} )
		aAdd( aBind, { 'A', aGrupos } )
		aAdd( aBind, { 'C', ' '} )
		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', cSD3Seq} )
		endif

		aAdd( aBind, { 'C', xFilial("SD2")} )
		aAdd( aBind, { 'C', ' '} )
		aAdd( aBind, { 'C', xFilial("SB1")} )
		aAdd( aBind, { 'A', aGrupos } )
		aAdd( aBind, { 'C', ' '} )
		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', cSD2Seq} )
		endif

		aAdd( aBind, { 'C', xFilial("SD1")} )
		aAdd( aBind, { 'C', ' '} )
		aAdd( aBind, { 'C', xFilial("SB1")} )
		aAdd( aBind, { 'A', aGrupos } )
		aAdd( aBind, { 'C', ' '} )
		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', cSD1Seq} )
		endif		

		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', xFilial("SF3") } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, { 'C', xFilial("VBD") } )
			aAdd( aBind, { 'C', oPrim:CodDev() } )
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, { 'C', xFilial("VBD") } )
			aAdd( aBind, { 'C', 'S' } )
			aAdd( aBind, { 'C', 'Y' } )
			aAdd( aBind, { 'C', ' ' } )	
			aAdd( aBind, { 'C', xFilial("SB1") } )
			aAdd( aBind, { 'C', ' ' } )	
			aAdd( aBind, { 'C', xFilial("SD2") } )
			aAdd( aBind, { 'A', aGrupos } )
			aAdd( aBind, { 'A', { DtoS(dDatabase-1), DtoS(dDatabase)} } )
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, { 'C', '*' } )
		endif

	else
		cQuery := "select B1_COD, B1_DESC, MAX(D3_NUMSEQ) NUMSEQ, 'SD3' ORIGEM"
		cQuery += " FROM " + retSqlName('VBF') + " VBF "
		cQuery += " JOIN " + retSqlName('SB1') + " SB1 ON B1_FILIAL = ? AND B1_COD = VBF_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + retSqlName("SD3") + " SD3 "
		cQuery += 	" ON  D3_FILIAL = ?"
		cQuery += 	" AND D3_COD = B1_COD"
		cQuery += 	" AND SD3.D_E_L_E_T_ = ?"
		cQuery += " WHERE VBF_FILIAL = ?"
		cQuery += " AND VBF_FLGUSO = ?"
		cQuery += " AND VBF_FLGARQ = ?"
		cQuery += " AND VBF.D_E_L_E_T_ = ?"
		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " AND D3_NUMSEQ > ?"
		endif
		cQuery += " GROUP BY B1_COD, B1_DESC"

		cQuery += " UNION ALL "

		cQuery += "select B1_COD, B1_DESC, MAX(D2_NUMSEQ) NUMSEQ, 'SD2' ORIGEM"
		cQuery += " FROM " + retSqlName('VBF') + " VBF "
		cQuery += " JOIN " + retSqlName('SB1') + " SB1 ON B1_FILIAL = ? AND B1_COD = VBF_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + retSqlName("SD2") + " SD2 "
		cQuery += 	" ON  D2_FILIAL = ?"
		cQuery += 	" AND D2_COD = B1_COD"
		cQuery += 	" AND SD2.D_E_L_E_T_ = ?"
		cQuery += " WHERE VBF_FILIAL = ?"
		cQuery += " AND VBF_FLGUSO = ?"
		cQuery += " AND VBF_FLGARQ = ?"
		cQuery += " AND VBF.D_E_L_E_T_ = ?"
		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " AND D2_NUMSEQ > ?"
		endif
		cQuery += " GROUP BY B1_COD, B1_DESC"

		cQuery += " UNION ALL "

		cQuery += "select B1_COD, B1_DESC, MAX(D1_NUMSEQ) NUMSEQ, 'SD1' ORIGEM"
		cQuery += " FROM " + retSqlName('VBF') + " VBF "
		cQuery += " JOIN " + retSqlName('SB1') + " SB1 ON B1_FILIAL = ? AND B1_COD = VBF_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + retSqlName("SD1") + " SD1 "
		cQuery += 	" ON  D1_FILIAL = ?"
		cQuery += 	" AND D1_COD = B1_COD"
		cQuery += 	" AND SD1.D_E_L_E_T_ = ?"
		cQuery += " WHERE VBF_FILIAL = ?"
		cQuery += " AND VBF_FLGUSO = ?"
		cQuery += " AND VBF_FLGARQ = ?"
		cQuery += " AND VBF.D_E_L_E_T_ = ?"
		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " AND D1_NUMSEQ > ?"
		endif
		cQuery += " GROUP BY B1_COD, B1_DESC"

		if cTipoGer == oPrim:CodGerNormal()

			cQuery += " UNION ALL "

			cQuery += " SELECT VBD_PRODUT,B1_DESC,D2_NUMSEQ, 'SF3' ORIGEM "
			cQuery += " FROM " + retSqlName('SD2') + " SD2 "
			cQuery += " JOIN " + retSqlName('SF3') + " SF3 "
			cQuery += "     ON F3_FILIAL= ? "
			cQuery += "         AND F3_NFISCAL = D2_DOC "
			cQuery += "         AND F3_SERIE = D2_SERIE "
			cQuery += "         AND SF3.D_E_L_E_T_= ? "
			cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=? "
			cQuery += " JOIN " + retSqlName('VBD') + " VBD " 
			cQuery += "     ON VBD_FILIAL= ? "
			cQuery += "         AND VBD_PRODUT = D2_COD "
			cQuery += "         AND VBD_NUMNFI = D2_DOC "
			cQuery += "         AND VBD_SERORI = D2_SERIE "
			cQuery += "         AND VBD_INDDEV <> ? "//'S'
			cQuery += "         AND VBD_INDCAN <> ? "//'Y'
			cQuery += "         AND VBD.D_E_L_E_T_= ? "
			cQuery += "         AND VBD_CODIGO = "
			cQuery += "     (SELECT MAX(VBD_CODIGO) "
			cQuery += "     FROM " + retSqlName('VBD') "
			cQuery += "     WHERE VBD_FILIAL= ? "
			cQuery += "             AND VBD_PRODUT = D2_COD "
			cQuery += "             AND VBD_NUMNFI = D2_DOC "
			cQuery += "             AND VBD_SERORI = D2_SERIE "
			cQuery += "             AND VBD_INDDEV <> ? "// 'S'
			cQuery += "             AND VBD_INDCAN <> ? " //'Y'
			cQuery += "             AND D_E_L_E_T_= ?) "
			cQuery += " JOIN " + retSqlName('SB1') + " SB1 "
			cQuery += " 	ON B1_FILIAL = ? "
			cQuery += " 	AND B1_CODFAB = VBD_PRODUT "
			cQuery += " 	        AND SB1.D_E_L_E_T_= ? "
			cQuery += " WHERE SD2.D2_FILIAL= ? "
			cQuery += "         AND F3_DTCANC IN (?) "
			cQuery += "         AND NOT EXISTS "
			cQuery += "         (SELECT 1 FROM " + retSqlName('VBD') + " DELTA "
			cQuery += "     WHERE DELTA.VBD_FILIAL = VBD.VBD_FILIAL "
			cQuery += "             AND DELTA.VBD_PRODUT = VBD.VBD_PRODUT " 
			cQuery += "             AND DELTA.VBD_NUMNFI = VBD.VBD_NUMNFI "
			cQuery += "             AND DELTA.VBD_SERORI = VBD.VBD_SERORI "
			cQuery += "             AND DELTA.VBD_CODCLI = VBD.VBD_CODCLI "
			cQuery += "             AND DELTA.VBD_LOJCLI = VBD.VBD_LOJCLI "
			cQuery += "             AND DELTA.VBD_QTDFAT = VBD.VBD_QTDFAT "
			cQuery += "             AND DELTA.VBD_INDCAN = ? "// 'Y'
			cQuery += "             AND DELTA.D_E_L_E_T_= ? ) "
			cQuery += "         AND SD2.D_E_L_E_T_= ? " //'*'
			cQuery += " GROUP BY VBD_PRODUT,B1_DESC,D2_NUMSEQ "
		endif

		aAdd( aBind, { 'C', xFilial("SB1")} )
		aAdd( aBind, { 'C', xFilial("SD3")} )
		aAdd( aBind, { 'C', ' '} )
		aAdd( aBind, { 'C', xFilial("VBF")} )
		aAdd( aBind, { 'C', '1'} )
		aAdd( aBind, { 'C', 'S'} )
		aAdd( aBind, { 'C', ' '} )
		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', cSD3Seq} )
		endif

		aAdd( aBind, { 'C', xFilial("SB1")} )
		aAdd( aBind, { 'C', xFilial("SD2")} )
		aAdd( aBind, { 'C', ' '} )
		aAdd( aBind, { 'C', xFilial("VBF")} )
		aAdd( aBind, { 'C', '1'} )
		aAdd( aBind, { 'C', 'S'} )
		aAdd( aBind, { 'C', ' '} )
		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', cSD2Seq} )
		endif

		aAdd( aBind, { 'C', xFilial("SB1")} )
		aAdd( aBind, { 'C', xFilial("SD1")} )
		aAdd( aBind, { 'C', ' '} )
		aAdd( aBind, { 'C', xFilial("VBF")} )
		aAdd( aBind, { 'C', '1'} )
		aAdd( aBind, { 'C', 'S'} )
		aAdd( aBind, { 'C', ' '} )
		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', cSD1Seq} )
		endif

		if cTipoGer == oPrim:CodGerNormal()
			aAdd( aBind, { 'C', xFilial("SF3") } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, { 'C', xFilial("VBF") } )
			aAdd( aBind, { 'C', 'S' } )
			aAdd( aBind, { 'C', '1' } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, { 'C', xFilial("VBD") } )
			aAdd( aBind, { 'C', oPrim:CodDev() } )
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, { 'C', xFilial("VBD") } )
			aAdd( aBind, { 'C', 'S' } )
			aAdd( aBind, { 'C', 'Y' } )
			aAdd( aBind, { 'C', ' ' } )	
			aAdd( aBind, { 'C', xFilial("SB1") } )
			aAdd( aBind, { 'C', ' ' } )	
			aAdd( aBind, { 'C', xFilial("SD2") } )
			aAdd( aBind, { 'A', { DtoS(dDatabase-1), DtoS(dDatabase)} } )
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, { 'C', '*' } )
		endif

	endif

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())

		if aScan( aProdutos, (cAl)->B1_COD ) == 0
			aAdd( aProdutos, (cAl)->B1_COD )

			nRegs++
			aQAtuCust := OFCNHA012C_getQAtuCust( (cAl)->B1_COD, nParam03, aLocais, lSBZ )

			reclock('VBC', .T.)
			VBC->VBC_FILIAL := xFilial('VBC')
			VBC->VBC_CODIGO := GetSxeNum('VBC', 'VBC_CODIGO'); confirmSx8()
			VBC->VBC_CODVBB := cCodVBB
			VBC->VBC_PRODUT := (cAl)->B1_COD
			VBC->VBC_QTDEST := aQAtuCust[1]
			VBC->VBC_QTDENC := 0
			VBC->VBC_BACKOR := 0
			VBC->VBC_CUSMED := aQAtuCust[2]
			VBC->VBC_ESTOCA := aQAtuCust[3]
			VBC->VBC_ESTMIN := aQAtuCust[4]
			VBC->VBC_QTDRES := 0
			VBC->VBC_FUTRES := 0
			VBC->VBC_DESPRO := left((cAl)->B1_DESC, nSizeDes)
			VBC->VBC_CODFOR := ''
			VBC->VBC_FORNAM := ''
			VBC->VBC_NUMSEQ := (cAl)->NUMSEQ
			VBC->(MsUnlock())

			if lDebug
				cPrdList += iif( empty(cPrdList), "", ", " ) + alltrim(VBC->VBC_PRODUT)
			endif
		endif

		cSD1Max := iif( (cAl)->ORIGEM == "SD1" .and. (cAl)->NUMSEQ > cSD1Max, (cAl)->NUMSEQ, cSD1Max )
		cSD2Max := iif( (cAl)->ORIGEM == "SD2" .and. (cAl)->NUMSEQ > cSD2Max, (cAl)->NUMSEQ, cSD2Max )
		cSD3Max := iif( (cAl)->ORIGEM == "SD3" .and. (cAl)->NUMSEQ > cSD3Max, (cAl)->NUMSEQ, cSD3Max )

		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado

	if lDebug
		cMsgLog += CRLF + STR0023 +" ["+ STR0024 +" "+cArm+"]: " + cPrdList + CRLF + CRLF	// #Produtos	#Armazém
	endif

	if nRegs > 0
		oLogger:Log({"TIMESTAMP","  |> "+STR0025})	// #Iniciando Preenchimento dos dados de estoque
		OFCNHA0107_PreencheEstoque(cCodVBB, cArm)
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado
	endif
return .T.


/*/{Protheus.doc} OFCNHA0104_GeraVendas
	Gera os dados de vendas do arquivo PRIM2

	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0104_GeraVendas(cArm, cTipoGer, dData1, dData2, cNumProgr, cDatDePrim1, cDatAtePrim1)
local cQuery   := ''
local cCodMerc := oConf:cMarket
local cCodCorp := oConf:cDealerCode
local aGrupos  := { "NAOTRAZERNADA" }
local nI
local cCondD1
local cCondD2
local cCondD3
local cCondVB2
local aBind
Private cPrefBal    := GetNewPar("MV_PREFBAL","BAL")
Private cPrefOfi    := GetNewPar("MV_PREFOFI","OFI")

	for nI := 1 to len( oConf:oConfig["LOCAIS"] )
		if oConf:oConfig["LOCAIS"][nI]["WAREHOUSE"] == cArm
			aAdd( aGrupos, alltrim(oConf:oConfig["LOCAIS"][nI]["GRUPO"]) )
		endif
	next

	// se for geracao normal tenho que enviar somente o que ainda nao foi enviado
	if cTipoGer == oPrim:CodGerNormal()
		cCondD1  := " AND D1_NUMSEQ > '"+ cSD1Seq +"' "
		cCondD2  := " AND D2_NUMSEQ > '"+ cSD2Seq +"' "
		cCondD3  := " AND D3_NUMSEQ > '"+ cSD3Seq +"' "
		cCondVB2 := " AND VB2_DATMOV > '"+ DtoS(dDatabase-3) +"' "				/// avaliar
	else
		cCondD1  := " AND D1_DTDIGIT BETWEEN '"+DTOS(dData1)+"' AND '"+DTOS(dData2)+"' "
		cCondD2  := " AND D2_EMISSAO BETWEEN '"+DTOS(dData1)+"' AND '"+DTOS(dData2)+"' "
		cCondD3  := " AND D3_EMISSAO BETWEEN '"+DTOS(dData1)+"' AND '"+DTOS(dData2)+"' "
		cCondVB2 := " AND VB2_DATMOV BETWEEN '"+DTOS(dData1)+"' AND '"+DTOS(dData2)+"' "
	endif

	oLogger:Log({"TIMESTAMP",STR0027})	//#"Coletando peças movimentadas"
	// gera cache das pecas desta geracao pela data, verificando pecas movimentadas nas datas de inicio e fim
	aBind  := {}
	cQuery := "UPDATE "+retsqlname('VBF')+" SET VBF_FLGARQ = ? WHERE VBF_PRODUT IN (" 
	cQuery += 	" SELECT D1_COD FROM " + oSqlHlp:Nolock('SD1')
	cQuery +=       " join "+retSqlName("SF4")+" SF4 on F4_FILIAL=? and F4_CODIGO=D1_TES and F4_ESTOQUE=? and SF4.D_E_L_E_T_=?"
	cQuery += 		" WHERE D1_FILIAL=? " + cCondD1 // removi os D_E_L_E_T_  pq significam cancelados
	cQuery +=       " and D1_GRUPO in (?)"
	cQuery += 	" UNION "
	cQuery += 	" SELECT D2_COD FROM " + oSqlHlp:Nolock('SD2')
	cQuery +=       " join "+retSqlName("SF4")+" SF4 on F4_FILIAL=? and F4_CODIGO=D2_TES and F4_ESTOQUE=? and SF4.D_E_L_E_T_=?"
	cQuery +=       " WHERE D2_FILIAL=? " + cCondD2 // removi os D_E_L_E_T_  pq significam cancelados
	cQuery +=       " and D2_GRUPO in (?)"
	cQuery += " ) AND VBF_FLGUSO=? AND D_E_L_E_T_=?" // criando cache
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("SD1") } )
	aAdd( aBind, { 'A', aGrupos } )
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("SD2") } )
	aAdd( aBind, { 'A', aGrupos } )
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0066)	//#"Erro de sql detectado ao coletar peças movimentadas no período."
	oLogger:Log({"TIMESTAMP",STR0020})	// #Finalizado

	reclock('VBB', .T.)
	VBB->VBB_FILIAL  := xFilial('VBB')
	VBB->VBB_CODIGO  := GetSxeNum('VBB', 'VBB_CODIGO'); confirmSx8()
	VBB->VBB_CATREG  := 'T'
	VBB->VBB_IDENTI  := 'SE' // SE=Venda, ST=Estoque
	VBB->VBB_DATA   := SToD(LEFT(cUltExt, 8))
	VBB->VBB_HORA   := RIGHT( cUltExt, 6)
	VBB->VBB_DATA2  := SToD(LEFT(cDatExt, 8))
	VBB->VBB_HORA2  := RIGHT( cDatExt , 6)
	VBB->VBB_CODCOR  := '01' // fixo
	VBB->VBB_CODMER  := cCodMerc
	VBB->VBB_CODUNI  := cCodCorp
	VBB->VBB_LOCCNH   := cArm
	VBB->VBB_CATTRA  := cTipoGer
	VBB->VBB_FILEQU  := 0
	VBB->VBB_NUMTRA  := 0
	VBB->VBB_NUMREG  := 0
	VBB->VBB_CODPRG  := cNumProgr
	VBB->VBB_TIPGER  := oPrim:CodArqVen()
	VBB->(MsUnlock())

	OFCNHA0105GeraItensVendas(cArm, VBB->VBB_CODIGO, dData1, dData2, cTipoGer, aGrupos)
	AADD(aVBBs, VBB->VBB_CODIGO)
return .T.


/*/{Protheus.doc} OFCNHA0105GeraItensVendas
	Gera cabecalho das vendas

	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0105GeraItensVendas(cArm, cCodVBB, dDataIni, dDataFim, cTipoGer, aGrupos)
local cQuery     := ''
local cAl        := GetNextAlias()
local nI
local aOrcs      := {}
local nItem
local nRegs      := 0
local aBind      := {}

	oLogger:Log({"TIMESTAMP","  |> "+STR0028})	//#"Gerando Registros de transferencias"
	cQuery := "select D2_ITEM, D2_DOC, D2_SERIE, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_CLIENTE, D2_LOJA, D2_EMISSAO,"
	cQuery += " VS1_DATORC, VS1_NUMORC, VS1_MOTCOM, VS1_TIPTEM,"
	cQuery += " VS3_SEQUEN, VS3_CODSIT,"
	cQuery += " D2_NUMSEQ"
	cQuery += " FROM "+retSqlName('SD2')+" SD2 "
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL  = ? AND D2_TES = F4_CODIGO  AND SF4.D_E_L_E_T_ = ?"
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', ' ' } )
	if cArm == "F01"	// armazéns gerenciados
//	if cArm != "D01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON  VBF_FILIAL = ? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF_ARMZEM = ? AND VBF.D_E_L_E_T_ = ?"
		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON  VBF_FILIAL = ? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?"
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " JOIN "+retSqlName('SF2')+" SF2 on F2_FILIAL = D2_FILIAL AND D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ?"
	cQuery += " JOIN "+retSqlName('VS1')+" VS1 on VS1_FILIAL = D2_FILIAL AND VS1_TIPORC = ? AND VS1_NUMNFI = D2_DOC AND VS1_SERNFI = D2_SERIE AND VS1.D_E_L_E_T_ = ?"
	cQuery += " JOIN "+retSqlName('VS3')+" VS3 on VS3_FILIAL = D2_FILIAL AND VS3_NUMORC = VS1_NUMORC AND VS3_CODITE = D2_COD AND VS1.D_E_L_E_T_ = ?"
	cQuery += " WHERE F2_FILIAL  = ?"
	cQuery  += " AND D2_GRUPO IN (?)"
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '3' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('SF2') } )
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " AND SD2.D2_NUMSEQ  > ?"

		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL = ?"
		cQuery += 		" and   DELTA.VBD_PRODUT = D2_COD"
		cQuery += 		" and   DELTA.VBD_NUMNFI = D2_DOC"
		cQuery += 		" and   DELTA.VBD_SERORI = D2_SERIE"
		cQuery += 		" and   DELTA.VBD_CODCLI = D2_CLIENTE"
		cQuery += 		" and   DELTA.VBD_LOJCLI = D2_LOJA"
		cQuery += 		" and   DELTA.VBD_QTDFAT = D2_QUANT"
		cQuery += 		" and   DELTA.VBD_INDDEV = ?"
		cQuery += 		" and   DELTA.VBD_INDCAN = ?"
		cQuery += 		" and   DELTA.D_E_L_E_T_ = ?"
		cQuery += " ) "
		aAdd( aBind, { 'C', cSD2SEQ} )
		aAdd( aBind, { 'C', xFilial('VBD')} )
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		aAdd( aBind, { 'C', oPrim:CodNaoCanc()} )
		aAdd( aBind, { 'C', ' '} )
	else
		cQuery += " AND SD2.D2_EMISSAO between ? AND ? "
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND SD2.D_E_L_E_T_ = ?"
	aAdd( aBind, { 'C', ' '} )

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		nRegs++
		reclock('VBD', .T.)
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_CODCLI := (cAl)->D2_CLIENTE
		VBD->VBD_LOJCLI := (cAl)->D2_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMNFI := (cAl)->D2_DOC
		VBD->VBD_SERORI := (cAl)->D2_SERIE
		VBD->VBD_NUMREM := VBD->VBD_NUMNFI
		VBD->VBD_DATORI := iif( Empty( (cAl)->VS1_DATORC ), STOD((cAl)->D2_EMISSAO), STOD( (cAl)->VS1_DATORC ) )
//		VBD->VBD_LINVEN := iif( Empty( (cAl)->VS1_DATORC ), VAL( (cAl)->D2_ITEM )  , VAL( (cAl)->VS3_SEQUEN ) )
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->D2_COD,;
												iif( Empty( (cAl)->VS1_DATORC ), "", (cAl)->VS1_NUMORC ),;
												VBD->VBD_NUMNFI,;
												VBD->VBD_SERORI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->D2_QUANT,;
												iif( Empty( (cAl)->VS1_DATORC ), VAL( (cAl)->D2_ITEM ), VAL( (cAl)->VS3_SEQUEN ) ) )

		VBD->VBD_NUMORI := iif( Empty( (cAl)->VS1_DATORC ), ""                     , (cAl)->VS1_NUMORC )
		VBD->VBD_MOTCOM := iif( Empty( (cAl)->VS1_DATORC ), ""                     , (cAl)->VS1_MOTCOM )
		VBD->VBD_DATNFI := STOD( (cAl)->D2_EMISSAO )
		VBD->VBD_CANALV := oCanalVenda:CanalTransf()
		VBD->VBD_PRODUT := (cAl)->D2_COD
		VBD->VBD_QTDFAT := (cAl)->D2_QUANT
		VBD->VBD_QTDPED := (cAl)->D2_QUANT // Será regravado se tiver pedido com a quantidade corretamente pedida pelo cliente para calculo do NA
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_TIPDEM := oPrim:getDemanda( (cAl)->VS3_CODSIT )			// oPrim:CodVendNor()
		VBD->VBD_INDCAN := oPrim:CodNaoCanc()
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_VALVDA := (cAl)->D2_PRCVEN
		VBD->VBD_CODGAR := 'Z' // venda normal
		VBD->VBD_ALIAS  := "SD2"
		VBD->VBD_NUMSEQ := (cAl)->D2_NUMSEQ
		VBD->VBD_TIPTEM := (cAl)->VS1_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0029})	// #"Gerando Registros de vendas balcão"
	aBind := {}
	cQuery := "select D2_ITEM, D2_DOC, D2_SERIE, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_CLIENTE, D2_LOJA, D2_EMISSAO,"
	cQuery += " VS1_DATORC, VS1_NUMORC, VS1_MOTCOM, VS1_NUMNFI, VS1_SERNFI, VS1_INDPRE, VS1_TIPTEM,"
	cQuery += " VS3_SEQUEN, VS3_QTDINI, VS3_QTDITE, VS3_CODSIT,"
	cQuery += " D2_NUMSEQ "
	cQuery += " FROM "+retSqlName('SD2') + " SD2 "
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL = ? AND D2_TES = F4_CODIGO AND F4_OPEMOV = ? AND SF4.D_E_L_E_T_ = ?"
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', '05' } )
	aAdd( aBind, { 'C', ' ' } )
	if cArm == "F01"	// armazéns gerenciados
//	if cArm != "D01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL = ? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF_ARMZEM = ? AND VBF.D_E_L_E_T_ = ?"
		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL = ? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?"
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " JOIN "+retSqlName('SF2')+" SF2 ON F2_FILIAL = D2_FILIAL AND D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE AND F2_PREFORI = ? AND SF2.D_E_L_E_T_ = ?"
	cQuery += " JOIN "+retSqlName('VS1')+" VS1 on VS1_FILIAL = D2_FILIAL AND VS1_TIPORC = ? AND VS1_NUMNFI = D2_DOC AND VS1_SERNFI = D2_SERIE AND VS1.D_E_L_E_T_ = ?"
	cQuery += " JOIN "+retSqlName('VS3')+" VS3 on VS3_FILIAL = D2_FILIAL AND VS3_NUMORC = VS1_NUMORC AND VS3_CODITE = D2_COD AND VS1.D_E_L_E_T_ = ?"
	cQuery += " WHERE F2_FILIAL = ?"
	cQuery  += " AND D2_GRUPO IN (?)"
	aAdd( aBind, { 'C', cPrefBal } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('SF2') } )
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " AND D2_NUMSEQ  > ?"

		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL = ?"
		cQuery += 		" and   DELTA.VBD_PRODUT = D2_COD"
		cQuery += 		" and   DELTA.VBD_NUMNFI = VS1_NUMNFI"
		cQuery += 		" and   DELTA.VBD_SERORI = VS1_SERNFI"
		cQuery += 		" and   DELTA.VBD_CODCLI = D2_CLIENTE"
		cQuery += 		" and   DELTA.VBD_LOJCLI = D2_LOJA"
		cQuery += 		" and   DELTA.VBD_QTDFAT = D2_QUANT"
		cQuery += 		" and   DELTA.VBD_QTDPED = D2_QUANT"		
		//cQuery += 		" and   DELTA.VBD_QTDPED = VS3_QTDINI"
		cQuery += 		" and   DELTA.VBD_INDDEV = ?"
		cQuery += 		" and   DELTA.VBD_INDCAN = ?"
		cQuery += 		" and   DELTA.D_E_L_E_T_ = ?"
		cQuery += " ) "
		aAdd( aBind, { 'C', cSD2SEQ} )
		aAdd( aBind, { 'C', xFilial('VBD')} )
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		aAdd( aBind, { 'C', oPrim:CodNaoCanc()} )
		aAdd( aBind, { 'C', ' '} )
	else
		cQuery += " AND SD2.D2_EMISSAO between ? AND ? "
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND SD2.D_E_L_E_T_ = ?"
	aAdd( aBind, { 'C', ' '} )

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		nRegs++
		reclock('VBD', .T.)
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_CODCLI := (cAl)->D2_CLIENTE
		VBD->VBD_LOJCLI := (cAl)->D2_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMNFI := (cAl)->VS1_NUMNFI
		VBD->VBD_SERORI := (cAl)->VS1_SERNFI
		VBD->VBD_NUMREM := VBD->VBD_NUMNFI
		VBD->VBD_NUMORI := (cAl)->VS1_NUMORC
		VBD->VBD_DATORI := STOD( iif( empty((cAl)->VS1_DATORC), (cAl)->D2_EMISSAO, (cAl)->VS1_DATORC ) )
//		VBD->VBD_LINVEN := VAL(  iif( empty((cAl)->VS3_SEQUEN), (cAl)->D2_ITEM   , (cAl)->VS3_SEQUEN ) )
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->D2_COD,;
												VBD->VBD_NUMORI,;
												VBD->VBD_NUMNFI,;
												VBD->VBD_SERORI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->D2_QUANT,;
												iif( Empty( (cAl)->VS3_SEQUEN ), VAL( (cAl)->D2_ITEM )  , VAL( (cAl)->VS3_SEQUEN ) ) )

		VBD->VBD_DATNFI := STOD( (cAl)->D2_EMISSAO )
		VBD->VBD_CANALV := oCanalVenda:retCanal( cPrefBal, "05", (cAl)->VS3_CODSIT, (cAl)->VS1_INDPRE, VBD->VBD_CODCLI, VBD->VBD_LOJCLI )			// oCanalVenda:CanalBalcao()
		VBD->VBD_PRODUT := (cAl)->D2_COD
		VBD->VBD_QTDFAT := (cAl)->D2_QUANT
		//VBD->VBD_QTDPED := (cAl)->VS3_QTDINI		
		VBD->VBD_QTDPED := (cAl)->D2_QUANT
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_TIPDEM := oPrim:getDemanda( (cAl)->VS3_CODSIT )				// oPrim:CodVendNor()
		VBD->VBD_INDCAN := oPrim:CodNaoCanc()
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_MOTCOM := (cAl)->VS1_MOTCOM
		VBD->VBD_VALVDA := (cAl)->D2_PRCVEN
		VBD->VBD_CODGAR := 'Z' // venda normal
		VBD->VBD_ALIAS  := "SD2"
		VBD->VBD_NUMSEQ := (cAl)->D2_NUMSEQ
		VBD->VBD_TIPTEM := (cAl)->VS1_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0030})	// #"Iniciando geracao de registros de oficina"
	// OFICINA
	aBind  := {}
	cQuery := "select * FROM ("
	cQuery += "SELECT D2_PRCVEN, D2_QUANT, D2_ITEM, VOO_NUMOSV, VO1_DATABE, VOI_SITTPO, D2_CLIENTE, D2_LOJA, VOO_NUMNFI, VOO_SERNFI, D2_EMISSAO, D2_COD, VO1_CHASSI,"
	cQuery += "VV1_MODVEI, VO1_KILOME, VV1_CODMAR, VO1_MOTCOM, D2_NUMSEQ, 'OFI' ORIGEM, D2_GRUPO, VO3_QTDREQ, VO3_CODSIT, VOO_TIPTEM, VO3_NOSNUM"
	cQuery += " FROM "+retSqlName('SD2')+" SD2 "
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND D2_TES = F4_CODIGO AND F4_OPEMOV=? AND SF4.D_E_L_E_T_=?"
	cQuery += " JOIN "+retSqlName('VOO')+" VOO ON VOO_FILIAL=? AND VOO_SERNFI = D2_SERIE AND VOO_NUMNFI = D2_DOC AND VOO.D_E_L_E_T_=?"
	cQuery += " JOIN "+retSqlName('VO1')+" VO1 ON VO1_FILIAL=? AND VO1_NUMOSV = VOO_NUMOSV AND VO1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', '05' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("VOO") } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("VO1") } )
	aAdd( aBind, { 'C', ' ' } )
//	cQuery += " JOIN "+retSqlName('VO3')+" VO3 ON VO3_FILIAL=VO1_FILIAL AND VO3_NUMOSV = VO1_NUMOSV AND VO3_CODITE = D2_COD AND VO3.D_E_L_E_T_=?"
	cQuery += " JOIN ("
	cQuery += 		"select "
	cQuery += 			" VO3_FILIAL, VO3_CODITE, VO3_NUMOSV, VO3_CODSIT, max(VO3_NOSNUM) VO3_NOSNUM,"
	cQuery += 			" SUM(CASE WHEN VO2_DEVOLU=? THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) VO3_QTDREQ"
	aAdd( aBind, { 'C', '1' } )
	cQuery += 		" FROM "+retSqlName('VO3')+" VO3"
	cQuery += 		" JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL =? AND F4_CODIGO = VO3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=? AND VO2_NOSNUM=VO3_NOSNUM AND VO2_TIPREQ=? AND VO2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VO2") } )
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" WHERE VO3.VO3_FILIAL=?"
	cQuery += 		" AND VO3.D_E_L_E_T_=?"
//	cQuery += 		" AND VO3_DATFEC=?"
//	cQuery += 		" AND VO3_DATCAN=?"
	aAdd( aBind, { 'C', xFilial("VO3") } )
	aAdd( aBind, { 'C', ' ' } )
//	aAdd( aBind, { 'C', ' ' } )
//	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" GROUP BY VO3_FILIAL, VO3_CODITE, VO3_NUMOSV, VO3_CODSIT"
	cQuery += ") VO3S ON VO3_FILIAL=VO1_FILIAL AND VO3_NUMOSV = VO1_NUMOSV AND VO3_CODITE = D2_COD "

	cQuery += " JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT = VO1_CHAINT AND VV1.D_E_L_E_T_=?"

	aAdd( aBind, { 'C', xFilial("VV1") } )
	aAdd( aBind, { 'C', ' ' } )
	if cArm == "F01"	// armazéns gerenciados
//	if cArm != "D01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF_ARMZEM=? AND VBF.D_E_L_E_T_=?"
		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial("VBF") } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VOO_TIPTEM = VOI_TIPTEM AND VOI.D_E_L_E_T_=?"
	cQuery += " WHERE SD2.D2_FILIAL=?"
	cQuery += " AND SD2.D_E_L_E_T_=? "
	cQuery += CRLF + " UNION ALL " + CRLF
	cQuery += OFCNHA014C_getQryRes( cArm ) + CRLF		// Obtém reservas
	cQuery += ") TEMP "
	cQuery += " WHERE D2_GRUPO IN (?)"
	aAdd( aBind, { 'C', xFilial("VOI") } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("SD2") } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " AND ( D2_NUMSEQ > ? OR D2_NUMSEQ=? )"

		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL=?"
		cQuery += 		" and   DELTA.VBD_PRODUT = D2_COD"
		cQuery += 		" and   DELTA.VBD_NUMORI = VOO_NUMOSV"
		cQuery += 		" and   DELTA.VBD_NUMNFI = VOO_NUMNFI"
		cQuery += 		" and   DELTA.VBD_SERORI = VOO_SERNFI"
//		cQuery += 		" and   DELTA.VBD_NUMREM = VO3_NOSNUM"
		cQuery += 		" and   DELTA.VBD_CODCLI = D2_CLIENTE"
		cQuery += 		" and   DELTA.VBD_LOJCLI = D2_LOJA"
		cQuery += 		" and   DELTA.VBD_QTDFAT = D2_QUANT"
		cQuery += 		" and   DELTA.VBD_TIPTEM = VOO_TIPTEM"		// Tipo de Tempo
		cQuery += 		" and   DELTA.VBD_INDDEV=?"
		cQuery += 		" and   DELTA.VBD_INDCAN=?"
		cQuery += 		" and   DELTA.D_E_L_E_T_=?"
		cQuery += " ) "
		aAdd( aBind, { 'C', cSD2SEQ} )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
		aAdd( aBind, { 'C', ' ' } )
	else
		cQuery += " AND ( D2_EMISSAO BETWEEN ? AND ? OR D2_EMISSAO=? )"
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " ORDER BY VOO_NUMOSV,D2_COD"

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		nRegs++
		aAdd( aOrcs, (cAl)->VOO_NUMOSV )
		nItem := 0
		for nI := 1 to len( aOrcs )
			nItem += iif( aOrcs[nI] == (cAl)->VOO_NUMOSV, 1, 0)
		next
		reclock('VBD', .T.)
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODCLI := (cAl)->D2_CLIENTE
		VBD->VBD_LOJCLI := (cAl)->D2_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMORI := (cAl)->VOO_NUMOSV
//		VBD->VBD_LINVEN := iif( empty((cAl)->D2_ITEM), nItem, val( (cAl)->D2_ITEM ) )
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->D2_COD,;
												VBD->VBD_NUMORI,;
												(cAl)->VOO_NUMNFI,;
												(cAl)->VOO_SERNFI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->D2_QUANT,;
												iif( Empty( (cAl)->D2_ITEM ), nItem, VAL( (cAl)->D2_ITEM ) ) )

		VBD->VBD_NUMNFI := (cAl)->VOO_NUMNFI
		VBD->VBD_SERORI := (cAl)->VOO_SERNFI
		VBD->VBD_NUMREM := (cAl)->VO3_NOSNUM		//VBD->VBD_NUMNFI
		VBD->VBD_DATORI := STOD( (cAl)->VO1_DATABE )
		VBD->VBD_DATNFI := STOD( (cAl)->D2_EMISSAO )
		VBD->VBD_PRODUT := (cAl)->D2_COD
		VBD->VBD_QTDFAT := (cAl)->D2_QUANT
		VBD->VBD_QTDPED := (cAl)->VO3_QTDREQ // oficina não tem NA
		VBD->VBD_TIPDEM := oPrim:getDemanda( (cAl)->VO3_CODSIT )
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_INDCAN := oPrim:CodNaoCanc()
		VBD->VBD_CHASSI := (cAl)->VO1_CHASSI
		VBD->VBD_MODELO := LEFT( (cAl)->VV1_MODVEI, tamsx3('VBD_MODELO')[1] )
		VBD->VBD_HORKIL := (cAl)->VO1_KILOME
		VBD->VBD_FABRIC := (cAl)->VV1_CODMAR
		VBD->VBD_MOTCOM := (cAl)->VO1_MOTCOM
		VBD->VBD_VALVDA := (cAl)->D2_PRCVEN
		VBD->VBD_CODGAR := iif( (cAl)->VOI_SITTPO == "3", 'D', 'Z' )	// D=consumo interno;Z=venda normal
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_CANALV := oCanalVenda:retCanal( (cAl)->ORIGEM, "05", NIL, NIL, VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_ALIAS  := iif( empty((cAl)->D2_NUMSEQ), "RES", "SD2" )
		VBD->VBD_NUMSEQ := (cAl)->D2_NUMSEQ
		VBD->VBD_TIPTEM := (cAl)->VOO_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 1"})	// # cancelados 1
	aBind  := {}
	cQuery := "select VS1_NUMORC, VS1_TIPORC, VS1_CLIFAT, VS1_LOJA, VS1_NCLIFT, VS1_NUMNFI, VS1_SERNFI, VS1_DATORC, VS1_MOTCOM, VV1_CODMAR, VV1_MODVEI, VS1_KILOME,"
	cQuery += " VS3_SEQUEN, VS3_CODITE, VS3_QTDITE, VS3_QTDINI, VS3_VALPEC,"
	cQuery += " F2_EMISSAO,"
	cQuery += " D2_QUANT,"
	cQuery += " VV1_CHASSI, VV1_CODMAR, VV1_MODVEI,"
	cQuery += " VOI_SITTPO,"
	cQuery += " VBD.*"
	cQuery += " from "+retSqlName("VS1")+" VS1 "
	cQuery += " join "+retSqlName("VS3")+" VS3 "
	cQuery += 	" on  VS3_FILIAL=VS1_FILIAL"
	cQuery += 	" and VS3_NUMORC=VS1_NUMORC"
	cQuery +=   " and VS3.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " left join "+retSqlName('VOI')+" VOI "
	cQuery += 	" on  VOI_FILIAL=?"
	cQuery += 	" and VOI_TIPTEM = VS1_TIPTEM"
	cQuery += 	" and VOI.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VOI") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " left join "+retSqlName("SF2")+" SF2 "
	cQuery += 	" on  F2_FILIAL = VS1_FILIAL"
	cQuery += 	" and F2_DOC    = VS1_NUMNFI"
	cQuery += 	" and F2_SERIE  = VS1_SERNFI"
	cQuery +=   " and SF2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " left join "+retSqlName("SD2")+" SD2 "
	cQuery += 	" on  D2_FILIAL = VS1_FILIAL"
	cQuery += 	" and D2_DOC    = VS1_NUMNFI"
	cQuery += 	" and D2_SERIE  = VS1_SERNFI"
	cQuery += 	" and D2_COD    = VS3_CODITE"
	cQuery +=   " and SD2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " left join "+retSqlName("VV1")+" VV1 "
	cQuery += 	" on  VV1_FILIAL=?"
	cQuery += 	" and VV1_CHAINT = VS1_CHAINT"
	cQuery +=   " and VV1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VV1") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('VBD')+" VBD "	// encontrar a venda antes
	cQuery +=   " ON  VBD_FILIAL=?" 
	cQuery += 	" AND VBD_CODIGO = ("
	cQuery += 		" select MAX(VBD_CODIGO)"
	cQuery += 		" from "+retSqlName("VBD")
	cQuery += 		" where VBD_FILIAL=?"
	cQuery += 		" AND VBD_PRODUT = VS3_CODITE"
	cQuery += 		" AND VBD_NUMORI = VS1_NUMORC"
	cQuery += 		" AND VBD_SERORI = VS1_SERNFI"
	cQuery +=   	" AND VBD_INDDEV <> ?"
	cQuery +=   	" AND VBD_INDCAN <> ?"
	cQuery += 		" AND D_E_L_E_T_=?"
	cQuery += 	")"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	aAdd( aBind, { 'C', xFilial("VBD") } )
	aAdd( aBind, { 'C', oPrim:CodDev() } )
	aAdd( aBind, { 'C', oPrim:CodCanc() } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " where VS1_FILIAL=?"
	cQuery += " and   VS1_STATUS <> ?"			// excluir Loja
	cQuery += " and   VS3_MOTPED <> ?"			// Item cancelado
	cQuery += " and   VS3_GRUITE IN (?)"
	aAdd( aBind, { 'C', xFilial("VS1") } )
	aAdd( aBind, { 'C', 'X' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL=?"
		cQuery += 		" and   DELTA.VBD_PRODUT = VS3_CODITE"
		cQuery += 		" and   DELTA.VBD_NUMORI = VS1_NUMORC"
		cQuery += 		" and   DELTA.VBD_NUMNFI = VS1_NUMNFI"
		cQuery += 		" and   DELTA.VBD_SERORI = VS1_SERNFI"
		cQuery += 		" and   DELTA.VBD_CODCLI = VS1_CLIFAT"
		cQuery += 		" and   DELTA.VBD_LOJCLI = VS1_LOJA"
		cQuery += 		" and   DELTA.VBD_QTDFAT = VS3_QTDINI"
		cQuery += 		" and   DELTA.VBD_INDCAN=?"
		cQuery += 		" and   DELTA.D_E_L_E_T_=?"
		cQuery += ")"
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )
	else
		cQuery += " AND VS1_DATORC BETWEEN ? AND ?"
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif

	cQuery += " and VS1.D_E_L_E_T_=?"
	cQuery += " order by VS1_NUMORC, VS3_CODITE"
	aAdd( aBind, { 'C', ' ' } )

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		reclock('VBD', .T.)
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODCLI := (cAl)->VS1_CLIFAT
		VBD->VBD_LOJCLI := (cAl)->VS1_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMORI := (cAl)->VS1_NUMORC
		VBD->VBD_SERORI := (cAl)->VS1_SERNFI
//		VBD->VBD_LINVEN := val( (cAl)->VS3_SEQUEN )
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->VS3_CODITE,;
												VBD->VBD_NUMORI,;
												(cAl)->VS1_NUMNFI,;
												(cAl)->VS1_SERNFI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->VS3_QTDINI,;
												val( (cAl)->VS3_SEQUEN ) )

		VBD->VBD_NUMREM := (cAl)->VS1_NUMNFI
		VBD->VBD_NUMNFI := (cAl)->VS1_NUMNFI
		VBD->VBD_DATORI := stod( (cAl)->VS1_DATORC )
		VBD->VBD_DATREM := stod((cAl)->F2_EMISSAO)
		VBD->VBD_DATNFI := stod((cAl)->F2_EMISSAO)
		VBD->VBD_CANALV := (cAl)->VBD_CANALV
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_PRODUT := (cAl)->VS3_CODITE
		VBD->VBD_QTDPED := (cAl)->VS3_QTDINI
		VBD->VBD_QTDREM := (cAl)->VS3_QTDINI
		VBD->VBD_QTDFAT := (cAl)->VS3_QTDINI
		VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
		VBD->VBD_CHASSI := (cAl)->VV1_CHASSI
		VBD->VBD_HORKIL := (cAl)->VS1_KILOME
		VBD->VBD_FABRIC := (cAl)->VV1_CODMAR
		VBD->VBD_MODELO := LEFT( (cAl)->VV1_MODVEI, tamsx3('VBD_MODELO')[1] )
		VBD->VBD_MOTCOM := (cAl)->VS1_MOTCOM
		VBD->VBD_VALVDA := (cAl)->VS3_VALPEC
		VBD->VBD_INDCAN := oPrim:CodCanc()
		VBD->VBD_CODGAR := iif( (cAl)->VOI_SITTPO=="3", 'D' /*consumo interno*/, 'Z' /*venda normal*/ )
		VBD->VBD_ALIAS  := "VS3"
		VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 2"})	// # cancelados 2 - Reservas
	aBind  := {}
	cQuery := "select VS1_NUMORC, VS1_TIPORC, VS1_CLIFAT, VS1_LOJA, VS1_NCLIFT, VS1_NUMNFI, VS1_SERNFI, VS1_DATORC, VS1_MOTCOM, VS1_KILOME,"
	cQuery += " VBD.*"
	cQuery += " from "+retSqlName("VS1")+" VS1 "
	cQuery += " join "+retSqlName("VB2")+" VB2 "
	cQuery += 	" on  VB2_FILIAL=VS1_FILIAL"
	cQuery += 	" and VB2_NUMORC=VS1_NUMORC"
	cQuery +=   " and VB2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('VBD')+" VBD "	// encontrar a venda antes
	cQuery +=   " ON  VBD_FILIAL=?"
	cQuery += 	" AND VBD_CODIGO = ("
	cQuery += 		" select MAX(VBD_CODIGO)"
	cQuery += 		" from "+retSqlName("VBD")
	cQuery += 		" where VBD_FILIAL=?"
	cQuery += 		" AND VBD_PRODUT = VB2_CODITE"
	cQuery += 		" AND VBD_NUMORI = VS1_NUMORC"
	cQuery += 		" AND VBD_SERORI = VS1_SERNFI"
	cQuery += 		" AND VBD_QTDFAT = VB2_QUANT"
	cQuery +=   	" AND VBD_INDDEV <> ?"
	cQuery +=   	" AND VBD_INDCAN <> ?"
	cQuery += 		" AND D_E_L_E_T_=?"
	cQuery += 	")"
	aAdd( aBind, { 'C', xFilial('VBD') } )
	aAdd( aBind, { 'C', xFilial('VBD') } )
	aAdd( aBind, { 'C', oPrim:CodDev() } )
	aAdd( aBind, { 'C', oPrim:CodCanc() } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " where VS1_FILIAL=?"
	cQuery += " and   VS1_STATUS <> ?"			// excluir Loja
	cQuery += " and   VB2_TIPDEV <> ?"			// item Des-reservado
	cQuery += " and   VB2_GRUITE IN (?)"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', 'X' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL=?"
		cQuery += 		" and   DELTA.VBD_PRODUT = VB2_CODITE"
		cQuery += 		" and   DELTA.VBD_NUMORI = VS1_NUMORC"
		cQuery += 		" and   DELTA.VBD_NUMNFI = VS1_NUMNFI"
		cQuery += 		" and   DELTA.VBD_SERORI = VS1_SERNFI"
		cQuery += 		" and   DELTA.VBD_CODCLI = VS1_CLIFAT"
		cQuery += 		" and   DELTA.VBD_LOJCLI = VS1_LOJA"
		cQuery += 		" and   DELTA.VBD_QTDFAT = VB2_QUANT"
		cQuery += 		" and   DELTA.VBD_INDCAN=?"
		cQuery += 		" and   DELTA.D_E_L_E_T_=?"
		cQuery += ")"
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )
	else
		cQuery += " AND VS1_DATORC BETWEEN ? AND ?"
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif

	cQuery += " and VS1.D_E_L_E_T_=?"
	cQuery += " order by VS1_NUMORC, VB2_CODITE"
	aAdd( aBind, { 'C', ' ' } )

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		reclock('VBD', .T.)
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODCLI := (cAl)->VS1_CLIFAT
		VBD->VBD_LOJCLI := (cAl)->VS1_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMORI := (cAl)->VS1_NUMORC
		VBD->VBD_SERORI := (cAl)->VS1_SERNFI
		VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
		VBD->VBD_NUMREM := (cAl)->VS1_NUMNFI
		VBD->VBD_NUMNFI := (cAl)->VS1_NUMNFI
		VBD->VBD_DATORI := stod((cAl)->VS1_DATORC)
		VBD->VBD_DATREM := stod((cAl)->VBD_DATREM)
		VBD->VBD_DATNFI := stod((cAl)->VBD_DATNFI)
		VBD->VBD_CANALV := (cAl)->VBD_CANALV
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
		VBD->VBD_QTDPED := (cAl)->VBD_QTDPED
		VBD->VBD_QTDREM := (cAl)->VBD_QTDREM
		VBD->VBD_QTDFAT := (cAl)->VBD_QTDFAT
		VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
		VBD->VBD_CHASSI := (cAl)->VBD_CHASSI
		VBD->VBD_HORKIL := (cAl)->VBD_HORKIL
		VBD->VBD_FABRIC := (cAl)->VBD_FABRIC
		VBD->VBD_MODELO := (cAl)->VBD_MODELO
		VBD->VBD_MOTCOM := (cAl)->VS1_MOTCOM
		VBD->VBD_VALVDA := (cAl)->VBD_VALVDA
		VBD->VBD_INDCAN := oPrim:CodCanc()
		VBD->VBD_CODGAR := (cAl)->VBD_CODGAR
		VBD->VBD_ALIAS  := "VS3"
		VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 3"})	//#"Criando registros cancelados" --- exclusão NF de Saída
	cCampos := "  VBD_CODCLI,VBD_LOJCLI,VBD_CDCLI2,VBD_NOMCLI,VBD_ENDCLI,"
	cCampos += "  VBD_CLICEP,VBD_CLCNPJ,VBD_NUMORI,VBD_SERORI,VBD_LINVEN,"
	cCampos += "  VBD_NUMREM,VBD_NUMNFI,VBD_DATORI,VBD_DATREM,VBD_DATNFI,"
	cCampos += "  VBD_CANALV,VBD_CODGAR,VBD_SUBCAN,VBD_PRODUT,VBD_QTDPED,"
	cCampos += "  VBD_QTDREM,VBD_QTDFAT,VBD_HORMOB,VBD_TIPDEM,VBD_INDDEV,"
	cCampos += "  VBD_CUSMED,VBD_CHASSI,VBD_HORKIL,VBD_FABRIC,VBD_MODELO,"
	cCampos += "  VBD_MOTCOM,VBD_CODVBG,VBD_VALVDA,D2_NUMSEQ, VBD_TIPTEM "

	aBind  := {}
	cQuery := "select " + cCampos
	cQuery += " FROM "+retSqlName('SD2')+ " SD2 "
	cQuery += " JOIN "+retSqlName('SF3')+" SF3 ON F3_FILIAL=? AND F3_NFISCAL = D2_DOC AND F3_SERIE = D2_SERIE AND SF3.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SF3") } )
	aAdd( aBind, { 'C', ' ' } )

	if cArm == "F01"	// armazéns gerenciados
//	if cArm != "D01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF_ARMZEM=? AND VBF.D_E_L_E_T_=?"
		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial("VBF") } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " JOIN "+retSqlName('VBD')+" VBD ON VBD_FILIAL=? AND VBD_PRODUT = D2_COD AND VBD_NUMNFI = D2_DOC AND VBD_SERORI = D2_SERIE AND VBD_INDDEV <> ? AND VBD_INDCAN <> ? AND VBD.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	aAdd( aBind, { 'C', oPrim:CodDev() } )
	aAdd( aBind, { 'C', oPrim:CodCanc() } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += "	AND VBD_CODIGO = ("
	cQuery += 	"	select MAX(VBD_CODIGO)"
	cQuery += 	"	from "+retSqlName("VBD")
	cQuery += 	"	where VBD_FILIAL=?"
	cQuery += 	"	AND VBD_PRODUT = D2_COD"
	cQuery += 	"	AND VBD_NUMNFI = D2_DOC"
	cQuery += 	"	AND VBD_SERORI = D2_SERIE"
	cQuery += 	"	AND VBD_INDDEV <> ?"
	cQuery += 	"	AND VBD_INDCAN <> ?"
	cQuery += 	"	AND D_E_L_E_T_=?"
	cQuery += ")"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', 'Y' } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " WHERE SD2.D2_FILIAL=?"
	cQuery += " AND D2_GRUPO IN (?)"
	aAdd( aBind, { 'C', xFilial("SD2") } )
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		// é enviado dia atual mais dia anterior por conta do horário
		// segundo victor da cnh, enviar repetido não causa problemas, pois é
		// sobrescrito o registro na base e não duplicado
		cQuery += " AND F3_DTCANC IN (?) "
		aAdd( aBind, { 'A', { DtoS(dDatabase-1), DtoS(dDatabase)} } )

		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL = VBD.VBD_FILIAL"
		cQuery += 		" and   DELTA.VBD_PRODUT = VBD.VBD_PRODUT"
		cQuery += 		" and   DELTA.VBD_NUMNFI = VBD.VBD_NUMNFI"
		cQuery += 		" and   DELTA.VBD_SERORI = VBD.VBD_SERORI"
		cQuery += 		" and   DELTA.VBD_CODCLI = VBD.VBD_CODCLI"
		cQuery += 		" and   DELTA.VBD_LOJCLI = VBD.VBD_LOJCLI"
		cQuery += 		" and   DELTA.VBD_QTDFAT = VBD.VBD_QTDFAT"
		cQuery += 		" and   DELTA.VBD_INDCAN = ?"
		cQuery += 		" and   DELTA.D_E_L_E_T_=?"
		cQuery += " ) "
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )

	else
		cQuery += " AND F3_DTCANC >= ? AND F3_DTCANC <= ?"
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND SD2.D_E_L_E_T_=?" // canceladas
	aAdd( aBind, { 'C', '*' } )
	cQuery += " GROUP BY " + cCampos

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		if ! Empty((cAl)->VBD_NOMCLI)
			reclock('VBD', .T.)
			VBD->VBD_CODVBB := cCodVBB
			VBD->VBD_FILIAL := xFilial('VBD')
			VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
			VBD->VBD_CODCLI := (cAl)->VBD_CODCLI
			VBD->VBD_LOJCLI := (cAl)->VBD_LOJCLI
			VBD->VBD_CDCLI2 := (cAl)->VBD_CDCLI2
			VBD->VBD_NOMCLI := (cAl)->VBD_NOMCLI
			VBD->VBD_ENDCLI := (cAl)->VBD_ENDCLI
			VBD->VBD_CLICEP := (cAl)->VBD_CLICEP
			VBD->VBD_CLCNPJ := (cAl)->VBD_CLCNPJ
			VBD->VBD_NUMORI := (cAl)->VBD_NUMORI
			VBD->VBD_SERORI := (cAl)->VBD_SERORI
			VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
			VBD->VBD_NUMREM := (cAl)->VBD_NUMREM
			VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI
			VBD->VBD_DATORI := stod((cAl)->VBD_DATORI)
			VBD->VBD_DATREM := stod((cAl)->VBD_DATREM)
			VBD->VBD_DATNFI := stod((cAl)->VBD_DATNFI)
			VBD->VBD_CANALV := (cAl)->VBD_CANALV
			VBD->VBD_SUBCAN := (cAl)->VBD_SUBCAN
			VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
			VBD->VBD_QTDPED := (cAl)->VBD_QTDPED
			VBD->VBD_QTDREM := (cAl)->VBD_QTDREM
			VBD->VBD_QTDFAT := (cAl)->VBD_QTDFAT
			VBD->VBD_HORMOB := (cAl)->VBD_HORMOB
			VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
			VBD->VBD_INDDEV := (cAl)->VBD_INDDEV
			VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
			VBD->VBD_CHASSI := (cAl)->VBD_CHASSI
			VBD->VBD_HORKIL := (cAl)->VBD_HORKIL
			VBD->VBD_FABRIC := (cAl)->VBD_FABRIC
			VBD->VBD_MODELO := (cAl)->VBD_MODELO
			VBD->VBD_MOTCOM := (cAl)->VBD_MOTCOM
			VBD->VBD_CODVBG := (cAl)->VBD_CODVBG
			VBD->VBD_VALVDA := (cAl)->VBD_VALVDA
			VBD->VBD_INDCAN := oPrim:CodCanc()
			VBD->VBD_CODGAR := (cAl)->VBD_CODGAR
			VBD->VBD_ALIAS  := "SD2"
			VBD->VBD_NUMSEQ := (cAl)->D2_NUMSEQ
			VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		endif
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	// COLOCAR AQUI TRATAMENTO PARA CANCELAMENTO DE SERVIÇOS
	oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 4"})	//#"Criando registros cancelados DE SERVIÇO" --- exclusão NF de Saída
	cCampos := "  VBD_CODCLI,VBD_LOJCLI,VBD_CDCLI2,VBD_NOMCLI,VBD_ENDCLI,"
	cCampos += "  VBD_CLICEP,VBD_CLCNPJ,VBD_NUMORI,VBD_SERORI,VBD_LINVEN,"
	cCampos += "  VBD_NUMREM,VBD_NUMNFI,VBD_DATORI,VBD_DATREM,VBD_DATNFI,"
	cCampos += "  VBD_CANALV,VBD_CODGAR,VBD_SUBCAN,VBD_PRODUT,VBD_QTDPED,"
	cCampos += "  VBD_QTDREM,VBD_QTDFAT,VBD_HORMOB,VBD_TIPDEM,VBD_INDDEV,"
	cCampos += "  VBD_CUSMED,VBD_CHASSI,VBD_HORKIL,VBD_FABRIC,VBD_MODELO,"
	cCampos += "  VBD_MOTCOM,VBD_CODVBG,VBD_VALVDA, VBD_TIPTEM "

	aBind  := {}
	cQuery := "select " + cCampos
	cQuery += " FROM "+retSqlName('VSC')+ " VSC "
	cQuery += " JOIN "+retSqlName('SF3')+" SF3 ON F3_FILIAL=? AND F3_NFISCAL = VSC_NUMNFI AND F3_SERIE = VSC_SERNFI AND SF3.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SF3") } )
	aAdd( aBind, { 'C', ' ' } )

	if cArm == "F01"	// armazéns gerenciados
		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = VSC_CODSER AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial("VBF") } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " JOIN "+retSqlName('VBD')+" VBD ON VBD_FILIAL=? AND VBD_PRODUT = VSC_CODSER AND VBD_NUMNFI = VSC_NUMNFI AND VBD_SERORI = VSC_SERNFI AND VBD_INDDEV <> ? AND VBD_INDCAN <> ? AND VBD.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	aAdd( aBind, { 'C', oPrim:CodDev() } )
	aAdd( aBind, { 'C', oPrim:CodCanc() } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += "	AND VBD_CODIGO = ("
	cQuery += 	"	select MAX(VBD_CODIGO)"
	cQuery += 	"	from "+retSqlName("VBD")
	cQuery += 	"	where VBD_FILIAL=?"
	cQuery += 	"	AND VBD_PRODUT = VSC_CODSER"
	cQuery += 	"	AND VBD_NUMNFI = VSC_NUMNFI"
	cQuery += 	"	AND VBD_SERORI = VSC_SERNFI"
	cQuery += 	"	AND VBD_INDDEV <> ?"
	cQuery += 	"	AND VBD_INDCAN <> ?"
	cQuery += 	"	AND D_E_L_E_T_=?"
	cQuery += ")"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', 'Y' } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " WHERE VSC_FILIAL=?"
	aAdd( aBind, { 'C', xFilial("VSC") } )

	if cTipoGer == oPrim:CodGerNormal()
		// é enviado dia atual mais dia anterior por conta do horário
		// segundo victor da cnh, enviar repetido não causa problemas, pois é
		// sobrescrito o registro na base e não duplicado
		cQuery += " AND F3_DTCANC IN (?) "
		aAdd( aBind, { 'A', { DtoS(dDatabase-1), DtoS(dDatabase)} } )

		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL = VBD.VBD_FILIAL"
		cQuery += 		" and   DELTA.VBD_PRODUT = VBD.VBD_PRODUT"
		cQuery += 		" and   DELTA.VBD_NUMNFI = VBD.VBD_NUMNFI"
		cQuery += 		" and   DELTA.VBD_SERORI = VBD.VBD_SERORI"
		cQuery += 		" and   DELTA.VBD_CODCLI = VBD.VBD_CODCLI"
		cQuery += 		" and   DELTA.VBD_LOJCLI = VBD.VBD_LOJCLI"
		cQuery += 		" and   DELTA.VBD_QTDFAT = VBD.VBD_QTDFAT"
		cQuery += 		" and   DELTA.VBD_INDCAN = ?"
		cQuery += 		" and   DELTA.D_E_L_E_T_=?"
		cQuery += " ) "
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )

	else
		cQuery += " AND F3_DTCANC >= ? AND F3_DTCANC <= ?"
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND VSC.D_E_L_E_T_=?" // canceladas
	aAdd( aBind, { 'C', '*' } )
	cQuery += " GROUP BY " + cCampos

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		if ! Empty((cAl)->VBD_NOMCLI)
			reclock('VBD', .T.)
			VBD->VBD_CODVBB := cCodVBB
			VBD->VBD_FILIAL := xFilial('VBD')
			VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
			VBD->VBD_CODCLI := (cAl)->VBD_CODCLI
			VBD->VBD_LOJCLI := (cAl)->VBD_LOJCLI
			VBD->VBD_CDCLI2 := (cAl)->VBD_CDCLI2
			VBD->VBD_NOMCLI := (cAl)->VBD_NOMCLI
			VBD->VBD_ENDCLI := (cAl)->VBD_ENDCLI
			VBD->VBD_CLICEP := (cAl)->VBD_CLICEP
			VBD->VBD_CLCNPJ := (cAl)->VBD_CLCNPJ
			VBD->VBD_NUMORI := (cAl)->VBD_NUMORI
			VBD->VBD_SERORI := (cAl)->VBD_SERORI
			VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
			VBD->VBD_NUMREM := (cAl)->VBD_NUMREM
			VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI
			VBD->VBD_DATORI := stod((cAl)->VBD_DATORI)
			VBD->VBD_DATREM := stod((cAl)->VBD_DATREM)
			VBD->VBD_DATNFI := stod((cAl)->VBD_DATNFI)
			VBD->VBD_CANALV := (cAl)->VBD_CANALV
			VBD->VBD_SUBCAN := (cAl)->VBD_SUBCAN
			VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
			VBD->VBD_QTDPED := (cAl)->VBD_QTDPED
			VBD->VBD_QTDREM := (cAl)->VBD_QTDREM
			VBD->VBD_QTDFAT := (cAl)->VBD_QTDFAT
			VBD->VBD_HORMOB := (cAl)->VBD_HORMOB
			VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
			VBD->VBD_INDDEV := (cAl)->VBD_INDDEV
			VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
			VBD->VBD_CHASSI := (cAl)->VBD_CHASSI
			VBD->VBD_HORKIL := (cAl)->VBD_HORKIL
			VBD->VBD_FABRIC := (cAl)->VBD_FABRIC
			VBD->VBD_MODELO := (cAl)->VBD_MODELO
			VBD->VBD_MOTCOM := (cAl)->VBD_MOTCOM
			VBD->VBD_CODVBG := (cAl)->VBD_CODVBG
			VBD->VBD_VALVDA := (cAl)->VBD_VALVDA
			VBD->VBD_INDCAN := oPrim:CodCanc()
			VBD->VBD_CODGAR := (cAl)->VBD_CODGAR
			VBD->VBD_ALIAS  := "SRV"
			//VBD->VBD_NUMSEQ := (cAl)->D2_NUMSEQ
			VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		endif
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0032})	//#"Criando registros de devolucao"
	cCampos := " VBD_CODCLI,VBD_LOJCLI,VBD_CDCLI2,VBD_NOMCLI,VBD_ENDCLI,"
	cCampos += " VBD_CLICEP,VBD_CLCNPJ,VBD_NUMORI,VBD_SERORI,VBD_LINVEN,"
	cCampos += " VBD_NUMREM,VBD_NUMNFI,VBD_DATORI,VBD_DATREM,VBD_DATNFI,"
	cCampos += " VBD_CANALV,VBD_CODGAR,VBD_SUBCAN,VBD_PRODUT,VBD_QTDPED,"
	cCampos += " VBD_QTDREM,VBD_QTDFAT,VBD_HORMOB,VBD_TIPDEM,VBD_VALVDA,"
	cCampos += " VBD_CUSMED,VBD_CHASSI,VBD_HORKIL,VBD_FABRIC,VBD_MODELO,"
	cCampos += " VBD_MOTCOM,VBD_CODVBG,VBD_TIPTEM,"
	cCampos += " D1_QUANT, D1_NUMSEQ, F1_DOC, F1_SERIE, F1_EMISSAO "

	aBind  := {}
	cQuery := "select " + cCampos
	cQuery += " FROM "+retSqlName('SF1')+" SF1 "
	cQuery += " JOIN "+retSqlName('SD1')+" SD1 ON D1_FILIAL=? AND D1_DOC = F1_DOC AND SF1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SD1') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND D1_TES = F4_CODIGO AND F4_OPEMOV=? AND SF4.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', '09' } )
	aAdd( aBind, { 'C', ' ' } )

	if cArm == "F01"	// armazéns gerenciados
//	if cArm != "D01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D1_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF_ARMZEM=? AND VBF.D_E_L_E_T_=?"
		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D1_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " JOIN "+retSqlName('VBD')+" VBD ON VBD_FILIAL=? AND VBD_PRODUT = D1_COD AND VBD_NUMNFI = D1_NFORI AND VBD_SERORI = D1_SERIORI AND VBD_INDDEV <> ? AND VBD_INDCAN <> ? AND VBD.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBD') } )
	aAdd( aBind, { 'C', oPrim:CodDev() } )
	aAdd( aBind, { 'C', oPrim:CodCanc() } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " WHERE F1_FILIAL=?"
	cQuery += " AND D1_GRUPO IN (?)"
	cQuery += " AND D1_TIPO=?" // devolucao
	aAdd( aBind, { 'C', xFilial('SF1') } )
	aAdd( aBind, { 'A', aGrupos } )
	aAdd( aBind, { 'C', 'D' } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " AND SD1.D1_NUMSEQ > ?"

		cQuery += " and not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL = VBD.VBD_FILIAL"
		cQuery += 		" and   DELTA.VBD_PRODUT = VBD.VBD_PRODUT"
		cQuery += 		" and   DELTA.VBD_NUMNFI = F1_DOC"
		cQuery += 		" and   DELTA.VBD_SERORI = F1_SERIE"
		cQuery += 		" and   DELTA.VBD_CODCLI = VBD.VBD_CODCLI"
		cQuery += 		" and   DELTA.VBD_LOJCLI = VBD.VBD_LOJCLI"
		cQuery += 		" and   DELTA.VBD_QTDFAT = VBD.VBD_QTDFAT"
		cQuery += 		" and   DELTA.VBD_INDCAN = VBD.VBD_INDCAN"
		cQuery += 		" and   DELTA.VBD_INDDEV = ?"
		cQuery += 		" and   DELTA.D_E_L_E_T_=?"
		cQuery += " ) "
		aAdd( aBind, { 'C', cSD1SEQ } )
		aAdd( aBind, { 'C', oPrim:CodDev() } )
		aAdd( aBind, { 'C', ' ' } )
	else
		cQuery += " AND D1_DTDIGIT >= ? AND D1_DTDIGIT <= ?"
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND SD1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " GROUP BY " + cCampos

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		reclock('VBD', .T.)
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODCLI := (cAl)->VBD_CODCLI
		VBD->VBD_LOJCLI := (cAl)->VBD_LOJCLI
		VBD->VBD_CDCLI2 := (cAl)->VBD_CDCLI2
		VBD->VBD_NOMCLI := (cAl)->VBD_NOMCLI
		VBD->VBD_ENDCLI := (cAl)->VBD_ENDCLI
		VBD->VBD_CLICEP := (cAl)->VBD_CLICEP
		VBD->VBD_CLCNPJ := (cAl)->VBD_CLCNPJ
		VBD->VBD_NUMORI := (cAl)->VBD_NUMORI
		VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
		VBD->VBD_NUMREM := (cAl)->VBD_NUMREM
		VBD->VBD_NUMNFI := (cAl)->F1_DOC
		VBD->VBD_SERORI := (cAl)->F1_SERIE
		VBD->VBD_DATNFI := stod((cAl)->F1_EMISSAO)
		VBD->VBD_DATORI := stod((cAl)->VBD_DATORI)
		VBD->VBD_DATREM := stod((cAl)->VBD_DATREM)
		VBD->VBD_CANALV := (cAl)->VBD_CANALV
		VBD->VBD_SUBCAN := (cAl)->VBD_SUBCAN
		VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
		VBD->VBD_QTDPED := (cAl)->D1_QUANT
		VBD->VBD_QTDREM := (cAl)->VBD_QTDREM
		VBD->VBD_QTDFAT := (cAl)->D1_QUANT // qtd devolvida
		VBD->VBD_HORMOB := (cAl)->VBD_HORMOB
		VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
		VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
		VBD->VBD_CHASSI := (cAl)->VBD_CHASSI
		VBD->VBD_HORKIL := (cAl)->VBD_HORKIL
		VBD->VBD_FABRIC := (cAl)->VBD_FABRIC
		VBD->VBD_MODELO := (cAl)->VBD_MODELO
		VBD->VBD_MOTCOM := (cAl)->VBD_MOTCOM
		VBD->VBD_CODVBG := (cAl)->VBD_CODVBG
		VBD->VBD_VALVDA := (cAl)->VBD_VALVDA
		VBD->VBD_INDDEV := oPrim:CodDev()
		VBD->VBD_INDCAN := oPrim:CodNaoCanc()
		VBD->VBD_CODGAR := (cAl)->VBD_CODGAR
		VBD->VBD_ALIAS  := "SD1"
		VBD->VBD_NUMSEQ := (cAl)->D1_NUMSEQ
		VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado


	oLogger:Log({"TIMESTAMP","  |> "+"Iniciando coleta de peças canceladas"})	//#"Iniciando coleta de peças canceladas"
	aBind  := {}
	cQuery := "select * from ("
	cQuery += " select 
	cQuery += " VO3_NUMOSV, VO3_CODITE, "
	cQuery += " MAX(VO3_NOSNUM) NOSNUM, "
	cQuery += " SUM(case when VO2_DEVOLU=? then VO3_QTDREQ * -1"
	aAdd( aBind, { 'C', '0' } )
	cQuery += 	" else VO3_QTDREQ"
	cQuery += " end) QTDREQ,"
	cQuery += " MAX(VO2_DATREQ) DATREQ"
	cQuery += " from "+retSqlName("VO3")+ " VO3"
	cQuery += " join "+retSqlName("VO2")+ " VO2"
	cQuery += 		" ON  VO2_FILIAL=VO3_FILIAL"
	cQuery += 		" AND VO2_NOSNUM=VO3_NOSNUM"
	cQuery += 		" AND VO2_TIPREQ=?"
	aAdd( aBind, { 'C', 'P' } )
	cQuery += 		" AND VO2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )

	if cArm == "F01"	// armazéns gerenciados
		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = VO3_CODITE AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
		aAdd( aBind, { 'C', ' ' } )
	endif

	cQuery += " WHERE VO3_FILIAL=?"
	cQuery += " AND VO3.D_E_L_E_T_=? "
	aAdd( aBind, { 'C', xFilial("VO3") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " and VO3_GRUITE IN (?)"
	aAdd( aBind, { 'A', aGrupos } )
	cQuery += " GROUP BY VO3_NUMOSV, VO3_CODITE"
	cQuery += " ) OS "

	cQuery += " JOIN "+retSqlName('VBD')+" VBD ON  VBD_FILIAL=?"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	cQuery += "	AND VBD_CODIGO = ("
	cQuery += 	"	select MAX(VBD_CODIGO)"
	cQuery += 	"	from "+retSqlName("VBD")
	cQuery += 	"	where VBD_FILIAL=?"
	cQuery += 	"	AND VBD_PRODUT = VO3_CODITE"
//	cQuery += 	"	AND VBD_NUMORI = NUMOSV"
	cQuery += 	"	AND VBD_INDDEV=?"
	cQuery += 	"	AND VBD_INDCAN=?"
	cQuery += 	"	AND VBD_CANALV <> ?"
	cQuery += 	"	AND D_E_L_E_T_=?"
	cQuery += ")"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
	aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
	aAdd( aBind, { 'C', oCanalVenda:CanalServicos() } )
	aAdd( aBind, { 'C', ' ' } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " where not exists ("
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
		cQuery += 		" where DELTA.VBD_FILIAL=?"
		cQuery += 		" and   DELTA.VBD_PRODUT = VO3_CODITE"
		cQuery += 		" and   DELTA.VBD_NUMORI = VO3_NUMOSV"
		cQuery += 		" and   DELTA.VBD_NUMREM = NOSNUM"
		cQuery += 		" and   DELTA.VBD_INDDEV=?"
		cQuery += 		" and   DELTA.VBD_INDCAN=?"
		cQuery += 		" and   DELTA.D_E_L_E_T_=?"
		cQuery += " ) "
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )
	else
		cQuery += " where DATREQ BETWEEN ? AND ? "
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " and QTDREQ=?"
	aAdd( aBind, { 'N', 0 } )
	cQuery += " order by VBD_NUMORI, VBD_LINVEN"

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )

	While ! (cAl)->(Eof())

		reclock('VBD', .T.)
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODCLI := (cAl)->VBD_CODCLI
		VBD->VBD_LOJCLI := (cAl)->VBD_LOJCLI
		VBD->VBD_CDCLI2 := (cAl)->VBD_CDCLI2
		VBD->VBD_NUMORI := (cAl)->VBD_NUMORI
		VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
		VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI
		VBD->VBD_SERORI := (cAl)->VBD_SERORI
		VBD->VBD_NUMREM := (cAl)->NOSNUM
		VBD->VBD_DATORI := StoD( (cAl)->VBD_DATORI )
		VBD->VBD_DATNFI := StoD( (cAl)->VBD_DATNFI )
		VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
		VBD->VBD_QTDFAT := (cAl)->VBD_QTDFAT
		VBD->VBD_QTDPED := (cAl)->VBD_QTDPED
		VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_INDCAN := oPrim:CodCanc()
		VBD->VBD_CHASSI := (cAl)->VBD_CHASSI
		VBD->VBD_MODELO := (cAl)->VBD_MODELO
		VBD->VBD_HORKIL := (cAl)->VBD_HORKIL
		VBD->VBD_FABRIC := (cAl)->VBD_FABRIC
		VBD->VBD_MOTCOM := (cAl)->VBD_MOTCOM
		VBD->VBD_VALVDA := (cAl)->VBD_VALVDA
		VBD->VBD_HORMOB := (cAl)->VBD_HORMOB
		VBD->VBD_CODGAR := (cAl)->VBD_CODGAR
		VBD->VBD_SUBCAN := (cAl)->VBD_SUBCAN
		VBD->VBD_CANALV := (cAl)->VBD_CANALV
		VBD->VBD_ALIAS  := (cAl)->VBD_ALIAS
		VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())

	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado

	if cArm == "N01"
		oLogger:Log({"TIMESTAMP","  |> "+"Iniciando coleta de serviços"})	//#"Iniciando coleta de serviços"
		aBind  := {}
		cQuery := "SELECT VO1_NUMOSV, VO1_DATABE, VO1_DATENT, VO1_CHASSI, VO1_KILOME, VO1_MOTCOM, VO1_STATUS,"
		cQuery += "VO4_CODSER, VO4_GRUSER, VO4_TIPTEM, VO4_DATDIS, VO4_DATFEC, VO4_DATCAN, VO4_SRVFIN, VO4_FATPAR, VO4_LOJA, MIN(VO4_SEQUEN) VO4_SEQUEN,"
		cQuery += "VOI_SITTPO,"
		cQuery += "VV1_MODVEI,  VV1_CODMAR,"
		cQuery += "VOO_NUMNFI, VOO_SERNFI"
		cQuery += " FROM "+retSqlName('VO1')+" VO1"
		cQuery += " JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=VO1_FILIAL AND VO2_NUMOSV=VO1_NUMOSV AND VO2_TIPREQ=? AND VO2.D_E_L_E_T_=?"
		cQuery += " JOIN "+retSqlName('VO4')+" VO4 ON VO4_FILIAL=VO1_FILIAL AND VO4_NUMOSV=VO1_NUMOSV AND VO4.D_E_L_E_T_=?"
		cQuery += " JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VOI_TIPTEM=VO4_TIPTEM AND VOI.D_E_L_E_T_=?"
		cQuery += " JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT=VO1_CHAINT AND VV1.D_E_L_E_T_=?"
		cQuery += " LEFT JOIN "+retSqlName('VOO')+" VOO ON VOO_FILIAL=? AND VOO_NUMOSV=VO1_NUMOSV AND VOO_LIBVOO=VO4_LIBVOO AND VOO.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', xFilial("VOI") } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', xFilial("VV1") } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', xFilial("VOO") } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " WHERE VO1_FILIAL=?"
		cQuery += " AND VO1.D_E_L_E_T_=? "
		cQuery += " AND VO4_DATINI <> ?"
		aAdd( aBind, { 'C', xFilial("VO1") } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', ' ' } )

		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " and not exists ("
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
			cQuery += 		" where DELTA.VBD_FILIAL=?"
			cQuery += 		" and   DELTA.VBD_PRODUT = VO4_CODSER"
			cQuery += 		" and   DELTA.VBD_NUMORI = VO1_NUMOSV"
			cQuery += 		" and   DELTA.VBD_NUMNFI = " + iif( cSGBD == "ORACLE", "NVL(VOO_NUMNFI, ' ')", "isnull(VOO_NUMNFI, ' ')" )
			cQuery += 		" and   DELTA.VBD_SERORI = " + iif( cSGBD == "ORACLE", "NVL(VOO_SERNFI, ' ')", "isnull(VOO_SERNFI, ' ')" )
			cQuery += 		" and   DELTA.VBD_CODCLI = VO4_FATPAR"
			cQuery += 		" and   DELTA.VBD_LOJCLI = VO4_LOJA"
			cQuery += 		" and   DELTA.VBD_INDDEV=?"
			cQuery += 		" and   DELTA.VBD_INDCAN=?"
			cQuery += 		" and   DELTA.D_E_L_E_T_=?"
			cQuery += " ) "
			aAdd( aBind, { 'C', xFilial("VBD") } )
			aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
			aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
			aAdd( aBind, { 'C', ' ' } )
		else
			cQuery += " and ( VO4_DATDIS BETWEEN ? AND ? "				// Tipo de Tempo - Liberado <> ''
			cQuery += "    or VO4_DATFEC BETWEEN ? AND ? "				// Tipo de Tempo - Fechado <> ''
			cQuery += "    or VO4_DATCAN BETWEEN ? AND ? )"				// Tipo de Tempo - Cancelado <> ''
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
		endif

		cQuery += " group by VO1_NUMOSV, VO1_DATABE, VO1_DATENT, VO1_CHASSI, VO1_KILOME, VO1_MOTCOM, VO1_STATUS,"
		cQuery += " VO4_CODSER, VO4_GRUSER, VO4_TIPTEM, VO4_DATDIS, VO4_DATFEC, VO4_DATCAN, VO4_SRVFIN, VO4_FATPAR, VO4_LOJA,"
		cQuery += " VOI_SITTPO,"
		cQuery += " VV1_MODVEI, VV1_CODMAR,"
		cQuery += " VOO_NUMNFI, VOO_SERNFI"
		cQuery += " order by VO1_NUMOSV, VO4_SEQUEN"
		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

			aCalSrvc :=;
				FMX_CALSER(;
					(cAl)->VO1_NUMOSV,; // cNumOS
					(cAl)->VO4_TIPTEM,; // cTipTem
					(cAl)->VO4_GRUSER,; // cGruSer
					(cAl)->VO4_CODSER,;	// cCodSer
					.F.,;        		// lApont
					.F.,;        		// lNegoc
					.T.,;        		// lRetAbe
					.T.,;        		// lRetLib
					.T.,;        		// lRetFec
					.T.,;        		// lRetCan
					,;           		// cLibVOO
					;  			 		// cFiltroSQL
				)

			reclock('VBD', .T.)
			VBD->VBD_CODVBB := cCodVBB
			VBD->VBD_FILIAL := xFilial('VBD')
			VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
			VBD->VBD_CODCLI := (cAl)->VO4_FATPAR
			VBD->VBD_LOJCLI := (cAl)->VO4_LOJA
			VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
			VBD->VBD_NUMORI := (cAl)->VO1_NUMOSV
//			VBD->VBD_LINVEN := val( (cAl)->VO4_SEQUEN )
			VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
													(cAl)->VO4_CODSER,;
													VBD->VBD_NUMORI,;
													(cAl)->VOO_NUMNFI,;
													(cAl)->VOO_SERNFI,;
													VBD->VBD_CODCLI,;
													VBD->VBD_LOJCLI,;
													1,;
													val( (cAl)->VO4_SEQUEN ) )

			VBD->VBD_NUMNFI := (cAl)->VOO_NUMNFI
			VBD->VBD_SERORI := (cAl)->VOO_SERNFI
			VBD->VBD_NUMREM := VBD->VBD_NUMNFI
			VBD->VBD_DATORI := STOD( (cAl)->VO1_DATABE )
			VBD->VBD_DATNFI := STOD( (cAl)->VO1_DATENT )
			VBD->VBD_PRODUT := (cAl)->VO4_CODSER
			VBD->VBD_QTDFAT := iif( ! empty( (cAl)->VO1_DATENT ), 1, 0 )
			VBD->VBD_QTDPED := 1
			VBD->VBD_TIPDEM := "0"	// solicitação Brenda "1"
			VBD->VBD_INDDEV := oPrim:CodNaoDev()
			VBD->VBD_INDCAN := iif( ! empty( (cAl)->VO4_DATCAN ), oPrim:CodCanc(), oPrim:CodNaoCanc() )
			VBD->VBD_CHASSI := (cAl)->VO1_CHASSI
			VBD->VBD_MODELO := LEFT( (cAl)->VV1_MODVEI, tamsx3('VBD_MODELO')[1] )
			VBD->VBD_HORKIL := (cAl)->VO1_KILOME
			VBD->VBD_FABRIC := (cAl)->VV1_CODMAR
			VBD->VBD_MOTCOM := (cAl)->VO1_MOTCOM
			VBD->VBD_VALVDA := aCalSrvc[1,SRVC_VALLIQ]						// Valor do Servico (Valor Liquido)
			VBD->VBD_HORMOB := aCalSrvc[1,SRVC_TEMVEN]						// Tempo vendido 
			VBD->VBD_CODGAR := iif( (cAl)->VOI_SITTPO == "3", 'D', 'A' )	// D=consumo interno;A=Garantia
			VBD->VBD_SUBCAN := "D5"
			VBD->VBD_CANALV := oCanalVenda:CanalServicos()
			VBD->VBD_ALIAS  := "SRV"
			VBD->VBD_TIPTEM := (cAl)->VO4_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())


// obter Serviços de Ordem de Serviço CANCELADOS
		aBind  := {}
		cQuery := "select * from ("

		cQuery += "select VO4_NUMOSV VO3_NUMOSV, VO4_CODSER VO3_CODITE, VO4_NOSNUM VO3_NOSNUM, 1 VO3_QTDREQ, VO2_DATREQ, VBD.*"
		cQuery += " from "+retSqlName("VO4")+" VO4"
		cQuery += " join "+retSqlName("VO2")+" VO2"
		cQuery += 	" ON  VO2_FILIAL=VO4_FILIAL"
		cQuery += 	" AND VO2_NOSNUM=VO4_NOSNUM"
		cQuery += 	" AND VO2_TIPREQ=?"
		cQuery += 	" AND VO2.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " JOIN "+retSqlName('VBD')+" VBD ON  VBD_FILIAL=?"
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += "	AND VBD_CODIGO = ("
		cQuery += 	"	select MAX(VBD_CODIGO)"
		cQuery += 	"	from "+retSqlName("VBD")
		cQuery += 	"	where VBD_FILIAL=?"
		cQuery += 	"	AND VBD_PRODUT = VO4_CODSER"
		cQuery += 	"	AND VBD_NUMORI = VO4_NUMOSV"
		cQuery += 	"	AND VBD_INDDEV=?"
		cQuery += 	"	AND VBD_INDCAN=?"
		cQuery += 	"	AND VBD_CANALV=?"
		cQuery += 	"	AND D_E_L_E_T_=?"
		cQuery += ")"
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
		aAdd( aBind, { 'C', oCanalVenda:CanalServicos() } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " WHERE VO4_FILIAL=?"
		cQuery += " AND VO4_DATINI <> ?"
		cQuery += " AND VO4.D_E_L_E_T_=? "
		aAdd( aBind, { 'C', xFilial("VO4") } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', '*' } )

		cQuery += " ) OS "

		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " where not exists ("
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA "
			cQuery += 		" where DELTA.VBD_FILIAL=?"
			cQuery += 		" and   DELTA.VBD_PRODUT = VO3_CODITE"
			cQuery += 		" and   DELTA.VBD_NUMORI = VO3_NUMOSV"
			cQuery += 		" and   DELTA.VBD_NUMREM = VO3_NOSNUM"
			cQuery += 		" and   DELTA.VBD_INDDEV=?"
			cQuery += 		" and   DELTA.VBD_INDCAN=?"
			cQuery += 		" and   DELTA.D_E_L_E_T_=?"
			cQuery += " ) "
			aAdd( aBind, { 'C', xFilial("VBD") } )
			aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			aAdd( aBind, { 'C', ' ' } )
		else
			cQuery += " where VO2_DATREQ BETWEEN ? AND ? "
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
		endif
		cQuery += " order by VBD_NUMORI, VBD_LINVEN"

		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

			reclock('VBD', .T.)
			VBD->VBD_CODVBB := cCodVBB
			VBD->VBD_FILIAL := xFilial('VBD')
			VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
			VBD->VBD_CODCLI := (cAl)->VBD_CODCLI
			VBD->VBD_LOJCLI := (cAl)->VBD_LOJCLI
			VBD->VBD_CDCLI2 := (cAl)->VBD_CDCLI2
			VBD->VBD_NUMORI := (cAl)->VBD_NUMORI
			VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
			VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI
			VBD->VBD_SERORI := (cAl)->VBD_SERORI
			VBD->VBD_NUMREM := (cAl)->VO3_NOSNUM
			VBD->VBD_DATORI := StoD( (cAl)->VBD_DATORI )
			VBD->VBD_DATNFI := StoD( (cAl)->VBD_DATNFI )
			VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
			VBD->VBD_QTDFAT := (cAl)->VO3_QTDREQ
			VBD->VBD_QTDPED := (cAl)->VO3_QTDREQ
			VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
			VBD->VBD_INDDEV := oPrim:CodNaoDev()
			VBD->VBD_INDCAN := oPrim:CodCanc()
			VBD->VBD_CHASSI := (cAl)->VBD_CHASSI
			VBD->VBD_MODELO := (cAl)->VBD_MODELO
			VBD->VBD_HORKIL := (cAl)->VBD_HORKIL
			VBD->VBD_FABRIC := (cAl)->VBD_FABRIC
			VBD->VBD_MOTCOM := (cAl)->VBD_MOTCOM
			VBD->VBD_VALVDA := (cAl)->VBD_VALVDA
			VBD->VBD_HORMOB := (cAl)->VBD_HORMOB
			VBD->VBD_CODGAR := (cAl)->VBD_CODGAR
			VBD->VBD_SUBCAN := (cAl)->VBD_SUBCAN
			VBD->VBD_CANALV := (cAl)->VBD_CANALV
			VBD->VBD_ALIAS  := (cAl)->VBD_ALIAS
			VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())

		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado
	endif


// obter Mudança de Tipo de Tempo, Peças e Serviços
	aBind  := {}
	cQuery := "select distinct VBD.*"
	cQuery += " from "+retSqlName("VBD")+" VBD"
	cQuery += " join "+retSqlName("VBD")+" VBD2"
	cQuery += 	" on  VBD2.VBD_FILIAL=VBD.VBD_FILIAL"
	cQuery += 	" and VBD2.VBD_PRODUT=VBD.VBD_PRODUT"
	cQuery += 	" and VBD2.VBD_NUMORI=VBD.VBD_NUMORI"
	cQuery += 	" and VBD2.VBD_NUMNFI=VBD.VBD_NUMNFI"
	cQuery += 	" and VBD2.VBD_SERORI=VBD.VBD_SERORI"
	cQuery += 	" and VBD2.VBD_INDDEV=VBD.VBD_INDDEV"
	cQuery += 	" and VBD2.VBD_INDCAN=VBD.VBD_INDCAN"
	cQuery += 	" and VBD2.VBD_CANALV=VBD.VBD_CANALV"
	cQuery += 	" and VBD2.VBD_CODCLI=VBD.VBD_CODCLI"
	cQuery += 	" and VBD2.VBD_LOJCLI=VBD.VBD_LOJCLI"
	cQuery += 	" and VBD2.VBD_TIPTEM <> VBD.VBD_TIPTEM"
	cQuery += 	" and VBD2.R_E_C_N_O_ > VBD.R_E_C_N_O_"
	cQuery += 	" and VBD2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " join "+retSqlName('SB1')+" SB1 on B1_FILIAL=? and B1_COD=VBD.VBD_PRODUT and SB1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )

	if cArm == "F01"	// armazéns gerenciados
		cQuery += " join "+retSqlName('VBF')+" VBF on VBF_FILIAL=? and VBF_PRODUT=VBD.VBD_PRODUT and VBF_FLGARQ=? and VBF_FLGUSO=? and VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', '1' } )
		aAdd( aBind, { 'C', ' ' } )
	endif

	cQuery += " where VBD.VBD_FILIAL=?"
	aAdd( aBind, { 'C', xFilial("VBD") } )
	cQuery += " and   VBD.VBD_INDCAN=?"
	aAdd( aBind, { 'C', 'N' } )
	cQuery += " and   VBD.VBD_SQCANC=?"
	aAdd( aBind, { 'C', '1' } )
	cQuery += " and   VBD.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " and B1_GRUPO IN (?)"
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and   not exists ("
		cQuery += 		" select 1 from "+retSqlName("VBD")+" CANC"
		cQuery += 		" where CANC.VBD_FILIAL=VBD.VBD_FILIAL"
		cQuery += 		" and   CANC.VBD_PRODUT=VBD.VBD_PRODUT"
		cQuery += 		" and   CANC.VBD_NUMORI=VBD.VBD_NUMORI"
		cQuery += 		" and   CANC.VBD_NUMNFI=VBD.VBD_NUMNFI"
		cQuery += 		" and   CANC.VBD_SERORI=VBD.VBD_SERORI"
		cQuery += 		" and   CANC.VBD_INDCAN=?"
		aAdd( aBind, { 'C', 'Y' } )
		cQuery += 		" and   CANC.VBD_INDDEV=VBD.VBD_INDDEV"
		cQuery += 		" and   CANC.VBD_CANALV=VBD.VBD_CANALV"
		cQuery += 		" and   CANC.VBD_CODCLI=VBD.VBD_CODCLI"
		cQuery += 		" and   CANC.VBD_LOJCLI=VBD.VBD_LOJCLI"
		cQuery += 		" and   CANC.VBD_TIPTEM=VBD.VBD_TIPTEM"
		cQuery += 		" and   CANC.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " )"
	else
		cQuery += " and (VBD.VBD_DATORI BETWEEN ? AND ? "
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
		cQuery += " or VBD.VBD_DATNFI BETWEEN ? AND ? )"
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " order by VBD.VBD_NUMORI, VBD.VBD_LINVEN"

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())

		reclock('VBD', .T.)
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODCLI := (cAl)->VBD_CODCLI
		VBD->VBD_LOJCLI := (cAl)->VBD_LOJCLI
		VBD->VBD_CDCLI2 := (cAl)->VBD_CDCLI2
		VBD->VBD_NUMORI := (cAl)->VBD_NUMORI
		VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
		VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI
		VBD->VBD_SERORI := (cAl)->VBD_SERORI
		VBD->VBD_NUMREM := (cAl)->VBD_NUMREM
		VBD->VBD_DATORI := StoD( (cAl)->VBD_DATORI )
		VBD->VBD_DATNFI := StoD( (cAl)->VBD_DATNFI )
		VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
		VBD->VBD_QTDFAT := (cAl)->VBD_QTDFAT
		VBD->VBD_QTDPED := (cAl)->VBD_QTDPED
		VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_INDCAN := oPrim:CodCanc()
		VBD->VBD_CHASSI := (cAl)->VBD_CHASSI
		VBD->VBD_MODELO := (cAl)->VBD_MODELO
		VBD->VBD_HORKIL := (cAl)->VBD_HORKIL
		VBD->VBD_FABRIC := (cAl)->VBD_FABRIC
		VBD->VBD_MOTCOM := (cAl)->VBD_MOTCOM
		VBD->VBD_VALVDA := (cAl)->VBD_VALVDA
		VBD->VBD_HORMOB := (cAl)->VBD_HORMOB
		VBD->VBD_CODGAR := (cAl)->VBD_CODGAR
		VBD->VBD_SUBCAN := (cAl)->VBD_SUBCAN
		VBD->VBD_CANALV := (cAl)->VBD_CANALV
		VBD->VBD_ALIAS  := (cAl)->VBD_ALIAS
		VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
		VBD->VBD_SQCANC := (cAl)->VBD_SQCANC
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())



	oLogger:Log({"TIMESTAMP","  |> "+STR0033})	//#"Iniciando preenchimento de dados comuns"
	OFCNHA0108_PreencheVendas(cCodVBB)
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado
return .t.


/*/{Protheus.doc} OFCNHA0107_PreencheEstoque
	Preenche os dados das linhas de estoque utilizando o banco para o mesmo
	para que se agilize a captação de dados ao máximo.
	
	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0107_PreencheEstoque(cCodVBB, cArm)
local cQuery      := ''
Local lSBZ        := SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
Local lBZ_LOCALI2 := ( lSBZ .and. SBZ->(FieldPos("BZ_LOCALI2")) > 0 )
local aBind

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0035})	//#"Iniciando preenchimento da quantidade encomendada"
	aBind  := {}
	cQuery := "UPDATE "+retsqlname('VBC')
	cQuery += 	" SET VBC_QTDENC = TMP.TOTENC "
	cQuery += " FROM ( "
	cQuery += 	" SELECT C7_PRODUTO, SUM(C7_QUANT-C7_QUJE) AS TOTENC "
	cQuery += 		" FROM "+retsqlname('SC7')+" SC7 "
	cQuery += 		" WHERE SC7.C7_FILIAL=?"
	cQuery += 		" AND SC7.D_E_L_E_T_=?"
	cQuery += 		" GROUP BY SC7.C7_PRODUTO"
	aAdd( aBind, { 'C', xFilial('SC7') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
	cQuery += " AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.C7_PRODUTO "
	cQuery += " AND "+retsqlname('VBC')+".VBC_CODVBB=?"
	cQuery += " AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBC') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0036)		//#"Erro de query na captação de itens encomendados."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})		//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0037})	// #"Iniciando preenchimento BackOrder"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBC')
	cQuery += "    SET VBC_BACKOR = TMP.TOTBACK "
	cQuery += " FROM ( "
	cQuery += " select VS3_CODITE, SUM(VS3_QTDITE) AS TOTBACK "
	cQuery += " from ( "
	cQuery += 	" SELECT VS3_CODITE, VS3_QTDITE "
	cQuery += 	" FROM "+retsqlname('VS1')+" VS1 "
	cQuery += 	" JOIN "+retsqlname('VS3')+" VS3 "
	cQuery += 		" ON  VS3_FILIAL = VS1_FILIAL "
	cQuery += 		" AND VS3_NUMORC = VS1_NUMORC "
	cQuery += 		" AND VS3.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE VS1_FILIAL=?"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	cQuery += 	" AND VS1_STATUS=?"
	cQuery += 	" AND VS1_TIPORC=?"
	cQuery += 	" AND VS1_PEDREF <> VS1_NUMORC "
	cQuery += 	" AND VS1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " UNION ALL"

	cQuery += 	" select VSJ_CODITE, VSJ_QTDITE "
	cQuery += 	" from "+retsqlname('SFJ')+" SFJ "

	cQuery += 	" join "+retsqlname('VB5')+" VB5 "
	cQuery += 		" on  VB5_FILIAL=?"
	cQuery += 		" and VB5_CODSFJ = FJ_CODIGO"
	cQuery += 		" and VB5.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VB5") } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += 	" join "+retsqlname('VSJ')+" VSJ "
	cQuery += 		" on  VSJ_FILIAL=? "
	cQuery += 		" and VSJ_CODIGO=VB5_CODVSJ "
	cQuery += 		" and VSJ_CODITE=VB5_CODITE "
	cQuery += 		" and VSJ_GRUITE=VB5_GRUITE "
	cQuery += 		" and VSJ.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VSJ") } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += 	" where FJ_FILIAL=?"
	cQuery += 	" and   FJ_SOLICIT=?"
	cQuery += 	" and   SFJ.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SFJ") } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) BACKORDER "
	cQuery += " group by VS3_CODITE "

	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.VS3_CODITE "
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VBC") } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0038)	//#"Erro de query na captação de itens em Backorder."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})		//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> " + STR0068})	//#"Iniciando coleta de dados de fornecedor"
	aBind  := {}
	cQuery := "UPDATE "+retsqlname('VBC')
	cQuery += 	" SET VBC_CODFOR = TMP.A2_COD, "
	cQuery += 		" VBC_FORNAM = TMP.FORNAM "
	cQuery += 	" FROM ( "
	cQuery += 		" SELECT B1_COD, A2_COD, CASE WHEN A2_NEMPR=? THEN A2_NREDUZ ELSE A2_NEMPR END AS FORNAM "
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" FROM "+retsqlname('SB1')+" SB1 "
	cQuery += 		" JOIN "+retsqlname('SA2')+" SA2 ON A2_FILIAL=? AND A2_COD = B1_PROC AND SA2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SA2") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" WHERE SB1.B1_FILIAL=?"
	cQuery += 		" AND SB1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SB1") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" ) TMP "
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.B1_COD "
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBC') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0067)	//#coleta de dados de fornecedor
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})		//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0039})	//#"Iniciando coleta de datas de ultima saida"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBC')
	cQuery += 	" SET VBC_ULTSAI = TMP.ULTSAI "
	cQuery += " FROM ( "
	cQuery += 	" SELECT  D2_COD, MAX(D2_EMISSAO) AS ULTSAI "
	cQuery += 	" FROM "+retsqlname('SD2')+" SD2 "
	cQuery += 	" JOIN "+retsqlname('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = D2_TES AND SF4.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE D2_FILIAL=?"
	cQuery += 	" AND F4_OPEMOV=?"
	cQuery += 	" AND SD2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SD2") } )
	aAdd( aBind, { 'C', '05' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" GROUP BY D2_COD "
	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
	cQuery += 	" AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.D2_COD "
	cQuery += 	" AND "+retsqlname('VBC')+".VBC_CODVBB=?"
	cQuery += 	" AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VBC") } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0040)	//#"Erro de query na captação das últimas saídas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0041})	// #"Iniciando coleta de dados de ultima entrada"
	aBind  := {}
	cQuery := "UPDATE "+retsqlname('VBC')
	cQuery += 	" SET VBC_ULTENT = TMP.ULTENT "
	cQuery += 	" FROM ( "
	cQuery += 	" SELECT D1_COD, MAX(D1_DTDIGIT) ULTENT "
	cQuery += 	" FROM "+retsqlname('SD1')+" SD1 "
	cQuery += 	" JOIN "+retsqlname('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE D1_FILIAL=?"
	cQuery += 	" AND SF4.F4_OPEMOV IN (?) "
	cQuery += 	" GROUP BY D1_COD "
	aAdd( aBind, { 'C', xFilial("SD1") } )
	aAdd( aBind, { 'A', {'01','03','09'} } )
	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.D1_COD "
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("VBC") } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0042)		//#"Erro de query na captação das últimas entradas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0043})	// #"Iniciando coleta de dados de ultima entrada pelo SB9"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBC')
	cQuery += 	" SET VBC_ULTENT = TMP.ULTENT "
	cQuery += " FROM ( "
	cQuery += 	" SELECT B9_COD, MAX(B9_DATA) ULTENT "
	cQuery += 	" FROM "+retsqlname('SB9')
	cQuery += 	" WHERE B9_FILIAL=?"
	cQuery += 	" AND B9_DATA <> ?"
	cQuery += 	" AND D_E_L_E_T_=?"
	cQuery += 	" GROUP BY B9_COD "
	aAdd( aBind, { 'C', xFilial('SB9') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.B9_COD "
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBC')+".VBC_ULTENT=?"
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBC') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0044)		//#"Erro de query na captação das últimas entradas via saldo inicial."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0045})	// #"Iniciando coleta de dados de reserva"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBC')
	cQuery += 	" SET VBC_QTDRES = (TMP.SOMA_BAL + TMP.SOMA_OFI) "
	cQuery += " FROM ( "
	cQuery += OFCNHA013C_getQryRes( cArm )		// reservas - estoque
	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.B1_COD "
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBC') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0046)	//#"Erro de query na captação das reservas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0047})	// #"Gravando totais no cabecalho de estoque"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBB')
	cQuery += 	" SET VBB_NUMREG = TMP.QTD, "
	cQuery += 		" VBB_FILEQU = TMP.SOMA "
	cQuery += " FROM ( "
	cQuery += 	" SELECT VBC_CODVBB, COUNT(*) QTD, SUM(VBC_QTDEST + VBC_QTDENC + "
	cQuery += 	" case when VBC_BACKOR > VBC_QTDEST then VBC_BACKOR - VBC_QTDEST else 0 end "
	cQuery += ") SOMA "
	cQuery += 	" FROM "+retsqlname('VBC')
	cQuery += 	" WHERE VBC_FILIAL=?"
	cQuery += 	" AND VBC_CODVBB=?"
	cQuery += 	" AND D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBC') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" GROUP BY VBC_CODVBB "
	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBB')+".VBB_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBB')+".VBB_CODIGO=?"
	cQuery += "   AND "+retsqlname('VBB')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBB') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0048)	//#"Erro de query nas somas de cabeçalho."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	if lSBZ .AND. lBZ_LOCALI2
		oLogger:Log({"TIMESTAMP","  |>   |> "+ STR0069})	// #"Gravando Localização da SBZ"
		aBind  := {}
		cQuery := " UPDATE "+retsqlname('VBC')
		cQuery += 	" SET VBC_LOCCAO = TMP.BZ_LOCALI2 "
		cQuery += " FROM (
		cQuery += 	" SELECT BZ_COD, BZ_LOCALI2 "
		cQuery += 	" FROM "+RetSqlName('SBZ')+" SBZ"
		cQuery += 	" WHERE BZ_FILIAL=?"
		cQuery += 	" AND BZ_LOCALI2 != ?"
		cQuery += 	" AND SBZ.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('SBZ') } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " ) TMP "
		cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
		cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.BZ_COD "
		cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?"
		cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('VBC') } )
		aAdd( aBind, { 'C', cCodVBB } )
		aAdd( aBind, { 'C', ' ' } )
		OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0070)	//#"Erro gravação Localização na SBZ"
		oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado
	endif

	if SB5->(FieldPos('B5_LOCALI2')) > 0
		aBind  := {}
		oLogger:Log({"TIMESTAMP","  |>   |> "+ STR0071})	// #"Gravando Localização da SB5"
		cQuery := "UPDATE "+retsqlname('VBC')
		cQuery += 	" SET VBC_LOCCAO = TMP.B5_LOCALI2 "
		cQuery += " FROM ( "
		cQuery += 	" SELECT B5_COD, B5_LOCALI2 "
		cQuery += 	" FROM "+RetSqlName('SB5')
		cQuery += 	" WHERE B5_FILIAL=?"
		cQuery += 	" AND B5_LOCALI2 != ?"
		cQuery += 	" AND D_E_L_E_T_ =?"
		aAdd( aBind, { 'C', xFilial('SB5') } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " ) TMP "
		cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?"
		cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.B5_COD "
		cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?"
		cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('VBC') } )
		aAdd( aBind, { 'C', cCodVBB } )
		aAdd( aBind, { 'C', ' ' } )
		OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0072)	//#"Erro gravação Localização na SB5"
		oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado
	endif
return nil


/*/{Protheus.doc} OFCNHA0108_PreencheVendas
	Preenche os dados das linhas de venda
	
	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0108_PreencheVendas(cCodVBB)
local cQuery := ''
local aBind

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0049})	//#"Iniciando captação de dados comuns de clientes"
	aBind  := {}
	cQuery := " UPDATE " + retsqlname('VBD')
	cQuery += 	" SET VBD_NOMCLI = LEFT(TMP.A1_NOME, ?),"
	cQuery += 		" VBD_CLICEP = LEFT(TMP.A1_CEP , ?),
	cQuery += 		" VBD_ENDCLI = LEFT(TMP.A1_END , ?),"
//	cQuery += 		" VBD_CDCLI2 = LEFT(?, ?),"
	cQuery += 		" VBD_CLCNPJ = ?"
	aAdd( aBind, { 'N', tamsx3('VBD_NOMCLI')[1] } )
	aAdd( aBind, { 'N', tamsx3('VBD_CLICEP')[1] } )
	aAdd( aBind, { 'N', tamsx3('VBD_ENDCLI')[1] } )
//	aAdd( aBind, { 'U', oSqlHlp:Concat({'A1_COD', 'A1_LOJA'}) } )
	aAdd( aBind, { 'U', oSqlHlp:Concat({'SUBSTRING(TMP.A1_CGC, 0, 9)', 'SUBSTRING(TMP.A1_CGC, 11, 2)'}) } )
	cQuery += " FROM ("
	cQuery += "   SELECT A1_COD, A1_LOJA, A1_NOME, A1_END, A1_CEP, A1_CGC"
	cQuery += "     FROM " + retsqlname('SA1')
	cQuery += "    WHERE A1_FILIAL=? AND D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial("SA1") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP"
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_NOMCLI=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODCLI = TMP.A1_COD "
	cQuery += "   AND "+retsqlname('VBD')+".VBD_LOJCLI = TMP.A1_LOJA "
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0050)	//#"Erro de query na captação dados de clientes - vendas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	// #Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0051})	//#"Iniciando captação de dados comuns de custos"
	aBind  := {}
	cQuery := "UPDATE " + retsqlname('VBD')
	cQuery += 	" SET VBD_CUSMED = TMP.B2_CM1 "
	cQuery += " FROM ("
	cQuery += 	" SELECT B2_COD, CAST(B2_CM1 AS decimal(10,2)) B2_CM1 "
	cQuery += 	" FROM " + retsqlname('VBF') + " VBF "
	cQuery += 	" JOIN " + retsqlname('SB1') + " SB1 ON B1_FILIAL=? AND B1_COD = VBF_PRODUT AND SB1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" JOIN " + retsqlname('SB2') + " SB2 ON B2_FILIAL=? AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE VBF_FILIAL=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBF') } )
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP"
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_PRODUT = TMP.B2_COD "
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0052)	//#"Erro de query na captação do custo médio."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0057})	//#"Gravando totais no cabecalho de estoque"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBB')
	cQuery += 	" SET VBB_NUMREG = TMP.QTD, "
	cQuery += 		" VBB_FILEQU = TMP.SOMA "
	cQuery += " FROM ( "
	cQuery += 	" SELECT VBD_CODVBB, COUNT(*) QTD, SUM(VBD_QTDPED) SOMA "
	cQuery += 	" FROM "+retsqlname('VBD')
	cQuery += 	" WHERE VBD_FILIAL=?"
	cQuery += 	" AND VBD_CODVBB=?"
	cQuery += 	" AND D_E_L_E_T_=?"
	cQuery += 	" GROUP BY VBD_CODVBB "
	aAdd( aBind, { 'C', xFilial('VBD') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP "
	cQuery += " WHERE "+retsqlname('VBB')+".VBB_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBB')+".VBB_CODIGO=?"
	cQuery += "   AND "+retsqlname('VBB')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VBD') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0048)	//#"Erro de query nas somas de cabeçalho."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0058})	//#"Iniciando captação de dados de subcanal de clientes"
	aBind  := {}
	cQuery := " UPDATE " + retsqlname('VBD')
	cQuery += 	" SET VBD_SUBCAN = VCF_SUBCAN "
	cQuery += " FROM ("
	cQuery += 	" SELECT VCF_FILIAL, VCF_CODCLI, VCF_LOJCLI, VCF_SUBCAN "
	cQuery += 	" FROM " + retsqlname('VCF')
	cQuery += 	" WHERE VCF_FILIAL=? AND D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VCF') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP"
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODCLI = TMP.VCF_CODCLI "
	cQuery += "   AND "+retsqlname('VBD')+".VBD_LOJCLI = TMP.VCF_LOJCLI "
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CANALV <> ? "
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', oCanalVenda:CanalServicos() } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0050)	//#"Erro de query na captação de dados de clientes das vendas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	// #Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0060})	// #"Iniciando captação de dados de canal de recompras"
	aBind  := {}
	cQuery := " UPDATE " + retsqlname('VBD')
	cQuery += 	" SET VBD_CANALV=?"
	cQuery += " FROM ("
	cQuery += 	" SELECT VCF_CODCLI, VCF_LOJCLI "
	cQuery += 	" FROM " + retsqlname('VCF') + " VCF "
	cQuery += 	" JOIN " + retsqlname('SA1') + " SA1 ON A1_FILIAL=? AND A1_COD = VCF_CODCLI AND A1_LOJA = VCF_LOJCLI and SA1.D_E_L_E_T_=?"
	cQuery += 	" WHERE VCF_FILIAL=?"
	cQuery += 	" AND A1_COD  =?" // codigo cliente recompra
	cQuery += 	" AND A1_LOJA =?" // loja cliente recompra
	cQuery += 	" AND VCF.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', oCanalVenda:CanalRecompra() } )
	aAdd( aBind, { 'C', xFilial('SA1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VCF') } )
	aAdd( aBind, { 'C', oConf:cCodCliRecomp } )
	aAdd( aBind, { 'C', oConf:cLojCliRecomp } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP"
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?"
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODCLI = TMP.VCF_CODCLI "
	cQuery += "   AND "+retsqlname('VBD')+".VBD_LOJCLI = TMP.VCF_LOJCLI "
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CANALV <> ?"
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', oCanalVenda:CanalServicos() } )
	aAdd( aBind, { 'C', ' ' } )

	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0059)	//#"Erro de query na captação de canal de recompra."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	// #Finalizado
return nil


/*/{Protheus.doc} OFCNHA0109_GravaCheckPoint
	Funcao que vai gravar os numseq para gravar o status atual dos envios caso 
	a geracao que aconteceu tenha sido normal e nao extraordinaria
	
	@type function
	@author Vinicius Gati
	@since 08/03/2018
/*/
function OFCNHA0109_GravaCheckPoint(aData)
local aArea    := getArea()
local cQuery
local cAlias   := getNextAlias()

	if Len(aData) > 0 .and. aData[1, 7] == oPrim:CodGerNormal()
		cQuery := "select max(VBB_SD1SEQ) SD1SEQ, max(VBB_SD2SEQ) SD2SEQ, max(VBB_SD3SEQ) SD3SEQ"
		cQuery += " from "+ retSqlName("VBB") +" VBB "
		cQuery += " where VBB_FILIAL = ?"
		cQuery += " and   VBB_CODIGO in (?)"
		cQuery += " and   VBB.D_E_L_E_T_=?"
		OFCNHA015C_ExecQuery( @cQuery, {{'C',xFilial("VBB")},{'A',aVBBs},{'C',space(1)}}, cAlias )
		if ! (cAlias)->(eof())
			cSD1SEQ := (cAlias)->SD1SEQ
			cSD2SEQ := (cAlias)->SD2SEQ
			cSD3SEQ := (cAlias)->SD3SEQ
		endif
		(cAlias)->( dbCloseArea() )
		oConf:SaveCheckPoint( cSD1SEQ, cSD2SEQ, cSD3SEQ )

		restArea( aArea )
	endif
return .T.


/*/{Protheus.doc} OFCNHA0112_GeraDados
	Gera os dados para o arquivo

	@type function
	@author Vinicius Gati
	@since 01/03/2018
/*/
function OFCNHA0112_GeraDados(cFilPrc, cArm, dDtVen1, dDtVen2, lEst, dDtEst, cTipoGer, lVda, cDtDe, cDtAte, cDtEst, cNumProgr)
local cFilAtu := cFilAnt
local aBind

	cFilAnt := cFilPrc
	oConf:getConfig( cFilPrc )

	// limpando cache de gerações passadas
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBF')+" SET VBF_FLGARQ=? WHERE VBF_FILIAL=? AND D_E_L_E_T_=?"
	aAdd( aBind, { 'C', 'N' } )
	aAdd( aBind, { 'C', xFilial('VBF') } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0073)		//#Limpeza de cache

	cNumProgr := right( "0000000" + iif( Empty(cNumProgr), oConf:NextNum(), cNumProgr ), 7 )

	if lEst
		oLogger:Log({"TIMESTAMP",STR0062})	// #"Gerando dados de estoque"
		OFCNHA0102_GeraEstoque(cArm, cTipoGer, dDtEst, cNumProgr, cDtEst)
	endif

	if lVda
		oLogger:Log({"TIMESTAMP",STR0063})	//#"Gerando dados de vendas"
		OFCNHA0104_GeraVendas(cArm, cTipoGer, dDtVen1, dDtVen2, cNumProgr, cDtDe, cDtAte)
	endif

	if cTipoGer == oPrim:CodGerNormal()
		aBind  := {}
		cQuery := "update "+retSqlName("VBB")+" set"
		cQuery += "  VBB_SD1SEQ = (select coalesce(max(VBD_NUMSEQ),?) from "+retSqlName("VBD")+" where VBD_FILIAL=? and VBD_ALIAS=? and D_E_L_E_T_=?)"
		aAdd( aBind, { 'C', cSD1Max } )
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', 'SD1' } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += ", VBB_SD2SEQ = (select coalesce(max(VBD_NUMSEQ),?) from "+retSqlName("VBD")+" where VBD_FILIAL=? and VBD_ALIAS=? and D_E_L_E_T_=?)"
		aAdd( aBind, { 'C', cSD2Max } )
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', 'SD2' } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += ", VBB_SD3SEQ = (select coalesce(max(VBC_NUMSEQ),?) from "+retSqlName("VBC")+" where VBC_FILIAL=? and D_E_L_E_T_=?)"
		aAdd( aBind, { 'C', cSD3Max } )
		aAdd( aBind, { 'C', xFilial("VBC") } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " where VBB_DATA2=?"
		cQuery += " and VBB_SD1SEQ=?"
		cQuery += " and VBB_SD2SEQ=?"
		cQuery += " and VBB_SD3SEQ=?"
		cQuery += " and D_E_L_E_T_=?"
		aAdd( aBind, { 'D', date() } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', ' ' } )
		OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0064)		//#"Erro de sql detectado atualização dos NUMSEQ."
	endif

	oLogger:Log({"TIMESTAMP",STR0065})	// #"Finalizada geração de dados"
	oLogger:Log({"TIMESTAMP","###############################################"})
	cFilAnt := cFilAtu
return .T.


/*/{Protheus.doc} OFCNHA012C_getQAtuCust
Busca custo e quantidade disponível
@type function
@author Cristiam Rossi
@since 12/03/2025
/*/
static function OFCNHA012C_getQAtuCust( cPRODUT, nParam03, aLocais, lSBZ )
local  aArea   := getArea()
local  aRet    := { 0, 0, nil, 0 }
local  nI

	SB1->( dbSeek( xFilial("SB1") + cPRODUT ) )
	if lSBZ
		SBZ->( dbSetOrder(1) )
		SBZ->( dbSeek( xFilial("SBZ") + cPRODUT ) )
	endif

	for nI := 1 to len( aLocais )
		if SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + aLocais[nI][1] ) )
			aRet[1] += saldoMov(nil, nil, nil, iif(nParam03 == 1, .F., Nil), nil, nil, nil, nil)
			aRet[2] := iif( aRet[2] == 0, SB2->B2_CM1, aRet[2] )
		endif
	next
	aRet[2] := iif( aRet[2] < 0.01, 0.01, aRet[2] )			// custo médio
	aRet[3] := iif( SB1->B1_REMANE == "0", "N", "S" ) 		// Indicador estocagem
	aRet[4] := iif( lSBZ, SBZ->BZ_ESTSEG, SB1->B1_ESTSEG )	// Estoque mínimo acima do estoque de segurança

	restArea( aArea )
return aRet


/*/{Protheus.doc} OFCNHA013C_getQryRes
Query que retorna Reservas de estoque
@type function
@author Cristiam Rossi
@since 12/03/2025
@param cArm, character, armazém CNH
@return character, query
/*/
Static Function OFCNHA013C_getQryRes( cArm )
local   cSQL
local   cVldsts := JD06ResFases("' ', 'C'")
local   cVldLj  := JD06ResFases("'X'")
local   nI
local   aGrupo := {"NAOTRAZERNADA"}
local   aBind   := {}

	for nI := 1 to len( oConf:oConfig["LOCAIS"] )
		if oConf:oConfig["LOCAIS"][nI]["WAREHOUSE"] == cArm
			aAdd( aGrupo, alltrim(oConf:oConfig["LOCAIS"][nI]["GRUPO"]) )
		endif
	next

	cSQL := "SELECT VE6.B1_COD, SUM(CASE OPERACAO WHEN 'BAL' THEN SOMA ELSE 0 END) SOMA_BAL,"
	cSQL += 	" SUM(CASE OPERACAO WHEN 'OFI' THEN SOMA ELSE 0 END) SOMA_OFI"
	cSQL += " FROM ( "
	cSQL += 	" SELECT OPERACAO, VS1_STATUS, B1_COD, SUM(CONTA) SOMA"
	cSQL += 	" FROM ( "

	// Orçamento balcão
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA"
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2"
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL=? AND B1_GRUPO = VB2_GRUITE AND B1_CODFAB = VB2_CODITE AND SB1.D_E_L_E_T_=?"
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?"
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?"
	cSQL += 		" AND VS1_TIPORC=? AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?) "  // só X não entra // tratamento do loja
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD "
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )

	// Orçamento oficina 
	cSQL += 		" UNION ALL  "
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'OFI' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA" // quando oficina é necessário usar a conta
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2"
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL=? AND B1_GRUPO = VB2_GRUITE AND B1_CODFAB = VB2_CODITE  AND SB1.D_E_L_E_T_=?"
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?"
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?"
	cSQL += 		" AND VS1_TIPORC=? AND VS1_NUMOSV=?" // requisicao nao entra aqui vai ser query separada, esta abaixo "
	cSQL += 		" AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)"  // só X não entra // tratamento do loja
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD "
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '2' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )

	// Pedido
	cSQL += 		" UNION ALL  "
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA"
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2"
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL =? AND B1_GRUPO = VB2_GRUITE AND B1_CODFAB = VB2_CODITE AND SB1.D_E_L_E_T_=?"
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?"
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=? AND VS1.VS1_PEDSTA IN (?)"
	cSQL += 		" AND VS1_TIPORC=? AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)"  // só X não entra // tratamento do loja
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD "
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'A', {'0','1'} } )
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )

	// Reserva de OS sem orçamento (não requisição)
	cSQL += 		" UNION ALL "
	cSQL += 		" SELECT '0' VS1_STATUS, B1_COD, 'OFI' OPERACAO, SUM ( CASE WHEN VB3.VB3_TIPREQ <> ? THEN VB3.VB3_QUANT ELSE VB3.VB3_QUANT * -1 END ) AS CONTA" // quando oficina é necessário usar a conta
	cSQL += 		" FROM "+retSqlName('VB3')+ " VB3, "+retSqlName('SB1')+ " SB1"
	cSQL +=		 	" WHERE VB3.VB3_FILIAL=? AND SB1.B1_FILIAL=?"
	cSQL +=		 	" AND VB3.VB3_GRUITE = B1_GRUPO AND VB3.VB3_CODITE = B1_CODFAB  AND VB3.D_E_L_E_T_=?"
	cSQL +=		 	" AND SB1.D_E_L_E_T_=?" // preenchido os
	cSQL +=		 	" GROUP BY B1_COD "
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VB3') } )
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )

	// Reservas de transferências
	cSQL += 		" UNION ALL  "
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA"
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2"
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL =? AND B1_GRUPO = VB2_GRUITE AND B1_CODFAB = VB2_CODITE  AND SB1.D_E_L_E_T_=?"
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?"
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?"
	cSQL += 		" AND VS1_TIPORC=? AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)"  // só X não entra // tratamento do loja
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD"
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '3' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )

	// coleta requisicoes
	cSQL += 		" UNION ALL "
	cSQL += 		" SELECT '0' VS1_STATUS, B1_COD, 'OFI', SUM(SALDO) AS CONTA"
	cSQL += 		" FROM ("
	cSQL += 			" SELECT B1_COD, VO2_NUMOSV, SUM(CASE WHEN VO2_DEVOLU=? THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) SALDO"
	cSQL += 			" FROM "+retSqlName('VO3')+" VO3"
	cSQL += 			" JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL =? AND F4_CODIGO = VO3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?"
	cSQL += 			" JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=? AND VO2_NOSNUM = VO3_NOSNUM AND VO2.D_E_L_E_T_=?"
	cSQL += 			" JOIN "+retSqlName('SB1')+" SB1 ON B1_FILIAL =? AND B1_CODFAB = VO3_CODITE AND B1_GRUPO = VO3_GRUITE AND SB1.D_E_L_E_T_=?"
	cSQL += 			" WHERE VO3.VO3_FILIAL=?"
	cSQL += 			" AND VO3.D_E_L_E_T_=?"
	cSQL += 			" AND VO3_DATFEC=?"
	cSQL += 			" AND VO3_DATCAN=?"
	cSQL += 			" GROUP BY B1_COD, VO2_NUMOSV"
	cSQL += 			" HAVING SUM(CASE WHEN VO2_DEVOLU=? THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) > ?"
	cSQL += 		" ) TB"
	cSQL += 		" GROUP BY B1_COD"
	cSQL += 		" HAVING SUM(SALDO) > ?"
	cSQL += 	" ) UNIONS_RESORC "
	cSQL += 	" WHERE VS1_STATUS IN (?)"
	cSQL += 	" GROUP BY OPERACAO, VS1_STATUS, B1_COD"
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VO2') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial('VO3') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'N', 0 } )
	aAdd( aBind, { 'N', 0 } )
	aAdd( aBind, { 'U', cVldsts } )

	// removendo lixos/erros
	cSQL += "      HAVING COUNT(*) <= SUM(CONTA) AND SUM(CONTA) > ?"
	cSQL += "  ) VE6   "
	aAdd( aBind, { 'N', 0 } )

//	if cArm == "D01"	// Armazém Não Gerenciado
	if cArm != "F01"	// Armazém Não Gerenciado
		cSQL += " JOIN " + retSqlName('SB1') + " SB1"
		cSQL += " ON  SB1.B1_FILIAL=?"
		cSQL += " AND SB1.B1_GRUPO in (?)"
		cSQL += " AND SB1.B1_COD = VE6.B1_COD"
		cSQL += " AND SB1.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('SB1') } )
		aAdd( aBind, { 'A', aGrupo } )
		aAdd( aBind, { 'C', ' ' } )
	else
		cSQL   += " JOIN " + retSqlName('VBF') + " VBF"
		cSQL   += " ON VE6.B1_COD = VBF_PRODUT"
		cSQL   += " AND VBF_FILIAL=?"
		cSQL   += " AND VBF_FLGUSO=?"
		cSQL   += " AND VBF_FLGARQ=?"
//		cSQL   += " AND VBF_ARMZEM=?"
		cSQL   += " AND VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', '1' } )
		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cSQL += " GROUP BY VE6.B1_COD "
	cSQL := OFCNHA015C_ExecQuery( cSQL, aBind, , , .T. )
Return cSQL


/*/{Protheus.doc} OFCNHA014C_getQryRes
Query que retorna Reservas de vendas/orçamentos
@type function
@author Cristiam Rossi
@since 12/03/2025
@param cArm, character, armazém CNH
@return character, query
/*/
Static Function OFCNHA014C_getQryRes( cArm )
local   cSQL
local   cVldsts := JD06ResFases("' ', 'C', 'X'")
local   nI
local   aGrupo  := {"NAOTRAZERNADA"}
local   aBind   := {}

	for nI := 1 to len( oConf:oConfig["LOCAIS"] )
		if oConf:oConfig["LOCAIS"][nI]["WAREHOUSE"] == cArm
			aAdd( aGrupo, alltrim(oConf:oConfig["LOCAIS"][nI]["GRUPO"]) )
		endif
	next

	// Orçamento balcão, oficina e Pedido
	cSQL := "SELECT distinct VE6.* FROM  ("
	cSQL += " SELECT D2_PRCVEN, SUM(D2_QUANT) D2_QUANT,D2_ITEM,VOO_NUMOSV,VO1_DATABE,VOI_SITTPO,D2_CLIENTE,D2_LOJA,VOO_NUMNFI,VOO_SERNFI,D2_EMISSAO,D2_COD,VO1_CHASSI,VV1_MODVEI,VO1_KILOME,VO1_CODMAR,VO1_MOTCOM,D2_NUMSEQ,OPERACAO,D2_GRUPO,SUM(D2_QUANT) VO3_QTDREQ,VS3_CODSIT,VS1_TIPTEM,VO3_NOSNUM"
	cSQL += " FROM ( "
	cSQL += " SELECT "
	cSQL += " VS3_VALPEC D2_PRCVEN, "
	cSQL += " SUM(CASE "
	cSQL += " 	WHEN VB2.VB2_TIPREQ <> ?"
	cSQL += " 	THEN VB2.VB2_QUANT "
	cSQL += " 	ELSE VB2.VB2_QUANT * ? "
	cSQL += " 	END) D2_QUANT, "
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'N', -1 } )
	cSQL += " VS3_SEQUEN D2_ITEM, "
	cSQL += " VS1_NUMORC VOO_NUMOSV, "
	cSQL += " VS1_DATORC VO1_DATABE, "
	cSQL += " VOI_SITTPO, "
	cSQL += " VS1_CLIFAT D2_CLIENTE, "
	cSQL += " VS1_LOJA D2_LOJA, "
	cSQL += " VS1_NUMNFI VOO_NUMNFI, "
	cSQL += " VS1_SERNFI VOO_SERNFI, "
	cSQL += " F2_EMISSAO D2_EMISSAO, "
	cSQL += " VS3_CODITE D2_COD, "
	cSQL += " VV1_CHASSI VO1_CHASSI, "
	cSQL += " VV1_MODVEI, "
	cSQL += " '' VO1_KILOME, "
	cSQL += " '' VO1_CODMAR, "
	cSQL += " '' VO1_MOTCOM, "
	cSQL += " '' D2_NUMSEQ, "
	cSQL += " CASE"
	cSQL += 	" WHEN VS1_TIPORC=? THEN 'BAL'"
	cSQL += 	" WHEN VS1_TIPORC=? AND VS1_NUMOSV=? THEN 'OFI'"
	cSQL += 	" WHEN VS1_TIPORC=? THEN 'BAL'"
	cSQL += 	" WHEN VS1_TIPORC=? AND VS1_PEDSTA IN (?) THEN 'BAL'"
	cSQL += " END OPERACAO,"
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', '2' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '3' } )
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'A', {'0','1'} } )
	cSQL += " B1_GRUPO D2_GRUPO,"
	cSQL += " VS3_CODSIT, "
	cSQL += " VS1_TIPTEM,"
	cSQL += " '' VO3_NOSNUM"
	cSQL += " FROM "+retSqlName('VB2')+" VB2 "
	cSQL += " JOIN "+retSqlName('SB1')+" SB1 ON B1_FILIAL=? AND B1_GRUPO = VB2_GRUITE AND B1_CODFAB = VB2_CODITE AND SB1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VS1')+" VS1 ON VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT = VS1_CHAINT AND VV1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VV1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('SF2')+" SF2 ON F2_FILIAL=? AND F2_DOC = VS1_NUMNFI AND F2_SERIE = VS1_SERNFI AND SF2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SF2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VS3')+" VS3 ON VS3_FILIAL=? AND VS3_NUMORC = VB2_NUMORC AND VS3_CODITE = VB2_CODITE AND VS3.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS3') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = VS3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VS1_TIPTEM = VOI_TIPTEM AND VOI.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VOI') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)"
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldsts } )
	CSQL += " GROUP BY VS3_VALPEC,VS3_SEQUEN,VS1_NUMORC,VS1_DATORC,VOI_SITTPO,VS1_CLIFAT,VS1_LOJA,VS1_NUMNFI,VS1_SERNFI,F2_EMISSAO,VS3_CODITE,VV1_CHASSI,VV1_MODVEI,VS1_TIPORC,VS1_NUMOSV,VS1_PEDSTA,B1_GRUPO,VS3_CODSIT,VS1_TIPTEM"

	cSQL += " UNION ALL "

// ADD AQUI SUBQUERY PEDIDO EM BACKORDER
	cSQL += " SELECT "
	cSQL += " VS3_VALPEC D2_PRCVEN, "
	cSQL += " VS3_QTDITE D2_QUANT, "
	cSQL += " VS3_SEQUEN D2_ITEM, "
	cSQL += " VS1_NUMORC VOO_NUMOSV, "
	cSQL += " VS1_DATORC VO1_DATABE, "
	cSQL += " VOI_SITTPO, "
	cSQL += " VS1_CLIFAT D2_CLIENTE, "
	cSQL += " VS1_LOJA D2_LOJA, "
	cSQL += " VS1_NUMNFI VOO_NUMNFI, "
	cSQL += " VS1_SERNFI VOO_SERNFI, "
	cSQL += " F2_EMISSAO D2_EMISSAO, "
	cSQL += " VS3_CODITE D2_COD, "
	cSQL += " VV1_CHASSI VO1_CHASSI, "
	cSQL += " VV1_MODVEI, "
	cSQL += " '' VO1_KILOME, "
	cSQL += " '' VO1_CODMAR, "
	cSQL += " '' VO1_MOTCOM, "
	cSQL += " '' D2_NUMSEQ, "
	cSQL += " 'BKO' OPERACAO,"
	cSQL += " B1_GRUPO D2_GRUPO,"
	cSQL += " VS3_CODSIT, "
	cSQL += " VS1_TIPTEM,"
	cSQL += " '' VO3_NOSNUM"
	cSQL += " FROM "+retSqlName('VS1')+" VS1"
	cSQL += " LEFT JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT = VS1_CHAINT AND VV1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VV1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('SF2')+" SF2 ON F2_FILIAL=? AND F2_DOC = VS1_NUMNFI AND F2_SERIE = VS1_SERNFI AND SF2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SF2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VS3')+" VS3 ON VS3_FILIAL=? AND VS3_NUMORC = VS1_NUMORC AND VS3.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS3') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SB1')+" SB1 ON B1_FILIAL=? AND B1_GRUPO = VS3_GRUITE AND B1_CODFAB = VS3_CODITE AND SB1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = VS3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VS1_TIPTEM = VOI_TIPTEM AND VOI.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VOI') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " WHERE VS1_FILIAL=?"
	cSQL += " AND VS1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	CSQL += 	" AND VS1_STATUS=?"
	CSQL += 	" AND VS1_TIPORC=?"
	CSQL += 	" AND VS1_PEDREF <> VS1_NUMORC "
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'C', 'P' } )

	cSQL += " UNION ALL "

	// coleta requisicoes PEÇAS - Oficina
	CSQL += " SELECT "
	cSQL += " AVG(VO3_VALPEC), "
	cSQL += " SUM(CASE "
	cSQL += 	" WHEN VO2_DEVOLU=?"
	cSQL += 	" THEN VO3_QTDREQ "
	cSQL += 	" ELSE VO3_QTDREQ * ?"
	cSQL += 	" END) QUANT, "
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'N', -1 } )
	cSQL += " VSJ_SEQINC ITEM, "
	cSQL += " VO1_NUMOSV, "
	cSQL += " VO1_DATABE, "
	cSQL += " VOI_SITTPO, "
	cSQL += " VO3_FATPAR, "
	cSQL += " VO3_LOJA, "
	cSQL += " '' DOC, "
	cSQL += " '' SERIE, "
	cSQL += " '' EMISSAO, "
	cSQL += " VO3_CODITE PRODUTO, "
	cSQL += " VO1_CHASSI, "
	cSQL += " VV1_MODVEI, "
	cSQL += " VO1_KILOME, "
	cSQL += " VO1_CODMAR, "
	cSQL += " VO1_MOTCOM, "
	cSQL += " '' NUMSEQ, "
	cSQL += " 'OFI' OPERACAO, "
	cSQL += " B1_GRUPO D2_GRUPO, "
	cSQL += " VO3_CODSIT VS3_CODSIT, "
	cSQL += " VO3_TIPTEM,"
//	cSQL += " max( VO3_NOSNUM ) VO3_NOSNUM"
	cSQL += " ("
	cSQL += 	" select max(s.VO3_NOSNUM)"
	cSQL += 	" from "+retSqlName("VO3")+" s "
	cSQL += 	" where s.VO3_FILIAL=?"
	cSQL += 	" and   s.VO3_NUMOSV=VO1_NUMOSV"
	cSQL += 	" and   s.VO3_CODITE=VO3.VO3_CODITE"
	cSQL += 	" and   s.VO3_DATCAN=?"
	cSQL += 	" and   s.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VO3') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += ") NOSNUM"

	cSQL += " FROM "+retSqlName('VO3')+" VO3 "
	cSQL += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = VO3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VOI_TIPTEM = VO3_TIPTEM AND VOI.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VOI') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=? AND VO2_NOSNUM = VO3_NOSNUM AND VO2.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VO2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VO1')+" VO1 ON VO1_FILIAL=? AND VO1_NUMOSV = VO3_NUMOSV AND VO1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VO1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT = VO1_CHAINT AND VV1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VV1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SB1')+" SB1 ON B1_FILIAL=? AND B1_CODFAB = VO3_CODITE AND B1_GRUPO = VO3_GRUITE AND SB1.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('VSJ')+" VSJ ON VSJ_FILIAL=? AND VSJ_NUMOSV=VO3_NUMOSV AND VSJ_CODITE=VO3_CODITE AND VSJ.D_E_L_E_T_=?"
	aAdd( aBind, { 'C', xFilial('VSJ') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " WHERE VO3.VO3_FILIAL=?"
	cSQL += " AND VO3.D_E_L_E_T_=?"
	cSQL += " AND VO3_DATFEC=?"
	cSQL += " AND VO3_DATCAN=?"
	aAdd( aBind, { 'C', xFilial('VO3') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " GROUP BY VSJ_SEQINC,VO1_NUMOSV,VO1_DATABE,VOI_SITTPO,VO3_FATPAR,VO3_LOJA,VO3_CODITE,VO1_CHASSI,VV1_MODVEI,VO1_KILOME,VO1_CODMAR,VO1_MOTCOM,B1_GRUPO,VO3_CODSIT, VO3_TIPTEM"
	cSQL += ") TEMP "
	cSQL += " group by D2_PRCVEN,D2_ITEM,VOO_NUMOSV,VO1_DATABE,VOI_SITTPO,D2_CLIENTE,D2_LOJA,VOO_NUMNFI,VOO_SERNFI,D2_EMISSAO,D2_COD,VO1_CHASSI,VV1_MODVEI,VO1_KILOME,VO1_CODMAR,VO1_MOTCOM,D2_NUMSEQ,OPERACAO,D2_GRUPO,VS3_CODSIT, VS1_TIPTEM, VO3_NOSNUM "
	cSQL += " HAVING SUM(D2_QUANT) > ?"
	aAdd( aBind, { 'N', 0 } )
	cSQL += " ) VE6 "

//	if cArm == "D01"	// Armazém Não Gerenciado
	if cArm != "F01"	// Armazém Não Gerenciado
		cSQL += " JOIN " + retSqlName('SB1') + " SB1 "
		cSQL += " ON  SB1.B1_FILIAL=?"
		cSQL += " AND SB1.B1_GRUPO in (?)"
		cSQL += " AND SB1.B1_COD = VE6.D2_COD"
		cSQL += " AND SB1.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('SB1') } )
		aAdd( aBind, { 'A', aGrupo } )
		aAdd( aBind, { 'C', ' ' } )
	else
		cSQL   += " JOIN " + retSqlName('VBF') + " VBF "
		cSQL   += " ON VE6.D2_COD = VBF_PRODUT"
		cSQL   += " AND VBF_FILIAL=?"
		cSQL   += " AND VBF_FLGUSO=?"
		cSQL   += " AND VBF_FLGARQ=?"
//		cSQL   += " AND VBF_ARMZEM=?"
		cSQL   += " AND VBF.D_E_L_E_T_=?"
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', '1' } )
		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', ' ' } )
	endif

	cSQL += " WHERE D2_QUANT > ? "
	aAdd( aBind, { 'N', 0 } )
	cSQL := OFCNHA015C_ExecQuery( cSQL, aBind, , , .T. )
Return cSQL


/*/{Protheus.doc} OFCNHA015C_ExecQuery
executa query com método FWPreparedStatement()
@type function
@author Cristiam Rossi
@since 23/05/2025
@param cQuery, character, string query
@param aBind, character, lista dos parâmetros
@param cAlias, character, alias que será aberto
@param cMsgErro, character, mensagem de erro
@param lQueryOnly, logical, se deve retornar apenas a query string pós bind
@return variant, se lQueryOnly: query; se for SELECT: Alias; se UPDATE: .T.
/*/
function OFCNHA015C_ExecQuery( cQuery, aBind, cAlias, cMsgErro, lQueryOnly )
local   nI
local   oStatement
local   xRet
default aBind       := {}
default cAlias      := getNextAlias()
default cMsgErro    := "Error: "
default lCloseAlias := .F.

	oStatement := FwExecStatement():new( cQuery )

	for nI := 1 to len( aBind )
		if aBind[nI,1] == "C"
			oStatement:setString( nI, aBind[nI,2] )
		elseif aBind[nI,1] == "N"
			oStatement:setNumeric( nI, aBind[nI,2] )
		elseif aBind[nI,1] == "D"
			oStatement:setDate( nI, aBind[nI,2] )
		elseif aBind[nI,1] == "A"
			oStatement:setIn( nI, aBind[nI,2] )
		else
			oStatement:setUnsafe( nI, aBind[nI,2] )
		endif		
	next

	cQuery := oStatement:getFixQuery()

	if lQueryOnly
		xRet := cQuery
	else
		if left( lower( cQuery ), 6 ) == "select"
			oStatement:OpenAlias( cAlias )
			dbSelectArea( cAlias )
			xRet := cAlias
		else
			if tcSqlExec( cQuery ) < 0
				if lDebug
					cMsgErro += CRLF + TCSQLError()
					oLogger:Log({"TIMESTAMP",STR0034 +" "+ TCSQLError()})	//#"Erro em query durante geração, verificar log."
				endif
				UserException( cMsgErro )
			endif
			xRet := .T.
		endif
	endif

	oStatement:destroy()
	FwFreeObj(oStatement)
return xRet


/*/{Protheus.doc} OFCNHA016C_getCancel
retorna número de vezes que um orçamento foi cancelado
@type function
@author Cristiam Rossi
@since 12/06/2025
@param cFilReg, character, Filial
@param cNumOri, character, Número do orçamento
@param cProdut, character, código do produto
@param cTipTem, character, tipo de tempo
@return character, número de cancelamentos do orçamento
/*/
static function OFCNHA016C_getCancel( cFilReg, cNumOri, cProdut, cTipTem )
local cAliasCur := alias()
local cRetorno  := "0"
local aBind     := {}
local cQuery
local cAlias    := getNextAlias()

	cQuery := "select count(*) QTDCANC"
	cQuery += " from "+retSqlName("VBD")+" VBD"
	cQuery += " where VBD_FILIAL=?"
	cQuery += " and   VBD_NUMORI=?"
	cQuery += " and   VBD_PRODUT=?"
	cQuery += " and   VBD_TIPTEM=?"
	cQuery += " and   VBD_INDCAN=?"
	cQuery += " and VBD.D_E_L_E_T_=?"
	aAdd( aBind, { "C", cFilReg } )
	aAdd( aBind, { "C", cNumOri } )
	aAdd( aBind, { "C", cProdut } )
	aAdd( aBind, { "C", cTipTem } )
	aAdd( aBind, { "C", "Y" } )
	aAdd( aBind, { "C", " " } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAlias )

	if ! (cAlias)->( eof() )
		cRetorno := cValToChar( (cAlias)->QTDCANC )
	endif
	(cAlias)->(dbCloseArea())

	dbSelectArea( cAliasCur )
return cRetorno


/*/{Protheus.doc} OFCNHA017C_inserirVCF
Insere clientes na tabela VCF
@type function
@author Cristiam Rossi
@since 16/06/2025
/*/
static function OFCNHA017C_inserirVCF( cCodCli, cLojCli )
local cAliasAtu  := alias()
local cQuery
local cAlias     := getNextAlias()
local aBind      := {}
local cCodCliVCF := ""
local oPrim      := OFCNHPrim():new()

	cQuery := "select VCF_CODCNH from "+retSqlName("VCF")+" VCF"
	cQuery += " where VCF_FILIAL=?"
	cQuery += " and   VCF_CODCLI=?"
	cQuery += " and   VCF_LOJCLI=?"
	cQuery += " and   VCF.D_E_L_E_T_=?"
	aAdd( aBind, { "C", xFilial("VCF") } )
	aAdd( aBind, { "C", cCodCli } )
	aAdd( aBind, { "C", cLojCli } )
	aAdd( aBind, { "C", " " } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAlias )

	if ! (cAlias)->( eof() )
		cCodCliVCF := (cAlias)->VCF_CODCNH
	else
		recLock( "VCF", .T. )
		VCF->VCF_FILIAL := xFilial("VCF")
		VCF->VCF_CODCLI := cCodCli
		VCF->VCF_LOJCLI := cLojCli
		VCF->VCF_CODCNH := GetSxeNum("VCF","VCF_CODCNH")
		VCF->VCF_SUBCAN := oPrim:SubCanalPadrao()
		msUnlock()
		confirmSx8()
		cCodCliVCF := VCF->VCF_CODCNH
	endif
	(cAlias)->( dbCloseArea() )
	dbSelectArea( cAliasAtu )
return cCodCliVCF


/*/{Protheus.doc} OFCNHA018C_getLinVen
Insere clientes na tabela VCF
@type function
@author Cristiam Rossi
@since 16/06/2025
/*/
static function OFCNHA018C_getLinVen( cFil, cProd, cNumOri, cDoc, cSer, cCli, cLoj, nQuant, nDefault )
local   cAliasAtu := alias()
local   cAlias    := getNextAlias()
local   aBind     := {}
local   nSeq      := 0
local   cQuery
default cFil      := xFilial("VBD")
default cProd     := ""
default cNumOri   := ""
default cDoc      := ""
default cSer      := ""
default cCli      := ""
default cLoj      := ""
default nQuant    := 0
default nDefault  := nSeq

	cQuery := "select VBD_LINVEN from "+retSqlName("VBD")+" VBD "
	cQuery += " where VBD_FILIAL = ?"
	cQuery += " and   VBD_PRODUT = ?"
	aAdd( aBind, { "C", cFil } )
	aAdd( aBind, { "C", cProd } )
	if ! empty( cDoc )
		cQuery += " and   VBD_NUMNFI = ?"
		cQuery += " and   VBD_SERORI = ?"
		aAdd( aBind, { "C", cDoc } )
		aAdd( aBind, { "C", cSer } )
	endif

	if ! empty( cNumOri )
		cQuery += " and   VBD_NUMORI = ?"
		aAdd( aBind, { "C", cNumOri } )
	endif

	cQuery += " and   VBD_CODCLI = ?"
	cQuery += " and   VBD_LOJCLI = ?"
	cQuery += " and   VBD.D_E_L_E_T_ = ?"
	aAdd( aBind, { "C", cCli } )
	aAdd( aBind, { "C", cLoj } )
	aAdd( aBind, { "C", " " } )
/*
	cQuery += " and not exists ("
	cQuery += 		"select 1 from "+retSqlName("VBD")+" VBD "
	cQuery += 		" where VBD_FILIAL = ?"
	cQuery += 		" and   VBD_PRODUT = ?"
	aAdd( aBind, { "C", cFil } )
	aAdd( aBind, { "C", cProd } )
	if ! empty( cDoc )
		cQuery += 	" and   VBD_NUMNFI = ?"
		cQuery += 	" and   VBD_SERORI = ?"
		aAdd( aBind, { "C", cDoc } )
		aAdd( aBind, { "C", cSer } )
	endif

	if ! empty( cNumOri )
		cQuery += 	" and   VBD_NUMORI = ?"
		aAdd( aBind, { "C", cNumOri } )
	endif

	cQuery += 		" and   VBD_CODCLI = ?"
	cQuery += 		" and   VBD_LOJCLI = ?"
	cQuery += 		" and   VBD.D_E_L_E_T_ = ?"
	aAdd( aBind, { "C", cCli } )
	aAdd( aBind, { "C", cLoj } )
	aAdd( aBind, { "C", " " } )
	cQuery += ")"
*/
	cQuery += " order by R_E_C_N_O_ desc"
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAlias )

	if ! (cAlias)->( eof() )
		nSeq := (cAlias)->VBD_LINVEN
	endif
	(cAlias)->(dbCloseArea())

	if nSeq == 0
		aBind  := {}
		cQuery := "select max(VBD_LINVEN) MAXLINVEN from "+retSqlName("VBD")+" VBD "
		cQuery += " where VBD_FILIAL = ?"
		aAdd( aBind, { "C", cFil } )
		if ! empty( cDoc )
			cQuery += " and   VBD_NUMNFI = ?"
			cQuery += " and   VBD_SERORI = ?"
			aAdd( aBind, { "C", cDoc } )
			aAdd( aBind, { "C", cSer } )
		endif

		if ! empty( cNumOri )
			cQuery += " and   VBD_NUMORI = ?"
			aAdd( aBind, { "C", cNumOri } )
		endif

		cQuery += " and   VBD_CODCLI = ?"
		cQuery += " and   VBD_LOJCLI = ?"
		cQuery += " and   VBD.D_E_L_E_T_ = ?"
		aAdd( aBind, { "C", cCli } )
		aAdd( aBind, { "C", cLoj } )
		aAdd( aBind, { "C", " " } )
		OFCNHA015C_ExecQuery( @cQuery, aBind, cAlias )

		if ! (cAlias)->( eof() )
			nSeq := (cAlias)->MAXLINVEN
		endif
		(cAlias)->(dbCloseArea())

		nSeq++
	endif

	dbSelectArea( cAliasAtu )
return nSeq
