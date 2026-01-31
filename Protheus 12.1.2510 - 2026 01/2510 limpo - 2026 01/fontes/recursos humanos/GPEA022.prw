#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'
#Include 'FILEIO.ch'
#INCLUDE 'GPEA022.ch'

#define  CRLF chr(13)+chr(10)

Static cDirAts
Static cArqCfg
Static cGrpPadAts
Static cFilPadAts

/*
{Protheus.doc} GPEA022
Candidatos do Totvs ATS
@author  martins.marcio
@since   03/11/2025
@version 12.1.2510
*/
Function GPEA022()

	Local oBrowse

	DEFAULT cDirAts    := GetPvProfString( GetEnvServer() , "StartPath" , "" , GetAdv97() ) + "ats\"
	DEFAULT cArqCfg    := cDirAts + "config.json"
	DEFAULT cGrpPadAts := PADR("", Len(cEmpAnt))
	DEFAULT cFilPadAts := PADR("", Len(cFilAnt))
	
	// Verifica a configuração do arquivo /system/ats/config.json
	isCfgAtsOk()

	oBrowse := FWmBrowse():New()
	oBrowse:SetMenuDef("")
	oBrowse:SetIgnoreARotina(.T.)
	oBrowse:SetMenuDef("GPEA022")
	oBrowse:SetAlias("RUH")
	oBrowse:SetDescription(OemToAnsi(STR0001)) //"Candidatos ATS"

    //Define as legendas
    oBrowse:AddLegend('AllTrim(RUH->RUH_STATUS) == "1" ',"BR_AZUL" 	    ,OemToAnsi(STR0002)) //"Livre para Admissão"
    oBrowse:AddLegend('AllTrim(RUH->RUH_STATUS) == "2" ',"BR_VERDE" 	,OemToAnsi(STR0003)) //"Admitido"
    oBrowse:AddLegend('AllTrim(RUH->RUH_STATUS) == "3" ',"BR_VERMELHO" 	,OemToAnsi(STR0004)) //"Desprezado"

	oBrowse:Activate()

Return Nil

/*
{Protheus.doc} MenuDef
Carrega as opções de menu
@author  martins.marcio
@since   03/11/2025
@version 12.1.2510
*/
Static Function MenuDef()

	Local aRotina := {}

	Add Option aRotina Title OemToAnsi(STR0005)    Action "VIEWDEF.GPEA022"   Operation 2 Access 0 //"Visualizar"
	Add Option aRotina Title OemToAnsi(STR0006)    Action "GPEA022MNU(1)"      Operation 3 Access 0 //"Admitir"
	Add Option aRotina Title OemToAnsi(STR0007)    Action "GPEA022MNU(2)"      Operation 4 Access 0 //"Desprezar"
	Add Option aRotina Title OemToAnsi(STR0008)    Action "GPEA022MNU(3)"      Operation 3 Access 0 //"Configuração ATS-Protheus"

Return aRotina

/*
{Protheus.doc} ModelDef
Reponsável pela montagem do modelo
@author  martins.marcio
@since   03/11/2025
@version 12.1.2510
*/
Static Function ModelDef()

	Local oModel
	Local oStruRUH	:= FwFormStruct(1,"RUH")

	oModel := MPFormModel():New("GPEA022",/*bPreValidacao*/,/*bTudoOk*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("RUHMASTER",/*Owner*/,oStruRUH)
	oModel:SetPrimaryKey({'RUH_FILIAL','RUH_IDINTE'})
	oModel:SetDescription(OemToAnsi(STR0001)) //"Candidatos ATS"
	oModel:GetModel("RUHMASTER"):SetDescription(OemToAnsi(STR0001))//"Candidatos ATS"

Return oModel

/*
{Protheus.doc} ViewDef
Responsável pela montagem da View
@author  martins.marcio
@since   03/11/2025
@version 12.1.2510
*/
Static Function ViewDef()

	Local oModel:= FwLoadModel("GPEA022")
	Local oStruRUH := FwFormStruct(2,"RUH")
	Local oView := FwFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_RUH",oStruRUH,"RUHMASTER")
	oView:CreateHorizontalBox("SUPERIOR",100,,,,)
	oView:SetOwnerView("VIEW_RUH","SUPERIOR")

