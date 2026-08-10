#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} RetChecklistEntrega
ITUP BUSINESS - TOTVS RENTAL
Metodo retorna o checklist de entrega a partir do devolução
Dev.criação: Dennis
Cod Review 30/09/2025 - Frank Z Fuga
/*/

WSRESTFUL RetChecklistEntrega DESCRIPTION "Método retorna o checklist de entrega a partir da devolução"

	WSMETHOD POST DESCRIPTION "<h2>Método retorna o checklist de entrega a partir da devolução.</h2>" WSSYNTAX "/RetChecklistEntrega"

END WSRESTFUL

/*/{PROTHEUS.DOC} RetChecklistEntrega
ITUP BUSINESS - TOTVS RENTAL
Metodo retorna o checklist de entrega a partir do devolução
Dev.criação: Dennis
Cod Review 30/09/2025 - Frank Z Fuga
/*/

WSMETHOD POST WSSERVICE RetChecklistEntrega
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local oJson			:= Nil
Local cRet			:= ""
Local cDados        := ""

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de cÃ³digo do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))//aEmp := FwLoadSm0()//xVerEmp(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")//If RpcSetEnv(aEmp[1,1],aEmp[1,2],,,"FIN",GetEnvServer(),{""})//(aEmp[3] == "Empresa já existente.")

                cRet := xAbreEnv1(aEmp[1],aEmp[2])
                If Empty(cRet)
                    DbSelectArea("ST9")
                    ST9->(DbSetOrder(1))
                    If ST9->(DbSeek(xFilial("ST9")+oJson:CodBem))
                        //SE FOR CHECK-LIST DE ENTREGA E DEVOLUÇÃO E STATUS TIVER EM 20, SIGNIFICA QUE ESTÃO DEVOLVENDO
                        If oJson:CodForm == "2" 

                            FQD->(dbSetOrder(2))
                            FQD->(dbSeek(xFilial("FQD")+ST9->T9_STATUS))

                            If Alltrim(FQD->FQD_STAREN) == "20" .and. !FQD->(Eof())
                                STB->(DbSetOrder(1))
                                STB->(DbGoTop())
                                If STB->(DbSeek(xFilial("STB")+oJson:CodBem))
                                    FQE->(DbSetOrder(2))
                                    FQE->(DbGoTop())
                                    If FQE->(DbSeek(xFilial("FQE")+ST9->T9_STATUS))                            
                                            cDados := getCheckEntrega(oJson:CodBem,"S")
                                    Else
                                            cDados := getCheckEntrega(oJson:CodBem,"N")     
                                    EndIf
                                EndIf            
                            Else
                                cRet := "ERRO-Veículo não se encontra com status 20-"+Alltrim(Posicione("FQD",1,xFilial("FQD")+"20","FQD_DESTQY"))
                            EndIf
                        Else
                            cRet := "ERRO-Busca apenas para formulário de entrega e devolução"
                        EndIf
                    Else
                        cRet := "ERRO-Não foi possí­vel encontrar o veí­culo(ST9) "+oJson:CodBem
                    EndIf
                EndIf
            endif

        EndIf
	End Sequence

	ErrorBlock(bError)

	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"'+cDados+'}')) )
	
Return .T.

/*/{PROTHEUS.DOC} getCheckEntrega
ITUP BUSINESS - TOTVS RENTAL
Retorna o checklist de entrega a partir do devolução
Dev.criação: Dennis
Cod Review 30/09/2025 - Frank Z Fuga
/*/

Function getCheckEntrega(cCodBem,cCarroReserva)
Local cQuery          := ""
Local cDados          := ""
Local cStatus00       := "00"
Local cStatus10       := "10"
Local aBindParam      := {}

Default cCarroReserva := "N"

    FQD->(dbSetOrder(1))
    If FQD->(dbSeek(xFilial("FQD")+cStatus00))
        cStatus00 := FQD->FQD_STATQY
    EndIf
    If FQD->(dbSeek(xFilial("FQD")+cStatus10))
        cStatus10 := FQD->FQD_STATQY
    EndIf

    cQuery := "SELECT FQC_FILIAL, FQC_CODCHE, FQC_SEQ FROM "+RetSqlName("FQC")+" FQC "
    cQuery += "WHERE FQC_FILIAL = '"+xFilial("FQC")+"' "
    cQuery += "AND FQC_CODBEM = ? "
    aadd(aBindParam,Alltrim(cCodBem))
    cQuery += "AND FQC_CODFOR = '2' "
    If cCarroReserva == "S"
        cQuery += "AND FQC_STBEMA = ? "
        aadd(aBindParam,cStatus00)
    Else
        cQuery += "AND FQC_STBEMA = ? "
        aadd(aBindParam,cStatus10)
    EndIf
    cQuery += "AND FQC.D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY FQC.R_E_C_N_O_ DESC"

    LOCACLOSE("TRBFQC")

    cQuery := ChangeQuery(cQuery)
    
    MPSysOpenQuery(cQuery,"TRBFQC",,,aBindParam)
    
    cDados += ', "CheckListEntrega": {'
    If TRBFQC->(EoF())
        cDados += ' "Filial": "",'
        cDados += ' "Codigo": "",'
        cDados += ' "Seq": ""'
    Else
        cDados += ' "Filial": "'+TRBFQC->FQC_FILIAL+'",'
        cDados += ' "Codigo": "'+TRBFQC->FQC_CODCHE+'",'
        cDados += ' "Seq": "'+TRBFQC->FQC_SEQ+'"'
    EndIf
    cDados += ' }'
    
Return (cDados)
