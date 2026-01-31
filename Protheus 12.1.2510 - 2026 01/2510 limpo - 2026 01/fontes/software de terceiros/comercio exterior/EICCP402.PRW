#include 'protheus.ch'
#include 'average.ch'
#include 'eiccp402.ch'
#INCLUDE "FWMVCDEF.CH"

#define REGISTRADO                   "1"
#define PENDENTE_REGISTRO            "2"
#define PENDENTE_RETIFICACAO         "3"
#define BLOQUEADO                    "4"
#define REGISTRADO_MANUALMENTE       "5"
#define REGISTRADO_PENDENTE_FAB_PAIS "6"

#Define ATT_COMPOSTO       "COMPOSTO"
#Define ATT_LISTA_ESTATICA "LISTA_ESTATICA"
#Define ATT_TEXTO          "TEXTO"
#Define ATT_BOOLEANO       "BOOLEANO"

#define INICIO  "0" // "AZUL"
#define ERRO    "1" // "VERMELHO"
#define OK      "2" // "VERDE"
#define WARNING "3" // "AMARELO"

#define CP402_TABLE "CP402_EK9"
#define MARCA       "X"

#define ETAPA_ATRIBUTOS  "1" // 1 - Validação de atributos
#define ETAPA_OPERADORES "2" // 2 - Processamento dos operadores estrangeiros
#define ETAPA_CATALOGO   "3" // 3 - Integração do catálogo de produtos
#define ETAPA_VINCULACAO "4" // 4 - Vinculação dos operadores estrangeiros com o catálogo de produtos 
#define ETAPA_FIM        "5" // 5 - Fim do processamento 

static IsPE_CP402 := EasyEntryPoint("EICCP402")

/*/{Protheus.doc} EICCP402
   Realiza a integração em massa do Catálogo de Produtos com o Pontal Único
   
   @type  Function
   @author user
   @since 24/01/2025
   @version version
   @return nil
   @example
   (examples)
   @see (links_or_references)
   /*/
function EICCP402()
   local lIsBlind := isBlind()
   local aAreaEK9 := {}

   dbSelectArea("EK9")
   aAreaEK9 := EK9->(getArea())

   if !lIsBlind
      WizardCat()
   endif

   restArea(aAreaEK9)

return nil

/*/{Protheus.doc} WizardCat
   Criação da tela do Wizard para a integração do Catálogo de Produtos com o Portal Único

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param nil
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function WizardCat()
   local oEasyTmp   := nil
   local nCount     := 0
   local cAmbPortal := ""
   local cUrlPortal := ""
   local aCoords    := {}
   local oStepWiz   := nil
   local cStep      := ""
   local oStep1     := nil
   local oStep2     := nil
   local oStep3     := nil
   local oMrkBrw    := nil
   local oBrwProc   := nil
   local nRecAlias  := 0

   oEasyTmp := EasyTemporaryTable():new()
   setTable(@oEasyTmp)

   if vldCatProd(@oEasyTmp, @nCount, @nRecAlias)

      cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") // 1 - Produção, 2 - Treinamento
      cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))
      aCoords := FWGetDialogSize()
      oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
      oStepWiz:ActiveUISteps()

      cStep := "1"

      if nCount > 1
         oStep1 := oStepWiz:AddStep(cStep)
         oStep1:SetStepDescription(STR0001) // "Introdução"
         oStep1:SetConstruction({ |oPanel| ViewIntrod( oPanel, cAmbPortal, cUrlPortal ) } )
         oStep1:SetNextTitle(STR0002) // "Avançar"
         oStep1:SetNextAction( { || validStep("1") })
         oStep1:SetCancelAction( { || MsgYesNo(STR0003, STR0004) }) // "Deseja cancelar a integração do Catálogo de Produto?" ### "Catálogo de Produto"        

         cStep := "2"
         oStep2 := oStepWiz:AddStep(cStep)
         oStep2:SetStepDescription(STR0005) // "Catálogos de produtos"
         oStep2:SetConstruction({ |oPanel| ViewCatPrd(oPanel, cAmbPortal, cUrlPortal, @oMrkBrw, nRecAlias), if( oMrkBrw <> nil, oMrkBrw:oBrowse:Refresh(.F.), nil) })
         oStep2:SetPrevTitle(STR0006) // "Voltar"
         oStep2:SetNextTitle(STR0007) // "Integrar"
         oStep2:SetNextAction( { || validStep("2") })
         oStep2:SetCancelAction( { || MsgYesNo(STR0003, STR0004) }) // "Deseja cancelar a integração do Catálogo de Produto?" ### "Catálogo de Produto"      

         cStep := "3"
      EndIf

      oStep3 := oStepWiz:AddStep(cStep) 
      oStep3:SetStepDescription(STR0008) // "Processamento"
      oStep3:SetConstruction({|oPanel| ViewProc(oPanel, cAmbPortal, cUrlPortal, nCount, @oBrwProc), if( oBrwProc <> nil, oBrwProc:oBrowse:Refresh(.T.), nil) })
      oStep3:SetNextTitle(STR0009) // "Fechar"
      oStep3:SetPrevTitle(STR0010) // "Exportar"
      oStep3:SetNextAction({|| validStep("3") }) //Qunado a integração é com um único registro o wizard fica com um único step,
                                                 //desta forma na tela fica o botão Avançar e Cancelar, onde ambos fecham a tela sem processamento
                                                 //o componente ignora os comandos SetNextTile, SetPrevTitle e o SetPRevAction
                                                 //neste cenário somente o SetNextAction tem efeito
      oStep3:SetPrevAction({|| geraExcel(cAmbPortal, cUrlPortal) })
      oStep3:SetCancelWhen({|| .F. })

      oStepWiz:Activate()
      oStepWiz:Destroy()

      FwFreeObj( oStepWiz )

   endif

   eraseTable(oEasyTmp)

return nil

/*/{Protheus.doc} ViewIntrod
   Função para introdução do Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oPanel, objeto, objeto que será apresentado a introdução
          cAmbPortal, caracter, ambiente do portal único
          cUrlPortal, caracter, url do portal único
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewIntrod(oPanel, cAmbPortal, cUrlPortal)
   local aCoords    := {}
   local cIntrod    := "" 
   local oSay       := nil
   local oFont      := nil

   default cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") 
   default cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))

   aCoords := FWGetDialogSize(oPanel)
   cIntrod := STR0011 + ENTER + ENTER + ; // "Esta rotina tem como objetivo possibilitar a Integração em Lote dos Catálogos de Produtos e seus Operadores Estrangeiros vinculados junto ao Portal Único."
              STR0012 + ENTER + ENTER + ; // "Serão listados os Catálogos de Produtos passíveis de integração, ou seja, com os status 'Pendente de Registro', 'Pendente de Retificação' e 'Registrado (pendente: fabricante/ país)'."
              STR0013 + ENTER + ENTER + ; // "Após realizar a marcação dos registros que deseja transmitir na integração e, dando a sequência no processamento, o sistema listará os detalhes da operação junto ao Portal Único."
              STR0014 + " " + if( cAmbPortal == "1", STR0015, STR0016 ) + " - " + cUrlPortal + ", " + STR0017 // "Para iniciar o processo de integração no ambiente de" ### "Produção" ### "Treinamento" ### "clique em 'Avançar'."

   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return nil

/*/{Protheus.doc} ViewCatPrd
   Função para apresentação dos catalogos de produtos para o Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oPanel, objeto, objeto que será apresentado a introdução
          cAmbPortal, caracter, ambiente do portal único
          cUrlPortal, caracter, url do portal único
          oMarkBrow, objeto, objeto que será o browse de marcação dos catalogos de produtos
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewCatPrd(oPanel, cAmbPortal, cUrlPortal, oMarkBrow, nRecAlias)
   local lRet       := .T.
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local cAliasTmp  := CP402_TABLE
   local cMarca     := MARCA
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}
   Local aFieldFilter := {}
   Local aSeek      := {}
   local bMarcar    := { || Marcar(), oMarkBrow:oBrowse:Refresh() }
   local oLayer     := nil
   local cLib       := ""
   local cTexto     := ""
   local oPnlBrowse := nil
   local aCoresNum  := {PENDENTE_REGISTRO, PENDENTE_RETIFICACAO, REGISTRADO_PENDENTE_FAB_PAIS}
   local aCores     := {}
   local nL         := 0
   local cPicture   := ""

   default cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") 
   default cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))

   if oMarkBrow == nil
      aRotina := {} 

      aStruct := (cAliasTmp)->(dbStruct())
      for nCpo := 1 To Len(aStruct)
         if !(aStruct[nCpo][1] $ ("REG_MARCA||RECEK9||STATUS||RETORNO||LOGPROC||EK9_STATUS||EKD_VERSAO||ETAPA" ))
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            cPicture := GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE")
            aColumns[Len(aColumns)]:SetPicture( cPicture )
            aadd(aFieldFilter, {aStruct[nCpo][1], RetTitle(aStruct[nCpo][1]), aStruct[nCpo][2], aStruct[nCpo][3], aStruct[nCpo][4], cPicture})
         endif
      next nCpo 

      oLayer := FWLayer():New()
      GetRemoteType(@cLib)
      cTexto := STR0018 + " " + if( cAmbPortal == "1", STR0015, STR0016) + " - " + cUrlPortal // "Marque os catálogos de produtos que desejam realizar a integração com o Portal Único no ambiente de" ### "Produção" ### "Treinamento"
      if 'HTML' $ cLib
         cTexto := STR0018 + " " + "<b>" + if( cAmbPortal == "1", STR0015, STR0016) + " - " + cUrlPortal + "</b>" // "Marque os catálogos de produtos que desejam realizar a integração com o Portal Único no ambiente de" ### "Produção" ### "Treinamento"
      endif
      ViewTitulo(oLayer, 10, 90, oPanel, cTexto, @oPnlBrowse)

      // Defino os detalhes da busca do browse
      aAdd(aSeek,{getSX3Cache( "EK9_COD_I" , "X3_TITULO"), {{"",getSX3Cache( "EK9_COD_I", "X3_TIPO") ,getSX3Cache( "EK9_COD_I", "X3_TAMANHO") ,0,"EK9_COD_I", getSX3Cache( "EK9_COD_I", "X3_PICTURE")}} , 1, .T.})
      aAdd(aSeek,{getSX3Cache( "EK9_NCM"   , "X3_TITULO") + getSX3Cache( "EK9_IDPORT"   , "X3_TITULO") + getSX3Cache( "EK9_VATUAL"   , "X3_TITULO") , {;
                                                            {"",getSX3Cache( "EK9_NCM", "X3_TIPO")    ,getSX3Cache( "EK9_NCM", "X3_TAMANHO")    ,0,"EK9_NCM"   , getSX3Cache( "EK9_NCM", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_IDPORT", "X3_TIPO") ,getSX3Cache( "EK9_IDPORT", "X3_TAMANHO") ,0,"EK9_IDPORT", getSX3Cache( "EK9_IDPORT", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_VATUAL", "X3_TIPO") ,getSX3Cache( "EK9_VATUAL", "X3_TAMANHO") ,0,"EK9_VATUAL", getSX3Cache( "EK9_VATUAL", "X3_PICTURE")}}   , 2, .T.})
      aAdd(aSeek,{getSX3Cache( "EK9_PRDREF", "X3_TITULO"), {{"",getSX3Cache( "EK9_PRDREF", "X3_TIPO"),getSX3Cache( "EK9_PRDREF", "X3_TAMANHO"),0,"EK9_PRDREF",getSX3Cache( "EK9_PRDREF", "X3_PICTURE")}}, 3, .T.})
      aAdd(aSeek,{getSX3Cache( "EK9_STATUS", "X3_TITULO"), {{"",getSX3Cache( "EK9_STATUS", "X3_TIPO"),getSX3Cache( "EK9_STATUS", "X3_TAMANHO"),0,"EK9_STATUS",getSX3Cache( "EK9_STATUS", "X3_PICTURE")}}, 5, .T.})      

      fwFreeObj(oMarkBrow)
      oMarkBrow := FWMarkBrowse():New()      
      oMarkBrow:SetOwner( oPnlBrowse )
      oMarkBrow:SetDataTable(.T.)
      oMarkBrow:SetAlias( cAliasTmp )
      oMarkBrow:SetAllMark( bMarcar )
      oMarkBrow:SetMark( cMarca, cAliasTmp, "REG_MARCA" )
      aCores := CP400Cores(aCoresNum)
      For nL := 1 To Len( aCores )   	    
            oMarkBrow:AddLegend( aCores[nL][1], aCores[nL][2], aCores[nL][3] )
      Next nL
      oMarkBrow:SetFieldMark( "REG_MARCA" )
      oMarkBrow:SetColumns( aColumns )
      oMarkBrow:SetMenuDef("")
      oMarkBrow:SetTemporary(.T.)
      oMarkBrow:SetWalkThru(.F.)
      oMarkBrow:DisableReport()
      oMarkBrow:DisableDetails()
      oMarkBrow:DisableConfig()        
      oMarkBrow:oBrowse:SetDBFFilter(.T.)
      oMarkBrow:oBrowse:SetUseFilter() //Habilita a utilização do filtro no Browse
      oMarkBrow:oBrowse:SetFieldFilter(aFieldFilter)
      oMarkBrow:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
      oMarkBrow:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
      oMarkBrow:AddButton( OemTOAnsi(STR0019), { || Marcar("M"), oMarkBrow:oBrowse:Refresh() },, 2 ) // "Marcar todos"
      oMarkBrow:AddButton( OemTOAnsi(STR0020), { || Marcar("D"), oMarkBrow:oBrowse:Refresh() },, 2 ) // "Desmarcar todos"
      oMarkBrow:Activate()
      if nRecAlias > 0
         oMarkBrow:GoTo(nRecAlias,.t.) //posiciona e o parâmetro .t. já faz o refresh
      Endif   
      oMarkBrow:oBrowse:SetFocus()
   endif

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

return lRet

/*/{Protheus.doc} ViewProc
   Função para apresentação do processamento dos catalogos de produtos para o Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oPanel, objeto, objeto que será apresentado a introdução
          cAmbPortal, caracter, ambiente do portal único
          cUrlPortal, caracter, url do portal único
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewProc(oPanel, cAmbPortal, cUrlPortal, nCount, oBrowProc)
   local lRet       := .T.
   local oProc      := nil
   local cMsgError  := ""
   local cMsgSoluc  := ""

   default cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") 
   default cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))
   default nCount     := 0

   BrowseProc(oPanel, cAmbPortal, cUrlPortal, @oBrowProc)
   oProc := MsNewProcess():New({|lEnd| lRet := PrcIntCt(@lEnd, @oBrowProc, @oProc, (cAmbPortal == "1"), nCount, @cMsgError, @cMsgSoluc),oBrowProc:Refresh()}, STR0040 + "...",,.T.) // "Integrando o catálogo de produto"
   oProc:Activate() 

   if !lRet
      if !empty(cMsgError)
         easyHelp(cMsgError, STR0032, cMsgSoluc) // "Atenção"
      endif
   endif

