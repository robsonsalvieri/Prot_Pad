#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "locw002.ch"

/*/{Protheus.doc} GeraCheckList
Método responsável por gerar o check-list
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/

WSRESTFUL GeraCheckList DESCRIPTION STR0001 //"Gera check-list executado pelo app."

	WSMETHOD POST DESCRIPTION STR0002 WSSYNTAX "/GeraCheckList" //"<h2>Método responsável por gerar o check-list executado pelo app.</h2>"

END WSRESTFUL

/*/{Protheus.doc} GeraCheckList
Definição do método post
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/

WSMETHOD POST WSSERVICE GeraCheckList   
Local aEmp          := {}
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local cRet          := ""
Local lFQC          := .F.
Local nI            := 0
Local nX            := 0
Local nZ            := 0
Local cKeyArq       := ""
Local cNomeArq      := ""
Local cPDFArq       := ""
Local cResposta     := ""
Local lInicio       := .F.
Local aAC9Rec       := {}
Local cCarroReserva := "N"
Local aBindParam    := {}  // Frank em 28/04/25 ISSUE 6573
Local cQuery        := ""  // Frank em 28/04/25 ISSUE 6573
Local lDupl         := .F. // Frank em 28/04/25 ISSUE 6573
Local cTemp         := "" // Frank em 28/04/25 ISSUE 6573
Local lLOCX067      := GETMV("MV_LOCX067",,.F.) // Frank em 28/04/25 ISSUE 6573
Local cStaOld       := ""
Local cQuery        := ""
Local aBindParam    := {}
Local cStaAnt       := ""    

Private oJson		:= Nil
Private cCustoFPA   := ""
Private cNumOs      := ""
Private nAnexos     := 0

