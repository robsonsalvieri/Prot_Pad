#Include "PROTHEUS.CH" 

//----------------------------------------------------------
/*/{Protheus.doc} PLPtuJsPCad
Classe para montagem do JSON de Pré Cadastro do beneficiario baseado no PTU A1300

@author Gabriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
@Obs Aproveitamos a Integração TOTVS Saúde Planos x HealthMap para realizar a montagem dessa API.
/*/
//----------------------------------------------------------
Class PLPtuJsPCad From PLMapJson

    //Dados principais para pesquisa do Beneficiario
    Data cChave As String //Matricula completa
    Data cCodInt As String
    Data cCodEmp As String
    Data cMatric As String
    Data cTipReg As String
    Data cDigito As String
    Data lFindBenef As Boolean

    //Objetos os do Body do Json
    Data oDadosUnimed AS object
    Data oDadosContratante AS object
    Data oDadosPessoa AS object
    Data oDadosBeneficiario AS object
    Data oDadosPlano AS object
    Data aDadosAbrangencia AS Array
    Data aDadosCarencia As Array
    Data alistaBeneficiarios As Array
    
   
    Method New(cChave) Constructor
    Method AddListaBenef()
    Method SetDadosBenef()
    Method GetJson()
    Method MontaListaBenef()
    Method GetTitular(lContratante)
    Method GetPlano(cChvProduto)
    Method GetAbrang(cChvProduto, cChvBenef)
EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Gabriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method New(cChave) Class PLPtuJsPCad

    Default cChave := ''

    _Super:New()
     
    self:cChave := cChave
    self:cCodInt := Iif(!empty(cChave), Substr(cChave, 1, 4), '')
    self:cCodEmp := Iif(!empty(cChave), Substr(cChave, 5, 4), '')
    self:cMatric := Iif(!empty(cChave), Substr(cChave, 9, 6), '')
    self:cTipReg := Iif(!empty(cChave), Substr(cChave, 15, 2), '')
    self:cDigito := Iif(!empty(cChave), Substr(cChave, 17, 1), '')
    self:lFindBenef := .F.

    self:oDadosUnimed := JsonObject():New()
    self:oDadosContratante := JsonObject():New()
    self:oDadosPessoa := JsonObject():New()
    self:oDadosBeneficiario := JsonObject():New()
    self:oDadosPlano := JsonObject():New()
    self:aDadosAbrangencia := {}
    self:aDadosCarencia := {}
    self:alistaBeneficiarios := {}

    If !empty(cChave)
        self:SetDadosBenef()
        self:MontaListaBenef()
    EndIf

Return self


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosBenef
Monta a Lista de Beneficiarios para retornar ao Json

@author Ganriel J. Mucciolo
@since 18/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method AddListaBenef(cChave) Class PLPtuJsPCad
    Default cChave := ''

    self:cChave := cChave
    self:cCodInt := Iif(!empty(cChave), Substr(cChave, 1, 4), '')
    self:cCodEmp := Iif(!empty(cChave), Substr(cChave, 5, 4), '')
    self:cMatric := Iif(!empty(cChave), Substr(cChave, 9, 6), '')
    self:cTipReg := Iif(!empty(cChave), Substr(cChave, 15, 2), '')
    self:cDigito := Iif(!empty(cChave), Substr(cChave, 17, 1), '')

    self:oDadosUnimed := JsonObject():New()
    self:oDadosContratante := JsonObject():New()
    self:oDadosPessoa := JsonObject():New()
    self:oDadosBeneficiario := JsonObject():New()
    self:oDadosPlano := JsonObject():New()
    self:aDadosAbrangencia := {}
    self:aDadosCarencia := {}

    If !empty(cChave)
        self:SetDadosBenef()
        self:MontaListaBenef()
    EndIf
Return

