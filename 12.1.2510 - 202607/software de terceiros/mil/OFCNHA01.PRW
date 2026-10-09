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
	"",;
	,;
	.F.,;
	.T.;
	}
Return aParam


/*/{Protheus.doc} Processo
	Função principal que gera os dados
	@type function
	@author Vinicius Gati
	@since 16/01/2018
/*/
function OFCNHA0101_Processo( aData, cTpPrim )
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
private cDatExt     := FwTimeStamp(1) // data da extracao atual
private cSGBD       := TcGetDb()
private lAbatReserv := getMV("MV_TPSALDO") $ "S;C" .and. getMV("MV_SLDRESE") == "S"
private aOrcs       := {}
Default aData       := oPrim:PRIMPadrao( cFilAnt )
Default cTpPrim     := "PRIM02"

	oLogger     := DMS_Logger():New( cTpPrim + "_"+DTOS(dDatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")

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

	cUltExt := DtoS( aData[1,3] ) + "000000"

	oLogger:Log({"TIMESTAMP", STR0061 + cFilAnt})	// #"Iniciando Geração de dados para filial: "

	// coleta data da ultima geração
	if aData[1,7] == oPrim:CodGerNormal()
		cQuery := "select" + CRLF
		cQuery += " coalesce( MAX(?), ? ) ULTEXTR" + CRLF
		cQuery += " FROM "+retSqlName("VBB")+" VBB" + CRLF
		cQuery += " WHERE VBB_FILIAL = ?" + CRLF
		cQuery += " AND VBB.D_E_L_E_T_ = ?" + CRLF
		OFCNHA015C_ExecQuery( @cQuery, {{'U',cCpoDtHr},{'C',cDatExt},{'C',xFilial("VBB")},{'C',space(1)}}, cAlias )
		if ! (cAlias)->( eof() )
			cUltExt := (cAlias)->ULTEXTR
		endif
		(cAlias)->( dbCloseArea() )
	endif

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
		cFilePath := oPrim:GeraArquivo( aVBBs, cTpPrim )

		cMsgLog += STR0013 + aData[1,12] + CRLF		// #"Número envio: "
		cMsgLog += STR0014 + transform(cUltExt, "@R 9999-99-99 99:99:99" ) + CRLF		// #"Extração anterior: "
		cMsgLog += STR0016 + cFilePath + CRLF + CRLF		// #"arquivo gerado: "
		cMsgLog += "OFCNHA01 - "+STR0015+" - " + DtoC(date()) + " " + time() + CRLF
	endif

	OA060004C_log( /*cAgroup*/ "PRIM", /*cTipo*/ cTpPrim, cMsgLog, /*lSendMail*/ .T. )

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
local cAl      := GetNextAlias()
local cQuery   := ''
local cCodMerc := oConf:cMarket
local cCodCorp := oConf:cDealerCode
local aBind    := {}


	if cTipoGer == oPrim:CodGerNormal()
// -------------- flutuações em backorder
		oLogger:Log({"TIMESTAMP", STR0074})	// #Estoque - Flutuações BackOrder
		aBind := {}
		cQuery := "select ULTIMOVBC.*, BACKORDER.* from (" + CRLF
		cQuery += "  SELECT * FROM (" + CRLF
		cQuery += "      SELECT " + CRLF
		cQuery += "  		VBC_PRODUT, " + CRLF
		cQuery += "  		VBC_QTDEST, " + CRLF
		cQuery += "  		VBC_QTDENC, " + CRLF
		cQuery += "  		VBC_BACKOR, " + CRLF
		cQuery += "  		VBC_QTDRES, " + CRLF
		cQuery += "             ROW_NUMBER() OVER (PARTITION BY VBC_PRODUT ORDER BY VBC_CODIGO DESC) AS rn " + CRLF
		cQuery += "      FROM "+retSqlName("VBC")+" VBC " + CRLF
		cQuery += "      JOIN "+retSqlName("VBB")+" VBB " + CRLF
		cQuery += "         on  VBB_FILIAL = VBC_FILIAL " + CRLF
		cQuery += "         and VBB_CODIGO = VBC_CODVBB " + CRLF
		cQuery += "         and VBB_CATTRA = ? " + CRLF
		aAdd( aBind, {'C', 'G' } )
		cQuery += "         and VBB.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, {'C', ' ' } )
		cQuery += " 	where VBC_FILIAL = ? " + CRLF
		aAdd( aBind, {'C', xFilial("VBC")} )
		cQuery += " 	and   VBC.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, {'C', ' '} )
	//	cQuery += "     and   VBB_DATA > ?" + CRLF
	//	aAdd( aBind, {'C', DtoS( dDatabase-30 ) } )
		cQuery += "  ) AS sub  " + CRLF
		cQuery += "  WHERE rn = ? " + CRLF
		aAdd( aBind, {'N', 1 } )
		cQuery += " ) ULTIMOVBC " + CRLF

//		if cArm == "F01"
//			cQuery += " JOIN " + retSqlName('VBF') + " VBF ON VBF_FILIAL = ? AND VBF_PRODUT = VBC_PRODUT AND VBF.D_E_L_E_T_ = ? " + CRLF
//			aAdd( aBind, { 'C', xFilial("VBF") } )
//			aAdd( aBind, { 'C', ' ' } )
//		else
			cQuery += " JOIN " + retSqlName('SB1') + " SB1 ON B1_FILIAL = ? AND B1_COD = VBC_PRODUT AND SB1.D_E_L_E_T_ = ? "+ CRLF
			cQuery += " and B1_GRUPO in (?)" + CRLF
			aAdd( aBind, { 'C', xFilial("SB1") } )
			aAdd( aBind, { 'C', ' ' } )
			aAdd( aBind, {'A',aGrupos})
//		endif

		cQuery += " left join ( " + CRLF
		cQuery += "     select VS3_CODITE, SUM(TOTBACK) BACKORD from (" + CRLF
		cQuery += "     select " + CRLF
		cQuery += "         VS3_CODITE, " + CRLF
		cQuery += "         VS3_QTDAGU + VS3_QTDTRA TOTBACK " + CRLF
		cQuery += "     from "+retSqlName("VS1")+" VS1 " + CRLF
		cQuery += "     join "+retSqlName("VS3")+" VS3 " + CRLF
		cQuery += " 	    ON  VS3_FILIAL = VS1_FILIAL " + CRLF
		cQuery += " 	    AND VS3_NUMORC = VS1_NUMORC " + CRLF
		cQuery += " 	    AND VS3.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, {'C', ' '} )
		cQuery += "     where VS1_FILIAL = ? " + CRLF
		aAdd( aBind, {'C', xFilial("VS1")} )
		cQuery += "     and   VS1_TIPORC = ? " + CRLF
		aAdd( aBind, {'C', 'P' } )
		cQuery += "     and   VS1_STATUS = ? " + CRLF
		aAdd( aBind, {'C', '0' } )
	//	cQuery += "     and   VS1_PEDSTA <> ? " + CRLF
	//	aAdd( aBind, {'C', '2' } )

		cQuery += "     AND (VS1_PEDSTA in (?) and (VS3_QTDAGU > ? OR VS3_QTDTRA > ?)) 
		aAdd( aBind, {'A', {'0','1'} } )
		aAdd( aBind, {'N', 0 } )
		aAdd( aBind, {'N', 0 } )
		cQuery += "     AND VS1_PEDREF <> VS1_NUMORC  

		cQuery += "     and   VS1.D_E_L_E_T_=? " + CRLF
		aAdd( aBind, {'C', ' '} )

		cQuery += " union ALL " + CRLF

		cQuery += "     select VSJ_CODITE, case when VSJ_QTDAGU-VSJ_QTDREQ < 0 then 0 else VSJ_QTDAGU-VSJ_QTDREQ end " + CRLF
		cQuery += "     from "+retsqlname('VSJ')+" VSJ " + CRLF
		cQuery += "     join "+retsqlname('VB5')+" VB5 " + CRLF
		cQuery += "     	on  VB5_FILIAL=?" + CRLF
		cQuery += "         and VB5_CODVSJ = VSJ_CODIGO" + CRLF
		cQuery += "			and VB5_CODITE = VSJ_CODITE " + CRLF
		cQuery += "			and VB5_GRUITE = VSJ_GRUITE " + CRLF
		cQuery += "			and VB5.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VB5") } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "		where VSJ_FILIAL=?" + CRLF
		cQuery += "		and   VSJ_QTDITE>?" + CRLF
		cQuery += "		and   VSJ.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VSJ") } )
		aAdd( aBind, { 'N', 0 } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += "		) pec_ofi " + CRLF
		cQuery += "     GROUP BY VS3_CODITE " + CRLF
		cQuery += " ) BACKORDER " + CRLF
		cQuery += " on VBC_PRODUT = VS3_CODITE " + CRLF
		cQuery += " where VS3_CODITE is not null " + CRLF
		cQuery += " and VBC_BACKOR <> BACKORD " + CRLF
		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())
			OFCNHA019C_produtoMovimentado( (cAl)->VBC_PRODUT )
			(cAl)->( dbSkip() )
		endDo
		(cAl)->(dbCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado
	endif

// -------------- adicionando SB2 de produtos em Orçamento
	oLogger:Log({"TIMESTAMP", STR0075})	// #"Estoque - Criação saldo 0 p/ produtos sem SB2"
	aBind := {}
	cQuery := "select " + CRLF
	cQuery += " 	B1_COD," + CRLF
	cQuery += " 	NNR_CODIGO" + CRLF
	cQuery += " from "+retSqlName("SB1")+" SB1 " + CRLF

	cQuery += "  join ( " + CRLF
	cQuery += "     select distinct " + CRLF
	cQuery += "     VS3_GRUITE GRUITE, " + CRLF
	cQuery += "     VS3_CODITE CODITE " + CRLF
	cQuery += "     from "+retSqlName("VS3")+" VS3 " + CRLF
	cQuery += "     where VS3_FILIAL = ? " + CRLF
	aAdd( aBind, {'C', xFilial("VS3")} )
	cQuery += "     and VS3.D_E_L_E_T_ = ? " + CRLF
	aAdd( aBind, {'C',' '} )
	cQuery += "     ) itens " + CRLF
	cQuery += "     on  GRUITE = B1_GRUPO " + CRLF
	cQuery += "     and CODITE = B1_CODITE " + CRLF
	cQuery += " join "+retSqlName("NNR")+" NNR " + CRLF
	cQuery += " 	on NNR_FILIAL=?" + CRLF
	aAdd( aBind, {'C', xFilial("NNR")} )
	cQuery += " 	and NNR_VDADMS=?" + CRLF
	aAdd( aBind, {'C','1'} )
	cQuery += " 	and NNR.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, {'C',' '} )
//	if cArm == "F01"
//		cQuery += " join "+retSqlName("VBF")+" VBF " + CRLF
//		cQuery += " on VBF_FILIAL=?"
//		aAdd( aBind, {'C', xFilial("VBF")} )
//		cQuery += " and VBF_PRODUT = B1_COD" + CRLF
//		cQuery += " AND VBF_FLGUSO = ?"
//		aAdd( aBind, {'C','1'})
//		cQuery += "	and VBF.D_E_L_E_T_=?" + CRLF
//		aAdd( aBind, {'C',' '} )
//	endif 
	cQuery += " left join "+retSqlName("SB2")+" SB2 " + CRLF
	cQuery += " 	on  B2_FILIAL=?" + CRLF
	aAdd( aBind, {'C', xFilial("SB2")} )
	cQuery += " 	and B2_COD = B1_COD" + CRLF
	cQuery += " 	and B2_LOCAL = NNR_CODIGO" + CRLF
	cQuery += " 	and SB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, {'C',' '} )
	cQuery += " where B1_FILIAL=?" + CRLF
	aAdd( aBind, {'C', xFilial("SB1")} )
	if cArm != "F01"
		cQuery += " and B1_GRUPO in (?)" + CRLF
		aAdd( aBind, {'A',aGrupos})
	endif
	cQuery += " and B2_COD is null" + CRLF
	cQuery += " and SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, {'C',' '} )
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		CriaSB2( (cAl)->B1_COD, (cAl)->NNR_CODIGO )
		(cAl)->( dbSkip() )
	endDo
	(cAl)->(dbCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado

	reclock('VBB', .T.)
	VBB->VBB_FILIAL  := xFilial('VBB')
	VBB->VBB_CODIGO  := GetSxeNum('VBB', 'VBB_CODIGO'); confirmSx8()
	VBB->VBB_CATREG  := 'T'
	VBB->VBB_IDENTI  := 'ST'
	VBB->VBB_DATA    := StoD( iif( cTipoGer == oPrim:CodGerExcepcional(), "00010101", LEFT(cUltExt, 8) ) )
	VBB->VBB_HORA    := iif( cTipoGer == oPrim:CodGerExcepcional(), "000000"  , RIGHT( cUltExt, 6) )
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
//	VBB->VBB_DATP01 := iif( cTipoGer == oPrim:CodGerExcepcional(), cDatEst, '' )
	VBB->(MsUnlock())

	AADD(aVBBs, VBB->VBB_CODIGO)
	OFCNHA0103_GeraItensEstoque(cArm, cTipoGer, VBB->VBB_CODIGO, dDtEst)
return .t.


/*/{Protheus.doc} OFCNHA0103_GeraItensEstoque
	Gera os itens do estoque prim2
	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0103_GeraItensEstoque(cArm, cTipoGer, cCodVBB, dDtEst)
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
local nBackOrd   := 0

	OFCNHA015C_ExecQuery( @cQuery, {{'C',xFilial("NNR")},{'C','1'},{'C',space(1)}},,,.T. )
	TcSqlToArr( cQuery, aLocais )

	Pergunte("MTA260",.F.)
	nParam03 := MV_PAR03

	SB1->( dbSetOrder(1) )
	SB2->( dbSetOrder(1) )

	oLogger:Log({"TIMESTAMP","  |> "+STR0022})	// #Gerando Itens de estoque

	if cArm != "F01"	// Armazéns não Gerenciados
		cQuery := "SELECT PRINCIPAL.* FROM ( " + CRLF
		cQuery += "SELECT " + CRLF
		cQuery += "		SB1.B1_COD, " + CRLF
		cQuery += "		B1_DESC, " + CRLF
		cQuery += "		COALESCE(B2_QATU,0) - COALESCE(B2_QACLASS,0) " + iif( lAbatReserv, "- COALESCE(B2_RESERVA,0)", "" ) + " B2_QATU, " + CRLF
		cQuery += "		COALESCE(TOTENC,0) 'TOTENC', " + CRLF
		cQuery += "		COALESCE(BACKORD,0) 'TOTBACK', " + CRLF
		cQuery += "		(COALESCE(RESERVA.SOMA_BAL,0) + COALESCE(RESERVA.SOMA_OFI,0)) 'TOTRESERV' " + CRLF
		cQuery += "	FROM "+retSqlName("SB1")+" SB1 " + CRLF
		cQuery += "	left JOIN "+retSqlName("SB2")+" SB2 " + CRLF
		cQuery += "		ON  B2_FILIAL = ? " + CRLF
		aAdd( aBind, { 'C', xFilial("SB2") } )
		cQuery += "		AND B2_COD = SB1.B1_COD " + CRLF
		cQuery += "		AND B2_LOCAL = B1_LOCPAD " + CRLF
		cQuery += "		AND B2_STATUS = ? " + CRLF
		aAdd( aBind, { 'C', '1' } )		// saldo disponível
		cQuery += "		AND SB2.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "	LEFT JOIN ( " + CRLF

		cQuery += "   select C7_PRODUTO, SUM(TOTENC) TOTENC " + CRLF
		cQuery += "   from (" + CRLF

		cQuery += "		SELECT C7_PRODUTO, C7_QUANT-C7_QUJE TOTENC  " + CRLF// incluir a quantidade de orçamentos de transferência com filial destino.
		cQuery += "		FROM "+retSqlName("SC7")+" SC7  " + CRLF
		cQuery += "		WHERE SC7.C7_FILIAL=? " + CRLF
		aAdd( aBind, { 'C', xFilial("SC7") } )
		cQuery += "		AND C7_RESIDUO = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "		AND SC7.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
//		cQuery += "		GROUP BY C7_PRODUTO " + CRLF

		cQuery += "		union all " + CRLF

		cQuery += "		SELECT VDD_CODITE, VDD_QUANT" + CRLF
		cQuery += "		FROM "+retSqlName("VDD")+" VDD " + CRLF
		cQuery += "		WHERE VDD_STATUS NOT IN (?)" + CRLF
		aAdd( aBind, { 'A', {'R','C','S',''} } )
		cQuery += "			AND VDD_FILIAL  = ?" + CRLF
		aAdd( aBind, { 'C', xFilial("VDD") } )
		cQuery += "			AND (VDD_FILOSV  = ? OR VDD_FILORC  = ?)" + CRLF
		aAdd( aBind, { 'C', xFilial("SC7") } )
		aAdd( aBind, { 'C', xFilial("SC7") } )
		cQuery += "			AND VDD.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
//		cQuery += "		GROUP BY VDD_CODITE" + CRLF

		cQuery += "		) SC7_VDD" + CRLF
		cQuery += "     group by C7_PRODUTO" + CRLF

		cQuery += "	) ENCOMENDA " + CRLF
		cQuery += "		ON SB1.B1_COD = C7_PRODUTO " + CRLF
		cQuery += "	LEFT JOIN ( " + CRLF
		cQuery += "		SELECT VS3_CODITE, SUM( AGU_TRA ) AS BACKORD " + CRLF
		cQuery += " 		from (" + CRLF
		cQuery += "		SELECT VS3_CODITE, VS3_QTDAGU + VS3_QTDTRA AGU_TRA" + CRLF
		cQuery += "		FROM "+retSqlName("VS1")+" VS1  " + CRLF
		cQuery += "		JOIN "+retSqlName("VS3")+" VS3  " + CRLF
		cQuery += "			ON  VS3_FILIAL = VS1_FILIAL  " + CRLF
		cQuery += "			AND VS3_NUMORC = VS1_NUMORC  " + CRLF
		cQuery += "			AND VS3.D_E_L_E_T_=? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "		WHERE VS1_FILIAL=? " + CRLF
		aAdd( aBind, { 'C', xFilial("VS1") } )
		cQuery += "		AND VS1_STATUS=? " + CRLF
		aAdd( aBind, { 'C', '0' } )
		cQuery += "		AND VS1_TIPORC=? " + CRLF
		aAdd( aBind, { 'C', 'P' } )
		cQuery += "		AND (VS1_PEDSTA in (?) and (VS3_QTDAGU > ? OR VS3_QTDTRA > ?)) " + CRLF
		aAdd( aBind, { 'A', {'0','1'} } )
		aAdd( aBind, { 'N', 0 } )
		aAdd( aBind, { 'N', 0 } )

		cQuery += "		AND VS1_PEDREF <> VS1_NUMORC  " + CRLF
		cQuery += "		AND VS1.D_E_L_E_T_=? " + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += "		union all " + CRLF

		cQuery += 	" select VSJ_CODITE, case when VSJ_QTDAGU-VSJ_QTDREQ < 0 then 0 else VSJ_QTDAGU-VSJ_QTDREQ end " + CRLF
		cQuery += 	" from "+retsqlname('VSJ')+" VSJ " + CRLF
		cQuery += 	" join "+retsqlname('VB5')+" VB5 " + CRLF
		cQuery += 		" on  VB5_FILIAL=?" + CRLF
		cQuery += 		" and VB5_CODVSJ = VSJ_CODIGO " + CRLF
		cQuery += 		" and VB5_CODITE = VSJ_CODITE " + CRLF
		cQuery += 		" and VB5_GRUITE = VSJ_GRUITE " + CRLF
		cQuery += 		" and VB5.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VB5") } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 	" where VSJ_FILIAL=?" + CRLF
		cQuery += "		and   VSJ_QTDITE>?" + CRLF
		cQuery += "		and   VSJ.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VSJ") } )
		aAdd( aBind, { 'N', 0 } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += "		) pec_ofi " + CRLF
		cQuery += "		GROUP BY VS3_CODITE " + CRLF
		cQuery += "	) BACKORDER " + CRLF
		cQuery += "		ON SB1.B1_COD = VS3_CODITE " + CRLF
		cQuery += "	LEFT JOIN ( " + CRLF
		cQuery += OFCNHA013C_getQryRes( cArm )		// reservas - estoque
		cQuery += "	) RESERVA " + CRLF
		cQuery += "		ON RESERVA.B1_COD = SB1.B1_COD " + CRLF
		cQuery += "	WHERE B1_FILIAL = ? " + CRLF
		aAdd( aBind, { 'C', xFilial("SB1") } )

		cQuery += "	AND   B1_GRUPO in (?) " + CRLF
		aAdd( aBind, { 'A', aGrupos } )

		cQuery += "	AND   SB1.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "	AND B1_MSBLQL != ? " + CRLF
		aAdd( aBind, { 'C', '1' } )
		cQuery += "	AND ( B2_QATU >= ? or B2_QATU is null ) " + CRLF
		aAdd( aBind, { 'N', 0 } )
		cQuery += ") PRINCIPAL " + CRLF
		cQuery += " left JOIN ( " + CRLF
		cQuery += " SELECT * FROM ( " + CRLF
		cQuery += "     SELECT  " + CRLF
		cQuery += " 		VBC_PRODUT, " + CRLF
		cQuery += " 		VBC_QTDEST, " + CRLF
		cQuery += " 		VBC_QTDENC, " + CRLF
		cQuery += " 		VBC_BACKOR, " + CRLF
		cQuery += " 		VBC_QTDRES, " + CRLF
		cQuery += "            ROW_NUMBER() OVER (PARTITION BY VBC_PRODUT ORDER BY VBC_CODIGO DESC) AS rn " + CRLF
		cQuery += "     FROM "+retSqlName("VBC")+" VBC " + CRLF
		cQuery += "     JOIN "+retSqlName("VBB")+" VBB " + CRLF
		cQuery += "         on  VBB_FILIAL = VBC_FILIAL" + CRLF
//		cQuery += "         and VBB_DATA2 > ?"
//		aAdd( aBind, { 'C', DtoS(dDatabase-3) } )
		cQuery += "		    and VBB.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "		where VBC_FILIAL = ? " + CRLF
		aAdd( aBind, { 'C', xFilial("VBC") } )
		cQuery += "		and   VBC.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " ) AS sub " + CRLF
		cQuery += " WHERE rn = ? " + CRLF
		aAdd( aBind, { 'N', 1 } )
		cQuery += ") ULTIMO " + CRLF
		cQuery += "	ON  B1_COD = VBC_PRODUT " + CRLF
//		cQuery += "	AND B2_QATU = VBC_QTDEST " + CRLF
		cQuery += "	AND TOTENC = VBC_QTDENC " + CRLF
		cQuery += "	AND TOTBACK = VBC_BACKOR " + CRLF
		cQuery += "	AND TOTRESERV = VBC_QTDRES " + CRLF
		cQuery += " WHERE ( VBC_PRODUT is null" + CRLF
		cQuery += "	AND B2_QATU + TOTENC + TOTBACK + TOTRESERV > ? )" + CRLF
		aAdd( aBind, { 'N', 0 } )

	else
		cQuery := "SELECT PRINCIPAL.* FROM ( " + CRLF
		cQuery += "SELECT " + CRLF
		cQuery += "		SB1.B1_COD, " + CRLF
		cQuery += "		B1_DESC, " + CRLF
		cQuery += "		COALESCE(B2_QATU,0) - COALESCE(B2_QACLASS,0) " + iif( lAbatReserv, "- COALESCE(B2_RESERVA,0)", "" ) + " B2_QATU, " + CRLF
		cQuery += "		COALESCE(TOTENC,0) 'TOTENC', " + CRLF
		cQuery += "		COALESCE(BACKORD,0) 'TOTBACK', " + CRLF
		cQuery += "		(COALESCE(RESERVA.SOMA_BAL,0) + COALESCE(RESERVA.SOMA_OFI,0)) 'TOTRESERV' " + CRLF
		cQuery += "	FROM "+retSqlName("SB1")+" SB1 " + CRLF

//		cQuery += " JOIN " + retSqlName('VBF') + " VBF ON VBF_FILIAL = ? AND SB1.B1_COD = VBF_PRODUT AND VBF.D_E_L_E_T_ = ? " + CRLF
//		aAdd( aBind, { 'C', xFilial("VBF") } )
//		aAdd( aBind, { 'C', ' ' } )

		cQuery += "	LEFT JOIN "+retSqlName("SB2")+" SB2 " + CRLF
		cQuery += "		ON  B2_FILIAL = ? " + CRLF
		aAdd( aBind, { 'C', xFilial("SB2") } )
		cQuery += "		AND B2_COD = SB1.B1_COD " + CRLF
		cQuery += "		AND B2_LOCAL = B1_LOCPAD " + CRLF
		cQuery += "		AND SB2.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "	LEFT JOIN ( " + CRLF

		cQuery += "   select C7_PRODUTO, SUM(TOTENC) TOTENC " + CRLF
		cQuery += "   from (" + CRLF

		cQuery += "		SELECT C7_PRODUTO, C7_QUANT-C7_QUJE TOTENC  " + CRLF
		cQuery += "		FROM "+retSqlName("SC7")+" SC7  " + CRLF
		cQuery += "		WHERE SC7.C7_FILIAL=? " + CRLF
		aAdd( aBind, { 'C', xFilial("SC7") } )
		cQuery += "		AND C7_RESIDUO = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "		AND SC7.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += "		union all " + CRLF

		cQuery += "		SELECT VDD_CODITE, VDD_QUANT" + CRLF
		cQuery += "		FROM "+retSqlName("VDD")+" VDD " + CRLF
		cQuery += "		WHERE VDD_STATUS NOT IN (?)" + CRLF
		aAdd( aBind, { 'A', {'R','C','S',''} } )
		cQuery += "			AND VDD_FILIAL  = ?" + CRLF
		aAdd( aBind, { 'C', xFilial("VDD") } )
		cQuery += "			AND (VDD_FILOSV  = ? OR VDD_FILORC  = ?)" + CRLF
		aAdd( aBind, { 'C', xFilial("SC7") } )
		aAdd( aBind, { 'C', xFilial("SC7") } )

		cQuery += "			AND VDD.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += "		) SC7_VDD" + CRLF
		cQuery += "   GROUP BY C7_PRODUTO" + CRLF

		cQuery += "	) ENCOMENDA " + CRLF
		cQuery += "		ON SB1.B1_COD = C7_PRODUTO " + CRLF
		cQuery += "	LEFT JOIN ( " + CRLF
		cQuery += "		SELECT VS3_CODITE, SUM( AGU_TRA ) AS BACKORD " + CRLF
		cQuery += " 		from (" + CRLF
		cQuery += "		SELECT VS3_CODITE, VS3_QTDAGU + VS3_QTDTRA AGU_TRA" + CRLF
		cQuery += "		FROM "+retSqlName("VS1")+" VS1  " + CRLF
		cQuery += "		JOIN "+retSqlName("VS3")+" VS3  " + CRLF
		cQuery += "			ON  VS3_FILIAL = VS1_FILIAL  " + CRLF
		cQuery += "			AND VS3_NUMORC = VS1_NUMORC  " + CRLF
		cQuery += "			AND VS3.D_E_L_E_T_=? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "		WHERE VS1_FILIAL=? " + CRLF
		aAdd( aBind, { 'C', xFilial("VS1") } )
		cQuery += "		AND VS1_STATUS=? " + CRLF
		aAdd( aBind, { 'C', '0' } )
		cQuery += "		AND VS1_TIPORC=? " + CRLF
		aAdd( aBind, { 'C', 'P' } )
		cQuery += "		AND (VS1_PEDSTA in (?) and (VS3_QTDAGU > ? OR VS3_QTDTRA > ?)) " + CRLF
		aAdd( aBind, { 'A', {'0','1'} } )
		aAdd( aBind, { 'N', 0 } )
		aAdd( aBind, { 'N', 0 } )

		cQuery += "		AND VS1_PEDREF <> VS1_NUMORC  " + CRLF
		cQuery += "		AND VS1.D_E_L_E_T_=? " + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += "		union all " + CRLF

		cQuery += 	" select VSJ_CODITE, case when VSJ_QTDAGU-VSJ_QTDREQ < 0 then 0 else VSJ_QTDAGU-VSJ_QTDREQ end " + CRLF
		cQuery += 	" from "+retsqlname('VSJ')+" VSJ " + CRLF
		cQuery += 	" join "+retsqlname('VB5')+" VB5 " + CRLF
		cQuery += 		" on  VB5_FILIAL=?" + CRLF
		cQuery += 		" and VB5_CODVSJ = VSJ_CODIGO " + CRLF
		cQuery += 		" and VB5_CODITE = VSJ_CODITE " + CRLF
		cQuery += 		" and VB5_GRUITE = VSJ_GRUITE " + CRLF
		cQuery += 		" and VB5.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VB5") } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 	" where VSJ_FILIAL=?" + CRLF
		cQuery += "		and   VSJ_QTDITE>?" + CRLF
		cQuery += "		and   VSJ.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VSJ") } )
		aAdd( aBind, { 'N', 0 } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += "		) pec_ofi " + CRLF
		cQuery += "		GROUP BY VS3_CODITE " + CRLF
		cQuery += "	) BACKORDER " + CRLF
		cQuery += "		ON SB1.B1_COD = VS3_CODITE " + CRLF
		cQuery += "	LEFT JOIN ( " + CRLF
		cQuery += OFCNHA013C_getQryRes( cArm )		// reservas - estoque
		cQuery += "	) RESERVA " + CRLF
		cQuery += "		ON RESERVA.B1_COD = SB1.B1_COD " + CRLF
		cQuery += "	WHERE B1_FILIAL = ? " + CRLF
		aAdd( aBind, { 'C', xFilial("SB1") } )
		cQuery += "	AND   SB1.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "	AND B1_MSBLQL != ? " + CRLF
		aAdd( aBind, { 'C', '1' } )
		cQuery += "	AND ( B2_QATU >= ? OR B2_QATU is null )" + CRLF
		aAdd( aBind, { 'N', 0 } )

//		cQuery += " AND VBF_FLGUSO = ?" + CRLF
//		aAdd( aBind, { 'C', '1'} )
//		cQuery += " AND VBF_FLGARQ = ?" + CRLF
//		aAdd( aBind, { 'C', 'S'} )		

		cQuery += ") PRINCIPAL " + CRLF
		cQuery += " left JOIN ( " + CRLF
		cQuery += " SELECT * FROM ( " + CRLF
		cQuery += "     SELECT  " + CRLF
		cQuery += " 		VBC_PRODUT, " + CRLF
		cQuery += " 		VBC_QTDEST, " + CRLF
		cQuery += " 		VBC_QTDENC, " + CRLF
		cQuery += " 		VBC_BACKOR, " + CRLF
		cQuery += " 		VBC_QTDRES, " + CRLF
		cQuery += "            ROW_NUMBER() OVER (PARTITION BY VBC_PRODUT ORDER BY VBC_CODIGO DESC) AS rn " + CRLF
		cQuery += "     FROM "+retSqlName("VBC")+" VBC " + CRLF
		cQuery += "     JOIN "+retSqlName("VBB")+" VBB " + CRLF
		cQuery += "         on  VBB_FILIAL = VBC_FILIAL" + CRLF
		cQuery += "         and VBB_DATA2 > ?"
//		aAdd( aBind, { 'C', DtoS(dDatabase-3) } )
//		cQuery += "		    and VBB.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "		where VBC_FILIAL = ? " + CRLF
		aAdd( aBind, { 'C', xFilial("VBC") } )
		cQuery += "		and   VBC.D_E_L_E_T_ = ? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " ) AS sub " + CRLF
		cQuery += " WHERE rn = ? " + CRLF
		aAdd( aBind, { 'N', 1 } )
		cQuery += ") ULTIMO " + CRLF
		cQuery += "	ON  B1_COD = VBC_PRODUT " + CRLF
//		cQuery += "	AND B2_QATU = VBC_QTDEST " + CRLF
		cQuery += "	AND TOTENC = VBC_QTDENC " + CRLF
		cQuery += "	AND TOTBACK = VBC_BACKOR " + CRLF
		cQuery += "	AND TOTRESERV = VBC_QTDRES " + CRLF
		cQuery += " WHERE ( VBC_PRODUT is null" + CRLF
		cQuery += "	AND B2_QATU + TOTENC + TOTBACK + TOTRESERV > ? )" + CRLF
		aAdd( aBind, { 'N', 0 } )
	endif

//		cQuery += " OR B1_COD in (?)"
//		aAdd( aBind, { 'A', aProdMov } )

	cQuery += " or B1_COD in (" + CRLF
	cQuery += " select distinct VBD_PRODUT" + CRLF
	cQuery += " from "+retSqlName("VBD") + CRLF
	cQuery += " where VBD_CODVBB = ? " + CRLF
	aAdd( aBind, { 'C', aVBBs[ len(aVBBs)-1 ] } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " union " + CRLF
		cQuery += " select B1_COD " + CRLF
		cQuery += " from " + retSqlName("SB1") + CRLF
		cQuery += " where B1_COD in (?)"+ CRLF
		aAdd( aBind, { 'A', aProdMov } )
	endif

	cQuery += " ) " + CRLF

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())

		if aScan( aProdutos, (cAl)->B1_COD ) == 0
			aAdd( aProdutos, (cAl)->B1_COD )

			nRegs++
			aQAtuCust := OFCNHA012C_getQAtuCust( (cAl)->B1_COD, nParam03, aLocais, lSBZ )

			nBackOrd := iif( (cAl)->TOTBACK > 0, (cAl)->TOTBACK - (aQAtuCust[1] + (cAl)->TOTRESERV), 0 )

			reclock('VBC', .T.)
			VBC->VBC_FILIAL := xFilial('VBC')
			VBC->VBC_CODIGO := GetSxeNum('VBC', 'VBC_CODIGO'); confirmSx8()
			VBC->VBC_CODVBB := cCodVBB
			VBC->VBC_PRODUT := (cAl)->B1_COD
			VBC->VBC_QTDEST := aQAtuCust[1]
			VBC->VBC_QTDENC := (cAl)->TOTENC
			VBC->VBC_BACKOR := iif( nBackOrd > 0, nBackOrd, 0 )
			VBC->VBC_CUSMED := aQAtuCust[2]
			VBC->VBC_ESTOCA := aQAtuCust[3]
			VBC->VBC_ESTMIN := aQAtuCust[4]
			VBC->VBC_QTDRES := (cAl)->TOTRESERV
			VBC->VBC_FUTRES := 0
			VBC->VBC_DESPRO := left((cAl)->B1_DESC, nSizeDes)
			VBC->VBC_CODFOR := ''
			VBC->VBC_FORNAM := ''
			VBC->(MsUnlock())

			if lDebug
				cPrdList += iif( empty(cPrdList), "", ", " ) + alltrim(VBC->VBC_PRODUT)
			endif
		endif
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
local cCodMerc := oConf:cMarket
local cCodCorp := oConf:cDealerCode
Private cPrefBal    := GetNewPar("MV_PREFBAL","BAL")
Private cPrefOfi    := GetNewPar("MV_PREFOFI","OFI")

	reclock('VBB', .T.)
	VBB->VBB_FILIAL  := xFilial('VBB')
	VBB->VBB_CODIGO  := GetSxeNum('VBB', 'VBB_CODIGO'); confirmSx8()
	VBB->VBB_CATREG  := 'T'
	VBB->VBB_IDENTI  := 'SE' // SE=Venda, ST=Estoque
	VBB->VBB_DATA    := SToD(LEFT(cDatExt, 8))
	VBB->VBB_HORA    := RIGHT( cDatExt , 6)
	VBB->VBB_DATA2   := SToD(LEFT(cUltExt, 8))
	VBB->VBB_HORA2   := RIGHT( cUltExt, 6)
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

	OFCNHA0105GeraItensVendas(cArm, VBB->VBB_CODIGO, dData1, dData2, cTipoGer)
	AADD(aVBBs, VBB->VBB_CODIGO)
return .T.


/*/{Protheus.doc} OFCNHA0105GeraItensVendas
	Gera cabecalho das vendas
	@type function
	@author Vinicius Gati
	@since 21/02/2018
/*/
function OFCNHA0105GeraItensVendas(cArm, cCodVBB, dDataIni, dDataFim, cTipoGer)
local cQuery     := ''
local cAl        := GetNextAlias()
local cA2        := GetNextAlias()
local nI
//local aOrcs      := {}
local nItem
local nRegs      := 0
local aBind      := {}

	if cTipoGer == oPrim:CodGerNormal()
		oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 1"})	// # cancelados 1
		aBind  := {}
		cQuery := "select VS1_NUMORC, VS1_TIPORC, VS1_CLIFAT, VS1_LOJA, VS1_NCLIFT, VS1_NUMNFI, VS1_SERNFI, VS1_DATORC, VS1_MOTCOM, VV1_CODMAR, VV1_MODVEI, VS1_KILOME," + CRLF
		cQuery += " VS3_SEQUEN, VS3_CODITE, VS3_QTDITE, VS3_QTDINI, VS3_VALPEC," + CRLF
		cQuery += " F2_EMISSAO, F2_DOC," + CRLF
		cQuery += " D2_QUANT," + CRLF
		cQuery += " VV1_CHASSI, VV1_CODMAR, VV1_MODVEI," + CRLF
		cQuery += " VOI_SITTPO," + CRLF
		cQuery += " VBD.*" + CRLF
		cQuery += " from "+retSqlName("VS1")+" VS1 " + CRLF
		cQuery += " join "+retSqlName("VS3")+" VS3 " + CRLF
		cQuery += 	" on  VS3_FILIAL=VS1_FILIAL" + CRLF
		cQuery += 	" and VS3_NUMORC=VS1_NUMORC" + CRLF
		cQuery +=   " and VS3.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " left join "+retSqlName('VOI')+" VOI " + CRLF
		cQuery += 	" on  VOI_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VOI") } )
		cQuery += 	" and VOI_TIPTEM = VS1_TIPTEM" + CRLF
		cQuery += 	" and VOI.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " left join "+retSqlName("SF2")+" SF2 " + CRLF
		cQuery += 	" on  F2_FILIAL = VS1_FILIAL" + CRLF
		cQuery += 	" and F2_DOC    = VS1_NUMNFI" + CRLF
		cQuery += 	" and F2_SERIE  = VS1_SERNFI" + CRLF
		cQuery +=   " and SF2.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " left join "+retSqlName("SD2")+" SD2 " + CRLF
		cQuery += 	" on  D2_FILIAL = VS1_FILIAL" + CRLF
		cQuery += 	" and D2_DOC    = VS1_NUMNFI" + CRLF
		cQuery += 	" and D2_SERIE  = VS1_SERNFI" + CRLF
		cQuery += 	" and D2_COD    = VS3_CODITE" + CRLF
		cQuery +=   " and SD2.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " left join "+retSqlName("SF4")+" SF4 " + CRLF
		cQuery += 	" on  F4_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial("SF4") } )
		cQuery += 	" and F4_CODIGO = D2_TES" + CRLF
		cQuery += 	" and F4_ESTOQUE = ?" + CRLF
		aAdd( aBind, { 'C', 'S' } )
		cQuery +=   " and SF4.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " left join "+retSqlName("VV1")+" VV1 " + CRLF
		cQuery += 	" on  VV1_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VV1") } )
		cQuery += 	" and VV1_CHAINT = VS1_CHAINT" + CRLF
		cQuery +=   " and VV1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " JOIN "+retSqlName('VBD')+" VBD " + CRLF
		cQuery +=   " ON  VBD_FILIAL=?"  + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += 	" AND VBD_CODIGO = (" + CRLF
		cQuery += 		" select MAX(VBD_CODIGO)" + CRLF
		cQuery += 		" from "+retSqlName("VBD") + CRLF
		cQuery += 		" where VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += 		" AND VBD_PRODUT = VS3_CODITE" + CRLF
		cQuery += 		" AND VBD_NUMORI = VS1_NUMORC" + CRLF
		cQuery += 		" AND VBD_SERORI = VS1_SERNFI" + CRLF
		cQuery +=   	" AND VBD_INDDEV <> ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodDev() } )
		cQuery +=   	" AND VBD_INDCAN <> ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		cQuery += 		" AND D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 	")" + CRLF

		cQuery += " where VS1_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VS1") } )
		cQuery += " and   VS1_STATUS <> ?" + CRLF			// excluir Loja
		aAdd( aBind, { 'C', 'X' } )
//		cQuery += " and   VS3_MOTPED <> ?" + CRLF			// Item cancelado
//		aAdd( aBind, { 'C', ' ' } )
		cQuery += " and   VS3_GRUITE IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )

		//if cTipoGer == oPrim:CodGerNormal()
			cQuery += " and not exists (" + CRLF
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
			cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
			cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
			cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
			cQuery +=               " and VBB_CATTRA = ?" + CRLF
			aAdd( aBind, { 'C', cTipoGer } )
			cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += 		" where DELTA.VBD_FILIAL=?" + CRLF
			aAdd( aBind, { 'C', xFilial("VBD") } )
			cQuery += 		" and   DELTA.VBD_PRODUT = VS3_CODITE" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMORI = VS1_NUMORC" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMNFI = VS1_NUMNFI" + CRLF
			cQuery += 		" and   DELTA.VBD_SERORI = VS1_SERNFI" + CRLF
			cQuery += 		" and   DELTA.VBD_CODCLI = VS1_CLIFAT" + CRLF
			cQuery += 		" and   DELTA.VBD_LOJCLI = VS1_LOJA" + CRLF
		//	cQuery += 		" and   DELTA.VBD_QTDFAT = VS3_QTDINI"
			cQuery += 		" and   DELTA.VBD_QTDFAT = VS3_QTDITE" + CRLF
			cQuery += 		" and   DELTA.VBD_INDCAN=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			cQuery += 		" and   DELTA.VBD_ALIAS = VBD.VBD_ALIAS" + CRLF
			cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += ")" + CRLF
		//else
		//	cQuery += " AND VS1_DATORC BETWEEN ? AND ?" + CRLF
		//	aAdd( aBind, { 'D', dDataIni } )
		//	aAdd( aBind, { 'D', dDataFim } )
		//endif

		cQuery += " and VS1.D_E_L_E_T_=?" + CRLF
		cQuery += " order by VS1_NUMORC, VS3_CODITE" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

		//OFCNHA019C_produtoMovimentado( (cAl)->VS3_CODITE )

			reclock('VBD', .T.)
			VBD->VBD_CODVBB := cCodVBB
			VBD->VBD_FILIAL := xFilial('VBD')
			VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
			VBD->VBD_CODCLI := (cAl)->VS1_CLIFAT
			VBD->VBD_LOJCLI := (cAl)->VS1_LOJA
			VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
			VBD->VBD_NUMORI := (cAl)->VS1_NUMORC
			VBD->VBD_SERORI := (cAl)->VS1_SERNFI
			VBD->VBD_NUMREM := (cAl)->VS1_NUMNFI
			VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
													(cAl)->VS3_CODITE,;
													VBD->VBD_NUMORI,;
													(cAl)->VS1_NUMNFI,;
													(cAl)->VS1_SERNFI,;
													VBD->VBD_CODCLI,;
													VBD->VBD_LOJCLI,;
													(cAl)->VS3_QTDINI,;
													val( (cAl)->VS3_SEQUEN ),;
													VBD->VBD_NUMREM )
			VBD->VBD_NUMNFI := (cAl)->F2_DOC // (cAl)->VS1_NUMNFI
			VBD->VBD_DATORI := stod( (cAl)->VS1_DATORC )
			VBD->VBD_DATREM := stod((cAl)->F2_EMISSAO)
			VBD->VBD_DATNFI := stod((cAl)->F2_EMISSAO)
			VBD->VBD_CANALV := (cAl)->VBD_CANALV
			VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
			VBD->VBD_PRODUT := (cAl)->VS3_CODITE
			VBD->VBD_QTDPED := (cAl)->VS3_QTDITE // (cAl)->VS3_QTDINI
			VBD->VBD_QTDREM := (cAl)->VS3_QTDINI
			VBD->VBD_QTDFAT := (cAl)->VS3_QTDITE // (cAl)->VS3_QTDINI
			VBD->VBD_TIPDEM := (cAl)->VBD_TIPDEM
			VBD->VBD_CHASSI := (cAl)->VV1_CHASSI
			VBD->VBD_HORKIL := (cAl)->VS1_KILOME
			VBD->VBD_FABRIC := (cAl)->VV1_CODMAR
			VBD->VBD_MODELO := LEFT( (cAl)->VV1_MODVEI, tamsx3('VBD_MODELO')[1] )
			VBD->VBD_MOTCOM := (cAl)->VS1_MOTCOM
			VBD->VBD_VALVDA := (cAl)->VS3_VALPEC
			VBD->VBD_INDCAN := oPrim:CodCanc()
			VBD->VBD_INDDEV := oPrim:CodNaoDev()
		//	VBD->VBD_CODGAR := iif( (cAl)->VOI_SITTPO=="3", 'D' /*consumo interno*/, 'Z' /*venda normal*/ )
			VBD->VBD_CODGAR := oCanalVenda:retGarantia( (cAl)->VOI_SITTPO )
			VBD->VBD_ALIAS  := (cAl)->VBD_ALIAS
			VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->VBD_NUMSEQ := "CANC_1"
			VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

		oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 2"})	// # cancelados 2 - Reservas
		aBind  := {}
		cQuery := "select VS1_NUMORC, VS1_TIPORC, VS1_CLIFAT, VS1_LOJA, VS1_NCLIFT, VS1_NUMNFI, VS1_SERNFI, VS1_DATORC, VS1_MOTCOM, VS1_KILOME," + CRLF
		cQuery += " VBD.*" + CRLF
		cQuery += " from "+retSqlName("VS1")+" VS1 " + CRLF
		cQuery += " join "+retSqlName("VB2")+" VB2 " + CRLF
		cQuery += 	" on  VB2_FILIAL=VS1_FILIAL" + CRLF
		cQuery += 	" and VB2_NUMORC=VS1_NUMORC" + CRLF
		cQuery +=   " and VB2.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " JOIN "+retSqlName('VBD')+" VBD " + CRLF	// encontrar a venda antes
		cQuery +=   " ON  VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD') } )
		cQuery += 	" AND VBD_CODIGO = (" + CRLF
		cQuery += 		" select MAX(VBD_CODIGO)" + CRLF
		cQuery += 		" from "+retSqlName("VBD") + CRLF
		cQuery += 		" where VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD') } )
		cQuery += 		" AND VBD_PRODUT = VB2_CODITE" + CRLF
		cQuery += 		" AND VBD_NUMORI = VS1_NUMORC" + CRLF
		cQuery += 		" AND VBD_SERORI = VS1_SERNFI" + CRLF
		cQuery += 		" AND VBD_QTDFAT = VB2_QUANT" + CRLF
		cQuery +=   	" AND VBD_INDDEV <> ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodDev() } )
		cQuery +=   	" AND VBD_INDCAN <> ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		cQuery += 		" AND D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 	")" + CRLF

		cQuery += " where VS1_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('VS1') } )
		cQuery += " and   VS1_STATUS <> ?" + CRLF			// excluir Loja
		aAdd( aBind, { 'C', 'X' } )
		cQuery += " and   VB2_TIPDEV <> ?" + CRLF			// item Des-reservado
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " and   VB2_GRUITE IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )

		//if cTipoGer == oPrim:CodGerNormal()
			cQuery += " and not exists (" + CRLF
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
			cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
			cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
			cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
			cQuery +=               " and VBB_CATTRA = ?" + CRLF
			aAdd( aBind, { 'C', cTipoGer } )
			cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += 		" where DELTA.VBD_FILIAL=?" + CRLF
			aAdd( aBind, { 'C', xFilial("VBD") } )
			cQuery += 		" and   DELTA.VBD_PRODUT = VB2_CODITE" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMORI = VS1_NUMORC" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMNFI = VS1_NUMNFI" + CRLF
			cQuery += 		" and   DELTA.VBD_SERORI = VS1_SERNFI" + CRLF
			cQuery += 		" and   DELTA.VBD_CODCLI = VS1_CLIFAT" + CRLF
			cQuery += 		" and   DELTA.VBD_LOJCLI = VS1_LOJA" + CRLF
			cQuery += 		" and   DELTA.VBD_QTDFAT = VB2_QUANT" + CRLF
			cQuery += 		" and   DELTA.VBD_INDCAN=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			cQuery += 		" and   DELTA.VBD_ALIAS = VBD.VBD_ALIAS" + CRLF
			cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += ")"
		//else
		//	cQuery += " AND VS1_DATORC BETWEEN ? AND ?" + CRLF
		//	aAdd( aBind, { 'D', dDataIni } )
		//	aAdd( aBind, { 'D', dDataFim } )
		//endif

		cQuery += " and VS1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " order by VS1_NUMORC, VB2_CODITE" + CRLF

		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

		//OFCNHA019C_produtoMovimentado( (cAl)->VBD_PRODUT )

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
			VBD->VBD_NUMREM := (cAl)->VBD_NUMREM // (cAl)->VS1_NUMNFI
			VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI // (cAl)->VS1_NUMNFI
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
			VBD->VBD_ALIAS  := (cAl)->VBD_ALIAS
			VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->VBD_NUMSEQ := "CANC_2"
			VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

		oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 3"})	//#"Criando registros cancelados" --- exclusão NF de Saída
		cCampos := "  VBD_CODCLI,VBD_LOJCLI,VBD_CDCLI2,VBD_NOMCLI,VBD_ENDCLI," + CRLF
		cCampos += "  VBD_CLICEP,VBD_CLCNPJ,VBD_NUMORI,VBD_SERORI,VBD_LINVEN," + CRLF
		cCampos += "  VBD_NUMREM,VBD_NUMNFI,VBD_DATORI,VBD_DATREM,VBD_DATNFI," + CRLF
		cCampos += "  VBD_CANALV,VBD_CODGAR,VBD_SUBCAN,VBD_PRODUT,VBD_QTDPED," + CRLF
		cCampos += "  VBD_QTDREM,VBD_QTDFAT,VBD_HORMOB,VBD_TIPDEM,VBD_INDDEV," + CRLF
		cCampos += "  VBD_CUSMED,VBD_CHASSI,VBD_HORKIL,VBD_FABRIC,VBD_MODELO," + CRLF
		cCampos += "  VBD_MOTCOM,VBD_CODVBG,VBD_VALVDA,D2_NUMSEQ, VBD_TIPTEM,VBD_ALIAS " + CRLF

		aBind  := {}
		cQuery := "select " + cCampos + CRLF
		cQuery += " FROM "+retSqlName('SD2')+ " SD2 " + CRLF
		cQuery += " join "+retSqlName("SF4")+" SF4 " + CRLF
		cQuery += 	" on  F4_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial("SF4") } )
		cQuery += 	" and F4_CODIGO = D2_TES" + CRLF
		cQuery += 	" and F4_ESTOQUE = ?" + CRLF
		aAdd( aBind, { 'C', 'S' } )
		cQuery +=   " and SF4.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " JOIN "+retSqlName('SF3')+" SF3 ON F3_FILIAL=? AND F3_NFISCAL = D2_DOC AND F3_SERIE = D2_SERIE AND SF3.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("SF3") } )
		aAdd( aBind, { 'C', ' ' } )