Private lGravaTudo  := .T.

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)

            // Frank em 10/09/2025
            If type("oJson:chkParc") == "C"
                If alltrim(upper(oJson:chkParc)) == ".F."
                    lGravaTudo := .F.
                EndIf
            EndIf

            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))//aEmp := FwLoadSm0()
			If at("existente",aEmp[3]) > 0 //(aEmp[3] == "Empresa já existente.")//If RpcSetEnv(aEmp[1,1],aEmp[1,2],,,"FIN",GetEnvServer(),{""})//Empty(cRet)
                cRet := xAbreEnv1(aEmp[1],aEmp[2])

                If Empty(cRet)

                    // Troca do campo sobre status da FPX
                    If FindFunction( "LOCW002A" ) .and. FPX->(FIELDPOS("FPX_OBS")) > 0
                        LOCW002A()
                    EndIf

                    DbSelectArea("FQC")
                    If Empty(oJson:CodCheck)
                        FQC->(DbSetOrder(2)) //FQC_FILIAL+FQC_CODBEM+FQC_CODFOR+FQC_SEQ
                        FQC->(DbGoTop())
                    Else
                        FQC->(DbSetOrder(1)) //FQC_FILIAL+FQC_CODCHE
                        FQC->(DbGoTop())
                        If FQC->(DbSeek(xFilial("FQC")+oJson:CodCheck))
                            lFQC := .T.
                            If Upper(Alltrim(FQC->FQC_STATUS)) == "FINALIZADO"
                                cRet := STR0003+oJson:CodCheck+STR0004+oJson:Placa+" - "+Alltrim(oJson:DescForm)+STR0005 //"ERRO-Check-list "###" placa: "###" já se encontra finalizado, não é possível alterá-lo, faça um novo!"
                            EndIf
                        Else
                            oJson:CodCheck := ""
                        EndIf
                    EndIf

                    If Empty(cRet)
                        cRet := xCLValid(oJson:FilBem,oJson:CodBem,oJson:CodForm, cCarroReserva, oJson:Contrato,oJson:Obra,oJson:NrAS,oJson:CentroCustoRetorno)
                    EndIf
                   
                    If Empty(cRet)
                        
                        If !lFQC
                            oJson:CodCheck  := GetSxeNum("FQC","FQC_CODCHE")
                            FQC->(dbSetOrder(1))
                        EndIf
                        
                        If Empty(cRet)
                            cKeyArq     := oJson:CodCheck//"CHECKLISTPDF_"+oJson:CodCheck+"_"+Replace(oJson:HrFim,":","")
                            cPDFArq     := "CHECKLISTPDF_"+Alltrim(cKeyArq)+"_"+oJson:DtIni+"_"+Replace(oJson:HrIni,":","")+".pdf"
                            cRet := xGAppArq(cPDFArq,oJson:ChecklistPdf)
                            If Empty(cRet) .AND. !Empty(oJson:ChecklistPdf)
                                cRet := xGAppConhec(cPDFArq,"CHECK-LIST PDF "+DtoC(StoD(oJson:DtIni))+" "+ oJson:HrIni,cKeyArq,"FQC")
                            EndIf
                        EndIf

                        If Empty(cRet)

                            //Se for CHECK-LIST DE ENTREGA E DEVOLUÇÃO
                            If oJson:CodForm == "2"
                                //Cria banco de conhecimento da foto do cliente autorizado
                                cKeyArq     := oJson:CodCheck//oJson:CodCheck+"_CLIENTEAUTORIZADO"
                                cNomeArq    := "CHECKLIST_"+Alltrim(cKeyArq)+"_CLIENTEAUTORIZADO.jpg"

                                cRet := xGAppArq(cNomeArq,oJson:ClienteAutorizado:Foto)
                            
                                If Empty(cRet) .and. !empty(oJson:ClienteAutorizado:Foto)
                                    cRet := xGAppConhec(cNomeArq,STR0006,cKeyArq,"FQC") //"FOTO CLIENTE AUTORIZADO"
                                EndIf

                                If Empty(cRet)
                                    //Cria banco de conhecimento da assinatura do cliente autorizado
                                    cKeyArq     := oJson:CodCheck//oJson:CodCheck+"_ASSINATURACLIENTEAUTORIZADO"
                                    cNomeArq    := "CHECKLIST_"+Alltrim(cKeyArq)+"_ASSINATURACLIENTEAUTORIZADO.jpg"
                                    If !empty(oJson:ClienteAutorizado:Assinatura)
                                        cRet := xGAppArq(cNomeArq,oJson:ClienteAutorizado:Assinatura)
                                        If Empty(cRet)
                                            cRet := xGAppConhec(cNomeArq,STR0007,cKeyArq,"FQC") //"ASSINATURA CLIENTE AUTORIZADO"
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf
                        EndIf

                        // Frank em 28/04/2025 - ISSUE 6573
                        If empty(cRet)
                            If ST9->T9_POSCONT > val(oJson:KM) .and. ST9->T9_POSCONT > 0
                                cRet := STR0008+alltrim(str(ST9->T9_POSCONT)) //"Falha na informação do contador do bem, está menor do que o existente. Contador atual: "
                            EndIf
                        EndIf

                        // Frank em 28/04/2025 - ISSUE 6573
                        If empty(cRet)
                            If (select("TRBFQC") > 0, TRBFQC->(DBCLOSEAREA()), .T.)
                            aBindParam := {}
                            cQuery := " SELECT FQC.R_E_C_N_O_ REG "
                            cQuery += " FROM " + RETSQLNAME("FQC") + " FQC (NOLOCK) "
                            cQuery += " WHERE "
                            cQuery += " FQC_FILIAL = '"+XFILIAL("FQC")+"' AND "
                            cTemp  := " FQC_CODCHE = '"+oJson:CodCheck+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_FILBEM = '"+oJson:FilBem+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_CODBEM = '"+oJson:CodBem+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_PLACA = '"+oJson:Placa+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_CODFOR = '"+oJson:CodForm+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_SEQ = '"+oJson:Seq+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_STATUS = '"+oJson:Status+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_MODELO = '"+oJson:Modelo+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_PROJET = '"+oJson:Contrato+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_OBRA = '"+oJson:Obra+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_AS = '"+oJson:NrAS+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_DTINI = '"+oJson:DtIni+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_HRINI = '"+substr(oJson:HrIni,1,5)+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_CLIAUT = '"+oJson:ClienteAutorizado:Nome+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_CNHAUT = '"+oJson:ClienteAutorizado:Cnh+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_EMAAUT = '"+oJson:ClienteAutorizado:Email+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_DHFAUT = '"+substr(oJson:ClienteAutorizado:DataHora,1,19)+"' AND "
                            &("cQuery += cTemp")
                            cTemp  := " FQC_STBEMA = '"+ST9->T9_STATUS+"' AND "
                            &("cQuery += cTemp")
                            cQuery += " FQC.D_E_L_E_T_ = '' "
                            cQuery := CHANGEQUERY(cQuery)
                            MPSysOpenQuery(cQuery,"TRBFQC",,,aBindParam)
                            If !TRBFQC->(Eof()) .or. file("\SYSTEM\LOCW02X0.TXT")
                                lDupl := .T.
                            EndIf
                            TRBFQC->(DBCLOSEAREA())
                        EndIf

                        begin transaction 
                            If Empty(cRet) .and. !lDupl
                                If RecLock("FQC",!lFQC)
                                    FQC->FQC_FILIAL := xFilial("FQC")
                                    FQC->FQC_CODCHE := oJson:CodCheck
                                    FQC->FQC_FILBEM := oJson:FilBem
                                    FQC->FQC_CODBEM := oJson:CodBem
                                    If !Empty(oJson:Placa)
                                        FQC->FQC_PLACA  := oJson:Placa
                                    EndIf    
                                    FQC->FQC_CODFOR := oJson:CodForm
                                    FQC->FQC_DESFOR := Posicione("FPJ",1,xFilial("FPJ")+oJson:CodForm,"FPJ_NOMFOR")
                                    FQC->FQC_SEQ    := oJson:Seq
                                    FQC->FQC_STATUS := oJson:Status
                                    FQC->FQC_POSCON := val(oJson:KM)
                                    FQC->FQC_MODELO := oJson:Modelo
                                    FQC->FQC_CODCLI := Posicione("FP0",1,xFilial("FP0")+Alltrim(oJson:Contrato),"FP0_CLI")
                                    FQC->FQC_LOJCLI := Posicione("FP0",1,xFilial("FP0")+Alltrim(oJson:Contrato),"FP0_LOJA")
                                    FQC->FQC_NOMCLI := Posicione("FP0",1,xFilial("FP0")+Alltrim(oJson:Contrato),"FP0_CLINOM")
                                    FQC->FQC_ESTADO := Posicione("FP0",1,xFilial("FP0")+Alltrim(oJson:Contrato),"FP0_CLIEST")
                                    FQC->FQC_CIDADE := Posicione("FP0",1,xFilial("FP0")+Alltrim(oJson:Contrato),"FP0_CLIMUN")
                                    FQC->FQC_PROJET := oJson:Contrato
                                    FQC->FQC_OBRA   := oJson:Obra
                                    FQC->FQC_AS     := oJson:NrAS
                                    lInicio := .T.
                                    FQC->FQC_DTINI := dDataBase//StoD(oJson:DtIni)
                                    FQC->FQC_HRINI := Time()//oJson:HrIni
                                    FQC->FQC_CLIAUT := oJson:ClienteAutorizado:Nome
                                    FQC->FQC_CNHAUT := oJson:ClienteAutorizado:Cnh
                                    FQC->FQC_EMAAUT := oJson:ClienteAutorizado:Email
                                    FQC->FQC_DHFAUT := oJson:ClienteAutorizado:DataHora
                                    FQC->FQC_CELAUT := Replace(Replace(Replace(Replace(oJson:ClienteAutorizado:Celular,"(",""),")","")," ",""),"-","")
                                    FQC->FQC_STBEMA := ST9->T9_STATUS
                                    cStaOld := Alltrim(Posicione("FQD",2,xFilial("FQD")+ST9->T9_STATUS,"FQD_STAREN"))
                                    FQC->FQC_FCHENT := xFilial("FQC")
                                    FQC->FQC_CCHENT := oJson:CodCheck
                                    FQC->FQC_OBS    := oJson:Observacao
                                    FQC->FQC_RESERV := cCarroReserva
                                    FQC->(MsUnLocK())

                                    // Frank em 28/04/2025 - ISSUE 6573
                                    // Se for devolução gravar o FPA_DTSCRT
                                    If lGravaTudo .and. ((!lLOCX067 .and. oJson:CodForm == "2") .or. file("\SYSTEM\LOCW02X1.TXT"))
                                        FPA->(dbSetOrder(3))
                                        If FPA->(dbSeek(xFilial("FPA")+oJson:NrAS)) .or. file("\SYSTEM\LOCW02X1.TXT")
                                            FPA->(RecLock("FPA",.F.))
                                            FPA->FPA_DTSCRT := dDataBase
                                            FPA->(MsUnlock())
                                        EndIf
                                    EndIf

                                    DbSelectArea("FPX")
                                    If FPX->(FIELDPOS("FPX_OBS")) > 0
                                        FPX->(DbSetOrder(2)) //FPX_FILIAL+FPX_CODCHE+FPX_CODTOP+FPX_CODITE+FPX_STAT2
                                    Else
                                        FPX->(DbSetOrder(1)) //FPX_FILIAL+FPX_CODCHE+FPX_CODTOP+FPX_CODITE+FPX_STATUS
                                    EndIf
                                    For nI := 1 To Len(oJson:Topicos)
                                        If Empty(cRet)
                                            For nX := 1 To Len(oJson:Topicos[nI]:Itens)
                                                If Empty(cRet)
                                                    aAC9Rec := {}
                                                    FPX->(DbGoTop())
                                                    //Se o item existir pendente anteriormente, flaga como 'Revisado' para historico
                                                    If FPX->(FIELDPOS("FPX_OBS")) > 0
                                                        If FPX->(DbSeek(xFilial("FPX")+FQC->FQC_CODCHE+oJson:Topicos[nI]:CodTop+oJson:Topicos[nI]:Itens[nX]:CodItem+"Pendente de vistoria"))
                                                            If RecLock("FPX",.F.)
                                                                FPX->FPX_STAT2 := "Revisado" // mantido sem ch por efeito de integração do WS
                                                                FPX->(MsUnLocK())
                                                            EndIf
                                                        EndIf
                                                    Else
                                                        If FPX->(DbSeek(xFilial("FPX")+FQC->FQC_CODCHE+oJson:Topicos[nI]:CodTop+oJson:Topicos[nI]:Itens[nX]:CodItem+"Pendente de vistoria"))
                                                            If RecLock("FPX",.F.)
                                                                FPX->FPX_STATUS := "Revisado" // mantido sem ch por efeito de integração do WS
                                                                FPX->(MsUnLocK())
                                                            EndIf
                                                        EndIf
                                                    EndIf
                                                    
                                                    If RecLock("FPX",.T.)
                                                        FPX->FPX_FILIAL := xFilial("FPX")
                                                        FPX->FPX_CODCHE := FQC->FQC_CODCHE
                                                        FPX->FPX_CODTOP := oJson:Topicos[nI]:CodTop
                                                        FPX->FPX_NOMTOP := oJson:Topicos[nI]:Nome
                                                        FPX->FPX_CODITE := oJson:Topicos[nI]:Itens[nX]:CodItem
                                                        FPX->FPX_NOMITE := oJson:Topicos[nI]:Itens[nX]:Nome
                                                        FPX->FPX_RESPOS := oJson:Topicos[nI]:Itens[nX]:Resposta
                                                        If FPX->(FIELDPOS("FPX_OBS")) > 0
                                                            FPX->FPX_STAT2 := oJson:Status
                                                        else
                                                            FPX->FPX_STATUS := oJson:Status
                                                        EndIf
                                                        FPX->FPX_DTINI  := StoD(oJson:DtIni)
                                                        FPX->FPX_HRINI  := oJson:HrIni
                                                        FPX->(MsUnLocK())
                                                    EndIf
                                                    
                                                    For nZ := 1 To Len(oJson:Topicos[nI]:Itens[nX]:Fotos)
                                                        If Empty(cRet)
                                                            cKeyArq     := FPX->FPX_CODCHE//+FPX->FPX_CODTOP+FPX->FPX_CODITE
                                                            cNomeArq    := "CHECKLIST_"+Alltrim(cKeyArq)+Alltrim(Str(nZ))+".jpg"
                                                            cResposta   := ""
                                                            If oJson:Topicos[nI]:Itens[nX]:Resposta == "C"
                                                                cResposta := "Conforme" // mantido sem ch por efeito de integração do WS
                                                            ElseIf oJson:Topicos[nI]:Itens[nX]:Resposta == "NC"
                                                                cResposta := "Não conforme" // mantido sem ch por efeito de integração do WS
                                                            Else
                                                                cResposta := "Não aplica" // mantido sem ch por efeito de integração do WS
                                                            EndIf

                                                            If !empty(oJson:Topicos[nI]:Itens[nX]:Fotos[nZ]:base64)
                                                                cRet := xGAppArq(cNomeArq,oJson:Topicos[nI]:Itens[nX]:Fotos[nZ]:base64)
                                                            
                                                                If Empty(cRet)
                                                                    cRet := xGAppConhec(cNomeArq,"FOTO "+Alltrim(Str(nZ))+" - "+Alltrim(oJson:Topicos[nI]:Nome)+" - "+Alltrim(oJson:Topicos[nI]:Itens[nX]:Nome)+" - "+cResposta,cKeyArq,"FPX")//FPX
                                                                    If Empty(cRet) .and. !empty(cNomeArq)
                                                                        //Cria banco de conhecimento das fotos do item no cabeçalho FPX pra abrir no banco de conhecimento
                                                                        cKeyArq := FPX->FPX_CODCHE
                                                                        cRet    := xGAppConhec(cNomeArq,"FOTO "+Alltrim(Str(nZ))+" ITEM - "+Alltrim(oJson:Topicos[nI]:Nome)+" - "+Alltrim(oJson:Topicos[nI]:Itens[nX]:Nome)+" - "+cResposta,cKeyArq,"FQC")
                                                                    EndIf
                                                                EndIf
                                                            EndIF
                                                        EndIf
                                                    Next nZ

                                                EndIf
                                            Next nX
                                        EndIf
                                    Next nI
                                    
                                    If Empty(cRet)
                                        If !lFQC
                                            ConfirmSx8()
                                        EndIf
                                        
                                        //SE FOR CHECK-LIST DE ENTREGA E DEVOLUÇÃO
                                        If Alltrim(oJson:CodForm) == "2" 
                                    
                                            If cStaOld == "20"
                                                aFQCarea := FQC->(GetArea())
                                                cStaAnt := Alltrim(Posicione("FQD",1,xFilial("FQD")+"10","FQD_STATQY"))
                                                
                                                cQuery := "SELECT FQC.R_E_C_N_O_ RECNO "
                                                cQuery += "FROM "+RetSqlName("FQC")+" FQC "
                                                cQuery += " WHERE FQC_FILIAL = '" +xFilial("FQC") + "' "
                                                cQuery += " AND FQC.D_E_L_E_T_ = ' ' "	
                                                cQuery += " AND FQC_CODFOR = '2' "
                                                cQuery += " AND FQC_CODBEM = ? "	
                                                cQuery += " AND FQC_STBEMA = ? "
                                                cQuery += " ORDER BY FQC_CODCHE DESC "
                                                aadd(aBindParam,oJson:CodBem)
                                                aadd(aBindParam,cStaAnt)						

                                                //TcQuery cQuery New Alias "TRBFQC"
                                                cQuery := CHANGEQUERY(cQuery)
                                                MPSysOpenQuery(cQuery,"TRBFQC",,,aBindParam)	
                                                FQC->(DbGoTo(TRBFQC->RECNO))
                                                If !TRBFQC->(EoF())
                                                    RecLock("FQC",.F.)                                    
                                                    FQC->FQC_FCHENT := xFilial("FQC")
                                                    FQC->FQC_CCHENT := oJson:CodCheck
                                                    FQC->(MsUnLocK())   
                                                EndIf                      
                                                FQC->(RestArea(aFQCarea))                    
                                            Endif
                                                                            
                                        EndIf

                                        If lGravaTudo
                                            cRet := xCLFinaliza(oJson:CodBem,oJson:Status,oJson:CodForm,oJson:CentroCustoRetorno,"FQC",lInicio, oJson:KM)
                                        EndIf
                                        
                                    EndIf
                                EndIf
                            EndIf
                        end transaction 
                    EndIf
                EndIf
            EndIf

		EndIf
	End Sequence

	ErrorBlock(bError)
	If !Empty(cEnvLog)
		cRet := "ERRO-"+cEnvLog
	EndIf

	If Empty(cRet)
		cRet := "OK"
	EndIf                            
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" ,"CodCheck": "'+oJson:CodCheck+'", "Placa":"'+oJson:Placa+'", "CodForm": "'+oJson:CodForm+'"}')) )
	
