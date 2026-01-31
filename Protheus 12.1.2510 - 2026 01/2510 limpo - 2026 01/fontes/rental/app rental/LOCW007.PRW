#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetChecklist³ Autor ³ Rafael P Goncalves ³ Data ³09.08.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo que retorna o checklist em aberto                   ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL RetChecklist DESCRIPTION "Retorna o checklist em aberto pela placa"

	WSMETHOD POST DESCRIPTION "<h2>Metodo que retorna o checklist em aberto pela placa.</h2>" WSSYNTAX "/RetChecklist"

END WSRESTFUL



WSMETHOD POST WSSERVICE RetChecklist
	
	Local cDtIni		:= DtoC(Date())
	Local cHrIni		:= Time()
	Local cEnvLog  		:= ""
	Local bError    	:= {||}
    Local cRet          := ""
    Local cDados        := ' , "Dados" :'
    Local cAux          := ""
    Local cAux2         := ""
    Local cBody			:= DecodeUtf8(::GetContent())
    Local oJson         := Nil
    Local lFQC          := .F.
    Local lCont         := .T.

	//conout("INICIO-Consumido o WebService RetChecklist - Data e Hora Inicial "+cDtIni+" - "+cHrIni) 
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
        If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
            If at("existente",aEmp[3]) > 0 //(aEmp[3] == "Empresa já existente.")//cRet := ""//U_xAbreEnv("01",oJson:FilOs)
                cRet := xAbreEnv1(aEmp[1],aEmp[2])
                If Empty(cRet)

                    // Troca do campo sobre status da FPX
                    If FindFunction( "LOCW002A" ) .and. FPX->(FIELDPOS("FPX_OBS")) > 0
                        LOCW002A()
                    EndIf

                    DbSelectArea("FQC")
                    If oJson:Tipo == "Em aberto"
                        FQC->(DbSetOrder(2))
                        lFQC := FQC->(DbSeek(xFilial("FQC")+PadR(Alltrim(oJson:cCodBem),TamSX3("FQC_CODBEM")[1])+PadR(Alltrim(oJson:cCodForm),TamSX3("FQC_CODFOR")[1])+oJson:cSeq+"Pendente de vistoria"))
                    Else
                        FQC->(DbSetOrder(1))
                        lFQC := FQC->(DbSeek(xFilial("FQC")+oJson:CodCheck))
                    EndIf
                    If lFQC
                        cDados += ' {'
                        cDados += ' "KM":'+Alltrim(cValToChar(FQC->FQC_POSCON))+','
                        cDados += ' "Modelo": "'+Alltrim(FQC->FQC_MODELO)+'",'
                        cDados += ' "CodCliente": "'+Alltrim(FQC->FQC_CODCLI)+'",'
                        cDados += ' "LojaCliente": "'+Alltrim(FQC->FQC_LOJCLI)+'",'
                        cDados += ' "NomeCliente": "'+Alltrim(FQC->FQC_NOMCLI)+'",'
                        cDados += ' "Contrato": "'+Alltrim(FQC->FQC_PROJET)+'",'
                        cDados += ' "Obra": "'+Alltrim(FQC->FQC_OBRA)+'",'
                        cDados += ' "NrAS": "'+Alltrim(FQC->FQC_AS)+'",'
                        cDados += ' "Estado": "'+Alltrim(FQC->FQC_ESTADO)+'",'
                        cDados += ' "Cidade": "'+Alltrim(FQC->FQC_CIDADE)+'",'
                        cDados += ' "CodCheck": "'+Alltrim(FQC->FQC_CODCHE)+'",'
                        //cDados += ' "NivelCombustivel": "'+Alltrim(Str(FQC_NIVELC))+'",'
                        cDados += ' "Observacao": "'+Alltrim(Encode64(FQC->FQC_OBS))+'",'
                        cDados += ' "Itens": ['
                        DbSelectArea("FPX")
                        FPX->(DbSetOrder(1))
                        FPX->(DbGoTop())
                        If FPX->(DbSeek(xFilial("FPX")+FQC->FQC_CODCHE))
                            While FPX->(!EoF()) .AND. FPX->FPX_FILIAL+FPX->FPX_CODCHE == xFilial("FPX")+FQC->FQC_CODCHE
                                If FPX->(FIELDPOS("FPX_OBS")) > 0
                                    If oJson:Tipo == "Em aberto"
                                        lCont := (Alltrim(FPX->FPX_STAT2) == "Pendente de vistoria")
                                    Else
                                        lCont := (Upper(Alltrim(FPX->FPX_STAT2)) == "FINALIZADO")
                                    EndIf
                                Else
                                    If oJson:Tipo == "Em aberto"
                                        lCont := (Alltrim(FPX->FPX_STATUS) == "Pendente de vistoria")
                                    Else
                                        lCont := (Upper(Alltrim(FPX->FPX_STATUS)) == "FINALIZADO")
                                    EndIf
                                EndIf
                                If lCont
                                    If !Empty(cAux)
                                        cAux += ","
                                    EndIf
                                    cAux += ' {'
                                    cAux += ' "CodTop": "'+FPX->FPX_CODTOP+'",'
                                    cAux += ' "CodItem": "'+FPX->FPX_CODITE+'",'
                                    cAux += ' "Resposta": "'+Alltrim(FPX->FPX_RESPOS)+'",'
                                    cAux += ' "NomeItem": "'+Alltrim(Posicione("FQ6",1,xFilial("FQ6")+FPX->FPX_CODITE,"FQ6_DESC"))+'",'
                                    cAux += ' "NomeTop": "'+Alltrim(Posicione("FQM",1,xFilial("FQM")+FPX->FPX_CODTOP,"FQM_DESC"))+'",'
                                    cAux += ' "Imagens": ['
                                    cAux2 := ""
                                    DbSelectArea("AC9")
                                    AC9->(DbSetOrder(2)) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
                                    AC9->(DbGoTop())
                                    If AC9->(DbSeek(xFilial("AC9")+"FPX"+xFilial("FPX")+FPX->FPX_CODCHE+FPX->FPX_CODTOP+FPX->FPX_CODITE ))//AC9->(DbSeek(PadR(SubString(FQC->FQC_FILBEM,1,2),Len(FQC->FQC_FILBEM))+"FPX"+xFilial("FPX")+FPX->FPX_CODCHE+FPX->FPX_CODTOP+FPX->FPX_CODITE ))
                                        While FPX->FPX_CODCHE+FPX->FPX_CODTOP+FPX->FPX_CODITE == ALLTRIM(AC9_CODENT)//AC9->(!EoF()) .AND. PadR(SubString(FQC->FQC_FILBEM,1,2),Len(FQC->FQC_FILBEM))+"FPX"+xFilial("FPX")+PadR(FPX->FPX_CODCHE+FPX->FPX_CODTOP+FPX->FPX_CODITE,TamSX3("AC9_CODENT")[1]) == AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
                                            If !Empty(cAux2)
                                                cAux2 += ","
                                            EndIf
                                            DbSelectArea("ACB")
                                            ACB->(DbSetOrder(1))
                                            If ACB->(DbSeek(xFilial("ACB")+AC9->AC9_CODOBJ))
                                                cAux2 += ' { "base64": "'+FileToBase64(ACB->ACB_OBJETO)+'"}'
                                            EndIf
                                            AC9->(DbSkip())
                                        EndDo
                                    EndIf
                                    cAux += cAux2
                                    cAux += ' ]'
                                    cAux += ' }'
                                EndIf
                                FPX->(DbSkip())
                            EndDo
                        EndIf
                        cDados += cAux
                        cDados += ' ],'
                        cDados += ' "ClienteAutorizado": { '
                        cDados += '     "Nome" : "'+Alltrim(FQC->FQC_CLIAUT)+ '",'
                        cDados += '     "Cnh" : "'+Alltrim(FQC->FQC_CNHAUT)+ '",'
                        cDados += '     "Celular" : "'+Alltrim(FQC->FQC_CELAUT)+ '",'
                        cDados += '     "Email" : "'+Alltrim(FQC->FQC_EMAAUT)+ '",'
                        cDados += '     "DataHora" : "'+Alltrim(FQC->FQC_DHFAUT)+ '",'
                        cDados += '     "Assinatura" : "'+FileToBase64("checklist_"+Alltrim(FQC->FQC_CODCHE)+"_assinaturaclienteautorizado.jpg")+ '",'
                        cDados += '     "Foto" : "'+FileToBase64("checklist_"+Alltrim(FQC->FQC_CODCHE)+"_clienteautorizado.jpg")+ '"'
                        cDados += ' }'
                        cDados += ' }'
                    Else
                        If oJson:Tipo == "Em aberto"
                            cRet := "ERRO-Não possui check-list em aberto."
                        Else
                            cRet := "ERRO-Não encontrado o check-list."
                        EndIf
                        cDados += " {}"
                    EndIf
                EndIf
            EndIf
        EndIf
	End Sequence

	ErrorBlock(bError)
	If !Empty(cEnvLog)
		//cRet := "ERRO-"+cEnvLog
	EndIf

	If Empty(cRet)
		cRet 	:= "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cDados+'}')) )
	
	//conout("TERMINO-Consumido o WebService RetChecklist - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.
