#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#Include "FWMVCDef.ch"
#Include "OFIA533.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} OA5330018_ExecImport
	(long_description)
	@type Function
	@author Lucas Oliveira
	@since 28/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function OFIA533()

	Local cPerg			:= "OFIA533"
	Local lSchedule 	:= FWGetRunSchedule()
	Private cCodLogVQL 	:= OA533008K_RegistraLOGVQL(STR0008, /*cCodLogVQL*/, /*lClose*/)

	If !lSchedule
		While Pergunte(cPerg, !lSchedule, STR0022)
			If OA533010K_ParametrosValidos()
				FWMsgRun( ,{|| OA5330018_ExecImport()}, STR0007)
				Exit
			EndIf
		Enddo
	Else
		If OA533010K_ParametrosValidos()
			OA5330018_ExecImport()
		Endif
	Endif

	OA533008K_RegistraLOGVQL(STR0010, cCodLogVQL, .T.)

Return Nil

/*/{Protheus.doc} SchedDef
	Função padrão para Scheduler
	@type  Static Function
	@author Lucas Oliveira
	@since 29/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SchedDef()
	Local cPerg		:= PadR("OFIA533", Len(SX1->X1_GRUPO))
	Local aParam	:= { "P",;
		cPerg,;
		"",;
		"",;
		""}
Return aParam

/*/{Protheus.doc} OA5330018_ExecImport
	(long_description)
	@type Function
	@author Lucas Oliveira
	@since 25/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA5330018_ExecImport()

	If OA533005K_ValidXMLStruct()
		OA533003K_ProcessaArquivoXML()
	Else
		FMX_HELP("OA5330018", STR0009, STR0023)
		OA533008K_RegistraLOGVQL(STR0009, cCodLogVQL, /*lClose*/)
	Endif

Return .T.

