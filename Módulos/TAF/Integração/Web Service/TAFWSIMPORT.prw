//#include "tafxdef.ch"
#include "protheus.ch"
#include "apwebsrv.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFWSIMPORT
Funcao declarada para que o fonte esteja disponivel no AppMap

@author Daniel Magalhaes
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFWSIMPORT()

MsgAlert("Utilize o client de Webservice TAFWSIMPORT")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WSStruct IncludeResult
Estrutura de dados do Webservice para exibir o resultado do metodo
IncludeNewXML

@author Daniel Magalhaes
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
//Estruturas de saida
WSStruct IncludeResult
	WSData CodRet as Integer
	WSData RetMsg as String
EndWSStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WSStruct XmlStatus
Estrutura de dados do Webservice para exibir o resultado do metodo
CheckXMLStatus

@author Daniel Magalhaes
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
WSStruct XmlStatus
	WSData CodStat as Integer
	WSData StatMsg as String
EndWSStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WSService TAFWSIMPORT
Descricao do Webservice de inclusao de XML do SIGATAF

@author Daniel Magalhaes
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
WSService TAFWSIMPORT Description "Serviço para inclusão de XMLs do e-Social para processamento pelo SIGATAF"

	WSData TAFFil   as String
	WSData TAFSeq   as Integer
	WSData TAFTpReg as String
	WSData TAFKey   as String
	WSData TAFXml   as Base64Binary
	
	WSData TAFIncResult as IncludeResult
	WSData TAFXmlStatus as XmlStatus
	
	WSMethod IncludeNewXML  Description	"Método para inclusão de novo XML e-Social."
	WSMethod CheckXMLStatus Description	"Método para consulta da situação de um XML e-Social em processamento pelo SIGATAF."
	
EndWSService

//-------------------------------------------------------------------
/*/{Protheus.doc} WSMethod IncludeNewXML
Metodo para inclusao de novo XML e-Social

@author Daniel Magalhaes
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
WSMethod IncludeNewXML WSReceive TAFFil, TAFSeq, TAFTpReg, TAFKey, TAFXml WSSend TAFIncResult WSService TAFWSIMPORT

/*
aPar[1] - Indicador do Job que sera realizado
aPar[2] - Indica o TOP ALIAS
aPar[3] - Indica o Database
aPar[4] - Empresa
aPar[5] - Filial
*/

Local aErros    := {}
Local aPar      := {6,"","","",""}
Local aLayouts  := TAFIntDefine( "aTafSocial" )
Local aTabConf  := {}
Local aErros    := {}
Local cSeek     := ""
Local cFil      := ""
Local cCodMsg   := ""
Local cSeq      := ""
Local cTpReg    := ""
Local cKey      := ""
Local cXML      := ""
Local cST1Name  := TAFIntDefine( "cST1TAB" )
Local cST1Alias := GetNextAlias()
Local cST2Name  := TAFIntDefine( "cST2TAB" )
Local cST2Alias := GetNextAlias()
Local nPos      := 0
Local cTCBuild  := "TCGetBuild" 			// Nome da funcao para verificao da Build    
Local cTopBuild := ""						// Variavel com Versao do TopBuild
Local cBancoDB  := ""						// Identifica banco DB
Local lTAFConn  := .F.
Local lMsgJob   := GetNewPar("MV_TAFMSGJ",.F.)						//MV_TAFMSGJ - L - Se .T. Mensagens complementares no Console
Local aTAFConn  := {;
					AllTrim(SuperGetMV("MV_TAFTDB",.F.,"")),;	//Parametro MV_TAFTDB - TAF TOP DATABASE DO ERP
					AllTrim(SuperGetMV("MV_TAFTALI",.F.,""));	//Parametro MV_TAFTALI- TAF TOP ALIAS DO ERP
					}


//Recupera a estrutura da TAFST2
aTabConf := xTAFGetStru(cST2Name) 	// Chama funcao de retorno da estrutura das tabelas compartilhadas     	

cTpReg := AllTrim( self:TAFTpReg )

// -----------------------------------------------------
// Verificação da Build  para tratamento de campo CLOB            
If FindFunction(cTCBuild)
	cTopBuild := &cTCBuild.()
EndIf

// -----------------------------------------------------
// Verficia Banco 
cBancoDB := Upper(AllTrim(TcGetDB()))

If aScan(aLayouts, {|a| a[5] == cTpReg}) == 0

	self:TAFIncResult:CodRet := 0
	self:TAFIncResult:RetMsg := "O formato do campo Tipo de Registro (TAFTpReg) deve utilizar a máscara S-NNNN, onde NNNN é o número do layout do e-Social."

