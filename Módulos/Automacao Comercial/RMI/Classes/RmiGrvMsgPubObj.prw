#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIGRVMSGPUBOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgPubObj
Classe generica para o processamento da fila e gravação do campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubObj

    Data cAliasQuery    As Character    //Nome do alias temporario com o resultado da query
    Data cQuery         As Character    //Armazena a query que sera executada
    Data oPublica       As Objetc       //Objeto JsonObject com a publicação
    Data lSucesso       As Logical      //Define o sucesso da execução
    Data cErro          As Character    //Armazena a mensagem de erro

    Data cAssinante     As Character
    Data oBuscaObj      As Object

    Method New(cAssinante)                  //Metodo construtor da Classe
    Method Consulta(cAssinante)             //Metodo responsavel em consultar as mensagem disponiveis na fila para processamento
    Method TrataObj(cTexto)                 //Metodo para realizar o tratamento do objeto que é instancia da classe RmiBuscaObj
    Method Gravar()                         //Grava o conteudo no campo MHQ_MENSAGE
    Method PosMHP(cAssinante, cProcesso)    //Posiciona no registro da MHP
    Method RetFil(cCodFilial)               //Retorna a filial do Protheus que esta cadastrado no de/para
    Method Reprocessa(cUUID, cProcesso)     //Reprocessa uma mensagem que esta com status igual a 3 na MHQ
    Method ExecParseXml(cMsgOriginal)       //Executa o parse do XML e devolve um objeto

    Method GeraMsg()                        //Metodo responsavel em gravar a mensagem no campo MHQ_MENSAG
    Method Especificos(cPonto)              //Metodo abstrato, para permitir particularidade no tratamento dos campos.
    Method Inutilizacao()                   //Metodo responsavel por alterar o layout de publicação para atender a gravação de uma inutlização

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiGrvMsgPubObj

    Default cAssinante  := ""

    self:cAliasQuery    := ""
    self:cQuery         := ""
    self:oPublica       := Nil
    self:lSucesso       := .T.
    self:cErro          := ""

    self:cAssinante     := cAssinante
    self:oBuscaObj      := Nil

    If !Empty(self:cAssinante) 
        //Realiza a consulta para saber se tem publicação com status = 0
        self:Consulta(self:cAssinante)
    EndIf

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo responsavel em consultar as mensagem disponiveis na fila para processamento

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method Consulta(cAssinante) Class RmiGrvMsgPubObj

    Local cDB       := TcGetDB()
    Local cQuant    := "1000"
    Local cSelect   := IIF( cDB == "MSSQL"            , " TOP " + cQuant          , "" )
    Local cWhere    := IIF( cDB == "ORACLE"           , " AND ROWNUM <= " + cQuant, "" )
    Local cOrder    := IIF( !(cDB $ "MSSQL|ORACLE")   , " LIMIT " + cQuant        , "" )

    Default cAssinante := ""

    Self:cAliasQuery := GetNextAlias()

    //fazer Inner Join com MHP para não tentar reprocessar Processos Inativos.
    self:cQuery := "SELECT "
    self:cQuery += cSelect
    self:cQuery += " MHQ.R_E_C_N_O_"
    Self:cQuery += " FROM " + RetSqlName("MHQ") + " MHQ "
    Self:cQuery +=      " INNER JOIN " + RetSqlName("MHP") + " MHP "
    Self:cQuery +=          " ON MHP_FILIAL = MHQ_FILIAL AND MHP_CASSIN = MHQ_ORIGEM AND MHP_ATIVO = '1' AND MHP_CPROCE = MHQ_CPROCE AND MHP.D_E_L_E_T_ = ' ' "
    Self:cQuery += " WHERE MHQ_ORIGEM = '" + cAssinante + "'"
    Self:cQuery +=      " AND MHQ_STATUS = '0' "
    Self:cQuery +=      " AND MHQ.D_E_L_E_T_ = ' ' "
    self:cQuery += cWhere    

    self:cQuery += cOrder

    LjGrvLog("RMIGRVMSGPUBOBJ","Query a ser executada - [CONSULTA]",Self:cQuery)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , Self:cQuery), Self:cAliasQuery, .T., .F.)

    If (self:cAliasQuery)->( Eof() )
        LjGrvLog("RMIGRVMSGPUBOBJ", "Não foi encontrado nenhum registro (MHQ_STATUS = 0) na fila " +;
                        " para processar a mensagem e gravar no campo MHQ_MENSAGE", "Query: " + Self:cQuery)
    EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} TrataObj
