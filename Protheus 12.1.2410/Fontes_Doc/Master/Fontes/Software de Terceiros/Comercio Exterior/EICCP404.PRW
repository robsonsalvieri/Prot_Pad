#include 'protheus.ch'
#include 'average.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "eiccp404.ch"
#INCLUDE "fileio.ch"

#define CP404_TABLE "CP404_EK9"
#define PROCESSADO "0" // Verde
#define EXISTENTE  "1" // Cinza
#define ERRO       "2" // Vermelho
#define FABFOR     'Fabricante/Fornecedor'
#define OPERADOR   'Operador Estrangeiro'
#define CATALOGO   'Catálogo de Produtos'



/*/{Protheus.doc} CP404ImpArq
   Realiza a importação dos Catálogos para um arquivo excel
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

Function CP404ImpArq()
   local lIsBlind := isBlind()       

   if !lIsBlind 
      if !getPerg('EICCP404')
         EasyHelp(STR0081,STR0015,STR0082) //'Dicionário de dados não está completo para executar esta ação. 'Faça a atualização da última expedição contínua com aplicação do dicionário de dados'
         return nil
      EndIF  
      WizardArq()
   endif

return nil

/*/{Protheus.doc} WizardArq
   Criação da tela do Wizard para a importação do arquivo

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
static function WizardArq()
   local aCoords    := {}
   local aFiles     := {}
   local oStepWiz   := nil
   local oStep1     := nil
   local oBrwProc   := nil
   local cAliasTmp  := CP404_TABLE
   
   oEasyTmp := EasyTemporaryTable():new()
   setTable(@oEasyTmp)
   oEasyTmp:ClearTmp(cAliasTmp)

   aCoords := FWGetDialogSize()
   oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
   oStepWiz:ActiveUISteps()

    oStep1 := oStepWiz:AddStep("1")
    oStep1:SetStepDescription(STR0001) // "introdução"
    oStep1:SetConstruction({ |oPanel| ViewIntrod( oPanel ) } )
    oStep1:SetNextTitle(STR0003) // "Avançar"
    oStep1:SetCancelAction( { || MsgYesNo(STR0004, STR0005) }) // "Deseja cancelar a importação do arquivo?" 

    oStep2 := oStepWiz:AddStep("2")
    oStep2:SetStepDescription(STR0028) // "Download de arquivos"
    oStep2:SetConstruction({ |oPanel| ViewDirec(oPanel) } )
    oStep2:SetPrevTitle(STR0006) // "Voltar"
    oStep2:SetNextTitle(STR0007) // "Avançar"
    oStep2:SetNextAction( { || validStep2(@aFiles) })
    oStep2:SetCancelAction( { || MsgYesNo(STR0004, STR0005) }) // "Deseja cancelar a importação do arquivo?" 

    oStep3 := oStepWiz:AddStep("3")
    oStep3:SetStepDescription(STR0029) // "Operador estrangeiro"
    oStep3:SetConstruction({ |oPanel| ViewOper(oPanel) } )
    oStep3:SetPrevTitle(STR0006) // "Voltar"
    oStep3:SetNextTitle(STR0007) // "Avançar"
    oStep3:SetNextAction( { || validStep3() })
    oStep3:SetCancelAction( { || MsgYesNo(STR0004, STR0005) }) // "Deseja cancelar a importação do arquivo?" 

    oStep4 := oStepWiz:AddStep("4")
    oStep4:SetStepDescription(STR0008) // Processamento
    oStep4:SetConstruction({|oPanel| ViewProc(oPanel, @oBrwProc, aFiles), if(oBrwProc <> nil, oBrwProc:oBrowse:Refresh(.T.), nil) })
    oStep4:SetNextTitle(STR0010) // "Fechar"
    oStep4:SetPrevTitle(STR0009) // "Exportar"
    oStep4:SetNextAction({|| .T. })
    oStep4:SetPrevAction({|| geraExcel() })
    oStep4:SetCancelWhen({|| .F. })

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
   local cLib       := ""
   local lProducao   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   local cTxt := if(lProducao,STR0026,STR0027)
   aCoords := FWGetDialogSize(oPanel)      

   GetRemoteType(@cLib)
   cTxt := iif('HTML' $ cLib, "<b>" + cTxt + "</b>", cTxt)   
   cIntrod := StrTran(STR0002,'#####',cTxt) + ENTER + ENTER + STR0030 + ENTER + ENTER + STR0031 + ENTER + STR0032 + ENTER + ENTER + STR0033 + ENTER + STR0034 
   // "Você está prestes a importar dados do ambiente de #####. Certifique-se de que foi efetuado o download dos arquivos corretamente do ambiente de ##### do Portal Único.
   // Esta ação não poderá ser revertida.
   // Durante o processo de importação, todos os dados contidos nos arquivos selecionados serão completamente integrados ao sistema. Após a conclusão da importação, é importante destacar que quaisquer alterações ou atualizações nos registros importados deverão ser realizadas exclusivamente através das funcionalidades internas do sistema, garantindo assim a consistência e integridade das informações. 
   // Vale ressaltar que futuras importações de arquivos não modificarão os registros já existentes; apenas novos registros serão adicionados. Portanto, é essencial que a primeira importação seja feita com os dados mais atuais e precisos disponí­veis
   
   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return nil

/*/{Protheus.doc} ViewIntrod
   Função para introdução do Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oPanel, objeto, objeto que será apresentado a introdução
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewDirec(oPanel)
   local aCoords    := {}
   local cIntrod    := "" 
   local oSay       := nil
   local oFont      := nil
   aCoords := FWGetDialogSize(oPanel)
   
   cIntrod := STR0063 //"Para realizar a importação dos catálogos, é necessário que o usuário tenha previamente baixado os três arquivos obrigatórios: Operador Estrangeiro, Catálogo de Produtos e Vínculo de Catálogo com Fabricante/ País. Certifique-se de que esses arquivos estejam descompactados e salvos com a extensão json em um mesmo diretório.        
   
   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return nil


/*/{Protheus.doc} validStep2
   Função para validação do step 2 do Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function validStep2(aFiles)
local lRet := .T.
local cPath := selDir()
local aArqsOper := {}
local aArqsCat  := {}
local aArqsFab  := {}

   if !Empty(cPath)

      aArqsOper := Directory(cPath + "OPERADORES_ESTRANGEIROS_*.json") 
      aArqsCat  := Directory(cPath + "CATALOGO_PRODUTOS_*.json") 
      aArqsFab  := Directory(cPath + "FABRICANTE_PRODUTOR_*.json") 

      if len(aArqsOper) == 0 .or. len(aArqsCat) == 0 .or. len(aArqsFab) == 0
         easyHelp(STR0035, STR0015,STR0036) // "Para prosseguir com o processo de importação, é necessário que os três arquivos obrigatórios estejam armazenados em um único diretório." ### "Atenção" ### "Por favor, forneça o caminho do diretório onde os arquivos estáo localizados. O sistema irá automaticamente verificar a presença de cada um dos arquivos e assegurar que não existam duplicatas, garantindo assim a precisão e eficiência no processo de importação"
         lRet := .F.
      endif
      if lRet .and. (len(aArqsOper) > 1 .or. len(aArqsCat) > 1 .or. len(aArqsFab) > 1)
         easyHelp(STR0039, STR0015,STR0040) // "Para prosseguir com o processo de importação, é necessário que apenas um arquivo de cada entidade esteja no diretório informado." ### "Atenção" ### "Por favor, forneça o caminho do diretório onde exista apenas os arquivos a serem processados."
         lRet := .F.
      endif
      if lRet
         aadd(aFiles, cPath + aArqsOper[1][1])
         aadd(aFiles, cPath + aArqsCat[1][1])
         aadd(aFiles, cPath + aArqsFab[1][1])
      EndIf   
   else
      easyHelp(STR0037, STR0015,STR0038) //"Nenhum diretório selecionado." ### "Atenção" ### "Selecione um diretório onde os arquivos estáo localizados." 
      lRet := .F.
   endif

Return lRet

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
   Local cTitle:= "Selecione o diretório" //"Selecione o diretório"
   Local cMask := ""//"Arquivo json|*.json"
   Local nDefaultMask //:= 0
   Local cDefaultDir  := GetTempPath()
   Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY
   Local cPath

   cPath := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,.t.,nOptions)
   
