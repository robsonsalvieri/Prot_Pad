#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RMIGRVMSGPUBLIVEOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgPubLiveObj
Classe responsável em gravar o Json de publicação no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubLiveObj From RmiGrvMsgPubObj

    Method New()	                //Metodo construtor da Classe

    Method GeraMsg(cAssinante)      //Metodo responsavel em gravar as mensagem no campo MHQ_MENSAG

    Method NotaEntrada(oBuscaObj)   //Metodo responsavel em carregar a propriedade self:oPublica com a publicação de Nota de Entrada

    //Metodos auxiliares para tratamento interno da classe
    Method AuxTrataTag(cTag, xConteudo, nItem, oBuscaObj)   //Metodo para efetuar o tratamento das Tags que serão gravadas na publicação
    Method AjustTagL4() //Metodo para retirar a forma de pagamento vazia {} que esta na SL4 devido a forma de pagamento Vale Credito

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiGrvMsgPubLiveObj

    _Super:New()

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} GravaMsg
Metodo responsavel em gravar as mensagem no campo MHQ_MENSAG

@author  	Bruno Almeida
@version 	1.0
@since      28/05/2020
@return	    
/*/
//--------------------------------------------------------
Method GeraMsg(cAssinante) Class RmiGrvMsgPubLiveObj

    Local aTags         := {}       //Guarda as tags do layout de publicação
    Local aTagsSec      := {}       //Guarda as tags filhas do layout de publicação
    Local aNoFilho      := {}       //Array do No Filho com os itens que serão procesasdos
    Local xNoFilho      := Nil      //Objeto do No Filho com os itens que serão procesasdos
    Local nTagSec       := 0        //Variavel de loop
    Local cLayoutPub    := ""       //Propriedade que será macro executada para pegar o contedo retornado pelo assinante
    Local nItem         := 0        //Variavel de loop
    Local nTag          := 0        //Variavel de loop
    Local oBuscaObj     := Nil      //Instância da classe RmibuscaObj
    Local aTagsTri      := {}       //Armazena os dados de tributação do Live
    Local nTrib         := 0        //Variavel de loop
    Local aCmpsTri      := {}       //Campo de tributação
    Local lIsICMS       := .F.
    Local lIsFCP        := .F.
    Local nL2Perc       := 0
    Local nL2BasC       := 0
    Local nValTrib      := 0
    Local lContNo       := .T. 		//Variavel para controlar se processa ou nao o nó do XML/JSON
    Local nValCredito   := 0        //Variavel com o valor total do vale troca
    Local oError        := Nil      //Objeto para capturar o erro do Try/Exception

    Default cAssinante := ""

    //Realiza a consulta para saber se tem publicação com status = 0
    Self:Consulta(cAssinante)

    If !(self:cAliasQuery)->( Eof() )

        LjGrvLog("RMIGRVPUBLIVEOBJ", "Existe publicações com status = 0")
        While !(self:cAliasQuery)->( Eof() )

            //Move para o registro
            MHQ->(dbGoto((self:cAliasQuery)->R_E_C_N_O_))

            //Aqui estou instanciando a classe RmiBuscaObj para utilizar os objetos oLayoutPub, oConfProce, oRegistro e o metodo AuxTrataTag
            oBuscaObj := RmiBusLiveObj():New()
            oBuscaObj:SetaProcesso(AllTrim(MHQ->MHQ_CPROCE))

            //Posiciona na MHP
            Self:PosMHP(AllTrim(MHQ->MHQ_ORIGEM), AllTrim(MHQ->MHQ_CPROCE))

            If Self:lSucesso .AND. oBuscaObj:lSucesso

                oBuscaObj:oRegistro := Self:ExecParseXml(MHQ->MHQ_MSGORI)
                
                If Self:lSucesso

                    If self:oPublica == Nil
                        self:oPublica := JsonObject():New()
                    EndIf

                    If Alltrim(MHQ->MHQ_CPROCE) == "NOTA DE ENTRADA"

                        self:NotaEntrada(oBuscaObj)
                    Else

                        //Guarda o array todas as tags do layout de publicação
                        aTags := oBuscaObj:oLayoutPub:GetNames()

                        //Percorre tags do layout de publicação
                        For nTag := 1 To Len(aTags)

                            If !(Alltrim(MHQ->MHQ_CPROCE) == "VENDA")

                                If ValType(oBuscaObj:oLayoutPub:GetJsonObject(aTags[nTag])) == "A"
                                    self:oPublica[aTags[nTag]] := {}
                                    aTagsSec := oBuscaObj:oLayoutPub[ aTags[nTag] ][1]:GetNames()
                                    //Pega o caminho para o No Filho

                                    ASize(aNoFilho, 0)

                                    //Condição que pode dar erro
                                    TRY EXCEPTION
                                        xNoFilho := &( Self:TrataObj(oBuscaObj:oConfProce[ aTags[nTag] ] ) )
                                        lContNo := .T.
                                    //Se ocorreu erro
                                    CATCH EXCEPTION USING oError
                                        LjGrvLog("RMIBUSLIVEOBJ","Erro ao macro executar o nó - " + oBuscaObj:oConfProce[ aTags[nTag] ])      
                                        lContNo := .F.                  
                                    ENDTRY

                                    If lContNo
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

                                                    cLayoutPub := oBuscaObj:oLayoutPub[ aTags[nTag] ][1][ aTagsSec[nTagSec] ]
                                                    
                                                    //Tratamento no layout para quando tiver apenas 1 item
                                                    If ValType(xNoFilho) == "O"
                                                        cLayoutPub := StrTran( cLayoutPub, "[nItem]", "")
                                                    EndIf
                                                    
                                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)

                                                Next nTagSec
                                                //Ajusto o array para default 
                                                aTagsSec := oBuscaObj:oLayoutPub[ aTags[nTag] ][1]:GetNames()                  
                                            Next nItem
                                        EndIf
                                    EndIf

                                Else
                                    self:oPublica[ aTags[nTag] ] := oBuscaObj:AuxTrataTag( aTags[nTag], oBuscaObj:oLayoutPub[ aTags[nTag] ] )
                                EndIf   
                            
                                If !oBuscaObj:lSucesso
                                    Self:lSucesso := .F.
                                    Self:cErro := oBuscaObj:cRetorno
                                    LjGrvLog("RMIGRVPUBLIVEOBJ",Self:cErro)
                                    Exit
                                EndIf
                        
                            Else
                                //Processa tags de um NÓ filho
                                TRY EXCEPTION //Quando é Inutilização não existem Itens no XML do Live. 
                                    If aTags[nTag] $ "SL2|SL4" .AND. Upper( AllTrim(oBuscaObj:oRegistro:_SituacaoNFCe:Text) ) <> "INUTILIZADO"
                                        
                                        self:oPublica[ aTags[nTag] ] := {}

                                        //Pega o nome das tags filhas
                                        aTagsSec := oBuscaObj:oLayoutPub[ aTags[nTag] ][1]:GetNames()

                                        //Pega o caminho para o No Filho
                                        ASize(aNoFilho, 0)
                                        xNoFilho := &( Self:TrataObj(oBuscaObj:oConfProce[ aTags[nTag] ]) )

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

                                                    cLayoutPub := oBuscaObj:oLayoutPub[ aTags[nTag] ][1][ aTagsSec[nTagSec] ]
                                                    
                                                    //Tratamento no layout para quando tiver apenas 1 item
                                                    If ValType(xNoFilho) == "O"
                                                        cLayoutPub := StrTran( cLayoutPub, "[nItem]", "")
                                                    EndIf
                                                                                                                                //se for vale troca tem que entrar na validação do Else.
                                                    If aTags[nTag] == "SL4" .and. oBuscaObj:oRegistro:_Situacao:Text == "C" .AND. !(aNoFilho[nItem]:_FORMAPAGAMENTO:Text == AllTrim(oBuscaObj:oConfProce["ValeTroca"]))
                                                        Do Case
                                                            Case aTagsSec[nTagSec] == "L4_FORMA"
                                                                If VALTYPE(oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)) <> "C" 
                                                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := "R$"
                                                                else
                                                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)    
                                                                EndIf        


                                                            Case aTagsSec[nTagSec] == "L4_VALOR"
                                                                If VALTYPE(oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)) <> "N"
                                                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := self:oPublica[ aTags[Ascan(aTags,"L1_VLRTOT")] ]
                                                                else
                                                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)    
                                                                EndIf        

                                                            OTHERWISE
                                                                self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)
                                                        End Case
                                                    Else
                                                        //Tratamento para o Vale Troca
                                                        //Na configuração do processo vai ter configurado o código do vale troca, se não
                                                        //esta configurado então é gerado o log.
                                                        If AllTrim(aTags[nTag]) == "SL4" .AND. Empty(oBuscaObj:oConfProce["ValeTroca"])
                                                            LjGrvLog("RMIGRVPUBLIVEOBJ","A tag ValeTroca não existe ou não esta preenchida no cadastro de assinante do Live nas configurações" +;
                                                                                        " do processo de venda. Nesta tag, deve conter o numero da forma de pagamento Vale Troca do Live.")
                                                        EndIf      
                                                        //Se a forma de pagamento for igual ao informado na tag ValeTroca, significa que aquela venda é 
                                                        //proveniente de uma troca/devolução no Live, neste caso o valor do Vale Troca é gravado no campo
                                                        //L1_CREDITO.
                                                        If AllTrim(aTags[nTag]) == "SL4" .AND. aNoFilho[nItem]:_FORMAPAGAMENTO:Text == AllTrim(oBuscaObj:oConfProce["ValeTroca"])
                                                            nValCredito += Val(StrTransf(aNoFilho[nItem]:_VALORPAGAMENTO:Text,",","."))
                                                            Exit
                                                        Else
                                                            self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)
                                                        EndIf
                                                    EndIf

                                                    If !oBuscaObj:lSucesso
                                                        Self:lSucesso := .F.
                                                        Self:cErro := oBuscaObj:cRetorno
                                                        LjGrvLog("RMIGRVPUBLIVEOBJ",Self:cErro)
                                                        Exit
                                                    EndIf

                                                Next nTagSec

                                                If !Self:lSucesso
                                                    Exit
                                                EndIf

                                                TRY EXCEPTION
                                                    //Tratamento para impostos
                                                    If aTags[nTag] == "SL2"
                                                        If Upper( AllTrim(oBuscaObj:oRegistro:_SituacaoNFCe:Text) ) <> "INUTILIZADO"
                                                            If Valtype(oBuscaObj:oRegistro:_Itens:_Lc_ItemCupomfiscal) == "O"
                                                                If Valtype(oBuscaObj:oRegistro:_Itens:_Lc_ItemCupomfiscal:_Tributos:_Lc_TributoCupomFiscal) == "O"
                                                                    aTagsTri:={}
                                                                    Aadd(aTagsTri,oBuscaObj:oRegistro:_Itens:_Lc_ItemCupomfiscal:_Tributos:_Lc_TributoCupomFiscal)    
                                                                Else
                                                                    cLayoutPub := "oBuscaObj:oRegistro:_Itens:_Lc_ItemCupomfiscal:_Tributos:_Lc_TributoCupomFiscal"
                                                                    aTagsTri := &(cLayoutPub)
                                                                EndIf    
                                                            Else //Caso seja enviado apenas um tributo dentro ItemCupomfiscal vem com tipo Object.
                                                                If Valtype(oBuscaObj:oRegistro:_Itens:_Lc_ItemCupomfiscal[nItem]:_Tributos:_Lc_TributoCupomFiscal) == "O"
                                                                    aTagsTri:={}
                                                                    Aadd(aTagsTri,oBuscaObj:oRegistro:_Itens:_Lc_ItemCupomfiscal[nItem]:_Tributos:_Lc_TributoCupomFiscal)
                                                                else
                                                                    cLayoutPub := "oBuscaObj:oRegistro:_Itens:_Lc_ItemCupomfiscal[nItem]:_Tributos:_Lc_TributoCupomFiscal"
                                                                    aTagsTri := &(cLayoutPub)
                                                                EndIf        
                                                            EndIf
                                                            
                                                        EndIf    

                                                        For nTrib := 1 To Len (aTagsTri)

                                                            ASize(aCmpsTri, 0)
                                                            lIsICMS := .F.
                                                            lIsFCP  := .F.

                                                            Do Case
                                                                Case aTagsTri[nTrib]:_DescricaoTributo:Text == "ICMS"
                                                                    aCmpsTri := {"L2_VALICM" , "L2_BASEICM", "L2_PICM"   }
                                                                    lIsICMS := .T.

                                                                Case aTagsTri[nTrib]:_DescricaoTributo:Text == "PIS"
                                                                    aCmpsTri := {"L2_VALPS2" , "L2_BASEPS2", "L2_ALIQPS2","L2_CSTPIS"}

                                                                Case aTagsTri[nTrib]:_DescricaoTributo:Text == "COFINS"
                                                                    aCmpsTri := {"L2_VALCF2", "L2_BASECF2", "L2_ALIQCF2","L2_CSTCOF"}
                                                                
                                                                Case aTagsTri[nTrib]:_DescricaoTributo:Text == "FCP"
                                                                    aCmpsTri := {"L2_VALFECP", "L2_BASFECP", "L2_ALQFECP"}
                                                                    lIsFCP := .T.    
                                                            End Case

                                                            If Len(aCmpsTri) > 0

                                                                Aadd(aTagsSec, aCmpsTri[1])
                                                                nTagSec := Len(aTagsSec)
                                                                nValTrib := oBuscaObj:AuxTrataTag(aTagsSec[nTagSec], aTagsTri[nTrib]:_ValorTributo:Text, nItem)

                                                                self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := nValTrib
                                                                
                                                                Aadd(aTagsSec, aCmpsTri[2]) // Base de Cálculo
                                                                nTagSec := Len(aTagsSec)
                                                                nL2BasC := oBuscaObj:AuxTrataTag(aTagsSec[nTagSec], aTagsTri[nTrib]:_BaseCalculo:Text , nItem)
                                                                self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := nL2BasC


                                                                //Em vendas com redução da alíquota vem com o valor cheio ao inves da alíquota reduzida
                                                                //O Live faz o calculo da base Reduzida. Ponto anterior Retirado.
                                                                Aadd(aTagsSec, aCmpsTri[3])// Alíquota
                                                                nTagSec := Len(aTagsSec)
                                                                
                                                                nL2Perc := oBuscaObj:AuxTrataTag(aTagsSec[nTagSec], aTagsTri[nTrib]:_Aliquota:Text    , nItem)
                                                                self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := nL2Perc
                                                                
                                                                If !lIsICMS .AND. !lIsFCP// Alimenta CST PIS e COF 
                                                                    Aadd(aTagsSec, aCmpsTri[4]) // CST PIS e COF
                                                                    nTagSec := Len(aTagsSec)
                                                                    nL2BasC := oBuscaObj:AuxTrataTag(aTagsSec[nTagSec], aTagsTri[nTrib]:_SituacaoTributaria:Text , nItem)
                                                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := nL2BasC
                                                                EndIf    
                                                                
                                                            EndIf

                                                            If !oBuscaObj:lSucesso
                                                                Self:lSucesso := .F.
                                                                Self:cErro := oBuscaObj:cRetorno
                                                                LjGrvLog("RMIGRVPUBLIVEOBJ",Self:cErro)
                                                                Exit
                                                            EndIf                                    
                                                        Next nTrib

                                                    EndIf
                                                CATCH EXCEPTION USING oError
                                                    Self:lSucesso := .F. // ajusta variavel para gravar o log na MHL
                                                    Self:cErro    := STR0004+oError:Description // "Propriedade Invalida Verifique o XML Recebido no campo MHQ_MSGORI: TAG-> "+ Pega descrição do Erro do Try...
                                                    LjGrvLog("RMIGRVPUBLIVEOBJ",STR0004+oError:Description)
                                                ENDTRY    
                                                
                                                If !Self:lSucesso
                                                    Exit
                                                EndIf

                                                //Ajusto o array para default 
                                                aTagsSec := oBuscaObj:oLayoutPub[ aTags[nTag] ][1]:GetNames()                  
                                            Next nItem
                                        
                                        EndIf

                                    //Processa tags principais
                                    Else
                                        //Ajuste pq no live DataInutilizacao só vem preenchido corretamente quando tem o Retorno da SEFAZ caso contrario grava com erro.
                                        If Upper( AllTrim(oBuscaObj:oRegistro:_SituacaoNFCe:Text) ) == "INUTILIZADO"
                                            If Empty(oBuscaObj:oRegistro:_DataInutilizacao:Text) .OR. (AllTrim(oBuscaObj:oRegistro:_DataInutilizacao:Text) == "01/01/0001 00:00:00";
                                            .Or.  AllTrim(oBuscaObj:oRegistro:_DataInutilizacao:Text) ==  "01/01/1900 00:00:00") //é possivel que venha as duas datas.
                                                Self:lSucesso := .F.
                                                Self:cErro := STR0005//'Inutilização não foi transmitida pelo sistema Origem, solicite o reenvio para um novo processamento!  '
                                                Self:cErro += 'Tag:DataInutilizacao invalida '
                                                
                                                LjGrvLog("INUTILIZADO", "Tag:DataInutilizacao em Branco ou data invalida, por esse motivo a mensagem será gravada com erro",{oBuscaObj:oRegistro})
                                                LjGrvLog("RMIGRVPUBLIVEOBJ",Self:cErro)
                                            EndIf        
                                        EndIf
                                        If Self:lSucesso
                                            self:oPublica[ aTags[nTag] ] := oBuscaObj:AuxTrataTag( aTags[nTag], oBuscaObj:oLayoutPub[ aTags[nTag] ] )
                                            If !oBuscaObj:lSucesso
                                                Self:lSucesso := .F.
                                                Self:cErro := oBuscaObj:cRetorno
                                                LjGrvLog("RMIGRVPUBLIVEOBJ",Self:cErro)
                                            EndIf
                                        EndIf    
                                    Endif
                                CATCH EXCEPTION USING oError
                                    Self:lSucesso := .F. // ajusta variavel para gravar o log na MHL
                                    Self:cErro    := STR0004+oError:Description // "Propriedade Invalida Verifique o XML Recebido no campo MHQ_MSGORI: TAG-> "+ Pega descrição do Erro do Try...
                                    LjGrvLog("RMIGRVPUBLIVEOBJ",STR0004+oError:Description)                                                            
                                ENDTRY
                                If !Self:lSucesso
                                    Exit
                                EndIf
                            EndIF

                        Next nTag

                    EndIf

                EndIf
            Else

                self:lSucesso := .F.
                self:cErro    := STR0006 + " (MHQ_MENSAG): " + CRLF + AllTrim(self:cErro) + " | " + AllTrim(oBuscaObj:cRetorno)     //"Não foi possível carregar o campo de publicação"
                LjxjMsgErr(self:cErro)
            EndIf

            //Se tem valor de crédito, então alimenta o campo L1_CREDITO
            If nValCredito > 0
                LjGrvLog("RMIGRVPUBLIVEOBJ","Venda (UUID = " + AllTrim(MHQ->MHQ_UUID) + "), possui um valor de vale de credito de " + cValToChar(nValCredito) + ". Esse valor sera gravado no campo L1_CREDITO.")
                self:oPublica["L1_CREDITO"] := nValCredito
                LjGrvLog("RMIGRVPUBLIVEOBJ","Venda (UUID = " + AllTrim(MHQ->MHQ_UUID) + ") antes de executar o metodo AjustTagL4")
                Self:AjustTagL4(Self:oPublica)
                LjGrvLog("RMIGRVPUBLIVEOBJ","Venda (UUID = " + AllTrim(MHQ->MHQ_UUID) + ") depois que executou o metodo AjustTagL4")
            EndIf
            If (Valtype(self:oPublica) != 'U' .AND. !self:oPublica:toJson() == "{}") .OR. !Self:lSucesso // Noo method Gravar contem a gravação da MHL de LOG Self:lSucesso
                //Grava informação no campo MHQ_MENSAGE
                Self:Gravar()
            Else
                LjGrvLog("RMIGRVPUBLIVEOBJ","Houve algum problema na montagem do json. Favor verificar a documentação: https://tdn.totvs.com/pages/releaseview.action?pageId=516633428")
            EndIf

            //Limpa os objetos
            FwFreeObj(oBuscaObj)
            FwFreeObj(xNoFilho)
            FwFreeObj(self:oPublica)
            oBuscaObj     := Nil
            xNoFilho      := Nil
            self:oPublica := Nil
            nValCredito   := 0        

            If ValType(aNoFilho) == "A"
                Asize(aNoFilho, 0)
            EndIf
            Asize(aTagsSec, 0)
            Asize(aTagsTri, 0)
            Asize(aCmpsTri, 0)

            (self:cAliasQuery)->( DbSkip() )
        EndDo
    EndIf

    (self:cAliasQuery)->( DbCloseArea() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NotaEntrada
Metodo responsavel em carregar a propriedade self:oPublica com a publicação de Nota de Entrada

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method NotaEntrada(oBuscaObj) Class RmiGrvMsgPubLiveObj

    Local aTags      := oBuscaObj:oLayoutPub:GetNames()
    Local aTagsSec   := {}
    Local aNoFilho   := {}
    Local xNoFilho   := Nil
    Local nTagSec    := 0
    Local cLayoutPub := ""
    Local nItem      := 0
    Local nTag       := 0
    Local aTabSec    := RmiXSql("SELECT MHS_TABELA FROM " + RetSqlName("MHS") + " WHERE MHS_FILIAL = '" + xFilial("MHS") + "' AND MHS_CPROCE = '" + MHQ->MHQ_CPROCE + "' AND D_E_L_E_T_ = ' '", "*", /*lCommit*/, /*aReplace*/)
    Local cSituaNFe  := ""

    //Percorre tags do layout de publicação
    For nTag := 1 To Len(aTags)

        //Processa tags do Nó filho
        //If aTags[nTag] == "SD1"
        If Ascan(aTabSec, {|x| x[1] == aTags[nTag]} ) > 0
            
            self:oPublica[ aTags[nTag] ] := {}

            //Pega o nome das tags filhas
            aTagsSec := oBuscaObj:oLayoutPub[ aTags[nTag] ][1]:GetNames()

            //Pega o caminho para o No Filho
            ASize(aNoFilho, 0)
            xNoFilho := &( self:TrataObj( oBuscaObj:oConfProce[ aTags[nTag] ] ) )

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

                        cLayoutPub := oBuscaObj:oLayoutPub[ aTags[nTag] ][1][ aTagsSec[nTagSec] ]
                        
                        //Tratamento no layout para quando tiver apenas 1 item
                        If ValType(xNoFilho) == "O"
                            cLayoutPub := StrTran( cLayoutPub, "[nItem]", "")
                        EndIf
                        
                        self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := self:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem, oBuscaObj )

                        If !self:lSucesso
                            Exit
                        EndIf

                    Next nTagSec

                    If !self:lSucesso
                        Exit
                    EndIf

                Next nItem
            EndIf

        //Processa tags principais
        Else

            self:oPublica[ aTags[nTag] ] := self:AuxTrataTag( aTags[nTag], oBuscaObj:oLayoutPub[ aTags[nTag] ], /*nItem*/, oBuscaObj )
        EndIf

    Next nTag

    //Verifica situação de integração com SEFAZ
    If XmlChildEx(oBuscaObj:oRegistro, "_SITUACAOINTEGRACAONFE") <> Nil
        cSituaNFe := AllTrim( oBuscaObj:oRegistro:_SituacaoIntegracaoNFe:Text )
        If Upper(cSituaNFe) <> "INTEGRADA"
            If self:oPublica:HasProperty("F1_CHVNFE")
                LjGrvLog("RmiGrvMsgPubLiveObj", "Chave NFe da nota de entrada foi zerada. (F1_CHVNFE)", cSituaNFe)
                self:oPublica["F1_CHVNFE"] := ""
            EndIf
        EndIf 
    EndIf

    //Limpa os objetos
    FwFreeObj(xNoFilho)
    xNoFilho := Nil

    If ValType(aNoFilho) == "A"
        Asize(aNoFilho, 0)
    EndIf
    Asize(aTagsSec, 0)
    Asize(aTabSec, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxTrataTag
Metodo para efetuar o tratamento das Tags que serão gravadas na publicação

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method AuxTrataTag(cTag, xConteudo, nItem, oBuscaObj) Class RmiGrvMsgPubLiveObj

    Local xTag := oBuscaObj:AuxTrataTag(cTag, xConteudo, nItem)

    If !oBuscaObj:lSucesso
        self:lSucesso := .F.
        self:cErro    := oBuscaObj:cRetorno
        LjGrvLog("RMIGRVPUBLIVEOBJ", self:cErro)
    EndIf

Return xTag

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustTagL4
Metodo para retirar a forma de pagamento vazia {} que esta na SL4 devido a forma de
pagamento Vale Credito

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method AjustTagL4() Class RmiGrvMsgPubLiveObj

Local cJson     := Self:oPublica:ToJson() //Guarda o JSON da SL4 do objeto original
Local nI        := 0 //Variavel de loop
Local nX        := 0 //Variavel de loop
Local aFields   := {} //Array contendo os campos da SL4
Local oRet      := JsonObject():New() //Copia do objto Json da Venda
Local nTags     := 1 //Contador para add as formas de pagamento
Local oError    := Nil //Objeto para capturar o erro do Try/Exception

TRY EXCEPTION
    //Com base no Json original, cria um objeto copia.
    oRet:FromJson(cJson)

    //Exclui a chave da SL4 (copia do Json original), para 
    //adicionar novamente neste mesmo objeto mas agora sem a forma de pagamento em branco ({})
    oRet:DelName("SL4") 

    //Cria uma chave da SL4 vazia
    oRet["SL4"] := {} 

    For nI := 1 To Len(Self:oPublica["SL4"])
        If Self:oPublica["SL4"][nI]:ToJson() <> "{}"
            
            aFields := Self:oPublica["SL4"][nI]:GetNames()      
            
            Aadd(oRet["SL4"], JsonObject():New())

            For nX := 1 To Len(aFields)
                oRet["SL4"][nTags][aFields[nX]] := Self:oPublica["SL4"][nI][aFields[nX]]
            Next nX

            nTags += 1

        EndIf
    Next nI

    //Exclui no objeto original a chave da SL4, neste momento estou excluindo
    //para adicionar novamente o pagamento mas agora sem a forma de pagamento em branco ({})
    Self:oPublica:DelName("SL4")

    If oRet["SL4"] <> Nil .AND. Len(oRet["SL4"]) > 0
        Self:oPublica["SL4"] := {}
        For nI := 1 To Len(oRet["SL4"])
            Aadd(Self:oPublica["SL4"], oRet["SL4"][nI])
        Next nI
    EndIf
CATCH EXCEPTION USING oError
    LjGrvLog("RMIGRVPUBLIVEOBJ","Venda (UUID = " + AllTrim(MHQ->MHQ_UUID) + "), erro dentro do metodo AjustTagL4 - " + oError:Description) 
    Self:lSucesso   := .F.
    Self:cErro      := STR0003 + " - " + oError:Description //"Erro dentro do metodo AjustTagL4
ENDTRY

Return Nil
