#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("C1P"),' ')

/*/{Protheus.doc} TSICC
	( Classe que contém preparedstatament do T011 - CENTRO DE CUSTO )
    @type Class
	@author Henrique Pereira / Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Class TSICC

    Data TSIQRY      as String ReadOnly
    Data cFinalQuery as String ReadOnly
    Data oStatement  as Object ReadOnly
    Data oJObjTSI    as Object
    Data aFilC1P     as Array

    Method New() Constructor
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method FilCTT()

    Method GetQry()
    Method GetJsn()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSICC )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira / Carlos Eduardo
	@since 08/06/2020
	@retur
    n Nil, nulo, não tem retorno.
/*/
Method New(cSourceBr) Class TSICC

    Self:FilCTT(cSourceBr)
    Self:LoadQuery()
    Self:PrepQuery()
    Self:JSon()

Return Nil

/*/{Protheus.doc} PrepQuery
	(Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros )
    @type Class
	@author Henrique Pereira / Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method PrepQuery() Class TSICC

    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSIQRY)
    
    If !lNewCtrl .OR. Empty(cUltStmp)
        self:oStatement:SetIn(1,self:aFilC1P)
    EndIf
    
    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} PrepQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira / Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method LoadQuery() Class TSICC

Local cDbType  := Upper(Alltrim(TCGetDB()))
Local cQuery   := ""
Local cConvCpo := ""

cQuery := " SELECT "

If cDbType $ 'MSSQL/MSSQL7'
    cConvCpo := " convert(varchar(23), CTT.S_T_A_M_P_, 21) "
Elseif cDbType $ 'ORACLE'
    cConvCpo := " cast(to_char(CTT.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) "
Elseif cDbType $ "POSTGRES"
    cConvCpo := " cast(to_char(CTT.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
Endif
cQuery += cConvCpo + " CTT_STAMP, "
cQuery += " CTT.CTT_DTEXIS DT_ALT, "    //02 DT_ALT   Data da inclusão/alteração no ERP.
cQuery += " CTT.CTT_CUSTO COD_CCUS, "   //03 COD_CCUS Código do centro de custos.
cQuery += " CTT.CTT_DESC01 CTT_DESC01 " //04 CCUS     Nome do centro de custos.

cQuery += " FROM " + RetSqlName('CTT') + " CTT "

If !lNewCtrl .OR. Empty(cUltStmp)
    cQuery += " LEFT JOIN " + RetSqlName('C1P') + " C1P ON C1P.C1P_FILIAL IN (?) AND C1P.C1P_CODCUS = CTT.CTT_CUSTO AND C1P.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN " + RetSqlName('V5R') + " V5R ON V5R.V5R_FILIAL = '" + xFilial( "V5R" ) + "' AND V5R.V5R_CODFIL = '" + cFilAnt + "' AND V5R.V5R_ALIAS = 'C1P' "
    cQuery += " AND RTRIM( V5R.V5R_REGKEY ) = RTRIM( CTT.CTT_CUSTO ) AND V5R.D_E_L_E_T_ = ' ' " //Sem RTRIM o Oracle não entende que os conteudos são iguais por causa dos espaços do campo V5R_REGKEY.
EndIf

cQuery += " WHERE CTT.D_E_L_E_T_ = ' ' "
cQuery += " AND CTT.CTT_FILIAL = '" + xFilial("CTT") + "' "
cQuery += " AND CTT.CTT_BLOQ IN (' ','2') "

If !lNewCtrl .OR. Empty(cUltStmp)
    cQuery += " AND CTT.S_T_A_M_P_ IS NOT NULL "
    If cDbType $ "ORACLE"
        cQuery += " AND ( "
        cQuery += "         ( V5R.V5R_STAMP IS NOT NULL AND Length(trim(V5R.V5R_STAMP)) > 0 AND (CTT.S_T_A_M_P_ > TO_TIMESTAMP(V5R.V5R_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff'))) "
        cQuery += "     OR "
        cQuery += "     ( 
        cQuery += "         ( C1P.C1P_STAMP IS NULL OR Length(trim(C1P.C1P_STAMP)) = 0 OR Length(trim(C1P.C1P_STAMP)) IS NULL ) OR (Length(trim(C1P.C1P_STAMP)) > 0 AND (CTT.S_T_A_M_P_ > TO_TIMESTAMP(C1P.C1P_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff')))) "
        cQuery += " ) "   
    else
        cQuery += " AND ( (" + cConvCpo + " > C1P.C1P_STAMP) OR C1P.C1P_STAMP IS NULL ) "
        cQuery += " AND ( (" + cConvCpo + " > V5R.V5R_STAMP) OR V5R.V5R_STAMP IS NULL ) "
    endif
Else
    If cDbType $ "ORACLE"
        cQuery += " AND CTT.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += " AND " + cConvCpo + " > '" + Alltrim(cUltStmp) + "' "
    endif
Endif

self:TSIQRY := cQuery

Return Nil

 /*/{Protheus.doc} PrepQuery
	(Método responsável por retornar a propriedade cFinalQuery
	@author Henrique Pereira / Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetQry() Class TSICC
return self:cFinalQuery

 /*/{Protheus.doc} JSon
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira / Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method JSon( ) Class TSICC

    Local cAlias    := getNextAlias( )
    Local nLen      := 0
    Local oJObjRet  := nil
    Local cDataCTT  :=  ''

    oJObjRet := JsonObject( ):New( )
 
    DbSelectArea( "C1N" )
    C1N->( DbSetOrder( 1 ) )
 
    dbUseArea( .T., "TOPCONN", TCGenQry( ,, self:GetQry( ) ), cAlias, .F., .T. )

    TAFConOut(' TS1 LOG QRY Centro de Custo >>>>>>>>>>>>>>>>>>>> ' + self:GetQry( ) )

    oJObjRet['costCenter'] := { }

    While ( cAlias )->(!EOF( ) )

        cDataCTT := iif(Valtype((cAlias)->DT_ALT) == "D", DToC((cAlias)->DT_ALT), dToc(stod((cAlias)->DT_ALT)))

        aAdd( oJObjRet['costCenter'], JsonObject( ):New( ) )
        nLen++
        oJObjRet["costCenter"][nLen]["changeDate"   ] := cDataCTT             //02 DT_ALT   Data da inclusão/alteração no ERP.
        oJObjRet["costCenter"][nLen]["costCenterId" ] := (cAlias)->COD_CCUS   //03 COD_CCUS Código do centro de custos.
        oJObjRet["costCenter"][nLen]["description"  ] := (cAlias)->CTT_DESC01 //04 CCUS     Nome do centro de custos.
        oJObjRet["costCenter"][nLen]["criationDate" ] := cDataCTT             //02 DT_ALT   Data da inclusão/alteração no ERP.
        oJObjRet["costCenter"][nLen]["stamp"        ] := (cAlias)->CTT_STAMP

        ( cAlias )->(DBSKIP( ) )
    EndDo
    ( cAlias )->( DbCloseArea( ) )

    self:oJObjTSI := oJObjRet

Return Nil

 /*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira / Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetJsn () Class TSICC
Return self:oJObjTSI

/*/{Protheus.doc} FilCTT
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method FilCTT(cSourceBr) Class TSICC        
    self:aFilC1P := TafTSIFil(cSourceBr,'C1P')
Return
