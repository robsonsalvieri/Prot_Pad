#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"
#INCLUDE "PLSMGER.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBenef
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBenef From SyncHndPLS

	Data cJson as String
	
	Method New()
    Method mntJson()
	Method retBenef()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatBenef

    _Super:new()

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
Method mntJson() Class PEHatBenef

    Local nX      := 0
	Local nY      := 0
	Local nBA1    := 1
	Local nBFE    := 1
	Local aAux    := {}
	Local aRetBA1 := {}
	Local aRetBFE := {}
	Local oObjBenef := nil

	if self:lFindBNV

		self:logPlsToHat("------- Iniciando envio '"+self:cAPI+"'. Alias "+ self:cAlias)
		
		//Inicia o objeto oObjBenef para capturar todos os dados
		oObjBenef := JsonObject():new()
		aAux      := self:retBenef()
		
		if !aAux[1]
			//Verifico se o registro posicionado existe no Alias correspondente
			self:logPlsToHat("Dados do pedido  nao encontrados.")
			self:errorCriPed()
		else
			self:logPlsToHat("Dados do pedido encontrados.")
			//Monta cabecalho do arquivo
			oObjBenef['healthInsurerId'] := self:cCodOpe
			oObjBenef['ansRegistry']     := self:cSusep
			oObjBenef['items']           := {}
			aAdd(oObjBenef['items'], JsonObject():new())

			aRetBA1 := aAux[2]
			aRetBFE := aAux[3]

			//Aqui adiciono as chaves primarias do JSON
			oObjBenef['items'][nBA1]['subscriberId'] := self:retDadArr(aRetBA1,'subscriberId')

			///------------------------------------------------------------
			// Alteracao/Inclusao de dados do beneficiario
			//------------------------------------------------------------
			if Alltrim(self:cAlias) == "BA1"
		
				//Dados do beneficiario
				for nX := 1 to len(aRetBA1)
					if len(aRetBA1[nX]) > 3
						if !Empty(aRetBA1[nX][3]) .Or. aRetBA1[nX][4]
							oObjBenef['items'][nBA1][aRetBA1[nX][1]]  := aRetBA1[nX][3]
						endIf
					else
						if !Empty(aRetBA1[nX][3])
							oObjBenef['items'][nBA1][aRetBA1[nX][1]]  := aRetBA1[nX][3]
						endIf
					endIf
				next

				//Cobertura se houver
				if len(aRetBFE) > 0
					oObjBenef['items'][nBA1]['coverageGroup'] := {}
					for nX := 1 to len(aRetBFE) //nX controla o Grupo de Cobertura
						//Adiciona novo grupo
						aAdd(oObjBenef['items'][nBA1]['coverageGroup'], JsonObject():new())

						//Adiciona campos do grupo
						for nY := 1 to len(aRetBFE[nX]) //nY controla os Campos do Grupo de Cobertura
							if len(aRetBFE[nX][nY]) > 3
								if !Empty(aRetBFE[nX][nY][3]) .or. aRetBFE[nX][nY][4]
									oObjBenef['items'][nBA1]['coverageGroup'][nX][aRetBFE[nX][nY][1]]  := aRetBFE[nX][nY][3]
								endIf
							else
								if !Empty(aRetBFE[nX][nY][3])
									oObjBenef['items'][nBA1]['coverageGroup'][nX][aRetBFE[nX][nY][1]]  := aRetBFE[nX][nY][3]
								endIf
							endIf
						next
					next
				endIf
		
			//------------------------------------------------------------
			// Alteracao/Inclusao de dados da Cobertura
			//------------------------------------------------------------
			elseIf Alltrim(self:cAlias) == "BFE" .And. len(aRetBFE) > 0

				aAux := aRetBFE[1]

				oObjBenef['items'][nBA1]['coverageGroup'] := {}
				aAdd(oObjBenef['items'][nBA1]['coverageGroup'], JsonObject():new())

				//Aqui adiciono as chaves primarias do JSON no alias BFE
				oObjBenef['items'][nBA1]['coverageGroup'][nBFE]['code'] := self:retDadArr(aAux,'code')
			
				//Dados do grupo de cobertura
				for nX := 1 to len(aAux)
					if len(aAux[nX]) > 3
						if !Empty(aAux[nX][3]) .Or. aAux[nX][4]
							oObjBenef['items'][nBA1]['coverageGroup'][nBFE][aAux[nX][1]] := aAux[nX][3]
						endIf
					else
						if !Empty(aAux[nX][3])
							oObjBenef['items'][nBA1]['coverageGroup'][nBFE][aAux[nX][1]] := aAux[nX][3]
						endIf
					endIf
				next
			
			endIf

			self:cJson := FWJsonSerialize(oObjBenef, .F., .F.)

		endIf
	endIf
	
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} retBenef
    Retorna array com dados do beneficiario

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method retBenef() Class PEHatBenef

	Local cChave := self:cChaveBNV
	Local lRet   := .F.
	Local aBA1   := {}
	Local aBFE   := {}
	Local aAux   := {}
	Local aMap   := {}
	Local nX     := 0

	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	BFE->(DbSetOrder(1)) //BFE_FILIAL+BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG+BFE_CODGRU

	if BA1->(DbSeek(xFilial("BA1")+Substr(cChave,1,16)))

		aMap := PLHATMap("BA1")
		for nX := 1 to len(aMap)
			Aadd(aBA1,{aMap[nX][1],;
				aMap[nX][2],;
				&(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")"),;
				aMap[nX][3]})
		next
		if !Empty(BA1->BA1_CODPLA)
			Aadd(aBA1,{'healthInsuranceCode',"BA1_CODPLA",BA1->BA1_CODPLA })
			Aadd(aBA1,{'healthInsuranceVersion',"BA1_VERSAO",BA1->BA1_VERSAO })
		else
			BA3->(DbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
			if BA3->(MsSeek(xFilial("BA3")+Substr(cChave,1,14)))
				Aadd(aBA1,{'healthInsuranceCode',"BA3_CODPLA",BA3->BA3_CODPLA })
				Aadd(aBA1,{'healthInsuranceVersion',"BA3_VERSAO",BA3->BA3_VERSAO })
			else
				Aadd(aBA1,{'healthInsuranceCode',"BA3_CODPLA","" })
				Aadd(aBA1,{'healthInsuranceVersion',"BA3_VERSAO","" })
			endIf
		endIf
		aBA1 := self:ajustType(aBA1)

		//Verifico se os registros existem
		if self:cAlias == "BA1"
			lRet := .T.
		endIf

		//Verifica os niveis de cobertura
		if self:cAlias == "BFE" //BFE pego somente a chave
			if BFE->(DbSeek(xFilial("BFE")+cChave))
				aAux := {}
				aMap := PLHATMap("BFE")
				for nX := 1 to len(aMap)
					Aadd(aAux,{aMap[nX][1],;
						aMap[nX][2],;
						&(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")"),;
						aMap[nX,3]})
				next
				aAux := self:ajustType(aAux)
				Aadd(aBFE,aAux)

				lRet := .T.
			endIf

		elseIf self:cAlias == "BA1" //BA1 carrego todos os niveis de cobertura BFE
			if BFE->(DbSeek(xFilial("BFE")+Substr(cChave,1,16)))
				aMap := PLHATMap("BFE")
				while Substr(cChave,1,16) == BFE->(BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG) .And. !BFE->(Eof())
					if !Empty(BFE->BFE_CODGRU) .And. !Empty(BFE->BFE_TIPREG)
						aAux := {}
						for nX := 1 to len(aMap)
							Aadd(aAux,{aMap[nX][1],;
								aMap[nX][2],;
								&(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")"),;
								aMap[nX,3]})
						next
						aAux := self:ajustType(aAux)
						Aadd(aBFE,aAux)
					endIf
					BFE->(dbSkip())
				endDo
			endIf
		endIf
	endIf

Return {lRet,aBA1,aBFE}