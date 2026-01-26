#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*/{Protheus.doc} UPD_EIC
    Função para atualização de tabelas do módulo SIGAEIC

    @type  Function
    @author bruno kubagawa
    @since 31/05/2023
    @version version
    @param cRelease, caractere, release do sistema
    @return nenhum
    @example
    (examples)
    @see (links_or_references)
/*/
function UPD_EIC( cRelease )
    local oUpd       := nil
    local cRelFinish := ""

    default cRelease := GetRPORelease()

    cRelFinish := SubSTR(cRelease,Rat(".",cRelease)+1)

    oUpd := AVUpdate01():New()
    oUpd:lSimula := .F.
    oUpd:aChamados := {}

    //if GetRemoteType() == 5
    //    aAdd(oUpd:aChamados, {EIC,{|o| AjustaSmartHtml(o)}} )
    //endif

    if avflags("FORM_LPCO")
        aAdd(oUpd:aChamados,  {nModulo,{|o| cargaSJJ(o)}} )
        oUpd:cTitulo := "Update para o modulo carga padrão da tabela SJJ."
    EndIf

    aAdd(oUpd:aChamados, {EIC,{|o| UPDEICSYO(o)},.F.})         
    aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC2210()},.F.}) //Alinhado com o Alessandro 05/10/2022 vai chamar a rotina sempre e lá na rotina tem um controle com count para ver se vai rodar oupdate ou nao       

    oUpd:Init(,.T.) 

return nil

Static Function cargaSJJ(o)
   Local aAuxSJJ := {}
   Local i

   aadd( aAuxSJJ , {'ANATEL'     ,'ANATEL - AGÊNCIA NACIONAL DE TELECOMUNICAÇÕES'                                      , "2" } )
   aadd( aAuxSJJ , {'ANCINE'     ,'ANCINE - AGENCIA NACIONAL DO CINEMA'                                                , "2" } )
   aadd( aAuxSJJ , {'ANEEL'      ,'ANEEL - AGENCIA NACIONAL DE ENERGIA ELETRICA'                                       , "2" } )
   aadd( aAuxSJJ , {'ANP'        ,'ANP - AGENCIA NACIONAL DO PETROLEO'                                                 , "2" } )
   aadd( aAuxSJJ , {'ANVISA'     ,'ANVISA - AGENCIA NACIONAL DE VIGILANCIA SANITARIA'                                  , "2" } )
   aadd( aAuxSJJ , {'BB'         ,'BB - BANCO DO BRASIL'                                                               , "2" } )
   aadd( aAuxSJJ , {'BEFIEX'     ,'PROGRAMAS BEFIEX'                                                                   , "2" } )
   aadd( aAuxSJJ , {'BNDES'      ,'BNDES - BANCO NACIONAL DE DESENVOLVIMENTO ECONÔMICO E SOCIAL'                       , "2" } )
   aadd( aAuxSJJ , {'CNEN'       ,'CNEN - COMISSAO NACIONAL DE ENERGIA NUCLEAR'                                        , "2" } )
   aadd( aAuxSJJ , {'CNPQ'       ,'CNPQ - CONSELHO NACIONAL DE DESENVOLVIMENTO CIENTIFICO E TECNOLOGICO'               , "2" } )
   aadd( aAuxSJJ , {'CONFAZ'     ,'CONFAZ - CONSELHO NACIONAL DE POLITICA FAZENDARIA/SECRETARIAS DE FAZENDA ESTADUAIS' , "2" } )
   aadd( aAuxSJJ , {'COTAC'      ,'MIN.AERON. - COMISSAO COORDENADORA DO TRANSPORTE AEREO CIVIL'                       , "2" } )
   aadd( aAuxSJJ , {'DEAEX'      ,'DEAEX - DEPARTAMENTO DE ESTATISTICA E APOIO A EXPORTACAO'                           , "2" } )
   aadd( aAuxSJJ , {'DECEX'      ,'DECEX - DEPARTAMENTO DE OPERACOES DE COMERCIO EXTERIOR'                             , "2" } )
   aadd( aAuxSJJ , {'DEPLA'      ,'DEPARTAMENTO DE PLANEJAMENTO E DESENVOLVIMENTO DO COMERCIO EXTERIOR'                , "2" } )
   aadd( aAuxSJJ , {'DFPC'       ,'DFPC - DIRETORIA DE FISCALIZACAO DE PRODUTOS CONTROLADOS-COMANDO DO EXERCITO'       , "2" } )
   aadd( aAuxSJJ , {'DNPM'       ,'DNPM - DEPARTAMENTO NACIONAL DE PRODUCAO MINERAL'                                   , "2" } )
   aadd( aAuxSJJ , {'DPF'        ,'DPF - DEPARTAMENTO DE POLICIA FEDERAL'                                              , "2" } )
   aadd( aAuxSJJ , {'ECT'        ,'ECT - EMPRESA BRASILEIRA DE CORREIOS E TELEGRAFOS'                                  , "2" } )
   aadd( aAuxSJJ , {'GESTOR'     ,'MICT/DECEX/GESTOR'                                                                  , "2" } )
   aadd( aAuxSJJ , {'IBAMA'      ,'IBAMA - INSTITUTO BRASILEIRO DO MEIO AMBIENTE E DOS RECURSOS NATURAIS RENOVAVEIS'   , "2" } )
   aadd( aAuxSJJ , {'INMETRO'    ,'INMETRO - INSTITUTO NACIONAL DE METROLOGIA'                                         , "2" } )
   aadd( aAuxSJJ , {'IPHAN'      ,'IPHAN - INSTITUTO DO PATRIMÔNIO HISTÓRICO E ARTÍSTICO NACIONAL'                     , "2" } )
   aadd( aAuxSJJ , {'MAPA'       ,'MAPA - MINISTERIO DA AGRICULTURA,PECUARIA E ABASTECIMENTO'                          , "2" } )
   aadd( aAuxSJJ , {'MCT'        ,'MCTI - MINISTERIO DA CIENCIA, TECNOLOGIA E INOVACAO'                                , "2" } )
   aadd( aAuxSJJ , {'MIN.DEFESA' ,'MD - MINISTERIO DA DEFESA'                                                          , "2" } )
   aadd( aAuxSJJ , {'MRE'        ,'MRE - MINISTÉRIO DAS RELAÇÕES EXTERIORES'                                           , "2" } )
   aadd( aAuxSJJ , {'RECEITA'    ,'RFB - RECEITA FEDERAL DO BRASIL'                                                    , "2" } )
   aadd( aAuxSJJ , {'SDAVO'      ,'AUDIOVISUAL'                                                                        , "2" } )
   aadd( aAuxSJJ , {'SECEX'      ,'SECEX - SECRETARIA DE COMERCIO EXTERIOR'                                            , "2" } )
   aadd( aAuxSJJ , {'SEPIN'      ,'MIN.DA CIENCIA E TECNOLOGIA-SEC.DE POLIT. INFORM.E AUTOMACAO'                       , "2" } )
   aadd( aAuxSJJ , {'SPC-MA'     ,'MA - SECRETARIA DE PRODUCAO E COMERCIALIZACAO'                                      , "2" } )
   aadd( aAuxSJJ , {'SUFRAMA'    ,'SUFRAMA - SUPERINTENDENCIA DA ZONA FRANCA DE MANAUS'                                , "2" } )

   SJJ->(dbgotop())
   while SJJ->(!EOF())
      if ascan( aAuxSJJ, {|x| alltrim(upper(x[1])) == alltrim(SJJ->JJ_CODIGO) } ) == 0
         o:TableStruct("SJJ",{"JJ_CODIGO" , "JJ_MSBLQL" },1)
         o:TableData( 'SJJ',{ SJJ->JJ_CODIGO,'1'})
      endif
      SJJ->(dbskip())
   enddo

   for i := 1 to len(aAuxSJJ)
      o:TableStruct("SJJ",{"JJ_CODIGO" ,"JJ_DESC" , "JJ_MSBLQL" },1)
      o:TableData( 'SJJ',{ aAuxSJJ[i][1], aAuxSJJ[i][2], aAuxSJJ[i][3] })
   next

Return

Static Function UPDEICSYO(o)

ChkFile("SYO")
SYO->(dbSetOrder(1)) //YO_FILIAL + YO_CAMPO
If SYO->(dbSeek(xFilial("SYO") + "WKIVFOBTOT")) .And. Alltrim(SYO->YO_ORIGEM) == 'BuscaTudo("SW9",BuscaInvoice()+SW7->W7_FORN,"W9_FOB_TOT")+SW9->W9_FRETEINT+SW9->W9_INLAND+SW9->W9_PACKIN+' //Campo Vlr Invoice do Gerador de Relatório
   o:TableStruct("SYO",{"YO_FILIAL"    ,"YO_CAMPO"    ,"YO_FASE"  ,"YO_ORIGEM"},1)
   o:TableData(  'SYO', {xFilial('SYO'), "WKIVFOBTOT" , "DI"      , 'BuscaTudo("SW9",BuscaInvoice()+SW7->W7_FORN,"W9_FOB_TOT")+SW9->W9_FRETEIN+SW9->W9_INLAND+SW9->W9_PACKING+SW9->W9_OUTDESP+SW9->W9_SEGURO-SW9->W9_DESCONT'})
EndIf

Return

/*
Funcao                     : UPDEIC033
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização do SX5 por empresa filial
Autor       			   :
Data/Hora   			   : 27/07/2021
*/
/* DESCONTINUADA Débitos Técnicos Release 12.25.10 (19/03/2025) - User Story 1535898: Substituição do RUP e RBE para o release 12.1.2510
Function UPDEIC033Fil(o)

    //Alterando a tabela C5 da SX5 com os novos valores relacionados a DI de acordo com nova PORTARIA ME Nº 4131/2021
    o:TableStruct('SX5'  ,{'X5_TABELA','X5_CHAVE','X5_DESCRI' ,'X5_DESCSPA','X5_DESCENG'})
    o:TableData  ("SX5"  ,{ 'C5'      , '00'     , '115.67'   , '115.67'   , '115.67'   })
    o:TableData  ("SX5"  ,{ 'C5'      , '02'     , '38.56'    , '38.56'    , '38.56'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '05'     , '30.85'    , '30.85'    , '30.85'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '10'     , '23.14'    , '23.14'    , '23.14'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '20'     , '15.42'    , '15.42'    , '15.42'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '50'     , '7.71'     , '7.71'     , '7.71'     })
    o:TableData  ("SX5"  ,{ 'C5'      , '99'     , '3.86'     , '3.86'     , '3.86'     })

Return
*/
/*
Funcao            : UPDEIC033W
Parametros        : Objeto de update PAI
Objetivos         : Ajustar no dicionario para DUIMP
Revisao           : -
Autor             : Nilson César
Obs.              : O Ajuste foi digitado no ATUSX em Outubro/2021
*/
Function UPDEIC033W(o)

    //Alterar Ordem do campo na tela
    /* Ajustado no pacote de Débitos Técnicos Release 12.25.10 (19/03/2025) - 015277 - User Story 1535898: Substituição do RUP e RBE para o release 12.1.2510
    o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_ORDEM'},2)
    o:TableData  ("SX3"  ,{'W6_TIPOREG','9Y'      })

    o:TableStruct("SXB", {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"                               ,"XB_WCONTEM"})
    o:DelTableData("SXB",{"EKL"     ,"5"      ,"02"    ,""         ,""         ,""          ,""          ,'If(LEFT(EKL->EKL_CODFOR,1)=="I","1","2")',""          })
    */
