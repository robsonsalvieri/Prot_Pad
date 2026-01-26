#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "TRYEXCEPTION.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PshMotorPromocoesOnlineObj
Método construtor da Classe

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Class PshMotorPromocoesOnlineObj From RmiEnviaObj

Method New()         
Method Conect()   
Method SetPublica()
Method GetStruJson(cTabela, nTypeJson, lControle, cTipReg)
Method GetHeader()
Method TrataRetXML(cRetorno,aRetPromo)


Data aPromocoes     as Array
Data aFormPgt       as Array  
Data oConect        as  Objetc 


EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} PshMotorPromocoesOnlineObj
Método construtor da Classe

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante,cProcesso) Class PshMotorPromocoesOnlineObj
Self:aFormPgt := {}
_Super:New(cAssinante,cProcesso)
Self:SetaProcesso(cProcesso)
Self:SetPublica()//Gera o oPublica com os campos a serem alimentados com os dados
return


//-------------------------------------------------------------------
/*/{Protheus.doc} PshMotorPromocoesOnlineObj
Método construtor da Classe

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method Conect() Class PshMotorPromocoesOnlineObj

self:CarregaBody()// Carrega o Body de envio conexão.

If self:lSucesso 
    self:aPromocoes:= {}
    self:oConect := FWRest():New(Self:oConfAssin["url"])
    self:oConect:SetPath(Self:oConfAssin["Path"])
    self:oConect:SetPostParams(EncodeUTF8(Self:cBody))
    LjGrvLog(" PshMotorPromocoesOnlineObj ", "Conect - Enviado Json motor de promoções" ,{EncodeUTF8(Self:cBody)})
    If self:oConect:Post( self:GetHeader() ) 
        
        self:cRetorno := DeCodeUTF8(self:oConect:GetResult())
        If "xml" $ self:cRetorno
            Self:TrataRetXML(self:cRetorno,self:aPromocoes)
            LjGrvLog(" PshMotorPromocoesOnlineObj ", "Conect - Retornou Json de promoções" ,{self:cRetorno})
        EndIf
    Else
        Self:lSucesso   := .F.
        self:cRetorno   := iif(self:oConect:oResponseH:cStatusCode == "400", self:oConect:cResult ,self:oConect:GetLastError() + " - [" + Self:oConfAssin["url"] + "]" + CRLF)                
        LjGrvLog(" PshMotorPromocoesOnlineObj ", "Conect - Não obteve sucesso no retorno => " ,{self:cRetorno}) 
        Aadd(self:aPromocoes,{Self:lSucesso,self:cRetorno}) 
    EndIf
EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPublica()
Função que gera o Json com os campos da tabela passada, 
no registro que esta posicionado

@author  Rafael Tenorio da Costa
@since   30/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetPublica() Class PshMotorPromocoesOnlineObj
    Local cJson      := ""
    Local cJsonFilho := ""
    If self:oPublica == Nil
        self:oPublica := JsonObject():New()
    EndIf
    cJson       := Self:GetStruJson("SLQ", 0)
    cJsonFilho  := Self:GetStruJson("SLR", 0, .T.,"")
    cJson       := SubStr(cJson,1,Len(cJson) - 1) + ',' + SubStr(cJsonFilho,1,Len(cJsonFilho) - 1) + CRLF + "}]}"
    
    self:cPublica       := cJson
    self:oPublica:FromJson(self:cPublica)
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GetStruJson
Função que gera o Json com os campos da tabela passada, 
no registro que esta posicionado

@author  Rafael Tenorio da Costa
@since   30/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetStruJson(cTabela, nTypeJson, lControle, cTipReg) Class PshMotorPromocoesOnlineObj

    Local cJson      := "{"
    Local cTipo      := ""
    Local cCampo     := ""
    Local cCampoPublic := '"LQ_FILIAL","LQ_NUM","LQ_VEND","LQ_CLIENTE","LQ_LOJA","LQ_TIPOCLI","LQ_DESCONT","LQ_PDV","LR_ITEM","LR_PRODUTO","LR_QUANT","LR_VRUNIT","LR_CODBAR","LR_VALDESC"'
    Local xConteudo  := ""
    Local nCont      := 1
    Local aStructExp := (cTabela)->( DbStruct() )
    Local cPrefixo   := ""
    
    Default nTypeJson := 0 
    Default lControle := .F.
    Default cTipReg   := ""

    If lControle 
        cJson := '"' + cTabela + Iif(Empty(cTipReg),'": [', '_' + Alltrim(cTipReg) + '": [')
        cJson += CRLF + ' { ' 
    EndIf

    If !Empty(aStructExp)
        cCampo    := AllTrim(aStructExp[1][DBS_NAME] )
        cPrefixo  := SubStr(cCampo, 1, at('_',cCampo)-1)
    EndIf

    LjGrvLog(" PshMotorPromocoesOnlineObj  "," GetStruJson - aStructExp estrutura da tabela -> ",aStructExp)
    For nCont:=1 To Len(aStructExp)
        
        cTipo     := AllTrim( aStructExp[nCont][DBS_TYPE] )
        cCampo    := AllTrim( aStructExp[nCont][DBS_NAME] )
        xConteudo := IIF(cTipo == "N",0,"")
        
        If !(cCampo $ cCampoPublic)
            Loop
        EndIf
        
        
        
        
        
        //Trata o conteudo de cada tag
        Do Case

            Case cTipo == "C"

                //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
                xConteudo := StrTran(xConteudo,'"','')
                xConteudo := StrTran(xConteudo,"'","")
                
                xConteudo := '"' + AllTrim(xConteudo) + '"'
        
                cJson += '"' + AllTrim(cCampo) + '":' + xConteudo + ","

            Case cTipo == "N"
                xConteudo := cValToChar(xConteudo)
                cJson += '"' + AllTrim(cCampo) + '":' + xConteudo + ","
        End Case
    
    Next nCont
    
    cJson := SubStr(cJson, 1, Len(cJson)-1)
    
    
    
    cJson += "}"
    

    aSize(aStructExp, 0)

Return cJson
//-------------------------------------------------------------------
/*/{Protheus.doc} GetHeader
responsavel  por encontrar tag's que serão enviadas do header

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetHeader()  Class PshMotorPromocoesOnlineObj
    Local aHead := {}
    Local aTags   := {} 
    Local nI      := 0
    Local cHeader := ""
    Local lHeader := .T.

    Do case
        Case Self:oConfAssin:hasProperty("Header")
            cHeader := "Header"
        Case Self:oConfAssin:hasProperty("HEADER")
            cHeader := "HEADER"
        Case Self:oConfAssin:hasProperty("header")
            cHeader := "header"        
        OtherWise
            lHeader := .F.
            LjGrvLog("PshMotorPromocoesOnlineObj"," GetHeader - Tag [header] não encontrada na configuração, buscamos por [Header],[HEADER] e [header]")
    End Case

    If lHeader
        aTags := Self:oConfAssin[cHeader]:GetNames()
        For nI := 1 To Len(aTags)
            Aadd(aHead,aTags[nI] + ":" + Self:oConfAssin[cHeader][aTags[nI]]) 
        Next
    EndIf