Return (.T.)

/*/{Protheus.doc} xCLValid
Função que valida o check-list, podendo ser chamado via APP ou manualmente via ERP
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/
Function xCLValid(cFilBem,cCodBem,cCodForm,cCarroReserva,cContrato,cObra,cNrAS,cCentroCustoRetorno)
Local cRet      := ""

    If Empty(cCodBem)
        cRet := STR0009 //"ERRO-Não foi possível encontrar o código do veículo(ST9)"
    Else
        DbSelectArea("ST9")
        ST9->(DbSetOrder(1))
        ST9->(DbGoTop())
        If ST9->(DbSeek(xFilial("ST9")+cCodBem))
            DbSelectArea("FPA")
            FPA->(DbSetOrder(2)) //FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_AS+FPA_VIAGEM
            FPA->(DbGoTop())
            If FPA->(DbSeek(xFilial("FPA")+PadR(cContrato,TamSX3("FPA_PROJET")[1])+PadR(cObra,TamSX3("FPA_OBRA")[1])+PadR(cNrAS,TamSX3("FPA_AS")[1])))
                cCustoFPA := FPA->FPA_CUSTO
            EndIf
        Else
            cRet := STR0009+cCodBem //"ERRO-Não foi possível encontrar o veículo(ST9) "
        EndIf
    EndIf
    If Empty(cRet)
        FQD->(DBSETORDER(2))
        FQD->(DBSEEK(XFILIAL("FQD")+ST9->T9_STATUS))    
        If Alltrim(cCodForm) == "2" //CHECK-LIST DE ENTREGA E DEVOLUÇÃO
            //Se for carro reserva previsa estar inicialmente disponivel, ou no status 10 ou 20
            If(cCarroReserva == "S" .AND. Alltrim(FQD->FQD_STAREN) == "00")
                
            ElseIf Alltrim(FQD->FQD_STAREN) != "10" .AND. Alltrim(FQD->FQD_STAREN) != "20"
                cRet := STR0010+Alltrim(Posicione("TQY",1,xFilial("TQY")+"10","TQY_DESTAT"))+" ou 20-"+Alltrim(Posicione("TQY",1,xFilial("TQY")+"20","TQY_DESTAT")) //"ERRO-Veículo não se encontra com status 10-"
            EndIf
        ElseIf Alltrim(cCodForm) == "3" //CHECK-LIST DE TRANSPORTE
            If Alltrim(FQD->FQD_STAREN) != "10"
                cRet := STR0010+Alltrim(Posicione("TQY",1,xFilial("TQY")+"10","TQY_DESTAT")) //"ERRO-Veículo não se encontra com status 10-"
            EndIf
        EndIf
    EndIf

Return (cRet)

/*/{Protheus.doc} xCLFinaliza
Função para finalizar o check-list
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/
Function xCLFinaliza(cCodBem,cStatus,cCodForm,cCentroCustoRetorno,cAlias,lInicio,nKm)
Local cRet := ""
    FQD->(DBSETORDER(2))
    FQD->(DBSEEK(XFILIAL("FQD")+ST9->T9_STATUS))
    If lInicio
        If Alltrim(cCodForm) == "3" //CHECK-LIST DE TRANSPORTE
            //Gera substatus de Aguardando transporte
            If Alltrim(FQD->FQD_STAREN) == "10"
                xCLGSubStatus("01",cAlias)
            EndIf
        EndIf
    EndIf

    //Se checklist tiver sido finalizado, ou seja, todos os itens conformes ou como não se aplica
    If Upper(Alltrim(cStatus)) == "FINALIZADO" // mantido sem CH para efeito de integração com o WS
        If Alltrim(cCodForm) == "1" //PREPARAÇÃO QA
            //Gera substatus de Preparado
            If Alltrim(FQD->FQD_STAREN) == "10"
                xCLGSubStatus("02",cAlias)
            EndIf
        ElseIf Alltrim(cCodForm) == "3" //CHECK-LIST DE TRANSPORTE
            //Gera substatus de Aguardando cliente
            If Alltrim(FQD->FQD_STAREN) == "10"
                xCLGSubStatus("03",cAlias)
            EndIf
        ElseIf Alltrim(cCodForm) == "2" //CHECK-LIST DE ENTREGA E DEVOLUÇÃO
            If (&(cAlias+"->FQC_RESERV") == "S" .AND. Alltrim(FQD->FQD_STAREN) == "00") .OR. Alltrim(FQD->FQD_STAREN) == "10"
                FQD->(DBSETORDER(1))
                FQD->(DBSEEK(XFILIAL("FQD")+"20"))
                cRet := xCLGStatus(ST9->T9_STATUS,FQD->FQD_STATQY,cAlias,nKm)

                // Frank em 30/04/2025 - DSERLOCA-6597
                FPA->(dbSetOrder(3))
                If FPA->(dbSeek(xFilial("FPA")+oJson:NrAS))
                    FPA->(RecLock("FPA",.F.))
                    FPA->FPA_DNFENT := StoD(oJson:DtFim)
                    FPA->(MsUnlock())
                EndIf
            ElseIf Alltrim(FQD->FQD_STAREN) == "20"
                FQD->(DBSETORDER(1))
                FQD->(DBSEEK(XFILIAL("FQD")+"50"))            
                cRet := xCLGStatus(ST9->T9_STATUS,FQD->FQD_STATQY,cAlias,nKm)
                If Empty(cRet) .AND. !Empty(cCentroCustoRetorno)
                    If &(cAlias+"->FQC_RESERV") == "S"
                        xCLGSubStatus("04",cAlias)
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

