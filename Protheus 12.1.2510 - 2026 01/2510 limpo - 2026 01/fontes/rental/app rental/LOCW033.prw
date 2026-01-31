#Include "locw033.ch"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "Protheus.ch" 
#Include "tbiconn.ch"
#Include "Topconn.CH"  
#Include "fileio.ch"

/*/{Protheus.doc} LOCW033APR
@description	API Aprovação de Proposta
@author			Dennis Calabrez
@since     		13/10/2025
/*/     
WSRESTFUL LOCW033APR DESCRIPTION STR0001  //"Aprovação de Proposta RENTAL"

WSDATA usuario    AS STRING 
WSDATA filialproj AS STRING 
WSDATA projeto    AS STRING 

   WSMETHOD POST APROVE DESCRIPTION STR0002 PATH "/LOCW033APR/APROVE" //"<h2>Aprovação de Proposta RENTAL.</h2>"
	WSMETHOD POST REPROVE DESCRIPTION STR0003 PATH "/LOCW033APR/REPROVE" //"<h2>Reprovação de Proposta RENTAL.</h2>"

END WSRESTFUL

/*/{Protheus.doc} METODO APROVE
@description	API Aprovação de Proposta RENTAL
@author			Dennis Calabrez
@since     		13/10/2025
/*/     
WSMETHOD POST APROVE WSRECEIVE WSSERVICE LOCW033APR 
Local lRet     := .T.
Local cBody    := NoAcento(DecodeUtf8(::GetContent()))
Local cMessage := LOCW0331(cBody)

   ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cMessage+'"}')) )

Return lRet

/*/{Protheus.doc} METODO REPROVE
@description	API Reprovação de Proposta RENTAL 
@author			Dennis Calabrez
@since     		13/10/2025
/*/     
WSMETHOD POST REPROVE WSRECEIVE WSSERVICE LOCW033APR 
Local lRet     := .T.
Local cBody    := NoAcento(DecodeUtf8(::GetContent()))
Local cMessage := LOCW0331(cBody,.T.)

   ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cMessage+'"}')) )

Return lRet

/*/{Protheus.doc} LOCW0331
@description	Aprovação de Proposta
@author			Dennis Calabrez
@since     		13/10/2025
/*/  
Static Function LOCW0331(cBody,lReprove)
Local cResponse      := ""
Local cfilialproj    := ""
Local cprojeto       := ""
Local cusuario       := ""
Local cErro          := ""
Local oJson          := Nil

Default cBody        := ""
Default lReprove     := .F.

   If FWJsonDeserialize(cBody,@oJson)

      cusuario    := oJson:usuario
      cfilialproj := oJson:filialproj 
      cprojeto    := oJson:projeto 

      cResponse   :=  LOCW0332(cusuario,cfilialproj,cprojeto,lReprove)

   Else
      cErro := STR0004 //"JSON FORA DA ESTRURA"
   EndIf

   If Empty(cErro)
      cResponse := FWNoAccent(cResponse)
   Else   
      cResponse := cErro
   EndIf

Return cResponse

/*/{Protheus.doc} LOCW0332
@description	Aprovação de Proposta
@author			Dennis Calabrez
@since     		13/10/2025
/*/   
Static Function LOCW0332(cusuario,cfilialproj,cprojeto,lReprove)
Local cErro       := ""
Local cProcess    := ""
Local cMessage    := ""
Local cFilBkp     := cFilAnt
Local cNameBkp    := cUserName
Local cAprove     := STR0011 //"APROVADA"
Local aAreaFp0    := FP0->(GetArea())
Local aAreaFpr    := FPR->(GetArea())
Local lContinua   := .T.
Local lNotErro    := .F.

Default cusuario     := ""
Default cfilialproj  := ""
Default cprojeto     := ""
Default lReprove     := .F.

   //altera filial para funcionar xFilial na função de aprovação
   cFilAnt := cfilialproj

   cUserName := UsrRetName(cusuario)

   //valida projeto
   If lContinua 
      If Empty(cfilialproj)
         lContinua := .F.
         cErro := STR0012 //"FILIAL NÃO INFORMADA"
      ElseIf Empty(cprojeto)
         lContinua := .F.
         cErro := STR0013 //"PROPOSTA NÃO INFORMADA"
      Else
         FP0->(DbSetOrder(1)) //FP0_FILIAL+FP0_PROJET
         If FP0->(DbSeek(cfilialproj + cprojeto))
            If FP0->FP0_STATUS <> "2"
               lContinua   := .F.
               cErro       := STR0015 //"PROPOSTA INFORMADA NÃO ESTÁ NO STATUS 'EM APROVAÇAO'"
            EndIf
         Else
            lContinua := .F.
            cErro := STR0016 //"PROPOSTA NÃO LOCALIZADA"
         EndIf
      EndIf
   EndIf

   //realiza aprovação
   If lContinua .And. Empty(cErro)

      //chama a função padrão do LOCA057 para Aprovar ou Reporvar o Projeto
      If lContinua := LOCA05704(cprojeto,cUserName,.T.,.T.,lReprove,.T.,@cErro,@lNotErro)
         If lReprove
            cAprove := STR0017 //"REPROVADA"
         EndIf
         cProcess := STR0018 //"SUCESSO"
         cMessage := STR0019 + cprojeto + ' ' + cAprove //"PROPOSTA "
         
      EndIf

   EndIf

   If !Empty(cErro)
      cMessage := cErro
   EndIf

   //retona para filial original
   cFilAnt     := cFilBkp
   cUserName   := cNameBkp

   RestArea(aAreaFp0)
   RestArea(aAreaFpr)
   
Return cMessage
