#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraInsu    ³ Autor ³ Rafael P Goncalves ³ Data ³22.04.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Método responsável por gerar a ordem de serviço            ³±±
±±³Descricao ³ integrado com o portal do fornecedor                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL GeraInsu DESCRIPTION "Gera ordem de serviço integrado com o portal do fornecedor"

	WSMETHOD POST DESCRIPTION "<h2>Método responsável por gerar a ordem de serviço integrado com o portal do fornecedor</h2>" WSSYNTAX "/GeraInsu"

END WSRESTFUL



WSMETHOD POST WSSERVICE GeraInsu
	
Local aEmp          := {}
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent()) //::GetContent()
Local oJson			:= Nil
Local aArq          := ""
Local cTipoArq      := ""
Local cKeyArq       := ""
Local cNomeArq      := ""
Local nI            := 0 
Local cRet          := ""
Local nY            := 0 
Local lRet          := .T.
Local cCodigo       := ""
Local cCod          := ""
Private cNumOs      := ""
Private nAnexos     := 0

	
	::SetContentType("application/json; charset=iso-8859-1")
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp5(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            If (aEmp[3] == "Empresa já existente.")
                cRet := xAbreEnv5(aEmp[1],aEmp[2])
                If Empty(cRet)
                    cNumOs      := oJson:num_os
                    cCodigo := GERSEQTAR(oJson:num_os)
                    ccod    := GERSEQSTL(oJson:num_os)
                    //Se tiver anexo no cabeçalho da OS
                    dbSetOrder(1)
                    For nI := 1 To Len(oJson:Itens)     
                        If oJson:Itens[nI]:TipoInsumo <> "P"
                            cRet := "O Insumo "+oJson:Itens[nI]:CodInsumo+" nao pode ser inserido, pois nao e do Tipo P=Produto, esse insumo não foi inserido, escolha outro insumo e refaca o processo para inserir o mesmo"
                            lRet := .F.
                        EndIf               
                        If Len(oJson:Itens[nI]:Anexos) > 0
                            //Faz a gravação dos anexos que vem no cabeçalho da OS
                            For nY := 1 To Len(oJson:Itens[nI]:Anexos)
                                If Empty(cRet)
                                    nAnexos++
                                    aArq        := STRTOKARR(oJson:Itens[nI]:Anexos[nY]:name,".")
                                    cTipoArq    := Lower(aArq[Len(aArq)])
                                    cKeyArq     := PadR(cNumOs,TamSX3("TJ_ORDEM")[1])
                                    //cNomeArq    := "ANEXO_"+cValtoChar(nAnexos)+"_"+xFilial("STJ")+PadR(cNumOs,TamSX3("TJ_ORDEM")[1])+"."+cTipoArq
                                    cNomeArq    := "ANEXO_"+cValtoChar(nAnexos)+"_"+PadR(cNumOs,TamSX3("TJ_ORDEM")[1])+"."+cTipoArq
                                    cRet := xGAppArq(cNomeArq,oJson:Itens[nI]:Anexos[nY]:base64)

                                    If Empty(cRet)
                                        cRet := xGAppConhec(cNomeArq,"ANEXO "+cValtoChar(nAnexos),cKeyArq,"STJ")
                                    EndIf
                                EndIf
                            Next nY
                        EndIf
                    //dbSetOrder(1)
                        If lRet
                            RecLock("STL",.T.)

                                STL->TL_FILIAL  := xFilial("STL")
                                STL->TL_ORDEM   := cNumOS
                                STL->TL_PLANO   := "000000"
                                STL->TL_SEQRELA := "0"
                                STL->TL_TAREFA  := "0"
                                STL->TL_TIPOREG := oJson:Itens[nI]:TipoInsumo//"P"
                                STL->TL_CODIGO  := oJson:Itens[nI]:CodInsumo
                                STL->TL_USACALE := "N"
                                STL->TL_QUANTID := VAL(oJson:Itens[nI]:Qtd)
                                If STL->TL_TIPOREG == "P"
                                    STL->TL_UNIDADE := Posicione("SB1",1,xFilial("SB1")+STL->TL_CODIGO,"B1_UM")
                                EndIf
                                STL->TL_LOCAL := Posicione("SB1",1,xFilial("SB1")+STL->TL_CODIGO,"B1_LOCPAD")
                                STL->TL_CUSTO   := val(oJson:Itens[nI]:VlrUnit)//STL->TL_XVLRUNI
                                STL->TL_DESTINO := oJson:Itens[nI]:Destino
                                STL->TL_DTINICI := STJ->TJ_DTMPINI
                                STL->TL_HOINICI := STJ->TJ_HOMPINI
                                STL->TL_DTFIM   := STJ->TJ_DTMPFIM
                                STL->TL_HOFIM   := STJ->TJ_HOMPFIM
                                STL->TL_LOCAL   := "01"
                                STL->TL_SEQTARE := cCod//StrZero(nI, TamSX3("TL_SEQTARE")[1])
                                
                                STL->(MsUnLocK())   
                            
                            RecLock("FH1",.T.)

                                FH1->FH1_FILIAL := xFilial("STL")
                                FH1->FH1_ORDEM  := cNumOS
                                FH1->FH1_PLANO  := "000000"
                                FH1->FH1_TAREFA := "0"
                                FH1->FH1_TIPORE := oJson:Itens[nI]:TipoInsumo//"P"
                                FH1->FH1_CODIGO := oJson:Itens[nI]:CodInsumo
                                FH1->FH1_SEQREL := "0"
                                FH1->FH1_SEQTAR := cCodigo//StrZero(50, TamSX3("FH1_SEQTAR")[1])
                                FH1->FH1_CODFOR := oJson:Itens[nI]:CodForn
                                FH1->FH1_LOJFOR := oJson:Itens[nI]:LojForn
                                FH1->FH1_STAPRO := "1"//Status Aprovação -> 1=PENDENTE;2=APROVADO;3=REPROVADO
                                //FH1->FH1_CODAPR := oJson:Itens[nI]:CodApr
                                //FH1->FH1_NOMAPR := oJson:Itens[nI]:NomApr
                                //FH1->FH1_OBSREJ := oJson:Itens[nI]:Observacao
                                //FH1->FH1_DTAPRO := oJson:Itens[nI]:DtApro
                                //FH1->FH1_HRAPRO := oJson:Itens[nI]:HrApro
                                //FH1->FH1_DTENC  := oJson:Itens[nI]:DtEnc
                                //FH1->FH1_HRENC  := oJson:Itens[nI]:HrEnc
                                //FH1->FH1_PEDCOM := oJson:Itens[nI]:PedCom
                                FH1->FH1_QUANTI := VAL(oJson:Itens[nI]:Qtd)
                                FH1->FH1_VLRUNI := val(oJson:Itens[nI]:VlrUnit)
                                FH1->FH1_VLRTOT := val(oJson:Itens[nI]:VlrTotal)
                                //FH1->FH1_VLRAUN := val(oJson:Itens[nI]:VlUnApr)//Vlr Unitario Aprovado
                                //FH1->FH1_VLRATO := val(oJson:Itens[nI]:VlTotApr)//Vlr Total Aprovado
                                //FH1->FH1_CODFIN := oJson:Itens[nI]:CodFinGer//Cod Finalidade Gerencial 
                                //FH1->FH1_DESFIN := oJson:Itens[nI]:Qtd//Desc Finalidade Gerencial
                                //FH1->FH1_COBRA  := oJson:Itens[nI]:Cobra
                                //FH1->FH1_CUSEX  := VAL(oJson:Itens[nI]:CusExtra)//Vlr Custo Extra
                                
                                FH1->(MsUnLocK())  
                        EndIf                                 
                    Next  
                EndIf
            EndIf
		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
    If lRet
	    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "NumOs": "'+cNumOs+'"}')) )
    Else
        ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"}')) )
    EndIf    
	//conout("TERMINO-Consumido o WebService GeraOs - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return (.T.)

Function GERSEQTAR(cOs)
Local cCodigo  := "000"   
Local aArea    := GetArea()

	FH1->(dbSetOrder(1))
	FH1->(dbSeek(xFilial("FH1")+cOs))
	While !FH1->(Eof()) .and. FH1->FH1_FILIAL == xFilial("FH1") .AND. ALLTRIM(FH1->FH1_ORDEM) == cOs
		cCodigo := FH1->FH1_SEQTAR
		FH1->(dbSkip())
	EndDo

	cCodigo := Soma1( cCodigo )
	
RestArea(aArea)

Return cCodigo 

Function GERSEQSTL(cOs)
Local cCod  := "000"   
Local aArea    := GetArea()

	STL->(dbSetOrder(1))
	STL->(dbSeek(xFilial("STL")+cOs))
	While !STL->(Eof()) .and. STL->TL_FILIAL == xFilial("STL") .AND. ALLTRIM(STL->TL_ORDEM) == cOs
		cCod := STL->TL_SEQTARE
		STL->(dbSkip())
	EndDo

	cCod := Soma1( cCod )
	
RestArea(aArea)

Return cCod 
