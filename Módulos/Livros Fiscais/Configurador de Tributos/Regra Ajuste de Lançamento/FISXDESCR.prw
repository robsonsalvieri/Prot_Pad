#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"


//--------------------------------------------------------------------------------------------------------------------------------------------
//Este fonte tem objetivo de Converter referencias da maxtfis e outras funções em indices para serem utilizados em textos do documento fiscal
//--------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} MensagRef
	aNfCab      -> Array com dados do cabeçalho da nota
	aNFItem     -> Array com dados item da nota
	nItem       -> Item que esta sendo processado	
	aInfNat	    -> Array com dados da natureza	
    cMensagem  -> String com mensagem para conversão

    @type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021  
    
/*/
Function MensagRef(oHMCad,lBuild,aNfCab, aNfItem, aInfNat, cMensagem, aItens, aRetHash)
Local aPalavras     := {}
Local cNovaMensagem := ""
Default cMensagem   := ""
Default aItens      := {}
Default aRetHash    := {}

// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
If lBuild .And. !EmpTy(AllTrim(cMensagem)) .and. len(aItens) > 0
    
    //TODO -- Tirar daqui e colocar na MATXFIS para processar apenas uma vez
    IF oHMCad==Nil
        oHMCad:= NewHash(oHMCad)

        //Alimenta o hash
        LoadMSGhash(@oHMCad)
         //conout("tempo de Insert:" + cValTochar(seconds() - nStart))
    Endif
    
    //Quebra mensagem
    aPalavras := StrTokArr(alltrim(cMensagem),CHR(32)+CHR(13)+CHR(10)) //Espaço + SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)

    //Ordena Array pelo Prefixo+Sufixo
    aSort(aPalavras)

    //Processa texto    
    cNovaMensagem := Processar(oHMCad,aNfCab, aNfItem, aInfNat, aPalavras, cMensagem, aItens, aRetHash) 

    //Limpa array aPalavras
    aSize(aPalavras,0)
    
    //conout("tempo total:" + cValTochar(seconds() - nStart))    
    //conout(cNovaMensagem)
EndIf

Return cNovaMensagem

/*/{Protheus.doc} Processar
  
    /*/
Static Function Processar(oHMCad,aNfCab, aNfItem, aInfNat, aPalavras , cMensagem, aItens, aRetHash) 

Local aSomaItem  := {}
Local cPrefixo   := ""
Local cSufixo    := ""
Local nNumItens  := Len(aItens)
Local lSomaItens := nNumItens > 1
Local nFim       := 0
Local nI         := 0
Local nInicio    := 0
Local nItem      := 0
Local nMeio      := 0
Local nPosGen    := 0
Local nX         := 0
Local nY         := 0

Default aRetHash   := {}

    //Procesas todos itens que irão compor a mensagem
    For nI := 1 to nNumItens
        
        //Processa Item
        nItem := val(aItens[nI])

        //Processa todas as palavras apenas para primeiro item
        //Para demais itens apenas Soma valores
        IF nI == 1
            //Processa Palavras
            For nX := 1 to Len(aPalavras)
                
                // Evita processar mesmo texto
                IF nX > 1 .and. aPalavras[nX-1] == aPalavras[nX] 
                    Loop
                Endif            
                
                aRetHash := {}        
                nPosGen  := 0            

                IF !EmpTy(aPalavras[nX]) .And. (nMeio := AT(":", aPalavras[nX], 1)) > 0 .and. (nInicio := AT("[", aPalavras[nX], 1)) > 0 .and. (nFim := AT("]", aPalavras[nX], 1)) > 0
                    
                    cPrefixo := SubStr(aPalavras[nX], nInicio,nMeio-nInicio )
                    cSufixo  := SubStr(aPalavras[nX], nMeio, nFim-(nMeio-1))
                    
                    IF !EmpTy(cPrefixo) .And. !EmpTy(cSufixo) //Valida se Existe Sufixo e Prefixo

                        //Procura no Legado
                        IF cPrefixo <> "[TG" .And. Len(aRetHash := FindHash(oHMCad,cPrefixo+cSufixo)) > 0 // Localiza No hash se existe Prefixo+Sufixo
                            IF aRetHash[1][MSG_LSOMA] .And. lSomaItens
                                //Caso possua mais de um item para ser processado e a referencia possui atributo de soma
                                //Guarda valor para somar aos demais itens 
                                aadd(aSomaItem,{cPrefixo+cSufixo,;               //Chave 
                                                aRetHash[1][MSG_INDICADOR],;           //Indicador
                                                aRetHash[1][MSG_TIPO],;                //Tipo
                                                aRetHash[1][MSG_REFERENCIA],;          //Referencia
                                                aRetHash[1][MSG_VAL_REF],;             //Valor referencia compilacao
                                                nPosGen,;                               //Posição do tributo generico
                                                Converter(aNfCab, aNfItem, nItem, aInfNat, aRetHash[1], nPosGen, .F.)})   //Valor recuperado da referencia do item

                            Else
                                //Quando a referencia não possuir atributo de soma ou não existir mais de um item a ser processado
                                //atualiza a mensagem
                                cMensagem := AtuMensag(cPrefixo+cSufixo, cMensagem, aNfCab, aNfItem, nItem, aInfNat, aRetHash[1], nPosGen)
                            Endif
                        ElseIf (nPosGen := aScan(aNFItem[nItem][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_SIGLA]) == SubStr(cPrefixo, 2, len(cPrefixo)-1)})) > 0

                            IF Len(aRetHash := FindHash(oHMCad,'[TG'+cSufixo)) > 0
                                IF aRetHash[1][MSG_LSOMA] .And. lSomaItens
                                    //Caso possua mais de um item para ser processado e a referencia possui atributo de soma
                                    //Guarda valor para somar aos demais itens 
                                    aadd(aSomaItem,{cPrefixo+cSufixo,;             //Chave 
                                                    aRetHash[1][MSG_INDICADOR],;          //Indicador
                                                    aRetHash[1][MSG_TIPO],;               //Tipo
                                                    aRetHash[1][MSG_REFERENCIA],;         //Referencia
                                                    aRetHash[1][MSG_VAL_REF],;            //Valor referencia compilacao
                                                    nPosGen,;            //Posição do tributo generico
                                                    Converter(aNfCab, aNfItem, nItem, aInfNat, aRetHash[1], nPosGen, .F.)})   //Valor recuperado da referencia do item
                                Else
                                    //Quando a referencia não possuir atributo de soma ou não existir mais de um item a ser processado
                                    //atualiza a mensagem
                                    cMensagem := AtuMensag(cPrefixo+cSufixo, cMensagem, aNfCab, aNfItem, nItem, aInfNat, aRetHash[1], nPosGen)
                                Endif
                            Endif                        
                        Endif
                    Endif            
                Endif                
            Next nX
        Else
            //Soma todos os itens contidos no array aSomaItem
            For nY := 1 to Len(aSomaItem)            
                aSomaItem[nY][7] += Converter(aNfCab, aNfItem, nItem, aInfNat, aSomaItem[nY], aSomaItem[nY][6], .F.)
            Next nY
        Endif
    Next nI

    //Atualiza mensagem com somatorio de todos os itens
    IF lSomaItens
        For nY := 1 to Len(aSomaItem)
            cMensagem := AtuMensag(aSomaItem[nY][1], cMensagem, aNfCab, aNfItem, nItem, aInfNat, aSomaItem[nY], aSomaItem[nY][6], ConvResult(aSomaItem[nY][3], aSomaItem[nY][7]) )
        Next nY
    Endif

    //Limpa variaveis
    FwFreeArray(aSomaItem)    

Return cMensagem

/*/{Protheus.doc} AtuMensag
	(Função Para atualizar mensagem)

	@type Static Function
	@author Bruce Egnor, Rafael Oliveira, Matheus Henrique
	@since 20/04/2021	
/*/

Static function AtuMensag(cPalavra, cMensagem, aNfCab, aNfItem, nItem, aInfNat, aRetHash, nPosGen, cTxtConv)
Local nPosIni    := 0
Local nPosFin    := 1
Default nPosGen  := 0
Default cTxtConv := ""

    //Enquanto encontrar esta palavra na mensagem substitui pelo novo conteudo
    Do While (nPosIni := AT(cPalavra, cMensagem, nPosFin)) > 0
        IF Empty(cTxtConv)
            cTxtConv := Converter(aNfCab, aNfItem, nItem, aInfNat, aRetHash, nPosGen)
        Endif

        //Encontra final da palavra e Guarda posição da ultima palavra encontrada
        nPosFin := AT(']',cMensagem, nPosIni) +1

        //Valida se pavavra na integra dentro da mensagem é igual a palavra a ser susbtituida
        //AT faz like dentro da mensagem, pode retornar parte de uma palavra, gerando problema na atualização da mensagem
        IF cPalavra == SubString(cMensagem,nPosIni,nPosFin-nPosIni)
            //Atualiza Mensagem
            cMensagem := stuff(cMensagem, nPosIni, Len(cPalavra), cTxtConv)
        Endif
    Enddo
Return cMensagem

/*/{Protheus.doc} Converter
    (Função responsavel por converter prefixo+sufixo para valor da referencia )
    aNfCab      -> Array com dados do cabeçalho da nota
	aNFItem     -> Array com dados item da nota
	nItem       -> Item que esta sendo processado	
	aInfNat	    -> Array com dados da natureza
    aRetHash    -> Array retorno Hash
    nPosGen     -> Posição do tributo generico utilizado
    lConvTxt    -> Indica se Retorna valor convertido em caractere

    @type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021
/*/
Static Function Converter(aNfCab, aNfItem, nItem, aInfNat, aRetHash, nPosGen, lConvTxt)
Local Retorno    := Nil
Local nCalculo   := 0
Default nPosGen  := 0
Default lConvTxt := .T.

IF aRetHash[MSG_INDICADOR] == 0 .And. nPosGen > 0 //Verifica Configurador    

    Retorno := RetConf(aNfItem, nItem, nPosGen, aRetHash[MSG_REFERENCIA] )

//Verifica dados do legado
Else
    If aRetHash[MSG_INDICADOR] == 1 //- Cadastro produto
        
        Retorno := aNfItem[nItem][IT_PRD][aRetHash[MSG_VAL_REF]]
        
    ElseIF aRetHash[MSG_INDICADOR] == 2 //- TES
        
        Retorno := aNfItem[nItem][IT_TS][aRetHash[MSG_VAL_REF]]

    ElseIF aRetHash[MSG_INDICADOR] == 3 //- Natureza
        
        Retorno := aInfNat[aRetHash[MSG_VAL_REF]]
          
    ElseIF aRetHash[MSG_INDICADOR] == 4 //- Tributos Legado / Participante / MafisRet

        Retorno := MafisRet(nItem,aRetHash[MSG_REFERENCIA])
       
    ElseIF aRetHash[MSG_INDICADOR] == 5 //- Exceção - Nescessita de tratamento diferenciado com calculo
        
        IF aRetHash[MSG_CHAVE] == '[ZFI:VALOR_ICMS]' // Zona Franca de ICMS
            nCalculo := aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF])
        Endif
        Retorno := Max(nCalculo,0)
    
    //ElseIF aRetHash[MSG_INDICADOR] == 6 // Exceção - Quando MAFISRET Não Retorna Legado
    //    cTipo := Substr(aRetHash[MSG_REFERENCIA],1,2)

    //    IF cTipo == "IT"
    //        Retorno := aNfItem[nItem][aRetHash[MSG_VAL_REF]]
    //    Elseif cTipo == "LF"
    //        Retorno := aNfItem[nItem][IT_LIVRO][aRetHash[MSG_VAL_REF]]
    //    Elseif cTipo == "NF"
    //        Retorno := aNFCab[aRetHash[MSG_VAL_REF]]
    //    Endif

    Endif

Endif

//Converte resultado em texto
IF aRetHash[MSG_TIPO] <> 'C'
    If lConvTxt
        Retorno := Alltrim(ConvResult(aRetHash[MSG_TIPO],Retorno))
//        IF Len(Retorno) == 0
//            Retorno := Space(1)
//        Endif
    Endif
Endif

Return Retorno

/*/{Protheus.doc} RetConf
(Retorna valor do configurador)    
/*/
 Static Function RetConf(aNfItem, nItem, nPosGen, cReferencia )
 Local aTrbGen := {}
 Local cSigla  := ""
 Local Retorno := Nil
    
    cSigla   := AllTrim(aNfItem[nItem][IT_TRIBGEN][nPosGen][TG_IT_SIGLA])    
    aTrbGen     := {cSigla, cReferencia}

    Retorno := MafisRet(nItem,"IT_TRIBGEN",aTrbGen)
Return Retorno

/*/{Protheus.doc} ConvResult
    (Função responsavel por converter qualquer valor em caractere)
    aRetHash = Array retorno do Hash
    xValor   = Valor a ser convertido conforme definido no Hash

    @type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021