//----------------------------------------------------------
/*/{Protheus.doc} SetDadosBenef
Faz a query dos atributos utilizados na montagem do JSON

@author Ganriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method SetDadosBenef() Class PLPtuJsPCad

    Local cQuery := ""
    Local cTipTitular := GetNewPar("MV_PLCDTIT", "T")
    Local cAliasTemp := GetNextAlias()
    Local cTipoBenef := ""
    Local lExisPETag := .F.
    Local nXCar := 0
    Local oDadosCarencia := JsonObject():New()

    If ExistBlock( "PL1300TAG" )
		lExisPETag := .T.
	EndIf 

    cQuery := " SELECT BTS.BTS_NOMUSR, BTS.BTS_NOMSOC, BTS.BTS_NRCRNA, BA1.BA1_TIPUSU, BA1.BA1_SEXO, BA1.BA1_DATNAS, BA1.BA1_EMAIL, BA1.BA1_GRAUPA, BA1.BA1_CPFUSR, BA1.BA1_DRGUSR, BA1.BA1_MATVID, BA1.BA1_SUBCON, BA1.BA1_CODINT, BA1.BA1_CODPLA, BA1.BA1_VERSAO, BA1.BA1_VIACAR, "
    cQuery += " BA1.BA1_DATINC, BA1.BA1_DATBLO, BA1.BA1_TIPTEL, BA1.BA1_DDD, BA1.BA1_TELEFO, BA1.BA1_ENDERE, BA1.BA1_BAIRRO, BA1.BA1_CEPUSR, BA1.BA1_CODMUN, BA1.BA1_RESFAM, BA1.BA1_DTVLCR, BA1.R_E_C_N_O_ BA1_REC, "
    cQuery += " BA1.BA1_MUNICI, BA1.BA1_ESTADO, BA1.BA1_NR_END, BA1.BA1_COMEND,  BA3.BA3_CODINT, BA3.BA3_MODPAG, BA3.BA3_CODPLA, BA3.BA3_VERSAO, BA3.BA3_TIPOUS, BG9.BG9_DESCRI, SA1.A1_CGC, "
    cQuery += " BQC.BQC_CODINT, BQC.BQC_CODEMP, BQC.BQC_NUMCON, BQC.BQC_VERCON, BQC.BQC_SUBCON, BQC.BQC_VERSUB, BQC.BQC_DESCRI, BQC.BQC_CNPJ "

    cQuery += " FROM "+RetSqlName('BA1')+" BA1 "
    //Inner com a BTS - Vidas
    cQuery += " INNER JOIN "+RetSqlName('BTS')+" BTS "
    cQuery += "      ON BTS.BTS_FILIAL = '" +xFilial("BTS")+ "' "
    cQuery += "     AND BTS.BTS_MATVID = BA1.BA1_MATVID "
    cQuery += "     AND BTS.D_E_L_E_T_ = ' ' "
    //Inner com a BA3 - Famílias Usuários 
    cQuery += " INNER JOIN "+RetSqlName('BA3')+" BA3 "
    cQuery += "      ON BA3.BA3_FILIAL = '" +xFilial("BA3")+ "' "
    cQuery += "     AND BA3.BA3_CODINT = BA1.BA1_CODINT "
    cQuery += "     AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
    cQuery += "     AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
    cQuery += "     AND BA3.D_E_L_E_T_ = ' ' "
    //Inner com a BG9 - Grupos Empresas
    cQuery += " INNER JOIN "+RetSqlName('BG9')+" BG9 "
    cQuery += "      ON BG9.BG9_FILIAL = '" +xFilial("BG9")+ "' "
    cQuery += "     AND BG9.BG9_CODIGO = BA1.BA1_CODEMP "
    cQuery += "     AND BG9.BG9_CODINT = BA1.BA1_CODINT "
    cQuery += "     AND BG9.D_E_L_E_T_ = ' ' "
    //Left com a BQC - Subcontrato 
    cQuery += " LEFT JOIN "+RetSqlName('BQC')+" BQC "
    cQuery += "      ON BQC.BQC_FILIAL = '" +xFilial("BQC")+ "'"
    cQuery += "     AND BQC.BQC_CODINT = BA1.BA1_CODINT "
    cQuery += "     AND BQC.BQC_CODEMP = BA1.BA1_CODEMP "
    cQuery += "     AND BQC.BQC_NUMCON = BA1.BA1_CONEMP "
    cQuery += "     AND BQC.BQC_VERCON = BA1.BA1_VERCON "
    cQuery += "     AND BQC.BQC_SUBCON = BA1.BA1_SUBCON "
    cQuery += "     AND BQC.BQC_VERSUB = BA1.BA1_VERSUB "
    cQuery += "     AND BQC.D_E_L_E_T_ = ' ' "       
    //Left com a SA1 - Clientes  
    cQuery += " LEFT JOIN "+RetSqlName('SA1')+" SA1 "
    cQuery += "      ON SA1.A1_FILIAL = '" +xFilial("SA1")+ "'"
    cQuery += "     AND SA1.A1_COD = BQC.BQC_CODCLI "
    cQuery += "     AND SA1.A1_LOJA = BQC.BQC_LOJA "
    cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "          
    //Clausula Where
    cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "
    cQuery += "   AND BA1.BA1_CODINT = '"+self:cCodInt+"'"
    cQuery += "   AND BA1.BA1_CODEMP = '"+self:cCodEmp+"'"
    cQuery += "   AND BA1.BA1_MATRIC = '"+self:cMatric+"'"
    cQuery += "   AND BA1.BA1_TIPREG = '"+self:cTipReg+"'"
    cQuery += "   AND BA1.BA1_DIGITO = '"+self:cDigito+"'"
    cQuery += "   AND BA1.D_E_L_E_T_ = ' ' "

    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)
    
    If !(cAliasTemp)->(Eof())
        //Tipo do beneficiario
        cTipoBenef :=  Alltrim((cAliasTemp)->BA1_TIPUSU)

        //dadosUnimed
        self:oDadosUnimed['codUnimed'] := self:SetAtributo(self:cCodInt)
    
        //dadosContratante
        If (cAliasTemp)->BA3_TIPOUS == "1" // Pessoa Física
            If cTipoBenef <> cTipTitular
                If empty(self:oDadosContratante['cpfCnpj']) .OR. empty(self:oDadosContratante['nomeContratante'])
                    self:GetTitular(.T.)
                EndIf
            Else
                self:oDadosContratante['cpfCnpj'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_CPFUSR))
                self:oDadosContratante['nomeContratante'] := self:SetAtributo(Alltrim((cAliasTemp)->BTS_NOMUSR))
            EndIf
        Else // Pessoa Jurídica
            self:oDadosContratante['cpfCnpj'] :=  self:SetAtributo(Alltrim(IIf(!empty((cAliasTemp)->BQC_CNPJ), (cAliasTemp)->BQC_CNPJ, (cAliasTemp)->A1_CGC)))
            // Ponto de Entrada 
			If lExisPETag	     
				cNmEmprComp := ExecBlock( "PL1300TAG", .F., .F., {"nm_empr_comp",BA1->(Recno())} )
				If !Empty(cNmEmprComp)
					self:oDadosContratante['nomeContratante'] :=  Padl(cNmEmprComp,40)
                Else
                    self:oDadosContratante['nomeContratante'] := self:SetAtributo(Alltrim(Padl((cAliasTemp)->BG9_DESCRI,40)))     
				EndIF
            Else
                self:oDadosContratante['nomeContratante'] := self:SetAtributo(Alltrim(Padl((cAliasTemp)->BG9_DESCRI,40))) 
			EndIf
        EndIf
   
        //dadosPessoa
        self:oDadosPessoa['nome'] := self:SetAtributo(Alltrim((cAliasTemp)->BTS_NOMUSR))
        self:oDadosPessoa['nomeSocial'] := self:SetAtributo(Alltrim((cAliasTemp)->BTS_NOMSOC))
        self:oDadosPessoa['genero'] := self:SetAtributo(IIf((cAliasTemp)->BA1_SEXO == "1", "M", "F"))
        self:oDadosPessoa['generoSocial'] := self:SetAtributo(IIF(!empty(self:oDadosPessoa['nomeSocial']),IIf((cAliasTemp)->BA1_SEXO == "1", "M", "F"), ''))
        self:oDadosPessoa['dtNascimento'] := self:SetAtributo((cAliasTemp)->BA1_DATNAS)
        self:oDadosPessoa['cpf'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_CPFUSR))
        self:oDadosPessoa['cns'] := self:SetAtributo(Alltrim((cAliasTemp)->BTS_NRCRNA))
       
        //dadosBeneficiario
        If cTipoBenef == cTipTitular
            self:oDadosBeneficiario['cdCarteiraTitular'] := self:SetAtributo(self:cChave)
        EndIf
        //Se nao for o Titular, vamos pegar a cdCarteiraTitular do metodo GetTitular
        If cTipoBenef <> cTipTitular 
            If empty(self:oDadosBeneficiario['cdCarteiraTitular'])
                self:GetTitular(.F.)
            EndIf
            self:oDadosBeneficiario['cdCarteiraDepende'] := self:SetAtributo(self:cChave)
        EndIf
        self:oDadosBeneficiario['dependencia'] :=  self:SetAtributo(Posicione("BRP", 1, xFilial("BRP")+Alltrim((cAliasTemp)->BA1_GRAUPA), "BRP_CODPTU"))
        self:oDadosBeneficiario['dataInclusao'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_DATINC))
        
        //dadosPlano
        //Verifica se tem o ponto de entrada
        If lExisPETag
			self:oDadosPlano['dtValidadeCartao'] := self:SetAtributo(ExecBlock( "PL1300TAG", .F., .F., {"dt_val_carteira",BA1->(Recno())} ))
            self:oDadosPlano['viaCartao'] := self:SetAtributo(ExecBlock( "PL1300TAG", .F., .F., {"cVIA_CARTAO",(cAliasTemp)->BA1_REC} ), 'N')
		EndIf
        If Empty(self:oDadosPlano['dtValidadeCartao'])
            self:oDadosPlano['dtValidadeCartao'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_DTVLCR))
        EndIF
        If Empty(self:oDadosPlano['viaCartao'])
            self:oDadosPlano['viaCartao'] := self:SetAtributo((cAliasTemp)->BA1_VIACAR, 'N')
        EndIF
        
        If Empty((cAliasTemp)->BA1_CODPLA) //Chave do produto
            self:GetPlano((cAliasTemp)->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO))
        Else
            self:GetPlano((cAliasTemp)->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO))
        EndIf
        
        //dadosAbrangencia
        If Empty((cAliasTemp)->BA1_CODPLA)  //Chave do produto
            self:aDadosAbrangencia := self:GetAbrang((cAliasTemp)->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO), self:cChave, (cAliasTemp)->BA1_REC)
        Else
            self:aDadosAbrangencia := self:GetAbrang((cAliasTemp)->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO), self:cChave, (cAliasTemp)->BA1_REC)
        EndIf

        //dadosCarencia
        aRetCarenc := PLSCLACAR(self:cCodInt,self:cChave)
        For nXCar:= 1 to Len(aRetCarenc[2])
            oDadosCarencia['tpCobertura'] := self:SetAtributo(aRetCarenc[2][nXCar][8], "N")
            oDadosCarencia['DtFimCarencia'] := self:SetAtributo(dtos(aRetCarenc[2][nXCar][3]))
            Aadd(self:aDadosCarencia, oDadosCarencia)
        Next

        self:lFindBenef := .T.
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return 

//----------------------------------------------------------
/*/{Protheus.doc} MontaListaBenef
Monta a lista de Beneficiarios que será enviada ao Json