//		if cArm == "F01"	// armazéns gerenciados
//			cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?" + CRLF
//			aAdd( aBind, { 'C', xFilial("VBF") } )
//			aAdd( aBind, { 'C', 'S' } )
//			aAdd( aBind, { 'C', '1' } )
//			aAdd( aBind, { 'C', ' ' } )
//		endif
		cQuery += " JOIN "+retSqlName('VBD')+" VBD ON VBD_FILIAL=? AND VBD_PRODUT = D2_COD AND VBD_NUMNFI = D2_DOC AND VBD_SERORI = D2_SERIE AND VBD_INDDEV <> ? AND VBD_INDCAN <> ? AND VBD.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', oPrim:CodDev() } )
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "	AND VBD_CODIGO = (" + CRLF
		cQuery += 	"	select MAX(VBD_CODIGO)" + CRLF
		cQuery += 	"	from "+retSqlName("VBD") + CRLF
		cQuery += 	"	where VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += 	"	AND VBD_PRODUT = D2_COD" + CRLF
		cQuery += 	"	AND VBD_NUMNFI = D2_DOC" + CRLF
		cQuery += 	"	AND VBD_SERORI = D2_SERIE" + CRLF
		cQuery += 	"	AND VBD_INDDEV <> ?" + CRLF
		aAdd( aBind, { 'C', 'S' } )
		cQuery += 	"	AND VBD_INDCAN <> ?" + CRLF
		aAdd( aBind, { 'C', 'Y' } )
		cQuery += 	"	AND D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += ")" + CRLF

		cQuery += " WHERE SD2.D2_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("SD2") } )
		cQuery += " AND D2_GRUPO IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )

		//if cTipoGer == oPrim:CodGerNormal()
			// é enviado dia atual mais dia anterior por conta do horário
			// segundo victor da cnh, enviar repetido não causa problemas, pois é
			// sobrescrito o registro na base e não duplicado
			cQuery += " AND F3_DTCANC IN (?) " + CRLF
			aAdd( aBind, { 'A', { DtoS(dDatabase-1), DtoS(dDatabase)} } )

			cQuery += " and not exists (" + CRLF
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
			cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
			cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
			cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
			cQuery +=               " and VBB_CATTRA = ?" + CRLF
			aAdd( aBind, { 'C', cTipoGer } )
			cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += 		" where DELTA.VBD_FILIAL = VBD.VBD_FILIAL" + CRLF
			cQuery += 		" and   DELTA.VBD_PRODUT = VBD.VBD_PRODUT" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMNFI = VBD.VBD_NUMNFI" + CRLF
			cQuery += 		" and   DELTA.VBD_SERORI = VBD.VBD_SERORI" + CRLF
			cQuery += 		" and   DELTA.VBD_CODCLI = VBD.VBD_CODCLI" + CRLF
			cQuery += 		" and   DELTA.VBD_LOJCLI = VBD.VBD_LOJCLI" + CRLF
			cQuery += 		" and   DELTA.VBD_QTDFAT = VBD.VBD_QTDFAT" + CRLF
			cQuery += 		" and   DELTA.VBD_INDCAN = ?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			cQuery += 		" and   DELTA.VBD_ALIAS = VBD.VBD_ALIAS" + CRLF
			cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += " ) "
		//else
		//	cQuery += " AND F3_DTCANC >= ? AND F3_DTCANC <= ?" + CRLF
		//	aAdd( aBind, { 'D', dDataIni } )
		//	aAdd( aBind, { 'D', dDataFim } )
		//endif
		cQuery += " AND SD2.D_E_L_E_T_=?" + CRLF // canceladas
		aAdd( aBind, { 'C', '*' } )
		cQuery += " GROUP BY " + cCampos + CRLF

		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())
			if ! Empty((cAl)->VBD_NOMCLI)

		//	OFCNHA019C_produtoMovimentado( (cAl)->VBD_PRODUT )

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
				VBD->VBD_NUMREM := (cAl)->VBD_NUMREM // (cAl)->VBD_NUMREM
				VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI // (cAl)->VBD_NUMNFI
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
				VBD->VBD_ALIAS  := (cAl)->VBD_ALIAS
				VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
				VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
				VBD->VBD_NUMSEQ := "EXC_NF"
				VBD->(MsUnlock())
				(cAl)->(DBSkip())
			endif
		enddo
		(cAl)->(DBCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

		// COLOCAR AQUI TRATAMENTO PARA CANCELAMENTO DE SERVIÇOS
		oLogger:Log({"TIMESTAMP","  |> "+STR0031 + " 4"})	//#"Criando registros cancelados DE SERVIÇO" --- exclusão NF de Saída
		cCampos := "  VBD_CODCLI,VBD_LOJCLI,VBD_CDCLI2,VBD_NOMCLI,VBD_ENDCLI," + CRLF
		cCampos += "  VBD_CLICEP,VBD_CLCNPJ,VBD_NUMORI,VBD_SERORI,VBD_LINVEN," + CRLF
		cCampos += "  VBD_NUMREM,VBD_NUMNFI,VBD_DATORI,VBD_DATREM,VBD_DATNFI," + CRLF
		cCampos += "  VBD_CANALV,VBD_CODGAR,VBD_SUBCAN,VBD_PRODUT,VBD_QTDPED," + CRLF
		cCampos += "  VBD_QTDREM,VBD_QTDFAT,VBD_HORMOB,VBD_TIPDEM,VBD_INDDEV," + CRLF
		cCampos += "  VBD_CUSMED,VBD_CHASSI,VBD_HORKIL,VBD_FABRIC,VBD_MODELO," + CRLF
		cCampos += "  VBD_MOTCOM,VBD_CODVBG,VBD_VALVDA, VBD_TIPTEM, VBD_ALIAS " + CRLF

		aBind  := {}
		cQuery := "select " + cCampos + CRLF
		cQuery += " FROM "+retSqlName('VSC')+ " VSC " + CRLF
		cQuery += " JOIN "+retSqlName('SF3')+" SF3 ON F3_FILIAL=? AND F3_NFISCAL = VSC_NUMNFI AND F3_SERIE = VSC_SERNFI AND SF3.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("SF3") } )
		aAdd( aBind, { 'C', ' ' } )

//		if cArm == "F01"	// armazéns gerenciados
//			cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = VSC_CODSER AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?" + CRLF
//			aAdd( aBind, { 'C', xFilial("VBF") } )
//			aAdd( aBind, { 'C', 'S' } )
//			aAdd( aBind, { 'C', '1' } )
//			aAdd( aBind, { 'C', ' ' } )
//		endif
		cQuery += " JOIN "+retSqlName('VBD')+" VBD ON VBD_FILIAL=? AND VBD_PRODUT = VSC_CODSER AND VBD_NUMNFI = VSC_NUMNFI AND VBD_SERORI = VSC_SERNFI AND VBD_INDDEV <> ? AND VBD_INDCAN <> ? AND VBD.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		aAdd( aBind, { 'C', oPrim:CodDev() } )
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += "	AND VBD_CODIGO = (" + CRLF
		cQuery += 	"	select MAX(VBD_CODIGO)" + CRLF
		cQuery += 	"	from "+retSqlName("VBD") + CRLF
		cQuery += 	"	where VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += 	"	AND VBD_PRODUT = VSC_CODSER" + CRLF
		cQuery += 	"	AND VBD_NUMNFI = VSC_NUMNFI" + CRLF
		cQuery += 	"	AND VBD_SERORI = VSC_SERNFI" + CRLF
		cQuery += 	"	AND VBD_INDDEV <> ?" + CRLF
		aAdd( aBind, { 'C', 'S' } )
		cQuery += 	"	AND VBD_INDCAN <> ?" + CRLF
		aAdd( aBind, { 'C', 'Y' } )
		cQuery += 	"	AND D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += ")" + CRLF
		cQuery += " WHERE VSC_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VSC") } )

		//if cTipoGer == oPrim:CodGerNormal()
			// é enviado dia atual mais dia anterior por conta do horário
			// segundo victor da cnh, enviar repetido não causa problemas, pois é
			// sobrescrito o registro na base e não duplicado
			cQuery += " AND F3_DTCANC IN (?) " + CRLF
			aAdd( aBind, { 'A', { DtoS(dDatabase-1), DtoS(dDatabase)} } )

			cQuery += " and not exists (" + CRLF
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
			cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
			cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
			cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
			cQuery +=               " and VBB_CATTRA = ?" + CRLF
			aAdd( aBind, { 'C', cTipoGer } )
			cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += 		" where DELTA.VBD_FILIAL = VBD.VBD_FILIAL" + CRLF
			cQuery += 		" and   DELTA.VBD_PRODUT = VBD.VBD_PRODUT" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMNFI = VBD.VBD_NUMNFI" + CRLF
			cQuery += 		" and   DELTA.VBD_SERORI = VBD.VBD_SERORI" + CRLF
			cQuery += 		" and   DELTA.VBD_CODCLI = VBD.VBD_CODCLI" + CRLF
			cQuery += 		" and   DELTA.VBD_LOJCLI = VBD.VBD_LOJCLI" + CRLF
			cQuery += 		" and   DELTA.VBD_QTDFAT = VBD.VBD_QTDFAT" + CRLF
			cQuery += 		" and   DELTA.VBD_INDCAN = ?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			cQuery += 		" and   DELTA.VBD_ALIAS = VBD.VBD_ALIAS" + CRLF
			cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += " ) " + CRLF
		//else
		//	cQuery += " AND F3_DTCANC >= ? AND F3_DTCANC <= ?" + CRLF
		//	aAdd( aBind, { 'D', dDataIni } )
		//	aAdd( aBind, { 'D', dDataFim } )
		//endif
		cQuery += " AND VSC.D_E_L_E_T_=?" + CRLF // canceladas
		aAdd( aBind, { 'C', '*' } )
		cQuery += " GROUP BY " + cCampos + CRLF

		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())
			if ! Empty((cAl)->VBD_NOMCLI)

		//	OFCNHA019C_produtoMovimentado( (cAl)->VBD_PRODUT )

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
				VBD->VBD_ALIAS  := (cAl)->VBD_ALIAS
				VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
				VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
				VBD->VBD_NUMSEQ := "EXCNFS"
				VBD->(MsUnlock())
				(cAl)->(DBSkip())
			endif
		enddo
		(cAl)->(DBCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

		oLogger:Log({"TIMESTAMP","  |> "+STR0076})	//#"Iniciando coleta de peças canceladas"
		aBind  := {}
		cQuery := "select * from (" + CRLF
		cQuery += " select"  + CRLF
		cQuery += " VO3_NUMOSV, VO3_CODITE, " + CRLF
		cQuery += " MAX(VO3_NOSNUM) NOSNUM, " + CRLF
		cQuery += " SUM(case when VO2_DEVOLU=? then VO3_QTDREQ * -1" + CRLF
		aAdd( aBind, { 'C', '0' } )
		cQuery += 	" else VO3_QTDREQ" + CRLF
		cQuery += " end) QTDREQ," + CRLF
		cQuery += " MAX(VO2_DATREQ) DATREQ," + CRLF
		cQuery += " VO3_TIPTEM" + CRLF
		cQuery += " from "+retSqlName("VO3")+ " VO3" + CRLF
		cQuery += " join "+retSqlName("VO2")+ " VO2" + CRLF
		cQuery += 		" ON  VO2_FILIAL=VO3_FILIAL" + CRLF
		cQuery += 		" AND VO2_NOSNUM=VO3_NOSNUM" + CRLF
		cQuery += 		" AND VO2_TIPREQ=?" + CRLF
		aAdd( aBind, { 'C', 'P' } )
		cQuery += 		" AND VO2.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

//		if cArm == "F01"	// armazéns gerenciados
//			cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = VO3_CODITE AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?" + CRLF
//			aAdd( aBind, { 'C', xFilial('VBF') } )
//			aAdd( aBind, { 'C', 'S' } )
//			aAdd( aBind, { 'C', '1' } )
//			aAdd( aBind, { 'C', ' ' } )
//		endif

		cQuery += " WHERE VO3_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VO3") } )
		cQuery += " AND VO3.D_E_L_E_T_=? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " and VO3_GRUITE IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )
		cQuery += " GROUP BY VO3_NUMOSV, VO3_CODITE, VO3_TIPTEM" + CRLF
		cQuery += " ) OS " + CRLF

		cQuery += " JOIN "+retSqlName('VBD')+" VBD ON  VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += "	AND VBD_CODIGO = (" + CRLF
		cQuery += 	"	select MAX(VBD_CODIGO)" + CRLF
		cQuery += 	"	from "+retSqlName("VBD") + CRLF
		cQuery += 	"	where VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += 	"	AND VBD_PRODUT = VO3_CODITE" + CRLF
		cQuery += 	"	AND VBD_NUMORI = VO3_NUMOSV" + CRLF
		cQuery += 	"	AND VBD_INDDEV=?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		cQuery += 	"	AND VBD_INDCAN=?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
		cQuery += 	"	AND VBD_CANALV not in (?)" + CRLF
		aAdd( aBind, { 'A', {'G','V','B'} } )
		cQuery += 	"	AND D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += ")" + CRLF

		//if cTipoGer == oPrim:CodGerNormal()
			cQuery += " where not exists (" + CRLF
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
			cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
			cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
			cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
			cQuery +=               " and VBB_CATTRA = ?" + CRLF
			aAdd( aBind, { 'C', cTipoGer } )
			cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += 		" where DELTA.VBD_FILIAL=?" + CRLF
			aAdd( aBind, { 'C', xFilial("VBD") } )
			cQuery += 		" and   DELTA.VBD_PRODUT = VO3_CODITE" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMORI = VO3_NUMOSV" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMREM = NOSNUM" + CRLF
			cQuery += 		" and   DELTA.VBD_INDDEV=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
			cQuery += 		" and   DELTA.VBD_INDCAN=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			cQuery += 		" and   DELTA.VBD_ALIAS = VBD.VBD_ALIAS" + CRLF
			cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += " ) " + CRLF
		//else
		//	cQuery += " where DATREQ BETWEEN ? AND ? " + CRLF
		//	aAdd( aBind, { 'D', dDataIni } )
		//	aAdd( aBind, { 'D', dDataFim } )
		//endif
		cQuery += " and ( QTDREQ=?"
		aAdd( aBind, { 'N', 0 } )
		cQuery += " or VBD_TIPTEM != VO3_TIPTEM ) " + CRLF

		cQuery += " order by VBD_NUMORI, VBD_LINVEN" + CRLF
		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

		//	OFCNHA019C_produtoMovimentado( (cAl)->VBD_PRODUT )

			reclock('VBD', .T.)
			VBD->VBD_CODVBB := cCodVBB
			VBD->VBD_FILIAL := xFilial('VBD')
			VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
			VBD->VBD_CODCLI := (cAl)->VBD_CODCLI
			VBD->VBD_LOJCLI := (cAl)->VBD_LOJCLI
			VBD->VBD_CDCLI2 := (cAl)->VBD_CDCLI2
			VBD->VBD_NUMORI := (cAl)->VBD_NUMORI
			VBD->VBD_LINVEN := (cAl)->VBD_LINVEN
		//	VBD->VBD_NUMNFI := (cAl)->VBD_NUMNFI
		//	VBD->VBD_SERORI := (cAl)->VBD_SERORI
			VBD->VBD_NUMREM := (cAl)->NOSNUM
			VBD->VBD_DATORI := StoD( (cAl)->VBD_DATORI )
		//	VBD->VBD_DATNFI := StoD( (cAl)->VBD_DATNFI )
			VBD->VBD_PRODUT := (cAl)->VBD_PRODUT
		//	VBD->VBD_QTDFAT := (cAl)->VBD_QTDFAT
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
			VBD->VBD_NUMSEQ := "PCCANC"
			VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado
	endif

	if cArm == "N01"
		oLogger:Log({"TIMESTAMP","  |> "+STR0077})	//#"Iniciando coleta de serviços"
		aBind  := {}
		cQuery := "SELECT VO1_NUMOSV, VO1_DATABE, VO1_DATENT, VO1_CHASSI, VO1_KILOME, VO1_MOTCOM, VO1_STATUS," + CRLF
		cQuery += "VO4_CODSER, VO4_GRUSER, VO4_TIPTEM, VO4_DATDIS, VO4_DATFEC, VO4_DATCAN, VO4_SRVFIN, VO4_FATPAR, VO4_LOJA, MIN(VO4_SEQUEN) VO4_SEQUEN," + CRLF
		cQuery += "VO4_NUMNFI, VO4_SERNFI," + CRLF
		cQuery += "VOI_SITTPO," + CRLF
		cQuery += "VV1_MODVEI,  VV1_CODMAR," + CRLF
		cQuery += "VOO_NUMNFI, VOO_SERNFI" + CRLF
		cQuery += " FROM "+retSqlName('VO1')+" VO1" + CRLF
		cQuery += " JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=VO1_FILIAL AND VO2_NUMOSV=VO1_NUMOSV AND VO2_TIPREQ=? AND VO2.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " JOIN "+retSqlName('VO4')+" VO4 ON VO4_FILIAL=VO1_FILIAL AND VO4_NUMOSV=VO1_NUMOSV AND VO4.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VOI_TIPTEM=VO4_TIPTEM AND VOI.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VOI") } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT=VO1_CHAINT AND VV1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VV1") } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " LEFT JOIN "+retSqlName('VOO')+" VOO ON VOO_FILIAL=? AND VOO_NUMOSV=VO1_NUMOSV AND VOO_LIBVOO=VO4_LIBVOO AND VOO.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VOO") } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " WHERE VO1_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VO1") } )
		cQuery += " AND VO1.D_E_L_E_T_=? " + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " AND VO4_DATINI <> ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " and not exists (" + CRLF
			cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
			cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
			cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
			cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
			cQuery +=               " and VBB_CATTRA = ?" + CRLF
			aAdd( aBind, { 'C', cTipoGer } )
			cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += 		" where DELTA.VBD_FILIAL=?" + CRLF
			aAdd( aBind, { 'C', xFilial("VBD") } )
			cQuery += 		" and   DELTA.VBD_PRODUT = VO4_CODSER" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMORI = VO1_NUMOSV" + CRLF
			cQuery += 		" and   DELTA.VBD_NUMNFI = " + iif( cSGBD == "ORACLE", "NVL(VOO_NUMNFI, ' ')", "isnull(VOO_NUMNFI, ' ')" ) + CRLF
			cQuery += 		" and   DELTA.VBD_SERORI = " + iif( cSGBD == "ORACLE", "NVL(VOO_SERNFI, ' ')", "isnull(VOO_SERNFI, ' ')" ) + CRLF
			cQuery += 		" and   DELTA.VBD_CODCLI = VO4_FATPAR" + CRLF
			cQuery += 		" and   DELTA.VBD_LOJCLI = VO4_LOJA" + CRLF
			cQuery += 		" and   DELTA.VBD_INDDEV=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
			cQuery += 		" and   DELTA.VBD_INDCAN=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
			cQuery += 		" and   DELTA.VBD_ALIAS=?" + CRLF
			aAdd( aBind, { 'C', 'SRV' } )
			cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += " ) " + CRLF
		else
			cQuery += " and ( VO4_DATDIS BETWEEN ? AND ? " + CRLF				// Tipo de Tempo - Liberado <> ''
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
			cQuery += "    or VO4_DATFEC BETWEEN ? AND ? " + CRLF				// Tipo de Tempo - Fechado <> ''
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
			cQuery += "    or VO4_DATCAN BETWEEN ? AND ? )" + CRLF				// Tipo de Tempo - Cancelado <> ''
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
		endif

		cQuery += " group by VO1_NUMOSV, VO1_DATABE, VO1_DATENT, VO1_CHASSI, VO1_KILOME, VO1_MOTCOM, VO1_STATUS," + CRLF
		cQuery += " VO4_CODSER, VO4_GRUSER, VO4_TIPTEM, VO4_DATDIS, VO4_DATFEC, VO4_DATCAN, VO4_SRVFIN, VO4_FATPAR, VO4_LOJA, VO4_NUMNFI, VO4_SERNFI," + CRLF
		cQuery += " VOI_SITTPO," + CRLF
		cQuery += " VV1_MODVEI, VV1_CODMAR," + CRLF
		cQuery += " VOO_NUMNFI, VOO_SERNFI" + CRLF
		cQuery += " order by VO1_NUMOSV, VO4_SEQUEN" + CRLF
		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

			if cTipoGer == oPrim:CodGerExcepcional() .and. ! empty( (cAl)->VO4_DATCAN )		// PRIM1 não envia cancelados
				(cAl)->( dbSkip() )
				loop
			endif

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
			VBD->VBD_NUMNFI := iif( empty((cAl)->VO4_NUMNFI) .AND. !empty((cAl)->VO4_DATFEC) , "INTERNO", (cAl)->VO4_NUMNFI )  // (cAl)->VOO_NUMNFIve
			VBD->VBD_SERORI := (cAl)->VO4_SERNFI  // (cAl)->VOO_SERNFI
			VBD->VBD_NUMREM := VBD->VBD_NUMNFI
			VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
													(cAl)->VO4_CODSER,;
													VBD->VBD_NUMORI,;
													(cAl)->VOO_NUMNFI,;
													(cAl)->VOO_SERNFI,;
													VBD->VBD_CODCLI,;
													VBD->VBD_LOJCLI,;
													1,;
													val( (cAl)->VO4_SEQUEN )+1,;
													VBD->VBD_NUMREM )
			VBD->VBD_DATORI := STOD( (cAl)->VO1_DATABE )			
			VBD->VBD_DATNFI := STOD( (cAl)->VO4_DATFEC )// somente enviado quando faturado.
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
		//	VBD->VBD_CODGAR := iif( (cAl)->VOI_SITTPO == "3", 'D', 'A' )	// D=consumo interno;A=Garantia
			VBD->VBD_CODGAR := oCanalVenda:retGarantia( (cAl)->VOI_SITTPO )
			VBD->VBD_SUBCAN := "D5"
			VBD->VBD_CANALV := oCanalVenda:CanalServicos()
			VBD->VBD_ALIAS  := "SRV"
			VBD->VBD_TIPTEM := (cAl)->VO4_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->VBD_NUMSEQ := "SERVIC"
			VBD->VBD_CUSMED := aCalSrvc[1,SRVC_VALLIQ]						// Valor do Servico (Valor Liquido)
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado

		if cTipoGer == oPrim:CodGerNormal()
			oLogger:Log({"TIMESTAMP","  |> "+STR0078})	// obter Serviços de Ordem de Serviço CANCELADOS
			aBind  := {}
			cQuery := "select * from (" + CRLF

			cQuery += "select VO4_NUMOSV VO3_NUMOSV, VO4_CODSER VO3_CODITE, VO4_NOSNUM VO3_NOSNUM, 1 VO3_QTDREQ, VO2_DATREQ, VBD.*, VBD.VBD_ALIAS ORIGEM" + CRLF
			cQuery += " from "+retSqlName("VO4")+" VO4" + CRLF
			cQuery += " join "+retSqlName("VO2")+" VO2" + CRLF
			cQuery += 	" ON  VO2_FILIAL=VO4_FILIAL" + CRLF
			cQuery += 	" AND VO2_NOSNUM=VO4_NOSNUM" + CRLF
			cQuery += 	" AND VO2_TIPREQ=?" + CRLF
			aAdd( aBind, { 'C', 'S' } )
			cQuery += 	" AND VO2.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )

			cQuery += " JOIN "+retSqlName('VBD')+" VBD ON  VBD_FILIAL=?" + CRLF
			aAdd( aBind, { 'C', xFilial("VBD") } )
			cQuery += "	AND VBD_CODIGO = (" + CRLF
			cQuery += 	"	select MAX(VBD_CODIGO)" + CRLF
			cQuery += 	"	from "+retSqlName("VBD") + CRLF
			cQuery += 	"	where VBD_FILIAL=?" + CRLF
			aAdd( aBind, { 'C', xFilial("VBD") } )
			cQuery += 	"	AND VBD_PRODUT = VO4_CODSER" + CRLF
			cQuery += 	"	AND VBD_NUMORI = VO4_NUMOSV" + CRLF
			cQuery += 	"	AND VBD_INDDEV=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
			cQuery += 	"	AND VBD_INDCAN=?" + CRLF
			aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
			cQuery += 	"	AND VBD_CANALV=?" + CRLF
			aAdd( aBind, { 'C', oCanalVenda:CanalServicos() } )
			cQuery += 	"	AND D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += ")" + CRLF

			cQuery += " WHERE VO4_FILIAL=?" + CRLF
			aAdd( aBind, { 'C', xFilial("VO4") } )
			cQuery += " AND VO4_DATINI <> ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += " AND VO4.D_E_L_E_T_=? " + CRLF
			aAdd( aBind, { 'C', '*' } )

			cQuery += " ) OS " + CRLF

			//if cTipoGer == oPrim:CodGerNormal()
				cQuery += " where not exists (" + CRLF
				cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
				cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
				cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
				cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
				cQuery +=               " and VBB_CATTRA = ?" + CRLF
				aAdd( aBind, { 'C', cTipoGer } )
				cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
				aAdd( aBind, { 'C', ' ' } )
				cQuery += 		" where DELTA.VBD_FILIAL=?" + CRLF
				aAdd( aBind, { 'C', xFilial("VBD") } )
				cQuery += 		" and   DELTA.VBD_PRODUT = VO3_CODITE" + CRLF
				cQuery += 		" and   DELTA.VBD_NUMORI = VO3_NUMOSV" + CRLF
				cQuery += 		" and   DELTA.VBD_NUMREM = VO3_NOSNUM" + CRLF
				cQuery += 		" and   DELTA.VBD_INDDEV=?" + CRLF
				aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
				cQuery += 		" and   DELTA.VBD_INDCAN=?" + CRLF
				aAdd( aBind, { 'C', oPrim:CodCanc() } )
				cQuery += 		" and   DELTA.VBD_ALIAS = ORIGEM" + CRLF
				cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
				aAdd( aBind, { 'C', ' ' } )
				cQuery += " ) " + CRLF
			//else
			//	cQuery += " where VO2_DATREQ BETWEEN ? AND ? " + CRLF
			//	aAdd( aBind, { 'D', dDataIni } )
			//	aAdd( aBind, { 'D', dDataFim } )
			//endif
			cQuery += " order by VBD_NUMORI, VBD_LINVEN" + CRLF

			OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
			While ! (cAl)->(Eof())

		//	OFCNHA019C_produtoMovimentado( (cAl)->VBD_PRODUT )

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
				VBD->VBD_NUMSEQ := "SRVCAN"
				VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
				VBD->(MsUnlock())
				(cAl)->(DBSkip())
			enddo
			(cAl)->(DBCloseArea())
			oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado
		endif
	endif

	if cTipoGer == oPrim:CodGerNormal()
		oLogger:Log({"TIMESTAMP","  |> "+STR0079})		// # "Mudança de Tipo de Tempo, Peças e Serviços"
	// obter Mudança de Tipo de Tempo, Peças e Serviços
		aBind  := {}
		cQuery := "select distinct VBD.*" + CRLF
		cQuery += " from "+retSqlName("VBD")+" VBD" + CRLF
		cQuery += " join "+retSqlName("VBD")+" VBD2" + CRLF
		cQuery += 	" on  VBD2.VBD_FILIAL=VBD.VBD_FILIAL" + CRLF
		cQuery += 	" and VBD2.VBD_PRODUT=VBD.VBD_PRODUT" + CRLF
		cQuery += 	" and VBD2.VBD_NUMORI=VBD.VBD_NUMORI" + CRLF
		cQuery += 	" and VBD2.VBD_NUMNFI=VBD.VBD_NUMNFI" + CRLF
		cQuery += 	" and VBD2.VBD_SERORI=VBD.VBD_SERORI" + CRLF
		cQuery += 	" and VBD2.VBD_INDDEV=VBD.VBD_INDDEV" + CRLF
		cQuery += 	" and VBD2.VBD_INDCAN=VBD.VBD_INDCAN" + CRLF
		cQuery += 	" and VBD2.VBD_CANALV=VBD.VBD_CANALV" + CRLF
		cQuery += 	" and VBD2.VBD_CODCLI=VBD.VBD_CODCLI" + CRLF
		cQuery += 	" and VBD2.VBD_LOJCLI=VBD.VBD_LOJCLI" + CRLF
		cQuery += 	" and VBD2.VBD_TIPTEM <> VBD.VBD_TIPTEM" + CRLF
		cQuery += 	" and VBD2.R_E_C_N_O_ > VBD.R_E_C_N_O_" + CRLF
		cQuery += 	" and VBD2.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " join "+retSqlName('SB1')+" SB1 on B1_FILIAL=? and B1_COD=VBD.VBD_PRODUT and SB1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SB1') } )
		aAdd( aBind, { 'C', ' ' } )