Return

/*
Funcao                     : UPDEIC033
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   :
Data/Hora   			   : 14/09/2017
*/
Function UPDEIC033(o)

    //Alteração de Título
    /*Ajustado no pacote de Débitos Técnicos Release 12.25.10 (19/03/2025) - 015277 - User Story 1535898: Substituição do RUP e RBE para o release 12.1.2510
    o:TableStruct("SX3",{"X3_CAMPO" , "X3_TITULO"},2)
    o:TableData(  "SX3",{"EK9_MSBLQL", "Bloqueado?"})
    o:TableData(  "SX3",{"EK9_MODALI", "Modalidade"})
    o:TableData(  "SX3",{"EK9_ULTALT", "Alterado Por"})
    o:TableData(  "SX3",{"EKB_OPERFB", "TIN"})
    o:TableData(  "SX3",{"EKD_MODALI", "Modalidade"})

    //mudança de campos de um folder para outro - EK9
    o:TableStruct("SX3",{"X3_CAMPO"     ,"X3_FOLDER" },2)
    o:TableData  ("SX3",{"EK9_DSCNCM"   ,"3"         })
    o:TableData  ("SX3",{"EK9_UNIEST"   ,"3"         })
    o:TableData  ("SX3",{"EK9_MSBLQL"   ,"3"         })
    o:TableData  ("SX3",{"EK9_DSCCOM"   ,"3"         })
    o:TableData  ("SX3",{"EK9_OBSINT"   ,"3"         })
    o:TableData  ("SX3",{"EK9_ULTALT"   ,"3"         })
    o:TableData  ("SX3",{"EK9_RETINT"   ,"2"         })
    
    //Mudança de campos de um folder para outro - EKD
    //Diversos campos da EK9 não estão presentes na EKD
    o:TableData  ("SX3",{"EKD_UNIEST"   ,"3"         })
    o:TableData  ("SX3",{"EKD_OBSINT"   ,"3"         })
    o:TableData  ("SX3",{"EKD_RETINT"   ,"2"         })

    //Ordenação de campos
    o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_ORDEM'},2)
    o:TableData  ("SX3"  ,{'EKB_PAIS'  ,'05'        })
    o:TableData  ("SX3"  ,{'EKB_PAISDS','06'      })
    o:TableData  ("SX3"  ,{'EKB_OESTAT','07'      })
    o:TableData  ("SX3"  ,{'EKB_OPERFB','08'      })
    o:TableData  ("SX3"  ,{'EKB_OENOME','09'      })
    o:TableData  ("SX3"  ,{'EKB_OEEND' ,'10'       })
    o:TableData  ("SX3"  ,{'EKF_PAIS'  ,'05'       })
    o:TableData  ("SX3"  ,{'EKF_PAISDS','06'      })

    //alterar campo para Visual
    o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_VISUAL'},2)
    o:TableData  ("SX3"  ,{'EK9_IDPORT','V'      })
    o:TableData  ("SX3"  ,{'EK9_VATUAL','V'      })
*/
Return


