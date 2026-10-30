//#Include "rwmake.ch" 
#Include "topconn.ch" 
#Include "Protheus.ch" 
#include "fileio.ch" 
#INCLUDE "TBICONN.CH"
  
User Function MyMata410()
 
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local nY     := 0
Local cDoc   := ""
Local lOk    := .T.
Local aProduto := {}
Local nI     := 0
Local nItem  := 0

 
PRIVATE lMsErroAuto := .F.
//****************************************************************
//* Abertura do ambiente
//****************************************************************
//ConOut(Repl("-",80))
ConOut(PadC("Teste de Inclusao de 10 pedidos de venda  com 30 itens cada",80))

PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "XIFIS26" MODULO "TAF"  
//****************************************************************
//* Verificacao do ambiente para teste 
//****************************************************************
dbSelectArea("SB1")
dbSetOrder(1)

aProduto := {;
"PA0000000000000000000000000001",;
"PA0000000000000000000000000002",;
"PA0000000000000000000000000003",;
"PA0000000000000000000000000004",;
"PA0000000000000000000000000005"}


For nI := 1 to Len(aProduto)
    If !SB1->(MsSeek(xFilial("SB1")+aProduto[nI]))
        lOk := .F.
        ConOut("Cadastrar produto: "+ aProduto[nI])
    EndIf
NEXT

dbSelectArea("SF4")
dbSetOrder(1)
If !SF4->(MsSeek(xFilial("SF4")+"532"))
    lOk := .F.
    ConOut("Cadastrar TES: 532")
EndIf
dbSelectArea("SE4")
dbSetOrder(1)
If !SE4->(MsSeek(xFilial("SE4")+"001"))
    lOk := .F.
    ConOut("Cadastrar condicao de pagamento: 001")
EndIf

dbSelectArea("SA1")
dbSetOrder(1)
If !SA1->(MsSeek(xFilial("SA1")+"SP0003"))
    lOk := .F.
    ConOut("Cadastrar cliente: SP0003")
EndIf
If lOk
    ConOut("Inicio: "+Time())
    For nY := 1 To 5
        nItem := 1
        cDoc := GetSxeNum("SC5","C5_NUM")
        RollBAckSx8()
        aCabec := {}
        aItens := {}
        aadd(aCabec,{"C5_NUM"   ,cDoc,Nil})
        aadd(aCabec,{"C5_TIPO" ,"N",Nil})
        aadd(aCabec,{"C5_CLIENTE",SA1->A1_COD,Nil})
        aadd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
        aadd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})
        aadd(aCabec,{"C5_CONDPAG",SE4->E4_CODIGO,Nil})
        aadd(aCabec,{"C5_FRTCFOP","5931",Nil})
        aadd(aCabec,{"C5_FRETE",500,Nil})
        aadd(aCabec,{"C5_FRETAUT",500,Nil})
        aadd(aCabec,{"C5_TPFRETE","F",Nil})
        For nX := 1 To 10
            For nI := 1 to Len(aProduto)
                nItem += 1
                aLinha := {}
                aadd(aLinha,{"C6_ITEM",StrZero(nItem,2),Nil})
                aadd(aLinha,{"C6_PRODUTO",aProduto[nI],Nil})
                aadd(aLinha,{"C6_QTDVEN",1,Nil})
                aadd(aLinha,{"C6_PRCVEN",100,Nil})
                aadd(aLinha,{"C6_PRUNIT",100,Nil})
                aadd(aLinha,{"C6_VALOR",100,Nil})
                aadd(aLinha,{"C6_TES",SF4->F4_CODIGO,Nil})
                aadd(aItens,aLinha)
            Next nI
        Next nX
        //****************************************************************
        //* Teste de Inclusao              
        //****************************************************************
        MarcTemp('Processamento TSI', .T.)

        MSExecAuto({|x,y| MATA410(x,y)},aCabec,aItens, 3)

        MarcTemp('Processamento TSI', .F.)

        //MATA410(aCabec,aItens,3)
        If !lMsErroAuto
            ConOut("Incluido com sucesso! "+cDoc)
        Else
            ConOut("Erro na inclusao!")
            MostraErro()
        EndIf
    Next nY
    ConOut("Fim  : "+Time())
    //****************************************************************
    //* Teste de alteracao                                      
    //****************************************************************
    /*aCabec := {}
    aItens := {}
    aadd(aCabec,{"C5_NUM",cDoc,Nil})
    aadd(aCabec,{"C5_TIPO","N",Nil})
    aadd(aCabec,{"C5_CLIENTE",SA1->A1_COD,Nil})
    aadd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
    aadd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})
    aadd(aCabec,{"C5_CONDPAG",SE4->E4_CODIGO,Nil})
    If cPaisLoc == "PTG"
        aadd(aCabec,{"C5_DECLEXP","TESTE",Nil})
    Endif
    For nX := 1 To 30
        aLinha := {}
        aadd(aLinha,{"LINPOS","C6_ITEM",StrZero(nX,2)})
        aadd(aLinha,{"AUTDELETA","N",Nil})
        aadd(aLinha,{"C6_PRODUTO",SB1->B1_COD,Nil})
        aadd(aLinha,{"C6_QTDVEN",2,Nil})
        aadd(aLinha,{"C6_PRCVEN",100,Nil})
        aadd(aLinha,{"C6_PRUNIT",100,Nil})
        aadd(aLinha,{"C6_VALOR",200,Nil})
        aadd(aLinha,{"C6_TES","622",Nil})
        aadd(aItens,aLinha)
    Next nX 
    ConOut(PadC("Teste de alteracao",80))
    ConOut("Inicio: "+Time())
    MATA410(aCabec,aItens,4)
    ConOut("Fim  : "+Time())
    ConOut(Repl("-",80))    
    //****************************************************************
    //* Teste de Exclusao                                           
    //****************************************************************
    ConOut(PadC("Teste de exclusao",80))
    ConOut("Inicio: "+Time())
    MATA410(aCabec,aItens,5)
    If !lMsErroAuto
        ConOut("Exclusao com sucesso! "+cDoc)
    Else
        ConOut("Erro na exclusao!")
    EndIf
    ConOut("Fim  : "+Time())
    ConOut(Repl("-",80))*/
EndIf
RESET ENVIRONMENT
Return(.T.)
