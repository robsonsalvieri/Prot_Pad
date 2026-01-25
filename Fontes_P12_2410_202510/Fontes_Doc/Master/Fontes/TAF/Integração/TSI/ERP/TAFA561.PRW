#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := Nil
Static cUltStmp := Nil

static cTsiLayout := Nil

Static lCompSYD := Nil
Static lCompC0A := Nil
Static lAliErp  := Nil
Static lCompar  := Nil
Static cStmpSYD := Nil

/*/{Protheus.doc} TSINCM
	(Classe que contém preparedstatament do NCM )
    @type Class
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno.
/*/

Class TSINCM

    Data TSITQRY      as String ReadOnly
    Data cFinalQuery  as String ReadOnly
    Data oStatement   as Object ReadOnly
    Data cFilC0A      as String ReadOnly
    Data oJObjTSI     as Object

    Method New() Constructor
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method FilC0A()

    Method GetQry()
    Method GetJsn()

EndClass

/*/{Protheus.doc} New
	(Método construtor da classe TSINCM )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno.
/*/
 
Method New(cSourceBr) Class TSINCM

If !FwIsInCallStack('RESTGETLISTSERVICE')     

    lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
    cUltStmp := iif(lNewCtrl, TsiUltStamp("C0A"),' ')
    cTsiLayout := "commonMercosurNomenclature"
    lCompSYD := iif(Upper(AllTrim(FWModeAccess("SYD",1)+FWModeAccess("SYD",2)+FWModeAccess("SYD",3))) == 'CCC', .T.,.F.)
    lCompC0A := iif(Upper(AllTrim(FWModeAccess("C0A",1)+FWModeAccess("C0A",2)+FWModeAccess("C0A",3))) == 'CCC', .T.,.F.)
    lAliErp  := iif(lNewCtrl,V80->(FieldPos("V80_ALIERP") ) > 0,.F.)
    lCompar  := iif(lNewCtrl, (V80->(FieldPos("V80_COMPAR") ) > 0 .And. lCompSYD .And. lCompC0A) ,.F.)
    cStmpSYD := iif(lAliErp,TsiUltStamp("C0A",/*2*/,'SYD',lAliErp,lCompar),cUltStmp)

    Self:FilC0A(cSourceBr)
    Self:LoadQuery()
    Self:PrepQuery()
    Self:JSon()

Endif
    
Return Nil

/*/{Protheus.doc} PrepQuery
    @author Denis Souza
	(Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros )
    @type Class
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno.
/*/

Method PrepQuery() Class TSINCM

    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSITQRY)
    self:oStatement:SetIn(1,self:cFilC0A) //1
    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatement, por hora ainda com '?'
    nos parâmetros variáveis
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery() Class TSINCM

    Local cDbType  := Upper(Alltrim(TCGetDB()))
    Local cQuery   := " "
    Local cConvCpo := ""
    Local cConcat  := ""

    cQuery += " SELECT "
    cQuery += " SYD.YD_TEC "    //Código de NCM (Campo YD_TEC)
    cQuery += " ,SYD.YD_EX_NCM " //EX. NCM (YD_EX_NCM)
    cQuery += " ,SYD.YD_DESC_P " //Descrição (YD_DESC_P)

    If cDbType $ "MSSQL/MSSQL7" //STAMP
        cConvCpo := " convert(varchar(23), SYD.S_T_A_M_P_ , 21 ) "
        cConcat := "+"
    Elseif cDbType $ "ORACLE"
        cConvCpo := " cast( to_char(SYD.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
        cConcat := "||"
    Elseif cDbType $ "POSTGRES"
        cConvCpo := " cast( to_char(SYD.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
        cConcat := "||"
    Endif

    cQuery += " ," + cConvCpo + " STAMP "
    cQuery += " FROM " + RetSqlName("SYD") + " SYD " //ERP

    cQuery += " LEFT JOIN " + RetSqlName("C0A") + " C0A " //TAF
    cQuery += " ON C0A.C0A_FILIAL IN (?) "  //1
    cQuery += " AND C0A.C0A_CODIGO = SYD.YD_TEC "
    cQuery += " AND C0A.C0A_EXNCM = SYD.YD_EX_NCM "
    cQuery += " AND C0A.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName('V5R') + " V5R "
    cQuery += " ON V5R.V5R_FILIAL = '" + xFilial( "V5R" ) + "' "
    cQuery += " AND V5R.V5R_CODFIL = '" + cFilAnt + "' "
    cQuery += " AND V5R.V5R_ALIAS = 'C0A' "
    cQuery += " AND V5R.V5R_REGKEY = SYD.YD_TEC " + cConcat + " SYD.YD_EX_NCM " 
    cQuery += " AND V5R.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SYD.YD_FILIAL = '" + xFilial( "SYD" ) + "' "
    cQuery += " AND SYD.S_T_A_M_P_  IS NOT NULL "    
    If cDbType $ "ORACLE"
        cQuery += " AND ( "
        cQuery += "         ( V5R.V5R_STAMP IS NOT NULL AND Length(trim(V5R.V5R_STAMP)) > 0 AND (SYD.S_T_A_M_P_ > TO_TIMESTAMP(V5R.V5R_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff'))) "
        cQuery += "     OR "
        cQuery += "     ( 
        cQuery += "         ( C0A.C0A_STAMP IS NULL OR Length(trim(C0A.C0A_STAMP)) = 0 OR Length(trim(C0A.C0A_STAMP)) IS NULL ) OR (Length(trim(C0A.C0A_STAMP)) > 0 AND (SYD.S_T_A_M_P_ > TO_TIMESTAMP(C0A.C0A_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff')))) "
        cQuery += " ) "
    else
        cQuery += " AND (( " + cConvCpo + " > C0A.C0A_STAMP ) OR C0A.C0A_STAMP IS NULL ) "
        cQuery += " AND (( " + cConvCpo + " > V5R.V5R_STAMP ) OR V5R.V5R_STAMP IS NULL ) " 
    Endif
    If cDbType $ "ORACLE" 
        cQuery += " AND SYD.S_T_A_M_P_ > to_timestamp('" + cStmpSYD + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += " AND " + cConvCpo + " > '" + Alltrim(cStmpSYD) + "' "
    endif
    cQuery += " AND SYD.D_E_L_E_T_ = ' ' "

    self:TSITQRY := cQuery

