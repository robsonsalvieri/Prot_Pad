#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := Nil
Static cUltStmp := Nil

static nTmFTPrd := Nil
static nTmB1Prd := Nil

Static lCompSB1 := Nil
Static lCompC1L := Nil
Static lAliErp  := Nil
Static lCompar  := Nil

/*/{Protheus.doc} TSIITEM
	(Classe que contém preparedstatament do T005 )
    @type Class
	@author Henrique Pereira 
    @author Carlos Eduardo
	@since 10/06/2020
	@return Nil, nulo, não tem retorno.
/*/ 
 
Class TSIITEM

    Data TSITQRY     as String ReadOnly
    Data cFinalQuery as String ReadOnly 
    Data oStatement  as Object ReadOnly
    Data aFilC1L     as Array  ReadOnly
    Data oJObjTSI    as Object
    Data cAlias      as String 
    Data nTotReg     as numeric
    Data nSizeMax    as numeric
    Data nReg        as numeric 

    Method New() Constructor
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method TempTable()
    Method FilC1L()
    Method GetJsn()
    Method CommitRegs()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSIITEM )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira 
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
 
Method New(cSourceBr, cTable) Class TSIITEM

If !FwIsInCallStack('RESTGETLISTSERVICE')        

    lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
    cUltStmp := iif(lNewCtrl, TsiUltStamp("C1L"),' ')
    nTmFTPrd := GetSx3Cache( 'FT_PRODUTO' , 'X3_TAMANHO' )
    nTmB1Prd := GetSx3Cache( 'B1_COD'     , 'X3_TAMANHO' )
    lCompSB1 := iif(Upper(AllTrim(FWModeAccess("SB1",1)+FWModeAccess("SB1",2)+FWModeAccess("SB1",3))) == 'CCC' ,.T.,.F.)
    lCompC1L := iif(Upper(AllTrim(FWModeAccess("C1L",1)+FWModeAccess("C1L",2)+FWModeAccess("C1L",3))) == 'CCC' ,.T.,.F.)
    lAliErp  := iif(lNewCtrl,V80->(FieldPos("V80_ALIERP") ) > 0,.F.)
    lCompar  := iif(lNewCtrl, (V80->(FieldPos("V80_COMPAR") ) > 0 .And. lCompSB1 .And. lCompC1L ) ,.F.)

    Self:FilC1L(cSourceBr)
    self:nSizeMax := 1000  //Seta limite máximo de execução para ser chamado no TAFA565
    Self:LoadQuery(cTable)
    Self:TempTable()  

Endif
    
