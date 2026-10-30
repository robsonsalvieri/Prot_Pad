#include 'protheus.ch'
#include 'average.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "eiccp404.ch"
#INCLUDE "fileio.ch"

#define CP404_TABLE "CP404_EK9"
#define PROCESSADO "0" // Verde
#define EXISTENTE  "1" // Cinza
#define ERRO       "2" // Vermelho
#define FABFOR     STR0093 // 'Fabricante/Fornecedor'
#define OPERADOR   STR0089 // 'Operador Estrangeiro'
#define CATALOGO   STR0094 // 'Catálogo de Produtos'

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

function CP404ImpArq()
   local lIsBlind := isBlind()

   if !lIsBlind 
      if !getPerg('EICCP404')
         EasyHelp(STR0081,STR0015,STR0082) //'Dicionário de dados não está completo para executar esta ação. 'Faça a atualização da última expedição contínua com aplicação do dicionário de dados'
         return nil
      EndIF  
      WizardArq()
   endif

return nil

/*/{Protheus.doc} getPerg
   Função para verificar se o pergunte existe

   @type  static function
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
   lRet := (len(aPergunte) > 0 .and. len(aPergunte[2]) > 0)
   FwFreeArray(aPergunte)
   FwFreeObj(oFwSX1Util)
   aPergunte := nil

return lRet

/*/{Protheus.doc} WizardArq
   Criação da tela do Wizard para a importação do arquivo

   @type  static function
   @author user
   @since 26/03/2025
   @version version
   @param
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function WizardArq()
   local aCoords    := {}
   local oStepWiz   := nil
   local oStep1     := nil
   local oBrwProc   := nil
   local cAliasTmp  := CP404_TABLE
   local oJsonOpe   := nil
   local oJsonCat   := nil
   local oJsonVinc  := nil
   local aFiles     := {}
   local lFinalizou := .F.

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
   oStep2:SetNextAction( { || validStep2(@oJsonOpe, @oJsonCat, @oJsonVinc, @aFiles) })
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
   oStep4:SetConstruction({|oPanel| ViewProc(oPanel, @oBrwProc, @oJsonOpe, @oJsonCat, @oJsonVinc), if(oBrwProc <> nil, oBrwProc:oBrowse:Refresh(.T.), nil) })
   oStep4:SetNextTitle(STR0010) // "Fechar"
   oStep4:SetPrevTitle(STR0009) // "Exportar"
   oStep4:SetNextAction({|| lFinalizou := .T. })
   oStep4:SetPrevAction({|| geraExcel(oBrwProc) })
   oStep4:SetCancelWhen({|| .F. })

   oStepWiz:Activate()
   oStepWiz:Destroy()

   FwFreeObj( oStepWiz )

   eraseTable(oEasyTmp)

   FwFreeObj(oJsonOpe)
   FwFreeObj(oJsonCat)
   FwFreeObj(oJsonVinc)

   if lFinalizou
      TrocaExt(aFiles)
   endif

return nil

/*/{Protheus.doc} setTable
   Função para configurar a tabela temporaria para o Wizard

   @type  static function
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
   aAdd(aSemSX3, {"SEQ"        , "C"                                  , 12                                      , 0                                        })
   aAdd(aSemSX3, {"OPE"        , "C"                                  , 01                                      , 0                                        })
   aAdd(aSemSX3, {"STATUS"     , "C"                                  , 01                                      , 0                                        })
   aAdd(aSemSX3, {"OPERACAO"   , "C"                                  , 21                                      , 0                                        })
   aAdd(aSemSX3, {"IDPORT"     , getSX3Cache( "EK9_IDPORT", "X3_TIPO"), getSX3Cache( "EK9_IDPORT", "X3_TAMANHO"), getSX3Cache( "EK9_IDPORT", "X3_DECIMAL") })
   aAdd(aSemSX3, {"VERSAO"     , getSX3Cache( "EK9_VATUAL", "X3_TIPO"), getSX3Cache( "EK9_VATUAL", "X3_TAMANHO"), getSX3Cache( "EK9_VATUAL", "X3_DECIMAL") })
   aAdd(aSemSX3, {"RETORNO"    , "M"                                  , 250                                     , 0                                        })

   aIndex := {}
   aAdd(aIndex, "OPE+SEQ+STATUS" )
   aAdd(aIndex, "IDPORT+VERSAO" )
   aAdd(aIndex, "STATUS" )
   aAdd(aIndex, "OPERACAO" )
   aAdd(aIndex, "OPE+IDPORT+STATUS" )
   oEasyTmp:setData(nil, aSemSX3, cAliasTmp, aIndex)

return

/*/{Protheus.doc} eraseTable
   Função destruir o objeto da classe EasyTemporaryTable

   @type  static function
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

/*/{Protheus.doc} ViewIntrod
   Função para introdução do Wizard

   @type  static function
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
   local lProducao  := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   local cTxt       := if(lProducao, STR0026, STR0027) // "Produção" ### "Treinamento"

   aCoords := FWGetDialogSize(oPanel)      

   GetRemoteType(@cLib)
   cTxt := iif('HTML' $ cLib, "<b>" + cTxt + "</b>", cTxt)   
   cIntrod := StrTran(STR0002,'#####',cTxt) + ENTER + ENTER + STR0030 + ENTER + ENTER + STR0031 + ENTER + STR0032 + ENTER + ENTER + STR0033 + ENTER + STR0034 
   // STR0002 "Você está prestes a importar dados do ambiente de #####. Certifique-se de que foi efetuado o download dos arquivos corretamente do ambiente de ##### do Portal Único.
   // STR0030 "Esta ação não poderá ser revertida."
   // STR0031 "Durante o processo de importação, todos os dados contidos nos arquivos selecionados serão completamente integrados ao sistema."
   // STR0032 "Após a conclusão da importação, é importante destacar que quaisquer alterações ou atualizações nos registros importados deverão ser realizadas exclusivamente através das funcionalidades internas do sistema, garantindo assim a consistência e integridade das informações."
   // STR0033 "Vale ressaltar que futuras importações de arquivos não modificarão os registros já existentes; apenas novos registros serão adicionados."
   // STR0034 "Portanto, é essencial que a primeira importação seja feita com os dados mais atuais e precisos disponíveis."
   
   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return nil

/*/{Protheus.doc} ViewDirec
   Função para diretório dos json do Wizard

   @type  static function
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
   
   cIntrod := STR0063 // "Para realizar a importação dos catálogos, é necessário que o usuário tenha previamente baixado os três arquivos obrigatórios: Operador Estrangeiro, Catálogo de Produtos e Vínculo de Catálogo com Fabricante/ País. Certifique-se de que esses arquivos estejam descompactados e salvos com a extensão json em um mesmo diretório."
   
   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return nil

