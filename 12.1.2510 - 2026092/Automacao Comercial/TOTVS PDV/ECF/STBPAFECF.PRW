#INCLUDE "TOTVS.CH"  
#INCLUDE "AUTODEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBPAFECF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "DIRECTRY.CH"

Static lPAFECF 	 := NIL
Static aVersaoPAF:= {}
Static aDtPAFMDZ := { .F. , .F. }  //[1] = Gravou Local / [2] = Gravou na RET
Static cCFMD5	 := NIL
Static lHomolPAF := NIL
Static cPathCert := PAF_DirCERT //Define do AUTODEF
Static cDefEnt	 := "000001"
Static cDefPrvKey:= "_cert.pem"
Static cDefKey	 := "_key.pem"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetPath
Function Pega o Caminho do arquivo do PAFECF
@param   	cPath Caminho do arquivo do PAFECF
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRetValue - Caminho do arquivo
/*/
//------------------------------------------------------------------- 
Function STBGerPath(cPath)
Local lRetValue 		:= .T.		// Retorna Valores
Local cSep 			:= Iif( GetRemoteType() <> REMOTE_LINUX, "\", "/" )	// Caminho p linux
Local cPathDefault 	:= Iif( GetRemoteType() <> REMOTE_LINUX, PAF_DirDef , "/totvs paf-ecf" ) // Caminho p linux

Default cPath 			:= ""        	// Define o Caminho onde serao gravados os arquivos do PAF-ECF

// Monta o path do arquivo de acordo com o SIGALOJA.INI
cPath := GetPvProfString("paf-ecf", "patharquivo", cPathDefault, GetClientDir() + "sigaloja.ini") 
cPath := AllTrim(cPath)  

If cPath == ""
	lRetValue := .F. 
Else
    If SubStr(cPath, Len(cPath), 1) <> cSep
    	cPath += cSep
    EndIf   

	 //Cria pasta para salvar arquivos Paf-Ecf.
    If !ExistDir(cPath)
    	lRetValue := (MakeDir(cPath) == 0)
    EndIf    
EndIf

Return lRetValue         

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIsPAF
Function  Verifica se e PAFECF
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lPAFECF - eh Paf-ECF
/*/
//------------------------------------------------------------------- 
Function STBIsPAF()

If lPAFECF == NIL
	lPAFECF := SuperGetMV("MV_LJPAFEC", ,.F.) .AND. LjNfPafEcf(SM0->M0_CGC)
EndIf

Return lPAFECF     

//-------------------------------------------------------------------
/*/{Protheus.doc} STBHomolPaf
Function  Verifica se é homologação do PAF-ECF
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - eh Homologação
/*/
//-------------------------------------------------------------------                                   
Function STBHomolPaf()      
Local cPath:= ""
Local lRet := .F. //Retorno da funçao
Local lArqHomol := .F.

//Nao executa quando Job
If !IsBlind()
	cPath		:= GetClientDir()
	lArqHomol	:= File(cPath+"homologProtheus.paf")
	/*
	Criei o arquivo para garantir que nenhum cliente tera acesso
	pois vi que o cliente questionou a questão da chave de homologacao
	quando na verdade essa chave deve ser habilitada internamente
	*/
	If File(cPath+"SIGALOJA.INI")
		lRet := GetPvProfString("HOMOLOGACAO","homolpaf","0",cPath+"SIGALOJA.INI") == "1"
		lRet := lRet .And. lArqHomol
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STBMd5CF
Efetua a leitura do MD5.
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cRet		- MD5
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBMd5CF()
Local nHandle	:= 0		//handle do arquivo
Local cRet		:= ""		//MD-5 gravado no arquivo criptografado
Local nSize 	:= 0		//Tamanho do arquivo a ser lido
Local cBuffer	:= ""		//Buffer para captura do conteudo do arquivo
Local cFile		:= ""

If IsBlind()
	cRet := STBVerPAFECF("MD5LISTA") //retorna o MD-5 do PAFLISTA	
