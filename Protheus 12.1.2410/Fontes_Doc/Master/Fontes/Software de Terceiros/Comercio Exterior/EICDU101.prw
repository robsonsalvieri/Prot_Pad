#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EICDU101.CH"
 
#define FAILED_FETCH "Failed to fetch"
#define DIAG_PROCESSAMENTO "Diagnóstico em processamento"
#define PROC_N_IMPED "PROCESSADO_ERRO_NAO_IMPEDITIVO Não há erros impeditivos para o registro"
#define PROC_S_IMPED "PROCESSADO_SEM_ERRO_IMPEDITIVO"
#define CAPA "CAPA"
#define ITEM "ITEM"
#define DIAGNOSTICO "DIAGNOSTICO"
#define REGISTRO "REGISTRO"
#define DELETE_DUIMP "DELETE_DUIMP"
#define VALOR_CALCULADO "VALOR_CALCULADO"
#define II     "201"
#define IPI    "202"
//#define ICMS   "203"
#define PIS    "204"
#define COFINS "205"

// define EV1_STATUS
#define PENDENTE_INTEGRACAO        "1"
#define PROCESSO_PENDENTE_REVISAO  "2"
#define PENDENTE_REGISTRO          "3"
#define DUIMP_REGISTRADA           "4"
#define OBSOLETO                   "5"
#define EM_PROCESSAMENTO           "6"

// define ENDPOINT Portal Unico
#define URL_AUTENTICAR "/portal/api/autenticar"

#define SUSPENSAO "1"
#define ISENCAO   "2"

static _nQtdeItem := 0
static _aItsDUIMP := {}
static _DIC_22_4  := nil
static _cRelease  := ""
static _cVrAgent  := ""

/*
Função     : DU101PrcInt
Objetivo   : Realiza o processo de integração com o Portal DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function DU101PrcInt(cAlias, nRecno, nOpc, cHawb, cLote)
   local lRet := .F.
   local aArea      := getArea()
   local cUrlInteg  := ""
   local bAction    := nil
   local bValid     := {|| getFecha()}
   local lCancelou  := .F.

   default cAlias     := "EV1"
   default nRecno     := EV1->(recno())
   default nOpc       := 0
   default cHawb      := EV1->EV1_HAWB
   default cLote      := EV1->EV1_LOTE

   Private lFecha := .F.
   
   aAreaEV1 := EV1->(getArea())
   if nRecno > 0
      EV1->(dbGoTo(nRecno))
   endif

   begin sequence

   if ( nOpc == 3 .or. nOpc == 4 ) //  INCLUIR ou INTEGRAR

      // Validação para verificar se o registro está com status pendente de integração
      If nOpc == 4 .and. !(EV1->EV1_STATUS == PENDENTE_INTEGRACAO)
         EasyHelp(STR0023, STR0003, "") // "A ação 'Integrar' só pode ser executada para registros com o status '1-Pendente de Integração'" ### "Atenção"
         break
      EndIf

      If nOpc == 4 
         jItens := DU100NewVs(cHawb, .T.)
         If Len(jItens['Itens']) > 0 .And.  MsgYesNo(STR0074 + ENTER+ENTER + STR0075, STR0003)//""###"Atenção"##"Existem catálogos de produtos registrados com versões mais recentes disponíveis."##"Deseja realizar uma atualização automática antes de continuar com a integração?"
            If !DU100UpdCat(cHawb, jItens, .F.) .Or. !DU100AtuDUIMP(cHawb, .F.)
               //EasyHelp(STR0076, STR0003, STR0077)//""###"Atenção"###"Não foi possível atualizar a versão do Catálogo de Produtos."###"Verifique o catálogo de produto informado no itens da DUIMP."
               break
            EndIf
         EndIf
      EndIf
      // Validação para procurar se há catálogos de produtos bloqueados nos itens da DUIMP
      If VerifCat(cHawb, cLote, "Bloqueado")
         EasyHelp(STR0078, STR0003, STR0079)//'Não é possível prosseguir pois existem catálogos de produtos bloqueados vinculados aos itens da DUIMP.'###'Atenção'###'Revise os catálogos e versões vinculados aos itens da DUIMP.'
         break
      EndIf

      If VerifCat(cHawb, cLote, "Pendente Retificação")
         If !MsgYesNo(STR0080 + CRLF + CRLF + STR0081, STR0003)//"Foram encontrados catálogos de produtos com status 3 - Pendente de Retificação."###"Atenção"###"Deseja prosseguir com os dados atuais?"
            break
         EndIf
      EndIf

      // Pergunta se deseja iniciar a integração
      If !MsgYesNo(STR0001 + CRLF + CRLF + STR0002, STR0003) // "Deseja iniciar a integração da Duimp com o Portal Único?" ### "Esta operação iniciará a gravação dos dados no Portal Único, o diagnóstico e o registro da Duimp." ### "Atenção"  
         break
      Endif
      bAction := {|x| IntegDuimp(x,cUrlInteg,cHawb,cLote)}

   elseif nOpc == 5 // EXCLUIR

      if EV1->EV1_STATUS $ PENDENTE_INTEGRACAO + "||" + PROCESSO_PENDENTE_REVISAO + "||" + PENDENTE_REGISTRO .and. !empty(EV1->EV1_DI_NUM) .and. !empty(EV1->EV1_VERSAO)
         bAction := {|x| IntDelete(x,cUrlInteg,cHawb,cLote)}
      endif

   elseif nOpc == 6 // REGISTRAR

      if EV1->EV1_STATUS == PENDENTE_REGISTRO
         if !MsgYesNo(STR0001 + CRLF + CRLF + STR0002, STR0003) // "Deseja iniciar a integração da Duimp com o Portal Único?" ### "Esta operação iniciará a gravação dos dados no Portal Único, o diagnóstico e o registro da Duimp." ### "Atenção"  
         break
         endif
      ElseIf EV1->EV1_STATUS == EM_PROCESSAMENTO
         if !MsgYesNo(STR0083 + CRLF + CRLF + STR0084, STR0003) // "O status atual do processo é "Registro em Processamento". A geração desta ação resultará na criação de uma nova versão da DUIMP no Portal Único para registro."####"Deseja confirmar o reenvio da solicitação de registro e prosseguir com esta operação?" ### "Atenção"  
            break
         endif
      Else
         EasyHelp( STR0082/*STR0036*/ , STR0003 , "") // "Ação permitida apenas para os status 'Pendente de Registro' e 'Registro em Processamento'." ### "Atenção" 
         break
      endif

      bAction := {|x| IntRegistro(x,cUrlInteg,cHawb,cLote)}

   elseif nOpc == 7 // Consultar Status
   
      if !(EV1->EV1_STATUS == EM_PROCESSAMENTO) // "Registro em processamento"
         EasyHelp(STR0064, STR0003, "") // "Ação permitida apenas para o status 'Registro em Processamento'" ### "Atenção" 
         break
      endif

      bAction := {|x| IntConsDuimp(x,cUrlInteg) }

   elseif nOpc == 99 //Exclusão executada pela inclusão de um novo registro com duimp ja em satatus 'em processamento
      
      if EV1->EV1_STATUS == EM_PROCESSAMENTO .and. !empty(EV1->EV1_DI_NUM) .and. !empty(EV1->EV1_VERSAO)
         bAction := {|x| lRet := IntDelete(x,cUrlInteg,cHawb,cLote, nOpc)}
      endif

   endif

   if !( bAction == nil )

      cUrlInteg := AVgetUrl(,,@lCancelou)
      if empty(cUrlInteg)
         if !lCancelou
            easyhelp(STR0026,STR0003,STR0027) // O parâmetro MV_EIC0072 ou MV_EIC0073 não estão preenchidos","ATENÇÃO","Informe o parâmetro MV_EIC0072(Produção) ou MV_EIC0073(Homologação) e tente novamente"
         endif
         break
      endif

      Eecview("",STR0003,,,bValid,.F.,.T.,bAction, .T.)

   endif

   end sequence

   restArea(aAreaEV1)
   restArea(aArea)

return lRet

