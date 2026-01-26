#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINXSPD1601.CH"

Static __oQy1601T   As Object
Static __oQy1601B   As Object
Static __oQy1601A   As Object
Static __oQy1601C   As Object
Static __oQMotBxR   As Object
Static __oQMovTrR   As Object
Static __oQMovLot   As Object
Static __oQImpRet   As Object
Static __oQImpBor   As Object
Static __oQSeqBx   	As Object
Static __cBcoCart   As Char
Static __cForPgto   As Char 
Static __cCpoComp   As Char 
Static __cCpoCaix   As Char 
Static __CCPOREC1 	As Char 
Static __lBxCnab    As Logical 
Static __lSLDBXCR   As Logical
Static __cNameDB    As Char 
Static __cConcat   	As Char



//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FinSpd1601
Funcão para retornar os títulos que compoem o registro 1601 no SPED Fiscal ICMS/IPI

@param aFiliais  - Filiais a serem consideradas
@param dDtIni    - Data inicial a ser considera
@param dDtFim    - Data final a ser considera
@param cDtRegime - Data p/ o regime de caixa: 1-Data Pagamento; 2-Data da disponibilidade
@return oTmp1601 - Retorna o objeto da FwTemporaryTable com os dados

@Author	fabio.casagrande
@since	11/07/2023
/*/
//-----------------------------------------------------------------------------------------------------
Function FinSpd1601(aFiliais As Array, dDtIni As Date, dDtFim As Date, cDtRegime As Char)

	Local oTmp1601   As Object
	Local lMotInDB   As Logical
	Local cAliasTmp	 As Char
	Local aFields    As Array
	Local aParams    As Array
	Local aTamSX3Cpo As Array

	Default aFiliais  := {cFilAnt}
	Default dDtIni    := dDataBase
	Default dDtFim    := dDataBase
	Default cDtRegime := "1"

	//Atribuição padrão das variáveis 
	aTamSX3Cpo := {}
	cAliasTmp  := GetNextAlias()
	lMotInDB   := AliasInDic('F7G') .And. FindFunction("F490Sync") .And. F7G->(FieldPos("F7G_FORMRC")) > 0
	aParams    := {aFiliais, dDtIni, dDtFim, cDtRegime}

	FinIniVar()

	If !lMotInDB
		Help(" ",1,"F1601DESATU",, STR0001, 1, 0,,,,,, {STR0002}) // Módulo Financeiro desatualizado para uso dessa funcionalidade. ## Necessário que a tabela F7G seja criada.
	Else
		oTmp1601 := F1601TabA(cAliasTmp, @aFields) //Cria a estrutura da tabela temporária
		F1601TabB(oTmp1601, aParams, aFields) //Alimenta a tabela temporária
		SPDSetField(aFields, cAliasTmp) //Trata campos com TCSETFIELD
		F1601TabC(cAliasTmp, aParams) //Tratamentos complementares para os registros
	EndIf
	
	FwFreeArray(aFields)
	FwFreeArray(aParams)

Return oTmp1601

/*/{Protheus.doc} F1601TabA
    Cria a tabela temporaria para gerar o registro 1601 do SPED Fiscal ICMS/IPI
    @type  Static Function
	@param cAliasTmp - Alias da tabela temporária
	@param aFields   - Array da estrutura da temporaria
    @author fabio.casagrande
    @since 12/07/2023
    @version 1.0
    @return oTable
/*/
Static Function F1601TabA(cAliasTmp As Char, aFields As Array) As Object
    Local nTamData 	As Numeric
	Local nTamBco 	As Numeric
    Local nTamVal 	As Numeric
    Local nDecVal 	As Numeric
	Local oTable 	As Object

	Default cAliasTmp := GetNextAlias()
	Default aFields   := {}

    nTamData := TamSX3("E1_EMISSAO")[1]
    nTamVal  := TamSX3("E1_VALOR")[1]
    nDecVal  := TamSX3("E1_VALOR")[2]
	nTamBco	 := TamSX3("A6_COD")[1]+TamSX3("A6_AGENCIA")[1]+TamSX3("A6_NUMCON")[1]

    aFields := {{"REGIME"		, "C" , 11		                  ,  0},;
				{"BANCO" 		, "C" , nTamBco				      ,  0},;
				{"CNPJBCO" 		, "C" , TamSX3("A6_CGC")[1]       ,  0},;
                {"FILORIG"		, "C" , TamSX3("E1_FILORIG")[1]   ,  0},;
                {"DT_EMISSAO"  	, "D" , nTamData                  ,  0},;
                {"ORIGEM"   	, "C" , TamSX3("E1_ORIGEM")[1]    ,  0},;
                {"PREFIXO" 		, "C" , TamSX3("E1_PREFIXO")[1]   ,  0 },;
                {"NUMERO" 		, "C" , TamSX3("E1_NUM")[1]   	  ,  0 },;
                {"TIPO" 		, "C" , TamSX3("E1_TIPO")[1]   	  ,  0 },;
                {"PARCELA"   	, "C" , TamSX3("E1_PARCELA")[1]   ,  0 },;
				{"SITUACAO"   	, "C" , TamSX3("E1_SITUACA")[1]   ,  0 },;
				{"SALDO"   		, "N" , nTamVal                   ,  nDecVal},;
				{"IDDOC"   		, "C" , TamSX3("FK7_IDDOC")[1]    ,  0 },;
                {"CLIFOR"   	, "C" , TamSX3("E1_CLIENTE")[1]   ,  0 },;
				{"LOJA"   		, "C" , TamSX3("E1_LOJA")[1]      ,  0 },;
				{"CODBAR"  		, "C" , TamSX3("E1_CODBAR")[1]    ,  0 },;
				{"E1_NUMNOTA"	, "C" , TamSX3("E1_NUMNOTA")[1]   ,  0},;
				{"E1_SERIE"		, "C" , TamSX3("E1_SERIE")[1]     ,  0},;
				{"INTERMED"   	, "C" , TamSX3("F2_CODA1U")[1]    ,  0 },;
				{"VALOR"   		, "N" , nTamVal                   ,  nDecVal},;
				{"DT_BAIXA" 	, "D" , nTamData                  ,  0},;
				{"MOTBX"   		, "C" , 12    					  ,  0 },;
				{"LOTEFIN" 		, "C" , TamSX3("FK5_LOTE")[1]     ,  0 },;
				{"IDBAIXA" 		, "C" , TamSX3("FK4_IDORIG")[1]   ,  0 },;
				{"FORMA_PGTO"   , "C" , TamSX3("F7G_FORMRC")[1]   ,  0 },;
				{"MOEDA"   		, "N" , nTamVal                   ,  nDecVal},;
				{"TXMOEDA" 		, "N" , nTamVal                   ,  nDecVal},;
				{"FILIAL"		, "C" , TamSX3("E1_FILIAL")[1]    ,  0},;
				{"NUMBOR"   	, "C" , TamSX3("EA_NUMBOR")[1]    ,  0},;
				{"EA_ORIGEM"   	, "C" , TamSX3("EA_ORIGEM")[1]    ,  0},;
				{"SEQBX"		, "C" , TamSX3("FK1_SEQ")[1]      ,  0};
				}

    oTable := FWTemporaryTable():New(cAliasTmp)
    oTable:SetFields(aFields)
    oTable:AddIndex("1",{"REGIME" , "BANCO"   , "FILORIG"})
    oTable:AddIndex("2",{"FILORIG", "REGIME"  , "BANCO"})
    oTable:AddIndex("3",{"FILORIG", "BANCO"   , "REGIME"  })
    oTable:AddIndex("4",{"BANCO"  , "REGIME"  , "FILORIG"})
	oTable:AddIndex("5",{"REGIME"  , "FILORIG"})
    oTable:Create()

Return oTable

/*/{Protheus.doc} F1601TabB
    Alimenta a tabela temporaria para gerar o registro 1601 do SPED Fiscal ICMS/IPI
    @type  Static Function
	@param oTable  - Objeto da FwTemporaryTable a ser alimentada
	@param aParams - Parâmetrização passada pela rotina do SPED
	@param aFields - Array da estrutura da temporaria
	@return nil
    @author fabio.casagrande
    @since 12/07/2023
/*/
Static Function F1601TabB(oTable As Object, aParams As Array, aFields As Array )
	Local nLoop 	As Numeric
	Local cFields 	As Char

	Default oTable  := Nil
	Default aFields := {}
	Default aParams :=  { {}, dDatabase, dDatabase, "" }


	cFields := ""

	//Obtem as colunas da temporaria para o insert
	For nLoop := 1 to Len(aFields)
		cFields += aFields[nLoop][1] + ","//Nome do campo
	Next
	
	cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula

	F1601QTit(oTable, cFields, aFields, aParams) //Query de contas a receber (regime de apuração competencia)
	F1601QBxR(oTable, cFields, aFields, aParams) //Query de baixas a receber (regime de apuração caixa)
	F1601QAdt(oTable, cFields, aFields, aParams) //Adiantamento de contas a receber (regime de apuração caixa)
	If __lSLDBXCR
		F1601QChC(oTable, cFields, aFields, aParams) //Cheques compensados de contas a receber (regime de apuração caixa)
	EndIf

Return

/*/{Protheus.doc} F1601QTit
    Query de contas a receber (regime de apuração competencia)
    @type  Static Function
	@param oTable  - Objeto da FwTemporaryTable a ser alimentada
	@param cFields - Colunas da tab. temporária separadas por virgula
	@param aFields - Colunas da tab. temporária em array
	@param aParams - Parâmetrização passada pela rotina do SPED
	@return nil
    @author fabio.casagrande
    @since 12/07/2023
