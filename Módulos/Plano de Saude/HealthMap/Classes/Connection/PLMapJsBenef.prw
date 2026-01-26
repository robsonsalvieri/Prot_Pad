#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapJsBenef
Classe para montagem do JSON de Pedidos de Beneficiários

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
@Obs Utilização na Integração TOTVS Saúde Planos x HealthMap
/*/
//----------------------------------------------------------
Class PLMapJsBenef From PLMapJson
    
    Data cCodInt As String
    Data cCodEmp As String
    Data cMatric As String
    Data cTipReg As String
    Data cDigito As String
    Data lFindBenef As Boolean
    // Dados do Body do Json
    Data cCodTitular As String
    Data cGrauParen As String
    Data aProfSaude As Array
    Data cDtNascimento As String
    Data cEmail As String  
    Data cEndereco As String
    Data cBairro As String
    Data cCEPBenef As String
    Data cCodMunicipio As String
    Data cMunicipio As String
    Data cEstado As String
    Data aContratante As Array
    Data aCarteirinhas As Array
    Data cCodigoConvenio As String
    Data cModalidade As String
    Data cNomeBenef As String
    Data cNomeParen As String
    Data cSenha As String
    Data cSexo As String
    Data cStatus As String
    Data cTelCelular As String
    Data cTelComercial As String
    Data cTelResidencial As String
    Data cTipoBenef As String
    Data aDocumentos As Array
    Data cCPFBeneficiario As String
    Data cRGBeneficiario As String
    Data cCNSBeneficiario As String
    Data cMatVidaBenef As String
    Data cCodContratante As String
    Data cNomeContratante As String
    Data cModPagamento As String 
    
    Method New(cChave) Constructor
    Method SetDadosBenef()
    Method GetJson()
    Method GetCarteirinhas()
    Method GetContratante()
    Method GetDocumentos()
    Method GetCodTitular()
    
EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New(cChave) Class PLMapJsBenef

    _Super:New()

    self:cCodInt := Substr(cChave, 1, 4)
    self:cCodEmp := Substr(cChave, 5, 4)
    self:cMatric := Substr(cChave, 9, 6)
    self:cTipReg := Substr(cChave, 15, 2)
    self:cDigito := Substr(cChave, 17, 1)
    self:lFindBenef := .F.

    self:cCodTitular := ""
    self:cGrauParen := ""
    self:aProfSaude := {}
    self:cDtNascimento := ""
    self:cEmail := ""
    self:cEndereco := ""
    self:cBairro := ""
    self:cCEPBenef := ""
    self:cCodMunicipio := ""
    self:cMunicipio := ""
    self:cEstado := ""
    self:aContratante := {}
    self:aCarteirinhas := {}
    self:cCodigoConvenio := ""
    self:cModalidade := ""
    self:cNomeBenef := ""
    self:cNomeParen := ""
    self:cSenha := ""
    self:cSexo := ""
    self:cStatus := ""
    self:cTelCelular := ""
    self:cTelComercial := ""
    self:cTelResidencial := ""
    self:cTipoBenef := ""
    self:aDocumentos := {}
    self:cCPFBeneficiario := ""
    self:cRGBeneficiario := ""
    self:cCNSBeneficiario := ""
    self:cMatVidaBenef := ""
    self:cCodContratante := ""
    self:cNomeContratante := ""
    self:cModPagamento := ""

    self:SetDadosBenef()

Return self


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosBenef
Faz a query dos atributos utilizados na montagem do JSON

@author Rafael Soares da Silva
@since 05/08/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosBenef() Class PLMapJsBenef

    Local cQuery := ""
    Local cTipTitular := GetNewPar("MV_PLCDTIT", "T")
    Local nDiasBloqueio := GetNewPar("MV_PLDIABL", 0) //Tolerância em dias para o Bloqueio
    Local cTelefone := ""
    Local cTipoTelefone := ""
    Local aDadosTitular := {}
    Local cAliasTemp := GetNextAlias()
    
    cQuery := " SELECT BA1.BA1_TIPUSU, BA1.BA1_NOMUSR, BA1.BA1_SEXO, BA1.BA1_DATNAS, BA1.BA1_EMAIL, BA1.BA1_GRAUPA, BA1.BA1_CPFUSR, BA1.BA1_DRGUSR, BA1.BA1_MATVID, "
    cQuery += " BA1.BA1_NRCRNA, BA1.BA1_DATBLO, BA1.BA1_TIPTEL, BA1.BA1_DDD, BA1.BA1_TELEFO, BA1.BA1_ENDERE, BA1.BA1_BAIRRO, BA1.BA1_CEPUSR, BA1.BA1_CODMUN, "
    cQuery += " BA1.BA1_MUNICI, BA1.BA1_ESTADO, BA1.BA1_NR_END, BA1.BA1_COMEND, BA3.BA3_MODPAG, BA3.BA3_CODPLA, BA3.BA3_VERSAO, BA3.BA3_TIPOUS, "
    cQuery += " BQC.BQC_CODINT, BQC.BQC_CODEMP, BQC.BQC_NUMCON, BQC.BQC_VERCON, BQC.BQC_SUBCON, BQC.BQC_VERSUB, BQC.BQC_DESCRI "

    cQuery += " FROM "+RetSqlName('BA1')+" BA1 "

    cQuery += " INNER JOIN "+RetSqlName('BA3')+" BA3 "
    cQuery += "      ON BA3.BA3_FILIAL = '" +xFilial("BA3")+ "' "
    cQuery += "     AND BA3.BA3_CODINT = BA1.BA1_CODINT "
    cQuery += "     AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
    cQuery += "     AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
    cQuery += "     AND BA3.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN "+RetSqlName('BQC')+" BQC "
    cQuery += "      ON BQC.BQC_FILIAL = '" +xFilial("BQC")+ "'"
    cQuery += "     AND BQC.BQC_CODINT = BA1.BA1_CODINT "
    cQuery += "     AND BQC.BQC_CODEMP = BA1.BA1_CODEMP "
    cQuery += "     AND BQC.BQC_NUMCON = BA1.BA1_CONEMP "
    cQuery += "     AND BQC.BQC_VERCON = BA1.BA1_VERCON "
    cQuery += "     AND BQC.BQC_SUBCON = BA1.BA1_SUBCON "
    cQuery += "     AND BQC.BQC_VERSUB = BA1.BA1_VERSUB "
    cQuery += "     AND BQC.D_E_L_E_T_ = ' ' "                                                                                       

    cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "
    cQuery += "   AND BA1.BA1_CODINT = '"+self:cCodInt+"'"
    cQuery += "   AND BA1.BA1_CODEMP = '"+self:cCodEmp+"'"
    cQuery += "   AND BA1.BA1_MATRIC = '"+self:cMatric+"'"
    cQuery += "   AND BA1.BA1_TIPREG = '"+self:cTipReg+"'"
    cQuery += "   AND BA1.BA1_DIGITO = '"+self:cDigito+"'"
    cQuery += "   AND BA1.D_E_L_E_T_ = ' ' "
        
    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)
    
    If !(cAliasTemp)->(Eof())

        self:cTipoBenef :=  Alltrim((cAliasTemp)->BA1_TIPUSU)
        self:cNomeBenef :=  Alltrim((cAliasTemp)->BA1_NOMUSR)
        self:cSexo :=  IIf((cAliasTemp)->BA1_SEXO == "1", "M", "F")
        self:cDtNascimento := Substr((cAliasTemp)->BA1_DATNAS, 7, 2)+"/"+Substr((cAliasTemp)->BA1_DATNAS, 5, 2)+"/"+Substr((cAliasTemp)->BA1_DATNAS, 1, 4)
        self:cEmail :=  Alltrim((cAliasTemp)->BA1_EMAIL)
        self:cSenha :=  ""
        self:cCPFBeneficiario := Alltrim((cAliasTemp)->BA1_CPFUSR)
        self:cRGBeneficiario := Alltrim((cAliasTemp)->BA1_DRGUSR)
        self:cCNSBeneficiario := Alltrim((cAliasTemp)->BA1_NRCRNA)
        self:cMatVidaBenef := Alltrim((cAliasTemp)->BA1_MATVID)
        
        cTipoTelefone := Alltrim((cAliasTemp)->BA1_TIPTEL)
        cTelefone := Alltrim((cAliasTemp)->BA1_DDD) + Alltrim((cAliasTemp)->BA1_TELEFO)
        Do Case 
            Case cTipoTelefone == "1"
                self:cTelResidencial := cTelefone

            Case cTipoTelefone == "2"
                self:cTelComercial := cTelefone

            Otherwise  
                self:cTelCelular := cTelefone
        EndCase
    
        self:cEndereco := Alltrim((cAliasTemp)->BA1_ENDERE)
        self:cEndereco += IIF(Empty((cAliasTemp)->BA1_NR_END), "", ", "+Alltrim((cAliasTemp)->BA1_NR_END))
        self:cEndereco += IIF(Empty((cAliasTemp)->BA1_COMEND), "", ", "+Alltrim((cAliasTemp)->BA1_COMEND))
        self:cBairro := Alltrim((cAliasTemp)->BA1_BAIRRO)
        self:cCEPBenef := Alltrim((cAliasTemp)->BA1_CEPUSR)
        self:cCodMunicipio := Alltrim((cAliasTemp)->BA1_CODMUN)
        self:cMunicipio := Alltrim((cAliasTemp)->BA1_MUNICI)
        self:cEstado :=  Alltrim((cAliasTemp)->BA1_ESTADO)

        // Regras para o envio dos Dependentes
        If self:cTipoBenef <> cTipTitular
            aDadosTitular := self:GetCodTitular()
            self:cCodTitular := aDadosTitular[1]
            self:cNomeParen := Posicione("BRP", 1, xFilial("BRP")+Alltrim((cAliasTemp)->BA1_GRAUPA), "BRP_DESCRI")
            self:cGrauParen :=  cValToChar(Val(self:cGrauParen))
        EndIf

        self:cModPagamento :=  Alltrim((cAliasTemp)->BA3_MODPAG)

        If (cAliasTemp)->BA3_TIPOUS == "1" // Pessoa Física
            If Len(aDadosTitular) == 0
                aDadosTitular := self:GetCodTitular()
            EndIf
            self:cCodContratante :=  aDadosTitular[1]
            self:cNomeContratante :=  aDadosTitular[2]
        Else // Pessoa Jurídica
            self:cCodContratante :=  Alltrim((cAliasTemp)->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB))
            self:cNomeContratante :=  Alltrim((cAliasTemp)->BQC_DESCRI)      
        EndIf
   
        self:cModalidade := "H"
        If !Empty((cAliasTemp)->BA1_DATBLO) .And. (StoD((cAliasTemp)->BA1_DATBLO) + nDiasBloqueio) <= dDataBase
            self:cStatus := "I" // Inativo
        Else
            self:cStatus := "A" // Ativo
        EndIf

        self:cCodigoConvenio := Alltrim((cAliasTemp)->(BA3_CODPLA+BA3_VERSAO))
        self:aContratante := self:GetContratante()
        self:aCarteirinhas := self:GetCarteirinhas()
        self:aDocumentos := self:GetDocumentos() 

        self:lFindBenef := .T.
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetJson
Retorna o JSON referente ao Pedido

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetJson() Class PLMapJsBenef

    Local oResponse := JsonObject():New()
    Local cMatricula := self:cCodInt + self:cCodEmp + self:cMatric + self:cTipReg + self:cDigito
    Local cJson := ""

    If self:lFindBenef

        oResponse["codigoExterno"] := self:SetAtributo(cMatricula)
        oResponse["codigoExternoEmpresa"] := self:SetAtributo(self:cCodEmp)
        oResponse["codigoExternoGestor"] := self:SetAtributo("")
        oResponse["codigoExternoTitular"] := self:SetAtributo(self:cCodTitular)
        oResponse["codigoParentesco"] := self:SetAtributo(self:cGrauParen)
        oResponse["codigosProfSaudeRef"] := self:aProfSaude
        oResponse["dataNascimento"] := self:SetAtributo(self:cDtNascimento, "D")
        oResponse["docIdentificacao"] := self:SetAtributo("")
        oResponse["email"] := self:SetAtributo(self:cEmail)
        oResponse["enderecoBairro"] := self:SetAtributo(self:cBairro)
        oResponse["enderecoCep"] := self:SetAtributo(self:cCEPBenef)
        oResponse["enderecoCodigoIbgeCidade"] := self:SetAtributo(self:cCodMunicipio)
        oResponse["enderecoDescricao"] := self:SetAtributo(self:cEndereco) 
        oResponse["enderecoNomeCidade"] := self:SetAtributo(self:cMunicipio)
        oResponse["enderecoUf"] := self:SetAtributo(self:cEstado)
        oResponse["listaCarteirinhas"] := self:aCarteirinhas
        oResponse["listaContratante"] := self:aContratante 
        oResponse["login"] := self:SetAtributo(cMatricula)
        oResponse["modalidade"] := self:SetAtributo(self:cModalidade)
        oResponse["nome"] := self:SetAtributo(self:cNomeBenef)
        oResponse["nomeParentesco"] := self:SetAtributo(self:cNomeParen)
        oResponse["senha"] := self:SetAtributo(self:cSenha) 
        oResponse["sexo"] := self:SetAtributo(self:cSexo)
        oResponse["status"] := self:SetAtributo(self:cStatus) 
        oResponse["telCelular"] := self:SetAtributo(self:cTelCelular) 
        oResponse["telComercial"] := self:SetAtributo(self:cTelComercial) 
        oResponse["telResidencial"] := self:SetAtributo(self:cTelResidencial) 
        oResponse["titularidade"] := self:SetAtributo(self:cTipoBenef) 
        oResponse["listaDocumentos"] := self:aDocumentos 

        cJson := FWJsonSerialize(oResponse, .F., .F.)

        If ExistBlock("PLMPJSBE")
			cJson := ExecBlock("PLMPJSBE", .F., .F., {cMatricula, cJson})  
        EndIf

    EndIf

    FreeObj(oResponse)
    oResponse := Nil

Return cJson


//----------------------------------------------------------
/*/{Protheus.doc} GetCarteirinhas
Monta array para os dados da Carteirinha do Beneficiário

