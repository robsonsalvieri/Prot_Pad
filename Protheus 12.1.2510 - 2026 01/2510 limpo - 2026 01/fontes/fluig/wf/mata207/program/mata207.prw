#include 'protheus.ch'
#include 'apwebsrv.ch'
#include 'mata207.ch'

Function __MATA207()
Return

WSSERVICE MATA207 ;
    DESCRIPTION STR0001 /*WS genérico para execução de funções Protheus a partir de um processo workflow*/;
    NAMESPACE 'http://webservices.totvs.com.br/'

    WSDATA cUser          AS STRING
    WSDATA cPassword      AS STRING
    WSDATA cCompany       AS STRING
    WSDATA lAuthenticated AS BOOLEAN

    WSDATA cFunction      AS STRING
    WSDATA cParameters    AS STRING
    WSDATA cReturn        AS STRING

    WSDATA cParMsg        AS STRING
    WSDATA cRetMsg        AS STRING

    WSMETHOD HELLO          ;
        DESCRIPTION STR0002 //Método auxiliar para verificar se o serviço está funcionando corretamente

    WSMETHOD CALLFUNCTION   ;
        DESCRIPTION STR0003 //Executa uma determinada função de regra de negócio do Protheus
ENDWSSERVICE

WSMETHOD HELLO WSRECEIVE cParMsg WSSEND cRetMsg WSSERVICE MATA207
    ::cRetMsg := 'ok'
Return .T.

WSMETHOD CALLFUNCTION WSRECEIVE cFunction,cParameters WSSEND cReturn WSSERVICE MATA207
Return WsEcmServiceCallFunction(cFunction,cParameters,@::cReturn)

Static Function GetFunctionBlock(cFunction,cParameters)
    Local bFunction := Nil

    If FindFunction(cFunction)
        bFunction := &("{|| "+AllTrim(cFunction)+"('"+AllTrim(cParameters)+"') }")
    EndIf
Return bFunction

Function WsEcmServiceCallFunction(cFunction,cParameters,cReturn)
    Local bFunction
    Local oReturn
    Local oParameters

    //Cria o array a partir da string no formato JSON.
    If  !Empty(cParameters)
        If !FwJsonDeserialize(cParameters,@oParameters)
            cReturn := '[false,'+STR0004+']' //Não foi possível converter o objeto JSON informado por parametro.
            Return .T.
        EndIf
    EndIf

    bFunction := GetFunctionBlock(cFunction,cParameters)

    If  bFunction == Nil
        cReturn := '[false,' + STR0005 + Trim(cFunction) + STR0006 + ']' //Função ' + Trim(cFunction) + ' não encontrada no RPO.
        Return .T.
    EndIf

    //Executa a função informada por parâmetro
    oReturn := Eval(bFunction)

    If  oReturn == Nil
        cReturn := '[false,' + STR0007 + ']' //Parâmetros de retorno não informados.
    Else
        //Gera a string JSON do objeto de retornado informado.
        cReturn := FwJsonSerialize(oReturn,.F.)
        Default cReturn := '[false,' + STR0008 + ']' //Não foi possível converter o retorno informado para o formato JSON.
    EndIf
Return .T.