/*/
Static Function F1601QTit(oTable As Object, cFields As Char, aFields As Array, aParams As Array)
	Local cQuery     As Char
	Local cAliasQry  As Char
	Local cSitBco    As Char
	Local cModeAcSE1 As Char
	Local cModeAcSF2 As Char
	Local cFormatIn  As Char
	Local cFormatInB As Char
	Local aFilQry    As Array
	Local dDtIni     As Date
	Local dDtFim     As Date
	Local nError   	 As Numeric
	Local nParam	 As Numeric

	Default oTable  := Nil
	Default cFields := ""
	Default aFields := {}
	Default aParams :=  { {}, dDatabase, dDatabase, "" }

	cModeAcSE1		:= FWModeAccess("SE1",3)
	cModeAcSF2		:= FWModeAccess("SF2",3)

	cAliasQry := GetNextAlias()
	aFilQry   := aParams[1] 
	dDtIni    := aParams[2] 
	dDtFim    := aParams[3] 
	cSitBco	  := FN022LSTCB(3)
	nError	  := 0
	nParam	  := 1

	cFormatIn	:= FormatIn(MVABATIM+"|"+MVPROVIS+"|"+MV_CRNEG+"|"+MVRECANT+"|"+"SES","|")
	cFormatInB	:= FormatIn(cSitBco,"|")

	If __oQy1601T == Nil	

		cQuery := " SELECT ? " + " ? "  // 1,2
		cQuery += " COALESCE( SF2.F2_CODA1U,' ') INTERMED, SE1.E1_VALOR VALOR, "
		cQuery += " SE1.E1_BAIXA DT_BAIXA, " 
		cQuery += " ' ' MOTBX, ' ' LOTEFIN, ' ' IDBAIXA, " 
		cQuery += "		COALESCE(SX5.X5_CHAVE,' ')  FORMA_PGTO, "
		cQuery += "	SE1.E1_MOEDA MOEDA, SE1.E1_TXMOEDA TXMOEDA, SE1.E1_FILIAL FILIAL, "
		cQuery += "	COALESCE(SEA.EA_NUMBOR,' ') NUMBOR, COALESCE(SEA.EA_ORIGEM,' ') EA_ORIGEM, "
		cQuery += "	' ' SEQBX "
		cQuery += "	FROM ? SE1 " // 3
		
		If cModeAcSE1 == "C" .And. cModeAcSF2 == 'E'
			cQuery += "	LEFT JOIN ? SF2 ON SF2.F2_FILIAL = SE1.E1_FILORIG " //4
		Else  
			cQuery += "	LEFT JOIN ? SF2 ON " + FWJoinFilial("SF2", "SE1") // 4
		Endif
		
		cQuery += "		AND SE1.E1_NUM = SF2.F2_DOC AND SE1.E1_SERIE = SF2.F2_SERIE AND SF2.D_E_L_E_T_ = ? " //5
		cQuery += "	INNER JOIN ? FK7 ON FK7.FK7_ALIAS = ? " // 6,7
		cQuery += "	    AND FK7.FK7_FILTIT = SE1.E1_FILIAL AND FK7.FK7_PREFIX = SE1.E1_PREFIXO "
		cQuery += "	    AND FK7.FK7_NUM = SE1.E1_NUM AND FK7.FK7_PARCEL = SE1.E1_PARCELA "
		cQuery += "	    AND FK7.FK7_TIPO = SE1.E1_TIPO AND FK7.FK7_CLIFOR = SE1.E1_CLIENTE "
		cQuery += "	    AND FK7.FK7_LOJA = SE1.E1_LOJA "
		cQuery += "	AND FK7.D_E_L_E_T_ = ? " // 8
		cQuery += "	INNER JOIN ? FKF ON " + FWJoinFilial("FKF", "FK7") // 9
		cQuery += "	AND FK7.FK7_IDDOC = FKF.FKF_IDDOC AND FKF.FKF_ESPEC IN (' ', 'N') "
		cQuery += "	AND FKF.D_E_L_E_T_ = ? " // 10
		cQuery += "	LEFT JOIN ?  F71 ON " + FWJoinFilial("F71", "FK7") // 11
		cQuery += "	AND FK7.FK7_IDDOC = F71.F71_IDDOC AND F71.F71_STATUS IN ('2','3','4') "
		cQuery += "	AND F71.F71_SOLCAN = '2'  AND F71.D_E_L_E_T_ = ? " // 12
		cQuery += "	LEFT JOIN ? SE4 ON " + FWJoinFilial("SE4", "SF2") //SE4.E4_FILIAL = SF2.F2_FILIAL " 13
		cQuery += "		AND SE4.E4_CODIGO = SF2.F2_COND AND SE4.D_E_L_E_T_ = ? " // 14
		cQuery += "	LEFT JOIN ? SEA ON SEA.EA_CART = 'R' AND " + FWJoinFilial("SEA", "SE1") //SEA.EA_FILIAL = SE1.E1_FILIAL " 15
		cQuery += "	    AND SEA.EA_PREFIXO = SE1.E1_PREFIXO AND SEA.EA_NUM = SE1.E1_NUM "
		cQuery += "	    AND SEA.EA_PARCELA = SE1.E1_PARCELA	AND SEA.EA_TIPO = SE1.E1_TIPO AND SEA.D_E_L_E_T_ = ? " // 16
		cQuery += "	INNER JOIN ? SA6 ON " + FWJoinFilial("SA6", "SE1") // 17
		cQuery += "	    AND (SA6.A6_COD = SE1.E1_PORTADO OR SA6.A6_COD = SEA.EA_PORTADO 
		cQuery += "	    OR SA6.A6_COD = F71.F71_CODBAN) "
		cQuery += "	    AND (SA6.A6_AGENCIA = SE1.E1_AGEDEP  OR SA6.A6_AGENCIA = SEA.EA_AGEDEP
		cQuery += "	 	OR SA6.A6_AGENCIA = F71.F71_AGENCI )"
		cQuery += "	    AND (SA6.A6_NUMCON = SE1.E1_NUMCON  OR SA6.A6_NUMCON = SEA.EA_NUMCON "
		cQuery += "	 	OR SA6.A6_NUMCON = F71.F71_NUMCON)"
		cQuery += "	    AND SA6.A6_COD NOT IN ? " // 18
		cQuery += "	    AND SA6.A6_MOEDA = ? " // 19
		cQuery += "	    AND SA6.D_E_L_E_T_ = ? " //20
		cQuery += "	LEFT JOIN ? SX5 ON SX5.X5_FILIAL = ? " // 21, 22
		cQuery += "	    AND SX5.X5_TABELA = '24' AND (X5_CHAVE = SE4.E4_FORMA OR X5_CHAVE = SE1.E1_TIPO) "
		cQuery += "	    AND X5_CHAVE NOT IN ? " // 23
		cQuery += "	    AND SX5.D_E_L_E_T_ = ? " // 24
		cQuery += "	WHERE "
		cQuery += "	    SE1.E1_FILORIG IN ( ? ) AND SE1.E1_EMISSAO BETWEEN ? AND ? AND SE1.D_E_L_E_T_ = ? " // 25, 26, 27, 28
		cQuery += "	    AND SE1.E1_TIPO NOT IN ? " // 29
		cQuery += "	    AND SE1.E1_SITUACA IN ? " // 30
		cQuery += "	    AND SE1.E1_TIPOLIQ = ' ' "
		cQuery += "	    AND SE1.R_E_C_N_O_ NOT IN ( "
		cQuery += "	    		SELECT SE1_L.R_E_C_N_O_ FROM ? SE1_L " //31
		cQuery += "	    		WHERE SE1_L.E1_FILORIG IN ( ? ) AND SE1_L.E1_EMISSAO BETWEEN ? AND ? " // 32, 33, 34
		cQuery += "		AND SE1_L.E1_TIPO NOT IN ('PX') AND SE1_L.E1_ORIGEM LIKE 'LOJ%'  "
		cQuery += "	    AND SE1_L.D_E_L_E_T_ = ' ')  "

		cQuery := ChangeQuery( cQuery )

         __oQy1601T := FWPreparedStatement():New(cQuery)
	EndIf

	__oQy1601T:SetUnsafe(nParam++, __cCpoComp) // 1
	__oQy1601T:SetUnsafe(nParam++, __cCpoRec1) // 2
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("SE1")) // 3
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("SF2")) // 4
	__oQy1601T:SetString(nParam++, ' ') // 5
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("FK7")) // 6
	__oQy1601T:SetString(nParam++, 'SE1') // 7
	__oQy1601T:SetString(nParam++, ' ') // 8
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("FKF")) // 9
	__oQy1601T:SetString(nParam++, ' ') // 10
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("F71")) // 11
	__oQy1601T:SetString(nParam++, ' ') // 12
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("SE4")) // 13
	__oQy1601T:SetString(nParam++, ' ') // 14
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("SEA")) // 15
	__oQy1601T:SetString(nParam++, ' ') // 16
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("SA6")) // 17
	__oQy1601T:SetUnsafe(nParam++, __cBcoCart) // 18
	__oQy1601T:SetString(nParam++, '1') // 19
	__oQy1601T:SetString(nParam++, ' ') // 20
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("SX5")) // 21
	__oQy1601T:SetString(nParam++, xFilial("SX5")) //X5_FILIAL 22
	__oQy1601T:SetUnsafe(nParam++, __cForPgto) // 23
	__oQy1601T:SetString(nParam++, ' ') // 24
	__oQy1601T:SetIn(nParam++, aFilQry ) //E1_FILORIG 25
	__oQy1601T:SetString(nParam++, Dtos(dDtIni)) //E1_EMISSAO 26
	__oQy1601T:SetString(nParam++, Dtos(dDtFim)) //E1_EMISSAO 27
	__oQy1601T:SetString(nParam++, ' ') // 28
	__oQy1601T:SetUnsafe(nParam++, cFormatIn) // 29
	__oQy1601T:SetUnsafe(nParam++, cFormatInB) // 30
	__oQy1601T:SetUnsafe(nParam++, RetSqlName("SE1")) // 31	
	__oQy1601T:SetIn(nParam++, aFilQry ) //E1_FILORIG 32
	__oQy1601T:SetString(nParam++, Dtos(dDtIni)) //E1_EMISSAO 33
	__oQy1601T:SetString(nParam++, Dtos(dDtFim)) //E1_EMISSAO 34

	cQuery := __oQy1601T:GetFixQuery()

	/*--------------------------------------------------|
	| PE recebe a query padrao, permitindo modificacoes | 
	| nas regras de filtro. Substitui a query padrao	|
	---------------------------------------------------*/
	If ExistBlock("F16QYCRT")   			
		cQuery := ExecBlock("F16QYCRT",.F.,.F.,{cQuery})
	EndIf		

	nError:= TcSQLExec("INSERT INTO " + oTable:GetRealName() + " (" + cFields + ") " + cQuery + " " )
	If nError < 0
		UserException(TCSQLError())
	EndIf
