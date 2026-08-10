#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIBUSCHEFOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusChefObj
Classe responsável pela busca de dados no Chef
    
/*/
//-------------------------------------------------------------------
Class RmiBusChefObj From RmiBuscaObj

    Data cLayoutFil     As Character    //Layout referente as filias que serao processadas pela API data de integração

    Data oLayoutFil     As Objetc       //Objeto jSonObject com layout das filias utilizadas pela API data de integração

    Data cDtIntegracao  As Character    //Data da Integração da Venda usada na API data de Integração

    Data cTime          As Character    //Hora para validação 

    Method New()	                    //Metodo construtor da Classe

    Method Busca()                      //Metodo responsavel por buscar as informações no Assinante

    Method SetaProcesso(cProcesso)      //Metodo responsavel por carregar as informações referente ao processo que será recebido

    Method TrataRetorno()               //Metodo que centraliza os retorno permitidos    

    Method Venda()	                    //Metodo para carregar a publicação de venda

    Method Inutiliza()                  //Metodo para carregar a publicação de inutilização

    Method GravaFilial()	            //Metodo para gravar a data e hora da venda da API - CapaVenda/DatadeIntegracao

    Method CheckTime(cTime)

    Method AjustaJsonRepro()            //Metodo para verificar se esta utilizando o metodo ListPorDataMovimento

    Method LayEstAutoChef(cCmpRet, cModelo, cSerie, cEstacao, cCodLoja)    //Metodo que Retorna informações da SLG a partir do campo recebido no parâmetro cCmpRet ou cadastra a SLG

    Method VldVendErro() // Descarta ou prepara para reprocessamento
    Method LogMhlBlq(lLog) //Deleta o Log de bloqueio do CHEF
    Method GrvMHQBlq() //Amarra uma MHQ de Erro para o bloqueio

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiBusChefObj
    
    _Super:New("CHEF")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por enviar a mensagens ao Chef

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBusChefObj

    //Atualiza o token no body - para o Chef o token vale apenas para uma utilização
    self:oBody["token"] := self:cToken
    self:cBody          := self:oBody:ToJson()

    self:cLayoutFil     := ""

    self:oLayoutFil     := Nil

    self:cDtIntegracao  := ""

    //Aguarda 15 segundos para executar o próximo post, regra incluída pela equipe do FOOD
    ljGrvLog("RmiBusChefObj", "Aguardando 15 segundos para efetuar a próxima busca.", {self:cProcesso, self:cBody})
    sleep(15000)

    _Super:Busca()

    self:oConfProce["ultimaExecucao"] := time()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informações referente ao processo que será buscado

@param  cProcesso, charactere, define o processo que será utilizado na busca 
@param  lVldUltExe, logico, define se ira ou não efetuar a validação de tempo de ultima execução

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso, lVldUltExe) Class RmiBusChefObj

    Local cTmpMinimo    := ""

    Default lVldUltExe  := .T.

    If AllTrim(cProcesso) == "VENDA"
        self:cStatus := "0"  //0=Fila;1=A Processar;2=Processada;3=Erro
    EndIf

    //Chama metodo da classe pai para buscar informações comuns
    _Super:SetaProcesso(cProcesso)

    If self:lSucesso
        
        //Valida o tempo minino para executar a busca, quando não for reprocessamento
        If lVldUltExe .and. !RmiGetRepc() .and. self:oConfProce:hasProperty("ultimaExecucao") .and. self:oConfProce:hasProperty("tempBuscaVenda") .and. ( cTmpMinimo := elapTime(self:oConfProce["ultimaExecucao"], time()) ) <= self:oConfProce["tempBuscaVenda"];
        .and. self:oConfProce:hasProperty("regraChef") .and. self:oConfProce["regraChef"]
            self:lSucesso := .F.
            self:cRetorno := STR0007 + cTmpMinimo       //"Busca não será executada, intervalo de tempo minimo(00:30:00) não foi atingido. Intervalo atual: "
            LjGrvLog(" RMIBUSCACHEFOBJ ",self:cRetorno)
        EndIf
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Metodo que centraliza os retorno permitidos

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno() Class RmiBusChefObj

    Local cProcesso := AllTrim(self:cProcesso)

    Do Case 

        Case cProcesso == "VENDA"
            self:Venda()
            self:Inutiliza()

        OTherWise

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, {cProcesso})    //"Processo #1 sem tratamento para busca implementado"
            LjGrvLog("RMIBUSCHEFOBJ",self:cRetorno)

    End Case

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Venda
Metodo para carregar a publicação de venda

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Venda() Class RmiBusChefObj

    Local nVenda     := 0
    Local nStatus    := 0                            //1=Aberto, 2=Finalizado, 3=Cancelado
    Local nItem      := 0 
    Local cHoraAux   := ""                           //Variavel auxiliar para uso de tempo
    Local cTimeAux   := ""                           //Variavel auxiliar para uso de tempo
    Local cMsgErro   := AllTrim(self:cProcesso) + " - " + STR0004

    //Verifica se as vendas foram retornadas
    If !self:oRetorno["Sucesso"]

        self:lSucesso := .F.
        self:cRetorno := IIF(Valtype(self:oRetorno["Sucesso"]) =="U",cMsgErro,;
        cMsgErro + " - " + IIF(Len(self:oRetorno["Erros"])>0,self:oRetorno["Erros"][1]["DescricaoErro"],STR0005)) + CRLF;//"Mensagem Recebida inválida verifique na Origem o Json Enviado"  " API  não retornou o motivo do erro, verifique junto a equipe Totvs Food."
        +STR0006+self:oConfProce["url"]//" Envie no Chamado para Equipe do TOTVS FOOD a URL: "
        
        Self:LogMhlBlq(.T.)// Grava Log para aparecer no monitor.
        LjGrvLog("RMIBUSCHEFOBJ", "( Cliente Bloqueado na API do CHEF ) "+ self:cRetorno)

    //Processa as vendas
    Else
        Self:LogMhlBlq()// Limpa o log que esta aparecendo no monitor.
        //Verifica se existem vendas
        If Len(self:oRetorno["Vendas"]) == 0

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0003, { ProcName(), self:cRetorno} )   //"[#1] Não há vendas a serem baixadas: #2"
            LjGrvLog("RMIBUSCHEFOBJ", self:cRetorno)

            If !(self:oLayoutFil == Nil)
                self:GravaFilial()
            Else
                LjGrvLog("RMIBUSCHEFOBJ", "oLayoutFil retornou NIL")
            EndIf
        Else

            For nVenda:=1 To Len(self:oRetorno["Vendas"])

                //Status da venda no Chef 1=Em Aberto, 2=Finalizada, 3=Cancelada
                nStatus := self:oRetorno["Vendas"][nVenda]["StatusVenda"]

                //Só carrega vendas Finalizadas ou Canceladas
                If nStatus > 1

                    //Carrega informações da publicação que será gerada
                    self:oRegistro      := self:oRetorno["Vendas"][nVenda]  //Objeto que poderá ser utilizado para gerar o layout da publicação. (MHP_LAYPUB)

                    self:cMsgOrigem := FWJsonSerialize(self:oRegistro) 

                    self:cChaveUnica    := self:oRegistro["ChaveVenda"]     //Chave única do registro publicado. (MHQ_CHVUNI)
                    self:cEvento        := IIF(nStatus == 2, "1", "2")      //Evento da publicação 1=Upsert, 2=Delete (MHQ_EVENTO)

                    self:cDtIntegracao  := self:oRegistro["DataIntegracaoChefweb"]

                    //Verifica se a venda já foi publicada
                    If self:AuxExistePub()
                        Loop
                    EndIf
                    
                    If !(self:oLayoutFil == Nil) .and. Valtype(self:oLayoutFil["Filiais"]) == "A"
                        For nItem:=1 To Len( self:oLayoutFil["Filiais"] )
                            If Alltrim(self:oLayoutFil["Filiais"][nItem]["Filial"])  == Alltrim(self:oPublica["L1_FILIAL"])
                                cTimeAux := self:CheckTime(substr(self:cDtIntegracao,rat("T",self:cDtIntegracao) +1 , 8))
                                self:cDtIntegracao :=  DtoC(Stod(StrTran( self:cDtIntegracao, "-", "" )))
                                If self:cDtIntegracao > self:oLayoutFil["Filiais"][nItem]["Data"]
                                    self:oLayoutFil["Filiais"][nItem]["Data"] := self:cDtIntegracao
                                    self:oLayoutFil["Filiais"][nItem]["Hora"] := cTimeAux
                                Else
                                    cHoraAux := ElapTime(self:oLayoutFil["Filiais"][nItem]["Hora"],cTimeAux)
                                    cTimeAux := Iif(self:oLayoutFil["Filiais"][nItem]["Hora"] < cHoraAux, self:oLayoutFil["Filiais"][nItem]["Hora"], cTimeAux)
                                    self:oLayoutFil["Filiais"][nItem]["Hora"] := cTimeAux
                                EndIf
                            EndIf
                        Next nItem
                    EndIf

                    //Grava a publicação
                    self:Grava()

                    If self:lSucesso .and. !(self:oLayoutFil == Nil)                        
                        self:GravaFilial()
                    EndIf

                    //Limpa objeto da publicação
                    FwFreeObj(self:oRegistro)
                    FwFreeObj(self:oPublica)
                    self:oRegistro  := Nil
                    self:oPublica   := Nil
                    
                EndIf

            Next nVenda
        EndIf        
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Inutiliza
Metodo para carregar a publicação de inutilização MHQ_EVENTO = 3

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Inutiliza() Class RmiBusChefObj

    Local nInutil    := 0

    If Valtype(self:oRetorno["NotasInutilizadas"]) !="U" .AND. Len(self:oRetorno["NotasInutilizadas"]) > 0
        For nInutil:=1 To Len(self:oRetorno["NotasInutilizadas"])

            //Carrega informações da publicação que será gerada           
            self:cEvento        := "3"

            self:oRegistro      := self:oRetorno["NotasInutilizadas"][nInutil]

            self:cMsgOrigem     := FWJsonSerialize(self:oRegistro) 

            self:cChaveUnica    := self:oRegistro["ChaveVenda"]

            //Verifica se a inutilizacao já foi publicada
            If self:AuxExistePub()
                Loop
            EndIf

            //Grava a publicação
            self:Grava()
            
            LjGrvLog("RMIBUSCHEFOBJ", "Existe nota inutilizada" + self:oRetorno:ToJson() )

            //Limpa objeto da publicação
            FwFreeObj(self:oRegistro)                
            self:oRegistro  := Nil
            
        Next nInutil
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaFilial
Metodo responsavel por gravar a data e hora da venda para 
a API - CapaVenda/DatadeIntegracao

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method GravaFilial() Class RmiBusChefObj

Local nItem     := 0

    self:cDtIntegracao := DtoC(Stod(StrTran( self:cDtIntegracao, "-", "" )))

    If !self:lSucesso
        LjGrvLog("RMIBUSCHEFOBJ","lSucesso retornou falso")

        If !(self:oLayoutFil == Nil) .and. Valtype(self:oLayoutFil["Filiais"]) == "A"
            For nItem:=1 To Len( self:oLayoutFil["Filiais"] )
                If Alltrim(self:oLayoutFil["Filiais"][nItem]["Filial"])  ==  Alltrim(self:aArrayFil[self:nFil][2])
                    If self:cDtIntegracao <= self:oLayoutFil["Filiais"][nItem]["Data"]
                        self:oLayoutFil["Filiais"][nItem]["Data"] := DtoC(Stod(StrTran( self:oBody["DataFinalIntegracaoChefweb"], "-", "" )))
                    EndIf
                EndIf
            Next nItem
        Else
            LjGrvLog("RMIBUSCHEFOBJ","oLayoutFil deve vir diferente de NIL")
            LjGrvLog("RMIBUSCHEFOBJ",'self:oLayoutFil["Filiais"] não é um array')
        EndIf
    EndIF

    //Atualiza o token no body - para o Chef o token vale apenas para uma utilização
    If !(self:oLayoutFil == Nil)
        self:cLayoutFil := self:oLayoutFil:ToJson()
    Else
        LjGrvLog("RMIBUSCHEFOBJ","cLayoutFil igual a NIL - Token não atualizado")
    EndIf

    If !Empty(self:cLayoutFil)
        MHP->( DbSetOrder(1) )  //MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO
        If MHP->( DbSeek(xFilial("MHP") + PadR(self:cOrigem, TamSx3("MHP_CASSIN")[1]) + PadR(self:cProcesso, TamSx3("MHP_CPROCE")[1])) )
            RecLock("MHP", .F.)
                MHP->MHP_LAYFIL := self:cLayoutFil
            MHP->( MsUnLock() )
            LjGrvLog("RMIBUSCHEFOBJ","Campo MHP_LAYFIL ajustado",self:cLayoutFil)
        EndIf
    Else
        LjGrvLog("RMIBUSCHEFOBJ","cLayoutFil em branco")
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckTime
Metodo responsavel por validar data e hora 

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method CheckTime(cTime) Class RmiBusChefObj
   
	Local cH := SubStr(cTime,1,2)
	Local cM := SubStr(cTime,4,2)
    Local cS := SubStr(cTime,7,2)
    Local nSec := Val(cS) + 1
    Local nMin := Val(cM)
    Local nHor := Val(cH)

    Default cTime := ""
	
    If (nSec > 59)
        cS := "00"
        cM := StrZero( nMin + 1, 2)
    Else    
        cS := StrZero( nSec, 2)
    EndIf

    If (nMin > 59)
		cM := "00"
        cH := StrZero( nHor + 1, 2)
	EndIf

    If (nHor > 23)
		cH := "00"
	EndIf 

    If Len(AllTrim(cTime)) == 8
		cTime := cH + ":" + cM + ":" + cS
	EndIf
   
Return cTime

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaJsonRepro
Metodo para verificar se esta utilizando o metodo ListPorDataMovimento
e tambem para alterar a data de inicio e fim do movimento.

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method AjustaJsonRepro() Class RmiBusChefObj

Local cJson := '{"CodigoLoja":"&self:aArrayFil[self:nFil][1]","DataMovimentoInicial":"&Str( Year(dDatabase), 4) +'-'+  StrZero( Month(dDatabase), 2) +'-'+ StrZero( Day(dDatabase), 2)","DataMovimentoFinal":"&Str( Year(dDatabase), 4) +'-'+  StrZero( Month(dDatabase), 2) +'-'+ StrZero( Day(dDatabase), 2)"}'
Local cUrl  := ""

If !("LISTPORDATAMOVIMENTO" $ Upper(self:oConfProce["url"]))
    Self:oLayoutEnv:FromJson(cJson)
    cUrl := StrTran(self:oConfProce["url"],"ListPorDataIntegracaoChefWeb","ListPorDataMovimento")
    self:oConfProce["url"] := cUrl
EndIf

Self:oLayoutEnv["DataMovimentoInicial"] := FWTimeStamp(3,RmiGetDate(),"00:00:00")
Self:oLayoutEnv["DataMovimentoFinal"]   := FWTimeStamp(3,RmiGetDate(),"23:59:59")

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LayEstAutoChef
Metodo que Retorna informações da SLG a partir do campo recebido no parâmetro cCmpRet ou cadastra a SLG
Cadastra a estação AUTOMATICO caso seja necessário.
Utilizado no layout

@param cCmpRet      - Nome do campo que irá retornar LG_SERIE, LG_PDV

@return cRetorno    - Caracter com a serie ou pdv 
				
@author  Danilo Rodrigues
@since 	 29/04/2021
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Method LayEstAutoChef(cCmpRet, cModelo, cSerie, cEstacao, cCodLoja) Class RmiBusChefObj

    Local aArea     := GetArea()
    Local cRetorno  := ""
	Local aEstacao	:= {}
	Local aErro		:= {}
	Local cErro		:= ""
	Local nCont		:= 0
	Local cQuery    := ""
    Local cTab      := ""
    Local nOpc      := 3
    Local cFilRmi   := ""
    Local cPdv      := ""
    Local lContinua := .T.

    Default cModelo   := cValtoChar(self:oRegistro['ModeloFiscal'])
    Default cCodLoja  := cValtoChar(self:oRegistro['Loja']['Codigo'])
    Default cEstacao  := ""
    Default cSerie    := ""


    LjGrvLog("LayEstAutoChef","Dados recebidos para query. Modelo: " + cModelo + ", CodLoja: " + cCodLoja + ".")

	Private lMsErroAuto	   := .F.	//Cria a variavel do retorno da rotina automatica

    cFilRmi   := PadR( self:DePara("SM0", cCodLoja, 1, 0), TamSX3("LG_FILIAL")[1] )
    cFilSLG   := xFilial("SLG",PadR(cFilRmi, TamSx3("LG_FILIAL")[1]))

    If !Empty(cFilRmi)

        LjGrvLog("LayEstAutoChef","Filial do De/Para de Loja: " + cFilRmi)

        cQuery := " SELECT LG_CODIGO, LG_NOME, LG_SERIE, LG_PDV, LG_SERPDV, LG_NFCE "
        cQuery += " FROM " + RetSqlName("SLG")
        cQuery += " WHERE LG_FILIAL = '" + cFilSLG + "'"

        Do Case
            Case cModelo == "1" .And. !Empty(self:oRegistro['SerieSAT'])
                cEstacao :=  self:oRegistro['SerieSAT']              
                cQuery +=   " AND LG_SERSAT = '" + cEstacao + "'"

            Case cModelo == "2" .And. !Empty(self:oRegistro['SerieNota'])
                cEstacao :=  self:oRegistro['SerieNota']              
                cQuery +=   " AND LG_SERIE = '" + cEstacao + "'"
                
            Case cModelo == "4" .And. Empty(self:oRegistro['SerieECF'])
                cEstacao :=  self:oRegistro['SerieECF']              
                cQuery +=   " AND LG_SERPDV = '" + cEstacao + "'"

            OTherWise
                lContinua     := .F.
                self:lSucesso := .F.
                self:cTipoRet := "ESTACAO"
                self:cRetorno += I18n("Dados recebidos não conferem com as regras estabelecidas: Modelo=[#1] Serie=[#2]", {cModelo, cSerie}) + CRLF

        End Case

        cQuery +=   " AND D_E_L_E_T_ = ' ' "

        LjGrvLog("LayEstAutoChef","Query executada: " + cQuery)

        If lContinua

            cTab := GetNextAlias()
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTab, .T., .F.)

            //Não encontrou nenhuma estação
            If (cTab)->( Eof() )                        

                If cModelo == "1"
                    cSerie := "999"
                Else
                    cSerie := "001"
                EndIf

                SLG->( DbSetOrder(1) )
                While SLG->(DbSeek(cFilSLG + cSerie))
                    cSerie := Soma1(cSerie,TamSX3("LG_CODIGO")[1])
                End

                If cModelo == '1' .or. cModelo == '4'
                    cPdv := Substr( GetSxeNum("SLG", "LG_PDV", "LG_PDV" + cFilRmi), 8, 3)

                    Aadd( aEstacao, {"LG_FILIAL", cFilSLG            , Nil} )
                    Aadd( aEstacao, {"LG_CODIGO", cSerie            , Nil} )
                    Aadd( aEstacao, {"LG_NOME"	, "ESTACAO" + cSerie, Nil} )
                    Aadd( aEstacao, {"LG_SERIE"	, cEstacao	        , Nil} )
                    Aadd( aEstacao, {"LG_PDV"	, cPdv              , Nil} )
                    Aadd( aEstacao, {"LG_NFCE"  , .F.               , Nil} )

                    If cModelo == '1'
                        Aadd( aEstacao, {"LG_SERSAT", cEstacao      , Nil} )
                        Aadd( aEstacao, {"LG_USESAT", .T.           , Nil} )
                    Else
                        Aadd( aEstacao, {"LG_SERPDV", cEstacao      , Nil} )
                        Aadd( aEstacao, {"LG_USESAT", .F.           , Nil} )
                    EndIf
                    
                Else            

                    cPdv := Substr( GetSxeNum("SLG","LG_PDV","LG_PDV" + cFilRmi), 8, 3)

                    Aadd( aEstacao, {"LG_FILIAL", cFilSLG           , Nil} )
                    Aadd( aEstacao, {"LG_CODIGO", cSerie            , Nil} )
                    Aadd( aEstacao, {"LG_NOME"	, "ESTACAO" + cSerie, Nil} )
                    Aadd( aEstacao, {"LG_SERIE"	, cEstacao	        , Nil} )
                    Aadd( aEstacao, {"LG_PDV"	, cPdv              , Nil} )
                    Aadd( aEstacao, {"LG_NFCE"	, .T.               , Nil} )
                EndIF
                
                
                //Cadastra a estação AUTOMATICA
                MSExecAuto({|a,b,c,d| LOJA121(a,b,c,d)}, /*cFolder*/, /*lCallCenter*/, aEstacao, nOpc)
                
                If lMsErroAuto

                    aErro := GetAutoGRLog()

                    For nCont := 1 To Len(aErro)
                        cErro += aErro[nCont] + CRLF
                    Next nCont

                    self:lSucesso := .F.
                    self:cTipoRet := "ESTACAO"
                    self:cRetorno += cErro
                Else

                    cRetorno := &("SLG->" + cCmpRet)                    
                EndIf
            Else

                If cModelo == "2" .And. (cTab)->LG_NFCE == "F"

                    self:lSucesso := .F.
                    self:cTipoRet := "ESTACAO"
                    self:cRetorno += I18n("A estação #1 do Protheus não se refere ao tipo NFCE.", {(cTab)->LG_CODIGO} ) + CRLF
                Else

                    cRetorno := &(cTab + "->" + cCmpRet)
                EndIf
            EndIf

        EndIf
    Else

        self:lSucesso := .F.
        self:cTipoRet := "ESTACAO"
        self:cRetorno += I18n("Não foi realizado o De/Para da Filial: CodigoLoja=[#1]", cCodLoja ) + CRLF
    EndIf

	Asize(aEstacao, 0)
	ASize(aErro   , 0)

    RestArea(aArea)

    LjGrvLog("LayEstAutoChef","Retorno do conteudo do campo: ", cRetorno)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldVendErro 
