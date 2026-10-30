#include "protheus.ch"
#include "fileio.ch" 
#include "totvs.ch"
#include "restful.ch"
#include "fwmvcdef.ch"

Static __lOK       := .T.

//<- Encapsulamento: SetOK  ->
Static Function SetOK(xVal)
Return __lOK := xVal

Static Function GetOK()
Return __lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSET
Funcoes...

@param [Obrigatorio] jWSTAF

@author Marcelo Dente
@since 11/04/2018
@version 1.0x

@Notas:
		O primeiro setup deve ser efetuado sempre pelo usuario administrador, pois ele possui acesso master no ambiente
		no segundo setup, será criado um novo usuario para criação das empresas, porem este não irá alterar os dados dos usuarios cadastrados.
/*/
//-------------------------------------------------------------------
Main Function TAFSET(jWSTAF)
Local cRet       := ""
Local xRetFunc   :=""
Local nEmp       := 0
Local cCodEmp    :=""
Local cCodFil    :=""
Local cCodTSS    := ""
Local jLog       := JsonObject():New()
Local jRetUser   := JsonObject():New()
Local aLog       := {}
Local lSchAtivo  := .T.
Local aSM0Area   := {}
Local lRet 		 := .F.
Local nI 		 := 1
Local jDados	 := JsonObject():New()
Local cEndPoint  := ''
Local lAmbiente  := .T.
Local cFilAntBkp :=	''
Local nEmpXMsg	 :=	500 // alinhar com as marcas para reduzirmos a integracao para 100

jSetParc := TAFSETPARC(jWSTAF)

// realizo a preparação do ambiente
lAmbiente := PrepEnv()

jLog['Log'] := ""

If !lAmbiente 
	jLog['Log'] := "Nao foi possível preparar o ambiente (Empresa:0000 / Filial:000000 / Ambiente:" + GetEnvServer() + ")"
	Conout(FwTimeStamp(3) + "   - [TAFSET|Falha] - " + jLog['Log'])
	Return jLog
Else
	Conout(FwTimeStamp(3) + "   - [TAFSET|OK] - Preparacao de ambiente da Empresa:0000 / Filial:000000 / Ambiente:" + GetEnvServer())

	If jSetParc['matriz']

		// Verifica se servidor TSS esta ativo
		lRet:= TSSOK()

		If lRet
			Conout(FwTimeStamp(3) + "   - [TAFSET|OK] - Servico TSS")
		Else
			jLog['Log'] := "Processo suspenso, Servidor TSS nao esta disponivel"
			Conout(FwTimeStamp(3) + "   - [TAFSET|Falha] - " + jLog['Log'])
			Return jLog
		Endif
	Else
		jLog['Log'] += "Tag 'matriz' nao informada na mensagem de integracao. Processo ignorado" + CRLF
	EndIf

	If jSetParc['empresa']

		//Guarda dados da empresa Posicionada
		aSM0Area:=SM0->(GetArea())

		//Tratativa de dados Obrigatorios
		For nEmp:=1 To Len(jWSTAF["empresas"])
			//Limitacao de processamento para nao gerar timeout na comunicacao
			If nEmp > nEmpXMsg
				Exit 
			EndIf 

			cCodEmp := PadR(jWSTAF["empresas"][nEmp]["CODEMPRESA"],4," ")
            cCodFil := PadR(jWSTAF["empresas"][nEmp]["CODFILIAL"],6," ")

            If FWXX8SeekFil( '01', cCodEmp, cCodFil ) //-> Validação para não realizar input de infos que já existam na base de dados.
                Loop 
            EndIf 


			If Empty(jWSTAF["empresas"][nEmp]["M0_NOMECOM"])
				jWSTAF["empresas"][nEmp]["M0_NOMECOM"]:= jWSTAF["empresas"][nEmp]["M0_NOME"]
			EndIf
			If !Empty(jWSTAF["empresas"][nEmp]["M0_DTRE"])
				jWSTAF["empresas"][nEmp]["M0_DTRE"]:= StoD(jWSTAF["empresas"][nEmp]["M0_DTRE"])
			EndIf
			If Empty(jWSTAF["empresas"][nEmp]["M0_INSC"])
				jWSTAF["empresas"][nEmp]["M0_INSC"]:= "ISENTO"
			EndIf
			If Empty(jWSTAF["empresas"][nEmp]["C1E_INDETT"])
				jWSTAF["empresas"][nEmp]["C1E_INDETT"]:= "2"
			EndIf				
			Conout(FwTimeStamp(3) + "   - [TAFSET|OK] - Pre tratativa de dados obrigatorios" )

			//Cadastro de Empresas e Filiais
			xRetFunc := CriaEmpFil({jWSTAF["empresas"][nEmp]}) 
			aAdd(aLog,xRetFunc)
	
			conout("[Processando Empresa] - " + cValtoChar(nEmp) + "/" + cValtoChar(Len(jWSTAF["empresas"]))) 
			conout("[Empresa            ] - " + cCodEmp) 
			conout("[Filial             ] - " + cCodFil)
			conout("[Nome               ] - " + jWSTAF["empresas"][nEmp]["M0_NOME"])
					
			// Posiciona na empresa Criada e inicia parametrizacao
			If FWXX8SeekFil( '01', cCodEmp, cCodFil )
				//Cadastra complemento de Empresas
				xRetFunc := ComplEmp(jWSTAF["empresas"][nEmp]) 
				If !Empty(xRetFunc)
					aAdd(aLog,LogTafSet("ComplEmp",xRetFunc,cCodEmp,cCodFil))
				EndIf
				
				// Altera parâmetro de data inicial do eSocial
				cFilAntBkp	:=	cFilAnt
				cFilAnt	:=	cCodEmp+cCodFil
				xRetFunc := dtInieSocial(jWSTAF["empresas"][nEmp]["dataInicioeSocial"],cCodFil)
				cFilAnt	:=	cFilAntBkp
				If !Empty(xRetFunc)
					aAdd(aLog,LogTafSet("dataInicioeSocial",xRetFunc,cCodEmp,cCodFil))
				EndIf
				
				//Inicio da tratativa especial para empresa Matriz
				If jWSTAF["empresas"][nEmp]["C1E_MATRIZ"] == .T.
					//Cadastro da Empresa no TSS
					xRetFunc := CadTSS() 
					If Len(xRetFunc) < 10
						cCodTSS:=xRetFunc
						xRetFunc:=''
					EndIF	
					
					If !Empty(xRetFunc)
						aAdd(aLog,LogTafSet("CadTSS",xRetFunc,cCodEmp,cCodFil))
					EndIF
					
					//Cadastro de Certificado
					If !Empty(cCodTSS) 
						xRetFunc := EnvCert(jWSTAF["empresas"][nEmp]["certificado"],cCodEmp+cCodFil) 
						If !Empty(xRetFunc)
							aAdd(aLog,LogTafSet("EnvCert",xRetFunc,cCodEmp,cCodFil))
						EndIf
					EndIf
				EndIf
			Else
				jLog['Log'] += "[TAFSET|Falha] - Empresa nao posicionada (" + cCodEmp + "|" + cCodFil + ")" + CRLF
				Conout(FwTimeStamp(3) + "   - " + jLog['Log'])
			EndIf				
		Next nEmp

		RestArea(aSM0Area)
	Else
		jLog['Log'] += "Tag 'empresa' nao informado na mensagem de integracao. Processo ignorado" + CRLF
	EndIf	

	//Versao vigente 
	//eSocial
	If jWSTAF["versaoVigenteeSocial"] <> Nil .And. !Empty(jWSTAF["versaoVigenteeSocial"])
		xRetFunc := vVigeSocial(jWSTAF["versaoVigenteeSocial"]) 
		If !Empty(xRetFunc)
			aAdd(aLog,LogTafSet("versaoVigenteeSocial",xRetFunc))
		EndIf
	EndIf

	//Reinf
	If jWSTAF["versaoVigenteReinf"] <> Nil .And. !Empty(jWSTAF["versaoVigenteReinf"])
		xRetFunc := vVigReinf(jWSTAF["versaoVigenteReinf"]) 
		If !Empty(xRetFunc)
			aAdd(aLog,LogTafSet("versaoVigenteReinf",xRetFunc))
		EndIf
	EndIf

	If jSetParc['schedule']
		//Ativa Agendamento Jobs
		If  (jWsTAF["schedule"][1]["scheduleTransmissao"] == "1") .And.;
			(jWsTAF["schedule"][1]["scheduleValidacao"]   == "1")  .And.;
			(jWsTAF["schedule"][1]["scheduleIntegracao"]  == "1")			
			
			lSchAtivo:= .T.	
		EndIf
	Else
		jLog['Log'] += "Tag 'schedule' nao informada na mensagem de integracao. Processo ignorado" + CRLF
	EndIf

	//Seta o endpoint para retornar aos ERPs
	If jWSTAF["urlSmartClient"] <> Nil .And. !Empty(jWSTAF["urlSmartClient"])		
		cEndPoint      := jWSTAF["urlSmartClient"]
	EndIf
	
	//Cadastro de usuarios	
	If jWSTAF["usuarios"] <> Nil
		jRetUser     := CriaUsu(jWSTAF["usuarios"], cEndPoint) 
		aAdd(aLog,jRetUser)
	Else
		jLog['Log'] += "Tag 'usuarios' nao informado na mensagem de integracao. Processo ignorado" + CRLF
	EndIf

	If jSetParc['schedule']
		//Cadastra Schedule
		xRetFunc := CriaSch(lSchAtivo)

		If !Empty(xRetFunc)
			aAdd(aLog,LogTafSet("CriaSchedule",xRetFunc))
		EndIf
	EndIf	
EndIf

jLog['Logs'] := aLog

If !Empty(cEndPoint	)
	cMailPara	 := "admin.smartfiscal@totvs.com.br"
	cMailAssunto := "TAFSETUP: Processo de contratação concluido: " + cEndPoint
	cMailMsg	 := "Olá, Administrador" + CRLF + CRLF + "Foi realizado a contratação pela topologia " + cEndPoint + CRLF + CRLF +;
					"O resultado da contratação está abaixo:" + CRLF + CRLF + FwJsonSerialize((jLog)) + CRLF + CRLF +;
					"Atenciosamente" + CRLF + "Equipe SMART Fiscal"+ CRLF + CRLF

	// Envia e-mail para o administrador do SMART referente a contratação.
	If !TAFSETMAIL( /*cDe*/,cMailPara,/*cCc*/,/*cCCO*/,cMailAssunto,/*cAnexo*/,cMailMsg)
		Conout(FWTimeStamp(3) + "   - TAFSET|Erro ao enviar e-mail de setup para o administrador")
	EndIf