Return

/*/{Protheus.doc} F1601QBxR
    Query de contas a receber (regime de apuração caixa)
    @type  Static Function
	@param oTable  - Objeto da FwTemporaryTable a ser alimentada
	@param cFields - Colunas da tab. temporária separadas por virgula
	@param aFields - Colunas da tab. temporária em array
	@param aParams - Parâmetrização passada pela rotina do SPED
	@return nil
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function F1601QBxR(oTable As Object, cFields As Char, aFields As Array, aParams As Array)
	Local cQuery     As Char
	Local cAliasQry  As Char
	Local cModeAcSE1 As Char
	Local cModeAcSF2 As Char
	Local cModeAcSA6 As Char
	Local cModeAcFK5 As Char
	Local cModeAcSEA As Char
	Local cFormatIn  As Char
	Local cQryBind1	 As Char
	Local cQryBind2	 As Char
	Local aFilQry    As Array
	Local dDtIni     As Date
	Local dDtFim     As Date
	Local lDtPagto   As Logical
	Local nError	 As Numeric
	Local nParam	 As Numeric

	Default oTable  := Nil
	Default cFields := ""
	Default aFields := {}
	Default aParams := { {}, dDatabase, dDatabase, "" }

	cModeAcSE1		:= FWModeAccess("SE1",3)
	cModeAcSF2		:= FWModeAccess("SF2",3)
	cModeAcSA6		:= FWModeAccess("SA6",3)
	cModeAcFK5		:= FWModeAccess("FK5",3)
	cModeAcSEA		:= FWModeAccess("SEA",3)

	cAliasQry := GetNextAlias()
	aFilQry   := aParams[1] 
	dDtIni    := aParams[2] 
	dDtFim    := aParams[3] 
	lDtPagto  := aParams[4] == "1" //1= Data de Pagamento ou 2 = Data de disponibilidade
	nError	  := 0
	nParam	  := 1

	cFormatIn	:= FormatIn(MVABATIM+"|"+MVPROVIS+"|"+MV_CRNEG+"|"+MVRECANT+"|"+"SES","|")

	cQryBind1 	:= FWJoinFilial("SA6", "FK5")
	cQryBind2 	:= FWJoinFilial("SA6", "SEA")

	If cModeAcSA6 == "E" .And. cModeAcFK5 == "C"
		cQryBind1 := "SA6.A6_FILIAL = FK5.FK5_FILORI"
	Endif

	If cModeAcSA6 == "E" .And. cModeAcSEA == "C"
		cQryBind2 := "SA6.A6_FILIAL = SEA.EA_FILORIG"
	Endif

	If __oQy1601B == Nil	

		cQuery := " SELECT ? " + " ? " // 1, 2
		cQuery += "	COALESCE( SF2.F2_CODA1U,' ') INTERMED, FK1.FK1_VALOR VALOR, "
		If lDtPagto
			cQuery += " 	FK1.FK1_DATA DT_BAIXA, "	
		Else
			cQuery += " 	FK1.FK1_DTDISP DT_BAIXA, "	
		EndIf
		cQuery += "		COALESCE(FK1.FK1_MOTBX, ' ') MOTBX, "
		cQuery += "		COALESCE( FK1.FK1_LOTE,' ') LOTEFIN, "
		cQuery += "		FK1.FK1_IDFK1 IDBAIXA, "
		cQuery += "		COALESCE(SX5.X5_CHAVE,' ')  FORMA_PGTO, "
		cQuery += " 	CAST(FK1.FK1_MOEDA AS INT) MOEDA, FK1.FK1_TXMOED TXMOEDA, "
		cQuery += " 	FK1.FK1_FILIAL FILIAL, "
		cQuery += "		COALESCE(SEA.EA_NUMBOR,' ') NUMBOR, COALESCE(SEA.EA_ORIGEM,' ') EA_ORIGEM, "
		cQuery += "		FK1.FK1_SEQ SEQBX "	
		cQuery += "	FROM ? SE1 " // 3
		
		If cModeAcSE1 == "C" .And. cModeAcSF2 == 'E'
			cQuery += "	LEFT JOIN ? SF2 ON SF2.F2_FILIAL = SE1.E1_FILORIG " // 4
		Else 
			cQuery += "	LEFT JOIN ? SF2 ON " + FWJoinFilial("SF2", "SE1") // 4
		Endif
		
		cQuery += "		AND SF2.F2_DOC = (CASE WHEN SE1.E1_ORIGEM LIKE 'LOJ%' THEN SE1.E1_NUMNOTA ELSE SE1.E1_NUM END) "
		cQuery += "		AND SE1.E1_SERIE = SF2.F2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN ? FK7 ON FK7.FK7_ALIAS = 'SE1' " // 5
		cQuery += "	    AND FK7.FK7_FILTIT = SE1.E1_FILIAL AND FK7.FK7_PREFIX = SE1.E1_PREFIXO "
		cQuery += "	    AND FK7.FK7_NUM = SE1.E1_NUM AND FK7.FK7_PARCEL = SE1.E1_PARCELA "
		cQuery += "	    AND FK7.FK7_TIPO = SE1.E1_TIPO AND FK7.FK7_CLIFOR = SE1.E1_CLIENTE "
		cQuery += "	    AND FK7.FK7_LOJA = SE1.E1_LOJA AND FK7.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN ?  FKF ON " + FWJoinFilial("FKF", "FK7") // 6
		cQuery += "	AND FK7.FK7_IDDOC = FKF.FKF_IDDOC AND FKF_ESPEC IN (' ', 'N') "
		cQuery += "	AND FKF.D_E_L_E_T_ = ? " // 7
		cQuery += "	LEFT JOIN ? SEA ON SEA.EA_CART = 'R' AND " + FWJoinFilial("SEA", "SE1") //SEA.EA_FILIAL = SE1.E1_FILIAL " // 8
		cQuery += "	    AND SEA.EA_PREFIXO = SE1.E1_PREFIXO AND SEA.EA_NUM = SE1.E1_NUM "
		cQuery += "	    AND SEA.EA_PARCELA = SE1.E1_PARCELA	AND SEA.EA_TIPO = SE1.E1_TIPO AND SEA.D_E_L_E_T_ = ? " // 9
		cQuery += "	INNER JOIN ? FK1 ON " + FWJoinFilial("FK1", "FK7") // 10
		cQuery += "	    AND FK1.D_E_L_E_T_ = ? AND FK1.FK1_IDDOC = FK7.FK7_IDDOC AND FK1.FK1_FILORI IN ( ? ) " // 11, 12
		cQuery += "	    AND NOT EXISTS( 
		cQuery += "	    	SELECT FK1EST.FK1_IDDOC FROM ? FK1EST " // 13
		cQuery += "	    	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
		cQuery += "	    	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ AND FK1EST.FK1_TPDOC = 'ES' AND FK1EST.D_E_L_E_T_ = ? ) " // 14
		cQuery += "	INNER JOIN ? FKA ON " + FWJoinFilial("FKA", "FK1") // 15
		cQuery += "	    AND FKA.FKA_IDORIG = FK1.FK1_IDFK1 "
		cQuery += "	    AND FKA.FKA_TABORI = 'FK1' AND FKA.D_E_L_E_T_ = ? " // 16
		cQuery += "	LEFT JOIN ? FKA2 ON FKA.FKA_FILIAL =  FKA2.FKA_FILIAL " // 17
		cQuery += "	    AND FKA.FKA_IDPROC = FKA2.FKA_IDPROC "
		cQuery += "	    AND FKA2.FKA_TABORI = 'FK5' AND FKA2.D_E_L_E_T_ = ? " // 18
		cQuery += "	LEFT JOIN ? FK5 ON " + FWJoinFilial("FK5", "FKA") // 19
		cQuery += "	    AND FK5.D_E_L_E_T_ = ? AND FKA2.FKA_IDORIG = FK5.FK5_IDMOV AND FK5.FK5_FILORI IN ( ? ) " // 20, 21
		cQuery += "	    AND NOT EXISTS( SELECT "
		cQuery += "	    	FK5EST.FK5_IDMOV FROM ? FK5EST " // 22
		cQuery += "	    	WHERE FK5EST.FK5_FILIAL = FK5.FK5_FILIAL AND FK5EST.FK5_IDMOV = FKA2.FKA_IDORIG "
		cQuery += "	    	AND FK5EST.FK5_SEQ = FK5.FK5_SEQ AND FK5EST.FK5_TPDOC = 'ES' AND FK5EST.D_E_L_E_T_ = ? ) " // 23

		cQuery += "	LEFT JOIN ? SA6 ON ( ?  OR  ? ) " // 24, 25, 26

		cQuery += "	    AND (SA6.A6_COD = SEA.EA_PORTADO OR SA6.A6_COD = FK5.FK5_BANCO) "
		cQuery += "	    AND (SA6.A6_AGENCIA = SEA.EA_AGEDEP OR SA6.A6_AGENCIA = FK5.FK5_AGENCI) "
		cQuery += "	    AND (SA6.A6_NUMCON = SEA.EA_NUMCON  OR SA6.A6_NUMCON = FK5.FK5_CONTA) "
		cQuery += "	    AND SA6.A6_COD NOT IN ? " // 27
		cQuery += "	    AND SA6.A6_MOEDA = 1 "
		cQuery += "	    AND SA6.D_E_L_E_T_ = ? " // 30
		cQuery += "	INNER JOIN ? F7G ON " + FWJoinFilial("F7G", "FK1") // 29
		cQuery += "	    AND F7G.F7G_SIGLA = FK1.FK1_MOTBX "
		cQuery += "	    AND F7G.D_E_L_E_T_ = ? " // 28
		cQuery += "	    AND F7G.F7G_MOVBCO = 'S' "
		cQuery += "	    AND F7G.F7G_FORMRC <> ' ' "
		cQuery += "	    AND F7G_ESPEC IN (' ', 'N') "
		cQuery += "	INNER JOIN ? SX5 ON SX5.X5_FILIAL = ? " // 31, 32
		cQuery += "	    AND SX5.X5_TABELA = '24' AND SX5.X5_CHAVE = F7G.F7G_FORMRC "
		cQuery += "	    AND X5_CHAVE NOT IN ? " // 33
		cQuery += "	    AND SX5.D_E_L_E_T_ = ? " // 34
		cQuery += "	WHERE "
		cQuery += "	    SE1.E1_FILORIG IN ( ? ) " // 35
		If lDtPagto
			cQuery += "	    AND FK1.FK1_DATA BETWEEN ? AND ? " // 36, 35
		Else
			cQuery += "	    AND FK1.FK1_DTDISP BETWEEN ? AND ? " // 34, 37
		EndIf
		cQuery += "	   AND SE1.D_E_L_E_T_ = ? " // 38

		cQuery += "	    AND SE1.E1_TIPO NOT IN ? " // 39

		/*--------------------------------------------------|
		| PE recebe a query padrao, permitindo modificacoes | 
		| nas regras de filtro. Substitui a query padrao	|
		---------------------------------------------------*/
		If ExistBlock("F16QYCRB")                       			
			cQuery := ExecBlock("F16QYCRB",.F.,.F.,{cQuery})
		EndIf	

		cQuery := ChangeQuery( cQuery )

         __oQy1601B := FWPreparedStatement():New(cQuery)
	EndIf

	__oQy1601B:SetUnsafe(nParam++, __cCpoCaix) // 1
	__oQy1601B:SetUnsafe(nParam++, __cCpoRec1) // 2
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("SE1")) // 3
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("SF2")) // 4
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FK7")) // 5
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FKF")) // 6
	__oQy1601B:SetString(nParam++, ' ') // 7
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("SEA")) // 8
	__oQy1601B:SetString(nParam++, ' ') // 9
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FK1")) // 10
	__oQy1601B:SetString(nParam++, ' ') // 11
	__oQy1601B:SetIn(nParam++, aFilQry ) //FK1_FILORIG 12
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FK1") ) // 13
	__oQy1601B:SetString(nParam++, ' ') // 14
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FKA") ) // 15
	__oQy1601B:SetString(nParam++, ' ') // 16
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FKA") ) // 17
	__oQy1601B:SetString(nParam++, ' ') // 18
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FK5") ) // 19
	__oQy1601B:SetString(nParam++, ' ') // 20
	__oQy1601B:SetIn(nParam++, aFilQry ) //FK5_FILORIG 21
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("FK5") ) // 22
	__oQy1601B:SetString(nParam++, ' ') // 23
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("SA6") ) // 24
	__oQy1601B:SetUnsafe(nParam++, cQryBind1 ) // 25
	__oQy1601B:SetUnsafe(nParam++, cQryBind2 ) // 26
	__oQy1601B:SetUnsafe(nParam++, __cBcoCart ) // 27
	__oQy1601B:SetString(nParam++, ' ') // 28
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("F7G") ) // 29
	__oQy1601B:SetString(nParam++, ' ') // 30
	__oQy1601B:SetUnsafe(nParam++, RetSqlName("SX5") ) // 31
	__oQy1601B:SetString(nParam++, xFilial("SX5")) //X5_FILIAL 32
	__oQy1601B:SetUnsafe(nParam++, __cForPgto ) // 33
	__oQy1601B:SetString(nParam++, ' ') // 34
	__oQy1601B:SetIn(nParam++, aFilQry ) //E1_FILORIG 35
	__oQy1601B:SetString(nParam++, Dtos(dDtIni)) //FK1_DATA OU FK1_DTDISP 36
	__oQy1601B:SetString(nParam++, Dtos(dDtFim)) //FK1_DATA OU FK1_DTDISP 37
	__oQy1601B:SetString(nParam++, ' ') // 38
	__oQy1601B:SetUnsafe(nParam++, cFormatIn ) // 39

	cQuery := __oQy1601B:GetFixQuery()

	nError:= TcSQLExec("INSERT INTO " + oTable:GetRealName() + " (" + cFields + ") " + cQuery + " " )
	
	If nError < 0
		UserException(TCSQLError())
	EndIf

