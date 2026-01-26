#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#INCLUDE "ERROR.CH"
#INCLUDE "XMLXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} P395SolPro
Funcao de recebimento de uma solicitacao do WebService solicitarProtocoloWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function P395SolPro(aAuto)
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local cNameSpace := ""
	Local cSoap      := ""
	Local aRet       := {}
	Local aRetObj    := {}
	Local aRetVld    := {}
	Local aCab       := {}
	Local lRetObj    := .F.
	Local cEnv := GetEnvServer()
	Local cEmp := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para armazenar dados do envio    								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraPre := ""
	Local cIdUsuario := ""
	Local cMatric    := ""
	Local cNomeBenef := ""
	Local cCPF       := ""
	Local cDDD       := ""
	Local cTelefone  := ""
	Local cEmail     := ""
	Local cTipManif  := ""
	Local cTipCateg  := ""
	Local cTipSentim := ""
	Local cNumProAnt := ""
	Local cIDResp    := ""
	Local cNrTrolOri := ""
	Local cMsgLivre  := ""
	Local dDataGer
	Default aAuto   := {.F.,""}

	If aAuto[1] .Or. !Empty(cEmp)

		if !aAuto[1]
			RpcSetEnv( cEmp,cFil,,,cEnv,,)
		endIf
		cSoap := iif(aAuto[1],aAuto[2],HttpOtherContent())

		if empty(cSoap)
			aRet := RetWsdl("solicitarProtocolo_V1_1_0.wsdl","P395SolPro",aAuto[1])
			if aRet[1]
				Return aRet[2]
			endIf
		endIf

		aRetObj := ajusXMLRec(@cErro,@cAviso,cSoap)
		HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding

		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se erro de estrutura monta o SoapFault 								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRetObj
			cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
			cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
			cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")
			cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\numeroTransacaoPrestadora")

			Aadd(aCab,{"011","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aCab,nil,nil,nil,.T.,aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',cNumTraPre)
			cRet := PLMntTagPT(cRet,'mensagemErro',aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,nil,"hash",nil,nil,.T.)
		EndIf
	Else
		cRet := "A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil."
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta variaveis gerais 											       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
		cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
		cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")

		cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\numeroTransacaoPrestadora")
		dDataGer   := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\dataGeracao","D")
		cIdUsuario := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\idUsuario")
		cMatric    := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\identificacaoBeneficiario\codigoUnimed",,4) + ;
			PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\identificacaoBeneficiario\codigoIdentificacao",,13)

		cNomeBenef := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\dadosBeneficiario\nomeBenef")
		cCPF       := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\dadosBeneficiario\cdCPF")
		cDDD       := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\dadosBeneficiario\ddd")
		cTelefone  := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\dadosBeneficiario\telefone")
		cEmail     := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\dadosBeneficiario\email")
		cTipManif  := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\identificacaoManifestacao\tipoManifestacao")
		cTipCateg  := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\identificacaoManifestacao\tipoCategoria")
		cTipSentim := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\identificacaoManifestacao\tipoSentimento")

		cIDResp    := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\idResposta")
		cNrTrolOri := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\numeroTransacaoIntercambio")
		cNumProAnt := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\numeroProtocoloAnterior")
		cMsgLivre  := PLRetTagWB(oObjXml,cNameSpace,"solicitarProtocolo\mensagemLivre")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama funcao para processamento da solicitacao				           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := PLSolProWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDataGer,cIDUsuario,cMatric,cNomeBenef,cCPF,cDDD,cTelefone,;
			cEmail,cTipManif,cTipCateg,cTipSentim,cIDResp,cNrTrolOri,cNumProAnt,cMsgLivre,aAuto)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Array do aRet                       				           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	[1][01] -> codigoTransacao
	[1][02] -> tipoCliente
	[1][03] -> codigoUnimedOrigemMensagem
	[1][04] -> codigoUnimedDestino
	[1][05] -> numeroRegistroANS
	[1][06] -> numeroTransacaoPrestadora
	[1][07] -> dataGeracao
	[1][08] -> idUsuario
	[1][09] -> identificacaoBeneficicario - codigoUnimed
	[1][10] -> identificacaoBeneficicario - codigoidentificacao
	[1][11] -> numeroProtocolo
	[1][12] -> idResposta
	[1][13] -> mensagemLivre
	[1][14] -> origemResposta
	[1][15] -> numeroVersaoProtocolo

	[2] -> Hash
	[3] -> codigoErro
		*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivo processado com sucesso        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRet[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'respostasolicitarProtocolo',.T.,.F.,aRet)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][06])
			cRet := PLMntTagPT(cRet,'dataGeracao',aRet[1][07])
			cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][08])

			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
			cRet := PLMntTagPT(cRet,'codigoUnimed',aRet[1][09])
			cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][10] )
			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)

			cRet := PLMntTagPT(cRet,'numeroProtocolo',aRet[1][11])
			cRet := PLMntTagPT(cRet,'idResposta',aRet[1][12])
			cRet := PLMntTagPT(cRet,'mensagemLivre',aRet[1][13])
			cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][14])
			cRet := PLMntTagPT(cRet,'numeroVersaoProtocolo',aRet[1][15])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'respostasolicitarProtocolo',.F.,.T.,aRet,aRet[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivo processado com erro        						    		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aRet,nil,nil,nil,.T.,aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',aRet[1][06])
			cRet := PLMntTagPT(cRet,'codigoErro',aRet[1][07])
			cRet := PLMntTagPT(cRet,'mensagemErro',aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,aRet,aRet[2],nil,nil,.T.)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se o layout do arquivo de resposta esto Ok					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetVld := vldXmlEnv(cRet)
		If !aRetVld[1]
			cRet := aRetVld[2]
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Log        			         								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LogRes395(cRet)

Return(cRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} P395ComPro
Funcao de recebimento de uma solicitacao do WebService complementoProtocoloWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function P395ComPro(aAuto)
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local aRetObj    := {}
	Local aRetVld    := {}
	Local aCab       := {}
	Local cEnv 		 := GetEnvServer()
	Local cEmp 		 := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil		 := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	Local cNameSpace := ""
	Local cSoap      := ""
	Local lRetObj    := .F.

	//Variaveis para armazenar dados do envio
	Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraOpe := ""
	Local cIdUsuario := ""
	Local cMatric    := ""
	Local cNumProtoc := ""
	Local cNrTrolOri := ""
	Local dDataGer
	Default aAuto    := {.F.,""}

	If aAuto[1] .Or. !Empty(cEmp)

		if !aAuto[1]
			RpcSetEnv( cEmp,cFil,,,cEnv,,)
		endIf
		cSoap := iif(aAuto[1],aAuto[2],HttpOtherContent())

		if empty(cSoap)
			aRet := RetWsdl("complementarProtocolo_V1_1_0.wsdl","P395ComPro",aAuto[1])
			if aRet[1]
				Return aRet[2]
			endIf
		endIf

		aRetObj := ajusXMLRec(@cErro,@cAviso,cSoap)

		HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding
		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se erro de estrutura monta o SoapFault 								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRetObj
			cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
			cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
			cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")
			cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\numeroTransacaoPrestadora")

			Aadd(aCab,{"011","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aCab,nil,nil,nil,.T.,aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',cNumTraPre)
			cRet := PLMntTagPT(cRet,'mensagemErro',aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,nil,"hash",nil,nil,.T.)
		EndIf
	Else
		cRet := "A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil."
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta variaveis gerais 											       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
		cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
		cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")

		cNumTraOpe := PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\numeroTransacaoPrestadora")
		dDataGer   := PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\dataGeracao","D")
		cIdUsuario := PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\idUsuario")
		cMatric    := PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\identificacaoBeneficiario\codigoUnimed",,4) + ;
			PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\identificacaoBeneficiario\codigoIdentificacao",,13)
		cNumProtoc := PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\numeroProtocolo")
		cNrTrolOri := PLRetTagWB(oObjXml,cNameSpace,"pedidoComplementoAutorizacao\numeroTransacaoIntercambio")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada da funcao de processamento 									   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := PLComProWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOpe,dDataGer,cIDUsuario,cMatric,cNumProtoc,cNrTrolOri)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Array do aRet                       				           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	[1][01] -> codigoTransacao
	[1][02] -> tipoCliente
	[1][03] -> codigoUnimedOrigemMensagem
	[1][04] -> codigoUnimedDestino
	[1][05] -> numeroRegistroANS
	[1][06] -> numeroTransacaoPrestadora
	[1][07] -> dataGeracao
	[1][08] -> idUsuario
	[1][09] -> identificacaoBeneficicario - codigoUnimed
	[1][10] -> identificacaoBeneficicario - codigoidentificacao
	[1][11] -> tipoIdentificador
	[1][12] -> origemResposta
	[1][13] -> numeroVersaoProtocolo

	[2] -> Hash
	[3] -> codigoErro
		*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivo processado com sucesso        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRet[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.T.,.F.,aRet)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][06])
			cRet := PLMntTagPT(cRet,'dataGeracao',aRet[1][07])
			cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][08])

			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
			cRet := PLMntTagPT(cRet,'codigoUnimed',aRet[1][09])
			cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][10] )
			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)

			cRet := PLMntTagPT(cRet,'tipoIdentificador',aRet[1][11])
			cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][12])
			cRet := PLMntTagPT(cRet,'numeroVersaoProtocolo',aRet[1][13])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.F.,.T.,aRet,aRet[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivo processado com erro        						    		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aRet,nil,nil,nil,.T.,aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',aRet[1][06])
			cRet := PLMntTagPT(cRet,'codigoErro',aRet[1][07])
			cRet := PLMntTagPT(cRet,'mensagemErro',aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,aRet,aRet[2],nil,nil,.T.)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se o layout do arquivo de resposta esto Ok					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetVld := vldXmlEnv(cRet)
		If !aRetVld[1]
			cRet := aRetVld[2]
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Log        			         								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LogRes395(cRet)

Return(cRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} P395ResAte
Funcao de recebimento de uma solicitacao do WebService respostaAtendimentoWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function P395ResAte(aAuto)
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local cEnv       := GetEnvServer()
	Local cEmp       := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil       := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	Local cNameSpace := ""
	Local aRetObj    := {}
	Local aRet       := {}
	Local aRetVld    := {}
	Local aMsg       := {}
	Local aCab       := {}
	Local lRetObj    := .F.

	//Variaveis para armazenar dados do envio
	Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraOpe := ""
	Local cIdUsuario := ""
	Local cMatric    := ""
	Local cNumProtoc := ""
	Local cIDResp    := ""
	Local cNrTrolOri := ""
	Local cMsgLivre  := ""
	Local cTime		 := ""
	Local dDataGer
	Local nX := 0
	Default aAuto := {.F.,""}

	If aAuto[1] .Or. !Empty(cEmp)

		if !aAuto[1]
			RpcSetEnv( cEmp,cFil,,,cEnv,,)
		endIf
		cSoap := iif(aAuto[1],aAuto[2],HttpOtherContent())

		if empty(cSoap)
			aRet := RetWsdl("respostaAtendimento_V1_1_0.wsdl","P395ResAte",aAuto[1])
			if aRet[1]
				Return aRet[2]
			endIf
		endIf

		aRetObj := ajusXMLRec(@cErro,@cAviso,cSoap)
		HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding

		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se erro de estrutura monta o SoapFault 								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRetObj
			cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
			cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
			cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")
			cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\numeroTransacaoPrestadora")

			Aadd(aCab,{"011","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aCab,nil,nil,nil,.T.,aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',cNumTraPre)
			cRet := PLMntTagPT(cRet,'mensagemErro',aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,nil,"hash",nil,nil,.T.)
		EndIf
	Else
		cRet := "A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil."
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta variaveis gerais 											       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
		cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
		cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")

		cNumTraOpe := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\numeroTransacaoPrestadora")
		dDataGer   := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\dataGeracao","D")
		cIdUsuario := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\idUsuario")
		cMatric    := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\identificacaoBeneficiario\codigoUnimed",,4) + ;
			PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\identificacaoBeneficiario\codigoIdentificacao",,13)
		cNumProtoc := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\numeroProtocolo")
		cIDResp    := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\idResposta")
		cNrTrolOri := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\numeroTransacaoOrigemBeneficiario")

		cMsgLivre  := PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\mensagemLivre")

		If Type("oObjXml:"+cNameSpace+"respostaAtendimento:"+cNameSpace+"mensagemLivre") == "O"
			Aadd(aMsg,PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\mensagemLivre") )


		ElseIf  Type("oObjXml:"+cNameSpace+"respostaAtendimento:"+cNameSpace+"mensagemLivre") <> "U" .And. ;
				(nTot := len( &("oObjXml:"+cNameSpace+"respostaAtendimento:"+cNameSpace+"mensagemLivre") ) ) > 1

			For nX := 1 to nTot
				Aadd(aMsg,PLRetTagWB(oObjXml,cNameSpace,"respostaAtendimento\mensagemLivre["+cValtoChar(nX)+"]") )
			Next
		EndIf

		cTime	   := SubStr(dDataGer,10,5)
		dDataGer   := SToD(SubStr(dDataGer,1,8))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada da funcao de processamento 									   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := PLResAteWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOpe,dDataGer,cIDUsuario,cMatric,cNumProtoc,cIDResp,cNrTrolOri,aMsg,cTime)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Array do aRet                       				           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	[1][01] -> codigoTransacao
	[1][02] -> tipoCliente
	[1][03] -> codigoUnimedOrigemMensagem
	[1][04] -> codigoUnimedDestino
	[1][05] -> numeroRegistroANS
	[1][06] -> numeroTransacaoPrestadora
	[1][07] -> dataGeracao
	[1][08] -> idUsuario
	[1][09] -> identificacaoBeneficicario - codigoUnimed
	[1][10] -> identificacaoBeneficicario - codigoidentificacao
	[1][11] -> tipoIdentificador
	[1][12] -> origemResposta
	[1][13] -> numeroVersaoProtocolo

	[2] -> Hash
	[3] -> codigoErro
		*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivo processado com sucesso        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRet[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.T.,.F.,aRet)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][06])
			cRet := PLMntTagPT(cRet,'dataGeracao',aRet[1][07])
			cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][08])

			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
			cRet := PLMntTagPT(cRet,'codigoUnimed',aRet[1][09] )
			cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][10] )
			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)

			cRet := PLMntTagPT(cRet,'tipoIdentificador',aRet[1][11])
			cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][12])
			cRet := PLMntTagPT(cRet,'numeroVersaoProtocolo',aRet[1][13])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.F.,.T.,aRet,aRet[2])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivo processado com erro        						    		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aRet,nil,nil,nil,.T.,aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',aRet[1][06])
			cRet := PLMntTagPT(cRet,'codigoErro',aRet[1][07])
			cRet := PLMntTagPT(cRet,'mensagemErro',aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,aRet,aRet[2],nil,nil,.T.)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se o layout do arquivo de resposta esto Ok					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetVld := vldXmlEnv(cRet)
		If !aRetVld[1]
			cRet := aRetVld[2]
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Log        			         								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LogRes395(cRet)

