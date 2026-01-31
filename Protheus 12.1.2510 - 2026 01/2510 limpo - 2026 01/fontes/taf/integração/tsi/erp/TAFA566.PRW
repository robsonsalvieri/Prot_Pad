#include 'totvs.ch'
#include 'topconn.ch'
#include 'restful.ch'
#include 'fwmvcdef.ch'

STATIC lNewCtrl   := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
STATIC cUltStmp   := iif(lNewCtrl, TsiUltStamp("C5M"),' ')
STATIC lExisF2S   := AliasIndic('F2S')

/*/-------------------------------------------------------------
{Protheus.doc}TSICPRB
(Classe principal para integração de CPRB)
@author Carlos Eduardo
@since 22/09/2021
-------------------------------------------------------------/*/
Class TSICPRB

Data oJObjTSI as Object
Data nTotReg  as numeric //Total de registros da query

Method New() Constructor
Method LoadQuery()
Method JSon()
Method GetJsn()
Method QryT082AC()
Method QryT082AD()

EndClass

/*---------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} New
(Método contrutor da classe TSICPRB )
Fluxo New:
Monta o JSon com os dados da CPRB
@author Carlos Eduardo
@since 22/09/2021
@return Nil, nulo, não tem retorno.
----------------------------------------------------------------------------------------------------------------------------*/
Method New(cSourceBr) Class TSICPRB

Self:LoadQuery(cSourceBr)

Return Nil

 /*-----------------------------------------------------------------------------------
{Protheus.doc} LoadQuery
(Método responsável por montar a query de consulta a tabela de CPRB
@author Carlos Eduardo
@since 22/09/2021
@return Nil, nulo, não tem retorno.
-------------------------------------------------------------------------------------*/

Method LoadQuery(cSourceBr) Class TSICPRB

Local cDbType  := Upper(Alltrim(TCGetDB()))
Local lRet     := .t.
Local cQuery   := ''
Local aFilTaf  := TafTSIFil(cSourceBr,'C5M')
Local cFilTaf  := ''
Local nLenFil  := len(aFilTaf)
Local cAlias   := GetNextAlias()
Local nI       := 0
Local cConvCpo := ''

If nLenFil == 0
    // Caso não exista filial na C1E para o grupo selecionado no JOB adiciono "' '" para que a query não quebre no IN da Filial no WHERE.
    cFilTaf := "''"
Else    
    //Monta a string com as filiais para somar á query
    for nI := 1 to nLenFil
        cFilTaf += "'" + aFilTaf[nI] + "'"
        if nI < nLenFil; cFilTaf += ','; endif
    next
Endif

//Converte o conteúdo do campo conforme o banco de dados usado.
If cDbType $ 'MSSQL/MSSQL7'
    cConvCpo := " convert(varchar(23), CKX.S_T_A_M_P_, 21) "
Elseif cDbType $ 'ORACLE'
    cConvCpo := " cast(to_char(CKX.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) "
Elseif cDbType $ 'POSTGRES'
    cConvCpo := " cast(CKX.S_T_A_M_P_ AS VARCHAR(23)) "
Endif

//Monto a query que servirá como base para integração.
cQuery := " SELECT DISTINCT "
cQuery += "     CKX.CKX_PER,     "
cQuery += "     CKX.CKX_VLBRUT , "
cQuery += "     CKX.CKX_CODATI , "
cQuery += "     CKX.CKX_VLATI  , "
cQuery += "     CKX.CKX_EXCLU  , "
cQuery += "     CKX.CKX_BASE   , "
cQuery += "     CKX.CKX_ALIQ   , "
cQuery += "     CKX.CKX_VLCPRB , "
cQuery += "     CKX.CKX_CONTA  , "
cQuery += "     CKX.CKX_INFORM , "
cQuery += cConvCpo + ' CKX_STAMP'
cQuery += " FROM " + RetSqlName('CKX') + " CKX "

