#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "SPEDFISCAL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "SPEDXDEF.CH"

STATIC aSPDSX2     := SpedLoadX2()
STATIC aSPDSX3     := SpedLoadX3()
STATIC aSPDSX6     := SpedLoadX6()
STATIC cMVSUBTRIB  := GetSubTrib()
STATIC cMVEstado   := aSPDSX6[MV_ESTADO]
STATIC nTamCdhDes  := TamSx3("CDH_DESC")[1]
STATIC nTamIdSub   :=  TamSX3( "CHY_CODIGO" )[1]
STATIC nTamCodAj   :=  TamSX3( "C1A_CODIGO" )[1]
STATIC lNewCtrl   := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
STATIC cUltStmp   := iif(lNewCtrl, TsiUltStamp("C3J"),' ')

/*/{Protheus.doc} TSICMSST
Classe que contém preparedstatament do T021 - Apuração de ICMS ST

@type Class
@author Denis Souza / Rafael Leme
@since 06/08/2021
@return Nil, nulo, não tem retorno.
/*/ 
Class TSICMSST

	Data TSITQRY     as String ReadOnly
	Data cFinalQuery as String ReadOnly
	Data oStatement  as Object ReadOnly
	Data aFilC3J     as Array  ReadOnly
	Data oJObjTSI    as Object

	Method New( ) Constructor
	Method PrepQuery( )
	Method LoadQuery( )
	Method JSon( )
	Method FilC3J( )

	Method GetQry( )
	Method GetJsn( )

EndClass

/*/{Protheus.doc} New
Método contrutor da classe TSICMSST

Fluxo New:
1º Monta-se a query com LoadQuery()
2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
cFinalQuery com a query final já com os parâmetros

@type Method
@author Denis Souza / Rafael Leme
@since 06/08/2021
@return Nil, nulo, não tem retorno
/*/
Method New( cSourceBr ) Class TSICMSST
	Self:FilC3J( cSourceBr )
	Self:LoadQuery( )
	Self:PrepQuery( )
	Self:JSon( )
Return

/*/{Protheus.doc} PrepQuery   
Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
cFinalQuery com a query final já com os parâmetros

@type Method
@author Denis Souza / Rafael Leme
@since 06/08/2021
@return Nil, nulo, não tem retorno.
/*/
Method PrepQuery( ) Class TSICMSST

	self:oStatement := FWPreparedStatement( ):New( )
	self:oStatement:SetQuery( self:TSITQRY )
	self:oStatement:SetIn( 1, self:aFilC3J )
	self:cFinalQuery := self:oStatement:GetFixQuery( )

Return

 /*/{Protheus.doc} PrepQuery
	Método responsável por montar a query para o preparedstatemen
	
	@type Method
	@author Denis Souza / Rafael Leme
	@since 06/08/2021
	@return Nil, nulo, não tem retorno.
/*/
Method LoadQuery( ) Class TSICMSST

Local cQuery  	:= ""
Local cConvCpo 	:= ''
Local cDbType 	:= Upper( Alltrim( TCGetDB( ) ) )

//Converte o conteúdo do campo conforme o banco de dados usado.
If cDbType $ "MSSQL/MSSQL7"
	cConvCpo := " convert(varchar(23), CDH.S_T_A_M_P_, 21) "
Elseif cDbType $ "ORACLE"
	cConvCpo := " cast(to_char(CDH.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) "
Elseif cDbType $ "POSTGRES"
	cConvCpo := " cast( CDH.S_T_A_M_P_ AS CHAR(23)) "
Endif