Return(cRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} P395ConSta
Funcao de recebimento de uma solicitacao do WebService consultaStatusProtocoloWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function P395ConSta(aAuto)
	Local cEnv       := GetEnvServer()
	Local cEmp       := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil       := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local cNameSpace := ""
	Local cSoap      := ""
	Local nX         := 0
	Local aRetObj    := {}
	Local aRet       := {}
	Local aRetVld    := {}
	Local aCab       := {}
	Local lRetObj    := .F.

	//Variaveis para armazenar dados do envio
	Local cNumTraPre := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cIdUsuario := ""
	Local cMatric    := ""
	Local cNumProtoc := ""
	Local dDataGer
	Default aAuto    := {.F.,""}

	If aAuto[1] .Or. !Empty(cEmp)

		if !aAuto[1]
			RpcSetEnv( cEmp,cFil,,,cEnv,,)
		endIf
		cSoap := iif(aAuto[1],aAuto[2],HttpOtherContent())

		if empty(cSoap)
			aRet := RetWsdl("consultaStatusProtocolo_V1_1_0.wsdl","P395ConSta",aAuto[1])
			if aRet[1]
				Return aRet[2]
			endIf
		endIf

		aRetObj := ajusXMLRec(@cErro,@cAviso,cSoap)
		HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding

		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se erro de estrutura monta o SoapFault 								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRetObj
			cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
			cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
			cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")
			cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"consultaStatusProtocolo\numeroTransacaoPrestadora")

			Aadd(aCab,{"011","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aCab,nil,nil,nil,.T.,aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',cNumTraPre)
			cRet := PLMntTagPT(cRet,'mensagemErro',aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,nil,"hash",nil,nil,.T.)
		EndIf
	Else
		cRet := "A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil."
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta variaveis gerais 												   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
		cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
		cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")

		cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"consultaStatusProtocolo\numeroTransacaoPrestadora")
		dDataGer   := PLRetTagWB(oObjXml,cNameSpace,"consultaStatusProtocolo\dataGeracao","D")
		cIdUsuario := PLRetTagWB(oObjXml,cNameSpace,"consultaStatusProtocolo\idUsuario")
		cMatric    := PLRetTagWB(oObjXml,cNameSpace,"consultaStatusProtocolo\identificacaoBeneficiario\codigoUnimed",,4) + ;
			PLRetTagWB(oObjXml,cNameSpace,"consultaStatusProtocolo\identificacaoBeneficiario\codigoIdentificacao",,13)
		cNumProtoc := PLRetTagWB(oObjXml,cNameSpace,"consultaStatusProtocolo\numeroProtocolo")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada da funcao de processamento 									   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := PLConStaWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDataGer,cIDUsuario,cMatric,cNumProtoc)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Array do aRet                       				           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	[1][01] -> codigoTransacao
	[1][02] -> tipoCliente
	[1][03] -> codigoUnimedOrigemMensagem
	[1][04] -> codigoUnimedDestino
	[1][05] -> numeroRegistroANS
	[1][06] -> dataSolicitacaoProtocolo
	[1][07] -> numeroTransacaoPrestadora
	[1][08] -> dataGeracao
    [1][09] -> numeroProtocolo
	[1][10] -> identificacaoManifestacao - tipoManifestacao
	[1][11] -> identificacaoManifestacao - tipoCategoria
	[1][12] -> identificacaoManifestacao - tipoSentimento
	[1][13] -> nomeBeneficiario
	[1][14] -> identificacaoBeneficiario - codigoUnimed
	[1][15] -> identificacaoBeneficiario - codigoIdentificacao
	[1][16] -> numeroTransacaoIntercambioPrestadora
	[1][17] -> numeroTransacaoOrigemBeneficiario
	[1][18] -> idResposta
	[1][19] -> numeroVersaoProtocolo
	[1][20] -> Array com a tag identificacaoMensagemPedidoManifestacao
	[1][21] -> Array com a tag identificacaoMensagemRespostaManifestacao
	[1][22] -> origemResposta

	[2] -> Hash
	[3] -> codigoErro
		*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivo processado com sucesso        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRet[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'respostaConsultaStatusProtocolo',.T.,.F.,aRet)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'dataSolicitacaoProtocolo',aRet[1][06])
			cRet := PLMntTagPT(cRet,'respostaConsultaStatusProtocolo',nil,.T.)

			cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][07])
			cRet := PLMntTagPT(cRet,'dataGeracao',aRet[1][08])
			cRet := PLMntTagPT(cRet,'numeroProtocolo',aRet[1][09])

			cRet := PLMntTagPT(cRet,'identificacaoManifestacao',nil,.T.)
			cRet := PLMntTagPT(cRet,'tipoManifestacao',aRet[1][10])
			cRet := PLMntTagPT(cRet,'tipoCategoria',aRet[1][11])
			cRet := PLMntTagPT(cRet,'tipoSentimento',aRet[1][12])
			cRet := PLMntTagPT(cRet,'identificacaoManifestacao',nil,nil,.T.)

			cRet := PLMntTagPT(cRet,'nomeBenef',aRet[1][13])

			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
			cRet := PLMntTagPT(cRet,'codigoUnimed',aRet[1][14])
			cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][15] )
			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)

			cRet := PLMntTagPT(cRet,'numeroTransacaoIntercambioPrestadora',aRet[1][16])
			cRet := PLMntTagPT(cRet,'numeroTransacaoOrigemBeneficiario',aRet[1][17])
			cRet := PLMntTagPT(cRet,'idResposta',aRet[1][18])
			cRet := PLMntTagPT(cRet,'numeroVersaoProtocolo',aRet[1][19])

			For nX := 1 to len(aRet[1][20])
				cRet := PLMntTagPT(cRet,'identificacaoMensagemPedidoManifestacao',nil,.T.)
				cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][20][nX][1])
				cRet := PLMntTagPT(cRet,'dataEnvioMensagem',aRet[1][20][nX][2])
				cRet := PLMntTagPT(cRet,'dataRespostaMensagem',aRet[1][20][nX][3])
				cRet := PLMntTagPT(cRet,'mensagemLivre',aRet[1][20][nX][4])
				cRet := PLMntTagPT(cRet,'identificacaoMensagemPedidoManifestacao',nil,nil,.T.)
			Next

			For nX := 1 to len(aRet[1][21])
				cRet := PLMntTagPT(cRet,'identificacaoMensagemRespostaManifestacao',nil,.T.)
				cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][21][nX][1])
				cRet := PLMntTagPT(cRet,'dataEnvioMensagem',aRet[1][21][nX][2])
				cRet := PLMntTagPT(cRet,'dataRespostaMensagem',aRet[1][21][nX][3])
				cRet := PLMntTagPT(cRet,'mensagemLivre',aRet[1][21][nX][4])
				cRet := PLMntTagPT(cRet,'identificacaoMensagemRespostaManifestacao',nil,nil,.T.)
			Next

			cRet := PLMntTagPT(cRet,'respostaConsultaStatusProtocolo',nil,nil,.T.)
			cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][22])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'respostaConsultaStatusProtocolo',.F.,.T.,aRet,aRet[2])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivo processado com erro        						    		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aRet,nil,nil,nil,.T.,aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',aRet[1][06])
			cRet := PLMntTagPT(cRet,'codigoErro',aRet[1][07])
			cRet := PLMntTagPT(cRet,'mensagemErro',aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,aRet,aRet[2],nil,nil,.T.)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se o layout do arquivo de resposta esto Ok					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetVld := vldXmlEnv(cRet)
		If !aRetVld[1]
			cRet := aRetVld[2]
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Log        			         								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LogRes395(cRet)

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} P395ConHis
Funcao de recebimento de uma solicitacao do WebService consultaHistoricoWS

