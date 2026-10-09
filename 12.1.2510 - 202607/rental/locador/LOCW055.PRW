#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW055.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Geração e exclusão de solicitação de compras
@TYPE function
@AUTHOR Frank Zwarg Fuga
@SINCE 08/06/2026
/*/
WSRESTFUL LOCW055 DESCRIPTION "Solicitacao de compras - RENTAL"

	WSMETHOD POST DESCRIPTION "<h2>Solicitacao de compras - RENTAL</h2>" WSSYNTAX "/LOCW055"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW055
ITUP BUSINESS - TOTVS RENTAL
Método para geração e exclusão de solicitação de compras
@TYPE WSMETHOD
@AUTHOR Frank Zwarg Fuga
@SINCE 08/06/2026
/*/
WSMETHOD POST WSSERVICE LOCW055
//Local cEnvLog  	 := ""
//Local bError     := {||}
Local cRet       := ""
Local cMsg       := ""
Local cBody      := DecodeUtf8(::GetContent())
Local lRet       := .T.
Local aEmp       := {}
Local cFonte     := "LOCW055.PRW"
Local aInfo      := GetAPOInfo(cFonte)
Local lReg
Local nX
Local aCabSC     := {}
Local aItensSC   := {}
Local aLinhaC1   := {}

Private oJson        := Nil
Private lMsErroAuto  := .F.
    
    ::SetContentType("application/json; charset=iso-8859-1")
    
    //bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
    Begin Sequence	
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            
            If Empty(cRet)   
           
                //VALIDAÇÕES ANTES DO EXECAUTO
                If len(oJson:itens) == 0
                    cRet := "400 - "
                    cMsg := "Falta informar os itens da solicitacao de compras"
                    lRet := .F.
                Else    

                    If oJson:operacao == "1"
                        // Monta cabecalho 
                        aadd(aCabSC,{"C1_SOLICIT", UsrRetName(__cUserID)	})
                        aadd(aCabSC,{"C1_EMISSAO", ctod(oJson:data) })

                        For nX := 1 to len(oJson:itens)
                            aLinhaC1 := {}
                            aadd( aLinhaC1, {"C1_ITEM",    strzero(nX,4,0),         Nil})
                            aadd( aLinhaC1, {"C1_PRODUTO", oJson:itens[nX]:produto, Nil})
                            aadd( aLinhaC1, {"C1_QUANT",   oJson:itens[nX]:quant,   Nil})
                            aadd( aLinhaC1, {"C1_VUNIT",   oJson:itens[nX]:vunit,   Nil})
                            aadd( aLinhaC1, {"C1_DATPRF",  ctod(oJson:itens[nX]:datprf),  Nil})
                            aadd( aLinhaC1, {"C1_OBS",     oJson:itens[nX]:obs,     Nil})
                            aadd( aLinhaC1, {"C1_LOCAL",   oJson:itens[nX]:localx,  Nil})
                            aadd( aLinhaC1, {"C1_CLVL",    oJson:itens[nX]:clvl,    Nil})
                            aadd( aLinhaC1, {"C1_OP",      oJson:itens[nX]:op,      Nil})
                            aadd(aItensSC,aLinhaC1)
                        Next                   

                        //| Teste de Inclusao - Execução Rotina Automática |
                        MSExecAuto({|x,y| mata110(x,y)},aCabSC,aItensSC)
                    Else
                        aadd(aCabSC, {"C1_NUM", oJson:codigo, NIL })
                		aadd(aItensSC, {{"C1_NUM", oJson:codigo, Nil}})
                    	MSExecAuto( {|x,y,z| MATA110(x,y,z)}, aCabSC, aItensSC, 5)
                    EndIF

                    If !lMsErroAuto 
                        lReg := .T.
                    Else
                        lReg := .F.
                    EndIf

                    If lReg
                        cRet := "200 - "
                        If oJson:operacao == "1"
                            cMsg := "Solicitacao inclusa com sucesso: "+alltrim(SC1->C1_NUM)
                        Else
                            cMsg := "Solicitacao excluida com sucesso: "+alltrim(oJson:codigo)
                        EndIf
                    Else
                        cRet := "404 - "
                        If oJson:operacao == "1"
                            cMsg := "Nao foi possivel gerar a soliticacao de compras. "
                        Else
                            cMsg := "Nao foi possivel excluir a soliticacao de compras: "+alltrim(oJson:codigo)
                        EndIf
                    EndIf
                EndIf    
            EndIf    
        EndIf    
    End Sequence
    
    //ErrorBlock(bError)
    
    ::SetResponse( AllTrim( FWHttpEncode('{"Retorno":"'+cRet+cMsg+'","compilado":"'+ aInfo[1]+' '+DtoS(aInfo[4])+'"}' ) ) )
    
Return .T.
