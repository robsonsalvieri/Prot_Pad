#Include 'Protheus.ch'
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} retQueryMon
Retorna a query para o job de monitoramento do auto NFS-e.

@param		cSerie	Serie a ser processada pelo job.

@return	cQuery	qury para o monitoramento

@author	Renato nagib
@since		30/01/2014
@version	12
/*/
//-------------------------------------------------------------------
function retQueryMon( cSerie, cModelo )

	local nDias 	:= SuperGetMV( "MV_QTDMON", , 60 ) // Tratamento para performance da query, monitorar apenas 60 dias antes da data-base
	local cQuery	:= ""
	local lSdoc 	:= TamSx3("F3_SERIE")[1] == 14
	local dDatabase	:= Date()
	local dDatafil	:= SToD ("  /  /  ")
	local cSGBD 	:= AllTrim(Upper(TcGetDb()))

	default cSerie	:= ""

	dDatafil := (dDataBase - if( nDias > 60, 60, nDias) )
	If cModelo == "57"
		cPrefixo := "CTE"
	Elseif cModelo == "65"
		cPrefixo := "NFCE"
	Else 
		cPrefixo := "SPED"
	Endif

	//-----------------------------------------------------------------------------
	// Funcao retBancoDados verifica qual Banco de Dados que esta sendo utilizado
	// para realizar a Query corretamente.
	//
	// Obs.: Retornado .T. caso for os bancos de dados abaixo:
	//
	// Bancos: ORACLE, INFORMIX, DB2, CTREESQL, OPENEDGE
	//-----------------------------------------------------------------------------
	cQuery := " SELECT F3_SERIE , F3_NFISCAL "
	if cPrefixo == "NFCE"
		if cSGBD $ "INFORMIX"
			cQuery := "SELECT FIRST 1000 F3_SERIE , F3_NFISCAL "
		elseif !retBancoDados() .and. !(cSGBD == "POSTGRES") 
			cQuery := "SELECT TOP 1000 F3_SERIE , F3_NFISCAL "
		endif
	endif

	cQuery += " FROM "+RetSqlName("SF3")+" "
	cQuery += " WHERE F3_FILIAL = '" + xFilial( "SF3" ) + "' "
	cQuery += " AND (("

	//-----------------------------------------------------------------------------
	// Funcao retBancoDados verifica qual Banco de Dados que esta sendo utilizado
	// para realizar a Query corretamente.
	//
	// Obs.: Retornado .T. caso for os bancos de dados abaixo:
	//
	// Bancos: ORACLE, INFORMIX, DB2, CTREESQL, OPENEDGE
	//-----------------------------------------------------------------------------
	If retBancoDados()
		cQuery += " SUBSTR( F3_CFO, 1, 1 ) >= '5' "
	Else
		cQuery += " SUBSTRING( F3_CFO, 1, 1 ) >= '5' "
	EndIf
	cQuery += " AND F3_ENTRADA >= '" + Dtos(dDatafil) + "' AND "

	//-----------------------------------------------------------------------
	// Como no varejo, possui uma serie diferente cadastrada para cada PDV,
	// podendo haver mais de 20 PDVs por loja, ficaria inviável cadastrar
	// um agendamento no configurador (AUTONFETRANS, MON, CANC) para cada 
	// PDV. Devido á isso, verificamos se o prefixo é NFCe, sendo, ignoramos
	// a série.
	//-----------------------------------------------------------------------	
	if cPrefixo <> "NFCE"
		If lSdoc
			cQuery += " F3_SDOC = '" + SubStr(cSerie,1,3) + "' "
		Else
			cQuery += " F3_SERIE = '" + cSerie + "' "
		EndIf

		cQuery += " AND "
	Endif

	cQuery += "  F3_ESPECIE = '"+cPrefixo+"' AND "

	//---------------------------------------------------------------------
	// NFCe é transmitida pelo PDV, porém o SF3 somente é gerado quando 
	// a venda é processada na Retaguarda, não gravando o campo F3_CODRET.
	//
	// No caso de Nfe, o campo F3_CODRET é preenchido pelo fonte DANFEIII,
	// no momento da transmissão.
	//---------------------------------------------------------------------
	If cPrefixo == "NFCE"
		cQuery += " F3_CODRET IN (' ','T') "
	Else	
		cQuery += " F3_CODRET = 'T' "
	Endif

	cQuery += " AND "

	If retBancoDados() .and. cPrefixo == "NFCE"
		If  cSGBD $ "ORACLE"
			cQuery += " D_E_L_E_T_ = ' '  AND ROWNUM <= 1000 ) "
		ElseIf cSGBD $ "DB2"
			cQuery += " D_E_L_E_T_ = ' '  AND FETCH FIRST <= 1000 ROWS ONLY ) "
		Endif
	Else
		cQuery += " D_E_L_E_T_ = ' ' )"
	Endif

	// Query para nota de entrada
	cQuery += " OR (" 
	If retBancoDados()
		cQuery += " SUBSTR( F3_CFO, 1, 1 ) < '5' "
	Else
		cQuery += " SUBSTRING( F3_CFO, 1, 1 ) < '5' "
	EndIf
	cQuery += " AND F3_FORMUL = 'S' AND F3_ENTRADA >= '" + Dtos(dDatafil) + "' AND F3_SERIE = '" + cSerie + "' AND "
	cQuery += " F3_ESPECIE = '"+cPrefixo+"' AND F3_CODRET = 'T'  AND  D_E_L_E_T_ = ' ' ))"
	cQuery += " ORDER BY F3_SERIE,F3_NFISCAL "
	if cSGBD $ "POSTGRES"
		cQuery += " LIMIT 10000 ;"
	ENDIF


return( cQuery )

//-------------------------------------------------------------------
/*/{Protheus.doc} retDocsMon
Retorna array de documentos para monitoramento

@param		cAlias		Alias da query a ser processada

@aDocs		array com Id de documentos

@author		Renato Nagib
@since		30/11/2012
@version	12
/*/
//-------------------------------------------------------------------
function retDocsMon( cAlias )

	local aDocs		:= {}
	local cId		:= ""
	local cSerie	:= ""
	local nTamSerie := GetSx3Cache("F3_SERIE", "X3_TAMANHO")
	local cNota		:= ""
	local nTamNota	:= GetSx3Cache("F3_NFISCAL", "X3_TAMANHO")

	cSerie := PadR( (cAlias)->F3_SERIE , nTamSerie) 
	cNota := PadR( (cAlias)->F3_NFISCAL , nTamNota )

	cId := cSerie + cNota
	aDocs := { cId }

return aDocs

//-------------------------------------------------------------------
/*/{Protheus.doc} monitoraAutoNFe
processa monitoramento

@param		aProcessa		array com parametros para o monitoramento
			cEmpresa		Empresa para o processamento
			cEmpFilial		filial para o processamento
			cIdEnt			entidade da empresa para o processamento
			cUrl			url do TSS
			cModelo		modelo do documento

@aDocs		array com Id de documentos