//Verifico se tem alguma apuração não integrada para exportar
cQuery += " SELECT "
cQuery += cConvCpo + " STAMP, "
cQuery += " CDH_FILIAL, "
cQuery += " CDH_LIVRO, "
cQuery += " CDH_DTINI, "
cQuery += " CDH_DTFIM "
cQuery += " FROM " + RetSqlName( "CDH" ) + " CDH "
cQuery += " LEFT JOIN " + RetSqlName( "C3J" ) + " C3J ON C3J.C3J_FILIAL = CDH.CDH_FILIAL "
cQuery += " AND C3J.C3J_DTINI = CDH.CDH_DTINI "
cQuery += " AND C3J.C3J_DTFIN = CDH.CDH_DTFIM "
cQuery += " AND C3J.D_E_L_E_T_ = ' ' "
cQuery += " WHERE CDH.D_E_L_E_T_ = ' ' "
cQuery += " AND CDH.CDH_FILIAL IN (?) "	//1
cQuery += " AND CDH.CDH_LIVRO = '*' "
cQuery += " AND CDH.CDH_TIPOIP = 'ST' "
cQuery += " AND CDH.CDH_TIPOPR = '3' "	//mensal
cQuery += " AND CDH.CDH_PERIOD = '1' "	//primeiro periodo
cQuery += " AND CDH.CDH_SEQUEN = "
cQuery += " (SELECT MAX(CDHMAX.CDH_SEQUEN) " //USANDO MAX NO WHERE PARA SEMPRE PEGAR A ULTIMA APURAÇÃO
cQuery += " FROM " + RetSqlName( "CDH" ) + " CDHMAX  "
cQuery += " WHERE CDHMAX.D_E_L_E_T_ = ' '  "
cQuery += " AND CDHMAX.CDH_TIPOIP = CDH.CDH_TIPOIP "
cQuery += " AND CDHMAX.CDH_FILIAL = CDH.CDH_FILIAL "
cQuery += " AND CDHMAX.CDH_TIPOPR = CDH.CDH_TIPOPR "
cQuery += " AND CDHMAX.CDH_PERIOD = CDH.CDH_PERIOD "
cQuery += " AND CDHMAX.CDH_LIVRO = CDH.CDH_LIVRO "
cQuery += " AND CDHMAX.CDH_DTINI = CDH.CDH_DTINI "
cQuery += " AND CDHMAX.CDH_DTFIM = CDH.CDH_DTFIM) "
cQuery += " AND CDH.CDH_LINHA = '012' AND UPPER(CDH.CDH_DESC) LIKE '%TOTAL%' " //FILTRO pelo Total linha 012 para garantir buscar apenas uma linha por apuração

//Filtra o IDMOV
cQuery += " AND  (C3J.C3J_INDMOV = CASE WHEN (SELECT COUNT(*) "
cQuery += " 										FROM " + RetSqlName( "CDH" ) +" CDHCODAJ "
cQuery += " 										WHERE CDHCODAJ.D_E_L_E_T_ = ' ' "
cQuery += " 										AND CDHCODAJ.CDH_TIPOIP = CDH.CDH_TIPOIP "
cQuery += " 										AND CDHCODAJ.CDH_FILIAL = CDH.CDH_FILIAL "
cQuery += " 										AND CDHCODAJ.CDH_TIPOPR = CDH.CDH_TIPOPR "
cQuery += " 										AND CDHCODAJ.CDH_PERIOD = CDH.CDH_PERIOD "
cQuery += " 										AND CDHCODAJ.CDH_SEQUEN = CDH.CDH_SEQUEN "
cQuery += " 										AND CDHCODAJ.CDH_LIVRO = CDH.CDH_LIVRO "
If cDbType $ "ORACLE|POSTGRES|DB2"
	cQuery += "                             AND SUBSTR(CDHCODAJ.CDH_CODLAN,1,2) = 'SP'  " //Por ora, será verificado apenas a UF
ElseIf cDbType $ "INFORMIX"
	cQuery += " 	                        AND CDHCODAJ.CDH_CODLAN[1,2] = 'SP'  " //Por ora, será verificado apenas a UF
ElseIf cDbType $ "MSSQL/MSSQL7"
	cQuery += " 	                        AND SUBSTRING(CDHCODAJ.CDH_CODLAN,1,2) = 'SP'  " //Por ora, será verificado apenas a UF
EndIf
cQuery += " 								AND CDHCODAJ.CDH_DTINI = CDH.CDH_DTINI "
cQuery += " 								AND CDHCODAJ.CDH_DTFIM = CDH.CDH_DTFIM) > 0 THEN '1' ELSE '0' END  "
cQuery += " OR C3J.C3J_INDMOV IS NULL) "
cQuery += " AND CDH.S_T_A_M_P_ IS NOT NULL "

If !lNewCtrl .OR. Empty(cUltStmp)
	If cDbType $ "ORACLE"
		cQuery += " AND ((C3J.C3J_STAMP IS NULL OR Length(trim(C3J.C3J_STAMP)) = 0 OR Length(trim(C3J.C3J_STAMP)) IS NULL) OR ( Length(trim(C3J.C3J_STAMP)) > 0 AND CDH.S_T_A_M_P_ > TO_TIMESTAMP(C3J.C3J_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') )) "
	else
		cQuery += " AND (( " + cConvCpo + " > C3J.C3J_STAMP) OR C3J.C3J_STAMP IS NULL) "
	endif