Else

	//Efetua a abertura da tabela
	lTAFConn := TAFConn( 1,aPar[1], aTABDados, aTabConf, aErros, aPar, cTopBuild, cBancoDB, .T. )
	           

	If !lTAFConn

		self:TAFIncResult:CodRet := 0
		self:TAFIncResult:RetMsg := "Não foi possível abrir a tabela " + cST2Name + "."

	Else

		//aAdd(aInd, 	 {"TAFFIL","TAFCODMSG", "TAFSEQ", "TAFTPREG" ,"TAFKEY"} ) 

		//Monta a chave de pesquisa
		cFil    := PadR( self:TAFFil, Len((cST2Alias)->TAFFIL    ) )
		cCodMsg := PadR( "2",         Len((cST2Alias)->TAFCODMSG ) )
		cSeq    := StrZero( self:TAFSeq, Len((cST2Alias)->TAFSEQ ) )
		cTpReg  := PadR( cTpReg,      Len((cST2Alias)->TAFTPREG  ) )
		cKey    := PadR( self:TAFKey, Len((cST2Alias)->TAFKEY    ) )
		cXML    := ""
		
		cSeek := cFil
		cSeek += cCodMsg
		cSeek += cSeq
		cSeek += cTpReg
		cSeek += cKey

		(cST2Alias)->( DbSetOrder(1) )
		If (cST2Alias)->( DbSeek(cSeek) )
		
			self:TAFIncResult:CodRet := 0
			self:TAFIncResult:RetMsg := "A chave informada já foi registrada na base de dados do SIGATAF."
		
		Else

			/*
			// Estrutura Campos Tabela
			aAdd(aEstru, {"TAFFIL",		"C",	010,	0 }  )      
			aAdd(aEstru, {"TAFCODMSG",	"C",	001,	0 }  )
			aAdd(aEstru, {"TAFSEQ",		"C",	003,	0 }  )
			aAdd(aEstru, {"TAFTPREG",	"C",	010,	0 }  )
			aAdd(aEstru, {"TAFKEY",		"C",	100,	0 }  )
			aAdd(aEstru, {"TAFMSG",		"M",	010,	0 }  )
			aAdd(aEstru, {"TAFSTATUS",	"C",	001,	0 }  )      
			aAdd(aEstru, {"TAFIDTHRD",	"C",	010,	0 }  )
			*/
			
			//Verifica o cadastro de Complemento de Estabelecimento
			C1E->( DbSetOrder(1) ) //C1E_FILIAL+C1E_CODFIL+DTOS(C1E_DTINI)+DTOS(C1E_DTFIN)
			If !C1E->( DbSeek( xFilial("C1E") + cFil ) )

				self:TAFIncResult:CodRet := 0
				self:TAFIncResult:RetMsg := "O código de filial informado ('" + cFil + "') não está cadastrado na tabela de Complemento de Estabelecimento do SIGATAF."

			Else

				cXML := Decode64( self:TAFXml )

				If Reclock(cST2Alias, .T.)

					(cST2Alias)->TAFFIL    := cFil
					(cST2Alias)->TAFCODMSG := cCodMsg
					(cST2Alias)->TAFSEQ    := cSeq
					(cST2Alias)->TAFTPREG  := cTpReg
					(cST2Alias)->TAFKEY    := cKey
					(cST2Alias)->TAFMSG    := cXML
					(cST2Alias)->TAFSTATUS := "1"

					(cST2Alias)->( MsUnlock() )

					self:TAFIncResult:CodRet := 1
					self:TAFIncResult:RetMsg := "XML incluído com sucesso."

				Else

					self:TAFIncResult:CodRet := 0
					self:TAFIncResult:RetMsg := "Erro na gravação do XML."

				EndIf
			
			EndIf
		
		EndIf
		
		//Encerra conexao - Fecha tabelas
		TAFConn( 2, aPar[1], aTABDados, Nil , aErros, aPar, cTopBuild, cBancoDB, .T. )

	EndIf

EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WSMethod CheckXMLStatus
Metodo para consulta da situacao de um XML e-Social em processamento pelo SIGATAF

@author Daniel Magalhaes
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
WSMethod CheckXMLStatus WSReceive TAFFil, TAFSeq, TAFTpReg, TAFKey WSSend TAFXmlStatus WSService TAFWSIMPORT

