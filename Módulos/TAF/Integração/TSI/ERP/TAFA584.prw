#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "SPEDFISCAL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "SPEDXDEF.CH"

STATIC aSPDSX2	  := SpedLoadX2()
STATIC aSPDSX3	  := SpedLoadX3()
STATIC aSPDSX6	  := SpedLoadX6()
STATIC nTamIdSub  := TamSX3( "CHY_CODIGO" )[1]
STATIC nTamCodAj  := TamSX3( "C1A_CODIGO" )[1]
STATIC nTamCodAut := TamSX3( "T02_CODIGO" )[1]
STATIC lNewCtrl   := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
STATIC cUltStmp   := iif(lNewCtrl, TsiUltStamp("C2S"),' ')

/*/{Protheus.doc} TSIAPURICMS
Classe que contém preparedstatament do T020 - Apuração de ICMS

@type Class
@author Renan Gomes
@since 13/07/2021
@return Nil, nulo, não tem retorno.
/*/ 

Class TSIAPURICMS

	Data TSITQRY     as String ReadOnly
	Data cFinalQuery as String ReadOnly
	Data oStatement  as Object ReadOnly
	Data aFilC2S     as Array ReadOnly
	Data oJObjTSI    as Object

	Method New( ) Constructor
	Method PrepQuery( )
	Method LoadQuery( )
	Method JSon( )
	Method FilC2S( )

	Method GetQry( )
	Method GetJsn( )

EndClass

/*/{Protheus.doc} New
Método contrutor da classe TSIAPURICMS

Fluxo New:
1º Monta-se a query com LoadQuery()
2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
cFinalQuery com a query final já com os parâmetros

@type Class
@author Renan Gomes
@since 13/07/2021
@return Nil, nulo, não tem retorno
/*/

Method New( cSourceBr ) Class TSIAPURICMS
	Self:FilC2S( cSourceBr )
	Self:LoadQuery( )
	Self:PrepQuery( )
	Self:JSon( )
Return

/*/{Protheus.doc} PrepQuery   
Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
cFinalQuery com a query final já com os parâmetros

@type Class
@author Renan Gomes
@since 13/07/2021
@return Nil, nulo, não tem retorno.
/*/

Method PrepQuery( ) Class TSIAPURICMS

	self:oStatement := FWPreparedStatement( ):New( )
	self:oStatement:SetQuery( self:TSITQRY )
	self:oStatement:SetIn( 1, self:aFilC2S )           			// par01
	self:cFinalQuery := self:oStatement:GetFixQuery( )

Return

 /*/{Protheus.doc} PrepQuery
	Método responsável por montar a query para o preparedstatemen

	@author Renan Gomes
	@since 13/07/2021
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery( ) Class TSIAPURICMS

	Local cDbType := Upper( Alltrim( TCGetDB( ) ) )
	Local cQuery  := ""
	Local cConvCpo := ""

	//Verifico se tem alguma apuração não integrada para exportar
	cQuery += " SELECT "
	//Converte o conteúdo do campo conforme o banco de dados usado.
	If cDbType $ "MSSQL/MSSQL7"
		cConvCpo := " convert(varchar(23), CDH.S_T_A_M_P_, 21) "
	Elseif cDbType $ "ORACLE"
		cConvCpo := " cast(to_char(CDH.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) "
	Elseif cDbType $ "POSTGRES"
		cConvCpo := " cast( CDH.S_T_A_M_P_ AS CHAR(23)) "
	Endif
	cQuery += cConvCpo + " STAMP, "
	cQuery += " CDH_FILIAL,  "
	cQuery += " CDH_TIPOIP, "
	cQuery += " CDH_TIPOPR, "
	cQuery += " CDH_PERIOD, "
	cQuery += " CDH_LIVRO, "
	cQuery += " CDH_DTINI, "
	cQuery += " CDH_DTFIM "
	cQuery += " FROM " + RetSqlName( "CDH" ) + " CDH "

	If !lNewCtrl .OR. Empty(cUltStmp)
		cQuery += " LEFT JOIN " + RetSqlName( "C2S" ) + " C2S ON C2S.C2S_FILIAL = CDH.CDH_FILIAL"
		cQuery += " 				AND C2S.C2S_DTINI = CDH.CDH_DTINI "
		cQuery += " 				AND C2S.C2S_DTFIN = CDH.CDH_DTFIM "
		cQuery += " 				AND C2S.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += " WHERE CDH.D_E_L_E_T_ = ' ' "
	cQuery += " AND CDH.CDH_FILIAL IN (?) "  //1
	cQuery += " AND CDH.CDH_TIPOIP = 'IC' "
	cQuery += " AND  CDH.CDH_TIPOPR = '3' "//MENSAL
	cQuery += " AND  CDH.CDH_LIVRO = '*' "
	cQuery += " AND  CDH.CDH_PERIOD = '1' "// 1º PERIODO
	cQuery += " AND CDH_SEQUEN = (SELECT MAX(CDHMAX.CDH_SEQUEN)  " //USANDO MAX NO WHERE PARA SEMPRE PEGAR A ULTIMA APURAÇÃO
	cQuery += " 								FROM " + RetSqlName( "CDH" ) + " CDHMAX  "
	cQuery += " 								WHERE CDHMAX.D_E_L_E_T_ = ' '  "
	cQuery += " 								AND CDHMAX.CDH_TIPOIP =  CDH.CDH_TIPOIP "
	cQuery += " 								AND CDHMAX.CDH_FILIAL = CDH.CDH_FILIAL "
	cQuery += " 								AND CDHMAX.CDH_TIPOPR = CDH.CDH_TIPOPR "
	cQuery += " 								AND CDHMAX.CDH_PERIOD =  CDH.CDH_PERIOD "
	cQuery += " 								AND CDHMAX.CDH_LIVRO =  CDH.CDH_LIVRO "
	cQuery += " 								AND CDHMAX.CDH_DTINI = CDH.CDH_DTINI  "
	cQuery += " 								AND CDHMAX.CDH_DTFIM = CDH.CDH_DTFIM ) "
	cQuery += " AND (CDH_LINHA = '010') " //FILTRO pelo 010 para garantir buscar apenas uma linha por apuração
	cQuery += " AND CDH.S_T_A_M_P_ IS NOT NULL "
	
	If !lNewCtrl .OR. Empty(cUltStmp)
		If cDbType $ "ORACLE"
			cQuery += " AND ((C2S.C2S_STAMP IS NULL OR Length(trim(C2S.C2S_STAMP)) = 0 OR Length(trim(C2S.C2S_STAMP)) IS NULL ) OR ( Length(trim(C2S.C2S_STAMP)) > 0 AND CDH.S_T_A_M_P_ > TO_TIMESTAMP(C2S.C2S_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') ) )"
		else
			cQuery += " AND ( " + cConvCpo + " > C2S.C2S_STAMP OR C2S.C2S_STAMP IS NULL) "
		endif
	Else
		If cDbType $ "ORACLE"
			cQuery += "  AND CDH.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
		else
			cQuery += "  AND " + cConvCpo + " > '" + Alltrim(cUltStmp) + "' "
		endif
	EndIf

	cQuery += " ORDER BY CDH.CDH_DTFIM DESC "

	self:TSITQRY := cQuery

Return

 /*/{Protheus.doc} PrepQuery
	Método responsável por retornar a propriedade self:cFinalQuery

	@author Renan Gomes
	@since 13/07/2021
	@return cFinalQuery  - String com a query já montada e pronta para ser executada