If !lNewCtrl .OR. Empty(cUltStmp)
    cQuery += " LEFT JOIN " + RetSqlName('C5M') + " C5M ON C5M.C5M_FILIAL = CKX.CKX_FILIAL "
    If cDbType $ "ORACLE|POSTGRES|DB2"
        cQuery += " AND SUBSTR(C5M.C5M_DTINI,1,6) = SUBSTR(CKX.CKX_PER,1,6) "
    ElseIf cDbType $ "INFORMIX"
        cQuery += " AND C5M.C5M_DTINI[1,6] = CKX.CKX_PER[1,6] "
    ElseIf cDbType $ "MSSQL/MSSQL7"
        cQuery += " AND SUBSTRING(C5M.C5M_DTINI,1,6) = SUBSTRING(CKX.CKX_PER,1,6) "
    EndIf
    cQuery += "     AND C5M.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " WHERE CKX.D_E_L_E_T_ = ' ' "
cQuery += " 	AND CKX.CKX_FILIAL IN (" + cFilTaf + ") "
cQuery += " 	AND CKX.CKX_SALDO != '1' "

If !lNewCtrl .OR. Empty(cUltStmp)
    cQuery += "     AND CKX.S_T_A_M_P_ IS NOT NULL "
    If cDbType $ "ORACLE"
        cQuery += "     AND ( (C5M.C5M_STAMP IS NULL OR Length(trim(C5M.C5M_STAMP)) = 0 OR Length(trim(C5M.C5M_STAMP)) IS NULL ) OR (Length(trim(C5M.C5M_STAMP)) > 0 AND CKX.S_T_A_M_P_ > TO_TIMESTAMP(C5M.C5M_STAMP,'dd.mm.yyyy hh24:mi:ss.ff')) ) "
    else
        cQuery += "     AND (( " + cConvCpo + " > C5M.C5M_STAMP) OR C5M.C5M_STAMP IS NULL ) "
    endif
Else
    If cDbType $ "ORACLE"
        cQuery += " AND CKX.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += " AND " + cConvCpo + " > '" + Alltrim(cUltStmp) + "' "
    endif
Endif

//Proteção abaixo é necessário caso o TAFA573 esteja extraindo CPRB sem que exista o campo S_T_A_M_P_ na tabela CKX
If ExistStamp(,,"CKX")
    cQuery := ChangeQuery(cQuery) 
    DbUseArea(.t., 'topconn', TCGenQry(, , cQuery), cAlias, .f., .t. )
	Count to self:nTotReg
	(cAlias)->(dbGoTop())

    TAFConOut("TSILOG000019: Query de busca do cadastro de CPRB [ Início query TSILOG000019 " + TIME() + "  ]" + cQuery + " [ Fim query TSILOG000019 " + TIME() + " ]") 

    //Crio o JSon
    Self:JSon(cAlias)
    (cAlias)->(DbCloseArea())
Else
    TAFConOut("TSILOG000019: Tabela CKX sem campo S_T_A_M_P_. Extracao cancelada. " + TIME() ) 
    Self:JSon()
EndIf

Return lRet


/*/----------------------------------------------------------------------------
{Protheus.doc}JSon
(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI)
@author Carlos Eduardo
@since 22/09/2021
-----------------------------------------------------------------------------/*/
Method JSon(cAlias) Class TSICPRB
Local lRet := .t.
Local nPos := 0
Local oJson := JsonObject():New()
Local dDataDe := Date()
Local dDataAte := Date()
Local oJAjuste := Nil
Local oJObjCNO := Nil
Local aAjuste  := { }
Local aCnoCPRB := { }
Local cAliasF2S := ""
Local cAliasF3Z := ""

Default cAlias := ' '

//Inicia o Json como array
oJson['socialSecurityContribution'] := {}

