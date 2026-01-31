#Include "locm007.ch"
#Include "Protheus.ch"

/*/LOCM007.PRW
ITUP Business - TOTVS RENTAL
author Frank Zwarg Fuga
since 21/03/2023
history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Este fonte era o ponto de entrada MT100LOK

DSERLOCA-9372 alterado por Alessandro Gois - 19/11/2025
para bloquear alteração da nota fiscal origem no documento de entrada

DSERLOCA-8517 alterado por Frank Fuga - 13/01/26
Tratamento para quando vier por msExecAuto
Tratamento para não aceitar quando não veio o registro pelo Rental
/*/

Function LOCM007(lRet)
Local aArea := GetArea()
Local nPosNotaS := 0
Local nPosSerieS := 0
Local nPosItemS := 0
Local nPosProdS := 0
Local nPosNotaE := 0
Local nPosSerieE := 0
Local lRental := .F.
Local cNota := ""
Local cSerie := ""
Local cItem := ""
Local cClix := ""
Local cLojx := ""
Local cProduto := ""
Local cPedido := ""
Local nPosForDev := 0
Local nPosLojDev := 0
Local aAreaSD2 := SD2->(GetArea())
Local aAreaFPY := FPY->(GetArea())

Default lRet := .T.

    // Validar se veio de um msExecAuto - Frank 12/01/26
    If type("aAutoitens") == "A"
        If len(aAutoItens) > 0
            
            nPosNotaS  := aScan(aAutoitens[1], {|x| alltrim(x[1]) == "D1_NFORI" })
            nPosSerieS := aScan(aAutoitens[1], {|x| alltrim(x[1]) == "D1_SERIORI" })
            nPosItemS  := aScan(aAutoitens[1], {|x| alltrim(x[1]) == "D1_ITEMORI" })
            nPosProdS  := aScan(aAutoitens[1], {|x| alltrim(x[1]) == "D1_COD" })
            nPosForDev := aScan(aAutoCab,{|x| AllTrim(x[1]) == "F1_FORNECE"})
			nPosLojDev := aScan(aAutoCab,{|x| AllTrim(x[1]) == "F1_LOJA"})

            cNota    := aAutoItens[n,nPosNotaS,2]
            cSerie   := aAutoItens[n,nPosSerieS,2]
            cItem    := aAutoItens[n,nPosItemS,2] 
            cProduto := aAutoItens[n,nPosProdS,2] 
            cClix    := aAutoCab[nPosForDev][2]
            cLojx    := aAutoCab[nPosLojDev][2]

            // posicionar nos itens da nota para pegar o pedido de vendas SD2
            SD2->(dbSetOrder(3))
            If SD2->(dbSeek(xFilial("SD2")+cNota+cSerie+cClix+cLojx+cProduto+cItem))
                cPedido := SD2->D2_PEDIDO
                FPY->(dbSetOrder(1))
                If FPY->(dbSeek(xFilial("FPY")+cPedido))
                    lRental := .T.
                EndIf
            EndIf

        EndIf
    EndIf

    // Validar se nao veio de um msExecAuto - Frank 12/01/26
    If type("aAutoitens") <> "A"
        
        nPosNotaE  := aScan(aHeader, {|x| alltrim(x[2]) == "D1_NFORI" })
        nPosSerieE := aScan(aHeader, {|x| alltrim(x[2]) == "D1_SERIORI" })
        nPosItemE  := aScan(aHeader, {|x| alltrim(x[2]) == "D1_ITEMORI" })
        nPosProdE  := aScan(aHeader, {|x| alltrim(x[2]) == "D1_COD" })

        cNota    := acols[n,nPosNotaE]  
        cSerie   := acols[n,nPosSerieE]
        cItem    := acols[n,nPosItemE] 
        cProduto := acols[n,nPosProdE] 
        cClix    := cA100for  
        cLojx    := cLoja

        // posicionar nos itens da nota para pegar o pedido de vendas SD2
        SD2->(dbSetOrder(3))
        If SD2->(dbSeek(xFilial("SD2")+cNota+cSerie+cClix+cLojx+cProduto+cItem))
            cPedido := SD2->D2_PEDIDO
            FPY->(dbSetOrder(1))
            If FPY->(dbSeek(xFilial("FPY")+cPedido))
                lRental := .T.
            EndIf
        EndIf

    EndIf

    If lRental // apenas validar se o pedido original (nota de remessa) tenha sido gerado pelo Rental - Frank 12/01/26

        If type("aAutoitens") == "A" .and. type("aHeader") == "A" // Ajuste da existência dos arrays Frank 12/01/26 - DSERLOCA-10256
            
            nPosNotaS  := aScan(aAutoitens[1], {|x| x[1] == "D1_NFORI" })
            nPosSerieS := aScan(aAutoitens[1], {|x| x[1] == "D1_SERIORI" })

            nPosNotaE    := aScan(aHeader,{|x| "D1_NFORI"  == AllTrim(x[2])})
            nPosSerieE   := aScan(aHeader,{|x| "D1_SERIORI"  == AllTrim(x[2])})

            if acols[n,nPosNotaE] <> aAutoItens[n,nPosNotaS,2] .or. file("\SYSTEM\LCM007E1.TXT")
                Help( ,, "LOCM007-001",, STR0003, 1, 0,,,,,,{STR0001 + aAutoItens[n,nPosNotaS,2] + STR0002 + alltrim(str(n)) }) //"Retorne o(s) item(ns) " //" para sua quantidade original" //"Este pedido foi gerado pelo modulo SIGALOC não se permite alterar a quantidade" //"O pedido foi encontrado na tabela FPY. Este pedido foi gerado pelo RENTAL/SIGALOC, não se permite alterar a quantidade." //"Manter a NF origem " //" na linha " //"Documento gerado pelo Rental não pode ser alterado"
                lRet := .f.
            endif

            if acols[n,nPosSerieE] <> aAutoItens[n,nPosSerieS,2] .or. file("\SYSTEM\LCM007E2.TXT")
                Help( ,, "LOCM007-002",, STR0003, 1, 0,,,,,,{STR0004 + aAutoItens[n,nPosSerieS,2] + STR0002 + alltrim(str(n)) }) //"Retorne o(s) item(ns) " //" para sua quantidade original" //"Este pedido foi gerado pelo modulo SIGALOC não se permite alterar a quantidade" //"O pedido foi encontrado na tabela FPY. Este pedido foi gerado pelo RENTAL/SIGALOC, não se permite alterar a quantidade." //"Manter a Serie origem " //" na linha " //"Documento gerado pelo Rental não pode ser alterado"
                lRet := .f.
            endif

        EndIf   

        // Validar na pilha de chamadas se passou pelo LOCA011 - Geração dos registros de entrada.
        If (!FWIsInCallStack("LOCA011") .AND. !FWIsInCallStack("LOCA029") ) .or. file("\SYSTEM\LCM007E3.TXT") 
            Help(Nil,	Nil,"Rental: "+alltrim(upper(Procname())),; 
		    Nil,STR0005,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
		    {STR0006}) //"Por tratar-se de uma nota de origem gerada pelo Rental, faz-se necessário que a entrada da Nota seja pelo módulo Rental." 
            lRet := .f.
        EndIf

    EndIf

    SD2->(RestArea(aAreaSD2))
    FPY->(RestArea(aAreaFPY))
    RestArea(aArea)
Return lRet