Metodo para realizar o tratamento do objeto que é instancia da classe RmiBuscaObj

@author  	Bruno Almeida
@version 	1.0
@since      26/05/2020
@return	    
/*/
//--------------------------------------------------------
Method TrataObj(cTexto) Class RmiGrvMsgPubObj

    If ValType(self:oBuscaObj) == "O"
        cTexto := StrTran(cTexto, "self", "self:oBuscaObj" )
    Else
        cTexto := StrTran(cTexto, "self", "oBuscaObj"      )
    EndIf

Return cTexto

//--------------------------------------------------------
/*/{Protheus.doc} Gravar
Grava o conteudo no campo MHQ_MENSAGE

@author  	Bruno Almeida
@version 	1.0
@since      26/05/2020
@return	    
/*/
//--------------------------------------------------------
Method Gravar() Class RmiGrvMsgPubObj

    Local cMsg  := ""
    Local cErro := ""

    If self:lSucesso

        cMsg := self:oPublica:toJson()
        
        If cMsg == "{}"
            self:lSucesso := .F.
            self:cErro    := "Problema ao efetuar a montagem do json, por favor verificar a documentação: https://tdn.totvs.com/pages/releaseview.action?pageId=516633428"
        EndIf
    EndIf

    If self:lSucesso
        RecLock("MHQ", .F.)
            MHQ->MHQ_MENSAG := cMsg
            MHQ->MHQ_STATUS := "1"
        MHQ->( MsUnLock() )

        LjGrvLog("RMIGRVMSGPUBOBJ", "Mensagem gravada com sucesso!", "Venda (MHQ_CHVUNI): " + MHQ->MHQ_CHVUNI)
    Else

		//Aguarda 1 hora para gerar erro quando tem dependência de de\para
        cErro := StrTran(self:cErro, "/", "#")
        cErro := StrTran(cErro     , "\", "#")
        cErro := AllTrim( Upper(cErro) )
        If ElapTime( Substr(MHQ->MHQ_HORGER,1,Len(Time())), Time() ) <= "01:00:00" .And. ( ("DE#PARA" $ cErro) .Or. ("SA1" $ cErro) .Or. ("SA3" $ cErro) .Or. ("SA6" $ cErro) .Or. ("SM0" $ cErro) )
		
			LjxjMsgErr( I18n("Integração aguardando possivel processamento de De\Para para continuar. UUID[#1] Descricao[#2]", {MHQ->MHQ_UUID, AllTrim(self:cErro)}) , /*cSolucao*/, "RmiGrvMsgPubObj - Gravar")
		Else

	        RmiGrvLog(  "IR"            , "MHQ"         , MHQ->(Recno())    , "PUBLICACAO"      ,;
	                    self:cErro      , .F.           , /*lTxt*/          , "MHQ_STATUS"      ,;
	                    .T.             , 7             , MHQ->MHQ_CHVUNI   , MHQ->MHQ_CPROCE   ,;
	                    MHQ->MHQ_ORIGEM ,MHQ->MHQ_UUID  )
	                    
	        LjGrvLog("RMIGRVMSGPUBOBJ", self:cErro, "MHQ_CHVUNI: " + MHQ->MHQ_CHVUNI)
        EndIf
    EndIf

    self:lSucesso := .T.
    self:cErro    := ""

    If ValType(self:oBuscaObj) == "O"
        self:oBuscaObj:lSucesso := .T.
        self:oBuscaObj:cRetorno := ""
    EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} PosMHP
Posiciona no registro da MHP

