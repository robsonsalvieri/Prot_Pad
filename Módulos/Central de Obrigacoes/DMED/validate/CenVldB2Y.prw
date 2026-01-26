#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB2Y from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB2Y
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB2Y
    Local lValid     := .T.

    self:cMsg := ''

    lValid := !Empty(oEntity:getValue("expenseKey")) .And. Len(oEntity:getValue("expenseKey"))<=40
    If !lValid
        self:cMsg += "A Chave (expenseKey) deve ser informada, contendo de 1 a 40 caracteres. "
    Endif

    lValid := !Empty(oEntity:getValue("ssnHolder"))
    If !lValid
        self:cMsg += "CPF do Títular não está preeenchido. "
    Endif

    lValid := !Empty(oEntity:getValue("period"))
    If !lValid
        self:cMsg += "Preencha o campo period, com Ano/Mês da Despesa ou Reembolso. "
    Endif

    lValid := !Empty(oEntity:getValue("exclusionId"))
    If !lValid
        self:cMsg += "Preencha o campo exclusionId, sendo 1 para excluir a movimentação e 0 para Incluir. "
    Endif

    If ValType(oEntity:getValue("dependentEnrollment"))=="C" .And. !Empty(oEntity:getValue("dependentEnrollment"))
        If Empty(oEntity:getValue("dependentName"))
            lValid :=.F.
            self:cMsg += "Nome do dependente deve ser informado. "
        Endif
    Endif

    If self:valOpe(oEntity:getValue("healthInsurerCode")) .And. !Empty(oEntity:getValue("titleHolderEnrollment"))
        lValid :=.T.
    Else

        lValid    := self:valOpe(oEntity:getValue("healthInsurerCode"))
        If !lValid
            self:cMsg += "Operadora não Cadastrada. "
        Endif

    Endif

    If lValid .and. !Empty(oEntity:getValue("dependentName"))

        If ValType(oEntity:getValue("dependentSsn"))=="C" .And. !Empty(oEntity:getValue("dependentSsn"))
            lValid:=.T.
        Else
            If ValType(oEntity:getValue("dependentBirthDate"))<>"C" .Or. Empty(oEntity:getValue("dependentBirthDate"))
                lValid:=.F.
                self:cMsg += "Campo CPF do Beneficiário ou Data de Nascimento deve ser preenchido. "
            Endif
        Endif
    Endif

    If !Empty(self:cMsg)
        lValid:=.F.
    Endif

Return lValid