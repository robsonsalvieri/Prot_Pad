#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PLSR003.ch"

#Define _BL 25
#Define Moeda "@E 999,999,999.99"

static oFnt09C := TFont():New("Arial",9,9,,.f., , , , .t., .f.)
static oFnt10C 		:= TFont():New("Arial",10,10,,.f., , , , .t., .f.)
static oFnt10N := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
static objCENFUNLGP := CENFUNLGP():New()

/*/{Protheus.doc} PLSR003
Geração do relatório de Extrato Financeiro em formato Base64,
permitindo a filtragem dos dados por empresa ou por um intervalo de matrículas (beneficiários).
@type static function 
@author giovanna.charlo
@since 28/05/2026
@version 12.1.2510  
@param aData, array, contendo os parâmetros de filtro do relatório:
    - aData[1]: month             (Mês de Referência)
    - aData[2]: year              (Ano de Referência)
    - aData[3]: healthInsurerCode (Código da Operadora)
    - aData[4]: companyCode       (Código da Empresa)
    - aData[5]: contractCode      (Código do Contrato)
    - aData[6]: contractVersion   (Versão do Contrato)
    - aData[7]: subcontractCode   (Código do Subcontrato)
    - aData[8]: subcontractVersion(Versão do Subcontrato)
    - aData[9]: subscriberIdTo  (Matrícula Inicial / De)
    - aData[10]: subscriberIdFrom   (Matrícula Final / Até)
    - aData[11]: expenseType      (Tipo de Despesa)
@param cDiretory, character, Caminho do diretório para processamento do arquivo.
@return aFile[1], character, nome do arquivo gerado (PDF)
/*/
user function PLSR003(aData,cDiretory)

    local oReport := nil
    local cFileName	:= STR0001+CriaTrab(nil,.F.) //FinancialStatement
    local lPrint := .f.
    local aFile := {"",""}

    default aData := {}
    default cDiretory := lower(getMV("MV_RELT"))

    private cTitulo := STR0002 //Extrato Financeiro
    private nLeft := 70
    private nTop := 130
    private nTopInt	:= nTop
    private nColIni := 065
    private nAC := 0.24
    private nLinVer 	:= 590
    private nColMax := 3350
    private nTweb := 3
    private nLweb := 10
    private nRight := 2650
    private nPag := 1
    private nCol0 := nLeft
    private nDivEsp := 0 // era static

    oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)

    oReport:lInJob  	:= .t.
    oReport:lServer 	:= .t.
    oReport:cPathPDF	:= cDiretory

    oReport:setDevice(IMP_PDF)
    oReport:setResolution(72)
    oReport:SetLandscape()
    oReport:SetPaperSize(9)
    oReport:setMargin(05,05,05,05)

    lPrint := loadReport(@oReport,aData)

    if lPrint
    	aFile := {cFileName+".pdf",""}
        oReport:EndPage()
    	oReport:Print()
    else
    	aFile := {"",""}
    endif

    if lPrint
    	PLSCHKRP(cDiretory, cFileName+".pdf")
    endIf

return aFile[1] 