Else
	cFile := GetClientDir()+"SIGALOJA.VLD" //Arquivo Binário
	
	/*Conforme Requisito IX Ato Cotepe 0608: O MD-5 impresso deve
	ser o codigo armazenado no arquivo Criptografado.            
	No processo de homologacao o arquivo criptografado eh       
	alterado e um cupom eh emitido para teste da origem do codigo*/            
	//Verifica se possui rotina para gravacao do MD-5 no arquivo criptografado
	//Durante homologacao sempre realiza a leitura do MD-5 do arquivo ou armazena em variavel Static(LOJXECF) cLojMD5
	nHandle := fOpen(cFile)
	
	If nHandle <> -1
		//Le o arquivo criptografado
		nSize 	:= FSeek( nHandle, 0, 2 ) 
		FSeek( nHandle, 0 )
		cBuffer := Space( nSize )
		FRead( nHandle, @cBuffer, nSize )
		fClose(nHandle)
	
		//Com a mudança do arquivo o MD5 ficou na ultima posição do arquivo e sem o CHR(10)
		nPos := At(chr(10),cBuffer)
		While nPos > 0
			cBuffer	:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)
			nPos := At(chr(10),cBuffer)
		end
		
		cBuffer := Substr(cBuffer,1,Len(cBuffer)) //Linha do MD-5
				
		//Linha com o MD-5 do PAFLISTA.TXT
		cRet := Decode64(cBuffer) 	// Descriptografa
	Else
		STFMessage("STBMd5CF", "STOP", "Não foi possível abrir o arquivo:" + cFile)   //"Não foi possível abrir o arquivo:"
		STFShowMessage("STBMd5CF")
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGrvMd5Ls
Function  Le o MD5 do arquivo PAFLista
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
/*/
//-------------------------------------------------------------------    
Function STBGrvMd5Ls(lTotvsPdv)
Local nHandle 		:= 0 						//Handle para tratamento do arquivo criptografado a ser criado
Local nSize			:= 0						//Tamanho
Local nPos			:= 0   						//Posicao
Local cConteudo		:= ""             			//Conteudo do arquivo
Local cPath			:= GetClientDir()
Local cArqLista		:= cPath + "paflista.txt"	//Arquivo paflista
Local cArqVld		:= "SIGALOJA.VLD"
Local cBuffer		:= ""						//Buffer
Local cChaveMd5		:= ""
Local lRet			:= .T.						//Retorno
Local lPafNFCe		:= IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.) //Usa PAF-NFC-e c/ Impressora Não Fiscal

Default lTotvsPdv	:= .F.

If !File(cPath+cArqVld)
	lRet := .F.
	If !lPafNFCe
		STFMessage("STBGRVMD5LS", "STOPPOPUP",STR0001 + cPath + cArqVld)//"Não foi possível localizar o arquivo:"
		STFShowMessage("STBGRVMD5LS") 
		LJGrvGT( cArqVld , lTotvsPdv )
		lRet := File(cPath + cArqVld )
	EndIf	
EndIf

//Atualiza MD5 do PAFlista
If lRet
	nHandle := fOpen(cPath+cArqVld)	
	If !(nHandle > 0)
		lRet := .F.
		STFMessage("STBGRVMD5LS2", "STOPPOPUP",STR0002)//"Ocorreu um erro ao ler o arquivo criptografado."
		STFShowMessage("STBGRVMD5LS2") 
	EndIf
EndIf

cChaveMd5	:= STBMd5File( cArqLista )
LjGrvLog( NIL, "PAFLISTA : " + Upper(cChaveMd5))
                  
If lRet
	//Conteudo do arquivo
	nSize 	:= FSeek( nHandle, 0, 2 )
	FSeek( nHandle, 0 )
	cBuffer := Space( nSize )
	FRead( nHandle, @cBuffer, nSize )
	fClose(nHandle)
	
	//Leitura das linhas do arquivo separado pelo CHR(10)
	nPos := At(chr(10),cBuffer)
	While nPos > 0
		cConteudo	+= Substr(cBuffer,1,nPos)
		cBuffer		:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)	
		nPos		:= At(chr(10),cBuffer)
	End
	
	/*
	Nao pode pegar o MD-5 que está no buffer da ultima linha,
	 pois ele deve ser reescrito a partir da variável  cChaveMd5
	*/	
	//Atualiza Arquivo
	fErase(cPath+cArqVld)
	nHandle := fCreate(cPath+cArqVld)	
	
	//MD5 PafLista.txt - usado Encode pois o Encript traz errado o MD-5
	cConteudo   += Encode64(AllTrim( cChaveMd5 ))//Remoção do chr(10) para que não fique incluindo o md5 nas leituras posteriores       

	fWrite(nHandle,cConteudo)			
	fClose(nHandle)
EndIf

 /*
 Conforme Homologacao 2017 - deve acrescentar mais posições no arquivo criptografado
 	 ->Recriar o arquivo PAFEMP.TXT para evitar problemas nos R's do Registro do PAF
 	 ->Validar a alteração desses arquivos
 */