@author		Renato Nagib
@since		30/11/2012
@version	12
/*/
//-------------------------------------------------------------------
function monitoraAutoNFe(cLockFile,cProcesso,aProcessa,cEmpresa, cFilEmp, cIdEnt, cUrl, cModelo, xParam)
local lUsaColab  := UsaColaboracao("1")
local nX		 := 0
local lCTe		 := IIf(cModelo=="57",.T.,.F.)
local nTamSerie	 := GetSx3Cache("F3_SERIE", "X3_TAMANHO")
local nTamNota	 := GetSx3Cache("F3_NFISCAL", "X3_TAMANHO")
Local aParametro := {Space(nTamSerie),Space(nTamNota),Space(nTamNota)}

	If lUsaColab

		If len(aProcessa) > 0

			For nX := 1 to len(aProcessa)

				aParametro[01]   := SubStr(aProcessa[nX][1],1,nTamSerie)	//serie

				If nX == 1
					aParametro[02] := SubStr(aProcessa[nX][1],nTamSerie+1,nTamNota)	//nota inicial
				EndIf
				If nX == len(aProcessa)
					aParametro[03] := SubStr(aProcessa[nX][1],nTamSerie+1,nTamNota)	//nota final
				EndIf
		 	Next

			colNfeMonProc( aParametro, 1 , cModelo, lCte )

		EndIf

	Else
		procMonitorDoc(cIdEnt, cUrl, aProcessa, 2, cModelo, (cModelo == "57") , , .F.)
	EndIf

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} procMonitorDoc
Envia os documentos para monitoramento bo TSS

@param		cIdEnt			Entidade do TSS para processamento
			cUrl			endereço do Web Wervice no TSS
			aParam			Parametro para a busca dos docuemtnos no TSS, de acordo com o tipo nTpMonitor
			nTpMonitor		tipo do monitor
			cModelo		modelo do documento
			lCte			indica se o modelo é Cte
			lMsg			habilita exibição de mensagem

@author	Renato Nagib
@since		04/01/2014
@version	12
/*/
//-------------------------------------------------------------------
function procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, cAviso ,lUsaColab)

	local aRetorno			:= {}
	local aLote			:= {}

	local cId				:= ""
	local cSerie 			:= ""
	local cNota			:= ""
	local cProtocolo		:= ""
	local cRetCodNfe		:= ""
	local cMsgRetNfe		:= ""
	local cRecomendacao	:= ""
	local cTempoDeEspera	:= ""

	local lOk				:= .F.
	local lUpd				:= .F.

	local nX				:= 0
	local nY				:= 0
	local nTamF2_DOC		:= tamSX3("F2_DOC")[1]
	local nAmbiente		:= 0
	local nModalidade		:= 0
	local nTempoMedioSef	:= 0
	local nCount			:= 0

	local oLote				:= nil
	local oWs				:= nil
	local lSdoc			:= TamSx3("F2_SERIE")[1] == 14
	local lFisMntNfe    := ExistBlock("FISMNTNFE")
	
	local cTenConsInd		:= ""
	local cObsConsInd		:= ""

	private oRetorno		:= nil

	default cModelo		:= "55"
	default cAviso			:= ""
	default lCte			:= .F.
	default lUsaColab		:= UsaColaboracao("1")

	oWS:= wsNfeSBra():new()
	oWS:cUserToken	:= "TOTVS"
	oWS:cId_ent		:= cIdEnt
	oWS:_url			:= AllTrim(cUrl)+"/NFeSBRA.apw"

	if cModelo == "65"
		if !empty( getNewPar("MV_NFCEURL","") )
			cUrl := padr(getNewPar("MV_NFCEURL","http://"),250)
		endif

		oWS:cModelo   := cModelo
	endif

	//Monitor por Range de notas
	if nTpMonitor == 1

		If lSdoc
			oWS:cIdInicial    := aParam[01]+aParam[02]
			oWS:cIdFinal      := aParam[Len(aParam)]+aParam[03]
		Else
			oWS:cIdInicial    := aParam[01]+aParam[02]
			oWS:cIdFinal      := aParam[01]+aParam[03]
		EndIf

		lOk := oWS:monitorFaixa()

		oRetorno := oWS:oWsMonitorFaixaResult:oWSMonitorNfe

	//monitor por lote de Id
	elseif nTpMonitor == 2

		oWS:oWSLoteDocs:oWSDocsId := nfeSBra_arrayOfDocId():new()

		for nX := 1 to len(aParam)
			aadd(oWS:oWSLoteDocs:oWSDocsId:oWSDocId, nfeSBra_docId():new())
			oWS:oWSLoteDocs:oWSDocsId:oWSDocId[nX]:cId := aParam[nX][1]
		next

		lOk := oWS:monitorDocumentos()

		oRetorno := oWS:oWSMonitorDocumentosResult:oWSMonitorNfe

	//monitor por tempo
	else
		if valType(aParam[01]) == "N"
			oWS:nIntervalo := max((aParam[01]),60)
		else
			oWS:nIntervalo := max(val(aParam[01]),60)
		endIf

		lOk := oWS:monitorTempo()

		oRetorno := oWS:oWsMonitorTempoResult:oWSMonitorNfe
	EndIf

	if lOk

		for nX := 1 to len(oRetorno)

			cId				:= oRetorno[nX]:cId
			cSerie			:= If (lSdoc,substr(oRetorno[nX]:cId, 1, 14),substr(oRetorno[nX]:cId, 1, 3))
			cNota			:= If (lSdoc,padr( substr(oRetorno[nX]:cId, 15 ), nTamF2_DOC ),padr( substr(oRetorno[nX]:cId, 4 ), nTamF2_DOC ))
			cProtocolo		:= oRetorno[nX]:cProtocolo
	 		nAmbiente		:= oRetorno[nX]:nAmbiente
	 		nModalidade		:= oRetorno[nX]:nModalidade
	 		cRecomendacao	:= PadR(oRetorno[nX]:cRecomendacao,250)
	 		cTempoDeEspera	:= oRetorno[nX]:cTempoDeEspera
			nTempoMedioSef	:= oRetorno[nX]:nTempoMedioSef
			cRetCodNfe		:= ""
			cMsgRetNfe		:= ""
			lUpd			:= .F.

			If (oRetorno[nX]:OWSWS01ConsumoIndevido) <> Nil
				cObsConsInd		:= oRetorno[nX]:OWSWS01ConsumoIndevido:COBSERVACAO
				cTenConsInd		:= oRetorno[nX]:OWSWS01ConsumoIndevido:CTENTATIVAS
			Else
				cObsConsInd		:= cTenConsInd	:= ""
			EndIf	

			//obtem dados dos lotes transmitidos para o documento
	  		aLote := {}
	 		if ValAtrib("oRetorno["+cValToChar(nX)+"]:OWSErro:OWSLoteNfe")<>"U"

				oLote := oRetorno[nX]:OWSErro:OWSLoteNfe
				lUpd := .T.

		 		for nY := 1 to len( oLote )
	 				if oLote[nY]:nLote<>0
		 				aadd(aLote,{	oLote[nY]:nLote,;
		 								oLote[nY]:dDataLote,;
		 								oLote[nY]:cHoraLote,;
										oLote[nY]:nReciboSefaz,;
		 								oLote[nY]:cCodEnvLote,;
		 								padr(oLote[nY]:cMsgEnvLote,50),;
		 								oLote[nY]:cCodRetRecibo,;
		 								padr(oLote[nY]:cMsgRetRecibo,50),;
		 								iif(SubStr(cRecomendacao,1,3)$"003-004-009-025","",oLote[nY]:cCodRetNfe),;
		 								oLote[nY]:cMsgRetNfe;
		 							})
						//Ponto de entrada para obter as informações que serão apresentadas no monitor faixa.
						If	lFisMntNfe
							ExecBlock("FISMNTNFE",.f.,.f.,{cId,aLote})
			   			Endif

					EndIf

				Next nY

				cRetCodNfe	:= if( len(aLote) > 0, aTail(aLote)[9], "")
				cMsgRetNfe	:= if( len(aLote) > 0, aTail(aLote)[10], "")

				oLote := nil

			endif

			//dados para atualização da base
			aadd(aRetorno, {	cId,;
								cSerie,;
								cNota,;
								cProtocolo,;
								cRetCodNfe,;
								cMsgRetNfe,;
								nAmbiente,;
								nModalidade,;
								cRecomendacao,;
								cTempoDeEspera,;
								nTempomedioSef,;
								aLote,;
								lUpd,; // Atualiza doc. na tabela ou nao
								.F.,; // retornaNotasNx para registro realizado ou nao
								cTenConsInd,;
								cObsConsInd;
							})

			// Dados retornaNotasNx - aRetorno[nX][17]
			aadd(aTail(aRetorno),;
						{;
							"",;		//Protocolo
							"",;			//XML
							"",;		//DpecProtocolo
							"",;			//DpecXML
							"",;		//hora da autorizacao
							CToD("");	//hora da autorizacao
						})
		next nX

		if len(aRetorno) > 0

			nCount += getXmlNfe(cIdEnt,@aRetorno) // busca inf. compl. via metodo retornaNotasNx

			while nCount > 0 .and. nCount <	 len(aRetorno)
				If nCount > 0 .and. nCount < len(aRetorno)
					monitorUpd(cIdEnt, @aRetorno, lCte) //atualiza a base e retorno
				EndIf
				nCount+= getXmlNfe(cIdEnt,@aRetorno)
			EndDo
			monitorUpd(cIdEnt, aRetorno, lCte,,,,cModelo)

		endif

	else
		cAviso := iif( empty(getWscError(3)),getWscError(1),getWscError(3) )
	endif

	FreeObj( oWs )
	oWs	:= nil

return aRetorno

//Function para atulizar quando vier do totvs colaboção
function colmonitorupd( aRetorno, lCTe, lMDfe, lUsaColab, lICC )
	monitorUpd("000000", aRetorno, lCTe, lMDfe, lUsaColab, lICC)
return

