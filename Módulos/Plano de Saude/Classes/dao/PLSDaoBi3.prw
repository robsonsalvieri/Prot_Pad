#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBi3 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method getNextCodigo()
    
EndClass

Method New(aFields) Class PLSDaoBi3
	_Super:New(aFields)
    self:cAlias := "BI3"
    self:cfieldOrder := "BI3_VERSAO,BI3_CODINT,BI3_CODIGO"
Return self

Method buscar() Class PLSDaoBi3
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BI3->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBi3
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBi3

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BI3') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BI3_FILIAL = '" + xFilial("BI3") + "' "

    cQuery += " AND BI3_VERSAO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BI3_VERSAO")))
    cQuery += " AND BI3_CODINT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BI3_CODINT")))
    cQuery += " AND BI3_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BI3_CODIGO")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBi3
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBi3

    Default lInclui := .F.

	If BI3->(RecLock("BI3",lInclui))
		
        BI3->BI3_FILIAL := xFilial("BI3")
        If lInclui
        
            BI3->BI3_VERSAO := _Super:normalizeType(BI3->BI3_VERSAO,self:getValue("BI3_VERSAO")) 
            BI3->BI3_CODINT := _Super:normalizeType(BI3->BI3_CODINT,self:getValue("BI3_CODINT")) 
            BI3->BI3_CODIGO := _Super:normalizeType(BI3->BI3_CODIGO,self:getValue("BI3_CODIGO")) 

        EndIf

        BI3->BI3_ALLRED := _Super:normalizeType(BI3->BI3_ALLRED,self:getValue("BI3_ALLRED")) 
        BI3->BI3_ALLCRE := _Super:normalizeType(BI3->BI3_ALLCRE,self:getValue("BI3_ALLCRE")) 
        BI3->BI3_ALLUSR := _Super:normalizeType(BI3->BI3_ALLUSR,self:getValue("BI3_ALLUSR")) 
        BI3->BI3_DESCRI := _Super:normalizeType(BI3->BI3_DESCRI,self:getValue("BI3_DESCRI")) 
        BI3->BI3_NREDUZ := _Super:normalizeType(BI3->BI3_NREDUZ,self:getValue("BI3_NREDUZ")) 
        BI3->BI3_GRUPO := _Super:normalizeType(BI3->BI3_GRUPO,self:getValue("BI3_GRUPO")) 
        BI3->BI3_TIPPLA := _Super:normalizeType(BI3->BI3_TIPPLA,self:getValue("BI3_TIPPLA")) 
        BI3->BI3_TIPO := _Super:normalizeType(BI3->BI3_TIPO,self:getValue("BI3_TIPO")) 
        BI3->BI3_DATINC := _Super:normalizeType(BI3->BI3_DATINC,self:getValue("BI3_DATINC")) 
        BI3->BI3_CODANT := _Super:normalizeType(BI3->BI3_CODANT,self:getValue("BI3_CODANT")) 
        BI3->BI3_STATUS := _Super:normalizeType(BI3->BI3_STATUS,self:getValue("BI3_STATUS")) 
        BI3->BI3_DATBLO := _Super:normalizeType(BI3->BI3_DATBLO,self:getValue("BI3_DATBLO")) 
        BI3->BI3_DESCAR := _Super:normalizeType(BI3->BI3_DESCAR,self:getValue("BI3_DESCAR")) 
        BI3->BI3_TAXDIA := _Super:normalizeType(BI3->BI3_TAXDIA,self:getValue("BI3_TAXDIA")) 
        BI3->BI3_COBJUR := _Super:normalizeType(BI3->BI3_COBJUR,self:getValue("BI3_COBJUR")) 
        BI3->BI3_JURDIA := _Super:normalizeType(BI3->BI3_JURDIA,self:getValue("BI3_JURDIA")) 
        BI3->BI3_NATURE := _Super:normalizeType(BI3->BI3_NATURE,self:getValue("BI3_NATURE")) 
        BI3->BI3_TIPTIT := _Super:normalizeType(BI3->BI3_TIPTIT,self:getValue("BI3_TIPTIT")) 
        BI3->BI3_COBRAT := _Super:normalizeType(BI3->BI3_COBRAT,self:getValue("BI3_COBRAT")) 
        BI3->BI3_RATMAI := _Super:normalizeType(BI3->BI3_RATMAI,self:getValue("BI3_RATMAI")) 
        BI3->BI3_TODOS := _Super:normalizeType(BI3->BI3_TODOS,self:getValue("BI3_TODOS")) 
        BI3->BI3_RATSAI := _Super:normalizeType(BI3->BI3_RATSAI,self:getValue("BI3_RATSAI")) 
        BI3->BI3_SUSEP := _Super:normalizeType(BI3->BI3_SUSEP,self:getValue("BI3_SUSEP")) 
        BI3->BI3_CODSEG := _Super:normalizeType(BI3->BI3_CODSEG,self:getValue("BI3_CODSEG")) 
        BI3->BI3_MODPAG := _Super:normalizeType(BI3->BI3_MODPAG,self:getValue("BI3_MODPAG")) 
        BI3->BI3_APOSRG := _Super:normalizeType(BI3->BI3_APOSRG,self:getValue("BI3_APOSRG")) 
        BI3->BI3_CODACO := _Super:normalizeType(BI3->BI3_CODACO,self:getValue("BI3_CODACO")) 
        BI3->BI3_CPFM := _Super:normalizeType(BI3->BI3_CPFM,self:getValue("BI3_CPFM")) 
        BI3->BI3_ABRANG := _Super:normalizeType(BI3->BI3_ABRANG,self:getValue("BI3_ABRANG")) 
        BI3->BI3_DTRGPR := _Super:normalizeType(BI3->BI3_DTRGPR,self:getValue("BI3_DTRGPR")) 
        BI3->BI3_DTAPPR := _Super:normalizeType(BI3->BI3_DTAPPR,self:getValue("BI3_DTAPPR")) 
        BI3->BI3_ALLOPE := _Super:normalizeType(BI3->BI3_ALLOPE,self:getValue("BI3_ALLOPE")) 
        BI3->BI3_TIPCON := _Super:normalizeType(BI3->BI3_TIPCON,self:getValue("BI3_TIPCON")) 
        BI3->BI3_MUDFAI := _Super:normalizeType(BI3->BI3_MUDFAI,self:getValue("BI3_MUDFAI")) 
        BI3->BI3_ANOMES := _Super:normalizeType(BI3->BI3_ANOMES,self:getValue("BI3_ANOMES")) 
        BI3->BI3_INFCOB := _Super:normalizeType(BI3->BI3_INFCOB,self:getValue("BI3_INFCOB")) 
        BI3->BI3_INFGCB := _Super:normalizeType(BI3->BI3_INFGCB,self:getValue("BI3_INFGCB")) 
        BI3->BI3_INFCBU := _Super:normalizeType(BI3->BI3_INFCBU,self:getValue("BI3_INFCBU")) 
        BI3->BI3_LIMTXA := _Super:normalizeType(BI3->BI3_LIMTXA,self:getValue("BI3_LIMTXA")) 
        BI3->BI3_PADSAU := _Super:normalizeType(BI3->BI3_PADSAU,self:getValue("BI3_PADSAU")) 
        BI3->BI3_MODCON := _Super:normalizeType(BI3->BI3_MODCON,self:getValue("BI3_MODCON")) 
        BI3->BI3_VL2BOL := _Super:normalizeType(BI3->BI3_VL2BOL,self:getValue("BI3_VL2BOL")) 
        BI3->BI3_CODPTU := _Super:normalizeType(BI3->BI3_CODPTU,self:getValue("BI3_CODPTU")) 
        BI3->BI3_CONTA := _Super:normalizeType(BI3->BI3_CONTA,self:getValue("BI3_CONTA")) 
        BI3->BI3_CC := _Super:normalizeType(BI3->BI3_CC,self:getValue("BI3_CC")) 
        BI3->BI3_NATJCO := _Super:normalizeType(BI3->BI3_NATJCO,self:getValue("BI3_NATJCO")) 
        BI3->BI3_IDECAR := _Super:normalizeType(BI3->BI3_IDECAR,self:getValue("BI3_IDECAR")) 
        BI3->BI3_HSPPLA := _Super:normalizeType(BI3->BI3_HSPPLA,self:getValue("BI3_HSPPLA")) 
        BI3->BI3_FATMUL := _Super:normalizeType(BI3->BI3_FATMUL,self:getValue("BI3_FATMUL")) 
        BI3->BI3_RISCO := _Super:normalizeType(BI3->BI3_RISCO,self:getValue("BI3_RISCO")) 
        BI3->BI3_GRUCOM := _Super:normalizeType(BI3->BI3_GRUCOM,self:getValue("BI3_GRUCOM")) 
        BI3->BI3_DESMEN := _Super:normalizeType(BI3->BI3_DESMEN,self:getValue("BI3_DESMEN")) 
        BI3->BI3_COBCPF := _Super:normalizeType(BI3->BI3_COBCPF,self:getValue("BI3_COBCPF")) 
        BI3->BI3_FORFAT := _Super:normalizeType(BI3->BI3_FORFAT,self:getValue("BI3_FORFAT")) 
        BI3->BI3_REEMB := _Super:normalizeType(BI3->BI3_REEMB,self:getValue("BI3_REEMB")) 
        BI3->BI3_CODSB1 := _Super:normalizeType(BI3->BI3_CODSB1,self:getValue("BI3_CODSB1")) 
        BI3->BI3_CODTES := _Super:normalizeType(BI3->BI3_CODTES,self:getValue("BI3_CODTES")) 
        BI3->BI3_SCPA := _Super:normalizeType(BI3->BI3_SCPA,self:getValue("BI3_SCPA")) 
        BI3->BI3_PORTAL := _Super:normalizeType(BI3->BI3_PORTAL,self:getValue("BI3_PORTAL")) 
        BI3->BI3_QTDUS := _Super:normalizeType(BI3->BI3_QTDUS,self:getValue("BI3_QTDUS")) 
        BI3->BI3_REDEDI := _Super:normalizeType(BI3->BI3_REDEDI,self:getValue("BI3_REDEDI")) 
        BI3->BI3_QTDPUS := _Super:normalizeType(BI3->BI3_QTDPUS,self:getValue("BI3_QTDPUS")) 
        BI3->BI3_UNIPUS := _Super:normalizeType(BI3->BI3_UNIPUS,self:getValue("BI3_UNIPUS")) 
        BI3->BI3_CONRPC := _Super:normalizeType(BI3->BI3_CONRPC,self:getValue("BI3_CONRPC")) 
        BI3->BI3_TPCONT := _Super:normalizeType(BI3->BI3_TPCONT,self:getValue("BI3_TPCONT")) 
        BI3->BI3_TPBEN := _Super:normalizeType(BI3->BI3_TPBEN,self:getValue("BI3_TPBEN")) 
        BI3->BI3_ABRCAR := _Super:normalizeType(BI3->BI3_ABRCAR,self:getValue("BI3_ABRCAR")) 
        BI3->BI3_SITANS := _Super:normalizeType(BI3->BI3_SITANS,self:getValue("BI3_SITANS")) 
        BI3->BI3_CLAPLS := _Super:normalizeType(BI3->BI3_CLAPLS,self:getValue("BI3_CLAPLS")) 
        BI3->BI3_REDREF := _Super:normalizeType(BI3->BI3_REDREF,self:getValue("BI3_REDREF")) 
        BI3->BI3_GUIMED := _Super:normalizeType(BI3->BI3_GUIMED,self:getValue("BI3_GUIMED")) 
        BI3->BI3_TPFORN := _Super:normalizeType(BI3->BI3_TPFORN,self:getValue("BI3_TPFORN")) 
        BI3->BI3_INFANS := _Super:normalizeType(BI3->BI3_INFANS,self:getValue("BI3_INFANS")) 
        BI3->BI3_TPREDI := _Super:normalizeType(BI3->BI3_TPREDI,self:getValue("BI3_TPREDI")) 
        BI3->BI3_MXDRMB := _Super:normalizeType(BI3->BI3_MXDRMB,self:getValue("BI3_MXDRMB")) 
        BI3->BI3_VMIRMB := _Super:normalizeType(BI3->BI3_VMIRMB,self:getValue("BI3_VMIRMB")) 
        BI3->BI3_TABCOP := _Super:normalizeType(BI3->BI3_TABCOP,self:getValue("BI3_TABCOP")) 
        BI3->BI3_RRFDES := _Super:normalizeType(BI3->BI3_RRFDES,self:getValue("BI3_RRFDES")) 
        BI3->BI3_LATEDI := _Super:normalizeType(BI3->BI3_LATEDI,self:getValue("BI3_LATEDI")) 
        BI3->BI3_CLASSE := _Super:normalizeType(BI3->BI3_CLASSE,self:getValue("BI3_CLASSE")) 
        BI3->BI3_MOTDOC := _Super:normalizeType(BI3->BI3_MOTDOC,self:getValue("BI3_MOTDOC")) 
        BI3->BI3_DROGAR := _Super:normalizeType(BI3->BI3_DROGAR,self:getValue("BI3_DROGAR")) 
        BI3->BI3_TIPRED := _Super:normalizeType(BI3->BI3_TIPRED,self:getValue("BI3_TIPRED")) 
        BI3->BI3_EMPIND := _Super:normalizeType(BI3->BI3_EMPIND,self:getValue("BI3_EMPIND")) 

        BI3->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method getNextCodigo() Class PLSDaoBi3
    Local cCodVid := BI3->(GetSx8Num("BI3","BI3_CODIGO"))
    BI3->(ConfirmSX8())
Return cCodVid