/*/
Static Function ConvResult(cTipo, xValor)
Local cRetorno := ""
 
 If cTipo == 'D'
    cRetorno := Dtos(xValor)
ElseIf cTipo == 'N'    
    IF xValor > 0
        cRetorno := cValtochar(xValor)
    Else
        cRetorno := "0"
    Endif
Else
    cRetorno := xValor
Endif

Return cRetorno

/*/{Protheus.doc} LoadMSGhash
    (Esta função tem a responsabilidade de alimentar Hash com dados a serem processados)
    
    @type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021
/*/
Function LoadMSGhash(oHMCad,cTpRef)
Local aLista := {}
Local lTodos := .F.

Default cTpRef := ""
Default	oHMCad := Nil

IF EmpTy(cTpRef) .or. "Todos" == cTpRef
	lTodos := .T.
Endif

/*
Indicador = 0 = Configurador de Tributos
Indicador = 1 = Cadastro de Produto
Indicador = 2 = Cadastro de TES
Indicador = 3 = Cadastro de Natureza
Indicador = 4 = Refenrencias tratadas no MafisRet
Indicador = 5 = Exceção - Nescessita de tratamento diferenciado com calculo
Indicador = 6 = Exceção - Quando MAFISRET Não Retorna Legado
*/
 //Indicador, tipo do dado, valor referencia, referencia

//Configurador

If lTodos .or. cTpRef == "TG"
	            //Chave        /indicador / Tipo / Refrencia / Val ref / lSoma
	aadd(aLista,{'[TG:SIGLA]'         ,0, 'C', 'TG_IT_SIGLA'             ,TG_IT_SIGLA          , .F. ,"1=Sigla do Tributo" 				})
	aadd(aLista,{'[TG:DESCRICAO]'     ,0, 'C', 'TG_IT_DESCRICAO'         ,TG_IT_DESCRICAO      , .F. ,"2=Descrição do Tributo" 			})
	aadd(aLista,{'[TG:BASE]'          ,0, 'N', 'TG_IT_BASE'              ,TG_IT_BASE           , .T. ,"3=Valor da Base" 				})
	aadd(aLista,{'[TG:ALIQUOTA]'      ,0, 'N', 'TG_IT_ALIQUOTA'          ,TG_IT_ALIQUOTA       , .F. ,"4=Valor da Aliquota" 			})
	aadd(aLista,{'[TG:VALOR]'         ,0, 'N', 'TG_IT_VALOR'             ,TG_IT_VALOR          , .T. ,"5=Valor do Tributo"				})
	aadd(aLista,{'[TG:BASE_ORIGEM]'   ,0, 'N', 'TG_LF_BASE_ORI'          ,TG_LF_BASE_ORI       , .T. ,"6=Valor da Base de Origem" 		})
	aadd(aLista,{'[TG:CST]'           ,0, 'C', 'TG_LF_CST'               ,TG_LF_CST            , .F. ,"7=Situação Tributária do tributo"})
	aadd(aLista,{'[TG:VALTRIB]'       ,0, 'N', 'TG_LF_VALTRIB'           ,TG_LF_VALTRIB        , .T. ,"8=Valor Tributado" 				})
	aadd(aLista,{'[TG:DIFERIDO]'      ,0, 'N', 'TG_LF_DIFERIDO'          ,TG_LF_DIFERIDO       , .T. ,"9=Valor Diferido" 				})
	aadd(aLista,{'[TG:ISENTO]'        ,0, 'N', 'TG_LF_ISENTO'            ,TG_LF_ISENTO         , .T. ,"10=Valor Isento" 				})
	aadd(aLista,{'[TG:MAJORADO]'      ,0, 'N', 'TG_LF_MAJORADO'          ,TG_LF_MAJORADO       , .T. ,"11=Valor Majorado" 				})
	aadd(aLista,{'[TG:NAO_TRIBUTADO]' ,0, 'N', 'TG_LF_NAO_TRIBUTADO'     ,TG_LF_NAO_TRIBUTADO  , .T. ,"12=Valor Não Tributario" 		})
	aadd(aLista,{'[TG:OUTROS]'        ,0, 'N', 'TG_LF_OUTROS'            ,TG_LF_OUTROS         , .T. ,"13=Valor Outros" 				})
	aadd(aLista,{'[TG:PERC_DIFERIDO]' ,0, 'N', 'TG_LF_PERC_DIFERIDO'     ,TG_LF_PERC_DIFERIDO  , .F. ,"14=Percentual Diferido" 			})
	aadd(aLista,{'[TG:PERC_MAJORACAO]',0, 'N', 'TG_LF_PERC_MAJORACAO'    ,TG_LF_PERC_MAJORACAO , .F. ,"15=Percentual Majorado" 			})
	aadd(aLista,{'[TG:PERC_REDUCAO]'  ,0, 'N', 'TG_LF_PERC_REDUCAO'      ,TG_LF_PERC_REDUCAO   , .F. ,"16=Percentual de Redução" 		})
	aadd(aLista,{'[TG:PAUTA]'         ,0, 'N', 'TG_LF_PAUTA'             ,TG_LF_PAUTA          , .F. ,"17=Valor da Pauta" 				})
	aadd(aLista,{'[TG:MVA]'           ,0, 'N', 'TG_LF_MVA'               ,TG_LF_MVA            , .F. ,"18=Margem de Lucro" 				})
	aadd(aLista,{'[TG:AUX_MVA]'       ,0, 'N', 'TG_LF_AUX_MVA'           ,TG_LF_AUX_MVA        , .F. ,"19=Margem de Lucro Auxiliar" 	})
	aadd(aLista,{'[TG:AUX_MAJORACAO]' ,0, 'N', 'TG_LF_AUX_MAJORACAO'     ,TG_LF_AUX_MAJORACAO  , .F. ,"12=Majoração Auxiliar" 			})
EndIf
If lTodos .or. cTpRef == "SB"
	//Legado - Produto
	aadd(aLista,{'[SB:CODIGO]'          ,1, 'C', 'SB_COD'          ,SB_COD     , .F. ,"1=Codigo do Produto"						        })             
	aadd(aLista,{'[SB:GRUPOTRIB]'       ,1, 'C', 'SB_GRTRIB'       ,SB_GRTRIB  , .F. ,"2=Grupo de Tributação do Produto"			    })   
	aadd(aLista,{'[SB:NCM]'             ,1, 'C', 'SB_POSIPI'       ,SB_POSIPI  , .F. ,"3=Nomenclatura Comum do Mercosul"				})     					    
	aadd(aLista,{'[SB:UNIDADE_MEDIDA]'  ,1, 'C', 'SB_UM'           ,SB_UM      , .F. ,"4=Unidade de Medida"							    })     
	aadd(aLista,{'[SB:ORIGEM]'          ,1, 'C', 'SB_ORIGEM'       ,SB_ORIGEM  , .F. ,"5=Origem do Produto"								})     		    
	aadd(aLista,{'[SB:CODIGO_ISS]'      ,1, 'C', 'SB_CODISS'       ,SB_CODISS  , .F. ,"6=Codigo de Serviço"								})     		    
	aadd(aLista,{'[SB:CNAE]'            ,1, 'C', 'SB_CNAE'         ,SB_CNAE    , .F. ,"7=Classificação Nacional de Atividade Econômica"	})     									    
	aadd(aLista,{'[SB:CHASSI]'          ,1, 'C', 'SB_CHASSI'       ,SB_CHASSI  , .F. ,"8=Chassi do Produto"								})     		    
	aadd(aLista,{'[SB:VLR_ULT_COMPRA]'  ,1, 'N', 'SB_UVLRC'        ,SB_UVLRC   , .F. ,"9=Valor da Ultima Compra"						})     			    
	aadd(aLista,{'[SB:FATOR_CONVERSAO]' ,1, 'N', 'SB_CONV'         ,SB_CONV    , .F. ,"10=Fator de Conversão"							})     		    
	aadd(aLista,{'[SB:ENQUAD_IPI]'      ,1, 'C', 'SB_GRPCST'       ,SB_GRPCST  , .F. ,"11=Enquadramento do IPI"							})     			    
	aadd(aLista,{'[SB:CEST]'            ,1, 'C', 'SB_CEST'         ,SB_CEST    , .F. ,"12=Código Especificador da Substituição Tributária"})     									    
	aadd(aLista,{'[SB:CODIGO_ATIVIDADE]',1, 'C', 'SB_CODATIV'      ,SB_CODATIV , .F. ,"13=Código de Atividade"							})     		    
	aadd(aLista,{'[SB:ALIQUOTA_CPRB]'   ,1, 'N', 'SB_CG1_ALIQ'     ,SB_CG1_ALIQ, .F. ,"14=Valor da Aliquota da CPRB"					})     				    
