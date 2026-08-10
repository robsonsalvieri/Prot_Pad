#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TAFA618.CH"


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA618
@type			function
@description	Rotina de importação de xml para lucros e dividendo        
@author			Karen Honda/Wesley Matos
@since			26/10/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA618(lAutomato, cEveAut, cDir)

	Local cNomWiz	as Character
	Local cDirRead	as Character
	Local aWizard	as Array
	Local lOk		as Logical
	Local aFiles	as Array
	Local cTime		as Character
	Local lMatriz   as Logical
	Local cEvAdic   as Character
	Local lJob      as Logical
	Local cDirJob   as Character
	Local cEAJob	as Character
	Local cBarra    as Character
	Local lSrvLinux as Logical

	Default lAutomato	:= .F.
	Default cEveAut     := ""
	Default cDir     	:= ""
	
	cNomWiz		:= "A618"
	lJob		:= Iif( IsBlind(), .T., .F. )
	cDirRead	:= ""
	aWizard		:= {}
	cEvAdic		:= ""
	cDirJob     := ""
	lOk			:= .T.
	cTime		:= ""
	aFiles		:= {}
	lMatriz		:= .F.
	cBarra      := ""
	lSrvLinux	:= IsSrvUnix()
	cEAJob		:= ""

	DBSelectArea( "C1E" )
	C1E->( DBSetOrder( 3 ) )
	If C1E->( DBSeek( xFilial( "C1E" ) + cFilAnt + "1" ) )
		lMatriz := C1E->C1E_MATRIZ == .T.
	EndIf

	If lMatriz

		If lAutomato .OR. lJob .OR. A618Wizard( cNomWiz )
			//Tratamento para Linux onde a barra é invertida
			cBarra := IIf(lSrvLinux,"/","\")

			If lAutomato .OR. lJob .OR. ApMsgYesNo( STR0001 ) //"Confirma o processamento dos arquivos?"
				//carrego as informações da Wizard
				If xFunLoadProf( cNomWiz, @aWizard ) .OR. lAutomato .OR. lJob

					if lJob
					//Diretório e EvtAdic chamados pelo schedule
						cDirJob  := cBarra + "xml_import" +cBarra	
						cEAJob   := Alltrim(MV_PAR01)
						If !ExistDir(cDirJob)
							FwMakeDir(cDirJob)
						EndIf
					EndIf

					If !lAutomato .AND. !lJob
					//Diretório e EvtAdic da Rotina chamada pelo menu
						cDirRead := aWizard[1,1]
						cEvAdic  := aWizard[1,2]
					Else
					//Desvio para uso na automação e do Schedule
						If cEveAut $ "4010|4020|AutErr" .AND. lAutomato
							cDirRead := cDir
							cEvAdic  := cEveAut
						ElseIf lJob
							cDirRead := cDirJob
							cEvAdic  := cEAJob
						endif
					EndIf

					aFiles := Directory(cDirRead + "*.xml")

					if Len(aFiles) == 0
						MsgAlert(STR0030, STR0004) //"Não ha arquivos com extensão '.xml' na pasta para importação"
						lOk := .F.
					Else
						//Inicio do processamento
						If TAFColumnPos("V4Q_ORIGEM")
							If LockByName('TAF_XML',,.T.)
								cTime := DToS( Date() ) + "-" + Time()
								TAFConOut( STR0002 + cTime) //"Inicio Importação Lucros e Dividendos - TAFA618:"
								FWMsgRun(,{|oSay|XmlImport(oSay, aFiles, cDirRead, @lOk, lAutomato, cEvAdic, lJob )},STR0031,STR0032)

								cTime += CRLF + DToS( Date() ) + "-" + Time()
								TAFConOut( STR0010 + cTime ) //"Fim Importação Lucros e Dividendos TAFA618:"
								UnLockByName('TAF_XML')
							EndIf
						else
							MsgAlert(STR0033, STR0004) //"Dicionário de Dados do TAF desatualizado. Por favor, atualize para o pacote com data maior ou igual a 30/12/2023 disponivel no portal do cliente."  
							lOk := .F.       
						EndIf
					Endif
				Else
					ApMsgStop( STR0011 ) //"Problema encontrado ao carregar o Profile! Tente novamente!"
					lOk := .F.
				EndIf
			Else
				MsgInfo( STR0012 , STR0013 ) //"Processamento cancelado."
			EndIf
		EndIf

		Asize(aWizard,0)
		aWizard := nil
	Else
		If !lAutomato .AND. !lJob
			Aviso( STR0014, STR0015, { STR0016  }, 2 ) //"Esta funcionalidade está disponível apenas para a filial marcada como matriz no complemento cadastral."
		Else
			MsgAlert( STR0015,STR0004 )
		EndIf
	EndIf

Return( lOk )

/*---------------------------------------------------------------/
{Protheus.doc} A618Wizard   
Funcao responsavel pela montagem do Wizard da rotina

@param 
cNomWiz - nome do WIZARD A618

@return 
lRet - Flag de sucesso de processamento, .T. = Wizard concluido com sucesso, .F. = Assistente cancelado

@author Karen Honda
@since 09/10/2023

/---------------------------------------------------------------*/

Static Function A618Wizard ( cNomWiz ) 

Local aTxtApre	as Array
Local aPaineis	as Array
Local lRet		as Logical 

lRet := .F.

aTxtApre := {}
aAdd ( aTxtApre , STR0021 )
aAdd ( aTxtApre , "" )	
aAdd ( aTxtApre , STR0022 )
aAdd ( aTxtApre , STR0023 )

aPaineis := {}
aAdd ( aPaineis , {} )
nPos :=	Len ( aPaineis )
aAdd ( aPaineis[nPos] , STR0024 ) 
aAdd ( aPaineis[nPos] , STR0025 ) 
aAdd ( aPaineis[nPos] , {} )

aAdd (aPaineis[nPos][3], {0,,,,,,,})						
aAdd (aPaineis[nPos][3], {0,,,,,,,})
aAdd (aPaineis[nPos][3], {0,,,,,,,}) 							
aAdd (aPaineis[nPos][3], {0,,,,,,,})

aAdd (aPaineis[nPos][3], {1,STR0026,,,,,,})		
aAdd (aPaineis[nPos][3], {2,,,1,,,,,,,,,{"xFunVldWiz","ECF-DIRETORIO"},,,,,,,,,,,.T.}) 
aAdd (aPaineis[nPos][3], {0,,,,,,,})				
aAdd (aPaineis[nPos][3], {0,,,,,,,})
aAdd (aPaineis[nPos][3], {1,STR0027,,,,,,})
aAdd (aPaineis[nPos][3], {2,,,1,,,,8,,,,{ "xValWizCmp",14,{"",""}},,,,,,,,,,})

aAdd (aPaineis[nPos][3], {0,,,,,,,})							
aAdd (aPaineis[nPos][3], {0,,,,,,,})

lRet	:=	XFUNWizard ( aTxtApre , aPaineis , cNomWiz )

Return ( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} FVerExcl
VerIfica se o Arquivo não está em Uso

@author Karen Honda
@since 09/10/2023
@version 1.0

@param cArq   - Caminho do arquivo a ser verIficado
@Return  lRet - Indica se o Arquivo está em uso

/*///----------------------------------------------------------------
Static Function FVerExcl(cArq)

	Local nHandle := 1
	Local lRet 	:= .F.

	// Devido as exigencias do Sonarqube removemos o parâmentro FO_EXCLUSIVE, não há problema neste caso, pois colocamos um tratamento no uso da própria CopyFile() 
	nHandle := FOPEN(cArq)
	lRet	 := IIf(nHandle < 0,.F.,.T.)
	FCLOSE(nHandle)
	
Return lRet


/*/{Protheus.doc} XmlImport
Faz o processamento dos arquivos XML

@author Wesley Matos
@since 27/10/2023
@version 1.0

@return 
lRet - Status do processamento, .T. = Processamento concluido com sucesso, .F. = Falha no Processamento

/*/
Static Function XmlImport(oSay, aFiles, cDirRead, lOk, lAutomato, cEvAdic, lJob)

Local nx 	    as Numeric
Local cDirLog   as Character
Local cArqTxt   as Character
Local cArquivo  as Character
Local cDirProc  as Character
Local cError    as Character
Local aLayout   as Array
Local nRegAtu   as Numeric
Local nHandle   as Numeric
Local cLogError as Character
Local lRet      as Logical
Local cBarra	as Character
Local lSrvLinux	as Logical

Private oXML   as Object
Default cEvAdic := ''

cBarra      := ""
lSrvLinux	:= IsSrvUnix()
nx 			:= 0
cDirLog 	:= ''
cArqTxt 	:= ''
cArquivo    := ''
cDirProc    := ''
aLayout		:= {}
nRegAtu		:= 0
nHandle		:= 0
cLogError	:= ''
lRet 	    := .T.

oXML    	:= nil

If !lAutomato .AND. !lJob
	oSay:SetText(STR0028)
EndIf

cBarra := IIf(lSrvLinux,"/","\")

For nX := 1 to len(aFiles)

	cArquivo := cDirRead + aFiles[nX][1]
	cArqTxt  := aFiles[nX][1]

	cError := ''
	lOk	:= .T.

	If File( cArquivo )
		//conforme orientação do frame não é preciso tratar as barras. Quando tratadas, ocorre erro no FwMakeDir
		cDirProc := cBarra+ "out" +cBarra+ "XML" +cBarra+ "inproc"
		cDirLog  := cDirRead + "log" +cBarra

		If FVerExcl(cArquivo)
			If FwMakeDir(cDirProc) .and. FwMakeDir(cDirLog)
				If __CopyFile( cArquivo , cDirProc +"\" + cArqTxt)
					If FERASE(cArquivo) <> -1
						oXML := TXMLManager():New()
						If !oXML:ParseFile( cDirProc +"\" + cArqTxt )
							cError := STR0017 + oXml:Error() //"Erro ao ler arquivo XML: "
							lOk := .F.
							lRet := .F.
						Else
							aLayout := oXML:XPATHGETROOTNSLIST()
							If Len(aLayout) > 0
								If "4010" $ aLayout[1][2]
									TAFA619(oXml, cEvAdic, @cError)
									if !Empty(cError)
										lOk := .F.
										lRet := .F.
									EndIf
								ElseIf "4020" $ aLayout[1][2]
									TAFA620(oXml, cEvAdic, @cError)
									if !Empty(cError)
										lOk := .F.
										lRet := .F.
									EndIf
								Else
									lOk := .F.
									lRet := .F.
									cError := STR0018 //"Não foi encontrada a tag xmlns!"
								EndIf
							Else
								//aqui, se não tiver a tag xmlNs, verificar se existe a tag evtRetPf ou evtRetPJ
								If Alltrim(UPPER(oXML:CNAME)) == "EVTRETPF"
									TAFA619(oXml, cEvAdic, @cError)
									if !Empty(cError)
										lOk := .F.
										lRet := .F.
									EndIf
								ElseIf 	Alltrim(UPPER(oXML:CNAME)) == "EVTRETPJ"
									TAFA620(oXml, cEvAdic, @cError)
									if !Empty(cError)
										lOk := .F.
										lRet := .F.
									EndIf
								Else
									lOk := .F.
									lRet := .F.
									cError := STR0019 //"Não foi encontrada a tag evtRetPf ou evtRetPj!"
								EndIf
							EndIf
						EndIf
						cLogError := cDirLog + Rtrim(cEvAdic) + ".log"
						If !lOk
							//Cria o arquivo de log caso ele não exista
							If !File( cLogError )
								nHandle := FCREATE( cLogError )
								FWrite(nHandle, STR0020 + cArqTxt + ": "  + cError + ' - ' + Dtoc(Date()) + " " + Time() + CRLF ) //"Erro no arquivo: "
								FClose( nHandle )
							Else
								nHandle := FOPEN( cLogError , 2)
								FSeek(nHandle, 0, 2)
								FWrite(nHandle, STR0020 + cArqTxt + ": "  + cError + ' - ' + Dtoc(Date()) + " " + Time() + CRLF ) //"Erro no arquivo: "
								FClose( nHandle )
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	nRegAtu++
	If !lAutomato .AND. !lJob
		oSay:SetText( STR0029 + cValTochar(nRegAtu) + " de " + cValTochar(len(aFiles)))
	EndIf
Next nX

If !lRet
	MsgAlert(STR0005 + CRLF+ STR0006 + CRLF+ STR0007, STR0004) //"Processo concluído! Alguns arquivos não puderam ser importados. Favor, verificar o arquivo de LOG."
Else
	MsgInfo( STR0008, STR0009 ) //"Importação realizada com sucesso!"
EndIf

Return lOk


//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Wesley Matos
@since  08/12/2023
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()

	Local aParam  := {}

	aParam := { "P";			//Tipo R para relatorio P para processo
	           	,"TAFA618S";	//Pergunte do relatorio, caso nao use passar ParamDef
	            ,;				//Alias
	            ,;				//Array de ordens
	            ,STR0023 } 		//"Esta rotina realiza a importação de arquivos XMLs de pagamentos de lucros e dividendos para ser enviado a EFD-REINF (R-4010 e R-4020)." 

Return ( aParam )