//		if cArm == "F01"	// armazéns gerenciados
//			cQuery += " join "+retSqlName('VBF')+" VBF on VBF_FILIAL=? and VBF_PRODUT=VBD.VBD_PRODUT and VBF_FLGARQ=? and VBF_FLGUSO=? and VBF.D_E_L_E_T_=?" + CRLF
//			aAdd( aBind, { 'C', xFilial('VBF') } )
//			aAdd( aBind, { 'C', 'S' } )
//			aAdd( aBind, { 'C', '1' } )
//			aAdd( aBind, { 'C', ' ' } )
//		endif

		cQuery += " where VBD.VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += " and   VBD.VBD_INDCAN=?" + CRLF
		aAdd( aBind, { 'C', 'N' } )
		cQuery += " and   VBD.VBD_SQCANC=?" + CRLF
		aAdd( aBind, { 'C', '1' } )
		cQuery += " and   VBD.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " and B1_GRUPO IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )

		//if cTipoGer == oPrim:CodGerNormal()
			cQuery += " and   not exists (" + CRLF
			cQuery += 		" select 1 from "+retSqlName("VBD")+" CANC" + CRLF
			cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
			cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
			cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
			cQuery +=               " and VBB_CATTRA = ?" + CRLF
			aAdd( aBind, { 'C', cTipoGer } )
			cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += 		" where CANC.VBD_FILIAL=VBD.VBD_FILIAL" + CRLF
			cQuery += 		" and   CANC.VBD_PRODUT=VBD.VBD_PRODUT" + CRLF
			cQuery += 		" and   CANC.VBD_NUMORI=VBD.VBD_NUMORI" + CRLF
			cQuery += 		" and   CANC.VBD_NUMNFI=VBD.VBD_NUMNFI" + CRLF
			cQuery += 		" and   CANC.VBD_SERORI=VBD.VBD_SERORI" + CRLF
			cQuery += 		" and   CANC.VBD_INDCAN=?" + CRLF
			aAdd( aBind, { 'C', 'Y' } )
			cQuery += 		" and   CANC.VBD_ALIAS = VBD.VBD_ALIAS" + CRLF
			cQuery += 		" and   CANC.VBD_INDDEV=VBD.VBD_INDDEV" + CRLF
			cQuery += 		" and   CANC.VBD_CANALV=VBD.VBD_CANALV" + CRLF
			cQuery += 		" and   CANC.VBD_CODCLI=VBD.VBD_CODCLI" + CRLF
			cQuery += 		" and   CANC.VBD_LOJCLI=VBD.VBD_LOJCLI" + CRLF
			cQuery += 		" and   CANC.VBD_TIPTEM=VBD.VBD_TIPTEM" + CRLF
			cQuery += 		" and   CANC.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', ' ' } )
			cQuery += " )" + CRLF
		//else
		//	cQuery += " and (VBD.VBD_DATORI BETWEEN ? AND ? " + CRLF
		//	aAdd( aBind, { 'D', dDataIni } )
		//	aAdd( aBind, { 'D', dDataFim } )
		//	cQuery += " or VBD.VBD_DATNFI BETWEEN ? AND ? )" + CRLF
		//	aAdd( aBind, { 'D', dDataIni } )
		//	aAdd( aBind, { 'D', dDataFim } )
		//endif
		cQuery += " order by VBD.VBD_NUMORI, VBD.VBD_LINVEN" + CRLF

		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

		//	OFCNHA019C_produtoMovimentado( (cAl)->VBD_PRODUT )

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
			VBD->VBD_NUMSEQ := "MUD_TT"
			VBD->VBD_CUSMED := (cAl)->VBD_CUSMED
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
	endif