Else
	If cDbType $ "ORACLE"
		cQuery += "  AND CDH.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "	
	else
		cQuery += "  AND " + cConvCpo + " > '" + Alltrim(cUltStmp) + "' "	
	endif
Endif

cQuery += " ORDER BY CDH.CDH_DTFIM DESC "

self:TSITQRY := cQuery

Return

/*----------------------------------------------------------------------
{Protheus.doc} INTAPICMSST()
(Teste de integração via menu. Deve ser retirada apos criação do JOB de execução.
@author Renan Gomes
@since 01/12/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Function INTAPICMSST()

Local oObjAPURICMS := TSICMSST():New(cEmpAnt+cFilAnt)
Local oObjJson     := oObjAPURICMS:GetJsn()

WsTSIProc( oObjJson, .T., HashC3J()   ) //Processamento de importação das apurações

freeobj( oObjAPURICMS )

Return

 /*/{Protheus.doc} PrepQuery
	Método responsável por retornar a propriedade self:cFinalQuery

	@type Method
	@author Denis Souza / Rafael Leme
	@since 06/08/2021
	@return cFinalQuery  - String com a query já montada e pronta para ser executada
/*/
Method GetQry( ) Class TSICMSST
return self:cFinalQuery

 /*/{Protheus.doc} JSon
	Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI

	@type Method
	@author Denis Souza / Rafael Leme
	@since 06/08/2021
	@return Nil, nulo, não tem retorno.