@author  PLS TEAM
@version P11
@since   26/07/16
/*/
//-------------------------------------------------------------------
Function P395ConHis(aAuto)
	Local cEnv       := GetEnvServer()
	Local cEmp       := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil       := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local cNameSpace := ""
	Local cSoap      := ""
	Local nX         := 0
	Local aRetObj    := {}
	Local aRet       := {}
	Local aRetVld    := {}
	Local aCab       := {}
	Local lRetObj    := .F.

	//Variaveis para armazenar dados do envio
	Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraPre := ""
	Local cIdUsuario := ""
	Local cMatric    := ""
	Local cNumProtoc := ""
	Local dDataGer
	Local dDatSol
	Local dDatResp
	Default aAuto    := {.F.,""}

	If aAuto[1] .Or. !Empty(cEmp)

		if !aAuto[1]
			RpcSetEnv( cEmp,cFil,,,cEnv,,)
		endIf
		cSoap := iif(aAuto[1],aAuto[2],HttpOtherContent())

		if empty(cSoap)
			aRet := RetWsdl("consultaHistorico_V1_1_0.wsdl","P395ConHis",aAuto[1])
			if aRet[1]
				Return aRet[2]
			endIf
		endIf

		aRetObj := ajusXMLRec(@cErro,@cAviso,cSoap)
		HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding

		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se erro de estrutura monta o SoapFault 								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRetObj
			cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
			cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
			cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")
			cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\numeroTransacaoPrestadora")

			Aadd(aCab,{"011","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aCab,nil,nil,nil,.T.,aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',cNumTraPre)
			cRet := PLMntTagPT(cRet,'mensagemErro',aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,nil,"hash",nil,nil,.T.)
		EndIf
	Else
		cRet := "A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil."
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta variaveis gerais 												   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
		cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
		cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")

		cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\numeroTransacaoPrestadora")
		dDataGer   := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\dataGeracao","D")
		cIdUsuario := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\idUsuario")
		cMatric    := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\identificacaoBeneficiario\codigoUnimed",,4) + ;
			PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\identificacaoBeneficiario\codigoIdentificacao",,13)

		cNumProtoc := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\numeroProtocolo")
		dDatSol    := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\dataSolicitacao","D")
		dDatResp   := PLRetTagWB(oObjXml,cNameSpace,"consultaHistorico\dataResposta","D")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada da funcao de processamento 									   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := PLConHisWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDataGer,cIdUsuario,cMatric,cNumProtoc,dDatSol,dDatResp)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Array do aRet                       				           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	[1][01] -> codigoTransacao
	[1][02] -> tipoCliente
	[1][03] -> codigoUnimedOrigemMensagem
	[1][04] -> codigoUnimedDestino
	[1][05] -> numeroRegistroANS
	[1][06] -> dataInicioPeriodo
 	[1][07] -> dataFimPeriodo
 	[1][08] -> aResp - Array com a tag respostaConsultaHistorico
 		[1][08][nX][01] -> numeroTransacaoPrestadora
	    [1][08][nX][02] -> dataGeracao
	    [1][08][nX][03] -> idUsuario
	    [1][08][nX][04] -> numeroProtocolo
	    [1][08][nX][05] -> identificacaoManifestacao - tipoManifestacao
	    [1][08][nX][06] -> identificacaoManifestacao - tipoCategoria
	    [1][08][nX][07] -> identificacaoManifestacao - tipoSentimento
	    [1][08][nX][08] -> nomeBenef
	    [1][08][nX][09] -> numeroTransacaoIntercambioPrestadora
	    [1][08][nX][10] -> numeroTransacaoOrigemBeneficiario
        [1][08][nX][11] -> identificacaoBeneficiario - codigoUnimed
  		[1][08][nX][12] -> identificacaoBeneficiario - codigoIdentificacao
		[1][08][nX][13] -> idResposta

 	[1][09] -> origemResposta
 	[2] -> Hash
 	[3] -> codigoErro
		*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivo processado com sucesso        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRet[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'respostaConsultaHistorico',.T.,.F.,aRet)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'dataInicioPeriodo',aRet[1][06])
			cRet := PLMntTagPT(cRet,'dataFimPeriodo',aRet[1][07])

			For nX := 1 to len(aRet[1][8])
				cRet := PLMntTagPT(cRet,'respostaConsultaHistorico',nil,.T.)

				cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][8][nX][1])
				cRet := PLMntTagPT(cRet,'dataGeracao',aRet[1][8][nX][2])
				cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][8][nX][3])
				cRet := PLMntTagPT(cRet,'numeroProtocolo',aRet[1][8][nX][4])

				cRet := PLMntTagPT(cRet,'identificacaoManifestacao',nil,.T.)
				cRet := PLMntTagPT(cRet,'tipoManifestacao',aRet[1][8][nX][5])
				cRet := PLMntTagPT(cRet,'tipoCategoria',aRet[1][8][nX][6])
				cRet := PLMntTagPT(cRet,'tipoSentimento',aRet[1][8][nX][7])
				cRet := PLMntTagPT(cRet,'identificacaoManifestacao',nil,nil,.T.)

				cRet := PLMntTagPT(cRet,'nomeBenef',aRet[1][8][nX][8])
				cRet := PLMntTagPT(cRet,'numeroTransacaoIntercambioPrestadora',aRet[1][8][nX][9])
				cRet := PLMntTagPT(cRet,'numeroTransacaoOrigemBeneficiario',aRet[1][8][nX][10])

				cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
				cRet := PLMntTagPT(cRet,'codigoUnimed',aRet[1][8][nX][11])
				cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][8][nX][12] )
				cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)

				cRet := PLMntTagPT(cRet,'idResposta',aRet[1][8][nX][13])

				cRet := PLMntTagPT(cRet,'respostaConsultaHistorico',nil,nil,.T.)
			Next

			cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][09])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'respostaConsultaHistorico',.F.,.T.,aRet,aRet[2])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivo processado com erro        						    		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aRet,nil,nil,nil,.T.,aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',aRet[1][06])
			cRet := PLMntTagPT(cRet,'codigoErro',aRet[1][07])
			cRet := PLMntTagPT(cRet,'mensagemErro',aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,aRet,aRet[2],nil,nil,.T.)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ valida se o layout do arquivo de resposta esto Ok					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetVld := vldXmlEnv(cRet)
		If !aRetVld[1]
			cRet := aRetVld[2]
		EndIf

	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Log        			         								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LogRes395(cRet)

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} P395CanAte
Funcao de recebimento de uma solicitacao do WebService cancelamentoWS

@author  PLS TEAM
@version P11
@since   26/07/16
/*/
//-------------------------------------------------------------------
Function P395CanAte(aAuto)
	Local cEnv       := GetEnvServer()
	Local cEmp       := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil       := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local cNameSpace := ""
	Local cSoap      := ""
	Local aRetObj    := {}
	Local aRet       := {}
	Local aRetVld    := {}
	Local aCab       := {}
	Local lRetObj    := .F.
	//Variaveis para armazenar dados do envio
	Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraPre := ""
	Local cIdUsuario := ""
	Local cMatric    := ""
	Local cNumProtoc := ""
	Local cDescMot   := ""
	Local cTime		 :=  ""
	Local dDataGer
	Default aAuto    := {.F.,""}

	If aAuto[1] .Or. !Empty(cEmp)

		if !aAuto[1]
			RpcSetEnv( cEmp,cFil,,,cEnv,,)
		endIf
		cSoap := iif(aAuto[1],aAuto[2],HttpOtherContent())

		if empty(cSoap)
			aRet := RetWsdl("cancelamento_V1_1_0.wsdl","P395CanAte",aAuto[1])
			if aRet[1]
				Return aRet[2]
			endIf
		endIf

		aRetObj := ajusXMLRec(@cErro,@cAviso,cSoap)
		HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding

		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se erro de estrutura monta o SoapFault 								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRetObj
			cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
			cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
			cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")
			cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"cancelamento\numeroTransacaoPrestadora")

			Aadd(aCab,{"011","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aCab,nil,nil,nil,.T.,aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',cNumTraPre)
			cRet := PLMntTagPT(cRet,'mensagemErro',aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,nil,"hash",nil,nil,.T.)
		EndIf
	Else
		cRet := "A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil."
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta variaveis gerais 												   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
		cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
		cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")

		cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"cancelamento\numeroTransacaoPrestadora")
		dDataGer   := PLRetTagWB(oObjXml,cNameSpace,"cancelamento\dataGeracao","D")
		cIdUsuario := PLRetTagWB(oObjXml,cNameSpace,"cancelamento\idUsuario")
		cMatric    := PLRetTagWB(oObjXml,cNameSpace,"cancelamento\identificacaoBeneficiario\codigoUnimed",,4) + ;
			PLRetTagWB(oObjXml,cNameSpace,"cancelamento\identificacaoBeneficiario\codigoIdentificacao",,13)
		cNumProtoc := PLRetTagWB(oObjXml,cNameSpace,"cancelamento\numeroProtocolo")
		cDescMot   := PLRetTagWB(oObjXml,cNameSpace,"cancelamento\descricaoMotivo")

		cTime	   := SubStr(dDataGer,10,5)
		dDataGer   := SToD(SubStr(dDataGer,1,8))


		// Chamada da funcao de processamento

		aRet := PLCanAteWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDataGer,cIDUsuario,cMatric,cNumProtoc,cDescMot,cTime)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Array do aRet                       				           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	[1][01] -> codigoTransacao
	[1][02] -> tipoCliente
	[1][03] -> codigoUnimedOrigemMensagem
	[1][04] -> codigoUnimedDestino
	[1][05] -> numeroRegistroANS
	[1][06] -> numeroTransacaoPrestadora
	[1][07] -> dataGeracao
	[1][08] -> idUsuario
	[1][09] -> identificacaoBeneficicario - codigoUnimed
	[1][10] -> identificacaoBeneficicario - codigoidentificacao
	[1][11] -> tipoIdentificador
	[1][12] -> origemResposta
	[1][13] -> numeroVersaoProtocolo

	[2] -> Hash
	[3] -> codigoErro
		*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivo processado com sucesso        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRet[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.T.,.F.,aRet)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][06])
			cRet := PLMntTagPT(cRet,'dataGeracao',aRet[1][07])
			cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][08])

			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
			cRet := PLMntTagPT(cRet,'codigoUnimed',aRet[1][09])
			cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][10] )
			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)

			cRet := PLMntTagPT(cRet,'tipoIdentificador',aRet[1][11])
			cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][12])
			cRet := PLMntTagPT(cRet,'numeroVersaoProtocolo',aRet[1][13])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.F.,.T.,aRet,aRet[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivo processado com erro        						    		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aRet,nil,nil,nil,.T.,aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',aRet[1][06])
			cRet := PLMntTagPT(cRet,'codigoErro',aRet[1][07])
			cRet := PLMntTagPT(cRet,'mensagemErro',aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,aRet,aRet[2],nil,nil,.T.)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se o layout do arquivo de resposta esto Ok					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetVld := vldXmlEnv(cRet)
		If !aRetVld[1]
			cRet := aRetVld[2]
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Log        			         								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LogRes395(cRet)

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} P395EncExe
Funcao de recebimento de uma solicitacao do WebService encaminharExecucaoWS

