#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusSigaGpcObj
Classe responsável pela busca de dados no PdvSync
    
/*/
//-------------------------------------------------------------------
Class RmiBusSigaGpcObj From RmiBuscaObj

    Method New()                    //Metodo construtor da Classe

    Method Processa()               //Metodo que ira controlar o processamento das buscas
    
    Method Busca(cCompId,cMetodo)   //Metodo responsavel por buscar as informações no Assinante
    
    Method Grava()                  //Metodo que efetua a gravação da publicação
    
    Method getHeader(aCompany)              //Metodo que retorna o header para a chamada do get
    
    Method MessageCount(cCompanyId) //Metodo que retorna a quantidade de mensagens na fila

    Method ProcessMessages(cCompanyId,nQtd)    //Metodo que processa as mensagens na fila

    Method ProcessError(cId,cErro)        //Metodo que processa os erros na fila

    Data aCompanies as Array        //Array de empresas que serão processadas

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiBusSigaGpcObj

    Default cAssinante := "SIGAGPC"
    
    _Super:New(cAssinante)

    self:aCompanies := PshListCad("COMPARTILHAMENTOS",{"nivel","CodigoLoja","CompanyID","SenhaInt"})
    self:lLoteIdRet := .F.

    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
Metodo que ira controlar o processamento das buscas

@author  Evandro Pattaro
@version 1.0
/*/
//-------------------------------------------------------------------
Method Processa() Class RmiBusSigaGpcObj

Local nComp := 0
Local cCodfil := ""
Local nMsg := 0

/*
aCompanies[1] = "nivel"
aCompanies[2] = "CodigoLoja"
aCompanies[3] = "CompanyID"
aCompanies[4] = "SenhaInt" */

For nComp:=1 To Len(self:aCompanies)
    If !Empty(self:aCompanies[nComp][3])
        nMsg := 0
        cCodFil := LjAuxPosic("CADASTRO DE LOJA    ","MIH_ID",self:aCompanies[nComp][2],"IDFilialProtheus")
        self:getHeader(self:aCompanies[nComp])
        
        LjGrvLog("RmiBusSigaGpcObj", "Company: "+self:aCompanies[nComp][3]+" - Buscando registros pendentes na fila...")
        
        nMsg := self:MessageCount(self:aCompanies[nComp][3])

        If nMsg > 0

            LjGrvLog("RmiBusSigaGpcObj", "Company: "+self:aCompanies[nComp][3]+" - "+cValToChar(nMsg)+" registros pendentes")

            self:ProcessMessages(self:aCompanies[nComp][3],nMsg)
        
        Else
            LjGrvLog("RmiBusSigaGpcObj", "Company: "+self:aCompanies[nComp][3]+" - sem registros na fila")
        EndIf

    EndIf
Next nComp

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por realizar um get conforme
@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca(cCompId,cMetodo) Class RmiBusSigaGpcObj

    Local cPath           := ""

    Default cMetodo := ""
    
    //Inteligencia poderá ser feita na classe filha - default em Rest com Json
    If self:lSucesso

        If self:oBusca == Nil
            self:oBusca := FWRest():New("")
        EndIf

        if self:oConfAssin:hasProperty("url")
			If	Substr(Self:oConfAssin["url"],1,1) == "&"
				cPath := &(AllTrim(SubStr(Self:oConfAssin["url"],2)))
			Else
				cPath := Self:oConfAssin["url"]
			EndIf
        EndIf    

        cPath += "/queue/"+ cCompId + "_out" + cMetodo

        self:oBusca:SetPath(cPath)

        If self:oBusca:Get( self:aHeader )

            self:cRetorno := self:oBusca:GetResult()

        Else

            self:lSucesso := .F.
            self:cRetorno := self:oBusca:GetLastError() + " - [" + cPath + "]" + CRLF
        EndIf
            
    EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Grava a publicação recebida


@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiBusSigaGpcObj

    _Super:Grava()

    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getHeader
