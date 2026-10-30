#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLDSEGPESL.CH"
                               
/*/{Protheus.doc} PLDSEGPESL
Diops Saldo da Provisão de Eventos/Sinistros a liquidar

@author Karine Riquena Limp
@since 06/02/2017
@version 12

/*/
Function PLDSEGPESL()
LOCAL aReg := {} 	
Local dDatDe	:= CtoD('')
Local dDatRef	:= CtoD('')

/*	Parâmetros:
		MV_PAR01: Mes de referência
		MV_PAR02: Ano de referência
*/

If Pergunte("PLDSEGPESL", .T.)

	dDatRef := LastDay(STOD(alltrim(str(MV_PAR02))+alltrim(strzero(MV_PAR01,2))+'01'))
	// Obrigatoriedade de apresentação de dados até 36 meses anteriores
	dDatDe	:= FirstDay( dDatRef - (36*30) )
	//Faz busca dos registros
	Processa({|| aReg := PLSEGPESL(dDatDe, dDatRef, .T. ) }, STR0001/*"Aguarde"*/, STR0002 /*"Gerando dados..."*/, .t.)

	// Se não ocorreu erro e retornou algum valor da PESL ou quantidade de beneficiarios 
	If aReg[1] .and. aReg[2,1]+aReg[2,2]+aReg[2,3] > 0
		//Monta esquema CSV
		aReg := SegToArray(aReg[2])
		
		If Len(aReg) > 0
			PLSCSVPESL(aReg)
		EndIf	
		
	Else
		msgAlert(STR0003)/*"Não foram encontrados registros para gerar o quadro DIOPS de Saldo da Provisão de Eventos/Sinistros a liquidar"*/
	EndIf	
		
EndIf

Return

/*/{Protheus.doc} PLSegPESL
Query Segregação dos dados

@author Karine Riquena Limp
@since 06/02/2017
@version 12 ++RogerC

/*/
Function PLSEGPESL(dDatDe, dDatRef, lMsg) 
Local nQtdBen 	:= 0
Local aValores 	:= {}
Local nQtdLim	:= 100000	// Limite de beneficiario que determina se é uma pequena ou grande empresa

Default dDatRef:= dDataBase
// Obrigatoriedade de apresentação de dados até 36 meses anteriores
Default dDatDe := dDatRef - (36*30)
Default lMsg	:= .T.

nQtdBen 	:= PLQtdBen(dDatRef, lMsg)

// Normativa RN 430 insere campos a partir da competencia 2018
If B3D->B3D_ANO >= '2018'
	nQtdLim	:= 20000
EndIf

// Tipo de Aviso: 0 - Avisados últimos 30 dias (Qtde Benef < 100k), 1 - Avisados últimos 60 Dias (Qtde Benef >= 100k)
nTpAviso:= IIf(nQtdBen <= nQtdLim, 0, 1 )
	

If lMsg
	Processa({|| aValores := PLVlrPESL(dDatDe, nTpAviso, dDatRef, lMsg) }, STR0001/*"Aguarde"*/, STR0002 /*"Gerando dados..."*/, .t.)
Else
	aValores 	:= PLVlrPESL(dDatDe, nTpAviso, dDatRef, lMsg)
EndIf
	
Return { ( aValores[2,1]+aValores[2,2]+aValores[2,3]+aValores[2,4]+nQtdBen > 0 ), IIf( aValores[1],{aValores[2,1], aValores[2,2], aValores[2,3], aValores[2,4], nQtdBen}, {0, 0, 0, 0, nQtdBen} )  }



/*/{Protheus.doc} PLQtdBen
Query para buscar a quantidade de beneficiários ativos na data 31/12 
do ano anterior ao ano da data referência

@author Karine Riquena Limp
@since 06/02/2017
@version Roger C.

/*/
Static Function PLQtdBen(dDatRef, lMsg)
	
