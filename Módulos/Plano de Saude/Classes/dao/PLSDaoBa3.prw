#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBa3 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class PLSDaoBa3
	_Super:New(aFields)
    self:cAlias := "BA3"
    self:cfieldOrder := "BA3_CODINT,BA3_CODEMP,BA3_CONEMP,BA3_VERCON,BA3_SUBCON,BA3_VERSUB,BA3_MATRIC"
Return self

Method buscar() Class PLSDaoBa3
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BA3->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBa3
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBa3

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BA3') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BA3_FILIAL = '" + xFilial("BA3") + "' "

    cQuery += " AND BA3_CODINT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA3_CODINT")))
    cQuery += " AND BA3_CODEMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA3_CODEMP")))
    cQuery += " AND BA3_CONEMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA3_CONEMP")))
    cQuery += " AND BA3_VERCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA3_VERCON")))
    cQuery += " AND BA3_SUBCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA3_SUBCON")))
    cQuery += " AND BA3_VERSUB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA3_VERSUB")))
    cQuery += " AND BA3_MATRIC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA3_MATRIC")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBa3
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBa3

    Default lInclui := .F.

	If BA3->(RecLock("BA3",lInclui))
		
        BA3->BA3_FILIAL := xFilial("BA3")
        If lInclui
        
            BA3->BA3_CODINT := _Super:normalizeType(BA3->BA3_CODINT,self:getValue("BA3_CODINT")) 
            BA3->BA3_CODEMP := _Super:normalizeType(BA3->BA3_CODEMP,self:getValue("BA3_CODEMP")) 
            BA3->BA3_CONEMP := _Super:normalizeType(BA3->BA3_CONEMP,self:getValue("BA3_CONEMP")) 
            BA3->BA3_VERCON := _Super:normalizeType(BA3->BA3_VERCON,self:getValue("BA3_VERCON")) 
            BA3->BA3_SUBCON := _Super:normalizeType(BA3->BA3_SUBCON,self:getValue("BA3_SUBCON")) 
            BA3->BA3_VERSUB := _Super:normalizeType(BA3->BA3_VERSUB,self:getValue("BA3_VERSUB")) 
            BA3->BA3_MATRIC := _Super:normalizeType(BA3->BA3_MATRIC,self:getValue("BA3_MATRIC")) 

        EndIf

        BA3->BA3_NUMCON := _Super:normalizeType(BA3->BA3_NUMCON,self:getValue("BA3_NUMCON")) 
        BA3->BA3_MATEMP := _Super:normalizeType(BA3->BA3_MATEMP,self:getValue("BA3_MATEMP")) 
        BA3->BA3_MATANT := _Super:normalizeType(BA3->BA3_MATANT,self:getValue("BA3_MATANT")) 
        BA3->BA3_HORACN := _Super:normalizeType(BA3->BA3_HORACN,self:getValue("BA3_HORACN")) 
        BA3->BA3_COBNIV := _Super:normalizeType(BA3->BA3_COBNIV,self:getValue("BA3_COBNIV")) 
        BA3->BA3_VENCTO := _Super:normalizeType(BA3->BA3_VENCTO,self:getValue("BA3_VENCTO")) 
        BA3->BA3_DATBAS := _Super:normalizeType(BA3->BA3_DATBAS,self:getValue("BA3_DATBAS")) 
        BA3->BA3_PODREM := _Super:normalizeType(BA3->BA3_PODREM,self:getValue("BA3_PODREM")) 
        BA3->BA3_DATCIV := _Super:normalizeType(BA3->BA3_DATCIV,self:getValue("BA3_DATCIV")) 
        BA3->BA3_MESREA := _Super:normalizeType(BA3->BA3_MESREA,self:getValue("BA3_MESREA")) 
        BA3->BA3_INDREA := _Super:normalizeType(BA3->BA3_INDREA,self:getValue("BA3_INDREA")) 
        BA3->BA3_CODCLI := _Super:normalizeType(BA3->BA3_CODCLI,self:getValue("BA3_CODCLI")) 
        BA3->BA3_LOJA := _Super:normalizeType(BA3->BA3_LOJA,self:getValue("BA3_LOJA")) 
        BA3->BA3_TIPOUS := _Super:normalizeType(BA3->BA3_TIPOUS,self:getValue("BA3_TIPOUS")) 
        BA3->BA3_NATURE := _Super:normalizeType(BA3->BA3_NATURE,self:getValue("BA3_NATURE")) 
        BA3->BA3_CODFOR := _Super:normalizeType(BA3->BA3_CODFOR,self:getValue("BA3_CODFOR")) 
        BA3->BA3_LOJFOR := _Super:normalizeType(BA3->BA3_LOJFOR,self:getValue("BA3_LOJFOR")) 
        BA3->BA3_MOTBLO := _Super:normalizeType(BA3->BA3_MOTBLO,self:getValue("BA3_MOTBLO")) 
        BA3->BA3_DATBLO := _Super:normalizeType(BA3->BA3_DATBLO,self:getValue("BA3_DATBLO")) 
        BA3->BA3_CODPLA := _Super:normalizeType(BA3->BA3_CODPLA,self:getValue("BA3_CODPLA")) 
        BA3->BA3_VERSAO := _Super:normalizeType(BA3->BA3_VERSAO,self:getValue("BA3_VERSAO")) 
        BA3->BA3_FORPAG := _Super:normalizeType(BA3->BA3_FORPAG,self:getValue("BA3_FORPAG")) 
        BA3->BA3_TIPCON := _Super:normalizeType(BA3->BA3_TIPCON,self:getValue("BA3_TIPCON")) 
        BA3->BA3_SEGPLA := _Super:normalizeType(BA3->BA3_SEGPLA,self:getValue("BA3_SEGPLA")) 
        BA3->BA3_MODPAG := _Super:normalizeType(BA3->BA3_MODPAG,self:getValue("BA3_MODPAG")) 
        BA3->BA3_FORCTX := _Super:normalizeType(BA3->BA3_FORCTX,self:getValue("BA3_FORCTX")) 
        BA3->BA3_TXUSU := _Super:normalizeType(BA3->BA3_TXUSU,self:getValue("BA3_TXUSU")) 
        BA3->BA3_FORCOP := _Super:normalizeType(BA3->BA3_FORCOP,self:getValue("BA3_FORCOP")) 
        BA3->BA3_AGMTFU := _Super:normalizeType(BA3->BA3_AGMTFU,self:getValue("BA3_AGMTFU")) 
        BA3->BA3_APLEI := _Super:normalizeType(BA3->BA3_APLEI,self:getValue("BA3_APLEI")) 
        BA3->BA3_AGFTFU := _Super:normalizeType(BA3->BA3_AGFTFU,self:getValue("BA3_AGFTFU")) 
        BA3->BA3_VALSAL := _Super:normalizeType(BA3->BA3_VALSAL,self:getValue("BA3_VALSAL")) 
        BA3->BA3_ROTSAL := _Super:normalizeType(BA3->BA3_ROTSAL,self:getValue("BA3_ROTSAL")) 
        BA3->BA3_EQUIPE := _Super:normalizeType(BA3->BA3_EQUIPE,self:getValue("BA3_EQUIPE")) 
        BA3->BA3_CODVEN := _Super:normalizeType(BA3->BA3_CODVEN,self:getValue("BA3_CODVEN")) 
        BA3->BA3_ENDCOB := _Super:normalizeType(BA3->BA3_ENDCOB,self:getValue("BA3_ENDCOB")) 
        BA3->BA3_CEP := _Super:normalizeType(BA3->BA3_CEP,self:getValue("BA3_CEP")) 
        BA3->BA3_END := _Super:normalizeType(BA3->BA3_END,self:getValue("BA3_END")) 
        BA3->BA3_NUMERO := _Super:normalizeType(BA3->BA3_NUMERO,self:getValue("BA3_NUMERO")) 
        BA3->BA3_COMPLE := _Super:normalizeType(BA3->BA3_COMPLE,self:getValue("BA3_COMPLE")) 
        BA3->BA3_BAIRRO := _Super:normalizeType(BA3->BA3_BAIRRO,self:getValue("BA3_BAIRRO")) 
        BA3->BA3_CODMUN := _Super:normalizeType(BA3->BA3_CODMUN,self:getValue("BA3_CODMUN")) 
        BA3->BA3_MUN := _Super:normalizeType(BA3->BA3_MUN,self:getValue("BA3_MUN")) 
        BA3->BA3_ESTADO := _Super:normalizeType(BA3->BA3_ESTADO,self:getValue("BA3_ESTADO")) 
        BA3->BA3_USUOPE := _Super:normalizeType(BA3->BA3_USUOPE,self:getValue("BA3_USUOPE")) 
        BA3->BA3_DATCON := _Super:normalizeType(BA3->BA3_DATCON,self:getValue("BA3_DATCON")) 
        BA3->BA3_HORCON := _Super:normalizeType(BA3->BA3_HORCON,self:getValue("BA3_HORCON")) 
        BA3->BA3_GRPCOB := _Super:normalizeType(BA3->BA3_GRPCOB,self:getValue("BA3_GRPCOB")) 
        BA3->BA3_CODTDE := _Super:normalizeType(BA3->BA3_CODTDE,self:getValue("BA3_CODTDE")) 
        BA3->BA3_DESMUN := _Super:normalizeType(BA3->BA3_DESMUN,self:getValue("BA3_DESMUN")) 
        BA3->BA3_RGIMP := _Super:normalizeType(BA3->BA3_RGIMP,self:getValue("BA3_RGIMP")) 
        BA3->BA3_DEMITI := _Super:normalizeType(BA3->BA3_DEMITI,self:getValue("BA3_DEMITI")) 
        BA3->BA3_DATDEM := _Super:normalizeType(BA3->BA3_DATDEM,self:getValue("BA3_DATDEM")) 
        BA3->BA3_MOTDEM := _Super:normalizeType(BA3->BA3_MOTDEM,self:getValue("BA3_MOTDEM")) 
        BA3->BA3_LIMATE := _Super:normalizeType(BA3->BA3_LIMATE,self:getValue("BA3_LIMATE")) 
        BA3->BA3_ABRANG := _Super:normalizeType(BA3->BA3_ABRANG,self:getValue("BA3_ABRANG")) 
        BA3->BA3_INFCOB := _Super:normalizeType(BA3->BA3_INFCOB,self:getValue("BA3_INFCOB")) 
        BA3->BA3_INFGCB := _Super:normalizeType(BA3->BA3_INFGCB,self:getValue("BA3_INFGCB")) 
        BA3->BA3_IMPORT := _Super:normalizeType(BA3->BA3_IMPORT,self:getValue("BA3_IMPORT")) 
        BA3->BA3_VALANT := _Super:normalizeType(BA3->BA3_VALANT,self:getValue("BA3_VALANT")) 
        BA3->BA3_LETANT := _Super:normalizeType(BA3->BA3_LETANT,self:getValue("BA3_LETANT")) 
        BA3->BA3_DATALT := _Super:normalizeType(BA3->BA3_DATALT,self:getValue("BA3_DATALT")) 
        BA3->BA3_COBRAT := _Super:normalizeType(BA3->BA3_COBRAT,self:getValue("BA3_COBRAT")) 
        BA3->BA3_RATMAI := _Super:normalizeType(BA3->BA3_RATMAI,self:getValue("BA3_RATMAI")) 
        BA3->BA3_COBRET := _Super:normalizeType(BA3->BA3_COBRET,self:getValue("BA3_COBRET")) 
        BA3->BA3_DIARET := _Super:normalizeType(BA3->BA3_DIARET,self:getValue("BA3_DIARET")) 
        BA3->BA3_ULTCOB := _Super:normalizeType(BA3->BA3_ULTCOB,self:getValue("BA3_ULTCOB")) 
        BA3->BA3_RATSAI := _Super:normalizeType(BA3->BA3_RATSAI,self:getValue("BA3_RATSAI")) 
        BA3->BA3_NUMCOB := _Super:normalizeType(BA3->BA3_NUMCOB,self:getValue("BA3_NUMCOB")) 
        BA3->BA3_ULREA := _Super:normalizeType(BA3->BA3_ULREA,self:getValue("BA3_ULREA")) 
        BA3->BA3_CARIMP := _Super:normalizeType(BA3->BA3_CARIMP,self:getValue("BA3_CARIMP")) 
        BA3->BA3_PERMOV := _Super:normalizeType(BA3->BA3_PERMOV,self:getValue("BA3_PERMOV")) 
        BA3->BA3_NIVFOR := _Super:normalizeType(BA3->BA3_NIVFOR,self:getValue("BA3_NIVFOR")) 
        BA3->BA3_NIVFTX := _Super:normalizeType(BA3->BA3_NIVFTX,self:getValue("BA3_NIVFTX")) 
        BA3->BA3_NIVFOP := _Super:normalizeType(BA3->BA3_NIVFOP,self:getValue("BA3_NIVFOP")) 
        BA3->BA3_OUTLAN := _Super:normalizeType(BA3->BA3_OUTLAN,self:getValue("BA3_OUTLAN")) 
        BA3->BA3_MATFMB := _Super:normalizeType(BA3->BA3_MATFMB,self:getValue("BA3_MATFMB")) 
        BA3->BA3_CODACO := _Super:normalizeType(BA3->BA3_CODACO,self:getValue("BA3_CODACO")) 
        BA3->BA3_TRAORI := _Super:normalizeType(BA3->BA3_TRAORI,self:getValue("BA3_TRAORI")) 
        BA3->BA3_TRADES := _Super:normalizeType(BA3->BA3_TRADES,self:getValue("BA3_TRADES")) 
        BA3->BA3_ROTINA := _Super:normalizeType(BA3->BA3_ROTINA,self:getValue("BA3_ROTINA")) 
        BA3->BA3_VALID := _Super:normalizeType(BA3->BA3_VALID,self:getValue("BA3_VALID")) 
        BA3->BA3_DATPLA := _Super:normalizeType(BA3->BA3_DATPLA,self:getValue("BA3_DATPLA")) 
        BA3->BA3_DESLIG := _Super:normalizeType(BA3->BA3_DESLIG,self:getValue("BA3_DESLIG")) 
        BA3->BA3_DATDES := _Super:normalizeType(BA3->BA3_DATDES,self:getValue("BA3_DATDES")) 
        BA3->BA3_LOTTRA := _Super:normalizeType(BA3->BA3_LOTTRA,self:getValue("BA3_LOTTRA")) 
        BA3->BA3_BLOFAT := _Super:normalizeType(BA3->BA3_BLOFAT,self:getValue("BA3_BLOFAT")) 
        BA3->BA3_CODRDA := _Super:normalizeType(BA3->BA3_CODRDA,self:getValue("BA3_CODRDA")) 
        BA3->BA3_CODLAN := _Super:normalizeType(BA3->BA3_CODLAN,self:getValue("BA3_CODLAN")) 
        BA3->BA3_TIPPAG := _Super:normalizeType(BA3->BA3_TIPPAG,self:getValue("BA3_TIPPAG")) 
        BA3->BA3_BCOCLI := _Super:normalizeType(BA3->BA3_BCOCLI,self:getValue("BA3_BCOCLI")) 
        BA3->BA3_AGECLI := _Super:normalizeType(BA3->BA3_AGECLI,self:getValue("BA3_AGECLI")) 
        BA3->BA3_CTACLI := _Super:normalizeType(BA3->BA3_CTACLI,self:getValue("BA3_CTACLI")) 
        BA3->BA3_LIMITE := _Super:normalizeType(BA3->BA3_LIMITE,self:getValue("BA3_LIMITE")) 
        BA3->BA3_PORTAD := _Super:normalizeType(BA3->BA3_PORTAD,self:getValue("BA3_PORTAD")) 
        BA3->BA3_AGEDEP := _Super:normalizeType(BA3->BA3_AGEDEP,self:getValue("BA3_AGEDEP")) 
        BA3->BA3_CTACOR := _Super:normalizeType(BA3->BA3_CTACOR,self:getValue("BA3_CTACOR")) 
        BA3->BA3_DESMEN := _Super:normalizeType(BA3->BA3_DESMEN,self:getValue("BA3_DESMEN")) 
        BA3->BA3_CODVE2 := _Super:normalizeType(BA3->BA3_CODVE2,self:getValue("BA3_CODVE2")) 
        BA3->BA3_CONSID := _Super:normalizeType(BA3->BA3_CONSID,self:getValue("BA3_CONSID")) 
        BA3->BA3_PADSAU := _Super:normalizeType(BA3->BA3_PADSAU,self:getValue("BA3_PADSAU")) 
        BA3->BA3_PLPOR := _Super:normalizeType(BA3->BA3_PLPOR,self:getValue("BA3_PLPOR")) 
        BA3->BA3_AGLUT := _Super:normalizeType(BA3->BA3_AGLUT,self:getValue("BA3_AGLUT")) 
        BA3->BA3_PACOOK := _Super:normalizeType(BA3->BA3_PACOOK,self:getValue("BA3_PACOOK")) 
        BA3->BA3_DIASIN := _Super:normalizeType(BA3->BA3_DIASIN,self:getValue("BA3_DIASIN")) 
        BA3->BA3_CODTES := _Super:normalizeType(BA3->BA3_CODTES,self:getValue("BA3_CODTES")) 
        BA3->BA3_CODSB1 := _Super:normalizeType(BA3->BA3_CODSB1,self:getValue("BA3_CODSB1")) 
        BA3->BA3_REEWEB := _Super:normalizeType(BA3->BA3_REEWEB,self:getValue("BA3_REEWEB")) 
        BA3->BA3_GRPFAM := _Super:normalizeType(BA3->BA3_GRPFAM,self:getValue("BA3_GRPFAM")) 
        BA3->BA3_TIPPGO := _Super:normalizeType(BA3->BA3_TIPPGO,self:getValue("BA3_TIPPGO")) 
        BA3->BA3_UNDORG := _Super:normalizeType(BA3->BA3_UNDORG,self:getValue("BA3_UNDORG")) 
        BA3->BA3_NOTB := _Super:normalizeType(BA3->BA3_NOTB,self:getValue("BA3_NOTB")) 
        BA3->BA3_COMAUT := _Super:normalizeType(BA3->BA3_COMAUT,self:getValue("BA3_COMAUT")) 
        BA3->BA3_TIPVIN := _Super:normalizeType(BA3->BA3_TIPVIN,self:getValue("BA3_TIPVIN")) 
        BA3->BA3_CODRAS := _Super:normalizeType(BA3->BA3_CODRAS,self:getValue("BA3_CODRAS")) 

        BA3->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