Endif

// limpo o ambiente para futuras utilizaçães
RpcClearEnv()

Return jLog


//=========================================================================================================================== 
//-------------------------------------------------------------------
/*/{Protheus.doc} CriaEmpFil
Cria empresas e Filiais no ambiente

@param [Obrigatorio] jEmpresas

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaEmpFil(jEmpresas)
Local aRet := {}
Local cRet := ""
Local oCompanyStartup
Local nEmp	:= 0
Local aTmp	:= {}
Local jEmp	:= JsonObject():New()
Local jTmp 

For nEmp := 1 To Len( jEmpresas )
	oCompanyStartup := TAFCompanyStartup():New()

	If jEmpresas[nEmp]['excluir']
		oCompanyStartup:ExcludeCompanies(jEmpresas[nEmp])
	Else
		oCompanyStartup:CreateCompanies(jEmpresas[nEmp])
	Endif

	aRet := oCompanyStartup:GetResult()

	If Len(aRet) > 0
		jTmp := JsonObject():New()

		jTmp['empresa']  :=  jEmpresas[nEmp]["CODEMPRESA"]
		jTmp['filial']   :=  jEmpresas[nEmp]["CODFILIAL"]
		jTmp['status']   :=  aRet[nEmp][1]
		jTmp['mensagem'] :=  aRet[nEmp][2]

		aAdd(aTmp,jTmp)
	Endif

	FreeObj(oCompanyStartup)
Next

jEmp["empresas"] := aTmp

Return jEmp

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaUsu
Cria Usuarios

@param [Obrigatorio] jUsuarios

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaUsu(jUsuarios,cEndPoint)
Local cRet := ""
Local oUserStartup
Local jDados:= JsonObject():New()
Local jAcessos:= JsonObject():New()
Local nUsuario := 0

Default cEndPoint := ''

jAcessos['usuarios'] := Array(4)

oUserStartup := TAFUsersStartup():New()
oUserStartup:CreateUsers(jUsuarios)

cRet := oUserStartup:GetResult()

If Upper(GetEnvServer()) == 'TAF_WS'
	aAdd(cRet["usuarios"], oUserStartup:AlterPswAndEmail( '000201', jUsuarios[1]['email'],'TAFWS' ))
Else
	aAdd(cRet["usuarios"], oUserStartup:AlterPswAndEmail( '000005', jUsuarios[1]['email'],'TAFWS' ))
EndIf

jAcessos:= cRet

For nUsuario:= 1 To Len(jAcessos["usuarios"])
	If jAcessos["usuarios"][nUsuario]["usuario"] <> "erro"
		If jAcessos["usuarios"][nUsuario]["usuario"] == 'TAFWS'
			jAcessos["usuarios"][nUsuario]["email"] := jUsuarios[1]["email"]
		Else
			jAcessos["usuarios"][nUsuario]["email"] := jUsuarios[nUsuario]["email"]
		EndIf
	Else
		SetOk(.F.) 
	EndIf
Next

// envio o email dos usuarios para o cliente
MailTafSet(jAcessos,cEndPoint)

FreeObj(jDados)
FreeObj(oUserStartup)
FreeObj(jAcessos)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ComplEmp
Complemento de Cadastro de Empresa TAF - C1E - S1000

@param [Obrigatorio] jWSTAF

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ComplEmp(jEmpTaf)
Local oModel := Nil
Local oC1EModel := Nil
Local cResult := ""
Local cRet:= ""
Local aCmpCE1 := {"C1E_CODFIL","C1E_MATRIZ","C1E_DTINI","C1E_DESFOL","C1E_REGELT","C1E_SEGMEN","C1E_ENTEDU","C1E_INDETT","C1E_NRETT","C1E_SIGMIN","C1E_NRCERT";
				,"C1E_DTEMCE","C1E_DTVCCE","C1E_NRPRRE","C1E_DTPRRE","C1E_DTDOU","C1E_PAGDOU","C1E_SIAFI","C1E_RPPS","C1E_EFR","C1E_CPNJER";
				,"C1E_NMENTE","C1E_SUBTET","C1E_VLRSUB","C1E_SITESP","C1E_SITPF","C1E_CNPJTR"}

Local cCodEmp:= jEmpTaf["CODEMPRESA"]                                              
Local cCodFil:= jEmpTaf["CODFILIAL"]
Local nCmp:= 0

oModel    := FWLoadModel("TAFA050")  	
oC1EModel := oModel:GetModel("MODEL_C1E")
oCRMModel := oModel:GetModel("MODEL_CRM")

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()		 
											
cCodEmp:= PadR(cCodEmp,4," ")

oC1EModel:SetValue("C1E_FILTAF" , cCodEmp + cCodFil)                                              

For nCmp:=1 To Len(aCmpCE1)
	If aCmpCE1[nCmp] $ "C1E_DTEMCE|C1E_DTVCCE|C1E_DTPRRE|C1E_DTPRRE|C1E_DTDOU" .And. !Empty(jEmpTaf[aCmpCE1[nCmp]])
		oC1EModel:SetValue(aCmpCE1[nCmp] ,  StoD(jEmpTaf[aCmpCE1[nCmp]]))
	ElseIf !Empty(jEmpTaf[aCmpCE1[nCmp]])                                               
		oC1EModel:SetValue(aCmpCE1[nCmp] , jEmpTaf[aCmpCE1[nCmp]])
	EndIf
Next

oCRMModel:SetValue("CRM_CNPJ" , '53113791000122')
oCRMModel:SetValue("CRM_NOME" , 'TOTVS S/A')  	
oCRMModel:SetValue("CRM_CONTAT" , 'MARCELO EDUARDO SANTANNA CONSENTINO')
oCRMModel:SetValue("CRM_DDD" , '11')
oCRMModel:SetValue("CRM_FONE" , '20997373')
oCRMModel:SetValue("CRM_MAIL" , 'MARCELOC@TOTVS.COM.BR')

If oModel:VldData()
	cResult := oC1EModel:GetValue("C1E_ID")
	oModel:CommitData()
	If __lSX8
		ConfirmSX8()
		SetOk(.F.)
	EndIf			  				   		
Else
	If __lSX8	
		RollBackSX8()
		SetOk(.F.)
	EndIf			    
	
	cRet:= "Empresa: " + jEmpTaf["CODEMPRESA"]+ " Filial: " + jEmpTaf["CODFILIAL"] + " - " 
	cRet+= oModel:GetErrorMessage()[6]
Endif

FreeObj(oC1EModel)
FreeObj(oCRMModel)
FreeObj(oModel)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaSch
Cria Agendamento de rotinas TAF

@param lAtivo - Define se sera cadastrado como ativo

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaSch(lAtivo)
Local cRet := ""
Local oTAFSchedStartup

oTAFSchedStartup := TAFSchedStartup():New()

oTAFSchedStartup:CreateSched(lAtivo)

FreeObj(oTAFSchedStartup)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CadTSS
Cadastra empresa no TSS ( C1E_MATRIZ = '1' )

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CadTSS()
Local cRet:= ""
Local cTSSIdEnt:= ""
Local nI:=1

Begin Sequence
	cTSSIdEnt:= TAFRIdEnt(.T.)
	
	For nI:=1 To 10 
		If Empty(cTSSIdEnt)
			Conout("Tentativa de Envio de certificado para TSS: " + cValToChar(nI)+"/10" + CRLF ) 
			cTSSIdEnt:= TAFRIdEnt(.T.)
		Else
			Exit
		EndIf
		Sleep(1000)
	Next	 
	If Empty(cTSSIdEnt)
		cRet:= "Integracao TSS nao Cadastrada , Certificado nao sera integrado"
		SetOk(.F.)
	Else
		cRet:= cTSSIdEnt
	EndIF
End Sequence

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvCert
Envia Certificado para o TSS - ( C1E_MATRIZ = '1' )

@param [Obrigatorio] zzzz

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvCert(jCert,cEmpresa)
Local cRet    		:= ""
Local lRet        	:= .T.
Local nI 			:= 1
Local cCert         :=""

lRet:= TSSOK()

If !lRet
	cRet:= 'Nao foi possível cadastrar certificados, falha na comunicacao com TSS'
	Conout(FwTimeStamp(3) + " - [Falha] - " + cRet)
	Return cRet
EndIf

// Extrair Certificado/senha do Objeto Json jCert
If !Empty(jCert["arquivo"])
	cCert    := jCert["arquivo"]
//	cCert    := StrTran(jCert["arquivo"],"\","")
//	cCert    := StrTran(cCert,Chr(13) + Chr(10),"")
	cCert    := Decode64(cCert) 
EndIf
cSenha   := jCert["senha"]
	
If (Empty(cCert) .OR. Empty(cSenha))
	//"parâmetros Obrigatorios faltando, favor verificar!"
	cRet += "Dados Incompletos"
Else
	//Chama Funcao de Envio de Certificado para TSS
	lRet:= TAFCTrsf(2,cCert,"",cSenha,"","","","","2")
EndIf
If lRet
	Conout(FWTimeStamp(3) + "   - [OK] - Certificado Cadastrado com Exito")
	cRet+= ""
Else
	cRet+= "Problemas na integracao com TSS "
	Conout(FwTimeStamp(3) + "   - [Falha] - " + cRet)
	SetOk(.F.)
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} dtInieSocial
Modifica parâmetro da de Inicio do eSocial por empresa

@param [Obrigatorio] cData

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function dtInieSocial(cData,cCodFil)
Local cRet := ""

Default	cCodFil	:=	''

If !Empty(cData)
	If !(PutMV("MV_TAFINIE",cData))
		cRet+= "MV_TAFINIE nao Alterado"
	Else		
		FWSX6Util():ReplicateParam( "MV_TAFINIE" , '*' , .T. , .T. )
	EndIf
Else
	cRet+="dataInicioeSocial vazio"
	SetOk(.F.)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vVigeSocial
Modifica parâmetro da de Inicio do eSocial

@param [Obrigatorio] cData

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function vVigeSocial(cData)
Local cRet := ""

If !Empty(cData)
	If !(PutMV("MV_TAFVLES",cData))
		cRet+= " MV_TAFVLES nao Alterado "
		SetOk(.F.)
	Else
		FWSX6Util():ReplicateParam( "MV_TAFVLES" , '*' , .T. , .T. )
	EndIf
Else
	cRet+= " versaoVigenteeSocial vazio "
	SetOk(.F.)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vVigReinf
Modifica parâmetro da data de Inicio do Reinf

@param [Obrigatorio] cData

@author Gustavo G. Rueda
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function vVigReinf(cData)
Local cRet := ""

If !Empty(cData)
	If !(PutMV("MV_TAFVLRE",cData))
		cRet+= " MV_TAFVLRE nao Alterado "
		SetOk(.F.)
	Else
		FWSX6Util():ReplicateParam( "MV_TAFVLRE" , '*' , .T. , .T. )
	EndIf
Else
	cRet+= " versaoVigenteReinf vazio "
	SetOk(.F.)
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TSSOK
Verifica se Servico do E-social esta no on-line


@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TSSOK()
Local oWs  := WsSpedCfgNFe():New()
Local lRet := .T.
Local cURL := PadR(SuperGetMV("MV_TAFSURL",,"http://"),250)  
Local nI := 0

oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

For nI:=1 To 10 
	Conout(FwTimeStamp(3) + "   - [>>] - Tentativa de Conexao com Servico TSS: " + cValToChar(nI)+"/10" )

	If !(oWs:CFGCONNECT())
		lRet := .F.
	Else
		lRet:= .T.
		Exit
	EndIf

	Sleep(1000)
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LogTafSet
Log de Retorno centralizador


@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LogTafSet(cRot,cRet,cCodEmp,cCodFil)
Local jLogRet:= JsonObject():New()

Default	cCodEmp	:=	''
Default	cCodFil	:=	''

If !Empty(cRet) 
	jLogRet['empresa']   := cCodEmp
	jLogRet['filial']    := cCodFil
	jLogRet["passo"]     := cRot
	jLogRet["status"] 	 := cRet
	jLogRet['timestamp'] := FwTimeStamp(3) 
	
	Conout(jLogRet['timestamp'] + "   - " + jLogRet["passo"] + " - " + jLogRet["status"] )
Else
	Conout(FwTimeStamp(3) + "   - [OK]" + cRot )
EndIf

Return jLogRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCTrsf
Verifica se o certificado digital foi transferido com sucesso

@author Evandro dos Santos Oliveira
@since 27/01/2014
@version 1.0

@param ${nTipo}	, ${[1]PEM;[2]PFX}
@param ${cCert}	, ${Certificado digital}
@param ${cKey}		, ${Private Key}
@param ${cPassWord}, ${Password}
@param ${cSlot}	, ${Slot}
@param ${cLabel}	, ${Label}
@param ${cModulo}	, ${Modulo}
@param ${cIdHex}	, ${}


@return ${lRetorno}, ${Retorna se a Funcao foi validada}

@see Funcao Original - IsCDReady 18.06.2007
/*/
//-------------------------------------------------------------------
Static Function TAFCTrsf(nTipo,cCert,cKey,cPassWord,cSlot,cLabel,cModulo,cIdHex,cFormato)
Local oWS
Local cIdEnt   := ""
Local lRetorno := .T.
Local cURL     := PadR(GetNewPar("MV_TAFSURL","http://"),250)