Local cSql := ""
Local cMotBloExc := GETNEWPAR("MV_PLBLOEX", "")
Local aMotBloExc := {}
Local nI 		:= 1
Local cData		:= CtoD('')
Local nQtdBen	:= 0
Local nQtdBlqF	:= 0
Local nQtdBlqB	:= 0
Local lMsSql	:= Upper(TcGetDb()) $ "MSSQL"

Default dDatRef	:= dDataBase

cData	:= ALLTRIM(STR(Year(dDatRef)-1))+'1231'

// Tratamento para conteudo do parametro
aMotBloExc := Separa(cMotBloExc, ",")
cMotBloExc := ""
for nI := 1 to len(aMotBloExc)
	cMotBloExc += "'" + aMotBloExc[nI] + "',"
next nI
cMotBloExc := left(cMotBloExc, (len(cMotBloExc)-1))

If lMsg
	ProcRegua( 4 )
	IncProc( 'Calculando quantidade de beneficiários Pessoa Física' )
EndIf

// Calcula Quantidade de Beneficiarios Pessoa Física
cSql := " SELECT "
cSql += " COUNT(*) AS QTDE "
cSql += " FROM " + RetSqlName("BA1") + "  BA1 "+ Iif( lMsSql, '  (NOLOCK) ', '' )
cSql += " WHERE BA1_FILIAL= '" + xFilial("BA1") + "' "
cSql += " AND BA1_CODINT = '" + PlsIntPad() + "' "
cSql += " AND BA1_DATINC <= '" + cData + "' "
cSql += " AND BA1_CONEMP = '"+Space(Len(BA1->BA1_CONEMP))+"' "
cSql += " AND BA1.D_E_L_E_T_ = ' ' "
cSql := ChangeQuery(cSql)

If Select("QTDBEN") > 0
	QTDBEN->(dbSelectArea("QTDBEN"))
	QTDBEN->(dbCloseArea())
EndIf
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QTDBEN",.T.,.F.)
QTDBEN->(dbSelectArea("QTDBEN"))

If QTDBEN->(!EOF())
	nQtdBen	:= QTDBEN->QTDE
EndIf
QTDBEN->(dbSelectArea("QTDBEN"))
QTDBEN->(dbCloseArea())

If lMsg
	IncProc( 'Calculando quantidade de beneficiários Pessoa Juridica ' )
EndIf

// Calcula Quantidade de Beneficiarios Juridico menos Intercâmbio
cSql := " SELECT "
cSql += " COUNT(1) AS QTDE "
cSql += " FROM " + RetSqlName("BA1") + "  BA1 "+ Iif( lMsSql, '  (NOLOCK) ', '' )

// Contrato
cSql += "INNER JOIN "+RetSqlName("BT5")+" BT5 "+ Iif( lMsSql, '  (NOLOCK) ', '' )
cSql += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cSql += "  AND BT5_CODINT=BA1.BA1_CODINT "
cSql += "  AND BT5_CODIGO=BA1.BA1_CODEMP "
cSql += "  AND BT5_NUMCON=BA1.BA1_CONEMP "
cSql += "  AND BT5_VERSAO=BA1.BA1_VERCON "
cSql += "  AND BT5_INTERC <> '1' "
cSql += "  AND BT5_INFANS = '1' "
cSql += "  AND BT5.D_E_L_E_T_='' "

cSql += " WHERE BA1_FILIAL= '" + xFilial("BA1") + "' "
cSql += " AND BA1_CODINT = '" + PlsIntPad() + "' "
cSql += " AND BA1_DATINC <= '" + cData + "' "
cSql += " AND BA1_CONEMP > '"+Space(Len(BA1->BA1_CONEMP))+"' "
cSql += " AND BA1.D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)

If Select("QTDBEN") > 0
	QTDBEN->(dbSelectArea("QTDBEN"))
	QTDBEN->(dbCloseArea())
EndIf
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QTDBEN",.T.,.F.)
QTDBEN->(dbSelectArea("QTDBEN"))