Return

/*/{Protheus.doc} F1601QAdt
    Query de contas a receber de adiantamento (regime de apuração caixa)
    @type  Static Function
	@param oTable  - Objeto da FwTemporaryTable a ser alimentada
	@param cFields - Colunas da tab. temporária separadas por virgula
	@param aFields - Colunas da tab. temporária em array
	@param aParams - Parâmetrização passada pela rotina do SPED
	@return nil
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function F1601QAdt(oTable As Object, cFields As Char, aFields As Array, aParams As Array)
	Local cQuery    As Char
	Local cAliasQry As Char
	Local aFilQry   As Array
	Local dDtIni    As Date
	Local dDtFim    As Date
	Local nError	As Numeric
	Local lDtPagto	As Logical

	Default oTable  := Nil
	Default cFields := ""
	Default aFields := {}
	Default aParams :=  { {}, dDatabase, dDatabase, "" }

	cAliasQry := GetNextAlias()
	aFilQry   := aParams[1] 
	dDtIni    := aParams[2] 
	dDtFim    := aParams[3] 
	lDtPagto  := aparams[4] == "1"
	nError	  := 0

	If __oQy1601A == Nil	
		
		cQuery := " SELECT " + __cCpoCaix + __cCpoRec1
		cQuery += "		' ' INTERMED, SE1.E1_VALOR VALOR, "
		If lDtPagto
			cQuery += "	FK5.FK5_DATA   DT_BAIXA,  "
		Else
			cQuery += "	FK5.FK5_DTDISP DT_BAIXA, "
		EndIf
		cQuery += "		'ADIANTAMENTO' MOTBX, "
		cQuery += "		' ' LOTEFIN, ' ' IDBAIXA, "
		cQuery += "		COALESCE(CASE WHEN FK5.FK5_NUMCH NOT IN (' ') THEN 'CH' ELSE 'DC' END, ' ') FORMA_PGTO, "
		cQuery += " 	CAST(COALESCE(FK5.FK5_MOEDA, '1') AS INT) MOEDA, COALESCE(FK5.FK5_TXMOED, 0) TXMOEDA, "
		cQuery += "		SE1.E1_FILIAL FILIAL, ' ' NUMBOR, ' ' EA_ORIGEM, ' ' SEQBX "
		cQuery += "	FROM " + RetSqlName("SE1") + " SE1 "
		cQuery += "	INNER JOIN " + RetSqlName("FK7") + " FK7 ON FK7.FK7_ALIAS = 'SE1' "
		cQuery += "	    AND FK7.FK7_FILTIT = SE1.E1_FILIAL AND FK7.FK7_PREFIX = SE1.E1_PREFIXO "
		cQuery += "	    AND FK7.FK7_NUM = SE1.E1_NUM AND FK7.FK7_PARCEL = SE1.E1_PARCELA "
		cQuery += "	    AND FK7.FK7_TIPO = SE1.E1_TIPO AND FK7.FK7_CLIFOR = SE1.E1_CLIENTE "
		cQuery += "	    AND FK7.FK7_LOJA = SE1.E1_LOJA AND FK7.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN " + RetSqlName("FKF") + "  FKF ON " + FWJoinFilial("FKF", "FK7") 
		cQuery += "	AND FK7.FK7_IDDOC = FKF.FKF_IDDOC AND FKF_ESPEC IN (' ', 'N') "
		cQuery += "	AND FKF.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN " + RetSqlName("FK5") + " FK5 ON " + FWJoinFilial("FK5", "FK7") "
		cQuery += "	    AND FK5.D_E_L_E_T_ = ' ' AND FK5.FK5_IDDOC = FK7.FK7_IDDOC AND FK5.FK5_FILORI IN ( ? ) "
		cQuery += "	INNER JOIN " + RetSqlName("SA6") + " SA6 ON " + FWJoinFilial("SA6", "FK5")
		cQuery += "	    AND SA6.A6_COD = FK5.FK5_BANCO "
		cQuery += "	    AND SA6.A6_AGENCIA = FK5.FK5_AGENCI "
		cQuery += "	    AND SA6.A6_NUMCON = FK5.FK5_CONTA "
		cQuery += "	    AND SA6.A6_COD NOT IN "+__cBcoCart+ " "
		cQuery += "	    AND SA6.A6_MOEDA = 1 "
		cQuery += "	    AND SA6.D_E_L_E_T_ = ' ' "
		cQuery += "	WHERE "
		cQuery += "	    SE1.E1_FILORIG IN ( ? ) AND SE1.E1_EMISSAO BETWEEN ? AND ? AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += "	    AND SE1.E1_TIPO IN "+FormatIn(MVRECANT,"|")  + " "
		

		/*--------------------------------------------------|
		| PE recebe a query padrao, permitindo modificacoes | 
		| nas regras de filtro. Substitui a query padrao	|
		---------------------------------------------------*/
		If ExistBlock("F16QYCRA")                        			
			cQuery := ExecBlock("F16QYCRA",.F.,.F.,{cQuery})
		EndIf	

		cQuery := ChangeQuery( cQuery )

         __oQy1601A := FWPreparedStatement():New(cQuery)
	EndIf

	__oQy1601A:SetIn(1, aFilQry )			//FK5_FILORIG
	__oQy1601A:SetIn(2, aFilQry )			//E1_FILORIG
	__oQy1601A:SetString(3, Dtos(dDtIni))   //E1_EMISSAO
	__oQy1601A:SetString(4, Dtos(dDtFim))	//E1_EMISSAO

	cQuery := __oQy1601A:GetFixQuery()

	nError:= TcSQLExec("INSERT INTO " + oTable:GetRealName() + " (" + cFields + ") " + cQuery + " " )
	
	If nError < 0
		UserException(TCSQLError())
	EndIf