Default cIdHex := ""

//==========================================================================
//Obtem o codigo da entidade                                               |
//==========================================================================
If ((!Empty(cCert) .And. !Empty(cKey) .And. !Empty(cPassWord) .And. nTipo == 1) .Or. ;
	(!Empty(cSlot) .And. !Empty(cLabel) .And. !Empty(cPassword) .And. nTipo == 3) .Or. ;
	(!Empty(cSlot) .And. !Empty(cIdHex) .And. !Empty(cPassword) .And. nTipo == 3) .Or. ;
	(!Empty(cCert) .And. !Empty(cPassWord) .And. nTipo == 2)) .Or. !TAFCTSpd(,2)

	If !Empty(cLabel) .and. !Empty(cIdHex)
		Aviso("SPED","Para o tipo de certificado HSM, os campos Label e ID Hexadecimal nao podem ser preenchidos simultaneamente.",{"Ok"},3) //"Para o tipo de certificado HSM, os campos Label e ID Hexadecimal nao podem ser preenchidos simultaneamente."
		lRetorno := .F.
	Else
		cIdEnt := AllTrim(TAFRIdEnt())
		
		If cFormato == '2'
			If !Empty(cIdEnt) .And. lRetorno .And. nTipo <> 3
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN  	:= "TOTVS"
				oWs:cID_ENT     	:= cIdEnt
				oWs:cCertificate	:= cCert

				If nTipo == 1
					oWs:cPrivateKey  := cKey
				EndIf

				oWs:cPASSWORD   	:= AllTrim(cPassWord)
				oWS:_URL        	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"

				If IIF(nTipo==1,oWs:CfgCertificate(),oWs:CfgCertificatePFX())
					Aviso("SPED",IIF(nTipo==1,""/*oWS:cCfgCertificateResult*/,""/*oWS:cCfgCertificatePFXResult*/),{"Ok"},3)
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
				EndIf
			EndIf
		Else
			If nTipo <> 3 .And. !File(cCert)
				Aviso("SPED","Arquivo nao encontrado",{"Ok"},3) //"Arquivo nao encontrado"
				lRetorno := .F.
			EndIf

			If nTipo == 1 .And. !File(cKey) .And. lRetorno
				Aviso("SPED","Arquivo nao encontrado",{"Ok"},3) //"Arquivo nao encontrado"
				lRetorno := .F.
			EndIf

			If !Empty(cIdEnt) .And. lRetorno .And. nTipo <> 3
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN  	:= "TOTVS"
				oWs:cID_ENT     	:= cIdEnt
				oWs:cCertificate	:= TfLoadTXT(cCert)

				If nTipo == 1
					oWs:cPrivateKey  := TfLoadTXT(cKey)
				EndIf

				oWs:cPASSWORD   	:= AllTrim(cPassWord)
				oWS:_URL        	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"

				If IIF(nTipo==1,oWs:CfgCertificate(),oWs:CfgCertificatePFX())
					Aviso("SPED",IIF(nTipo==1,oWS:cCfgCertificateResult,oWS:cCfgCertificatePFXResult),{"Ok"},3)
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
				EndIf
			EndIf
		EndIf

		If !Empty(cIdEnt) .And. lRetorno .And. nTipo == 3
			oWs:= WsSpedCfgNFe():New()
			oWs:cUSERTOKEN   		:= "TOTVS"
			oWs:cID_ENT      	:= cIdEnt
			oWs:cSlot        	:= cSlot
			oWs:cModule      	:= AllTrim(cModulo)
			oWs:cPASSWORD    	:= AllTrim(cPassWord)

			If !Empty( cIdHex )
				oWs:cIDHEX      	:= AllTrim(cIdHex)
				oWs:cLabel      	:= ""
			Else
				oWs:cIDHEX      	:= ""
				oWs:cLabel     	:= cLabel
			EndIf

			If nTipo == 1
				oWs:cPrivateKey  	:= TfLoadTXT(cKey)
			EndIf

			oWs:cPASSWORD    	:= AllTrim(cPassWord)
			oWS:_URL         	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"

			If oWs:CfgHSM()
				Aviso("SPED",oWS:cCfgHSMResult,{"Ok"},3)
			Else
				lRetorno := .F.
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
			EndIf
		EndIf
	endif
