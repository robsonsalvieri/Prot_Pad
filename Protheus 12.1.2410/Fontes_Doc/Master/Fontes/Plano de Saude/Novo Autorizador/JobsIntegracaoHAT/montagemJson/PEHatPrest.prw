#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"
#INCLUDE "PLSMGER.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatPrest
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatPrest From SyncHndPLS

	Data aTabDup as Array

	Method New()
    Method mntJson()
	Method retBenef()
    Method retPrestad()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatPrest

    _Super:new()

    self:aTabDup   := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
	self:posicBA0()
	
Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} mntJson
    Calcula os totalizadores da guia

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method mntJson() Class PEHatPrest

   	Local nX         := 0
	Local nY         := 0
	Local nBAU       := 1
	Local nBC0       := 0
	Local aAux       := {}
	Local aRetBAU    := {}
	Local aRetBC0    := {}
	Local oObjPrest  := nil
	
	if self:lFindBNV

		self:logPlsToHat("----- Iniciando envio '"+self:cAPI+"'. Alias "+ self:cAlias)
		
		//Inicia o objeto oObjPrest para capturar todos os dados
		oObjPrest := JsonObject():new()
		aAux      := self:retPrestad()

		if !aAux[1]
			//Verifico se o registro posicionado existe no Alias correspondente
			self:logPlsToHat("Dados do pedido nao encontrados.")
			self:errorCriPed(self:cAlias, self:cPedido)
		else
			self:logPlsToHat("Dados do pedido encontrados.")
			//Monta cabecalho do arquivo
			oObjPrest['healthInsurerId'] := self:cCodOpe
			oObjPrest['ansRegistry']     := self:cSusep 
			oObjPrest['providers']       := {}
			aAdd(oObjPrest['providers'], JsonObject():new())

			aRetBAU  := aAux[2]
			aRetBC0  := aAux[3]
			
			//Aqui adiciono as chaves primarias do JSON
			oObjPrest['providers'][nBAU]['healthProviderCode'] := self:retDadArr(aRetBAU,'healthProviderCode')
			oObjPrest['providers'][nBAU]['healthProviderDocument'] := self:retDadArr(aRetBAU,'healthProviderDocument')

			///------------------------------------------------------------
			// Alteracao/Inclusao de dados do prestador
			//------------------------------------------------------------
			if Alltrim(self:cAlias) == "BAU"

				//Dados do prestador - enviar todos os campos
				for nX := 1 to len(aRetBAU)
					if len(aRetBAU[nX]) > 3
						if !Empty(aRetBAU[nX][3]) .Or. aRetBAU[nX][4]
							oObjPrest['providers'][nBAU][aRetBAU[nX][1]]  := aRetBAU[nX][3]
						endIf
					else
						if !Empty(aRetBAU[nX][3])
							oObjPrest['providers'][nBAU][aRetBAU[nX][1]]  := aRetBAU[nX][3]
						endIf
					endIf
				next
				
				//Procedimentos autorizados se houver
				if len(aRetBC0) > 0
					oObjPrest['providers'][nBAU]['procedureCoverage'] := {}
					for nX := 1 to len(aRetBC0) //nX controla o Grupo de procedimentos autorizados
						//Adiciona novo grupo
						aAdd(oObjPrest['providers'][nBAU]['procedureCoverage'], JsonObject():new())

						//Adiciona campos do grupo
						for nY := 1 to len(aRetBC0[nX]) //nY controla os Campos do Grupo de procedimentos autorizados
							if len(aRetBC0[nX][nY]) > 4
								if !Empty(aRetBC0[nX][nY][3]) .Or. aRetBC0[nX][nY][4]
									oObjPrest['providers'][nBAU]['procedureCoverage'][nX][aRetBC0[nX][nY][1]]  := aRetBC0[nX][nY][3]
								endIf
							else
								if !Empty(aRetBC0[nX][nY][3])
									oObjPrest['providers'][nBAU]['procedureCoverage'][nX][aRetBC0[nX][nY][1]]  := aRetBC0[nX][nY][3]
								endIf
							endIf
						next
					next
				endIf

			//------------------------------------------------------------
			// Alteracao/Inclusao de dados da procedimentos autorizados
			//------------------------------------------------------------
			elseIf Alltrim(self:cAlias) == "BC0" .And. len(aRetBC0) > 0

				oObjPrest['providers'][nBAU]['procedureCoverage'] := {}

				for nY := 1 to len(aRetBC0)

					aAux := aRetBC0[nY]

					//Verifica se a chave ja existe no JSON - caso exista, pega sempre o ultimo, pois e' o que tem os dados mais atualizados
					//Caso nao exista, adiciona um novo item no array
					nBC0 := ascan(oObjPrest['providers'][nBAU]['procedureCoverage'],{|x|x['procedureTableCode'] == self:retDadArr(aAux,'procedureTableCode') .And. ;
						x['procedureCode'] == self:retDadArr(aAux,'procedureCode') .And. ;
						x['initialTerm'] == self:retDadArr(aAux,'initialTerm') .And. ;
						x['finalTerm'] == self:retDadArr(aAux,'finalTerm') })

					if nBC0	== 0
						aAdd(oObjPrest['providers'][nBAU]['procedureCoverage'],JsonObject():new())
						nBC0 := len(oObjPrest['providers'][nBAU]['procedureCoverage'])
					endIf

					//Aqui adiciono as chaves primarias do JSON
					oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0]['procedureTableCode'] := self:retDadArr(aAux,'procedureTableCode')
					oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0]['procedureCode'] := self:retDadArr(aAux,'procedureCode')

					for nX := 1 to len(aAux)
						if len(aAux[nX]) > 3
							if !Empty(aAux[nX][3]) .Or. aAux[nX][4]
								oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0][aAux[nX][1]] := aAux[nX][3]
							endIf
						else
							if !Empty(aAux[nX][3])
								oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0][aAux[nX][1]] := aAux[nX][3]
							endIf
						endIf
					next
				next
			endIf

			self:cJson := FWJsonSerialize(oObjPrest, .F., .F.)

		endIf
	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} retPrestad
