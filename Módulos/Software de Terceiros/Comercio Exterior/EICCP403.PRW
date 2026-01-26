#include 'protheus.ch'
#include 'average.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "eiccp403.ch"

#define CP403_TABLE "CP403_EK9"
#define REG_MARCA   "REG_MARCA"
#define MARCA       "X"
#define REGISTRADO                   "1"
#define PENDENTE_REGISTRO            "2"
#define PENDENTE_RETIFICACAO         "3"
#define BLOQUEADO                    "4"
#define REGISTRADO_MANUALMENTE       "5"
#define REGISTRADO_PENDENTE_FAB_PAIS "6"
#define COR_CAMPO                    "0xD3D3D3" //cinza
#define COR_TITULO                   "0x778899"  //preto
#define COR_DEFAULT                  "Default"

/*/{Protheus.doc} CP403ExpXls
   Realiza a exportação dos catálogos para um arquivo excel
   @type  Function
   @author user
   @since 26/03/2025
   @version version
   @param 
   @return nil
   @example
   (examples)
   @see (links_or_references)
   /*/

Function CP403ExpXls()
   local lIsBlind := isBlind()
   local aAreaEK9 := {}
   local nRecEK9  := 0

   dbSelectArea("EK9")
   aAreaEK9 := EK9->(getArea())

   if !lIsBlind
      nRecEK9 := EK9->(recno())
      WizardXls(nRecEK9)
   endif

   restArea(aAreaEK9)

return nil

/*/{Protheus.doc} WizardXls
   Criação da tela do Wizard para a geração do excel

   @type  Static Function
   @author user
   @since 26/03/2025
   @version version
   @param nRecEK9, numérico, recno da tabela EK9 posicionado
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function WizardXls(nRecEK9)
   local oEasyTmp   := nil
   local aCoords    := {}
   local oStepWiz   := nil
   local oStep1     := nil
   local oStep2     := nil
   local oStep3     := nil
   local oMrkBrw    := nil
   local oBrwProc   := nil
   local nRecAlias  := 0
   local nCount     := 0

   oEasyTmp := EasyTemporaryTable():new()
   setTable(@oEasyTmp)

   getEK9(@oEasyTmp,nRecEK9,@nRecAlias)

   aCoords := FWGetDialogSize()
   oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
   oStepWiz:ActiveUISteps()

    oStep1 := oStepWiz:AddStep("1")
    oStep1:SetStepDescription(STR0001) // "Introdução"
    oStep1:SetConstruction({ |oPanel| ViewIntrod( oPanel ) } )
    oStep1:SetNextTitle(STR0011) // "Avançar"
    oStep1:SetNextAction( { || validStep("1") })
    oStep1:SetCancelAction( { || MsgYesNo(STR0002, STR0003) }) // "Deseja cancelar a geração da planilha?" ### "Catálogo de Produto"        

    oStep2 := oStepWiz:AddStep("2")
    oStep2:SetStepDescription(STR0003) // "Catálogos de produtos"
    oStep2:SetConstruction({ |oPanel| ViewCatPrd(oPanel, @oMrkBrw, nRecAlias), if( oMrkBrw <> nil, oMrkBrw:oBrowse:Refresh(.F.), nil) })
    oStep2:SetPrevTitle(STR0010) // "Voltar"
    oStep2:SetNextTitle(STR0009) // "Avançar"
    oStep2:SetNextAction( { || validStep("2",@nCount) })
    oStep2:SetCancelAction( { || MsgYesNo(STR0002, STR0003) }) // "Deseja cancelar a geração da planilha?" ### "Catálogo de Produto"      
         
    oStep3 := oStepWiz:AddStep("3") 
    oStep3:SetStepDescription(STR0014) // "Processamento"
    oStep3:SetConstruction({|oPanel| ViewProc(oPanel, @oBrwProc,nCount), if( oBrwProc <> nil, oBrwProc:oBrowse:Refresh(.T.), nil) })
    oStep3:SetNextTitle(STR0008) // "Exportar"
    oStep3:SetPrevTitle(STR0010) // "Fechar"
    oStep3:SetCancelWhen({|| .F. })

    oStepWiz:Activate()
    oStepWiz:Destroy()

    FwFreeObj( oStepWiz )

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
static function ViewIntrod(oPanel)
   local aCoords    := {}
   local cIntrod    := "" 
   local oSay       := nil
   local oFont      := nil

   aCoords := FWGetDialogSize(oPanel)      
   cIntrod := STR0015 + ' ' + STR0016 + ' ' + STR0017 // "Esta rotina tem por objetivo a exibição dos catálogos de produtos para realização da exportação dos dados em planilha onde serão agrupados 
               // "por NCM  possibilitando o preenchimento dos atributos, vinculação de produtos e vinculação de fabricantes/ país de origem 
              // "para atualização das informações dos Catálogo de Produtos.*/

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
static function ViewCatPrd(oPanel, oMarkBrow, nRecAlias)

