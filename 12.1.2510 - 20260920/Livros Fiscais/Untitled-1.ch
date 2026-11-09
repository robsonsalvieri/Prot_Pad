#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
 
User Function MyMata410()
 
Local cDoc       := ""                                                                 // NÃºmero do Pedido de Vendas
Local cA1Cod     := "SP0002"                                                           // CÃ³digo do Cliente
Local cA1Loja    := "01"                                                               // Loja do Cliente
Local cB1Cod     := "ATIVO"                                   // CÃ³digo do Produto
Local cF4TES     := "501"                                                              // CÃ³digo do TES
Local cE4Codigo  := "001"                                                              // CÃ³digo da CondiÃ§Ã£o de Pagamento
Local cMsgLog    := ""
Local cLogErro   := ""
Local cFilSA1    := ""
Local cFilSB1    := ""
Local cFilSE4    := ""
Local cFilSF4    := ""
Local nOpcX      := 0
Local nX         := 0
Local nCount     := 0
Local aCabec     := {}
Local aItens     := {}
Local aLinha     := {}
Local aErroAuto  := {}
Local lOk        := .T.
 
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
 
//****************************************************************
//* Abertura do ambiente
//****************************************************************
ConOut("Inicio: " + Time())
 
ConOut(Repl("-",80))
ConOut(PadC("Teste de inclusao / alteraÃ§Ã£o / exclusÃ£o de 01 pedido de venda com 02 itens", 80))
 
PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "XIFIS26" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
 
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SF4->(dbSetOrder(1))
 
cFilAGG := xFilial("AGG")
cFilSA1 := xFilial("SA1")
cFilSB1 := xFilial("SB1")
cFilSE4 := xFilial("SE4")
cFilSF4 := xFilial("SF4")
 
//****************************************************************
//* Verificacao do ambiente para teste
//****************************************************************
If SB1->(! MsSeek(cFilSB1 + cB1Cod))
   cMsgLog += "Cadastrar o Produto: " + cB1Cod + CRLF
   lOk     := .F.
EndIf
 
If SF4->(! MsSeek(cFilSF4 + cF4TES))
   cMsgLog += "Cadastrar o TES: " + cF4TES + CRLF
   lOk     := .F.
EndIf
 
If SE4->(! MsSeek(cFilSE4 + cE4Codigo))
   cMsgLog += "Cadastrar a CondiÃ§Ã£o de Pagamento: " + cE4Codigo + CRLF
   lOk     := .F.
EndIf
 
If SA1->(! MsSeek(cFilSA1 + cA1Cod + cA1Loja))
   cMsgLog += "Cadastrar o Cliente: " + cA1Cod + " Loja: " + cA1Loja + CRLF
   lOk     := .F.
EndIf
 
If lOk
 
   // Neste RDMAKE (Exemplo), o mesmo nÃºmero do Pedido de Venda Ã© utilizado para a Rotina AutomÃ¡tica (Modelos INCLUSÃƒO / ALTERAÃ‡ÃƒO e EXCLUSÃƒO).
   cDoc := GetSxeNum("SC5", "C5_NUM")
 
   //****************************************************************
   //* Inclusao - INÃ�CIO
   //****************************************************************
   aCabec   := {}
   aItens   := {}
   aLinha   := {}
   aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
   aadd(aCabec, {"C5_TIPO",    "N",       Nil})
   aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
   aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
   aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
 
   If cPaisLoc == "PTG"
      aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
   Endif
 
   For nX := 1 To 04
      //--- Informando os dados do item do Pedido de Venda
      aLinha := {}
      aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
      aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
      aadd(aLinha,{"C6_QTDVEN",  1,             Nil})
      aadd(aLinha,{"C6_PRCVEN",  1000,          Nil})
      aadd(aLinha,{"C6_PRUNIT",  1000,          Nil})
      aadd(aLinha,{"C6_VALOR",   1000,          Nil})
      aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
      aadd(aItens, aLinha)
   Next nX
 
   nOpcX := 3
   MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
   If !lMsErroAuto
      ConOut("Incluido com sucesso! " + cDoc)
   Else
      ConOut("Erro na inclusao!")
      aErroAuto := GetAutoGRLog()
      For nCount := 1 To Len(aErroAuto)
         cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
         ConOut(cLogErro)
      Next nCount
   EndIf
   //****************************************************************
   //* Inclusao - FIM
   //****************************************************************
