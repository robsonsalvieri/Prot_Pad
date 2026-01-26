#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := Nil
Static cUltStmp := Nil
Static lCompSF4 := Nil
Static lCompC1N := Nil
Static lAliErp  := Nil
Static lCompar  := Nil
Static cStmpSF4 := Nil
Static cDbType  := Nil

/*/{Protheus.doc} TSINATOPE
	( Classe que contém preparedstatament do T009 Natureza(TES) )
    @type Class
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, nao tem retorno.
/*/
Class TSINATOPE

    Data cFinalQuery as String ReadOnly
    Data oStatement  as Object ReadOnly
    Data oJObjTSI    as Object
    Data aFilC1N     as Array

    Method New() Constructor
    Method LoadQuery()
    Method JSon()
    Method FilC1N()
    Method GetJsn()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSINATOPE )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com loadquery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method New(cSourceBr, cTable) Class TSINATOPE

If !FwIsInCallStack('RESTGETLISTSERVICE') 
    cDbType  := Upper(Alltrim(TCGetDB()))
    lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
    cUltStmp := iif(lNewCtrl, TsiUltStamp("C1N"),' ')
    lCompSF4 := iif(Upper(AllTrim(FWModeAccess("SF4",1)+FWModeAccess("SF4",2)+FWModeAccess("SF4",3))) == 'CCC', .T.,.F.)
    lCompC1N := iif(Upper(AllTrim(FWModeAccess("C1N",1)+FWModeAccess("C1N",2)+FWModeAccess("C1N",3))) == 'CCC', .T.,.F.)
    lAliErp  := iif(lNewCtrl,V80->(FieldPos("V80_ALIERP") ) > 0,.F.)
    lCompar  := iif(lNewCtrl, (V80->(FieldPos("V80_COMPAR") ) > 0 .And. lCompSF4, lCompC1N ) ,.F.)
    cStmpSF4 := iif(lAliErp,TsiUltStamp("C1N",/*2*/,'SF4',lAliErp,lCompar),cUltStmp)
    Self:FilC1N(cSourceBr)
    Self:LoadQuery(cTable)
    Self:JSon()
Endif

Return Nil

