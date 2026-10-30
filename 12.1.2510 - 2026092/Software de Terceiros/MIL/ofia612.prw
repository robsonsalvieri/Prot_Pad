#include "totvs.ch"
#include "tbiconn.ch"
#include "ofia612.ch"

//-----------------------------------------------------------------------
/*/{Protheus.doc} OFIA612
Rotina Job de geração de arquivo .CSV com as notas fiscais de entrada e saída - JD
@author Cristiam Rossi
@since 25/02/2026
@version 1.0
@type function
/*/
//-----------------------------------------------------------------------
function OFIA612()
local   aPergs      := {}
local   cDtIni
local   cDtFim      := DtoS( date() - 1 )
local   cMsg

	if ! isBlind()
	    aAdd( aPergs, {1, STR0001 , CtoD("")    ,  "", ".T.", "", ".T.", 80,  .T.})		// "Data De"
	    aAdd( aPergs, {1, STR0002, StoD(cDtFim),  "", ".T.", "", ".T.", 80,  .T.})		// "Data Até"
        if paramBox( aPergs, STR0003 )		// "Relação de notas fiscais"
			FWMsgRun(, { || cMsg := OA612001C_Processa( DtoS( MV_PAR01 ), DtoS( MV_PAR02 ) ) }, STR0003, STR0004 )		// "Relação de notas fiscais"		"Favor aguarde, coletando NFs e gerando arquivo"
			fwAlertInfo( cMsg, STR0003 )		// "Relação de notas fiscais"
		endif
	else
		OA612001C_Processa( cDtIni, cDtFim )
    endif
return nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} OA612001C_Processa
Rotina geração de arquivo .CSV com as notas fiscais de entrada e saída - JD
@author Cristiam Rossi
@since 25/02/2026
@version 1.0
@type function
/*/
//-----------------------------------------------------------------------
static function OA612001C_Processa( cDtIni, cDtFim )
local   cAlias
local   cAux        := ""
local   cQuery
local   cIdEnt
local   cLinha
local   cPasta      := "/logsmil/reljdpec"
local   cNomeArq    := cPasta + "/" + STR0030		// "relatorio_notas_"
local   aAux
local   aCFOP
local   aExecucao   := { date(), time() }
local   aSM0data
local   nNFs        := 0
local   nPos
local   oFWriter
local   oJson
local   oLogger
local   oStatement
local   oCIFT       := OFJDCIFT():New()
local   lCIFTenable := oCIFT:_oOkta:oConfig:CIFT()
local   cConteudo   := ""
private cURL

	makeDir(cPasta)

	oCIFT:_cFileType := "SpedFiscalDD"
	oLogger := DMS_Logger():New()
	if empty( cDtIni )
		aAux := oLogger:GetArray("OFIA612", 'JOB_EXEC')
		if len( aAux ) == 0
			cDtIni := DtoS( dDatabase - 1 ) 	// D-1 Entradas e Cancelamentos
		else
			cAux  := aTail( aAux )
			oJson := JsonObject():New()
			oJson:FromJson(cAux)
			cDtIni := DtoS( StoD( oJson["date2"] ) + 1 )	// pega data anterior + 1 dia
			fwFreeObj(oJson)
		endif
		aAux := nil
	endif

	if cDtIni <= cDtFim

		cURL     := alltrim( getNewPar("MV_SPEDURL","http://localhost:8080/sped") )
		aCFOP    := FWGetSX5("13")
		aSM0data := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_NOMECOM", "M0_CGC", "M0_INSC", "M0_CIDCOB" } )
		cIdEnt   := RetIdEnti()				// Ident do TSS

		cNomeArq += transform( DtoS(aExecucao[1]), "@R 9999_99_99") + "_" + strTran( aExecucao[2], ":", "_") + ".csv"

		oFWriter := FWFileWriter():New( cNomeArq, .T. )
		oFWriter:Create()

		cLinha := STR0006+";"		// 01-"NOME REMETENTE"
		cLinha += STR0007+";"		// 02-"CNPJ REMETENTE"
		cLinha += STR0008+";"		// 03-"INSCRICAO ESTADUAL REMETENTE"
		cLinha += STR0009+";"		// 04-"NUMERO DA NOTA/SERIE"
		cLinha += STR0010+";"		// 05-"DATA DE EMISSAO"
		cLinha += STR0011+";"		// 06-"CFOP"
		cLinha += STR0012+";"		// 07-"NATUREZA DA OPERACAO"
		cLinha += STR0013+";"		// 08-"DESCRICAO DOS PRODUTOS/SERVICOS"
		cLinha += STR0014+";"		// 09-"NCM/SH"
		cLinha += STR0015+";"		// 10-"UN."
		cLinha += STR0016+";"		// 11-"QNTD."
		cLinha += STR0017+";"		// 12-"V.UNITARIO"
		cLinha += STR0018+";"		// 13-"VALOR TOTAL"
		cLinha += STR0019+";"		// 14-"PESO BRUTO"
		cLinha += STR0020+";"		// 15-"PESO LIQUIDO"
		cLinha += STR0021+";"		// 16-"COD. PROD"
		cLinha += STR0022+";"		// 17-"NOME DESTINATARIO"
		cLinha += STR0023+";"		// 18-"INSCRICAO DESTINATARIO"
		cLinha += STR0024+";"		// 19-"CNPJ DESTINATARIO"
		cLinha += STR0025+";"		// 20-"MUNICIPIO"
		cLinha += STR0026+";"		// 21-"INFORMACOES COMPLEMENTARES"
		cLinha += STR0027+";"		// 22-"STATUS DA NF"
		oFWriter:Write( cLinha + CRLF )
		cConteudo += cLinha + "\n"

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSelectArea("SD2")
		dbSetOrder(1)
		dbSelectArea("SFT")
		dbSetOrder(1)
		dbSelectArea("SF3")
		dbSetOrder(1)

		cQuery := "select SF3.R_E_C_N_O_ RECSF3, SFT.R_E_C_N_O_ RECSFT, SB1.R_E_C_N_O_ RECSB1, SA1.R_E_C_N_O_ RECSA1, SA2.R_E_C_N_O_ RECSA2 "
		cQuery += " from " + retSqlName("SF3") + " SF3"
		cQuery += " join " + retSqlName("SFT") + " SFT"
		cQuery += 	" on  FT_FILIAL  = F3_FILIAL"
		cQuery += 	" and FT_SERIE   = F3_SERIE"
		cQuery += 	" and FT_NFISCAL = F3_NFISCAL"
		cQuery += 	" and FT_CLIEFOR = F3_CLIEFOR"
		cQuery += 	" and FT_LOJA    = F3_LOJA"
		cQuery += 	" and SFT.D_E_L_E_T_ = ?"
		cQuery += " join " + retSqlName("SB1") + " SB1"
		cQuery += 	" on  B1_FILIAL  = ?"
		cQuery += 	" and B1_COD     = FT_PRODUTO"
		cQuery += 	" and SB1.D_E_L_E_T_ = ?"
		cQuery += " left join " + retSqlName("SA1") + " SA1"
		cQuery += 	" on  A1_FILIAL  = ?"
		cQuery += 	" and A1_COD     = F3_CLIEFOR"
		cQuery += 	" and A1_LOJA    = F3_LOJA"
		cQuery += 	" and SA1.D_E_L_E_T_ = ?"
		cQuery += " left join " + retSqlName("SA2") + " SA2"
		cQuery += 	" on  A2_FILIAL  = ?"
		cQuery += 	" and A2_COD     = F3_CLIEFOR"
		cQuery += 	" and A2_LOJA    = F3_LOJA"
		cQuery += 	" and SA2.D_E_L_E_T_ = ?"
		cQuery += " where F3_FILIAL = ?"
		cQuery += " and   SF3.D_E_L_E_T_ = ?"
		cQuery += " and ( F3_ENTRADA between ? and ?"
		cQuery += "  or   F3_DTCANC  between ? and ? )"
		cQuery += " order by F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, FT_ITEM"

		oStatement := FwExecStatement():new( cQuery )
		oStatement:setString( 01, " " )
		oStatement:setString( 02, xFilial("SB1") )
		oStatement:setString( 03, " " )
		oStatement:setString( 04, xFilial("SA1") )
		oStatement:setString( 05, " " )
		oStatement:setString( 06, xFilial("SA2") )
		oStatement:setString( 07, " " )
		oStatement:setString( 08, xFilial("SF3") )
		oStatement:setString( 09, " " )
		oStatement:setString( 10, cDtIni )
		oStatement:setString( 11, cDtFim )
		oStatement:setString( 12, cDtIni )
		oStatement:setString( 13, cDtFim )

		cQuery := oStatement:getFixQuery()
		cAlias := oStatement:OpenAlias()

		while ! (cAlias)->( eof() )
			SF3->( dbGoto( (cAlias)->RECSF3 ) )
			SFT->( dbGoto( (cAlias)->RECSFT ) )
			SB1->( dbGoto( (cAlias)->RECSB1 ) )

			cInfCompl := getDCompl( SF3->(F3_SERIE+F3_NFISCAL), cIdEnt )

			if ! empty( SF3->F3_CLIENT )
				cLinha := fLimpa( aSM0data[1,2] ) + ";"					// 01-NOME REMETENTE
				cLinha += fLimpa( aSM0data[2,2] ) + ";"					// 02-CNPJ REMETENTE
				cLinha += fLimpa( aSM0data[3,2] ) + ";"					// 03-INSCRICAO ESTADUAL REMETENTE
			else
				SA2->( dbGoto( (cAlias)->RECSA2 ) )
				cLinha := fLimpa( SA2->A2_NOME ) + ";"					// 01-NOME REMETENTE
				cLinha += fLimpa( SA2->A2_CGC ) + ";"					// 02-CNPJ REMETENTE
				cLinha += fLimpa( SA2->A2_INSCR ) + ";"					// 03-INSCRICAO ESTADUAL REMETENTE
			endif

			cLinha += fLimpa( SF3->F3_NFISCAL + SF3->F3_SERIE ) + ";"	// 04-NUMERO NF/SERIE
			cLinha += fLimpa( SF3->F3_EMISSAO ) + ";"					// 05-EMISSAO NF
			cLinha += fLimpa( SFT->FT_CFOP ) + ";"						// 06-CFOP

			nPos := aScan( aCFOP, {|it| it[3] == padR( SFT->FT_CFOP, 6) } )
			cLinha += fLimpa( iif( nPos>0, aCFOP[nPos,4], "" ) ) + ";"	// 07=NATUREZA DA OPERAÇÃO

			cLinha += fLimpa( SB1->B1_DESC ) + ";"								// 08-DESCRIÇÃO PRODUTOS/SERVIÇOS
			cLinha += fLimpa( SFT->FT_POSIPI ) + ";"					// 09-NCM/SH
			cLinha += fLimpa( SB1->B1_TIPO ) + ";"						// 10-UN.
			cLinha += fLimpa( SFT->FT_QUANT ) + ";"						// 11-QUANTIDADE
			cLinha += fLimpa( SFT->FT_PRCUNIT ) + ";"					// 12-VALOR UNITARIO
			cLinha += fLimpa( SFT->FT_TOTAL ) + ";"						// 13-VALOR TOTAL
			cLinha += fLimpa( SB1->B1_PESBRU * SFT->FT_QUANT ) + ";"	// 14-PESO BRUTO
			cLinha += fLimpa( SB1->B1_PESO   * SFT->FT_QUANT ) + ";"	// 15-PESO LIQUIDO
			cLinha += fLimpa( SFT->FT_PRODUTO ) + ";"					// 16-COD PRODUTO

			if ! empty( SF3->F3_CLIENT )
				SA1->( dbGoto( (cAlias)->RECSA1 ) )
				cLinha += fLimpa( SA1->A1_NOME ) + ";"					// 17-NOME DESTINATARIO
				cLinha += fLimpa( SA1->A1_INSCR ) + ";"					// 18-INSCRICAO ESTADUAL DESTINATARIO
				cLinha += fLimpa( SA1->A1_CGC ) + ";"					// 19-CNPJ DESTINATARIO
				cLinha += fLimpa( SA1->A1_MUN ) + ";"					// 20-MUNICIPIO
			else
				cLinha += fLimpa( aSM0data[1,2] ) + ";"					// 17-NOME DESTINATARIO
				cLinha += fLimpa( aSM0data[3,2] ) + ";"					// 18-INSCRICAO ESTADUAL DESTINATARIO
				cLinha += fLimpa( aSM0data[2,2] ) + ";"					// 17-CNPJ DESTINATARIO
				cLinha += fLimpa( aSM0data[4,2] ) + ";"					// 20-MUNICIPIO
			endif

			cLinha += fLimpa( cInfCompl ) + ";"							// 21-INFORMACOES COMPLEMENTARES
			cAux   := iif( empty(SF3->F3_DTCANC), STR0028, STR0029 )	// "Valida"		 "Cancelada"
			cLinha += fLimpa( cAux ) + ";"								// 22-STATUS DA NF
			oFWriter:Write( cLinha + CRLF )
			cConteudo += "\n" + cLinha
			nNFs++

			(cAlias)->( dbSkip() )
		endDo
		(cAlias)->( dbCloseArea() )

		if lCIFTenable
			oCIFT:EnviaMensagem( '{"mensagem": "'+cConteudo+'"}', cNomeArq )
		endif

		cAux := '{"date1": "'+cDtIni+'","date2": "'+cDtFim+'","regs": '+cValToChar( nNFs )+',"file": "'+cNomeArq+'"}'
		oLogger:LogToTable({;
			{'VQL_AGROUP'     , "OFIA612" },;
			{'VQL_TIPO'       , iif( isBlind(), "JOB_EXEC", "MANUAL_EXEC" ) },;
			{'VQL_DATAI'      , aExecucao[1] },;
			{'VQL_HORAI'      , Val(StrTran(left(aExecucao[2], 5), ":", "")) },;
			{'VQL_DATAF'      , date() },;
			{'VQL_HORAF'      , Val(StrTran(Substr(Time(), 1, 5), ":", "")) },;
			{'VQL_DADOS'      , cAux };
		})
		cAux := FGX_JSONform( cAux, .T. )
		FWLogMsg( "INFO",,"OFIA612","OFIA612","","ENDPROCESS",cAux )

		oStatement:destroy()
		oFWriter:close()
		fwFreeObj(oStatement)
		fwFreeObj(oFWriter)
	else
		cAux := STR0005		// "Data Inicial deve ser menor ou igual a data final"
	endif
	fwFreeObj(oCIFT)
	fwFreeObj(oLogger)
	delClassIntF()
return cAux


//-----------------------------------------------------------------------
/*/{Protheus.doc} getDCompl
obtém XML da NF
@type function
@author Cristiam Rossi
@since 25/02/2026
@version 1.0
@param  cSerDoc, character, Série e Documento a ser pesquisado
@param  cIdEnt, character, Entidade no TSS
@return character, XML da DANFE
/*/
//-----------------------------------------------------------------------
static function getDCompl( cSerDoc, cIdEnt )
local   cInfCompl  := ""
local   cXML       := ""
local   cAviso     := ""
local   cErro      := ""
local   oWS
local   oNfe
private oRetNF

	if ! empty( cURL )
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:nDIASPARAEXCLUSAO := 0
		oWS:_URL      := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:oWSNFEID          := NFESBRA_NFES2():New()
		oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()

		aAdd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
		aTail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := cSerDoc

		if oWS:RETORNANOTASNX()
			if Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
				cXML := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[1]:oWSNFE:CXML
				if ! empty( cXML )
					oRetNF    := XmlParser(cXML,"_",@cAviso,@cErro)
					oNfe      := iif( type("oRetNF:_NFEPROC") != "U", WSAdvValue( oRetNF,"_NFEPROC","string",NIL,NIL,NIL,NIL,NIL), oRetNF )
					cInfCompl := iif( type("oRetNF:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT") == "C", oRetNF:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT, "" )
					fwFreeObj(oNfe)
					fwFreeObj(oRetNF)
				endif
			endif
		endif

		fwFreeObj(oWS)
		delClassIntF()
	endif
return cInfCompl


//-----------------------------------------------------------------------
/*/{Protheus.doc} fLimpa
converte para texto, tira espaços e troca ; por ,
@type function
@author  Cristiam Rossi
@since   26/02/2026
@version  12
/*/
//-----------------------------------------------------------------------
static function fLimpa( xValor )
local   cTxtTrat := ""
default xValor   := ""
	cTxtTrat += alltrim( cValToChar( xValor ) )
	cTxtTrat := strTran( cTxtTrat, ";", "," )
	cTxtTrat := strTran( cTxtTrat, '"', "'" )
	cTxtTrat := strTran( cTxtTrat, CRLF, ". " )
	cTxtTrat := strTran( cTxtTrat, chr(13), ". " )
	cTxtTrat := strTran( cTxtTrat, chr(10), "" )
	cTxtTrat := strTran( cTxtTrat, chr(9), " " )
return cTxtTrat


//-----------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Função para definição de parametros na tela de schedule
@type function
@author  Cristiam Rossi
@since   27/02/2026
@version  12
/*/
//-----------------------------------------------------------------------
static function SchedDef()
return { "P", "", "", {}, "", "" }

