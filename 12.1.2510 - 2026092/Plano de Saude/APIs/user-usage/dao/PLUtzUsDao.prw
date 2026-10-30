#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLUtzUsDao from CenDao

    Method New(aFields) Constructor
    Method bscUtiliz(cMatric,cPeriodDe,cPeriodAte)
    Method hasNext(nRecno)
    Method loadOrder()
    Method PMobSplMat(cMatric)
    Method getFiltCus()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method New(aFields) Class PLUtzUsDao
	_Super:New(aFields)
    self:cfieldOrder := "BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN"
    self:cAlias      := "BD6QRY"  
    self:loadOrder()    
Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscUtiliz
    Query que retorna todos os customers

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method bscUtiliz(cMatric,cPeriodDe,cPeriodAte) Class PLUtzUsDao

    Local cDb     := Alltrim(Upper(TcGetDb()) )
    Local cQuery  := ""
	Local oMatric := self:PMobSplMat(cMatric)
	Local cMesDe  := Substr(cPeriodDe,5,2)
	Local cAnoDe  := Substr(cPeriodDe,1,4)
	Local cMesAte := Substr(cPeriodAte,5,2)
	Local cAnoAte := Substr(cPeriodAte,1,4)

    cQuery += self:getRowControl()
    cQuery += " BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, "
    cQuery += " BD6_CODPRO, BD6_DESPRO, BD6_DATPRO, BD6_NOMUSR, BD6_CODRDA, BD6_NOMRDA, BR8_CLASSE, BJE_DESCRI, BD6_QTDPRO, BD6_CPFRDA, "
    cQuery += " BD6_CID, BD6_DENREG, BD6_FADENT, BD6_VLRPAG, BD6_VLRGLO, BD6_VLRTPF, "
    cQuery += " BA1_DATNAS, BA1_DATINC, BA1_DATBLO, BA1_TIPUSU, BA1_CODMUN, BR8_TPPROC, "

    cQuery += " (CASE BA1_SEXO "
    cQuery += "      WHEN '1' THEN 'M' "
    cQuery += "      ELSE 'F' END) AS BA1_SEXO, "

    cQuery += " (CASE BD6_TIPGUI "
    cQuery += "      WHEN '04' THEN 'REEMBOLSO' "
    cQuery += "      ELSE 'CONVENIO' END) AS BD6_TIPGUI, "

    cQuery += " (CASE BA1_DATBLO "
    cQuery += "      WHEN '' THEN 'A' "
    cQuery += "      ELSE 'I' END) AS STATUS, "

    if cDb $ "ORACLE/POSTGRES"
        cQuery += " BD6_OPEUSR || BD6_CODEMP || BD6_MATRIC || BD6_TIPREG || BD6_DIGITO AS MATRIC, "

        cQuery += " (CASE BD6_TIPGUI "
        cQuery += "      WHEN '03' THEN BD6_OPEINT || BD6_ANOINT || BD6_MESINT || BD6_NUMINT "
        cQuery += "      ELSE '' END) AS GUIAINT"
    else
        cQuery += " BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO AS MATRIC, "
        cQuery += " (CASE BD6_TIPGUI "
        cQuery += "      WHEN '03' THEN BD6_OPEINT + BD6_ANOINT + BD6_MESINT + BD6_NUMINT "
        cQuery += "      ELSE '' END) AS GUIAINT"
	endIf
    cQuery += " FROM " + RetSqlName("BD6")+" BD6 "
	
    // Relacionamento com o procedimento na tabela padrão
    cQuery += " INNER JOIN " + RetSqlName("BR8") + " BR8 "
    cQuery += "   ON  BR8_FILIAL = '" + xFilial("BR8")+"' "
	cQuery += "   AND BR8_CODPSA = BD6_CODPRO "
	cQuery += "   AND BR8_CODPAD = BD6_CODPAD "
	cQuery += "   AND BR8.D_E_L_E_T_ = ' ' "

    // Relacionamnto com prestador (BAU), indiferente a questoes de contrato
    cQuery += " INNER JOIN " + RetSqlName("BAU") + " BAU "
	cQuery += "   ON  BAU_FILIAL = '" + xFilial("BAU")+"' "
	cQuery += "   AND BAU_CODIGO = BD6_CODRDA "
	cQuery += "   AND BAU.D_E_L_E_T_ = ' ' "

    // Relacionamento com a classe de procedimento
    cQuery += " INNER JOIN " + RetSqlName("BJE") + " BJE "
	cQuery += "   ON  BJE_FILIAL = '" + xFilial("BJE")+"' "
	cQuery += "   AND BJE_CODINT = BD6_CODOPE "
	cQuery += "   AND BJE_CODIGO = BR8_CLASSE "
	cQuery += "   AND BJE.D_E_L_E_T_ = ' ' "

    // Relacionamento com o Beneficiário
    cQuery += " INNER JOIN " + RetSqlName("BA1") + " BA1 "
	cQuery += "   ON  BA1_FILIAL = '" + xFilial("BA1")+"' "
	cQuery += "   AND BA1_CODINT = BD6_OPEUSR "
	cQuery += "   AND BA1_CODEMP = BD6_CODEMP "
    cQuery += "   AND BA1_MATRIC = BD6_MATRIC "
    cQuery += "   AND BA1_TIPREG = BD6_TIPREG "
    cQuery += "   AND BA1_DIGITO = BD6_DIGITO "
	cQuery += "   AND BA1.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
	cQuery += " BD6.BD6_FILIAL = '" + xFilial("BD6") +"' "	
	cQuery += " AND BD6_OPEUSR = '"+oMatric['codInt']+"' "
    cQuery += " AND BD6_CODEMP = '"+oMatric['codEmp']+"' "
    cQuery += " AND BD6_MATRIC = '"+oMatric['matric']+"' "
    cQuery += " AND BD6_TIPREG = '"+oMatric['tipReg']+"' "
    cQuery += " AND BD6_DIGITO = '"+oMatric['digito']+"' "

	cQuery += " AND BD6_ANOPAG BETWEEN '"+cAnoDe+"' AND '"+cAnoAte+"' "
	cQuery += " AND BD6_MESPAG BETWEEN '"+cMesDe+"' AND '"+cMesAte+"' "
	cQuery += " AND BD6_AUDITA <> '1' "
	cQuery += " AND BD6_LIBERA <> '1' "
    cQuery += " AND BD6_BLOCPA <> '1' "
	cQuery += " AND BD6_FASE IN ('3','4') "	
    cQuery += self:getFiltCus()
    cQuery += " AND BD6.D_E_L_E_T_ = ' ' "
    cQuery += self:getWhereRow()

    if ExistBlock("PUTZBEN1")
        cQuery := ExecBlock("PUTZBEN1",.F.,.F.,{cQuery})
    endIf

    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getFiltCus

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method getFiltCus() Class PLUtzUsDao

    Local cFilter := ""
    Local xValue  := ""
    Local cField  := ""
    Local nField := 0
    Local nLen   := Len(self:getAFields())
    
    For nField := 1 to nLen
        cField := self:getAFields()[nField][JSONFIELD]
        xValue := self:getValue(cField)
        If !empty(xValue) .And. cField != "subscriberId"

            if cField == "executionDate"
                xValue := StrTran( xValue, "-", "" )
            endIf
            cFilter += " AND " + self:getAFields()[nField][DBFIELD] + " = '"+self:toString(xValue)+"' "
        EndIf
    Next nField

