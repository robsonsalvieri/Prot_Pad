#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fisa305.ch"

/*/{Protheus.doc} FISA305
    (Função inicializadora para geração do arquivo de serviços tomados do município de São José dos Campos)
    @type  Function
    @author pereira.weslley
    @since 02/12/2020
    @version 1.0
    @param none
    @return none
    @example
    (Função inicializadora para geração do arquivo de serviços tomados do município de São José dos Campos)
    @see (links_or_references)
    /*/
function FISA305()
    Local lLGPD  	:= FindFunction("Verpesssen") .And. Verpesssen()
    Local lAutomato := Iif(IsBlind(), .T., .F.)

    If lLGPD
        If !lAutomato
            If Pergunte('FISA305', .T., STR0001) //"Parâmetros para geração do arquivo"
                FwMsgRun(,{|oSay| MainSJC(oSay)}, STR0002, "") //"Processando arquivo"
            Else
                Alert("Pergunte não encontrado - Atualize a base de dados")
            EndIf
        Else
            MainSJC()
        EndIf
    EndIf

Return 

/*/{Protheus.doc} MainSJC
    (Função principal da rotina de geração do arquivo de serviços tomados do município de São José dos Campos)
    @type  Function
    @author pereira.weslley
    @since 02/12/2020
    @version 1.0
    @param oSay, Objeto, Componente que será sobreposto com o painel
    @return none
    @example
    (Função principal da rotina de geração do arquivo de serviços tomados do município de São José dos Campos)
    @see (links_or_references)
    /*/
Static function MainSJC(oSay)
    Local oParamArq  := SJCGEN():New(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
    Local oRegT      := REGT():New()
    Local cAliasProc := GetNextAlias()
    Local cAliasSJC  := GetNextAlias()
    Local lContinua  := .T.
    Local cMensagem  := ''
    Local lAutomato  := Iif(IsBlind(), .T., .F.)

    If !lAutomato
        If (Empty(oParamArq:GetDtIni()) .Or. Empty(oParamArq:GetDtFim()))
            lContinua := .F.
            cMensagem += STR0005 + CRLF // Necessario informar a Data Inicio e a Data Fim.
        EndIf

        If oParamArq:GetDtIni() > oParamArq:GetDtFim()
            lContinua := .F.
            cMensagem += STR0011 + CRLF // Data Inicial não pode ser maior que Data Final
        EndIf

        If Empty(oParamArq:GetPath())
            lContinua := .F.
            cMensagem += STR0006 + CRLF // Necessario informar o Diretório.
        EndIf

        If Empty(oParamArq:GetArcName())
            lContinua := .F.
            cMensagem += STR0007 //Necessario informar o Nome do Arquivo.
        EndIf        
    EndIf

    If lContinua
        //Busca os documentos fiscais que irão compôr o arquivo
        QuerySJC(oParamArq, @cAliasProc)

        dbSelectArea(cAliasProc)
        (cAliasProc)->(dbGoTop())

        //Loop para inserir cada documento fiscal da query em um objeto Reg T e posteriormente grava-lo na tabela temporária
        While !(cAliasProc)->(Eof())
            oRegT:GravaRegT(oRegT, cAliasProc)
            GravaTbSJC(@cAliasSJC, oRegT)
            (cAliasProc)->(DBSkip())
            oRegT:LimpaObj()
        End

        //Caso existam registros na tabela, gera o arquivo
        If Select(cAliasSJC) > 0 .And. !(cAliasSJC)->(EoF())
            GeraArqSJC(cAliasSJC, oParamArq)
        Else
            MsgInfo(STR0008, STR0003) //Impossível prosseguir! - Não existem documentos válidos no período informado.
        EndIf
    Else
        MsgInfo(STR0008, cMensagem) // Impossível prosseguir! - Mensagem acumulada
    EndIf

    //Fecha todos Alias e libera todos os objetos
    If Select(cAliasProc) > 0
        (cAliasProc)->(DbCloseArea())
    EndIf

    If Select(cAliasSJC) > 0
        (cAliasSJC)->(DbCloseArea())
        LimpOTBSJC()
        FreeObj(oRegT)
    EndIf

    If !lAutomato
        Alert(STR0010) //"Processamento Concluído"
    EndIf

Return