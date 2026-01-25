#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

static _nTmIndOpe := GetSx3Cache( 'C20_INDOPE', 'X3_TAMANHO') //01

static _nTmCliFor := GetSx3Cache( 'FT_CLIEFOR', 'X3_TAMANHO') //02
static _nTmLoja   := GetSx3Cache( 'FT_LOJA'	  , 'X3_TAMANHO') //02

static _nTmSerie  := GetSx3Cache( 'C20_SERIE' , 'X3_TAMANHO') //03
static _nTmNumDoc := GetSx3Cache( 'C20_NUMDOC', 'X3_TAMANHO') //04
static _nTmDtes   := GetSx3Cache( 'C20_DTES'  , 'X3_TAMANHO') //05

static lV5rErp 	  := V5R->( FieldPos("V5R_ERPKEY") ) > 0
static _cDbType   := Upper( Alltrim( TCGetDB( ) ) )

/*/{Protheus.doc} TSIV5RC20
	Classe responsavel pela alteracao fake na SF3/SFT com base na chave do campo V5R_ERPKEY do V5R_ALIAS = 'C20'
    @type Class
	@author Ricardo Lovrenovic / Denis Souza
	@since 18/11/2021
	@return Nil, nulo, não tem retorno.
/*/
Class TSIV5RC20
	Data lExecSFT As Logical
	Data lExecSF3 As Logical
	Data cDtV5R	  As character

    Method New() Constructor
	Method AltFakeSF3()
	Method AltFakeSFT()
	Method _ClearV5R()
EndClass

 /*/{Protheus.doc} New
	(Método construtor )
	@author Ricardo Lovrenovic / Denis Souza
	@since 18/11/2021
	@return Nil, nulo, não tem retorno.
/*/
Method New( cSourceBr , lManual, nRecnoV5R, cBranch ) Class TSIV5RC20

	Default cSourceBr  := cEmpAnt+cFilAnt
	Default lManual    := .t.
	Default nRecnoV5R  := 0
	Default cBranch	   := ''

	if lV5rErp
		::cDtV5R := DtoS(dDatabase)

		Self:AltFakeSF3( lManual, nRecnoV5R, cBranch )
		Self:AltFakeSFT( lManual, nRecnoV5R, cBranch )
		Self:_ClearV5R( lManual, nRecnoV5R, cBranch )
	Endif

Return Nil

 /*/{Protheus.doc} AltFakeSF3
	(Método responsavel por executar o update fake na SF3)
	@author Denis Souza
	@since 18/11/2021
	@return Nil, nulo, não tem retorno.
/*/
Method AltFakeSF3( lManual, nRecnoV5R, cBranch  ) Class TSIV5RC20

Local cSql  	:= ""
Local nQtdPipe 	:= 0
Local nPosIni  	:= 0
Local nTmCmp   	:= 0
Local nStatus   := 0
Local cBd       := Upper(Alltrim(TcGetDb()))
Local cCFO 		:= ''
Local cSubStr 	:= "SUBSTR" //Default ORACLE|POSTGRES

Default lManual   := .t.
Default nRecnoV5R := 0
Default cBranch	  := ''

::lExecSF3 := .F.

If cBd $ "MSSQL|MSSQL7"
	cSubStr := "SUBSTRING"
endif

cSql := "UPDATE " + RetSqlName("SF3") + " SET D_E_L_E_T_ = ' ' WHERE R_E_C_N_O_ IN ( "
//ja que a V5R nao repete a chave e sera utiliza no IN, retirado o distinct p/ ganho performance jadlog
cSql += " SELECT SF3.R_E_C_N_O_ FROM " + RetSqlName("V5R") + " V5R " 
If "MSSQL" $ _cDbType
	cSql += " (NOLOCK) "
EndIf

cSql += " LEFT JOIN " + RetSqlName("SF3") + " SF3 "
If "MSSQL" $ _cDbType
	cSql += " (NOLOCK) "
EndIf

//SF3 Indice(1) F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_ALIQICM, R_E_C_N_O_, D_E_L_E_T_

//F3_FILIAL
cSql += " ON SF3.F3_FILIAL = V5R.V5R_CODFIL "

//TIPOMOV F3_CFO
nQtdPipe := 0
nPosIni  := (nQtdPipe + 1) //1
nTmCmp   := _nTmIndOpe 	//1