Return oView

/*/{Protheus.doc} function isCfgAtsOk
Função que verifica o arquivo config.json na pasta system/ats/
@author martins.marcio
@since 18/11/2025
@version 1.0
/*/
Function isCfgAtsOk()
	Local lRet       := .F.
	Local oJConfig   := JsonObject():New()

	DEFAULT cDirAts    := GetPvProfString( GetEnvServer() , "StartPath" , "" , GetAdv97() ) + "ats\"
	DEFAULT cArqCfg    := cDirAts + "config.json"
	DEFAULT cGrpPadAts := PADR("", Len(cEmpAnt))
	DEFAULT cFilPadAts := PADR("", Len(cFilAnt))

	// Leitura do aruivo de configuração
	lRet := readCfgAts(oJConfig)
	
	If lRet
		// Verifica se o Grupo de Empresas/Filial padrão são válidos
		lRet := !Empty(cGrpPadAts) .And. !Empty(cFilPadAts) .And. FWFilExist(cGrpPadAts, cFilPadAts)
	EndIf
	
	If !(lRet)
		//"Configuração inexistente ou inválida em: " /system/ats/config.json. "Deseja definir o Grupo de Empresas/Fiial padrão agora?"		
		If !IsBlind() .And. MsgNoYes(OemToAnsi(STR0014) + cArqCfg + "." + CRLF + OemToAnsi(STR0015), OemToAnsi(STR0012)) //"Atenção"
			lRet := fMntCfgAts()
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} function fMntCfgAts
Função responsável por gerenciar a manutenção do arquivo de configuração do ATS na pasta system/ats/
@author martins.marcio
@since 25/11/2025
@version 1.0
/*/
Function fMntCfgAts()
	Local lRet     := .F.
	Local oJConfig := JsonObject():New()
	
	DEFAULT cDirAts := GetPvProfString( GetEnvServer() , "StartPath" , "" , GetAdv97() ) + "ats\"
	DEFAULT cArqCfg := cDirAts + "config.json"
	DEFAULT cGrpPadAts := PADR("", Len(cEmpAnt))
	DEFAULT cFilPadAts := PADR("", Len(cFilAnt))

	readCfgAts(oJConfig) // Lê o arquivo de configuração

	lRet := fShowTela()
	If lRet
		oJConfig['companyId'] := cGrpPadAts
		oJConfig['branchId']  := cFilPadAts
		lRet := fGrvCfgAts(oJConfig)
	EndIf

	If lRet
		MsgInfo(OemToAnsi(STR0011), OemToAnsi(STR0012)) //"Configuração do ATS salva com sucesso."##"Atenção"
	EndIf

Return lRet

/*/{Protheus.doc} function readCfgAts
Função responsável pela leitura do arquivo de configuração do ATS na pasta system/ats/
@author martins.marcio
@since 25/11/2025
@version 1.0
/*/
Static Function readCfgAts(oJConfig)
	Local lRet    := .F.
	Local nHandle := 0
	Local cTxtCfg := ""

	DEFAULT oJConfig   := Nil

	If ValType(oJConfig) == "J"
		If !ExistDir(cDirAts)
			If Makedir(cDirAts) <> 0
				MsgAlert(OemToAnsi(STR0013) + cDirAts, OemToAnsi(STR0012)) //"Não foi possível criar o diretório: "##"Atenção"
				Return(.F.)
			EndIf
		EndIf

		If File(cArqCfg)
			nHandle := FOPEN(cArqCfg, FO_READ)

			If !(Ferror() # 0 .Or. nHandle < 0)
				FSEEK(nHandle, 0, 0)
				cTxtCfg := MemoRead(cArqCfg)
				If (oJConfig:FromJSON(DecodeUTF8(cTxtCfg)) == Nil .And. ValType(oJConfig) == "J")
					If !Empty(oJConfig['companyId']) .And. ValType(oJConfig['companyId']) == "C" .And. ;
						!Empty(oJConfig['branchId'])  .And. ValType(oJConfig['branchId'])  == "C"
						cGrpPadAts := oJConfig['companyId']
						cFilPadAts := oJConfig['branchId']
						lRet       := .T.
					EndIf
				EndIf
			EndIf
			FCLOSE(nHandle)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} function fGrvCfgAts
Função responsável por gravar o arquivo de configuração do ATS na pasta system/ats/ 
@author martins.marcio
@since 25/11/2025
@version 1.0
/*/
Function fGrvCfgAts(oJConfig)
	Local lRet     := .F.
	Local nHandle  := 0
	Local cTxtCfg  := ""
	
	DEFAULT oJConfig := Nil

	If ValType(oJConfig) == "J"
		cTxtCfg := oJConfig:ToJSON()
		nHandle := MSFCREATE(cArqCfg, FC_NORMAL)
		IF nHandle >= 0 
			FWRITE(nHandle, EncodeUTF8(cTxtCfg))
			FCLOSE(nHandle)
			lRet := .T.
		Else
			MsgAlert(OemToAnsi(STR0025), OemToAnsi(STR0012))//"Erro ao criar o arquivo de configuração. Verifique as permissões de gravação no diretório."##"Atenção"
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} function fShowTela
Exibe a tela para informar o Grupo de Empresas e Filial padrão do ATS
@author martins.marcio
@since 18/11/2025
@version 1.0
/*/
Static Function fShowTela()

	Local oDlg			:= NIL
	Local oBtFechar		:= NIL
	Local oBtTDN		:= NIL
	Local oGroup		:= NIL
	Local oBtCancel		:= NIL
	Local lRet			:= .F.

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-12 BOLD
	DEFINE FONT oFont1 NAME "Arial" SIZE 0,-12

	DEFINE MSDIALOG oDlg FROM  094,001 TO 400,600 TITLE OemToAnsi(STR0028) PIXEL Style 128 //--"Integração ATS-Protheus"

		@ 010,015	GROUP oGroup TO 085,285 LABEL OemToAnsi(STR0018)  OF oDlg PIXEL //"Bem vindo à configuração da Integração ATS-Protheus"
		oGroup:oFont:=oFont

		@ 025 , 025 SAY OemToAnsi(STR0016)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"Para a gravação dos dados de candidatos do sistema ATS no Protheus, é necessário informar"
		@ 035 , 025 SAY OemToAnsi(STR0017)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"o Grupo de Empresas e a Filial Padrão."
		
		@ 050 , 025 SAY OemToAnsi(STR0019)	SIZE 300,15 OF oDlg PIXEL FONT oFont //"Por que esses campos são necessários?"
		@ 060 , 025 SAY OemToAnsi(STR0020)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"Esta configuração será usada como destino default para garantir a integração dos"
		@ 070 , 025 SAY OemToAnsi(STR0021)	SIZE 300,15 OF oDlg PIXEL FONT oFont1 //"candidatos de unidades do ATS que não possuem CNPJ cadastrado."

		@ 095 , 015 SAY OemToAnsi(STR0022) 	SIZE 150,17 OF oDlg PIXEL FONT oFont//"Informe o Grupo de Empresas Padrão:"
		@ 095 , 160 MSGET cGrpPadAts SIZE 126,07 OF oDlg PIXEL FONT oFont1 WHEN .T. PICTURE "@!" F3 "SM0MRP" //READONLY

		@ 108 , 015 SAY OemToAnsi(STR0023) 	SIZE 150,17 OF oDlg PIXEL FONT oFont//"Informe a Filial Padrão:"
		@ 108 , 160 MSGET cFilPadAts SIZE 126,07 OF oDlg PIXEL FONT oFont1 WHEN .T. PICTURE "@!" F3 "SM0SQB" //READONLY

		@ 130, 170 BUTTON oBtTDN PROMPT OemToAnsi(STR0029) SIZE 037, 012 OF oDlg PIXEL //"Abrir TDN"
		@ 130, 210 BUTTON oBtCancel PROMPT OemToAnsi(STR0030) SIZE 037, 012 OF oDlg PIXEL //"Cancelar"
		@ 130, 250 BUTTON oBtFechar PROMPT OemToAnsi(STR0031) SIZE 037, 012 OF oDlg PIXEL //"OK"

		oBtTDN:bLClicked 	:= {|| ShellExecute("open","https://tdn.totvs.com/pages/viewpage.action?pageId=1012515566","","",1) }
		oBtCancel:bLClicked := {|| oDlg:End() }
		oBtFechar:bLClicked := {|| IIf(fGrpFilOk(@lRet), oDlg:End(), Nil) }
		oDlg:lEscClose     	:= .T.

	ACTIVATE DIALOG oDlg CENTERED

Return lRet

/*/{Protheus.doc} function fGrpFilOk
Valida se o Grupo de Empresas e Filial existem no Protheus
@author martins.marcio
@since 19/11/2025
@version 1.0
/*/
Static Function fGrpFilOk(lRet)

	DEFAULT lRet    := .F.

	If !Empty(cGrpPadAts) .And. !Empty(cFilPadAts)
		lRet := FWFilExist(cGrpPadAts, cFilPadAts)
	EndIf

	If !lRet
		MsgAlert(OemToAnsi(STR0024), OemToAnsi(STR0012)) //"Grupo de Empresas/Filial inválidos. Verifique e tente novamente."##"Atenção"
	EndIf

Return lRet

/*
{Protheus.doc} GPEA022MNU
Função para chamar as static functions.
@author  martins.marcio
@since   03/11/2025
@version 12.1.2510
*/
Function GPEA022MNU(nTipo)

	DEFAULT nTipo := 0

	Do Case
		Case nTipo == 1// Admitir o candidato
			fAdmite()
		Case nTipo == 2// Desprezar o candidato
			fDespreza()
		Case nTipo == 3// Configura o Grupo de Empresas/Filial do ATS
			fMntCfgAts()
	EndCase