return lRet

/*/{Protheus.doc} BrowseProc
   Função para apresentação do browse de processamento dos catalogos de produtos para o Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oPanel, objeto, objeto que será apresentado a introdução
          cAmbPortal, caracter, ambiente do portal único
          cUrlPortal, caracter, url do portal único
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function BrowseProc(oPanel, cAmbPortal, cUrlPortal, oBrowProc)
   local lRet       := .T.
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local cAliasTmp  := CP402_TABLE
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}
   Local aFieldFilter := {}
   Local aSeek      := {}
   local oLayer     := nil
   local cLib       := ""
   local cTexto     := ""
   local oPnlBrowse := nil
   local cPicture   := ""

   default cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") 
   default cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))

   if oBrowProc == nil
      aRotina := {} 

      aStruct := (cAliasTmp)->(dbStruct())
      for nCpo := 1 To Len(aStruct)
         if aStruct[nCpo][1] == "RETORNO"
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( STR0022 ) // "Retorno do processamento"
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDoubleClick({|| EECView((cAliasTmp)->LOGPROC, STR0023,,,,,.T.) }) // "Mensagem"
         elseif !(aStruct[nCpo][1] $ "REG_MARCA||RECEK9||STATUS||EK9_STATUS||LOGPROC||EKD_VERSAO||ETAPA" )
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            cPicture := GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE")
            aColumns[Len(aColumns)]:SetPicture( cPicture )
            aadd(aFieldFilter, {aStruct[nCpo][1], RetTitle(aStruct[nCpo][1]), aStruct[nCpo][2], aStruct[nCpo][3], aStruct[nCpo][4], cPicture})
         endif

      next nCpo 

      oLayer := FWLayer():New()
      GetRemoteType(@cLib)
      cTexto := STR0024 + " " + if( cAmbPortal == "1", STR0015, STR0016) + " - " + cUrlPortal // "Integração dos Catálogos de Produtos e seus Operadores Estrangeiros com o Portal Único no ambiente de" ### "Produção" ### "Treinamento"
      if 'HTML' $ cLib
         cTexto := STR0024 + " " + "<b>" + if( cAmbPortal == "1", STR0015, STR0016) + " - " + cUrlPortal + "</b>" // "Integração dos Catálogos de Produtos e seus Operadores Estrangeiros com o Portal Único no ambiente de" ### "Produção" ### "Treinamento"
      endif
      ViewTitulo(oLayer, 10, 90, oPanel, cTexto, @oPnlBrowse)

      // Defino os detalhes da busca do browse
      aAdd(aSeek,{getSX3Cache( "EK9_COD_I" , "X3_TITULO"), {{"",getSX3Cache( "EK9_COD_I", "X3_TIPO") ,getSX3Cache( "EK9_COD_I", "X3_TAMANHO") ,0,"EK9_COD_I", getSX3Cache( "EK9_COD_I", "X3_PICTURE")}} , 1, .T.})
      aAdd(aSeek,{getSX3Cache( "EK9_NCM"   , "X3_TITULO") + getSX3Cache( "EK9_IDPORT"   , "X3_TITULO") + getSX3Cache( "EK9_VATUAL"   , "X3_TITULO") , {;
                                                            {"",getSX3Cache( "EK9_NCM", "X3_TIPO")    ,getSX3Cache( "EK9_NCM", "X3_TAMANHO")    ,0,"EK9_NCM"   , getSX3Cache( "EK9_NCM", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_IDPORT", "X3_TIPO") ,getSX3Cache( "EK9_IDPORT", "X3_TAMANHO") ,0,"EK9_IDPORT", getSX3Cache( "EK9_IDPORT", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_VATUAL", "X3_TIPO") ,getSX3Cache( "EK9_VATUAL", "X3_TAMANHO") ,0,"EK9_VATUAL", getSX3Cache( "EK9_VATUAL", "X3_PICTURE")}}   , 2, .T.})
      aAdd(aSeek,{getSX3Cache( "EK9_PRDREF", "X3_TITULO"), {{"",getSX3Cache( "EK9_PRDREF", "X3_TIPO"),getSX3Cache( "EK9_PRDREF", "X3_TAMANHO"),0,"EK9_PRDREF",getSX3Cache( "EK9_PRDREF", "X3_PICTURE")}}, 3, .T.})
      aAdd(aSeek,{STR0025                               , {{"","C"                                  ,1                                       ,0,"STATUS"    ,                                        }}, 4, .T.}) // "Status"

      fwFreeObj(oBrowProc)
      oBrowProc := FWMarkBrowse():New()
      oBrowProc:SetOwner( oPnlBrowse )
      oBrowProc:SetDataTable(.T.)
      oBrowProc:SetAlias( cAliasTmp )
      oBrowProc:SetMenuDef("")
      oBrowProc:SetTemporary(.T.)
      oBrowProc:SetWalkThru(.F.)
      oBrowProc:DisableReport()
      oBrowProc:DisableDetails()
      oBrowProc:DisableConfig()
      oBrowProc:AddLegend("STATUS == '" + INICIO  + "' ","BR_AZUL"     , STR0026 ) // "Integração em andamento"
      oBrowProc:AddLegend("STATUS == '" + ERRO    + "' ","BR_VERMELHO" , STR0027 ) // "Mensagem impeditiva"
      oBrowProc:AddLegend("STATUS == '" + OK      + "' ","BR_VERDE"    , STR0028 ) // "Catálogo integrado com sucesso"
      oBrowProc:AddLegend("STATUS == '" + WARNING + "' ","BR_AMARELO"  , STR0029 ) // "Mensagem de aviso"
      oBrowProc:SetColumns( aColumns )
      oBrowProc:oBrowse:SetDBFFilter(.T.)
      oBrowProc:oBrowse:SetUseFilter() //Habilita a utilização do filtro no Browse
      oBrowProc:oBrowse:SetFieldFilter(aFieldFilter)
      oBrowProc:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
      oBrowProc:oBrowse:SetFilterDefault(" REG_MARCA <> ' ' ") //Indica o filtro padrão do Browse
      oBrowProc:Activate()

      oBrowProc:oBrowse:Refresh(.T.)
      oBrowProc:oBrowse:SetFocus()

   endif

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

return lRet

/*/{Protheus.doc} ViewTitulo
   Função para apresentação do titulo das telas do Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oLayer, objeto, objeto da classe FWLayer
          nPorcTit, numérico, porcentagem do titulo
          nPercTela, numérico, porcentagem da tela
          oPanel, objeto, objeto que será apresentado a etapa do Wizard
          cTitulo, caracter, mensagem do titulo e subtitulo
          oPanel2, objeto, objeto que será a tela do Wizard
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewTitulo(oLayer, nPorcTit, nPercTela, oPanel, cTitulo, oPanel2)
   local oPanel1      := nil

   default oLayer     := FWLayer():New()
   default nPorcTit   := 10
   default nPercTela  := 90
   default cTitulo    := ""

   oLayer:Init(oPanel,.F.)

   oLayer:AddLine("L1",nPorcTit,.F.)
   oLayer:AddLine("L2",nPercTela,.F.)
   oPanel1 := oLayer:getLinePanel("L1")
   oPanel2 := oLayer:getLinePanel("L2")

   oSayTitulo := TSay():New(5,5,{||cTitulo},oPanel1,,TFont():New("Arial",,18,,.F.,,,,,.F.,.F.),,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10)

return nil

/*/{Protheus.doc} Marcar
   Função para marca ou desmarcar os catalogos para integração

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param cOpcao, caracter, D para desmarcar, M para marcar e H para header do Browser
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function Marcar(cOpcao)
   local cAliasTmp  := CP402_TABLE
   local cMarca     := MARCA
   local nRecno     := 0

   default cOpcao     := "H"

   if cOpcao == "H"
      cOpcao := if( empty((cAliasTmp)->REG_MARCA), "M", "D" )
   endif

   nRecno := (cAliasTmp)->(recno())
   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())
      Reclock(cAliasTmp, .F.)
      (cAliasTmp)->REG_MARCA := if( cOpcao == "M", cMarca, " ")
      (cAliasTmp)->(msUnLock())
      (cAliasTmp)->(dbskip())
   end
   (cAliasTmp)->(dbGoTo(nRecno))

return nil

/*/{Protheus.doc} vldCatProd
   Função para validação dos catalogos de produtos para serem integrados

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oEasyTmp, objeto, objeto da classe EasyTemporaryTable
          nCount, numérico, quantidade de registros para integração
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function vldCatProd(oEasyTmp, nCount, nRecAlias)
   local lRet       := .F.
   local cMsgError  := ""
   local cMsgSol    := ""
   local cAliasTmp  := CP402_TABLE
   local nRecEK9    := EK9->(recno())

   default nCount     := 0

   begin sequence

      if !loadCatPrd(@oEasyTmp, nRecEK9, @nCount, @nRecAlias)
         cMsgError := STR0030 // "Não existe catálogos de produtos para serem integrados."
         cMsgSol := STR0031 // "Verifique se existem catálogos de produtos com os status 'Pendente de Registro', 'Pendente de Retificação' e 'Registrado (pendente: fabricante/ país)'"
         break
      endif

      lRet := .T.

   end sequence

   if !empty(cMsgError)
      easyHelp(cMsgError, STR0032, cMsgSol) // "Atenção"
      lRet := .F.
   endif

   if nCount == 1 .and. lRet
      lRet := MsgYesNo(StrTran(STR0096,'#####', (cAliasTmp)->EK9_COD_I), STR0004) // "Deseja realizar a integração do Catálogo: ######  " ### "Catálogo de Produto"
   EndIf   

return lRet

