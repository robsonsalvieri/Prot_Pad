#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW054.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Retorna com o banco de conhecimento
@TYPE function
@AUTHOR Frank Zwarg Fuga
@SINCE 01/06/2026
/*/
WSRESTFUL LOCW054 DESCRIPTION "Banco de conhecimento"

	WSMETHOD POST DESCRIPTION "<h2>Banco de conhecimento</h2>" WSSYNTAX "/LOCW054"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW054
ITUP BUSINESS - TOTVS RENTAL
Método para retornar com o banco de conhecimento
@TYPE WSMETHOD
@AUTHOR Frank Zwarg Fuga
@SINCE 01/06/2026
/*/
WSMETHOD POST WSSERVICE LOCW054
//Local cEnvLog  	:= ""
//Local bError    := {||}
Local cRet      := ""
Local cMsg      := ""
Local cBody     := DecodeUtf8(::GetContent())
Local lRet      := .T.
Local aEmp      := {}
Local cFonte    := "LOCW054.PRW"
Local aInfo     := GetAPOInfo(cFonte)
Local cQuery
Local aBindParam := {}
Local cTabela
Local cChave
Local cCodigo
Local lReg
Local cFiltro
Local aAnexos := {}
Local nX
Local cBase64 := ""
Local cAnexo
Local cAnexosx := ""
Local nHandle
Local nSize
Local cContent
Local cComando  :=  ""

Private oJson          := Nil
    
    ::SetContentType("application/json; charset=iso-8859-1")
    
    //bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
    Begin Sequence	
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            
            If Empty(cRet)   
                //VALIDAÇÃÇÕES ANTES DO EXECAUTO
                If Empty(oJson:tabela)
                    cRet := "400 - "
                    cMsg := "Campo 'tabela' e obrigatorio"
                    lRet := .F.
                ElseIf Empty(oJson:chave)
                    cRet := "400 - "
                    cMsg := "Campo 'chave' e obrigatorio"
                    lRet := .F.
                Else    

                    cTabela := oJson:tabela
                    cChave := oJson:chave
                    cCodigo := oJson:codigo

                    cQuery := " SELECT AC9.AC9_CODOBJ, ACB.ACB_OBJETO "
                    cQuery += " FROM " + RETSQLNAME("AC9") + " AC9 "
                    cQuery += " INNER JOIN "+RETSQLNAME("ACB")+" ACB "
                    cQuery += " ON ACB.ACB_FILIAL='"+XFILIAL("ACB")+"' AND ACB.D_E_L_E_T_ = ' ' AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ "
                    cQuery += " WHERE AC9.AC9_FILIAL = ? "
                    aadd(aBindParam,xFilial("AC9"))
                    cQuery += " AND AC9.AC9_ENTIDA = ? "
                    aadd(aBindParam,alltrim(cTabela))
                    cQuery += " AND AC9.AC9_FILENT = ? "
                    aadd(aBindParam,xFilial(cTabela))
                    cQuery += " AND AC9.AC9_CODENT LIKE ? "
                    cFiltro := "%"+alltrim(cChave)+"%"	
                    aadd(aBindParam,cFiltro)
                    If !empty(cCodigo)
                        cQuery += " AND AC9.AC9_CODOBJ = ? "
                        aadd(aBindParam,cCodigo)
                    EndIf
                    cQuery += " AND AC9.D_E_L_E_T_ = ' ' "

                    LOCACLOSE("TRBAC9")

                    cQuery := CHANGEQUERY(cQuery)
                    MPSysOpenQuery(cQuery,"TRBAC9",,,aBindParam)

                    lReg := .F.
                    While !TRBAC9->(Eof())
                        lReg := .T.
                        aadd(aAnexos,{TRBAC9->ACB_OBJETO, TRBAC9->AC9_CODOBJ, ""})
                        TRBAC9->(dbSkip())
                    EndDo

                    cAnexosx := ""

                    If len(aAnexos) > 0
                        cAnexosx := '"anexos":['
                    Endif
                    For nX := 1 to len(aAnexos)
                        cAnexo := Alltrim(MsDocPath()) + "\" + aAnexos[nX,1]
                        cBase64 := ""
                        If File(cAnexo)
                            cComando := "nHandle := fOpen(cAnexo)"
                            &(cComando)
                            If nHandle >= 0
                                nSize    := fSeek(nHandle, 0, FS_END)
                                cContent := Space(nSize)
                                fSeek(nHandle, 0, FS_SET)
                                fRead(nHandle, @cContent, nSize)
                                fClose(nHandle)
                                cBase64 := Encode64(cContent)
                            EndIf
                        EndIf
                        aAnexos[nX,3] := cBase64
                        If nX > 1
                            cAnexosx += ","
                        EndIF
                        cAnexosx += '{ "codigo": "'+aAnexos[nX,2]+'","base64": "'+aAnexos[nX,3]+'" }'
                    Next                       
                    If len(aAnexos) > 0
                        cAnexosx += ']'
                    Endif

                    If lReg
                        cRet := "200 - "
                        cMsg := "OK "
                    Else
                        cRet := "404 - "
                        cMsg := "Nao foram localizados registros validos"
                    EndIf
                EndIf    
            EndIf    
        EndIf    
    End Sequence
    
    //ErrorBlock(bError)
    
    //::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'","compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )
    ::SetResponse( AllTrim( FWHttpEncode('{"Retorno":"'+cRet+cMsg+'","compilado":"'+ aInfo[1]+' '+DtoS(aInfo[4])+'",'+cAnexosx+'}' ) ) )
    
Return .T.