//---------------------------------------------- E N T R A D A   A J U S T E   E S T O Q U E --------------------------------------
	oLogger:Log({"TIMESTAMP","  |> "+ STR0080 })	//# "Gerando Entradas para Ajuste de Estoque"
	aBind  := {}
	cQuery := "select D1_ITEM, D1_DOC, D1_SERIE, D1_COD, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_DTDIGIT, D1_NUMSEQ, D1_CUSTO," + CRLF
	cQuery += " A2_NOME, A2_END, A2_CEP, A2_CGC " + CRLF
	cQuery += " FROM "+retSqlName('SD1')+" SD1 " + CRLF
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL  = ? AND D1_TES = F4_CODIGO  AND SF4.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName("SA2")+" SA2 ON A2_FILIAL = ? AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', xFilial("SA2") } )
	aAdd( aBind, { 'C', ' ' } )
//	if cArm == "F01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON  VBF_FILIAL = ? AND VBF_PRODUT = D1_COD AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?" + CRLF
//		aAdd( aBind, { 'C', xFilial('VBF') } )
//		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', ' ' } )
//	endif
	cQuery += " JOIN "+retSqlName('SF1')+" SF1 on F1_FILIAL = D1_FILIAL AND D1_DOC = F1_DOC AND F1_SERIE = D1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SF1.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " WHERE F1_FILIAL  = ?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF1') } )
	cQuery  += " AND D1_GRUPO IN (?)" + CRLF
	aAdd( aBind, { 'A', aGrupos } )
	cQuery  += " AND F4_OPEMOV IN (?)" + CRLF
	aAdd( aBind, { 'A', { "12", "15" } } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and not exists (" + CRLF
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
		cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
		cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
		cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
		cQuery +=               " and VBB_CATTRA = ?" + CRLF
		aAdd( aBind, { 'C', cTipoGer } )
		cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 		" where DELTA.VBD_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD')} )
		cQuery += 		" and   DELTA.VBD_PRODUT = D1_COD" + CRLF
		cQuery += 		" and   DELTA.VBD_NUMNFI = D1_DOC" + CRLF
		cQuery += 		" and   DELTA.VBD_SERORI = D1_SERIE" + CRLF
		cQuery += 		" and   DELTA.VBD_CODCLI = D1_FORNECE" + CRLF
		cQuery += 		" and   DELTA.VBD_LOJCLI = D1_LOJA" + CRLF
		cQuery += 		" and   DELTA.VBD_QTDFAT = D1_QUANT" + CRLF
		cQuery += 		" and   DELTA.VBD_CANALV = ?" + CRLF
		aAdd( aBind, { 'C', oCanalVenda:CanalAjuste() } )
		cQuery += 		" and   DELTA.VBD_INDDEV = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		cQuery += 		" and   DELTA.VBD_INDCAN = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoCanc()} )
		cQuery += 		" and   DELTA.VBD_ALIAS=?" + CRLF
		aAdd( aBind, { 'C', 'SD1'} )
		cQuery += 		" and   DELTA.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' '} )
		cQuery += " ) " + CRLF
	else
		cQuery += " AND SD1.D1_DTDIGIT between ? AND ? " + CRLF
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND SD1.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' '} )

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		nRegs++

		reclock('VBD', .T.)
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_CODCLI := (cAl)->D1_FORNECE
		VBD->VBD_LOJCLI := (cAl)->D1_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NOMCLI := (cAl)->A2_NOME
		VBD->VBD_ENDCLI := (cAl)->A2_END
		VBD->VBD_CLICEP := (cAl)->A2_CEP
		VBD->VBD_CLCNPJ := (cAl)->A2_CGC
		VBD->VBD_NUMNFI := (cAl)->D1_DOC
		VBD->VBD_SERORI := (cAl)->D1_SERIE
		VBD->VBD_NUMREM := VBD->VBD_NUMNFI
		VBD->VBD_DATORI := STOD((cAl)->D1_EMISSAO)
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->D1_COD,;
												(cAl)->D1_EMISSAO,;
												VBD->VBD_NUMNFI,;
												VBD->VBD_SERORI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->D1_QUANT,;
												VAL( (cAl)->D1_ITEM ),;
												VBD->VBD_NUMREM )
		VBD->VBD_NUMORI := (cAl)->D1_DOC
		VBD->VBD_MOTCOM := ""
		VBD->VBD_DATNFI := STOD( (cAl)->D1_EMISSAO )
		VBD->VBD_CANALV := oCanalVenda:CanalAjuste()
		VBD->VBD_PRODUT := (cAl)->D1_COD
		VBD->VBD_QTDFAT := (cAl)->D1_QUANT
		VBD->VBD_QTDPED := (cAl)->D1_QUANT
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_TIPDEM := "0"
		VBD->VBD_INDCAN := oPrim:CodNaoCanc()
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_VALVDA := (cAl)->D1_VUNIT
		VBD->VBD_CODGAR := 'Z' // venda normal
		VBD->VBD_ALIAS  := "SD1"
		VBD->VBD_TIPTEM := ""
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->VBD_NUMSEQ := "AJ.EST"
		VBD->VBD_CUSMED := (cAl)->D1_CUSTO /(cAl)->D1_QUANT
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado
//
//-------------------------------------------------------------------------------- DEVOLUCOES ------------------------------------
		oLogger:Log({"TIMESTAMP","  |> "+STR0032})	//#"Criando registros de devolucao" APOS GRAVAÇÃO DAS VENDAS 
		cCampos := " VBD.VBD_CODCLI,VBD.VBD_LOJCLI,VBD.VBD_CDCLI2,VBD.VBD_NOMCLI,VBD.VBD_ENDCLI," + CRLF
		cCampos += " VBD.VBD_CLICEP,VBD.VBD_CLCNPJ,VBD.VBD_NUMORI,VBD.VBD_SERORI,VBD.VBD_LINVEN," + CRLF
		cCampos += " VBD.VBD_NUMREM,VBD.VBD_NUMNFI,VBD.VBD_DATORI,VBD.VBD_DATREM,VBD.VBD_DATNFI," + CRLF
		cCampos += " VBD.VBD_CANALV,VBD.VBD_CODGAR,VBD.VBD_SUBCAN,VBD.VBD_PRODUT,VBD.VBD_QTDPED," + CRLF
		cCampos += " VBD.VBD_QTDREM,VBD.VBD_QTDFAT,VBD.VBD_HORMOB,VBD.VBD_TIPDEM,VBD.VBD_VALVDA," + CRLF
		cCampos += " VBD.VBD_CUSMED,VBD.VBD_CHASSI,VBD.VBD_HORKIL,VBD.VBD_FABRIC,VBD.VBD_MODELO," + CRLF
		cCampos += " VBD.VBD_MOTCOM,VBD.VBD_CODVBG,VBD.VBD_TIPTEM," + CRLF
		cCampos += " D1_QUANT, D1_NUMSEQ, F1_DOC, F1_SERIE, F1_EMISSAO, D1_CUSTO," + CRLF
		cCampos += " VBD.VBD_ALIAS"

		aBind  := {}
		cQuery := "select " + cCampos + CRLF
		cQuery += " FROM "+retSqlName('SF1')+" SF1 " + CRLF
		cQuery += " JOIN "+retSqlName('SD1')+" SD1 ON D1_FILIAL=? AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE"
		cQuery += 		" AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SF1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SD1') } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND D1_TES = F4_CODIGO AND F4_OPEMOV=? AND SF4.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SF4') } )
		aAdd( aBind, { 'C', '09' } )
		aAdd( aBind, { 'C', ' ' } )

