#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'


/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "003697_11"

/*/{Protheus.doc} OFAGCA01
	Rotina scheduler que vai rodar infinitamente e gerar conforme especificações(SCHEDULER)
	OU
	Configura gerações do DPM para o scheduler posteriormente usar

	@author Vinicius Gati
	@since  26/11/2015
/*/
Function OFAGCA01(aParam)
	//PROCESSO()
	BatchProcess("Controle de comunicação VMI","Este processo funciona via agendador, é um processo infinito que controla os envios de dados a AGCO.",,{ || PROCESSO() })
Return .T.

/*/{Protheus.doc} SchedDef
	Função padrão scheduler

	@author Vinicius Gati
	@since 28/06/2017
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


/*/{Protheus.doc} PROCESSO
	Função que verifica novos dados para o VMI

	@author Vinicius Gati
	@since  26/11/2015
/*/
Static Function PROCESSO()
	Local cQuery            := ""
	Local nQtdDias          := 0
	Local nX                := 1
	Local cAl               := GetNextAlias()
	Private oUtil           := DMS_Util():New()
	Private oSqlHlp         := DMS_SqlHelper():New()
	Private oArHlp          := DMS_ArrayHelper():New()
	Private oVmiParametros  := OFAGVmiParametros():New()
	Private oVmi            := OFAGVmi():New()
	
	Private aFilis          := oVmiParametros:filiais()
	Private cTblLogCod
	Private aDevsFeitas     := {}
	Private aVendFeitas     := {}
	Private aOSsFeitas      := {}
	Private aTranFeitas     := {}

	nQtdDias := val(oVmiParametros:QtdDiasArmazenar())
	If nQtdDias < 99999
		cQuery := "DELETE FROM "+ RetSqlName("VB6")
		cQuery += " WHERE VB6_FILIAL = '"+xFilial("VB6")+"' "
		cQuery += "   AND VB6_DATA < '"+dtos(date()-nQtdDias)+"' "
		cQuery += "   AND VB6_FLGENV = '1' "
		TcSqlExec(cQuery)
	EndIf

	AGCA0103_GeraNovosDados()

	cQuery := "SELECT R_E_C_N_O_ AS RECNO "
	cQuery += "  FROM " + oSqlHlp:NoLock('VB6')
	cQuery += " WHERE VB6_FILIAL = '"+xFilial("VB6")+"' "
	cQuery += "   AND VB6_FLGENV = '0' "
	cQuery += "   AND VB6_IMPEDI = '0' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "
	cQuery := oSqlHlp:TopFunc(cQuery,200)
	For nX := 1 to 10
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
		while !(cAl)->(eof())
			oVmi:Enviar((cAl)->RECNO,.f.)
			(cAl)->(DBSkip())
		end
		(cAl)->(dbCloseArea())
	Next
	dbSelectArea("VB6")
	
Return .T.

/*/{Protheus.doc} AGCA0101_GravaNumSeq
	Grava o NUMSEQ final do SD1/SD2/SD3

	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Function AGCA0101_GravaNumSeq( cD1_NUMSEQ , cD2_NUMSEQ , cD3_NUMSEQ )
Local oConfig := OFAGCA01Config():New()
Local jJson := JsonObject():New()
//
jJson["D1_NUMSEQ"] := cD1_NUMSEQ
jJson["D2_NUMSEQ"] := cD2_NUMSEQ
jJson["D3_NUMSEQ"] := cD3_NUMSEQ
//
oConfig:Save(jJson)
return .t.

/*/{Protheus.doc} AGCA0102_UltimoNumSeq
	Pega o ultimo NUMSEQ do SD1/SD2/SD3

	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Function AGCA0102_UltimoNumSeq(cNUMSEQ)
Local oConfig := OFAGCA01Config():New()
Return oConfig:GetValue( cNUMSEQ , space(6) )

/*/{Protheus.doc} AGCA0103_GeraNovosDados
	Busca por novos dados de movimentação para atualizar as interfaces necessárias
	e grava o numseq para definir onde parou

	@author Vinicius Gati
	@since 30/06/2017