/*/{Protheus.doc} validStep
   Função para validação dos steps do Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param cStep, caractere, código do step
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function validStep(cStep, oBrowse)
   local lRet       := .T.
   local cAliasTmp  := CP402_TABLE
   local nRecno     := 0

   default cStep      := ""

   do case
      case cStep == "1" // Introdução

      case cStep == "2" // Grid de catalogos

         nRecno := (cAliasTmp)->(recno())
         (cAliasTmp)->(dbGoTop())
         do while (cAliasTmp)->(!eof())
            lRet := !empty((cAliasTmp)->REG_MARCA)
            if lRet
               exit
            endif
            (cAliasTmp)->(dbskip())
         end
         (cAliasTmp)->(dbGoTo(nRecno))

         if !lRet
            easyHelp(STR0033, STR0032, STR0034) // "Não foram marcados os registros para processamento." ### "Atenção" ### "Marque os registros que deseja realizar a integração."
         endif

         lRet := lRet .and. MsgYesNo(STR0035, STR0004) // "Deseja realizar a integração dos registros marcados?" ### "Catálogo de Produto"

      case cStep == "3" // Grid de processamento

   end case

return lRet

/*/{Protheus.doc} setTable
   Função para configurar a tabela temporaria para o Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oEasyTmp, objeto, objeto da classe EasyTemporaryTable
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function setTable(oEasyTmp)
   local aSemSX3    := {}
   local cAliasTmp  := CP402_TABLE
   local nCpos      := 0

   default oEasyTmp := EasyTemporaryTable():new()

   private aCposTemp := {} // Variavel utilizada no ponto de entrada - ADICIONAR_CAMPOS

   aSemSX3 := {}
   aAdd(aSemSX3, {"STATUS"     , "C"                                  , 01                                      , 0                                        })
   aAdd(aSemSX3, {"REG_MARCA"  , "C"                                  , 01                                      , 0                                        })
   aAdd(aSemSX3, {"EK9_COD_I"  , getSX3Cache( "EK9_COD_I", "X3_TIPO") , getSX3Cache( "EK9_COD_I", "X3_TAMANHO") , getSX3Cache( "EK9_COD_I", "X3_DECIMAL")  })
   aAdd(aSemSX3, {"EK9_IDPORT" , getSX3Cache( "EK9_IDPORT", "X3_TIPO"), getSX3Cache( "EK9_IDPORT", "X3_TAMANHO"), getSX3Cache( "EK9_IDPORT", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_VATUAL" , getSX3Cache( "EK9_VATUAL", "X3_TIPO"), getSX3Cache( "EK9_VATUAL", "X3_TAMANHO"), getSX3Cache( "EK9_VATUAL", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_CNPJ"   , getSX3Cache( "EK9_CNPJ", "X3_TIPO")  , getSX3Cache( "EK9_CNPJ", "X3_TAMANHO")  , getSX3Cache( "EK9_CNPJ", "X3_DECIMAL")   })
   aAdd(aSemSX3, {"EK9_NCM"    , getSX3Cache( "EK9_NCM", "X3_TIPO")   , getSX3Cache( "EK9_NCM", "X3_TAMANHO")   , getSX3Cache( "EK9_NCM", "X3_DECIMAL")    })
   aAdd(aSemSX3, {"EK9_PRDREF" , getSX3Cache( "EK9_PRDREF", "X3_TIPO"), getSX3Cache( "EK9_PRDREF", "X3_TAMANHO"), getSX3Cache( "EK9_PRDREF", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_DESC_I" , getSX3Cache( "EK9_DESC_I", "X3_TIPO"), getSX3Cache( "EK9_DESC_I", "X3_TAMANHO"), getSX3Cache( "EK9_DESC_I", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_STATUS" , getSX3Cache( "EK9_STATUS", "X3_TIPO"), getSX3Cache( "EK9_STATUS", "X3_TAMANHO"), getSX3Cache( "EK9_STATUS", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EKD_VERSAO" , getSX3Cache( "EKD_VERSAO", "X3_TIPO"), getSX3Cache( "EKD_VERSAO", "X3_TAMANHO"), getSX3Cache( "EKD_VERSAO", "X3_DECIMAL") })
   aAdd(aSemSX3, {"RETORNO"    , "M"                                  , 250                                     , 0                                        })
   aAdd(aSemSX3, {"LOGPROC"    , "M"                                  , 250                                     , 0                                        })
   aAdd(aSemSX3, {"RECEK9"     , "N"                                  , 10                                      , 0                                        })
   aAdd(aSemSX3, {"ETAPA"      , "C"                                  , 01                                      , 0                                        })

   aIndex := {}
   aAdd(aIndex, "EK9_COD_I" )
   aAdd(aIndex, "EK9_NCM+EK9_IDPORT+EK9_VATUAL" )
   aAdd(aIndex, "EK9_PRDREF" )
   aAdd(aIndex, "STATUS" )
   aAdd(aIndex, "EK9_STATUS" )

   if IsPE_CP402
      // aCposTemp - Adicionar campos para carga na tabela temporaria
      ExecBlock("EICCP402", .F., .F., "ADICIONAR_CAMPOS")
      for nCpos := 1 to len(aCposTemp)
         aAdd(aSemSX3, aCposTemp[nCpos])
      next nCpos
   endif

   oEasyTmp:setData(nil, aSemSX3, cAliasTmp, aIndex)

return

/*/{Protheus.doc} eraseTable
   Função destruir o objeto da classe EasyTemporaryTable

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oEasyTmp, objeto, objeto da classe EasyTemporaryTable
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function eraseTable(oEasyTmp)
   if oEasyTmp <> nil
      oEasyTmp:destroy()
      FwFreeObj(oEasyTmp)
   endif
return nil

/*/{Protheus.doc} loadCatPrd
   Função para carregar os catalogos de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oEasyTmp, objeto, objeto da classe EasyTemporaryTable
          nRecEK9, numérico, recno da tabela EK9 posicionado
          nCount, numérico, contador de registros
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function loadCatPrd(oEasyTmp, nRecEK9, nCount, nRecAlias)
   local lRet       := .F.
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""
   local cAliasTmp  := CP402_TABLE
   local cMarca     := MARCA
   local cInformix  := if(TcGetDB()=="INFORMIX", " AS ","")
   local cEK9       := RetSqlName("EK9") + cInformix 
   local cEKD       := RetSqlName("EKD") + cInformix

   default oEasyTmp   := EasyTemporaryTable():new()
   default nCount     := 0

   private cCposSelec := "" // Variavel utilizada no ponto de entrada - QUERY_CAMPOS
   private cWhere     := "" // Variavel utilizada no ponto de entrada - QUERY_WHERE
   private cTmpAlias  := "" // Variavel utilizada no ponto de entrada - CARREGAR_CAMPOS
   private cTmpQuery  := "" // Variavel utilizada no ponto de entrada - CARREGAR_CAMPOS

   oEasyTmp:ClearTmp(cAliasTmp)

   cQuery := " SELECT "
   cQuery +=      " EK9_STATUS,"
   cQuery +=      " EK9_FILIAL, "
   cQuery +=      " EK9_COD_I, "
   cQuery +=      " EK9_IDPORT, "
   cQuery +=      " EK9_VATUAL, "
   cQuery +=      " EK9_CNPJ, "
   cQuery +=      " EK9_NCM, "
   cQuery +=      " EK9_PRDREF, "
   cQuery +=      " EK9_DESC_I, "
   cQuery +=      " EK9.R_E_C_N_O_ " + cInformix + " RECEK9, "
   cQuery +=      " EKD_VERSAO "

   if IsPE_CP402
      ExecBlock("EICCP402", .F., .F., "QUERY_CAMPOS")
      if !empty(cCposSelec)
         cQuery += "," + cCposSelec
      endif
   endif

   cQuery += " FROM " + cEK9 + " EK9 "
   cQuery += " INNER JOIN ( "
   cQuery +=      " SELECT EKD_FILIAL, EKD_COD_I, MAX(EKD_VERSAO) EKD_VERSAO "
   cQuery +=      " FROM " + cEKD + " EKD "
   cQuery +=      " WHERE EKD.EKD_FILIAL = ? " 
   cQuery +=      " AND EKD.D_E_L_E_T_ = ? "
   cQuery +=      " GROUP BY EKD_FILIAL, EKD_COD_I "
   cQuery +=      ") LAST_VERSION ON LAST_VERSION.EKD_COD_I = EK9.EK9_COD_I "
   cQuery += " WHERE EK9.EK9_FILIAL = ? "
   cQuery +=      " AND EK9.EK9_STATUS IN(?) "
   cQuery +=      " AND EK9.EK9_MODALI = ? "
   cQuery +=      " AND EK9.EK9_MSBLQL <> ? "
   cQuery +=      " AND EK9.D_E_L_E_T_ = ? "

   if IsPE_CP402
      ExecBlock("EICCP402", .F., .F., "QUERY_WHERE")
      if !empty(cWhere)
         cQuery += " AND " + cWhere + " "
      endif
   endif

   cQuery += " ORDER BY EK9_COD_I "

   oQuery := FWPreparedStatement():New(cQuery)

   oQuery:SetString(1, xFilial("EKD") ) // EKD_FILIAL
   oQuery:SetString(2, " " ) // EKD.D_E_L_E_T_
   oQuery:SetString(3, xFilial("EK9") ) // EK9_FILIAL
   oQuery:SetIn(4, {PENDENTE_REGISTRO, PENDENTE_RETIFICACAO, REGISTRADO_PENDENTE_FAB_PAIS} ) // EK9_STATUS
   oQuery:SetString(5, '1' ) // EK9_MODALI
   oQuery:SetString(6, '1' ) // EK9.EK9_MSBLQL
   oQuery:SetString(7, ' ' ) // EK9.D_E_L_E_T_

   cQuery := oQuery:GetFixQuery()
   FwFreeObj(oQuery)

   cAliasQry := GetNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   if IsPE_CP402
      cTmpAlias  := cAliasTmp // Variavel utilizada no ponto de entrada - CARREGAR_CAMPOS
      cTmpQuery  := cAliasQry // Variavel utilizada no ponto de entrada - CARREGAR_CAMPOS
   endif

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())
      lRet := .T.
      nCount += 1

      reclock(cAliasTmp, .T.)
      if IsPE_CP402
         ExecBlock("EICCP402", .F., .F., "CARREGAR_CAMPOS")
      endif

      (cAliasTmp)->EK9_COD_I := (cAliasQry)->EK9_COD_I
      (cAliasTmp)->EK9_IDPORT := (cAliasQry)->EK9_IDPORT
      (cAliasTmp)->EK9_VATUAL := (cAliasQry)->EK9_VATUAL
      (cAliasTmp)->EK9_CNPJ := (cAliasQry)->EK9_CNPJ
      (cAliasTmp)->EK9_NCM := (cAliasQry)->EK9_NCM
      (cAliasTmp)->EK9_PRDREF := (cAliasQry)->EK9_PRDREF
      (cAliasTmp)->EK9_DESC_I := (cAliasQry)->EK9_DESC_I
      (cAliasTmp)->EK9_STATUS := (cAliasQry)->EK9_STATUS
      (cAliasTmp)->RECEK9 := (cAliasQry)->RECEK9
      (cAliasTmp)->EKD_VERSAO := (cAliasQry)->EKD_VERSAO
      (cAliasTmp)->REG_MARCA := " "

      if nRecEK9 == (cAliasTmp)->RECEK9
         (cAliasTmp)->REG_MARCA := cMarca
         nRecAlias := (cAliasTmp)->(recno())
      endif
      (cAliasTmp)->STATUS := INICIO
      (cAliasTmp)->RETORNO := ""
      (cAliasTmp)->LOGPROC := ""
      (cAliasTmp)->ETAPA := ETAPA_ATRIBUTOS // Validação de atributos
      (cAliasTmp)->(msUnLock())

      (cAliasQry)->(dbSkip())
   end 

   if nCount == 1
      (cAliasTmp)->REG_MARCA := cMarca
      (cAliasTmp)->(dbSetOrder(1))
   endif

   (cAliasQry)->(dbCloseArea())
    
return lRet

/*/{Protheus.doc} geraExcel
   Função para geração do resultado do processamento em Excel

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param cAmbPortal, caracter, ambiente do portal único
          cUrlPortal, caracter, url do portal único
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
static function geraExcel(cAmbPortal, cUrlPortal)
   local oExcel     := nil
   local cWorksheet := ""
   local cTable     := ""
   local cAliasTmp  := CP402_TABLE
   local aStruct    := {}
   local nCpo       := 0
   local cStatus    := ""
   local aRow       := {}
   local cArquivo   := ""

   default cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") 
   default cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))

   cWorksheet := STR0036 // "Resultado da integração"
   cTable := STR0037 + " " + if( cAmbPortal == "1", STR0015, STR0016) + " - " + cUrlPortal // "Processamento da integração do catálogo de produtos em lote no ambiente de" ### "Produção" ### "Treinamento"

   oExcel := FwMsExcelXlsx():New()
   oExcel:AddworkSheet(cWorksheet)
   oExcel:AddTable(cWorksheet, cTable)

   aStruct := (cAliasTmp)->(dbStruct())
   for nCpo := 1 to Len(aStruct)
      if aStruct[nCpo][1] == "STATUS"
         oExcel:AddColumn(cWorksheet, cTable, STR0025 ) // "Status"
      elseif aStruct[nCpo][1] == "LOGPROC"
         oExcel:AddColumn(cWorksheet, cTable, STR0038 ) // "Retorno do processamento"
      elseif !(aStruct[nCpo][1] $ "REG_MARCA||RECEK9||RETORNO||EKD_VERSAO||ETAPA")
         oExcel:AddColumn(cWorksheet, cTable, RetTitle(aStruct[nCpo][1]))
      endif
   next nCpo

   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())

      aRow := {}
      for nCpo := 1 to Len(aStruct)
         if aStruct[nCpo][1] == "STATUS"
            cStatus := STR0026 // "Integração em andamento"
            do case
               case (cAliasTmp)->&(aStruct[nCpo][1]) == ERRO
                  cStatus := STR0027 // "Mensagem impeditiva"
               case (cAliasTmp)->&(aStruct[nCpo][1]) == OK
                  cStatus := STR0028 // "Catálogo integrado com sucesso"
               case (cAliasTmp)->&(aStruct[nCpo][1]) == WARNING
                  cStatus := STR0029 // "Mensagem de aviso"
            endcase
            aAdd( aRow, cStatus )
         elseif aStruct[nCpo][1] == "LOGPROC"
            aAdd( aRow, (cAliasTmp)->&(aStruct[nCpo][1]) )
         elseif !(aStruct[nCpo][1] $ "REG_MARCA||RECEK9||RETORNO||EKD_VERSAO||ETAPA")
            aAdd( aRow, (cAliasTmp)->&(aStruct[nCpo][1]) )
         endif
      next nCpo

      oExcel:Addrow(cWorksheet, cTable, aClone(aRow))
      (cAliasTmp)->(dbSkip())
   end

   oExcel:Activate()
   cArquivo := CriaTrab(Nil, .F.) + ".xlsx"
   oExcel:GetXMLFile(cArquivo)
   oExcel:DeActivate()
   FwFreeObj(oExcel)

   MsAguarde( {|| comex.generics.TEOpenExcel(cArquivo)}, STR0039 + "...") // "Gerando o arquivo excel"

// Retorna falso para não realizar mudanças na página
return .F.


/*/{Protheus.doc} PrcIntCt
   Função para realizar a integração do catálogo de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
static function PrcIntCt(lEnd, oBrowProc, oProc, lIntProd, nCount, cMsgError, cMsgSoluc)
   local lRet       := .F.
   local cURLPortal := ""
   local cURLAuth   := ""
   local lCancelou  := .F.
   local oEasyJS    := nil
   local lUnico     := .F.
   local aExecAutOE := {}
   local cAliasTmp  := ""
   local nRecnoTmp  := 0
   local lAutentica := .T.

   default lIntProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   default nCount     := 0
   default cMsgError  := ""
   default cMsgSoluc  := ""

   cURLPortal := AVGetUrl(,, @lCancelou, "EIC")
   cURLAuth   := avGetAuth()

   if !lCancelou

      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cURLAuth
      
      oEasyJS:setTimeOut(120)
      oEasyJS:AddLib( EasyAppFetch(cURLAuth) )
      oEasyJS:AddLib( OE400Script() )
      oEasyJS:AddLib( CP402Script() )
      
      lRet := oEasyJS:Activate(.T.)
      cMsgError := STR0102 // "Não foi possível carregar os dados para realizar a integração"
      cMsgSoluc := STR0103 // "Por favor, acesse novamente o sistema e tente realizar a integração."

      // Caso ativou o EasyJS com sucesso
      if lRet

         cMsgError := ""
         cMsgSoluc := ""
         oProc:SetRegua1(7) // Regua para processamento geral, representa a quantidade de IncRegua1

         // Caso só tenha um registro, não é necessário buscar a quantidade de registros marcados
         lUnico := nCount == 1

         oProc:IncRegua1(STR0104 + "...") // "Validando atributos obrigatórios"
         VldAtrCat(@lEnd, oBrowProc, oProc, lUnico, @lAutentica)
         oProc:IncRegua2("")

         oProc:IncRegua1(STR0105 + "...") // "Incluindo operadores estrangeiros"
         aExecAutOE := ExecAutoOE(oProc)
         oProc:IncRegua2("")

         if lAutentica
            oProc:IncRegua1(STR0044 + "...") // "Autenticando no Portal Único"
            if lRet 
               oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplError);", {|x| lRet := comex.generics.EasyRetAut(x, @cMsgError, @cMsgSoluc) }, { |x| lRet := comex.generics.EasyRetAut(x, @cMsgError, @cMsgSoluc) } ) //Executando um javascript de forma Síncrona
            endif
            oProc:IncRegua2("")
         endif

         // Caso a autenticação ocorreu com sucesso
         if lRet .and. lAutentica

            oProc:IncRegua1(STR0106 + "...") // "Processando operadores estrangeiros"
            ProcOpEst(@lEnd, oEasyJS, oProc, oBrowProc, lIntProd, cURLPortal, lUnico, aExecAutOE)
            oProc:IncRegua2("")

            oProc:IncRegua1(STR0107 + "...") // "Processando catálogos de produtos"
            ProcCatPrd(@lEnd, oEasyJS, oProc, oBrowProc, lIntProd, cURLPortal, lUnico)
            oProc:IncRegua2("")

            oProc:IncRegua1(STR0108 + "...") // "Processando vinculações dos operadores estrangeiros"
            ProcVincOE(@lEnd, oEasyJS, oProc, oBrowProc, lIntProd, cURLPortal, lUnico)
            oProc:IncRegua2("")

            oProc:IncRegua1(STR0109) // "Processamento finalizado"
            
         endif

      endif

      oEasyJS:Destroy()

   endif

   if !lRet
      cAliasTmp := CP402_TABLE
      nRecnoTmp := (cAliasTmp)->(recno())
      (cAliasTmp)->(dbGoTop())
      (cAliasTmp)->(dbEval({||,;
            (cAliasTmp)->RETORNO := STR0098,; // "Processamento cancelado."
            (cAliasTmp)->LOGPROC := STR0098,; // "Processamento cancelado."
            (cAliasTmp)->STATUS := WARNING,;
         }))
      (cAliasTmp)->(dbGoTo(nRecnoTmp))
   endif

return lRet

/*/{Protheus.doc} VldAtrCat
   Função para realizar a validação dos atributos dos catálogos de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function VldAtrCat(lEnd, oBrowProc, oProc, lUnico, lAutentica)
   local cAliasTmp  := CP402_TABLE
   local nRecno     := 0
   local cMsgVldAtr := ""
   local lValidaOk  := .F.
   local nPrcCount  := 1
   local nQtdError  := 0

   if !lUnico
      // Recebe a quantidade de registros marcados para integração para realizar a validação dos atributos obrigatórios
      nPrcCount := getQtdPrc(ETAPA_ATRIBUTOS)
   endif
   oProc:SetRegua2(nPrcCount) // Regua para cada registro processado

   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())

      // Processa o registro apenas se estiver marcado para integração e na etapa de validação dos atributos obrigatórios
      if !((cAliasTmp)->STATUS == ERRO) .and. !empty((cAliasTmp)->REG_MARCA) .and. (cAliasTmp)->ETAPA == ETAPA_ATRIBUTOS
         nRecno := (cAliasTmp)->(recno())
         oProc:IncRegua2(STR0005 + ": " + (cAliasTmp)->EK9_COD_I) // "Catálogo de produtos"

         cMsgVldAtr := ""
         lValidaOk := CP400AtrValid( (cAliasTmp)->EK9_COD_I, (cAliasTmp)->EK9_VATUAL, @cMsgVldAtr )

         Reclock(cAliasTmp,.F.)
         if lValidaOk
            (cAliasTmp)->RETORNO := '- ' + STR0041 + "." // "Atributos validados com sucesso"
            (cAliasTmp)->ETAPA   := ETAPA_OPERADORES // Processamento dos operadores estrangeiros
         else
            (cAliasTmp)->RETORNO := STR0110 + ":" + ENTER + ' - ' + cMsgVldAtr //"Ocorreram as seguintes validações dos atributos obrigatórios"
            (cAliasTmp)->STATUS  := ERRO
            (cAliasTmp)->ETAPA   := ETAPA_FIM // Fim do processamento
            nQtdError += 1
         endif
         (cAliasTmp)->LOGPROC := (cAliasTmp)->LOGPROC + (cAliasTmp)->RETORNO + ENTER + ENTER 
         (cAliasTmp)->(msUnLock())

         oBrowProc:Refresh()
         (cAliasTmp)->(dbGoTo(nRecno))
      endif

      (cAliasTmp)->(dbSkip())
   end 

   // caso todos os registros ocorreu erro de atributos, não precisa autenticar no portal único
   if nPrcCount == nQtdError
      lAutentica := .F.
   endif

return nil

/*/{Protheus.doc} ExecAutoOE
   Função para realizar a inclusão dos fabricantes SA2 que estão vinculados ao catalogo mas não são operadores estrangeiros no sistema

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function ExecAutoOE(oProc)
   local aRetProc   := {}
   local cInformix  := ""
   local lExcEKJ    := .F.
   local cEKB       := ""
   local cEKJ       := ""
   local cQuery     := ""
   local oQuery     := nil
   local nQuery     := 0
   local cAliasTmp  := CP402_TABLE
   local cMarca     := MARCA
   local cAliasQry  := ""
   local cFilEKJ    := ""
   local aOEExec    := {}
   local aInfOper   := {}
   local cCnpjRaiz  := ""
   local cCodFab    := ""
   local cLojFab    := ""

   cInformix := if( TcGetDB()=="INFORMIX", " AS ","")
   lExcEKJ := CP400OpExc()

   cEKB := RetSqlName('EKB') + cInformix
   cEKJ := RetSqlName('EKJ') + cInformix

   cQuery := " SELECT WORK_EK9.EK9_CNPJ, EKB.EKB_FILORI, EKB.EKB_CODFAB, EKB.EKB_LOJA, EKJ.EKJ_FORN "
   cQuery += " FROM " + TETempName(cAliasTmp) + cInformix + " WORK_EK9 "
   cQuery +=   " INNER JOIN " + cEKB + " EKB ON "
   cQuery +=      " EKB.EKB_FILIAL = ? "
   cQuery +=      " AND EKB.EKB_COD_I = WORK_EK9.EK9_COD_I "
   cQuery +=      " AND EKB.EKB_CODFAB <> ? "
   cQuery +=      " AND EKB.D_E_L_E_T_ = ? "
   cQuery +=   " LEFT JOIN " + cEKJ + " EKJ ON "
   cQuery +=      if( lExcEKJ, " EKJ.EKJ_FILIAL = EKB.EKB_FILORI ", " EKJ.EKJ_FILIAL = ? ")
   cQuery +=      " AND EKJ.EKJ_CNPJ_R = WORK_EK9.EK9_CNPJ "
   cQuery +=      " AND EKJ.EKJ_FORN = EKB.EKB_CODFAB "
   cQuery +=      " AND EKJ.EKJ_FOLOJA = EKB.EKB_LOJA "
   cQuery +=      " AND EKJ.D_E_L_E_T_ = ? "
   cQuery += " WHERE "
   cQuery +=   " WORK_EK9.REG_MARCA = ? "
   cQuery +=   " AND WORK_EK9.ETAPA = ? "
   cQuery +=   " AND EKJ.EKJ_FORN IS NULL "
   cQuery +=   " AND WORK_EK9.D_E_L_E_T_ = ? "
   cQuery += " GROUP BY WORK_EK9.EK9_CNPJ, EKB.EKB_FILORI, EKB.EKB_CODFAB, EKB.EKB_LOJA, EKJ.EKJ_FORN "

   oQuery := FWPreparedStatement():New(cQuery)

   nQuery := 1
   oQuery:setString(nQuery, xFilial("EKB")) // EKB.EKB_FILIAL
   nQuery += 1
   oQuery:setString(nQuery,' ') // EKB_CODFAB
   nQuery += 1
   oQuery:setString(nQuery,' ') // EKB.D_E_L_E_T_
   if !lExcEKJ
      nQuery += 1
      oQuery:setString(nQuery, xFilial('EKJ')) // EKJ.EKJ_FILIAL
   endif
   nQuery += 1
   oQuery:setString(nQuery, ' ') // EKJ.D_E_L_E_T_
   nQuery += 1
   oQuery:setString(nQuery, cMarca) // WORK_EK9.REG_MARCA
   nQuery += 1
   oQuery:setString(nQuery, ETAPA_OPERADORES) // WORK_EK9.ETAPA
   nQuery += 1
   oQuery:setString(nQuery, ' ') // WORK_EK9.D_E_L_E_T_

   cQuery := oQuery:GetFixQuery()
   cAliasQry := GetNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)
   fwFreeObj(oQuery)

   (cAliasQry)->(dbGoTop())
   aOEExec := {}
   while (cAliasQry)->(!eof())

      cFilEKJ := if( lExcEKJ, (cAliasQry)->EKB_FILORI, xFilial("EKJ"))
      cCnpjRaiz := (cAliasQry)->EK9_CNPJ
      cCodFab := (cAliasQry)->EKB_CODFAB
      cLojFab := (cAliasQry)->EKB_LOJA

      aInfOper := {}
      aAdd( aInfOper, { "EKJ_FILIAL"  , cFilEKJ   , Nil })
      aAdd( aInfOper, { "EKJ_CNPJ_R"  , cCnpjRaiz , Nil })
      aAdd( aInfOper, { "EKJ_FORN"    , cCodFab   , Nil })
      aAdd( aInfOper, { "EKJ_FOLOJA"  , cLojFab   , Nil })
      aAdd( aOEExec, aClone(aInfOper) )

      (cAliasQry)->(dbskip())
   end
   (cAliasQry)->(dbCloseArea())

   if len(aOEExec) > 0
      oProc:SetRegua2(len(aOEExec))
      aRetProc := {}
      CP400ExecEKJ(aOEExec, , .T., oProc, @aRetProc)
   endif

// aRetProc -> { EKJ_FILIAL, EKJ_CNPJ_R, EKJ_FORN, EKJ_FOLOJA, MENSAGEM DE VALIDAÇÃO }
return aRetProc

/*/{Protheus.doc} ProcOpEst
   Função para realizar o processamento dos operadores estrangeiros

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function ProcOpEst(lEnd, oEasyJS, oProc, oBrowProc, lIntProd, cURLPortal, lUnico, aExecAutOE)
   local aExecIntOE := {}

   default aExecAutOE := {}

   // Realiza a integração dos operadores estrangeiros vinculados aos catálogos de produtos
   aExecIntOE := ExecIntOE(oProc, oEasyJS, lIntProd, cURLPortal)

   // Processa o retorno dos operadores estrangeiros
   ProcRetOE(oProc, oBrowProc, lUnico, aExecAutOE, aExecIntOE)

return nil

/*/{Protheus.doc} ExecIntOE
   Função para realizar a integração dos operadores estrangeiros vinculados aos catálogos de produtos para o Portal Único

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function ExecIntOE(oProc, oEasyJS, lIntProd, cURLPortal)
   local aExecIntOE := {}
   local cInformix  := ""
   local lExcEKJ    := .F.
   local cEKB       := ""
   local cEKJ       := ""
   local cQuery     := ""
   local oQuery     := nil
   local nQuery     := 0
   local cAliasTmp  := CP402_TABLE
   local cMarca     := MARCA
   local cAliasQry  := ""
   local aOEExec    := {}

   cInformix := if( TcGetDB()=="INFORMIX", " AS ","")
   lExcEKJ := CP400OpExc()

   cEKB := RetSqlName('EKB') + cInformix
   cEKJ := RetSqlName('EKJ') + cInformix

   cQuery := " SELECT WORK_EK9.EK9_CNPJ, EKB.EKB_FILORI, EKB.EKB_CODFAB, EKB.EKB_LOJA, EKJ.R_E_C_N_O_ " + cInformix + " RECEKJ "
   cQuery += " FROM " + TETempName(cAliasTmp) + cInformix + " WORK_EK9 "
   cQuery +=   " INNER JOIN " + cEKB + " EKB ON "
   cQuery +=      " EKB.EKB_FILIAL = ? "
   cQuery +=      " AND EKB.EKB_COD_I = WORK_EK9.EK9_COD_I "
   cQuery +=      " AND EKB.EKB_CODFAB <> ? "
   cQuery +=      " AND EKB.D_E_L_E_T_ = ? "
   cQuery +=   " INNER JOIN " + cEKJ + " EKJ ON "
   cQuery +=      if( lExcEKJ, " EKJ.EKJ_FILIAL = EKB.EKB_FILORI ", " EKJ.EKJ_FILIAL = ? ")
   cQuery +=      " AND EKJ.EKJ_CNPJ_R = WORK_EK9.EK9_CNPJ "
   cQuery +=      " AND EKJ.EKJ_FORN = EKB.EKB_CODFAB "
   cQuery +=      " AND EKJ.EKJ_FOLOJA = EKB.EKB_LOJA "
   cQuery +=      " AND EKJ.EKJ_STATUS <> ? "
   cQuery +=      " AND EKJ.EKJ_STATUS <> ? "
   cQuery +=      " AND EKJ.D_E_L_E_T_ = ? "
   cQuery += " WHERE "
   cQuery +=   " WORK_EK9.REG_MARCA = ? "
   cQuery +=   " AND WORK_EK9.ETAPA = ? "
   cQuery +=   " AND WORK_EK9.D_E_L_E_T_ = ? "
   cQuery += " GROUP BY WORK_EK9.EK9_CNPJ, EKB.EKB_FILORI, EKB.EKB_CODFAB, EKB.EKB_LOJA, EKJ.R_E_C_N_O_ "

   oQuery := FWPreparedStatement():New(cQuery)

   nQuery := 1
   oQuery:setString(nQuery, xFilial("EKB")) // EKB.EKB_FILIAL
   nQuery += 1
   oQuery:setString(nQuery,' ') // EKB_CODFAB
   nQuery += 1
   oQuery:setString(nQuery,' ') // EKB.D_E_L_E_T_
   if !lExcEKJ
      nQuery += 1
      oQuery:setString(nQuery, xFilial('EKJ')) // EKJ.EKJ_FILIAL
   endif
   nQuery += 1
   oQuery:setString(nQuery, '1') // EKJ.EKJ_STATUS // "Registrado"
   nQuery += 1
   oQuery:setString(nQuery, '5') // EKJ.EKJ_STATUS // "Desativados"
   nQuery += 1
   oQuery:setString(nQuery, ' ') // EKJ.D_E_L_E_T_
   nQuery += 1
   oQuery:setString(nQuery, cMarca) // WORK_EK9.REG_MARCA
   nQuery += 1
   oQuery:setString(nQuery, ETAPA_OPERADORES) // WORK_EK9.ETAPA
   nQuery += 1
   oQuery:setString(nQuery, ' ') // WORK_EK9.D_E_L_E_T_

   cQuery := oQuery:GetFixQuery()
   cAliasQry := GetNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)
   fwFreeObj(oQuery)

   (cAliasQry)->(dbGoTop())
   aOEExec := {}
   while (cAliasQry)->(!eof())
      aAdd( aOEExec, (cAliasQry)->RECEKJ )
      (cAliasQry)->(dbskip())
   end
   (cAliasQry)->(dbCloseArea())

   if len(aOEExec) > 0
      aExecIntOE := {}
      OE400Integrar(aOEExec, @aExecIntOE, oProc, oEasyJS, cURLPortal, lIntProd, .F.)
   endif

// aExecIntOE -> { RECNO da EKJ, LOGICO .T. ou .F., MENSAGEM DA VALIDAÇÃO }
return aExecIntOE

/*/{Protheus.doc} ProcRetOE
   Função para atualizar o arquivo temporário do processamento de inclusão e integração do operadores estrangeiros

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function ProcRetOE(oProc, oBrowProc, lUnico, aExecAutOE, aExecIntOE)
   local aAreaTMP   := {}
   local nPrcCount  := 1
   local cInformix  := ""
   local lExcEKJ    := .F.
   local lProcOE    := .F.
   local cEKB       := ""
   local cEKJ       := ""
   local cQuery     := ""
   local oQuery     := nil
   local nQuery     := 0
   local cAliasTmp  := CP402_TABLE
   local cMarca     := MARCA
   local cAliasQry  := ""
   local cCodCat    := ""
   local cMsgProcOE := ""
   local cFilEKJ    := ""
   local cMsgPrcIni := ""
   local lMsgIntOE  := .F.

   default aExecAutOE := {}
   default aExecIntOE := {}

   aAreaTMP := (cAliasTmp)->(getArea())

   if !lUnico
      // Recebe a quantidade de registros marcados para integração para realizar o processamento dos operadores estrangeiros
      nPrcCount := getQtdPrc(ETAPA_OPERADORES)
   endif
   oProc:SetRegua2(nPrcCount) // Regua para cada registro processado

   cInformix := if( TcGetDB()=="INFORMIX", " AS ","")
   lExcEKJ := CP400OpExc()

   cEKB := RetSqlName('EKB') + cInformix
   cEKJ := RetSqlName('EKJ') + cInformix

   // Indica que foi realizado algum inclusão do operador estrangeiro ou integração do operador estrangeiro
   // Caso contrario somente necessidade de passar para proxima etapa
   lProcOE := len(aExecAutOE) > 0 .or. len(aExecIntOE) > 0

   cQuery := " SELECT WORK_EK9.EK9_COD_I, WORK_EK9.EK9_CNPJ "
   if lProcOE
      cQuery += ",  EKB.EKB_FILORI, EKB.EKB_CODFAB, EKB.EKB_LOJA, EKJ.R_E_C_N_O_ " + cInformix + " RECEKJ " "
   endif
   cQuery += " FROM " + TETempName(cAliasTmp) + cInformix + " WORK_EK9 "
   if lProcOE
      cQuery +=   " INNER JOIN " + cEKB + " EKB ON "
      cQuery +=      " EKB.EKB_FILIAL = ? "
      cQuery +=      " AND EKB.EKB_COD_I = WORK_EK9.EK9_COD_I "
      cQuery +=      " AND EKB.EKB_CODFAB <> ? "
      cQuery +=      " AND EKB.D_E_L_E_T_ = ? "
      cQuery +=   " LEFT JOIN " + cEKJ + " EKJ ON "
      cQuery +=      if( lExcEKJ, " EKJ.EKJ_FILIAL = EKB.EKB_FILORI ", " EKJ.EKJ_FILIAL = ? ")
      cQuery +=      " AND EKJ.EKJ_CNPJ_R = WORK_EK9.EK9_CNPJ "
      cQuery +=      " AND EKJ.EKJ_FORN = EKB.EKB_CODFAB "
      cQuery +=      " AND EKJ.EKJ_FOLOJA = EKB.EKB_LOJA "
      cQuery +=      " AND EKJ.D_E_L_E_T_ = ? "
   endif
   cQuery += " WHERE "
   cQuery +=   " WORK_EK9.REG_MARCA = ? "
   cQuery +=   " AND WORK_EK9.ETAPA = ? "
   cQuery +=   " AND WORK_EK9.D_E_L_E_T_ = ? "
   if lProcOE
      cQuery += " GROUP BY WORK_EK9.EK9_COD_I, WORK_EK9.EK9_CNPJ, EKB.EKB_FILORI, EKB.EKB_CODFAB, EKB.EKB_LOJA, EKJ.R_E_C_N_O_ "
   endif
   cQuery += " ORDER BY WORK_EK9.EK9_COD_I
   oQuery := FWPreparedStatement():New(cQuery)

   if lProcOE
      nQuery += 1
      oQuery:setString(nQuery, xFilial("EKB")) // EKB.EKB_FILIAL
      nQuery += 1
      oQuery:setString(nQuery,' ') // EKB_CODFAB
      nQuery += 1
      oQuery:setString(nQuery,' ') // EKB.D_E_L_E_T_
      if !lExcEKJ
         nQuery += 1
         oQuery:setString(nQuery, xFilial('EKJ')) // EKJ.EKJ_FILIAL
      endif
      nQuery += 1
      oQuery:setString(nQuery, ' ') // EKJ.D_E_L_E_T_
   endif

   nQuery += 1
   oQuery:setString(nQuery, cMarca) // WORK_EK9.REG_MARCA
   nQuery += 1
   oQuery:setString(nQuery, ETAPA_OPERADORES) // WORK_EK9.ETAPA
   nQuery += 1
   oQuery:setString(nQuery, ' ') // WORK_EK9.D_E_L_E_T_

   cQuery := oQuery:GetFixQuery()
   cAliasQry := GetNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)
   fwFreeObj(oQuery)

   (cAliasQry)->(dbGoTop())
   (cAliasTmp)->(dbSetOrder(1)) // EK9_COD_I
   while (cAliasQry)->(!eof())

      oProc:IncRegua2(STR0005 + ": " + (cAliasQry)->EK9_COD_I) // "Catálogo de produtos"
      cCodCat := (cAliasQry)->EK9_COD_I
      if lProcOE
         cMsgProcOE := ""
         lMsgIntOE := .F.
         while (cAliasQry)->(!eof()) .and. (cAliasQry)->EK9_COD_I == cCodCat
            // aExecAutOE -> { EKJ_FILIAL, EKJ_CNPJ_R, EKJ_FORN, EKJ_FOLOJA, MENSAGEM DE VALIDAÇÃO }
            nPosExcAut := aScan(aExecAutOE, { |X| X[1] == if( lExcEKJ, (cAliasQry)->EKB_FILORI, xFilial("EKJ")) .and. ;
                                                  X[2] == (cAliasQry)->EK9_CNPJ .and. ;
                                                  X[3] == (cAliasQry)->EKB_CODFAB .and. ;
                                                  X[4] == (cAliasQry)->EKB_LOJA } )
            if nPosExcAut > 0
               // Caso ocorreu erro de inclusão do operador estrangeiro
               if !aExecAutOE[nPosExcAut][5]
                  cFilEKJ := if( lExcEKJ, (cAliasQry)->EKB_FILORI, xFilial("EKJ"))
                  cMsgProcOE += if(!empty(cFilEKJ), " - " + STR0111 + ": " + cFilEKJ, "" ) + " - " + STR0112 + ": " + (cAliasQry)->EK9_CNPJ // "Filial" | "CNPJ Raiz"
                  cMsgProcOE += " - " + STR0113 + ": " + (cAliasQry)->EKB_CODFAB + " - " +  STR0078 + ": " + (cAliasQry)->EKB_LOJA + " - " + aExecAutOE[nPosExcAut][6] + ENTER // "Código" | "Loja"
               endif
            endif

            if !empty((cAliasQry)->RECEKJ)
               // aExecIntOE -> { RECNO da EKJ, LOGICO .T. ou .F., MENSAGEM DA VALIDAÇÃO }
               nPosIntOE := aScan(aExecIntOE, { |X| X[1] == (cAliasQry)->RECEKJ } )
               if nPosIntOE > 0
                  EKJ->(dbGoTo((cAliasQry)->RECEKJ))
                  // Caso ocorreu erro de integração do operador estrangeiro
                  if !aExecIntOE[nPosIntOE][2]
                     lMsgIntOE := .T.
                     cFilEKJ := if( lExcEKJ, EKJ->EKJ_FILIAL, xFilial("EKJ"))
                     cMsgProcOE += if(nPosExcAut > 0, ENTER, "") + if(!empty(cFilEKJ), " - " + STR0111 + ": " + cFilEKJ, "" ) + " - " + STR0112 + ": " + EKJ->EKJ_CNPJ_R // "Filial" | "CNPJ Raiz"
                     cMsgProcOE += " - " + STR0113 + ": " +  EKJ->EKJ_FOLOJA + " - " + STR0078 + ": " + (cAliasQry)->EKB_LOJA + " - " + aExecIntOE[nPosIntOE][3] + ENTER // "Código" | "Loja"
                  endif
               endif

            endif

            (cAliasQry)->(dbskip())
         end

         if !empty(cMsgProcOE)
	         cMsgPrcIni := STR0115 + ":" + ENTER // "Ocorreram as seguintes validações no processamento dos Operadores estrangeiros"
	         if lMsgIntOE
	            cMsgPrcIni := STR0126 + ":" + ENTER // "Ocorreram as seguintes validações no Portal Único durante o processamento dos Operadores estrangeiros"
	         endif
	         cMsgProcOE := cMsgPrcIni + subStr(cMsgProcOE, 1, len(cMsgProcOE)-len(ENTER)) // Remove o ultimo ENTER adicionado
	      endif

	   endif

      if (cAliasTmp)->(dbSeek(cCodCat))
         Reclock(cAliasTmp,.F.)
         // Independente se houve sucesso ou não no processamento dos operadores estrangeiro, atualiza a etapa para integração do catálogo de produtos
         // Pois o catálogo poderá ficar com status de integrado mas com pendencia de Fabricante ou País de Origem
         (cAliasTmp)->ETAPA   := ETAPA_CATALOGO // Integração do catálogo de produtos

         // Caso não teve necessidade de realizar o processamento dos operadores estrangeiros, somente atualiza que está validados com sucesso
         if !lProcOE
            (cAliasTmp)->RETORNO := '- ' + STR0114 // "Operadores estrangeiros validados com sucesso."
         elseif !empty(cMsgProcOE)
            (cAliasTmp)->RETORNO := cMsgProcOE
         endif
         (cAliasTmp)->LOGPROC := (cAliasTmp)->LOGPROC + (cAliasTmp)->RETORNO + ENTER + ENTER 

         (cAliasTmp)->(msUnLock())
         oBrowProc:Refresh()
      endif

      (cAliasQry)->(dbskip())
   end
   (cAliasQry)->(dbCloseArea())
   
   restArea(aAreaTMP)

return nil

/*/{Protheus.doc} ProcCatPrd
   Função para realizar o processamento dos catalogo de produtos marcados para integração

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function ProcCatPrd(lEnd, oEasyJS, oProc, oBrowProc, lIntProd, cURLPortal, lUnico)
   local cAliasTmp  := CP402_TABLE
   local nRecno     := 0
   local cMsgPrcCat := ""
   local lIntegOk   := .F.
   local nPrcCount  := 1

   if !lUnico
      // Recebe a quantidade de registros marcados para integração para realizar a integração do catalogo de produtos
      nPrcCount := getQtdPrc(ETAPA_CATALOGO)
   endif
   oProc:SetRegua2(nPrcCount) // Regua para cada registro processado

   EK9->(dbsetorder(1)) // EK9_FILIAL+EK9_COD_I+EK9_VATUAL
   EKD->(dbsetorder(1)) // EKD_FILIAL+EKD_COD_I+EKD_VERSAO
   EKE->(dbsetorder(1)) // EKE_FILIAL+EKE_COD_I+EKE_VERSAO+EKE_ITEM

   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())

      // Processa o registro apenas se estiver marcado para integração e na etapa de integração do catalogo de produtos
      if !((cAliasTmp)->STATUS == ERRO) .and. !empty((cAliasTmp)->REG_MARCA) .and. (cAliasTmp)->ETAPA == ETAPA_CATALOGO
         nRecno := (cAliasTmp)->(recno())
         oProc:IncRegua2(STR0005 + ": " + (cAliasTmp)->EK9_COD_I) // "Catálogo de produtos"

         lIntegOk := (cAliasTmp)->EK9_STATUS == REGISTRADO_PENDENTE_FAB_PAIS
         if !lIntegOk
            lIntegOk := .F.
            cMsgPrcCat := STR0116 // "Catalogo de produtos e sua sequência de histórico não encontrado."
            if EK9->(dbSeek( xFilial("EK9") + (cAliasTmp)->EK9_COD_I )) .and. EKD->(dbSeek( xFilial("EKD") + (cAliasTmp)->EK9_COD_I + (cAliasTmp)->EKD_VERSAO ))
               cMsgPrcCat := ""
               lIntegOk := IntCatPrd(oEasyJS, lIntProd, cURLPortal, @cMsgPrcCat )
            endif
         endif

         Reclock(cAliasTmp,.F.)
         if lIntegOk
            (cAliasTmp)->RETORNO := '- ' + STR0117 // "Catálogo de produtos validado com sucesso."
            (cAliasTmp)->ETAPA   := ETAPA_VINCULACAO // Vinculação dos operadores estrangeiros com o catálogo de produtos 
         else
            (cAliasTmp)->RETORNO := STR0118 + ":" + ENTER + ' - ' + cMsgPrcCat // "Ocorreram as seguintes validações no Portal Único durante o processamento do Catálogo de produtos"
            (cAliasTmp)->STATUS  := ERRO
            (cAliasTmp)->ETAPA   := ETAPA_FIM // Fim do processamento
         endif
         (cAliasTmp)->LOGPROC := (cAliasTmp)->LOGPROC + (cAliasTmp)->RETORNO + ENTER + ENTER 
         (cAliasTmp)->(msUnLock())

         oBrowProc:Refresh()
         (cAliasTmp)->(dbGoTo(nRecno))
      endif

      (cAliasTmp)->(dbSkip())
   end 