@author  	Bruno Almeida
@version 	1.0
@since      27/05/2020
@return	    
/*/
//--------------------------------------------------------
Method PosMHP(cAssinante, cProcesso) Class RmiGrvMsgPubObj

Local cAlias := GetNextAlias()
Local cQuery := ""

Default cAssinante := ""
Default cProcesso := ""

cQuery := "SELECT HP.R_E_C_N_O_ "
cQuery += "  FROM " + RetSqlName("MHO") + " HO "
cQuery += "       INNER JOIN " + RetSqlName("MHP") + " HP ON HP.MHP_FILIAL = HO.MHO_FILIAL"
cQuery += "	                                            AND HP.MHP_CASSIN = HO.MHO_COD"
cQuery += " WHERE HP.MHP_CASSIN = '" + cAssinante + "'"
cQuery += "   AND HP.MHP_CPROCE = '" + cProcesso + "'"
cQuery += "   AND HP.MHP_ATIVO = '1'"
LjGrvLog("RMIGRVMSGPUBOBJ","Query a ser executada - [POSMHP]",cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

If !(cAlias)->( Eof() )
    dbSelectArea("MHP")
    MHP->(dbGoto((cAlias)->R_E_C_N_O_))
    LjGrvLog("RMIGRVMSGPUBOBJ", "Posicionou com sucesso no registro da MHP", AllTrim(MHP->MHP_CASSIN) + "|" + AllTrim(MHP->MHP_CPROCE))
Else
    Self:lSucesso := .F.
    Self:cErro := STR0004 + cAssinante + STR0005 + cProcesso //"Não foi encontrado o processo (MHP), o processo pode não estar cadastrado ou não esta ativo. Assinante: " # " - Processo: "
    LjGrvLog("RMIGRVMSGPUBOBJ",Self:cErro)
EndIf

(cAlias)->( DbCloseArea() )

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} RetFil
Retorna a filial do Protheus que esta cadastrado no de/para

@author  	Bruno Almeida
@version 	1.0
@since      27/05/2020
@return	    
/*/
//--------------------------------------------------------
Method RetFil(cSisOrigem, cAlias, nCodFilial, lOrigem) Class RmiGrvMsgPubObj

Local cRet := ""

Default cSisOrigem := ""
Default cAlias := "SM0"
Default nCodFilial := ""
Default lOrigem := .F.

cRet := RmiDePaRet(cSisOrigem, cAlias, nCodFilial, lOrigem)

If Empty(cRet)
    Self:lSucesso   := .F.
    Self:cErro      := STR0001 + IIF(ValType(nCodFilial) == "N", cValToChar(nCodFilial), nCodFilial)  //"De/para de filial (SM0) não encontrado - Cod. da Filial de Origem: "
    LjGrvLog("RMIGRVMSGPUBOBJ", Self:cErro)
Else
    LjGrvLog("RMIGRVMSGPUBOBJ", "Retorno do de/para da filial com sucesso!", "Venda (MHQ_CHVUNI): " + MHQ->MHQ_CHVUNI)    
EndIf

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc} Reprocessa
Reprocessa uma mensagem que esta com status igual a 3 na MHQ

@author  	Bruno Almeida
@version 	1.0
@since      27/05/2020
@return	    
/*/
//--------------------------------------------------------
Method Reprocessa(cUUID, cProcesso) Class RmiGrvMsgPubObj
Local cAlias := GetNextAlias()
Local cQuery := ""

Default cUUID := ""
Default cProcesso := "VENDA"

cQuery := "SELECT R_E_C_N_O_ "
cQuery += "  FROM " + RetSqlName("MHQ") + " "
cQuery += " WHERE MHQ_UUID = '" + cUUID + "'"

LjGrvLog("RMIGRVMSGPUBOBJ","Query a ser executada - [Reprocessa]",cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

If !(cAlias)->( Eof() )

    While !(cAlias)->( Eof() )
        MHQ->(dbGoto((cAlias)->R_E_C_N_O_))

        RecLock("MHQ", .F.)        
            MHQ->MHQ_STATUS := "0"
            MHQ->MHQ_MENSAG := ""        
        MHQ->( MsUnLock() )        

        (cAlias)->( DbSkip() )
    EndDo
    (cAlias)->( DbCloseArea() )

Else
    LjGrvLog("RMIGRVMSGPUBOBJ", "Não foi encontrada nenhuma publicação para reprocessar!", "Query: " + cQuery)    
EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} ExecParseXml
Executa o parse do XML e devolve um objeto

@author  	Bruno Almeida
@version 	1.0
@since      28/05/2020
@return	    
/*/
//--------------------------------------------------------
Method ExecParseXml(cMsgOriginal) Class RmiGrvMsgPubObj

Local oRet      := Nil  //Objeto de retorno
Local cError    := ""   //Grava o erro do parse do XML
Local cWarning  := ""   //Grava os warnings do parse do XML
Local oParse    := Nil  //Objeto para realização do parse do XML

Default cMsgOriginal := ""