Return (cRet)

/*/{Protheus.doc} xCLGStatus
Função para gerar status a partir do status antigo para o status novo conforme o check-list
@type function
@author Frank Zwarg Fuga
@since 16/09/2025
/*/
Function xCLGStatus(_cStsOld,_cStsNew,cAlias,nKm)
Local _cSeq     := ""
Local _cLog     := ""
Local cNomOld   := Alltrim(Posicione("FQD",2,xFilial("FQD")+_cStsOld,"FQD_DESTQY"))
Local cNomNew   := Alltrim(Posicione("FQD",2,xFilial("FQD")+_cStsNew,"FQD_DESTQY"))
Local cRet      := ""

    nKm := val(nKm)

    DbSelectArea("SHB")
    SHB->(DbSetOrder(1))
    SHB->(dbSeek( xFilial("SHB") + ST9->T9_CENTRAB )) 		// --> Para pegar o nome do centro de trabalho
    DbSelectArea("FP1")
    FP1->(DbSetOrder(1))
    FP1->(dbSeek( xFilial("FP1") + PadR(Alltrim(&(cAlias+"->FQC_PROJET")),TamSx3("FP1_PROJET")[1]) + PadR(Alltrim(&(cAlias+"->FQC_OBRA")),TamSx3("FP1_OBRA")[1])))
    DbSelectArea("FP0")
    FP0->(DbSetOrder(1))
    FP0->(dbSeek( xFilial("FP0") + PadR(Alltrim(&(cAlias+"->FQC_PROJET")),TamSx3("FP0_PROJET")[1])))
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(dbSeek( xFilial("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA ))

    FPJ->(DbSetOrder(1))
    FPJ->(dbSeek( xFilial("FPJ") + ALLTRIM(&(cAlias+"->FQC_CODFOR")) ))    

    FPA->(DbSetOrder(1))
    FPA->(dbSeek( xFilial("FP1") + PadR(Alltrim(&(cAlias+"->FQC_PROJET")),TamSx3("FP1_PROJET")[1]) + PadR(Alltrim(&(cAlias+"->FQC_OBRA")),TamSx3("FP1_OBRA")[1])))

    FQD->(DBSETORDER(2))
    FQD->(DBSEEK(XFILIAL("FQD")+_cStsNew))
    _cSeq := GetSx8Num("FQ4","FQ4_SEQ") // FQ4_SEQ campo inexistente
    ConfirmSx8()
    
    _cLog := STR0011 + AllTrim(ST9->T9_CODBEM) +; //"BEM "
              " - " + AllTrim(ST9->T9_NOME) +;
              STR0012+ _cStsOld+"-"+cNomOld +; //" - STATUS: "
              STR0013+ Alltrim(&(cAlias+"->FQC_PROJET")) +; //" - CHECKLIST - CONTRATO: "
              STR0014 + Alltrim(&(cAlias+"->FQC_OBRA"))+; //" - OBRA: "
              STR0015+ _cStsNew+"-"+cNomNew  +; //" - STATUS ATUAL: "
              " - " + Alltrim(&(cAlias+"->FQC_NOMUSF")) +;
              " - " + dtoc(dDataBase) + "-" + time()
    
    If RecLock("ST9",.F.)
    
        ST9->T9_STATUS := _cStsNew
        ST9->(MsUnLocK())

        If RecLock("FQ4",.T.)
            FQ4->FQ4_FILIAL := xFilial("FQ4")
            FQ4->FQ4_CODBEM := ST9->T9_CODBEM
            FQ4->FQ4_NOME	:= ST9->T9_NOME
            FQ4->FQ4_STSOLD := _cStsOld
            FQ4->FQ4_STATUS := _cStsNew
            FQ4->FQ4_DESTAT := cNomNew  
            FQ4->FQ4_CODFAM := ST9->T9_CODFAMI
            FQ4->FQ4_TIPMOD := ST9->T9_TIPMOD
            FQ4->FQ4_FABRIC := ST9->T9_FABRICA
            If ST9->T9_TERCEIR == '1'
                FQ4->FQ4_SUBLOC := "N"
            Endif    
            If ST9->T9_TERCEIR == '2'
                FQ4->FQ4_SUBLOC := "S"
            Endif                
            FQ4->FQ4_POSCON         := &(cAlias+"->FQC_POSCON")
            FQ4->FQ4_CENTRA         := ST9->T9_CENTRAB
            FQ4->FQ4_NOMTRA         := SHB->HB_NOME
            FQ4->FQ4_OS		        := ""
            If FQD->FQD_STAREN == "20"
                FQ4->FQ4_TPSERV     := "CHECKLIST SAIDA"//FPJ->FPJ_NOMFOR//Posicione("FPJ",1,xFilial("FPJ")+&(cAlias+"->FQC_CODFOR"),"FPJ_NOMFOR")
            EndIf    
            If FQD->FQD_STAREN == "50"
                FQ4->FQ4_TPSERV     := "CHECKLIST ENTRADA"//FPJ->FPJ_NOMFOR//Posicione("FPJ",1,xFilial("FPJ")+&(cAlias+"->FQC_CODFOR"),"FPJ_NOMFOR")
            EndIf                
        	FQ4->FQ4_PRELIB         := SubStr(DTOC(&(cAlias+"->FQC_DTINI")),1,2)+ "/" + SubStr(DTOC(&(cAlias+"->FQC_DTINI")),4,2)+ "/" + SubStr(DTOC(&(cAlias+"->FQC_DTINI")),9,2)//DTOC(&(cAlias+"->FQC_DTINI"))//_dPreLib
            FQ4->FQ4_DOCUME         := SubStr(&(cAlias+"->FQC_CODCHE"), 2, 9)//&(cAlias+"->FQC_CODCHE")
            FQ4->FQ4_SERIE          := ""
            FQ4->FQ4_CODCLI         := FP1->FP1_CLIORI
            FQ4->FQ4_LOJCLI         := FP1->FP1_LOJORI
            FQ4->FQ4_NOMCLI         := FP1->FP1_NOMORI
            FQ4->FQ4_CODMUN         := SA1->A1_COD_MUN
            FQ4->FQ4_MUNIC          := SA1->A1_MUN
            FQ4->FQ4_EST	        := SA1->A1_EST
            FQ4->FQ4_PROJET         := &(cAlias+"->FQC_PROJET")
            FQ4->FQ4_OBRA           := &(cAlias+"->FQC_OBRA")
            FQ4->FQ4_AS		        := &(cAlias+"->FQC_AS")
            FQ4->FQ4_PREDES         := FPA->FPA_DTSCRT
            FQ4->FQ4_DTINI          := FPA->FPA_DTINI//&(cAlias+"->FQC_DTINI")
            FQ4->FQ4_DTFIM          := FPA->FPA_DTFIM//&(cAlias+"->FQC_DTFIM")
            FQ4->FQ4_LOG	        := _cLog
            FQ4->FQ4_SEQ            := _cSeq
            FQ4->(MsUnLock())
        EndIf
    EndIf

    If FQD->FQD_STAREN == "20"
        RecLock("FQC",.F.)
        FQC->FQC_FCHENT := ""
        FQC->FQC_CCHENT := ""
        FQC->(MsUnLock())         
    EndIf

    // Atualização do contador no MNT
    NGTRETCON(ST9->T9_CODBEM,dDataBase,nKm,time(),1,,,"A",xFilial("ST9"))
    
Return (cRet)

/*/{Protheus.doc} xCLGSubStatus
Função para gerar sub-status a partir de um status amarrado ao substatus do app novo conforme o check-list
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/
Function xCLGSubStatus(cSubStatus,cAlias)
    DbSelectArea("FQE")
    FQE->(DbSetOrder(RetOrder("FQE","FQE_FILIAL+FQE_XSUBAP")))
    FQE->(DbGoTop())
    If FQE->(DbSeek(xFilial("FQE")+cSubStatus))
        If Reclock("FQF",.T.)    
            FQF->FQF_FILIAL := xFilial("FQF")
            FQF->FQF_CODBEM := &(cAlias+"->FQC_CODBEM")
            FQF->FQF_CC     := cCustoFPA
            FQF->FQF_DTINI  := Iif(Empty(&(cAlias+"->FQC_DTFIM")),&(cAlias+"->FQC_DTINI"),&(cAlias+"->FQC_DTFIM"))
            FQF->FQF_HORA   := Iif(Empty(&(cAlias+"->FQC_HRFIM")),&(cAlias+"->FQC_HRINI"),&(cAlias+"->FQC_HRFIM"))
            FQF->FQF_STATUS := ST9->T9_STATUS
            FQF->FQF_SUBST  := FQE->FQE_CODIGO //cSubStatus
            FQF->FQF_AS     := &(cAlias+"->FQC_AS")
            FQF->FQF_PROJET := &(cAlias+"->FQC_PROJET")
            FQF->(MsUnLocK())
        EndIf
    EndIf
Return (Nil)

/*/{Protheus.doc} PDFemB64
Converter um arquivo em base 64
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/
Function PDFemB64(bodyHtml)
Local alHeader      := {}
Local olRest        := Nil
Local nlStatus      := 0
Local clMsg         := ""
Local llRet         := .F.
Local clURL         := "https://54.233.82.163/api/index.php"
    
    //Cabeçalho de requisição
    aAdd(alHeader,"Content-Type: base64")
    olRest := FWRest():New(clURL)
    olRest:setPath("/index.php")
    olRest:SetPostParams(bodyHtml)
    olRest:SetChkStatus(.F.)

    If olRest:Post(alHeader)
        clMsg       := ""
        nlStatus    := HTTPGetStatus(@clMsg)
        
        If nlStatus >= 200 .And. nlStatus <= 299
            llRet := .T.
            clMsg := olRest:getResult()
        endIf
    EndIf
    
Return {llRet,clMsg}

/*/{Protheus.doc} xGAppArq
Copiar localmente o arquivo base 64
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/
Function xGAppArq(cNomeArq,cBase64,cPathBco)
Local cRet      := ""
Local cDirDoc   := Alltrim(GetMv("MV_DIRDOC"))
Local nHandle   := 0
Local cComando  :=  ""
Default cPathBco  := ""

    If Empty(cPathBco)
        //Se o ultimo caracter nao for uma \, acrescenta ela, e depois configura o diretorio com a subpasta co01\shared
        If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
            cDirDoc := cDirDoc + "\"
        EndIf
        cPathBco := cDirDoc + "co" + cEmpAnt + "\shared\"
    EndIf

    If File(cPathBco+cNomeArq)
        FERASE(cPathBco+cNomeArq)
    EndIf

    //Cria arquivo na system
    cComando := "nHandle := fcreate(cNomeArq)"
    &(cComando)

    cTexto := Encode64(cBase64)
    FWrite(nHandle, Decode64(cBase64))
    fclose(nHandle)
        
    //Faz a cópia da origem, para a pasta do banco de conhecimento
    cComando := '__CopyFile(cNomeArq, cPathBco + cNomeArq)'
    &(cComando)

    //Exclui o arquivo da origem System
    FERASE(cNomeArq)

Return (cRet)

/*/{Protheus.doc} xGAppConhec
Criação do banco de conhecimento
@type function
@author Dennis Calabrez
@since 16/09/2025
/*/
Function xGAppConhec(cNomeArq,cDescArq,cKeyArq,cTab)
Local cRet     := ""
Local cCodObj  := ""
Local lExists  := .F.

    ACB->(DbGoTop())
    ACB->(DbSetOrder(2))
    
    //Se não tiver o arquivo na ACB, irá incluir
    If ACB->(DbSeek(FWxFilial('ACB') + cNomeArq))
        lExists     := .T.
        cCodObj     := ACB->ACB_CODOBJ
    Else
        cCodObj := GetSxeNum("ACB","ACB_CODOBJ")//StrZero((Val(GetSxeNum("ACB","ACB_CODOBJ")) + 1), 10) //Pega o próximo registro da ACB
        ACB->(dbSetOrder(1))
        If !ACB->(dbSeek(xFilial("ACB")+cCodObj)) .and. !file("\SYSTEM\LOCW002ERR.TXT")
            If Reclock("ACB", .T.)
                ACB->ACB_FILIAL := FWxFilial('ACB')
                ACB->ACB_CODOBJ := cCodObj
                ACB->ACB_OBJETO := cNomeArq
                ACB->ACB_DESCRI := cDescArq
                ACB->(MsUnlock())
            EndIf
        Else
            cRet := "Erro na geração da numeração do sequencial no campo ACB_CODOBJ"
        EndIf
    EndIf

    If Empty(cRet)
        //Se não existir na tabela de vinculos, irá criar
        DbSelectArea("AC9")
        AC9->(DbGoTop())
        AC9->(DbSetOrder(1))
        If !AC9->(DbSeek(FWxFilial('AC9') + cCodObj +cTab+FWxFilial(cTab)+ cKeyArq))
            If Reclock("AC9", .T.)
                AC9->AC9_FILIAL := FWxFilial('AC9')
                AC9->AC9_FILENT	:= FWxFilial(cTab)
                AC9->AC9_ENTIDA := cTab
                AC9->AC9_CODENT := xFilial("FPX")+cKeyArq
                AC9->AC9_CODOBJ := cCodObj
                AC9->(MsUnlock())
            EndIf
        EndIf
    EndIf

    If !lExists
        If Empty(cRet)
            ConfirmSx8()
        EndIf
    EndIf

Return (cRet)

/*/{Protheus.doc} LOCW002A
Atualiza o campo FPX_STAT2
@type function
@author Frank Zwarg Fuga
@since 6/13/2025
Houve a troca do campo de FPX_STATUS para FPX_STAT2 por questão do banco de conhecimento vs X2_UNICO
/*/
Function LOCW002A
Local cQuery := ""
    
    If select("TRBFPX") > 0
        TRBFPX->(dbCloseArea())
    ENDIF

    cQuery := " SELECT FPX.R_E_C_N_O_ REG "
    cQuery += " FROM " + RetSqlName("FPX") + " FPX "
    cQuery += " WHERE FPX.D_E_L_E_T_ = '' AND FPX.FPX_STATUS <> '' AND FPX.FPX_STAT2 = '' "
    cQuery := changeQuery(cQuery)
    MPSysOpenQuery(cQuery,"TRBFPX",,,)
    While !TRBFPX->(Eof())
        FPX->(dbGoto(TRBFPX->REG))
        FPX->(RecLock("FPX",.F.))
        FPX->FPX_STAT2 := FPX->FPX_STATUS
        FPX->(MsUnlock())
        TRBFPX->(dbSkip())
    EndDo
    TRBFPX->(dbCloseArea())

Return

