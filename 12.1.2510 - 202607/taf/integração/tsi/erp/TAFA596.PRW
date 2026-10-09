#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := Nil
Static cUltStmp := Nil

static cTsiLayout := Nil
Static nTamDescr  := Nil

Static lT9CCodART := Nil
Static lSONCodART := Nil

/*/{Protheus.doc} TSICNO
	(Classe que contem preparedstatament do CNO )
    @type Class
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno.
/*/ 
Class TSICNO

    Data cFinalQuery //as String ReadOnly
    Data oStatement  //as Object ReadOnly
    Data cFilT9C     //as String ReadOnly
    Data oJObjTSI    //as Object

    Method New() Constructor
    Method LoadQuery()
    Method JSon()
    Method FilT9C()
    Method GetJsn()

EndClass


/*/{Protheus.doc} New
	(Metodo construtor da classe TSICNO )
    Fluxo New:
    1 Monta-se a query com LoadQuery()
    2 Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final ja com os parametros
	@type Class
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, nao tem retorno.
/*/
Method New(cSourceBr) Class TSICNO

If !FwIsInCallStack('RESTGETLISTSERVICE')

    lNewCtrl   := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
    cUltStmp   := iif(lNewCtrl, TsiUltStamp("T9C"),' ')
    cTsiLayout := "WorkNationalFile"
    nTamDescr  := GetSx3Cache("T9C_DSCOBR","X3_TAMANHO")
    lT9CCodART := T9C->(FieldPos("T9C_CODART")) > 0
    lSONCodART := SON->(FieldPos("ON_CODART")) > 0

    Self:FilT9C(cSourceBr)
    Self:LoadQuery()
    Self:JSon()

Endif

Return Nil

 /*/{Protheus.doc} LoadQuery
	(Metodo responsavel por montar a query para o preparedstatement, por hora ainda com '?'
    nos parametros variaveis
    
    SON_TPINSCR  -- > T9C_TPINSC
    SON_CNO      -- > T9C_NRINSC
    SON_DESC     -- > T9C_DSCOBR
    SON_IDOBRA   -- > T9C_INDOBR
    SON_INDCPRB  -- > T9C_CPRB

	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, nao tem retorno.
/*/
Method LoadQuery() Class TSICNO

    Local cDbType  := Upper(Alltrim(TCGetDB()))
    Local cQuery   := " "
    Local cConvCpo := " "
    Local aBind    := {}

    cQuery += "SELECT "
    cQuery += "SON.ON_TPINSCR "   // Tipo de Inscricao ( CNPJ ou CNO )
    cQuery += ",SON.ON_CNO "      // Numero do Registro ( CNPJ ou CNO )
    cQuery += ",SON.ON_DESC "     // Descricao da Obra 
    cQuery += ",SON.ON_IDOBRA "   // Indicativo de Prestacao de Serviço
    cQuery += ",SON.ON_INDCPRB "  // Contribuicao Previdenciaria 
    cQuery += ",SON.ON_TPOBRA "   // Tipo de Obra
    if lSONCodART
        cQuery += ",SON.ON_CODART " // codigo art
    endif
    If cDbType $ "MSSQL/MSSQL7" //STAMP
        cConvCpo := " convert(varchar(23), SON.S_T_A_M_P_ , 21 ) "
    Elseif cDbType $ "ORACLE"
        cConvCpo += " cast( to_char(SON.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    Elseif cDbType $ "POSTGRES"
        cConvCpo += " cast( to_char(SON.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    Endif

    cQuery += "," + cConvCpo + " STAMP "

    cQuery += " FROM " + RetSqlName("SON") + " SON " //ERP

    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += " LEFT JOIN " + RetSqlName("T9C") + " T9C ON " //TAF T9C_FILIAL, T9C_TPINSC, T9C_NRINSC, R_E_C_N_O_, D_E_L_E_T_
        cQuery += " T9C.T9C_FILIAL IN (?) "
        cQuery += " AND T9C_TPINSC = SON.ON_TPINSCR "
        cQuery += " AND T9C_NRINSC = SON.ON_CNO "
        cQuery += " AND T9C.D_E_L_E_T_ = ? "
        aadd( aBind, { self:cFilT9C, .F. } )
        aadd( aBind, { space(1)	   , .F. } )
    EndIf

    cQuery += " WHERE SON.ON_FILIAL = ? "
    aadd( aBind, { xFilial("SON"), .F. } )

    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += " AND SON.S_T_A_M_P_  IS NOT NULL "
        If cDbType $ "ORACLE"
            cQuery += " AND ((T9C.T9C_STAMP IS NULL "
            cQuery += " OR Length(trim(T9C.T9C_STAMP)) = ? "
            cQuery += " OR Length(trim(T9C.T9C_STAMP)) IS NULL) "
            cQuery += " OR ( Length(trim(T9C.T9C_STAMP)) > ? "
            cQuery += " AND SON.S_T_A_M_P_ > TO_TIMESTAMP(T9C.T9C_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') ) )"
	        aadd( aBind, { 0, .F. } )
    	    aadd( aBind, { 0, .F. } )
        else
            cQuery += " AND (( " + cConvCpo + " > T9C.T9C_STAMP) OR T9C.T9C_STAMP IS NULL ) "
        endif
    Else
        If cDbType $ "ORACLE"
            cQuery += " AND SON.S_T_A_M_P_ > to_timestamp(?,'dd.mm.yyyy hh24:mi:ss.ff') "
            aadd( aBind, { cUltStmp , .F. } )
        else
            cQuery += " AND " + cConvCpo + "> ? "
            aadd( aBind, { Alltrim(cUltStmp) , .F. } )
        endif
    Endif

    cQuery += " AND SON.D_E_L_E_T_ = ? "
    aadd( aBind, { space(1)		 , .F. } )

    self:oStatement := FwExecStatement():New( cQuery )
    TafSetPrepare(self:oStatement,@aBind)
    self:cFinalQuery := self:oStatement:GetFixQuery()