Return cPath

/*/{Protheus.doc} EIC404VLD
   Função para validação dos campos do pergunte EICCP404
   @type  Static Function
   @author user
   @since 03/07/2025
   @version version
   @param cCampo, caracater, campo a ser validado
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
function EIC404VLD(cCampo)
local lRet := .T.
Do case
   Case cCampo == "A2_COD"
      lRet := VLD_Campo(cCampo,MV_PAR02)
   Case cCampo == "A2_LOJA"      
      lRet := VLD_Campo(cCampo,MV_PAR05)
   Case cCampo == "LJDF"   
      lRet := VLD_LJDF(MV_PAR03,MV_PAR06)      
EndCase
Return lRet

/*/{Protheus.doc} VLD_Campo
   Função para validação dos campos de dicionário do pergunte EICCP404
   @type  Static Function
   @author user
   @since 03/07/2025
   @version version
   @param cCampo, caracater, campo a ser validado
          nVal, numérico, valor digitado no pergunte          
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function VLD_Campo(cCampo, nVal)
Local lRet := .T.
Local nTam := 0
nTam := getSX3Cache(cCampo, "X3_TAMANHO")
if nVal > nTam 
   cTxt1 := StrTran(STR0041, '#####', alltrim(str(nVal)))
   cTxt1 := StrTran(cTxt1, '$$$$$', alltrim(str(nTam)))
   cTxt2 := StrTran(STR0042, '$$$$$', alltrim(str(nTam)))
   easyHelp(cTxt1, STR0015, cTxt2) // "Tamanho selecionado ##### não pode ser maior que o tamanho máximo($$$$$) permitido pelo dicionário de dados. " ### "Atenção" ### "Informe um tamanho menor ou igual a $$$$$"
   lRet := .F.
endif
return lRet


/*/{Protheus.doc} VLD_LJDF
   Função para validação dos campos de dicionário do pergunte EICCP404
   @type  Static Function
   @author user
   @since 03/07/2025
   @version version
   @param nUsaLoja cCampo, caracater, campo a ser validado
          nVal, numérico, valor digitado no pergunte          
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
Static function VLD_LJDF(nUsaLoja,cLojaDefault)
Local lRet := .T.
if nUsaLoja == 2 .AND. EMPTY(cLojaDefault)
   easyHelp(STR0043, STR0015, STR0044) // "A opção 'Utiliza o conceito de Loja' foi selecionada como não, então o campo Loja default deve ser informado." Atenção  "Informe o campo Loja Default."
   lRet := .F.
endif
Return lRet   

/*/{Protheus.doc} EIC404Ini
   Função para inicialização padrão de campos do pergutne EICCP404
   @type  Static Function
   @author user
   @since 03/07/2025
   @version version
   @param cCampo, caracater, campo a ter valor padrão inicializado
   @return nRet, numérico, retorna o tamanho do campo ou o valor padrão
   @example
   (examples)
   @see (links_or_references)
/*/
function EIC404Ini(cCampo)
local nRet := getSX3Cache(cCampo, "X3_TAMANHO")
Do case
   Case cCampo == "A2_COD"
      nRet := if(empty(MV_PAR02),nRet, MV_PAR02)
   Case cCampo == "A2_LOJA"      
      nRet := if(empty(MV_PAR05),nRet, MV_PAR05)   
EndCase
Return nRet

/*/{Protheus.doc} validStep3
   Função para validação do step 3 do Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function validStep3()
local lRet := .T.
local aPergunte  := {}
Pergunte('EICCP404',.F.,,,,,aPergunte)
MV_PAR02 := EIC404Ini('A2_COD')
MV_PAR05 := EIC404Ini('A2_LOJA')
__SaveParam('EICCP404', aPergunte)
lRet := Pergunte('EICCP404',.T.)
if lRet .and. !EIC404VLD('LJDF') //este cenário trata quando o usuário não utiliza o conceito de loja e deixar o campo Loja Default em branco
   validStep3()
EndIf   
return lRet

/*/{Protheus.doc} ViewOper
   Função para introdução do Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version versionverificações
   @param oPanel, objeto, objeto que será apresentado a introdução
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewOper(oPanel)
   local aCoords    := {}
   local cIntrod    := "" 
   local oSay       := nil
   local oFont      := nil   
   aCoords := FWGetDialogSize(oPanel)      
   cIntrod := STR0045 + ENTER + ENTER + STR0046 
   
    //Nesta etapa, será necessário informar ao sistema os tamanhos dos campos código e loja que serão considerados durante o processamento. Essas informações serão utilizadas na leitura do código Interno informado no Portal único para o Operador Estrangeiro, a fim de verificar a existência desse registro no cadastro de Fornecedores (SA2) do ERP.
    //"Lembrando que todo o processo será executado na filial corrente e caso a tabela de Fornecedores esteja configurada com a forma de acesso exclusiva, todas as verificações e inclusões ocorreão na filial corrente."
   
   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return nil

/*
Função     : ViewProc
Objetivo   : Função para o resultado final do processamento
Retorno    : 
Autor      : Maurício Frison  
Data/Hora  : Julho/2025
Obs.       :
*/
static function ViewProc(oPanel, oBrowProc, aFiles)
   local lRet       := .T.
   local oProc      := nil

   BrowseProc(oPanel, @oBrowProc)
   oProc := MsNewProcess():New({|lEnd| ProcImp(@lEnd, @oBrowProc,@oProc, aFiles), oBrowProc:Refresh() }, STR0011 + "...",, .T.) // "Importando o arquivo"   
   oProc:Activate() 
Return lRet

/*/{Protheus.doc} BrowseProc
   Função para apresentação do browse de processamento dos catalogos de produtos para o Wizard

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param oPanel, objeto, objeto que será apresentado a introdução
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function BrowseProc(oPanel, oBrowProc)
   local lRet       := .T.
   local cAliasTmp  := CP404_TABLE                       
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}
   local oLayer     := nil
   local cLib       := ""
   local cTexto     := ""
   local oPnlBrowse := nil
   
   if oBrowProc == nil
      aRotina := {} 
      aStruct := (cAliasTmp)->(dbStruct())
      for nCpo := 1 To Len(aStruct)
         if aStruct[nCpo][1] # 'STATUS' .and. aStruct[nCpo][1] # 'SEQUENCIA'
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle(setTitulo(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            if aStruct[nCpo][1] == "RETORNO"
               aColumns[Len(aColumns)]:SetDoubleClick({|| EECView((cAliasTmp)->RETORNO, STR0023,,,,,.T.) }) // "Mensagem"
            EndIf            
         Endif   
      next nCpo 

      oLayer := FWLayer():New()
      GetRemoteType(@cLib)
      cTexto := STR0052 //'Resultado da importação do arquivo'  
      ViewTitulo(oLayer, 10, 90, oPanel, cTexto, @oPnlBrowse)

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
      oBrowProc:AddLegend("STATUS == '" + PROCESSADO  + "' ","BR_VERDE"    , STR0047 ) // "Processado com sucesso"
      oBrowProc:AddLegend("STATUS == '" + EXISTENTE   + "' ","BR_CINZA"    , STR0048 ) // "Catálogo existente"
      oBrowProc:AddLegend("STATUS == '" + ERRO        + "' ","BR_VERMELHO" , STR0049 ) // "Falha na importação"
      oBrowProc:SetColumns( aColumns )
      oBrowProc:Activate()

      oBrowProc:oBrowse:Refresh(.T.)
      oBrowProc:oBrowse:SetFocus()

   endif
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
   local aIndex     := {}
   local cAliasTmp  := CP404_TABLE

   default oEasyTmp := EasyTemporaryTable():new()

   aSemSX3 := {}
   aAdd(aSemSX3, {"STATUS"     , "C"                                , 01                                    , 0                                        })
   aAdd(aSemSX3, {"OPERACAO"   , "C"                                , 21                                    , 0                                        })
   aAdd(aSemSX3, {"EK9_IDPORT" , getSX3Cache( "EK9_IDPORT", "X3_TIPO"), getSX3Cache( "EK9_IDPORT", "X3_TAMANHO"), getSX3Cache( "EK9_IDPORT", "X3_DECIMAL") })
   aAdd(aSemSX3, {"EK9_VATUAL" , getSX3Cache( "EK9_VATUAL", "X3_TIPO"), getSX3Cache( "EK9_VATUAL", "X3_TAMANHO"), getSX3Cache( "EK9_VATUAL", "X3_DECIMAL") })
   aAdd(aSemSX3, {"RETORNO"    , "M"                                  , 250                                     , 0                                        })
   aAdd(aSemSX3, {"SEQUENCIA"  , "N"                                  , 12                                      , 0                                        })

   aIndex := {}
   aAdd(aIndex, "SEQUENCIA" )
   aAdd(aIndex, "EK9_IDPORT+EK9_VATUAL" )
   aAdd(aIndex, "STATUS" )
   aAdd(aIndex, "OPERACAO" )
   oEasyTmp:setData(nil, aSemSX3, cAliasTmp, aIndex)

return

/*/{Protheus.doc} eraseTable
   Função destruir o objeto da classe EasyTemporaryTable

   @type  Static Function
   @author user
   @since 07/07/2025
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

