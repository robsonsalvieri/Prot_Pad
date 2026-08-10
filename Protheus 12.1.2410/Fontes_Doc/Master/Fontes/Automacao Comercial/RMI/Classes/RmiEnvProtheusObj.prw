#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIENVPROTHEUSOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvProtheusObj
Classe que processa as distribuições do Protheus
/*/
//-------------------------------------------------------------------
Class RmiEnvProtheusObj From RmiEnviaObj

    Data aExecAuto  As Array                    //Array com o conteudo utilizado na manipulação de dados MsExecAuto

    Method New()                                //Metodo construtor da Classe

    Method PreExecucao()                        //Metodo com as regras para efetuar conexão com o sistema de destino

    Method CarregaBody()                        //Metodo que carrega o corpo da mensagem que será enviada

    Method Envia()                              //Metodo responsavel por enviar a mensagens ao sistema de destino

    Method NotaEntrada()                        //Metodo com tratamentos especificos para geração da nota de entrada

    Method Pedido()                             //Metodo com tratamentos especificos para geração do Pedido

    Method grava()                              //Metodo que ira efetuar as gravações\atualizações MHR, MHL, MIP e MHM

    //Metodos auxiliares para tratamento interno da classe
    Method AuxExecAuto(bMsExecAuto, cChave)     //Metodo para efetuar a execução da MsExecAuto, dependendo os parâmetros passados
    
    Method GravaReserva()                       //Metodo para efetuar a reserva especifico para o processo Pedido 
    Method ConfirmaPagto()                      //Metodo para efetuar a confirmação de pagamento no Pedido 
    Method CancReserva()                        //Metodo para efetuar a cancelamento da reserva

    Method consolidado()                        //Metodo responsável pelas validação do processo CONSOLIDADO

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvProtheusObj
    
    _Super:New("PROTHEUS",cProcesso)

    self:aExecAuto := {}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvProtheusObj
    //Como ja estamos no protheus não temos que efetuar nenhum procedimento
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaBody
Metodo que carrega a propriedade self:aExecAuto com os dados que serão atualizado na base do Protheus

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method CarregaBody() Class RmiEnvProtheusObj

    Local aTags      := {}
    Local nTag       := 0
    Local aTagsSec   := {}
    Local nTagSec    := 0
    Local nTabelaSec := 0
    Local nItem      := 0   
    Local aItem      := {}
    Local xConteudo  := ""
    Local cSetFil    := ''

    //Inicializa o array que ira conter os dados de gravação
    Asize(self:aExecAuto, 0)
    Aadd( self:aExecAuto, {})

    If self:oPublica:hasProperty("configPSH")
        self:oPublica:DelName("configPSH")
    EndIf

    //Retorno o nome das tags do objeto publica
    aTags := self:oPublica:GetNames()
    If UPPER(Alltrim(self:cProcesso)) == "INVENTARIO" 
        Aadd(self:aSecundaria, "SB7")  //Para Ajustar a tabela cabeçalho e item de uma mesma tabela Modelo 2 
    EndIf
    
    For nTag := 1 To Len(aTags)

        //Carrega as tabelas secundarias do processo
        If Ascan(self:aSecundaria, aTags[nTag]) > 0

            //Verifica se veio algum item
            If self:oPublica[ aTags[nTag] ] == Nil .Or. Len( self:oPublica[ aTags[nTag] ] ) == 0
                Aadd(self:aExecAuto, {})
            Else

                //Para cada tabela secundaria será criado um novo item no aExecAuto
                Aadd(self:aExecAuto, {})
                nTabelaSec := Len(self:aExecAuto)

                For nItem:=1 To Len(self:oPublica[ aTags[nTag] ])

                    //Pega o nome das tags da tabela secundaria, carrega por item porque cada item pode ter tags diferentes
                    aTagsSec := self:oPublica[ aTags[nTag] ][nItem]:GetNames()

                    //Carrega campos
                    For nTagSec:=1 To Len(aTagsSec)

                        xConteudo := self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ]

                        If GetSX3Cache(aTagsSec[nTagSec], "X3_TIPO") == "D"
                            xConteudo := StoD(xConteudo)
                        EndIf
                        //Quando o xConteudo == NIL gera erro.log ERROR: Tipos permitidos: STRING, DATE, NUMERIC, LOGICAL
                        If xConteudo == NIL //Tratamento para não adicionar Nil ao conteudo do campo.
                            If GetSX3Cache(aTagsSec[nTagSec], "X3_TIPO") == "N"
                                xConteudo := 0
                            EndIf
                            If GetSX3Cache(aTagsSec[nTagSec], "X3_TIPO") == "C"
                                xConteudo := ""
                            EndIf    
                        EndIf 
                        Aadd(aItem, {aTagsSec[nTagSec], xConteudo, Nil} )
                    Next nTagSec

                    //Carrega item
                    Aadd(self:aExecAuto[nTabelaSec], aClone(aItem) )
                    aSize(aItem, 0)

                Next nItem

            EndIf

        //Carrega tabela principal do processo
        Else

            xConteudo := self:oPublica[ aTags[nTag] ]

            if '_FILIAL' $ alltrim(aTags[nTag])
                cSetFil := self:oPublica[ aTags[nTag] ]
            endIf
            
            If GetSX3Cache(aTags[nTag], "X3_TIPO") == "D"
                xConteudo := StoD(xConteudo)
            EndIf

            Aadd(self:aExecAuto[1], {aTags[nTag], xConteudo, Nil} )
        EndIf

    Next nTag
    
    //Se encontrar a tag FILIAL publicada, utiliza ela para atualizar cFilAnt
    //Esta tag sempre tem a filial completa ex: D MG 01
    if ( nTag := aScan(aTags, allTrim("FILIAL")) ) > 0
        cSetFil := self:oPublica[ aTags[nTag] ]
        if len(self:aExecAuto) > 0
            //Removo o elemento "FILIAL" para não gerar erro no execauto
            if ( nTag := aScan(self:aExecAuto[1], {|x| x[1] == "FILIAL"}) ) > 0
                aDel(self:aExecAuto[1]  , nTag)
                aSize(self:aExecAuto[1] , Len(self:aExecAuto[1]) - 1)
            endIf
        endIf
    endIf
    
    //Atualiza cFilAnt
    If !Empty(cSetFil)
        RmiFilInt(cSetFil,  .T.)
    EndIf

    //Atualiza o body para ser gravado no distribuição MHR_ENVIO
    self:cBody := VarInfo("self:aExecAuto", self:aExecAuto, Nil, .F., .F.)

    Asize(aTags   , 0)
    Asize(aTagsSec, 0)
    aSize(aItem   , 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Grava as informações recebidas na distribuição no protheus

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvProtheusObj

    Local aAux          := {}
    Local nPos,nL1Num   := 0
    Local cEvento       := ""
    Local cProcesso     := AllTrim(self:cProcesso)
    Local bErrorBlock   := Nil
    Local lErrorBlock   := .F.
    Local cErrorBlock   := ""
    Local nOpc          := 3
    Local nX            := 0
    
    LjGrvLog("RMIENVPROTHEUSOBJ", "Envia() - Iniciada gravação do processo " + cProcesso + " no Protheus")

    //Condição que pode dar erro
    bErrorBlock := ErrorBlock( {|oErro| RmiErroBlock(oErro, @lErrorBlock, @cErrorBlock)} )
    Begin Sequence
        
        Do Case 

            Case cProcesso == "VENDA"
                
                If MHQ->(ColumnPos("MHQ_UUID")) > 0
                    Aadd(self:aExecAuto[1],{"L1_UMOV",MHQ->MHQ_UUID,NIL})//Adiciona o Rastreio UUID na venda.
                Else
                    LjGrvLog("RMIENVPROTHEUSOBJ","Campo MHQ_UUID não consta na base. Efetue o seu cadastro via SIGACFG ou aplicação de UPDDSTR")
                EndIf

                //Se origem for uma pre-venda importada do protheus, Reutilizar o Orçamento.
                nL1Num  := Ascan(self:aExecAuto[1], {|x| x[1] == "L1_NUM"})
                If nL1Num > 0
                    cNumOrc := Padr(self:aExecAuto[1][nL1Num][2],TamSX3("L1_NUM")[1])
                    If !Empty(cNumOrc)
                        
                        LjGrvLog("RMIENVPROTHEUSOBJ","Pre Venda, verificando se o orçamento da pre-venda existe no protheus")
                        SL1->(dbSetOrder(1))
                        
                        If SL1->(dbSeek(xFilial("SL1")+cNumOrc )) .AND. Empty(SL1->L1_DOC)
                            nOpc := 4 //Alteração
                            
                            For nX := 1 To Len(self:aExecAuto[2]) 
                                Aadd(self:aExecAuto[2][nX], {"L2_NUM", cNumOrc  , Nil} ) //Adicionado Chave e posicionar no registro.
                            next    
                            
                            For nX := 1 To Len(self:aExecAuto[3]) 
                                Aadd(self:aExecAuto[3][nX], {"L4_NUM", cNumOrc , Nil} )
                            next 
                            
                            
                            SL2->(dbSetOrder(1))
                            SL2->(dbSeek(xFilial("SL2")+cNumOrc ))
                            
                            SL4->(dbSetOrder(1))
                            SL4->(dbSeek(xFilial("SL4")+cNumOrc ))
                        Else
                            LjGrvLog("RMIENVPROTHEUSOBJ","O Orçamento numero: ("+cNumOrc+"): - Pre-Venda, para venda: "+ IIF(Empty(SL1->L1_DOC),"  nao encontrado venda será gravada como venda normal sem orçamento-prevenda",;
                            " Foi utilizado na venda de nota: "+SL1->L1_DOC+" então será criado um novo orçamento para finalizar a venda."))
                            ADel(self:aExecAuto[1],nL1Num)//Ajusta o array para retirar o L1_NUM em caso de inclusão. 
                            ASize(self:aExecAuto[1],Len(self:aExecAuto[1])-1)
                        EndIf
                    
                    Else
                        ADel(self:aExecAuto[1],nL1Num) 
                        ASize(self:aExecAuto[1],Len(self:aExecAuto[1])-1)
                    EndIf
                EndIf
              
                //Tratamento de Venda\Cancelamento para processamento do RmiRetailJob
                nPos := Ascan(self:aExecAuto[1], {|x| x[1] == "L1_SITUA"})
                cEvento := IIF(self:cEvento == "1", "IP", "IC") //1=Upsert, 2=Delete, 3=Inutilizacao

                If nPos > 0
                    self:aExecAuto[1][nPos][2] := cEvento                 
                Else
                    Aadd(self:aExecAuto[1], {"L1_SITUA", cEvento , Nil} )
                EndIf
                //Para evitar que seja criado SL1 Duplicada.
                If self:cEvento == "1" //Nao validar para cancelamento e Inutilização.
                    aAux := RmiVldVend(MHQ->MHQ_UUID,self:aExecAuto[1])//Valida se a venda já existe na SL1.    
                else
                    aAux := {.T.,""} //Nao validar para cancelamento e Inutilização.
                EndIf    
                
                If aAux[1] //Retorna .F. para Valida se a venda já existe na SL1.
                    //Chama gravação de venda\cancelamento  e inutilização utilizada pelo RMI
                    aAux := RsGrvVenda(self:aExecAuto[1], IIF(Len(self:aExecAuto) >= 2,self:aExecAuto[2],{}), IIF(Len(self:aExecAuto) >= 3,self:aExecAuto[3],{}), nOpc)

                    If aAux[1]

                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica
                        self:cChaveUnica    := SL1->L1_FILIAL + "|" + SL1->L1_NUM
                        self:cRetorno       := I18n(STR0001, {self:cChaveUnica})    //"Venda gerada #1"
                    Else

                        self:lSucesso := .F.
                        self:cRetorno := aAux[2]
                    EndIf
                Else
                    self:lSucesso := .F.
                    self:cRetorno := aAux[2]
                EndIf
            Case cProcesso == "CLIENTE"

                //Dentro da funcao RmiGrvCli chama o ExecAuto do MATA030
                aAux := RmiGrvCli(self:aExecAuto, self:cOrigem)

                If aAux[1]
                    LjGrvLog("RMIENVPROTHEUSOBJ", "Cliente gravado com sucesso na base do Protheus (SA1)",SA1->A1_FILIAL + "|" + SA1->A1_COD+"|" + SA1->A1_LOJA)
                    self:lSucesso       := .T.
                    self:cChaveExterna  := self:cChaveUnica
                    self:cChaveUnica    := SA1->A1_FILIAL + "|" + SA1->A1_COD +"|" + SA1->A1_LOJA
                    self:cRetorno       := I18n(STR0003, {aAux[1]})    //"Cliente gerado #1"
                Else
                    self:lSucesso       := .F.
                    self:cRetorno       := aAux[2]
                    LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar o cliente na base do Protheus (SA1)",self:cRetorno)
                EndIf

            Case cProcesso == "OPERADOR CAIXA"
                
                aAux := RmiGrvOpe(self:aExecAuto, self:cOrigem)

                If ValType(aAux) == 'A' .AND. Len(aAux) > 1
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica
                        self:cChaveUnica    := SA6->A6_FILIAL + "|" + SA6->A6_COD
                        self:cRetorno       := I18n("", {aAux[1]})
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Operador de caixa gravado com sucesso na base do Protheus (SA6)",SA6->A6_FILIAL + "|" + SA6->A6_COD)
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar o operador de caixa na base do Protheus (SA6)",self:cRetorno)
                    EndIf
                EndIf
            
            Case cProcesso == "INVENTARIO"
                
                aAux := RmiGrvInv(self:aExecAuto, self:cOrigem)

                If ValType(aAux) == 'A' .AND. Len(aAux) > 1
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica //B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL                                                                                                                                
                        self:cChaveUnica    := SB7->B7_FILIAL+"|"+SB7->B7_DOC+"|"+SB7->B7_COD+"|"+SB7->B7_LOCAL
                        self:cRetorno       := I18n(STR0004, {aAux[1]})    //"Operador gerado #1"
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Inventario gravado com sucesso na base do Protheus (SB7)",SB7->B7_FILIAL+"|"+SB7->B7_DOC+"|"+SB7->B7_COD+"|"+SB7->B7_LOCAL)
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar o Inventario na base do Protheus (SB7)",self:cRetorno)
                    EndIf
                EndIf    
            
            Case cProcesso == "ADMINISTRADORA"
                
                aAux := RmiGrvAdm(self:aExecAuto, self:cChaveUnica)

                If ValType(aAux) == 'A' .AND. Len(aAux) > 1            
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica 
                        self:cChaveUnica    := SAE->AE_FILIAL +"|"+SAE->AE_COD
                        self:cRetorno       := I18n(STR0005, {SAE->AE_FILIAL +"|"+SAE->AE_COD})    //"Adm Financeira gerada #1"
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Adm Financeira gravada com sucesso na base do Protheus (SAE)",SAE->AE_FILIAL +"|"+SAE->AE_COD)
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar a Adm Financeira na base do Protheus (SAE)",self:cRetorno)
                    EndIf
                EndIf

            Case cProcesso $ "SANGRIA|SUPRIMENTO"
                
                aAux := GrvCXSan(self:aExecAuto)
                
                If ValType(aAux) == 'A' .AND. Len(aAux) > 1            
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica 
                        self:cChaveUnica    := SE5->E5_FILIAL+"|"+dTos(SE5->E5_DATA)+"|"+SE5->E5_BANCO+"|"+SE5->E5_AGENCIA+"|"+SE5->E5_CONTA+"|"+SE5->E5_IDMOVI
                        self:cRetorno       := I18n( STR0006, { AllTrim(self:cProcesso), self:cChaveUnica } )    //"#1 gerado(a): #2"
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                    EndIf

                    LjGrvLog("RMIENVPROTHEUSOBJ", "Retorno do processamento do(a) " + cProcesso, self:cRetorno)
                EndIf

            Case cProcesso == "NOTA DE ENTRADA"
            
                //Verificar se já integrou esta nota de entrada
                MHM->( DbSetOrder(4) )  //MHM_FILIAL + MHM_SISORI + MHM_TABELA + MHM_VLORIG
                if MHM->( DbSeek( xFilial("MHM") + padR(MHQ->MHQ_ORIGEM, tamSx3("MHM_SISORI")[1]) + padR("SF1", tamSx3("MHM_TABELA")[1]) + padR(MHQ->MHQ_CHVUNI, tamSx3("MHM_VLORIG")[1]) ) )
                    self:lSucesso   := .F.
                    self:cRetorno   := i18n(STR0019, {alltrim(MHQ->MHQ_CHVUNI), alltrim(MHM->MHM_VLINT)} )  //"Para essa chave única (#1) já foi encontrado o de\para de nota de entrada na tabela MHM. A nota gerada foi (#2). Este registro será atualizado para repetido, para não ser processado."
                    self:lEnvDuplic := .T.
                else
                    Begin Transaction
                        self:NotaEntrada()
                    End Transaction
                endif
            
            Case cProcesso == "PEDIDO"                            
            
                self:Pedido()

            Case cProcesso == "CONFIRMA PAGTO"

                Begin Transaction
                    If self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_PAGAMENTO"})][2]
                        self:ConfirmaPagto()   
                    else
                        self:CancReserva()            
                    endIf
                End Transaction

            Case cProcesso == "CONSOLIDADO"

                Begin Transaction
                    self:consolidado()
                End Transaction

            OTherWise
                self:lSucesso := .F.
                self:cRetorno := I18n(STR0002, {cProcesso, self:cAssinante})   //"Envio de #1 não implmentado para o assinante #2"
        End Case

        //Caso tenha algum erro capturado pelo ErrorBlock força a saida para o Recover
        If lErrorBlock
            Break
        EndIf

    //Se ocorreu erro
    Recover
        
        self:lSucesso := .F.
        self:cRetorno := I18n(STR0007, {cProcesso}) + CRLF + cErrorBlock    //"Não foi possível efetuar a gravação do processo #1 no Protheus."

    End Sequence
    ErrorBlock(bErrorBlock)

    Asize(aAux, 0)

    LjGrvLog("RMIENVPROTHEUSOBJ", "Envia() - Finalizada gravação do processo " + cProcesso + " no Protheus - Retorno: " + self:cRetorno)

    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxExecAuto
Metodo auxiliar para executar rotinas automaticas

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method AuxExecAuto(bMsExecAuto, cChave)  Class RmiEnvProtheusObj

    Local aErro := {}
    Local cErro := ""
    Local nCont := 0
    Local aArea := GetArea()

	Private lMsHelpAuto     := .T.
	Private lMsErroAuto		:= .F.
    Private lAutoErrNoFile  := .T.  //Define que retorna o erro do MsExecAuto para o array

    //Executa a MsExecAuto
    Eval(bMsExecAuto)

    If lMsErroAuto
        aErro := GetAutoGrLog()

        For nCont := 1 To Len(aErro)
            cErro += AllTrim( aErro[nCont] ) + CRLF
        Next nCont

        self:lSucesso       := .F.
        self:cTipoRet       := "ENVIA"
        self:cRetorno       := cErro
    Else

        self:lSucesso       := .T.
        self:cTipoRet       := ""
        self:cChaveExterna  := self:cChaveUnica
        self:cChaveUnica    := &( cChave )
        self:cRetorno       := I18n( STR0006, { AllTrim(self:cProcesso), self:cChaveUnica } )    //"#1 gerado(a): #2"
    EndIf

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NotaEntrada
Metodo com tratamentos especificos para geração da nota de entrada

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method NotaEntrada()  Class RmiEnvProtheusObj

    Local aArea    := GetArea()
    Local aAreaSFT := SFT->( GetArea() )
    Local aAreaSF3 := SF3->( GetArea() )
    Local nPos     := Ascan( self:aExecAuto[1], {|x| x[1] == "F1_CHVNFE"} )
    Local cCodRSef := ""

    If nPos > 0 
        cChaveNFE := self:aExecAuto[1][nPos][2]

        If !Empty(cChaveNFE)
            cCodRSef := "100"   //Para gravar o campo F3_CODRET, retorno da SEFAZ 100|Autorizado o uso da NF-e
        EndIf
    EndIf

    //MATA103(xAutoCab,xAutoItens,nOpcAuto,lWhenGet,xAutoImp,xAutoAFN,xParamAuto,xRateioCC,lGravaAuto,xCodRSef,xCodRet,xAposEsp,xNatRend,xAutoPFS)
    bMsExecAuto := { || MsExecAuto( {|x,y,z| MATA103(x,y,z) }, self:aExecAuto[1], self:aExecAuto[2], 3,,,,,,, cCodRSef) } 
    cChave      := "SF1->F1_FILIAL + '|' + SF1->F1_DOC + '|' + SF1->F1_SERIE"
    
    //Chama metodo auxiliar para executar rotinas automaticas
    self:AuxExecAuto(bMsExecAuto, cChave)

    if self:lSucesso
        //Grava de\para MHM
        rmiDePaGrv(MHQ->MHQ_ORIGEM, "SF1", "F1_DOC", MHQ->MHQ_CHVUNI, self:cChaveUnica, .T., MHQ->MHQ_UUID)
    endIf

    If self:lSucesso .And. !Empty(cChaveNFE)

        LjGrvLog("RmiEnvProtheusObj", "Ajustando SF1 para o SPED adicionando chave.", {"NotaEntrada", cChaveNFE})

        RecLock('SF1', .F.)
            SF1->F1_CHVNFE := cChaveNFE         
        SF1->( MsUnlock() )
        
        SF3->( DbSetOrder(6) )  //F3_FILIAL, F3_NFISCAL, F3_SERIE
        If SF3->( DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE) )

            LjGrvLog("RmiEnvProtheusObj", "Ajustando SF3 para o SPED adicionando chave", {"NotaEntrada", cChaveNFE})

            RecLock('SF3', .F.)
                SF3->F3_CHVNFE := cChaveNFE
                SF3->F3_CODRET = 'M'         
            SF1->( MsUnlock() )
            
            SFT->( DbSetOrder(6) )
            SFT->( DbSeek(SF3->F3_FILIAL + 'E' + SF3->F3_NFISCAL + SF3->F3_SERIE) )   //FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE    
            While !SFT->( Eof() )                    .And. SFT->FT_FILIAL == SF3->F3_FILIAL .And. SFT->FT_TIPOMOV == "E" .And.;
                  SFT->FT_NFISCAL == SF3->F3_NFISCAL .And. SFT->FT_SERIE == SF3->F3_SERIE

                LjGrvLog("RmiEnvProtheusObj", "Ajustando SFT para o SPED adicionando chave", {"NotaEntrada", cChaveNFE})

                RecLock('SFT', .F.)
                    SFT->FT_CHVNFE := cChaveNFE         
                SFT->( MsUnlock() )
                
                SFT->( DbSkip() )
            EndDo
        Else

            self:lSucesso := .F.
            self:cTipoRet := "ENVIA"
            self:cRetorno := "Não foi encontrado registro no Livro verificar RmiEnvProtheusObj Ajuste temporario"
            LjGrvLog("RmiEnvProtheusObj", self:cRetorno, {"NotaEntrada", cChaveNFE})
        EndIf
    EndIf

    RestArea(aAreaSF3)
    RestArea(aAreaSFT)
    RestArea(aArea) 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Pedido
Metodo com tratamentos especificos para geração do Pedido

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Pedido() Class RmiEnvProtheusObj

    Local aArea     := GetArea()
    Local aAux      := {}
    Local nPos      := 0
    Local cEvento   := ""
    Local oJson     := Nil

    Aadd(self:aExecAuto[1],{"L1_UMOV",MHQ->MHQ_UUID,NIL})//Adiciona o Rastreio UUID na venda.
    
    //Tratamento de Venda\Cancelamento para processamento do RmiRetailJob
    nPos := Ascan(self:aExecAuto[1], {|x| x[1] == "L1_SITUA"})
    cEvento := IIF(self:cEvento == "1", "PP", "IC") //1=Upsert, 2=Delete, PP = Pagamento Pendente
    If nPos > 0
        self:aExecAuto[1][nPos][2] := cEvento                 
    Else
        Aadd(self:aExecAuto[1], {"L1_SITUA", cEvento , Nil} )
    EndIf
    
    Begin Transaction
        
        If self:cEvento == "1" 
            aAux := self:GravaReserva()//Grava a reserva para geração da venda
        else
            aAux := {.T.,""} //Função não implementada para cancelamento da reserva
        EndIf    
        
        If aAux[1] 

            //Incluo o cliente no execauto para chamada da gravação
            self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_CLIENTE"})][2]  := aAux[3][2]
            self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_LOJA"})][2]     := aAux[3][3]
            
            // Faz o calculo reverso de IPI antes de gravar a venda
            LjTaxEAI(@self:aExecAuto[1], @self:aExecAuto[2], .F.)

            //Chama gravação de pedido\cancelamento utilizada pelo RMI
            aAux := RsGrvVenda(self:aExecAuto[1], self:aExecAuto[2], IIF(Len(self:aExecAuto) >= 3,self:aExecAuto[3],{}), 3)

            If aAux[1] .AND. self:lSucesso
                self:lSucesso       := .T.
                self:cChaveExterna  := self:cChaveUnica
                self:cChaveUnica    := SL1->L1_FILIAL + "|" + SL1->L1_NUM
                self:cRetorno       := I18n(STR0001, {self:cChaveUnica})    //"Venda gerada #1"
            EndIf
        EndIf

        If !aAux[1]
            DisarmTransaction()
            self:lSucesso := .F.
            self:cRetorno := aAux[2]
        EndIf

        //Publica Status do Pedido
        If ExistFunc("RmiExeGat")
            oJson := JsonObject():New()

            oJson["filial"]       := xFilial("SL1")
            oJson["pedidoOrigem"] := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_ECPEDEC"})][2]
            oJson["status"]       := IIF(self:lSucesso, "reserved", "error")
            oJson["detalhe"]      := JsonObject():New()

            oJson["detalhe"]["mensagem"] := self:cRetorno
        
            RmiExeGat("STATUSPEDIDO", "2", {oJson})

            FwFreeObj(oJson)
        EndIf

    End Transaction

    RestArea(aArea) 

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} GeraReser
Quando estiver processando um pedido, entao prepara os dados
para chamar a rotina de reserva.

@author Bruno Almeida
@since  22/03/2022
@return { .T. }
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Method GravaReserva()  Class RmiEnvProtheusObj

Local nX            := 0    //Variavel de loop
Local aArea         := GetArea() //Guarda area
Local aCliente      := {} //Recebe o retorno do cadastro de cliente
Local aCabReser     := {} //Recebe campos do cabeçalho da reserva
Local aGridReser    := {} //Recebe campos dos itens da reserva
Local aRet          := {.F.,"",{}}   //Variavel de retorno
Local cResRet       := "" //Recebe o retorno da reserva
Local cReserv       := "" //Codigo da reserva
Local cErro         := "" //Monta mensagem de erro para ser apresentado na reserva de produto
Local nL2FilRes     := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_FILRES"})
Local nL2Prod       := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_PRODUTO"})
Local nL2Local      := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_LOCAL"})
Local nL2Quant      := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_QUANT"})

Local oJson     := JsonObject():New() //Recebe o Json de origem

oJson:FromJson(MHQ->MHQ_MSGORI)

Private nOpcx := 1 //Essa variavel foi declarada como private pois é utilizada dentro do LJGeraSC0 (LOJA701E)

    //Gerando o cadastro de cliente
    aCliente := RsGrvCli(MHQ->MHQ_MSGORI)

    If aCliente[1]        

        For nX := 1 To Len(self:aExecAuto[2])                        

            //Cabeçalho da reserva
            Aadd(aCabReser,{"C0_TIPO","LJ",NiL})
            Aadd(aCabReser,{"C0_DOCRES",MHQ->MHQ_CHVUNI,NiL})
            Aadd(aCabReser,{"C0_SOLICIT",MHQ->MHQ_ORIGEM,NiL})
            Aadd(aCabReser,{"C0_FILRES",self:aExecAuto[2][nX][nL2FilRes][2],NiL})

            //Itens da reserva
            Aadd(aGridReser,{})
            Aadd(aGridReser[1],{"C0_PRODUTO",Padr(self:aExecAuto[2][nX][nL2Prod][2],Tamsx3("B1_COD")[1]),NiL})
            Aadd(aGridReser[1],{"C0_LOCAL",self:aExecAuto[2][nX][nL2Local][2],NiL})
            Aadd(aGridReser[1],{"C0_QUANT",self:aExecAuto[2][nX][nL2Quant][2],NiL})
            Aadd(aGridReser[1],{"C0_VALIDA",dDataBase,NiL})
            Aadd(aGridReser[1],{"C0_EMISSAO",Date(),NiL})
            Aadd(aGridReser[1],{"C0_LOTECTL","",NiL})
            Aadd(aGridReser[1],{"C0_NUMLOTE","",NiL})
            Aadd(aGridReser[1],{"C0_NUMSERI","",NiL})
            Aadd(aGridReser[1],{"C0_LOCALIZ","",NiL})
            Aadd(aGridReser[1],{"C0_OBS","",NiL})
            Aadd(aGridReser[1],{"C0_FILIAL",xFilial("SC0"),NiL})

            cReserv := LOJA704(aCabReser, aGridReser, 1, @cResRet)

            aCabReser   := {}
            aGridReser  := {}

            If Empty(cReserv)
                cErro += STR0008 + " " + AllTrim(self:aExecAuto[2][nX][nL2Prod][2]) + STR0009 + " " + cResRet + " - " + STR0010 + " " + cValToChar(RsSaldoPrd(self:aExecAuto[2][nX][nL2Prod][2])) + CRLF //"Não foi possivel realizar a reserva para o produto" # ", motivo:" # "Saldo em Estoque:"
            else                                       
                Aadd(self:aExecAuto[2][nX], {"L2_RESERVA",cReserv,""})                    
            EndIf
            
        Next nX

    Else        
        cErro += aCliente[5] + CRLF
    EndIf


If !Empty(cErro)
    LjGrvLog("RmiEnvProtheusObj", cErro, "GravaReserva")
    aRet[1] := .F.
    aRet[2] := cErro
    aRet[3] := aCliente
else
    aRet[1] := .T.
    aRet[2] := cResRet
    aRet[3] := aCliente
EndIF

RestArea(aArea)

Return aRet
//--------------------------------------------------------
/*/{Protheus.doc} ConfirmaPagto
Confirma Pagamento na SL1 ou Cancela a Reserva.