STArqEmp()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBVerPAFECF
Function  Retorna informações da versão do PAF-ECF
@param   	cTipo - Tipo da Informação
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cRet - Informação
/*/
//------------------------------------------------------------------- 
Function STBVerPAFECF( cTipo , lRetMDZ , lRetag)
Local cRet		:= ""			//Retorna versao
Local cMD5		:= "" 			//MD5 do Executável
Local cClientDir:= ""
Local aRet		:= {}
Local nI		:= 0
Local nRecMDZ	:= 0
Local lIsBlind	:= IsBlind()
Local lBliHomol	:= STBHomolPaf() .And. !lIsBlind
Local lTotvsPdv := STFIsPOS()
Local lConRET	:= .T.
Local cAlias	:= GetNextAlias()
Local cQuery	:= ""
Local cMDZSimbol:= "M5"

Default lRetMDZ := .T.
Default lRetag	:= .F.

//Carrega valores "default" evitando erro em modo Debug, 
//so realiza esse trecho caso MsgRemoteLoja nao seja chamado na inicializacao
If Len(aVersaoPAF) == 0 .Or. lBliHomol
	aVersaoPAF	:= Array(6)
	
	If lIsBlind .Or. lRetag
		cMD5 := "DC4F482A5F05235E70712DFE59C32347"
	Else		
		cClientDir := GetClientDir()
		cMD5 := STBMd5File( cClientDir + 'SIGAPAF.EXE')
	EndIf
    
	aVersaoPAF[1] := "INA0062019" 		//Nr. do Laudo de Analise Funcional
	aVersaoPAF[2] := "02.06"  			//Versao da ER/Ato Cotepe (Especificacao de Requisitos)
	aVersaoPAF[3] := cMD5   			//Codigo MD-5 do principal executavel(SIGAPAF.exe)	
	aVersaoPAF[4] := "12.1" 			//Versao Protheus da Homologacao
	aVersaoPAF[5] := "24-06-2019"		//Data da emissão do Laudo
	aVersaoPAF[6] := "94DBB831B0F3C67A412EAC4010EC561F" //MD-5 do PAFLISTA
	cMD5 := aVersaoPAF[6]

	If !lRetag .And. !lIsBlind .And. File(cClientDir + 'PAFLISTA.TXT') 
		cMD5 := STBMd5File( cClientDir + 'PAFLISTA.TXT')
		aDtPAFMDZ[1] := .F.
		aDtPAFMDZ[2] := .F.
	EndIf

	aVersaoPAF[6] := cMD5 //MD5 do PAF-LISTA
EndIf

lConRET := !lRetag .And. STBPafCom(lTotvsPdv, .F.)
If !IsInCallStack("MsgRemoteLoja")
	
	If !aDtPAFMDZ[1]
		cMD5 := ""
		For nI := 1 to Len(aVersaoPAF)
			cMD5 += aVersaoPAF[nI] + "|"
		Next nI
		
		cMD5 := SubStr(cMD5,1,Len(cMD5)-1) //corta o ultimo "|"
		
		aRet := LjxGrvMdz("M5",0,"STBVerPAFECF",cMD5,"")
		aDtPAFMDZ[1] := aRet[1]
	EndIf
	
	If (LjxBGetPaf()[2] .Or. lTotvsPdv) 
		If lConRET .And. !aDtPAFMDZ[2]
			aRet := {}
			If lTotvsPdv
				STBRemoteExecute("LjxGrvMdz",{"M5",0,"STBVerPAFECF",cMD5,""},NIL, .F.,@aRet)
			Else
				aRet := FR271CMyCall("LjxGrvMdz",{"MDZ"},"M5",0,"STBVerPAFECF",cMD5,"")
			EndIf
			
			If ValType(aRet) == "A" .And. (Len(aRet) > 0)
				VarInfo("aRet_LjxGrvMdz", aRet)
				aDtPAFMDZ[2] := aRet[1]
				
				If ValType(aRet[1]) <> "L"
					aDtPAFMDZ[2] := .F.
				EndIf
			EndIf
		Else
			If !aDtPAFMDZ[2]
				Conout(" AVISO - Sem conexão com a retaguarda para gravar dados de MD-5 - Efetue conexão dos WebServices e Comunicação RPC ")
			EndIf
		EndIf
	EndIf
EndIf

If lRetMDZ

	aRet := {}	

	DbSelectArea("MDZ")
	nRecMDZ := MDZ->(Recno())

	#IFDEF TOP

		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())	
		EndIf

		cQuery := " SELECT MDZ_FILIAL, MDZ_COO, MDZ_SIMBOL, MDZ_XMLEPA, R_E_C_N_O_ AS RECNOMDZ "
		cQuery += " FROM " + RetSQLName("MDZ") + " MDZ "
		cQuery += " WHERE MDZ.D_E_L_E_T_ = '' "
		cQuery += " AND MDZ.MDZ_FILIAL = '" + xFilial("MDZ") + "' "
		cQuery += " AND MDZ.MDZ_SIMBOL = '" + cMDZSimbol + "' "

		LJa801ExQu(cAlias,@cQuery)		

		If !(cAlias)->(EOF())
			MDZ->(dbgoto((cAlias)->RECNOMDZ))
			aRet := StrTokArr(AllTrim(MDZ->MDZ_XMLEPA),"|")
		Endif

	#ELSE	

		MDZ->(DbGoTop())

		While !MDZ->(Eof())
			If MDZ->MDZ_SIMBOL == "M5"
				aRet := StrTokArr(AllTrim(MDZ->MDZ_XMLEPA),"|")
				Exit
			EndIf
			MDZ->(DbSkip())
		End
		
	#ENDIF	

	MDZ->(MsGoTo(nRecMDZ))
	
	If Len(aRet) > 0
		For nI := 1 to Len(aRet)
			aVersaoPAF[nI] := aRet[nI]
		Next nI
	EndIf
EndIf

//aVersaoPAF: [1]Nr. do Laudo de Analise Funcional, [2]Versao da ER/Ato Coteep (Especificacao de Requisitos),
// [3]Codigo MD-5 do principal executavel(SIGAPAF.EXE), [4]Versao Protheus da Homologacao
If Upper(cTipo) == "NUMLAUDO"
	cRet := aVersaoPAF[1]
ElseIf Upper(cTipo) == "ERPAFECF"
	cRet := aVersaoPAF[2]
ElseIf Upper(cTipo) == "MD5MASTER"
	cRet := aVersaoPAF[3]
ElseIf Upper(cTipo) == "VERSAOAPLIC"
	cRet := aVersaoPAF[4]
ElseIf Upper(cTipo) == "DATALAUDO"
	cRet := aVersaoPAF[5]
ElseIf Upper(cTipo) == "MD5LISTA"
	cRet := aVersaoPAF[6]
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetPAF
Function  Configura informações da versão do PAF-ECF
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	.T.
/*/
//------------------------------------------------------------------- 
Function STBSetPAF(cLaudo)

