#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "STFCRMRMS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STFCrmRms
Funcao para pesquisar o credito do cliente no ws da RMS

@author	Varejo
@since		19/08/2014
@version	11
/*/
//-------------------------------------------------------------------
Function STFCrmRms(cType,nVal,cCardConve,cCpfCheck)

Local oDados := Nil //Classe do ws de credito
Local aRet := Array(4) //Array de retorno

Default cType := ''
Default nVal	:= 0
Default cCardConve := ''
Default cCpfCheck := ''

If (cType $ 'CH|CO') .AND. (nVal > 0) .AND. (FindFunction('U__NXTWPAR'))
	// Foi retirado o trecho desse If, pois a função WSCreditoService 
	// utilizada para preencher o objeto oDados, foi descontinuada.
	aRet[1] := .T.
	aRet[2] := 0
	aRet[3] := ''
	aRet[4] := ''
Else
	aRet[1] := .T.
	aRet[2] := 0
	aRet[3] := ''
	aRet[4] := STR0003 //"Forma de pagamento não contempla o CRM!"	
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFRmsWs
Retorna o caminho do web service de credito

@author	Varejo
@since		19/08/2014
@version	11
/*/
//-------------------------------------------------------------------
Static Function STFRmsWs()

Local cPatchWs := '' //Caminho do webservice da rsm

If !Empty(AllTrim(SuperGetMv("MV_LJWSCPO",,"")))
	cPatchWs := 'http://' + AllTrim(SuperGetMv("MV_LJWSCRM",,"")) + ':' + AllTrim(SuperGetMv("MV_LJWSCPO",,"")) + '/RMS.WS.Credito/Services/CreditoService.svc'
Else
	cPatchWs := 'http://' + AllTrim(SuperGetMv("MV_LJWSCRM",,"")) + '/RMS.WS.Credito/Services/CreditoService.svc'
EndIf

Return cPatchWs


//-------------------------------------------------------------------
/*/{Protheus.doc} STFDePFili
Funcao para pesquisar a filial de/para

@author	Varejo
@since		16/08/2014
@version	11
/*/
//-------------------------------------------------------------------
Function STFDePFili(cFilPrt)

Local cFilialRms := '' //Variavel de retorno

Default cFilPrt := ''

If !Empty(cFilPrt)

	dbSelectArea('MGL')
	MGL->(dbSetOrder(2)) //MGL_FILIAL+MGL_FILPRT
	If MGL->(dbSeek(xFilial('MGL')+cFilPrt))
		cFilialRms := MGL->MGL_FILRMS
	EndIf

EndIf

Return cFilialRms

//-------------------------------------------------------------------
/*/{Protheus.doc} STFDePFili
Funcao para pesquisar a filial de/para

@author	Varejo
@since		16/08/2014
@version	11
/*/
//-------------------------------------------------------------------
Function STFCpfCli()

Local cRet := '' //Retorno do documento do cliente
Local aArea := GetArea()	//Guarda area
Local cCodCli := STDGPBasket( "SL1" , "L1_CLIENTE" ) //Retorna o cliente que esta na cesta de vendas
Local cCodLoj := STDGPBasket( "SL1" , "L1_LOJA" ) //Retorna a loja do cliente que esta na cesta de vendas

dbSelectArea("SA1")
SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
If SA1->(dbSeek(xFilial("SA1")+cCodCli+cCodLoj))
	cRet := SA1->A1_CGC
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetAuto
Set da autorizacao para o CRM da RMS

@author	Varejo
@since		16/08/2014
@version	11
/*/
//-------------------------------------------------------------------
Function STFSetAuto()

//bloco de IF e respectivas variáveis excluídos devido trabalho de débito técnico da Engenharia de Funcções não Compiladas
//WSCREDITOSERVICE

STISetChRms()

Return .T.