/*/

Method GetQry( ) Class TSIAPURICMS
return self:cFinalQuery

 /*/{Protheus.doc} JSon
	Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI

	@author Renan Gomes
	@since 13/07/2021
	@return Nil, nulo, não tem retorno.
/*/

Method JSon( ) Class TSIAPURICMS

	Local cAlias      := getNextAlias( )
	Local oJObjRet    := nil
	Local dDataDe     := ''
	Local dDataAte    := ''
	Local nApuracao   := 3
	Local nPeriodo    := 1
	Local cNrLivro    := ''
	Local aLanCDA     := {}
	Local aRegT020    := {}
	Local aRegT020AA  := {}
	Local aRegT020AB  := {}
	Local aRegT020AC  := {}
	Local aRegT020AD  := {}
	Local aRegT020AE  := {}
	Local aRegT020AG  := {}
	Local cMVSUBTRIB  := GetSubTrib()
	Local cMVEstado   := aSPDSX6[MV_ESTADO]
	Local lTop 	      := .T. //Para utilizar o TAF deve possuir ambiente TOP
	Local nRegAA      := 0
	Local nRegAG      := 0
	Local cRelIdC2S	  := GetSx3Cache("C2S_ID","X3_RELACAO")
	Local lIdC2SErr   := '("C2S","C2S_ID")' $ UPPER(cRelIdC2S) //Se inic. padrão não tiver passando o indice 2, retorno o max _ID

	dbUseArea(.T., "TOPCONN", TCGenQry(, , self:GetQry()), cAlias, .F., .T.)
	TAFConOut( "TSILOG000014: Query de busca do cadastro de apurações de Icms [ " + self:GetQry() + " ]")
	
	oJObjRet := JsonObject( ):New( )
	aApurationIcms := { }

	While ( cAlias )->( !EOF( ) )

		dDataDe    := STOD(( cAlias )->CDH_DTINI)
		dDataAte   := STOD(( cAlias )->CDH_DTFIM)
		cFilDe     := ( cAlias )->CDH_FILIAL
		cFilAte    := ( cAlias )->CDH_FILIAL
		cNrLivro   := ( cAlias )->CDH_LIVRO

		lSeekCDH	:=	TsiIcmApur(cFilDe,cFilAte,nApuracao,nPeriodo,cNrLivro,"IC",dDataDe,dDataAte,;
			cMVEstado,lTop,cMVSUBTRIB,aLanCDA, ,@aRegT020,@aRegT020AA,@aRegT020AB,@aRegT020AC,;
			@aRegT020AE,, @aRegT020AG, @aRegT020AD )

			// Adiciona os registros de apuração da nota
    		fGetApurNf(@aRegT020AA,dDataDe)

		If len(aRegT020) > 0
			//Crio Objeto da apuração - T020
			oJObjApurIcm := JsonObject( ):New( ) 
			
			//Busco ID manualmente apenas se Inic. Padrão estiver errado 
			If lIdC2SErr
				oJObjApurIcm["apurationId"]   	:= GetSx8Num("C2S","C2S_ID",,2)
				C2S->( ConfirmSX8() )        
			Endif
			
			oJObjApurIcm["typeApuration"]               := "0"
			oJObjApurIcm["dateInitialApuration"]        := STOD(( cAlias )->CDH_DTINI)
			oJObjApurIcm["dateFinalApuration"]          := STOD(( cAlias )->CDH_DTFIM)
			oJObjApurIcm["indicatorApuration"]          := ""
			oJObjApurIcm["descriptionComplementary"]    := ""
			oJObjApurIcm["valueTotalDebts"]             := aRegT020[2]
			oJObjApurIcm["valueAdjustmentDebts"]        := aRegT020[3]
			oJObjApurIcm["valueTotalAdjustmentDebts"]   := aRegT020[4]
			oJObjApurIcm["valueReversalCredit"]         := aRegT020[5]
			oJObjApurIcm["valueTotalCredits"]           := aRegT020[6]
			oJObjApurIcm["valueAdjustmentCredits"]      := aRegT020[7]
			oJObjApurIcm["valueTotalAdjustmentCredits"] := aRegT020[8]
			oJObjApurIcm["valueReversalDebts"]          := aRegT020[9]
			oJObjApurIcm["balanceCreditPeridPrevios"]   := aRegT020[10]
			oJObjApurIcm["balanceDebtVerified"]         := aRegT020[11]
			oJObjApurIcm["totalDeductions"]             := aRegT020[12]
			oJObjApurIcm["totalToRecall"]               := aRegT020[13]
			oJObjApurIcm["balanceCreditNextPeriod"]     := aRegT020[14]
			oJObjApurIcm["debtsSpecial"]                := aRegT020[15]
			oJObjApurIcm["stamp"]                       := ( cAlias )->STAMP

		
			//Crio array dos ajustes de apurações -  T020AA
			aAdjustmentApuration	:= {}
		
			for nRegAA := 1 to len(aRegT020AA)
				//Crio Objeto de ajustes de apurações - T020AA
				oJObjAjust := JsonObject( ):New( ) 
				
				cSubItem := aRegT020AA[nRegAA][06]
				
				// Se existir a posição 7
				If Len(aRegT020AA[nRegAA]) >= 7 
					cCodLanNf := aRegT020AA[nRegAA][07]
				else
					cCodLanNf := ""
				EndIf

				// Busco o código do motivo e subitem que devo enviar no registro da apuração
				aSubItem := FSubItRegras(cMVEstado,,,cSubItem)

				oJObjAjust["seqReg"]            	  := nRegAA
				oJObjAjust["adjustmentCode"]          := PADR(alltrim(aRegT020AA[nRegAA][3]),nTamCodAj)
				oJObjAjust["complementaryAdjustment"] := UPPER(alltrim(aRegT020AA[nRegAA][4]))
				oJObjAjust["valueAdjustment"]         := aRegT020AA[nRegAA][5]
				oJObjAjust["subItemCode"]             := SubStr(StrTran(AllTrim(aSubItem[1]),".",""),1,nTamIdSub)
				oJObjAjust["reasonCode"]              := aSubItem[2]
				oJObjAjust["codeAdjInvoice"]          := cCodLanNf
				oJObjAjust["complemNote1"]            := cCodLanNf
				oJObjAjust["complemNote2"]            := ""
				oJObjAjust["complemNote3"]            := ""
				
				//Crio array dos ajustes acumulados - T020AG
				aAccumulatedAdjust := {}

				for nRegAG := 1 to len(aRegT020AG)

					if (Alltrim(aRegT020AG[nRegAG,3]) ==  aRegT020AA[nRegAA,3]  + AllTrim(aRegT020AA[nRegAA,6]))  .and. (AllTrim(aRegT020AG[nRegAG,1]) ==  AllTrim(aRegT020AA[nRegAA,4]))    
						// Geração do registro T020AG
						oJObjAcum := JsonObject( ):New( )

						oJObjAcum["seqReg"]            := nRegAG
						oJObjAcum["authorizationCode"] := PADR(Alltrim(aRegT020AG[nRegAG][1]),nTamCodAut)
						oJObjAcum["valueCredIcms"]     := aRegT020AG[nRegAG][2]
					
						aAdd( aAccumulatedAdjust, oJObjAcum )
					Endif
					
				next
				
				//Atualizo objeto T020AA com array de objetos T020AG
				oJObjAjust["accumulatedAdjust"] := aAccumulatedAdjust
				
				//Adiciono objeto filho T020AA dentro do array
				aAdd( aAdjustmentApuration, oJObjAjust )
			next
			
			//Atualizo objeto T020 com array de objetos T020AA
			oJObjApurIcm['adjustmentApuration'] := aAdjustmentApuration
			
			//Adiciono objeto pai T020 dentro do array
			aadd(aApurationIcms,oJObjApurIcm)
			
		Endif

		( cAlias )->( DBSKIP( ) )

	EndDo

	oJObjRet['apurationIcms'] := aApurationIcms

	self:oJObjTSI := oJObjRet

	( cAlias )->( DbCloseArea( ) )

Return

 /*/{Protheus.doc} GetJsn
	Método responsável retornar a propriedade self:oJObjTSI

	@author Renan Gomes
	@since 13/07/2021
	@return oJObjTSI - Objeto TSIAPURICMS com o Json gerado com as informações de apuração T020
