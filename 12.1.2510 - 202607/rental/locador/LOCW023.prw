#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetOS       ³ Autor ³ Dennis Calabrez    ³ Data ³31.01.2025³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo que retorna as Ordens de Serviço para o aplicativo  ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL RetOS DESCRIPTION "Retorna as Ordens de Serviço para o aplicativo"

	WSMETHOD GET DESCRIPTION "<h2> Metodo que retorna as Ordens de Serviço para o aplicativo.</h2>" WSSYNTAX "/RetOS/{param1}/{param2}/{param3}/{param4}/{param5}/"

END WSRESTFUL



WSMETHOD GET WSSERVICE RetOS
	
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cDados		:= ""
Local nContForm     := 0
Local nContFam      := 0
Local nContSeq      := 0
Local cRet          := ""
Local cParam1       := ""
Local cParam2       := ""
Local cParam3       := ""
Local cParam4       := ""
Local cParam5       := ""
Local cDtIni        := ""
Local cDtFim        := ""
Local aPar          := {}
Local cCodFor       := ""
Local cLojFor       := ""
Local cAut          := ""
Local cQuery
Local aBindParam    := {}

	aPar :=  GetUrlParams2(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
	cParam2 := aPar[2]
	cParam3 := aPar[3]
	cParam4 := aPar[4]
	cParam5 := aPar[5]
	cCodFor := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o Código do cliente se informado
	cLojFor := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego a Loja do cliente se informada
	cAut    := AllTrim(SubStr(cParam3, At("=", cParam3) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta
	cDtIni  := AllTrim(SubStr(cParam4, At("=", cParam4) + 1))//Pego a Data inicial
	cDtFim  := AllTrim(SubStr(cParam5, At("=", cParam5) + 1))//Pego a Data final
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
		If (aEmp[3] == "Empresa já existente.")
			cRet := xAbreEnv1(aEmp[1],aEmp[2])

			If Empty(cRet)
				cQuery := "SELECT *,TJ_PROJETO,TJ_OBRA,TJ_AS,TJ_OBSERVA,TJ_POSCONT,TJ_SERVICO,TJ_CODBEM,A2_NOME,TJ_DTORIGI "
				cQuery += "FROM "+RetSqlName("FH1")+" FH1 "
				cQuery += "INNER JOIN "+RetSqlName("SA2")+" SA2 ON FH1_CODFOR = A2_COD AND SA2.D_E_L_E_T_ = ' ' "
				cQuery += " AND A2_LOJA = FH1_LOJFOR AND A2_FILIAL = '" +xFilial("SA2") + "' "
				cQuery += "INNER JOIN "+RetSqlName("STJ")+" STJ ON  TJ_ORDEM = FH1_ORDEM AND STJ.D_E_L_E_T_ = ' ' "
				cQuery += " AND TJ_FILIAL = '" +xFilial("STJ") + "' "
                If !Empty(cDtIni) .and. !Empty(cDtFim)
					cQuery += " AND TJ_DTORIGI BETWEEN ? AND ? "
					aadd(aBindParam,cDtIni)
					aadd(aBindParam,cDtFim)
				EndIf					
				
				cQuery += "WHERE FH1.D_E_L_E_T_ = ' ' "	
                If !Empty(cCodFor) .and. !Empty(cLojFor)
					cQuery +=  "AND FH1_CODFOR = ? AND FH1_LOJFOR = ? "
					aadd(aBindParam,cCodFor)
					aadd(aBindParam,cLojFor)
				EndIf	
				cQuery += "ORDER BY FH1_ORDEM"

				//TcQuery cQuery New Alias "TRBFH1"
				cQuery := CHANGEQUERY(cQuery)
				MPSysOpenQuery(cQuery,"TRBFH1",,,aBindParam)
                
				cDados += ', "CodFor" : "'+Alltrim(TRBFH1->FH1_CODFOR)+'", "Nome": "'+Alltrim(TRBFH1->A2_NOME)+'", "Ordens": ['			

				While TRBFH1->(!EoF()) 
					If nContForm > 0
						cDados += ','
					EndIf
						
					nContFam := 0
					//BUSCA O ARQUIVO NO BANCO DO CONHECIMENTO (MULTA)
					AC9->(DbSetOrder(2)) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
					If AC9->(DbSeek(xFilial("AC9")+"STJ"+xFilial("FH1")+xFilial("FH1")+TRBFH1->FH1_ORDEM ))

						DbSelectArea("ACB")
						ACB->(DbSetOrder(1))
						If ACB->(DbSeek(xFilial("ACB")+AC9->AC9_CODOBJ))
							cAux := FileToBs64(ACB->ACB_OBJETO)//ARQUIVO A SER CONVERTIDO PARA BASE64
						EndIf

					EndIf   
				
					cDados += ' { ' 
					cDados += '"projeto" : "'+TRBFH1->TJ_PROJETO+'",'
					cDados += '"obra" : "'+TRBFH1->TJ_OBRA+'",'
					cDados += '"AS": "'+Alltrim(TRBFH1->TJ_AS)+'",'
					cDados += '"Observ" : "'+Alltrim(TRBFH1->TJ_OBSERVA)+'",'
					cDados += '"Contador": "'+Alltrim(TRBFH1->TJ_POSCONT)+'",'
					cDados += '"Servico": "'+Alltrim(TRBFH1->TJ_SERVICO)+'",'
					cDados += '"dt_abertura": "'+ALLTRIM(TRBFH1->TJ_DTORIGI)+'",'
					cDados += '"Bem": "'+Alltrim(TRBFH1->TJ_CODBEM)+'",'
					cDados += '"Ordem": "'+ALLTRIM(TRBFH1->FH1_ORDEM)+'",'
					cDados += '"Plano": "'+(TRBFH1->FH1_PLANO)+'",'
					cDados += '"tarefa": "'+ALLTRIM(TRBFH1->FH1_TAREFA)+'",'
                    cDados += '"tipo_re": "'+ALLTRIM(TRBFH1->FH1_TIPORE)+'",'
                    cDados += '"codigo": "'+ALLTRIM(TRBFH1->FH1_CODIGO)+'",'
					cDados += '"desc_cod": "'+Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBFH1->FH1_CODIGO),"B1_DESC")+'",'
					cDados += '"quanti": "'+ALLTRIM(str(TRBFH1->FH1_QUANTI))+'",'
                    cDados += '"seq_rel": "'+ALLTRIM(TRBFH1->FH1_SEQREL)+'",'
                    cDados += '"seq_tar": "'+ALLTRIM(TRBFH1->FH1_SEQTAR)+'",'
                    cDados += '"aprovador": "'+ALLTRIM(TRBFH1->FH1_CODAPR)+'",'
                    cDados += '"nome_apr": "'+ALLTRIM(TRBFH1->FH1_NOMAPR)+'",'
                    cDados += '"dat_apro": "'+ALLTRIM(TRBFH1->FH1_DTAPRO)+'",'
                    cDados += '"hora_apro": "'+ALLTRIM(TRBFH1->FH1_HRAPRO)+'",'
                    cDados += '"dt_enc": "'+ALLTRIM(TRBFH1->FH1_DTENC)+'",'
                    cDados += '"hr_enc": "'+ALLTRIM(TRBFH1->FH1_HRENC)+'",'
                    cDados += '"ped_com": "'+ALLTRIM(TRBFH1->FH1_PEDCOM)+'",'
                    cDados += '"valor_uni": "'+ALLTRIM((str(TRBFH1->FH1_VLRUNI)))+'",'
                    cDados += '"valor_tot": "'+ALLTRIM((str(TRBFH1->FH1_VLRTOT)))+'",'
                    cDados += '"valor_uni_apr": "'+ALLTRIM((str(TRBFH1->FH1_VLRAUN)))+'",'
                    cDados += '"valor_tot_apr": "'+ALLTRIM((str(TRBFH1->FH1_VLRATO)))+'",'
                    cDados += '"cod_finalidade": "'+ALLTRIM(TRBFH1->FH1_CODFIN)+'",'
                    cDados += '"desc_finalidade": "'+ALLTRIM(TRBFH1->FH1_DESFIN)+'",'
                    cDados += '"cobra": "'+ALLTRIM(TRBFH1->FH1_COBRA)+'",'
                    cDados += '"custo_extra": "'+ALLTRIM((str(TRBFH1->FH1_CUSEX)))+'",'
					If !Empty(cAux)
						cDados += '"arquivo": "'+cAux+'",'
					Else
						cDados += '"arquivo": "",
					EndIf	
					cDados += '"status_apr": "'+ALLTRIM(TRBFH1->FH1_STAPRO)+'",'
					cDados += ' } '
					cAux := ""
					nContSeq := 0
					nContForm++
					TRBFH1->(DbSkip())
				EndDo

				cDados += "]"
			EndIf
		EndIf	
	End Sequence

	ErrorBlock(bError)
	If Empty(cRet)
		cRet 	:= "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cDados+'}')) )
	
Return .T.

/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parâmetros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 20/01/2025
/*/
Static Function GetUrlParams2(cUrl)
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

Function FileToBs64(cArq)

    Local cString   := ""
    Local cBase64   := ""
    Local aFiles    := {} // O array receberá os nomes dos arquivos e do diretório
    Local aSizes    := {} // O array receberá os tamanhos dos arquivos e do diretorio
    Local nHandle   := 0
    Local cDirDoc   := Alltrim(GetMv("MV_DIRDOC"))
    Local cPathBco  := ""
	Local cComando

    //Se o ultimo caracter nao for uma \, acrescenta ela, e depois configura o diretorio com a subpasta co01\shared
    If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
        cDirDoc := cDirDoc + "\"
    EndIf

    //cPathBco := cDirDoc + 'co01\shared\'
	cPathBco := cDirDoc + "co" + cEmpAnt + "\shared\"

    ADir(cPathBco+cArq, @aFiles, @aSizes)//Verifica o tamanho do arquivo, parâmetro exigido na FRead.

	cComando := "fopen(cPathBco+cArq , FO_READWRITE + FO_SHARED )" 
    nHandle := &(cComando)
    
    If nHandle >= 0
        FRead( nHandle, @cString, aSizes[1] ) //Carrega na variável cString, a string ASCII do arquivo.

        cBase64 := Encode64(cString) //Converte o arquivo para BASE64

        fclose(nHandle)
    EndIf

Return (cBase64)
