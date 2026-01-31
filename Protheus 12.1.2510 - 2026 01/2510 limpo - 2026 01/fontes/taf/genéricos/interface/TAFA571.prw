#INCLUDE "Protheus.ch"
#INCLUDE "TAFA571.ch"

/*/{Protheus.doc} TAFA571
    Função de processamento manual da ST2 x TAFXERP
    @type  Function
    @author user
    @since 13/07/2020
    @version version
/*/
Function TAFA571()
    Local lRet      := .T.
    //------------------------------------------
    //VARIÁVEIS PARA DIMENSIONAMENTO DE 
    //ACORDO COM O TAMANHO DA TELA E FORMATAÇÃO
    //------------------------------------------
    Local aRes		:= GetScreenRes()	// Recupera Resolução atual
    Local nWidth	:= aRes[1]		// Largura 
    Local nHeight   := aRes[2]		// Altura 
    Local nTmGrd    := 0            // Controle para montagem de grid de posicionamento de objetos 
    Local nTmGrdCpo := 0            // Controle dos tamanhos do campo
    Local oTFont    := TFont():New('Arial Black',,-14,.T.)

    //----------------------------------------------------------------------
    //VARIÁVEIS PARA CAMPOS LIBERADOS PARA EDIÇÃO E PRÉ-CARREGAMENTO DE TELA
    //----------------------------------------------------------------------
    Local cCadastro := STR0001
    Local dDtDe     := STOD(" / / ")    //Space(TAMSX3("C9V_DTNASC")[1])//TAMANHO DE DATA
    Local dDtAte    := STOD(" / / ")    //Space(TAMSX3("C9V_DTNASC")[1])//TAMANHO DE DATA
    Local cTafKey   := Space(IIF(SFT->( ColumnPos( 'FT_TAFKEY' ) )>0,TAMSX3("FT_TAFKEY")[1],100))
    Local cTicket   := Space(Len(FWUUID( "TICKET" )))
    Local cEvento   := Space(TAMSX3("C9V_NOMEVE")[1]+1) //SOMA DE UM CARACTERE, CASO O USUÁRIO COLOQUE O TRAÇO NA BUSCA
    Local aButtons  := {} 

    //--------------------------------------
    //ÁREA DE CAMPOS E TITULOS
    //--------------------------------------
    Local oSDtDe	:= nil
    Local oGDtDe	:= nil
    Local oSDtAte	:= nil
    Local oGDtAte	:= nil
    Local oSKEY	    := nil
    Local oGKEY	    := nil
    Local oSTICKET  := nil
    Local oGTICKET  := nil
    Local oSEvt     := nil
    Local oGEvt     := nil
    
    //Somente um usuario do grupo administrador terá acesso a essa rotina
    If FWIsAdmin( __cUserID )
        //-----------------
        //MONTAGEM DA TELA
        //-----------------
        oDlg  := FWDialogModal():New()
        oDlg:SetBackground(.F.)
        oDlg:SetTitle(cCadastro)
        oDlg:lFontBoldTitle:= .T.
        oDlg:enableFormBar(.T.)
        
        //-------------------------
        //DIMENSIONAMENTO DA DIALOG
        //--------------------------
        nWidth      := (nWidth/2)*0.22
        nHeight     := (nHeight/2)*0.25
        oDlg:SetFreeArea(nWidth,nHeight)
        oDlg:createDialog()
        oDlg:addCloseButton(nil,STR0002 )//"Fechar"
        aAdd(aButtons, {, STR0003,;
        {|| IIF(fVldCpos(dDtDe,dDtAte,cTAFKEY,cTicket,cEvento),;
        FWMSGRUN(,{||fProcRegs({DTOS(dDtDe),DTOS(dDtAte),cTAFKEY,cTicket,cEvento},oDlg),.F.},STR0018, STR0019),.F.) },,, .T., .T.} )//processando # "Processando dados..."


        oDlg:addButtons(aButtons)
        oTFont:Bold := .T.
        
        //------------------------------------------------------------------
        //MONTAGEM DE GRID PARA DIMENSIONAMENTO E LAYOUT DOS OBJETOS EM TELA
        //------------------------------------------------------------------
        nTmGrd      := nWidth/2 //POSICIONAMENTO DOS OBJETOS DENTRO DA DIALOG
        nTmGrdCpo   := nTmGrd-(nTmGrd*0.1) //TAMANHO DO CAMPO 

        //------------------------------------------
        //PEGANDO A ÁREA ÚTIL PARA OS COMPONENTES.
        //------------------------------------------
        oPanel := TPanel():New(0,0,'',oDlg:getPanelMain(),,.T.,.T.,,,nWidth,nHeight,.T.,.T.)
        
        oSDtDe	:= TSay():New(10,5			    ,{|| STR0004 }			                        ,oPanel,,,,,,.T.)//"Data Dê:"
        oGDtDe	:= TGet():New(10,nTmGrd-1			    ,{|u| if(PCount()>0,dDtDe:=u,dDtDe)}	    ,oPanel,nTmGrdCpo,10,X3Picture("C9V_DTNASC") ,,,,,,,.T.,,,,,,,.F.,,,"dDtDe")
        oSDtAte	:= TSay():New(25,5	    ,{|| STR0005  }			                        ,oPanel,,,,,,.T.) //"Data Até:"
        oGDtAte	:= TGet():New(25,nTmGrd-1	    ,{|u| if(PCount()>0,dDtAte:=u,dDtAte)}	    ,oPanel,nTmGrdCpo,10,X3Picture("C9V_DTNASC"),,,,,,,.T.,,,,,,,.F.,,,"dDtAte")
        oSKEY	:= TSay():New(40,5   ,{|| STR0006 }	                                ,oPanel,,,,,,.T.) //"Tafkey"
        oGKEY	:= TGet():New(40,nTmGrd-1   ,{|u| if(PCount()>0,cTafkey:=u,cTafkey)}	,oPanel,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.F.,,,"cTafkey")		
        oSTICKET:= TSay():New(55,5   ,{|| STR0007 }	                    ,oPanel,,,,,,.T.) //"TafTicket"
        oGTICKET:= TGet():New(55,nTmGrd-1   ,{|u| if(PCount()>0,cTicket:=u,cTicket)}	,oPanel,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.F.,,,"cTicket")		
        oSEvt   := TSay():New(70,5   ,{|| STR0008 }	                    ,oPanel,,,,,,.T.) //"Evento"
        oGEvt   := TGet():New(70,nTmGrd-1   ,{|u| if(PCount()>0,cEvento:=u,cEvento)}	,oPanel,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.F.,,,"cEvento")		
        oDlg:Activate()
    else
         Aviso(STR0012,STR0017,{STR0011},3)//"Por segurança, esta rotina está disponível apenas para usuários pertencentes ao grupo de administradores."
    EndIf
