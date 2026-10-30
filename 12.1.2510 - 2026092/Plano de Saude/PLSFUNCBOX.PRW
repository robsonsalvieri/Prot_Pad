#INCLUDE "PROTHEUS.CH"
/* Este fonte terá as funções de x3_cbox do PLS */
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCRWEBPRE
Retorna os novos status de protocolo da TISS 
@author Karine Riquena Limp
@since 12/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSSTATISS()
Local cRet := "1=Recebido;2=Em análise;3=Liberado para pagamento;4=Encerrado sem pagamento;5=Analisado e aguardando liberação para o pagamento;6=Pagamento efetuado;7=Não localizado;8=Aguardando informação complementar;9=Cancelado"
Return cRet

Function PLSGUTISS()
Local cRet := "1=Autorizado;2=Em análise;3=Negado;4=Aguardando justificativa técnica do solicitante;5=Aguardando documentação do prestador;6=Solicitação cancelada;7=Autorizado parcialmente"
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCTCONSTISS
Retorna string concatenada dos termos da tabela BTQ filtrados por BTP_CODTAB
@author Zaar Ribeiro
@since 24/04/2026
@version P12
/*/
//-------------------------------------------------------------------
Function PLSTABTISS(cTab)
    Local cRet := " "
    Local cAlias := "BTQ"

    dbSelectArea(cAlias)
    dbSetOrder(1) // Assumindo ordem por código
    dbGoTop()
    dbSeek(xFilial("BTQ") + cTab)

    While BTQ->(!Eof()) .and. BTQ->BTQ_CODTAB == cTab
        if !Empty(cRet)
            cRet += ";"
        EndIf
        If dDataBase >= BTQ->BTQ_VIGDE            
            cRet += ";"            
            cRet += AllTrim(BTQ->BTQ_CDTERM) + "=" + AllTrim(BTQ->BTQ_DESTER)
        EndIf
        BTQ->(dbSkip())
    EndDo
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVALCTCONS
Validação do campo de Centro de Consumo para eventos de material ou medicamento, verificando a existência do código na tabela BTQ para os tipos 19 (Material) e 20 (Medicamento).
@author Zaar Ribeiro
@since 22/04/2026
@version P12
/*/
//-------------------------------------------------------------------
Function PLSVALTISS(cCod, cTab)
    Local lRet := .F.
    Local cAlias := "BTQ"


    dbSelectArea(cAlias)
    dbSetOrder(1) // Assumindo ordem por BTQ_FILIAL + BTQ_CODTAB + BTQ_CDTERM
    dbSeek(xFilial("BTQ") + cTab + cCod)

    If Found() .and. trim(BTQ->BTQ_CODTAB) == cTab .and. trim(BTQ->BTQ_CDTERM) == cCod
        If dDataBase >= BTQ->BTQ_VIGDE .and. (Empty(BTQ->BTQ_VIGATE) .or. dDataBase <= BTQ->BTQ_VIGATE)
            lRet := .T.
        EndIf
    EndIf
Return lRet

Function PLSVALREFTISS(cCod, cTab, cAlias)
    Local lAlias := "BTU" 
    
    dbSelectArea(lAlias)
    dbSetOrder(1) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRBUS
    dbSeek(xFilial(lAlias) + cTab + cAlias + cCod)
    
Return Found()

function PLSVALCTCONS(cGuia, cCod)
    Local lRet := .F.
    
    if !empty(M->BX6_CTCONS)
        lRet := cGuia != "03" .and. cGuia != "05"
        if lRet
            MsgInfo("O centro de consumo só deve ser preenchido em Guias de Resumo de Internação.")        
        else 
            lRet := Empty(cCod)
            if lRet
                MsgInfo("O código do evento não foi informado. Por favor, informe um código de material ou medicamento TISS para validação.")                
            else   
                lRet := !(PLSVALREFTISS(cCod, "19", "BR8") .or. PLSVALREFTISS(cCod, "20", "BR8"))             
                if lRet
                    MsgInfo("O campo de Centro de Consumo não deve ser preenchido quando o evento não for um material ou medicamento TISS.")                                 
                EndIf                
            EndIf            
        EndIf        
    endif

    if lRet
        M->BX6_CTCONS := ""   
    endif  
Return !lRet
