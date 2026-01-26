#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBF3
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBF3 From PEHatGener

    Data aTabDup as Array

	Method New()
    Method retDadJson()
	
EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatBF3

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'subscriberId','diseaseCode'}
    self:aTabDup    := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadJson
Retorna array com dados das doencas pre-existentes

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method retDadJson() Class PEHatBF3

	Local cCodPad		:= ""
	Local cPadBkp		:= ""
	Local cCodPro		:= ""
	Local cCodProTerm	:= ""
	Local aCodPad		:= {}
	Local aCodPro		:= {}
	Local lRet			:= .F.
	Local aMap			:= PLHATMap("BF3")
	Local aRet			:= {}
	Local nX			:= 0

	BF3->(DbSetOrder(1))//BF3_FILIAL+BF3_MATVID
	if BF3->(DbSeek(xFilial('BF3')+self:cChaveBNV))

		for nX := 1 to len(aMap)
			if Alltrim(aMap[nX][2]) == "BF3_CODPAD"
				cCodPad := &(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")")
				aCodPad := {aMap[nX][1],;
					aMap[nX][2],;
					"",;
					aMap[nX][3]}

			elseIf Alltrim(aMap[nX][2]) == "BF3_CODPSA"
				cCodPro := &(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")")
				aCodPro := {aMap[nX][1],;
					aMap[nX][2],;
					"",;
					aMap[nX][3]}

			else
				Aadd(aRet,{aMap[nX,1],;
					aMap[nX,2],;
					&(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
					aMap[nX,3]})
			endif
		next

		cPadBkp	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCodPad,.F.))
		cCodProTerm	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodPad,  cCodPad + cCodPro, .F. ,self:aTabDup, @cPadBkp))
		cCodPro	:= iif(len(cCodProTerm) <> len(cCodPro), cCodPro, cCodProTerm)
		cCodPad := cPadBkp

		aCodPad[3] := cCodPad
		aCodPro[3] := cCodPro

		aAdd(aRet, aClone(aCodPad))
		aAdd(aRet, aClone(aCodPro))

		self:freeArr(@aCodPad)
		self:freeArr(@aCodPro)

		lRet := .T.
	endIf
	aRet := self:ajustType(aRet)

Return {lRet,aRet}