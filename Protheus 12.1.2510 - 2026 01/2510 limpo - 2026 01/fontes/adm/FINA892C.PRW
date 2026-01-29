#Include "Protheus.ch"
#Include "FwLibVersion.ch"
#Include "FINA892.CH"

Static __lSitCPix As Logical
Static __lExcImpo As Logical
Static __lMVGlosa As Logical
Static __nCasasDc As Numeric
Static __lTemDic  As Logical
Static __lFinPix  As Logical
Static __nMotBaix As Numeric
Static __nHisBaix As Logical
Static __lCalJrDe As Logical
Static __lHttpsQu As Logical

/*/{Protheus.doc} Titulo
    Modelagem da classe Titulo.
    
    @type  Classe
    @author Sivaldo Oliveira
    @since 11/11/2022
/*/ 
Class Titulo
    //atributos da classe
    Data cUrlBase  As Char        
    Data cPath     As Char
    Data cAppKey   As Char
    Data cTable    As Char    
    Data cTblCanc  As Char
    Data cBody     As Char
    Data cResponse As Char
    Data nRecno    As Numeric
    Data nDiasExp  As Numeric
    Data aHeader   As Array    
    
    //construtor da classe
    Method New() 
    
    //métodos para atribuir valores aos atributos
    Method setUrlBase()
    Method setPath()
    Method setAppKey()
    Method setTable()
    Method setTblCanc()
    Method setBody()
    Method setRespons()
    Method setRecno()
    Method setDiasExp()
    Method setHeader()    
    
    //métodos para pegar valores dos atributos
    Method getUrlBase()
    Method getPath()
    Method getAppKey()
    Method getTable()    
    Method getTblCanc()
    Method getBody()
    Method getRespons()
    Method getRecno()
    Method getDiasExp()
    Method getHeader()
    
    //outros métodos
    Method listaCanc()
    Method listaEnvio()
    Method registrCob()
    Method baixaTitul()
    Method cancelaCob()    
End Class

/*/{Protheus.doc}New
    Método construtor da classe Titulo
    
    @Param cUrlBase, Char,  Url Base (HostName) 
    @Param cPath,    Char,  Recurso (EndPoint)
    @Param cAppKey,  Char,  Chave credencial para consumir a API
    @Param cTable,   Char,  Tabela temporária (ResultSet) com a lista de títulos para gerar QrCode
    @Param aHeader,  Array, Cabeçalho da requisição
    
    @author Sivaldo Oliveira
    @since  09/11/2022
/*/
Method New(cUrlBase As Char, cPath As Char, cAppKey As Char, cTable As Char, aHeader As Array) Class Titulo
    Default cUrlBase := ""
    Default cPath    := ""
    Default cAppKey  := ""    
    Default cTable   := ""
    Default aHeader  := {}
    
    Self:cUrlBase  := cUrlBase
    Self:cPath     := cPath
    Self:cAppKey   := cAppKey
    Self:cTable    := cTable
    Self:cTblCanc  := ""
    Self:cBody     := ""
    Self:nRecno    := 0
    Self:nDiasExp  := 0
    Self:aHeader   := AClone(aHeader)
    Self:cResponse := ""
Return Nil

//setters
Method setUrlBase(cUrlBase As Char) Class Titulo
    Default cUrlBase := ""
    Self:cUrlBase := cUrlBase
Return Nil

Method setPath(cPath As Char) Class Titulo
    Default cPath := ""
    Self:cPath := cPath
Return Nil

Method setAppKey(cAppKey As Char) Class Titulo
    Default cAppKey := ""
    Self:cAppKey := cAppKey
Return Nil

Method setTable(cTable As Char) Class Titulo
    Default cTable := ""
    Self:cTable := cTable 
Return Nil

Method setTblCanc(cTblCanc As Char) Class Titulo
    Default cTblCanc := ""
    Self:cTblCanc := cTblCanc 
Return Nil

Method setBody(cBody As Char) Class Titulo
    Default cBody := ""
    Self:cBody := cBody
Return Nil

Method setRespons(cResponse As Char) Class Titulo
    Default cResponse := ""
    Self:cResponse := cResponse
Return Nil

Method setRecno(nRecno As Numeric) Class Titulo
    Default nRecno := 0
    Self:nRecno := nRecno
Return Nil

Method setDiasExp(nDiasExp As Numeric) Class Titulo
    Default nDiasExp := 0
    Self:nDiasExp := nDiasExp
Return Nil

Method setHeader(aHeader As Array) Class Titulo
    Default aHeader := {}
    Self:aHeader := AClone(aHeader)
Return Nil

//getters
Method getUrlBase() Class Titulo
Return Self:cUrlBase

Method getPath() Class Titulo
Return Self:cPath

Method getAppKey() Class Titulo
Return Self:cAppKey

Method getTable() Class Titulo
Return Self:cTable

Method getTblCanc() Class Titulo
Return Self:cTblCanc

Method getBody() Class Titulo
Return Self:cBody

Method getRespons() Class Titulo
Return Self:cResponse

Method getRecno() Class Titulo
Return Self:nRecno

Method getDiasExp () Class Titulo
Return Self:nDiasExp

Method getHeader() Class Titulo
Return Self:aHeader