Return

/*/{Protheus.doc} F1601QChC
    Query de contas a receber de títulos compensados (regime de apuração caixa)
    @type  Static Function
	@param oTable  - Objeto da FwTemporaryTable a ser alimentada
	@param cFields - Colunas da tab. temporária separadas por virgula
	@param aFields - Colunas da tab. temporária em array
	@param aParams - Parâmetrização passada pela rotina do SPED
	@return nil
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function F1601QChC(oTable As Object, cFields As Char, aFields As Array, aParams As Array)
	Local cQuery    As Char
	Local cAliasQry As Char
	Local aFilQry   As Array
	Local dDtIni    As Date
	Local dDtFim    As Date
	Local lDtPagto	As Logical
	Local nError	As Numeric

	Default oTable  := Nil
	Default cFields := ""
	Default aFields := {}
	Default aParams := { {}, dDatabase, dDatabase, "" }

	cAliasQry := GetNextAlias()
	aFilQry   := aParams[1] 
	dDtIni    := aParams[2] 
	dDtFim    := aParams[3]
	lDtPagto  := aParams[4] == "1" //1= Data de Pagamento ou 2 = Data de disponibilidade
	nError	  := 0

	If __oQy1601C == Nil	
		
		cQuery := " SELECT " + __cCpoCaix + __cCpoRec1
		cQuery += "		' ' INTERMED, SE1.E1_VALOR VALOR, "
		If lDtPagto
			cQuery += "	    FK5.FK5_DATA DT_BAIXA, "
		Else
			cQuery += "	    FK5.FK5_DTDISP DT_BAIXA, "
		EndIf
		cQuery += "		' ' MOTBX, "
		cQuery += "		' ' LOTEFIN, ' ' IDBAIXA, "
		cQuery += "		'CH' FORMA_PGTO, "
		cQuery += " 	CAST(COALESCE(FK5.FK5_MOEDA, '1') AS INT) MOEDA, COALESCE(FK5.FK5_TXMOED, 0) TXMOEDA, "
		cQuery += "		SE1.E1_FILIAL FILIAL, ' ' NUMBOR, ' ' EA_ORIGEM, ' ' SEQBX "
		cQuery += "	FROM " + RetSqlName("SE1") + " SE1 "
		cQuery += "	INNER JOIN " + RetSqlName("FK7") + " FK7 ON FK7.FK7_ALIAS = 'SE1' "
		cQuery += "	    AND FK7.FK7_FILTIT = SE1.E1_FILIAL AND FK7.FK7_PREFIX = SE1.E1_PREFIXO "
		cQuery += "	    AND FK7.FK7_NUM = SE1.E1_NUM AND FK7.FK7_PARCEL = SE1.E1_PARCELA "
		cQuery += "	    AND FK7.FK7_TIPO = SE1.E1_TIPO AND FK7.FK7_CLIFOR = SE1.E1_CLIENTE "
		cQuery += "	    AND FK7.FK7_LOJA = SE1.E1_LOJA AND FK7.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN " + RetSqlName("FKF") + "  FKF ON " + FWJoinFilial("FKF", "FK7") 
		cQuery += "	AND FK7.FK7_IDDOC = FKF.FKF_IDDOC AND FKF_ESPEC IN (' ', 'N') "
		cQuery += "	AND FKF.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN " + RetSqlName("SEF") + " SEF ON " + FWJoinFilial("SEF", "SE1")
		cQuery += "	    AND SEF.EF_FILORIG = SE1.E1_FILORIG AND SEF.EF_PREFIXO = SE1.E1_PREFIXO "
		cQuery += "	    AND SEF.EF_TITULO = SE1.E1_NUM AND SEF.EF_PARCELA = SE1.E1_PARCELA"
		cQuery += "	    AND SEF.EF_TIPO = SE1.E1_TIPO AND SEF.EF_CLIENTE = SE1.E1_CLIENTE"
		cQuery += "	    AND SEF.EF_LOJACLI = SE1.E1_LOJA AND SEF.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN " + RetSqlName("FKA") + " FKA ON " + FWJoinFilial("FKA", "SEF")
		cQuery += "	    AND FKA.FKA_IDORIG = SEF.EF_IDSEF "
		cQuery += "	    AND FKA.FKA_TABORI = 'SEF' AND FKA.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN " + RetSqlName("FKA") + " FKA2 ON FKA.FKA_FILIAL =  FKA2.FKA_FILIAL "
		cQuery += "	    AND FKA.FKA_IDPROC = FKA2.FKA_IDPROC "
		cQuery += "	    AND FKA2.FKA_TABORI = 'FK5' AND FKA2.D_E_L_E_T_ = ' ' "
		cQuery += "	INNER JOIN " + RetSqlName("FK5") + " FK5 ON " + FWJoinFilial("FK5", "FKA")
		cQuery += "	    AND FK5.D_E_L_E_T_ = ' ' AND FKA2.FKA_IDORIG = FK5.FK5_IDMOV "
		cQuery += "	    AND FK5.FK5_IDDOC = FK7.FK7_IDDOC "
		cQuery += "	    AND NOT EXISTS( SELECT "
		cQuery += "	    	FK5EST.FK5_IDMOV FROM " + RetSqlName("FK5") + " FK5EST "
		cQuery += "	    	WHERE FK5EST.FK5_FILIAL = FK5.FK5_FILIAL AND FK5EST.FK5_IDMOV = FKA2.FKA_IDORIG "
		cQuery += "	    	AND FK5EST.FK5_SEQ = FK5.FK5_SEQ AND FK5EST.FK5_TPDOC = 'ES' AND FK5EST.D_E_L_E_T_ = ' ') "
		cQuery += "	INNER JOIN " + RetSqlName("SA6") + " SA6 ON " + FWJoinFilial("SA6", "FK5")
		cQuery += "	    AND SA6.A6_COD = FK5.FK5_BANCO "
		cQuery += "	    AND SA6.A6_AGENCIA = FK5.FK5_AGENCI "
		cQuery += "	    AND SA6.A6_NUMCON = FK5.FK5_CONTA "
		cQuery += "	    AND SA6.A6_COD NOT IN "+__cBcoCart+ " "
		cQuery += "	    AND SA6.A6_MOEDA = 1 "
		cQuery += "	    AND SA6.D_E_L_E_T_ = ' ' "
		cQuery += "	WHERE "
		cQuery += "	    SE1.E1_FILORIG IN ( ? ) AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += "	    AND SE1.E1_TIPO NOT IN "+FormatIn(MVABATIM+"|"+MVPROVIS+"|"+MV_CRNEG+"|"+MVRECANT+"|"+"SES","|")  + " "

		If lDtPagto
			cQuery += "	    AND FK5.FK5_DATA BETWEEN ? AND ? "
		Else
			cQuery += "	    AND FK5.FK5_DTDISP BETWEEN ? AND ? "
		EndIf
		

		/*--------------------------------------------------|
		| PE recebe a query padrao, permitindo modificacoes | 
		| nas regras de filtro. Substitui a query padrao	|
		---------------------------------------------------*/
		If ExistBlock("F16QYCRC")                        			
			cQuery := ExecBlock("F16QYCRC",.F.,.F.,{cQuery})
		EndIf	

		cQuery := ChangeQuery( cQuery )

         __oQy1601C := FWPreparedStatement():New(cQuery)
	EndIf

	__oQy1601C:SetIn(1, aFilQry )			//E1_FILORIG
	__oQy1601C:SetString(2, Dtos(dDtIni))   //FK5_DATA/FK5_DTDISP
	__oQy1601C:SetString(3, Dtos(dDtFim))	//FK5_DATA/FK5_DTDISP

	cQuery := __oQy1601C:GetFixQuery()

	nError:= TcSQLExec("INSERT INTO " + oTable:GetRealName() + " (" + cFields + ") " + cQuery + " " )
	
	If nError < 0
		UserException(TCSQLError())
	EndIf

Return

/*/{Protheus.doc} SPDSetField()
Tratamento com a função TCSETFIELD() para os
campos do alias desejado.

@author fabio.casagrande
@since 13/07/2023
@version 1.0
@type static function

@return NIL
/*/
Static Function SPDSetField(aStruSet As Array, cAliasSet As Char)
	Local nLoop As Numeric

	Default aStruSet  := {}
	Default cAliasSet := ""

	If !Empty(aStruSet) .AND. !Empty(cAliasSet)
		For nLoop := 1 TO Len(aStruSet)
			If aStruSet[nLoop][2] $ "ND"
				TCSetField(cAliasSet, aStruSet[nLoop][1], aStruSet[nLoop][2], aStruSet[nLoop][3], aStruSet[nLoop][4])
			EndIf
		NEXT nLoop
	EndIf
Return

