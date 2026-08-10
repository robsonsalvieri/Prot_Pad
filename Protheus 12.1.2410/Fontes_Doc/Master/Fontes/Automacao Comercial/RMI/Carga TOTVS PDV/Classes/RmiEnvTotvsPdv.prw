#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvTotvsPdv
Classe responsável pelo envio de dados ao Totvs Pdv

/*/
//-------------------------------------------------------------------
Class RmiEnvTotvsPdv From RmiEnviaObj
    
    Data cTempProcesso  As Character
    Data cRegExclus     As Character
    Data nTamCProce     As Numeric
    Data nTamChvUni     As Numeric
    Data nTamPdv        As Numeric
    Data aTabMiq        As Array

    Method New()
    Method PreExecucao()
    Method CarregaBody()
    Method Envia()
    Method Grava()
    Method getMiq()
    Method ValidFil()
    Method SalvaConfig()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso,cAssinante) Class RmiEnvTotvsPdv    
    _Super:New(cAssinante, cProcesso) 
    Self:getMiq()

    Self:nTamCProce := TamSx3("MIP_CPROCE")[1]
    Self:nTamChvUni := TamSx3("MIP_CHVUNI")[1]
    Self:nTamPdv    := TamSx3("MIP_PDV")[1]

    Self:cTempProcesso  := ""
    Self:cRegExclus     := ""

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvTotvsPdv
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaBody
Metodo que carrega o corpo da mensagem que será enviada

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method CarregaBody() Class RmiEnvTotvsPdv
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao sistema de destino

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvTotvsPdv
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição e gravar a tabela MIP

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiEnvTotvsPdv

Local lInclui   := .T.
Local nX        := 0

Begin Transaction

    If Len(Self:aTabMiq) > 0

        _Super:Grava("2","","")

        If Self:cTempProcesso <> AllTrim(MHQ->MHQ_CPROCE)
            Self:cTempProcesso  := AllTrim(MHQ->MHQ_CPROCE)
            Self:cRegExclus     := Self:ValidFil()
        EndIf

        For nX := 1 To Len(Self:aTabMiq)

            MIQ->(dbGoTo(Self:aTabMiq[nX][1]))

            If (Self:cRegExclus == "COMPARTILHADA") .OR. (Self:cRegExclus == "EXCLUSIVA" .AND. AllTrim(MIQ->MIQ_FILPC) == AllTrim(MHQ->MHQ_IDEXT)) .OR.;
                (AllTrim(Self:cRegExclus) $ AllTrim(MHQ->MHQ_IDEXT))

                MIP->(dbSetOrder(1)) //MIP_FILIAL+MIP_CPROCE+MIP_CHVUNI+MIP_PDV
                lInclui := !MIP->( DbSeek(MIQ->MIQ_FILPC + PadR(Self:cProcesso, Self:nTamCProce) + PadR(Self:cChaveUnica, Self:nTamChvUni) + PadR(MIQ->MIQ_COD, Self:nTamPdv)) )

                RecLock("MIP", lInclui)
                MIP->MIP_FILIAL := MIQ->MIQ_FILPC
                MIP->MIP_CPROCE := Self:cProcesso
                MIP->MIP_CHVUNI := Self:cChaveUnica
                MIP->MIP_LOTE   := ""
                MIP->MIP_DATGER := Date()
                MIP->MIP_HORGER := TimeFull()
                MIP->MIP_DATPRO := CtoD("")
                MIP->MIP_HORPRO := ""
                MIP->MIP_STATUS := "1"
                MIP->MIP_UUID   := FwUUID("MIP" + DtoS(MIP->MIP_DATGER) + MIP->MIP_HORGER)
                MIP->MIP_UIDORI := MHR->MHR_UIDMHQ
                MIP->MIP_IDRET  := MHR->MHR_IDRET
                MIP->MIP_PDV    := MIQ->MIQ_COD
                MIP->MIP_TENTAT := "0"
                MIP->( MsUnLock() )

            EndIf

        Next nX
    Else
        LjGrvLog(" RmiEnvTotvsPdv ", "A gravação da tabela MIP não aconteceu porque não existem cadastrados ponto de carga ou o cadastro pode estar como Ativo = Não")
    EndIf

End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getMiq
Consulta os ponto de carga ativos

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method getMiq() Class RmiEnvTotvsPdv

Local cQuery := ""

cQuery := "SELECT R_E_C_N_O_ REC"
cQuery += "  FROM " + RetSqlName("MIQ")
cQuery += " WHERE MIQ_FILIAL = '" + xFilial("MIQ") + "'"
cQuery += "   AND MIQ_ATIVO = '1'"
cQuery += "   AND D_E_L_E_T_ = ''"

Self:aTabMiq := RmiXSql(cQuery, "*", /*lCommit*/, /*aReplace*/)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidFil
Valida para qual ponto de carga deve-se endereçar o registro

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method ValidFil() Class RmiEnvTotvsPdv

Local cRet      := ""
Local aTabela   := {}

dbSelectArea("MHN")
MHN->(dbSetOrder(1)) //MHN_FILIAL+MHN_COD
If MHN->(dbSeek(xFilial("MHN") + PadR(MHQ->MHQ_CPROCE,TamSx3("MHN_COD")[1])))
    aTabela := FwSX2Util():GetSX2data(MHN->MHN_TABELA,{"X2_MODO","X2_MODOUN","X2_MODOEMP"})
    If aTabela[1][2] == "C" .AND. aTabela[2][2] == "C" .AND. aTabela[3][2] == "C"
        cRet := "COMPARTILHADA"
    ElseIf aTabela[1][2] == "E" .AND. aTabela[2][2] == "E" .AND. aTabela[3][2] == "E"
        cRet := "EXCLUSIVA"
    Else
        cRet := xFilial(AllTrim(MHN->MHN_TABELA))
    EndIf
EndIf

FwFreeArray(aTabela)
aTabela := {}

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaConfig
Metodo que ira atualizar a configuração do assinante.

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method SalvaConfig() Class RmiEnvTotvsPdv
Return .T.
