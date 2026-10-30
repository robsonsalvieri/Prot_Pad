#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'RU09T06.ch'
#include 'RU09XXX.ch'

Class RU09T06EventRUS From FwModelEvent 
	Method New() CONSTRUCTOR	
	Method VldActivate(oModel, cModelID)   
	Method ModelPosVld(oModel, cModelID)

EndClass

Method New() Class RU09T06EventRUS
Return Nil
/*{Protheus.doc} RU09T06EventRUS
@type 		method
@author Daria Sergeeva 
@since 07/02/2019
@version 	P12.1.25
*/
Method VldActivate(oModel, cModelID) Class RU09T06EventRUS
Local lRet as Logical
Local nOperation as Numeric

lRet := .T.
nOperation := oModel:GetOperation() 
lRet := lRet .And. (nOperation != MODEL_OPERATION_UPDATE .Or. F3D->F3D_STATUS != "3" .Or. Empty(F3D_DTLA).Or. FWIsInCallStack('RU09T06001_RETWRIOFF'))

if (!lRet)
	Help("", 1, STR0935,, STR0968, 2,0,,,,,, /*solucao*/)
Endif

Return lRet

Method ModelPosVld(oModel, cModelID) Class RU09T06EventRUS
Local lRet 		as Logical
Local oModelF3D as Object
Local aAreaF3D	as Array
Local cStatus	as Character

lRet :=.T.
oModelF3D := oModel:GetModel("F3DMASTER")
aAreaF3D := F3D->(GetArea())
cStatus := oModelF3D:GetValue("F3D_STATUS")

If cStatus == "3" 
	F3D->(GetArea())
	F3D->(DbSetOrder(1))   // F3D_FILIAL+F3D_WRIKEY                                                                                                                                            
	F3D->(DbGoTop())                                                                                                                                            
	If F3D->(DbSeek(xFilial("F3D") + oModelF3D:GetValue("F3D_WRIKEY")))
		// record exist:
		If F3D->F3D_STATUS <> cStatus 
			// check if F3D_CONTA is empty:
			if Empty(oModelF3D:GetValue("F3D_CONTA")) 
				Help("", 1, STR0935,, STR0969, 2,0,,,,,, /*solucao*/) 
				lRet := .F.
			Endif
		Endif
	Else
		// record does not exist (new) simply evaluate account F3D_CONTA:
		if Empty(oModelF3D:GetValue("F3D_CONTA")) 
			Help("", 1, STR0935,, STR0969, 2,0,,,,,, /*solucao*/) 
			lRet := .F.
		Endif
	Endif
	RestArea(aAreaF3D)
EndIf

Return (lRet)
                   
//Merge Russia R14 
                   