static Function monitorUpd(cIdEnt, aRetorno, lCTe, lMDfe, lUsaColab, lICC, cModelo)

	local cChaveF3			:= ""
	local cChaveFT			:= ""
	local cId				:= ""
	local cSerie			:= ""
	local cNota				:= ""
	local nAmbiente			:= 0
	local cProtocolo		:= ""
	local cCodRetNfe		:= ""
	local cMsgRetNfe		:= ""
	local cXml				:= ""
	local cDpecProtocolo	:= ""
	local cDpecXml			:= ""
	local cHautNfe			:= ""
	Local cTextInut			:= GetNewPar("MV_TXTINUT","")
	Local cFlag				:= ""
	local cRecomendacao		:= ""
	local cEspecieNfe 		:= ""
	Local cCODAnt    		:= ""
	Local cMsgAnt			:= ""
	Local aArea		 		:= {}
	Local lTMSCTe  	 		:= IntTms()
	local dDautNfe	 		:= SToD("  /  /  ")
	Local cSitCTE	 		:= ""
	local lUpd		 		:= .F.
	Local lCTECan	 		:= GetNewPar( "MV_CTECAN", .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
	local lMVGfe	 		:= GetNewPar( "MV_INTGFE", .F. ) // Se tem integração com o GFE
	local nModalidade		:= 0
	local nX		 		:= 0
	Local nRecnoSF1	 		:= 0
	local aArrayDel	 		:= {}
	local cMV_INTTAF 		:= GetNewPar( 'MV_INTTAF', 'N' ) //Verifica se o parâmetro da integração online esta como 'S'
	local lTafKey    		:= SFT->( FieldPos( 'FT_TAFKEY' ) ) > 0
	local lIntegTaf  		:= ( cMV_INTTAF == 'S' .and. lTafKey )
	local lTAFVldAmb 		:= FindFunction( 'TAFVldAmb' ) .And. TAFVldAmb( '1' ) .And. FindFunction( 'DocFisxTAF' ) //Valida se o cliente habilitou a integração nativa Protheus x TAF
	Local lIntegM461 		:= ExistFunc("MATI461EAI") .And. ( FWHasEAI("MATA410B",.T.,,.T.) .Or. FWHasEAI("MATA461",.T.,,.T.) )	//Verifica se o envio da mensagem única DOCUMENTTRACEABILITYORDER ou INVOICE está configurado
    Local lL701VlInt        := ExistFunc("L701VlInt")
	Local cChvAnt  			:= ""
	local lChaveEpec
	Local cPriCTe	 		:= ""
	Local cUltCTe	 		:= ""
	Local cSerCTe	 		:= ""
	local cCliFor	 		:= ""	
	local cLoja 	 		:= ""
	local lSeekSF3			:= .F.
	local lCancNfe          := SuperGetMv("MV_CANCNFE",.F.,.F.)
	local lSpdDanf          := ExistBlock("SPDNFDANF")
	local lSpedGerChv		:= ExistFunc("SpedGerChv")
	local lUpdSF3Chv		:= .F.
	local cNumSF3			:= ""
	local cSerieF3			:= ""
	local nPosAut			:= 0

	Default lCTe		:= .F.
	Default lMDfe		:= .F.
	Default lUsaColab	:= .F.
	Default lICC	 	:= .F.
	default cIdEnt		:= if(lUsaColab, "000000", getCfgEntidade())
	Default cModelo		:= ""

    For nX := 1 To Len(aRetorno)

		//dados do monitor
		cId				:= aRetorno[nX][1]
		cSerie			:= aRetorno[nX][2]
		cNota			:= aRetorno[nX][3]
		cProtocolo		:= aRetorno[nX][4]
		cCodRetNfe		:= aRetorno[nX][5]
		cMsgRetNfe		:= aRetorno[nX][6]
		nAmbiente 		:= aRetorno[nX][7]
		nModalidade		:= aRetorno[nX][8]
		cRecomendacao	:= aRetorno[nX][9]
		lUpd			:= aRetorno[nX][13]
		cXml			:= aTail(aRetorno[nX])[2]
		cDpecProtocolo:= aTail(aRetorno[nX])[3]
		cDpecXml		:= aTail(aRetorno[nX])[4]

		If cModelo == "62" .And. (nPosAut := aScan(aRetorno[nX][12], {|x| x[09] $ "100" } )) > 0
			cHautNfe 		:= aRetorno[nX][12][nPosAut][3]
			dDautNfe		:= aRetorno[nX][12][nPosAut][2]
		Else
			cHautNfe		:= aTail(aRetorno[nX])[5]
			dDautNfe		:= if( !empty(aTail(aRetorno[nX])[6]), aTail(aRetorno[nX])[6], SToD("  /  /  ") )
		EndIf

		cEspecieNfe		:= ""
		cCliFor			:= ""
		cLoja			:= ""
		lSeekSF3		:= .F.

		//Verifica se a chave foi autorizada em contingencia
		lChaveEpec  := !empty(aRetorno[nX][12]) .and. aScan(aRetorno[nX][12], {|x| x[09] $ "136" } ) > 0
		
		nSFTRecno:= SFT->(RECNO())
		nSFTIndex:= SFT->(IndexOrd())

		if lUpd
			aRetorno[nX][13] := .F.
			//-- Atualizar status dos MDF-e (SIGATMS)
			If lMDfe .And. lUsaColab .And. lTMSCTe
				If lICC
					TME73UpdIC(aRetorno)
				Else
					TME73Upd(cNota,cSerie,cCodRetNfe,Substr(cRecomendacao,1,3),cProtocolo,nAmbiente,cRecomendacao,IIF(Empty(cCodRetNfe),"",Substr(cCodRetNfe+" - "+cMsgRetNfe,1,150)),nModalidade)
				EndIf				
				Loop
			EndIf
			SF3->(dbSetOrder(5))
			If SF3->(MsSeek(xFilial("SF3")+ cId,.T.))

				While !SF3->(Eof()) .And. AllTrim(SF3->(F3_SERIE+F3_NFISCAL))== AllTrim(cId)
					nSF3Recno:= SF3->(RECNO())
					nSF3Index:= SF3->(IndexOrd())
					lSeekSF3 := .T.
					If SF3->( (Left(F3_CFO,1)>="5" .Or. (Left(F3_CFO,1)<"5" .And. F3_FORMUL=="S")) .And. FieldPos("F3_CODRSEF")<>0)
						RecLock("SF3")
						cCODAnt:= SF3->F3_CODRSEF
						If SF3->(FieldPos("F3_DESCRET"))> 0
							cMsgAnt:= SF3->F3_DESCRET
						EndIf

						SF3->F3_CODRSEF:= cCodRetNfe
						// -- Para NFC-e não existe o parametro MV_CANCNFE e o campo F3_CODRSEF fica em branco para venda autorizada, por esse motivo caso seja NFC-e e não seja status final o campo F3_CODRSEF não é atualizado.
						If	(cCODAnt == "100" .and. lCancNfe .OR. AllTrim(SF3->F3_ESPECIE) == "NFCE" ) .and. !cCodRetNfe $ "100,101,102,124,136,135,150,151,155"+ RetCodDene() //Adicionados os codigos 150/151 conforme tabela de codigos de resultado de processamento do MOC.
						   SF3->F3_CODRSEF:= cCODAnt
						   cMsgRetNfe:= cMsgAnt
						ENDIF

						// Grava protocolo - chamado TRBOLF(Fiscal)
						If SF3->(FieldPos("F3_PROTOC")) > 0 .and. !Empty(cProtocolo)
							SF3->F3_PROTOC:= cProtocolo
						EndIf
						//SE FOR UMA NOTA DENEGADA, INFORMA NO CAMPO F3_OBSERV
						If cCodRetNfe $ RetCodDene()
							SF3->F3_OBSERV := "NF DENEGADA"
						EndIf
					    //SE FOR INUTILIZAÇÃO ALTERA NOS LIVROS FISCAIS
						If !Empty(cTextInut)
						    If !empty(cMsgRetNfe) .And. (Left(cCodRetNfe,3) == '102')//("Inutilizacao de numero homologado" $ cMsgRetNfe .Or. "Inutilização de número homologado" $ cMsgRetNfe)
								SF3->F3_OBSERV := ALLTRIM(cTextInut)
							EndIf
						EndIF

						If SF3->F3_FORMUL == "S"
							cTipoMov :=	"E"
						Else
							cTipoMov := "S"
						EndIf

						// apenas flaga a SF3 com status monitorada quando possuir retorno da sefaz OU falha no Schema.
						if ( (!empty(cCodRetNfe) .and. cCodRetNfe <> "103") .or. "029" $ cRecomendacao ) .and. SF3->(FieldPos("F3_CODRET"))> 0 .and. SF3->(FieldPos("F3_DESCRET"))> 0
							SF3->F3_CODRET := "M"
							SF3->F3_DESCRET:= cMsgRetNfe
						endif

						//apenas para notas de entradas canceladas formulario proprio "S"
						If !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)<"5" //Alimenta Chave da NFe Cancelada na F3 ao consultar o monitorfaixa
							If !Empty(cXml) .And. !Empty(cProtocolo) .and. cCodRetNfe <> "102" // Inserida verificação do protocolo, antes de gravar a Chave.
								SF3->F3_CHVNFE  := RetChave(cXML)
							EndIf
						EndIf

						/* Cancelamento/Inutilizacao sao enviados apenas se F3_CODRET <> 'T'
							Ajuste abaixo para possibilitar reenvio de inut/canc em caso de rejeicao na SEFAZ
						*/
						If !Empty(SF3->F3_DTCANC) .And. Alltrim(SF3->F3_CODRET) == "T" .And. ("032" $ cRecomendacao .or. "025" $ cRecomendacao)
							SF3->F3_CODRET := ""
						EndIf

						SFT->(dbSetOrder(1))
						SFT->(Dbseek(xFilial("SFT")+cTipoMov+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA))

						While !SFT->(Eof()) .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+cTipoMov+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If !Empty(cTextInut)
						    	If Left(cCodRetNfe,3) == '102'//("Inutilizacao de numero homologado" $ cMsgRetNfe .Or. "Inutilização de número homologado" $ cMsgRetNfe)
									RecLock("SFT")
									SFT->FT_OBSERV := ALLTRIM(cTextInut)
									SFT->(MsUnlock())
								EndIf
							EndIF
							//SE FOR UMA NOTA DENEGADA, INFORMA NO CAMPO FT_OBSERV com a mesma informação da SF3->F3_OBSERV
							If cCodRetNfe $ RetCodDene()
								RecLock("SFT")
								SFT->FT_OBSERV := "NF DENEGADA"
								SFT->(MsUnlock())
							EndIf
							SFT->(dbSkip())
						EndDo
						MsUnlock()

						If Alltrim(SF3->F3_ESPECIE) == "CTE" .And. lTMSCTe
							aArea := GetArea()
							If lUsaColab
								//-- Atualizacao dados CTE - TOTVS Colaboracao 2.0
								DT6->(dbSetOrder(1))
								If	DT6->(MsSeek(xFilial("DT6")+cFilAnt+PadR(SF3->F3_NFISCAL,Len(DT6->DT6_DOC))+SF3->F3_SERIE))
									cSitCTE := DT6->DT6_SITCTE //-- 0=Nao Transmitido;1=Aguardando...;2=Autorizado o uso do Cte.;3=Nao Autorizado;4=Autorizado Contingencia
									If Left(cCodRetNfe,3) == '100'
										cSitCTE := StrZero(2,Len(DT6->DT6_SITCTE))
									ElseIf Left(cCodRetNfe,3) >= '200'
										cSitCTE := StrZero(3,Len(DT6->DT6_SITCTE))
									ElseIf Left(cCodRetNfe,3) == '100' .And. nModalidade == 5
										cSitCTE := StrZero(4,Len(DT6->DT6_SITCTE))
									EndIf
									RecLock("DT6",.F.)
									DT6->DT6_RETCTE := cRecomendacao
									If !Empty(cCodRetNfe)
										DT6->DT6_AMBIEN := Val(SubStr(ColGetPar("MV_AMBCTE","2"),1,1))
										DT6->DT6_SITCTE := cSitCTE
										DT6->DT6_IDRCTE := cCodRetNfe
										DT6->DT6_PROCTE := cProtocolo
										DT6->DT6_CHVCTE := SubStr(NfeIdSPED(cXML,"Id"),4)
									EndIf
									MsUnlock()
								EndIf
							Else
								//-- Atualizacao dados CTE - TSS
								cSerCTe := SF3->F3_SERIE
								If Empty(cPriCTe)
									cPriCTe := SF3->F3_NFISCAL
								EndIf
								cUltCTe := SF3->F3_NFISCAL
							EndIf
							RestArea(aArea)
						Endif

						//-- Exclusao CTE somente apos envio e autorizacao da SEFAZ
						If lCTE .And. lCTECan .And. !Empty(SF3->F3_DTCANC)
							DT6->(dbSetOrder(1))
							If	DT6->(MsSeek(xFilial('DT6')+cFilAnt+PadR(SF3->F3_NFISCAL,Len(DT6->DT6_DOC))+SF3->F3_SERIE)) .And. DT6->DT6_STATUS$"B/D"
								RecLock('DT6',.F.)
								If SF3->F3_CODRSEF == '101'
									DT6->DT6_STATUS := 'C'  //Cancelamento SEFAZ Autorizado
								Else
									DT6->DT6_STATUS := 'D'  //Cancelamento SEFAZ Nao Autorizado
								EndIf
								MsUnLock()

								//Exclui o documento automaticamente caso o parâmetro MV_CTECAN e MV_CANAUTO esteja habilitado, e se for TOTVS Colab 2.0
								If lCTECan .And. SF3->F3_CODRSEF == '101' .And. lUsaColab
									Aadd(aArrayDel , { DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, "", .T., DT6->DT6_SITCTE })
									TMSA200Exc(aArrayDel, DT6->DT6_LOTNFC, .F., .F., )
								EndIf
							EndIf
						EndIf

					EndIf

					If lUsaColab
						If FindFunction ("AvbeGrvCte") .And. AliasInDic("DL5") .And. SF3->F3_CODRSEF == '101'   //Cancelamento
							AvbeGrvCte( cFilAnt, PadR(SF3->F3_NFISCAL,Len(DT6->DT6_DOC)), SF3->F3_SERIE,,,'101',,,)
						ElseIf FindFunction ("AvbeGrvCte") .And. AliasInDic("DL5")
							AvbeGrvCte( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE,DT6->DT6_DATEMI,DT6->DT6_HOREMI,DT6->DT6_IDRCTE,DT6->DT6_DOCTMS, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV)
						EndIf
					EndIf

					SF3->(dbSkip())
				End
				//-- Faz chamada da rotina que exporta para Datasul
				SF3->(dbSetOrder(5))
				If SF3->(MsSeek(xFilial("SF3")+ cId,.T.))
					if FindFunction("TMSAE76")
						TMSAE76()
					endif
				EndIf
				SFT->(DBSETORDER(nSFTIndex))
				SFT->(DBGOTO(nSFTRecno))
				SF3->(DBSETORDER(nSF3Index))
				SF3->(DBGOTO(nSF3Recno))
			Else	
				If lCTe
					aRetorno[nX][9] := "000 - Calculo do CT-e estornado no ERP Protheus"
				EndIf				
			EndIf

			//Nota de saida
			dbSelectArea("SF2")
			dbSetOrder(1)
			If SF2->(MsSeek(xFilial("SF2")+ cNota + cSerie,.T.))
				cEspecieNfe	:= SF2->F2_ESPECIE
				cFlag		:= SF2->F2_FIMP
				cCliFor		:= SF2->F2_CLIENTE
				cLoja		:= SF2->F2_LOJA
				IF lUsacolab .AND. lCancNfe
					IF "005" $ cRecomendacao .OR. "009" $ cRecomendacao
						RecLock("SF2")
							SF2->F2_STATUS := '025' //Legenda do job do faturamento para cancelamento e inutilização: Em processamento
						MsUnlock()
					ELSEIF "026"     $ cRecomendacao
						RecLock("SF2")
							SF2->F2_STATUS := '026'//Legenda do job do faturamento para cancelamento e inutilização: Não autorizado
						MsUnlock()
					ENDIF
				ENDIF
				if  !Empty(cCodRetNfe) .And. cCodRetNfe $ "100,101,102,124,136" .or.;
				 	( lCancNfe .and. ("026" $ cRecomendacao .or. ("001" $ cRecomendacao .and. SF2->F2_STATUS == "026") ) .and.;
					 	!cCodRetNfe $ "100,101,102,124,136,135,150,151,155"+ RetCodDene() ) //Com cancelamento nao autorizada deverá ficar com legenda verde (autorizada)
					/*	Legenda fica verde após consultar a autorização no monitor
						(não somente após consulta chave ou impressão do danfe)
						Alteração feita em 23/09/16
					*/
					cFlag := "S" // Autorizada
				elseIf  !Empty(cCodRetNfe) .And. !cCodRetNfe $ "100,101,102,124,136"+ RetCodDene()
					cFlag := "N" // Não Autorizada
				elseIf !Empty(cCodRetNfe) .And. cCodRetNfe $ RetCodDene()	 					// Atualizar a Leganda para Nf-e denegada
					cFlag := "D" // Denegada
				//else //retirada valição para permitir que cFlag continue como N ao consultar o monitor para uma nota com erro de schema
					//cFlag := "T" // Transmitida
				endIf

				If (SF2->(FieldPos("F2_HAUTNFE"))<>0 .And. SF2->(FieldPos("F2_DAUTNFE"))<>0) .And. (SF2->(FieldPos("F2_CHVNFE"))>0 .And. !Empty(cFlag))
				//If (SF2->(FieldPos("F2_HAUTNFE"))<>0 .And. SF2->(FieldPos("F2_DAUTNFE"))<>0) .And. (Empty(SF2->F2_HAUTNFE) .Or. Empty(SF2->F2_DAUTNFE) .Or. (SF2->(FieldPos("F2_CHVNFE"))>0 .And. Empty(SF2->F2_CHVNFE))) .And. !Empty(cFlag)
					RecLock("SF2")
					SF2->F2_HAUTNFE	:= substr(cHautNfe,1,5)      //Grava a hora de autorização da nota
					SF2->F2_DAUTNFE	:= dDautNfe   //Grava a data de autorização da nota
					SF2->F2_FIMP := cFlag

					If Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := cHautNfe
						MsUnlock()
					EndIf

					MsUnlock()
				EndIf

				If !Empty(cXml) .And. ( !Empty(cProtocolo) .OR. cCodRetNfe $ RetCodDene() )// Inserida verificação do protocolo , antes de gravar a Chave. Para nota denegada deve gravar a chave
					cChvAnt := SF2->F2_CHVNFE

					RecLock("SF2")
					SF2->F2_CHVNFE  := RetChave(cXML)
					MsUnlock()

					if !lSpedGerChv
						If lIntegM461 .And. cChvAnt <> SF2->F2_CHVNFE
							//Chama Integração EAI - INVOICE >= 3.009
							STARTJOB("MATI461EAI", GetEnvServer(),.F., cEmpant,cFilAnt,SF2->F2_DOC, SF2->F2_SERIE)
						Endif

                    	If lL701VlInt .And. cChvAnt <> SF2->F2_CHVNFE .And. L701VlInt(SF2->F2_DOC, SF2->F2_SERIE)
                        	//Chama mensagem única EAI - DOCUMENTTRACEABILITYORDERRETAIL
                        	StartJob("L701aBoEai", GetEnvServer(), .F., cEmpAnt, cFilAnt, SF2->F2_DOC, SF2->F2_SERIE)
                    	Endif
					endif

					// Grava quando a nota for Transferencia entre filiais
					IF !EMPTY (SF2->F2_FORDES)
				       SF1->(dbSetOrder(1))
				    	If SF1->(MsSeek(SF2->F2_FILDEST+SF2->F2_DOC+SF2->f2_SERIE+SF2->F2_FORDES+SF2->F2_LOJADES+SF2->F2_FORMDES))
				    		If EMPTY(SF1->F1_CHVNFE)
					    		RecLock("SF1",.F.)
					    		SF1->F1_CHVNFE := SF2->F2_CHVNFE
					    		MsUnlock()
					    	EndIf
				    	Endif
				    EndiF
				ElseIf !Empty(cXml) .And. Empty(cProtocolo) .And. (nModalidade = 7 .or. lChaveEpec) // Contingencia FD-SA
					RecLock("SF2")
					SF2->F2_CHVNFE  := RetChave(cXML)
					MsUnlock()
				EndIf
				// Atualização dos campos da Tabela GFE
				if FindFunction("GFECHVNFE") .and. lMVGfe  // Integração com o GFE
					if  SF2->F2_TIPO $ "D|B"    // Documento com tipo de devolução ou "Utilizar Fornecedor"
						dbSelectArea("SA2")
						dbSetOrder(1)
						If SA2->(MsSeek(xFilial("SA2")+ SF2->F2_CLIENTE + SF2->F2_LOJA,.T.))
							GFECHVNFE(xFilial("SF2"),SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_TIPO,SA2->A2_CGC,SA2->A2_COD,SA2->A2_LOJA,SF2->F2_CHVNFE,SF2->F2_FIMP, "S")
						EndIf
					else
						dbSelectArea("SA1")
						dbSetOrder(1)
						If SA1->(MsSeek(xFilial("SA1")+ SF2->F2_CLIENTE + SF2->F2_LOJA,.T.))
							GFECHVNFE(xFilial("SF2"),SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_TIPO,SA1->A1_CGC,SA1->A1_COD,SA1->A1_LOJA,SF2->F2_CHVNFE,SF2->F2_FIMP, "S")
						Endif
					endif
				endif

				lUpdSF3Chv := .F.
				cNumSF3 := ""
				cSerieF3 := ""
			  	//Atualizo SF3
				SF3->(dbSetOrder(4))
				cChave := xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE
				If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,.T.))
					Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
						If (Val(SF3->F3_CFO) >= 5000 .Or. SF3->F3_FORMUL=='S')
							RecLock("SF3",.F.)
							If !Empty(cXml) .And. ( !Empty(cProtocolo) .Or. cCodRetNfe $ RetCodDene() )  // Inserida verificação do protocolo, antes de gravar a Chave. Para nota denegada deve gravar a chave.
								If EMPTY(SF3->F3_CHVNFE)
									if !lUpdSF3Chv 
										lUpdSF3Chv := lSpedGerChv .and. SF3->F3_CHVNFE != RetChave(cXML)
										cNumSF3 := SF3->F3_NFISCAL
										cSerieF3 := SF3->F3_SERIE
									endif
									SF3->F3_CHVNFE  := RetChave(cXML)
								EndIf
							EndIf
						EndIf
						MsUnLock()
						SF3->(dbSkip())
				    EndDo
				EndIf
				//Atualizo SF3
				// Grava quando a nota for Transferencia entre filiais
				IF SF1->(!EOF()) .And. !EMPTY (SF2->F2_FORDES)
					SF3->(dbSetOrder(4))
					cChave := SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
					If SF3->(MsSeek(SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.))
						Do While cChave == SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
							RecLock("SF3",.F.)
							If !Empty(cXml).And. ( !Empty(cProtocolo) .Or. cCodRetNfe $ RetCodDene() ) // Inserida verificação do protocolo, antes de gravar a Chave. Para nota denegada deve gravar a chave.
								If EMPTY(SF3->F3_CHVNFE)
									if !lUpdSF3Chv 
										lUpdSF3Chv := lSpedGerChv .and. SF3->F3_CHVNFE != SF2->F2_CHVNFE
										cNumSF3 := SF3->F3_NFISCAL
										cSerieF3 := SF3->F3_SERIE
									endif
									SF3->F3_CHVNFE  := SF2->F2_CHVNFE
								EndIf
							EndIf
							MsUnLock()
					    SF3->(dbSkip())
					    EndDo
					EndIf
				 EndIf
				 
				 if lUpdSF3Chv
					If lIntegM461
						//Chama Integração EAI - INVOICE >= 3.009
						STARTJOB("MATI461EAI", GetEnvServer(),.F., cEmpant,cFilAnt,cNumSF3, cSerieF3)
					Endif

                    If lL701VlInt .And. L701VlInt(cNumSF3, cSerieF3)
                        //Chama mensagem única EAI - DOCUMENTTRACEABILITYORDERRETAIL
                        StartJob("L701aBoEai", GetEnvServer(), .F., cEmpAnt, cFilAnt, cNumSF3, cSerieF3)
                    Endif
				endif

			  	//Atualizo SFT
			  	SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
				If SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))
					Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA ;
					 .And. (Val(SFT->FT_CFOP) >= 5000 .Or. SFT->FT_FORMUL=='S') .And. !SFT->(Eof())
						RecLock("SFT",.F.)
						If !Empty(cXml).And. ( !Empty(cProtocolo) .Or. cCodRetNfe $ RetCodDene() ) // Inserida verificação do protocolo, antes de gravar a Chave.
							if cCodRetNfe <> "102"
								SFT->FT_CHVNFE  := RetChave(cXML)
							endif
						EndIf
						MsUnLock()

						//-----------------------------------------------------------------------------------------
						//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
						//-----------------------------------------------------------------------------------------
						if lIntegTaf .and. !empty( SFT->FT_CHVNFE )
							FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
						endif

						SFT->(dbSkip())
			    	EndDo
				EndIf

			  	//Atualizo SFT
				// Grava quando a nota for Transferencia entre filiais
				IF SF1->(!EOF()) .And. !EMPTY (SF2->F2_FORDES)
				  	SFT->(dbSetOrder(1))
					cChave := SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
					If SFT->(MsSeek(SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
						Do While cChave == SFT->FT_FILIAL+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
							RecLock("SFT",.F.)
							If !Empty(cXml).And. ( !Empty(cProtocolo) .Or. cCodRetNfe $ RetCodDene() ) // Inserida verificação do protocolo, antes de gravar a Chave.
								If EMPTY(SFT->FT_CHVNFE)
									SFT->FT_CHVNFE  := SF2->F2_CHVNFE
								Endif
							EndIf
							MsUnLock()

							//-----------------------------------------------------------------------------------------
							//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
							//-----------------------------------------------------------------------------------------
							if lIntegTaf .and. !empty( SFT->FT_CHVNFE )
								FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
							endif

							SFT->(dbSkip())
				    	EndDo
					EndIf
				EndIf
			ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)>="5" //Alimenta Chave da NFe Cancelada na F3/FT ao consultar o monitorfaixa
				SF3->(dbSetOrder(4))
				cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
				cChaveFT := xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
				SF3->(dbSeek(cChaveF3,.T.))
				While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
					RecLock("SF3",.F.)
					If !Empty(cXml) .And. ( !Empty(cProtocolo) .Or. cCodRetNfe $ RetCodDene()) // Inserida verificação do protocolo, antes de gravar a Chave.
						If !(Left(cCodRetNfe,3) == '102')//("Inutilizacao de numero homologado" $ cMsgRetNfe .Or. "Inutilização de número homologado" $ cMsgRetNfe)
							//Tratamento para o XML do Colaboração que retorna como evento.
							SF3->F3_CHVNFE  := RetChave(cXML)
						EndIf
					EndIf
					SF3->(MsUnLock())
				    SF3->(dbSkip())
			    EndDo

	   			SFT->(dbSetOrder(1))
				SFT->(dbSeek(cChaveFT,.T.))
				While !SFT->(Eof()) .And. xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
					RecLock("SFT",.F.)
					If !Empty(cXml).And. ( !Empty(cProtocolo) .Or. cCodRetNfe $ RetCodDene()) // Inserida verificação do protocolo, antes de gravar a Chave.
						If !(Left(cCodRetNfe,3) == '102')//("Inutilizacao de numero homologado" $ cMsgRetNfe .Or. "Inutilização de número homologado" $ cMsgRetNfe)
							//Tratamento para o XML do Colaboração que retorna como evento.
							SFT->FT_CHVNFE  := RetChave(cXML)
						EndIf
					EndIf
					SFT->(MsUnLock())

					//-----------------------------------------------------------------------------------------
					//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
					//-----------------------------------------------------------------------------------------
					if lIntegTaf .and. !empty( SFT->FT_CHVNFE )
						FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
					endif

					SFT->(dbSkip())
		    	EndDo
			EndIf

			//Nota de entrada
			dbSelectArea("SF1")
			dbSetOrder(1)
			if lSeekSF3 .and. nSF3Recno > 0
				SF3->(dbSetOrder(nSF3Index))
				SF3->(dbGoto(nSF3Recno))
			endif
			If SF1->(MsSeek(xFilial("SF1")+ cNota + cSerie,.T.)) //.And. nLastXml > 0 .And. !Empty(aXml)
				nRecnoSF1 := 0
				While !SF1->(Eof()) .And. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE == xFilial("SF1")+cNota+cSerie
					If SF1->F1_FORMUL == "S"
						//If SF1->(FieldPos("F1_HORA"))<>0 .And. (Empty(SF1->F1_HORA) .OR. Empty(SF1->F1_NFELETR) .Or. Empty(SF1->F1_EMINFE) .Or.Empty(SF1->F1_HORNFE) .Or. Empty(SF1->F1_CODNFE) .Or. (SF1->(FieldPos("F1_CHVNFE"))>0 .And. Empty(SF1->F1_CHVNFE)))
						cEspecieNfe	:= SF1->F1_ESPECIE
						cCliFor		:= SF1->F1_FORNECE
						cLoja		:= SF1->F1_LOJA

						If (SF1->(FieldPos("F1_HAUTNFE")) <> 0 .And. SF1->(FieldPos("F1_DAUTNFE")) <> 0) .And. (Empty(SF1->F1_HAUTNFE) .Or. Empty(SF1->F1_DAUTNFE) .Or. (SF1->(FieldPos("F1_CHVNFE")) > 0 .And. Empty(SF1->F1_CHVNFE)))
							RecLock("SF1")

							SF1->F1_HAUTNFE := substr(cHautNfe, 1, 5 )     //Grava a hora de autorização da nota
							SF1->F1_DAUTNFE	:= dDautNfe	//Grava a data de autorização da nota
							If !Empty(cXml).And. !Empty(cProtocolo) .Or. (!Empty(cXml).And. !Empty(cProtocolo) .And. nModalidade = 7) .or. lChaveEpec // Inserida verificação do protocolo, antes de gravar a Chave. e se está em contigencia FSDA
								If (SF1->F1_FORMUL == "S") // So grava a a chave da nota se for formulerio prorpio igual a SIM
									SF1->F1_CHVNFE  := RetChave(cXML)
								EndIF
							EndIf

							If !Empty(cCodRetNfe) .And. cCodRetNfe $ "100,101,102,124,136"
							/*	Alteração replicada em 13/02/2017 também para entrada
								Legenda fica verde após consultar a autorização no monitor
								(não somente após consulta chave ou impressão do danfe)
							*/
								SF1->F1_FIMP := "S" // Autorizada
							ElseIf !Empty(cCodRetNfe) .And. !cCodRetNfe $ "100,101,102,124,"+RetCodDene() 	 //Se o retorno for uma rejeição, grava o F1_FIMP como N e a legenda fica como Não Autorizada(preto) (124 = Autorização DPEC)
								SF1->F1_FIMP := "N"
							ElseIf !Empty(cCodRetNfe) .And. cCodRetNfe $ RetCodDene()  					// Atualizar a Leganda para Nf-e denegada
								SF1->F1_FIMP := "D"
							EndIf

							If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
								RecLock("SF1")
								SF1->F1_HORA := cHautNfe
								MsUnlock()
							EndIf

							MsUnlock()
							// Atualização dos campos da Tabela GFE
							if FindFunction("GFECHVNFE") .and. lMVGfe  // Integração com o GFE
								if  SF1->F1_TIPO $ "D|B"    // Documento com tipo de devolução ou "Utilizar Fornecedor"
									dbSelectArea("SA1")
									dbSetOrder(1)
									If SA1->(DbSeek(xFilial("SA1")+ SF1->F1_FORNECE + SF1->F1_LOJA))
										GFECHVNFE(xFilial("SF1"),SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_TIPO,SA1->A1_CGC,SA1->A1_COD,SA1->A1_LOJA,SF1->F1_CHVNFE,SF1->F1_FIMP, "E")
									Endif
								else
									dbSelectArea("SA2")
									dbSetOrder(1)
									If SA2->(MsSeek(xFilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA,.T.))
										GFECHVNFE(xFilial("SF1"),SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_TIPO,SA2->A2_CGC,SA2->A2_COD,SA2->A2_LOJA,SF1->F1_CHVNFE,SF1->F1_FIMP, "E")
									endif
								endif
							endif
						EndIf
						nRecnoSF1 := SF1->(Recno())
						//cEspecieNfe	:= SF1->F2_ESPECIE

						if !empty(SF1->F1_CHVNFE)
							AtuSF9(SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_DTDIGIT, SF1->F1_CHVNFE)
						endIf

					Endif
					SF1->(dbSkip())
				EndDo

				If nRecnoSF1 > 0
					SF1->(DbGoTo(nRecnoSF1))
				Else
					SF1->(MsSeek(xFilial("SF1")+ cNota + cSerie,.T.))
				EndIf

				//Atualizo SF3
				SF3->(dbSetOrder(4))
				cChave := xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
				If SF3->(MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.))
					Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
						If (Val(SF3->F3_CFO) >= 5000 .Or. SF3->F3_FORMUL=='S')
							RecLock("SF3",.F.)
							If !Empty(cXml).And. !Empty(cProtocolo) // Inserida verificação do protocolo, antes de gravar a Chave.
								If (SF3->F3_FORMUL == "S") .And. !(Left(cCodRetNfe,3) == '102')//("Inutilizacao de numero homologado" $ cMsgRetNfe .Or. "Inutilização de número homologado" $ cMsgRetNfe)
									SF3->F3_CHVNFE  := RetChave(cXML)
								Endif
							EndIf
						Endif
						MsUnLock()
						SF3->(dbSkip())
				    EndDo
				EndIf

			  	//Atualizo SFT
			  	SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
				If SFT->(MsSeek(xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
					Do While cChave == xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA ;
					  .And. (Val(SFT->FT_CFOP) >= 5000 .Or. SFT->FT_FORMUL=='S') .And. !SFT->(Eof())
						RecLock("SFT",.F.)
						If !Empty(cXml).And. !Empty(cProtocolo) // Inserida verificação do protocolo, antes de gravar a Chave.
							If (SFT->FT_FORMUL == "S") .And. !(Left(cCodRetNfe,3) == '102')//("Inutilizacao de numero homologado" $ cMsgRetNfe .Or. "Inutilização de número homologado" $ cMsgRetNfe)
								SFT->FT_CHVNFE := RetChave(cXML)					
							Endif
						EndIf
						MsUnLock()

						//-----------------------------------------------------------------------------------------
						//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
						//-----------------------------------------------------------------------------------------
						if lIntegTaf .and. !empty( SFT->FT_CHVNFE )
							FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
						endif

						SFT->(dbSkip())
			    	EndDo
				EndIf
			ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)<"5" //Alimenta Chave da NFe Cancelada na F3/FT  ao consultar o monitorfaixa
				SF3->(dbSetOrder(4))
				cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
				cChaveFT := xFilial("SFT")+"E"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
				SF3->(dbSeek(cChaveF3,.T.))
				While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
					RecLock("SF3",.F.)
					If !Empty(cXml) .And. !Empty(cProtocolo) // Inserida verificação do protocolo, antes de gravar a Chave.
						If (SF3->F3_FORMUL == "S") .And. !(Left(cCodRetNfe,3) == '102')
							//Tratamento para o XML do Colaboração que retorna como evento.
							SF3->F3_CHVNFE  := RetChave(cXML)
						EndIf
					EndIf
					SF3->(MsUnLock())
				    SF3->(dbSkip())
			    EndDo

	   			SFT->(dbSetOrder(1))
				SFT->(dbSeek(cChaveFT,.T.))
				While !SFT->(Eof()) .And. xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
					RecLock("SFT",.F.)
					If !Empty(cXml) .And. !Empty(cProtocolo) // Inserida verificação do protocolo, antes de gravar a Chave.
						If (SFT->FT_FORMUL == "S") .And. !(Left(cCodRetNfe,3) == '102')
							//Tratamento para o XML do Colaboração que retorna como evento.
							SFT->FT_CHVNFE  := RetChave(cXML)
						EndIf
					EndIf
					SFT->(MsUnLock())

					//-----------------------------------------------------------------------------------------
					//Quando o cliente utiliza integração com o TAF no retorno do TSS faço o envio do documento
					//-----------------------------------------------------------------------------------------
					if lIntegTaf .and. !empty( SFT->FT_CHVNFE )
						FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
					endif

					SFT->(dbSkip())
		    	EndDo
			EndIf
		endif

		//Ponto de entrada para o cliente customizar impressao automatica da DANFE posicionado por nota.
		If 	AllTrim(Upper(cEspecieNfe)) $ "SPED" .and. !empty(cXml) .and. !empty(cCodRetNfe) .And. !(alltrim(cCodRetNfe) $ "101,102") .and. (!empty(cProtocolo) .or. !empty(cDpecProtocolo)) .and. ( IsInCallStack("SPEDNFe") .or. IsInCallStack("execJobAuto") )
			If lSpdDanf
				ExecBlock("SPDNFDANF",.F.,.F.,{cNota,cSerie,SubStr(NfeIdSPED(cXml,"Id"),4), cIdEnt, cCliFor, cLoja})
			EndIf
		EndIf

    Next nX

If !Empty(cPriCTe) .And. !Empty(cUltCTe) .And. !Empty(cSerCTe) .And. ExistFunc("TMSSpedCte")
	TMSSpedCte(cSerCTe, cPriCTe, cUltCTe) // ATUALIZA OS DADOS DO CTE NA DT6
EndIf

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GetXMLNFE
executa e Retorna dados do metodo retornaNotas

@param cIdEnt			Entidade no TSS
@param aDados			array de retorno do monitorFaixa
@param cModelo			Modelo do docuemento
@param lReprocesso	Reprocesso de documentos nao retornados

@return

@author  Renato Nagib
@since   13/02/2014
@version 12
/*/
//-------------------------------------------------------------------
static Function GetXMLNFE(cIdEnt,aDados)

	Local cURL				:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
	Local cProtocolo		:= ""
	local cDpecProtocolo	:= ""
	local cXml				:= ""
	local cDpecXml			:= ""
	Local cDHRecbto			:= ""
	Local cDtHrRec   		:= ""
	Local cDtHrRec1			:= ""
	Local dDtRecib			:= CToD("")
	Local nX				:= 0
	Local nDtHrRec1			:= 0
	local nCount 			:= 0
	Local oWS

	Private oDHRecbto
	Default aDados 	:= {}

	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:oWSNFEID          := NFESBRA_NFES2():New()
	oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
	oWS:nDIASPARAEXCLUSAO := 0
	oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

	for nX := 1 To Len(aDados)

		if !aDados[nX][14]
			aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
			Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDados[nX][1]
		endif

	Next nX

	If len(oWS:oWSNFEID:oWSNotas:oWSNFESID2) > 0
		if oWS:RETORNANOTASNX()

			If len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0

				for nX := 1 To Len(aDados)

					nPosId := aScan(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5,{|X| alltrim(X:cID) == alltrim(aDados[nX][1])})

					if nPosId > 0

						//Normal
						cProtocolo	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CPROTOCOLO
						cXml		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CXML
						cDHRecbto	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CXMLPROT

						//DPEC
						cDpecXml 		:= ""
						cDpecProtocolo  := ""
						If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:OWSDPEC)=="O"
							cDpecXml		 := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSDPEC:CXML
							cDpecProtocolo	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSDPEC:CPROTOCOLO
						EndIf

						//Tratamento para gravar a hora da transmissao da NFe
						cDtHrRec1 	:= "" // F2_HAUTNFE
						dDtRecib	:= CToD("") // F2_DAUTNFE
						If !Empty(cProtocolo)
							oDHRecbto		:= XmlParser(cDHRecbto,"","","")
							cDtHrRec		:= IIf(ValAtrib("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
							oDHRecbto		:= NIL
							nDtHrRec1		:= RAT("T",cDtHrRec)

							If nDtHrRec1 <> 0
								cDtHrRec1	:=	SubStr(cDtHrRec,nDtHrRec1+1)
								dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
							EndIf

						EndIf

						aTail(aDados[nX])[1] := cProtocolo
						aTail(aDados[nX])[2] := cXml
						aTail(aDados[nX])[3] := cDpecProtocolo
						aTail(aDados[nX])[4] := cDpecXml
						aTail(aDados[nX])[5] := cDtHrRec1
						aTail(aDados[nX])[6] := dDtRecib
						aDados[nX][13] := .T. // Atualiza o Doc. na tabela
						aDados[nX][14] := .T.					
						nCount++

					endif

				Next nX

			EndIf
		Else
			Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		EndIf
	endif

	FreeObj( oWS )
	oWs	:=	nil

Return nCount

//-------------------------------------------------------------------
/*/{Protheus.doc} retDocsTrans
Retorno os documentos a serem transmitidos ao TSS.

@author  Sergio S. Fuziaka
@since   10/02/2014
@version 12
/*/
//-------------------------------------------------------------------
function retDocsTrans( cAlias )

return( { (cAlias)->F3_CLIEFOR, (cAlias)->F3_LOJA, (cAlias)->F3_NFISCAL, (cAlias)->F3_SERIE } )

//-------------------------------------------------------------------
/*/{Protheus.doc} transmiteAutoNFE
Transmite os documentos para o TSS.

@author  Sergio S. Fuziaka
@since   10/02/2014
@version 12
/*/
//-------------------------------------------------------------------
function transmiteAutoNFE( cLockFile, cProcesso, aProcessa, cEmpresa, cFilEmp, cIdEnt, cUrl, cModelo, cSerie )

local cNotaIni		:= ""
local cNotaFim		:= ""
local lOk			:= .F.
local cAmbiente		:= ""
local cModalidade	:= ""
local cVersao		:= ""
local lCte			:= ( cModelo == "57" )
local lEnd			:= .F.
local cError		:= ""
local nX			:= 0
local cAlias		:= "SF1"
local oDoc
local lUsaColab		:= UsaColaboracao("1")

//----------------------------------------------------------
// Limpa o filtro
//----------------------------------------------------------
For nX := 1 To 2
	dbSelectArea(cAlias)
	dbClearFilter()
	RetIndex(cAlias)

	cAlias := "SF2"
Next

//----------------------------------------------------------
// Inicio do processo de transmissao
//----------------------------------------------------------
If Len( aProcessa ) > 0 .And. !Empty( cIdEnt )

	//----------------------------------------------------------
	// TOTVS Colaboracao 2.0
	//----------------------------------------------------------
	If lUsaColab

		oDoc 			:= ColaboracaoDocumentos():new()
		oDoc:cModelo 	:= IIF(lCte,"CTE","NFE")
		oDoc:cTipoMov	:= "1"
		cNotaIni 		:= aProcessa[1][3]
		cNotaFim 		:= aProcessa[Len(aProcessa)][3]
		cAmbiente		:= ColGetPar("MV_AMBIENT","")
		cModalidade	:= ColGetPar("MV_MODALIDAD","")
		cVersao 		:= IIF(lCte,ColGetPar("MV_VERCTE","2.00"),ColGetPar("MV_VERSAO","3.10"))


		cRetorno := SpedNFeTrf("SF2",cSerie,cNotaIni,cNotaFim,cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,lCte,.T.,nil,nil)

	Else
		//----------------------------------------------------------
		// TSS
		//----------------------------------------------------------
		If !Empty( cIdEnt )

			cNotaIni := aProcessa[1][3]
			cNotaFim := aProcessa[Len(aProcessa)][3]

			cAmbiente := getCfgAmbiente(@cError, cIdEnt, cModelo)

			if( !empty(cAmbiente))

				cModalidade := getCfgModalidade(@cError, cIdEnt, cModelo)

				if( !empty(cModalidade) )
					cVersao	:= getCfgVersao(@cError, cIdEnt, cModelo) 

					lOk := !empty(cVersao)

				endif
			endif

			if( lOk )

				cRetorno := SpedNFeTrf("SF2",cSerie,cNotaIni,cNotaFim,cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,lCte,.T.,nil,nil)
				conout(cRetorno)
			else

				if !Empty( cError )
					autoNfeMsg( "Erro no processo de " + getProcName(cProcesso ) + " - " + cError, .T., cEmpresa, cFilEmp, cSerie , cProcesso)
				endif

			endif

		endif

	endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} retQueryCanc
Retorna a query para o job de cancelamento do auto NF-e.

@param		cSerie		Serie informada no Pergunte Schedulle.
			cModelo	Modelo (55 - NFe / 57 - CTe)

@return   	cRetorno	String com os dados da Query (NF a serem canceladas).

@author	Douglas Parreja
@since		30/01/2014
///version	12
/*/
//-------------------------------------------------------------------
function retQueryCanc( cSerie, cModelo , lUsaColab)

Local cData			:= ""
Local cRetorno	 	:= ""
Local lEndFis  	:= GetNewPar("MV_SPEDEND",.F.)
Local cUFEnt   	:= IIF(!lEndFis,SM0->M0_ESTCOB,SM0->M0_ESTENT)
Local nCancExt 	:= GetNewPar("MV_CANCEXT",30)   //-- Cancelamento Extemporâneo
Local dDataCanc	:= Date()
Local lSdoc		:= TamSx3("F3_SERIE")[1] == 14

default lUsaColab	:= UsaColaboracao("1")

default cModelo	:= ""
default cSerie		:= ""

dDataCanc	:= dDataBase-nCancExt
cData		:= Iif(Empty(Dtos(dDataCanc)), Dtos(dDataBase-30), Dtos(dDataCanc))

cRetorno := " SELECT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_ENTRADA,F3_CFO,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_FORMUL,F3_CODRET,F3_CODRSEF "
cRetorno += " FROM "+retSqlname("SF3")+" SF3 "
cRetorno += " WHERE "
cRetorno += " SF3.F3_FILIAL		=  '" + xFilial("SF3")	+ "' AND "
If lSdoc
	cRetorno += " SF3.F3_SDOC		=  '" + SubStr(cSerie,1,3) 	+ "' AND "
Else
	cRetorno += " SF3.F3_SERIE		=  '" + cSerie         	+ "' AND "
EndIf
cRetorno += " SF3.F3_ENTRADA    >= '" + cData	 + "' AND "
cRetorno += " SF3.F3_DTCANC		<> '" + space(8) + "' AND "
cRetorno += " SF3.F3_DTCANC  	>= '" + cData	 + "' AND "
//cRetorno += " SF3.F3_CODRET		<>  'T'		AND " // A letra "T" indica que a NFe ja foi transmitida, e no aguardo do Monitoramento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³/Verifica se tem o campo F3_CODRET                               ³
//³                                                                ³
//³Obs: Caso nao tenha o campo, terá problema de PERFORMANCE devido³
//³a query buscar todos os registros que já foram transmitidos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRetorno += " SF3.F3_ESPECIE	=  '" + Iif(cModelo == "55","SPED","CTE") + "' AND "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se tem o campo F3_CODRSEF                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRet := RetCodDene()
cRetorno += " ((SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S') OR (SubString(SF3.F3_CFO,1,1) >= '5')) AND "
cRetorno += " SF3.F3_CODRSEF NOT IN ( "+ cRet + ",'101','102','151','155','135','578','579','241', '999' " + if( cUFEnt $ "MG|BA","",",'220'") + ") AND "
cRetorno += " SF3.F3_CODRET NOT IN ('T') AND " //Notas Transmitidas ainda não monitoradas
cRetorno += " SF3.D_E_L_E_T_	= ' ' "

Return( cRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} retDocsCan
Funcao gera o array para transmissão do Cancelamento.

@param 		cAliasSF3	Tabela temporária com NFe a serem canceladas

@return   	aNotas		Array com os dados e quantidade de NF a serem canceladas.

@author	Douglas Parreja
@since		05/02/2014
@version	12
/*/
//-------------------------------------------------------------------
Function retDocsCan(cAliasSF3)
Local aNota 	 := {}

If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNota,{|x| x[3]+x[4]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL})==0
	If (AModNot((cAliasSF3)->F3_ESPECIE)$"55,57")
		aadd(aNota,IIF((cAliasSF3)->F3_CFO<"5","0","1"))
		aadd(aNota,Stod((cAliasSF3)->F3_ENTRADA))
		aadd(aNota,(cAliasSF3)->F3_SERIE)
		aadd(aNota,(cAliasSF3)->F3_NFISCAL)
		aadd(aNota,(cAliasSF3)->F3_CLIEFOR)
		aadd(aNota,(cAliasSF3)->F3_LOJA)
		If AModNot((cAliasSF3)->F3_ESPECIE)$"55,57"
			aadd(aNota,AModNot((cAliasSF3)->F3_ESPECIE))
		ElseIf FunName()$"SPEDCTE,TMSA200"
			aadd(aNota,"57")
		Else
			aadd(aNota,"55")
		EndIf
		aadd(aNota, (cAliasSF3)->F3_CODRSEF)
	EndIf
EndIf

Return aNota

//-------------------------------------------------------------------
/*/{Protheus.doc} cancelaAutoNFe
Funcao que transmite NFe ao TSS

@param		aNotas			Array contendo as notas a serem transmitidas
			cEmpresa		Empresa para o processamento
			cEmpFilial		Filial para o processamento


@author	Douglas Parreja
@since		10/02/2014
@version	12
/*/
//-------------------------------------------------------------------
function cancelaAutoNFe( cLockFile, cProcesso, aNotas, cEmpresa, cFilEmp, cIdEnt, cUrl, cModelo , xParam )
Local aHist      	:= {}
Local aHistRet		:= {}
Local cRetorno		:= ""
Local cNumDoc		:= ""
Local cNumSerie		:= ""
Local cSerie		:= ""
Local cDoc			:= ""
Local cMod			:= ""
Local cTpEvento		:= "110111"
Local cXjust		:= ""
Local cErro			:= ""
Local cTipoMov		:= "1"
Local nTamSerie		:= 0
Local nTamDoc   	:= 0
Local nX 			:= 0
Local aRetorno 		:= {}
Local aNFeCol		:= {}
Local lCancOk		:= .F.
Local lAutoNF		:= .T.
Local lUsaColab		:= .F.
Local lCancela		:= .F.
Local lInutiliza	:= .F.
Local lGerado		:= .F.
Local lCTe			:= .F.
Local lTrfNfeCanc 	:= ExistBlock('TRFNFECANC')

default cEmpresa 	:= ""
default cFilEmp 	:= ""
default cIdEnt		:= ""
default cUrl		:= ""
default cModelo		:= "55"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preparando variaveis para validações do ambiente de cancelamento       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lCTe := IIf(cModelo=="57",.T.,.F.)
lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )
//-------------------------------------------------------------------
/*
 					[1] Conteudo do campo F3_ENTRADA
               		[2] Conteudo do campo F3_SERIE
               		[3] Conteudo do campo F3_NFISCAL
		       		[4] Conteudo do campo F3_ESPECIE
		       		[5] Conteudo do campo F3_CODRSEF
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TOTVS Colaboracao                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando o tamanho dos campos na SX3                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamSerie := TamSX3("F3_SERIE")[1] 			// Tamanho do campo F3_SERIE
nTamDoc   := TamSX3("F3_NFISCAL")[1]	 	// Tamanho do campo F3_NFISCAL

If lTrfNfeCanc .and. !Empty(aNotas)
	aNotas := ExecBlock("TRFNFECANC",.F.,.F.,{aNotas})
Endif

//TOTVS Colaboracao
If lUsaColab

	oDoc := ColaboracaoDocumentos():new()
	oDoc:cModelo 	:= IIf(cModelo=="55","NFE",IIf(cModelo=="57","CTE",""))
	oDoc:cTipoMov	:= cTipoMov

	For nX:=1 to Len(aNotas)

		cXjust 		:= ""
		cSerie		:= aNotas[nX][3]
		cDoc		:= aNotas[nX][4]
		cMod	 	:= IIf(cModelo == "55","NFE","CTE")
		cIdErp 	:= aNotas[nX][3] + aNotas[nX][4] + FwGrpCompany()+FwCodFil()
		aHist:= {}
		aAdd (aHist, FwCodFil())
		aAdd (aHist, cMod	)
		aAdd (aHist, cTipoMov)
		aAdd (aHist,cIdErp)
		aInfXml	:= ColExpDoc(cSerie , cDoc , cMod )

		aHistRet := GetHistCKQ(cIdErp,aHist)

		If ( !aInfXml[1]) .Or. 	;			// Se retornar .F. esta correto, pois nao consta o registro na base e com isso pode inutilizar.
			(!aInfXml[1]  .And. (empty(alltrim(aNotas[nX][8])) ) ) .or.;
		  	( aInfXml[1] .And. Empty(aInfXml[2]) .And. Empty(aInfXml[3]) .And. Empty(aInfXml[4]) .And. Empty(aInfXml[6])) //Consta documento na base (Rejeitado) E nao tem Xml Autorizado

			cXjust := "Motivo de inutilizacao nota " + cSerie + "-" + cDoc

		Else
			cXjust := "Motivo de cancelamento nota " + cSerie + "-" + cDoc

		EndIf

		If aInfXml[1] //Consta documento

			//Chave | Xml Autorizado
			If ( !Empty(aInfXml[2]) .And. !Empty(aInfXml[3]) )
				lCancela := .T.

			// Xml Cancelamento | Xml Inutilizacao = Se retornado nao pode transmitir o cancelamento/inutilizacao porque ja foi transmitido
			ElseIf !Empty(aInfXml[4]) .Or. !Empty(aInfXml[6])
				lCancela := .F.

			// Contingencia = Quando eh retornado CSTAT igual a "1" eh retornado a chave do Documento para realizar o Cancelamento
			Elseif (!Empty(aInfXml[2]) .And. Empty(aInfXml[3]) .And. Empty(aInfXml[4]) .And. Empty(aInfXml[5]) .And. Empty(aInfXml[6]) )
				lCancela 	:= .F.
				lInutiliza	:= .F.

			// Rejeitado = Documento transmitido e rejeitado
			Else
				lInutiliza := .T.
			EndIf

		//Inutilizacao
		Else
			lInutiliza := .T.
		EndIf
		IF  ((aHistRet[1][2] .or. lInutiliza) .And. ('2' $ aHistRet[1][8]))
			If lCancela .Or. lInutiliza
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adicionando no aNFe para manter o padrao das funcoes SpedCCeXml e ColEnvEvento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aNFeCol := {}
				aAdd(aNFeCol,aInfXml[2] ) 	//01 - Chave da Nfe
				aAdd(aNFeCol,"")			 				//02 - em branco
				aAdd(aNFeCol,cSerie) 					//03 - Serie
				aAdd(aNFeCol,cDoc) 						//04 - Numero

				oDoc:cNomeArq := "" 		// Limpando o nome do Arq. pois sera criado outro arquivo.
				If lCancela
					cXml := SpedCCeXml( aNFeCol , cXjust , cTpEvento , aInfXml[7] , , , , lCte )
				ElseIf lInutiliza
					cXml := ColInutTrans( aNFeCol , cXjust , cModelo )
				EndIf
				lGerado := ColEnvEvento( cMod , aNFeCol , cXml , nil , @cErro , lInutiliza )
				If lGerado
					lCancOk	:= ColAtuTrans( "1" , cSerie, cDoc ,/*cCliente*/,/*cLoja*/,/*lCTe*/,/*cChvCtg*/,/*nTpEmisCte*/)
				EndIf

				conout(cErro)
			EndIf
			conout(cErro)
		EndIf
	Next

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao TransCanc(SPEDNFE) - Realiza transmissao Cancelamento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lCancOk := TransCanc(aNotas, @aRetorno, lAutoNF, lCTe) .and. len(aRetorno) > 0 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se lCancOk retornou .T. eh porque as NFe foram transmitidas     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCancOk .And. !lUsaColab

	For nX:= 1 to len(aNotas)

		nPos := AScan(aNotas, {|x| x[3] + x[4] == aRetorno[nX]})

		If nPos > 0
			cRetorno  := aRetorno[nX]
			cNumDoc   := SubStr(cRetorno,nTamSerie+1,nTamDoc)
			cNumSerie := SubStr(cRetorno,1,nTamSerie)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para cada NFe transmitida eh gravada "T" de Transmitido.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF3")
			SF3->(DbSetOrder(6))
			If SF3->(DbSeek( xFilial("SF3") + cNumDoc + cNumSerie ))
				if Reclock("SF3",.F.)
					SF3->F3_CODRET := "T"
					SF3->(MsUnLock())
				EndIf
			Endif

		Endif
	Next
