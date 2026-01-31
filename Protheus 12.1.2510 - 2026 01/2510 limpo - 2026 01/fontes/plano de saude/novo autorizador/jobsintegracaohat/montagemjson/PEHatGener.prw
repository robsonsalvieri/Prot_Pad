#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"
#INCLUDE "PLSMGER.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatGener
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatGener From SyncHndPLS

	Data cJson as String
    
    Data nInd as Integer 
	Data cNodePrinc as String
    Data aNodeKey as Array	

	Method New()
    Method mntJson()
	Method retDadJson()
	Method mntCabec(oObj)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatGener

    _Super:new()

	self:nInd       := 1
	self:cNodePrinc := ""
	self:aNodeKey   := {}
	
	self:posicBA0()

Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} mntJson
    Metodo padrao de montagem de corpo da mensagem

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method mntJson() Class PEHatGener

	Local nX         := 0
	Local nItem      := 1
	Local cAux       := ""
	Local aAux       := {}
	Local aRetItem   := {}
	Local oObj       := nil
	
	if self:lFindBNV
		
		self:logPlsToHat("----- Iniciando envio '"+self:cAPI+"'. Alias "+ self:cAlias)

		//Cria novo objeto para cada pedido
		oObj := JsonObject():new()

		//Verifica se usa funcao padrao de busca de dados ou especifica
		aAux := self:retDadJson()

		if !aAux[1]
			//Verifico se o registro posicionado existe no Alias correspondente
			self:logPlsToHat("Dados do pedido nao encontrados.")
			self:errorCriPed(self:cAlias, self:cPedido)
		else
			self:logPlsToHat("Dados do pedido encontrados.")
			//Monta cabecalho do arquivo
			self:mntCabec(oObj)

			oObj[self:cNodePrinc] := {}
			aAdd(oObj[self:cNodePrinc], JsonObject():new())
			aRetItem := aAux[2]

			//Aqui adiciono as chaves primarias do JSON
			for nX := 1 to len(self:aNodeKey)
				cAux := self:retDadArr(aRetItem,self:aNodeKey[nX])
				if !Empty(cAux)
					oObj[self:cNodePrinc][nItem][self:aNodeKey[nX]] := cAux
				endIf
			next

			//Adiciona os valores dos campos
			for nX := 1 to len(aRetItem)
				if len(aRetItem[nX]) > 3
					if !Empty(aRetItem[nX][3]) .Or. aRetItem[nX][4] //Posicao 4 indica que pode gerar uma tag vazia
						oObj[self:cNodePrinc][nItem][aRetItem[nX][1]]  := aRetItem[nX][3]
					endIf
				else
					if !Empty(aRetItem[nX][3])
						oObj[self:cNodePrinc][nItem][aRetItem[nX][1]]  := aRetItem[nX][3]
					endIf
				endIf
			next

			self:cJson := FWJsonSerialize(oObj, .F., .F.)

		endIf
	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadJson
Metodo padrao para carregar dados de uma Alias

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method retDadJson() Class PEHatGener

	Local lRet := .F.
	Local aMap := PLHATMap(self:cAlias)
	Local aRet := {}
	Local nX   := 0

	(self:cAlias)->(DbSetOrder(self:nInd))
	if (self:cAlias)->(DbSeek(xFilial(self:cAlias)+self:cChaveBNV))
		for nX := 1 to len(aMap)
			Aadd(aRet,{aMap[nX,1],;
				aMap[nX,2],;
				&(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
				aMap[nX,3]})
		next
		lRet := .T.
	endIf
	aRet := self:ajustType(aRet)

Return {lRet,aRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} mntCabec
Metodo padrao de montagem de cabecalho

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method mntCabec(oObj) Class PEHatGener

	oObj['healthInsurerId'] := self:cCodOpe
	oObj['ansRegistry']     := self:cSusep 

Return