/*/
Method JSon( ) Class TSICMSST

Local oJObjRet    := nil
Local oJsICMSST   := nil
Local cAlias      := getNextAlias( )
Local dDataDe     := ''
Local dDataAte    := ''
Local cNrLivro    := ''
Local cUf         := ''
Local aT021Reg	  := {}
Local aRegT021Val := {}
Local aRegT021Est := {}
Local aRegT021AA  := {}
Local aReg0200    := {}
Local aReg0190    := {}
Local aReg0220    := {}
Local aApurationIcmsST 		 := { }
Local aAdjustmentApurationST := { }
Local nApuracao	  := 3
Local nPeriodo	  := 1
Local nlA         := 0
Local nI          := 0
Local lGer        := .F.
Local cRelIdC3J	  := GetSx3Cache("C3J_ID","X3_RELACAO")
Local lIdC3JErr   := '("C3J","C3J_ID")' $ UPPER(cRelIdC3J)

dbUseArea(.T., "TOPCONN", TCGenQry(, , self:GetQry()), cAlias, .F., .T.)
TAFConOut( "TSILOG000015: Query de busca do cadastro de apurações de Icms ST [ " + self:GetQry() + " ]")

oJObjRet := JsonObject( ):New( )

While ( cAlias )->( !EOF( ) )
	dDataDe  := STOD(( cAlias )->CDH_DTINI)
	dDataAte := STOD(( cAlias )->CDH_DTFIM)
	cFilDe   := ( cAlias )->CDH_FILIAL
	cFilAte  := ( cAlias )->CDH_FILIAL
	cNrLivro := ( cAlias )->CDH_LIVRO

	//REGISTRO E200 - PERIODO DA APURACAO DO ICMS ST
	//REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA
	//REGISTRO E220 - AJUSTES/BENEFICIOS/INCENTIVOS DA APURACAO DO ICMS SUBSTITUICAO TRIBUTARIA
	TAFICMSST(cFilDe,cFilAte,nApuracao,nPeriodo,cNrLivro,"ST",cAlias,dDataDe,dDataAte,;
	@aT021Reg, @aRegT021Val,@aRegT021Est,@aRegT021AA,@aReg0200, @aReg0190,@aReg0220)

	for nlA := 1 to len(aT021Reg)
		cUf := aT021Reg[nlA][2]
		
		
		//tratamento para gerar mesmo resultado do extrator fiscal quando houve subtrib com mais de uma UF, alinhado que
		//para outro estado diferente de sp nao devera ser gerado		
		//somente para nova gia sp
		if cUf == 'SP'
			lGer := .T.
		endif

		if lGer
			oJsICMSST := JsonObject( ):New( )

			If lIdC3JErr
				oJsICMSST["apurationId"] := GetSx8Num("C3J","C3J_ID",,2)
				C3J->( ConfirmSX8() )        
			Endif
			
			oJsICMSST["stamp"] 				  		 := ( cAlias )->STAMP
			oJsICMSST["codUF"]				  		 := cUf
			oJsICMSST["dateInitialApuration"] 		 := aT021Reg[nlA][3]
			oJsICMSST["dateFinalApuration"]   		 := aT021Reg[nlA][4]
			oJsICMSST["indicatorApuration"]          := aT021Reg[nlA][5]
			oJsICMSST["balanceCreditPeridPrevios"]   := aT021Reg[nlA][6]
			oJsICMSST["valueDevolution"]             := aT021Reg[nlA][7]
			oJsICMSST["valueTotalReimbursement"]     := aT021Reg[nlA][8]
			oJsICMSST["valueOthersCredits"]          := aT021Reg[nlA][9]
			oJsICMSST["valueAdjustmentCredits"]      := aT021Reg[nlA][10]
			oJsICMSST["valueIcmsRet"]                := aT021Reg[nlA][11]
			oJsICMSST["valueOthersDebits"]      	 := aT021Reg[nlA][12]
			oJsICMSST["valueAdjustmentDebits"]       := aT021Reg[nlA][13]
			oJsICMSST["balanceDebitBeforeDeduction"] := aT021Reg[nlA][14]
			oJsICMSST["valueTotalDeductions"]        := aT021Reg[nlA][15]
			oJsICMSST["valueIcmsToRecall"]           := aT021Reg[nlA][16]
			oJsICMSST["creditCarried"]               := aT021Reg[nlA][17]
			oJsICMSST["specialDebits"]               := aT021Reg[nlA][18]

			//Crio array dos ajustes de apurações -  T021AA
			aAdjustmentApurationST := { }

			For nI := 1 to Len(aRegT021AA)
				if cUf == SubString(Alltrim(aRegT021AA[nI][3]),1,2)
					//Crio Objeto de ajustes de apurações - T021AA
					oJObjAjust := JsonObject( ):New( )

					oJObjAjust["valueAdjustment"]         := aRegT021AA[nI][5]
					oJObjAjust["adjustmentCode"]          := PADR(alltrim(aRegT021AA[nI][3]),nTamCodAj)
					oJObjAjust["subItemCode"]             := PADR(Alltrim( StrTran( aRegT021AA[nI][6], ".", "" ) ),nTamIdSub)
					oJObjAjust["reasonCode"]              := " "
					oJObjAjust["complementaryAdjustment"] := aRegT021AA[nI][4]

					//Adiciono objeto filho T021AA dentro do array
					aAdd( aAdjustmentApurationST, oJObjAjust )
				endif
			Next nI

			//Atualizo objeto T021AA com array de json dos ajustes T021AA
			oJsICMSST["adjustmentApurationST"] := aAdjustmentApurationST

			//Adiciono objeto pai T020 dentro do array de apuracao T021
			aadd( aApurationIcmsST, oJsICMSST )
		endif
	next nlA

	aT021Reg    := {}
	aRegT021Est := {}
	aRegT021Val := {}
	aRegT021AA  := {}
	( cAlias )->( DBSKIP( ) )
EndDo

//Objeto de apuracao recebe array de json acumulado com toda estrutura apurada
oJObjRet['apurationIcmsST'] := aApurationIcmsST

self:oJObjTSI := oJObjRet

( cAlias )->( DbCloseArea( ) )

Return

 /*/{Protheus.doc} GetJsn
	Método responsável retornar a propriedade self:oJObjTSI

	@author Denis Souza / Rafael Leme
	@since 06/08/2021
	@return oJObjTSI - Objeto TSICMSST com o Json gerado com as informações de apuração T020
/*/
Method GetJsn ( ) Class TSICMSST
Return self:oJObjTSI

 /*/{Protheus.doc} TSICMSST
	Método responsável por montar o conteúdo da filial da C3J

	@author Denis Souza / Rafael Leme
	@since 06/08/2021
	@return Nil, nulo, não tem retorno.
/*/
Method FilC3J( cSourceBr ) Class TSICMSST
	self:aFilC3J := TafTSIFil( cSourceBr, "C3J" )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDsCDO
Rotina baseada no DescCDO do fonte SPEDFISCAL.PRW

/*/
//-------------------------------------------------------------------
Static Function TafDsCDO(cDESC, nTamDes, cCodLanc)

Local cRet		:= cDESC
Local cDescrCDO := ""