EndIf


Return

//-------------------------------------------------------------------------
/*/{Protheus.doc} retBancoDados
Funcao retBancoDados verifica qual Banco de Dados que esta sendo utilizado
para realizar a Query corretamente.

@return	lBancoPadrao			Retorna se o banco utilizado eh na qual
									consta na validacao


@author	Douglas Parreja
@since		20/05/2015
@version	11
/*/
//-------------------------------------------------------------------------
Function retBancoDados()

Local cBanco 			:= Alltrim(Upper(TCGetDb()))
Local lBancoPadrao	:= .F.

// Validacao de banco igual consta na ChangeQuery
If ( cBanco == 'ORACLE' ) .Or. ( cBanco == 'INFORMIX' ) .Or. ( cBanco == 'DB2' ) .Or. ( cBanco == 'CTREESQL' ) .Or. ( cBanco == 'OPENEDGE' )

	lBancoPadrao := .T.

EndIf

// Caso nao entre na funcao sera realizado validacao conforme padrao SQL, MySql, etc...

Return lBancoPadrao

//-------------------------------------------------------------------------
/*/{Protheus.doc} FIntegNfTaf
Função responsável pelo envio do documento fiscal eletrônico para o TAF após
o retorno do TSS com a chave eletrônica.

@Param	aDocSFT    -> Array com a chave do documento fiscal para integração
		lTAFVldAmb -> Controle do ERP para saber se a integração online pode ser realizada

@author	 Rodrigo Aguilar
@since	 16/02/2017
/*/
//-------------------------------------------------------------------------
Function FIntegNfTaf( aDocSFT, lTAFVldAmb )

 //-----------------------------------------------------------