//Filtro no cCFO seguindo a ordem dos pipes e sua utilizacao na ordem do indice no filtro. Ver {#Pt1} linha75
cCFO += " AND ( "
cCFO += " (RTRIM(" + cSubStr + "( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) = '0' AND SF3.F3_CFO <= '4000' ) "
cCFO += " OR "
cCFO += " (RTRIM(" + cSubStr + "( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) = '1' AND SF3.F3_CFO > '5000' ) "
cCFO += " ) "

//F3_ENTRADA  //retirado RTRIM em campo fixo tamanho 8 ganho performance jadlog
nQtdPipe := 1
nPosIni  := (nQtdPipe + _nTmIndOpe + 1 )
nTmCmp   := _nTmDtes //8
cSql += " AND SF3.F3_ENTRADA = RTRIM(" + cSubStr + "( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "

//F3_SERIE
nQtdPipe := 2
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + 1 )
nTmCmp   := _nTmSerie //20
cSql += " AND RTRIM(SF3.F3_SERIE) = RTRIM(" + cSubStr + "( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "

//F3_NFISCAL
nQtdPipe := 3
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + _nTmSerie + 1 )
nTmCmp   := _nTmNumDoc //60
cSql += " AND RTRIM(SF3.F3_NFISCAL) = RTRIM( " + cSubStr + "( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "

//F3_CLIEFOR
nQtdPipe := 4
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + _nTmSerie + _nTmNumDoc + 1 )
nTmCmp   := (_nTmCliFor) //06
cSql += " AND RTRIM(SF3.F3_CLIEFOR) = RTRIM(" + cSubStr + "( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "

//F3_LOJA
nQtdPipe := 5
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + _nTmSerie + _nTmNumDoc + _nTmCliFor + 1 )
nTmCmp   := (_nTmLoja) //02
cSql += " AND RTRIM(SF3.F3_LOJA) = RTRIM(" + cSubStr + "( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "

//#Pt1 Após a loja, atribui o filtro do CFO devido a ordem do indice
//SF3 Indice(1) F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_ALIQICM, R_E_C_N_O_, D_E_L_E_T_
cSql += cCFO

cSql += " AND SF3.D_E_L_E_T_ = ' ' "

cSql += " WHERE "
cSql += " V5R.V5R_FILIAL = '" + xFilial("V5R") + "' "

if !lManual .and. nRecnoV5R == 0 //chamada por job(TAFA573), apenas 1x por dia ja que apos reprocessamento V5R_DATA atualizara com data de hoje
	cSql += " AND V5R.V5R_DATA < '" + ::cDtV5R + "' "
elseIf nRecnoV5R > 0 //Se passou o RECNO, filtro pelo RECNO da V5R , caso seja true, nao devera filtrar data, pois vira do reprocessamento manual do mvc da v5r ( TAFA564 )
	cSql += " AND V5R.R_E_C_N_O_ = '" + cValToChar(nRecnoV5R) + "' "
elseIf !Alltrim(cBranch) == "Todas" //reprocessa todos os documentos da filial selecionada no campo "Filial" no painel, caso seja selecionado "Todas", será reprocessado todas os docmentos. 
	cSql += " AND V5R.V5R_CODFIL =  '" + cFilAnt + "' "
endif

cSql += " AND V5R.V5R_ALIAS = 'C20' "
cSql += " AND V5R.D_E_L_E_T_ = ' ' "
cSql += " ) "

TAFConOut("TSILOG000035: Update dos registros na SF3 que sofrerão alteração fake com base no log V5R alias C20 [ Início update TSILOG000034 ]", 1, .F., "TSI" )
TAFConOut("TSILOG000035: " + cSql, 1, .F., "TSI" )
TCCommit(1) // Inicia a Transação
nStatus := tcsqlexec( cSql )
TCCommit(2) // Realiza o commit
TCCommit(4) // Finaliza a Transação

if nStatus < 0
	TAFConOut("TSILOG000035: Erro de alteração fake [ Início erro TSILOG000034 ]" + TCSQLError() + " [ Fim erro TSILOG000034 ] ", 1, .F., "TSI" )
else
	::lExecSF3 := .T.
endif

Return Nil

 /*/{Protheus.doc} AltFakeSFT
	(Método responsavel por executar o update fake )
	@author Ricardo Lovrenovic / Denis Souza
	@since 18/11/2021
	@return Nil, nulo, não tem retorno.
/*/
Method AltFakeSFT( lManual, nRecnoV5R, cBranch ) Class TSIV5RC20

