#include "protheus.ch"
#include "plsr107.ch"

/*/{Protheus.doc} PLSR107
Relatório para a Provisão para Prêmios ou Contraprestações Não Ganhas (PPCNG),
onde será demonstrado a precificação para o período de vigência mensal das
mensalidade (tipo de lançamento 101) dos lotes de cobrança que foram gerados.
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 03/03/2024
/*/
function PLSR107()

    local oReport as object
    local cPerg := "PLSR107" as character

    if pergunte(cPerg, .T.)
        oReport := reportDef(cPerg)
        oReport:printDialog()
    endif

    freeObj(oReport)

return

/*/{Protheus.doc} reportDef
Estrutura do relatório
@type function
@version 12.1.2410 
@author vinicius.queiros
@since 04/03/2024
@param cPerg, character, Grupo de perguntas do relatório
@return object, Objeto TReport
/*/
static function reportDef(cPerg)

    local oReport as object
    local oSection1 as object
    local cTitle := STR0001 as character // "Provisão para Prêmios ou Contraprestações Não Ganhas (PPCNG)"
    local lIsAnalytical := MV_PAR10 == 1 as logical
    
    oReport := TReport():new("PPCNG", cTitle, cPerg, {|oReport| printReport(oReport, lIsAnalytical)})
    oReport:setLandscape()
    oReport:DisableOrientation()

    oSection1 := TRSection():new(oReport, "Compositions")

    TRCell():new(oSection1, "BG9_DESCRI", nil, STR0004, "", 30) // "Nome do grupo/empresa"
    TRCell():new(oSection1, "BQC_DESCRI", nil, STR0005, "", 30) // "Nome do subcontrato"

    if lIsAnalytical
        TRCell():new(oSection1, "BM1_NOMUSR", nil, STR0006, "", 30) // "Nome do beneficiário"
    endif
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    TRCell():new(oSection1, "BM1_MES", nil, STR0002, "", tamSX3("BM1_MES")[1]) // "Mês base"
    TRCell():new(oSection1, "BM1_ANO", nil, STR0003, "", tamSX3("BM1_ANO")[1]) // "Ano base"
    TRCell():new(oSection1, "BM1_PREFIX", nil, STR0012, "", tamSX3("BM1_PREFIX")[1]) // "Prefixo"
    TRCell():new(oSection1, "BM1_NUMTIT", nil, STR0013, "", 12) // "Numero"
    TRCell():new(oSection1, "BM1_PARCEL", nil, STR0014, "", tamSX3("BM1_PARCEL")[1]) // "Parcela"
    TRCell():new(oSection1, "BM1_TIPTIT", nil, STR0015, "", tamSX3("BM1_TIPTIT")[1]) // "Tipo"
    TRCell():new(oSection1, "E1_EMISSAO", nil, STR0010, "", tamSX3("E1_EMISSAO")[1]) // "Dt. Emissão" 
    TRCell():new(oSection1, "BM1_CHVPRO", nil, STR0011, "", tamSX3("BM1_CHVPRO")[1]) // "Chave Contábil"   
    TRCell():new(oSection1, "BM1_VALOR", nil, STR0007, alltrim(getSx3Cache("BM1_VALOR", "X3_PICTURE")), tamSX3("BM1_VALOR")[1]) // "Vlr. mensalidade"
    TRCell():new(oSection1, "BM1_VPPCNG", nil, STR0008, alltrim(getSx3Cache("BM1_VPPCNG", "X3_PICTURE")), tamSX3("BM1_VPPCNG")[1]) // "Vlr. PPCNG"
    TRCell():new(oSection1, "BM1_VLRECE", nil, STR0009, alltrim(getSx3Cache("BM1_VLRECE", "X3_PICTURE")), tamSX3("BM1_VLRECE")[1]) // "Vlr. receita"
    TRCell():new(oSection1, "COB_RECEITA_INI", nil, STR0016, "",tamSX3("E1_EMISSAO")[1]) // Periodo da Cobertura Assistencial Receita Inicial
    TRCell():new(oSection1, "COB_RECEITA_FIM", nil, STR0017, "",tamSX3("E1_EMISSAO")[1]) // Periodo da Cobertura Assistencial Receita Final
	TRCell():new(oSection1, "COB_PPCNG_INI", nil, STR0018, "",tamSX3("E1_EMISSAO")[1])  // Periodo da Cobertura Assistencial Ppcng Inicial
    TRCell():new(oSection1, "COB_PPCNG_FIM", nil, STR0019, "",tamSX3("E1_EMISSAO")[1]) // Periodo da Cobertura Assistencial Ppcng Final