// Chama Job para intregacao NATIVA do documento fiscal no TAF
//-----------------------------------------------------------
if lTAFVldAmb
	/*
		DocFisxTAF(c_EmpresaT,c_FilialT,a_DocSFT,l_LmTafKey)
		@param c_EmpresaT, caracter, contem a empresa para thread
		@param c_FilialT, caracter, contem a filial para thread
		@param a_DocSFT, array, contem as informações do documento informado
		@param l_LmTafKey, logico, se deve limpar o campo FT_TAFKEY

		@author Vitor Ribeiro (vitor.e@totvs.com.br)
		@since 02/01/2018
	*/
    StartJob('DocFisxTAF',GetEnvServer(),.F.,cEmpAnt,cFilAnt,aDocSFT,.T.)
endif

Return

//-------------------------------------------------------------------------
/*/{Protheus.doc} RetChave
Funcao RetChave retorna a chave valida dentro do xml
@Param   cXML            CXml
@return	 Chave		     Retorna a chave correta com 44 dígitos.
@author	Valter da Silva
@since		21/11/2018
@version	11
/*/
//-------------------------------------------------------------------------
Function RetChave(cXML)

Local cChave :=''
default cXML :=''

If '<infEvento Id' $ cXML
	cChave  := SubStr(NfeIdSPED(cXML,"Id"),9,44)