IF !Empty(cCodLanc) .AND. SPEDSeek("CDO",1,xFilial("CDO")+cCodLanc)
	cDescrCDO := Alltrim( MSMM(CDO->CDO_DESCR2) )
	nTamDes	:= Min(nTamDes, Len(cDescrCDO))
    cCodDeclar := Iif(aSPDSX3[FP_CDO_DECLAR],CDO->CDO_DECLAR,"")
	If !Empty(cCodDeclar) //Quando campo de Codigo declaratorio estiver peenchido, consider este como descrição do ajuste na apuraçao de ICMS
		cRet := cCodDeclar
	ElseIf !Empty(cDescrCDO) .AND. Padr(cDESC, nTamDes) == Padr(cDescrCDO, nTamDes)
		If Len(cDescrCDO) > 255
			cRet := SUBSTR( cDescrCDO,1,255) //Validador aceita até 255 caracteres // 4/2/2019 - versão 2.5.1
		Else
			cRet := cDescrCDO
		Endif
	EndIF
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFICMSST
Rotina baseada no BlocoE do fonte SPEDFISCAL.PRW

@author Denis Souza / Rafael Leme
@since 06/08/2021
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TAFICMSST(cFilDe,cFilAte,nApuracao,nPeriodo,cNrLivro,cImp,cAlias,dDataDe,dDataAte,;
aT021Reg,aRegT021Val,aRegT021Est,aRegT021AA,aReg0200,aReg0190,aReg0220)

Local cChave	 	:= ""
Local cSequen	 	:= ""
Local cCodAjApur 	:= ""
Local cAliasCDH	 	:= "CDH"
Local cCodE240	 	:= ""
Local cUf		 	:= cMvEstado
Local cDescAj	 	:= ""
Local aRegE200 	 	:= {}
Local aRegE210 	 	:= {}
Local aRegE220 	 	:= {}
Local aParametros	:= {}
Local nPosE220	 	:= 0
local nIniReg    	:= 0
local nI 		 	:= 0
Local nPosAj	 	:= 0
Local nUf		 	:= 0
Local nRecnoSF6		:= 0
Local lAchouSF6	 	:= .F.
Local lAchouCCF	 	:= .F.
Local lAjusteNF 	:= .F.
Local lOldLan     	:= .F.
Local lContinua     := .T.

Default nApuracao	:= 3
Default nPeriodo	:= 1
Default dDataDe  	:= Ctod(' / /  ')
Default dDataAte 	:= Ctod(' / /  ')
Default cNrLivro 	:= '*'
Default aRegT021Val := {} 
Default aRegT021Est := {} 
Default aRegT021AA  := {} 
Default aReg0200    := {} 
Default aReg0190    := {} 
Default aReg0220    := {}

cChave := STR(nApuracao,1)+STR(nPeriodo,1)+DTOS(dDataDe)+cNrLivro

aAdd(aParametros,cImp)
aAdd(aParametros,STR(nApuracao,1))
aAdd(aParametros,STR(nPeriodo,1))
aAdd(aParametros,DTOS(dDataDe))
aAdd(aParametros,cNrLivro)
aAdd(aParametros,cSequen)

TafE200E210(@aRegE200,@aRegE210,cAlias,dDataDe,dDataAte,@lContinua,@aT021Reg)

