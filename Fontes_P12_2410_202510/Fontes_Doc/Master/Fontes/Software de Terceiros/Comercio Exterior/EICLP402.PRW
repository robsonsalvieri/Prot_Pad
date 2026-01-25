#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#INCLUDE 'AVERAGE.CH'
#Include 'EICLP402.CH'
#INCLUDE "EEC.CH"
 
/*
Funcao      : EICLP402()
Parametros  :
Retorno     : Nil
Objetivos   : Executar Integração da LPCO
Autor       : Maurício/Nilson
Data/Hora   : 09/12/2020
Obs.        :
*/
Function EICLP402()
Local aCoors := FWGetDialogSize( oMainWnd )
Local  oColumn
local lLibAccess  := .F.
local lExecFunc   := .F. // existFunc("FwBlkUserFunction")

Private oDlgInt
Private oBrwInLpco
Private oRegLPCO  := tHashMap():New()

if lExecFunc
   FwBlkUserFunction(.T.)
endif

lLibAccess := AmIin(17,29)

if lExecFunc
   FwBlkUserFunction(.F.)
endif

if lLibAccess
      //Cria a tela principal, sem bordas, títulos ou botões
      oDlgInt := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0001,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,) //"Integração de Solicitações de LPCO"

      //Cria o objeto do browse dos registros de LPCO
      oBrwInLpco := FWmBrowse():New()
      oBrwInLpco:SetOwner(oDlgInt)
      oBrwInLpco:SetDescription(STR0002) //"Integração de LPCO"
      oBrwInLpco:SetAlias("EKO")
      oBrwInLpco:SetMenuDef("EICLP402")
      oBrwInLpco:DisableDetails()//Desabilita a exibição dos detalhes do registro

      //Cria o filtro padrão para o Browse.
      oBrwInLpco:AddFilter (STR0003, "EKO_ATIVO == '1' .AND. EKO_INTEGR <> '1'", .T., .T.)  //"Ativos e não integrados"

      //Cria a coluna do marca/desmarca
      ADD MARKCOLUMN oColumn DATA { || SetMark() } DOUBLECLICK {|| MarkOne() } HEADERCLICK {|| MarkAll(oBrwInLpco) } OF oBrwInLpco

      //Habilita a exibição de visões e gráficos
      oBrwInLpco:SetAttach( .T. )
      //Configura as visões padrão
      oBrwInLpco:SetViewsDefault(LP402GetVs())
      oBrwInLpco:CIDVIEWDEFAULT := If( nModulo == 17,"1","2" ) //View "Importação"(SIGAEIC) e "Exportação"(SIGAEEC)
      oBrwInLpco:ForceQuitButton()
      //Ativa o Browse
      oBrwInLpco:Activate()
      //AutoMark()

      ACTIVATE MSDIALOG oDlgInt CENTERED

endif

Return Nil

/*---------------------------------------------------------------------*
 | Func:  LP402GetVs                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Montar e retornar as visões Default do Browse                |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function LP402GetVs()
Local aVisions    := {}
Local aColunas    := AvGetCpBrw("EKO")
Local aContextos  := {"IMPORTAÇÃO","EXPORTAÇÃO"}
Local cFiltro     := ""
Local oDSView
Local i

   If aScan(aColunas, "EKO_FILIAL") == 0
      aAdd(aColunas, "EKO_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := LP402GetFt(aContextos[i])            
      oDSView    := FWDSView():New()
      oDSView:SetName(AllTrim(Str(i)) + "-" + LP402GetFt(aContextos[i], .T.))
      oDSView:SetPublic(.T.)
      oDSView:SetCollumns(aColunas)
      oDSView:SetOrder(1)
      oDSView:AddFilter(AllTrim(Str(i)) + "-" + LP402GetFt(aContextos[i], .T.), cFiltro)
      oDSView:SetID(AllTrim(Str(i)))
      oDsView:SetLegend(.T.)
      aAdd(aVisions, oDSView)
   Next

Return aVisions

/*---------------------------------------------------------------------------------------------------------*
 | Func:  LP402GetFt                                                                                       |
 | Autor: Nilson César                                                                                     |
 | Data:  04/11/2020                                                                                       |
 | Desc:  Retorna a chave ou nome do filtro da tabela EKO de acordo com o contexto desejado                |
 | Obs.:  /                                                                                                |
 *--------------------------------------------------------------------------------------------------------*/
Static Function LP402GetFt(cTipo, lNome)
Local cRet     := ""
Default lNome  := .F.

   Do Case
      Case cTipo == "IMPORTAÇÃO" .And. !lNome
         cRet := "Upper(Left(EKO->EKO_FRMLPC,1)) = 'I' "
      Case cTipo == "IMPORTAÇÃO" .And. lNome
         cRet := "Importação"

      Case cTipo == "EXPORTAÇÃO" .And. !lNome
         cRet := "Upper(Left(EKO->EKO_FRMLPC,1)) = 'E' "
      Case cTipo == "EXPORTAÇÃO" .And. lNome
         cRet := "Exportação"
   EndCase

Return cRet


/*
Funcao      : MenuDef()
Parametros  :
Retorno     : Nil
Objetivos   : Menu Funcional
Autor       : 
Data/Hora   : 29/09/20
Obs.        :
*/
Static Function MenuDef()

Local aRot := {}

ADD OPTION aRot TITLE STR0004 ACTION 'LP402Integ()' OPERATION 4 ACCESS 0 //OPERATION X   //#"Integrar"

Return aRot

/*
Funcao      : LP402Integ()
Parametros  :
Retorno     : .T.
Objetivos   : Executar FwMarkBrowse de Integração de Status da DUE - Recebera retorno da consulta de status da integração junto ao portal
Autor       : 
Data/Hora   : 29/09/20
Obs.        :
*/
Function LP402Integ()
Local aAux := {}
Local aListLPCO := {}
Local i

   oRegLPCO:List(@aAux)
   If ( lHasReg := Len(aAux) > 0 )
      For i := 1 To Len(aAux)
         aAdd( aListLPCO, { aAux[i][1] , aAux[i][2][1] , aAux[i][2][2] , aAux[i][2][3] , aAux[i][2][4], aAux[i][2][5] } )
      Next i

      //Orderna o array por código do LCPO + Versão
      aSort(aListLPCO,,,{|x,y| x[2] < y[2] .And. x[3] < y[3]   })

      //Chama a integração de status
      aLPCOs := LP402IntSt(aListLPCO) //Garantir que o fwmarkbrowse deixa marcado apenas os processos que retornaram da integração
   Else
      MsgStop(STR0005,STR0006) //"Não há registro(s) marcado(s) para integração!"  # "Aviso"
   EndIf
   oBrwInLpco:Refresh()

Return .T.

/*
Função   : SetMark
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Retorna marca de registro conforme avaliação
*/
static function SetMark()
Local cRet
Local hashChLPCO := EKO->( RECNO() )

   aBuffLPCO := {}
   If !oRegLPCO:Get(hashChLPCO, @aBuffLPCO)
      cRet := 'LBNO'
   Else 
      cRet := 'LBOK'
   EndIf

Return cRet

/*
Função   : AutoMark
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Marca registros automaticamente conforme condição
*/
static function AutoMark()
Local lRet := .T.

   IF EKO_INTEGR <> '1'
      MarkOne(oMark)
   ENDIF

Return lRet

/*
Função   : MarkOne
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Habilita/Desabilita registro para marcação conforme condição
           Executa a ação do "DoubleClic"
*/
static function MarkOne(oMark)
Local lRet := .F.
Local hashChLPCO := EKO->( Recno() )

aBuffLPCO := {}
If !oRegLPCO:Get(hashChLPCO, @aBuffLPCO)
   oRegLPCO:Set( hashChLPCO , { EKO->EKO_ID , EKO->EKO_VERSAO, EKO->EKO_FRMLPC, EKO->EKO_INFOAD, EKO->EKO_LPCO } )
   lRet := .T.
Else
   oRegLPCO:Del(hashChLPCO)
   lRet := .F.
EndIf

return lRet//cRet

/*
Função   : MarkAll
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Habilita/Desabilita registros para marcação conforme condição
           Executa a ação do "HeaderClic"
*/
static function MarkAll(oBrw)
Local lRet := .F.
Local aListLPCO := {}
oRegLPCO:List(@aListLPCO)
If Empty(aListLPCO)
   EKO->(DbGoTop())
   Do While EKO->(!Eof())
      oRegLPCO:Set( EKO->( Recno() ) , { EKO->EKO_ID , EKO->EKO_VERSAO, EKO->EKO_FRMLPC, EKO->EKO_INFOAD, EKO->EKO_LPCO } )
      EKO->(DBSkip())
   EndDo
   lRet := .T.