If !Empty(cMsgOriginal)
    
    cMsgOriginal := "<XML>" + cMsgOriginal + "</XML>"
    oParse       := XmlParser(cMsgOriginal, "_", @cError, @cWarning)

    If Empty(cError)
        oRet := oParse:_XML

    Else

        Self:lSucesso := .F.
        Self:cErro    := STR0002 + cError   //"Erro ao realizar o XMLParser - "
        LjGrvLog("RMIGRVMSGPUBOBJ", self:cErro)
    EndIf
Else

    Self:lSucesso := .F.
    Self:cErro    := STR0003    //"O parâmetro cMsgOriginal esta vazio e não vai ser possível executar o XMLParser"
    LjGrvLog("RMIGRVMSGPUBOBJ", self:cErro)
EndIf

Return oRet

//--------------------------------------------------------
/*/{Protheus.doc} GravaMsg
Metodo responsavel em gravar a mensagem no campo MHQ_MENSAG

@author  Rafael Tenorio da Costa
@version 1.0
@since   02/12/21
/*/
//--------------------------------------------------------
Method GeraMsg() Class RmiGrvMsgPubObj

    Local aTags         := {}   //Guarda as tags do layout de publicação
    Local aTagsSec      := {}   //Guarda as tags filhas do layout de publicação
    Local aNoFilho      := {}   //Array do No Filho com os itens que serão procesasdos
    Local xNoFilho      := Nil  //Objeto do No Filho com os itens que serão procesasdos
    Local nTagSec       := 0    //Variavel de loop
    Local cLayoutPub    := ""   //Propriedade que será macro executada para pegar o contedo retornado pelo assinante
    Local nItem         := 0    //Variavel de loop
    Local nTag          := 0    //Variavel de loop

    If !(self:cAliasQuery)->( Eof() )

        LjGrvLog(GetClassName(self), "Existe publicações com status = 0")
        While !(self:cAliasQuery)->( Eof() )
        
            //Move para o registro
            MHQ->(dbGoto((self:cAliasQuery)->R_E_C_N_O_))

            //Carrega chave única
            self:oBuscaObj:cChaveUnica := AllTrim(MHQ->MHQ_CHVUNI)
            //Carrega Evento
            self:oBuscaObj:cEvento := AllTrim(MHQ->MHQ_EVENTO)

            //Aqui estou instanciando a classe RmiBuscaObj para utilizar os objetos oLayoutPub, oConfProce, oRegistro e o metodo AuxTrataTag
            self:oBuscaObj:SetaProcesso( AllTrim(MHQ->MHQ_CPROCE) )

            //Posiciona na MHP
            Self:PosMHP( AllTrim(MHQ->MHQ_ORIGEM), AllTrim(MHQ->MHQ_CPROCE) )

            If Self:lSucesso 
            
                If self:oBuscaObj:oRegistro == Nil
                    self:oBuscaObj:oRegistro := JsonObject():New()
                EndIf
                self:oBuscaObj:oRegistro:FromJson(MHQ->MHQ_MSGORI)

                //Trata campos especificos
                self:Especificos("INICIO")

                If self:lSucesso
                    //Guarda o array todas as tags do layout de publicação
                    aTags := self:oBuscaObj:oLayoutPub:GetNames()

                    //Cria objeto que conterá a publicação
                    If self:oPublica == Nil
                        self:oPublica := JsonObject():New()
                    EndIf

                    //Percorre tags do layout de publicação
                    For nTag := 1 To Len(aTags)

                        //Processa tags de um NÓ filho
                        If self:oBuscaObj:oConfProce:HasProperty("listasPublicacao") .And. self:oBuscaObj:oConfProce["listasPublicacao"]:HasProperty( aTags[nTag] )
                            
                            self:oPublica[ aTags[nTag] ] := {}

                            //Pega o nome das tags filhas
                            aTagsSec := self:oBuscaObj:oLayoutPub[ aTags[nTag] ][1]:GetNames()

                            //Pega o caminho para o No Filho
                            aNoFilho := {}
                            ASize(aNoFilho, 0)
                            xNoFilho := &( Self:TrataObj( self:oBuscaObj:oConfProce["listasPublicacao"][aTags[nTag]] ) )

                            //Tratamento no layout para quando tiver apenas 1 item
                            If ValType(xNoFilho) == "O"
                                Aadd(aNoFilho, xNoFilho)
                            Else
                                aNoFilho := xNoFilho
                            EndIf

                            If ValType(aNoFilho) == "A"

                                For nItem:=1 To Len( aNoFilho )

                                    Aadd(self:oPublica[ aTags[nTag] ], JsonObject():New())

                                    //Carrega tags do No Filho
                                    For nTagSec:=1 To Len(aTagsSec)

                                        cLayoutPub := self:oBuscaObj:oLayoutPub[ aTags[nTag] ][1][ aTagsSec[nTagSec] ]
                                        
                                        //Tratamento no layout para quando tiver apenas 1 item
                                        If ValType(xNoFilho) == "O"
                                            cLayoutPub := StrTran( cLayoutPub, "[nItem]", "")
                                        EndIf

                                        self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := self:oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)
                                        
                                        If !self:oBuscaObj:lSucesso
                                            Self:lSucesso := .F.
                                            Self:cErro    := self:oBuscaObj:cRetorno
                                            LjGrvLog(GetClassName(self),Self:cErro)
                                            Exit
                                        ElseIf !Self:lSucesso
                                            Exit
                                        EndIf

                                    Next nTagSec

                                    If !self:oBuscaObj:lSucesso .OR. !Self:lSucesso
                                        Exit
                                    EndIf
                                Next nItem
                            EndIf

                        //Processa tags principais
                        Else                    

                            self:oPublica[ aTags[nTag] ] := self:oBuscaObj:AuxTrataTag( aTags[nTag],  self:oBuscaObj:oLayoutPub[ aTags[nTag] ] )

                            If !self:oBuscaObj:lSucesso
                                Self:lSucesso := .F.
                                Self:cErro    := self:oBuscaObj:cRetorno
                                LjGrvLog(GetClassName(self), Self:cErro)
                            EndIf                
                        Endif

                        If !Self:lSucesso
                            Exit
                        EndIf

                    Next nTag
                EndIf
            Else
                LjGrvLog(GetClassName(self), "Sem sucesso na verificação dentro do objeto", self:cErro)
            EndIf

            //Trata campos especificos
            If self:lSucesso
                self:Especificos("FIM")
            EndIf

            //Grava informação no campo MHQ_MENSAGE
            self:Gravar()

            //Limpa os objetos
            FwFreeObj(xNoFilho)
            FwFreeObj(self:oPublica)
            xNoFilho                := Nil
            self:oPublica           := Nil

            If ValType(aNoFilho) == "A"
                Asize(aNoFilho, 0)
            EndIf
            Asize(aTagsSec, 0)

            (self:cAliasQuery)->( DbSkip() )
        EndDo
    EndIf

    (self:cAliasQuery)->( DbCloseArea() )

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Especificos
Método abstrato, para permitir particularidade no tratamento dos campos.
Sua implementação estará na classe mais especifica.

