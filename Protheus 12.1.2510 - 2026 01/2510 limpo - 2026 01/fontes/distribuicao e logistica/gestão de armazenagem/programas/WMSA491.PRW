#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSA491.CH"

//------------------------------------
/*/{Protheus.doc} WMSA491()
Carga para tabela de complemento produto WMS D1A
@author Roselaine Adriano 
@version P12
@Since 19/05/2025
@obs Importação de produtos para incusão de controle WMS Saas '.txt' 
/*/
//------------------------------------
Function WMSA491()
Local cArquivo := Space(100)
Local nHdlArq
Local cAliasTmp
Local aCampos   := {}
Local aDiver    := {}
Local aDadosArq := {}
Local oReport
Local lWmsSass  := SuperGetMv("MV_WMSSAAS",.F.,.F.)
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)

	If !lWmsSass .AND. !lWmsNew
		MsgInfo(STR0001,STR0002) //"Esta rotina deve ser utilizada para atualização de campos da tabela D1A utlizados pelo WMS Protheus ou Integração com WMS SaaS. Ative um dos parâmetros (MV_WMSSAAS) ou (MV_WMSNEW) para uso desta rotina." "Atenção"
		Return
	EndIf
	IF lWmsSass .AND. lWmsNew
		MsgInfo(STR0003,STR0002) // "Os parâmetros (MV_WMSSAAS) e (MV_WMSNEW) estão ativos. Ative somente um dos parâmetros para que a rotina passa ser executada.""Atenção"
		Return
	EndIF
	If lWmsSass
	   Msginfo(STR0004,STR0002) // "Esse programa tem como objetivo realizar a inclusão de complemento para os produtos (WMSA090) marcando o campo WMSSAAS na tabela D1A. Somente será incluso o controle WMS SAAS para produtos que não possuem Controle de endereçamento no ERP Protheus."
	EndIF
	If lWmsNew
	   Msginfo(STR0005,STR0002) //"Esse programa tem como objetivo realizar a inclusão de complemento para os produtos (WMSA090) incluindo os dados na tabela D1A. " "Atenção"
	EndIF
	Do While .T.
		cArquivo := cGetFile(STR0007+"|*.TxT|", OemToAnsi(OemToAnsi(STR0006)),,,.T. ) // Arquivo Texto (*.txt) // "Selecione o arquivo para importação."
		If !Empty(cArquivo) .And. WMSA491VAR(@cArquivo,@nHdlArq)
			Exit
		ElseIf Empty(cArquivo)
			Exit
		EndIf
	EndDo
	Conout("Inicio leitura arquivo : " + cArquivo)
	If !Empty(cArquivo)
		// Criação dos campos da tabela temporaria
		WMSA4912TB(@cAliasTmp,@aCampos)
		Conout("Fim criação temporária : ")
		// Leitura do arquivo texto
		Processa({|| ProcRegua(0), WMSA491ARQ(cArquivo,@aDiver,@aDadosArq) },STR0008 , STR0009, .T.)
		If Len(aDiver) > 0
			aDadosArq := {}
			// Geracao do relatorio com as divergencias
			Processa({|| ProcRegua(0) , Processa({|| cAliasTmp := MntCargDad(cAliasTmp,aDiver,aCampos) } , STR0008, STR0010,.F.) , oReport:= WMSA4912RL(aDiver,cAliasTmp) , oReport:PrintDialog() }, "Aguarde...", "Gerando Relatório de Divergências...",.F.) // Aguarde... // Gerando Relatório de Divergências...
		Else
			If Len(aDadosArq) > 0
				Processa({|| ProcRegua(0) ,WMSA4912PR(aDadosArq) }, STR0008, STR0011,.F.) // Aguarde... // "Processando atualização..."
				Msginfo(STR0012) // Após a execução dessa rotina deverá ser rodado o programa de acerto de saldo, Miscelânia > Processamentos > Refaz Saldos.
			EndIf
		EndIf	
		delTabTmp(cAliasTmp)
	EndIf