/*/{Protheus.doc} FinRetCX
    Função que retorna os bancos de uso interno do sistema, ou seja, Caixa da empresa.
    @type  Static Function
	@return cBancos
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinRetCX() As Char 
	Local cBanco 		As Char
	Local cMvCarteir 	As Char 
	Local nTamCodA6 	As Numeric

	nTamCodA6 	:= TamSX3("A6_COD")[1]
	cBanco 		:= Left(GetMv("MV_CXFIN"),nTamCodA6)
	cMvCarteir 	:= GetMV("MV_CARTEIR")

	If !Empty(cMvCarteir)
		cBanco := cBanco +";"+ cMvCarteir 
	EndIf

	cBanco := FormatIn(cBanco,";")

Return cBanco

/*/{Protheus.doc} FinTpbx
    Função que retorna motivo de baixa, para títulos baixados e enviados na competencia.
    @type  Static Function
	@param cIddoc  - ID do registro
	@param dDataBX - Data da Baixa
	@param cFilOrig - Filial de origem do registro
	@return aDados[1] - Motivo de baixa
			aDados[2] - A6_CGC
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinTpbx(cIddoc as Char, dDataBX as Date, cFilOrig as Char) as Array 
	Local aDados 		as Array
	Local cQuery		as Char
	Local cAliasTemp	as Char

	Default cIddoc  := ""
	Default dDataBX := dDatabase
	Default cFilOrig := cFilant

	aDados 		:= Array(3)
	cQuery 		:= ""
	cAliasTemp	:= ""

	aDados[1] 	:= ""
	aDados[2] 	:= ""

	If __oQMotBxR == Nil

		cQuery := "	SELECT FK1.FK1_MOTBX MOTBX, COALESCE(SA6.A6_CGC, '') CNPJBCO, " 
		If "SQL" $ __cNameDB 
			cQuery += " COALESCE(SA6.A6_COD+SA6.A6_AGENCIA+SA6.A6_NUMCON, '') BANCO "
		Else
			cQuery += " COALESCE(SA6.A6_COD||SA6.A6_AGENCIA||SA6.A6_NUMCON, '') BANCO "
		EndIf
		cQuery += " FROM " + RetSqlName("FK1") + " FK1 "
		cQuery += "	INNER JOIN " + RetSqlName("F7G") + " F7G ON " + FWJoinFilial("F7G", "FK1")
		cQuery += "	    AND F7G.F7G_SIGLA = FK1.FK1_MOTBX "
		cQuery += "	    AND F7G.D_E_L_E_T_ = ' ' "
		cQuery += "	    AND F7G.F7G_MOVBCO = 'S' "
		cQuery += "	    AND F7G.F7G_FORMRC <> ' ' "
		cQuery += "	    AND F7G_ESPEC IN (' ', 'N') "
		cQuery += "	INNER JOIN " + RetSqlName("FKA") + " FKA ON "  + FWJoinFilial("FKA", "FK1")
		cQuery += "	    AND FKA.FKA_IDORIG = FK1.FK1_IDFK1 "
		cQuery += "	    AND FKA.FKA_TABORI = 'FK1' AND FKA.D_E_L_E_T_ = ' ' "
		cQuery += "	LEFT JOIN " + RetSqlName("FKA") + " FKA2 ON FKA.FKA_FILIAL =  FKA2.FKA_FILIAL "
		cQuery += "	    AND FKA.FKA_IDPROC = FKA2.FKA_IDPROC "
		cQuery += "	    AND FKA2.FKA_TABORI = 'FK5' AND FKA2.D_E_L_E_T_ = ' ' "
		cQuery += "	LEFT JOIN " + RetSqlName("FK5") + " FK5 ON " + FWJoinFilial("FK5", "FKA")
		cQuery += "	    AND FK5.D_E_L_E_T_ = ' ' AND FKA2.FKA_IDORIG = FK5.FK5_IDMOV AND FK5.FK5_FILORI IN ( ? ) "
		cQuery += "	    AND NOT EXISTS( SELECT "
		cQuery += "	    	FK5EST.FK5_IDMOV FROM " + RetSqlName("FK5") + " FK5EST "
		cQuery += "	    	WHERE FK5EST.FK5_FILIAL = FK5.FK5_FILIAL AND FK5EST.FK5_IDMOV = FKA2.FKA_IDORIG "
		cQuery += "	    	AND FK5EST.FK5_SEQ = FK5.FK5_SEQ AND FK5EST.FK5_TPDOC = 'ES' AND FK5EST.D_E_L_E_T_ = ' ') "
		cQuery += "	LEFT JOIN " + RetSqlName("SA6") + " SA6 ON " + FWJoinFilial("SA6", "FK5")
		cQuery += "	    AND SA6.A6_COD = FK5.FK5_BANCO "
		cQuery += "	    AND SA6.A6_AGENCIA = FK5.FK5_AGENCI "
		cQuery += "	    AND SA6.A6_NUMCON = FK5.FK5_CONTA "
		cQuery += "	    AND SA6.A6_COD NOT IN "+__cBcoCart+ " "
		cQuery += "	    AND SA6.A6_MOEDA = 1 "
		cQuery += "	    AND SA6.D_E_L_E_T_ = ' ' "
		cQuery += "	    WHERE FK1.FK1_IDDOC = ? AND FK1.FK1_DATA = ? "
		cQuery += "	    AND FK1.D_E_L_E_T_ = ' '  "
		cQuery += "	    AND NOT EXISTS( 
		cQuery += "	    	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") + " FK1EST "
		cQuery += "	    	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
		cQuery += "	    	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ AND FK1EST.FK1_TPDOC = 'ES' AND FK1EST.D_E_L_E_T_ = ' ') "
		
		cQuery := ChangeQuery( cQuery )

		__oQMotBxR := FWPreparedStatement():New(cQuery)
	EndIf

	__oQMotBxR:SetString(1, cFilOrig)
	__oQMotBxR:SetString(2, cIddoc)   
	__oQMotBxR:SetString(3, Dtos(dDataBX))

	cQuery := __oQMotBxR:GetFixQuery()
	cAliasTemp := MpSysOpenQuery(cQuery)

	If (cAliasTemp)->(!Eof())
		aDados[1] := (cAliasTemp)->MOTBX
		aDados[2] := (cAliasTemp)->CNPJBCO
		aDados[3] := (cAliasTemp)->BANCO
	EndIf

	(cAliasTemp)->(DbCloseArea())

Return aDados

/*/{Protheus.doc} F1601TabC
    Query de contas a receber (regime de apuração competencia)
    @type  Static Function
	@param cAliasTmp  - Alias da tabela temporaria
	@param aParams    - Parâmetrização passada pela rotina do SPED
	@return nil
    @author fabio.casagrande
    @since 12/07/2023
/*/
Static Function F1601TabC(cAliasTmp As Char, aParams As Array)
	
	Local lDelReg 	As Logical
	Local lGrvReg 	As Logical
	Local lVerCHQ 	As Logical
	Local aArea 	As Array
	Local aDadosBx 	As Array
	Local aDadosBco As Array
	Local cMotBx 	As Char
	Local cFormPgto As Char
	Local cChaveTit As Char
	Local cSpFPgto 	As Char
	Local cCart 	As Char
	Local cCgcBco 	As Char
	Local cBanco 	As Char
	Local nTamFPgto As Numeric
	Local nValor 	As Numeric
	Local nVa		As Numeric
	Local dDtIni    As Date
	Local dDtFim    As Date

	Default cAliasTmp   := ""
	Default aParams 	:={ {}, dDatabase, dDatabase, "" }
	
	aArea 		:= GetArea()
	nTamFPgto 	:= TamSX3("F7G_FORMRC")[1]
	dDtIni    	:= aParams[2] 
	dDtFim    	:= aParams[3]

	F7G->(DbSelectArea("F7G"))
	SA6->(DbSelectArea("SA6"))
	FK5->(DbSelectArea("FK5"))
	SEF->(DbSelectArea("SEF"))
	SEF->(dbSetOrder(7)) //EF_FILIAL+EF_CART+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
	SA2->(DbSelectArea("SA2"))
	SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	
	/*--------------------------------------------------|
	| PE que permite complementar a gravação da tabela,	| 
	| com os dados enviado para o SPED					|
	---------------------------------------------------*/
	If ExistBlock("F160GRV")                        			
		ExecBlock("F160GRV",.F.,.F.,{cAliasTmp})
	EndIf
	
	(cAliasTmp)->(DbSetOrder(5)) //{"REGIME"  , "FILORIG"}
	(cAliasTmp)->(DbGoTop())
	
	While (cAliasTmp)->(!Eof())
		
		cMotBx 		:= (cAliasTmp)->MOTBX
		cFormPgto 	:= (cAliasTmp)->FORMA_PGTO
		cChaveTit 	:= ""
		lDelReg 	:= .F.
		lGrvReg 	:= .F.
		cCart 		:= "R"
		cCgcBco 	:= (cAliasTmp)->CNPJBCO
		cBanco 		:= (cAliasTmp)->BANCO
		lVerCHQ 	:= .F.
		aDadosBx 	:= Array(3)
		aDadosBco 	:= Array(2)
		

		If Empty(cMotBx) .And. Empty(cFormPgto)
			cChaveTit := xFilial("SE1", (cAliasTmp)->FILORIG)+"|"+(cAliasTmp)->PREFIXO+"|"+(cAliasTmp)->NUMERO+"|"+(cAliasTmp)->PARCELA+"|"+(cAliasTmp)->TIPO+"|"+(cAliasTmp)->CLIFOR+"|"+(cAliasTmp)->LOJA
			If EnviadoBco(cChaveTit, (cAliasTmp)->FILORIG, "SE1")
				cFormPgto := 'PX'
				lGrvReg := .T.
			EndIf
			If Empty(cFormPgto)
				If !Empty((cAliasTmp)->CODBAR)
					cFormPgto := 'BOL'
					lGrvReg := .T.
				Else
					lVerCHQ := .T.
				EndIf
			EndIf
		EndIf
		If Empty(cCgcBco)
			lVerCHQ := .T.
		EndIf

		If lVerCHQ .And. __lSLDBXCR 
			If SEF->(MsSeek(xFilial("SEF", (cAliasTmp)->FILORIG)+cCart+(cAliasTmp)->PREFIXO + (cAliasTmp)->NUMERO + (cAliasTmp)->PARCELA + (cAliasTmp)->TIPO))
				lDelReg := .T.
			EndIf
		EndIf
		
		If Empty(cMotBx) .And. !Empty((cAliasTmp)->DT_BAIXA)
			aDadosBx:= FinTpbx((cAliasTmp)->IDDOC, (cAliasTmp)->DT_BAIXA, (cAliasTmp)->FILORIG)
			cMotBx 	:= aDadosBx[1]
			If Empty(cCgcBco) .or.  Empty(cBanco)
				cCgcBco := aDadosBx[2]
				cBanco 	:= aDadosBx[3]
			EndIf

			lGrvReg := .T.
		EndIf
		If Empty(cCgcBco) .or.  Empty(cBanco) //busco as baixas a receber por transferencias
			aDadosBco:= FinVerTrf((cAliasTmp)->FILORIG, (cAliasTmp)->IDDOC)
			cBanco 	:= aDadosBco[1]
			cCgcBco := aDadosBco[2]
		EndIf
		If !lDelReg 
			If !Empty(cMotBx)
				F7G->(DbSetOrder(1)) //F7G_FILIAL+F7G_SIGLA
				If F7G->(MsSeek(xFilial("F7G", (cAliasTmp)->FILORIG)+cMotBx))
					If Empty(cFormPgto)
						cFormPgto := F7G->F7G_FORMRC
					EndIf
				EndIf
			ElseIf !Empty(cFormPgto)
				F7G->(DbSetOrder(3)) //F7G_FILIAL+F7G_FORMRC+F7G_MOVBCO+F7G_ESPEC
				cSpFPgto := Space(nTamFPgto-len(cFormPgto))
				If F7G->(MsSeek(xFilial("F7G", (cAliasTmp)->FILORIG)+cFormPgto+cSpFPgto+"S"+"N"))
					cMotBx:= F7G->F7G_SIGLA
				Else 
					lDelReg := .T.
				EndIf
			Else
				lDelReg := .T.
			EndIf
		EndIf

		If __lBxCnab .And. !Empty((cAliasTmp)->LOTEFIN) //retorna os dados do banco do borderô
			aDadosBco:= FinVerLot((cAliasTmp)->FILORIG, (cAliasTmp)->LOTEFIN) //Busca os dados do banco da baixa (FK5)
			cBanco 	:= aDadosBco[1]
			cCgcBco := aDadosBco[2]
		EndIf

		If !lDelReg .And. !Empty(cFormPgto)
			If Alltrim(cFormPgto) $ __cForPgto
				lDelReg := .T.
			Else
				lGrvReg := .T.
			EndIf
		EndIf
		If lDelReg
			RecLock(cAliasTmp, .F.)
				dbdelete()
			(cAliasTmp)->(MsUnlock())
		ElseIf lGrvReg
			nValor	:= FinNValor(cAliasTmp)
			nVa := FinTotFK6((cAliasTmp)->IDBAIXA, "FK1")
			nValor := nValor-nVa

			RecLock(cAliasTmp, .F.)
				If Empty((cAliasTmp)->FORMA_PGTO) .OR. lVerCHQ
					(cAliasTmp)->FORMA_PGTO := cFormPgto
				EndIf
				If Empty((cAliasTmp)->MOTBX)
					(cAliasTmp)->MOTBX := cMotBx
				EndIf
				If (cAliasTmp)->CNPJBCO <> cCgcBco
					(cAliasTmp)->CNPJBCO := cCgcBco
				EndIf
				If (cAliasTmp)->BANCO <> cBanco
					(cAliasTmp)->BANCO := cBanco
				EndIf
				(cAliasTmp)->VALOR := nValor
			(cAliasTmp)->(MsUnlock())
		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo
	RestArea(aArea)
