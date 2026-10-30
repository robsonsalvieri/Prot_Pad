#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBa1 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method getNextMatric()
    Method nextTipReg()
    Method matByCco(cCodCco)
    
EndClass

Method New(aFields) Class PLSDaoBa1
	_Super:New(aFields)
    self:cAlias := "BA1"
    self:cfieldOrder := "BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_TIPUSU"
Return self

Method buscar() Class PLSDaoBa1
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BA1->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBa1
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBa1

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BA1') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BA1_FILIAL = '" + xFilial("BA1") + "' "

    cQuery += " AND BA1_CODINT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_CODINT")))
    cQuery += " AND BA1_CODEMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_CODEMP")))
    cQuery += " AND BA1_MATRIC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_MATRIC")))
    cQuery += " AND BA1_TIPREG = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_TIPREG")))
    cQuery += " AND BA1_DIGITO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_DIGITO")))
    cQuery += " AND BA1_TIPUSU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_TIPUSU")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBa1
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBa1

    Default lInclui := .F.

	If BA1->(RecLock("BA1",lInclui))
		
        BA1->BA1_FILIAL := xFilial("BA1")
        If lInclui
        
            BA1->BA1_CODINT := _Super:normalizeType(BA1->BA1_CODINT,self:getValue("BA1_CODINT")) 
            BA1->BA1_CODEMP := _Super:normalizeType(BA1->BA1_CODEMP,self:getValue("BA1_CODEMP")) 
            BA1->BA1_MATRIC := _Super:normalizeType(BA1->BA1_MATRIC,self:getValue("BA1_MATRIC")) 
            BA1->BA1_TIPREG := _Super:normalizeType(BA1->BA1_TIPREG,self:getValue("BA1_TIPREG")) 
            BA1->BA1_DIGITO := _Super:normalizeType(BA1->BA1_DIGITO,self:getValue("BA1_DIGITO")) 
            BA1->BA1_TIPUSU := _Super:normalizeType(BA1->BA1_TIPUSU,self:getValue("BA1_TIPUSU")) 

        EndIf

        BA1->BA1_CONEMP := _Super:normalizeType(BA1->BA1_CONEMP,self:getValue("BA1_CONEMP")) 
        BA1->BA1_VERCON := _Super:normalizeType(BA1->BA1_VERCON,self:getValue("BA1_VERCON")) 
        BA1->BA1_SUBCON := _Super:normalizeType(BA1->BA1_SUBCON,self:getValue("BA1_SUBCON")) 
        BA1->BA1_VERSUB := _Super:normalizeType(BA1->BA1_VERSUB,self:getValue("BA1_VERSUB")) 
        BA1->BA1_IMAGE := _Super:normalizeType(BA1->BA1_IMAGE,self:getValue("BA1_IMAGE")) 
        BA1->BA1_CPFUSR := _Super:normalizeType(BA1->BA1_CPFUSR,self:getValue("BA1_CPFUSR")) 
        BA1->BA1_PISPAS := _Super:normalizeType(BA1->BA1_PISPAS,self:getValue("BA1_PISPAS")) 
        BA1->BA1_DRGUSR := _Super:normalizeType(BA1->BA1_DRGUSR,self:getValue("BA1_DRGUSR")) 
        BA1->BA1_ORGEM := _Super:normalizeType(BA1->BA1_ORGEM,self:getValue("BA1_ORGEM")) 
        BA1->BA1_MATVID := _Super:normalizeType(BA1->BA1_MATVID,self:getValue("BA1_MATVID")) 
        BA1->BA1_NOMUSR := _Super:normalizeType(BA1->BA1_NOMUSR,self:getValue("BA1_NOMUSR")) 
        BA1->BA1_NREDUZ := _Super:normalizeType(BA1->BA1_NREDUZ,self:getValue("BA1_NREDUZ")) 
        BA1->BA1_DATNAS := _Super:normalizeType(BA1->BA1_DATNAS,self:getValue("BA1_DATNAS")) 
        BA1->BA1_SEXO := _Super:normalizeType(BA1->BA1_SEXO,self:getValue("BA1_SEXO")) 
        BA1->BA1_ESTCIV := _Super:normalizeType(BA1->BA1_ESTCIV,self:getValue("BA1_ESTCIV")) 
        BA1->BA1_GRAUPA := _Super:normalizeType(BA1->BA1_GRAUPA,self:getValue("BA1_GRAUPA")) 
        BA1->BA1_DATINC := _Super:normalizeType(BA1->BA1_DATINC,self:getValue("BA1_DATINC")) 
        BA1->BA1_NOMPRE := _Super:normalizeType(BA1->BA1_NOMPRE,self:getValue("BA1_NOMPRE")) 
        BA1->BA1_CPFPRE := _Super:normalizeType(BA1->BA1_CPFPRE,self:getValue("BA1_CPFPRE")) 
        BA1->BA1_MAE := _Super:normalizeType(BA1->BA1_MAE,self:getValue("BA1_MAE")) 
        BA1->BA1_DATADM := _Super:normalizeType(BA1->BA1_DATADM,self:getValue("BA1_DATADM")) 
        BA1->BA1_CPFMAE := _Super:normalizeType(BA1->BA1_CPFMAE,self:getValue("BA1_CPFMAE")) 
        BA1->BA1_RECNAS := _Super:normalizeType(BA1->BA1_RECNAS,self:getValue("BA1_RECNAS")) 
        BA1->BA1_CODPLA := _Super:normalizeType(BA1->BA1_CODPLA,self:getValue("BA1_CODPLA")) 
        BA1->BA1_VERSAO := _Super:normalizeType(BA1->BA1_VERSAO,self:getValue("BA1_VERSAO")) 
        BA1->BA1_10ANOS := _Super:normalizeType(BA1->BA1_10ANOS,self:getValue("BA1_10ANOS")) 
        BA1->BA1_EMICAR := _Super:normalizeType(BA1->BA1_EMICAR,self:getValue("BA1_EMICAR")) 
        BA1->BA1_DATCAS := _Super:normalizeType(BA1->BA1_DATCAS,self:getValue("BA1_DATCAS")) 
        BA1->BA1_CEPUSR := _Super:normalizeType(BA1->BA1_CEPUSR,self:getValue("BA1_CEPUSR")) 
        BA1->BA1_ENDERE := _Super:normalizeType(BA1->BA1_ENDERE,self:getValue("BA1_ENDERE")) 
        BA1->BA1_NR_END := _Super:normalizeType(BA1->BA1_NR_END,self:getValue("BA1_NR_END")) 
        BA1->BA1_COMEND := _Super:normalizeType(BA1->BA1_COMEND,self:getValue("BA1_COMEND")) 
        BA1->BA1_BAIRRO := _Super:normalizeType(BA1->BA1_BAIRRO,self:getValue("BA1_BAIRRO")) 
        BA1->BA1_CODMUN := _Super:normalizeType(BA1->BA1_CODMUN,self:getValue("BA1_CODMUN")) 
        BA1->BA1_MUNICI := _Super:normalizeType(BA1->BA1_MUNICI,self:getValue("BA1_MUNICI")) 
        BA1->BA1_ESTADO := _Super:normalizeType(BA1->BA1_ESTADO,self:getValue("BA1_ESTADO")) 
        BA1->BA1_DDD := _Super:normalizeType(BA1->BA1_DDD,self:getValue("BA1_DDD")) 
        BA1->BA1_TELEFO := _Super:normalizeType(BA1->BA1_TELEFO,self:getValue("BA1_TELEFO")) 
        BA1->BA1_CODPRF := _Super:normalizeType(BA1->BA1_CODPRF,self:getValue("BA1_CODPRF")) 
        BA1->BA1_DATMAE := _Super:normalizeType(BA1->BA1_DATMAE,self:getValue("BA1_DATMAE")) 
        BA1->BA1_PAI := _Super:normalizeType(BA1->BA1_PAI,self:getValue("BA1_PAI")) 
        BA1->BA1_CPFPAI := _Super:normalizeType(BA1->BA1_CPFPAI,self:getValue("BA1_CPFPAI")) 
        BA1->BA1_DATPAI := _Super:normalizeType(BA1->BA1_DATPAI,self:getValue("BA1_DATPAI")) 
        BA1->BA1_MATEMP := _Super:normalizeType(BA1->BA1_MATEMP,self:getValue("BA1_MATEMP")) 
        BA1->BA1_MATANT := _Super:normalizeType(BA1->BA1_MATANT,self:getValue("BA1_MATANT")) 
        BA1->BA1_TIPANT := _Super:normalizeType(BA1->BA1_TIPANT,self:getValue("BA1_TIPANT")) 
        BA1->BA1_DATCAR := _Super:normalizeType(BA1->BA1_DATCAR,self:getValue("BA1_DATCAR")) 
        BA1->BA1_DATCPT := _Super:normalizeType(BA1->BA1_DATCPT,self:getValue("BA1_DATCPT")) 
        BA1->BA1_MUDFAI := _Super:normalizeType(BA1->BA1_MUDFAI,self:getValue("BA1_MUDFAI")) 
        BA1->BA1_COBRET := _Super:normalizeType(BA1->BA1_COBRET,self:getValue("BA1_COBRET")) 
        BA1->BA1_MESREA := _Super:normalizeType(BA1->BA1_MESREA,self:getValue("BA1_MESREA")) 
        BA1->BA1_INDREA := _Super:normalizeType(BA1->BA1_INDREA,self:getValue("BA1_INDREA")) 
        BA1->BA1_CB1AMS := _Super:normalizeType(BA1->BA1_CB1AMS,self:getValue("BA1_CB1AMS")) 
        BA1->BA1_UNIVER := _Super:normalizeType(BA1->BA1_UNIVER,self:getValue("BA1_UNIVER")) 
        BA1->BA1_DATBLO := _Super:normalizeType(BA1->BA1_DATBLO,self:getValue("BA1_DATBLO")) 
        BA1->BA1_MOTBLO := _Super:normalizeType(BA1->BA1_MOTBLO,self:getValue("BA1_MOTBLO")) 
        BA1->BA1_CONSID := _Super:normalizeType(BA1->BA1_CONSID,self:getValue("BA1_CONSID")) 
        BA1->BA1_INTERD := _Super:normalizeType(BA1->BA1_INTERD,self:getValue("BA1_INTERD")) 
        BA1->BA1_NUMCON := _Super:normalizeType(BA1->BA1_NUMCON,self:getValue("BA1_NUMCON")) 
        BA1->BA1_CORNAT := _Super:normalizeType(BA1->BA1_CORNAT,self:getValue("BA1_CORNAT")) 
        BA1->BA1_SANGUE := _Super:normalizeType(BA1->BA1_SANGUE,self:getValue("BA1_SANGUE")) 
        BA1->BA1_PRICON := _Super:normalizeType(BA1->BA1_PRICON,self:getValue("BA1_PRICON")) 
        BA1->BA1_ULTCON := _Super:normalizeType(BA1->BA1_ULTCON,self:getValue("BA1_ULTCON")) 
        BA1->BA1_PROCON := _Super:normalizeType(BA1->BA1_PROCON,self:getValue("BA1_PROCON")) 
        BA1->BA1_VIACAR := _Super:normalizeType(BA1->BA1_VIACAR,self:getValue("BA1_VIACAR")) 
        BA1->BA1_CODFUN := _Super:normalizeType(BA1->BA1_CODFUN,self:getValue("BA1_CODFUN")) 
        BA1->BA1_INSALU := _Super:normalizeType(BA1->BA1_INSALU,self:getValue("BA1_INSALU")) 
        BA1->BA1_CODSET := _Super:normalizeType(BA1->BA1_CODSET,self:getValue("BA1_CODSET")) 
        BA1->BA1_PESO := _Super:normalizeType(BA1->BA1_PESO,self:getValue("BA1_PESO")) 
        BA1->BA1_ALTURA := _Super:normalizeType(BA1->BA1_ALTURA,self:getValue("BA1_ALTURA")) 
        BA1->BA1_OBESO := _Super:normalizeType(BA1->BA1_OBESO,self:getValue("BA1_OBESO")) 
        BA1->BA1_RGIMP := _Super:normalizeType(BA1->BA1_RGIMP,self:getValue("BA1_RGIMP")) 
        BA1->BA1_CBTXAD := _Super:normalizeType(BA1->BA1_CBTXAD,self:getValue("BA1_CBTXAD")) 
        BA1->BA1_VLTXAD := _Super:normalizeType(BA1->BA1_VLTXAD,self:getValue("BA1_VLTXAD")) 
        BA1->BA1_NUMCOB := _Super:normalizeType(BA1->BA1_NUMCOB,self:getValue("BA1_NUMCOB")) 
        BA1->BA1_JACOBR := _Super:normalizeType(BA1->BA1_JACOBR,self:getValue("BA1_JACOBR")) 
        BA1->BA1_TXADOP := _Super:normalizeType(BA1->BA1_TXADOP,self:getValue("BA1_TXADOP")) 
        BA1->BA1_VLTXOP := _Super:normalizeType(BA1->BA1_VLTXOP,self:getValue("BA1_VLTXOP")) 
        BA1->BA1_COBINI := _Super:normalizeType(BA1->BA1_COBINI,self:getValue("BA1_COBINI")) 
        BA1->BA1_ANOMES := _Super:normalizeType(BA1->BA1_ANOMES,self:getValue("BA1_ANOMES")) 
        BA1->BA1_INFCOB := _Super:normalizeType(BA1->BA1_INFCOB,self:getValue("BA1_INFCOB")) 
        BA1->BA1_INFGCB := _Super:normalizeType(BA1->BA1_INFGCB,self:getValue("BA1_INFGCB")) 
        BA1->BA1_INFPRE := _Super:normalizeType(BA1->BA1_INFPRE,self:getValue("BA1_INFPRE")) 
        BA1->BA1_NUMCER := _Super:normalizeType(BA1->BA1_NUMCER,self:getValue("BA1_NUMCER")) 
        BA1->BA1_CDIDEN := _Super:normalizeType(BA1->BA1_CDIDEN,self:getValue("BA1_CDIDEN")) 
        BA1->BA1_NSUBFT := _Super:normalizeType(BA1->BA1_NSUBFT,self:getValue("BA1_NSUBFT")) 
        BA1->BA1_USRVIP := _Super:normalizeType(BA1->BA1_USRVIP,self:getValue("BA1_USRVIP")) 
        BA1->BA1_OPEORI := _Super:normalizeType(BA1->BA1_OPEORI,self:getValue("BA1_OPEORI")) 
        BA1->BA1_OPEDES := _Super:normalizeType(BA1->BA1_OPEDES,self:getValue("BA1_OPEDES")) 
        BA1->BA1_OPERES := _Super:normalizeType(BA1->BA1_OPERES,self:getValue("BA1_OPERES")) 
        BA1->BA1_LOCATE := _Super:normalizeType(BA1->BA1_LOCATE,self:getValue("BA1_LOCATE")) 
        BA1->BA1_LOCCOB := _Super:normalizeType(BA1->BA1_LOCCOB,self:getValue("BA1_LOCCOB")) 
        BA1->BA1_LOCEMI := _Super:normalizeType(BA1->BA1_LOCEMI,self:getValue("BA1_LOCEMI")) 
        BA1->BA1_LOCANS := _Super:normalizeType(BA1->BA1_LOCANS,self:getValue("BA1_LOCANS")) 
        BA1->BA1_INFSIB := _Super:normalizeType(BA1->BA1_INFSIB,self:getValue("BA1_INFSIB")) 
        BA1->BA1_INFANS := _Super:normalizeType(BA1->BA1_INFANS,self:getValue("BA1_INFANS")) 
        BA1->BA1_LOCSIB := _Super:normalizeType(BA1->BA1_LOCSIB,self:getValue("BA1_LOCSIB")) 
        BA1->BA1_ATUSIB := _Super:normalizeType(BA1->BA1_ATUSIB,self:getValue("BA1_ATUSIB")) 
        BA1->BA1_DTVLCR := _Super:normalizeType(BA1->BA1_DTVLCR,self:getValue("BA1_DTVLCR")) 
        BA1->BA1_OK := _Super:normalizeType(BA1->BA1_OK,self:getValue("BA1_OK")) 
        BA1->BA1_IMPORT := _Super:normalizeType(BA1->BA1_IMPORT,self:getValue("BA1_IMPORT")) 
        BA1->BA1_DATTRA := _Super:normalizeType(BA1->BA1_DATTRA,self:getValue("BA1_DATTRA")) 
        BA1->BA1_EQUIPE := _Super:normalizeType(BA1->BA1_EQUIPE,self:getValue("BA1_EQUIPE")) 
        BA1->BA1_CODVEN := _Super:normalizeType(BA1->BA1_CODVEN,self:getValue("BA1_CODVEN")) 
        BA1->BA1_CODVE2 := _Super:normalizeType(BA1->BA1_CODVE2,self:getValue("BA1_CODVE2")) 
        BA1->BA1_FXCOB := _Super:normalizeType(BA1->BA1_FXCOB,self:getValue("BA1_FXCOB")) 
        BA1->BA1_OUTLAN := _Super:normalizeType(BA1->BA1_OUTLAN,self:getValue("BA1_OUTLAN")) 
        BA1->BA1_ESCOLA := _Super:normalizeType(BA1->BA1_ESCOLA,self:getValue("BA1_ESCOLA")) 
        BA1->BA1_CDORIG := _Super:normalizeType(BA1->BA1_CDORIG,self:getValue("BA1_CDORIG")) 
        BA1->BA1_PSORIG := _Super:normalizeType(BA1->BA1_PSORIG,self:getValue("BA1_PSORIG")) 
        BA1->BA1_SOBRN := _Super:normalizeType(BA1->BA1_SOBRN,self:getValue("BA1_SOBRN")) 
        BA1->BA1_ARQEDI := _Super:normalizeType(BA1->BA1_ARQEDI,self:getValue("BA1_ARQEDI")) 
        BA1->BA1_OBSERV := _Super:normalizeType(BA1->BA1_OBSERV,self:getValue("BA1_OBSERV")) 
        BA1->BA1_NUMENT := _Super:normalizeType(BA1->BA1_NUMENT,self:getValue("BA1_NUMENT")) 
        BA1->BA1_PLAINT := _Super:normalizeType(BA1->BA1_PLAINT,self:getValue("BA1_PLAINT")) 
        BA1->BA1_DATREP := _Super:normalizeType(BA1->BA1_DATREP,self:getValue("BA1_DATREP")) 
        BA1->BA1_MATUSB := _Super:normalizeType(BA1->BA1_MATUSB,self:getValue("BA1_MATUSB")) 
        BA1->BA1_STAEDI := _Super:normalizeType(BA1->BA1_STAEDI,self:getValue("BA1_STAEDI")) 
        BA1->BA1_PRIENV := _Super:normalizeType(BA1->BA1_PRIENV,self:getValue("BA1_PRIENV")) 
        BA1->BA1_ULTENV := _Super:normalizeType(BA1->BA1_ULTENV,self:getValue("BA1_ULTENV")) 
        BA1->BA1_CODERR := _Super:normalizeType(BA1->BA1_CODERR,self:getValue("BA1_CODERR")) 
        BA1->BA1_DATALT := _Super:normalizeType(BA1->BA1_DATALT,self:getValue("BA1_DATALT")) 
        BA1->BA1_FAICOB := _Super:normalizeType(BA1->BA1_FAICOB,self:getValue("BA1_FAICOB")) 
        BA1->BA1_TIPINC := _Super:normalizeType(BA1->BA1_TIPINC,self:getValue("BA1_TIPINC")) 
        BA1->BA1_TRADES := _Super:normalizeType(BA1->BA1_TRADES,self:getValue("BA1_TRADES")) 
        BA1->BA1_TRAORI := _Super:normalizeType(BA1->BA1_TRAORI,self:getValue("BA1_TRAORI")) 
        BA1->BA1_LOTTRA := _Super:normalizeType(BA1->BA1_LOTTRA,self:getValue("BA1_LOTTRA")) 
        BA1->BA1_BLOFAT := _Super:normalizeType(BA1->BA1_BLOFAT,self:getValue("BA1_BLOFAT")) 
        BA1->BA1_OBTSIP := _Super:normalizeType(BA1->BA1_OBTSIP,self:getValue("BA1_OBTSIP")) 
        BA1->BA1_MATEDI := _Super:normalizeType(BA1->BA1_MATEDI,self:getValue("BA1_MATEDI")) 
        BA1->BA1_ENVANS := _Super:normalizeType(BA1->BA1_ENVANS,self:getValue("BA1_ENVANS")) 
        BA1->BA1_INCANS := _Super:normalizeType(BA1->BA1_INCANS,self:getValue("BA1_INCANS")) 
        BA1->BA1_EXCANS := _Super:normalizeType(BA1->BA1_EXCANS,self:getValue("BA1_EXCANS")) 
        BA1->BA1_MOTTRA := _Super:normalizeType(BA1->BA1_MOTTRA,self:getValue("BA1_MOTTRA")) 
        BA1->BA1_COBNIV := _Super:normalizeType(BA1->BA1_COBNIV,self:getValue("BA1_COBNIV")) 
        BA1->BA1_CODCLI := _Super:normalizeType(BA1->BA1_CODCLI,self:getValue("BA1_CODCLI")) 
        BA1->BA1_LOJA := _Super:normalizeType(BA1->BA1_LOJA,self:getValue("BA1_LOJA")) 
        BA1->BA1_VENCTO := _Super:normalizeType(BA1->BA1_VENCTO,self:getValue("BA1_VENCTO")) 
        BA1->BA1_CODFOR := _Super:normalizeType(BA1->BA1_CODFOR,self:getValue("BA1_CODFOR")) 
        BA1->BA1_LOJFOR := _Super:normalizeType(BA1->BA1_LOJFOR,self:getValue("BA1_LOJFOR")) 
        BA1->BA1_NOMTIT := _Super:normalizeType(BA1->BA1_NOMTIT,self:getValue("BA1_NOMTIT")) 
        BA1->BA1_ORIEND := _Super:normalizeType(BA1->BA1_ORIEND,self:getValue("BA1_ORIEND")) 
        BA1->BA1_SENHA := _Super:normalizeType(BA1->BA1_SENHA,self:getValue("BA1_SENHA")) 
        BA1->BA1_CODACE := _Super:normalizeType(BA1->BA1_CODACE,self:getValue("BA1_CODACE")) 
        BA1->BA1_DTVLCE := _Super:normalizeType(BA1->BA1_DTVLCE,self:getValue("BA1_DTVLCE")) 
        BA1->BA1_PLPOR := _Super:normalizeType(BA1->BA1_PLPOR,self:getValue("BA1_PLPOR")) 
        BA1->BA1_CODCCO := _Super:normalizeType(BA1->BA1_CODCCO,self:getValue("BA1_CODCCO")) 
        BA1->BA1_EMAIL := _Super:normalizeType(BA1->BA1_EMAIL,self:getValue("BA1_EMAIL")) 
        BA1->BA1_CODDEP := _Super:normalizeType(BA1->BA1_CODDEP,self:getValue("BA1_CODDEP")) 
        BA1->BA1_PACOOK := _Super:normalizeType(BA1->BA1_PACOOK,self:getValue("BA1_PACOOK")) 
        BA1->BA1_TREGRA := _Super:normalizeType(BA1->BA1_TREGRA,self:getValue("BA1_TREGRA")) 
        BA1->BA1_MESLIQ := _Super:normalizeType(BA1->BA1_MESLIQ,self:getValue("BA1_MESLIQ")) 
        BA1->BA1_ANOLIQ := _Super:normalizeType(BA1->BA1_ANOLIQ,self:getValue("BA1_ANOLIQ")) 
        BA1->BA1_VLRFIX := _Super:normalizeType(BA1->BA1_VLRFIX,self:getValue("BA1_VLRFIX")) 
        BA1->BA1_NREPAD := _Super:normalizeType(BA1->BA1_NREPAD,self:getValue("BA1_NREPAD")) 
        BA1->BA1_CODTES := _Super:normalizeType(BA1->BA1_CODTES,self:getValue("BA1_CODTES")) 
        BA1->BA1_CODSB1 := _Super:normalizeType(BA1->BA1_CODSB1,self:getValue("BA1_CODSB1")) 
        BA1->BA1_EMIAVC := _Super:normalizeType(BA1->BA1_EMIAVC,self:getValue("BA1_EMIAVC")) 
        BA1->BA1_RECAVC := _Super:normalizeType(BA1->BA1_RECAVC,self:getValue("BA1_RECAVC")) 
        BA1->BA1_CDMNAS := _Super:normalizeType(BA1->BA1_CDMNAS,self:getValue("BA1_CDMNAS")) 
        BA1->BA1_MUNNAS := _Super:normalizeType(BA1->BA1_MUNNAS,self:getValue("BA1_MUNNAS")) 
        BA1->BA1_ESTNAS := _Super:normalizeType(BA1->BA1_ESTNAS,self:getValue("BA1_ESTNAS")) 
        BA1->BA1_DTRSIB := _Super:normalizeType(BA1->BA1_DTRSIB,self:getValue("BA1_DTRSIB")) 
        BA1->BA1_PIPAMA := _Super:normalizeType(BA1->BA1_PIPAMA,self:getValue("BA1_PIPAMA")) 
        BA1->BA1_DATADP := _Super:normalizeType(BA1->BA1_DATADP,self:getValue("BA1_DATADP")) 
        BA1->BA1_REEWEB := _Super:normalizeType(BA1->BA1_REEWEB,self:getValue("BA1_REEWEB")) 
        BA1->BA1_TIPEND := _Super:normalizeType(BA1->BA1_TIPEND,self:getValue("BA1_TIPEND")) 
        BA1->BA1_MUNRES := _Super:normalizeType(BA1->BA1_MUNRES,self:getValue("BA1_MUNRES")) 
        BA1->BA1_RESEXT := _Super:normalizeType(BA1->BA1_RESEXT,self:getValue("BA1_RESEXT")) 
        BA1->BA1_RESFAM := _Super:normalizeType(BA1->BA1_RESFAM,self:getValue("BA1_RESFAM")) 
        BA1->BA1_REMIDO := _Super:normalizeType(BA1->BA1_REMIDO,self:getValue("BA1_REMIDO")) 
        BA1->BA1_COOPER := _Super:normalizeType(BA1->BA1_COOPER,self:getValue("BA1_COOPER")) 
        BA1->BA1_NOMSOC := _Super:normalizeType(BA1->BA1_NOMSOC,self:getValue("BA1_NOMSOC")) 
        BA1->BA1_TIPTEL := _Super:normalizeType(BA1->BA1_TIPTEL,self:getValue("BA1_TIPTEL")) 
        BA1->BA1_CRINOM := _Super:normalizeType(BA1->BA1_CRINOM,self:getValue("BA1_CRINOM")) 
        BA1->BA1_CRIMAE := _Super:normalizeType(BA1->BA1_CRIMAE,self:getValue("BA1_CRIMAE")) 
        BA1->BA1_NRCRNA := _Super:normalizeType(BA1->BA1_NRCRNA,self:getValue("BA1_NRCRNA")) 

        BA1->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method getNextMatric() Class PLSDaoBa1
