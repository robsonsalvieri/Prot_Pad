#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIENVLIVEOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvLiveObj
Classe responsável pelo envio de dados ao Live

/*/
//-------------------------------------------------------------------
Class RmiEnvLiveObj From RmiEnviaObj

    Data oLive          As Object

    Method New()            //Metodo construtor da Classe

    Method PreExecucao()    //Metodo com as regras para efetuar conexão com o sistema de destino

    Method Envia()          //Metodo responsavel por enviar a mensagens ao Live

    Method Grava()          //Metodo que ira atualizar a situação da distribuição e gravar o de\para

	//Nota de entrada
    Method XmlSf1(oPublica) 	//Metodo que monta o XML da nota de entrada
	Method RetEmiSf1(cField) 	//Metodo responsavel em retornar o fornecedor para nota de entrada
	Method RetDestSf1(cField) 	//Retorna a filial para a qual foi emitido a nota de entrada
	Method RetItSf1(oPublica)	//Retorna os produtos para alimentar a tag <Itens> da nota de entrada

	//Nota de saída
	Method XmlSf2(oPublica) 	//Metodo que monta o XML da nota de saída
	Method RetEmiSf2(cField) 	//Retorna a filial responsavel em emitir a nota de saída
	Method RetDestSf2(cField) 	//Retorna o cliente da nota de saída
	Method RetItSf2(oPublica) 	//Retorna os produtos para alimentar a tag <Itens> da nota de saída

	//Utilizado na Nota de Entrada e Nota de Saída
	Method RetSb1(cField, cCodFilial, cCodProd) //Metodo responsavel em retornar o produto

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvLiveObj
    //cProcesso para tratamento de Thread de processos.
    _Super:New("LIVE",cProcesso)

    If self:lSucesso
        self:oLive := totvs.protheus.retail.rmi.classes.live.Live():New()
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

Mesma logica do metodo do fonte RmiBusLiveObj.prw

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvLiveObj

    Local cError    := ""
    Local cWarning  := ""
    Local cBody     := ""
    Local cAux      := ""

    //Token do Live eh valido por 1 dia
    If !Empty(self:cToken)
        Return Nil
    EndIf

    Self:oPreExecucao := RMIConWsdl(self:oConfAssin["url_token"], @cError)

    If Empty(cError)

        //Seta a operação que será executada
        If !self:oPreExecucao:SetOperation( self:oConfAssin["operacao"] )   //"ObterChaveAcessoLC_Integracao"

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, {ProcName(), "SetOperation", self:oPreExecucao:cError} )     //"[#1] Problema ao efetuar o #2: #3"
        Else

            cBody := "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>"
            cBody += "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:liv='http://LiveConnector/'>"
            cBody +=   "<SOAP-ENV:Body>"
            cBody +=       "<ObterChaveAcessoLC_Integracao xmlns='http://LiveConnector/'>"
            cBody +=           "<CodigoSistemaSatelite>" + self:oLive:getSatelite(self) + "</CodigoSistemaSatelite>"
            cBody +=           "<Usuario>" + self:oConfAssin["usuario"] + "</Usuario>"
            cBody +=           "<Senha>" + self:oConfAssin["senha"] + "</Senha>"
            cBody +=           "<PersisteChave>true</PersisteChave>"
            cBody +=       "</ObterChaveAcessoLC_Integracao>"
            cBody +=   "</SOAP-ENV:Body>"
            cBody += "</SOAP-ENV:Envelope>"        

            //Envia a mensagem a ser processada
            If self:oPreExecucao:SendSoapMsg(cBody)

                self:cRetorno := self:oPreExecucao:GetSoapResponse()

                //Pesquisa a tag com o retorno do token
                cAux := RmiXGetTag(self:cRetorno, "<ObterChaveAcessoLC_IntegracaoResult>", .T.)

                If !Empty(cAux)

                    self:oRetorno := XmlParser(cAux, "_", @cError, @cWarning)

                    //Carrega token
                    If self:oRetorno <> Nil

                        If self:oConfProce:hasProperty("subsistemasatelite") .And. Valtype(self:oConfProce["subsistemasatelite"]) != "U" .And. !Empty(self:oConfProce["subsistemasatelite"])
                            self:oConfProce["subtoken"] := self:oRetorno:_ObterChaveAcessoLC_IntegracaoResult:Text
                        Else
                            self:cToken                 := self:oRetorno:_ObterChaveAcessoLC_IntegracaoResult:Text
                        EndIf
                        
                        //Atualiza o token no assinante
                        self:SalvaConfig()
                    EndIf
                EndIf

                If Empty(cAux) .Or. self:oRetorno == Nil
                    self:lSucesso := .F.
                    self:cRetorno := I18n(STR0001, { ProcName(), "XmlParser", cError + CRLF + cWarning + CRLF + self:cRetorno} )    //"[#1] Problema ao efetuar o #2: #3"
                EndIf
            Else

                self:lSucesso := .F.
                self:cRetorno := I18n(STR0001, { ProcName(), "SendSoapMsg", self:oPreExecucao:cError} )     //"[#1] Problema ao efetuar o #2: #3"
            EndIf

        EndIf
    Else
        self:lSucesso := .F.
        self:cRetorno := I18n(STR0001, {ProcName(), "XmlParser", self:oPreExecucao:cError} )    //"[#1] Problema ao efetuar o #2: #3"
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao Live

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia(nVez) Class RmiEnvLiveObj

    Local cAux     := ""
    Local cError   := ""

    Default nVez     := 0

    Self:oEnvia := RMIConWsdl(self:oConfProce["url"], @cError)

    //Faz o parse de uma URL
    If !Empty(cError)

        self:lSucesso := .F.
        self:cRetorno := I18n(STR0001, { ProcName(), "ParseUrl", self:oEnvia:cError} )      //"[#1] Problema ao efetuar o #2: #3"
    Else

        //Seta a operação que será executada
        If !self:oEnvia:SetOperation( self:oConfProce["operacao"] )     //ManterProdutoLC_Integracao_Xml

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, { ProcName(), "SetOperation", self:oEnvia:cError} )      //"[#1] Problema ao efetuar o #2: #3"
        Else

            //Controle de reenvio com geração de novo token
            nVez++

            //Envia a mensagem a ser processada
            self:cBody := EnCodeUtf8(self:cBody)
            If self:oEnvia:SendSoapMsg(self:cBody)

                self:cRetorno := self:oEnvia:GetSoapResponse()
                self:cRetorno := StrTran(self:cRetorno, "&lt;", "<")
                self:cRetorno := StrTran(self:cRetorno, "&gt;", ">")

                //Pesquisa a tag com o retorno das vendas
                cAux := RmiXGetTag(self:cRetorno, self:oConfProce["tagretorno"], .T.)   //"<LC_Retorno>"
 
            Else
                // -- Em caso de conferencia tratamos o retorno, assim podemos tomar ações automaticas.
                cAux := DeCodeUtf8(self:oEnvia:cError)
  
            EndIf

            If "PROCESSAMENTO REALIZADO COM SUCESSO" $ Upper(cAux)

                //Por enquanto o processamento do Live é assincrono, então não carrega a chave externa
                self:lSucesso := .T.
                self:cRetorno := cAux

            ElseIf "CHAVE DE ACESSO INV" $ Upper(cAux)

                If nVez > 1

                    self:lSucesso := .F.
                    self:cRetorno := I18n(STR0002, {ProcName(), self:cRetorno} )    //"[#1] Reenvio já foi feito, mas erro persiste: #2"
                Else
                    
                    //Gera novo token para tentar o reenvio
                    self:cToken := ""
                    
                    self:PreExecucao() 

                    self:CarregaBody()

                    Self:Envia(nVez)
                EndIf
            Else
                self:lSucesso := .F.
                If Alltrim(Self:cProcesso) == "CONFERENCIA" .AND. !Empty(self:oEnvia:GetSoapResponse())
                    
                    cAux := self:oEnvia:GetSoapResponse()
                    cAux := StrTran(cAux, "&lt;", "<")
                    cAux := StrTran(cAux, "&gt;", ">")
                   
                    self:cRetorno := DeCodeUtf8(RmiXGetTag(cAux, self:oConfProce["tagretorno"], .T.))
                Else
                    self:cRetorno := I18n(STR0003, { ProcName(), self:oConfProce["operacao"], cAux} )  //"[#1] Retorno desconhecido, na operação #2: #3"
                EndIf 

            EndIf
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição e gravar o de\para

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiEnvLiveObj

    Local cStatus := ""     //1=A processar, 2=Processado, 3=Erro, 6=Aguardando Confirmação
    
    If self:lSucesso

        //Retorno sincrono do Live
        If AllTrim(self:cProcesso) == "NOTA SAIDA CANC"
            cStatus := "2"

        //Retorno assincrono do Live
        Else 
            cStatus := "6"
        EndIf

    Else
        cStatus := "3"
    EndIf

    _Super:Grava(cStatus)
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlSf1
Metodo responsavel por gerar o XML de envio da nota de entrada

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method XmlSf1(oPublica,cFazDePara) Class RmiEnvLiveObj

Local cXml 	:= "" //Monta o XML da nota Entrada
Local nI	:= 0 //Variavel de loop

Default cFazDePara	:= .T.
Default oPublica 	:= Nil

If ValType(oPublica) == "J"

	cXml := '<![CDATA[<?xml version="1.0" encoding="UTF-8"?>'
	cXml += '<nfeProc versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
	cXml += '	<NFe xmlns="http://www.portalfiscal.inf.br/nfe">'
	cXml += '	<infNFe Id="' + oPublica["F1_CHVNFE"] + '" versao="4.00">'
	cXml += '	<ide>'
	cXml += '		<cUF>33</cUF>'
	cXml += '		<cNF>ESTSE0005</cNF>'
	cXml += '		<natOp>COMPRA</natOp>'
	cXml += '		<nNF>' + oPublica["F1_DOC"] + '</nNF>'
	cXml += '		<serie>' + oPublica["F1_SERIE"] + '</serie>'
	cXml += '		<mod>55</mod>'
	cXml += '		<dhEmi>' + FWTimeStamp(3, SToD(oPublica["F1_EMISSAO"]), "00:00:00") + '</dhEmi>'
	cXml += '		<dhSaiEnt>' + FWTimeStamp(3, SToD(oPublica["F1_EMISSAO"]), "00:00:00") + '</dhSaiEnt>'
	cXml += '		<tpNF>0</tpNF>'
	cXml += '		<idDest>1</idDest>'
	cXml += '		<tpNFe>1</tpNFe>'
	cXml += '		<indFinal>0</indFinal>'
	cXml += '		<indPres>1</indPres>'
	cXml += '	</ide>'

    //Para nota de entrada a tag <emit> sera enviado o fornecedor que esta na SF1
	cXml += '	<emit>'
	cXml += '		<CNPJ>' + Self:RetEmiSf1("A2_CGC") + '</CNPJ>'
	cXml += '		<Nome>' + AllTrim(Self:RetEmiSf1("A2_NOME")) + '</Nome>'
	cXml += '		<Fant>' + AllTrim(Self:RetEmiSf1("A2_NOME")) + '</Fant>'
	cXml += '		<enderEmit>'
	cXml += '			<Lgr>' + AllTrim(Self:RetEmiSf1("A2_END")) + '</Lgr>'
	cXml += '			<nro>SN</nro>'
	cXml += '			<Bairro/>'
	cXml += '			<cMun>' + AllTrim(Self:RetEmiSf1("A2_COD_MUN")) + '</cMun>'
	cXml += '			<Mun>' + AllTrim(Self:RetEmiSf1("A2_MUN")) + '</Mun>'
	cXml += '			<UF>' + AllTrim(Self:RetEmiSf1("A2_EST")) + '</UF>'
	cXml += '			<CEP>' + AllTrim(Self:RetEmiSf1("A2_CEP")) + '</CEP>'
	cXml += '			<cPais>1058</cPais>'
	cXml += '			<Pais>BRASIL</Pais>'
	cXml += '		</enderEmit>'
	cXml += '		<IE>' + AllTrim(Self:RetEmiSf1("A2_INSCR")) + '</IE>'
	cXml += '		<CRT> </CRT>'
	cXml += '	</emit>'

    /*Para nota de entrada a tag <dest> sera enviado o cnpj da filial que realizou a nota,
    neste é alterado o cFilAnt pegando do campo F1_FILIAL e depois retornado o cFilAnt*/
	cXml += '	<dest>'
	cXml += '		<CNPJ>' + Self:RetDestSf1("M0_CGC") + '</CNPJ>'
	cXml += '		<Nome>' + AllTrim(Self:RetDestSf1("M0_FILIAL")) + '</Nome>'
	cXml += '		<enderDest>'
	cXml += '			<Lgr>' + "" + '</Lgr>'
	cXml += '			<nro>SN</nro>'
	cXml += '			<Bairro/>'
	cXml += '			<cMun>' + "" + '</cMun>'
	cXml += '			<Mun>' + "" + '</Mun>'
	cXml += '			<UF>' + "" + '</UF>'
	cXml += '			<cPais>1058</cPais>'
	cXml += '			<Pais>BRASIL</Pais>'
	cXml += '		</enderDest>'
	cXml += '		<indIEDest>2</indIEDest>'
	cXml += '	</dest>'

	//Add os itens
    If oPublica["SD1"] <> Nil .And. ValType( oPublica["SD1"] ) == "A"

        For nI := 1 To Len(oPublica["SD1"])

            cXml += '	<det nItem="' + cValToChar(nI) + '">'
            cXml += '		<prod>'
            If cFazDePara
                cXml += '			<cProd>' + Self:DePara("SB1", FWxFilial("SB1", oPublica["SD1"][nI]["D1_FILIAL"]) + "|" + oPublica["SD1"][nI]["D1_COD"], 1, 0, .T. , "LIVE") + '</cProd>'
            Else
                cXml += '			<cProd>' +oPublica["SD1"][nI]["D1_COD"]+ '</cProd>'
            EndIf    
            cXml += '			<ean/>'
            cXml += '			<Prod>' + AllTrim(Self:RetSb1("B1_DESC", oPublica["F1_FILIAL"], oPublica["SD1"][nI]["D1_COD"])) + '</Prod>'
            cXml += '			<NCM/>'
            cXml += '			<CFOP>1949</CFOP>' // solicitar o vinculo do CFOP com CodigoExternoTipoDocumentoFiscal> definir na integração
            cXml += '			<uCom>' + AllTrim(Self:RetSb1("B1_UM", oPublica["F1_FILIAL"], oPublica["SD1"][nI]["D1_COD"])) + '</uCom>'
            cXml += '			<qCom>' + cValToChar(oPublica["SD1"][nI]["D1_QUANT"]) + '</qCom>'
            cXml += '			<vUnCom>' + cValToChar(oPublica["SD1"][nI]["D1_VUNIT"]) + '</vUnCom>'
            cXml += '			<vProd>' + cValToChar(oPublica["SD1"][nI]["D1_TOTAL"]) + '</vProd>'
            cXml += '			<eantrib/>'
            cXml += '			<uTrib>' + AllTrim(Self:RetSb1("B1_UM", oPublica["F1_FILIAL"], oPublica["SD1"][nI]["D1_COD"])) + '</uTrib>'
            cXml += '			<qTrib>9.00</qTrib>'
            cXml += '			<vUnTrib>' + cValToChar(oPublica["SD1"][nI]["D1_VUNIT"]) + '</vUnTrib>'
            cXml += '			<indTot>1</indTot>'
            cXml += '		</prod>'
            cXml += '		<imposto>'
            cXml += '			<vTotTrib>0</vTotTrib>'
            cXml += '			<ICMS>'
            cXml += '				<ICMS00>'
            cXml += '					<orig>2</orig>'
            cXml += '					<CST>00</CST>'
            cXml += '					<modBC>0</modBC>'
            cXml += '					<vBC>0.0</vBC>'
            cXml += '					<pICMS>0.0</pICMS>'
            cXml += '					<vICMS>0.0</vICMS>'
            cXml += '				</ICMS00>'
            cXml += '			</ICMS>'
            cXml += '			<IPI>'
            cXml += '				<cEnq>0</cEnq>'
            cXml += '				<IPINT>'
            cXml += '					<CST>0</CST>'
            cXml += '				</IPINT>'
            cXml += '			</IPI>'
            cXml += '			<PIS>'
            cXml += '				<PISOutr>'
            cXml += '					<CST>0</CST>'
            cXml += '					<vBC>0.00</vBC>'
            cXml += '					<pPIS>0.0000</pPIS>'
            cXml += '					<vPIS>0.00</vPIS>'
            cXml += '				</PISOutr>'
            cXml += '			</PIS>'
            cXml += '			<COFINS>'
            cXml += '				<COFINSOutr>'
            cXml += '					<CST>0</CST>'
            cXml += '					<vBC>0.00</vBC>'
            cXml += '					<pCOFINS>0.0000</pCOFINS>'
            cXml += '					<vCOFINS>0.00</vCOFINS>'
            cXml += '				</COFINSOutr>'
            cXml += '			</COFINS>'
            cXml += '		</imposto>'
            cXml += '		<imposto>'
            cXml += '			<codigo>ICMSST</codigo>'
            cXml += '			<cpl>'
            cXml += '				<pmvast>0</pmvast>'
            cXml += '			</cpl>'
            cXml += '			<Tributo>'
            cXml += '				<CST>50</CST>'
            cXml += '				<modBC>0</modBC>'
            cXml += '				<pRedBC>0</pRedBC>'
            cXml += '				<vBC>0</vBC>'
            cXml += '				<aliquota>0</aliquota>'
            cXml += '				<valor>0</valor>'
            cXml += '				<qtrib>0</qtrib>'
            cXml += '				<vltrib>0</vltrib>'
            cXml += '			</Tributo>'
            cXml += '		</imposto>'
            cXml += '		<imposto>'
            cXml += '			<codigo>PIS</codigo>'
            cXml += '				<Tributo>'
            cXml += '					<CST>08</CST>'
            cXml += '					<modBC/>'
            cXml += '					<pRedBC/>'
            cXml += '					<vBC>0</vBC>'
            cXml += '					<aliquota>0</aliquota>'
            cXml += '					<vlTrib>0</vlTrib>'
            cXml += '					<qTrib>0</qTrib>'
            cXml += '					<valor>0</valor>'
            cXml += '				</Tributo>'
            cXml += '		</imposto>'
            cXml += '		<imposto>'
            cXml += '			<codigo>COFINS</codigo>'
            cXml += '			<Tributo>'
            cXml += '				<CST>08</CST>'
            cXml += '				<modBC/>'
            cXml += '				<pRedBC/>'
            cXml += '				<vBC>0</vBC>'
            cXml += '				<aliquota>0</aliquota>'
            cXml += '				<vlTrib>0</vlTrib>'
            cXml += '				<qTrib>0</qTrib>'
            cXml += '				<valor>0</valor>'
            cXml += '			</Tributo>'
            cXml += '		</imposto>'
            cXml += '		<infadprod/>'
            cXml += '	</det>'

        Next nI
    EndIf

	cXml += '	<total>'
	cXml += '		<ICMSTot>'
	cXml += '			<vBC>0</vBC>'
	cXml += '			<vICMS>0</vICMS>'
	cXml += '			<vBCST>0</vBCST>'
	cXml += '			<vICMSST>0</vICMSST>'
	cXml += '			<despesa>0</despesa>'
	cXml += '			<vNF>' + cValToChar(oPublica["F1_VALBRUT"]) + '</vNF>'
	cXml += '			<dCompet>20180708</dCompet>'
	cXml += '			<vFCP>0.00</vFCP>'
	cXml += '			<vST>00.00</vST>'
	cXml += '			<vFCPST>0.00</vFCPST>'
	cXml += '			<vFCPSTRet>0.00</vFCPSTRet>'
	cXml += '			<vProd>0.00</vProd>'
	cXml += '			<vFrete>0.00</vFrete>'
	cXml += '			<vSeg>0.00</vSeg>'
	cXml += '			<vDesc>0.00</vDesc>'
	cXml += '			<vII>0.00</vII>'
	cXml += '			<vIPI>0.00</vIPI>'
	cXml += '			<vIPIDevol>0.00</vIPIDevol>'
	cXml += '			<vPIS>0.00</vPIS>'
	cXml += '			<vCOFINS>0.00</vCOFINS>'
	cXml += '			<vOutro>0.00</vOutro>'
	cXml += '			<vTotTrib>0.00</vTotTrib>'
	cXml += '		</ICMSTot>'
	cXml += '	</total>'
	cXml += '	<transp>'
	cXml += '		<modFrete>1</modFrete>'
	cXml += '	</transp>'
	cXml += '	<pagamento>'
	cXml += '		<detPag>'
	cXml += '			<indForma>0</indForma>'
	cXml += '			<forma>99</forma>'
	cXml += '			<valor>' + cValToChar(oPublica["F1_VALBRUT"]) + '</valor>'
	cXml += '		</detPag>'
	cXml += '		<vTroco>0</vTroco>'
	cXml += '	</pagamento>'
	cXml += '	<infAdic>'
	cXml += '		<Cpl>[ContrTSS=2020-11-25#15:42:02#]</Cpl>'
	cXml += '	</infAdic>'
	cXml += '	<infRespTec>'
	cXml += '		<CNPJ>53113791000122</CNPJ>'
	cXml += '		<Contato>Rodrigo de Almeida Sartorio</Contato>'
	cXml += '		<email>resp_tecnico_dfe_protheus@totvs.com.br</email>'
	cXml += '		<fone>1128593904</fone>'
	cXml += '	</infRespTec>'
	cXml += '	</infNFe>'
	cXml += '	</NFe>'
	cXml += '	<protNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
	cXml += '		<infProt>'
	cXml += '			<chNFe>' + oPublica["F1_CHVNFE"] + '</chNFe>'
	cXml += '		</infProt>'
	cXml += '	</protNFe>'
	cXml += '</nfeProc>]]]]>'

EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} RetItSf1
Retorna os produtos para alimentar a tag <Itens> da nota de entrada

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method RetItSf1(oPublica,cFazDePara) Class RmiEnvLiveObj

Local cXml 	:= "" //Monta o XML da nota Entrada
Local nI	:= 0 //Variavel de loop

Default cFazDePara	:= .T.
Default oPublica	:= Nil

If ValType(oPublica) == "J"

	//Add os itens
	For nI := 1 To Len(oPublica["SD1"])
		cXml += '<LC_ItemNotaFiscalXML>'
		If cFazDePara
            cXml += '	<CodigoItemNota>' + Self:DePara("SB1", FWxFilial("SB1", oPublica["SD1"][nI]["D1_FILIAL"]) + "|" + oPublica["SD1"][nI]["D1_COD"], 1, 0, .T. , "LIVE") + '</CodigoItemNota>'
        Else
            cXml += '	<CodigoItemNota>' +oPublica["SD1"][nI]["D1_COD"]+ '</CodigoItemNota>'
        EndIf    
		cXml += '	<PosicaoItemNota>' + cValToChar(nI) + '</PosicaoItemNota>'
		cXml += '	<PrecoUnitarioItemNota>' + cValToChar(oPublica["SD1"][nI]["D1_VUNIT"]) + '</PrecoUnitarioItemNota>'
		cXml += '	<QuantidadeDevolvidaItemNota>0</QuantidadeDevolvidaItemNota>'
		cXml += '	<QuantidadeRecebidaItemNota>' + cValToChar(oPublica["SD1"][nI]["D1_VUNIT"]) + '</QuantidadeRecebidaItemNota>'
		cXml += '	<ValorBruto>' + cValToChar(oPublica["SD1"][nI]["D1_TOTAL"]) + '</ValorBruto>'
		cXml += '	<ValorLiquido>' + cValToChar(oPublica["SD1"][nI]["D1_TOTAL"]) + '</ValorLiquido>'
		cXml += '	<ValorTributos>0</ValorTributos>'
		cXml += '	<TotalDespesas>0</TotalDespesas>'
		cXml += '</LC_ItemNotaFiscalXML>'
	Next 

	If Empty(cXml)
		Self:lSucesso := .F.
		Self:cRetorno := STR0008 //"Não existem produtos a serem enviados na nota de entrada!"
	EndIf

EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} RetEmiSf1
Retorna o fornecedor conforme a filial da SF1 para 
envio da nota de entrada

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method RetEmiSf1(cField) Class RmiEnvLiveObj

Local cBkpFilial 	:= cFilAnt //Guarda a filial logada
Local cRet 			:= "" //Variavel de retorno
Local cCodFor		:= Self:oConfProce["CodFornecedor"] //Código padrão do fornecedor
Local cCodLoj		:= Self:oConfProce["CodLoja"] //Codigo padrão da loja do fornecedor

cFilAnt := self:oPublica['F1_FILIAL']

If !Empty(cCodFor) .AND. !Empty(cCodLoj)
	cRet := Posicione('SA2',1,xFilial('SA2') + PadR(cCodFor,TamSx3('A2_COD')[1]) + PadR(cCodLoj, TamSx3('A2_LOJA')[1]), cField)
Else
	cRet := Posicione('SA2',1,xFilial('SA2') + PadR(Self:oPublica['F1_FORNECE'],TamSx3('A2_COD')[1]) + PadR(Self:oPublica['F1_LOJA'], TamSx3('A2_LOJA')[1]), cField)
EndIf

If Empty(cRet) .AND. cField == "A2_CGC"
	Self:lSucesso := .F.
	Self:cRetorno := STR0004 + IIF(!Empty(cCodFor), cCodFor, Self:oPublica['F1_FORNECE']) +	STR0005 + IIF(!Empty(cCodLoj), cCodLoj, Self:oPublica['F1_LOJA']) //"Fornecedor não encontrado na base de dados do Protheus, tabela (SA2), código do fornecedor: " # " - código da loja: "