If QTDBEN->(!EOF())
	nQtdBen	+= QTDBEN->QTDE
EndIf
QTDBEN->(dbSelectArea("QTDBEN"))
QTDBEN->(dbCloseArea())

If lMsg
	IncProc( 'Calculando bloqueio de famílias ' )
EndIf

// Calcula bloqueios de família para descontar do total de beneficiários
cSql := " SELECT BC3.BC3_MATRIC"
cSql += " FROM " + RetSqlName("BC3") + " BC3 "+ Iif( lMsSql, '  (NOLOCK) ', '' )
cSql += " WHERE BC3.BC3_FILIAL ='" + xFilial("BC3") + "' "
cSql += " AND BC3.BC3_TIPO = '0' "
cSql += " AND ((BC3_DATA = ' ' OR BC3_DATA >= '" + cData + "') "
cSql += " AND (BC3.R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("BC3") 
cSql += " 						 WHERE BC3_DATA <= '" + cData  
cSql += "'  					 AND BC3_MATRIC = BC3.BC3_MATRIC AND D_E_L_E_T_= ' ' "
if !empty(cMotBloExc)	
	cSql += "					AND BC3_MOTBLO NOT IN (" + cMotBloExc + ") ) ) ) "
	cSql += " AND BC3_MOTBLO NOT IN (" + cMotBloExc + ") "
Else
	cSql += " ) ) ) "
endIf
cSql += " AND BC3.D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QTDBEN",.T.,.F.)
QTDBEN->(dbGoTop())


// Se achou registros
If QTDBEN->(!EOF())
	
	//-------------------
	//Criação da Temporaria para Evitar recalculo de beneficiario para familias ja bloqueadas
	//-------------------
	aFields := {}
	aadd(aFields,{"CHAVE","C",40,0})
	oTempTabl2 := FWTemporaryTable():New( "BLQTMP", aFields )
	oTempTabl2:AddIndex("INDCHV", {"CHAVE"} )
	//------------------
	//Criação da tabela
	//------------------
	oTempTabl2:Create()
	
	// Posiciona indice para busca
	BA1->(dbSetOrder(1))
	
	While QTDBEN->(!Eof())
		If !BLQTMP->(dbSeek(QTDBEN->BC3_MATRIC))
			RecLock('BLQTMP', .T. )
			BLQTMP->CHAVE := QTDBEN->BC3_MATRIC
			BLQTMP->(msUnlock())
		EndIf
		BA1->(dbSeek(xFilial('BA1')+QTDBEN->BC3_MATRIC))
		While !BA1->(Eof()) .and.  BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == QTDBEN->BC3_MATRIC
			nQtdBlqF ++
			BA1->(dbSkip())
		EndDo
		QTDBEN->(dbSkip())
	EndDo

EndIf

QTDBEN->(dbSelectArea("QTDBEN"))
QTDBEN->(dbCloseArea())

If lMsg
	IncProc( 'Calculando bloqueio de beneficiários ' )
EndIf

cSql := " SELECT BCA.BCA_MATRIC "
cSql += " FROM " + RetSqlName("BCA") + " BCA "+ Iif( lMsSql, '  (NOLOCK) ', '' )
cSql += " WHERE BCA.BCA_FILIAL ='" + xFilial("BCA") + "' "
cSql += " AND BCA.BCA_TIPO = '0' "
cSql += " AND ((BCA_DATA = ' ' OR BCA_DATA >= '" + cData + "') "
cSql += " AND (BCA.R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("BCA") 
cSql += "						 WHERE BCA_DATA <= '" + cData  
cSql += "' 						 AND BCA_MATRIC = BCA.BCA_MATRIC AND BCA_TIPREG = BCA.BCA_TIPREG AND D_E_L_E_T_= ' ' "
if !empty(cMotBloExc)	
	cSql += "					AND BCA_MOTBLO NOT IN (" + cMotBloExc + ") ) ) ) "
	cSql += " AND BCA_MOTBLO NOT IN (" + cMotBloExc + ") "