Return Nil


 /*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira 
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery(cTable) Class TSIITEM

Local cQuery    := ''
Local aBlocok   := {}
Local cB1Sped   := GetNewPar('MV_DTINCB1','')
Local nIcmPad   := GetNewPar('MV_ICMPAD','')
Local cDbType   := Upper(Alltrim(TCGetDB()))
Local cConvB1   := ''
Local cConvB5   := ''
Local cConvF2Q  := ''
Local cConvPROD := ''
Local cConvISS  := ''
Local nX        := 1
Local cMensagem := ''
Local aBind     := {}

//Guardo todos os parametros referente ao bloco K no array.
aadd(aBlocok,{GetNewPar('MV_BLKTP00',''),'MV_BLKTP00'}) // Mercadoria para revenda
aadd(aBlocok,{GetNewPar('MV_BLKTP01',''),'MV_BLKTP01'}) // Materia Prima
aadd(aBlocok,{GetNewPar('MV_BLKTP02',''),'MV_BLKTP02'}) // Embalagem
aadd(aBlocok,{GetNewPar('MV_BLKTP03',''),'MV_BLKTP03'}) // Produto em processo
aadd(aBlocok,{GetNewPar('MV_BLKTP04',''),'MV_BLKTP04'}) // Produto acabado
aadd(aBlocok,{GetNewPar('MV_BLKTP06',''),'MV_BLKTP06'}) // Produto Intermediario
aadd(aBlocok,{GetNewPar('MV_BLKTP10',''),'MV_BLKTP10'}) // OUtros Insumos

// Criado for para tratar os casos em que o valor informado nos parâmetros MV_BLKTPXX não começam ou não
// terminam com aspas simples, evitando quebra na query.

cMensagem += "TSILOG000022: Conteudo dos parametros do bloco K ->> MV_BLKTPXX:" +chr(10)

For nX := 1 to len(aBlocok)
    If !Empty(aBlocok[nX,1])
        If  SubStr(Alltrim(aBlocok[nX,1]), 1, 1 ) != "'" .OR. SubStr(Alltrim(aBlocok[nX,1]), len(AllTrim(aBlocok[nX,1])),1) != "'"
            aBlocok[nX,1] := AllTrim(StrTran( aBlocok[nX,1], '"', '' ))
            aBlocok[nX,1] := "'" + AllTrim(StrTran( aBlocok[nX,1], "'", '' )) + "'" 
        Endif

        cMensagem += aBlocok[nX,2] + " : " + aBlocok[nX,1]+chr(10)
      
    Else
        cMensagem += "Parametro: "+ aBlocok[nX,2] + " Vazio "
    Endif

Next nX

TAFConOut(cMensagem) 

if !empty(cB1Sped) 
	cB1Sped := StrTran(cB1Sped, '"','')
	cB1Sped := StrTran(cB1Sped, "'",'')
    cB1Sped := 'B1.'+alltrim(cB1Sped)
else
    cB1Sped := dtos(dDataBase)
endif

//Gerando registro T007

cQuery := " SELECT DISTINCT "  

If cDbType $ "MSSQL/MSSQL7"
    cConvB1     := " convert(varchar(23), B1.S_T_A_M_P_ , 21 ) "
    cConvB5     := " convert(varchar(23), B5.S_T_A_M_P_ , 21 ) "
    cConvF2Q    := " convert(varchar(23), F2Q.S_T_A_M_P_ , 21 ) "   
    cConvPROD   := " convert(varchar(23), CDNPROD.S_T_A_M_P_ , 21 ) "
    cConvISS    := " convert(varchar(23), CDNISS.S_T_A_M_P_  , 21 ) "
Elseif cDbType $ "ORACLE"
    cConvB1     := " cast( to_char(B1.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvB5     := " cast( to_char(B5.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvF2Q    := " cast( to_char(F2Q.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvPROD   := " cast( to_char(CDNPROD.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvISS    := " cast( to_char(CDNISS.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
Elseif cDbType $ "POSTGRES"
    cConvB1     := " cast( to_char(B1.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvB5     := " cast( to_char(B5.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvF2Q    := " cast( to_char(F2Q.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvPROD   := " cast( to_char(CDNPROD.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvISS    := " cast( to_char(CDNISS.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
Endif

cQuery += cConvB1 + " B1_STAMP, "
cQuery += cConvB5 + " B5_STAMP, "
cQuery += cConvF2Q + " F2Q_STAMP, "   
cQuery += cConvPROD + " CDNPROD_STAMP, "
cQuery += cConvISS + " CDNISS_STAMP, "
cQuery += "B1.B1_COD COD_ITEM, " // 02 - COD_ITEM
cQuery += "B1.B1_DESC  DESCR_ITEM, " // 03 - DESCR_ITEM
cQuery += "B1.B1_UM UNID_INV, " // 05 - UNID_INV
cQuery += "case " 
cQuery += "   when B1.B1_CODISS != ? then ? "
aadd( aBind, { ''	   , .F. } )
aadd( aBind, { '09'    , .F. } )
cQuery += "   when B1.B1_TIPO = ? then ? "
aadd( aBind, { 'AI'	   , .F. } )
aadd( aBind, { '08'    , .F. } )
//Coloco IFF para veriifcar se a posição do array é branco. Caso seja, não há motivos para ter operador OR, pois iria
//criar um IN com o valor BRANCO.
If !Empty(aBlocok[03,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? "
    aadd( aBind, { 'EM'	   , .F. } )
    aadd( aBind, { {aBlocok[03,01]}   , .F. } )
    aadd( aBind, { '02'	   , .F. } )
Else 
    cQuery += " when B1.B1_TIPO = ? then ? "
    aadd( aBind, { 'EM'	   , .F. } )
    aadd( aBind, { '02'    , .F. } )
EndIf
cQuery += "   when B1.B1_TIPO = ? then ? "
aadd( aBind, { 'MC'	   , .F. } )
aadd( aBind, { '07'    , .F. } )

If !Empty(aBlocok[01,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? "
    aadd( aBind, { 'ME'	   , .F. } )
    aadd( aBind, { {aBlocok[01,01]}   , .F. } )
    aadd( aBind, { '00'	   , .F. } )
Else 
    cQuery += " when B1.B1_TIPO = ? then ? "
    aadd( aBind, { 'ME'	   , .F. } )
    aadd( aBind, { '00'    , .F. } )
EndIf

If !Empty(aBlocok[02,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? "
    aadd( aBind, { 'MP'	   , .F. } )
    aadd( aBind, { {aBlocok[02,01]}   , .F. } )
    aadd( aBind, { '01'	   , .F. } )
Else 
    cQuery += " when B1_TIPO = ? then ? "
    aadd( aBind, { 'MP'	   , .F. } )
    aadd( aBind, { '01'    , .F. } )
EndIf

If !Empty(aBlocok[07,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? "
    aadd( aBind, { 'OI'	   , .F. } )
    aadd( aBind, { {aBlocok[07,01]}   , .F. } )
    aadd( aBind, { '10'	   , .F. } )
Else 
    cQuery += " when B1_TIPO = ? then ? "
    aadd( aBind, { 'OI'	   , .F. } )
    aadd( aBind, { '10'    , .F. } )
EndIf

If !Empty(aBlocok[05,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? "
    aadd( aBind, { 'PA'	   , .F. } )
    aadd( aBind, { {aBlocok[05,01]}   , .F. } )
    aadd( aBind, { '04'	   , .F. } )
Else 
    cQuery += " when B1_TIPO = ? then ? "
    aadd( aBind, { 'PA'	   , .F. } )
    aadd( aBind, { '04'    , .F. } )
EndIf

If !Empty(aBlocok[06,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? " 
    aadd( aBind, { 'PI'	   , .F. } )
    aadd( aBind, { {aBlocok[06,01]}   , .F. } )
    aadd( aBind, { '06'	   , .F. } )
Else 
    cQuery += " when B1_TIPO = ? then ? "
    aadd( aBind, { 'PI'	   , .F. } )
    aadd( aBind, { '06'    , .F. } )
EndIf

If !Empty(aBlocok[04,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? " 
    aadd( aBind, { 'PP'	   , .F. } )
    aadd( aBind, { {aBlocok[04,01]}   , .F. } )
    aadd( aBind, { '03'	   , .F. } )
Else 
    cQuery += " when B1_TIPO = ? then ? "
    aadd( aBind, { 'PP'	   , .F. } )
    aadd( aBind, { '03'    , .F. } )
EndIf

If !Empty(aBlocok[05,01])
    cQuery += "   when B1.B1_TIPO = ? OR B1.B1_TIPO IN ( ? ) then ? " 
    aadd( aBind, { 'SP'	   , .F. } )
    aadd( aBind, { {aBlocok[05,01]}   , .F. } )
    aadd( aBind, { '05'	   , .F. } )
Else 
    cQuery += " when B1_TIPO = ? then ? "
    aadd( aBind, { 'SP'	   , .F. } )
    aadd( aBind, { '05'    , .F. } )
EndIf
cQuery += "else ? end TIPO_ITEM, " //Verificar se o conteúdo deverá vir do sped // 06 - TIPO_ITEM
aadd( aBind, { '99'    , .F. } )

cQuery += "B1.B1_POSIPI COD_NCM, " // 07 - COD_NCM
cQuery += "B1.B1_EX_NCM EX_IPI, " // 08 - EX_IPI
cQuery += "case "
cQuery += "   when CDNPROD.CDN_CODLST IS NOT NULL then CDNPROD.CDN_CODLST "
cQuery += "   when CDNISS.CDN_CODLST IS NOT NULL then CDNISS.CDN_CODLST "
cQuery += "else ? end COD_LST, "	
aadd( aBind, { ''    , .F. } )													//-- 10 - COD_LST -> Na posição 10 vai o código de serviço federal.
cQuery += "B1.B1_ORIGEM ORIGEM, "																//-- 14 - ORIGEM

If cDbType $ "ORACLE"
    cQuery += "case when B1.B1_PICM > TO_NUMBER(?) then B1.B1_PICM else TO_NUMBER(?) end ALIQ_ICMS,  " //-- 16 - ALIQ_ICMS
    aadd( aBind, { '0'    , .F. } )
    aadd( aBind, { str(nIcmPad,5,2)    , .F. } )
Else
    cQuery += "case when B1.B1_PICM > ? then B1.B1_PICM else ? end ALIQ_ICMS,  " //-- 16 - ALIQ_ICMS
    aadd( aBind, { 0    , .F. } )
    aadd( aBind, { Val(str(nIcmPad,5,2))   , .F. } )
EndIf

cQuery += "B1.B1_IPI ALIQ_IPI, "                                                               //-- 18 - ALIQ_IPI -- Val2Str((cAliasQry)->B1_IPI,5,2))
cQuery += "case "
// Caso existe a tabela e o campo, priorizo o tipo de serviço da reinf que esta no cadastro do produto.
if TAFAlsInDic('F2Q') .and. TafColumnPos('F2Q_TPSERV')
    cQuery += "when F2Q.F2Q_TPSERV IS NOT NULL AND F2Q.F2Q_TPSERV != ? then F2Q.F2Q_TPSERV " 
    aadd( aBind, { '' , .F. } )
endif
cQuery += "   when CDNPROD.CDN_CODLST IS NOT NULL then CDNPROD.CDN_TPSERV "
cQuery += "   when CDNISS.CDN_CODLST IS NOT NULL then CDNISS.CDN_TPSERV "
cQuery += "else ? end TIP_SERV, " //29 - TIP_SERV	 
aadd( aBind, { '' , .F. } )
cQuery += "B1.B1_CODISS, B1.B1_PICM " //-- Campos auxiliares
cQuery += "FROM " + RetSqlName('SB1') + " B1 "

cQuery += "INNER JOIN " 
cQuery += "(SELECT DISTINCT SFT.FT_PRODUTO PRODUTO, SFT.FT_FILIAL FILIAL "
cQuery += "FROM " + cTable + " SFT ) SFTTEMP "
cQuery += "ON SFTTEMP.FILIAL = ? "
aadd( aBind, { xFilial( "SFT" ) , .F. } )
cQuery += "AND SFTTEMP.PRODUTO = B1.B1_COD "

cQuery += "LEFT JOIN " + RetSqlName('SB5') + " B5 ON B5.B5_FILIAL = ? AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = ? " // Left Join com SB5 porque serão incluídos campos para registros REINF
aadd( aBind, { xFilial( "SB5" ) , .F. } )
aadd( aBind, { space(1) , .F. } )

cQuery += "FULL OUTER JOIN " + RetSqlName('CDN') + " CDNPROD ON CDNPROD.CDN_FILIAL = ? AND CDNPROD.CDN_CODISS = B1.B1_CODISS AND CDNPROD.CDN_PROD = B1.B1_COD AND CDNPROD.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial( "CDN" ) , .F. } )
aadd( aBind, { space(1) , .F. } )

cQuery += "FULL OUTER JOIN " + RetSqlName('CDN') + " CDNISS ON CDNISS.CDN_FILIAL = ? AND CDNISS.CDN_CODISS = B1.B1_CODISS AND CDNISS.CDN_PROD = ? AND CDNISS.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial( "CDN" ) , .F. } )
aadd( aBind, { '' , .F. } )
aadd( aBind, { space(1) , .F. } )

if TAFAlsInDic('F2Q') .and. TafColumnPos('F2Q_TPSERV')
    cQuery += "LEFT JOIN " + RetSqlName('F2Q') + " F2Q ON F2Q.F2Q_FILIAL = ? AND F2Q.F2Q_PRODUT = B1.B1_COD AND F2Q.D_E_L_E_T_ = ? "
    aadd( aBind, { xFilial( "F2Q" ) , .F. } )
    aadd( aBind, { space(1) , .F. } )
endif

cQuery += "WHERE B1.B1_FILIAL = ? " 
cQuery += "AND B1.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial( "SB1" ) , .F. } )
aadd( aBind, { space(1) , .F. } )
    
self:oStatement := FwExecStatement():New( cQuery )
TafSetPrepare(self:oStatement,@aBind)
self:cFinalQuery := self:oStatement:GetFixQuery()

Return


/*/{Protheus.doc} TempTable(
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method TempTable() Class TSIITEM

    Self:cAlias    := getNextAlias( )

    self:oStatement:OpenAlias( Self:cAlias )

    DbSelectArea(Self:cAlias)
    Count to self:nTotReg

    TAFConOut("TSILOG00009: Query de busca dos Produtos [ Fim query TSILOG00009 " + TIME() + " ] ", 1, .F., "TSI" )

Return

/*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.  
/*/

Method GetJsn() Class TSIITEM

    Local cCodNcm   := ""
    Local cTpServ   := ""
    Local nTamDesc  := TAMSX3("C1L_DESCRI")[1]

    Local oJObjRet  := JsonObject( ):New( )
   
    //Gravo o maior stamp entro todos que compoe o registro
    cStamp := aSort( {(self:cAlias)->B1_STAMP, (self:cAlias)->B5_STAMP,(self:cAlias)->F2Q_STAMP, (self:cAlias)->CDNPROD_STAMP, (self:cAlias)->CDNISS_STAMP } ,,, { |x, y| x > y } )[1] 
    
    cCodNcm := alltrim( ( self:cAlias )->COD_NCM ) + alltrim(iif( !empty( ( self:cAlias )->EX_IPI ), ( self:cAlias )->EX_IPI, '' ))
    cTpServ := iif( !empty( ( self:cAlias )->TIP_SERV ), '1' + StrZero( Val( ( self:cAlias )->TIP_SERV ), 08 ), ''  )
    
    // Campos da Planilha Layout TAF - T007
    oJObjRet["itemId"       ] := rtrim( ( self:cAlias )->COD_ITEM )	    // 02 COD_ITEM 
    oJObjRet["description"  ] := Alltrim( SUBSTR( ( self:cAlias )-> DESCR_ITEM,1,nTamDesc) )   // 03 DESCR_ITEM
    oJObjRet["unit"         ] := ( self:cAlias )->UNID_INV              // 05 UNID_INV
    oJObjRet["itemType"     ] := alltrim( ( self:cAlias )->TIPO_ITEM )  // 06 TIPO_ITEM
    oJObjRet["idNcm"        ] := cCodNcm                                // 07 COD_NCM
    oJObjRet["serviceId"    ] := alltrim( ( self:cAlias )->COD_LST )    // 10 COD_LST
    oJObjRet["originId"     ] := ( self:cAlias )->ORIGEM                // 14 ORIGEM
    oJObjRet["icmsRate"     ] := ( self:cAlias )->ALIQ_ICMS             // 16 ALIQ_ICMS
    oJObjRet["ipiRate"      ] := ( self:cAlias )->ALIQ_IPI              // 18 ALIQ_IPI
    oJObjRet["serviceTypeId"] := cTpServ                                // 29 TIP_SERV
    oJObjRet["stamp"        ] := cStamp

Return oJObjRet

/*/{Protheus.doc} FilC1L
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC1L(cSourceBr) Class TSIITEM        
    self:aFilC1L := TafTSIFil(cSourceBr, 'C1L')      
Return

Method CommitRegs(oHash, cUltStmp, aREGxV80 ) Class TSIITEM  
    
    Local nGetNames := 0
    Local oBjJson   := 0

    Default cUltStmp := ''
    Default aREGxV80 := {}

    self:nReg := 0

    oJObjRet := JsonObject( ):New( )
    oJObjRet['item'] := { }
    
    (Self:cAlias)->(dbGoTop())
    while (Self:cAlias)->(!EOF())
        self:nReg ++
        
        oBjJson := Self:GetJsn()
        aadd(oJObjRet['item'],oBjJson)
        
        //Verifico se atingiu o limite de registros por array ou se o registro processado é igual ao ultimo da temp table
        IF self:nReg == self:nSizeMax .or. (Self:cAlias)->(RECNO()) == Self:nTotReg

            TAFConOut("TSILOG000025 Item (Cadastro de Produtos) " + cValtoChar((Self:cAlias)->(RECNO())) + " de " + cValToChar(Self:nTotReg),1,.F.,"TSI")
            
            for nGetNames := 1 to len( oJObjRet:GetNames() )
                TAFConOut("TSILOG00004 GetNames ok: " + cvaltochar(len( oJObjRet:GetNames() )))
                aObjJson := oJObjRet:GetJsonObject( oJObjRet:GetNames()[nGetNames] )

                //Utilizara novo motor pai e filho TAFA585, ex: processo referenciado e suspensao
                TAFA565( oHash, aObjJson, , , , @cUltStmp, aREGxV80 )
            next nGetNames
            
            ASIZE(aObjJson,0)
            aObjJson := {}

            FreeObj(oBjJson)
            oBjJson := NIL
            self:nReg := 0
        Endif

        (Self:cAlias)->(dbSkip())

    enddo

    if self:oStatement != Nil
        freeobj(self:oStatement)
        self:oStatement := Nil
    endif

Return
