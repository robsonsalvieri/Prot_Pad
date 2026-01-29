#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "MATXDEF.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TBICODE.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LjTaxEAI
Função para cálculo reverso de impostos, quando a Integração não envia Impostos.
Cálcula IPI

@param aCab     - Cabeçalho do orçamento
@param aItem    - Itens do orçamento
@param lTabTemp - Define se será utilizada a tabela temporaria do orçamento (SLQ\SLR ou SL1\SL2)

@since 	 04/06/19
@version 2.0
/*/
//------------------------------------------------------------------
Function LjTaxEAI(aCab, aItem, lTabTemp)

    Local aArea         := GetArea()
    Local aAreaSB1      := SB1->( GetArea() )
    Local aAreaSF4      := SF4->( GetArea() )
    Local nItem			:= 0
    Local nVlrUnit		:= 0
    Local nVlrItem		:= 0
    Local nAliRedIpi	:= 0
    Local nPosProduto	:= 0
    Local nPosTes       := 0
    Local nPosQuant	    := 0
    Local nPosVrUnit    := 0
    Local nPosValDes	:= 0
    Local nPosVlrIte	:= 0
    Local nPosValIpi    := 0
    Local nPosIpi   	:= 0
    Local nPosBasIpi	:= 0
    Local nPosDesPro	:= 0
    Local nPosValFre    := 0
    Local nPosVlrDesp   := 0
    Local aItemLoad		:= {}
    Local nRedBasIpi    := 1
    Local cCodCli       := ""
    Local cLojCli       := ""
    Local cTipoNF       := ""
    Local cCliFor       := ""
    Local cTipoCli      := ""
    Local nVlrIpi       := 0
    Local nValDesp      := 0
    Local nVlrItFrete   := 0
    Local lAtualiza     := .F.
    Local nMoedaCor     := 1
    Local nDecimais     := MsDecimais(nMoedaCor)
    Local lMvArrefat	:= (SuperGetMv("MV_ARREFAT") == "S")
    Local cCmpCaFre     := ""
    Local cCmpCaDes     := ""
    Local cCmpCaTot     := ""
    Local cCmpCaLiq	    := ""
    Local cCmpCaBru	    := ""
    Local cCmpCaMer	    := ""
    Local cCmpCaVIpi    := ""
    Local cCmpCaBIpi	:= ""
    Local cCmpCaTipo	:= ""
    Local cCmpCaCli     := ""
    Local cCmpCaLoja    := ""
    Local cCmpCaTipC    := ""
    Local nPosCaFre     := 0
    Local nPosCaDes     := 0
    Local nPosCaTot     := 0
    Local nPosCaLiq	    := 0
    Local nPosCaBru	    := 0
    Local nPosCaMer	    := 0
    Local nPosCaVIpi    := 0
    Local nPosCaBIpi	:= 0
    Local nPosCaTipo	:= 0
    Local nPosCaCli     := 0
    Local nPosCaLoja    := 0
    Local nPosCaTipC    := 0
    Local cCmpProduto   := ""
    Local cCmpTes		:= ""
    Local cCmpQuant	    := ""
    Local cCmpVrUnit	:= ""
    Local cCmpPrcTab	:= ""
    Local cCmpVlrIte	:= ""
    Local cCmpValDes    := ""
    Local cCmpDesPro	:= ""
    Local cCmpValIpi	:= ""
    Local cCmpBasIpi    := ""
    Local cCmpIpi	    := ""
    Local cCmpValFre    := ""
    Local cCmpVlrDesp   := ""
    Local nMvIpiFrRev   := SuperGetMv("MV_LJIPIFR",,0)	//Parâmetro determina se a integração irá realizar a reversão do cálculo de IPI no valor do frete. 0 (Padrão) = não realiza a reversão de IPI no frete, somente no produto. 1 = realiza a reversão de IPI tanto no frete quanto no produto.
    Local nVlBkVrIt     := 0
    Local nVlBkItFre    := 0
    Local nDifFrete     := 0
    Local lIpiFrete     := .F.
    Local nItIpi        := 0
    Local lCfgTrib  := IIf(ExistFunc("LjCfgTrib"), LjCfgTrib(), .F.) // Verifica se pode ou nao utilizar o Configurador de Tributos.
    

    Default lTabTemp    := .T.

    If Len(aItem) > 0

        LjGrvLog("LjTaxEAI", "Inicia calculo de impostos - MaFisIni")

        //Carrega campos do cabeçalho
        cCmpCaFre   := IIF( lTabTemp, "LQ_FRETE"    , "L1_FRETE"    )
        cCmpCaDes   := IIF( lTabTemp, "LQ_DESPESA"  , "L1_DESPESA"  )
        cCmpCaTot   := IIF( lTabTemp, "LQ_VLRTOT"   , "L1_VLRTOT"   )
        cCmpCaLiq	:= IIF( lTabTemp, "LQ_VLRLIQ"   , "L1_VLRLIQ"   )
        cCmpCaBru	:= IIF( lTabTemp, "LQ_VALBRUT"  , "L1_VALBRUT"  )
        cCmpCaMer	:= IIF( lTabTemp, "LQ_VALMERC"  , "L1_VALMERC"  )
        cCmpCaVIpi  := IIF( lTabTemp, "LQ_VALIPI"   , "L1_VALIPI"   )
        cCmpCaBIpi	:= IIF( lTabTemp, "LQ_BASEIPI"  , "L1_BASEIPI"  )
        cCmpCaTipo	:= IIF( lTabTemp, "LQ_TIPO"     , "L1_TIPO"     )
        cCmpCaCli   := IIF( lTabTemp, "LQ_CLIENTE"  , "L1_CLIENTE"  )
        cCmpCaLoja  := IIF( lTabTemp, "LQ_LOJA"     , "L1_LOJA"     )
        cCmpCaTipC  := IIF( lTabTemp, "LQ_TIPOCLI"  , "L1_TIPOCLI"  )

        nPosCaFre   := Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaFre } )
        nPosCaDes   := Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaDes } )
        nPosCaTot   := Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaTot } )
        nPosCaLiq	:= Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaLiq } )
        nPosCaBru	:= Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaBru } )
        nPosCaMer	:= Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaMer } )
        nPosCaVIpi  := Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaVIpi} )
        nPosCaBIpi	:= Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaBIpi} )
        nPosCaTipo	:= Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaTipo} )
        nPosCaCli   := Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaCli } )
        nPosCaLoja  := Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaLoja} )
        nPosCaTipC  := Ascan(aCab, {|x| Alltrim(x[1]) == cCmpCaTipC} )

        //Carrega campos do item
        cCmpProduto := IIF( lTabTemp, "LR_PRODUTO"  , "L2_PRODUTO"  )
        cCmpTes		:= IIF( lTabTemp, "LR_TES"      , "L2_TES"      )
        cCmpQuant	:= IIF( lTabTemp, "LR_QUANT"    , "L2_QUANT"    )
        cCmpVrUnit	:= IIF( lTabTemp, "LR_VRUNIT"   , "L2_VRUNIT"   )
        cCmpPrcTab	:= IIF( lTabTemp, "LR_PRCTAB"   , "L2_PRCTAB"   )
        cCmpVlrIte	:= IIF( lTabTemp, "LR_VLRITEM"  , "L2_VLRITEM"  )
        cCmpValDes  := IIF( lTabTemp, "LR_VALDESC"  , "L2_VALDESC"  )
        cCmpDesPro	:= IIF( lTabTemp, "LR_DESCPRO"  , "L2_DESCPRO"  )
        cCmpValIpi	:= IIF( lTabTemp, "LR_VALIPI"   , "L2_VALIPI"   )
        cCmpBasIpi  := IIF( lTabTemp, "LR_BASEIPI"  , "L2_BASEIPI"  )
        cCmpIpi	    := IIF( lTabTemp, "LR_IPI"      , "L2_IPI"      )
        cCmpValFre  := IIF( lTabTemp, "LR_VALFRE"   , "L2_VALFRE"   )
        cCmpVlrDesp := IIF( lTabTemp, "LR_DESPESA"  , "L2_DESPESA"  )

        nPosProduto := Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpProduto})
        nPosTes		:= Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpTes    })
        nPosQuant	:= Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpQuant  })
        nPosVrUnit	:= Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpVrUnit })
        nPosPrcTab	:= Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpPrcTab })
        nPosVlrIte	:= Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpVlrIte })
        nPosValDes  := Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpValDes })
        nPosDesPro	:= Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpDesPro })
        nPosValIpi	:= Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpValIpi })
        nPosBasIpi  := Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpBasIpi })
        nPosIpi	    := Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpIpi    })
        nPosValFre  := Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpValFre })
        nPosVlrDesp := Ascan(aItem[1], {|x| Alltrim(x[1]) == cCmpVlrDesp})

        //Carrega tipo do documento fiscal que deverá ser gerado
        cTipoNF  := aCab[nPosCaTipo][2]
        cTipoNF  := StrTran(cTipoNF, "V", "N")     //Venda para Normal
        cTipoNF  := StrTran(cTipoNF, "P", "N")     //Pedido para Normal

        cCodCli  := Padr(aCab[nPosCaCli][2] , TamSx3(cCmpCaCli)[1]  )
        cLojCli  := Padr(aCab[nPosCaLoja][2], TamSx3(cCmpCaLoja)[1] )
        cCliFor  := IIF(cTipoNF $ "B|D", "F", "C")
        cTipoCli := aCab[nPosCaTipC][2]

        //Inicializa o Calculo das operacoes Fiscais
        MaFisIni(	cCodCli			,;	// 01-Codigo Cliente/Fornecedor
                    cLojCli			,;	// 02-Loja do Cliente/Fornecedor
                    cCliFor	        ,;	// 03-C:Cliente , F:Fornecedor
                    cTipoNF         ,; 	// 04-Tipo da NF( "N","D","B","C","P","I","S" ) 
                    cTipoCli		,;	// 05-Tipo do Cliente/Fornecedor
                    Nil				,;	// 06-Relacao de Impostos que suportados no arquivo
                    Nil				,;	// 07-Tipo de complemento
                    .F.				,;	// 08-Permite Incluir Impostos no Rodape .T./.F.
                    "SB1"			,;	// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                    "LOJA701"     	,;	// 10-Nome da rotina que esta utilizando a funcao
                    Nil				,;	// 11-Tipo de documento
                    Nil				,;	// 12-Especie do documento 
                    Nil				,;	// 13-Codigo e Loja do Prospect 
                    Nil				,;	// 14-Grupo Cliente
                    Nil				,;	// 15-Recolhe ISS
                    Nil				,;	// 16-Codigo do cliente de entrega na nota fiscal de saida
                    Nil				,;	// 17-Loja do cliente de entrega na nota fiscal de saida
                    Nil				,;	// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
                    .F.				,;	// 19- No momento o PDV nao emite NF , por isso sempre falso   
                    .T.				,;  // 20-Define se calcula IPI (SIGALOJA)
                    Nil				,;  // 21-Pedido de Venda
                    Nil             ,;	// 22	
                    Nil             ,;	// 23
                    Nil             ,;	// 24
                    Nil             ,;  // 25
					Nil				,;	// 26
					Nil				,;	// 27
					Nil				,;	// 28
					Nil				,;	// 29
					Nil				,;	// 30
					Nil				,;	// 31
					Nil				,;	// 32
					lCfgTrib)			// 33

        If nPosCaFre > 0
            MaFisLoad("NF_FRETE"  , IIF(nMvIpiFrRev == 0,aCab[nPosCaFre][2],0))
        EndIf

        If nPosCaDes > 0        
            MaFisLoad("NF_DESPESA", aCab[nPosCaDes][2])
        EndIf

        For nItem:=1 To Len(aItem)

            //Posiciona nas tabelas
            SB1->( DbSetOrder(1) )  //B1_FILIAL+B1_COD
            SB1->( DbSeek(xFilial("SB1") + aItem[nItem][nPosProduto][2]) )          

            SF4->( DbSetOrder(1) )  //F4_FILIAL+F4_CODIGO
            SF4->( DbSeek(xFilial("SF4") + aItem[nItem][nPosTes][2]) )

            nRedBasIpi  := 1
            
            nVlrUnit    := aItem[nItem][nPosVrUnit][2]


            nVlrItem    := aItem[nItem][nPosVlrIte][2]
            nVlBkVrIt   := aItem[nItem][nPosVlrIte][2]

            nVlrItFrete := IIF( nPosValFre  > 0, aItem[nItem][nPosValFre][2] , 0 )
            nVlBkItFre  := IIF( nPosValFre  > 0, aItem[nItem][nPosValFre][2] , 0 )

            nValDesp    := IIF( nPosVlrDesp > 0, aItem[nItem][nPosVlrDesp][2], 0 )
            nVlrDesc    := IIF(SF4->F4_TPIPI == 'L', IIF( nPosDesPro > 0, aItem[nItem][nPosDesPro][2], 0 ) + IIF( nPosValDes > 0, aItem[nItem][nPosValDes][2], 0 ), 0)

            If SF4->F4_IPI == 'S'
                If SF4->F4_IPIFRET == 'S'
                    If nMvIpiFrRev == 0                    
                        nVlrItem := nVlrItem + nVlrItFrete 
                        LjGrvLog("LjTaxEAI", "O item " + CValToChar(nItem) + ", está configurado para incluir o frete no IPI do Produto. (Parâmetro MV_LJIPIFR = 0)") 
                    Else    
                        LjGrvLog("LjTaxEAI", "O item " + CValToChar(nItem) + ", irá calcular o IPI com o valor do frete, e a reversão será realizada também no valor do frete. (Parâmetro MV_LJIPIFR = 1)") 
                    EndIf
                EndIf            
                If SF4->F4_DESPIPI == 'S'
                    nVlrItem := nVlrItem + nValDesp
                    LjGrvLog("LjTaxEAI", "O item " + CValToChar(nItem) + ", esté configurado para incluir a despesa no IPI do Produto.")             
                EndIf                               
            EndIf
            
            //Inicializa o Calculo das operacoes Fiscais por item 
            aItemLoad := {}
            Aadd( aItemLoad , SB1->B1_COD               	    ) // IT_PRODUTO
            Aadd( aItemLoad , SF4->F4_CODIGO                    ) // IT_TES
            Aadd( aItemLoad , ""								) // IT_CODISS
            Aadd( aItemLoad , aItem[nItem][nPosQuant][2]		) // IT_QUANT
			Aadd( aItemLoad , ""                                ) // IT_NFORI
            Aadd( aItemLoad , ""								) // IT_SERIORI
            Aadd( aItemLoad , SB1->( Recno() )                  ) // IT_RECNOSB1
            Aadd( aItemLoad , SF4->( Recno() )                  ) // IT_RECNOSF4
            Aadd( aItemLoad , 0		 							) // IT_RECORI
            Aadd( aItemLoad , ""            					) // IT_LOTECTL
            Aadd( aItemLoad , ""								) // IT_NUMLOTE
            Aadd( aItemLoad , ""								) // IT_PRDFIS
            Aadd( aItemLoad , ""								) // IT_RECPRDF
            Aadd( aItemLoad , "" 				 				) // IT_TPOPER

            //Rotina inicializacao do item da funcao Fiscal
            LjGrvLog("LjTaxEAI", "Carrega informações do item - MaFisIniLoad", aItemLoad)
            MaFisIniLoad(nItem, aItemLoad, .F.)
            
            MaFisLoad( "IT_PRCUNI" 	, nVlrUnit, nItem)
            MaFisLoad( "IT_DESCONTO", IIF( nPosValDes > 0, aItem[nItem][nPosValDes][2], 0 ), nItem)
            MaFisLoad( "IT_DESCTOT" , IIF( nPosDesPro > 0, aItem[nItem][nPosDesPro][2], 0 ), nItem)
            MaFisLoad( "IT_VALMERC" , nVlrItem, nItem)
            
            //Fas o cálculo do item
            LjGrvLog("LjTaxEAI", "Cálcula item - MaFisRecal", nItem)
            MaFisRecal("" , nItem) 

            //Calculo reverso do IPI
            nVlrIpi := MaFisRet(nItem, "IT_VALIPI")            
            If nVlrIpi > 0
                nItIpi := nItem
                LjGrvLog("LjTaxEAI", "Faz cálculo reverso do IPI", nItem)            

                //Ipi de Pauta
                If SB1->B1_VLR_IPI > ( nVlrIpi / aItem[nItem][nPosQuant][2] )

                    nVlrUnit := nVlrUnit - SB1->B1_VLR_IPI

                //Ipi por aliquota com ou sem redução de base
                Else
            
                    //Reduz aliquota de IPI, caso tenha redução de base
                    nRedBasIpi  := IIF(SF4->F4_BASEIPI > 0, SF4->F4_BASEIPI / 100, 1) 
                    nAliRedIpi  := MaFisRet(nItem, "IT_ALIQIPI") * nRedBasIpi                    

                    If lMvArrefat
                        nVlrUnit    := a410Arred(((nVlrItem - nVlrDesc)/ ( (nAliRedIpi / 100) + 1) ) / aItem[nItem][nPosQuant][2],"L2_VRUNIT",nMoedaCor)                                              
                    Else
                        nVlrUnit    := NoRound(((nVlrItem - nVlrDesc) / ( (nAliRedIpi / 100) + 1) ) / aItem[nItem][nPosQuant][2],nDecimais)
                    EndIf 

                    If SF4->F4_IPIFRET == 'S' .And. nMvIpiFrRev == 1 .And. nPosValFre  > 0 //Realiza o calculo reverso do IPI no frete                        
                        lIpiFrete := .T.                                                                     
                        nVlrItFrete := IIF(lMvArrefat,a410Arred(nVlrItFrete / ( (nAliRedIpi / 100) + 1),"L2_VALFRE",nMoedaCor),NoRound(nVlrItFrete / ( (nAliRedIpi / 100) + 1),nDecimais)) 

                        aItem[nItem][nPosValFre][2] := nVlrItFrete                    
                        
                    EndIf 
                EndIf              

                //Atualiza valores
                nVlrItem := nVlrUnit * aItem[nItem][nPosQuant][2]

                aItem[nItem][nPosVrUnit][2] := nVlrUnit + (nVlrDesc / aItem[nItem][nPosQuant][2])
                aItem[nItem][nPosVlrIte][2] := nVlrItem + nVlrDesc
                lAtualiza                   := .T.
            Endif                
                        
            //Atualiza a MatxFis com os valores do Item
            MaFisLoad("IT_PRCUNI"   , aItem[nItem][nPosVrUnit][2], nItem)
            MaFisLoad("IT_DESCONTO" , IIF( nPosValDes > 0, aItem[nItem][nPosValDes][2], 0 ), nItem)
            MaFisLoad("IT_DESCTOT"  , IIF( nPosDesPro > 0, aItem[nItem][nPosDesPro][2], 0 ), nItem)
            MaFisLoad("IT_VALMERC"  , aItem[nItem][nPosVlrIte][2], nItem)  
            If nMvIpiFrRev == 1 
                MaFisLoad("IT_FRETE"  , nVlrItFrete, nItem)                                 
            EndIf
            //Recalcula item
            LjGrvLog("LjTaxEAI", "Recalcula item - MaFisRecal", nItem)
            MaFisRecal("", nItem)

            //Atualiza item com valores calculados
            If lAtualiza
                aItem[nItem][nPosVrUnit][2] := MaFisRet(nItem, "IT_PRCUNI" ) - Iif(SF4->F4_IPIFRET == 'S' .And. nMvIpiFrRev == 0, (nVlrItFrete/aItem[nItem][nPosQuant][2]), 0) - Iif(SF4->F4_DESPIPI == 'S', (nValDesp/aItem[nItem][nPosQuant][2]), 0)//Preço Unitário
                aItem[nItem][nPosPrcTab][2] := MaFisRet(nItem, "IT_PRCUNI" ) - Iif(SF4->F4_IPIFRET == 'S' .And. nMvIpiFrRev == 0, (nVlrItFrete/aItem[nItem][nPosQuant][2]), 0) - Iif(SF4->F4_DESPIPI == 'S', (nValDesp/aItem[nItem][nPosQuant][2]), 0)//Preço de Tabela
                aItem[nItem][nPosVlrIte][2] := MaFisRet(nItem, "IT_VALMERC") - Iif(SF4->F4_IPIFRET == 'S' .And. nMvIpiFrRev == 0, nVlrItFrete, 0) - Iif(SF4->F4_DESPIPI == 'S', nValDesp, 0)//Valor do Item
                
                //Valor IPI
                If nPosValIpi > 0
                    aItem[nItem][nPosValIpi][2] := MaFisRet(nItem, "IT_VALIPI")
                Else
                    Aadd( aItem[nItem], {cCmpValIpi, MaFisRet(nItem, "IT_VALIPI"), Nil} )
                EndIf

                //Base IPI
                If nPosBasIpi > 0 
                    aItem[nItem][nPosBasIpi][2] := MaFisRet(nItem, "IT_BASEIPI")
                Else
                    Aadd( aItem[nItem], {cCmpBasIpi, MaFisRet(nItem, "IT_BASEIPI"), Nil} )
                EndIf

                //Aliquota IPI
                If nPosIpi > 0 
                    aItem[nItem][nPosIpi][2] := MaFisRet(nItem, "IT_ALIQIPI")
                Else
                    Aadd( aItem[nItem], {cCmpIpi, MaFisRet(nItem, "IT_ALIQIPI"), Nil} )
                EndIf

                LjGrvLog("LjTaxEAI", "Item atualizado", aItem[nItem])
            EndIf

            //Fecha o calculo do item e atualiza os totalizadores do cabeçalho
            MaFisEndLoad(nItem, 2) 
        Next nItem

        //Atualiza cabeçalho com valores calculados
        If lAtualiza

            If nItIpi > 0 .And. nPosCaFre > 0 .And. MaFisRet(,"NF_FRETE") > 0 .And. lIpiFrete .And. MaFisRet(,"NF_TOTAL") <> (aCab[nPosCaTot][2] + aCab[nPosCaFre][2])

                nDifFrete := MaFisRet(,"NF_TOTAL") - (aCab[nPosCaTot][2] + aCab[nPosCaFre][2])
                If Abs(nDifFrete) == 0.01
                    aItem[nItIpi][nPosValIpi][2] -= nDifFrete                 
                    MafisAlt("IT_VALIPI",aItem[nItIpi][nPosValIpi][2],nItIpi)                    
                EndIf

            EndIf 

            aCab[nPosCaMer][2] := MaFisRet(,"NF_VALMERC") + Iif(SF4->F4_IPIFRET == 'S' .And. nMvIpiFrRev == 0, aCab[nPosCaFre][2] *-1, 0) + Iif(SF4->F4_DESPIPI == 'S', MaFisRet(,"NF_DESPESA") *-1, 0)

            //Loja701c, refaz o calculos destes campos, então é necessário o tratamento abaixo
            If !FWIsInCallStack("Envia")                
                aCab[nPosCaTot][2]  := MaFisRet(,"NF_TOTAL") + MaFisRet(,"NF_DESCTOT") + Iif(SF4->F4_IPIFRET == 'S' , aCab[nPosCaFre][2] *-1, 0) + Iif(SF4->F4_DESPIPI == 'S', MaFisRet(,"NF_DESPESA") *-1, 0)
                aCab[nPosCaLiq][2]  := MaFisRet(,"NF_TOTAL") + MaFisRet(,"NF_DESCTOT") + Iif(SF4->F4_IPIFRET == 'S' , aCab[nPosCaFre][2] *-1, aCab[nPosCaFre][2]) + Iif(SF4->F4_DESPIPI == 'S', MaFisRet(,"NF_DESPESA") *-1, 0)
                aCab[nPosCaBru][2]  := MaFisRet(,"NF_TOTAL") + MaFisRet(,"NF_DESCTOT") + Iif(SF4->F4_IPIFRET == 'S' , aCab[nPosCaFre][2] *-1, aCab[nPosCaFre][2]) + Iif(SF4->F4_DESPIPI == 'S', MaFisRet(,"NF_DESPESA") *-1, 0)
            EndIf

            //Valor IPI
            If nPosCaVIpi > 0
                aCab[nPosCaVIpi][2] := MaFisRet(,"NF_VALIPI")
            Else
                Aadd(aCab, {cCmpCaVIpi, MaFisRet(,"NF_VALIPI"), Nil} )
            EndIf

            //Base IPI
            If nPosCaBIpi > 0
                aCab[nPosCaBIpi][2] := MaFisRet(,"NF_BASEIPI")
            Else
                Aadd(aCab, {cCmpCaBIpi, MaFisRet(,"NF_BASEIPI"), Nil} )
            Endif

            LjGrvLog("LjTaxEAI", "Cabeçalho atualizado", aCab)
        EndIf

        LjGrvLog("LjTaxEAI", "Finaliza cálculo de impostos - MaFisEnd")
        MaFisEnd()

        FwFreeObj(aItemLoad)

        RestArea(aAreaSF4)
        RestArea(aAreaSB1)
        RestArea(aArea)
    Endif
		
Return Nil