return nil

/*/{Protheus.doc} IntCatPrd
   Função para realizar o processamento dos catalogo de produtos
   Criação de json, integração com o Portal Único e atualizado do retorno nas tabelas de negócio
   Precisa esta posicionado na EK9 e EKD com a sequencia do historico desejada

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function IntCatPrd(oEasyJS, lIntProd, cURLPortal, cMsgPrcCat )
   local nRecEK9    := EK9->(recno())
   local nRecEKD    := EKD->(recno())
   local lRet       := .F.
   local cLogIniCat := ""
   local cJsonCat   := ""
   local cLogInteg  := ""
   local cMsgProc   := ""
   local cEndPoint  := ""
   local cOperacao  := ""
   local cErrorProc := ""
   local cRetInteg  := ""
   local cIdCat     := ""
   local cVerCat    := ""
   local cLogComp   := ""

   default cMsgPrcCat := ""

   private cIntCpfCnpj := ""

   cLogIniCat += STR0084 + if(lIntProd, STR0015, STR0016) + " - " + AVgetUrl(,,,,,.T.) + ENTER // "Integração realizada no ambiente de " ### "Produção." #### "Treinamento."
   cLogIniCat += dToc(Date()) +  " - " + Time() + " - " + STR0085 + UsrFullName(retCodUsr()) + ENTER + ENTER // "Usuário do sistema"

   // Gera o json do catálogo de produtos
   cJsonCat := JsonCatPrd()  
   lRet := comex.generics.validJson(cJsonCat)
   cLogInteg := Time() + " - " + STR0075 + cJsonCat + ENTER // "Mensagem de envio"

   cMsgProc := STR0089 + ENTER // "Mensagem de envio incorreta."
   if lRet
      EK9->(dbGoTo(nRecEK9))
      EKD->(dbGoTo(nRecEKD))

      cLogInteg += ENTER

      cIntCpfCnpj := EKD->EKD_CNPJ
      if(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICCP400_INTEGRAR"),)

      cEndPoint := cURLPortal + "/catp/api/ext/produto/" + alltrim(cIntCpfCnpj)

      cOperacao := "INSERT_CATALOGO"
      if !empty(EK9->EK9_IDPORT)
         cOperacao := "UPDATE_CATALOGO"
         cEndPoint += "/" + alltrim(EK9->EK9_IDPORT)
      endif

      // Integração do catalogo de produto com o Portal Único
      cErrorProc := ""
      cRetInteg := intPrtUni(oEasyJS, cOperacao, cEndPoint, cJsonCat, @cErrorProc)
      cLogInteg += Time() + " - " + STR0067 + ": " + cRetInteg + ENTER // "Mensagem de retorno"
   
      // Processamento do retorno da integração do catálogo de produtos
      cMsgProc := ""
      cIdCat := ""
      cVerCat := ""
      lRet := retCatProd(cRetInteg, cErrorProc, @cMsgProc, @cIdCat, @cVerCat) 

   endif

   cLogIniCat += STR0036 + ": " + if( lRet, STR0119, STR0058 ) + ENTER //  "Resultado da integração" | "Sucesso" | "Erro"
   cLogIniCat += if( lRet, ENTER, STR0120  + ": " + cMsgProc + ENTER + ENTER )   // "Mensagem de erro" 
   cLogIniCat += STR0086 + ": " + ENTER + ENTER // "Detalhes da Integração"

   cLogComp := cLogIniCat + cLogInteg + ENTER + STR0090 // "Fim da integração do catálogo"

   // Gravação do retorno nas tabelas de negocios EK9 e EKD
   EK9->(dbGoTo(nRecEK9))
   setEK9(cIdCat, cVerCat, cLogComp)
  
   EKD->(dbGoTo(nRecEKD))
   setEKD(cIdCat, cVerCat, cLogComp, .T.)

   cMsgPrcCat := cMsgProc

return lRet

/*/{Protheus.doc} JsonCatPrd
   Criação do json para o catalogo de produto

   @type  Static Function
   @author user
   @since 21/08/2023
   @version 1.0
   @param nenhum
   @return cJson, caractere, mensagem json do catalogo de produto