Return

/*/{Protheus.doc} FinVerTrf
    Função que retorna o A6_CGC da baixa a receber feita por transferecia descontada.
    @type  Static Function
	@param cFilOrig  - Filial de origem do movimento.
	@param cIdDoc  - Id do movimento bancário.
	@return aDadosBco[1] - Chave do banco
	@return aDadosBco[2] - CNPJ do banco
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinVerTrf(cFilOrig as Char, cIdDoc as Char) as Array 

	Local aDadosBco		as Array 
	Local cQuery		As Char
	Local cAliasTemp	As Char
	
	Default cFilOrig  	:= cFilAnt
	Default cIdDoc  	:= ""
	
	cQuery 		:= ""
	cAliasTemp	:= ""
	aDadosBco	:= Array(2)

	If __oQMovTrR == Nil
		If "SQL" $ __cNameDB 
			cQuery := "	SELECT SA6.A6_COD+SA6.A6_AGENCIA+SA6.A6_NUMCON BANCO, SA6.A6_CGC CNPJBCO "
		Else
			cQuery := "	SELECT SA6.A6_COD||SA6.A6_AGENCIA||SA6.A6_NUMCON BANCO, SA6.A6_CGC CNPJBCO "
		EndIf
		cQuery += "  FROM " + RetSqlName("FK5") + " FK5 "
		cQuery += "	INNER JOIN " + RetSqlName("SA6") + " SA6 ON " + FWJoinFilial("SA6", "FK5")
		cQuery += "	    AND SA6.A6_COD = FK5.FK5_BANCO "
		cQuery += "	    AND SA6.A6_AGENCIA = FK5.FK5_AGENCI "
		cQuery += "	    AND SA6.A6_NUMCON = FK5.FK5_CONTA "
		cQuery += "	    AND SA6.A6_COD NOT IN "+__cBcoCart+ " "
		cQuery += "	    AND SA6.A6_MOEDA = 1 "
		cQuery += "	    AND SA6.D_E_L_E_T_ = ' ' "

		cQuery += "	    WHERE FK5.FK5_FILIAL = ?"
		cQuery += "		AND FK5.FK5_IDDOC = ? "
		cQuery += "	    AND NOT EXISTS( SELECT "
		cQuery += "	    	FK5EST.FK5_IDMOV FROM " + RetSqlName("FK5") + " FK5EST "
		cQuery += "	    	WHERE FK5EST.FK5_FILIAL = FK5.FK5_FILIAL AND FK5EST.FK5_IDMOV = FK5.FK5_IDMOV "
		cQuery += "	    	AND FK5EST.FK5_SEQ = FK5.FK5_SEQ AND FK5EST.FK5_TPDOC = 'ES' AND FK5EST.D_E_L_E_T_ = ' ') 
		cQuery += "	    AND FK5.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )

		__oQMovTrR := FWPreparedStatement():New(cQuery)

	EndIf

		__oQMovTrR:SetString(1, xFilial("FK5", cFilOrig))
		__oQMovTrR:SetString(2, cIddoc)   

		cQuery := __oQMovTrR:GetFixQuery()
		cAliasTemp := MpSysOpenQuery(cQuery)

	If (cAliasTemp)->(!Eof())
		aDadosBco[1] := (cAliasTemp)->BANCO
		aDadosBco[2] := (cAliasTemp)->CNPJBCO
	EndIf

	(cAliasTemp)->(DbCloseArea())
Return aDadosBco

/*/{Protheus.doc} FinVerLot
    Função que retorna o A6_CGC da baixas de borderô com MV_BXCNXB = S.
    @type  Static Function
	@param cFilOrig  - Filial de origem do movimento.
	@param cLoteFin  - Lote do movimento de baixa.
	@return aDadosBco[1] - Chave do banco
	@return aDadosBco[2] - CNPJ do banco
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinVerLot(cFilOrig as Char, cLoteFin as Char) as Array 

	Local aDadosBco		as Array 
	Local cQuery		As Char
	Local cAliasTemp	As Char
	
	Default cFilOrig  	:= cFilAnt
	Default cLoteFin  	:= ""
	
	cQuery 		:= ""
	cAliasTemp	:= ""
	aDadosBco	:= Array(2)

	If __oQMovLot == Nil
		If "SQL" $ __cNameDB
			cQuery := "	SELECT SA6.A6_COD+SA6.A6_AGENCIA+SA6.A6_NUMCON BANCO, SA6.A6_CGC CNPJBCO "
		Else
			cQuery := "	SELECT SA6.A6_COD||SA6.A6_AGENCIA||SA6.A6_NUMCON BANCO, SA6.A6_CGC CNPJBCO "
		EndIf
		cQuery += " FROM " + RetSqlName("FK5") + " FK5 "
			
		cQuery += "	INNER JOIN " + RetSqlName("SA6") + " SA6 ON " + FWJoinFilial("SA6", "FK5")
		cQuery += "	    AND SA6.A6_COD = FK5.FK5_BANCO "
		cQuery += "	    AND SA6.A6_AGENCIA = FK5.FK5_AGENCI "
		cQuery += "	    AND SA6.A6_NUMCON = FK5.FK5_CONTA "
		cQuery += "	    AND SA6.A6_COD NOT IN "+__cBcoCart+ " "
		cQuery += "	    AND SA6.A6_MOEDA = 1 "
		cQuery += "	    AND SA6.D_E_L_E_T_ = ' ' "

		cQuery += "	    WHERE FK5.FK5_FILIAL = ?"
		cQuery += "		AND FK5.FK5_LOTE = ? "
		cQuery += "	    AND NOT EXISTS( SELECT "
		cQuery += "	    	FK5EST.FK5_IDMOV FROM " + RetSqlName("FK5") + " FK5EST "
		cQuery += "	    	WHERE FK5EST.FK5_FILIAL = FK5.FK5_FILIAL AND FK5EST.FK5_IDMOV = FK5.FK5_IDMOV "
		cQuery += "	    	AND FK5EST.FK5_SEQ = FK5.FK5_SEQ AND FK5EST.FK5_TPDOC = 'ES' AND FK5EST.D_E_L_E_T_ = ' ') 
		cQuery += "	    AND FK5.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )

		__oQMovLot := FWPreparedStatement():New(cQuery)

	EndIf

		__oQMovLot:SetString(1, xFilial("FK5", cFilOrig))
		__oQMovLot:SetString(2, cLoteFin)   

		cQuery := __oQMovLot:GetFixQuery()
		cAliasTemp := MpSysOpenQuery(cQuery)

	If (cAliasTemp)->(!Eof())
		aDadosBco[1] := (cAliasTemp)->BANCO
		aDadosBco[2] := (cAliasTemp)->CNPJBCO
	EndIf

	(cAliasTemp)->(DbCloseArea())