//Salva versao da Homologacao do PAF-ECF
aVersaoPAF := {}
If Empty(cLaudo) .Or. (cLaudo == "20190624") .Or. (cLaudo == "12")
	Aadd( aVersaoPAF, "INA0062019" ) 									//Nr. do Laudo de Analise Funcional
	Aadd( aVersaoPAF, "02.06" ) 										//Versao da ER/Ato Cotepe (Especificacao de Requisitos)
	Aadd( aVersaoPAF, "DC4F482A5F05235E70712DFE59C32347")				//Codigo MD-5 do principal executavel(SIGAPAF.EXE)
	Aadd( aVersaoPAF, "12.1" ) 											//Versao Protheus da Homologacao
	Aadd( aVersaoPAF, "24-06-2019")										//Data da emissão do Laudo
	Aadd( aVersaoPAF, "94DBB831B0F3C67A412EAC4010EC561F")				//MD5 do PAFLista
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPerfPAF
Function  Configura informações da versão do PAF-ECF
@param   	cEstado - Estado
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cRet - Perfil
/*/
//------------------------------------------------------------------- 
Function STBPerfPAF(cEstado)  
Local cRet		:= "" //Retorno da função
Local nPosPER	:= 0   //Posicao do Período
Local aPrfReqPAF:={;
				  {"AC", "ND"},; //Perfil de Requisitos
				  {"AL", "ND"},;
				  {"AP", "ND"},;
				  {"AM", "ND"},;
				  {"BA", "ND"},;
				  {"CE", "ND"},;
				  {"DF", "ND"},;
				  {"ES", "ND"},;
				  {"GO", "ND"},;
				  {"MA", "ND"},;
				  {"MS", "W"},;
				  {"MG", "ND"},;
				  {"PA", "ND"},;
				  {"PB", "ND"},;
				  {"PR", "ND"},;
				  {"PE", "ND"},;
				  {"PI", "W"},;
				  {"RJ", "ND"},;
				  {"RN", "ND"},;
				  {"RS", "ND"},;
				  {"RO", "ND"},;
				  {"RR", "ND"},;
				  {"SC", "V"},;
				  {"SP", "ND"},;
				  {"TO", "T"};
				  }

Default cEstado := SM0->M0_ESTCOB	// Estado de cobranca do SIGAMAT.EMP porque e o estado onde o cliente Microsiga sera tributado.
					  
If ( nPosPER := aScan(aPrfReqPAF, { |p| p[1] == cEstado} ) ) > 0
	cRet := aPrfReqPAF[nPosPER, 2] 
EndIf

Return cRet         

//--------------------------------------------------------
/*/{Protheus.doc}STBRETMD5
STBRETMD5 - Retorna o MD5 do Executável
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Nil
/*/
//--------------------------------------------------------
Function STBRETMD5(cPadMD5) 

Default cPadMD5 := "" //Usar somente via Job

If lHomolPAF == NIL
	lHomolPAF := STBHomolPaf()
EndIf

//PAF-ECF: MD-5 do Cupom Fiscal deve ser capturado do arquivo Criptografado, em producao armazena MD-5 em Static para otimizar processo de Emissao do Cupom Fiscal
If cCFMD5 == Nil .OR. lHomolPaf
	cCFMD5 := STBMd5CF()
EndIf

Return cCFMD5

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPafNfce
Verifica se usa Paf com Nfce
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	19/06/2015
@return  	lRet - Utiliza (S) ou (N)
/*/
//-------------------------------------------------------------------                                   
Function STBPafNfce()
Local lRet		:= .F. 		//Retorno da funçao
Local cPath		:= ""
Local cEstacao	:= ""
Local cCodiLG	:= ""
Local lIsBlind 	:= IsBlind() 	
Local lIsMDI 	:= Iif( !lIsBlind, (Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI)), .F. ) //Verifica se acessou via SIGAMDI

//Nao executa quando Job
If !lIsBlind .And. ( !lIsMDI .Or. Select("SLG") > 0 )
	cPath := GetClientDir()
	
	If STBHomolPaf() .And. File(cPath+"SIGALOJA.INI")
		cCodiLG := LJGetStation("LG_CODIGO")
		cEstacao := GetPvProfString("HOMOLOGACAO","estnfce","001",cPath+"SIGALOJA.INI")
		
		If cEstacao == cCodiLG
			lRet	:=	Iif(GetPvProfString("HOMOLOGACAO","pafnfce","0",cPath+"SIGALOJA.INI") == "1",.T.,.F.)
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSaveQrCd

Grava o QrCode em imagem para imprimir no Relatorio Gerencial

@author  Varejo
@version P11
@since   30/06/2015
@return  lRet
/*/
//-------------------------------------------------------------------
Function STSaveQrCd(cCode,cArquivo)
Local lRet		:= .F.
Local cPath 	:= ""        	// Define o Caminho onde serao gravados os arquivos do PAF-ECF
Local cNomeArq	:= ""

If LjxGerPath( @cPath )	
	cPath	:= Iif(Substr(cPath,Len(cPath),1) == '\',cPath,cPath += '\')
	cNomeArq:= 'QrCode'
	
	If File(cPath + cNomeArq + '.BMP')
		FErase(cPath + cNomeArq + '.BMP')
	EndIf
	
	If File(cPath + cNomeArq + '.txt')
		FErase(cPath + cNomeArq + '.txt')
	EndIf
	
	nRet := FCreate(cPath + cNomeArq + '.txt')
	If nRet > 0
		FWrite(nRet,cCode)
		FClose(nRet)
		lRet := .T.
	Else
		LjGrvLog(Nil,"Problema na geração do arquivo de QrCode")
		Conout('QrCode não gerado em arquivo')
		lRet := .F.
	EndIf
	
	If lRet
		nRet := IFQrCode(nHdlECF ,cPath + cNomeArq + '.BMP' , cCode)
		If nRet == 0
			cArquivo	:= cPath + cNomeArq 
			lRet		:= .T.
		Else
			LjGrvLog(Nil,"Problema na geração da imagem de QrCode")
			Conout('QrCode não gerado em imagem')
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STImPFNfce

Criada para não deixa a lógica de impressão da DANFE no ECF 
no LOJRNFCE ( rdmake liberado para cliente ) e assim deixar 
de forma interna e mais padrão

Valida se imprime NFCe com PAF no fonte LOJRNFCE
-Faz os desvios necessários para o funcionamento da DANFE-NFCe com PAF

Esta função pode ser usada somente para verificar se esta com PAF-ECF,
por isso é importante manter o Len(aParams) e deixar o retorno sem
outro tratamento

@author  Varejo
@version P11-P12
@since   23/05/2017
@return  lRet
/*/
//-------------------------------------------------------------------
Function STImPFNfce(aParams)
Local lRet		:= STBPafNfce()
Local cFile		:= ""
Local cPath		:= ""
Local cQrCodeEcf:= ""
Local nHdlTXT	:= 0
Local nHdlTotal	:= 0

Default aParams := {}