Else
	Aviso("SPED", "é Necessario preencher todos os campos que estao habilitados para a correta configuracao do certificado.",{"Ok"},3) //"é Necessario preencher todos os campos que estao habilitados para a correta configuracao do certificado."
	lRetorno := .F.
	SetOk(lRetorno)
EndIf

Return(lRetorno)


/*/{Protheus.doc} AltAdmin
Altera senha do administrador

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AltAdmin()
Local oUserStartup
Local cRet := ""

Conout( FwTimeStamp(3) + "   - [TAFSET|AltAdmin] - Realizando a alteracao da senha do administrador.")
oUserStartup := TAFUsersStartup():New()

oUserStartup:AlterPswAndEmail( '000000', 'admin.smartfiscal@totvs.com.br','admin' )
cRet := oUserStartup:GetResult()

FreeObj(oUserStartup)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PrepEnv
Preparacao de Ambiente

@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PrepEnv(/*cUserX,cSenha,cEmpFil*/)
Local aUser		AS ARRAY
Local lRet 		AS LOGICAL
Local cGrpEmp   AS CHARACTER
Local cEmpFil   AS CHARACTER

// recupero primeiro o usuario de setup
aUser := GetUserSetup()

// Seta o grupo e empresa padrão
cGrpEmp     := '01'
cEmpFil     := '0000000000'