/*/{Protheus.doc} loadReport
Criação do Relatório Extrato Financeiro em Base64.
@type static function 
@author giovanna.charlo
@since 28/05/2026
@version 12.1.2610 
@param oReport, object, Objeto do relatório em execução.
@param aData, array, contém os parâmetros para o filtro do relatório
@return lPrinter, logical, indica se foram encontrados registros para a geração do relatório.
/*/
static function loadReport(oReport,aData)
    
    local oExecStmt := nil
    local cAlias := ""
    local lFirstPage := .t.
    local cBeneficiary := ""
    local nInitBal := 0
    local nTotPaid := 0 
    local nLi := 0 
    local lPrinter := .t.
    local cLastBenef := ""
    local cRegistrationCode := ""
    local cLastCode := ""

    objCENFUNLGP:setAlias("BA0")

    oExecStmt := loadData(aData)
    cAlias := oExecStmt:openAlias()

    (cAlias)->(dbGoTop())

    if !(cAlias)->(Eof())

        oReport:StartPage()
        nLi := 1

        while !(cAlias)->(eof())

            cBeneficiary := (cAlias)->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_DIGITO)
            cRegistrationCode := (cAlias)->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC)

            if lFirstPage
                createHeader(@oReport, cBeneficiary, aData[1], aData[2], (cAlias)->(BM1_TIPUSU), @nLi)
                lFirstPage := .f.
            endif
            if !lFirstPage
                if nLi > 17
			    	nLi := 1
			    	oReport:EndPage()
			    	oReport:StartPage()
			    	createHeader(@oReport, cBeneficiar, aData[1], aData[2], (cAlias)->(BM1_TIPUSU),@nLi)
		        endif
            endif

            if !empty(cLastBenef) .and. !(cBeneficiary == cLastBenef)
                //Adiciona a Linha Total Valor Pago referente ao beneficiário anterior
                addPaidLine(@oReport,nTotPaid, @nLi) 
                nTotPaid := 0
                nInitBal := 0
            
                if !empty(cLastCode) .and. !(cRegistrationCode == cLastCode) 
                    nLi := 18
                    
                    if nLi > 17
			        	nLi := 1
			        	oReport:EndPage()
			        	oReport:StartPage()
			        	createHeader(@oReport, cBeneficiar, aData[1], aData[2], (cAlias)->(BM1_TIPUSU),@nLi)
		            endif

                else
                    //Adiciona os dados do cabeçalho referente ao próximo beneficiário
                    addBenefName(@oReport, cBeneficiary, (cAlias)->(BM1_TIPUSU), @nLi)
                endif
            endif

            createItems(@oReport,(cAlias)->BM1_CODTIP,(cAlias)->BM1_DESTIP,(cAlias)->BM1_ANO,;
                                (cAlias)->BM1_MES,@nInitBal,@nTotPaid,(cAlias)->BM1_VALMES,(cAlias)->BM1_VALOR,;
                                (cAlias)->E1_VALLIQ,(cAlias)->E1_VALOR,(cAlias)->(BM1_PREFIX + BM1_NUMTIT),@nLi)

            cLastBenef := (cAlias)->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_DIGITO)
            cLastCode:= (cAlias)->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC)
        (cAlias)->(dbSkip())
        enddo
        addPaidLine(@oReport,nTotPaid, @nLi) 
    else 
        lPrinter := .f.
    endif

    (cAlias)->(dbCloseArea())
    freeObj(oExecStmt)

return lPrinter

