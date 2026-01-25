#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJJ.CH"
#INCLUDE "AVERAGE.CH"

static _oEasyTmp  := nil
static EICSJJ_SB1 := "EICSJJ_SB1"

/*
Programa   : EICSJJ
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão
             definidas em um programa com o mesmo nome da função.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:09
Obs.       : Criado com gerador automático de fontes
Revisão    : Clayton Fernandes - 01/04/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/


Function EICSJJ()
   Local oBrowse
   local lLibAccess  := .F.
   local lExecFunc   := .F. // existFunc("FwBlkUserFunction")

   if lExecFunc
      FwBlkUserFunction(.T.)
   endif

   lLibAccess := AmIIn(17,29)

   if lExecFunc
      FwBlkUserFunction(.F.)
   endif

   if lLibAccess
      //CRIAÇÃO DA MBROWSE
      oBrowse := FWMBrowse():New() //Instanciando a Classe
      oBrowse:SetAlias("SJJ") //Informando o Alias
      oBrowse:SetMenuDef("EICSJJ") //Nome do fonte do MenuDef
      oBrowse:SetDescription(STR0001)//Orgao Em.ato Legal
      oBrowse:Activate()
   endif

Return oBrowse
/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:09
Revisão    : Clayton Fernandes - 01/04/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/

Static Function MenuDef()
   Local aRot     := {}
   Local aRotina  := {}

   //Adiciona os botões na MBROWSE
   ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"       OPERATION 1 ACCESS 0
   ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICSJJ" OPERATION 2 ACCESS 0
   ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICSJJ" OPERATION 3 ACCESS 0
   ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICSJJ" OPERATION 4 ACCESS 0
   ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICSJJ" OPERATION 5 ACCESS 0

   // a integração só será adicionada para quem tiver atualizado com os dados de formulário LPCO
   aRot := {{ STR0033 , "SJJIntgPU(.F.)" , 6, 0 },; //"Anuente Selecionado"
      { STR0034 , "SJJIntgPU(.T.)" , 6, 0 }} // "Todos"

   aAdd(aRotina, { STR0002 , aRot , 6, 0}) //"Integração de Formulários"

Return aRotina

//CRF
*-------------------------*
Static Function ModelDef()
   *-------------------------*
   Local oModel
   Local oStruSJJ  := FWFormStruct( 1, "SJJ") //Monta a estrutura da tabela SJO
   Local oStEKL

   aRelEKL := {{"EKL_FILIAL","xFilial('SJJ')"},;
      {"EKL_CODIGO","JJ_CODIGO"}}

   oModel := MPFormModel():New( 'EICSJJ', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

   oModel:AddFields( 'SJJMASTER', /*nOwner*/,oStruSJJ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
   oModel:SetDescription(STR0001)    //Orgao Em.ato Legal
   oModel:SetPrimaryKey({'JJ_FILIAL','JJ_CODIGO'})

   if avflags("FORM_LPCO")
      oStEKL := FWFormStruct( 1, "EKL")
      oModel:AddGrid( 'EKLDETAIL' , 'SJJMASTER' , oStEKL  )
      oModel:GetModel("EKLDETAIL"):SetOptional( .T. )
      oModel:SetRelation("EKLDETAIL",aRelEKL, EKL->(IndexKey(1)))
      oModel:GetModel("EKLDETAIL"):SetDescription(STR0004) //"Formulário LPCO"
   endif

Return oModel

//CRF
*------------------------*
Static Function ViewDef()
   *------------------------*
   Local oModel    := FWLoadModel("EICSJJ")
   Local oStruSJJ  := FWFormStruct( 2, "SJJ")
   Local oStEKL
   Local oView

   oView := FWFormView():New()
   oView:SetModel( oModel )

   oView:CreateFolder( 'SJJFOLDER' ) //, 'TELA')
   oView:AddSheet('SJJFOLDER',"OA",STR0003) //"Orgão Anuente"
   oView:CreateHorizontalBox( 'BOXSJJ', 50, , , 'SJJFOLDER', 'OA')
   oView:AddField('VIEW_SJJ', oStruSJJ , "SJJMASTER" )
   oView:SetOwnerView( 'VIEW_SJJ' , 'BOXSJJ' )
   oView:EnableTitleView('VIEW_SJJ', STR0001 )

   if avflags("FORM_LPCO")
      oStEKL := FWFormStruct( 2, "EKL")
      oView:CreateHorizontalBox( 'BOXEKL', 50 , , , 'SJJFOLDER', 'OA')
      oView:AddGrid( "VIEW_EKL", oStEKL, "EKLDETAIL")
      oView:SetOwnerView( 'VIEW_EKL', 'BOXEKL' )
      oView:EnableTitleView('VIEW_EKL', STR0004 ) //"Formulário LPCO"
      oView:SetViewProperty('VIEW_EKL', "GRIDDOUBLECLICK" , {{|oView,cFieldName,nLineGrid,nLineModel| showMemo(oView,cFieldName,nLineGrid,nLineModel)}} )
   endif

   //Habilita ButtonsBar
   oView:EnableControlBar(.T.)

Return oView
/*/
   Function showMemo(oView,cFieldName,nLineGrid,nLineModel)
   Função para exibir o campo meemo do grid EKL
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function showMemo(oView,cFieldName,nLineGrid,nLineModel)
   Local oModel   := FWModelActive()
   Local oMdlEKL  := oModel:GetModel("EKLDETAIL")

   eecView( oMdlEKL:getValue("EKL_FORMJS"), "Modelo LPCO")

return .F.

/*/
   Function EKLModal()
   Função para o combo box dos campos EKL e EKM modal
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Function EKLModal()
   Local cRet := ""

   cRet := "1=Importação;2=Exportação"