@author Gabriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method MontaListaBenef() Class PLPtuJsPCad
    Local olistaBeneficiarios := JsonObject():New()

    If self:lFindBenef
        olistaBeneficiarios["dadosUnimed"] := self:oDadosUnimed
        olistaBeneficiarios["dadosContratante"] := self:oDadosContratante
        olistaBeneficiarios["dadosPessoa"] := self:oDadosPessoa
        olistaBeneficiarios["dadosBeneficiario"] := self:oDadosBeneficiario
        olistaBeneficiarios["dadosPlano"] := self:oDadosPlano
        olistaBeneficiarios["listaAbrangencias"] := self:aDadosAbrangencia
        olistaBeneficiarios["listaCarencias"] := self:aDadosCarencia
        
        Aadd(self:alistaBeneficiarios, olistaBeneficiarios)
    EndIf

Return

//----------------------------------------------------------
/*/{Protheus.doc} GetJson
Retorna o JSON referente ao Pedido

@author Gabriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method GetJson() Class PLPtuJsPCad

    Local oResponse := JsonObject():New()
    Local cMatricula := self:cCodInt + self:cCodEmp + self:cMatric + self:cTipReg + self:cDigito
    Local cJson := ""

    oResponse["message"]:= "Criar Beneficiario"
    oResponse["listaBeneficiarios"] := self:alistaBeneficiarios
    
    cJson := FWJsonSerialize(oResponse, .F., .F.)

    If ExistBlock("PLMPJSBE")
        cJson := ExecBlock("PLMPJSBE", .F., .F., {cMatricula, cJson})  
    EndIf

    FreeObj(oResponse)
    oResponse := Nil

Return cJson

//----------------------------------------------------------
/*/{Protheus.doc} GetTitular
Retorna os dados do titular da familia ou Responsavel Financeiro 
(Utilizado somente para os dependentes)