/*/{Protheus.doc} loadData
Busca e estrutura os dados do Extrato Financeiro em Base64.
@type static function 
@author giovanna.charlo
@since 20/05/2026
@version 12.1.2610  
@param aData, array, contém os parâmetros para o filtro do relatório
@return oExecStmt, object, objeto contendo a query para execução.
/*/
static function loadData(aData)

    local oExecStmt := nil
    local nOrder := 1 
    local cQuery := ""

    cQuery := " SELECT  ? "
	cQuery += " FROM ? BM1 "

    cQuery += " LEFT JOIN ? SE1 ON
	cQuery += " 	SE1.E1_FILIAL = ? AND "
	cQuery += " 	SE1.E1_NUM  = BM1.BM1_NUMTIT AND "
    cQuery += " 	SE1.E1_PREFIXO  = BM1.BM1_PREFIX AND "
    cQuery += " 	SE1.E1_PARCELA  = BM1.BM1_PARCEL AND "
    cQuery += " 	SE1.E1_TIPO  = BM1.BM1_TIPTIT AND "
	cQuery += " 	SE1.E1_BAIXA <> ? AND "
	cQuery += " 	SE1.D_E_L_E_T_ = ? "

	cQuery += " WHERE "

    if !empty(aData[9]) .and. !empty(aData[10])
        cQuery += "     BM1.BM1_CODINT || BM1.BM1_CODEMP || BM1.BM1_MATRIC || BM1.BM1_TIPREG || BM1.BM1_DIGITO  >= ? AND "
        cQuery += "     BM1.BM1_CODINT || BM1.BM1_CODEMP || BM1.BM1_MATRIC || BM1.BM1_TIPREG || BM1.BM1_DIGITO  <= ? AND "
    else
        cQuery += "     BM1.BM1_CODINT = ? AND "
        cQuery += "     BM1.BM1_CODEMP = ? AND "
        cQuery += "     BM1.BM1_CONEMP = ? AND "
        cQuery += "     BM1.BM1_VERCON = ? AND "
        cQuery += "     BM1.BM1_SUBCON = ? AND "
        cQuery += "     BM1.BM1_VERSUB = ? AND "
    endif

    cQuery += "     BM1.BM1_MES = ? AND "
    cQuery += "     BM1.BM1_ANO = ? AND "
    cQuery += "     BM1.BM1_CODTIP = ?"
  
    cQuery += " AND BM1.D_E_L_E_T_ = ? "

    cQuery += " ORDER BY ?"

    cQuery := ChangeQuery(cQuery)

    oExecStmt := FwExecStatement():new(cQuery)

    oExecStmt:setUnsafe(nOrder++, "BM1.BM1_CODINT,BM1.BM1_CODEMP,BM1.BM1_MATRIC,BM1.BM1_TIPREG,BM1.BM1_DIGITO,"+;
                                  "BM1.BM1_CODTIP,BM1.BM1_DESTIP,BM1.BM1_MES,BM1.BM1_ANO,BM1.BM1_VALMES,BM1.BM1_VALOR,"+;
                                  "BM1.BM1_PREFIX,BM1.BM1_NUMTIT,SE1.E1_VALOR,SE1.E1_VALLIQ,SE1.E1_SALDO,BM1.BM1_TIPUSU")
    oExecStmt:setUnsafe(nOrder++, retSqlName("BM1")) 
    oExecStmt:setUnsafe(nOrder++, retSqlName("SE1"))
    oExecStmt:setString(nOrder++, xFilial("SE1"))
    oExecStmt:setString(nOrder++, "")
    oExecStmt:setString(nOrder++, "")

    if !empty(aData[9]) .and. !empty(aData[10])
        oExecStmt:setString(nOrder++, aData[9])
        oExecStmt:setString(nOrder++, aData[10])
    else
        oExecStmt:setString(nOrder++, aData[3])
        oExecStmt:setString(nOrder++, aData[4])
        oExecStmt:setString(nOrder++, aData[5])
        oExecStmt:setString(nOrder++, aData[6])
        oExecStmt:setString(nOrder++, aData[7])
        oExecStmt:setString(nOrder++, aData[8])
    endif

    oExecStmt:setString(nOrder++, aData[1])
    oExecStmt:setString(nOrder++, aData[2])
	oExecStmt:setString(nOrder++, aData[11])

    oExecStmt:setString(nOrder++, " ")
    oExecStmt:setUnsafe(nOrder++,"BM1.BM1_CODINT,BM1.BM1_CODEMP,BM1.BM1_MATRIC,BM1.BM1_TIPREG,BM1.BM1_DIGITO")

return oExecStmt

/*/{Protheus.doc} createHeader
Montagem do cabeçalho do Extrato Financeiro.
@type static function 
@author giovanna.charlo
@since 28/05/2026
@version 12.1.2610  
@param oReport, object, Objeto do relatório em execução.
@param cBeneficiary, character,  matrícula do beneficiário.
@param cMonthYear, character, Competência (Mês/Ano) do extrato.
@param cType, character, Tipo do cabeçalho/impressão.
@param nLi, numeric, Linha atual para posicionamento da impressão.
/*/
static function createHeader(oReport, cBeneficiary, cMonth, cYear, cType, nLi)

    local cCodint := PlsIntPad()
    local cNlogo := "lgesqrl"
    local aBMP := {"lgesqrl.bmp"}
    local nSize := 55
    local nLinIni := 5
    local oFnt14N := TFont():New("Arial",18,18,,.t., , , , .t., .f.)
    local cMessage := ""
    local cTitle := STR0002 //Extrato Financeiro
  
    BA0->(dbSetOrder(1))
    BA0->(MsSeek(xFilial("BA0")+ cCodint))

    nLeft := 25

	nTop		:= 100
	nTopInt	:= nTop
	nTop		+= _BL 
    nColIni := 065
    nColMax := 3350
	oReport:Box(nLeft,(nColIni + 0000)*nAC,nLinVer,(nColIni + nColMax)*nAC)
	nColMax := 260
	nTop := 30
	nColIni := 15  
	PlLogoImp(@oReport, nTop, nLeft, aBMP, cNlogo, nSize, nLinIni, nColIni, nColMax, nil, oFnt09C, objCENFUNLGP)   
	nLeft += 60

    cMessage := cTitle
    nTop += 80
    oReport:Say(((nTop)/nTweb)+nLweb, (nLeft + 900)/nTweb, cMessage, oFnt14N)

    nTop  += 130
    nLeft := 70
    cMessage := STR0003 + DTOC(dDatabase) //"Data do relatório: " 
    nTop += 45

    oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMessage, oFnt10N)

    cMessage := STR0004 + cMonth + "/" + cYear // "Mês/Ano de cobrança: "
    nTop += 35

    oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMessage, oFnt10N)
    nTop += 35

    addBenefName(@oReport, cBeneficiary, cType,@nLi)