Return cRet
/*---------------------------------------------------------------------*
 | Func:  eklRelacao                                                   |
 | Autor: Miguel Gontijo                                               |
 | Data:  17/11/2020                                                   |
 | Desc:  Carregar valores para determinados campos, como os virtuais  |
 | Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Function EKLRelacao(cCpo)
   Local oMdlAtv := FWModelActive()
   Local oModel  := If( !(oMdlAtv:CID == "EICSJJ") ,  FWLoadModel("EICSJJ") , FWModelActive() )
   Local oMdl_EKL
   Local cValue   := ""

   if( !oModel:IsActive(), oModel:Activate(), nil)

   oMdl_EKL := oModel:GetModel("EKLDETAIL")

   If oModel:GetOperation() <> 3
      Do Case
         Case cCpo == 'EKL_MODALI' .And. ValType(oMdl_EKL) == "O"
            cValue := If( Left(EKL->EKL_CODFOR,1) == "I" , "1" , "2" )
      EndCase
   EndIf

Return cValue

/*/
   Function SJJIntgPU
   Função a ser chamada no menu outras ações para iniciar a integração de um ou de todos
   os registros de órgãos anuentes formulários LPCO e NCM x Form LPCO
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Function SJJIntgPU(lIntegAll)
   local lRet           := .F.
   local aArea          := getArea()
   local cURLAuth       := ""
   local lLPCOMult      := .F.
   local lIntegPerg     := .T. // .T. -> considera tudo, .F. -> somente formularios da EKL ou EKM diferente da ddatabase
   local aOrgaos        := {}
   local cUrlPU         := ""
   local cPUAuth        := ""
   local cErros         := ""
   local lCancelou      := .F.

   default lIntegAll    := .F.

   if avflags("FORM_LPCO")
      begin sequence

         cURLAuth := "/portal/api/autenticar"

         lLPCOMult := AvFlags("LPCO_MULTIPLE_ITEMS")

         EKL->(dbSetorder(1)) // EKL_FILIAL+EKL_CODIGO+EKL_CODFOR
         EKM->(dbSetOrder(1)) // EKM_FILIAL+EKM_ORGANU+EKM_FRMLPC+EKM_NCM
         aOrgaos := VldInteg(lIntegAll, @lIntegPerg, lLPCOMult)
         if len(aOrgaos) == 0
            MsgInfo(STR0050, STR0010) // "Não foi encontrado nenhum orgão anuente ativado." ,"Aviso"
            break
         endif
         
         cUrlPU := AVgetUrl(, , @lCancelou, "EIC")
         If lCancelou
            lRet := .F.
            break
         EndIf
         
         cPUAuth := cUrlPU + cURLAuth

         SetTmpTable()

         MSAguarde( {|| lRet := IntegPU(lIntegPerg, aOrgaos, cPUAuth, cUrlPU, @cErros, lLPCOMult) } , STR0020, STR0021 ) // "Integração Portal Único", "Aguarde a integração..."

         if lRet .and. empty(cErros)
            MsgInfo(STR0011, STR0010) //"Integração realizada com sucesso" ,"Aviso"
         else
            EECView( if( !empty(cErros), cErros, STR0012 ), STR0009 ) //"Integração abortada pelo usuário!" ### "Atenção"
         endif

         EraseTmpTable()

      end sequence

      restArea(aArea)
   Else
      EasyHelp(STR0052, STR0010, STR0053)//"Integração de Formulários não habilitada para o Ambiente."###"Aviso"###"Atualize o Ambiente com o pacote de expedição contínua através da central de atualizações."
   EndIf

return

/*/
   Function IntegPU
   Função a ser chamada no menu outras ações para iniciar a integração de um ou de todos
   os registros de órgãos anuentes formulários LPCO e NCM x Form LPCO
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Function IntegPU(lIntegPerg, aOrgaos, cPUAuth, cUrlPU, cErros, lLPCOMult)
   local lRet        := .F.
   local cObrig      := ""
   local oEasyJS     := nil
   local oProcess    := nil
   local cUrl        := "" 
   local aFormNCM    := {}

   default lIntegPerg := .F.
   default aOrgaos    := {}
   default cPUAuth    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") + "/portal/api/autenticar"
   default cErros     := ""
   default lLPCOMult  := AvFlags("LPCO_MULTIPLE_ITEMS")

   cObrig := getSX3Cache("EKM_OBRIGA","X3_RELACAO")
   cObrig := if( empty(cObrig), "2", InitPad(cObrig))

   begin sequence

      // crio somente um objeto para easyjs
      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cPUAuth
      oEasyJS:SetTimeout(30)
      
      oEasyJS:AddLib( EasyAppFetch(cPUAuth) )
      oEasyJS:AddLib( jsFormlpco() )

      cErros := STR0030 // "Falha na integração"
      if oEasyJS:Activate(.T.)

         cErros := ""
         oEasyJS:SetTimeout(0)
         oEasyJS:Accumulate(.F.)

         MsProcTxt(STR0026) // "Autenticando com Portal Único"

         oProcess := easyProgress():New(.T.)
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO(@lEnd, "AUTH", lIntegPerg, aOrgaos, cUrl, @oProcess, @cErros, @oEasyJS, lLPCOMult, cObrig, @aFormNCM) }, STR0026 ) // "Autenticando com Portal Único"
         oProcess:init()

         if !lRet
            cErros := ENTER + STR0035 + ENTER + cErros //"Não foi possível autenticar no Portal Único Siscomex, verifique o endereço nos parâmetros e verifique se o portal está no ar."
            break
         endif

         MsProcTxt(STR0027) // "Buscando Formulários LPCO"
         cUrl := cUrlPU + "/talpco/api/ext/lpco/modelo/consulta/"
         oProcess := easyProgress():New(.T.)
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO(@lEnd, "FORM", lIntegPerg, aOrgaos, cUrl, @oProcess, @cErros, @oEasyJS, lLPCOMult, cObrig, @aFormNCM) }, STR0027 ) //"Buscando Formulários LPCO"
         oProcess:init()

         if !lRet
            break
         endif

         loadSB1()

         MsProcTxt(STR0028) // "Buscando Modelos dos Formulários LPCO"
         cUrl := cUrlPU + "/talpco/api/ext/lpco/modelo/"
         oProcess := easyProgress():New(.T.)
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO(@lEnd, "MDL_FORM", lIntegPerg, aOrgaos, cUrl, @oProcess,  @cErros, @oEasyJS, lLPCOMult, cObrig, @aFormNCM) }, STR0028 ) // "Buscando Modelos dos Formulários LPCO"
         oProcess:init()

         if !lRet
            break
         endif

         MsProcTxt(STR0029) // "Buscando Modelos das NCMs associadas aos formulários"
         cUrl := cUrlPU + "/talpco/api/ext/lpco/modelo/"
         oProcess := easyProgress():New(.T.)
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO(@lEnd, "NCM", lIntegPerg, aOrgaos, cUrl, @oProcess, @cErros, @oEasyJS, lLPCOMult, cObrig, @aFormNCM) }, STR0029 ) // "Buscando Modelos das NCMs"
         oProcess:init()

         if lRet .and. lLPCOMult .and. len(aFormNCM) > 0
            oProcess := easyProgress():New()
            oProcess:setProcess( {|| BlqFormNcm(aFormNCM, oProcess) }, STR0051 + "..." ) // "Bloqueando formulários ou formulários da NCMs"
            oProcess:init()
         endif
        
      endif

   end sequence

   if oEasyJS <> nil
      oEasyJS:Destroy()
   endif

return lRet

/*/
   Function IntegLPCO(cTipo,cPUAuth,cUrl,oProcess,lEnd,cErros,oEasyJS)
   Função que monta a lista de formulários LPCO e NCM x Form LPCO com base no array de itens a serem integrados e dispara a integração
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function IntegLPCO(lEnd, cTipo, lIntegPerg, aOrgaos, cUrl, oProcess, cErros, oEasyJS, lLPCOMult, cObrig, aFormNCM)
   local lRet        := .T.
   local nRegua      := 0
   local cLista      := ""
   local cAux        := ""
   local nOrgao      := 0
   local nPosOrg     := 0
   local aForm       := {}
   local nForm       := 0
   local nFormNcm    := 0
   local aBuffer     := {}
   local lAutenticou := .F.
   local lProcessou  := .F.
   local lErroGrave  := .F.
   local lValProc    := .F.
   local cForms      := ""

   default lEnd       := .F.
   default cTipo      := ""
   default lIntegPerg := .F.
   default aOrgaos    := {}
   default cUrl       := ""
   default cErros     := ""
   default lLPCOMult  := AvFlags("LPCO_MULTIPLE_ITEMS")
   default cObrig     := "2"
   default aFormNCM   := {}

   begin sequence
      nRegua := if( cTipo == "AUTH" , 1 , 0 )

      if cTipo <> "AUTH"

         cLista := "["
         cAux := ""
         if cTipo == "FORM"

            nRegua += len(aOrgaos)
            for nOrgao := 1 to len(aOrgaos)
              cAux += if( empty(cAux), "", ",") + "'" + alltrim( aOrgaos[nOrgao] ) + "'"
            next nOrgao
            cLista += cAux

         elseif cTipo == "MDL_FORM"

            for nOrgao := 1 to len(aOrgaos)

               nPosOrg := aScan( aFormNCM, { |X| alltrim(X[1]) == alltrim( aOrgaos[nOrgao] ) } )
               if nPosOrg > 0
                  aForm := aFormNCM[nPosOrg][2]

                  nRegua += len(aForm)
                  cForms := ""
                  for nForm := 1 to len(aForm)
                     if aForm[nForm][3] == 0 .or. lIntegPerg .or. aForm[nForm][4] <> dDataBase
                        cForms += if( empty(cForms), "", ",") + "'" + aForm[nForm][1] + "'"
                     endif
                  next nForm

                  if !empty(cForms)
                     cAux += if( empty(cAux), "", ",") + "[ '" + alltrim( aOrgaos[nOrgao] ) + "' , ["
                     cAux += cForms
                     cAux += "]]"
                  endif
               endif

            next nOrgao
            cLista += cAux

         elseif cTipo == "NCM"

            for nOrgao := 1 to len(aOrgaos)

               nPosOrg := aScan( aFormNCM, { |X| alltrim(X[1]) == alltrim( aOrgaos[nOrgao] ) } )
               if nPosOrg > 0
                     
                  aForm := aFormNCM[nPosOrg][3]
                  nRegua += len(aForm)
                  for nFormNcm := 1 to len(aForm)
                     if aForm[nFormNcm][3] == 0 .or. lIntegPerg .or. aForm[nFormNcm][4] <> dDataBase
                        cAux += if( empty(cAux), "", ",") + "['" + alltrim(aOrgaos[nOrgao]) + "', '" + alltrim(aForm[nFormNcm][1]) + "', '" + alltrim(aForm[nFormNcm][2]) + "']"
                     endif
                  next

               endif

            next nOrgao
            cLista += cAux

         endif

         cLista += "]"
      endif

      lValProc := oProcess <> nil
      if lValProc
         oProcess:SetRegua(nRegua)
      endif

      if !lValProc .or. !oProcess:lAbort

         if cTipo == "AUTH"

            oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplError);" ,;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave) },;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave, .T.) } ) //Executando um javascript de forma Síncrona

         elseif cTipo == "FORM"

            // roda função js que consulta os formulários pertence aos orgãos
            oEasyJS:runJSSync( "cLista = " + cLista + "; cUrlAPI = '" + cUrl + "' ; getFormOrgaos(retAdvpl,retAdvplChunk,retAdvplError);",;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave) },;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave, .T.) } ) //Executando um javascript de forma Síncrona

         elseif cTipo == "MDL_FORM"

            // roda função js que consulta os formulários
            oEasyJS:runJSSync( "cLista = " + cLista + "; cUrlAPI = '" + cUrl + "' ; getModelForms(retAdvpl,retAdvplChunk,retAdvplError);",;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave) },;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave, .T.) } ) //Executando um javascript de forma Síncrona

         elseif cTipo == "NCM"

            // roda função js que consulta os formulários x NCM
            oEasyJS:runJSSync( "cLista = " + cLista + "; cUrlAPI = '" + cUrl + "' ; getModelNCM(retAdvpl,retAdvplChunk,retAdvplError);",;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave) },;
            {|cRetJson| lRet := SJJBufferJS(cRetJson, cTipo, @aBuffer, @lAutenticou, @lProcessou, @cErros, @lErroGrave, .T.) } ) //Executando um javascript de forma Síncrona

         endif

         // função que processa o buffer de retorno do JS
         lRet := procBuffer(cTipo, @cErros, @aBuffer, lValProc, @oProcess, @lAutenticou, @lProcessou, @lErroGrave, @oEasyJS, lLPCOMult, cObrig, @aFormNCM)

      endif

   end sequence