EndIf

cFilAnt := cBkpFilial

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDestSf1
Retorna o destinatario para quem foi emitido a 
nota fiscal da nota de entrada

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method RetDestSf1(cField) Class RmiEnvLiveObj

Local cBkpFilial 	:= cFilAnt //Guarda a filial logada
Local aFiliais		:= {} //Recebe o retorno da função FWArrFilAtu()
Local cRet 			:= "" //Variavel de retorno

cFilAnt := Self:oPublica['F1_FILIAL']

aFiliais := FWArrFilAtu()

Do Case

	Case cField == "M0_CGC"
		cRet := aFiliais[18]

	Case cField == "M0_FILIAL"
		cRet := aFiliais[7]

EndCase

cFilAnt := cBkpFilial

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlSf2
Metodo responsavel por gerar o XML de envio da nota de saída

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method XmlSf2(oPublica,cFazDePara) Class RmiEnvLiveObj

Local cXml 	:= "" //Monta o XML da nota Entrada
Local nI	:= 0 //Variavel de loop

Default cFazDePara	:=.T.
Default oPublica	:= Nil

If ValType(oPublica) == "J"

	cXml := '<![CDATA[<?xml version="1.0" encoding="UTF-8"?>'
	cXml += '<nfeProc versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
	cXml += '	<NFe xmlns="http://www.portalfiscal.inf.br/nfe">'
	cXml += '	<infNFe Id="' + oPublica["F2_CHVNFE"] + '" versao="4.00">'
	cXml += '	<ide>'
	cXml += '		<cUF>33</cUF>'
	cXml += '		<cNF>ESTSE0005</cNF>'
	cXml += '		<natOp>SAIDA DE MERCADORIAS</natOp>'
	cXml += '		<nNF>' + Padl( oPublica["F2_DOC"], TamSx3("F2_DOC")[1], "0" ) + '</nNF>'
	cXml += '		<serie>' + oPublica["F2_SERIE"] + '</serie>'
	cXml += '		<mod>55</mod>'
	cXml += '		<dhEmi>' + FWTimeStamp(3, SToD(oPublica["F2_EMISSAO"]), "00:00:00") + '</dhEmi>'
	cXml += '		<dhSaiEnt>' + FWTimeStamp(3, SToD(oPublica["F2_EMISSAO"]), "00:00:00") + '</dhSaiEnt>'
	cXml += '		<tpNF>0</tpNF>'
	cXml += '		<idDest>1</idDest>'
	cXml += '		<tpNFe>1</tpNFe>'
	cXml += '		<indFinal>0</indFinal>'
	cXml += '		<indPres>1</indPres>'
	cXml += '	</ide>'

    //Para nota de entrada a tag <emit> sera enviado o fornecedor que esta na SF1
	cXml += '	<emit>'
	cXml += '		<CNPJ>' + Self:RetEmiSf2("M0_CGC") + '</CNPJ>'
	cXml += '		<Nome>' + AllTrim(Self:RetEmiSf2("M0_FILIAL")) + '</Nome>'
	cXml += '		<Fant>' + AllTrim(Self:RetEmiSf2("M0_FILIAL")) + '</Fant>'
	cXml += '		<enderEmit>'
	cXml += '			<Lgr>' + "" + '</Lgr>'
	cXml += '			<nro>SN</nro>'
	cXml += '			<Bairro/>'
	cXml += '			<cMun>' + "" + '</cMun>'
	cXml += '			<Mun>' + "" + '</Mun>'
	cXml += '			<UF>' + "" + '</UF>'
	cXml += '			<CEP>' + "" + '</CEP>'
	cXml += '			<cPais>1058</cPais>'
	cXml += '			<Pais>BRASIL</Pais>'
	cXml += '		</enderEmit>'
	cXml += '		<IE>' + "" + '</IE>'
	cXml += '		<CRT> </CRT>'
	cXml += '	</emit>'

    /*Para nota de entrada a tag <dest> sera enviado o cnpj da filial que realizou a nota,
    neste é alterado o cFilAnt pegando do campo F1_FILIAL e depois retornado o cFilAnt*/
	cXml += '	<dest>'
	cXml += '		<CNPJ>' + Self:RetDestSf2("A1_CGC") + '</CNPJ>'
	cXml += '		<Nome>' + AllTrim(Self:RetDestSf2("A1_NOME")) + '</Nome>'
	cXml += '		<enderDest>'
	cXml += '			<Lgr>' + AllTrim(Self:RetDestSf2("A1_END")) + '</Lgr>'
	cXml += '			<nro>SN</nro>'
	cXml += '			<Bairro/>'
	cXml += '			<cMun>' + AllTrim(Self:RetDestSf2("A1_COD_MUN")) + '</cMun>'
	cXml += '			<Mun>' + AllTrim(Self:RetDestSf2("A1_MUN")) + '</Mun>'
	cXml += '			<UF>' + AllTrim(Self:RetDestSf2("A1_EST")) + '</UF>'
	cXml += '			<cPais>1058</cPais>'
	cXml += '			<Pais>BRASIL</Pais>'
	cXml += '		</enderDest>'
	cXml += '		<indIEDest>2</indIEDest>'
	cXml += '	</dest>'

	//Add os itens
    If oPublica["SD2"] <> Nil .And. ValType( oPublica["SD2"] ) == "A"

        For nI := 1 To Len(oPublica["SD2"])

            cXml += '	<det nItem="' + cValToChar(nI) + '">'
            cXml += '		<prod>'
            If cFazDePara
                cXml += '			<cProd>' + Self:DePara("SB1", FWxFilial("SB1", oPublica["SD2"][nI]["D2_FILIAL"]) + "|" + oPublica["SD2"][nI]["D2_COD"], 1, 0, .T. , "LIVE") + '</cProd>'
            Else
                cXml += '			<cProd>' +oPublica["SD2"][nI]["D2_COD"]+ '</cProd>'
            EndIf    
            cXml += '			<ean/>'
            cXml += '			<Prod>' + AllTrim(Self:RetSb1("B1_DESC", oPublica["F2_FILIAL"], oPublica["SD2"][nI]["D2_COD"])) + '</Prod>'
            cXml += '			<NCM/>'
            cXml += '			<CFOP>5949</CFOP>'// solicitar o vinculo do CFOP com CodigoExternoTipoDocumentoFiscal> definir na integração
            cXml += '			<uCom>' + AllTrim(Self:RetSb1("B1_UM", oPublica["F2_FILIAL"], oPublica["SD2"][nI]["D2_COD"])) + '</uCom>'
            cXml += '			<qCom>' + cValToChar(oPublica["SD2"][nI]["D2_QUANT"]) + '</qCom>'
            cXml += '			<vUnCom>' + cValToChar(oPublica["SD2"][nI]["D2_VUNIT"]) + '</vUnCom>'
            cXml += '			<vProd>' + cValToChar(oPublica["SD2"][nI]["D2_TOTAL"]) + '</vProd>'
            cXml += '			<eantrib/>'
            cXml += '			<uTrib>' + AllTrim(Self:RetSb1("B1_UM", oPublica["F2_FILIAL"], oPublica["SD2"][nI]["D2_COD"])) + '</uTrib>'
            cXml += '			<qTrib>9.00</qTrib>'
            cXml += '			<vUnTrib>' + cValToChar(oPublica["SD2"][nI]["D2_VUNIT"]) + '</vUnTrib>'
            cXml += '			<indTot>1</indTot>'
            cXml += '		</prod>'
            cXml += '		<imposto>'
            cXml += '			<vTotTrib>0</vTotTrib>'
            cXml += '			<ICMS>'
            cXml += '				<ICMS00>'
            cXml += '					<orig>2</orig>'
            cXml += '					<CST>00</CST>'
            cXml += '					<modBC>0</modBC>'
            cXml += '					<vBC>0.0</vBC>'
            cXml += '					<pICMS>0.0</pICMS>'
            cXml += '					<vICMS>0.0</vICMS>'
            cXml += '				</ICMS00>'
            cXml += '			</ICMS>'
            cXml += '			<IPI>'
            cXml += '				<cEnq>0</cEnq>'
            cXml += '				<IPINT>'
            cXml += '					<CST>0</CST>'
            cXml += '				</IPINT>'
            cXml += '			</IPI>'
            cXml += '			<PIS>'
            cXml += '				<PISOutr>'
            cXml += '					<CST>0</CST>'
            cXml += '					<vBC>0.00</vBC>'
            cXml += '					<pPIS>0.0000</pPIS>'
            cXml += '					<vPIS>0.00</vPIS>'
            cXml += '				</PISOutr>'
            cXml += '			</PIS>'
            cXml += '			<COFINS>'
            cXml += '				<COFINSOutr>'
            cXml += '					<CST>0</CST>'
            cXml += '					<vBC>0.00</vBC>'
            cXml += '					<pCOFINS>0.0000</pCOFINS>'
            cXml += '					<vCOFINS>0.00</vCOFINS>'
            cXml += '				</COFINSOutr>'
            cXml += '			</COFINS>'
            cXml += '		</imposto>'
            cXml += '		<imposto>'
            cXml += '			<codigo>ICMSST</codigo>'
            cXml += '			<cpl>'
            cXml += '				<pmvast>0</pmvast>'
            cXml += '			</cpl>'
            cXml += '			<Tributo>'
            cXml += '				<CST>50</CST>'
            cXml += '				<modBC>0</modBC>'
            cXml += '				<pRedBC>0</pRedBC>'
            cXml += '				<vBC>0</vBC>'
            cXml += '				<aliquota>0</aliquota>'
            cXml += '				<valor>0</valor>'
            cXml += '				<qtrib>0</qtrib>'
            cXml += '				<vltrib>0</vltrib>'
            cXml += '			</Tributo>'
            cXml += '		</imposto>'
            cXml += '		<imposto>'
            cXml += '			<codigo>PIS</codigo>'
            cXml += '				<Tributo>'
            cXml += '					<CST>08</CST>'
            cXml += '					<modBC/>'
            cXml += '					<pRedBC/>'
            cXml += '					<vBC>0</vBC>'
            cXml += '					<aliquota>0</aliquota>'
            cXml += '					<vlTrib>0</vlTrib>'
            cXml += '					<qTrib>0</qTrib>'
            cXml += '					<valor>0</valor>'
            cXml += '				</Tributo>'
            cXml += '		</imposto>'
            cXml += '		<imposto>'
            cXml += '			<codigo>COFINS</codigo>'
            cXml += '			<Tributo>'
            cXml += '				<CST>08</CST>'
            cXml += '				<modBC/>'
            cXml += '				<pRedBC/>'
            cXml += '				<vBC>0</vBC>'
            cXml += '				<aliquota>0</aliquota>'
            cXml += '				<vlTrib>0</vlTrib>'
            cXml += '				<qTrib>0</qTrib>'
            cXml += '				<valor>0</valor>'
            cXml += '			</Tributo>'
            cXml += '		</imposto>'
            cXml += '		<infadprod/>'
            cXml += '	</det>'

        Next nI
    EndIf

	cXml += '	<total>'
	cXml += '		<ICMSTot>'
	cXml += '			<vBC>0</vBC>'
	cXml += '			<vICMS>0</vICMS>'
	cXml += '			<vBCST>0</vBCST>'
	cXml += '			<vICMSST>0</vICMSST>'
	cXml += '			<despesa>0</despesa>'
	cXml += '			<vNF>' + cValToChar(oPublica["F2_VALBRUT"]) + '</vNF>'
	cXml += '			<dCompet>20180708</dCompet>'
	cXml += '			<vFCP>0.00</vFCP>'
	cXml += '			<vST>00.00</vST>'
	cXml += '			<vFCPST>0.00</vFCPST>'
	cXml += '			<vFCPSTRet>0.00</vFCPSTRet>'
	cXml += '			<vProd>0.00</vProd>'
	cXml += '			<vFrete>0.00</vFrete>'
	cXml += '			<vSeg>0.00</vSeg>'
	cXml += '			<vDesc>0.00</vDesc>'
	cXml += '			<vII>0.00</vII>'
	cXml += '			<vIPI>0.00</vIPI>'
	cXml += '			<vIPIDevol>0.00</vIPIDevol>'
	cXml += '			<vPIS>0.00</vPIS>'
	cXml += '			<vCOFINS>0.00</vCOFINS>'
	cXml += '			<vOutro>0.00</vOutro>'
	cXml += '			<vTotTrib>0.00</vTotTrib>'
	cXml += '		</ICMSTot>'
	cXml += '	</total>'
	cXml += '	<transp>'
	cXml += '		<modFrete>1</modFrete>'
	cXml += '	</transp>'
	cXml += '	<pagamento>'
	cXml += '		<detPag>'
	cXml += '			<indForma>0</indForma>'
	cXml += '			<forma>99</forma>'
	cXml += '			<valor>' + cValToChar(oPublica["F2_VALBRUT"]) + '</valor>'
	cXml += '		</detPag>'
	cXml += '		<vTroco>0</vTroco>'
	cXml += '	</pagamento>'
	cXml += '	<infAdic>'
	cXml += '		<Cpl>[ContrTSS=2020-11-25#15:42:02#]</Cpl>'
	cXml += '	</infAdic>'
	cXml += '	<infRespTec>'
	cXml += '		<CNPJ>53113791000122</CNPJ>'
	cXml += '		<Contato>Rodrigo de Almeida Sartorio</Contato>'
	cXml += '		<email>resp_tecnico_dfe_protheus@totvs.com.br</email>'
	cXml += '		<fone>1128593904</fone>'
	cXml += '	</infRespTec>'
	cXml += '	</infNFe>'
	cXml += '	</NFe>'
	cXml += '	<protNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
	cXml += '		<infProt>'
	cXml += '			<chNFe>' + oPublica["F2_CHVNFE"] + '</chNFe>'
	cXml += '		</infProt>'
	cXml += '	</protNFe>'
	cXml += '</nfeProc>]]]]>'