return

/*/{Protheus.doc} addBenefName
Adiciona os dados de identificação do beneficiário ao Extrato Financeiro.
@type static function 
@author giovanna.charlo
@since 28/05/2026
@version 12.1.2610  
@param oReport, object, Objeto do relatório em execução.
@param cBeneficiary, character, matrícula do beneficiário.
@param cType, character, identificação do beneficiário (titular ou dependente).
@param nLi, numeric, Linha atual para o posicionamento da impressão.
/*/
static function addBenefName(oReport, cBeneficiary, cType, nLi)

    local cHolderType := superGetMv("MV_PLCDTIT", .F., "T") 
    local cMessage := ""
    local nColAux := 0
    
    oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb - 5, (nTop/nTweb)+nLweb, nRight/nTweb - 65)
    if cType == cHolderType 
	   	cMessage := STR0005 + ALLTRIM(Posicione("BA1",2,xFilial("BA1") + cBeneficiary ,"BA1_NOMUSR")) //"Beneficiário(a) titular: "
		nTop += 35
		oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMessage, oFnt10N)
	else
		cMessage := STR0006 + ALLTRIM(Posicione("BA1",2,xFilial("BA1")+cBeneficiary,"BA1_NOMUSR")) //"Dependente: "
		nTop += 35
		oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMessage, oFnt10N)
	endif
    
    nLi++
    nTop += _BL
    oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb - 5, (nTop/nTweb)+nLweb, nRight/nTweb - 65)
    nTop += _BL
    nPag++

    nTop += 40

    nLeft := 70
    nCol0 := nLeft

    nColAux  := (nCol0/nTweb)

    oReport:Say(nTop/nTweb, nColAux, STR0007, oFnt10c) //"Cod. Despesa"

    nColAux :=  105.625

    nDivEsp := nColAux

    oReport:Say(nTop/nTweb, nColAux, STR0008, oFnt10c) //"Tipo Despesa"

    nColAux += nDivEsp + 7 
    oReport:Say(nTop/nTweb, nColAux, STR0008, oFnt10c) //"Mês/ano Cobrança"

    nColAux += nDivEsp
    oReport:Say(nTop/nTweb, nColAux, STR0009, oFnt10c) //"Saldo Inicial(R$)"

    nColAux += nDivEsp
    oReport:Say(nTop/nTweb, nColAux, STR0010, oFnt10c) //"Despesa Mês(R$)"

    nColAux += nDivEsp
    oReport:Say(nTop/nTweb, nColAux, STR0011, oFnt10c) //"Valor Cobrado(R$)"

    nColAux += nDivEsp
    oReport:Say(nTop/nTweb, nColAux, STR0012, oFnt10c) //"Valor Pago(R$)"

    nColAux += nDivEsp
    oReport:Say(nTop/nTweb, nColAux, STR0013, oFnt10c) //"Saldo Final(R$)"

    nTop -= 35
    nTop += _BL
    nTop += 43
    nLi++
return