@author Rafael Soares da Silva
@since 20/08/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetCarteirinhas() Class PLMapJsBenef

    Local oCarteirinhas := Nil
    Local aCarteirinhas := {}
    Local cQuery := ""
    Local cDataValidade := ""
    Local lCartaoVirtual := GetNewPar("MV_PLCTVIR", .F.)
    Local cDataVirtual := GetNewPar("MV_PLDTVIR", "01/01/2100")
    Local cAliasTemp := GetNextAlias()

    If lCartaoVirtual
        oCarteirinhas := JsonObject():New()
        oCarteirinhas["codigoConvenio"] := self:cCodigoConvenio
        oCarteirinhas["dataValidade"] := cDataVirtual
        oCarteirinhas["numeroCarteira"] := self:cCodInt+self:cCodEmp+self:cMatric+self:cTipReg+self:cDigito

        aAdd(aCarteirinhas, oCarteirinhas)
        FreeObj(oCarteirinhas)
        oCarteirinhas := NIL
    Else
        cQuery := "SELECT BED.BED_DATVAL FROM "+RetSqlName("BED")+ " BED "
        cQuery += " WHERE BED.BED_FILIAL = '"+xFilial("BED")+"' "
        cQuery += "   AND BED.BED_CODINT = '"+self:cCodInt+"' "
        cQuery += "   AND BED.BED_CODEMP = '"+self:cCodEmp+"' "
        cQuery += "   AND BED.BED_MATRIC = '"+self:cMatric+"' " 
        cQuery += "   AND BED.BED_TIPREG = '"+self:cTipReg+"' "
        cQuery += "   AND BED.BED_DIGITO = '"+self:cDigito+"' "
        cQuery += "   AND BED.D_E_L_E_T_ = ' '"
        
        DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

        While ! (cAliasTemp)->(EoF())

            cDataValidade := Substr((cAliasTemp)->BED_DATVAL, 7, 2)+"/"+Substr((cAliasTemp)->BED_DATVAL, 5, 2)+"/"+Substr((cAliasTemp)->BED_DATVAL, 1, 4)

            oCarteirinhas := JsonObject():New()
            oCarteirinhas["codigoConvenio"] := self:cCodigoConvenio
            oCarteirinhas["dataValidade"] := self:SetAtributo(cDataValidade, "D")
            oCarteirinhas["numeroCarteira"] := self:cCodInt+self:cCodEmp+self:cMatric+self:cTipReg+self:cDigito

            aAdd(aCarteirinhas, oCarteirinhas)
            FreeObj(oCarteirinhas)
            oCarteirinhas := NIL

            (cAliasTemp)->(DBSkip())
        EndDo
        
        (cAliasTemp)->(DbCloseArea())
    EndIf