/*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method LoadQuery(cTable) Class TSINATOPE

    Local cQuery    := " "
    Local cVarConv  := " "
    Local aBind     := {}

    If cDbType $ 'MSSQL/MSSQL7' //STAMP
        cVarConv := " convert(varchar(23), SF4.S_T_A_M_P_ , 21 ) "
    Elseif cDbType $ 'ORACLE'
        cVarConv := " cast( to_char(SF4.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    Elseif cDbType $ 'POSTGRES'
        cVarConv := " cast( to_char(SF4.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    Endif
	//Campo ja existente nao sera necessario protecao F4_ISSST
    cQuery += " SELECT DISTINCT SF4.F4_CODIGO CODIGO, SF4.F4_TEXTO DESCR, SF4.F4_ISSST F4_ISSST "
    cQuery += ", " + cVarConv + " STAMP "
    cQuery += " FROM " + RetSqlName("SF4") + " SF4 "

    cQuery += "INNER JOIN " 
    cQuery += "(SELECT DISTINCT SFT.FT_TES TES, SFT.FT_FILIAL FILIAL "
    cQuery += "FROM " + cTable + " SFT ) SFTTEMP "
    cQuery += "ON SFTTEMP.FILIAL = ? "
    cQuery += "AND SFTTEMP.TES = SF4.F4_CODIGO "
    aadd( aBind, { xFilial("SFT"), .F. } )

    cQuery += " LEFT JOIN " + RetSqlName("C1N") + " C1N ON " // C1N_FILIAL, C1N_CODNAT, R_E_C_N_O_, D_E_L_E_T_ // C1N_FILIAL, C1N_DESNAT, R_E_C_N_O_, D_E_L_E_T_
    cQuery += " C1N.C1N_FILIAL = ? "
    cQuery += " AND C1N.C1N_CODNAT = SF4.F4_CODIGO "
    cQuery += " AND C1N.C1N_DESNAT = SF4.F4_TEXTO "
    cQuery += " AND C1N.D_E_L_E_T_ = ? "
	aadd( aBind, { self:aFilC1N , .F. } )
	aadd( aBind, { space(1)		, .F. } )

    cQuery += " WHERE SF4.F4_FILIAL = ? "
    cQuery += " AND (SF4.S_T_A_M_P_ IS NULL "
	aadd( aBind, { xFilial("SF4"), .F. } )

    If cDbType $ "ORACLE"
        cQuery += " OR ( (C1N.C1N_STAMP IS NULL OR Length(trim(C1N.C1N_STAMP)) = ? OR Length(trim(C1N.C1N_STAMP)) IS NULL ) "
        cQuery += " OR (Length(trim(C1N.C1N_STAMP)) > ? AND SF4.S_T_A_M_P_ > TO_TIMESTAMP(C1N.C1N_STAMP,'dd.mm.yyyy hh24:mi:ss.ff')) ) "
        cQuery += " OR SF4.S_T_A_M_P_ > to_timestamp(?,'dd.mm.yyyy hh24:mi:ss.ff')) "
	    aadd( aBind, { 0        , .F. } )
    	aadd( aBind, { 0        , .F. } )
        aadd( aBind, { cStmpSF4 , .F. } )
    else
        cQuery += " OR (( " + cVarConv + " > C1N.C1N_STAMP) OR C1N.C1N_STAMP IS NULL ) "
        cQuery += " OR " + cVarConv + " > ? ) "
        aadd( aBind, { cStmpSF4 , .F. } )
    endif

    cQuery += " AND SF4.D_E_L_E_T_ = ? "
    aadd( aBind, { space(1) , .F. } )

    self:oStatement := FwExecStatement():New( cQuery )
    TafSetPrepare(self:oStatement,@aBind)
    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} JSon
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method JSon() Class TSINATOPE

    Local cAlias    := getNextAlias()
    Local nLen      := 0
    Local cExigISS  := ''
    Local oJObjRet  := nil

    oJObjRet := JsonObject():New()

    DbSelectArea('C1N')
    C1N->(DbSetOrder(1))

	self:oStatement:OpenAlias( cAlias )

    TAFConOut("TSILOG000010: Query de busca do cadastro de Natureza da operação [ Início query TSILOG00006 " + TIME() + " ]"  + self:cFinalQuery + "[ Fim query TSILOG00005 " + TIME() + "  ] ")  
    oJObjRet['natureOfTheOperation'] := {}  

    While ( cAlias )->( !EOF( ) )
        aAdd( oJObjRet['natureOfTheOperation'], JsonObject( ):New( ) )
        nLen++
        /*
        Referente a exportação indireta CFOP: ( 5501/6501/5502/6502/ ) | Exportação direta: CFOP tudo que começa com 7.
        Como estamos tratando a GISS apenas para operação de entrada\compras não possui exportação nesse momento.

        De/Para da SF4/T85, posteriormente deverá ser feito o De/Para da T85 com o campo {51. ExigibilidadeISS} do manual da GISS, conforme Código de natureza da operação:
        1 – Exigível;2 – Não incidência;3 – Isenção;4 – Exportação;5 – Imunidade;6 – Exigibilidade Suspensa por Decisão Judicial; 7 – Exigibilidade Suspensa por Processo Administrativo)
        aqui se faz necessario o código do C1N_CODEXI(TAM 2) F3 T85 XFUNVldCmp("T85",2,,,) para gravar o ID no campo C1N_IDEXIG(TAM 36).
        */
        cExigISS := ''
        //Apenas nao trata a opcao F4_ISSST=8(Micro Empreendedor Individual MEI)
        if Alltrim((cAlias)->F4_ISSST) == '1' .Or. Alltrim((cAlias)->F4_ISSST) == '2' //#1=Dentro do municipio #2=Fora municipio
            cExigISS := '01'    //2.1 Exigível

        elseif Alltrim((cAlias)->F4_ISSST) == '3' .Or. Alltrim((cAlias)->F4_ISSST) == '9' //#3=Isencao #9=Isencao Parcial
            cExigISS := '04'    //2.4 Isenta do ISS

        elseif Alltrim((cAlias)->F4_ISSST) == '4' .Or. Alltrim((cAlias)->F4_ISSST) == 'A' //#4=Imune #A Imunidade Objetiva
            cExigISS := '03'    //2.3 Imunidade Tributária

        elseif Alltrim((cAlias)->F4_ISSST) == '5' //Exigibilidade Susp. Judicial
            cExigISS := '05'    //2.5 Exigibilidade Suspensa por Decisão Judicial

        elseif Alltrim((cAlias)->F4_ISSST) == '6' //Exigibilidade Susp. Proc. Adm
            cExigISS := '08'    //2.8 Exigibilidade Suspensa por Decisão Adm

        elseif Alltrim((cAlias)->F4_ISSST) == '7' //Nao tributavel
            cExigISS := '06'    //2.6 Não Incidência
        endif

        oJObjRet['natureOfTheOperation'][nLen]["natureOfTheOperationId"] := alltrim( ( cAlias )->CODIGO )   // 2 - COD_NAT
        oJObjRet['natureOfTheOperation'][nLen]["description"           ] := alltrim( ( cAlias )->DESCR  )   // 3 - DESCR_NAT
        oJObjRet['natureOfTheOperation'][nLen]["stamp"                 ] := ( cAlias )->STAMP               // 9 - STAMP
        //Campos ja existentes nao sera necessario protecao C1N_CODEXI (V)
        oJObjRet['natureOfTheOperation'][nLen]["enforceabilityISS"     ] := cExigISS                        // ? - _CODEXI Título: Codigo Exig. ISS Tributacao Desc: Exigibilidade ISS

        ( cAlias )->( DBSKIP( ) )
    EndDo

    ( cAlias )->( DBCloseArea( ) )

    self:oJObjTSI := oJObjRet
	if self:oStatement != Nil
		freeobj(self:oStatement)
		self:oStatement := Nil
	endif
Return

 /*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method GetJsn () Class TSINATOPE

Return self:oJObjTSI
 /*/{Protheus.doc} FilC1N
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC1N(cSourceBr) Class TSINATOPE        
     self:aFilC1N := TafTSIFil(cSourceBr, 'C1N')      
Return