/*/{Protheus.doc} validStep2
   Função para validação do step 2 do Wizard

   @type  static function
   @author user
   @since 24/01/2025
   @version version
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function validStep2(oJsonOpe, oJsonCat, oJsonVinc, aFiles)
   local lRet      := .T.
   local cPath     := ""
   local aArqsOper := {}
   local aArqsCat  := {}
   local aArqsFab  := {}
   local cArqOpe   := ""
   local cArqCat   := ""
   local cArqFab   := ""
   local cErroOpe  := ""
   local cErroCat  := ""
   local cErroFab  := ""
   local cErroJson := ""
   local lProcOpe  := .F.
   local lProcCat  := .F.
   local lProcFab  := .F.

   cPath := selDir()
   if !empty(cPath)

      aArqsOper := Directory(cPath + "OPERADORES_ESTRANGEIROS_*.json") 
      aArqsCat  := Directory(cPath + "CATALOGO_PRODUTOS_*.json") 
      aArqsFab  := Directory(cPath + "FABRICANTE_PRODUTOR_*.json") 

      if len(aArqsOper) == 0 .or. len(aArqsCat) == 0 .or. len(aArqsFab) == 0
         easyHelp(STR0035, STR0015, STR0036) // "Para prosseguir com o processo de importação, é necessário que os três arquivos obrigatórios estejam armazenados em um único diretório." ### "Atenção" ### "Por favor, forneça o caminho do diretório onde os arquivos estão localizados. O sistema irá automaticamente verificar a presença de cada um dos arquivos e assegurará que não existam duplicatas, garantindo assim a precisão e eficiência no processo de importação"
         lRet := .F.
      endif

      if lRet .and. (len(aArqsOper) > 1 .or. len(aArqsCat) > 1 .or. len(aArqsFab) > 1)
         easyHelp(STR0039, STR0015, STR0040) // "Para prosseguir com o processo de importação, é necessário que apenas um arquivo de cada entidade esteja no diretório informado." ### "Atenção" ### "Por favor, forneça o caminho do diretório onde exista apenas os arquivos a serem processados."
         lRet := .F.
      endif

      if lRet

         FwFreeObj(oJsonOpe)
         FwFreeObj(oJsonCat)
         FwFreeObj(oJsonVinc)
         oJsonOpe := JsonObject():New()
         oJsonCat := JsonObject():New()
         oJsonVinc:= JsonObject():New()

         cArqOpe := cPath + aArqsOper[1][1]
         cArqCat := cPath + aArqsCat[1][1]
         cArqFab := cPath + aArqsFab[1][1]
         cErroOpe := oJsonOpe:FromJsonFile(cArqOpe)
         cErroCat := oJsonCat:FromJsonFile(cArqCat)
         cErroFab := oJsonVinc:FromJsonFile(cArqFab)

         if !empty(cErroOpe) .Or. !empty(cErroCat) .Or. !empty(cErroFab)
            cErroJson := if( !empty(cErroOpe), CHR(13) + STR0089 + ": " + cErroOpe + ". ", "") //"Operador Estrangeiro"
            cErroJson += if( !empty(cErroCat), CHR(13) + STR0005 + ":" + cErroCat + ". ", "")//"Catálogo de Produtos"
            cErroJson += if( !empty(cErroFab), CHR(13) + STR0090 + ": " + cErroFab + ". ", "") //"Fabricante Produtor"
            EasyHelp(STR0088 + CHR(13) + cErroJson, STR0015, STR0066) // "Houve um ou mais erros na importação do arquivo "### "Atenção" ### "Verifique se o arquivo foi importado corretamente do Portal único."
            lRet := .F.
         endif

         if lRet
            lProcOpe := isJsonVld(oJsonOpe, "ope", cArqOpe)
            lProcCat := isJsonVld(oJsonCat, "cat", cArqCat)
            lProcFab := isJsonVld(oJsonVinc, "fab", cArqFab)

            if !lProcCat .Or. !lProcFab .Or. !lProcOpe
               lRet := .F.
            endif
         endif

         if lRet
            aFiles := {}
            aAdd( aFiles, cArqOpe )
            aAdd( aFiles, cArqCat )
            aAdd( aFiles, cArqFab )
         endif

      endif

   else
      easyHelp(STR0037, STR0015, STR0038) //"Nenhum diretório selecionado." ### "Atenção" ### "Selecione um diretório onde os arquivos estáo localizados." 
      lRet := .F.

   endif

return lRet

/*/{Protheus.doc} selDir
   Função que retorna o diretorio que contem os 3 arquivos json

   @type  static function
   @author user
   @since 17/06/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function selDir()
   local cTitle     := STR0095 // "Selecione o diretório"
   local cMask      := ""
   local cDefPath   := GetTempPath()
   local nOptions   := GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY
   local cPath      := ""

   cPath := cGetFile(cMask, cTitle, , cDefPath, .T., nOptions, .F.)

return cPath

/*/{Protheus.doc} isJsonVld
   Função para validar se o Json possui os campos necessários para o processamento

   @type  static function
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
static function isJsonVld(oJson, cTipo, cArquivo)
   local aHeadOpe   := { "seq", "cpfCnpjRaiz", "codigo", "versao", "nome", "situacao", "logradouro", "nomeCidade", "codigoPais", "codigoInterno"}
   local aHeadCat   := { "seq", "codigo", "denominacao", "cpfCnpjRaiz", "situacao", "modalidade", "ncm", "versao"}
   local aHeadFab   := { "seq", "codigoPais", "cpfCnpjRaiz","conhecido", "codigoProduto"}
   local aHeaders   := {}
   local aProp      := {}
   local lRet       := .T.
   local i          := 0
   local cCpoFalt   := ""
   local cNomArq    := ""

   // Valida só o primeiro item
   if len(oJson) > 0
      aProp := oJson[1]:GetNames()
   endif

   Do Case
      Case cTipo == "ope"
         aHeaders := aHeadOpe
         cNomArq := "OPERADORES_ESTRANGEIROS"
      Case cTipo == "cat"
         aHeaders := aHeadCat
         cNomArq := "CATALOGO_PRODUTOS"
      Case cTipo == "fab"
         aHeaders := aHeadFab
         cNomArq := "FABRICANTE_PRODUTOR"
   End Case
   
   For i := 1 To Len(aHeaders)
      If aScan(aProp, {|x| x == aHeaders[i]}) == 0
         lRet := .F.
         cCpoFalt := aHeaders[i]
         Exit
      EndIf
   Next i
   
   // Se houver campo faltante, exibe mensagem detalhada
   if !lRet
      EasyHelp(STR0086 + "'" + cCpoFalt + "' (" + GetCampoDesc(cCpoFalt, cTipo)+ ") " + STR0087 + cNomArq, STR0015, STR0066) // "O campo " | "é obrigatório e está ausente no arquivo: " | Atenção | "Verifique se o arquivo foi importado corretamente do Portal único."
   endif

return lRet

/*/{Protheus.doc} GetCampoDesc
   Função para retornar a descrição amigável do campo do Portal Único
   
   @type  static function
   @author user
   @since 01/12/2025
   @version version
   @param cCampo, String, Nome do campo do Portal Único
   @param cTipo, String, Tipo de arquivo (ope, cat, fab)
   @return cDesc, String, Descrição amigável do campo
   @example
   GetCampoDesc("seq", "ope")
   @see (links_or_references)
/*/
static function GetCampoDesc(cCampo, cTipo)
   local cDesc      := ""
   local aCamposOpe := { {"seq", "Sequência do json"}, {"cpfCnpjRaiz", "CPF/CNPJ raiz da empresa responsável"}, {"codigo", "Código"}, {"versao", "Versão"}, {"nome", "Nome"}, {"situacao", "Situação"}, {"logradouro", "Logradouro"}, {"nomeCidade", "Cidade"}, {"codigoPais", "País do Operador Estrangeiro"}, {"codigoInterno", "Código interno"} }
   local aCamposCat := { {"seq", "Sequência do json"}, {"codigo", "Código do produto"}, {"denominacao", "Denominação do produto"}, {"cpfCnpjRaiz", "CPF/CNPJ raiz da empresa responsável"}, {"situacao", "Situação"}, {"modalidade", "Modalidade de operação"}, {"ncm", "NCM"}, {"versao", "Versão"} }
   local aCamposFab := { {"seq", "Sequência do json"}, {"codigoPais", "País do Operador Estrangeiro"}, {"cpfCnpjRaiz", "CPF/CNPJ raiz da empresa responsável"}, {"conhecido", "Conhecido"}, {"codigoProduto", "Código do produto"} }
   local nPos       := 0

   Do Case
      // Operador Estrangeiro
      Case cTipo == "ope"
         nPos := aScan(aCamposOpe, {|x| x[1] == cCampo})
         cDesc := IIF(nPos == 0, cCampo, aCamposOpe[nPos][2])
      
      // Catálogo de Produtos
      Case cTipo == "cat"
         nPos := aScan(aCamposCat, {|x| x[1] == cCampo})
         cDesc := IIF(nPos == 0, cCampo, aCamposCat[nPos][2])
      
      // Vinculação (Fabricante)
      Case cTipo == "fab"
         nPos := aScan(aCamposFab, {|x| x[1] == cCampo})
         cDesc := IIF(nPos == 0, cCampo, aCamposFab[nPos][2])

   End Case

return cDesc

/*/{Protheus.doc} ViewOper
   Função para definição de importação dos operadores estrangeiros do Wizard

   @type  static function
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
   // STR0045 "Nesta etapa, será necessário informar ao sistema os tamanhos dos campos código e loja que serão considerados durante o processamento. Essas informações serão utilizadas na leitura do Código Interno informado no Portal Único para o Operador Estrangeiro, a fim de verificar a existência desse registro no cadastro de Fornecedores (SA2) do ERP."
   // STR0046 "Lembrando que todo o processo será executado na filial corrente e caso a tabela de Fornecedores esteja configurada com a forma de acesso exclusiva, todas as verificações e inclusões ocorrerão na filial corrente."

   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return nil