/*/{Protheus.doc} OA533003K_ProcessaArquivoXML
	Rotina principal de processamento do XML,
	responsável por gravar as tabelas de serviços, logs
	e lidar com os arquivos
	@type Function
	@author Lucas Oliveira
	@since 25/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533003K_ProcessaArquivoXML()

	Local lRet 				:= .T.
	Local cGrpServ			:= ""
	Local cCodServ 			:= ""
	Local aAreaVO6 			:= {}
	Local aServico			:= {}
	Local nPosSTDCODE		:= 0
	Local nPosWORKOBJECT	:= 0
	Local nPosWORKTYPE		:= 0
	Local nPosECC_KATEGORY	:= 0
	Local nPosTIME 			:= 0
	Local nPosINVOICE_TEXT	:= 0
	Local nQtdMec	  		:= MV_PAR03			// Quantidade de mecanicos.
	Local cCodMarca 		:= PadR(MV_PAR01, TamSX3('VO6_CODMAR')[1]) 	// Cod. Marca.
	Local oXml 				:= TXmlManager():New()
	Local lFirstNodeXML		:= .F.
	Local aGrpSrvNaoLocalizado := {}

	If oXml:ParseFile(MV_PAR02)

		If oXML:DOMHasChildNode() .and. oXML:DOMChildNode()

			aServico 			:= aClone(oXml:DOMGetChildArray())
			nPosSTDCODE 		:= aScan(aServico, {|x| Alltrim(Upper(x[1])) == "STDCODE"})
			nPosWORKOBJECT 		:= aScan(aServico, {|x| Alltrim(Upper(x[1])) == "WORKOBJECT"})
			nPosWORKTYPE 		:= aScan(aServico, {|x| Alltrim(Upper(x[1])) == "WORKTYPE"})
			nPosECC_KATEGORY	:= aScan(aServico, {|x| Alltrim(Upper(x[1])) == "ECC_KATEGORY"})
			nPosTIME 			:= aScan(aServico, {|x| Alltrim(Upper(x[1])) == "TIME"})
			nPosINVOICE_TEXT 	:= aScan(aServico, {|x| Alltrim(Upper(x[1])) == "INVOICE_TEXT"})
			lFirstNodeXML		:= .T.

			While oXML:DOMHasNextNode() .and. oXML:DOMNextNode()

				If lFirstNodeXML .and. oXML:DOMPrevNode() //Reinicia a leitura do XML no primeiro nó para garantir que o primeiro serviço seja gravado corretamente
					lFirstNodeXML := .F.
				Endif

				aServico	:= aClone(oXml:DOMGetChildArray())
				cGrpServ	:= Left(aServico[nPosSTDCODE][2],2)

				If Empty( cGrpServ := FM_SQL("SELECT DISTINCT VOS.VOS_CODGRU FROM "+RetSQLName('VOS')+" VOS WHERE VOS.VOS_FILIAL = '"+xFilial('VOS')+"' AND VOS.VOS_CODMAR = '"+ MV_PAR01 +"' AND VOS.VOS_GRPSER = '"+cGrpServ+"' AND VOS.D_E_L_E_T_ = ' '"))
					If aScan(aGrpSrvNaoLocalizado, {|x| Alltrim(x) == Left(aServico[nPosSTDCODE][2],2)}) == 0
						aAdd(aGrpSrvNaoLocalizado, Left(aServico[nPosSTDCODE][2],2)) // Adiciona grupos da Scania não localizados no Protheus
					Endif
					Loop
				Endif
					
				cCodServ 	:= PadR(Left(aServico[nPosSTDCODE][2],8), TamSX3('VO6_CODSER')[1])
				cTime		:= aServico[nPosTIME][2]
				cECCKat		:= aServico[nPosECC_KATEGORY][2]
				cDescDetal	:= aServico[nPosINVOICE_TEXT][2]
				cDescAbr	:= aServico[nPosWORKOBJECT][2]
				cDescServic	:= aServico[nPosWORKOBJECT][2] + ","+aServico[nPosWORKTYPE][2]

				VO6->(DBSetOrder(3))
				if !VO6->(DBSeek(xFilial("VO6")+ cCodMarca + cGrpServ + cCodServ))
					RecLock("VO6",.T.)
					VO6->VO6_CODMAR := cCodMarca
					VO6->VO6_GRUSER := cGrpServ
					VO6->VO6_CODSER := cCodServ
					VO6->VO6_DESABR := Upper(FWNoAccent(cDescAbr))
					VO6->VO6_DESSER := Upper(FWNoAccent(cDescServic))
					VO6->VO6_CLAHAB := cECCKat
					VO6->VO6_TEMFAB := OA533009K_ConverteTempoXMLParaVO6(cTime)
					VO6->VO6_TEMCON := OA533009K_ConverteTempoXMLParaVO6(cTime)
					VO6->VO6_SERATI := "1"
					VO6->VO6_QTDMEC	:= nQtdMec
					VO6->VO6_SERINT := GetSXENum("VO6","VO6_SERINT")
					ConfirmSx8()
					VO6->(MsUnlock())

					MSMM(,TamSX3("VO6_DESDET")[1] , , FWNoAccent(cDescDetal) ,1	,,, "VO6","VO6_DESMEM")
					
				Else
					VO6->(RecLock("VO6",.F.))
					VO6->VO6_TEMANT := VO6->VO6_TEMFAB
					VO6->VO6_TEMFAB := OA533009K_ConverteTempoXMLParaVO6(cTime)
					VO6->(MsUnlock())
				EndIf

				If ExistBlock("OF533SER")
					ExecBlock("OF533SER",.F.,.F.)
				EndIf
			Enddo
		Endif
	Endif

	OA533008K_RegistraLOGVQL(STR0011, cCodLogVQL, /*lClose*/)

	OA533007K_MostraGruposNaoLocalizados(aGrpSrvNaoLocalizado)

	If ExistBlock("OF533FIM")
		OA533008K_RegistraLOGVQL(STR0012, cCodLogVQL, /*lClose*/)
		ExecBlock("OF533FIM",.F.,.F.)
	EndIf
	
	RestArea(aAreaVO6)

	OA533004K_HandleFile()

Return lRet