/*/{Protheus.doc} setTitulo
   Função para gerar o títulos das colunas do browse
   @type  Static Function
   @author user
   @since 08/07/2025
   @version version
   @param cCampo, campo a ter o seu título gerado
   @return cRet, retorna o título do campo
   @example
   (examples)
   @see (links_or_references)
/*/
static function setTitulo(cCampo)
   local cRet := ""
   do Case 
      case cCampo == "STATUS"
         cRet := STR0050 // "Status"   
      case cCampo == "OPERACAO"
         cRet := STR0051 // "Operação"
      case cCampo == "RETORNO"
         cRet := STR0023 // "Log da importação do arquivo"
      OtherWise
         cRet := RetTitle(cCampo)
   endCase   
Return cRet   

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


/*/{Protheus.doc} ProcImp
   Função para realizar a importação dos arquivos baixados pelo portal único
   @type  Static Function
   @author user
   @since 08/07/2025
   @version version
   @param lEnd, logico, para finalizar o processamento
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          aFiles, array, array com os arquivos baixados do portal único
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function ProcImp(lEnd, oBrowProc, oProc, aFiles)
Local lRet       := .F.
Local cArqOpe    := aFiles[1] //OPERADORES_ESTRANGEIROS_*.json
Local cArqCat    := aFiles[2] //CATALOGO_PRODUTOS_*.json
Local cArqFab    := aFiles[3] //FABRICANTE_PRODUTOR_*.json
Local cCatalogo  := ""
Local oJsonOpe   := JsonObject():New()
Local oJsonCat   := JsonObject():New()
Local oJsonFab   := JsonObject():New()
Local lProcCat   := .T.
Local lProcFab   := .T.
Local lProcOpe   := .T.
Local oModelo    := nil
Local oModelEK9  := nil
Local oModelEKC  := nil
Local i, nAtrib, nComposto, nFab
local aFabJson := {}
local nCodCat := 0
local aFabProd := {}
local cLogAtt  := ""
local lLinhaOK
local nfiles := 0
local aJsonFab := nil
local cVersao  := nil
local cCodPortal := nil
local nSeq      := nil
local cLogProd := ""
local aJson    := {}

   oProc:SetRegua1(2)
   oProc:IncRegua1()
   // Validações iniciais do JSON

   for i:=1 to len(aFiles)
       aJson := getFile(aFiles[i]) 
       if empty(aJson) .or. valType(aJson) # "A" .or. len(aJson) == 0
            Return .f.
       Endif
   Next i         

   oJsonOpe:FromJson(ImpTxtJson(cArqOpe)) //"importação do arquivo JSON", "Abrindo arquivo OPERADORES_ESTRANGEIROS")
   oJsonCat:FromJson(ImpTxtJson(cArqCat)) //"importação do arquivo JSON", "Abrindo arquivo CATALOGO_PRODUTOS")
   oJsonFab:FromJson(ImpTxtJson(cArqFab)) //"importação do arquivo JSON", "Abrindo arquivo FABRICANTE_PRODUTOR")

   lProcOpe := isJsonVld(oJsonOpe, "ope") //"importação do arquivo JSON", "Validando o arquivo OPERADORES_ESTRANGEIROS")
   lProcCat := isJsonVld(oJsonCat, "cat") //"importação do arquivo JSON", "Validando o arquivo CATALOGO_PRODUTOS")
   lProcFab := isJsonVld(oJsonFab, "fab") //"importação do arquivo JSON", "Validando o arquivo FABRICANTE_PRODUTOR")

   If !lProcCat .Or. !lProcFab .Or. !lProcOpe
      EasyHelp(STR0065, STR0004, STR0066) // "Um ou mais arquivos possuem estruturas inconsistentes."### "Atenção"###"Verifique se o arquivo foi importado corretamente do Portal único."
      Return .F.
   EndIf
   
   ProcOE(oBrowProc,aFiles,@aFabProd,@oProc)

   aJsonFab := getFile(aFiles[3])
   
   oProc:IncRegua1()
   oProc:SetRegua2(Len(oJsonCat))

   // Inicialização do modelo de dados e demais tabelas
   EK9->(DbsetOrder(1)) // EK9_FILIAL+EK9_COD_I+EK9_VATUAL
   EKA->(DbsetOrder(1)) // EKA_FILIAL+EKA_COD_I+EKA_PRDREF+EKA_ITEM
   EKB->(DbsetOrder(1)) // EKB_FILIAL+EKB_COD_I+EKB_CODFAB+EKB_LOJA
   EKC->(DbsetOrder(1)) // EKC_FILIAL+EKC_COD_I+EKC_CODATR+EKC_CONDTE

   oModelo := FwLoadModel("EICCP400")
   oModelo:SetOperation(MODEL_OPERATION_INSERT)

   // Processamento do arquivo CATALOGO_PRODUTOS
   For i := 1 to Len(oJsonCat)
      cLogAtt := ""
      cLogProd := ""
      oProc:incRegua2()
      cCodPortal := AllTrim(Str(oJsonCat[i]['codigo'])) 
      cVersao := oJsonCat[i]['versao']
      nSeq := oJsonCat[i]['seq']
      // Ignora os registros desativados ou rascunhos provenientes do Portal único
      If oJsonCat[i]['situacao'] != "Ativado"
         //"Registro com status diferente de 'Ativado' não será processado."
         gravaLog(oBrowProc,nSeq,ERRO, CATALOGO, getStatus(ERRO) + ENTER + STR0064, cCodPortal, cVersao)
         Loop
      EndIf

      // Processamento do modelo de dados
      lRet := oModelo:Activate()
      If lRet
         oModelEK9 := oModelo:getModel("EK9MASTER")
         cCatalogo := oModelEK9:GetValue("EK9_COD_I")
         nCodCat := oJsonCat[i]['codigo']
         // Preenchimento dos campos obrigatórios com validação
         lLinhaOK := .T.

         lLinhaOK := oModelEK9:SetValue("EK9_IDMANU", AllTrim(Str(oJsonCat[i]['codigo'])))
         oModelEK9:SetValue("EK9_DESC_I", oJsonCat[i]['denominacao'])

         if lLinhaOK
            lLinhaOK := oModelEK9:SetValue("EK9_CNPJ", avkey(oJsonCat[i]['cpfCnpjRaiz'],'EKJ_CNPJ_R'))
         endif

         if lLinhaOK
            lLinhaOK := oModelEK9:SetValue("EK9_NCM", oJsonCat[i]['ncm'])
         endif

         if lLinhaOK
            lLinhaOK := oModelEK9:SetValue("EK9_VSMANU", oJsonCat[i]['versao'])
         endif

         if !lLinhaOK
            gravaLog(oBrowProc,nSeq,ERRO, CATALOGO, STR0068 + trataErro(oModelo:GetErrorMessage()), AllTrim(Str(oJsonCat[i]['codigo'])), oJsonCat[i]['versao'])
            oModelo:DeActivate()
            Loop
         endif
         IIF(oJsonCat[i]:hasProperty('descricao'), oModelEK9:SetValue("EK9_DSCCOM", oJsonCat[i]['descricao']),)

         oModelEKA := oModelo:getModel("EKADETAIL")
         oModelEKB := oModelo:getModel("EKBDETAIL")
         oModelEKC := oModelo:getModel("EKCDETAIL")

         oModelEKC:SetNoInsertLine(.F.) // Habilita a inserção de linhas no modelo EKC

         If oJsonCat[i]:hasProperty('atributos') .And. Len(oJsonCat[i]["atributos"]) > 0
            For nAtrib := 1 to Len(oJsonCat[i]["atributos"])
               If oJsonCat[i]["atributos"][nAtrib]:hasProperty('atributo')
                  If oModelEKC:SeekLine({{"EKC_COD_I", cCatalogo}, {"EKC_VERSAO", oJsonCat[i]['versao']}, {"EKC_CODATR", oJsonCat[i]["atributos"][nAtrib]['atributo']}})
                     //oModelEKC:SetValue("EKC_CODATR", oJsonCat[i]["atributos"][nAtrib]['atributo'])
                     oModelEKC:SetValue("EKC_VALOR", oJsonCat[i]["atributos"][nAtrib]['valor'])
                  Else
                     cLogAtt := cLogAtt + STR0069 + oJsonCat[i]["atributos"][nAtrib]['atributo'] + ENTER //"Atributo não encontrado: "
                  EndIf
               EndIf
            Next nAtrib
         EndIf

         If oJsonCat[i]:hasProperty('atributosMultivalorados') .And. Len(oJsonCat[i]["atributosMultivalorados"]) > 0
            For nAtrib := 1 to Len(oJsonCat[i]["atributosMultivalorados"])
               If oJsonCat[i]["atributosMultivalorados"][nAtrib]:hasProperty('atributo')
                  If oModelEKC:SeekLine({{"EKC_COD_I", cCatalogo}, {"EKC_VERSAO", oJsonCat[i]['versao']}, {"EKC_CODATR", oJsonCat[i]["atributosMultivalorados"][nAtrib]['atributo']}})
                     //oModelEKC:SetValue("EKC_CODATR", oJsonCat[i]["atributosMultivalorados"][nAtrib]['atributo'])
                     oModelEKC:SetValue("EKC_VALOR", ArrTokStr(oJsonCat[i]["atributosMultivalorados"][nAtrib]['valores'], ";"))
                  Else
                     cLogAtt := cLogAtt + STR0069 + oJsonCat[i]["atributosMultivalorados"][nAtrib]['atributo'] + ENTER //"Atributo não encontrado: "
                  EndIf
               EndIf
            Next nAtrib
         EndIf

         If oJsonCat[i]:hasProperty('atributosCompostos') .And. Len(oJsonCat[i]["atributosCompostos"]) > 0
            For nAtrib := 1 to Len(oJsonCat[i]["atributosCompostos"])
               For nComposto := 1 to Len(oJsonCat[i]["atributosCompostos"][nAtrib]['valores'])
                  If oJsonCat[i]["atributosCompostos"][nAtrib]['valores'][nComposto]:hasProperty('atributo')
                     If oModelEKC:SeekLine({{"EKC_COD_I", cCatalogo}, {"EKC_VERSAO", oJsonCat[i]['versao']}, {"EKC_CODATR", oJsonCat[i]["atributosCompostos"][nAtrib]['valores'][nComposto]['atributo']}, {"EKC_CONDTE", oJsonCat[i]["atributosCompostos"][nAtrib]['atributo']}})
                        //oModelEKC:SetValue("EKC_CODATR", oJsonCat[i]["atributosCompostos"][nAtrib]['valores'][nComposto]['atributo'])
                        oModelEKC:SetValue("EKC_VALOR", oJsonCat[i]["atributosCompostos"][nAtrib]['valores'][nComposto]['valor'])
                        oModelEKC:SetValue("EKC_CONDTE", oJsonCat[i]["atributosCompostos"][nAtrib]['atributo'])
                     Else
                        cLogAtt := cLogAtt + STR0069 + oJsonCat[i]["atributosCompostos"][nAtrib]['valores'][nComposto]['atributo'] + ENTER //"Atributo não encontrado: "
                     EndIf
                  EndIf
               Next nComposto
            Next nAtrib
         EndIf

           /*
         If Len(oJsonCat[1]["atributosCompostosMultivalorados"]) > 0
            // Comentado pois sem exemplo de implementação
            // For nAtrib := 1 to Len(oJsonCat[i]["atributosCompostosMultivalorados"])
            // Next nAtrib
         EndIf  
         */

         //Fim do processamento dos atributos. Verifica se deu erro em algum atributo
         If !Empty(cLogAtt)
            gravaLog(oBrowProc,nSeq,ERRO, CATALOGO, STR0070 + ENTER + STR0071 + Transform(oJsonCat[i]['ncm'], AvSX3("YD_TEC", AV_PICTURE)) + ". " + ENTER + cLogAtt, AllTrim(Str(oJsonCat[i]['codigo'])), oJsonCat[i]['versao'])  
            oModelo:DeActivate()
            Loop
         EndIf

         // Processamento do modelo de dados EKA
         lRet := ProcPR(oJsonCat[i],oModelEKA,oModelo, @cLogProd)

         // Processamento do arquivo 
         
         oModelEKB:SetNoInsertLine(.F.) // Habilita a inserção de linhas no modelo EKB
         aFabJson := getFab(aJsonFab, nCodCat,aFabProd)
         for nFab := 1 to len(aFabJson)
            If !(oModelEKB:Length() == 1 .And. Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. Empty(oModelEKB:GetValue("EKB_PAIS")))
               oModelEKB:AddLine()
            EndIf            
            ///obs: Não trocar a ordem e nem o tipo de load, set load abaixo
            //Carregar o fabricante sem validaçaõ para validar na loja
            //Carregar a loja com validação para validar o fabricante            
            //Carregar o país sem validação, senão breca no when
            oModelEKB:loadValue("EKB_CODFAB", aFabJson[nFab][2])
            oModelEKB:setValue("EKB_LOJA",   aFabJson[nFab][3])            
            oModelEKB:setValue("EKB_PAIS",   aFabJson[nFab][4])
            xErro := trataErro(oModelo:GetErrorMessage())            
            if !empty(xErro)
                cLogProd += getFabErro(xErro,aFabJson[nFab][2],aFabJson[nFab][3],aFabJson[nFab][4]) 
            EndIf    
         next nFab                 

         lRet := (oModelo:VldData() .and. lRet .and. empty(cLogProd)) // Verifica se o modelo de dados está válido e se não houve erro no log do produto
         IIF(lRet, oModelo:CommitData(), xErro := oModelo:GetErrorMessage())
         gravaLog(oBrowProc, nSeq, IIF(lRet, PROCESSADO, ERRO), CATALOGO, IIF(lRet, STR0072 , STR0049+"." + ENTER + cLogProd + ENTER + trataErro(xErro)), AllTrim(Str(oJsonCat[i]['codigo'])), oJsonCat[i]['versao'])
         oBrowProc:Refresh()
         oModelo:DeActivate()
      EndIf      

   Next i

   for nfiles :=1 to len(aFiles)
       TrocaExt(aFiles[nfiles], ".JSON")
   next nfiles    

