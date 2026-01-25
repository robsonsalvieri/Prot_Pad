#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TSISFTC20
	Classe responsavel por reintegrar as notas 
	(update fake na SFT)de acordo com os documentos não encontrados na C20).
	Tambem eh realizado a limpeza da V5R após a reintegracao.
    @type Class
	@author Denis Souza
	@since  20/07/2022
	@return Nil, nulo, não tem retorno.
/*/
Class TsiSftC20
	Data cSourceBr   As Character
	Data cBranchCode As Character
	Data cDateOf	 As Character
	Data cDateUp	 As Character	
	Data cQry  		 As Character	
	Data cUpdSFT     As Character
	Data cUpdSF3     As Character
	Data cUpdV5R  	 As Character
	Data cDbType     As Character
	Data cSubStr     As Character
	Data cIsNullSQL  As Character
	Data cConvSF3  	 As Character
	Data cConvSFT  	 As Character
	Data cConcat   	 As Character
	Data cIndCFOP 	 As Character
	Data cIndSCFOP	 As Character
	Data cNoLock 	 As Character
	Data lExecScript As Logical
	Data lV5rErpkey	 As Logical
	Data nTmIndOpe   As Numeric
	Data nTmCliFor 	 As Numeric
	Data nTmLoja   	 As Numeric
	Data nTmSerie  	 As Numeric
	Data nTmNumDoc 	 As Numeric
	Data nTmFtNFis	 As Numeric
	Data nTmFtSer	 As Numeric
	Data nTmDtes   	 As Numeric
	Data nQtdPipe	 As Numeric
	Data nPosIni 	 As Numeric
	Data nTmCmp  	 As Numeric
	Data nStatus  	 As Numeric
    Method New() Constructor
	Method UpdFakeSF3()
	Method UpdFakeSFT()
	Method DelDivV5R()
	Method CommonQuery()	
	Method ExecScript()
EndClass

 /*/{Protheus.doc} New
	(Método construtor )
	@author Denis Souza
	@since  20/07/2022
	@return Nil, nulo, não tem retorno.