EndIf

Return cXml


//-------------------------------------------------------------------
/*/{Protheus.doc} RetItSf2
Retorna os produtos para alimentar a tag <Itens> da nota de saída

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method RetItSf2(oPublica,cFazDePara) Class RmiEnvLiveObj

Local cXml 	:= "" //Monta o XML da nota Entrada
Local nI	:= 0 //Variavel de loop

Default cFazDePara 	:= .T.
Default oPublica	:= Nil

If ValType(oPublica) == "J"

    If oPublica["SD2"] <> Nil .And. ValType( oPublica["SD2"] ) == "A"

        //Add os itens
        For nI := 1 To Len(oPublica["SD2"])
            cXml += '<LC_ItemNotaFiscalXML>'
            If cFazDePara
                cXml += '	<CodigoItemNota>' + Self:DePara("SB1", FWxFilial("SB1", oPublica["SD2"][nI]["D2_FILIAL"]) + "|" + oPublica["SD2"][nI]["D2_COD"], 1, 0, .T., "LIVE") + '</CodigoItemNota>'
            Else
                cXml += '	<CodigoItemNota>' +oPublica["SD2"][nI]["D2_COD"]+ '</CodigoItemNota>'
            EndIf    
            cXml += '	<PosicaoItemNota>' + cValToChar(nI) + '</PosicaoItemNota>'
            cXml += '	<PrecoUnitarioItemNota>' + cValToChar(oPublica["SD2"][nI]["D2_PRCVEN"]) + '</PrecoUnitarioItemNota>'
            cXml += '	<QuantidadeDevolvidaItemNota>' + cValToChar(oPublica["SD2"][nI]["D2_QTDEDEV"]) + '</QuantidadeDevolvidaItemNota>'
            cXml += '	<QuantidadeRecebidaItemNota>' + cValToChar(oPublica["SD2"][nI]["D2_QUANT"]) + '</QuantidadeRecebidaItemNota>'
            cXml += '	<ValorBruto>' + cValToChar(oPublica["SD2"][nI]["D2_TOTAL"]) + '</ValorBruto>'
            cXml += '	<ValorLiquido>' + cValToChar(oPublica["SD2"][nI]["D2_TOTAL"]) + '</ValorLiquido>'
            cXml += '	<ValorTributos>0</ValorTributos>'
            cXml += '	<TotalDespesas>0</TotalDespesas>'
            cXml += '</LC_ItemNotaFiscalXML>'
        Next nI
    EndIf


	If Empty(cXml)
		Self:lSucesso := .F.
		Self:cRetorno := STR0009 //"Não existem produtos a serem enviados na nota de saída!"
	EndIf

EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} RetEmiSf2
Retorna a filial que fez a emissão da nota de saída

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method RetEmiSf2(cField) Class RmiEnvLiveObj

Local cBkpFilial 	:= cFilAnt //Guarda a filial logada
Local aFiliais		:= {} //Recebe o retorno da função FWArrFilAtu()
Local cRet 			:= "" //Variavel de retorno

cFilAnt := Self:oPublica['F2_FILIAL']

aFiliais := FWArrFilAtu()

Do Case

	Case cField == "M0_CGC"
		cRet := aFiliais[18]

	Case cField == "M0_FILIAL"
		cRet := aFiliais[7]

EndCase

cFilAnt := cBkpFilial

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDestSf2
Retorna o cliente para qual foi emitido a nota de saída

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method RetDestSf2(cField) Class RmiEnvLiveObj

Local cBkpFilial 	:= cFilAnt                          //Guarda a filial logada
Local cRet 			:= ""                               //Variavel de retorno
Local cCodFor		:= self:oConfProce["CodCliente"]    //Código padrão do cliente
Local cCodLoj		:= self:oConfProce["CodLoja"]       //Codigo padrão da loja do cliente

cFilAnt := self:oPublica['F2_FILIAL']

If !Empty(cCodFor) .And. !Empty(cCodLoj)
	cRet := Posicione('SA1',1,xFilial('SA1') + PadR(cCodFor,TamSx3('A1_COD')[1]) + PadR(cCodLoj, TamSx3('A1_LOJA')[1]), cField)
Else
    cRet := Posicione('SA1',1,xFilial('SA1') + PadR(self:oPublica['F2_CLIENTE'],TamSx3('A1_COD')[1]) + PadR(self:oPublica['F2_LOJA'], TamSx3('A1_LOJA')[1]), cField)
EndIf

If Empty(cRet) .And. cField == "A1_CGC"
	Self:lSucesso := .F.
	Self:cRetorno := STR0006 + AllTrim(self:oPublica['F2_CLIENTE']) + STR0005 + AllTrim(self:oPublica['F2_LOJA']) //"Cliente não encontrado na base de dados do Protheus, tabela (SA1), código do cliente: " # " - código da loja: "
EndIf

cFilAnt := cBkpFilial

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSb1
Posiciona no produto conforme o parametro cCodProd, e retorna o conteúdo
do campo que foi passado no parametro cField

@author  Bruno Almeida
@version 1.0
@date 15/12/2020
/*/
//-------------------------------------------------------------------
Method RetSb1(cField, cCodFilial, cCodProd) Class RmiEnvLiveObj

Local cBkpFilial 	:= cFilAnt  //Guarda a filial logada
Local cRet 			:= ""       //Variavel de retorno

cFilAnt := cCodFilial
cRet := Posicione("SB1", 1, xFilial("SB1") + PadR(cCodProd,TamSx3('B1_COD')[1]), cField)

cFilAnt := cBkpFilial

Return cRet