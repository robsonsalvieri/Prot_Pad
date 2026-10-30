#INCLUDE "BADEFINITION.ch"

NEW ENTITY COMPGARANTIA

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPGARANTIA
Visualiza a comparação de Garantias entre marcas

@since   01/02/2018
/*/
//-------------------------------------------------------------------
Class BACompGarantia from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@since   01/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACompGarantia
	_Super:Setup("AuditoriaCompGarantia", FACT, "O0H")

	
	//---------------------------------------------------------
	// Define que a extração da entidade será por mês
	//---------------------------------------------------------
	_Super:SetTpExtr( BYMONTH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@since   01/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACompGarantia
	Local cQuery := ""
	
	cQuery := "SELECT BK_FILIAL " 
	cQuery +=	                ",BK_PROCESSO_JUR " 
	cQuery +=	                ",<<KEY_O0E_M1.O0E_MARCA>> AS MARCA1 " 
	cQuery +=	                ",<<KEY_O0E_M2.O0E_MARCA>> AS MARCA2 " 
	cQuery +=	                ",O0H_DATA " 
	cQuery +=	                ",O0H_VALOR " 
	cQuery +=	                ",O0H_VLRATU " 
	cQuery +=	                ",O0H_VJPROV " 
	cQuery +=	                ",O0H_VCPROV " 
	cQuery +=	                ",O0H_LEVANT " 
	cQuery +=	                ",O0H_COD " 
	cQuery +=	                ",O0H_EMBREC " 
	cQuery +=	                ",BK_FORMA_CORRECAO " 
	cQuery +=	                ",BK_TIPO_GARANTIA " 
	cQuery +=	                ",MOVIMENTACAO " 
	cQuery +=                    ", '01' AS INSTANCIA " 
	cQuery +=              "FROM ( SELECT A.BK_FILIAL BK_FILIAL, " 
	cQuery +=	                        "COALESCE(A.BK_PROCESSO_JUR,B.BK_PROCESSO_JUR) BK_PROCESSO_JUR, " 
	cQuery +=	                        "COALESCE(A.BK_MARCA,M.MARCA1) MARCA1, " 
	cQuery +=	                        "B.BK_MARCA MARCA2, " 
	cQuery +=	                        "COALESCE(B.O0H_VALOR,0) - COALESCE(A.O0H_VALOR,0) O0H_VALOR, " 
	cQuery +=	                        "COALESCE(B.O0H_VLRATU,0) - COALESCE(A.O0H_VLRATU,0) O0H_VLRATU, " 
	cQuery +=	                        "COALESCE(B.O0H_VJPROV,0) - COALESCE(A.O0H_VJPROV,0) O0H_VJPROV, " 
	cQuery +=	                        "COALESCE(B.O0H_VCPROV,0) - COALESCE(A.O0H_VCPROV,0) O0H_VCPROV, " 
	cQuery +=	                        "COALESCE(B.O0H_LEVANT,0) - COALESCE(A.O0H_LEVANT,0) O0H_LEVANT, " 
	cQuery +=	                        "B.O0H_DATA, " 
	cQuery +=	                        "B.BK_TIPO_GARANTIA, " 
	cQuery +=	                        "B.O0H_COD, " 
	cQuery +=	                        "B.O0H_EMBREC, " 
	cQuery +=	                        "B.BK_FORMA_CORRECAO, " 
	cQuery +=	                        "CASE " 
	cQuery +=	                          "WHEN COALESCE(B.O0H_VLRATU,0) = A.O0H_VLRATU AND COALESCE(B.O0H_LEVANT,0) = A.O0H_LEVANT THEN 'Sem Alteracao' " 
	cQuery +=	                          "WHEN COALESCE(NULLIF(COALESCE(B.O0H_VLRATU,0),0),B.O0H_VALOR) - B.O0H_LEVANT <= 0 THEN 'Baixa total' " 
	cQuery +=	                          "WHEN COALESCE(B.O0H_LEVANT,0) > 0 AND B.O0H_VLRATU - B.O0H_LEVANT > 0 THEN 'Baixa parcial' " 
	cQuery +=	                          "WHEN COALESCE(A.O0H_COD,' ') = ' ' AND B.O0H_VALOR > 0 THEN 'Adicao de valor' " 
	cQuery +=	                          "WHEN B.O0H_VCPROV > A.O0H_VCPROV OR B.O0H_VJPROV > A.O0H_VJPROV THEN 'Correcao monetaria' " 
	cQuery +=	                          "ELSE '0' " 
	cQuery +=	                        "END MOVIMENTACAO,"
	cQuery +=                          " '01' AS INSTANCIA"
	cQuery +=	                 "FROM ( SELECT DISTINCT A1.O0E_MARCA MARCA1 " 
	cQuery +=	                                       ",B1.O0E_MARCA MARCA2 " 
	cQuery +=	                        "FROM (SELECT O0E_MARCA " 
	cQuery +=	                              "FROM <<O0E_COMPANY>> " 
	cQuery +=								"WHERE D_E_L_E_T_ =' ') A1, " 
	cQuery +=	                             "(SELECT O0E_MARCA " 
	cQuery +=	                              "FROM <<O0E_COMPANY>> " 
	cQuery +=	                              "WHERE D_E_L_E_T_ =' ') B1 " 
	cQuery +=	                        "WHERE B1.O0E_MARCA > A1.O0E_MARCA " 
	cQuery +=	                        dateFilter() 
	cQuery +=	                        " ) M " 
	cQuery +=	                        "RIGHT JOIN ( " 
	cQuery +=	                        "SELECT <<KEY_FILIAL_O0H_FILPRO>> AS BK_FILIAL, " 
	cQuery +=								   "<<KEY_NSZ_O0H_FILPRO+O0H_CAJURI>> AS BK_PROCESSO_JUR, " 
	cQuery +=	                               "<<KEY_NQW_O0H_CTPGAR>> AS BK_TIPO_GARANTIA, " 
	cQuery +=	                               "<<KEY_NW7_O0H_CCOMON>> AS BK_FORMA_CORRECAO, " 
	cQuery +=	                               "O0H_MARCA BK_MARCA, " 
	cQuery +=	                               "COALESCE(NULLIF(O0H_DATA,''),'19010101') O0H_DATA, " 
	cQuery +=	                               "O0H_VALOR, " 
	cQuery +=	                               "O0H_VLRATU, " 
	cQuery +=	                               "O0H_VJPROV, " 
	cQuery +=	                               "O0H_VCPROV, " 
	cQuery +=	                               "O0H_LEVANT, " 
	cQuery +=	                               "O0H_COD, " 
	cQuery +=	                               "O0H_EMBREC " 
	cQuery +=	                        "FROM <<O0H_COMPANY>> O0H LEFT JOIN <<NQW_COMPANY>> NQW ON O0H_CTPGAR = NQW_COD " 
	cQuery +=	                                                                              "AND NQW.D_E_L_E_T_ = ' ' " 
	cQuery +=	                        "WHERE O0H.D_E_L_E_T_ = ' ') A ON (A.BK_MARCA = M.MARCA1) " 
	cQuery +=	                        "RIGHT JOIN ( " 
	cQuery +=	                        "SELECT <<KEY_FILIAL_O0H_FILPRO>> AS BK_FILIAL, " 
	cQuery +=                                  "<<KEY_NSZ_O0H_FILPRO+O0H_CAJURI>> AS BK_PROCESSO_JUR, " 
	cQuery +=	                               "<<KEY_NQW_O0H_CTPGAR>> AS BK_TIPO_GARANTIA, " 
	cQuery +=	                               "<<KEY_NW7_O0H_CCOMON>> AS BK_FORMA_CORRECAO, " 
	cQuery +=	                               "O0H_MARCA BK_MARCA, " 
	cQuery +=	                               "COALESCE(NULLIF(O0H_DATA,''),'19010101') O0H_DATA, " 
	cQuery +=	                               "O0H_VALOR, " 
	cQuery +=	                               "O0H_VLRATU, " 
	cQuery +=	                               "O0H_VJPROV, " 
	cQuery +=	                               "O0H_VCPROV, " 
	cQuery +=	                               "O0H_LEVANT, " 
	cQuery +=	                               "O0H_COD, " 
	cQuery +=	                               "O0H_EMBREC " 
	cQuery +=	                        "FROM <<O0H_COMPANY>> O0H LEFT JOIN <<NQW_COMPANY>> NQW ON O0H_CTPGAR = NQW_COD " 
	cQuery +=                           "AND NQW.D_E_L_E_T_ = ' ' " 
	cQuery +=	                        "WHERE O0H.D_E_L_E_T_ = ' ') B ON (A.BK_PROCESSO_JUR = B.BK_PROCESSO_JUR " 
	cQuery +=	                                                      "AND A.O0H_COD = B.O0H_COD " 
	cQuery +=	                                                      "AND B.BK_MARCA = M.MARCA2) " 
	cQuery +=              "UNION " 
	cQuery +=              "SELECT <<KEY_FILIAL_O0H_FILPRO>> AS BK_FILIAL, " 
	cQuery +=                     "<<KEY_NSZ_O0H_FILPRO+O0H_CAJURI>> AS BK_PROCESSO_JUR, " 
	cQuery +=                     "M.MARCA1, " 
	cQuery +=                     "M.MARCA2, " 
	cQuery +=                     "COALESCE(C.O0H_VALOR,0) O0H_VALOR, " 
	cQuery +=                     "COALESCE(C.O0H_VLRATU,0) O0H_VLRATU, " 
	cQuery +=                     "COALESCE(C.O0H_VJPROV,0) O0H_VJPROV, " 
	cQuery +=                     "COALESCE(C.O0H_VCPROV,0) O0H_VCPROV, " 
	cQuery +=                     "COALESCE(C.O0H_LEVANT,0) O0H_LEVANT, " 
	cQuery +=                     "COALESCE(NULLIF(C.O0H_DATA,''),'19010101') O0H_DATA, " 
	cQuery +=                     "<<KEY_NQW_O0H_CTPGAR>> AS BK_TIPO_GARANTIA, " 
	cQuery +=                     "C.O0H_COD, " 
	cQuery +=                     "C.O0H_EMBREC, " 
	cQuery +=                     "<<KEY_NW7_O0H_CCOMON>> AS BK_FORMA_CORRECAO, " 
	cQuery +=                     "CASE " 
	cQuery +=                       "WHEN COALESCE(NULLIF(COALESCE(C.O0H_VLRATU,0),0),C.O0H_VALOR) - COALESCE(C.O0H_LEVANT,0) <= 0 THEN 'Novo Baixa total' " 
	cQuery +=                       "WHEN COALESCE(C.O0H_LEVANT,0) > 0 AND COALESCE(NULLIF(C.O0H_VLRATU,0),C.O0H_VALOR) - COALESCE(C.O0H_LEVANT,0) > 0 THEN 'Novo Baixa parcial' " 
	cQuery +=                       "WHEN COALESCE(C.O0H_VALOR,0) > 0 THEN 'Adicao de valor' " 
	cQuery +=                       "ELSE '0' " 
	cQuery +=                     "END MOVIMENTACAO," 
	cQuery +=                      "'01' AS INSTANCIA " 
	cQuery +=              "FROM ( SELECT DISTINCT A1.O0E_MARCA MARCA1 " 
	cQuery +=                                    ",B1.O0E_MARCA MARCA2 " 
	cQuery +=                     "FROM ( SELECT O0E_MARCA " 
	cQuery +=                            "FROM <<O0E_COMPANY>> " 
	cQuery +=                  "WHERE D_E_L_E_T_ =' ') A1, " 
	cQuery +=                          "( SELECT O0E_MARCA " 
	cQuery +=                            "FROM <<O0E_COMPANY>> " 
	cQuery +=                     "WHERE D_E_L_E_T_ =' ') B1 " 
	cQuery +=                     "WHERE B1.O0E_MARCA > A1.O0E_MARCA " 
	cQuery +=                     dateFilter() 
	cQuery +=                     ") M JOIN <<O0H_COMPANY>> C ON C.O0H_MARCA = M.MARCA2 " 
	cQuery +=                                                "AND NOT EXISTS ( SELECT 1 "
	cQuery +=                                                                 "FROM <<O0H_COMPANY>> "
	cQuery +=                                                                " WHERE O0H_MARCA = M.MARCA1 "
	cQuery +=                                                                   "AND O0H_COD = C.O0H_COD  AND O0H_FILPRO = C.O0H_FILPRO)) F"
	cQuery +=                                                                 " JOIN <<O0E_COMPANY>> M1 ON (F.MARCA1 = M1.O0E_MARCA) "
	cQuery +=	                                                              " JOIN <<O0E_COMPANY>> M2 ON (F.MARCA2 = M2.O0E_MARCA) "
	cQuery +=                       "WHERE F.MARCA1 IS NOT NULL"
	cQuery +=                        " AND F.MARCA2 IS NOT NULL"
	cQuery +=                        " AND <<XFILIAL_O0H_FILIAL>> "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} dateFilter
Cria o filtro de data

@return cReturn - Filtro de Datas

@since   06/02/2018
/*/
//-------------------------------------------------------------------
Static Function dateFilter()
Local cReturn := ""
Local cDatabase  := Upper( SGDB() )
	
	If "ORACLE" $ cDatabase
		cReturn := "AND SUBSTRING(B1.O0E_MARCA,1,6) = SUBSTR(<<FINAL_DATE>>,1,6) "
		cReturn += "AND SUBSTRING(A1.O0E_MARCA,1,6) IN ( " 
		cReturn +=     "to_char(add_months(to_date(B1.O0E_MARCA,'yyyymmdd'),-1),'yyyymm'), "
		cReturn +=     "to_char(add_months(to_date(B1.O0E_MARCA,'yyyymmdd'),-2),'yyyymm'), " 
		cReturn +=     "to_char(add_months(to_date(B1.O0E_MARCA,'yyyymmdd'),-3),'yyyymm'), " 
		cReturn +=     "to_char(add_months(to_date(B1.O0E_MARCA,'yyyymmdd'),-6),'yyyymm'), " 
		cReturn +=     "to_char(add_months(to_date(B1.O0E_MARCA,'yyyymmdd'),-11),'yyyymm'), "
		cReturn +=     "to_char(add_months(to_date(B1.O0E_MARCA,'yyyymmdd'),-12),'yyyymm')) "
	 Elseif "POSTGRES" $ cDatabase
		cReturn := "AND SUBSTRING(B1.O0E_MARCA,1,6) = SUBSTRING(<<FINAL_DATE>>,1,6) "
		cReturn += "AND SUBSTRING(A1.O0E_MARCA,1,6) IN ( "
		cReturn +=     "TO_CHAR(TO_DATE(B1.O0E_MARCA,'YYYYMMDD') - 'INTERVAL 1 MONTH','YYYYMM'), "
		cReturn +=     "TO_CHAR(TO_DATE(B1.O0E_MARCA,'YYYYMMDD') - 'INTERVAL 2 MONTH','YYYYMM'), "
		cReturn +=     "TO_CHAR(TO_DATE(B1.O0E_MARCA,'YYYYMMDD') - 'INTERVAL 3 MONTH','YYYYMM'), "
		cReturn +=     "TO_CHAR(TO_DATE(B1.O0E_MARCA,'YYYYMMDD') - 'INTERVAL 6 MONTH','YYYYMM'), "
		cReturn +=     "TO_CHAR(TO_DATE(B1.O0E_MARCA,'YYYYMMDD') - 'INTERVAL 11 MONTH','YYYYMM'), "
		cReturn +=     "TO_CHAR(TO_DATE(B1.O0E_MARCA,'YYYYMMDD') - 'INTERVAL 12 MONTH','YYYYMM')) "
	Else 
		cReturn := "AND LEFT(B1.O0E_MARCA,6) = LEFT(<<FINAL_DATE>>,6) "
		cReturn += "AND LEFT(A1.O0E_MARCA,6) IN ( "
		cReturn +=      "CONVERT(VARCHAR(6),dateadd(month,-1,CONVERT(DATE,B1.O0E_MARCA,112)),112), " 
		cReturn +=      "CONVERT(VARCHAR(6),dateadd(month,-2,CONVERT(DATE,B1.O0E_MARCA,112)),112), "
		cReturn +=      "CONVERT(VARCHAR(6),dateadd(month,-3,CONVERT(DATE,B1.O0E_MARCA,112)),112), "
		cReturn +=      "CONVERT(VARCHAR(6),dateadd(month,-6,CONVERT(DATE,B1.O0E_MARCA,112)),112), "
		cReturn +=      "CONVERT(VARCHAR(6),dateadd(month,-11,CONVERT(DATE,B1.O0E_MARCA,112)),112), "
		cReturn +=      "CONVERT(VARCHAR(6),dateadd(month,-12,CONVERT(DATE,B1.O0E_MARCA,112)),112)) "
	EndIf
Return cReturn