/*/
Function AGCA0103_GeraNovosDados()
	local cQuery    := ""
	Local nIdx      := 1
	Local cAl       := GetNextAlias()
	local oVmiPars  := OFAGVmiParametros():New()
	local oVmi      := OFAGVmi():New()
	Local cGrupos   := oVmiPars:todosGrupos() // Retorna TODOS os Grupos (Originais e Paralelos) para serem utilizados nas Querys
	Local aNumSeq   := {} // Parametros ( inicial e final ) para levantamentos ( D1_NUMSEQ / D2_NUMSEQ / D3_NUMSEQ )
	
	cNroIni := AGCA0102_UltimoNumSeq('D1_NUMSEQ')
	aAdd(aNumSeq,{ cNroIni , AGCA107L_FiltraSD('SD1','D1',cNroIni)})

	cNroIni := AGCA0102_UltimoNumSeq('D2_NUMSEQ')
	aAdd(aNumSeq,{ cNroIni , AGCA107L_FiltraSD('SD2','D2',cNroIni)})

	cNroIni := AGCA0102_UltimoNumSeq('D3_NUMSEQ')
	aAdd(aNumSeq,{ cNroIni , AGCA107L_FiltraSD('SD3','D3',cNroIni)})

	cQuery += " SELECT D1_COD, D2_COD, D3_COD, CODIGO, RECNO FROM ( "
	cQuery += "     SELECT D1_COD, '' as D2_COD, '' as D3_COD, D1_COD as CODIGO, R_E_C_N_O_ as RECNO "
	cQuery += "       FROM "+oSqlHlp:NoLock('SD1')
	cQuery += "      WHERE SD1.D1_FILIAL  = '"+xFilial('SD1')+"' "
	cQuery += "        AND SD1.D1_NUMSEQ  > '"+aNumSeq[1,1]+"' "
	cQuery += "        AND SD1.D1_NUMSEQ <= '"+aNumSeq[1,2]+"' "
	cQuery += "        AND SD1.D_E_L_E_T_ = ' ' "
	// cQuery += "   UNION "
	// cQuery += "     SELECT '' as D1_COD, D2_COD, '' AS D3_COD, D2_COD as CODIGO, R_E_C_N_O_ as RECNO "
	// cQuery += "       FROM "+oSqlHlp:NoLock("SD2")
	// cQuery += "      WHERE SD2.D2_FILIAL  = '"+xFilial('SD2')+"' "
	// cQuery += "        AND SD2.D2_NUMSEQ  > '"+aNumSeq[2,1]+"' "
	// cQuery += "        AND SD2.D2_NUMSEQ <= '"+aNumSeq[2,2]+"' "
	// cQuery += "        AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "   UNION "
	cQuery += "     SELECT '' as D1_COD, '' as D2_COD, D3_COD, D3_COD as CODIGO, R_E_C_N_O_ as RECNO "
	cQuery += "       FROM "+oSqlHlp:NoLock('SD3')
	cQuery += "      WHERE SD3.D3_FILIAL  = '"+xFilial('SD3')+"' "
	cQuery += "        AND SD3.D3_NUMSEQ  > '"+aNumSeq[3,1]+"' "
	cQuery += "        AND SD3.D3_NUMSEQ <= '"+aNumSeq[3,2]+"' "
	cQuery += "        AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += " ) TBTMP "
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = CODIGO AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SB1.B1_GRUPO IN ("+cGrupos+") "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
	while !( (cAl)->(eof()) )
		if ! Empty((cAl)->D1_COD)
			AGCA0104_EnviaDev((cAl)->RECNO)
		elseif ! Empty((cAl)->D3_COD)
			AGCA0105_EnviaTrf((cAl)->RECNO)
		// else // SD2 Comentado pois esses envios de vendas já são feito a cada movimentação
		// 	AGCA0106_EnviaVenda((cAl)->RECNO)
		end
		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())

	// Grava o ultimo NUMSEQ do SD1/SD2/SD3
	AGCA0101_GravaNumSeq( aNumSeq[1,2] , aNumSeq[2,2] , aNumSeq[3,2] ) // D1_NUMSEQ / D2_NUMSEQ / D3_NUMSEQ

Return .T.

/*/{Protheus.doc} AGCA0104_EnviaDev
	Pega numero do orcamento da devolucao para enviar ao VMI

	@author Vinicius Gati
	@since 04/07/2017
	@type function