/*/{Protheus.doc} validStep3
   Função para validação do step 3 do Wizard

   @type  static function
   @author user
   @since 24/01/2025
   @version version
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function validStep3()
   local lRet      := .T.
   local aPergunte := {}

   Pergunte('EICCP404',.F.,,,,,aPergunte)
   MV_PAR02 := InitPerg('A2_COD') // Tam. p/ o código do fornedor ?
   MV_PAR05 := InitPerg('A2_LOJA') // Tamanho de dígitos p/ Loja ?
   __SaveParam('EICCP404', aPergunte)
   lRet := Pergunte('EICCP404',.T.)
   if lRet .and. !EIC404VLD('LJDF') //este cenário trata quando o usuário não utiliza o conceito de loja e deixar o campo Loja Default em branco
      validStep3()
   endif

return lRet

/*/{Protheus.doc} InitPerg
   Função para inicialização padrão de campos do pergunte EICCP404

   @type  static function
   @author user
   @since 03/07/2025
   @version version
   @param cCampo, caracater, campo a ter valor padrão inicializado
   @return nRet, numérico, retorna o tamanho do campo ou o valor padrão
   @example
   (examples)
   @see (links_or_references)
/*/
static function InitPerg(cCampo)
   local nRet := getSX3Cache(cCampo, "X3_TAMANHO")

   do case
      case cCampo == "A2_COD"
         nRet := if(empty(MV_PAR02),nRet, MV_PAR02) // Tam. p/ o código do fornedor ?
      case cCampo == "A2_LOJA"      
         nRet := if(empty(MV_PAR05),nRet, MV_PAR05) // Tamanho de dígitos p/ Loja ?
   endcase

return nRet

/*/{Protheus.doc} EIC404VLD
   Função para validação dos campos do pergunte EICCP404

   @type  Function
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

   do case
      case cCampo == "A2_COD"
         lRet := VLD_Campo(cCampo, MV_PAR02) // Tam. p/ o código do fornedor ?
      case cCampo == "A2_LOJA"      
         lRet := VLD_Campo(cCampo, MV_PAR05) // Tamanho de dígitos p/ Loja ?
      case cCampo == "LJDF"   
         lRet := VLD_LJDF(MV_PAR03, MV_PAR06) // MV_PAR03 - Utiliza o conceito de Loja ? - MV_PAR06 - Loja default ?
   endcase

return lRet

/*/{Protheus.doc} VLD_Campo
   Função para validação dos campos A2_COD e A2_LOJA do pergunte EICCP404

   @type  static function
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
   local lRet := .T.
   local nTam := 0

   nTam := getSX3Cache(cCampo, "X3_TAMANHO")
   if nVal > nTam 
      cTxt1 := StrTran(STR0041, '#####', alltrim(str(nVal))) // "Tamanho selecionado ##### não pode ser maior que o tamanho máximo($$$$$) permitido pelo dicionário de dados. "
      cTxt1 := StrTran(cTxt1, '$$$$$', alltrim(str(nTam)))
      cTxt2 := StrTran(STR0042, '$$$$$', alltrim(str(nTam))) // "Informe um tamanho menor ou igual a $$$$$"
      easyHelp(cTxt1, STR0015, cTxt2) // "Atenção"
      lRet := .F.
   endif

return lRet

/*/{Protheus.doc} VLD_LJDF
   Função para validação do campo Loja default? do pergunte EICCP404

   @type  static function
   @author user
   @since 03/07/2025
   @version version
   @param nUsaLoja, numérico, indica se o conceito de loja é utilizado
          cLojaDefault, caracater, valor do campo Loja Default
   @return lRet, logico, .T. para continuar o processamento
   @example
   (examples)
   @see (links_or_references)
/*/
static function VLD_LJDF(nUsaLoja, cLojaDefault)
   local lRet := .T.

   if nUsaLoja == 2 .AND. empty(cLojaDefault)
      easyHelp(STR0043, STR0015, STR0044) // "A opção 'Utiliza o conceito de Loja' foi selecionada como não, então o campo Loja default deve ser informado." Atenção  "Informe o campo Loja Default."
      lRet := .F.
   endif

return lRet   

/*/{Protheus.doc} ViewProc
   Função para o resultado final do processamento

   @type  static function
   @author user
   @since 24/01/2025
   @version version
   @param 
   @return
   @example
   (examples)
   @see (links_or_references)
/*/
static function ViewProc(oPanel, oBrowProc, oJsonOpe, oJsonCat, oJsonVinc)
   local lRet       := .T.
   local oProc      := nil

   BrowseProc(oPanel, @oBrowProc)
   oProc := MsNewProcess():New({|lEnd| ProcImp(@lEnd, @oBrowProc, @oProc, @oJsonOpe, @oJsonCat, @oJsonVinc), oBrowProc:Refresh() }, STR0011 + "...",, .T.) // "Importando o arquivo"   
   oProc:Activate()

return lRet

/*/{Protheus.doc} BrowseProc
   Função para apresentação do browse de processamento dos catalogos de produtos para o Wizard

   @type  static function
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
         if !(aStruct[nCpo][1] == 'STATUS') .and. !(aStruct[nCpo][1] == 'SEQ') .and. !(aStruct[nCpo][1] == 'OPE')
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

/*/{Protheus.doc} setTitulo
   Função para gerar o títulos das colunas do browse
   
   @type  static function
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

   do case 
      case cCampo == "STATUS"
         cRet := STR0050 // "Status"   
      case cCampo == "OPERACAO"
         cRet := STR0051 // "Operação"
      case cCampo == "RETORNO"
         cRet := STR0023 // "Log da importação do arquivo"
      otherwise
         cRet := RetTitle(cCampo)
   endcase 
  
return cRet

/*/{Protheus.doc} ViewTitulo
   Função para apresentação do titulo das telas do Wizard

   @type  static function
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

   @type  static function
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
static function ProcImp(lEnd, oBrowProc, oProc, oJsonOpe, oJsonCat, oJsonVinc)
   local aJsonCat   := {}
   local aFabPais   := {}
   local aVincFab   := {}

   oProc:setRegua1(3)

   oProc:IncRegua1(STR0096 + "...") // "Processando operadores estrangeiros"
   ProcOE(oProc, oBrowProc, oJsonOpe, @aFabPais)

   oProc:IncRegua1(STR0097 + "...") // "Verificando vinculação dos operadores estrangeiros
   FiltrarOE(oProc, oBrowProc, oJsonVinc, oJsonCat, @aJsonCat, aFabPais, @aVincFab)

   oProc:IncRegua1(STR0098 + "...") // "Processando catálogo de produtos"
   ProcCat(oProc, oBrowProc, aJsonCat, aVincFab)

return nil