Return Nil
//------------------------------------
/*/{Protheus.doc} WMSA491VAR
Validacao do arquivo
@author Roselaine Adriano
@version P12
@Since 19/05/2025
@obs Valida o arquivo se o mesmo existe no diretorio informado 
/*/
//------------------------------------
Static Function WMSA491VAR(cArquivo,nHdlArq)
Local lRet := .T.
	
	If Upper(SubStr(AllTrim(cArquivo),Len(AllTrim(cArquivo))-3,Len(AllTrim(cArquivo)))) != ".TXT"
		cArquivo := Upper(AllTrim(cArquivo))+".TXT"
	Else
		cArquivo := AllTrim(cArquivo)
	EndIf
	Conout("Verificando se arquivo existe")
	If !FILE(cArquivo)
		Help(,,STR0002,,STR0013,1,0) // Atencao // Arquivo não existe para o diretorio informado
	   lRet := .F.
	EndIf
	Conout("Arquivo Existe? " +  cValToChar(lRet))
Return lRet
//------------------------------------
/*/{Protheus.doc} WMSA4912TB
Criação da tabela temporaria
@author Roselaine Adriano 
@version P12
@Since 28/05/2025
@obs Criação da tabela temporaria para armazenar os dados do relatorio
/*/
//------------------------------------
Static Function WMSA4912TB(cAliasTmp,aCampos)
	
	Aadd(aCampos,{"INDREC","N",10,0})
	Aadd(aCampos,{"DIVER","C",180,0})
	Aadd(aCampos,{"CONTE","C",100,0})
	
	cAliasTmp := CriaTabTmp(aCampos,{"INDREC"},cAliasTmp)