/*/{Protheus.doc} OA533005K_ValidXMLStruct
	Confronta o XML utilizado para processamento
	com o Schema correto
	@type user function
	@author user
	@since 24/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533005K_ValidXMLStruct()

	Local oXml := TXmlManager():New()
	
	If oXml:ParseFile(MV_PAR02) .and. oXML:ParseSchema( OA533006K_XMLSchema() )
		oXml:DOMDelAllAtt() // Remove os atributos do dataroot para que o SchemaValidate funcione
	Endif

Return oXML:SchemaValidate()

/*/{Protheus.doc} OA533004K_HandleFile
	Move e/ou apaga o arquivo do diretório conforme
	definições do usuário na tela de parametros
	@type Function
	@author Lucas Oliveira
	@since 25/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533004K_HandleFile()

	Local lRet 			:= .T.
	Local cDrive		:= ""
	Local cDiretorio	:= ""
	Local cNomeArquivo	:= ""
	Local cExtensao		:= ""
	Local lCopyFile		:= ""
	Local nDelFile		:= 0
	
	SplitPath( MV_PAR02, @cDrive, @cDiretorio, @cNomeArquivo, @cExtensao )

	//Cópia do arquivo, caso o MV_PAR04 esteja como "Mover arquivo"
	If MV_PAR04 == 2
		lCopyFile := __CopyFile(MV_PAR02, Alltrim(MV_PAR05)+"\"+Alltrim(cNomeArquivo)+Alltrim(cExtensao))
		OA533008K_RegistraLOGVQL( IIF(lCopyFile, STR0013, STR0014) + STR0015, cCodLogVQL, /*lClose*/)
	EndIf
	
	If MV_PAR04 == 2 .or. MV_PAR04 == 3
		FErase(MV_PAR02) //Apaga o arquivo, caso o MV_PAR04 esteja como "Apagar arquivo" ou esteja sendo movido
		OA533008K_RegistraLOGVQL( IIF(nDelFile == 0, STR0013, STR0014) + STR0016, cCodLogVQL, /*lClose*/)
	Endif

	If MV_PAR04 <> 2 .and. MV_PAR04 <> 3 // Não está movendo, nem excluído o arquivo.
		OA533008K_RegistraLOGVQL( STR0017, cCodLogVQL, /*lClose*/)
	Endif

Return lRet

/*/{Protheus.doc} OA533007K_MostraGruposNaoLocalizados
	Exibe os grupos processados no XML não localizados
	no Protheus (Grupo Montadora)
	@type Function
	@author Lucas Oliveira
	@since 25/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533007K_MostraGruposNaoLocalizados(aGrpSrvNaoLocalizado)

	Local nI					:= 0
	Local cGrpNaoEncontrado 	:= ""
	Default aGrpSrvNaoLocalizado:= {}

	If Len(aGrpSrvNaoLocalizado) > 0
		For nI := 1 To Len(aGrpSrvNaoLocalizado)
			cGrpNaoEncontrado += aGrpSrvNaoLocalizado[nI] + " / "
		Next
		OA533008K_RegistraLOGVQL(STR0019 + " - " + STR0018 + cGrpNaoEncontrado, cCodLogVQL, /*lClose*/)
		FMX_HELP("OA533007K", STR0018 + cGrpNaoEncontrado, STR0019)
	Endif

Return Nil

/*/{Protheus.doc} OA533006K_XMLSchema
	Schema padrão enviado pela Scania para validação do XML
	e utilizado para validar se o XML utilizado para processamento
	segue o padrão correto.
	@type Function
	@author Lucas Oliveira
	@since 25/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533006K_XMLSchema()

	Local cXSD := ""

	cXSD := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
	cXSD += '<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">' + CRLF
	cXSD += '<xsd:element name="dataroot">' + CRLF
	cXSD += 	'<xsd:complexType>' + CRLF
	cXSD += 	'<xsd:sequence>' + CRLF
	cXSD += 		'<xsd:element name="STDTID" minOccurs="0" maxOccurs="unbounded">' + CRLF
	cXSD += 		'<xsd:complexType>' + CRLF
	cXSD += 			'<xsd:sequence>' + CRLF
	cXSD += 			'<xsd:element name="STDCODE" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="LANGUAGE_CODE" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="WORKOBJECT" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="WORKTYPE" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="DESCR" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="VARIANT" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="TIMETYPE" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="ECC_KATEGORY" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="TIME" type="xsd:decimal" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="TU" type="xsd:integer" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="PU" type="xsd:integer" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="INVOICE_TEXT" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="COMPONENT_CODE" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P3TRUCK" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P3BUS" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P4TRUCK" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P4BUS" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P5TRUCK" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P5BUS" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P6TRUCK" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P6BUS" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P4IM" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'<xsd:element name="P5IM" type="xsd:string" minOccurs="0" nillable="true"/>' + CRLF
	cXSD += 			'</xsd:sequence>' + CRLF
	cXSD += 		'</xsd:complexType>' + CRLF
	cXSD += 		'</xsd:element>' + CRLF
	cXSD += 	'</xsd:sequence>' + CRLF
	cXSD += 	'</xsd:complexType>' + CRLF
	cXSD += '</xsd:element>' + CRLF
	cXSD += '</xsd:schema>'

Return cXSD

/*/{Protheus.doc} OA533008K_RegistraLOGVQL
	Função que registra os logs desde o inicio
	do processamento até a conclusão
	@type  Static Function
	@author user
	@since 27/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533008K_RegistraLOGVQL(cMensagemLog, cCodLogVQL, lClose)

	Local oLogger 		:= DMS_Logger():New()
	Local cTipo			:= IIF( FWGetRunSchedule(), STR0020, STR0021)
	Default cMensagemLog:= ""
	Default cTipo		:= ""
	Default cCodLogVQL 	:= ""
	Default lClose		:= .F.

	If Empty(cCodLogVQL)

		cCodLogVQL := oLogger:LogToTable(	{;
			{'VQL_CODVQL',	''},;
			{'VQL_AGROUP',	'OFIA533'	},;
			{'VQL_TIPO'  , 	cTipo		},;
			{'VQL_DADOS' , 	MV_PAR02	},;
			{'VQL_FILORI', 	xFilial()	},;
			{'VQL_MSGLOG', 	cMensagemLog};
		})

	Else
		oLogger:LogToTable(	{;
			{'VQL_CODVQL',	cCodLogVQL	},;
			{'VQL_AGROUP',	'OFIA533'	},;
			{'VQL_TIPO'  , 	cTipo		},;
			{'VQL_DADOS' , 	MV_PAR02	},;
			{'VQL_FILORI', 	xFilial()	},;
			{'VQL_MSGLOG', 	cMensagemLog};
		})

	Endif

	If lClose
		oLogger:CloseOpened(cCodLogVQL)
	Endif