Else
	cSql += " ) ) ) "
endIf
cSql += " AND BCA.D_E_L_E_T_ = ' ' "
cSql := ChangeQuery(cSql)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QTDBEN",.T.,.F.)
QTDBEN->(dbSelectArea("QTDBEN"))

// Se achou registros
If QTDBEN->(!EOF())

	While QTDBEN->(!Eof())
		// Se achar no temporário é porque já contou
		If BLQTMP->(dbSeek(QTDBEN->BCA_MATRIC))
			QTDBEN->(dbSkip())
			Loop
		EndIf
		nQtdBlqB ++
		QTDBEN->(dbSkip())
	EndDo

EndIf

// Fecha os temporários
If Select('QTDBEN') > 0
	QTDBEN->(dbCloseArea())
EndIf
If Select('BLQTMP') > 0
	BLQTMP->(dbCloseArea())
EndIf

Return( nQtdBen-nQtdBlqF-nQtdBlqB )

//-------------------------------------------------------------------
/*/{Protheus.doc} SegToArray
Converte o arquivo temporário em array de dados para posterior criação do arquivo CSV.

@author	Karine Riquena Limp
@since		06/02/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function SegToArray(aReg)

	Local aDados := {}
	Local nI := 0
	Local nVlrLastDays := 0
	Local nVlrRemaining := 0
	Local nVlrTotal := 0
	Local cQtdDias := iif(MV_PAR03 == 1, "30", "60")
	
	aadd(aDados, STR0006 + ";" + STR0007 + " " + cQtdDias + " " + STR0008 + ";" + STR0009 + " " + cQtdDias + " " + STR0008 + ";" + STR0010)	
	nVlrTotal := aReg[1] + aReg[2]
	
	aadd(aDados, ALLTRIM(STR(aReg[3])) + ";" + alltrim(TRANSFORM(ROUND(aReg[1],2),"@E 999,999,999.99")) + ";" + alltrim(TRANSFORM(ROUND(aReg[2],2),"@E 999,999,999.99")) + ";" + alltrim(TRANSFORM(ROUND(nVlrTotal,2),"@E 999,999,999.99")) )
	
	
Return aDados    

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCSVPESL
Monta arquivo CSV com o layout definido a partir da busca do saldo da PESL

@author	Karine Riquena Limp
@since		06/02/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function PLSCSVPESL(aReg)

Local cDirCsv 	:= ""
Local nFileCsv 	:= 0
Local cTitulo 	:= ""
Local nI 			:= 1
Local cFileName	:= STR0011 + alltrim(strZero(MV_PAR01,2)) + "-" + alltrim(str(MV_PAR02)) + ".csv"
Local cCabec		:= STR0012 + ": " + alltrim(strZero(MV_PAR01,2)) + "/" + alltrim(str(MV_PAR02)) + "."

//Gera arquivo CSV
PLSGerCSV(cFileName, cCabec, aReg)	

MsgAlert("Arquivo: "+cFileName+" gerado com sucesso!")

Return                



/*/{Protheus.doc} PLVlrPESL(dDatDe, nTpAviso, dDatRef, lMsg)
Impressao