//		if cArm == "F01"	// armazéns gerenciados
//			cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D1_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?" + CRLF
//			aAdd( aBind, { 'C', xFilial('VBF') } )
//			aAdd( aBind, { 'C', 'S' } )
//			aAdd( aBind, { 'C', '1' } )
//			aAdd( aBind, { 'C', ' ' } )
//		endif
		cQuery += " JOIN "+retSqlName('VBD')+" VBD ON VBD.VBD_FILIAL=? AND VBD.VBD_PRODUT=D1_COD AND VBD.VBD_NUMNFI=D1_NFORI AND VBD.VBD_SERORI=D1_SERIORI AND VBD.VBD_INDDEV<>? AND VBD.VBD_INDCAN<>? AND VBD.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD') } )
		aAdd( aBind, { 'C', oPrim:CodDev() } )
		aAdd( aBind, { 'C', oPrim:CodCanc() } )
		aAdd( aBind, { 'C', ' ' } )

		cQuery += " JOIN "+retSqlName('VBB')+" VBB ON VBB_FILIAL=? AND VBB_CODIGO=VBD.VBD_CODVBB AND VBB_CATTRA=? AND VBB_LOCCNH=? AND VBB_TIPGER=? AND VBB.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD') } )
		aAdd( aBind, { 'C', 'G' } )
		aAdd( aBind, { 'C', cArm } )
		aAdd( aBind, { 'C', 'V' } )
		aAdd( aBind, { 'C', ' ' } )

		if cTipoGer == oPrim:CodGerNormal()		// DELTA - p/ PRIM2
			cQuery += " LEFT JOIN "+retSqlName('VBD')+" DEV ON DEV.VBD_FILIAL=? AND DEV.VBD_PRODUT=D1_COD AND DEV.VBD_NUMNFI=D1_DOC AND DEV.VBD_SERORI=D1_SERIE AND DEV.VBD_INDDEV=? AND DEV.VBD_INDCAN<>? AND DEV.D_E_L_E_T_=?" + CRLF
			aAdd( aBind, { 'C', xFilial('VBD') } )
			aAdd( aBind, { 'C', oPrim:CodDev() } )
			aAdd( aBind, { 'C', oPrim:CodCanc() } )
			aAdd( aBind, { 'C', ' ' } )
		endif

		cQuery += " WHERE F1_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SF1') } )
		cQuery += " AND D1_GRUPO IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )
		cQuery += " AND D1_TIPO=?" + CRLF // devolucao
		aAdd( aBind, { 'C', 'D' } )

		if cTipoGer == oPrim:CodGerNormal()
			cQuery += " AND DEV.VBD_ALIAS is null" + CRLF

			cQuery += " AND VBD.VBD_ALIAS in (?)" + CRLF
			aAdd( aBind, { 'A', { 'BAL', 'OUT', 'OFI' } } )
		else
			cQuery += " AND D1_DTDIGIT >= ? AND D1_DTDIGIT <= ?" + CRLF
			aAdd( aBind, { 'D', dDataIni } )
			aAdd( aBind, { 'D', dDataFim } )
		endif
		cQuery += " AND SD1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )

		OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
		While ! (cAl)->(Eof())

		//	OFCNHA019C_produtoMovimentado( (cAl)->VBD_PRODUT )

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
			VBD->VBD_CUSMED := (cAl)->D1_CUSTO / (cAl)->D1_QUANT
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
			VBD->VBD_TIPTEM := (cAl)->VBD_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->VBD_NUMSEQ := "DEVOLV"
			VBD->(MsUnlock())
			(cAl)->(DBSkip())
		enddo
		(cAl)->(DBCloseArea())
		oLogger:Log({"TIMESTAMP","  |> "+STR0020})	// #Finalizado

//
	oLogger:Log({"TIMESTAMP","  |> "+STR0028})	//#"Gerando Registros de transferencias"
	aBind  := {}
	cQuery := "select distinct F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO" + CRLF
//	cQuery += " VS1_DATORC, VS1_NUMORC, VS1_MOTCOM, VS1_TIPTEM," + CRLF
//	cQuery += " VS3_SEQUEN, VS3_CODSIT, VS3_CODITE, VS3_GRUITE, VS3_QTDITE" + CRLF
	cQuery += " FROM "+retSqlName('VS1')+" VS1 " + CRLF
	cQuery += " JOIN "+retSqlName('SF2')+" SF2 on F2_FILIAL = ? AND F2_DOC = VS1_NUMNFI AND F2_SERIE = VS1_SERNFI AND SF2.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF2') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('VS3')+" VS3 on VS3_FILIAL = VS1_FILIAL AND VS3_NUMORC = VS1_NUMORC AND VS3.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
//	if cArm == "F01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON  VBF_FILIAL = ? AND VBF_PRODUT = VS3_CODITE AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?" + CRLF
//		aAdd( aBind, { 'C', xFilial('VBF') } )
//		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', ' ' } )
//	endif
	cQuery += " WHERE VS1_FILIAL  = ?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	cQuery  += " AND VS3_GRUITE IN (?)" + CRLF
	aAdd( aBind, { 'A', aGrupos } )
	cQuery  += " AND VS1_NUMNFI <> ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
//	cQuery  += " AND VS3_MOTPED <> ?" + CRLF
//	aAdd( aBind, { 'C', ' ' } )
	cQuery  += " AND VS1_TIPORC = ?" + CRLF
	aAdd( aBind, { 'C', '3' } )
	cQuery += " AND VS1.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' '} )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and not exists (" + CRLF
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
		cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
		cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
		cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
		cQuery +=               " and VBB_CATTRA = ?" + CRLF
		aAdd( aBind, { 'C', cTipoGer } )
		cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 		" where DELTA.VBD_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD')} )
		cQuery += 		" and   DELTA.VBD_PRODUT = VS3_CODITE" + CRLF
		cQuery += 		" and   DELTA.VBD_NUMNFI = F2_DOC" + CRLF
		cQuery += 		" and   DELTA.VBD_SERORI = F2_SERIE" + CRLF
		cQuery += 		" and   DELTA.VBD_CODCLI = F2_CLIENTE" + CRLF
		cQuery += 		" and   DELTA.VBD_LOJCLI = F2_LOJA" + CRLF
//		cQuery += 		" and   DELTA.VBD_QTDFAT = VS3_QTDITE" + CRLF
		cQuery += 		" and   DELTA.VBD_ALIAS = ?" + CRLF
		aAdd( aBind, { 'C', "TRF" } )
		cQuery += 		" and   DELTA.VBD_INDDEV = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		cQuery += 		" and   DELTA.VBD_INDCAN = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoCanc()} )
		cQuery += 		" and   DELTA.VBD_ALIAS=?" + CRLF
		aAdd( aBind, { 'C', 'TRF'} )
		cQuery += 		" and   DELTA.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' '} )
		cQuery += " ) " + CRLF
	else
		cQuery += " AND F2_EMISSAO between ? AND ? " + CRLF
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())

		aBind  := {}
		cQuery := "select VS1_DATORC, VS1_NUMORC, VS1_MOTCOM, VS1_TIPTEM," + CRLF
		cQuery += "  VS3_SEQUEN, VS3_CODSIT, VS3_CODITE, VS3_GRUITE, VS3_QTDITE, VS3_VALPEC," + CRLF
		cQuery += " (select AVG(D2_CUSTO1) from "+retSqlName("SD2")+" SD2 " + CRLF
		cQuery += "      where D2_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial('SD2') } )
		cQuery += "        and D2_DOC    = VS1_NUMNFI" + CRLF
		cQuery += "        and D2_SERIE  = VS1_SERNFI" + CRLF
		cQuery += "        and D2_COD    = VS3_CODITE" + CRLF
		cQuery += "        and SD2.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += ") D2_CUSTO1" + CRLF

		cQuery += " FROM "+retSqlName('VS3')+" VS3 " + CRLF
		cQuery += " JOIN "+retSqlName('VS1')+" VS1 on VS1_FILIAL = ? AND VS3_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', xFilial('VS1') } )
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND VS3_CODTES = F4_CODIGO AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', xFilial("SF4") } )
		aAdd( aBind, { 'C', 'S' } )
		aAdd( aBind, { 'C', ' ' } )
//		if cArm == "F01"	// armazéns gerenciados
//			cQuery += " JOIN "+retSqlName('VBF')+" VBF ON  VBF_FILIAL = ? AND VBF_PRODUT = VS3_CODITE AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?" + CRLF
//			aAdd( aBind, { 'C', xFilial('VBF') } )
//			aAdd( aBind, { 'C', 'S' } )
//			aAdd( aBind, { 'C', '1' } )
//			aAdd( aBind, { 'C', ' ' } )
//		endif
		cQuery += " WHERE VS3_FILIAL  = ?" + CRLF
		aAdd( aBind, { 'C', xFilial('VS3') } )
		cQuery += " and VS3_GRUITE IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )
		cQuery  += " AND VS1_NUMNFI = ?" + CRLF
		aAdd( aBind, { 'C', (cAl)->F2_DOC } )
		cQuery  += " AND VS1_SERNFI = ?" + CRLF
		aAdd( aBind, { 'C', (cAl)->F2_SERIE } )
		cQuery += " AND VS3.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' '} )

		OFCNHA015C_ExecQuery( @cQuery, aBind, cA2 )
		While ! (cA2)->(Eof())
			nRegs++

			reclock('VBD', .T.)
			VBD->VBD_FILIAL := xFilial('VBD')
			VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
			VBD->VBD_CODVBB := cCodVBB
			VBD->VBD_CODCLI := (cAl)->F2_CLIENTE
			VBD->VBD_LOJCLI := (cAl)->F2_LOJA
			VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
			VBD->VBD_NUMNFI := (cAl)->F2_DOC
			VBD->VBD_SERORI := (cAl)->F2_SERIE
			VBD->VBD_NUMREM := VBD->VBD_NUMNFI
			VBD->VBD_DATORI := iif( Empty( (cA2)->VS1_DATORC ), STOD((cAl)->F2_EMISSAO), STOD( (cA2)->VS1_DATORC ) )
			VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
													(cA2)->VS3_CODITE,;
													iif( Empty( (cA2)->VS1_DATORC ), "", (cA2)->VS1_NUMORC ),;
													VBD->VBD_NUMNFI,;
													VBD->VBD_SERORI,;
													VBD->VBD_CODCLI,;
													VBD->VBD_LOJCLI,;
													(cA2)->VS3_QTDITE,;
													iif( Empty( (cA2)->VS3_SEQUEN ), 0, VAL( (cA2)->VS3_SEQUEN ) ),;	// iif( Empty( (cAl)->VS1_DATORC ), VAL( (cAl)->D2_ITEM ), VAL( (cAl)->VS3_SEQUEN ) ),;
													VBD->VBD_NUMREM )
			VBD->VBD_NUMORI := iif( Empty( (cA2)->VS1_DATORC ), ""                     , (cA2)->VS1_NUMORC )
			VBD->VBD_MOTCOM := iif( Empty( (cA2)->VS1_DATORC ), ""                     , (cA2)->VS1_MOTCOM )
			VBD->VBD_DATNFI := STOD( (cAl)->F2_EMISSAO )
			VBD->VBD_CANALV := oCanalVenda:CanalTransf()
			VBD->VBD_PRODUT := (cA2)->VS3_CODITE
			VBD->VBD_QTDFAT := (cA2)->VS3_QTDITE
			VBD->VBD_QTDPED := (cA2)->VS3_QTDITE // Será regravado se tiver pedido com a quantidade corretamente pedida pelo cliente para calculo do NA
			VBD->VBD_INDDEV := oPrim:CodNaoDev()
			VBD->VBD_TIPDEM := oPrim:getDemanda( (cA2)->VS3_CODSIT )			// oPrim:CodVendNor()
			VBD->VBD_INDCAN := oPrim:CodNaoCanc()
			VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
			VBD->VBD_VALVDA := (cA2)->VS3_VALPEC
			VBD->VBD_CODGAR := 'Z' // venda normal
			VBD->VBD_ALIAS  := "TRF" // "SD2"
			VBD->VBD_TIPTEM := (cA2)->VS1_TIPTEM
			VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
			VBD->VBD_NUMSEQ := "TRANSF"
			VBD->VBD_CUSMED := (cA2)->D2_CUSTO1 / (cA2)->VS3_QTDITE // dividir o custo médio do item para o total de itens do pedido, para tentar chegar mais próximo do custo médio real do item na transferência
			VBD->(MsUnlock())
			(cA2)->(DBSkip())
		enddo
		(cA2)->(DBCloseArea())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0029})	// #"Gerando Registros de vendas balcão"
	aBind := {}
	cQuery := "select D2_ITEM, D2_DOC, D2_SERIE, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_CLIENTE, D2_LOJA, D2_EMISSAO," + CRLF
	cQuery += " VS1_DATORC, VS1_NUMORC, VS1_MOTCOM, VS1_NUMNFI, VS1_SERNFI, VS1_INDPRE, VS1_TIPTEM," + CRLF
	cQuery += " VS3_SEQUEN, VS3_QTDINI, VS3_QTDITE, VS3_CODSIT," + CRLF
	cQuery += " D2_NUMSEQ, D2_CUSTO1, F4_OPEMOV, F2_PREFORI" + CRLF
	cQuery += " FROM "+retSqlName('SD2') + " SD2 " + CRLF
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL = ? AND D2_TES = F4_CODIGO AND F4_ESTOQUE = ? AND SF4.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
//	if cArm == "F01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL = ? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?" + CRLF
//		aAdd( aBind, { 'C', xFilial('VBF') } )
//		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', ' ' } )
//	endif
	cQuery += " JOIN "+retSqlName('SF2')+" SF2 ON F2_FILIAL = D2_FILIAL AND D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE AND F2_PREFORI = ? AND SF2.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', cPrefBal } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('VS1')+" VS1 on VS1_FILIAL = D2_FILIAL AND VS1_TIPORC = ? AND VS1_NUMNFI = D2_DOC AND VS1_SERNFI = D2_SERIE AND VS1.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('VS3')+" VS3 on VS3_FILIAL = D2_FILIAL AND VS3_NUMORC = VS1_NUMORC AND VS3_CODITE = D2_COD AND VS1.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " WHERE F2_FILIAL = ?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF2') } )
	cQuery  += " AND D2_GRUPO IN (?)" + CRLF
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and not exists (" + CRLF
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
		cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
		cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
		cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
		cQuery +=               " and VBB_CATTRA = ?" + CRLF
		aAdd( aBind, { 'C', cTipoGer } )
		cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 		" where DELTA.VBD_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD')} )
		cQuery += 		" and   DELTA.VBD_PRODUT = D2_COD" + CRLF
		cQuery += 		" and   DELTA.VBD_NUMNFI = D2_DOC" + CRLF
		cQuery += 		" and   DELTA.VBD_SERORI = D2_SERIE" + CRLF
		cQuery += 		" and   DELTA.VBD_CODCLI = D2_CLIENTE" + CRLF
		cQuery += 		" and   DELTA.VBD_LOJCLI = D2_LOJA" + CRLF
		cQuery += 		" and   DELTA.VBD_QTDFAT = D2_QUANT" + CRLF
		cQuery += 		" and   DELTA.VBD_QTDPED = D2_QUANT" + CRLF
		cQuery += 		" and   DELTA.VBD_INDDEV = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		cQuery += 		" and   DELTA.VBD_INDCAN = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoCanc()} )
		cQuery += 		" and   DELTA.VBD_ALIAS=?" + CRLF
		aAdd( aBind, { 'C', 'BAL'} )
		cQuery += 		" and   DELTA.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' '} )
		cQuery += " ) "
	else
		cQuery += " AND SD2.D2_EMISSAO between ? AND ? " + CRLF
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND SD2.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' '} )

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		nRegs++

//		OFCNHA019C_produtoMovimentado( (cAl)->D2_COD )

		reclock('VBD', .T.)
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_CODCLI := (cAl)->D2_CLIENTE
		VBD->VBD_LOJCLI := (cAl)->D2_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMNFI := (cAl)->D2_DOC   // (cAl)->VS1_NUMNFI
		VBD->VBD_SERORI := (cAl)->D2_SERIE // (cAl)->VS1_SERNFI
		VBD->VBD_NUMREM := VBD->VBD_NUMNFI
		VBD->VBD_NUMORI := iif( empty((cAl)->VS1_NUMORC), (cAl)->(D2_DOC+D2_SERIE), (cAl)->VS1_NUMORC )
		VBD->VBD_DATORI := STOD( iif( empty((cAl)->VS1_DATORC), (cAl)->D2_EMISSAO, (cAl)->VS1_DATORC ) )
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->D2_COD,;
												VBD->VBD_NUMORI,;
												VBD->VBD_NUMNFI,;
												VBD->VBD_SERORI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->D2_QUANT,;
												iif( Empty( (cAl)->VS3_SEQUEN ), 0, VAL( (cAl)->VS3_SEQUEN ) ),;
												VBD->VBD_NUMREM )
		VBD->VBD_DATNFI := STOD( (cAl)->D2_EMISSAO )
		VBD->VBD_CANALV := oCanalVenda:retCanal( (cAl)->F2_PREFORI, (cAl)->F4_OPEMOV, (cAl)->VS3_CODSIT, (cAl)->VS1_INDPRE, VBD->VBD_CODCLI, VBD->VBD_LOJCLI )			// oCanalVenda:CanalBalcao()
		VBD->VBD_PRODUT := (cAl)->D2_COD
		VBD->VBD_QTDFAT := (cAl)->D2_QUANT
		VBD->VBD_QTDPED := (cAl)->D2_QUANT
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_TIPDEM := oPrim:getDemanda( (cAl)->VS3_CODSIT )				// oPrim:CodVendNor()
		VBD->VBD_INDCAN := oPrim:CodNaoCanc()
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_MOTCOM := (cAl)->VS1_MOTCOM
		VBD->VBD_VALVDA := (cAl)->D2_PRCVEN
		VBD->VBD_CODGAR := 'Z' // venda normal
		VBD->VBD_ALIAS  := "BAL"
		VBD->VBD_TIPTEM := (cAl)->VS1_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->VBD_NUMSEQ := "VD_BAL"
		VBD->VBD_CUSMED := (cAl)->D2_CUSTO1 / (cAl)->D2_QUANT // dividir pela quantidade para pegar o custo unitário, pois o campo D2_CUSTO1 vem com o valor total do item
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0085})	// #"Iniciando geracao de registros Vendas fora DMS"
	aBind := {}
	cQuery := "select D2_ITEM, D2_DOC, D2_SERIE, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_CLIENTE, D2_LOJA, D2_EMISSAO," + CRLF
	cQuery += " D2_NUMSEQ, D2_CUSTO1, F4_OPEMOV, F2_PREFORI" + CRLF
	cQuery += " FROM "+retSqlName('SD2') + " SD2 " + CRLF
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL = ? AND D2_TES = F4_CODIGO AND F4_ESTOQUE = ? AND SF4.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
//	if cArm == "F01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL = ? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?" + CRLF
//		aAdd( aBind, { 'C', xFilial('VBF') } )
//		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', ' ' } )
//	endif
	cQuery += " JOIN "+retSqlName('SF2')+" SF2 ON F2_FILIAL = D2_FILIAL AND D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE AND F2_PREFORI = ? AND SF2.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " WHERE F2_FILIAL = ?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF2') } )
	cQuery  += " AND D2_GRUPO IN (?)" + CRLF
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and not exists (" + CRLF
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
		cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
		cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
		cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
		cQuery +=               " and VBB_CATTRA = ?" + CRLF
		aAdd( aBind, { 'C', cTipoGer } )
		cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 		" where DELTA.VBD_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBD')} )
		cQuery += 		" and   DELTA.VBD_PRODUT = D2_COD" + CRLF
		cQuery += 		" and   DELTA.VBD_NUMNFI = D2_DOC" + CRLF
		cQuery += 		" and   DELTA.VBD_SERORI = D2_SERIE" + CRLF
		cQuery += 		" and   DELTA.VBD_CODCLI = D2_CLIENTE" + CRLF
		cQuery += 		" and   DELTA.VBD_LOJCLI = D2_LOJA" + CRLF
		cQuery += 		" and   DELTA.VBD_QTDFAT = D2_QUANT" + CRLF
		cQuery += 		" and   DELTA.VBD_QTDPED = D2_QUANT" + CRLF
		cQuery += 		" and   DELTA.VBD_INDDEV = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		cQuery += 		" and   DELTA.VBD_INDCAN = ?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoCanc()} )
		cQuery += 		" and   DELTA.VBD_ALIAS=?" + CRLF
		aAdd( aBind, { 'C', 'OUT'} )
		cQuery += 		" and   DELTA.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' '} )
		cQuery += " ) "
	else
		cQuery += " AND SD2.D2_EMISSAO between ? AND ? " + CRLF
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND SD2.D_E_L_E_T_ = ?" + CRLF
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
		VBD->VBD_NUMORI := (cAl)->(D2_DOC+D2_SERIE)
		VBD->VBD_DATORI := STOD( (cAl)->D2_EMISSAO )
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->D2_COD,;
												VBD->VBD_NUMORI,;
												VBD->VBD_NUMNFI,;
												VBD->VBD_SERORI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->D2_QUANT,;
												0,;
												VBD->VBD_NUMREM )
		VBD->VBD_DATNFI := STOD( (cAl)->D2_EMISSAO )
		VBD->VBD_CANALV := oCanalVenda:retCanal( (cAl)->F2_PREFORI, (cAl)->F4_OPEMOV, '03', '', VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_PRODUT := (cAl)->D2_COD
		VBD->VBD_QTDFAT := (cAl)->D2_QUANT
		VBD->VBD_QTDPED := (cAl)->D2_QUANT
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_TIPDEM := oPrim:getDemanda()
		VBD->VBD_INDCAN := oPrim:CodNaoCanc()
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_MOTCOM := ""
		VBD->VBD_VALVDA := (cAl)->D2_PRCVEN
		VBD->VBD_CODGAR := 'Z' // venda normal
		VBD->VBD_ALIAS  := "OUT"
		VBD->VBD_TIPTEM := ""
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->VBD_NUMSEQ := "VD_OUT"
		VBD->VBD_CUSMED := (cAl)->D2_CUSTO1 / (cAl)->D2_QUANT // dividir pela quantidade para pegar o custo unitário, pois o campo D2_CUSTO1 vem com o valor total do item
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |> "+STR0030})	// #"Iniciando geracao de registros de oficina"
	// OFICINA
	aBind  := {}
	cQuery := "select * FROM (" + CRLF
	cQuery += "SELECT D2_PRCVEN, D2_QUANT, D2_ITEM, VOO_NUMOSV, VO1_DATABE, VOI_SITTPO, D2_CLIENTE, D2_LOJA, VOO_NUMNFI, VOO_SERNFI, D2_EMISSAO, D2_COD, VO1_CHASSI," + CRLF
	cQuery += "D2_DOC, D2_SERIE, D2_CUSTO1, "
	cQuery += "VV1_MODVEI, VO1_KILOME, VV1_CODMAR, VO1_MOTCOM, D2_NUMSEQ, 'OFI' ORIGEM, D2_GRUPO, VO3_QTDREQ, VO3_CODSIT, VOO_TIPTEM, VO3_NOSNUM, F4_OPEMOV, VOO_INDPRE" + CRLF
	cQuery += " FROM "+retSqlName('SD2')+" SD2 " + CRLF
	cQuery += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND D2_TES = F4_CODIGO AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('VOO')+" VOO ON VOO_FILIAL=? AND VOO_SERNFI = D2_SERIE AND VOO_NUMNFI = D2_DOC AND VOO.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VOO") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN "+retSqlName('VO1')+" VO1 ON VO1_FILIAL=? AND VO1_NUMOSV = VOO_NUMOSV AND VO1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VO1") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN (" + CRLF
	cQuery += 		"select " + CRLF
	cQuery += 			" VO3_FILIAL, VO3_CODITE, VO3_NUMOSV, VO3_CODSIT, max(VO3_NOSNUM) VO3_NOSNUM," + CRLF
	cQuery += 			" SUM(CASE WHEN VO2_DEVOLU=? THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) VO3_QTDREQ" + CRLF
	aAdd( aBind, { 'C', '1' } )
	cQuery += 		" FROM "+retSqlName('VO3')+" VO3" + CRLF
	cQuery += 		" JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL =? AND F4_CODIGO = VO3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=? AND VO2_NOSNUM=VO3_NOSNUM AND VO2_TIPREQ=? AND VO2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VO2") } )
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" WHERE VO3.VO3_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VO3") } )
	cQuery += 		" AND VO3.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" GROUP BY VO3_FILIAL, VO3_CODITE, VO3_NUMOSV, VO3_CODSIT" + CRLF
	cQuery += ") VO3S ON VO3_FILIAL=VO1_FILIAL AND VO3_NUMOSV = VO1_NUMOSV AND VO3_CODITE = D2_COD " + CRLF

	cQuery += " JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT = VO1_CHAINT AND VV1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VV1") } )
	aAdd( aBind, { 'C', ' ' } )
