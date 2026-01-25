#INCLUDE 'DLGXFUN.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLTransfer³ Autor ³ VICCO                 ³ Data ³01.04.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a Transferencia Automatica dos Produtos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLTransfer(ExPL1,ExPC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. Utiliza Radio Frequencia, .F. Nao utiliza      ³±±
±±³          ³ ExpC1 = "1" = Gera registros no SDB sem movimentar estoque ³±±
±±³          ³         "2" = Atualiza o registro no SDB com status de     ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³                                                            ³±±
±±³          ³ Parametros   tambem  serao  passados   atraves   do  Array ³±±
±±³          ³ "aParam150", que devera ser PRIVATE na funcao anterior,com ³±±
±±³          ³ o seguinte formato:                                        ³±±
±±³          ³ aParam150[01] = Produto                                    ³±±
±±³          ³ aParam150[02] = Armazem Origem                             ³±±
±±³          ³ aParam150[03] = Documento                                  ³±±
±±³          ³ aParam150[04] = Serie                                      ³±±
±±³          ³ aParam150[05] = Numero Sequencial                          ³±±
±±³          ³ aParam150[06] = Quantidade a ser Movimentada               ³±±
±±³          ³ aParam150[07] = Data da Movimentacao                       ³±±
±±³          ³ aParam150[08] = Hora da Movimentacao                       ³±±
±±³          ³ aParam150[09] = Servico                                    ³±±
±±³          ³ aParam150[10] = Tarefa                                     ³±±
±±³          ³ aParam150[11] = Atividade                                  ³±±
±±³          ³ aParam150[12] = Cliente/Fornecedor                         ³±±
±±³          ³ aParam150[13] = Loja                                       ³±±
±±³          ³ aParam150[14] = Tipo da Nota Fiscal                        ³±±
±±³          ³ aParam150[15] = Item da Nota Fiscal                        ³±±
±±³          ³ aParam150[16] = Tipo de Movimentacao                       ³±±
±±³          ³ aParam150[17] = Origem de Movimentacao                     ³±±
±±³          ³ aParam150[18] = Lote                                       ³±±
±±³          ³ aParam150[19] = Sub-Lote                                   ³±±
±±³          ³ aParam150[20] = Endereco Origem                            ³±±
±±³          ³ aParam150[21] = Estrutura Fisica Origem                    ³±±
±±³          ³ aParam150[22] = Regra de Apanhe (1=Lote/2=N.Serie/3=Data)  ³±±
±±³          ³ aParam150[23] = Codigo da Carga                            ³±±
±±³          ³ aParam150[24] = Nr. do Unitizador                          ³±±
±±³          ³ aParam150[25] = Armazem Destino                            ³±±
±±³          ³ aParam150[26] = Endereco Destino                           ³±±
±±³          ³ aParam150[27] = Estrutura Fisica Destino                   ³±±
±±³          ³ aParam150[28] = Ordem da Tarefa                            ³±±
±±³          ³ aParam150[29] = Ordem da Atividade                         ³±±
±±³          ³ aParam150[30] = Recurso Humano                             ³±±
±±³          ³ aParam150[31] = Recurso Fisico                             ³±±
±±³          ³ aParam150[32] = Identificador do DCF DCF_ID                ³±±
±±³          ³ aParam150[33] = Codigo da Norma informada Docto de Entrada ³±±
±±³          ³ aParam150[34] = Identificador exclusivo Movimento no SDB   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLTransfer(lRadioF,cStatRF)
Default lRadioF := (SuperGetMV('MV_RADIOF')=='S') //-- Como Default o parametro MV_RADIOF e verificado
Default cStatRF := '1' //-- Como Default a radio frequencia VAI gerar movimentos no SDB SEM atualizar estoque
	If FindFunction("WmsTransfer")
		Return WmsTransfer(lRadioF,cStatRF) //Não exibe mensagens
	Else
		Final("Solicite atualização do chamado TSMBRK.")
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DLDesfrag ºAutor ³Felipe Machado de Oliveira º Data ³  24/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Desfragmentar Estoque                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLDesfrag(lRadioF,cStatRF)
Return DLTransfer(lRadioF,cStatRF)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLEndereca³ Autor ³ Alex Egydio           ³ Data ³02.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o Enderecamento Automatico dos Produtos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLEndereca(ExPL1,ExPC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. Utiliza Radio Frequencia, .F. Nao utiliza      ³±±
±±³          ³ ExpC1 = "1" = Gera registros no SDB sem movimentar estoque ³±±
±±³          ³         "2" = Atualiza o registro no SDB com status de     ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³                                                            ³±±
±±³          ³ Todos os Parametros  serao  passados  atraves do  um Array ³±±
±±³          ³ "aParam150", que devera ser PRIVATE na funcao anterior,com ³±±
±±³          ³ o seguinte formato:                                        ³±±
±±³          ³ aParam150[01] = Produto                                    ³±±
±±³          ³ aParam150[02] = Armazem Origem                             ³±±
±±³          ³ aParam150[03] = Documento                                  ³±±
±±³          ³ aParam150[04] = Serie                                      ³±±
±±³          ³ aParam150[05] = Numero Sequencial                          ³±±
±±³          ³ aParam150[06] = Quantidade a ser Movimentada               ³±±
±±³          ³ aParam150[07] = Data da Movimentacao                       ³±±
±±³          ³ aParam150[08] = Hora da Movimentacao                       ³±±
±±³          ³ aParam150[09] = Servico                                    ³±±
±±³          ³ aParam150[10] = Tarefa                                     ³±±
±±³          ³ aParam150[11] = Atividade                                  ³±±
±±³          ³ aParam150[12] = Cliente/Fornecedor                         ³±±
±±³          ³ aParam150[13] = Loja                                       ³±±
±±³          ³ aParam150[14] = Tipo da Nota Fiscal                        ³±±
±±³          ³ aParam150[15] = Item da Nota Fiscal                        ³±±
±±³          ³ aParam150[16] = Tipo de Movimentacao                       ³±±
±±³          ³ aParam150[17] = Origem de Movimentacao                     ³±±
±±³          ³ aParam150[18] = Lote                                       ³±±
±±³          ³ aParam150[19] = Sub-Lote                                   ³±±
±±³          ³ aParam150[20] = Endereco Origem                            ³±±
±±³          ³ aParam150[21] = Estrutura Fisica Origem                    ³±±
±±³          ³ aParam150[22] = Regra de Apanhe (1=Lote/2=N.Serie/3=Data)  ³±±
±±³          ³ aParam150[23] = Codigo da Carga                            ³±±
±±³          ³ aParam150[24] = Nr. do Unitizador                          ³±±
±±³          ³ aParam150[25] = Armazem Destino                            ³±±
±±³          ³ aParam150[26] = Endereco Destino                           ³±±
±±³          ³ aParam150[27] = Estrutura Fisica Destino                   ³±±
±±³          ³ aParam150[28] = Ordem da Tarefa                            ³±±
±±³          ³ aParam150[29] = Ordem da Atividade                         ³±±
±±³          ³ aParam150[30] = Recurso Humano                             ³±±
±±³          ³ aParam150[31] = Recurso Fisico                             ³±±
±±³          ³ aParam150[32] = Identificador do DCF DCF_ID                ³±±
±±³          ³ aParam150[33] = Codigo da Norma informada Docto de Entrada ³±±
±±³          ³ aParam150[34] = Identificador exclusivo Movimento no SDB   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tabela de Tarefas (L7) do SX5                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLEndereca(lRadioF,cStatRF)

Default lRadioF    := (SuperGetMV('MV_RADIOF')=='S') //-- Como Default o parametro MV_RADIOF e verificado
Default cStatRF    := '1' //-- Como Default a radio frequencia VAI gerar movimentos no SDB SEM atualizar estoque
	If FindFunction("WmsEndereca")
		Return WmsEndereca(lRadioF,cStatRF) //Não exibe mensagens
	Else
		Final("Solicite atualização dos chamados TQJADB e TQRUUN.")
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLCrossDoc³ Autor ³ Alex Egydio           ³ Data ³19.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cross-Docking e um metodo que movimenta os produtos de um   ³±±
±±³          ³fornecedor atraves de um Armazem, ou nao, sem               ³±±
±±³          ³armazenar o produto por um longo tempo.                     ³±±
±±³          ³O Cross-Docking permite reducao no custo final do produto,  ³±±
±±³          ³devido ao corte nos custos de estocagem.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DlgA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLCrossDoc(lRadioF,cStatRF)
Default lRadioF := (SuperGetMV('MV_RADIOF')=='S') //-- Como Default o parametro MV_RADIOF e verificado
Default cStatRF := '1' //-- Como Default a radio frequencia VAI gerar movimentos no SDB SEM atualizar estoque
	If FindFunction("WmsEndCross")
		Return WmsEndCross(lRadioF,cStatRF) //Não exibe mensagens
	Else
		Final("Solicite atualização do chamado TSMBRK.")
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLApanhe  ³ Autor ³ Fernando Joly Siquini ³ Data ³09.04.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o "Apanhe" Automatico dos Produtos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLApanhe(ExpL1, ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. Utiliza Radio Frequencia, .F. Nao utiliza      ³±±
±±³          ³ ExpC1 = "1" = Gera registros no SDB sem movimentar estoque ³±±
±±³          ³         "2" = Atualiza o registro no SDB com status de     ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³ ExpL2 = .T. Executa WmsAtzSC9()                            ³±±
±±³          ³ ExpL3 = .T. Permite Liberação do SC9 (C9_BLWMS)            ³±±
±±³          ³                                                            ³±±
±±³          ³ Parametros   tambem  serao  passados   atraves   do  Array ³±±
±±³          ³ "aParam150", que devera ser PRIVATE na funcao anterior,com ³±±
±±³          ³ o seguinte formato:                                        ³±±
±±³          ³ aParam150[01] = Produto                                    ³±±
±±³          ³ aParam150[02] = Armazem Origem                             ³±±
±±³          ³ aParam150[03] = Documento                                  ³±±
±±³          ³ aParam150[04] = Serie                                      ³±±
±±³          ³ aParam150[05] = Numero Sequencial                          ³±±
±±³          ³ aParam150[06] = Quantidade a ser Movimentada               ³±±
±±³          ³ aParam150[07] = Data da Movimentacao                       ³±±
±±³          ³ aParam150[08] = Hora da Movimentacao                       ³±±
±±³          ³ aParam150[09] = Servico                                    ³±±
±±³          ³ aParam150[10] = Tarefa                                     ³±±
±±³          ³ aParam150[11] = Atividade                                  ³±±
±±³          ³ aParam150[12] = Cliente/Fornecedor                         ³±±
±±³          ³ aParam150[13] = Loja                                       ³±±
±±³          ³ aParam150[14] = Tipo da Nota Fiscal                        ³±±
±±³          ³ aParam150[15] = Item da Nota Fiscal                        ³±±
±±³          ³ aParam150[16] = Tipo de Movimentacao                       ³±±
±±³          ³ aParam150[17] = Origem de Movimentacao                     ³±±
±±³          ³ aParam150[18] = Lote                                       ³±±
±±³          ³ aParam150[19] = Sub-Lote                                   ³±±
±±³          ³ aParam150[20] = Endereco Origem                            ³±±
±±³          ³ aParam150[21] = Estrutura Fisica Origem                    ³±±
±±³          ³ aParam150[22] = Regra de Apanhe (1=Lote/2=N.Serie/3=Data)  ³±±
±±³          ³ aParam150[23] = Codigo da Carga                            ³±±
±±³          ³ aParam150[24] = Nr. do Unitizador                          ³±±
±±³          ³ aParam150[25] = Armazem Destino                            ³±±
±±³          ³ aParam150[26] = Endereco Destino                           ³±±
±±³          ³ aParam150[27] = Estrutura Fisica Destino                   ³±±
±±³          ³ aParam150[28] = Ordem da Tarefa                            ³±±
±±³          ³ aParam150[29] = Ordem da Atividade                         ³±±
±±³          ³ aParam150[30] = Recurso Humano                             ³±±
±±³          ³ aParam150[31] = Recurso Fisico                             ³±±
±±³          ³ aParam150[32] = Identificador do DCF DCF_ID                ³±±
±±³          ³ aParam150[33] = Codigo da Norma informada Docto de Entrada ³±±
±±³          ³ aParam150[34] = Identificador exclusivo Movimento no SDB   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tabela de Tarefas (L7) do SX5                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLApanhe(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)
Default lRadioF      := (SuperGetMV('MV_RADIOF')=='S')
Default cStatRF      := '1'
Default lWmsAtzSC9   := .T.
Default lWmsLibSC9   := .T.
	If FindFunction("WmsApanhe")
		Return WmsApanhe(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9) //Não exibe mensagens
	Else
		Final("Solicite atualização do chamado TQIRZC.")
	EndIf
Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLApanheVL³ Autor ³ Leandro Paulino       ³ Data ³06.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o "Apanhe" Automatico dos Produtos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLApanheVL(ExpL1, ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. Utiliza Radio Frequencia, .F. Nao utiliza      ³±±
±±³          ³ ExpC1 = "1" = Gera registros no SDB sem movimentar estoque ³±±
±±³          ³         "2" = Atualiza o registro no SDB com status de     ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³ ExpL2 = .T. Executa WmsAtzSC9()                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLApanheVL(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)
Default lRadioF      := (SuperGetMV('MV_RADIOF')=='S')
Default cStatRF      := '1'
Default lWmsAtzSC9   := .T.
Default lWmsLibSC9   := .F.

Return DLApanhe(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLApanheC1³ Autor ³ Flávio Aroldi Junior  ³ Data ³10.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Esta função será utilizada para diferenciar os processos em³±±
±±³ que deverá ser efetuado o apanhe de produtos considerando o saldo que ³±±
±±³ está em endereços do tipo de estrutura "Cross Docking" sendo que não  ³±±
±±³ será utilizada a rotina de montagem de volumes.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLApanheC1(ExpL1, ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRadioF = .T. Utiliza Radio Frequencia, .F. Nao utiliza     ³±±
±±³          ³cStatRF = "1" = Gera registros no SDB sem movimentar estoque³±±
±±³          ³          "2" = Atualiza o registro no SDB com status de    ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³ lWmsAtzSC9 = .T. Executa WmsAtzSC9()                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLApanheC1(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)
Default lRadioF      := (SuperGetMV('MV_RADIOF')=='S')
Default cStatRF      := '1'
Default lWmsAtzSC9   := .T.
Default lWmsLibSC9   := .F.

Return DLApanhe(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLApanheC2³ Autor ³ Flávio Aroldi Junior  ³ Data ³10.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Esta função será utilizada para diferenciar os processos em³±±
±±³ que deverá ser efetuado o apanhe de produtos considerando o saldo que ³±±
±±³ está em endereços do tipo de estrutura "Cross Docking" e onde também  ³±±
±±³ será utilizada a rotina de montagem de volumes.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLApanheC2(ExpL1, ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRadioF = .T. Utiliza Radio Frequencia, .F. Nao utiliza     ³±±
±±³          ³cStatRF = "1" = Gera registros no SDB sem movimentar estoque³±±
±±³          ³         "2" = Atualiza o registro no SDB com status de     ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³ lWmsAtzSC9 = .T. Executa WmsAtzSC9()                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLApanheC2(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)

Default lRadioF      := (SuperGetMV('MV_RADIOF')=='S')
Default cStatRF      := '1'
Default lWmsAtzSC9   := .T.
Default lWmsLibSC9   := .F.

Return DLApanhe(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DlgxAbast     ³ Autor ³ Renato           ³ Data ³22.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Localiza lista de picking  do  produto  e  obtem estrutura ³±±
±±³          ³ que  deve  ser  utilizada  para  obter  endereco base para ³±±
±±³          ³ transferencia.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DlgxAbast(ExC1,ExC2,ExC3,ExC4,ExC5,ExN1,ExX1,ExL1,ExC6)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. Utiliza Radio Frequencia, .F. Nao utiliza      ³±±
±±³          ³ ExpC1 = "1" = Gera registros no SDB sem movimentar estoque ³±±
±±³          ³         "2" = Atualiza o registro no SDB com status de     ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³                                                            ³±±
±±³          ³ Parametros   tambem  serao  passados   atraves   do  Array ³±±
±±³          ³ "aParam150", que devera ser PRIVATE na funcao anterior,com ³±±
±±³          ³ o seguinte formato:                                        ³±±
±±³          ³ aParam150[01] = Produto                                    ³±±
±±³          ³ aParam150[02] = Armazem Origem                             ³±±
±±³          ³ aParam150[03] = Documento                                  ³±±
±±³          ³ aParam150[04] = Serie                                      ³±±
±±³          ³ aParam150[05] = Numero Sequencial                          ³±±
±±³          ³ aParam150[06] = Quantidade a ser Movimentada               ³±±
±±³          ³ aParam150[07] = Data da Movimentacao                       ³±±
±±³          ³ aParam150[08] = Hora da Movimentacao                       ³±±
±±³          ³ aParam150[09] = Servico                                    ³±±
±±³          ³ aParam150[10] = Tarefa                                     ³±±
±±³          ³ aParam150[11] = Atividade                                  ³±±
±±³          ³ aParam150[12] = Cliente/Fornecedor                         ³±±
±±³          ³ aParam150[13] = Loja                                       ³±±
±±³          ³ aParam150[14] = Tipo da Nota Fiscal                        ³±±
±±³          ³ aParam150[15] = Item da Nota Fiscal                        ³±±
±±³          ³ aParam150[16] = Tipo de Movimentacao                       ³±±
±±³          ³ aParam150[17] = Origem de Movimentacao                     ³±±
±±³          ³ aParam150[18] = Lote                                       ³±±
±±³          ³ aParam150[19] = Sub-Lote                                   ³±±
±±³          ³ aParam150[20] = Endereco Origem                            ³±±
±±³          ³ aParam150[21] = Estrutura Fisica Origem                    ³±±
±±³          ³ aParam150[22] = Regra de Apanhe (1=Lote/2=N.Serie/3=Data)  ³±±
±±³          ³ aParam150[23] = Codigo da Carga                            ³±±
±±³          ³ aParam150[24] = Nr. do Unitizador                          ³±±
±±³          ³ aParam150[25] = Armazem Destino                            ³±±
±±³          ³ aParam150[26] = Endereco Destino                           ³±±
±±³          ³ aParam150[27] = Estrutura Fisica Destino                   ³±±
±±³          ³ aParam150[28] = Ordem da Tarefa                            ³±±
±±³          ³ aParam150[29] = Ordem da Atividade                         ³±±
±±³          ³ aParam150[30] = Recurso Humano                             ³±±
±±³          ³ aParam150[31] = Recurso Fisico                             ³±±
±±³          ³ aParam150[32] = Identificador do DCF DCF_ID                ³±±
±±³          ³ aParam150[33] = Codigo da Norma informada Docto de Entrada ³±±
±±³          ³ aParam150[34] = Identificador exclusivo Movimento no SDB   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DlgxAbast(lRadioF, cStatRF)
Return WmsAbastece(lRadioF,cStatRF,"A")

Function DLAbastece(lRadioF, cStatRF)
Return WmsAbastece(lRadioF,cStatRF,"A")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLConferen³ Autor ³ Edman                 ³ Data ³26.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera os registros de conferencia no SDB                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLConferen()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. Utiliza Radio Frequencia, .F. Nao utiliza      ³±±
±±³          ³ ExpC1 = "1" = Gera registros no SDB sem movimentar estoque ³±±
±±³          ³         "2" = Atualiza o registro no SDB com status de     ³±±
±±³          ³               execucao e atualiza saldos no estoque.       ³±±
±±³          ³                                                            ³±±
±±³          ³ Parametros   tambem  serao  passados   atraves   do  Array ³±±
±±³          ³ "aParam150", que devera ser PRIVATE na funcao anterior,com ³±±
±±³          ³ o seguinte formato:                                        ³±±
±±³          ³ aParam150[01] = Produto                                    ³±±
±±³          ³ aParam150[02] = Armazem Origem                             ³±±
±±³          ³ aParam150[03] = Documento                                  ³±±
±±³          ³ aParam150[04] = Serie                                      ³±±
±±³          ³ aParam150[05] = Numero Sequencial                          ³±±
±±³          ³ aParam150[06] = Quantidade a ser Movimentada               ³±±
±±³          ³ aParam150[07] = Data da Movimentacao                       ³±±
±±³          ³ aParam150[08] = Hora da Movimentacao                       ³±±
±±³          ³ aParam150[09] = Servico                                    ³±±
±±³          ³ aParam150[10] = Tarefa                                     ³±±
±±³          ³ aParam150[11] = Atividade                                  ³±±
±±³          ³ aParam150[12] = Cliente/Fornecedor                         ³±±
±±³          ³ aParam150[13] = Loja                                       ³±±
±±³          ³ aParam150[14] = Tipo da Nota Fiscal                        ³±±
±±³          ³ aParam150[15] = Item da Nota Fiscal                        ³±±
±±³          ³ aParam150[16] = Tipo de Movimentacao                       ³±±
±±³          ³ aParam150[17] = Origem de Movimentacao                     ³±±
±±³          ³ aParam150[18] = Lote                                       ³±±
±±³          ³ aParam150[19] = Sub-Lote                                   ³±±
±±³          ³ aParam150[20] = Endereco Origem                            ³±±
±±³          ³ aParam150[21] = Estrutura Fisica Origem                    ³±±
±±³          ³ aParam150[22] = Regra de Apanhe (1=Lote/2=N.Serie/3=Data)  ³±±
±±³          ³ aParam150[23] = Codigo da Carga                            ³±±
±±³          ³ aParam150[24] = Nr. do Unitizador                          ³±±
±±³          ³ aParam150[25] = Armazem Destino                            ³±±
±±³          ³ aParam150[26] = Endereco Destino                           ³±±
±±³          ³ aParam150[27] = Estrutura Fisica Destino                   ³±±
±±³          ³ aParam150[28] = Ordem da Tarefa                            ³±±
±±³          ³ aParam150[29] = Ordem da Atividade                         ³±±
±±³          ³ aParam150[30] = Recurso Humano                             ³±±
±±³          ³ aParam150[31] = Recurso Fisico                             ³±±
±±³          ³ aParam150[32] = Identificador do DCF DCF_ID                ³±±
±±³          ³ aParam150[33] = Codigo da Norma informada Docto de Entrada ³±±
±±³          ³ aParam150[34] = Identificador exclusivo Movimento no SDB   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tabela de Tarefas (L7) do SX5                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLConferen()
Local aAreaAnt := GetArea()
Local lRet     := .T.
	If Type('aParam150') == 'A'
		If aParam150[17] == 'SD1'
			lRet := DLConfEnt()
		Else
			aParam150[20] := DCF->DCF_ENDER  // Endereco Origem
			aParam150[21] := DCF->DCF_ESTFIS // Estrutura Origem
			aParam150[26] := DCF->DCF_ENDER  // Endereco Destino
			aParam150[27] := DCF->DCF_ESTFIS // Estrutura Destino
			aParam150[14] := ''              // Tipo da Nota Fiscal de Entrada
			aParam150[16] := ''              // Tipo de Entrada e Saida
			DLXExecAti(aParam150[10], aParam150)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*/{Protheus.doc} DLConfSai
Função para execução de um processo de conferência de expedição
Antes de chamar esta função deve star declardo um array - Private aParam150
Este array contém os parametros da ordem de serviço a ser executada
@author Jackson Patrick Werka
@since 15/09/2014

@return Lógico Indicador se as atividades foram geradas corretamente
/*/
Function DLConfSai()
Local aAreaAnt  := GetArea()
Local aAreaDC5  := DC5->(GetArea())
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local aParam    := {}
Local aTamSX3   := TamSx3('DCR_QUANT')
Local cOrdSep   := "01"
Local lAgluSerEx:= Type('aAgluDCF') == 'A' .And. !Empty(aAgluDCF) //Verifica se os serviços de expedição estão aglutinados
Local nI := 0
	If Type('aParam150') == 'A'
		DC5->(DbSetOrder(1))
		If DC5->(MsSeek(xFilial("DC5")+aParam150[09]+aParam150[28]))
			DC5->(DbSkip(-1))
			If DC5->DC5_SERVIC == aParam150[09]
				cOrdSep := DC5->DC5_ORDEM
			EndIf
		EndIf

		cQuery := "SELECT DCF.DCF_CODPRO, SDB.DB_LOTECTL, SDB.DB_NUMLOTE, sum(DCR.DCR_QUANT) DCR_QUANT,"
		cQuery += " DCF_ID, DCF_NUMSEQ, DCF_DOCTO, DCF_SERIE, DCF_CLIFOR, DCF_LOJA "
		cQuery +=  " FROM "+RetSqlName("DCF")+" DCF, "+RetSqlName("DCR")+" DCR, "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=   " AND DCF.DCF_SERVIC = '"+aParam150[09]+"'"
		If lAgluSerEx
			cQuery += " AND DCF.DCF_ID IN ("
			For nI := 1 To Len(aAgluDCF)
				cQuery += IIF (nI  == Len(aAgluDCF),"'"+aAgluDCF[nI][1]+"'","'"+aAgluDCF[nI][1]+"',")
			Next nI
			cQuery += ")"
		Else
			cQuery +=   " AND DCF.DCF_ID     = '"+aParam150[32]+"'"
		EndIf
		cQuery +=   " AND DCF.DCF_CODPRO = '"+aParam150[01]+"'"
		cQuery +=   " AND DCF.DCF_LOCAL  = '"+aParam150[02]+"'"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=   " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
		cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_SERVIC  = DCF.DCF_SERVIC"
		cQuery +=   " AND SDB.DB_PRODUTO = DCF.DCF_CODPRO"
		cQuery +=   " AND SDB.DB_LOCAL   = DCF.DCF_LOCAL"
		cQuery +=   " AND SDB.DB_IDDCF   = DCR.DCR_IDORI"
		cQuery +=   " AND SDB.DB_IDMOVTO = DCR.DCR_IDMOV"
		cQuery +=   " AND SDB.DB_IDOPERA = DCR.DCR_IDOPER"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SDB.DB_ORDTARE = '"+cOrdSep+"'" //Assume a tarefa exatamante anterior
		cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
														" FROM "+RetSqlName("SDB")+" SDBM"+;
													  " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"+;
														 " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"+;
														 " AND SDBM.DB_DOC     = SDB.DB_DOC"+;
														 " AND SDBM.DB_SERIE   = SDB.DB_SERIE"+;
														 " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"+;
														 " AND SDBM.DB_LOJA    = SDB.DB_LOJA"+;
														 " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"+;
														 " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"+;
														 " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"+;
														 " AND SDBM.DB_ESTORNO = ' '"+;
														 " AND SDBM.DB_ATUEST  = 'N'"+;
														 " AND SDBM.D_E_L_E_T_ = ' ' )"
		cQuery += " GROUP BY DCF.DCF_CODPRO, DCF.DCF_NUMSEQ,DCF.DCF_DOCTO,DCF.DCF_SERIE,DCF.DCF_CLIFOR,DCF.DCF_LOJA,DCF.DCF_ID,"
		cQuery += " SDB.DB_LOTECTL, SDB.DB_NUMLOTE"
		cQuery += " ORDER BY DCF.DCF_ID,DCF.DCF_CODPRO, SDB.DB_LOTECTL, SDB.DB_NUMLOTE"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		TcSetField(cAliasQry,'DCR_QUANT','N',aTamSX3[1],aTamSX3[2])

		Do While lRet .And. (cAliasQry)->(!Eof())
			//-- Monta o Array aParam para ser utilizado na Execucao das Atividades
			aParam     := aClone(aParam150)
			aParam[06] := (cAliasQry)->DCR_QUANT  //-- Quantidade Movimentada
			aParam[18] := (cAliasQry)->DB_LOTECTL //-- Lote
			aParam[19] := (cAliasQry)->DB_NUMLOTE //-- Sub-Lote
			//-- Executa todas as Atividades (DC6) da Tarefa (DC5) Atual

			If lAgluSerEx
				aParam150[03] := (cAliasQry)->DCF_DOCTO
				aParam150[04] := (cAliasQry)->DCF_SERIE
				aParam150[05] := (cAliasQry)->DCF_NUMSEQ
				aParam150[12] := (cAliasQry)->DCF_CLIFOR
				aParam150[13] := (cAliasQry)->DCF_LOJA
				aParam150[32] := (cAliasQry)->DCF_ID
			EndIf
			lRet := DLXExecAti(aParam[10], aParam)
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aAreaDC5)
	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} DLConfEnt
Função para execução de um processo de conferência de recebimento
Antes de chamar esta função deve star declardo um array - Private aParam150
Este array contém os parametros da ordem de serviço a ser executada

@since  10/04/2015
@return Lógico Indicador se as atividades foram geradas corretamente
/*/
Function DLConfEnt()
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local cProduto := ""
Local cLocal   := ""
Local cNumSeq  := ""
Local cEstFis  := ""
	If Type('aParam150') == 'A'
		If aParam150[17] == 'SD1'
			cProduto := aParam150[01]
			cLocal   := aParam150[02]
			cDocto   := aParam150[03]
			cNumSeq  := aParam150[05]
			SD1->(DbSetOrder(5)) //D1_FILIAL+D1_COD+D1_LOCAL+D1_NUMSEQ
			If SD1->(MsSeek(xFilial('SD1')+cProduto+cLocal+cNumSeq))
				cEstFis := Posicione('SBE',1,xFilial('SBE')+cLocal+SD1->D1_ENDER,'BE_ESTFIS')
				aParam150[20] := SD1->D1_ENDER // Endereco Origem
				aParam150[21] := cEstFis       // Estrutura Origem
				aParam150[26] := SD1->D1_ENDER // Endereco Destino
				aParam150[27] := cEstFis       // Estrutura Destino
				aParam150[14] := SD1->D1_TIPO  // Tipo da Nota Fiscal de Entrada
				aParam150[15] := SD1->D1_ITEM
				aParam150[16] := SD1->D1_TES   // Tipo de Entrada e Saida
			Else
				WmsMessage(STR0021+AllTrim(cProduto)+'/'+AllTrim(cLocal)+'/'+AllTrim(cDocto)+STR0022+'SD1).','DLGXFUN24',1) //'O registro ref. a movimentacao do Produto/Armazem/Doc '###' nao foi encontrado no Arquivo de Origem ('
				lRet := .F.
			EndIf
		Else
			aParam150[20] := DCF->DCF_ENDER  // Endereco Origem
			aParam150[21] := DCF->DCF_ESTFIS // Estrutura Origem
			aParam150[26] := DCF->DCF_ENDER  // Endereco Destino
			aParam150[27] := DCF->DCF_ESTFIS // Estrutura Destino
			aParam150[14] := ''              // Tipo da Nota Fiscal de Entrada
			aParam150[16] := ''              // Tipo de Entrada e Saida
		EndIf
		If lRet
			//Executa as atividades
			DLXExecAti(aParam150[10], aParam150)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLXExecAti³ Autor ³Fernando Joly Siquini  ³ Data ³31.03.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa as Atividades da Terafa Selecionada                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLXExecAti(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tarefa                                             ³±±
±±³          ³ ExpA1 = Array no Seguinte Formato:                         ³±±
±±³          ³         ExpA1[01] = Produto                                ³±±
±±³          ³         ExpA1[02] = Armazem Origem                         ³±±
±±³          ³         ExpA1[03] = Documento                              ³±±
±±³          ³         ExpA1[04] = Serie                                  ³±±
±±³          ³         ExpA1[05] = Numero Sequencial                      ³±±
±±³          ³         ExpA1[06] = Quantidade a ser Movimentada           ³±±
±±³          ³         ExpA1[07] = Data da Movimentacao                   ³±±
±±³          ³         ExpA1[08] = Hora da Movimentacao                   ³±±
±±³          ³         ExpA1[09] = Servico                                ³±±
±±³          ³         ExpA1[10] = Tarefa                                 ³±±
±±³          ³         ExpA1[11] = Atividade                              ³±±
±±³          ³         ExpA1[12] = Cliente/Fornecedor                     ³±±
±±³          ³         ExpA1[13] = Loja                                   ³±±
±±³          ³         ExpA1[14] = Tipo da Nota Fiscal                    ³±±
±±³          ³         ExpA1[15] = Item da Nota Fiscal                    ³±±
±±³          ³         ExpA1[16] = Tipo de Movimentacao                   ³±±
±±³          ³         ExpA1[17] = Origem de Movimentacao                 ³±±
±±³          ³         ExpA1[18] = Lote                                   ³±±
±±³          ³         ExpA1[19] = Sub-Lote                               ³±±
±±³          ³         ExpA1[20] = Endereco Origem                        ³±±
±±³          ³         ExpA1[21] = Estrutura Fisica Origem                ³±±
±±³          ³         ExpA1[22] = Regra de Apanhe(1=Lote/2=NSerie/3=Data)³±±
±±³          ³         ExpA1[23] = Codigo da Carga                        ³±±
±±³          ³         ExpA1[24] = Nr. do Unitizador                      ³±±
±±³          ³         ExpA1[25] = Armazem Destino                        ³±±
±±³          ³         ExpA1[26] = Endereco Destino                       ³±±
±±³          ³         ExpA1[27] = Estrutura Fisica Destino               ³±±
±±³          ³         ExpA1[28] = Ordem da Tarefa                        ³±±
±±³          ³         ExpA1[29] = Ordem da Atividade                     ³±±
±±³          ³         ExpA1[30] = Recurso Humano                         ³±±
±±³          ³         ExpA1[31] = Recurso Fisico                         ³±±
±±³          ³         ExpA1[32] = Identificador do DCF DCF_ID            ³±±
±±³          ³         ExpA1[33] = Codigo da Norma informada Doc Entrada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 = .T. caso nenhum problema tenha ocorrido, .F. C.C.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLXExecAti(cTarefa, aParam)

Static lDLGGATV  := ExistBlock("DLGGATV")   // Ponto de entrada para identificar se grava atividade ou nao
Static lDLGEXETA := ExistBlock("DLGEXETA")  // Ponto de entrada apos executar tarefa
Static lDLGNSERI := ExistBlock("DLGNSERI")

Local aAreaAnt   := GetArea()
Local aAreaDC5   := DC5->(GetArea())
Local aAreaDC6   := DC6->(GetArea())
Local aAreaSBF   := SBF->(GetArea())
Local aExcecoesO := {} //-- Excecoes referentes ao Endereco ORIGEM
Local aExcecoesD := {} //-- Excecoes referentes ao Endereco DESTINO
Local aAtivExec  := {} //-- Atividades a serem executadas
Local cSeek      := ''
Local cNSEBlock  := ''
Local cNumSerie  := ''
Local cProduto   := ''
Local cLocOrig   := ''
Local cDoc       := ''
Local cSerie     := ''
Local cNumSeq    := ''
Local cHora      := ''
Local cServico   := ''
Local cAtividade := ''
Local cCliFor    := ''
Local cLoja      := ''
Local cTipoNF    := ''
Local cItem      := ''
Local cTM        := ''
Local cTipo      := Iif(Type('cTipoSDB')=='C',cTipoSDB,'E')
Local cOrigLan   := ''
Local cLoteCtl   := ''
Local cNumLote   := ''
Local cEndOrig   := ''
Local cEstOrig   := ''
Local cLocDest   := ''
Local cEndDest   := ''
Local cEstDest   := ''
Local cCarga     := ''
Local cUnitiz    := ''
Local cOrdTar    := ''
Local cOrdAti    := ''
Local cRHumano   := ''
Local cRFisico   := ''
Local cTipoServ  := '3'
Local cIdDCF     := ''
Local dData      := CtoD('  /  /  ')
Local lRet       := .T.
Local nRegra     := 0
Local nQuant     := 0
Local lGravaSDB  := .T.
Local lNoExcec   := .T.
Local nCntAtiv   := 0
Local cIdMovto   := ""
Local nI         := 0
Local nQtSol     := 0
Local cIDDCFOrig := ""
Local nOrdTar    := 0
Local cFunExe    := ''
	If ValType(aParam) == 'A'
		cProduto   := aParam[01]
		cLocOrig   := aParam[02]
		cDoc       := aParam[03]
		cSerie     := aParam[04]
		cNumSeq    := aParam[05]
		nQuant     := aParam[06]
		dData      := aParam[07]
		cHora      := aParam[08]
		cServico   := aParam[09]
		cTarefa    := aParam[10]
		cAtividade := aParam[11]
		cCliFor    := aParam[12]
		cLoja      := aParam[13]
		cTipoNF    := aParam[14]
		cItem      := aParam[15]
		cTM        := aParam[16]
		cOrigLan   := aParam[17]
		cLoteCtl   := aParam[18]
		cNumLote   := aParam[19]
		cEndOrig   := aParam[20]
		cEstOrig   := aParam[21]
		nRegra     := aParam[22]
		cCarga     := aParam[23]
		cUnitiz    := aParam[24]
		cLocDest   := aParam[25]
		cEndDest   := aParam[26]
		cEstDest   := aParam[27]
		cOrdTar    := aParam[28]
		cOrdAti    := aParam[29]
		cRHumano   := aParam[30]
		cRFisico   := aParam[31]
		If Len(aParam)>=32
			cIdDCF  := aParam[32]
		EndIf
	EndIf

	If lDLGNSERI
		cNSEBlock := ExecBlock('DLGNSERI',.F.,.F.,{cOrigLan,cProduto,cLocOrig,cDoc,cSerie,cCliFor,cLoja,nQuant,cEndOrig})
		cNumSerie := If(ValType(cNSEBlock)=='C',cNSEBlock,cNumSerie)
	EndIf

	//-- Verifica o Tipo de Servico (1-Entrada/2-Saida/3-Mov.Interno)
	DbSelectArea('DC5')
	DbSelectArea('SX5')
	SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
	DC5->(DbSetOrder(1))
	If DC5->(MsSeek(xFilial('DC5')+cServico, .F.))
		cTipoServ := DC5->DC5_TIPO
		If SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
			cFunExe := AllTrim(Upper(SX5->(X5Descri())))
		EndIf
	EndIf

	//Realiza o rateio para a tarefa da quantidade total solicitada dentre os ID DCF que estão no array aAgluDCF,
	//determinando neste momento quanto de cada ID DCF que será atendido pela quantidade total deste movimento

	If Type("aAgluDCF") == "A" .And. !Empty(aAgluDCF) .And. 'DLGXABAST()' != Upper(cFunExe)
		nQtSol := nQuant

		nOrdTar:= Len(aAgluDCF[1][4]) //A ordem da tarefa é a útilma adicionada no array.
		For nI := 1 To Len(aAgluDCF)
			If (aAgluDCF[nI][2] - aAgluDCF[nI][4][nOrdTar][2]) > 0
				//Considera a primeira DCF com saldo disponível para ser utilizado na movimentação, como a DCF de origem.
				If Empty(cIDDCFOrig)
					cIDDCFOrig := aAgluDCF[nI][1]
				EndIf

				aAgluDCF[nI][4][nOrdTar][3] := cIDDCFOrig
				If nQtSol > (aAgluDCF[nI][2] - aAgluDCF[nI][4][nOrdTar][2])
					nQtSol -= (aAgluDCF[nI][2] - aAgluDCF[nI][4][nOrdTar][2])
					aAgluDCF[nI][4][nOrdTar][4] := (aAgluDCF[nI][2] - aAgluDCF[nI][4][nOrdTar][2]) //Utiliza todo o saldo
				Else
					aAgluDCF[nI][4][nOrdTar][4] := nQtSol
					nQtSol := 0
				EndIf
				// Grava o total atendido
				aAgluDCF[nI][4][nOrdTar][2] += aAgluDCF[nI][4][nOrdTar][4]

				If nQtSol == 0
					Exit
				EndIf
			EndIf
		Next nI
	EndIf


	//-- Carregas as exceções das atividades
	DLExcecoes(cTipoServ,cLocOrig,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,aExcecoesO,aExcecoesD)

	DbSelectArea('SB1')
	If Rastro(cProduto) .And. Empty(cLoteCtl)
		If cTipoServ == '3' //-- Inicializa Lote e Sublote para servicos de Mov.Interno
			DbSelectArea('SBF')
			DbSetOrder(6) //-- BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_ESTFIS+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If MsSeek(xFilial('SBF')+cLocOrig+cEndOrig+cEstOrig+cProduto, .F.)
				cLoteCtl := BF_LOTECTL
				cNumLote := BF_NUMLOTE
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa as Atividades (SX5 - Tab L6) Referentes a Tarefa Desejada     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea('DC6')
	DC6->(DbSetOrder(1))
	If DC6->(MsSeek(cSeek:=xFilial('DC6')+cTarefa, .F.))
		Do While DC6->(!Eof() .And. cSeek==DC6_FILIAL+DC6_TAREFA)
			AAdd(aAtivExec,{DC6->DC6_ATIVID,DC6->DC6_ORDEM,DC6->DC6_FUNCAO,DC6->DC6_TPREC})
			DC6->(DbSkip())
		EndDo
	EndIf

	cIdMovto := WMSProxSeq("MV_WMSSEQ","DB_IDMOVTO")
	While Len(aParam) < 34
		AAdd(aParam,"")
	EndDo
	aParam[34] := cIdMovto

	For nCntAtiv := 1 To Len(aAtivExec)
		cAtividade := aAtivExec[nCntAtiv][1]
		cOrdAti    := aAtivExec[nCntAtiv][2]
		cRHumano   := aAtivExec[nCntAtiv][3]
		cRFisico   := aAtivExec[nCntAtiv][4]

		lNoExcec   := .T.
		If cTipoServ == '1' //-- Nas Entradas, verifica as Excecoes nos Enderecos Destino (Ex.: DOCA->Picking)
			lNoExcec := AScan(aExcecoesD, cAtividade) == 0
		ElseIf cTipoServ == '2' //-- Nas Saidas, verifica as Excecoes nos Enderecos Origem (Ex.: Picking->DOCA)
			lNoExcec := AScan(aExcecoesO, cAtividade) == 0
		ElseIf cTipoServ == '3' //-- Nos Movtos.Internos, verifica as Excecoes nos Enderecos Destino ou Origem
			//Se possuir mais de uma atividade, e for a primeira, deve verificar apenas na origem
			If Len(aAtivExec) > 1 .And. nCntAtiv == 1
				lNoExcec := AScan(aExcecoesO, cAtividade) == 0
			//Se possuir mais de uma atividade, e for a ultima, deve verificar apenas no destino
			ElseIf Len(aAtivExec) > 1 .And. nCntAtiv == Len(aAtivExec)
				lNoExcec := AScan(aExcecoesD, cAtividade) == 0
			ElseIf Len(aAtivExec) > 1
				lNoExcec := AScan(aExcecoesO, cAtividade) == 0 .Or. AScan(aExcecoesD, cAtividade) == 0
			EndIf
		EndIf
		If lNoExcec //-- Se nao houverem excecoes
			//-- Ponto de entrada para identificar se grava atividade ou nao
			If lDLGGATV
				lGravaSDB := ExecBlock('DLGGATV',.F.,.F.,{cProduto,cLocOrig,nQuant,cEndOrig,cNumSerie,cDoc,cSerie,cCliFor,cLoja,cTipoNF,cOrigLan,dData,cLoteCtl,cNumLote,cNumSeq,cTm,cItem,cEstOrig,cServico,cTarefa,cAtividade,cEstDest,cEndDest,cHora,cCarga,cUnitiz,cOrdTar,cOrdAti,cRHumano,cRFisico})
				If ValType(lGravaSDB) != "L"
					lGravaSDB:=.T.
				EndIf
			EndIf
			If lGravaSDB
				CriaSDB(cProduto,cLocOrig,nQuant,cEndOrig,cNumSerie,cDoc,cSerie,cCliFor,cLoja,cTipoNF,cOrigLan,dData,cLoteCtl,cNumLote,cNumSeq,cTm,cTipo,cItem,.F.,Nil,Nil,Nil,cEstOrig,cServico,cTarefa,cAtividade,'',cEstDest,cEndDest,cHora,'N',cCarga,cUnitiz,cOrdTar,cOrdAti,cRHumano,cRFisico,/*cSeqCar*/,cIdDCF,/*nRecnoSDB*/,cIdMovto)
				//Grava array com as movimentações SDB que precisam ter o reabastecimento verificado
				If Type("aValReab")=="A" .And. SDB->DB_ATUEST == 'N' .And. Val(cTm) > 500
					AAdd(aValReab,{SDB->(Recno())})
				EndIf
			EndIf
		EndIf

		//-- Ponto de entrada apos executar tarefa
		If lDLGEXETA
			ExecBlock('DLGEXETA',.F.,.F.,{cProduto,cLocOrig,nQuant,cEndOrig,cNumSerie,cDoc,cSerie,cCliFor,cLoja,cTipoNF,cOrigLan,dData,cLoteCtl,cNumLote,cNumSeq,cTm,cItem,cEstOrig,cServico,cTarefa,cEstDest,cEndDest,cHora,cCarga,cUnitiz,cOrdTar})
		EndIf
	Next

	// Zera as quantidades distribuídas nesta movimentação
	If Type("aAgluDCF") == "A" .And. !Empty(aAgluDCF) .And. 'DLGXABAST()' != Upper(cFunExe)
		nOrdTar:= Len(aAgluDCF[1][4]) //A ordem da tarefa é a útilma adicionada no array.
		For nI := 1 To Len(aAgluDCF)
		   aAgluDCF[nI][4][nOrdTar][4] := 0
		Next nI
	EndIf

	RestArea(aAreaSBF)
	RestArea(aAreaDC5)
	RestArea(aAreaDC6)
	RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLXCfgEnd ³ Autor ³ Alex Egydio           ³ Data ³08.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os Niveis Contidos no Codigo do Endereco, de acordo³±±
±±³          ³ com o arq. Configuracao do Codigo de Endereco.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLXCfgEnd(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Configuracao do Endereco                 ³±±
±±³          ³ ExpC2 = Codigo do Endereco                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 = Array com os Niveis da Configuracao de Endereco    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLXCfgEnd(cCodCfg,cEndereco)

Static __aCfgEnd := {}
Static __aAlpha  := {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}

Local aAreaAnt  := GetArea()
Local aRet      := {}
Local aCfgTmp   := Array(2)
Local nCntFor   := 1
Local nPos      := 0
Local nCnt1     := 0
Local nCnt2     := 0
Local cStr1     := ''
Local cStr2     := ''
Local cLetra    := ''
Local cQuery    := ''
Local cAliasDC7 := ''
Local nTamNiv   := TamSx3('BE_VALNV1')[1]

Default cCodCfg   := CriaVar('DC7_CODCFG', .F.)
Default cEndereco := CriaVar('BE_LOCALIZ', .F.)

	//-- Formato do Array aRet:
	//-- aRet[n,1] = Codigo do Endereco separado por Nivel
	//-- aRet[n,2] = Peso do Nivel (Deve ser DESCONSIDERADO para o ultimo Nivel)
	//-- aRet[n,3] = Peso do Lado

	If Len(__aCfgEnd) > 0 .And. (nPos:=AScan(__aCfgEnd, {|x|x[1]==cCodCfg}))>0
		aCfgTmp := __aCfgEnd[nPos]
	Else
		aCfgTmp[1] := cCodCfg
		aCfgTmp[2] := {} //Array vazio
		cAliasDC7 := GetNextAlias()
		cQuery := "SELECT DC7_POSIC,DC7_PESO1,DC7_PESO2"
		cQuery += "  FROM "+RetSqlName('DC7')+" DC7"
		cQuery += " WHERE DC7_FILIAL = '"+xFilial('DC7')+"'"
		cQuery += "   AND DC7_CODCFG = '"+cCodCfg+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY DC7_SEQUEN,DC7_POSIC,DC7_PESO1,DC7_PESO2"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDC7,.F.,.T.)
		Do While (cAliasDC7)->(!Eof())
			AAdd(aCfgTmp[2],{(cAliasDC7)->DC7_PESO2, (cAliasDC7)->DC7_PESO1,(cAliasDC7)->DC7_POSIC})
			(cAliasDC7)->(DbSkip())
		EndDo
		(cAliasDC7)->(DbCloseArea())
		AAdd(__aCfgEnd,aCfgTmp)
	EndIf

	For nCnt1 := 1 To Len(aCfgTmp[2])
		cStr1 := AllTrim(Upper(SubStr(cEndereco,nCntFor,aCfgTmp[2,nCnt1,3])))
		cStr2 := ''
		//Transforma a configuração em números seguindo a ordem no ARRAy
		// -> 000 -> '0' = 01 + '0' = 01 + '0' = 01 -> '010101'
		// -> R01 -> 'R' = 28 + '0' = 01 + '1' = 02 -> '280102'
		// -> ZR5 -> 'Z' = 36 + 'R' = 28 + '5' = 06 -> '362806'
		// -> ZZZ -> 'Z' = 36 + 'Z' = 36 + 'Z' = 36 -> '363636'
		For nCnt2 := 1 To Len(cStr1)
			cLetra := SubStr(cStr1, nCnt2, 1)
			nPos   := AScan(__aAlpha, {|x|x==cLetra})
			cStr2  += StrZero(nPos,2)
		Next
		AAdd(aRet, {Val(substr(cStr2,1,nTamNiv)), aCfgTmp[2,nCnt1,1], aCfgTmp[2,nCnt1,2]})
		nCntFor += aCfgTmp[2,nCnt1,3]
	Next
	If Len(aRet)==0
		WmsMessage(STR0038+AllTrim(cEndereco)+' / '+STR0028+AllTrim(cCodCfg)+STR0029,'DLGXFUN10',1) //'Endereco '###'Codigo de Configuracao de Enderecos '###' nao cadastrado (DC7).'
	EndIf
	RestArea(aAreaAnt)
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLXPicEnd ³ Autor ³ Alex Egydio           ³ Data ³08.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os Niveis Contidos no Codigo do Endereco, de acordo³±±
±±³          ³ com o arq. Configuracao do Codigo de Endereco.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLXPicEnd(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Configuracao do Endereco                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC2 = String com a mascara do endereco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLXPicEnd(cCodCfg, lShowMsg)

Local aAreaAnt   := GetArea()
Local aAreaDC7   := DC7->(GetArea())
Local cRet       := ''
Local cSeek      := ''

Default cCodCfg    := ''
Default lShowMsg   := .F.
	DbSelectArea('DC7')
	DC7->(DbSetOrder(1))
	If DC7->(MsSeek(cSeek:=xFilial('DC7')+cCodCfg, .F.))
		Do While DC7->(!Eof() .And. cSeek==DC7_FILIAL+DC7_CODCFG)
			cRet += If(Empty(cRet),'','.')
			cRet += Replicate('!',DC7->DC7_POSIC)
			DC7->(DbSkip())
		EndDo
		cRet := '@r '+cRet
	Else
		If lShowMsg
			DLAviso(.F., 'DLGXFUN10',STR0028+AllTrim(cCodCfg)+STR0029) //'Codigo de Configuracao de Enderecos '###' nao cadastrado (DC7).'
		EndIf
		cRet := '@!'
	EndIf
	RestArea(aAreaDC7)
	RestArea(aAreaAnt)
Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLAviso   ³ Autor ³ Fernando Joly Siquini ³ Data ³09.04.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Emite um Aviso Com ou Sem Radio Frequencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLAviso(ExpL1, ExpC1, ExpC2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = .T. Utiliza Radio Frequencia, .F. Nao utiliza      ³±±
±±³          ³ ExpC1 = Titulo da Mensagem                                 ³±±
±±³          ³ ExpC1 = Mensagem a ser emitida                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLAviso(lRadioF, cTitulo, cString)
Default lRadioF    := (SuperGetMV('MV_RADIOF')=='S')
Default cTitulo    := ''
Default cString    := ''
	If Len(cTitulo)+Len(cString)>0
		If lRadioF .And. ISTelNet()
			VTAlert(cString, cTitulo, .T.)
		Else
			Aviso(cTitulo, cString, {'Ok'})
		EndIf
	EndIf
Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DLQtdNorma³Autor  ³Fernando J. Siquini   ³ Data ³  06/30/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Retorna a Quantidade de Produtos (na 1a U.M.) definida na  ³±±
±±³          ³ Norma de Unitizacao.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do produto                                  ³±±
±±³          ³ ExpC2 - Armazem                                            ³±±
±±³          ³ ExpC3 - Codigo da estrutura fisica                         ³±±
±±³          ³ ExpC4 - Descricao do unitizador    (@)                     ³±±
±±³          ³ ExpL1 - .T. = Quantos unitizadores cabem em um endereco    ³±±
±±³          ³               blocado fracionado.                          ³±±
±±³          ³         .F. = Quantos produtos (na 1a.U.M.) cabem em um    ³±±
±±³          ³               unitizador.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DLQtdNorma(cProduto, cLocal, cEstruFis, cDesUni, lNUnit, cEndereco, cCodNorma)

Static lLastroPE  := ExistBlock("DLLASTRO")
Static lCamadaPE  := ExistBlock("DLCAMADA")
Static lQtdUnitPE := ExistBlock("DLQTDUNI")
Local lChangeDC3  := .F.
Local lDC8SBEUni  := (WmsX312120("DC8","DC8_NRUNIT") .And. WmsX312120("SBE","BE_NRUNIT"))
Local lNNRUni     := WmsX312120("NNR","NNR_AMZUNI")
Local aAreaAnt    := GetArea()
Local aDC3_NUNITI := GetWmsSX3("DC3_NUNITI")
Local aB1_CONV    := GetWmsSX3("B1_CONV")
Local cAliasQry   := Nil
Local cAliasQr1   := Nil
Local cAliasQr2   := Nil
Local cCampos     := ""
Local cUMInd      := ""
Local nLastro     := 0
Local nLastroPE   := 0
Local nCamada     := 0
Local nCamadaPE   := 0
Local nQtdUnit    := 1
Local nQtdUnitPE  := 1
Local nPorcOcup   := 0
Local nFatConv    := 0
Local nRet        := 0

Default lNUnit   := .T.
Default cEndereco:= ""
Default cCodNorma:= ""
Default cDesUni  := ""
	// Quando número de unitizadores é controlado pela estrutura física ou endereço
	cCampos :=   IIf(lNNRUni," CASE WHEN NNR.NNR_AMZUNI IS NULL THEN '2' ELSE NNR.NNR_AMZUNI END NNR_AMZUNI"," 2 NNR_AMZUNI")
	cCampos := "%"+cCampos+"%"
	cAliasQry := GetNextAlias()
	If lDC8SBEUni
		BeginSql Alias cAliasQry
			SELECT DC3.DC3_CODNOR,
					DC8.DC8_TPESTR,
					DC3.DC3_NUNITI,
					CASE WHEN DC8.DC8_NRUNIT IS NULL THEN 0 ELSE DC8.DC8_NRUNIT END DC8_NRUNIT,
					CASE WHEN SBE.BE_NRUNIT IS NULL THEN 0 ELSE SBE.BE_NRUNIT END BE_NRUNIT,
					SB1.B1_CONV,
					(SELECT SB5.B5_UMIND
						FROM %Table:SB5% SB5
						WHERE SB5.B5_FILIAL = %xFilial:SB5%
						AND SB5.B5_COD = DC3.DC3_CODPRO
						AND SB5.%NotDel%) B5_UMIND,
					%Exp:cCampos%
			FROM %Table:DC3% DC3
			INNER JOIN %Table:NNR% NNR
			ON NNR.NNR_FILIAL = %xFilial:NNR%
			AND NNR.NNR_CODIGO = DC3.DC3_LOCAL
			AND NNR.%NotDel%
			INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = DC3.DC3_CODPRO
			AND SB1.%NotDel%
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = DC3.DC3_TPESTR
			AND DC8.%NotDel%
			LEFT JOIN %Table:SBE% SBE
			ON SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = DC3.DC3_LOCAL
			AND SBE.BE_LOCALIZ = %Exp:cEndereco%
			AND SBE.BE_ESTFIS = DC3.DC3_TPESTR
			AND SBE.%NotDel%
			WHERE DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_CODPRO = %Exp:cProduto%
			AND DC3.DC3_LOCAL =  %Exp:cLocal%
			AND DC3.DC3_TPESTR = %Exp:cEstruFis%
			AND DC3.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DC3.DC3_CODNOR,
					DC8.DC8_TPESTR,
					DC3.DC3_NUNITI,
					0 DC8_NRUNIT,
					0 BE_NRUNIT,
					SB1.B1_CONV,
					(SELECT SB5.B5_UMIND
						FROM %Table:SB5% SB5
						WHERE SB5.B5_FILIAL = %xFilial:SB5%
						AND SB5.B5_COD = DC3.DC3_CODPRO
						AND SB5.%NotDel%) B5_UMIND,
					%Exp:cCampos%
			FROM %Table:DC3% DC3
			INNER JOIN %Table:NNR% NNR
			ON NNR.NNR_FILIAL = %xFilial:NNR%
			AND NNR.NNR_CODIGO = DC3.DC3_LOCAL
			AND NNR.%NotDel%
			INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = DC3.DC3_CODPRO
			AND SB1.%NotDel%
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = DC3.DC3_TPESTR
			AND DC8.%NotDel%
			WHERE DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_CODPRO = %Exp:cProduto%
			AND DC3.DC3_LOCAL =  %Exp:cLocal%
			AND DC3.DC3_TPESTR = %Exp:cEstruFis%
			AND DC3.%NotDel%
		EndSql
	EndIf
	TcSetField(cAliasQry,'DC3_NUNITI','N',aDC3_NUNITI[1],aDC3_NUNITI[2])
	TcSetField(cAliasQry,'DC8_NRUNIT','N',aDC3_NUNITI[1],aDC3_NUNITI[2])
	TcSetField(cAliasQry,'BE_NRUNIT' ,'N',aDC3_NUNITI[1],aDC3_NUNITI[2])
	TcSetField(cAliasQry,'B1_CONV'   ,'N',aB1_CONV[1]   ,aB1_CONV[2])
	If (cAliasQry)->(!Eof())
		lChangeDC3 := .T.
		cUMInd   := IIf(Empty((cAliasQry)->B5_UMIND)," ",(cAliasQry)->B5_UMIND)
		nFatConv := (cAliasQry)->B1_CONV
		If lNUnit
			// Quando armazém controla unitizador e a estrutura física não for 2-Picking ou 7-Produção
			// Irá verificar o número de unitizadores cadastrado na estrutura física e no endereço
			// Caso contrário irá verificar na sequencia de abastecimento do produto
			If lDC8SBEUni .And. (cAliasQry)->NNR_AMZUNI == '1' .And. !((cAliasQry)->DC8_TPESTR $ "2|7")
				If (cAliasQry)->DC8_NRUNIT > 0
					nQtdUnit := (cAliasQry)->DC8_NRUNIT
					If !Empty(cEndereco) .And. (cAliasQry)->BE_NRUNIT > 0
						nQtdUnit := (cAliasQry)->BE_NRUNIT
					EndIf
				EndIf
			Else
				If (cAliasQry)->DC3_NUNITI > 0
					nQtdUnit := (cAliasQry)->DC3_NUNITI
				EndIf
			EndIf
		EndIf
		If Empty(cCodNorma)
			cCodNorma := (cAliasQry)->DC3_CODNOR
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())

	If lQtdUnitPE
		If ValType(nQtdUnitPE:=ExecBlock('DLQTDUNI',.F.,.F.,{cProduto,cLocal,cEstruFis,nQtdUnit,lNUnit}))=='N'
			nQtdUnit := nQtdUnitPE
		EndIf
	EndIf

	If lLastroPE .And. lCamadaPE .And. (ValType(nLastroPE:=ExecBlock('DLLASTRO',.F.,.F.,{cProduto,cLocal,cEstruFis}))=='N') .And. (ValType(nCamadaPE:=ExecBlock('DLCAMADA',.F.,.F.,{cProduto,cLocal,cEstruFis}))=='N')
		nLastro := nLastroPE
		nCamada := nCamadaPE
	Else
		If lChangeDC3
			cAliasQry := GetNextAlias()
			If ValType(cDesUni)=='C'
				BeginSql Alias cAliasQry
					SELECT DC2.DC2_LASTRO,
							DC2.DC2_CAMADA,
							DC2.DC2_CODUNI,
							CASE WHEN D0T.D0T_DESUNI IS NULL THEN ' ' ELSE D0T_DESUNI END D0T_DESUNI
					FROM %Table:DC2% DC2
					LEFT JOIN %Table:D0T% D0T
					ON D0T.D0T_FILIAL = %xFilial:D0T%
					AND D0T.D0T_CODUNI = DC2.DC2_CODUNI
					AND D0T.%NotDel%
					WHERE DC2.DC2_FILIAL = %xFilial:DC2%
					AND DC2.DC2_CODNOR = %Exp:cCodNorma%
					AND DC2.%NotDel%
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT DC2.DC2_LASTRO,
							DC2.DC2_CAMADA,
							DC2.DC2_CODUNI,
							'' D0T_DESUNI
					FROM %Table:DC2% DC2
					WHERE DC2.DC2_FILIAL = %xFilial:DC2%
					AND DC2.DC2_CODNOR = %Exp:cCodNorma%
					AND DC2.%NotDel%
				EndSql
			EndIf
			If (cAliasQry)->(!Eof())
				If lLastroPE .And. ValType(nLastroPE:=ExecBlock('DLLASTRO',.F.,.F.,{cProduto,cLocal,cEstruFis})) == 'N'
					nLastro := nLastroPE
				Else
					nLastro := (cAliasQry)->DC2_LASTRO
				EndIf
				If lCamadaPE .And. ValType(nCamadaPE:=ExecBlock('DLCAMADA',.F.,.F.,{cProduto,cLocal,cEstruFis})) == 'N'
					nCamada := nCamadaPE
				Else
					nCamada := (cAliasQry)->DC2_CAMADA
				EndIf
				cDesUni := (cAliasQry)->D0T_DESUNI

				If !Empty(cEndereco)
					// Pesquisa se existe % de ocupacao cadastrado para este endereco para o produto.
					cAliasQr1 := GetNextAlias()
					BeginSql Alias cAliasQr1
						SELECT DCP.DCP_PORCEN
						FROM %Table:DCP% DCP
						WHERE DCP.DCP_FILIAL = %xFilial:DCP%
						AND DCP.DCP_LOCAL = %Exp:cLocal%
						AND DCP.DCP_ENDERE = %Exp:cEndereco%
						AND DCP.DCP_ESTFIS = %Exp:cEstruFis%
						AND DCP.DCP_NORMA = %Exp:cCodNorma%
						AND DCP.DCP_CODPRO = %Exp:cProduto%
						AND DCP.%NotDel%
					EndSql
					If (cAliasQr1)->(!Eof())
						nPorcOcup := (cAliasQr1)->DCP_PORCEN
					Else
						// Pesquisa se existe % de ocupacao cadastrado para este endereco, para qualquer produto.
						cAliasQr2 := GetNextAlias()
						BeginSql Alias cAliasQr2
							SELECT DCP.DCP_PORCEN
							FROM %Table:DCP% DCP
							WHERE DCP.DCP_FILIAL = %xFilial:DCP%
							AND DCP.DCP_LOCAL = %Exp:cLocal%
							AND DCP.DCP_ENDERE = %Exp:cEndereco%
							AND DCP.DCP_ESTFIS = %Exp:cEstruFis%
							AND DCP.DCP_NORMA = %Exp:cCodNorma%
							AND DCP.%NotDel%
						EndSql
						If (cAliasQr2)->(!Eof())
							nPorcOcup := (cAliasQr2)->DCP_PORCEN
						EndIf
						(cAliasQr2)->(dbCloseArea())
					EndIf
					(cAliasQr1)->(dbCloseArea())
				EndIf
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf
	nRet := nLastro * nCamada * nQtdUnit
	If nPorcOcup > 0
		nRet := Int(nRet * nPorcOcup/100)
	EndIf

	If !cUMInd == '1' .And. QtdComp(nFatConv) <> QtdComp(0)
		nRet := ConvUm(cProduto, 0, nRet, 1)
	EndIf
	RestArea(aAreaAnt)
Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DLTipoEnd ºAutor  ³Fernando J. Siquini º Data ³  08/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o Tipo de Estrutura a qual o Endereco Pertence     º±±
±±º          ³ 1=Pulmao                                                   º±±
±±º          ³ 2=Picking                                                  º±±
±±º          ³ 3=Cross Docking                                            º±±
±±º          ³ 4=Blocado                                                  º±±
±±º          ³ 5=Box/Doca                                                 º±±
±±º          ³ 6=Blocado Fracionado                                       º±±
±±º          ³ 7=Dispositivo de movimentacao (carrinho)                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLTipoEnd(cEst)
Local nRet      := 0
Local cAliasQry := Nil
	If !Empty(cEst)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DC8.DC8_TPESTR
			FROM %Table:DC8% DC8
			WHERE DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = %Exp:cEst%
			AND DC8.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			nRet := Val((cAliasQry)->DC8_TPESTR)
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlgxCliFor³ Autor ³ Alex Egydio           ³ Data ³24.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3 no Arq. de Clientes ou Fornecedor              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DlgxCliFor()               SXB( DL2 )                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DlgxCliFor()

Static nOpcDefaul := 0

Local cArqF3     := ''
Local lRet       := .F.
Local nOpc       := 1
Local oDlgEsp
	If Upper(__ReadVar) == 'MV_PAR11' .And. nOpcDefaul>0
		cArqF3 := {"CLI", "SA2"}[nOpcDefaul]
	Else
		DEFINE MSDIALOG oDlgEsp TITLE '' FROM 10,12 to 21,45
		@ 05, 005 TO 65, 130 LABEL '' OF oDlgEsp PIXEL
		@ 10, 030 RADIO nOpc ITEMS STR0030, STR0031 3D SIZE 75, 015 OF oDlgEsp PIXEL //'&Cliente'###'&Fornecedor'
		DEFINE SBUTTON FROM 68, 030 TYPE 1 ACTION (oDlgEsp:End(), cArqF3:={'CLI', 'SA2'}[nOpc]) ENABLE OF oDlgEsp
		DEFINE SBUTTON FROM 68, 070 TYPE 2 ACTION (oDlgEsp:End()) ENABLE OF oDlgEsp
		ACTIVATE MSDIALOG oDlgEsp CENTERED
		nOpcDefaul := nOpc
	EndIf

	lRet := ConPad1(,,, cArqF3,,, .F.)

	If lRet .And. Type('M->DCF_LOJA') == 'C'
		M->DCF_LOJA := {SA1->A1_LOJA, SA2->A2_LOJA}[nOpc]
	EndIf
Return lRet

/*/{Protheus.doc} DLPergWMS
Exibe uma tela onde deverá ser informado o serviço e endereço WMS para o processo
@author Jackson Patrick Werka
@since 15/09/2014

@param cServWMS, Caracter, Código do serviço, retorna por referencia @cServWMS
@param cEndOrig, Caracter, Código do endereço, retorna por referencia @cEndOrig
@param [lSuggest], Lógico, Indica que sugere as informações na tela
@param [lForce], Lógico, Indica se é obrigatório informar os dados de endereço
@param [cTipServ], Caracter, Tipo do serviço: 1- Entrada, 2- Saída, 3- Interno

@return Lógico Indicador se os dados foram informados corretamente
/*/
Function DLPergWMS(cServWMS,cEnderWMS, lSuggest, lForce, cTipServ,cArmazWMS)
Local cServico  := CriaVar('DCF_SERVIC',.F.)
Local cArmazem  := CriaVar('BE_LOCAL',.F.)
Local cEndereco := CriaVar('BE_LOCALIZ',.F.)
Local lCancel   := .F.
Local oDlg, oBtn, aTela
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lRet      := .T.

Default lSuggest  := .T.
Default lForce    := .F.
Default cTipServ  := '3'
Default cArmazWMS := ""

	//-- Posiciona no cadastro de armazens
	NNR->(dbSetOrder(1))
	NNR->(dbSeek(xFilial("NNR")+cArmazWMS))
	cArmazem := NNR->NNR_CODIGO

	If lSuggest
		If !Empty(cServWMS)
			cServico := cServWMS
		EndIf
		If !Empty(cEnderWMS)
			cEndereco := cEnderWMS
		EndIf
	EndIf

	If IsTelNet()
		aTela := VtSave()
		Do While .T.
			VTClear()
			WMSVTCabec('SIGAWMS', .F., .F., .T.)
			@ 01,00 VTSay AllTrim(RetTitle('DCF_SERVIC'))+':'
			@ 02,00 VtGet cServico Pict "@!" Valid VldServWMS(cServico,lForce,cTipServ,.T.)
			@ 03,00 VTSay AllTrim(RetTitle('BE_LOCAL'))+': '+cArmazem
			@ 04,00 VTSay AllTrim(RetTitle('BE_LOCALIZ'))+':'
			@ 05,00 VtGet cEndereco Pict "@!" Valid VldEndWMS(cArmazem,cEndereco,lForce,cTipServ,.T.)
			VtRead()
			If VTLastKey() == 27
				If !VldInfoWMS(cServico,cArmazem,cEndereco,lForce,cTipServ,.F.)
					Loop
				Else
					lCancel := .T.
					Exit
				EndIf
			Else
				If !VldInfoWMS(cServico,cArmazem,cEndereco,lForce,cTipServ,.T.)
					Loop
				Else
					lCancel := .F.
					Exit
				EndIf
			EndIf
		EndDo
		VtRestore(,,,,aTela)
	Else
		DEFINE MSDIALOG oDlg STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE ) FROM 0, 0 TO 165, 295 TITLE 'SIGAWMS' PIXEL
		@ 10, 10 SAY   AllTrim(RetTitle('DCF_SERVIC'))+':' OF oDlg PIXEL
		@ 10, 50 MSGET cServico VALID VldServWMS(cServico,lForce,cTipServ,.T.) F3 'DC5' OF oDlg PICTURE '@!' PIXEL
		@ 28, 10 SAY   AllTrim(RetTitle('BE_LOCAL'))+':' OF oDlg PIXEL
		@ 28, 50 MSGET cArmazem WHEN .F. OF oDlg PICTURE '@!' PIXEL
		@ 46, 10 SAY   AllTrim(RetTitle('BE_LOCALIZ'))+':' OF oDlg PIXEL
		@ 46, 50 MSGET cEndereco VALID VldEndWMS(cArmazem,cEndereco,lForce,cTipServ,.T.) F3 'SBELOC' OF oDlg PICTURE '@!' PIXEL

		@ 064,100 BUTTON oBtn PROMPT STR0077 SIZE 040,012 OF oDlg PIXEL; //"Cancelar"
		ACTION (Iif(VldInfoWMS(cServico,cArmazem,cEndereco,lForce,cTipServ,.F.),(oDlg:End(),lCancel:=.T.),/*Não faz nada*/))
		@ 064,058 BUTTON oBtn PROMPT STR0076 SIZE 040,012 OF oDlg PIXEL; //"Confirmar"
		ACTION (Iif(VldInfoWMS(cServico,cArmazem,cEndereco,.T.,cTipServ,.T.),(oDlg:End(),lCancel:=.F.),/*Não faz nada*/))

		oDlg:lEscClose := .F.
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

	//Se não informou o serviço WMS
	If Empty(cServico)
		cServWMS  := CriaVar('DCF_SERVIC',.F.)
		cEnderWMS := CriaVar('BE_LOCALIZ',.F.)
	Else
		If lCancel
			cServWMS  := cServico
			cEnderWMS := CriaVar('BE_LOCALIZ',.F.)
		Else
			cServWMS  := cServico
			cEnderWMS := cEndereco
		EndIf
	EndIf

	// Só deve avaliar se o serviço e o endereço foram preenchidos no caso do WMS Novo
	If lWmsNew
		lRet := !Empty(cServWMS) .And. !Empty(cEnderWMS)
	EndIf
Return lRet

/*/{Protheus.doc} DLPergServ
Exibe uma tela onde deverá ser informado o serviço WMS para o processo
@author Flavio Luiz Vicco
@since 01/04/2009

@param cServWMS, Caracter, Código do serviço, retorna por referencia @cServWMS
@param [lSuggest], Lógico, Indica que sugere as informações na tela
@param [lForce], Lógico, Indica se é obrigatório informar os dados de endereço
@param [cTipServ], Caracter, Tipo do serviço: 1- Entrada, 2- Saída, 3- Interno

@return Lógico Indicador se os dados foram informados corretamente
/*/
Function DLPergServ(cServWMS, lSuggest, lForce, cTipServ)
Local cServico := CriaVar('DCF_SERVIC',.F.)
Local lCancel  := .F.
Local oDlg, oBtn

Default lSuggest := .T.
Default lForce   := .F.

	If lSuggest
		If !Empty(cServWMS)
			cServico := cServWMS
		EndIf
	EndIf

	DEFINE MSDIALOG oDlg STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE ) FROM 0, 0 TO 125, 295 TITLE 'SIGAWMS' PIXEL
	@ 10, 10 SAY STR0094 OF oDlg PIXEL //"Informe o código do Serviço WMS:"
	@ 25, 10 SAY AllTrim(RetTitle('DCF_SERVIC'))+':' OF oDlg PIXEL
	@ 25, 50 MSGET cServico VALID VldServWMS(cServico,lForce,cTipServ,.T.) F3 'DC5' OF oDlg PIXEL

	@ 043,100 BUTTON oBtn PROMPT STR0077 SIZE 040,012 OF oDlg PIXEL; //"Cancelar"
	ACTION (Iif(VldServWMS(cServico,lForce,cTipServ,.F.),(oDlg:End(),lCancel:=.T.),/*Não faz nada*/))
	@ 043,058 BUTTON oBtn PROMPT STR0076 SIZE 040,012 OF oDlg PIXEL; //"Confirmar"
	ACTION (Iif(VldServWMS(cServico,.T.,cTipServ,.T.),(oDlg:End(),lCancel:=.F.),/*Não faz nada*/))

	oDlg:lEscClose := .F.
	ACTIVATE MSDIALOG oDlg CENTERED

	//Se não informou o serviço WMS
	If Empty(cServico) .Or. lCancel
		cServWMS := CriaVar('DCF_SERVIC',.F.)
	Else
		cServWMS := cServico
	EndIf
Return !Empty(cServWMS)

/*/{Protheus.doc} DLPergEnd
Exibe uma tela onde deverá ser informado o endereço WMS para o processo
@author Fernando J. Siquini
@since 02/04/2004

@param cEndOrig, Caracter, Código do endereço, retorna por referencia @cEndOrig
@param [lSuggest], Lógico, Indica que sugere as informações na tela
@param [lForce], Lógico, Indica se é obrigatório informar os dados de endereço
@param [cTipServ], Caracter, Tipo do serviço: 1- Entrada, 2- Saída, 3- Interno
@param [cArmazWMS], Caracter, Código do armazem

@return Lógico Indicador se os dados foram informados corretamente
/*/
Function DLPergEnd(cEnderWMS, lSuggest, lForce, cTipServ, cArmazWMS)
Local aAreaAnt  := {}
Local cEndereco := CriaVar('BE_LOCALIZ',.F.)
Local cTitle    := "SIGAWMS"
Local cString   := ""
Local lCancel   := .F.
Local cSeek     := ""
Local cTipoMov  := ""
Local oDlg, oBtn

Default lSuggest  := .T.
Default lForce    := .F.
Default cTipServ  := '3'
Default cArmazWMS := ""

	//-- Posiciona no cadastro de armazens
	NNR->(dbSetOrder(1))
	NNR->(dbSeek(xFilial("NNR")+cArmazWMS))
	cArmazem := NNR->NNR_CODIGO

	If lSuggest
		If !Empty(cEnderWMS)
			cEndereco := cEnderWMS
		EndIf
	EndIf

	If Type("aParam150") == "A"
		If aParam150[17] == 'SD3'
			aAreaAnt := SD3->(GetArea())
			SD3->(DbSetOrder(3))
			SD3->(MsSeek(cSeek := xFilial('SD3')+aParam150[01]+aParam150[02]+aParam150[05], .F.))

			Do While SD3->(!Eof() .And. cSeek == D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ)
				If !Empty(SD3->D3_SERVIC)
					cTipoMov := SD3->D3_TM
				EndIf
				SD3->(DbSkip())
			EndDo
			RestArea(aAreaAnt)

			If !Empty(cTipoMov)
				SB5->(DbSetOrder(1))
				SB5->(MsSeek(xFilial("SB5")+aParam150[01]))

				If cTipoMov > '500'
					cEndereco := SB5->B5_ENDREQ
				Else
					cEndereco := SB5->B5_ENDDEV
				EndIf
			EndIf
		EndIf
	EndIf

	If IsInCallStack('WmsExeDCF')
		cTitle += Iif(WmsCarga(DCF->DCF_CARGA)," - "+Trim(RetTitle("DCF_CARGA"))+": "+Trim(DCF->DCF_CARGA)," - "+Trim(RetTitle("DCF_DOCTO"))+": "+Trim(DCF->DCF_DOCTO))
	EndIf

	cString := Iif(cTipServ=='1',STR0079,STR0082) //Identifique a origem do Serviço WMS:/Identifique o destino do Serviço WMS:

	DEFINE MSDIALOG oDlg STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE ) FROM 0, 0 TO 140, 295 TITLE cTitle PIXEL
	@ 10, 10 SAY   AllTrim(cString)                    OF oDlg PIXEL
	@ 25, 10 SAY   AllTrim(RetTitle('BE_LOCAL'))+':' OF oDlg PIXEL
	@ 25, 50 MSGET cArmazem WHEN .F. OF oDlg PIXEL
	@ 40, 10 SAY   AllTrim(RetTitle('BE_LOCALIZ'))+':' OF oDlg PIXEL
	@ 40, 50 MSGET cEndereco VALID VldEndWMS(cArmazem,cEndereco,lForce,cTipServ,.T.) F3 'SBELOC' OF oDlg PICTURE '@!' PIXEL

	@ 058,100 BUTTON oBtn PROMPT STR0077 SIZE 040,012 OF oDlg PIXEL; //"Cancelar"
	ACTION (Iif(VldEndWMS(cArmazem,cEndereco,lForce,cTipServ,.F.),(oDlg:End(),lCancel:=.T.),/*Não faz nada*/))
	@ 058,058 BUTTON oBack PROMPT STR0076 SIZE 040, 012 OF oDlg PIXEL; //"Confirmar"
	ACTION (Iif(VldEndWMS(cArmazem,cEndereco,.T.,cTipServ,.T.),(oDlg:End(),lCancel:=.F.),/*Não faz nada*/))

	oDlg:lEscClose := .F.
	ACTIVATE MSDIALOG oDlg CENTERED

	//Se não informou o endereço WMS
	If Empty(cEndereco) .Or. lCancel
		cEnderWMS := CriaVar('BE_LOCALIZ',.F.)
	Else
		cEnderWMS := cEndereco
	EndIf

Return !Empty(cEnderWMS)

/*------------------------------------------------------------------------------
Valida as informações de integração para serviços do WMS
------------------------------------------------------------------------------*/
Static Function VldInfoWMS(cServico,cArmazem,cEndereco,lForce,cTipServ,lConfirm)
Local lRet := .T.
	If !Empty(cServico)
		lRet := VldServWMS(cServico,.F.,cTipServ,lConfirm)
		lRet := lRet .And. VldEndWMS(cArmazem,cEndereco,lForce,cTipServ,lConfirm)
	EndIf
Return lRet
/*------------------------------------------------------------------------------
Valida as informações de serviço para serviços do WMS
@param [nProcValid], inteiro, Indica se será feita a validação do endereço/série, e o processo onde ocorrerá
a validação.
Opções:
0 - não valida; 1 - OP via sistema; 2 - OP via coletor; aqui poderão ser implementadas futuras
validações para outros endereços.
------------------------------------------------------------------------------*/
Static Function VldServWMS(cServico,lForce,cTipServ,lConfirm,nProcValid)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local aBoxDC5  := {}
Default nProcValid := 0

	If lConfirm .And. !Empty(cServico)
		DbSelectArea('DC5')
		DC5->(DbSetOrder(1))
		If DC5->(!MsSeek(xFilial('DC5')+cServico, .F.))
			Do Case
				Case nProcValid == 1
					WmsMessage(STR0118/*+STR0119*/,"SIGAWMS",1,.T.) //"Serviço de produção do produto informado não cadastrado. Verifique o serviço de produção no cadastro de complementos de produto, aba WMS."
				Case nProcValid == 2
					WmsMessage(STR0112+STR0114,"SIGAWMS",5,.T.) //"Serv. produção do produto não cadastrado. Verifique cadastro compl. produto WMS (WMSA090)."
				Otherwise
					WmsMessage(STR0032,"SIGAWMS",1,.T.) //"Serviço não cadastrado (DC5)."
			EndCase
			lRet := .F.
		Else
			If DC5->DC5_TIPO != cTipServ
				aBoxDC5 := StrTokArr(Posicione('SX3',2,'DC5_TIPO','X3CBox()'),';')
				Do Case
					Case nProcValid == 1
						WmsMessage(WmsFmtMsg(STR0120/*+STR0119*/,{{"[VAR01]",aBoxDC5[Val(cTipServ)]}}),"SIGAWMS",1,.T.) //"Serviço de produção do produto deve ser tipo [VAR01]. Verifique o serviço de produção no cadastro de complementos de produto, aba WMS."
					Case nProcValid == 2
						WmsMessage(WmsFmtMsg(STR0113+STR0114,{{"[VAR01]",aBoxDC5[Val(cTipServ)]}}),"SIGAWMS",5,.T.) //"Serv. produção do produto deve ser tipo [VAR01]. Verifique cadastro compl. produto WMS (WMSA090)."
					Otherwise
						WmsMessage(WmsFmtMsg(STR0037,{{"[VAR01]",aBoxDC5[Val(cTipServ)]}}),"SIGAWMS",1,.T.) //"O tipo do serviço informado deve ser [VAR01]." -> (entrada/saída/mov.interno)
				EndCase
				lRet := .F.
			EndIf
		EndIf
	ElseIf lForce
		Do Case
			Case nProcValid == 1
				WmsMessage(STR0121/*+STR0119*/,"SIGAWMS",1,.T.) //"Serviço de produção do produto não definido. Verifique o serviço de produção no cadastro complementos de produto, aba WMS."
			Case nProcValid == 2
				WmsMessage(STR0115+STR0114,"SIGAWMS",5,.T.) //"Serv. produção do produto não definido. Verifique cadastro compl. produto WMS (WMSA090)."
			Otherwise
				WmsMessage(STR0033,"SIGAWMS",1,.T.) //"É obrigatório informar o serviço WMS."
		EndCase
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
Valida as informações de endereço para serviços do WMS
@param [nProcValid], inteiro, Indica se será feita a validação do endereço/série e o processo onde ocorrerá
a validação.
Opções: 0 - não valida; 1 - OP via sistem; 2 - OP via coletor; aqui poderão ser implementadas futuras
validações para outros endereços.

------------------------------------------------------------------------------*/
Function VldEndWMS(cArmazem,cEndereco,lForce,cTipServ,lConfirm, nProcValid)
Local lRet := .T.
Default nProcValid := 0

	If lConfirm .And. !Empty(cEndereco)
		dbSelectArea('SBE')
		SBE->(dbSetOrder(1))
		If SBE->(!DbSeek(xFilial('SBE')+cArmazem+cEndereco, .F.))
			Do Case
				Case nProcValid == 1
					WmsMessage(STR0110/*+STR0111*/,"SIGAWMS",1,.T.) //"Endereço de produção do produto informado não cadastrado. Verifique o endereço de produção no cadastro de complementos de produto, aba WMS."
				Case nProcValid == 2
					WmsMessage(STR0122+STR0114,"SIGAWMS",5,.T.) //"Endereço produção do produto não cadastrado. Verifique cadastro compl. produto WMS (WMSA090)."
				Otherwise
					WmsMessage(STR0034,"SIGAWMS",1,.T.) //"Endereço não cadastrado (SBE)."
			EndCase
			lRet := .F.
		Else
			If cTipServ != '3' .And. DLTipoEnd(SBE->BE_ESTFIS) != 5
				Do Case
					Case nProcValid == 1
						WmsMessage(STR0117/*+STR0111*/,"SIGAWMS",1,.T.) //"Endereço produção deve ter estrutura do tipo box/doca. " Verifique o endereço de produção no cadastro de complementos de produto, aba WMS."
					Case nProcValid == 2
						WmsMessage(STR0123+STR0114,"SIGAWMS",5,.T.) //"End. produção do produto deve ter estrutura tipo box/doca. Verifique cadastro compl. produto WMS (WMSA090)."
					Otherwise
						WmsMessage(STR0107,"SIGAWMS",1,.T.) //"Para serviços de entrada/saída somente endereços de estrutura do tipo box/doca podem ser utilizados."
				EndCase
				lRet := .F.
			EndIf
		EndIf
	ElseIf lForce
		Do Case
			Case nProcValid == 1
				WmsMessage(STR0116/*+STR0111*/,"SIGAWMS",1,.T.) //"Endereço de produção do produto não definido. Verifique o endereço de produção no cadastro de complementos de produto, aba WMS."
			Case nProcValid == 2
				WmsMessage(STR0124+STR0114,"SIGAWMS",5,.T.) //"End. produção do produto não definido. Verifique cadastro compl. produto WMS (WMSA090)."
			Otherwise
				WmsMessage(Iif(cTipServ=='1',STR0035,STR0036),"SIGAWMS",1,.T.) //"É obrigatório informar endereço (origem/destino)"
		EndCase
		lRet := .F.
	ElseIf !lConfirm
		lRet := (WmsMessage(Iif(cTipServ=='1',STR0103,STR0104),"SIGAWMS",4,.T.,{STR0105,STR0106})==2) //"Sempre que um Serviço WMS for gerado é necessário que se informe um endereço..."
	EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConSldRF  ºAutor  ³Microsiga           º Data ³  03/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ConSldRF(cLocal,cEndereco,cProduto,cLoteCTL,cNumlote,nSaldoSBF,lRadioF,cStatRF,lCache,lAConvo,lUsaEntra,lUsaSaida,cNumSeq,cDocto,cSerie,cCliFor,cLoja)
Local aAreaAnt  := GetArea()
Local nCntFor   := 0
Local nCnt1     := 0
Local cQuery    := ''
Local cAliasQry := 'SDB'
Local aTamQtd   := TamSX3('DB_QUANT')

Default cLocal    := ''
Default cEndereco := ''
Default cProduto  := ''
Default cLoteCTL  := ''
Default cNumLote  := ''
Default nSaldoSBF := 0
Default lRadioF   := SuperGetMV('MV_RADIOF') == 'S' //-- Como Default o parametro MV_RADIOF e verificado
Default cStatRF   := '1' //-- Como Default a radio frequencia VAI gerar movimentos no SDB SEM atualizar estoque
Default lCache    := .T.
Default lAConvo   := .T.
Default cNumSeq   := ''
Default cDocto    := ''
Default cSerie    := ''
Default cCliFor   := ''
Default cLoja     := ''

	//-- Formato do Array aSaldoSBF
	//-- 1-Armazen
	//-- 2-Endereco
	//-- 3-Produto
	//-- 4-Lote
	//-- 5-Sublote
	//-- 6-Quantidade Origem
	//-- 7-Quantidade Destino

	//-- Faz com que o Saldo do SBF seja submetido a validacoes da Rastreabilidade (Data de Implantacao do Lote, Data de Validade, Bloqueio de Lote, etc.)
	If nSaldoSBF > 0 .And. Rastro(cProduto)
		nSaldoSBF := Min(nSaldoSBF, SaldoLote(cProduto, cLocal, cLoteCTL, cNumLote, .F., Nil, .F., dDataBase))
	EndIf
	If !lRadioF .Or. (lRadioF .And. cStatRF=='1') //-- O saldo Pendente deve ser considerado somente na Geracao dos Servicos de RF

		If lCache //-- Considera os servicos em Cache (executados nesta mesma secao)
			If Type('aSaldoSBF') == 'A'
				For nCntFor := 1 To Len(aSaldoSBF)
					For nCnt1 := 1 To Len(aSaldoSBF[nCntFor])
						If cLocal + cEndereco == aSaldoSBF[nCntFor,nCnt1,1] + aSaldoSBF[nCntFor,nCnt1,2] .And.;
							Iif(!Empty(cProduto),cProduto == aSaldoSBF[nCntFor,nCnt1,3],.T.) .And.;
							Iif(!Empty(cLoteCTL + cNumlote),cLoteCTL + cNumlote == aSaldoSBF[nCntFor,nCnt1,4] + aSaldoSBF[nCntFor,nCnt1,5],.T.)
							If lUsaSaida
								//-- Subtrai o saldo na origem
								nSaldoSBF -= aSaldoSBF[nCntFor,nCnt1,6]
							EndIf
							If lUsaEntra
								//-- Soma o saldo no destino
								nSaldoSBF += aSaldoSBF[nCntFor,nCnt1,7]
							EndIf
						EndIf
					Next
				Next
			EndIf
		EndIf
		//-- Considera Servicos ja executados aguardando Convocacao
		If lAConvo
			//-- Considera os Servicos Pendentes (executados em secoes anteriores)
			//-- Subtrai o Saldo Pendente para Saida da Origem
			//-- ( DB_LOCALIZ )
			If lUsaSaida
				cAliasQry := GetNextAlias()
				cQuery := " SUM(SDB.DB_QUANT) DB_QUANT FROM ("
				cQuery += "SELECT DB_QUANT"
				cQuery += " FROM "+ RetSqlName("SDB")
				cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
				If !Empty(cProduto)
					cQuery += " AND DB_PRODUTO = '"+cProduto+"'"
				EndIf
				cQuery += " AND DB_LOCAL = '"+cLocal+"'"
				If !Empty(cLoteCTL+cNumLote)
					cQuery += " AND DB_LOTECTL = '"+cLoteCTL+"'"
					cQuery += " AND DB_NUMLOTE = '"+cNumLote+"'"
				EndIf
				If !Empty(cEndereco)
					cQuery += " AND DB_LOCALIZ = '"+cEndereco+"'"
				EndIf
				If !Empty(cNumSeq)
					cQuery += " AND DB_NUMSEQ = '"+cNumSeq+"'"
				EndIf
				If !Empty(cDocto)
					cQuery += " AND DB_DOC = '"+cDocto+"'"
				EndIf
				If !Empty(cSerie)
					cQuery += " AND DB_SERIE = '"+cSerie+"'"
				EndIf
				If !Empty(cCliFor)
					cQuery += " AND DB_CLIFOR = '"+cCliFor+"'"
				EndIf
				If !Empty(cLoja)
					cQuery += " AND DB_LOJA = '"+cLoja+"'"
				EndIf
				//Se existe a variável do ID Movto atual não deve considerar o mesmo nas consultas de saldo de estoque RF
				If Type('cIdMovtoAt') == 'C'
					cQuery += " AND DB_IDMOVTO <> '"+cIdMovtoAt+"'"
				EndIf
				cQuery += " AND DB_ESTORNO = ' '"
				cQuery += " AND DB_ATUEST  = 'N'"
				cQuery += " AND DB_STATUS IN ('4','3','2','-')"
				cQuery += " AND D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY DB_SERVIC,DB_TAREFA,DB_IDDCF,DB_IDMOVTO,DB_QUANT) SDB"
				cQuery := "%" + cQuery + "%"
				BeginSql Alias cAliasQry
					SELECT %Exp:cQuery%
				EndSql
				TcSetField(cAliasQry, 'DB_QUANT', 'N', aTamQtd[1], aTamQtd[2])
				If (cAliasQry)->(!Eof()) .And. !Empty((cAliasQry)->DB_QUANT)
					//-- Saldos endereco destino pendentes exec. RF
					nSaldoSBF -= (cAliasQry)->DB_QUANT
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIF
			//-- Soma o Saldo Pendente para Entrada na Origem
			//-- ( DB_ENDDES )
			If lUsaEntra
				cAliasQry := GetNextAlias()
				cQuery := " SUM(SDB.DB_QUANT) DB_QUANT FROM ("
				cQuery += "SELECT DB_QUANT"
				cQuery += " FROM "+ RetSqlName("SDB")
				cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
				If !Empty(cProduto)
					cQuery += " AND DB_PRODUTO = '"+cProduto+"'"
				EndIf
				cQuery += " AND DB_LOCAL = '"+cLocal+"'"
				If !Empty(cLoteCTL+cNumLote)
					cQuery += " AND DB_LOTECTL = '"+cLoteCTL+"'"
					cQuery += " AND DB_NUMLOTE = '"+cNumLote+"'"
				EndIf
				If !Empty(cEndereco)
					cQuery += " AND DB_ENDDES = '"+cEndereco+"'"
				EndIf
				If !Empty(cNumSeq)
					cQuery += " AND DB_NUMSEQ = '"+cNumSeq+"'"
				EndIf
				If !Empty(cDocto)
					cQuery += " AND DB_DOC = '"+cDocto+"'"
				EndIf
				If !Empty(cSerie)
					cQuery += " AND DB_SERIE = '"+cSerie+"'"
				EndIf
				If !Empty(cCliFor)
					cQuery += " AND DB_CLIFOR = '"+cCliFor+"'"
				EndIf
				If !Empty(cLoja)
					cQuery += " AND DB_LOJA = '"+cLoja+"'"
				EndIf
				//Se existe a variável do ID Movto atual não deve considerar o mesmo nas consultas de saldo de estoque RF
				If Type('cIdMovtoAt') == 'C'
					cQuery += " AND DB_IDMOVTO <> '"+cIdMovtoAt+"'"
				EndIf
				cQuery += " AND DB_ESTORNO = ' '"
				cQuery += " AND DB_ATUEST  = 'N'"
				cQuery += " AND DB_STATUS IN ('4','3','2','-')"
				cQuery += " AND D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY DB_SERVIC,DB_TAREFA,DB_IDDCF,DB_IDMOVTO,DB_QUANT) SDB"
				cQuery := "%" + cQuery + "%"
				BeginSql Alias cAliasQry
					SELECT %Exp:cQuery%
				EndSql
				TcSetField(cAliasQry, 'DB_QUANT', 'N', aTamQtd[1], aTamQtd[2])
				If (cAliasQry)->(!Eof()) .And. !Empty((cAliasQry)->DB_QUANT)
					//-- Saldos endereco destino pendentes exec. RF
					nSaldoSBF += (cAliasQry)->DB_QUANT
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return nSaldoSBF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ SaldoLote                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 24/10/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Busca o saldo do lote somando pelo saldo dos sublotes      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ ExpN1:=SaldoLote(ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 = String com o codigo do produto                     ³±±
±±³           ³ ExpC2 = String com o local a ser pesquisado                ³±±
±±³           ³ ExpC3 = String com o lote de Controle                      ³±±
±±³           ³ ExpC4 = String com o Numero do lote                        ³±±
±±³           ³ ExpL5 = Considera Empenho                                  ³±±
±±³           ³ ExpL6 = Considera Lotes Vencidos                           ³±±
±±³           ³ ExpL7 = Considera saldo a classificar                      ³±±
±±³           ³ ExpD1 := Indica a data de referencia do saldo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ Generico Rastreabilidade                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SaldoLote(cProduto,cLocal,cLoteCTL,cNumLote,lBaixaEmp,lConsVenc,lConsClas,dDataRef)
Local aAreaAnt     := GetArea()
Local nRetorno     := 0
Local cQuery       := ''
Local cAliasSB8    := 'SB8'

Default cProduto   := ''
Default cLocal     := ''
Default cLoteCTL   := ''
Default cNumLote   := ''
Default lBaixaEmp  := .F.
Default lConsVenc  := (SuperGetMV('MV_LOTVENC', .F., 'N')=='S')
Default lConsClas  := .F.
Default dDataRef   := dDataBase
	If Rastro(cProduto)
		DbSelectArea("SB8")
		If Rastro(cProduto, "S") .And. !Empty(cLoteCtl) .And. !Empty(cNumLote)
			DbSetOrder(2) //B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)
			If MsSeek(xFilial("SB8")+cNumLote+cLoteCtl+cProduto+cLocal, .F.)
				nRetorno := SB8Saldo(lBaixaEmp, lConsVenc, lConsClas, Nil, Nil, Nil, Nil, dDataRef)
			EndIf
		Else
			DbSetOrder(3) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
			cQuery := "SELECT SB8.R_E_C_N_O_ RECSB8 "
			cQuery +=  " FROM "+RetSqlName("SB8")+" SB8"
			cQuery += " WHERE SB8.B8_FILIAL  = '"+xFilial('SB8')+"'"
			cQuery +=   " AND SB8.B8_PRODUTO = '"+cProduto      +"'"
			cQuery +=   " AND SB8.B8_LOCAL   = '"+cLocal        +"'"
			If !Empty(cLoteCtl)
				cQuery += " AND SB8.B8_LOTECTL='"+cLoteCtl+"'"
			EndIf
			cQuery +=   " AND SB8.B8_SALDO > 0"
			cQuery +=   " AND SB8.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasSB8 := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB8, .T., .T.)
			Do While (cAliasSB8)->(!Eof())
				SB8->(MsGoto((cAliasSB8)->RECSB8))
				nRetorno += SB8Saldo(lBaixaEmp,lConsVenc,lConsClas,NIL,"SB8",nil,nil,dDataRef)
				(cAliasSB8)->(DbSkip())
			EndDo
			(cAliasSB8)->(DbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return nRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³WMSTrava  ºAutor  ³Fernando J. Siquini º Data ³  07/25/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Trava ou destrava uma carga ou documento referente a um    º±±
±±º          ³ servico do WMS. Utiliza uma trava do tipo LOCKBYNAME       º±±
±±º          ³ gerada da seguinte forma:                                  º±±
±±º          ³ Quando o servico for aglutinado por carga: WM99CCCCC       º±±
±±º          ³ Quando o servico for aglutinado por documento: WM99DDDDDSSSº±±
±±º          ³ onde "WM" eh fixo, 99 eh a filial, C eh a carga, D eh o    º±±
±±º          ³ documento e S eh a serie do documento.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ 01 ExpN nAcao  = 1 (Inclui) ou 0 (Exclui) a trava          º±±
±±º          ³ 02 ExpC cTrava = Nome da Trava a ser incluida/excluida (@) º±±
±±º          ³                  Obs.: Quando nAcao = 1 passar com "@"     º±±
±±º          ³                        para possibilitar seu uso na exclu- º±±
±±º          ³                        sao da trava.                       º±±
±±º          ³                        Quando nAcao = 2 eh obrigatorio     º±±
±±º          ³ 03 ExpC cCarga = Codigo da Carga                           º±±
±±º          ³                  Obs.: Obrigatorio quando nAcao = 1        º±±
±±º          ³ 04 ExpC cDoc   = Codigo do Documento                       º±±
±±º          ³                  Obs.: Obrigatorio quando nAcao = 1        º±±
±±º          ³ 05 ExpC cSerie = Codigo da Serie do documento              º±±
±±º          ³                  Obs.: Obrigatorio quando nAcao = 1        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WMSTrava(nAcao, cTrava, cCarga, cDoc, cSerie, cMapSep)

Local cAviso     := ''
Local lCarga     := .F.
Local lRet       := .F.
Local nTentativa := 0

Default nAcao      := 1
Default cTrava     := ''
Default cCarga     := ''
Default cDoc       := ''
Default cSerie     := ''
Default cMapSep    := ''
	If nAcao == 1 .And. !Empty(cCarga+cDoc+cSerie)
		lCarga := WmsCarga(cCarga)
		cTrava := 'WM' + cFilAnt
		cTrava += If(lCarga, cCarga+Iif(Empty(cMapSep),'',cMapSep), cDoc+cSerie)
		Do While .T.
			If IsTelnet()
				DLVTCabec(STR0060, .F., .F., .T.)//"Aguarde"
				@ Int(VTMaxRow()/2)  , 00 VtSay STR0061//"Tentando..."
			EndIf
			Do While !LockByName(cTrava, .T., .T., .T.) .And. nTentativa <= 50
				If IsTelnet()
					@ Int(VTMaxRow()/2)  , 00 VtSay STR0061//"Tentando..."
				EndIf
				nTentativa++
				Sleep(5000)
			EndDo
			If nTentativa >= 50
				cAviso := If(lCarga, STR0062+AllTrim(cCarga), STR0063+AllTrim(cDoc)+'/'+AllTrim(SubStr(cSerie,1,3))) +STR0064//"Carga "#"Documento "#" em processo."
				If IsTelnet()
					cAviso += STR0067//' Tente mais tarde...'
					DLAviso(.T., STR0065, cAviso)//'Atencao!'
					lRet := .F.
					Exit
				Else
					cAviso += STR0066//"Tenta novamente ou abandona?"
					If Aviso(STR0065, cAviso, {STR0068, STR0069}) == 1//'Atencao!'#'Tenta'#'Abandona'
						nTentativa := 0
						Loop
					Else
						lRet := .F.
						Exit
					EndIf
				EndIf
			Else
				lRet := .T.
				Exit
			EndIf
		EndDo
	ElseIf nAcao == 0 .And. !Empty(cTrava)
		UnLockByName(cTrava, .T., .T., .T.)
		lRet := .T.
	EndIf
Return lRet
/*/-----------------------------------------------------------------------------
Determina se a tarefa utiliza radio frequencia.
Verifica se a atividade não é exceção, caso não seja, verifica se esta atividade
utiliza RF. Caso alguma atividade utilize RF já considera a tarefa com RF
-----------------------------------------------------------------------------/*/
Function DLTarUsaRF(cTipoServ,cTarefa,aExcecoesO,aExcecoesD)
Local aAreaAnt   := GetArea()
Local cAtivUsaRF := ''
Local lNoExcec   := .T.
Local lRadioF    := (SuperGetMV('MV_RADIOF')=='S')
Local cSeek      := ''

	If lRadioF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa as Atividades (SX5 - Tab L6) Referentes a Tarefa Desejada     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('DC6')
		DC6->(DbSetOrder(1))
		If DC6->(MsSeek(cSeek:=xFilial('DC6')+cTarefa, .F.))
			Do While DC6->(!Eof() .And. cSeek==DC6_FILIAL+DC6_TAREFA)
				cAtivUsaRF := DC6->DC6_ATIVID
				lNoExcec   := .T.
				If cTipoServ == '1' //-- Nas Entradas, verifica as Excecoes nos Enderecos Destino (Ex.: DOCA->Picking)
					lNoExcec := AScan(aExcecoesD, cAtivUsaRF) == 0
				ElseIf cTipoServ == '2' //-- Nas Saidas, verifica as Excecoes nos Enderecos Origem (Ex.: Picking->DOCA)
					lNoExcec := AScan(aExcecoesO, cAtivUsaRF) == 0
				ElseIf cTipoServ == '3' //-- Nos Movtos.Internos, verifica as Excecoes nos Enderecos Destino ou Origem
					lNoExcec := AScan(aExcecoesD, cAtivUsaRF) == 0 .Or. AScan(aExcecoesO, cAtivUsaRF) == 0
				EndIf
				If lNoExcec //-- Se nao houverem excecoes
					If (lRadioF := (DC6->DC6_RADIOF=='1'))
						Exit
					EndIf
				EndIf
				DC6->(DbSkip())
			EndDo
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRadioF
/*/-----------------------------------------------------------------------------
Determina se a tarefa utiliza radio frequencia.
Verifica se a atividade não é exceção, caso não seja, verifica se esta atividade
utiliza RF. Caso alguma atividade utilize RF já considera a tarefa com RF
-----------------------------------------------------------------------------/*/
Function DLExcecoes(cTipoServ,cLocOrig,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,aExcecoesO,aExcecoesD)
Local aAreaAnt  := GetArea()
Local cQuery    := ''
Local cAliasNew := GetNextAlias()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem Excecoes a Atividades para o Endereco ORIGEM      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoServ $ '23' .And. aExcecoesO != Nil
		aExcecoesO := {}
		cQuery := " DCL_ATIVID "
		cQuery += " FROM "+RetSqlName("SBE")+" SBE, "+RetSqlName("DCL")+" DCL "
		cQuery += " WHERE BE_FILIAL      = '"+xFilial("SBE")+"'"
		cQuery +=   " AND BE_LOCAL       = '"+cLocOrig+"'"
		cQuery +=   " AND BE_ESTFIS      = '"+cEstOrig+"'"
		cQuery +=   " AND BE_LOCALIZ     = '"+cEndOrig+"'"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DCL_FILIAL     = '"+xFilial("DCL")+"'"
		cQuery +=   " AND DCL.DCL_CODIGO = SBE.BE_EXCECAO"
		cQuery +=   " AND DCL.D_E_L_E_T_ = ' '"
		cQuery := "%" + cQuery + "%"
		BeginSql Alias cAliasNew
			SELECT %Exp:cQuery%
		EndSql
		Do While (cAliasNew)->(!Eof())
			aAdd(aExcecoesO, (cAliasNew)->DCL_ATIVID)
			(cAliasNew)->(DbSkip())
		EndDo
		(cAliasNew)->(DbCloseArea())
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem Excecoes a Atividades para o Endereco DESTINO     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoServ $ '13' .And. aExcecoesD != Nil
		aExcecoesD := {}
		cQuery := " DCL_ATIVID "
		cQuery += " FROM "+RetSqlName("SBE")+" SBE, "+RetSqlName("DCL")+" DCL "
		cQuery += " WHERE BE_FILIAL      = '"+xFilial("SBE")+"'"
		cQuery +=   " AND BE_LOCAL       = '"+cLocDest+"'"
		cQuery +=   " AND BE_ESTFIS      = '"+cEstDest+"'"
		cQuery +=   " AND BE_LOCALIZ     = '"+cEndDest+"'"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DCL_FILIAL     = '"+xFilial("DCL")+"'"
		cQuery +=   " AND DCL.DCL_CODIGO = SBE.BE_EXCECAO"
		cQuery +=   " AND DCL.D_E_L_E_T_ = ' '"
		cQuery := "%" + cQuery + "%"
		BeginSql Alias cAliasNew
			SELECT %Exp:cQuery%
		EndSql
		Do While (cAliasNew)->(!Eof())
			aAdd(aExcecoesD, (cAliasNew)->DCL_ATIVID)
			(cAliasNew)->(DbSkip())
		EndDo
		(cAliasNew)->(DbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return (.T.)

/*/{Protheus.doc} DLPxVEndSr
Indica se será aberta a tela de pergunte para informar endereço e serviço ou somente validar ambos.
Usada para os casos em que endereço e serviço são atribuídos automaticamente (ex: parâmetros de endereço e
serviço de produção do produto na ordem de produção).
Os programas que estiverem prevendo a leitura dos parâmetros por produto chamarão esta função em substituição à
função DLPergWms.
@author Wander Horongoso
@since 30/01/2020

@param [cServico], Caracter, Código do serviço, retorna por referencia @cServWMS
@param [cEndereco], Caracter, Código do endereço, retorna por referencia @cEndOrig
@param [lSuggest], Lógico, Indica que sugere as informações na tela
@param [lForce], Lógico, Indica se é obrigatório informar os dados de endereço
@param [cTipServ], Caracter, Tipo do serviço: 1- Entrada, 2- Saída, 3- Interno
@param [cArmazem], Caracter, Código do armazem
@param [l250], Lógico, indica se a origem da chamada é o MATA250.
@param [l250Auto], Lógico, indica se os parâmetros de inclusão automática foram informados no MATA250 (inclusão via execauto).
@param [l680], Lógico, indica se a origem da chamada é o MATA680.
@param [l680Auto], Lógico, indica se os parâmetros de inclusão automática foram informados no MATA680 (inclusão via execauto).
@param [l681], Lógico, indica se a origem da chamada é o MATA681.
@param [l681Auto], Lógico, indica se os parâmetros de inclusão automática foram informados no MATA681 (inclusão via execauto).

@return Lógico Indicador se os dados foram informados corretamente
/*/
Function DLPxVEndSr(cServico, cEndereco, lSuggest, lForce, cTipServ,cArmazem, l250, l250Auto, l680, l680Auto, l681, l681Auto)
Local lRet := .T.
Local nProcValEn := 0
Local nProcValSr := 0

Default l250     := .F.
Default l250Auto := .F.
Default l680     := .F.
Default l680Auto := .F.
Default l681     := .F.
Default l681Auto := .F.

	/*Se a chamada for via Execauto do MATA250, MATA680 ou MATA681 (chamadas feitas via coletor ACDV020/3/5)
	  ou for inclusão normal via MATA250/680/1 com endereço e serviço obtidos dos parâmetros de produção do produto,
	  então não irá abrir a tela, fazendo apenas a validação).*/
	If l250Auto .Or. l680Auto .Or. l681Auto
		nProcValEn := 2
		nProcValSr := 2
	ElseIf (l250 .And. !Empty(cEndereco))
		nProcValEn := 1
		nProcValSr := 3
	ElseIf ((l680 .Or. l681) .And. !Empty(cServico) .And. !Empty(cEndereco))
		nProcValEn := 1
		nProcValSr := 1
	EndIf

	If nProcValEn == 0 .And. nProcValSr == 0
		If l250
			lRet := DLPergEnd(@cEndereco,lSuggest,lForce,cTipServ,cArmazem)
		Else
			lRet := DLPergWMS(@cServico,@cEndereco,lSuggest,lForce,cTipServ,cArmazem)
		EndIf
	Else
		lRet := VldServWMS(cServico,lForce,cTipServ,.T.,nProcValSr)
		lRet := lRet .And. VldEndWMS(cArmazem,cEndereco,lForce,cTipServ,.T.,nProcValEn)
	EndIf

Return lRet
 
/*/{Protheus.doc} Wms250SEA
Função criada para remover a lógica de WMS existente no PCP.
Objetivo é validar serviço e endereço de produção e abrir a tela para informar o endereço de produção.
@author Wander Horongoso
@since 10/06/2020

@param [cServic], Caracter, Código do serviço, retorna por referencia @cServWMS
@param [cEnd], Caracter, Código do endereço, retorna por referencia @cEndOrig
@param [cCodProd], Caracter, Código do produto
@param [cOP], Caracter, Número da OP
@param [cLocal], Caracter, Código do armazém
@param [cDoc], Caracter, Código do documento
@param [l250], Lógico, indica se a origem da chamada é o MATA250.
@param [l250Auto], Lógico, indica se os parâmetros de inclusão automática foram informados no MATA250 (inclusão via execauto).

@return Lógico Indicador se os dados foram informados corretamente
/*/
function Wms250SEA(cServic, cEnd, cCodProd, cOP, cLocal, cDoc, l250, l250Auto)
Local lRet   := .T.
Local lPerg  := .T.	
Local aRetPE := {}	

	If l250 .And. !Empty(cServic) 
		//-- Permite a informacao do Endereco e da Estrutura de Origem via Ponto de Entrada
		If ExistBlock('A250WMSO') 
			//-- Retorno esperado do RDMAKE
			//-- Array[1] = cEnd
			aRetPE := ExecBlock('A250WMSO', NIL, NIL, {cCodProd, cOP})
			If Len(aRetPE) > 0
				lPerg := .F.
				cEnd := aRetPE[1]
			EndIf
		EndIf		
	EndIf

	If lPerg .And. !(l250Auto .And. Empty(cEnd)) .AND. !Empty(cServic)
		lRet := DLPxVEndSr(cServic, @cEnd, .T., .T., '1', cLocal, .T., l250Auto) //'Identifique a origem do Servico WMS:'			
	EndIf
	
	If lRet 
		lRet := WmsAvalSC2("1",cServic,cEnd,cDoc)
	EndIf

Return lRet

/*/{Protheus.doc} Wms145SET
Função criada para sugerir serviço, endereço e tipo de estrutura após informar produto no MATA145.
@author Wander Horongoso
@since 18/08/2021
@param [cCod], Caracter, Código do produto
@return aRet [servico,endereco,tipo de estrutura]
/*/
function Wms145SET(cCod)
Local cAliasQry := nil
Local aRet := {'','',''}

	If IntWms(cCod)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SB5.B5_SERVENT, SB5.B5_ENDENT, SBE.BE_ESTFIS
			FROM %Table:SB5% SB5
			INNER JOIN %Table:SBE% SBE
			  ON SBE.BE_FILIAL = %xFilial:SBE%
			  AND SBE.BE_LOCALIZ = SB5.B5_ENDENT
			  AND SBE.%NotDel%
			WHERE SB5.B5_FILIAL = %xFilial:SB5%
			AND SB5.B5_COD = %Exp:cCod%
			AND SB5.%NotDel%
		EndSql
		If !(cAliasQry)->(Eof())
			aRet[1] := (cAliasQry)->B5_SERVENT
			aRet[2] := (cAliasQry)->B5_ENDENT
			aRet[3] := (cAliasQry)->BE_ESTFIS
		EndIf

		(cAliasQry)->(dbCloseArea())
	EndIf
Return aRet
