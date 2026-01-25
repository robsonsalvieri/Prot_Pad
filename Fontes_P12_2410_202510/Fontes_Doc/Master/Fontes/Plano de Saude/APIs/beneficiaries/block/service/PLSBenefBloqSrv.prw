#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLSBENEFBLOQSRV.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBenefBloqSrv
Classe para gravar a solicitação de bloqueio dos beneficiários pela
RN 402

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------- 
Class PLSBenefBloqSrv

    Data cMatriculaSolicitante As String
    Data lBloqFamilia As Boolean
    Data aBloqBeneficiarios As Array
    Data lSolicitanteTitular As Boolean
    Data cOperadoraSolicitante As String
    Data cEmpresaSolicitante As String
    Data cFamiliaSolicitante As String
    Data cProtocoloGerado As String
    Data oError As Object
    Data oResult As Object
    Data nStatus As String
    Data lSuccess As Boolean
    
    Method New() CONSTRUCTOR
    Method AddProtocolBloq(cMatriculaSolicitante, lBloqFamilia, aBloqBeneficiarios)
    Method ValidRequest(cTipo) 
    Method ValidBeneficiario(cMatricula, lSolicitante, cSolicMatricula)
    Method GetAllBeneficiarios()
    Method GetProtocolo(cMatricula)
    Method GetMultaFidelidade(cMatricula)
    Method GravaProtocol()
    Method RetProtocolBloq()
    Method SetError(nStatus, cCode, cMessage, cDetailedMessage)
    Method SetResult(cMessage)
    Method GetError()
    Method GetResult()
    Method GetStatusCode()
    Method SetAtributo()
    
EndCLass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method New() Class PLSBenefBloqSrv

    Self:oError := JsonObject():new()
    Self:oResult := JsonObject():new()
    Self:nStatus := 200
    Self:lSuccess := .T.
    Self:cMatriculaSolicitante := ""
    Self:lBloqFamilia := .F.
    Self:aBloqBeneficiarios := {}
    Self:lSolicitanteTitular := .F.
    Self:cOperadoraSolicitante := ""
    Self:cEmpresaSolicitante := ""
    Self:cFamiliaSolicitante := ""
    Self:cProtocoloGerado := ""
    
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} AddProtocolBloq
Adiciona um novo protocolo na Rotina de Cancelamento de Planos (PLSA99B)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method AddProtocolBloq(cMatriculaSolicitante, lBloqFamilia, aBloqBeneficiarios) Class PLSBenefBloqSrv

    Default cMatriculaSolicitante := ""
    Default lBloqFamilia := .F.
    Default aBloqBeneficiarios := {}

    Self:cMatriculaSolicitante := cMatriculaSolicitante
    Self:lBloqFamilia := lBloqFamilia
    Self:aBloqBeneficiarios := aBloqBeneficiarios

    If Self:ValidRequest()
        If Self:GravaProtocol()
            Self:RetProtocolBloq(cMatriculaSolicitante)
        EndIf
    EndIf

Return self:lSuccess


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidRequest
Valida os dados da requisição

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method ValidRequest() Class PLSBenefBloqSrv

    Local nX := 0
   
    If Len(Self:cMatriculaSolicitante) == 17

        Self:ValidBeneficiario(Self:cMatriculaSolicitante, .T.)

        If Self:lSuccess

            If Self:lBloqFamilia .And. Self:lSolicitanteTitular
                Self:aBloqBeneficiarios := Self:GetAllBeneficiarios()
            EndIf

            If Len(Self:aBloqBeneficiarios) > 1

                For nX := 2 To Len(Self:aBloqBeneficiarios)

                    If Len(Self:aBloqBeneficiarios[nX]) == 17
                        Self:ValidBeneficiario(Self:aBloqBeneficiarios[nX], .F., Self:cMatriculaSolicitante)
                    Else
                        Self:SetError(400, "BL02", STR0003+Self:aBloqBeneficiarios[nX]+STR0004, STR0005+"BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO") // "Matrícula ";" inválida.";"Matrícula deve ter o tamanho de 17 caracteres: "
                        Exit
                    EndIf

                Next nX

            EndIf
        EndIf
    Else
        Self:SetError(400, "BL02", STR0003+Self:cMatriculaSolicitante+STR0004, STR0005+"BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO") // "Matrícula ";" inválida.";"Matrícula deve ter o tamanho de 17 caracteres: "    
    EndIf