return lRet

/*/
   Function procBuffer(cAcao,cErros,aBuffer,aSJJInteg,oProcess,lAutenticou,lProcessou,oEasyJS)
   Função que processa o buffer alimentado pela integração com JS
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function procBuffer(cAcao, cErros, aBuffer, lValProc, oProcess, lAutenticou, lProcessou, lErroGrave, oEasyJS, lLPCOMult, cObrig, aFormNCM)
   Local lRet  := .T.

   default cAcao      := ""
   default cErros     := ""
   default aBuffer    := {}
   default lValProc   := .F.
   default lAutenticou:= .F.
   default lProcessou := .F.
   default lErroGrave := .F.
   default lLPCOMult  := AvFlags("LPCO_MULTIPLE_ITEMS")
   default cObrig     := "2"
   default aFormNCM   := {}

   if cAcao == "AUTH"

      lRet := lAutenticou
      if lValProc
         oProcess:incRegua()
      endif

   elseif cAcao $ "FORM|MDL_FORM|NCM"

      while !lErroGrave .and. (len(aBuffer) > 0 .or. !lProcessou) 
         if len(aBuffer) > 0
            if lValProc
               oProcess:incRegua()
            endif
            if '"log_trade_easy"' $ aBuffer[1] 
               //FWLogMsg( "INFO",,"EICSJJ_"+cValToChar(ThreadId()),,,,FWTimeStamp(5) + " - " + aBuffer[1] )
               retError(aBuffer[1], @cErros, cAcao )
            else
               grvRetFormLPCO(cAcao, aBuffer[1], cErros, lLPCOMult, cObrig, aFormNCM)
            endif
            aDel(aBuffer, 1)
            aSize(aBuffer,Len(aBuffer)-1)
         endif

         if lValProc
            oProcess:refresh()
            if oProcess:lAbort
               lRet := .F.
               oEasyJS:runJS( "lFim = true; console.log('fim')" )
               exit
            endif
         endif

      enddo
   endif

   if lErroGrave
      lRet := .F.
   endif

return lRet

/*/
   Function SJJBufferJS(cRetJson,cAcao,cErros,aBuffer,aSJJInteg,oProcess,lAutenticou,lProcessou,oEasyJS)
   Função que alimenta o buffer com o retorno das integrações
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function SJJBufferJS(cRetJson, cAcao, aBuffer, lAutenticou, lProcessou, cErros, lErroGrave, lError)
   local lRet := .T.

   default cRetJson    := ""
   default cAcao       := ""
   default aBuffer     := {}
   default lAutenticou := .F.
   default lProcessou  := .F.
   default cErros      := ""
   default lErroGrave  := .F.
   default lError      := .F.

   if lError
      cErros += cRetJson //decodeutf8(cRetJson) - Estava ocorrendo erro no WebApp, pois a mensagem ja vem em UTF8
      lErroGrave := .T.
      lRet := .F.
   else
      if cAcao == "AUTH"

         if Alltrim(cRetJson) == 'AUTENTICADO_OK'
            lAutenticou := .T.
         endif

      elseif cAcao $ "FORM|MDL_FORM|NCM"

         if upper(Alltrim(cRetJson)) == 'PROCESSOU'
            lProcessou := .T.
         else
            aAdd(aBuffer, cRetJson)
         endif

      endif

   endif

