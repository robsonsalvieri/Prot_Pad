#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW056.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Movimentação interna (geração e estorno)
@TYPE function
@AUTHOR Frank Zwarg Fuga
@SINCE 08/06/2026
/*/
WSRESTFUL LOCW056 DESCRIPTION "Movimentacao interna de estoque - RENTAL"

	WSMETHOD POST DESCRIPTION "<h2>Movimentacao interna de estoque - RENTAL</h2>" WSSYNTAX "/LOCW056"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW056
ITUP BUSINESS - TOTVS RENTAL
Método para Movimentação interna (geração e exclusão)
@TYPE WSMETHOD
@AUTHOR Frank Zwarg Fuga
@SINCE 08/06/2026
/*/
WSMETHOD POST WSSERVICE LOCW056
Local cRet       := ""
Local cMsg       := ""
Local cBody      := DecodeUtf8(::GetContent())
Local lRet       := .T.
Local aEmp       := {}
Local cFonte     := "LOCW056.PRW"
Local aInfo      := GetAPOInfo(cFonte)
Local lReg
Local nX
Local aCab1 := {} // Array para o cabeçalho do movimento
Local atotitem := {} // Array para agrupar todos os itens

Private oJson        := Nil
Private lMsErroAuto  := .F.

    ::SetContentType("application/json; charset=iso-8859-1")
    
    Begin Sequence	
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            
            If Empty(cRet)   
           
                //VALIDAÇÕES ANTES DO EXECAUTO
                If len(oJson:itens) == 0
                    cRet := "400 - "
                    cMsg := "Falta informar os itens da movimentacao interna"
                    lRet := .F.
                Else    

                    If oJson:operacao == "1"

                        aCab1 := {;
                                 {"D3_TM",      oJson:tm,         NIL},;  
                                 {"D3_CC",      oJson:ccusto,     NIL},; 
                                 {"D3_EMISSAO", ctod(oJson:data), NIL}; 
                                 }
                        
                        For nX := 1 to len(oJson:itens)

                            aadd(atotitem,{	;		
					                        {"D3_COD",     oJson:itens[nX]:produto, NIL},; 
                                            {"D3_QUANT",   oJson:itens[nX]:quant,   NIL},; 
                                            {"D3_CONTA",   oJson:itens[nX]:conta,   NIL},; 
                                            {"D3_OP",      oJson:itens[nX]:op,      NIL},; 
                                            {"D3_CUSTO1",  oJson:itens[nX]:custo,   NIL},; 
                                            {"D3_CLVL",    oJson:itens[nX]:clvl,    NIL},; 
                                            {"D3_ORDEM",   oJson:itens[nX]:ordem,   NIL},; 
                                            {"D3_TEATF",   oJson:itens[nX]:teatf,   NIL},; 
                                            {"D3_CODFOR",  oJson:itens[nX]:codfor,  NIL},; 
                                            {"D3_LOJAFOR", oJson:itens[nX]:lojafor, NIL},; 
                                            {"D3_OBSERVA", oJson:itens[nX]:observa, NIL}})
                        Next

                        MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCab1, atotitem, 3)

                        If lMsErroAuto
                            lReg := .F.
                        Else
                            lRet := .T.
                        EndIf
                    Else
                        
                        SD3->(dbSetOrder(2))
                        If SD3->(dbSeek(xFilial("SD3")+oJson:doc))
                        	MsExecAuto({|x,y,z| MATA241(x,y,z)},{},Nil,6)
                        Else
                            lMsErroAuto := .T.    
                        EndIf
                    EndIF

                    If !lMsErroAuto 
                        lReg := .T.
                    Else
                        lReg := .F.
                    EndIf

                    If lReg
                        cRet := "200 - "
                        If oJson:operacao == "1"
                            cMsg := "Movimentacao interna gerada com sucesso: "+alltrim(SD3->D3_DOC)
                        Else
                            cMsg := "Movimentacao interna estornada com sucesso "
                        EndIf
                    Else
                        cRet := "404 - "
                        If oJson:operacao == "1"
                            cMsg := "Nao foi possivel gerar a movimentacao interna. "
                        Else
                            cMsg := "Nao foi possivel estornar a movimentacao interna "
                        EndIf
                    EndIf
                EndIf    
            EndIf    
        EndIf    
    End Sequence
      
    ::SetResponse( AllTrim( FWHttpEncode('{"Retorno":"'+cRet+cMsg+'","compilado":"'+ aInfo[1]+' '+DtoS(aInfo[4])+'"}' ) ) )
    
Return .T.