Return cFilter

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PMobSplMat

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method PMobSplMat(cMatric) Class PLUtzUsDao

	Local oMatric := jSonObject():New()

	oMatric['codInt'] := Substr(cMatric,01,04)
	oMatric['codEmp'] := Substr(cMatric,05,04)
	oMatric['matric'] := Substr(cMatric,09,06)
	oMatric['tipReg'] := Substr(cMatric,15,02)
	oMatric['digito'] := Substr(cMatric,17,01)

Return(oMatric)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} hasNext
    hasNext especifico

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method hasNext(nRecno) Class PLUtzUsDao
    Local lTemProx := .F.
    If self:aliasSelected()
        lTemProx := !(self:getAliasTemp())->(Eof())
    EndIf
return lTemProx


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadOrder
    Adicona campos para ordenacao

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method loadOrder() Class PLUtzUsDao

    self:oHashOrder:set("PROCEDURECODE", "BD6_CODPRO")
    self:oHashOrder:set("PROCEDURENAME", "BD6_DESPRO")
    self:oHashOrder:set("EXECUTIONDATE", "BD6_DATPRO")
    self:oHashOrder:set("SUBSCRIBERNAME", "BD6_NOMUSR")
    self:oHashOrder:set("HEALTHPROVIDERCODE", "BD6_CODRDA")
    self:oHashOrder:set("HEALTHPROVIDERNAME", "BD6_NOMRDA")
    self:oHashOrder:set("QUANTITY", "BD6_QTDPRO")
    self:oHashOrder:set("HEALTHPROVIDERDOCUMENT", "BD6_CPFRDA")
    self:oHashOrder:set("CID","BD6_CID")
    self:oHashOrder:set("PROCEDURENAME","BD6_DESPRO")
    self:oHashOrder:set("HEALTHPROVIDERNAME","BD6_NOMRDA")
    self:oHashOrder:set("TOOTHREGION","BD6_DENREG")
    self:oHashOrder:set("FACE","BD6_FADENT")

Return