return lRet

/*/{Protheus.doc} retError
   Trata mensagem de retorno de erros

   @type  Static Function
   @author user
   @since 25/07/2023
   @version version
   @param cRetError, caractere, mensagem de retorno
          cErros, caractere, mensagens acumulativas
          cTipo, caractere, tipo -  FORM/MDL_FORM/NCM
   @return nenhum
/*/
static function retError(cRetError, cErros, cTipo)
   local oJson      := nil
   local xRetJson   := nil

   default cRetError := ""
   default cErros    := ""
   default cTipo     := ""

   oJson := JsonObject():New()
   xRetJson := oJson:FromJson(cRetError)
   if valtype(xRetJson) == "U"
      do case
         case cTipo == "FORM"
            cErros += STR0038 + " " + oJson:GetJsonText("orgao_anuente") + "." + CHR(10) // "Não foi encontrado a lista de modelos de LPCO para o orgão anuente"
         case cTipo == "MDL_FORM"
            cErros += StrTran( STR0039, "AAAA", oJson:GetJsonText("formulario")) + " " + oJson:GetJsonText("orgao_anuente") + "." + CHR(10) // "Não foi retornada as informações do modelo de LPCO para o formulário 'AAAA' do orgão anuente"
         case cTipo == "NCM"
            cErros += StrTran( StrTran( STR0040, "AAAA", oJson:GetJsonText("ncm")), "BBBB", oJson:GetJsonText("formulario")) + " " + oJson:GetJsonText("orgao_anuente") + "." + CHR(10) // "Não foi retornada as listas de campos a serem preenchidos para a NCM 'AAAA' do modelo 'BBBB' do orgão anuente"
      end case
   endif

   FwFreeObj(oJson)

return