Return lRet

/*/{Protheus.doc} trataErro
   Função para tratar a mensagem de erro do modelo de dados
   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param xErro, variado, erro retornado pelo modelo de dados
   @return cRet, caracter, mensagem de erro tratada
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function trataErro(xErro)
Return if( valtype(xErro) == "C", alltrim(xErro), if( valtype(xErro) == "A" .and. len(xErro) >= 7 .And. (!Empty(xErro[6]) .Or. !Empty(xErro[7])), ENTER + STR0073 + ": " + allToChar( xErro[6]) + ENTER + STR0074 + ": " + allToChar( xErro[7] ) , "") ) //"Problema"#### "Solução"


/*/{Protheus.doc} geraExcel
   Função para geração do resultado do processamento em Excel

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param 
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
static function geraExcel()
   local oExcel     := nil
   local cWorksheet := ""
   local cTable     := ""
   local cAliasTmp  := CP404_TABLE
   local aStruct    := {}
   local nCpo       := 0
   local cCampo     := ""
   local cValor     := ""
   local aRow       := {}
   local cArquivo   := ""
   local i          := 0

   cWorksheet := STR0025 // "Resultado da importação"
   cTable := STR0053 // "Processamento da importação de arquivos baixados do portal do único"

   oExcel := FwMsExcelXlsx():New()
   oExcel:AddworkSheet(cWorksheet)
   oExcel:AddTable(cWorksheet, cTable)

   aStruct := (cAliasTmp)->(dbStruct())

   if (i:=aScan(aStruct, {|x| x[1] == "SEQUENCIA"})) > 0
      aDel(aStruct,i)
		aSize(aStruct,Len(aStruct)-1)
   EndIf

   for nCpo := 1 to Len(aStruct)
         oExcel:AddColumn(cWorksheet, cTable, setTitulo(aStruct[nCpo][1])) 
   next nCpo

   (cAliasTmp)->(dbGoTop())
   while (cAliasTmp)->(!eof())
      aRow := {}
      for nCpo := 1 to Len(aStruct)
         cCampo := aStruct[nCpo][1]
         cValor := (cAliasTmp)->&(cCampo)
         aAdd( aRow, if(cCampo== "STATUS", getStatus(cValor), cValor))
      next nCpo

      oExcel:Addrow(cWorksheet, cTable, aClone(aRow))
      (cAliasTmp)->(dbSkip())
   end

   oExcel:Activate()
   cArquivo := CriaTrab(Nil, .F.) + ".xlsx"
   oExcel:GetXMLFile(cArquivo)
   oExcel:DeActivate()
   FwFreeObj(oExcel)

   MsAguarde( {|| comex.generics.TEOpenExcel(cArquivo)}, STR0054 + "...") // "Gerando o arquivo excel"

