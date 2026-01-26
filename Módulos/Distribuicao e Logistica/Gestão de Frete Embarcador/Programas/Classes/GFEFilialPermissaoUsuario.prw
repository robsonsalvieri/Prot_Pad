#INCLUDE 'PROTHEUS.CH'

Function GFEFilialPermissaoUsuario()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEFilialPermissaoUsuario()

@author Andre Wisnheski
@since 4/5/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------

CLASS GFEFilialPermissaoUsuario FROM LongNameClass 

   DATA aFilUser
   DATA cFilSQLIn
   DATA aFilRet
   DATA aFilUsrEmp
   DATA lAllEmp

   METHOD New() CONSTRUCTOR
   METHOD ClearData()
   METHOD Destroy(oObject)
   METHOD MontaFilUsr()
   METHOD addRuleUsr()
   METHOD addRuleGrp()

   METHOD setAddFilUser(cFilUser)
   METHOD setFilSQLIn(cFilSQLIn)
   METHOD setFilRet(aFilRet)
   METHOD setFilUsrEmp()
   METHOD setAllEmp(lAllEmp)

   METHOD getFilSQLIn()
   METHOD getFilRet()
   METHOD getAllEmp()

ENDCLASS

METHOD New() Class GFEFilialPermissaoUsuario
   Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEFilialPermissaoUsuario
   FreeObj(oObject)
Return

METHOD ClearData() Class GFEFilialPermissaoUsuario
	Self:aFilUser	:= {}
	Self:cFilSQLIn	:= ""
	Self:aFilRet	:= {}
	Self:aFilUsrEmp	:= {}
	Self:lAllEmp	:= .F.
Return

METHOD MontaFilUsr() CLASS GFEFilialPermissaoUsuario
	Local aRetFil
	Local nCont	:= 0
	
	Self:setFilUsrEmp()
	Self:setAllEmp(AScan(Self:aFilUsrEmp,"@@@@") > 0)
	
	//Se nao foi escolhida nenhuma filial pelo usuário e tem permissão para toda as filiais
	if Len(Self:aFilUser) == 0 .AND. Self:getAllEmp() 
		aRetFil := FWLoadSM0()
		For nCont:= 1 to Len(aRetFil)
			if FWGrpCompany() == aRetFil[nCont][1]
				Self:setFilRet(aRetFil[nCont][2])
				Self:setFilSQLIn(aRetFil[nCont][2])
			EndIf
		Next
	Else
		// se o usuário nao escolheu nenhuma filial, pega todas que tem permissão
		if Len(Self:aFilUser) == 0
			For nCont:= 1 to Len(Self:aFilUsrEmp)
				Self:setFilRet(Self:aFilUsrEmp[nCont])
				Self:setFilSQLIn(Self:aFilUsrEmp[nCont])
			Next
		Else
			// Se o usuário esclheu filiais para filtrar, será selecionada somente as filiais que ele tem permissão.
			For nCont:= 1 to Len(Self:aFilUser)
				If Self:getAllEmp() .OR. (ASCAN(Self:aFilUsrEmp,{|X| Alltrim(X) == Alltrim(Self:aFilUser[nCont])}) > 0)
					Self:setFilRet(Self:aFilUser[nCont])
					Self:setFilSQLIn(Self:aFilUser[nCont])
				EndIf
			Next
		EndIf
	EndIf
Return

//-----------------------------------
//Setters
//-----------------------------------
// Todas as filiais escolhidas pelo usuário deve ser passado como parametro
METHOD setAddFilUser(cFilUser) CLASS GFEFilialPermissaoUsuario
   Aadd(Self:aFilUser,cFilUser)
Return

METHOD setFilSQLIn(cFilSQLIn) CLASS GFEFilialPermissaoUsuario
	if Len(AllTrim(Self:cFilSQLIn)) == 0
		Self:cFilSQLIn := "'" + cFilSQLIn + "'"
	Else
		Self:cFilSQLIn += ",'" +  cFilSQLIn +"'"
	EndIf
Return

METHOD setFilRet(cFilUser) CLASS GFEFilialPermissaoUsuario
	Aadd(Self:aFilRet,cFilUser)
Return