/*/
   Function grvRetFormLPCO(cTipo,aSJJInteg,cBuffer,oProcess,cErros)
   Função que grava o retorno das integrações nos registros de formulários LPCO e NCM x Form LPCO
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function grvRetFormLPCO(cTipo, cBuffer, cErros, lLPCOMult, cObrig, aFormNCM)
   local oJson      := nil
   local xRetJson   := nil
   local cErro      := ""
   local cOrgao     := ""
   local aRetForm   := {}
   local nPosOrg    := 0
   local nRet       := 0
   local cNome      := ""
   local cCodigo    := ""
   local lSeekEKL   := .F.
   local nRecEKL    := 0
   local dDataEKL   := ctod("")
   local cFormJson  := ""
   local nPosForm   := 0
   local lReclock   := .F.
   local aDomNcm    := {}
   local nNcm       := 0
   local lSeekEKM   := .F.
   local nRecEKM    := 0
   local dDataEKM   := ctod("")
   local cNCM       := ""
   local nPosFrmNCM := 0
   local lProduto   := .F.

   default cTipo      := ""
   default cBuffer    := ""
   default cErros     := ""
   default lLPCOMult  := AvFlags("LPCO_MULTIPLE_ITEMS")
   default cObrig     := "2"
   default aFormNCM   := {}

   if !empty(cBuffer)

      if cTipo == "FORM"
         // a propriedade "ret" é criada no retorno da resposta da API, seguindo a estrutura:
         // {orgao_anuente: cProcLista, ret: response}
         // response é a resposta inteira da API

         oJson    := JsonObject():New()
         xRetJson := oJson:FromJson(cBuffer)
         cErro := if( valtype(xRetJson) == "U", "", STR0016 + ENTER  + oJson:toJson() + ENTER) // "Arquivo de retorno inválido!"
         cOrgao := ""
         aRetForm := {}
         if empty(cErro)
            cErro := if( valtype(oJson:GetJsonObject("ret")) == "A", "", STR0015 + ENTER + oJson:toJson() + ENTER) // "Arquivo de retorno sem itens!"
            if empty(cErro)
               aRetForm := oJson:GetJsonObject("ret")
               cOrgao := PadR(oJson:GetJsonText("orgao_anuente"), GetSX3Cache("EKL_CODIGO", "X3_TAMANHO"))
            endif
         endif
         FreeObj(oJson)
         cErros += cErro

         if !empty(cOrgao)

            // { ORGAO ANUENTE, Array com formularios, Array com Formulários x NCMs }
            aAdd( aFormNCM, { cOrgao, {}, {} } )
            nPosOrg := len(aFormNCM)

            for nRet := 1 to len(aRetForm)

               cNome := aRetForm[nRet]:GetJsonText("nome")
               cCodigo := PadR(aRetForm[nRet]:GetJsonText("codigo"), GetSX3Cache("EKL_CODFOR", "X3_TAMANHO"))
               lSeekEKL := EKL->(dbseek(xfilial("EKL") + cOrgao + cCodigo))
               nRecEKL := 0
               dDataEKL := cToD("")
               if lSeekEKL
                  nRecEKL := EKL->(Recno())
                  dDataEKL := EKL->EKL_DATA
               endif
               if aScan( aFormNCM[nPosOrg][2], { |X| X[1] == cCodigo } ) == 0  
                  aAdd( aFormNCM[nPosOrg][2], { cCodigo, cNome, nRecEKL, dDataEKL } )
               endif
            next

         endif

      elseif cTipo == "MDL_FORM"
         // a propriedade "modelo" é criada no retorno da resposta da API, seguindo a estrutura:
         // { orgao_anuente:cAnuente, formulario:cCodigo, modelo:response }
         // response é a resposta inteira da API

         oJson    := JsonObject():New()
         xRetJson := oJson:FromJson(cBuffer)
         cErro := if( valtype(xRetJson) == "U", "", STR0016 + ENTER  + oJson:toJson() + ENTER) // "Arquivo de retorno inválido!"
         cOrgao := ""
         cCodigo := ""
         if empty(cErro)
            cErro := if( valtype(oJson:GetJsonObject("modelo")) == "C", "", STR0031 + ENTER + oJson:toJson() + ENTER) // "Arquivo de retorno sem o modelo do formulário!"
            if empty(cErro)
               cOrgao  := PadR(oJson:GetJsonText("orgao_anuente"), GetSX3Cache("EKL_CODIGO", "X3_TAMANHO")) 
               cCodigo := PadR(oJson:GetJsonText("formulario"), GetSX3Cache("EKL_CODFOR", "X3_TAMANHO"))
               cFormJson := strTran( decode64( oJson:GetJsonText("modelo") ), "01_caractere_trade_easy", "–")
               cFormJson := strTran( cFormJson , "02_caractere_trade_easy", "“")
               cFormJson := strTran( cFormJson , "03_caractere_trade_easy", "”")
               //cFormJson := strTran( cFormJson , "04_caractere_trade_easy", "?") // é uma bolinha preta que esta em um campo de informacoesExportadorImportador - E00155
               //cFormJson := strTran( cFormJson , "05_caractere_trade_easy", "?") // é uma bolinha branca que esta em um campo de '05 - ABAIXO DE 25' - I00072
            endif
         endif
         FreeObj(oJson)
         cErros += cErro

         if !empty(cOrgao) .and. !empty(cCodigo) .and. !empty(cFormJson)

            nPosOrg := aScan( aFormNCM, { |X| X[1] == cOrgao } )
            if nPosOrg > 0
               nPosForm := aScan( aFormNCM[nPosOrg][2], { |X| X[1] == cCodigo })
               if nPosForm > 0

                  lReclock := .T.
                  if aFormNCM[nPosOrg][2][nPosForm][3] > 0
                     EKL->(dbGoto( aFormNCM[nPosOrg][2][nPosForm][3] ))
                     lReclock := .F.
                  endif
                  reclock("EKL", lReclock)
                  if lRecLock
                     EKL->EKL_FILIAL   := xFilial("EKL")
                     EKL->EKL_CODIGO   := cOrgao
                     EKL->EKL_CODFOR   := cCodigo
                  endif
                  EKL->EKL_DESC     := aFormNCM[nPosOrg][2][nPosForm][2]
                  if lLPCOMult
                     EKL->EKL_MSBLQL := "2"
                  endif
                  EKL->EKL_DATA     := dDatabase
                  EKL->EKL_HORA     := strtran(time(),":","")
                  EKL->EKL_FORMJS   := cFormJson
                  EKL->(msunlock())

               endif
            endif

            oJson := JsonObject():New()
            xRetJson := oJson:FromJson(cFormJson)
            cErro += if( valtype(xRetJson) == "U", "", STR0044 + " " + alltrim(cCodigo) + ENTER + oJson:toJson() + ENTER )  // "Falha ao ler as NCMs do formulário"
            if empty(cErro) .and. valtype(oJson:GetJsonObject("listaNcm")) == "J" .and. valtype(oJson:GetJsonObject("listaNcm"):GetJsonObject("dominioNcm")) == "A"

               aDomNcm := oJson:GetJsonObject("listaNcm"):GetJsonObject("dominioNcm")
               for nNcm := 1 to len(aDomNcm)

                  aDomNcm[nNcm] := PadR(aDomNcm[nNcm], GetSX3Cache("EKM_NCM", "X3_TAMANHO"))

                  lSeekEKM := EKM->(dbseek(xFilial("EKM") + cOrgao + cCodigo + aDomNcm[nNcm]))
                  nRecEKM := 0
                  dDataEKM := cToD("")
                  if lSeekEKM
                     nRecEKM := EKM->(Recno())
                     dDataEKM := EKM->EKM_DATA
                     if lLPCOMult
                        lSeekEKM := !(EKM->EKM_MSBLQL == "1")
                     endif
                  endif

                  lProduto := isNcmProd(aDomNcm[nNcm])
                  if aScan( aFormNCM[nPosOrg][3], { |X| X[1] == cCodigo .and. X[2] == aDomNcm[nNcm] } ) == 0 .and. ( lSeekEKM .or. lProduto)
                     aAdd( aFormNCM[nPosOrg][3], { cCodigo, aDomNcm[nNcm], nRecEKM, dDataEKM} )
                  endif
               next nNcm

            endif
            FreeObj(oJson)
            cErros += cErro

         endif

      elseif cTipo == "NCM"
         // a propriedade "modeloncm" é criada no retorno da resposta da API, seguindo a estrutura:
         // { orgao_anuente:cAnuente, formulario:cFormulario, ncm:cNCM, modeloncm:response }
         // response é a resposta da API

         oJson    := JsonObject():New()
         xRetJson := oJson:FromJson(cBuffer)
         cErro := if( valtype(xRetJson) == "U", "", STR0016 + ENTER  + oJson:toJson() + ENTER) // "Arquivo de retorno inválido!"
         cOrgao := ""
         cCodigo := ""
         cNCM := ""
         if empty(cErro)
            cErro := if( valtype(oJson:GetJsonObject("modeloncm")) == "C", "", STR0032 + ENTER  + oJson:toJson() + ENTER) // "Arquivo de retorno sem o modelo da NCM!"
            if empty(cErro)
               cOrgao  := PadR(oJson:GetJsonText("orgao_anuente"), GetSX3Cache("EKL_CODIGO", "X3_TAMANHO")) 
               cCodigo := PadR(oJson:GetJsonText("formulario"), GetSX3Cache("EKL_CODFOR", "X3_TAMANHO"))
               cNCM    := PadR(oJson:GetJsonText("ncm"), GetSX3Cache("EKM_NCM", "X3_TAMANHO"))
               cFormJson := strTran( decode64( oJson:GetJsonText("modeloncm") ), "01_caractere_trade_easy", "–")
               cFormJson := strTran( cFormJson , "02_caractere_trade_easy", "“")
               cFormJson := strTran( cFormJson , "03_caractere_trade_easy", "”")
               //cFormJson := strTran( cFormJson , "04_caractere_trade_easy", "?") // é uma bolinha preta que esta em um campo de informacoesExportadorImportador - E00155
               //cFormJson := strTran( cFormJson , "05_caractere_trade_easy", "?") // é uma bolinha branca que esta em um campo de '05 - ABAIXO DE 25' - I00072
            endif
         endif
         FreeObj(oJson)
         cErros += cErro

         if !empty(cOrgao) .and. !empty(cCodigo) .and. !empty(cNCM) .and. !empty(cFormJson)

            nPosOrg := aScan( aFormNCM, { |X| X[1] == cOrgao } )
            if nPosOrg > 0
               nPosFrmNCM := aScan( aFormNCM[nPosOrg][3], { |X| X[1] == cCodigo .and. X[2] == cNCM})
               if nPosFrmNCM > 0

                  lReclock := .T.
                  if aFormNCM[nPosOrg][3][nPosFrmNCM][3] > 0
                     EKM->(dbGoto( aFormNCM[nPosOrg][3][nPosFrmNCM][3] ))
                     lReclock := .F.
                  endif
                  reclock("EKM", lReclock)
                  if lReclock
                     EKM->EKM_FILIAL   := xFilial("EKM")
                     EKM->EKM_ORGANU   := cOrgao
                     EKM->EKM_FRMLPC   := cCodigo
                     EKM->EKM_NCM      := cNCM
                     EKM->EKM_OBRIGA   := cObrig
                  endif
                  if lLPCOMult
                     EKM->EKM_MSBLQL := "2"
                  endif
                  EKM->EKM_DATA   := dDatabase
                  EKM->EKM_HORA   := strtran(time(),":","")
                  EKM->EKM_FRMDEF := cFormJson
                  EKM->(msunlock())

               endif
            endif

         endif

      endif

   endif

return

/*/
   Function jsFormlpco()
   Gera os scripts para autenticar e consumir serviços de integração do portaul unico através do easyjs
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Static Function jsFormlpco()
   Local cVar

   begincontent var cVar
      var lFim = false;
      var cLista = '';
      var cUrlAPI = '';

      function getFormOrgaos(retAdvpl,retAdvplChunk,retAdvplError){
         if (cLista && !lFim) {
            var aLista  = cLista;
            var cProc = () => {
               var cProcLista = aLista.shift();
               if (cProcLista && !lFim ){
      
                  EasyFetch( retAdvplError, cUrlAPI + cProcLista, 'GET')
                  .then( (res) => {
                     if (!res.ok && res.status !== 422){
                        throw new Error(`Erro ${res.status}: ${res.statusText}`)
                     }
      
                     if (res.status !== 200 ) {
                        return {log_trade_easy: res.statusText, status: res.status, endpoint: cUrlAPI + cProcLista } ;
                     } else {
                        // Refatoração: Verifica se há conteúdo no body da resposta
                        return res.text().then(textContent => {
                           if (textContent && textContent.trim().length > 0) {
                              try {
                                 // Se há conteúdo, tenta fazer parse para JSON
                                 return JSON.parse(textContent);
                              } catch (e) {
                                 // Se falhar o parse, retorna como texto
                                 return textContent;
                              }
                           } else {
                              // Se não há conteúdo, retorna string vazia
                              return "";
                           }
                        });
                     }
                  })
                  .then( (response) => { retAdvplChunk({orgao_anuente: cProcLista, ret: response}) ; cProc() })
                  .catch( (e)  => { retAdvplError( "%Exp:STR0041%" + " - [" + cProcLista + "] - " + e.message ) }); // "Erro ao consultar o orgão anuente"
      
               } else {
                  retAdvpl("processou")
               }
            }
            cProc();
         } else {
            retAdvplError("%Exp:STR0046%") // "Lista Inválida!"
         }
      }

      function getModelForms(retAdvpl,retAdvplChunk,retAdvplError){
         if (cLista && !lFim) {
            var aLista = cLista;
            var cProcForm = () => {
               var aAux = aLista.shift();
               if (aAux && !lFim) {
                  var cAnuente = aAux.shift();
                  var aFormularios = aAux.shift();

                  var cModelos = () => {
                     var cAnu = cAnuente;
                     var cCodigo = aFormularios.shift();
                     if (cCodigo && !lFim) {
                        EasyFetch( retAdvplError, cUrlAPI + cCodigo, 'GET')
                        .then( (res) => {
                           if (!res.ok && res.status !== 422){
                              throw new Error(`Erro ${res.status}: ${res.statusText}`)
                           }

                           if (res.status !== 200 ) {
                              return {log_trade_easy: res.statusText, status: res.status, endpoint: cUrlAPI + cCodigo  } ;
                           } else {
                              // return res.json();
                              return res.text();
                           }
                        })
                        // .then( (response) => {
                        // limparPropriedade(response, "exemplo")
                        // return response;
                        // } )
                        .then( (response) => {
                           // retAdvplChunk( { orgao_anuente: cAnuente, formulario: cCodigo, modelo: response } );
                           if (typeof response === 'string') {
                              try {
                                 retAdvplChunk( { orgao_anuente: cAnuente, formulario: cCodigo, modelo: stringToBase64(response) } );
                              } catch (error) {
                                 retAdvplChunk( { orgao_anuente: cAnuente, formulario: cCodigo, modelo: { log_trade_easy: error.message }  } );
                              }
                           } else {
                              retAdvplChunk( { orgao_anuente: cAnuente, formulario: cCodigo, modelo: response } );
                           }
                           cModelos();
                        })
                        .catch( (e)  => { retAdvplError( "%Exp:STR0042%" + " - [" + cCodigo + "/"+ cAnuente + "] - " +  e.message) }); // "Erro ao consultar o formulario do orgao anuente"
                     } else {
                        cProcForm();
                     }
                  }
                  cModelos();

               } else {
                  retAdvpl("processou");
               }
            }
            cProcForm();

         } else {
            retAdvplError("%Exp:STR0046%") // "Lista Inválida!"
         }
      }

      function getModelNCM(retAdvpl,retAdvplChunk,retAdvplError){
         if (cLista && !lFim) {
            var aLista = cLista;
            var cProcNCM = () => {
               var aAux = aLista.shift();
               if (aAux && !lFim) {
                  var cAnuente    = aAux.shift();
                  var cFormulario = aAux.shift();
                  var cNCM        = aAux.shift();
                  // console.log( "orgao_anuente: " + cAnuente + " - Form: " + cFormulario + " - NCM: " + cNCM );
                  EasyFetch( retAdvplError, cUrlAPI + cFormulario + '/' + cNCM, 'GET')
                  .then( (res) => {
                     if (!res.ok && res.status !== 422){
                        throw new Error(`Erro ${res.status}: ${res.statusText}`)
                     }

                     if (res.status !== 200 ) {
                        return {log_trade_easy: res.statusText, status: res.status, endpoint: cUrlAPI + cFormulario + '/' + cNCM} ;
                     } else {
                        // return res.json();
                        return res.text();
                     }
                  })
                  // .then( (response) => {
                  //      limparPropriedade(response, "exemplo")
                  //      return response;
                  //    } )
                  .then( (response) => {
                     // retAdvplChunk( { orgao_anuente: cAnuente, formulario: cFormulario, ncm: cNCM, modeloncm: response } );
                     if (typeof response === 'string') {
                        try {
                           retAdvplChunk( { orgao_anuente: cAnuente, formulario: cFormulario, ncm: cNCM, modeloncm: stringToBase64(response) } );
                        } catch (error) {
                           retAdvplChunk( { orgao_anuente: cAnuente, formulario: cFormulario, ncm: cNCM, modeloncm: {log_trade_easy: error.message }  } );
                        }
                     } else {
                        retAdvplChunk( { orgao_anuente: cAnuente, formulario: cFormulario, ncm: cNCM, modeloncm: response } );
                     }
                     cProcNCM();
                  })
                  .catch( (e)  => { retAdvplError( "%Exp:STR0043%" + " - [" + cNCM + "-" + cFormulario + "/" + cAnuente + "] - " + e.message ) }) // "Erro ao consultar a NCM do formulario do orgao anuente"
               }else{
                  retAdvpl("processou")
               }
            }
            cProcNCM();
         } else {
            retAdvplError("%Exp:STR0046%") // "Lista Inválida!"
         }
      }

      function stringToBase64(inputString) {
         let str = '';

         for (let i = 0; i < inputString.length; i++) {
            try {
               btoa(inputString[i]);
               str += inputString[i];
            } catch (error) {
              
               if (inputString[i]==="–"){ // (formulário E00091)
                  str += '01_caractere_trade_easy'
               } else if (inputString[i]==="“"){ // (formulário E00049)
                  str += '02_caractere_trade_easy'
               } else if (inputString[i]==="”"){ // (formulário E00049)
                  str += '03_caractere_trade_easy'
               //} else if (inputString[i]==="?"){ // é uma bolinha preta que esta em um campo de informacoesExportadorImportador - E00155
               //   str += '04_caractere_trade_easy'
               //} else if (inputString[i]==="?"){  // é uma bolinha branca que esta em um campo de '05 - ABAIXO DE 25' - I00072
               //   str += '05_caractere_trade_easy'
               } else {
                  str += ' ';
                  //str += inputString[i];
               }
               //console.log(`Caractere: ${inputString[i]}`);
            }
         }

         return btoa(str);
      }

      // devido o retorno do portal unico, a propriedade "exemplo" está incorreta, mesmo sendo uma string (formulário I00011)
      // "exemplo": "{ 'codigo': 'ATT_5037', 'listaValor': [], 'valorComposto': {  'listaComposicaoAtributo': [ [ { 'atributo': 'ATT_4588', 'valor': 100 }, { 'atributo': 'ATT_4589', 'valor': '01/10/2022' } ], [ { 'atributo': 'ATT_4588', 'valor': 200 }, { 'atributo': 'ATT_4589', 'valor': '15/10/2022' } ] ] } } }"
      // não estava retornando para o advpl.
      // obs: funciona diretamente no Browser
      function limparPropriedade(objeto, propriedade) {
         for (var chave in objeto) {
            if (objeto.hasOwnProperty(chave)) {
               if (typeof objeto[chave] === 'object') {
                  limparPropriedade(objeto[chave], propriedade);
               } else if (chave === propriedade) {
                  try {
                     JSON.parse(objeto[chave].replace(/[']/g, '"'));
                  } catch (e) {
                     objeto[chave] = '';
                  }
               }
            }
         }
      }
   endcontent

Return cVar

/*/
   Function VldInteg
   Função que busca os registros de órgãos anuentes a serem atualizados pela integração com o portal único
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Static Function VldInteg(lIntegAll, lIntegPerg, lLPCOMult)
   local aOrgaos    := {}
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""
   local lPergunte  := .T.

   default lIntegAll  := .F.
   default lIntegPerg := .T.
   default lLPCOMult  := AvFlags("LPCO_MULTIPLE_ITEMS")

   cQuery := " SELECT "
   cQuery += "   JJ_CODIGO, SJJ.R_E_C_N_O_ RECSJJ, "
   cQuery += "   EKL_CODFOR, EKL_DATA, EKL.R_E_C_N_O_ RECEKL, "
   cQuery += "   EKM_NCM, EKM_DATA, EKM.R_E_C_N_O_ RECEKM "
   cQuery += " FROM " + RetSqlName('SJJ') + " SJJ "
   cQuery += "   LEFT JOIN " + RetSqlName('EKL') + " EKL ON EKL.D_E_L_E_T_ = ' ' "
   cQuery += "      AND EKL.EKL_FILIAL = ' ' "
   cQuery += "      AND EKL.EKL_CODIGO = SJJ.JJ_CODIGO "
   if lLPCOMult
      cQuery += "      AND EKL.EKL_MSBLQL <> '1' "
   endif
   cQuery += "   LEFT JOIN " + RetSqlName('EKM') + " EKM ON EKM.D_E_L_E_T_ = ' ' "
   cQuery += "      AND EKM.EKM_FILIAL = ' ' "
   cQuery += "      AND EKM.EKM_ORGANU = SJJ.JJ_CODIGO "
   cQuery += "      AND EKM.EKM_FRMLPC = EKL.EKL_CODFOR "
   if lLPCOMult
      cQuery += "      AND EKM.EKM_MSBLQL <> '1' "
   endif
   cQuery += " WHERE SJJ.D_E_L_E_T_ = ' ' "
   cQuery += " AND SJJ.JJ_FILIAL = ? "
   if !lIntegAll
      cQuery += " AND SJJ.JJ_CODIGO = ? "
   endif
   cQuery += " AND SJJ.JJ_MSBLQL <> '1' "
   cQuery += " ORDER BY JJ_CODIGO, EKL_CODFOR, EKM_NCM "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1,xFilial('SJJ'))
   if !lIntegAll
      oQuery:SetString(2,SJJ->JJ_CODIGO)
   endif

   cQuery := oQuery:GetFixQuery()

   cAliasQry := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)
   TCSetField(cAliasQry, "EKL_DATA",   "D", 8, 0)
   TCSetField(cAliasQry, "EKM_DATA",   "D", 8, 0)

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())
      if lPergunte .and. ((cAliasQry)->EKL_DATA == dDatabase .or. (cAliasQry)->EKM_DATA == dDatabase) 
         lIntegPerg := msgyesno(STR0018) // "Há formulários ou formulários por NCM atualizados hoje. Deseja atualizar novamente esses mesmos formulários?"
         lPergunte := .F.
      endif
      if aScan( aOrgaos, {|X| X == (cAliasQry)->JJ_CODIGO }) == 0
         aAdd( aOrgaos, (cAliasQry)->JJ_CODIGO)
      endif
      (cAliasQry)->(dbskip())
   end

   oQuery:Destroy()
   FwFreeObj(oQuery)
   (cAliasQry)->(dbCloseArea())

return aOrgaos

/*/{Protheus.doc} BlqFormNcm
   Função que realizar o bloqueio dos formularios x NCM que não foram retornados do Portal Único

   @type  Static Function
   @author user
   @since 31/10/2023
   @version version
   @param aFormsNcm, vetor, vetor com os orgãos anuentes,com seus formularios e NCMs retornados do portal unico
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function BlqFormNcm(aFormsNcm, oProcess)
   local nOrgao     := 0
   local nForm      := 0
   local cOrgao     := ""
   local cForms     := ""
   local aForms     := {}
   local nNcm       := 0
   local nPosForm   := 0
   local cForm      := ""
   local cNcms      := ""
   local aFormNcms  := {}
   local lValProc   := oProcess <> nil

   if lValProc
      oProcess:SetRegua(len(aFormsNcm))
   endif

   for nOrgao := 1 to len(aFormsNcm)
      if lValProc
         oProcess:IncRegua()
      endif
      cOrgao := aFormsNcm[nOrgao][1]
      cForms := ""
      aFormNcms := {}

      if len(aFormsNcm[nOrgao][2]) > 0
         for nForm := 1 to len(aFormsNcm[nOrgao][2])
            cForms += aFormsNcm[nOrgao][2][nForm][1] + "||"
         next nForm
         aForms := BlqForm(cOrgao, cForms)
      endif

      if len(aFormsNcm[nOrgao][3]) > 0
         aFormNcms := aClone(aFormsNcm[nOrgao][3])
         aSort( aFormNcms,,, {|x,y| x[1] < y[1] } )
         cForm := aFormNcms[1][1]
         nPosForm := aScan( aForms , { |X| X == cForm })
      endif

      for nNcm := 1 to len(aFormNcms)

         if nPosForm == 0 .and. cForm == aFormNcms[nNcm][1]
            cNcms += aFormNcms[nNcm][2] + "||"
         endif

         if !(cForm == aFormNcms[nNcm][1])
            if !empty(cNcms)
               BlqNCM(cOrgao, cForm, cNcms)
            endif
            cForm := aFormNcms[nNcm][1]
            nPosForm := aScan( aForms , { |X| X == cForm })
            cNcms := if( nPosForm == 0, aFormNcms[nNcm][2]  + "||", "")
         endif
               
      next nNcm

      if !empty(cNcms)
         BlqNCM(cOrgao, cForm, cNcms)
      endif

   next nOrgao

return nil

/*/{Protheus.doc} BlqForm
   Função que realizar o bloqueio dos formularios (EKL) que não foram retornados do Portal Único

   @type  Static Function
   @author user
   @since 31/10/2023
   @version version
   @param cOrgao, caractere, código do orgão anuente
          cFormul, caractere, código do formulário
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function BlqForm(cOrgao, cFormul)
   local aForms     := {}
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""

   default cOrgao  := ""
   default cFormul := ""

   cQuery := " SELECT "
   cQuery += "  EKL_CODFOR, EKL.R_E_C_N_O_ RECNO "
   cQuery += " FROM " + RetSqlName('EKL') + " EKL "
   cQuery += " WHERE EKL.D_E_L_E_T_ = ' ' "
   cQuery += " AND EKL.EKL_FILIAL = ? "
   cQuery += " AND EKL.EKL_CODIGO = ? "
   cQuery += " AND EKL.EKL_MSBLQL <> '1' "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1,xFilial('EKL'))
   oQuery:SetString(2,cOrgao)

   cQuery := oQuery:GetFixQuery()

   cAliasQry := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())
      if !((cAliasQry)->EKL_CODFOR $ cFormul)
         EKL->(dbgoTo((cAliasQry)->RECNO))
         if EKL->(recno()) == (cAliasQry)->RECNO
            Reclock("EKL",.F.)
            EKL->EKL_MSBLQL := "1"
            EKL->(MsUnLock())
            BlqNCM(cOrgao, (cAliasQry)->EKL_CODFOR)
            aAdd( aForms, (cAliasQry)->EKL_CODFOR)
         endif
      endif
      (cAliasQry)->(dbSkip())
   end 

   (cAliasQry)->(dbCloseArea())
   oQuery:Destroy()

   FwFreeObj(oQuery)

return aForms

/*/{Protheus.doc} BlqNCM
   Função que realizar o bloqueio dos NCM (EKM) que não foram retornados do Portal Único

   @type  Static Function
   @author user
   @since 31/10/2023
   @version version
   @param cOrgao, caractere, código do orgão anuente
          cFormul, caractere, código do formulário
          cNcm, caractere, código da NCM
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function BlqNCM(cOrgao, cFormul, cNcm)
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""

   default cOrgao  := ""
   default cFormul := ""
   default cNcm    := ""

   cQuery := " SELECT "
   cQuery += "  EKM_NCM, EKM.R_E_C_N_O_ RECNO "
   cQuery += " FROM " + RetSqlName('EKM') + " EKM "
   cQuery += " WHERE EKM.D_E_L_E_T_ = ' ' "
   cQuery += " AND EKM.EKM_FILIAL = ? "
   cQuery += " AND EKM.EKM_ORGANU = ? "
   cQuery += " AND EKM.EKM_FRMLPC = ? "
   cQuery += " AND EKM.EKM_MSBLQL <> '1' "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1,xFilial('EKM'))
   oQuery:SetString(2,cOrgao)
   oQuery:SetString(3,cFormul)

   cQuery := oQuery:GetFixQuery()

   cAliasQry := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())
      if empty(cNCM) .or. !((cAliasQry)->EKM_NCM $ cNcm)
         EKM->(dbgoTo((cAliasQry)->RECNO))
         if EKM->(recno()) == (cAliasQry)->RECNO
            Reclock("EKM",.F.)
            EKM->EKM_MSBLQL := "1"
            EKM->(MsUnLock())
         endif
      endif
      (cAliasQry)->(dbSkip())
   end 

   (cAliasQry)->(dbCloseArea())
   oQuery:Destroy()

   FwFreeObj(oQuery)

return

/*/{Protheus.doc} SetTmpTable
   Fecha/Apaga os arquivos temporarios criados no banco de dados

   @type  Static Function
   @author user
   @since 08/12/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function SetTmpTable()
   local cAliasTmp := ""
   local aSemSX3   := {}
   local aIndex    := {}

   if existFunc("EasyTemporaryTable")

      _oEasyTmp := EasyTemporaryTable():new()

      cAliasTmp := EICSJJ_SB1
      aSemSX3 := {}
      aAdd(aSemSX3, {"B1_POSIPI", getSX3Cache("B1_POSIPI", "X3_TIPO"), getSX3Cache("EKM_NCM", "X3_TAMANHO"), getSX3Cache("B1_POSIPI", "X3_DECIMAL") })
      aIndex := {}
      aAdd(aIndex, "B1_POSIPI" )
      _oEasyTmp:setData(nil, aSemSX3, cAliasTmp, aIndex)

   endif

return

/*/{Protheus.doc} EraseTmpTable
   Fecha/Apaga os arquivos temporarios criados no banco de dados

   @type  Static Function
   @author user
   @since 08/12/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function EraseTmpTable()
   if _oEasyTmp <> nil
      _oEasyTmp:destroy()
      FwFreeObj(_oEasyTmp)
   endif
return

/*/{Protheus.doc} loadSB1
   Função que realizar a carga de NCM informada na SB1

   @type  Static Function
   @author user
   @since 08/12/2023
   @version version
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function loadSB1()
   local cQuery     := ""
   local cAliasQry  := ""
   local cAliasTmp  := EICSJJ_SB1

   if _oEasyTmp <> nil
      _oEasyTmp:ClearTmp(cAliasTmp)

      cQuery := " SELECT "
      cQuery += "  B1_POSIPI "
      cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
      cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
      cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
      cQuery += " AND SB1.B1_POSIPI <> ' ' "
      cQuery += " AND SB1.B1_MSBLQL <> '1' "
      cQuery += " GROUP BY SB1.B1_POSIPI "
      cQuery += " ORDER BY SB1.B1_POSIPI "
 
      cAliasQry := getNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      while (cAliasQry)->(!eof())

         reclock(cAliasTmp, .T.)
         (cAliasTmp)->B1_POSIPI := (cAliasQry)->B1_POSIPI
         (cAliasTmp)->(msUnLock())

         (cAliasQry)->(dbSkip())
      end 

      (cAliasQry)->(dbCloseArea())

   endif

return

/*/{Protheus.doc} isNcmProd
   Função que verificar se a NCM está cadastrada no SB1 produto

   @type  Static Function
   @author user
   @since 08/12/2023
   @version version
   @param cNcm, caractere, código da NCM
   @return lRet, lógico, verdadeiro se a NCM estiver cadastrada no SB1
   @example
   (examples)
   @see (links_or_references)
/*/
static function isNcmProd(cNcm)
   local lRet       := .F.
   local cAliasTmp  := EICSJJ_SB1

   default cNcm       := ""

   if _oEasyTmp <> nil
      lRet := (cAliasTmp)->(dbSeek(cNcm))
   endif

return lRet
