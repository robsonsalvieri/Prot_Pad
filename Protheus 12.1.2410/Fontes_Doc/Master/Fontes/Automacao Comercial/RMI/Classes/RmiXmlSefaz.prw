#INCLUDE "TOTVS.CH"
#INCLUDE "RMIXMLSEFAZ.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiXmlSefaz
Classe para manitulação do XML da Sefaz
    
/*/
//-------------------------------------------------------------------
Class RmiXmlSefaz

    Method New(nTipo, cXml) //Metodo construtor da Classe

    Method getStatus()      //Metodo que retorna se houve erro
    Method getErro()        //Metodo que retorna a mensagem de erro

    Method get(cCaminho, aTags, xValRet, nItem, lText)  //Retorna informações do XML com base nos parametros passados 
    Method getDet(aTags, nItem,xValRet, lText)          //Retorna informações do nó de itens do xml (<det>)
    Method getTotal(aTags, xValRet)                     //Retorna informações do nó de totais do xml (<total>)
    Method getDetIcms(cTag, nItem, xValRet)             //Retornar informações do nó de impostos do itens do xml (<det><imposto><ICMS>)
    Method getDetPIS(cTag, nItem, xValRet)             	//Retornar informações do nó de impostos do itens do xml (<det><imposto><PIS>)
    Method getDetCOF(cTag, nItem, xValRet)             	//Retornar informações do nó de impostos do itens do xml (<det><imposto><COFINS>)

    Method layoutLivro()                                //Retorna o json com o layout dos campos que serão validados do livro fiscal 
    Method XMLCompar(oJson,oRegistro)                   //Faz a comparação do XML com os dados gravados nos livros fiscais
    
    Method ComparaMatx(oJson,aCliente,cFilMsg,oRegistro)                  //Compara o XML com os valores simulados pela MatxFis 

    Data cTipo          as Caractere
    Data cXml           as Caractere
    Data oXml           as Object

    Data oMessageError  as Object

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@type    method
@return  RmiXmlSefaz, O proprio objeto da classe

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New(nTipo, cXml) Class RmiXmlSefaz

    Local cError    := ""
    Local cWarning  := ""
    Local oXmlAux   := Nil
    Local oError    := Nil

    /*
    ModeloFiscal
    1 - SAT
    2 - NFC-e
    3 - MFE
    4 - PAF
    5 - NF-e
    */
    do case
        case nTipo == 1
            self:cTipo := "SAT"
        case nTipo == 2
            self:cTipo := "NFCE"
        case nTipo == 5
            self:cTipo := "SPED"
        oTherWise
            self:cTipo := "ECF"
    end case

    self:cXml           := cXml
    self:oMessageError  := LjMessageError():New()
    TRY EXCEPTION    
        If !Empty(self:cXml)
            oXmlAux := XmlParser( self:cXml, "_", @cError, @cWarning )

            If Empty(cError) .And. Empty(cWarning)

                If (XmlChildEx(oXmlAux, "_PROCINUTNFE") <> Nil) .or. (XmlChildEx(oXmlAux, "_RETINUTNFE") <> Nil)
                    self:oXml := Nil // quando for inutilização nao existe xml com conteudo valido.   
                Else
                    If self:cTipo == "SAT"
                        self:oXml := oXmlAux:_CFE:_INFCFE
                    Else
                        If XmlChildEx( oXmlAux, "_NFEPROC" ) <> Nil
                            self:oXml := oXmlAux:_NFEPROC:_NFE:_INFNFE
                        ElseIf XmlChildEx( oXmlAux, "_ENVINFE" ) <> Nil
                            self:oXml := oXmlAux:_ENVINFE:_NFE:_INFNFE 
                        ElseIF XmlChildEx( oXmlAux, "_NFE" ) <> Nil
                            self:oXml := oXmlAux:_NFE:_INFNFE    
                        Else
                            self:oMessageError:SetError( GetClassName(self), STR0002 + STR0003 ) //"Erro ao efetuar o parse do XML: " + "Documento XML possui formato desconhecido pela integração. Por favor verifique o conteúdo contido na mensagem de integração e caso necessário solicite o reenvio pelo sistema de origem."
                        EndIf
                    EndIf
                EndIf    
            Else
                self:oMessageError:SetError( GetClassName(self), STR0002 + cError + "|" + cWarning ) //"Erro ao efetuar o parse do XML: "
            EndIf
        EndIf
    CATCH EXCEPTION USING oError
        self:oMessageError:SetError( GetClassName(self), STR0002 + oError:ErrorStack ) //"Erro ao efetuar o parse do XML: "    
    END EXCEPTION    

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Método que retorna se houve erro