//Proteção abaixo é necessário caso o TAFA573 esteja extraindo CPRB sem que exista o campo S_T_A_M_P_ na tabela CKX
If ExistStamp(,,"CKX")

    //Grava o Json caso exista apuração da CPRB
    while (cAlias)->(!eof())
        aAdd( oJson['socialSecurityContribution'],JsonObject():New())                                 
        nPos++

        dDataDe  := FirstDate(Stod((cAlias)->CKX_PER))
        dDataAte := LastDate(Stod((cAlias)->CKX_PER))
        oJson['socialSecurityContribution'][nPos]['startDate'                     ] := dDataDe                            //DT_INI
        oJson['socialSecurityContribution'][nPos]['endDate'                       ] := dDataAte                           //DT_FIN
        oJson['socialSecurityContribution'][nPos]['totalValue'                    ] := (cAlias)->CKX_VLBRUT               //VL_REC_TOT_EST
        oJson['socialSecurityContribution'][nPos]['activityCode'                  ] := (cAlias)->CKX_CODATI               //COD_ATIV_ECON
        oJson['socialSecurityContribution'][nPos]['grossIncome'                   ] := (cAlias)->CKX_VLATI                //VL_REC_ATIV_ESTAB 
        oJson['socialSecurityContribution'][nPos]['exclusionValue'                ] := (cAlias)->CKX_EXCLU                //VL_EXC
        oJson['socialSecurityContribution'][nPos]['baseValue'                     ] := (cAlias)->CKX_BASE                 //VL_BC_CONT
        oJson['socialSecurityContribution'][nPos]['contributionRate'              ] := (cAlias)->CKX_ALIQ                 //ALIQ_CONT
        oJson['socialSecurityContribution'][nPos]['contributionValue'             ] := (cAlias)->CKX_VLCPRB               //VL_CONT_APU
        oJson['socialSecurityContribution'][nPos]['accountCode'                   ] := (cAlias)->CKX_CONTA                //COD_CTA
        oJson['socialSecurityContribution'][nPos]['complementInformation'         ] := (cAlias)->CKX_INFORM               //INFO_COMPL 
        oJson['socialSecurityContribution'][nPos]['suspensionSocialContribution'  ] := 0                                  //VLRSUSPCPRB
        oJson['socialSecurityContribution'][nPos]['stamp'                         ] := (cAlias)->CKX_STAMP                //STAMP

		// Montagem do Json do T082AC
        aAjuste := { }
        if nPos == self:nTotReg
            cAliasF2S := Self:QryT082AC( dDataDe, dDataAte )
            Do While (cAliasF2S)->( !Eof() )
                oJAjuste := JsonObject( ):New( )
                oJAjuste["adjustmentType"       ] := (cAliasF2S)->F2S_TPAJUS            //TPAJUSTE 
                oJAjuste["adjustmentCode"       ] := (cAliasF2S)->F2S_CODAJU            //CODAJUSTE
                oJAjuste["adjustmentValue"      ] := (cAliasF2S)->F2S_VLRAJU            //VLRAJUSTE
                oJAjuste["adjustmentDescription"] := Alltrim((cAliasF2S)->F2S_DESCRI)   //DESCAJUSTE
                oJAjuste["adjustmentDate"       ] := substr( (cAliasF2S)->F2S_PER,5,2) + substr( (cAliasF2S)->F2S_PER,1,4)  //DTAJUSTE
                //Adiciono objeto filho T082AC dentro do array
			    aAdd( aAjuste, oJAjuste )                
                (cAliasF2S)->(DbSkip())
            enddo
            (cAliasF2S)->(DBCloseArea())  
        endif
        //Atualiza objeto T082 com array de json com os tipos de ajuste T082AC
		oJson['socialSecurityContribution'][nPos]['adjustment'] := aAjuste      

        // Montagem do Json do T082AD
        aCnoCPRB := { }

        cAliasF3Z := Self:QryT082AD(dDataDe, dDataAte, (cAlias)->CKX_CODATI, (cAlias)->CKX_CONTA )
        Do While (cAliasF3Z)->( !Eof() )

            oJObjCNO := JsonObject( ):New( )
            oJObjCNO["grossValue"    ] := (cAliasF3Z)->F3Z_VLBRUT  //VL_REC_ATIV_ESTAB 
            oJObjCNO["deletionValue" ] := (cAliasF3Z)->F3Z_EXCLU   //VL_EXC
            oJObjCNO["baseValue"     ] := (cAliasF3Z)->F3Z_BASE    //VL_BC_CONT
            oJObjCNO["accountingRate"] := (cAliasF3Z)->F3Z_ALIQ    //ALIQ_CONT
            oJObjCNO["cprbValue"     ] := (cAliasF3Z)->F3Z_VLCPRB  //VL_CONT_APU
            oJObjCNO["accountCode"   ] := (cAliasF3Z)->F3Z_CONTA   //COD_CTA 
            oJObjCNO["cnoNumber"     ] := (cAliasF3Z)->F3Z_CNO     //CNO

            //Adiciono objeto filho T082AD dentro do array
			aAdd( aCnoCPRB, oJObjCNO )
	        (cAliasF3Z)->(DbSkip ())

        EndDo

        (cAliasF3Z)->( DBCloseArea() )
        //Atualizo objeto T082 com array de json dos CNOs T082AD
		oJson['socialSecurityContribution'][nPos]['cnoSocialSecurityContribution'] := aCnoCPRB        
        
        (cAlias)->(DbSkip())

    enddo