Endif
If lTodos .or.  cTpRef == "TS"
	//TES
	aadd(aLista,{'[TS:CODIGO]'          ,2, 'C', 'TS_CODIGO'       ,TS_CODIGO   , .F. ,"1=Código da TES"    									})											
	aadd(aLista,{'[TS:SIT_TRIB_ICMS]'   ,2, 'C', 'TS_SITTRIB'      ,TS_SITTRIB  , .F. ,"2=Situação Tributária do ICMS"    						})					
	aadd(aLista,{'[TS:SIT_TRIB_IPI]'    ,2, 'C', 'TS_CTIPI'        ,TS_CTIPI    , .F. ,"3=Situação Tributaria do IPI"    						})					
	aadd(aLista,{'[TS:REDUCAO_ICMS]'    ,2, 'N', 'TS_BASEICM'      ,TS_BASEICM  , .F. ,"4=Percentual de Redução do ICMS Próprio"    			})								
	aadd(aLista,{'[TS:LIVRO_ICMS]'      ,2, 'C', 'TS_LFICM'        ,TS_LFICM    , .F. ,"5=Livro de ICMS"    									})		
	aadd(aLista,{'[TS:LIVRO_IPI]'       ,2, 'C', 'TS_LFIPI'        ,TS_LFIPI    , .F. ,"6=Livro de IPI"    										})	
	aadd(aLista,{'[TS:CFOP]'            ,2, 'C', 'TS_CF'           ,TS_CF       , .F. ,"7=Código Fiscal de Operações e Prestações"    			})								
	aadd(aLista,{'[TS:REDUCAO_IPI]'     ,2, 'N', 'TS_BASEIPI'      ,TS_BASEIPI  , .F. ,"8=Percentual de Redução de IPI"    						})					
	aadd(aLista,{'[TS:LIVRO_ISS]'       ,2, 'C', 'TS_LFISS'        ,TS_LFISS    , .F. ,"9=Livro de ISS"    										})	
	aadd(aLista,{'[TS:REDUCAO_ICMSST]'  ,2, 'N', 'TS_BSICMST'      ,TS_BSICMST  , .F. ,"10=Percentual de Redução da Substituição Tributária"	})										
	aadd(aLista,{'[TS:REDUCAO_ISS]'     ,2, 'N', 'TS_BASEISS'      ,TS_BASEISS  , .F. ,"11=Percentual de Redução de ISS"    					})					
	aadd(aLista,{'[TS:PERC_DIFERIMENTO]',2, 'N', 'TS_PICMDIF'      ,TS_PICMDIF  , .F. ,"12=Percentual de Diferimento"    						})					
	aadd(aLista,{'[TS:CFOP_EXTENDIDO]'  ,2, 'C', 'TS_CFEXT'        ,TS_CFEXT    , .F. ,"13=Código Fiscal de Operações e Prestações Extendido"	})											
	aadd(aLista,{'[TS:CFPS]'            ,2, 'C', 'TS_CFPS'         ,TS_CFPS     , .F. ,"14=Código Fiscal de Prestação de Serviços"    			})								
	aadd(aLista,{'[TS:SIT_TRIB_PIS]'    ,2, 'C', 'TS_CSTPIS'       ,TS_CSTPIS   , .F. ,"15=Situação Tributária do PIS"    						})					
	aadd(aLista,{'[TS:SIT_TRIB_COF]'    ,2, 'C', 'TS_CSTCOF'       ,TS_CSTCOF   , .F. ,"16=Situação Tributária do Cofins"						})					
	aadd(aLista,{'[TS:REDUCAO_ANT_ICMS]',2, 'N', 'TS_REDANT'       ,TS_REDANT   , .F. ,"17=Percentual de Antecipação do ICMS"    				})							
	aadd(aLista,{'[TS:SIT_TRIB_ISS]'    ,2, 'C', 'TS_CSTISS'       ,TS_CSTISS   , .F. ,"18=Situação Tributária do ISS"    						})					
	aadd(aLista,{'[TS:MOT_DESONE_ICMS]' ,2, 'C', 'TS_MOTICMS'      ,TS_MOTICMS  , .F. ,"19=Motivo do Desoneração do ICMS"    					})						
	aadd(aLista,{'[TS:COD_BAS_CRED]'    ,2, 'C', 'TS_CODBCC'       ,TS_CODBCC   , .F. ,"20=Código da Base de Cálculo de Crédito"    			})							
	aadd(aLista,{'[TS:ALIQ_MAJ_COF]'    ,2, 'N', 'TS_ALQCMAJ'      ,TS_ALQCMAJ  , .F. ,"21=Alíquota Majoração do Cofins"    					})					
	aadd(aLista,{'[TS:ALIQ_MAJ_PIS]'    ,2, 'N', 'TS_ALQPMAJ'      ,TS_ALQPMAJ  , .F. ,"22=Alíquota Majoração do PIS"    						})					
	aadd(aLista,{'[TS:NAT_OPERACAO]'    ,2, 'C', 'TS_NATOPER'      ,TS_NATOPER  , .F. ,"23=Natureza de Operação"    							})			
	aadd(aLista,{'[TS:ENQUAD_IPI]'      ,2, 'C', 'TS_GRPCST'       ,TS_GRPCST   , .F. ,"24=Enquadramento do IPI"    							})			
	aadd(aLista,{'[TS:RED_DESC_ICMS]'   ,2, 'N', 'TS_FTRICMS'      ,TS_FTRICMS  , .F. ,"25=Fator de Redução Desconto do ICMS"    				})							
	aadd(aLista,{'[TS:SIT_TRIB_SN]'     ,2, 'C', 'TS_CSOSN'        ,TS_CSOSN    , .F. ,"26=Situação Tributária do Simples Nacional"    			})								
	aadd(aLista,{'[TS:REDUCAO_ICMS_COMP]',2,'C', 'TS_BICMCMP'      ,TS_BICMCMP  , .F. ,"27=Percentual de Redução do ICMS Complementar"			})								
Endif

//Natureza
If lTodos .or.  cTpRef == "NT"
	aadd(aLista,{'[NT:CODIGO]'            ,3, 'C', 'NT_CODIGO'       ,NT_CODIGO  ,.F. ,"1=Codigo da Natureza"          		  })                         
	aadd(aLista,{'[NT:BASE_INSS]'         ,3, 'N', 'NT_BASEINS'      ,NT_BASEINS ,.F. ,"2=Base de Cálculo do INSS"     		  })                         
	aadd(aLista,{'[NT:PERC_PIS]'          ,3, 'N', 'NT_PERCPIS'      ,NT_PERCPIS ,.F. ,"3=Percentual de PIS"           		  })                         
	aadd(aLista,{'[NT:PERC_COF]'          ,3, 'N', 'NT_PERCCOF'      ,NT_PERCCOF ,.F. ,"4=Percentual de Cofins"        		  })                         
	aadd(aLista,{'[NT:PERC_CSL]'          ,3, 'N', 'NT_PERCCSL'      ,NT_PERCCSL ,.F. ,"5=Percentual de CSLL "         		  })                         
	aadd(aLista,{'[NT:BASE_SEST]'         ,3, 'N', 'NT_BASESES'      ,NT_BASESES ,.F. ,"6=Base de Cálculo do SEST"     		  })                                     
	aadd(aLista,{'[NT:PERC_SES]'          ,3, 'N', 'NT_PERCSES'      ,NT_PERCSES ,.F. ,"7=Percentual do SEST"          		  })                                           
	aadd(aLista,{'[NT:BASE_IR_CARRETEIRO]',3, 'N', 'NT_BASEIRC'      ,NT_BASEIRC ,.F. ,"8=Base de Cálculo do IRRF Carreteiro" })                                                
	aadd(aLista,{'[NT:PERC_FUMIPEQ]'      ,3, 'N', 'NT_PERQFMP'      ,NT_PERQFMP ,.F. ,"9=Percentual do FUMIPEQ"       		  })                                              
	aadd(aLista,{'[NT:PERC_INSS_PATRONAL]',3, 'N', 'NT_PERCINP'      ,NT_PERCINP ,.F. ,"10=Percentual do INSS Patronal"		  })                                                    
Endif

//Legado Itens/ Dados Participante
If lTodos .or.  cTpRef == "PR"	
	aadd(aLista,{'[PR:CNPJ]'            ,4,'C', 'NF_CNPJ'         ,NF_CNPJ     ,	.F. ,"1=CNPJ do Participante"   				})
	aadd(aLista,{'[PR:CODIGO]'          ,4,'C', 'NF_CLIFOR'       ,NF_CLIFOR   ,	.F. ,"2=Código do Cliente"     					})
	aadd(aLista,{'[PR:TIPO]'            ,4,'C', 'NF_TPCLIFOR'     ,NF_TPCLIFOR ,	.F. ,"3=Tipo de Cliente"  						})
	aadd(aLista,{'[PR:CLIENTE_ENTRADA]' ,4,'C', 'NF_CLIENT'       ,NF_CLIENT   ,	.F. ,"4=Código do Cliente da ntrada"   			})  
	aadd(aLista,{'[PR:LOJA_ENTRADA]'    ,4,'C', 'NF_LOJENT'       ,NF_LOJENT   ,	.F. ,"5=Loja do Cliente da Entrada" 			})
	aadd(aLista,{'[PR:CLIENTE_FAT]'     ,4,'C', 'NF_CLIEFAT'      ,{NF_CLIEFAT},	.F. ,"6=Código do Cliente do Faturamento"       })
	aadd(aLista,{'[PR:LOJA_CLI_FAT]'    ,4,'C', 'NF_LOJCFAT'      ,{NF_LOJCFAT},	.F. ,"7=Loja do Cliente do Faturamento"     	})  
	aadd(aLista,{'[PR:TIPO_CLI_FAT]'    ,4,'C', 'NF_TIPOFAT'      ,{NF_TIPOFAT},	.F. ,"8=Tipo de Cliente do Faturamento"    		})   
	aadd(aLista,{'[PR:NAT_CLI_FAT]'    ,4,'C',  'NF_NATUFAT'      ,{NF_NATUFAT},	.F. ,"9=Natureza do Cliente"       				})
	aadd(aLista,{'[PR:CLIENTE_DESTINO]' ,4,'C', 'NF_CLIDEST'      ,NF_CLIDEST  ,	.F. ,"10=Codigo do Cliente do Destino"    		})
	aadd(aLista,{'[PR:LOJA_DESTINO]'    ,4,'C', 'NF_LOJDEST'      ,NF_LOJDEST  ,	.F. ,"11=Loja do Cliente do Destino"  			})
	aadd(aLista,{'[PR:UF_CLI_DESTINO]'  ,4,'C', 'NF_UFCDEST'      ,NF_UFCDEST  ,	.F. ,"12=Unidade Federativa Cliente de Destino" })
Endif

//Legado / Dados da Nota - Generico
If lTodos .or.  cTpRef == "NF"	

	aadd(aLista,{'[NF:TIPO_NOTA]'       ,4,'C', 'NF_TIPONF'      ,NF_TIPONF   ,   .F. ,"1=Tipo de Nota Fiscal"                         })   
	aadd(aLista,{'[NF:TIPO_OPERACAO]'   ,4,'C', 'NF_OPERNF'      ,NF_OPERNF   ,   .F. ,"2=Tipo de Operação"                            })
	aadd(aLista,{'[NF:UF_DESTINO]'      ,4,'C', 'NF_UFDEST'      ,NF_UFDEST   ,   .F. ,"3=Unidade Federativa de Destino"               })             
	aadd(aLista,{'[NF:UF_ORIGEM]'       ,4,'C', 'NF_UFORIGEM'    ,NF_UFORIGEM ,   .F. ,"4=Unidade Federativa de Origem"                })            
	aadd(aLista,{'[NF:NATUREZA]'        ,4,'C', 'NF_NATUREZA'    ,NF_NATUREZA ,   .F. ,"5=Natureza da Operação"                        })   
	aadd(aLista,{'[NF:TIPO_COMPLEMENTO]',4,'C', 'NF_TPCOMP'      ,NF_TPCOMP   ,   .F. ,"6=Tipo de Complemento"                         }) 
	aadd(aLista,{'[NF:MOEDA_NOTA]'      ,4,'N', 'NF_MOEDA'       ,NF_MOEDA    ,   .F. ,"7=Moeda da Nota Fiscal"                        })  
	aadd(aLista,{'[NF:TAXA_MOEDA]'      ,4,'N', 'NF_TXMOEDA'     ,NF_TXMOEDA  ,   .F. ,"8=Taxa da Moeda"                               })
	aadd(aLista,{'[NF:SERIE_NF]'        ,4,'C', 'NF_SERIENF'     ,NF_SERIENF  ,   .F. ,"9=Série da Nota Fiscal"                        })  
	aadd(aLista,{'[NF:ESPECIE]'         ,4,'C', 'NF_ESPECIE'     ,NF_ESPECIE  ,   .F. ,"10=Espécie da Nota Fiscal"                     })    
	aadd(aLista,{'[NF:PESO_TOTAL_NF]'   ,4,'N', 'NF_PESO'        ,NF_PESO     ,   .F. ,"11=Peso da Nota Fiscal"                        }) 
	aadd(aLista,{'[NF:UF_TRANSPORTADOR]',4,'C', 'NF_TRANSUF'     ,{NF_TRANSUF},   .F. ,"12=Unidade Federativa da Transportadora"       })                  
	aadd(aLista,{'[NF:COD_MUN_OPER]'    ,4,'C', 'NF_CODMUN'      ,NF_CODMUN   ,   .F. ,"13=Código do Município"                        })
	aadd(aLista,{'[NF:UF_PRES_ISS]'     ,4,'C', 'NF_UFPREISS'    ,NF_UFPREISS ,   .F. ,"14=Unidade Federativa da Prestação de Serviço" })                        
	aadd(aLista,{'[NF:MUN_SIGAMAT]'     ,4,'C', 'NF_M0CODMUN'    ,NF_M0CODMUN ,   .F. ,"15=Código do Município do SIGAMAT"             })            
	aadd(aLista,{'[NF:DATA_EMISSAO]'    ,4,'D', 'NF_DTEMISS'     ,NF_DTEMISS  ,   .F. ,"16=Data de Emissão da Nota Fiscal"             })            
	aadd(aLista,{'[NF:NUM_DEPENDENTES]' ,4,'N', 'NF_NUMDEP'      ,NF_NUMDEP   ,   .F. ,"17=Número de Dependentes"                      })    
	aadd(aLista,{'[NF:NUM_PEDIDO]'      ,4,'C',	'NF_PEDIDO'      ,NF_PEDIDO   ,   .F. ,"18=Número do Pedido"                           })	
	aadd(aLista,{'[NF:NF_DOC]'    		,4,'C', 'NF_DOC'   		 ,NF_DOC	  ,   .F. ,"19=Número da nota fiscal"               	   })	