ElseIf "NFCom" $ cXml
	cChave  := SubStr(NfeIdSPED(cXML,"Id"),6)
Else
	cChave  := SubStr(NfeIdSPED(cXML,"Id"),4)
endif

Return cChave

/*/{Protheus.doc} ValAtrib
Função utilizada para substituir o type onde não seja possivél a sua retirada para não haver  
ocorrencia indevida pelo SonarQube.
/*/
//-----------------------------------------------------------------------
static Function ValAtrib(atributo)
Return (type(atributo) )

/*/{Protheus.doc} AtuSF9
Responsavel por atualizar a chave na tabela SF9 - Manutenção CIAP 
quando Formulario Proprio = S

@Param	cDoc		- Numero de documento
		cSerie		- Numero de serie do documento
		cFornCli 	- Codigo do fornecedor/cliente
		cLoja		- Loja do fornecedor/cliente
		dDtNFe		- Data de emissao do documento
		cChave		- Chave de autorização do documento

@return	nil

@author	Felipe Martinez
@since	11/02/2022
@version 12.1.27
/*/
static function AtuSF9(cDoc, cSerie, cFornCli, cLoja, dDtNFe, cChave)
local cFilSF9	:= xFilial("SF9")
local cDtNfe	:= dTos(dDtNFe)