/*/
Method New( cSourceBr, cBranchCode, dDateOf, dDateUp ) Class TsiSftC20
	Default cSourceBr  	:= cEmpAnt + cFilAnt
	Default cBranchCode := cFilAnt
	Default dDateOf 	:= ""
	Default dDateUp 	:= ""

	Self:cSourceBr   := cSourceBr
	Self:cBranchCode := cBranchCode
	if !Empty(dDateOf)
		Self:cDateOf := DtoS(dDateOf)
	else
		Self:cDateOf := Dtos( CtoD('01/' + StrZero(Month(dDataBase),2) + '/' + cValToChar(Year(dDataBase))))
	endif
	if !Empty(dDateUp)
		Self:cDateUp := DtoS(dDateUp)
	else //Se Não passar parametro filtra mes todo
		Self:cDateUp := Dtos(Lastday(Stod(Self:cDateOf)))
	endif
	Self:lExecScript := .F.
	Self:lV5rErpkey  := V5R->(FieldPos("V5R_ERPKEY")) > 0
	Self:cDbType     := Upper(Alltrim(TCGetDB()))
	Self:cQry	     := ""
	Self:cUpdSFT	 := ""
	Self:cUpdSF3	 := ""
	Self:cUpdV5R	 := ""
	Self:nStatus 	 := 0
	Self:cIndCFOP    := "'4'"
	Self:cIndSCFOP   := "'5'"
	If Self:cDbType $ "ORACLE"
		Self:cSubStr    := "SUBSTR"
		Self:cIsNullSQL := "NVL"
		Self:cConvSFT   := " (cast(to_char(MAX(SFT.S_T_A_M_P_),'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23))) "
		Self:cConvSF3   := " (cast(to_char(SF3.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23))) " //SF3 sem o Max
		Self:cConcat    := "||"
		Self:cNoLock    := ""
	ElseIf Self:cDbType $ "POSTGRES"
		Self:cSubStr    := "SUBSTR"
		Self:cIsNullSQL := "COALESCE"
		Self:cConvSFT   := " (cast(to_char(MAX(SFT.S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23))) "
		Self:cConvSF3   := " (cast(to_char(SF3.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23))) "
		Self:cConcat    := "||"
		Self:cNoLock    := ""
	Else //MSSQL,MYSQL,PROGRESS
		Self:cSubStr    := "SUBSTRING"
		Self:cIsNullSQL := "ISNULL"
		Self:cConvSFT   := " CONVERT(VARCHAR(23),MAX(SFT.S_T_A_M_P_),21) "
		Self:cConvSF3   := " CONVERT(VARCHAR(23),SF3.S_T_A_M_P_,21) "
		Self:cConcat    := "+"
		If "MSSQL" $ Self:cDbType
			Self:cNoLock := "(NOLOCK)"
		endif
	EndIf
	Self:nTmIndOpe := GetSx3Cache( 'C20_INDOPE' , 'X3_TAMANHO')
	Self:nTmCliFor := GetSx3Cache( 'FT_CLIEFOR' , 'X3_TAMANHO')
	Self:nTmLoja   := GetSx3Cache( 'FT_LOJA'    , 'X3_TAMANHO')
	Self:nTmSerie  := GetSx3Cache( 'C20_SERIE'  , 'X3_TAMANHO')
	Self:nTmNumDoc := GetSx3Cache( 'C20_NUMDOC' , 'X3_TAMANHO')
	Self:nTmFtNFis := GetSx3Cache( 'FT_NFISCAL' , 'X3_TAMANHO')
	Self:nTmFtSer  := GetSx3Cache( 'FT_SERIE'	, 'X3_TAMANHO')
	Self:nTmDtes   := GetSx3Cache( 'C20_DTES'   , 'X3_TAMANHO')
Return Nil

/*/{Protheus.doc} UpdFakeSF3
(Método responsavel por executar o update fake )
Update em lote na SF3 de acordo com itens divergentes encontrados.
@author Denis Souza
@since  19/01/2023
@return Nil, nulo, não tem retorno.
/*/
Method UpdFakeSF3( oJsItem ) Class TsiSftC20

Default oJsItem := Nil

Self:lExecScript := .F.

::cUpdSF3 := "UPDATE " + RetSqlName("SF3") + " SET D_E_L_E_T_ = D_E_L_E_T_ WHERE R_E_C_N_O_ IN "
::cUpdSF3 += " ( "

if valtype(oJsItem) == 'U' //executa para reintegrar todos com queryparam
	::cUpdSF3 += " SELECT SF3RECNO FROM ( "
	::cUpdSF3 += ::CommonQuery(.T.,"SF3")
elseif valtype(oJsItem) == 'J' //executa para reintegrar por item selecionado
	::cUpdSF3 += " SELECT ATUSF3.R_E_C_N_O_ FROM " + RetSqlName("SF3") + " ATUSF3 " + ::cNoLock
	::cUpdSF3 += " WHERE "
	::cUpdSF3 += " ATUSF3.F3_FILIAL = '" + oJsItem['branchcode'] + "' "
	::cUpdSF3 += " AND ATUSF3.F3_CFO " + iif( Alltrim( oJsItem['operationtype'] ) == "0" , "<= " + ::cIndCFOP , "> " + ::cIndCFOP )
	::cUpdSF3 += " AND ATUSF3.F3_ENTRADA = '" + separa(oJsItem['typingdate'],'-')[1] + PadL(separa(oJsItem['typingdate'],'-')[2],2,"0") + PadL(separa(oJsItem['typingdate'],'-')[3],2,"0") + "' "
	::cUpdSF3 += " AND ATUSF3.F3_SERIE = '" + Padr(oJsItem['series'],::nTmFtSer,' ') + "' "
	::cUpdSF3 += " AND ATUSF3.F3_NFISCAL = '" + Padr(oJsItem['documentnumber'],::nTmFtNFis,' ') + "' "
	::cUpdSF3 += " AND ATUSF3.F3_CLIEFOR = '" + Padr(oJsItem['participantcode'],::nTmCliFor,' ') + "' "
	::cUpdSF3 += " AND ATUSF3.F3_LOJA = '" + Padr(oJsItem['store'],::nTmLoja,' ') + "' "
	::cUpdSF3 += " AND ATUSF3.D_E_L_E_T_ = ' ' "
endif
::cUpdSF3 += " ) "
::ExecScript( ::cUpdSF3 )

Return ::lExecScript

 /*/{Protheus.doc} UpdFakeSFT