Return Self:lSuccess


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidBeneficiario
Valida os dados de cada beneficiário solicitado para bloqueio

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method ValidBeneficiario(cMatricula, lSolicitante, cSolicMatricula) Class PLSBenefBloqSrv

    Local cTipoTitular := GetNewPar("MV_PLCDTIT", "T")

    Default cMatricula := ""
    Default lSolicitante := .F.
    Default cSolicMatricula := ""

    BA1->(DbSetOrder(2))
    If BA1->(MsSeek(xFilial("BA1")+cMatricula))

        If lSolicitante .And. BA1->BA1_TIPUSU == cTipoTitular
            Self:lSolicitanteTitular := .T.
            Self:cOperadoraSolicitante := BA1->BA1_CODINT
            Self:cEmpresaSolicitante := BA1->BA1_CODEMP
            Self:cFamiliaSolicitante := BA1->BA1_MATRIC
        EndIf

        Do Case
            Case lSolicitante .And. BA1->BA1_TIPUSU <> cTipoTitular .And. Calc_Idade(dDataBase, BA1->BA1_DATNAS) < 18
			    Self:SetError(400, "BL04", STR0008+cMatricula+STR0009, STR0010) // "Beneficiário dependente ";" deve ser de maior para realizar a solicitação.";"Calculo da idade do beneficiário realizada pelo campo BA1_DATNAS"
            
            Case lSolicitante .And. BA1->BA1_TIPUSU <> cTipoTitular .And. (Len(Self:aBloqBeneficiarios) > 1 .Or. Self:lBloqFamilia)
                Self:SetError(400, "BL05", STR0008+cMatricula+STR0011, STR0012) // "Beneficiário dependente ";" só pode realizar a solicitação para ele mesmo.";"Informado o atributo 'beneficiaries' no body da requisição."
                
            Case !Empty(BA1->BA1_MOTBLO)
                Self:SetError(400, "BL06", STR0013+cMatricula+STR0014, STR0015) // "Beneficiário ";" já está bloqueado.";"Campo BA1_MOTBLO do beneficiário já preenchido."

            Case Len(Self:GetProtocolo(cMatricula)) > 0
                Self:SetError(400, "BL07", STR0013+cMatricula+STR0016, STR0017) // "Beneficiário ";" já tem uma solicitação pendente.";"Beneficiário com solicitação pendente na tabela B5J com o B5J_STATUS igual a 0."

            Case !lSolicitante .And. Substr(cMatricula, 1, 14) <> Substr(cSolicMatricula, 1, 14)
                Self:SetError(400, "BL08", STR0013+cMatricula+STR0018, STR0019) // "Beneficiário ";" solicitado é de uma família diferente do solicitante.";"Campos BA1_CODINT, BA1_CODEMP, BA1_MATRIC diferente dos beneficiarios."

            Case BA1->BA1_CODEMP == GetNewPar("MV_PLSGEIN", "0050")
                Self:SetError(400, "BL09", STR0020, STR0021) // "A solicitação de bloqueio não pode ser realizada para beneficiários de intercâmbio.";"Campo BA1_CODEMP do beneficiário é igual a empresa informada no parâmetro MV_PLSGEIN"
        EndCase
    Else
        Self:SetError(400, "BL03", STR0003+cMatricula+STR0006, STR0007+"BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO") // "Matrícula ";" não foi encontrada.";"Matricula não encontrada na tabela BA1 pela chave: "
    EndIf

Return Self:lSuccess



//-------------------------------------------------------------------
/*/{Protheus.doc} GetProtocolo
Retorna o protocolo de solicitação de bloqueio do beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method GetProtocolo(cMatricula) Class PLSBenefBloqSrv

    Local lExist := .F.
    Local cAliasTemp := GetNextAlias()
    Local cStatus := ""
    Local cProtocolo := ""
    Local cDataSolic := ""
    Local cOrigem := ""
    Local oDados := JsonObject():New()
    Local aDados := {}

    Default cMatricula := ""


    BeginSQL Alias cAliasTemp
        SELECT B5J.B5J_STATUS, B5J.B5J_DATSOL, B5J.B5J_HORSOL, B5J.B5J_ORISOL, B5J.B5J_PROTOC FROM %Table:B5K% B5K 
            INNER JOIN  %Table:B5J% B5J 
             ON B5J.B5J_FILIAL = %XFilial:B5J% 
            AND B5J.B5J_CODIGO = B5K.B5K_CODIGO
            AND B5J.%notDel%

          WHERE B5K.B5K_FILIAL = %XFilial:B5K% 
            AND B5K.B5K_MATUSU = %exp:cMatricula% 
            AND B5K.%notDel%
    EndSQL

    While !(cAliasTemp)->(EoF())

        If (cAliasTemp)->B5J_STATUS == "0"
            lExist := .T.
            cStatus :=  (cAliasTemp)->B5J_STATUS
            cProtocolo := (cAliasTemp)->B5J_PROTOC
            cDataSolic := (cAliasTemp)->B5J_DATSOL
            cOrigem := (cAliasTemp)->B5J_ORISOL

            Exit
        EndIf

        (cAliasTemp)->(DbSkip())
    EndDo

    (cAliasTemp)->(DbCloseArea())

    If lExist
        oDados["requestDate"] :=  Self:SetAtributo(cDataSolic, "Date")
        oDados["requestOrigin"] :=  Self:SetAtributo(cOrigem, "String")
        oDados["status"] :=  Self:SetAtributo(cStatus, "String")
        oDados["protocol"] :=  Self:SetAtributo(cProtocolo, "String")

        aAdd(aDados, oDados)
    EndIf

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProtocolo
Retorna o valor da multa de fidelidade ao realizar o bloqueio do beneficiário

@author Gabriel Mucciolo
@version Protheus 12
@since 09/09/2022
/*/
//------------------------------------------------------------------