/*/
Method GetJsn ( ) Class TSIAPURICMS
Return self:oJObjTSI

 /*/{Protheus.doc} TSIAPURICMS
	Método responsável por montar o conteúdo da filial da C2S

	@author Renan Gomes
	@since 13/07/2021
	@return Nil, nulo, não tem retorno.
/*/
Method FilC2S( cSourceBr ) Class TSIAPURICMS
	self:aFilC2S := TafTSIFil( cSourceBr, "C2S" )
Return

/*----------------------------------------------------------------------
{Protheus.doc} IntNCMTSI()
(Teste de integração via menu. Deve ser retirada apos criação do JOB de execução.
@author Renan Gomes
@since 01/12/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Function IntAPURICMS()

Local oObjAPURICMS := TSIAPURICMS():New(cEmpAnt+cFilAnt)
Local oObjJson     := oObjAPURICMS:GetJsn()

WsTSIProc( oObjJson, .T., HashC2S()   ) //Processamento de importação das apurações

freeobj( oObjAPURICMS )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    TsiIcmApur | Autor ³Renan Gomes 			  	   ³ Data ³19.07.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                        GERACAO DO LAYOUT T020                     ³±± 
±±³          ³REGISTRO E100 - PERIODO DA APURACAO DO ICMS                        ³±± 
±±³          ³REGISTRO E110 - T020 - APURACAO DE ICMS - OPERACOES PROPRIAS       ³±± 
±±³          ³REGISTRO E111 - T020AA - AJUSTES INCENTIVO DA APURACAO DE ICMS     ³±± 
±±³          ³REGISTRO E111 - T020AG - CREDITO ACUMULADOS DE ICMS                ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Identifica se houve movimento no periodo ou nao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cFilDe   - Filial inicial para processament multifilial            ³±±
±±³          ³cFilAte  - Filial final para processament multifilial              ³±±
±±³          ³nApuracao -> Tipo de apuracao, padrao 3                            ³±±
±±³          ³nPeriodo  -> Periodo de apuracao, padrao 1                         ³±±
±±³          ³cNrLivro  -> Numero do livro selecionado no wizard                 ³±±
±±³          ³cImp -> imposto de processamento. IC=ICMS,ST=SUBST. TRIBUTARIA     ³±±
±±³          ³dDataDe -> Data inicio de processamento inf. no wizard             ³±±
±±³          ³dDataAte -> Data final de processamento inf. no wizard             ³±±
±±³			 ³cMVEstado -> Conteudo do parametro MV_ESTADO                       ³±±
±±³          ³lTop     - Flag para identificar ambiente TOP                      ³±±
±±³          ³lImpCrdST -> Flago de processamento do CredST conforme wizard      ³±±
±±³          ³cMVSUBTRIB -> Conteudo do parametro MV_SUBTRIB 					 ³±±
±±³			 ³aLanCDA -> Array contendo a tabela CDA.		                     ³±±
±±³			 ³aRegT020 -> Gera informacoes do Registro T020 do TAF               ³±±
±±³			 ³aRegT020AA -> Gera informacoes do Registro T020AA do TAF           ³±±
±±³			 ³aRegT020AB -> Gera informacoes do Registro T020AB do TAF           ³±±
±±³			 ³aRegT020AC -> Gera informacoes do Registro T020AC do TAF           ³±±
±±³			 ³aRegT020AE -> Gera informacoes do Registro T020AE do TAF           ³±±
±±³			 ³cVerSPDFis -> Versão do SPED FISCAL                                ³±±
±±³			 ³aRegT020AG -> Gera informacoes do Registro T020AG do TAF           ³±±
±±³			 ³aRegT020AD -> Gera informacoes do Registro T020AD do TAF           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATAF - TAFA584                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Importante³                                                                   ³±±
±±³ 19/07/21 ³Função clone da SPDAPICMS                                          ³±±  
±±³ 19/07/21 ³Atualmente essa função está extraindo os layout, T020, T020AA e    ³±±  
±±³          ³T020AG, para atender a GIA-SP, conforme for entrando novos layouts ³±±  
±±³          olhar a rega de no fonte na função SPDAPICMS do SPEDFISCAL.PRW      ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TsiIcmApur(	cFilDe,		cFilAte,	nApuracao,	nPeriodo,		cNrLivro,	cImp,		dDataDe,;
					dDataAte,	cMVEstado,	lTop,  cMVSUBTRIB,	aLanCDA,   	lOldLan,;
					aRegT020,	aRegT020AA, aRegT020AB,	aRegT020AC, aRegT020AE,	cVerSPDFis,	;
					aRegT020AG,  aRegT020AD )

Local cChave        := STR(nApuracao,1)+STR(nPeriodo,1)+DTOS(dDataDe)+cNrLivro
Local lRet          := .T.
Local cSomaSeq      := ""
Local cSequen       := ""
Local aParametros   := {}
Local cUf           := cMvEstado
Local cCodAjApur    := ""
Local cAliasCDH     := "CDH"
Local nPosE111      := 0
Local nPosT020AG    := 0
Local aRegE110      := {"E110", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local aRegE111      := {}
Local aRegE112      := {}
Local aRegE113      := {}
Local aRegE116      := {}
Local aRegE115      := {}
Local nTamCdhDes    := TamSx3("CDH_DESC")[1]
Local nScanE11      := 0
Local cDescAj       := ""

Default aLanCDA     := {}
Default lOldLan     := (aSPDSX2[AI_CC6] .And. aSPDSX3[FP_CC6_TIPOAJ])
Default aRegT020    := {}
Default aRegT020AA  := {}
Default aRegT020AB  := {}
Default aRegT020AC  := {}
Default aRegT020AD  := {}
Default aRegT020AE  := {}
Default aRegT020AG  := {}
Default cVerSPDFis  := cVersao

//³Para ambiente TOP nao preciso pegar a ultima sequencia, pois isso eh resolvido na propria query³
If !lTop
	If CDH->(MsSeek(xFilial("CDH")+cImp+cChave))
		cSomaSeq  := CDH->CDH_SEQUEN
		While CDH->(MsSeek(xFilial("CDH")+cImp+cChave+cSomaSeq)) // Posiciona na ultima sequencia
			cSequen  := CDH->CDH_SEQUEN
			cSomaSeq := Soma1(cSequen)
		EndDo
	EndIf
EndIf

//³Montando parametros para a query ou indregua³
aAdd(aParametros,cImp)
aAdd(aParametros,STR(nApuracao,1))
aAdd(aParametros,STR(nPeriodo,1))
aAdd(aParametros,DTOS(dDataDe))
aAdd(aParametros,cNrLivro)
aAdd(aParametros,cSequen)

If SPEDFFiltro(1,"CDH",@cAliasCDH,aParametros)

	//³REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS³
	If cImp=="IC"
		//³ Carrega ajustes na apuracao ICMS ³
		While !(cAliasCDH)->(Eof())
			
			cCodAjApur := (cAliasCDH)->CDH_CODLAN
			nPosE111   := 0
			nPosT020AG := 0
			lGeraE111  := .F.
			lGeraE116  := .F.
			
			Do Case
				//³Case que determina o calculo do (2)VL_TOT_DEBITOS = Valor total dos debitos  ³
				//³     por "SAIDAS E PRESTACOES COM DEBITO DO IMPOSTO"                         ³
				Case (cAliasCDH)->CDH_LINHA == "001"
					aRegE110[2] += (cAliasCDH)->CDH_VALOR
					
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (3)VL_AJ_DEBITOS = Valor total dos ajustes a debitos provenitentes de NF   ³
				//³- (4)VL_TOT_AJ_DEBITOS = Valor total dos ajustes a debitos                   ³
				Case (cAliasCDH)->CDH_LINHA $ "002" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "002.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)	//Lancamentos a outros debitos
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						aRegE110[3] += (cAliasCDH)->CDH_VALOR
					Else
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 0=Outros Debitos, considero este valor.            ³
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "0"
							aRegE110[4] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.
						
						//³Se for ajuste de apuracao precisa lancar no E111³
						If lOldLan	//Codigo de lancamento antigo tem outro formato, e precisa ser convertido para um DEFAULT para nao apresentar erro de validacao
							cCodAjApur := cUf+"0"+"0"+"9999"
						EndIf
					EndIf

				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (3)VL_AJ_DEBITOS = Valor total dos ajustes a debitos provenitentes de NF   ³
				//³- (5)VL_ESTORNOS_CRED = Valor total dos ajustes "ESTORNO DE CREDITOS"        ³
				Case (cAliasCDH)->CDH_LINHA $ "003" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "003.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						//|                                                            |
						//|Um lancacamento a ESTORNO DE CREDITO proveniente de NF,     |
						//|  tambem entra como DEBITO(3)                               |
						aRegE110[3] += (cAliasCDH)->CDH_VALOR
					Else
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 1=Estorno de Credito, considero este valor.        ³
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "1"
							aRegE110[5] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//³Se for ajuste de apuracao precisa lancar no E111³
						If lOldLan
							cCodAjApur := cUf+"0"+"1"+"9999"
						EndIf
					EndIf

				//³Case que determina o calculo do (6)VL_TOT_CREDITOS = Valor total dos creditos³
				//³     por "ENTRADAS E AQUISICOES COM CREDITO DO IMPOSTO"                      ³
				Case (cAliasCDH)->CDH_LINHA == "005"
					aRegE110[6] += (cAliasCDH)->CDH_VALOR

				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (8)VL_TOT_AJ_CREDITOS = Valor total dos "AJUSTES A CREDITO"                ³
				Case (cAliasCDH)->CDH_LINHA $ "006" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "006.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						aRegE110[7] += (cAliasCDH)->CDH_VALOR
					Else
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 2=Outros Creditos, considero este valor.           ³
					    If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "2"
							aRegE110[8] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//³Se for ajuste de apuracao precisa lancar no E111³
						
						If lOldLan
							cCodAjApur := cUf+"0"+"2"+"9999"
						EndIf
					EndIf

				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (9)VL_ESTORNOS_DEB = Valor total dos ajustes "ESTORNO DE DEBITOS"          ³
			
				Case (cAliasCDH)->CDH_LINHA $ "007" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "007.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						aRegE110[7] += (cAliasCDH)->CDH_VALOR
					Else
						//Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for
						//0=ICMS e a quarta for 3=Estorno de debitos, considero este valor.
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="3"
							aRegE110[9] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//Se for ajuste de apuracao precisa lancar no E111
						If lOldLan
							cCodAjApur := cUf+"0"+"3"+"9999"
						EndIf
					EndIf

				//Case que determina o calculo do (10)VL_SLD_CREDOR_ANT = Valor total do "SALDO CREDOR DO PERIODO ANTERIOR"
				Case (cAliasCDH)->CDH_LINHA == "009"
					aRegE110[10] += (cAliasCDH)->CDH_VALOR
					
				//Case que determina o calculo do (10)VL_SLD_APURADO = Valor do saldo devedor apurado                                                                    ³
				Case (cAliasCDH)->CDH_LINHA == "011"
					aRegE110[11] += (cAliasCDH)->CDH_VALOR

				//Case que determina o calculo de 2 lancamentos:
				//- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF
				//- (12)VL_TOT_DED = Valor total de "DEDUCOES"
				Case (cAliasCDH)->CDH_LINHA $ "012" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "012.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes
					//O valor informado deve corresponder ao somatorio do campo VL_ICMS dos registros C197 e D197,se
					//o terceiro caractere do codigo de ajuste dos registros C197 ou D197 for '0', '1' ou '2' e o
					//quarto caractere for '0', '3', '4' ou '5'.
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10 .And. SubStr((cAliasCDH)->CDH_CODLAN,3,1)$'012' .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)$'0345' ) //Tamanho 10 eh soh os lancamentos de NF
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						aRegE110[7] += (cAliasCDH)->CDH_VALOR
					
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for 0=ICMS e a quarta		³
					//³for 4=Deducoes, considero este valor.               												    ³
					Elseif ( Len(Alltrim((cAliasCDH)->CDH_CODLAN))==8 .And. SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="4" )
						aRegE110[12] += (cAliasCDH)->CDH_VALOR
						//³Se for ajuste de apuracao precisa lancar no E111³
						lGeraE111	:=	.T.
						If lOldLan
							cCodAjApur := cUf+"0"+"4"+"9999"
						EndIf
					
					//Quando se tratar dos codigos de 10 posicoes (documento):
					//o valor informado deve corresponder ao somatorio do campo VL_ICMS dos registros C197 e D197, se o 
					//terceiro caractere do codigo de ajuste do registro C197 ou D197, for '6' e o quarto caractere for '0'
					Elseif	( Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10 .And. SubStr((cAliasCDH)->CDH_CODLAN,3,1)$'6' .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)$'0' ) //Tamanho 10 eh soh os lancamentos de NF
						aRegE110[12] += (cAliasCDH)->CDH_VALOR
					Endif	
					
				//Case que determina o calculo do (13)VL_ICMS_RECOLHER = Valor total de "ICMS A RECOLHER"
				Case (cAliasCDH)->CDH_LINHA == "013"
					aRegE110[13] += (cAliasCDH)->CDH_VALOR
					
				//Case que determina o calculo do (14)VL_SLD_CREDOR_TRANSPORTAR = Valor total
				//de "SALDO CREDOR A TRANSPORTAR PARA O PERIODO SEGUINTE"
				Case (cAliasCDH)->CDH_LINHA == "014"
					aRegE110[14] += (cAliasCDH)->CDH_VALOR 				
					
				//Case que determina o calculo de 2 lancamentos:
				//-(15)DEB_ESP = valores recolhidos ou a recolher extra-apuracao
				Case (cAliasCDH)->CDH_LINHA$"900" .And. Alltrim((cAliasCDH)->CDH_SUBITE)<>"900.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						aRegE110[15] += (cAliasCDH)->CDH_VALOR
					Else
						//Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for
						//0=ICMS e a quarta for 5=Debitos especiais, considero este valor.
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="5"
							aRegE110[15] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//Se for ajuste de apuracao precisa lancar no E111
						If lOldLan
							cCodAjApur := cUf+"0"+"5"+"9999"
						EndIf
					
					EndIf
				
			EndCase   

			//REGISTRO E111 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS
			//Tratamento para gerar a estrutura do retgistro E111 conforme condicoes acima
			If lGeraE111

				//Utiliza CDO para compor a descrição se estiver preenchida								
				cDescAj	:= DescCDO((cAliasCDH)->CDH_DESC, nTamCdhDes, cCodAjApur) 
				nScanE11 := aScan(aRegE111,{|x| x[03] == cCodAjApur .and. substr(x[04],1,50) == substr(cDescAj,1,50) .and. substr(x[06],1,6) == substr(Alltrim((cAliasCDH)->CDH_SUBITE ),1,6) })    
				if nScanE11 == 0 
					aAdd(aRegE111, {})
					nPosE111	:=	Len(aRegE111)
					aAdd (aRegE111[nPosE111], 1)								//01 - REG
					aAdd (aRegE111[nPosE111], "E111")							//01 - REG
					aAdd (aRegE111[nPosE111], cCodAjApur)						//02 - COD_AJ_APUR
					aAdd (aRegE111[nPosE111], cDescAj)							//03 - DESCR_COMPL_AJ
					aAdd (aRegE111[nPosE111], (cAliasCDH)->CDH_VALOR)			//04 - VL_AJ_APUR
				else
					aRegE111[nScanE11][05]	+= (cAliasCDH)->CDH_VALOR 
				endif 	
				
				if nScanE11 == 0 
					aAdd (aRegE111[nPosE111], substr(Alltrim((cAliasCDH)->CDH_SUBITE ),1,6))			//05 - SUBITEM  
				endif 	
				
				//creditos acumulados-
				If substr(Alltrim((cAliasCDH)->CDH_SUBITE ),1,6) $ ("002.20|002.21|007.40|007.41|002.23|007.44|007.45")
					aAdd(aRegT020AG, {})
					nPosT020AG	:=	Len(aRegT020AG)
					aAdd (aRegT020AG[nPosT020AG], cDescAj)														//01 - COD_AUTO
					aAdd (aRegT020AG[nPosT020AG], (cAliasCDH)->CDH_VALOR)										//02 - VALOR 
					aAdd (aRegT020AG[nPosT020AG], cCodAjApur + substr(Alltrim((cAliasCDH)->CDH_SUBITE ),1,6)) 	// chave de comparação  
				Endif
				
				nScanE11	:=	0  				
			EndIf

		
			(cAliasCDH)->(dbSkip())		
		EndDo	//Fim do processamento da Apuracao de ICMS
		
	EndIf          
	
	
	If cImp=="IC"
		aRegT020   := aRegE110 
		aRegT020AA := aRegE111 
		aRegT020AB := aRegE112 
		aRegT020AC := aRegE113 
		aRegT020AD := aRegE115 
		aRegT020AE := aRegE116 
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecho query ou indregua criada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SPEDFFiltro(2,,cAliasCDH)
Else
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DescCDO
Se o começo da descrição for igual entre CDH/F0K e CDO significa que usuário não alterou a 
descrição e que poderá complementar com a descrição completa do cadastro do código de lançamento.
Caso seja diferente significa que o usuário alterou a descrição na apuração e neste caso 
manteremos a descrição informada por ele.
@Erick G Dias
@since 01/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function DescCDO(cDESC, nTamDes, cCodLanc)
Local cRet		 	:= cDESC
Local cDescrCDO  	:= ""

IF !Empty(cCodLanc) .AND. SPEDSeek("CDO",1,xFilial("CDO")+cCodLanc)
	cDescrCDO  := MSMM(CDO->CDO_DESCR2)	
	nTamDes	:= Min(nTamDes, Len(cDescrCDO))
    cCodDeclar := Iif(aSPDSX3[FP_CDO_DECLAR],CDO->CDO_DECLAR,"")
	If !Empty(cCodDeclar)
		//Quando campo de Codigo declaratorio estiver peenchido, consider este como descrição do ajuste na apuraçao de ICMS
		cRet := cCodDeclar
	ElseIf !Empty(cDescrCDO) .AND. Padr(cDESC, nTamDes) == Padr(cDescrCDO, nTamDes)		
		If Len(cDescrCDO) > 255		
			cRet	:= SUBSTR( cDescrCDO,1,255) //Validador aceita até 255 caracteres // 4/2/2019 - versão 2.5.1
		Else
			cRet	:= cDescrCDO
		Endif
	EndIF
EndIF
Return cRet


/*/{Protheus.doc} fGetApurNf
Função para buscar apuração referente as notas fiscais.