/*/{Protheus.doc} listaCanc
    Lista os registro do monitor PIX que possuem 
    solicitação de cancelamento.Ou seja, solicitação
    para remover o registro de cobrança do sistema PIX.
    
    @author Sivaldo Oliveira
    @since 11/11/2022
    
    @param oListCanc, Object, Consulta prepada para listar as 
    registros que possuem solicitação de cancelamento.
/*/
Method listaCanc(oListCanc As Object) Class Titulo
    Local cQuery     As Char
    Local cTblTmp    As Char
    Local cFilSE1F71 As Char    
    
    //Parâmetros de entrada.
    oListCanc := Nil
    
    //Inicializa variáveis.
    cQuery     := ""
    cTblTmp    := ""
    cFilSE1F71 := xFilial("SE1")
    
    If oListCanc == Nil
        cQuery := "SELECT SE1.E1_FILIAL, F71.F71_CODBAN, F71.F71_AGENCI, F71.F71_NUMCON, F71.R_E_C_N_O_ RECNO "
        
        cQuery += "FROM ? F71 JOIN ? SE1 "
        cQuery += "ON F71.F71_FILIAL  = SE1.E1_FILIAL "
        cQuery += "AND F71.F71_PREFIX = SE1.E1_PREFIXO "
        cQuery += "AND F71.F71_NUM    = SE1.E1_NUM "
        cQuery += "AND F71.F71_PARCEL = SE1.E1_PARCELA "
        cQuery += "AND F71.F71_TIPO   = SE1.E1_TIPO "
        cQuery += "AND F71.F71_CODCLI = SE1.E1_CLIENTE "
        cQuery += "AND F71.F71_LOJCLI = SE1.E1_LOJA "
        cQuery += "AND F71.D_E_L_E_T_ = SE1.D_E_L_E_T_ "
        cQuery += "WHERE F71.F71_FILIAL = ? AND SE1.E1_FILIAL = ? "
        cQuery += "AND F71.F71_STATUS IN ('3', '4') AND F71_SOLCAN = '1' "
        cQuery += "AND F71.F71_CODBAN <> ' ' AND F71.F71_AGENCI <> ' ' AND F71.F71_NUMCON <> ' ' "
        cQuery += "AND F71.F71_CHVPIX <> ' ' AND F71.D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        oListCanc := FWPreparedStatement():New(cQuery)
    EndIf
    
    oListCanc:SetNumeric(1, RetSqlName("F71"))
    oListCanc:SetNumeric(2, RetSqlName("SE1"))
    oListCanc:SetString(3, cFilSE1F71)
    oListCanc:SetString(4, cFilSE1F71)    
    
    cQuery  := oListCanc:GetFixQuery()
    cTblTmp := MPSysOpenQuery(cQuery)
    
    If (cTblTmp)->(Eof()) 
        (cTblTmp)->(DbCloseArea())
        cTblTmp := ""
    EndIf
    
    Self:setTblCanc(cTblTmp)
Return Nil

/*/{Protheus.doc} listaEnvio
    Lista os registro do monitor PIX que estão pendente 
    de envio para registro no sistema PIX, geração de qrcode.
    
    @author Sivaldo Oliveira
    @since 11/11/2022
    
    @param oListEnvio, Object, Consulta prepada para listar os títulos
    @param dDataVenc, Date, Data de vencimento para filtro dos títulos.
/*/
Method listaEnvio(oListEnvio As Object, dDataVenc As Date) Class Titulo
    Local cQuery     As Char
    Local cTblTmp    As Char
    Local cFilSE1F71 As Char    
    
    //Parâmetros de entrada.
    oListEnvio  := Nil
    dDataVenc := Date()
    
    //Inicializa variáveis.
    cQuery     := ""
    cTblTmp    := ""
    cFilSE1F71 := xFilial("SE1")
    
    If oListEnvio == Nil
        cQuery := "SELECT SE1.E1_FILIAL, SE1.E1_VENCREA, F71.F71_CODBAN, F71.F71_AGENCI, F71.F71_NUMCON, " 
        cQuery += "F71.F71_STATUS, F71.F71_SOLCAN, F71.R_E_C_N_O_ RECNO "
        
        cQuery += "FROM ? F71 JOIN ? SE1 "
        cQuery += "ON F71.F71_FILIAL  = SE1.E1_FILIAL "
        cQuery += "AND F71.F71_PREFIX = SE1.E1_PREFIXO "
        cQuery += "AND F71.F71_NUM    = SE1.E1_NUM "
        cQuery += "AND F71.F71_PARCEL = SE1.E1_PARCELA "
        cQuery += "AND F71.F71_TIPO   = SE1.E1_TIPO "
        cQuery += "AND F71.F71_CODCLI = SE1.E1_CLIENTE "
        cQuery += "AND F71.F71_LOJCLI = SE1.E1_LOJA "
        cQuery += "AND F71.D_E_L_E_T_ = SE1.D_E_L_E_T_ "
        cQuery += "WHERE F71.F71_FILIAL = ? AND SE1.E1_FILIAL = ? "
        cQuery += "AND F71.F71_STATUS = '1' AND F71_SOLCAN = '2' AND SE1.E1_VENCREA >= ? "
        cQuery += "AND F71.F71_CODBAN <> ' ' AND F71.F71_AGENCI <> ' ' AND F71.F71_NUMCON <> ' ' "
        cQuery += "AND F71.F71_CHVPIX <> ' ' AND F71.D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        oListEnvio := FWPreparedStatement():New(cQuery)
    EndIf
    
    oListEnvio:SetNumeric(1, RetSqlName("F71"))
    oListEnvio:SetNumeric(2, RetSqlName("SE1"))
    oListEnvio:SetString(3, cFilSE1F71)
    oListEnvio:SetString(4, cFilSE1F71)
    oListEnvio:SetDate(5, dDataVenc)
    
    cQuery  := oListEnvio:GetFixQuery()
    cTblTmp := MPSysOpenQuery(cQuery)
    
    If (cTblTmp)->(Eof()) 
        (cTblTmp)->(DbCloseArea())
        cTblTmp := ""
    EndIf
    
    Self:SetTable(cTblTmp)
Return Nil

