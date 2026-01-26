#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Notifmultas ³ Autor ³ Dennis Calabrez    ³ Data ³31.01.2025³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo que retorna as Multas para o aplicativo            ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL Notifmultas DESCRIPTION "Retorna as Frotas Locadas para o aplicativo"

	WSMETHOD GET DESCRIPTION "<h2> Metodo que retorna as Multas para o aplicativo.</h2>" WSSYNTAX "/Notifmultas/{param1}/{param2}/{param3}/{param4}"

END WSRESTFUL



WSMETHOD GET WSSERVICE Notifmultas
	
//Local cDtIni		:= DtoC(Date())
//Local cHrIni		:= Time()
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
Local aPar          := {}
Local cCodCli       := ""
Local cLojCli       := ""
Local cCnpj         := ""
Local cAut          := ""
Local cQuery
Local aBindParam    := {}

	//conout("INICIO-Consumido o WebService RetFrotasApp - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	aPar :=  GetUrlParams1(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
	cParam2 := aPar[2]
	cParam3 := aPar[3]
	cParam4 := aPar[4]
	cCodCli := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o Código do cliente se informado
	cLojCli := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego a Loja do cliente se informada
	cCnpj   := AllTrim(SubStr(cParam3, At("=", cParam3) + 1))//Pego o CNPJ do cliente se informado
	cAut    := AllTrim(SubStr(cParam4, At("=", cParam4) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
		If (aEmp[3] == "Empresa já existente.")
			cRet := xAbreEnv1(aEmp[1],aEmp[2])
			//cRet := ""
			If Empty(cRet)
				cQuery := "SELECT FPA_PROJET,FPA_OBRA,TRX_CODMO, TRX_PLACA,TRX_VALOR,TRX_FIC,TRX_MULTA,TRX_TPMULT,TRX_DTDIGI, TRX_DTNAR, "
				cQuery += "FP0_CLI, FP0_LOJA,FP0_CLICGC,TRX_CODINF,FP0_STATUS,TRX_DTINFR,TRX_MULTA,TRX_NUMAIT,TQR_DESMOD "
				cQuery += "FROM "+RetSqlName("TRX")+" TRX "
				cQuery += "INNER JOIN "+RetSqlName("FP0")+" FP0 ON FP0_FILIAL = '"+xFilial("FP0")+"' AND FP0.D_E_L_E_T_ = ' ' "
				If !Empty(cCodCli) .and. !Empty(cLojCli)
					cQuery +=  "AND FP0_CLI = ? AND FP0_LOJA = ? "
					aadd(aBindParam,cCodCli)
					aadd(aBindParam,cLojCli)
				EndIf 	
				If !Empty(cCnpj)
					cQuery +=  "AND FP0_CLICGC = ? "
					aadd(aBindParam,cCnpj)
				EndIf	
				cQuery += "INNER JOIN "+RetSqlName("FPA")+" FPA ON FPA_FILIAL = '"+xFilial("FPA")+"' AND FP0_PROJET = FPA_PROJET AND FP0.D_E_L_E_T_ = ' ' "
				cQuery += " AND FPA_AS <> '' "
				cQuery += "INNER JOIN "+RetSqlName("ST9")+" ST9 ON  T9_CODBEM = TRX_CODBEM AND ST9.D_E_L_E_T_ = ' ' "
				cQuery += "INNER JOIN "+RetSqlName("TQR")+" TQR ON  TQR_TIPMOD = T9_TIPMOD AND TQR.D_E_L_E_T_ = ' ' "
				cQuery += "WHERE TRX.D_E_L_E_T_ = ' ' AND TRX_AS = FPA_AS "		
				cQuery += "ORDER BY TRX_NOME"

				If Select("TRBTRX") > 0
					TRBFQ4->(DbCloseArea())
				EndIf

				//TcQuery cQuery New Alias "TRBTRX"
				cQuery := CHANGEQUERY(cQuery)
				MPSysOpenQuery(cQuery,"TRBTRX",,,aBindParam)

				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())   
				SA1->(DbSeek(xFilial("SA1")+TRBTRX->FP0_CLI+TRBTRX->FP0_LOJA))                 
				cDados += ', "cnpj" : "'+Alltrim(SA1->A1_CGC)+'", "Nome": "'+Alltrim(SA1->A1_NOME)+'", "Multas": ['			

				While TRBTRX->(!EoF()) 
					If nContForm > 0
						cDados += ','
					EndIf
						
					nContFam := 0
					//BUSCA O ARQUIVO NO BANCO DO CONHECIMENTO (MULTA)
					AC9->(DbSetOrder(2)) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
					If AC9->(DbSeek(xFilial("AC9")+"TRX"+xFilial("TRX")+xFilial("TRX")+TRBTRX->TRX_MULTA+TRBTRX->TRX_TPMULT ))

						DbSelectArea("ACB")
						ACB->(DbSetOrder(1))
						If ACB->(DbSeek(xFilial("ACB")+AC9->AC9_CODOBJ))
							cAux := FileToBas64(ACB->ACB_OBJETO)//ARQUIVO A SER CONVERTIDO PARA BASE64
						EndIf

					EndIf   
					//BUSCA A PONTUAÇÃO DA INFRAÇÃO PELO CÓDIGOO DA INFRAÇÃO NA TRX(TRX_CODFINF), POIS O CAMPO TRX_PONTUA É VIRTUAL   
					TSH->(DbSetOrder(1))
					TSH->(DbGoTop())   
					TSH->(DbSeek(xFilial("TSH")+TRBTRX->TRX_CODINF))  
				
					cDados += ' { ' 
					cDados += '"projeto" : "'+Alltrim(TRBTRX->FPA_PROJET)+'",'
					cDados += '"obra" : "'+Alltrim(TRBTRX->FPA_OBRA)+'",'
					cDados += '"nome_obra": "'+Alltrim(Posicione("FP1",1,xFilial("FP1")+TRBTRX->FPA_PROJET+TRBTRX->FPA_OBRA,"FP1_NOMORI"))+'",'
					If !Empty(TRBTRX->TRX_CODMO)
						cDados += '"motorista" : "'+Alltrim(TRBTRX->TRX_CODMO)+'",'
						cDados += '"nome_mot": "'+Alltrim(Posicione("DA4",1,xFilial("DA4")+Alltrim(TRBTRX->TRX_CODMO),"DA4_NOME"))+'",'
					Else
						cDados += '"motorista" : "",'
						cDados += '"nome_mot": "",'						
					EndIf 	
					cDados += '"placa": "'+ALLTRIM(TRBTRX->TRX_PLACA)+'",'
					cDados += '"id_multa": "'+ALLTRIM(TRBTRX->TRX_MULTA)+'",'
					cDados += '"dt_infra": "'+ALLTRIM(TRBTRX->TRX_DTINFR)+'",'
					cDados += '"num_infra": "'+ALLTRIM(TRBTRX->TRX_NUMAIT)+'",'
					cDados += '"valor": "'+ALLTRIM((str(TRBTRX->TRX_VALOR)))+'",'
					cDados += '"pontuacao": "'+(TSH->TSH_PONTOS)+'",'
					cDados += '"modelo": "'+ALLTRIM(TRBTRX->TQR_DESMOD)+'",'
					cDados += '"aviso": "'+ALLTRIM(TRBTRX->TRX_DTNAR)+'",'
					cDados += '"digitacao": "'+ALLTRIM(TRBTRX->TRX_DTDIGI)+'",'
					If !Empty(cAux)
						cDados += '"arquivo": "'+cAux+'",'
						cDados += '"tipo_multa": "'+ALLTRIM(TRBTRX->TRX_TPMULT)+'",'
					Else
						cDados += '"arquivo": "",
						cDados += '"tipo_multa": "'+ALLTRIM(TRBTRX->TRX_TPMULT)+'",'	
					EndIf	
					cDados += '"status_obra": "'+ALLTRIM(TRBTRX->FP0_STATUS)+'"'
					cDados += ' } '
					cAux := ""
					nContSeq := 0
					nContForm++
					TRBTRX->(DbSkip())
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
	
	//conout("TERMINO-Consumido o WebService RetFormsApp - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parâmetros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 20/01/2025
/*/
Static Function GetUrlParams1(cUrl)
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

Function FileToBas64(cArq)

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
