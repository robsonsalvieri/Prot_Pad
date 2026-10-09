#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#Include 'FWMVCDef.ch'

/*/{PROTHEUS.DOC} LOCW057.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Custo extra
@TYPE function
@AUTHOR Frank Zwarg Fuga
@SINCE 08/06/2026
/*/
WSRESTFUL LOCW057 DESCRIPTION "Registro do custo extra - RENTAL"

	WSMETHOD POST DESCRIPTION "<h2>Registro do custo extra - RENTAL</h2>" WSSYNTAX "/LOCW057"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW057
ITUP BUSINESS - TOTVS RENTAL
Método para registro do custo extra
@TYPE WSMETHOD
@AUTHOR Frank Zwarg Fuga
@SINCE 08/06/2026
/*/
WSMETHOD POST WSSERVICE LOCW057
Local cRet       := ""
Local cMsg       := ""
Local cBody      := DecodeUtf8(::GetContent())
Local lRet       := .F.
Local aEmp       := {}
Local cFonte     := "LOCW057.PRW"
Local aInfo      := GetAPOInfo(cFonte)
Local cErro      := ""
Local nRegistro  := 0

Private oJson        := Nil
Private oModel

    ::SetContentType("application/json; charset=iso-8859-1")
    
    Begin Sequence	
        
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            
            If Empty(cRet)   
           
                If oJson:operacao == "1"

                    // Incluir o custo extra
                    oModel := FWLoadModel('LOCA007') 
                    oModelFPG := oModel:GetModel("FPGMASTER")
                    oModel:SetOperation(MODEL_OPERATION_INSERT)
                    If oModel:Activate()
                        If oModel:GetModel("FPGMASTER") != Nil
                            oModelFPG:SetValue("FPG_PROJET", oJson:projeto)
                            oModelFPG:SetValue("FPG_NRAS",   oJson:nras)
                            oModelFPG:SetValue("FPG_CUSTO",  oJson:custo)
                            oModelFPG:SetValue("FPG_PRODUT", oJson:produt)
                            oModelFPG:SetValue("FPG_QUANT",  oJson:quant)
                            oModelFPG:SetValue("FPG_VLUNIT", oJson:vlunit)
                            oModelFPG:SetValue("FPG_TAXAP",  oJson:taxap)
                            oModelFPG:SetValue("FPG_COBRA",  oJson:cobra)
                            oModelFPG:SetValue("FPG_COBRAT", oJson:cobrat)
                            oModelFPG:SetValue("FPG_JUNTO",  oJson:junto)
                            oModelFPG:SetValue("FPG_DTENT",  ctod(oJson:dtent))
                            oModelFPG:SetValue("FPG_NATURE", oJson:nature)
                            oModelFPG:SetValue("FPG_OBSCUS", oJson:obscus)
                            If oModel:VldData()
                                lRet := oModel:CommitData()
                            Else
                                lRet := .F.
                            EndIf
                        EndIf
                    EndIf
                    oModel:DeActivate()

                Else
                    
                    // Deletar o custo extra
                    If empty(oJson:codigo) .or. empty(oJson:projeto)
                        cErro := "Falta o preenchimento do codigo, ou projeto."
                        lRet := .F.
                    Else
                        nRegistro := 0
                        FPG->(dbSetorder(1))
                        If FPG->(dbSeek(xFilial("FPG")+oJson:projeto))
                            While !FPG->(Eof()) .and. FPG->(FPG_FILIAL+alltrim(FPG_PROJET)) == xFilial("FPG")+oJson:projeto
                                If alltrim(FPG->FPG_SEQ) == alltrim(oJson:codigo)
                                    nRegistro := FPG->(Recno())
                                    Exit
                                EndIF
                                FPG->(dbSkip())
                            EndDo
                            If nRegistro == 0
                                cErro := "Registro nao localizado"
                                lRet := .F.
                            Else
                                FPG->(dbGoto(nRegistro))
                                If !empty(FPG->FPG_PVNUM)
                                    cErro := "Nao pode ser excluido, ja tem pedido de venda emitido"
                                    lRet := .F.
                                Else
                                    FPG->(RecLock("FPG",.F.))
                                    FPG->(dbDelete())
                                    FPG->(MsUnlock())
                                    lRet := .T.
                                EndIf
                            EndIF
                        EndIf
                    EndIf

                EndIF

                If lRet
                    cRet := "200 - "
                    If oJson:operacao == "1"
                        cMsg := "Custo extra gerado com sucesso. Codigo: "+alltrim(FPG->FPG_SEQ)
                    Else
                        cMsg := "Custo extra removido com sucesso."
                    EndIf
                Else
                    cRet := "404 - "
                    If oJson:operacao == "1"
                        cMsg := "Nao foi possivel gerar o custo extra. "
                    Else
                        cMsg := "Nao foi possivel remover o custo extra. Erro: "+cErro
                    EndIf
                EndIf
            EndIf    
        EndIf    

    End Sequence
      
    ::SetResponse( AllTrim( FWHttpEncode('{"Retorno":"'+cRet+cMsg+'","compilado":"'+ aInfo[1]+' '+DtoS(aInfo[4])+'"}' ) ) )
    
Return .T.