Function FileToBase64(cArq)

    Local cString   := ""
    Local cBase64   := ""
    Local aFiles    := {} // O array receberá os nomes dos arquivos e do diretório
    Local aSizes    := {} // O array receberá os tamanhos dos arquivos e do diretorio
    Local nHandle   := 0
    Local cDirDoc   := Alltrim(GetMv("MV_DIRDOC"))
    Local cPathBco  := ""
    Local nHandle   := 0
    Local cComando  := 0
    //Se o ultimo caracter nao for uma \, acrescenta ela, e depois configura o diretorio com a subpasta co01\shared
    If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
        cDirDoc := cDirDoc + "\"
    EndIf

    cPathBco := cDirDoc + 'co01\shared\'

    ADir(cPathBco+cArq, @aFiles, @aSizes)//Verifica o tamanho do arquivo, parâmetro exigido na FRead.


      cComando := "nHandle := fopen(cPathBco+cArq , FO_READWRITE + FO_SHARED )"
    &(cComando)  
    If nHandle >= 0
        FRead( nHandle, @cString, aSizes[1] ) //Carrega na variável cString, a string ASCII do arquivo.

        cBase64 := Encode64(cString) //Converte o arquivo para BASE64

        fclose(nHandle)
    EndIf

Return (cBase64)

/*
{
  "FilOs": "valor_exemplo",
  "Tipo": "valor_exemplo",
  "cCodBem": "valor_exemplo",
  "cCodForm": "valor_exemplo",
  "cSeq": "valor_exemplo",
  "CodCheck": "valor_exemplo"
}
*/