Retorna array com dados dos Prestadores

@author  Renan Sakai
@version P12
@since    11.10.18
/*/
//-------------------------------------------------------------------
Method retPrestad() Class PEHatPrest
    
    Local cChave      := Alltrim(self:cChaveBNV)
	Local nX		  := 0
	Local lRet		  := .F.
	Local aRetBAU	  := {}
	Local aRetBC0	  := {}
	Local aAux		  := {}
	Local aCodPad	  := {}
	Local aCodPro	  := {}
	Local aMapBAU  	  := PLHATMap("BAU")
	Local aMapBC0  	  := PLHATMap("BC0")
	Local cCodPad  	  := ""
	Local cPadBkp  	  := ""
	Local cCodPro  	  := ""
	Local cCodProTerm := ""

	BAU->(DbSetOrder(1)) //BTS_FILIAL+BTS_MATVID
	if BAU->(DbSeek(xFilial('BAU')+Substr(cChave,1,6)))

		for nX := 1 to len(aMapBAU)
			Aadd(aRetBAU,{aMapBAU[nX][1],;
				aMapBAU[nX][2],;
				&(Substr(aMapBAU[nX][2],1,3)+"->("+aMapBAU[nX][2]+")"),;
				aMapBAU[nX][3]})
		next

		lRet := .T.
	endIf

	//Se o Alias é BC0, carrego somente o registro correspondente
	if self:cAlias == "BC0"
	
		BC0->(DbSetOrder(1))//BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC
		if BC0->(MsSeek(xFilial("BC0")+cChave))
			aAux := {}
			while Alltrim(BC0->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC)) == cChave .And. !BC0->(eof())

				//Itens com vigencia, devo considerar o Recno para posicionar no registro correto
				if self:nIDINT == BC0->(Recno())

					for nX := 1 to len(aMapBC0)

						if Alltrim(aMapBC0[nX][2]) == "BC0_CODPAD"
							cCodPad := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
							aCodPad :=	{aMapBC0[nX][1],;
								aMapBC0[nX][2],;
								"",;
								aMapBC0[nX,3]}

						elseIf Alltrim(aMapBC0[nX][2]) == "BC0_CODOPC"
							cCodPro := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
							aCodPro := 	{aMapBC0[nX][1],;
								aMapBC0[nX][2],;
								"",;
								aMapBC0[nX,3]}

						else
							Aadd(aAux,{aMapBC0[nX][1],;
								aMapBC0[nX][2],;
								&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"),;
								aMapBC0[nX,3]})
						endif
					next

					cPadBkp	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCodPad,.F.))
					cCodProTerm	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodPad,  cCodPad + cCodPro, .F. ,self:aTabDup, @cPadBkp))
					cCodPro	:= iif(len(cCodProTerm) <> len(cCodPro), cCodPro, cCodProTerm)
					cCodPad := cPadBkp

					aCodPad[3] := cCodPad
					aCodPro[3] := cCodPro

					aAdd(aAux, aClone(aCodPad))
					aAdd(aAux, aClone(aCodPro))
					Aadd(aRetBC0,aAux)

					self:freeArr(@aCodPad)
					self:freeArr(@aCodPro)

					Exit
				endIf

				BC0->(DbSkip())
			endDo
		endIf

		//Se Alias é BAU, carrego todos os procedimentos
	elseIf self:cAlias == "BAU"

		BC0->(DbSetOrder(1))//BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC
		if BC0->(MsSeek(xFilial("BC0")+Substr(cChave,1,6)))
			while BC0->BC0_CODIGO == Substr(cChave,1,6) .And. !BC0->(eof())
				aAux := {}

				for nX := 1 to len(aMapBC0)
					if Alltrim(aMapBC0[nX][2]) == "BC0_CODPAD"
						cCodPad := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
						aCodPad :=	{aMapBC0[nX][1],;
							aMapBC0[nX][2],;
							"",;
							aMapBC0[nX,3]}

					elseIf Alltrim(aMapBC0[nX][2]) == "BC0_CODOPC"
						cCodPro := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
						aCodPro := 	{aMapBC0[nX][1],;
							aMapBC0[nX][2],;
							"",;
							aMapBC0[nX,3]}

					else
						Aadd(aAux,{aMapBC0[nX][1],;
							aMapBC0[nX][2],;
							&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"),;
							aMapBC0[nX][3]})
					endif
				next

				cPadBkp	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCodPad,.F.))
				cCodProTerm	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodPad,  cCodPad + cCodPro, .F. ,self:aTabDup, @cPadBkp))
				cCodPro	:= iif(len(cCodProTerm) <> len(cCodPro), cCodPro, cCodProTerm)
				cCodPad := cPadBkp

				aCodPad[3] := cCodPad
				aCodPro[3] := cCodPro

				aAdd(aAux, aClone(aCodPad))
				aAdd(aAux, aClone(aCodPro))
				Aadd(aRetBC0,aAux)

				self:freeArr(@aCodPad)
				self:freeArr(@aCodPro)

				BC0->(DbSkip())

			endDo
		endIf
	endIf

	aRetBAU := self:ajustType(aRetBAU)
	for nX := 1 to len(aRetBC0)
		aRetBC0[nX] := self:ajustType(aRetBC0[nX])
	next

Return {lRet,aRetBAU,aRetBC0}