If lRet .And. Len(aParams) > 0

	Do Case 
		Case aParams[1] == "C"
			//ER-PAFECF 02.03 - pede a impressão da danfe em RG no ECF
			If IsBlind()
				Conout("Aguarde. Abrindo a Impressora...")
				LjGrvLog( NIL, "Aguarde. Abrindo a Impressora...")
				aParams[3] := IFAbrir(  aParams[2],LJGetStation("PORTIF") )
			Else
				LjMsgRun( "Aguarde. Abrindo a Impressora Fiscal...",, { || aParams[3] := IFAbrir( aParams[2],LJGetStation("PORTIF") ) } )				
			EndIf
		
		Case aParams[1] == "Q"
			cQrCodeEcf := aParams[2] //Chave do QrCode
			STSaveQrCd(cQrCodeEcf,@aParams[3])
		
		Case aParams[1] == "M"
			aParams[2] := "MD-5:" + STBVerPAFECF("MD5MASTER") + CHR(10) //MD5 na impressão da DANFE da NFC-e
		
		Case aParams[1] == "I" //Paf com Nfc-e, deve-se imprimir a danfe como um relatorio gerencial ( somente em homologação de PAF )
			aParams[2] := RemoveTags( aParams[2] ) //função no fonte Loja1305 para remover as tags e evitar erros na dll
			
			//Na Bematech existe um comando especifico para impressão, por isso envio somente a URL
			If "BEMATECH" $ IIf(aParams[3],AllTrim(STFGetStation("IMPFISC")), AllTrim(LjGetStation("IMPFISC")))
				LjxGerPath( @cPath )
				cFile := cPath + 'QrCode.txt'			
				nHdlTXT	:= FOpen(Upper(cFile),FO_READWRITE)
				nHdlTotal:= FSeek(nHdlTXT,0,FS_END)
				FSeek(nHdlTXT,0,FS_SET) //Retorna ao comeco do arquivo
				cQrCodeEcf := FReadStr(nHdlTXT,nHdlTotal)
				FClose(nHdlTXT)
			Else
				cQrCodeEcf := aParams[4]
			EndIf
			STBImpItMF("LojNfce" , aParams[2] , 1 , aParams[3] , cQrCodeEcf)
	EndCase
EndiF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBDirPaf

Criação dos diretórios padrões do paf
@author  Varejo
@version P11-P12
@since   06/06/2017
@return  lRet
/*/
//-------------------------------------------------------------------
Function STBDirPaf()
Local cArquivo	:= "SIGALOJA.INI"
Local cPathINI	:= GetClientDir()
Local cRet		:= ""
Local cMsg		:= ""
Local lRet		:= .T.
Local aPaths	:= {}
Local nX		:= 0

//Caminho padrão para geração de arquivos do PAF-ECF
cRet :=	AllTrim(GetPvProfString("PAF-ECF", "patharquivo", "", cPathINI + cArquivo))
If Empty(cRet) //Insere um caminho padrão
	cRet := PAF_DirDef
	WritePProString("PAF-ECF","patharquivo",cRet,cPathINI + cArquivo)
EndIf

Aadd(aPaths,cRet)
Aadd(aPaths,cRet+PAF_DirStck)
Aadd(aPaths,cRet+PAF_DirRedZ)
Aadd(aPaths,cRet+PAF_ARQMFD)
Aadd(aPaths,cRet+PAF_DirXML)
aadd(aPaths,GetSrvProfString("RootPath","")+PAF_DirCERT)

For nX := 1 to Len(aPaths)
	If !ExistDir(aPaths[nX])
		lRet := (MakeDir(aPaths[nX]) == 0)
		
		If !lRet
			cMsg := " Atenção: o Diretório [" + aPaths[nX] + "]  não criado! Isso prejudica o funcionamento do PAF-ECF!! " + CHR(10) + CHR(13)
			cMsg += " Preencha a sessão [PAF-ECF] no arquivo de configuração " + cArquivo + ", a chaves com diretórios válidos"
			cMsg += " para geração dos arquivos do PAF e dos XML's "  + CHR(10) + CHR(13)
			cMsg += " Exemplo de Configuração do " + cArquivo +": "  + CHR(10) + CHR(13)
			cMsg += " [PAF-ECF] "  + CHR(10) + CHR(13)
			cMsg += " PathArquivo=C:\PAF-ECF\ " + CHR(10) + CHR(13)
			cMsg += " PathArqMFD= C:\ ( preencha de acordo com seu ECF )" + CHR(10) + CHR(13) 
			cMsg += " PathAtoECF=C:\ ( preencha de acordo com seu ECF )" + CHR(10) + CHR(13)
			cMsg += " Para o arquivo de XML crie a pasta informada dentro do caminho configurado na chave PATHARQUIVO"
					
			LjGrvLog( Nil, cMsg)
			Alert(cMsg)
		EndIf
	EndIf
Next nX

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STBMD5Arqs
Função para resgatar o MD-5 dos arquivos de acordo com a versão 
do Paf-ecf

@author Varejo
@since 03/08/2017
@version P12
*/
//-------------------------------------------------------------------
Function STBMD5Arqs( lTotvsPDV , cLaudoPAF )
Local aArqPAFServer	:= {}
Local aArqPAFSmart	:= {}

Default lTotvsPDV := .F.
Default cLaudoPAF := STBVerPAFECF("NUMLAUDO")

If cLaudoPAF == "POL0852017"
	Aadd(aArqPAFSmart, { "5A748FA0726D61933D01EA5432D13FCD ","SMARTCLIENT11.EXE" } )
EndIf

Return { aArqPAFSmart , aArqPAFServer }

//-------------------------------------------------------------------
/*{Protheus.doc} STBPafCSef
Verifica comunicação com o SEFAZ
@author Varejo
@since 03/08/2017
@version P12
*/
//-------------------------------------------------------------------
Function STBPafCSef(cTpTeste)
Local cMV_LJPAFWS := AllTrim(SuperGetMV("MV_LJPAFWS",,""))
Local lRet		  := .T.
Local lSTBPEnvXML := STBPEnvXML()

Default cTpTeste := ""