@author Gabriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method GetTitular(lContratante) Class PLPtuJsPCad

    Local lRet := .F.
    Local lTitular := .F.
    Local cQuery := ""
    Local cAliasTemp := ""
    Local cTipTitular := GetNewPar("MV_PLCDTIT", "T")
    Local cResFam := '1' //Reponsavel Familiar
    Default lContratante := .F.

    //Pega os dados dos Beneficiarios
    cAliasTemp := GetNextAlias()
    cQuery := "SELECT BA1.BA1_CPFUSR, BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO, BA1.BA1_NOMUSR, BA1.BA1_RESFAM, BA1.BA1_TIPUSU, BA1.BA1_DATBLO "
    cQuery += " FROM "+RetSqlName("BA1")+" BA1 "
    cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' " 
    cQuery += "   AND BA1.BA1_CODINT = '"+self:cCodInt+"'"
    cQuery += "   AND BA1.BA1_CODEMP = '"+self:cCodEmp+"'" 
    cQuery += "   AND BA1.BA1_MATRIC = '"+self:cMatric+"'" 
    cQuery += "   AND (BA1.BA1_TIPUSU = '"+cTipTitular+"' OR BA1.BA1_RESFAM = '"+cResFam+"')" 
    cQuery += "   AND BA1.D_E_L_E_T_ = ' '"
    
    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    //Vamos verificar se o Titular está bloqueado, se tiver, vamos pegar o Responsavel Financeiro
    While ! (cAliasTemp)->(EoF())
        //Verifica se é o titular e se não está bloqueado
        if ((cAliasTemp)->BA1_TIPUSU == cTipTitular .AND. empty((cAliasTemp)->BA1_DATBLO))
            self:oDadosBeneficiario['cdCarteiraTitular'] := self:SetAtributo((cAliasTemp)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
            if lContratante
                self:oDadosContratante['nomeContratante'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_NOMUSR))
                self:oDadosContratante['cpfCnpj'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_CPFUSR))
            EndIf
            lTitular := .T.
            lRet := .T.
        elseIf (lTitular == .F. .AND. (cAliasTemp)->BA1_RESFAM == cResFam)
            //Não é Titular mas é Responsavel Financeiro
            self:oDadosBeneficiario['cdCarteiraTitular'] := self:SetAtributo((cAliasTemp)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
            if lContratante
                self:oDadosContratante['nomeContratante'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_NOMUSR))
                self:oDadosContratante['cpfCnpj'] := self:SetAtributo(Alltrim((cAliasTemp)->BA1_CPFUSR))
            EndIf
            lRet := .T.
        EndIf 
        (cAliasTemp)->(DBSkip())
    EndDo
    
    (cAliasTemp)->(DbCloseArea())

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} GetPlano
Retorna os dados do plano