Return Nil

/*
{Protheus.doc} fAdmite
Função que admite o candidato integrado.
@author  martins.marcio
@since   03/11/2025
@version 12.1.2510
*/
Static Function fAdmite()

	Local lRet    := .T.

	// Verifica se o registro está livre para admissão
	If RUH->RUH_STATUS != "1"
		lRet := .F.
		Help(,,'HELP',, OemToAnsi(STR0009),1,0 ) //"Apenas candidatos com status 'Livre para Admissão' podem ser admitidos."

	ElseIf Gpea010Mnt( "SRA", /*nReg*/, 3, "", /*lDlgPadSiga*/, /*oDlg*/, /*aObjSize*/, /*lGrvGPE*/, /*leSocGPE*/ ) == 1

		MBrChgLoop( .F. ) // Não apresenta nova tela de inclusão

		// Atualiza o status do candidato para Admitido
		RecLock("RUH", .F.)
		RUH->RUH_STATUS := "2"
		RUH->RUH_DTSRA  := Date()
		RUH->RUH_HRSRA	:= Time()
		RUH->RUH_CODUNI	:= SRA->RA_CODUNIC
		RUH->(MsUnLock())

	EndIf

Return lRet

/*
{Protheus.doc} fDespreza
Função que despreza o candidato integrado.
@author  martins.marcio
@since   03/11/2025
@version 12.1.2510
*/
Static Function fDespreza()
	Local lRet := .T.

	// Verifica se o registro está livre para admissão
	If RUH->RUH_STATUS != "1"
		lRet := .F.
		Help(,,'HELP',, OemToAnsi(STR0010),1,0 ) //"Apenas candidatos com status 'Livre para Admissão' podem ser desprezados."
	Else
		RecLock("RUH", .F.)
		RUH->RUH_STATUS := "3" // 3-Desprezado
		RUH->(MsUnLock())
	EndIf

