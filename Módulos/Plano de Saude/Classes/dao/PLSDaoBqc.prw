#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBqc from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method nextSubCon()
    
EndClass

Method New(aFields) Class PLSDaoBqc
	_Super:New(aFields)
    self:cAlias := "BQC"
    self:cfieldOrder := "BQC_CODIGO,BQC_NUMCON,BQC_VERCON,BQC_SUBCON,BQC_VERSUB"
Return self

Method buscar() Class PLSDaoBqc
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BQC->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBqc
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBqc

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BQC') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BQC_FILIAL = '" + xFilial("BQC") + "' "

    cQuery += " AND BQC_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_CODIGO")))
    cQuery += " AND BQC_NUMCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_NUMCON")))
    cQuery += " AND BQC_VERCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_VERCON")))
    cQuery += " AND BQC_SUBCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_SUBCON")))
    cQuery += " AND BQC_VERSUB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_VERSUB")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBqc
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBqc

    Default lInclui := .F.

	If BQC->(RecLock("BQC",lInclui))
		
        BQC->BQC_FILIAL := xFilial("BQC")
        If lInclui
        
            BQC->BQC_CODIGO := _Super:normalizeType(BQC->BQC_CODIGO,self:getValue("BQC_CODIGO")) 
            BQC->BQC_NUMCON := _Super:normalizeType(BQC->BQC_NUMCON,self:getValue("BQC_NUMCON")) 
            BQC->BQC_VERCON := _Super:normalizeType(BQC->BQC_VERCON,self:getValue("BQC_VERCON")) 
            BQC->BQC_SUBCON := _Super:normalizeType(BQC->BQC_SUBCON,self:getValue("BQC_SUBCON")) 
            BQC->BQC_VERSUB := _Super:normalizeType(BQC->BQC_VERSUB,self:getValue("BQC_VERSUB")) 

        EndIf

        BQC->BQC_CODINT := _Super:normalizeType(BQC->BQC_CODINT,self:getValue("BQC_CODINT")) 
        BQC->BQC_CODEMP := _Super:normalizeType(BQC->BQC_CODEMP,self:getValue("BQC_CODEMP")) 
        BQC->BQC_DATCON := _Super:normalizeType(BQC->BQC_DATCON,self:getValue("BQC_DATCON")) 
        BQC->BQC_DESCRI := _Super:normalizeType(BQC->BQC_DESCRI,self:getValue("BQC_DESCRI")) 
        BQC->BQC_NREDUZ := _Super:normalizeType(BQC->BQC_NREDUZ,self:getValue("BQC_NREDUZ")) 
        BQC->BQC_COBNIV := _Super:normalizeType(BQC->BQC_COBNIV,self:getValue("BQC_COBNIV")) 
        BQC->BQC_CODCLI := _Super:normalizeType(BQC->BQC_CODCLI,self:getValue("BQC_CODCLI")) 
        BQC->BQC_CNPJ := _Super:normalizeType(BQC->BQC_CNPJ,self:getValue("BQC_CNPJ")) 
        BQC->BQC_LOJA := _Super:normalizeType(BQC->BQC_LOJA,self:getValue("BQC_LOJA")) 
        BQC->BQC_PODREM := _Super:normalizeType(BQC->BQC_PODREM,self:getValue("BQC_PODREM")) 
        BQC->BQC_NATURE := _Super:normalizeType(BQC->BQC_NATURE,self:getValue("BQC_NATURE")) 
        BQC->BQC_CODFOR := _Super:normalizeType(BQC->BQC_CODFOR,self:getValue("BQC_CODFOR")) 
        BQC->BQC_LOJFOR := _Super:normalizeType(BQC->BQC_LOJFOR,self:getValue("BQC_LOJFOR")) 
        BQC->BQC_PERCON := _Super:normalizeType(BQC->BQC_PERCON,self:getValue("BQC_PERCON")) 
        BQC->BQC_TPVCPP := _Super:normalizeType(BQC->BQC_TPVCPP,self:getValue("BQC_TPVCPP")) 
        BQC->BQC_VENCTO := _Super:normalizeType(BQC->BQC_VENCTO,self:getValue("BQC_VENCTO")) 
        BQC->BQC_TPVCCO := _Super:normalizeType(BQC->BQC_TPVCCO,self:getValue("BQC_TPVCCO")) 
        BQC->BQC_VENCCO := _Super:normalizeType(BQC->BQC_VENCCO,self:getValue("BQC_VENCCO")) 
        BQC->BQC_ALTVEN := _Super:normalizeType(BQC->BQC_ALTVEN,self:getValue("BQC_ALTVEN")) 
        BQC->BQC_GRATUI := _Super:normalizeType(BQC->BQC_GRATUI,self:getValue("BQC_GRATUI")) 
        BQC->BQC_COBRET := _Super:normalizeType(BQC->BQC_COBRET,self:getValue("BQC_COBRET")) 
        BQC->BQC_COBRAT := _Super:normalizeType(BQC->BQC_COBRAT,self:getValue("BQC_COBRAT")) 
        BQC->BQC_DIARET := _Super:normalizeType(BQC->BQC_DIARET,self:getValue("BQC_DIARET")) 
        BQC->BQC_CONCON := _Super:normalizeType(BQC->BQC_CONCON,self:getValue("BQC_CONCON")) 
        BQC->BQC_ULTCOB := _Super:normalizeType(BQC->BQC_ULTCOB,self:getValue("BQC_ULTCOB")) 
        BQC->BQC_NUMCOB := _Super:normalizeType(BQC->BQC_NUMCOB,self:getValue("BQC_NUMCOB")) 
        BQC->BQC_PATROC := _Super:normalizeType(BQC->BQC_PATROC,self:getValue("BQC_PATROC")) 
        BQC->BQC_TIPBLO := _Super:normalizeType(BQC->BQC_TIPBLO,self:getValue("BQC_TIPBLO")) 
        BQC->BQC_CODBLO := _Super:normalizeType(BQC->BQC_CODBLO,self:getValue("BQC_CODBLO")) 
        BQC->BQC_DATBLO := _Super:normalizeType(BQC->BQC_DATBLO,self:getValue("BQC_DATBLO")) 
        BQC->BQC_ANTCON := _Super:normalizeType(BQC->BQC_ANTCON,self:getValue("BQC_ANTCON")) 
        BQC->BQC_VL2BOL := _Super:normalizeType(BQC->BQC_VL2BOL,self:getValue("BQC_VL2BOL")) 
        BQC->BQC_VALID := _Super:normalizeType(BQC->BQC_VALID,self:getValue("BQC_VALID")) 
        BQC->BQC_MESREA := _Super:normalizeType(BQC->BQC_MESREA,self:getValue("BQC_MESREA")) 
        BQC->BQC_INDREA := _Super:normalizeType(BQC->BQC_INDREA,self:getValue("BQC_INDREA")) 
        BQC->BQC_PERREJ := _Super:normalizeType(BQC->BQC_PERREJ,self:getValue("BQC_PERREJ")) 
        BQC->BQC_CONTAC := _Super:normalizeType(BQC->BQC_CONTAC,self:getValue("BQC_CONTAC")) 
        BQC->BQC_TIPEND := _Super:normalizeType(BQC->BQC_TIPEND,self:getValue("BQC_TIPEND")) 
        BQC->BQC_CEP := _Super:normalizeType(BQC->BQC_CEP,self:getValue("BQC_CEP")) 
        BQC->BQC_LOGRAD := _Super:normalizeType(BQC->BQC_LOGRAD,self:getValue("BQC_LOGRAD")) 
        BQC->BQC_NUMERO := _Super:normalizeType(BQC->BQC_NUMERO,self:getValue("BQC_NUMERO")) 
        BQC->BQC_COMPLE := _Super:normalizeType(BQC->BQC_COMPLE,self:getValue("BQC_COMPLE")) 
        BQC->BQC_BAIRRO := _Super:normalizeType(BQC->BQC_BAIRRO,self:getValue("BQC_BAIRRO")) 
        BQC->BQC_CODMUN := _Super:normalizeType(BQC->BQC_CODMUN,self:getValue("BQC_CODMUN")) 
        BQC->BQC_MUN := _Super:normalizeType(BQC->BQC_MUN,self:getValue("BQC_MUN")) 
        BQC->BQC_ESTADO := _Super:normalizeType(BQC->BQC_ESTADO,self:getValue("BQC_ESTADO")) 
        BQC->BQC_ENDCOB := _Super:normalizeType(BQC->BQC_ENDCOB,self:getValue("BQC_ENDCOB")) 
        BQC->BQC_TEL := _Super:normalizeType(BQC->BQC_TEL,self:getValue("BQC_TEL")) 
        BQC->BQC_IMPORT := _Super:normalizeType(BQC->BQC_IMPORT,self:getValue("BQC_IMPORT")) 
        BQC->BQC_INFANS := _Super:normalizeType(BQC->BQC_INFANS,self:getValue("BQC_INFANS")) 
        BQC->BQC_EMICAR := _Super:normalizeType(BQC->BQC_EMICAR,self:getValue("BQC_EMICAR")) 
        BQC->BQC_OBRFAM := _Super:normalizeType(BQC->BQC_OBRFAM,self:getValue("BQC_OBRFAM")) 
        BQC->BQC_PERCOM := _Super:normalizeType(BQC->BQC_PERCOM,self:getValue("BQC_PERCOM")) 
        BQC->BQC_GRPCOB := _Super:normalizeType(BQC->BQC_GRPCOB,self:getValue("BQC_GRPCOB")) 
        BQC->BQC_OBRDAD := _Super:normalizeType(BQC->BQC_OBRDAD,self:getValue("BQC_OBRDAD")) 
        BQC->BQC_EQUIPE := _Super:normalizeType(BQC->BQC_EQUIPE,self:getValue("BQC_EQUIPE")) 
        BQC->BQC_CODVEN := _Super:normalizeType(BQC->BQC_CODVEN,self:getValue("BQC_CODVEN")) 
        BQC->BQC_RESCOM := _Super:normalizeType(BQC->BQC_RESCOM,self:getValue("BQC_RESCOM")) 
        BQC->BQC_QUACOB := _Super:normalizeType(BQC->BQC_QUACOB,self:getValue("BQC_QUACOB")) 
        BQC->BQC_NPERRN := _Super:normalizeType(BQC->BQC_NPERRN,self:getValue("BQC_NPERRN")) 
        BQC->BQC_ABRQUE := _Super:normalizeType(BQC->BQC_ABRQUE,self:getValue("BQC_ABRQUE")) 
        BQC->BQC_CONSLI := _Super:normalizeType(BQC->BQC_CONSLI,self:getValue("BQC_CONSLI")) 
        BQC->BQC_LIMCH := _Super:normalizeType(BQC->BQC_LIMCH,self:getValue("BQC_LIMCH")) 
        BQC->BQC_RPGPAT := _Super:normalizeType(BQC->BQC_RPGPAT,self:getValue("BQC_RPGPAT")) 
        BQC->BQC_ENTFIL := _Super:normalizeType(BQC->BQC_ENTFIL,self:getValue("BQC_ENTFIL")) 
        BQC->BQC_OUTLAN := _Super:normalizeType(BQC->BQC_OUTLAN,self:getValue("BQC_OUTLAN")) 
        BQC->BQC_TIPPAG := _Super:normalizeType(BQC->BQC_TIPPAG,self:getValue("BQC_TIPPAG")) 
        BQC->BQC_REGFIN := _Super:normalizeType(BQC->BQC_REGFIN,self:getValue("BQC_REGFIN")) 
        BQC->BQC_BCOCLI := _Super:normalizeType(BQC->BQC_BCOCLI,self:getValue("BQC_BCOCLI")) 
        BQC->BQC_AGECLI := _Super:normalizeType(BQC->BQC_AGECLI,self:getValue("BQC_AGECLI")) 
        BQC->BQC_REGGOP := _Super:normalizeType(BQC->BQC_REGGOP,self:getValue("BQC_REGGOP")) 
        BQC->BQC_CTACLI := _Super:normalizeType(BQC->BQC_CTACLI,self:getValue("BQC_CTACLI")) 
        BQC->BQC_PORTAD := _Super:normalizeType(BQC->BQC_PORTAD,self:getValue("BQC_PORTAD")) 
        BQC->BQC_GRUOPE := _Super:normalizeType(BQC->BQC_GRUOPE,self:getValue("BQC_GRUOPE")) 
        BQC->BQC_AGEDEP := _Super:normalizeType(BQC->BQC_AGEDEP,self:getValue("BQC_AGEDEP")) 
        BQC->BQC_CTACOR := _Super:normalizeType(BQC->BQC_CTACOR,self:getValue("BQC_CTACOR")) 
        BQC->BQC_COBJUR := _Super:normalizeType(BQC->BQC_COBJUR,self:getValue("BQC_COBJUR")) 
        BQC->BQC_TAXDIA := _Super:normalizeType(BQC->BQC_TAXDIA,self:getValue("BQC_TAXDIA")) 
        BQC->BQC_JURDIA := _Super:normalizeType(BQC->BQC_JURDIA,self:getValue("BQC_JURDIA")) 
        BQC->BQC_MAIORI := _Super:normalizeType(BQC->BQC_MAIORI,self:getValue("BQC_MAIORI")) 
        BQC->BQC_GUIPOS := _Super:normalizeType(BQC->BQC_GUIPOS,self:getValue("BQC_GUIPOS")) 
        BQC->BQC_CLAINS := _Super:normalizeType(BQC->BQC_CLAINS,self:getValue("BQC_CLAINS")) 
        BQC->BQC_CODVE2 := _Super:normalizeType(BQC->BQC_CODVE2,self:getValue("BQC_CODVE2")) 
        BQC->BQC_CRGPOS := _Super:normalizeType(BQC->BQC_CRGPOS,self:getValue("BQC_CRGPOS")) 
        BQC->BQC_MOTREA := _Super:normalizeType(BQC->BQC_MOTREA,self:getValue("BQC_MOTREA")) 
        BQC->BQC_CARREA := _Super:normalizeType(BQC->BQC_CARREA,self:getValue("BQC_CARREA")) 
        BQC->BQC_REALIN := _Super:normalizeType(BQC->BQC_REALIN,self:getValue("BQC_REALIN")) 
        BQC->BQC_NOMCAR := _Super:normalizeType(BQC->BQC_NOMCAR,self:getValue("BQC_NOMCAR")) 
        BQC->BQC_INFCAR := _Super:normalizeType(BQC->BQC_INFCAR,self:getValue("BQC_INFCAR")) 
        BQC->BQC_AGLUT := _Super:normalizeType(BQC->BQC_AGLUT,self:getValue("BQC_AGLUT")) 
        BQC->BQC_CODTES := _Super:normalizeType(BQC->BQC_CODTES,self:getValue("BQC_CODTES")) 
        BQC->BQC_QTDUS := _Super:normalizeType(BQC->BQC_QTDUS,self:getValue("BQC_QTDUS")) 
        BQC->BQC_QTDPUS := _Super:normalizeType(BQC->BQC_QTDPUS,self:getValue("BQC_QTDPUS")) 
        BQC->BQC_UNIPUS := _Super:normalizeType(BQC->BQC_UNIPUS,self:getValue("BQC_UNIPUS")) 
        BQC->BQC_VERLIM := _Super:normalizeType(BQC->BQC_VERLIM,self:getValue("BQC_VERLIM")) 
        BQC->BQC_PACOOK := _Super:normalizeType(BQC->BQC_PACOOK,self:getValue("BQC_PACOOK")) 
        BQC->BQC_LIQUID := _Super:normalizeType(BQC->BQC_LIQUID,self:getValue("BQC_LIQUID")) 
        BQC->BQC_MESLIQ := _Super:normalizeType(BQC->BQC_MESLIQ,self:getValue("BQC_MESLIQ")) 
        BQC->BQC_VLRMIN := _Super:normalizeType(BQC->BQC_VLRMIN,self:getValue("BQC_VLRMIN")) 
        BQC->BQC_PERMIN := _Super:normalizeType(BQC->BQC_PERMIN,self:getValue("BQC_PERMIN")) 
        BQC->BQC_VLRPAR := _Super:normalizeType(BQC->BQC_VLRPAR,self:getValue("BQC_VLRPAR")) 
        BQC->BQC_PERPAR := _Super:normalizeType(BQC->BQC_PERPAR,self:getValue("BQC_PERPAR")) 
        BQC->BQC_QTSMES := _Super:normalizeType(BQC->BQC_QTSMES,self:getValue("BQC_QTSMES")) 
        BQC->BQC_PERPAT := _Super:normalizeType(BQC->BQC_PERPAT,self:getValue("BQC_PERPAT")) 
        BQC->BQC_CODPAT := _Super:normalizeType(BQC->BQC_CODPAT,self:getValue("BQC_CODPAT")) 
        BQC->BQC_MDFTPT := _Super:normalizeType(BQC->BQC_MDFTPT,self:getValue("BQC_MDFTPT")) 
        BQC->BQC_DIASIN := _Super:normalizeType(BQC->BQC_DIASIN,self:getValue("BQC_DIASIN")) 
        BQC->BQC_CODSB1 := _Super:normalizeType(BQC->BQC_CODSB1,self:getValue("BQC_CODSB1")) 
        BQC->BQC_TABCOP := _Super:normalizeType(BQC->BQC_TABCOP,self:getValue("BQC_TABCOP")) 
        BQC->BQC_BQDEFI := _Super:normalizeType(BQC->BQC_BQDEFI,self:getValue("BQC_BQDEFI")) 
        BQC->BQC_CEINSS := _Super:normalizeType(BQC->BQC_CEINSS,self:getValue("BQC_CEINSS")) 
        BQC->BQC_RECANS := _Super:normalizeType(BQC->BQC_RECANS,self:getValue("BQC_RECANS")) 
        BQC->BQC_CIE309 := _Super:normalizeType(BQC->BQC_CIE309,self:getValue("BQC_CIE309")) 
        BQC->BQC_SEASPL := _Super:normalizeType(BQC->BQC_SEASPL,self:getValue("BQC_SEASPL")) 
        BQC->BQC_RAZSBE := _Super:normalizeType(BQC->BQC_RAZSBE,self:getValue("BQC_RAZSBE")) 
        BQC->BQC_COMAUT := _Super:normalizeType(BQC->BQC_COMAUT,self:getValue("BQC_COMAUT")) 
        BQC->BQC_CAEPF := _Super:normalizeType(BQC->BQC_CAEPF,self:getValue("BQC_CAEPF")) 
        BQC->BQC_CNPADM := _Super:normalizeType(BQC->BQC_CNPADM,self:getValue("BQC_CNPADM")) 

        BQC->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method nextSubCon() Class PLSDaoBqc
    Local lFound := .F.
	Local cQuery := ""
	Local cSubCon := "000000001"

    cQuery := " SELECT MAX(BQC_SUBCON) BQC_SUBCON"
    cQuery += " FROM " + RetSqlName('BQC') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BQC_FILIAL = '" + xFilial("BQC") + "' "
    cQuery += " AND BQC_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_CODIGO")))
    cQuery += " AND BQC_NUMCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_NUMCON")))
    cQuery += " AND BQC_VERCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BQC_VERCON")))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound
        cSubCon := Soma1( (self:getAliasTemp())->BQC_SUBCON )
    EndIf
    self:fechaQuery()
Return cSubCon