// Retorna falso para não realizar mudanças na página
return .F.

/*/{Protheus.doc} getStatus
   Função para gerar o nome do status na planilha excel
   @type  Static Function
   @author user
   @since 10/07/2025
   @version version
   @param cStatus, caracter, código do status a ser convertido para o título
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/

static function getStatus(cStatus)
Local cRet := ""
   do case
      case cStatus == PROCESSADO
         cRet := STR0047 // "Processado com sucesso
      case cStatus == EXISTENTE
         cRet := STR0048 // "Registro já existente"
      case cStatus == ERRO
         cRet := STR0049 // "Falha na importação"
   endcase
Return cRet   


/*/{Protheus.doc} ImpTxtJson
   Função para abrir o arquivo Json como texto e retornar o conteúdo como objeto Json
   @type  Static Function
   @author user
   @since 08/07/2025
   @version version
   @param cArquivo, String, Caminho do arquivo Json a ser processado
   @return cBuffer, String, Conteúdo do arquivo Json lido
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function ImpTxtJson(cArquivo)
Local cBuffer  := ""
Local nHandle  := -1
Local nSize    := 0
Local nBytes   := 0

   nHandle := fOpen(cArquivo)
   If nHandle <> -1
      nSize := fSeek(nHandle, 0, 2)
      fSeek(nHandle, 0)
      nBytes := fRead(nHandle, @cBuffer, nSize)
      fClose(nHandle)
      cBuffer := DecodeUTF8(cBuffer)
   EndIf

Return cBuffer

/*/{Protheus.doc} isJsonVld
   Função para validar se o Json possui os campos necessários para o processamento
   @type  Static Function
   @author user
   @since 09/07/2025
   @version version
   c:\g@param oJson, JsonObject, Objeto Json a ser validado
          cTipo, String, Tipo de validação (ope, cat, fab)
   @return lRet, logico, .T. se o Json possui os campos necessários, .F. caso contrário
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function isJsonVld(oJson, cTipo)
Local aHeadersOpe := { "seq", "cpfCnpjRaiz", "codigo", "versao", "tin", "nome", "situacao", "logradouro", "nomeCidade", "codigoSubdivisaoPais", "codigoPais", "codigoInterno"}
Local aHeadersCat := { "seq", "codigo", "denominacao", "cpfCnpjRaiz", "situacao", "modalidade", "ncm", "versao"}
Local aHeadersFab := { "seq", "codigoPais", "cpfCnpjRaiz","conhecido", "codigoProduto"}
Local aHeaders    := {}
Local aProperties := oJson[1]:GetNames()
Local lRet := .T.
Local i

   Do Case
      Case cTipo == "ope"
         aHeaders := aHeadersOpe
      Case cTipo == "cat"
         aHeaders := aHeadersCat
      Case cTipo == "fab"
         aHeaders := aHeadersFab
   End Case
   
   For i := 1 To Len(aHeaders)
      If aScan(aProperties, {|x| x == aHeaders[i]}) == 0
         lRet := .F.
         Exit
      EndIf
   Next i
   
Return lRet

/*/{Protheus.doc} TrocaExt
   Função para trocar a extensão do arquivo para ".processado" após o sistema processar o arquivo
   @type  Static Function
   @author Nícolas Castellani Brisque
   @since 08/07/2025
   @version version
   @param cArquivo, String, Caminho do arquivo a ser processado
   @param cExtensao, String, Extensão do arquivo a ser processado
   @return
   @example
   TrocaExt("C:\temp\arquivo.json", ".json")
   @see (links_or_references)
/*/
Static Function TrocaExt(cArquivo, cExtensao)
Local aTemp     := {}
Local cArqNome  := ""
Local cName := ''

   aTemp := StrTokArr(cArquivo, "\")
   cArqNome := aTemp[Len(aTemp)]
   cName := StrTran(cArquivo, cExtensao, ".processado")
   IIF(!(FRename(cArquivo, cName) == 0), MsgInfo(STR0067 + StrTran(cArqNome, cExtensao, ".processado") + ENTER + Str(fError()), STR0004),) // ""Não foi possível renomear o arquivo para: "

Return


/*/{Protheus.doc} getFab
   Função para gerar um array com os códigos do catálogo dentro do json do fabricante
   @type  Static Function
   @author Maurício Frison
   @since 25/07/2025
   @version version
   @param oJsonFab, json, json dos fabricantes
   @return aFab, array, array com os códigos dos fabricantes
   @description
   @example
   @see (links_or_references)
/*/
static function getFab(aJsonFab, nCodCat, aFabProd, cForn, cLoja)
Local aFab := {}
Local iFab := nil     
Local cCodOp  := ""
Local nSeq    := 0
Local cCnpj := ""
Local cPais := ""
Local nLen := len(aJsonFab)
if (iFab:=aScan(aJsonFab, {|X| X['codigoProduto'] == nCodCat})) > 0
   do While iFab <= nLen .and. aJsonFab[iFab]['codigoProduto'] == nCodCat
      nSeq    := aJsonFab[iFab]['seq']
      cCodOp  := aJsonFab[iFab]['codigoOperadorEstrangeiro']
      cCnpj   := aJsonFab[iFab]['cpfCnpjRaiz']
      cPais   := aJsonFab[iFab]['codigoPais']
      cVersao := ''
      getFornLj(@cForn, @cLoja, cCodOp, aFabProd,cCnpj)
      aAdd(aFab,{nSeq,cForn,cLoja,cPais,cVersao,cCodOp})
      iFab++
   EndDo   
EndIf
Return aFab   

Static function getFornLj(cForn, cLoja, cCodOp, aFabProd,cCnpj)
local i:= 0
cForn :=''
cLoja := ''
if !Empty(cCodOp) .and. (i:=aScan(aFabProd, {|x| x[1] == cCodOp .and. x[4] == cCnpj})) > 0
   cForn := aFabProd[i][2]  
   cLoja := aFabProd[i][3]
EndIf
Return
   
/*/{Protheus.doc} ProcOE
   Função para processar o arquivo de operadora estrangeiro
   @type  Static Function
   @author user
   @since 17/07/2025
   @version version
   @param aArq, array com o arquivo a ser processado (Ã­ndice 1) é o arquivo de operadora estrangeiro
          oBrowProc, objeto, objeto que será o browse dos catalogos de produtos
          aFabPRod, array, array com os fabricantes produtor que serão processados com sucesso
   @return sem retorno
   @example
   (examples)
   @see (links_or_references)