If lContinua == .T.
	If SPEDFFiltro(1,"CDH",@cAliasCDH,aParametros)

		//Carrega ajustes na apuracao ICMS/ST
		While !(cAliasCDH)->(Eof())

			nRecnoSF6	:=	(cAliasCDH)->SF6RECNO
			lAchouSF6	:=	.F.
			lAchouCCF	:=	.F.
			nUf 		:= 	0
			cUF 		:= 	Left((cAliasCDH)->CDH_CODLAN,2)
			cCodAjApur 	:= 	(cAliasCDH)->CDH_CODLAN
			nPosAj		:=	0
			cCodE240	:=	""

			If !Empty((cAliasCDH)->(CDH_ESTGNR+CDH_GNRE))
				lAchouSF6	:=	SPEDSeek("SF6",1,xFilial("SF6")+(cAliasCDH)->(CDH_ESTGNR+CDH_GNRE),nRecnoSF6)
			EndIf
				
			//³Processamento de subitens que tenha codigo de lancamento conforme manual SPED Fiscal³
			If !Empty((cAliasCDH)->CDH_CODLAN) .And. (nUf := aScan(aRegE200,{|x|x[2]==cUf}))>0
				If Len(Alltrim((cAliasCDH)->CDH_CODLAN))==8 .And. aSPDSX2[AI_CDO]
					lAjusteNF  := .F.
				ElseIf Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10 
					lAjusteNF := .T.							
					If aSPDSX3[FP_CC6_CLANAP].And.;
						CC6->(MsSeek(xFilial("CC6")+(cAliasCDH)->CDH_CODLAN)) .And. !Empty(CC6->CC6_CLANAP)
						cCodE240 :=	CC6->CC6_CLANAP
					EndIf
				EndIf
				Do Case
					//Processamento dos subitens de "OUTROS DEBITOS", para gerar os campos:
					//(9)VL_OUT_DEB_ST = Valor total de ajustes "OUTROS DEBITOS ST ou ESTORNO DE CREDITOS ST"
					//(10)VL_AJ_DEBITOS_ST =  Valor total dos ajustes a debitos de ST, provenientes de NF
					Case (cAliasCDH)->(CDH_LINHA$"002" .And. Alltrim(CDH_SUBITE)<>"002.00") .Or.;
						(cAliasCDH)->(CDH_LINHA$"003" .And. Alltrim(CDH_SUBITE)<>"003.00")				
						nPosAj := Iif(lAjusteNF,11,10)
						If !lAjusteNF .And. lOldLan
							If (cAliasCDH)->CDH_LINHA$"002"
								cCodAjApur := cMvEstado+"1"+"0"+"9999"
							Else
								cCodAjApur := cMvEstado+"1"+"1"+"9999"
							EndIf
						EndIf
					//Processamento dos subitens de "OUTROS CREDITOS", para gerar os campos:
					//(6)VL_OUT_CRED_ST = Valor total de ajustes "OUTROS CREDITOS ST ou ESTORNO DE DEBITOS ST"
					//(7)VL_AJ_CREDITOS_ST = Valor total dos ajustes a creditos de ST, provenientes de NF
					Case (cAliasCDH)->(CDH_LINHA$"007" .And. Alltrim(CDH_SUBITE)<>"007.00") .Or.;
						(cAliasCDH)->(CDH_LINHA$"008" .And. Alltrim(CDH_SUBITE)<>"008.00")
						//Definicao de qual coluna o valor estara composto
						nPosAj 	:= 	Iif(lAjusteNF,8,7)
						If !lAjusteNF .And. lOldLan
							If (cAliasCDH)->CDH_LINHA$"007"
								cCodAjApur := cMvEstado+"1"+"2"+"9999"
							Else
								cCodAjApur := cMvEstado+"1"+"3"+"9999"
							EndIf
						EndIf				
					//Processamento dos subitens de "ESTORNO DE DEBITOS", para gerar os campos:
					//(6)VL_OUT_CRED_ST = Valor total de ajustes "OUTROS CREDITOS ST ou ESTORNO DE DEBITOS ST"
					//(7)VL_AJ_CREDITOS_ST =  Valor total dos ajustes a creditos de ST, provenientes de NF
					Case (cAliasCDH)->(CDH_LINHA$"008" .And. Alltrim(CDH_SUBITE)<>"008.00")
						//³Definicao de qual coluna o valor estara composto³
						nPosAj 	:= 	Iif(lAjusteNF,8,7)
						If !lAjusteNF .And. lOldLan
							cCodAjApur := cMvEstado+"1"+"3"+"9999"
						EndIf
					//Processamento dos subitens de "DEDUCOES", para gerar o campo:
					//(12)VL_DEDUCOES_ST = Valor total dos ajustes "DEDUCOES ST"
					//ESTORNO DE DEBITOS ST"
					Case (cAliasCDH)->(CDH_LINHA$"014" .And. Alltrim(CDH_SUBITE)<>"014.00")
						nPosAj := 13
						If !lAjusteNF .And. lOldLan    
							cCodAjApur := cMvEstado+"1"+"4"+"9999" 
						EndIf   
					//Processamento dos subitens de "DEBITOS ESPECIAIS", para gerar o campo:
					//(15)DEB_ESP_ST = Valores recolhidos ou a recolher extra-apuracao
					Case (cAliasCDH)->(CDH_LINHA$"901" .And. Alltrim(CDH_SUBITE)<>"901.00") 
						//³Definicao de qual coluna o valor estara composto³
						nPosAj := 16 
						If !lAjusteNF .And. lOldLan        
							cCodAjApur := cMvEstado+"1"+"5"+"9999"  
						EndIf				
				EndCase
				//³Gero quando achar um registro correspondente e quando o valor for maior que ZERO³
				If nUf>0 .And. nPosAj>0 .And. (cAliasCDH)->CDH_VALOR>0 .And. Substr((cAliasCDH)->CDH_CODLAN,3,1) <> "9"
					//REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA
					aRegE210[nUf][nPosAj] 	+= 	(cAliasCDH)->CDH_VALOR
					//REGISTRO E220 - AJUSTES/BENEFICIOS/INCENTIVOS DA APURACAO DO ICMS SUBSTITUICAO TRIBUTARIA
					If (!lAjusteNF) .Or. (!Empty(cCodE240) .And. lCmpsE240)
						//Utiliza CDO para compor a descrição se estiver preenchida
						cDescAj	:= TafDsCDO((cAliasCDH)->CDH_DESC, nTamCdhDes, Iif(!Empty(cCodE240),cCodE240,cCodAjApur))						
						aAdd(aRegE220, {})	
						nPosE220	:=	Len (aRegE220)
						aAdd (aRegE220[nPosE220], nUF)							   			 //Relacionamento com o registro E210
						aAdd (aRegE220[nPosE220], "E220")						   			 //01 - REG
						aAdd (aRegE220[nPosE220], Iif(!Empty(cCodE240),cCodE240,cCodAjApur)) //02 - COD_AJ_APUR
						aAdd (aRegE220[nPosE220], cDescAj)									 //03 - DESCR_COMPL_AJ
						aAdd (aRegE220[nPosE220], (cAliasCDH)->CDH_VALOR)					 //04 - VL_AJ_APUR
						aAdd (aRegE220[nPosE220], (cAliasCDH)->CDH_SUBITE)					 //05 - VL_AJ_APUR					
					EndIf			
				EndIf
			endif
			(cAliasCDH)->(dbSkip())
		EndDo

		//Apos o fim do processamento das informacoes da apuracao, eh necessario complementa-los com algumas que faltaram
		TafSpedApE200(aRegE200,@aRegE210,nApuracao,nPeriodo,cNrLivro)

		aRegT021Est := aRegE200
		aRegT021Val := aRegE210
		aRegT021AA  := aRegE220

		For nI := 1 to Len(aRegT021Est)
			nIniReg := Ascan( aRegT021Val, {|x| x[1] == nI })
			If nIniReg > 0
				T021Reg(aRegT021Est[nI],aRegT021Val[nIniReg],dDataDe,dDataAte,@aT021Reg )
			EndIf
		next nI
		SPEDFFiltro(2,,cAliasCDH)
	Endif
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TafE200E210
Rotina baseada na função PrcE200E210 do fonte SPEDFISCAL.PRW