//	if cArm == "F01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL=? AND VBF_PRODUT = D2_COD AND VBF_FLGARQ=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?" + CRLF
//		aAdd( aBind, { 'C', xFilial("VBF") } )
//		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', ' ' } )
//	endif
	cQuery += " JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VOO_TIPTEM = VOI_TIPTEM AND VOI.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VOI") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " WHERE SD2.D2_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SD2") } )
	cQuery += " AND SD2.D_E_L_E_T_=? " + CRLF
	aAdd( aBind, { 'C', ' ' } )

	cQuery += CRLF + " UNION ALL " + CRLF

	cQuery += OFCNHA014C_getQryRes( cArm ) + CRLF		// Obtém reservas
	cQuery += ") TEMP " + CRLF
	cQuery += " WHERE D2_GRUPO IN (?)" + CRLF
	aAdd( aBind, { 'A', aGrupos } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " and not exists (" + CRLF
		cQuery += 		"select 1 from "+retSqlName("VBD")+" DELTA " + CRLF
		cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
		cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
		cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
		cQuery +=               " and VBB_CATTRA = ?" + CRLF
		aAdd( aBind, { 'C', cTipoGer } )
		cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 		" where DELTA.VBD_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += 		" and   DELTA.VBD_PRODUT = D2_COD" + CRLF
		cQuery += 		" and   DELTA.VBD_NUMORI = VOO_NUMOSV" + CRLF
		cQuery += 		" and   DELTA.VBD_NUMREM = VO3_NOSNUM" + CRLF
		cQuery += 		" and   DELTA.VBD_NUMNFI = VOO_NUMNFI" + CRLF
		cQuery += 		" and   DELTA.VBD_SERORI = VOO_SERNFI" + CRLF
		cQuery += 		" and   DELTA.VBD_CODCLI = D2_CLIENTE" + CRLF
		cQuery += 		" and   DELTA.VBD_LOJCLI = D2_LOJA" + CRLF
		cQuery += 		" and   DELTA.VBD_QTDFAT = D2_QUANT" + CRLF
		cQuery += 		" and   DELTA.VBD_TIPTEM = VOO_TIPTEM" + CRLF		// Tipo de Tempo
		cQuery += 		" and   DELTA.VBD_INDDEV=?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoDev() } )
		cQuery += 		" and   DELTA.VBD_INDCAN=?" + CRLF
		aAdd( aBind, { 'C', oPrim:CodNaoCanc() } )
		cQuery += 		" and   DELTA.VBD_ALIAS = ORIGEM" + CRLF
		cQuery += 		" and   DELTA.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " ) " + CRLF
	else
		cQuery += " AND ( D2_EMISSAO BETWEEN ? AND ? OR D2_EMISSAO=? )" + CRLF
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
		aAdd( aBind, { 'C', ' ' } )
	endif
	cQuery += " ORDER BY VOO_NUMOSV,D2_COD" + CRLF

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		nRegs++
		aAdd( aOrcs, (cAl)->VOO_NUMOSV )
		nItem := 0
		for nI := 1 to len( aOrcs )
			nItem += iif( aOrcs[nI] == (cAl)->VOO_NUMOSV, 1, 0)
		next

//		OFCNHA019C_produtoMovimentado( (cAl)->D2_COD )
		if empty( (cAl)->D2_ITEM ) .and. (cAl)->ORIGEM == "OFI"
			nLinVen := OFCNHA021C_retornaSeqOS( (cAl)->VO3_NOSNUM, (cAl)->D2_COD )
		else
			nLinVen := OFCNHA018C_getLinVen(xFilial('VBD'),;
											(cAl)->D2_COD,;
											(cAl)->VOO_NUMOSV,;
											(cAl)->VOO_NUMNFI,;
											(cAl)->VOO_SERNFI,;
											(cAl)->D2_CLIENTE,;
											(cAl)->D2_LOJA,;
											(cAl)->D2_QUANT,;
											nItem,; // iif( Empty( (cAl)->D2_ITEM ), nItem, VAL( (cAl)->D2_ITEM ) ),;
											(cAl)->VO3_NOSNUM )
		endif

		reclock('VBD', .T.)
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODCLI := (cAl)->D2_CLIENTE
		VBD->VBD_LOJCLI := (cAl)->D2_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMORI := (cAl)->VOO_NUMOSV
		VBD->VBD_NUMREM := (cAl)->VO3_NOSNUM		//VBD->VBD_NUMNFI
/*
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->D2_COD,;
												VBD->VBD_NUMORI,;
												(cAl)->VOO_NUMNFI,;
												(cAl)->VOO_SERNFI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->D2_QUANT,;
												iif( Empty( (cAl)->D2_ITEM ), nItem, VAL( (cAl)->D2_ITEM ) ),;
												VBD->VBD_NUMREM )
*/
		VBD->VBD_LINVEN := nLinVen
		VBD->VBD_NUMNFI := (cAl)->D2_DOC   // (cAl)->VOO_NUMNFI
		VBD->VBD_SERORI := (cAl)->D2_SERIE // (cAl)->VOO_SERNFI
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
//		VBD->VBD_CODGAR := iif( (cAl)->VOI_SITTPO == "3", 'D', 'Z' )	// D=consumo interno;Z=venda normal
		VBD->VBD_CODGAR := oCanalVenda:retGarantia( (cAl)->VOI_SITTPO )
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_CANALV := oCanalVenda:retCanal( (cAl)->ORIGEM, (cAl)->F4_OPEMOV, (cAl)->VO3_CODSIT, (cAl)->VOO_INDPRE, VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_ALIAS  := (cAl)->ORIGEM // iif( empty((cAl)->D2_NUMSEQ), "RES", "VO3" )
		VBD->VBD_TIPTEM := (cAl)->VOO_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->VBD_NUMSEQ := "VD_OFI"
		VBD->VBD_CUSMED := iif( !empty( (cAl)->D2_DOC ), (cAl)->D2_CUSTO1 / (cAl)->D2_QUANT, (cAl)->D2_CUSTO1 ) // dividir pela quantidade para pegar o custo unitário, pois o campo D2_CUSTO1 vem com o valor total do item
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

//------------------------------------ itens em backorder, não reservados -----------------------------------

	oLogger:Log({"TIMESTAMP","  |> "+STR0081})	// #"Gerando itens em backorder sem reserva"
	aBind := {}
	cQuery := "SELECT" + CRLF
	cQuery += " VS1_CLIFAT," + CRLF
	cQuery += " VS1_LOJA," + CRLF
	cQuery += " VS1_DATORC," + CRLF
	cQuery += " VS1_NUMORC," + CRLF
	cQuery += " VS1_MOTCOM," + CRLF
	cQuery += " VS1_NUMNFI," + CRLF
	cQuery += " VS1_SERNFI," + CRLF
	cQuery += " VS1_INDPRE," + CRLF
	cQuery += " VS1_TIPTEM," + CRLF

	cQuery += " VS3_CODITE," + CRLF
	cQuery += " VS3_VALPEC," + CRLF
	cQuery += " VS3_VALTOT," + CRLF
	cQuery += " VS3_SEQUEN," + CRLF
	cQuery += " VS3_QTDINI," + CRLF
	cQuery += " VS3_QTDITE," + CRLF
	cQuery += " VS3_CODSIT," + CRLF
	cQuery += " VS3_MOTPED," + CRLF

	cQuery += " F4_OPEMOV," + CRLF
	cQuery += " B2_CM1" + CRLF

	cQuery += " FROM " + retSqlName("VS3") +" VS3 " + CRLF

	cQuery += " JOIN " + retSqlName("SF4") + " SF4 " + CRLF
	cQuery += 	" ON  F4_FILIAL = ?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	cQuery += 	" AND F4_CODIGO = VS3_CODTES" + CRLF
	cQuery += 	" AND F4_ESTOQUE = ?" + CRLF
	aAdd( aBind, { 'C', 'S' } )
	cQuery += 	" AND SF4.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " JOIN " + retSqlName("VS1") + " VS1 " + CRLF
	cQuery += 	" ON  VS1_FILIAL = VS3_FILIAL" + CRLF
	cQuery += 	" AND VS1_TIPORC = ?" + CRLF
	aAdd( aBind, { 'C', 'P' } )
	cQuery += 	" AND VS1_NUMORC = VS3_NUMORC" + CRLF
	cQuery += 	" AND VS1.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " JOIN " + retSqlName("SB1") + " SB1 " + CRLF
	cQuery += 	" ON  B1_FILIAL = ?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	cQuery += 	" AND B1_GRUPO = VS3_GRUITE" + CRLF
	cQuery += 	" AND B1_CODITE = VS3_CODITE" + CRLF
	cQuery += 	" AND SB1.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " JOIN " + retSqlName("SB2") + " SB2 " + CRLF
	cQuery += 	" ON  B2_FILIAL = ?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB2') } )
	cQuery += 	" AND B2_COD = B1_COD" + CRLF
	cQuery += 	" AND B2_LOCAL = VS3_LOCAL" + CRLF
	cQuery += 	" AND SB2.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )

//	if cArm == "F01"	// armazéns gerenciados
//		cQuery += " JOIN "+retSqlName('VBF')+" VBF ON VBF_FILIAL = ? AND VBF_PRODUT = VS3_CODITE AND VBF_FLGARQ = ? AND VBF_FLGUSO = ? AND VBF.D_E_L_E_T_ = ?" + CRLF
//		aAdd( aBind, { 'C', xFilial('VBF') } )
//		aAdd( aBind, { 'C', 'S' } )
//		aAdd( aBind, { 'C', '1' } )
//		aAdd( aBind, { 'C', ' ' } )
//	endif

	cQuery += " WHERE VS3_FILIAL = ?" + CRLF
	aAdd( aBind, { 'C', xFilial("VS3") } )

//	if cArm != "F01"	// armazéns não gerenciados
		cQuery += " and VS3_GRUITE IN (?)" + CRLF
		aAdd( aBind, { 'A', aGrupos } )
//	endif

	cQuery += " AND VS1_STATUS=?" + CRLF
	aAdd( aBind, { 'C', '0' } )
	cQuery += " AND VS1_TIPORC=?" + CRLF
	aAdd( aBind, { 'C', 'P' } )

	cQuery += " AND (VS1_PEDSTA <> ? AND VS3_QTDRES = ? AND (VS3_QTDAGU > ? OR VS3_QTDTRA > ? OR VS3_MOTPED <> ?))" + CRLF
	aAdd( aBind, { 'C', '2' } )
	aAdd( aBind, { 'N', 0 } )
	aAdd( aBind, { 'N', 0 } )
	aAdd( aBind, { 'N', 0 } )
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " AND VS1_PEDREF <> VS1_NUMORC" + CRLF
	cQuery += " AND VS1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )

	if cTipoGer == oPrim:CodGerNormal()
		cQuery += " AND NOT EXISTS " + CRLF
		cQuery += 		" (SELECT 1" + CRLF
		cQuery += 		" FROM " + retSqlName("VBD") + " DELTA " + CRLF
		cQuery += 		"join "+retSqlName("VBB")+" VBB " + CRLF
		cQuery +=       		" on  VBB_FILIAL = VBD_FILIAL" + CRLF
		cQuery +=               " and VBB_CODIGO = VBD_CODVBB" + CRLF
		cQuery +=               " and VBB_CATTRA = ?" + CRLF
		aAdd( aBind, { 'C', cTipoGer } )
		cQuery +=               " and VBB.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 		" WHERE DELTA.VBD_FILIAL = ?" + CRLF
		aAdd( aBind, { 'C', xFilial("VBD") } )
		cQuery += 		" AND DELTA.VBD_PRODUT = VS3_CODITE" + CRLF
		cQuery += 		" AND DELTA.VBD_NUMNFI = VS1_NUMNFI" + CRLF
		cQuery += 		" AND DELTA.VBD_SERORI = VS1_SERNFI" + CRLF
		cQuery += 		" AND DELTA.VBD_CODCLI = VS1_CLIFAT" + CRLF
		cQuery += 		" AND DELTA.VBD_LOJCLI = VS1_LOJA" + CRLF
		cQuery += 		" AND DELTA.VBD_QTDFAT = VS3_QTDITE" + CRLF
		cQuery += 		" AND DELTA.VBD_QTDPED = VS3_QTDITE" + CRLF
		cQuery += 		" AND DELTA.VBD_INDDEV = ?" + CRLF
		aAdd( aBind, { 'C', 'N' } )
		cQuery += 		" AND (( DELTA.VBD_INDCAN = ? AND VS3_MOTPED = ? ) OR DELTA.VBD_INDCAN = ?) " + CRLF
		aAdd( aBind, { 'C', 'N' } )
		aAdd( aBind, { 'C', ' ' } )
		aAdd( aBind, { 'C', 'Y' } )
		cQuery += 		" AND DELTA.VBD_ALIAS=?" + CRLF
		aAdd( aBind, { 'C', 'BAL' } )
		cQuery += 		" AND DELTA.D_E_L_E_T_ = ? )" + CRLF
		aAdd( aBind, { 'C', ' ' } )
	else
		cQuery += " AND VS1_DATORC between ? AND ? " + CRLF
		aAdd( aBind, { 'D', dDataIni } )
		aAdd( aBind, { 'D', dDataFim } )
	endif
	cQuery += " AND VS3.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )

	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		nRegs++

//		OFCNHA019C_produtoMovimentado( (cAl)->VS3_CODITE )

		if cTipoGer == oPrim:CodGerExcepcional() .and. ! empty( (cAl)->VS3_MOTPED )		// PRIM1 não envia cancelados
			(cAl)->( dbSkip() )
			loop
		endif

		reclock('VBD', .T.)
		VBD->VBD_FILIAL := xFilial('VBD')
		VBD->VBD_CODIGO := GetSxeNum('VBD', 'VBD_CODIGO'); confirmSx8()
		VBD->VBD_CODVBB := cCodVBB
		VBD->VBD_CODCLI := (cAl)->VS1_CLIFAT
		VBD->VBD_LOJCLI := (cAl)->VS1_LOJA
		VBD->VBD_CDCLI2 := OFCNHA017C_inserirVCF( VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_NUMNFI := (cAl)->VS1_NUMNFI
		VBD->VBD_SERORI := (cAl)->VS1_SERNFI
		VBD->VBD_NUMREM := VBD->VBD_NUMNFI
		VBD->VBD_NUMORI := (cAl)->VS1_NUMORC
		VBD->VBD_DATORI := STOD( (cAl)->VS1_DATORC )
		VBD->VBD_LINVEN := OFCNHA018C_getLinVen( VBD->VBD_FILIAL,;
												(cAl)->VS3_CODITE,;
												VBD->VBD_NUMORI,;
												VBD->VBD_NUMNFI,;
												VBD->VBD_SERORI,;
												VBD->VBD_CODCLI,;
												VBD->VBD_LOJCLI,;
												(cAl)->VS3_QTDITE,;
												VAL( (cAl)->VS3_SEQUEN ),;
												VBD->VBD_NUMREM )
		VBD->VBD_CANALV := oCanalVenda:retCanal( cPrefBal, (cAl)->F4_OPEMOV, (cAl)->VS3_CODSIT, (cAl)->VS1_INDPRE, VBD->VBD_CODCLI, VBD->VBD_LOJCLI )
		VBD->VBD_PRODUT := (cAl)->VS3_CODITE
		VBD->VBD_QTDFAT := (cAl)->VS3_QTDITE
		VBD->VBD_QTDPED := (cAl)->VS3_QTDITE
		VBD->VBD_INDDEV := oPrim:CodNaoDev()
		VBD->VBD_TIPDEM := oPrim:getDemanda( (cAl)->VS3_CODSIT )
		VBD->VBD_INDCAN := iif( empty( (cAl)->VS3_MOTPED), oPrim:CodNaoCanc(), oPrim:CodCanc() )
		VBD->VBD_SUBCAN := oPrim:SubCanalPadrao()
		VBD->VBD_MOTCOM := (cAl)->VS1_MOTCOM
		VBD->VBD_VALVDA := (cAl)->VS3_VALTOT
		VBD->VBD_CODGAR := 'Z' // venda normal
		VBD->VBD_ALIAS  := "BAL"
		VBD->VBD_TIPTEM := (cAl)->VS1_TIPTEM
		VBD->VBD_SQCANC := OFCNHA016C_getCancel( VBD->VBD_FILIAL, VBD->VBD_NUMORI, VBD->VBD_PRODUT, VBD->VBD_TIPTEM )
		VBD->VBD_NUMSEQ := "BO_SRE"
		VBD->VBD_CUSMED := (cAl)->B2_CM1 // verificar se é o custo unitário
		VBD->(MsUnlock())
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP","  |> "+STR0020})	//#Finalizado

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

	oLogger:Log({"TIMESTAMP","  |>   |> " + STR0068})	//#"Iniciando coleta de dados de fornecedor"
	aBind  := {}
	cQuery := "UPDATE "+retsqlname('VBC') + CRLF
	cQuery += 	" SET VBC_CODFOR = TMP.A2_COD, " + CRLF
	cQuery += 		" VBC_FORNAM = TMP.FORNAM " + CRLF
	cQuery += 	" FROM ( " + CRLF
	cQuery += 		" SELECT B1_COD, A2_COD, CASE WHEN A2_NEMPR=? THEN A2_NREDUZ ELSE A2_NEMPR END AS FORNAM " + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" FROM "+retsqlname('SB1')+" SB1 " + CRLF
	cQuery += 		" JOIN "+retsqlname('SA2')+" SA2 ON A2_FILIAL=? AND A2_COD = B1_PROC AND SA2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SA2") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 		" WHERE SB1.B1_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SB1") } )
	cQuery += 		" AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" ) TMP " + CRLF
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VBC') } )
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.B1_COD " + CRLF
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0067)	//#coleta de dados de fornecedor
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})		//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0039})	//#"Iniciando coleta de datas de ultima saida"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBC') + CRLF
	cQuery += 	" SET VBC_ULTSAI = TMP.ULTSAI " + CRLF
	cQuery += " FROM ( " + CRLF
	cQuery += 	" SELECT  D2_COD, MAX(D2_EMISSAO) AS ULTSAI " + CRLF
	cQuery += 	" FROM "+retsqlname('SD2')+" SD2 " + CRLF
	cQuery += 	" JOIN "+retsqlname('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = D2_TES AND SF4.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE D2_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SD2") } )
	cQuery += 	" AND F4_ESTOQUE=?" + CRLF
	aAdd( aBind, { 'C', 'S' } )
		cQuery += 	" AND F4_OPEMOV NOT IN (?)" + CRLF
	//aAdd( aBind, { 'A', {'03','04','12','15'} } )//REVISAR, DEPENDÊNCIA DO CANAL DE VENDAS.
	aAdd( aBind, { 'A', {'01','02','03','06','07','08','09','11','12','13','14','15'} } )//REVISAR, DEPENDÊNCIA DO CANAL DE VENDAS.
	cQuery += 	" AND SD2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" GROUP BY D2_COD " + CRLF
	cQuery += " ) TMP " + CRLF
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VBC") } )
	cQuery += 	" AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.D2_COD " + CRLF
	cQuery += 	" AND "+retsqlname('VBC')+".VBC_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += 	" AND "+retsqlname('VBC')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0040)	//#"Erro de query na captação das últimas saídas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0041})	// #"Iniciando coleta de dados de ultima entrada"
	aBind  := {}
	cQuery := "UPDATE "+retsqlname('VBC') + CRLF
	cQuery += 	" SET VBC_ULTENT = TMP.ULTENT " + CRLF
	cQuery += 	" FROM ( " + CRLF
	cQuery += 	" SELECT D1_COD, MAX(D1_DTDIGIT) ULTENT " + CRLF
	cQuery += 	" FROM "+retsqlname('SD1')+" SD1 " + CRLF
	cQuery += 	" JOIN "+retsqlname('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SF4") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE D1_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SD1") } )
	cQuery += 	" AND F4_ESTOQUE=?" + CRLF
	aAdd( aBind, { 'C', 'S' } )
	cQuery += 	" GROUP BY D1_COD " + CRLF
	cQuery += " ) TMP " + CRLF
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial("VBC") } )
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.D1_COD " + CRLF
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0042)		//#"Erro de query na captação das últimas entradas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0043})	// #"Iniciando coleta de dados de ultima entrada pelo SB9"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBC')
	cQuery += 	" SET VBC_ULTENT = TMP.ULTENT " + CRLF
	cQuery += " FROM ( " + CRLF
