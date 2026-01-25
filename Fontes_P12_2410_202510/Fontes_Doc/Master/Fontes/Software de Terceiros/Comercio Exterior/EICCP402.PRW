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
#define REG_MARCA   "REG_MARCA"
#define MARCA       "X"
#define limiteInt            100

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
      oStep3:SetConstruction({|oPanel| ViewProc(oPanel, cAmbPortal, cUrlPortal, @oBrwProc, nCount), if( oBrwProc <> nil, oBrwProc:oBrowse:Refresh(.T.), nil) })
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
              STR0012 + ENTER + ENTER + ; // "Serão listados os Catálogos de Produtos passíveis de integração, ou seja, com os status Pendente de Registro', 'Pendente de Retificação' e 'Registrado (pendente: fabricante/ país)'."
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
   local cFieldMark := REG_MARCA
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
              
   default cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") 
   default cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))

   if oMarkBrow == nil
      aRotina := {} 

      aStruct := (cAliasTmp)->(dbStruct())
      for nCpo := 1 To Len(aStruct)
         if !(aStruct[nCpo][1] $ (cFieldMark + "||RECEK9||STATUS||RETORNO||EK9_STATUS" ))
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
            aadd(aFieldFilter, {aStruct[nCpo][1], aStruct[nCpo][1], aStruct[nCpo][2], aStruct[nCpo][3], aStruct[nCpo][4], nil})
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
      oMarkBrow:SetMark( cMarca, cAliasTmp, cFieldMark )
      aCores := CP400Cores(aCoresNum)
      For nL := 1 To Len( aCores )   	    
            oMarkBrow:AddLegend( aCores[nL][1], aCores[nL][2], aCores[nL][3] )
      Next nL
      oMarkBrow:SetFieldMark( cFieldMark )
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
          nCount, numérico, quantidade de registros para integração
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewProc(oPanel, cAmbPortal, cUrlPortal, oBrowProc, nCount)
   local lRet       := .T.
   local oProc      := nil
   local cMsgError  := ""
   local cMsgSoluc  := ""

   default cAmbPortal := EasyGParam("MV_EIC0074",.F.,"1") 
   default cUrlPortal := if( cAmbPortal == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br"))
   default nCount     := 0

   BrowseProc(oPanel, cAmbPortal, cUrlPortal, @oBrowProc)
   oProc := MsNewProcess():New({|lEnd| lRet := PrcIntCt(@lEnd, @oBrowProc, @oProc, nCount, @cMsgError, @cMsgSoluc),oBrowProc:Refresh()}, STR0040 + "...",,.T.) // ""Integrando o catálogo de produto"
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
   local cFieldMark := REG_MARCA
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}
   Local aFieldFilter := {}
   Local aSeek      := {}
   local oLayer     := nil
   local cLib       := ""
   local cTexto     := ""
   local oPnlBrowse := nil

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
            aColumns[Len(aColumns)]:SetDoubleClick({|| EECView((cAliasTmp)->RETORNO, STR0023,,,,,.T.) }) // "Mensagem"
         elseif !(aStruct[nCpo][1] $ cFieldMark + "||RECEK9||STATUS||EK9_STATUS" )
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
         endif

         if !(aStruct[nCpo][1] $ cFieldMark + "||RECEK9||STATUS||EK9_STATUS" )
            aadd(aFieldFilter, {aStruct[nCpo][1], aStruct[nCpo][1], aStruct[nCpo][2], aStruct[nCpo][3], aStruct[nCpo][4], nil})
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
      oBrowProc:oBrowse:SetFilterDefault(cFieldMark + " <> ' ' ") //Indica o filtro padrão do Browse
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
   local cFieldMark := REG_MARCA
   local cMarca     := MARCA
   local nRecno     := 0

   default cOpcao     := "H"

   if cOpcao == "H"
      cOpcao := if( empty((cAliasTmp)->&(cFieldMark)), "M", "D" )
   endif

   nRecno := (cAliasTmp)->(recno())
   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())
      Reclock(cAliasTmp, .F.)
      (cAliasTmp)->&(cFieldMark) := if( cOpcao == "M", cMarca, " ")
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
   local cFieldMark := REG_MARCA
   local nRecno     := 0

   default cStep      := ""

   do case
      case cStep == "1" // Introdução

      case cStep == "2" // Grid de catalogos

         nRecno := (cAliasTmp)->(recno())
         (cAliasTmp)->(dbGoTop())
         do while (cAliasTmp)->(!eof())
            lRet := !empty((cAliasTmp)->&(cFieldMark))
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
   local cFieldMark := REG_MARCA

   default oEasyTmp := EasyTemporaryTable():new()

   aSemSX3 := {}
   aAdd(aSemSX3, {"STATUS"     , "C"                                  , 01                                      , 0                                        })
   aAdd(aSemSX3, {cFieldMark   , "C"                                  , 01                                      , 0                                        })
   aAdd(aSemSX3, {"EK9_COD_I"  , getSX3Cache( "EK9_COD_I", "X3_TIPO") , getSX3Cache( "EK9_COD_I", "X3_TAMANHO") , getSX3Cache( "EK9_COD_I", "X3_DECIMAL")  })
   aAdd(aSemSX3, {"EK9_IDPORT" , getSX3Cache( "EK9_IDPORT", "X3_TIPO"), getSX3Cache( "EK9_IDPORT", "X3_TAMANHO"), getSX3Cache( "EK9_IDPORT", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_VATUAL" , getSX3Cache( "EK9_VATUAL", "X3_TIPO"), getSX3Cache( "EK9_VATUAL", "X3_TAMANHO"), getSX3Cache( "EK9_VATUAL", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_CNPJ"   , getSX3Cache( "EK9_CNPJ", "X3_TIPO")  , getSX3Cache( "EK9_CNPJ", "X3_TAMANHO")  , getSX3Cache( "EK9_CNPJ", "X3_DECIMAL")   })
   aAdd(aSemSX3, {"EK9_NCM"    , getSX3Cache( "EK9_NCM", "X3_TIPO")   , getSX3Cache( "EK9_NCM", "X3_TAMANHO")   , getSX3Cache( "EK9_NCM", "X3_DECIMAL")    })
   aAdd(aSemSX3, {"EK9_PRDREF" , getSX3Cache( "EK9_PRDREF", "X3_TIPO"), getSX3Cache( "EK9_PRDREF", "X3_TAMANHO"), getSX3Cache( "EK9_PRDREF", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_DESC_I" , getSX3Cache( "EK9_DESC_I", "X3_TIPO"), getSX3Cache( "EK9_DESC_I", "X3_TAMANHO"), getSX3Cache( "EK9_DESC_I", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_STATUS" , getSX3Cache( "EK9_STATUS", "X3_TIPO"), getSX3Cache( "EK9_STATUS", "X3_TAMANHO"), getSX3Cache( "EK9_STATUS", "X3_DECIMAL") })      
   aAdd(aSemSX3, {"RETORNO"    , "M"                                  , 250                                     , 0                                        })
   aAdd(aSemSX3, {"RECEK9"     , "N"                                  , 10                                      , 0                                        })

   aIndex := {}
   aAdd(aIndex, "EK9_COD_I" )
   aAdd(aIndex, "EK9_NCM+EK9_IDPORT+EK9_VATUAL" )
   aAdd(aIndex, "EK9_PRDREF" )
   aAdd(aIndex, "STATUS" )
   aAdd(aIndex, "EK9_STATUS" )
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
   local cFieldMark := REG_MARCA
   local cMarca     := MARCA
   local cInformix  := if(TcGetDB()=="INFORMIX", " AS ","")
   local cEK9       := RetSqlName("EK9") + cInformix 

   default oEasyTmp   := EasyTemporaryTable():new()
   default nCount     := 0

   oEasyTmp:ClearTmp(cAliasTmp)

   cQuery := " SELECT "
   cQuery +=  " EK9_STATUS,"
   cQuery +=  " EK9_FILIAL, "
   cQuery +=  " EK9_COD_I, "
   cQuery +=  " EK9_IDPORT, "
   cQuery +=  " EK9_VATUAL, "
   cQuery +=  " EK9_CNPJ, "
   cQuery +=  " EK9_NCM, "
   cQuery +=  " EK9_PRDREF, "
   cQuery +=  " EK9_DESC_I, "
   cQuery +=  " EK9.R_E_C_N_O_ " + cInformix + " RECEK9 "
   cQuery += " FROM " + cEK9 + " EK9 "
   cQuery += " WHERE EK9.EK9_FILIAL = ? "
   cQuery += " AND EK9.EK9_STATUS IN(?) "
   cQuery += " AND EK9.EK9_MODALI = ? "
   cQuery += " AND EK9.D_E_L_E_T_ = ? "
   cQuery += " ORDER BY EK9_COD_I "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1, xFilial("EK9") ) // EK9_FILIAL
   oQuery:SetIn(2, {PENDENTE_REGISTRO, PENDENTE_RETIFICACAO, REGISTRADO_PENDENTE_FAB_PAIS} ) // EK9_STATUS
   oQuery:SetString(3, '1' ) // EK9_MODALI
   oQuery:SetString(4, ' ' ) // D_E_L_E_T_
   cQuery := oQuery:GetFixQuery()
   FwFreeObj(oQuery)

   cAliasQry := GetNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   
   while (cAliasQry)->(!eof())
      lRet := .T.
      nCount += 1

      reclock(cAliasTmp, .T.)
      (cAliasTmp)->EK9_COD_I := (cAliasQry)->EK9_COD_I
      (cAliasTmp)->EK9_IDPORT := (cAliasQry)->EK9_IDPORT
      (cAliasTmp)->EK9_VATUAL := (cAliasQry)->EK9_VATUAL
      (cAliasTmp)->EK9_CNPJ := (cAliasQry)->EK9_CNPJ
      (cAliasTmp)->EK9_NCM := (cAliasQry)->EK9_NCM
      (cAliasTmp)->EK9_PRDREF := (cAliasQry)->EK9_PRDREF
      (cAliasTmp)->EK9_DESC_I := (cAliasQry)->EK9_DESC_I
      (cAliasTmp)->EK9_STATUS := (cAliasQry)->EK9_STATUS
      (cAliasTmp)->RECEK9 := (cAliasQry)->RECEK9
      (cAliasTmp)->&(cFieldMark) := " "

      if nRecEK9 == (cAliasTmp)->RECEK9
         (cAliasTmp)->&(cFieldMark) := cMarca
         nRecAlias := (cAliasTmp)->(recno())
      endif
      (cAliasTmp)->STATUS := INICIO
      (cAliasTmp)->RETORNO := ""

      (cAliasTmp)->(msUnLock())

      (cAliasQry)->(dbSkip())
   end 

   if nCount == 1
      (cAliasTmp)->&(cFieldMark) := cMarca
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
   local cFieldMark := REG_MARCA
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
      elseif aStruct[nCpo][1] == "RETORNO"
         oExcel:AddColumn(cWorksheet, cTable, STR0038 ) // "Retorno do processamento"
      elseif !(aStruct[nCpo][1] $ cFieldMark + "||RECEK9")
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
         elseif aStruct[nCpo][1] == "RETORNO"
            aAdd( aRow, (cAliasTmp)->&(aStruct[nCpo][1]) )
         elseif !(aStruct[nCpo][1] $ cFieldMark + "||RECEK9")
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
          nCount, numérico, quantidade de registros para integração
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
static function PrcIntCt(lEnd, oBrowProc, oProc, nCount, cMsgError, cMsgSoluc)
local lRet       := .F.
local aCatalogo  := {}
local aCat6      := {}
local aCatInt    := {}
local aOEint     := nil
local aRetInt    := {}
local aEntidade  := {}
local aCatIntOK  := {}
local oEasyJS    := nil
local lCancelou  := .F.
local cURLPortal := AVGetUrl(,, @lCancelou, "EIC")
local cAliasTmp  := ""
local nRecnoTmp  := 0

default cMsgError  := ""
default cMsgSoluc  := ""

if !lCancelou

   oEasyJS := EasyJS():New()
   lRet := setOEasyJs(@oEasyJS, cUrlPortal, @cMsgError, @cMsgSoluc)
   if lRet
      oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplError);", {|x| lRet := RetAut(x, @cMsgError, @cMsgSoluc) }, { |x| lRet := RetAut(x, @cMsgError, @cMsgSoluc) } ) //Executando um javascript de forma Síncrona
   endif

   if lRet
      oProc:SetRegua2(10)
      oProc:IncRegua2() // "Validando atributos"
      aCatalogo := VldAtr(lEnd, oBrowProc, oProc, nCount,@aCat6) //valida se tem atributos obrigatórios não preenchidos
      oProc:IncRegua2()
      IncOE(lEnd, oBrowProc, oProc, len(aCatalogo),aCatalogo) //inclui os operadores estrangeiros dos catálogos válidos
      oProc:IncRegua2()
      aOEint := getOpInt(aCatalogo,@aEntidade) //traz os operadores estrangeiros dos catálogos válidos que devem ser integrados no portal único
      if !empty(aOEint) 
         OE400Integrar(aOEint,.T.,,oEasyJs,,oProc,@aRetInt,.t.) //integra os operadores estrangeiros    
         oProc:IncRegua2()
         AtuInt(aRetInt,aEntidade,oBrowProc) //atualiza a tela do browse com os resultaodos ocorridos na integração dos operadores estrangeiros com sucesso
         oProc:IncRegua2()
      EndIF  
      aEntidade := {} 
      aCatInt := getCatInt(oProc,@aEntidade)
      oProc:IncRegua2()
      if !Empty(aCatInt)          
         aRetInt := {}
         CP402Integrar(aCatInt,.T.,oProc,@aRetInt,oEasyJs,cUrlPortal) //integra os catálogos de produtos
         oProc:IncRegua2()
         aCatIntOK := AtuInt(aRetInt,aEntidade,oBrowProc) //atualiza a tela do browse com os resultaodos ocorridos na integração dos operadores estrangeiros ou com sucesso e retorna um array com os catálogos de produtos integrados com sucesso                 
      Endif   
      oProc:IncRegua2()
      aRetInt := {} 
      getEKD6(@aCatIntOK,aCat6) //adiciona os catálogos com status 6 para serem processados posteriormente
      oProc:IncRegua2()
      CP402IFbPO(oProc, oEasyJS, cUrlPortal, aCatIntOK,@aRetInt,oBrowProc) //integra a vinculação/desvinculaçaõ dos operador estrangeiro ao catálogo      
      oProc:IncRegua2(STR0092) //Operação finalizada
   endif

   if oEasyJS <> nil
      oEasyJS:Destroy()
   EndIf
