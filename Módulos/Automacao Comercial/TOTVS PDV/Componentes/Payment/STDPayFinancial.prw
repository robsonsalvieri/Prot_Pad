#INCLUDE 'Protheus.ch'
#INCLUDE "STDPAYFINANCIAL.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGetAdmFin


@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDGetAdmFin(cTpForm)
Local aArea 	:= GetArea()
Local aRet  	:= {""}
Local cFilSAE 	:= ""
Local lRet 		:= .F.

DbSelectArea("SAE")
cFilSAE := xFilial("SAE")

IF ExistFunc("STFGetOnPdv") .AND. STFGetOnPdv()
	DBSetOrder(1)
	lRet := DBSeek(cFilSAE)
Else
	SAE->(DbGoTop())
	lRet := !SAE->(EOF()) 
Endif 

If lRet 
	While !SAE->(EOF()) .AND. cFilSAE == SAE->AE_FILIAL
		If AllTrim(SAE->AE_TIPO) == cTpForm
			Aadd(aRet,SAE->AE_COD+" - "+SAE->AE_DESC)
		EndIf 	
		SAE->(DbSkip())
	EndDo
Endif 

If Len(aRet) == 1
	STFMessage(ProcName(),"ALERT",STR0001 + " " + cTpForm + " " + STR0002) //"Nao existe Adm. Financeira do tipo 'FI' cadastrada"
	STFShowMessage(ProcName())
	STFCleanMessage(ProcName())
EndIf

STISetAdm(aRet)

RestArea(aArea)

Return aRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDVencAdmFin
Responsável por efetuar o posicionamento da Adm.Financeira e retornar a data do 
vencimento da parcela 
@param   	cCodAdmFin - Codigo da adm. financeira a ser posicionada
@param   	dData - Data a partir daqual será calculado o proximo vencimento
			
@author  	Vendas & CRM
@version 	P11
@since   	29/04/2015
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDVencAdmFin(cCodAdmFin,dData)
Local dDataRet := dDataBase
Local aArea	 := GetArea("SAE")
 
Default dData := dDataBase

SAE->(DBSetOrder(1)) //AE_FILIAL+AE_COD
If SAE->(DbSeek(xFilial("SAE")+cCodAdmFin))
	dDataRet := LJCalcVenc(.F.,dData)
EndIf

RestArea(aArea)

Return dDataRet