//	cQuery += 	" SELECT B9_COD, MAX(B9_DATA) ULTENT " + CRLF
	cQuery += 	" SELECT B9_COD, coalesce( MAX(B9_DATA), ? ) ULTENT " + CRLF
	aAdd( aBind, { 'C', '19900101' } )
	cQuery += 	" FROM "+retsqlname('SB9') + CRLF
	cQuery += 	" WHERE B9_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB9') } )
	cQuery += 	" AND B9_DATA <> ?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" AND D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" GROUP BY B9_COD " + CRLF
	cQuery += " ) TMP " + CRLF
	cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VBC') } )
	cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.B9_COD " + CRLF
	cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBC')+".VBC_ULTENT=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0044)		//#"Erro de query na captação das últimas entradas via saldo inicial."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0047})	// #"Gravando totais no cabecalho de estoque"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBB') + CRLF
	cQuery += 	" SET VBB_NUMREG = TMP.QTD, " + CRLF
	cQuery += 		" VBB_FILEQU = TMP.SOMA " + CRLF
	cQuery += " FROM ( " + CRLF
	cQuery += 	" SELECT VBC_CODVBB, COUNT(*) QTD, SUM( VBC_QTDEST + VBC_QTDENC + VBC_BACKOR ) SOMA"
//	cQuery +=   " case when VBC_QTDEST < 0 then 0 else VBC_QTDEST end + VBC_QTDENC + " + CRLF
//	cQuery += 	" case when VBC_BACKOR > VBC_QTDEST then VBC_BACKOR - VBC_QTDEST else 0 end " + CRLF// REVISAR
//	cQuery += 	" case when VBC_BACKOR > 0 then VBC_BACKOR - (VBC_QTDEST+VBC_QTDRES) else 0 end " + CRLF			// igual tratativa de BackOrder no OFCNHPrim.prw
//	cQuery += ") SOMA " + CRLF
	cQuery += 	" FROM "+retsqlname('VBC') + CRLF
	cQuery += 	" WHERE VBC_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VBC') } )
	cQuery += 	" AND VBC_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += 	" AND D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" GROUP BY VBC_CODVBB " + CRLF
	cQuery += " ) TMP " + CRLF
	cQuery += " WHERE "+retsqlname('VBB')+".VBB_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VBB') } )
	cQuery += "   AND "+retsqlname('VBB')+".VBB_CODIGO=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBB')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0048)	//#"Erro de query nas somas de cabeçalho."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	if lSBZ .AND. lBZ_LOCALI2
		oLogger:Log({"TIMESTAMP","  |>   |> "+ STR0069})	// #"Gravando Localização da SBZ"
		aBind  := {}
		cQuery := " UPDATE "+retsqlname('VBC') + CRLF
		cQuery += 	" SET VBC_LOCCAO = TMP.BZ_LOCALI2 " + CRLF
		cQuery += " FROM ( " + CRLF
		cQuery += 	" SELECT BZ_COD, BZ_LOCALI2 " + CRLF
		cQuery += 	" FROM "+RetSqlName('SBZ')+" SBZ" + CRLF
		cQuery += 	" WHERE BZ_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SBZ') } )
		cQuery += 	" AND BZ_LOCALI2 != ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 	" AND SBZ.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " ) TMP " + CRLF
		cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBC') } )
		cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.BZ_COD " + CRLF
		cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?" + CRLF
		aAdd( aBind, { 'C', cCodVBB } )
		cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0070)	//#"Erro gravação Localização na SBZ"
		oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado
	endif

	if SB5->(FieldPos('B5_LOCALI2')) > 0
		aBind  := {}
		oLogger:Log({"TIMESTAMP","  |>   |> "+ STR0071})	// #"Gravando Localização da SB5"
		cQuery := "UPDATE "+retsqlname('VBC') + CRLF
		cQuery += 	" SET VBC_LOCCAO = TMP.B5_LOCALI2 " + CRLF
		cQuery += " FROM ( " + CRLF
		cQuery += 	" SELECT B5_COD, B5_LOCALI2 " + CRLF
		cQuery += 	" FROM "+RetSqlName('SB5') + CRLF
		cQuery += 	" WHERE B5_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SB5') } )
		cQuery += 	" AND B5_LOCALI2 != ?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += 	" AND D_E_L_E_T_ =?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
		cQuery += " ) TMP " + CRLF
		cQuery += " WHERE "+retsqlname('VBC')+".VBC_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('VBC') } )
		cQuery += "   AND "+retsqlname('VBC')+".VBC_PRODUT = TMP.B5_COD " + CRLF
		cQuery += "   AND "+retsqlname('VBC')+".VBC_CODVBB=?" + CRLF
		aAdd( aBind, { 'C', cCodVBB } )
		cQuery += "   AND "+retsqlname('VBC')+".D_E_L_E_T_=?" + CRLF
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
	cQuery := " UPDATE " + retsqlname('VBD') + CRLF
	cQuery += 	" SET VBD_NOMCLI = LEFT(TMP.A1_NOME, ?)," + CRLF
	aAdd( aBind, { 'N', tamsx3('VBD_NOMCLI')[1] } )
	cQuery += 		" VBD_CLICEP = LEFT(TMP.A1_CEP , ?)," + CRLF
	aAdd( aBind, { 'N', tamsx3('VBD_CLICEP')[1] } )
	cQuery += 		" VBD_ENDCLI = LEFT(TMP.A1_END , ?)," + CRLF
	aAdd( aBind, { 'N', tamsx3('VBD_ENDCLI')[1] } )
	cQuery += 		" VBD_CLCNPJ = ?" + CRLF
	aAdd( aBind, { 'U', oSqlHlp:Concat({'SUBSTRING(TMP.A1_CGC, 0, 9)', 'SUBSTRING(TMP.A1_CGC, 11, 2)'}) } )
	cQuery += " FROM (" + CRLF
	cQuery += "   SELECT A1_COD, A1_LOJA, A1_NOME, A1_END, A1_CEP, A1_CGC" + CRLF
	cQuery += "     FROM " + retsqlname('SA1') + CRLF
	cQuery += "    WHERE A1_FILIAL=? AND D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial("SA1") } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP" + CRLF
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_NOMCLI=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODCLI = TMP.A1_COD " + CRLF
	cQuery += "   AND "+retsqlname('VBD')+".VBD_LOJCLI = TMP.A1_LOJA " + CRLF
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0050)	//#"Erro de query na captação dados de clientes - vendas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	// #Finalizado

/*
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0051})	//#"Iniciando captação de dados comuns de custos"
	aBind  := {}
	cQuery := "UPDATE " + retsqlname('VBD') + CRLF
	cQuery += 	" SET VBD_CUSMED = TMP.B2_CM1 " + CRLF
	cQuery += " FROM (" + CRLF
	cQuery += 	" SELECT B2_COD, CAST(B2_CM1 AS decimal(10,2)) B2_CM1 " + CRLF
	cQuery += 	" FROM " + retsqlname('VBF') + " VBF " + CRLF
	cQuery += 	" JOIN " + retsqlname('SB1') + " SB1 ON B1_FILIAL=? AND B1_COD = VBF_PRODUT AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" JOIN " + retsqlname('SB2') + " SB2 ON B2_FILIAL=? AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE VBF_FILIAL=? AND VBF_FLGUSO=? AND VBF.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VBF') } )
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP" + CRLF
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_PRODUT = TMP.B2_COD " + CRLF
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0052)	//#"Erro de query na captação do custo médio."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado
*/

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0057})	//#"Gravando totais no cabecalho de Vendas"
	aBind  := {}
	cQuery := " UPDATE "+retsqlname('VBB') + CRLF
	cQuery += 	" SET VBB_NUMREG = TMP.QTD, " + CRLF
	cQuery += 		" VBB_FILEQU = TMP.SOMA " + CRLF
	cQuery += " FROM ( " + CRLF
//	cQuery += 	" SELECT VBD_CODVBB, COUNT(*) QTD, SUM(VBD_QTDPED) SOMA " + CRLF
	cQuery += 	" SELECT VBD_CODVBB, COUNT(*) QTD, SUM(" + CRLF
	cQuery += 	"    case when VBD_NUMSEQ = 'AJ.EST'" + CRLF
	cQuery += 	"    then VBD_QTDPED * -1" + CRLF
	cQuery += 	"    else VBD_QTDPED" + CRLF
	cQuery += 	" end ) SOMA " + CRLF

	cQuery += 	" FROM "+retsqlname('VBD') + CRLF
	cQuery += 	" WHERE VBD_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VBD') } )
	cQuery += 	" AND VBD_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += 	" AND D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" GROUP BY VBD_CODVBB " + CRLF
	cQuery += " ) TMP " + CRLF
	cQuery += " WHERE "+retsqlname('VBB')+".VBB_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VBD') } )
	cQuery += "   AND "+retsqlname('VBB')+".VBB_CODIGO=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBB')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0048)	//#"Erro de query nas somas de cabeçalho."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	//#Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0058})	//#"Iniciando captação de dados de subcanal de clientes"
	aBind  := {}
	cQuery := " UPDATE " + retsqlname('VBD') + CRLF
	cQuery += 	" SET VBD_SUBCAN = VCF_SUBCAN " + CRLF
	cQuery += " FROM (" + CRLF
	cQuery += 	" SELECT VCF_FILIAL, VCF_CODCLI, VCF_LOJCLI, VCF_SUBCAN " + CRLF
	cQuery += 	" FROM " + retsqlname('VCF') + CRLF
	cQuery += 	" WHERE VCF_FILIAL=? AND D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VCF') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP" + CRLF
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODCLI = TMP.VCF_CODCLI " + CRLF
	cQuery += "   AND "+retsqlname('VBD')+".VBD_LOJCLI = TMP.VCF_LOJCLI " + CRLF
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CANALV <> ? " + CRLF
	aAdd( aBind, { 'C', oCanalVenda:CanalServicos() } )
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0050)	//#"Erro de query na captação de dados de clientes das vendas."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	// #Finalizado

	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0060})	// #"Iniciando captação de dados de canal de recompras"
	aBind  := {}
	cQuery := " UPDATE " + retsqlname('VBD') + CRLF
	cQuery += 	" SET VBD_CANALV=?" + CRLF
	aAdd( aBind, { 'C', oCanalVenda:CanalRecompra() } )
	cQuery += " FROM (" + CRLF
	cQuery += 	" SELECT VCF_CODCLI, VCF_LOJCLI " + CRLF
	cQuery += 	" FROM " + retsqlname('VCF') + " VCF " + CRLF
	cQuery += 	" JOIN " + retsqlname('SA1') + " SA1 ON A1_FILIAL=? AND A1_COD = VCF_CODCLI AND A1_LOJA = VCF_LOJCLI and SA1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SA1') } )
	aAdd( aBind, { 'C', ' ' } )
	cQuery += 	" WHERE VCF_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VCF') } )
	cQuery += 	" AND A1_COD  =?" + CRLF // codigo cliente recompra
	aAdd( aBind, { 'C', oConf:cCodCliRecomp } )
	cQuery += 	" AND A1_LOJA =?" + CRLF // loja cliente recompra
	aAdd( aBind, { 'C', oConf:cLojCliRecomp } )
	cQuery += 	" AND VCF.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cQuery += " ) TMP" + CRLF
	cQuery += " WHERE "+retsqlname('VBD')+".VBD_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODVBB=?" + CRLF
	aAdd( aBind, { 'C', cCodVBB } )
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CODCLI = TMP.VCF_CODCLI " + CRLF
	cQuery += "   AND "+retsqlname('VBD')+".VBD_LOJCLI = TMP.VCF_LOJCLI " + CRLF
	cQuery += "   AND "+retsqlname('VBD')+".VBD_CANALV <> ?" + CRLF
	aAdd( aBind, { 'C', oCanalVenda:CanalServicos() } )
	cQuery += "   AND "+retsqlname('VBD')+".D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )

	OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0059)	//#"Erro de query na captação de canal de recompra."
	oLogger:Log({"TIMESTAMP","  |>   |> "+STR0020})	// #Finalizado
return nil


/*/{Protheus.doc} OFCNHA0112_GeraDados
	Gera os dados para o arquivo
	@type function
	@author Vinicius Gati
	@since 01/03/2018
/*/
function OFCNHA0112_GeraDados(cFilPrc, cArm, dDtVen1, dDtVen2, lEst, dDtEst, cTipoGer, lVda, cDtDe, cDtAte, cDtEst, cNumProgr)
local   cFilAtu := cFilAnt
local   aBind
local   nI
private aGrupos  := { "NAOTRAZERNADA" }
private aProdMov := {}

	cFilAnt := cFilPrc
	oConf:getConfig( cFilPrc )

	for nI := 1 to len( oConf:oConfig["LOCAIS"] )
		if oConf:oConfig["LOCAIS"][nI]["WAREHOUSE"] == cArm
			aAdd( aGrupos, alltrim(oConf:oConfig["LOCAIS"][nI]["GRUPO"]) )
		endif
	next

	oLogger:Log({"TIMESTAMP",STR0082 + cArm})		// #"GeraDados Armazém: "

	cNumProgr := right( "0000000" + iif( Empty(cNumProgr), oConf:NextNum(), cNumProgr ), 7 )

	if cArm == "F01"		// limpando cache de gerações passadas
		aBind  := {}
		cQuery := " UPDATE "+retsqlname('VBF')+" SET VBF_FLGARQ=? WHERE VBF_FILIAL=? AND D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', 'N' } )
		aAdd( aBind, { 'C', xFilial('VBF') } )
		aAdd( aBind, { 'C', ' ' } )
		OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0073)		//#Limpeza de cache

		aBind := {}
		oLogger:Log({"TIMESTAMP",STR0018})		// #"Coletando peças movimentadas para estoque"
		cQuery := " UPDATE "+retsqlname('VBF') + CRLF
		cQuery += " SET VBF_FLGARQ = ?" + CRLF
		aAdd( aBind, {'C','S'} )
		cQuery += " WHERE VBF_PRODUT IN (" + CRLF
		cQuery += 	" SELECT B1_COD" + CRLF
		cQuery += 	" FROM " + oSqlHlp:Nolock('SB1') + CRLF
		cQuery += 	" JOIN " + oSqlHlp:Nolock('NNR') + CRLF
		cQuery += 		" on  NNR_FILIAL = ?" + CRLF
		aAdd( aBind, {'C',xFilial("NNR")})
		cQuery +=		" and NNR_CODIGO = B1_LOCPAD" + CRLF
		cQuery +=		" and NNR.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, {'C', ' '})
		cQuery += 	" where B1_FILIAL = ?" + CRLF
		aAdd( aBind, {'C',xFilial("SB1")})
		cQuery +=		" and B1_GRUPO in (?)" + CRLF
		aAdd( aBind, {'A',aGrupos})
		cQuery +=		" and NNR_VDADMS = ?" + CRLF
		aAdd( aBind, {'C', '1'})
		cQuery += 		" and SB1.D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, {'C', ' '})
		cQuery += " )" + CRLF
		cQuery += " AND VBF_FLGUSO = ?" + CRLF
		aAdd( aBind, {'C','1'})
		cQuery += " AND D_E_L_E_T_ = ?" + CRLF
		aAdd( aBind, {'C',' '})

		OFCNHA015C_ExecQuery( @cQuery, aBind, , STR0019)
		oLogger:Log({"TIMESTAMP",STR0020})	// # "Finalizado"
	endif

	if lVda
		oLogger:Log({"TIMESTAMP",STR0063})	//#"Gerando dados de vendas"
		OFCNHA0104_GeraVendas(cArm, cTipoGer, dDtVen1, dDtVen2, cNumProgr, cDtDe, cDtAte)
	endif

	if lEst
		oLogger:Log({"TIMESTAMP",STR0062})	// #"Gerando dados de estoque"
		OFCNHA0102_GeraEstoque(cArm, cTipoGer, dDtEst, cNumProgr, cDtEst)
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
	aRet[1] := iif( aRet[1] < 0, 0, aRet[1] )				// saldo atual
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
local   cVldLj  := JD06ResFases("' ', 'C', 'X'")
local   nI
local   aGrupo := {"NAOTRAZERNADA"}
local   aBind   := {}

	for nI := 1 to len( oConf:oConfig["LOCAIS"] )
		if oConf:oConfig["LOCAIS"][nI]["WAREHOUSE"] == cArm
			aAdd( aGrupo, alltrim(oConf:oConfig["LOCAIS"][nI]["GRUPO"]) )
		endif
	next

	cSQL := "SELECT VE6.B1_COD, SUM(CASE OPERACAO WHEN 'BAL' THEN SOMA ELSE ? END) SOMA_BAL," + CRLF
	aAdd( aBind, { 'N', 0 } )
	cSQL += 	" SUM(CASE OPERACAO WHEN 'OFI' THEN SOMA ELSE ? END) SOMA_OFI" + CRLF
	aAdd( aBind, { 'N', 0 } )
	cSQL += " FROM ( " + CRLF
	cSQL += 	" SELECT OPERACAO, VS1_STATUS, B1_COD, SUM(CONTA) SOMA" + CRLF
	cSQL += 	" FROM ( " + CRLF

	// Orçamento balcão
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2" + CRLF
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL=? AND B1_CODFAB = VB2_CODITE AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" AND VS1_TIPORC=? AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?) " + CRLF  // só X não entra // tratamento do loja
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD " + CRLF

	// Orçamento oficina 
	cSQL += 		" UNION ALL  " + CRLF
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'OFI' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA" + CRLF // quando oficina é necessário usar a conta
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2" + CRLF
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL=? AND B1_CODFAB = VB2_CODITE  AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" AND VS1_TIPORC=? AND VS1_NUMOSV=?" + CRLF // requisicao nao entra aqui vai ser query separada, esta abaixo "
	aAdd( aBind, { 'C', '2' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)" + CRLF  // só X não entra // tratamento do loja
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD " + CRLF

	// Pedido
	cSQL += 		" UNION ALL  " + CRLF
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2" + CRLF
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL =? AND B1_CODFAB = VB2_CODITE AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=? AND VS1.VS1_PEDSTA IN (?)" + CRLF
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'A', {'0','1'} } )
	cSQL += 		" AND VS1_TIPORC=? AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)" + CRLF  // só X não entra // tratamento do loja
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD " + CRLF

	// Reserva de OS sem orçamento (não requisição)
	cSQL += 		" UNION ALL " + CRLF
	cSQL += 		" SELECT ? VS1_STATUS, B1_COD, 'OFI' OPERACAO, SUM ( CASE WHEN VB3.VB3_TIPREQ <> ? THEN VB3.VB3_QUANT ELSE VB3.VB3_QUANT * -1 END ) AS CONTA" + CRLF // quando oficina é necessário usar a conta
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" FROM "+retSqlName('VB3')+ " VB3, "+retSqlName('SB1')+ " SB1" + CRLF
	cSQL +=		 	" WHERE VB3.VB3_FILIAL=? AND SB1.B1_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VB3') } )
	aAdd( aBind, { 'C', xFilial('SB1') } )
	cSQL +=		 	" AND VB3.VB3_CODITE = B1_CODFAB  AND VB3.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL +=		 	" AND SB1.D_E_L_E_T_=?" + CRLF // preenchido os
	aAdd( aBind, { 'C', ' ' } )
	cSQL +=		 	" GROUP BY B1_COD " + CRLF

	// Reservas de transferências
	cSQL += 		" UNION ALL  " + CRLF
	cSQL += 		" SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ? THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" FROM "+retSqlName('VB2')+" VB2" + CRLF
	cSQL += 		" JOIN "+retSqlName('SB1')+" SB1 ON SB1.B1_FILIAL =? AND B1_CODFAB = VB2_CODITE  AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" JOIN "+retSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 		" AND VS1_TIPORC=? AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)" + CRLF  // só X não entra // tratamento do loja
	aAdd( aBind, { 'C', '3' } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldLj } )
	cSQL += 		" GROUP BY VS1_STATUS, B1_COD" + CRLF

	// coleta requisicoes
	cSQL += 		" UNION ALL " + CRLF
	cSQL += 		" SELECT '0' VS1_STATUS, B1_COD, 'OFI', SUM(SALDO) AS CONTA" + CRLF
	cSQL += 		" FROM (" + CRLF
	cSQL += 			" SELECT B1_COD, VO2_NUMOSV, SUM(CASE WHEN VO2_DEVOLU=? THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) SALDO" + CRLF
	aAdd( aBind, { 'C', '1' } )
	cSQL += 			" FROM "+retSqlName('VO3')+" VO3" + CRLF
	cSQL += 			" JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL =? AND F4_CODIGO = VO3_CODTES AND F4_ESTOQUE=? AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 			" JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=? AND VO2_NOSNUM = VO3_NOSNUM AND VO2_TIPREQ=? AND VO2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VO2') } )
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 			" JOIN "+retSqlName('SB1')+" SB1 ON B1_FILIAL =? AND B1_CODFAB = VO3_CODITE AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 			" WHERE VO3.VO3_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VO3') } )
	cSQL += 			" AND VO3.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 			" AND VO3_DATFEC=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 			" AND VO3_DATCAN=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 			" GROUP BY B1_COD, VO2_NUMOSV" + CRLF
	cSQL += 		" ) TB" + CRLF
	cSQL += 		" GROUP BY B1_COD" + CRLF
	cSQL += 	" ) UNIONS_RESORC " + CRLF
	cSQL += 	" WHERE VS1_STATUS IN (?)" + CRLF
	aAdd( aBind, { 'U', cVldsts } )
	cSQL += 	" GROUP BY OPERACAO, VS1_STATUS, B1_COD" + CRLF
	cSQL += "  ) VE6   " + CRLF

//	if cArm != "F01"	// Armazém Não Gerenciado
		cSQL += " JOIN " + retSqlName('SB1') + " SB1" + CRLF
		cSQL += " ON  SB1.B1_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SB1') } )
		cSQL += " AND SB1.B1_GRUPO in (?)" + CRLF
		aAdd( aBind, { 'A', aGrupo } )
		cSQL += " AND SB1.B1_COD = VE6.B1_COD" + CRLF
		cSQL += " AND SB1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