/*/

static function ProcOE(oBrowProc,aFiles,aFabProd,oProc)
local aJsonOE := nil
local nje := 0
local nSeq       := nil
local cTin       := nil
local cNome      := nil
local cSituacao  := nil
local cLogradour := nil
local cNomeCid   := nil   
local cSubdivPai := nil
local cCodPais   := nil
local cCep       := nil
local lValid     := nil
local cCodPortal := nil
local cVersao    := nil
local cCpfCnpj   := nil
local cForn      := nil
local cLoja      := nil
local cCodInt    := nil
local nIncluiSA2 := MV_PAR01

aJsonOE := getFile(aFiles[1])
if !empty(aJsonOE) .and. valType(aJsonOE) == "A" .and. len(aJsonOE) > 0
   oProc:SetRegua2(len(aJsonOE))
   for nje := 1 to len(aJsonOE)
      oProc:incRegua2()
      getValues(@nSeq,@cCodPortal,@cCodInt,@cCpfCnpj,@cVersao,@cTin,@cNome,@cSituacao,@cLogradour,@cNomeCid,@cSubdivPai,@cCodPais,@cCep,aJsonOE[nje])
      if cSituacao == "Ativado"
         ExtFornLj(cCodint,@cForn,@cLoja)
         aadd(aFabProd,{cCodPortal,cForn,cLoja,cCpfCnpj})
         lValid := ValidOE(oBrowProc,nSeq,cCodPortal,cVersao,cCpfCnpj,cForn,cLoja,cCodInt)   
         lValid := setSA2(oBrowProc,nSeq,cCodPortal,cVersao,nIncluiSA2,cForn,cLoja,cNome,cCep,cLogradour,cNomeCid,cSubdivPai,cCodPais,lValid) 
         setOpEstr(oBrowProc,nSeq,cCodPortal,cCodInt,cCpfCnpj,cForn,cloja,cVersao,cTin,cNome,cSituacao,cLogradour,cNomeCid,cSubdivPai,cCodPais,cCep,lValid)
      EndIf         
   next nje
EndIf
Return   

/*/{Protheus.doc} ProcPR
   Função para processar a vinculação dos produtos
   @type  Static Function
   @author user
   @since 17/07/2025
   @version version
   @param   oJsonCat, json, objeto json com os dados do catálogo de produtos
            oModelEKA, objeto, modelo de dados EKA
            oModelo, objeto, modelo de dados do catálogo de produtos          
   @return true se bem sucedido e false se não
   @example
   (examples)
   @see (links_or_references)
/*/

static function ProcPR(oJsonCat,oModelEKA,oModelo, cErro)
local i := nil
local lRet := .T.
local aJson := oJsonCat['codigosInterno']
local cNcm := AvKey(oJsonCat['ncm'], 'YD_TEC')

Default cErro := ""

oModelEKA:SetNoInsertLine(.F.) // Habilita a inserção de linhas no modelo EKA
SB1->(DbSetOrder(1))
for i:=1 to len(aJson)
   lRet := SB1->(dbSeek(xFilial("SB1") + AvKey(aJson[i],'B1_COD')))
   if !lRet
      cErro := cErro + STR0076 + Alltrim(aJson[i]) +"." + ENTER //"O Produto não foi vinculado ao Catálogo de Produtos, pois não foi encontrado no SB1: "
      loop
   EndIf
   If cNcm <> SB1->B1_POSIPI
      cErro := cErro + STR0077 + Alltrim(aJson[i]) + STR0078 + ENTER + STR0079 + Transform(Alltrim(SB1->B1_POSIPI), AvSX3("YD_TEC", AV_PICTURE)) + ENTER + STR0080 + Transform(AllTrim(cNcm), AvSX3("YD_TEC", AV_PICTURE))+"." + ENTER //"O produto "###" não foi vinculado ao Catálogo de Produtos: "###"Ncm do Produto: "###"Ncm do Catálogo: "
      loop
   EndIf

   If !oModelEKA:SeekLine({{"EKA_PRDREF", aJson[i]}})
      If !(oModelEKA:Length() == 1 .And. Empty(oModelEKA:GetValue("EKA_PRDREF"))) 
         oModelEKA:AddLine()
      EndIf            
      lRet := oModelEKA:setValue("EKA_PRDREF", aJson[i])
      oModelEKA:setValue("EKA_ITEM", strzero(i,getSX3Cache("EKA_ITEM","X3_TAMANHO")))
      IIf(!lRet, cErro := cErro + getErro(oModelo:GetErrorMessage()),)
   EndIf
next i   
lRet := Empty(cErro)
Return lRet


/*/{Protheus.doc} getValues
   Função pegar os valores do json
   @type  Static Function
   @author user
   @since 21/07/2025
   @version version
   @param cCodPortal, caracter, código do portal
          cCodInt, caracter, código interno do operador estrangeiro
          cCpfCnpj, caracter, cpf ou cnpj do operador estrangeiro
          cVersao, caracter, versão do operador estrangeiro
          cTin, caracter, TIN do operador estrangeiro
          cNome, caracter, nome do operador estrangeiro
          cSituacao, caracter, situação do operador estrangeiro
          cLogradour, caracter, logradouro do operador estrangeiro
          cNomeCid, caracter, nome da cidade do operador estrangeiro
          cSubdivPai, caracter, subdivisão pai do operador estrangeiro
          cCodPais, caracter, código do país do operador estrangeiro
          cCep, caracter, cep do operador estrangeiro
          aJsonOE, array de jsons com os dados a serem processados
   @return sem retorno
   @example
   (examples)
   @see (links_or_references)
/*/
static function getValues(nSeq,cCodPortal,cCodInt,cCpfCnpj,cVersao,cTin,cNome,cSituacao,cLogradour,cNomeCid,cSubdivPai,cCodPais,cCep,aJsonOE)
       nSeq        := if(aJsonOE["seq"]==nil,0,aJsonOE["seq"])
       cCodPortal := if(aJsonOE["codigo"]==nil,'',aJsonOE["codigo"])
       cCodInt    := if(aJsonOE["codigoInterno"]==nil,'',aJsonOE["codigoInterno"])
       cCpfCnpj   := if(aJsonOE["cpfCnpjRaiz"]==nil,'',aJsonOE["cpfCnpjRaiz"])
       cVersao    := if(aJsonOE["versao"]==nil,'',aJsonOE["versao"])
       cTin       := if(aJsonOE["tin"]==nil,'',aJsonOE["tin"])
       cNome      := if(aJsonOE["nome"]==nil,'',aJsonOE["nome"])   
       cSituacao  := if(aJsonOE["situacao"]== nil,'',aJsonOE["situacao"])
       cLogradour := if(aJsonOE["logradouro"]==nil,'',aJsonOE["logradouro"])
       cNomeCid   := if(aJsonOE["nomeCidade"]==nil,'',aJsonOE["nomeCidade"])
       cSubdivPai := if(aJsonOE["codigoSubdivisaoPais"]==nil,'',aJsonOE["codigoSubdivisaoPais"])
       cCodPais   := if(aJsonOE["codigoPais"]==nil,'',aJsonOE["codigoPais"])
       cCep       := if(aJsonOE["cep"]==nil,'',aJsonOE["cep"]) 
Return       

/*/{Protheus.doc} setSA2
   Função para verificar se não existe o fabricante/fornecedor e incluir se nao existir
   @type  Static Function
   @author user
   @since 21/07/2025
   @version version
   @param oBrowProc, objeto, objeto que será o browse da tela
          cCodPortal, caracter, código do portal
          cVersao, caracter, versão do operador estrangeiro
          nIncluiSA2, numérico, se deve incluir o SA2
          cForn, caracter, código do fornecedor
          cLoja, caracter, código da loja       
          cNome, caracter, nome do operador estrangeiro
          cCep, caracter, cep do operador estrangeiro
          cLogradour, caracter, logradouro do operador estrangeiro
          cNomeCid, caracter, nome da cidade do operador estrangeiro
          cSubdivPai, caracter, subdivisão pai do operador estrangeiro
          cCodPais, caracter, código do país do operador estrangeiro
   @return sem retorno
   @example
   (examples)
   @see (links_or_references)