/*/{Protheus.doc} ProcOE
   Função para processar o arquivo de operadores estrangeiros

   @type  static function
   @author user
   @since 17/07/2025
   @version version
   @param 
   @return
   @example
   (examples)
   @see (links_or_references)
/*/
static function ProcOE(oProc, oBrowProc, jJsonOE, aFabPais)
   local nQtdTot    := 0
   local nOper      := 0
   local nSeq       := nil
   local cTin       := nil
   local cNome      := nil
   local cSituacao  := nil
   local cLogradour := nil
   local cNomeCid   := nil   
   local cSubdivPai := nil
   local cCodPais   := nil
   local cCep       := nil
   local cCodPortal := nil
   local cVersao    := nil
   local cCpfCnpj   := nil
   local cForn      := nil
   local cLoja      := nil
   local cCodInt    := nil
   local nIncluiSA2 := MV_PAR01 // Incluir cad. de Fornecedor ? 1 - Sim, 2 - Não
   local nTamFor    := MV_PAR02 // Tam. p/ o código do fornedor ?
   local nTamLja    := MV_PAR05 // Tamanho de dígitos p/ Loja ?
   local lSeekEKJ   := .F.

   if valType(jJsonOE) == "J" .and. (nQtdTot := len(jJsonOE)) > 0

      oProc:setRegua2(nQtdTot)

      EKJ->(DbSetOrder(1)) // EKJ_FILIAL+EKJ_CNPJ_R+EKJ_FORN+EKJ_FOLOJA
      SA2->(DbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
      for nOper := 1 to nQtdTot
        
         nSeq       := if(jJsonOE[nOper]["seq"] == nil, 0, jJsonOE[nOper]["seq"])
         cCpfCnpj   := if(jJsonOE[nOper]["cpfCnpjRaiz"] == nil, "", jJsonOE[nOper]["cpfCnpjRaiz"])
         cCodPortal := if(jJsonOE[nOper]["codigo"] == nil, "", jJsonOE[nOper]["codigo"])
         cVersao    := if(jJsonOE[nOper]["versao"] == nil, "", jJsonOE[nOper]["versao"])

         oProc:incRegua2( StrTran(StrTran(STR0105, "XXX", cCodPortal), "YYY", cVersao) ) // "Operador estrangeiro: 'XXX' - Versão - 'YYY'"

         cSituacao  := if(jJsonOE[nOper]["situacao"]== nil, "", jJsonOE[nOper]["situacao"])
         if cSituacao == "Ativado"

            cCodInt := if(jJsonOE[nOper]["codigoInterno"] == nil, "", jJsonOE[nOper]["codigoInterno"])
            if empty(cCodInt)
               gravaLog(oBrowProc, nSeq, ERRO, OPERADOR, cCodPortal, cVersao, STR0055) // "O campo de código Interno está vazio. Por favor informe o código Interno no Portal único que representa o Fornecedor/Loja e tente novamente."
               loop
            endif

            cForn := ""
            cLoja := ""
            ExtFornLj(cCodInt, @cForn, @cLoja)
            if empty(cForn) .and. empty(cLoja)
               gravaLog(oBrowProc, nSeq, ERRO, OPERADOR, cCodPortal, cVersao, STR0056) // "O campo código Interno não possui o separador de loja informado e não foi informado a loja padrão."
               loop
            endif

            if len(cForn) > nTamFor
               gravaLog(oBrowProc, nSeq, ERRO, OPERADOR, cCodPortal, cVersao, STR0057) // "O campo código Interno possui o tamanho do campo fornecedor maior que o tamanho definido no pergunte"
               loop
            endif

            if len(cLoja) > nTamLja
               gravaLog(oBrowProc, nSeq, ERRO, OPERADOR, cCodPortal, cVersao, STR0058) // "O campo código Interno possui o tamanho do campo loja maior que o tamanho definido no pergunte"
               loop
            endif

            cCpfCnpj := AvKey(cCpfCnpj,'EKJ_CNPJ_R')
            cForn := AvKey(cForn,'A2_COD')
            cLoja := AvKey(cLoja,'A2_LOJA')
            lSeekEKJ := EKJ->(dbSeek(xFilial("EKJ") + cCpfCnpj + cForn + cLoja))
            if lSeekEKJ .and. !empty(EKJ->EKJ_TIN)
               aAdd( aFabPais, { EKJ->EKJ_TIN, EKJ->EKJ_FORN, EKJ->EKJ_FOLOJA } )
               gravaLog(oBrowProc, nSeq, EXISTENTE, OPERADOR, cCodPortal, cVersao, StrTran(StrTran(StrTran(STR0059,'#####',AllTrim(cCpfCnpj)),'$$$$$',Alltrim(cForn)),'!!!!!',AllTrim(cLoja))) // "Operador estrangeiro já existente no sistema. CPF/CNPJ: ##### Fornecedor: $$$$$ Loja: !!!!!"
               loop
            endif

            cTin       := if(jJsonOE[nOper]["tin"] == nil, "", jJsonOE[nOper]["tin"])
            cNome      := if(jJsonOE[nOper]["nome"] == nil, "", decode(jJsonOE[nOper]["nome"]))
            cLogradour := if(jJsonOE[nOper]["logradouro"] == nil, "", decode(jJsonOE[nOper]["logradouro"]))
            cNomeCid   := if(jJsonOE[nOper]["nomeCidade"] == nil, "", jJsonOE[nOper]["nomeCidade"])
            cSubdivPai := if(jJsonOE[nOper]["codigoSubdivisaoPais"] == nil, "", jJsonOE[nOper]["codigoSubdivisaoPais"])
            cCodPais   := if(jJsonOE[nOper]["codigoPais"] == nil, "", jJsonOE[nOper]["codigoPais"])
            cCep       := if(jJsonOE[nOper]["cep"] == nil, "", jJsonOE[nOper]["cep"]) 

            if !lSeekEKJ .and. !SA2->(dbSeek(xFilial("SA2") + cForn + cLoja))
               if nIncluiSA2 == 2 // Não
                  gravaLog(oBrowProc, nSeq, ERRO, OPERADOR, cCodPortal, cVersao,  StrTran(StrTran(STR0060,'#####',Alltrim(cForn)),'$$$$$',Alltrim(cLoja)) ) // "A importação do Operador Estrangeiro (Fornecedor: ##### Loja: $$$$$) foi bloqueada. O Código Interno não existe no sistema. Por favor, revise as informações no SA2 - Cadastro de Fornecedores ou no Portal Único."
                  loop
               else
                  if !setSA2(oBrowProc, nSeq, cCodPortal, cVersao, cForn, cLoja, cNome, cCep, cLogradour, cCodPais, cSubdivPai, cNomeCid)
                     loop
                  endif
               endif
            endif

            if setOpEstr(oBrowProc, nSeq, cCodPortal, cCodInt, cCpfCnpj, cForn, cLoja, cVersao, cTin, cNome, cSituacao, cLogradour, cNomeCid, cSubdivPai, cCodPais, cCep, lSeekEKJ)
               aAdd( aFabPais, { AvKey(cCodPortal, "EKJ_TIN"), cForn, cLoja} )
            endif

         else
            gravaLog(oBrowProc, nSeq, ERRO, OPERADOR, cCodPortal, cVersao, STR0099) // "Operador Estrangeiro com situação desativado no arquivo json."
         endif

      next nOper

   endif

return nil

/*/{Protheus.doc} ExtFornLj
   Função para extrair o código do fornecedor e loja do campo código interno do arquivo do portal único

   @type  static function
   @author user
   @since 17/07/2025
   @version version
   @param cCodInt, caracter, código interno do operador estrangeiro (fornecedor e loja)   
   @return sem retorno
   @example
   (examples)
   @see (links_or_references)
/*/
static function ExtFornLj(cCodInt, cForn, cLoja)
   local nPosSep  := at(MV_PAR04, cCodInt) // Separador entre cód. e loja ? 
   local cLojaDef := MV_PAR06 // Loja default ?

   default cCodInt := ""

   if nPosSep == 0 .and. empty(cLojaDef)
      cForn := ""
      cLoja := ""
   elseif nPosSep == 0 .and. !empty(cLojaDef)
      cForn := cCodInt
      cLoja := cLojaDef
   else  
      cForn := SubStr(cCodInt, 1, nPosSep - 1)
      cLoja := SubStr(cCodInt, nPosSep + 1, Len(cCodInt) - nPosSep)
   endif

return nil

/*/{Protheus.doc} setSA2
   Função para verificar se não existe o fabricante/fornecedor e incluir se nao existir

   @type  static function
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
static function setSA2(oBrowProc, nSeq, cCodPortal, cVersao, cForn, cLoja, cNome, cCep, cLogradour, cCodPais, cSubdivPai, cNomeCid)
   local aDadosSA2 := {}
   local aLogErro  := {}
   local cErroMsg  := ""
   local nCont     := 0
   local lRet      := .T.

   private lMsErroAuto    := .F.
   private lAutoErrNoFile := .T.

   aDadosSA2 := {}
   aAdd(aDadosSA2, {"A2_COD"    , cForn})
   aAdd(aDadosSA2, {"A2_LOJA"   , cLoja})
   aAdd(aDadosSA2, {"A2_NOME"   , cNome})
   aAdd(aDadosSA2, {"A2_CEP"    , cCep})
   aAdd(aDadosSA2, {"A2_END"    , cLogradour})   
   aAdd(aDadosSA2, {"A2_PAIS"   , getPais(cCodPais)})
   aAdd(aDadosSA2, {"A2_PAISSUB", cSubdivPai})
   aAdd(aDadosSA2, {"A2_NREDUZ" , left(cNome,getSX3Cache("A2_NREDUZ","X3_TAMANHO"))})
   aAdd(aDadosSA2, {"A2_EST"    , "EX"})
   aAdd(aDadosSA2, {"A2_TIPO"   , "J"})
   aAdd(aDadosSA2, {"A2_MUN"    , cNomeCid})

   MsExecAuto({|x,y| MATA020(x,y)}, aDadosSA2, 3)

   if lMsErroAuto
      lRet := .F.
      aLogErro:= GetAutoGRLog()
      for nCont := 1 to len(aLogErro)
         cErroMsg += aLogErro[nCont] + chr(13) + chr(10)
      next nCont
      gravaLog(oBrowProc, nSeq, ERRO, FABFOR, cCodPortal, cVersao, STR0100 + " - " + cErroMsg) // "Falha na inclusão do Fornecedor (SA2)"
   else
      gravaLog(oBrowProc, nSeq, PROCESSADO, FABFOR, cCodPortal, cVersao, getStatus(PROCESSADO))
   endif

return lRet

/*/{Protheus.doc} getPais
   Função para retornar o país YA_CODGI de acordo com o país YA_PAISDUE

   @type    static function
   @author  Nícolas Castellani Brisque
   @since   02/06/2025
   @version version
   @param   xErro, Variant, Mensagem de erro recebida, podendo ser do tipo caractere ou array
   @return  cRet, String, Mensagem de erro tratada e formatada para exibição
   @example
   @see
*/
static function getPais(cPais)
   local cAliasQry  := ""
   local cQuery     := ""
   local oQuery     := nil
   local cRet       := ""

   cAliasQry := getNextAlias()
   cQuery := " SELECT SYA.YA_CODGI FROM " + RetSqlName('SYA') + " SYA "
   cQuery += " WHERE SYA.YA_FILIAL = ? AND SYA.YA_PAISDUE = ? AND SYA.D_E_L_E_T_  = ? "
   
   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString( 1, xFilial("SYA") )
   oQuery:SetString( 2, cPais )
   oQuery:SetString( 3, ' ' )

   cQuery := oQuery:GetFixQuery()
   MPSysOpenQuery(cQuery, cAliasQry)

   cRet := (cAliasQry)->YA_CODGI

   (cAliasQry)->(dbCloseArea())
   FwFreeObj(oQuery)

return cRet

/*/{Protheus.doc} setOpEstr
   Função para verificar se existe o operador estrangeiro e incluir se nao existir

   @type  static function
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
static function setOpEstr(oBrowProc, nSeq, cCodPortal, cCodInt, cCpfCnpj, cForn, cLoja, cVersao, cTin, cNome, cSituacao, cLogradour, cNomeCid, cSubdivPai, cCodPais, cCep, lSeekEKJ)
   local oModelo   := nil
   local oModelEKJ := nil
   local lRet      := .T.
   local cMens     := ""
   local cStatus   := ""

   if !lSeekEKJ .or. empty(EKJ->EKJ_TIN)

      oModelo:= FwLoadModel("EICOE400")
      if !lSeekEKJ
         oModelo:SetOperation(MODEL_OPERATION_INSERT)
      elseif empty(EKJ->EKJ_TIN)
         oModelo:SetOperation(MODEL_OPERATION_UPDATE)
      endif
      lRet := oModelo:Activate()

      if lRet
         oModelEKJ := oModelo:GetModel("EICOE400_EKJ")
         if !lSeekEKJ
            lRet := oModelEKJ:SetValue("EKJ_FILIAL", xFilial("EKJ"))
            lRet := lRet .and. oModelEKJ:SetValue("EKJ_CNPJ_R", cCpfCnpj)
            lRet := lRet .and. oModelEKJ:SetValue("EKJ_FORN", cForn)
            lRet := lRet .and. oModelEKJ:SetValue("EKJ_FOLOJA", cLoja)
         endif
         lRet := lRet .and. oModelEKJ:SetValue("EKJ_CODTIN", cTin) 
         lRet := lRet .and. oModelEKJ:SetValue("EKJ_NOME", cNome)
         lRet := lRet .and. oModelEKJ:SetValue("EKJ_LOGR", cLogradour)
         lRet := lRet .and. oModelEKJ:SetValue("EKJ_CIDA", cNomeCid)
         lRet := lRet .and. oModelEKJ:SetValue("EKJ_SUBP", cSubdivPai)
         lRet := lRet .and. oModelEKJ:SetValue("EKJ_PAIS", cCodPais)
         oModelEKJ:LoadValue("EKJ_TIN", cCodPortal)
         oModelEKJ:LoadValue("EKJ_VERSAO", cVersao)
         oModelEKJ:LoadValue("EKJ_STATUS", '1') //REGISTRADO
         lRet := lRet .and. oModelo:VldData()
         lRet := lRet .and. oModelo:CommitData()
      endif

      if lRet
         cMens := STR0047 // "Processado com sucesso"
         cStatus := PROCESSADO
      Else
         cMens := getError(oModelo:GetErrorMessage())
         cStatus := ERRO
      EndIf

      gravaLog(oBrowProc, nSeq, cStatus, OPERADOR, cCodPortal, cVersao, cMens)

      oModelo:DeActivate()

   endif

return lRet

/*/{Protheus.doc} FiltrarOE
   Realiza o filtro retirando os catalogos de produtos que possuem operadores estrangeiros que ocorreram falha de processamento

   @type  Static Function
   @author user
   @since 18/06/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function FiltrarOE(oProc, oBrowProc, oJsonVinc, oJsonCat, aJsonCat, aFabPais, aVincFab)
   local cAliasTmp  := CP404_TABLE
   local aAreaTmp   := {}
   local nTamIdPort := 0
   local nJsonFab   := 0
   local nQtdTot    := 0
   local nCat       := 0
   local cCodOper   := ""
   local cPaisOrig  := ""
   local lError     := .F.
   local nCodCat    := 0
   local nPosCat    := 0
   local nSeq       := 0
   local cVerCat    := ""
   local nPosOper   := 0

   aAreaTmp := (cAliasTmp)->(getArea())
   (cAliasTmp)->(dbSetOrder(5)) // OPE+IDPORT+STATUS
   nTamIdPort := len((cAliasTmp)->IDPORT)

   nQtdTot := len(oJsonVinc)
   oProc:setRegua2(nQtdTot)

   // devido ao scan não conseguir procurar diretamente no objeto json
   for nCat := 1 to len(oJsonCat)
      aAdd(aJsonCat, oJsonCat[nCat])
   next

   EKJ->(DbSetOrder(2)) // EKJ_FILIAL+EKJ_CNPJ_R+EKJ_FORN+EKJ_FOLOJA
   for nJsonFab := 1 to nQtdTot

      lError := .F.
      nCodCat := oJsonVinc[nJsonFab]["codigoProduto"]
      cPaisOrig := ""
      if !oJsonVinc[nJsonFab]:HasProperty("vincular") .or. oJsonVinc[nJsonFab]["vincular"]
         if oJsonVinc[nJsonFab]["conhecido"]
            if oJsonVinc[nJsonFab]:HasProperty("codigoOperadorEstrangeiro")
               cCodOper := oJsonVinc[nJsonFab]["codigoOperadorEstrangeiro"]
               if !empty(cCodOper)
                  oProc:incRegua2( StrTran(StrTran(STR0101, "XXX", cCodOper), "YYY", alltrim(str(nCodCat))) ) // "Vinculação do operador 'XXX' ao catálogo de produto 'YYY'."
                  
                  // Verificar se foi logado erro para o operador vinculado 
                  lError := (cAliasTmp)->(dbSeek("1" + PadR(cCodOper, nTamIdPort) + ERRO))

                  // mesmo que adicione um operador estrangeiro que não deu problema no processamento
                  // na leitura dos catalogos, não estará presente para processamento
                  if !lError
                     nPosOper := aScan( aFabPais, { |X| alltrim(X[1]) == alltrim(cCodOper) } )
                     if nPosOper > 0
                        oJsonVinc[nJsonFab]["codigo_SA2"] := aFabPais[nPosOper][2]
                        oJsonVinc[nJsonFab]["loja_SA2"] := aFabPais[nPosOper][3]
                        aAdd( aVincFab, oJsonVinc[nJsonFab] )
                     endif
                  endif
               endif
            endif
         else
            cPaisOrig := oJsonVinc[nJsonFab]["codigoPais"]
            oProc:incRegua2( StrTran(StrTran(STR0102, "XXX", cPaisOrig), "YYY", alltrim(str(nCodCat))) ) // "Vinculação do País de Origem 'XXX' ao catálogo de produto 'YYY'."
            oJsonVinc[nJsonFab]["codigo_SA2"] := ""
            oJsonVinc[nJsonFab]["loja_SA2"] := ""
            aAdd( aVincFab, oJsonVinc[nJsonFab] )
         endif
      endif

      if lError
         nPosCat := aScan(aJsonCat, { |X| X["codigo"] == nCodCat } )
         if nPosCat > 0
            nSeq := aJsonCat[nPosCat]['seq']
            cVerCat := aJsonCat[nPosCat]['versao']
            aDel(aJsonCat, nPosCat)
            aSize(aJsonCat, len(aJsonCat) - 1)
            gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, alltrim(str(nCodCat)), cVerCat, StrTran(STR0103, "XXX", cCodOper) ) // "O catálogo de produto com operador estrangeiro 'XXX' com falha de processamento. Verifique o log de operadores estrangeiros para mais detalhes."
         endif
      endif

   next nJsonFab

   restArea(aAreaTmp)

