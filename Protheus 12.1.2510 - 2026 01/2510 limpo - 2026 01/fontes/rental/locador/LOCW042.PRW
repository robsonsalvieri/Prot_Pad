#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW042NF.PRW
	ITUP BUSINESS - TOTVS RENTAL
	Liberação do PV - Rental
	@TYPE FUNCTION
	@AUTHOR FRANK ZWARG FUGA
	@SINCE 26/11/2025

	@AUTHOR Alessandro Gois
	@SINCE 02/12/2025

/*/

WSRESTFUL LOCW042NF DESCRIPTION "Metodo para retornar informacoes da nota fiscal - Rental"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para retornar informacoes da nota fiscal - Rental.</h2>" WSSYNTAX "/locw042NF"

END WSRESTFUL


/*/{PROTHEUS.DOC} LOCW042NF
	ITUP BUSINESS - TOTVS RENTAL
	Liberação do PV - Rental
	@TYPE FUNCTION
	@AUTHOR FRANK ZWARG FUGA
	@SINCE 26/11/2025
/*/

WSMETHOD POST  WSSERVICE LOCW042NF
Local bError   := {||}
Local cEnvLog  := ""
Local cRet	   := ""
Local cBody	   := DecodeUtf8(::GetContent())
Local aEmp     := {}
Local cAprov   := ""

Local cNota
Local dEmissaoI
Local dEmissaoF
Local cCliente
Local cLoja

Private oJson  := Nil
Private lTransf
Private lLiber


	::SetContentType("application/json; charset=iso-8859-1")

	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )

		Begin Sequence
			If FWJsonDeserialize(cBody,@oJson)

				if empty(oJson:emissaoi)
					cRet := Alltrim(FWhttpEncode('{"Retorno":"nao ok", "motivo":"Favor Informar a emissao inicial"}')) 
				elseif empty(oJson:emissaof)
					cRet := Alltrim(FWhttpEncode('{"Retorno":"nao ok", "motivo":"Favor Informar a emissao final"}')) 
				elseif empty(oJson:cliente)
					cRet := Alltrim(FWhttpEncode('{"Retorno":"nao ok", "motivo":"Favor Informar o codigo do cliente"}'))
				elseif empty(oJson:loja)
					cRet := Alltrim(FWhttpEncode('{"Retorno":"nao ok", "motivo":"Favor Informar a loja do cliente"}'))
				endif		

				if empty(cRet)
					dEmissaoI := oJson:emissaoi
					dEmissaoF := oJson:emissaof
					cCliente  := oJson:cliente
					cLoja	  := oJson:loja
					If type("oJson:aprova") == "C"
						cAprov    := oJson:aprova
					EndIf

					aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
					If (aEmp[3] == "Empresa já existente.")
						//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
						//Daniel
						cRet := xAbreEnv1(aEmp[1],aEmp[2])

						if empty(cRet)

							cRet := '{"retorno": "ok","conteudo":' + LCW42NFB(cNota,dEmissaoI,dEmissaoF,cCliente,cLoja,cAprov) + '}'

						endif
					else
						cRet := '{"Retorno":"nao ok", "motivo": "Empresa nao encontrada"}'
					endif
				endif
			EndIf
		End Sequence
	
	::SetResponse(Alltrim(FWhttpEncode(cRet)) )
	
Return .T.




/*/{PROTHEUS.DOC} LCW42NFA
	ITUP BUSINESS - TOTVS RENTAL
	Lista de Notas Fiscais de Saída - Rental, funcao para retornar o xml da nota fiscal de saida
	@TYPE FUNCTION
	@AUTHOR Alessandro Gois
	@SINCE 02/01/2026
/*/
static Function LCW42NFA(cDocumento, cSerie, lMostra)
Local aArea        := GetArea()
Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Local oWebServ
Local cIdEnt       := RetIdEnti()
Local cTextoXML    := ""
Default cDocumento := ""
Default cSerie     := ""
Default lMostra    := .F.
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA == Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                EndIf
                    
            EndIf
   		 EndIf
	endif
    RestArea(aArea)
Return cTextoXML



/*/{PROTHEUS.DOC} LCW42NFB
	ITUP BUSINESS - TOTVS RENTAL
	Lista de Notas Fiscais de Saída - Rental
	@TYPE FUNCTION
	@AUTHOR Alessandro Gois
	@SINCE 03/12/2025