//Função para validação dos campos do formulário
Function mata207Vld(cParam)
   Local index := 0
   Local aEstruOrig := {}
   Local aReturn := {}
   /*
      aReturn[1] - Identifica o status que será retornado, .T. ou .F.
      aReturn[2] - Contém uma mensagem a ser exibida no Fluig.
      aReturn[3] - Contém a descrição do produto.
   */
   Local aParam
   /*
      aParam[1] - identifica o campo a ser validado.
         1 = Item atual.
         2 = Novo item.
         3 = Grupo de opcionais.
         4 = Item opcional.
         5 = Formulário inteiro.
      aParam[2] - contém o valor a ser validado
   */

   Private nEstru   := 0

   aAdd(aReturn,.T.)
   aAdd(aReturn,"")
   aAdd(aReturn,"")

   If !Empty(cParam)
       If !FwJsonDeserialize(cParam,@aParam)
           aReturn[1] := .F.
           aReturn[2] := STR0009 //Erro ao realizar o deserialize dos parametros.
           Return aReturn
       EndIf
   EndIf

   //Valida o Item
   If aParam[1] == "1" .Or. aParam[1] == "2"
      If Empty(aParam[2])
         aReturn[1] := .F.
         If aParam[1] == "1"
            aReturn[2] := STR0010 //"Componente atual não informado."
         Else
            aReturn[2] := STR0011 //"Novo componente não informado."
         EndIf
         Return aReturn
      EndIf

      dbSelectArea("SB1")
      SB1->(dbSetOrder(1))
      If SB1->(dbSeek(xFilial("SB1") + PadR(aParam[2],TamSX3("B1_COD")[1])))
         aReturn[3] := SB1->B1_DESC
      Else
         aReturn[1] := .F.
         If aParam[1] == "1"
            aReturn[2] := STR0012 //Componente atual não cadastrado.
         Else
            aReturn[2] := STR0013 //"Novo componente não cadastrado."
         EndIf
         Return aReturn
      EndIf
   EndIf

   //Valida o grupo de opcionais
   If aParam[1] == "3"
      dbSelectArea("SGA")
      SGA->(dbSetOrder(1))
      If !SGA->(dbSeek(xFilial("SGA")+ PadR(aParam[2],TamSX3("GA_GROPC")[1])))
         aReturn[1] := .F.
         aReturn[2] := STR0014 //"Grupo de opcionais não cadastrado."
      EndIf
   EndIf

   //Valida o item opcional
   If aParam[1] == "4"
      If !Empty(aParam[2]) .And. !Empty(aParam[3])
         dbSelectArea("SGA")
         SGA->(dbSetOrder(1))
         If !SGA->(dbSeek(xFilial("SGA") + PadR(aParam[2],TamSX3("GA_GROPC")[1]) + PadR(aParam[3],TamSX3("GA_GROPC")[1])))
            aReturn[1] := .F.
            aReturn[2] := STR0015 //"Item opcional não cadastrado para este grupo de opcionais."
         EndIf
      EndIf
   EndIf

   //Valida o formulário inteiro.
   If aParam[1] == "5"
      //Item atual
      If Empty(aParam[2])
         aReturn[1] := .F.
         aReturn[2] := STR0010 //"Componente atual não informado."
         Return aReturn
      Else
         dbSelectArea("SB1")
         SB1->(dbSetOrder(1))
         If !SB1->(dbSeek(xFilial("SB1")+ PadR(aParam[2],TamSX3("B1_COD")[1])))
            aReturn[1] := .F.
            aReturn[2] := STR0012 //"Componente atual não cadastrado."
            Return aReturn
         EndIf
      EndIf

      //Grupo de opcionais atual.
      If Empty(aParam[3])
         If !Empty(aParam[4])
            aReturn[1] := .F.
            aReturn[2] := STR0016 //"Item opcional atual não pertence ao grupo de opcionais."
            Return aReturn
         EndIf
      Else
         dbSelectArea("SGA")
         SGA->(dbSetOrder(1))
         If !SGA->(dbSeek(xFilial("SGA")+ PadR(aParam[3],TamSX3("GA_GROPC")[1])))
            aReturn[1] := .F.
            aReturn[2] := STR0017 //"Grupo de opcionais atual não cadastrado."
            Return aReturn
         EndIf
      EndIf

      //Item opcional atual.
      If Empty(aParam[4])
         If !Empty(aParam[3])
            aReturn[1] := .F.
            aReturn[2] := STR0018 //"Item opcional atual não informado."
            Return aReturn
         EndIf
      Else
         dbSelectArea("SGA")
         SGA->(dbSetOrder(1))
         If !SGA->(dbSeek(xFilial("SGA") + PadR(aParam[3],TamSX3("GA_GROPC")[1]) + PadR(aParam[4],TamSX3("GA_GROPC")[1])))
            aReturn[1] := .F.
            aReturn[2] := STR0019 //"Item opcional atual não cadastrado para este grupo de opcionais."
            Return aReturn
         EndIf
      EndIf

      //Novo item
      If Empty(aParam[5])
         aReturn[1] := .F.
         aReturn[2] := STR0011 //"Novo componente não informado."
         Return aReturn
      Else
         dbSelectArea("SB1")
         SB1->(dbSetOrder(1))
         If !SB1->(dbSeek(xFilial("SB1") + PadR(aParam[5],TamSX3("B1_COD")[1])))
            aReturn[1] := .F.
            aReturn[2] := STR0013 //"Novo componente não cadastrado."
            Return aReturn
         EndIf

         aEstruOrig := Estrut( aParam[5],1)
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Verifica se o produto origem ja' existe na estrutura do produto destino          ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If (aScan(aEstruOrig,{|x| x[3] == aParam[2] }) > 0)
            aReturn[1] := .F.
            aReturn[2] := STR0020 //"Um produto 'PAI' não pode ser componente do seu 'FILHO'."
            Return aReturn
         EndIf

      EndIf

      //Novo grupo de opcionais.
      If Empty(aParam[6])
         If !Empty(aParam[7])
            aReturn[1] := .F.
            aReturn[2] := STR0021 //"Novo item opcional não pertence ao grupo de opcionais."
            Return aReturn
         EndIf
      Else
         dbSelectArea("SGA")
         SGA->(dbSetOrder(1))
         If !SGA->(dbSeek(xFilial("SGA")+ PadR(aParam[6],TamSX3("GA_GROPC")[1])))
            aReturn[1] := .F.
            aReturn[2] := STR0022 //"Novo grupo de opcionais não cadastrado."
            Return aReturn
         EndIf
      EndIf

      //Novo item opcional.
      If Empty(aParam[7])
         If !Empty(aParam[6])
            aReturn[1] := .F.
            aReturn[2] := STR0023 //"Novo item opcional não informado."
            Return aReturn
         EndIf
      Else
         dbSelectArea("SGA")
         SGA->(dbSetOrder(1))
         If !SGA->(dbSeek(xFilial("SGA") + PadR(aParam[6],TamSX3("GA_GROPC")[1]) + PadR(aParam[7],TamSX3("GA_GROPC")[1])))
            aReturn[1] := .F.
            aReturn[2] := STR0024 //"Novo item opcional não cadastrado para este grupo de opcionais."
            Return aReturn
         EndIf
      EndIf

      //Valida os itens pais
      If Len(aParam[8]) < 1
         aReturn[1] := .F.
         aReturn[2] := STR0025 //"Nenhum item pai selecionado."
         Return aReturn
      Else
         //Valida se os itens pais pertencem ao componente atual
         For index := 1 To Len(aParam[8])
            dbSelectArea("SG1")
            SG1->(dbSetOrder(1))
            SG1->(dbGoTo(aParam[8][index]))

            If SG1->G1_COMP  != PadR(aParam[2],TamSX3("G1_COMP")[1]) .Or.;
               SG1->G1_GROPC != PadR(aParam[3],TamSX3("G1_GROPC")[1]) .Or.;
               SG1->G1_OPC   != PadR(aParam[4],TamSX3("G1_OPC")[1])
               aReturn[1] := .F.
               aReturn[2] := STR0026 /*"Componente atual não pertence ao item pai '"*/ + AllTrim(SG1->G1_COD) + "'."
               Return aReturn
            EndIf
            dbSelectArea("SGF")
            SGF->(dbSetOrder(2))
            // Valida SGF - Oper. x Compon.
            SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
            While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
               If SGF->GF_COMP == SG1->G1_COMP // Encontra o componente a ser substituido
                  nRecnoSGF := SGF->(Recno())
                  If SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD+SGF->GF_ROTEIRO+ PadR(aParam[5],TamSX3("GF_COMP")[1])))
                     aReturn[1] := .F.
                     aReturn[2] := STR0027 /*"Já existe o componente destino para o mesmo roteiro no cad. de Operação x Componente. "*/ +;
                                   AllTrim(RetTitle("GF_PRODUTO"))+": "+AllTrim(SG1->G1_COD)+"   "+;
                                   AllTrim(RetTitle("GF_ROTEIRO"))+": "+SGF->GF_ROTEIRO+"   "+;
                                   AllTrim(RetTitle("GF_COMP"))+": "+AllTrim(aParam[5])
                     Return aReturn
                  EndIf
               EndIf
               SGF->(dbSkip())
            EndDo
         Next index
      EndIf

   EndIf