lRet := RpcSetEnv(cGrpEmp,cEmpFil,aUser[1],aUser[2],"TAF","TAFSET")

If !lRet
	jLog['Log'] := "[TAFSET|PrepEnv] - Nao foi possiével preparar o ambiente (Empresa:0000 / Filial:000000 / Ambiente:" + GetEnvServer() + ")." + CRLF + " Usuario/senha invalido. Realizar ajuste no usuario para dar continuidade."
	Conout(FwTimeStamp(3) + "   - [TAFSET|Falha] - " + jLog['Log'])

	// garanto a instancia simples do ambiente
	lRet := RpcSetEnv(cGrpEmp,cEmpFil,,,"TAF","TAFSET")
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSETPARC
(long_description)
	@type  Static Function
	@author Marcelo Dente
	@since 28/05/2018
	@version 1.0
	@param jWSTAF, JSON, Dados recebidos via WebService para parametrizacao
	@return jSetParc, JSON, Atividades que serao executadas apartir da analise do arquivo
/*/
//-------------------------------------------------------------------	
Static Function TAFSETPARC(jWSTAF)
Local jSetParc as Object
Local nEmp as Numeric

jSetParc := JsonObject():New()

If jWSTAF <> Nil
	// Empresas / Matriz / Certificado
	If !Empty(jWSTAF['empresas'])
		jSetParc['empresa']:= .T.
		For nEmp:= 1 to Len(jWSTAF['empresas'])
			If jWSTAF['empresas'][nEmp]['C1E_MATRIZ'] == .T.
				jSetParc['matriz']:= .T.
			EndIf
			
			If (jWSTAF['empresas'][nEmp]['certificado'] <> Nil)
				If !Empty(jWSTAF['empresas'][nEmp]['certificado']['arquivo'])
					jSetParc['certificado']:= .T.
				EndIf
			Endif
		Next
	EndIf
	
	//Schedule
	If (jWSTAF["schedule"] <> Nil)
		If  !Empty(jWSTAF["schedule"][1]["scheduleTransmissao"]) .And. ;
			!Empty(jWSTAF["schedule"][1]["scheduleValidacao"]) .And. ;
			!Empty(jWSTAF["schedule"][1]["scheduleIntegracao"])
		
			jSetParc['schedule']:= .T.
		EndIf
	EndIf

		//Usuarios
	If  !Empty(jWSTAF["usuarios"])
		jSetParc['usuario']:= .T.
	Else
		SetOK(.F.)
	EndIf
EndIf

Return jSetParc

/*/{Protheus.doc} GetUserSetup
(long_description)
	@type  Static Function
	@author Renato Campos
	@since 04/09/2018
	@version 1.0
	@param 
	@return array com o usuario e senha para logar no ambiente de setup