Return PLPROXMAT(self:getValue("BA1_CODINT"),self:getValue("BA1_CODEMP"), xFilial("BA1"))

Method nextTipReg() Class PLSDaoBa1
    Local lFound := .F.
	Local cQuery := ""
	Local cTipUsu := "01"

    cQuery := " SELECT MAX(BA1_TIPREG) BA1_TIPREG"
    cQuery += " FROM " + RetSqlName('BA1') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BA1_FILIAL = '" + xFilial("BA1") + "' "
    cQuery += " AND BA1_CODINT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_CODINT")))
    cQuery += " AND BA1_CODEMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_CODEMP")))
    cQuery += " AND BA1_MATRIC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BA1_MATRIC")))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound
        cTipUsu := Soma1( (self:getAliasTemp())->BA1_TIPREG )
    EndIf
    self:fechaQuery()
Return cTipUsu

Method matByCco(cCodCco) Class PLSDaoBa1
    Local lFound := .F.
	Local cQuery := ""
	Local cMatric := ""

    cQuery := " SELECT BA1_MATRIC "
    cQuery += " FROM " + RetSqlName('BA1') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BA1_FILIAL = '" + xFilial("BA1") + "' "
    cQuery += " AND BA1_CODCCO = ? "
    aAdd(self:aMapBuilder, self:toString(cCodCco))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound
        cMatric := (self:getAliasTemp())->BA1_MATRIC
    Else
        cMatric :=  self:getNextMatric()
    EndIf
    self:fechaQuery()
Return cMatric
