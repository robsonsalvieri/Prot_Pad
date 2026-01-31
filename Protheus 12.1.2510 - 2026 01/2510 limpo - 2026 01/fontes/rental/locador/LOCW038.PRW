#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW038FQF
Atualização dos sub-status
@type API
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
@type API
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
Local cResult := ""
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
                    dDtIni := ctod(oJson:dtini)
                    cHora := oJson:hora
                    nConta := oJson:contador

                    If empty(cBem) .or. empty(cSubSta)
                        cRet := "É necessário informar o bem e o substatus"
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
                                oModelFQL:AddLine()
                                lAtualiza := .T.
                            EndIf

                            If empty(oModelFQF:GetValue("FQF_SUBST"))
                                lAtualiza := .T.
                            EndIf
                                
                            If lAtualiza
                                If !oModelFQF:SetValue("FQF_SUBST",cSubSta)
                                    cRet := "O substatus não foi aceito."
                                EndIf
                                If !empty(cCC)
                                    If !oModelFQF:SetValue("FQF_CC",cCC)
                                        cRet := "O centro de custo não foi aceito."
                                    EndIf
                                EndIf
                                If !empty(dDtIni)
                                    oModelFQF:SetValue("FQF_DTINI",dDtIni)
                                EndIf
                                If !empty(cHora)
                                    If !oModelFQF:SetValue("FQF_HORA",cHora)
                                        cRet := "A hora não foi aceita."
                                    EndIf
                                EndIf
                                //If nConta > 0
                                //    If !oModelFQF:SetValue("FQF_CONTA",nConta)
                                //        cRet := "O contador não foi aceita."
                                //    EndIf
                                //EndIf
                            //Else
                            //    cRet := "A ocorrência não aceita atualização."
                            EndIF

                        Else

                            cRet := "Bem não localizado no gerenciamento."

                        EndIf

                        LOCACLOSE("TRBFQ4")

                        If empty(cRet)
                            If oModel:VldData()
                                oModel:CommitData()
                                cRet := "A ocorrência foi registrada com o substatus."
                            Else
                                cRet := "A ocorrência não foi registrada."
                            EndIf

                            oModel:DeActivate()
                            oModel:Destroy()
                            oModel := NIL

                        EndIf

                    EndIf

                EndIf
            endif

		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "OK "
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cResult+'}')) )
	

Return .T.