/*/
static function JsonCatPrd()
   local cJson      := ""
   local cModal     := "AMBOS"
   local cDenomi    := ""
   local cAtributos := ""
   local cChaveEKE  := ""
   local nContCP    := 0
   local cCodIntern := ""
   local lSeekEKE   := .F.
   local cDscCom    := ""

   cModal := if( EKD->EKD_MODALI == "1", "IMPORTACAO", if(EKD->EKD_MODALI == "2",  "EXPORTACAO", "AMBOS")) // =Importacao // =Exportacao // =Ambos
   cChaveEKE := xFilial("EKE") + EKD->EKD_COD_I + EKD->EKD_VERSAO
   lSeekEKE := EKE->(dbSeek(cChaveEKE))

   /* ------ Exemplo de Json retirado do Portal Único ------
   {
      "descricao": "Produto Teste",
      "denominacao": "Denominação Produto Teste",
      "modalidade": "EXPORTACAO",
      "ncm": "02011000",
      "atributos": [
         {
            "atributo": "ATT_1",
            "valor": "01"
         }
      ],
      "atributosMultivalorados": [
         {
            "valores": [
               "string"
            ],
            "atributo": "ATT_1"
         }
      ],
      "atributosCompostos": [
         {
            "valores": [
               {
                  "atributo": "ATT_1",
                  "valor": "01"
               }
            ],
            "atributo": "ATT_1"
         }
      ],
      "atributosCompostosMultivalorados": [
         {
            "valores": [
               [
                  {
                     "atributo": "ATT_1",
                     "valor": "01"
                  }
               ]
            ],
            "atributo": "ATT_1"
         }
      ],
      "codigosInterno": [
         "string"
      ]
   }
   ---------------------------------------------------------*/

   cDscCom := if( !empty(EK9->EK9_DSCCOM), comex.generics.SetStringJson(EK9->EK9_DSCCOM), "")
   cDenomi := if( !(getSX3Cache("EK9_DESC_I","X3_CONTEXT") == "V") .and. !empty(EK9->EK9_DESC_I), EK9->EK9_DESC_I,;
               Posicione("SB1", 1, if(CP400MultF(), EK9->EK9_FILORI, XFILIAL("SB1")) + EK9->EK9_PRDREF, "B1_DESC"))
   cDenomi := comex.generics.SetStringJson(cDenomi)
   
   cJson := '{'
   cJson += if( !empty(cDscCom), ' "descricao": "' + cDscCom               + '",', '') + ;
               ' "denominacao": "'                 + cDenomi               + '",' +;
               ' "modalidade": "'                  + cModal                + '",' + ;
               ' "ncm": "'                         + alltrim(EKD->EKD_NCM) + '"'
   cAtributos := getJsonAtt()
   // Retorna os atributos montados no formato json para a integração do catálogo
   cJson += if( !empty(cAtributos), ", " + cAtributos, "") 

   // percorre a lista de código relacionados que são enviados em lista
   if lSeekEKE
      cCodIntern := ', "codigosInterno": [ '
      while EKE->(!eof()) .and. EKE->(EKE_FILIAL+EKE_COD_I+EKE_VERSAO) == cChaveEKE
         nContCP++
         cCodIntern += if( nContCP > 1, ',', '')
         cCodIntern += '"' + if( !empty(EKE->EKE_FILORI), EKE->EKE_FILORI + "-" , "") + alltrim(EKE->EKE_PRDREF) + '"'
         EKE->(dbskip())
      enddo
      cCodIntern += ']'
      cJson += cCodIntern
   endif

   cJson += '}'