Esse metodo valida erro para efetuar deletar e receber os
novos registros.
@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method VldVendErro() Class RmiBusChefObj
Local lRet          := .F.

If MHQ->MHQ_STATUS == '4'
    LjGrvLog("VldVendErro", "RmiBusChefObj - Encontrado Reprocessamento na tabela MHQ")
    lRet := .T.    
    Self:DelVenda(MHQ->MHQ_UUID)// Só deletar a venda e MHQ ja estiver com 4 para reprocessar.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} LogMhlBlq 
Metodo responsavel em realizar a exclusão dos registros de log da venda

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method LogMhlBlq(lLog) Class RmiBusChefObj


If lLog
    Begin Transaction
        RMIGRVLOG(  "IR"            , "MHQ"         ,99999999, "BUSCA",;
                            "(Abra o chamado para Equipe do TOTVS FOOD - Servidor Bloqueado na API do TOTVS FOOD ) "+STR0006+self:oConfProce["url"] , , , ,;
                            .F.             , 1             , dTos(dDataBase) , "VENDA"   ,;
                            "CHEF" , "Bloqueio-d29a-4491-994d-026a8303a23b" )
        Self:GrvMHQBlq()
        LjGrvLog("RmiBuscaObj", "[DelLog]  Servidor Bloqueado pela equipe do TOTVS FOOD não está mais bloqueado!")
    End Transaction
