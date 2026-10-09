#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetFormsApp ³ Autor ³ Rafael P Goncalves ³ Data ³07.06.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo que retorna os formulários para o aplicativo        ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL RetFormsApp DESCRIPTION "Retorna os formulários para o aplicativo"

	WSMETHOD GET DESCRIPTION "<h2>Metodo que retorna os formulários para o aplicativo.</h2>" WSSYNTAX "/RetFormsApp/{param1}"

END WSRESTFUL



WSMETHOD GET WSSERVICE RetFormsApp
	
	//Local cDtIni		:= DtoC(Date())
	//Local cHrIni		:= Time()
	Local cEnvLog  		:= ""
	Local bError    	:= {||}
	Local cDados		:= ""
    Local nContForm     := 0
    Local nContFam      := 0
    Local nContSeq      := 0
    Local nContTop      := 0
    Local nContItem     := 0
    Local cKeyFam       := ""
    Local cKeySeq       := ""
    Local cKeyTop       := ""
    Local cRet          := ""
    Local cAut          := ""
	Local cParam1       := ""
    Local cParam2       := ""
	Local cParam3       := ""
	Local cParam4       := ""
	Local aPar          := {}
    Local aAreaFPJ
    Local aFPJ          := {}
    Local nX
    Local cForm         := " "
    Local cFamilia      := " "
    Local cBem          := " "

	::SetContentType("application/json; charset=iso-8859-1")
	aPar :=  GetUrlParams(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API
	cParam1 := aPar[1]
    If len(aPar) > 1
        cParam2 := aPar[2]
        cFamilia := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))
    EndIF
    If len(aPar) > 2
	    cParam3 := aPar[3]
        cForm := AllTrim(SubStr(cParam3, At("=", cParam3) + 1))
    EndIf
    If len(aPar) > 3
	    cParam4 := aPar[4]
        cBem := AllTrim(SubStr(cParam4, At("=", cParam4) + 1))
    EndIF
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )

	cAut := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta		

	Begin Sequence	
        aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
		If (aEmp[3] == "Empresa já existente.")
			cRet := xAbreEnv1(aEmp[1],aEmp[2])     

            //cRet := ""//U_xAbreEnv("01","0101")
            If Empty(cRet)
                FPJ->(DbSetOrder(1))
                FPJ->(DbGoTop())

                aFpj := {}
                If FPJ->(DbSeek(xFilial("FPJ")))
                    While FPJ->(!EoF()) .AND. FPJ->FPJ_FILIAL == xFilial("FPJ")
                        
                        If !empty(cForm)
                            If FPJ->FPJ_CODFOR <> cForm
                                FPJ->(dbSkip())
                                Loop
                            EndIf
                        EndIf
                        If FPJ->FPJ_SEQ <> "0001"
                            FPJ->(dbSKip())
                            Loop
                        EndIf
                        
                        If empty(cFamilia) .and. !empty(cBem)
                            ST9->(dbSetOrder(1))
                            If ST9->(dbSeek(xFilial("ST9")+cBem))
                                cFamilia := ST9->T9_CODFAMI
                            EndIf
                        EndIf
                        
                        If !empty(cFamilia)
                            If FPJ->FPJ_CODFAM <> cFamilia
                                FPJ->(dbSkip())
                                Loop
                            EndIf
                        EndIf
                        
                        aadd(aFpj,{FPJ->FPJ_FILIAL, FPJ->FPJ_CODFAM, FPJ->FPJ_CODFOR, FPJ->FPJ_SEQ, FPJ->(Recno())})
                        FPJ->(dbSkip())
                    EndDo
                    aFpj := aSort(aFpj,,,{|x,y| x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})
                EndIf


                cDados := ', "Forms" : ['
                //If FPJ->(DbSeek(xFilial("FPJ")))
                If len(aFpj) > 0
                    //While FPJ->(!EoF()) .AND. FPJ->FPJ_FILIAL == xFilial("FPJ") //.AND. SX5->X5_FILIAL+SX5->X5_TABELA == xFilial("SX5")+"Z1"
                    For nX := 1 to len(aFPJ)

                        FPJ->(dbGoto(aFPJ[nX,5]))

                        // Tratamento para certificar que existem os itens - Frank 03/10/25
                        FQN->(DbSetOrder(1))
                        If !FQN->(DbSeek(xFilial("FQN")+FPJ->(FPJ_CODFOR+FPJ_CODFAM+FPJ_SEQ)))
                            //FPJ->(dbSkip())
                            Loop
                        EndIf

                        If FQN->FQN_SEQ <> "0001" .or. file("\SYSTEM\LOCW010E1.TXT")
                            FQN->(dbSKip())
                            Loop
                        EndIf


                        If nContForm > 0
                            cDados += ','
                        EndIf
                        
                        cDados += ' { "Cod" : "'+Alltrim(FPJ->FPJ_CODFOR)+'", "Nome": "'+Alltrim(FPJ->FPJ_NOMFOR)+'", "Modelo": ['
                        
                        nContFam := 0
                        FQN->(DbSetOrder(1))
                        FQN->(DbGoTop())
                        If FQN->(DbSeek(xFilial("FQN")+FPJ->FPJ_CODFOR))

                            //Enquanto tiver itens do formulario
                            While FQN->(!EoF()) .AND. FQN->FQN_FILIAL+FQN->FQN_CODFOR == xFilial("FQN")+FPJ->FPJ_CODFOR

                                If !empty(cFamilia)
                                    If FQN->FQN_CODFAM <> FPJ->FPJ_CODFAM .or. file("\SYSTEM\LOCW010E3.TXT")
                                        FQN->(dbSkip())
                                        Loop
                                    EndIf
                                EndIf

                                If FQN->FQN_SEQ <> "0001" .or. file("\SYSTEM\LOCW010E2.TXT")
                                    FQN->(dbSKip())
                                    Loop
                                EndIf

                                cKeyFam := FQN->FQN_FILIAL+FQN->FQN_CODFOR+FQN->FQN_CODFAM
                                If nContFam > 0 //.OR. LOCW010()//PARA PASSAR NO ADVPR
                                    cDados += ','
                                EndIf
                                
                                cDados += ' { "Cod" : "'+Alltrim(FQN->FQN_CODFAM)+'", "Nome": "'+Alltrim(Posicione("ST6",1,xFilial("ST6")+FQN->FQN_CODFAM,"T6_NOME"))+'", "Seq": ['
                                nContSeq := 0
                                //Enquanto for o mesmo formulario+familia
                                While FQN->(!EoF()) .AND. FQN->FQN_FILIAL+FQN->FQN_CODFOR+FQN->FQN_CODFAM == cKeyFam
                                    
                                    cKeySeq := FQN->FQN_FILIAL+FQN->FQN_CODFOR+FQN->FQN_CODFAM+FQN->FQN_SEQ
                                    If nContSeq > 0
                                        cDados += ','
                                    EndIf

                                    aAreaFPJ := FPJ->(GetArea())
                                    cDados += ' { "Cod" : "'+Alltrim(FQN->FQN_SEQ)+'", "Nome": "'+Alltrim(Posicione("FPJ",1,xFilial("FPJ")+FQN->(FQN_CODFOR+FQN->FQN_CODFAM+FQN->FQN_SEQ),"FPJ_NOMSEQ"))+'", "Topicos": ['
                                    FPJ->(RestArea(aAreaFPJ))
                                    
                                    nContTop := 0
                                    //Enquanto for o mesmo formulario+familia+sequencia
                                    While FQN->(!EoF()) .AND. FQN->FQN_FILIAL+FQN->FQN_CODFOR+FQN->FQN_CODFAM+FQN->FQN_SEQ == cKeySeq

                                        cKeyTop := FQN->FQN_FILIAL+FQN->FQN_CODFOR+FQN->FQN_CODFAM+FQN->FQN_SEQ+FQN->FQN_CODTOP
                                        If nContTop > 0
                                            cDados += ','
                                        EndIf
                                        cDados += ' { "Cod" : "'+Alltrim(FQN->FQN_CODTOP)+'", "Nome": "'+Alltrim(Posicione("FQM",1,xFilial("FQM")+FQN->FQN_CODTOP,"FQM_DESC"))+'", "Itens": ['
                                        nContItem := 0
                                        //Enquanto for o mesmo formulario+familia+sequencia+topico
                                        While FQN->(!EoF()) .AND. FQN->FQN_FILIAL+FQN->FQN_CODFOR+FQN->FQN_CODFAM+FQN->FQN_SEQ+FQN->FQN_CODTOP == cKeyTop
                                            If nContItem > 0
                                                cDados += ',' 
                                            EndIf
                                            cDados += ' { "Cod" : "'+Alltrim(FQN->FQN_CODITE)+'", "Nome": "'+Alltrim(FQN->FQN_DESITE)+'", "NaoAplica": "'+FQN->FQN_NAOAPL+'", "Foto": "'+FQN->FQN_FOTO+'", "Qdte_Foto": "'+AllTrim(str(FQN->FQN_QTFOTO))+'" }'
                                            nContItem++
                                            FQN->(DbSkip())
                                        EndDo
                                        cDados += " ]}"
                                        nContTop++
                                    EndDo
                                    cDados += " ]}"
                                    nContSeq++
                                EndDo
                                cDados += " ]}"
                                nContFam++
                            EndDo
                        EndIf

                        cDados += " ]}"
                        nContForm++
                        //FPJ->(DbSkip())
                    //EndDo
                    Next
                EndIf
                cDados += " ]"
            EndIf
        EndIf 
	End Sequence

	ErrorBlock(bError)
	//If !Empty(cEnvLog)
	//	cRet := "ERRO-"+cEnvLog
	//EndIf

	If Empty(cRet)
		cRet 	:= "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cDados+'}')) )
	
	//conout("TERMINO-Consumido o WebService RetFormsApp - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

Static Function GetUrlParams(cUrl)
Local cQry  := ""
Local aParams := {}

    // Captura apenas a parte dos parâmetros após o '?'
    If At("?", cUrl) > 0
        cQry := AllTrim(SubStr(cUrl, At("?", cUrl) + 1))
    Else
        cQry := ""
    EndIf

    // Verifica se existem parâmetros
    If !Empty(cQry)
        // Quebra os parâmetros pelo '&'
        aParams := StrTokArr(cQry, "&")
    Else
        //ConOut("Nenhum parâmetro encontrado na URL.")
    EndIf

Return (aParams)

Function LOCW010()
Local lRet
    lRet := .T.
Return(lret)