/*/
static Function LCW42NFB(cNota,dEmissaoI,dEmissaoF,cCliente,cLoja,cAprov)
Local oJson, oSF2, oFPY
Local CSQL
Local cRet := '{}'
Local nparcTot := 0
Local nParcAtr := 0
Local nParQtd  := 0
Local aSF2     := {}
Local aFPY     := {}
Local cFil	   := ''
Local cDoc	   := ''
Local cSerie   := ''		
Local cCli	   := ''		
Local cLoj	   := ''

	CSQL := "SELECT COALESCE(FPY_FILIAL,'') FPY_FILIAL, COALESCE(FPY_CLIENT,'') FPY_CLIENT, COALESCE(FPY_LOJA,'') FPY_LOJA, " 
	CSQL += " 		COALESCE(FPY_DATA,'') FPY_DATA, COALESCE(FPY_PROJET,'') FPY_PROJET, COALESCE(FPY_PEDVEN,'') FPY_PEDVEN, "
	CSQL += " 		COALESCE(FPY_TIPFAT,'') FPY_TIPFAT, COALESCE(FPY_OBRA,'') FPY_OBRA,
	CSQL += " 		F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_COND, F2_EMISSAO, F2_VALBRUT, F2_CHVNFE, 
	CSQL += " 		COALESCE(E1_FILIAL,'') E1_FILIAL, COALESCE(E1_PREFIXO,'') E1_PREFIXO, COALESCE(E1_NUM,'') E1_NUM,  
	CSQL += " 		COALESCE(E1_PARCELA,'') E1_PARCELA, COALESCE(E1_TIPO,'') E1_TIPO, COALESCE(E1_NATUREZ,'') E1_NATUREZ, 
	CSQL += " 		COALESCE(E1_CLIENTE,'') E1_CLIENTE, COALESCE(E1_LOJA,'') E1_LOJA, COALESCE(E1_NOMCLI,'') E1_NOMCLI,
	CSQL += " 		COALESCE(E1_EMISSAO,'') E1_EMISSAO, COALESCE(E1_VENCREA,'') E1_VENCREA, 
	CSQL += " 		COALESCE(E1_VALOR,0) E1_VALOR, COALESCE(E1_SALDO,0) E1_SALDO
	CSQL += " FROM " + RETSQLNAME("SF2") + "  SF2 "
	CSQL += " INNER JOIN " + RETSQLNAME("SD2") + "  SD2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SD2.D_E_L_E_T_ = ' ' "
	CSQL += " LEFT JOIN " + RETSQLNAME("FPY") + " FPY ON FPY_PEDVEN = SD2.D2_PEDIDO AND FPY.FPY_STATUS = '1 ' AND FPY.D_E_L_E_T_ = ' '  "

	If cAprov == "A"
		CSQL += " AND FPY_APROV = '1' "
	EndIf
	If cAprov == "R"
		CSQL += " AND FPY_APROV = '2' "
	EndIf

	CSQL += " LEFT JOIN " + RETSQLNAME("SE1") + " SE1 ON E1_FILIAL = F2_FILIAL AND E1_NUM = F2_DOC AND E1_CLIENTE = F2_CLIENTE AND E1_LOJA = F2_LOJA AND SE1.D_E_L_E_T_ = ' '"
	CSQL += " WHERE "
	CSQL += " 	 SF2.D_E_L_E_T_ = ' ' "
	CSQL += " 	AND F2_EMISSAO BETWEEN ? AND ? "
	CSQL += " 	AND F2_CLIENTE = ? "
	CSQL += " 	AND F2_LOJA = ? "
	CSQL += " 	ORDER BY F2_FILIAL, F2_DOC, F2_CLIENTE, F2_LOJA "
	CSQL := CHANGEQUERY(CSQL)

	aBindParam := {dEmissaoI, dEmissaoF,cCliente, cLoja}

	cAlias := MPSysOpenQuery(CSQL,,,,aBindParam)


    // Criação do JSON principal
    oJson := JsonObject():New()


	do While (cAlias)->(!EOF())
		oSF2 := Nil
		oFPY := Nil
		

		// Seção SF2
		oSF2 := JsonObject():New()
		oSF2["F2_DOC"]      := (CALIAS)->F2_DOC
		oSF2["F2_SERIE"]    := (CALIAS)->F2_SERIE
		oSF2["F2_CLIENTE"]  := (CALIAS)->F2_CLIENTE
		oSF2["F2_LOJA"]     := (CALIAS)->F2_LOJA
		oSF2["F2_COND"]     := (CALIAS)->F2_COND
		oSF2["F2_EMISSAO"]  := (CALIAS)->F2_EMISSAO
		oSF2["F2_VALBRUT"]  := (CALIAS)->F2_VALBRUT


		// DSERLOCA-9912 - Alessandro Gois, 02/01/2026
		oSF2["F2_CHVNFE"]   := (cAlias)->F2_CHVNFE
		if !empty((cAlias)->F2_CHVNFE)
			if alltrim(len((cAlias)->F2_CHVNFE)) == 44 
				oSF2["F2_tiponf"]   := iif(substr((cAlias)->F2_CHVNFE,21,2) == '55','NFe','NFSe')
			else
				oSF2["F2_tiponf"]   := 'NFSe'
			endif
		else
			oSF2["F2_tiponf"]   := ''
		endif

		oSF2["xml"] 	    := LCW42NFA((cAlias)->F2_DOC, (cAlias)->F2_SERIE, .F.)
		// DSERLOCA-9912 fim - Alessandro Gois, 02/01/2026

		cFil		:= (cAlias)->F2_FILIAL
		cDoc		:= (cAlias)->F2_DOC
		cSerie		:= (cAlias)->F2_SERIE
		cCli     	:= (cAlias)->F2_CLIENTE
		cLoj		:= (cAlias)->F2_LOJA

		nparcTot := 0
		nParcAtr := 0
		nParQtd	 := 0

		do While (cAlias)->(!EOF()) .and. (cAlias)->F2_FILIAL == cFil .and. ;
			(cAlias)->F2_DOC == cDoc .and. (cAlias)->F2_SERIE == cSerie .and. ;
			(cAlias)->F2_CLIENTE == cCli .and. (cAlias)->F2_LOJA == cLoj

			// Seção FPY
			oFPY := JsonObject():New()
			oFPY["FPY_FILIAL"]  := (CALIAS)->FPY_FILIAL
			oFPY["FPY_CLIENT"]  := (CALIAS)->FPY_CLIENT
			oFPY["FPY_LOJA"]    := (CALIAS)->FPY_LOJA
			oFPY["FPY_DATA"]    := (CALIAS)->FPY_DATA
			oFPY["FPY_PROJET"]  := (CALIAS)->FPY_PROJET
			oFPY["FPY_PEDVEN"]  := (CALIAS)->FPY_PEDVEN
			oFPY["FPY_TIPFAT"]  := (CALIAS)->FPY_TIPFAT
			oFPY["FPY_OBRA"]    := (CALIAS)->FPY_OBRA

			aadd(aFPY, oFPY)

			nParQtd ++
			nparcTot := 0
			nParcAtr := 0

			if !empty((CALIAS)->E1_VENCREA)

				if (CALIAS)->E1_SALDO == 0
					nparcTot ++
				elseif (CALIAS)->E1_SALDO >= 0 .and. ddatabase > stod((CALIAS)->E1_VENCREA)
					nParcAtr ++ 
				endif

			endif


			(cAlias)->(dbSkip())

		enddo

		if nparcTot == nParQtd
			cStatus := 'total'
		else
			if nParcAtr > 0
				cStatus := 'atrasado'
			else
				cStatus := 'a vencer'
			endif
		endif
		oSF2["F2_STATUS" ]  := cStatus


		oSF2["FPY"] := aFPY
		
		aadd(asF2, oSF2)
	enddo

	if !empty(aSF2)
		oJson["SF2"] := aSF2
		cRet := oJson:toJson()
	endif
	
Return cRet