@author  PLS TEAM
@version P11
@since   26/07/16
/*/
//-------------------------------------------------------------------
Function P395EncExe(aAuto)
	Local cEnv       := GetEnvServer()
	Local cEmp       := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil       := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local cNameSpace := ""
	Local cSoap      := ""
	Local aRetObj    := {}
	Local aRet       := {}
	Local aRetVld    := {}
	Local aCab       := {}
	Local lRetObj    := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para armazenar dados do envio    								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraIni := ""
	Local cNumTraOri := ""
	Local cIdUsuario := ""
	Local cMatric    := ""
	Local cNomeBenef := ""
	Local cCPF       := ""
	Local cDDD       := ""
	Local cTelefone  := ""
	Local cEmail     := ""
	Local cTipManif  := ""
	Local cTipCateg  := ""
	Local cTipSentim := ""
	Local cNumProAnt := ""
	Local cNrTrolOri := ""
	Local cMsgLivre  := ""
	Local cNumProto  := ""
	Local dDataGer
	Default aAuto    := {.F.,""}

	If aAuto[1] .Or. !Empty(cEmp)

		if !aAuto[1]
			RpcSetEnv( cEmp,cFil,,,cEnv,,)
		endIf
		cSoap := iif(aAuto[1],aAuto[2],HttpOtherContent())

		if empty(cSoap)
			aRet := RetWsdl("encaminharExecucao_V1_1_0.wsdl","P395EncExe",aAuto[1])
			if aRet[1]
				Return aRet[2]
			endIf
		endIf

		aRetObj := ajusXMLRec(@cErro,@cAviso,cSoap)
		HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding

		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se erro de estrutura monta o SoapFault 								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRetObj
			cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
			cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
			cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")
			cNumTraPre := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\numeroTransacaoPrestadora")

			Aadd(aCab,{"011","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aCab,nil,nil,nil,.T.,aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',cNumTraPre)
			cRet := PLMntTagPT(cRet,'mensagemErro',aRetObj[4])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,nil,"hash",nil,nil,.T.)
		EndIf
	Else
		cRet := "A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil."
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta variaveis gerais 											       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodUniOri := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
		cCodUniDes := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
		cNumRegAns := PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\numeroRegistroANS")

		cNumTraIni := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\numeroTransacaoInicial")
		cNumTraOri := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\numeroTransacaoOrigem")

		dDataGer   := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\dataGeracao","D")
		cIdUsuario := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\idUsuario")
		cMatric    := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\identificacaoBeneficiario\codigoUnimed",,4) + ;
			PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\identificacaoBeneficiario\codigoIdentificacao",,13)

		cNomeBenef := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\dadosBeneficiario\nomeBenef")
		cCPF       := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\dadosBeneficiario\cdCPF")
		cDDD       := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\dadosBeneficiario\ddd")
		cTelefone  := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\dadosBeneficiario\telefone")
		cEmail     := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\dadosBeneficiario\email")
		cTipManif  := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\identificacaoManifestacao\tipoManifestacao")
		cTipCateg  := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\identificacaoManifestacao\tipoCategoria")
		cTipSentim := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\identificacaoManifestacao\tipoSentimento")

		cNrTrolOri := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\numeroTransacaoIntercambio")
		cNumProto  := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\numeroProtocolo")
		cNumProAnt := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\numeroProtocoloAnterior")
		cMsgLivre  := PLRetTagWB(oObjXml,cNameSpace,"encaminharExecucao\mensagemLivre")


		aRet := PLEncExeWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraIni,cNumTraOri,dDataGer,cIDUsuario,cMatric,cNomeBenef,cCPF,cDDD,cTelefone,;
			cEmail,cTipManif,cTipCateg,cTipSentim,cNrTrolOri,cNumProto,cNumProAnt,cMsgLivre)
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Array do aRet                       				           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	[1][01] -> codigoTransacao
	[1][02] -> tipoCliente
	[1][03] -> codigoUnimedOrigemMensagem
	[1][04] -> codigoUnimedDestino
	[1][05] -> numeroRegistroANS
	[1][06] -> numeroTransacaoPrestadora
	[1][07] -> dataGeracao
	[1][08] -> idUsuario
	[1][09] -> identificacaoBeneficicario - codigoUnimed
	[1][10] -> identificacaoBeneficicario - codigoidentificacao
	[1][11] -> tipoIdentificador
	[1][12] -> origemResposta
	[1][13] -> numeroVersaoProtocolo

	[2] -> Hash
	[3] -> codigoErro
		*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivo processado com sucesso        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRet[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.T.,.F.,aRet)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][06])
			cRet := PLMntTagPT(cRet,'dataGeracao',aRet[1][07])
			cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][08])

			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
			cRet := PLMntTagPT(cRet,'codigoUnimed',aRet[1][09])
			cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][10] )
			cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)

			cRet := PLMntTagPT(cRet,'tipoIdentificador',aRet[1][11])
			cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][12])
			cRet := PLMntTagPT(cRet,'numeroVersaoProtocolo',aRet[1][13])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'confirmacao',.F.,.T.,aRet,aRet[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivo processado com erro        						    		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Soap de resposta	         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.T.,.F.,aRet,nil,nil,nil,.T.,aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Corpo do arquivo                    								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := PLMntTagPT(cRet,'numeroTransacao',aRet[1][06])
			cRet := PLMntTagPT(cRet,'codigoErro',aRet[1][07])
			cRet := PLMntTagPT(cRet,'mensagemErro',aRet[1][08])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza arquivo			         								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := XmlIniFim(cRet,'erroInesperado',.F.,.T.,aRet,aRet[2],nil,nil,.T.)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se o layout do arquivo de resposta esto Ok					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetVld := vldXmlEnv(cRet)
		If !aRetVld[1]
			cRet := aRetVld[2]
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Log        			         								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LogRes395(cRet)

Return(cRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} ajusXMLRec
Ajusta um soap de recebimento para montagem do objeto de trabalho

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Static Function ajusXMLRec(cErro,cAviso,cSoap)
	Local cSchema    := GetNewPar("MV_R395XSD","")//gp_Transacoes-V1_1_0.xsd
	Local cVersion   := GetNewPar("MV_R395VER","")//V1_1_0
	Local cSoapAux   := ''
	Local cNameSpace := ''
	Local cMsg       := ''
	Local nPos       := 0
	Local nX         := 0
	Local lRet       := .T.
	Local oXml
	Local oObjXml

	If GetNewPar("MV_R395LOG","") == "1"
		PLRN395Log("-----------------------------------------------")
		PLRN395Log("Recebendo transacao")
		PLRN395Log(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
		PLRN395Log("-----------------------------------------------")
		PLRN395Log("Soap Recebido:")
		PLRN395Log(cSoap)
	EndIf

	nPos := At("BODY",Upper(cSoap))
	cSoapAux := Substr(cSoap,nPos+4,len(cSoap))
	nPos := At(">",Upper(cSoapAux))
	cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))

	nPos := At("BODY",Upper(cSoapAux))
	For nX := 1 to nPos
		If Substr(cSoapAux,nPos-nX,1) == "<"
			cSoapAux := Substr(cSoapAux,1,nPos-(nX+1))
			Exit
		EndIf
	Next

	If nPos == 0 .Or. Empty(cSoap)
		cErro := "Erro com o pacote Soap recebido"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria diretorios                                   					     	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExistDir("\pl395web")
		If MakeDir(GetSrvProfString ("ROOTPATH","")+"\pl395web\") == 3
			cErro := "Não foi possivel criar o diretorio \pl395web"
		EndIf
	EndIf
	If !ExistDir("\pl395web\schemas\")
		If MakeDir(GetSrvProfString ("ROOTPATH","")+"\pl395web\schemas\") == 3
			cErro := "Não foi possivel criar o diretorio \pl395web\schemas\"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houve erro fatal finaliza							                 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cErro)
		Return {.F.,oObjXml,cNameSpace,cErro}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza o parse             							                 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSoapAux := EncodeUTF8(cSoapAux)
	oXml := XmlParser( cSoapAux ,"_",@cErro,@cAviso )

	if empty(cErro) .And. empty(cAviso)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Identificar o namespace                           					     	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := At("CABECALHOTRANSACAO",Upper(cSoapAux))
		If Substr(cSoapAux,nPos-1,1) == ":"
			nPosNamSpc := nPos-2
			For nX := 1 to nPosNamSpc
				If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"
					cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
					Exit
				EndIf
			Next
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta texto para montagem do arquivo para validacao					     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := At(">",Upper(cSoapAux))
		cSoapPt1 := Substr(cSoapAux,1,nPos-1)
		cSoapPt2 := Substr(cSoapAux,nPos,len(cSoapAux))
		cSoapXml := cSoapPt1 + ' xmlns:v1="http://gp.unimed.coop.br/schemas/'+cVersion+'"'+cSoapPt2

		//cSoapXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'+Chr(10)+cSoapXml
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a validação do XML gerado pelo TranXml com o XSD 				     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!XmlSVldSch( cSoapXml, "\pl395web\schemas\"+cSchema, @cErro,@cAviso))
			cMsg := Iif( !Empty(cErro),"Erro: " +cErro,"")
			cMsg += Iif( !Empty(cAviso),"Aviso: "+cAviso,"")
			lRet := .F.
		EndIf

		aMatAux 	:= classDataArr(oXml)
		nPos 		:= ( At("_",SubStr( aMatAux[Len(aMatAux),1],2 ) )+1 )
		cNameSpace 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],1,nPos ) )
		cNameEleme 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],(nPos+1) ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura bruta															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjXml := XmlChildEx(oXml,cNameSpace+cNameEleme)
	else
		lRet  := .F.
		cErro := 'Erro na resposta recebida: '+cSoap
	endIf

Return {lRet,oObjXml,cNameSpace,cMsg}



//-------------------------------------------------------------------
/*/{Protheus.doc} XmlIniFim
Monta cabecalho e fim do arquivo de Soap de Resposta

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//-------------------------------------------------------------------
Static Function XmlIniFim(cSoapRet,cTagTrans,lIni,lFim,aRet,cHash,lNameSpace,cTagBody,lErro,cFaultStr)
	Local cVersion   := GetNewPar("MV_R395VER","")//V1_1_0
	Local cNameSpace := "v1:"
	Default lIni  := .F.
	Default lFim  := .F.
	Default aRet  := {}
	Default cHash := ""
	Default lNameSpace := .F.
	Default cTagBody  := ""
	Default lErro     := .F.
	Default cFaultStr := ""
	//Quando e arquivo de resposta nao envia o NameSpace
	If !lNameSpace
		cNameSpace := ""
	EndIf

	If lIni
		If lNameSpace
			cSoapRet += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://gp.unimed.coop.br/schemas/'+cVersion+'">'+ Chr(13)+Chr(10)
			cSoapRet += '<soapenv:Header/>'+ Chr(13)+Chr(10)
			cSoapRet += '<soapenv:Body>'+ Chr(13)+Chr(10)
			cSoapRet += '<'+cNameSpace+cTagTrans+'WS>'+ Chr(13)+Chr(10)
		Else
			cSoapRet += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + Chr(13)+Chr(10)
			cSoapRet += '<soap:Body>'+ Chr(13)+Chr(10)
			If lErro
				cSoapRet += '<soap:Fault>'+ Chr(13)+Chr(10)
				cSoapRet += '<faultcode>soap:Unimed</faultcode>'+ Chr(13)+Chr(10)
				cSoapRet += '<faultstring>'+IIF(!Empty(cFaultStr),cFaultStr,"Erro")+'</faultstring>'+ Chr(13)+Chr(10)
				cSoapRet += '<detail>'+ Chr(13)+Chr(10)
			EndIf
			cSoapRet += '<'+cTagTrans+'WS xmlns="http://gp.unimed.coop.br/schemas/'+cVersion+'">' + Chr(13)+Chr(10)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta cabecalho															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoapRet += '<'+cNameSpace+'cabecalhoTransacao>'+ Chr(13)+Chr(10)
		cSoapRet += '<'+cNameSpace+'codigoTransacao>'+aRet[1][01]+'</'+cNameSpace+'codigoTransacao>'+ Chr(13)+Chr(10)
		cSoapRet += '<'+cNameSpace+'tipoCliente>'+aRet[1][02]+'</'+cNameSpace+'tipoCliente>'+ Chr(13)+Chr(10)
		If !Empty(aRet[1][03])
			cSoapRet += '<'+cNameSpace+'codigoUnimedOrigemMensagem>'+cValtoChar(Val(aRet[1][03]))+'</'+cNameSpace+'codigoUnimedOrigemMensagem>' + Chr(13)+Chr(10)
		Endif
		If !Empty(aRet[1][04])
			cSoapRet += '<'+cNameSpace+'codigoUnimedDestinoMensagem>'+cValtoChar(Val(aRet[1][04]))+'</'+cNameSpace+'codigoUnimedDestinoMensagem>'+ Chr(13)+Chr(10)
		EndIf
		If !Empty(aRet[1][05])
			cSoapRet += '<'+cNameSpace+'numeroRegistroANS>'+ aRet[1][05]+'</'+cNameSpace+'numeroRegistroANS>'+ Chr(13)+Chr(10)
		Endif
		cSoapRet += '</'+cNameSpace+'cabecalhoTransacao>' + Chr(13)+Chr(10)

		cSoapRet += '<'+cNameSpace+IIF(!Empty(cTagBody),cTagBody,cTagTrans)+'>'+ Chr(13)+Chr(10)
	Endif

	If lFim
		cSoapRet += '</'+cNameSpace+IIF(!Empty(cTagBody),cTagBody,cTagTrans)+'>'+ Chr(13)+Chr(10)
		cSoapRet += '<'+cNameSpace+'hash>'+cHash+'</'+cNameSpace+'hash>'+ Chr(13)+Chr(10)
		cSoapRet += '</'+cNameSpace+cTagTrans+'WS>' + Chr(13)+Chr(10)
		If lNameSpace
			cSoapRet += '</soapenv:Body>' + Chr(13)+Chr(10)
			cSoapRet += '</soapenv:Envelope>' + Chr(13)+Chr(10)
		Else
			If lErro
				cSoapRet += '</detail>' + Chr(13)+Chr(10)
				cSoapRet += '</soap:Fault>' + Chr(13)+Chr(10)
			EndIf
			cSoapRet += '</soap:Body>' + Chr(13)+Chr(10)
			cSoapRet += '</soap:Envelope>' + Chr(13)+Chr(10)
		EndIf
	Endif