Return

 /*/{Protheus.doc} JSon
	(Metodo responsavel montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, nao tem retorno.
/*/
Method JSon() Class TSICNO

    Local cAlias    := ''
    Local nLen      := 0
    Local oJObjRet  := nil

    If ExistStamp(,,"SON")

        cAlias := getNextAlias()

        oJObjRet := JsonObject():New()
        oJObjRet[cTsiLayout] := {}

        DbSelectArea('T9C')
        T9C->(DbSetOrder(1))

        self:oStatement:OpenAlias( cAlias )

        TAFConOut("TSILOG000020: Query de busca do cadastro de CNO - Obras [ Inicio query TSILOG000020 " + TIME() + " ]"  + self:cFinalQuery + "[ Fim query TSILOG000020 " + TIME() + "  ] ")  

        While (cAlias)->(!EOF())
            aAdd( oJObjRet[cTsiLayout],JsonObject():New())
            nLen++
            oJObjRet[cTsiLayout][nLen]["registrationType"]      := Alltrim((cAlias)->ON_TPINSCR)  
            oJObjRet[cTsiLayout][nLen]["cnoNumber"]             := Alltrim((cAlias)->ON_CNO)      
            oJObjRet[cTsiLayout][nLen]["description"]           := Substr(Alltrim((cAlias)->ON_DESC), 1, nTamDescr)
            oJObjRet[cTsiLayout][nLen]["workIdentification"]    := Alltrim((cAlias)->ON_IDOBRA)   
            oJObjRet[cTsiLayout][nLen]["cprbPayer"]             := Alltrim((cAlias)->ON_INDCPRB)
            oJObjRet[cTsiLayout][nLen]["thirdPartyCallsign"]    := IIf(Alltrim((cAlias)->ON_TPOBRA)=='2','1','2')
            oJObjRet[cTsiLayout][nLen]["stamp"]                 := (cAlias)->STAMP
            if lT9CCodART .And. lSONCodART
                oJObjRet[cTsiLayout][nLen]["artCode"]           := Alltrim((cAlias)->ON_CODART)
            endif
            (cAlias)->(DBSKIP())
        EndDo
        ( cAlias )->( DbCloseArea( ) )
    Endif
    self:oJObjTSI := oJObjRet

    if self:oStatement != Nil
        freeobj(self:oStatement)
        self:oStatement := Nil
    endif
Return

 /*/{Protheus.doc} GetJsn
	(Metodo responsavel retornar a propriedade self:oJObjTSI
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, nao tem retorno. 
/*/
Method GetJsn() Class TSICNO

Return self:oJObjTSI


 /*/{Protheus.doc} TSICNO
	(Metodo responsavel por montar o conteudo da filial da T9C
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, nao tem retorno.
/*/
Method FilT9C(cSourceBr) Class TSICNO        
     self:cFilT9C := TafTSIFil(cSourceBr, 'T9C')      
Return