/*/static function setSA2(oBrowProc,nSeq,cCodPortal,cVersao,nIncluiSA2,cForn,cLoja,cNome,cCep,cLogradour,cNomeCid,cSubdivPai,cCodPais,lValid)               
local aDadosSA2 := {}
local aLogErro:= {}
local cErroMsg := ""
local nCont := 0
local lRet := lValid
Private lMsErroAuto := .f.
Private lAutoErrNoFile := .T.

if lValid .and. nIncluiSA2 == 1 
   cForn    :=  avkey(cForn,'A2_COD')
   cLoja    :=  avkey(cLoja,'A2_LOJA')
   if  Empty(Posicione("SA2", 1, xFilial("SA2") + cForn + cLoja, "A2_COD"))
      aAdd(aDadosSA2, {"A2_COD",     cForn})
      aAdd(aDadosSA2, {"A2_LOJA",    cLoja})
      aAdd(aDadosSA2, {"A2_NOME",    cNome})
      aAdd(aDadosSA2, {"A2_CEP",     cCep})
      aAdd(aDadosSA2, {"A2_END",     cLogradour})   
      aAdd(aDadosSA2, {"A2_PAIS",  getPais(cCodPais)})
      aAdd(aDadosSA2, {"A2_PAISSUB", cSubdivPai})
      aAdd(aDadosSA2, {"A2_NREDUZ",  left(cNome,getSX3Cache("A2_NREDUZ","X3_TAMANHO"))})
      aAdd(aDadosSA2, {"A2_EST",  "EX"})
      aAdd(aDadosSA2, {"A2_TIPO",  "J"})
      aAdd(aDadosSA2, {"A2_MUN",     cNomeCid})
                     
      MsExecAuto({|x,y| MATA020(x,y)},aDadosSA2,3)

      if lMsErroAuto
         lRet := .f.
         aLogErro:= GetAutoGRLog()
         for nCont := 1 to len(aLogErro)
            cErroMsg += aLogErro[nCont] + chr(13)+chr(10)
         next nCont   
         gravaLog(oBrowProc,nSeq,ERRO, OPERADOR, getStatus(ERRO) + ENTER + cErroMsg, cCodPortal, cVersao)
      Else         
         gravaLog(oBrowProc,nSeq,PROCESSADO, OPERADOR, getStatus(PROCESSADO), cCodPortal, cVersao)
      EndIf                  
   EndIf   
EndIf   
Return lRet

/*/{Protheus.doc} setOpEstr
   Função para verificar se existe o operador estrangeiro e incluir se nao existir
   @type  Static Function
   @author user
   @since 21/07/2025
   @version version
   @param oBrowProc, objeto, objeto que será o browse da tela
          cCodPortal, caracter, código do portal
          cVersao, caracter, versão do operador estrangeiro
          nIncluiSA2, numérico, se deve incluir o SA2
          cForn, caracter, código do fornecedor
          cLoja, caracter, código da loja       
          cNome, caracter, nome do operador estrangeiro
          cCep, caracter, cep do operador estrangeiro
          cLogradour, caracter, logradouro do operador estrangeiro
          cNomeCid, caracter, nome da cidade do operador estrangeiro
          cSubdivPai, caracter, subdivisão pai do operador estrangeiro
          cCodPais, caracter, código do país do operador estrangeiro
   @return sem retorno
   @example
   (examples)
   @see (links_or_references)
/*/
static function setOpEstr(oBrowProc,nSeq,cCodPortal,cCodInt,cCpfCnpj,cForn,cloja,cVersao,cTin,cNome,cSituacao,cLogradour,cNomeCid,cSubdivPai,cCodPais,cCep,lValid)               
local oModelo := nil
local oModelEKJ := nil
local lRet := lValid
if lValid 
   cCpfCnpj :=  avkey(cCpfCnpj,'EKJ_CNPJ_R')
   cForn    :=  avkey(cForn,'EKJ_FORN')
   cLoja    :=  avkey(cLoja,'EKJ_FOLOJA')
   oModelo:= FwLoadModel("EICOE400")
   oModelo:SetOperation(MODEL_OPERATION_INSERT)
   oModelo:Activate()
   oModelEKJ:= oModelo:GetModel("EICOE400_EKJ")
   oModelEKJ:SetValue("EKJ_FILIAL", xFilial("EKJ"))
   oModelEKJ:SetValue("EKJ_CNPJ_R", cCpfCnpj)
   oModelEKJ:SetValue("EKJ_FORN", cForn)
   oModelEKJ:SetValue("EKJ_FOLOJA", cLoja)
   oModelEKJ:SetValue("EKJ_CODTIN", cTin) 
   oModelEKJ:SetValue("EKJ_NOME", cNome)
   oModelEKJ:SetValue("EKJ_LOGR", cLogradour)
   oModelEKJ:SetValue("EKJ_CIDA", cNomeCid)
   oModelEKJ:SetValue("EKJ_SUBP", cSubdivPai)
   oModelEKJ:SetValue("EKJ_PAIS", cCodPais)
   oModelEKJ:SetValue("EKJ_VERMAN", cVersao)
   oModelEKJ:SetValue("EKJ_STATUS", '1') //REGISTRADO
   lRet := oModelo:VldData()
   if lRet
      cMens := STR0047
      cStatus := PROCESSADO
      oModelo:CommitData()
   Else
      cMens := getErro(oModelo:GetErrorMessage())
      cStatus := ERRO   
   EndIf
   gravaLog(oBrowProc,nSeq,cStatus, FABFOR, cMens, cCodPortal, cVersao)            
   oModelo:DeActivate()
EndIf   
Return lRet


/*/{Protheus.doc} ValidOE
   Função para validar o operaodr estrangeiro
   @type  Static Function
   @author user
   @since 17/07/2025
   @version version
   @param oBrowProc, objeto, objeto que será o browse da tela
   @return .t. se o OP está válido e .f. se não está
   @example
   (examples)
   @see (links_or_references)
/*/

Static function ValidOE(oBrowProc,nSeq,cCodPortal,cVersao,cCpfCnpj,cForn,cLoja,cCodInt)
local lValid  := .F.

if ValidOpc(oBrowProc,1,nSeq,cCodPortal,cVersao,cCodInt) .and. ;
   ValidOpc(oBrowProc,2,nSeq,cCodPortal,cVersao,,,cForn,cLoja) .and. ;           
   ValidOpc(oBrowProc,3,nSeq,cCodPortal,cVersao,,,cForn,cLoja) .and. ;
   ValidOpc(oBrowProc,4,nSeq,cCodPortal,cVersao,,cCpfCnpj,cForn,cLoja) .and. ; 
   ValidOpc(oBrowProc,5,nSeq,cCodPortal,cVersao,,,cForn,cLoja)
   lValid := .t.
EndIf

Return lValid

/*/{Protheus.doc} ValidOpc
   Função para validar os vários cenários do operaodr estrangeiro
   @type  Static Function
   @author user
   @since 17/07/2025
   @version version
   @param oBrowProc, objeto, objeto que será o browse da tela
   @return .t. se o OP está válido e .f. se não está
   @example
   (examples)
   @see (links_or_references)
