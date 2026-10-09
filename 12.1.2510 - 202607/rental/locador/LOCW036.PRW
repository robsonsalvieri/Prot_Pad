#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW036FQE
Consulta dos sub-status
@type API
@version V1 
@author Frank Zwarg Fuga
@since 15/10/2025
/*/
WSRESTFUL LOCW036FQE DESCRIPTION "Consulta dos sub-status"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para consulta dos sub-status</h2>" WSSYNTAX "/LOCW036FQE"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW036FQE
ITUP BUSINESS - TOTVS RENTAL
Consulta dos sub-status
@type API
@version V1 
@author Frank Zwarg Fuga
@since 03/10/2025
/*/
WSMETHOD POST WSSERVICE LOCW036FQE
Local bError := {||}
Local cBody	:= DecodeUtf8(::GetContent())
Local cRet := ""
Local cEnvLog := ""
Local aEmp := {}
Local cQuery := ""
Local cResult := ""
Local aServicos := {}
Local nX
Local cTemp

Private oJson		:= Nil

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
                cRet := xAbreEnv(aEmp[1],aEmp[2])
                If Empty(cRet)

                    LOCACLOSE("TRBFQE")

                    cQuery := "SELECT FQE.R_E_C_N_O_ REG "
                    cQuery += "FROM "+RetSqlName("FQE")+" FQE "
                    cQuery += "WHERE FQE.FQE_FILIAL = '"+xFilial("FQE")+"' AND "
                    cQuery += "FQE.D_E_L_E_T_ = ' '  "
                    
                    cQuery += "ORDER BY FQE_CODIGO "

                    cQuery := CHANGEQUERY(cQuery)
                    MPSysOpenQuery(cQuery,"TRBFQE",,,)

                    cResult += ', "substatus": ['
                    While !TRBFQE->(Eof())

                        FQE->(dbGoto(TRBFQE->REG))

                        aServicos := {}

                        FQH->(dbSetOrder(1))                    
                        If FQH->(dbSeek(xFilial("FQH")+FQE->(FQE_CODSTA+FQE_CODIGO)))
                            While !FQH->(Eof()) .and. FQH->(FQH_FILIAL+FQH_SUBSTA+FQH_STATUS) == xFilial("FQH")+FQE->(FQE_CODIGO+FQE_CODSTA)
                                aadd(aServicos,{FQH->(Recno())})
                                FQH->(dbSkip())
                            EndDo
                        EndIf

                        cResult += ' { '
                        cResult += ' "filial": "'+FQE->FQE_FILIAL+'",'
                        cResult += ' "substatus": "'+FQE->FQE_CODIGO+'",'
                        cResult += ' "descricao": "'+FQE->FQE_DESCRI+'",'
                        cResult += ' "status": "'+FQE->FQE_CODSTA+'",'
                        cResult += ' "descstatus": "'+POSICIONE("FQD",2,XFILIAL("FQD")+FQE->FQE_CODSTA,"FQD_DESTQY")+'",'
                        cResult += ' "caract": "'+FQE->FQE_CARACT+'",'
                        ST9->(dbSetOrder(1))
                        cTemp := ""
                        If !empty(FQE->FQE_CARACT)    
                            If ST9->(dbSeek(xFilial("ST9")+FQE->FQE_CARACT))
                                cTemp := ST9->T9_NOME
                            EndIf
                        EndIF
                        cResult += ' "descaract": "'+cTemp+'",'
                        cResult += ' "subst": "'+If(FQE->FQE_SUBST=="S","Sim","Não")+'",'
                        cResult += ' "tipo": "'+If(FQE->FQE_TIPO=="1","Entrada","Saída")+'",'
                        
                        cResult += ' "servicos": [{'
                        If len(aServicos) == 0
                            cResult += ' "servico": "'+""+'" '
                        else
                            For nX := 1 to len(aServicos)
                                FQH->(dbGoto(aServicos[nX,1]))
                                ST9->(dbSetOrder(1))
                                ST9->(dbSeek(xfilial("ST9")+FQH->FQH_SERV))
                                cResult += ' "servico": "'+FQH->FQH_SERV+" - "+ST9->T9_NOME+'" '
                                If nX+1 <= len(aServicos)
                                    cResult += ', '
                                EndIf
                            Next
                        EndIf
                        cResult += '}] '
                        cResult += ' }'

                        TRBFQE->(dbSkip())

                        If !TRBFQE->(Eof())
                            cResult += ', '
                        EndIf

                    EndDo
                    
                    cResult += '] '

                    LOCACLOSE("TRBFQE")

                EndIf
            endif

		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "OK "
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cResult+'}')) )
	
Return .T.

