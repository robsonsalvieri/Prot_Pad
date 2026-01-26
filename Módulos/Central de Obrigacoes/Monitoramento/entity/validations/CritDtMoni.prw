#Include "Totvs.ch"

#DEFINE CNPJF '1'
#DEFINE CPF '2'
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCPFCNPJ
Descricao: 	Critica referente ao Campo.
				-> B9T_CPFCNP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0

@version 2.0
@author p.drivas
@since 19/06/2020
Inserido validação de se o conteudo do CPF ou CNPJ corresponde ao
tipo de identificador informado
/*/
//-------------------------------------------------------------------
Class CritDtMoni From CriticaB3F

  Data aDates
  Data FieldPos
  Data FieldValue

	Method New(cCampo) Constructor
  Method getDates()
  Method setDates()
  Method validFormat()
	Method Validar()

EndClass

Method New(cCampo) Class CritDtMoni
	_Super:New()
  If cCampo == "BKR_DTPROT"
    self:setCodCrit('M129')
  ElseIf cCampo == "BKR_DTINFT"
    self:setCodCrit('M120')
  ElseIf cCampo == "BKR_DTFIFT"
    self:setCodCrit("M121")
  ElseIf cCampo == "BKR_DATREA"
    self:setCodCrit("M124")
  ElseIf cCampo == "BKR_DATAUT"
    self:setCodCrit("M125")
  ElseIf cCampo == "BKR_DTPAGT"
    self:setCodCrit("M126")
  ElseIf cCampo == "BKR_DATSOL"
    self:setCodCrit("M127")
  ElseIf cCampo == "BKR_DTPRGU"
    self:setCodCrit("M128")
  Else
    self:setCodCrit('M120')
  EndIf
	self:setAlias(SubStr(cCampo,1,3))
  self:setCpoCrit(cCampo)
	self:setTpVld('1')
Return Self

Method getDates() Class CritDtMoni
return self:aDates

Method setDates() Class CritDtMoni
  local aDates := {}

  aAdd(aDates,{"BKR_DTPROT",Self:oEntity:getValue("collectionProtocolDate")})
  aAdd(aDates,{"BKR_DATSOL",Self:oEntity:getValue("requestDate")})
  aAdd(aDates,{"BKR_DTPAGT",Self:oEntity:getValue("paymentDt")})
  aAdd(aDates,{"BKR_DTPRGU",Self:oEntity:getValue("formProcDt")})
  aAdd(aDates,{"BKR_DTFIFT",Self:oEntity:getValue("invoicingEndDate")})
  aAdd(aDates,{"BKR_DATREA",Self:oEntity:getValue("executionDate")})
  aAdd(aDates,{"BKR_DATAUT",Self:oEntity:getValue("authorizationDate")})
  aAdd(aDates,{"BKR_DTINFT",Self:oEntity:getValue("invoicingStartDate")})
  self:aDates := aDates
return

Method Validar() Class CritDtMoni

  Local fValidado  := .T.
  local cEveAType  := Self:oEntity:getValue("aEventType")
  local cFatType   := Self:oEntity:getValue("invoicingTp")

  self:setDates()

  self:FieldPos   := AScan(self:aDates, {|x| AllTrim(x[1]) == self:cCpoCrit})
  self:FieldValue := self:aDates[self:FieldPos][2]

  If (self:cCpoCrit) == "BKR_DTPROT"
    If empty(self:FieldValue) ;
    .OR. STOD(self:FieldValue) > date() ;
    .OR. self:FieldValue < self:aDates[6][2]
      fValidado := .F.
      self:setCodCrit('M129')
      self:setMsgCrit("Data protocolo de cobrança inválida.")
      self:setSolCrit('A data não pode estar vazia e deve ser menor que a data do envio da guia e maior ou igual a Data de realização ou data inicial do período de atendimento.')
      self:setCodAns('1323')
      return fValidado
    EndIf
  ElseIf (self:cCpoCrit) == "BKR_DTINFT"
    if ((empty(self:FieldValue)) .AND. cEveAType == '3' .AND. (cFatType $ '1/4/P'));
    .OR. (!(empty(self:FieldValue)) .AND. cEveAType == '3' .AND. (cFatType $ '1/4/P') .AND. self:FieldValue != self:aDates[6][2]);
    .OR. STOD(self:FieldValue) > date()
      fValidado := .F.
      self:setCodCrit('M120')
      self:setMsgCrit("Data de início de faturamento inválida.")
      self:setSolCrit('Se o tipo de evento for igual a 3, e o tipo de faturamento for parcial 1 ou 4 ou P a data deve ser igual a data de internação')
      self:setCodAns('1323')
      return fValidado
    EndIf
  Elseif (self:cCpoCrit) == "BKR_DTFIFT"
    if (!(empty(self:FieldValue)) .AND. (STOD(self:FieldValue) > date() .OR. self:FieldValue < self:aDates[8][2] .OR. self:FieldValue < self:aDates[1][2] ));
    .OR. (empty(self:FieldValue) .AND. (cFatType $ '1/2/4/P'))
      fValidado := .F.
      self:setCodCrit('M121')
      self:setMsgCrit("Data de término de faturamento inválida.")
      self:setSolCrit('Deve ser preenchido para as cobranças de internação ou cobranças parciais. Deve ser posterior a data de inicio de faturamento. ')
      self:setCodAns('1323')
      return fValidado
    EndIf
  Elseif (self:cCpoCrit) == "BKR_DATREA"
    if empty(self:FieldValue);
    .OR. (STOD(self:FieldValue) > date() )
      fValidado := .F.
      self:setCodCrit('M124')
      self:setMsgCrit("Data de realização inválida.")
      self:setSolCrit('Data vazia ou tipo de evento diferente de 3 e faturamento diferente de 1 ou 4. ')
      self:setCodAns('1323')
      return fValidado
    EndIf
  Elseif (self:cCpoCrit) == "BKR_DATAUT"
    if empty(self:FieldValue) .AND. cEveAType == '3'
      fValidado := .F.
      self:setCodCrit('M125')
      self:setMsgCrit("Data de autorização inválida.")
      self:setSolCrit('Data deve ser preenchida quando tipo de evento igual a 3. ')
      self:setCodAns('1323')
      return fValidado
    EndIf
  Elseif (self:cCpoCrit) == "BKR_DTPAGT"
    if (!empty(self:FieldValue) .AND. (STOD(self:FieldValue) > date() .OR. self:FieldValue < self:aDates[1][2]))
      fValidado := .F.
      self:setCodCrit('M126')
      self:setMsgCrit("Data de pagamento inválida.")
      self:setSolCrit('Data deve ser preenchida com uma data anterior à data atual ou maior ou igual à data do protocolo da cobrança. ')
      self:setCodAns('1323')
      return fValidado
    EndIf
  Elseif (self:cCpoCrit) == "BKR_DATSOL"
    if empty(self:FieldValue) .AND. (cEveAType $ '2/3')
      fValidado := .F.
      self:setCodCrit('M127')
      self:setMsgCrit("Data de solicitação inválida.")
      self:setSolCrit('Data deve ser preenchida quando o tipo de guia for igual a 2 ou 3. ')
      self:setCodAns('1323')
      return fValidado
    EndIf
  Elseif (self:cCpoCrit) == "BKR_DTPRGU"
    if empty(self:FieldValue) .OR. STOD(self:FieldValue) > date()
      fValidado := .F.
      self:setCodCrit('M128')
      self:setMsgCrit("Data de processamento da guia inválida.")
      self:setSolCrit('Data vazia ou maior que a data atual. ')
      self:setCodAns('1323')
      return fValidado
    EndIf
  EndIf
  
  self:aDates := nil
  
Return fValidado