@author Gabriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method GetPlano(cChvProduto) Class PLPtuJsPCad

    Local lRet := .F.
    Local cQuery := ""
    Local cAliasTemp := ""
    Local cCodInt := Substr(cChvProduto, 1, 4)
    Local cCodPla := Substr(cChvProduto, 5, 4)
    Local cVersao := Substr(cChvProduto, 9, 3)
    Local cConcatQuery := IIF(AllTrim(TCGetDB()) $ "ORACLE|DB2|POSTGRES", '||', '+')

    //Abre um alias temporario
    cAliasTemp := GetNextAlias()
    cQuery := "SELECT BI3.BI3_DESCRI, BI3.BI3_CLAPLS, BI3.BI3_APOSRG, BI3.BI3_REDREF, BI3.BI3_REDEDI, BI3.BI3_SCPA, "
    cQuery += " BI3.BI3_LATEDI, BI3.BI3_SUSEP, BI3.BI3_MODPAG, BI3.BI3_CODINT, BI3.BI3_CODIGO, BI3.BI3_VERSAO, "
    cQuery += " BI3.BI3_CODACO, BI3.BI3_ABRANG, BIL.BIL_DATINI, BI4.BI4_CODEDI, BF7.BF7_CODEDI, BI6.BI6_CODEDI "
    cQuery += " FROM "+RetSqlName("BI3")+" BI3 "
    //Inner com a BIL - Versões de Produtos
    cQuery += " INNER JOIN "+RetSqlName('BIL')+" BIL "
    cQuery += "      ON BIL.BIL_FILIAL = '" +xFilial("BIL")+ "' "
    cQuery += "     AND BIL.BIL_CODIGO = BI3.BI3_CODINT"+cConcatQuery+"BI3.BI3_CODIGO "
    cQuery += "     AND BIL.BIL_VERSAO = BI3.BI3_VERSAO "
    cQuery += "     AND BIL.D_E_L_E_T_ = ' ' "
    //Inner com a BI4 - Tipos de Acomodação Internação
    cQuery += " INNER JOIN "+RetSqlName('BI4')+" BI4 "
    cQuery += "      ON BI4.BI4_FILIAL = '" +xFilial("BI4")+ "' "
    cQuery += "     AND BI4.BI4_CODACO = BI3.BI3_CODACO "
    cQuery += "     AND BI4.D_E_L_E_T_ = ' ' "
    //Inner com a BF7 - Abrangências
    cQuery += " INNER JOIN "+RetSqlName('BF7')+" BF7 "
    cQuery += "      ON BF7.BF7_FILIAL = '" +xFilial("BF7")+ "' "
    cQuery += "     AND BF7.BF7_CODORI = BI3.BI3_ABRANG "
    cQuery += "     AND BF7.D_E_L_E_T_ = ' ' "
    //LEFT com a BI6 - Segmentação 
    cQuery += " LEFT JOIN "+RetSqlName('BI6')+" BI6 "
    cQuery += "      ON BI6.BI6_FILIAL = '" +xFilial("BI6")+ "' "
    cQuery += "     AND BI6.BI6_CODSEG = BI3.BI3_CODSEG "
    cQuery += "     AND BI6.D_E_L_E_T_ = ' ' "
    //Clausula Where
    cQuery += " WHERE BI3.BI3_FILIAL = '"+xFilial("BI3")+"' "
    cQuery += "   AND BI3.BI3_CODINT = '"+cCodInt+"'"
    cQuery += "   AND BI3.BI3_CODIGO = '"+cCodPla+"'"
    cQuery += "   AND BI3.BI3_VERSAO = '"+cVersao+"'"
    cQuery += "   AND BI3.D_E_L_E_T_ = ' ' "

    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    If !(cAliasTemp)->(EoF())
        self:oDadosPlano['dtInicioVigencia'] := self:SetAtributo((cAliasTemp)->(BIL_DATINI)) //Data Inicio Vigencia
        self:oDadosPlano['tpAbrangencia'] := self:SetAtributo((cAliasTemp)->(BF7_CODEDI), 'N') //Tipo de abrangencia

        //Tipo de Acomodação
         Do Case
            Case ((cAliasTemp)->BI4_CODEDI == "1" .OR. (cAliasTemp)->BI4_CODEDI == "B") //Apartamento(Individual) 
                self:oDadosPlano['tpAcomodacao'] := self:SetAtributo(Padr("B",2))
            Case ((cAliasTemp)->BI4_CODEDI == "2" .OR. (cAliasTemp)->BI4_CODEDI == "A")//Enfermaria(Coletiva) 
                self:oDadosPlano['tpAcomodacao'] := self:SetAtributo(Padr("A",2))   
            Case ((cAliasTemp)->BI4_CODEDI $ "3/4" .OR. (cAliasTemp)->BI4_CODEDI == "C")//Não se aplica ou Ambulatorial 
                self:oDadosPlano['tpAcomodacao'] := self:SetAtributo(Padr("C",2))
            Otherwise
                self:oDadosPlano['tpAcomodacao'] := self:SetAtributo(Space(1))
        EndCase
        
        //Tipo de contratação
        Do Case
            Case (cAliasTemp)->BI3_CLAPLS == "1" //Individual
                self:oDadosPlano['tpContratacao'] := self:SetAtributo('2', 'N')
            Case (cAliasTemp)->BI3_CLAPLS == "2" //Coletivo Empresarial
                self:oDadosPlano['tpContratacao'] := self:SetAtributo('3', 'N')
            Case (cAliasTemp)->BI3_CLAPLS == "3" //Coletivo por Adesao
                self:oDadosPlano['tpContratacao'] := self:SetAtributo('4', 'N')
            Otherwise
                self:oDadosPlano['tpContratacao'] := self:SetAtributo(Space(1))
        EndCase

        //Tipo de Contrato
        self:oDadosPlano['tpContrato'] := self:SetAtributo(IIf(Alltrim((cAliasTemp)->BI3_MODPAG) == "1","P","C"))

        //Segmentação
        self:oDadosPlano['segmentacao'] := self:SetAtributo(Strzero(Val((cAliasTemp)->BI6_CODEDI),2))

        //Indicador do Registro do Plano na ANS
        Do Case
            Case (cAliasTemp)->BI3_APOSRG == "0" //Plano nao regulamentado
                self:oDadosPlano['idRegPlanoANS'] := self:SetAtributo(2)
            Case (cAliasTemp)->BI3_APOSRG == "1" //Plano regulamentado
                self:oDadosPlano['idRegPlanoANS'] := self:SetAtributo(1)
            Case (cAliasTemp)->BI3_APOSRG == "2" //Plano adaptado
                self:oDadosPlano['idRegPlanoANS'] := self:SetAtributo(3)
            Otherwise
                self:oDadosPlano['idRegPlanoANS'] := self:SetAtributo(Space(1)) 
        EndCase

        //Registro ANS
        If (cAliasTemp)->BI3_APOSRG == "1" // Regulamentado 
            self:oDadosPlano['registroANS'] := self:SetAtributo(Padr((cAliasTemp)->BI3_SUSEP,20))
        ElseIf (cAliasTemp)->BI3_APOSRG $ "0/2" // Não regulamentado ou Adaptado
            self:oDadosPlano['registroANS'] := self:SetAtributo(Padr((cAliasTemp)->BI3_SCPA,20))
        EndIf

        //Código da rede referenciada
        If !Empty(BI3->BI3_REDREF) .And. !(AllTrim(BI3->BI3_REDREF) == "1")
            self:oDadosPlano['cdRede'] := self:SetAtributo(Strzero(Val(Substr((cAliasTemp)->BI3_REDREF,1,4)),4))
        Else
            self:oDadosPlano['cdRede'] := self:SetAtributo(Strzero(Val(Substr((cAliasTemp)->BI3_REDEDI,1,4)),4))
        EndIf

        //Código do Local de Atendimento
        self:oDadosPlano['cdLcat'] := self:SetAtributo(Strzero(Val((cAliasTemp)->BI3_LATEDI),4), 'N')
        
        //Nome do Plano
        self:oDadosPlano['nomeProduto'] := self:SetAtributo(Substr((cAliasTemp)->BI3_DESCRI,1,60))

        lRet := .T.
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} GetAbrang
Retorna os dados da Abrangencia