/*
Função     : IntegDuimp
Objetivo   : Realiza a integração como portal único e atualiza o eecview
Parâmetro  :
Retorno    :
Autor      : Maurício Frison
Data/Hora  : Abril/2022
Obs.       :
*/
static function IntegDuimp(oLogView,cUrlInteg,cHawb,cLote)
local cRelease   := ""
local cURLAuth   := cUrlInteg + URL_AUTENTICAR
local oEasyJS    := EasyJS():New()
Local lIntgProd  := .F.
local aIntDel    := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntCapa   := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntItem   := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntDiag   := {.F.,.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio, 3o. Indica se passou pelo erro não impeditivo
local aIntVlr    := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntReg    := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntVlrIts := {.F.,.f.}
local lConsulta  := .F.

InitInt(@oLogView)

begin sequence

   if EV1->EV1_STATUS == PENDENTE_INTEGRACAO .and. VldCertDig(@oEasyJs,cUrlInteg,cUrlAuth,oLogView)

      lIntgProd := EasyGParam("MV_EIC0074",.F.,"1") == "1"
      if !lIntgProd 
         cRelease := getRelease()
      endif

      aIntDel := {.T.,.T.}
      // realiza a integração de exclusão da duimp somente caso seja produção, a versão do release menor que 12.1.2410 ou a versão do agente maior ou igual que 1.0.17
      if lIntgProd .or. cRelease < "12.1.2410" .or. !VldVersao(getVrAgent(),"1.0.17")
         aIntDel := {.F.,.F.}
         aIntDel := IntDelDUIMP(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      endif

      if aIntDel[1] .And. aIntDel[2]
         aIntCapa := IntegCapa(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break
      endif

      if aIntCapa[1] .And. aIntCapa[2]
         aIntItem:= IntegItens(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break
      EndIf

      if aIntCapa[1] .And. aIntCapa[2] .And. aIntItem[1] .And. aIntItem[2]
         //pega os impostos da duimp item a item
         aIntVlrIts := IntegVlrIts(oEasyJS, cUrlInteg, cHawb, cLote, EV1->(Recno()), oLogView )
      endif
      
      
      If aIntCapa[1] .And. aIntCapa[2] .And. aIntItem[1] .And. aIntItem[2] .and. aIntVlrIts[1] //garante que não houve erro de conexao e nem erro da camada de negócio
         aIntDiag := IntegDiagnostico(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break   
      EndIf        
      

      If aIntDiag[1] .And. aIntDiag[2]
         //pega os valores da capa da duimp
         aIntVlr := IntegVlrCalc(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break   
      EndIf   

      If aIntVlr[1] .And. aIntVlr[2]
         aIntReg := IntegRegistro(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView,aIntDiag[3])
      EndIf   

      if aIntReg[1] .And. aIntReg[2]
         lConsulta := IntConsDuimp(@oLogView, cUrlInteg, , , @oEasyJS)
      endif

   endif

end sequence

FinishInt(@oLogView, @oEasyJS)

Return nil

/*
Função     : IntDelete
Objetivo   : Realiza a integração como portal único enviando o DELETE da DUIMP e atualiza o eecview
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntDelete(oLogView,cUrlInteg,cHawb,cLote, nOperacao)
   local cURLAuth := cUrlInteg + URL_AUTENTICAR
   local oEasyJS  := nil
   local aIntDel  := {.F.,.F.} 

   default nOperacao := 0

   if (nOperacao == 99 .Or. EV1->EV1_STATUS $ PENDENTE_INTEGRACAO + "||" + PROCESSO_PENDENTE_REVISAO + "||" + PENDENTE_REGISTRO) .and. !empty(EV1->EV1_DI_NUM) .and. !empty(EV1->EV1_VERSAO)

      oEasyJS := EasyJS():New()

      InitInt(@oLogView)

      begin sequence

      if VldCertDig(@oEasyJs,cUrlInteg,cUrlAuth,@oLogView)

         aIntDel := IntDelDUIMP(@oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,@oLogView)

         if aIntDel[1] .And. aIntDel[2]
            AtuReg({"EV1_STATUS"}, {OBSOLETO} )
         endif

      endif

      end sequence

      FinishInt(@oLogView, @oEasyJS)

   endif

Return aIntDel[1] .And. aIntDel[2] //1o. Erro de conexão, 2o. Erro da camada de negócio

/*
Função     : IntRegistro
Objetivo   : Realiza a integração como portal único enviando o Diagnóstico e Registro da DUIMP e atualiza o eecview
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntRegistro(oLogView,cUrlInteg,cHawb,cLote)
   local cURLAuth    := cUrlInteg + URL_AUTENTICAR
   local cQrySWV     := nil
   local oEasyJS     := EasyJS():New()
   //local aIntDiag    := {.F.,.F., .F.}
   local aIntVlr     := {.F.,.F.}
   local aIntReg     := {.F.,.F.}
   local aIntVlrIts  := {.F.,.F.}
   local lConsulta   := .F.

   InitInt(@oLogView)

   begin sequence

   if (EV1->EV1_STATUS == PENDENTE_REGISTRO .Or. EV1->EV1_STATUS == EM_PROCESSAMENTO) .and. VldCertDig(@oEasyJs,cUrlInteg,cUrlAuth,@oLogView) .and. getItens(@cQrySWV, cHawb, .T.)
                  //pega os valores da duimp item a item
      aIntVlrIts := IntegVlrIts(oEasyJS, cUrlInteg, cHawb, cLote, EV1->(Recno()), oLogView) 
      /* retirado a pedido do Fabrício
      if aIntVlrIts[1]
         aIntDiag := IntegDiagnostico(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      endif
      */

      //If aIntDiag[1] .And. aIntDiag[2]
      if aIntVlrIts[1]
         //pega os valores da capa da duimp
         aIntVlr := IntegVlrCalc(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break   
      endif   

      if aIntVlr[1] .And. aIntVlr[2]
         //aIntReg := IntegRegistro(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView,aIntDiag[3])
         aIntReg := IntegRegistro(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView,.T.)
      endif 

      if aIntReg[1] .And. aIntReg[2]
         lConsulta := IntConsDuimp(@oLogView, cUrlInteg, , , @oEasyJS)
      endif

   endif

   end sequence

   FinishInt(@oLogView, @oEasyJS)

Return nil

/*
Função     : InitInt
Objetivo   : Início do processamento da integração com Portal Único
Parâmetro  : 
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function InitInt(oLogView)
   Local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   getLog(dToc(Date()) + '- ' + Time() + ' ' + STR0061 + if(lIntgProd, STR0062, STR0063) + ENTER, oLogView, .F.) // "Integração realizada no ambiente de " ### "Produção." #### "Treinamento."
   getLog(STR0008 + ' ' + UsrFullName(retCodUsr()) + ' - ' + STR0009,oLogView,.T.) // Usuário do sistema:' Início do processamento de integração da Duimp'
   _nQtdeItem := 0
   aSize(_aItsDUIMP, 0)
   _aItsDUIMP := {}
   _cRelease  := ""
   _cVrAgent  := ""
return nil

/*
Função     : FinishInt
Objetivo   : Fim do processamento da integração com Portal Único
Parâmetro  : 
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function FinishInt(oLogView, oEasyJS)
   getLog(STR0016,oLogView) //Fim do processamento  
   lFecha := .T.
   AtuReg({'EV1_LOGINT'},{eval(oLogView:bsetGet) + Replicate( "-", 120 ) + ENTER + ENTER + ENTER + EV1->EV1_LOGINT})
   oEasyJS:Destroy()
return nil

/*
Função     : getFecha
Objetivo   : Retorna a variável indicando se pode fechar a tela da integração ou não 
Parâmetro  : 
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getFecha()
return lFecha

/*
Função     : VldCertDig
Objetivo   : Realiza a validação do certificado digital 
Parâmetro  :
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
Static function VldCertDig(oEasyJs,cUrlInteg,cUrlAuth,oLogView)
   local lRet := .F.

   default oEasyJs   := EasyJS():New()
   default cUrlInteg := ""
   default cUrlAuth  := cUrlInteg + URL_AUTENTICAR

   oEasyJS:cUrl := cUrlAuth
   oEasyJS:AddLib( GetApoRes('ASYNC.JS') )
   oEasyJS:AddLib( EasyAppFetch(cUrlAuth) )
   oEasyJS:AddLib( DU101Script(cUrlInteg) )
   oEasyJS:setTimeOut(45)
   getLog(STR0010,oLogView) //Acessando o certificado digital
   lRet := oEasyJS:Activate(.T.) //Ativa a tela que solicita o certificado
   if !lRet
      getLog(STR0013,oLogView) //"Erro no certificado"
   EndIf

return lRet

/*
Função     : IntegRegistro
Objetivo   : Realiza a integração do registro da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegRegistro(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView,lErroNimp)
local cRet := '', cAtuReg:=''
local cUrlVlrCalc := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/registros"
local aRet := {.T.,.T.}    //[1] erro de conexão, [2] erro da camada de negócio  
local cBody := getRegJson(lErroNimp,cHawb)
Begin Sequence   
      getLog(STR0033 + ' ' + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // "Solicitando registro da Duimp:"
      //cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_REGISTRO + "'})" Neste caso não precisa alterar o status da duimp em caso de erro no certificado
      getLog(cBody,oLogView)  
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlVlrCalc , cBody,'POST',@aRet,oLogView,cAtuReg,.F.)
      getLog(cRet,oLogView)  
      ProcRetDuimp(cRet,@aRet,oLogView,REGISTRO,STR0034)    //"Houve algum problema no registro da DUIMP, verifique a mensagem acima"
End Sequence
Return aRet   


/*
Função     : IntegVlrCalc
Objetivo   : Realiza a integração dos valores calculados da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegVlrCalc(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local cRet := '', cAtuReg:=''
local cUrlVlrCalc := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/valores-calculados"
local aRet := {.T.,.T.}    //[1] erro de conexão, [2] erro da camada de negócio  
Begin Sequence   
      getLog(STR0032 + ' ' + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // "Recuperando valores calculados da Duimp"
      cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_REGISTRO + "'})"
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlVlrCalc , '','GET',@aRet,oLogView,cAtuReg,.F.)
      getLog(cRet,oLogView)  
      ProcRetDuimp(cRet,@aRet,oLogView,VALOR_CALCULADO,STR0035)    //"Houve algum problema no retorno dos valores dos atributos da DUIMP, verifique a mensagem acima"   
End Sequence
Return aRet   

/*
Função     : IntegDiagnostico
Objetivo   : Realiza a integração do diagnóstico da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegDiagnostico(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local cRet := '', cAtuReg:=''
local cUrlDiagDuimp := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/diagnosticos"
local aRet := {.T.,.T.,.F.}    //[1] erro de conexão, [2] erro da camada de negócio [3] Se passou pelo erro não impeditivo
local cQtdeItem := '{"totalItem":'+ lTrim(str(_nQtdeItem)) + '}'  
Begin Sequence   
      getLog(STR0025 + ' ' + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // Solicitando Diagnóstico da Duimp para registro/ retificação
      cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_REGISTRO + "'})"
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlDiagDuimp , cQtdeItem,'POST',@aRet,oLogView,cAtuReg)
      getLog(cRet,oLogView)  
      If !ProcRetDuimp(cRet,@aRet,oLogView,DIAGNOSTICO,STR0024) //"Houve algum problema no retorno do diagnóstico da DUIMP, verifique a mensagem acima"
         AtuReg({'EV1_STATUS'},{PENDENTE_REGISTRO}) 
         getLog(STR0028,oLogView) //"Operação de Registro da Duimp abortada pelo usuário" 
         aRet[2]:=.F.
      EndIf   
End Sequence
Return aRet   

/*
Função     : IntDelDUIMP
Objetivo   : Realiza o envio da exclusão da integração DUIMP
Parâmetro  :
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
Static function IntDelDUIMP(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
   local cAtuReg      := ""
   local cRet         := ""
   local cUrlDelDuimp := ""
   local aRet         := {.T.,.T.}

   default cUrlInteg := ""
   default cURLAuth  := cUrlInteg + URL_AUTENTICAR

   begin sequence

   if !empty(EV1->EV1_DI_NUM)
      cUrlDelDuimp := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO) 
      //cAtuReg := "AtuReg({'EV1_DI_NUM','EV1_VERSAO'},{'',''})"
      getLog(STR0011 + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // Iniciando o envio da exclusão da Duimp: XXX versão:
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlDelDuimp , '','DELETE',@aRet,oLogView,cAtuReg)
      
      ProcRetDuimp(cRet,@aRet,oLogView,DELETE_DUIMP,STR0085) //"Houve algum problema no retorno da exclusão da DUIMP, verifique a mensagem acima"
      if aRet[1] .And. aRet[2]
         AtuReg({'EV1_DI_NUM','EV1_VERSAO'},{'',''})
      endif
      getLog(cRet,oLogView)
   endif

   end sequence

return aRet

/*
Função     : IntegCapa
Objetivo   : Realiza a integração da capa da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegCapa(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local cGeraisTxt := InfGerais(cHawb, cLote)
local oJson      := JsonObject():New()
local cError := oJson:FromJson(cGeraisTxt)
local cRet := '', cAtuReg:=''
local cUrlDuimp   := cUrlInteg + "/duimp-api/api/ext/duimp"
local aRet := {.T.,.T.}  //[1] erro de conexão, [2] erro da camada de negócio         
Begin Sequence
   fwfreeobj(oJson)
   If cError == nil
      getLog(STR0014,oLogView)  //Iniciando o envio dos Dados Gerais da Duimp:      
      getLog(cGeraisTxt,oLogView)    

      cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_INTEGRACAO + "'})"
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlDuimp , cGeraisTxt,'POST',@aRet,oLogView,cAtuReg)

      getLog(STR0015,oLogView)  //Retorno da gravação dos Dados Gerais da Duimp:                
      getLog(cRet,oLogView)   
      ProcRetDuimp(cRet,@aRet,oLogView,CAPA,STR0019) //"Houve algum problema no retorno da gravação da DUIMP, verifique a mensagem acima"    
   else
      getLog(STR0020 ,oLogView) //Erro na formatação do json gerado   //atenção advpr ok
      getLog(cError ,oLogView) 
      AtuReg({'EV1_STATUS'},{PENDENTE_INTEGRACAO})         
      aRet[1] := .F. 
   EndIf    
End Sequence   
Return aRet   

/*
Função     : getRegJson
Objetivo   : Gerar o json para envio no registro da duimp
Parâmetro  : lErroNimp - se .T. é pq. teve erros não impeditivos, se .F. é pq. não teve erros não impeditivos
             cHawb - número do processo de importação
Retorno    : Retorna o json para solicitaçaõ do registroda duimp
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
Static function getRegJson(lErroNimp,cHawb)
local cRegJson  := ''
local cPgtoJson := ''
local cPgtoImp  := ''
local cResposta := iif(lErroNimp,"SIM","NA")
local aImposto  := {201,202,204,205,val(EasyGParam("MV_CODTXSI",.F.,"415"))} // pular o 203 que é o icms
local nTotal    := len(aImposto)
local nImposto  := 0

SWD->(DBSETORDER(1))
cRegJson := '{"totalItem": '+ lTrim(str(_nQtdeItem)) +','

cPgtoJson := ''
for nImposto := 1 to nTotal
   cPgtoImp := getTagImpostos(aImposto[nImposto],cHawb) 
   if !empty(cPgtoImp)
      cPgtoJson += cPgtoImp +','
   endif
next

if !empty(cPgtoJson)
   cPgtoJson := substr(cPgtoJson,1,len(cPgtoJson)-1)
   cRegJson +=    '"pagamentos": ['
   cRegJson +=          cPgtoJson
   cRegJson +=                 '],'
endif
cRegJson +=  '"confirmacaoAlertaErrosNaoImpeditivos": "' + cResposta + '"'
cRegJson +='}'

return cRegJson

/*
Função     : getTagImpostos
Objetivo   : gerar a tag do imposto informado no parâmetro
Parâmetro  : nImposto - código numérico do imposto
             cHawb -  número do processo de importação
Retorno    : Retorna a tag gerada do imposto informado no parâmetro
Autor      : Maurício Frison
Data/Hora  : Novembro/2023
Obs.       :
*/
static function getTagImpostos(nImposto,cHawb)
Local cSWDFil := xFilial("SWD")
Local cTagJson:=''
local cValor := ''
local nValor := 0

   nValor := getValImp(cSWDFil,cHawb,nImposto)
   if nValor > 0
      cValor := alltrim(str(nValor,AvSx3('WD_VALOR_R',AV_TAMANHO),2))
      cTagJson += '{'  
      cTagJson +=    '"principal": {'
      cTagJson +=       '"tributo": {'
      cTagJson +=          '"tipo": "' + getNomeImp(nImposto) + '"'
      cTagJson +=       '},'
      cTagJson +=       '"valor": ' + cValor
      cTagJson +=    '}'
      cTagJson += '}'
   endif

Return cTagJson   

/*
Função     : getNomeImp
Objetivo   : Retornar o nome do imposto a partir do código
Parâmetro  : nImposto - código numérico do imposto
Retorno    : Retorno do nome do imposto
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getNomeImp(nImposto)
local cRet:=''
Do CASE
   Case nImposto == 201
        cRet := 'II'
   Case nImposto == 202
        cRet := 'IPI'
   //Case nImposto == 203
   //     cRet := 'ICMS'     
   Case nImposto == 204
        cRet := 'PIS'
   Case nImposto == 205
        cRet := 'COFINS'
   Case nImposto == val(EasyGParam("MV_CODTXSI",.F.,"415"))
        cRet := 'TAXA_UTILIZACAO'

ENDCASE
Return cRet

/*
Função     : getValImp
Objetivo   : Retornar o valor do imposto que foi recuperado no portal único e salvo na tabela swd
Parâmetro  : cSWDFil - filial da tabela SWD
             cHawb - número do processo de embarque/desembaraço no sigaeic
             nCodigo - código numérico do imposto
Retorno    : Retorno o valor do imposto como caracter formatdo em duas casas decimais e . decimal
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getValImp(cSWDFil,cHawb,nImposto)
local nValor := 0
if SWD->(DBSEEK(cSWDFil + cHawb + str(nImposto,AvSx3('WD_DESPESA',AV_TAMANHO),0))) 
   nValor := SWD->WD_VALOR_R
endif
Return nValor


/*
Função     : AtuReg
Objetivo   : Realiza a atualização dos campos na tabela EV1
Parâmetro  : aCampos  - array com os campos a serem atualizados 
             aValores -array com os valores a serem atualizados
             cAlias   - Alias da tabela 
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
Static function AtuReg(aCampos,aValores,cAlias)
local i
local cCampo
Default cAlias := "EV1"
IF cAlias == "SW6"
   SW6->(DBSETORDER(1))
   SW6->(dbSeek( xFilial("SW6") + EV1->EV1_HAWB ))
ENDIF

RecLock(cAlias,.F.)
for i:=1 to len(aCampos)
   if !Empty(aValores[i]) .or. aCampos[i] == "W6_DI_NUM" .or. aCampos[i] == "EV1_DI_NUM" .or. aCampos[i] == "W6_VERSAO" .or. aCampos[i] == "EV1_VERSAO"
      cCampo := cAlias + '->' + aCampos[i]
      &cCampo := aValores[i]
   EndIf   
Next
(cAlias)->(MsUnlock())

Return

/*
Função     : execEndPoint
Objetivo   : Faz a chamada no portal único
Parâmetro  : oEasyJS : objeto easyjs
             cUrlAuth: url de atutenticação no portal único
             cUrlExec: url a ser utilizada no portal único após a autenticação
             cDados  : informações a serem enviadas ao portal único quando for método post ou put, caso contrário será vazio
             cMetodo : método a ser executado no portal único, ex: post,put,delete
             aRet    : array onde será retornado .f. em caso de erro
             oLogView: objeto para tratamento do eecview
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
Static function execEndPoint(oEasyJS, cUrlAuth, cUrlExec , cDados, cMetodo, aRet, oLogView, cAtuReg, lBody, nTry)
local cRet       := ""
local cErros     := ""
local cJscript   := ""
local cVersAgent := ""

default nTry := 0

// cJscript := "intDuimp('" + cUrlExec + "', '" + cMetodo + "', " + if( !empty(cDados), "'" + cDados + "'", "null") + ", retAdvpl, retAdvplError);"
// oEasyJS:runJSSync( cJscript, {|x| cRet := x } , {|x| cErros := x } )
cRet := intDUIMP(oEasyJS, @cErros, cUrlExec, cMetodo, cDados)
If !Empty(cErros)
   getLog(iif(cErros == FAILED_FETCH, STR0013 + ' ' + cErros,cErros),oLogView)  //"Erro no certificado"      
   aRet[1] := .F.           
   if !empty(cAtuReg)  
      &cAtuReg
   endif
   BREAK
EndIf

//chama novamente o endpoint caso não haja retorno do processamento - estouro do timeout; 3 tentativas de integração
// Caso o release for maior ou igual 12.1.2410 e a versão do agente for igual 1.0.17-RC1 ou for menor que a 1.0.17
if empty(cRet) .And. nTry < 3 .and. getRelease() >= '12.1.2410' 
   cVersAgent := getVrAgent()
   if cVersAgent == "1.0.17-RC1" .or. VldVersao(cVersAgent,"1.0.17")
      cRet := execEndPoint(oEasyJS, cUrlAuth, cUrlExec , cDados, cMetodo, aRet, oLogView, cAtuReg, lBody, nTry++)
   endif
endIf

Return cRet

/*
Função     : ProcRetDuimp
Objetivo   : Faz a chamada no portal único
Parâmetro  : cRet    : string com o retorno do portal único
             aRet    : array onde será retornado .f. em caso de erro
             oLogView: objeto para tratamento do eecview
             cTipo   : tipo da integração, ex: CAPA, ITEM, DIAGNOSTICO ou REGISTRO
             cMsgErr : mensagem a ser exibida em caso de problema na estrutura do arquivo no retorno do portal único
Retorno    : retorna .T. se quis continuar ou não passou pela pergunta e retorna .F. se o usuário não quis continuar 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function ProcRetDuimp(cRet,aRet,oLogView,cTipo,cMsgErr)
local lReturn   := .T.
local cMsg      := ""
local aDuimp    := getRetorno(cRet, cTipo)
local cRetDiag  := ""
local cNumDuimp := ""
local cVerDuimp := ""
local aValores  := {}

if len(aDuimp) == 0 
   getLog(cMsgErr,oLogView)  //Houve algum problema no retorno ?????? da DUIMP, verifique a mensagem acima
   aRet[2] := .F.
else
   cNumDuimp := aDuimp[1]
   cVerDuimp := aDuimp[2]
   aValores := aDuimp[3]
   cRetDiag := aDuimp[4]
   cMsg := aDuimp[5]
endif

If aRet[2] 
   Do CASE
      Case cTipo == CAPA 
            if empty(cMsg) .and. !empty(cNumDuimp)
               AtuReg({'EV1_DI_NUM','EV1_VERSAO'},{cNumDuimp,cVerDuimp})
            else
               AtuReg({'EV1_DI_NUM','EV1_VERSAO'},{cNumDuimp,cVerDuimp})
               getLog(STR0022,oLogView) //Erro na camada de negócio, verifique a mensagem acima
               AtuReg({'EV1_STATUS'},{PROCESSO_PENDENTE_REVISAO})
               aRet[2] := .F.
            endif 
      Case cTipo == DIAGNOSTICO .AND. cRetDiag == DIAG_PROCESSAMENTO 
            AtuReg({'EV1_STATUS'},{PENDENTE_REGISTRO})
            aRet[2]:=.F.
      Case cTipo == DIAGNOSTICO .AND. cRetDiag $ PROC_N_IMPED 
            EECView(STR0029 + cRetDiag,STR0003,,,,.F.,.T.) //"Retorno do envio de diagnóstico: "
            lReturn := MsgNoYes(STR0030,STR0003) //"Deseja prosseguir com o registro de sua Duimp com alertas ou erros não impeditivos?","ATENCAO"
            aRet[3] := lReturn
      Case cTipo == DIAGNOSTICO .AND. cRetDiag == PROC_S_IMPED 
            EECView(STR0029 + cRetDiag,STR0003,,,,.F.,.T.) //"Retorno do envio de diagnóstico: "
            lReturn := MsgNoYes(STR0031,STR0003)   //"Deseja prosseguir com o registro de sua Duimp?","ATENCAO"
      Case cTipo == VALOR_CALCULADO .And. !Empty(cMsg)
            AtuReg({'EV1_STATUS'},{PENDENTE_REGISTRO})
            getLog(STR0022,oLogView) //Erro na camada de negócio, verifique a mensagem acima
            aRet[2] := .F.  
      Case cTipo == VALOR_CALCULADO .And. Empty(cMsg)          
            aRet[2] := gravaDesp(aValores) 
      Case cTipo == REGISTRO .And. Empty(cMsg)            
            AtuReg({'EV1_STATUS','EV1_VERSAO'},{EM_PROCESSAMENTO,cVerDuimp})
      Case cTipo == DELETE_DUIMP .And. !Empty(cMsg)
            getLog(STR0022,oLogView) //Erro na camada de negócio, verifique a mensagem acima
            aRet[2] := .F.
      Case !Empty(cMsg)
            getLog(STR0022,oLogView) //Erro na camada de negócio, verifique a mensagem acima
            AtuReg({'EV1_STATUS'},{PROCESSO_PENDENTE_REVISAO})  
            aRet[2] := .F.        
   EndCase  
EndIf

Return lReturn

/*
Função     : IntegItens
Objetivo   : Realiza a integração dos itens da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegItens(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local aItsDUIMP := {}
local aItensTxt := InfItens(cHawb, cLote, @aItsDUIMP)
local nTotItens := 0
local cUrlITDuimp := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/itens"
local cRet := '', cAtuReg:=''
local oJson  := JsonObject():New()
local cError 
local aRet := {.T.,.T.}  //[1] erro de conexão, [2] erro da camada de negócio  
local nQtdItem := 0
local nTotal := 0
local i:=0

Begin Sequence

   nTotal := len(aItensTxt)
   _aItsDUIMP := aClone(aItsDUIMP)
   _nQtdeItem := len(_aItsDUIMP)
   nTotItens := _nQtdeItem
   for i:=1 to nTotal
      nQtdItem := nTotItens
      if i < nTotal 
         nQtdItem := 100
         nTotItens -= 100
      endif
      cError := oJson:FromJson(aItensTxt[i])
      If cError == nil
         cString := StrTran( STR0017, '###', lTrim(str(i)))                   
         cString := StrTran(cString, '@@@',lTrim(str(nQtdItem)))
         getLog(cString,oLogView) //Iniciando o envio dos Dados dos Itens da Duimp para inclusão ### de @@@       
         getLog(aItensTxt[i],oLogView)        
            
         cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_INTEGRACAO + "'})"
         cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlItDuimp , aItensTxt[i],'POST',@aRet,oLogView,cAtuReg)
         getLog(STR0018,oLogView) //Retorno da gravação dos Dados dos Itens da Duimp:               
         getLog(cRet,oLogView)                  
         ProcRetDuimp(cRet,@aRet,oLogView,ITEM,STR0021) //"Houve algum problema no retorno da gravação do item da DUIMP, verifique a mensagem acima"       
      else 
         getLog(STR0020 ,oLogView) //Erro na formatação do json gerado    //atenção advpr OK
         getLog(cError ,oLogView)  
         AtuReg({'EV1_STATUS'},{PENDENTE_INTEGRACAO})         
         aRet[1] := .F.
         exit
      EndIf   
   Next
End Sequence
fwfreeobj(oJson)
Return aRet

/*
Função     : getLog
Objetivo   : gera o log para o eecview e posterior gravação no registro
Parâmetro  :cMsg: Mensagem que será enviada ao log
            oLogView: objeto que receberá o log
            lSpace: se true vai incluir espaços + hora na mensagem, se false não altera a mensagem
Retorno    :
Autor      : Maurício Frison
Data/Hora  : Abril/2022
Obs.       :
*/
static function getLog(cMsg,oLogView,lspace)
Default lspace := .T.
cSpace := iif(lspace,space(10) + '- ' + time()+' ','')
oLogView:appendText(cSpace+cMsg+ENTER+ENTER)
oLogView:Refresh()
oLogView:goEnd()
return

/*
Função:    getRetorno
Objetivo:  tratar o json retornado pelo portal e obter o número da D.I. gerada e a Versão
Retorno:   aRet contendo o númerod da D.I. na primeira posição
                           versão na segunda posição
                           erro da camada de negócio se houver na terceira posição
Autor:     Maurício Frison
Data:      Maio/2022
*/
static function getRetorno(cMsg, cTipo)
Local nj,nje
Local cRet
Local oJson
Local aJson      := {}
Local aJsonErros := {}
local aJsonErr   := {}
Local cErros     := ""
Local aResult    := {}
Local aTributos  := {}
Local jIdent
Local cNumero := ''
Local cVersao := ''
local cRetJson
local nStatus   := 0
local cMsgValid := ""
  
   if !empty(cMsg) // "{"status":404,"status_text":"Not Found","response":"{\n  \"message\" : \"A Duimp que você informou 25BR00000114610 não foi encontrada, verifique se está correta.\",\n  \"errors\" : [ ]\n}"}"
      oJson := JsonObject():New()
      cRetJson := oJson:FromJson(cMsg)
      if valtype(cRetJson) == "U"
         if valtype(oJson:GetJsonObject("status")) == "N"
            nStatus := oJson:GetJsonObject("status")
         endif

         if valtype(oJson:GetJsonObject("response")) == "J"
            cMsg := oJson:GetJsonText("response")
            if !empty(cMsg)
               oJson := JsonObject():New()
               cRetJson := oJson:FromJson(cMsg)
               if valtype(cRetJson) == "U"
                  if valtype(oJson:GetJsonObject("message")) == "C"
                     cMsgValid := oJson:GetJsonText("message")
                  endif
               endif
            endif
         endif

      endif
      FwFreeObj(oJson)
   endif

   if !empty(cMsg)
      cRet     := '{"items":['+cMsg+']}'
      oJson    := JsonObject():New()
      cRetJson := oJson:FromJson(cRet)
      if valtype(cRetJson) == "U" .And. valtype(oJson:GetJsonObject("items")) == "A"
         aJson := oJson:GetJsonObject("items")
         if len(aJson) > 0

            aResult := Array(5)
            // aResult[1] - Numero DUIMP
            // aResult[2] - Versao
            // aResult[3] - valores dos tributos
            // aResult[4] - Situação da DUIMP (diagnóstico)
            // aResult[5] - Erros

            jIdent := aJson[1]:GetJsonObject("identificacao")
            if jIdent != nil
               cNumero := jIdent:GetJsonText("numero")
               cVersao := jIdent:GetJsonText("versao")
            endif

            cErros    := aJson[1]:GetJsonObject("errors")  //cErros do tipo "A", tipo "C" ou nil
            cSituacao := aJson[1]:GetJsonObject("situacao")
            aTributos := aJson[1]:getJsonObject("tributosCalculados")  

            //obs: o array tem sempre que inicar com essas duas informaçãoes vazias ou nao
            aResult[1] := cNumero
            aResult[2] := cVersao
            aResult[3] := {} // valores dos tributos
            aResult[4] := "" // Situação da DUIMP (diagnóstico)
            aResult[5] := "" // Erros

            if aTributos != nil .And. Valtype(aTributos) == "A"
               aResult[3] := getTributos(aTributos)
            else
               if cSituacao != nil 
                  aResult[4] := cSituacao
               else
                  if valtype(aJson[1]:GetJsonObject("errors")) == "A" .or. valtype(aJson[1]:GetJsonObject("multiStatus")) == "A" 
                     aJsonErros := if(valtype(aJson[1]:GetJsonObject("errors")) == "A",aJson[1]:GetJsonObject("errors"), aJson[1]:GetJsonObject("multiStatus"))
                     cErros := "" // tem que deixar a variável cErros com o tipo Caracter, qunado ele é criado como array, é tratado um nível inferior aqui dentro onde tem que ser caracater
                                  // se foi gerado como caracter não vai entrar aqui
                     for nj := 1 to len(aJsonErros)
                        if ValType(aJsonErros[nj]:getJsonObject("errors") ) == "A" 
                           aJsonErr := aJsonErros[nj]:getJsonObject("errors")                             
                           For nje := 1 to len(aJsonErr)
                              cErros += aJsonErr[nje]:getJsonText("message") + ENTER    
                           Next nje    
                        else
                           if !(aJsonErros[nj]:getJsonText("code") $ ('200|201|202|203|204|205|206|207|208|226'))
                              cErros += aJsonErros[nj]:getJsonText("message") + ENTER
                           endif
                        endif
                     next
                  endif
               endif
            endif

            if cTipo == CAPA .and. empty(cNumero) .and. empty(cErros)
               cErros := ""
               if aJson[1]:HasProperty("status")
                  cErros += "Status: " + aJson[1]:getJsonText("status") 
               endif
               if aJson[1]:HasProperty("message")
                  cErros += if( !empty(cErros), " - ", "") + "Mensagem: " + aJson[1]:getJsonText("message")
               endif
            endif

            if nStatus > 0 .and. !empty(cMsgValid) .and. !(cValToChar(nStatus) $ ('200|201|202|203|204|205|206|207|208|226')) 
               cErros := if(cErros==nil, "",cErros)
               cErros += cMsgValid + ENTER
            endif
            aResult[5] := if(cErros==nil, "",cErros)

         endif
         FreeObj(oJson)
      endif
   endif

return aResult

/*
Função     : getTributos
Objetivo   : Pega o json de retorno do portal único dos valores calculados e retorna um array com imposto e valor 
Parâmetro  : aTributos - Array com os tributos vindos do portal único
Retorno    : Retornar um array com o tipo do imposto, o códgio no sistema EIC e o valor
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getTributos(aTributos)
Local aRet:={}
Local aImpostos := {}
Local i:=0
Local cImposto 
Local nValor
For i:=1 to len(aTributos)
    aImpostos := aTributos[i]:getJsonObject("valoresBRL")  
    cImposto  := aTributos[i]:getJsonText("tipo")
    nValor    := val(aImpostos:getJsonText("calculado"))
    aadd(aRet,{cImposto,nValor})
Next    
return aRet

/*
Função     : gravaDesp
Objetivo   : Grava as despesas 
Parâmetro  : aImpostos - Array com o valor e o tipo do imposto
Retorno    : Retornar .T. se conseguiu gravar e .F. se não conseguiu
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function gravaDesp(aImpostos)
Local lRet:= .T.
Local i:=0
Local cCodImp := ""
Local cSWDFil := xFilial("SWD")
SWD->(DBSETORDER(1))
For i:=1 to len(aImpostos)
   cCodImp := getCodImposto(aImpostos[i][1])
   if !empty(cCodImp)
      If !SWD->(DBSEEK( cSWDFil + EV1->EV1_HAWB + cCodImp)) 
         SWD->(RECLOCK("SWD",.T.)) 
         SWD->WD_FILIAL  := cSWDFil 
         SWD->WD_HAWB    := EV1->EV1_HAWB 
         SWD->WD_DESPESA := cCodImp
         SWD->WD_DES_ADI := Date()
         SWD->WD_BASEADI := '2' //ADIANTADO 2-Nao
         SWD->WD_PAGOPOR := '2' //PAGO POR 2-Importador
      else
         SWD->(RECLOCK("SWD",.F.))
      EndIf
      SWD->WD_VALOR_R := aImpostos[i][2]
      SWD->(MSUNLOCK())
   endif
Next    
return lRet

/*
Função     : getCodImposto
Objetivo   : Gerar o código do imposto utilizado no SIGAEIC a partir do imposto retornadao pelo portal único
Parâmetro  : Imposto
Retorno    : Retorna o código do imposto utilizado no SIGAEIC
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getCodImposto(cImposto)
cCodImposto:=''
Do Case
   Case cImposto == 'II'
        cCodImposto:=II
   Case cImposto == 'IPI'
        cCodImposto:=IPI
   Case cImposto == 'PIS'
        cCodImposto:=PIS
   Case cImposto == 'COFINS'
        cCodImposto:=COFINS
ENDCASE
Return cCodImposto

/*
Função     : InfGerais
Objetivo   : Realiza a criação dos json dos dados gerais da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function InfGerais(cHawb, cLote)
   local aArea      := getArea()
   local aAreaEV1   := {}
   local cJson      := ""
   local cIdentif   := ""
   local cCarga     := ""
   local cDocs      := ""

   default cHawb      := ""
   default cLote      := ""

   dbSelectArea("EV1")
   aAreaEV1 := EV1->(getArea())
   EV1->(dbSetOrder(2)) // EV1_FILIAL+EV1_LOTE+EV1_HAWB
   EV1->(dbSeek( xFilial("EV1") + cLote + cHawb))

   cJson := '{'

   // Identificação
   cIdentif := getIdent()
   cJson +=    '"identificacao":{'
   cJson +=       cIdentif
   cJson +=    '},'

   // Carga
   cCarga := getCarga()
   cJson +=    '"carga":{'
   cJson +=       cCarga
   cJson +=    '},'

   // Documentos
   cDocs := getDocs(cHawb, cLote)
   cJson +=    '"documentos":{'
   cJson +=       cDocs
   cJson +=    '}'

   cJson += '}'
 
   restArea(aAreaEV1)
   restArea(aArea)

return cJson

/*
Função     : getIdent
Objetivo   : Realiza a criação dos json dos dados da tabela EV1 - identificacao
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getIdent()
   local cIdentif   := ''
   local cNi        := ''
   local cInfComp   := ''
   local cTipoImp   := "CNPJ"

   private cIntCpfCnpj := ""

   if EV1->(Found())
      cNi        := alltrim(EV1->EV1_IMPNRO)
      cInfComp   := comex.generics.SetStringJson(EV1->EV1_INFCOM)
   endif

   cIntCpfCnpj := alltrim(cNi)
   If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICDU101_EV1_IMPNRO"),)
   cTipoImp := if(len(cIntCpfCnpj)==11,"CPF","CNPJ")

   cIdentif += '"importador":{'
   cIdentif += '"tipoImportador": "' + cTipoImp + '",'
   cIdentif +=    '"ni":"' + cIntCpfCnpj + '"'
   cIdentif +=    '}'
   if !empty(cInfComp)
      cIdentif += ', "informacaoComplementar":"' + cInfComp + '"'
   endif

return cIdentif

/*
Função     : getCarga
Objetivo   : Realiza a criação dos json dos dados da tabela EV1 - carga
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCarga()
   local cCarga     := ''
   local cIdenCarga := ''
   local cCodCarga  := ''
   local cMoeSeg    := ''
   local cVlrSeg    := '0'
   local cTipoIdent := ''
   local aAreaSW6   := {}
   local cPaisPro   := ''

   if EV1->(Found())
      aAreaSW6 := SW6->(getArea())
      SW6->(dbSetOrder(1)) // W6_FILIAL+W6_HAWB
      SW6->(dbSeek( xFilial("SW6") + EV1->EV1_HAWB ))

      cIdenCarga := alltrim(EV1->EV1_COIDM)
      cCodCarga  := alltrim(EV1->EV1_URFDES)
      cMoeSeg    := alltrim(EV1->EV1_SEGMOE)
      cVlrSeg    := StrTransf( StrTransf(alltrim(EV1->EV1_SETOMO), ".","") , ",",".") 
      cPaisPro   := allTrim(EV1->EV1_PAISPRO)
   endif

   /*
   Número de Identificação da Carga.
   Quando tipo de identificação da carga for CE:
   - Tamanho: 15
   - Formato: NNNNNNNNNNNNNNN
   Quando tipo de identificação da carga for RUC:
   - Tamanho mínimo: 1
   - Tamanho máximo: 32
   Origem: Sistema Siscomex Carga - https://www4.receita.fazenda.gov.br/g33159/jsp/logon.jsp?ind=11
   */
   cTipoIdent := if(len(cIdenCarga) > 15, 'RUC', 'CE')

   cCarga += '"tipoIdentificacaoCarga":"' + cTipoIdent + '",'
   cCarga += '"identificacao":"' + cIdenCarga + '",'
   cCarga += '"unidadeDeclarada":{'
   cCarga +=    '"codigo":"' + cCodCarga + '"'
   cCarga +=    '}'
   if !empty(cMoeSeg) .and. val(cVlrSeg) > 0
      cCarga += ', "seguro":{'
      cCarga +=      '"codigoMoedaNegociada":"' + cMoeSeg + '",'
      cCarga +=      '"valorMoedaNegociada": ' + cVlrSeg
      cCarga += '}'
   endif

   cCarga += ', "paisProcedencia":{'
   cCarga +=      '"codigo": "' + cPaisPro + '"'
   cCarga += '}'

   if len(aAreaSW6) > 0
      restArea(aAreaSW6)
   endif

return cCarga

/*
Função     : getDocs
Objetivo   : Realiza a criação dos json dos dados da tabela EV9 - Documentos
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getDocs(cHawb, cLote)
   local aAreaEV9   := {}
   local cDocsInst  := ''
   local cDocs      := ''
   local aAreaSW6   := {}
   local aAreaSW9   := {}
   local aAreaEYZ   := {}
   local aAreaSW2   := {}
   local cValor     := ""
   local cCodVin    := ""
   local cDocTo     := ""
   local aDados     := {}
   local cProcessos := ''
   local cData      := ""
   local aDclExpEst := {}
   local nDocs      := 0
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""
   local cFaixaIni  := ""
   local cFaixaFim  := ""
   local cDclExpEst := ""
   local cPicVlrTot := ""
   local cCodTip   := ""

   default cHawb      := ""
   default cLote      := ""

   dbSelectArea("EV9")
   aAreaEV9 := EV9->(getArea())

   EV9->(dbSetOrder(2)) // EV9_FILIAL+EV9_LOTE+EV9_HAWB+EV9_CODIN
   if EV9->(dbSeek( xFilial("EV9") + cLote + cHawb))

      cPicVlrTot := getSX3Cache("W9_FOB_TOT", "X3_PICTURE")

      dbSelectArea("SW6")
      aAreaSW6 := SW6->(getArea())
      SW6->(dbSetOrder(1)) // W6_FILIAL+W6_HAWB

      dbSelectArea("SW9")
      aAreaSW9 := SW9->(getArea())

      dbSelectArea("EYZ")
      aAreaEYZ := EYZ->(getArea())

      dbSelectArea("SW2")
      aAreaSW2 := SW2->(getArea())

      while EV9->(!eof()) .and. EV9->EV9_FILIAL == xFilial("EV9") .and. EV9->EV9_LOTE == cLote .and. EV9->EV9_HAWB == cHawb

         cCodVin := alltrim(EV9->EV9_CODIN)
         cDocTo := alltrim(EV9->EV9_DOCTO)
         cValor := ""
         aDados := {}
         cData := ""
         cCodTip := if(cCodVin == "73", "2", "1")
         if cCodVin == "41" // Declaração de exportação
            aAdd(aDclExpEst, cDocTo)
         else
            cDocsInst += '{'
            cDocsInst +=      '"tipo":{'
            cDocsInst +=         '"codigo":"' + cCodVin + '"'
            cDocsInst +=      '},'
            cDocsInst +=      '"palavrasChave":['
            cDocsInst +=         '{'
            cDocsInst +=            '"codigo": ' + cCodTip +','
            cDocsInst +=            '"valor":"' + cDocTo + '"'
            cDocsInst +=         '}'

            do case
               case cCodVin == "30" // Conhecimento de Embarque
                  SW6->(dbSeek( xFilial("SW6") + EV9->EV9_HAWB ))
                  if !empty(SW6->W6_TIPOCON)
                     aDados := FWGetSX5("47", SW6->W6_TIPOCON)
                     if len(aDados) > 0
                        cDocsInst += ',{'
                        cDocsInst +=   '"codigo": 2,'
                        cDocsInst +=   '"valor":"' + aDados[1][4] + '"'
                        cDocsInst += '}'
                     endif
                  endif
                  cData := fwTimeStamp(2,SW6->W6_DT_EMB)
                  cData := substr(cData, 1, at("-", cData)-1)
                  cDocsInst += ',{'
                  cDocsInst +=   '"codigo": 10,'
                  cDocsInst +=   '"valor":"' + cData + '"'
                  cDocsInst += '}'

               case cCodVin == "49" // Fatura Comercial
                  aDados := getInfInv(EV9->EV9_HAWB, cDocTo)
                  if len(aDados) > 0
                     if !empty(aDados[1])
                        cData := fwTimeStamp(2,aDados[1])
                        cData := substr(cData, 1, at("-", cData)-1)
                        cDocsInst += ',{'
                        cDocsInst +=   '"codigo": 4,'
                        cDocsInst +=   '"valor":"' + cData + '"'
                        cDocsInst += '}'
                     endif
                     if aDados[2] > 0
                        cDocsInst += ',{'
                        cDocsInst +=   '"codigo": 6,'
                        cDocsInst +=   '"valor":"' + ConvValor( aDados[2], cPicVlrTot ) + '"'
                        cDocsInst += '}'
                     endif
                  endif

               case cCodVin == "50" // Fatura Proforma
                  aDados := getInfProf(EV9->EV9_HAWB, cDocTo)
                  if len(aDados) > 0
                     if !empty(aDados[1])
                        cData := fwTimeStamp(2,aDados[1])
                        cData := substr(cData, 1, at("-", cData)-1)
                        cDocsInst += ',{'
                        cDocsInst +=   '"codigo": 4,'
                        cDocsInst +=   '"valor":"' + cData + '"'
                        cDocsInst += '}'
                     endif
                  endif

            end case

            cDocsInst +=      ']'
            cDocsInst += '},'
         endif

         EV9->(dbSkip())
      end

      cDocsInst := substr(alltrim(cDocsInst), 1, len(alltrim(cDocsInst))-1 )

      restArea(aAreaSW6)
      restArea(aAreaSW9)
      restArea(aAreaEYZ)
      restArea(aAreaSW2)

   endif

   cDocs += '"documentosInstrucao":['
   cDocs +=    cDocsInst
   cDocs += ']'

   // Processos
   cProcessos := ""
   getProces(cHawb, cLote, @cProcessos)
   if !empty(cProcessos)
      cDocs += ',"processos":['
      cDocs +=    cProcessos
      cDocs += ']'
   endif

   if len(aDclExpEst) > 0
      cQuery := " SELECT MAX(WV_SEQDUIM) MAXIMO, MIN(WV_SEQDUIM) MINIMO  "
      cQuery += "  FROM " + RetSqlName("SWV") + " SWV "
      cQuery += " WHERE "
      cQuery += "  SWV.WV_FILIAL = ? "
      cQuery += "  AND SWV.WV_HAWB = ? "
      cQuery += "  AND SWV.D_E_L_E_T_ = ? "

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString( 1, xFilial("SWV") ) // WV_FILIAL
      oQuery:SetString( 2, cHawb ) // WV_HAWB
      oQuery:SetString( 3, ' ' ) // D_E_L_E_T_
      cQuery := oQuery:GetFixQuery()

      cAliasQry  := getNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      cFaixaIni := (cAliasQry)->MINIMO
      cFaixaFim := (cAliasQry)->MAXIMO
      (cAliasQry)->(dbCloseArea())

      // "numero": "19XY0000001-XYZ",
      // "faixaInicio": "A-11",
      // "faixaFim": "B-20"
      
      cDocs += ',"declaracoesExportacaoEstrangeira":['
      for nDocs := 1 to len(aDclExpEst)
         cDclExpEst += '{'
         cDclExpEst +=    '"numero": "' + aDclExpEst[nDocs] + '",'
         cDclExpEst +=    '"faixaInicio": "' + cFaixaIni + '",'
         cDclExpEst +=    '"faixaFim": "' + cFaixaFim + '" '
         cDclExpEst += '},'
      next
      cDclExpEst := substr(alltrim(cDclExpEst), 1, len(alltrim(cDclExpEst))-1 )
      cDocs +=    cDclExpEst
      cDocs += ']'

   endif

   restArea(aAreaEV9)

return cDocs

/*
Função     : getInfInv
Objetivo   : Retorna os dados das invoices do processo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getInfInv(cHawb, cInvoice)
   local aRet       := {"", 0}
   local cAliasQry  := ""
   local cQuery     := ""
   local oQuery     := nil

   default cHawb      := ""
   default cInvoice   := ""

   // Carregando 49 - Fatura Comercial
   cAliasQry := getNextAlias()

   cQuery := " SELECT SW9.R_E_C_N_O_ RECNO "
   cQuery += "  FROM " + RetSqlName("SW9") + " SW9 "
   cQuery += " WHERE "
   cQuery += "  SW9.W9_FILIAL = ? "
   cQuery += "  AND SW9.W9_HAWB = ? "
   cQuery += "  AND SW9.W9_INVOICE = ? "
   cQuery += "  AND SW9.D_E_L_E_T_ = ? "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString( 1, xFilial("SW9") )
   oQuery:SetString( 2, cHawb )
   oQuery:SetString( 3, cInvoice )
   oQuery:SetString( 4, ' ' )
   cQuery := oQuery:GetFixQuery()

   cAliasQry  := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   if (cAliasQry)->(!eof()) .and. (cAliasQry)->RECNO > 0
      SW9->(dbGoTo( (cAliasQry)->RECNO))
      aRet[1] := SW9->W9_DT_EMIS
      aRet[2] := DI501RetVal("TOT_INV", "TAB", .T.)
   endif

   (cAliasQry)->(DBCloseArea())

return aRet

/*
Função     : getInfProf
Objetivo   : Retorna os dados das proformas do processo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getInfProf(cHawb, cProforma)
   local aRet       := {""}
   local cAliasQry  := ""
   local lAchouEYZ  := .F.
   local cQuery     := ""
   local oQuery     := ""

   default cHawb      := ""
   default cProforma  := ""

   // Carregando 50 - Fatura Proforma
   cQuery := " SELECT DISTINCT EYZ.EYZ_DT_PRO "
   cQuery +=   " FROM " + RetSqlName("SW7") + " SW7 "
   cQuery +=      " INNER JOIN " + RetSqlName("EYZ") + " EYZ ON "
   cQuery +=      " EYZ.EYZ_FILIAL = ? "
   cQuery +=      " AND EYZ.EYZ_PO_NUM = SW7.W7_PO_NUM "
   cQuery +=      " AND EYZ.EYZ_NR_PRO = ? " 
   cQuery +=      " AND EYZ.D_E_L_E_T_ = ? " 
   cQuery += " WHERE "
   cQuery += "  SW7.W7_FILIAL = ? "
   cQuery += "  AND SW7.W7_HAWB = ? "
   cQuery += "  AND SW7.D_E_L_E_T_ = ? "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString( 1, xFilial("EYZ") ) // EYZ_FILIAL
   oQuery:SetString( 2, cProforma ) // EYZ_NR_PRO
   oQuery:SetString( 3, ' ' ) // EYZ.D_E_L_E_T_
   oQuery:SetString( 4, xFilial("SW7") ) // W7_FILIAL
   oQuery:SetString( 5, cHawb ) // W7_HAWB
   oQuery:SetString( 6, ' ' ) // SW7.D_E_L_E_T_ 
   cQuery := oQuery:GetFixQuery()

   cAliasQry  := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   TCSetField( cAliasQry, "EYZ_DT_PRO", "D", 8, 0 )

   (cAliasQry)->(dbGoTop())
   if (cAliasQry)->(!eof())
      aRet[1] := (cAliasQry)->EYZ_DT_PRO
      lAchouEYZ := .T. 
   endif
   (cAliasQry)->(DBCloseArea())

   if !lAchouEYZ
      cQuery := " SELECT DISTINCT W2_DT_PRO "
      cQuery +=   " FROM " + RetSqlName("SW7") + " SW7 "
      cQuery +=      " INNER JOIN " + RetSqlName("SW3") + " SW3 ON "
      cQuery +=         " SW3.W3_FILIAL = ? "
      cQuery +=         " AND SW3.W3_PO_NUM = SW7.W7_PO_NUM "
      cQuery +=         " AND SW3.W3_POSICAO = SW7.W7_POSICAO "
      cQuery +=         " AND SW3.D_E_L_E_T_ = ? "
      cQuery +=      " INNER JOIN " + RetSqlName("SW2") + " SW2 ON "
      cQuery +=         " SW2.W2_FILIAL = ? "
      cQuery +=         " AND SW2.W2_PO_NUM = SW3.W3_PO_NUM "
      cQuery +=         " AND SW2.W2_NR_PRO = ? "
      cQuery +=         " AND SW2.D_E_L_E_T_ = ? "
      cQuery += " WHERE "
      cQuery +=   " SW7.W7_FILIAL = ? "
      cQuery +=   " AND SW7.W7_HAWB = ? "
      cQuery +=   " AND SW7.D_E_L_E_T_ = ? "

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString( 1, xFilial("SW3") ) // W3_FILIAL
      oQuery:SetString( 2, ' ' ) // SW3.D_E_L_E_T_
      oQuery:SetString( 3, xFilial("SW2") ) // W2_FILIAL
      oQuery:SetString( 4, cProforma ) // W2_NR_PRO
      oQuery:SetString( 5, ' ' ) // SW2.D_E_L_E_T_ 
      oQuery:SetString( 6, xFilial("SW7") ) // W7_FILIAL
      oQuery:SetString( 7, cHawb ) // W7_HAWB
      oQuery:SetString( 8, ' ' ) // SW7.D_E_L_E_T_ 
      cQuery := oQuery:GetFixQuery()

      cAliasQry  := getNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      TCSetField( cAliasQry, "W2_DT_PRO", "D", 8, 0 )

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
         aRet[1] := (cAliasQry)->W2_DT_PRO
      endif
      (cAliasQry)->(DBCloseArea())
   endif

return aRet

/*
Função     : getProces
Objetivo   : Realiza a criação dos json dos dados da tabela EVB - processos
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getProces(cHawb, cLote, cProcessos)
   local aArea      := getArea()
   local aAreaEVB   := {}

   default cHawb      := ""
   default cLote      := ""
   default cProcessos := ""

   dbSelectArea("EVB")
   aAreaEVB := EVB->(getArea())

   EVB->(dbSetOrder(2)) // EVB_FILIAL+EVB_LOTE+EVB_HAWB
   if EVB->(dbSeek( xFilial("EVB") + cLote + cHawb))
      while EVB->(!eof()) .and. EVB->EVB_FILIAL == xFilial("EVB") .and. EVB->EVB_LOTE == cLote .and. EVB->EVB_HAWB == cHawb
         cProcessos += '{'
         cProcessos +=     '"identificacao":"' + alltrim(EVB->EVB_DESPV) + '",'
         cProcessos +=     '"tipo":"' + alltrim(EVB->EVB_CODPV) + '"'
         cProcessos += '},'
         EVB->(dbSkip())
      end
      cProcessos := substr(alltrim(cProcessos), 1, len(alltrim(cProcessos))-1 )
   endif
 
   restArea(aAreaEVB)
   restArea(aArea)

return nil

/*
Função     : InfItens
Objetivo   : Realiza a criação dos json dos dados dos itens da DUIMP
Parâmetro  :
Retorno    : aRet: array com os jsons dos itens gerados
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function InfItens(cHawb, cLote, aItsDUIMP)
   local aArea      := getArea()
   local aAreaSWV   := {}
   local aAreaEV2   := {}
   local aRet       := {}
   local cQrySWV    := nil
   local lFoundEV2  := .F.
   local nCountItem := 0
   local cJsonItem  := ''
   local cProduto   := ''
   local cCaracImp  := ''
   local cIndExpFab := ''
   local cInfInd    := ''
   local cInfFab    := ''
   local cFabric    := ''
   local cExport    := ''
   local cIndCompVd := ''
   local cMerc      := ''
   local cCondVenda := ''
   local cLPCOs     := ''
   local cCertMerc  := ''
   local cDocVincs  := ''
   local cDadosCamb := ''
   local cDadosTrib := ''
   local cJson      := ''
   local cMsgItens  := ""
   local lEv2Fl     := EV2->(columnPos("EV2_ATT_FL")) > 0

   default cHawb      := ""
   default cLote      := ""
   default aItsDUIMP  := {}

   dbSelectArea("SWV")
   aAreaSWV := SWV->(getArea())

   if getItens(@cQrySWV, cHawb)

      dbSelectArea("EV2")
      aAreaEV2 := EV2->(getArea())

      nCountItem := 0
      cMsgItens := ""

      EV2->(dbSetOrder(3)) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

      while (cQrySWV)->(!eof())

         SWV->(dbGoto((cQrySWV)->RECNO))
         lFoundEV2 := EV2->(dbSeek( xFilial("EV2") + cLote + SWV->WV_HAWB + SWV->WV_SEQDUIM))

         nCountItem += 1
         aAdd( aItsDUIMP, { SWV->WV_SEQDUIM, SWV->WV_ID } )
         cInfInd := ''
         cInfFab := ''

         cJsonItem += '{'
         cJsonItem +=      '"identificacao":{'
         cJsonItem +=            '"numeroItem": ' + cValToChar(val(SWV->WV_SEQDUIM)) // Número do item da Duimp.
         cJsonItem +=            '}'

         // "produto"
         cProduto := getProd(lFoundEV2)
         if !empty(cProduto)
            cJsonItem +=   ',"produto":{'
            cJsonItem +=         cProduto
            cJsonItem +=         '}'
         endif

         // "caracterizacaoImportacao"
         cCaracImp := getCaracImp(lFoundEV2)
         if !empty(cCaracImp)
            cJsonItem +=   ',"caracterizacaoImportacao":{'
            cJsonItem +=         cCaracImp
            cJsonItem +=         '}'
         endif

         // "indicadorExportadorFabricante"
         cIndExpFab := getExpFab(lFoundEV2, @cInfInd)
         if !empty(cIndExpFab)
            cJsonItem +=   ',"indicadorExportadorFabricante":{'
            cJsonItem +=         cIndExpFab
            cJsonItem +=         '}'
         endif

         // "fabricante"
         cFabric := getFabric(lFoundEV2, @cInfFab)
         if !empty(cFabric)
            cJsonItem +=   ',"fabricante":{'
            cJsonItem +=         cFabric
            cJsonItem +=         '}'
         endif

         // "exportador"
         cExport := getExport(lFoundEV2, cInfInd, cInfFab)
         if !empty(cExport)
            cJsonItem +=   ',"exportador":{'
            cJsonItem +=         cExport
            cJsonItem +=         '}'
         endif

         // "indicadorCompradorVendedor"
         cIndCompVd := getIndCmpVd(lFoundEV2)
         if !empty(cIndCompVd)
            cJsonItem +=   ',"indicadorCompradorVendedor":{'
            cJsonItem +=         cIndCompVd
            cJsonItem +=         '}'
         endif

         // "mercadoria"
         cMerc := getMercad(lFoundEV2)
         if !empty(cMerc)
            cJsonItem +=   ',"mercadoria":{'
            cJsonItem +=         cMerc
            cJsonItem +=         '}'
         endif

         // "condicaoVenda"
         cCondVenda := getCondVend(lFoundEV2, cLote)
         if !empty(cCondVenda)
            cJsonItem +=   ',"condicaoVenda":{'
            cJsonItem +=         cCondVenda
            cJsonItem +=         '}'
         endif

         // "lpcos"
         cLPCOs := getLPCOS(cLote)
         if !empty(cLPCOs)
            cJsonItem +=   ',"lpcos":['
            cJsonItem +=         cLPCOs
            cJsonItem +=         ']'
         endif

         // "certificadoMercosul"
         cCertMerc := getCertMerc(cLote)
         if !empty(cCertMerc)
            cJsonItem +=   ',"certificadoMercosul":['
            cJsonItem +=         cCertMerc
            cJsonItem +=         ']'
         endif

         // "declaracoesVinculadas"
         cDocVincs := getDocVincs(cLote)
         if !empty(cDocVincs)
            cJsonItem +=   ',"declaracoesVinculadas":['
            cJsonItem +=         cDocVincs
            cJsonItem +=         ']'
         endif

         // "dadosCambiais"
         cDadosCamb := getDadosCam(lFoundEV2)
         if !empty(cDadosCamb)
            cJsonItem +=   ',"dadosCambiais":{'
            cJsonItem +=         cDadosCamb
            cJsonItem +=         '}'
         endif

         If AvFlags("FUNDAMENTO_LEGAL_ITEM")
            // "atributosDuimp"
            cDadosTrib := getDadosAttDuimp(lFoundEV2)
            if !empty(cDadosTrib)
               cJsonItem += ', "atributosDuimp": ' 
               cJsonItem += cDadosTrib
            endif
         EndIf

         //ENVIO DO ATO CONCESSÓRIO - atributosFundamentoLegalDuimp
         If lEv2Fl
            if !empty(EV2->EV2_ATT_FL)
               nTam := len(Alltrim(EV2->EV2_ATT_FL))
               cJsonItem += ',' + SubString(EV2->EV2_ATT_FL,2,nTam-2) 
            Endif   
         elseIf AvFlags("DRAWBACK_DUIMP")
            // "atributosFundamentoLegalDuimp"
            cDadosTrib := getAtoDuimp(SWV->WV_MODAL, SWV->WV_AC, SWV->WV_SEQSIS)
            if !empty(cDadosTrib)
               cJsonItem += ', "atributosFundamentoLegalDuimp":[' 
               cJsonItem += cDadosTrib
               cJsonItem += ']'
            endif
         EndIf

         If AvFlags("TRIBUTACAO_DUIMP")
            // "tributos"
            cDadosTrib := getDadosTrib(SWV->WV_HAWB, cLote, SWV->WV_SEQDUIM)
            if !empty(cDadosTrib)
               cJsonItem +=   ',"tributos":['
               cJsonItem +=         cDadosTrib
               cJsonItem +=         ']'
            endif
         EndIf

         cJsonItem += '},'

         (cQrySWV)->(dbSkip())

         if nCountItem == 100 .or. (cQrySWV)->(eof())

            cJsonItem := substr(alltrim(cJsonItem), 1, len(alltrim(cJsonItem))-1 )
            cJson := '['
            cJson += cJsonItem
            cJson += ']'

            AADD(aRet,cJson)

            cJsonItem := ''
            nCountItem := 0

         endif

      end

      restArea(aAreaEV2)

   endif

   (cQrySWV)->(dbCloseArea())

   restArea(aAreaSWV)
   restArea(aArea)

return aRet

/*
Função     : getItens
Objetivo   : Retorna um alias com registros da SWV
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getItens(cAliasQry, cHawb, lGetAll)
   local lRet   := .F.
   local aArea  := {}
   local cQuery := ""
   local oQuery := nil

   default cAliasQry  := getNextAlias()
   default cHawb      := ""
   default lGetAll    := .F.

   cQuery := " SELECT SWV.R_E_C_N_O_ RECNO "
   cQuery +=   " FROM " + RetSqlName("SWV") + " SWV "
   cQuery += " WHERE "
   cQuery +=   " SWV.WV_FILIAL = ? "
   cQuery +=   " AND SWV.WV_HAWB = ? "
   cQuery +=   " AND SWV.D_E_L_E_T_ = ? "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString( 1, xFilial("SW7") ) // W7_FILIAL
   oQuery:SetString( 2, cHawb ) // W7_HAWB
   oQuery:SetString( 3, ' ' ) // SWV.D_E_L_E_T_ 
   cQuery := oQuery:GetFixQuery()

   cAliasQry  := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   lRet := (cAliasQry)->(!eof())

   if lRet .and. lGetAll

      aArea := SWV->(getArea())

      while (cAliasQry)->(!eof())
         SWV->(dbGoto( (cAliasQry)->RECNO ))
         if SWV->(recno()) == (cAliasQry)->RECNO
            aAdd( _aItsDUIMP, { SWV->WV_SEQDUIM, SWV->WV_ID } )
         endif
         (cAliasQry)->(dbSkip())
      enddo

      _nQtdeItem := len(_aItsDUIMP)

      restArea(aArea)
      (cAliasQry)->(dbCloseArea())

   endif

return lRet

/*
Função     : getProd
Objetivo   : Retorna os dados para estrutura "produto"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getProd(lFoundEV2)
   local cJson := ''

   default lFoundEV2   := .F.

   private cIntCpfCnpj := ""

   /*
   "codigo": 10,
   "versao": "1",
   "cnpjRaiz": "00000000"
   */

   if lFoundEV2

      if !empty(EV2->EV2_IDPTCP) // Código do produto.
         cJson += '"codigo":' + alltrim(EV2->EV2_IDPTCP)
      endif

      if !empty(EV2->EV2_VRSACP) // Versão do produto.
         cJson += if(!empty(cJson), ',', '')
         cJson += '"versao":"' + alltrim(EV2->EV2_VRSACP) + '"'
      endif

      if !empty(EV2->EV2_CNPJRZ) // Cnpj raiz do operador estrangeiro.
         cIntCpfCnpj := alltrim(EV2->EV2_CNPJRZ)
         If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICDU101_EV2_CNPJRZ_PRODUTO"),)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"niResponsavel":"' + alltrim(cIntCpfCnpj) + '"'
      endif

   endif

return cJson

/*
Função     : getCaracImp
Objetivo   : Retorna os dados para estrutura "caracterizacaoImportacao"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCaracImp(lFoundEV2)
   local cJson := ''

   default lFoundEV2   := .F.

   /*
   "indicador": "IMPORTACAO_DIRETA", 
   "ni": "00000000000191"
   */

   if lFoundEV2

      if !empty(EV2->EV2_IMPCO)
         cJson += '"indicador":"' + if(alltrim(EV2->EV2_IMPCO) == "1",'IMPORTACAO_POR_CONTA_E_ORDEM', 'IMPORTACAO_DIRETA') + '"' // Indicador de importação por terceiros. [ 2 = IMPORTACAO_DIRETA, 1 = IMPORTACAO_POR_CONTA_E_ORDEM ]
         if alltrim(EV2->EV2_IMPCO) == "1" .and. !empty(EV2->EV2_CNPJAD)
            cJson += ',"ni":"' + alltrim(EV2->EV2_CNPJAD) + '"' // CNPJ do adquirente. Observação: Este atributo é informado apenas quando selecionada a opção 'IMPORTACAO_POR_CONTA_E_ORDEM'
         endif
      endif

   endif

return cJson

/*
Função     : getExpFab
Objetivo   : Retorna os dados para estrutura "indicadorExportadorFabricante"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getExpFab(lFoundEV2, cIndExpFab)
   local cJson := ''

   default lFoundEV2   := .F.
   default cIndExpFab  := ""

   /*
   "codigo": "EXPORTADOR_DIFERENTE_FABRICANTE"
   */

   if lFoundEV2

      if !empty(EV2->EV2_FABFOR) // 1=Fabricante / Produtor é o Exportador; 2=Fabricante / Produtor não é o Exportador; 3=O Fabricante / Produtor é Desconhecido 
         cIndExpFab :=  if( alltrim(EV2->EV2_FABFOR) == "1" ,'EXPORTADOR_IGUAL_FABRICANTE', 'EXPORTADOR_DIFERENTE_FABRICANTE')
         cJson += '"codigo":"' + cIndExpFab + '"' // Código da relação exportador x fabricante. [ EXPORTADOR_DIFERENTE_FABRICANTE, EXPORTADOR_IGUAL_FABRICANTE ]
      endif

   endif

return cJson

/*
Função     : getFabric
Objetivo   : Retorna os dados para estrutura "fabricante"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getFabric(lFoundEV2, cInfFab)
   local cJson := ''

   default lFoundEV2   := .F.
   default cInfFab     := ""

   private cIntCpfCnpj := ""

   /*
   "codigo": "2104",
   "versao": "1",
   "cnpjRaiz": "00000000",
   "pais": {
      "codigo": "BR"
   }
   */

   if lFoundEV2

      if !empty(EV2->EV2_TINFA)
         cJson += '"codigo":"' + alltrim(EV2->EV2_TINFA) + '"' // Código do Fabricante.
      endif

      if !empty(EV2->EV2_VRSFAB)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"versao":"' + alltrim(EV2->EV2_VRSFAB) + '"' // Versão do fabricante.
      endif

      if !empty(EV2->EV2_CNPJRZ)
         cJson += if(!empty(cJson), ',', '')
         cIntCpfCnpj := alltrim(EV2->EV2_CNPJRZ)
         If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICDU101_EV2_CNPJRZ_OPERADOR"),)
         cJson += '"niOperador":"' + alltrim(cIntCpfCnpj) + '"' // CNPJ raiz da empresa responsável.
      endif

      if !empty(EV2->EV2_PAIOME)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"pais":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_PAIOME) + '"' // Código do país de origem no formato ISO (3166-1 alfa-2)
         cJson += '}'
      endif

      cInfFab := cJson

   endif

return cJson

/*
Função     : getExport
Objetivo   : Retorna os dados para estrutura "exportador"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getExport(lFoundEV2, cInfInd, cInfFab)
   local cJson := ''

   default lFoundEV2  := .F.
   default cInfInd    := ""
   default cInfFab    := ""

   private cIntCpfCnpj := ""

   /*
   "codigo": "CN001",
   "versao": "1",
   "cnpjRaiz": "00000000",
   "pais": {
      "codigo": "BR"
   }
   */

   if lFoundEV2

      // Observação: Quando o atributo "exportadorIndicadorFabricante" for preenchido com o valor "EXPORTADOR_IGUAL_FABRICANTE", os valores informados neste grupo devem ser idênticos aos valores informados no grupo "Fabricante".
      if cInfInd == "EXPORTADOR_IGUAL_FABRICANTE"
         cJson := cInfFab
      else
         if !empty(EV2->EV2_TINFO)
            cJson += '"codigo":"' + alltrim(EV2->EV2_TINFO) + '"' // Código do exportador estrangeiro (TIN).
         endif

         if !empty(EV2->EV2_VRSFOR)
            cJson += if(!empty(cJson), ',', '')
            cJson += '"versao":"' + alltrim(EV2->EV2_VRSFOR) + '"' // Versão do exportador.
         endif

         if !empty(EV2->EV2_CNPJRZ)
            cJson += if(!empty(cJson), ',', '')
            cIntCpfCnpj := alltrim(EV2->EV2_CNPJRZ)
            If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICDU101_EV2_CNPJRZ_EXPORTADOR"),)
            cJson += '"niOperador":"' + alltrim(cIntCpfCnpj) + '"' // CNPJ raiz da empresa responsável.
         endif

         if !empty(EV2->EV2_PAISPR)
            cJson += if(!empty(cJson), ',', '')
            cJson += '"pais":{'
            cJson +=    '"codigo":"' + alltrim(EV2->EV2_PAISPR) + '"' // Código do país de origem no formato ISO (3166-1 alfa-2).
            cJson += '}'
         endif

      endif

   endif

return cJson

/*
Função     : getIndCmpVd
Objetivo   : Retorna os dados para estrutura "indicadorCompradorVendedor"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getIndCmpVd(lFoundEV2)
   local cJson     := ''
   local cVincCO   := ''

   default lFoundEV2 := .F.

   /*
   "codigo": "NAO_HA_VINCULACAO"
   */

   if lFoundEV2

      if !empty(EV2->EV2_VINCCO) // 1=Sem Vinculacao;2=Com vinculacao, sem influencia no preco;3=Com vinculacao, com influencia no preco
         cVincCO := alltrim(EV2->EV2_VINCCO)
         cJson += '"codigo":"' + if( cVincCO == "1" , 'NAO_HA_VINCULACAO', if( cVincCO == "2" , 'VINCULACAO_SEM_INFLUENCIA_PRECO' , 'VINCULACAO_COM_INFLUENCIA_PRECO') ) + '"' // Código de vinculação comprador x vendedor. [ NAO_HA_VINCULACAO, VINCULACAO_SEM_INFLUENCIA_PRECO, VINCULACAO_COM_INFLUENCIA_PRECO ]
      endif

   endif

return cJson

/*
Função     : getMercad
Objetivo   : Retorna os dados para estrutura "mercadoria"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getMercad(lFoundEV2)
   local cJson     := ''
   local cAplME    := ''

   default lFoundEV2 := .F.

   /*
   "tipoAplicacao": {
      "codigo": "CONSUMO"
   },
   "condicao": "NOVA",
   "unidadeComercial": "SACAS",
   "quantidadeComercial": 100.5,
   "quantidadeMedidaEstatistica": 12.12345,
   "pesoLiquido": 100,
   "moedaNegociada": {
      "codigo": "USD"
   },
   "valorUnitarioMoedaNegociada": 10,
   "descricao": "Texto de exemplo."
   */

   if lFoundEV2

      if !empty(EV2->EV2_APLME) // 1=Consumo;2=Revenda 
         cJson += '"tipoAplicacao":{'
         cAplME := alltrim(EV2->EV2_APLME) 
         cJson +=    '"codigo":"' + if( cAplME == "1", 'CONSUMO', if( cAplME == "2", 'REVENDA' , 'OUTRA' ) ) + '"' // Destinação da mercadoria de acordo com o domínio a seguir. [ CONSUMO, INCORPORACAO_ATIVO_FIXO, INDUSTRIALIZACAO, REVENDA, OUTRA ]
         cJson += '}'
      endif

      if !empty(EV2->EV2_MATUSA) // 1=Usado;2=Nao Usado
         cJson += if(!empty(cJson), ',', '')
         cJson += '"condicao":"' + if( alltrim(EV2->EV2_MATUSA) == "1", 'USADA', 'NOVA' ) + '"' // Indica se a mercadoria é nova ou usada. [ NOVA, USADA ]
      endif

      if !empty(EV2->EV2_NMCOM)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"unidadeComercial":"' + alltrim(EV2->EV2_NMCOM) + '"' // Unidade de medida utilizada na comercialização da mercadoria.
      endif

      if val(StrTransf( StrTransf( alltrim( EV2->EV2_QTCOM ), ".","") , ",",".")) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"quantidadeComercial": ' + StrTransf( StrTransf( alltrim( EV2->EV2_QTCOM ), ".","") , ",",".") + '' // Quantidade da mercadoria na unidade de medida comercial.
      endif

      if val(StrTransf( StrTransf( alltrim( EV2->EV2_QT_EST ), ".","") , ",",".")) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"quantidadeMedidaEstatistica": ' + StrTransf( StrTransf( alltrim( EV2->EV2_QT_EST ), ".","") , ",",".") + '' // Quantidade na unidade de medida estatística associada à NCM do produto.
      endif

      if val(StrTransf( StrTransf( alltrim( EV2->EV2_PESOL ), ".","") , ",",".")) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"pesoLiquido": ' + StrTransf( StrTransf( alltrim( EV2->EV2_PESOL ), ".","") , ",",".") + '' // Peso líquido, em quilogramas, que corresponde ao quantitativo total das mercadorias do item.
      endif

      if !empty((EV2->EV2_MOE1))
         cJson += if(!empty(cJson), ',', '')
         cJson += '"moedaNegociada": {'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_MOE1) + '"' // Código da Moeda utilizada para a negociação da mercadoria e usada na expedição da fatura comercial (ISO-4217).
         cJson += '}'
      endif

      if val(StrTransf( StrTransf( alltrim( EV2->EV2_VLMLE ), ".","") , ",",".")) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"valorUnitarioMoedaNegociada": ' + StrTransf( StrTransf( alltrim( EV2->EV2_VLMLE ), ".","") , ",",".") + '' // Valor unitário da mercadoria na condição de venda.
      endif

      if !empty((EV2->EV2_DSCCIT))
         cJson += if(!empty(cJson), ',', '')
         cJson += '"descricao":"' + comex.generics.SetStringJson(EV2->EV2_DSCCIT) + '"' // Descrição complementar da mercadoria.
      endif

   endif

return cJson

/*
Função     : getCondVend
Objetivo   : Retorna os dados para estrutura "condicaoVenda"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCondVend(lFoundEV2, cLote, cHawb, cSeqDui)
   local cJson      := ''
   local cInfAcrDed := ''

   default lFoundEV2  := .F.
   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
   "metodoValoracao": {
      "codigo": 1
   },
   "incoterm": {
      "codigo": "FOB",
      "complemento": "1"
   },
   "acrescimosDeducoes": [
      {
         "tipo": "ACRESCIMO",
         "moeda": {
            "codigo": "USD",
            "valor": 100.12
         },
         "denominacao": {
            "codigo": 1
         }
      }
   ]
   */

   if lFoundEV2

      if !empty(EV2->EV2_METVAL)
         cJson += '"metodoValoracao":{'
         cJson +=    '"codigo":' + alltrim(str(Val(EV2->EV2_METVAL))) // Código do método de valoração.
         cJson += '}' 
      endif

      if !empty(EV2->EV2_INCOTE)
         cJson += if(!empty(cJson), ',', '') 
         cJson += '"incoterm":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_INCOTE) + '"' // Código da Condição de Venda
         cJson += '}'
      endif

   endif

   cInfAcrDed := getAcrDed(cLote)
   if !empty(cInfAcrDed)
      cJson += if(!empty(cJson), ',', '') 
      cJson += '"acrescimosDeducoes":['
      cJson +=    cInfAcrDed
      cJson += ']'
   endif

return cJson

/*
Função     : getAcrDed
Objetivo   : Retorna os dados para estrutura "acrescimosDeducoes"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getAcrDed(cLote, cHawb, cSeqDui)
   local cJson := ''
   local cDeducao := ''

   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   cJson := getInfAcDe("EV3", cLote, cHawb, cSeqDui)
   cDeducao := getInfAcDe("EV4", cLote, cHawb, cSeqDui)
   if !empty(cDeducao)
      cJson +=  if(!empty(cJson), ',', '') + cDeducao
   endif

return cJson

/*
Função     : getInfAcDe
Objetivo   : Retorna os dados dos acréscimos ou deduções do item
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getInfAcDe(cAliasTab, cLote, cHawb, cSeqDui)
   local aArea      := {}
   local cJson      := ''

   default cAliasTab  := ""
   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
      {
         "tipo": "ACRESCIMO", // [ ACRESCIMO, DEDUCAO ]
         "moeda": {
            "codigo": "USD",
            "valor": 100.12
         },
         "denominacao": {
            "codigo": 1
         }
      }
   */

   dbSelectArea(cAliasTab)
   aArea := (cAliasTab)->(getArea())

   (cAliasTab)->(dbSetOrder(3)) // EV3_FILIAL+EV3_LOTE+EV3_HAWB+EV3_SEQDUI ou EV4_FILIAL+EV4_LOTE+EV4_HAWB+EV4_SEQDUI
   if (cAliasTab)->(dbSeek( xFilial(cAliasTab)+ cLote + cHawb + cSeqDui ))

      while (cAliasTab)->(!eof()) .and. (cAliasTab)->(&(IndexKey())) == xFilial(cAliasTab) + cLote + cHawb + cSeqDui

      if !empty((cAliasTab)->&(cAliasTab + "_MOE")) .or. val((cAliasTab)->&(cAliasTab + "_VLMLE")) > 0 
         cJson += '{'
         cJson +=    '"tipo":"' + if( cAliasTab == "EV3", 'ACRESCIMO', 'DEDUCAO' ) + '",' // Tipo de Operação (acréscimo ou dedução).
         cJson +=    '"moeda":{'
         cJson +=       '"codigo":"' + alltrim((cAliasTab)->&(cAliasTab + "_MOE")) + '",' // Código da Moeda negociada (ISO-4217).
         cJson +=       '"valor": ' + cValToChar(val((cAliasTab)->&(cAliasTab + "_VLMLE"))) + '' // Valor, na moeda negociada, acrescentado no/deduzido do valor da condição de venda.
         cJson +=    '}'

         if !empty(if( cAliasTab == "EV3", EV3->EV3_ACRES, EV4->EV4_DEDU ))
            cJson += if(!empty(cJson), ',', '') 
            cJson +=    '"denominacao":{'
            cJson +=       '"codigo":"' + alltrim(if( cAliasTab == "EV3", EV3->EV3_ACRES, EV4->EV4_DEDU )) + '"' // Código do acréscimo ou da dedução escolhida.
            cJson +=    '}'
         endif
         cJson += '},'
      endif

      (cAliasTab)->(dbSkip())
      end
      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getLPCOS
Objetivo   : Retorna os dados para estrutura "lpcos"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getLPCOS(cLote, cSeqDui)
   local aArea      := {}
   local cJson      := ''

   default cLote      := EV1->EV1_LOTE
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
   {
      "numero": "I2000000063"
   }
   */

   dbSelectArea("EVE")
   aArea := EVE->(getArea())

   EVE->(dbSetOrder(2)) // EVE_FILIAL+EVE_LOTE+EVE_SEQDUI
   if EVE->(dbSeek( xFilial("EVE") + cLote + cSeqDui ))

      while EVE->(!eof()) .and. EVE->(&(IndexKey())) == xFilial("EVE") + cLote + cSeqDui

         if !empty(EVE->EVE_LPCO)
            cJson += '{'
            cJson +=    '"numero":"' + alltrim(EVE->EVE_LPCO) + '"' // Número do um LPCO.
            cJson += '},'
         endif

         EVE->(dbSkip())
      end

      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getCertMerc
Objetivo   : Retorna os dados para estrutura "certificadoMercosul"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCertMerc(cLote, cHawb, cSeqDui)
   local aArea      := {}
   local cJson      := ''
   local cIdCert    := ''

   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
   {
      "tipo": "CCPTC",
      "numero": "PY-06000AA0000A-0001",
      "quantidade": "1.12345"
   }
   */

   dbSelectArea("EVI")
   aArea := EVI->(getArea())

   EVI->(dbSetOrder(2)) // EVI_FILIAL+EVI_LOTE+EVI_HAWB+EVI_SEQDUI
   if EVI->(dbSeek( xFilial("EVI") + cLote + cHawb + cSeqDui ))

      while EVI->(!eof()) .and. EVI->(&(IndexKey())) == xFilial("EVI") + cLote + cHawb + cSeqDui

         if !empty(EVI->EVI_IDCERT) .or. !empty(EVI->EVI_DEMERC) .or. Val(EVI->EVI_QTDCER) > 0

            cJson += '{'
            cIdCert := alltrim(EVI->EVI_IDCERT) // 1=Sem Certificado;2=CCPTC;3=CCROM
            cJson +=    '"tipo":"' + if( cIdCert == "2",'CCPTC', if( cIdCert == "3", 'CCROM', 'SEM_CERTIFICADO'))  + '",' // Tipo de certificado Mercosul. [ SEM_CERTIFICADO, CCPTC, CCROM ]
            cJson +=    '"numero":"' + alltrim(EVI->EVI_DEMERC) + '",' // Número do Certificado Mercosul.
            cJson +=    '"quantidade":"' +  StrTransf( StrTransf( alltrim( EVI->EVI_QTDCER), ".","") , ",",".") + '"' // Quantidade da mercadoria na unidade estatística.
            cJson += '},'

         endif

         EVI->(dbSkip())
      end
      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getDocVincs
Objetivo   : Retorna os dados para estrutura "declaracoesVinculadas"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getDocVincs(cLote, cHawb, cSeqDui)
   local aArea      := {}
   local cJson      := ''
   local cTipVin    := ''

   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

	/*
   {
      "tipo": "DUE",
      "numero": "19BR00000004936",
      "numeroItem": 10001
   }
   */

   dbSelectArea("EV6")
   aArea := EV6->(getArea())

   EV6->(dbSetOrder(3)) // EV6_FILIAL+EV6_LOTE+EV6_HAWB+EV6_SEQDUI
   if EV6->(dbSeek( xFilial("EV6") + cLote + cHawb + cSeqDui ))

      while EV6->(!eof()) .and. EV6->(&(IndexKey())) == xFilial("EV6") + cLote + cHawb + cSeqDui

         if !empty(EV6->EV6_TIPVIN) .or. !empty(EV6->EV6_DOCVIN)

            cJson += '{'

            if !empty(EV6->EV6_TIPVIN) // 1=DUIMP;2=DUE;3=DI;4=DE
               cTipVin := alltrim(EV6->EV6_TIPVIN)
               cJson +=    '"tipo":"' + if( cTipVin == "1",'DUIMP', if( cTipVin == "2", 'DUE', if( cTipVin == "3", 'DI', 'DE')))  + '"' // Tipo de declaração vinculada. [ DUIMP, DUE, DI, DE ]
            endif

            if !empty(EV6->EV6_DOCVIN)
               cJson += if(!empty(cJson), ',', '') 
               cJson +=    '"numero":"' + alltrim(EV6->EV6_DOCVIN) + '"' // Número da Declaração.
            endif

            // Campo não existe na estrutura da tabela EIK
            /*if val(EV6->EV6_SEQDUI) > 0
               cJson += if(!empty(cJson), ',', '') 
               cJson +=    '"numeroItem": ' +  cValToChar( val( EV6->EV6_SEQDUI ) ) + '' // Número do item/adição da declaração.
            endif*/

            cJson += '},'

         endif

         EV6->(dbSkip())
      end
      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getDadosCam
Objetivo   : Retorna os dados para estrutura "dadosCambiais"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getDadosCam(lFoundEV2)
   local cJson      := ''
   local cCobCamb   := ''

   default lFoundEV2 := .F.

   /*
   "coberturaCambial": {
      "codigo": "ATE_180_DIAS"
   },
   "numeroROF": "180A0A0A",
   "instituicaoFinanciadora": {
      "codigo": 99
   },
   "valorCoberturaCambial": "100.12",
   "motivoSemCobertura": {
      "codigo": 52
   }
   */

   if lFoundEV2

      if !empty(EV2->EV2_TIPCOB) // 1=180 DD;2=De 181 a 360 DD;3=Acima de 360 DD;4=Sem Cobertura
         cJson += '"coberturaCambial":{'
         cCobCamb := alltrim(EV2->EV2_TIPCOB)
         cJson +=    '"codigo":"' + if( cCobCamb == "1", 'ATE_180_DIAS', if( cCobCamb == "2", 'DE_180_ATE_360' , if( cCobCamb == "3", 'ACIMA_360' , 'SEM_COBERTURA' ) ) ) + '"' // Código da cobertura cambial. [ ATE_180_DIAS, DE_180_ATE_360, ACIMA_360, SEM_COBERTURA ]
         cJson += '}'
      endif

      if !empty(EV2->EV2_NRROF)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"numeroROF":"' + alltrim(EV2->EV2_NRROF) + '"' // Número do ROF no BACEN.
      endif

      if !empty(EV2->EV2_INSTFI)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"instituicaoFinanciadora":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_INSTFI) + '"' // Código da instituição financiadora.
         cJson += '}'
      endif

      if val(StrTransf( StrTransf( alltrim( EV2->EV2_VL_FIN  ), ".","") , ",",".")) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"valorCoberturaCambial": ' + StrTransf( StrTransf( alltrim( EV2->EV2_VL_FIN  ), ".","") , ",",".") + '' // Valor da cobertura cambial.
      endif

      if !empty(EV2->EV2_MOTIVO)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"motivoSemCobertura":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_MOTIVO) + '"' // Código do Motivo para ausência de cobertura cambial.
         cJson += '}'
      endif

   endif

return cJson

/*
Função     : getDadosAttDuimp
Objetivo   : Retorna os dados para estrutura "atributosDuimp"
Parâmetro  :
Retorno    :
Autor      : Nícolas Castellani Brisque
Data/Hora  : Fevereiro/2025
Obs.       :
*/
static function getDadosAttDuimp(lFoundEV2)
   local cRet        := ''
   local oJson       := JsonObject():New()
   default lFoundEV2 := .F.

   /* Exemplo da tag de atributosDuimp:
   "atributosDuimp": [
         {
         "codigo": "ATT_0001",
         "valor": "01011100"
         }
      ],
   */
   If lFoundEV2
      If !Empty(EV2->EV2_ATRIBU)
         // O objeto já vem formato do POUI
         oJson:FromJson(EV2->EV2_ATRIBU)
         cRet := oJson:getJsonText("atributosDuimp")
      EndIf
   EndIf
   FreeObj(oJson)

Return cRet

/*
Função     : getAtoDuimp
Objetivo   : Retorna os dados para estrutura "atributosFundamentoLegalDuimp" para Drawback
Autor      : THTS - Tiago Tudisco
Data/Hora  : Março/2025
*/
static function getAtoDuimp(cModal, cAto, cSeqSis)
   local cJson       := ''

   /* EXEMPLO da tag de atributosFundamentoLegalDuimp para DrawBack

    "atributosFundamentoLegalDuimp": [
      {
        "codigo": "ATT_15165",
        "valor": "230000123"
      },
      {
        "codigo": "ATT_15186",
        "valor": "001"
      }
    ]
   */
   If !Empty(cAto)
      If cModal == SUSPENSAO
         cJson += '{'
         cJson += '"codigo":"ATT_15165",'
         cJson += '"valor":"' + cAto + '"'
         cJson += '},'
      
         cJson += '{'
         cJson += '"codigo":"ATT_15186",'
         cJson += '"valor":"' + cSeqSis + '"'
         cJson += '}'
      ElseIf cModal == ISENCAO
         cJson += '{'
         cJson += '"codigo":"ATT_15185",'
         cJson += '"valor":"' + cAto + '"'
         cJson += '},'
      
         cJson += '{'
         cJson += '"codigo":"ATT_15186",'
         cJson += '"valor":"' + cSeqSis + '"'
         cJson += '}'
      EndIf
   EndIf
Return cJson

/*
Função     : getDadosTrib
Objetivo   : Retorna os dados para estrutura "Tributos"
Parâmetro  :
Retorno    :
Autor      : THTS - Tiago Tudisco
Data/Hora  : Julho/2024
Obs.       :
*/
static function getDadosTrib(cHawb, cLote, cSeqDUI)
   local cJson      := ''
   local cRegime
   local oAtributos

   /* EXEMPLO da tag de Tributos
   Tributos - Enum aceitos:  II, IPI, PIS, COFINS, CIDE, ANTIDUMPING, MEDIDAS, SALVAGUARDA, MULTA

   "tributos": [
      {
         "tributo": {
         "codigo": "IPI"
         },
         "regime": {
         "codigo": 1
         },
         "fundamento": {
         "codigo": 1001
         },
         "atributos": [
         {
            "codigo": "ATT_0001",
            "valor": "01011100"
         }
         ]
      }
   ]
   */

   EVG->(dbSetOrder(2)) // EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP

   if EVG->(dbSeek( xFilial("EVG") + cHawb + cLote + cSeqDUI))
      While EVG->(!EOF()) .And. EVG->EVG_FILIAL == xFilial("EVG") .And. EVG->EVG_HAWB == cHawb .And. EVG->EVG_LOTE == cLote .And. EVG->EVG_SEQDUI == cSeqDUI
         If !Empty(EVG->EVG_FUNDLE)
            IIF(!Empty(cJson),cJson += ",",)
            cRegime := retAsc(EVG->EVG_REGIME, 1, .F.) // Função para converter A, B, C, em 10, 11, 12...
            if EVG->EVG_IDIMP == "1" //II
               //tributo
               cJson += '{'
               cJson += '"tributo":{'
               cJson +=    '"codigo":"' + 'II' + '"' // Código do tributo.
               cJson +=    '},'
               //regime
               cJson += '"regime":{'
               cJson +=    '"codigo":' + cRegime // Código do regime.
               cJson +=    '},'
               //fundamento
               cJson += '"fundamento":{'
               cJson +=    '"codigo":"' + EVG->EVG_FUNDLE + '"' // Código do fundamento.
               cJson +=    '},'
               //atributos
               cJson += '"atributos":'
               If !Empty(EVG->EVG_ATRIBU)
                  oAtributos := JsonObject():New()
                  oAtributos:FromJson(EVG->EVG_ATRIBU)
                  cJson += oAtributos:getJsonText("atributos")
                  FreeObj(oAtributos)
               Else
                  cJson += '[]'
               EndIf

               cJson += '}'
            endif

            if EVG->EVG_IDIMP == "2" //IPI
               //tributo
               cJson += '{'
               cJson += '"tributo":{'
               cJson +=    '"codigo":"' + 'IPI' + '"' // Código do tributo.
               cJson +=    '},'
               //regime
               cJson += '"regime":{'
               cJson +=    '"codigo":' + cRegime // Código do regime.
               cJson +=    '},'
               //fundamento
               cJson += '"fundamento":{'
               cJson +=    '"codigo":"' + EVG->EVG_FUNDLE + '"' // Código do fundamento.
               cJson +=    '},'
               //atributos
               cJson += '"atributos":'
               If !Empty(EVG->EVG_ATRIBU)
                  oAtributos := JsonObject():New()
                  oAtributos:FromJson(EVG->EVG_ATRIBU)
                  cJson += oAtributos:getJsonText("atributos")
                  FreeObj(oAtributos)
               Else
                  cJson += '[]'
               EndIf

               cJson += '}'
            endif

            if EVG->EVG_IDIMP == "3"  //PIS
               //tributo
               cJson += '{'
               cJson += '"tributo":{'
               cJson +=    '"codigo":"' + 'PIS' + '"' // Código do tributo.
               cJson +=    '},'
               //regime
               cJson += '"regime":{'
               cJson +=    '"codigo":' + cRegime // Código do regime.
               cJson +=    '},'
               //fundamento
               cJson += '"fundamento":{'
               cJson +=    '"codigo":"' + EVG->EVG_FUNDLE + '"' // Código do fundamento.
               cJson +=    '},'
               //atributos
               cJson += '"atributos":'
               If !Empty(EVG->EVG_ATRIBU)
                  oAtributos := JsonObject():New()
                  oAtributos:FromJson(EVG->EVG_ATRIBU)
                  cJson += oAtributos:getJsonText("atributos")
                  FreeObj(oAtributos)
               Else
                  cJson += '[]'
               EndIf

               cJson += '}'
            endif

            if EVG->EVG_IDIMP == "4"  //COFINS
               //tributo
               cJson += '{'
               cJson += '"tributo":{'
               cJson +=    '"codigo":"' + 'COFINS' + '"' // Código do tributo.
               cJson +=    '},'
               //regime
               cJson += '"regime":{'
               cJson +=    '"codigo":' + cRegime // Código do regime.
               cJson +=    '},'
               //fundamento
               cJson += '"fundamento":{'
               cJson +=    '"codigo":"' + EVG->EVG_FUNDLE + '"' // Código do fundamento.
               cJson +=    '},'
               //atributos
               cJson += '"atributos":'
               If !Empty(EVG->EVG_ATRIBU)
                  oAtributos := JsonObject():New()
                  oAtributos:FromJson(EVG->EVG_ATRIBU)
                  cJson += oAtributos:getJsonText("atributos")
                  FreeObj(oAtributos)
               Else
                  cJson += '[]'
               EndIf

               cJson += '}'
            endif

            if EVG->EVG_IDIMP == "5" //ANTIDUMPING
               //tributo
               cJson += '{'
               cJson += '"tributo":{'
               cJson +=    '"codigo":"' + 'ANTIDUMPING' + '"' // Código do tributo.
               cJson +=    '},'
               //Regime - ANTIDUMPING não possui Regime
               cJson += '"regime":{'
               cJson +=    '"codigo": 0'
               cJson +=    '},'
               //fundamento
               cJson += '"fundamento":{'
               cJson +=    '"codigo":"' + EVG->EVG_FUNDLE + '"' // Código do fundamento.
               cJson +=    '},'
               //atributos
               cJson += '"atributos":'
               If !Empty(EVG->EVG_ATRIBU)
                  oAtributos := JsonObject():New()
                  oAtributos:FromJson(EVG->EVG_ATRIBU)
                  cJson += oAtributos:getJsonText("atributos")
                  FreeObj(oAtributos)
               Else
                  cJson += '[]'
               EndIf

               cJson += '}'
            endif
         EndIf
         EVG->(dbSkip())
      End
   endif

Return cJson
/*
Função     : IntegVlrIts
Objetivo   : Realiza a integração da recuperação dos impostos por item da DUIMP
Parâmetro  : 
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       :
*/
static function IntegVlrIts(oEasyJS, cUrlInteg, cHawb, cLote, nRecEV1, oLogView)
   local aRet       := {}
   local aItsDUIMP  := {}
   local nTotItens  := 0
   local aProcs     := {}
   local lRet       := .T.
   local cErros     := ""
   local aAreaEV1   := {}
   local aAreaEV2   := {}
   local aAreaEIJ   := {}
   local nCount     := 0
   local nSequen    := 0
   local jItemDuimp := nil
   local cItem      := ""
   local lAbortar   := .F.

   default cUrlInteg := AVGetUrl()
   default cHawb     := EV1->EV1_HAWB
   default cLote     := EV1->EV1_LOTE
   default nRecEV1   := EV1->(recno())

   aRet := {.F., .T.} // [1] erro de conexão, [2] erro da camada de negócio

   if DUIMP2310()

      aItsDUIMP := aClone(_aItsDUIMP)
      nTotItens := len(aItsDUIMP)

      getLog(STR0037 + " " + EV1->EV1_DI_NUM + " " + STR0012 + " " + alltrim(EV1->EV1_VERSAO) + " - " + STR0038 + " " + aItsDUIMP[1][1] + " " + STR0039 + " " + aItsDUIMP[nTotItens][1], oLogView) // "Recuperando valores dos impostos calculados dos itens da Duimp" ## versão: ## "Itens da Duimp" ## "até"

      cErros := ""                                                            

      dbSelectArea("EV1")
      aAreaEV1 := EV1->(getArea())
      EV1->(dbGoTo(nRecEV1))

      dbSelectArea("EV2")
      aAreaEV2 := EV2->(getArea())
      EV2->(dbSetOrder(3)) // EV2_FILIAL + EV2_LOTE + EV2_HAWB + EV2_SEQDUI

      dbSelectArea("EIJ")
      aAreaEIJ := EIJ->(getArea())
      EIJ->(dbSetOrder(3)) // EIJ_FILIAL + EIJ_HAWB + EIJ_IDWV

      aProcs := {}                                                                     //pega os impostos da duimp item a item
      oEasyJS:runJS( "IntItemDUIMP(retAdvpl, retAdvplChunk, retAdvplError);", {|x| lRet := DU101RetInt(x,, oLogView, @aProcs) }, {|x| lAbortar := .T. , cErros := x } )

      cErros := ""
      nCount := 0
      for nSequen := 1 to len(aItsDUIMP)
         jItemDuimp := JsonObject():New()
         jItemDuimp['numDuimp'] := alltrim(EV1->EV1_DI_NUM)
         jItemDuimp['versaoDuimp'] := alltrim(EV1->EV1_VERSAO)
         jItemDuimp['seqDuimp_url'] := val(aItsDUIMP[nSequen][1])
         jItemDuimp['seqDuimp'] := aItsDUIMP[nSequen][1]
         jItemDuimp['id'] := aItsDUIMP[nSequen][2]
         cItem := jItemDuimp:toJson()
         oEasyJS:runJS("addItemDUIMP(retAdvpl,'" + cItem + "')" , {|x| if( DU101RetInt(x), nCount += 1 , nil) }, {|x| cErros += x } )
      next

      cErros := ""
      oEasyJS:wait({|| lAbortar .or. ( nTotItens == len(aProcs) .and. nTotItens == nCount ) }, 0 ) 
      oEasyJS:runJS( "lEndFor = true;", , {|x| cErros := x } )

      restArea(aAreaEV1)
      restArea(aAreaEV2)
      restArea(aAreaEIJ)

   endif

   if lAbortar
      getLog( STR0040 + " " + STR0041 + ": " + STR0060, oLogView) // "Falha ao recuperar os impostos dos itens da DUIMP." ## "Erro" ## "Não foi possivel consultar os tributos dos outros itens."
   endif

   aRet := {!lAbortar, lRet}

return aRet

/*
Função     : DU101RetInt
Objetivo   : Função para tratamento do retorno da API de tributos do item da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DU101RetInt(cRetJson, cErros, oLogView, aProcs)
   local lRet    := .F.
   local cRet    := ""
   local cSequen := ""
   local cMsgRet := ""

   default cRetJson   := ""
   default cErros     := ""
   default aProcs := {}
   cRet := Alltrim(lower(cRetJson))
   lRet := cRet == 'processou' .or. cRet == 'autenticado_ok' .or. cRet == 'adicionou'
   if !lRet .and. !empty(cRetJson)
      cSequen := ""
      cMsgRet := ""
      getLog( cRetJson, oLogView)  
      lRet := PrcRetIts(oLogView, cRetJson, @cSequen, @cMsgRet ) //pega os impostos da duimp item a item
      aAdd( aProcs, { cSequen, cMsgRet })
   endif

return lRet

/*
Função     : PrcRetIts
Objetivo   : Função para tratamento do retorno da API de tributos do item da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function PrcRetIts(oLogView, cResposta, cSequen, cMsgRet)
   local lRetNeg    := .F.
   local cId        := ""
   local jResposta  := nil
   local nRecEIJ    := 0
   local nRecEV2    := 0
   local cError     := ""
   local jRetorno   := nil
   local jItemDUIMP := nil

   default cResposta  := ""
   default cSequen    := ""
   default cMsgRet    := ""

   cMsgRet := STR0042 // "Falha no retorno."
   if !empty(cResposta)
      jResposta := JsonObject():new()
      cMsgRet += if( valtype(cResposta) == "C", " " + STR0043 + ": " + cResposta, "") // "Retorno"
      if valtype(jResposta:fromJson(cResposta)) == "U"

         cError := ""
         jItemDUIMP := jResposta["jItemDUIMP"]
         if valtype(jItemDUIMP) == "J"
            cId := jItemDUIMP["id"]
            cSequen := jItemDUIMP["seqDuimp"]
         endif
         jRetorno := jResposta["ret"]

         nRecEIJ := 0
         if !empty(cId) .and. EIJ->(dbSeek( xFilial("EIJ") + EV1->EV1_HAWB + cId )) 
            nRecEIJ := EIJ->(recno())
         endif

         nRecEV2 := 0
         if !empty(cSequen) .and. EV2->(dbSeek( xFilial("EV2") + EV1->EV1_LOTE + EV1->EV1_HAWB + cSequen ))
            nRecEV2 := EV2->(recno())
         endif

         lRetNeg := PrcRetItem(nRecEIJ, nRecEV2, @cError, jRetorno) //Pega os impostos item a item
         cMsgRet := if( lRetNeg , STR0044 + ": " + cSequen + ". ", STR0045 + ": " + cSequen + ". " + STR0041 + ": " + cError ) // "Realizado com sucesso a consulta dos tributos da sequência do item" ##  "Inconsistência ao consultar os tributos do item" ## "Erro"
                
      endif
      getLog( cMsgRet , oLogView)
      fwfreeobj(jResposta)
   endif

return lRetNeg

/*
Função     : PrcRetItem
Objetivo   : Função para tratamento do retorno da API de tributos do item da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function PrcRetItem( nRecEIJ, nRecEV2, cError, jResposta)
   local lRet       := .F.
   local aErros     := {}
   local nError     := 0
   local aTributos  := {}
   local nTributos  := 0
   local cTipo      := ""
   local jValores   := nil
   local jMemCal    := nil
   local aCposEIJ   := {}
   local aCposEV2   := {}
   local aValores   := {}

   default nRecEIJ   := 0
   default nRecEV2   := 0
   default cError    := ""

   if jResposta:HasProperty("errors")

      aErros := if(valtype(jResposta["errors"]) == "J", {jResposta["errors"]}, jResposta["errors"])
      for nError := 1 to len(aErros)
         if valtype(aErros[nError]) == "J" .and. aErros[nError]:HasProperty("code") .and. aErros[nError]:HasProperty("message")
            cError += "'" + alltrim(aErros[nError]["code"]) + "' - " + alltrim(aErros[nError]["message"])
         endif
      next
      cError := if(empty(cError), STR0046, cError) // "Erro indefinido."
      aCposEIJ := {}
      aVlrEIJ := {}
      aValores := {}
      aAdd( aCposEIJ, "EIJ_OBSTRB" )
      aAdd( aCposEV2, "EV2_OBSTRB" )
      aAdd( aValores, cError )

   elseif jResposta:HasProperty("tributosCalculados")

      aTributos := if(valtype(jResposta["tributosCalculados"]) == "J", { jResposta["tributosCalculados"]}, jResposta["tributosCalculados"])
      aCposEIJ := {}
      aVlrEIJ := {}
      aValores := {}
      aMemCal := {}
      for nTributos := 1 to len(aTributos)

         cTipo := ""
         jValores := nil
         jMemCal := nil

         if valtype(aTributos[nTributos]) == "J"
            if aTributos[nTributos]:HasProperty("tipo")
               cTipo := alltrim(aTributos[nTributos]["tipo"])
               lRet := lRet .or. cTipo $ "II|IPI|PIS|COFINS|ANTIDUMPING"
            endif
            if aTributos[nTributos]:HasProperty("valoresBRL")
               jValores := aTributos[nTributos]["valoresBRL"]
            endif
            if aTributos[nTributos]:HasProperty("memoriaCalculo")
               jMemCal := aTributos[nTributos]["memoriaCalculo"]
            endif
         endif

         if ValType(jMemCal) == "J" .and. cTipo $ "II|IPI|PIS|COFINS|ANTIDUMPING"
            aAdd( aMemCal, { cTipo, jMemCal})
         endif

         if ValType(jValores) == "J"
            do case
               case cTipo == "II"
                  aAdd( aCposEIJ, "EIJ_VLCII" ) // Vlr Calculado II
                  aAdd( aCposEIJ, "EIJ_VRDII" ) // Vlr Reduzir II
                  aAdd( aCposEIJ, "EIJ_VLDII" ) // Vlr Devido II
                  aAdd( aCposEIJ, "EIJ_VLSII" ) // Vlr Suspenso II
                  aAdd( aCposEIJ, "EIJ_VRCII" ) // Vlr Recolher II

                  aAdd( aCposEV2, "EV2_VLRCII" ) // Vlr Calculado II
                  aAdd( aCposEV2, "EV2_VRDII"  ) // Vlr Reduzir II
                  aAdd( aCposEV2, "EV2_VLDII"  ) // Vlr Devido II
                  aAdd( aCposEV2, "EV2_VLSII"  ) // Vlr Suspenso II
                  aAdd( aCposEV2, "EV2_VRCII"  ) // Vlr Recolher II

               case cTipo == "IPI"
                  aAdd( aCposEIJ, "EIJ_VLCIPI" ) // Vlr Calculado IPI
                  aAdd( aCposEIJ, "EIJ_VRDIPI" ) // Vlr Reduzir IPI
                  aAdd( aCposEIJ, "EIJ_VDIPI"  ) // Vlr Devido IPI
                  aAdd( aCposEIJ, "EIJ_VLSIPI" ) // Vlr Suspenso IPI
                  aAdd( aCposEIJ, "EIJ_VRCIPI" ) // Vlr Recolher IPI

                  aAdd( aCposEV2, "EV2_VLCIPI" ) // Vlr Calculado IPI
                  aAdd( aCposEV2, "EV2_VRDIPI" ) // Vlr Reduzir IPI
                  aAdd( aCposEV2, "EV2_VDIPI"  ) // Vlr Devido IPI
                  aAdd( aCposEV2, "EV2_VLSIPI" ) // Vlr Suspenso IPI
                  aAdd( aCposEV2, "EV2_VRCIPI" ) // Vlr Recolher IPI

               case cTipo == "PIS"
                  aAdd( aCposEIJ, "EIJ_VLCPIS" ) // Vlr Calculado PIS
                  aAdd( aCposEIJ, "EIJ_VRDPIS" ) // Vlr Reduzir PIS
                  aAdd( aCposEIJ, "EIJ_VDEPIS" ) // Vlr Devido PIS
                  aAdd( aCposEIJ, "EIJ_VLSPIS" ) // Vlr Suspenso PIS
                  aAdd( aCposEIJ, "EIJ_VRCPIS" ) // Vlr Recolher PIS

                  aAdd( aCposEV2, "EV2_VLCPIS" ) // Vlr Calculado PIS
                  aAdd( aCposEV2, "EV2_VRDPIS" ) // Vlr Reduzir PIS
                  aAdd( aCposEV2, "EV2_VDEPIS" ) // Vlr Devido PIS
                  aAdd( aCposEV2, "EV2_VLSPIS" ) // Vlr Suspenso PIS
                  aAdd( aCposEV2, "EV2_VRCPIS" ) // Vlr Recolher PIS

               case cTipo == "COFINS"
                  aAdd( aCposEIJ, "EIJ_VLCCOF" ) // Vlr Calculado COFINS
                  aAdd( aCposEIJ, "EIJ_VRDCOF" ) // Vlr Reduzir COFINS
                  aAdd( aCposEIJ, "EIJ_VDECOF" ) // Vlr Devido COFINS
                  aAdd( aCposEIJ, "EIJ_VLSCOF" ) // Vlr Suspenso COFINS
                  aAdd( aCposEIJ, "EIJ_VRCCOF" ) // Vlr Recolher COFINS

                  aAdd( aCposEV2, "EV2_VLCCOF" ) // Vlr Calculado COFINS
                  aAdd( aCposEV2, "EV2_VRDCOF" ) // Vlr Reduzir COFINS
                  aAdd( aCposEV2, "EV2_VDECOF" ) // Vlr Devido COFINS
                  aAdd( aCposEV2, "EV2_VLSCOF" ) // Vlr Suspenso COFINS
                  aAdd( aCposEV2, "EV2_VRCCOF" ) // Vlr Recolher COFINS

               case cTipo == "ANTIDUMPING" .And. AvFlags("TRIBUTACAO_DUIMP")
                  aAdd( aCposEIJ, "EIJ_VLC_DU" ) // Vlr Calculado ANTIDUMPING
                  aAdd( aCposEIJ, "EIJ_VLD_DU" ) // Vlr Devido ANTIDUMPING
                  aAdd( aCposEIJ, "EIJ_VLR_DU" ) // Vlr Recolher ANTIDUMPING

                  aAdd( aCposEV2, "EV2_VLC_DU" ) // Vlr Calculado ANTIDUMPING
                  aAdd( aCposEV2, "EV2_VLD_DU" ) // Vlr Devido ANTIDUMPING
                  aAdd( aCposEV2, "EV2_VLR_DU" ) // Vlr Recolher ANTIDUMPING

            endcase

            if cTipo $ "II|IPI|PIS|COFINS"
               aAdd( aValores, if( jValores:HasProperty("calculado"), jValores["calculado"], 0) )
               aAdd( aValores, if( jValores:HasProperty("aReduzir") , jValores["aReduzir"] , 0) )
               aAdd( aValores, if( jValores:HasProperty("devido")   , jValores["devido"]   , 0) )
               aAdd( aValores, if( jValores:HasProperty("suspenso") , jValores["suspenso"] , 0) )
               aAdd( aValores, if( jValores:HasProperty("aRecolher"), jValores["aRecolher"], 0) )
            elseif cTipo == "ANTIDUMPING" .And. AvFlags("TRIBUTACAO_DUIMP")
               aAdd( aValores, if( jValores:HasProperty("calculado"), jValores["calculado"], 0) )
               aAdd( aValores, if( jValores:HasProperty("devido")   , jValores["devido"]   , 0) )
               aAdd( aValores, if( jValores:HasProperty("aRecolher"), jValores["aRecolher"], 0) )
            endif

         endif

      next

      if len(aMemCal) > 0
         aAdd( aCposEIJ, "EIJ_OBSTRB" )
         aAdd( aCposEV2, "EV2_OBSTRB" )
         aAdd( aValores, FormatVlCal(aMemCal) )
      endif

   endif

   if len(aValores) > 0
      if nRecEIJ > 0
         EIJ->(dbGoTo(nRecEIJ))
         AtuReg(aCposEIJ,aValores,"EIJ")
      endif

      if nRecEV2 > 0 
         EV2->(dbGoTo(nRecEV2))
         AtuReg(aCposEV2,aValores,"EV2")
      endif
   endif

   cError := if( !lRet .and. empty(cError) .and. !jResposta:HasProperty("tributosCalculados"), STR0047, cError) // "Erro no retorno."
   fwfreeobj(jValores)
   fwfreeobj(jMemCal)

return lRet

/*
Função     : FormatVlCal
Objetivo   : Função para formatação do objeto memoriaCalculo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function FormatVlCal(aDados)
   local cRet     := ""
   local nDados   := 0
   local oJsonTrb := nil

   /*
   "codigoFundamentoLegalNormal" - Código do fundamento legal do regime tributário de importação utilizado na declaração
   "baseCalculoBRL" - Valor da base de cálculo em R$ (Reais).
   "baseCalculoEspecificaBRL" - Valor da base de cálculo específica em R$ (Reais).
   "baseCalculoReduzidaBRL" - Valor da base de cálculo reduzida em R$ (Reais).
   "percentualReducaoBaseCalculo" - Percentual de redução da base de cálculo.
   "tipoAliquota" - Tipo de alíquota do tributo.
   "percentualReducaoAliquotaReduzida" - Percentual de redução da alíquota reduzida (%).
   "valorAliquota" - Valor da alíquota (%).
   "valorAliquotaEspecifica" - Valor da alíquota específica (%).
   "valorAliquotaReduzida" - Valor da alíquota reduzida (%).
   "normal" - Valor normal em R$ (Reais).
   "tributado" - Indicador de tributação
   */

   for nDados := 1 to len(aDados)
      oJsonTrb := aDados[nDados][2]
      if Valtype(oJsonTrb) = "J"
         cRet += "- Imposto '" + aDados[nDados][1] + "'" + CRLF
         if oJsonTrb:HasProperty("codigoFundamentoLegalNormal")
            cRet += "   " + STR0048 + ": " + cValToChar(oJsonTrb["codigoFundamentoLegalNormal"]) + CRLF // "Código do fundamento legal do regime tributário"
         endif
         if oJsonTrb:HasProperty("baseCalculoBRL")
            cRet += "   " + STR0049 + ": " + cValToChar(oJsonTrb["baseCalculoBRL"]) + CRLF // "Valor da base de cálculo em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("baseCalculoEspecificaBRL")
            cRet += "   " + STR0050 + ": " + cValToChar(oJsonTrb["baseCalculoEspecificaBRL"]) + CRLF // "Valor da base de cálculo específica em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("baseCalculoReduzidaBRL")
            cRet += "   " + STR0051 + ": " + cValToChar(oJsonTrb["baseCalculoReduzidaBRL"]) + CRLF // "Valor da base de cálculo reduzida em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("percentualReducaoBaseCalculo")
            cRet += "   " + STR0052 + ": " + cValToChar(oJsonTrb["percentualReducaoBaseCalculo"]) + CRLF //  "Percentual de redução da base de cálculo"
         endif
         if oJsonTrb:HasProperty("tipoAliquota") .and. valtype(oJsonTrb["tipoAliquota"]) == "C"
            cRet += "   " + STR0053 + ": " + oJsonTrb["tipoAliquota"] + CRLF //  "Tipo de alíquota do tributo"
         endif
         if oJsonTrb:HasProperty("percentualReducaoAliquotaReduzida")
            cRet += "   " + STR0054 + ": " + cValToChar(oJsonTrb["percentualReducaoAliquotaReduzida"]) + CRLF // "Percentual de redução da alíquota reduzida (%)"
         endif
         if oJsonTrb:HasProperty("valorAliquota")
            cRet += "   " + STR0055 + ": " + cValToChar(oJsonTrb["valorAliquota"]) + CRLF //  "Valor da alíquota (%)"
         endif
         if oJsonTrb:HasProperty("valorAliquotaEspecifica")
            cRet += "   " + STR0056 + ": " + cValToChar(oJsonTrb["valorAliquotaEspecifica"]) + CRLF // "Valor da alíquota específica (%)"
         endif
         if oJsonTrb:HasProperty("valorAliquotaReduzida")
            cRet += "   " + STR0057 + ": " + cValToChar(oJsonTrb["valorAliquotaReduzida"]) + CRLF // "Valor da alíquota reduzida (%)"
         endif
         if oJsonTrb:HasProperty("normal")
            cRet += "   " + STR0058 + ": " + cValToChar(oJsonTrb["normal"]) + CRLF // "Valor normal em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("tributado")
            cRet += "   " + STR0059 + ": " + if( oJsonTrb["tributado"], "Verdadeiro", "Falso") + CRLF // "Indicador de tributação"
         endif
      endif
   next

return cRet

/*
Função     : DU101Script
Objetivo   : Funções do javascript
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DU101Script(cUrl)

   begincontent var cVar
      var aItemDUIMPs = [];
      var lEndFor = false;

      function IntItemDUIMP( retAdvpl, retAdvplChunk, retAdvplError){
         var cProcItemDUIMP = () => {
            var cItemDUIMP = aItemDUIMPs.shift();
            if(cItemDUIMP){
               var jItemDUIMP = JSON.parse(cItemDUIMP);
               var cDuimp = jItemDUIMP.numDuimp;
               var cVersao = jItemDUIMP.versaoDuimp;
               var cSeqDUIMP = jItemDUIMP.seqDuimp_url;
               EasyFetch( retAdvplError, '%Exp:cUrl%' + '/duimp-api/api/ext/duimp/' + cDuimp + '/' + cVersao + '/itens/' + cSeqDUIMP + '/valores-calculados', 'GET')
               .then( (res) => res.json() )
               .then( (json) => { retAdvplChunk({jItemDUIMP, ret:json}) ; cProcItemDUIMP() })
               .catch( (e)  => { retAdvplError(e) });
            } else {
                  if (lEndFor) {
                     retAdvpl('processou');
                  } else {
                     setTimeout(cProcItemDUIMP,100);
                  }
            }
         }
         cProcItemDUIMP();
      }     

      function addItemDUIMP(retAdvpl,cItem){
         aItemDUIMPs.push(cItem);
         retAdvpl('adicionou');
      }

      function intDuimp(url, metodo, sbody, retAdvpl, retAdvplError) {
         if(sbody === ""){
            sbody = null;
         }
         let status = 0;
         let status_text = '';
         EasyFetch( retAdvplError, url, metodo, sbody)
         .then( (res) => {
         status = res.status;
         status_text = res.statusText;
            return res.json();
         })
         .then((json) => {
            retAdvpl({status: status, status_text: status_text, response: json});
         })
         .catch((e) => { retAdvplError(e) });
      }

      function ConsultaStatusDuimp(url, metodo, retAdvpl, retAdvplError) {
         let status = 0;
         let status_text = '';

         EasyFetch( retAdvplError, url, metodo)
         .then( (response) => {
            status = response.status;
            status_text = response.statusText;
            return response.json();
         })
         .then( (json) => {
            retAdvpl({status: status, status_text: status_text, response: json} );
         })
         .catch((e) => { retAdvplError(e) });
      }
   endcontent

return cVar

/*
Função     : DUIMP2310
Objetivo   : Função para validação do dicionario de dados para DUIMP release 12.1.2310
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DUIMP2310()
   local lRet := .F.

   if _DIC_22_4 == nil
      _DIC_22_4 := AvFlags("DUIMP_12.1.2310-22.4")
   endif

   lRet := _DIC_22_4

return lRet

/*/{Protheus.doc} IntConsDuimp
   Função responsável por consultar o status da duimp

   @type  Static Function
   @author user
   @since 30/11/2023
   @version version
   @param oLogView, objeto, Objeto da função EECVIEW
          cUrlInteg, caractere, URL do portal unico
          cDuimp, caractere, Numero da Duimp
          cVersao, caractere, Versão da Duimp
   @return nenhum, nil
/*/
static function IntConsDuimp(oLogView, cUrlInteg, cDuimp, cVersao, oEasyJS)
   local cURLAuth    := ""
   local cUrlConsul  := ""
   local cErros      := ""
   local cRetorno    := ""
   local nStatus     := 0
   local aRetorno    := {}
   local lExecMenu   := .F.

   default cUrlInteg  := if( EasyGParam("MV_EIC0074",.F.,"1") == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") ) + "/duimp-api/api/ext/duimp"
   default cDuimp     := EV1->EV1_DI_NUM
   default cVersao    := EV1->EV1_VERSAO

   if oEasyJS == nil
      InitInt(@oLogView)

      cURLAuth := cUrlInteg + URL_AUTENTICAR
      oEasyJS := EasyJS():New()
      lExecMenu := .T.
   endif

   if !empty(cDuimp) .and. (!lExecMenu .or. VldCertDig(@oEasyJs, cUrlInteg, cUrlAuth, @oLogView))

      cUrlInteg += "/duimp-api/api/ext/duimp"
      cVersao := alltrim(str(val(cVersao) + 1 ))
      cUrlConsul := cUrlInteg + "/" + alltrim(cDuimp) + "/" + cVersao

      getLog(STR0065 + " " + alltrim(cDuimp) + " " + STR0012 + " " + cVersao, oLogView) // "Consultando status da DUIMP" ### "versão:"

      cErros := ""
      aRetorno := {}
      cRetorno := IntegCons(oEasyJs, cUrlConsul, @cErros)
      nStatus := RetConsDuimp(cRetorno, @cErros, @aRetorno, @oLogView)

      if len(aRetorno) > 0

         AtuReg({"EV1_STATUS","EV1_VERSAO"},{DUIMP_REGISTRADA, aRetorno[2]}, "EV1")
         AtuReg({"W6_DI_NUM","W6_VERSAO","W6_DTREG_D"},aRetorno,"SW6")

      elseif !empty(cRetorno) .and. empty(cErros)

         getLog(STR0066, oLogView) // "Verificando o status"

         cVersao := alltrim(EV1->EV1_VERSAO)
         cUrlConsul := cUrlInteg + "/" + alltrim(cDuimp) + "/" + cVersao
         
         getLog(STR0065 + " " + alltrim(cDuimp) + " " + STR0012 + " " + cVersao, oLogView) // "Consultando status da DUIMP" ### "versão:"
         
         aRetorno := {}
         cRetorno := IntegCons(oEasyJs, cUrlConsul, @cErros)
         nStatus := RetConsDuimp(cRetorno, @cErros, @aRetorno, @oLogView)

         if (nStatus == 200 .or. nStatus == 201) .or. "EM_ELABORACAO" $ cRetorno .or. "ELABORADA_AGUARDANDO_VINCULACAO_CARGA" $ cRetorno
            getLog(STR0067, oLogView) // "O registro da DUIMP está em processamento."
            AtuReg({"EV1_STATUS"},{EM_PROCESSAMENTO})
         elseif !empty(cRetorno) .and. empty(cErros)
            getLog(STR0068 ,oLogView) // "Verifique as informações retornadas pelo Portal Único e avalie a necessidade de revisão do processo."
            AtuReg({"EV1_STATUS"},{PROCESSO_PENDENTE_REVISAO})
         endif

      endif
  
   endif

   if lExecMenu
      FinishInt(@oLogView, @oEasyJS)
   endif

return nil

/*/{Protheus.doc} IntegCons
   Função responsável por consumir a API da consulta do status da duimp

   @type  Static Function
   @author user
   @since 30/11/2023
   @version version
   @param oEasyJs, objeto, Objeto da classe EasyJS
          cUrlConsul, caractere, URL do portal unico "/duimp-api/api/ext/duimp/{numero-duimp}/{versao-duimp}
   @return lRet, logico, .T. ok - .F. erro
/*/
static function IntegCons(oEasyJs, cUrlConsul, cErros)
   local cRet       := ""

   default cUrlConsul := if( EasyGParam("MV_EIC0074",.F.,"1") == "1", EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") ) + "/duimp-api/api/ext/duimp" + "/" + alltrim(EV1->EV1_DI_NUM) + "/" + alltrim(EV1->EV1_VERSAO)
   default cErros     := ""

   oEasyJS:runJSSync( "ConsultaStatusDuimp('" + cUrlConsul + "', 'GET', retAdvpl, retAdvplError);", {|x| cRet := x } , {|x| cErros := x } )

return cRet

/*/{Protheus.doc} RetConsDuimp
   Função responsável tratar o retorno da API de consulta STATUS da DUIMP

   @type  Static Function
   @author user
   @since 30/11/2023
   @version version
   @param cRetorno, caractere, Mensagem de resposta
          cErros, caractere, Mensagem de erro
          aRetorno, vetor, Array com as informações da resposta { DUIMP, VERSAO, DATA }
          oLogView, objeto, Objeto da função EECVIEW
   @return nStatus, numerico, -1 com erro, caso contrario o status da http
/*/
static function RetConsDuimp(cRetorno, cErros, aRetorno, oLogView)
   local nStatus    := -1
   local jResponse  := jsonobject():new()
   local cResponse  := ""
   local jRetConsul := nil
   local cMsgConsul := ""
   local cNumero    := ""
   local cVerDuimp  := ""
   local dDataReg   := stod("")

   default cRetorno   := ""
   default cErros     := ""
   default aRetorno   := {}

   if !empty(cRetorno)

      cResponse := jResponse:FromJson(cRetorno)
      cErros := if(cResponse <> nil, STR0069 + ". " + if( valtype(cRetorno) == "C" .and. !empty(cRetorno), STR0070 + ": " + cRetorno, STR0071), "" )  // "Não foi possível consultar o status da DUIMP" ## "Retorno" ## "Retorno inválido"
      if empty(cErros)

         nStatus := jResponse:GetJsonObject("status")
         jRetConsul := jResponse:GetJsonObject("response")
         if !jRetConsul == nil
            cMsgConsul := jResponse:GetJsonText("response")
            if valtype(jRetConsul:GetJsonObject("identificacao")) == "J"
               cNumero := jRetConsul:GetJsonObject("identificacao"):GetJsonText("numero")
               cVerDuimp := jRetConsul:GetJsonObject("identificacao"):GetJsonText("versao")
               if !empty(jRetConsul:GetJsonObject("identificacao"):GetJsonText("dataRegistro")) .and. !jRetConsul:GetJsonObject("identificacao"):GetJsonText("dataRegistro") == "null"
                  dDataReg := stod(strtran( substr(jRetConsul:GetJsonObject("identificacao"):GetJsonText("dataRegistro"), 1, at("T",jRetConsul:GetJsonObject("identificacao"):GetJsonText("dataRegistro"))-1) , "-", "" )) 
               endif
            endif
         endif
         getLog(STR0072 + ": " + cMsgConsul, oLogView) // "Retorno da consulta da DUIMP"

         if !empty(dDataReg)
            aRetorno := { cNumero, cVerDuimp, dDataReg }
         endif

      endif

   endif

   if( !empty(cErros), getLog( if( match(cErros,"*Failed to fetch*"), STR0073, cErros) , oLogView), nil) // "Não foi possível estabelecer conexão com o portal único. Verifique se está conectado na internet ou se o certificado está correto."

return nStatus

/*/{Protheus.doc} intDUIMP
   Executa a integração da DUIMP

   @type  Static Function
   @author user
   @since 24/11/2023
   @version version
   @param oEasyJS, objeto, EasyJS
          cErros, caracter, variavel de erro
          cUrl, caracter, URL do portal unico da API
          cMetodo, caracter, Metodo da API
          cJson, caracter, JSON de envio
   @return cRet, caracter, retorno da execução
/*/
static function intDUIMP(oEasyJS, cErros, cUrl, cMetodo, cJson)
   local cRet    := ""
   local cScript := ""

   if( empty(cJson), cJson := "''", cJson := strTran(cJson, CHR(13)+CHR(10), ""))

   begincontent var cScript

      intDuimp('%Exp:cUrl%', '%Exp:cMetodo%', %Exp:cJson%, retAdvpl, retAdvplError)

   endcontent

   // cJscript := "intDuimp('" + cUrlExec + "', '" + cMetodo + "', " + if( !empty(cDados), "'" + cDados + "'", "null") + ", retAdvpl, retAdvplError);"
   // oEasyJS:runJSSync( cJscript, {|x| cRet := x } , {|x| cErros := x } )
   oEasyJS:runJSSync( cScript ,{|x| cRet := x } , {|x| cErros := x } )

return cRet

/*/{Protheus.doc} VerifCat (Verifica Catalogos)
   Verifica os status do catálogo nos itens da DUIMP
   @type  Static Function
   @author user
   @since 01/08/2024
   @version version
   @param cHawb, caracter, variavel do Hawb da EV1
          cLote, caracter, variavel do Lote da EV1
          cTipo, caracter, variavel do status do catalogo a ser verificado
   @return lRet, lógico, retorno da execução
/*/
Static Function VerifCat(cHawb, cLote, cTipo)
Local cQuery    := ""
Local cAliasQry := getNextAlias()
Local lRet

cQuery := " SELECT "
cQuery += " EK9_STATUS "
cQuery += " FROM " + RetSqlName('EK9') + " EK9 "
cQuery += " INNER JOIN " + RetSqlName('EV2') + " EV2"
cQuery += " ON EK9.EK9_IDPORT = EV2.EV2_IDPTCP "
cQuery += " WHERE EK9.D_E_L_E_T_ = ' ' "
cQuery += " AND EK9.EK9_IDPORT <> ' ' "
cQuery += " AND EK9.EK9_FILIAL = ? "
cQuery += " AND EV2.EV2_FILIAL = ? "
cQuery += " AND EV2.EV2_HAWB = ? "
cQuery += " AND EV2.EV2_LOTE = ? "
cQuery += " AND EV2.D_E_L_E_T_ = ' ' "

Do Case
   Case cTipo == 'Pendente Retificação'
      cQuery += " AND EK9.EK9_STATUS = '3' "
   Case cTipo == 'Bloqueado'
      cQuery += " AND (EK9.EK9_STATUS = '4' OR EK9.EK9_MSBLQL = '1') "
EndCase

oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString(1,xFilial('EK9'))
oQuery:SetString(2,xFilial('EV2'))
oQuery:SetString(3,cHawb)
oQuery:SetString(4,cLote)
cQuery := oQuery:GetFixQuery()

fwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasQry)

lRet := IIF((cAliasQry)->(EOF()) .and. (cAliasQry)->(BOF()), .F., .T.) // Caso seja Inicio e fim da tabela, ou seja, nenhum registro encontrado, retorna .F.

(cAliasQry)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} getRelease
   Armazena na variavel static _cRelease a versão do release 

   @type  Static Function
   @author user
   @since 18/02/2025
   @version version
   @param nenhum
   @return cRelease, caractere, versão do release, por exemplo 12.1.2410
   @example
   (examples)
   @see (links_or_references)
/*/
static function getRelease()
   local cRelease   := ""

   if empty(_cRelease)
      _cRelease := getRPORelease()
   endif
   cRelease := _cRelease

return cRelease

/*/{Protheus.doc} getVrAgent
   Armazena na variavel static _cVrAgent a versão do webagent
   Somente para o build 24.3.0.0 do appserver 

   @type  Static Function
   @author user
   @since 18/02/2025
   @version version
   @param nenhum
   @return cVerAgent, caractere, versão do webagent
   @example
   (examples)
   @see (links_or_references)
/*/
static function getVrAgent()
   local cVerAgent  := ""

   // caso a versão da build do appserver for igual ou maior que 24.3.0.0
   if empty(_cVrAgent) .and. !VldVersao(GetSrvVersion(),"24.3.0.0")
      _cVrAgent := GetWebAgentInfo()[1]
   endif
   cVerAgent := _cVrAgent

return cVerAgent

/*/{Protheus.doc} VldVersao
   Realiza a validação do webagent e da build do appserver

   @type  Static Function
   @author user
   @since 18/02/2025
   @version version
   @param cParVersao, caractere, versão corrente
          cVerValid, caractere, versão ser validada
          cToken, caractere, token de separação
   @return lRet, logico, verdadeiro se a versão corrente é menor que a versão validada
   @example
   (examples)
   @see (links_or_references)
/*/
static function VldVersao(cParVersao, cVerValid, cToken)
   local lRet       := .F.
   local aVersao
   local aVerVld
   local nLenIni
   local nLenFim
   local nLenMenor
   local nI

   default cToken := "."

   if !empty(cParVersao) .and. !empty(cVerValid)
      aVersao := StrToKArr(cParVersao, cToken)
      aVerVld := StrToKArr(cVerValid, cToken)
      nLenIni := Len(aVersao)
      nLenFim := Len(aVerVld)
      nLenMenor := Min(nLenIni, nLenFim)

      for nI := 1 to nLenMenor
         if Val(aVersao[nI]) < Val(aVerVld[nI])
            lRet := .T.
            exit
         endif
      next
   endif

return lRet

/*/{Protheus.doc} ConvValor
   Converter o valor para caractere conforme portal unico

   @type  Static Function
   @author user
   @since 22/07/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function ConvValor(nValor, cPicture)
   local cRet       := "0,00"

   default nValor     := 0
   default cPicture   := getSX3Cache("W9_FOB_TOT", "X3_PICTURE")

   cRet := alltrim(Transform(nValor, cPicture))

return cRet
