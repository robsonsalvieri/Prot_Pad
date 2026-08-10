#INCLUDE "PROTHEUS.CH"
#INCLUDE "PSHMTPDVPROMO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PshMtProm
Função criada para venda Assistida do Loja701B para enviar 
informações para motor de promoções e retornar as promoções ativas.

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function PshMtPdvP(cFormPagto)
Local oConectPromo  := nil
Local cAssinante    := "MOTOR PROMOCOES" 
Local cProcesso     := "PROMOCOES"
Local nY            := 0
Local nRateio       := 0
Local nDel          := 0
Local oMdl          := STDGPBModel()
Local oModelCesta 	:= NIL
Local oModelMaster	:= NIL
Local oMdlPay	    := NIL

Default nValor      := 0
Default nVlrPago    := 0
Default lAbateISS   := .F.
Default nValAbISS   := .F.
DEFAULT cFormPagto  := ""

oModelMaster    := oMdl:GetModel("SL1MASTER")
oModelCesta     := oMdl:GetModel("SL2DETAIL")
oMdlPay         := oMdl:GetModel('SL4DETAIL') 

//Cria Objeto para transmissao do Motor de promoções
oConectPromo := PshMotorPromocoesOnlineObj():New(cAssinante,cProcesso)
//Alimenta o Body da Classe PshMotorPromocoesOnlineObj para conectar e retornar as promoções validas.
oConectPromo:Aformpgt               := StrTokArr(cFormPagto+',',',')
oConectPromo:OPUBLICA["LQ_FILIAL"]  := oModelMaster:GetValue("L1_FILIAL")
oConectPromo:OPUBLICA["LQ_NUM"]     := oModelMaster:GetValue("L1_NUM")
oConectPromo:OPUBLICA["LQ_VEND"]    := oModelMaster:GetValue("L1_VEND")
oConectPromo:OPUBLICA["LQ_CLIENTE"] := oModelMaster:GetValue("L1_CLIENTE")
oConectPromo:OPUBLICA["LQ_LOJA"]    := oModelMaster:GetValue("L1_LOJA")
oConectPromo:OPUBLICA["LQ_TIPOCLI"] := oModelMaster:GetValue("L1_TIPOCLI") 
oConectPromo:OPUBLICA["LQ_PDV"]     := "PDV"
oConectPromo:OPUBLICA["LQ_TIPO"]    := oModelMaster:GetValue("L1_TIPO")
oConectPromo:OPUBLICA["LQ_FORMA"]   := cFormPagto

For nY := 1 To oModelCesta:Length()
    oModelCesta:GoLine( nY )
    If !oModelCesta:IsDeleted()
        nRateio+= oModelCesta:GetValue("L2_QUANT") 
    EndIf
Next    


For nY := 1 To oModelCesta:Length()
    oModelCesta:GoLine( nY )
    If !oModelCesta:IsDeleted()
        //Adiciona estrutura json anterior para atualizar os dados
        If (nY-nDel) > 1
            aAdd(oConectPromo:OPUBLICA["SLR"],JsonObject():New()) //Ajustar esse ponto.
        EndIf
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_ITEM"]      := oModelCesta:GetValue("L2_ITEM")
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_PRODUTO"]   := Alltrim(oModelCesta:GetValue("L2_PRODUTO"))
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_QUANT"]     := oModelCesta:GetValue("L2_QUANT")
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_VRUNIT"]    := IIF(nVlrPago>0,nValor/nRateio,oModelCesta:GetValue("L2_VRUNIT"))
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_VALDESC"]   := oModelCesta:GetValue("L2_VALDESC")
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_CODBAR"]    := Alltrim(Posicione('SLK',2,xFilial('SLK')+PadR(oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_PRODUTO"],TamSx3('LK_CODIGO')[1]),'LK_CODBAR'))
    else
        nDel++
    EndIf
Next

If oConectPromo:lSucesso
    Processa({|| oConectPromo:Conect() } ,STR0001  ,,.F.)//"Buscando Promoção"
    If oConectPromo:lSucesso  
        Processa({|| PSHDesc(oConectPromo:aPromocoes) } ,STR0001 ,,.F.)//"Aplicando Promoção na Venda.."
    Else           
        STFMessage("STFMTPRO","POPUP", STR0003 + CRLF + oConectPromo:aPromocoes[1][2])
        STFShowMessage("STFMTPRO")         
    EndIf