Return aCarteirinhas


//----------------------------------------------------------
/*/{Protheus.doc} GetContratante
Monta array para os dados do Contratante do Beneficiário

@author Rafael Soares da Silva
@since 20/08/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetContratante() Class PLMapJsBenef

    Local oContratante := JsonObject():New()
    Local aContratante := {}

    oContratante["codigoContratante"] := self:SetAtributo(self:cCodContratante)
    oContratante["codigoModalidadePagamento"] := self:SetAtributo(self:cModPagamento)
    oContratante["nomeContratante"] := self:SetAtributo(self:cNomeContratante)
    
    aAdd(aContratante,oContratante)

    FreeObj(oContratante)
    oContratante := Nil

Return aContratante


//----------------------------------------------------------
/*/{Protheus.doc} GetDocumentos
Retorna os documentos obrigatório do Beneficiário

@author Rafael Soares da Silva
@since 20/08/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetDocumentos() Class PLMapJsBenef

    Local oIdentificacao := Nil
    Local oCPF := Nil
    Local oRG := Nil
    Local oCNS := Nil
    Local oMatVida := Nil
    Local aDocumentos := {}

    If !Empty(self:cCPFBeneficiario)
        oCPF := JsonObject():New()
        oCPF["codigoDocumento"] := "1" 
        oCPF["numeroDocumento"] := self:cCPFBeneficiario
        
        aAdd(aDocumentos, oCPF)
        FreeObj(oCPF)
        oCPF := NIL
    EndIf

    If !Empty(self:cRGBeneficiario)
        oRG := JsonObject():New()
        oRG["codigoDocumento"] := "2" 
        oRG["numeroDocumento"] := self:cRGBeneficiario

        aAdd(aDocumentos, oRG)
        FreeObj(oRG)
        oRG := NIL
    EndIf

    If !Empty(self:cCNSBeneficiario)
        oCNS := JsonObject():New()
        oCNS["codigoDocumento"] := "3" 
        oCNS["numeroDocumento"] := self:cCNSBeneficiario

        aAdd(aDocumentos, oCNS)
        FreeObj(oCNS)
        oCNS := NIL
    EndIf

    oIdentificacao := JsonObject():New()
    oIdentificacao["codigoDocumento"] := "4" 
    oIdentificacao["numeroDocumento"] := self:cCodInt+self:cCodEmp+self:cMatric+self:cTipReg+self:cDigito

    aAdd(aDocumentos, oIdentificacao)
    FreeObj(oIdentificacao)
    oIdentificacao := NIL

    oMatVida := JsonObject():New()
    oMatVida["codigoDocumento"] := "5" 
    oMatVida["numeroDocumento"] := self:cMatVidaBenef

    aAdd(aDocumentos, oMatVida)
    FreeObj(oMatVida)
    oMatVida := NIL

