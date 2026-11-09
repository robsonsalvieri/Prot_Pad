#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapGrvPed
Classe que grava os Pedidos da Integração de acordo com os
STAMPS das Entidades

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Class PLMapGrvPed

    Data cOperadora As String
    Data cCodIntegracao As String
    Data cTabPrimaria As String
    Data cClasseStamp As String
    Data cQuery As String
    Data cBanco As String
    Data cDataStamp As String 
    Data nQtdGerada As Numeric
    Data nQtdExist As Numeric
    Data nQtdFalha As Numeric
    Data nQtdTotal As Numeric

    Method New() Constructor
    Method ProcessDados()
    Method CheckPedido(cChave)
    Method GravaPedido(lConsidDataInc, cChave, cData)
    Method FilterStamp(cAliasStamp)
    Method GetResult()
    Method AddStampBase(aTabelas)
    Method SetPreCadBenef(cChave)

EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New() Class PLMapGrvPed

    self:cOperadora := ""
    self:cCodIntegracao := ""
    self:cTabPrimaria := ""
    self:cClasseStamp := ""
    self:cQuery := ""
    self:cBanco := AllTrim(TCGetDB())
    self:cDataStamp := "" 
    self:nQtdGerada := 0
    self:nQtdExist := 0
    self:nQtdFalha := 0
    self:nQtdTotal := 0

Return self


//----------------------------------------------------------
/*/{Protheus.doc} ProcessDados
Processa a gravação dos pedidos

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method ProcessDados() Class PLMapGrvPed
    
    Local lRetorno := .F.
    Local cAliasTemp := ""
    Local cQuery := self:cQuery

    If !Empty(cQuery)       
        cAliasTemp := GetNextAlias()
        DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

        While (cAliasTemp)->(!Eof())

            If !self:CheckPedido((cAliasTemp)->CHAVE)
                If self:GravaPedido(.T., (cAliasTemp)->CHAVE, (cAliasTemp)->DATA)
                    self:nQtdGerada++
                    lRetorno := .T.
                Else
                    self:nQtdFalha++
                EndIf
            Else
                self:nQtdExist++
            EndIf

            self:nQtdTotal++
            (cAliasTemp)->(DbSkip())
        EndDo

        (cAliasTemp)->(DbCloseArea())
    EndIf

Return lRetorno


//----------------------------------------------------------
/*/{Protheus.doc} CheckPedido
Verifica se já consta pedido em aberto para o Alias + Chave

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method CheckPedido(cChave) Class PLMapGrvPed

    Local lRetorno := .F.
    Local nPedidos := 0
    Local cQuery := ""
                                                                                                                              
    cQuery := " SELECT COUNT(B7F_CODPED) PEDIDOS FROM "+RetSQLName("B7F")+" B7F "
	cQuery += " WHERE B7F.B7F_FILIAL = '"+xFilial("B7F")+"' "
    cQuery += "   AND B7F.B7F_CODOPE = '"+self:cOperadora+"' "
    cQuery += "   AND B7F.B7F_CODIGO = '"+self:cCodIntegracao+"' "
	cQuery += "   AND B7F.B7F_ALIAS = '"+self:cTabPrimaria+"' "
	cQuery += "   AND B7F.B7F_CHAVE = '"+cChave+"' "
    cQuery += "   AND (B7F.B7F_STATUS = '0' OR B7F.B7F_STATUS = '2') "	
	cQuery += "   AND B7F.D_E_L_E_T_ = ' ' "

	nPedidos := MPSysExecScalar(cQuery, "PEDIDOS")

	lRetorno := IIF(nPedidos > 0, .T., .F.)

Return lRetorno


