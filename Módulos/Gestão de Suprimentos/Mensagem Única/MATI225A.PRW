#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'MATI225A.CH'

Static __cAdapter      := 'MATI225A'
Static __cMsgUnica     := "INVENTORYTRANSACTIONQUERY"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI225A
Adapter de consulta de estoque
  (mensagem InventoryTransactionQuery - Livro de medicamentos controlados).

@author  	Andre Carralero
@since   	03/04/2023
@version  	P12
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem
/*/
//------------------------------------------------------------------------------------------
Function MATI225A()
   Local lRet      := .T.
   Local cResult   := ""
   Local aIntegDef := FWIntegDef(__cAdapter, , , , __cAdapter, .T.)
   Local oFWEAI

   If aIntegDef[2] <> ""
      /*
      Passagem por este bloco ocorre quando há envio de mensagem (XX4_SENDER==1)
      */
      oFWEAI := FWEAI():New()
      oFWEAI:SetFuncCode( __cMsgUnica )
      oFWEAI:SetFuncDescription( __cMsgUnica )
      oFWEAI:SetDocType( PROC_SYNC ) //< PROC_SYNC = Sincrono, PROC_ASYNC = Assincrono > ) // olhar a configuração do ADAPTER
      oFWEAI:AddLayout( __cAdapter, aIntegDef[3], __cAdapter, aIntegDef[2] )
      oFWEAI:SetTypeMessage( EAI_MESSAGE_BUSINESS ) // olhar a configuração do ADAPTER para ver se é Mensagem ÚNICA ou MVC
      oFWEAI:SetSendChannel( EAI_CHANNEL_EAI )//< EAI_CHANNEL_ESB = ESB, EAI_CHANNEL_EAI = EAI > ) // olhar a configuração do ADAPTER para ver se é Mensagem ÚNICA ou MVC
      oFWEAI:SetDocVersion( FWAdapterVersion(__cAdapter, __cMsgUnica) )
      oFWEAI:Activate()

      lRet := oFWEAI:Save()
      cResult:= oFWEAI:cResult
      
      FreeObj(oFWEAI)
      DelClassIntf()

EndIf

FwFreeArray(aIntegDef)

Return {lRet, cResult}

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica

@sample 	IntegDef( cXML, cTypeTrans, cTypeMessage , cVersion, cTransaction)
@param		cXml - O XML recebido pelo EAI Protheus
			cTypeTrans - Tipo de transacao
				0- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				1- para mensagem sendo enviada (DEFINE TRANS_SEND)
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
            cVersion - Versao da mensagem
            cTransaction - Nome da transação.
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro
@author  	Andre Carralero
@since   	03/04/2023
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function IntegDef( cXml, cTypeTrans, cTypeMessage, cVersion, cTransaction)
   Local lRet          := .T.
   Local cXMLRet       := ""
   Local cProdIniLivro := ""
   Local cProdFimLivro := ""
   Local cFilIniLivro  := ""
   Local cFilFimLivro  := ""
   Local dtInicioLivro := SToD("")
   Local dtFinalLivro  := SToD("")
   Local cDate         := ""
   Local cEvent        := ""

   Local cFilSF4       := ""
   Local cFilSF5       := ""

   //Variaveis utilizadas no De/Para de Codigo Interno X Codigo Externo
   Local cQuery    := ""
   Local cAliasMov := GetNextAlias()
   Local oXML      := Nil
   Local aSD3CF    := {}
   Local cPathNode := ""
   Local cPath     := ""
   Local cNodeBC   := ""
   Local cNodeQuery:= ""

   Default cXml            := ""
   Default cTypeTrans      := "3"
   Default cTypeMessage    := ""
   Default cVersion        := ""
   Default cTransaction    := ""
     

   AAdd( aSD3CF , {"RE0", STR0002 } ) // "Requisição manual"
   AAdd( aSD3CF , {"RE1", STR0003 } ) // "Requisição automática"
   AAdd( aSD3CF , {"RE2", STR0004 } ) // "Requisição automática de material de apropriação indireta"
   AAdd( aSD3CF , {"RE3", STR0005 } ) // "Requisição ao Armazém de Processo (MV_LOCPROC)"
   AAdd( aSD3CF , {"RE4", STR0006 } ) // "Requisição por transferência"
   AAdd( aSD3CF , {"RE5", STR0007 } ) // "Requisição informando OP na nota fiscal de entrada"
   AAdd( aSD3CF , {"RE6", STR0008 } ) // "Requisição valorizada / Requisição do Armazém de Qualidade (MV_CQ)"
   AAdd( aSD3CF , {"RE7", STR0009 } ) // "Requisição para transferência de um para “N”"
   AAdd( aSD3CF , {"RE9", STR0010 } ) // "Requisição para OP sem agregar custo"
   AAdd( aSD3CF , {"REA", STR0011 } ) // "Reavaliação de custo médio (Requisição de valor final para período)"
   AAdd( aSD3CF , {"DE0", STR0012 } ) // "Devolução manual"
   AAdd( aSD3CF , {"DE1", STR0013 } ) // "Devolução automática - estorno da produção"
   AAdd( aSD3CF , {"DE2", STR0014 } ) // "Devolução automática de material de apropriação indireta - estorno da produção"
   AAdd( aSD3CF , {"DE3", STR0015 } ) // "Devolução do Armazém de Processo (MV_LOCPROC)"
   AAdd( aSD3CF , {"DE4", STR0016 } ) // "Devolução de transferência entre locais"
   AAdd( aSD3CF , {"DE5", STR0017 } ) // "Devolução de material apropriado em OP – (exclusão de nota fiscal de entrada)"
   AAdd( aSD3CF , {"DE6", STR0018 } ) // "Devolução valorizada / Devolução ao armazém destino oriundo do Armazém de Qualidade (MV_CQ)"
   AAdd( aSD3CF , {"DE7", STR0019 } ) // "Devolução de transferência de um para “N”"
   AAdd( aSD3CF , {"DE9", STR0020 } ) // "Devolução para OP sem agregar custo"
   AAdd( aSD3CF , {"DEA", STR0021 } ) // "Reavaliação de custo médio (Devolução de valor final para período)"
   AAdd( aSD3CF , {"PR0", STR0022 } ) // "Produção manual"
   AAdd( aSD3CF , {"PR1", STR0023 } ) // "Produção automática"
   AAdd( aSD3CF , {"ER0", STR0024 } ) // "Estorno de produção manual"
   AAdd( aSD3CF , {"ER1", STR0025 } ) // "Estorno de produção automática"

   AdpLogEAI(1, __cAdapter, cTypeTrans, cTypeMessage, cXML)

   //Tratamento do recebimento de mensagens
   If ( cTypeTrans == TRANS_RECEIVE )

      If cTypeMessage == EAI_MESSAGE_BUSINESS .OR. cTypeMessage == EAI_MESSAGE_RESPONSE

         oXML := tXMLManager():New()

         xRet := oXML:Parse( cXML )
         if xRet

            cPath := '/TOTVSMessage' // Parse já feito pelo EAI PROTHEUS 
            cPath := cPath + '/BusinessMessage' // Parse já feito pelo EAI PROTHEUS

            cNodeBC := cPath + '/BusinessContent'
            if oXml:XPathHasNode( cNodeBC )
               cNodeQuery := cNodeBC + '/Query'
               if oXml:XPathHasNode( cNodeQuery )
                  cPathNode := cNodeQuery + '/ItemCode'

                  if oXml:XPathHasNode( cPathNode )

                     cProdIniLivro  := oXml:xPathGetNodeValue(cPathNode+'/InitialItemCode')
                     if Empty(cProdIniLivro)
                        lRet := .F.
                        cXMLRet := I18N(STR0001, {"InitialItemCode"}) //"Nao existe a Tag InitialItemCode"
                     EndIf

                     cProdFimLivro  := oXml:xPathGetNodeValue(cPathNode+'/FinalItemCode') //"Nao existe a Tag FinalItemCode"
                     if Empty(cProdFimLivro)
                        lRet := .F.
                        cXMLRet := I18N(STR0001, {"FinalItemCode"}) //"Nao existe a Tag FinalItemCode"
                     EndIf
                  Else
                     lRet := .F.
                     cXMLRet := I18N(STR0001, {"ItemCode"}) //"Nao existe a Tag ItemCode"
                  EndIf

                  cPathNode := cNodeQuery + '/Site'
                  if oXml:XPathHasNode( cPathNode )

                     cFilIniLivro := oXml:xPathGetNodeValue(cPathNode+'/InitialSiteID')
                     if Empty(cFilIniLivro)
                        lRet := .F.
                        cXMLRet := I18N(STR0001, {"InitialSiteID"}) //"Nao existe a Tag InitialSiteID"
                     EndIf

                     cFilFimLivro := oXml:xPathGetNodeValue(cPathNode+'/FinalSiteID')
                     if Empty(cFilFimLivro)
                        lRet := .F.
                        cXMLRet := I18N(STR0001, {"FinalSiteID"}) //"Nao existe a Tag FinalSiteID"
                     EndIf

                  Else
                     lRet := .F.
                     cXMLRet := I18N(STR0001, {"Site"}) //"Nao existe a Tag Site"
                  EndIf

                  cPathNode := cNodeQuery + '/TransactionDate'
                  if oXml:XPathHasNode( cPathNode )
                     cDate := oXml:xPathGetNodeValue(cPathNode+'/InitialTransactionDate')
                     dtInicioLivro := SToD( StrTran(Left(cDate, 10), '-',''))
                     if Empty(dtInicioLivro)
                        lRet := .F.
                        cXMLRet := I18N(STR0001, {"InitialTransactionDate"}) //"Nao existe a Tag InitialTransactionDate" 
                     EndIf

                     cDate := oXml:xPathGetNodeValue(cPathNode+'/FinalTransactionDate')
                     dtFinalLivro := SToD( StrTran(Left(cDate, 10), '-',''))
                     if Empty(dtFinalLivro)
                        lRet := .F.
                        cXMLRet := I18N(STR0001, {"FinalTransactionDate"}) //"Nao existe a Tag FinalTransactionDate"
                     EndIf
                  Else
                     lRet := .F.
                     cXMLRet := I18N(STR0001, {"TransactionDate"}) //"Nao existe a Tag TransactionDate"
                  EndIf
               Else
                  lRet := .F.
                  cXMLRet := I18N(STR0001, {"Query"}) //"Nao existe a Tag TransactionDate"
               EndIf
            Else
               lRet := .F.
               cXMLRet := I18N(STR0001, {"BusinessContent"}) //"Nao existe a Tag TransactionDate"
            EndIf

            If lRet
               cEvent := "upsert"
               
               cXMLRet := '<BusinessEvent>'
               cXMLRet +=     '<Entity>'+__cMsgUnica+'</Entity>'
               cXMLRet +=     '<Event>' + cEvent + '</Event>'
               cXMLRet +=     '<Identification>'
               cXMLRet +=         '<key name="InternalId">' + cEmpAnt + '|' + RTrim(xFilial('SD3')) + '</key>'
               cXMLRet +=     '</Identification>'
               cXMLRet += '</BusinessEvent>'
               cXMLRet += '<BusinessContent>'
               cXMLRet += '<ListOfPrescriptionDrugBook>'
               cXMLRet += '<InternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</InternalId>'
               cXMLRet += '<CompanyId>' + cEmpAnt + '</CompanyId>'
               cXMLRet += '<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
               cXMLRet += '<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
               cXMLRet += '<RegisterDateTime>'+Transform(DToS(Date()),"@R 9999-99-99")+'</RegisterDateTime>'

               cFilSF4 := xFilial("SF4")
               cFilSF5 := xFilial("SF5")

               cQuery := "SELECT SB1.R_E_C_N_O_ RECSB1 , SB1.B1_COD, SB2.R_E_C_N_O_ RECSB2 , SB2.B2_LOCAL, "
               cQuery +=       " ISNULL(ORIGEM,'') ORIGEM, ISNULL(EMISSAO,'') EMISSAO, ISNULL(DOCUMENT,'')  , ISNULL(NUMSEQ,'') NUMSEQ, ISNULL(TM,'') TM, ISNULL(CF,'') CF, ISNULL(RECMOV,0) RECMOV, ISNULL(RECTPMOV,0) RECTPMOV "
               cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
               cQuery += "INNER JOIN " + RetSqlName("SB2 ") + " SB2 "
               cQuery += "  ON "
               cQuery += " SB2.B2_FILIAL      = ? " // 1-
               cQuery += " AND SB2.B2_COD     = SB1.B1_COD "
               cQuery += " AND SB2.D_E_L_E_T_ = ? "  // 2-
               cQuery += "LEFT JOIN (SELECT 'SD1' ORIGEM, SD1.D1_COD CODIGO, SD1.R_E_C_N_O_ RECMOV, SD1.D1_DTDIGIT EMISSAO, SD1.D1_LOCAL ALMOX, "
               cQuery +=                    "D1_SERIE+D1_DOC DOCUMENT, SD1.D1_NUMSEQ NUMSEQ, SD1.D1_TES TM, SD1.D1_CF CF, SF4.R_E_C_N_O_ RECTPMOV "
               cQuery +=           " FROM " + RetSqlName("SD1") + " SD1 "
               cQuery +=           " INNER JOIN " + RetSqlName("SF4") + " SF4 "
               cQuery +=           " ON "
               cQuery +=           " SF4.F4_FILIAL = ? " // 3-
               cQuery +=           " AND SF4.F4_CODIGO = SD1.D1_TES"
               cQuery +=           " AND SF4.D_E_L_E_T_ = ?" // 4-
               cQuery +=           " WHERE "
               cQuery +=           " SD1.D1_FILIAL = ? " // 5-
               cQuery +=           " AND SD1.D1_COD >= ? " // 6-
               cQuery +=           " AND SD1.D1_COD <= ? " // 7-
               cQuery +=           " AND SD1.D1_DTDIGIT >= ? " // 8 -
               cQuery +=           " AND SD1.D1_DTDIGIT <= ? " // 9 -
               cQuery +=           " AND SD1.D_E_L_E_T_ = ? " // 10-
               cQuery +=           " UNION ALL "
               cQuery +=           " SELECT 'SD2' ORIGEM, SD2.D2_COD CODIGO, SD2.R_E_C_N_O_ RECMOV, SD2.D2_EMISSAO EMISSAO, SD2.D2_LOCAL ALMOX, "
               cQuery +=                    "D2_SERIE+D2_DOC DOCUMENT, SD2.D2_NUMSEQ NUMSEQ, SD2.D2_TES TM, SD2.D2_CF CF, SF4.R_E_C_N_O_ RECTPMOV "
               cQuery +=           " FROM " + RetSqlName("SD2") + " SD2 "
               cQuery +=           " INNER JOIN " + RetSqlName("SF4") + " SF4 "
               cQuery +=           " ON "
               cQuery +=           " SF4.F4_FILIAL = ? " // 11 -
               cQuery +=           " AND SF4.F4_CODIGO = SD2.D2_TES"
               cQuery +=           " AND SF4.D_E_L_E_T_ = ? " // 12 -
               cQuery +=           " WHERE "
               cQuery +=           " SD2.D2_FILIAL = ? " // 13 -
               cQuery +=           " AND SD2.D2_COD >= ? " // 14 -
               cQuery +=           " AND SD2.D2_COD <= ? " // 15 -
               cQuery +=           " AND SD2.D2_EMISSAO >= ? " // 16 -
               cQuery +=           " AND SD2.D2_EMISSAO <= ? " // 17 -
               cQuery +=           " AND SD2.D_E_L_E_T_ = ? " // 18 -
               cQuery +=           " UNION ALL "
               cQuery +=           " SELECT 'SD3' ORIGEM, SD3.D3_COD CODIGO, SD3.R_E_C_N_O_ RECMOV,  SD3.D3_EMISSAO EMISSAO, SD3.D3_LOCAL ALMOX, "
               cQuery +=                    "D3_DOC DOCUMENT, SD3.D3_NUMSEQ NUMSEQ, SD3.D3_TM, SD3.D3_CF CF, SF5.R_E_C_N_O_ RECTPMOV "
               cQuery +=           " FROM " + RetSqlName("SD3") + " SD3 "
               cQuery +=           " LEFT JOIN " + RetSqlName("SF5") + " SF5 "
               cQuery +=           " ON "
               cQuery +=           " SF5.F5_FILIAL = ? " // 19-
               cQuery +=           " AND SF5.F5_CODIGO = SD3.D3_TM "
               cQuery +=           " AND SF5.D_E_L_E_T_ = ? " // 20- 
               cQuery +=           " WHERE "
               cQuery +=           " SD3.D3_FILIAL = ? " // 21 = 
               cQuery +=           " AND SD3.D3_COD >= ? " // 22 
               cQuery +=           " AND SD3.D3_COD <= ? " // 23 
               cQuery +=           " AND SD3.D3_EMISSAO >= ? " // 24 = 
               cQuery +=           " AND SD3.D3_EMISSAO <= ? " // 25 = 
               cQuery +=           " AND SD3.D_E_L_E_T_ = ? " // 26 = 
               cQuery += ") MOV ON MOV.CODIGO = SB1.B1_COD "
               cQuery += "AND MOV.ALMOX  = SB2.B2_LOCAL "
               cQuery += "WHERE "
               cQuery += " SB1.B1_FILIAL = ? " // 27 = 
               cQuery += "AND SB1.B1_COD >= ? " // 28 = 
               cQuery += "AND SB1.B1_COD <= ? " // 29 = 
               cQuery += "AND SB1.D_E_L_E_T_ = ? " // 30 = 
               cQuery += "ORDER BY SB1.B1_COD,SB2.B2_LOCAL,MOV.EMISSAO, MOV.ORIGEM, MOV.DOCUMENT, MOV.NUMSEQ, MOV.TM, MOV.CF"
               cQuery := ChangeQuery(cQuery)

               oQry := FwExecStatement():New(cQuery)

               oQry:SetString( 1, FWxFilial("SB2", cFilIniLivro))
               oQry:SetString( 2, ' ')

               oQry:SetString( 3, cFilSF4)
               oQry:SetString( 4, ' ')
               oQry:SetString( 5, FWxFilial("SD1", cFilIniLivro) )
               oQry:SetString( 6, cProdIniLivro )
               oQry:SetString( 7, cProdFimLivro )
               oQry:SetString( 8, DToS(dtInicioLivro))
               oQry:SetString( 9, DToS(dtFinalLivro) )
               oQry:SetString(10, ' ')

               oQry:SetString(11, cFilSF4)
               oQry:SetString(12, ' ')

               oQry:SetString(13, FWxFilial("SD2", cFilIniLivro) )
               oQry:SetString(14, cProdIniLivro)
               oQry:SetString(15, cProdFimLivro)
               oQry:SetString(16, DToS(dtInicioLivro))
               oQry:SetString(17, DToS(dtFinalLivro))
               oQry:SetString(18, ' ')

               oQry:SetString(19, cFilSF5)
               oQry:SetString(20, ' ')

               oQry:SetString(21, FWxFilial("SD3", cFilIniLivro) )
               oQry:SetString(22, cProdIniLivro)
               oQry:SetString(23, cProdFimLivro)
               oQry:SetString(24, DToS(dtInicioLivro))
               oQry:SetString(25, DToS(dtFinalLivro))
               oQry:SetString(26, ' ' )

               oQry:SetString(27, FWxFilial("SB1", cFilIniLivro) )
               oQry:SetString(28, cProdIniLivro )
               oQry:SetString(29, cProdFimLivro )
               oQry:SetString(30, ' ' )

               cAliasMov := oQry:OpenAlias()

               cXMLRet +=  '<ListOfPrescriptionDrugBookItems>'
               While !(cAliasMov)->(EoF())
                  SB1->(MSGoTo((cAliasMov)->RECSB1))
                  SB2->(MSGoTo((cAliasMov)->RECSB2))

                  cProduto  := SB1->B1_COD
                  cLocal    := SB2->B2_LOCAL
                  nSldIni   := CalcEst(cProduto,cLocal,dtInicioLivro)[1]
                  nInputs   := 0
                  nOutPuts  := 0
                  cXMLMov   := ""
                  While !(cAliasMov)->(EoF()) .And.;
                        (cAliasMov)->B1_COD == cProduto .And.;
                        (cAliasMov)->B2_LOCAL == cLocal

                     cXMLMov += '<StockTurnoverItem>'
                     cXMLMov += '<ItemInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '|' + RTrim(cProduto) + '|' + RTrim(cLocal) +'</ItemInternalId>'
                     cXMLMov += '<ItemCode>'+RTrim(cProduto)+'</ItemCode>'
                     If (cAliasMov)->ORIGEM == 'SD1'
                        SD1->(MSGoTo((cAliasMov)->RECMOV))
                        SF4->(MSGoTo((cAliasMov)->RECTPMOV))
                        nInputs  += SD1->D1_QUANT
                        cXMLMov += '<Document>'+SD1->(D1_SERIE+D1_DOC)+'</Document>'
                        cXMLMov += '<Sequence>'+SD1->D1_NUMSEQ+'</Sequence>'
                        cXMLMov += '<MovementTypeCode>'+SD1->D1_TES+'</MovementTypeCode>'
                        cXMLMov += '<TypeofRequestOrReturn>'+SD1->D1_CF+'</TypeofRequestOrReturn>'
                        cXMLMov += '<DescriptionMovementType>DOC.ENTRADA('+AllTrim(SF4->F4_TEXTO)+')</DescriptionMovementType>'
                        cXMLMov += '<EmissionDate>'+Transform(DToS(SD1->D1_EMISSAO),"@R 9999-99-99")+'</EmissionDate>'
                        cXMLMov += '<UnitPrice>'+cValToChar(SD1->D1_VUNIT)+'</UnitPrice>'
                        cXMLMov += '<TotalPrice>'+cValToChar(SD1->D1_TOTAL)+'</TotalPrice>'
                        cXMLMov += '<Quantity>'+cValToChar(SD1->D1_QUANT)+'</Quantity>'
                        cXMLMov += '<UnitOfMeasureInternalId>'+SD1->D1_UM+'</UnitOfMeasureInternalId>'
                        cXMLMov += '<UnitOfMeasureCode>'+SD1->D1_UM+'</UnitOfMeasureCode>'
                        cXMLMov += '<DeliveryDateTime>'+Transform(DToS(SD1->D1_DTDIGIT),"@R 9999-99-99")+'</DeliveryDateTime>'
                        cXMLMov += tagCC(SD1->D1_CC)

                     ElseIf (cAliasMov)->ORIGEM == 'SD2'
                        SD2->(MSGoTo((cAliasMov)->RECMOV))
                        SF4->(MSGoTo((cAliasMov)->RECTPMOV))
                        nOutPuts += SD2->D2_QUANT
                        cXMLMov += '<Document>'+SD2->(D2_SERIE+D2_DOC)+'</Document>'
                        cXMLMov += '<Sequence>'+SD2->D2_NUMSEQ+'</Sequence>'
                        cXMLMov += '<MovementTypeCode>'+SD2->D2_TES+'</MovementTypeCode>'
                        cXMLMov += '<TypeofRequestOrReturn>'+SD2->D2_CF+'</TypeofRequestOrReturn>'
                        cXMLMov += '<DescriptionMovementType>DOC.SAIDA('+AllTrim(SF4->F4_TEXTO)+')</DescriptionMovementType>'
                        cXMLMov += '<EmissionDate>'+Transform(DToS(SD2->D2_EMISSAO),"@R 9999-99-99")+'</EmissionDate>'
                        cXMLMov += '<UnitPrice>'+cValToChar(SD2->D2_PRCVEN)+'</UnitPrice>'
                        cXMLMov += '<TotalPrice>'+cValToChar(SD2->D2_TOTAL)+'</TotalPrice>'
                        cXMLMov += '<Quantity>'+cValToChar(SD2->D2_QUANT)+'</Quantity>'
                        cXMLMov += '<UnitOfMeasureInternalId>'+SD2->D2_UM+'</UnitOfMeasureInternalId>'
                        cXMLMov += '<UnitOfMeasureCode>'+SD2->D2_UM+'</UnitOfMeasureCode>'
                        cXMLMov += '<DeliveryDateTime>'+Transform(DToS(SD2->D2_EMISSAO),"@R 9999-99-99")+'</DeliveryDateTime>'
                        cXMLMov += tagCC(SD2->D2_CCUSTO)

                     ElseIf (cAliasMov)->ORIGEM == 'SD3'
                        SD3->(MSGoTo((cAliasMov)->RECMOV))
                        If Left(SD3->D3_TM,1) < '5'
                           nInputs  += SD3->D3_QUANT
                           cDescrCF := "ENTRADA ("
                        Else
                           nOutPuts += SD3->D3_QUANT
                           cDescrCF := "SAIDA ("
                        EndIf
                        If (cAliasMov)->RECTPMOV != 0
                           SF5->(MSGoTo((cAliasMov)->RECTPMOV))
                           cDescrCF += AllTrim(SF5->F5_TEXTO)
                        ElseIf (cAliasMov)->RECTPMOV == 0 .And. AllTrim(SD3->D3_DOC) == 'INVENT'
                           cDescrCF += "INVENTARIO"
                        Else
                           If (nElem := AScan(aSD3CF,{|x|x[1]==AllTrim(SD3->D3_CF)})) > 0
                              cDescrCF += aSD3CF[nElem][2]
                           EndIf
                        EndIf
                        cDescrCF+=")"

                        cXMLMov += '<Document>'+SD3->D3_DOC+'</Document>
                        cXMLMov += '<Sequence>'+SD3->D3_NUMSEQ+'</Sequence>
                        cXMLMov += '<MovementTypeCode>'+SD3->D3_TM+'</MovementTypeCode>
                        cXMLMov += '<TypeofRequestOrReturn>'+SD3->D3_CF+'</TypeofRequestOrReturn>
                        cXMLMov += '<DescriptionMovementType>'+cDescrCF+'</DescriptionMovementType>'
                        cXMLMov += '<EmissionDate>'+Transform(DToS(SD3->D3_EMISSAO),"@R 9999-99-99")+'</EmissionDate>
                        cXMLMov += '<UnitPrice>'+cValToChar(SD3->(D3_CUSTO1/D3_QUANT))+'</UnitPrice>'
                        cXMLMov += '<TotalPrice>'+cValToChar(SD3->D3_CUSTO1)+'</TotalPrice>'
                        cXMLMov += '<Quantity>'+cValToChar(SD3->D3_QUANT)+'</Quantity>'
                        cXMLMov += '<UnitOfMeasureInternalId>'+SD3->D3_UM+'</UnitOfMeasureInternalId>'
                        cXMLMov += '<UnitOfMeasureCode>'+SD3->D3_UM+'</UnitOfMeasureCode>'
                        cXMLMov += '<DeliveryDateTime>'+Transform(DToS(SD3->D3_EMISSAO),"@R 9999-99-99")+'</DeliveryDateTime>'
                        cXMLMov += tagCC(SD3->D3_CC)
                     Else
                        cXMLMov+='<Document/>'
                        cXMLMov+='<Sequence/>'
                        cXMLMov+='<MovementTypeCode/>'
                        cXMLMov+='<TypeofRequestOrReturn/>'
                        cXMLMov+='<DescriptionMovementType/>'
                        cXMLMov+='<EmissionDate/>'
                        cXMLMov+='<UnitPrice/>'
                        cXMLMov+='<TotalPrice/>'
                        cXMLMov+='<Quantity/>'
                        cXMLMov+='<UnitOfMeasureInternalId/>'
                        cXMLMov+='<UnitOfMeasureCode/>'
                        cXMLMov+='<DeliveryDateTime/>'
                        cXMLMov+='<CostCenterInternalId/>'
                        cXMLMov+='<CostCenterCode/>'
                     EndIf
                     cXMLMov += '</StockTurnoverItem>
                     (cAliasMov)->(DbSkip())
                  End

                  cXMLRet += '<ListOfPrescriptionDrugBookItem>'
                  cXMLRet += '<ItemInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '|' + RTrim(cProduto) + '|' + RTrim(cLocal) +'</ItemInternalId>'
                  cXMLRet += '<CompanyId>' + cEmpAnt + '</CompanyId>'
                  cXMLRet += '<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
                  cXMLRet += '<ItemCode>' + RTrim(cProduto) + '</ItemCode>'
                  cXMLRet += '<WarehouseCode>' + RTrim(cLocal) +'</WarehouseCode>'
                  cXMLRet += '<WarehouseInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '|' + RTrim(cLocal) +'</WarehouseInternalId>'
                  cXMLRet += '<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '|' + RTrim(cProduto) + '|' + RTrim(cLocal) +'</CompanyInternalId>'
                  cXMLRet += '<LotOrSerialNumber/>'
                  cXMLRet += '<LotExpirationDate/>'
                  cXMLRet += '<previousBalance>'+cValToChar(nSldIni)+'</previousBalance>'
                  cXMLRet += '<inputs>'+cValToChar(nInputs)+'</inputs>'
                  cXMLRet += '<outputs>'+cValToChar(nOutPuts)+'</outputs>'
                  cXMLRet += '<finalBalance>'+cValToChar(nSldIni+nInputs-nOutPuts)+'</finalBalance>'
                  cXMLRet += cXMLMov
                  cXMLRet += '</ListOfPrescriptionDrugBookItem>'
               End
               (cAliasMov)->(dbCloseArea())
               oQry:Destroy()
               oQry := NIL

               cXMLRet += '</ListOfPrescriptionDrugBookItems>'
               cXMLRet += '</ListOfPrescriptionDrugBook>'
               cXMLRet += '</BusinessContent>'

            EndIf

         EndIf

         FreeObj(oXml)
         oXml := NIL

      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
         lRet    := .T.
         cXMLRet := '1.000'
      EndIf
   //Tratamento do envio de mensagens
   ElseIf cTypeTrans == TRANS_SEND
      lRet    := .T.
      cXMLRet := '1.000'
   EndIf

   AdpLogEAI(5, __cAdapter, cXmlRet, lRet)

   FwFreeArray(aSD3CF)

   DelClassIntf()

Return { lRet, cXMLRet, __cMsgUnica }

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} tagCC

@author  	Andre Carralero
@since   	03/04/2023
@version  	P12
@param      cCC - character - Código do centro de custo 
@return     cXML - character - trecho XML formataod com o Centro de Custo
/*/
//------------------------------------------------------------------------------------------
Static Function tagCC(cCC)
Local cXML := ""

   If Empty(cCC) 
      cXML +=  '<CostCenterInternalId/>'
      cXML +=  '<CostCenterCode/>'
   Else
      cXML += '<CostCenterInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '|' + RTrim(cCC) + '</CostCenterInternalId>'
      cXML += '<CostCenterCode>' + RTrim(cCC) + '</CostCenterCode>'
   EndIf

return cXML