Return Nil
//------------------------------------
/*/{Protheus.doc} WMSA491ARQ
Leitura e validação do arquivo
@author Roselaine Adriano 
@version P12
@Since 28/05/2025
@obs Leitura e validaçao do conteudo do arquivo
/*/
//------------------------------------
Static Function WMSA491ARQ(cArquivo,aDiver,aDadosArq)
Local lRet      := .T.
Local nRecno    := 0
Local aLinha    := {}
Local cLinha    := ""
Local cAliasQry := Nil
Local cEmpresa  := ""
Local cLocal    := ""
Local cProduto  := ""
Local cServico  := ""
Local cEndereco := ""
Local cWMSSaas  := ""
Local lWmsSass   := SuperGetMv("MV_WMSSAAS",.F.,.F.)
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local cAliasDC5     := Nil 
Local cAliasNNR     := Nil 
Local cAliasSBE     := Nil 
Local cFilAtual   := cFilAnt
Local cFilArq   := ""
Local cLinhaAux := ""
	
	Conout("Inicio processamento leitura linha arquivo : " + cArquivo)
	FT_FUse(cArquivo)
	ProcRegua(FT_FLastRec())
	FT_FGoTop()
    Conout("posiciona primeiro registro arquivo : " + cArquivo)
	
	If lRet
		aDiver := {}
		Do While (!FT_FEOF())
			cLinha := FT_FReadLn()
			Conout("leitura linha : " + cLinha)
			lRet := .T.
			nRecno++
			incproc()
			If !Empty(cLinha)
				cLinhaAux := StrTran(cLinha,";")
				If (Len(cLinhaAux) != (Len(cLinha) - 5)) 
					lRet := .F.
					MsgAlert(STR0014+AllTrim(Str(nRecno)),STR0002) // Arquivo inconsistente! Existem informações a menos ou a mais na linha:  // Atenção
				EndIf
			EndIf
			
			If lRet .And. !Empty(cLinha)
				aLinha    := Separa(cLinha,';')
				cEmpresa  := FWGrpCompany()  //PadR(aLinha[1],TamSx3("B9_FILIAL")[1])  // Filial
				cFilArq   := PadR(aLinha[1],TamSx3("D1A_FILIAL")[1])  // Filial
				cProduto  := PadR(aLinha[2],TamSx3("D1A_COD")[1])     // Codigo do produto
				cServico  := PadR(aLinha[3],TamSx3("D1A_SEREPR")[1]) // Codigo do Servico de produção
				cLocal    := PadR(aLinha[4],TamSx3("NNR_CODIGO")[1]) 
				cEndereco := PadR(aLinha[5],TamSx3("D1A_ENDEPR")[1]) // Codigo do Endereço de produção
				If lWmsSass
					cWMSSaas  := PadR(aLinha[6],TamSx3("D1A_WSAAS")[1])
				endIf 
				
				If Empty(cFilArq)
					aAdd(aDiver,{nRecno,STR0015,cFilArq}) // Filial não informada.
					lRet := .F.
				EndIf 
				//validação para validar a filial informada no arquivo deve ser a mesma logada.
				If lRet .AND. (cFilAtual <> cFilarq)
				    aAdd(aDiver,{nRecno,STR0033,cFilArq}) //"Filial informada no arquivo deve ser a mesma que a filial logada para importação."
					lRet := .F.
				EndIf
				
				If Empty(cProduto)
					aAdd(aDiver,{nRecno,STR0016,cProduto}) // Produto não informado.
					lRet := .F.
				Else
				  Conout("Efetuar busca do produto : " + cProduto)
				   cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SB1.B1_COD,
								SB1.B1_LOCALIZ
						FROM %Table:SB1% SB1
						WHERE SB1.B1_FILIAL = %xFilial:SB1%
						AND SB1.B1_COD = %Exp:cProduto%
						AND SB1.%NotDel%
					EndSql
					If (cAliasQry)->(Eof())
						aAdd(aDiver,{nRecno,STR0017,cProduto}) // Produto não cadastrado no SB1.
						lRet := .F.
					Else
					   Conout("Encontrou produto : " + cProduto)
						If lWmsSass 
						    If (cAliasQry)->B1_LOCALIZ = 'S'
								aAdd(aDiver,{nRecno,STR0018,(cAliasQry)->B1_COD}) // 'Para habilitar controle do WMS Saas, produto não pode ter controle de localização ativa no Protheus.' //'Verificar cadastro de produtos.' 
								lRet := .F.
							EndIf
							If IntWMS((cAliasQry)->B1_COD)
								aAdd(aDiver,{nRecno,STR0019,(cAliasQry)->B1_COD}) // "Produto com controle WMS no Protheus. Não é permitido marcar o contole WMS SAAS"
								lRet := .F.
							EndIf
							
						ElseIf lWmsNew
							If (cAliasQry)->B1_LOCALIZ <> 'S'
								aAdd(aDiver,{nRecno,STR0020,(cAliasQry)->B1_COD}) //"Produto sem controle de localização ativa no Protheus. Verificar cadastro de produtos." 
								lRet := .F.
							EndIf
							If !IntWMS((cAliasQry)->B1_COD)
								aAdd(aDiver,{nRecno,STR0021,(cAliasQry)->B1_COD}) // "Produto sem controle WMS no Protheus."
								lRet := .F.
							EndIf
							//Validação servico 
							If !Empty(cServico)
								cAliasDC5 := GetNextAlias()
								BeginSql Alias cAliasDC5
									SELECT DC5.DC5_TIPO
									FROM %Table:DC5% DC5
									WHERE DC5.DC5_FILIAL = %xFilial:DC5%
									AND DC5.DC5_SERVIC = %Exp:cServico%
									AND DC5.%NotDel%
								EndSql
								If (cAliasDC5)->(!Eof())
                                    If (cAliasDC5)->DC5_TIPO != '1' //servico de entrada
								   		aAdd(aDiver,{nRecno,STR0022,(cAliasQry)->B1_COD}) //"O tipo do serviço informado deve ser de entrada"
								   		lRet := .F.
									EndIf
								Else
								    aAdd(aDiver,{nRecno,STR0023,(cAliasQry)->B1_COD}) //"Serviço não cadastrado."
								   	lRet := .F.
								EndIf 
								(cAliasDC5)->(dbCloseArea())
							EndIf
							//Validação endereço 
							If Empty(cLocal)
								aAdd(aDiver,{nRecno,STR0024,cLocal}) // Armazém não informado.
								lRet := .F.
							Else
								cAliasNNR := GetNextAlias()
								BeginSql Alias cAliasNNR
									SELECT 1
									FROM %Table:NNR% NNR
									WHERE NNR.NNR_FILIAL = %xFilial:NNR%
									AND NNR.NNR_CODIGO = %Exp:cLocal%
									AND NNR.%NotDel%
								EndSql
								If (cAliasNNR)->(Eof())
									aAdd(aDiver,{nRecno,STR0025,(cAliasQry)->B1_COD}) //"Armazém não cadastrado no NNR." 
									lRet := .F.
								EndIf
								(cAliasNNR)->(dbCloseArea())
							EndIf
							If Empty(cEndereco)
								aAdd(aDiver,{nRecno,STR0026,(cAliasQry)->B1_COD}) // "Endereço não informado."
								lRet := .F.
							Else
								cAliasSBE := GetNextAlias()
								BeginSql Alias cAliasSBE
									SELECT SBE.BE_ESTFIS
									FROM %Table:SBE% SBE
									WHERE SBE.BE_FILIAL = %xFilial:SBE%
									AND SBE.BE_LOCAL = %Exp:cLocal%
									AND SBE.BE_LOCALIZ = %Exp:cEndereco%
									AND SBE.%NotDel%
								EndSql
								If (cAliasSBE)->(Eof())
									aAdd(aDiver,{nRecno,STR0027,(cAliasQry)->B1_COD}) // Endereço não cadastrado na SBE.
									lRet := .F.
								EndIf
								(cAliasSBE)->(dbCloseArea())
							Endif
						EndIF
					EndIf
					(cAliasQry)->(dbCloseArea())
				Endif
				If Len(aDiver) == 0
				    Conout("Adiociona array para processamento")
					aAdd(aDadosArq, {cEmpresa,; // [01] Empresa
									cFilArq,;   // [02] Filia de referência do Protheus
									cProduto,;  // [03] Codigo do Produto
									cServico,;  // [04] Codigo do Produto
									cEndereco,; // [05] Codigo do Produto
									cWMSSaas})  // [06] Codigo do Produto
				EndIf
			Else
				If !Empty(cLinha)
					aDiver := {}
					aDadosArq := {}
					Exit
				EndIf
			EndIf  
			FT_FSkip()
		EndDo
	EndIf
	FT_FUse()
	Conout("Fim da função de leitura")