Method GetMultaFidelidade(cMatricula) Class PLSBenefBloqSrv

    Local oDados     := JsonObject():New()
    Local aDados     := {}
    Local oRequest   := nil
    Local oDetalhe   := nil
    Local aMatricula := {}
    Local cOpe       := ''
    Local cEmp       := ''
    Local cMat       := ''

    Default cMatricula := ""
    aAdd(aMatricula, cMatricula)

    If FindClass('PLBenefMulta')
        oRequest := PLBenefMulta():New()
        if oRequest:SetBeneficiarios(aMatricula,,)
            nValorMulta := oRequest:Calcular()
            if nValorMulta > 0
                oDetalhe := oRequest:GetDetalhe()
                oDados['product'] := oDetalhe['produto']
                oDados['productDescription'] := ALLTRIM(oDetalhe['descricaoProduto'])
                oDados['inclusionDate'] := Transform(oDetalhe['dataInclusao'], "@R 9999-99-99") 
                oDados['fidelityTime'] :=  cValToChar(oDetalhe['fidelidade']['quantidadeMeses'])+" Months"
                oDados['fidelityFinalDate'] := Transform(oDetalhe['fidelidade']['dataFinal'], "@R 9999-99-99") 
                oDados['totalAmountFine'] := oDetalhe['valorTotalMulta']
            EndIf
        EndIf
    EndIf

   
    aAdd(aDados, oDados)
Return aDados


