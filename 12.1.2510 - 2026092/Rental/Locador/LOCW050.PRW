#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW050.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Gera Solicitação de Serviço
@TYPE function
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSRESTFUL LOCW050 DESCRIPTION "Gera Solicitacao de Servico"

	WSMETHOD POST DESCRIPTION "<h2>Gera Solicitacao de Servico.</h2>" WSSYNTAX "/LOCW050"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW050
ITUP BUSINESS - TOTVS RENTAL
Método para Gerar Solicitação de Serviço
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSMETHOD POST WSSERVICE LOCW050
Local cEnvLog  	:= ""
Local bError    := {||}
Local cDados	:= ""
Local cRet      := ""
Local cMsg      := ""
Local cBody     := DecodeUtf8(::GetContent())
Local lLog      := .F.
Local lRet      := .T.
Local aEmp      := {}
Local aRotAuto  := {}
Local nOpcAuto  := 3
Local aErroAuto := {}
Local nX        := 0 
Local cCodUsr   := RetCodUsr() 
Local cNomUsr   := AllTrim(UsrRetName(cCodUsr)) 
Local cHrIni    := Time()
Local cFonte    := "LOCW050.PRW"
Local aInfo     := GetAPOInfo(cFonte)
Local nRecTQB   := 0

Private oJson          := Nil
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.
    
    ::SetContentType("application/json; charset=iso-8859-1")
    
    bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
    Begin Sequence	
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa já existente.")
            
            If lLog
                cRet := xAbreEnv1(aEmp[1],aEmp[2])
                
                If Empty(cRet)   
                    //VALIDAÇÕES ANTES DO EXECAUTO
                    If Empty(oJson:bem)
                        cRet := "400 - "
                        cMsg := "Campo 'bem' e obrigatorio"
                        lRet := .F.
                    ElseIf Empty(oJson:descricao)
                        cRet := "400 - "
                        cMsg := "Campo 'descricao' e obrigatorio"
                        lRet := .F.
                    ElseIf Empty(oJson:cprojeto)
                        cRet := "400 - "
                        cMsg := "Campo 'cprojeto' e obrigatorio"  
                        lRet := .F. 
                    ElseIf Empty(oJson:cObra)
                        cRet := "400 - "
                        cMsg := "Campo 'cObra' e obrigatorio"  
                        lRet := .F.     
                    ElseIf Empty(oJson:NrAS)
                        cRet := "400 - "
                        cMsg := "Campo 'NrAS' e obrigatorio" 
                        lRet := .F.                                                                    
                    Else    
						ST9->(dbSetOrder(1))
						ST9->(dbSeek(xFilial("ST9")+oJson:bem))

                        If !ST9->(Found())
                            lRet := .F.
                            cRet := "400 - "
                            cMsg := "Bem nao localizado no cadastro"
                        ElseIf oJson:contador >= ST9->T9_POSCONT
                            NGTRETCON(oJson:bem,dDatabase,oJson:contador,cHrIni,1,,,"A",xFilial("ST9"))
                        Else
                            lRet := .F.
                            cRet := "400 - "
                            cMsg := "Nao foi possivel prosseguir, contador informado "+ Str(oJson:contador)
                            cMsg += " menor que o contador atual "+ AllTrim(Str(ST9->T9_POSCONT))
                            cMsg += " corrigir o contador informado no APP."
                        EndIf

                        If lRet                
                            // Monta array para ExecAuto
                            aAdd(aRotAuto, {"TQB_CODBEM", oJson:bem           , Nil})
                            aAdd(aRotAuto, {"TQB_TIPOSS", "B"                 , Nil})
                            aAdd(aRotAuto, {"TQB_CCUSTO", oJson:centr_custo   , Nil})
                            aAdd(aRotAuto, {"TQB_DTABER", dDataBase           , Nil})
                            aAdd(aRotAuto, {"TQB_HOABER", Time()              , Nil})
                            aAdd(aRotAuto, {"TQB_DESCSS", oJson:descricao     , Nil})
                            aAdd(aRotAuto, {"TQB_PRIORI", "3"                 , Nil})
                            aAdd(aRotAuto, {"TQB_USUARI", cNomUsr             , Nil})
                            aAdd(aRotAuto, {"TQB_CDSOLI", cCodUsr             , Nil})
                            aAdd(aRotAuto, {"TQB_CDSERV", oJson:tipo_servico  , Nil})
                            aAdd(aRotAuto, {"TQB_ORIGEM", "RENTAL"            , Nil})
                            aAdd(aRotAuto, {"TQB_AS"    , oJson:NrAS          , Nil})
                            aAdd(aRotAuto, {"TQB_PROJET", oJson:cprojeto      , Nil})
                            aAdd(aRotAuto, {"TQB_OBRA"  , oJson:cObra         , Nil})
                            
                            //EXECUTA O EXECAUTO
                            MSExecAuto({|x, y, z| MNTA280(, , x, y)}, aRotAuto, nOpcAuto)
                            
                            //VERIFICA SE DEU ERRO
                            If lMsErroAuto    
                                //CAPTURA OS ERROS
                                aErroAuto := GetAutoGRLog()
                                cMsg := ""
                                
                                For nX := 1 To Len(aErroAuto)
                                    cMsg += AllTrim(aErroAuto[nX]) + " "
                                Next nX
                                
								cMsg := FwNoAccent(cMsg)

                                cMsg := StrTran(cMsg, Chr(13), " ")
                                cMsg := StrTran(cMsg, Chr(10), " ")
                                
                                cRet := "500 - "
                                cMsg := "Erro ExecAuto: " + cMsg
                            Else
                                nRecTQB := TQB->(RecNo())
                                cRet := "200 - "
                                cMsg := "SS incluida com sucesso! "
                                cDados := ',"codigo":"' + TQB->TQB_SOLICI + '"'

                                TQB->(dbGoto(nRecTQB))
                                TQB->(RecLock("TQB",.F.))
                                TQB->TQB_POSCON := oJson:contador
                                TQB->TQB_POSCOS := oJson:contador2
                                TQB->(MsUnlock())
                            EndIf
                        EndIf  
                    EndIf    
                EndIf    
            Else
                cRet := "401 - "
                cMsg := "Credenciais invalidas"
            EndIf   
        EndIf    
    End Sequence
    
    ErrorBlock(bError)
    
    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cDados+',"compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )
    
Return .T.