@type    method
@return  Lógico, Define se houve algum erro. (Erro = .F.)

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getStatus() Class RmiXmlSefaz
Return self:oMessageError:GetStatus()

//-------------------------------------------------------------------
/*/{Protheus.doc} getErro
Método que retorna a mensagem de erro

@type    method
@return  Caractere, Descrição do erro dependendo do tipo informado

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getErro() Class RmiXmlSefaz
Return self:oMessageError:GetMessage("E")

//-------------------------------------------------------------------
/*/{Protheus.doc} get
Retorna informações do XML com base nos parametros passados 

@type    Method
@param   cCaminho, Caractere, Caminho para acesso a tag
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag
@param   nItem, Numerico, Numero do item para localizar no xml
@param   lText, Lógico, Define se ira retorna a propriedade TEXT do XML
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method get(cCaminho, aTags, xValRet, nItem, lText) Class RmiXmlSefaz

    Local nTag      := 0
    Local cTag      := ""
    Local lContinua := .T.
    Local xValor    := ""

    Default cCaminho := "SELF:OXML"
    Default nItem    := 0
    Default lText    := .T.

    If Valtype(SELF:OXML) == "U"
        Return xValRet // caso o conteudo do xml for NIL retorna o que foi definido no layout com Default.
    EndIf    

    For nTag:=1 To Len(aTags)

        cTag := "_" + Upper( aTags[nTag] )

        If XmlChildEx( &(cCaminho), cTag) <> Nil
            cCaminho  := cCaminho + ":" + cTag
        Else
            lContinua := .F.
            Exit
        EndIf
    Next nTag

    Do Case
        //Executada tag
        Case lContinua
            If lText
                cCaminho := cCaminho + ":TEXT"
            EndIf

            xValor   := &(cCaminho)

            If Upper( SubStr(cTag, 2, 1) ) $ "Q|V|P" .And. ValType(xValor) == "C"
                xValor := Val(xValor)
            EndIf

        //Retorna valor default, caso não exista
        Case !lContinua .And. xValRet <> Nil
            xValor := xValRet

        OTherWise
            self:oMessageError:SetError( GetClassName(self), I18n("Tag #1 não encontrada no XML da SEFAZ, verifique!", {cCaminho + ":" + cTag}) )
    End Case

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} getDet
Retornar informações do nó de itens do xml (<det>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag
@param   lText, Lógico, Define se ira retorna a propriedade TEXT do XML
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDet(aTags, nItem, xValRet, lText) Class RmiXmlSefaz

    Local cCaminho := ""

    If ValType(self:oXml) != "U"
        If ValType(self:oXml:_DET) == "O"
            cCaminho := "SELF:OXML:_DET"
        Else
            cCaminho := "SELF:OXML:_DET[NITEM]"
        EndIf
    EndIf
Return self:get(cCaminho, aTags, xValRet, nItem, lText)

//-------------------------------------------------------------------
/*/{Protheus.doc} getTotal
Retornar informações do nó de totais do xml (<total>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getTotal(aTags, xValRet) Class RmiXmlSefaz
Return self:get("SELF:OXML:_TOTAL", aTags, xValRet, /*nItem*/, /*lText*/)