Else
    Begin Transaction
        dbSelectArea("MHL")
        dbSetOrder(3)
        If MHL->(DbSeek(xFilial("MHL") + Padr("Bloqueio-d29a-4491-994d-026a8303a23b",Tamsx3("MHL_UIDORI")[1])) )
            RecLock("MHL",.F.)
            MHL->( DbDelete() )
            MHL->( MsUnLock() )    
            LjGrvLog("RmiBuscaObj", "[DelLog]  Servidor liberado pela equipe do TOTVS FOOD não está mais bloqueado!")   
        EndIf
    End Transaction    
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Grava a publicação para vincular no monitor.

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method GrvMHQBlq() Class RmiBusChefObj

dbSelectArea("MHQ")
MHQ->( DbSetOrder(7) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE + MHQ_CHVUNI + MHQ_EVENTO + DTOS(MHQ_DATGER) + MHQ_HORGER
    
RecLock("MHQ",!MHQ->(DbSeek(xFilial("MHQ")+PADR("Bloqueio-d29a-4491-994d-026a8303a23b",TAMSX3("MHQ_UUID")[1]))))
    MHQ->MHQ_FILIAL := xFilial("MHQ")
    MHQ->MHQ_ORIGEM := "CHEF"
    MHQ->MHQ_CPROCE := "VENDA"
    MHQ->MHQ_EVENTO := "1"              //1=Atualização;2=Exclusão;3=Inutilização
    MHQ->MHQ_CHVUNI := dTos(dDataBase)
    MHQ->MHQ_MENSAG := '{"Erros": "Servidor Bloqueado pela equipe do TOTVS FOOD"}'
    MHQ->MHQ_DATGER := Date()
    MHQ->MHQ_HORGER := Time()
    MHQ->MHQ_STATUS := "3"    //0=Fila;1=A Processar;2=Processada;3=Erro
    MHQ->MHQ_UUID   := "Bloqueio-d29a-4491-994d-026a8303a23b"    //Gera chave unica
    MHQ->MHQ_MSGORI := '{"Erros": "Servidor Bloqueado pela equipe do TOTVS FOOD"}'
MHQ->( MsUnLock() )

    

Return Nil