Local cSql  	:= ""
Local nQtdPipe 	:= 0
Local nPosIni  	:= 0
Local nTmCmp   	:= 0
Local nStatus   := 0
Local cBd       := Upper(Alltrim(TcGetDb()))

Default lManual   := .t.
Default nRecnoV5R := 0
Default cBranch	  := ''

::lExecSFT := .F.

cSql := "UPDATE " + RetSqlName("SFT") + " SET D_E_L_E_T_ = ' ' WHERE R_E_C_N_O_ IN ( "
//ja que a V5R nao repete a chave e sera utiliza no IN, retirado o distinct p/ ganho performance jadlog
cSql += " SELECT SFT.R_E_C_N_O_ FROM " + RetSqlName("V5R") + " V5R " 
If "MSSQL" $ _cDbType
	cSql += " (NOLOCK) "
EndIf

cSql += " LEFT JOIN " + RetSqlName("SFT") + " SFT "
If "MSSQL" $ _cDbType
	cSql += " (NOLOCK) "
EndIf

//SFT Indice(2) FT_FILIAL, FT_TIPOMOV, FT_ENTRADA, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA

//FT_FILIAL
cSql += " ON SFT.FT_FILIAL = V5R.V5R_CODFIL "

//FT_TIPOMOV
nQtdPipe := 0
nPosIni  := (nQtdPipe + 1) //1
nTmCmp   := _nTmIndOpe //1

If cBd $ "ORACLE|POSTGRES" //retirado RTRIM em campo fixo tamanho 1 performance jadlog
	cSql += " AND SFT.FT_TIPOMOV = RTRIM( ( CASE WHEN SUBSTR( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) = '0' THEN 'E' ELSE 'S' END ) ) "
Else //MSSQL,MYSQL,PROGRESS
	cSql += " AND SFT.FT_TIPOMOV = RTRIM( ( CASE WHEN SUBSTRING( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) = '0' THEN 'E' ELSE 'S' END ) ) "
EndIf

//FT_ENTRADA
nQtdPipe := 1
nPosIni  := (nQtdPipe + _nTmIndOpe + 1 )
nTmCmp   := _nTmDtes //8

If cBd $ "ORACLE|POSTGRES" //retirado RTRIM em campo fixo tamanho 8 performance jadlog
	cSql += " AND SFT.FT_ENTRADA = RTRIM( SUBSTR( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
Else //MSSQL,MYSQL,PROGRESS
	cSql += " AND SFT.FT_ENTRADA = RTRIM( SUBSTRING( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
EndIf

//FT_SERIE
nQtdPipe := 2
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + 1 )
nTmCmp   := _nTmSerie //20

If cBd $ "ORACLE|POSTGRES"
	cSql += " AND RTRIM(SFT.FT_SERIE) = RTRIM( SUBSTR( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
Else //MSSQL,MYSQL,PROGRESS
	cSql += " AND SFT.FT_SERIE = RTRIM( SUBSTRING( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
EndIf

//FT_NFISCAL
nQtdPipe := 3
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + _nTmSerie + 1 )
nTmCmp   := _nTmNumDoc //60

If cBd $ "ORACLE|POSTGRES"
	cSql += " AND RTRIM(SFT.FT_NFISCAL) = RTRIM( SUBSTR( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
Else //MSSQL,MYSQL,PROGRESS
	cSql += " AND SFT.FT_NFISCAL = RTRIM( SUBSTRING( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
EndIf

//FT_CLIEFOR
nQtdPipe := 4
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + _nTmSerie + _nTmNumDoc + 1 )
nTmCmp   := (_nTmCliFor) //06

If cBd $ "ORACLE|POSTGRES"
	cSql += " AND RTRIM(SFT.FT_CLIEFOR) = RTRIM( SUBSTR( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
Else //MSSQL,MYSQL,PROGRESS
	cSql += " AND SFT.FT_CLIEFOR = RTRIM( SUBSTRING( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
EndIf

//FT_LOJA
nQtdPipe := 5
nPosIni  := (nQtdPipe + _nTmIndOpe + _nTmDtes + _nTmSerie + _nTmNumDoc + _nTmCliFor + 1 )
nTmCmp   := (_nTmLoja) //02