/*/{Protheus.doc} registrCob
    Método responsável pelo registro
    de título no sistema PIX
    
    @author Sivaldo Oliveira
    @since 11/11/2022
    
    @param oToken, Object, Instância da classe token
    @param cCertifica, Char, Nome do arquivo de certificado com a extensão (.pem)
    @param cCertiKey, Char, Nome do arquivo chave do certificado com a extensão (.pem)
    @param lAutomacao, Logical, Valor Lógico que define se o processamento é de automação
/*/
Method registrCob(oToken As Object, cCertifica As Char, cCertiKey As Char, lAutomacao As Logical, oJSonAut As JSon) Class Titulo
    Local lBordeImpo As Logical
    Local lDescFin   As Logical
    Local cBody      As Char
    Local cToken     As Char
    Local cSituaCob  As Char
    Local cData      As Char
    Local cDtaVenc   As Char
    Local cTpDescFin As Char
    Local cModalDesc As Char
    Local cChaveTit  As Char
    Local cLogErro   As Char
    Local cCGC       As Char
    Local cLogUtf8   As Char
    Local cIdDocF71  As Char
    Local cResult    As Char
    Local cHttpsQuot As Char
    Local nRecnoF71  As Numeric
    Local nRecnoSE1  As Numeric
    Local nVlrPix    As Numeric    
    Local nTxMoeda   As Numeric
    Local nBaseImpos As Numeric
    Local nAbatImpos As Numeric
    Local nAbatiment As Numeric
    Local nOutrosAba As Numeric 
    Local nVASoma    As Numeric
    Local nVASubtra  As Numeric        
    Local nAcresc    As Numeric
    Local nDecresc   As Numeric
    Local nDescFin   As Numeric    
    Local nTaxaPerm  As Numeric
    Local nPerJuros  As Numeric
    Local nModMulta  As Numeric
    Local nMulta     As Numeric
    Local nHttpCode  As Numeric
    Local nTotImpBx  As Numeric
    Local dDtaConv   As Date
    Local dDtLimDesc As Date
    Local aHeader    As Array
    Local aAreaAtu   As Array
    Local aAreaSA1   As Array
    Local aAreaSE1   As Array
    Local aAreaF71   As Array    
    Local aSetF71    As Array
    Local oJSon      As Object        
    Local oJsonCred  As Object
    
    //Parâmetros de entrada.
    Default oToken     := Nil
    Default cCertifica := ""
    Default cCertiKey  := ""
    Default lAutomacao := .F.
    Default oJSonAut   := Nil
    
    //Inicializa variáveis
    lBordeImpo := .F.
    lDescFin   := .F.
    cBody      := ""
    cToken     := ""    
    cData      := ""
    cDtaVenc   := ""
    cTpDescFin := ""
    cModalDesc := "2"
    cChaveTit  := ""
    cLogErro   := ""
    cCGC       := ""
    cLogUtf8   := ""
    cIdDocF71  := ""
    cResult    := ""
    cHttpsQuot := ""
    nRecnoF71  := Self:GetRecno()
    nRecnoSE1  := 0
    nVlrPix    := 0
    nTxMoeda   := 0
    nBaseImpos := 0
    nAbatImpos := 0
    nAbatiment := 0
    nOutrosAba := 0
    nVASoma    := 0
    nVASubtra  := 0
    nAcresc    := 0
    nDecresc   := 0
    nDescFin   := 0
    nTaxaPerm  := 0
    nPerJuros  := 0
    nModMulta  := 0
    nMulta     := 0
    nHttpCode  := 0
    nTotImpBx  := 0
    dDtaConv   := CToD("")
    dDtLimDesc := dDtaConv 
    aHeader    := {}
    aSetF71    := {}
    oJSon      := Nil
    oJsonCred  := Nil
    
    If __lHttpsQu == Nil
        __lHttpsQu := FindFunction("HTTPSQuote")
    EndIf
    
    If nRecnoF71 > 0 .And. (lAutomacao .Or. (__lHttpsQu .And. oToken != Nil))
        aAreaAtu := GetArea()        
        DbSelectArea("SA1")
        DbSelectArea("SE1")
        DbSelectArea("F71")
        aAreaSA1 := SA1->(GetArea())
        aAreaSE1 := SE1->(GetArea())
        aAreaF71 := F71->(GetArea())        
        SA1->(DbSetOrder(1))
        SE1->(DbSetOrder(1))
        
        If __lSitCPix == Nil
            __lSitCPix  := FindFunction("F022SITPIX")
        EndIf
        
        If __lExcImpo == Nil
            __lExcImpo := FindFunction("ExcluiImpo") .And. FindFunction("PIXGerImp")
        EndIf
        
        If __lMVGlosa == Nil
            __lMVGlosa := SuperGetMv("MV_GLOSA", .F., .F.)
        EndIf
        
        If __nCasasDc == Nil
            __nCasasDc := TamSX3("FK1_TXMOED")[2]
        EndIf
        
        If __lTemDic == Nil
            __lTemDic := F71->(FieldPos("F71_DIAEXP")) > 0 .And. F71->(FieldPos("F71_MULTA")) > 0
        EndIf
        
        If __lFinPix == Nil 
            __lFinPix := ExistBlock("FINVLPIX")
        EndIf
        
        F71->(DbGoto(nRecnoF71))
        cChaveTit := F71->(F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO) 
        cIdDocF71 := F71->(F71_FILIAL + F71_IDDOC)
        
        If !(lRetorno := SE1->(MsSeek(cChaveTit)) .And. SE1->(MsRLock()))
            FwLogMsg("INFO", Nil, STR0064, STR0060, "", "01", STR0061 + cChaveTit + STR0062, 0, 0, {})
        ElseIf !(lRetorno := !(SE1->E1_SALDO <= 0))
            FwLogMsg("INFO", Nil, STR0064, STR0060, "", "01", STR0061 + cChaveTit + STR0063, 0, 0, {})
        EndIf
        
        If lRetorno .And. !(lRetorno := (SA1->(MsSeek(XFilial("SA1", SE1->E1_FILORIG) + SE1->(E1_CLIENTE+E1_LOJA)))))
            FwLogMsg("INFO", Nil, STR0064, STR0060, "", "01", STR0065 + (SE1->E1_CLIENTE + " / " + SE1->E1_LOJA) + STR0062, 0, 0, {})
        ElseIf lRetorno
            nRecnoSE1  := SE1->(Recno())
        EndIf

        If lRetorno
            cLogErro   := ""
            cLogUtf8   := ""
            lBordeImpo := .F.
            nTxMoeda   := SE1->E1_TXMOEDA            
            
            If SE1->E1_MOEDA > 1 .And. (Empty(nTxMoeda) .Or. !Empty(SE1->E1_DTVARIA))
                dDtaConv := SE1->E1_DTVARIA 
                
                If Empty(SE1->E1_DTVARIA)
                    dDtaConv := dDataBase
                EndIf
                
                nTxMoeda := RecMoeda(dDtaConv, SE1->E1_MOEDA)
            EndIf
            
            Begin Transaction
                If __lExcImpo
                    lBordeImpo := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)
                    nBaseImpos := BaseImpPix(nRecnoSE1, @nVASoma, @nVASubtra, @nAbatImpos, nTxMoeda, @nOutrosAba)
                    
                    If !lBordeImpo .And. (!__lMVGlosa .Or. (__lMVGlosa .And. SE1->(E1_VALOR == E1_SALDO) .And. Empty(SE1->E1_BAIXA)))
                        If !PIXGerImp(nBaseImpos, nTxMoeda, @nTotImpBx)
                            DisarmTransaction()
                            Break
                        EndIf                
                    EndIf
                EndIf
                
                If __lFinPix
                    nVlrPix := ExecBlock("FINVLPIX")                
                Else
                    nVlrPix    := SE1->E1_SALDO
                    nDescFin   := SE1->E1_DESCFIN
                    cTpDescFin := AllTrim(SE1->E1_TIPODES)
                    nTaxaPerm  := SE1->E1_VALJUR
                    nPerJuros  := SE1->E1_PORCJUR                    
                    nModMulta  := 1
                    nMulta     := 0                    
                    oJsonCred  := JsonObject():New()
                    
                    If (ValType(oJsonCred:FromJson(SA6->A6_CFGPIX)) == "U")
                        If oJsonCred:Hasproperty("modalidademulta") .And. oJsonCred:Hasproperty("valordamulta")
                            nModMulta := oJsonCred["modalidademulta"]
                            nMulta    := oJsonCred["valordamulta"]
                        EndIf
                    EndIf
                    
                    FreeObj(oJsonCred)
                    
                    If __lTemDic .And. (lDescFin := ((nDescFin > 0) .And. (cTpDescFin $ "1|2")))
                        dDtLimDesc := DataLimDes()
                    EndIf
                    
                    If SE1->(E1_SDACRES+E1_SDDECRE) > 0
                        nVlrPix  += (SE1->E1_SDACRES - SE1->E1_SDDECRE)
                        nAcresc  := SE1->E1_SDACRES
                        nDecresc := SE1->E1_SDDECRE                
                    EndIf
                    
                    If ((nVASoma > 0) .Or. (nVASubtra != 0 ))
                        nVlrPix += (nVASoma - Abs(nVASubtra))
                    EndIf
                    
                    If (nAbatImpos+nOutrosAba) > 0
                        If SE1->E1_MOEDA > 1
                            If nAbatImpos > 0
                                nAbatImpos := Round(xMoeda(nAbatImpos, 1, SE1->E1_MOEDA, dDataBase, __nCasasDc, 0, nTxMoeda), 2)
                            EndIf
                            
                            If nOutrosAba > 0
                                nOutrosAba := Round(xMoeda(nOutrosAba, 1, SE1->E1_MOEDA, dDataBase, __nCasasDc, 0, nTxMoeda), 2)
                                nAbatiment := nOutrosAba 
                            EndIf
                        EndIf
                        
                        nVlrPix    -= (nAbatImpos+nOutrosAba)
                        nAbatiment := nOutrosAba
                    EndIf
                    
                    nVlrPix -= nTotImpBx
                EndIf
                
                If Empty(cBody := Self:getBody())
                    cData    := DToS(SE1->E1_VENCREA) 
                    cDtaVenc := SubStr(cData, 1, 4) + "-" + SubStr(cData, 5, 2) + "-" + SubStr(cData, 7, 2)                    
                    
                    cBody := "{"                
                        //Validade do QrCode
                        cBody += '"calendario": {'
                            cBody += '"dataDeVencimento": "' + cDtaVenc + '"'
                            cBody += ',"validadeAposVencimento": ' + CValToChar(Self:getDiasExp())
                        cBody += "}"
                        
                        //Dados do sacado
                        cBody += ',"devedor": {'
                            cBody += '"logradouro": "' + AllTrim(SA1->A1_END) + ", " +AllTrim(SA1->A1_BAIRRO) + '"'
                            cBody += ',"cidade": "' + AllTrim(SA1->A1_MUN) + '"'
                            cBody += ',"uf": "' + SA1->A1_EST + '"'
                            cBody += ',"cep": "' + SA1->A1_CEP + '"'
                            
                            If Len(cCGC := AllTrim(SA1->A1_CGC)) > 11
                                cBody += ',"cnpj": "' + cCGC + '"'
                            Else
                                cBody += ',"cpf": "' + cCGC + '"'
                            EndIf
                            
                            cBody += ',"nome": "' + AllTrim(SE1->E1_NOMCLI) + '"'
                        cBody += "}"
                        
                        //Valor para registro de cobrança PIX
                        cBody += ',"valor": {'
                            cBody += '"original": "' + CValToChar(nVlrPix) + '"'
                            
                            If __lTemDic .And. ((nMulta > 0) .Or. ((nTaxaPerm + nPerJuros) > 0) .Or. (lDescFin .And. nDescFin > 0))
                                //Multa
                                If nMulta > 0
                                    cBody += ',"multa": {'
                                        cBody += '"modalidade": "' + cValToChar(nModMulta) + '"' 
                                        cBody += ',"valorPerc": "' + cValToChar(nMulta) + '"' 
                                    cBody += "}"
                                EndIf
                                
                                //Juros
                                If (nTaxaPerm + nPerJuros) > 0
                                    If nTaxaPerm > 0
                                        cBody += ',"juros": {'
                                            cBody += '"modalidade": "' + '1"'
                                            cBody += ',"valorPerc": "' + cValToChar(Round(nTaxaPerm,2)) + '"'
                                        cBody += "}"
                                    Else
                                        cBody += ',"juros": {'
                                            cBody += '"modalidade": "' + '2"'
                                            cBody += ',"valorPerc": "' + cValToChar(Round(nPerJuros,2)) + '"'
                                        cBody += "}"                                
                                    EndIf
                                EndIf
                                
                                //Valor percentual de desconto
                                If lDescFin .And. nDescFin > 0 
                                    cData      := DToS(dDtLimDesc) 
                                    cDtaVenc   := SubStr(cData, 1, 4) + "-" + SubStr(cData, 5, 2) + "-" + SubStr(cData, 7, 2)

                                    If cTpDescFin != "1"
                                        nDescFin   := Round((nDescFin / 30), 2)
                                    ElseIf cTpDescFin == '1'
                                        cModalDesc := "2"
                                    Endif
                                    
                                    If cTpDescFin == "2"
                                        cModalDesc := "5"
                                    EndIf
                                    
                                    cBody += ',"desconto": {'
                                        cBody += '"modalidade": "' + cModalDesc + '"'
                                        
                                        If cTpDescFin == "1"
                                            cBody += ',"descontoDataFixa": ['
                                                cBody += "{"
                                                    cBody += '"data": "' + cDtaVenc + '"'
                                                    cBody += ',"valorPerc": "' + cValToChar(nDescFin) + '"'
                                                cBody += "}"
                                            cBody += "]"
                                        Else
                                            cBody += ',"data": "' + cDtaVenc + '"'
                                            cBody += ',"valorPerc": "' + cValToChar(nDescFin) + '"'
                                        EndIf
                                    cBody += "}"
                                EndIf
                            EndIf                        
                        cBody += "}"
                        
                        //Chave Pix cadastrada no banco
                        cBody += ',"chave": "' + AllTrim(F71->F71_CHVPIX) + '"'
                    cBody += "}"
                EndIf                
                
                If (lAutomacao .Or. !Empty(cToken := oToken:getToken()))
                    If (lAutomacao .Or. (Len(aHeader := AClone(Self:GetHeader())) >= 3))
                        If !lAutomacao
                            aHeader[3] += cToken
                        EndIf
                        
                        If DecodeUTF8(cBody) == Nil
                            cBody := EncodeUTF8(cBody)
                        EndIf
                        
                        If lAutomacao
                            oJSon := oJSonAut 
                        Else
                            cHttpsQuot := 'HTTPSQuote((self:getUrlBase()+self:getPath()+"/"+F71->F71_IDTRAN+self:getAppKey()), cCertifica, cCertiKey, "", "PUT", "", cBody, 120, aHeader, Nil, .F.)' 
                            cResult    := &cHttpsQuot
                            nHttpCode  := HTTPGetStatus(Nil, Nil)
                            oJSon := JsonObject():New()
                        EndIf
                        
                        If lAutomacao .Or. (((nHttpCode == 200) .Or. (nHttpCode == 201)) .And. (ValType(cResult := oJSon:FromJson(cResult)) == "U"))
                            AAdd(aSetF71, {"F71_STATUS", "3"})
                            AAdd(aSetF71, {"F71_VLRPIX", nVlrPix})
                            AAdd(aSetF71, {"F71_EMVPIX", oJSon["pixCopiaECola"]})
                            AAdd(aSetF71, {"F71_DTPSP",  dDataBase})
                            AAdd(aSetF71, {"F71_HRPSP",  Time()})
                            AAdd(aSetF71, {"F71_MENSAG", STR0067})
                            
                            If __lTemDic
                                AAdd(aSetF71, {"F71_DECRES", nDecresc})
                                AAdd(aSetF71, {"F71_ACRESC", nAcresc})
                                AAdd(aSetF71, {"F71_VASOMA", nVASoma})
                                AAdd(aSetF71, {"F71_VASUBT", nVASubtra})
                                AAdd(aSetF71, {"F71_ABATIM", nAbatiment})
                                
                                If lDescFin
                                    AAdd(aSetF71, {"F71_TPDESC", cTpDescFin})
                                    AAdd(aSetF71, {"F71_DTLIMI", dDtLimDesc})
                                    AAdd(aSetF71, {"F71_DESFIN", nDescFin})
                                EndIf
                                
                                AAdd(aSetF71, {"F71_TXPERM", nTaxaPerm})
                                AAdd(aSetF71, {"F71_PERJUR", nPerJuros})
                                AAdd(aSetF71, {"F71_MULTA", nMulta})
                            EndIf
                            
                            If !F982MntPIX(aSetF71, "2", nRecnoF71, @cLogErro)
                                cLogErro += CRLF + STR0068
                                DisarmTransaction()
                                Break
                            EndIf
                            
                            SE1->(DbGoTo(nRecnoSE1))
                            F71->(DbSetOrder(1))
                            
                            If F71->(DbSeek(cIdDocF71))
                                While F71->(F71_FILIAL + F71_IDDOC) == cIdDocF71
                                    If F71->F71_STATUS == "9" .And. F71->F71_SOLCAN ==  "2"
                                        RecLock("F71")
                                        F71->F71_STATUS := "A"
                                        F71->(MsUnlock())
                                    EndIF
                                    
                                    F71->(DbSkip())
                                EndDo
                            EndIf
                            
                            If SE1->E1_SITUACA == "0"
                                If __lSitCPix
                                    cSituaCob := F022SITPIX()
                                EndIf
                                
                                If Empty(cSituaCob)
                                    cSituaCob := SE1->E1_SITUACA
                                EndIf
                                
                                Reclock("SE1", .F.)
                                SE1->E1_SITUACA := cSituaCob
                                SE1->(MsUnlock())
                            EndIf
                        Else
                            cLogErro := STR0066 + " (" + DTOC(Date()) + "|" + Time() + ")"
                            
                            If ValType(cResult) == "C" .And. !Empty(cResult) .And. ValType(cLogUtf8 := DecodeUTF8(cResult)) == "C"
                                cLogErro += CRLF + cLogUtf8
                            EndIf                            
                            
                            DisarmTransaction()
                            Break
                        EndIf
                        
                        FreeObj(oJSon)
                    EndIf
                EndIf
            End Transaction

            If !Empty(cLogErro)
                F982MntPIX({{"F71_MENSAG", cLogErro}}, "2", nRecnoF71)
            EndIf
            
            FwFreeArray(aHeader)
            FwFreeArray(aSetF71)            
        EndIf

        // Garantindo que o registro seja desbloqueado ao termino da execucao
        If IsLocked("SE1", nRecnoSE1)
            SE1->(MsRUnLock())
        EndIf 
        
        RestArea(aAreaSA1)
        RestArea(aAreaSE1)
        RestArea(aAreaF71)
        RestArea(aAreaAtu)            
        FwFreeArray(aAreaAtu)
        FwFreeArray(aAreaSA1)
        FwFreeArray(aAreaSE1)
        FwFreeArray(aAreaF71)    
    EndIf
