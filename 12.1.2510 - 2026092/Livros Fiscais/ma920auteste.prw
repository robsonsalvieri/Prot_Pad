#INCLUDE "TBICONN.CH"

#DEFINE Linha Chr(13) + Chr(10)

USER Function MA920AUT()

   Local aCabec     := {}
   Local aItens     := {}
   Local cDoc       := "TESTCDA"
   Local cCliente   := "SP0001"   // código de cliente
   Local cTes       := "501"  // código da TES (ajustado abaixo se cTrib == "1")
   Local cEspecie   := "SPED" // espécie do documento
   Local nQtdNotas  := 0      // qtde de notas a gerar
   Local nContador  := 0
   Local lCont      := .T.
   Local cTrib      := "1"
   Local dDataBase  := Date() // declarado para evitar warning/erro

   PRIVATE lMsErroAuto := .F.

   // Abertura do ambiente
   PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "XIFIS26" MODULO "FIS" ;
                       TABLES "SF2","SD2","SA1","SA2","SB1","SB2","SF4","SED","SE1"

   MsgInfo( ;
      "Olá, este programa irá incluir notas fiscais manuais de saída." + Linha + ;
      "Será necessário digitar alguns dados manualmente.", ;
      "MA920AUT" )

   While lCont

      // Entradas do usuário
      cCliente  := FWINPUTBOX("Digite o código do cliente:")
      cEspecie  := FWINPUTBOX("Digite a espécie:")
      cTrib     := FWINPUTBOX("Digite qual tributo será calculado? 1-ICM/IPI, 2-ISS, 3-ICM/IPI/PIS/COF:")
      dDataBase := STOD(FWINPUTBOX("Data de emissão: formato AAAAMMDD "))
      nQtdNotas := Val(FWINPUTBOX("Digite quantas notas serão geradas com os dados acima:"))

      For nContador := 1 To nQtdNotas

         If cTrib == "1"
            // Mantive sua lógica. Esta função deve existir no seu ambiente.
            cTes := "501"
         EndIf

         cDoc   := Soma1(cDoc)

         // Montagem da capa (SF2)
         aCabec := {}
         aAdd(aCabec, {"F2_TIPO"   ,"N"})
         aAdd(aCabec, {"F2_FORMUL" ,"S"})
         aAdd(aCabec, {"F2_DOC"    , cDoc})
         aAdd(aCabec, {"F2_SERIE"  ,"1"})
         aAdd(aCabec, {"F2_EMISSAO", dDataBase})
         aAdd(aCabec, {"F2_CLIENTE", cCliente})
         aAdd(aCabec, {"F2_LOJA"   ,"01"})
         aAdd(aCabec, {"F2_ESPECIE", cEspecie})
         //aAdd(aCabec, {"F2_COND"   ,"001"})
         aAdd(aCabec, {"F2_DESCONT", 0})
         aAdd(aCabec, {"F2_FRETE"  , 0})
         aAdd(aCabec, {"F2_SEGURO" , 0})
         aAdd(aCabec, {"F2_DESPESA", 0})

         // **Itens (SD2): exatamente 100 linhas**
         aItens := BuildItens100(cTes)

         // Inclusão automática
         MSExecAuto( {|x,y| MATA920(aCabec, aItens)}, aCabec, aItens, 3 )

         If !lMsErroAuto
            ConOut("Incluído com sucesso! " + cDoc)
         Else
            ConOut("Erro na inclusão!")
            MostraErro()
         EndIf

         // Limpeza
         aCabec := Nil
         aItens := Nil

      Next

      lCont := MsgYesNo("Deseja efetuar uma nova inclusão?")

   End While

   ConOut("Fim  : " + Time())
   RESET ENVIRONMENT
Return .T.


// -----------------------------------------------------------------
// Monta exatamente 100 itens padrões de SD2 para a nota
// Você pode adaptar campos/valores conforme sua regra.
// -----------------------------------------------------------------
Static Function BuildItens100(cTes)
   Local aItens := {}
   Local n
   Local aLinha

   For n := 1 To 100
      aLinha := {}
      aAdd(aLinha, {"D2_COD"   , "ATIVO", Nil})
      aAdd(aLinha, {"D2_QUANT" , 1      , Nil})
      aAdd(aLinha, {"D2_PRCVEN", 1000   , Nil})
      aAdd(aLinha, {"D2_TOTAL" , 1000    ,Nil})
      aAdd(aLinha, {"D2_TES"   , cTes   , Nil})
      aAdd(aItens, aLinha)
   Next

Return aItens


// Incrementa o número do documento contido em string (ex.: "00000001" -> "00000002")
Static Function Soma1(cDoc)
   Local nDoc := Val(cDoc)
   Local cRet := ""

   nDoc++
   cRet := cValToChar(nDoc)

Return cRet