return cJson

/*/{Protheus.doc} getJsonAtt
   Monta o json com todos os atributos do catálogo, tratados por Atributos, Atributos Multi Valorados e Atributos Compostos.

   @type  Static Function
   @author user
   @since 21/08/2023
   @version 1.0
   @param nenhum
   @return cJsonAtt, caractere, mensagem json dos atributos catalogo de produto
/*/
Static Function getJsonAtt()
   Local cAliasAtt   := GetNextAlias()
   Local cJsonAtt    := "" //Montagem do Json a ser enviado com os atributos do catálogo (atributos)
   Local cJsonAttMV  := "" //Montagem do Json a ser enviado com os atributos do catálogo "Multi Valorado" (atributosMultivalorados)
   Local cJsonAttCP  := "" //Montagem do Json a ser enviado com os atributos do catálogo "Compostos" (atributosCompostos)
   Local cJsonAttMC  := "" //Trata atributos Compostos e Multivalorados
   Local lTemAtt     := .F. //Adiciona virgula para atributo
   Local lTemMV      := .F. //Adiciona virgula para atributo MultiValorado
   Local lTemCP      := .F. //Adiciona virgula para atributo composto
   //Local lTemCPMV    := .F. //Adiciona virgula para atributo composto e Multivalorados
   Local aAttCP      := {} //Controle de Atributos Compostos
   Local aAuxMV      := {}
   Local nAttCP
   Local cAuxATT
   Local nI
   local lAtrCadast := .F.
   local cQuery := ""
   local oQuery := nil
   local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
   local cEKI := RetSqlName('EKI') + cInformix
   local cEKG := RetSqlName('EKG') + cInformix
   local cEK9 := RetSqlName('EK9') + cInformix

   cQuery := " SELECT "
   cQuery += " EKI_COD_I, "
   cQuery += " EKI_VERSAO, "
   cQuery += " EKI_CODATR, "
   cQuery += " EKG.EKG_COD_I, "
   cQuery += " EKG.EKG_MULTVA, "
   cQuery += " EKI_CONDTE, "
   cQuery += " EKG.EKG_FORMA, "
   cQuery += " EKG_PAI.EKG_FORMA " + cInformix + " EKG_FORMA_PAI, "
   //cQuery += " CAST(EKI_VALOR AS VARCHAR(1000)) " + cInformix + " EKI_VALOR "
   cQuery += " EKI.R_E_C_N_O_ " + cInformix + " RECNOEKI "
   cQuery += " FROM " 
   cQuery +=  cEKI + " EKI "
   cQuery += " INNER JOIN " + cEK9 + " EK9 ON "
   cQuery += " ( EK9_FILIAL = ? AND EK9_COD_I  = EKI_COD_I ) "
   cQuery += " LEFT JOIN " + cEKG + " EKG ON "
   cQuery += " ( EKG.EKG_FILIAL    = ? " 
   cQuery += " AND EKG.EKG_NCM   = EK9_NCM "
   cQuery += " AND EKG.EKG_COD_I = EKI_CODATR "
   cQuery += " AND EKG.EKG_CODOBJ LIKE ? "
   cQuery += " AND EKG.D_E_L_E_T_ = ? ) "
   cQuery += " LEFT OUTER JOIN " + cEKG + " EKG_PAI ON "
   cQuery += " ( EKG_PAI.EKG_FILIAL = ? "
   cQuery += "   AND EKG_PAI.EKG_NCM     = EK9_NCM "
   cQuery += "   AND EKG_PAI.EKG_COD_I   = EKI_CONDTE " 
   cQuery += "   AND EKG.EKG_CODOBJ LIKE ? "
   cQuery += "   AND EKG_PAI.D_E_L_E_T_ = ? ) "
   cQuery += " WHERE "
   cQuery += " EKI_FILIAL     = ? "
   cQuery += "   AND EKI_COD_I  = ? "
   cQuery += "   AND EKI_VERSAO = ? "
   cQuery += "   AND EKI_VALOR IS NOT NULL "
   cQuery += "   AND EKI.D_E_L_E_T_ = ? "
   cQuery += "   AND EK9.D_E_L_E_T_ = ? "
   cQuery += " ORDER BY "
   cQuery += " EKI.EKI_FILIAL, "
   cQuery += " EKI.EKI_COD_I, "
   cQuery += " EKI.EKI_VERSAO, " 
   cQuery += " EKI.EKI_CODATR, "
   cQuery += " EKI.EKI_CONDTE  "    

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:setString(1,xFilial('EK9'))
   oQuery:setString(2,xFilial('EKG'))
   oQuery:setString(3,'%7%')   
   oQuery:setString(4,' ')   
   oQuery:setString(5,xFilial('EKG'))
   oQuery:setString(6,'%7%')   
   oQuery:setString(7,' ')   
   oQuery:setString(8,xFilial('EKI'))
   oQuery:setString(9,EKD->EKD_COD_I)
   oQuery:setString(10,EKD->EKD_VERSAO)
   oQuery:setString(11,' ')      
   oQuery:setString(12,' ')      

   cQuery := oQuery:GetFixQuery()

   MPSysOpenQuery(cQuery, cAliasAtt)
   fwFreeObj(oQuery)

   if (cAliasAtt)->(!eof())

      cJsonAtt    := ' "atributos": [ '
      cJsonAttMV  := ' "atributosMultivalorados": [ '
      cJsonAttCP  := ' "atributosCompostos": [ '
      cJsonAttMC  := ' "atributosCompostosMultivalorados": [ '
      while (cAliasAtt)->(!Eof())

         lAtrCadast := !empty((cAliasAtt)->EKG_COD_I) // atributos que estão na tabela EKG
         if Valtype((cAliasAtt)->RECNOEKI) == "N"
            EKI->(dbgoto((cAliasAtt)->RECNOEKI))
         endif

         If (lAtrCadast .and. !Empty((cAliasAtt)->EKI_CONDTE) .and. Alltrim((cAliasAtt)->EKG_FORMA_PAI) == ATT_COMPOSTO .And. (cAliasAtt)->EKG_MULTVA != "1" ) .or. ; //Atributo Composto e não multivalorado
            (!lAtrCadast .and. !Empty((cAliasAtt)->EKI_CONDTE))
            lTemCP := .T.
            cAuxATT :=  '{' + ;
                           ' "atributo": "' + Alltrim((cAliasAtt)->EKI_CODATR)                           + '",' + ;
                           ' "valor": ' + getCarac((cAliasAtt)->EKG_FORMA) + CP400gtFrm((cAliasAtt)->EKG_FORMA, EKI->EKI_VALOR, , .T.) + getCarac((cAliasAtt)->EKG_FORMA) + ;
                        '}'
            If (nAttCP := aScan(aAttCP,{|X| X[1] == (cAliasAtt)->EKI_CONDTE})) > 0
               aAttCP[nAttCP][2] += "," + cAuxATT
            Else
               aAdd(aAttCP,{(cAliasAtt)->EKI_CONDTE, cAuxATT})
            EndIf

         ElseIf lAtrCadast .and. !Empty((cAliasAtt)->EKI_CONDTE) .And. Alltrim((cAliasAtt)->EKG_FORMA_PAI) == ATT_COMPOSTO .And. (cAliasAtt)->EKG_MULTVA == "1"  //Atributo Composto e multivalorado
            //lTemCPMV := .T.
            
         ElseIf (lAtrCadast .and. (cAliasAtt)->EKG_MULTVA == "1") .or. ; //Multivalorado = 1-Sim;
               (!lAtrCadast .and. !empty(EKI->EKI_VALOR) .and. (';' $ EKI->EKI_VALOR))
            if lTemMV
               cJsonAttMV += ','
            endif
            lTemMV := .T.
            
            cJsonAttMV +=  '{' + ;
                           ' "valores": [ '

            If !lAtrCadast .or. Alltrim((cAliasAtt)->EKG_FORMA) == ATT_LISTA_ESTATICA
               aAuxMV := Strtokarr2(EKI->EKI_VALOR, ';')
            ElseIf Alltrim((cAliasAtt)->EKG_FORMA) == ATT_TEXTO
               aAuxMV := Strtokarr2(EKI->EKI_VALOR, chr(13)+chr(10))
            EndIf
            For nI := 1 To Len(aAuxMV)
               If nI > 1 
                  cJsonAttMV += ","
               EndIf
               cJsonAttMV += '"' + if( Alltrim((cAliasAtt)->EKG_FORMA) == ATT_TEXTO, comex.generics.SetStringJson(aAuxMV[nI]) , aAuxMV[nI] )+ '"'
            Next
            cJsonAttMV += "],"
            cJsonAttMV +=  ' "atributo": "' + Alltrim((cAliasAtt)->EKI_CODATR) + '" '
            cJsonAttMV +=  '}'

         ElseIf ! empty(EKI->EKI_VALOR)
            
            if lTemAtt
               cJsonAtt += ','
            endif
            lTemAtt := .T.

            cJsonAtt += '{' + ;
                           ' "atributo": "' + Alltrim((cAliasAtt)->EKI_CODATR)                           + '",' + ;
                           ' "valor": ' + getCarac((cAliasAtt)->EKG_FORMA) + CP400gtFrm((cAliasAtt)->EKG_FORMA, EKI->EKI_VALOR, , .T.) + getCarac((cAliasAtt)->EKG_FORMA) + ;
                        '}'
         endif
         (cAliasAtt)->(dbskip())
      enddo
      
      //Monta a lista de ATRIBUTOS
      cJsonAtt    += ']'

      //Monta a lista de atributos MULTI VALORADOS
      If lTemMV
         cJsonAttMV  += ']'
         cJsonAtt += ', ' + cJsonAttMV
      EndIf
      
      //Monta a lista de atributos COMPOSTOS
      If lTemCP
         For nI := 1 To Len(aAttCP)
            If nI > 1
               cJsonAttCP += ","
            EndIf
            cJsonAttCP += '{ "valores":[ '
            cJsonAttCP += aAttCP[nI][2]
            cJsonAttCP += ' ], "atributo": "' + Alltrim(aAttCP[nI][1]) + '" }'
         Next
         cJsonAttCP += ']'
         cJsonAtt += ', ' + cJsonAttCP
      EndIf
      
      //Monta atributos COMPOSTOS e MULTI VALORADOS
      //If lTemCPMV
         //cJsonAttMC  += ']'
      //EndIf

   endif

   (cAliasAtt)->(dbCloseArea())