endif

if !lRet
   cAliasTmp := CP402_TABLE
   nRecnoTmp := (cAliasTmp)->(recno())
   (cAliasTmp)->(dbGoTop())
   (cAliasTmp)->(dbEval({||,;
         (cAliasTmp)->RETORNO := STR0098,; // "Processamento cancelado."
         (cAliasTmp)->STATUS := WARNING,;
        }))
   (cAliasTmp)->(dbGoTo(nRecnoTmp))
endif

return lRet

/*/{Protheus.doc} RetAut
   Função para validar a autenticação no portal único

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param cRetorno, caracter, retorno da autenticação
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function RetAut(cRetorno, cMsgError, cMsgSol)
   local lRet       := .F.
   local nPos       := 0

   default cRetorno  := ""

   lRet := alltrim(cRetorno) == 'AUTENTICADO_OK'

   if !lRet
      nPos := at("O token gerado deve ser reaproveitado", cRetorno)
      cMsgError := if( nPos > 0 , substr(cRetorno, 1, nPos-1), cRetorno)
      cMsgSol := if( nPos > 0 , STR0101, "") // "Realize a integração novamente após 60 segundos."

      nPos := at("Failed to fetch", cRetorno)
      if nPos > 0
         cMsgError := STR0099 // "Falha de autenticação"
         cMsgSol := STR0100 // "Verifique o certificado selecionado para a integração com o Portal Único."
      endif
   endif

return lRet

/*/{Protheus.doc} VldAtr
   Função para realizar a integração do catálogo de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
          nCount, numérico, quantidade de registros para integração
          aCat6, array onde serão incluídos os registros com status = 6 para posterior processamento
   @return lRet, array com os códigos dos catálogos de produtos validados
   @example
   (examples)
   @see (links_or_references)
/*/
static function VldAtr(lEnd, oBrowProc, oProc, nCount,aCat6)
   local cAliasTmp  := CP402_TABLE
   local nRecno     := 0
   local nIncProc   := 0
   local cMsg := ''
   local lRetExec := nil
   local aCatOK := {}

   default nCount     := 0

   oProc:SetRegua1(nCount)
   
   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())
      
      nRecno := (cAliasTmp)->(recno())
      oProc:IncRegua1(CP402getEt("1") + STR0042 + " " + (cAliasTmp)->EK9_COD_I) // "Validando atributos"
      nIncProc += 1

      if (cAliasTmp)->EK9_STATUS == REGISTRADO_PENDENTE_FAB_PAIS
         aadd(aCat6,(cAliasTmp)->EK9_COD_I)
      Endif
      lRetExec := CP400AtrValid( (cAliasTmp)->EK9_COD_I, (cAliasTmp)->EK9_VATUAL, @cMsg )
      Reclock(cAliasTmp,.F.)
      
      (cAliasTmp)->RETORNO := '- ' + if(lRetExec,STR0041,cMsg) + ENTER // Atribtutos validados com sucesso                                                       
                                                         //'Existem atributos que não foram preenchidos." ### "Atenção" #### "Para prosseguir com a integração, todos os atributos obrigatórios devem ser preenchidos."'
      (cAliasTmp)->STATUS := if(lRetExec, OK, ERRO)
      (cAliasTmp)->(msUnLock())
      if lRetExec  
         aadd(aCatOK,(cAliasTmp)->EK9_COD_I)
      endIf   

      oBrowProc:Refresh()

      (cAliasTmp)->(dbGoTo(nRecno))
      (cAliasTmp)->(dbSkip())
   end 

return aCatOK

/*/{Protheus.doc} IncOE
   Função para realizar a inclusão dos operadores estrangeiros dos processos válidos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
          nCount, numérico, quantidade de registros para integração
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
static function IncOE(lEnd, oBrowProc, oProc, nCount, aCatalogo)
local aOperador := nil
local lRet := .t.
   aOperador := getOperador(aCatalogo) //traz os operadores estrangeiros dos catálogos válidos que ainda não estão cadastrados no sistema
   execOperador(lEnd, oBrowProc, oProc, len(aOperador), @aOperador) //gera o execauto da inclusão dos operadores estrangeiros dos catálogos válidos que ainda não estão cadastrados no sistema
return lRet