//-------------------------------------------------------------------
/*/{Protheus.doc} GetAllBeneficiarios
Retorna todos os beneficiários da familia, quando o solicitante for o
titular o o atributo do json 'familyBlock' estiver com true

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method GetAllBeneficiarios() Class PLSBenefBloqSrv

    Local cAliasTemp := GetNextAlias()
    Local aBloqBeneficiarios := {}

    BeginSQL Alias cAliasTemp
        SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO FROM %Table:BA1% BA1
          WHERE BA1_FILIAL = %XFilial:BA1% 
            AND BA1_CODINT = %exp:Self:cOperadoraSolicitante% 
            AND BA1_CODEMP = %exp:Self:cEmpresaSolicitante% 
            AND BA1_MATRIC = %exp:Self:cFamiliaSolicitante% 
            AND BA1_MOTBLO = ''
            AND BA1.%notDel%
    EndSQL

    While !(cAliasTemp)->(EoF())

        aAdd(aBloqBeneficiarios, (cAliasTemp)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))

        (cAliasTemp)->(DbSkip())
    EndDo

    (cAliasTemp)->(DbCloseArea())

Return aBloqBeneficiarios


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaProtocol
Grava o protocolo de bloqueio no modelo de dados (ModelDef) PLSA99B

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method GravaProtocol() Class PLSBenefBloqSrv

    Local lGrava := .T.
    Local nX := 0
    Local oModel := Nil
    Local oModelB5J := Nil
    Local oModelB5K := Nil

    oModel := FwLoadModel("PLSA99B") 
    oModelB5J := oModel:GetModel("B5JMASTER")
    oModelB5K := oModel:GetModel("B5KDETAIL")

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
    
	oModelB5J:SetValue("B5J_MATSOL", Self:cMatriculaSolicitante)
	oModelB5J:SetValue("B5J_DATSOL", dDataBase)
	oModelB5J:SetValue("B5J_STATUS", "0") // 0 = Pendente
	oModelB5J:SetValue("B5J_ORISOL", "3") // 3 = Portal Web
	oModelB5J:SetValue("B5J_PROTOC", P773GerPro())   

    For nX := 1 To Len(Self:aBloqBeneficiarios)
        If nX > 1
            oModelB5K:AddLine(.T.)
        EndIf

        oModelB5K:SetValue("B5K_MATUSU", Self:aBloqBeneficiarios[nX])
    Next nX                                           
		
	If oModel:VldData()
        Self:cProtocoloGerado := oModelB5J:GetValue("B5J_PROTOC")

		oModel:CommitData()
	Else
        Self:SetError(400, "BL10", oModel:GetErrorMessage()[6], oModel:GetErrorMessage()[6])
        lGrava := .F.
	EndIf

	oModel:DeActivate()
	oModel:Destroy()

	FreeObj(oModel)
	oModel := Nil
    
    FreeObj(oModelB5J)
	oModelB5J := Nil

    FreeObj(oModelB5K)
	oModelB5K := Nil

    If ExistBlock("PL99GRVSOL")
        BA1->(DbSetOrder(2)) 
        For nX := 1 To Len(Self:aBloqBeneficiarios)
            If BA1->(MsSeek(xFilial("BA1")+Self:aBloqBeneficiarios[nX]))
                // Ponto de Entrada para manipulação da solicitação de cancelamento de beneficiario                                                     
                ExecBlock("PL99GRVSOL", .F., .F., {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), ""})
            EndIf
        Next nX
    EndIf

Return lGrava


//-------------------------------------------------------------------
/*/{Protheus.doc} RetProtocolBloq
Retorna os dados da solicitação de bloqueio do beneficiário informado

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------
Method RetProtocolBloq(cMatriculaSolicitante) Class PLSBenefBloqSrv

    Default cMatriculaSolicitante := ""

    If Len(cMatriculaSolicitante) == 17

        BA1->(DbSetOrder(2))
        If BA1->(MsSeek(xFilial("BA1")+cMatriculaSolicitante))

            Self:oResult["blockingDate"] := Self:SetAtributo(DToS(BA1->BA1_DATBLO), "Date")
            Self:oResult["blockingReason"] := Self:SetAtributo(BA1->BA1_MOTBLO, "String")
            Self:oResult["blockingProtocol"] := Self:GetProtocolo(cMatriculaSolicitante)
            Self:oResult["fidelity"] := Self:GetMultaFidelidade(cMatriculaSolicitante)

        Else
            Self:SetError(400, "BL03", STR0003+cMatriculaSolicitante+STR0006, STR0007+"BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO") // "Matrícula ";" não foi encontrada.";"Matricula não encontrada na tabela BA1 pela chave: "
        EndIf
    Else   
        Self:SetError(400, "BL02", STR0003+cMatriculaSolicitante+STR0004, STR0005+"BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO") // "Matrícula ";" inválida.";"Matrícula deve ter o tamanho de 17 caracteres: "
    EndIf

Return Self:lSuccess


//-------------------------------------------------------------------
/*/{Protheus.doc} SetError
Inseri error de Bad Request

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------
Method SetError(nStatus, cCode, cMessage, cDetailedMessage) Class PLSBenefBloqSrv

    Default nStatus := 400
    Default cCode := "BL00"
    Default cMessage := "Bad Request"
    Default cDetailedMessage := "O servidor nao foi capaz de entender a solicitacao"

    Self:oError["status"] := nStatus
    Self:oError["code"] := cCode
    Self:oError["message"] := cMessage
    Self:oError["detailedMessage"] := cDetailedMessage

    Self:nStatus := nStatus
    Self:lSuccess := .F.

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetError
Retornar os erros de Bad Request

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------
Method GetError() Class PLSBenefBloqSrv
Return self:oError


//-------------------------------------------------------------------
/*/{Protheus.doc} GetResult
Retorna JSON processado com sucesso!

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------
Method GetResult() Class PLSBenefBloqSrv
Return self:oResult:ToJson()


//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatusCode
Retornar statusCode

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------
Method GetStatusCode() Class PLSBenefBloqSrv
Return self:nStatus


//-------------------------------------------------------------------
/*/{Protheus.doc} SetAtributo
Seta atributo no JSON no Formato Padrão TOTVS

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------
Method SetAtributo(xValor, cTipo) Class PLSBenefBloqSrv
    
    Local xRetorno

    Default xValor := ""
    Default cTipo := "String"

	xRetorno := IIf(ValType(xValor) == "C", Alltrim(xValor), xValor)

    If !Empty(xValor)
        Do Case
			Case cTipo == "Date" .And. ValType(xValor) == "C" .And. Len(xValor) == 8
                xRetorno := Transform(xValor, "@R 9999-99-99")
        EndCase	    
    Else
        xRetorno := ""
    EndIf

Return xRetorno