If lSTBPEnvXML
	IF Empty(cMV_LJPAFWS)
		MsgStop("O parametro MV_LJPAFWS não está preenchido com o WSDL/WebService" +;
				" de envio de XML - Atualize informações conforme Laudo PAF-ECF POL0852017R1")
		lRet := .F.
	EndIf
	
	DbSelectArea("SLG")
	DbSelectArea("MDZ")
	DbSelectArea("SFI")
	
	If !SFI->(ColumnPos("FI_XMLENV")) > 0 .Or. !SFI->(ColumnPos("FI_XMLEPAF")) > 0 .Or. !SFI->(ColumnPos("FI_XMLRPAF")) > 0
		MsgStop("Verifique a existência dos campos da tabela SFI - Resumo da Reducao Z " + CHR(10)+CHR(13)+;
		"FI_XMLENV , FI_XMLEPAF e FI_XMLRPAF - Efetue a aplicação do compatibilizador UPDDISTR com pacote diferencial do PAF-ECF")
		lRet := .F.
	EndIf
	
	If !MDZ->(ColumnPos("MDZ_XMLENV")) > 0 .Or. !MDZ->(ColumnPos("MDZ_XMLEPA")) > 0 .Or. !MDZ->(ColumnPos("MDZ_XMLRPA")) > 0
		MsgStop("Verifique a existência dos campos da tabela MDZ - Dados do ECF " + CHR(10)+CHR(13)+;
		"MDZ_XMLENV , MDZ_XMLEPA e MDZ_XMLRPA - Efetue a aplicação do compatibilizador UPDDISTR com pacote diferencial do PAF-ECF")
		lRet := .F.
	EndIf
	
	If lRet
		//Fazemos uma conexão WSDL - é necessário inserir esse conteúdo no final do link
		If !("?WSDL" $ Upper(cMV_LJPAFWS))
			cMV_LJPAFWS += "?WSDL"
			PutMV("MV_LJPAFWS",cMV_LJPAFWS)
		EndIf

		If Empty(cTpTeste) .Or. cTpTeste == "C" //Valida comunicacao
			lRet := LWSPCnsStt(,.T.)
			If !lRet
				lRet := LWSPCnsStt(,.F.)
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBPafCom
Valida comunicação com a retaguarda do PAF, verificando 
o WebService
@author  	Varejo
@version 	P12
@since   	08/08/2017
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function STBPafCom(lTotvsPdv, lMsg)
Local lRet	:= .F.
Local cWSServer:= ""
Local cMsg	:= ""
Local oWS	:= NIL

DEFAULT lTotvsPdv := .F.
DEFAULT lMsg := .T.

If LjxBGetPaf()[2] .Or. lTotvsPdv
	cWSServer := AllTrim(IIF(lTotvsPdv,STFGetStat("WSSRV"),LjGetStation("WSSRV")))
	oWS := WsFrtPafEcf():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
	oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
	
	STFMessage("STBPafCom1", "RUN", "Verificando Comunicação WS com a Retaguarda",{||lRet := oWs:LstInfoPDV(cEmpAnt,cFilAnt,"")})
	STFShowMessage("STBPafCom1")
	
	If (ValType(lRet) <> "L" .OR. !lRet)
		lRet := .F.
		cMsg := "Erro na Comunicação WS"
		If lMsg
			STFMessage("STBPafCom2", "STOP", cMsg)
			STFShowMessage("STBPafCom2")
		EndIf
		LjGrvLog( NIL, cMsg)
	Else
		oWs:RESET()
		oWs := NIL
		lRet:= .T.
	EndIf
	
	cMsg := "ATENÇÃO" + CHR(10) + CHR(13) +;
			"Este PDV não possui comunicação com a Retaguarda, verifique as configurações de WebService" +;
			" para que a rotina de Registros do PAF e Geração de XML da Redução funcionem corretamente " + CHR(10) + CHR(13) +;
			" Essa comunicação se faz necessária para emissão da REDUÇÃO Z, podendo impedir o processamento da mesma !" + CHR(10) + CHR(13) +;
			" Verifique as configurações de WebService no Cadastro de Estação (LOJA121), Jobs do PAF-ECF na retaguarda e PDV e sua rede"
	
	If !lRet 
	 	If lMsg
	 		MsgAlert(cMsg,"PAF-ECF")
	 	EndIf
	 	
	 	LjGrvLog( NIL, cMsg)
	EndIf
Else
	lRet := .T. //Retaguarda
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBIniPAF
Função de inicialização de algumas funções do PAF

@author  	Varejo
@version 	P12
@since   	08/08/2017
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function STBIniPAF(lIsPos, lEcfSemCom)
Local lRet		:= .T.
Local lSTBPEnvXML:= STBPEnvXML()
Local lLjNfPafEc:= LjNfPafEcf(SM0->M0_CGC) //Já contempla a NFC-e
Local lFtvdVer12:= LjFTVD()
Local cMsg		:= ""

Default lEcfSemCom := .F.

If lFtvdVer12 .Or. !lLjNfPafEc
	lRet := .F.
EndIf

If lRet .And. lSTBPEnvXML

	If !(GetAPOInfo("WSC_XMLPAF.PRW")[4] >= Ctod("06/02/2020"))
		cMsg := "Atenção o fonte WSC_XMLPAF.PRW esta desatualizado em seu RPO - Atualize seu PAF-ECF"
		lRet := .F.
	EndIf
	
	//Função necessária para geração do .ZIP pra envio de arquivo
	If !ExistFunc("FZip") .Or. !(GetBuild() >= "7.00.131227A-20170816")
		cMsg += CHR(10) + CHR(13) + ;
				"Por favor atualize o seu binário conforme especificação do "+;
				"Laudo POL0852017R1 para execução de funções específicas"
		lRet := .F.
	EndIf
	
	If !lRet
		LjGrvLog( "STBIniPAF" , cMsg)
		MsgStop(cMsg)
		
		If !lIsPos //Para TotvsPDV tratado no STFStart		 
			Final( "Término Normal" )
		EndIf
	EndIf