/*/
Static Function AGCA0104_EnviaDev(nRecnoD1)
	local cNumOrc := ""
	local cQuery  := " SELECT DISTINCT VS1_NUMORC "
	cQuery += "    FROM "+oSqlHlp:NoLock('SD1')
	cQuery += "    JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD     = SD1.D1_COD      AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF2')+" ON SF2.F2_FILIAL = '"+xFilial("SD1")+"' AND SF2.F2_DOC     = SD1.D1_NFORI    AND SF2.F2_SERIE   = SD1.D1_SERIORI  AND SF2.D_E_L_E_T_ = ' '  "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SD2')+" ON SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_DOC     = SF2.F2_DOC      AND SD2.D2_SERIE   = SF2.F2_SERIE    AND SD2.D2_COD     = SD1.D1_COD     AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' '  "
	cQuery += "    JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL= '"+xFilial("VS1")+"' AND VS1.VS1_NUMNFI = SD2.D2_DOC      AND VS1.VS1_SERNFI = SD2.D2_SERIE    AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO  = SD2.D2_TES      AND SF4.F4_OPEMOV  = '05'            AND SF4.D_E_L_E_T_ =' '  "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF4', 'SF4_SD1')+" ON SF4_SD1.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4_SD1.F4_CODIGO  = SD1.D1_TES AND SF4_SD1.F4_OPEMOV  = '09' AND SF4_SD1.D_E_L_E_T_ =' '  "
	cQuery += "   WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'  "
	cQuery += "     AND SD1.R_E_C_N_O_ = "+ALLTRIM(STR(nRecnoD1))
	cQuery += "     AND SF4_SD1.F4_OPEMOV = '09' "
	cQuery += "     AND SD1.D_E_L_E_T_ = ' ' "
	cNumOrc := FM_SQL(cQuery)
	if ! Empty(cNumOrc)
		if ascan(aDevsFeitas, {|cDev| cDev == cNumOrc}) <= 0
			oVMi:Trigger({;
				{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
				{'ORIGEM'          , "OFAGCA0104_DMS4"            },;
				{'NUMERO_ORCAMENTO', cNumOrc                      } ;
			})
			aadd(aDevsFeitas, cNumOrc)
		endif
	end
Return .T.

/*/{Protheus.doc} AGCA0105_EnviaTrf
	Pega orçamento de transferencia para enviar a VMI com dados atualizados

	@author Vinicius Gati
	@since 04/07/2017
	@type function
/*/
Static Function AGCA0105_EnviaTrf(nRecnoD3)
	local cNumOrc := ''
	local cQuery  := " SELECT DISTINCT VS3_NUMORC "
	cQuery +=        "  FROM "+oSqlHlp:NoLock('SD3')
	cQuery +=        "  JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_DOCSDB = D3_DOC AND VS3.D_E_L_E_T_ = ' ' "
	cQuery +=        " WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"'  "
	cQuery +=        "   AND SD3.R_E_C_N_O_ = "+ALLTRIM(STR(nRecnoD3))
	cQuery +=        "   AND SD3.D_E_L_E_T_ = ' ' "
	cNumOrc := FM_SQL(cQuery)
	if ! Empty(cNumOrc)
		if ascan(aTranFeitas, {|cTrf| cTrf == cNumOrc}) <= 0
			oVMi:Trigger({;
				{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
				{'ORIGEM'          , "OFAGCA0105_DMS4"            },;
				{'NUMERO_ORCAMENTO', cNumOrc                      } ;
			})
			aadd(aTranFeitas, cNumOrc)
		endif
	end
Return .T.

/*/{Protheus.doc} AGCA0106_EnviaVenda
	Pega orçamento de transferencia para enviar a VMI com dados atualizados

	@author Vinicius Gati
	@since 04/07/2017
	@type function