@author Vitor Ribeiro
@since  15/02/2018

@param aRegT020AA, array, Array com informacoes do registro T020AA
@param dDataDe, data, Data inicial

@return Nil, nulo, não tem retorno.
/*/
Static Function fGetApurNf(aRegT020AA,dDataDe)
	
	Local cAliasQry := ""
	
	Local nPosicao := 0
	
	Default aRegT020AA := {}
	
	Default dDataDe := CToD("")
	
	cAliasQry := fQryApurNf(dDataDe)
	
	While (cAliasQry)->(!Eof())
		Aadd(aRegT020AA,{})
		nPosicao := Len(aRegT020AA)
		
		Aadd(aRegT020AA[nPosicao],)						// 01 - NAO USA
		Aadd(aRegT020AA[nPosicao],)						// 02 - NAO USA
		Aadd(aRegT020AA[nPosicao],"")					// 03 - COD_AJ_APUR
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->DESCRI)	// 04 - DESCR_COMPL_AJ
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->VALOR)	// 05 - VL_AJ_APUR
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->SUBITE)	// 06 - SUBITEM
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->CODLAN)	// 07 - COD_AJ_APUR_NF
		
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())
	
Return Nil

/*/{Protheus.doc} fQryApurNf
Função para executar a query para buscar apuração das notas fiscais.