/*/{Protheus.doc} getOperador
   Função para trazer os operadores estrangeiros que dos catálogos válidos que ainda não estão cadastrados no sistema
   @type  Static Function
   @author user
   @since 31/01/2025
   @version version
   @param aCatalogo catálogos que devem ser verificados os operadores estrangeiros
   @return aOperador, array com os operadores que devem ser cadastros no sistema
   @example
   (examples)
   @see (links_or_references)
/*/
static function getOperador(aCatalogo)
local cQuery := nil
local oQuery     := nil
local cAliasTmpOE  := GetNextAlias()
local aOperador := {}
local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
local cEKB := RetSqlName('EKB') + cInformix
local cEK9 := RetSqlName('EK9') + cInformix
local cEKJ := RetSqlName('EKJ') + cInformix
if !empty(aCatalogo)
   cQuery := "SELECT EKB.EKB_CODFAB,EKB.EKB_LOJA, EK9.EK9_IMPORT,EK9.EK9_CNPJ, EK9.EK9_COD_I, COALESCE(EKJ.EKJ_FORN, ' ') " + cInformix + " EKJ_FORN "
   cQuery += "FROM " + cEKB + " EKB LEFT JOIN " + cEK9 + " EK9 ON EKB.EKB_COD_I = EK9.EK9_COD_I AND EKB.EKB_FILIAL = EK9.EK9_FILIAL AND EK9.D_E_L_E_T_ = ?"
   cQuery += "                      LEFT JOIN " + cEKJ + " EKJ ON EKJ.EKJ_FORN = EKB_CODFAB AND EKJ_FOLOJA = EKB.EKB_LOJA AND EKJ.EKJ_FILIAL = EKB.EKB_FILIAL AND  EKJ.EKJ_CNPJ_R = EK9.EK9_CNPJ AND EKJ.D_E_L_E_T_ = ?"
   cQuery += " WHERE "
   cQuery += " EKB.EKB_FILIAL = ? "
   cQuery += " AND  "
   cQuery += " EKB.EKB_COD_I IN( ? ) "
   cQuery += " AND  "
   cQuery += " EKB.D_E_L_E_T_ = ? "
   cQuery += " AND  "
   cQuery += " EKB.EKB_CODFAB > ? "
   cQuery += " GROUP BY EKB.EKB_CODFAB,EKB.EKB_LOJA,EK9.EK9_IMPORT,EK9.EK9_CNPJ, EK9.EK9_COD_I, EKJ.EKJ_FORN "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:setString(1,' ')
   oQuery:setString(2,' ')
   oQuery:setString(3, xFilial('EKB'))
   oQuery:setIn( 4 , aCatalogo )
   oQuery:setString(5,' ')
   oQuery:setString(6,' ')

   cQuery := oQuery:GetFixQuery()

   MPSysOpenQuery(cQuery, cAliasTmpOE)
   
   fwFreeObj(oQuery)
   (cAliasTmpOE)->(DBGOTOP())
   DO WHILE (cAliasTmpOE)->(!EOF())      
      if Empty((cAliasTmpOE)->EKJ_FORN)                                                                       //Status  //mensagem retorno da integração
         aadd(aOperador,{(cAliasTmpOE)->EK9_COD_I,(cAliasTmpOE)->EKB_CODFAB,(cAliasTmpOE)->EKB_LOJA, (cAliasTmpOE)->EK9_IMPORT,(cAliasTmpOE)->EK9_CNPJ,'',''})
      EndIf   
      (cAliasTmpOE)->(dbskip())
   Enddo
EndIf
Return aOperador

/*/{Protheus.doc} execOperador
   Função para gerar o execauto da inclusão dos operadores estrangeiros dos catálogos válidos que ainda não estão cadastrados no sistema
   @type  Static Function
   @author user
   @since 31/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
          nCount, numérico, quantidade de registros para integração   
   @return aOperador, array com os operadores que devem ser cadastros no sistema
   @example
   (examples)
   @see (links_or_references)
/*/
static function execOperador(lEnd, oBrowProc, oProc, nCount, aOperador)
local aOEexecAuto := nil
local nOEprocessado := nil
local aOEprocessado := {}
local i,y := nil
local cMsg:=''
local cAliasTmp := CP402_TABLE
local aLog := {}
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
oProc:SetRegua1(nCount)
(cAliasTmp)->(dbSetOrder(1))
for i:=1 to nCount
   if (nOEprocessado := aScan(aOEprocessado, {|x| x[1] == aOperador[i][5] + aOperador[i][2] + aOperador[i][3] })) == 0    
      aOEexecAuto := {}      
      oProc:IncRegua1(CP402getEt("2") + STR0043 + " " + aOperador[i][5]) // "Incluindo operador estrangeiro"
      aadd(aOEexecAuto,{"EKJ_FILIAL", xFilial("EKJ")  ,nil})
      aadd(aOEexecAuto,{"EKJ_IMPORT", aOperador[i][4] , nil}) 
      aadd(aOEexecAuto,{"EKJ_CNPJ_R", aOperador[i][5] ,nil}) 
      aadd(aOEexecAuto,{"EKJ_FORN"  , aOperador[i][2] ,nil}) 
      aadd(aOEexecAuto,{"EKJ_FOLOJA", aOperador[i][3] ,nil}) 
      lMsErroAuto := .F.
      MsExecAuto({|x,y| EICOE400(x,y) },aOEexecAuto, 3)
      if lMsErroAuto         
         aLog        := GetAutoGrLog()
         for y := 1 to len(aLog)
            cMsg += Alltrim(aLog[y]) + ENTER
         Next
      EndIf
      aOperador[i][6] := if(lMsErroAuto,WARNING,OK)   
      aOperador[i][7] := '- ' + if(lMsErroAuto,cMSg,STR0052 + ": " +  alltrim(aOperador[i][2]) + '-' + alltrim(aOperador[i][3]) )  //"Operador estrangeiro incluído com sucesso" 
      aadd(aOEprocessado,{aOperador[i][5] + aOperador[i][2] + aOperador[i][3], aOperador[i][6],aOperador[i][7]})                                          
   else 
      aOperador[i][6] := aOEprocessado[nOEprocessado][2] 
      aOperador[i][7] := aOEprocessado[nOEprocessado][3] 
   EndIf   
   setMsgOperador(aOperador[i])
next

Return


/*/{Protheus.doc} setMsgOperador
   Função para atualizar o status e mensagens da execução da inclusão do operador estrangeiro
   @type  Static Function
   @author user
   @since 04/02/2025
   @version version
   @param aOperador - Array com os operadores estrangeiros ou catálogos ou vinculação do operador estrangeiro ao catálogo
           lFabPai, indica se está processando a vinculaçao do operador estrangeiro ao catálogo
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Static function setMsgOperador(aOperador,lFabPais)
local cAliasTmp := CP402_TABLE
local nDif := nil
Default lFAbPAis := .f.
   nDif := if(lFabPais,3,0)
   if (cAliasTmp)->(dbSeek(aOperador[1+nDif])) 
      Reclock(cAliasTmp,.F.)
      if aOperador[6] == ERRO .or. empty((cAliasTmp)->STATUS) .or. (aOperador[6] == WARNING .and. (cAliasTmp)->STATUS == OK)
         (cAliasTmp)->STATUS := aOperador[6]       
      Endif  
      (cAliasTmp)->RETORNO := (cAliasTmp)->RETORNO + ENTER + aOperador[7] + ENTER
      (cAliasTmp)->(msUnLock())     
   endIf  
return 

/*/{Protheus.doc} getOpInt
   Função para trazer os operadores estrangeiros que dos catálogos válidos que ainda não foram integrados no portal único
   @type  Static Function
   @author user
   @since 31/01/2025
   @version version
   @param aCatalogo catálogos que devem ser verificados os operadores estrangeiros
   @return aEntidade, array com os operadores que devem ser integrados no portal único
   @example
   (examples)
   @see (links_or_references)
/*/
static function getOpInt(aCatalogo,aEntidade,aCatVer)
local cQuery := nil
local oQuery     := nil
local cAliasTmpOE  := GetNextAlias()
local aOEInt := {}
local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
local cEKB := RetSqlName('EKB') + cInformix
local cEK9 := RetSqlName('EK9') + cInformix
local cEKJ := RetSqlName('EKJ') + cInformix
if !empty(aCatalogo)
   cQuery := "SELECT EKJ.R_E_C_N_O_ " + cInformix + " EKJ_RECNO,EKB.EKB_COD_I,EKB.EKB_CODFAB,EKB.EKB_LOJA,EK9.EK9_CNPJ "
   cQuery += " FROM " + cEKB + " EKB " 
   cQuery += " INNER JOIN " + cEK9 + " EK9 ON EKB.EKB_COD_I = EK9.EK9_COD_I AND EKB.EKB_FILIAL = EK9.EK9_FILIAL AND EK9.D_E_L_E_T_ = ? "
   cQuery += " INNER JOIN " + cEKJ + " EKJ ON EKB.EKB_FILIAL = EKJ.EKJ_FILIAL AND EKB.EKB_CODFAB = EKJ.EKJ_FORN AND EKB.EKB_LOJA = EKJ.EKJ_FOLOJA AND EK9.EK9_CNPJ = EKJ.EKJ_CNPJ_R AND EKJ.D_E_L_E_T_ = ? "
   cQuery += " WHERE  
   cQuery += " EKB.EKB_FILIAL = ? " 
   cQuery += " AND " 
   cQuery += " EKB.EKB_COD_I IN( ? ) "
   cQuery += " AND " 
   cQuery += " EKB.D_E_L_E_T_ = ? "
   cQuery += " AND "
   cQuery += " EKB.EKB_CODFAB > ? "
   cQuery += " AND "
   cQuery += " EKJ.EKJ_STATUS <> ?
   cQuery += " AND " 
   cQuery += " EKJ.EKJ_STATUS <> ? " 
   cQuery += " AND "
   cQuery += " EKJ.EKJ_MSBLQL <> ? "
   cQuery += " GROUP BY EKJ.R_E_C_N_O_ ,EKB.EKB_COD_I,EKB.EKB_CODFAB,EKB.EKB_LOJA,EK9.EK9_CNPJ "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:setString(1,' ')
   oQuery:setString(2,' ')
   oQuery:setString(3,xFilial('EKB'))   
   oQuery:setIn(4, aCatalogo )
   oQuery:setString(5,' ')
   oQuery:setString(6,' ')
   oQuery:setString(7,'1')
   oQuery:setString(8,'5')
   oQuery:setString(9,'1')

   cQuery := oQuery:GetFixQuery()

   MPSysOpenQuery(cQuery, cAliasTmpOE)
   
   fwFreeObj(oQuery)
   (cAliasTmpOE)->(DBGOTOP())
   DO WHILE (cAliasTmpOE)->(!EOF())                                                                           //Status  //mensagem retorno da integração
      if aScan(aOEInt,(cAliasTmpOE)->EKJ_RECNO) == 0
         aadd(aOEInt,(cAliasTmpOE)->EKJ_RECNO)
      EndIF   
      aadd(aEntidade,{(cAliasTmpOE)->EKB_COD_I,(cAliasTmpOE)->EKJ_RECNO,(cAliasTmpOE)->EKB_CODFAB,(cAliasTmpOE)->EKB_LOJA,(cAliasTmpOE)->EK9_CNPJ,'','',STR0055})
      (cAliasTmpOE)->(dbskip())
   Enddo
EndIf
Return aOEInt


/*/{Protheus.doc} atuInt
   Função para atualizar a tela com o retorno da integração do operador estrangeiro
   @type  Static Function
   @author user
   @since 06/02/2025
   @version version
   @param aResInt, array com o resultado das integrações
          aEntidade, array com os operadores estrangeiros ou catálogo de produtos
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          lFabPai, indica se está processando a vinculaçao do operador estrangeiro ao catálogo
   @return aCatIntOK - retorna um array com os catálogos de produtos integrados com sucesso
   @example
   (examples)
   @see (links_or_references)