Return aReturn

//Função que realiza a busca dos itens pais de um determinado componente.
Function mata207BIT(cParam)
   Local aParam
   /*
      aParam[1] - Contém o código do item componente.
      aParam[2] - Contém o código do grupo opcional.
      aParam[3] - Contém o código do item opcional.
   */
   Local aReturn := {}
   /*
      aReturn[1] - Identifica o status que será retornado, .T. ou .F.
      aReturn[2] - Contém uma mensagem a ser exibida no Fluig.
      aReturn[3] - Total de registros  encontrados.
      aReturn[4] - Array com os itens pais. (G1_COD)
      aReturn[5] - Array com a sequencia dos itens pais. (G1_TRT)
      aReturn[6] - Array com a quantidade dos itens pais. (G1_QUANT)
      aReturn[7] - Array com o indice de perda dos itens pais. (G1_PERDA)
      aReturn[8] - Array com a potencia dos itens pais. (G1_POTENCI)
      aReturn[9] - Array com o R_E_C_N_O_ do registro.
   */

   Local aCod     := {}
   Local aTrt     := {}
   Local aQuant   := {}
   Local aPerda   := {}
   Local aPotenci := {}
   Local aRecno   := {}
   Local cQuery   := ""
   Local cAlias   := GetNextAlias()

   If !Empty(cParam)
       If !FwJsonDeserialize(cParam,@aParam)
           aReturn[1] := .F.
           aReturn[2] := STR0009 //"Erro ao realizar o deserialize dos parametros."
           Return aReturn
       EndIf
   EndIf

   aAdd(aReturn,.T.)
   aAdd(aReturn,"")
   aAdd(aReturn,0)

   cQuery := " SELECT SG1.G1_COD, "
   cQuery += "        SG1.G1_TRT, "
   cQuery += "        SG1.G1_QUANT, "
   cQuery += "        SG1.G1_PERDA, "
   cQuery += "        SG1.G1_POTENCI, "
   cQuery += "        SG1.R_E_C_N_O_ "
   cQuery += "   FROM " + RetSqlName('SG1') + " SG1"
   cQuery += "  WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "'"
   cQuery += "    AND SG1.D_E_L_E_T_ = '' "
   cQuery += "    AND SG1.G1_COMP    = '" + PadR(aParam[1],TamSX3("G1_COD")[1]) + "'"
   cQuery += "    AND SG1.G1_GROPC   = '" + PadR(aParam[2],TamSX3("G1_GROPC")[1]) + "'"
   cQuery += "    AND SG1.G1_OPC     = '" + PadR(aParam[3],TamSX3("G1_OPC")[1]) + "'"

   cQuery := ChangeQuery(cQuery)
   dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
   DbSelectArea( cAlias )

   While ((cAlias)->(!Eof() ))
      aAdd(aCod,(cAlias)->G1_COD)
      aAdd(aTrt,(cAlias)->G1_TRT)
      aAdd(aQuant,(cAlias)->G1_QUANT)
      aAdd(aPerda,(cAlias)->G1_PERDA)
      aAdd(aPotenci,(cAlias)->G1_POTENCI)
      aAdd(aRecno,(cAlias)->R_E_C_N_O_)
      aReturn[3]++
      (cAlias)->(DbSkip())
   EndDo

   aAdd(aReturn,aCod)
   aAdd(aReturn,aTrt)
   aAdd(aReturn,aQuant)
   aAdd(aReturn,aPerda)
   aAdd(aReturn,aPotenci)
   aAdd(aReturn,aRecno)
   If aReturn[3] == 0
      aReturn[1] := .F.
      aReturn[2] := STR0028 //"Nenhum item pai encontrado."
   EndIf