//	else
//		cSQL   += " JOIN " + retSqlName('VBF') + " VBF" + CRLF
//		cSQL   += " ON VE6.B1_COD = VBF_PRODUT" + CRLF
//		cSQL   += " AND VBF_FILIAL=?" + CRLF
//		aAdd( aBind, { 'C', xFilial('VBF') } )
//		cSQL   += " AND VBF_FLGUSO=?" + CRLF
//		aAdd( aBind, { 'C', '1' } )
//		cSQL   += " AND VBF_FLGARQ=?" + CRLF
//		aAdd( aBind, { 'C', 'S' } )
//		cSQL   += " AND VBF.D_E_L_E_T_=?" + CRLF
//		aAdd( aBind, { 'C', ' ' } )
//	endif
	cSQL += " GROUP BY VE6.B1_COD " + CRLF
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
	cSQL := "SELECT distinct VE6.* FROM  (" + CRLF
	cSQL += " SELECT D2_PRCVEN, SUM(D2_QUANT) D2_QUANT,D2_ITEM,VOO_NUMOSV,VO1_DATABE,VOI_SITTPO,D2_CLIENTE,D2_LOJA,VOO_NUMNFI,VOO_SERNFI,D2_EMISSAO,D2_COD,VO1_CHASSI,"
	cSQL += " D2_DOC, D2_SERIE, D2_CUSTO1,"
	cSql += " VV1_MODVEI,VO1_KILOME,VO1_CODMAR,VO1_MOTCOM,D2_NUMSEQ,OPERACAO,D2_GRUPO,SUM(D2_QUANT) VO3_QTDREQ,VS3_CODSIT,VS1_TIPTEM,VO3_NOSNUM,F4_OPEMOV, VOO_INDPRE" + CRLF
	cSQL += " FROM ( " + CRLF
	cSQL += " SELECT " + CRLF
	cSQL += " VS3_VALPEC D2_PRCVEN, " + CRLF
	cSQL += " SUM(CASE " + CRLF
	cSQL += " 	WHEN VB2.VB2_TIPREQ <> ?" + CRLF
	cSQL += " 	THEN VS3.VS3_QTDITE " + CRLF
	cSQL += " 	ELSE VS3.VS3_QTDITE * ? " + CRLF
	cSQL += " 	END) D2_QUANT, " + CRLF
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'N', -1 } )
	cSQL += " VS3_SEQUEN D2_ITEM, " + CRLF
	cSQL += " VS1_NUMORC VOO_NUMOSV, " + CRLF
	cSQL += " VS1_DATORC VO1_DATABE, " + CRLF
	cSQL += " VOI_SITTPO, " + CRLF
	cSQL += " VS1_CLIFAT D2_CLIENTE, " + CRLF
	cSQL += " VS1_LOJA D2_LOJA, " + CRLF
	cSQL += " VS1_NUMNFI VOO_NUMNFI, " + CRLF
	cSQL += " VS1_SERNFI VOO_SERNFI, " + CRLF
	cSQL += " F2_EMISSAO D2_EMISSAO, " + CRLF
	cSQL += " VS3_CODITE D2_COD, " + CRLF
	cSQL += " VV1_CHASSI VO1_CHASSI, " + CRLF
	cSQL += " F2_DOC D2_DOC," + CRLF
	cSQL += " F2_SERIE D2_SERIE," + CRLF
	cSQL += " B2_CM1 D2_CUSTO1," + CRLF
	cSQL += " VV1_MODVEI, " + CRLF
	cSQL += " '' VO1_KILOME, " + CRLF
	cSQL += " '' VO1_CODMAR, " + CRLF
	cSQL += " '' VO1_MOTCOM, " + CRLF
	cSQL += " '' D2_NUMSEQ, " + CRLF
	cSQL += " CASE" + CRLF
	cSQL += 	" WHEN VS1_TIPORC=? THEN 'BAL'" + CRLF
	aAdd( aBind, { 'C', '1' } )
	cSQL += 	" WHEN VS1_TIPORC=? THEN 'OFI'" + CRLF
	aAdd( aBind, { 'C', '2' } )
	cSQL += 	" WHEN VS1_TIPORC=? THEN 'BAL'" + CRLF
	aAdd( aBind, { 'C', '3' } )
	cSQL += 	" WHEN VS1_TIPORC=? THEN 'BAL'" + CRLF
	aAdd( aBind, { 'C', 'P' } )
	cSQL += " END OPERACAO," + CRLF
	cSQL += " B1_GRUPO D2_GRUPO," + CRLF
	cSQL += " VS3_CODSIT, " + CRLF
	cSQL += " VS1_TIPTEM," + CRLF

	cSQL += " VB2_DOCSDB VO3_NOSNUM," + CRLF

	cSQL += " F4_OPEMOV," + CRLF
	cSQL += " VS1_INDPRE VOO_INDPRE" + CRLF
	cSQL += " FROM "+retSqlName('VB2')+" VB2 " + CRLF
	cSQL += " JOIN "+retSqlName('SB1')+" SB1 ON B1_FILIAL=? AND B1_CODFAB = VB2_CODITE AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VS1')+" VS1 ON VS1_FILIAL=? AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT = VS1_CHAINT AND VV1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VV1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('SF2')+" SF2 ON F2_FILIAL=? AND F2_DOC = VS1_NUMNFI AND F2_SERIE = VS1_SERNFI AND SF2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VS3')+" VS3 ON VS3_FILIAL=? AND VS3_NUMORC = VB2_NUMORC AND VS3_CODITE = VB2_CODITE AND VS3.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VS3') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = VS3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SB2')+" SB2 ON B2_FILIAL=? AND B2_COD = B1_COD AND B2_LOCAL = VS3_LOCAL AND SB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VS1_TIPTEM = VOI_TIPTEM AND VOI.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VOI') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " WHERE VB2.VB2_FILIAL=? AND VB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " AND (CASE WHEN VS1_NUMNFI=? THEN ? ELSE VS1_STATUS END ) IN (?)" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'U', cVldsts } )
	cSQL += " and ( VS1_TIPORC <> ? or ( VS1_TIPORC = ? and VS1_PEDSTA in (?) ) )" + CRLF
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'C', 'P' } )
	aAdd( aBind, { 'A', {'0','1'} } )

	CSQL += " GROUP BY VS3_VALPEC,VS3_SEQUEN,VS1_NUMORC,VS1_DATORC,VOI_SITTPO,VS1_CLIFAT,VS1_LOJA,VS1_NUMNFI,VS1_SERNFI,F2_EMISSAO, F2_DOC, F2_SERIE,"
	cSql += "VS3_CODITE,VV1_CHASSI,VV1_MODVEI,VS1_TIPORC,VS1_NUMOSV,VS1_PEDSTA,B1_GRUPO,VS3_CODSIT,VS1_TIPTEM,F4_OPEMOV,VB2_DOCSDB,VS1_INDPRE,B2_CM1" + CRLF

	cSQL += " UNION ALL " + CRLF

	// coleta requisicoes PEÇAS - Oficina
	CSQL += " SELECT " + CRLF
	cSQL += " AVG(VO3_VALPEC), " + CRLF
	cSQL += " SUM(CASE " + CRLF
	cSQL += 	" WHEN VO2_DEVOLU=?" + CRLF
	cSQL += 	" THEN VO3_QTDREQ " + CRLF
	cSQL += 	" ELSE VO3_QTDREQ * ?" + CRLF
	cSQL += 	" END) QUANT, " + CRLF
	aAdd( aBind, { 'C', '1' } )
	aAdd( aBind, { 'N', -1 } )
	cSQL += " VSJ_SEQINC ITEM, " + CRLF
	cSQL += " VO1_NUMOSV, " + CRLF
	cSQL += " VO1_DATABE, " + CRLF
	cSQL += " VOI_SITTPO, " + CRLF
	cSQL += " VO3_FATPAR, " + CRLF
	cSQL += " VO3_LOJA, " + CRLF
	cSQL += " '' DOC, " + CRLF
	cSQL += " '' SERIE, " + CRLF
	cSQL += " '' EMISSAO, " + CRLF
	cSQL += " VO3_CODITE PRODUTO, " + CRLF
	cSQL += " VO1_CHASSI, " + CRLF
	cSQL += " VO3_NUMNFI D2_DOC, " + CRLF
	cSQL += " VO3_SERNFI D2_SERIE," + CRLF
	cSQL += " B2_CM1 D2_CUSTO1," + CRLF
	cSQL += " VV1_MODVEI, " + CRLF
	cSQL += " VO1_KILOME, " + CRLF
	cSQL += " VO1_CODMAR, " + CRLF
	cSQL += " VO1_MOTCOM, " + CRLF
	cSQL += " '' NUMSEQ, " + CRLF
	cSQL += " 'OFI' OPERACAO, " + CRLF
	cSQL += " B1_GRUPO D2_GRUPO, " + CRLF
	cSQL += " VSJ_CODSIT VS3_CODSIT, " + CRLF
	cSQL += " VO3_TIPTEM," + CRLF
	cSQL += " (" + CRLF
	cSQL += 	" select max(s.VO3_NOSNUM)" + CRLF
	cSQL += 	" from "+retSqlName("VO3")+" s " + CRLF
	cSQL += 	" where s.VO3_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VO3') } )
	cSQL += 	" and   s.VO3_NUMOSV=VO1_NUMOSV" + CRLF
	cSQL += 	" and   s.VO3_CODITE=VO3.VO3_CODITE" + CRLF
	cSQL += 	" and   s.VO3_DATCAN=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += 	" and   s.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += ") NOSNUM,F4_OPEMOV, '' VOO_INDPRE" + CRLF

	cSQL += " FROM "+retSqlName('VO3')+" VO3 " + CRLF
	cSQL += " JOIN "+retSqlName('SF4')+" SF4 ON F4_FILIAL=? AND F4_CODIGO = VO3_CODTES AND F4_ESTOQUE=? AND SF4.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SF4') } )
	aAdd( aBind, { 'C', 'S' } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VOI')+" VOI ON VOI_FILIAL=? AND VOI_TIPTEM = VO3_TIPTEM AND VOI.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VOI') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VO2')+" VO2 ON VO2_FILIAL=? AND VO2_NOSNUM = VO3_NOSNUM AND VO2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VO2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VO1')+" VO1 ON VO1_FILIAL=? AND VO1_NUMOSV = VO3_NUMOSV AND VO1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VO1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('VV1')+" VV1 ON VV1_FILIAL=? AND VV1_CHAINT = VO1_CHAINT AND VV1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VV1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SB1')+" SB1 ON B1_FILIAL=? AND B1_CODFAB = VO3_CODITE AND SB1.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB1') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " JOIN "+retSqlName('SB2')+" SB2 ON B2_FILIAL=? AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('SB2') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " LEFT JOIN "+retSqlName('VSJ')+" VSJ ON VSJ_FILIAL=? AND VSJ_NUMOSV=VO3_NUMOSV AND VSJ_CODITE=VO3_CODITE AND VSJ_TIPTEM = VO3_TIPTEM AND VSJ.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VSJ') } )
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " WHERE VO3.VO3_FILIAL=?" + CRLF
	aAdd( aBind, { 'C', xFilial('VO3') } )
	cSQL += " AND VO3.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " AND VO3_DATFEC=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " AND VO3_DATCAN=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	cSQL += " AND F4_ESTOQUE=?" + CRLF
	aAdd( aBind, { 'C', 'S'} )
	cSQL += " GROUP BY VSJ_SEQINC,VO1_NUMOSV,VO1_DATABE,VOI_SITTPO,VO3_FATPAR,VO3_LOJA,VO3_CODITE,VO1_CHASSI,VV1_MODVEI,VO1_KILOME,VO1_CODMAR,VO1_MOTCOM,B1_GRUPO,VO3_CODSIT, VO3_TIPTEM, F4_OPEMOV, VSJ_CODSIT, VO3_NUMNFI, VO3_SERNFI, B2_CM1" + CRLF
	cSQL += ") TEMP " + CRLF
	cSQL += " group by D2_PRCVEN,D2_ITEM,VOO_NUMOSV,VO1_DATABE,VOI_SITTPO,D2_CLIENTE,D2_LOJA,VOO_NUMNFI,VOO_SERNFI,D2_EMISSAO,D2_COD,VO1_CHASSI,VV1_MODVEI,VO1_KILOME,VO1_CODMAR,VO1_MOTCOM,D2_NUMSEQ,OPERACAO,D2_GRUPO,VS3_CODSIT, VS1_TIPTEM, VO3_NOSNUM,F4_OPEMOV, VOO_INDPRE, D2_DOC, D2_SERIE, D2_CUSTO1 " + CRLF
	cSQL += " HAVING SUM(D2_QUANT) > ?" + CRLF
	aAdd( aBind, { 'N', 0 } )
	cSQL += " ) VE6 " + CRLF

//	if cArm != "F01"	// Armazém Não Gerenciado
		cSQL += " JOIN " + retSqlName('SB1') + " SB1 " + CRLF
		cSQL += " ON  SB1.B1_FILIAL=?" + CRLF
		aAdd( aBind, { 'C', xFilial('SB1') } )
		cSQL += " AND SB1.B1_GRUPO in (?)" + CRLF
		aAdd( aBind, { 'A', aGrupo } )
		cSQL += " AND SB1.B1_COD = VE6.D2_COD" + CRLF
		cSQL += " AND SB1.D_E_L_E_T_=?" + CRLF
		aAdd( aBind, { 'C', ' ' } )
//	else
//		cSQL   += " JOIN " + retSqlName('VBF') + " VBF " + CRLF
//		cSQL   += " ON VE6.D2_COD = VBF_PRODUT" + CRLF
//		cSQL   += " AND VBF_FILIAL=?" + CRLF
//		aAdd( aBind, { 'C', xFilial('VBF') } )
//		cSQL   += " AND VBF_FLGUSO=?" + CRLF
//		aAdd( aBind, { 'C', '1' } )
//		cSQL   += " AND VBF_FLGARQ=?" + CRLF
//		aAdd( aBind, { 'C', 'S' } )
//		cSQL   += " AND VBF.D_E_L_E_T_=?" + CRLF
//		aAdd( aBind, { 'C', ' ' } )
//	endif

	cSQL += " WHERE D2_QUANT > ? " + CRLF
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

	if lDebug
		oLogger:Log( { cQuery } )
	endif

	if lQueryOnly
		xRet := cQuery
	else
		if left( lower( cQuery ), 6 ) == "select"
//			oStatement:OpenAlias( cAlias )
			MPSysOpenQuery( cQuery, cAlias )
			dbSelectArea( cAlias )
			xRet := cAlias

			if lDebug
				oLogger:Log( OFCNHA020C_retornaDados() )
			endif
		else
			if tcSqlExec( cQuery ) < 0
				if lDebug
					cMsgErro += CRLF + TCSQLError()
					oLogger:Log({ "TIMESTAMP", STR0034, cQuery, TCSQLError() } )	//#"Erro em query durante geração, verificar log."
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

	cQuery := "select count(*) QTDCANC" + CRLF
	cQuery += " from "+retSqlName("VBD")+" VBD" + CRLF
	cQuery += " where VBD_FILIAL=?" + CRLF
	aAdd( aBind, { "C", cFilReg } )
	cQuery += " and   VBD_NUMORI=?" + CRLF
	aAdd( aBind, { "C", cNumOri } )
	cQuery += " and   VBD_PRODUT=?" + CRLF
	aAdd( aBind, { "C", cProdut } )
	cQuery += " and   VBD_TIPTEM=?" + CRLF
	aAdd( aBind, { "C", cTipTem } )
	cQuery += " and   VBD_INDCAN=?" + CRLF
	aAdd( aBind, { "C", "Y" } )
	cQuery += " and VBD.D_E_L_E_T_=?" + CRLF
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

	cQuery := "select VCF_CODCNH from "+retSqlName("VCF")+" VCF" + CRLF
	cQuery += " where VCF_FILIAL=?" + CRLF
	aAdd( aBind, { "C", xFilial("VCF") } )
	cQuery += " and   VCF_CODCLI=?" + CRLF
	aAdd( aBind, { "C", cCodCli } )
	cQuery += " and   VCF_LOJCLI=?" + CRLF
	aAdd( aBind, { "C", cLojCli } )
	cQuery += " and   VCF.D_E_L_E_T_=?" + CRLF
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
static function OFCNHA018C_getLinVen( cFil, cProd, cNumOri, cDoc, cSer, cCli, cLoj, nQuant, nDefault, cNumRem )
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

	if nDefault > 0
		return nDefault
	endif

	cQuery := "select VBD_LINVEN from "+retSqlName("VBD")+" VBD " + CRLF
	cQuery += " where VBD_FILIAL = ?" + CRLF
	aAdd( aBind, { "C", cFil } )
	cQuery += " and   VBD_PRODUT = ?" + CRLF
	aAdd( aBind, { "C", cProd } )
	if ! empty( cDoc )
		cQuery += " and   VBD_NUMNFI = ?" + CRLF
		aAdd( aBind, { "C", cDoc } )
		cQuery += " and   VBD_SERORI = ?" + CRLF
		aAdd( aBind, { "C", cSer } )
	endif

	if ! empty( cNumOri )
		cQuery += " and   VBD_NUMORI = ?" + CRLF
		aAdd( aBind, { "C", cNumOri } )
	endif

	cQuery += " and   VBD_CODCLI = ?" + CRLF
	aAdd( aBind, { "C", cCli } )
	cQuery += " and   VBD_LOJCLI = ?" + CRLF
	aAdd( aBind, { "C", cLoj } )
	cQuery += " and   VBD_NUMREM = ?" + CRLF
	aAdd( aBind, { "C", cNumRem } )
	cQuery += " and   VBD.D_E_L_E_T_ = ?" + CRLF
	aAdd( aBind, { "C", " " } )
	cQuery += " order by R_E_C_N_O_ desc" + CRLF
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAlias )

	if ! (cAlias)->( eof() )
		nSeq := (cAlias)->VBD_LINVEN
	endif
	(cAlias)->(dbCloseArea())

	if nSeq == 0
		aBind  := {}
		cQuery := "select max(VBD_LINVEN) MAXLINVEN from "+retSqlName("VBD")+" VBD " + CRLF
		cQuery += " where VBD_FILIAL = ?" + CRLF
		aAdd( aBind, { "C", cFil } )
		if ! empty( cDoc )
			cQuery += " and   VBD_NUMNFI = ?" + CRLF
			aAdd( aBind, { "C", cDoc } )
			cQuery += " and   VBD_SERORI = ?" + CRLF
			aAdd( aBind, { "C", cSer } )
		endif

		if ! empty( cNumOri )
			cQuery += " and   VBD_NUMORI = ?" + CRLF
			aAdd( aBind, { "C", cNumOri } )
		endif

		cQuery += " and   VBD_CODCLI = ?" + CRLF
		aAdd( aBind, { "C", cCli } )
		cQuery += " and   VBD_LOJCLI = ?" + CRLF
		aAdd( aBind, { "C", cLoj } )
		cQuery += " and   VBD.D_E_L_E_T_ = ?" + CRLF
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


/*/{Protheus.doc} OFCNHA019C_produtoMovimentado
Adiciona produto movimentado em lista para verificação posterior na tabela VBC
@type function
@author Cristiam Rossi
@since 23/09/2025
/*/

static function OFCNHA019C_produtoMovimentado( cCodite )
	if aScan( aProdMov, cCodite ) == 0
		aAdd( aProdMov, cCodite )
	endif
return nil


/*/{Protheus.doc} OFCNHA020C_retornaDados
Retorna string do alias
@type function
@author Cristiam Rossi
@since 26/09/2025
/*/
static function OFCNHA020C_retornaDados()
local   aRetorno := {}
local   cAux     := ""
local   nI
local   aStruct  := dbStruct()
local   cSepara  := "+"

	aEval( aStruct, {|item| ;
				nLarg := max( len(item[1]), item[3] ),;
				cSepara += replicate("-",nLarg) + "+",;
				aAdd(Item, nLarg) })

	aAdd( aRetorno, cSepara )

	for nI := 1 to fCount()
		cAux += "|" + padR( fieldName(nI), aStruct[nI,5] )
	next
	aAdd( aRetorno, cAux + "|" )

	aAdd( aRetorno, cSepara )

	if eof()
		cAux := padR( "|" + STR0083, len(cSepara)-1 ) + "|"		// "Não há dados"
		aAdd( aRetorno, cAux )
	else
		while ! eof()
			cAux := ""
			for nI := 1 to fCount()
				cValue := cValToChar( fieldGet(nI) )
				cAux += "|" + padR( cValue, aStruct[nI,5] )
			next
			aAdd( aRetorno, cAux + "|" )
			dbSkip()
		endDo
	endif
	aAdd( aRetorno, cSepara )
	dbGotop()
return aRetorno


/*/{Protheus.doc} OFCNHA021C_retornaSeqOS
Retorna posição do Item, considerando vai e vem de requisições/devoluções
@type function
@author Cristiam Rossi
@since 05/11/2025
/*/
static function OFCNHA021C_retornaSeqOS( cNosNum, cCodIte )
local cAliasAtu := alias()
local cAlias    := getNextAlias()
local cQuery    := ""
local aBind     := {}
local aMemoria  := {}
local nSeq      := 1
local cNumOS    := ""
local nI

	VO3->( dbSetOrder(1) )
	if VO3->( dbSeek( xFilial("VO3") + alltrim(cNosNum), .T. ) )
		cNumOS := VO3->VO3_NUMOSV
	endif

	oLogger:Log({"TIMESTAMP","  |> "+STR0084})	// #"Gerando Sequencia VO3"
	cQuery := "select " + CRLF
	cQuery += " VO3_CODITE," + CRLF
	cQuery += " VO3_QTDREQ," + CRLF
	cQuery += " SUM(" + CRLF
	cQuery += "      case when VO2_DEVOLU=? then VO3_QTDREQ * ?" + CRLF
	aAdd( aBind, { 'C', '0' } )
	aAdd( aBind, { 'N', -1 } )
	cQuery += "      else VO3_QTDREQ" + CRLF
	cQuery += " end) QTDREQ," + CRLF
	cQuery += " VO3_NOSNUM" + CRLF
	cQuery += " from "+retSqlName("VO3")+" VO3 " + CRLF
	cQuery += " join "+retSqlName("VO2")+ " VO2" + CRLF
	cQuery += 		" ON  VO2_FILIAL=VO3_FILIAL" + CRLF
	cQuery += 		" AND VO2_NOSNUM=VO3_NOSNUM" + CRLF
	cQuery += 		" AND VO2_TIPREQ=?" + CRLF
	aAdd( aBind, { 'C', 'P' } )
	cQuery += 		" AND VO2.D_E_L_E_T_=?" + CRLF
	aAdd( aBind, { 'C', ' ' } )

	cQuery += " where VO3_FILIAL = ?" + CRLF
	aAdd( aBind, { "C", xFilial("VO3") } )

	cQuery += " and   VO3_NUMOSV = ?" + CRLF
	aAdd( aBind, { "C", cNumOS } )

	cQuery += " group by VO3_CODITE, VO3_NOSNUM, VO3_QTDREQ" + CRLF
	cQuery += " order by VO3_NOSNUM" + CRLF
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAlias )

	while ! (cAlias)->( eof() )
		nPos := aScan( aMemoria, {|it| it[1] == alltrim((cAlias)->VO3_CODITE) .and. it[3] > 0} )
		if nPos == 0 
			aAdd( aMemoria, {;
				alltrim((cAlias)->VO3_CODITE),;
				(cAlias)->VO3_QTDREQ,;
				(cAlias)->QTDREQ;
			} )
		else
			aMemoria[nPos,3] += (cAlias)->QTDREQ
		endif
		(cAlias)->( dbSkip() )
	endDo
	(cAlias)->(dbCloseArea())

	for nI := 1 to len( aMemoria )
		if aMemoria[nI,1] == alltrim(cCodIte) .and. aMemoria[nI,3] > 0
			nSeq := nI
			exit
		endif
	next

	dbSelectArea( cAliasAtu )
return nSeq