EndIf

If lRet
	If lIsPos
		STBPafCom(.T.,LjGtIsPaf())
	Else
		STBPafCom(.F.,LjxBGetPaf()[2])
	EndIf
	
	STBDirPaf() //Cria diretórios do PAF
	
	//Comunicação com a SEFAZ e parametro, mesmo retornando falso não impede a entrada no sistema
	/*ATO ER-PAF_ECF: 02.05 - Bloco X 
	Requisitos LVIII e LIX */
	LPXVlEnvFi( .F.,.T.,"",.T.,@lEcfSemCom)
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBProcRedZ
Processo de geração dos arquivos da Redução Z
Usado por LOJA,FRT e TOTVSPDV

@author  	Varejo
@version 	P12
@since   	08/08/2017
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function STBProcRedZ(lIsPos	, dDtMvto	, cKeySFI	, cPDV)
Local lRet	:= .T.
Local lXML	:= STBPEnvXML() // Verifica a obrigatoriedade da geração do XML da Redução Z

Default lIsPos := .F.

LjGrvLog(Nil,"Processo de Geração de arquivos do PAF-ECF")

LjGrvLog(Nil,"MDZ de Registros do PAF")
LjxGrvMdz("RP", 0, "REGPAF", "", "")
LjGrvLog(Nil,"Fim da MDZ de Registros do PAF")

//ER 02.06 - Item 6.26.1.4
LjxGrvMdz("RZ", 0, "ReducaoZ", "", "")

If STBPafCom(lIsPos)

	If lXML
		MsgAlert("ATENÇÃO"+CHR(10)+CHR(13)+;
		"Serão gerados os arquivos Referente a Registros do PAF e Arquivo XML de Redução Z,"+;
		"esses arquivos levarão alguns minutos para serem gerados")
	Else 
		MsgAlert("ATENÇÃO"+CHR(10)+CHR(13)+;
		"Serão gerados os arquivos Referente a Registros do PAF,"+CHR(10)+CHR(13)+;
		"esses arquivos levarão alguns minutos para serem gerados")
	EndIf

	If lHomolPaf
		Sleep(5000)
	EndIf
	
	LjGrvLog(Nil,"Geração dos Arquivos do PAF-ECF")
	STBImRgPAF(	dDtMvto, dDtMvto, cPDV, .T.,lIsPos) //Registros do PAF-ECF
	LjGrvLog(Nil,"Fim da Geração dos arquivos do PAF-ECF")
EndIf

/*
Mesmo que não haja comunicação com a SEFAZ, será gerado o XML 
pra ficar guardado no banco e futuramente ser enviado
*/
If lXML //XML Da Redução Z - conforme Requisito LVIII - Ato Cotepe 02.05			
	LjGrvLog(Nil,"Geração do XML de Redução Z")
	LPXFiscoRedZ(.F.,cKeySFI,dDtMvto)
	LjGrvLog(Nil,"Fim da Geração do XML de Redução Z")
	
	LjGrvLog(Nil,"Envio de XML")
	LPXVlEnvFi( .F.,.T.,"R",.T.,,.F.)
	LjGrvLog(Nil,"Fim do Envio do XML")
EndIf

LjGrvLog(Nil,"Fim do Processo de Geração de arquivos do PAF-ECF")

LjGrvLog(Nil,"Geração do arquivo de ECF")
If lIsPos
	STWCripArq()
Else
	LOJA420()
EndIf
LjGrvLog(Nil,"Final da Geração do arquivo de ECF")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPEnvXML
 
 Valida se o Estado envia o XML
 
@author  Varejo
@version P11-P12
@since   01/12/2017
@return  lRet , logico , Tem envio de XML ou Não ?
@obs Regra do parametro:
	Usar juntamente com o AnalisaLeg pois em homologação(2017) 
	esse é um requisito obrigatório portanto
	permite configurar o parametro como falso somente em Estados 
	aonde é comprovadamente opcional esse envio à SEFAZ
/*/
//-------------------------------------------------------------------
Function STBPEnvXML()
Local lRet 		:= .T. 								//XML tem envio obrigatório
Local lMVLJPENXM:= SuperGetMV("MV_LJPENXM",,.F.)
Local lFtvdVer12:= LjFTVD()
Local cDtInicio := "" 								//Data inicio envio bloco X definido no SIGALOJA.INI
Local cSigaloja := GetClientDir()+"SIGALOJA.INI" 	//verifica se existe arquivo sigaloja.ini 

If GetRemoteType() == 5 
	lRet := .F.
Else 
	lRet := !lFtvdVer12 //Faturamento não tem PAF

	If lRet
		If File (cSigaloja)
			cDtInicio := GetPvProfString("PAF-ECF","BlocoX","", cSigaloja)
			If !Empty(cDtInicio) .And. (Len(cDtInicio) == 8)
				IF Stod(cDtInicio) > Date()
					lRet := .F.
				EndIf
			Endif 
		EndIf
		If lRet
			If SM0->M0_ESTCOB $ "SC" //para SC o envio de XML é obrigatório
				lRet := .T.
			Else
				lRet := lMVLJPENXM
			EndIf
		EndIf
	EndIf
Endif 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBHabDelP
 
 Verifica se habilita os deletados no PAF-ECF
 
@author  Varejo
@version P12
@since   12/07/2012
@return  lRet , logico , Habilita ou Não ?
/*/
//-------------------------------------------------------------------
Function STBHabDelP()
Local cUFPAF:= "" //Captura se PAF está em ambiente especifico de homologacao
Local lRet 	:= .F.