@author Roger 
@since 15/10/2017
@version ALL
/*/
Static Function PLVlrPESL(dDatDe, nTpAviso, dDatRef, lMsg)
local cLastBD7		:= ""
local aRet			:= {}
local lCT2Ativo		:= .f.
Local nPosSE2		:= 0
Local lSaldoSE2		:= .F.
Local cTexto		:= "Provisão de Eventos e Sinistros a Liquidar"
// Tipo de Aviso: 0 - Avisados últimos 30 dias, 1 - Avisados últimos 60 Dias
Local dDatAviso		:= dDatRef - IIf(nTpAviso == 0, 29, 59 )
Local nVlrUltimos	:= 0
Local nVlrPrevio	:= 0 
Local nVlrCAUlt		:= 0
Local nVlrCAPrev	:= 0 
Local nTotReg		:= 0
Local nCont			:= 0
Local cLastProd		:= ''
Local cTpBen		:= ''

Default dDatDe		:= dDataBase
Default nTpAviso	:= 0
Default dDatRef		:= dDataBase
Default lMsg		:= .T.

aRet := GetTrbQuery(dDatDe,dDatRef,lMsg,IIf(nTpAviso == 0, 29, 59 ))

if aRet[1]		// Se .T. não encontrou dados
	If lMsg
		MsgAlert("Não foi possível obter os dados referente ao movimento da "+cTexto+".")
	EndIf
    Return( { .F., { 0,0,0,0 } } )
endIf

//define regua
If lMsg
	TRBLIV->(dbEval({|| nTotReg++ }))
	ProcRegua(nTotReg)
EndIf
	
While !TRBLIV->(eof())

	If TRBLIV->TIPO == 'L'
		If TRBLIV->GRUPO == '2'
			nVlrUltimos	+= TRBLIV->PROVISAO
		Else
			nVlrPrevio	+= TRBLIV->PROVISAO
		EndIf
	Else
		If TRBLIV->GRUPO == '2'
			nVlrCAUlt	+= TRBLIV->PROVISAO 
		Else
			nVlrCAPrev	+= TRBLIV->PROVISAO
		EndIf
	EndIf

	TRBLIV->(dbskip())
EndDo

//Fecha a tabela temporária 
TRBLIV->(dbCloseArea())

Return{ .T., { nVlrUltimos, nVlrPrevio, nVlrCaUlt, nVlrCaPrev } }

/*/{Protheus.doc} PLSVlrPESL
Executa query 