EndIf

Return
//------------------------------------------------------------------
/*/{Protheus.doc} PSHDesc
Função para aplicar as promoções ativas

@author Everson S P Junior
@since  25/05/2023
/*/
//-------------------------------------------------------------------
Static Function PSHDesc(aPromocoes)
Local aDesPromo := {}
Local nDecTotal := 0
Local nX,nY,nZ  := 0
Local lMsg      := .F.

aDesPromo := aClone(aPromocoes)

If Len(aDesPromo) > 0

    If aDesPromo[1][1]
    
        For nX:= 1 to Len(aDesPromo)
            If Len(aDesPromo[nX]) > 3 .AND. VALTYPE(aDesPromo[nX][3]) == "A" .AND. Len(aDesPromo[nX][3]) > 0 .AND. !PshVldMTP(aDesPromo[nX][6]) 
                For nY:=1 To Len(aDesPromo[nX][3]) //laço dos itens com promoção
                    For nZ := 1 to STDPBLength("SL2")
                        If Alltrim(STDGPBasket( "SL2" , "L2_ITEM" , nZ )) == Alltrim(aDesPromo[nX][3][nY][1])
                            STBIDApply( nZ , aDesPromo[nX][3][nY][3] , "V" , STDGPBasket( "SL2" , "L2_FISCAL" , nZ ) , "A" )    
                            STBRefshItBasket( nZ ) //Atualizo a linha do item com a promoção aplicada
                        EndIf
                    Next                                
                Next
                PshCodMTP(aDesPromo[nX][6],.F.,aDesPromo[nX])
                lMsg := .T.
            EndIf
        next
        For nX:= 1 to Len(aDesPromo)
            If aDesPromo[nX][1]
                If aDesPromo[nX][2] > 0 .AND. !PshVldMTP(aDesPromo[nX][6])  //  desconto valor total 
                    nDecTotal += aDesPromo[nX][2]
                    PshCodMTP(aDesPromo[nX][6],.F.,aDesPromo[nX])
                    lMsg := .T.
                EndIf    
            EndIf
        next        
        
        If nDecTotal > 0
            STITotDiscVal(nDecTotal,0)
        EndIf
        
        If lMsg
            PshMsgInfo()
        EndIf            
    EndIf
EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PshClearPromo
Função criada para limpar os descontos por item no TOTVS PDV

@author  Evandro Pattaro
@version 1.0
/*/
//-------------------------------------------------------------------
Function PshClearPromo()
    Local nX := 0
    Local lCRdesItTt 	:= SuperGetMv("MV_LJRGDES",,.F.) .AND. SuperGetMV("MV_LJCRDPT",,"0") == "1" .AND. FindFunction("totvs.protheus.retail.desconto.RegraDescProdutoTotal.LjCallCalcRegDescProdTotal", .T.)
    Local lDesligaRD    := .F.

    If FindFunction("totvs.protheus.retail.desconto.RegraDescProdutoTotal.HasDescManu", .T.)
        lDesligaRD := totvs.protheus.retail.desconto.RegraDescProdutoTotal.HasDescManu("TOTVSPDV", STDGPBasket('SL1','L1_NUM'), STDGPBasket('SL1','L1_CLIENTE'), STDGPBasket('SL1','L1_LOJA'))
    EndIf

    For nX := 1 to STDPBLength("SL2")
        If !lCRdesItTt .OR. lDesligaRD .OR. ( lCRdesItTt .AND. STDGPBasket( "SL2" , "L2_VALDESC" , nX ) > 0 .AND. STDGPBasket( "SL2" , "L2_VLDRGDV" , nX ) > 0)
            STBIDApply( nX , 0 , "V" , STDGPBasket( "SL2" , "L2_FISCAL" , nX ) , "A" )
        EndIf
        STBRefshItBasket( nX ) //Atualizo a linha do item com a promoção aplicada
    Next  

    If !FWIsInCallStack("STIOpenCash")
        STIGridCupRefresh()
    EndIf
Return
