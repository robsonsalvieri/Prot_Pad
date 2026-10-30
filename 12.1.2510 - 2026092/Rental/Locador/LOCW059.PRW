#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW059.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Transferï¿½ncia de estoque (incluir e estornar)
@TYPE function
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSRESTFUL LOCW059 DESCRIPTION "Transferï¿½ncia de estoque (incluir e estornar) - Rental"

	WSMETHOD POST DESCRIPTION "<h2Transferï¿½ncia de estoque (incluir e estornar) - Rental.</h2>" WSSYNTAX "/LOCW059"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW059
ITUP BUSINESS - TOTVS RENTAL
Mï¿½todo para Transferï¿½ncia de estoque (incluir e estornar)
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSMETHOD POST WSSERVICE LOCW059
Local cDados	:= ""
Local cRet      := ""
Local cMsg      := ""
Local cBody     := DecodeUtf8(::GetContent())
Local lRet      := .T.
Local aEmp      := {}
Local aErroAuto := {}
Local nX        := 0 
Local cFonte    := "LOCW059.PRW"
Local aInfo     := GetAPOInfo(cFonte)
Local nOpcx     := 0
Local aAuto     := {}
Local aLinha    := {}
Local cNumero   := ""
Local cArmOrig  := ""
Local cArmDest  := ""
Local nRecSD3   := 0
Local cProduto  := ""
Local cLote      := ""
Local cLocaliz   := ""
Local cRastro    := ""
Local cCtrLocal  := ""