@type    Method
@param   cPonto, Caractere, Define o ponto onde esta sendo chamado o metodo.
@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Especificos(cPonto) Class RmiGrvMsgPubObj

    If !self:oBuscaObj:lSucesso
        self:lSucesso := .F.
        self:cErro    := self:oBuscaObj:cRetorno
    EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Inutilizacao
Metodo responsavel por montar layout reduzido de inutilização com base nos campos necessarios

@author  Lucas Novais (lnovais@)
@version 1.0
@since   19/07/22 
/*/
//--------------------------------------------------------

Method Inutilizacao(cFilialLX,cDoc,cSerie,cOperador,cSitua,cDataInut,cProtocolo,cChave,cMotivo,cCodRSefaz,cPdv) Class RmiGrvMsgPubObj
    Local cJson := ""
    
    // -- Limpo o layout atual de venda para a criação do layout de inutilização
    FwFreeObj(self:oBuscaObj:oLayoutPub)

    self:oBuscaObj:oLayoutPub  := JsonObject():New()

    BeginContent var cJson
        {
            "LX_FILIAL":"%Exp:cFilialLX%",
            "L1_DOC":"%Exp:cDoc%",
            "L1_SERIE":"%Exp:cSerie%",
            "L1_OPERADO":"%Exp:cOperador%",
            "L1_SITUA":"%Exp:cSitua%",
            "LX_DTINUTI":"%Exp:cDataInut%",
            "LX_PRINUT":"%Exp:cProtocolo%",
            "LX_CHVNFCE":"%Exp:cChave%",
            "LX_MOTIVO":"%Exp:cMotivo%",
            "LX_RETSFZ":"%Exp:cCodRSefaz%",
            "L1_PDV":"%Exp:cPdv%"
        }
    EndContent

    self:oBuscaObj:oLayoutPub:FromJson(cJson) 

return