(Método responsavel por executar o update fake )
Update em lote na SFT de acordo com itens divergentes encontrados.
@author Denis Souza
@since  20/07/2022
@return Nil, nulo, não tem retorno.
/*/
Method UpdFakeSFT( oJsItem ) Class TsiSftC20

Default oJsItem := Nil

Self:lExecScript := .F.

::cUpdSFT := "UPDATE " + RetSqlName("SFT") + " SET D_E_L_E_T_ = D_E_L_E_T_ WHERE R_E_C_N_O_ IN "
::cUpdSFT += " ( "
::cUpdSFT += " SELECT ATUSFT.R_E_C_N_O_ FROM " + RetSqlName("SFT") + " ATUSFT " + ::cNoLock

if valtype(oJsItem) == 'U' //executa para reintegrar todos com queryparam
	::cUpdSFT += ::CommonQuery(.T.,"SFT")
	::cUpdSFT += " ATUSFT.FT_FILIAL = DIVERGENTE.F3_FILIAL "
	::cUpdSFT += " AND ATUSFT.FT_TIPOMOV = DIVERGENTE.TIPOMOV "
	::cUpdSFT += " AND ATUSFT.FT_ENTRADA = DIVERGENTE.F3_ENTRADA "
	::cUpdSFT += " AND ATUSFT.FT_SERIE = DIVERGENTE.F3_SERIE "
	::cUpdSFT += " AND ATUSFT.FT_NFISCAL = DIVERGENTE.F3_NFISCAL "
	::cUpdSFT += " AND ATUSFT.FT_CLIEFOR = DIVERGENTE.CODPART "
	::cUpdSFT += " AND ATUSFT.FT_LOJA = DIVERGENTE.LOJA "
	::cUpdSFT += " AND ATUSFT.D_E_L_E_T_ = ' ' "
elseif valtype(oJsItem) == 'J' //executa para reintegrar por item selecionado
	::cUpdSFT += " WHERE "
	::cUpdSFT += " ATUSFT.FT_FILIAL = '" + oJsItem['branchcode'] + "' "
	::cUpdSFT += " AND ATUSFT.FT_TIPOMOV = '" + iif(Alltrim(oJsItem['operationtype'])=="0","E","S") + "' " //conforme regra do frontend
	::cUpdSFT += " AND ATUSFT.FT_ENTRADA = '" + separa(oJsItem['typingdate'],'-')[1] + PadL(separa(oJsItem['typingdate'],'-')[2],2,"0") + PadL(separa(oJsItem['typingdate'],'-')[3],2,"0") + "' "
	::cUpdSFT += " AND ATUSFT.FT_SERIE = '" + Padr(oJsItem['series'],::nTmFtSer,' ') + "' "
	::cUpdSFT += " AND ATUSFT.FT_NFISCAL = '" + Padr(oJsItem['documentnumber'],::nTmFtNFis,' ') + "' "
	::cUpdSFT += " AND ATUSFT.FT_CLIEFOR = '" + Padr(oJsItem['participantcode'],::nTmCliFor,' ') + "' "
	::cUpdSFT += " AND ATUSFT.FT_LOJA = '" + Padr(oJsItem['store'],::nTmLoja,' ') + "' "
	::cUpdSFT += " AND ATUSFT.D_E_L_E_T_ = ' ' "
endif
::cUpdSFT += " ) "
::ExecScript( ::cUpdSFT )

Return ::lExecScript

 /*/{Protheus.doc} CommonQuery