Return cCodLogVQL

/*/{Protheus.doc} OA533008K_RegistraLOGVQL
	Função que converte o tempo enviado no XML
	no formato aceito pelo Protheus (VO6_TEMFAB)
	@type  Static Function
	@author user
	@since 27/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533009K_ConverteTempoXMLParaVO6(cTimeXML)
	Local nTime 		:= 0
	Default cTimeXML	:= "0"

	nTime := Val(cTimeXML) * 100

Return nTime

/*/{Protheus.doc} OA533010K_ParametrosValidos
	Função que verifica se os parametros digitados são
	validados após OK da Pergunte
	@type  Static Function
	@author Lucas Oliveira
	@since 27/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA533010K_ParametrosValidos()

	Local lRet 	:= .T.
	Local cPerg	:= "OFIA533"

	If Empty(MV_PAR02) .or. !File(Alltrim(MV_PAR02))
		FMX_HELP("OA533010K", STR0026, STR0027)
		OA533008K_RegistraLOGVQL("OA533010K-> " + STR0026 + "-" + STR0027, cCodLogVQL, /*lClose*/)
		SetMVValue(cPerg, "MV_PAR02", "")
		lRet := .F.
	Endif

	If MV_PAR04 == 2 .and. (Empty(MV_PAR05) .or. !ExistDir(Alltrim(MV_PAR05)))
		FMX_HELP("OA533010K", STR0028, STR0029)
		OA533008K_RegistraLOGVQL("OA533010K-> " + STR0028 + "-" + STR0029, cCodLogVQL, /*lClose*/)
		SetMVValue(cPerg, "MV_PAR05", "")
		lRet := .F.
	Endif

	If MV_PAR04 <> 2 .and. !Empty(MV_PAR05)// Nenhuma ação ou Apagar arquivo
		SetMVValue(cPerg, "MV_PAR05", "") // Limpa o diretório destino, pois não será utilizado para mover o arquivo
	Endif

Return lRet

/*/{Protheus.doc} OA533002K_ValidPerg
	Função que valida alguns parametros da pergunte em tempo de 
	preenchimento dos parametros
	@type Function
	@author Lucas Oliveira
	@since 25/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function OA533002K_ValidPerg()

	Local lRet 		:= .T.

	If ReadVar() == 'MV_PAR02'

		If !Empty(MV_PAR02) .and. !File(Alltrim(MV_PAR02),0,.F.)
			FMX_HELP("OA533002K", STR0001 , STR0003)
		Endif

		MV_PAR02 := cGetFile( STR0006, STR0022, , "SERVIDOR", .T., 0, .T., .T. )

	EndIf

	If ReadVar() == 'MV_PAR05' .and. MV_PAR04 == 2

		If !Empty(MV_PAR05) .and. !ExistDir(Alltrim(MV_PAR05))
			FMX_HELP("OA533002K", STR0002, STR0004)
		EndIF
		
		MV_PAR05 := cGetFile( STR0005, STR0022, , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. )
	
	EndIf

Return lRet