@author Vitor Ribeiro
@since  15/02/2018

@param dDataDe, data, Data inicial

@return caracter, alias da query.
/*/
Static Function fQryApurNf(dDataDe)
	
	Local cAliasQry := ""
	Local cQuery01  := ''
	Local cFilCDH   := xFilial( 'CDH' )
	Default dDataDe := CToD("")
	
	cAliasQry := GetNextAlias()
	
	cQuery01 := " SELECT "   
	cQuery01 += "  CDH.CDH_CODLAN CODLAN "  
	cQuery01 += " ,CDH.CDH_DESC DESCRI   "  
	cQuery01 += " ,CDH.CDH_VALOR VALOR   "  
	cQuery01 += " ,CDH.CDH_SUBITE SUBITE "  
	cQuery01 += " FROM " + RetSqlName('CDH') + " CDH "  
		
	cQuery01 += " INNER JOIN ( "  
	cQuery01 += " SELECT "  
	cQuery01 += "  CDH.CDH_TIPOIP TIPOIP "  
	cQuery01 += " ,CDH.CDH_TIPOPR TIPOPR "  
	cQuery01 += " ,CDH.CDH_PERIOD PERIOD "  
	cQuery01 += " ,CDH.CDH_DTINI DTINI "  
	cQuery01 += " ,CDH.CDH_LIVRO LIVRO "  
	cQuery01 += " ,MAX(CDH.CDH_SEQUEN) MAX_SEQUEN "  
	cQuery01 += " FROM " + RetSqlName('CDH') + " CDH "  

	cQuery01 += " WHERE "  
	cQuery01 += "     CDH.D_E_L_E_T_ = ' ' "  
	cQuery01 += " AND CDH.CDH_FILIAL = '"  + cFilCDH + "' "  
	cQuery01 += " AND CDH.CDH_TIPOIP = 'IC' "  
	cQuery01 += " AND CDH.CDH_TIPOPR = '3' "  
	cQuery01 += " AND CDH.CDH_PERIOD = '1' "  
	cQuery01 += " AND CDH.CDH_DTINI  = '" + DToS(dDataDe) + "' "  
	cQuery01 += " AND CDH.CDH_CODLAN <> '' "
	cQuery01 += " AND " + xFunExpSql("LENGTH") + "(CDH.CDH_CODLAN) = 10"
	cQuery01 += "                GROUP BY "  
	cQuery01 += "                      CDH.CDH_TIPOIP "  
	cQuery01 += "                      ,CDH.CDH_TIPOPR "  
	cQuery01 += "                      ,CDH.CDH_PERIOD "  
	cQuery01 += "                      ,CDH.CDH_DTINI  "  
	cQuery01 += "                      ,CDH.CDH_LIVRO  "  
	cQuery01 += "     ) APURA ON "  
	cQuery01 += "                APURA.TIPOIP = CDH.CDH_TIPOIP "  
	cQuery01 += "                AND APURA.TIPOPR = CDH.CDH_TIPOPR "  
	cQuery01 += "                AND APURA.PERIOD = CDH.CDH_PERIOD "  
	cQuery01 += "                AND APURA.DTINI = CDH.CDH_DTINI "  
	cQuery01 += "                AND APURA.LIVRO = CDH.CDH_LIVRO "  
	cQuery01 += "                AND APURA.MAX_SEQUEN = CDH.CDH_SEQUEN "  

	cQuery01 += "     WHERE "
	cQuery01 += "           CDH.D_E_L_E_T_ = ' ' "
	cQuery01 += "                AND CDH.CDH_FILIAL = '" + cFilCDH + "' "  
	cQuery01 += "                AND CDH.CDH_TIPOIP = 'IC' "  
	cQuery01 += "                AND CDH.CDH_TIPOPR = '3' "  
	cQuery01 += "                AND CDH.CDH_PERIOD = '1' "  
	cQuery01 += "                AND CDH.CDH_DTINI = '" + DToS(dDataDe) + "' "  
	cQuery01 += "                AND CDH.CDH_CODLAN <> '' "
	cQuery01 += "                AND " + xFunExpSql("LENGTH") + "(CDH.CDH_CODLAN) = 10"
				
	cQuery01 := ChangeQuery(cQuery01)
	DBUseArea(.T.,"TopConn",TCGenQry(,,cQuery01),cAliasQry)

Return cAliasQry