//----------------------------------------------------------
/*/{Protheus.doc} GravaPedido
Grava Pedido do Registro (Alias + Chave) na Tabela B7F

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GravaPedido(lConsidDataInc, cChave, cData) Class PLMapGrvPed

    Local lRetorno := .F.
    Local dDataInclusao := CToD(" / / ")
    Local nDiasBloqueio := GetNewPar("MV_PLDIABL", 0) //Tolerância em dias para o Bloqueio
    Local oModel := FWLoadModel("PLMapPedidos")
    Local lPedidoFuturo := .F.

    Default lConsidDataInc := .T.

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue("MASTERB7F", "B7F_CODOPE", self:cOperadora)
    oModel:SetValue("MASTERB7F", "B7F_CODIGO", self:cCodIntegracao)
    oModel:SetValue("MASTERB7F", "B7F_ALIAS", self:cTabPrimaria)
    oModel:SetValue("MASTERB7F", "B7F_CHAVE", cChave)
  
    If !Empty(cData) .And. lConsidDataInc

        dDataInclusao := SToD(cData)
        If self:cTabPrimaria == "BA1"
            dDataInclusao += nDiasBloqueio
        EndIf
        
        If dDataInclusao > dDataBase 
            oModel:SetValue("MASTERB7F", "B7F_DATINC", dDataInclusao)
            lPedidoFuturo := .T.
        EndIf
    EndIf
    
    If oModel:VldData()
        oModel:CommitData()
        lRetorno := .T.
    EndIf

    If lRetorno .AND. self:cClasseStamp == 'PLPtuStpPCad'
        self:SetPreCadBenef(cChave)
    EndIf
        
    oModel:DeActivate()
    FreeObj(oModel)
    oModel := Nil

    // Pedido programado com data futura, será gerado um outro pedido com a data atual. (Integrações de Beneficiários)   
    If lPedidoFuturo .And. self:cTabPrimaria == "BA1"
        If self:GravaPedido(.F., cChave, cData)
            self:nQtdGerada++
        Else
            self:nQtdFalha++
        EndIf
        self:nQtdTotal++
    EndIf

Return lRetorno


//----------------------------------------------------------
/*/{Protheus.doc} FilterStamp
Filtra entidade pelo STAMP

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method FilterStamp(cAliasStamp) Class PLMapGrvPed

    Local cQuery := ""

    Do Case
        Case self:cBanco $ "MSSQL/MSSQL7"
            cQuery += " ( CONVERT(VARCHAR(8),"+cAliasStamp+".S_T_A_M_P_, 112) = '"+self:cDataStamp+"' )"

        Case self:cBanco $ "ORACLE/POSTGRES"
            cQuery += " ( TO_CHAR("+cAliasStamp+".S_T_A_M_P_, 'YYYYMMDD') = '"+self:cDataStamp+"' )"
    EndCase

Return cQuery


//----------------------------------------------------------
/*/{Protheus.doc} GetResult
Retorna o resultado final do processamento 

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetResult() Class PLMapGrvPed
Return {self:nQtdGerada, self:nQtdExist, self:nQtdFalha, self:nQtdTotal }


//-------------------------------------------------------------------
/*/{Protheus.doc} AddStampBase
Adiciona coluna STAMP na base de dados

@author Vinicius Queiros Teixeira
@since 27/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method AddStampBase(aTabelas) Class PLMapGrvPed

	Local nX := 0
    Local aAlias := {}
	Local lAutoStampON := .F.
	Local lUserStampON := .F.
	Local lRetorno := .F.

    Default aTabelas := {}

	// Tabelas para criar STAMP
    For nX := 1 To Len(aTabelas)
        If PlsAliasExi(aTabelas[nX])
            aAdd(aAlias, {aTabelas[nX], RetSqlName(aTabelas[nX])})
        EndIf
    Next nX
    
    If Len(aAlias) > 0
        TCLink()
            
        lAutoStampON := TCConfig("GETAUTOSTAMP") == "ON"
        lUserStampON := TCConfig("GETUSEROWSTAMP") == "ON"
            
        If !lAutoStampON
            TCConfig("SETAUTOSTAMP=ON")
        EndIf

        If !lUserStampON 
            TCConfig("SETUSEROWSTAMP=ON")
        EndIf
        
        For nX := 1 To Len(aAlias)
            DBSelectArea(aAlias[nX][1])
            (aAlias[nX][1])->(DbCloseArea())
            TCRefresh(aAlias[nX][2])
            DBSelectArea(aAlias[nX][1])

            lRetorno := .T.
        Next nX

        If !lAutoStampON
            TCConfig("SETAUTOSTAMP=OFF")
        EndIf

        If !lUserStampON
            TCConfig("SETUSEROWSTAMP=OFF") 
        EndIf

        TCUnlink()
    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPreCadBenef
Altera o campo BA1_PTUCAD para Pre-Cadastrado ao realizar a solicitação para a BF7

@author Gabriel Mucciolo
@since 12/01/2023
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetPreCadBenef(cChave) Class PLMapGrvPed
    Local lRet := .F.
    BA1->(DbSetOrder(2))
    If BA1->(DbSeek(xFilial('BA1')+cChave))
		BA1->(recLock("BA1",.f.))
			BA1->BA1_PTUCAD := '1'
		BA1->(msUnLock())
    EndIf
Return lRet