@author Denis Souza / Rafael Leme
@since 06/08/2021
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TafE200E210(aRegE200,aRegE210,cAlias,dDataDe,dDataAte,lContinua,aT021Reg)

Local cUf	   := ""
Local nUf	   := 0  
Local nX       := 0
Local nI	   := 1
Local aReg0015 := {}

Default lContinua := .T.

//Verifico todas as UFs onde ha inscricao, porem nao houve movimentacao
aReg0015 := TafReg15(cAlias)

If Len(aReg0015) == 0
	//Tratamento para quando o parâmetro MV_SUBTRIB estiver vazio.
	If AllTrim(cMVSUBTRIB) == "" 
		cUf := cMVEstado
		lContinua = .F.
		TAFCONOUT("Para importação da apuração de ICMS-ST com seus respectivos códigos de ajustes é necessário informar o parâmetro MV_SUBTRIB.")
	Endif
	aAdd(aRegE200,{"E200",cUf,dDataDe,dDataAte})
	aAdd(aRegE210,{1,"E210","0",0,0,0,0,0,0,0,0,0,0,0,0,0})		
	
	aRegT021Est := aRegE200
	aRegT021Val := aRegE210

	For nI := 1 to Len(aRegT021Est)
		nIniReg := Ascan( aRegT021Val, {|x| x[1] == nI })
		If nIniReg > 0
			T021Reg(aRegT021Est[nI],aRegT021Val[nIniReg],dDataDe,dDataAte,@aT021Reg )
		EndIf
	next nI
