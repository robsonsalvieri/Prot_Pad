#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "locw038.ch"

/*/{Protheus.doc} LOCW038FQF
Atualização dos sub-status
@type function
@version V1 
@author Frank Zwarg Fuga
@since 15/10/2025
/*/
WSRESTFUL LOCW038FQF DESCRIPTION "Atualização do sub-status"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para atualização do sub-status</h2>" WSSYNTAX "/LOCW038FQF"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW038FQF
ITUP BUSINESS - TOTVS RENTAL
Atualização do sub-status
@type function
@version V1 
@author Frank Zwarg Fuga
@since 23/10/2025
/*/
WSMETHOD POST WSSERVICE LOCW038FQF
Local bError := {||}
Local cBody	:= DecodeUtf8(::GetContent())
Local cRet := ""
Local cEnvLog := ""
Local aEmp := {}
Local cQuery := ""
Local cBem
Local aBindParam := {}
Local oModel
Local oModelFQ4
Local oModelFQF
Local cSubSta := ""
Local cCC := ""
Local dDtIni := ctod("")
Local cHora := ""
Local nConta := 0
Local lAtualiza
Local cMemo := ""
Local cField := ""
Local nHttpStatus := 200

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

                    cBem := oJson:bem
                    cSubSta := oJson:substatus
                    cCC := oJson:cc
                    cHora := oJson:hora
                    nConta := oJson:contador
					cMemo := oJson:memo


                    // Validacao do formato da data AAAAMMDD
                    If !empty(oJson:dtini)
						if Len(Alltrim(oJson:dtini)) <> 8
							cRet := STR0001 //"Formato de data invalido. Utilize AAAAMMDD."
							cField := "dtini"
							nHttpStatus := 400
						else
							dDtIni := stod(oJson:dtini)
						endif
                    EndIf

                    If empty(cBem) .and. empty(cRet)
                        cRet := STR0002 //"O campo bem e obrigatorio."
                        cField := "bem"
                        nHttpStatus := 400
                    EndIf

                    If empty(cSubSta) .and. empty(cRet)
                        cRet := STR0003 //"O campo substatus e obrigatorio."
                        cField := "substatus"
                        nHttpStatus := 400
                    EndIf

                    If empty(cRet)

                        LOCACLOSE("TRBFQ4")

                        cQuery := "SELECT FQ4.R_E_C_N_O_ REG "
                        cQuery += "FROM "+RetSqlName("FQ4")+" FQ4 "
                        cQuery += "WHERE FQ4.D_E_L_E_T_ = ' ' AND FQ4.FQ4_CODBEM = ? "
                        aadd(aBindParam,cBem)
                        cQuery += "AND FQ4.FQ4_SEQ = (SELECT MAX(FQ4A.FQ4_SEQ) FROM "+ RetSqlName("FQ4") + " FQ4A " 
                        cQuery += "WHERE FQ4A.D_E_L_E_T_ = '' "
                        cQuery += "AND FQ4A.FQ4_FILIAL = '"+xFilial("FQ4")+"' "       
                        cQuery += "AND FQ4A.FQ4_CODBEM = FQ4.FQ4_CODBEM "
                        cQuery += ") "			
                        cQuery := CHANGEQUERY(cQuery)
                        MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)//TcQuery cQuery New Alias "TRBFQ4"

                        If !TRBFQ4->(Eof())

                            ST9->(dbSetOrder(1))
                            ST9->(dbSeek(xFilial("ST9")+cBem))
                        
                            FQ4->(dbGoto(TRBFQ4->REG))

                            oModel	:= FWLoadModel('LOCA224') 
                            oModelFQ4 := oModel:GetModel("FQ4DETAIL")
                            oModelFQF := oModel:GetModel("FQFDETAIL")

                            oModel:SetOperation(4)
                            oModel:Activate()

                            lAtualiza := .F.
                            
                            If !empty(oModelFQF:GetValue("FQF_SUBST"))
                                if oModelFQF:AddLine()
                                	lAtualiza := .T.
                                    /*
								else
									cRet := STR0004 + oModel:GetErrorMessage() //"Nao foi possivel adicionar nova linha de sub-status: "
									nHttpStatus := 500
									lAtualiza := .F.
                                    */
								endif
                            EndIf

                            If empty(oModelFQF:GetValue("FQF_SUBST"))
                                lAtualiza := .T.
                            EndIf
                                
                            If lAtualiza
                                If !oModelFQF:SetValue("FQF_SUBST",cSubSta)
                                    cRet := STR0005 //"O substatus não foi aceito."
									cField := "substatus"
                                    nHttpStatus := 400									
                                EndIf
                                If !empty(cCC) .and. empty(cRet)
                                    If !oModelFQF:SetValue("FQF_CC",cCC)
                                        cRet := STR0006 //"O centro de custo não foi aceito."
										cField := "cc"
                                        nHttpStatus := 400										
                                    EndIf
                                EndIf
                                If !empty(dDtIni) .and. empty(cRet)
                                    If !oModelFQF:SetValue("FQF_DTINI",dDtIni)
										cRet := STR0007 //"A data não foi aceita."
										cField := "data"
										nHttpStatus := 400										
									endif
                                EndIf
                                If !empty(cHora) .and. empty(cRet)
                                    If !oModelFQF:SetValue("FQF_HORA",cHora)
                                        cRet := STR0008 //"A hora não foi aceita."
                                        cField := "hora"
                                        nHttpStatus := 400										
                                    EndIf
                                EndIf
                                If !empty(cMemo) .and. empty(cRet)
                                    If !oModelFQF:SetValue("FQF_OBS",cMemo)
                                        cRet := STR0009 //"O memo nao foi aceito."
                                        cField := "memo"
                                        nHttpStatus := 400
                                    EndIf
                                EndIf
/*
                                If empty(cRet)
                                    If !oModelFQF:SetValue("FQF_CONTA",nConta)
                                        cRet := "O contador nao foi aceito."
                                        cField := "contador"
                                        nHttpStatus := 400
                                    EndIf
                                EndIf
  */
                            //Else
                            //    cRet := "A ocorrência não aceita atualização."
                            EndIF
/*
                        Else

                            cRet := STR0010 //"Bem não localizado no gerenciamento."
							nHttpStatus := 404
*/
                        EndIf

                        LOCACLOSE("TRBFQ4")
                        If empty(cRet)

                            If oModel:VldData()

                                If oModel:CommitData()

                                    cRet := STR0011 //"A ocorroncia foi registrada com o substatus."

                                EndIf

                            Else

                                cRet := STR0013 + oModel:GetErrorMessage() //"Validacao do modelo: "

                                nHttpStatus := 500

                            EndIf

                        EndIf

						If oModel <> NIL
							oModel:DeActivate()
							oModel:Destroy()
							oModel := NIL
						endif

                    EndIf

                EndIf
            endif

		EndIf
	End Sequence

	::SetStatus(nHttpStatus)

	If nHttpStatus == 200
		If Empty(cRet)
			cRet := "OK"
		EndIf
		::SetResponse(FWhttpEncode('{"success":true,"message":"'+fwnoaccent(cRet)+'"}'))
	Else
		::SetResponse(FWhttpEncode('{"success":false,"error":"'+fwnoaccent(cRet)+'","field":"'+fwnoaccent(cField)+'"}'))
	EndIf

Return .T.


 