/*/
static function atuInt(aResInt,aEntidade,oBrowProc,lFabPai)   
local ni         := nil
local aCatIntOk := {}   
Default lFabPai := .f.
   aCatIntOk := getResInt(aResInt,@aEntidade,lFabPai) //atualiza no array operadores ou catálogo de produtos o resulatdo da integração
   for ni :=1 to len(aEntidade)
       setMsgOperador(aEntidade[ni],lFabPai)
       oBrowProc:Refresh()      
   next    
return aCatIntOk

/*/{Protheus.doc} getResInt
   Função para atualizar o array aEntidade com o resultado da integração do operador estrangeiro ou do catálogo de produtos
   @type  Static Function
   @author user
   @since 07/02/2025
   @version version
   @param aResInt array com o  resultado da integração dos operadores estrangeiros
          aEntidade array com os operadores estrangeiros ou catálogo de produtro ou fabr pais para vinculaçao ao catálogo
          lFabPai, indica se está processando a vinculaçao do operador estrangeiro ao catálogo
   @return aCatIntOK - retorna um array com os catálogos de produtos integrados com sucesso 
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getResInt(aResInt,aEntidade,lFabPai) 
local ni := nil
local nRes := nil
local aCatIntOk := {}
local nDif1 := if(lFabPai,1,0) 
local nDif2 := if(lFabPai,6,0) 
   for ni:=1 to len(aEntidade)
      if (nRes := aScan(aResInt, {|x| x[6] == aEntidade[ni][2-nDif1] })) > 0    
         aEntidade[ni][6] := if(upper(aResInt[nRes][1])=="TRUE",OK,ERRO)
         aEntidade[ni][7] := '- ' + STR0054 + ' ' + aEntidade[ni][8]+ ' ' + aEntidade[ni][3+nDif2] + '-' + aEntidade[ni][4+nDif2] + ENTER + '- ' + if(aEntidade[ni][6] == OK, STR0057, if(empty(aResInt[nRes][4]),STR0059,STR0080+' '+aResInt[nRes][4])) //integrando ####// Integrado com sucesso// Sem retornov
         if upper(aResInt[nRes][1])=="TRUE"
           aadd(aCatIntOk,aResInt[nRes][6])
         EndIF            
      EndIf   
   next ni   
return aCatIntOk

/*/{Protheus.doc} getCatInt
   Função para retornar os catálogos válidos para integração
   @type  Static Function
   @author user
   @since 11/02/2025
   @version version
   @param aCatInt array com o resultado dos catálgos válidos para  a integração com o portal único
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getCatInt(oProc,aCatGeral)
local aCatInt := {}
local cAliasTmp  := CP402_TABLE
local cVersaoEKD := ''
   oProc:SetRegua1((cAliasTmp)->(Reccount()))
   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())
//oProc:IncRegua1(STR0053 + " " + (cAliasTmp)->EK9_COD_I) // "Agrupando catálogos válidos para a integração      
      if (cAliasTmp)->STATUS == OK .and. (cAliasTmp)->EK9_STATUS # REGISTRADO_PENDENTE_FAB_PAIS
         cVersaoEKD := CPGetVersion(xFilial("EKD"), (cAliasTmp)->EK9_COD_I)
         IF EKD->(dbsetorder(1),DbSeek(xFilial("EKD") + (cAliasTmp)->EK9_COD_I + cVersaoEKD))    
            AADD(aCatGeral,{(cAliasTmp)->EK9_COD_I  ,EKD->(recno()), (cAliasTmp)->EK9_COD_I, cVersaoEKD, '', '', '', STR0056 })                       
            AADD(aCatInt,EKD->(recno()))     
         EndIF   
      EndIF
      (cAliasTmp)->(dbSkip())
   End  
   (cAliasTmp)->(dbGoTop())
return aCatInt


//////////////////////// INÍCIO FUNCOES MOVIDAS DO FONTE EICCP400 ///////////////////////////

/*/{Protheus.doc} CP402Integrar
   Função para realizar a integração do operador estrangeiro com o siscomex
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   @param aCatalogos - array com o recno do catálogo de produtos a ser integrado, se vazio registra o posicionado no browse
          lLote - quando true indica que a integraçaõ será executada em lote
   @return Nil
   /*/
Function CP402Integrar(aCatalogos,lLote,oProc,aRetCat,oEasyJS,cUrlPortal)
   local lRet       := .F.

   default aCatalogos  := {}
   default lLote := .f.
   default oProc := nil

      begin sequence
                  
         if len(aCatalogos) > 0                       
              lRet := CP402Siscomex(@aCatalogos, cURLPortal,lLote,oProc,@aRetCat,oEasyJs)  //"Integração Catálogo de Produto"            
         endif

      end sequence

Return lRet

/*/{Protheus.doc} CP402Siscomex
   Função que realiza a integração com o siscomex para cada item do array aCatalogos
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Static Function CP402Siscomex(aCatalogos, cURLPortal, lLote, oProcess, aRetCat, oEasyJs)
   local lRet       := .F.   
   local lCpoVrsAt  := .F.
   local nTotCat    := 0
   local cURLCat    := ""
   local cErros     := ""
   local cRet       := ""
   local cJson      := ""
   local ni:= 0
   local nForF := 0
   local nFor  := 0  
   local cLogIni    := ""
   local cLogInteg  := ""
   local lIntgProd  := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   
   cLogIni += STR0084 + if(lIntgProd, STR0015, STR0016) + ENTER // "Integração realizada no ambiente de " ### "Produção." #### "Treinamento."
   cLogIni += dToc(Date()) +  " - " + Time() + " - " + STR0085 + UsrFullName(retCodUsr()) + ENTER + ENTER // "Usuário do sistema: "
   cLogIni += STR0086 + ": " + ENTER + ENTER // "Detalhes da Integração"
   cLogIni += Time() + " - " + STR0087 + ENTER + ENTER  // "Início do processamento de integração do Catálogo de Produtos"
   cLogIni += Time() + " - " + STR0088 + ENTER // "Acessando certificado digital"


   default aCatalogos  := {}
   default lLote := .f.

   begin sequence

      EKE->(dbsetorder(1))
      EK9->(dbsetorder(1))

      lCpoVrsAt := EKD->(ColumnPos("EKD_VATUAL")) > 0
    
      nTotCat := len(aCatalogos)
      oProcess:SetRegua1(nTotCat)
      cURLCat := "/catp/api/ext/produto"

      // percorre o array de catálogos a serem intregados
      nForF := int(nTotCat / limiteInt) + if( nTotCat % limiteInt > 0, 1, 0)     
      for nFor := 1 to nForF   
         oProcess:IncRegua1(CP402getEt("4") + STR0064 ) // "Integrando catálogo de produtos
         cLogInteg := ''        
         nSeq := 0      
         cRet := ''
         cJson := '['
         for ni:= 1+((nFor-1)*limiteInt) to if(limiteInt * nFor > nTotCat, nTotCat, limiteInt * nFor)    
            nSeq += 1             
            cJson += getJsonCatProd(aCatalogos[ni],lLote,nSeq)  
         next ni
         cJson += ']'
         lRet := comex.generics.validJson(cJson) 
         
         if !lREt 
            cLogInteg += Time() + " - " + STR0089 + ENTER // "Mensagem de envio incorreta."
            cLogInteg += ENTER + Time() + " - " + STR0075 + cJson + ENTER // "Mensagem de envio: "                                        
         EndIf             

         if lRet .and. cJson # '[]' .and. !empty(cJson) .and. cErros <> "Failed to fetch" .and. cErros <> STR0062 
            cRet := intCatalogo(oEasyJS, @cErros, (cURLPortal+cURLCat), cJson)
         EndIf           

         retCatProd(cRet, @aRetCat, aCatalogos, nFor, nSeq, cErros, cLogIni + ENTER + cLogInteg, cJson, lRet) 
    
      next nFor
      setEK9_EKD(aRetCat,aCatalogos)
      
   end sequence
   
return lRet

Static function getJsonCatProd(aCatalogo,lLote,nSeq) //REMOVER
local nREcEKD := nil
local cJson := "" 
   nRecEKD := aCatalogo
   EKD->(dbgoto(nRecEKD))
   if EKD->EKD_STATUS $ "2|4|5" .or. lLote  
      EK9->(DbSeek(xFilial("EK9")+EKD->EKD_COD_I))
      cJson := if(nSeq <> 1, ',','') + JsonCatProd(nSeq) 
   EndIF
Return cJson