//-------------------------------------------------------------------
/*/{Protheus.doc} getDetIcms
Retornar informações do nó de impostos do itens do xml (<det><imposto><ICMS>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag (default)
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDetIcms(cTag, nItem, xValRet) Class RmiXmlSefaz

    Local xValor    := ""
    Local aIcms     := {"ICMS00"    , "ICMS10"   , "ICMS20", "ICMS30", "ICMS40"    ,;
                        "ICMS51"    , "ICMS60"   , "ICMS70", "ICMS90", "ICMSSN102" ,;
                        "ICMSSN500" , "ICMSSN900"}
    Local nIcms     := 0
    Local aAux      := {"imposto", "ICMS", ""}
    Local nPosAuxImp:= 3

    //Procura o ICMS do item
    If ValType(self:oXml) != "U"
        For nIcms:=1 To Len(aIcms)

            aAux[nPosAuxImp] := aIcms[nIcms]

            xValor := self:getDet(aAux, nItem, "", .F.)

            If !Empty(xValor)
                Exit
            EndIf
        Next nIcms

        //Não encontrou nenhum ICMS no item
        If Empty(xValor)  

            self:oMessageError:SetError( GetClassName(self), "ICMS não reconhecido, verifique o nó de impostos do item no XML da SEFAZ!")
            LjGrvLog( GetClassName(self), "ICMS no item do XML da SEFAZ, não implementado: {TAG, ICMS IMPLEMENTADOS, ICMS DO XML SEFAZ}", { cTag, aIcms, self:getDet({"imposto", "ICMS"}, nItem, /*xValRet*/, .F.) } )       
        Else

            //SAT não tem tag de base
            If self:cTipo == "SAT" .And. cTag == "vBC" 
                xValor := self:getDet({"prod", "vProd"}, nItem, /*xValRet*/) - self:getDet({"prod", "vDesc"}, nItem, 0)

            //Retorno o conteudo da tag do ICMS
            Else
                Aadd(aAux, cTag)
                xValor := self:getDet(aAux, nItem, xValRet)
            EndIf
        EndIf
    Else
        xValor := xValRet // Se nao existir o objeto retorna o Default xValRet
    EndIf
    FwFreeArray(aAux)
    FwFreeArray(aIcms)

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} getDetPIS
Retornar informações do nó de impostos do itens do xml (<det><imposto><PIS>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag (default)
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDetPIS(cTag, nItem, xValRet) Class RmiXmlSefaz

    Local xValor:= ""
    Local aList := {"PISAliq","PISOutr","PISQtde", "PISNT","PISSN"}
    Local aAux  := {"imposto", "PIS",""}
    Local nX    := 0
    
   //Procura o PIS do item
    For nX:=1 To Len(aList)

        aAux[3] := aList[nX]

        xValor := self:getDet(aAux, nItem, "", .F.)

        If !Empty(xValor)
            Exit
        EndIf
    Next nX
    
    If Empty(xValor)
        xValor := xValRet
        LjGrvLog( GetClassName(self), "PIS com retorno default (#1) para TAG (#2), porque não foi encontrada TAGs de PIS no XML da SEFAZ.", {cValToChar(xValRet), cTag} )
    Else
        
        Aadd(aAux, cTag)
        xValor := self:getDet(aAux, nItem, xValRet)   

        If self:cTipo == "SAT" .And. cTag == "pPIS" 
            xValor := xValor * 100 //"Ajuste para quando é SAT" o valor é <pPIS>0.0165</pPIS> e quando é NFC-e <pPIS>1.65</pPIS> 
        EndIf

    EndIf
  
    FwFreeArray(aAux)
    FwFreeArray(aList)
    
Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} getDetCOF
Retornar informações do nó de impostos do itens do xml (<det><imposto><COFINS>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag (default)
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDetCOF(cTag, nItem, xValRet) Class RmiXmlSefaz

    Local xValor:= ""
    Local aList := {"COFINSAliq","COFINSQtde","COFINSNT", "COFINSSN","COFINSOutr"}
    Local aAux  := {"imposto", "COFINS",""}
    Local nX    := 0
    
   //Procura o COFINS do item
    For nX:=1 To Len(aList)

        aAux[3] := aList[nX]

        xValor := self:getDet(aAux, nItem, "", .F.)

        If !Empty(xValor)
            Exit
        EndIf
    Next nX
    
    If Empty(xValor)
        xValor := xValRet
        LjGrvLog( GetClassName(self), "COFINS com retorno default (#1) para TAG (#2), porque não foi encontrada TAGs de COFINS no XML da SEFAZ.", {cValToChar(xValRet), cTag} )
    Else
        Aadd(aAux, cTag)
        xValor := self:getDet(aAux, nItem, xValRet)

        If self:cTipo == "SAT" .And. cTag == "pCOFINS" 
            xValor := xValor * 100 //"Ajuste para quando é SAT" o valor é <pCOFINS>0.0165</pCOFINS> e quando é NFC-e <pCOFINS>1.65</pCOFINS> 
        EndIf  

    EndIf
  
    FwFreeArray(aAux)
    FwFreeArray(aList)
    
Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} XMLCompar
Método que retorna a comparação do XML com SF3 e SFT

@type    method
@return  Caractere, Descrição do erro dependendo do tipo informado

