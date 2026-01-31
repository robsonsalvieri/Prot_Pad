#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBts from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method getNextMatVid()
    
EndClass

Method New(aFields) Class PLSDaoBts
	_Super:New(aFields)
    self:cAlias := "BTS"
    self:cfieldOrder := "BTS_MATVID"
Return self

Method buscar() Class PLSDaoBts
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BTS->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBts
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBts

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BTS') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BTS_FILIAL = '" + xFilial("BTS") + "' "

    cQuery += " AND BTS_MATVID = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BTS_MATVID")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBts
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBts

    Default lInclui := .F.

	If BTS->(RecLock("BTS",lInclui))
		
        BTS->BTS_FILIAL := xFilial("BTS")
        If lInclui
        
            BTS->BTS_MATVID := _Super:normalizeType(BTS->BTS_MATVID,self:getValue("BTS_MATVID")) 

        EndIf

        BTS->BTS_NOMUSR := _Super:normalizeType(BTS->BTS_NOMUSR,self:getValue("BTS_NOMUSR")) 
        BTS->BTS_SOBRN := _Super:normalizeType(BTS->BTS_SOBRN,self:getValue("BTS_SOBRN")) 
        BTS->BTS_NOMCAR := _Super:normalizeType(BTS->BTS_NOMCAR,self:getValue("BTS_NOMCAR")) 
        BTS->BTS_DATNAS := _Super:normalizeType(BTS->BTS_DATNAS,self:getValue("BTS_DATNAS")) 
        BTS->BTS_SEXO := _Super:normalizeType(BTS->BTS_SEXO,self:getValue("BTS_SEXO")) 
        BTS->BTS_ESTCIV := _Super:normalizeType(BTS->BTS_ESTCIV,self:getValue("BTS_ESTCIV")) 
        BTS->BTS_CPFUSR := _Super:normalizeType(BTS->BTS_CPFUSR,self:getValue("BTS_CPFUSR")) 
        BTS->BTS_PISPAS := _Super:normalizeType(BTS->BTS_PISPAS,self:getValue("BTS_PISPAS")) 
        BTS->BTS_DRGUSR := _Super:normalizeType(BTS->BTS_DRGUSR,self:getValue("BTS_DRGUSR")) 
        BTS->BTS_ORGEM := _Super:normalizeType(BTS->BTS_ORGEM,self:getValue("BTS_ORGEM")) 
        BTS->BTS_RGEST := _Super:normalizeType(BTS->BTS_RGEST,self:getValue("BTS_RGEST")) 
        BTS->BTS_NRCRNA := _Super:normalizeType(BTS->BTS_NRCRNA,self:getValue("BTS_NRCRNA")) 
        BTS->BTS_ORIEND := _Super:normalizeType(BTS->BTS_ORIEND,self:getValue("BTS_ORIEND")) 
        BTS->BTS_RELAOP := _Super:normalizeType(BTS->BTS_RELAOP,self:getValue("BTS_RELAOP")) 
        BTS->BTS_CEPUSR := _Super:normalizeType(BTS->BTS_CEPUSR,self:getValue("BTS_CEPUSR")) 
        BTS->BTS_ENDERE := _Super:normalizeType(BTS->BTS_ENDERE,self:getValue("BTS_ENDERE")) 
        BTS->BTS_NR_END := _Super:normalizeType(BTS->BTS_NR_END,self:getValue("BTS_NR_END")) 
        BTS->BTS_COMEND := _Super:normalizeType(BTS->BTS_COMEND,self:getValue("BTS_COMEND")) 
        BTS->BTS_BAIRRO := _Super:normalizeType(BTS->BTS_BAIRRO,self:getValue("BTS_BAIRRO")) 
        BTS->BTS_CODMUN := _Super:normalizeType(BTS->BTS_CODMUN,self:getValue("BTS_CODMUN")) 
        BTS->BTS_MUNICI := _Super:normalizeType(BTS->BTS_MUNICI,self:getValue("BTS_MUNICI")) 
        BTS->BTS_ESTADO := _Super:normalizeType(BTS->BTS_ESTADO,self:getValue("BTS_ESTADO")) 
        BTS->BTS_DDD := _Super:normalizeType(BTS->BTS_DDD,self:getValue("BTS_DDD")) 
        BTS->BTS_TELEFO := _Super:normalizeType(BTS->BTS_TELEFO,self:getValue("BTS_TELEFO")) 
        BTS->BTS_UNIVER := _Super:normalizeType(BTS->BTS_UNIVER,self:getValue("BTS_UNIVER")) 
        BTS->BTS_INTERD := _Super:normalizeType(BTS->BTS_INTERD,self:getValue("BTS_INTERD")) 
        BTS->BTS_CORNAT := _Super:normalizeType(BTS->BTS_CORNAT,self:getValue("BTS_CORNAT")) 
        BTS->BTS_SANGUE := _Super:normalizeType(BTS->BTS_SANGUE,self:getValue("BTS_SANGUE")) 
        BTS->BTS_BITMAP := _Super:normalizeType(BTS->BTS_BITMAP,self:getValue("BTS_BITMAP")) 
        BTS->BTS_CODFUN := _Super:normalizeType(BTS->BTS_CODFUN,self:getValue("BTS_CODFUN")) 
        BTS->BTS_INSALU := _Super:normalizeType(BTS->BTS_INSALU,self:getValue("BTS_INSALU")) 
        BTS->BTS_CODSET := _Super:normalizeType(BTS->BTS_CODSET,self:getValue("BTS_CODSET")) 
        BTS->BTS_PESO := _Super:normalizeType(BTS->BTS_PESO,self:getValue("BTS_PESO")) 
        BTS->BTS_ALTURA := _Super:normalizeType(BTS->BTS_ALTURA,self:getValue("BTS_ALTURA")) 
        BTS->BTS_OBESO := _Super:normalizeType(BTS->BTS_OBESO,self:getValue("BTS_OBESO")) 
        BTS->BTS_EMAIL := _Super:normalizeType(BTS->BTS_EMAIL,self:getValue("BTS_EMAIL")) 
        BTS->BTS_CODREL := _Super:normalizeType(BTS->BTS_CODREL,self:getValue("BTS_CODREL")) 
        BTS->BTS_TUTELA := _Super:normalizeType(BTS->BTS_TUTELA,self:getValue("BTS_TUTELA")) 
        BTS->BTS_DEFFIS := _Super:normalizeType(BTS->BTS_DEFFIS,self:getValue("BTS_DEFFIS")) 
        BTS->BTS_INVALI := _Super:normalizeType(BTS->BTS_INVALI,self:getValue("BTS_INVALI")) 
        BTS->BTS_DATOBI := _Super:normalizeType(BTS->BTS_DATOBI,self:getValue("BTS_DATOBI")) 
        BTS->BTS_DATMAE := _Super:normalizeType(BTS->BTS_DATMAE,self:getValue("BTS_DATMAE")) 
        BTS->BTS_MAE := _Super:normalizeType(BTS->BTS_MAE,self:getValue("BTS_MAE")) 
        BTS->BTS_CPFMAE := _Super:normalizeType(BTS->BTS_CPFMAE,self:getValue("BTS_CPFMAE")) 
        BTS->BTS_PAI := _Super:normalizeType(BTS->BTS_PAI,self:getValue("BTS_PAI")) 
        BTS->BTS_DATPAI := _Super:normalizeType(BTS->BTS_DATPAI,self:getValue("BTS_DATPAI")) 
        BTS->BTS_CPFPAI := _Super:normalizeType(BTS->BTS_CPFPAI,self:getValue("BTS_CPFPAI")) 
        BTS->BTS_NOMPRE := _Super:normalizeType(BTS->BTS_NOMPRE,self:getValue("BTS_NOMPRE")) 
        BTS->BTS_DATCPT := _Super:normalizeType(BTS->BTS_DATCPT,self:getValue("BTS_DATCPT")) 
        BTS->BTS_CPFPRE := _Super:normalizeType(BTS->BTS_CPFPRE,self:getValue("BTS_CPFPRE")) 
        BTS->BTS_DOADOR := _Super:normalizeType(BTS->BTS_DOADOR,self:getValue("BTS_DOADOR")) 
        BTS->BTS_NACION := _Super:normalizeType(BTS->BTS_NACION,self:getValue("BTS_NACION")) 
        BTS->BTS_CDIDEN := _Super:normalizeType(BTS->BTS_CDIDEN,self:getValue("BTS_CDIDEN")) 
        BTS->BTS_CDPAIS := _Super:normalizeType(BTS->BTS_CDPAIS,self:getValue("BTS_CDPAIS")) 
        BTS->BTS_NMPAIS := _Super:normalizeType(BTS->BTS_NMPAIS,self:getValue("BTS_NMPAIS")) 
        BTS->BTS_ORGEMI := _Super:normalizeType(BTS->BTS_ORGEMI,self:getValue("BTS_ORGEMI")) 
        BTS->BTS_NOMRED := _Super:normalizeType(BTS->BTS_NOMRED,self:getValue("BTS_NOMRED")) 
        BTS->BTS_DENAVI := _Super:normalizeType(BTS->BTS_DENAVI,self:getValue("BTS_DENAVI")) 
        BTS->BTS_TIPPES := _Super:normalizeType(BTS->BTS_TIPPES,self:getValue("BTS_TIPPES")) 
        BTS->BTS_NOMFAN := _Super:normalizeType(BTS->BTS_NOMFAN,self:getValue("BTS_NOMFAN")) 
        BTS->BTS_INSCES := _Super:normalizeType(BTS->BTS_INSCES,self:getValue("BTS_INSCES")) 
        BTS->BTS_NUMFAX := _Super:normalizeType(BTS->BTS_NUMFAX,self:getValue("BTS_NUMFAX")) 
        BTS->BTS_DTINC := _Super:normalizeType(BTS->BTS_DTINC,self:getValue("BTS_DTINC")) 
        BTS->BTS_INSCMU := _Super:normalizeType(BTS->BTS_INSCMU,self:getValue("BTS_INSCMU")) 
        BTS->BTS_PAGWEB := _Super:normalizeType(BTS->BTS_PAGWEB,self:getValue("BTS_PAGWEB")) 
        BTS->BTS_CNESPE := _Super:normalizeType(BTS->BTS_CNESPE,self:getValue("BTS_CNESPE")) 
        BTS->BTS_SIGLCR := _Super:normalizeType(BTS->BTS_SIGLCR,self:getValue("BTS_SIGLCR")) 
        BTS->BTS_SIGCR2 := _Super:normalizeType(BTS->BTS_SIGCR2,self:getValue("BTS_SIGCR2")) 
        BTS->BTS_ESTACR := _Super:normalizeType(BTS->BTS_ESTACR,self:getValue("BTS_ESTACR")) 
        BTS->BTS_ESTCR2 := _Super:normalizeType(BTS->BTS_ESTCR2,self:getValue("BTS_ESTCR2")) 
        BTS->BTS_NUMECR := _Super:normalizeType(BTS->BTS_NUMECR,self:getValue("BTS_NUMECR")) 
        BTS->BTS_DTINSC := _Super:normalizeType(BTS->BTS_DTINSC,self:getValue("BTS_DTINSC")) 
        BTS->BTS_NUMCR2 := _Super:normalizeType(BTS->BTS_NUMCR2,self:getValue("BTS_NUMCR2")) 
        BTS->BTS_DTINS2 := _Super:normalizeType(BTS->BTS_DTINS2,self:getValue("BTS_DTINS2")) 
        BTS->BTS_RGIDCV := _Super:normalizeType(BTS->BTS_RGIDCV,self:getValue("BTS_RGIDCV")) 
        BTS->BTS_TITELE := _Super:normalizeType(BTS->BTS_TITELE,self:getValue("BTS_TITELE")) 
        BTS->BTS_COMUNI := _Super:normalizeType(BTS->BTS_COMUNI,self:getValue("BTS_COMUNI")) 
        BTS->BTS_CDMNAS := _Super:normalizeType(BTS->BTS_CDMNAS,self:getValue("BTS_CDMNAS")) 
        BTS->BTS_MUNNAS := _Super:normalizeType(BTS->BTS_MUNNAS,self:getValue("BTS_MUNNAS")) 
        BTS->BTS_ESTNAS := _Super:normalizeType(BTS->BTS_ESTNAS,self:getValue("BTS_ESTNAS")) 
        BTS->BTS_BANCO := _Super:normalizeType(BTS->BTS_BANCO,self:getValue("BTS_BANCO")) 
        BTS->BTS_TIPEND := _Super:normalizeType(BTS->BTS_TIPEND,self:getValue("BTS_TIPEND")) 
        BTS->BTS_MUNRES := _Super:normalizeType(BTS->BTS_MUNRES,self:getValue("BTS_MUNRES")) 
        BTS->BTS_AGENC := _Super:normalizeType(BTS->BTS_AGENC,self:getValue("BTS_AGENC")) 
        BTS->BTS_RESEXT := _Super:normalizeType(BTS->BTS_RESEXT,self:getValue("BTS_RESEXT")) 
        BTS->BTS_CONTA := _Super:normalizeType(BTS->BTS_CONTA,self:getValue("BTS_CONTA")) 
        BTS->BTS_DATADT := _Super:normalizeType(BTS->BTS_DATADT,self:getValue("BTS_DATADT")) 
        BTS->BTS_DATSOC := _Super:normalizeType(BTS->BTS_DATSOC,self:getValue("BTS_DATSOC")) 
        BTS->BTS_NOMSOC := _Super:normalizeType(BTS->BTS_NOMSOC,self:getValue("BTS_NOMSOC")) 
        BTS->BTS_USASOC := _Super:normalizeType(BTS->BTS_USASOC,self:getValue("BTS_USASOC")) 
        BTS->BTS_TIPTEL := _Super:normalizeType(BTS->BTS_TIPTEL,self:getValue("BTS_TIPTEL")) 
        BTS->BTS_GENSOC := _Super:normalizeType(BTS->BTS_GENSOC,self:getValue("BTS_GENSOC")) 

        BTS->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method getNextMatVid() Class PLSDaoBts
    Local cCodVid := BTS->(GetSx8Num("BTS","BTS_MATVID"))
    BTS->(ConfirmSX8())
Return cCodVid