Return lRet

//------------------------------------
/*/{Protheus.doc} WMSA4912RL()
Geração do relatório com as divergências
@author Roselaine Adriano
@version P12
@Since 28/05/2025
@obs Realiza um relatório com base nos dados da tabela temporária
/*/
//------------------------------------
Static Function WMSA4912RL(aDiver,cAliasTmp)
Local cTitle := OemToAnsi(STR0028) // "Divergências importação complemento produto WMS (D1A)"
Local oReport
Local oSection
	// Criacao do componente de impressao
	oReport := TReport():New('WMSA491',cTitle,,{|oReport| ReportPrint(oReport,cAliasTmp)},cTitle)
	oSection := TRSection():New(oReport,STR0029,{cAliasTmp},) // Divergência
	
	TRCell():New(oSection,"INDREC",cAliasTmp,STR0030) // Linha
	TRCell():New(oSection,"DIVER",cAliasTmp,STR0031)  // Mensagem
	TRCell():New(oSection,"CONTE",cAliasTmp,STR0032)  // Conteudo
Return oReport
//------------------------------------
/*/{Protheus.doc} ReportPrint()
Impressão do relatório
@author Roselaine Adriano
@version P12
@Since 28/05/2025
@obs Impressão do relatório
/*/
//------------------------------------
Static Function ReportPrint(oReport,cAliasTmp)
Local oSection1 := oReport:Section(1)
	
	MakeSqlExpr(oReport:GetParam())
	
	oReport:SetMeter((cAliasTmp)->(RecCount()))
	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbSetOrder(1))
	(cAliasTmp)->(dbGoTop())
	
	oSection1:Init()
	oSection1:Cell("INDREC"):SetSize(4)
	oSection1:Cell("DIVER"):SetSize(150)
	oSection1:Cell("CONTE"):SetSize(20)
	
	Do While !oReport:Cancel() .And. !(cAliasTmp)->(Eof())
		oSection1:Cell("INDREC"):Show()
		oSection1:Cell("DIVER"):Show()
		oSection1:Cell("CONTE"):Show()
	
		oSection1:PrintLine()
		oReport:SkipLine()
		
		(cAliasTmp)->(dbSkip())
	EndDo
	oSection1:Finish()