Return

 /*/{Protheus.doc} GetQry
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetQry() Class TSINCM
return self:cFinalQuery

 /*/{Protheus.doc} JSon
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno.
/*/

Method JSon() Class TSINCM

    Local cAlias    := getNextAlias()
    Local nLen      := 0
    Local oJObjRet  := nil
    Local cRelIdC0A := GetSx3Cache("C0A_ID","X3_RELACAO")
    Local lIdC0AErr := '("C0A","C0A_ID")' $ UPPER(cRelIdC0A) //Se inic. padrão não tiver passando o indice 3, retorno o max _ID

    oJObjRet := JsonObject():New()

    DbSelectArea('C0A')
    C0A->(DbSetOrder(1)) //C0A_FILIAL, C0A_CODIGO, C0A_EXNCM, C0A_VALIDA, R_E_C_N_O_, D_E_L_E_T_
 
    dbUseArea(.T., "TOPCONN", TCGenQry(, , self:GetQry()), cAlias, .F., .T.)
    (cAlias)->(DbGoTop())

    TAFConOut("TSILOG000012: Query de busca do cadastro de NCM [ Início query TSILOG000012 " + TIME() + " ]"  + self:GetQry() + "[ Fim query TSILOG000012 " + TIME() + "  ] ")  

    oJObjRet[cTsiLayout] := {}

    While (cAlias)->(!EOF())

        aAdd( oJObjRet[cTsiLayout],JsonObject():New())
        nLen++
        
        //Busco ID manualmente apenas se Inic. Padrão estiver errado 
        If lIdC0AErr
            oJObjRet[cTsiLayout][nLen]["id"]    :=  GetSx8Num("C0A","C0A_ID",,3)   
            C0A->( ConfirmSX8() )        
        Endif

        oJObjRet[cTsiLayout][nLen]["commonExternalTariff"] := Alltrim((cAlias)->YD_TEC)
        oJObjRet[cTsiLayout][nLen]["exceptionNcm"]         := Alltrim((cAlias)->YD_EX_NCM)
        oJObjRet[cTsiLayout][nLen]["description"]          := Alltrim((cAlias)->YD_DESC_P)
        oJObjRet[cTsiLayout][nLen]["stamp"]                := (cAlias)->STAMP
        (cAlias)->(DBSKIP())
    EndDo

    ( cAlias )->( DbCloseArea( ) )

    self:oJObjTSI := oJObjRet

Return

 /*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno. 
/*/
Method GetJsn () Class TSINCM

Return self:oJObjTSI

 /*/{Protheus.doc} TSINCM
	(Método responsável por montar o conteúdo da filial da C0A
	@author Denis Souza
	@since 05/11/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC0A(cSourceBr) Class TSINCM        
     self:cFilC0A := TafTSIFil(cSourceBr, 'C0A')      
Return