@author DEV
@since 05/03/2016
@version ALL
/*/
Static Function GetTrbQuery(dDatDe,dDatRef,lMsg,nDias)
local nX		 := 0
local nFator	 := 0  
local cQuery	 := ''
local aStruSQL 	 := {}
Local lMsSql     := Upper(TcGetDb()) $ "MSSQL"
Local cNotIn	 := RetLocIgn()

Default nDias		:= 60

dataate := DtoS(dDatRef)
cSql := ""
cSql += " Select TIPO, GRUPO, SUM(VALOR) PROVISAO from ( "
cSql += " Select CT2_DATA, TIPO, VALOR, RECCT2, FK2_DATa, FK2_DTDISP,  VENCTO,  RECSE2,  CASE WHEN DATAD >= '" + DtoS(StoD(dataate) - nDias) + "' THEN '1' ELSE '2' END GRUPO from ( "
cSql += " Select DISTINCT CT2_DATA, "
cSql += " CASE "
cSql += " WHEN SUBSTRING(CONTA,7,3) <> '033' THEN 'L' "
cSql += " WHEN SUBSTRING(CONTA,1,9) = '211111033' OR SUBSTRING(CONTA,1,9) = '211112033' OR SUBSTRING(CONTA,1,9) = '211121033' OR SUBSTRING(CONTA,1,9) = '211122033' THEN 'I' "
cSql += " ELSE 'L' END TIPO, "
cSql += " VALOR, RECCT2, FK2_DATa, FK2_DTDISP,  VENCTO,  RECSE2, COALESCE(BD7_DTDIGI, CT2_DATA) DATAD  from ( "
cSql += " Select CT2_DATA, CONTA, VALOR, RECCT2, FK2_DATa, FK2_DTDISP, COALESCE(SE2.E2_VENCTO ,  SE2K.E2_VENCTO, SE2L.E2_VENCTO, CT2_DATA) VENCTO, COALESCE(SE2.R_E_C_N_O_ ,SE2K.R_E_C_N_O_, SE2L.R_E_C_N_O_, 0) RECSE2  from ( "
cSql += " Select DISTINCT "
cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_CREDIT CONTA, CT2_VALOR VALOR, CT2.R_E_C_N_O_ RECCT2 "
cSql += " , COALESCE(CV3_TABORI, '   ') TABORI, COALESCE(CV3_RECORI, 0) RECORI "    //", FK2_IDDOC, FK7_CHAVE "
cSql += " from " + retSqlName("CT2") + " CT2 "
cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
cSql += " On "
cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "
cSql += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
cSql += " CV3.D_E_L_E_T_ = ' ' "
csql += " Where "
Csql += " CT2_FILIAL = '" + xfilial("CT2") + "' AND "
cSql += " CT2_DATA <= '" + dataate + "' AND "
cSql += " ( "
cSql += " CT2_CREDIT Like '21111102%' OR "
cSql += " CT2_CREDIT Like '21111202%' OR "
cSql += " CT2_CREDIT Like '21112102%' OR "
cSql += " CT2_CREDIT Like '21112202%' OR "
cSql += " CT2_CREDIT Like '21111103%' OR "
cSql += " CT2_CREDIT Like '21111203%' OR "
cSql += " CT2_CREDIT Like '21112103%' OR "
cSql += " CT2_CREDIT Like '21112203%' OR "
cSql += " CT2_CREDIT Like '23111102%' OR "
cSql += " CT2_CREDIT Like '23111202%' OR "
cSql += " CT2_CREDIT Like '23112102%' OR "
cSql += " CT2_CREDIT Like '23112202%' OR "
cSql += " CT2_CREDIT Like '23111103%' OR "
cSql += " CT2_CREDIT Like '23111203%' OR "
cSql += " CT2_CREDIT Like '23112103%' OR "
cSql += " CT2_CREDIT Like '23112203%'  "
cSql += " ) AND "
cSql += " CT2.D_E_L_E_T_ = ' ' "
cSql += " Union "
cSql += " Select DISTINCT "
cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO CONTA, CT2_VALOR * -1 VALOR, CT2.R_E_C_N_O_ RECCT2 "
cSql += " , COALESCE(CV3_TABORI, '   ') TABORI, COALESCE(CV3_RECORI, 0) RECORI "    //", FK2_IDDOC, FK7_CHAVE "
cSql += " from " + retSqlName("CT2") + " CT2 "
cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
cSql += " On "
cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "
cSql += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
cSql += " CV3.D_E_L_E_T_ = ' ' "
csql += " Where "
Csql += " CT2_FILIAL = '" + xfilial("CT2") + "' AND "
cSql += " CT2_DATA <= '" + dataate + "' AND "
cSql += " ( "
cSql += " CT2_DEBITO Like '21111102%' OR "
cSql += " CT2_DEBITO Like '21111202%' OR "
cSql += " CT2_DEBITO Like '21112102%' OR "
cSql += " CT2_DEBITO Like '21112202%' OR "
cSql += " CT2_DEBITO Like '21111103%' OR "
cSql += " CT2_DEBITO Like '21111203%' OR "
cSql += " CT2_DEBITO Like '21112103%' OR "
cSql += " CT2_DEBITO Like '21112203%' OR "
cSql += " CT2_DEBITO Like '23111102%' OR "
cSql += " CT2_DEBITO Like '23111202%' OR "
cSql += " CT2_DEBITO Like '23112102%' OR "
cSql += " CT2_DEBITO Like '23112202%' OR "
cSql += " CT2_DEBITO Like '23111103%' OR "
cSql += " CT2_DEBITO Like '23111203%' OR "
cSql += " CT2_DEBITO Like '23112103%' OR "
cSql += " CT2_DEBITO Like '23112203%'  "
cSql += " ) AND "
cSql += " CT2.D_E_L_E_T_ = ' ' "
cSql += " ) Z"
cSql += " LEFT join " + RetSqlName("FK2") + " FK2"
cSql += " On"
cSql += " Z.TABORI = 'FK2' AND"
cSql += " FK2.R_E_C_N_O_ = Z.RECORI AND"
cSql += " FK2.D_E_L_E_T_ = ' '"
cSql += " Left Join  " + RetSqlName("FK7") + "  FK7"
cSql += " On"
cSql += " FK7_FILIAL = '" + xFilial("FK7") + "' AND "
cSql += " FK7_IDDOC = FK2.FK2_IDDOC AND"
cSql += " FK7.D_E_L_E_T_ =  ' '"
cSql += " Left Join  " + RetSqlName("SE2") + "  SE2K"
cSql += " On"
cSql += " FK7_CHAVE = SE2K.E2_FILIAL || '|' || SE2K.E2_PREFIXO || '|' || SE2K.E2_NUM || '|' || SE2K.E2_PARCELA || '|' || SE2K.E2_TIPO || '|' || SE2K.E2_FORNECE || '|' || SE2K.E2_LOJA AND"
cSql += " SE2K.D_E_L_E_T_ = ' '"
cSql += " Left Join  " + RetSqlName("FI8") + "  FI8"
cSql += " On"
cSql += " FK7_CHAVE = FI8.FI8_FILDES || '|' || FI8.FI8_PRFDES || '|' || FI8.FI8_NUMDES || '|' || FI8.FI8_PARDES || '|' || FI8.FI8_TIPDES || '|' || FI8.FI8_FORDES || '|' || FI8.FI8_LOJDES AND"
cSql += " FI8.D_E_L_E_T_ = ' '"
cSql += " left Join  " + RetSqlName("SE2") + "  SE2L"
cSql += " On"
cSql += " FI8.FI8_PRFORI = SE2L.E2_PREFIXO "
cSql += "  AND FI8.FI8_NUMORI = SE2L.E2_NUM "
cSql += "  AND FI8.FI8_PARORI = SE2L.E2_PARCELA "
cSql += "  AND FI8.FI8_TIPORI = SE2L.E2_TIPO "
cSql += "  AND FI8.FI8_FORORI = SE2L.E2_FORNECE"
cSql += "  AND FI8.FI8_LOJORI = SE2L.E2_LOJA"
cSql += " AND SE2L.D_E_L_E_T_ = ' '"
cSql += " Left join  " + RetSqlName("BD7") + "  BD7"
cSql += " On"
cSql += " Z.TABORI = 'BD7' AND"
cSql += " BD7.R_E_C_N_O_ = Z.RECORI AND"
cSql += " BD7.D_E_L_E_T_ = ' '"
cSql += " Left Join  " + RetSqlName("SE2") + "  SE2"
cSql += " On"
cSql += " BD7_CHKSE2 = SE2.E2_FILIAL || '|' || SE2.E2_PREFIXO || '|' || SE2.E2_NUM || '|' || SE2.E2_PARCELA || '|' || SE2.E2_TIPO || '|' || SE2.E2_FORNECE || '|' || SE2.E2_LOJA AND"
cSql += " SE2.D_E_L_E_T_ = ' '"
cSql += " ) C "
cSql += " Left Join " + RetSqlName("SE2") + " SE2 "
cSql += " On "
cSql += " C.RECSE2 = SE2.R_E_C_N_O_ "
cSql += " Left Join " + RetSqlName("BD7") + " BD7 "
cSql += " On "
cSql += " BD7_CHKSE2 = SE2.E2_FILIAL || '|' || SE2.E2_PREFIXO || '|' || SE2.E2_NUM || '|' || SE2.E2_PARCELA || '|' || SE2.E2_TIPO || '|' || SE2.E2_FORNECE || '|' || SE2.E2_LOJA  "
cSql += " AND BD7.D_E_L_E_T_ = ' ' "
cSql += " ) A "
cSql += " ) V "
cSql += " Group By TIPO, GRUPO "

MPSysOpenQuery( changeQuery(cSql), 'TRBLIV' )

TRBLIV->(dbGotop())

Return( { TRBLIV->(Eof()) } )