Return aDocumentos


//----------------------------------------------------------
/*/{Protheus.doc} GetCodTitular
Retorna a chave completa do titular da familia (Utilizado 
somente para os dependentes)

@author Vinicius Queiros Teixeira
@since 21/09/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetCodTitular() Class PLMapJsBenef

    Local cCodTitular := ""
    Local cNomeTitular := ""
    Local cQuery := ""
    Local cAliasTemp := ""
    Local cTipTitular := GetNewPar("MV_PLCDTIT", "T")

    cAliasTemp := GetNextAlias()
    cQuery := "SELECT BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO, BA1.BA1_NOMUSR "
    cQuery += " FROM "+RetSqlName("BA1")+" BA1 "
    cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' " 
    cQuery += "   AND BA1.BA1_CODINT = '"+self:cCodInt+"'"
    cQuery += "   AND BA1.BA1_CODEMP = '"+self:cCodEmp+"'" 
    cQuery += "   AND BA1.BA1_MATRIC = '"+self:cMatric+"'" 
    cQuery += "   AND BA1.BA1_TIPUSU = '"+cTipTitular+"'" 
    cQuery += "   AND BA1.D_E_L_E_T_ = ' '"
   
    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    If !(cAliasTemp)->(EoF())
        cCodTitular := (cAliasTemp)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
        cNomeTitular := Alltrim((cAliasTemp)->BA1_NOMUSR)
    EndIf
    
    (cAliasTemp)->(DbCloseArea())

Return {cCodTitular, cNomeTitular}