Endif

	//Legado / Dados Item - Generico
If lTodos .or.  cTpRef == "IT"
	aadd(aLista,{'[IT:CNAE]'            ,4,'C','IT_CNAE'       ,IT_CNAE      ,	  .F. ,"1=Classificação Nacional de Atividade Econômica do Item" })										
	aadd(aLista,{'[IT:ITEM]'            ,4,'C','IT_ITEM'       ,IT_ITEM      ,	  .F. ,"2=Número do Item" 										 })	
	aadd(aLista,{'[IT:CFOP]'            ,4,'C','IT_CF'         ,IT_CF        ,	  .F. ,"3=Código Fiscal de Operações e Prestações" 				 })							
	aadd(aLista,{'[IT:DESCONTO]'        ,4,'N','IT_DESCONTO'   ,IT_DESCONTO  ,	  .T. ,"4=Valor de Desconto" 									 })	
	aadd(aLista,{'[IT:FRETE]'           ,4,'N','IT_FRETE'      ,IT_FRETE     ,	  .T. ,"5=Valor do Frete" 										 })	
	aadd(aLista,{'[IT:DESPESA]'         ,4,'N','IT_DESPESA'    ,IT_DESPESA   ,	  .T. ,"6=Valor de Despesa" 									 })	
	aadd(aLista,{'[IT:SEGURO]'          ,4,'N','IT_SEGURO'     ,IT_SEGURO    ,	  .T. ,"7=Valor de Seguro" 										 })	
	aadd(aLista,{'[IT:TOTAL]'           ,4,'N','IT_TOTAL'      ,IT_TOTAL     ,	  .T. ,"8=Valor Total do Item" 									 })	
	aadd(aLista,{'[IT:VALOR_MERC]'      ,4,'N','IT_VALMERC'    ,IT_VALMERC   ,	  .T. ,"9=Valor da Mercadoria" 									 })		
	aadd(aLista,{'[IT:VALOR_EMBALAGEM]' ,4,'N','IT_VALEMB'     ,IT_VALEMB    ,	  .T. ,"10=Valor da Embalagem" 									 })		
	aadd(aLista,{'[IT:VALOR_NAO_AGRG]'  ,4,'N','IT_VNAGREG'    ,IT_VNAGREG   ,	  .T. ,"11=Valor Não Agregado"									 })	
	aadd(aLista,{'[IT:PESO]'            ,4,'N','IT_PESO'       ,IT_PESO      ,	  .T. ,"12=Peso do Item"										 })	
	aadd(aLista,{'[IT:LOTE]'            ,4,'C','IT_LOTE'       ,{IT_LOTE}    ,	  .T. ,"13=Lote do Produto" 									 })	
	aadd(aLista,{'[IT:SUBLOTE]'         ,4,'C','IT_SUBLOTE'    ,{IT_SUBLOTE} ,	  .T. ,"14=Sublote do Produto" 									 })		
Endif

	//Legado / Tributos - AFRMM
If lTodos .or.  cTpRef == "F3"
	aadd(aLista,{'[AFRMM:BASE]'         ,4,'N', 'IT_BASEAFRMM'   ,IT_BASEAFRMM , .T. ,"1=Base de Cálculo"	  })	       
	aadd(aLista,{'[AFRMM:ALIQUOTA]'     ,4,'N', 'IT_ALIQAFRMM'   ,IT_ALIQAFRMM , .F. ,"2=Alíquota"   		  })  
	aadd(aLista,{'[AFRMM:VALOR]'        ,4,'N', 'IT_VALAFRMM'    ,IT_VALAFRMM  , .T. ,"3=Valor"      	      })
	aadd(aLista,{'[AFRMM:IMPORTACAO]'   ,4,'N', 'IT_AFRMIMP'     ,IT_AFRMIMP   , .T. ,"4=Valor de Importação" })   
Endif
	//Legado / Tributos - FABOV