/*/

Function validOpc(oBrowProc,nOpc,nSeq,cCodPortal,cVersao,cCodInt,cCpfCnpj,cForn,cLoja)
local lRet := .T.
local nIncluiSA2 := MV_PAR01
local nTamFor := MV_PAR02       
local nTamLja := MV_PAR05
local cStatus := ERRO
Do case 
   Case nOpc == 1 
      if empty(cCodInt)
         lRet := .f.
         cMens := STR0055 // "A importação do Operador Estrangeiro foi bloqueada. O campo de código Interno está vazio. Por favor informe o código Interno do Fornecedor/ Loja no Portal único e tente novamente."
      EndIF   
   Case nOpc == 2
      if empty(cForn) .and. empty(cLoja)
         lRet := .f.
         cMens := STR0056 //"O campo código Interno não possui o separador de loja informado e não foi informado a loja padrão."
      EndIf           
   Case nOpc == 3 
      If len(cForn) > nTamFor
         lRet := .f.
         cMens := STR0057 + ENTER // "O campo código Interno possui o tamanho do campo fornecedor maior que o tamanho definido no pergunte" 
      EndIf
      If len(cLoja) > nTamLja
         lRet := .f.
         cMens += STR0058 // "O campo código Interno possui o tamanho do campo loja maior que o tamanho definido no pergunte"
      EndIf         
   Case nOpc == 4
      cCpfCnpj :=  avkey(cCpfCnpj,'EKJ_CNPJ_R')
      cForn    :=  avkey(cForn,'EKJ_FORN')
      cLoja    :=  avkey(cLoja,'EKJ_FOLOJA')
      if !Empty(Posicione("EKJ", 1, xFilial("EKJ") + cCpfCnpj + cForn + cLoja, "EKJ_FORN"))
         lRet := .f.
         cMens := StrTran(STR0059,'#####',AllTrim(cCpfCnpj))
         cMens := StrTran(cMens,'$$$$$',Alltrim(cForn))
         cMens := StrTran(cMens,'!!!!!',AllTrim(cLoja))
         cStatus := EXISTENTE
         //"O registro do Operador Estrangeiro Cnpj Raiz: ##### Fornecedor: $$$$$ Loja: !!!!! foi ignorado, pois já existe na base de dados."
      EndIf   
   Case nOpc == 5
      cForn    :=  avkey(cForn,'A2_COD')
      cLoja    :=  avkey(cLoja,'A2_LOJA')
      if nIncluiSA2 == 2 .And. Empty(Posicione("SA2", 1, xFilial("SA2") + cForn + cLoja, "A2_COD"))
         lRet := .f.      
         cMens := StrTran(STR0060,'#####',Alltrim(cForn))
         cMens := StrTran(cMens,'$$$$$',Alltrim(cLoja))
         //"A importação do Operador Estrangeiro Fornecedor: ##### Loja: $$$$$ foi bloqueada. O código Interno não existe no sistema. Por favor, revise as informações no SA2 - Cadastro de Fornecedores ou no Portal único."          
      Endif   
EndCase
if !lRet
   gravaLog(oBrowProc,nSeq,cStatus, OPERADOR, cMens, cCodPortal, cVersao)
EndIf   
Return lRet

/*/{Protheus.doc} GravaLog
   Função para gravar o log do resultado da importação de cada registro
   @type  Static Function
   @author user
   @since 17/07/2025
   @version version
   @param oBrowProc, objeto, objeto que será o browse da tela
          cStatus, caracter, status do processamento, PROCESSADO, EXISTENTE ou ERRO
          cOperacao, caracter, Operação realizada, FABFOR, OPERADOR ou CATALOGO
          cMens, caracter, mensagem do log
   @return sem retorno
   @example
   (examples)
   @see (links_or_references)
/*/

static function gravaLog(oBrowProc,nSeq,cStatus, cOperacao, cMens, cCodPortal, cVersao)
local cAliasTmp := CP404_TABLE
   reclock(cAliasTmp, .T.)
   (cAliasTmp)->SEQUENCIA := nSeq
   (cAliasTmp)->STATUS := cStatus
   (cAliasTmp)->OPERACAO := cOperacao
   (cAliasTmp)->EK9_IDPORT := cCodPortal
   (cAliasTmp)->EK9_VATUAL := cVersao
   (cAliasTmp)->RETORNO := cMens 
   (cAliasTmp)->(msUnLock())  
   oBrowProc:Refresh()
Return   

/*/{Protheus.doc} ExtFornLj
   Função para extrair o código do fornecedor e loja do campo código interno do arquivo do portal único
   @type  Static Function
   @author user
   @since 17/07/2025
   @version version
   @param cCodint, caracter, código interno do operador estrangeiro (fornecedor e loja)   
   @return sem retorno
   @example
   (examples)
   @see (links_or_references)
/*/

static function ExtFornLj(cCodint,cForn,cLoja)
local cSepLja := MV_PAR04
local nPosSep := at(cSepLja, cCodint)
local cLojaDef := MV_PAR06
default cCodint := ''
if nPosSep == 0 .and. empty(cLojaDef)
   cForn := ''
   cLoja := ''
ElseIf nPosSep == 0 .and. !empty(cLojaDef)
   cForn := cCodint
   cLoja := cLojaDef
Else  
  cForn := SubStr(cCodint, 1, nPosSep - 1)
  cLoja := SubStr(cCodint, nPosSep + 1, Len(cCodint) - nPosSep)    
EndIf  
Return 

/*/{Protheus.doc} getErro
   Função utilizada para tratar e formatar mensagens de erro durante o processo de importação do Catálogode produtos, retornando a mensagem apropriada para exibição ao usuário.

   @type    Static Function
   @author  Nícolas Castellani Brisque
   @since   02/06/2025
   @version version
   @param   xErro, Variant, Mensagem de erro recebida, podendo ser do tipo caractere ou array
   @return  cRet, String, Mensagem de erro tratada e formatada para exibição
   @example
   @see
*/
Static Function getErro(xErro)
Return trataErro(xErro)

/*/{Protheus.doc} getFile
   Função para abrir o arquivo json

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param cFile, caracter, caminho e nome do arquivo
   @return Retorna um array de jsons capturado do arquivo indicado no cFile
   @example
   (examples)
   @see (links_or_references)
/*/

Static Function getFile(cFile)
Local cText := ""
Local nHdl  := fopen(cFile,0)
Local nTamArq := 0
Local oJson    := JsonObject():New()
Local aJsonRet := {}
 
If nHDL >= 0
   //verifica o tamanho do arquivo
   nTamArq := FSeek(nHdl, 0, FS_END)
   //posiciona no inicio do arquivo
   FSeek(nHdl, 0)
   // Lê os bytes do arquivo
   FRead(nHdl,@cText,nTamArq)
   FClose(nHdl)
   cText:=decodeutf8(cText)
   cText := '{"items":'+cText+'}'
   oJson:FromJson(cText)
   aJsonRet := oJson:GetJsonObject("items")
EndIf
If Empty(aJsonRet)
   easyHelp(STR0061, STR0015, STR0062) // "não foi possível ler o arquivo informado." ### "Atenção" ### "Verifique se o arquivo informado é um arquivo json válido."
EndIf   
Return aJsonRet

Static function getPais(cPais)
   local cAliasQry  := ""
   local cQuery     := ""
   local oQuery     := nil
   local cRet := ""

   cAliasQry := getNextAlias()
   cQuery := " SELECT SYA.YA_CODGI FROM " + RetSqlName('SYA') + " SYA "
   cQuery += " WHERE SYA.YA_PAISDUE = ? AND SYA.D_E_L_E_T_  = ? "
   
   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString( 1, cPais )
   oQuery:SetString( 2, ' ' )

   cQuery := oQuery:GetFixQuery()
   MPSysOpenQuery(cQuery, cAliasQry)

   cRet := (cAliasQry)->YA_CODGI
   
   (cAliasQry)->(dbCloseArea())
   FwFreeObj(oQuery)
return cRet

/*/{Protheus.doc} getPerg
   Função para verificar se o pergunte existe

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param cPergunte, caracter, com o nome do pergunte a ser verificado
   @return Retorna true se encontrado e false se não existir
   @example
   (examples)
   @see (links_or_references)
/*/

static function getPerg(cPergunte)
local lRet := nil
   oFwSX1Util := FwSX1Util():New()
   oFwSX1Util:AddGroup(cPergunte)
   oFwSX1Util:SearchGroup()
   aPergunte := oFwSX1Util:GetGroup(cPergunte)
   lREt :=  (len(aPergunte) > 0 .and. len(aPergunte[2]) > 0)
   FwFreeArray(aPergunte)
   FwFreeObj(oFwSX1Util)
   aPergunte := nil
Return lRet   

/*/{Protheus.doc} getFabErro
   Função para verificar o erro na associaçaõ do fabricante no catálogo

   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param xErro, caracter, com o erro a ser verificado
   @param cForn, caracter, com o código do fornecedor 
   @param cLoja, caracter, com o código da loja
   @param cPais, caracter, com o código do país
   @param cPergunte, caracter, com o nome do pergunte a ser verificado
   @return Retorna uma string com o erro original indicando qual fornecedor, loja e país, ou retorna vazio se não houver erro
   @example
   (examples)
   @see (links_or_references)
/*/

static Function getFabErro(xErro, cForn, cLoja, cPais)
Local cErro := ""
cErro += if(empty(cForn),'', STR0083 + cForn) //'Fornecedor: '
cErro += if(empty(cLoja),'', STR0084 + cLoja) //' Loja: '
cErro += if(empty(cPais),'', STR0085 + cPais) //' País: '
cErro += xErro
REturn cErro
