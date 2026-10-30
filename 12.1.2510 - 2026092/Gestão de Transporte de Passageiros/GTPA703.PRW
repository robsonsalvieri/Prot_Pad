#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GtpjGerTit
Fila de geração dos títulos de receita e despesas
@author flavio.martins
@since 12/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Function GTPA703()
Local oBrowse := Nil	

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('H8C')
oBrowse:SetDescription("Fila de Geração de Títulos") 
oBrowse:oConfig:aButtonsOrder := {}
aAdd(oBrowse:oConfig:aButtonsOrder,"Processar Fila")
aAdd(oBrowse:oConfig:aButtonsOrder,"Selec. Tit. Falha")
oBrowse:Activate()
	
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definições do menu
@author flavio.martins
@since 12/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Processar Fila"     ACTION 'G703GerTit()'  OPERATION 9 ACCESS 0 // "Processar Fila"
    ADD OPTION aRotina TITLE "Selec. Tit. Falha"  ACTION 'G703Reproc()'  OPERATION 3 ACCESS 0 // "Selec. Tit. Falha"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} G703GerTit
Função que faz a chamada da rotina de geração de títulos
@author flavio.martins
@since 12/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Function G703GerTit()
Local aParam := {}

If FindFunction('GTPJGERTIT')
    FwMsgRun( , {|oSelf| lRet := GTPJGERTIT(aParam, oSelf)}, , "Processando fila de geração de títulos... Aguarde!")
Else
    FwAlertWarning("Rotina de geração de títulos não encontrada. Verifique se a rotina GTPJGERTIT está presente e atualizada.")
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} G703Reproc
Função que faz a chamada da rotina de reprocessamento de títulos com error
@author José Carlos
@since 04/07/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Function G703Reproc()
    If LockByName("G703REPROC", .T., .F.) // Tenta efetuar o lock para a filial atual
        FwMsgRun( , {|| lRet := fProcessa()}, , "Reprocessando títulos... Aguarde!")
        UnlockByName("G703REPROC", .T., .T.) // Libera o lock após o término do processamento
    Else 
        FwAlertWarning('Processo já em execução para esta filial.')
    EndIf         
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Função que faz a chamada a montagem da query para seleção e 
processamento dos dados
@author José Carlos
@since 04/07/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function fProcessa()
    Local cAliasTmp := GetNextAlias()
    Local cProcess  := ''
    Local lRegistros:= .F.

    BeginSql Alias cAliasTmp
        Select
            GZG_AGENCI,
            GZG_NUMFCH,
            GZG_SEQ,
            GZG_TIPO,
            GZG_COD,
            GZG_VALOR,
            GZG_NUMTIT
        From %table:GZG% GZG 
        Where GZG_FILIAL = %xFilial:GZG%
            And Not Exists(
                Select 1
                From %table:H8C% H8C
                Where H8C_FILIAL = %xFilial:H8C%
                And H8C_AGENCI = GZG_AGENCI
                And H8C_NUMFCH = GZG_NUMFCH
                And H8C_SEQ = GZG_SEQ
                And H8C_CODGZC = GZG_COD
                And H8C_TIPO = GZG_TIPO 
                And H8C.%NotDel%
            )            
            And GZG_STATIT = '2'
            And GZG.%NotDel%

    EndSql

    If (cAliasTmp)->(!Eof())
        lRegistros := .T.
    EndIf         
    
    While (cAliasTmp)->(!Eof())

        If Empty((cAliasTmp)->GZG_NUMTIT)
            cProcess := '1' //Inclusão
        Else 
            cProcess := '2' //Estorno
        EndIf 

        RecLock("H8C",.T.)

            H8C->H8C_FILIAL := xFilial("H8C")
            H8C->H8C_CODIGO := GetSxeNum("H8C","H8C_CODIGO")
            H8C->H8C_AGENCI := (cAliasTmp)->GZG_AGENCI
            H8C->H8C_NUMFCH := (cAliasTmp)->GZG_NUMFCH
            H8C->H8C_SEQ    := (cAliasTmp)->GZG_SEQ
            H8C->H8C_TIPO   := (cAliasTmp)->GZG_TIPO
            H8C->H8C_CODGZC := (cAliasTmp)->GZG_COD
            H8C->H8C_VALOR  := (cAliasTmp)->GZG_VALOR
            H8C->H8C_DTINCL := dDataBase
            H8C->H8C_HRINCL := Substr(Time(),1,2)+Substr(Time(),4,2)
            H8C->H8C_TPPROC := cProcess

        H8C->(MsUnlock())

        H8C->(ConfirmSx8())

        (cAliasTmp)->(dbSkip())

    EndDo

    (cAliasTmp)->(dbCloseArea())

    If !(lRegistros)
        FwAlertWarning("Não localizado(s) registro(s) para processamento e/ou no aguardo do processamento da fila.")
    EndIf         
Return 
