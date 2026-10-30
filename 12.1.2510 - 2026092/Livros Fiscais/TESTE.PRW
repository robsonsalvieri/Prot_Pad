#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
 
/*/{Protheus.doc} User Function exExecAuto
    (Função que inicializa o processamento.)
    @type  Function
    @author user
    @since 04/09/2023
    @version 12.1.2210
    @return Nil, Nil, sem retorno
/*/
User Function exExecAuto()
    local lMVFACAUTO := .F.
    local nOp := 4
    local cCodPerfil := "200001"
    local cTipoPart := "1"
    local cCliFor := "SP0003"
    local cLoja := "01"
    local cTipoPerf := "02"
    local lOk := .F.
 
    ConOut(Repl("-",80))
    ConOut(PadC("Mensagem : Inicío do processamento " + Time(), 80))
 
    // preparo o ambiente
    // prepare o ambiente da maneira que achar melhor
    // para este exemplo abrirei apenas as tabelas F20 e F22
    PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "XIFIS26" MODULO "FIS" TABLES "F20", "F22"
 
 
        /*
            Lógica de cadastro de cliente/fornecedor via execAuto das rotinas de
            cadastro de cliente e fornecedor.
        */
 
 
        // Inclusão de novo fornecedor/cliente em um perfil de participante já existente
        lMVFACAUTO := GetNewPar("MV_FACAUTO", lMVFACAUTO)
        if lMVFACAUTO // se o facilitador estiver ativado
            dbSelectArea("F20")
            F20->(dbSetOrder(1))
            // posiciono no perfil ao qual quero incluir o novo cliente/fornecedor
            if F20->(MsSeek(xFilial("F20") + cCodPerfil + cTipoPerf))
                // chamo a função para gravar nova linha de participante (F22)
                lOk := u_gravaPart(nOp, cCodPerfil, cTipoPart, cCliFor, cLoja, cTipoPerf)
                if !lOk
                    ConOut("Mensagem : Não foi possível a inserção de novo participante no perfil. Verificar Log.")
                else
                    ConOut("Mensagem : Incluído participante " + cCliFor + " ao perfil " + cCodPerfil+".")
                endif
            else
                ConOut("Mensagem : Perfil de Participante inexistente!")
            endIf
        endif
        ConOut("Mensagem : Fim da Execução em - "+Time())
 
    RESET ENVIRONMENT
 
Return
 
 
/*/{Protheus.doc} User Function gravaPart
    (Grava cliente/fornecedor em perfil de participante já existente)
    @type  Function
    @author user
    @since 05/09/2023
    @version version
    @param nOp, numeric, Opção a ser aplicada
    @param cCodPerfil, character, Código do Perfil a ser vinculado o participante
    @param cTipoPart, character, Tipo do Participante - Fornecedor (1) Cliente (2)
    @param cCliFor, character, Código do cliente/fornecedor
    @param cLoja, character, Loja do cliente/fornecedor
    @param cTipoPerf, character, Tipo do Perfil de participante: 1-Origem Destino; 2-Participante; 3-Operação. No nosso caso será sempre 2
    @return lOk, logical, flag que identifica se a inserção ocorreu
/*/
User Function gravaPart(nOp, cCodPerfil, cTipoPart, cCliFor, cLoja, cTipoPerf)
    local oModel as object
    local lOk := .F.
 
    oModel := FwLoadModel("FISA164") // carrego o modelo da rotina
 
    if nOp == MODEL_OPERATION_UPDATE // verifico se é alteração
 
        // Através da operação de update no modelo, consigo adicionar uma nova
        // linha na GRID (F22).
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate() // ativo o modelo
 
        //Adiciona uma nova linha no grid
        oModel:GetModel("FISA164PARTICIPANTE"):AddLine()
        oModel:SetValue("FISA164PARTICIPANTE", "F22_CODIGO", cCodPerfil)
        oModel:SetValue("FISA164PARTICIPANTE", "F22_TPPART", cTipoPart)
        oModel:SetValue("FISA164PARTICIPANTE", "F22_CLIFOR", cCliFor)
        oModel:SetValue("FISA164PARTICIPANTE", "F22_LOJA", cLoja)
        oModel:SetValue("FISA164PARTICIPANTE", "F22_TIPOPF", cTipoPerf)
 
        If oModel:VldData()
            oModel:CommitData()
            lOk := .T.
        Else
            VarInfo("",oModel:GetErrorMessage())
        EndIf
 
        oModel:DeActivate()
    else
        ConOut("Mensagem : Opção de operação diferente da esperada: ")
        ConOut("Mensagem : Operação esperada: 4")
        ConOut("Mensagem : Operação recebida: " + str(nOp))
    endif
Return lOk