return nil

/*/{Protheus.doc} ProcCat
   Realiza o processamento do catalogo de produtos

   @type  Static Function
   @author user
   @since 18/06/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function ProcCat(oProc, oBrowProc, aJsonCat, aVincFab)
   local nQtdTot    := 0
   local oModelo    := nil
   local nCatalogo  := 0
   local cCodPortal := ""
   local cVersao    := ""
   local cModalid   := ""
   local nSeq       := 0
   local cCnpjRaiz  := ""
   local cLogCat    := ""
   local lOk        := .F.
   local oModelEK9  := nil
   local cCatalogo  := ""
   local nCodCat    := 0
   local cNCM       := ""
   local cPicNCM    := AvSX3("YD_TEC", AV_PICTURE)
   local cLogAtt    := ""
   local cLogProd   := ""
   local cLogVinc   := ""

   nQtdTot := Len(aJsonCat)
   oProc:setRegua2(nQtdTot)

   if nQtdTot > 0

      // Inicialização do modelo de dados e demais tabelas
      EK9->(DbsetOrder(1)) // EK9_FILIAL+EK9_COD_I+EK9_VATUAL
      EKA->(DbsetOrder(1)) // EKA_FILIAL+EKA_COD_I+EKA_PRDREF+EKA_ITEM
      EKB->(DbsetOrder(1)) // EKB_FILIAL+EKB_COD_I+EKB_CODFAB+EKB_LOJA
      EKC->(DbsetOrder(1)) // EKC_FILIAL+EKC_COD_I+EKC_CODATR+EKC_CONDTE
      EKG->(DbsetOrder(1)) // EKG_FILIAL+EKG_NCM+EKG_COD_I+EKG_CONDTE
      // SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

      oModelo := FwLoadModel("EICCP400")

   endif

   // Processamento do arquivo CATALOGO_PRODUTOS
   for nCatalogo := 1 to nQtdTot

      nCodCat := aJsonCat[nCatalogo]['codigo']
      cCodPortal := alltrim(str(nCodCat)) 
      cVersao := aJsonCat[nCatalogo]['versao']
      oProc:incRegua2( StrTran(StrTran(STR0104, "XXX", cCodPortal), "YYY", cVersao) ) // "Catálogo de produtos: 'XXX' - Versão - 'YYY'"

      cModalid := alltrim(upper(aJsonCat[nCatalogo]['modalidade']))
      nSeq := aJsonCat[nCatalogo]['seq']
      if cModalid == "EXPORTACAO"
         gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, cCodPortal, cVersao, STR0092) // "Catálogo de produto com modalidade de exportação."
         loop
      endif

      // Ignora os registros desativados ou rascunhos provenientes do Portal único
      if !(aJsonCat[nCatalogo]['situacao'] == "Ativado")
         gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, cCodPortal, cVersao, STR0064) // "Registro com status diferente de 'Ativado' não será processado."
         loop
      endif

      cCnpjRaiz := AvKey(aJsonCat[nCatalogo]['cpfCnpjRaiz'],'EKJ_CNPJ_R')
      cLogCat := ""
      if !CP400VLDID(cCnpjRaiz, cCodPortal, 3, @cLogCat)
         gravaLog(oBrowProc, nSeq, EXISTENTE, CATALOGO, cCodPortal, cVersao, cLogCat) // "O catálogo de produto já está registrado no sistema."
         loop
      endif

      // Processamento do modelo de dados
      oModelo:SetOperation(MODEL_OPERATION_INSERT)
      lOk := oModelo:Activate()
      if lOk

         oModelEK9 := oModelo:getModel("EK9MASTER")
         cCatalogo := oModelEK9:GetValue("EK9_COD_I")
         cNCM := aJsonCat[nCatalogo]['ncm']
         lOk := oModelEK9:SetValue("EK9_CNPJ", cCnpjRaiz)
         lOk := lOk .and. oModelEK9:SetValue("EK9_DESC_I", AvKey(decode(aJsonCat[nCatalogo]['denominacao']),'EK9_DESC_I'))
         lOk := lOk .and. oModelEK9:SetValue("EK9_NCM", cNCM)
         lOk := lOk .and. oModelEK9:SetValue("EK9_IDMANU", cCodPortal)
         lOk := lOk .and. oModelEK9:SetValue("EK9_VSMANU", cVersao)

         if aJsonCat[nCatalogo]:hasProperty('descricao')
            lOk := lOk .and. oModelEK9:SetValue("EK9_DSCCOM", aJsonCat[nCatalogo]['descricao'])
         endif

         if !lOk
            gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, cCodPortal, cVersao, STR0068 + getError(oModelo:GetErrorMessage())) // "Erro ao preencher campos obrigatórios: "
            oModelo:DeActivate()
            Loop
         endif

         // Processamento do modelo de dados EKC
         cLogAtt := ProcEKC(oModelo, cCatalogo, cNCM, aJsonCat[nCatalogo])
         if !Empty(cLogAtt)
            // STR0070 "Existem atributos não cadastrados no sistema."
            // STR0071 "Efetue a integração dos atributos para a NCM "
            gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, cCodPortal, cVersao, STR0070 + ENTER + STR0071 + Transform(cNCM, cPicNCM) + ". " + ENTER + cLogAtt)
            oModelo:DeActivate()
            Loop
         endif

         // Processamento do modelo de dados EKA
         cLogProd := ProcEKA(oModelo, cNCM, cPicNCM, aJsonCat[nCatalogo])
         if !Empty(cLogProd)
            gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, cCodPortal, cVersao, STR0106 + cLogProd) // "Erro na importação do produto: "
            oModelo:DeActivate()
            Loop
         endif

         // Processamento do modelo de dados EKB
         cLogVinc := ProcEKB(oModelo, nCodCat, aJsonCat[nCatalogo], aVincFab)
         if !Empty(cLogVinc)
            gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, cCodPortal, cVersao, STR0107 + cLogVinc) // "Erro na importação do vínculo do Fabricante/País de origem: "
            oModelo:DeActivate()
            Loop
         endif

         lOk := oModelo:VldData()
         lOk := lOk .and. oModelo:CommitData()

         if lOk
            gravaLog(oBrowProc, nSeq, PROCESSADO, CATALOGO, cCodPortal, cVersao, STR0072 ) // "Registro processado com sucesso."
         else
            gravaLog(oBrowProc, nSeq, ERRO, CATALOGO, cCodPortal, cVersao, STR0049 + ENTER + getError(oModelo:GetErrorMessage()) ) // "Falha na importação"
         endif

         oBrowProc:Refresh()
         oModelo:DeActivate()

      endif

   next nCatalogo

return nil

/*/{Protheus.doc} ProcEKC
   Função para processar a importação dos atributos do catalogo

   @type  static function
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