Return aHead

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetXML
Trata Retorno da Promoção XML e Retorna o Array com as promoções

@author  Everson S P Junior
@version 1.0
@return	 aRet[1][true ou False]
         aRet[2][Valor desconto total]
         aRet[3][aITEM[Posição do Item], 
              aITEM[Codigo do Produto],
              aITEM[Valor desconto Item]  
         ],
         aRet[4][Nome da Promoção]
         aRet[5][Mensagem da Promoção]
         aRet[6][Codigo da Promoção]
/*/ 
//-------------------------------------------------------------------
Method TrataRetXML(cRetorno,aRetPromo) Class PshMotorPromocoesOnlineObj
Local aProduto := {}
Local oRetorno := nil
Local cError   := ""
Local cWarning := ""
Local cAux     := ""
local nx,nY       := 0


cAux := RmiXGetTag(cRetorno, "<beneficioPromocaoes>", .T.)

If !EMPTY(cAux)
    oRetorno := XmlParser(cAux, "_", @cError, @cWarning)
    If VALTYPE(oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO) == "A"
        For nX:= 1 To Len(oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO)
            cAux := IIF(XmlChildEx(oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO[nX], "_PRODUTOS") != Nil,RmiXGetTag(cRetorno, "<produtos>", .T.),"")
            If !EMPTY(cAux) .AND. Valtype(oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO[nX]:_PRODUTOS) == "A"
                oProdutos := oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO[nX]:_PRODUTOS
                For nY:= 1 To Len(oProdutos)
                    Aadd(aProduto,{STRZERO(VAL(oProdutos[nY]:_POSICAOITEM:TEXT),TAMSX3("LR_ITEM")[1],0),oProdutos[nY]:_CODIGO:TEXT,Val(oProdutos[nY]:_DESCONTO:TEXT)} )
                Next    
            elseIf !EMPTY(cAux)
                oProdutos := XmlParser(cAux, "_", @cError, @cWarning)
                Aadd(aProduto,{STRZERO(VAL(oProdutos:_PRODUTOS:_POSICAOITEM:TEXT),TAMSX3("LR_ITEM")[1],0),oProdutos:_PRODUTOS:_CODIGO:TEXT,VAL(oProdutos:_PRODUTOS:_DESCONTO:TEXT)} )
            EndIf
            Aadd( aRetPromo,{.T.,VAL(oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO[nX]:_DESCONTOVALORTOTAL:TEXT),aClone(aProduto),oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO[nX]:_NOMEPROMOCAO:TEXT,;
            oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO[nX]:_MENSAGEMPROMOCIONAL:TEXT,oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO[nX]:_CODIGOPROMOCAO:TEXT} )
        next
    Else
        cAux := RmiXGetTag(cRetorno, "<produtos>", .T.)
        If !EMPTY(cAux) .AND. Valtype(oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO:_PRODUTOS) == "A"
            oProdutos := oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO:_PRODUTOS
            For nX:= 1 To Len(oProdutos)
                Aadd(aProduto,{STRZERO(VAL(oProdutos[nX]:_POSICAOITEM:TEXT),TAMSX3("LR_ITEM")[1],0),oProdutos[nX]:_CODIGO:TEXT,Val(oProdutos[nX]:_DESCONTO:TEXT)} )
            Next    
        elseIf !EMPTY(cAux)
            oProdutos := XmlParser(cAux, "_", @cError, @cWarning)         
            Aadd(aProduto,{STRZERO(VAL(oProdutos:_PRODUTOS:_POSICAOITEM:TEXT),TAMSX3("LR_ITEM")[1],0),oProdutos:_PRODUTOS:_CODIGO:TEXT,VAL(oProdutos:_PRODUTOS:_DESCONTO:TEXT)} )
        EndIf
        Aadd( aRetPromo,{.T.,VAL(oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO:_DESCONTOVALORTOTAL:TEXT),aClone(aProduto),oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO:_NOMEPROMOCAO:TEXT,;
        oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO:_MENSAGEMPROMOCIONAL:TEXT,oRetorno:_BENEFICIOPROMOCAOES:_BENEFICIOPROMOCAO:_CODIGOPROMOCAO:TEXT} )    
    EndIf
EndIf

Return