@author  Everson S P Junior
@since   15/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method XMLCompar(oJson,oRegistro) Class RmiXmlSefaz
Local nItem     := 1
Local aTagsJ    := {}
Local nX     := 1
Local cCampo    := ""
Local cMsgInfo  := ""
Local cTabela   := GetNextAlias()
Local cDoc      := PADR(IIF( self:cTipo == 'SAT' , self:get( , {'ide', 'nCFe'}, ''), IIF(self:cTipo $ 'NFCE|SPED', self:get( , {'ide', 'nNF'}, oRegistro['Ccf']), oRegistro['Ccf']) ),TAMSX3('F3_NFISCAL')[1])
Local cSerie    := PADR(self:get(,{'ide','serie'},''),TAMSX3('F3_SERIE')[1])
Local cSerSat   := PADR(self:get(,{'ide','nserieSAT'},''),TAMSX3('F3_SERSAT')[1])
Local cXValor    := ""
Local cPValor    := ""

Default oJson   := self:layoutLivro()
aTagsJ := oJson:GetNames()

For nX:=1 to Len(aTagsJ)
    cCampo += aTagsJ[nX]+","    
Next 
cCampo := SubStr(cCampo, 1, Len(cCampo)-1)


cSelect := " SELECT FT_ITEM, "+cCampo
cSelect += " FROM " + RetSqlName("SFT") + " SFT "
cSelect += " WHERE SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND SFT.D_E_L_E_T_ = ' '"
cSelect += " AND SFT.FT_NFISCAL = '" +cDoc+ "'"

If !Empty(cSerie)
    cSelect += " AND SFT.FT_SERIE = '" +cSerie+ "'"
    LjGrvLog("RMIXMLSEFAZ"," [XMLCompar] BUSCANDO VENDA DO TIPO NFCE ->  ",cDoc+"|"+cSerie)    
else
    cSelect += " AND SFT.FT_SERSAT = '" +cSerSat+ "'"
    LjGrvLog("RMIXMLSEFAZ"," [XMLCompar] BUSCANDO VENDA DO TIPO SAT ->  ",cDoc+"|"+cSerSat)    
EndIf
    
DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)


While !(cTabela)->( Eof() )
    nItem := VAL((cTabela)->FT_ITEM)
    For nX:=1 to Len(aTagsJ)
        If Valtype((cTabela)->&(aTagsJ[nX])) != "C"
            cXValor := Alltrim(CVALTOCHAR(&(oJson[aTagsJ[nX]])))
            cPValor := Alltrim(CVALTOCHAR((cTabela)->&(aTagsJ[nX])))
        else
            cXValor := Alltrim(&(oJson[aTagsJ[nX]]))
            cPValor := Alltrim((cTabela)->&(aTagsJ[nX]))
        EndIf
        If !(cXValor == cPValor)
            cMsgInfo += "PRODUTO: ["+Self:getDet({'prod', 'cProd'}, nItem,0)+ "] ITEM: ["+ Alltrim(STR(nItem))+"]"+CRLF
            cMsgInfo += "CAMPO: -> "+Alltrim(aTagsJ[nX])+CRLF
            cMsgInfo += "PROTHEUS:-> "+cPValor+CRLF
            cMsgInfo += "XML-SEFAZ:->"+cXValor+CRLF+CRLF
        End
    Next 
    (cTabela)->( DbSkip() )
EndDo
(cTabela)->( DbCloseArea() )

If !Empty(cMsgInfo)
    self:oMessageError:SetError(STR0001+CRLF+"[DOC: "+cDoc+ IIF(!Empty(cSerie),"[SERIE: "+cSerie+"]"+CRLF,"[SERSAT: "+cSerSat+"]"+CRLF)+cMsgInfo)//"Alerta: Houve uma diferença entre os tributos que seriam calculados pelo Protheus(MATXFIS) e o transmitido pelo PDV OMNI, porém a venda foi gravada/escriturada com sucesso no Protheus. Verifique o cadastro/configuração fiscal do Produto no Protheus e os tributos que o PDV OMNI calculou."
            
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ComparaMatx
Método que retorna a comparação do XML com SF3 e SFT

@type    method
@param   oJson, Objeto JSON, Com nomes das tags para acessar a informação
@param   aCliente, Array, Array com os dados de código de cliente (A1_COD) e loja (A1_LOJA)
@param   cFilMsg, Caractere, informa a filial onde será gerada a simulação do MATXFIS 
@param   oRegistro, Objeto JSON, Contém as informações da mensagem de origem da venda
 