/*/{Protheus.doc} JsonCatProd
   Criação do json para o catalogo de produto

   @type  Static Function
   @author user
   @since 21/08/2023
   @version 1.0
   @param nenhum
   @return cJson, caractere, mensagem json do catalogo de produto
/*/
static function JsonCatProd(nSeq)
   local cJson      := ""
   local cModal     := "AMBOS"
   local cDenomi    := ""
   local cAtributos := ""
   local cChaveEKE  := ""
   local nContCP    := 0
   local cCodIntern := ""
   local lSeekEKE   := .F.
   local cDscCom    := ""

   Private cIntCpfCnpj

   cModal := if( EKD->EKD_MODALI == "1", "IMPORTACAO", if(EKD->EKD_MODALI == "2",  "EXPORTACAO", "AMBOS")) // =Importacao // =Exportacao // =Ambos
   cChaveEKE := xFilial("EKE") + EKD->EKD_COD_I + EKD->EKD_VERSAO
   lSeekEKE := EKE->(dbSeek(cChaveEKE))

   // Monta o texto do json para a integração
   //cJson := '[{ "seq": '                 + "1"                    + ' ,'
   cJson := '{ "seq": '                 + alltrim(str(nSeq))                    + ' ,'
   // opcional, caso esteja em branco é inclusão e não deve ser enviado, depois de preenchido é alteração
   if !empty(EKD->EKD_IDPORT)
      cJson += ' "codigo": "'             + EKD->EKD_IDPORT        + '" ,'
   endif

   // Na integração do catalogo a versão ficará preenchida somente quando houve alteração dos produto de referencia, pois o portal unico entende que não é passivo de retificação
   if !empty(EKD->EKD_VATUAL) .and. lSeekEKE
      cJson += ' "versao": "'             + alltrim(EKD->EKD_VATUAL)        + '" ,'
   endif

   cDenomi := Posicione("SB1", 1, if(CP400MultF(), EK9->EK9_FILORI, XFILIAL("SB1")) + EK9->EK9_PRDREF, "B1_DESC")
   if getSX3Cache("EK9_DESC_I","X3_CONTEXT") <> "V" .And. !Empty(EK9->EK9_DESC_I)
      cDenomi := EK9->EK9_DESC_I
   endif
   cDenomi := comex.generics.SetStringJson(cDenomi)

   cDscCom := ""
   if !empty(EK9->EK9_DSCCOM)
      cDscCom := comex.generics.SetStringJson(EK9->EK9_DSCCOM)
   endif

   cIntCpfCnpj := EKD->EKD_CNPJ
   If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICCP400_INTEGRAR"),)

   cJson += if( !empty(cDscCom), ' "descricao": "' + cDscCom               + '",', '') + ;
               ' "denominacao": "'                 + cDenomi               + '",' +;
               ' "cpfCnpjRaiz": "'                 + cIntCpfCnpj           + '",' + ;
               ' "situacao": "'                    + "ATIVADO"             + '",' + ;
               ' "modalidade": "'                  + cModal                + '",' + ;
               ' "ncm": "'                         + Alltrim(EKD->EKD_NCM) + '"'

   cAtributos := getJsonAtt()
   cJson += if( !empty(cAtributos), ", " + cAtributos, "") //Retorna os atributos montados no formato json para a integração do catálogo

   // percorre a lista de código relacionados que são enviados em lista
   if lSeekEKE
      cCodIntern := ', "codigosInterno": [ '
      while EKE->(!eof()) .and. EKE->(EKE_FILIAL+EKE_COD_I+EKE_VERSAO) == cChaveEKE
         nContCP++
         cCodIntern += if( nContCP > 1, ',', '')
         cCodIntern += '"' + allTrim(EKE->EKE_PRDREF) + '"'
         EKE->(dbskip())
      enddo
      cCodIntern += ']'
      cJson += cCodIntern
   endif
   //cJson += '}]'
   cJson += '}'

return cJson

/*
Função     : getJsonAtt
Objetivo   : Monta o json com todos os atributos do catálogo, tratados por Atributos, Atributos Multi Valorados e Atributos Compostos.
Parâmetro  : 
Retorno    : Retorna json montado com os atributos.
Autor      : THTS - Tiago Tudisco
Data/Hora  : Fevereiro/2023
Obs.       :
*/
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

if (cAliasAtt)->(!Eof())
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
Return cJsonAtt