static function ProcEKC(oModelo, cCatalogo, cNcm, aJsonCat)
   local oModelEKC  := nil
   local nAtrib     := 0
   local nComposto  := 0
   local cLogAtt    := ""

   oModelEKC := oModelo:getModel("EKCDETAIL")

   oModelEKC:SetNoInsertLine(.F.) // Habilita a inserção de linhas no modelo EKC
   If aJsonCat:hasProperty('atributos') .And. Len(aJsonCat["atributos"]) > 0
      For nAtrib := 1 to Len(aJsonCat["atributos"])
         If aJsonCat["atributos"][nAtrib]:hasProperty('atributo')
            LoadAtrEKC(oModelEKC, cCatalogo, cNcm, aJsonCat["atributos"][nAtrib]['atributo'], , aJsonCat["atributos"][nAtrib]['valor'], @cLogAtt )
         EndIf
      Next nAtrib
   EndIf

   If aJsonCat:hasProperty('atributosMultivalorados') .And. Len(aJsonCat["atributosMultivalorados"]) > 0
      For nAtrib := 1 to Len(aJsonCat["atributosMultivalorados"])
         If aJsonCat["atributosMultivalorados"][nAtrib]:hasProperty('atributo')
            LoadAtrEKC(oModelEKC, cCatalogo, cNcm, aJsonCat["atributosMultivalorados"][nAtrib]['atributo'], , ArrTokStr(aJsonCat["atributosMultivalorados"][nAtrib]['valores'], ";"),  @cLogAtt )
         EndIf
      Next nAtrib
   EndIf

   If aJsonCat:hasProperty('atributosCompostos') .And. Len(aJsonCat["atributosCompostos"]) > 0
      For nAtrib := 1 to Len(aJsonCat["atributosCompostos"])
         For nComposto := 1 to Len(aJsonCat["atributosCompostos"][nAtrib]['valores'])
            If aJsonCat["atributosCompostos"][nAtrib]['valores'][nComposto]:hasProperty('atributo')
               LoadAtrEKC(oModelEKC, cCatalogo, cNcm, aJsonCat["atributosCompostos"][nAtrib]['valores'][nComposto]['atributo'], aJsonCat["atributosCompostos"][nAtrib]['atributo'], aJsonCat["atributosCompostos"][nAtrib]['valores'][nComposto]['valor'],  @cLogAtt )
            EndIf
         Next nComposto
      Next nAtrib
   EndIf

   /*
   If aJsonCat:hasProperty('atributosCompostosMultivalorados') .And. Len(aJsonCat["atributosCompostosMultivalorados"]) > 0
      // Comentado pois sem exemplo de implementação
      // For nAtrib := 1 to Len(aJsonCat["atributosCompostosMultivalorados"])
      // Next nAtrib
   EndIf  
   */