Return lRet

/*/{Protheus.doc} fProcRegs
Rotina para envio dos dados para  TAFFIXST2
@author edvf8
@since 15/07/2020
@param aInfoParam, array, parametro de busca
@return lret, boolean, return_description
/*/
Function fProcRegs( aInfoParam as array, oDlg as object )

    Local aFil      as array
    Local cMsgErro  as character
    Local cCodFil   as character
    Local cUUID     as character
    Local cUserLock as character
    Local lRet      as logical
    Local nI        as numeric

    Default aInfoParam := {}
    Default oDlg       := NIL

    aFil               := {}
    cMsgErro           := ""
    cCodFil            := ""
    cUUID              := "UPDSTD"
    cUserLock          := ""
    lRet               := .T.
    nI                 := 0

    aFil := TAFCodFilErp()    

    cCodFil := "'"+ strtran(ArrTokStr( aFil), "|", "', '") + "'"   

    If !VarSetUID(cUUID,.T.)
        cMsgErro := STR0009
        Aviso(STR0010,cMsgErro,{STR0011},1)
        lRet:= .F.
    Else
        If !TafLockInteg(cUUID,.T.,@cUserLock,cCodFil,.T.,@cMsgErro,aInfoParam)

            Aviso(STR0010,cMsgErro,{STR0011},3)
            lRet:= .F.        
        EndIf
        TafLockInteg(cUUID,.F.)
    EndIf

    If !MsgYesNo(STR0021,STR0020)//"Deseja processar novos registros?"#"Processamento"
        oDlg:Deactivate()
    EndIf

Return lRet

/*/{Protheus.doc} fVldCpos
Função de Validação do preenchimento dos campos.
@type function
@version 
@author edvf8
@since 15/07/2020
@param dDtDe, date, range de data, data inicial
@param dDtAte, date, data final
@param cTAFKEY, character, informação do TAFKEY
@param cTicket, character, informação do Ticket
@param cEvento, character, informação do evento desejado.
@return return_type, return_description
/*/
Static Function fVldCpos(dDtDe,dDtAte,cTAFKEY,cTicket,cEvento)
Local lRet      := .T.
Local cMsgErro  := ""
Local cAviso    := ""
Local cTitulo   := STR0012
Default dDtDe   := ""
Default dDtAte  := ""
Default cTAFKEY := ""
Default cTicket := ""
Default cEvento := ""

//------------------
//VALIDAÇÃO DE DATAS
//------------------
If !Empty(dDtDe) .And. !Empty(dDtAte)
    If dDtAte < dDtDe
        cMsgErro:= STR0013 + CRLF
        lRet    := .F.
    EndIf
    If lRet .And. (dDtAte - dDtDe) > 15
        cAviso += STR0022 +Alltrim(Str(dDtAte - dDtDe)) + STR0023 +CRLF // "O período selecionado é de "#", isso pode tornar o processamento mais lento."
    EndIf
else
    cMsgErro    += STR0014 + CRLF
    lRet        := .F.
EndIf

//-------------------
//VALIDAÇÃO DE TAFKEY e TAFTICKET
//------------------
If Empty(cTafKey) .Or. Empty(cTicket) .Or. Empty(cEvento)
    cAviso+= STR0015 + CRLF //"Em caso de não preenchimento dos campos (Ticket,Tafkey,cEvento), os mesmos não serão considerados no filtro de processamento."
EndIf

If !Empty(cMsgErro)
    MsgAlert(cMsgErro)
else
    If !Empty(cAviso)
        If !MsgYesNo(cAviso+CRLF+STR0016,cTitulo)//'Deseja continuar?'
            lRet:= .F.
        Endif
    EndIf
EndIf
Return lRet
