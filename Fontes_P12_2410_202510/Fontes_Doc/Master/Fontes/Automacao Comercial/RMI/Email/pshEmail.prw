#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} pshEmail
Function responsavel por enviar os e-mails a partir do schedule utilizada
pela integração Protheus Smart hub

Exemplo de parâmetros recebidos do schedule:
aParams[1]:"VENDA"
aParams[2]:"T1"
aParams[3]:"D MG 01 "
aParams[4]:"000000"
aParams[5]:"000004000001"

@author  Everson S. P. Junior
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshEmail(aParams)

    Local oEmail     := nil
    Local cTipo      := ""    
    Local dDataDados := nil

    if len(aParams) >= 3  

        //Alterado para RPCSetType(3) para não consumir licença
        rpcSetType(3) 
        lContinua := rpcSetEnv(aParams[2], aParams[3], /*cEnvUser*/, /*cEnvPass*/, "LOJA", "pshEmail")

        if lContinua

            ljGrvLog("pshEmail", "Parâmetros recebidos pela função:", aParams)

            cTipo      := aParams[1]
            dDataDados := dDataBase - 1

            if cTipo == "VENDA" .and. findClass("totvs.protheus.retail.rmi.email.Venda")

                oEmail := totvs.protheus.retail.rmi.email.Venda():new("PDVSYNC", dDataDados, dDataDados)
                
                if oEmail:getSucesso()
                    oEmail:envia()
                endIf

                fwFreeObj(oEmail)
            endIf
        endIf
    endIf

    //Encerra o ambiente, fechando as devidas conexões
    rpcClearEnv()

Return nil