Return Nil

/*/{Protheus.doc} baixaTitul
    Baixa de título recebido por meio do sistema PIX.
    
    @author Sivaldo Oliveira
    @since 11/11/2022
    
    @param oPix, Json, Arquivo json de título para baixa,
    quando usado o verbo http get do endpoint pix/webhook.
/*/
Method baixaTitul(oPix As JSon) Class Titulo    
    Local lGetPix    As Logical
    Local lContinua  As Logical
    Local lRetorno   As Logical
    Local lPropertJu As Logical
    Local lPropertMu As Logical
    Local lPropertDe As Logical    
    Local cIdTran    As Char
    Local cMotBaixa  As Char
    Local cHisBaixa  As Char
    Local cIdDocF71  As Char
    Local cResponse  As Char
    Local cVirgula   As Char
    Local cChaveF71  As Char
    Local cDataCred  As Char
    Local cLogErro   As Char
    Local nRecnoF71  As Numeric
    Local nRecnoSE1  As Numeric
    Local nQtdTransc As Numeric
    Local nTransacao As Numeric    
    Local nVlRecPix  As Numeric
    Local nVlrJuros  As Numeric
    Local nVlrDescon As Numeric
    Local nVlrMulta  As Numeric
    Local nDiasAtras As Numeric
    Local dDataCred  As Date
    Local aTitulo    As Array
    Local aBaixa     As Array
    Local aAreaF71   As Array
    Local aAreaSE1   As Array
    Local aAreaAtu   As Array
    Local aAreaSA6   As Array
    Local oJsonCred  As JSon
    
    //Parâmetros de entrada
    Default oPix := Nil
    
    //Inicializa variáveis.
    lGetPix    := (oPix != Nil)
    lContinua  := .T.
    lRetorno   := .T.
    lPropertJu := .F.
    lPropertMu := .F.
    lPropertDe := .F.
    cIdTran    := ""
    cMotBaixa  := ""
    cHisBaixa  := ""
    cIdDocF71  := ""
    cResponse  := ""
    cVirgula   := ""
    cChaveF71  := ""
    cDataCred  := ""
    cLogErro   := ""
    nRecnoF71  := 0
    nRecnoSE1  := 0
    nQtdTransc := 0
    nTransacao := 0
    nVlRecPix  := 0
    nVlrJuros  := 0
    nVlrDescon := 0
    nVlrMulta  := 0
    nDiasAtras := 0
    dDataCred  := dDataBase
    aTitulo    := {} 
    aBaixa     := {}
    aAreaF71   := {}
    aAreaSE1   := {}
    aAreaAtu   := {}
    aAreaSA6   := {}
    oJsonCred  := Nil
    
    If Type("nAbatim") != "N"
        Private nAbatim := 0
    EndIf
    
    If !(lContinua := lGetPix)
        cResponse := '{"' + STR0069 + '": "' + STR0070 + '"}'
    EndIf
    
    If lContinua
        If (ValType(oPix["pix"]) != "A") 
            lContinua := .F.
            cResponse := '{"' + STR0071 + '": "' + STR0072 + '"}'
        Else
            nQtdTransc := Len(oPix["pix"])
        EndIf
        
        If lContinua .And. nQtdTransc <= 0
            lContinua := .F.
            cResponse := '{"' + STR0073 + '": "' + STR0074 + '"}'
        EndIf
    EndIf
    
    If lContinua
        aAreaAtu := GetArea()
        DbSelectArea("SA6")
        aAreaSA6 := SA6->(GetArea())       
        DbSelectArea("F71")
        aAreaF71 := F71->(GetArea())
        DbSelectArea("SE1")
        aAreaSE1 := SE1->(GetArea())
        
        If __lExcImpo == Nil
            __lExcImpo := FindFunction("ExcluiImpo")
        EndIf
        
        If __nMotBaix == Nil
            __nMotBaix := TamSX3("FK1_MOTBX")[1]       
        EndIf        
        
        If __nHisBaix == Nil
            __nHisBaix := TamSX3("FK1_HISTOR")[1]       
        EndIf        
        
        If __lTemDic == Nil
            __lTemDic := F71->(FieldPos("F71_DIAEXP")) > 0 .And. F71->(FieldPos("F71_MULTA")) > 0
        EndIf        
        
        If __lCalJrDe == Nil
            __lCalJrDe := FindFunction("CalculaJr")
        EndIf
        
        aBaixa  := {}
        aTitulo := {}        
        
        For nTransacao := 1 To nQtdTransc
            If Empty(cVirgula) .And. Len(cResponse) > 11
                cVirgula := ","
            EndIf
            
            If ValType(oPix["pix"][nTransacao]["txid"]) != "C"                    
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0077 + cValToChar(nTransacao) + '"}'
                Loop
            EndIf
            
            If ValType(oPix["pix"][nTransacao]["valor"]) != "C"
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0078 + cValToChar(nTransacao) + '"}'
                Loop
            EndIf                
            
            cIdTran   := AllTrim(oPix["pix"][nTransacao]["txid"])
            nVlRecPix := Val(oPix["pix"][nTransacao]["valor"])
            cDataCred := oPix["pix"][nTransacao]["horario"]
            
            If ((cIdTran == Nil) .Or. Empty(cIdTran))
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0081 + cValToChar(nTransacao) + STR0082 + '"}'
                Loop
            EndIf
            
            If ((nVlRecPix == Nil) .Or. (nVlRecPix <= 0))
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0083 + cValToChar(nTransacao) + STR0084 + '"}'
                Loop
            EndIf
            
            //Validações do Monitor Pix (F71)
            F71->(DbSetOrder(3))
            If !F71->(DbSeek(cIdTran))
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0085 + cIdTran + STR0086 + '"}'
                Loop
            ElseIf !(lContinua := F71->F71_STATUS $ "3|4")
                cChaveF71 := F71->(F71_FILIAL+F71_IDDOC) 
                
                While !F71->(Eof()) .And. cIdTran == F71->F71_IDTRAN .And. F71->(F71_FILIAL+F71_IDDOC) == cChaveF71
                    If (lContinua := (F71->F71_STATUS $ "3|4" .And. !Empty(F71->F71_EMVPIX) .And. F71->F71_SOLCAN == "2"))
                        Exit
                    EndIf
                    
                    F71->(DbSkip())
                EndDo
                
                If !lContinua
                    cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0085 + cIdTran + STR0087 + '"}'
                    Loop
                EndIf
            ElseIf Empty(F71->F71_EMVPIX)
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0085 + cIdTran + STR0088 + '"}'
                Loop
            ElseIf F71->F71_SOLCAN != "2"
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0085 + cIdTran + STR0089 + '"}'
                Loop
            EndIf
            
            //Validações do cadastro de títulos (SE1)
            SE1->(DbSetOrder(1))
            If !SE1->(DbSeek(F71->(F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO)) .And. SE1->(MsRLock()))
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0090 + F71->(F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO) + STR0091 + '"}'
                Loop
            ElseIf SE1->E1_SALDO <= 0
                cResponse += cVirgula + '{"' + STR0076 + '": "' + STR0090 + F71->(F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO) + STR0092 + '"}'
                Loop
            ElseIf !Empty(SE1->E1_FILORIG) .And. cFilAnt != SE1->E1_FILORIG
                cFilAnt  := SE1->E1_FILORIG
            EndIf
            
            cMotBaixa   := PadR(AllTrim(SuperGetMV("MV_FINPIX7", .F., "NOR")), __nMotBaix)
            cHisBaixa   := PadR(AllTrim(SuperGetMV("MV_FINPIX8", .F., STR0075)), __nHisBaix)            
            lMsErroAuto := .F.
            cIdDocF71   := F71->F71_IDDOC
            cLogErro    := ""
            nRecnoF71   := F71->(Recno())            
            nRecnoSE1   := SE1->(Recno())            
            nVlrJuros   := 0
            nVlrDescon  := 0
            nVlrMulta   := 0
            nDiasAtras  := 0
            dDataCred   := SToD(StrTran(SubStr(cDataCred, 1, 10), "-", ""))
            aBaixa      := {}
            aTitulo     := {}
            
            If __lTemDic
                lPropertJu := oPix["pix"][nTransacao]["componentesValor"]:Hasproperty("juros")
                lPropertMu := oPix["pix"][nTransacao]["componentesValor"]:Hasproperty("multa")
                lPropertDe := oPix["pix"][nTransacao]["componentesValor"]:Hasproperty("desconto")                
                
                If __lCalJrDe .And. !Empty(F71->F71_VENCTO)                    
                    If lPropertJu .And. oPix["pix"][nTransacao]["componentesValor"]["juros"]["valor"] != Nil
                        nVlrJuros := Val(oPix["pix"][nTransacao]["componentesValor"]["juros"]["valor"])
                    ElseIf !lPropertJu .And. F71->(F71_TXPERM+F71_PERJUR) > 0 .And. dDataCred > F71->F71_VENCTO
                        nVlrJuros := CalculaJr(F71->F71_VLRPIX, F71->F71_TXPERM, F71->F71_PERJUR, dDataCred, F71->F71_VENCTO)
                    EndIf
                    
                    If lPropertDe .And. oPix["pix"][nTransacao]["componentesValor"]["desconto"]["valor"] != Nil
                        nVlrDescon := Val(oPix["pix"][nTransacao]["componentesValor"]["desconto"]["valor"])
                    ElseIf !lPropertDe .And. !Empty(F71->F71_TPDESC) .And. !Empty(F71->F71_DTLIMI)
                        nVlrDescon := CalculDFin(F71->F71_VLRPIX, F71->F71_DESFIN, F71->F71_TPDESC, dDataCred, F71->F71_DTLIMI, F71->F71_VENCTO)
                    EndIf
                EndIf
                
                If lPropertMu .And. oPix["pix"][nTransacao]["componentesValor"]["multa"]["valor"] != Nil
                    nVlrMulta := Val(oPix["pix"][nTransacao]["componentesValor"]["multa"]["valor"])
                ElseIf !lPropertMu .And. F71->F71_MULTA > 0 .And. !Empty(F71->F71_VENCTO) .And. dDataCred > F71->F71_VENCTO
                    nVlrMulta := F71->F71_MULTA                        
                    SA6->(DbSetOrder(1))                    
                    
                    If SA6->(MsSeek(xFilial("SA6")+F71->(F71_CODBAN+F71_AGENCI+F71_NUMCON))) .And. !Empty(SA6->A6_CFGPIX)
                        oJsonCred  := JsonObject():New() 
                        
                        If (ValType(oJsonCred:FromJson(SA6->A6_CFGPIX)) == "U")
                            If oJsonCred:Hasproperty("modalidademulta") .And. oJsonCred:Hasproperty("valordamulta") .And. oJsonCred["modalidademulta"] == 2
                                nVlrMulta := 0
                                
                                If (nDiasAtras := (dDataCred - F71->F71_VENCTO)) > 0
                                    nVlrMulta := ((F71->F71_MULTA / 100) * F71->F71_VLRPIX)
                                EndIf                          
                            EndIf
                        EndIf                        
                    EndIf
                EndIf
            EndIf
            
            //Matriz para baixa via execauto
            AAdd(aBaixa, {"E1_FILIAL",    SE1->E1_FILIAL,  Nil}) // 01
            AAdd(aBaixa, {"E1_PREFIXO",   SE1->E1_PREFIXO, Nil}) // 02
            AAdd(aBaixa, {"E1_NUM",       SE1->E1_NUM,     Nil}) // 03
            AAdd(aBaixa, {"E1_PARCELA",   SE1->E1_PARCELA, Nil}) // 04
            AAdd(aBaixa, {"E1_TIPO",      SE1->E1_TIPO,    Nil}) // 05
            AAdd(aBaixa, {"AUTMOTBX",     cMotBaixa,       Nil}) // 06
            AAdd(aBaixa, {"AUTHIST",      cHisBaixa,       Nil}) // 07
            AAdd(aBaixa, {"AUTDTBAIXA",   dDataCred,       Nil}) // 08
            AAdd(aBaixa, {"AUTDTCREDITO", dDataCred,       Nil}) // 09
            AAdd(aBaixa, {"AUTVALREC",    nVlRecPix,       Nil}) // 10
            AAdd(aBaixa, {"AUTJUROS",     nVlrJuros,       Nil}) // 11
            AAdd(aBaixa, {"AUTDESCONT",   nVlrDescon,      Nil}) // 12
            AAdd(aBaixa, {"AUTMULTA",     nVlrMulta,       Nil}) // 13
            AAdd(aBaixa, {"AUTBANCO",     F71->F71_CODBAN, Nil}) // 14
            AAdd(aBaixa, {"AUTAGENCIA",   F71->F71_AGENCI, Nil}) // 15
            AAdd(aBaixa, {"AUTCONTA",     F71->F71_NUMCON, Nil}) // 16
            
            Begin Transaction
                //Efetiva a baixa do título.
                MSExecAuto({|titulo, operacao,,,,,,,,,,pix|FINA070(titulo, operacao,,,,,,,,,,pix)}, aBaixa, 3,,,,,,,,,,.T.)
                
                If !lMsErroAuto
                    AAdd(aTitulo, {"F71_STATUS", "5"})
                    AAdd(aTitulo, {"F71_MENSAG", STR0102})
                    lRetorno := F982MntPIX(aTitulo, "2", nRecnoF71)
                EndIf
                
                If (lMsErroAuto .Or. !lRetorno)                    
                    cLogErro := '{"' + STR0076 + '": "' + STR0093 + F71->(F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO) + " " + FinGetHelp() + '"}'
                    cResponse += cVirgula + cLogErro
                    DisarmTransaction()
                ElseIf __lExcImpo .And. !Empty(cIdDocF71)
                    LibTitPix(cIdDocF71, nRecnoSE1)
                EndIf
            End Transaction
            
            If (lMsErroAuto .Or. !lRetorno) .And. !Empty(cLogErro)
                F982MntPIX({{"F71_MENSAG", cLogErro}}, "2", nRecnoF71)
            EndIf
        Next nTransacao
        
        If Empty(cResponse)
            cResponse := '{"titulo": [{"' + STR0076 + '": "' + cValToChar(nQtdTransc) + STR0101 + '"}]}'
        Else
            cResponse := '{"titulo":[' + cResponse + "]}"
        EndIf
        
        RestArea(aAreaF71)
        RestArea(aAreaSE1)
        RestArea(aAreaAtu)
        FwFreeArray(aAreaF71)
        FwFreeArray(aAreaSE1)
        FwFreeArray(aAreaAtu)
        FwFreeArray(aBaixa)
        FwFreeArray(aTitulo)
    EndIf
    
    Self:setRespons(cResponse)