return oReport
   
/*/{Protheus.doc} printReport
Impressão do relatório
@type function
@version 12.1.2410
@author vinicius.queiros
@since 04/03/2024
@param oReport, object, Objeto TReport
@param lIsAnalytical, logical, Se o relatório é do tipo analítico
/*/
static function printReport(oReport, lIsAnalytical)

    local oSection1 := oReport:section(1) as object
    local oStatement as object
    local cAlias as character
    local nIncomeValue as numeric
    local nPPCNGValue as numeric
    local aFields as array
    local aPDFields as array
    local lObfuscated as logical
    local nX as numeric
    local xValue as variant
    local dDatePpcng as date

    if lIsAnalytical
        aFields := {"BG9_DESCRI", "BQC_DESCRI", "BM1_NOMUSR", "BM1_MES", "BM1_ANO", "BM1_PREFIX", "BM1_NUMTIT", "BM1_PARCEL", "BM1_TIPTIT", "E1_EMISSAO", "BM1_CHVPRO"}
    else
        aFields := {"BG9_DESCRI", "BQC_DESCRI", "BM1_MES", "BM1_ANO", "BM1_PREFIX", "BM1_NUMTIT", "BM1_PARCEL", "BM1_TIPTIT", "E1_EMISSAO", "BM1_CHVPRO"}
    endif

    oStatement := loadStatement(lIsAnalytical)
    cAlias := oStatement:openAlias()

    TCSetField(cAlias, "BA1_DATINC", "D")
    TCSetField(cAlias, "E1_EMIS1", "D")

    If oReport:nDevice == 1   
        oSection1:Cell("BM1_CHVPRO"):Disable()
    Endif

    if !(cAlias)->(eof())

        aPDFields := FwProtectedDataUtil():usrAccessPDField(__cUserID, aFields)
        lObfuscated := len(aPDFields) <> len(aFields)

        BM1->(dbSetOrder(1))

        while !(cAlias)->(eof())
            oSection1:init()

            for nX := 1 to len(aFields)
                xValue := (cAlias)->&(aFields[nX])

                if valType(xValue) == "C"
                    xValue := alltrim(xValue)

                    if getSx3Cache(aFields[nX], "X3_TIPO") == "D"
                        xValue := stod(xValue)
                    endif
                endif

                // Tratamento para ofuscar dados (LGPD)
                xValue := iif(lObfuscated .and. aScan(aPDFields, aFields[nX]) == 0,;
                              FwProtectedDataUtil():valueAsteriskToAnonymize(xValue),;
                              xValue)

                oSection1:cell(aFields[nX]):setValue(xValue)
            next nX

            oSection1:cell("BM1_VALOR"):setValue((cAlias)->BM1_VALOR)

            if ((cAlias)->BM1_VPPCNG > 0 .or. (cAlias)->BM1_VLRECE > 0)
                oSection1:cell("BM1_VPPCNG"):setValue((cAlias)->BM1_VPPCNG)
                oSection1:cell("BM1_VLRECE"):setValue((cAlias)->BM1_VLRECE)
            else
                if lIsAnalytical // Somente o relatório analítico é possível calcular o valor, devido o campo data de inclusão do beneficiário
                    nIncomeValue := PLPerRecPR((cAlias)->BA1_DATINC, (cAlias)->E1_EMIS1, (cAlias)->BM1_VALOR, .T.)
                    nIncomeValue := iif(nIncomeValue == 0, (cAlias)->BM1_VALOR, nIncomeValue)
                    nPPCNGValue := (cAlias)->BM1_VALOR - nIncomeValue

                    oSection1:cell("BM1_VPPCNG"):setValue(round(nPPCNGValue, 2))
                    oSection1:cell("BM1_VLRECE"):setValue(round(nIncomeValue, 2))
                    
                    if BM1->(msSeek(xFilial("BM1") + (cAlias)->(BM1_CODINT + BM1_CODEMP + BM1_MATRIC + BM1_ANO + BM1_MES + BM1_TIPREG + BM1_SEQ)))
                        BM1->(recLock("BM1", .F.))
                            BM1->BM1_VPPCNG := nPPCNGValue
                            BM1->BM1_VLRECE := nIncomeValue
                        BM1->(msUnLock())
                    endif
                endif
            endif 
			
			oSection1:cell("COB_RECEITA_INI"):setValue(stod(Year2Str((cAlias)->E1_EMIS1) + Month2Str((cAlias)->E1_EMIS1) + Day2Str((cAlias)->BA1_DATINC)))
            oSection1:cell("COB_RECEITA_FIM"):setValue(LastDate((cAlias)->E1_EMIS1))

           dDatePpcng := DaySum(LastDate((cAlias)->E1_EMIS1), 1)
           oSection1:cell("COB_PPCNG_INI"):setValue(dDatePpcng)
           oSection1:cell("COB_PPCNG_FIM"):setValue(stod(Year2Str(dDatePpcng) + Month2Str(dDatePpcng) + Day2Str(DaySub((cAlias)->BA1_DATINC, 1))))
            
            oSection1:printLine()

            (cAlias)->(dbSkip())
        enddo

        oSection1:finish()
    endif

    (cAlias)->(dbCloseArea())

    freeObj(oStatement)
    fwFreeArray(aFields)
    fwFreeArray(aPDFields)

