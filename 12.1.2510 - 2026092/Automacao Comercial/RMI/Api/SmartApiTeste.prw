#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para acesso a Publicações do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL smartapiteste DESCRIPTION "Auto Teste Integração Smart" FORMAT "application/json,text/html" 

    WSDATA AssinanteProcesso             As Character
    WSDATA Fields               As Character    Optional
    WSDATA Page                 As Integer 	    Optional
    WSDATA PageSize             As Integer		Optional        
    WSDATA Order    	        As Character   	Optional

    WSMETHOD GET ;
        DESCRIPTION "Restorna os Dados Definidos nos arquivos de configurações na arvore de pasta Path"; 
        PATH "/api/v1/smartapiteste/{AssinanteProcesso}";
        WSSYNTAX "/api/v1/smartapiteste/{AssinanteProcesso, Fields, Page, PageSize, Order}";
        PRODUCES APPLICATION_JSON
     WSMETHOD PUT ;
        DESCRIPTION "Simula Confirmação de recebimento";
        PATH "/api/v1/smartapiteste/{AssinanteProcesso}";
        WSSYNTAX "/api/v1/smartapiteste/{AssinanteProcesso}";
        PRODUCES APPLICATION_JSON
    
    WSMETHOD POST ;
        DESCRIPTION "Cria o arquivo com conteudo do Post";
        PATH "/api/v1/smartapiteste/{AssinanteProcesso}";
        WSSYNTAX "/api/v1/smartapiteste/{AssinanteProcesso}";
        PRODUCES APPLICATION_JSON 

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com as publicações a partir do AssinanteProcesso (MHR_CASSIN|MHR_CPROCE)

@param AssinanteProcesso - Código do Assinante|Processo (MHR_CASSIN|MHR_CPROCE)

@author  totvs
@since   05/12/2019
@version 2.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET PATHPARAM AssinanteProcesso QUERYPARAM Fields, Page, PageSize, Order WSREST smartapiteste

    Local lRet              As Logical
    Local osmartapiteste        As Object
    Local cRetResponse      := ""

    
    if self:AssinanteProcesso != Nil
        
        If RetResponse(self:AssinanteProcesso,@cRetResponse)
            lRet := .T.
            self:SetResponse( EncodeUtf8(cRetResponse) )//osmartapiteste:GetReturn() 
        Else
            lRet := .F.
            SetRestFault(500, EncodeUtf8( '{"success":false,"message":"' + cRetResponse + '" }') )
        EndIf
    EndIf
    FwFreeObj(osmartapiteste)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}
Atualiza as publicações a partir do Assinante (MHR_CASSIN) e uma lista Publicações

@param Assinante - Identificador Assinante|Processos

@author  totvs
@since   11/12/2019
@version 2.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT PATHPARAM AssinanteProcesso WSREST smartapiteste

    Local lRet              As Logical
    Local aErro             := StrTokArr(self:AssinanteProcesso,"|")

    If self:AssinanteProcesso != Nil .AND. Len(aErro)<= 2
        lRet := .T.
        self:SetResponse( EncodeUtf8( '{"success":true,"message":""}' ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( '{"success":false,"message":""}') )
    EndIf


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}
Atualiza as publicações a partir do Assinante (MHR_CASSIN) e uma lista Publicações

@param Assinante - Identificador Assinante|Processos

@author  totvs
@since   11/12/2019
@version 2.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST PATHPARAM AssinanteProcesso WSREST smartapiteste

    Local lRet              As Logical
    Local aAux              := Separa( Upper(self:AssinanteProcesso), "|")
    Local cBody 	        := Alltrim(Self:GetContent())


    If self:AssinanteProcesso != Nil 
        lRet := .T.
        If !ExistDir("\" + "smartapiteste\"+Alltrim(aAux[1]))
	        
            MakeDir( "\smartapiteste" )
	        MakeDir("\" + "smartapiteste\"+Alltrim(aAux[1]))
        endIf
        nHandle := FCREATE("\" + "smartapiteste\"+Alltrim(aAux[1]) + "\" + aAux[2] + ".txt")
        If nHandle  >= 0
            FWrite(nHandle,AjustaJson(@cBody))
            FClose(nHandle)
	    Endif
    EndIf
    If lRet
        self:SetResponse( EncodeUtf8( '{"success":true,"message":""}' ) )
    EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para acesso a Publicações do Varejo
/*/
//-------------------------------------------------------------------
Static Function RetResponse(cParam,cRetResponse)

    Local oFile         := nil
    Local cAssinante    := ""
    Local cProcesso     := ""
    Local PATH          := "\smartapiteste\"
    Local cLine         := ""
    Local nLines        := 0
    Local aAux          := ""
    Local cArquivo      := ""
    Local lSucesso      := .T.

    aAux := Separa( Upper(cParam), "|")
    
    If !Empty(aAux[1]).AND. !Empty(aAux[2])

        cAssinante := Alltrim(aAux[1])
        cProcesso  := Alltrim(aAux[2])
        
        oFile := ZFWReadTXT():New(PATH+cAssinante+"\"+cProcesso+".txt")
        if (oFile:Open())
            cArquivo:=""
            while oFile:ReadLine(@cLine)
                cArquivo += cLine
                nLines++
            end
            oFile:Close()
            cRetResponse := cArquivo
        Else
            cRetResponse := oFile:GetErrorStr()
            lSucesso := .F.
        endif 
    EndIf

Return lSucesso
//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para acesso a Publicações do Varejo
/*/
//-------------------------------------------------------------------
Static function AjustaJson(cBody)
Local cjson := ""

cJson+='{'
cJson+='"success": true,'
cJson+='"message": "",'
cJson+='"data": ['
			cJson+='{'
			cJson+='"tipo": 0,'
            cJson+='"status": 0,'
            cJson+='"conteudo": "'+Encode64(cBody)+'",'
            cJson+='"cupom": "138",'
            cJson+='"ccf": "138",'
            cJson+='"dataEmissao": "2022-07-08T15:22:23.957989Z",'
            cJson+='"pdv": "7",'
            cJson+='"valorBruto": "100.0",'
            cJson+='"numeroLoja": "9017517",'
            cJson+='"chaveAcesso": "13220782373077000171659660000001381376391328",'
            cJson+='"serieNota": "966",'
            cJson+='"observacao": null,'
            cJson+='"id": "x4ZBjGTmFw0ibci3sD5e",'
            cJson+='"idInquilino": "ELgxWKTnHcFShMP6B6AH",'
            cJson+='"idRetaguarda": "000037",'
            cJson+='"dataAtualizacao": "2022-07-08T18:24:21.17023Z",'
            cJson+='"dataCadastro": "2022-07-08T18:24:21.170238Z",'
            cJson+='"idProprietario": "000041",'
            cJson+='"loteOrigem": null,'
            cJson+='"lote": "Venda20227815241549",'
            cJson+='"_expandables": []'
            cJson+='}'
            cJson+=']}'

Return cJson