/*/
Static Function GetUserSetup()
Local cUserID    AS CHARACTER
Local aUserSetup AS ARRAY
//Local aUsers     AS ARRAY
//Local nPos       AS NUMERIC
//Local lNew		 AS LOGICAL

cUserID := "000000"

/*
lNew := .F. // Controlo do novo usuario da contratação <> do admin

If lNew
	BEGIN SEQUENCE
		// Seto o ambiente no default somente para pegar os usuarios setados no ambiente para dar continuidade no processo de SETUP
		RpcSetType(3)
		RpcSetEnv( "01","0000000000",,,'TAF','TAFSET')

		aUsers := FWSFAllUsers()		// Array com todos os usuarios do sistema

		RpcClearEnv()
	RECOVER
		aUsers := {"000000","ADMIN"}
	END SEQUENCE

	nPos := aScan( aUsers, { |x| Alltrim(x[2]) == "TAFSETUP"} )

	If nPos > 0 
		cUserID := aUsers[nPos, 2]	
	Else
		cUserID := "000000"
	EndIf
Else
	cUserID := "000000"
Endif
*/

aUserSetup := {cUserID,GetPassWSetup(cUserID)}

Return aUserSetup

/*/{Protheus.doc} GetPassWSetup
(long_description)
	@type  Static Function
	@author Renato Campos
	@since 04/09/2018
	@version 1.0
	@param cUser AS CHARACTER
	@return CHARACTER com a senha padrão de setup do ambiente de setup
/*/
Static Function GetPassWSetup(cUser)
Local cReturn AS CHARACTER