Else
   oRegLPCO:Clean()
   lRet := .F.
EndIf
EKO->(DbGoTop())
oBrw:Refresh()

return lRet

/*
Função   : LP401GrvEKO
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Gravar os registros de detalhes de histórico da DUE (Consulta DUE)
*/
Static Function LP401GrvEKO( aDataRet )
Local lRet := .T.

EKO->( DbGoTo(aDataRet[1]) )

Begin Transaction
   // Grava os dados de retorno do Portal para a LPCO
   EKO->(Reclock("EKO",.F.))
   EKO->EKO_FILIAL   := xFilial("EKO")
   EKO->EKO_DATARG   := aDataRet[7][1][1][1]
   EKO->EKO_HORARG   := aDataRet[7][1][1][2]  
   EKO->EKO_CHVACE   := aDataRet[7][1][2]
   EKO->EKO_LPCO     := aDataRet[7][1][3]
   EKO->EKO_INTEGR   := "1"
   EKO->( MsUnlock() )

End Transaction

Return lRet

/*
Funcao      : LP401ExcHs
Parametros  :
Retorno     : aLPCOs
Objetivos   : Função que retira registro de LPCOs ja integrados do HashMap
Autor       : 
Data/Hora   : 06/10/2020
Obs.        :
*/
static function LP401ExcHs(oRegLPCO, aLPCOs , nPosaProc)
Local aBuffLPCO := {}

If oRegLPCO:Get(aLPCOs[1][1], @aBuffLPCO)
   oRegLPCO:Del(aLPCOs[1][1])
EndIf
If ValType( aLPCOs[nPosaProc] ) == "A"
   aDel(aLPCOs,nPosaProc)
   aSize(aLPCOs,Len(aLPCOs)-1)
EndIf

Return

/*
Funcao      : LP402IntSt
Parametros  :
Retorno     : aLPCOs - 
Objetivos   : Função que efetua a consulta de status da Declaração Única de Exportação junto ao Portal
Autor       : 
Data/Hora   : 29/09/20
Obs.        :
*/
Function LP402IntSt(aLPCOs)
Local lRet        := .T.
Local cPortal     := ""
Local lCancelou   := .F.

Default aLPCOs  := {}

Private lProcessou := .F. //ira mudar para True assim que processar tudo ou se o usuario cancelar e ja tiver consultado ao menos um Status
Private lPrimeira  := .T.

Begin sequence
     
   If Len(aLPCOs) = 0   
      EasyHelp(STR0014) //"Marque ao menos uma solicitação LPCO"  
      lRet := .F.
   else
      cPortal := AVgetUrl(, , @lCancelou, "EIC")
      If lCancelou
         lRet := .F.
         break
      EndIf

      EECView("", STR0012 ,,,,.F.,.T., { |oLogView| lRet := LP402Port(aLPCOs, cPortal, @oLogView) }, .T.) // "Processando Integração de LPCO"

   EndIf  

End Sequence

Return aLPCOs

/*/{Protheus.doc} getLog
   Geração de log da integração do LPCO
   
   @type  Static Function
   @author user
   @since 16/08/2023
   @version version
   @param cMsg, caractere, Mensagem de log
          oLogView, objeto, objeto do MEMO do EECVIEW
   @return nulo
/*/
static function getLog(cMsg, oLogView)
   default cMsg      := ""
 
   oLogView:appendText( cMsg )
   oLogView:Refresh()
   oLogView:goEnd()

return

/*/{Protheus.doc} LP402Portltrim(str(aLPCOs[1]))
   Função que realiza a Consulta de Status da Integração com o Portal para cada item do array aLPCOs
   @author Ramon Prado
   @since 30/09/2020
   @version 1
   /*/
Function LP402Port(aLPCOs,cPortal,oLogView)
Local nQtdInt  := Len(aLPCOs)
Local lRet     := .T.
Local cErros   := ""
Local cPUAuth  := cPortal+"/portal/api/autenticar"
Local aBuffProc:= {}
Local cLPCOProc := ""
Local i:=0
LOcal ctn:=0
local aAreaEKL   := {}
local aAreaEKM   := {}
local aAreaEKP   := {}
local aAreaEKD   := {}
local aAreaEKF   := {}
local aAreaEKJ   := {}
local oHashForm  := tHashMap():New()