Local aErros    := {}
Local aPar      := {6,"","","",""}
Local aLayouts  := TAFIntDefine( "aTafSocial" )
Local aTabConf  := {}
Local aErros    := {}
Local cSeek     := ""
Local cFil      := ""
Local cCodMsg   := ""
Local cSeq      := ""
Local cTpReg    := ""
Local cKey      := ""
Local cST1Name  := TAFIntDefine( "cST1TAB" )
Local cST1Alias := GetNextAlias()
Local cST2Name  := TAFIntDefine( "cST2TAB" )
Local cST2Alias := GetNextAlias()
Local aTABDados := {{cST1Name,cST1Alias},{cST2Name,cST2Alias}} 
Local nPos      := 0
Local cTCBuild  := "TCGetBuild" 			// Nome da funcao para verificao da Build    
Local cTopBuild := ""						// Variavel com Versao do TopBuild
Local cBancoDB  := ""						// Identifica banco DB
Local lTAFConn  := .F.
Local lMsgJob   := GetNewPar("MV_TAFMSGJ",.F.)						//MV_TAFMSGJ - L - Se .T. Mensagens complementares no Console
Local aTAFConn  := {;
					AllTrim(SuperGetMV("MV_TAFTDB",.F.,"")),;	//Parametro MV_TAFTDB - TAF TOP DATABASE DO ERP
					AllTrim(SuperGetMV("MV_TAFTALI",.F.,""));	//Parametro MV_TAFTALI- TAF TOP ALIAS DO ERP
					}

//Recupera a estrutura da TAFST2
aTabConf := xTAFGetStru(cST2Name) 	// Chama funcao de retorno da estrutura das tabelas compartilhadas     	

cTpReg := AllTrim( self:TAFTpReg )

// -----------------------------------------------------
// Verificação da Build  para tratamento de campo CLOB            
If FindFunction(cTCBuild)
	cTopBuild := &cTCBuild.()
EndIf

// -----------------------------------------------------
// Verficia Banco 
cBancoDB := Upper(AllTrim(TcGetDB()))

If ( aScan(aLayouts, {|a| a[5] == cTpReg}) == 0 .And. Alltrim(cTpReg) != "NFESBRA" )

	self:TAFXmlStatus:CodStat := -1
	self:TAFXmlStatus:StatMsg := "O formato do campo Tipo de Registro (TAFTpReg) deve utilizar a máscara S-NNNN, onde NNNN é o número do layout do e-Social."

Else

	//Efetua a abertura da tabela
	lTAFConn := TAFConn( 1,aPar[1], aTABDados, aTabConf, aErros, aPar, cTopBuild, cBancoDB, .T. )

	If !lTAFConn

		self:TAFXmlStatus:CodStat := -1
		self:TAFXmlStatus:StatMsg := "Não foi possível abrir a tabela " + cST2Name + "."

	Else

		//aAdd(aInd, 	 {"TAFFIL","TAFCODMSG", "TAFSEQ", "TAFTPREG" ,"TAFKEY"} ) 

		//Monta a chave de pesquisa
		cFil    := PadR( self:TAFFil, Len((cST2Alias)->TAFFIL    ) )
		cCodMsg := PadR( IIf(Alltrim(cTpReg) != "NFESBRA", "2", "3"), Len((cST2Alias)->TAFCODMSG ) )
		cSeq    := StrZero( self:TAFSeq, Len((cST2Alias)->TAFSEQ ) )
		cTpReg  := PadR( cTpReg,      Len((cST2Alias)->TAFTPREG  ) )
		cKey    := PadR( self:TAFKey, Len((cST2Alias)->TAFKEY    ) )
		
		cSeek := cFil
		cSeek += cCodMsg
		cSeek += cSeq
		cSeek += cTpReg
		cSeek += cKey

		(cST2Alias)->( DbSetOrder(1) )
		If (cST2Alias)->( DbSeek(cSeek) )
		
			self:TAFXmlStatus:CodStat := Val( (cST2Alias)->TAFSTATUS )
			self:TAFXmlStatus:StatMsg := TAFStatDesc( (cST2Alias)->TAFSTATUS )
		
		Else

			self:TAFXmlStatus:CodStat := -1
			self:TAFXmlStatus:StatMsg := "A chave informada não esta registrada na base de dados do SIGATAF."
		
		EndIf
		
		//Encerra conexao - Fecha tabelas
		TAFConn( 2, aPar[1], aTABDados, Nil , aErros, aPar, cTopBuild, cBancoDB, .T. )

	EndIf

EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFStatDesc
Retorna a descricao do status do registro

@author Daniel Magalhaes
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFStatDesc( cCodStatus )
Local cDesc := ""

Do Case

	Case cCodStatus == "0"
	
		cDesc := "As informações estão sendo processadas pela aplicação (ERP)"
	
	Case cCodStatus == "1"
	
		cDesc := "As informações estão disponíveis para que a integração a processe, ou seja, está disponível para o TAF processá-la"
	
	Case cCodStatus == "2"

		cDesc := "As informações estão em processo de importação do ambiente do ERP para o TAF"
	
	Case cCodStatus == "3"

		cDesc := "As informações já foram processadas e estão disponíveis no ambiente do TAF"
	
	Otherwise

		cDesc := "Situação desconhecida"
	
EndCase


Return cDesc