static cCpoCust	:= nil
static cCpoPad	:= nil

if cCpoCust == nil
	cCpoCust := superGetMv("MV_F9CHVNF",,"")
	cCpoCust := iif(!empty(cCpoCust) .and. SF9->(columnPos(cCpoCust)) > 0, cCpoCust, "")
endIf

if cCpoPad == nil
	cCpoPad := iif(SF9->(columnPos("F9_CHAVENF")) > 0, "F9_CHAVENF", "")
endIf

//F9_FILIAL+DTOS(F9_DTENTNE)+F9_DOCNFE+F9_SERNFE+F9_FORNECE+F9_LOJAFOR+F9_CFOENT+STR(F9_PICM,5,2)
SF9->(dbSetOrder(2))
if ( !empty(cCpoPad) .or. !empty(cCpoCust) ) .and. SF9->(msSeek(cFilSF9+cDtNfe+cDoc+cSerie+cFornCli+cLoja))
	
	while !SF9->(EOF()) .and.;
		SF9->(F9_FILIAL+DTOS(F9_DTENTNE)+F9_DOCNFE+F9_SERNFE+F9_FORNECE+F9_LOJAFOR) == cFilSF9+cDtNfe+cDoc+cSerie+cFornCli+cLoja
		
		if upper(SF9->F9_PROPRIO) == "S"
			if SF9->(recLock("SF9",.F.))
				if !empty(cCpoCust) //legado de campo de chave criado por parametro 
					SF9->&(cCpoCust) := cChave
				endIf
				if !empty(cCpoPad) //Novo campo de chave da tabela
					SF9->&(cCpoPad) := cChave
				endIf
				SF9->(msUnlock())
			endIf
		endIf
		
		SF9->(dbSkip())
	end
endIf

return nil