return cJsonAtt

/*/{Protheus.doc} retCatProd
   Tratamento para o retorno da integração do catalogo de produto

   @type  Static Function
   @author user
   @since 21/08/2023
   @version 1.0
   @param cRetJson, caractere, retorno obtido do portal unico
          cRespError, caractere, retorno de erro obtido do portal unico
          cMsgProc, caractere, mensagem de processamento
   @return lRet, logico, .T. com sucesso e .F. com falha
/*/
static function retCatProd(cRespInt, cRespError, cMsgProc, cCodPrtUni, cVerPrtUni)
   local lRet       := .F.
   local oJsonResp  := nil
   local oRespInt   := nil
   local xRetJson   := nil
   local oJson      := nil
   local cSituacao  := ""
   local nI         := 0
   local aAreaEKD

   default cRespInt   := ""
   default cRespError := ""
   default cMsgProc   := ""
   default cCodPrtUni := ""
   default cVerPrtUni := ""

   // Declara a variavel a cada catalogo integrado, pois pode ficar na memoria a variavel, utilizado na função cp400getNomeAtt
   // private oJsonAtt := jsonObject():New()

   /* ------ Exemplo de Json retirado do Portal Único ------
   {
      "descricao": "Produto Teste",
      "denominacao": "Denominação Produto Teste",
      "modalidade": "EXPORTACAO",
      "ncm": "02011000",
      "atributos": [
         {
            "atributo": "ATT_1",
            "valor": "01"
         }
      ],
      "atributosMultivalorados": [
         {
            "valores": [
               "string"
            ],
            "atributo": "ATT_1"
         }
      ],
      "atributosCompostos": [
         {
            "valores": [
               {
                  "atributo": "ATT_1",
                  "valor": "01"
               }
            ],
            "atributo": "ATT_1"
         }
      ],
      "atributosCompostosMultivalorados": [
         {
            "valores": [
               [
                  {
                     "atributo": "ATT_1",
                     "valor": "01"
                  }
               ]
            ],
            "atributo": "ATT_1"
         }
      ],
      "codigosInterno": [
         "string"
      ],
      "cpfCnpjRaiz": "00000000",
      "codigo": 123,
      "versao": "1",
      "situacao": "ATIVADO"
   }
   ---------------------------------------------------------*/

   if !empty(cRespInt)
      oJsonResp := JsonObject():New()
      xRetJson := oJsonResp:FromJson(cRespInt)
      if xRetJson == nil
         oRespInt := oJsonResp['response']
         if oJsonResp['status'] <> 200 .and. oRespInt != nil .and. oRespInt:hasProperty('message')
            cMsgProc := oRespInt['message']
            If oRespInt:hasProperty('detail')
               If ValType(oRespInt['detail']) == "A" .And. Len(oRespInt['detail']) > 0
                  For nI := 1 To Len(oRespInt['detail'])
                     if !oRespInt['detail'][nI]['error']['message'] $ cMsgProc
                        cMsgProc += ENTER + " - " + oRespInt['detail'][nI]['error']['message']
                     endif
                  Next
               EndIf
            EndIf
            if !empty(cMsgProc)
               cRespInt := ""
            endif
         endIf
      endif
      FwFreeObj(oJsonResp)
   endif

   if empty(cMsgProc)
      cMsgProc := STR0071 // "Integração sem nenhum retorno!"
   endif

   if !empty(cRespInt) .and. empty(cRespError)

      oJson := JsonObject():New()
      xRetJson := oJson:FromJson(cRespInt)
      cMsgProc := if( !valtype(xRetJson) == "U", STR0065, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."

      if empty(cMsgProc)

         oJsonResp := oJson["response"]
         // Trecho comentado pois não entra devido a lógica da linha 2026
         // Não há um caso onde o portal único retorna 200 com uma mensagem
         // if oJsonResp:hasProperty("message")
         //    cMsgProc := oJsonResp:GetJsonText("message")
         //    cMsgProc := cp400getNomeAtt(cMsgProc, EKD->EKD_NCM, EKD->EKD_MODALI)
         // endif
         cMsgProc += getError(oJsonResp)

         if oJsonResp:hasProperty("codigo") .and. valtype(oJsonResp:GetJsonText("codigo")) == "C"
            cCodPrtUni := oJsonResp:GetJsonText("codigo")
         endif

         if oJsonResp:hasProperty("versao") .and. valtype(oJsonResp:GetJsonText("versao")) == "C"
            cVerPrtUni := oJsonResp:GetJsonText("versao")
         endif

         if oJsonResp:hasProperty("situacao") .and. valtype(oJsonResp:GetJsonText("situacao")) == "C"
            cSituacao := alltrim(upper(oJsonResp:GetJsonText("situacao")))
         endif

         lRet := empty(cMsgProc) .and. !empty(cCodPrtUni) .and. !empty(cVerPrtUni) .and. (cSituacao == "ATIVADO")

         if lRet
            aAreaEKD := EKD->(getArea())
            if ExistCpo("EKD", EK9->EK9_COD_I + AvKey(cCodPrtUni,"EK9_IDPORT") + AvKey(cVerPrtUni,"EK9_VATUAL"), 3, , .F.)
               cMsgProc += STR0069 +" (" +Alltrim(cCodPrtUni)+"/"+Alltrim(cVerPrtUni)+ ")" + ENTER // "O ID e Versão retornados pela integração já existem no histórico de Integrações do Catálogo de Produtos."
               cMsgProc += STR0070 // "Para utilizar este ID e Versão, recomendamos tornar obsoleto o registro atual e incluir um novo Catálogo de Produtos, informando os campos ID Manual e Versão Manual."
               lRet := .F.
            endif
            restArea(aAreaEKD)
         endif

      endif
      FwFreeObj(oJson)

   elseif !empty(cRespError)
      cMsgProc := if( match(cRespError,"*Failed to fetch*"), STR0062 , cRespError) // "Não foi possível estabelecer conexão com o portal único. Verifique se está conectado na internet ou se o certificado está correto."

   endif

return lRet

/*/{Protheus.doc} setEK9
   Função para atualizar os campos da EK9 após a integração

   @type  Static Function
   @author user
   @since 21/02/2025
   @version version
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static Function setEK9(cIdPort, cVersao, cLogInteg, lVincFab, lVincError)
   default lVincFab   := .F.
   default lVincError := .F.

   reclock("EK9",.F.)
   EK9->EK9_RETINT := if( lVincFab, EK9->EK9_RETINT + ENTER + ENTER + cLogInteg, cLogInteg )
   if !lVincFab .and. !empty(cIdPort) .and. !empty(cVersao)
      EK9->EK9_STATUS := REGISTRADO
      EK9->EK9_IDPORT := cIdPort
      EK9->EK9_VATUAL := cVersao
   elseif lVincFab 
      if lVincError
         EK9->EK9_STATUS := REGISTRADO_PENDENTE_FAB_PAIS
      else
         EK9->EK9_STATUS := REGISTRADO
      endif
   endif
   EK9->(msUnLock())

return nil

/*/{Protheus.doc} setEKD
   Função para atualizar os campos da EKD após a integração

   @type  Static Function
   @author user
   @since 21/02/2025
   @version version
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static Function setEKD(cIdPort, cVersao, cLogInteg, lVldObsol, lVincFab, lVincError)
   local nRecEKD := EKD->(recno())

   default lVldObsol  := .F.
   default lVincFab   := .F.
   default lVincError := .F.

   // Validação para tornar obsoleto o catálogo com o status integrado caso exista algum.
   if lVldObsol .and. !empty(cIdPort) .and. !empty(cVersao)
      EKD->(dbSeek(xFilial("EKD") + EK9->EK9_COD_I))
      while EKD->(!EOF()) .And. EKD->EKD_FILIAL == xFilial("EKD") .And. EKD->EKD_COD_I == EK9->EK9_COD_I
         if EKD->EKD_STATUS $ '1|5|6' // 1=Registrado | 5=Registrado(pendente: fabricante/ país) | 6=Registrado Manualmente
            RecLock("EKD",.F.)
            EKD->EKD_STATUS := '3' //Obsoleto
            EKD->(msUnLock())
         endif
         EKD->(dbSkip())
      end
   endif

   EKD->(dbGoTo(nRecEKD))
   reclock("EKD",.F.)
   EKD->EKD_RETINT := if( lVincFab, EKD->EKD_RETINT + ENTER + ENTER + cLogInteg, cLogInteg )
   if !lVincFab
      EKD->EKD_USERIN := __cUserID
      if !empty(cIdPort) .and. !empty(cVersao)
         EKD->EKD_STATUS := "1" // "Registrado"
         EKD->EKD_IDPORT := cIdPort
         EKD->EKD_VATUAL := cVersao
         EKD->EKD_DATA   := dDatabase
         EKD->EKD_HORA   := strtran(time(),":","")
      else
         // Verificar o porque validava somente o cIdPort, caso não retorno, não deveria atribuir falha de integração?
         // Ou ficaria como pendencia de integração?
         if !empty(cIdPort) 
            EKD->EKD_STATUS := "4" // "Falha de Integração"
         endif
      endif
   else
      if lVincError
         EKD->EKD_STATUS := "5" //Integrado (pendente: fabricante/país)
      else
         EKD->EKD_STATUS := "1" // "Registrado"
      endif
   endif
   EKD->(msUnLock())

return nil

/*/{Protheus.doc} ProcVincOE
   Função para realizar o processamento da vinculação dos operadores estrangeiros ou país de origem ao catalogo de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function ProcVincOE(lEnd, oEasyJS, oProc, oBrowProc, lIntProd, cURLPortal, lUnico)
   local cAliasTmp  := CP402_TABLE
   local nRecno     := 0
   local cMsgVinCat := ""
   local lIntegOk   := .F.
   local nPrcCount  := 1

   if !lUnico
      // Recebe a quantidade de registros marcados para integração para vincular/desvincular os fabricantes ou País de origem do catálogo de produtos
      nPrcCount := getQtdPrc(ETAPA_VINCULACAO)
   endif
   oProc:SetRegua2(nPrcCount) // Regua para cada registro processado

   EK9->(dbsetorder(1)) // EK9_FILIAL+EK9_COD_I+EK9_VATUAL
   EKD->(dbsetorder(1)) // EKD_FILIAL+EKD_COD_I+EKD_VERSAO
   EKF->(dbsetorder(1)) // EKF_FILIAL+EKF_COD_I+EKF_VERSAO+EKF_CODFAB+EKF_LOJA+EKF_PAIS+EKF_FILORI

   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())

      // Processa o registro apenas se estiver marcado para integração e na etapa de vinculação dos operadores estrangeiros com o catálogo de produtos
      if !((cAliasTmp)->STATUS == ERRO) .and. !empty((cAliasTmp)->REG_MARCA) .and. (cAliasTmp)->ETAPA == ETAPA_VINCULACAO
         nRecno := (cAliasTmp)->(recno())
         oProc:IncRegua2(STR0005 + ": " + (cAliasTmp)->EK9_COD_I) // "Catálogo de produtos"

         lIntegOk := .F.
         cMsgVinCat := STR0121 // "Catálogo de produtos e sua sequência de histórico não encontrado para vinculação/desvinculação."
         if EK9->(dbSeek( xFilial("EK9") + (cAliasTmp)->EK9_COD_I )) .and. EKD->(dbSeek( xFilial("EKD") + (cAliasTmp)->EK9_COD_I + (cAliasTmp)->EKD_VERSAO ))
            cMsgVinCat := ""
            lIntegOk := IntVincPrd(oEasyJS, lIntProd, cURLPortal, @cMsgVinCat )
         endif

         Reclock(cAliasTmp,.F.)
         if lIntegOk
            (cAliasTmp)->RETORNO := '- ' + STR0122 // "Vinculação/Desvinculação de operadores estrangeiros/País de Origem validados com sucesso."
            (cAliasTmp)->STATUS  := OK
         else
            (cAliasTmp)->RETORNO := STR0123 + ":" + ENTER + ' - ' + cMsgVinCat // "Ocorreram as seguintes validações no Portal Único durante o processamento da vinculação/desvinculação dos operadores estrangeiros ou país de origem"
            (cAliasTmp)->STATUS  := ERRO
            (cAliasTmp)->ETAPA   := ETAPA_FIM // Fim do processamento
         endif
         (cAliasTmp)->LOGPROC := (cAliasTmp)->LOGPROC + (cAliasTmp)->RETORNO + ENTER + ENTER 
         (cAliasTmp)->(msUnLock())

         oBrowProc:Refresh()
         (cAliasTmp)->(dbGoTo(nRecno))
      endif

      (cAliasTmp)->(dbSkip())
   end 

return nil

/*/{Protheus.doc} IntVincPrd
   Função para realizar a vinculação/desvinculação dos operadores estrangeiros ou país de origem ao catalogo de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oProc, objeto, objeto da classe MsNewProcess
   @return nulo
   @example
   (examples)
   @see (links_or_references)
/*/
static function IntVincPrd(oEasyJS, lIntProd, cURLPortal, cMsgVinCat )
   local lRet       := .F.
   local nRecEK9    := EK9->(recno())
   local nRecEKD    := EKD->(recno())
   local cChaveEKF  := ""
   local cLogInteg  := ""
   local cJsonVinc  := ""
   local cEndPoint  := ""
   local cOperacao  := ""
   local cErrorProc := ""
   local cRetInteg  := ""
   local lVincOK    := .F.
   local lVincError := .F.
   local cMsgProc   := ""
   local lProcVinc  := .F.

   private cIntCpfCnpj := ""

   cChaveEKF := xFilial("EKF") + EKD->EKD_COD_I + EKD->EKD_VERSAO
   if EKF->(dbSeek( cChaveEKF ))
      cLogInteg += Time() + " - " + STR0124 + ENTER + ENTER // "Vinculando/desvinculando os operadores estrangeiros ou País de origem aos catálogos de produtos."

      while EKF->(!eof()) .And. EKF->( EKF_FILIAL + EKF_COD_I + EKF_VERSAO ) == cChaveEKF

         //EKF_VINCFB -> 1=Vincular ao catálogo;2=Desvincular do catálogo;3=Sem alteração;4=Vinculado ao catálogo;5=Desvinculado do catálogo
         if !empty(EKF->EKF_VINCFB) .And. !(EKF->EKF_VINCFB $ "3|4|5")
            lProcVinc := .T.

            // Gera o json da vinculação/desvinculação do operador estrangeiro ou País de origem
            cJsonVinc := getJsonFab()
            cLogInteg += Time() + " - " + STR0075 + cJsonVinc + ENTER + ENTER // "Mensagem de envio"

            cIntCpfCnpj := EKD->EKD_CNPJ
            If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICCP400_VINCULAR_FABRICANTE"),)

            cEndPoint := cURLPortal + "/catp/api/ext/fabricante/" + alltrim(cIntCpfCnpj)
            cOperacao := "VINCULA_OPERADOR"
            if EKF->EKF_VINCFB == "2" // Desvincular do catálogo
               cOperacao := "DESVINCULA_OPERADOR"
            endif

            // Vinculação/Desvinculação do Operador Estrangeiro ou País de Origem do catalogo de produto com o Portal Único
            cErrorProc := ""
            cRetInteg := intPrtUni(oEasyJS, cOperacao, cEndPoint, cJsonVinc, @cErrorProc)
            cLogInteg += Time() + " - " + STR0067 + ": " + cRetInteg + ENTER + ENTER// "Mensagem de retorno"

            // Processamento do retorno da Vinculação/Desvinculação do Operador Estrangeiro 
            cMsgProc := ""
            lVincOK := retVincOE(cRetInteg, cErrorProc, @cMsgProc)
            if !lVincOK
               lVincError := .T. 
            endif
            
            setEKF(lVincOK)

         endif

         EKF->(dbSkip())
      end
      cLogInteg += Time() + " - " + STR0125 + ENTER + ENTER // "Fim da vinculação/desvinculação dos operadores estrangeiros/País de Origem."

      if lProcVinc
         // Gravação do retorno nas tabelas de negocios EK9 e EKD
         EK9->(dbGoTo(nRecEK9))
         setEK9(EK9->EK9_IDPORT, EK9->EK9_VATUAL, cLogInteg, .T., lVincError)
      
         EKD->(dbGoTo(nRecEKD))
         setEKD(EK9->EK9_IDPORT, EK9->EK9_VATUAL, cLogInteg, .F., .T., lVincError)

         cMsgVinCat := cMsgProc
      endif

   endif

   lRet := !lVincError

return lRet

/*/{Protheus.doc} getJsonFab
   Função para atualizar os campos do catálogo de produtos após a integração

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param nenhum
   @return cJson, caracter, json de envio da vinculação/desvinculação do operador estrangeiro ou País de origem
   @example
   (examples)
   @see (links_or_references)
/*/
static function getJsonFab()   
   local cJson      := ""
   local lExcEKJ    := .F.
   local cConhFB    := ""
   local cCodProdF  := ""
   local cCodPaisF  := ""
   local cCodOEFB   := ""
   local cCpfCnpjFB := ""

   /* ------ Exemplo de Json retirado do Portal Único ------
   {
      "codigoOperadorEstrangeiro": "123",
      "cpfCnpjFabricante": "00000000000000",
      "conhecido": false,
      "codigoProduto": 1,
      "codigoPais": "DE"
   }
   ---------------------------------------------------------*/
   lExcEKJ := CP400OpExc()

   cConhFB := if( !empty(EKF->EKF_CODFAB) , "true" , "false" )
   cCodProdF := EKD->EKD_IDPORT
   cCodPaisF := alltrim(EKF->EKF_PAIS)

   if !empty(EKF->EKF_CODFAB)
      EKJ->(dbSeek( if( lExcEKJ, EKF->EKF_FILORI, xFilial("EKJ")) + EKD->EKD_CNPJ + EKF->EKF_CODFAB + EKF->EKF_LOJA ))
      if EKJ->EKJ_PAIS == "BR"
         SA2->(dbSeek( if( lExcEKJ, EKF->EKF_FILORI, xFilial("SA2")) + EKF->EKF_CODFAB + EKF->EKF_LOJA))
         cCodOEFB   := ""
         cCpfCnpjFB := SA2->A2_CGC 
      else // se o pais origem for diferente de brasil manda o código do operador estrangeiro
         cCodOEFB   := AllTrim(EKJ->EKJ_TIN)
         cCpfCnpjFB := ""
      endif
   endif

   cJson := '{' 
   cJson +=    '"codigoOperadorEstrangeiro": "' + cCodOEFB + '", '
   cJson +=    '"cpfCnpjFabricante": "' + cCpfCnpjFB + '", '
   cJson +=    '"conhecido": ' + cConhFB + ', ' 
   cJson +=    '"codigoProduto": ' + cCodProdF + ', '
   cJson +=    '"codigoPais": "' + cCodPaisF + '"'
   cJson += '}'

return cJson

/*/{Protheus.doc} retVincOE
   Função para tratar o resultado da integração da vinculação do operador estrangeiro ou país de origem

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param nenhum
   @return cTxtJson, caracter, json de envio
   @example
   (examples)
   @see (links_or_references)
/*/
static function retVincOE(cRespInt, cRespError, cMsgProc)
   local lRet       := .T.
   local oJson      := nil
   local xRetJson   := ""
   local oJsonResp  := nil

   cRespError := if( empty(cRespInt) .and. empty(cRespError), STR0071, cRespError) // "Integração sem nenhum retorno!"

   if !empty(cRespInt) .and. empty(cRespError)

      oJson := JsonObject():New()
      xRetJson := oJson:FromJson(cRespInt)
      cMsgProc := if( !valtype(xRetJson) == "U", STR0065, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."

      if empty(cMsgProc)

         oJsonResp := oJson["response"]
         if oJsonResp:hasProperty("message")
            cMsgProc := oJsonResp:GetJsonText("message")
         endif
         cMsgProc += getError(oJsonResp)
 
         lRet := empty(cMsgProc)

      endif
      FwFreeObj(oJson)

   elseif !empty(cRespError)
      cMsgProc := if( match(cRespError,"*Failed to fetch*"), STR0062 , cRespError) // "Não foi possível estabelecer conexão com o portal único. Verifique se está conectado na internet ou se o certificado está correto."

   endif

return lRet

/*/{Protheus.doc} getError()
   Retorna os erros de integração do portal unico

   @type  Static Function
   @author user
   @since 05/12/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getError(oJsonResp)
   local cErrors    := ""
   local aError     := {}
   local nError     := 0

   if oJsonResp:hasProperty("detail")
      aError := if( valtype(oJsonResp:GetJsonObject("detail")) == "C", {oJsonResp:GetJsonObject("detail")}, oJsonResp:GetJsonObject("detail"))
      for nError := 1 to len(aError)
         if aError[nError]:hasProperty("error")
            if aError[nError]['error']:hasProperty("message") .and. !(aError[nError]['error']:GetJsonText("message") $ cErrors)
               cErrors += aError[nError]['error']:GetJsonText("message") + ENTER
            endif
         endif
      next
      cErrors := subStr(cErrors, 1, len(cErrors)-len(ENTER)) // Remove o ultimo ENTER adicionado
   endif   

return cErrors

/*/{Protheus.doc} setEKF
   Função que atualiza o status da EKF

   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param lEKFVincFB, indica se o campo KF_VINCFB existe na base
          lRet, indica o retorno de suceso ou falha na integração da vinculaçao do operador estrangiero
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
static function setEKF(lVincOK)
   local cStatusInt  := ""

   //EKF_VINCFB -> 1=Vincular ao catálogo;2=Desvincular do catálogo;3=Sem alteração;4=Vinculado ao catálogo;5=Desvinculado do catálogo
   cStatusInt := if(lVincOK, if( EKF->EKF_VINCFB == "1" , "4" , "5" ), EKF->EKF_VINCFB ) // 4=Vinculado ao catálogo;5=Desvinculado do catálogo
   if !(EKF->EKF_VINCFB == cStatusInt)
      EKF->(RecLock("EKF",.F.))
      EKF->EKF_VINCFB := cStatusInt
      EKF->(msUnLock())
   endif

return nil

/*/{Protheus.doc} getCarac
   Verifica se o tipo do atributo é numérico ou não e retorna o tipo de aspas para o json ou vazio
   @type  Static Function
   @author user
   @since 18/03/2025
   @version version
   @param aCatalogo
   @return Retorna aspas ou vazio conforme o tipo do valor do atributo
   @example
   (examples)
   @see (links_or_references)
/*/
static function getCarac(cTipo)
local cRet := if(left(UPPER(cTipo),6)=='NUMERO','','"')
return cRet

/*/{Protheus.doc} getQtdPrc()
   Retorna a quantidade de registro do arquivo temporario

   @type  Static Function
   @author user
   @since 04/12/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getQtdPrc(cEtapa, aStatusCat)
   local nQtd       := 0
   local cQuery     := ""
   local oQuery     := nil
   local cAliasTmp  := CP402_TABLE
   local cMarca     := MARCA
   local cAliasQry  := ""
   local nQuery     := 0

   default cEtapa     := ""
   default aStatusCat := {}

   cQuery := " SELECT "
   cQuery +=      " COUNT(*) TOTAL "
   cQuery += " FROM " + TETempName(cAliasTmp) 
   cQuery += " WHERE REG_MARCA = ? "
   if !empty(cEtapa)
      cQuery +=   " AND ETAPA = ? "
   endif
   if !empty(aStatusCat)
      cQuery +=   " AND EK9_STATUS IN(?)  "
   endif
   cQuery +=      " AND D_E_L_E_T_ = ? "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1, cMarca ) // REG_MARCA
   nQuery := 1
   if !empty(cEtapa)
      nQuery += 1
      oQuery:SetString(nQuery, cEtapa ) // ETAPA
   endif
   if len(aStatusCat) > 0 
      nQuery += 1
      oQuery:SetIn(nQuery, aStatusCat ) // EK9_STATUS
   endif
   nQuery += 1
   oQuery:SetString(nQuery, " " ) // D_E_L_E_T_
   cQuery := oQuery:GetFixQuery()
   FwFreeObj(oQuery)

   cAliasQry := GetNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   nQtd := (cAliasQry)->TOTAL
   (cAliasQry)->(dbCloseArea())
   
return nQtd

/*/{Protheus.doc} CP402Script
   Gera o script consumir o serviço do portal unico através do easyjs 
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
static function CP402Script()
   Local cVar

   begincontent var cVar

      function insertCatalogo(cUrl, sBody, retAdvplError, retAdvpl) {
         let status = 0;
         let status_text = '';
         EasyFetch( retAdvplError, cUrl, 'POST', sBody)
         .then( (res) => {
            status = res.status;
            status_text = res.statusText;
            return res.json() 
         })
         .then( (res) => { retAdvpl({status: status, status_text: status_text, response: res}) } )
         .catch((e) => { retAdvplError(e) });
      }

      function updateCatalogo(cUrl, sBody, retAdvplError, retAdvpl) {
         let status = 0;
         let status_text = '';
         EasyFetch( retAdvplError, cUrl, 'PUT', sBody)
         .then( (res) => {
            status = res.status;
            status_text = res.statusText;
            return res.json() 
         })
         .then( (res) => { retAdvpl({status: status, status_text: status_text, response: res}) } )
         .catch((e) => { retAdvplError(e) });
      }

      function linkOperador(cUrl, sBody, retAdvplError, retAdvpl) {
         let status = 0;
         let status_text = '';
         EasyFetch( retAdvplError, cUrl, 'POST', sBody)
         .then( (res) => {
            status = res.status;
            status_text = res.statusText;
            return res.json() 
         })
         .then( (res) => { retAdvpl({status: status, status_text: status_text, response: res}) } )
         .catch((e) => { retAdvplError(e) });
      }

      function unlinkOperador(cUrl, sBody, retAdvplError, retAdvpl) {
         let status = 0;
         let status_text = '';
         EasyFetch( retAdvplError, cUrl, 'PUT', sBody)
         .then( (res) => {
            status = res.status;
            status_text = res.statusText;
            return res.json() 
         })
         .then( (res) => { retAdvpl({status: status, status_text: status_text, response: res}) } )
         .catch((e) => { retAdvplError(e) });
      }

   endcontent

return cVar

/*/{Protheus.doc} intPrtUni
   Executa a integração com portal unico

   @type  Static Function
   @author user
   @since 24/11/2023
   @version version
   @param oEasyJS, objeto, EasyJS
          cUrl, caracter, URL do portal unico da API
          cJson, caracter, JSON de envio
          cErros, caracter, variavel de erro
   @return cRet, caracter, retorno da execução
/*/
static function intPrtUni(oEasyJS, cOperacao, cUrl, cJson, cErros)
   local cRet    := ""
   local cScript := ""

   default cOperacao := ""
   default cUrl      := ""
   default cJson     := ""
   default cErros    := ""

   do case
      case cOperacao == "INSERT_CATALOGO"
         begincontent var cScript
            insertCatalogo('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)
         endcontent

      case cOperacao == "UPDATE_CATALOGO"
         begincontent var cScript
            updateCatalogo('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)
         endcontent

      case cOperacao == "VINCULA_OPERADOR"
         begincontent var cScript
            linkOperador('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)
         endcontent

      case cOperacao == "DESVINCULA_OPERADOR"
         begincontent var cScript
            unlinkOperador('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)
         endcontent

   end case

   oEasyJS:runJSSync( cScript ,{|x| cRet := x } , {|x| cErros := x } )

return cRet