//Status, Código Chave, ID Portal, Versão Atual, CNPJ Raíz, Produto de Referência e NCM
   local lRet       := .T.
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local cAliasTmp  := CP403_TABLE
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
   local aCores     := {}
   local nL         := 0
   local aCoresNum  := {REGISTRADO,PENDENTE_REGISTRO,PENDENTE_RETIFICACAO,REGISTRADO_MANUALMENTE,REGISTRADO_PENDENTE_FAB_PAIS} //define quais cores serão utilizadas para os registros do browse

   aCores := CP400Cores(aCoresNum)                    

   if oMarkBrow == nil
      aRotina := {} 

      aStruct := (cAliasTmp)->(dbStruct())
      for nCpo := 1 To Len(aStruct)
         if !(aStruct[nCpo][1] $ (cFieldMark + "||RECEK9||EK9_STATUS" ))
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
      cTexto := STR0006 // "Marque os catálogos de produtos que deseja realizar a exportação para a planilha excel"
      ViewTitulo(oLayer, 17, 83, oPanel, cTexto, @oPnlBrowse)

      // Defino os detalhes da busca do browse
      aAdd(aSeek,{ AvSx3("EK9_COD_I", AV_TITULO) , {{"",getSX3Cache( "EK9_COD_I", "X3_TIPO") ,getSX3Cache( "EK9_COD_I", "X3_TAMANHO") ,0,"EK9_COD_I", getSX3Cache( "EK9_COD_I", "X3_PICTURE")}} , 1, .T.})
      aAdd(aSeek,{ AvSx3("EK9_NCM", AV_TITULO) + AvSx3("EK9_IDPORT", AV_TITULO) + AvSx3("EK9_VATUAL", AV_TITULO) , {;
                                                            {"",getSX3Cache( "EK9_NCM", "X3_TIPO")    ,getSX3Cache( "EK9_NCM", "X3_TAMANHO")    ,0,"EK9_NCM"   , getSX3Cache( "EK9_NCM", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_IDPORT", "X3_TIPO") ,getSX3Cache( "EK9_IDPORT", "X3_TAMANHO") ,0,"EK9_IDPORT", getSX3Cache( "EK9_IDPORT", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_VATUAL", "X3_TIPO") ,getSX3Cache( "EK9_VATUAL", "X3_TAMANHO") ,0,"EK9_VATUAL", getSX3Cache( "EK9_VATUAL", "X3_PICTURE")}}   , 2, .T.})
      aAdd(aSeek,{ AvSx3( "EK9_PRDREF", AV_TITULO), {{"",getSX3Cache( "EK9_PRDREF", "X3_TIPO"),getSX3Cache( "EK9_PRDREF", "X3_TAMANHO"),0,"EK9_PRDREF",getSX3Cache( "EK9_PRDREF", "X3_PICTURE")}}, 3, .T.})
      aAdd(aSeek,{ AvSx3( "EK9_STATUS", AV_TITULO), {{"",getSX3Cache( "EK9_STATUS", "X3_TIPO"),getSX3Cache( "EK9_STATUS", "X3_TAMANHO"),0,"EK9_STATUS",getSX3Cache( "EK9_STATUS", "X3_PICTURE")}}, 5, .T.})      

      fwFreeObj(oMarkBrow)
      oMarkBrow := FWMarkBrowse():New()      
      oMarkBrow:SetOwner( oPnlBrowse )
      oMarkBrow:SetDataTable(.T.)
      oMarkBrow:SetAlias( cAliasTmp )
      oMarkBrow:SetAllMark( bMarcar )
      oMarkBrow:SetMark( cMarca, cAliasTmp, cFieldMark )
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
      oMarkBrow:AddButton( OemTOAnsi("Marcar todos"), { || Marcar("M"), oMarkBrow:oBrowse:Refresh() },, 2 ) // "Marcar todos"
      oMarkBrow:AddButton( OemTOAnsi("Desmarcar todos"), { || Marcar("D"), oMarkBrow:oBrowse:Refresh() },, 2 ) // "Desmarcar todos"
      oMarkBrow:Activate()
      if nRecAlias # 0
         oMarkBrow:GoTo(nRecAlias,.t.) //posiciona e o parâmetro .t. já faz o refresh
      EndIf   
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
   @param oPanel, objeto que será apresentado a introdução
          oBrowProc, objeto que será o browse dos catalogos de produtos        
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewProc(oPanel, oBrowProc, nCount)
   local lRet       := .T.
   local oProc      := nil
   
   BrowseProc(oPanel, @oBrowProc)
   oProc := MsNewProcess():New({|lEnd| GeraExcel(@lEnd, @oBrowProc, @oProc, nCount),oBrowProc:Refresh()}, STR0013 + "...",,.T.) // "Gerando a planilha excel"
   oProc:Activate() 

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
static function BrowseProc(oPanel, oBrowProc)
   local lRet       := .T.
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local cAliasTmp  := CP403_TABLE
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

   if oBrowProc == nil
      aRotina := {} 

      aStruct := (cAliasTmp)->(dbStruct())
      for nCpo := 1 To Len(aStruct)
         if !(aStruct[nCpo][1] $ cFieldMark + "||RECEK9||EK9_STATUS" )
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
         endif

         if !(aStruct[nCpo][1] $ cFieldMark + "||RECEK9||EK9_STATUS" )
            aadd(aFieldFilter, {aStruct[nCpo][1], aStruct[nCpo][1], aStruct[nCpo][2], aStruct[nCpo][3], aStruct[nCpo][4], nil})
         endif
      next nCpo 

      oLayer := FWLayer():New()
      GetRemoteType(@cLib)
      cTexto := STR0012  // "Exportaçaõ dos Catálogos de Produtos para planilha excel"
      ViewTitulo(oLayer, 17, 83, oPanel, cTexto, @oPnlBrowse)

      // Defino os detalhes da busca do browse
      aAdd(aSeek,{AvSx3( "EK9_COD_I" , AV_TITULO), {{"",getSX3Cache( "EK9_COD_I", "X3_TIPO") ,getSX3Cache( "EK9_COD_I", "X3_TAMANHO") ,0,"EK9_COD_I", getSX3Cache( "EK9_COD_I", "X3_PICTURE")}} , 1, .T.})
      aAdd(aSeek,{AvSx3( "EK9_NCM"   , AV_TITULO) + AvSx3( "EK9_IDPORT"   , AV_TITULO) + AvSx3( "EK9_VATUAL"   , AV_TITULO) , {;
                                                            {"",getSX3Cache( "EK9_NCM", "X3_TIPO")    ,getSX3Cache( "EK9_NCM", "X3_TAMANHO")    ,0,"EK9_NCM"   , getSX3Cache( "EK9_NCM", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_IDPORT", "X3_TIPO") ,getSX3Cache( "EK9_IDPORT", "X3_TAMANHO") ,0,"EK9_IDPORT", getSX3Cache( "EK9_IDPORT", "X3_PICTURE")},;
                                                            {"",getSX3Cache( "EK9_VATUAL", "X3_TIPO") ,getSX3Cache( "EK9_VATUAL", "X3_TAMANHO") ,0,"EK9_VATUAL", getSX3Cache( "EK9_VATUAL", "X3_PICTURE")}}   , 2, .T.})
      aAdd(aSeek,{AvSx3( "EK9_PRDREF", AV_TITULO), {{"",getSX3Cache( "EK9_PRDREF", "X3_TIPO"),getSX3Cache( "EK9_PRDREF", "X3_TAMANHO"),0,"EK9_PRDREF",getSX3Cache( "EK9_PRDREF", "X3_PICTURE")}}, 3, .T.})

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
   Função para marca ou desmarcar os catalogos para a geração da planilha

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
   local cAliasTmp  := CP403_TABLE
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
static function validStep(cStep, nCount)
   local lRet       := .T.   
   default cStep      := ""

   do case
      case cStep == "1" // Introdução

      case cStep == "2" // Grid de catalogos
         lRet := getMarcado(@nCount)         
         if !lRet
            easyHelp(STR0005, STR0004,STR0006) // "Não foram marcados os registros para processamento." ### "Atenção" ### "Marque os registros que deseja realizar a exportaçao para planilha excel"
         endif
         lRet := lRet .and. MsgYesNo(STR0007,STR0003) // "Deseja realizar a exportação dos registros marcados?" ### "Catálogo de Produto"
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
   local cAliasTmp  := CP403_TABLE
   local cFieldMark := REG_MARCA

   default oEasyTmp := EasyTemporaryTable():new()

   aSemSX3 := {}
   aAdd(aSemSX3, {cFieldMark   , "C"                                  , 01                                      , 0                                        })
   aAdd(aSemSX3, {"EK9_COD_I"  , getSX3Cache( "EK9_COD_I", "X3_TIPO") , getSX3Cache( "EK9_COD_I", "X3_TAMANHO") , getSX3Cache( "EK9_COD_I", "X3_DECIMAL")  })
   aAdd(aSemSX3, {"EK9_IDPORT" , getSX3Cache( "EK9_IDPORT", "X3_TIPO"), getSX3Cache( "EK9_IDPORT", "X3_TAMANHO"), getSX3Cache( "EK9_IDPORT", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_VATUAL" , getSX3Cache( "EK9_VATUAL", "X3_TIPO"), getSX3Cache( "EK9_VATUAL", "X3_TAMANHO"), getSX3Cache( "EK9_VATUAL", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_CNPJ"   , getSX3Cache( "EK9_CNPJ", "X3_TIPO")  , getSX3Cache( "EK9_CNPJ", "X3_TAMANHO")  , getSX3Cache( "EK9_CNPJ", "X3_DECIMAL")   })
   aAdd(aSemSX3, {"EK9_NCM"    , getSX3Cache( "EK9_NCM", "X3_TIPO")   , getSX3Cache( "EK9_NCM", "X3_TAMANHO")   , getSX3Cache( "EK9_NCM", "X3_DECIMAL")    })
   aAdd(aSemSX3, {"EK9_PRDREF" , getSX3Cache( "EK9_PRDREF", "X3_TIPO"), getSX3Cache( "EK9_PRDREF", "X3_TAMANHO"), getSX3Cache( "EK9_PRDREF", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_DESC_I" , getSX3Cache( "EK9_DESC_I", "X3_TIPO"), getSX3Cache( "EK9_DESC_I", "X3_TAMANHO"), getSX3Cache( "EK9_DESC_I", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_STATUS" , getSX3Cache( "EK9_STATUS", "X3_TIPO"), getSX3Cache( "EK9_STATUS", "X3_TAMANHO"), getSX3Cache( "EK9_STATUS", "X3_DECIMAL") })         
   aAdd(aSemSX3, {"RECEK9"     , "N"                                  , 10                                      , 0                                        })

   aIndex := {}
   aAdd(aIndex, "EK9_COD_I" )
   aAdd(aIndex, "EK9_NCM+EK9_IDPORT+EK9_VATUAL" )
   aAdd(aIndex, "EK9_PRDREF" )
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


/*/{Protheus.doc} GeraExcel
   Função para realizar a geração da planilha do catálogo de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          oProc, objeto, objeto da classe MsNewProcess
          nCount, numérico, quantidade de registros para exportação
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
static function GeraExcel(lEnd, oBrowProc, oProc, nCount)
local lRet:=.f.
local cJson := ''
local oJson := JsonObject():new()
local aNcm := nil
local aPrd := nil
local aOpe := nil
local aCatalogo := nil
local cMsgOk := ''
local cMsgErr := STR0032 //"Ocorreu algum erro no processo de exportação para XLS"
local cMsgRet := ''
local aJson := {}
local aCabPrd := {}
local aCabOpe := {}
Private cNomeXls := 'catproduto' + dtos(dDataBase) + "_" + StrTran(Time(), ":", "") + ".xlsx"
Private cDestXLS := GetTempPath()+space(150-Len(GetTempPath())) //Caminho de onde será salvo o XLS, tamanho total 150 caracteres
Private cDestino := ''
Private aAtribNcm := {}

if ShowDlg()   
   cMsgOK := StrTran(STR0033,"###",cNomeXls) //"Arquivo ###.xls gerado com sucesso."
   cDestino := alltrim(cDestXLS) + cNomeXls  
   If !FILE(cDestino) .Or. ApMsgYesNo(StrTran(STR0034,"###",' ' +cDestino)) // "Deseja sobrescrever o arquivo ###.xls existente?"
      aCatalogo := getCatalogo()
      aNcm := getNcm()
      aPrd := getPrd(aCatalogo)
      aOpe := getOpe(aCatalogo)
      aCabPrd := getCabPrd()
      aCabOpe := getCabOpe()      
      oProc:SetRegua2(2)

      oProc:SetRegua1(len(aNcm) )
      oProc:incRegua2(STR0041) // "Gerando NCM"
      getNcmSheet(@aJson,aNcm,@oProc) 

      oProc:SetRegua1(len(aPrd) )
      oProc:incRegua2(STR0042) // "Gerando Relação de Produtos"
      getPlanSheet(@aJson,aPrd,aCabPrd,STR0038,@oProc)

      oProc:SetRegua1(len(aOpe) )
      oProc:incRegua2(STR0043) // "Gerando Relação de Fabricantes"
      getPlanSheet(@aJson,aOpe,aCabOpe,STR0039,@oProc)

      oJson:set(aJson)  
      cJson := oJson:toJson()
      cMsgRet := if(EasyExpXLS(cJson),cMsgOK,cMSgErr)
      MsgInfo(cMsgRet,'')
   EndIf   
Endif   
Return lRet

/*/{Protheus.doc} getNcmSheet
   Função para gerar um array com o os objetos json com todas as propriedades para gerar as sheets dos ncms na planilha
   @type  Static Function
   @author user
   @since 24/04/2025
   @version version
   @param aJson, array de objetos json que será gerado para cada ncm
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getNcmSheet(aJson,aNcm,oProc)
local oi := 0
local ni := 0
local cNcm := ''
local aDetailAux := {}
local oJsonNcm := nil
for ni := 1 to len(aNcm)          
         aDetailAux:={}
         cNcm := aNcm[ni]
         oJsonNcm := getNcmJson(cNcm)
         oProc:IncRegua1(cNcm) 
         for oi:=1 to len(oJsonNcm)   
            oProc:IncRegua1(STR0019 + " " + cNcm + " " + STR0040 + " " + oJsonNcm[oi]['TITULO'] ) //NCM 99.99.9999 Coluna         
            aadd(aDetailAux,JsonObject():new())            
            aDetailAux[oi] := oJsonNcm[oi]
         next oi
         aadd(aJson,JsonObject():new())            
         aJson[ni][getWorkSheet(cNcm)]  := aDetailAux
      next ni   
Return      

/*/{Protheus.doc} getPlanSheet
   Função para gerar um array com o os objetos json com todas as propriedades para gerar a sheet(neste caso é sempre uma) dos produtos na planilha
   @type  Static Function
   @author user
   @since 24/04/2025
   @version version
   @param aJson, array de objetos json no qual será grado a planilha
          aDados, array com os dados que serão gerados na planilha
          aCab, array com os cabeçalhos que serão gerados na planilha
          cNAmeSheet, caracter, nome da sheet que será gerada na planilha
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getPlanSheet(aJson,aDados,aCab,cNameSheet,oProc)
local oi := 0
local aDetailAux := {}
local oJsonPlan := nil
local nLenJson := len(aJson)
   aDetailAux:={}
   oJsonPlan := getPlanJson(aDados,aCab)
   for oi:=1 to len(oJsonPlan)
      oProc:IncRegua1(cNameSheet + " " + STR0040 + " " + oJsonPlan[oi]['TITULO'] ) // "Gerando Relação de Prdutos/Gerando Relação de Operador Coluna
      aadd(aDetailAux,JsonObject():new())            
      aDetailAux[oi] := oJsonPlan[oi]
   next oi
   aadd(aJson,JsonObject():new())            
   aJson[nLenJson + 1][cNameSheet]  := aDetailAux
Return      

/*/{Protheus.doc} getEK9
   Função para carregar os catalogos de produtos

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oEasyTmp, objeto, objeto da classe EasyTemporaryTable        
          nRecEK9, numérico, recno da tabela EK9 posicionado
          nRecAlias, será atualizado com o recno do alias temporário para posicionamento na funcao ViewCatPrd
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function getEK9(oEasyTmp,nRecEK9,nRecAlias)
   local lRet       := .F.
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""
   local cAliasTmp  := CP403_TABLE
   local cFieldMark := REG_MARCA
   local cMarca     := MARCA
   local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
   local cEK9 := RetSqlName("EK9") + cInformix 

   default oEasyTmp   := EasyTemporaryTable():new()

   oEasyTmp:ClearTmp(cAliasTmp)
      cQuery := " SELECT "
      cQuery +=  " EK9_STATUS,"
      cQuery +=  " EK9_COD_I, "
      cQuery +=  " EK9_IDPORT, "
      cQuery +=  " EK9_VATUAL, "
      cQuery +=  " EK9_CNPJ, "
      cQuery +=  " EK9_NCM, "
      cQuery +=  " EK9_PRDREF, "
      cQuery +=  " EK9_DESC_I, "
      cQuery +=  " EK9_DSCCOM, "
      cQuery +=  " EK9.R_E_C_N_O_ " + cInformix + " RECEK9 "
      cQuery += " FROM " + cEK9 + " EK9 "
      cQuery +=  " WHERE EK9_MSBLQL <> ? AND EK9_STATUS <> ? AND EK9.D_E_L_E_T_ = ? AND EK9_FILIAL = ? "
      cQuery += " ORDER BY EK9_COD_I"

      oQuery := FWPreparedStatement():New(cQuery)      
      oQuery:SetString(1, '1' ) 
      oQuery:SetString(2, '4' ) 
      oQuery:SetString(3, ' ' ) 
      oQuery:SetString(4, xFilial('EK9')) 
      cQuery := oQuery:GetFixQuery()
      FwFreeObj(oQuery)

      cAliasQry := GetNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
   
   while (cAliasQry)->(!eof())
      lRet := .T.
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

      (cAliasTmp)->(msUnLock())
      (cAliasQry)->(dbSkip())
   end    

   (cAliasQry)->(dbCloseArea())
    
return lRet

/*/{Protheus.doc} getMarcado
   Função para verificar se tem algum item marcado para exportar para a planilha ou nao
   @type  Static Function
   @author user
   @since 01/04/2025
   @version version
   @param cAliasTmp, alias que sofrerá o select
   @return lRet, logico, .T. possui pelo menos um item marcado e seguirá o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getMarcado(nCount)
local cQuery := nil
local oQuery     := nil
local cAliasMarc  := GetNextAlias()
local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
local lRet:= nil
local cAliasTmp  := CP403_TABLE

cQuery := "SELECT COUNT(*) " + cInformix + "CONTADOR FROM " + TETempName(cAliasTmp) + " WHERE REG_MARCA = ? " 
oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString(1, 'X' ) 
cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)
cAliasMarc := GetNextAlias()
MPSysOpenQuery(cQuery, cAliasMarc)
nCount := (cAliasMarc)->(CONTADOR)
lRet := nCount # 0
fwFreeObj(oQuery)
Return lRet

/*/{Protheus.doc} getNcm
   Função para retornar os ncms envolvidos 
   @type  Static Function
   @author user
   @since 02/04/2025
   @version version
   @param cAliasTmp, alias que sofrerá o select
   @return aNcm, array, retorna os ncms dos catálogos selecionados
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getNcm()
local cQuery := nil
local oQuery     := nil
local cAliasNcm  := GetNextAlias()
local aNcm := {}
local cAliasTmp  := CP403_TABLE

cQuery := "SELECT EK9_NCM FROM " + TETempName(cAliasTmp) + " WHERE REG_MARCA = ? " 
cQuery += " GROUP BY EK9_NCM"
oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString(1, 'X' ) 
cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasNcm)
(cAliasNcm)->(dbGoTop())
   while (cAliasNcm)->(!eof())
      aadd(aNcm, (cAliasNcm)->EK9_NCM)
      (cAliasNcm)->(dbskip())
   end
fwFreeObj(oQuery)
Return aNcm

/*/{Protheus.doc} getCatalogo
   Função para retornar os código dos catálogos selecionados
   @type  Static Function
   @author user
   @since 02/04/2025
   @version version
   @param cAliasTmp, alias que sofrerá o select
   @return aCat, array, retorna os catálogos selecionados
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getCatalogo()
local cQuery := nil
local oQuery     := nil
local cAliasCat  := GetNextAlias()
local aCat := {}
local cAliasTmp  := CP403_TABLE

cQuery := "SELECT EK9_COD_I FROM " + TETempName(cAliasTmp) + " WHERE REG_MARCA = ? " 
oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString(1, 'X' ) 
cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasCat)
(cAliasCat)->(dbGoTop())
   while (cAliasCat)->(!eof())
      aadd(aCat, (cAliasCat)->EK9_COD_I)
      (cAliasCat)->(dbskip())
   end
fwFreeObj(oQuery)
Return aCat


/*/{Protheus.doc} getPrd
   Função para retornar os produtos envolvidos 
   @type  Static Function
   @author user
   @since 02/04/2025
   @version version
   @param aCatalogo, array com os catalgos selecioandos para a geração da planilha
   @return aPrd, array, retorna os ncms dos catálogos selecionados
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getPrd(aCatalogo)
local cQuery := nil
local oQuery     := nil
local cAliasEKA  := GetNextAlias()
local aPrd := {}
local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
local cEK9 := RetSqlName('EK9') + cInformix
local cEKA := RetSqlName('EKA') + cInformix

cQuery := "SELECT EK9.EK9_COD_I,EK9.EK9_IDPORT,EK9.EK9_VATUAL,COALESCE(EKA.EKA_PRDREF,'') " + cInformix + " EKA_PRDREF "
cQuery += " FROM " + cEK9 + " EK9 LEFT JOIN " + cEKA +" EKA ON (EK9.EK9_FILIAL = EKA.EKA_FILIAL AND EK9.EK9_COD_I = EKA.EKA_COD_I) "
cQuery += " WHERE EK9.EK9_COD_I IN (?) AND EK9.EK9_FILIAL = ? AND EK9.D_E_L_E_T_ = ? AND EKA.D_E_L_E_T_ = ? "
oQuery := FWPreparedStatement():New(cQuery)
oQuery:setIn(1, aCatalogo )
oQuery:setString(2, xFilial('EK9'))
oQuery:SetString(3, ' ')
oQuery:SetString(4, ' ')
cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasEKA)
(cAliasEKA)->(dbGoTop())
   while (cAliasEKA)->(!eof())
      aadd(aPrd, {(cAliasEKA)->EK9_COD_I, (cAliasEKA)->EK9_IDPORT, (cAliasEKA)->EK9_VATUAL, (cAliasEKA)->EKA_PRDREF})
      (cAliasEKA)->(dbskip())
   end
fwFreeObj(oQuery)
Return aPrd

/*/{Protheus.doc} getOpe
   Função para retornar os operadores estrangeiros e países envolvidos 
   @type  Static Function
   @author user
   @since 02/04/2025
   @version version
   @param aCatalogo, array com os catalgos selecioandos para a geração da planilha
   @return aOpe, array, retorna os operadores estrangeiros e países dos catálogos selecionados
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getOpe(aCatalogo)
local cQuery := nil
local oQuery     := nil
local cAliasEKB  := GetNextAlias()
local aOpe := {}
local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
local cEK9 := RetSqlName('EK9') + cInformix
local cEKJ := RetSqlName('EKJ') + cInformix
local cEKB := RetSqlName('EKB') + cInformix

cQuery := "SELECT EK9.EK9_COD_I,EK9.EK9_IDPORT,EK9.EK9_VATUAL,COALESCE(EKB.EKB_CODFAB,'') " + cInformix + " EKB_CODFAB,"  
cQuery += " COALESCE(EKB.EKB_LOJA,'') " + cInformix + " EKB_LOJA,"
cQuery += " COALESCE(EKJ.EKJ_TIN,'') " + cInformix + " EKJ_TIN,"
cQuery += " COALESCE(EKB.EKB_PAIS,'') " + cInformix + " EKB_PAIS "
cQuery += " FROM " + cEK9 + " EK9 LEFT JOIN " + cEKB + " EKB  ON (EK9.EK9_FILIAL = EKB.EKB_FILIAL AND EK9.EK9_COD_I = EKB.EKB_COD_I) "
cQuery += "                       LEFT JOIN " + cEKJ + " EKJ  ON (EK9.EK9_FILIAL = EKJ.EKJ_FILIAL AND EK9_CNPJ = EKJ.EKJ_CNPJ_R AND EKB.EKB_CODFAB = EKJ.EKJ_FORN AND EKB.EKB_LOJA = EKJ.EKJ_FOLOJA) "
cQuery += " WHERE EK9.EK9_COD_I IN (?) AND EK9.EK9_FILIAL = ? AND EK9.D_E_L_E_T_ = ? AND EKB.D_E_L_E_T_ = ? AND EKJ.D_E_L_E_T_ = ? "
oQuery := FWPreparedStatement():New(cQuery)
oQuery:setIn(1, aCatalogo )
oQuery:setString(2, xFilial('EK9'))
oQuery:SetString(3, ' ')
oQuery:SetString(4, ' ')
oQuery:SetString(5, ' ')
cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasEKB)
(cAliasEKB)->(dbGoTop())
   while (cAliasEKB)->(!eof())
      aadd(aOpe, {(cAliasEKB)->EK9_COD_I, (cAliasEKB)->EK9_IDPORT, (cAliasEKB)->EK9_VATUAL, (cAliasEKB)->EKB_CODFAB, (cAliasEKB)->EKB_LOJA, (cAliasEKB)->EKJ_TIN, (cAliasEKB)->EKB_PAIS})
      (cAliasEKB)->(dbskip())
   end
fwFreeObj(oQuery)
Return aOpe


/*/{Protheus.doc} getAtributos
   Função para pesquisa os códigos e nomes dos atributos do ncm enviado no parâmetro
   @type  Static Function
   @author user
   @since 02/04/2025
   @version version
   @param cNcm, caracter, ncm a ser pesquisado
   @return aAtributos, array Cód. Atributo, Nome do Atributo, Condicionante, Tipo, Multivalorado, Obrigatório, tamanho total, decimais 
   @example
   (examples)
   @see (links_or_references)
/*/
static function getAtributos(cNcm)
local aAtributos := {}
local aAtribAux := {}
local nAtr := 0
local nRes := 0

aAtribEKG := getEKG(cNcm)
aAtribAux :=  aClone(aAtribEKG)
// primiero pega todos os atributos que não sejam condicionantes de outro atributo
for nAtr := 1 to len(aAtribEKG)
   if empty(aAtribEKG[nAtr][4]) .and. (nRes := aScan(aAtribAux, {|x| x[4] == aAtribEKG[nAtr][3] })) == 0   
      aAdd(aAtributos, {aAtribEKG[nAtr][3],aAtribEKG[nAtr][5],aAtribEKG[nAtr][4],aAtribEKG[nAtr][6],aAtribEKG[nAtr][8],aAtribEKG[nAtr][9],aAtribEKG[nAtr][10],aAtribEKG[nAtr][11]})
   endif
next nAtr        

for nAtr :=1 to len(aAtribEKG) //continua com o processamento para os atibutos que possuam condicioandos e gera os filhos logo após o seu pai 
   if (nRes := aScan(aAtribAux, {|x| x[4] == aAtribEKG[nAtr][3] })) > 0         
      if aScan(aAtributos, {|x| x[1] == aAtribEKG[nAtr][3] }) == 0         
         aAdd(aAtributos, {aAtribEKG[nATr][3],aAtribEKG[nAtr][5],aAtribEKG[nAtr][4],aAtribEKG[nAtr][6],aAtribEKG[nAtr][8],aAtribEKG[nAtr][9],aAtribEKG[nAtr][10],aAtribEKG[nAtr][11]})   //atributo condicionante (pai)
      EndIf   
      Do while nRes <= len(aAtribAux) .and. aAtribAux[nRes][4] == aAtribEKG[nAtr][3]
         aAdd(aAtributos, {aAtribAux[nRes][3],aAtribAux[nRes][5],aAtribAux[nRes][4],aAtribAux[nAtr][6],aAtribAux[nAtr][8],aAtribAux[nAtr][9],aAtribAux[nAtr][10],aAtribAux[nAtr][11]}) //atributo condicionado (filho)        
         nRes += 1
      Enddo   
   endif          
next nAtr
aadd(aAtribNcm,{cNcm,aClone(aAtributos)})
Return aAtributos

/*
Funcao     : getEKG
Objetivo   : Gerar todos os atributos válidos e vigentes de um NCM
Parametros : cNCm - Ncm a ser pesquiado
Retorno    : aAtributos - array com os atributos do ncm pesquisado
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static Function getEKG(cNcm)
local aAtributos := {}
local cQuery := nil
local oQuery     := nil
local cEKG := RetSqlName("EKG") 
local dDataZero := cTod("00/00/0000")
local cAliasEKG  := GetNextAlias()

cQuery := "SELECT EKG_FILIAL,EKG_NCM,EKG_COD_I,EKG_CONDTE,EKG_NOME,EKG_FORMA,EKG_MODALI,EKG_MULTVA,EKG_OBRIGA,EKG_TAMAXI,EKG_DECATR FROM " + cEKG
cQuery += " WHERE EKG_FILIAL = ? AND EKG_NCM = ? AND EKG_MSBLQL <> ? "
cQuery += " AND (EKG_INIVIG <= ? OR EKG_INIVIG = ?) "
cQuery += " AND (EKG_FIMVIG >= ? OR EKG_FIMVIG = ?) "
cQuery += " AND EKG_CODOBJ like ? "
cQuery += " AND D_E_L_E_T_ = ? "
cQuery += " ORDER BY EKG_CONDTE"

oQuery := FWPreparedStatement():New(cQuery)      
oQuery:SetString(1, xFilial('EKG')) // EKG_FILIAL
oQuery:SetString(2, cNcm ) // EKG_NCM
oQuery:SetString(3, '1' ) // EKG_MSBLQL
oQuery:SetDate(4, dDatabase ) // EKG_INIVIG
oQuery:SetDate(5, dDataZero ) // EKG_INIVIG
oQuery:SetDate(6, dDatabase ) // EKG_FIMVIG
oQuery:SetDate(7, dDataZero ) // EKG_FIMVIG
oQuery:SetString(8,'%7%') // EKG_CODOBJ
oQuery:SetString(9,' ') // D_E_L_E_T_

cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)

MPSysOpenQuery(cQuery, cAliasEKG)
fwFreeObj(oQuery)
Do while (cAliasEKG)->(!eof())
   aAdd(aAtributos, {(cAliasEKG)->EKG_FILIAL, (cAliasEKG)->EKG_NCM, (cAliasEKG)->EKG_COD_I, (cAliasEKG)->EKG_CONDTE, (cAliasEKG)->EKG_NOME, (cAliasEKG)->EKG_FORMA, (cAliasEKG)->EKG_MODALIDADE, (cAliasEKG)->EKG_MULTVA, (cAliasEKG)->EKG_OBRIGA, (cAliasEKG)->EKG_TAMAXI, (cAliasEKG)->EKG_DECATR})  
   (cAliasEKG)->(dbSkip())
EndDo   
Return aAtributos


/*
Funcao     : getWorkSheet
Objetivo   : formatar o ncm com o texto "NCM" e o ncm em si com os separadores de ponto "."
Parametros : cNCm - Ncm a ser formatado
Retorno    : cWorSheet - NCM formatado com o texto NCM e o ncm em si com os separadores de ponto "." para ser usado como nome do folder da planilha
             Exemplo: NCM 1234.56.78
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getWorkSheet(cNcm)
local cWorkSheet := ''
cWorkSheet := STR0019 + ' ' + substr(cNcm,1,4) + '.' + substr(cNcm,5,2) + '.' + substr(cNcm,7,2) 
return cWorkSheet

/*
Funcao     : getCposEKS
Objetivo   : De/para para as colunas da planilha
Parametros : -
Retorno    : aCpos - Vetor com os campos {1-Campo, 2-Titulo, 3-ReadOnly_Campo, 4-Color_Campo, 5-ReadOnly_Titulo, 6-Color_Titulo,7-Tamanho dicionário,8-decimal,9-tipo, 10-tamanho célula excel, 11-repete o nome do campo para compatilizar com a EKG,12-atributo pai(vazio para a EK9),13-muti valorado(vazio para a EK9),14-obrigatório (vazio para a EK9),15-Alias}
Autor      : Bruno Akyo KubagawaRetorno    
Data       : Setembro/2022
*/
Static Function getCposEKS(aCpos,aCab)
local ni := 0
local nTamInt := 0
local nTamDec := 0
local cTitulo := ''
For ni:= 1 to len(aCab)
   nTamInt := getSX3Cache(acab[ni][1]    , "X3_TAMANHO")
   nTamDec := getSX3Cache(acab[ni][1]    , "X3_DECIMAL")
   cTitulo := getTit(acab[ni][1])   
   if nTamDec > 0
      nTamInt := nTamInt - nTamDec - 1
   EndIf      
   aAdd(aCpos, { cTitulo, acab[ni][1] , acab[ni][2]  , acab[ni][3] , acab[ni][4] , acab[ni][5] , nTamInt, nTamDec, getSX3Cache(acab[ni][1]    , "X3_TIPO"),getTamanho(acab[ni][1],cTitulo), acab[ni][1],'','','',acab[ni][6], acab[ni][7], acab[ni][8] })
next ni
RETURN 

Static Function getTit(cCampo)
local cCampoVisu := ''
local cRet := ''
Do case
   Case cCampo == 'EK9_IDMANU'
        cCampoVisu := 'EK9_IDPORT'
   case cCampo == 'EK9_VSMANU'
        cCampoVisu := 'EK9_VATUAL'
   otherwise 
        cCampoVisu := cCampo
EndCase
cRet := alltrim(AvSx3(cCampoVisu    , AV_TITULO)) 
Do case
   Case cCampo == 'EK9_DESC_I'
        cRet += ' ' + STR0003 //Catálogo de Produtos
   case cCampo == 'YD_DESC_P'
        cRet += ' ' + STR0019 //NCM
   case cCampo == 'YD_UNID'
        cRet += ' ' + STR0019 //NCM
   otherwise 
        cCampoVisu := cCampo
EndCase
Return cRet


/*
Funcao     : getCposPlan
Objetivo   : De/para para as colunas da planilha
Parametros : -
Retorno    : aCpos - Vetor com os campos {1-Campo, 2-Titulo, 3-ReadOnly_Campo, 4-Color_Campo, 5-ReadOnly_Titulo, 6-Color_Titulo,7-Tamanho dicionário,8-decimal,9-tipo,10-tamanho célula excel,11-repete o código do atributo,12-atributo pai,13-muti valorado, 14-obrigatóri
Autor      : Bruno Akyo Kubagawa
Data       : Setembro/2022
*/
Static Function getCposEKG(aCpos,aCab)
local ni := 0
local cTit := getTitCond()
local nTamInt := 0
local nTamDec := 0   
For ni:= 1 to len(aCab)
   nTamInt := acab[ni][7]
   nTamDec :=  acab[ni][8]
   if nTamDec > 0
      nTamInt := nTamInt - nTamDec 
   EndIf 
   aAdd(aCpos, {alltrim(acab[ni][1]) , alltrim(acab[ni][2]), 'false' , COR_DEFAULT , 'true' , COR_TITULO , nTamInt , nTamDec, getTipo(acab[ni][4]),getTamEKG(acab[ni],cTit),alltrim(acab[ni][1]),if(!Empty(acab[ni][3]),cTit + alltrim(acab[ni][3]),''),acab[ni][5],acab[ni][6]})
next ni
RETURN 

/*
Funcao      : getPrdJson()
Parâmetros  :
Retorno     : Retorna o json dos produtos com todas as informações a serem geradas na planilha
Objetivos   : REtornar um json com as informações para gerar a planilha
Autor       : Maurício Frison
Data        : Setembro/2022
*/

static function getPlanJson(aDados,aCab)
Local oJson := jsonobject():New()
Local aJson := {}, aDetails := {}
Local aJsonTitulos := {}
Local aCpos := {}
Local nLenAcpos := 0
local nCountCab := 0
local nCountRow := 0
Local nLinTotCab := 0 //retorna o número de linhas do cabeçalho além da linha principal

getCposEKS(@aCpos,aCab) //carrega os campos da EK9 que serão utilizados na planilha 
nLenAcpos := len(aCpos)
nLenAcpost := nLenAcpos
nCountCab := getCabPlan(@aJsonTitulos,@aDetails,aCpos,nLenACpos,nLenACposT,nLinTotCab)
nCountRow := getRowPlan(aCpos,@aDetails,nLenACpos,aDados)
aJson := getaJson(nLenACposT,aJsonTitulos,aDetails,aCpos,nLinTotCab + nCountRow)
oJson:set(aJson)  
return oJson


/*
Funcao      : getNcmJson()
Parâmetros  :
Retorno     : Retorna o json do ncm correspondente pronto com todas as informações a serem geradas na planilha
Objetivos   : REtornar um json com as informações para gerar a planilha
Autor       : Maurício Frison
Data        : Setembro/2022
*/

static function getNcmJson(cNcm)
Local oJson := jsonobject():New()
Local aJson := {}, aDetails := {}
Local aJsonTitulos := {}
Local aAtributos := {}
Local aCpos := {}
Local nLenAcpos := 0
local nCountRow := 0
local nLinTotCab := 2 //retorna o número de linhas do cabeçalho além da linha principal

getCposEKS(@aCpos,getCabNcm()) //carrega os campos da EK9 que serão utilizados na planilha 
nLenAcpos := len(aCpos)
aAtributos := getCposEKG(@aCpos,getAtributos(cNcm)) //carrega os campos da EK9 que serão utilizados na planilha
nLenAcposT := len(aCpos)

getCabPlan(@aJsonTitulos,@aDetails,aCpos,nLenACpos,nLenACposT,nLinTotCab)
nCountRow := getNcmRow(aCpos,@aDetails,nLenACpos,cNcm)
aJson := getaJson(nLenACposT,aJsonTitulos,aDetails,aCpos,nLinTotCab + nCountRow)
oJson:set(aJson)  
return oJson

/*
Funcao     : getaJson
Objetivo   : gera um array de json com todos os títulos, dados, validações e anotações para gerar a planilha
Parametros : nLenAcposT - tamanho de todas as colunas a serem geradas na planilha (ek9+ekg)
             aJsonTitulos - array com os títulos dos campos que serão utilizados na planilha
             aDetails - array com os detalhes dos campos que serão utilizados na planilha
             aCpos - array com os campos que serão utilizados na planilha
             nConttot - total de cabeçalhos e linhas que serão utilizados na planilha
Retorno    : aJson - retorna um array com todos os títulos, dados, validações e anotações para gerar a planilha
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static function getaJson(nLenACposT,aJsonTitulos,aDetails,aCpos,nCountTot)
local i :=0, k := 0
local aDetailAux,aDetail2 := {}
local xValor := nil
local cColor := ''
local cValid := ''
local cFrm := ''
local aJson := {}
local oJson := nil

//monta json final
for i:=1 to nLenACposT
    //carrega jason com os atributos do cabeçalho
    Aadd(aJson,JsonObject():new())
    aJson[i] := aJsonTitulos[i]

   //carrega jason com os atributos dos campos
   aDetailAux:={}
   Aadd(aDetailAux,JsonObject():new())
   aDetailAux[1]['READONLY'] := aCpos[i][3]

   Aadd(aDetailAux,JsonObject():new())
   aDetailAux[2]['COLOR'] := aCpos[i][4]
   aJson[i]['DETAILS'] := aDetailAux
    
   //carrega jason com os valores dos campos na vertical (com o campo, seus atributos e com todos os seus valores que vieram da tabela e depois vai para o próximo campo e etc...) 
   aDetailAux:={}    
   for k:=1 to nCountTot      
       aadd(aDetailAux,JsonObject():new())       
       aDetails[k][i]:GetJsonValue("VALOR", @xValor)
       aDetailAux[k]['VALOR'] := xValor
       if aDetails[k][i]:GetJsonValue("COLOR", @cColor)  //para as colunas de valor não enviar a cor, vai respeitar a cor da coluna     
          aDetailAux[k]['COLOR'] := cColor
       EndIf   
       if aDetails[k][i]:GetJsonValue("VALID", @cValid)          
          oJson := JsonObject():New()
		    oJson:FromJson(cValid)
          aDetail2 := {}
          aadd(aDetail2,JsonObject():new())            
          aDetail2[1] := oJson
          aDetailAux[k]['VALID'] := aDetail2 
       EndIf   
       if aDetails[k][i]:GetJsonValue("FORMAT", @cFrm)  
          aDetailAux[k]['FORMAT'] := cFrm
       EndIf   
   next K    
   aJson[i]['VALORES'] := aDetailAux
next i
Return aClone(aJson)

/*
Funcao     : getVlrCampo
Objetivo   : apura o maior tamannho entre o dicionário, a definicção do dicionário
Parametros : aCab - array com os campos e configurações da EKG para a geração na planilha
             cTit - título do campo que será utilizado na planilha
Retorno    : nRet - retorna o maior valor apurado
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getVlrCampo(cAliasTmp,cCampo,cTipo,cPosicione,lCombo)
Local xRetorno := '',cVar:=''
cVar := (cAliasTmp)+'->'+cCampo 
if !empty(cPosicione)
   &cPosicione
EndIf
Do Case       
//AINDA NÃO TEM CAMPO DO TIPO DATA, QUANDO TIVER, DESFAZER ESSE COMENTÁRIO
/*    Case cTipo == "D"
         xRetorno :=dtoc(sTod(&cVar))*/
      Case cTipo == "M"         
         xRetorno :=TiraEnter(alltrim(&cVar))
   otherWise    
   xRetorno := If(ValType(&cVar)=="C",rtrim(&cVar),&cVar) 
EndCase
if lCombo //se o campo for combo, pega o valor do combo
   xRetorno := X3Combo(cCampo, xRetorno)
EndIf   
return xRetorno

/*
Funcao     : getTamanho
Objetivo   : determinar a largura da coluna ser gerada no excel, pega o tamanho definido no dicionário ou tamanho do título, o que for maior
Parametros : -cCampo: Campo a ser determinada a largura da coluna
Retorno    : nTam: largura da coluna                
             cTitulo: Título do campo a ser determinada a largura da coluna
Autor      : Maurício Frison
Data       : Setembro/2022
*/
static function getTamanho(cCampo,cTitulo)
Local nTamDic := getSX3Cache(cCampo,"X3_TAMANHO") + getSX3Cache(cCampo,"X3_DECIMAL")
Local nTamTit := LEN(cTitulo)
Local nTam := if(nTamDic > nTamTit, nTamDic, nTamTit) + 2
return nTam


/*
Funcao     : getTamEKG
Objetivo   : apura o maior tamannho entre o dicionário, a definicção do dicionário
Parametros : aCab - array com os campos e configurações da EKG para a geração na planilha
             onde aCab[1] - é código do atribuo
                  aCab[2] - é o nome do atributo
                  aCab[3] - é o condicionante do atributo
                  aCab[7] - é o tamanho do atributo na EKG
             cTit - título do campo que será utilizado na planilha
Retorno    : nRet - retorna o maior valor apurado
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getTamEKG(aCab,cTit)
local aValores :=  {}
local nRet := 0
aadd(aValores,len(alltrim(acab[1])))
aadd(aValores,len(alltrim(acab[2])))
aadd(aValores,len(cTit + alltrim(acab[3])))
aadd(aValores,aCab[7])
ASORT(aValores,,, { |x, y| x > y } )
nRet := aValores[1] + 2
return nRet


/*
Funcao     : getCabNcm
Objetivo   : gerar um array com os campos e configurações da EK9 para a geração na planilha
Parametros : 
Retorno    : Retorna array com os campos da EK9 e configurações para montagem do título 
             Retorna  Vetor com os campos {Campo, ReadOnly_Campo, Color_Campo, ReadOnly_Titulo, Color_Titulo, Alias, Posicione}, se é campo do tipo Combo
Autor      : Maurício Frison
Data       : 15/04/2025
*/

static function getCabNcm() 
local aCabNcm := {}
aadd(acabNcm,{'EK9_FILIAL','true', COR_CAMPO,  'true',COR_TITULO,'EK9','',.f.})
aadd(acabNcm,{'EK9_COD_I', 'true', COR_CAMPO,  'true',COR_TITULO,'EK9','',.f.})
aadd(acabNcm,{'EK9_CNPJ',  'false',COR_DEFAULT,'true',COR_TITULO,'EK9','',.f.})
aadd(acabNcm,{'EK9_MODALI','true', COR_CAMPO,  'true',COR_TITULO,'EK9','',.t.})
aadd(acabNcm,{'EK9_DESC_I','false',COR_DEFAULT,'true',COR_TITULO,'EK9','',.f.})
aadd(acabNcm,{'YD_DESC_P', 'true', COR_CAMPO,  'true',COR_TITULO,'SYD','Posicione("SYD", 1, xFilial("SYD")+EK9->(EK9_NCM), "YD_DESC_P")',.f.})
aadd(acabNcm,{'YD_UNID',   'true', COR_CAMPO,  'true',COR_TITULO,'SYD','Posicione("SYD", 1, xFilial("SYD")+EK9->(EK9_NCM), "YD_UNID")',.f.})
aadd(acabNcm,{'EK9_IDMANU','false',COR_DEFAULT,'true',COR_TITULO,'EK9','',.f.})
aadd(acabNcm,{'EK9_VSMANU','false',COR_DEFAULT,'true',COR_TITULO,'EK9','',.f.})
aadd(acabNcm,{'EK9_DSCCOM','false',COR_DEFAULT,'true',COR_TITULO,'EK9','',.f.})
aadd(acabNcm,{'EK9_OBSINT','false',COR_DEFAULT,'true',COR_TITULO,'EK9','',.f.})
Return aClone(aCabNcm)

/*
Funcao     : getCabPrd
Objetivo   : gerar um array com os campos e configurações da EK9 e EKA da aba Produtos para a geração na planilha
Parametros : 
Retorno    : Retorna array com os campos da EK9 e EKA configurações para montagem do título 
             Retorna  Vetor com os campos {Campo, ReadOnly_Campo, Color_Campo, ReadOnly_Titulo, Color_Titulo,Alias(somente para a getCabNcm),Posicione(somente para a getCabNcm), se é campo do tipo Combo}
Autor      : Maurício Frison
Data       : 15/04/2025
*/

static function getCabPrd() 
local aCabPrd := {}
aadd(acabPrd,{'EK9_COD_I','false',COR_CAMPO,'true',COR_TITULO,'','',.f.})
aadd(acabPrd,{'EK9_IDPORT','false',COR_CAMPO,'true',COR_TITULO,'','',.f.})
aadd(acabPrd,{'EK9_VATUAL','false',COR_CAMPO,'true',COR_TITULO,'','',.f.})
aadd(acabPrd,{'EKA_PRDREF','false',COR_DEFAULT,'true',COR_TITULO,'','',.f.})
Return aClone(aCabPrd)

/*
Funcao     : getCabOpe
Objetivo   : gerar um array com os campos e configurações da EK9 e EKB da aba Fabricantes para a geração na planilha
Parametros : 
Retorno    : Retorna array com os campos da EK9 e EKB configurações para montagem do título 
             Retorna  Vetor com os campos {Campo, ReadOnly_Campo, Color_Campo, ReadOnly_Titulo, Color_Titulo, Alias(somente para a getCabNcm)}, Posicione(somente para a getCabNcm), se é campo do tipo Combo}
Autor      : Maurício Frison
Data       : 15/04/2025
*/

static function getCabOpe() 
local aCabOpe := {}
aadd(acabOpe,{'EK9_COD_I', 'false', COR_CAMPO,  'true',COR_TITULO,'','',.f.})
aadd(acabOpe,{'EK9_IDPORT','false', COR_CAMPO,  'true',COR_TITULO,'','',.f.})
aadd(acabOpe,{'EK9_VATUAL','false', COR_CAMPO,  'true',COR_TITULO,'','',.f.})
aadd(acabOPe,{'EKB_CODFAB','false', COR_DEFAULT,'true',COR_TITULO,'','',.f.})
aadd(acabOpe,{'EKB_LOJA',  'false', COR_DEFAULT,'true',COR_TITULO,'','',.f.})
aadd(acabOpe,{'EKJ_TIN',   'false', COR_CAMPO,'  true',COR_TITULO,'','',.f.})
aadd(acabOPe,{'EKB_PAIS',  'false', COR_DEFAULT,'true',COR_TITULO,'','',.f.})
Return aClone(aCabOpe)


/*
Funcao     : getTipo
Objetivo   : fazer conversao dos tipos de campo da EKC ekc_Forma com os tipos de campos do dicionário sx3
Parametros : cTipo - tipo do campo da EKC, ekc_Forma
Retorno    : Retorna o tipo de dado correspondente no protheus (sx3)
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getTipo(cTipo)
local cRet:=''
Local cTipoLoc := alltrim(cTipo)
do Case
   Case cTipoLoc == 'BOOLEANO'
      cRet := 'L'
   Case 'NUMERO' $ cTipoLoc
      cRet := 'N'
   otherWise
      cRet := 'C'
EndCase
Return cRet      


/*
Funcao     : getCabPlan
Objetivo   : gerar o jSon com os cabeçalhos da EK9 e da EKC que serão gerados na planilha
Parametros : aJsonTitulos - array de json onde serão gerados os títulos dos campos
             aDetails - array com os valores e configurações dos títulos
             aCpos - Campos da tabela EK9 e EKC que serão utilizados na planilha
             nLenAcpos - número de campos da EK9 para o controle de geração dos títulos
             nLenAcposT - número de campos Total da EK9 + EKC para o controle de geração dos títulos
             cNcm - ncm a ser pesquisado
Retorno    : 
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static function getCabPlan(aJsonTitulos,aDetails,aCpos,nLenACpos,nLenACposT,nLinTotCab)
Local k:=0,i:=0
Local aDetailAux:={}
Local cNote :=''
//carrega jason com títulos
For i:=1 to nLenACposT
    cNote := ''
    if(aCpos[i][14]=='1')
      cNote += '* ' + STR0023  + ENTER //"Campo obrigatório"  
    EndIf
    if(aCpos[i][13]=='1')
      cNote += STR0024 + ENTER //'Campo multivalorado deve ser informado com os valores seprados por ponto e vírgula (;)'
    Endif      
    if(aCpos[i][8] > 0 .And. aCpos[i][9] == "N")
      cNote += STR0037  + ENTER //'Para a importação dos dados, será considerado o valor exibido na célula, conforme a formatação de decimais configurada no atributo'
    EndIf

    AADD(aJsonTitulos,JsonObject():new())
    aJsonTitulos[i]['TITULO'] := aCpos[i][1]
    aJsonTitulos[i]['READONLY'] := aCpos[i][5]
    aJsonTitulos[i]['COLOR'] := aCpos[i][6]
    aJsonTitulos[i]['TAMANHO'] := aCpos[i][10]
    aJsonTitulos[i]['NOTE'] := cNote
next i 

for  k :=1 to nLinTotCab
      // carrega dois em branco para equalizar com o tamanho do título dos atributos que usam 3 linhas
      aDetailAux:={}
      for i:=1 to nLenACpos  
         oJson := JsonObject():new()
         oJson['VALOR'] := ' '
         oJson['COLOR'] := COR_TITULO
         AADD(aDetailAux,oJson)  
      next i
      
      //carrega linha 2 e 3 do cabeçalho dos atributos         
      nPos := if(k==1,2,12)
      for i:= nLenAcpos + 1 to nLenAcposT            
         oJson := JsonObject():new()
         oJson['VALOR'] :=  if(aCpos[i][14]=='1' .and. k == 1,'* ','') + aCpos[i][nPos]
         oJson['COLOR'] := COR_TITULO
         AADD(aDetailAux,oJson)  
      next i
      AADD(aDetails,aDetailAux)
next k     
Return 

/*
Funcao     : getNcmPlan
Objetivo   : gerar o jSon com os campos e validações da EK9 e da EKC em uma única linha
Parametros : aCpos - Campos da EK9 e EKC que serão utilizados na planilha
             aDetails - array com os valores dos campos da EK9 e EKC
             nLenAcpos - número de campos da EK9 para percorrer o array e preencher os valores
             cNcm - ncm a ser pesquisado
Retorno    : Retorna o número de linhas geradas
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getNcmRow(aCpos,aDetails,nLenACpos,cNcm)
local i := 0, ni := 0, nPos := 0
local nCountRow := 0
local cAtr := ''
local cValor := ''
local aDetailAux := {}
local aAtrib := {}
local cAliasTmp  := CP403_TABLE
local cTipo := ''

//carrega json com os valores da tabela EK9(Catálogo) e EKC(Atraibutos) na horizonta (tipo grid)
(cAliasTmp)->(dbGoTop())
While !(cAliasTmp)->(Eof()) 
   if (cAliasTmp)->EK9_NCM == cNcm
      nCountRow += 1
      aDetailAux:={}
      EK9->(dbGoTo((cAliasTmp)->RECEK9))  
      //carrega dados da EK9
      aDetailAux:={}
      for i:=1 to nLenACpos          
            oJson := JsonObject():new()
            oJson['VALOR'] := getVlrCampo(aCpos[i][15],aCpos[i][11],aCpos[i][9],aCpos[i][16],aCpos[i][17]) 
            oJson['VALID'] := getVld(aCpos[i][7],aCpos[i][8],aCpos[i][9]) //Tamanho inteiro, tamanho decimal, tipo
            oJson['FORMAT'] := getFrm(aCpos[i][7],aCpos[i][8],aCpos[i][9])
            AADD(aDetailAux,oJson)  
      next i
      //Carrega dados da EKC
      nPos := aScan(aAtribNcm, {|x| x[1] == cNcm}) 
      if nPos > 0
         aAtrib := aClone(aAtribNcm[nPos][2])
         for nI:= 1 to len(aAtrib)
            cAtr := aAtrib[nI][1]
            cTipo := getTipo(aAtrib[ni][4])
            cValor := getValor(cAtr,cTipo)
            oJson := JsonObject():new()
            oJson['VALOR'] := cValor
            oJson['VALID'] := getVld(aAtrib[nI][7],aAtrib[nI][8],cTipo,aAtrib[ni][4]) //Tamanho inteiro, tamanho decimal, tipo, forma
            oJson['FORMAT'] := getFrm(aAtrib[nI][7],aAtrib[nI][8],cTipo,aAtrib[ni][4])
            AADD(aDetailAux,oJson)  
         next nI
      EndIf   
      AADD(aDetails,aDetailAux)       
    EndIf
    (cAliasTmp)->(DbSkip())			
EndDo
Return nCountRow

/*
Funcao     : getPrdRow
Objetivo   : gerar o jSon com os campos e validações dos produtos dos catálogos selecionados para gerar a planilha
Parametros : aCpos - Campos da EK9 e EKA que serão utilizados na planilha
             aDetails - array com os valores dos campos da EK9 e EKA
             nLenAcpos - número de campos para percorrer o array e preencher os valores
Retorno    : Retorna o número de linhas geradas
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getRowPlan(aCpos,aDetails,nLenACpos,aDados)
local i := 0, na := 0
local nCountRow := 0
local aDetailAux := {}
//carrega json com os valores do array de produrtos na horizontal (tipo grid)
for na := 1 to len(aDados)   
      nCountRow += 1
      aDetailAux:={}      
      //carrega dados da EK9
      aDetailAux:={}
      for i:=1 to nLenACpos          
            oJson := JsonObject():new()
            oJson['VALOR'] := aDados[na][i]
            oJson['VALID'] := getVld(aCpos[i][7],aCpos[i][8],aCpos[i][9]) //Tamanho inteiro, tamanho decimal, tipo
            oJson['FORMAT'] := getFrm(aCpos[i][7],aCpos[i][8],aCpos[i][9])
            AADD(aDetailAux,oJson)  
      next i      
      AADD(aDetails,aDetailAux)       
   
Next na
Return nCountRow


/*
Funcao     : getVld
Objetivo   : gerar a string do json para validação do excel de acordo com o tipo do campo 
Parametros : nTam  - Tamanho do campo
             nDec  - Tamanho dos decimais do campo
             cTipo - tipo do campo (Caracter, Numérico, Data, Lógico, Memo)
             cForma - forma do campo (Texto, Inteiro, Decimal, Lista_Estatica, Lista_Dinâmica)
Retorno    : Retorna a string de acordo do tipo da validação do campo 
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getVld(nTam,nDec,cTipo,cForma)
Local cValid := ''
default cForma := ''
cForma := alltrim(cForma)
if (cTipo == "C" .and. empty(cForma)) .or. cForma = "TEXTO"
   cValid := getTexto(nTam)
ElseIf (cTipo == "N" .and. empty(cForma) .and. nDec == 0) .or. cForma == "NUMERO_INTEIRO"   
   cValid := getInteiro(nTam)
ElseIf (cTipo == "N" .and. empty(cForma) .and. nDec != 0) .or. cForma == "NUMERO_REAL" 
   cValid := getDecimal(nTam,nDec)
ElseIf (cTipo == "L" .and. empty(cForma) ) .or. cForma == 'BOOLEANO'
   cValid := getBooleano()
EndIf   
return cValid

/*
Funcao     : getFrm
Objetivo   : gerar a formataçaõ de campos decimais para enviar para a planilha
Parametros : nTam  - Tamanho do campo
             nDec  - Tamanho dos decimais do campo
             cTipo - tipo do campo (Caracter, Numérico, Data, Lógico, Memo)
             cForma - forma do campo (Texto, Inteiro, Decimal, Lista_Estatica, Lista_Dinâmica)
Retorno    : Retorna a string do json de acordo do tipo da validação do campo 
Autor      : Maurício Frison
Data       : 15/04/2025
*/
static function getFrm(nTam,nDec,cTipo,cForma)
Local cFrm := ''
default cForma := ''
cForma := alltrim(cForma)
if (cTipo == "N" .and. empty(cForma) .and. nDec != 0) .or. cForma == "NUMERO_REAL" 
   cFrm := '0.' + replicate('0',nDec)
EndIf   
return cFrm

/*
Funcao     : getTexto
Objetivo   : gerar a string do json para validação do excel do campo do tipo string
Parametros : nTam  - Tamanho do campo
Retorno    : Retorna a string do json do tipod de validação string do excel
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static function getTexto(nTam)
local cRet := ''
local aFormula := {nTam + 1} //a validação é lessThan entao tem que somar um 
local oJson := JsonObject():new()
   oJson['type'] := 'textLength'
   cMsg := 'Por favor, insira um valor com no máximo ' + alltrim(str(nTam)) + ' posições'
   getGeral(@oJson,aFormula,cMsg)
   cRet := oJson:toJson()
Return cRet   

/*
Funcao     : getInteiro
Objetivo   : gerar a string do json para validação do excel do campo do tipo inteiro
Parametros : nTam  - Tamanho do campo
Retorno    : Retorna a string do json do tipod de validação inteiro do excel
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static function getInteiro(nTam)
local oJson := JsonObject():new()
local nfinal := val(replicate('9',nTam))
local aFormula := {nFinal + 1 }
   oJson['type'] := 'whole'   
   cMsg := 'Por favor, insira um número inteiro entre 0 e ' + allTrim(str(nFinal))
   getGeral(@oJson,aFormula,cMsg)   
   cRet := oJson:toJson()
Return cRet   

/*
Funcao     : getDecimal
Objetivo   : gerar a string do json para validação do excel do campo do tipo Decimal 
Parametros : nTam  - Tamanho do campo
             nDecimal -Tamanho dos decimais do campo
Retorno    : Retorna a string do json do tipod de validação decimal do excel
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static function getDecimal(nTam,nDecimal)
local oJson := JsonObject():new()
local nfinal := val(replicate('9',nTam)+'.'+ replicate('9',nDecimal))
local aFormula := {nFinal + 1}
   oJson['type'] := 'decimal'  
   cMsg := 'Por favor, insira um número entre 0 e ' + allTrim(str(nFinal)) 
   getGeral(@oJson,aFormula,cMsg)   
   cRet := oJson:toJson()
Return cRet   

/*
Funcao     : getBooleano
Objetivo   : gerar a string do json com uma lista Sim ou Não para validação do excel do campo do tipo booleano
Parametros : 
Retorno    : Retorna a string do json com a lista Sim ou Não para validação booleano do excel
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static function getBooleano()
local oJson := JsonObject():new()
   oJson['type'] := 'boolean' //desenvolvido dentro da funcao javascript expGeraXls
   cRet := oJson:toJson()
Return cRet   

/*
Funcao     : getGeral
Objetivo   : gerar as propriedades padrões do validador do excel
Parametros : oJson - json que será gerado
            aFormula - array com as formula de validação
            cMsg - mensagem de erro que será exibida na planilha
Retorno    : Sem retorno
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static function getGeral(oJson,aFormula,cMsg)
   oJson['operator'] := 'lessThan'
   oJson['showErrorMessage'] := .t.
   oJson['allowBlank'] := .t. 
   oJson['errorTitle'] := STR0025
   oJson['error'] := cMsg 
   oJson['formulae'] := aFormula
Return   

/*
Funcao     : getValor
Objetivo   : gerar o valor de acordo com o tipo
Parametros : cAtr - código do atributo
             cTipo - tipo do atributro
Retorno    : cValor, retorna o valor que pode ser numérico
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static Function getValor(cAtr,cTipo)
cValor := if(EKC->(DBSEEK(xFilial('EKC') + EK9->EK9_COD_I + cAtr)), alltrim(EKC->EKC_VALOR), ' ')    
if cTipo == "L"
   cValor := if(cValor=='1','Sim','Nao')
elseif cTipo == "N"
   cValor := val(cValor)
EndIf   
Return cValor

/*
Funcao     : showDlg
Objetivo   : gerar uma tela com as opções para a gravação do arquivo
Parâmetro  : cArqName - nome do arquivo a ser gerado
Retorno    : lOpc, se .t. o usuário confirmou a gravação do arquivo, se .f. abortar
Autor      : Maurício Frison
Data       : 15/04/2025
*/
Static Function showDLG()
   Local oDlg
   Local lOpc //Valor lógico informando se as informações foram confirmadas ou se o usuário cancelou a operação
   Local nCol := 10, nLinha := 10
   Local nLinhaFim := 340
      
   DEFINE MSDIALOG oDlg TITLE STR0030 From 0,0 to nLinhaFim,500 PIXEL //"Parâmetros para geraçãdo da planilha"
      @ nLinha, nCol Say STR0029 of oDlg Pixel //"Nome do Arquivo"
      nLinha += 10
     
      @ nLinha, nCol MsGet cNomeXls Size 230,10 Valid(valParam("NomeXLS")) of oDlg Pixel
      nLinha += 15
      @ nLinha, nCol Say STR0031 of oDlg Pixel //"Diretório"
      nLinha += 10
      @ nLinha, nCol MsGet cDestXLS Size 200,10 Valid(valParam("DestXLS")) of oDlg Pixel
      nLinha += 15
     
      @ nLinha, nCol+123 Button STR0027 Size 50,15 Action(lOpc := .T., oDlg:End()) of oDlg Pixel // OK
      @ nLinha, nCol+178 Button STR0028 Size 50,15 Action(lOpc := .F., oDlg:End()) of oDlg Pixel // "Cancelar"

      Define SBUTTON From 45, 212 Type 14 Action(selDir()) enable of oDlg Pixel      

   ACTIVATE MSDIALOG oDlg Centered

   cNomeXLS := AltCaracter(cNomeXLS)
      

Return lOpc

/*------------------------------------------------------------------------------------
Funcao      : selDir
Parametros  :
Retorno     :
Objetivos   : Apresentar uma Dialog para o usuário selecionar o diretório desejado
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function selDir()
   Local cTitle:= STR0026//"Selecione o Diretório"
   Local cMask := ""//"Arquivo Excel|*.xls"
   Local nDefaultMask //:= 0
   Local cDefaultDir  := GetTempPath()
   Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY
   Local cPath

   cPath := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions)

   If Empty(cPath)
      Return cDestXLS
   Else
      cDestXLS := cPath + space(len(cDestXLS) - len(cPath)) // mantem o tamanho da msGet de 150 caracteres
   EndIf
Return


/*------------------------------------------------------------------------------------
Funcao      : ValParam
Parametros  : Campo para validação
Retorno     : Valor lógico - .T. a informação do campo é válida, .F. a informação não é válida
Objetivos   : Validar as informações da Dialog da função showDLGEmail
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function ValParam(cCampo)
   Local lRet := .T.
   Local aDir := nil
   Local cTempXLS := nil
   If cCampo == "NomeXLS"
      If Len(alltrim(cNomeXLS)) < 3
         Alert(STR0035) //"Insira um nome de arquivo válido."
         lRet := .F.
      EndIf
   ElseIf cCampo == "DestXLS"
      If RAT("\",cDestXLS) == len(alltrim(cDestXLS))
         cTempXLS := subStr(cDestXLS,1,len(alltrim(cDestXLS))-1)
      Else
         cTempXLS := cDestXLS
      EndIf
      aDir := Directory(cTempXLS,"D")
      //if len(aDir) == 0 WFS 13/08/09
      If (Len(aDir) == 0 .Or. !lIsDir(cTempXLS)) .And. Upper(AllTrim(cTempXLS)) <> GetTempPath()

         Alert(STR0036) //"Insira um diretório de destino válido."
         lRet := .F.

      EndIf
   EndIf


Return lRet

/*------------------------------------------------------------------------------------
Funcao      : AltCaracter
Parametros  : cFile - Nome do arquivo que será salvo
Retorno     : String com o nome do arquivo corrigido
Objetivos   : Retirar caracteres não reconhecidos pelas chamadas do Protheus
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function AltCaracter(cFile)
   cFile := alltrim(cFile)
   cFile := strTran(cFile,"'","_")
   cFile := strTran(cFile,"/","_")
   cFile := strTran(cFile,"\","_")
   cFile := strTran(cFile,"(","_")
   cFile := strTran(cFile,")","_")
   cFile := strTran(cFile,",","_")
   cFile := strTran(cFile,";","_")
   cFile := strTran(cFile,"*","_")
   cFile := strTran(cFile,"$","_")
   cFile := strTran(cFile,"@","_")
   cFile := strTran(cFile,"!","_")
   cFile := strTran(cFile,"|","_")
   cFile := strTran(cFile,":","_")
   cFile := strTran(cFile,"?","_")
   cFile := strTran(cFile,"<","_")
   cFile := strTran(cFile,">","_")
   cFile := strTran(cFile,'"',"_")
   cFile := strTran(cFile,"-","_")
   cFile := strTran(cFile," ","_")
return cFile


/*------------------------------------------------------------------------------------
Funcao      : TiraEnter
Parametros  : cString  - String a ser retirado os enters
Retorno     : String sem enter
Objetivos   : Retirar caractere de enter
Autor       : Maurício Frison
Data/Hora   : 22/04/25
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function TiraEnter(cStr)
Return strtran(cStr,Chr(13)+Chr(10),"")

/*/{Protheus.doc} CP403ImpXls
   Função utilizada para importar o arquivo excel com os dados do catálogo de produtos e incluir ou atualizar os dados
   @type  Function
   @author user
   @since 13/05/2025
   @version version
   @param 
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Function CP403ImpXls()
Local cArquivo  := ""
Local cArqNome  := ""
Local aTemp     := {}
Local cJson     := ""
Local oJson     := JsonObject():New()
Local cAliasTmp := GetNextAlias()
Local _aTabsTmp := {}
Local lProcess  := .F.
Local oProc     := nil

   cArquivo := cGetFile(STR0044, STR0045, 0,,,GETF_LOCALHARD, .F.)//"Arquivos Excel (*.xlsx)|*.xlsx"###"Diretório local para importação do catálogo de produtos"
   If File(cArquivo)
      FWMsgRun(, {|oSay| cJson := ImpXlsJson(cArquivo) }, STR0081, STR0046)//"Importar da Planilha"###"Abrindo arquivo selecionado..."
      Begin Sequence
         If !Empty(cJson)
            oJson:FromJson(cJson)
            FWMsgRun(, {|oSay| lProcess := isHdrVld(oJson) }, STR0081, STR0047)// "Importar da Planilha"###"Validando arquivo a ser Importado..."
            If !lProcess
               EasyHelp(STR0048, STR0004, STR0049) // "Cabeçalho do arquivo se encontra inconsistente."### "Atenção"###"Verifique os dados do cabeçalho antes de prosseguir."
               break
            EndIf
            
            cArqLog := CriaTrbLog(cAliasTmp, @_aTabsTmp)
            oProc := MsNewProcess():New({|lEnd| ProcesCat(oJson, cAliasTmp, @oProc)}, STR0050,,.T.) //"Integrando Catálogo de Produtos...."
            oProc:Activate()

            aTemp := StrTokArr(cArquivo, "\")
            cArqNome := aTemp[Len(aTemp)]
            IIF(!(FRename(cArquivo, StrTran(cArquivo, ".xlsx", ".processado")) == 0), MsgInfo(STR0075 + StrTran(cArqNome, ".xlsx", ".processado") + ENTER + Str(fError()), STR0004),) // "Não foi possível renomear o arquivo para: " | "Atenção"

         EndIf
      End Sequence
      If Select(cAliasTmp) > 0
         E_EraseArq(cArqLog, _aTabsTmp[1][1])
      EndIf
   Else
      If !Empty(cArquivo)
         EasyHelp(STR0051, STR0004, STR0052) // "Arquivo não encontrado ou inválido." ### "Atenção"###"Verifique o arquivo selecionado antes de prosseguir."
      EndIf
   EndIf
   FreeObj(oJson)
Return

/*/{Protheus.doc} isHdrVld (isHeaderValid)
   Função utilizada para validar o cabeçalho do arquivo excel importado
   @type  Static Function
   @author Nícolas Castellani Brisque
   @since 15/05/2025
   @version version
   @param oJson, Object, Objeto Json que contém os dados do arquivo excel
   @return lRet, Logical, Retorno da validação do cabeçalho do arquivo excel. .T. se o cabeçalho for válido, .F. se o cabeçalho for inválido
   @see (links_or_references)
   /*/
Static Function isHdrVld(oJson)
Local lRet        := .T.
Local oHeaders    := JsonObject():New()
Local i, j
Local aCamposNCM  := {} // {"Filial", "Codigo Chave", "CNPJ Raiz", "Modalidade", "Descricao Catálogo de Produtos", "Descricao NCM", "Unidade NCM", "ID Portal", "Versão Atual", "Descri. Comp", "Obs Internas"}
Local aCamposProd := {} // {"Codigo Chave", "ID Portal", "Versão Atual", "Prod. Ref."}
Local aCamposFab  := {} // {"Codigo Chave", "ID Portal", "Versão Atual", "Codigo Fab.", "Loja", "Código", "País"}
Local cPlanilha   := ""
local nCampo      := 0 
local aCabNcm     := getCabNcm()
local aCabPrd     := getCabPrd()
local aCabOpe     := getCabOpe()   

for nCampo := 1 to len(aCabNcm)
   aAdd( aCamposNCM, getTit(aCabNcm[nCampo][1]) )
next

for nCampo := 1 to len(aCabPrd)
   aAdd( aCamposProd, getTit(aCabPrd[nCampo][1]) )
next

for nCampo := 1 to len(aCabOpe)
   aAdd( aCamposFab, getTit(aCabOpe[nCampo][1]) )
next

oHeaders['NCM'] := aCamposNCM
oHeaders['RELAÇÃO DE PRODUTOS'] := aCamposProd
oHeaders['RELAÇÃO DE FABRICANTES'] := aCamposFab

For i := 1 To Len(oJson)
   IIF("NCM" $ oJson[i]['sheetName'], cPlanilha := "NCM", cPlanilha := oJson[i]['sheetName'])

   If (aScan(oHeaders:GetNames(), { |X| cPlanilha $ X }) == 0) .Or. (Len(oJson[i]['rows'][1]['row']) < Len(oHeaders[cPlanilha]))
      lRet := .F.
      Exit
   EndIf

   For j := 1 to Len(oHeaders[cPlanilha])
      If oJson[i]['rows'][1]['row'][j] != oHeaders[cPlanilha][j]
         lRet := .F.
         Exit
      EndIf
   Next j

Next i

FreeObj(oHeaders)
FreeObj(oJson)

Return lRet

/*/{Protheus.doc} ProcesCat
   Função utilizada para validar se os catálogos informados no arquivo excel são válidos e realiza o processamento deles
   @type  Static Function
   @author Nícolas Castellani Brisque
   @since 19/05/2025
   @version version
   @param oJson, Object, Objeto Json que contém os dados do arquivo excel
          cAliasTmp, String, Alias temporário utilizado para armazenar os resultados da validação dos catálogos
          oProc, Object, Objeto do tipo MsNewProcess utilizado para exibir o progresso do processamento dos catálogos
   @return oResult, Object, Objeto Json que contém os resultados da validação dos catálogos informados no arquivo excel. Contém os campos "sucesso" e "erro" com os respectivos resultados
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function ProcesCat(oJson, cAliasTmp, oProc)
Local lRet
Local nPlanilha, nLinha, nAtributo, i
Local aLinha       := {}
Local aAtributos   := {}
Local cCatalogo    := ""
Local xErro        := ""
// Variáveis da NCM
Local cNcm         := ""
Local cCnpjRaiz    := ""
Local cDescCatProd := ""
Local cIDPortal    := ""
Local cVersaoAtual := ""
Local cDescriComp  := ""
Local cObsInternas := ""
// Variáveis do Produto
Local cProduto     := ""
Local cCodItem     := ""
// Variáveis do Fabricante
Local cFabricante  := ""
Local cLoja        := ""
Local cPais        := ""
// Modelos de dados e objetos
Local oModelo      := nil
Local oModelEK9    := nil
Local oModelEKA    := nil
Local oModelEKB    := nil
Local oModelEKC    := nil
Local nAcima
Local nAbaixo
local nTamCpoAtr := 0
local nTamCpoCnd := 0
local nTamCpoNCM := 0
local cTitCond   := ""
local cValorAtr  := ""
local cInfNcm    := ""

   EK9->(DbsetOrder(1)) // EK9_FILIAL+EK9_COD_I+EK9_VATUAL
   EKA->(DbsetOrder(1)) // EKA_FILIAL+EKA_COD_I+EKA_PRDREF+EKA_ITEM
   EKB->(DbsetOrder(1)) // EKB_FILIAL+EKB_COD_I+EKB_CODFAB+EKB_LOJA
   EKC->(DbsetOrder(1)) // EKC_FILIAL+EKC_COD_I+EKC_CODATR+EKC_CONDTE
   SB1->(DbsetOrder(1)) // B1_FILIAL+B1_COD
   SA2->(DbsetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
   ELO->(DbsetOrder(1)) // ELO_FILIAL+ELO_COD
   EKG->(DbsetOrder(1)) // EKG_FILIAL+EKG_NCM+EKG_COD_I+EKG_CONDTE

   oModelo := FwLoadModel("EICCP400")
   oModelo:SetOperation(MODEL_OPERATION_UPDATE)

   nAcima := Len(oJson)
   oProc:SetRegua1(nAcima)

   For nPlanilha := nAcima To 1 Step -1
      If "NCM" $ oJson[nPlanilha]['sheetName']
         cNcm := StrTokArr(oJson[nPlanilha]['sheetName'], " ")[2]
         oProc:IncRegua1(STR0067 +  cNcm) //"Integrando NCM "
         nAbaixo := Len(oJson[nPlanilha]['rows']) - 3 //Deve subtrair o nLinha inicial que é 4 e somar 1, chegando no 3
         oProc:SetRegua2(nAbaixo)
         nTamCpoAtr := getSX3Cache("EKC_CODATR", "X3_TAMANHO")
         nTamCpoCnd := getSX3Cache("EKC_CONDTE", "X3_TAMANHO")
         nTamCpoNCM := getSX3Cache("EKG_NCM", "X3_TAMANHO")
         cTitCond := getTitCond()
         cInfNcm := PadR(strTran(cNcm, ".", ""), nTamCpoNCM)

         For nLinha := 4 To (Len(oJson[nPlanilha]['rows'])) // Inicia da quarta linha pois as outras 3 são cabeçalho
            lRet         := .T.
            xErro        := ""
            aLinha       := oJson[nPlanilha]['rows'][nLinha]['row']
            cCatalogo    := AvKey(aLinha[2], "EK9_COD_I")
            cCnpjRaiz    := aLinha[3]
            cDescCatProd := aLinha[5]
            cIDPortal    := aLinha[8]
            cVersaoAtual := aLinha[9]
            cDescriComp  := aLinha[10]
            cObsInternas := aLinha[11]

            oProc:IncRegua2(STR0053 + cCatalogo + " / " + cDescCatProd)//"Catálogo: "
            aAtributos := {}
            If Len(aLinha) > 11 // Caso exista atributos na planilha
               For nAtributo := 12 To Len(aLinha)
                  aAdd(aAtributos, { PadR(oJson[nPlanilha]['rows'][1]['row'][nAtributo],nTamCpoAtr),  PadR( StrTran(oJson[nPlanilha]['rows'][3]['row'][nAtributo], cTitCond, ""), nTamCpoCnd), aLinha[nAtributo]})
               Next nAtributo
            EndIf

            If !Empty(cCatalogo)
               If !EK9->(DbSeek(xFilial("EK9") + cCatalogo))
                  lRet := .F.
                  xErro := STR0054 // "Catálogo de produtos não encontrado."
                  GrvResult(cAliasTmp, cCatalogo, "", "","", oJson[nPlanilha]['sheetName'], STR0055 + AllTrim(Str(nLinha)) + ": "+ xErro, "0")//"Linha "
               Else
                  lRet := oModelo:Activate()
                  oModelEK9 := oModelo:getModel("EK9MASTER")
                  oModelEKC := oModelo:getModel("EKCDETAIL")
                  If lRet
                     oModelEK9:SetValue("EK9_CNPJ",   cCnpjRaiz)
                     oModelEK9:SetValue("EK9_DESC_I", cDescCatProd)
                     oModelEK9:SetValue("EK9_IDMANU", cIDPortal)
                     oModelEK9:SetValue("EK9_VSMANU", cVersaoAtual)
                     oModelEK9:SetValue("EK9_DSCCOM", cDescriComp)
                     oModelEK9:SetValue("EK9_OBSINT", cObsInternas)

                     If !Empty(aAtributos)
                        For nAtributo := 1 to Len(aAtributos)
                           If oModelEKC:SeekLine({{"EKC_COD_I", cCatalogo}, {"EKC_CODATR", aAtributos[nAtributo][1]},  {"EKC_CONDTE", aAtributos[nAtributo][2]}})
                              cValorAtr := aAtributos[nAtributo][3]
                              if EKG->(MsSeek(xFilial("EKG") + cInfNcm + aAtributos[nAtributo][1] + aAtributos[nAtributo][2]))
                                 if alltrim(EKG->EKG_FORMA) == "BOOLEANO"
                                    cValorAtr := if(alltrim(upper(aAtributos[nAtributo][3])) == "SIM", "1", "2")
                                 endif
                              endif
                              oModelEKC:SetValue("EKC_VALOR", cValorAtr)
                           EndIf
                        Next nAtributo
                     EndIf

                     lRet := oModelo:VldData()
                     IIF(lRet, oModelo:CommitData(), xErro := oModelo:GetErrorMessage())
                     GrvResult(cAliasTmp, cCatalogo, oModelEK9:GetValue("EK9_DESC_I"), cNcm, oModelEK9:getValue('EK9_DSCNCM'), oJson[nPlanilha]['sheetName'], IIF(lRet, "Processado com sucesso.", trataErro(xErro)), IIF(lRet, cResult := "1", cResult := "2"))
                     oModelo:DeActivate()
                  EndIf
               EndIf
            EndIf
         Next nLinha
      ElseIf oJson[nPlanilha]['sheetName'] == "RELAÇÃO DE PRODUTOS"
         oProc:IncRegua1(STR0068 +  oJson[nPlanilha]['sheetName'])//"Integrando "
         nAbaixo := Len(oJson[nPlanilha]['rows']) - 1 //Deve subtrair o nLinha inicial que é 2 e somar 1, chegando no 1
         oProc:SetRegua2(nAbaixo)
         For nLinha := 2 To (Len(oJson[nPlanilha]['rows'])) // A primeira linha é o cabeçalho
            aLinha       := oJson[nPlanilha]['rows'][nLinha]['row']
            If Len(aLinha) < 4 // Tratamento para caso a planilha não tenha todos os campos necessários
               For i := Len(aLinha) To 3
                  aAdd(aLinha, "")
               Next i
            EndIf
            cCatalogo    := AvKey(aLinha[1], "EK9_COD_I")
            cProduto     := AvKey(aLinha[4], "B1_COD")

            oProc:IncRegua2(STR0056 + cCatalogo + " / " + cProduto)//"Catálogo / Produto: "

            // Estas validações estão sendo feitas antes das validações do modelo de dados para poupar processamento
            If Empty(cCatalogo) .Or. Empty(cProduto)
               Loop
            EndIf

            xErro := ""
            If !EK9->(DbSeek(xFilial("EK9") + cCatalogo))
               xErro := IIF(Empty(xErro), "", xErro + ENTER) +  STR0003 + " '" + cCatalogo + "' " + STR0057 + " '" + cProduto + "'."//Catálogo de Produtos###"não encontrado para a vinculação do produto de referência"
               GrvResult(cAliasTmp, cCatalogo, "", "", "", oJson[nPlanilha]['sheetName'], STR0055 + AllTrim(Str(nLinha)) + ": "+ xErro, "0") // Retorna 0 pois se trata de avisos e não de erros ###"Linha "
               Loop
            EndIf

            If !SB1->(DbSeek(xFilial("SB1") + cProduto))
               xErro := STR0058 + " '" + cProduto + "' " + STR0059 //"Produto"###"não encontrado."
            ElseIf SB1->B1_MSBLQL == "1"
               xErro := IIF(Empty(xErro), "", xErro + ENTER) + STR0058 + " '" + cProduto + "' " + STR0060//"Produto"###"está bloqueado."
            EndIf

            If EKA->(DbSeek(xFilial("EKA") + cCatalogo + cProduto))
               xErro := IIF(Empty(xErro), "", xErro + ENTER) + STR0058 + " '" + cProduto + "' " + STR0061 + " '" + cCatalogo + "'."//"Produto"###"já está vinculado ao catálogo"
            EndIf

            If !Empty(xErro)
               GrvResult(cAliasTmp, cCatalogo, EK9->EK9_DESC_I, EK9->EK9_NCM, Posicione("SYD", 1,xFilial("SYD")+EK9->EK9_NCM, "YD_DESC_P"), oJson[nPlanilha]['sheetName'], STR0055 + AllTrim(Str(nLinha)) + ": "+ xErro, "0") // Retorna 0 pois se trata de avisos e não de erros###"Linha "
               Loop
            EndIf

            oModelo:Activate()
            oModelEK9 := oModelo:getModel("EK9MASTER")
            oModelEKA := oModelo:getModel("EKADETAIL")

            If !(oModelEKA:Length() == 1 .And. Empty(oModelEKA:GetValue("EKA_PRDREF")))
               cCodItem := StrZero(oModelEKA:Length() + 1, GetSx3Cache("EKA_ITEM", "X3_TAMANHO"))
               oModelEKA:AddLine()
            Else
               cCodItem := StrZero(1, GetSx3Cache("EKA_ITEM", "X3_TAMANHO"))
            EndIf
            oModelEKA:SetValue("EKA_ITEM",   cCodItem)
            oModelEKA:SetValue("EKA_PRDREF", cProduto)

            lRet := oModelo:VldData()
            IIF(lRet, oModelo:CommitData(), xErro := oModelo:GetErrorMessage())

            GrvResult(cAliasTmp, cCatalogo, oModelEK9:GetValue("EK9_DESC_I"), oModelEK9:GetValue("EK9_NCM"), oModelEK9:getValue('EK9_DSCNCM'), oJson[nPlanilha]['sheetName'], IIF(lRet, STR0076, trataErro(xErro)), IIF(lRet, cResult := "1", cResult := "2")) // Processado com suceso."

            oModelo:DeActivate()
         Next nLinha
      ElseIf oJson[nPlanilha]['sheetName'] == "RELAÇÃO DE FABRICANTES"
         oProc:IncRegua1(STR0068 +  oJson[nPlanilha]['sheetName'])//"Integrando "

         nAbaixo := Len(oJson[nPlanilha]['rows']) - 1 //Deve subtrair o nLinha inicial que é 2 e somar 1, chegando no 1
         oProc:SetRegua2(nAbaixo)
         For nLinha := 2 To (Len(oJson[nPlanilha]['rows'])) // A primeira linha é o cabeçalho
            aLinha       := oJson[nPlanilha]['rows'][nLinha]['row']
            If Len(aLinha) < 7 // Tratamento para caso a planilha não tenha todos os campos necessários
               For i := Len(aLinha) To 6
                  aAdd(aLinha, "")
               Next i
            EndIf
            cCatalogo    := AvKey(aLinha[1], "EK9_COD_I")
            cFabricante  := AvKey(aLinha[4], "A2_COD")
            cLoja        := AvKey(aLinha[5], "A2_LOJA")
            cPais        := AvKey(aLinha[7], "ELO_COD")

            oProc:IncRegua2(STR0062 + cCatalogo + " / " + cFabricante + "-" + cLoja + "-" + cPais)//"Catálogo/Fabricante: "

            If Empty(cCatalogo) .Or. (Empty(cFabricante) .And. Empty(cLoja) .And. Empty(cPais))
               Loop
            EndIf

            xErro := ""
            If !EK9->(DbSeek(xFilial("EK9") + cCatalogo))
               xErro := IIF(Empty(xErro), "", xErro + ENTER) +  STR0003 + " '" + cCatalogo + "' " + STR0057 + " '" + cProduto + "'."//Catálogo de Produtos###"não encontrado para a vinculação do produto de referência"
               GrvResult(cAliasTmp, cCatalogo, "", "", "", oJson[nPlanilha]['sheetName'], STR0055 + AllTrim(Str(nLinha)) + ": "+ xErro, "0") // Retorna 0 pois se trata de avisos e não de erros ###"Linha "
               Loop
            EndIf

            If (Empty(cFabricante) .And. !Empty(cLoja)) .or. (!Empty(cFabricante) .And. Empty(cLoja))
               xErro := IIF(Empty(xErro), "", xErro + ENTER) + STR0077 // "Foi informado apenas o Fabricante ou a Loja do Fabricante."
            EndIf

            If !Empty(cFabricante) .And. !Empty(cLoja) .And. !SA2->(DbSeek(xFilial("SA2") + cFabricante + cLoja))
               xErro := IIF(Empty(xErro), "", xErro + ENTER) + STR0078 // "Fabricante não encontrado."
            EndIf

            If !Empty(cPais) .And. !ELO->(DbSeek(xFilial("ELO") + cPais))
               xErro := IIF(Empty(xErro), "", xErro + ENTER) + STR0079 //"País não encontrado."
            EndIf

            If !Empty(xErro)
               GrvResult(cAliasTmp, cCatalogo, EK9->EK9_DESC_I, EK9->EK9_NCM, Posicione("SYD", 1,xFilial("SYD")+EK9->EK9_NCM, "YD_DESC_P"), oJson[nPlanilha]['sheetName'], STR0055 + AllTrim(Str(nLinha)) + ": "+ xErro, "0") // Retorna 0 pois se trata de avisos e não de erros###"Linha "
               Loop
            EndIf

            oModelo:Activate()
            oModelEK9 := oModelo:getModel("EK9MASTER")
            oModelEKB := oModelo:getModel("EKBDETAIL")
            If !(oModelEKB:Length() == 1 .And. Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. Empty(oModelEKB:GetValue("EKB_PAIS")))
               oModelEKB:AddLine()
            EndIf

            If !Empty(cFabricante) .And. !Empty(cLoja)
               oModelEKB:SetValue("EKB_CODFAB", cFabricante)
               oModelEKB:SetValue("EKB_LOJA",   cLoja)
            ElseIf !Empty(cPais)
               oModelEKB:SetValue("EKB_PAIS",   cPais)
            EndIf

            lRet := oModelo:VldData()
            IIF(lRet, oModelo:CommitData(), xErro := oModelo:GetErrorMessage())

            GrvResult(cAliasTmp, cCatalogo, oModelEK9:GetValue("EK9_DESC_I"), oModelEK9:GetValue("EK9_NCM"), oModelEK9:getValue('EK9_DSCNCM'), oJson[nPlanilha]['sheetName'], IIF(lRet, "Processado com sucesso.", trataErro(xErro)), IIF(lRet, cResult := "1", cResult := "2"))

            oModelo:DeActivate()
         Next nLinha
      EndIf
   Next nPlanilha
   
   telaResult(cAliasTmp)

   FreeObj(oModelo)
   FreeObj(oModelEK9)
   FreeObj(oModelEKA)
   FreeObj(oModelEKB)
   FreeObj(oModelEKC)

Return

/*/{Protheus.doc} telaResult
   Função utilizada para exibir o resultado da importação do catálogo de produtos em um Wizard, permitindo ao usuário visualizar os resultados e exportar o log para Excel.
   @type  Static Function
   @author THTS - Tiago Tudisco
   @since Junho/2025
   @version version
   @param cAliasTmp, String, Alias temporário utilizado para armazenar os resultados da validação dos catálogos
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function telaResult(cAliasTmp)
local aCoords    := {}
local oStepWiz   := nil
local oStep1     := nil

aCoords := FWGetDialogSize()
oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
//oStepWiz:ActiveUISteps()

oStep1 := oStepWiz:AddStep("1")
oStep1:SetStepDescription(STR0081) // "Importar da Planilha"
oStep1:SetConstruction({|oPanel| ViewResult( oPanel, cAliasTmp)})
oStep1:SetNextTitle(STR0008) // "Fechar"
If Valtype(oStepWiz:oUIStepWizard:cNextTitle) == "C"
   oStepWiz:oUIStepWizard:cNextTitle := STR0008//"Fechar"
EndIf
oStep1:SetNextAction({|| .T. })
oStep1:SetCancelTitle(STR0009) // "Exportar"
If Valtype(oStepWiz:oUIStepWizard:cCancelTitle) == "C"
   oStepWiz:oUIStepWizard:cCancelTitle := STR0009//"Exportar"
EndIf
oStep1:SetCancelAction({|| ExpResult(cAliasTmp) })
oStep1:SetCancelWhen({|| .F. })

oStepWiz:Activate()
oStepWiz:Destroy()

FwFreeObj( oStepWiz )
Return


/*/{Protheus.doc} ViewResult
   Função utilizada para exibir o resultado da importação do catálogo de produtos em um Wizard, permitindo ao usuário visualizar os resultados e exportar o log para Excel.

   @type    Static Function
   @author  THTS - Tiago Tudisco
   @since   Junho/2025
   @version 1.0
   @param   oPanel, Object, Painel principal onde o resultado será exibido
   @param   cAliasTmp, String, Alias temporário utilizado para armazenar os resultados da validação dos catálogos
   @return  Nil
   @example
   @see
/*/
Static Function ViewResult(oPanel, cAliasTmp)
local nCpo       := 0
local aStruct    := {}
local aColumns   := {}
Local aFieldFilter := {}
Local aSeek      := {}
Local oResult    := nil
local oLayer
local oPanel1
local oPanel2
local oSayTitulo
local cTexto     := ""
Local cLib       := ""

aStruct := (cAliasTmp)->(dbStruct())
for nCpo := 1 To Len(aStruct)
    if !(aStruct[nCpo][1] $ ("RESULTADO"))
        aAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
        aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
        aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
        if aStruct[nCpo][1] == "RETORNO"
            aColumns[Len(aColumns)]:SetTitle(STR0069)//Mensagem
            aColumns[Len(aColumns)]:SetDoubleClick({|| EECView((cAliasTmp)->RETORNO, STR0069,,,,,.T.) })//Duplo clique na coluna de mensagem####"Mensagem"
         ElseIf aStruct[nCpo][1] == "OPERACAO"
            aColumns[Len(aColumns)]:SetTitle( STR0070 )//"Operação" 
            aColumns[Len(aColumns)]:SetPicture( "@!")
         Else       
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
        endif
    endif
next nCpo 

oLayer := FWLayer():New()
oLayer:Init(oPanel,.F.)

oLayer:AddLine("L1",13,.F.)
oLayer:AddLine("L2",87,.F.)
oPanel1 := oLayer:getLinePanel("L1")
oPanel2 := oLayer:getLinePanel("L2")

GetRemoteType(@cLib)
cTexto := STR0063 //Resultado da Importação do Arquivo de Catálogo de Produtos
If 'HTML' $ cLib
    cTexto := "<!DOCTYPE html><html lang='pt-BR'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>Integração</title><style>body { font-family: Arial, sans-serif; font-size: 18px; } .bold { font-weight: bold; }</style></head><body><p>" + STR0063 + "</p></body></html>" //Resultado da Importação do Arquivo de Catálogo de Produtos
EndIf
oSayTitulo  := TSay():New(0,0,{|| cTexto},oPanel1,,TFont():New("Arial",,18,,.F.,,,,,.F.,.F.,,,,,,,,,.T.),,,,.T.,,,(oPanel1:nWidth) - 10, oPanel1:nHeight) //"Resultado de Importação do Arquivo de Catálogo de Produtos"

// Defino os detalhes da busca do browse
Aadd(aSeek,{ AvSx3( "EK9_COD_I", AV_TITULO) , {{"",getSX3Cache( "EK9_COD_I", "X3_TIPO")  ,getSX3Cache( "EK9_COD_I", "X3_TAMANHO"),0,"EK9_COD_I",getSX3Cache( "EK9_COD_I", "X3_PICTURE")}}, 1, .T.})
Aadd(aSeek,{ AvSx3( "YD_TEC", AV_TITULO)    , {{"",getSX3Cache( "YD_TEC", "X3_TIPO")     ,getSX3Cache( "YD_TEC"   , "X3_TAMANHO"),0,"YD_TEC"   ,getSX3Cache( "YD_TEC"   , "X3_PICTURE")}}, 2, .T.})
aEval((cAliasTmp)->(dbStruct()), {|x| Iif(x[1] $ "YA_CODGI|YA_DESCR", Aadd(aFieldFilter, {x[1], x[1], x[2], x[3], x[4], NIL}),)})

fwFreeObj(oResult)
oResult := FWmBrowse():New()
oResult:SetProfileID( 'RESULTADO' )
oResult:SetDataTable()
oResult:SetOwner( oPanel2 )
oResult:SetAlias( cAliasTmp )
oResult:AddLegend("RESULTADO == '0' ","BR_AMARELO"  , STR0065) // "Alerta: Verifique os dados informados"
oResult:AddLegend("RESULTADO == '1' ","ENABLE"      , STR0064) // "Dados importados com sucesso"
oResult:AddLegend("RESULTADO == '2' ","DISABLE"     , STR0066) // "Falha na Importação dos dados"
oResult:SetColumns( aColumns )
oResult:SetMenuDef( "" )
oResult:SetSeek(,aSeek) 
oResult:DisableConfig()
oResult:DisableReport()
oResult:DisableDetails()
oResult:Activate()

Return


/*/{Protheus.doc} criaTrbLog
   Função utilizada para criar o arquivo temporário de log para armazenar os resultados da importação do catálogo de produtos.

   @type    Static Function
   @author  THTS - Tiago Tudisco
   @since   Junho/2025
   @version 1.0
   @param   cAliasTmp, String, Alias temporário utilizado para armazenar os resultados
   @param   _aTabsTmp, Array, Array para controle das tabelas temporárias criadas
   @return  String, Caminho do arquivo temporário criado
   @example
   @see
*/
Static Function criaTrbLog(cAliasTmp, _aTabsTmp)
Local aSemSX3    := {}
Local cArqTmp    := ""
Local cIndExt    := ""
Local cIndex1    := ""

if Select(cAliasTmp) == 0
   aSemSX3  := {}
   _aTabsTmp:= {}
   aAdd(aSemSX3, {"EK9_COD_I" , getSX3Cache( "EK9_COD_I", "X3_TIPO") , getSX3Cache( "EK9_COD_I", "X3_TAMANHO") , 0 })
   aAdd(aSemSX3, {"EK9_DESC_I", getSX3Cache( "EK9_DESC_I", "X3_TIPO"), getSX3Cache( "EK9_DESC_I", "X3_TAMANHO"), 0 })
   aAdd(aSemSX3, {"YD_TEC"    , getSX3Cache( "YD_TEC", "X3_TIPO")    , getSX3Cache( "YD_TEC", "X3_TAMANHO")    , getSX3Cache( "YD_TEC", "X3_DECIMAL")    })
   aAdd(aSemSX3, {"YD_DESC_P" , getSX3Cache( "YD_DESC_P", "X3_TIPO") , getSX3Cache( "YD_DESC_P", "X3_TAMANHO") , getSX3Cache( "YD_DESC_P", "X3_DECIMAL") })
   aAdd(aSemSX3, {"OPERACAO"  , "C"                                  , 25                                      , 0                                       })
   aAdd(aSemSX3, {"RESULTADO" , "C"                                  , 01                                      , 0                                       })
   aAdd(aSemSX3, {"RETORNO"   , "M"                                  , 250                                     , 0                                       })

   cArqTmp := e_criatrab(, aSemSX3, cAliasTmp )

   cIndExt := TEOrdBagExt()
   E_IndRegua( cAliasTmp , cArqTmp+cIndExt, "EK9_COD_I")

   cIndex1 := e_create(,.F.)
   E_IndRegua( cAliasTmp , cIndex1+cIndExt, "YD_TEC")

   SET INDEX TO (cArqTmp+cIndExt),(cIndex1+cIndExt)

   aAdd( _aTabsTmp, {cIndex1 })
EndIf

return cArqTmp

/*/{Protheus.doc} GrvResult
   Função utilizada para gravar o log do resultado da integração do catálogo de produtos, armazenando as informações de processamento para posterior visualização e exportação.

   @type    Static Function
   @author  THTS - Tiago Tudisco
   @since   Junho/2025
   @version 1.0
   @param   cAliasTmp, String, Alias temporário utilizado para armazenar os resultados da validação dos catálogos
   @param   cCod_I, String, Código do catálogo de produtos
   @param   cDesc_I, String, Descrição do catálogo de produtos
   @param   cNcm, String, NCM relacionado ao catálogo
   @param   cDescNcm, String, Descrição do NCM
   @param   cOperacao, String, Operação realizada
   @param   cMsg, String, Mensagem de retorno do processamento
   @param   cResult, String, Resultado do processamento ("0"=Alerta, "1"=Sucesso, "2"=Erro)
   @return  Nil
   @example
   @see
*/
Static Function GrvResult(cAliasTmp, cCod_I, cDesc_I, cNcm, cDescNcm, cOperacao, cMsg, cResult)

RecLock(cAliasTmp, .T.)

(cAliasTmp)->(EK9_COD_I)   := cCod_I
(cAliasTmp)->(EK9_DESC_I)  := cDesc_I
(cAliasTmp)->(YD_TEC)      := cNcm
(cAliasTmp)->(YD_DESC_P)   := cDescNcm
(cAliasTmp)->(OPERACAO)    := cOperacao
(cAliasTmp)->(RESULTADO)   := cResult
(cAliasTmp)->(RETORNO)     := cMsg

(cAliasTmp)->(MsUnlock())

Return

/*/{Protheus.doc} trataErro
   Função utilizada para tratar e formatar mensagens de erro durante o processo de importação do catálogo de produtos, retornando a mensagem apropriada para exibição ao usuário.

   @type    Static Function
   @author  Nícolas Castellani Brisque
   @since   02/06/2025
   @version version
   @param   xErro, Variant, Mensagem de erro recebida, podendo ser do tipo caractere ou array
   @return  cRet, String, Mensagem de erro tratada e formatada para exibição
   @example
   @see
*/
Static Function trataErro(xErro)
Return IIF(ValType(xErro) == "C", AllTrim(xErro), IIF(ValType(xErro) == "A", xErro[6], ""))


/*/{Protheus.doc} ExpResult
   Função utilizada para gerar o arquivo Excel com o resultado da integração do catálogo de produtos, permitindo ao usuário exportar o log da importação para análise posterior.

   @type    Static Function
   @author  THTS - Tiago Tudisco
   @since   Junho/2025
   @version 1.0
   @param   cAliasTmp, String, Alias temporário utilizado para armazenar os resultados da validação dos catálogos
   @return  Logical, .F. para não realizar mudanças na página
   @example
   @see
*/
Static Function ExpResult(cAliasTmp)
IIF((cAliasTmp)->(eof()) .And. (cAliasTmp)->(bof()),MsgInfo(STR0071, STR0004), FWMsgRun(,{|| ExpExcel(cAliasTmp)}, STR0080, STR0013)) // //"Não é possível exportar os resultados da integração, pois não existem registros."###Atenção.### "Exportando Planilha"###"Gerando a planilha excel"
Return .F.
Static Function ExpExcel(cAliasTela)
Local oExcel      := FwMsExcelXlsx():New()
Local cWorksheet  := STR0072//"Log da Importação do Arquivo"
Local cTable      := STR0073//"Log da Importação do Arquivo de Catálogo de Produtos"
Local cArquivo    := CriaTrab(Nil, .F.) + ".xlsx"
Local cTitulo     := ""
Local aStruct     := {}
Local i           := 0

// Cria a planilha e a tabela que será utilizada
oExcel:AddworkSheet(cWorksheet)
oExcel:AddTable(cWorksheet, cTable)

// Adiciona as colunas na tabela
(cAliasTela)->(dbGoTop())
aStruct := (cAliasTela)->(dbStruct())
For i := 1 To Len(aStruct)
   If !(aStruct[i][1] $ "REG_MARCA")
         cTitulo  := IIF(aStruct[i][1] == "RETORNO", STR0069, IIF(aStruct[i][1] == "RESULTADO", STR0074, RetTitle(aStruct[i][1])))//"Mensagem"###"Resultado"
         oExcel:AddColumn(cWorksheet, cTable, cTitulo)
   EndIf
Next i

// Adiciona as linhas na tabela
While (cAliasTela)->(!EoF())
    cResultado := IIF((cAliasTela)->RESULTADO == "0", STR0065, IIF((cAliasTela)->RESULTADO == "1", STR0064, STR0066))// "Alerta: Verifique os dados informados"####// "Dados importados com sucesso"###// "Falha na Importação dos dados"
    oExcel:Addrow(cWorksheet    , cTable, { ;
        (cAliasTela)->EK9_COD_I  , ;
        (cAliasTela)->EK9_DESC_I  , ;
        Transform((cAliasTela)->YD_TEC, GetSx3Cache("YD_TEC", "X3_PICTURE")), ;
        (cAliasTela)->YD_DESC_P  , ;
        (cAliasTela)->OPERACAO, ;
        cResultado,               ;
        (cAliasTela)->RETORNO     ;
    })
   (cAliasTela)->(dbSkip())
EndDo

// Salva o arquivo
oExcel:Activate()
oExcel:GetXMLFile(cArquivo)
oExcel:DeActivate()
FwFreeObj(oExcel)

comex.generics.TEOpenExcel(cArquivo)
Return .F. // Retorna falso para não realizar mudanças na página


/*/{Protheus.doc} getTitCond
   (long_description)
   @type  Static Function
   @author user
   @since 11/07/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getTitCond()
Return AvSx3("EKG_CONDTE"   , AV_TITULO) + ': '