return

/*/{Protheus.doc} loadStatement
Carrega o objeto oStatement (FWExecStatement) com a query do relatório
@type function
@version 12.1.2410
@author vinicius.queiros
@since 04/03/2024
@param lIsAnalytical, logical, Se o tipo do relatório é analitico
@return object, Objeto FWExecStatement
/*/
static function loadStatement(lIsAnalytical)

    local oStatement as object
    local cQuery as character
    local nOrder := 1 as numeric
    local dDate := stod(MV_PAR09 + MV_PAR08 + "01") as date

    cQuery := "SELECT ? "
	cQuery += " FROM ? BM1 "

    cQuery += " INNER JOIN ? BG9 ON "
	cQuery += " 	  BG9.BG9_FILIAL = ? AND "
	cQuery += " 	  BG9.BG9_CODINT = BM1.BM1_CODINT AND "
	cQuery += " 	  BG9.BG9_CODIGO = BM1.BM1_CODEMP AND "
	cQuery += " 	  BG9.D_E_L_E_T_ = ? "

    cQuery += " INNER JOIN ? BA1 ON "
	cQuery += " 	  BA1.BA1_FILIAL = ? AND "
	cQuery += " 	  BA1.BA1_CODINT = BM1.BM1_CODINT AND "
	cQuery += " 	  BA1.BA1_CODEMP = BM1.BM1_CODEMP AND "
    cQuery += " 	  BA1.BA1_MATRIC = BM1.BM1_MATRIC AND "
    cQuery += " 	  BA1.BA1_TIPREG = BM1.BM1_TIPREG AND "
    cQuery += " 	  BA1.BA1_DIGITO = BM1.BM1_DIGITO AND "
	cQuery += " 	  BA1.D_E_L_E_T_ = ? "

    cQuery += " INNER JOIN ? SE1 ON "
    cQuery += "       SE1.E1_FILIAL = ? AND "
    cQuery += "       SE1.E1_PREFIXO = BM1.BM1_PREFIX AND "
    cQuery += "       SE1.E1_NUM = BM1.BM1_NUMTIT AND "
    cQuery += "       SE1.E1_PARCELA = BM1.BM1_PARCEL AND " 
    cQuery += "       SE1.E1_TIPO = BM1.BM1_TIPTIT AND " 
    cQuery += "       SE1.E1_EMISSAO BETWEEN ? AND ? AND "
    cQuery += "       SE1.D_E_L_E_T_ = ? "

    cQuery += "LEFT JOIN ? BQC ON "
    cQuery += "       BQC.BQC_FILIAL = ? AND "
    cQuery += "       BQC.BQC_CODIGO = BM1.BM1_CODINT || BM1.BM1_CODEMP AND "
    cQuery += "       BQC.BQC_NUMCON = BM1.BM1_CONEMP AND "
    cQuery += "       BQC.BQC_VERCON = BM1.BM1_VERCON AND "
    cQuery += "       BQC.BQC_SUBCON = BM1.BM1_SUBCON AND "
    cQuery += "       BQC.BQC_VERSUB = BM1.BM1_VERSUB AND "
    cQuery += "       BQC.D_E_L_E_T_ = ? "

    cQuery += " WHERE BM1.BM1_FILIAL = ? AND "
    cQuery += " 	  BM1.BM1_CODINT = ? AND "
    cQuery += " 	  BM1.BM1_CODEMP >= ? AND "
    cQuery += " 	  BM1.BM1_CODEMP <= ? AND "
    cQuery += " 	  BM1.BM1_CONEMP >= ? AND "
    cQuery += " 	  BM1.BM1_CONEMP <= ? AND "
    cQuery += " 	  BM1.BM1_SUBCON >= ? AND "
    cQuery += " 	  BM1.BM1_SUBCON <= ? AND "
    cQuery += " 	  BM1.BM1_CODTIP = ? AND "
	cQuery += " 	  BM1.D_E_L_E_T_ = ? "

    if !lIsAnalytical
        cQuery += " GROUP BY ? "
    endif

	cQuery += " ORDER BY ? "

    cQuery := changeQuery(cQuery)

	oStatement := FWExecStatement():new(cQuery)

    if lIsAnalytical
        oStatement:setUnsafe(nOrder++, "BM1_CODINT, BM1_CODEMP, BM1_MATRIC, BM1_TIPREG, BM1_MES, BM1_ANO, BM1_SEQ, BM1_CHVPRO," +;
                                       "BM1_NOMUSR, BM1_VALOR, BA1_DATINC, BG9_DESCRI, BQC_DESCRI, E1_EMISSAO, E1_EMIS1, BM1_VPPCNG, BM1_VLRECE," +;
                                       "BM1_PREFIX, BM1_NUMTIT, BM1_PARCEL, BM1_TIPTIT")
    else
        oStatement:setUnsafe(nOrder++, "BM1_PREFIX, BM1_NUMTIT, BM1_PARCEL, BM1_TIPTIT, BM1_MES, BM1_ANO, BM1_CHVPRO, BG9_DESCRI, BQC_DESCRI," +;
                                       "E1_EMISSAO, E1_EMIS1, BA1_DATINC, SUM(BM1_VALOR) BM1_VALOR, SUM(BM1_VPPCNG) BM1_VPPCNG, SUM(BM1_VLRECE) BM1_VLRECE")
    endif
    
	oStatement:setUnsafe(nOrder++, retSqlName("BM1"))
    oStatement:setUnsafe(nOrder++, retSqlName("BG9"))
    oStatement:setString(nOrder++, xFilial("BG9"))
    oStatement:setString(nOrder++, " ")
    oStatement:setUnsafe(nOrder++, retSqlName("BA1"))
    oStatement:setString(nOrder++, xFilial("BA1"))
    oStatement:setString(nOrder++, " ")
    oStatement:setUnsafe(nOrder++, retSqlName("SE1"))
    oStatement:setString(nOrder++, xFilial("SE1"))
    oStatement:setString(nOrder++, dtos(firstDate(dDate)))
    oStatement:setString(nOrder++, dtos(lastDate(dDate)))
    oStatement:setString(nOrder++, " ")
    oStatement:setUnsafe(nOrder++, retSqlName("BQC"))
    oStatement:setString(nOrder++, xFilial("BQC"))
    oStatement:setString(nOrder++, " ")
	oStatement:setString(nOrder++, xFilial("BM1"))
    oStatement:setString(nOrder++, MV_PAR01)
    oStatement:setString(nOrder++, MV_PAR02)
    oStatement:setString(nOrder++, MV_PAR03)
    oStatement:setString(nOrder++, MV_PAR04)
    oStatement:setString(nOrder++, MV_PAR05)
    oStatement:setString(nOrder++, MV_PAR06)
    oStatement:setString(nOrder++, MV_PAR07)
	oStatement:setString(nOrder++, "101") // Produto/Plano (Mensalidade)
    oStatement:setString(nOrder++, " ")

    if !lIsAnalytical
        oStatement:setUnsafe(nOrder++, "BM1_PREFIX, BM1_NUMTIT, BM1_PARCEL, BM1_TIPTIT, BM1_MES, BM1_ANO, BM1_CHVPRO, BG9_DESCRI, BQC_DESCRI, E1_EMISSAO, E1_EMIS1, BA1_DATINC")
    endif

	oStatement:setUnsafe(nOrder++, "BM1_PREFIX, BM1_NUMTIT, BM1_PARCEL, BM1_TIPTIT")

return oStatement
    