@author Denis Souza
@since  20/07/2022
@return Nil, nulo, não tem retorno.
/*/
Method CommonQuery( lEntSai, cAliasUpd ) Class TsiSftC20

Default lEntSai 	:= .T.
Default cAliasUpd 	:= "SFT"

if cAliasUpd == "SFT"
	::cQry := "INNER JOIN ( "
	::cQry += "SELECT F3_FILIAL,F3_ENTRADA,TIPOMOV,F3_NFISCAL,F3_SERIE,CODPART,LOJA FROM ( " 
endif

::cQry += "SELECT DISTINCT TAB2.F3_FILIAL, TAB2.ERP, "
::cQry += ::cIsNullSQL + "((SELECT CASE WHEN C20.D_E_L_E_T_='*' THEN 'Não' WHEN C20.C20_STAMP <> ' ' THEN 'Sim' ELSE 'Não' END FROM " 
::cQry += RetSqlName( 'C20' ) + " C20 " + ::cNoLock + " WHERE C20.R_E_C_N_O_ = TAB2.C20REC),'Não') TAF, "
::cQry += "TAB2.F3_ENTRADA,TAB2.TIPOMOV,TAB2.F3_NFISCAL,TAB2.F3_SERIE, "
::cQry += ::cIsNullSQL + "((SELECT " + ::cSubStr + "(C20.C20_STAMP,1,16) FROM " + RetSqlName( 'C20' ) + " C20 " + ::cNoLock
::cQry += " WHERE C20.R_E_C_N_O_ = TAB2.C20REC ),' ') C20STAMP, "
if cAliasUpd == "SFT"
	::cQry += ::cSubStr + "(TAB2.SFTSTAMP,1,16) SFTSTAMP, "
else
	::cQry += ::cSubStr + "(TAB2.SF3STAMP,1,16) SF3STAMP, "
endif
::cQry += " TAB2.CANCERP, "
::cQry += ::cIsNullSQL + "((SELECT CASE WHEN C20.C20_CODSIT IN ('000003','000004') THEN 'Sim' ELSE 'Não' END FROM "
::cQry += RetSqlName( 'C20' ) + " C20 " + ::cNoLock + " WHERE C20.R_E_C_N_O_ = TAB2.C20REC),'Não') CANCTAF, "
::cQry += "TAB2.CODPART, TAB2.LOJA "

if cAliasUpd == "SF3"
	::cQry += ",TAB2.SF3RECNO "
endif

::cQry += "FROM ( "
::cQry += "SELECT SF3.F3_FILIAL, "
::cQry += "CASE WHEN SF3.D_E_L_E_T_ = '*' THEN 'Não' ELSE 'Sim' END ERP, "
::cQry += "SF3.F3_ENTRADA, "

if lEntSai //utiliza E ou S devido chave no FT_TIPOMOV
	::cQry += "CASE WHEN SF3.F3_CFO <= " + ::cIndCFOP + " THEN 'E' ELSE 'S' END TIPOMOV, "
else //utiliza 0 ou 1 devido primeiro campo na chave do V5R_ERPKEY
	::cQry += "CASE WHEN SF3.F3_CFO <= " + ::cIndCFOP + " THEN '0' ELSE '1' END TIPOMOV, "
endif

::cQry += "SF3.F3_NFISCAL, "
::cQry += "SF3.F3_SERIE, "

::cQry += ::cIsNullSQL + "((SELECT MAX(C20.R_E_C_N_O_) FROM " + RetSqlName( 'C20' ) + " C20 " + ::cNoLock + " WHERE C20.C20_FILIAL = SF3.F3_FILIAL "
::cQry += "AND C20.C20_INDOPE = CASE WHEN SF3.F3_CFO <= " + ::cIndCFOP + " THEN '0'ELSE '1' END AND C20.C20_CODPAR = C1H.C1H_ID "
::cQry += "AND LTRIM(RTRIM(C20.C20_SERIE)) = LTRIM(RTRIM(SF3.F3_SERIE)) "
::cQry += "AND LTRIM(RTRIM(C20.C20_NUMDOC)) = LTRIM(RTRIM(SF3.F3_NFISCAL)) AND C20.C20_DTES = SF3.F3_ENTRADA ),0) C20REC, "

if cAliasUpd == "SFT"
	::cQry += ::cIsNullSQL + "((SELECT " + ::cConvSFT + " FROM " + RetSqlName( 'SFT' ) + " SFT " + ::cNoLock + " WHERE SFT.FT_FILIAL = SF3.F3_FILIAL "
	::cQry += "AND SFT.FT_IDENTF3 = SF3.F3_IDENTFT AND SFT.FT_ENTRADA = SF3.F3_ENTRADA AND SFT.FT_SERIE = SF3.F3_SERIE AND SFT.FT_NFISCAL = SF3.F3_NFISCAL "
	::cQry += "AND SFT.FT_CLIEFOR = SF3.F3_CLIEFOR AND SFT.FT_LOJA = SF3.F3_LOJA ), ' ') SFTSTAMP, "
else
	::cQry += ::cIsNullSQL + "( " + ::cConvSF3 + ", ' ') SF3STAMP, "
endif

::cQry += "CASE WHEN SF3.F3_DTCANC <> ' ' AND LTRIM(RTRIM(SF3.F3_OBSERV)) = 'NF CANCELADA' THEN 'Sim' ELSE 'Não' END CANCERP, "

::cQry += "CASE WHEN ( SF3.F3_CFO <= " + ::cIndCFOP + " AND SF3.F3_TIPO IN ( ' ','C','I','N','S','P' ) ) "
::cQry += "OR ( SF3.F3_CFO >= " + ::cIndSCFOP + " AND SF3.F3_TIPO IN ('B','D') ) "
::cQry += "THEN SA2.A2_COD ELSE SA1.A1_COD END CODPART, "

::cQry += "CASE WHEN ( SF3.F3_CFO <= " + ::cIndCFOP + " AND SF3.F3_TIPO IN ( ' ','C','I','N','S','P' ) ) "
::cQry += "OR ( SF3.F3_CFO >= " + ::cIndSCFOP + " AND SF3.F3_TIPO IN ('B','D') ) "
::cQry += "THEN SA2.A2_LOJA ELSE SA1.A1_LOJA END LOJA "

if cAliasUpd == "SF3"
	::cQry += ", SF3.R_E_C_N_O_ SF3RECNO "
endif

::cQry += "FROM " + RetSqlName( 'SF3' ) + " SF3 " + ::cNoLock + " 
::cQry += "INNER JOIN (SELECT MAX(SF3.R_E_C_N_O_) SF3REC FROM " + RetSqlName( 'SF3' ) + " SF3 " + ::cNoLock

::cQry += "WHERE "
if ::cBranchCode <> "Todas"    
	::cQry += "SF3.F3_FILIAL = '" + ::cBranchCode + "' AND "
endif
::cQry += "SF3.F3_ENTRADA BETWEEN '" + ::cDateOf + "' AND '" + ::cDateUp + "' "
::cQry += " AND SF3.S_T_A_M_P_ IS NOT NULL "

::cQry += "GROUP BY SF3.F3_FILIAL,SF3.F3_IDENTFT,SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_CLIEFOR,SF3.F3_LOJA ) TAB1 ON  SF3.R_E_C_N_O_ = TAB1.SF3REC "
::cQry += TafSF3LJoin(::cDbType,::cSubStr,::cConcat,::cIndCFOP,::cNoLock,::cIndSCFOP )	
::cQry += ") TAB2 ) TMP WHERE ( TMP.ERP = 'Sim' OR TMP.TAF = 'Sim' ) AND ( TMP.ERP <> TMP.TAF OR "
if cAliasUpd == "SFT"
	::cQry += " TMP.C20STAMP < TMP.SFTSTAMP "
else
	::cQry += " TMP.C20STAMP < TMP.SF3STAMP "
endif
::cQry += " OR TMP.CANCERP <> TMP.CANCTAF ) "

if cAliasUpd == "SFT"
	::cQry += " ) DIVERGENTE ON "
endif

Return ::cQry

/*/{Protheus.doc} DelDivV5R
(Método responsavel por excluir o erros da V5R encontrados nos documentos divergentes )
@author Denis Souza
@since  20/07/2022
@return Nil, nulo, não tem retorno.
/*/
Method DelDivV5R( lLote, cRecnoV5R ) Class TsiSftC20

Default lLote     := .T.
Default cRecnoV5R := "0"

::lExecScript := .F.

::cUpdV5R := "UPDATE " + RetSqlName("V5R") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE " 

if lLote
	::cUpdV5R += " R_E_C_N_O_ IN "
	::cUpdV5R += " ( "
	::cUpdV5R += " SELECT ATUV5R.R_E_C_N_O_ FROM " + RetSqlName("V5R") + " ATUV5R " + ::cNoLock

	::cUpdV5R += ::CommonQuery(.F.)

	::cUpdV5R += " ATUV5R.V5R_ALIAS = 'C20' "
	::cUpdV5R += " AND ATUV5R.D_E_L_E_T_ = ' ' "
	::cUpdV5R += " AND ATUV5R.V5R_ERPKEY <> ' ' "

	//SFT Indice(2) FT_FILIAL, FT_TIPOMOV, FT_ENTRADA, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA
	//FT_FILIAL
	::cUpdV5R += " AND ATUV5R.V5R_CODFIL = DIVERGENTE.F3_FILIAL "

	//FT_TIPOMOV
	::nQtdPipe := 0
	::nPosIni  := (::nQtdPipe + 1) //1
	::nTmCmp   := ::nTmIndOpe      //1
	::cUpdV5R += " AND "+::cSubStr+"(ATUV5R.V5R_ERPKEY, "+cValToChar(::nPosIni)+" , "+cValToChar(::nTmCmp)+" ) = LTRIM(RTRIM(DIVERGENTE.TIPOMOV)) "

	//FT_ENTRADA
	::nQtdPipe := 1
	::nPosIni  := (::nQtdPipe + ::nTmIndOpe + 1) //3
	::nTmCmp   := ::nTmDtes 					 //8
	::cUpdV5R += " AND LTRIM(RTRIM("+::cSubStr+"(ATUV5R.V5R_ERPKEY, "+cValToChar(::nPosIni)+" , "+cValToChar(::nTmCmp)+"))) = LTRIM(RTRIM(DIVERGENTE.F3_ENTRADA)) "

	//FT_SERIE
	::nQtdPipe := 2
	::nPosIni  := (::nQtdPipe + ::nTmIndOpe + ::nTmDtes + 1 ) //12
	::nTmCmp   := ::nTmSerie 								  //20
	::cUpdV5R += " AND LTRIM(RTRIM("+::cSubStr+"(ATUV5R.V5R_ERPKEY, "+cValToChar(::nPosIni)+" , "+cValToChar(::nTmCmp)+"))) = LTRIM(RTRIM(DIVERGENTE.F3_SERIE)) "

	//FT_NFISCAL
	::nQtdPipe := 3
	::nPosIni  := (::nQtdPipe + ::nTmIndOpe + ::nTmDtes + ::nTmSerie + 1 ) //33
	::nTmCmp   := ::nTmNumDoc 											   //60
	::cUpdV5R += " AND LTRIM(RTRIM("+::cSubStr+"(ATUV5R.V5R_ERPKEY, "+cValToChar(::nPosIni)+" , "+cValToChar(::nTmCmp)+"))) = LTRIM(RTRIM(DIVERGENTE.F3_NFISCAL)) "

	//FT_CLIEFOR
	::nQtdPipe := 4
	::nPosIni  := (::nQtdPipe + ::nTmIndOpe + ::nTmDtes + ::nTmSerie + ::nTmNumDoc + 1 ) //94
	::nTmCmp   := (::nTmCliFor) 														 //06
	::cUpdV5R += " AND LTRIM(RTRIM("+::cSubStr+"(ATUV5R.V5R_ERPKEY, "+cValToChar(::nPosIni)+" , "+cValToChar(::nTmCmp)+"))) = LTRIM(RTRIM(DIVERGENTE.CODPART)) "

	//FT_LOJA
	::nQtdPipe := 5
	::nPosIni  := (::nQtdPipe + ::nTmIndOpe + ::nTmDtes + ::nTmSerie + ::nTmNumDoc + ::nTmCliFor + 1 )  //101
	::nTmCmp   := (::nTmLoja) 																			//02
	::cUpdV5R += " AND LTRIM(RTRIM("+::cSubStr+"(ATUV5R.V5R_ERPKEY, "+cValToChar(::nPosIni)+" , "+cValToChar(::nTmCmp)+"))) = LTRIM(RTRIM(DIVERGENTE.LOJA)) "

	::cUpdV5R += " ) "
else
	::cUpdV5R += " R_E_C_N_O_ = " + cRecnoV5R
endif

::ExecScript( ::cUpdV5R )

Return ::lExecScript

 /*/{Protheus.doc} ExecScript

@author Denis Souza
@since  20/07/2022
@return Nil, nulo, não tem retorno.
/*/
Method ExecScript(cScript) Class TsiSftC20

Default cScript := ''

TAFConOut("TSILOG000033: Update dos registros na SF3\SFT que sofrerão alteração fake com base nos documentos divergentes da C20 e limpeza da V5R correspondente[ Início update TSILOG000033 ]", 1, .F., "TSI" )
TAFConOut("TSILOG000033: " + cScript, 1, .F., "TSI" )

TcCommit(1) //Inicia a Transacao

::nStatus := TcSqlExec( cScript )

TcCommit(2) //Realiza o commit

TcCommit(4) //Finaliza a Transacao

if ::nStatus < 0
	::lExecScript := .F.
	TAFConOut("TSILOG000033: Erro de alteração fake Documentos Divergentes [ Início erro TSILOG000033 ]" + TCSQLError() + " [ Fim erro TSILOG000033 ] ", 1, .F., "TSI" )
else
	::lExecScript := .T.
endif

Return ::lExecScript
