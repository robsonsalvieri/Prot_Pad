#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include "TOPConn.ch"
#Include "GTPA502.ch"

/*/{Protheus.doc} GTPA502A
Função de recebimento dos malotes.
@type  function 
@author Yuri Porto
@since  08/08/2024
@version 12.1.2310
/*/

Function GTPA502A()
Local   aSize   := FWGetDialogSize( oMainWnd )
Local   oDlg    := Nil
Private oMark
	
    oDlg :=MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4],STR0034, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) //

	oMark := FWMarkBrowse():New()
	oMark:SetAlias('H7C')	
	oMark:SetDescription('Seleção do Registros')
	oMark:SetFieldMark( 'H7C_RECOK' )
    oMark:SetSemaphore(.T.)
    oMark:SetOwner(oDlg)
    
    //filtro de acordo com o registro que deseja aparecer no browse 
    oMark:SetFilterDefault("!Empty(H7C_CODVIA) .And. !Empty(H7C_RECURS) ")//.And. Empty(H7C_RECCOD)")
    oMark:SetMenuDef("GTPA502A")
    
    //Legenda	
    oMark:AddLegend("!Empty(H7C_CODVIA) .And. !Empty(H7C_RECURS) .And. Empty(H7C_RECCOD)"  , "YELLOW" , "Enviado")        // "Enviado"
    oMark:AddLegend("!Empty(H7C_CODVIA) .And. !Empty(H7C_RECURS) .And. !Empty(H7C_RECCOD)" , "GREEN"  , "Recebido")       // "Recebido"

    //Força Refresh
    oMark:Refresh(.T.)
	oMark:GoTop(.T.)

	//Ativando a janela
	oMark:Activate()
    oDlg:Activate()

    oMark:DeActivate()
    
Return NIL




/*/{Protheus.doc} GTPA502A
Função para criação dos menus.
@type  function 
@author Yuri Porto
@since  08/08/2024
@version 12.1.2310
/*/ 
Static Function MenuDef()
	Local aRotina := {}
	
	//Criação das opções
	ADD OPTION aRotina TITLE 'Efetuar Recebebimeto'   ACTION 'G502ARECEB(1,oMark)'     OPERATION MODEL_OPERATION_VIEW ACCESS 0    //'Efetuar Recebebimeto
    ADD OPTION aRotina TITLE 'Cancelar Recebimento'   ACTION 'G502ARECEB(2,oMark)'     OPERATION MODEL_OPERATION_VIEW ACCESS 0    //'Cancelar Recebimento' 
	
Return aRotina




/*/{Protheus.doc} GTPA502A
Rotina para processamento
@type  function 
@author Yuri Porto
@since  08/08/2024
@version 12.1.2310
/*/ 
Function G502ARECEB(nOperacao,oMark)
Local aArea    := GetArea()
Local cMarca   := oMark:Mark()
Local aMalotes := {}	
Local nZ       := 0
Local cDir     := ""

Default nOperacao := 0

    If nOperacao ==1
        If FwAlertYesNo(STR0035,STR0024)                    //"Deseja efetuar o recebimento do Malote ?"  //"Atenção!!!"
            H7C->(DbGoTop())
            While !H7C->(EoF())
                If oMark:IsMark(cMarca)
                    RecLock('H7C', .F.)
                        H7C->H7C_RECCOD  := __CUSERID
                        H7C->H7C_RECDAT  := dDataBase
                        H7C->H7C_RECOK   := ""  
                        AADD(aMalotes,H7C->( Recno() ) )
                    H7C->(MsUnlock())
                EndIf                
                H7C->(DbSkip())
            EndDo
            If FwAlertYesNo(STR0036,STR0024)                //"Deseja efetuar a impressão do(s) recebimento(s) de Malote(s) ?" //"Atenção!!!"
                For nZ:= 1 to len(aMalotes)
                    H7C->(DbGoTo(aMalotes[nZ]))             //posiciona para impressão do recibo
                    GTP502REL(2,@cDir)                      //impressão do recibo
                Next
            EndIf
        EndIf
    Elseif nOperacao ==2
        If FwAlertYesNo(STR0037,STR0024)                    //"Deseja efetuar cancelamento do recebimento do Malote ?"  //"Atenção!!!"
            H7C->(DbGoTop())
            While !H7C->(EoF())
                If oMark:IsMark(cMarca)
                    RecLock('H7C', .F.)
                        H7C->H7C_RECCOD := ""
                        H7C->H7C_RECDAT := ctod("")
                        H7C->H7C_RECOK  := ""
                    H7C->(MsUnlock())
                EndIf                
                H7C->(DbSkip())
            EndDo
        EndIf
    EndIf
	RestArea(aArea)

    oMark:Refresh(.T.)
	oMark:GoTop(.T.)

Return NIL

