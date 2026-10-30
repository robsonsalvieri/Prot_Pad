#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
Static aPromocao    := {}
Static lPromoAplic  := .F. //Informa se foi aplicado a promoção no total ou no Item
//-------------------------------------------------------------------
/*/{Protheus.doc} PshMtProm
Função criada para venda Assistida do Loja701B para enviar 
informações para motor de promoções e retornar as promoções ativas.

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function PshMtProm(nValor,nVlrPago,lAbateISS,nValAbISS,cFormPagto,cCondicao)
Local oConectPromo := nil
Local cAssinante   := "MOTOR PROMOCOES" 
Local cProcesso    := "PROMOCOES"
Local nY        := 0
Local nRateio   := 0
Local nDel      := 0
Default nValor      := 0
Default nVlrPago    := 0
Default lAbateISS   := .F.
Default nValAbISS   := .F.
Default cFormPagto  := ""
Default cCondicao   := ""

IF Empty(cFormPagto)
    cFormPagto := cCondicao
EndIf    
//Cria Objeto para transmissao do Motor de promoções
oConectPromo := PshMotorPromocoesOnlineObj():New(cAssinante,cProcesso)
//Alimenta o Body da Classe PshMotorPromocoesOnlineObj para conectar e retornar as promoções validas.
oConectPromo:Aformpgt := StrTokArr(cFormPagto+',',',')
oConectPromo:OPUBLICA["LQ_FILIAL"] := cFilant
oConectPromo:OPUBLICA["LQ_NUM"] := M->LQ_NUM
oConectPromo:OPUBLICA["LQ_VEND"] := M->LQ_VEND
oConectPromo:OPUBLICA["LQ_CIENTE"] :=M->LQ_CIENTE
oConectPromo:OPUBLICA["LQ_LOJA"] := M->LQ_LOJA
oConectPromo:OPUBLICA["LQ_TIPOCLI"] := M->LQ_TIPOCLI
oConectPromo:OPUBLICA["LQ_PDV"] := "PDV"
oConectPromo:OPUBLICA["LQ_TIPO"] := M->LQ_TIPO
oConectPromo:OPUBLICA["LQ_FORMA"] := cFormPagto

For nY := 1 To Len(aCols)
    If !Acols[nY][Len(Acols[nY])]
        nRateio+= Acols[nY][Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_QUANT"})]
    EndIf
Next    

For nY := 1 To Len(aCols)
    If !Acols[nY][Len(Acols[nY])]
        //Adiciona estrutura json anterior para atualizar os dados
        If (nY-nDel) > 1
            aAdd(oConectPromo:OPUBLICA["SLR"],JsonObject():New()) //Ajustar esse ponto.
        EndIf
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_ITEM"]      := Acols[nY][Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ITEM"})]
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_PRODUTO"]   := Alltrim(Acols[nY][Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_PRODUTO"})])
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_QUANT"]     := Acols[nY][Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_QUANT"})]
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_VRUNIT"]    := IIF(nVlrPago>0,nValor/nRateio,Acols[nY][Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_VRUNIT"})])
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_VALDESC"]   := Acols[nY][Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_VALDESC"})]
        oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_CODBAR"]    := Alltrim(Posicione('SLK',2,xFilial('SLK')+PadR(oConectPromo:OPUBLICA["SLR"][nY-nDel]["LR_PRODUTO"],TamSx3('LK_CODIGO')[1]),'LK_CODBAR'))
    else
        nDel++
    EndIf
Next
//faz a conexão com Servidor e aplica a promoção na tela do Venda Assistida.
If oConectPromo:lSucesso
    Processa({|| oConectPromo:Conect() } ,"Buscando Promoção" ,,.F.)
    If oConectPromo:lSucesso  
        Processa({|| AplicaDec(@nValor,nVlrPago,lAbateISS,nValAbISS,cFormPagto,oConectPromo:aPromocoes) } ,"Aplicando Promoção na Venda.." ,,.F.)
    EndIf
EndIf    

Return 
//------------------------------------------------------------------
/*/{Protheus.doc} AplicaDec
Função para aplicar as promoções ativas

@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Static Function AplicaDec(nValor,nVlrPago,lAbateISS,nValAbISS,cFormPagto,aPromocoes)
Local aDesPromo := {}
Local nDecTotal := 0
Local nX,nY     := 0
Local lMsg      := .F.
aDesPromo := aClone(aPromocoes)

If Len(aDesPromo) > 0 .AND. aDesPromo[1][1]
    
    For nX:= 1 to Len(aDesPromo)
        If Len(aDesPromo[nX]) > 3 .AND. VALTYPE(aDesPromo[nX][3]) == "A" .AND. Len(aDesPromo[nX][3]) > 0 .AND. !PshVldMTP(aDesPromo[nX][6]) 
            For nY:=1 To Len(aDesPromo[nX][3])
                PshDesIt(aDesPromo[nX][3][nY][1],aDesPromo[nX][3][nY][2],aDesPromo[nX][3][nY][3],cFormPagto)
            Next
            PshCodMTP(aDesPromo[nX][6],.F.,aDesPromo[nX])
            lMsg := .T.
        EndIf
    next
    For nX:= 1 to Len(aDesPromo)
        If aDesPromo[nX][1]
            If aDesPromo[nX][2] > 0 .AND. !PshVldMTP(aDesPromo[nX][6])  //  desconto valor total 
                nDecTotal += PshDescT(nVlrPago,lAbateISS,nValAbISS,cFormPagto,aDesPromo[nX][2])
                PshCodMTP(aDesPromo[nX][6],.F.,aDesPromo[nX])
                lMsg := .T.
            EndIf    
        EndIf
    next        
    
    If lMsg
        PshMsgInfo()
    EndIf

    If nDecTotal > 0
        nValor := nDecTotal
    elseIf nValor > Lj7T_TOTAL(2)
        nValor := Lj7T_TOTAL(2)
    EndIf
EndIf

return
//------------------------------------------------------------------
/*/{Protheus.doc} PshCodMTP
Alimenta o Array com as promoções aplicadas
@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function PshCodMTP(cCodPro,lLimpa,aPromo)
Default cCodPro := ""
Default lLimpa  := .T.

If !lLimpa
    aAdd(aPromocao,{cCodPro,aClone(aPromo)}) //Ajustar esse ponto.
    lPromoAplic := .T.
else
    aPromocao := {}
    lPromoAplic := .F.   
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PshVldMTP
Retorna se a Promoções já foi aplicada na busca.
@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function PshVldMTP(cCodPro)
Local nPos := 0

nPos := Ascan(aPromocao, {|x| AllTrim(x[1]) == Alltrim(cCodPro)})

Return nPos > 0 

//------------------------------------------------------------------
/*/{Protheus.doc} PshAplProm
Retorna se a Promoções já foi aplicada.
@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function PshAplProm()

Return lPromoAplic

//------------------------------------------------------------------
/*/{Protheus.doc} PshArrayMP
Retorna Array de Promoção aplicado.
@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function PshArrayMP()

Return aPromocao