@author Everson S P Junior
@since  22/03/2022
@return { .T. }

/*/
//--------------------------------------------------------
Method ConfirmaPagto()  Class RmiEnvProtheusObj
Local cNumPed_e := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_ECPEDEC"})][2]
Local cFilPed   := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_FILIAL"})][2] 
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias


cQuery := "SELECT R_E_C_N_O_ REC, L1_NUM "
cQuery += "  FROM " + RetSqlName("SL1")
cQuery += " WHERE L1_ECPEDEC = '" + cNumPed_e + "'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += "   AND L1_FILIAL = '" + cFilPed + "'"
cQuery += "   AND L1_SITUA = 'PP'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("Confirma Pagamento","[Atualiza Pedido de Venda para 'IP'] Query executada ->",(cAlias)->L1_NUM)
If !(cAlias)->( Eof() )
    SL1->(dbGoto((cAlias)->REC))
    RecLock("SL1",.F.)
    SL1->L1_SITUA := "IP"
    SL1->( MsUnLock() )
EndIf           

(cAlias)->( DbCloseArea() )
Return 
//--------------------------------------------------------
/*/{Protheus.doc} CancReserva
Cancela Reserva e Deleta os Registros da SL1,SL2,SL4

@author Bruno Almeida
@since  22/03/2022
@return { .T. }
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Method CancReserva()  Class RmiEnvProtheusObj
Local cNumPed_e := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_ECPEDEC"})][2]
Local cFilPed   := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_FILIAL"})][2] 
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local aReserva  := {}