/*/{Protheus.doc} intOperador
   Executa a integração do Catalogo de Produto

   @type  Static Function
   @author user
   @since 24/11/2023
   @version version
   @param oEasyJS, objeto, EasyJS
          cErros, caracter, variavel de erro
          cUrl, caracter, URL do portal unico da API
          cJson, caracter, JSON de envio
   @return cRet, caracter, retorno da execução
/*/
static function intCatalogo(oEasyJS, cErros, cUrl, cJson)
   local cRet    := ""
   local cScript := ""

   begincontent var cScript

      intCatalogo('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)

   endcontent

   oEasyJS:runJSSync( cScript ,{|x| cRet := x } , {|x| cErros := x } )

return cRet

/*/{Protheus.doc} retCatProd
   Tratamento para o retorno da integração do catalogo de produto

   @type  Static Function
   @author user
   @since 21/08/2023
   @version 1.0
   @param cRetJson, caractere, retorno obtido do portal unico
          cErros, caractere, mensagem de validação
          aDados, vetor, array com as informações extraídas
   @return lRet, logico, .T. com sucesso e .F. com falha
/*/
static function retCatProd(cRetJson, aRetCat, aCatalogos, nFor, nSeq, cErros, cLogInteg,cJsonEnvio,lJEnvioOk)
   local lAtuErr    := .F.
   local lRet       := .F.
   local cRetorno   := ""
   local oJson      := nil
   local xRetJson   := nil
   local aJsonRet   := {}
   local cSucesso   := ""
   local cCodigo    := ""
   local cVersao    := ""
   local aJsonErros := {}
   local nErros     := 0
   local nje        := 0
   local cStrJson   := ''
   local aJsonEnvio := {}
   local cEnvio     := ''
   local oJsonEnvio := nil
   local oJsonResponse:= nil
   local oJsonError := nil
   local aGetNcmMod := {}
   local cMsgRetErr := ""
   local lIndEKD    := .F.

   default cRetJson   := ""
   default cErros     := ""
   
   if lJEnvioOk
      cEnvio     := '{"items":'+cJsonEnvio+'}'
      oJsonEnvio := JsonObject():New()
      xRetJson := oJsonEnvio:FromJson(cEnvio)
      if xRetJson == nil
         aJsonEnvio := oJsonEnvio:GetJsonObject("items")
   
         //mensagem de retorno do json de envio
         if !empty(cRetJson)
            oJsonResponse := JsonObject():New()
            xRetJson := oJsonResponse:FromJson(cRetJson)
            if xRetJson == nil
               cRetJson := oJsonResponse['response']

               if oJsonResponse['status'] <> 200
                  oJsonError:= JsonObject():New()
                  oJsonError:FromJson(cRetJson)
                  cErros:= oJsonError['message']
                  cRetJson:= ""
                  FwFreeObj(oJsonError)
               endIf
            endif
            FwFreeObj(oJsonResponse)
         endif

      endif
      FwFreeObj(oJsonEnvio)
   EndIf

   // Pega o retorno e converte para json para extrair as informações
   if !empty(cRetJson) .and. empty(cErros)
      lIndEKD := AvExisteInd({{"EKD","3"}}) 
      lRet := .T.
      cRetorno := '{"items":'+cRetJson+'}'
      oJson := JsonObject():New()
      xRetJson := oJson:FromJson(cRetorno)
      cErros := if( !valtype(xRetJson) == "U", STR0065 + ENTER + ENTER + cRetJson + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
      if empty(cErros)
         cErros := if( valtype(oJson:GetJsonObject("items")) == "A", "", STR0066 + ENTER ) // "Arquivo de retorno sem itens!"
         if empty(cErros)
            aJsonRet := oJson:GetJsonObject("items")
            if len(aJsonRet) > 0
               for nje := 1 to len(aJsonRet)
                  cSucesso := aJsonRet[nje]:GetJsonText("sucesso")
                  cCodigo := aJsonRet[nje]:GetJsonText("codigo")
                  cVersao :=  AvKey(aJsonRet[nJe]:GetJsonText("versao"),"EK9_VATUAL")               
                  cStrJson := ENTER + Time() + " - " + STR0067 + ": " + aJsonRet[nje]:ToJson() + ENTER// "Mensagem de retorno"
                  aJsonErros := if( valtype(aJsonRet[nje]:GetJsonObject("erros")) == "A", aJsonRet[nJe]:GetJsonObject("erros"), if( valtype(aJsonRet[nJe]:GetJsonObject("error")) == "C" , aJsonRet[nJe]:GetJsonObject("error_description"), {}))

                  if len(aJsonErros) > 0
                     cErros := if( valtype(aJsonRet[nje]:GetJsonObject("error")) == "C", aJsonRet[nje]:GetJsonObject("error") + ENTER, "")
                     aGetNcmMod := getNcmMod(aCatalogos[limiteInt * (nFor - 1) +nje])
                     for nErros := 1 to len(aJsonErros)
                        cMsgRetErr := cp400getNomeAtt(aJsonErros[nErros],aGetNcmMod[1],aGetNcmMod[2])
                        if !cMsgRetErr $ cErros
                           cErros += cMsgRetErr + ENTER
                        endif
                     next
                  endif

                  if lIndEKD .And. ExistCpo("EKD",EK9->EK9_COD_I + AvKey(cCodigo,"EK9_IDPORT") + AvKey(cVersao,"EK9_VSMANU"), 3, , .F.)
                     cErros += STR0069 +" (" +Alltrim(cCodigo)+"/"+Alltrim(cVersao)+ ")" + ENTER //"O ID e Versão retornados pela integração já existem no histórico de Integrações do Catálogo de Produtos."
                     cErros += STR0070 + ENTER //"Para utilizar este ID e Versão, recomendamos tornar obsoleto o registro atual e incluir um novo Catálogo de Produtos, informando os campos ID Manual e Versão Manual."
                     cSucesso := "false"
                  endif

                  lAtuErr := .t.
                  aadd(aRetCat,{cSucesso, cCodigo, cVersao,getErros(cErros,cSucesso,substr(cStrJson,10,len(cStrJson))),substr(cStrJson,10,len(cStrJson)),aCatalogos[limiteInt * (nFor - 1) +nje],cLogInteg,getMsgEnv(aJsonEnvio,nje) + cStrJson})
               next nje   
            endif
         endif
      endif
      FwFreeObj(oJson)
   elseif !empty(cErros)
      cErros := if( match(cErros,"*Failed to fetch*"), STR0062 , cErros) + ENTER // "Não foi possível estabelecer conexão com o portal único. Verifique se está conectado na internet ou se o certificado está correto."
   elseif empty(cErros)

      cErros := STR0071 + ENTER // "Integração sem nenhum retorno!"
   endif

   if !lAtuErr
      for nje := 1 to nSeq
//            aadd(aRetCat,{"", "", "", getErros(cErros,cSucesso,substr(cStrJson,10,len(cStrJson))),substr(cStrJson,10,len(cStrJson)),aCatalogos[limiteInt * (nFor - 1) +nje], cLogInteg,getMsgEnv(aJsonEnvio,nje)}) 
            aadd(aRetCat,{"false", "", "", getErros(cErros,"false",substr(cStrJson,10,len(cStrJson))),substr(cStrJson,10,len(cStrJson)),aCatalogos[limiteInt * (nFor - 1) +nje], cLogInteg,getMsgEnv(aJsonEnvio,nje)}) 
            //adiciona a mesma mensagem de erro com conexão ao portal único para cada operador
      next nje
   EndIF    
   CP402aRtCt(@aRetCat,nSeq,nFor,aCatalogos,.f.)
return lRet


/*/{Protheus.doc} setEK9_EKD
   Função para atualizar os campos do catálogo de produtos após a integração

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
          nCount, numérico, quantidade de registros para integração
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function setEK9_EKD(aRetCat,aCatalogos)
local nje := 0
local lCpoVrsAt := EKD->(ColumnPos("EKD_VATUAL")) > 0
local lOk := nil
for nje := 1 to len(aCatalogos)
   EKD->(dbgoto(aCatalogos[nJe]))
   EK9->(DbSeek(xFilial("EK9")+EKD->EKD_COD_I))
   lOk := len(aRetCat) > 0 .and. upper(aRetCat[nJe][1]) == "TRUE"
   if lOk 
      // Validação para tornar obsoleto o catálogo com o status integrado caso exista algum.
      nTempRecno := EKD->(recno())
      EKD->(dbSeek(xFilial("EKD") + EK9->EK9_COD_I))
      While EKD->(!EOF()) .And. EKD->EKD_FILIAL == xFilial("EKD") .And. EKD->EKD_COD_I == EK9->EK9_COD_I
         If EKD->EKD_STATUS $ '1|5|6' // 1=Registrado | 5=Registrado(pendente: fabricante/ país) | 6=Registrado Manualmente
            RecLock("EKD",.F.)
            EKD->EKD_STATUS := '3' //Obsoleto
            EKD->(MsUnlock())
         EndIf
         EKD->(dbSkip())
      End
      EKD->(dbgoto(nTempRecno))
   EndIf
   setEKD(lOK,aRetCat[nJe],lCpoVrsAt)   
   setEK9(lOK,aRetCat[nJe])
Next nJe           
Return            

/*/{Protheus.doc} CP402Script
   Gera o script consumir o serviço do portal unico através do easyjs 
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
static function CP402Script()
   Local cVar

   begincontent var cVar
      function intCatalogo(cUrl, sBody, retAdvplError, retAdvpl) {
         let status = 0;
         let status_text = '';
         EasyFetch( retAdvplError, cUrl, 'POST', sBody)
         .then( (res) => {
            status = res.status;
            status_text = res.statusText;
            return res.text() 
         })
         .then( (res) => { retAdvpl({status: status, status_text: status_text, response: res}) } )
         .catch((e) => { retAdvplError(e) });
      }
      function vincOperCat(cUrl, sBody, retAdvplError, retAdvpl) {
         let status = 0;
         let status_text = '';
         EasyFetch( retAdvplError, cUrl, 'POST', sBody)
         .then( (res) => {
            status = res.status;
            status_text = res.statusText;
            return res.text() 
         })
         .then( (res) => { retAdvpl({status: status, status_text: status_text, response: res}) } )
         .catch((e) => { retAdvplError(e) });
      }
   endcontent

Return cVar


/*/{Protheus.doc} CP402IFbPO
   Função que realiza a integração com o siscomex para cada fabricante/país de origem 
   relacionado ao catálogo de produtos integrado.
   @author Nilson César
   @since 08/05/2021
   @version 1
/*/
Function CP402IFbPO(oProc, oEasyJS, cUrlPortal, aCatIntOK,aRetInt,oBrowProc) 
   Local nQtdInt     := 0
   Local cRet        := ""
   Local ctxtJsonFB  := ""
   Local aFabrPaises := {}
   Local lEKFVincFB  := EKF->(ColumnPos("EKF_VINCFB")) > 0 
   local nCp         := 0
   local cURLFbrCat  := "/catp/api/ext/fabricante"
   local ni          := 0
   local nForF       := 0
   local nFor        := 0
   local aJsonEnvio  := {}
   local aJsonGeral  := {}
   local nTotFab     := 0
   local cLogInteg   := ''
   local cLogIni     := ''
   local cErros      := ''

   cLogIni += Time() + " - " + STR0047  // Vinculando/Desvinculando operador estrangeiro aos catálogos de produtos"
   for nCp:=1 to len(aCatIntOK)
      EKD->(dbgoto(aCatIntOK[nCP]))
      cChaveEKF := xFilial("EKF") + EKD->EKD_COD_I + EKD->EKD_VERSAO
   
      If lEKFVincFB .and. EKF->(DbSeek( cChaveEKF ))      
         Do While EKF->(!Eof()) .And. EKF->( EKF_FILIAL + EKF_COD_I + EKF_VERSAO ) ==  cChaveEKF
            If !Empty(EKF->EKF_VINCFB) .And. !(EKF->EKF_VINCFB $ "3|4|5")  // NCF - 11/05/2021 - Só serão setados para integração fabricantes a vincular ou desvincular
               nQtdInt++
               aAdd( aFabrPaises, {EKF->(Recno()), EKD->EKD_CNPJ, EKD->EKD_IDPORT, EKF->EKF_COD_I,'','','',STR0093,rTrim(EKF->EKF_CODFAB),IF(EMPTY(EKF->EKF_LOJA),STR0097+EKF->EKF_PAIS,EKF->EKF_LOJA)})
            EndIf
            EKF->(DbSkip())
         EndDo
      EndIf
   next nCp   

   EKJ->(dbsetorder(1))
   SA2->(dbsetorder(1))

   oProc:SetRegua1(nQtdInt)
   nTotFab := len(aFabrPaises)
   nForF := int(nTotFab / limiteInt) + if( nTotFab % limiteInt > 0, 1, 0)     
   for nFor := 1 to nForF
      nSeq := 0      
      cRet := ''     
      aJsonEnvio:={}
      cLogInteg := ''
      oProc:IncRegua1(CP402getEt("5") + STR0054 + " " + STR0093 ) // Integrando vinculação/desvinculação do operador estrangeiro
      for ni:= 1+((nFor-1)*limiteInt) to if(limiteInt * nFor > nTotFab, nTotFab, limiteInt * nFor) 
          nSeq += 1 
          getJsonFab(aFabrPaises[ni],oProc,nSeq,@aJsonEnvio)
          aadd(aJsonGeral,aJsonEnvio[nSeq])               
      next ni
      ctxtJsonFB := getJsonVinc(aJsonEnvio)

      if cTxtJsonFB # '[]' .and. !empty(cTxtJsonFB) .and. cErros <> "Failed to fetch" .and. cErros <> STR0062
         cRet := vincOperCat(oEasyJS, @cErros, cUrlPortal + cURLFbrCat, ctxtJsonFB)   
      EndIf   
      setResFab(cRet, cErros, aFabrPaises, oProc, cLogInteg, lEKFVincFB,nSeq,@aRetInt,nFor,cLogIni + ENTER + cLogInteg, ctxtJsonFB) //Função para atualizar os resultados da integraçao da vinculação do operador estrangeiro
   next nFor   
   setkfkdk9(aRetInt,aFabrPaises)
   AtuInt(aRetInt,aFabrPaises,oBrowProc,.t.) //oBroc //atualiza a tela do browse com os resultaodos ocorridos na integração da vinculaçao dos operadores estrangeiros com sucesso       
Return

/*/{Protheus.doc} vincOperCat
   Executa a vinculação do operador com o catalogo de produto

   @type  Static Function
   @author user
   @since 24/11/2023
   @version version
   @param oEasyJS, objeto, EasyJS
          cErros, caracter, variavel de erro
          cUrl, caracter, URL do portal unico da API
          cJson, caracter, JSON de envio
   @return cRet, caracter, retorno da execução
/*/
static function vincOperCat(oEasyJS, cErros, cUrl, cJson)
   local cRet    := ""
   local cScript := ""
   if !empty(cJson)

      begincontent var cScript

         vincOperCat('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)

      endcontent

      oEasyJS:runJSSync( cScript ,{|x| cRet := x } , {|x| cErros := x } )
   EndIf
return cRet
//////////////////////// FINAL DAS FUNCOES MOVIDAS DO FONTE EICCP400 ///////////////////////////

/*/{Protheus.doc} getJsonFab
   Função para atualizar os campos do catálogo de produtos após a integração

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
          nCount, numérico, quantidade de registros para integração
   @return cTxtJson, caracter, json de envio
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getJsonFab(aFabrPaises,oProc,nSeq,aJsonEnvio)
   Local cConhFB, cVincFB, cCpfCnpjR, cCodProdF, cCodPaisF, cCpfCnpjFB, cCodOEFB
   Local lEKFVincFB := EKF->(ColumnPos("EKF_VINCFB")) > 0 
   Private cIntCpfCnpj

   EKF->(dbgoto(aFabrPaises[1]))
   
//         if lLogView 
//            getLog( space(08) + " - " + if( !empty(EKF->EKF_CODFAB), alltrim(EKF->EKF_CODFAB) + "-" + EKF->EKF_LOJA + "/", "" ) + EKF->EKF_PAIS + ENTER , oLogView, @cLogInteg) 
//         endif

   //oProc:IncRegua1( STR0054 + " " + if( !empty(EKF->EKF_CODFAB), alltrim(EKF->EKF_CODFAB) + "-" + EKF->EKF_LOJA + "/", "" ) + EKF->EKF_PAIS ) // "Integrando:"
   
   cConhFB   := If( !Empty(EKF->EKF_CODFAB) , "true" , "false"    )
   cVincFB   := If(lEKFVincFB,If( EKF->EKF_VINCFB == "1" , "true" , "false" ),"false")
   cCpfCnpjR := aFabrPaises[2] //EKD->EKD_CNPJ
   cCodProdF := aFabrPaises[3] //EKD->EKD_IDPORT
   cCodPaisF := alltrim(EKF->EKF_PAIS)

   If !Empty(EKF->EKF_CODFAB)
      EKJ->(dbSeek(  xFilial("EKJ") + aFabrPaises[2] + EKF->EKF_CODFAB + EKF->EKF_LOJA  ))  // Posiciona no registro de Operador Estrangeiro do Fabricante
      if EKJ->EKJ_PAIS == "BR"
         SA2->(dbSeek(xFilial("SA2") + EKF->EKF_CODFAB + EKF->EKF_LOJA))
         cCpfCnpjFB := SA2->A2_CGC 
         cCodOEFB   := ""
      else // se o pais origem for diferente de brasil manda o código do operador estrangeiro
         cCodOEFB   := AllTrim(EKJ->EKJ_TIN)
         cCpfCnpjFB := ""
      endif
      cCpfCnpjR := EKJ->EKJ_CNPJ_R
   Else
      cCodOEFB   := ""
      cCpfCnpjFB := ""
   EndIf

   cIntCpfCnpj := cCpfCnpjR
   If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICCP400_VINCULAR_FABRICANTE"),)

   Aadd(aJsonEnvio,JsonObject():new())
   aJsonEnvio[nSeq]["seq"] := nSeq
   aJsonEnvio[nSeq]["cpfCnpjRaiz"] := cIntCpfCnpj 
   aJsonEnvio[nSeq]["codigoOperadorEstrangeiro"] := cCodOEFB
   aJsonEnvio[nSeq]["cpfCnpjFabricante"] := cCpfCnpjFB
   aJsonEnvio[nSeq]["conhecido"] := cConhFB
   aJsonEnvio[nSeq]["codigoProduto"] := cCodProdF
   aJsonEnvio[nSeq]["vincular"] := cVincFB
   aJsonEnvio[nSeq]["codigoPais"] := cCodPaisF         
Return

/*/{Protheus.doc} setResFab
   Função para atualizar os resultados da integraçao da vinculação do operador estrangeiro
   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
          nCount, numérico, quantidade de registros para integração
   @return cTxtJson, caracter, json de envio
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function setResFab(cRet, cErros, aFabrPaises, oProc, cLogInteg, lEKFVincFB, nSeq, aRetInt, nFor, cLogInteg, cJsonEnvio)
local nj         := 0
local nInd       := 0
local lAtuErr    := .F.
local cEnvio     := ""
local oJsonEnvio := JsonObject():New()
local aJsonEnvio := {}
local cStrJson   := ""
local cSucesso   := ""
local cMsgRetErr := ""

   cEnvio := '{"items":'+cJsonEnvio+'}'
   oJsonEnvio:FromJson(cEnvio)
   aJsonEnvio := oJsonEnvio:GetJsonObject("items")

   cErros := if( empty(cRet) .and. empty(cErros), STR0071 + ENTER, cErros) // "Integração sem nenhum retorno!"

   // Pega o retorno e converte para json para extrair as informações
   if !empty(cRet) .and. empty(cErros)
      cRet     := '{"items":'+cRet+'}'
      oJson    := JsonObject():New()
      cRetJson := oJson:FromJson(cRet)
      cErros := if( !valtype(cRetJson) == "U", STR0077 + ENTER + ENTER + cRetJson + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
      if empty(cErros)

         cErros := if( valtype(oJson:GetJsonObject("items")) == "A", "", STR0066 + ENTER ) // "Arquivo de retorno sem itens!"
         if oJson:HasProperty("items") .and. oJson:GetJsonObject("items"):HasProperty("response")
            cRet := '{"items":'+oJson:GetJsonObject("items"):GetJsonText("response")+'}'
            FwFreeObj(oJson)
            oJson:= JsonObject():New()
            oJson:FromJson(cRet)
            cErros := ""
         endif

         if empty(cErros)
            aJson    := oJson:GetJsonObject("items")
            For nInd := 1 To len(aJson)
               nIndAtu := limiteInt * (nFor - 1) + nInd 
               cSucesso := aJson[nInd]:GetJsonText("sucesso")
               cSequence:= aJson[nInd]:GetJsonText("seq")
               cStrJson := ENTER + Time() + " - " + STR0067 + ": " + aJson[nInd]:ToJson() + ENTER// "Mensagem de retorno"
               if Upper(cSucesso)=="FALSE" 
                  aJsonErros := if( valtype(aJson[nInd]:GetJsonObject("erros")) == "A", aJson[nInd]:GetJsonObject("erros"), if( valtype(aJson[nInd]:GetJsonObject("error")) == "C" , aJson[nInd]:GetJsonObject("error_description"), {}))
                  EKF->(dbgoto(aFabrPaises[nIndAtu][1]))
                  cErros := STR0082 + ": " + EKF->EKF_CODFAB + " | " + STR0078 + ": " + EKF->EKF_LOJA + " | " + STR0079 + ": " + EKF->EKF_PAIS + ": " // "Fabricante" #### "Loja" #### "País de Origem"
                  if len(aJsonErros) > 0
                     cErros += if( valtype(aJson[nInd]:GetJsonObject("error")) == "C", aJson[nInd]:GetJsonObject("error") + ENTER, "")
                  endif
                  for nj := 1 to len(aJsonErros)
                     cMsgRetErr := aJsonErros[nj]
                     if !cMsgRetErr $ cErros
                        cErros += cMsgRetErr + ENTER
                     endif
                  next
                  cErros += if(empty(cErros),STR0068 + ENTER,"")  //Arquivo de retorno inválido
               endif
               lAtuErr := .T.
               aadd(aRetInt,{cSucesso, '', '',getErros(cErros,cSucesso,substr(cStrJson,10,len(cStrJson))),substr(cStrJson,10,len(cStrJson)),aFabrPaises[nIndAtu][1],cLogInteg + if(Upper(cSucesso)=="FALSE", ENTER +  Time() + " - " + STR0081,''),getMsgEnv(aJsonEnvio,nInd) + cStrJson})
                                                             
            Next nInd
         endif
      endif
      FreeObj(oJson)
   endif

   if !lAtuErr
      for nInd := 1 to nSeq
         aadd(aRetInt,{"false", "", "",getErros(cErros,"false",substr(cStrJson,10,len(cStrJson))),substr(cStrJson,10,len(cStrJson)),aFabrPaises[limiteInt * (nFor - 1) +nInd][1], cLogInteg + ENTER +  Time() + " - " + STR0081, getMsgEnv(aJsonEnvio,nInd) + cStrJson  }) 
      //adiciona a mesma mensagem de erro com conexão ao portal único para cada operador
      next nInd
   EndIF  
   CP402aRtCt(@aRetInt,nSeq,nFor,aFabrPaises,.f.)     
Return       


/*/{Protheus.doc} setOEasyJs
   Função para configurar e ativar o EasyJS
   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oEasyJs objeto que será configurado
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Static function setOEasyJs(oEasyJS,cUrlPortal, cError, cSolucao)
local cURLAuth := "/portal/api/autenticar"
local lRet     := .T.

   oEasyJS := EasyJS():New()
   oEasyJS:cUrl := cURLPortal+cURLAuth
   oEasyJS:setTimeOut(120)
   oEasyJS:AddLib( EasyAppFetch(cURLPortal+cURLAuth) )
   oEasyJS:AddLib( OE400Script() )
   oEasyJS:AddLib( CP402Script() )
   lRet := oEasyJS:Activate(.T.)

   if(!lRet, (cError := STR0102, cSolucao := STR0103), nil ) // "Não foi possível carregar os dados para realizar a integração" ### "Por favor, acesse novamente o sistema e tente realizar a integração."

Return lRet   

/*/{Protheus.doc} getJsonVinc
   Função para retornar o txt do json de envio 
   @type  Static Function
   @author user
   @since 19/02/2025
   @version version
   @param oEasyJs objeto que será configurado
   @return ctxtJson, caracter, json de envio
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getJsonVinc(aJsonEnvio)
Local ctxtJson := ""
Local oJson := nil
if !Empty(aJsonEnvio)
   oJson := JsonObject():new()
   oJson:set(aJsonEnvio) 
   ctxtJson:=oJson:ToJson()
   FwFreeObj(oJson)
EndIf   
return ctxtJson   

Static function setKFKDK9(aRetInt,aFabrPaises)
local nje := 0
local lEKFVincFB := EKF->(ColumnPos("EKF_VINCFB")) > 0    
local lCpoVrsAt := EKD->(ColumnPos("EKD_VATUAL")) > 0    //ver com o Fabrício se ainda precisa        
local lRet := .F.
local aEKD := EKD->(getarea())
local aRetEKD := {}
local aRetEK9 := {}
   EKD->(DBSETORDER(1))
   for nje := 1 to len(aFabrPaises)    
      EKF->(dbgoto(aFabrPaises[nje][1]))
      lRet := upper(aRetInt[nje][1]) == "TRUE"  
      setEKF(lEKFVincFB,lRet)
      setRetEKs(@aRetEKD,@aRetEK9,lRet,aRetInt,nje,lCpoVrsAt) 
   next nje   
   setaEK9(aRetEK9,lCpoVrsAt)   
   setaEKD(aRetEKD)   
   restarea(aEKD)
Return   

/*/{Protheus.doc} getMsgEnv
   Função para retornar o txt do json de envio 
   @type  Static Function
   @author user
   @since 21/02/2025
   @version version
   @param aJsonEnvio array com json de envio
          nJe indice do array a ser tratado
   @return cRet, retornao json convetuido apra texto
   @example
   (examples)
   @see (links_or_references)
/*/
static function getMsgEnv(aJsonEnvio,nje)
cRet:= ''
if !empty(aJsonEnvio)
   cret:= ENTER + Time() + " - " + STR0075 + aJsonEnvio[nje]:toJson() + ENTER // "Mensagem de envio: "
EndIf
return cRet

/*/{Protheus.doc} getMsgFin
   Função para retornar a mensagem final do log da inegarção do catálogo
   @type  Static Function
   @author user
   @since 21/02/2025
   @version version
   @param aReCAt array com as mensagens de log  
          lReplicate, indica se deve conter o replicate e concatenar com o log da EKD
   @return cRet, retorna a mensagem pronta
   @example
   (examples)
   @see (links_or_references)
/*/
static function getMsgFin(aRetCat,lReplicate,cStr)
local cRet := ''
cRet := aRetCat[7] + aRetCat[8] +  ENTER +  Time() + " - " + cStr + if(lReplicate,ENTER + ENTER + replicate("-",120) + ENTER + ENTER + EKD->EKD_RETINT,'')
Return cRet

/*/{Protheus.doc} setEKD
   Função para gravar o log na ekd
   @type  Static Function
   @author user
   @since 21/02/2025
   @version version
   @param lOk, define os campos que serão atualizados na ekdgetMsgFin
          aRetCat, array com as informações de log a serem gravadas
          lCpoVrsAt, indica se deve atualizar o campo de versão atual
   @return cRet, retorna a mensagem pronta
   @example
   (examples)
   @see (links_or_references)
/*/
static Function setEKD(lOk,aRetcat,lCpoVrsAt)
   reclock("EKD",.F.)
   EKD->EKD_USERIN   := __cUserID
   EKD->EKD_RETINT := getMsgFin(aRetCat,.t.,STR0090)
   if lok
      EKD->EKD_STATUS   := "1" // "Registrado"
      EKD->EKD_IDPORT   := aRetCat[2]
      If lCpoVrsAt
         EKD->EKD_VATUAL   := aRetCat[3]
      EndIf
      EKD->EKD_DATA     := dDatabase
      EKD->EKD_HORA     := strtran(time(),":","")
   else
      if !empty(aRetCat[1] ) //substitui o lHasRet
         EKD->EKD_STATUS   := "4"
      endif
   endif
   EKD->(msunlock())
Return

/*/{Protheus.doc} setEK9
   Função para gravar o log na ekd
   @type  Static Function
   @author user
   @since 21/02/2025
   @version version
   @param lOk, define os campos que serão atualizados na ek9
          aRetCat, array com as informações de log a serem gravadas
   @return cRet, retorna a mensagem pronta
   @example
   (examples)
   @see (links_or_references)
/*/
static Function setEK9(lOk,aRetCat)
   reclock("EK9",.F.)
   EK9->EK9_RETINT   := getMsgFin(aRetCat,.f.,STR0090)
   if lOK
      EK9->EK9_STATUS   := REGISTRADO
      EK9->EK9_IDPORT   := aRetCat[2]
      EK9->EK9_VATUAL   := aRetCat[3]        
   endIf   
   EK9->(msunlock())
return

/*/{Protheus.doc} getEKD6
   Função para gravar o log na ekd
   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param aCatIntOK array com os catálogos integrados com sucesso 
          aCat6 array com os catálogs da ek9 com status = 6
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
static function getEKD6(aCatIntOK,aCat6)
local nje := 0
local cVersaoEKD := ''
for nje := 1 to len(aCat6)
   cVersaoEKD := CPGetVersion(xFilial("EKD"), aCat6[nje])
   IF EKD->(dbsetorder(1),DbSeek(xFilial("EKD") + aCat6[nje] + cVersaoEKD))    
      AADD(aCatIntOk,EKD->(recno()))     
   endif   
next nje  
return


/*/{Protheus.doc} CP402aRtCt
   Função para ajustar o tamanho do array aRet de acordo com o número de registros enviados na integração
   este cenário ocorre quando o portal retorna menos erros do que no arquivo de envio
   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param aRet, array com os retornos já apurados
          nSeq, sequência de registros enviados
          nFor, ocorrência do loop da quebra do envio dos registros, quebrado pelo parâmetro limiteInt
          aEntidade, array com os países ou catálogos de produtos
          lOp, indica se é uma integração de operador estrangeiro
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
function CP402aRtCt(aRet,nSeq,nFor,aEntidade,lOp)
Local nInd := 0
Local nLenAret := len(aRet)
   if nLenAret < nSeq
      for nInd:=nLenAret + 1 to nSeq
          if lOp
            aadd(aRet,{aRet[nLenAret][1], aRet[nLenAret][2], aRet[nLenAret][3], aRet[nLenAret][4], aRet[nLenAret][5], aEntidade[limiteInt * (nFor - 1) + nInd]})
          else
            aadd(aRet,{aRet[nLenAret][1], aRet[nLenAret][2], aRet[nLenAret][3], aRet[nLenAret][4], aRet[nLenAret][5], aEntidade[limiteInt * (nFor - 1) +nInd][1], aRet[nLenAret][7], aRet[nLenAret][8]})
          EndIf
      next nj
   endif
Return   

/*/{Protheus.doc} getErros
   Função que verifica se houve falha e o cErro está vazio, é pq. o retorno do erro veio diferente do modelo esperado "Erros[]"
   entao retorna a mensagem de retorno completa como erro
   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param cErros, mensagem com o erro gerado ou vazio
          cSucesso, true ou false
          cStrJson, mensagem completa do retorno da integração         
   @return cRet, mensagem que deve ser considerada como erro 
   @example
   (examples)
   @see (links_or_references)
/*/
static function getErros(cErros,cSucesso,cStrJson)
Local cRet:=''
cRet:=if(cSucesso == "false" .and. empty(cErros),cStrJson,cErros)
Return cRet


/*/{Protheus.doc} setEKF
   Função que atualiza o status da EKF
   entao retorna a mensagem de retorno completa como erro
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
Static function setEKF(lEKFVincFB,lREt)
local cStatusInt :=''    
if lEKFVincFB
   cStatusInt := If(lRet, If( EKF->EKF_VINCFB == "1" , "4" , "5" ), EKF->EKF_VINCFB  )
   If EKF->EKF_VINCFB <> cStatusInt
      EKF->(RecLock("EKF",.F.))
      EKF->EKF_VINCFB := cStatusInt
      EKF->(MsUnlock())
   EndIf
Endif   
return

/*/{Protheus.doc} setRetEKs
   Função que cria um array com o recno, status e log das tabelas ekd e ek9
   Onde se houver um dos operadores estrangeiros com erro, deixa o status como false
   Então só vai ficar true se todos os operadoares estrangeiros forem integrados com sucesso
   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param aRetEKD, array onde será armazenado o recno, status e log da tabela ekd
          aRetEK9, array onde será armazenado o recno, status e log da tabela ek9
          lRet, indica o retorno de suceso ou falha na integração da vinculaçao do operador estrangiero
          aRetInt, array com as mensagens de log
          nje, indice do array aRetInt
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
static function setRetEKs(aRetEKD,aRetEK9,lRet,aRetInt,nje,lCpoVrsAt)
//já está posicionado na EKF
local nREs:=0
IF EKD->(DbSeek(xFilial("EKD") + EKF->EKF_COD_I + EKF->EKF_VERSAO))
   if (nRes := aScan(aRetEKD, {|x| x[1] == EKD->(Recno()) })) == 0  
      aadd(aRetEKD,{EKD->(Recno()), lRet, getMsgFin(aRetInt[nje],.f.,STR0091) })
   Else
      aRetEKD[nRes][2] := if(lRet,aRetEKD[nRes][2],lRet)
      aRetEKD[nRes][3] := aRetEKD[nRes][3] + ENTER + ENTER + getMsgFin(aRetInt[nje],.f.,STR0091)
   EndIf
EndIf  

IF EK9->(DbSeek(xFilial("EK9") + EKF->EKF_COD_I))
   if (nRes := aScan(aRetEK9, {|x| x[1] == EK9->(Recno()) })) == 0  
      aadd(aRetEK9,{EK9->(Recno()), lRet, getMsgFin(aRetInt[nje],.f.,STR0091),if(lCpoVrsAt,EKD->EKD_VATUAL,'') })
   Else
      aRetEK9[nRes][2] := if(lRet,aRetEK9[nRes][2],lRet)
      aRetEK9[nRes][3] := aRetEK9[nRes][3] + ENTER + ENTER + getMsgFin(aRetInt[nje],.f.,STR0091)
   EndIf
EndIf
Return


/*/{Protheus.doc} setaEK9
   Função que posiciona na EK9 e atualiza o log e o status   
   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param aRetEKD9, array com o recno e o booleano que indica se teve sucesso ou nao
          lCpoVrsAt, inidica se deve atualizar o campo EK9_VATUAL          
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
static function setaEK9(aRetEK9,lCpoVrsAt)
local ni:=0
for ni:=1 to len(aRetEK9)
   EK9->(dbgoto(aRetEK9[ni][1]))
   EK9->(RecLock("EK9",.F.))
   EK9->EK9_RETINT := aRetEK9[ni][3]
   if aRetEK9[ni][2]
      EK9->EK9_STATUS := REGISTRADO // 1
   else
      EK9->EK9_STATUS := REGISTRADO_PENDENTE_FAB_PAIS // 5
   endif
   if lCpoVrsAt
      EK9->EK9_VATUAL := aRetEK9[ni][4]
   endif
   EK9->(MsUnlock())
next ni
return

/*/{Protheus.doc} setaEKD
   Função que posiciona na EKD e atualiza o log e o status   
   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param aRetEKDD, array com o recno e o booleano que indica se teve sucesso ou nao
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
static function setaEKD(aRetEKD)
local ni:=0
for ni:=1 to len(aRetEKD)
   EKD->(dbgoto(aRetEKD[ni][1]))
   EKD->(RecLock("EKD",.F.))
   EKD->EKD_RETINT := aRetEKD[ni][3]
   if aRetEKD[ni][2]
      EKD->EKD_STATUS := "1" //Integrado
   else
      EKD->EKD_STATUS := "5" //Integrado (pendente: fabricante/país)
   EndIf
next ni
return   

/*/{Protheus.doc} CP402getEt
   Gera a sting com a etapa da execução do sistema
   @type  Static Function
   @author user
   @since 24/02/2025
   @version version
   @param cEtapa, string com a etapa da execuçaõa
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Function CP402getEt(cEtapa)
local cFim := "5"
local cRet:=""
cRet := StrTran(STR0095,'###', cEtapa)
cRet := StrTran(cRet,'$$$', cFim) + " "
REturn cRet

/*/{Protheus.doc} CP402getEt
   A partir do recno posiciona na EKD e retorna um array com o ncm e a modalidade do catálogo de produto
   @type  Static Function
   @author user
   @since 13/03/2025
   @version version
   @param aCatalogo
   @return Retorna um array com o ncm e a modalidade do catálogo de produto
   @example
   (examples)
   @see (links_or_references)
/*/
 Static Function  getNcmMod(nEKD)
 local aRet := {}
 EKD->(dbgoto(nEKD)) 
 aadd(aRet, EKD->EKD_NCM)
 aadd(aRet, EKD->EKD_MODALI)
 Return aRet

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
 Static function getCarac(cTipo)
local cRet := if(left(UPPER(cTipo),6)=='NUMERO','','"')
Return cRet