//Nao executa quando Job
If !IsBlind()
	/*If File(GetClientDir()+"SIGALOJA.INI")
		cUFPAF := AllTrim(GetPvProfString( "Homologacao","UFPAF","",GetClientDir()+"SIGALOJA.INI"))
	EndIf*/
	cUFPAF := "XX" //vou considerar para todos os preenchicmento dos campos
	lRet := IIf(Empty(cUFPAF),.F.,.T.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPEInFld
 
Inicializa campos parametros no PAF-ECF
 
@author  Varejo
@version P12
@since   26/04/2019
@return  nenhum
/*/
//-------------------------------------------------------------------
Function STBPEInFld()
Local lPos		:= STFIsPOS()
Local lEmitNfce	:= LjEmitNfce()
Local cSerPDV	:= ""
Local cCodSLG	:= ""
Local cECFInfo	:= "" 

If !lEmitNfce

	If lPos
		cSerPDV := AllTrim(STFGetStation("SERPDV"))  
		cCodSLG := STFGetStation("CODIGO")
		cECFInfo:= AllTrim(STFGetStation("ECFINFO"))
	Else
		cSerPDV := AllTrim(LjGetStation("SERPDV")) 
		cCodSLG := LjGetStation("CODIGO")
		cECFInfo:= AllTrim(LjGetStation("ECFINFO"))
	EndIf
	
	//Captura e Preenchimento do campo LG_SERPDV
	//Preciso que esse campo seja preenchido com a série 
	If Empty(cSerPDV)
		LJXGrSerie(nHdlECF, cCodSLG)
	EndIf
	
	If Empty(cECFInfo)
		AjstPAFECF(lPos)
	EndIf
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPRetEnt
 
Retorna a entidade utilizada
 
@author  Varejo
@version P12
@since   01/05/2019
@return  lRet, logico
/*/
//-------------------------------------------------------------------
Function STBPRetEnt( cEntidade ,lRetag	)
Local lRet		:= .F.
Local cCertDir	:= ""
Local cError	:= ""

Default lRetag	:= .F.

cCertDir := IIf(lRetag,"",GetSrvProfString("RootPath","")) + IIf(IsSrvUnix(), cPathCert +"/", cPathCert +"\")

cEntidade := getCfgEntidade(@cError)
If !Empty(AllTrim(cError))
	If !Empty(AllTrim(SuperGetMV("MV_SPEDURL",,""))) .AND. !Empty(AllTrim(SuperGetMV("MV_NFCEURL",,""))) 
		LjGrvLog( Nil, " getCfgEntidade com Erro [" + cError + "]")
		Conout("GetCfgEntidade - cError: " + cError)
	Else 
		LjGrvLog( Nil, " getCfgEntidade retornou  cEntidade = '"+ cEntidade + "' devido aos parametros MV_NFCEURL e MV_SPEDURL vazios")
	Endif 

	lRet := .F.

	//Caso não exista a configuração de TSS, insiro uma pesquisa padrão
	//para que não seja impedido de enviar o XML do PAF
	If File(cCertDir+cDefEnt+cDefPrvKey) .And. File(cCertDir+cDefEnt+cDefKey)
		lRet := .T.
		LjGrvLog( Nil, "Busca pela certificados padrão com a entidade " + cDefEnt)
	EndIf
	
	cEntidade := cDefEnt
Else
	lRet := .T.
EndIf

LjGrvLog( Nil, " Entidade utilizada para a pesquisa do arquivo .PEM - ["+ cEntidade +"]")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STArqEmp
 
Retorna a entidade utilizada
 
@author  Varejo
@version P12
@since   12/06/2019
@return  lRet, logico
/*/
//-------------------------------------------------------------------
Function STArqEmp()
Local nHandle  := 0
Local cArqEmp  := "PAFEMP.TXT"
Local cConteudo:= ""
Local cPath	   := GetClientDir()
Local cArqEXE  := cPath + "SIGAPAF.EXE" //Arquivo paflista
Local cChaveMd5:= STBMd5File( cArqEXE )

FErase(cArqEmp)
nHandle := FCreate(cPath+cArqEmp)

If nHandle > -1
	cConteudo 		:=  "Razao Social:" + Encript(_RAZSOC) //"Razao Social:" 
	fWrite(nHandle,cConteudo + Chr(10) )

	cConteudo 		:=  "CnpjTotvs:" + Encript(_CNPJTOT) //"CnpjTotvs:" 
	fWrite(nHandle,cConteudo + Chr(10) )
	
	cConteudo 		:=  "IE:" + Encript(_INSCEST) //Inscricao Estadual da Totvs
	fWrite(nHandle,cConteudo + Chr(10) )

	cConteudo 		:=  "IM:" + Encript(_INSCMUN) //Inscricao Municipal da Totvs
	fWrite(nHandle,cConteudo + Chr(10) )
	
	cConteudo 		:=  "NomeCom:" + Encript(STBFMModPaf()) //Nome Comercial
	fWrite(nHandle,cConteudo + Chr(10) )

	cConteudo 		:=  "Md5Master:" + Encode64(cChaveMd5) //MD5 do PafLista.txt - o Encript não funciona devendo usar uma outra função para proteger o HASH MD5
	fWrite(nHandle,cConteudo + Chr(10) )

	cConteudo 		:=  "CnpjCli:" + Encript(SM0->M0_CGC) //CNPJ do usuário
	fWrite(nHandle,cConteudo + Chr(10) )
	
	cConteudo 		:=  "NumSer:" + Encript(SLG->LG_SERPDV) //Numero de serie do PDV
	fWrite(nHandle,cConteudo + Chr(10) )
	
	cConteudo 		:=  "VersCom:" + Encript(STBVerPAFECF("VERSAOAPLIC")) //Versao Comercial do PAF
	fWrite(nHandle,cConteudo + Chr(10) )

	cConteudo 		:=  "IEU:" + Encript(SM0->M0_INSC) //Inscricao Estadual do Usuário
	fWrite(nHandle,cConteudo + Chr(10) )
	
	fClose(nHandle)
EndIf

Return nHandle
