#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AlteraOs    ³ Autor ³ Rafael P Goncalves ³ Data ³04.11.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Método responsável por alterar a ordem de serviço          ³±±
±±³Descricao ³ integrado com o portal do fornecedor                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

WSRESTFUL AlteraOs DESCRIPTION "Altera ordem de serviço integrado com o portal do fornecedor"

	WSMETHOD POST DESCRIPTION "<h2>Método responsável por alterar a ordem de serviço integrado com o portal do fornecedor</h2>" WSSYNTAX "/AlteraOs"

END WSRESTFUL

WSMETHOD POST WSSERVICE AlteraOs
	
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local cRet          := ""
Local aArq        	:= []
Local cTipoArq    	:= ""
Local cKeyArq     	:= ""
Local cNomeArq   	:= ""
Local nX            := 0
Local nY            := 0 
Local aBindParam    := {}
Local aBindPara     := {}
Private oJson		:= Nil
Private nAnexos		:= 0
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp5(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            If (aEmp[3] == "Empresa já existente.")
                cRet := xAbreEnv5(aEmp[1],aEmp[2])
                If Empty(cRet)
                    STJ->(dbSetOrder(1))
                    If STJ->(DbSeek(xFilial("STJ")+oJson:Ordem))
                        
                        For nX := 1 To Len(oJson:Itens)		

                            //Faz a gravação dos anexos que vem no cabeçalho da OS
                            If Len(oJson:Itens[nX]:Anexos) > 0
                                //Faz a gravação dos anexos que vem no cabeçalho da OS
                                For nY := 1 To Len(oJson:Itens[nX]:Anexos)
                                    If Empty(cRet)
                                        nAnexos++
                                        aArq        := STRTOKARR(oJson:Itens[nX]:Anexos[nY]:name,".")
                                        cTipoArq    := Lower(aArq[Len(aArq)])
                                        cKeyArq     := PadR(oJson:Ordem,TamSX3("TJ_ORDEM")[1])
                                        //cNomeArq    := "ANEXO_"+cValtoChar(nAnexos)+"_"+xFilial("STJ")+PadR(cNumOs,TamSX3("TJ_ORDEM")[1])+"."+cTipoArq
                                        cNomeArq    := "ANEXO_"+cValtoChar(nAnexos)+"_"+PadR(oJson:Ordem,TamSX3("TJ_ORDEM")[1])+"."+cTipoArq
                                        cRet := xGAppArq(cNomeArq,oJson:Itens[nX]:Anexos[nY]:base64)

                                        If Empty(cRet)
                                            cRet := xGAppConhec(cNomeArq,"ANEXO "+cValtoChar(nAnexos),cKeyArq,"STJ")
                                        EndIf
                                    EndIf
                                Next nY
                            EndIf
                       
                            aBindParam := {}				
                            aBindPara  := {}
                            
                            cQuery := "SELECT * "
                            cQuery += "FROM "+RetSqlName("STL")+" STL "
                            cQuery += "WHERE STL.D_E_L_E_T_ = ' ' "
                            cQuery += " AND TL_FILIAL = '" +xFilial("STL") + "' "
                            cQuery +=  "AND TL_ORDEM = ? AND TL_SEQTARE = ? "
                            aadd(aBindParam,oJson:Ordem)
                            aadd(aBindParam,oJson:Itens[nX]:seq_tar)

                            cQuery := CHANGEQUERY(cQuery)
                            MPSysOpenQuery(cQuery,"TRBSTL",,,aBindParam)
                            If !TRBSTL->(Eof())
                                STL->(DbGoTo(TRBSTL->R_E_C_N_O_))
                                If RecLock("STL",.F.)
                                    STL->TL_CUSTO     := val(oJson:Itens[nX]:valor_uni)
                                    STL->TL_CODIGO    := val(oJson:Itens[nX]:produto)
                                    STL->TL_QUANTID   := val(oJson:Itens[nX]:qtd)
                                    STL->(MsUnLocK())
                                EndIf
                            EndIf
 
                            cQuery := "SELECT * "
                            cQuery += "FROM "+RetSqlName("FH1")+" FH1 "
                            cQuery += "WHERE FH1.D_E_L_E_T_ = ' ' "
                            cQuery += " AND FH1_FILIAL = '" +xFilial("FH1") + "' "
                            cQuery +=  "AND FH1_ORDEM = ? AND FH1_SEQTAR = ? "
                            aadd(aBindPara,oJson:Ordem)
                            aadd(aBindPara,oJson:Itens[nX]:seq_tar)

                            cQuery := CHANGEQUERY(cQuery)
                            MPSysOpenQuery(cQuery,"TRBFH1",,,aBindPara)

                            FH1->(DbGoTo(TRBFH1->R_E_C_N_O_))
                            If RecLock("FH1",.F.)
                                FH1->FH1_VLRUNI := val(oJson:Itens[nX]:valor_uni)
                                FH1->FH1_CODIGO := val(oJson:Itens[nX]:produto)
                                FH1->FH1_VLRTOT := val(oJson:Itens[nX]:valor_uni) * val(oJson:Itens[nX]:qtd) 
                                FH1->FH1_QUANTI := val(oJson:Itens[nX]:qtd)
                                FH1->(MsUnLocK())
                            EndIf                        
                        Next nX
                    EndIf
                EndIf
            EndIf
		EndIf
	End Sequence

	ErrorBlock(bError)

	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"}')) )

Return (.T.)