cQuery := "SELECT R_E_C_N_O_ REC, L1_NUM "
cQuery += "  FROM " + RetSqlName("SL1")
cQuery += " WHERE L1_ECPEDEC = '" + cNumPed_e + "'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += "   AND L1_FILIAL = '" + cFilPed + "'"
cQuery += "   AND L1_SITUA = 'PP'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("Cancela Reserva ","[Atualiza Pedido de Venda] Cancelamento do Pedido e Reserva ->",(cAlias)->L1_NUM)

If !(cAlias)->( Eof() )
    SL1->(dbGoto((cAlias)->REC))
    LjGrvLog(" Cancelar Reserva ", "Cancelando a reserva e deletando SL1 SL2 SL4 " +;
                                AllTrim(SL1->L1_UMOV) + ". Excluindo a venda L1_FILIAL = " + AllTrim(SL1->L1_FILIAL) +;
                                " L1_NUM = " + AllTrim(SL1->L1_NUM)) 

    RecLock("SL1",.F.)    
    
    //Inicia a exclusao da SL2
    dbSelectArea("SL2")
    SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
    If SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
        While SL2->(!Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == SL1->L1_FILIAL + SL1->L1_NUM
            aReserva := { {SL2->L2_RESERVA ,SL2->L2_LOCAL , SL2->L2_PRODUTO , SL2->L2_LOCAL ,SL2->L2_FILIAL ,"" } }
            Lj7CancRes( aReserva , .T.) //Inicia a exclusao da reserva
            RecLock("SL2",.F.)
            SL2->( DbDelete() )
            SL2->( MsUnLock() )
            SL2->( DbSkip() )
        EndDo
    EndIf
    
    //Inicia a exclusao da SL4
    dbSelectArea("SL4")
    SL4->(dbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM
    If SL4->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
        While SL4->(!Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == SL1->L1_FILIAL + SL1->L1_NUM
            RecLock("SL4",.F.)
            SL4->( DbDelete() )
            SL4->( MsUnLock() )
            SL4->( DbSkip() )
        EndDo
    EndIf

    SL1->( DbDelete() )
    SL1->( MsUnLock() )       
    LjGrvLog(" RmiBuscaObj ", "Reprocessamento da publicação (MHQ_UUID) " + AllTrim(SL1->L1_UMOV) + ". Venda excluida com sucesso. L1_FILIAL = " + AllTrim(SL1->L1_FILIAL) + "L1_NUM = " + AllTrim(SL1->L1_NUM))  
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira efetuar as gravações\atualizações MHR, MHL, MIP e MHM

@type    metodo
@author  Rafael Tenorio da Costa
@since   16/01/24
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method grava() Class RmiEnvProtheusObj

    Local cChvUni := ""

    Begin Transaction

        _Super:grava()
            
        If self:lSucesso .and. self:lDetDistrib

            cChvUni := posicione("MHQ", 7, xFilial("MHQ") + MHR->MHR_UIDMHQ, "MHQ_CHVUNI")    //MHQ_FILIAL, MHQ_UUID, R_E_C_N_O_, D_E_L_E_T_

            rmiStDist(	IIF(ALLTRIM(self:cProcesso) != "VENDA","2","1")				,;  //cStatus se for Venda o status é 1
                        3				,;  //nIndex
                                        ,;  //cFil
                        cChvUni         ,;  //cChvUni
                        MHR->MHR_UIDMHQ ,;  //cUUID
                                        ,;  //dDtOrig
                                    	,;  //cDtOk
                        self:cProcesso  ,;  //cProcesso
                                        )   //cEvento
        EndIf

    End Transaction    

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} consolidado

Método responsável por comparar a lista consolidada (diária) de vendas retornadas do PDV com as vendas registradas nos Livros Fiscais do Protheus.
@type    metodo
@author  Samuel de Vincenzo
@since   25/06/24
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method consolidado() Class RmiEnvProtheusObj
    
    Local aArea         := getArea()
    Local aAreaMHQ      := MHQ->( getArea() )
    Local aAreaMHR      := MHR->( getArea() )
    Local aAreaMIP      := MIP->( getArea() )
    Local cStatus       := "1"                  //1=Pendente Consolidação; 2=Consolidado; 3=Falha na Consolidação
    Local cErro         := ""
    Local oConsolidado  := Nil
    Local cChavUni      := ""
    Local nCont         := 0
    Local cSql          := "SELECT R_E_C_N_O_ AS RECNOSF3 FROM " + retSqlName("SF3")
    Local cWhere        := ""
    Local aSql          := {}
    Local cBkpFilAnt    := cFilAnt
    Local cSituacao     := ""
    Local cVenda        := padR("VENDA", tamSX3("MIP_CPROCE")[1])
    Local cUuid         := MHQ->MHQ_UUID
    Local nPos          := aScan(self:aExecAuto[1], {|x| x[1] == "data"})

    if nPos == 0

        self:lSucesso := .F.
        self:cRetorno := I18n(STR0018, {"data", self:cProcesso, self:cAssinante})   //"Não foi encontrada a TAG #1 dentro do layout de publicação do processo #2, verifiquei o cadastros do assinante #3."
    else

        oConsolidado := JsonObject():new()
        oConsolidado:fromJson(self:aExecAuto[1][nPos][2])
        
        for nCont := 1 to Len(oConsolidado)

            cFilAnt := oConsolidado[nCont]["IdRetaguardaLoja"]

            //Carrega chave única da venda
            cChavUni := oConsolidado[nCont]["IdRetaguardaLoja"] + "|"+oConsolidado[nCont]["ccf"] + "|" + cValToChar(oConsolidado[nCont]["SerieNota"]) + "|"

            MIP->( dbSetOrder(1) )      //MIP_FILIAL, MIP_CPROCE, MIP_CHVUNI, MIP_PDV, R_E_C_N_O_, D_E_L_E_T_
            if !MIP->( dbSeek( xFilial("MIP") + cVenda + cChavUni ) )

                rmiStDist(   "3"        ,;  //cStatus
                                        ,;  //nIndex
                                        ,;  //cFil
                            cChavUni    ,;  //cChvUni
                                        ,;  //cUUID
                                        ,;  //dDtOrig
                                        ,;  //cDtOk
                            cVenda      ,;  //cProcesso
                            "1"         )   //cEvento
                cStatus := "3"
                cErro   := i18n(STR0011, {STR0012})   //"A venda não foi recebida pelo fluxo de integração, verifique no #1 a integridade dos dados e solicite o reenvio."    //"TOTVS Varejo Pdv Omni"
            else

                if MIP->MIP_STATUS $ "2|A"

                    //Valida livros fiscais
                    cWhere  := " WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND F3_CHVNFE = '" + oConsolidado[nCont]["ChaveAcesso"] + "'"
                    aSql    := RmiXSql(cSql+cWhere,"*", /*lCommit*/, /*aReplace*/)

                    if Len(aSql) > 0

                        SF3->( dbGoto(aSql[1][1]) )

                        /*
                        0 - Finalizada (Concluída)
                        1 - Cancelada
                        2 - Rejeitada (Rejeitada na SEFAZ)
                        3 - Inutilizada (Inutilizada na SEFAZ)
                        4 - Recebido (Pagamento realizado)
                        5 - Denegada
                        */
                        cSituacao := cValToChar(oConsolidado[nCont]['SituacaoVenda'])

                        do case 
                            case !empty(SF3->F3_DTCANC) .and. cSituacao $ "0|5"
                                cStatus := "3"
                                cErro   := i18n(STR0013, {STR0014, STR0015})  //"Situação da venda na retaguarda divergente do pdv. Retaguarda venda #1 - Pdv venda #2"   //"cancelada\inutilizada"   //"ativa"

                            case empty(SF3->F3_DTCANC) .and. cSituacao $ "1|3"
                                cStatus := "3"
                                cErro   := i18n(STR0013, {STR0015, STR0014})  //"Situação da venda na retaguarda divergente do pdv. Retaguarda venda #1 - Pdv venda #2"   //"ativa"   //"cancelada\inutilizada"

                            oTherWise
                                cStatus := "2"
                                cErro   := ""
                        end case
                    else

                        cStatus := "3"
                        cErro   := STR0016    //"A venda já terminou o processso de integração, porém não foi encontrada nos livros fiscais, contate o suporte para uma análise mais detalhada."
                    endIf

                elseIf MIP->MIP_STATUS <> "3"

                    cStatus := "3"
                    cErro   := STR0017    //"A consolidação foi executada, porém a venda não tinha finalizado o processo de integração. Aguarde alguns minutos para a venda terminar seu processamento, este status é temporário."
                endIf  
            endif

            //Atualização de dados
            if cStatus == "3"

                MIP->( dbSetOrder(1) )      //MIP_FILIAL, MIP_CPROCE, MIP_CHVUNI, MIP_PDV, R_E_C_N_O_, D_E_L_E_T_
                if MIP->( dbSeek( xFilial("MIP") + cVenda + cChavUni ) )

                    rmiGrvLog(  cStatus     , "MIP"             , MIP->( Recno() )  , "CONSOLI"         ,;
                                cErro       , /*lRegNew*/       , /*lTxt*/          , /*cFilStatus*/    ,;
                                .F.         , /*nIndice*/       , MIP->MIP_CHVUNI   , MIP->MIP_CPROCE   ,;
                                "PDVSYNC"   , MIP->MIP_UIDORI   , /*lIntegTPDV*/    ) 
                endIf
            endIf

            if MIP->( columnPos("MIP_UIDCON") ) > 0 .and. MIP->( columnPos("MIP_STCON") ) > 0 .and. MIP->( columnPos("MIP_VALCON") ) > 0
                recLock("MIP", .F.)
                    MIP->MIP_UIDCON := cUuid
                    MIP->MIP_STCON  := cStatus  //1=Pendente Consolidação; 2=Consolidado; 3=Falha na Consolidação
                    MIP->MIP_VALCON := oConsolidado[nCont]["ValorBruto"]
                MIP->( msUnLock() )
            endIf

        next nCont
    endIf

    cFilAnt := cBkpFilAnt
    
    fwFreeObj(oConsolidado)
    fwFreeArray(aSql)

    restArea(aAreaMIP)
    restArea(aAreaMHR)
    restArea(aAreaMHQ)
    restArea(aArea)

Return NiL