Private oJson          := Nil
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.
    
    ::SetContentType("application/json; charset=iso-8859-1")
    
    Begin Sequence	
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1()
            
            
            //If (aEmp[3] == "Empresa já existente.")
                cRet := xAbreEnv1(aEmp[1])
                
                If Empty(cRet)   
                    //VALIDAÇÕES ANTES DO EXECAUTO
                    
                    If Empty(oJson:produto)
                        cRet := "400 - "
                        cMsg := "Campo 'produto' e obrigatorio"
                        lRet := .F.
                    ElseIf Empty(oJson:quantidade)
                        cRet := "400 - "
                        cMsg := "Campo 'quantidade' e obrigatorio"
                        lRet := .F.
                    ElseIf Empty(oJson:armazem_origem)
                        cRet := "400 - "
                        cMsg := "Campo 'armazem_origem' e obrigatorio"  
                        lRet := .F. 
                    ElseIf Empty(oJson:armazem_destino)
                        cRet := "400 - "
                        cMsg := "Campo 'armazem_destin' e obrigatorio"  
                        lRet := .F.                                                                        
                    Else  
                        //INCLUSÃO
                        If oJson:tipo == "I"
                            nOpcx := 3
                        EndIf
                        //ESTORNO
                        If oJson:tipo == "E"
                            nOpcx := 6
                        EndIf                            
                        If lRet   
                            //INCLUSÃO
                            If nOpcx == 3

                                cArmOrig := PadR(oJson:armazem_origem, TamSX3("D3_LOCAL")[1])   // DSERLOCA-XXXXX - padding tamanho fixo (corrige MA240NEGAT)
                                cArmDest := PadR(oJson:armazem_destino, TamSX3("D3_LOCAL")[1])  // DSERLOCA-XXXXX - padding tamanho fixo

                                ConfirmSx8()
                                cNumero := GetSxeNum("SD3","D3_DOC")
 
                                // Monta array para ExecAuto
                                aAdd(aAuto, {cNumero, dDataBase})

                                cProduto := oJson:produto
                                //A260Local - para resolver esse problema, não precisamos enviar no ExecAuto o produto com todos os espaços a direita 
                                //conforme o tamanho do seu B1_COD, então na minha base o código do produto ficaria LOCACAOBEM01          ï¿½ 
                                //e assim, a pesquisa na SB2 pela validaï¿½ï¿½o padrï¿½o ficarï¿½ LOCACAOBEM01          02ï¿½.
                                cProduto := AvKey(cProduto, "B1_COD")

                                If SB1->(MsSeek(FWxFilial("SB1") + cProduto))

                                    //Controle de lote e localizacao do produto
                                    cRastro   := AllTrim(SB1->B1_RASTRO)
                                    cCtrLocal := AllTrim(SB1->B1_LOCALIZ)

                                    If cRastro == "L" .And. Empty(oJson:lote)
                                        cRet := "400 - "
                                        cMsg := "Campo 'lote' e obrigatorio para produtos com controle por lote"
                                        lRet := .F.
                                    ElseIf cCtrLocal == "S" .And. Empty(oJson:localizacao)
                                        cRet := "400 - "
                                        cMsg := "Campo 'localizacao' e obrigatorio para produtos com controle por localizacao"
                                        lRet := .F.
                                    EndIf

                                    If lRet
                                        cLote    := PadR(IIf(cRastro   == "L", oJson:lote,        ""), TamSX3("D3_LOTECTL")[1])  // DSERLOCA-XXXXX - padding tamanho fixo (corrige MA240NEGAT)
                                        cLocaliz := PadR(IIf(cCtrLocal == "S", oJson:localizacao,  ""), TamSX3("D3_LOCALIZ")[1])  // DSERLOCA-XXXXX - padding tamanho fixo

                                        //Origem
                                        aLinha := {}
                                        aadd(aLinha,{"D3_COD",     cProduto,Nil}) //Cod Produto origem
                                        aadd(aLinha,{"D3_DESCRI",  SB1->B1_DESC, Nil}) //descr produto origem
                                        aadd(aLinha,{"D3_UM",      SB1->B1_UM,   Nil}) //unidade medida origem
                                        aadd(aLinha,{"D3_LOCAL",   cArmOrig,     Nil}) //armazem origem
                                        aadd(aLinha,{"D3_LOCALIZ", cLocaliz,     Nil}) //Informar endereço origem
                                        aadd(aLinha,{"D3_LOTECTL", cLote,        Nil}) //Lote Origem
                                        aadd(aLinha,{"D3_DTVALID", CTOD(oJson:lote_valid), Nil}) //data validade

                                        //Destino
                                        aadd(aLinha,{"D3_COD",     cProduto,Nil}) //cod produto destino
                                        aadd(aLinha,{"D3_DESCRI",  SB1->B1_DESC, Nil}) //descr produto destino
                                        aadd(aLinha,{"D3_UM",      SB1->B1_UM,   Nil}) //unidade medida destino
                                        aadd(aLinha,{"D3_LOCAL",   cArmDest,     Nil}) //armazem destino
                                        aadd(aLinha,{"D3_LOCALIZ", PadR(oJson:localizacao_dest, TamSX3("D3_LOCALIZ")[1]), Nil}) // Informar endereço destino

                                        //Outros campos
                                        aadd(aLinha,{"D3_NUMSERI", "",           Nil}) //Numero serie
                                        aadd(aLinha,{"D3_NUMLOTE", "",           Nil}) //sublote origem
                                        aadd(aLinha,{"D3_POTENCI", 0,            Nil}) //Potencia
                                        aadd(aLinha,{"D3_QUANT",   val(oJson:quantidade), Nil}) //Quantidade
                                        aadd(aLinha,{"D3_QTSEGUM", 0,            Nil}) //Seg unidade medida
                                        aadd(aLinha,{"D3_ESTORNO", "",           Nil}) //Estorno
                                        aadd(aLinha,{"D3_NUMSEQ",  "",           Nil}) //Numero sequencia D3_NUMSEQ
                                        aadd(aLinha,{"D3_LOTECTL", PadR(oJson:lote_dest, TamSX3("D3_LOTECTL")[1]), Nil}) // Lote destino
                                        aadd(aLinha,{"D3_NUMLOTE", "",           Nil}) //sublote destino
                                        aadd(aLinha,{"D3_DTVALID", CTOD(oJson:lote_valid_dest),           Nil}) //validade lote destino
                                        aadd(aLinha,{"D3_ITEMGRD", "",           Nil}) //Item Grade
                                        aadd(aLinha,{"D3_CODLAN",  "",           Nil}) //cat83 prod origem
                                        aadd(aLinha,{"D3_CODLAN",  "",           Nil}) //cat83 prod destino

                                        aAdd(aAuto, aLinha)

                                        //EXECUTA O EXECAUTO
                                        MSExecAuto({|x, y| MATA261(x, y)}, aAuto, nOpcx)
                                    EndIf
                                EndIf

                            EndIf

                            //ESTORNO DE TRANFERÊNCIA.
                            
                            If nOpcx == 6
                                aAuto := {}

                                ConfirmSx8()
                                cNumero := oJson:numero

                                //Posiciona no documento (RE4/DE4). Ordem 8 = D3_FILIAL+D3_DOC+D3_NUMSEQ
                                DbSelectArea("SD3")
                                SD3->(DbSetOrder(8))
                                SD3->(DbSeek(xFilial("SD3") + cNumero))

                                //Chama a rotina automï¿½tica com opção de estorno (<> 3, use 6)
                                MSExecAuto({|x, y, z| Mata261(x, y, z)}, aAuto, nOpcx)  
   
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
                                //INCLUSÃO
                                If nOpcx == 3 .and. lRet
                                    cRet := "200 - "
                                    cMsg := "Transferencia realizada! "
                                    cDados := ',"documento":"' + cNumero + '"'

                                    nRecSD3 := SD3->(RecNo())
                                
                                    SD3->(dbGoto(nRecSD3))
                                    SD3->(RecLock("SD3",.F.))
                                    SD3->D3_USUARIO := oJson:usuario
                                    SD3->(MsUnlock())                                      
                                EndIf 

                                //ESTORNO DE TRANFERÊNCIA.
                                If nOpcx == 6 .and. lRet
                                    cRet := "200 - "
                                    cMsg := "Tranferencia excluida com sucesso! "
                                    cDados := ',"Documento":"' + oJson:numero  + '"'
                                EndIf 

                            EndIf
                        EndIf  
                    EndIf    
                EndIf    
            //EndIf   
        EndIf    
    End Sequence
    
    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cDados+',"compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )
    
Return .T.