Else
	For nX := 1 To Len(aReg0015)
		cUF	:=	aReg0015[nX,2]
		If aScan(aRegE200,{|x|x[2]==cUf})==0
			aAdd(aRegE200,{"E200",cUf,dDataDe,dDataAte})				
			nUf := Len(aRegE200)			
			aAdd(aRegE210,{nUf,"E210","0",0,0,0,0,0,0,0,0,0,0,0,0,0})
		EndIf	
	Next nX
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafReg15
Rotina baseada na função Reg0015 do fonte SPEDFISCAL.PRW

@author Denis Souza / Rafael Leme
@since 06/08/2021
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TafReg15(cAlias)

Local nPosI	   := 0
Local nPosF	   := 0
Local nPosY	   := 0
Local nX	   := 0
Local aUf	   := UfCodIBGE("",.F.)
Local aReg0015 := {}
                                              
cMVSUBTRIB += GetSubTrib("",.T.)
For nX := 1 to len(aUf)
	If At (aUf[nX][1], cMVSUBTRIB)>0
		If (aScan (aReg0015, {|aX| aX[2]==aUf[nX][1]})==0)
			nPosI := At (aUf[nX][1], cMVSUBTRIB)+2
			nPosF := At ("/", SubStr (cMVSUBTRIB, nPosI))-1
			nPosF := IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
			cStrValid:= SubStr(cMVSUBTRIB, nPosI, nPosF)
			If "CNPJ" $ cStrValid
				Loop
			EndIf
			aAdd(aReg0015, {})
			nPosY := Len (aReg0015)
			aAdd (aReg0015[nPosY], "0015")	   //01 - REG
			aAdd (aReg0015[nPosY], aUf[nX][1]) //02 - UF_ST
			aAdd (aReg0015[nPosY], cStrValid)  //03 - IE_ST
		EndIf
	EndIf
Next

Return aReg0015

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSpedApE200
Rotina baseada na função SpedApE200 do fonte SPEDXFUN.PRW

@author Denis Souza / Rafael Leme
@since 06/08/2021
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TafSpedApE200(aRegE200,aRegE210,nApuracao,nPeriodo,cNrLivro)

Local nX  := 0
Local nUf := 0

For nUF := 1 To Len(aRegE200)

	aApuracao := {0,0,0,0,0}
	aRegE210[nUF,4]	 += aApuracao[1]
	aRegE210[nUF,5]	 += aApuracao[2]
	aRegE210[nUF,6]	 += aApuracao[5]
	aRegE210[nUF,7]  += aApuracao[3]
	aRegE210[nUF,9]	 += aApuracao[4]
	aRegE210[nUf,12] :=	(aRegE210[nUf,9]+aRegE210[nUf,10]+aRegE210[nUf,11])-(aRegE210[nUf,4]+aRegE210[nUf,5]+aRegE210[nUf,6]+aRegE210[nUf,7]+aRegE210[nUf,8])
	aRegE210[nUf,14] :=	aRegE210[nUf,12]-aRegE210[nUf,13]

	If aRegE210[nUf,14] < 0
		aRegE210[nUf,15] :=	Abs(aRegE210[nUf,14])
		aRegE210[nUf,12] :=	Max(aRegE210[nUf,12],0)
		aRegE210[nUf,14] :=	Max(aRegE210[nUf,14],0)
	EndIf

	For nX := 4 To Len(aRegE210[nUf])
		If aRegE210[nUf,nX]>0
			aRegE210[nUf][3] :=	"1"
			Exit
		EndIf
	Next nX
Next nUF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} T021Reg
Rotina baseada na função RegT021 do fonte ExtFisxTaf.PRW

@author Denis Souza / Rafael Leme
@since 06/08/2021
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T021Reg(aRegT021Est,aRegT021Val,dDataDe,dDataAte, aT021Reg )

	Aadd( aT021Reg,;
	{'T021',;		   //01
	aRegT021Est[2],;   //02
	dDataDe,;  		   //03
	dDataAte,; 		   //04
	aRegT021Val[3] ,;  //05
	aRegT021Val[4] ,;  //06
	aRegT021Val[5] ,;  //07
	aRegT021Val[6] ,;  //08
	aRegT021Val[7] ,;  //09
	aRegT021Val[8] ,;  //10
	aRegT021Val[9] ,;  //11
	aRegT021Val[10],;  //12
	aRegT021Val[11],;  //13
	aRegT021Val[12],;  //14
	aRegT021Val[13],;  //15
	aRegT021Val[14],;  //16
	aRegT021Val[15],;  //17
	aRegT021Val[16]})  //18

Return Nil