Return cSoapRet



//-------------------------------------------------------------------
/*/{Protheus.doc} vldXmlEnv
Valida XML de Envio (resposta ou envio de mensagem) com seu respectivo XSD

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Static Function vldXmlEnv(cSoapXml,lEnv,cTransacao)
	Local cNameSpace:= "v1"
	Local cSchema   := GetNewPar("MV_R395XSD","")//gp_Transacoes-V1_1_0.xsd
	Local cVersion  := GetNewPar("MV_R395VER","")//V1_1_0
	Local cErro     := ""
	Local cAviso    := ""
	Local cMsg      := ""
	Local cAux1     := ""
	Local cAux2     := ""
	Local cVersao   := ""
	Local lOk       := .T.
	Default lEnv      := .F.

	If lEnv
		cSoapXml  := Substr(cSoapXml,At("<soapenv:Body>",cSoapXml) + len("<soapenv:Body>"))
		cAux1     := Substr(cSoapXml,1,At(">",cSoapXml)- 1)
		cAux2     := Substr(cSoapXml,At(">",cSoapXml),len(cSoapXml))
		cVersao   := ' xmlns="http://gp.unimed.coop.br/schemas/'+cVersion+'" xmlns:'+cNameSpace+'="http://gp.unimed.coop.br/schemas/'+cVersion+'"'
		cSoapXml  := cAux1 + cVersao + cAux2
		cSoapXml  := '<?xml version="1.0" encoding="ISO-8859-1"?>'+cSoapXml
		cSoapXml  := Substr(cSoapXml,1,At("</soapenv:Body>",cSoapXml) -1)
	Else
		If At("soap:Fault",cSoapXml) > 0
			cSoapXml := Substr(cSoapXml,At("<detail>",cSoapXml) + len("<detail>"))
			cSoapXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'+cSoapXml
			cSoapXml := Substr(cSoapXml,1,At("</detail>",cSoapXml) -1)
		Else
			cSoapXml := Substr(cSoapXml,At("<soap:Body>",cSoapXml) + len("<soap:Body>"))
			cSoapXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'+cSoapXml
			cSoapXml := Substr(cSoapXml,1,At("</soap:Body>",cSoapXml) -1)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a validação do XML gerado pelo TranXml com o XSD 				     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!XmlSVldSch( cSoapXml, "\pl395web\schemas\"+cSchema, @cErro,@cAviso))
		cMsg := "Problemas ao gerar arquivo de envio\resposta. "
		cMsg += Iif( !Empty(cErro),"Erro: " +cErro,"")
		cMsg += Iif( !Empty(cAviso),"Aviso: "+cAviso,"")
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {})
		lOk := .F.
	EndIf

Return({lOk,cMsg})



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSolProRN
Monta chamada do WebService SolicitaProtocoloAtendimento - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16

Parametros:
cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraPre --> ID da Manifestação (Número de Transação da Prestadora)
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNome      --> Nome do Beneficiário
cCPF       --> Código do CPF
cDDD       --> Número do DDD
cTelefone  --> Número do telefone
cEmail     --> Endereço de email
cTipManif  --> Tipo de Manifestação
cTipCateg  --> Categoria da Manifestação
cTipSent   --> Sentimento do Cliente
cIDResp    --> Indica o status da manifestação
cNumTraInt --> NUMERO TRANSACAO INTERCAMBIO
cNumProAnt --> Protocolo de Atendimento Anterior
cMsgLivre  --> Mensagem livre da manifestação

Retorno
1-lOk        --> Boolean indicando se a transacao foi processada com sucesso
2-aCriticas  --> Array com criticas
3-cNumProto  --> Numero do protocolo
4-cIdResp    --> Id de Resposta

/*/
//-------------------------------------------------------------------
Function PLSolProRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cNome,cCPF,cDDD,cTelefone,;
		cEmail,cTipManif,cTipCateg,cTipSent,cIDResp,cNumTraInt,cNumProAnt,cMsgLivre,aAuto,cTipSubCtg)

	Local cNumProto := ""
	Local cErro     := ""
	Local cAviso    := ""
	Local cSoap     := ""
	Local cHash     := ""
	Local aCriticas := {}
	Local aRet      := {}
	Local aRetFun   := {}
	Local aCab      := {}
	Local lRet      := .F.
	Local nX        := 0
	Local oGPU	    := Nil
	Local aParam    := {}

	default cTipSubCtg := ""
	Default aAuto   := {.F.,""}

	If GetNewPar("MV_PGPURES","0") == "1"
		aParam := {cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDatGer, cIDUsuario,; // Cabecalho
			cCodUniBen, cIDBenef, cNome, cCPF, cDDD, cTelefone, cEmail, cTipManif,; // Body
			cTipCateg, cIDResp, cNumTraInt, cNumProAnt, cMsgLivre, cTipSubCtg}

		oGPU := PGPUSolPro():New()
		If aAuto[1]
			oGPU:setAuto(aAuto[1])
			oGPU:setJsonRes(aAuto[2])
		EndIf
		oGPU:impLog("Realizando a comunicação GPU " + cvaltochar(dDataBase))
		aRetFun := oGPU:comunGPU(aParam)
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com dados do cabecalho         								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCab,{"001","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
		For nX := 1 to len(aCab[1])
			cHash += aCab[1][nX]
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Cabecalho        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := XmlIniFim(cSoap,'solicitarProtocolo',.T.,.F.,aCab,nil,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Corpo        								       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoPrestadora',cNumTraPre,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataGeracao',ajustaData(dDatGer),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idUsuario',cIDUsuario,nil,nil,.T.,@cHash)

		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'codigoUnimed',cValtoChar(Val(cCodUniBen)),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'codigoIdentificacao',cIDBenef,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'dadosBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'nomeBenef',cNome,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'cdCPF',cCPF,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'ddd',cDDD,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'telefone',cTelefone,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'email',cEmail,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dadosBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'identificacaoManifestacao',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'tipoManifestacao',cTipManif,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'tipoCategoria',cTipCateg,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'tipoSentimento',cTipSent,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoManifestacao',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'idresposta',cIDResp,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoIntercambio',cNumTraInt,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroProtocoloAnterior',cNumProAnt,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'mensagemLivre',cMsgLivre,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroVersaoProtocolo',GetNewPar("MV_R395LAY","001"),nil,nil,.T.,@cHash)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Finaliza arquivo     							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHash := Lower( MD5(cHash,2) )
		cSoap := XmlIniFim(cSoap,'solicitarProtocolo',.F.,.T.,aRet,cHash,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida estrutura do arquivo para envio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := vldXmlEnv(cSoap,.T.,"solicitarProtocoloWS")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para realizar a comunicacao e processar a resposta        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRet[1]

			aRet := comuniWsdl("solicitarProtocoloWS",cSoap,aAuto)
			If aRet[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida estrutura do arquivo de resposta                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetObj := ajusXMLRec(@cErro,@cAviso,aRet[2])
				If aRetObj[1]
					lRet  := .T.
					oObjXml    := aRetObj[2]
					cNameSpace := aRetObj[3]
				Else
					//Criticas na validacao de estrutura do arquivo resposta
					If !Empty(cErro)
						Aadd(aCriticas,{"999",cErro})
					EndIf
					If !Empty(cAviso)
						Aadd(aCriticas,{"999",cAviso})
					EndIf
				EndIf
			Else
				//Criticas na comunicacao com o WebService
				Aadd(aCriticas,{"999",aRet[3]})
			EndIf
		Else
			//Criticas de estrutura de arquivo
			Aadd(aCriticas,{"999",aRet[2]})
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver critica                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoTransacao") == "011"
				lRet := .F.
				Aadd(aCriticas,{PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\codigoErro"),;
					PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\mensagemErro") })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processado OK                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				cNumProto  := PLRetTagWB(oObjXml,cNameSpace,"respostasolicitarProtocolo\numeroProtocolo")
				cIdResp    := PLRetTagWB(oObjXml,cNameSpace,"respostasolicitarProtocolo\idResposta")
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de retorno                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aRetFun,lRet)
		Aadd(aRetFun,aCriticas)
		Aadd(aRetFun,cNumProto)
		Aadd(aRetFun,cIdResp)

	EndIf

Return aRetFun



//-------------------------------------------------------------------
/*/{Protheus.doc} PLComProRN
Monta chamada do WebService ComplementaProtocoloAtendimento - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16

Parametros:

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraOri --> Transacao de controle Unimed Origem
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProto  --> Numero do Protocolo gerado
cNrTrol    --> Numero da transacao de intercambio gerada


Retorno
1-lOk        --> Boolean indicando se a transacao foi processada com sucesso
2-aCriticas  --> aCriticas
/*/
//-------------------------------------------------------------------
Function PLComProRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cNumProto,cNrTrol,aAuto,cMsg)

	Local nX        := 0
	Local cNameSpace := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cSoap      := ""
	Local cHash      := ""
	Local aCab       := {}
	Local aRet       := {}
	Local aRetFun    := {}
	Local aRetObj    := {}
	Local aCriticas  := {}
	Local lRet       := .F.
	Local oGPU		 := Nil
	Local aParam     := {}

	Default aAuto    := {.F.,""}
	Default cMsg 	 := ""

	If GetNewPar("MV_PGPURES","0") == "1"
		aParam := {cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario,; // Cabecalho
			cCodUniBen, cIDBenef, cNumProto, cNrTrol, cMsg} // Body

		oGPU := PGPUComPro():New()
		If aAuto[1]
			oGPU:setAuto(aAuto[1])
			oGPU:setJsonRes(aAuto[2])
		EndIf
		aRetFun := oGPU:comunGPU(aParam)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com dados do cabecalho         								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCab,{"003","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
		For nX := 1 to len(aCab[1])
			cHash += aCab[1][nX]
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Cabecalho        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := XmlIniFim(cSoap,'complementoProtocolo',.T.,.F.,aCab,nil,.T.,'pedidoComplementoAutorizacao')
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Corpo        								       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoPrestadora',cNumTraOri ,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataGeracao',ajustaData(dDatGer),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idUsuario',cIDUsuario,nil,nil,.T.,@cHash)

		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'codigoUnimed',cValtoChar(Val(cCodUniBen)),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'codigoIdentificacao',cIDBenef,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'numeroProtocolo',cNumProto,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoIntercambio',cNrTrol,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroVersaoProtocolo',GetNewPar("MV_R395LAY","001"),nil,nil,.T.,@cHash)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Finaliza arquivo     							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHash := Lower( MD5(cHash,2) )
		cSoap := XmlIniFim(cSoap,'complementoProtocolo',.F.,.T.,aRet,cHash,.T.,'pedidoComplementoAutorizacao')

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida estrutura do arquivo para envio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := vldXmlEnv(cSoap,.T.,"complementoProtocoloWS")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para realizar a comunicacao e processar a resposta        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRet[1]


			aRet := comuniWsdl("complementoProtocoloWS",cSoap,aAuto)
			If aRet[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida estrutura do arquivo de resposta                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetObj := ajusXMLRec(@cErro,@cAviso,aRet[2])
				If aRetObj[1]
					lRet  := .T.
					oObjXml    := aRetObj[2]
					cNameSpace := aRetObj[3]
				Else
					//Criticas na validacao de estrutura do arquivo resposta
					If !Empty(cErro)
						Aadd(aCriticas,{"999",cErro})
					EndIf
					If !Empty(cAviso)
						Aadd(aCriticas,{"999",cAviso})
					EndIf
				EndIf
			Else
				//Criticas na comunicacao com o WebService
				Aadd(aCriticas,{"999",aRet[3]})
			EndIf
		Else
			//Criticas de estrutura de arquivo
			Aadd(aCriticas,{"999",aRet[2]})
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver critica                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoTransacao") == "011"
				lRet := .F.
				Aadd(aCriticas,{PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\codigoErro"),;
					PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\mensagemErro") })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processado OK, porem com situacao invalida                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf PLRetTagWB(oObjXml,cNameSpace,"confirmacao\tipoIdentificador") == "2"
				lRet := .F.
				Aadd(aCriticas,{"999","Situacao Invalida"})
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de retorno                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aRetFun,lRet)
		Aadd(aRetFun,aCriticas)
	EndIf

Return aRetFun


//-------------------------------------------------------------------
/*/{Protheus.doc} PLConStaRN
Monta chamada do WebService ConsultaStatusProtocolo - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16

Parametros:

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraOri --> Transacao de controle Unimed Origem
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProto  --> Numero do Protocolo gerado
cNrTrol    --> Numero da transacao de intercambio gerada
/*/
//-------------------------------------------------------------------
Function PLConStaRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cNumProto,aAuto)

	Local cNameSpace := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cTpManif   := ""
	Local cTpCateg   := ""
	Local cTpSentim  := ""
	Local cNumProtoc := ""
	Local cIdResp    := ""
	Local cSoap      := ""
	Local cHash      := ""
	Local aMenPedido := {}
	Local aMenResp   := {}
	Local aRet       := {}
	Local aRetFun    := {}
	Local aRetObj    := {}
	Local aCriticas  := {}
	Local aCab       := {}
	Local lRet       := .F.
	Local nX         := 0
	Local nTot       := 0
	Local oGPU	     := Nil

	Default aAuto    := {.F.,""}

	If GetNewPar("MV_PGPURES","0") == "1"
		aParam := {cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario,; // Cabecalho
			cCodUniBen, cIDBenef, cNumProto} // Body

		oGPU := PGPUConSta():New()
		If aAuto[1]
			oGPU:setAuto(aAuto[1])
			oGPU:setJsonRes(aAuto[2])
		EndIf
		aRetFun := oGPU:comunGPU(aParam)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com dados do cabecalho         								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCab,{"006","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
		For nX := 1 to len(aCab[1])
			cHash += aCab[1][nX]
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Cabecalho        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := XmlIniFim(cSoap,'consultaStatusProtocolo',.T.,.F.,aCab,nil,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Corpo        								       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoPrestadora',cNumTraOri ,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataGeracao',ajustaData(dDatGer),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idUsuario',cIDUsuario,nil,nil,.T.,@cHash)

		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'codigoUnimed',cValtoChar(Val(cCodUniBen)),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'codigoIdentificacao',cIDBenef,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'numeroProtocolo',cNumProto,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroVersaoProtocolo',GetNewPar("MV_R395LAY","001"),nil,nil,.T.,@cHash)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Finaliza arquivo     							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHash := Lower( MD5(cHash,2) )
		cSoap := XmlIniFim(cSoap,'consultaStatusProtocolo',.F.,.T.,aRet,cHash,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida estrutura do arquivo para envio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := vldXmlEnv(cSoap,.T.,"consultaStatusProtocoloWS")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para realizar a comunicacao e processar a resposta        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRet[1]

			aRet := comuniWsdl("consultaStatusProtocoloWS",cSoap,aAuto)
			If aRet[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida estrutura do arquivo de resposta                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetObj := ajusXMLRec(@cErro,@cAviso,aRet[2])
				If aRetObj[1]
					lRet  := .T.
					oObjXml    := aRetObj[2]
					cNameSpace := aRetObj[3]
				Else
					//Criticas na validacao de estrutura do arquivo resposta
					If !Empty(cErro)
						Aadd(aCriticas,{"999",cErro})
					EndIf
					If !Empty(cAviso)
						Aadd(aCriticas,{"999",cAviso})
					EndIf
				EndIf
			Else
				//Criticas na comunicacao com o WebService
				Aadd(aCriticas,{"999",aRet[3]})
			EndIf
		Else
			//Criticas de estrutura de arquivo
			Aadd(aCriticas,{"999",aRet[2]})
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver critica                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoTransacao") == "011"
				lRet := .F.
				Aadd(aCriticas,{PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\codigoErro"),;
					PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\mensagemErro") })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processado OK                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				cNumProtoc  := PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\numeroProtocolo")
				cTpManif    := PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoManifestacao\tipoManifestacao")
				cTpCateg    := PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoManifestacao\tipoCategoria")
				cTpSentim   := PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoManifestacao\tipoSentimento")
				cIdResp     := PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\idResposta")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Bloco identificacaoMensagemPedidoManifestacao    						 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("oObjXml:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"identificacaoMensagemPedidoManifestacao") == "O"
					Aadd(aMenPedido,{PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao\idUsuario") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao\dataEnvioMensagem","D") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao\dataRespostaMensagem","D") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao\mensagemLivre") })


				ElseIf  Type("oObjXml:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"identificacaoMensagemPedidoManifestacao") <> "U" .And. ;
						(nTot := len( &("oObjXml:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"identificacaoMensagemPedidoManifestacao") ) ) > 1

					For nX := 1 to nTot
						Aadd(aMenPedido,{PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao["+cValtoChar(nX)+"]\idUsuario") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao["+cValtoChar(nX)+"]\dataEnvioMensagem","D") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao["+cValtoChar(nX)+"]\dataRespostaMensagem","D") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemPedidoManifestacao["+cValtoChar(nX)+"]\mensagemLivre") })

					Next
				EndIF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Bloco identificacaoMensagemRespostaManifestacao                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("oObjXml:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"identificacaoMensagemRespostaManifestacao") == "O"
					Aadd(aMenResp,{PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao\idUsuario") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao\dataEnvioMensagem","D") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao\dataRespostaMensagem","D") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao\mensagemLivre") })


				ElseIf  Type("oObjXml:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"identificacaoMensagemRespostaManifestacao") <> "U" .And. ;
						(nTot := len( &("oObjXml:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"respostaConsultaStatusProtocolo:"+cNameSpace+"identificacaoMensagemRespostaManifestacao") ) ) > 1

					For nX := 1 to nTot
						Aadd(aMenResp,{PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao["+cValtoChar(nX)+"]\idUsuario") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao["+cValtoChar(nX)+"]\dataEnvioMensagem","D") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao["+cValtoChar(nX)+"]\dataRespostaMensagem","D") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaConsultaStatusProtocolo\respostaConsultaStatusProtocolo\identificacaoMensagemRespostaManifestacao["+cValtoChar(nX)+"]\mensagemLivre") })

					Next
				EndIF

			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de retorno                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aRetFun,lRet)
		Aadd(aRetFun,aCriticas)
		Aadd(aRetFun,cNumProtoc)
		Aadd(aRetFun,cTpManif)
		Aadd(aRetFun,cTpCateg)
		Aadd(aRetFun,cTpSentim)
		Aadd(aRetFun,cIdResp)
		Aadd(aRetFun,aMenPedido)
		Aadd(aRetFun,aMenResp)
	EndIf

Return aRetFun


//-------------------------------------------------------------------
/*/{Protheus.doc} PLConHisRN
Monta chamada do WebService ConsultaStatusProtocolo - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16

Parametros:

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraOri --> Transacao de controle Unimed Origem
dDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProto  --> Numero do Protocolo gerado
cNrTrol    --> Numero da transacao de intercambio gerada


/*/
//-------------------------------------------------------------------
Function PLConHisRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cNumProto,dDatSol,dDatResp,aAuto)

	Local cNameSpace := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cSoap      := ""
	Local cHash      := ""
	Local aRet       := {}
	Local aRetFun    := {}
	Local aRetObj    := {}
	Local aCriticas  := {}
	Local aHist      := {}
	Local aCab       := {}
	Local lRet       := .F.
	Local nX         := 0
	Local nTot       := 0
	Local oGPU       := Nil

	Default aAuto    := {.F.,""}

	If GetNewPar("MV_PGPURES","0") == "1"
		aParam := {cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario,; // Cabeçalho
			cCodUniBen, cIDBenef, dDatSol, dDatResp} // Body

		oGPU := PGPUConHis():New()
		If aAuto[1]
			oGPU:setAuto(aAuto[1])
			oGPU:setJsonRes(aAuto[2])
		EndIf
		aRetFun := oGPU:comunGPU(aParam)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com dados do cabecalho         								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCab,{"008","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
		For nX := 1 to len(aCab[1])
			cHash += aCab[1][nX]
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Cabecalho        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := XmlIniFim(cSoap,'consultaHistorico',.T.,.F.,aCab,nil,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Corpo        								       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoPrestadora',cNumTraOri ,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataGeracao',ajustaData(dDatGer),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idUsuario',cIDUsuario,nil,nil,.T.,@cHash)

		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'codigoUnimed',cValtoChar(Val(cCodUniBen)),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'codigoIdentificacao',cIDBenef,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'numeroProtocolo',cNumProto,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataSolicitacao',ajustaData(dDatSol),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataResposta',ajustaData(dDatResp),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroVersaoProtocolo',GetNewPar("MV_R395LAY","001"),nil,nil,.T.,@cHash)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Finaliza arquivo     							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHash := Lower( MD5(cHash,2) )
		cSoap := XmlIniFim(cSoap,'consultaHistorico',.F.,.T.,aRet,cHash,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida estrutura do arquivo para envio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := vldXmlEnv(cSoap,.T.,"consultaHistoricoWS")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para realizar a comunicacao e processar a resposta        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRet[1]

			aRet := comuniWsdl("consultaHistoricoWS",cSoap,aAuto)
			If aRet[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida estrutura do arquivo de resposta                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetObj := ajusXMLRec(@cErro,@cAviso,aRet[2])
				If aRetObj[1]
					lRet  := .T.
					oObjXml    := aRetObj[2]
					cNameSpace := aRetObj[3]
				Else
					//Criticas na validacao de estrutura do arquivo resposta
					If !Empty(cErro)
						Aadd(aCriticas,{"999",cErro})
					EndIf
					If !Empty(cAviso)
						Aadd(aCriticas,{"999",cAviso})
					EndIf
				EndIf
			Else
				//Criticas na comunicacao com o WebService
				Aadd(aCriticas,{"999",aRet[3]})
			EndIf
		Else
			//Criticas de estrutura de arquivo
			Aadd(aCriticas,{"999",aRet[2]})
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver critica                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoTransacao") == "011"
				lRet := .F.
				Aadd(aCriticas,{PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\codigoErro"),;
					PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\mensagemErro") })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processado OK                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				/* - Array de retorno:
				[1] -> numeroProtocolo
				[2] -> dataGeracao
				[3] -> idUsuario
				[4] -> numeroTransacaoIntercambioPrestadora
				[5] -> numeroTransacaoOrigemBeneficiario
				[6] -> idResposta
				[7] -> tipoManifestacao
				[8] -> tipoCategoria
				[9] -> tipoSentimento
				*/
				If Type("oObjXml:"+cNameSpace+"respostaConsultaHistorico:"+cNameSpace+"respostaConsultaHistorico") == "O"
					Aadd(aHist,{PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\numeroProtocolo") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\dataGeracao","D") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\idUsuario") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\numeroTransacaoIntercambioPrestadora") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\numeroTransacaoOrigemBeneficiario") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\idResposta") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\identificacaoManifestacao\tipoManifestacao") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\identificacaoManifestacao\tipoCategoria") ,;
						PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico\identificacaoManifestacao\tipoSentimento") })

				ElseIf  Type("oObjXml:"+cNameSpace+"respostaConsultaHistorico:"+cNameSpace+"respostaConsultaHistorico") <> "U" .And. ;
						(nTot := len( &("oObjXml:"+cNameSpace+"respostaConsultaHistorico:"+cNameSpace+"respostaConsultaHistorico") ) ) > 1

					For nX := 1 to nTot
						Aadd(aHist,{PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\numeroProtocolo") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\dataGeracao","D") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\idUsuario") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\numeroTransacaoIntercambioPrestadora") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\numeroTransacaoOrigemBeneficiario") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\idResposta") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\identificacaoManifestacao\tipoManifestacao") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\identificacaoManifestacao\tipoCategoria") ,;
							PLRetTagWB(oObjXml,cNameSpace,"respostaconsultaHistorico\respostaconsultaHistorico["+cValtoChar(nX)+"]\identificacaoManifestacao\tipoSentimento")})

					Next
				EndIF
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de retorno                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aRetFun,lRet)
		Aadd(aRetFun,aCriticas)
		Aadd(aRetFun,aHist)
	EndIf

Return aRetFun



//-------------------------------------------------------------------
/*/{Protheus.doc} PLCanProRN
Monta chamada do WebService cancelamentoWS - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16

Parametros:

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraOri --> Transacao de controle Unimed Origem
dDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProto  --> Numero do Protocolo gerado
cMotivo    --> Motivo do Cancelamento


/*/
//-------------------------------------------------------------------
Function PLCanProRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cMotivo,cNumProto,aAuto)

	Local nX        := 0
	Local cNameSpace := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cSoap      := ""
	Local cHash      := ""
	Local aCab       := {}
	Local aRet       := {}
	Local aRetObj    := {}
	Local aRetFun    := {}
	Local aCriticas  := {}
	Local lRet       := .F.
	Local oGPU       := Nil

	Default aAuto    := {.F.,""}

	If GetNewPar("MV_PGPURES","0") == "1"
		aParam := {cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario,; // Cabeçalho
			cCodUniBen, cIDBenef, cNumProto, cMotivo} // Body

		oGPU := PGPUCanAte():New()
		If aAuto[1]
			oGPU:setAuto(aAuto[1])
			oGPU:setJsonRes(aAuto[2])
		EndIf
		aRetFun := oGPU:comunGPU(aParam)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com dados do cabecalho         								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCab,{"010","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
		For nX := 1 to len(aCab[1])
			cHash += aCab[1][nX]
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Cabecalho        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := XmlIniFim(cSoap,'cancelamento',.T.,.F.,aCab,nil,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Corpo        								       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoPrestadora',cNumTraOri ,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataGeracao',ajustaData(dDatGer),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idUsuario',cIDUsuario,nil,nil,.T.,@cHash)

		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'codigoUnimed',cValtoChar(Val(cCodUniBen)),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'codigoIdentificacao',cIDBenef,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'numeroProtocolo',cNumProto,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroVersaoProtocolo',GetNewPar("MV_R395LAY","001"),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'descricaoMotivo',cMotivo,nil,nil,.T.,@cHash)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Finaliza arquivo     							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHash := Lower( MD5(cHash,2) )
		cSoap := XmlIniFim(cSoap,'cancelamento',.F.,.T.,aRet,cHash,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida estrutura do arquivo para envio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := vldXmlEnv(cSoap,.T.,"cancelamentoWS")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para realizar a comunicacao e processar a resposta        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRet[1]
			aRet := comuniWsdl("cancelamentoWS",cSoap,aAuto)
			If aRet[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida estrutura do arquivo de resposta                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetObj := ajusXMLRec(@cErro,@cAviso,aRet[2])
				If aRetObj[1]
					lRet  := .T.
					oObjXml    := aRetObj[2]
					cNameSpace := aRetObj[3]
				Else
					//Criticas na validacao de estrutura do arquivo resposta
					If !Empty(cErro)
						Aadd(aCriticas,{"999",cErro})
					EndIf
					If !Empty(cAviso)
						Aadd(aCriticas,{"999",cAviso})
					EndIf
				EndIf
			Else
				//Criticas na comunicacao com o WebService
				Aadd(aCriticas,{"999",aRet[3]})
			EndIf
		Else
			//Criticas de estrutura de arquivo
			Aadd(aCriticas,{"999",aRet[2]})
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver critica                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoTransacao") == "011"
				lRet := .F.
				Aadd(aCriticas,{PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\codigoErro"),;
					PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\mensagemErro") })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processado OK, porem com situacao invalida                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf PLRetTagWB(oObjXml,cNameSpace,"confirmacao\tipoIdentificador") == "2"
				lRet := .F.
				Aadd(aCriticas,{"999","Situacao Invalida"})
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de retorno                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aRetFun,lRet)
		Aadd(aRetFun,aCriticas)
	EndIf

Return aRetFun



//-------------------------------------------------------------------
/*/{Protheus.doc} PLResAteRN
Monta chamada do WebService respostaAtendimentoWS - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16

Parametros:

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraOri --> Transacao de controle Unimed Origem
dDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProto  --> Numero do Protocolo gerado
cIdResposta --> Id de Resposta
cNrTrol     --> Numero da transacao de intercambio
cMsgLivre   --> Mensagem Livre

Retorno
1-lOk        --> Boolean indicando se a transacao foi processada com sucesso
2-aCriticas  --> Array com criticas

/*/
//-------------------------------------------------------------------
Function PLResAteRN(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,;
		cNumProto,cIdResposta,cNrTrol,cMsgLivre,aAuto, aNoClient)

	Local nX        := 0
	Local cNameSpace := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cSoap      := ""
	Local cHash      := ""
	Local aRet       := {}
	Local aRetObj    := {}
	Local aRetFun    := {}
	Local aCab       := {}
	Local aCriticas  := {}
	Local lRet       := .F.
	Local oGPU       := Nil

	Default aAuto    := {.F.,""}
	Default aNoClient := {}

	If GetNewPar("MV_PGPURES","0") == "1"
		// Responder Protocolo Não Cliente
		If Len(aNoClient) >= 5
			oGPU := PGPUResNoClient():New()
			aParam := { cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario,; // Cabecalho
				cNumProto, cIdResposta, cMsgLivre, aNoClient[1], aNoClient[2], aNoClient[3],; // Body
				aNoClient[4], aNoClient[5]}

		Else // Responder Protocolo Cliente
			oGPU := PGPUResAte():New()
			aParam := { cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario,; // Cabecalho
				cCodUniBen, cIDBenef, cNumProto, cIdResposta, cNrTrol, cMsgLivre} // Body
		EndIf

		If aAuto[1]
			oGPU:setAuto(aAuto[1])
			oGPU:setJsonRes(aAuto[2])
		EndIf
		aRetFun := oGPU:comunGPU(aParam)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com dados do cabecalho         								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCab,{"005","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
		For nX := 1 to len(aCab[1])
			cHash += aCab[1][nX]
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Cabecalho        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := XmlIniFim(cSoap,'respostaAtendimento',.T.,.F.,aCab,nil,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Corpo        								       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoPrestadora',cNumTraOri ,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataGeracao',ajustaData(dDatGer),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idUsuario',cIDUsuario,nil,nil,.T.,@cHash)

		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'codigoUnimed',cValtoChar(Val(cCodUniBen)),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'codigoIdentificacao',cIDBenef,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'numeroProtocolo',cNumProto,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idResposta',cIdResposta,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoOrigemBeneficiario',cNrTrol,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroVersaoProtocolo',GetNewPar("MV_R395LAY","001"),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'mensagemLivre',cMsgLivre,nil,nil,.T.,@cHash)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Finaliza arquivo     							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHash := Lower( MD5(cHash,2) )
		cSoap := XmlIniFim(cSoap,'respostaAtendimento',.F.,.T.,aRet,cHash,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida estrutura do arquivo para envio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := vldXmlEnv(cSoap,.T.,"respostaAtendimentoWS")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para realizar a comunicacao e processar a resposta        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRet[1]
			aRet := comuniWsdl("respostaAtendimentoWS",cSoap,aAuto)
			If aRet[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida estrutura do arquivo de resposta                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetObj := ajusXMLRec(@cErro,@cAviso,aRet[2])
				If aRetObj[1]
					lRet  := .T.
					oObjXml    := aRetObj[2]
					cNameSpace := aRetObj[3]
				Else
					//Criticas na validacao de estrutura do arquivo resposta
					If !Empty(cErro)
						Aadd(aCriticas,{"999",cErro})
					EndIf
					If !Empty(cAviso)
						Aadd(aCriticas,{"999",cAviso})
					EndIf
				EndIf
			Else
				//Criticas na comunicacao com o WebService
				Aadd(aCriticas,{"999",aRet[3]})
			EndIf
		Else
			//Criticas de estrutura de arquivo
			Aadd(aCriticas,{"999",aRet[2]})
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver critica                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoTransacao") == "011"
				lRet := .F.
				Aadd(aCriticas,{PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\codigoErro"),;
					PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\mensagemErro") })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processado OK, porem com situacao invalida                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf PLRetTagWB(oObjXml,cNameSpace,"confirmacao\tipoIdentificador") == "2"
				lRet := .F.
				Aadd(aCriticas,{"999","Situacao Invalida"})
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de retorno                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aRetFun,lRet)
		Aadd(aRetFun,aCriticas)
	EndIf

Return aRetFun



//-------------------------------------------------------------------
/*/{Protheus.doc} PLEncExeRN
Monta chamada do WebService SolicitaProtocoloAtendimento - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16

Parametros:
cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraPre --> ID da Manifestação (Número de Transação da Prestadora)
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNome      --> Nome do Beneficiário
cCPF       --> Código do CPF
cDDD       --> Número do DDD
cTelefone  --> Número do telefone
cEmail     --> Endereço de email
cTipManif  --> Tipo de Manifestação
cTipCateg  --> Categoria da Manifestação
cTipSent   --> Sentimento do Cliente
cIDResp    --> Indica o status da manifestação
cNumTraInt --> NUMERO TRANSACAO INTERCAMBIO
cNumProAnt --> Protocolo de Atendimento Anterior
cMsgLivre  --> Mensagem livre da manifestação

Retorno
1-lOk        --> Boolean indicando se a transacao foi processada com sucesso
2-aCriticas  --> aCriticas

/*/
//-------------------------------------------------------------------
Function PLEncExeRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraIni,cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cNome,cCPF,cDDD,cTelefone,;
		cEmail,cTipManif,cTipCateg,cTipSent,cNumTraInt,cNumProtoc,cNumProAnt,cMsgLivre,aAuto,cTipSubCtg)

	Local nX        := 0
	Local cNameSpace := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cSoap      := ""
	Local cHash      := ""
	Local aCab       := {}
	Local aRet       := {}
	Local aRetObj    := {}
	Local aRetFun    := {}
	Local aCriticas  := {}
	Local lRet       := .F.
	Local oGPU       := Nil

	Default aAuto    := {.F.,""}

	If GetNewPar("MV_PGPURES","0") == "1"
		aParam := {cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario,; // Cabecalho
			cCodUniBen, cIDBenef, cNome, cCPF, cDDD, cTelefone, cEmail, cTipManif,; // Body
			cTipCateg, cNumTraInt, cNumProAnt, cMsgLivre, cTipSubCtg}

		oGPU := PGPUEncExe():New()
		If aAuto[1]
			oGPU:setAuto(aAuto[1])
			oGPU:setJsonRes(aAuto[2])
		EndIf
		aRetFun := oGPU:comunGPU(aParam)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array com dados do cabecalho         								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCab,{"012","UNIMED",cValtoChar(Val(cCodUniOri)),cValtoChar(Val(cCodUniDes)),cNumRegAns})
		For nX := 1 to len(aCab[1])
			cHash += aCab[1][nX]
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Cabecalho        								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := XmlIniFim(cSoap,'encaminharExecucao',.T.,.F.,aCab,nil,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Corpo        								       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoInicial',cNumTraIni ,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroTransacaoOrigem',cNumTraOri ,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dataGeracao',ajustaData(dDatGer),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'idUsuario',cIDUsuario,nil,nil,.T.,@cHash)

		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'codigoUnimed',cValtoChar(Val(cCodUniBen)),nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'codigoIdentificacao',cIDBenef,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'dadosBeneficiario',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'nomeBenef',cNome,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'cdCPF',cCPF,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'ddd',cDDD,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'telefone',cTelefone,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'email',cEmail,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'dadosBeneficiario',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'identificacaoManifestacao',nil,.T.,nil,.T.)
		cSoap := PLMntTagPT(cSoap,'tipoManifestacao',cTipManif,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'tipoCategoria',cTipCateg,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'tipoSentimento',cTipSent,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'identificacaoManifestacao',nil,nil,.T.,.T.)

		cSoap := PLMntTagPT(cSoap,'numeroTransacaoIntercambio',cNumTraInt,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroProtocolo',cNumProtoc,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroProtocoloAnterior',cNumProAnt,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'mensagemLivre',cMsgLivre,nil,nil,.T.,@cHash)
		cSoap := PLMntTagPT(cSoap,'numeroVersaoProtocolo',GetNewPar("MV_R395LAY","001"),nil,nil,.T.,@cHash)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string Soap - Finaliza arquivo     							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHash := Lower( MD5(cHash,2) )
		cSoap := XmlIniFim(cSoap,'encaminharExecucao',.F.,.T.,aRet,cHash,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida estrutura do arquivo para envio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := vldXmlEnv(cSoap,.T.,"encaminharExecucaoWS")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para realizar a comunicacao e processar a resposta        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRet[1]
			aRet := comuniWsdl("encaminharExecucaoWS",cSoap,aAuto)
			If aRet[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida estrutura do arquivo de resposta                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetObj := ajusXMLRec(@cErro,@cAviso,aRet[2])
				If aRetObj[1]
					lRet  := .T.
					oObjXml    := aRetObj[2]
					cNameSpace := aRetObj[3]
				Else
					//Criticas na validacao de estrutura do arquivo resposta
					If !Empty(cErro)
						Aadd(aCriticas,{"999",cErro})
					EndIf
					If !Empty(cAviso)
						Aadd(aCriticas,{"999",cAviso})
					EndIf
				EndIf
			Else
				//Criticas na comunicacao com o WebService
				Aadd(aCriticas,{"999",aRet[3]})
			EndIf
		Else
			//Criticas de estrutura de arquivo
			Aadd(aCriticas,{"999",aRet[2]})
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver critica                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLRetTagWB(oObjXml,cNameSpace,"cabecalhoTransacao\codigoTransacao") == "011"
				lRet := .F.
				Aadd(aCriticas,{PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\codigoErro"),;
					PLRetTagWB(oObjXml,cNameSpace,"erroInesperado\mensagemErro") })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processado OK, porem com situacao invalida                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf PLRetTagWB(oObjXml,cNameSpace,"confirmacao\tipoIdentificador") == "2"
				lRet := .F.
				Aadd(aCriticas,{"999","Situacao Invalida"})
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de retorno                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aRetFun,lRet)
		Aadd(aRetFun,aCriticas)
	EndIf

Return aRetFun



//-------------------------------------------------------------------
/*/{Protheus.doc} comuniWsdl
Gera os arquivos .pem para conectar com o WebService

@author  PLS TEAM
@version P11
@since   06.09.16
/*/
//-------------------------------------------------------------------
Static Function comuniWsdl(cAcao,cXml,aAuto)
	Local oWsdl
	Local cPFX   := PLSMUDSIS("\pl395web\certificados\certificado.p12")
	Local cCA    := PLSMUDSIS("\pl395web\certificados\ca.pem")
	Local cCert  := PLSMUDSIS("\pl395web\certificados\cert.pem")
	Local cKey   := PLSMUDSIS("\pl395web\certificados\key.pem")
	Local cPass  := GetNewPar("MV_R395SEN","")
	Local lLog   := GetNewPar("MV_R395LOG","") == "1"
	Local cError := ""
	Local cSoap  := ""
	Local cUrl   := ""
	Local lRet   := .T.
	Local nAt    := 0
	Local aOps   := {}
	Default aAuto := {.F.,""}

	//Extrai o CA do arquivo PFX
	If !PFXCA2PEM( cPFX, cCA, @cError, cPass ) .And. !aAuto[1]
		cError := "Não foi possível gerar o arquivo CA." + Chr(10)
		lRet := .F.
	EndIf

	//Extrai o Cert do arquivo PFX
	If !PFXCert2PEM( cPFX, cCert, @cError, cPass ) .And. !aAuto[1]
		cError := "Não foi possível gerar o arquivo Cert." + Chr(10)
		lRet := .F.
	EndIf

	//Extrai a Key do arquivo PFX
	If !PFXKey2PEM( cPFX, cKey, @cError, cPass ) .And. !aAuto[1]
		cError := "Não foi possível gerar o arquivo Key." + Chr(10)
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta a operacao e URL                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case cAcao == "solicitarProtocoloWS"
			cUrl  := GetNewPar("MV_R395SOL","")

		Case cAcao == "complementoProtocoloWS"
			cUrl  := GetNewPar("MV_R395COM","")

		Case cAcao == "respostaAtendimentoWS"
			cUrl  := GetNewPar("MV_R395RES","")

		Case cAcao == "cancelamentoWS"
			cUrl  := GetNewPar("MV_R395CAN","")

		Case cAcao == "consultaHistoricoWS"
			cUrl  := GetNewPar("MV_R395HIS","")

		Case cAcao == "consultaStatusProtocoloWS"
			cUrl  := GetNewPar("MV_R395STA","")

		Case cAcao == "encaminharExecucaoWS"
			cUrl  := GetNewPar("MV_R395ENC","")
	EndCase

	//Ponto de entrada utilizada para testes internos
	If ExistBlock( "PLWSD395" )
		aRetAux := ExecBlock( "PLWSD395", .F., .F., {cAcao,cXml} )
		lRet    := aRetAux[1]
		cSoap   := aRetAux[2]
		cError  := aRetAux[3]
	Else
		If lRet
			oWsdl := TwsdlManager():New()
			oWsdl:cSSLCACertFile := cCA
			oWsdl:cSSLCertFile   := cCert
			oWsdl:cSSLKeyFile    := cKey
			oWsdl:cSSLKeyPwd     := cPass
			oWsdl:bNoCheckPeerCert := .T.
			oWsdl:cEncoding      := "iso-8859-1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza o Parse da URL com o EndPoint                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aAuto[1] .Or. oWsdl:ParseURL( cURL )

				aOps := IIF(aAuto[1], {{"TESTE AUTO"}}, oWsdl:ListOperations() )

				If len(aOps) > 0
					cOper := aOps[1][1]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seta a Operacao  					                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aAuto[1] .Or. oWsdl:SetOperation(cOper)

						//Envia para o log o Soap de Envio
						If lLog
							PLRN395Log("-----------------------------------------------")
							PLRN395Log(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
							PLRN395Log("-----------------------------------------------")
							PLRN395Log("Soap Enviado:")
							PLRN395Log(EncodeUTF8(cXml))
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Envia o SOAP     					                                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						if aAuto[1]
							cSoap := aAuto[2]
						else
							oWsdl:SendSoapMsg(EncodeUTF8(cXml))
							cSoap := (oWsdl:GetSoapResponse() )
						endIf

						//Envia para o log o Soap de Resposta
						If lLog
							PLRN395Log("-----------------------------------------------")
							PLRN395Log(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
							PLRN395Log("-----------------------------------------------")
							PLRN395Log("Soap Resposta:")
							PLRN395Log(cSoap)
							If !aAuto[1] .And. !Empty(oWsdl:cError)
								PLRN395Log("")
								PLRN395Log("Erro WSDL Resposta:")
								PLRN395Log(oWsdl:cError)
							EndIf
						EndIf

					EndIf
				Else
					lRet   := .F.
					cError := "Não foi possível realizar a comunicacao: Nao foi possivel encontrar a lista de Operacoes do WebService"
				Endif
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa a resposta de erro  		                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !Empty(oWsdl:cError)
			If (nAt := At('FAULT STRING:',Upper(oWsdl:cError)) ) > 0
				cError := "Não foi possível realizar a comunicacao: " + Substr(oWsdl:cError,nAt+len('FAULT STRING:'),len(oWsdl:cError))
			Else
				cError := "Não foi possível realizar a comunicacao: " + oWsdl:cError
			EndIf
			lRet := .F.
		EndIf
	EndIf

Return({lRet,cSoap,cError})



//-------------------------------------------------------------------
/*/{Protheus.doc} ajustaData
Ajusta a data para o formato esperado no SOAP

@author  PLS TEAM
@version P11
@since   06.09.16
/*/
//-------------------------------------------------------------------
Static Function ajustaData(dData,cHorario)
	Local cRet := ""
	Default cHorario := Time()

	If !Empty(dData)
		cRet := Substr(Dtos(dData),1,4)+"-"+Substr(Dtos(dData),5,2)+"-"+Substr(Dtos(dData),7,2)+"T"+cHorario
	EndIf

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PLsPtuLog
Grava o Log com a descricao
cLogErro - Texto a ser gravado no arquivo.
o ARQUIVO DEFAULT E DE USO EXCLUSIVO DO PTU ONLINE

@author  PLS TEAM
@version P11
@since   10.01.17
/*/
//-------------------------------------------------------------------
Function PLRN395Log(cLogErro,cArqlog)
	DEFAULT cArqlog := "pl395log.log"

	//Este log nao pode mudar o nome do arquivo pq este arquivo e exibido na apl
	PlsLogFil(cLogErro,cArqlog)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LogRes395
Gera arquivo pl395log.log

@author  PLS TEAM
@version P11
@since   10.01.17
/*/
//-------------------------------------------------------------------
Function LogRes395(cRet)

	If GetNewPar("MV_R395LOG","") == "1"
		PLRN395Log("-----------------------------------------------")
		PLRN395Log(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
		PLRN395Log("-----------------------------------------------")
		PLRN395Log("Soap Resposta:")
		PLRN395Log(cRet)
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RetWsdl
Retorna o wsdl solicitado

@author renan.almeida
@since 03/09/2019
@version 1.0'1
/*/
//-------------------------------------------------------------------
Static Function RetWsdl(cWsdl,cWebService,lAuto)

	Local oXml
	Local cXml     := "Transacao nao suportada"
	Local cErro    := ""
	Local cAviso   := ""
	Local PVirtual := "/"
	Local cURLGet  := ""
	Local cUrlRet  := ""
	Local cPath    := ""
	Local nPosSB   := 0
	Local lRetWsdl := .F.
	Default lAuto  := .F.

	HttpCtType( "text/xml; charset="+'UTF-8' )
	oXml := XmlParserFile("\pl395web\schemas\"+cWsdl,"_",@cErro,@cAviso)

	If Empty(cErro) .And. Empty(cAviso)
		If XmlNodeExist(oXml,"_WSDL_DEFINITIONS") .And. XmlNodeExist(oXml:_WSDL_DEFINITIONS,"_XMLNS_TNS")
			__cTissTNS := oXml:_WSDL_DEFINITIONS:_XMLNS_TNS:TEXT
		ElseIf XmlNodeExist(oXml,"_DEFINITIONS") .And. XmlNodeExist(oXml:_DEFINITIONS,"_XMLNS_TNS")
			__cTissTNS := oXml:_DEFINITIONS:_XMLNS_TNS:TEXT
		EndIf
	Else
		cMsg := Iif( !Empty(cErro) ," Erro: "+cErro,"")
		cMsg += Iif( !Empty(cAviso)," Aviso:"+cAviso,"")

		cXml := "Transação não suportada: " + cMsg
	EndIf

	if lAuto
		cPath := "http://automacaoteste:8080/portal/"+cWebService+".apw"
	ElseIf Len(httpHeadIn->aHeaders) >= 1 .And. aScan(Httpget->aGets,{|x| x == "WSDL" }) > 0 .And. Len(Httpget->aGets) == 1
		cPath := httpHeadIn->aHeaders[1]
	EndIf

	If !Empty(cPath)

		nPosFB 	:= At("/",cPath)
		If nPosFB>0
			cURLGet := SubStr(cPath,nPosFB+1)
			nPosSB 	:= At("/",cURLGet)+1
			If nPosSB>0

				PVirtual := SubStr(cPath,nPosFB,nPosSB)
				If At(".APW",Upper(PVirtual) ) > 0 .Or. At("?WSDL",Upper(PVirtual) ) > 0
					PVirtual := "/"
				EndIf

			EndIf
		EndIf

		cUrlRet := iif(lAuto,"http://automacaoteste:8080/portal/"+cWebService+".apw", "http://"+httpHeadIn->Host+PVirtual+cWebService+".apw")
		oXml:_DEFINITIONS:_SERVICE:_PORT:_SOAP_ADDRESS:_LOCATION:TEXT := cUrlRet
		SAVE oXml XMLSTRING cXML
		lRetWsdl := .T.

	EndIf

Return {lRetWsdl,cXml}