/*/
Static Function AGCA0106_EnviaVenda(nRecnoD2)
	local cAl := GetNextAlias()
	local cQuery := " SELECT VEC_NUMORC, VEC_NUMOSV "
	cQuery += "  FROM "+oSqlHlp:NoLock('SD2')
	cQuery += "  JOIN "+oSqlHlp:NoLock('VEC')+" ON VEC_FILIAL = '"+xFilial('VEC')+"' AND VEC_NUMNFI = D2_DOC AND VEC_SERNFI = D2_SERIE AND VEC.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'  "
	cQuery += "   AND SD2.R_E_C_N_O_ = "+ALLTRIM(STR(nRecnoD2))
	cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "   GROUP BY VEC_NUMORC, VEC_NUMOSV "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. ) 
	while ! (cAl)->(eof())
		
		if Empty( (cAl)->(VEC_NUMORC) )
			if ascan(aOSsFeitas, {|cOs| cOs == (cAl)->(VEC_NUMOSV) }) <= 0
				oVMi:Trigger({;
					{'EVENTO'   , oVmi:oVmiMovimentos:OS},;
					{'ORIGEM'   , "OFAGCA0106_DMS4_OS"  },;
					{'NUMERO_OS', (cAl)->VEC_NUMOSV     } ;
				})
				AADD(aOSsFeitas, (cAl)->VEC_NUMOSV)
			endif
		else
			if ascan(aVendFeitas, {|cOrc| cOrc == (cAl)->VEC_NUMORC}) <= 0
				oVMi:Trigger({;
					{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
					{'ORIGEM'          , "OFAGCA0106_DMS4_ORC"        },;
					{'NUMERO_ORCAMENTO', (cAl)->VEC_NUMORC            } ;
				})
				AADD(aVendFeitas, (cAl)->VEC_NUMORC)
			endif
		end

		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())
Return .T.

/*/{Protheus.doc} AGCA107L_FiltraSD
	Limita a quantidade de registros gerados no envio diário do VMI
	@author Leonardo Menendes Solera	
	@since 13/06/2025
	@type function
/*/
Static Function AGCA107L_FiltraSD(cTabela,cCpo,cNroIni)
Local cQuery   := ""
Local nLimit   := 100

cQuery := "SELECT "+cTabela+"."+cCpo+"_NUMSEQ"
cQuery += "  FROM "+oSqlHlp:NoLock(cTabela)
cQuery += " WHERE "+cTabela+"."+cCpo+"_FILIAL = '" + xFilial(cTabela) + "'"
cQuery += "   AND "+cTabela+"."+cCpo+"_NUMSEQ > '" +cNroIni+ "'"
cQuery += "   AND "+cTabela+".D_E_L_E_T_ = ' '"
cQuery += " ORDER BY "+cTabela+"."+cCpo+"_NUMSEQ"
cQuery := oSqlHlp:TOPFunc(cQuery, nLimit)
cQuery := "SELECT MAX(TEMP."+cCpo+"_NUMSEQ) FROM ("+cQuery+") TEMP "

Return FM_SQL(cQuery)

/*/{Protheus.doc} OFAGCA01Config
	Classe principal para tratar os dados SD1/SD2/SD3
	
	@type class
	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Class OFAGCA01Config
	Public Data cCodigo
	Public Data cFilConf
	Data jConfig

	Public Method New() CONSTRUCTOR
	Public Method GetValue()
	Public Method Save()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type method
	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Method New() Class OFAGCA01Config
	::cCodigo  := "OFAGCA01"
	::cFilConf := Padr(cFilAnt,FWSizeFilial()) // Carrega a Filial Logada
	::jConfig  := JsonObject():New()
	dbselectArea("VRN")
	dbSetOrder( 2 ) // Ordem do VRN
	If dbSeek(xFilial("VRN") + ::cFilConf + ::cCodigo)
		::jConfig:FromJson(VRN->VRN_CONFIG)
	Else
		VRN->(reclock("VRN", .T.))
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := ::cCodigo
		VRN->VRN_CONFIG := "{}"
		VRN->VRN_FILCON := ::cFilConf
		VRN->(msUnlock())
	EndIf	
Return SELF

/*/{Protheus.doc} GetValue
	retorna o valor contido no json para o parametro passado

	@type method
	@author Andre Luis Almeida
	@since 26/06/2025
 /*/

Method GetValue(cLabel, xDef) Class OFAGCA01Config
if self:jConfig:hasProperty(cLabel)
	return self:jConfig[cLabel]
endif
Return xDef

/*/{Protheus.doc} Save
	salva json com a configuração

	@type method
	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Method Save(jConfig) Class OFAGCA01Config
	dbselectArea("VRN")
	dbSetOrder(2)
	If dbSeek(xFilial("VRN") + self:cFilConf + self:cCodigo)
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := jConfig:toJSON()
		msUnlock()
	EndIf
	self:jConfig := jConfig
Return .t.