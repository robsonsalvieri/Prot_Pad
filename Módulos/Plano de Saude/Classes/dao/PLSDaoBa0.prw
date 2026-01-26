#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBa0 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class PLSDaoBa0
	_Super:New(aFields)
    self:cAlias := "BA0"
    self:cfieldOrder := "BA0_CODIDE,BA0_CODINT"
Return self

Method buscar() Class PLSDaoBa0
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BA0->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBa0
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBa0

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BA0') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BA0_FILIAL = '" + xFilial("BA0") + "' "

    cQuery += " AND BA0_CODIDE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA0_CODIDE")))
    cQuery += " AND BA0_CODINT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA0_CODINT")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBa0
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBa0

    Default lInclui := .F.

	If BA0->(RecLock("BA0",lInclui))
		
        BA0->BA0_FILIAL := xFilial("BA0")
        If lInclui
        
            BA0->BA0_CODIDE := _Super:normalizeType(BA0->BA0_CODIDE,self:getValue("BA0_CODIDE")) 
            BA0->BA0_CODINT := _Super:normalizeType(BA0->BA0_CODINT,self:getValue("BA0_CODINT")) 

        EndIf

        BA0->BA0_NOMINT := _Super:normalizeType(BA0->BA0_NOMINT,self:getValue("BA0_NOMINT")) 
        BA0->BA0_CLAINT := _Super:normalizeType(BA0->BA0_CLAINT,self:getValue("BA0_CLAINT")) 
        BA0->BA0_GRUOPE := _Super:normalizeType(BA0->BA0_GRUOPE,self:getValue("BA0_GRUOPE")) 
        BA0->BA0_CAMCOM := _Super:normalizeType(BA0->BA0_CAMCOM,self:getValue("BA0_CAMCOM")) 
        BA0->BA0_SUSEP := _Super:normalizeType(BA0->BA0_SUSEP,self:getValue("BA0_SUSEP")) 
        BA0->BA0_CGC := _Super:normalizeType(BA0->BA0_CGC,self:getValue("BA0_CGC")) 
        BA0->BA0_INCEST := _Super:normalizeType(BA0->BA0_INCEST,self:getValue("BA0_INCEST")) 
        BA0->BA0_EMAIL := _Super:normalizeType(BA0->BA0_EMAIL,self:getValue("BA0_EMAIL")) 
        BA0->BA0_SITE := _Super:normalizeType(BA0->BA0_SITE,self:getValue("BA0_SITE")) 
        BA0->BA0_DATFUN := _Super:normalizeType(BA0->BA0_DATFUN,self:getValue("BA0_DATFUN")) 
        BA0->BA0_CEP := _Super:normalizeType(BA0->BA0_CEP,self:getValue("BA0_CEP")) 
        BA0->BA0_END := _Super:normalizeType(BA0->BA0_END,self:getValue("BA0_END")) 
        BA0->BA0_NUMEND := _Super:normalizeType(BA0->BA0_NUMEND,self:getValue("BA0_NUMEND")) 
        BA0->BA0_COMPEN := _Super:normalizeType(BA0->BA0_COMPEN,self:getValue("BA0_COMPEN")) 
        BA0->BA0_BAIRRO := _Super:normalizeType(BA0->BA0_BAIRRO,self:getValue("BA0_BAIRRO")) 
        BA0->BA0_CODMUN := _Super:normalizeType(BA0->BA0_CODMUN,self:getValue("BA0_CODMUN")) 
        BA0->BA0_CIDADE := _Super:normalizeType(BA0->BA0_CIDADE,self:getValue("BA0_CIDADE")) 
        BA0->BA0_EST := _Super:normalizeType(BA0->BA0_EST,self:getValue("BA0_EST")) 
        BA0->BA0_TELEF1 := _Super:normalizeType(BA0->BA0_TELEF1,self:getValue("BA0_TELEF1")) 
        BA0->BA0_TELEF2 := _Super:normalizeType(BA0->BA0_TELEF2,self:getValue("BA0_TELEF2")) 
        BA0->BA0_TELEF3 := _Super:normalizeType(BA0->BA0_TELEF3,self:getValue("BA0_TELEF3")) 
        BA0->BA0_FAX1 := _Super:normalizeType(BA0->BA0_FAX1,self:getValue("BA0_FAX1")) 
        BA0->BA0_FAX2 := _Super:normalizeType(BA0->BA0_FAX2,self:getValue("BA0_FAX2")) 
        BA0->BA0_FAX3 := _Super:normalizeType(BA0->BA0_FAX3,self:getValue("BA0_FAX3")) 
        BA0->BA0_MATFIL := _Super:normalizeType(BA0->BA0_MATFIL,self:getValue("BA0_MATFIL")) 
        BA0->BA0_MODOPE := _Super:normalizeType(BA0->BA0_MODOPE,self:getValue("BA0_MODOPE")) 
        BA0->BA0_CODFOR := _Super:normalizeType(BA0->BA0_CODFOR,self:getValue("BA0_CODFOR")) 
        BA0->BA0_LOJA := _Super:normalizeType(BA0->BA0_LOJA,self:getValue("BA0_LOJA")) 
        BA0->BA0_TBRFRE := _Super:normalizeType(BA0->BA0_TBRFRE,self:getValue("BA0_TBRFRE")) 
        BA0->BA0_CODTAB := _Super:normalizeType(BA0->BA0_CODTAB,self:getValue("BA0_CODTAB")) 
        BA0->BA0_CODCLI := _Super:normalizeType(BA0->BA0_CODCLI,self:getValue("BA0_CODCLI")) 
        BA0->BA0_LOJCLI := _Super:normalizeType(BA0->BA0_LOJCLI,self:getValue("BA0_LOJCLI")) 
        BA0->BA0_NATURE := _Super:normalizeType(BA0->BA0_NATURE,self:getValue("BA0_NATURE")) 
        BA0->BA0_TIPOPE := _Super:normalizeType(BA0->BA0_TIPOPE,self:getValue("BA0_TIPOPE")) 
        BA0->BA0_EXPIDE := _Super:normalizeType(BA0->BA0_EXPIDE,self:getValue("BA0_EXPIDE")) 
        BA0->BA0_NOMCAR := _Super:normalizeType(BA0->BA0_NOMCAR,self:getValue("BA0_NOMCAR")) 
        BA0->BA0_VL2BOL := _Super:normalizeType(BA0->BA0_VL2BOL,self:getValue("BA0_VL2BOL")) 
        BA0->BA0_VLCSOP := _Super:normalizeType(BA0->BA0_VLCSOP,self:getValue("BA0_VLCSOP")) 
        BA0->BA0_VENCTO := _Super:normalizeType(BA0->BA0_VENCTO,self:getValue("BA0_VENCTO")) 
        BA0->BA0_TIPVEN := _Super:normalizeType(BA0->BA0_TIPVEN,self:getValue("BA0_TIPVEN")) 
        BA0->BA0_VENCUS := _Super:normalizeType(BA0->BA0_VENCUS,self:getValue("BA0_VENCUS")) 
        BA0->BA0_TIPCUS := _Super:normalizeType(BA0->BA0_TIPCUS,self:getValue("BA0_TIPCUS")) 
        BA0->BA0_ENVPTU := _Super:normalizeType(BA0->BA0_ENVPTU,self:getValue("BA0_ENVPTU")) 
        BA0->BA0_RECPTU := _Super:normalizeType(BA0->BA0_RECPTU,self:getValue("BA0_RECPTU")) 
        BA0->BA0_EMAPTU := _Super:normalizeType(BA0->BA0_EMAPTU,self:getValue("BA0_EMAPTU")) 
        BA0->BA0_RESPTU := _Super:normalizeType(BA0->BA0_RESPTU,self:getValue("BA0_RESPTU")) 
        BA0->BA0_CODRDA := _Super:normalizeType(BA0->BA0_CODRDA,self:getValue("BA0_CODRDA")) 
        BA0->BA0_ONLINE := _Super:normalizeType(BA0->BA0_ONLINE,self:getValue("BA0_ONLINE")) 
        BA0->BA0_DIARET := _Super:normalizeType(BA0->BA0_DIARET,self:getValue("BA0_DIARET")) 
        BA0->BA0_A100 := _Super:normalizeType(BA0->BA0_A100,self:getValue("BA0_A100")) 
        BA0->BA0_A300 := _Super:normalizeType(BA0->BA0_A300,self:getValue("BA0_A300")) 
        BA0->BA0_A600 := _Super:normalizeType(BA0->BA0_A600,self:getValue("BA0_A600")) 
        BA0->BA0_A700 := _Super:normalizeType(BA0->BA0_A700,self:getValue("BA0_A700")) 
        BA0->BA0_LIMCH := _Super:normalizeType(BA0->BA0_LIMCH,self:getValue("BA0_LIMCH")) 
        BA0->BA0_TIPLIM := _Super:normalizeType(BA0->BA0_TIPLIM,self:getValue("BA0_TIPLIM")) 
        BA0->BA0_NIVVAL := _Super:normalizeType(BA0->BA0_NIVVAL,self:getValue("BA0_NIVVAL")) 
        BA0->BA0_GNT := _Super:normalizeType(BA0->BA0_GNT,self:getValue("BA0_GNT")) 
        BA0->BA0_BLOINO := _Super:normalizeType(BA0->BA0_BLOINO,self:getValue("BA0_BLOINO")) 
        BA0->BA0_TIPPAG := _Super:normalizeType(BA0->BA0_TIPPAG,self:getValue("BA0_TIPPAG")) 
        BA0->BA0_BCOCLI := _Super:normalizeType(BA0->BA0_BCOCLI,self:getValue("BA0_BCOCLI")) 
        BA0->BA0_AGECLI := _Super:normalizeType(BA0->BA0_AGECLI,self:getValue("BA0_AGECLI")) 
        BA0->BA0_CTACLI := _Super:normalizeType(BA0->BA0_CTACLI,self:getValue("BA0_CTACLI")) 
        BA0->BA0_PORTAD := _Super:normalizeType(BA0->BA0_PORTAD,self:getValue("BA0_PORTAD")) 
        BA0->BA0_AGEDEP := _Super:normalizeType(BA0->BA0_AGEDEP,self:getValue("BA0_AGEDEP")) 
        BA0->BA0_CTACOR := _Super:normalizeType(BA0->BA0_CTACOR,self:getValue("BA0_CTACOR")) 
        BA0->BA0_EMPORI := _Super:normalizeType(BA0->BA0_EMPORI,self:getValue("BA0_EMPORI")) 
        BA0->BA0_BASCOP := _Super:normalizeType(BA0->BA0_BASCOP,self:getValue("BA0_BASCOP")) 
        BA0->BA0_ABRANG := _Super:normalizeType(BA0->BA0_ABRANG,self:getValue("BA0_ABRANG")) 
        BA0->BA0_DDD := _Super:normalizeType(BA0->BA0_DDD,self:getValue("BA0_DDD")) 
        BA0->BA0_NATJUR := _Super:normalizeType(BA0->BA0_NATJUR,self:getValue("BA0_NATJUR")) 
        BA0->BA0_MODALI := _Super:normalizeType(BA0->BA0_MODALI,self:getValue("BA0_MODALI")) 
        BA0->BA0_SEGMEN := _Super:normalizeType(BA0->BA0_SEGMEN,self:getValue("BA0_SEGMEN")) 
        BA0->BA0_CODREG := _Super:normalizeType(BA0->BA0_CODREG,self:getValue("BA0_CODREG")) 
        BA0->BA0_ACOPUL := _Super:normalizeType(BA0->BA0_ACOPUL,self:getValue("BA0_ACOPUL")) 
        BA0->BA0_TOTACO := _Super:normalizeType(BA0->BA0_TOTACO,self:getValue("BA0_TOTACO")) 
        BA0->BA0_RAMAL1 := _Super:normalizeType(BA0->BA0_RAMAL1,self:getValue("BA0_RAMAL1")) 
        BA0->BA0_RAMAL2 := _Super:normalizeType(BA0->BA0_RAMAL2,self:getValue("BA0_RAMAL2")) 
        BA0->BA0_RAMAL3 := _Super:normalizeType(BA0->BA0_RAMAL3,self:getValue("BA0_RAMAL3")) 
        BA0->BA0_SENQUI := _Super:normalizeType(BA0->BA0_SENQUI,self:getValue("BA0_SENQUI")) 
        BA0->BA0_MAXRG := _Super:normalizeType(BA0->BA0_MAXRG,self:getValue("BA0_MAXRG")) 
        BA0->BA0_SENRAD := _Super:normalizeType(BA0->BA0_SENRAD,self:getValue("BA0_SENRAD")) 
        BA0->BA0_TPOPED := _Super:normalizeType(BA0->BA0_TPOPED,self:getValue("BA0_TPOPED")) 
        BA0->BA0_TISVER := _Super:normalizeType(BA0->BA0_TISVER,self:getValue("BA0_TISVER")) 
        BA0->BA0_SENOPM := _Super:normalizeType(BA0->BA0_SENOPM,self:getValue("BA0_SENOPM")) 
        BA0->BA0_PRZREC := _Super:normalizeType(BA0->BA0_PRZREC,self:getValue("BA0_PRZREC")) 
        BA0->BA0_TPPAG := _Super:normalizeType(BA0->BA0_TPPAG,self:getValue("BA0_TPPAG")) 
        BA0->BA0_CRIPRZ := _Super:normalizeType(BA0->BA0_CRIPRZ,self:getValue("BA0_CRIPRZ")) 
        BA0->BA0_TABPRZ := _Super:normalizeType(BA0->BA0_TABPRZ,self:getValue("BA0_TABPRZ")) 
        BA0->BA0_CRILIM := _Super:normalizeType(BA0->BA0_CRILIM,self:getValue("BA0_CRILIM")) 
        BA0->BA0_TABLIM := _Super:normalizeType(BA0->BA0_TABLIM,self:getValue("BA0_TABLIM")) 
        BA0->BA0_AUTGES := _Super:normalizeType(BA0->BA0_AUTGES,self:getValue("BA0_AUTGES")) 
        BA0->BA0_DIGANE := _Super:normalizeType(BA0->BA0_DIGANE,self:getValue("BA0_DIGANE")) 
        BA0->BA0_VLRAPR := _Super:normalizeType(BA0->BA0_VLRAPR,self:getValue("BA0_VLRAPR")) 
        BA0->BA0_ENDPOI := _Super:normalizeType(BA0->BA0_ENDPOI,self:getValue("BA0_ENDPOI")) 

        BA0->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
