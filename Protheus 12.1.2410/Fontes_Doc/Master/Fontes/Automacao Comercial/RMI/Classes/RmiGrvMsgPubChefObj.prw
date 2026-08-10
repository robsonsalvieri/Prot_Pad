#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgPubChefObj
Classe responsável em gravar o Json de publicação no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubChefObj From RmiGrvMsgPubObj

Method New()	//Metodo construtor da Classe
Method GeraMsg(cAssinante) //Metodo responsavel em gravar as mensagem no campo MHQ_MENSAG

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiGrvMsgPubChefObj

_Super:New()

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} GravaMsg
Metodo responsavel em gravar as mensagem no campo MHQ_MENSAG

@author  	Bruno Almeida
@version 	1.0
@since      25/05/2020
@return	    
/*/
//--------------------------------------------------------
Method GeraMsg(cAssinante) Class RmiGrvMsgPubChefObj

Local aTags         := {} //Guarda as tags do layout de publicação
Local aTagsSec      := {} //Guarda as tags filhas do layout de publicação
Local aNoFilho      := {} //Array do No Filho com os itens que serão procesasdos
Local xNoFilho      := Nil //Objeto do No Filho com os itens que serão procesasdos
Local nTagSec       := 0 //Variavel de loop
Local nTagTri       := 0 //Variavel de loop imposto
Local cLayoutPub    := "" //Propriedade que será macro executada para pegar o contedo retornado pelo assinante
Local cTipoImp      := "" //Tipo de imposto 
Local nItem         := 0 //Variavel de loop
Local nTag          := 0 //Variavel de loop
Local nValTrib      := 0 //Variavel numerica de Valor do Tributo
Local nL2Perc       := 0 //Variavel numerica de Percentual
Local nL2BasC       := 0 //Variavel numerica de Base de Calculo
Local oBuscaObj     := Nil //Instância da classe RmibuscaObj
Local lValTrib      := .F.
Local cSerie        := ""

Default cAssinante  := ""

//Realiza a consulta para saber se tem publicação com status = 0
Self:Consulta(cAssinante)

If !(self:cAliasQuery)->( Eof() )

    LjGrvLog("RMIGRVPUBCHEFOBJ", "Existe publicações com status = 0")
    While !(self:cAliasQuery)->( Eof() )
    
        //Move para o registro
        MHQ->(dbGoto((self:cAliasQuery)->R_E_C_N_O_))

        //Aqui estou instanciando a classe RmiBuscaObj para utilizar os objetos oLayoutPub, oConfProce, oRegistro e o metodo AuxTrataTag
        oBuscaObj := RmiBusChefObj():New()
        oBuscaObj:SetaProcesso(AllTrim(MHQ->MHQ_CPROCE), .F.)

        //Posiciona na MHP
        Self:PosMHP(AllTrim(MHQ->MHQ_ORIGEM), AllTrim(MHQ->MHQ_CPROCE))

        If Self:lSucesso
        
            If oBuscaObj:oRegistro == Nil
                oBuscaObj:oRegistro := JsonObject():New()
            EndIf
            oBuscaObj:oRegistro:FromJson(MHQ->MHQ_MSGORI)
            
            //Guarda o array todas as tags do layout de publicação
            aTags := oBuscaObj:oLayoutPub:GetNames()

            //Cria objeto que conterá a publicação
            If self:oPublica == Nil
                self:oPublica := JsonObject():New()
            EndIf            

            //Percorre tags do layout de publicação
            For nTag := 1 To Len(aTags)

                //Processa tags de um NÓ filho
                If aTags[nTag] $ "SL2|SL4"
                    
                    self:oPublica[ aTags[nTag] ] := {}

                    //Pega o nome das tags filhas
                    aTagsSec := oBuscaObj:oLayoutPub[ aTags[nTag] ][1]:GetNames()

                    //Pega o caminho para o No Filho
                    aNoFilho := {}
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

                                If "_FILIAL" $ AllTrim(aTagsSec[nTagSec])
                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := Self:RetFil("CHEF","SM0",oBuscaObj:oRegistro["Loja"]["Codigo"],.F.)
                                Else
                                    self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := oBuscaObj:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)
                                EndIf
                                
                                If !oBuscaObj:lSucesso
                                    Self:lSucesso := .F.
                                    Self:cErro := oBuscaObj:cRetorno
                                    LjGrvLog("RMIGRVPUBCHEFOBJ",Self:cErro)
                                    Exit
                                ElseIf !Self:lSucesso
                                    Exit
                                EndIf

                            Next nTagSec

                            If !oBuscaObj:lSucesso .OR. !Self:lSucesso
                                Exit
                            EndIf

                            If aTags[nTag] == "SL2" .and. !Empty(oBuscaObj:oRegistro["Itens"][nItem]["Tributo"] )

                                LjGrvLog("RMIGRVPUBCHEFOBJ", "Existe tributos a serem integrados")
                                
                                For nTagTri := 1 To 2

                                    Posicione('SA1',1,Xfilial("SA1") +  self:oPublica["L1_CLIENTE"] + self:oPublica["L1_LOJA"],'A1_COD' )

                                    If self:oPublica["L1_CLIENTE"] + self:oPublica["L1_LOJA"] == SA1->A1_COD + SA1->A1_LOJA

                                        LjGrvLog("RMIGRVPUBCHEFOBJ", "Encontrado cliente para inclusão nos campos de tributos a serem integrados", "Cliente: " + SA1->A1_COD + ", Loja: " + SA1->A1_LOJA)
                                    
                                        If RMIRetApur(SA1->A1_CGC)
                                            If nTagTri == 1 //primeiro laço imposto Pis                                                                                  
                                                aCmpsTri := {"L2_VALPS2", "L2_BASEPS2", "L2_ALIQPS2"}
                                                cTipoImp := "Pis"
                                            Else
                                                aCmpsTri := {"L2_VALCF2", "L2_BASECF2", "L2_ALIQCF2"}
                                                cTipoImp := "Cofins"
                                            EndIF
                                            
                                            LjGrvLog("RMIGRVPUBCHEFOBJ", "Cliente configurado para apuração de impostos",cTipoImp)
                                        Else //Cliente configurado para retenção de impostos
                                            If nTagTri == 1  //primeiro laço imposto Pis                                           
                                                aCmpsTri := {"L2_VALPIS", "L2_BASEPIS", "L2_ALIQPIS" }
                                                cTipoImp := "Pis"
                                            Else
                                                aCmpsTri := {"L2_VALCOFI", "L2_BASECOF", "L2_ALIQCOF"}
                                                cTipoImp := "Cofins"
                                            EndIf

                                            LjGrvLog("RMIGRVPUBCHEFOBJ", "Cliente configurado para retenção de impostos",cTipoImp)
                                        Endif

                                        If Len(aCmpsTri) > 0 
                                            Aadd(aTagsSec, aCmpsTri[1])
                                            nTagSec := Len(aTagsSec)
                                            nValTrib := oBuscaObj:AuxTrataTag(aTagsSec[nTagSec], oBuscaObj:oRegistro["Itens"][nItem][cTipoImp]["Valor"], nItem)

                                            lValTrib := (nValTrib > 0)
                                            If lValTrib
                                                self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := nValTrib
                                            Else
                                                self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := 0
                                            EndIf

                                            Aadd(aTagsSec, aCmpsTri[2])
                                            nTagSec := Len(aTagsSec)
                                            nL2BasC := oBuscaObj:AuxTrataTag(aTagsSec[nTagSec], oBuscaObj:oRegistro["Itens"][nItem][cTipoImp]["BaseCalculo"] , nItem)
                                            
                                            //Retirado validação de valor para gravação de valor base de calculo
                                            self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := nL2BasC
                                            
                                                                                
                                            Aadd(aTagsSec, aCmpsTri[3])
                                            nTagSec := Len(aTagsSec)
                                            nL2Perc := oBuscaObj:AuxTrataTag(aTagsSec[nTagSec], oBuscaObj:oRegistro["Itens"][nItem][cTipoImp]["Aliquota"] , nItem)

                                            //Retirado validação de valor para gravação de percentual de aliquota                                          
                                            self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := nL2Perc                                            
                                            
                                        EndIf
                                    Else
                                        LjGrvLog("RMIGRVPUBCHEFOBJ", "Não foi encontrado cliente com as informações do layout", "Cliente: " + self:oPublica["L1_CLIENTE"] + ", Loja: " + self:oPublica["L1_LOJA"])
                                    EndiF
                                Next nTagTri
                            Else
                                LjGrvLog("RMIGRVPUBCHEFOBJ", "Não existe tributos a serem integrados")
                            EndIF

                        Next nItem

                    Else

                        //Insere uma forma de pagamento, porque quando é cancelamento as vezes não vem pagamento
                        If ValType(aNoFilho) == "U" .And. AllTrim( Upper( aTags[nTag] ) ) == "SL4"

                            //Cancelamento
                            If oBuscaObj:oRegistro["StatusVenda"] == 3
                                Aadd(self:oPublica[ "SL4" ], JsonObject():New())

                                self:oPublica["SL4"][1]["L4_DATA"  ] := self:oPublica["L1_EMISSAO"]
                                self:oPublica["SL4"][1]["L4_FORMA" ] := "R$"
                                self:oPublica["SL4"][1]["L4_VALOR" ] := self:oPublica["L1_VLRTOT"]
                                self:oPublica["SL4"][1]["L4_FILIAL"] := self:oPublica["L1_FILIAL"]
                            Else
                                LjGrvLog("RMIGRVPUBCHEFOBJ", "Não há pagamento (SL4) associada a essa venda")
                            EndIf
                        EndIf
                    EndIf

                //Processa tags principais
                Else                    

                    If MHQ->MHQ_EVENTO == '3'
                
                        self:oPublica["LX_FILIAL" ]   := Self:RetFil("CHEF","SM0",oBuscaObj:oRegistro["CodigoLoja"],.F.) 
                        self:oPublica["L1_DOC"    ]   := cValtoChar(oBuscaObj:oRegistro["NumeroNotaIni"] )
                        self:oPublica["L1_SERIE"  ]   := oBuscaObj:oRegistro["SerieNota"]                        
                        self:oPublica["L1_OPERADO"]   := oBuscaObj:DePara('SA6',cValToChar(oBuscaObj:oRegistro['NumeroCaixa']), 2,0, .F., 'CHEF')
                        self:oPublica["L1_SITUA"  ]   := "IP"                        
                        self:oPublica["LX_DTINUTI"]   := StrTran(Substr(oBuscaObj:oRegistro["DataCriacao"],1,10), "-", "" )                        
                        self:oPublica["LX_PRINUT" ]   := oBuscaObj:oRegistro["NumeroRecibo"]
                        self:oPublica["LX_CHVNFCE"]   := oBuscaObj:oRegistro["ChaveSefaz"] 
                        self:oPublica["LX_MOTIVO" ]   := oBuscaObj:oRegistro["Motivo"] 
                        self:oPublica["LX_RETSFZ" ]   := "102"
                        
                        cSerie := GetAdvFVal("SLG","LG_PDV", self:oPublica["LX_FILIAL"] + self:oPublica["L1_SERIE"] ,2,"ERRO") 
                        If cSerie <> "ERRO"
                            self:oPublica["L1_PDV"]   := cSerie
                        Else
                            LjGrvLog("RMIGRVPUBCHEFOBJ","Não foi encontrado estação cadastrada para essa serie: " + oBuscaObj:oRegistro["SerieNota"] )
                        EndIf

                        self:oPublica["SL2"] := {}
                        self:oPublica["SL4"] := {}

                        Exit
                    EndIf

                    If "_FILIAL" $ AllTrim(aTags[nTag])
                        self:oPublica[ aTags[nTag] ] := Self:RetFil("CHEF","SM0",oBuscaObj:oRegistro["Loja"]["Codigo"],.F.)                
                    Else            
                        self:oPublica[ aTags[nTag] ] := oBuscaObj:AuxTrataTag( aTags[nTag], oBuscaObj:oLayoutPub[ aTags[nTag] ] )
                    EndIf

                    If !oBuscaObj:lSucesso
                        Self:lSucesso := .F.
                        Self:cErro := oBuscaObj:cRetorno
                        LjGrvLog("RMIGRVPUBCHEFOBJ", Self:cErro)
                    EndIf                
                Endif

                If !Self:lSucesso
                    Exit
                EndIf

            Next nTag
        Else
            LjGrvLog("RMIGRVPUBCHEFOBJ","Sem sucesso na verificação dentro do objeto")
        EndIf

        //Grava informação no campo MHQ_MENSAGE
        self:Gravar()

        //Limpa os objetos
        FwFreeObj(oBuscaObj)
        FwFreeObj(xNoFilho)
        FwFreeObj(self:oPublica)
        oBuscaObj     := Nil
        xNoFilho      := Nil
        self:oPublica := Nil

        If ValType(aNoFilho) == "A"
            Asize(aNoFilho, 0)
        EndIf
        Asize(aTagsSec, 0)

        (self:cAliasQuery)->( DbSkip() )
    EndDo
EndIf

(self:cAliasQuery)->( DbCloseArea() )

Return Nil