Return lRet

/*
{Protheus.doc} fRUHToSRA
Carrega os valores da tabela RUH para a memória da SRA.
Função utilizada dentro da função Gpea010Mnt(gpea010.prx)
@author  martins.marcio
@since   04/11/2025
@version 12.1.2510
*/
Function fRUHToSRA()
	Local cMemoTxt  := ""
	Local oJson     := JsonObject():new()
	Local aJsonCpos := {}
	Local oContent  := Nil
	Local aContent  := {}
	Local nX        := 0
	Local nY        := 0
	Local cNomeFunc := ""
	
	cMemoTxt := RUH->RUH_MEMO
	If !Empty(cMemoTxt)
		oJson:FromJSON(cMemoTxt)
	EndIf

	If ValType(oJson) == "J"
		aJsonCpos := oJson:GetNames()
		For nX := 1 To Len(aJsonCpos)
			If LOWER(aJsonCpos[nX]) == "content" 
				If ValType(oJson[aJsonCpos[nX]]) == "J"
					oContent := oJson[aJsonCpos[nX]]
					aContent := oContent:GetNames()
					For nY := 1 To Len(aContent)
						Do Case
							Case LOWER(aContent[nY]) == "fullname" .And. !Empty(oContent[aContent[nY]])
								cNomeFunc := UPPER(fSubstRH(oContent[aContent[nY]]))
								fJsonToSRA("RA_NOME", cNomeFunc, .T.)
								fJsonToSRA("RA_NOMECMP", cNomeFunc, .F.)
							Case LOWER(aContent[nY]) == "socialname" .And. !Empty(oContent[aContent[nY]])
								fJsonToSRA("RA_NSOCIAL", UPPER(fSubstRH(oContent[aContent[nY]])), .F.)
							Case LOWER(aContent[nY]) == "applicant" 
								If ValType(oContent[aContent[nY]]) == "J"
									// Carrega para a SRA os dados do grupo Applicant
									setApplica(oContent[aContent[nY]])
								EndIf
							Case LOWER(aContent[nY]) == "jobopportunity"
								If ValType(oContent[aContent[nY]]) == "J"
									// Carrega para a SRA os dados do grupo JobOpportunity
									setOpportu(oContent[aContent[nY]])
								EndIf
							Case LOWER(aContent[nY]) == "hiringdate"
								fJsonToSRA("RA_ADMISSA", fJToD(oContent[aContent[nY]]), .T.)
						EndCase
					Next nY	
				EndIf	
			EndIf
		Next nX
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJsonToSRA
Carrega o conteudo para a memória da SRA
@author  martins.marcio
@since   07/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fJsonToSRA(cCampo, xValor, lGatilha)
	Local lRet    := .T.
	Local cX3Type := ""

	DEFAULT cCampo   := ""
	DEFAULT xValor   := Nil
	DEFAULT lGatilha := .F.

	cX3Type := FWSX3Util():GetFieldType( cCampo )
	If IsMemVar( cCampo ) .And. cX3Type == ValType( xValor )
		xValor := IIf( cX3Type == "C", PADR( xValor, Len( &( "M->" + cCampo ) ) ), xValor )
		&( "M->" + cCampo ) := xValor
		If lGatilha
			RunTrigger(1, NIL, NIL, NIL, cCampo)
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function setApplica
Carrega o conteudo de Applicant para os Campos da SRA
@author  martins.marcio
@since   11/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function setApplica(oApplicant)

	Local aApplicant := {}
	Local nI         := 0
	Local nGenero    := 0
	Local oAddress   := Nil
	Local oDiversity := Nil

	DEFAULT oApplicant := Nil

	If ValType(oApplicant) == "J"
		aApplicant := oApplicant:GetNames()
		For nI := 1 To Len(aApplicant)
			Do Case
				Case LOWER(aApplicant[nI]) == "cpf"
					fJsonToSRA("RA_CIC", fSoNumeros(oApplicant[aApplicant[nI]]), .F.)
				Case LOWER(aApplicant[nI]) == "email"
					fJsonToSRA("RA_EMAIL", oApplicant[aApplicant[nI]], .F.)
				Case LOWER(aApplicant[nI]) == "birthday"
					fJsonToSRA("RA_NASC", fJToD(oApplicant[aApplicant[nI]]), .F.)
				Case LOWER(aApplicant[nI]) == "telephonenumber"
					fJsonToSRA("RA_TELEFON", fSoNumeros(oApplicant[aApplicant[nI]]), .F.)
				Case LOWER(aApplicant[nI]) == "gender"
					If ValType(oApplicant[aApplicant[nI]]) == "N" 
						nGenero := oApplicant[aApplicant[nI]]
						If nGenero == 0 .Or. nGenero == 1
							fJsonToSRA("RA_SEXO", IIf(nGenero == 0, "F", "M"), .F.)
						EndIf
					EndIf
				Case LOWER(aApplicant[nI]) == "address"
					If ValType(oApplicant[aApplicant[nI]]) == "J"
						oAddress := oApplicant[aApplicant[nI]]
						setAddress(oAddress)
					EndIf
				Case LOWER(aApplicant[nI]) == "diversity"
					If ValType(oApplicant[aApplicant[nI]]) == "J"
						oDiversity := oApplicant[aApplicant[nI]]
						setDefici(oDiversity)
					EndIf
			EndCase
		Next nI
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function setAddress
Carrega o conteudo de Address para os Campos da SRA
@author  martins.marcio
@since   11/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function setAddress(oAddress)
	Local aAddress   := {}
	Local nX         := 0
	Local aLogradour := {}
	Local xInfo      := ""
	Local cCampo     := ""
	Local cCodMun    := ""
	Local cNomeMun   := ""
	Local cEstado   := ""

	DEFAULT oAddress := Nil

	aAddress := oAddress:GetNames()
	If Len(aAddress) > 0
		For nX := 1 To Len(aAddress)
			cCampo := aAddress[nX]
			xInfo  := oAddress[aAddress[nX]]
			If ValType(xInfo) == "C"
				Do Case
					Case LOWER(cCampo) == "zipcode"
						fJsonToSRA("RA_CEP", fSoNumeros(xInfo), .F.)
					Case LOWER(cCampo) == "cityname" .And. !Empty(xInfo)
						cNomeMun := UPPER(fSubstRH(xInfo))
						fJsonToSRA("RA_MUNICIP", cNomeMun, .F.)
					Case LOWER(cCampo) == "statesmallname" .And. !Empty(xInfo)
						cEstado := UPPER(fSubstRH(xInfo))
						fJsonToSRA("RA_ESTADO", cEstado, .F.)
					Case LOWER(cCampo) == "street"
						aLogradour := fCargaLogr(UPPER(xInfo),"")
						If ValType(aLogradour) == "A" .And. Len(aLogradour) >= 3
							fJsonToSRA("RA_LOGRTP", aLogradour[1], .T.)
							fJsonToSRA("RA_LOGRDSC", aLogradour[2], .T.)
							fJsonToSRA("RA_LOGRNUM", aLogradour[3], .T.)
						EndIf
					Case LOWER(cCampo) == "complement" .And. !Empty(xInfo)
						fJsonToSRA("RA_COMPLEM", UPPER(fSubstRH(xInfo)), .F.)
					Case LOWER(cCampo) == "neighborhoodname" .And. !Empty(xInfo)
						fJsonToSRA("RA_BAIRRO", UPPER(fSubstRH(xInfo)), .F.)
				EndCase
			EndIf
		Next nX

		// Busca o código do município(RA_CODMUN) na tabela CC2
		If !Empty(cNomeMun) .And. !Empty(cEstado)
			cCodMun := fGetCodMun(PADR(cEstado,2), cNomeMun)
			If !Empty(cCodMun)
				fJsonToSRA("RA_CODMUN", cCodMun, .T.)
			EndIf
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function setDefici
Carrega o conteudo de Diversity para os Campos da SRA
@author  martins.marcio
@since   11/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function setDefici(oDiversity)
	Local   aDiversity := {}
	Local   nX         := 0
	Local   cTpDefFi   := ""
	Local   aTpDefFi   := {}
	Local   cRADefis   := "2"

	DEFAULT oDiversity := Nil

	aDiversity := oDiversity:GetNames()	
	If Len(aDiversity) > 0
		For nX := 1 To Len(aDiversity)
			IF ValType(oDiversity[aDiversity[nX]]) == "L"
				If LOWER(aDiversity[nX]) == "physical" .And. oDiversity[aDiversity[nX]] == .T.
					cRADefis := "1"						
					aAdd(aTpDefFi, "1")
				ElseIf LOWER(aDiversity[nX]) == "auditory" .And. oDiversity[aDiversity[nX]] == .T.
					aAdd(aTpDefFi, "2")
				ElseIf LOWER(aDiversity[nX]) == "visual" .And. oDiversity[aDiversity[nX]] == .T.
					aAdd(aTpDefFi, "3")
				ElseIf LOWER(aDiversity[nX]) == "intellectual" .And. oDiversity[aDiversity[nX]] == .T.
					aAdd(aTpDefFi, "4")
				EndIf
			EndIf
		Next nX
		
		fJsonToSRA("RA_DEFIFIS", cRADefis, .F.)	//Deficiente Físico: 1-Sim;2-Não
		
		cTpDefFi := IIf(Empty(aTpDefFi), "0", IIf(Len(aTpDefFi) > 1, "5", aTpDefFi[1]))
		fJsonToSRA("RA_TPDEFFI", cTpDefFi, .T.) //0=Nao é portador de deficiência;1=Fisica;2=Auditiva;3=Visual;4=Intelectual (Mental);5=Multipla;6=Reabilitado
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function setOpportu
Carrega o conteudo de Opportunity para os Campos da SRA
@author  martins.marcio
@since   11/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function setOpportu(oJobOpport)

	Local cDepto := ""
	Local cCargo := ""
	
	DEFAULT oJobOpport := Nil

	//RA_DEPTO
	If oJobOpport:hasProperty("Departaments") .And. ValType(oJobOpport['Departaments']) == "A"
		cDepto := oJobOpport['Departaments'][1]['IntegrationId']
		If ValType(cDepto) == "C"
			DbSelectArea("SQB")
			DbSetOrder(1)
			If SQB->(DbSeek(xFilial("SQB")+AllTrim(cDepto)))
				fJsonToSRA("RA_DEPTO", AllTrim(cDepto), .T.)
			EndIf
		EndIf
	EndIf

	//RA_CARGO
	If oJobOpport:hasProperty("Positions") .And. ValType(oJobOpport['Positions']) == "A"
		cCargo := oJobOpport['Positions'][1]['IntegrationId']
		If ValType(cCargo) == "C"
			DbSelectArea("SQ3")
			DbSetOrder(1)
			If SQ3->(DbSeek(xFilial("SQ3")+AllTrim(cCargo)))
				fJsonToSRA("RA_CARGO", AllTrim(cCargo), .T.)
			EndIf
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetCodMun
Retorna o código do município da tabela CC2 a partir do nome e estado.
@author  martins.marcio
@since   17/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fGetCodMun(cUF, cNomeMun)
	Local cCodMun := ""
	
	DEFAULT cUF      := ""
	DEFAULT cNomeMun := ""
	
	If !Empty(cUF) .And. !Empty(cNomeMun)
		DbSelectArea("CC2")
		DbSetOrder(4) //CC2_FILIAL + CC2_EST + CC2_MUN
		If CC2->(DbSeek(xFilial("CC2") + cUF + AllTrim(cNomeMun)))
			cCodMun := AllTrim(CC2->CC2_CODMUN)
		EndIf
	EndIf

Return cCodMun

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSoNumeros
Função que filtra apenas os números de uma string.
@author  martins.marcio
@since   07/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fSoNumeros(cTexto)
	Local cRet     := ""
	Local nY       := 0
	Local cCharY   := ""
	Local cDigitos := "0123456789"  // Conjunto de caracteres aceitos

	If ValType(cTexto) == "C"
		For nY := 1 To Len(cTexto)
			cCharY := SubStr(cTexto, nY, 1)
			If cCharY $ cDigitos
				cRet += cCharY
			EndIf
		Next nY
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   05/11/2025
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet        := sToD("")

	DEFAULT cDateJson := ""
	DEFAULT cDtType   := "D"

	If !Empty(cDateJson)
		cDateJson := LEFT(StrTran( cDateJson, "-", "" ), 8)
	EndIf

	dRet := IIf(cDtType =="D", sToD( cDateJson ), cDateJson )

Return dRet