/*/{Protheus.doc} addPaidLine
Adiciona a linha de totalização do valor pago ao corpo do relatório.
@type static function 
@author giovanna.charlo
@since 28/05/2026
@version 12.1.2610  
@param oReport, object, Objeto do relatório em execução.
@param nTotPaid, numeric, Valor acumulado total pago a ser impresso.
@param nLi, numeric, Linha atual para posicionamento da impressão.
/*/
static function addPaidLine(oReport, nTotPaid, nLi)

    local cMessage := ""

    default nTotPaid := 0
     
    nTop += 35

    nColAux := (nCol0/nTweb) + nDivEsp

	nTop += _BL
	cMessage := STR0014 + Replicate( ".", 160) //"Total Valor Pago  "
	oReport:Say(nTop/nTweb, nLeft/nTweb, cMessage, oFnt10c)

	nColAux += 3* nDivEsp - 8
	oReport:Say(nTop/nTweb, nColAux  , AllTrim(cValtoChar(transform( nTotPaid, Moeda))), oFnt10c)

	nLi++
   	nTop += _BL
	nLi++

return

/*/{Protheus.doc} createItems
Renderiza os itens e movimentações detalhados do Extrato Financeiro.
@type static function 
@author giovanna.charlo
@since 28/05/2026
@version 12.1.2610  
@param oReport, object, Objeto do relatório em execução.
@param cCodeType, character, Código do tipo de lançamento(BM1_CODTIP).
@param cDescType, character, Descrição do tipo de lançamento(BM1_DESTIP).
@param cYear, character, Ano de referência(BM1_ANO).
@param cMonth, character, Mês de referência(BM1_MES).
@param nInitBal, numeric, Saldo inicial.
@param nTotPaid, numeric, Total pago.
@param nValMonth, numeric, Valor do mês(BM1_VALMES).
@param nBM1Val, numeric, Valor do título (BM1_VALOR).
@param nLiqVal, numeric, Vlr.Liq Baix (E1_VALLIQ).
@param nSE1Val, numeric, Valor do título (E1_VALOR).
@param cTit, character, Prefixo/Número do título (BM1_PREFIX + BM1_NUMTIT).
@param nLi, numeric, Linha atual para posicionamento da impressão.
/*/
static function createItems(oReport,cCodeType, cDescType, cYear, cMonth,;
                                nInitBal,nTotPaid, nValMonth, nBM1Val, nLiqVal, nSE1Val, cTit,  nLi)
    
    local nQtd := 0
    local lLiquid := .f.

    default nInitBal := 0
    
    nTop += 10

	nTop += _BL

	nColAux := (nCol0/nTweb)
	oReport:Say(nTop/nTweb, nColAux, cCodeType, oFnt10c) // Cod Despesa

	nColAux +=  nDivEsp - 22
	oReport:Say(nTop/nTweb, nColAux, PADR(cDescType,22), oFnt10c)  // Desc Despesa
			
			
	nColAux +=  nDivEsp + 17
	oReport:Say(nTop/nTweb, nColAux, cMonth + "/" + cYear, oFnt10c) //Mes Ano de cobrança


	nColAux += nDivEsp 
	oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform( nInitBal, Moeda))), oFnt10c) //Saldo Inicial


	nColAux += nDivEsp 
	oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(nValMonth, Moeda))), oFnt10c) //Despesa do Mê
	nColAux += nDivEsp  //
	oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(nBM1Val, Moeda))), oFnt10c) //Valor cobrado

    if nLiqVal < nSE1Val
	    BM1->(dbSetOrder(4))
	    if BM1->(dbSeek(xFilial("BM1") + cTit))
	    	while !BM1->(EOF()) .AND. BM1->(BM1_PREFIX + BM1_NUMTIT) == cTit
	    		nQtd++  
	    		BM1->(dbSkip())
	    	enddo  
	    	nTotal := nLiqVal/ nQtd
	    	lLiquid := .f.
	    endIf
	else
	    lLiquid := .t.
	endIf
  

	if lLiquid
		nTotal := nBM1Val
	endIf

	nTotPaid += nTotal

	nColAux += nDivEsp 
	oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform( nTotal, Moeda))), oFnt10c) //Valor pag   
	nColAux += nDivEsp 
	oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(nBM1Val - nTotal, Moeda))), oFnt10c) //Saldo Final

	nInitBal += nBM1Val - nTotal
	nLi++  

	nTop += _BL
	oReport:Line(nTop/nTweb, nLeft/nTweb - 5, nTop/nTweb, nRight/nTweb - 65)

return