Return Nil
//------------------------------------
/*/{Protheus.doc} WMSA4912PR()
Processamento dos dados
@author Roselaine Adriano
@version P12
@Since 28/05/2025
@obs Realiza a inclusão do complemento do produto WMS D1A
/*/
//------------------------------------
Static Function WMSA4912PR(aDadosArq)
Local nI         := 0
Local cEmpresa   := ""
Local cProduto   := ""
Local cServico   := ""
Local cEndereco  := ""
Local lD1AWSAAS   := .F. 
Local lWmsSass   := SuperGetMv("MV_WMSSAAS",.F.,.F.)
Local cFilArq   := ""
Local lAltera := .F.
Local cAliasQry := Nil 

   Conout("Inicio funcao gravação")
   dbSelectArea("D1A")
   
   ProcRegua(Len(aDadosArq))

	For nI := 1 To Len(aDadosArq)
		incproc()
		cEmpresa  := aDadosArq[nI][1]  // Filia de referência do Protheus
		cFilArq   := aDadosArq[nI][2]  // Filia de referência do Protheus
		cProduto  := aDadosArq[nI][3]  // Codigo do Produto
		cServico  := aDadosArq[nI][4]  // Codigo do Serviço
		cEndereco := aDadosArq[nI][5]  // Endereço
		lD1AWSAAS  := IIf(aDadosArq[nI][6]='S',.T.,.F.)  // Controle Wms Saas
		
		Conout("select para verificar se produto ja existe na D1A")
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D1A.R_E_C_N_O_ RECNOD1A
			FROM %Table:D1A% D1A
			WHERE D1A.D1A_FILIAL = %xFilial:D1A%
			AND D1A.D1A_COD = %Exp:cProduto%
			AND D1A.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			lAltera := .T.
		Else 
		    lAltera := .F. 
		EndIf 
            
		Conout("lAltera = " + cProduto)

		Begin Transaction
				
		If lAltera
			D1A->(dbGoTo((cAliasQry)->RECNOD1A))
			RecLock("D1A",.F.)
			D1A->D1A_SEREPR := cServico
			D1A->D1A_ENDEPR := cEndereco
			D1A->D1A_WSAAS := lD1AWSAAS
			D1A->(MsUnLock())
		Else
			If (lWmsSass .AND. lD1AWSAAS) .OR. (!lWmsSass)
				RecLock("D1A",.T.)
				D1A->D1A_FILIAL	 := xFilial('D1A')
				D1A->D1A_COD     := cProduto
				D1A->D1A_SEREPR  := cServico
				D1A->D1A_ENDEPR  := cEndereco
				D1A->D1A_WSAAS   := lD1AWSAAS
				D1A->(MsUnLock())
			EndIf 
		EndIf
		End Transaction

		(cAliasQry)->(dbCloseArea())

		Conout("Fim gravação  = " + cProduto)
		
	Next nI
	
Return Nil