Return aReturn

//Função que realiza a substituição dos componentes.
Function mata207Alt(cParam)
   Local lRet := .T.
   Local index := 0
   Local nz := 0
   Local cQuery := ""
   Local nRecnoSGF
   Local aRecnosSGF := {}
   Local aParam
   /*
      aParam[1] - Contém o código do item componente atual.
      aParam[2] - Contém o código do grupo de opcionais atual.
      aParam[3] - Contém o código do item opcional atual.
      aParam[4] - Contém o código do novo componente.
      aParam[5] - Contém o código do novo grupo de opcionais.
      aParam[6] - Contém o código do novo item opcionai.
      aParam[7] - Contém um array com o R_E_C_N_O_ dos registros que serão alterados na SG1.
   */
   Local aReturn := {}
   /*
      aReturn[1] - Identifica o status que será retornado, .T. ou .F.
      aReturn[2] - Contém uma mensagem a ser exibida no Fluig.
   */

   If !Empty(cParam)
       If !FwJsonDeserialize(cParam,@aParam)
           aReturn[1] := .F.
           aReturn[2] := STR0009 //"Erro ao realizar o deserialize dos parametros."
           Return aReturn
       EndIf
   EndIf

   aAdd(aReturn,.T.)
   aAdd(aReturn,"")

   For index := 1 To Len(aParam[7])
      dbSelectArea("SG1")
      SG1->(dbSetOrder(1))
      SG1->(dbGoTo(aParam[7][index]))

      // Valida SGF - Oper. x Compon.
      dbSelectArea("SGF")
      SGF->(dbSetOrder(2))
      SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
      While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
         If SGF->GF_COMP == SG1->G1_COMP // Encontra o componente a ser substituido
            nRecnoSGF := SGF->(Recno())
            If SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD+SGF->GF_ROTEIRO+ PadR(aParam[4],TamSX3("GF_COMP")[1])))
               lRet := .F.
               Exit
            EndIf
            SGF->(dbGoto(nRecnoSGF))
            AADD(aRecnosSGF,nRecnoSGF)
         EndIf
         SGF->(dbSkip())
      EndDo
      If !lRet
         Exit
      EndIf
   Next index

   If lRet

      // Grava a substituicao de componentes
      If !("DB2" $ TCGetDB())
         if Len(aParam[7]) < 1001  //tratamento para oracle pois tem limite de 1000 itens no "IN"
            cQuery := "UPDATE "
            cQuery += RetSqlName("SG1")+" "
            cQuery += "SET G1_COMP  = '" + PadR(aParam[4],TamSX3("G1_COMP")[1])  +"', "+;
                         " G1_GROPC = '" + PadR(aParam[5],TamSX3("G1_GROPC")[1]) +"', "+;
                         " G1_OPC   = '" + PadR(aParam[6],TamSX3("G1_OPC")[1])   +"' "
            cQuery += " WHERE G1_COD <> '" + PadR(aParam[4],TamSX3("G1_COD")[1]) +"' "+;
                        " AND R_E_C_N_O_ IN ("
            For nz:=1 to Len(aParam[7])
               If nz > 1
                  cQuery+= ","
               EndIf
               cQuery+= "'"+Str(aParam[7][nz],10,0)+"'"
            Next nz
            cQuery += ")"
            //-- NAO efetua o UPDATE, caso a estrutura ja possua o NOVO componente
            cQuery += " AND G1_COD NOT IN ( SELECT G1_COD "
            cQuery += " FROM " + RetSqlName("SG1")  + " SG12 "
            cQuery += " WHERE SG12.G1_FILIAL = '" + xFilial('SG1')+ "'"
            cQuery += " AND SG12.G1_COMP  = '" + PadR(aParam[4],TamSX3("G1_COMP")[1])  +"'"
            cQuery += " AND SG12.G1_GROPC = '" + PadR(aParam[5],TamSX3("G1_GROPC")[1]) +"'"
            cQuery += " AND SG12.G1_OPC   = '" + PadR(aParam[6],TamSX3("G1_OPC")[1])   +"'"
            cQuery += " AND SG12.D_E_L_E_T_ = ' ' )

            TcSqlExec(cQuery)
         Else
            For nz:=1 to Len(aParam[7])
               cQuery := "UPDATE "
               cQuery += RetSqlName("SG1")+" "
               cQuery += "SET G1_COMP  = '" + PadR(aParam[4],TamSX3("G1_COMP")[1])  + "' , " + ;
                            " G1_GROPC = '" + PadR(aParam[5],TamSX3("G1_GROPC")[1]) + "' , " + ;
                            " G1_OPC   = '" + PadR(aParam[6],TamSX3("G1_OPC")[1])   + "' "
               cQuery += " WHERE G1_COD <> '" + PadR(aParam[4],TamSX3("G1_COD")[1]) + "' " + ;
                           " AND R_E_C_N_O_ = "
               cQuery += "'"+Str(aParam[7][nz],10,0)+"'"
               cQuery += " AND G1_COD NOT IN ( SELECT G1_COD "
               cQuery += " FROM " + RetSqlName("SG1")  + " SG12 "
               cQuery += " WHERE SG12.G1_FILIAL = '" + xFilial('SG1')+ "'"
               cQuery += " AND SG12.G1_COMP  = '" + PadR(aParam[4],TamSX3("G1_COMP")[1])  + "'"
               cQuery += " AND SG12.G1_GROPC = '" + PadR(aParam[5],TamSX3("G1_GROPC")[1]) + "'"
               cQuery += " AND SG12.G1_OPC   = '" + PadR(aParam[6],TamSX3("G1_OPC")[1])   + "'"
               cQuery += " AND SG12.D_E_L_E_T_ = ' ' )

               TcSqlExec(cQuery)
            Next nz
         EndIF
      Else
         dbSelectArea("SG1")
         SG1->(dbSetOrder(1))
         For nz:=1 to Len(aParam[7])
            SG1->(dbGoto(aParam[7][nz]))
            Reclock("SG1",.F.)
            Replace G1_COMP  With PadR(aParam[4],TamSX3("G1_COMP")[1])
            Replace G1_GROPC With PadR(aParam[5],TamSX3("G1_GROPC")[1])
            Replace G1_OPC   With PadR(aParam[6],TamSX3("G1_OPC")[1])
            MsUnlock()
         Next nz
      EndIf

      // Grava a substituicao de componentes na tabela SGF
      dbSelectArea("SGF")
      For nz:=1 to Len(aRecnosSGF)
         dbGoto(aRecnosSGF[NZ])
         Reclock("SGF",.F.)
         Replace GF_COMP With PadR(aParam[4],TamSX3("GF_COMP")[1])
         MsUnlock()
      Next nz
      dbSelectArea("SG1")

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //| M200SUB - Ponto de entrada executado apos a gravacao  |
      //|           da substituicao dos componentes             |
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If ExistBlock("M200SUB")
         ExecBlock("M200SUB",.F.,.F.,aParam[7])
      EndIf

      // Altera conteudo do parametro de niveis
      a200NivAlt()
      MA320Nivel(Nil,Nil,.F.)
   EndIf
Return aReturn