Private oEasyJS
Private lErroGrave := .F.

   getLog( STR0029 + " " + if(EasyGParam("MV_EIC0074",.F.,"1") == "1", STR0030, STR0031) + ENTER, oLogView) // "Integração realizada no ambiente de " ### "Produção." #### "Treinamento."
   getLog( dToc(Date()) +  " - " + Time() + " - " +  STR0032 + ": " + UsrFullName(retCodUsr()) + ENTER + ENTER, oLogView) // "Usuário do sistema: "
   getLog( STR0033 + ": " + ENTER + ENTER, oLogView) // "Detalhes da Integração"
   getLog( Time() + " - " +  STR0034 + ENTER + ENTER , oLogView) // "Início do processamento de integração de LPCO"

   oEasyJS := EasyJS():New()
   oEasyJS:cUrl := cPUAuth
   oEasyJS:AddLib( EasyAppFetch(cPUAuth) )
   oEasyJS:AddLib( LP402Script())
   oEasyJS:SetTimeout(60)
      
   If oEasyJS:Activate(.T.)
      oEasyJS:SetTimeout(0)
      getLog( Time() + " - " + STR0035 + ENTER + ENTER, oLogView) // "Acessando o certificado digital"
      oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplError);" ,{|x| lRet := LP402BUFFER(x, aBuffProc,aLPCOs,@oLogView) }, {|x|   lErroGrave := .T., cErros := x } ) //Executando um javascript de forma Síncrona                 
      
      if lRet .and. ! lErroGrave
         oEasyJS:runJS( "IntLpco('" + cPortal + "/talpco/api/ext/lpco/" + "',retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := LP402BUFFER(x, aBuffProc,aLPCOs,@oLogView) }, {|x|  lErroGrave := .T., cErros := x } ) //Executando um javascript de forma Síncrona                       
      Else
         cErros += ENTER + STR0026 //"Não foi possível autenticar no Portal Único Siscomex. Verifique o endereço nos parâmetros e verifique se o portal está no ar."
         lRet := .F.
      EndIf   
   Else
      cErros := STR0036 + ENTER  // "Não foi possível acessar o site do Portal Único."
      lRet := .F.
   EndIf

   if( !lRet .or. lErroGrave, getLog( Time() + " - " + if( Alltrim(cErros) == "Failed to fetch", STR0019, cErros) + ENTER, oLogView), nil) // "Falha de conexão com o Portal Siscomex"
   ctn:=0
   if lRet 
      
      aAreaEKM := getArea("EKM")
      EKM->(dbSetOrder(1))

      aAreaEKL := getArea("EKL")
      EKL->(dbSetOrder(1))

      aAreaEKP := getArea("EKP")
      EKP->(dbSetOrder(1))

      aAreaEKD := getArea("EKD")
      EKD->(dbSetOrder(4)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VATUAL

      aAreaEKF := getArea("EKF")
      EKF->(dbSetOrder(1)) // EKF_FILIAL + EKF_COD_I + EKF_VERSAO + EKF_CODFAB + EKF_LOJA + EKF_PAIS

      aAreaEKJ := getArea("EKJ")
      EKJ->(dbSetOrder(1)) // EKJ_FILIAL + EKJ_CNPJ_R + EKJ_FORN + EKJ_FOLOJA

      For i:=1 to nQtdInt
         cLPCOProc := LP402Json(aLPCOs[i], @oHashForm, oLogView) 
         // oEasyJS:runJS("addLpcos(retAdvpl,'" + cLPCOProc + "')" , {|x| ctn := ctn+1} ,  {|x| cErros := x } )
         addLpcos(oEasyJS, @cErros, cLPCOProc, @ctn)
      Next

      oHashForm:Clean()
      FwFreeObj(oHashForm)
      restArea(aAreaEKL)
      restArea(aAreaEKM)
      restArea(aAreaEKP)
      restArea(aAreaEKP)
      restArea(aAreaEKF)
      restArea(aAreaEKJ)

      oEasyJS:wait({|| ctn == nQtdInt .or. lErroGrave }) 
      oEasyJS:runJS( "lEndFor = true; retAdvpl('S');" , , {|x| cErros := x } )
      lRet := LP402DescB(aBuffProc,aLPCOs,@oLogView)
   EndIf

   getLog( Time() + " - " + STR0037, oLogView)// "Fim do processamento."

   if oEasyJS <> nil
      oEasyJS:Destroy()
   endif

Return lRet

/*/{Protheus.doc} LP402DescB
   Função que descarrega(chama a função que processa o retorno do JSON do Portal Siscomex) o Buffer
   @author Ramon/Nilson
   @since 30/09/2020
   @version 1
   /*/
static function LP402DescB(aBuffProc,aLPCOs, oLogView)
Local lRet           := .T.
Local nCont          := 1
local cErrosLPCO     := ""

//Processa o JSON de Retorno para salvar o conteudo das tags e chamar a gravação da tabela de status da integração(EKK)

While (Len(aBuffProc) > 0 .Or. !lProcessou) .And. !lErroGrave
   If Len(aBuffProc) > 0
      LP402PROCJ(aBuffProc[1],@cErrosLPCO,aLPCOs, oLogView)
      aDel(aBuffProc, 1)
      aSize(aBuffProc,Len(aBuffProc)-1)
   Else
      oEasyJS:wait({|| len(aBuffProc) > 0 .or. lErroGrave .or. lProcessou }) 
   EndIf
   nCont++  
EndDo

IF !Empty(cErrosLPCO)
   lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} LP402BUFFER
   Buffer para processamento
   @author Ramon/Nilson
   @since 02/10/2020
   @version 1
   /*/
Function LP402BUFFER(cRetJson, aBuffProc, aLPCOs, oLogView)
Local lRet := .F.

If Alltrim(cRetJson) == 'Processou'
   lProcessou := .T.
   lRet := .T. 
elseIf Alltrim(cRetJson) == 'AUTENTICADO_OK' .or. Alltrim(cRetJson) == "S"
   lRet := .T. 
Else
   aAdd(aBuffProc, cRetJson)
Endif

If ( !IsInCallStack("LP402DescB") .And. lProcessou, lRet := LP402DescB(aBuffProc,aLPCOs,oLogView), nil) //uso do msaguarde tera descarga de buffer diferente do EasyProgress

Return lRet 

/*/{Protheus.doc} LP402PROCJ
   Processa o retorno(Json) da consulta de status da LPCO
   @author Ramon/Nilson
   @since 02/10/2020
   @version 1
   /*/
static Function LP402PROCJ(cRetJson,cErros,aLPCOs, oLogView)
Local nPos := 0
Local cLpco       := ""
Local aDataP      := {}
Local aAuxP       := {}
Local cNumLpco    := ""
Local cChave      := ""
local cErrosLPCO  := ""

default cErros := ""
 // Pega o retorno e converte para json para extrair as informações
If !Empty(cRetJson)
   oJson    := JsonObject():New()
   xRetJson := oJson:FromJson(cRetJson)
   If valtype(xRetJson) == "U" 
      If valtype(oJson:GetJsonObject("ret")) == "J"
         cLpco := If(Valtype(oJson:GetJsonObject("lpco")) == "C", oJson:GetJsonObject("lpco"), "")
         nRecnoEKO := val(oJson:GetJsonText("receko"))
         EKO->(dbgoto( nRecnoEKO))
         
         getLog( Time() + " - " + STR0038 + " - ID: " + alltrim(EKO->EKO_ID) + " / " + STR0040 + ": " + alltrim(EKO->EKO_VERSAO) + " - " + STR0041 + ": " + alltrim(EKO->EKO_ORGANU) + " / " + STR0042 + ": " + alltrim(EKO->EKO_FRMLPC) + if( !empty(EKO->EKO_LPCO),  " / " + "LPCO" + ": " + alltrim(EKO->EKO_LPCO) ,"" ) + ENTER, oLogView)  // "Mensagem de retorno" ###  "Versão" ### "Orgão Anuente" ### "Formulario"
         getLog( space(11) + STR0039 + ": " + oJson:GetJsonObject("ret"):toJson() + ENTER + ENTER , oLogView ) // "Resposta"
         
         if Valtype(oJson:GetJsonObject("ret"):GetJsonObject("chaveAcesso")) == "C"
            cChave := If(Valtype(oJson:GetJsonObject("ret"):GetJsonObject("chaveAcesso")) == "C", oJson:GetJsonObject("ret"):GetJsonObject("chaveAcesso"), "")
            cNumLpco := if(Valtype(oJson:GetJsonObject("ret"):GetJsonObject("numero")) == "C", oJson:GetJsonObject("ret"):GetJsonObject("numero"), "")
            cDatahora := if(ValType(oJson:GetJsonObject("ret"):GetJsonObject("dataRegistro")) == "C", oJson:GetJsonObject("ret"):GetJsonObject("dataRegistro"), "")
            nPos := aScan(aLPCOs,{|x| x[2] == cLpco })
            If nPos > 0
               If !Empty(cDatahora)                        
                  aAdd( aDataP , {  StoD( StrTransf(SubStr(cDataHora , 1, At("T", cDataHora)-1 ),"-","") )  , StrTransf(SubStr(cDataHora , At("T", cDataHora)+1 ,5),":","")  } )
               EndIf 
               If !Empty(cChave)
                  aAdd( aDataP, cChave)
               EndIf 
               If !Empty(cNumLpco)
                  aAdd( aDataP, cNumLpco)
               EndIf 
            EndIf
            aAdd( aAuxP, aDataP)

            aAdd( aLPCOs[nPos], aAuxP)
            LP401GrvEKO(aLPCOs[nPos]) //função para gravação dos status
            LP401ExcHs(oRegLPCO, aLPCOs, nPos ) //função para exclusao do processo ja gravado do THashMap
            
         Else
            cErrosLPCO += STR0020 + cLpco + ENTER //"Falha de Integração para LPCO: "
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("code")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("code")), oJson:GetJsonObject("ret"):GetJsonText("code") + ENTER, "")      
            cErrosLPCO += If(ValType(oJson:GetJsonObject("ret"):GetJsonObject("date")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("date")) ,oJson:GetJsonObject("ret"):GetJsonText("date") + ENTER , "")               
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("tag")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("tag")) ,oJson:GetJsonObject("ret"):GetJsonText("tag") + ENTER , "")  
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("severity")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("severity")) ,oJson:GetJsonObject("ret"):GetJsonText("severity") + ENTER  , "") 
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("message")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("message")), ENTER + oJson:GetJsonObject("ret"):GetJsonText("message") + ENTER, "") 

            if ValType(oJson:GetJsonObject("ret"):GetJsonObject("detail")) == "A" 
               cErrosLPCO += getDetail(oJson:GetJsonObject("ret"):GetJsonObject("detail"))
            endif

         Endif
      Elseif Valtype(oJson:GetJsonObject("ERROR")) == "C"
         If oJson:GetJsonObject("ERROR") == "Not Found"
            cErrosLPCO += STR0021 + oJson:GetJsonObject("ERROR") + ENTER //"Provavelmente a Conexão com o Servidor está indisponível ou houve falha na autenticação "  
         Else
            cErrosLPCO += STR0022 + oJson:GetJsonObject("ERROR") + ENTER //"Falha na integração"
         EndIf   
      EndIf
      FreeObj(oJson)
   Else
      cErrosLPCO += STR0020 + cLpco + "  " + xRetJson + ENTER //"Falha de Integração para LPCO: "
   Endif
Else
   cErrosLPCO += STR0023 + cLpco + ENTER //"Não houve retorno para LPCO: "
Endif

if(!empty(cErrosLPCO), (cErros += cErrosLPCO, getLog( Time() + " - " +  STR0043 + ": "  + cErrosLPCO + ENTER + ENTER , oLogView)), nil) // "Erros encontrados na integração"

Return

static function getDetail(aDetail)
   local cMsgDetail  := ""
   local nDetail     := 0

   default aDetail     := {}

   for nDetail := 1 to len(aDetail)
      if aDetail[nDetail]:hasProperty("message")
         cMsgDetail += aDetail[nDetail]["message"] + ENTER
      endif
      cMsgDetail += if( aDetail[nDetail]:hasProperty("detail"), getDetail(aDetail[nDetail]["detail"]),"")
   next

return cMsgDetail

/*/{Protheus.doc} LP402Script
   Gera o script para consumir o serviço do portal unico através do easyjs
   @author Ramon/Nilson
   @since 30/09/2020
   @version 1
   /*/
Static Function LP402Script()

   begincontent var cVar
      var lFim = false;
      var aLpcos = [];
      var lEndFor = false;

      function addLpcos(cLpco, retAdvpl, retAdvplChunk, retAdvplError){
         aLpcos.push(cLpco);
         retAdvpl('Processou');
      }
 
      function IntLpco(cUrl, retAdvpl,retAdvplChunk,retAdvplError){
         var cProcLpco = () => {
            var cLpco = aLpcos.shift();
            if(cLpco && !lFim){
               //var jLpco = JSON.parse(cLpco)
               var recno = cLpco.recno;
               var cLpcoId = cLpco.idLpco;
               var cVersao = cLpco.versao;
               var cNumLpco = cLpco.numLpco;
               var cJson = cLpco.cJson;

               EasyFetch( retAdvplError, cUrl+cNumLpco, (cNumLpco==''?'POST':'PUT'), cJson)
               .then( (res) => res.json() )
               .then( (json) => { retAdvplChunk({OA:cNumLpco,ret:json,lpco:cLpcoId, receko: recno}) ; cProcLpco() })
               .catch((e) => { retAdvplError(e) });
            } else {
                   if (lEndFor) {
                      retAdvpl('Processou');
                   } else {
                      setTimeout(cProcLpco,100);
                   }
            }
         }
         cProcLpco();
      }

   endcontent

Return cVar

/*
Função que gera o json do lpco para a integracao
@author Maurício Frisons
@since 15/12/2020
*/
static function LP402Json(aLpcos, oFormLPCO, oLogView)
   local cJsonLPCO  := ""
   local oJsonInter := JsonObject():New()
   local oJson      := JsonObject():New()

   default oFormLPCO := tHashMap():New()

   oJson := getJsonLPCO(aLpcos[1], @oFormLPCO, oLogView)

   oJsonInter['recno']      := aLpcos[1]
   oJsonInter['idLpco']     := aLpcos[2]
   oJsonInter['versao']     := aLpcos[3]
   oJsonInter['modeloForm'] := aLpcos[4]
   oJsonInter['numLpco']    := alltrim(aLpcos[6])
   oJsonInter['cJson']      := oJson

   cJsonLPCO := oJsonInter:toJson()

   FwFreeObj(oJson)
   FwFreeObj(oJsonInter)

return cJsonLPCO

/*/{Protheus.doc} getJsonLPCO
   Função para gerar o json do LPCO (IncluirLpcoRequest)

   Dados de um LPCO a ser cadastrado
   {
      "codigoModelo": "E00104", -> Código do modelo de LPCO utilizado para o pedido - Lei de formação: O número do modelo de LPCO é composto por O = Operação (E para exportação, I para importação) e NNNNN = Número sequencial do LPCO no ano
      "informacaoAdicional": "Texto livre", -> Informações adicionais prestadas pelo importador/exportador
      "dataReferencia": "2019-08-27T13:28", -> Data de referência para emissão do pedido. Se não informada, utiliza-se o momento atual
      "listaCamposFormulario": [], -> CampoLpcoRequest -> Lista de campos do pedido que fazem parte dos "Dados Gerais" do LPCO, ou seja, aqueles que não são informados por item.
      "listaNcm": [], -> ItemLpcoInserirRequest - Lista dos itens do LPCO. Contém campos como NCM e código do produto de cada item do LPCO, entre outros.
      "numeroLI": 2200002094 -> Número da LI
   }

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param nRecnoEKO, numerico, recno da EKO
          oFormLPCO, objeto, HashMap com os formularios obtidos das tabelas EKL e EKM
   @return jJson, json, json com o body da mensagem para integração do LPCO
   @example
   (examples)
   @see (links_or_references)
/*/
static function getJsonLPCO(nRecnoEKO, oFormLPCO, oLogView)
   local jJsonLPCO  := nil
   local oModForm   := nil
   local aListaNCM  := {}
   local lReqCat    := .F.
   local nNumLi     := 0

   default nRecnoEKO  := 0

   EKO->(dbGoTo(nRecnoEKO))
   if EKO->(Recno()) == nRecnoEKO

      getLog( Time() + " - " + STR0044 + " - ID: " + alltrim(EKO->EKO_ID) + " / " + STR0040 + ": " + alltrim(EKO->EKO_VERSAO) + " - " + STR0041 + ": " + alltrim(EKO->EKO_ORGANU) + " / " + STR0042 + ": " + alltrim(EKO->EKO_FRMLPC) + if( !empty(EKO->EKO_LPCO),  " / " + "LPCO" + ": " + alltrim(EKO->EKO_LPCO) ,"" ) + ENTER, oLogView)  // "Integrando LPCO"  ###  "Versão" ### "Orgão Anuente" ### "Formulario"

      oModForm := getFormLPCO( @oFormLPCO )

      jJsonLPCO := JsonObject():New()

      if empty(EKO->EKO_LPCO) // quando gerado numero de LPCO não é necessário informar o modelo
         jJsonLPCO["codigoModelo"] := alltrim(EKO->EKO_FRMLPC)
      endif

      if !empty(EKO->EKO_INFOAD)
         jJsonLPCO["informacaoAdicional"] := EKO->EKO_INFOAD
      endif

      //jJsonLPCO["dataReferencia"] := FWTimeStamp(3) //Exemplo: 2019-04-14T08:48:50

      if oModForm <> nil .and. oModForm:hasProperty("modelo") .and. oModForm["modelo"]:hasProperty("requerCatalogoProduto")
         lReqCat := oModForm["modelo"]["requerCatalogoProduto"]
      endif

      jJsonLPCO["listaCamposFormulario"] := getCposFrm( "listaCamposFormulario",;
                                                        "",;
                                                        oModForm,;
                                                        "listaCamposFormulario",;
                                                        .F.)

      aListaNCM := getListaNcm( @oFormLPCO, oModForm["listaNcm"], lReqCat)
      if len(aListaNCM) > 0 
         jJsonLPCO["listaNcm"] := aListaNCM
      endif

       if oModForm:hasProperty('exigeNumeroLI') .And. oModForm['exigeNumeroLI'] //Número da LI. É obrigatório quando o campo "exigeNumeroLI" do modelo for true.
          nNumLi := getNumLI(oModForm)//Pega o número da LI no jSon de Atributos
          jJsonLPCO["numeroLI"] := nNumLi
       endif

      getLog( space(11) + STR0045 + ": " + jJsonLPCO:toJson() + ENTER + ENTER , oLogView ) // "Mensagem de envio"

   endif

return jJsonLPCO


Static Function getNumLI(oModForm)
Local nRet := 0
Local cRet
Local oCampoLI := JsonObject():New()
Local oDadosLI

oCampoLI['listaCamposFormulario'] := {}
aAdd(oCampoLI['listaCamposFormulario'], JsonObject():New())
oCampoLI['listaCamposFormulario'][1]:fromJson(getJsonLI())

oDadosLI := getCposFrm( "listaCamposFormulario", "", oCampoLI, "listaCamposFormulario", .F.)
If Len(oDadosLI) > 0 .And. oDadosLI[1]:hasProperty("codigo") .And. oDadosLI[1]["codigo"] == "EXIGENUMEROLI" .And. oDadosLI[1]:hasProperty("listaValor")
   cRet := strtran(oDadosLI[1]["listaValor"][1],'/')
   cRet := strtran(cRet,'-')
   nRet := val(cRet)
EndIf
FreeObj(oCampoLI)
freeObj(oDadosLI)
Return nRet

Static Function getJsonLI()
Local cCampoLI := ""
cCampoLI := '{'+;
	'"codigo": "EXIGENUMEROLI",'+;
	'"nome": "Número da LI",'+;
	'"unidadeMedida": null,'+;
	'"tipo": "TEXTO",'+;
	'"validacao": {'+;
	'	"obrigatorio": true,'+;
	'	"permiteMultiplosValores": false,'+;
	'	"mascara": "99/9999999-9",'+;
	'	"tamanhoMaximo": 12,'+;
	'	"qtdCasasDecimais": null,'+;
	'	"dominios": []'+;
	'},'+;
	'"condicaoPreenchimento": null,'+;
	'"codigoAtributoPai": null,'+;
	'"subatributos": [],'+;
	'"orientacao": "Preencher com um texto que atenda à máscara."'+;
	'}'
Return cCampoLI

/*/{Protheus.doc} getFormLPCO
   Função para retornar o template que especifica a estrutura de um formulário de um LPCO

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param oFormLPCO, objeto, hash com os formularios obtidos das tabelas EKL e EKM
          cOrgao, caractere, orgão anuente
          cForm, caractere, modelo de formulário
   @return oJson, json, formulário em formato json, caso não encontre ou tenha problema será retorando nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function getFormLPCO(oFormLPCO, cOrgao, cForm)
   local oJson      := nil
   local lMemoria   := .F.

   default oFormLPCO  := tHashMap():New()
   default cOrgao     := EKO->EKO_ORGANU
   default cForm      := EKO->EKO_FRMLPC

   lMemoria := oFormLPCO:Get( xFilial("EKL") + cOrgao + cForm , oJson) .and. valtype(oJson) == "J"

   if !lMemoria .and. EKL->(dbSeek( xFilial("EKL") + cOrgao + cForm))
      oJson := JsonObject():New()
      if !empty(EKL->EKL_FORMJS) .and. valtype(oJson:FromJson(EKL->EKL_FORMJS)) == "U"
         oFormLPCO:set( xFilial("EKL") + cOrgao + cForm , oJson)
      endif
   endif

return oJson

/*/{Protheus.doc} getCposFrm
   Função para gerar a lista de campos, utilizado em listaCamposFormulario, listaCamposNcm e listaAtributosNcm (CampoLpcoRequest)

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cIdCpo, caractere, Identificação do campo - EKP_IDCPOF
          cSequen, caractere, Sequencia do campo - EKP_SQCPOF
          oForm, objeto, Json com a lista de campos ou atributos listaCamposFormulario, listaCamposNcm e listaAtributosNcm
          cPropCpos, caractere, Propriedade do objeto oForm que contém a lista de campos
          lVlrComp, logico, .T. se for um campo composto (Lista de Atributos Compostos)
          lMultVal, logico, .T. se for um campo que permite múltiplos valores (Lista de Atributos Compostos)
          lOperador, logico, .T. se está posicionado na EKF dados do operador estrangeiro vinculado ao catalogo de produto (listaCamposNcm)
          cRaizProd, caractere, CNPJ Raiz do catalogo de produto (listaCamposNcm)

   @return aListCpos, vetor, array com a lista de campos formatado para envio
   @example
   (examples)
   @see (links_or_references)
/*/
static function getCposFrm( cIdCpo, cSequen, oForm, cPropCpos, lVlrComp, lMultVal, lOperador, cCnpjRaiz )
   local aListCpos  := {}
   local nTamCpo    := 0
   local oFormCpos  := nil
   local nList      := 0
   local cCodigo    := ""
   local cTipo      := ""
   local jJsonVld   := nil
   local lMultValor := .F.
   local cAtribSup  := ""
   local lSubAtrib  := .T.
   local lSeekEKP   := .F.
   local jJsonAtt   := nil
   local nRecEKP

   default cIdCpo     := EKP->EKP_IDCPOF
   default cSequen    := EKP->EKP_SQCPOF
   default cPropCpos  := ""
   default lVlrComp   := .F.
   default lMultVal   := .F.
   default lOperador  := .F.
   default cCnpjRaiz  := ""

   cIdCpo := PadR(cIdCpo, getSX3Cache("EKP_IDCPOF","X3_TAMANHO"))
   cSequen := PadR(cSequen, getSX3Cache("EKP_SQCPOF","X3_TAMANHO"))
   nTamCpo := getSX3Cache("EKP_CDCPOF","X3_TAMANHO")

   if oForm <> nil .and. oForm:hasProperty(cPropCpos)
      oFormCpos := oForm[cPropCpos]
      for nList := 1 to len( oFormCpos )

         cCodigo := alltrim(oFormCpos[nList]["codigo"])
         cTipo := alltrim(oFormCpos[nList]["tipo"])
         jJsonVld := oFormCpos[nList]["validacao"]
         lMultValor := jJsonVld["permiteMultiplosValores"]
         cAtribSup := ""
         if !(oFormCpos[nList]["codigoAtributoPai"] == "null")
            cAtribSup := oFormCpos[nList]["codigoAtributoPai"]
         endif

         lSubAtrib := cTipo == "ATRIBUTO_COMPOSTO"  .or. cCodigo == "INDICACAO_IMPORTACAO_TERCEIROS" .or. cCodigo == "EXPORTADOR_ESTRANGEIRO" .or. ;
                      cCodigo == "EXPORTADOR_E_FABRICANTE_DO_PRODUTO" .or. cCodigo == "FABRICANTE_PRODUTOR" .or. ;
                      cCodigo == "FUNDAMENTO_LEGAL"

         lSeekEKP := .F.

         if lSubAtrib .or. (lSeekEKP := EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + cIdCpo + cSequen + PadR(cCodigo,nTamCpo) ))) // EKP_FILIAL+EKP_ID+EKP_VERSAO+EKP_IDCPOF+EKP_SQCPOF+EKP_CDCPOF

            jJsonAtt := JsonObject():New()
            jJsonAtt[if(lVlrComp, "atributo","codigo")] := cCodigo

            if lSubAtrib

               if cCodigo == "FUNDAMENTO_LEGAL"
                  EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + cIdCpo + cSequen + PadR(cCodigo,nTamCpo) ))
               endif

               // ReferenciaValorComposto - Estrutura que guarda o valor de um campo composto de um LPCO. Apenas um dos campos desta estrutura estará preenchido, dependendo do tipo do campo.
               jJsonAtt["valorComposto"] := getVlrComp( cIdCpo, cSequen, cCodigo, cTipo, oFormCpos[nList], lMultValor, lOperador, cCnpjRaiz )

            elseif lVlrComp
               if lSeekEKP
                  jJsonAtt["valor"] := getValor( alltrim(EKP->EKP_VLCPOF), jJsonVld, lMultVal, cTipo )
               endif

            else
               if lSeekEKP
                  jJsonAtt["listaValor"] := getListVlr( alltrim(EKP->EKP_VLCPOF), jJsonVld, lMultVal, cTipo )
               endif

            endif

            if !lVlrComp

                if cCodigo == "QTDE_COMERCIALIZADA"
                  nRecEKP := EKP->(Recno())
                  If EKP->(dbSeek(xFilial('EKP') + EKO->EKO_ID + EKO->EKO_VERSAO + cIdCpo + cSequen + PadR(cCodigo + "_UNIDADEMEDIDA",nTamCpo)))
                     jJsonAtt["unidadeMedida"] := AllTrim(EKP->EKP_VLCPOF) // Unidade de medida utilizada no campo. Necessário apenas para campos QTD_COMERCIALIZADA
                  EndIf
                  EKP->(dbGoTo(nRecEKP))
                endif

               if !empty(cAtribSup)
                  jJsonAtt["codigoAtributoPai"] := cAtribSup // Código do atributo condicionante
               endif

            endif

            aAdd( aListCpos, jJsonAtt )

         endif

      next
   endif

return aListCpos

/*/{Protheus.doc} getVlrComp
   Função para gerar a lista de atributos compostos ou especificos
      ReferenciaValorAtributoComposto - Valor de um campo composto do tipo Atributo Composto
      ReferenciaImportacaoTerceiro - Valor de um campo composto do tipo Indicação de importação para terceiros
      ReferenciaOperadorEstrangeiro - Referência a um Operador Estrangeiro referenciado em um LPCO. Pode ser um exportador estrangeiro ou um fabricante estrangeiro
      ReferenciaExportadorEFabricanteDoProduto - Valor de um campo composto do tipo Exportador é o fabricante do produto
      ReferenciaFabricante - Valor de um campo composto do tipo Fabricante/Produtor
      ReferenciaValorCampoFundamentoLegal - Valor de um campo composto do tipo Fundamento Legal. Consultar valores disponível pelo sistema Tratamento Tributário

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cIdCpo, caractere, Identificação do campo - EKP_IDCPOF
          cSequen, caractere, Sequencia do campo - EKP_SQCPOF
          cCodigo, caractere, Código de identificação do campo
          cTipo, caractere, Tipo da informação recebida pelo campo
          oForm, objeto, Json com a lista de campos ou atributos listaCamposFormulario, listaCamposNcm e listaAtributosNcm
          lMultVal, logico, .T. se for um campo que permite múltiplos valores (Lista de Atributos Compostos)
          lOperador, logico, .T. se está posicionado na EKF dados do operador estrangeiro vinculado ao catalogo de produto (listaCamposNcm)
          cRaizProd, caractere, CNPJ Raiz do catalogo de produto (listaCamposNcm)
   @return jJsonComp, obejto, Json com os valores do valorComposto
   @example
   (examples)
   @see (links_or_references)
/*/
static function getVlrComp( cIdCpo, cSequen, cCodigo, cTipo, oForm, lMultVal, lOperador, cCnpjRaiz )
   local jJsonComp   := nil

   jJsonComp := JsonObject():New()

   do case

      case cTipo == "ATRIBUTO_COMPOSTO"
         // ReferenciaValorAtributoComposto - Valor de um campo composto do tipo Atributo Composto
         jJsonComp["listaComposicaoAtributo"] := getSubAtrb( cIdCpo, cSequen, oForm, lMultVal)

      case cTipo == "IMPORTACAO_TERCEIROS" // "codigo": "INDICACAO_IMPORTACAO_TERCEIROS"
         // ReferenciaImportacaoTerceiro - Valor de um campo composto do tipo Indicação de importação para terceiros
         jJsonComp["indicacaoImportacaoTerceiros"] := getIndTer(0)

      case cTipo == "FABRICANTE" // "codigo": "FABRICANTE_PRODUTOR"
         // ReferenciaFabricante - Valor de um campo composto do tipo Fabricante/Produtor
         jJsonComp["fabricante"] := getFabProd(lOperador, cCnpjRaiz)
         
      case cTipo == "OPERADOR_ESTRANGEIRO" // "codigo": "EXPORTADOR_ESTRANGEIRO" ou "codigo": "EXPORTADOR_E_FABRICANTE_DO_PRODUTO"
         if cCodigo == "EXPORTADOR_E_FABRICANTE_DO_PRODUTO"
            // ReferenciaExportadorEFabricanteDoProduto - Valor de um campo composto do tipo Exportador é o fabricante do produto
            jJsonComp["exportadorEFabricanteDoProduto"] := getExpFabP(lOperador, cCnpjRaiz)

         //else // implementação futura
            // ReferenciaOperadorEstrangeiro - Referência a um Operador Estrangeiro referenciado em um LPCO. Pode ser um exportador estrangeiro ou um fabricante estrangeiro
            //if lOperador .and. !empty(EKF->EKF_CODFAB) .and. !empty(EKF->EKF_LOJA) .and. EKJ->(dbSeek( xFilial("EKJ") + cCnpjRaiz + EKF->EKF_CODFAB + EKF->EKF_LOJA))
            //   jJsonComp["exportadorEstrangeiro"] := getOperEst(EKJ->EKJ_TIN, EKJ->EKJ_CNPJ_R, EKJ->EKJ_PAIS, EKJ->EKJ_VERSAO)   
            //endif
         endif

      case cTipo == "FUNDAMENTO_LEGAL" // "codigo": "FUNDAMENTO_LEGAL"
         jJsonComp["fundamentoLegal"] := getFundLeg()
      
   end case

return jJsonComp

/*/{Protheus.doc} getSubAtrb
   Função para gerar json do ReferenciaValorAtributoComposto - Valor de um campo composto do tipo Atributo Composto

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cIdCpo, caractere, Identificação do campo - EKP_IDCPOF
          cSequen, caractere, Sequencia do campo - EKP_SQCPOF
          oSubAtrib, objeto, Lista de subatributos que compõem o campo quando for um atributo composto
          lMultVal, logico, .T. se for um campo que permite múltiplos valores (Lista de Atributos Compostos)
   @return aRetLstSub, array, Vetor com os valores do atributo ou campo formatado para envio
   @example
   (examples)
   @see (links_or_references)
/*/
static function getSubAtrb( cIdCpo, cSequen, oSubAtrib, lMultVal)
   local aListSub   := {}
   local aRetLstSub := {}

   default cIdCpo     := EKP->EKP_IDCPOF
   default cSequen    := EKP->EKP_SQCPOF

   aListSub := getCposFrm( PadR( cIdCpo, getSX3Cache("EKP_IDCPOF","X3_TAMANHO") ),;
                           PadR( cSequen, getSX3Cache("EKP_SQCPOF","X3_TAMANHO") ),;
                           oSubAtrib,;
                           "subatributos",;
                           .T.,;
                           lMultVal)

   aRetLstSub := {aListSub}

return aRetLstSub

/*/{Protheus.doc} getValor
   Função para tratamento dos valores dos subatributos

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cValor, caractere, Valor do campo ou atributo
          jJsonVld, json, Características do campo ou atributo
          lMultVal, logico, .T. se for um campo que permite múltiplos valores (Lista de Atributos Compostos)
   @return cValor, caractere, Valor do campo ou atributo formatado para envio
   @example
   (examples)
   @see (links_or_references)
/*/
static function getValor( cValor, jJsonVld, lMultVal, cTipo )
return format(cValor, jJsonVld, cTipo)

/*/{Protheus.doc} getListVlr
   Função para tratamento dos valores do campo ou atributos

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cValor, caractere, Valor do campo ou atributo
          jJsonVld, json, Características do campo ou atributo
          lMultVal, logico, .T. se for um campo que permite múltiplos valores (Lista de Atributos Compostos)
   @return cValor, caractere, Valor do campo ou atributo formatado para envio
   @example
   (examples)
   @see (links_or_references)
/*/
static function getListVlr( cValor, jJsonVld, lMultVal, cTipo )
return {format(@cValor, jJsonVld, cTipo)}

/*/{Protheus.doc} getListaNcm
   Função para gerar a lista de NCM do LPCI (ItemLpcoInserirRequest) - Dados um item de um LPCO a ser cadastrado

   Lista dos itens do LPCO. Contém campos como NCM e código do produto de cada item do LPCO, entre outros.
   {
      "ncm": "01012100", -> Código da NCM do item do LPCO.
      "produto": { -> Produto -> Referência a um produto utilizado em um item de um LPCO
         "codigo": 12, -> Código do produto do item do LPCO
         "versao": "string", -> Versão do produto
         "cnpjRaiz": "33683111" -> Raiz do CNPJ do fabricante do produto
      },
      "listaCamposNcm": [], -> CampoLpcoRequest - Lista de campos de cada item do LPCO exigidos pelo modelo. Para campos de valor composto (como Fabricante/Produtor, Exportador estrangeiro, Exportador é o fabricante do Produto, Fundamento legal, Indicação de importação para terceiros), verifique a estrutura específica de valor do campo.
      "listaAtributosNcm": [] -> CampoLpcoRequest - Lista de atributos dinâmicos da NCM (varia de NCM para NCM). Essa lista de atributos da NCM pode ser obtida no endpoint /ext/lpco/modelo/{codigoModelo}/{ncm}.
   }

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param oFormLPCO, objeto, hash com os formularios obtidos das tabelas EKL e EKM
          oListForm, objeto, Lista de campos ou atributos do modelo de formulário
          lReqCat, logico, .T. se o modelo de formulário requer catalogo de produto
   @return aListaNCM, vetor, array com a lista de campos para a NCM formatado para envio
   @example
   (examples)
   @see (links_or_references)
/*/
static function getListaNcm(oFormLPCO, oListForm, lReqCat)
   local aListaNCM  := {}
   local cOrgao     := EKO->EKO_ORGANU
   local cForm      := EKO->EKO_FRMLPC
   local cAliasQry  := ""
   local cQuery     := ""
   local oQuery     := nil
   local oFormNCM   := nil
   local nTamId     := 0
   local nTamSeq    := 0
   local nTamCpo    := 0
   local cNCM       := ""
   local cSeq       := ""
   local jJsonNCM   := nil
   local jJsonProd  := nil
   local cIdPortPrd := ""
   local cCodProd   := ""
   local cVersProd  := ""
   local cRaizProd  := ""
   local lOperador  := .F.

   Private cIntCpfCnpj := ""

   cAliasQry  := getNextAlias()

   cQuery := " SELECT EKP.EKP_SQCPOF, EKP.EKP_CDCPOF "
   cQuery += " FROM  " + RetSqlName("EKP") + " EKP "
   cQuery += " WHERE EKP.D_E_L_E_T_= ' ' AND EKP.EKP_FILIAL = ? "
   cQuery += " AND EKP.EKP_ID       = ? "
   cQuery += " AND EKP.EKP_VERSAO   = ? "
   cQuery += " AND EKP.EKP_IDCPOF   = 'NCM' "
   cQuery += " ORDER BY EKP_SQCPOF, EKP_CDCPOF "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1, xFilial("EKP"))
   oQuery:SetString(2, EKO->EKO_ID)
   oQuery:SetString(3, EKO->EKO_VERSAO)
   cQuery := oQuery:GetFixQuery()

   fwFreeObj(oQuery)

   MPSysOpenQuery(cQuery, cAliasQry)

   nTamId := getSX3Cache("EKP_IDCPOF","X3_TAMANHO")
   nTamSeq := getSX3Cache("EKP_SQCPOF","X3_TAMANHO")
   nTamCpo := getSX3Cache("EKP_CDCPOF","X3_TAMANHO")

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!Eof())

      cNCM := alltrim((cAliasQry)->EKP_CDCPOF)
      cSeq := alltrim((cAliasQry)->EKP_SQCPOF)
      oFormNCM := getFormNCM(@oFormLPCO, cOrgao, cForm, cNCM)
      jJsonProd := nil
      cIdPortPrd := ""
      cCodProd := ""
      cVersProd := ""
      cRaizProd := ""
      lOperador := .F.

      if EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + PadR("IDPORTAL",nTamId) + PadR(cSeq,nTamSeq) )) // EKD_IDPORT
         cIdPortPrd := alltrim(EKP->EKP_CDCPOF)
      endif

      if EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + PadR("VERSAO",nTamId) + PadR(cSeq,nTamSeq) )) // EKD_VATUAL
         cVersProd := alltrim(EKP->EKP_CDCPOF)
      endif

      if EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + PadR("CNPJ",nTamId) + PadR(cSeq,nTamSeq) )) // EKD_CNPJ
         cRaizProd := alltrim(EKP->EKP_CDCPOF)
      endif

      if EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + PadR("PRODUTO",nTamId) + PadR(cSeq,nTamSeq) )) // EKD_COD_I
         cCodProd := alltrim(EKP->EKP_CDCPOF)
      endif

      cIntCpfCnpj:= cRaizProd
      If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICLP402_INTEGRAR"),)
      cRaizProd:= cIntCpfCnpj

      if !empty(cIdPortPrd) .and. !empty(cVersProd) .and. !empty(cRaizProd) .and. lReqCat
         jJsonProd := JsonObject():New()
         jJsonProd["codigo"] := cIdPortPrd
         jJsonProd["versao"] := cVersProd
         jJsonProd["cnpjRaiz"] := cRaizProd
         lOperador := posOperador(cNCM, jJsonProd["codigo"], jJsonProd["versao"])
      endif

      jJsonNCM := JsonObject():New()
      jJsonNCM["ncm"] := cNCM

      if jJsonProd <> nil
         jJsonNCM["produto"] := jJsonProd
      endif

      if oFormNCM <> nil

         if EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + PadR("listaCamposNcm",nTamId) + PadR(cSeq,nTamSeq) ))
            jJsonNCM["listaCamposNcm"] := getCposFrm( "listaCamposNcm",;
                                                      cSeq,;
                                                      oFormNCM,;
                                                      "listaCamposNcm",;
                                                      .F.,;
                                                      ,;
                                                      lOperador,;
                                                      cRaizProd)
         endif

         if EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + PadR("listaAtributosNcm",nTamId) + PadR(cSeq,nTamSeq) ))
            jJsonNCM["listaAtributosNcm"] := getCposFrm( "listaAtributosNcm",;
                                                         cSeq,;
                                                         oFormNCM,;
                                                         "listaAtributosNcm",;
                                                         .F.,;
                                                         ,;
                                                         lOperador,;
                                                         cRaizProd)
         endif

      elseif oListForm <> nil

         if EKP->(dbSeek( xFilial("EKP") + EKO->EKO_ID + EKO->EKO_VERSAO + PadR("listaCamposNcm",nTamId) + PadR(cSeq,nTamSeq) ))
            jJsonNCM["listaCamposNcm"] := getCposFrm( "listaCamposNcm",;
                                                      cSeq,;
                                                      oListForm,;
                                                      "listaCamposNcm",;
                                                      .F.,;
                                                      ,;
                                                      lOperador,;
                                                      cRaizProd)

         endif

      endif

      aAdd( aListaNCM, jJsonNCM )

      (cAliasQry)->(dbSkip())
   end
   (cAliasQry)->(dbCloseArea())

return aListaNCM

/*/{Protheus.doc} getFormNCM
   Função para retornar o template que especifica a estrutura de um item de um formulário de um LPCO

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param oFormLPCO, objeto, hash com os formularios obtidos das tabelas EKL e EKM
          cOrgao, caractere, orgão anuente
          cForm, caractere, modelo de formulário
          cNCM, caractere, ncm
   @return oJson, json, formulário em formato json, caso não encontre ou tenha problema será retorando nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function getFormNCM(oFormLPCO, cOrgao, cForm, cNCM)
   local oJson      := nil
   local lMemoria   := .F.

   default oFormLPCO  := tHashMap():New()
   default cOrgao     := EKO->EKO_ORGANU
   default cForm      := EKO->EKO_FRMLPC
   default cNCM       := ""

   lMemoria := oFormLPCO:Get( xFilial("EKM") + cOrgao + cForm + cNCM , oJson) .and. valtype(oJson) == "J"

   if !lMemoria .and. EKM->(dbSeek( xFilial("EKM") + cOrgao + cForm + cNCM ))
      oJson := JsonObject():New()
      if !empty(EKM->EKM_FRMDEF) .and. valType( oJson:FromJson(EKM->EKM_FRMDEF) ) == "U"
         oFormLPCO:set( xFilial("EKL") + cOrgao + cForm , oJson)
      endif
   endif

return oJson

/*/{Protheus.doc} format
   Função para formatar a informação do atributo de acordo com seu tipo

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cInfo, caractere, valor do atributo
          jJsonVld, objeto, propriedades do atributo ou campo
   @return xRet, indefinido, valor do atributo formatado
   @example
   (examples)
   @see (links_or_references)
/*/
static function format(cInfo, jJsonVld, cTipo)
   local xRet       := nil

   default cTipo    := ""

   if cTipo == "DATA"
      xRet := Transform(stod(strtran(cInfo, "-", "")),"@D")

   elseif cTipo == "BOOLEANO"
      xRet := if( alltrim(xRet) == ".T." .or. alltrim(xRet) == "true", "true", "false")

   else
      xRet := alltrim(cInfo)
      if cTipo == "TEXTO" .and. !empty(xRet) .and. jJsonVld <> nil .and. jJsonVld:hasProperty("mascara") .and. jJsonVld["mascara"] <> nil
         xRet := Transform(xRet,"@R " + jJsonVld["mascara"])
      endif
   endif

return xRet

/*/{Protheus.doc} PosOperador
   Função para posicionar no operador estrangeiro vinculado ao catalogo de produto EKF

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cNCM, numerico, NCM do Catalogo de Produto
          cIdPortPrd, caractere, Código do Catalogo de Produto
          cVersao, caractere, Versão do Catalogo de Produto
   @return jJsonOper, json, json do ReferenciaImportacaoTerceiro
   @example
   (examples)
   @see (links_or_references)
/*/
static function PosOperador(cNCM, cIdPortPrd, cVersao)
   local lPosOper := .F.

   default cNCM       := ""
   default cIdPortPrd := ""
   default cVersao    := ""

   if EKD->(dbSeek( xFilial("EKD") + PadR(cNCM,len(EKD->EKD_NCM)) + PadR(cIdPortPrd, len(EKD->EKD_IDPORT)) + PadR(cVersao, len(EKD->EKD_VATUAL)) ))
      if EKF->(dbSeek( xFilial("EKF") + EKD->EKD_COD_I + EKD->EKD_VERSAO ) ) 
         while EKF->(!eof()) .and. EKF->(EKF_FILIAL+EKF_COD_I+EKF_VERSAO) == xFilial("EKF") + EKD->EKD_COD_I + EKD->EKD_VERSAO
            if EKF->EKF_VINCFB == "4" .or. EKD->EKD_STATUS == "6" // 4=Vinculado ao catálogo ou 6=Registrado Manualmente
               lPosOper := .T.
               exit
            endif
            EKF->(dbSkip())
         end
      endif
   endif

return lPosOper

/*/{Protheus.doc} getIndTer
   Função para gerar json do ReferenciaImportacaoTerceiro - Valor de um campo composto do tipo Indicação de importação para terceiros

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param nIndicador, numerico, Código do indicador: 0: Importação Direta, 1: Importação por Conta e Ordem, 2: Importação por Encomenda
          cCpfCnpj, caractere, CPF / CNPJ do adquirente / encomendante. Não deve ser informado no caso de importação direta
   @return jJsonOper, json, json do ReferenciaImportacaoTerceiro
   @example
   (examples)
   @see (links_or_references)
/*/
static function getIndTer(nIndicador, cCpfCnpj)
   local jIndImpTer := nil

   default nIndicador := 0
   default cCpfCnpj   := ""

   // ReferenciaImportacaoTerceiro - Valor de um campo composto do tipo Indicação de importação para terceiros
   if nIndicador == 0 .or. !empty(cCpfCnpj)

      jIndImpTer := JsonObject():New()
      jIndImpTer["codigoIndicador"] := nIndicador // Código do indicador: 0: Importação Direta, 1: Importação por Conta e Ordem, 2: Importação por Encomenda.

      if( !(nIndicador == 0) , jIndImpTer["cpfCnpj"] := alltrim(cCpfCnpj), nil ) // CPF / CNPJ do adquirente / encomendante. Não deve ser informado no caso de importação direta.

   endif

return jIndImpTer

/*/{Protheus.doc} getOperEst
   Função para gerar json do ReferenciaOperadorEstrangeiro - Referência a um Operador Estrangeiro referenciado em um LPCO. Pode ser um exportador estrangeiro ou um fabricante estrangeiro

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param cCodigo, caractere, Código do operador estrangeiro
          cCpfCnpj, caractere, CNPJ raiz do operador estrangeiro
          cCodPais, caractere, Código na Tabela ISO2 do país do operador estrangeiro
          cVersao, caractere, Versão do operador estrangeiro
   @return jJsonOper, json, json do ReferenciaOperadorEstrangeiro
   @example
   (examples)
   @see (links_or_references)
/*/
static function getOperEst(cCodigo, cCpfCnpj, cCodPais, cVersao)
   local jJsonOper := nil

   default cCodigo   := ""
   default cCpfCnpj  := ""
   default cCodPais  := ""
   default cVersao   := ""

   // ReferenciaOperadorEstrangeiro - Referência a um Operador Estrangeiro referenciado em um LPCO. Pode ser um exportador estrangeiro ou um fabricante estrangeiro
   jJsonOper := JsonObject():New()
   jJsonOper["codigo"] := alltrim(cCodigo) // Código do operador estrangeiro
   jJsonOper["cpfCnpjRaiz"] := alltrim(cCpfCnpj) // CNPJ raiz do operador estrangeiro
   jJsonOper["codigoPais"] := alltrim(cCodPais) // Código na Tabela ISO2 do país do operador estrangeiro
   jJsonOper["versao"] := alltrim(cVersao) // Versão do operador estrangeiro

return jJsonOper

/*/{Protheus.doc} getExpFabP
   Função para gerar json do ReferenciaExportadorEFabricanteDoProduto - Valor de um campo composto do tipo Exportador é o fabricante do produto

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param lOperador, logico, .T. se está posicionado na EKF dados do operador estrangeiro vinculado ao catalogo de produto (listaCamposNcm)
          cRaizProd, caractere, CNPJ Raiz do catalogo de produto (listaCamposNcm)
   @return jExpFabPrd, json, json do ReferenciaExportadorEFabricanteDoProduto
   @example
   (examples)
   @see (links_or_references)
/*/
static function getExpFabP(lOperador, cCnpjRaiz)
   local jExpFabPrd := nil
   local lExpFab    := .T.

   default lOperador  := .F.
   default cCnpjRaiz  := ""

   // ReferenciaExportadorEFabricanteDoProduto - Valor de um campo composto do tipo Exportador é o fabricante do produto
   jExpFabPrd := JsonObject():New()
   jExpFabPrd["exportadorIgualFabricante"] := lExpFab // Indica se é o exportador é igual ao fabricante do produto.
   //if lOperador .and. !empty(EKF->EKF_CODFAB) .and. !empty(EKF->EKF_LOJA) .and. EKJ->(dbSeek( xFilial("EKJ") + cCnpjRaiz + EKF->EKF_CODFAB + EKF->EKF_LOJA))
   //   jExpFabPrd["operadorEstrangeiro"] := getOperEst(EKJ->EKJ_TIN, EKJ->EKJ_CNPJ_R, EKJ->EKJ_PAIS, EKJ->EKJ_VERSAO) // ReferenciaOperadorEstrangeiro - Referência a um Operador Estrangeiro referenciado em um LPCO. Pode ser um exportador estrangeiro ou um fabricante estrangeiro
   //endif


return jExpFabPrd

/*/{Protheus.doc} getFabProd
   Função para gerar json do ReferenciaFabricante - Valor de um campo composto do tipo Fabricante/Produtor

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param lOperador, logico, .T. se está posicionado na EKF dados do operador estrangeiro vinculado ao catalogo de produto (listaCamposNcm)
          cRaizProd, caractere, CNPJ Raiz do catalogo de produto (listaCamposNcm)
   @return jFabricant, json, json do ReferenciaFabricante
   @example
   (examples)
   @see (links_or_references)
/*/
static function getFabProd(lOperador, cCnpjRaiz)
   local jFabricant := nil
   local lConhecido := .F.
   local cCodPaisFb := ""
   local cCpfCnpjFb := ""

   default lOperador  := .F.
   default cCnpjRaiz  := ""

   if lOperador

      lConhecido := !empty(EKF->EKF_CODFAB) .and. !empty(EKF->EKF_LOJA) .and. EKJ->(dbSeek( xFilial("EKJ") + cCnpjRaiz + EKF->EKF_CODFAB + EKF->EKF_LOJA))
      cCodPaisFb := EKF->EKF_PAIS
   
      // ReferenciaFabricante - Valor de um campo composto do tipo Fabricante/Produtor
      jFabricant := JsonObject():New()
      jFabricant["codigoPais"] := alltrim(cCodPaisFb) // Código na Tabela ISO2 do país do fabricante.
      jFabricant["conhecido"] := lConhecido // Indica se é um fabricante conhecido

      if( !empty(cCpfCnpjFb), jFabricant["cpfCnpj"] := alltrim(cCpfCnpjFb), nil) // CPF / CNPJ do fabricante. Só deve ser informado se for um fabricante nacional

      if lConhecido 
         jFabricant["operadorEstrangeiro"] := getOperEst(EKJ->EKJ_TIN, EKJ->EKJ_CNPJ_R, EKJ->EKJ_PAIS, EKJ->EKJ_VERSAO) // ReferenciaOperadorEstrangeiro - Referência a um Operador Estrangeiro referenciado em um LPCO. Pode ser um exportador estrangeiro ou um fabricante estrangeiro
      endif

   endif

return jFabricant

/*/{Protheus.doc} getFundLeg
   Função para gerar json do ReferenciaValorCampoFundamentoLegal - Valor de um campo composto do tipo Fundamento Legal. Consultar valores disponível pelo sistema Tratamento Tributário

   @type  Static Function
   @author user
   @since 11/01/2024
   @version version
   @param nenhum
   @return jJsonComp, objeto, Json com os valores do valorComposto
   @example
   (examples)
   @see (links_or_references)
/*/
static function getFundLeg( )
   local jFundLegal := nil

   // ReferenciaValorCampoFundamentoLegal -Valor de um campo composto do tipo Fundamento Legal. Consultar valores disponível pelo sistema Tratamento Tributário
   jFundLegal := JsonObject():New()
   jFundLegal["codigoFundamento"] := alltrim(EKP->EKP_VLCPOF)

return jFundLegal

/*/{Protheus.doc} addLpcos
   Inclusão dos LPCOs para integração

   @type  Static Function
   @author user
   @since 24/11/2023
   @version version
   @param oEasyJS, objeto, EasyJS
          cErros, caracter, variavel de erro
          cJson, caracter, JSON de envio
          ctn, numerico, contador
   @return cRet, caracter, retorno da execução
/*/
static function addLpcos(oEasyJS, cErros, cJson, ctn)
   local cScript := ""

   begincontent var cScript
		addLpcos(%Exp:cJson%, retAdvpl, retAdvplChunk, retAdvplError)
   endcontent

   oEasyJS:runJS( cScript , {|x| ctn := ctn+1} ,  {|x| lErroGrave := .T., cErros := x } )
   //oEasyJS:runJS("addLpcos(retAdvpl,'" + cLPCOProc + "')" , {|x| ctn := ctn+1} ,  {|x| cErros := x } )

return