Return Nil

/*/{Protheus.doc} cancelaCob
    Remove o registro de cobrança do sistema PIX.
    
    @author Sivaldo Oliveira
    @since 11/11/2022
    
    @param oToken, Object, Instância da classe token
    @param cCertifica, Char, Nome do arquivo de certificado com a extensão (.pem)
    @param cCertiKey, Char, Nome do arquivo chave do certificado com a extensão (.pem)
    @param lAutomacao, Logical, Valor Lógico que define se o processamento é de automação    
/*/
Method cancelaCob(oToken As Object, cCertifica As Char, cCertiKey As Char, lAutomacao As Logical) Class Titulo
    Local lContinua  As Logical
    Local cResponse  As Char
    Local cToken     As Char
    Local cBody      As Char
    Local cResult    As Char
    Local cIdDocF71  As Char
    Local cLogErro   As Char
    Local cHttpsQuot As Char
    Local nRecnoF71  As Numeric
    Local nHttpCode  As Numeric
    Local aHeader    As Array
    
    //Parâmetro de entrada.
    Default oToken     := Nil
    Default cCertifica := ""
    Default cCertiKey  := ""
    Default lAutomacao := .F.
    
    //Inicializa variáveis.
    lContinua  := (lAutomacao .Or. (oToken != Nil))
    cResponse  := ""
    cBody      := ""
    cToken     := ""
    cResult    := ""
    cIdDocF71  := ""
    cLogErro   := ""
    cHttpsQuot := ""
    nRecnoF71  := 0
    nHttpCode  := 0
    aHeader    := Nil
    
    If __lHttpsQu == Nil
        __lHttpsQu := FindFunction("HTTPSQuote")
    EndIf    
    
    If __lHttpsQu .And. lContinua .And. ((nRecnoF71 := Self:GetRecno()) > 0) .And. !Empty(cBody := Self:getBody())
        F71->(DbGoto(nRecnoF71))
        
        If !(lContinua := SE1->(MsSeek(F71->(F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO))) .And. SE1->(MsRLock()))
            cResponse := '{"' + STR0076 + '": "' + STR0061 + F71->(F71_FILIAL+F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO) + STR0062 + '"}'
        EndIf         
        
        If lContinua .And. (lAutomacao .Or. (!Empty(cToken := oToken:GetToken())))
            If (lAutomacao .Or. (Len(aHeader := AClone(Self:GetHeader())) >= 3))
                cIdDocF71  := F71->F71_IDDOC
                
                If !lAutomacao
                    aHeader[3] += cToken                
                    cHttpsQuot := 'HTTPSQuote((self:getUrlBase()+self:getPath()+"/"+F71->F71_IDTRAN+self:getAppKey()), cCertifica, cCertiKey, "", "PATCH", "", cBody, 120, aHeader, Nil, .F.)' 
                    cResult    := &cHttpsQuot 
                    nHttpCode  := HTTPGetStatus(Nil, Nil)
                EndIf
                
                If (lAutomacao .Or. ((nHttpCode == 200) .Or. (nHttpCode == 201)))
                    If F982MntPIX({{"F71_STATUS", "7"}}, "2", nRecnoF71, cLogErro)
                        LibTitPix(cIdDocF71, SE1->(Recno()))
                    EndIf
                ElseIf ValType(cResult) == "C" .And. !Empty(cResult)
                    cLogErro := cResult
                EndIf
            EndIf
        EndIf    
    Else
        If lContinua
            cResponse := '{"' + STR0094 + '": "' + STR0095 + '"}'
        Else
            cResponse := '{"' + STR0096 + '": "' + STR0097 + '"}'
        EndIf
    EndIf
    
    If (!Empty(cLogErro) .Or. !Empty(cResponse))
        If Empty(cLogErro)
            cLogErro := cResponse
            Self:setRespons(cResponse)
        EndIf
        
        F982MntPIX({{"F71_MENSAG", cLogErro}}, "2", nRecnoF71)
    EndIf
Return Nil
