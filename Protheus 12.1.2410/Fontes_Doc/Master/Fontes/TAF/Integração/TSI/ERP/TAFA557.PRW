#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := Nil
Static cUltStmp := Nil
 
Static lCompSAH := Nil
Static lCompC1J := Nil
Static lAliErp  := Nil
Static lCompar  := Nil
Static cStmpSAH := Nil

/*/{Protheus.doc} TSIUM
	(Classe que contém preparedstatament do T005 )
    @type Class
	@author Henrique Pereira / Denis Souza
    @author Carlos Eduardo
	@since 10/06/2020
	@return Nil, nulo, não tem retorno.
/*/ 

Class TSIUM

    Data TSITQRY     as String ReadOnly
    Data cFinalQuery as String ReadOnly
    Data oStatement  as Object ReadOnly
    Data cFilC1J     as String ReadOnly
    Data oJObjTSI    as Object

    Method New() Constructor 
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method FilC1J()

    Method GetQry()
    Method GetJsn()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSIUM )
    @author Carlos Eduardo
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
 
Method New(cSourceBr) Class TSIUM

If !FwIsInCallStack('RESTGETLISTSERVICE') 

    lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
    cUltStmp := iif(lNewCtrl, TsiUltStamp("C1J"),' ')
    lCompSAH := iif(Upper(AllTrim(FWModeAccess("SAH",1)+FWModeAccess("SAH",2)+FWModeAccess("SAH",3))) == 'CCC' ,.T.,.F.)
    lCompC1J := iif(Upper(AllTrim(FWModeAccess("C1J",1)+FWModeAccess("C1J",2)+FWModeAccess("C1J",3))) == 'CCC' ,.T.,.F.)
    lAliErp  := iif(lNewCtrl,V80->(FieldPos("V80_ALIERP") ) > 0,.F.)
    lCompar  := iif(lNewCtrl, (V80->(FieldPos("V80_COMPAR") ) > 0 .And. lCompSAH .And. lCompC1J ) ,.F.)
    cStmpSAH := iif(lAliErp,TsiUltStamp("C1J",/*2*/,'SAH',lAliErp,lCompar),cUltStmp)

    Self:FilC1J(cSourceBr)
    Self:LoadQuery()
    Self:PrepQuery()
    Self:JSon()

Endif
    
Return Nil

/*/{Protheus.doc} PrepQuery
    @author Carlos Eduardo
	(Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros )
    @type Class
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method PrepQuery() Class TSIUM
    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSITQRY) 
    self:oStatement:SetIn(1,self:cFilC1J)
    self:cFinalQuery := self:oStatement:GetFixQuery()
Return Nil

 /*/{Protheus.doc} PrepQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery() Class TSIUM
    Local cDbType  := Upper(Alltrim(TCGetDB()))
    Local cQuery   := " "
    Local cConvCPO := ""
   
    cQuery += " SELECT "
    cQuery += " SAH.AH_UNIMED UNIMED, " //2 - UNID
    cQuery += " SAH.AH_UMRES UMRES, " //3 - DESCR

    If cDbType $ "ORACLE"
        cConvCPO := "  cast( to_char(SAH.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    Elseif cDbType $ "POSTGRES"
        cConvCPO := "  cast( to_char(SAH.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    Else
        cConvCPO := " convert(varchar(23), SAH.S_T_A_M_P_ , 21 ) "
    Endif

    cQuery += cConvCPO + " STAMP "    

    cQuery += "  FROM " + RetSqlName("SAH") + " SAH "
    cQuery += "  LEFT JOIN " + RetSqlName("C1J") + " C1J "
    cQuery += "  ON C1J.C1J_FILIAL IN (?) "
    cQuery += "  AND C1J.C1J_CODIGO = SAH.AH_UNIMED "
    cQuery += "  AND C1J.D_E_L_E_T_ = ' ' "
    cQuery += "  WHERE SAH.AH_FILIAL = '" + xFilial( "SAH" ) + "' "
    cQuery += "  AND SAH.S_T_A_M_P_ IS NOT NULL "
    If cDbType $ "ORACLE"
        cQuery += "  AND ( (C1J.C1J_STAMP IS NULL OR Length(trim(C1J.C1J_STAMP)) = 0 OR Length(trim(C1J.C1J_STAMP)) IS NULL ) OR ( Length(trim(C1J.C1J_STAMP)) > 0 AND SAH.S_T_A_M_P_ > TO_TIMESTAMP(C1J.C1J_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') ) ) "
    else
        cQuery += "  AND (  C1J.C1J_STAMP IS NULL OR (" + cConvCPO + " > C1J.C1J_STAMP) ) "
    endif

    If cDbType $ "ORACLE"
        cQuery += "  AND SAH.S_T_A_M_P_ > to_timestamp('" + cStmpSAH + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += "  AND " + cConvCPO + " > '" + Alltrim(cStmpSAH) + "' "
    endif

    cQuery += "  AND SAH.D_E_L_E_T_ = ' ' "

    self:TSITQRY := cQuery

Return

 /*/{Protheus.doc} PrepQuery
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetQry() Class TSIUM
return self:cFinalQuery

 /*/{Protheus.doc} JSon
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method JSon() Class TSIUM

    Local cAlias    := getNextAlias( )
    Local nLen      := 0
    Local oJObjRet  := nil

    oJObjRet := JsonObject( ):New( )

    DbSelectArea( "C1J" )
    C1J->( DbSetOrder( 1 ) )
 
    dbUseArea( .T., "TOPCONN", TCGenQry( ,, self:GetQry( ) ), cAlias, .F., .T. )

    TAFConOut("TSILOG00006: Query de busca do cadastro de Unidade de Medida [ Início query TSILOG00002 " + TIME() + "  ]" + self:GetQry() + " [ Fim query TSILOG00002 " + TIME() + " ]") 

    oJObjRet['unitOfMeasureCode'] := { }

    While ( cAlias )->( !EOF( ) )

        aAdd( oJObjRet['unitOfMeasureCode'], JsonObject( ):New( ) )
        nLen++
                                                                                                    // Campos da Planilha Layout TAF - T005
        oJObjRet['unitOfMeasureCode'][nLen]["unitOfMeasureCode" ] := alltrim( ( cAlias )->UNIMED )  // 02 UNID
        oJObjRet['unitOfMeasureCode'][nLen]["description"       ] := alltrim( ( cAlias )->UMRES  )  // 03 DESCR
        oJObjRet['unitOfMeasureCode'][nLen]["stamp"             ] := ( cAlias )->STAMP

        ( cAlias )->( DBSKIP( ) )
    EndDo

    ( cAlias )->( DBCloseArea( ) )

    self:oJObjTSI := oJObjRet

Return

 /*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno. 
/*/
Method GetJsn () Class TSIUM

Return self:oJObjTSI

 /*/{Protheus.doc} TSIUM
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC1J(cSourceBr) Class TSIUM        
     self:cFilC1J := TafTSIFil(cSourceBr, 'C1J')      
Return