//Default somente atribui se parâmetro recebido for nulo, se for vazio não atribui
Default cUser := "000000"

//If cUser == "000000"
	cReturn := "$I&x)FKisGL?MgzpEZIk;a*7f" 
//Else
//	cReturn := "$I&x)S3t4P@$M4r7Fi5C41*7f"
//Endif

Return cReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} TfLoadTXT
Funcao de leitura de arquivo texto para anexar ao layout

@author Evandro dos Santos Oliveira
@since 03/02/2014
@version 1.0

@param ${cFileImp}	, ${Arquivo texto}

@return ${cTexto}, ${Nome do arquivo texto com path}

@see Função Original - FsLoadTxt 24.10.2006
/*/
//-------------------------------------------------------------------
Static Function TfLoadTXT(cFileImp)

Local cTexto		:= ""
local cCopia		:= ""
local cExt			:= ""
Local nHandle		:= 0
Local nTamanho		:= 0

if left(cFileImp, 1) # "\"
	CpyT2S(cFileImp,"\")
endif

nHandle := FOpen(cFileImp)
nTamanho := Fseek(nHandle,0,FS_END)
FSeek(nHandle,0,FS_SET)
FRead(nHandle,@cTexto,nTamanho)
FClose(nHandle)

SplitPath(cFileImp,/*cDrive*/,/*cPath*/, @cCopia,cExt)
FErase("\"+cCopia+cExt)

Return(cTexto)