METHOD setFilUsrEmp() CLASS GFEFilialPermissaoUsuario
	Local cRegra := FWUsrGrpRule(__cUserID) // Define qual a regra será usada

	IF cRegra == "0" 
		GFEConout("GFEFilialPermissaoUsuario: Usuario nao encontrado.")
	ElseIf cRegra == "1"
		//Usuário prioriza regras do grupo
		Self:addRuleGrp()
	ElseIf cRegra == "2" .OR. cRegra == "3"
		//cRegra == "2" - Usuário prioriza regras do grupo
		//cRegra == "3" - Usuário soma regras do grupo
		
		Self:addRuleUsr()

		IF cRegra == "3"
			Self:addRuleGrp()
		EndIf
	EndIf
	// for nCont:= 1 to Len(Self:aFilUsrEmp)
	// 	Self:aFilUsrEmp[nCont] := SubStr(Self:aFilUsrEmp[nCont],nTamEmp) 
	// next
Return

METHOD addRuleUsr() CLASS GFEFilialPermissaoUsuario
	Local nCont := 0
	Local nTamEmp := Len(cEmpAnt) + 1
	Local nTamFil := Len(cFilAnt)
	Local aFilU := FWUsrEmp(__cUserID)
	Local cEmp := FWGrpCompany()
	Local lAllEmp
	for nCont:= 1 to Len(aFilU)
		lAllEmp := (AScan(aFilU,"@@@@") > 0)
		If (cEmp == SubStr(aFilU[nCont],1,Len(cEmp))) .OR. lAllEmp // mesmo grupo da empresa logada
			if lAllEmp
				aAdd(Self:aFilUsrEmp,aFilU[nCont])
			Else
				aAdd(Self:aFilUsrEmp,PadR(SubStr(aFilU[nCont],nTamEmp),nTamFil))
			EndIf
		EndIf
	next
Return

METHOD addRuleGrp() CLASS GFEFilialPermissaoUsuario
	Local aFilG // Filiais por Grupo de usuário
	Local nTamEmp
	Local nTamFil
	Local cEmp
	Local nGrp := 0
	Local nCont := 0
	Local aGprUsr
	Local lAllEmp

	// se já tem permissão total por usuário, não precisa buscar as filiais por grupo
	if AScan(Self:aFilUsrEmp,"@@@@") == 0
		nTamEmp := Len(cEmpAnt) + 1
		nTamFil := Len(cFilAnt)
		cEmp := FWGrpCompany()
		aGprUsr := FWSFUsrGrps(__cUserID) // Grupos vinculados oa usuário

		For nGrp:= 1 to Len(aGprUsr)
			aFilG := FWGrpEmp(aGprUsr[nGrp])
			For nCont:= 1 to Len(aFilG)
				lAllEmp := (AScan(aFilG,"@@@@") > 0)
				If (cEmp == SubStr(aFilG[nCont],1,Len(cEmp))) .OR. lAllEmp // mesmo grupo da empresa logada
					If ASCAN(Self:aFilUsrEmp,{|X| Alltrim(X) == SubStr(aFilG[nCont],nTamEmp)}) == 0
						if lAllEmp
							aAdd(Self:aFilUsrEmp,aFilG[nCont])
						Else
							aAdd(Self:aFilUsrEmp,PadR(SubStr(aFilG[nCont],nTamEmp),nTamFil))
						EndIf
					EndIf
				EndIf
			next
		next
	EndIf
Return

METHOD setAllEmp(lAllEmp) CLASS GFEFilialPermissaoUsuario
   Self:lAllEmp := lAllEmp
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getFilSQLIn(cAliasIn) CLASS GFEFilialPermissaoUsuario
Local cRet := ""
Local nI

If cAliasIn == Nil
	cRet := Self:cFilSQLIn
Else
	For nI := 1 To Len(Self:aFilRet)
		//-- Testa se não existe a expressão na cláusula IN em casos de compartilhamento parcial 
		If Empty(cRet) .Or. !(FwxFilial(cAliasIn,Self:aFilRet[nI]) $ cRet)
			cRet +=  Iif(!Empty(cRet),",","") + "'" + FwxFilial(cAliasIn,Self:aFilRet[nI]) + "'"
		EndIf
	Next nI
EndIf

Return cRet

METHOD getFilRet() CLASS GFEFilialPermissaoUsuario
Return Self:aFilRet

METHOD getAllEmp() CLASS GFEFilialPermissaoUsuario
Return Self:lAllEmp