@return  Nulo

@author  Evandro Pattaro
@since   22/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method ComparaMatx(oJson,aCliente,cFilMsg,oRegistro) Class RmiXmlSefaz

Local aRet  := {}
Local nItem := 0
Local nY    := 0
Local aItens := {}
Local aTagsJ := {}
Local aCampos := {}
Local cXValor := "" //Valor extraído do XML conforme campo da conferência
Local cMValor := "" //Valor extraído da simulação da MATXFIS conforme campo da conferência
Local cMsgInfo  := ""
Local cDoc      := PADR(IIF( self:cTipo == 'SAT' , self:get( , {'ide', 'nCFe'}, ''), IIF(self:cTipo $ 'NFCE|SPED', self:get( , {'ide', 'nNF'}, oRegistro['Ccf']), oRegistro['Ccf']) ),TAMSX3('F3_NFISCAL')[1])
Local cSerie    := PADR(self:get(,{'ide','serie'},''),TAMSX3('F3_SERIE')[1])
Local cSerSat   := PADR(self:get(,{'ide','nserieSAT'},''),TAMSX3('F3_SERSAT')[1])

Default oJson       := JsonObject():New()
Default aCliente    := {,}
Default cFilMsg     := ""

aTagsJ := oJson:GetNames()

For nItem := 1 to Len(aTagsJ)
    aAdd(aCampos,{aTagsJ[nItem]})
Next nItem

If ValType(SELF:OXML:_DET) == "A"
    For nItem := 1 to Len(SELF:OXML:_DET)
        aAdd(aItens,{self:getDet({"prod","cProd"},nItem),cFilMsg,self:getDet({"prod","qCom"},nItem),self:getDet({"prod","vDesc"},nItem,0),self:getDet({"prod","vUnCom"},nItem,0)})
    Next nItem
Else
    aAdd(aItens,{self:getDet({"prod","cProd"},nItem),cFilMsg,self:getDet({"prod","qCom"},nItem),self:getDet({"prod","vDesc"},nItem,0),self:getDet({"prod","vUnCom"},nItem,0)})    
EndIf

aRet := GetImpPrd(aItens,aCampos,aCliente[1],aCliente[2])

If Len(aRet) > 0
    For nItem := 1 To Len(aItens) 
        
        nY := Ascan(aRet,{|x| x[5] == nItem })    //Posiciono no Arrray de retorno da MatxFis o item do xml que vou comparar

        While nY <= Len(aRet) .And. aRet[nY][5] == nItem //Enquanto o produto do retorno da matxfis condizer com o produto que estou no momento
            If Valtype(aRet[nY][4]) != "C"
                cXValor := Alltrim(cValtoChar(&(oJson[aRet[nY][3]])))
                cMValor := Alltrim(cValtoChar(aRet[nY][4]))
            else
                cXValor := Alltrim(&(oJson[aRet[nY][3]]))
                cMValor := Alltrim(aRet[nY][4])
            EndIf
            If !(cXValor == cMValor)
                cMsgInfo += STR0004+"["+aRet[nY][2]+ "]"+STR0005+"["+ Alltrim(STR(nItem))+"]"+CRLF //PRODUTO: //ITEM: 
                cMsgInfo += STR0006+Alltrim(aRet[nY][3])+CRLF
                cMsgInfo += STR0007+cMValor+CRLF
                cMsgInfo += STR0008+cXValor+CRLF
            End
            nY++
        EndDo
    Next nItem
EndIf
If !Empty(cMsgInfo)
    self:oMessageError:ClearError()
    self:oMessageError:SetError(STR0009+CRLF+"[DOC: "+cDoc+ IIF(!Empty(cSerie),"[SERIE: "+cSerie+"]"+CRLF,"[SERSAT: "+cSerSat+"]"+CRLF)+cMsgInfo)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} layoutLivro
