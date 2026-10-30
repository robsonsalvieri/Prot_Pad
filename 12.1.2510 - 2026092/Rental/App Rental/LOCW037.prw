#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "Protheus.ch" 
#Include "tbiconn.ch"
#Include "Topconn.CH"  
#Include "fileio.ch"

/*/{Protheus.doc} LOCW037
@description	API Consulta Proposta RENTAL
@author			Dennis Calabrez
@since     		21/10/2025
/*/    
WSRESTFUL LOCW037 DESCRIPTION "Consulta Proposta RENTAL" 
 
   WSMETHOD GET DESCRIPTION "Consulta Proposta RENTAL" WSSYNTAX "/LOCW037/{param1}/{param2}"

END WSRESTFUL

/*/{Protheus.doc} METODO GET
@description	API Consulta Proposta RENTAL
@author			Dennis Calabrez
@since     		21/10/2025
/*/    
WSMETHOD GET WSSERVICE LOCW037
Local cResponse := ""
Local cParam1   := ""
Local cParam2   := ""
Local cProjet   := ""
Local cAut      := ""
Local aPar      := {}

   aPar := GetUrlParams2(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
   cParam2 := aPar[2]

	cProjet := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o Projeto e informado
   cAut    := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta

   cResponse :=  LOCW0371(cProjet ,cAut)
   cResponse := FWNoAccent(cResponse)

   ::SetContentType("application/json; charset=iso-8859-1")
   ::SetResponse(EncodeUtf8(cResponse))

Return .T.

/*/{Protheus.doc} LOCW0371
@description	Query de consulta de Projetos
@author			Dennis Calabrez
@since     		21/10/2025
/*/   
Static Function LOCW0371(cProjet,cAut)
Local cQuery      := ""
Local cRetorno    := ""
Local cProjs      := ""
Local cObras      := ""
Local cEquips     := ""
Local cErro       := ""
Local cBreakProj  := ""
Local cBreakObra  := ""
Local cBreakEqui  := ""
Local nTotalCou   := 0
Local aBindParam  := {}

   aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
   If (aEmp[3] == "Empresa já existente.")
      cRet := xAbreEnv1(aEmp[1],aEmp[2])
      If Empty(cRet)
         cQuery += " SELECT  "
         cQuery += "    FP0.R_E_C_N_O_ RECFP0, "
         cQuery += "    FP0_FILIAL FILREF, "
         cQuery += "    FP0_PROJET PROPOSTA, "
         cQuery += "    FP0_CLI CLIENTE, "
         cQuery += "    FP0_LOJA LOJA , "
         cQuery += "    A1_NOME NOME_CLIENTE, "
         cQuery += "    FP0_TPENVI TIPO_ENVIO, "
         cQuery += "    FP0_CODCON CODIGO_CONCORR, "
         cQuery += "    FP0_VALCON VALOR_CONCORR, "
         cQuery += "    FP0_PMEDIC PERIODO_MEDICAO, "
         cQuery += "    FP0_TIPFAT TIPO_FATURAMENTO, "
         cQuery += "    FP0_COMPLE COMPLEMENTO, "
         cQuery += "    FP0_VALPRO VALOR_PROJETO, "
         cQuery += "    FP0_MINPFT TIPO_FATURA, "
         cQuery += "    FP0_MOEDA MOEDA,"
         cQuery += "    FP0_NIVEL NIVEL,"
         cQuery += "    FP0_USUAPR APROVADOR,"
         cQuery += "    FP1_OBRA OBRA,"
         cQuery += "    FP1_CLIORI CLIENTE_OBRA,"
         cQuery += "    FP1_LOJORI LOJA_OBRA,"
         cQuery += "    FP1_NOMORI NOME_OBRA,"
         cQuery += "    FP1_NOMRES RESPONSAVEL,"
         cQuery += "    FP1_RESPON EMAIL_RESPONSAVEL,"
         cQuery += "    FPA_SEQGRU ITEM_FPA,"
         cQuery += "    FPA_PRODUT PRODUTO,"
         cQuery += "    B1_DESC DESCRICAO_PRODUTO,"
         cQuery += "    FPA_GRUA EQUIPAMENTO,"
         cQuery += "    T9_NOME DESCRICAO_EQUIPAMENTO,"
         cQuery += "    FPA_QUANT QUANTIDADE,"
         cQuery += "    FPA_PRCUNI VALOR_UNITARIO,"
         cQuery += "    FPA_PDESC PERCENTUAL_DESCONTO,"
         cQuery += "    FPA_VALDES VALOR_DESCONTO,"
         cQuery += "    FPA_VRHOR  VALOR_LIQUIDO,"
         cQuery += "    FPA_DTINI DATA_INICIO,"
         cQuery += "    FPA_HRINI HORA_INICIO,"
         cQuery += "    FPA_HRFIM HORA_FIM,"
         cQuery += "    FPA_DTFIM DATA_FIM,"
         cQuery += "    FPA_DTENRE DATA_FIM_LOCACAO,"
         cQuery += "    FPA_GERAEM DATA_GERA_FATURAMENTO,"
         cQuery += "    FPA_CONPAG CONDICAO_PAGAMENTO,"
         cQuery += "    E4_DESCRI DESCRICAO_CONDICAO_PAGAMENTO,"
         cQuery += "    FPA_CLIFAT CLIENTE_FATURAMENTO "
         cQuery += " FROM " + RetSqlName("FP0") + " FP0 "
         cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON  "
         cQuery += "    SA1.D_E_L_E_T_ = ' ' AND "
         cQuery += "    A1_COD = FP0_CLI AND "
         cQuery += "    A1_LOJA = FP0_LOJA "
         cQuery += "    AND A1_FILIAL = '"+xFilial("SA1")+"' "
         cQuery += " INNER JOIN " + RetSqlName("FP1") + " FP1 ON  "
         cQuery += "    FP1.D_E_L_E_T_ = ' ' AND "
         cQuery += "    FP1_FILIAL = '"+xFilial("FP1")+"' "
         cQuery += "    AND FP1_PROJET = FP0_PROJET "
         cQuery += " LEFT JOIN " + RetSqlName("FPA") + " FPA ON  "
         cQuery += "    FPA.D_E_L_E_T_ = ' ' AND " 
         cQuery += "     FPA_FILIAL = '"+xFilial("FPA")+"' "
         cQuery += "    AND FPA_PROJET = FP1_PROJET AND " 
         cQuery += "    FPA_OBRA = FP1_OBRA "
         cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 ON  "
         cQuery += "    SB1.D_E_L_E_T_ = ' ' AND " 
         cQuery += "    B1_COD = FPA_PRODUT AND " 
         cQuery += "     B1_FILIAL = '"+xFilial("SB1")+"' "
         cQuery += " LEFT JOIN " + RetSqlName("ST9") + " ST9 ON  "
         cQuery += "    ST9.D_E_L_E_T_ = ' ' AND "
         cQuery += "    T9_CODBEM = FPA_GRUA AND "
         cQuery += "     T9_FILIAL = '"+xFilial("ST9")+"' "
         cQuery += " LEFT JOIN " + RetSqlName("SE4") + " SE4 ON  "
         cQuery += "    SE4.D_E_L_E_T_ = ' ' AND "
         cQuery += "    E4_CODIGO = FPA_CONPAG "
         cQuery += "     AND E4_FILIAL = '"+xFilial("SE4")+"' "
         cQuery += " WHERE  "
         cQuery += "    FP0.D_E_L_E_T_ = ' ' "
         cQuery += "    AND  FP0_STATUS = '2' "
         cQuery += "    AND  FP0_FILIAL = ? "
         aadd(aBindParam,xFilial("FP0"))

         If !Empty(cProjet)
            cQuery += "    AND  FP0_PROJET = ? "
            aadd(aBindParam,cProjet)
         EndIf
         cQuery += "    ORDER BY "
         cQuery += "       FP0_FILIAL, "
         cQuery += "       FP0_PROJET, "
         cQuery += "       FP1_OBRA, "
         cQuery += "       FPA_SEQGRU "

         cQuery := ChangeQuery(cQuery)
         MPSysOpenQuery(cQuery,"TRBFP0",,,aBindParam)

         If !TRBFP0->(Eof())

            cRetorno += ' { '
            cRetorno += '    "RETORNO"   : { '
            cRetorno += '        "DESCRICAO" : "OK - Registros Localizados: $$"'
            cRetorno += '    }, '
            cRetorno += '	"LISTA_PROPOSTAS": ['

            While !TRBFP0->(Eof())

               // quebra por Projeto
               If cBreakProj <> TRBFP0->FILREF + TRBFP0->PROPOSTA

                  cBreakProj  := TRBFP0->FILREF + TRBFP0->PROPOSTA
                  cObras      := ""
                  nTotalCou++

                  //fecha linha caso tenha mais de uma
                  If !Empty(cProjs)
                     cRetorno += '						}'
                     cRetorno += '					]'

                     cRetorno += '				}'
                     cRetorno += '			]'

                     cRetorno += '		},' 
                     cProjs   := ""
                  EndIf

                  FP0->(DbGoTo(TRBFP0->RECFP0))

                  //abre linha Projeto 
                  cProjs += '		{'
                  cProjs += '			"FILREF"                   : "' + AllTrim(TRBFP0->FILREF)                     + '",'  
                  cProjs += '			"PROPOSTA"                 : "' + AllTrim(TRBFP0->PROPOSTA)                   + '",'  
                  cProjs += '			"CLIENTE"                  : "' + AllTrim(TRBFP0->CLIENTE)                    + '",'  
                  cProjs += '			"LOJA"                     : "' + AllTrim(TRBFP0->LOJA)                       + '",'  
                  cProjs += '			"NOME_CLIENTE"             : "' + AllTrim(TRBFP0->NOME_CLIENTE)               + '",'  
                  cProjs += '			"TIPO_ENVIO"               : "' + AllTrim(TRBFP0->TIPO_ENVIO)                 + '",'  
                  cProjs += '			"CODIGO_CONCORR"           : "' + AllTrim(TRBFP0->CODIGO_CONCORR)             + '",'  
                  cProjs += '			"VALOR_CONCORR"            : ' + cValToChar(TRBFP0->VALOR_CONCORR)            + ','   
                  cProjs += '			"PERIODO_MEDICAO"          : "' + AllTrim(TRBFP0->PERIODO_MEDICAO)            + '",'  
                  cProjs += '			"TIPO_FATURAMENTO"         : "' + AllTrim(TRBFP0->TIPO_FATURAMENTO)           + '",'  
                  cProjs += '			"COMPLEMENTO"              : "' + AllTrim(TRBFP0->COMPLEMENTO)                + '",'  
                  cProjs += '			"VALOR_PROJETO"            : ' + cValToChar(TRBFP0->VALOR_PROJETO)            + ','   
                  cProjs += '			"TIPO_FATURA"              : "' + AllTrim(TRBFP0->TIPO_FATURA)                + '",'  
                  cProjs += '			"MOEDA"                    : ' + cValToChar(TRBFP0->MOEDA)                    + ' ,'  
                  cProjs += '			"NIVEL"                    : "' + AllTrim(TRBFP0->NIVEL)                      + '" ,'  
                  cProjs += '			"APROVADOR"                : "' + AllTrim(TRBFP0->APROVADOR)                  + '",'  
                  cProjs += '			"OBSERVACAO"               : "' + LOCW0372(FP0->FP0_OBS)                         + '",'  
                  cProjs += '			"OBSERVACAO_DOCUMENTACAO"  : "' + AllTrim(FP0->FP0_OBSDOC)                       + '",'  
                  cProjs += '			"OBSERVACAO_PROPOSTA"      : "' + AllTrim(FP0->FP0_OBSPRO)                       + '",'  

                  cRetorno += cProjs

               EndIf

               // quebra por Obra
               If cBreakObra <> TRBFP0->FILREF + TRBFP0->PROPOSTA + TRBFP0->OBRA
                  cBreakObra := TRBFP0->FILREF + TRBFP0->PROPOSTA + TRBFP0->OBRA
                  //fecha linha caso tenha mais de uma
                  If !Empty(cObras)
                     cRetorno += '						}'
                     cRetorno += '					]'
                     cRetorno += '				},'
                     cObras   := ""
                  Else
                     cEquips := ""
                     cObras  += '			"LISTA_OBRAS": ['
                  EndIf
                  
                  cObras += '				{'
                  cObras += '					"OBRA"               : "' + AllTrim(TRBFP0->OBRA)                 + '",'
                  cObras += '					"CLIENTE_OBRA"       : "' + AllTrim(TRBFP0->CLIENTE_OBRA)         + '",'  
                  cObras += '					"LOJA_OBRA"          : "' + AllTrim(TRBFP0->LOJA_OBRA)            + '",'  
                  cObras += '					"NOME_OBRA"          : "' + AllTrim(TRBFP0->NOME_OBRA)            + '",'  
                  cObras += '					"RESPONSAVEL"        : "' + AllTrim(TRBFP0->RESPONSAVEL)          + '",'  
                  cObras += '					"EMAIL_RESPONSAVEL"  : "' + AllTrim(TRBFP0->EMAIL_RESPONSAVEL)    + '",'  

                  cRetorno += cObras

               EndIf

               // quebra por Item da FPA
               If cBreakEqui <> TRBFP0->FILREF + TRBFP0->PROPOSTA + TRBFP0->OBRA + TRBFP0->ITEM_FPA
                  cBreakEqui := TRBFP0->FILREF + TRBFP0->PROPOSTA + TRBFP0->OBRA + TRBFP0->ITEM_FPA
                  //fecha linha caso tenha mais de uma
                  If !Empty(cEquips)
                     cRetorno += '						},'
                     cEquips  := ""
                  Else
                     cEquips += '					"LISTA_ITENS": ['
                  EndIf
                  
                  cEquips += '						{'
                  cEquips += '							"ITEM_FPA"                       : "' + AllTrim(TRBFP0->ITEM_FPA)                      + '",'
                  cEquips += '							"PRODUTO"                        : "' + AllTrim(TRBFP0->PRODUTO)                       + '",'  
                  cEquips += '							"DESCRICAO_PRODUTO"              : "' + AllTrim(TRBFP0->DESCRICAO_PRODUTO)             + '",'  
                  cEquips += '							"EQUIPAMENTO"                    : "' + AllTrim(TRBFP0->EQUIPAMENTO)                   + '",'  
                  cEquips += '							"DESCRICAO_EQUIPAMENTO"          : "' + AllTrim(TRBFP0->DESCRICAO_EQUIPAMENTO)         + '",'  
                  cEquips += '							"QUANTIDADE"                     : ' + cValToChar(TRBFP0->QUANTIDADE)                  + ','   
                  cEquips += '							"VALOR_UNITARIO"                 : ' + cValToChar(TRBFP0->VALOR_UNITARIO)              + ','   
                  cEquips += '							"PERCENTUAL_DESCONTO"            : ' + cValToChar(TRBFP0->PERCENTUAL_DESCONTO)         + ','   
                  cEquips += '							"VALOR_DESCONTO"                 : ' + cValToChar(TRBFP0->VALOR_DESCONTO)              + ','   
                  cEquips += '							"VALOR_LIQUIDO"                  : ' + cValToChar(TRBFP0->VALOR_LIQUIDO)               + ','   
                  cEquips += '							"DATA_INICIO"                    : "' + DtoC(StoD(TRBFP0->DATA_INICIO))                + '",'  
                  cEquips += '							"HORA_INICIO"                    : "' + AllTrim(TRBFP0->HORA_INICIO)                   + '",'  
                  cEquips += '							"DATA_FIM"                       : "' + DtoC(StoD(TRBFP0->DATA_FIM))                   + '",'  
                  cEquips += '							"HORA_FIM"                       : "' + AllTrim(TRBFP0->HORA_FIM)                      + '",'  
                  cEquips += '							"DATA_FIM_LOCACAO"               : "' + DtoC(StoD(TRBFP0->DATA_FIM_LOCACAO))           + '",'  
                  cEquips += '							"DATA_GERA_FATURAMENTO"          : "' + DtoC(StoD(TRBFP0->DATA_GERA_FATURAMENTO))      + '",'  
                  cEquips += '							"CONDICAO_PAGAMENTO"             : "' + AllTrim(TRBFP0->CONDICAO_PAGAMENTO)            + '",'  
                  cEquips += '							"DESCRICAO_CONDICAO_PAGAMENTO"   : "' + AllTrim(TRBFP0->DESCRICAO_CONDICAO_PAGAMENTO)  + '",'  
                  cEquips += '							"CLIENTE_FATURAMENTO"            : "' + AllTrim(TRBFP0->CLIENTE_FATURAMENTO)           + '"'  

                  cRetorno += cEquips

               EndIf
                     
               TRBFP0->(dbSkip())
            EndDo
            
            TRBFP0->(dbSkip())

            //Fecha o ultimo
            cRetorno += '						}'
            cRetorno += '					]'

            cRetorno += '				}'
            cRetorno += '			]'

            cRetorno += '		}'      

            cRetorno += '	]'
            cRetorno += '}'

            //Altera a string $$ para colocar a quantidade
            cRetorno := StrTran(cRetorno,"$$",cValToChar(nTotalCou))
            
         Else
            cErro := "PROPOSTA NÃO LOCALIZADA"

            cRetorno += ' { '
            cRetorno += '    "RETORNO"   : { '
            cRetorno += '        "DESCRICAO" : "' + cErro + '" '
            cRetorno += '    } '
            cRetorno += ' } '
         EndIf
      EndIf
   EndIf       
Return cRetorno

/*/{Protheus.doc} LOCW0372
@description	Substitui CRLF por "\r\n" na Obsercação
@author			Dennis Calabrez
@since     		21/10/2025
/*/  
Static Function LOCW0372(cStringRef) 
Local cBkLine  := ""

   cBkLine := StrTran(cStringRef, CRLF,"\r\n")

Return cBkLine

/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parâmetros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 20/10/2025
/*/
Static Function GetUrlParams2(cUrl)
Local cQry    := ""
Local aParams := {}

    // Captura apenas a parte dos parâmetros após o '?'
   If At("?", cUrl) > 0
      cQry := AllTrim(SubStr(cUrl, At("?", cUrl) + 1))
   Else
      cQry := ""
   EndIf

    // Verifica se existem parâmetros
   If !Empty(cQry)
      // Quebra os parâmetros pelo '&'
      aParams := StrTokArr(cQry, "&")
   EndIf

Return (aParams)