/*
Funcao                     : UPDEIC2210
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualizar o campo YS_SI_NUM com o valor do campo  YS_HAWB para processos do tipo "S"(S.I.)
Autor       			   :
Data/Hora   			   : 14/09/2017
*/
Function UPDEIC2210()
Local cQuery := ''
Local cAliasTemp
Local oQryYs
Local lIndexSys := FWSIXUtil():ExistIndex( "SYS" , "3" )
local lExistCpo := .F.

if lIndexSys
    cAliasTemp := GetNextAlias()
    cQuery += 'SELECT COUNT(*) CONTADOR FROM ' + RetSqlName("SYS") +'  WHERE YS_SI_NUM> ? AND YS_TIPO= ? AND YS_TPMODU= ? AND D_E_L_E_T_= ?'
    oQryYs := FWPreparedStatement():New(cQuery)
    oQryYs:SetString(1,' ')
    oQryYs:SetString(2,'S')
    oQryYs:SetString(3,'I')
    oQryYs:SetString(4,' ')
    cQuery := oQryYs:GetFixQuery()
    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasTemp, .T., .T. )
    If  (cAliasTemp)->CONTADOR == 0 // é pq não executou o update ainda
        cQuery := "UPDATE " + RetSqlName("SYS") + " SET YS_SI_NUM=YS_HAWB WHERE YS_TIPO='S' AND YS_TPMODU='I' AND YS_SI_NUM=' ' AND  D_E_L_E_T_= ' ' "
        TCSQLEXEC(cQuery)
    EndIf
    (cAliasTemp)->(DbCloseArea())