If cBd $ "ORACLE|POSTGRES"
	cSql += " AND RTRIM(SFT.FT_LOJA) = RTRIM( SUBSTR( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
Else //MSSQL,MYSQL,PROGRESS
	cSql += " AND SFT.FT_LOJA = RTRIM( SUBSTRING( V5R.V5R_ERPKEY , " + cValToChar(nPosIni) + " , " + cValToChar(nTmCmp) + " ) ) "
EndIf

cSql += " AND SFT.D_E_L_E_T_ = ' ' "

cSql += " WHERE "
cSql += " V5R.V5R_FILIAL = '" + xFilial("V5R") + "' "

if !lManual .and. nRecnoV5R == 0 //chamada por job(TAFA573), apenas 1x por dia ja que apos reprocessamento V5R_DATA atualizara com data de hoje
	cSql += " AND V5R.V5R_DATA < '" + ::cDtV5R + "' "
elseIf nRecnoV5R > 0 //Se passou o RECNO, filtro pelo RECNO da V5R , caso seja true, nao devera filtrar data, pois vira do reprocessamento manual do mvc da v5r ( TAFA564 ) ou dos paineis
	cSql += " AND V5R.R_E_C_N_O_ = '" + cValToChar(nRecnoV5R) + "' "
elseIf !Alltrim(cBranch) == 'Todas' //reprocessa todos os documentos da filial selecionada no campo "Filial" no painel, caso seja selecionado "Todas", será reprocessado todas os docmentos.
	cSql += " AND V5R.V5R_CODFIL =  '" + cFilAnt + "' "	
endif

cSql += " AND V5R.V5R_ALIAS = 'C20' "
cSql += " AND V5R.D_E_L_E_T_ = ' ' "
cSql += " ) "

TAFConOut("TSILOG000023: Update dos registros na SFT que sofrerão alteração fake com base no log V5R alias C20 [ Início update TSILOG000023 ]", 1, .F., "TSI" )
TAFConOut("TSILOG000023: " + cSql, 1, .F., "TSI" )
TCCommit(1) // Inicia a Transação
nStatus := tcsqlexec( cSql )
TCCommit(2) // Realiza o commit
TCCommit(4) // Finaliza a Transação
if nStatus < 0
	TAFConOut("TSILOG000023: Erro de alteração fake [ Início erro TSILOG000023 ]" + TCSQLError() + " [ Fim erro TSILOG000023 ] ", 1, .F., "TSI" )
else
	::lExecSFT := .T.
endif

Return Nil 

 /*/{Protheus.doc} _ClearV5R
	(Método responsavel por limpar a V5R após o update fake )
	@author Renan Gomes
	@since 08/06/2022
	@return Nil, nulo, não tem retorno.
/*/
Method _ClearV5R(lManual, nRecnoV5R, cBranch) Class TSIV5RC20

Local cSql := ""

Default lManual   := .t.
Default nRecnoV5R := 0
Default cBranch	  := ''

TAFConOut("TSILOG000023: Update realizado, trigger executado com sucesso na tabela SFT.", 1, .F., "TSI" )

If ::lExecSFT .Or. ::lExecSF3
	cSql := " UPDATE " + RetSqlName("V5R") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE V5R_ALIAS = 'C20' AND D_E_L_E_T_ = ' ' "
	
	if !Alltrim(cBranch) == "Todas"
		cSql += " AND V5R_CODFIL = '" + cFilAnt + "'"
	endIf
	
	if !lManual .and. nRecnoV5R == 0 //caso seja true, nao devera filtrar data, pois vira do reprocessamento manual do mvc da v5r ( TAFA564 )
		cSql += " AND V5R_DATA < '" + ::cDtV5R + "' "
	elseIf nRecnoV5R > 0			 //Se tenho o RECNO, filtro ele na V5R
		cSql += " AND R_E_C_N_O_ = " + cValToChar(nRecnoV5R) + " "
	endif

	TCCommit(1) // Inicia a Transação

	iIf(TcSqlExec(cSql) < 0, TAFConOut("TSILOG000026: Erro ao excluir os registros da V5R [ Início erro TSILOG000026 ]" + TCSQLError() + " [ Fim erro TSILOG000026 ] ", 1, .F., "TSI" ), nil)

	TCCommit(2) // Realiza o commit
	TCCommit(4) // Finaliza a Transação
Endif
	
Return Nil