return cLogAtt

/*/{Protheus.doc} LoadAtrEKC
   Carrega o modelo de dados EKC

   @type  static function
   @author user
   @since 19/01/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function LoadAtrEKC(oModelEKC, cCatalogo, cNcm, cAtributo, cAtrbCont, cValor, cLogAtt)
   local lSeekEKC   := .F.
   local lSeekEKG   := .F.
   local lBloqueado := .F.

   default cAtrbCont  := ""
   default cLogAtt    := ""

   if empty(cAtrbCont)
      lSeekEKC := oModelEKC:SeekLine({{"EKC_COD_I", cCatalogo} , {"EKC_CODATR", cAtributo}})
   else
      lSeekEKC := oModelEKC:SeekLine({{"EKC_COD_I", cCatalogo} , {"EKC_CODATR", cAtributo}, {"EKC_CONDTE", cAtrbCont} })
   endif

   lSeekEKG := EKG->(dbseek( xFilial("EKG") + AvKey(cNcm, "EKG_NCM") + AvKey(cAtributo, "EKG_COD_I") ))
   if lSeekEKG
      lBloqueado := EKG->EKG_MSBLQL == "1"
      if !lBloqueado .and. alltrim(EKG->EKG_FORMA) == "BOOLEANO"
         if upper(cValor) == "TRUE"
            cValor := "1"
         else
            cValor := "2"
         endif
      endif
   endif

   if lSeekEKC
      oModelEKC:SetValue("EKC_VALOR", cValor)
   else
      if lSeekEKG .and. !lBloqueado
         oModelEKC:AddLine()
         oModelEKC:LoadValue("EKC_CODATR", cAtributo)
         oModelEKC:LoadValue("EKC_CONDTE", EKG->EKG_CONDTE)
         oModelEKC:SetValue("EKC_VALOR", cValor)
      else
         cLogAtt := cLogAtt + if( !lBloqueado, STR0069, STR0091) + cAtributo + ENTER //"Atributo não encontrado: " ### "Atributo bloqueado: "  
      endif
   endif

return nil

/*/{Protheus.doc} ProcEKA
   Função para processar a vinculação dos produtos

   @type  static function
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
static function ProcEKA(oModelo, cNcm, cPicNCM, aJsonCat)
   local oModelEKA  := nil
   local aProdutos  := {}
   local nProd      := 0
   local cCodProd   := ""
   local cItem      := ""
   local nTamItem   := getSX3Cache("EKA_ITEM","X3_TAMANHO")
   local cErro      := ""
   local lOk        := .F.

   oModelEKA := oModelo:getModel("EKADETAIL")
   oModelEKA:SetNoInsertLine(.F.) // Habilita a inserção de linhas no modelo EKA
   aProdutos := if( aJsonCat['codigosInterno'] == nil, {}, aJsonCat['codigosInterno']) 

   for nProd := 1 to len(aProdutos)

      cCodProd := AvKey(aProdutos[nProd],'EKA_PRDREF')

      // Validação já são executadas pelo valid do campo EKA_PRDREF, porém caso seja um unico produto a NCM é alterada
      if !SB1->(dbSeek(xFilial("SB1") + AvKey(aProdutos[nProd],'B1_COD')))
         cErro := cErro + STR0076 + alltrim(aProdutos[nProd]) + ENTER + ENTER //"O Produto não foi vinculado ao Catálogo de Produtos, pois não foi encontrado no sistema."
         loop
      endif

      if !(alltrim(cNcm) == alltrim(SB1->B1_POSIPI))
         cErro := cErro + STR0077 + alltrim(aProdutos[nProd]) + STR0078 + ENTER // "O produto " ### " não foi vinculado ao Catálogo de Produtos: "
         cErro += STR0079 + Transform(alltrim(SB1->B1_POSIPI), cPicNCM) + ENTER // "Ncm do Produto: "
         cErro += STR0080 + Transform(alltrim(cNcm), cPicNCM) + ENTER  + ENTER // "Ncm do Catálogo: "
         loop
      endif
      
      cItem := strZero(nProd, nTamItem)
      if !oModelEKA:SeekLine({{"EKA_PRDREF", cCodProd}})

         if !(oModelEKA:Length() == 1 .And. empty(oModelEKA:GetValue("EKA_PRDREF"))) 
            oModelEKA:AddLine()
         endif
         lOk := oModelEKA:setValue("EKA_PRDREF", cCodProd)
         lOk := lOk .and. oModelEKA:setValue("EKA_ITEM", cItem)
         if( !lOk, cErro := cErro + getError(oModelo:GetErrorMessage())+ ENTER  + ENTER, nil )

      endif

   next nProd

return cErro

