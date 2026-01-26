#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCDFACE
Descricao: 	Critica referente ao Campo.
				-> BKS_CDFACE 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCDFACE From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCDFACE
	
	_Super:New()
	self:setAlias('BKS')
	self:setCodCrit('M062' )
	self:setMsgCrit('O Código de Identificação da face do dente é inválido.')
	self:setSolCrit('Preencha corretamente o campo Identificação da(s) face(s) do dente referido no campo Dente, conforme tabela de domínio vigente na versão que a guia foi enviada.')
	self:setCpoCrit('BKS_CDFACE')
	self:setCodANS('5039')

Return Self

Method Validar() Class CritCDFACE
	
	Local lRet		:= .T.
	Local oColBKR	:= CenCltBKR():New()
	Local cTpGuia	:= '4'
	Local cAux      := ""
	Local aFaces    := {}
	Local nI        := 0
	
	oColBKR:SetValue('operatorRecord'		,Self:oEntity:getValue("operatorRecord"))   
	oColBKR:SetValue('operatorFormNumber'	,Self:oEntity:getValue("operatorFormNumber"))
	oColBKR:SetValue('requirementCode'		,Self:oEntity:getValue("requirementCode"))
	oColBKR:SetValue('referenceYear'		,Self:oEntity:getValue("referenceYear"))
	oColBKR:SetValue('commitmentCode'		,Self:oEntity:getValue("commitmentCode"))
	oColBKR:SetValue('formProcDt'			,Self:oEntity:getValue("formProcDt"))
	
	If !Empty(self:oEntity:getValue('toothFaceCode')) .And. Len(self:oEntity:getValue('toothFaceCode')) <= 5 .And. oColBKR:bscTpGuia(cTpGuia) 
			
		For nI:= 1 to Len(self:oEntity:getValue('toothFaceCode'))
			cAux+= UPPER(Substr(self:oEntity:getValue('toothFaceCode'),nI,1)) + "/"
		next nI

		aFaces:= StrTokArr2(cAux,"/")
		cAux := ""
		nI:=0
		
		For nI:=1 to Len(aFaces)
			If !aFaces[nI] $ cAux
				lRet	:= ExisTabTiss(aFaces[nI],"32")
				cAux += aFaces[nI]
			Else
				lRet:=.F.
			EndIf
			If !lRet	
				exit
			EndIf
		next nI

		
	EndIf 
	
	aFaces := nil

	oColBKR:destroy()
	FreeObj(oColBKR)
	oColBKR := nil

Return lRet