Metodo para carregar o header

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method getHeader(aCompany) Class RmiBusSigaGpcObj

	FwFreeArray(self:aHeader)
	self:aHeader := {}

    Aadd(self:aHeader, "accept: */*")
    Aadd(self:aHeader, "Content-Type: application/json")
    Aadd(self:aHeader, "user: "+ aCompany[3]+"_user")
	Aadd(self:aHeader, "password: "+ aCompany[4])


Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MessageCount
Metodo que retorna a quantidade de mensagens na fila

@author  Evandro Pattaro
@version 1.0
/*/
//-------------------------------------------------------------------
Method MessageCount(cCompanyId) class RmiBusSigaGpcObj

	Local nRet := 0
	Local ojResponse

	
    self:Busca(cCompanyId,"/count")
    If self:lSucesso
        ojResponse := JsonObject():New()
        ojResponse:FromJson(self:cRetorno)
        nRet := ojResponse["count"]
    Else    
        LjGrvLog("RmiBusSigaGpcObj", "Erro no consumo da mensagem no servidor RabbitMQ: "+self:cRetorno)
    EndIf

    FwFreeObj(self:oRetorno)


Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessMessages
Metodo que processa as mensagens na fila

@author  Evandro Pattaro
@version 1.0
/*/
//-------------------------------------------------------------------
Method ProcessMessages(cCompanyId,nQtd) class RmiBusSigaGpcObj

    Local nX := 0
    Local oJResponse
    Local xRet

    For nX := 1 to nQtd
    
        self:lSucesso := .T.
        self:cRetorno := ""
        self:Busca(cCompanyId)

        If self:lSucesso
   
            oJResponse := JsonObject():New()
            xRet := oJResponse:FromJson( self:cRetorno )

            If ValType(xRet) == "U"
                If oJResponse:HasProperty("id") .AND. oJResponse:HasProperty("entity") .AND. oJResponse:HasProperty("data") .AND. (oJResponse["entity"] == "error" .OR. oJResponse:HasProperty("companies"))
                    If oJResponse["entity"] == "error"
                        self:ProcessError(oJResponse["id"], oJResponse["data"])
                    ElseIf oJResponse["entity"] == "cash-control"
                        //oReceiveDataLoad := CashControlDataLoad():New()
                    ElseIf oJResponse["entity"] == "sale"
                        //oReceiveDataLoad := SaleDataLoad():New()
                    ElseIf oJResponse["entity"] == "series"
                        //oReceiveDataLoad := SeriesDataLoad():New()
                    ElseIf oJResponse["entity"] == "fuel-supply"
                        //oReceiveDataLoad := FuelSupplyDataLoad():New()
                    ElseIf oJResponse["entity"] == "customer"
                        //oReceiveDataLoad := CustomerDataLoad():New()
                    EndIf
                Else
                    LjGrvLog("RmiBusSigaGpcObj", "ProcessMessages => Mensagem não contem atributos [id] ou [entity] ou [data] ou [companies]")
                EndIf
            Else
                LjGrvLog("RmiBusSigaGpcObj", "ProcessMessages => Falha ao popular JsonObject. Erro: " + xRet)
            EndIf

            FwFreeObj(oJResponse)
        EndIf
        
    Next nX    

Return Nil


Method ProcessError(cId,cErro) class RmiBusSigaGpcObj

    Local aAreaMHR := MHR->(getArea())

    DbSelectArea("MHR")
    DbSetOrder(3) //MHR_FILIAL, MHR_UIDMHQ, MHR_CASSIN, MHR_CPROCE, R_E_C_N_O_, D_E_L_E_T_

    If MHR->(DbSeek( xFilial("MHR") + cId ))
        self:cRetorno := cErro
        self:cBody := MHR->MHR_ENVIO
        self:atualizaMHR("3")
    Else
        LjGrvLog("RmiBusSigaGpcObj", "ProcessError => Registro não encontrado na MHR para o ID: " + cId)
        self:lSucesso := .F.
    EndIf
 
    self:cRetorno := ""
    self:cBody := ""

    RestArea(aAreaMHR)

Return Nil