/*/{Protheus.doc} ProcEKB
   Função para processar a vinculação dos fabricantes / Pais de origem

   @type  static function
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
static function ProcEKB(oModelo, nCodCat, aJsonCat, aVincFab)
   local oModelEKB  := nil
   local nFab       := 0
   local lOk        := .F.
   local aFabJson   := {}
   local cCodFab    := ""
   local cLojaFab   := ""
   local cPaisOrig  := ""
   local cCodOper   := ""
   local lSeekEKB   := .F.
   local cErro      := ""

   oModelEKB := oModelo:getModel("EKBDETAIL")
   oModelEKB:SetNoInsertLine(.F.) // Habilita a inserção de linhas no modelo EKB

   aFabJson := getFabPais(nCodCat, aVincFab)
   for nFab := 1 to len(aFabJson)

      cCodFab := aFabJson[nFab][1]
      cLojaFab := aFabJson[nFab][2]
      cPaisOrig := aFabJson[nFab][3]
      cCodOper := aFabJson[nFab][4]

      cCodFab := AvKey(cCodFab,'EKB_CODFAB')
      cLojaFab := AvKey(cLojaFab,'EKB_LOJA')
      cPaisOrig := AvKey(cPaisOrig,'EKB_PAIS')

      if !empty(cCodFab)
         cCodFab := AvKey(cCodFab,'EKB_CODFAB')
         lSeekEKB := oModelEKB:SeekLine( {{"EKB_CODFAB", cCodFab},{"EKB_LOJA", cLojaFab}} )
      elseif !empty(cPaisOrig)
         cCodFab := AvKey("",'EKB_CODFAB')
         lSeekEKB := oModelEKB:SeekLine( {{"EKB_CODFAB", cCodFab},{"EKB_PAIS", cPaisOrig}} )
      endif

      if !lSeekEKB
         if !(oModelEKB:Length() == 1 .And. Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. Empty(oModelEKB:GetValue("EKB_PAIS")))
            oModelEKB:AddLine()
         endif

         ///obs: Não trocar a ordem e nem o tipo de load, set load abaixo
         //Carregar o fabricante sem validaçaõ para validar na loja
         //Carregar a loja com validação para validar o fabricante            
         //Carregar o país sem validação, senão breca no when
         if !empty(cCodFab)
            oModelEKB:loadValue("EKB_CODFAB", cCodFab)
            lOk := oModelEKB:setValue("EKB_LOJA", cLojaFab)
         elseif !empty(cPaisOrig)
            lOk := oModelEKB:setValue("EKB_PAIS", cPaisOrig)
         endif

         if !lOk
            cErro := "- Fabricante/Loja: " + cCodFab + " / " + cLojaFab + " - Operador: " + cCodOper
            if !empty(cPaisOrig)
               cErro := "- Código do País: " + cPaisOrig
            endif
            cErro += ENTER + getError(oModelo:GetErrorMessage())
            exit
         endif
      endif

   next nFab

return cErro

/*/{Protheus.doc} getFabPais
   Função para gerar um array com os códigos do catálogo dentro do json do fabricante

   @type  static function
   @author Maurício Frison
   @since 25/07/2025
   @version version
   @param oJsonVinc, json, json dos fabricantes
   @return aFab, array, array com os códigos dos fabricantes
   @description
   @example
   @see (links_or_references)
/*/
static function getFabPais(nCodCat, aVincFab)
   local aFab     := {}
   local nPosFab  := 0
   local cCodOp   := ""
   local cPais    := ""
   local cForn    := ""
   local cLoja    := ""

   nPosFab := aScan(aVincFab, {|X| X['codigoProduto'] == nCodCat})
   do While nPosFab > 0 

      cCodOp  := aVincFab[nPosFab]['codigoOperadorEstrangeiro']
      if !aVincFab[nPosFab]['conhecido'] .and. !empty(cPais := aVincFab[nPosFab]['codigoPais'])
         aAdd(aFab, { "", "", cPais, "" })
      elseif aVincFab[nPosFab]['conhecido'] .and. aVincFab[nPosFab]:hasProperty('codigo_SA2') .and. aVincFab[nPosFab]:hasProperty('loja_SA2') .and.;
         !empty(cForn := aVincFab[nPosFab]['codigo_SA2']) .and. !empty(cLoja := aVincFab[nPosFab]['loja_SA2'])
         aAdd(aFab, { cForn, cLoja, "", cCodOp })
      endif

      nPosFab := aScan(aVincFab, {|X| X['codigoProduto'] == nCodCat}, nPosFab + 1)
   enddo

return aFab

/*/{Protheus.doc} geraExcel
   Função para geração do resultado do processamento em Excel

   @type  static function
   @author user
   @since 24/01/2025
   @version version
   @param 
   @return lRet, logico, .F. para não fechar o wizard
   @example
   (examples)
   @see (links_or_references)
/*/
static function geraExcel(oBrwProc)
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
   local aArea      := (cAliasTmp)->(getArea())

   cWorksheet := STR0025 // "Resultado da importação"
   cTable := STR0053 // "Processamento da importação de arquivos baixados do portal do único"

   oExcel := FwMsExcelXlsx():New()
   oExcel:AddworkSheet(cWorksheet)
   oExcel:AddTable(cWorksheet, cTable)

   aStruct := (cAliasTmp)->(dbStruct())

   if (i:=aScan(aStruct, {|x| x[1] == "SEQ"})) > 0
      aDel(aStruct,i)
      aSize(aStruct,Len(aStruct)-1)
   endif

   if (i:=aScan(aStruct, {|x| x[1] == "OPE"})) > 0
      aDel(aStruct,i)
      aSize(aStruct,Len(aStruct)-1)
   endif

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

   restArea(aArea)
   oBrwProc:Refresh()

// Retorna falso para não realizar mudanças na página
return .F.

/*/{Protheus.doc} getError
   Função utilizada para tratar e formatar mensagens de erro durante o processo de importação do Catálogode produtos, retornando a mensagem apropriada para exibição ao usuário.

   @type    static function
   @author  Nícolas Castellani Brisque
   @since   02/06/2025
   @version version
   @param   xErro, Variant, Mensagem de erro recebida, podendo ser do tipo caractere ou array
   @return  cRet, String, Mensagem de erro tratada e formatada para exibição
   @example
   @see
*/
static function getError(xErro)
   local cRetorno := ""

   if valtype(xErro) == "C"
      cRetorno := alltrim(xErro)
   elseif valtype(xErro) == "A" .and. len(xErro) >= 7 .and. (!Empty(xErro[6]) .Or. !Empty(xErro[7]))
      cRetorno := STR0073 + ": " + alltrim( xErro[6] ) // "Problema"
      cRetorno += ENTER + STR0074 + ": " + alltrim( xErro[7] ) // "Solução"
   endif

return cRetorno

/*/{Protheus.doc} gravaLog
   Função para gravar o log do resultado da importação de cada registro

   @type  static function
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
static function gravaLog(oBrowProc, nSeq, cStatus, cOperacao, cCodPortal, cVersao, cMens)
   local cAliasTmp := CP404_TABLE

   reclock(cAliasTmp, .T.)
   (cAliasTmp)->STATUS := cStatus
   (cAliasTmp)->OPERACAO := cOperacao
   (cAliasTmp)->IDPORT := cCodPortal
   (cAliasTmp)->VERSAO := cVersao
   (cAliasTmp)->RETORNO := cMens
   (cAliasTmp)->SEQ := StrZero(nSeq, 12)
   if cOperacao == FABFOR .or. cOperacao == OPERADOR
      (cAliasTmp)->OPE := "1"
   elseif cOperacao == CATALOGO
      (cAliasTmp)->OPE := "2"
   endif
   (cAliasTmp)->(msUnLock())  
   oBrowProc:Refresh()

return nil

/*/{Protheus.doc} getStatus
   Função para gerar o nome do status na planilha excel

   @type  static function
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
   local cRet := ""

   do case
      case cStatus == PROCESSADO
         cRet := STR0047 // "Processado com sucesso"
      case cStatus == EXISTENTE
         cRet := STR0048 // "Registro já existente"
      case cStatus == ERRO
         cRet := STR0049 // "Falha na importação"
   endcase

return cRet

/*/{Protheus.doc} TrocaExt
   Função para trocar a extensão do arquivo para ".processado" após o sistema processar o arquivo

   @type  static function
   @author Nícolas Castellani Brisque
   @since 08/07/2025
   @version version
   @param cArquivo, String, Caminho do arquivo a ser processado
   @param cExtensao, String, Extensão do arquivo a ser processado
   @return
   @example
   TrocaExt({"C:\temp\arquivo.json"}, ".json")
   @see (links_or_references)
/*/
static function TrocaExt(aArquivo)
   local nFile     := 0
   local cArquivo  := ""
   local aTemp     := {}
   local cArqNome  := ""
   local cName     := ""
   local cExtensao := ".json"

   for nFile := 1 to len(aArquivo)
      cArquivo := aArquivo[nFile]
      aTemp := StrTokArr(cArquivo, "\")
      cArqNome := aTemp[Len(aTemp)]
      cName := StrTran(lower(cArquivo), cExtensao, ".processado")
      if !(FRename(cArquivo, cName) == 0)
         EasyHelp(STR0067 + StrTran(cArqNome, cExtensao, ".processado"), STR0015, STR0108) // "Não foi possível renomear o arquivo para: " ### "Verifique se o arquivo já existe com a extensão '.processado'"
      endif
   next nFile

return nil

/*/{Protheus.doc} decode
   Realiza a decodificação dos campos do json 

   @type  static function
   @author user
   @since 21/07/2025
   @version version
   @param
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
static function decode(cInfo)
   local cRetInfo   := ""
   
   cRetInfo := decodeutf8(cInfo)
   cRetInfo := if( cRetInfo == nil, cInfo, cRetInfo)

return cRetInfo