@author Gabriel J. Mucciolo
@since 04/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method GetAbrang(cChvProduto, cChvBenef, cRecBenef) Class PLPtuJsPCad
    
    Local cQuery := ""
    Local cAliasTemp := ""
    Local lPL1300ABRA := .F.
    Local cCodInt := Substr(cChvProduto, 1, 4)
    Local cCodPla := Substr(cChvProduto, 5, 4)
    Local cVersao := Substr(cChvProduto, 9, 3)
    Local aAbrangPE := {}
    Local nX := 0
    Local aDadosAbrangencia := {}
    Local oDadosAbrangencia := JsonObject():New()


    //Verifica se tem o Ponto de Entrada
    If ExistBlock( "PL1300ABRA" )
		lPL1300ABRA := .T.
	EndIf

    //Abre um alias temporario
    cAliasTemp := GetNextAlias()
    cQuery := "SELECT BI3.BI3_DESCRI, BI3.BI3_ABRANG, BF7.BF7_CODEDI, BF7.BF7_CODORI, BI3.R_E_C_N_O_ BI3_REC, B9B.B9B_CODMUN, B9C.B9C_ESTADO"
    cQuery += " FROM "+RetSqlName("BI3")+" BI3 "
    //Inner com a BF7 - Abrangências
    cQuery += " INNER JOIN "+RetSqlName('BF7')+" BF7 "
    cQuery += "      ON BF7.BF7_FILIAL = '" +xFilial("BF7")+ "' "
    cQuery += "     AND BF7.BF7_CODORI = BI3.BI3_ABRANG "
    cQuery += "     AND BF7.D_E_L_E_T_ = ' ' "
    //Left com a B9B - Municipio
    cQuery += " LEFT JOIN "+RetSqlName('B9B')+" B9B "
    cQuery += "      ON B9B.B9B_FILIAL = '" +xFilial("B9B")+ "' "
    cQuery += "     AND B9B.B9B_CODORI = BF7.BF7_CODORI "
    cQuery += "     AND B9B.D_E_L_E_T_ = ' ' "
    //Left com a B9C - Estado
    cQuery += " LEFT JOIN "+RetSqlName('B9C')+" B9C "
    cQuery += "      ON B9C.B9C_FILIAL = '" +xFilial("B9C")+ "' "
    cQuery += "     AND B9C.B9C_CODORI = BF7.BF7_CODORI "
    cQuery += "     AND B9C.D_E_L_E_T_ = ' ' "
    //Clausula Where
    cQuery += " WHERE BI3.BI3_FILIAL = '"+xFilial("BI3")+"' "
    cQuery += "   AND BI3.BI3_CODINT = '"+cCodInt+"'"
    cQuery += "   AND BI3.BI3_CODIGO = '"+cCodPla+"'"
    cQuery += "   AND BI3.BI3_VERSAO = '"+cVersao+"'"
    cQuery += "   AND BI3.D_E_L_E_T_ = ' ' "

    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    While !(cAliasTemp)->(EoF())
        If !Empty((cAliasTemp)->BI3_ABRANG)
            If lPL1300ABRA // P.E - Faz o tratamento para o grupo do município e o grupo de estados (Caso o cliente utilize outras tabelas)						     
                aAbrangPE := ExecBlock( "PL1300ABRA", .F., .F., {(cAliasTemp)->BF7_CODEDI,(cAliasTemp)->BF7_CODORI,cRecBenef,(cAliasTemp)->BI3_REC} )
                If Len(aAbrangPE) > 0
                    For nX := 1 To Len(aAbrangPE)
                        oDadosAbrangencia['cdMunic'] := self:SetAtributo(IIF(!Empty(aAbrangPE[nX][2]),Strzero(Val(Alltrim(aAbrangPE[1][2])),7), Space(7))) //Município
                        oDadosAbrangencia['cdUF'] := self:SetAtributo(IIF(!Empty(aAbrangPE[nX][1]),aAbrangPE[1][1], Space(2))) //Estado
                        Aadd(aDadosAbrangencia, oDadosAbrangencia)
                    Next 
                EndIF
            Else
                oDadosAbrangencia['cdMunic'] := self:SetAtributo(iif(!empty((cAliasTemp)->B9B_CODMUN), Strzero(Val(Alltrim((cAliasTemp)->B9B_CODMUN))), Space(7))) 
                oDadosAbrangencia['cdUF'] := self:SetAtributo(iif(!empty((cAliasTemp)->B9C_ESTADO), Alltrim((cAliasTemp)->B9C_ESTADO), Space(2)))
                Aadd(aDadosAbrangencia, oDadosAbrangencia)
            EndIf
        EndIf
        (cAliasTemp)->(DBSkip())
    EndDo
    
    (cAliasTemp)->(DbCloseArea())

Return aDadosAbrangencia