If lTodos .or.  cTpRef == "E1"
	aadd(aLista,{'[FABOV:BASE]'         ,4,'N', 'IT_BASEFAB'   ,IT_BASEFAB ,.T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[FABOV:ALIQUOTA]'     ,4,'N', 'IT_ALIQFAB'   ,IT_ALIQFAB ,.F. ,"2=Alíquota"		})
	aadd(aLista,{'[FABOV:VALOR]'        ,4,'N', 'IT_VALFAB'    ,IT_VALFAB  ,.T. ,"3=Valor"			})
Endif
	//Legado / Tributos - FACS
If lTodos .or.  cTpRef == "E2"
	aadd(aLista,{'[FACS:BASE]'         ,4,'N', 'IT_BASEFAC'   ,IT_BASEFAC , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[FACS:ALIQUOTA]'     ,4,'N', 'IT_ALIQFAC'   ,IT_ALIQFAC , .F. ,"2=Alíquota"		})
	aadd(aLista,{'[FACS:VALOR]'        ,4,'N', 'IT_VALFAC'    ,IT_VALFAC  , .T. ,"3=Valor"			})
Endif
	//Legado / Tributos - FAMAD
If lTodos .or.  cTpRef == "E3"
	aadd(aLista,{'[FAMAD:BASE]'         ,4,'N', 'IT_BASEFMD'   ,IT_BASEFMD ,.T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[FAMAD:ALIQUOTA]'     ,4,'N', 'IT_ALQFMD'    ,IT_ALQFMD  ,.F. ,"2=Alíquota"		})
	aadd(aLista,{'[FAMAD:VALOR]'        ,4,'N', 'IT_VALFMD'    ,IT_VALFMD  ,.T. ,"3=Valor"			})
Endif
	//Legado / Tributos - FASE
If lTodos .or.  cTpRef == "E4"
	aadd(aLista,{'[FASE:BASE]'        ,4,'N', 'IT_BASFASE'   ,IT_BASFASE , .T. ,"1=Base de Cálculo"	})
	aadd(aLista,{'[FASE:ALIQUOTA]'    ,4,'N', 'IT_ALIFASE'   ,IT_ALIFASE , .F. ,"2=Alíquota"		})
	aadd(aLista,{'[FASE:VALOR]'       ,4,'N', 'IT_VALFASE'   ,IT_VALFASE , .T. ,"3=Valor"			})
	aadd(aLista,{'[FASE:VALOR_RETIDO]',4,'N', 'IT_VLFASER'   ,IT_VLFASER , .T. ,"4=Valor Retido"	})
Endif
	//Legado / Tributos - FETHAB
If lTodos .or.  cTpRef == "E5"
	aadd(aLista,{'[FETHAB:BASE]'        ,4,'N', 'IT_BASEFET'   ,IT_BASEFET , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[FETHAB:ALIQUOTA]'    ,4,'N', 'IT_ALIQFET'   ,IT_ALIQFET , .F. ,"2=Alíquota"		 })
	aadd(aLista,{'[FETHAB:VALOR]'       ,4,'N', 'IT_VALFET'    ,IT_VALFET  , .T. ,"3=Valor"			 })
	aadd(aLista,{'[FETHAB:VALOR_RETIDO]',4,'N', 'IT_VALFETR'   ,IT_VALFETR , .T. ,"4=Valor Redito"	 })
EndIf
	//Legado / Tributos - FUNDERSUL
If lTodos .or. cTpRef == "E6"
	aadd(aLista,{'[FUNDERSUL:BASE]'        ,4,'N', 'IT_VALFDS'    ,IT_VALFDS  , .T., "1=Base de Cálculo"})
	aadd(aLista,{'[FUNDERSUL:ALIQUOTA]'    ,4,'N', 'IT_PRFDSUL'   ,IT_PRFDSUL , .F., "2=Alíquota"		})
	aadd(aLista,{'[FUNDERSUL:VALOR]'       ,4,'N', 'IT_UFERMS'    ,IT_UFERMS  , .T., "3=Valor"			})
Endif
	//Legado / Tributos - FUNDESA
If lTodos .or.  cTpRef == "E7"
	aadd(aLista,{'[FUNDESA:BASE]'        ,4,'N', 'IT_BASFUND'   ,IT_BASFUND , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[FUNDESA:ALIQUOTA]'    ,4,'N', 'IT_ALIFUND'   ,IT_ALIFUND , .F. ,"2=Alíquota"		  })
	aadd(aLista,{'[FUNDESA:VALOR]'       ,4,'N', 'IT_VALFUND'   ,IT_VALFUND , .T. ,"3=Valor"		  })
EndIf
	//Legado / Tributos - IMA
If lTodos .or.  cTpRef == "E8"	
	aadd(aLista,{'[IMA:BASE]'         ,4,'N', 'IT_BASIMA'   ,IT_BASIMA , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[IMA:ALIQUOTA]'     ,4,'N', 'IT_ALIIMA'   ,IT_ALIIMA , .F. ,"2=Alíquota"		 })
	aadd(aLista,{'[IMA:VALOR]'        ,4,'N', 'IT_VALIMA'   ,IT_VALIMA , .T. ,"3=Valor"			 })
	aadd(aLista,{'[IMA:VALOR_RETIDO]' ,4,'N', 'IT_VLIMAR'   ,IT_VLIMAR , .T. ,"4=Valor Retido"	 })
EndIf
	//Legado / Tributos - SEST
If lTodos .or.  cTpRef == "F4"
	aadd(aLista,{'[SEST:BASE]'         ,4,'N', 'IT_BASESES'   ,{IT_BASESES} , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[SEST:ALIQUOTA]'     ,4,'N', 'IT_ALIQSES'   ,{IT_ALIQSES} , .F. ,"2=Alíquota"		  })
	aadd(aLista,{'[SEST:VALOR]'        ,4,'N', 'IT_VALSES'    ,{IT_VALSES } , .T. ,"3=Valor"		  })
EndIf
	//Legado / Tributos - TPDP
If lTodos .or.  cTpRef == "E9"
	aadd(aLista,{'[TPDP:BASE]'         ,4,'N', 'IT_BASTPDP'   ,{IT_BASTPDP} , .T.,"1=Base de Cálculo"})
	aadd(aLista,{'[TPDP:ALIQUOTA]'     ,4,'N', 'IT_ALITPDP'   ,{IT_ALITPDP} , .F.,"2=Alíquota"		 })
	aadd(aLista,{'[TPDP:VALOR]'        ,4,'N', 'IT_VALTPDP'   ,{IT_VALTPDP} , .T.,"3=Valor"			 })
EndIf
	//Legado / Tributos - IPI
If lTodos .or.  cTpRef == "F10"
	aadd(aLista,{'[IPI:VALOR]'         ,4,'N', 'IT_VALIPI'    ,{IT_VALIPI }  ,.T. ,"1=Valor"						  })	
	aadd(aLista,{'[IPI:BASE]'          ,4,'N', 'IT_BASEIPI'   ,{IT_BASEIPI}  ,.T. ,"2=Base de Cálculo"				  })	
	aadd(aLista,{'[IPI:BASE_ORIGINAL]' ,4,'N', 'IT_BIPIORI'   ,{IT_BIPIORI}  ,.T. ,"3=Valor da Base Original"		  })			
	aadd(aLista,{'[IPI:PERC_RED_IPI]'  ,4,'N', 'IT_PREDIPI'   ,{IT_PREDIPI}  ,.F. ,"4=Percentual de Redução"		  })					
	aadd(aLista,{'[IPI:ALIQUOTA]'      ,4,'N', 'IT_ALIQIPI'   ,{IT_ALIQIPI}  ,.F. ,"5=Alíquota"						  })		
	aadd(aLista,{'[IPI:PAUTA]'         ,4,'N', 'IT_PAUTIPI'   ,{IT_PAUTIPI}  ,.T. ,"6=Valor de Pauta"				  })	
	aadd(aLista,{'[IPI:ENQUAD_IPI]'    ,4,'C', 'IT_GRPCST'    ,IT_GRPCST     ,.F. ,"7=Enquadramento do IPI"			  })			
	aadd(aLista,{'[IPI:SIT_TRIB_IPI]'  ,4,'C', 'LF_CTIPI'     ,LF_CTIPI      ,.F. ,"8=Situação Tributária"			  })				
	aadd(aLista,{'[IPI:VLR_BASE_ICMS]' ,4,'N', 'IT_IPIVFCF'   ,IT_IPIVFCF    ,.T. ,"9=Valor do IPI sobre o ICMS"	  })				
	aadd(aLista,{'[IPI:VLR_ORI_ORG]'   ,4,'N', 'IT_VIPIORI'   ,IT_VIPIORI    ,.T. ,"10=Valor IPI Original"			  })		
	aadd(aLista,{'[IPI:VLR_INCID_ICMS]',4,'N', 'IT_VIPIBICM'  ,IT_VIPIBICM   ,.T. ,"11=Valor do IPI incidente no ICMS"})					
	aadd(aLista,{'[IPI:IPI_OBSERVACAO]',4,'N', 'LF_IPIOBS'    ,LF_IPIOBS     ,.T. ,"12=Valor de IPI na Observação"    })					
EndIf

	//CIDE
If lTodos .or.  cTpRef == "F11"
	aadd(aLista,{'[CIDE:BASE]'     ,4,'N', 'IT_BASECID'    ,IT_BASECID   ,.T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[CIDE:ALIQUOTA]' ,4,'N', 'IT_ALQCIDE'    ,IT_ALQCIDE   ,.F. ,"2=Alíquota"		  })
	aadd(aLista,{'[CIDE:VALOR]'    ,4,'N', 'IT_VALCIDE'    ,IT_VALCIDE   ,.T. ,"3=Valor"		  })
EndIf
	//SENAR
If lTodos .or.  cTpRef == "F2"
	aadd(aLista,{'[SENAR:BASE]'     ,4,'N', 'IT_BSSENAR'    ,IT_BSSENAR   ,.T. ,"1=Base de Cálculo"	})
	aadd(aLista,{'[SENAR:ALIQUOTA]' ,4,'N', 'IT_ALSENAR'    ,IT_ALSENAR   ,.F. ,"2=Alíquota"		})
	aadd(aLista,{'[SENAR:VALOR]'    ,4,'N', 'IT_VLSENAR'    ,IT_VLSENAR   ,.T. ,"3=Valor"			})
Endif
	//CPRB
If lTodos .or.  cTpRef == "F12"
	aadd(aLista,{'[CPB:BASE]'            ,4,'N', 'IT_BASECPB'    ,IT_BASECPB , .T. ,"1=Base de Cálculo"	   })
	aadd(aLista,{'[CPB:ALIQUOTA]'        ,4,'N', 'IT_ALIQCPB'    ,IT_ALIQCPB , .F. ,"2=Alíquota"	  	   })
	aadd(aLista,{'[CPB:VALOR]'           ,4,'N', 'IT_VALCPB'     ,IT_VALCPB  , .T. ,"3=Valor"		  	   })
	aadd(aLista,{'[CPB:CODIGO_ATIVIDADE]',4,'C', 'IT_CODATIV'    ,IT_CODATIV , .F. ,"4=Código de Atividade"})
EndIf
	//FEEF
If lTodos .or.  cTpRef== "E12"
	aadd(aLista,{'[FEEF:BASE]'     ,4,'N', 'IT_BASFEEF'    ,IT_BASFEEF , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[FEEF:ALIQUOTA]' ,4,'N', 'IT_ALQFEEF'    ,IT_ALQFEEF , .F. ,"2=Alíquota"		 })
	aadd(aLista,{'[FEEF:VALOR]'    ,4,'N', 'IT_VALFEEF'    ,IT_VALFEEF , .T. ,"3=Valor"			 })
EndIf
	//FUNRUR
If lTodos .or.  cTpRef == "F1"
	aadd(aLista,{'[FUNRUR:BASE]'     ,4,'N', 'IT_BASEFUN'     ,IT_BASEFUN  , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[FUNRUR:ALIQUOTA]' ,4,'N', 'IT_PERFUN'      ,IT_PERFUN   , .F. ,"2=Alíquota"		 })
	aadd(aLista,{'[FUNRUR:VALOR]'    ,4,'N', 'IT_FUNRURAL'    ,IT_FUNRURAL , .T. ,"3=Valor"			 })
EndIf
	//CSLL
If lTodos .or.  cTpRef == "F13"
	aadd(aLista,{'[CSL:BASE]'     ,4,'N', 'IT_BASECSL'     ,IT_BASECSL  , .T. ,"1=Base de Cálculo"})
	aadd(aLista,{'[CSL:ALIQUOTA]' ,4,'N', 'IT_ALIQCSL'      ,IT_ALIQCSL , .F. ,"2=Alíquota"		  })
	aadd(aLista,{'[CSL:VALOR]'    ,4,'N', 'IT_VALCSL'    ,IT_VALCSL     , .T. ,"3=Valor"		  })
EndIf
	//PROTEG
If lTodos .or.  cTpRef == "E13"
	aadd(aLista,{'[PROTEG:BASE]'      ,4,'N', 'IT_BASEPRO' ,IT_BASEPRO , .T. ,"1=Base de Cálculo"		})
	aadd(aLista,{'[PROTEG:ALIQUOTA]'  ,4,'N', 'IT_ALIQPRO' ,IT_ALIQPRO , .F. ,"2=Alíquota"				})
	aadd(aLista,{'[PROTEG:VALOR]'     ,4,'N', 'IT_VALPRO'  ,IT_VALPRO  , .T. ,"3=Valor"					})
EndIf
	//FUMIPQ
If lTodos .or.  cTpRef == "M1"
	aadd(aLista,{'[FUMIPQ:BASE]'     ,4,'N', 'IT_BASEFMP' ,IT_BASEFMP , .T. ,"1=Base de Cálculo"		})
	aadd(aLista,{'[FUMIPQ:ALIQUOTA]' ,4,'N', 'IT_ALQFMP'  ,IT_ALQFMP  , .F. ,"2=Alíquota"				})
	aadd(aLista,{'[FUMIPQ:VALOR]'    ,4,'N', 'IT_VALFMP'  ,IT_VALFMP  , .T. ,"3=Valor"					})
EndIf
	//INSS
If lTodos .or.  cTpRef == "F9"
	aadd(aLista,{'[INS:BASE]'     ,4,'N', 'IT_BASEINS' ,{IT_BASEINS} , .T. ,"1=Base de Cálculo"					})
	aadd(aLista,{'[INS:PERC_RED]' ,4,'N', 'IT_REDINSS' ,{IT_REDINSS} , .F. ,"2=Percentual de Redução do INSS"	})
	aadd(aLista,{'[INS:ALIQUOTA]' ,4,'N', 'IT_ALIQINS' ,{IT_ALIQINS} , .F. ,"3=Alíquota"						})
	aadd(aLista,{'[INS:VALOR]'    ,4,'N', 'IT_VALINS'  ,{IT_VALINS} , .T.  ,"4=Valor"							})
EndIf
	//IRR
If lTodos .or.  cTpRef == "F8"
	aadd(aLista,{'[IRR:BASE]'     ,4,'N', 'IT_BASEIRR'  ,{IT_BASEIRR} , .T. ,"1=Base de Cálculo"	})
	aadd(aLista,{'[IRR:ALIQUOTA]' ,4,'N', 'IT_ALIQIRR'  ,{IT_ALIQIRR} , .F. ,"2=Alíquota"			})
	aadd(aLista,{'[IRR:VALOR]'    ,4,'N', 'IT_VALIRR'   ,{IT_VALIRR } , .T. ,"3=Valor"				})
EndIf
	//II
If lTodos .or.  cTpRef == "F7"
	aadd(aLista,{'[II:ALIQUOTA]' ,4,'N', 'IT_ALIQII'  ,{IT_ALIQII} , .F.  ,"1=Alíquota Imposto de Importação"	})
	aadd(aLista,{'[II:VALOR]'    ,4,'N', 'IT_VALII'   ,{IT_VALII}  , .T.  ,"2=Valor Imposto de Importação"		})
EndIf
	//PIS
If lTodos .or.  cTpRef == "F5"
	aadd(aLista,{'[PS2:BASE]'          ,4,'N', 'IT_BASEPS2'   ,IT_BASEPS2 , .T. ,"1=Base de Cálculo de PIS Apuração"    })
	aadd(aLista,{'[PS2:ALIQUOTA]'      ,4,'N', 'IT_ALIQPS2'   ,IT_ALIQPS2 , .F. ,"2=Alíquota do PIS Apuração"			})
	aadd(aLista,{'[PS2:VALOR]'         ,4,'N', 'IT_VALPS2'    ,IT_VALPS2  , .T. ,"3=Valor do PIS Apuração"				})
	aadd(aLista,{'[PS2:PAUTA_PIS]'     ,4,'N', 'IT_PAUTPIS'   ,IT_PAUTPIS , .T. ,"4=Pauta de PIS Apuração"				})	
	aadd(aLista,{'[PS2:ALIQ_MAJ_PIS]'  ,4,'N', 'IT_ALQPMAJ'   ,IT_ALQPMAJ , .F. ,"5=Alíquota Majorada de PIS Apuração"	})
	aadd(aLista,{'[PS2:VALOR_MAJ_PIS]' ,4,'N', 'IT_VALPMAJ'   ,IT_VALPMAJ , .T. ,"6=Valor Majorada de PIS Apuração"		})
	aadd(aLista,{'[PS2:SIT_TRIB_PIS]'  ,4,'C', 'LF_CSTPIS'    ,LF_CSTPIS  , .F. ,"7=Situação Tributária de PIS Apuração"})
EndIf
	//COF
If lTodos .or.  cTpRef == "F6"
	aadd(aLista,{'[CF2:BASE]'          ,4,'N', 'IT_BASECF2'   ,IT_BASECF2 ,.T. ,"1=Base de Cálculo do Cofins Apuração"		})
	aadd(aLista,{'[CF2:ALIQUOTA]'      ,4,'N', 'IT_ALIQCF2'   ,IT_ALIQCF2 ,.F. ,"2=Alíquota do Cofins Apuração"				})
	aadd(aLista,{'[CF2:VALOR]'         ,4,'N', 'IT_VALCF2'    ,IT_VALCF2  ,.T. ,"3=Valor do Cofins Apuração"				})
	aadd(aLista,{'[CF2:PAUTA_COF]'     ,4,'N', 'IT_PAUTCOF'   ,IT_PAUTCOF ,.T. ,"4=Pauta de Cofins Apuração"				})	
	aadd(aLista,{'[CF2:ALIQ_MAJ_COF]'  ,4,'N', 'IT_ALQCMAJ'   ,IT_ALQCMAJ ,.F. ,"5=Alíquota Majorada de Cofins Apuração"	})
	aadd(aLista,{'[CF2:VALOR_MAJ_COF]' ,4,'N', 'IT_VALCMAJ'   ,IT_VALCMAJ ,.T. ,"6=Valor Majorada de Cofins Apuração"		})
	aadd(aLista,{'[CF2:SIT_TRIB_COF]'  ,4,'C', 'LF_CSTCOF'    ,LF_CSTCOF  ,.F. ,"7=Situação Tributária de Cofins Apuração"	})
EndIf
	//ISS
If lTodos .or.  cTpRef == "M2"
	aadd(aLista,{'[ISS:BASE]'              ,4,'N', 'IT_BASEISS'  ,{IT_BASEISS } ,.T. ,"1=Base de Cálculo"   					})
	aadd(aLista,{'[ISS:ALIQUOTA]'          ,4,'N', 'IT_ALIQISS'  ,{IT_ALIQISS } ,.F. ,"2=Alíquota"								})
	aadd(aLista,{'[ISS:VALOR]'             ,4,'N', 'IT_VALISS'   ,{IT_VALISS  } ,.T. ,"3=Valor"									})
	aadd(aLista,{'[ISS:CODIGO_ISS]'        ,4,'C', 'IT_CODISS'   ,{IT_CODISS  } ,.F. ,"4=Código de Serviço"                  	}) 
	aadd(aLista,{'[ISS:REDUCAO_BASE_ISS]'  ,4,'N', 'IT_PREDISS'  ,{IT_PREDISS } ,.F. ,"5=Redução da Base"             			})      
	aadd(aLista,{'[ISS:ABAT_ISS]'          ,4,'N', 'IT_ABVLISS'  ,{IT_ABVLISS } ,.T. ,"6=Abatimento do ISS"                  	}) 
	aadd(aLista,{'[ISS:ABAT_ISS_MAT_UTIL]' ,4,'N', 'IT_ABMATISS' ,{IT_ABMATISS} ,.T. ,"7=Abatimento do ISS Material Utilizado"	})                    
	aadd(aLista,{'[ISS:BASE_CEPOM]'        ,4,'N', 'IT_BASECPM'  ,{IT_BASECPM } ,.T. ,"8=Base do CEPOM"                     	})
	aadd(aLista,{'[ISS:ALIQUOTA_CEPOM]'    ,4,'N', 'IT_ALQCPM'   ,{IT_ALQCPM  } ,.F. ,"9=Alíquota do CEPOM"                 	}) 
	aadd(aLista,{'[ISS:VALOR_CEPOM]'       ,4,'N', 'IT_VALCPM'   ,{IT_VALCPM  } ,.T. ,"10=Valor do CEPOM"                   	})
	aadd(aLista,{'[ISS:DEDUCAO_ISS]'       ,4,'N', 'IT_DEDICM'   ,{IT_DEDICM  } ,.T. ,"11=Dedução do ISS"                   	})
EndIf
	//CMP
If lTodos .or.  cTpRef == "E20"
	aadd(aLista,{'[CMP:BASE]'              ,4,'N', 'IT_BASEDES'  ,{IT_BASEDES}  ,.T. ,"1=Base de Cálculo do ICMS Complementar"	})
	aadd(aLista,{'[CMP:ALIQUOTA]'          ,4,'N', 'IT_ALIQCMP'  ,{IT_ALIQCMP}  ,.F. ,"2=Alíquota"			   					})
	aadd(aLista,{'[CMP:VALOR]'             ,4,'N', 'IT_VALCMP'   ,{IT_VALCMP }  ,.T. ,"3=Valor"				    				})
	aadd(aLista,{'[CMP:MVA]'               ,4,'N', 'IT_MVACMP'   ,{IT_MVACMP }  ,.F. ,"4=Margem de Lucro"						})
	aadd(aLista,{'[CMP:PERC_REDUCAO]'      ,4,'N', 'IT_PREDCMP'  ,{IT_PREDCMP}  ,.F. ,"5=Percentual de Redução"   				})
	aadd(aLista,{'[CMP:BASE_ORIGINAL]'     ,4,'N', 'IT_BSICARD'  ,{IT_BSICARD}  ,.T. ,"6=Base Original"							})
	aadd(aLista,{'[CMP:VALOR_ORIGINAL]'    ,4,'N', 'IT_VLICARD'  ,{IT_VLICARD}  ,.T. ,"7=Valor Original"						})
EndIf
	//DIFAL
If lTodos .or.  cTpRef == "E19"
	aadd(aLista,{'[DIF:BASE]'              ,4,'N', 'IT_BASEDES'  ,{IT_BASEDES}  ,.T. ,"1=Base de Cálculo do ICMS DIFAL"			})
	aadd(aLista,{'[DIF:ALIQUOTA]'          ,4,'N', 'IT_ALIQCMP'  ,{IT_ALIQCMP}  ,.F. ,"2=Alíquota"								})
	aadd(aLista,{'[DIF:VALOR_ORIGEM]'      ,4,'N', 'IT_DIFAL'    ,IT_DIFAL    	,.T. ,"3=Valor do DIFAL na Origem"				})
	aadd(aLista,{'[DIF:VALOR_DESTINO]'     ,4,'N', 'IT_VALCMP'   ,{IT_VALCMP}   ,.T. ,"4=Valor do DIFAL no Destino"				})
	aadd(aLista,{'[DIF:PERC_REDUCAO]'      ,4,'N', 'IT_PREDCMP'  ,{IT_PREDCMP}  ,.F. ,"5=Percentual de Redução"					})
	aadd(aLista,{'[DIF:PERC_ORIGEM]'       ,4,'N', 'IT_PDORI'    ,IT_PDORI    	,.F. ,"6=Percentual de DIFAL da Origem"			})
	aadd(aLista,{'[DIF:PER_DESTINO]'       ,4,'N', 'IT_PDDES'    ,IT_PDDES    	,.F. ,"7=Percentual de DIFAL do Destino"		})
EndIf
	//ICMS ST
If lTodos .or.  cTpRef == "E11"
	aadd(aLista,{'[ICR:BASE]'              ,4,'N', 'IT_BASEDES'  ,{IT_BASEDES} 	,.T. ,"1=Base de Cálculo do ICMS ST"						})
	aadd(aLista,{'[ICR:ALIQUOTA]'          ,4,'N', 'IT_ALIQCMP'  ,{IT_ALIQCMP} 	,.F. ,"2=Alíquota"											})
	aadd(aLista,{'[ICR:VALOR]'             ,4,'N', 'IT_VICPRST'  ,IT_VICPRST 	,.T. ,"3=Valor"												})
	aadd(aLista,{'[ICR:PAUTA]'             ,4,'N', 'IT_PAUTST'   ,{IT_PAUTST}  	,.T. ,"4=Pauta do ICMS ST" 									})
	aadd(aLista,{'[ICR:PERC_REDUCAO]'      ,4,'N', 'IT_PREDST'   ,{IT_PREDST}  	,.F. ,"5=Percentual de Redução"								})				
	aadd(aLista,{'[ICR:ALQ_ANTERIOR_REC]'  ,4,'N', 'IT_ALQNDES'  ,IT_ALQNDES 	,.F. ,"6=Alíquota Recolhida Anteriormente"					})			
	aadd(aLista,{'[ICR:PERC_RET_ANT_SAIDA]',4,'N', 'IT_PSTANT'   ,IT_PSTANT  	,.F. ,"7=Percential Retido Anteriormente na Saída"			})					
	aadd(aLista,{'[ICR:VLR_RET_ANT_SAIDA]' ,4,'N', 'IT_VSTANT'   ,IT_VSTANT  	,.T. ,"8=Valor Retido Anteriormente na Saída"				})			
	aadd(aLista,{'[ICR:BASE_RET_ANT_SAIDA]',4,'N', 'IT_BSTANT'   ,IT_BSTANT  	,.T. ,"9=Base Retida Anteriormente na Saída"				})			
	aadd(aLista,{'[ICR:MVA]'               ,4,'N', 'IT_MARGEM'   ,{IT_MARGEM}  	,.F. ,"10=Margem de Lucro"									})
	aadd(aLista,{'[ICR:CEST]'              ,4,'C', 'IT_CEST'     ,IT_CEST    	,.F. ,"11=Código Especificador da Substituição Tributária"	})								
	aadd(aLista,{'[ICR:SIT_TRIB_ICMS]'     ,4,'C', 'IT_CLASFIS'  ,IT_CLASFIS 	,.F. ,"12=Situação Tributária"        						})					
EndIf

	//Credito Pressumido
If lTodos .or.  cTpRef == "E14"
	aadd(aLista,{'[PRES:BASE]'    ,4,'N', 'LF_BASECPR'  ,LF_BASECPR  , .T. ,"1=Base do Crédito Presumudo" })
	aadd(aLista,{'[PRES:VALOR]'   ,4,'N', 'LF_CRDPRES'  ,LF_CRDPRES  , .T. ,"2=Valor do Crédito Presumudo"})
EndIf
	//Credito Pressumido ST
If lTodos .or.  cTpRef == "E15"
	aadd(aLista,{'[PRESST:VALOR]'   ,4,'N', 'LF_CRPRST'  ,LF_CRPRST , .T. ,"1=Valor do Crédito Presumido ICMS ST" })
EndIf
	//Credito Pressumido Carga
If lTodos .or.  cTpRef == "E18"
	aadd(aLista,{'[PRESCG:VALOR]'   ,4,'N', 'LF_CRDPCTR'  ,LF_CRDPCTR , .T. ,"1=Valor do Crédito Presumido Carga" })
EndIf
	//Zona franca
If lTodos .or.  cTpRef == "F22"
	aadd(aLista,{'[ZF:VALOR]'             ,4,'N', 'IT_DESCZF'  		,IT_DESCZF  		, .T. ,"1=Valor"						})
	aadd(aLista,{'[ZFI:VALOR_ICMS]'       ,5,'N', ''           		,0          		, .T. ,"2=Valor do ICMS Zona Franca"	})
	aadd(aLista,{'[ZFP:VALOR_PIS]'        ,4,'N', 'IT_DESCZFPIS'  	,IT_DESCZFPIS  		, .T. ,"3=Valor de Pis"					})
	aadd(aLista,{'[ZFC:VALOR_COFINS]'     ,4,'N', 'IT_DESCZFCOF'  	,IT_DESCZFCOF  		, .T. ,"4=Valor de Cofins"				})
EndIf

	//ICM
If lTodos .or.  cTpRef == "E10"
	aadd(aLista,{'[ICM:BASE]'                     ,4,'N', 'IT_BASEICM'   ,{IT_BASEICM  } , .T. ,"1=Base de Cálculo"				})
	aadd(aLista,{'[ICM:ALIQUOTA]'                 ,4,'N', 'IT_ALIQICM'   ,{IT_ALIQICM  } , .F. ,"2=Alíquota"					})	
	aadd(aLista,{'[ICM:VALOR]'                    ,4,'N', 'IT_VALICM'    ,{IT_VALICM   } , .T. ,"3=Valor"						})
	aadd(aLista,{'[ICM:REDUCAO_BASE_ICMS]'        ,4,'N', 'IT_PREDIC'    ,{IT_PREDIC   } , .F. ,"4=Valor Redução"				})		
	aadd(aLista,{'[ICM:VALOR_ICMS_FRETE]'         ,4,'N', 'IT_ICMFRETE'  ,IT_ICMFRETE    , .T. ,"5=Valor do ICMS do Frete"		})			
	aadd(aLista,{'[ICM:BASE_ICMS_FRETE]'          ,4,'N', 'IT_BSFRETE'   ,IT_BSFRETE     , .T. ,"6=Base do ICMS do Frete"		})		
	aadd(aLista,{'[ICM:VALOR_ICMS_DIFERIDO]'      ,4,'N', 'IT_ICMSDIF'   ,IT_ICMSDIF     , .T. ,"7=Valor ICMS Diferido"			})		
	aadd(aLista,{'[ICM:FATOR_RED_DESCONTO]'       ,4,'N', 'IT_FTRICMS'   ,IT_FTRICMS     , .F. ,"8=Fator de Redução Desconto"	})					
	aadd(aLista,{'[ICM:VALOR_RED_DESCONTO]'       ,4,'N', 'IT_VRDICMS'   ,IT_VRDICMS     , .T. ,"9=Valor de Redução Desconto"	})					
	aadd(aLista,{'[ICM:VALOR_DESONERADO]'         ,4,'N', 'IT_ICMDESONE' ,IT_ICMDESONE   , .T. ,"10=Valor Desonerado"			})			
	aadd(aLista,{'[ICM:BASE_EFETIVO]'             ,4,'N', 'IT_BICEFET'   ,IT_BICEFET     , .T. ,"11=Valor do ICMS Efetivo"		})		
	aadd(aLista,{'[ICM:ALIQUOTA_EFETIVO]'         ,4,'N', 'IT_PICEFET'   ,IT_PICEFET     , .F. ,"12=Alíquota do ICMS Efetivo"	})			
	aadd(aLista,{'[ICM:VALOR_EFETIVO]'            ,4,'N', 'IT_VICEFET'   ,IT_VICEFET     , .T. ,"13=Valor do ICMS Efetivo"		})		
	aadd(aLista,{'[ICM:VALOR_SEM_DIFER]'          ,4,'N', 'IT_VOPDIF'    ,IT_VOPDIF      , .T. ,"14=Valor sem Diferimento"		})		
	aadd(aLista,{'[ICM:VALOR_DEDUZIDO]'           ,4,'N', 'IT_DEDICM'    ,{IT_DEDICM   } , .T. ,"15=Valor Deduzido do ICMS"		})			
	aadd(aLista,{'[ICM:BASE_FRETE_AUTONOMO]'      ,4,'N', 'IT_BASEICA'   ,{IT_BASEICA }  , .T. ,"16=Base do Frete Autônomo"		})			
	aadd(aLista,{'[ICM:VALOR_FRETE_AUTONOMO]'     ,4,'N', 'IT_VALICA'    ,{IT_VALICA   } , .T. ,"17=Valor do Frete Autônomo"	})			
	aadd(aLista,{'[ICM:VALOR_PAUTA]'              ,4,'N', 'IT_PAUTIC'    ,{IT_PAUTIC   } , .T. ,"18=Valor de Pauta"				})	
	aadd(aLista,{'[ICM:CLASSIFICACAO_FISCAL]'     ,4,'C', 'IT_CLASFIS'   ,IT_CLASFIS     , .F. ,"19=Classificação Fiscal"		})		
EndIf

	//ANTEC
If lTodos .or.  cTpRef == "E21"
	aadd(aLista,{'[ANTEC:ALIQ_ANTECIPACAO]'       ,4,'N', 'IT_ALANTICMS' ,IT_ALANTICMS   ,.F. ,"1=Alíquota do ICMS Antecipado"	})
	aadd(aLista,{'[ANTEC:VALOR_ANTECIPACAO]'      ,4,'N', 'IT_VALANTI'   ,IT_VALANTI     ,.T. ,"2=Valor do ICMS Antecipado"		})
EndIf


	//FCP
If lTodos .or.  cTpRef == "E22"
	aadd(aLista,{'[FCP:BASE_FECP]'                ,4,'N', 'IT_BASFECP'    ,IT_BASFECP   ,.T. ,"1=Base do Fundo Estadual de Combate à Pobreza "		})
	aadd(aLista,{'[FCP:ALIQUOTA_FECP]'            ,4,'N', 'IT_ALIQFECP'   ,IT_ALIQFECP  ,.F. ,"2=Alíquota do Fundo Estadual de Combate à Pobreza "	})
	aadd(aLista,{'[FCP:VALOR_FECP]'               ,4,'N', 'IT_VALFECP'    ,IT_VALFECP   ,.T. ,"3=Valor do Fundo Estadual de Combate à Pobreza "		})
	aadd(aLista,{'[FCP:FECP_AUXILIAR]'            ,4,'N', 'IT_FCPAUX'     ,IT_FCPAUX    ,.F. ,"4=Fundo Estadual de Combate à Pobreza Auxiliar "		})
EndIf
	//FCM
If lTodos .or.  cTpRef == "E24"
	aadd(aLista,{'[FCM:BASE_FECP_COMP]'           ,4,'N', 'IT_BSFCCMP'    ,IT_BSFCCMP   ,.T. ,"1=Base do Fundo Estadual de Combate à Pobreza Complementar"		})
	aadd(aLista,{'[FCM:ALIQ_FECP_COMP]'           ,4,'N', 'IT_ALFCCMP'    ,IT_ALFCCMP   ,.F. ,"2=Alíquota do Fundo Estadual de Combate à Pobreza Complementar"	})
	aadd(aLista,{'[FCM:VALOR_FECP_COMP]'          ,4,'N', 'IT_VALFECP'    ,IT_VALFECP   ,.T. ,"3=Valor do Fundo Estadual de Combate à Pobreza Complementar"		})
	aadd(aLista,{'[FCM:VALOR_FECP_DIFAL]'         ,4,'N', 'IT_VFCPDIF'    ,IT_VFCPDIF   ,.T. ,"4=Fundo Estadual de Combate à Pobreza Auxiliar Difal"			})
EndIf
	//FST
If lTodos .or.  cTpRef == "E23"
	aadd(aLista,{'[FST:BASE_FECP_ST]'           ,4,'N', 'IT_BSFCPST'    ,IT_BSFCPST  ,.T. ,"1=Base do Fundo Estadual de Combate à Pobreza ICMS ST"		})
	aadd(aLista,{'[FST:ALIQ_FECP_ST]'           ,4,'N', 'IT_ALFCST'     ,IT_ALFCST   ,.F. ,"2=Alíquota do Fundo Estadual de Combate à Pobreza ICMS ST"	})
	aadd(aLista,{'[FST:VALOR_FECP_ST]'          ,4,'N', 'IT_VFECPST'    ,IT_VFECPST  ,.T. ,"3=Valor do Fundo Estadual de Combate à Pobreza ICMS ST"		})
EndIf
	//INS
If lTodos .or.  cTpRef == "F9"
	aadd(aLista,{'[INS:BASE_CONDI_ESPECIAL]'    ,4,'N', 'IT_BASEINA'        ,{IT_BASEINA}    ,.T. ,"1=Base Condiçao Especial do INSS"     })            
	aadd(aLista,{'[INS:ALIQ_CONDI_ESPECIAL]'    ,4,'N', 'IT_ALIQINA'        ,{IT_ALIQINA}    ,.F. ,"2=Alíquota Condiçao Especial do INSS" })                
	aadd(aLista,{'[INS:VALOR_CONDI_ESPECIAL]'   ,4,'N', 'IT_BASEINA'        ,{IT_BASEINA}    ,.T. ,"3=Valor Condiçao Especial do INSS"    })             
	aadd(aLista,{'[INS:VALOR_PATRONAL]'         ,4,'N', 'IT_VALINP'         ,IT_VALINP       ,.T. ,"4=Valor do Patronal"                  })
	aadd(aLista,{'[INS:BASE_PATRONAL]'          ,4,'N', 'IT_BASEINP'        ,IT_BASEINP      ,.T. ,"5=Base do Patronal"                   })
	aadd(aLista,{'[INS:ALIQ_PATRONAL]'          ,4,'N', 'IT_PERCINP'        ,IT_PERCINP      ,.F. ,"6=Alíquota Patronal"                  })
	aadd(aLista,{'[INS:VALOR_SERV_15ANOS]'      ,4,'N', 'IT_SECP15'         ,{IT_SECP15}     ,.T. ,"7=Valor Serviço 15 Anos"              })   
	aadd(aLista,{'[INS:BASE_15ANOS]'            ,4,'N', 'IT_BSCP15'         ,{IT_BSCP15}     ,.T. ,"8=Base Serviço 15 Anos"               })  
	aadd(aLista,{'[INS:ALIQ_15ANOS]'            ,4,'N', 'IT_ALCP15'         ,{IT_ALCP15}     ,.F. ,"9=Alíquota Serviço 15 Anos"           })      
	aadd(aLista,{'[INS:VALOR_15ANOS]'           ,4,'N', 'IT_VLCP15'         ,{IT_VLCP15}     ,.T. ,"10=Valor 15 Anos"                  	  })
	aadd(aLista,{'[INS:VALOR_SERV_20ANOS]'      ,4,'N', 'IT_SECP20'         ,{IT_SECP20}     ,.T. ,"11=Valor Serviço 20 Anos"             })   
	aadd(aLista,{'[INS:BASE_20ANOS]'            ,4,'N', 'IT_BSCP20'         ,{IT_BSCP20}     ,.T. ,"12=Base Serviço 20 Anos"              })  
	aadd(aLista,{'[INS:ALIQ_20ANOS]'            ,4,'N', 'IT_ALCP20'         ,{IT_ALCP20}     ,.F. ,"13=Alíquota Serviço 20 Anos"          })      
	aadd(aLista,{'[INS:VALOR_20ANOS]'           ,4,'N', 'IT_VLCP20'         ,{IT_VLCP20}     ,.T. ,"14=Valor 20 Anos"                  	  })
	aadd(aLista,{'[INS:VALOR_SERV_25ANOS]'      ,4,'N', 'IT_SECP25'         ,{IT_SECP25}     ,.T. ,"15=Valor Serviço 25 Anos"             })   
	aadd(aLista,{'[INS:BASE_25ANOS]'            ,4,'N', 'IT_BSCP25'         ,{IT_BSCP25}     ,.T. ,"16=Base Serviço 25 Anos"              })  
	aadd(aLista,{'[INS:ALIQ_25ANOS]'            ,4,'N', 'IT_ALCP25'         ,{IT_ALCP25}     ,.F. ,"17=Alíquota Serviço 25 Anos"          })      
	aadd(aLista,{'[INS:VALOR_25ANOS]'           ,4,'N', 'IT_VLCP25'         ,{IT_VLCP25}     ,.T. ,"18=Valor 25 Anos"                  	  })
Endif	
	//COFRET
If lTodos .or.  cTpRef == "F18"
	aadd(aLista,{'[COF:BASE_COFINS_RET]'           ,4,'N', 'IT_BASECOF'     ,IT_BASECOF    ,.T. ,"1=Base de Cálculo de Cofins Retenção"		 })
	aadd(aLista,{'[COF:ALIQ_COFINS_RET]'           ,4,'N', 'IT_ALIQCOF'     ,IT_ALIQCOF    ,.F. ,"2=Alíquota do Cofins Retenção"			 })
	aadd(aLista,{'[COF:VALOR_COFINS_RET]'          ,4,'N', 'IT_VALCOF'      ,IT_VALCOF     ,.T. ,"3=Valor do Cofins Retenção"				 })
	aadd(aLista,{'[COF:SIT_TRIB_COF]'              ,4,'C', 'LF_CSTCOF'      ,LF_CSTCOF     ,.F. ,"4=Situação Tributária de Cofins Retenção"  })
Endif
	//PISRET
If lTodos .or.  cTpRef == "F20"
	aadd(aLista,{'[PIS:BASE_PIS_RET]'           ,4,'N', 'IT_BASEPIS'     ,IT_BASEPIS   ,.T. ,"1=Base de Cálculo  PIS Retenção"			 })
	aadd(aLista,{'[PIS:ALIQ_PIS_RET]'           ,4,'N', 'IT_ALIQPIS'     ,IT_ALIQPIS   ,.F. ,"2=Alíquota do PIS Retenção"				 })
	aadd(aLista,{'[PIS:VALOR_PIS_RET]'          ,4,'N', 'IT_VALPIS'      ,IT_VALPIS    ,.T. ,"3=Valor do PIS Retenção"				 	 })
	aadd(aLista,{'[PIS:SIT_TRIB_PIS]'           ,4,'C', 'LF_CSTPIS'      ,LF_CSTPIS    ,.F. ,"4=Situação Tributária de PIS Retenção"	 })
Endif

	//CF3
If lTodos .or.  cTpRef == "F19"
	aadd(aLista,{'[CF3:BASE_COFINS_ST]'           ,4,'N', 'IT_BASECF3'     ,IT_BASECF3  ,.T. ,"1=Base de Cálculo do Cofins ST"	   })
	aadd(aLista,{'[CF3:ALIQ_COFINS_ST]'           ,4,'N', 'IT_ALIQCF3'     ,IT_ALIQCF3  ,.F. ,"2=Alíquota do Cofins ST"			   })
	aadd(aLista,{'[CF3:VALOR_COFINS_ST]'          ,4,'N', 'IT_VALCF3'      ,IT_VALCF3   ,.T. ,"3=Valor do Cofins ST"			   })
	aadd(aLista,{'[CF3:SIT_TRIB_COF]'             ,4,'C', 'LF_CSTCOF'      ,LF_CSTCOF   ,.F. ,"4=Situação Tributária de Cofins ST" })
Endif
	//PS3
If lTodos .or.  cTpRef == "F21"
	aadd(aLista,{'[PS3:BASE_PIS_ST]'           ,4,'N', 'IT_BASEPS3'     ,IT_BASEPS3   ,.T. ,"1=Base de Cálculo do PIS ST"	 })
	aadd(aLista,{'[PS3:ALIQ_PIS_ST]'           ,4,'N', 'IT_ALIQPS3'     ,IT_ALIQPS3   ,.F. ,"2=Alíquota do PIS ST"			 })
	aadd(aLista,{'[PS3:VALOR_PIS_ST]'          ,4,'N', 'IT_VALPS3'      ,IT_VALPS3    ,.T. ,"3=Valor do PIS ST"				 })
	aadd(aLista,{'[PS3:SIT_TRIB_PIS]'          ,4,'C', 'LF_CSTPIS'      ,LF_CSTPIS    ,.F. ,"4=Situação Tributária de PIS ST"})
Endif

	//FRTAUT 
If lTodos .or.  cTpRef == "E16"
	aadd(aLista,{'[FRTAUT:VALOR_FRETE_AUTO]'          ,4,'N', 'IT_AUTONOMO'      ,IT_AUTONOMO   ,.T.  ,"1=Valor Frete Autônomo"})
EndIf
	//ESTICM
If lTodos .or.  cTpRef == "E25"
	aadd(aLista,{'[ESTICM:VALOR_ESTORNO_CRED]'          ,4,'N', 'IT_ESTCRED'      ,IT_ESTCRED   ,.T.  ,"1=Valor Estorno de Credito ICMS"})
Endif
	//FRTEMB 
If lTodos .or.  cTpRef == "E17"
	aadd(aLista,{'[FRTAUT:BASE_FRETE_EMBAR]'           ,4,'N', 'IT_BASETST'      ,IT_BASETST    ,.T. ,"1=Base de Cálculo do Frete Embarcador"   })
	aadd(aLista,{'[FRTAUT:ALIQ_FRETE_EMBAR]'           ,4,'N', 'IT_ALIQTST'      ,IT_ALIQTST    ,.F. ,"2=Alíquota do do Frete Embarcador"		})
	aadd(aLista,{'[FRTAUT:VALOR_FRETE_EMBAR]'          ,4,'N', 'IT_VALTST'       ,IT_VALTST     ,.T. ,"3=Valor do do Frete Embarcador"   		})
EndIf

 //Quando processar todos itens deve adicionar no hash e limpar array
IF lTodos .and. ValType(oHMCad) =='O'
  oHMCad := AToHM(aLista)

  aLista := aSize(aLista,0)
  aLista := Nil
  
Endif

Return(aLista)


/*/{Protheus.doc} NewHash
	(Função Cria objetos do hash)

	@type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021

/*/
Static Function NewHash(oHMCad)
    
    oHMCad  := HMNew()

Return(oHMCad)

/*/{Protheus.doc} FindHash
	(Função para encontrar o hash)

	@type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021

	@param oHMCad, objeto, contém o hash
	@param cChave, caracter, contém a chave

	@return nPosRet, numerico, posição contido no hash
/*/
Function FindHash(oHMCad,cChave)
Local Array    := {}

HMGet(oHMCad,Upper(cChave),@Array)

Return Array

/*/{Protheus.doc} FinishHash
	(Função Finaliza objetos do hash)

	@type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021

	
/*/
Function FISXDFIH(oHMCad)
    HMClean(oHMCad)
    FreeObj(oHMCad)
    oHMCad := Nil
          
Return 

/*/{Protheus.doc} Converter
    (Função responsavel por ler o Array AGRAVA da função xMaFisAjIt, criar um novo array alimpo agrupando por chaves : 
    Exenplo Codigo de Lançamento ou Codigo de lançamento + CFOP)
    aNfCab      -> Array com dados do cabeçalho da nota
	aNFItem     -> Array com dados item da nota
	nItem       -> Item que esta sendo processado	
	aInfNat	    -> Array com dados da natureza
    aSX6        -> Array com o cacheamento dos parâmetros SX6
    aPos        -> Array com cache dos fieldpos
    aDic        -> Array com cache de aliasindic
    aPE         -> Array com Ponto de Entrada

    @type Static Function
	@author Bruce Egnor, Matheus Henrique Semanaka 
	@since 20/04/2021
    /*/
Function FISXDAGR(oHMCad, lBuild, aNfCab, aNfItem, aPos, aSX6, aDic, aPE, aInfNat,cNumNF, cSerie, cCliFor, cLoja,cFormul,cEspecie,cTpOper, nCaso )

Local aGrava    := {}
Local nI        := 0
Local nz        := 0
Local cTexto    := ""
Local oHaLimpo  := Nil
Local cChave    := ""
Local aVal      := {}
Local aValMsg   := {}
Local cIndice   := ""
Local aItens    := {}
Local aCtrl     := {}
Local aRetHash  := {}
Local cChvCDA   := ""
Local cChvCDV	:= ""
Local cIdCJL	:= ""
Local cInd		:= ""
Local cItem		:= ""
//Posições do aGrava
Local nPosIdMsg := 18 //aGrava[1][18] //ID Mensagem
Local nPosItem  := 01 //aGrava[1][01] //Item
Local nPosCodLa := 02 //aGrava[1][19] //Chave

//Posições do aMsgs
Local nPosTexto := 02
Local cMensagem := ""

//Default aGrava:= {}
Default cNumNf   := ""
Default cSerie   := ""
Default cCliFor  := ""
Default cLoja    := ""
Default cFormul  := ""
Default cEspecie := ""
Default aNfCab   := {}
Default aNfItem	 := {}
Default aInfNat  := {} 

if oHaLimpo == Nil
    //Cria o Hash
    oHaLimpo:= NewHash(oHaLimpo)
endif

cFormul  := IIF(!Empty(cFormul), cFormul, IIF(cTpOper == "E"," ","S"))
//Processa o aGrava, para montar o array aLimpo onde //limpa array //agrupar //ordenar
If nCaso == 1 // Quando for inclusão	 
	aGrava := xMaFisAjIt(,2, aNfCab, aNfItem, aPos, aSX6, aDic, aPE ) //Passando como 2 irá processar todos os itens
	For nI:=1 to len(aGrava)  

		If Len(aGrava[nI]) > 17 .And. !Alltrim(aGrava[nI][22]) == ""

			cIdCJL	 := FWUUID("CJL")
			cItem    := Alltrim(aGrava[nI][1])
			cCodLan  := PADR(aGrava[nI][2],10,"")
	
			If Alltrim(aGrava[nI][14]) == "4" 
				cChvCDV  := cTpOper+cEspecie+cFormul+cNumNf+cSerie+cCliFor+cLoja+cItem
				dbSelectArea("CDV")
				CDV->(dbSetOrder(4))

				If CDV->(MsSeek(xFilial("CDV")+cChvCDV))
					While !CDV->(Eof()) .And. xFilial("CDV")+cChvCDV == Alltrim(CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA+CDV_NUMITE)) 
					
						If Alltrim(cCodLan) == CDV->CDV_CODAJU 
							Reclock("CDV", .F.)
							CDV->CDV_IDMSG	:= cIdCJL
							CDV->(MsUnlock())
							CDV->(FkCommit())
							Endif
						CDV->(dbSkip())
					Enddo	
				Endif
			
			Else
				cChvCDA  := cTpOper+cEspecie+cFormul+cNumNf+cSerie+cCliFor+cLoja+cItem
				dbSelectArea("CDA")
				CDA->(dbSetOrder(1))

				If CDA->(MsSeek(xFilial("CDA")+cChvCDA))
					While !CDA->(Eof()) .And. xFilial("CDA")+cChvCDA == Alltrim(CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE))
					
						If cCodLan == CDA->CDA_CODLAN 
							Reclock("CDA", .F.)
							CDA->CDA_IDMSG	:= cIdCJL
							CDA->(MsUnlock())
							CDA->(FkCommit())
						Endif
						CDA->(dbSkip())
					Enddo	
				Endif
			Endif
		

			For nPosIdMsg := 18 to 20
				if !empty(aGrava[nI][nPosIdMsg]) //Se não existir msg não processa.

					//Formato puramente Hash
					//Busco no Hash oHaLimpo se ja existe a chave + o id da mensagem
					cPosIdMSg := CValToChar(nPosIdMsg)
					cChave  := HMKey({aGrava[nI][nPosCodLa],cPosIdMSg,aGrava[nI][nPosItem]},1,3,2,3,3,3)
					aVal    := FindHash(oHaLimpo,cChave) //Procuro no Hash a chave
					cIndice := Iif(nPosIdMsg == 18, "03",iif(nPosIdMsg == 19,"01","02"))
					
					if empty(aVal) //Se não encotrou a chave

							CJ8->(dbSetOrder(1))
							If (CJ8->(MsSeek(xFilial("CJ8")+aGrava[nI][nPosIdMsg])))
								cTexto:= CJ8->CJ8_MENSG
							Endif	
							//Adiciono o ID msg e o texto para poder utilizar.
							aValMsg := {{aGrava[nI][nPosIdMsg],cTexto}}
						//Adiciona no Hash os dados do aGrava com a chave
						HMAdd(oHaLimpo, {aGrava[nI][nPosCodLa],aGrava[nI][nPosIdMsg],{aGrava[nI][nPosItem]},aValMsg[1][nPosTexto],cIdCJL,cIndice,cPosIdMsg,aGrava[nI][nPosItem]},1,3,7,3,8,3)
					endif
				endif
			Next	
		Endif	
	Next

	//Lista os elementos do Hash para o Array 
	if HMList( oHaLimpo, @aItens)

		for nZ:=1 to len(aItens)
			
			//aItens[nZ][2][1][2] //Id da mensagem, //aItens[nZ][2][1][3] //Array de itens, //aItens[nZ][2][1][4] //mensagem texto
			cMensagem := MensagRef(@oHMCad, lBuild, aNfCab, aNfItem, aInfNat, aItens[nZ][2][1][4], aItens[nZ][2][1][3], aRetHash)

			If Reclock("CJL", .T.)
				CJL->CJL_FILIAL 	:= xFilial("CJL")
				CJL->CJL_ID 		:= aItens[nZ][2][1][5]
				CJL->CJL_CODMSG 	:= aItens[nZ][2][1][2]
				CJL->CJL_INDICE 	:= aItens[nZ][2][1][6]
				CJL->CJL_MENSG 		:= cMensagem
				CJL->(MsUnlock())
			Endif	
		next

	Endif
ElseIf nCaso == 2 //Quando for exclusão	

	cChavEx := cTpOper+cEspecie+cFormul+cNumNf+cSerie+cCliFor+cLoja
	dbSelectArea("CDA")
	CDA->(dbSetOrder(1))
	dbSelectArea("CDV")
	CDV->(dbSetOrder(4))
	If CDV->(MsSeek(xFilial("CDV")+cChavEx))
		While !CDV->(Eof()) .And. xFilial("CDV")+cChavEx == CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA) 
			cInd := xFilial("CDV") + CDV->CDV_IDMSG
			If CJL->(MsSeek(cInd) )
				While !CJL->(Eof()) .And. cInd == CJL->CJL_FILIAL + CJL->CJL_ID
					If Reclock("CJL", .F.)
						CJL->(DbDelete())
						CJL->(MsUnlock())
						CJL->(FkCommit())
					Endif
					CJL->(dbSkip())		
				Enddo		
			Endif	
			CDV->(DbSkip())
		Enddo
	Endif	
	If CDA->(MsSeek(xFilial("CDA")+cChavEx))
		While !CDA->(Eof()) .And. xFilial("CDA")+cChavEx == CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA) 
			cInd := xFilial("CDA") + CDA->CDA_IDMSG
			If CJL->(MsSeek(cInd) )
				While !CJL->(Eof()) .And. cInd == CJL->CJL_FILIAL + CJL->CJL_ID
					If Reclock("CJL", .F.)
						CJL->(DbDelete())
						CJL->(MsUnlock())
						CJL->(FkCommit())
					Endif
					CJL->(dbSkip())		
				Enddo
			Endif	
			CDA->(DbSkip())
		Enddo
	Endif
Else
	Return
Endif

//Limpa os objetos de Hash
FISXDFIH(oHaLimpo)
//Limpa array aItens
FwFreeArray(aItens) 
FwFreeArray(aValMsg)
FwFreeArray(aGrava)
FwFreeArray(aVal)
FwFreeArray(aCtrl)
FwFreeArray(aRetHash) 

Return




