Endif

//Grava JSon no Atributo oJObjTSI
self:oJObjTSI := oJson

return lRet

/*-------------------------------------------------------
{Protheus.doc} GetJsn
(Método responsável retornar a propriedade self:oJObjTSI
@author Carlos Eduardo
@since 22/09/2021
@return Nil, nulo, não tem retorno.
--------------------------------------------------------*/
Method GetJsn() Class TSICPRB
Return self:oJObjTSI

//-------------------------------------------------------------------
/*/{Protheus.doc} QryT082AC()
@description Query para identificar os registros T082AC filhos do
T082.
@author Denis / Matos
@since 09/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Method QryT082AC( dDataDe, dDataAte ) Class TSICPRB

Local cAliasF2S	:= ''
Local cCampos	:= ''
Local cFiltro	:= ''

Default dDataDe := FirstDate(Stod(dDataBase))
Default dDataAte := LastDate(Stod(dDataBase))

If lExisF2S
	cCampos	:= '%F2S.F2S_TPAJUS, F2S.F2S_CODAJU	, F2S.F2S_VLRAJU, F2S.F2S_DESCRI, F2S.F2S_PER%'
                     
	cFiltro	:= "%"
	cFiltro	+= "F2S.F2S_FILIAL= '"+ xFilial('F2S')+ "' AND "
	cFiltro	+= "F2S.F2S_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
	cFiltro	+= "F2S.F2S_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
	cFiltro	+= "F2S.F2S_TRIBUT = '2' AND "
	cFiltro	+= "F2S.F2S_TPAJUS = '0' AND "
	cFiltro	+= "%"

	cAliasF2S := GetNextAlias()
    BeginSql Alias cAliasF2S
		SELECT %Exp:cCampos% FROM %Table:F2S% F2S WHERE %Exp:cFiltro% F2S.%NotDel%
	EndSql
EndIf

Return cAliasF2S

//-------------------------------------------------------------------
/*/{Protheus.doc} QryT082AD()
@description Query para identificar os registros T082AD filhos do
T082.
@author Karen / Jose Felipe
@since 06/01/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method QryT082AD(dDataDe, dDataAte,cCodAti,cConta) Class TSICPRB
Local cCampos as character
Local cFiltro as character
Local cAliasF3Z as character

Default dDataDe := FirstDate(Stod(dDataBase))
Default dDataAte := LastDate(Stod(dDataBase))
Default cCodAti := ''
Default cConta  := '' 

cAliasF3Z := GetNextAlias()

cCampos	:= '%F3Z.F3Z_VLBRUT, F3Z.F3Z_CODATI, F3Z.F3Z_VLATI, F3Z.F3Z_EXCLU, F3Z.F3Z_BASE'
cCampos	+= ', F3Z.F3Z_ALIQ, F3Z.F3Z_VLCPRB, F3Z.F3Z_CONTA, F3Z.F3Z_CNO%'

cFiltro 	:= "%"
cFiltro 	+= "F3Z.F3Z_FILIAL= '"+ xFilial('F3Z')+ "' AND "
cFiltro 	+= "F3Z.F3Z_PER>= '" + %Exp:DToS(dDataDe)% + "' AND "
cFiltro 	+= "F3Z.F3Z_PER<= '" + %Exp:DToS(dDataAte)% + "' AND "
cFiltro 	+= "F3Z.F3Z_SALDO <> '1' AND "
cFiltro 	+= "F3Z.F3Z_CODATI = '" + %Exp:cCodAti% + "' AND "
cFiltro		+= "F3Z.F3Z_CONTA = '" + %Exp:cConta% + "' AND " 
cFiltro 	+= "%"

BeginSql Alias cAliasF3Z

	SELECT
	%Exp:cCampos%
	FROM
	%Table:F3Z% F3Z
	WHERE
	%Exp:cFiltro%
	F3Z.%NotDel%

EndSql

Return cAliasF3Z