EndIf    

lExistCpo := !empty(FWSX2Util():GetFile("EKD")) .and. EKD->(ColumnPos("EKD_VATUAL")) > 0
if lExistCpo

    // EKD_STATUS - "1=Registrado;2=Pendente Registro;3=Obsoleto;4=Falha de integração;5=Registrado(pendente: fabricante/ país);6=Registrado Manualmente"
    cQuery := " SELECT COUNT(*) CONTADOR FROM " + RetSqlName("EKD") + " WHERE EKD_VATUAL = ' ' AND EKD_VERSAO <> ' ' AND EKD_IDPORT <> ' ' AND ( EKD_STATUS = '1' OR EKD_STATUS = '5' OR EKD_STATUS = '6') AND D_E_L_E_T_= ' ' "
    cAliasTemp := GetNextAlias()
    MPSysOpenQuery(cQuery, cAliasTemp)

    if (cAliasTemp)->CONTADOR > 0
        cQuery := " UPDATE " + RetSqlName("EKD") + " SET EKD_VATUAL = EKD_VERSAO WHERE EKD_VATUAL = ' ' AND EKD_VERSAO <> ' ' AND EKD_IDPORT <> ' ' AND ( EKD_STATUS = '1' OR EKD_STATUS = '5' OR EKD_STATUS = '6') AND D_E_L_E_T_= ' '  "
        TCSQLEXEC(cQuery)
    endif
    (cAliasTemp)->(DbCloseArea())

endif

return
