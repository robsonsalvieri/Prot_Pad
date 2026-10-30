#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW058.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Gera Requisicao ao Armazem 
@TYPE function
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSRESTFUL LOCW058 DESCRIPTION "Gera Requisicao ao Armazem - Rental"

	WSMETHOD POST DESCRIPTION "<h2Gera Requisicao ao Armazem - Rental.</h2>" WSSYNTAX "/LOCW058"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW058
ITUP BUSINESS - TOTVS RENTAL
Método para Gera Requisicao ao Armazem
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSMETHOD POST WSSERVICE LOCW058
Local cDados	:= ""
Local cRet      := ""
Local cMsg      := ""
Local cBody     := DecodeUtf8(::GetContent())
Local lRet      := .T.
Local aEmp      := {}
Local aErroAuto := {}
Local nX        := 0 
Local cFonte    := "LOCW058.PRW"
Local aInfo     := GetAPOInfo(cFonte)
Local nOpcx     := 0
Local aCab      := {}
Local aItens    := {}
Local cNumero   := ""
Local nRecSCP   := 0
Local nY        := 1
Private oJson          := Nil
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.
    
    ::SetContentType("application/json; charset=iso-8859-1")
    
    Begin Sequence	
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1()
            
            
            If (aEmp[3] == "Empresa já existente.")
                cRet := xAbreEnv1(aEmp[1])
                
                If Empty(cRet)   
                    //VALIDAÇÕES ANTES DO EXECAUTO
                    
                    If ValType(oJson:itens) != "A" .Or. Len(oJson:itens) == 0
                        cRet := "400 - "
                        cMsg := "Campo 'itens' e obrigatorio"
                        lRet := .F.
                    ElseIf Empty(oJson:solicitante)
                        cRet := "400 - "
                        cMsg := "Campo 'solicitante' e obrigatorio"  
                        lRet := .F. 
                    ElseIf Empty(oJson:tipo)
                        cRet := "400 - "
                        cMsg := "Campo 'tipo' e obrigatorio"  
                        lRet := .F.                                                                        
                    Else
                        //INCLUSÃO DE S.A.
                        If oJson:tipo == "I"
                            nOpcx := 3
                        EndIf
                        //EXCLUSÃO DE S.A.
                        If oJson:tipo == "E"
                            nOpcx := 5
                        EndIf
                        If lRet .And. nOpcx == 3
                            For nY := 1 To Len(oJson:itens)
                                If Empty(oJson:itens[nY]:produto)
                                    cRet := "400 - "
                                    cMsg := "Campo 'produto' e obrigatorio no item " + AllTrim(Str(nY))
                                    lRet := .F.
                                    Exit
                                ElseIf Empty(oJson:itens[nY]:quantidade)
                                    cRet := "400 - "
                                    cMsg := "Campo 'quantidade' e obrigatorio no item " + AllTrim(Str(nY))
                                    lRet := .F.
                                    Exit
                                EndIf
                            Next
                        EndIf
                        If lRet
                            //INCLUSÃO DE S.A.
                            If nOpcx == 3

                                ConfirmSx8()
                                cNumero := GetSx8Num('SCP', 'CP_NUM')

                                // Monta array para ExecAuto
                                Aadd( aCab, { "CP_NUM"     ,cNumero ,   Nil })
                                Aadd( aCab, { "CP_EMISSAO" ,dDataBase , Nil })
                                For nY := 1 To Len(oJson:itens)
                                    Aadd( aItens, {} )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" ,  StrZero(nY,2) ,                    Nil } )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,oJson:itens[nY]:produto ,         Nil } )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_QUANT"   ,val(oJson:itens[nY]:quantidade) , Nil } )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_LOCAL"   ,oJson:itens[nY]:armazem ,         Nil } )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_OBS"     ,oJson:itens[nY]:observacao ,      Nil } )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_NUMOS"   ,oJson:itens[nY]:ordem_servico ,   Nil } )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_SOLICIT" ,oJson:solicitante ,               Nil } )
                                    Aadd( aItens[ Len( aItens ) ],{"CP_OP"      ,oJson:itens[nY]:ordem_producao ,  Nil } )
                                    If !Empty(oJson:itens[nY]:centro_custo)
                                        Aadd( aItens[ Len( aItens ) ],{"CP_CC"      ,oJson:itens[nY]:centro_custo ,    Nil } )
                                    EndIf
                                    If !Empty(oJson:itens[nY]:classe_valor)
                                        Aadd( aItens[ Len( aItens ) ],{"CP_CLVL"    ,oJson:itens[nY]:classe_valor ,    Nil } )
                                    EndIf
                                Next
                                //EXECUTA O EXECAUTO
                                MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , nOpcx )

                            EndIf    

                            //EXCLUSÃO DE S.A.
                            If nOpcx == 5

                                For nY := 1 To Len(oJson:itens)
                                    If Empty(oJson:itens[nY]:numero)
                                        cRet := "400 - "
                                        cMsg := "Campo 'numero' e obrigatorio no item " + AllTrim(Str(nY)) + " quando for exclusao de Solicitacoes"
                                        lRet := .F.
                                        Exit
                                    EndIf
                                Next

                                If lRet
                                    // Monta array para ExecAuto
                                    Aadd( aCab, { "CP_NUM"     ,oJson:itens[1]:numero , Nil })
                                    Aadd( aCab, { "CP_EMISSAO" ,dDataBase ,             Nil })

                                    For nY := 1 To Len(oJson:itens)
                                        Aadd( aItens, {} )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" ,  StrZero(nY,2) ,                    Nil } )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,oJson:itens[nY]:produto ,         Nil } )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_QUANT"   ,val(oJson:itens[nY]:quantidade) , Nil } )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_LOCAL"   ,oJson:itens[nY]:armazem ,         Nil } )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_OBS"     ,oJson:itens[nY]:observacao ,      Nil } )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_NUMOS"   ,oJson:itens[nY]:ordem_servico ,   Nil } )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_SOLICIT" ,oJson:solicitante ,               Nil } )
                                        Aadd( aItens[ Len( aItens ) ],{"CP_OP"      ,oJson:itens[nY]:ordem_producao ,  Nil } )
                                    Next

                                    //EXECUTA O EXECAUTO
                                    MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , nOpcx )
                                EndIf
                            EndIf
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
                                //INCLUSÃO DE S.A.
                                If nOpcx == 3
                                    cRet := "200 - "
                                    cMsg := "Solicitacao criada com sucesso! "
                                    cDados := ',"Requisicao":"' + cNumero + '"'

                                    nRecSCP := SCP->(RecNo())
                                
                                    SCP->(dbGoto(nRecSCP))
                                    SCP->(RecLock("SCP",.F.))     
                                    SCP->CP_SOLICIT := oJson:solicitante
                                    SCP->(MsUnlock())                                      
                                EndIf 

                                //EXCLUSÃO DE S.A.
                                If nOpcx == 5 .and. lRet 
                                    cRet := "200 - "
                                    cMsg := "Solicitacao excluida com sucesso! "
                                    cDados := ',"Requisicao":"' + oJson:numero  + '"'
                                EndIf 

                            EndIf
                        EndIf  
                    EndIf    
                EndIf    
            EndIf   
        EndIf    
    End Sequence
    
    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cDados+',"compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )
    
Return .T.