Layout Utilizado para De/Para de campos para comparar no Livro Fiscal.
Antiga função GetLayout.

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method layoutLivro() Class RmiXmlSefaz

    Local cJson := ""
    Local oJson := JsonObject():New()

    //Para os campos FT_BASEPIS e FT_BASECOF, é incluida uma exceção quando CST = 06 (Operação Tributável a Alíquota Zero), pois a base de cálculo é destacada no Protheus mesmo no XML não vindo a informação de base.
    BeginContent var cJson
    {
        "FT_CFOP": "Self:getDet({'prod', 'CFOP'}, nItem,0)",
        "FT_ALIQICM": "Self:getDetIcms('pICMS', nItem, 0) + Self:getDetIcms('pFCP',nItem, 0)",
        "FT_VALCONT": "Self:getDet({'prod', 'vProd'}, nItem,0) - (Self:getDet({'prod', 'vDesc'}, nItem, 0) + Self:getDet({'prod', 'vRatDesc'}, nItem, 0)) + Self:getDet({'prod', 'vOutro'}, nItem, 0) + Self:getDet({'prod', 'vRatAcr'}, nItem, 0)",
        "FT_VALICM": "Self:getDetIcms('vICMS', nItem, 0) + Self:getDetIcms('vFCP',nItem, 0)",
        "FT_ESPECIE": "IIF( self:cTipo == 'SAT', 'SATCE', self:cTipo )",
        "FT_PRODUTO": "Self:getDet({'prod', 'cProd'}, nItem,'')",
        "FT_CLASFIS": "Self:getDetIcms('Orig', nItem, ' ') + Self:getDetIcms('CST', nItem, '  ')",
        "FT_POSIPI": "Self:getDet({'prod', 'NCM'}, nItem,'')",
        "FT_PRCUNIT": "A410ARRED(Self:getDet({'prod', 'vUnCom'}, nItem,0) - ( ( Self:getDet({'prod', 'vDesc'}, nItem, 0) + Self:getDet({'prod', 'vRatDesc'}, nItem, 0) ) / Self:getDet({'prod', 'qCom'}, nItem,0)),'FT_PRCUNIT')",
        "FT_DESCONT": "Self:getDet({'prod', 'vDesc'}, nItem, 0) + Self:getDet({'prod', 'vRatDesc'}, nItem, 0)",
        "FT_TOTAL": "Self:getDet({'prod', 'vProd'}, nItem,0)",
        "FT_BASEPIS": "IIF( RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),IIF( Empty(Self:getDetPIS('vBC', nItem, 0)) .And. Self:getDetPIS('CST', nItem, '') == '06',(cTabela)->FT_BASEPIS,Self:getDetPIS('vBC', nItem, 0)), 0)",
        "FT_BRETPIS": "IIF( !RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),Self:getDetPIS('vBC', nItem, 0), 0)",
        "FT_VALPIS": "IIF( RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),Self:getDetPIS('vPIS', nItem, 0), 0)",
        "FT_VRETPIS": "IIF( !RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),Self:getDetPIS('vPIS', nItem, 0), 0)",
        "FT_BASECOF": "IIF( RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),IIF( Empty(Self:getDetCOF('vBC', nItem, 0)) .And. Self:getDetCOF('CST', nItem, '') == '06',(cTabela)->FT_BASECOF,Self:getDetCOF('vBC', nItem, 0)), 0)",
        "FT_BRETCOF": "IIF( !RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),Self:getDetCOF('vBC', nItem, 0), 0)",
        "FT_ARETCOF": "IIF( !RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),Self:getDetCOF('pCOFINS', nItem, 0), 0)",
        "FT_VALCOF": "IIF( RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),Self:getDetCOF('vCOFINS', nItem, 0), 0)",
        "FT_VRETCOF": "IIF( !RMIRetApur(Posicione('SA1',1,xFilial('SA1')+(cTabela)->FT_CLIEFOR+(cTabela)->FT_LOJA,'SA1->A1_CGC')),Self:getDetCOF('vCOFINS', nItem, 0), 0)",
        "FT_CSTPIS": "Self:getDetPIS('CST', nItem, '')",
        "FT_CSTCOF": "Self:getDetCOF('CST', nItem, '')",
        "FT_CLIEFOR": "(cTabela)->FT_CLIEFOR",
        "FT_LOJA": "(cTabela)->FT_LOJA"
    }
    EndContent

    oJson:FromJson(cJson)

    //SAT não tem uma tag especifica para base de icms no xml da sefaz, por não ter certeza da base esta validação não será feita
    if allTrim(self:cTipo) <> "SAT"
        oJson["FT_BASEICM"] := "self:getDetIcms('vBC', nItem, 0)"
    endIf        

Return oJson