Return aDadosBco

/*/{Protheus.doc} FinIniVar
    Função para inicializar as variáveis static.
    @type  Static Function
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinIniVar()

	__cNameDB  := AllTrim(Upper(TcGetDB()))
	__cConcat  := IIF("SQL" $ __cNameDB, "+", "||")

	__cCpoComp := "'COMPETENCIA' REGIME, "
	__cCpoCaix := " 'CAIXA' REGIME, "

	__cCpoRec1 := " COALESCE(SA6.A6_COD" + __cConcat +  "SA6.A6_AGENCIA" + __cConcat + "SA6.A6_NUMCON, '') BANCO, COALESCE(SA6.A6_CGC, ' ') CNPJBCO, "
	__cCpoRec1 += " SE1.E1_FILORIG FILORIG, SE1.E1_EMISSAO DT_EMISSAO,"
	__cCpoRec1 += "	SE1.E1_ORIGEM ORIGEM, SE1.E1_PREFIXO PREFIXO, SE1.E1_NUM NUMERO,"
	__cCpoRec1 += " SE1.E1_TIPO TIPO, SE1.E1_PARCELA PARCELA, SE1.E1_SITUACA SITUACAO, SE1.E1_SALDO SALDO, " 
	__cCpoRec1 += " FK7.FK7_IDDOC IDDOC, SE1.E1_CLIENTE CLIFOR, SE1.E1_LOJA LOJA, "
	__cCpoRec1 += "	SE1.E1_CODBAR CODBAR, SE1.E1_NUMNOTA, SE1.E1_SERIE, "

	If __cBcoCart == Nil
		__cBcoCart := FinRetCX()
	EndIf
	If __cForPgto == Nil
		__cForPgto := FormatIn(GetMV("MV_FINFMPG",.F.,"CI|CO|CQ|FA|FID|R$|RA|VA|VP"),"|")
	EndIF
	If __lBxCnab == Nil
		__lBxCnab := GetMv("MV_BXCNAB") == "S"
	EndIf 
	If __lSLDBXCR == Nil
		__lSLDBXCR  := SuperGetMv("MV_SLDBXCR",,"B") == "C"
	EndIf
Return

/*/{Protheus.doc} FinNValor
    Função que retorna o valor referente ao título ou a baixa.
    @type  Static Function
	@param cAliasTmp  - alias temporário com registro posicionado
	@return nValor
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinNValor(cAliasTmp as Char) as Numeric
	Local nValor 		As Numeric
	Local nTotImp 		As Numeric
	Local nCasDec	  	As Numeric
	Local nCasDecM  	As Numeric
	Local nTotAbt  		As Numeric

	nValor 		:= 0
	nTotImp		:= 0
	nCasDec  	:= TamSx3("E1_VALOR")[2]
	nCasDecM  	:= TamSx3("M2_MOEDA2")[2]
	nTotAbt		:= 0

	//Fazer a conversão sempre para moeda corrente 1
	If (cAliasTmp)->REGIME == "COMPETENCIA" 
		nValor := Round(xMoeda((cAliasTmp)->VALOR, (cAliasTmp)->MOEDA, 1, (cAliasTmp)->DT_EMISSAO, nCasDecM,(cAliasTmp)->TXMOEDA), nCasDec)
	Else 
		If !((cAliasTmp)->TIPO $ MVRECANT)  .And.FinUltBx((cAliasTmp)->FILIAL, (cAliasTmp)->IDDOC, (cAliasTmp)->SEQBX)
			nTotAbt :=SomaAbat((cAliasTmp)->PREFIXO,(cAliasTmp)->NUMERO,(cAliasTmp)->PARCELA,"R",(cAliasTmp)->MOEDA,(cAliasTmp)->DT_BAIXA,(cAliasTmp)->CLIFOR,(cAliasTmp)->LOJA,(cAliasTmp)->FILORIG,(cAliasTmp)->DT_EMISSAO, (cAliasTmp)->TIPO)
		EndIf
		If Alltrim((cAliasTmp)->EA_ORIGEM) == 'FINA061'
			nTotImp	:= FinImpBor((cAliasTmp)->FILIAL, (cAliasTmp)->IDDOC)
		Else
			nTotImp	:= FinSumImp((cAliasTmp)->FILIAL, (cAliasTmp)->IDBAIXA)
		EndIf
		nValor := (cAliasTmp)->VALOR + nTotAbt + nTotImp
	EndIf 

Return nValor

/*/{Protheus.doc} FinSumImp
    Função que retorna a soma de todos os impostos retidos na baixa
    @type  Static Function
	@param cFilBX  - Filial 
	@param cIdBaixa  - Id da baixa realizada
	@return nValor
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinSumImp(cFilBX as Char, cIdBaixa as Char) as Numeric

	Local nValor 		As Numeric
	Local cQuery		As Char
	Local cAliasTemp	As Char
	
	Default cFilBX		:= ""
	Default cIdBaixa  	:= ""
	
	cQuery 		:= ""
	cAliasTemp	:= ""
	nValor		:= 0

	If __oQImpRet == Nil
		cQuery := "	SELECT SUM(FK4.FK4_VALOR) TOTAL FROM " + RetSqlName("FK4") + " FK4 "
		cQuery += "	    WHERE FK4.FK4_FILIAL = ?"
		cQuery += "		AND FK4.FK4_IDORIG = ?"
		cQuery += "		AND FK4.FK4_STATUS = '1' "
		cQuery += "	    AND FK4.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )

		__oQImpRet := FWPreparedStatement():New(cQuery)

	EndIf

	__oQImpRet:SetString(1, cFilBX)
	__oQImpRet:SetString(2, cIdBaixa)

	cQuery := __oQImpRet:GetFixQuery()
	cAliasTemp := MpSysOpenQuery(cQuery)

	If (cAliasTemp)->(!Eof())
		nValor := (cAliasTemp)->TOTAL
	EndIf

	(cAliasTemp)->(DbCloseArea())

Return nValor

/*/{Protheus.doc} FinUltBx
    Função que retorna se essa é a ultima baixa ou não
    @type  Static Function
	@param cFilBX  - Filial 
	@param cIdDoc  - Id do título
	@param cSeq  - Id da baixa
	@return lUltBx
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinUltBx(cFilBX as Char, cIdDoc as Char, cSeq as Char) as Logical
	Local lUltBx as Logical
	Local cQuery		As Char
	Local cAliasTemp	As Char

	Default cFilBX  	:= cFilant
	Default cIdDoc  	:= ""
	Default cSeq  		:= "01"

	lUltBx := .F.
	cQuery 		:= ""
	cAliasTemp	:= ""

	If __oQSeqBx == NIL
		cQuery := "	SELECT MAX(FK1.FK1_SEQ) SEQBX FROM " + RetSqlName("FK1") + " FK1 "
		cQuery += "	    WHERE FK1.FK1_FILIAL = ?  " 
		cQuery += "		AND FK1.FK1_IDDOC = ?"
		cQuery += "	    AND FK1.D_E_L_E_T_ = ' '  "
		cQuery += "	    AND NOT EXISTS( 
		cQuery += "	    	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") + " FK1EST "
		cQuery += "	    	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
		cQuery += "	    	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ AND FK1EST.FK1_TPDOC = 'ES' AND FK1EST.D_E_L_E_T_ = ' ') "

		
		cQuery := ChangeQuery( cQuery )

		__oQSeqBx := FWPreparedStatement():New(cQuery)

	EndIf

	__oQSeqBx:SetString(1, cFilBX)
	__oQSeqBx:SetString(2, cIdDoc)

	cQuery := __oQSeqBx:GetFixQuery()
	cAliasTemp := MpSysOpenQuery(cQuery)

	If (cAliasTemp)->(!Eof())
		lUltBx := (cAliasTemp)->SEQBX == cSeq
	EndIf

	(cAliasTemp)->(DbCloseArea())

Return lUltBx

/*/{Protheus.doc} FinImpBor
    Função que retorna a soma de todos os impostos retidos na baixa
    @type  Static Function
	@param cFilOrig  - Filial Filial de origem da baixa
	@param cIddoc  - Id de identificação do título
	@return nValor
    @author Pâmela Bernardo
    @since 20/07/2023
/*/
Static Function FinImpBor(cFilOrig as Char, cIddoc as Char) as Numeric

	Local nValor 		As Numeric
	Local cQuery		As Char
	Local cAliasTemp	As Char
	
	Default cFilOrig	:= ""
	Default cIddoc  	:= ""
	
	cQuery 		:= ""
	cAliasTemp	:= ""
	nValor		:= 0

	If __oQImpBor == Nil
		cQuery := "	SELECT SUM(FK1.FK1_VALOR) TOTAL FROM " + RetSqlName("FK1") + " FK1 "
		cQuery += "	    WHERE FK1.FK1_FILIAL = ?"
		cQuery += "		AND FK1.FK1_IDDOC = ?"
		cQuery += "		AND FK1.FK1_MOTBX IN ('IRF','PCC') "
		cQuery += "	    AND FK1.D_E_L_E_T_ = ' ' "
		cQuery += "	    AND NOT EXISTS( 
		cQuery += "	    	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") + " FK1EST "
		cQuery += "	    	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
		cQuery += "	    	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ AND FK1EST.FK1_TPDOC = 'ES' AND FK1EST.D_E_L_E_T_ = ' ') "
		
		cQuery := ChangeQuery( cQuery )

		__oQImpBor := FWPreparedStatement():New(cQuery)

	EndIf

	__oQImpBor:SetString(1, FwXfilial('FK1',cFilOrig))
	__oQImpBor:SetString(2, cIddoc)

	cQuery := __oQImpBor:GetFixQuery()
	cAliasTemp := MpSysOpenQuery(cQuery)

	If (cAliasTemp)->(!Eof())
		nValor := (cAliasTemp)->TOTAL
	EndIf

	(cAliasTemp)->(DbCloseArea())

Return nValor
