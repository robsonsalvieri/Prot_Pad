#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"
#INCLUDE "FWLIBVERSION.CH"

Static lXmlVerbas	:= Val(SuperGetMv("MV_FASESOC",,'2')) == 2
Static nContRes		:= 0
Static lParcial		:= .F.
Static lGeraRat  	:= SuperGetMv("MV_RATESOC",, .T.)
Static lVerRJ5		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .F.) .And. !lParcial)
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static dDtcgini		:= SuperGetMv("MV_DTCGINI", , cToD("//"))
Static __oSt1		//Query para verificar se h· fÈrias calculadas no periodo
Static __oSt2		//Query com as fÈrias calculadas
Static __oSt3		 	//Query para verificar quais perÌodos foram calculados no dissÌdio
Static lNewDmDev	:= SuperGetMv("MV_IDEVTE", , .F.) .And. ChkFile("RU8") .And. FindFunction("fGetPrefixo")

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ GPEM026C ≥ Autor ≥ Gabriel de Souza Almeida                    ≥ Data ≥ 04/01/2016 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ FunÁıes para envio de Aviso PrÈvio... ao TAF                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥                       ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista     ≥ Data     ≥ FNC/Requisito  ≥Chamado≥Motivo da Alteracao                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Gabriel A.   ≥04/01/2016≥                ≥TUCT15 ≥CriaÁ„o da funÁ„o inclus„o e alteraÁ„o de avi≥±±
±±≥             ≥          ≥                ≥       ≥so PrÈvio                                    ≥±±
±±≥Marcia Moura ≥08/09/2016≥                ≥TVZVHZa ≥Alteracao do evento, para que gere o codigo ≥±±
±±≥             ≥          ≥                ≥        ≥unico ao inves da matricula para identificar≥±±
±±≥             ≥          ≥                ≥        ≥o funcionario no TAF                        ≥±±
±±≥Marcos Cout. ≥17/05/2017≥ DRHESOCP-278   ≥        ≥CriaÁ„o do evento S-2298 do eSocial - Reint ≥±±
±±≥Marcos Cout. ≥26/05/2017≥ DRHESOCP-282   ≥        ≥CriaÁ„o do evento S-2299 do eSocial - Deslig≥±±
±±≥Marcos Cout. ≥01/06/2017≥ DRHESOCP-320   ≥        ≥CriaÁ„o do evento S-2299 do eSocial         ≥±±
±±≥             ≥          ≥                ≥        ≥S-2299 - Desligamento Coletivo              ≥±±
±±≥Marcos Cout. ≥02/06/2017≥DRHESOCP-331    ≥        ≥Ajustes para geraÁ„o de LOG. Evento         ≥±±
±±≥             ≥          ≥                ≥        ≥S-2299 - Desligamento Coletivo.             ≥±±
±±≥Eduardo Vice ≥02/08/2017≥DRHESOCP-744    ≥        ≥ Ajustes na chamada da FunÁ„o fGp23Cons	  ≥±±
±±≥Eduardo V    ≥11/08/2017≥DRHESOCP-781    ≥        ≥CorreÁıes de erros apontadas a issue 592    ≥±±
±±≥Eduardo V    ≥14/08/2017≥DRHESOCP-866    ≥        ≥DeclaraÁ„o de Variaveis                     ≥±±
±±≥Marcos Cout  ≥24/08/2017≥DRHESOCP-868    ≥        ≥Realizado ajustes para gerar rescis„o cor_  ≥±±
±±≥             ≥          ≥                ≥        ≥_retamente. Problema ao ponteirar a filial  ≥±±
±±≥Marcos Cout  ≥25/08/2017≥DRHESOCP-791    ≥        ≥Realizando ajustes para que o Aviso Previo  ≥±±
±±≥             ≥          ≥DRHESOCP-949    ≥        ≥seja gerado corretamente para funcionarios  ≥±±
±±≥             ≥          ≥                ≥        ≥de outras filiais que n„o sejam a matriz    ≥±±
±±≥Eduardo Vic  ≥28/08/2017≥DRHESOCP-871    ≥        ≥inclus„o de tratativa quando exclus„o 000026≥±±
±±≥CecÌlia C.   ≥21/08/2017≥DRHESOCP-736    ≥        ≥GravaÁ„o do campo RG_INDAV no registro      ≥±±
±±≥             ≥          ≥                ≥        ≥S-2299 - Desligamento.                      ≥±±
±±≥Eduardo Vic  ≥30/08/2017≥DRHESOCP-848    ≥        ≥Tratativa de quando È feito a exclus„o da   ≥±±
±±≥Eduardo Vic  ≥		   ≥			    ≥        ≥linha com a aÁ„o de alteraÁ„o				  ≥±±
±±≥CecÌlia C.   ≥08/09/2017≥DRHESOCP-1015   ≥        ≥Inclus„o da TAG tpDep na geraÁ„o do evento  ≥±±
±±≥             ≥          ≥                ≥        ≥S-2299 - Desligamento.                      ≥±±
±±≥Marcos Cout  ≥04/09/2017≥DRHESOCP-950    ≥        ≥Realizando a tratativa do FwModelPos do MVC ≥±±
±±≥             ≥		   ≥			    ≥        ≥da tela de Cadastro de Aviso Previo         ≥±±
±±≥Eduardo Vic  ≥12/09/2017≥DRHESOCP-963    ≥        ≥Tratada array aDadosRAZ corrigindo erro.    ≥±±
±±≥Marcos Cout  ≥28/09/2017≥DRHESOCP-1362   ≥        ≥Realizando ajustes necess·rios para integrar≥±±
±±≥             ≥          ≥                ≥        ≥a tag <indCumprParc> com o valor correto    ≥±±
±±≥             ≥          ≥                ≥        ≥Ajustes para layout 2.2 e 2.3               ≥±±
±±≥CecÌlia C.   ≥05/10/2017≥DRHESOCP-1327   ≥        ≥Ajuste na geraÁ„o dos valores do plano de   ≥±±
±±≥             ≥          ≥                ≥        ≥sa˙de do dependente para o evento S-2299.   ≥±±
±±≥CecÌlia Carv ≥08/01/2018≥DRHESOCP-2682   ≥        ≥Ajuste para geraÁ„o de contrato intermitente≥±±
±±≥             ≥          ≥                ≥        ≥ - evento S-2200.                           ≥±±
±±≥CecÌlia Carv ≥31/01/2018≥DRHESOCP-2687   ≥        ≥Ajuste na gravaÁ„o das tag's <ideTabRubr>   ≥±±
±±≥             ≥          ≥DRHESOCP-2220   ≥        ≥(DRHESOCP-2687) e <ideDmDev> (DRHESOCP-2220)≥±±
±±≥             ≥          ≥                ≥        ≥do evento S-2299.                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ fAvsPrvEso    ≥ Autor ≥ Gabriel A.      ≥ Data ≥ 05/01/2016≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ FunÁ„o que gera o XML de aviso prÈvio para integraÁ„o com o≥±±
±±≥          ≥ TAF                                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ fAvsPrvEso(nOpca,lCanc,aDados)                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ GPEM026B                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function fAvsPrvEso(nOpca,aDados,oGridAvPrv)

	Local aFilInTaf := {}
	Local aArrayFil := {}
	Local cFilEnv := ""
	Local cXml := ""
	Local nI := 0
	Local cMsgErro:= ""
	Private aErros := []

	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	nI := oGridAvPrv:Length()
	oGridAvPrv:GoLine(nI) //Posiciona objeto na linha corrente
	If nOpca <> 5 .And. !oGridAvPrv:IsDeleted()
		cXml +=	'<eSocial>'
		cXml +=		'<evtAvPrevio>'
		cXml +=			'<ideVinculo>'
		cXml +=				'<cpfTrab>' + AllTrim(SRA->RA_CIC) + '</cpfTrab>'
		cXml +=				'<nisTrab>' + AllTrim(SRA->RA_PIS) + '</nisTrab>'
		cXml +=				'<matricula>' + SRA->RA_CODUNIC + '</matricula>'
		cXml +=			'</ideVinculo>'
		cXml +=			'<infoAvPrevio>'
		If Empty(oGridAvPrv:GetValue("RFY_DTCAP"))
			cXml +=			'<detAvPrevio>'
			cXml +=				'<dtAvPrv>' + Dtos(oGridAvPrv:GetValue("RFY_DTASVP")) + '</dtAvPrv>'
			cXml +=				'<dtPrevDeslig>' + Dtos(oGridAvPrv:GetValue("RFY_DTPJAV")) + '</dtPrevDeslig>'
			cXml +=				'<tpAvPrevio>' + oGridAvPrv:GetValue("RFY_TPAVIS") + '</tpAvPrevio>'
			cXml +=				'<observacao>' + FwNoAccent(oGridAvPrv:GetValue("RFY_OBSAV")) + '</observacao>'
			cXml +=			'</detAvPrevio>'
		Else
			cXml +=			'<cancAvPrevio>'
			cXml +=				'<dtCancAvPrv>' + Dtos(oGridAvPrv:GetValue("RFY_DTCAP")) + '</dtCancAvPrv>'
			cXml +=				'<observacao>' + FwNoAccent(oGridAvPrv:GetValue("RFY_OBSCAP")) + '</observacao>'
			cXml +=				'<mtvCancAvPrevio>' + oGridAvPrv:GetValue("RFY_TPCAP") + '</mtvCancAvPrevio>'
			cXml +=			'</cancAvPrevio>'
		EndIf
		cXml +=			'</infoAvPrevio>'
		cXml +=		'</evtAvPrevio>'
		cXml +=	'</eSocial>'
	Else //Exclus„o
		InExc3000(@cXml,'S-2250',(SRA->RA_CIC+SRA->RA_CODUNIC+Dtos(oGridAvPrv:GetValue("RFY_DTASVP"))),SRA->RA_CIC,SRA->RA_PIS,,)
	EndIf

	If !Empty(cXml)
		//Realiza geraÁ„o de XML na System
		GrvTxtArq(alltrim(cXml), If(nOpca <> 5 .And. !oGridAvPrv:IsDeleted(nI), "S2250", "S3000"), SRA->RA_CIC)
	Endif

	If nOpca <> 5 .And. !oGridAvPrv:IsDeleted(nI)
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2250")
		lRet:= IIF(Len(aErros) > 0,.F.,.T.)
	Else
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
		lRet:= IIF(Len(aErros) > 0,.F.,.T.)
	EndIf

	If Len( aErros ) > 0
		FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
		//Anula a mensagem de erro devido ao MVC da tela original
		//fEFDMsgErro(cMsgErro)
		If aErros[1]!='000026'
			aAdd(aDados, cMsgErro)
		EndIf
	EndIf
	If !Empty(cXml) .And. lRet
		fEFDMsg()
	EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ fInt2298 ≥ Autor ≥ Alessandro Santos     ≥ Data ≥ 14/04/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel por integrar as acoes realizadas na roti≥±±
±±≥          ≥ na de Reintegracao GPEA810 com o ambiente TAF.             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ eSocial - Uso Exclusivo Pais Brasil                        ≥±±
±±≥          ≥ Na rotina GPEA810 - Reintegracao de Funcionarios - S2820   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ aInfoTaf - Array com informacoes de reintegracao.          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fInt2298(aInfoTaf,aErros,cReg)

	Local aArea			:= GetArea()
	Local aFilInTaf		:= {}
	Local aArrayFil		:= {}
	Local cFilEnv		:= ""
	Local cXml			:= ""
	Local cTipoReint	:= ""
	Local lGravou		:= .T.
	Local cCatEFD
	Local cVersEnvio	:= ""
	Local lNDE			:= .F.

	Local cEFDAviso  	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")//Se nao encontrar este parametro apenas emitira alertas
	Local cVersMw	 	:= ""
	Local cChave	 	:= ""
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cOper2298	 	:= "I"
	Local cRecib2298 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2298	 	:= "1"
	Local cStat2298	 	:= "-1"
	Local nRec2298   	:= 0
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local cStat1000	 	:= "-1"

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2298",,,, @cVersEnvio , , @cVersMw )
		lNDE := cVersEnvio >= "2.6"
	EndIf

	Default cReg		:= "S2298"

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	Endif

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	//Geracao do evento S2298
	If !Empty(cFilEnv)

		If( Len(aInfoTaf[4]) == 2 )
			cTipoReint := SubStr(aInfoTaf[4], 1,1) //Recupera sÛ a 1a posicao
		Else
			cTipoReint := aInfoTaf[4]
		EndIf

		cCatEFD := AllTrim(SRA->RA_CATEFD)

		If (cCatEFD $ '101*102*103*104*105*106*111*301*302*303*306*307*309')
			If lMiddleware
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				lS1000 := fVld1000( AnoMes(SRA->RA_ADMISSA), @cStat1000 )

				If !lS1000 .And. cEFDAviso != "2"
					Do Case
						Case cStat1000 == "-1" // nao encontrado na base de dados
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX n„o localizado na base de dados"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX n„o localizado na base de dados"
							EndIf
						Case cStat1000 == "1" // nao enviado para o governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX n„o transmitido para o governo"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX n„o transmitido para o governo"
							EndIf
						Case cStat1000 == "2" // enviado e aguardando retorno do governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
							EndIf
						Case cStat1000 == "3" // enviado e retornado com erro
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
							EndIf
					EndCase
				Endif

				If lGravou
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChave	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2298" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStat2298 	:= "-1"
					GetInfRJE( 2, cChave, @cStat2298, @cOper2298, @cRetf2298, @nRec2298, @cRecib2298, @cRecibAnt )

					If cStat2298 == "-1"
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					ElseIf cStat2298 $ "1/3"
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .F.
					//Ser· gerado uma retificaÁ„o
					ElseIf cStat2298 == "4"
						cOperNew 	:= "A"
						cRetfNew	:= "2"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					Endif

					If cRetfNew == "2"
						If cStat2298 == "4"
							cRecibXML 	:= cRecib2298
							cRecibAnt	:= cRecib2298
							cRecib2298	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf

					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2298", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2298, cRecibAnt } )
					cXml := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtReintegr/v" + cVersMw + "'>"
					cXml +=		"<evtReintegr Id='" + cId + "'>"
					fXMLIdEve( @cXml, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" } )
					fXMLIdEmp( @cXml, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Endif
			Endif

			If lGravou
				If !lMiddleware
					cXml +=	'<eSocial>'
					cXml +=		'<evtReintegr>'
				Endif

				cXml +=			'<ideVinculo>'
				cXml +=				'<cpfTrab>' + AllTrim(SRA->RA_CIC) + '</cpfTrab>'
				If cVersEnvio < "9.0.00"
					cXml +=				'<nisTrab>' + AllTrim(SRA->RA_PIS) + '</nisTrab>'
				EndIf
				cXml +=				'<matricula>' + SRA->RA_CODUNIC + '</matricula>'
				cXml +=			'</ideVinculo>'
				cXml +=			'<infoReintegr>'
				cXml +=				'<tpReint>' + cTipoReint + '</tpReint>'
				If !lMiddleware .Or. !Empty(aInfoTaf[5])
					cXml +=				'<nrProcJud>' + aInfoTaf[5] + '</nrProcJud>'
				EndIf
				If !Empty(aInfoTaf[6])
					cXml +=				'<nrLeiAnistia>' + aInfoTaf[6] + '</nrLeiAnistia>'
				Endif
				If !lMiddleware
					cXml +=				'<dtEfetRetorno>' + Dtos(aInfoTaf[8]) + '</dtEfetRetorno>'
				Else
					cXml +=				'<dtEfetRetorno>' + SubStr( dToS(aInfoTaf[8]), 1, 4 ) + "-" + SubStr( dToS(aInfoTaf[8]), 5, 2 ) + "-" + SubStr( dToS(aInfoTaf[8]), 7, 2 ) + '</dtEfetRetorno>'
				EndIf
				If !lMiddleware
					cXml +=				'<dtEfeito>' + Dtos(aInfoTaf[7]) + '</dtEfeito>'
				Else
					cXml +=				'<dtEfeito>' + SubStr( dToS(aInfoTaf[7]), 1, 4 ) + "-" + SubStr( dToS(aInfoTaf[7]), 5, 2 ) + "-" + SubStr( dToS(aInfoTaf[7]), 7, 2 ) + '</dtEfeito>'
				EndIf
				If !( lNDE .And. aInfoTaf[7] >= StoD("01/01/2020") ) .And. cVersEnvio < "9.0.00"
					cXml +=			'<indPagtoJuizo>' + IIf(SubStr(aInfoTaf[4],2,1) == "A","S","N") + '</indPagtoJuizo>'
				EndIf
				cXml +=			'</infoReintegr>'
				cXml +=		'</evtReintegr>'
				cXml +=	'</eSocial>'

				GrvTxtArq(alltrim(cXml), "S2298")
			Endif

			If !lMiddleware
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2298")
				If Len(aErros) > 0
					MsgAlert(OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], OemToAnsi(STR0001) ) //  "Atencao"
					lGravou := .F.
				Endif
			Else
				If Len(aDados) > 0
					If !(lGravou := fGravaRJE( aDados, cXML, lNovoRJE, nRec2298 ))
						aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
					EndIf
				Endif
			Endif
		EndIf

	EndIf

	RestArea(aArea)

Return lGravou

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fInt2299   ≥ Autor ≥ Marcos Coutinho      ≥ Data ≥ 20/05/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel por realizar a integracao de dados gera_≥±±
±±≥          ≥ dos na rescicao com o TAF. Evento S-2299 - Desligamento    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ eSocial - Uso Exclusivo Pais Brasil                        ≥±±
±±≥          ≥ Na rotina GPEM040 - Rescisao de Funcionario S-2299         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ oModel   - Array com informacoes de rescisao.              ≥±±
±±≥          ≥ aErros   - Variavel responsavel por armazenar os erros     ≥±±
±±≥          ≥ cReg     - Codigo do evento em questao                     ≥±±
±±≥          ≥ cCodDslg - Codigo do eSocial de Desligamento               ≥±±
±±≥          ≥ cTpRes   - 1 = Rescisao Simples / 2 = Rescisao Coletiva    ≥±±
±±≥          ≥ aPd      - Array com as verbas do desligamento coletivo    ≥±±
±±≥          ≥ dDataRes - Data do Aviso Previo do funcionario (Coletivo)  ≥±±
±±≥          ≥ cDiaInde - Dias de Aviso indenizado (Coletivo)             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function fInt2299( oModel, aErros, cReg, cCodDslg, cTpRes, aPd, dDataRes, cDiaInde, cVersaoEnv, cIndAvPrv, lResComp, lRetif, nOpca, lNT15, lRel)

	Local aArea 		:= GetArea()
	Local aAreaSM0		:= SM0->(GetArea())
	Local aAreaCTT 		:= {} //Centro de Custo
	Local aAreaRJ5 		:= {}
	Local aAreaRJ3		:= {}
	Local aAreaSRV 		:= {} //Verbas
	Local aAreaRAZ 		:= {} //Multiplos Vinculos
	Local aAreaRCH 		:= {} //Periodos
	Local aFilInTaf 	:= {}
	Local cFilEnv 		:= ""
	Local cXml 			:= ""
	Local lGravou 		:= .T.
	Local cCodConvoc	:= ""
	Local cDiaSV7		:= "0"
	Local lIntermit		:= .F.
	Local oGrid
	Local oModelSRG

	Local nI 			:= 0
	Local aCodBenef 	:= {}
	Local nPerPens		:= 0
	Local aCC 			:= fGM23CTT()
	Local cTpInscr		:= ""
	Local cInscr 		:= ""
	Local cCEIObra		:= ""
	Local cCAEPF		:= ""
	Local nPosEstb		:= 0
	Local lSemFilSRV 	:= .F.
	Local cSimples 		:= ""
	Local cIndSimp 		:= ""
	Local nValor 		:= 0
	Local nPensao		:= 0
	Local dDtProj 		:= ""
	Local cStat   		:= ""
	Local cCpf			:= ""
	Local cPrcRubr		:= ""
	Local cTpLot		:= ""
	Local lRet 			:= .T.
	Local aCols 		:= {}
	Local aDadosRAZ 	:= {}
	Local aDadosCCT 	:= {}
	Local aDadosTRHR 	:= {}
	Local aDadosDRHR 	:= {}
	Local cInfoDiss		:= ""
	Local cMsgDiss		:= ""
	Local cVBDiss		:= ""
	Local cVbPla		:= ""
	Local cCodLot 		:= ""
	Local cCodRubr		:= ""
	Local cIdeRubr		:= ""
	Local cIdTabRub		:= ""
	Local lGeraCod		:= .F.
	Local lGerPla		:= .F.
	Local lPrimIdT		:= .T.
	Local nZ 			:= 0
	Local nX 			:= 0
	Local nW 			:= 0
	Local nD          	:= 0
	Local nContDev     	:= 0
	Local nOperation 	:= 0
	Local cIdDmDev   	:= ""
	Local aIdDmDev   	:= {}
	Local lVer2_3	    := .F.
	Local cProcess    	:= ""
	Local cRoteiro    	:= fGetCalcRot("C")  // Plano de Saude
	Local cPeriodo    	:= ""
	Local cNumPag     	:= ""
	Local cTabRH      	:= ""
	Local cComprovou	:= ""
	Local cMsg			:= ""
	Local lCarrDep		:= .F.
	Local aTabS037      := {} // Tabela S037.
	Local nCntS037      := 0 // Contador Tabela S037
	Local aAdiCC		:= {}
	Local aAdiCols		:= {}
	Local a131CC		:= {}
	Local a131Cols		:= {}
	Local a132CC		:= {}
	Local a132Cols		:= {}
	Local aFolCC		:= {}
	Local aFolCols		:= {}
	Local lCPFDepOk		:= .T.
	Local aDepAgreg		:= {}
	Local cTafKey		:= Nil
	Local lRJ5Ok		:= .T.
	Local aErrosRJ5		:= {}

	Local lParcial, lNovoCTT, lRJs := .F.
	Local cTipoPLA		:= fGetCalcRot('C')
	Local lCpoPDV		:= SRG->(ColumnPos("RG_PDV")) > 0
	Local cBkpFil	 	:= cFilAnt
	Local cEFDAviso  	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")//Se nao encontrar este parametro apenas emitira alertas
	Local cVersMw	 	:= ""
	Local cMsgErro	 	:= ""
	Local cChave	 	:= ""
	Local cChaveS1005	:= ""
	Local cStatus	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local lAdmPubl	 	:= .F.
	Local cTpInsc       := ""
	Local cNrInsc       := ""
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cOper2299	 	:= "I"
	Local cRecib2299 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2299	 	:= "1"
	Local cStat2299	 	:= "-1"
	Local nRec2299   	:= 0
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local lS1005 	 	:= .T.
	Local lS1010 	 	:= .T.
	Local lS1020 	 	:= .T.
	Local nCont			:= 0
	Local aErrosExc		:= {}
	Local cPdAnt		:= ""
	Local cCCAnt		:= ""
	Local lCMesAtual	:= .T.
	Local lRJ5FilT 		:= RJ5->(ColumnPos("RJ5_FILT")) > 0
	Local lTemReg		:= .F.
	Local lAltCC		:= .F.
	Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
	Local nTpRegTrab	:= 0
	Local aDiasConv		:= {}
	Local nC			:= 0
	Local dDtIniInt		:= CTOD("//")
	Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0 .And. cVersaoEnv >= "9.0"
	Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0 .And. cVersaoEnv >= "9.0"
	Local lQuarentena 	:= SRG->( ColumnPos( "RG_TPREMAD" ) ) > 0
	Local cFilRCA 		:= xFilial( "RCA", cFilAnt )
	Local dDataHom		:= CTOD("//")
	Local cMatricula    := ""
	Local cDtEfei		:= ""
	Local cCompAc		:= ""
	Local lTemRRA		:= .F.
	Local cPdRRA		:= ""
	Local cVerbRRA      := ""
	Local cVBDissRRA	:= ""
	Local cInfoRRA		:= ""
	Local cCompTrab		:= ""
	Local nMesRRA	    := 1
	Local lRetRRA       := .F.
	Local lRetIR		:= .F.
	Local nPosDmDev		:= 0
	Local dDtPagto		:= CTOD("//")
	Local lGeraPre		:= .F.
	Local cPrefixo		:= ""
	Local nComp         := 0
	Local lRetComp      := .T.
	Local nSvLinha		:= 0
	Local lDifINSSComp	:= .F.
	Local nPosS056		:= 0
	Local nPos			:= 0
	Local cDescMtv		:= ""
	Local cMsgRelat		:= ""
	Local aRelVbDiss	:= {}
	Local aErrosVb		:= {}
	Local lDedSimpl		:= .F.
	Local lGrvIR68		:= .F.
	Local lEmpECon      := .T.
	Local cCodINCIRF    := ""
	Local cCodNat		:= ""
	Local cFilIRF    	:= ""
	Local cMatIRF    	:= ""
	Local nValorIRF  	:= 0
	Local cPdIRF		:= ""
	Local cDtPesqI		:= ""
	Local cDtPesqF		:= ""
	Local cMsgPen       := ""
	Local dDtPgt        := CTOD("//")
	Local aErrosComp	:= {}
	Local nQtdPgto		:= ""
	Local cSemAdi		:= ""
	Local nContAdi		:= 0
	Local cCCRJ5        := ""
	Local cCodCCP15     := ""
	Local aErrosINCCP	:= {}
	Local cMsg15        := ""
	Local cDescCod      := ""
	Local lRetIncc      := .T.
	Local cDifDiss		:= ""
	Local nRecnoRJ5		:= 0
	Local cPdBkp		:= ""
	Local lAltPd		:= .F.
	Local lDtFerSub		:= .F.

	Private aEstb 		:= fGM23SM0(, .T.)
	Private bEstab 		:= {|| aScan(aEstb, {|x| x[1] == ALLTRIM(SRA->RA_FILIAL)})}
	Private nDecHor		:= TamSX3("RD_HORAS")[2]
	Private nDecVal		:= TamSX3("RD_VALOR")[2]
	Private nTamHor		:= TamSX3("RD_HORAS")[1]
	Private nTamMat		:= TamSX3("RD_MAT")[1]
	Private nTamVb		:= TamSX3("RD_PD")[1]
	Private nTamCC		:= TamSX3("RD_CC")[1]
	Private nTamVal		:= TamSX3("RD_VALOR")[1]
	Private nTamRot		:= TamSX3("RD_ROTEIR")[1]
	Private nTamDtPag	:= TamSX3("RR_DATAPAG")[1]
	Private cGpeAmbe	:= ""
	Private lAglut		:= .F.
	Private lSemFilCTT 	:= .F.
	Private aInfoRRA	:= {}
	Private aDtPgtDmDev	:= {}
	Private lVbRelIR	:= (FindFunction("fVbRelIR") .And. RJO->(ColumnPos("RJO_IDEDMD")) >  0 )
	Private aIncRel		:= {}
	Private aSM0     := FWLoadSM0(.T.)
	Private lResidExt	:= .F.
	Private aInfoPrev	:= {}
	Private aRetPensao	:= {}
	Private aDadosRHS   := {}
	Private aEConsig    := {}
	Private lVbFerSub	:= SRR->(ColumnPos("RR_FERSUB")) > 0 .And. SRC->(ColumnPos("RC_FERSUB")) > 0 .And. SRD->(ColumnPos("RD_FERSUB")) > 0   /// 11/2025
	Private dDtInFer    := SuperGetMV("MV_DTINFER",NIL,CTOD(" / / ") )  // Data de Inicio ConfiguraÁ„o de verbas substitutas de Ferias
	Private lVbContr    := .F.

	Default aErros 		:= {}
	Default cReg 		:= "S2299"
	Default aPd			:= {}
	Default dDataRes 	:= CTOD("//")
	Default cDiaInde	:= ""
	Default cVersaoEnv 	:= '2.2'
	Default lResComp	:= .F.
	Default lRetif		:= .F.
	Default nOpca		:= 3
	Default lNT15		:= .F.
	Default lRel		:= .F.

	RCA->( dbSetOrder(1) )
	If RCA->( dbSeek( cFilRCA + "P_ESOCMV" ) )
		lAglut := (AllTrim(RCA->RCA_CONTEU) == ".T.")
	EndIf

	lVer2_3 	:= (cVersaoEnv >= '2.3')
	nOperation 	:= Iif(cTpRes == "1", oModel:GetOperation(), nOpca)

	If Len(aEstb) > 0 .And. Len(aEstb[1]) > 4
		bEstab := {|| aScan(aEstb, {|x| x[5]+x[1] == FWGrpCompany() + ALLTRIM(SRA->RA_FILIAL)})}
	EndIf

	//Se trabalhador por contrato intermitente busca informaÁıes da tabela SV7 para a tag <infoTrabInterm>
	If SRA->RA_CATEFD == '111'
		lIntermit := .T.
		fBuscaSV7(SRA->RA_FILIAL, SRA->RA_MAT, dDataRes, @cCodConvoc, @lCMesAtual)
		If !Empty(cCodConvoc) .And. lCMesAtual
			cDiaSV7 := AllTrim(STR(Day(dDataRes),2))
		EndIf
		If cVersaoEnv >= "9.0.00"
			dDtIniInt := FirstDate( dDataRes )
			aDiasConv := fDiasConv(dDtIniInt, dDataRes)
		Endif
	Endif

	nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == SRA->RA_VIEMRAI})//Retorno: 0-CLT | >0-Estatutario

	If Len(aCodFol) > 0
		cPdRRA:= ("'"+aCodFol[0974,1]+"','"+aCodFol[0975,1]+"','"+aCodFol[0976,1]+"','"+aCodFol[0977,1]+"','"+aCodFol[0978,1]+"','"+aCodFol[0979,1]+"','"+aCodFol[0980,1]+"','"+aCodFol[0981,1]+"','"+aCodFol[0982,1]+"','"+aCodFol[0983,1]+"','"+aCodFol[0986,1]+"','"+aCodFol[0987,1]+"'")
		cVerbRRA := (aCodFol[0974,1]+"/"+aCodFol[0975,1]+"/"+aCodFol[0976,1]+"/"+aCodFol[0977,1]+"/"+aCodFol[0978,1]+"/"+aCodFol[0979,1]+"/"+aCodFol[0980,1]+"/"+aCodFol[0981,1]+"/"+aCodFol[0982,1]+"/"+aCodFol[0983,1]+"/"+aCodFol[0986,1]+"/"+aCodFol[0987,1])
		cDifDiss := (aCodFol[0337,1]+"/"+aCodFol[0338,1]+"/"+aCodFol[0339,1]+"/"+aCodFol[0340,1]+"/"+aCodFol[0398,1]+"/"+aCodFol[0399,1]+"/"+aCodFol[0400,1]+"/"+aCodFol[0401,1]+"/"+aCodFol[0341,1]+"/"+aCodFol[0342,1]+"/"+aCodFol[0402,1]+"/"+aCodFol[0403,1]+"/"+aCodFol[0943,1]+"/"+aCodFol[0944,1]+"/"+aCodFol[0945,1])
	Endif

	Begin Transaction
		//------------------------
		//| Tipo Rescisao Simples
		//| Caso a chamada da funcao tenha vindo da GPEM040()
		//----------------------------------------------------
		If( cTpRes == "1" ) .And. nOperation != 5
			oGrid 		:= oModel:GetModel('GPEM040_MGET')
			oModelSRG	:= oModel:GetModel('GPEM040_MSRG')

			If !lMiddleware
				fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				cStat2299 := TAFGetStat( "S-2299", AllTrim(SRA->RA_CIC) + ";" + AllTrim(SRA->RA_CODUNIC), , SRA->RA_FILIAL)
				If cStat2299 == "6"
					//"AtenÁ„o"##"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o pendente para transmiss„o"
					//"Verifique o status do evento S-3000 e tente novamente."
					aAdd(aErros, OemToAnsi(STR0146) + ". " + OemToAnsi(STR0326) )
					If !lRel
						If !IsInCallStack("fEnvLote")
							Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0146), 1, 0, , , , , , {OemToAnsi(STR0326)})
						EndIf
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf
				EndIf
			EndIf

			cComprovou := If( Type("cNewEmpAvP") == "U", "" , cNewEmpAvP)

			If Empty(cFilEnv)
				cFilEnv:= cFilAnt
			EndIf

			//----------------
			//| Evento S-2299
			//| Inicio da geracao do evento de desligamento
			//----------------------------------------------
			If !Empty(cFilEnv)

				//------------------------
				//| Verificacao de Filial
				//| Verificar o compartilhamento das tabelas CTT/RJ5 e SRV
				//--------------------------------------------------------------
				lNovoCTT:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
				lRJs 	:= lNovoCTT .And. !lParcial

				If lRJs
					If Empty(xFilial("RJ5")) //RJ5 compartilhada
						lSemFilCTT := .T.
					EndIf
				Else
					If Empty(xFilial("CTT")) //CTT compartilhada
						lSemFilCTT := .T.
					EndIf
				Endif

				If !lMiddleware
					cTafKey := "S2299" + oModelSRG:GetValue("RG_PERIODO") + SRA->RA_CIC + SRA->RA_CODUNIC
				Else
					fVersEsoc( "S2299", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw, ,@cGpeAmbe  )
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					lS1000 := fVld1000( AnoMes(M->RG_DATADEM), @cStatus )
					If !lS1000 .And. cEFDAviso != "2"
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX n„o localizado na base de dados"
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130)), OemToAnsi(STR0001))//"AtenÁ„o""Registro do evento X-XXXX n„o localizado na base de dados"
								EndIf
							Case cStatus == "1" // nao enviado para o governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX n„o transmitido para o governo"
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131)), OemToAnsi(STR0001))//"AtenÁ„o""Registro do evento X-XXXX n„o transmitido para o governo"
								EndIf
							Case cStatus == "2" // enviado e aguardando retorno do governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132)), OemToAnsi(STR0001))//"AtenÁ„o""Registro do evento X-XXXX aguardando retorno do governo"
								EndIf
							Case cStatus == "3" // enviado e retornado com erro
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133)), OemToAnsi(STR0001))//"AtenÁ„o""Registro do evento X-XXXX retornado com erro do governo"
								EndIf
						EndCase
						If cEFDAviso == "1"
							lGravou := .F.
							DisarmTransaction()
							Break
						EndIf
					EndIf
				EndIf

				//-----------------------------
				//| Varrendo o grid das verbas
				//| Looping para centralizar dentro do aCols as rubricas iguais
				//--------------------------------------------------------------
				For nI := 1 To oGrid:Length()
					If !oGrid:isDeleted(nI)
						oGrid:GoLine(nI)
					Else
						Loop
					EndIf

					lAltPd := .F.
					cPdBkp := ""

					//Manipula oGrid para considerar a verba de substituiÁ„o
					If lVbFerSub .And. !Empty(oGrid:GetValue("RR_FERSUB")) .And. oGrid:GetValue("RR_TIPO2") $ "R|I"
						cPdBkp	:= oGrid:GetValue("RR_PD")
						lAltPd	:= .T.

						oGrid:LoadValue("RR_PD", oGrid:GetValue("RR_FERSUB"))
					EndIf

					lAltCC 	:= .F.

					// CASO O PARAMETRO MV_RATESOC ESTEJA COMO .F., VAI CONSIDERAR O CENTRO DO CUSTO DO FUNCIONARIO PARA TOTALIZA«√O
					// DAS VERBAS DESCONSIDERANDO OS DEMAIS CENTROS DE CUSTOS.
					If !lGeraRat .And. (cCCAnt <> oGrid:GetValue("RR_CC") .Or. (Empty(cPdAnt) .Or. cPdAnt <> oGrid:GetValue("RR_PD")))
						cPdAnt	:= oGrid:GetValue("RR_PD")
						cCCAnt	:= oGrid:GetValue("RR_CC")
						lAltCC 	:= .T.
						oGrid:SetValue("RR_CC", SRA->RA_CC)
					EndIf

					//--------------------------------
					//| Montagem da chave de pesquisa
					//| Realiza a montagem da chave de auxilio para localizar registro
					//-----------------------------------------------------------------
					cChaveCCPD	:= oGrid:GetValue("RR_CC") + oGrid:GetValue("RR_PD")
					cChaveCC	:= oGrid:GetValue("RR_CC")

					nPosCCPD	:= Ascan( @aCols,{|X| X[1] == cChaveCCPD })
					nPosCC		:= Ascan( @aCols,{|X| X[12] == cChaveCC })

					aAreaCTT := GetArea()
					aAreaRJ5 := GetArea()
					aAreaRJ3 := GetArea()
					lTemReg := .F.

					//----------------------------------
					//| Centro de Custo x Verba/Rubrica
					//| Realiza o filtro para saber se a verba incide IRRF
					//| Seleciona a Verba dentro do SRA e pega seus respectivos dados
					//| Seleciona o CC    dentro da CTT e pega seus respectivos dados
					//----------------------------------------------------------------
					If ( ( (cVersaoEnv < "2.6.00" ) .And. !(SubStr(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
						 ( (cVersaoEnv >= "9.0.00") .And. (!RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_NATUREZ" ) $ "1801|9220" ))) .And.;
						!(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126|0303")
						//--------------------
						//| Verbas / Rubricas
						//| Guarda a area atual, entra na SRV e recupera os dados da verba
						//------------------------------------------------------------------
						aAreaSRV := GetArea()
						DBSelectArea("SRV")
						SRV->(DbSetOrder(1))
						If( SRV->( dbSeek( xFilial("SRV") + oGrid:GetValue("RR_PD")  ) ) )

							//Tratamento de compartilhamento da tabela SRV
							If !Empty(SRV->RV_FILIAL)
								lGeraCod := .T.
							Else
								lSemFilSRV := .T.
							EndIf

							//------------------
							//| LÛgica lGeraCod
							//| .T. -> Exclusiva | .F. -> Compartilhada
							//------------------------------------------
							If lGeraCod
								cIdeRubr := Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"),SRV->RV_FILIAL) )
							Else
								If cVersaoEnv >= "2.3"
									cIdeRubr := cEmpAnt
								Else
									cIdeRubr := ""
								EndIf
							Endif

							If lMiddleware
								If lPrimIdT
									lPrimIdT  := .F.
									cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
									If Empty(cIdTabRub)
										aAdd(aErros, OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141) )
										If !lRel	//"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "##" n„o est· cadastrado."
											If !IsInCallStack("fEnvLote")
												Help(,,OemToAnsi(STR0001),, OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141),1,0) //"AtenÁ„o"
											EndIf
											lGravou := .F.
											DisarmTransaction()
											Break
										EndIf
									EndIf
								EndIf
								cIdeRubr := cIdTabRub
							EndIf

							cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
							If (SRV->RV_PERC - 100) < 0
								cPrcRubr :=	0	//Percent da Rubrica
							Else
								cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
							EndIf
							//----------------------------------------
							//| Recuperar a natureza da verba
							//| Se estiverem vazias, v„o para a geraÁ„o do log
							//-------------------------------------------------
							If Empty( SRV->RV_NATUREZ )
								If( Len(aErrosVb) == 0 )
									aAdd(aErrosVb, OemToAnsi( STR0054 ))
									aAdd(aErrosVb, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC )+ " " )
								Else
									aAdd(aErrosVb, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC )+ " " )
								EndIf
							ElseIf ((cVersaoEnv < '2.6.00' .And. SRV->RV_NATUREZ == "9219") .Or. cVersaoEnv >= '2.6.00') .And. !lCarrDep
								//-----------------
								//| Plano de Saude
								//| Se a verba corrente tiver natureza de rubrica '9219' de plano de saude
								//| Entra na tabela RHR - Plano de Saude, localiza o registro do funcion·rio
								//| Verifica se o registro foi integrado com a folha, se sim: alimenta array
								//---------------------------------------------------------------------------
								//se o c·lculo do plano de sa˙de estiver fechado, ler RHS, sen„o RHR
								aAreaRCH := GetArea()
								DbSelectArea("RCH")
								RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )
								cProces  := oGrid:GetValue("RR_PROCES")
								cPeriodo := oModelSRG:GetValue("RG_PERIODO")
								cNumPag  := oModelSRG:GetValue("RG_SEMANA")
								RCH->( dbSeek( xFilial("RCH") + cProces + cTipoPLA + cPeriodo + cNumPag ) )
								If Empty(RCH->RCH_DTFECH)
									cTabRH := "RHR"
								Else
									cTabRH := "RHS"
								EndIf
								RestArea(aAreaRCH)
								GetRAssMed( xFilial("SRG"), oModelSRG:GetValue("RG_MAT"), "S016", cVersaoEnv, cPeriodo, @aDadosTRHR, @aDadosDRHR, cTabRH, @lCPFDepOk, @aDepAgreg )
								lCarrDep := .T.
								cVbPla 	 += SRV->RV_COD + "/"
							EndIf

						EndIf
						RestArea(aAreaSRV)

						If cVersaoEnv >= "9.3"
							cCodINCIRF := RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" )
							cCodNat    := RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_NATUREZ" )
							cCodCCP15  := RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCCP" )
							cFilIRF    := oGrid:GetValue("RR_FILIAL")
							cMatIRF    := oGrid:GetValue("RR_MAT")
							nValorIRF  := oGrid:GetValue("RR_VALOR")
							cPdIRF     := oGrid:GetValue("RR_PD")
							cDescCod   := RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_DESC" )
							dDtPgt 	   := oModelSRG:GetValue("RG_DATAHOM")

							//pens„o alimenticia
							If (VAL(cCodINCIRF ) >=  51 .AND. VAL(cCodINCIRF ) <= 55)
								fBenefic( cFilIRF, cMatIRF, dDtPgt, cPdIRF, nValorIRF, ,oModelSRG:GetValue("RG_PERIODO"), cCodINCIRF , .F.)
								If Len(aRetPensao)== 0
									cMsgPen := OemToAnsi(STR0412 ) + CRLF  //"Verba com incidÍncia de IR relacionada a Pens„o AlimentÌcia, mas n„o h· dados no Cadastro de Beneficiarios"
									If( Len(aErrosComp) == 0 )
										aAdd(aErrosComp, OemToAnsi( STR0415 ))
										aAdd(aErrosComp, cMsgPen )
									Else
										If aScan(aErrosComp,{|x| x == cMsgPen }) == 0
											aAdd(aErrosComp, cMsgPen )
										Endif
									EndIf
								Endif
							Endif
							//previdencia complementar
							If (Val(cCodINCIRF) >= 46 .And. Val(cCodINCIRF) <= 48) .Or. (Val(cCodINCIRF) >= 61 .And. Val(cCodINCIRF) <= 66) .Or. (Val(cCodINCIRF) >= 9046 .And. Val(cCodINCIRF) <= 9048) .Or. (Val(cCodINCIRF) >= 9061 .And. Val(cCodINCIRF) <= 9066)
								fGetPrev( cPdIRF, oModelSRG:GetValue("RG_PERIODO"), cCodINCIRF, nValorIRF, .F. )
								If Len(aInfoPrev) == 0
									cMsgPen := OemToAnsi(STR0413) + CRLF //"Verba com incidÍncia de IR relacionada a PrevidÍncia Complementar, mas n„o h· dados no Cadastro de PrevidÍncia Complementar"
									If( Len(aErrosComp) == 0 )
										aAdd(aErrosComp, OemToAnsi( STR0415 ))
										aAdd(aErrosComp, cMsgPen )
									Else
										If aScan(aErrosComp,{|x| x == cMsgPen }) == 0
											aAdd(aErrosComp, cMsgPen )
										Endif
									EndIf
								Endif
							Endif
							//plano de saude
							If  cCodNat == "9219" .And. Val(cCodINCIRF) == 67 .And. Empty(aDadosRHS)
								cDtPesqI  := oModelSRG:GetValue("RG_PERIODO")+"01"
								cDtPesqF  := oModelSRG:GetValue("RG_PERIODO")+"31"
								adadosRHS := fGetPLS1210( cFilIRF, cMatIRF , "1", cDtPesqI, cDtPesqF, oModelSRG:GetValue("RG_PERIODO") )
								If Len(aDadosRHS) == 0
									cMsgPen := OemToAnsi(STR0414) + CRLF //"Verba com incidÍncia de IR relacionada a Plano de Sa˙de, mas n„o h· dados no Cadastro de Plano de Sa˙de Ativo"
									If( Len(aErrosComp) == 0 )
										aAdd(aErrosComp, OemToAnsi( STR0415 ))
										aAdd(aErrosComp, cMsgPen )
									Else
										If aScan(aErrosComp,{|x| x == cMsgPen }) == 0
											aAdd(aErrosComp, cMsgPen)
										Endif
									EndIf
								Endif
							Endif
							If  !Empty(cCodNat) .And. cCodCCP15  $ '15|16'
								lRetIncc := fValNatINCC(cCodNat)
								If !lRetIncc
									cMsg15 := OemToAnsi(STR0436) + CRLF //"Somente podem ser aceitas rubricas com cÛdigo de incidÍncia para a PrevidÍncia Social 15 ou 16, desde que as naturezas de rubrica sejam compatÌveis,"
									cMsg15 += OemToAnsi(STR0437) + CRLF //"conforme o campo 'IncidÍncia INSS 15/16' da tabela S047-Natureza de Rubricas"
									If( Len(aErrosINCCP) == 0 )
										aAdd(aErrosINCCP, cMsg15)
										aAdd(aErrosINCCP, cPdIRF + " - " + AllTrim( cDescCod )+ " " )
									Else
										aAdd(aErrosINCCP, cPdIRF + " - " + AllTrim( cDescCod )+ " " )
									EndIf
								Endif
							Endif
						Endif

						if lRJs // usa controle na RJ5
						//------------------------------------------------
							//| LotaÁ„o
							//| Guarda a area atual, entra na RJ5 e recupera os dados do cc
							//---------------------------------------------------------------

							aAreaCTT := GetArea()
							aAreaRJ5 := GetArea()
							aAreaRJ3 := GetArea()

							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT") + oGrid:GetValue("RR_CC") ) ) )
								DBSelectArea("RJ5")
								RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
								If( RJ5->( dbSeek( xFilial("RJ5") + oGrid:GetValue("RR_CC") ) ) )
									//Se o campo RJ5_FILT existe pesquisa por este registro preenchido
									If lRJ5FilT
										RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
										RJ5->(dbGoTop())
										If RJ5->( dbSeek( xFilial("RJ5",oGrid:GetValue("RR_FILIAL")) + oGrid:GetValue("RR_CC") + oGrid:GetValue("RR_FILIAL")) )
											While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", oGrid:GetValue("RR_FILIAL")) .And. RJ5->RJ5_CC == oGrid:GetValue("RR_CC") .And.;
												IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == oGrid:GetValue("RR_FILIAL"), .T.)
												If cPeriodo >= RJ5->RJ5_INI
													cCCRJ5    := RJ5->RJ5_COD
													nRecnoRJ5 := RJ5->(RecNo())
												EndIf
												RJ5->( dbSkip() )
											EndDo
											If !Empty(cCCRJ5)
												RJ5->(dbGoTo(nRecnoRJ5)) // Reposiciona no registro correto da RJ5
											EndIf	
										EndIf
										If Empty(cCCRJ5)
											cCCRJ5 := fBsCCRJ5(xFilial("RJ5"), oGrid:GetValue("RR_CC"), IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == oGrid:GetValue("RR_FILIAL"), .T.), cPeriodo, @nRecnoRJ5)
											//Posiciona novamente no registro da RJ5
											IF !Empty(cCCRJ5) .And. nRecnoRJ5 > 0
												RJ5->(dbGoTo(nRecnoRJ5))
											EndIf  
										Endif
									EndIf
									If EMPTY(RJ5->RJ5_TPIO) .AND. EMPTY(RJ5->RJ5_NIO) // LOTACAO
										DBSelectArea("RJ3")
										RJ3->(DbSetOrder(2)) //RJ3_FILIAL+RJ3_COD+RJ3_INI+RJ3_TPLOT
										If( RJ3->( dbSeek( xFilial("RJ3") + cCCRJ5 ) ) )
											cCodLot  := IIf(lSemFilCTT, RJ3->RJ3_COD, RJ3->RJ3_FILIAL + RJ3->RJ3_COD )
											cTpInscr := ""
											cInscr 	 := ""
										ENDIF
									elseif !EMPTY(RJ5->RJ5_TPIO) .AND. !EMPTY(RJ5->RJ5_NIO) // OBRA PROPRIA
										cCodLot := IIf(lSemFilCTT, RJ5->RJ5_COD, RJ5->RJ5_FILIAL + RJ5->RJ5_COD )
										If RJ5->RJ5_TPIO == "4"
											cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
											cInscr 		:= RJ5->RJ5_NIO // Codigo da inscricao
											cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
										Endif
									ENDIF
								else
									aAdd(aErros, OemToAnsi(STR0116) + alltrim(oGrid:GetValue("RR_CC")) + OemToAnsi(STR0117) + alltrim(SRA->RA_MAT) + OemToAnsi(STR0118) )
									If !lRel	//"CC ## nao cadastrado na tabela RJ5"
										If !IsInCallStack("fEnvLote")
											Help(,,OemToAnsi(STR0001),, OemToAnsi(STR0116) + alltrim(oGrid:GetValue("RR_CC")) + OemToAnsi(STR0117) + alltrim(SRA->RA_MAT) + OemToAnsi(STR0118),1,0) //"AtenÁ„o"
										EndIf
										lGravou := .F.
										DisarmTransaction()
										Break
									Endif
								Endif

								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr	 	:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If nPosCC == 0 .And. If(Len(aDadosCCT) > 0, Ascan( aDadosCCT,{|X| X[4] == cCodLot }) == 0 , .T. )
									aAdd(aDadosCCT, { RJ5->RJ5_CC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaRJ5)
								RestArea(aAreaCTT)
								RestArea(aAreaRJ3)
							EndIf
						else // usa o controle na CTT

							//------------------------------------------------
							//| Centro de Custo
							//| Guarda a area atual, entra na CTT e recupera os dados do cc
							//---------------------------------------------------------------
							aAreaCTT := GetArea()
							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT") + oGrid:GetValue("RR_CC") ) ) )
								cCodLot := IIf(lSemFilCTT, CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
								cTpLot  := CTT->CTT_TPLOT	// Tipo de LotaÁ„o (?!?)
								//Verifica se eh uma obra por meio do campo CTT_TIPO2
								If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
									cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
									cInscr 		:= CTT->CTT_CEI2 // Codigo da inscricao
									cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
								Endif

								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr		:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If(nPosCC == 0)
									aAdd(aDadosCCT, {CTT->CTT_CUSTO, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaCTT)
							EndIf
						Endif

						//------------------------------------------------
						//| Array de Dados
						//| Montagem do array com os dados a utilizar para o XML
						//-------------------------------------------------------
						If( nPosCCPD > 0 )
							aCols[nPosCCPD, 15] += oGrid:GetValue("RR_HORAS")	//Incrementa Horas
							aCols[nPosCCPD, 17] += oGrid:GetValue("RR_VALOR")	//Incrementa Valor
							aCols[nPosCCPD, 18] := aCols[nPosCCPD, 18] + 1	  	//Incrementa Contador
						Else
							aAdd(aCols, { 	oGrid:GetValue("RR_CC")+ oGrid:GetValue("RR_PD"),;	    //01 - Chave para pesquisa (CC+PD)
												"Dados da Verba",;									//02 - Separador - Verbas/Rubricas
												cCodRubr,;											//03 - Codigo da Rubrica
												cIdeRubr,;											//04 - Ident   da Rubrica
												cPrcRubr,;											//05 - Percent da Rubrica
												"Dados do CC",;										//06 - Separador - Centro de Custo
												cCodLot,;											//07 - Codigo da LotaÁ„o
												cTpInscr,;											//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
												cInscr,;											//09 - Codigo da inscricao
												cTpLot,;											//10 - Tipo de LotaÁ„o (?!?)
												"Dados da Grid",;									//11 - Separador - Centro de Custo
												oGrid:GetValue("RR_CC"),;							//12 - Centro de Custo
												oGrid:GetValue("RR_PD"),;							//13 - Verba da rescis„o
												oGrid:GetValue("RR_DESCPD"),;						//14 - Descricao da verba
												oGrid:GetValue("RR_HORAS"),;						//15 - Horas da verba
												oGrid:GetValue("RR_VALOR"),;						//16 - Valor da verba
												oGrid:GetValue("RR_VALOR"),;						//17 - Acumulado da verba (valor inicial para soma)
												1,; 												//18 - Numero de registro repetidos (CC + PD)
												SRV->RV_NATUREZ,;									//19 - Natureza da verba
												SRV->RV_INCCP,;										//20 - IncidÍncia CP da verba
												SRV->RV_INCFGTS,;									//21 - IncidÍncia FGTS da verba
												SRV->RV_INCIRF,;									//22 - IncidÍncia IRRF da verba
												SRV->RV_TIPOCOD,;									//23 - Tipo da verba
												If(lRVIncop, SRV->RV_INCOP,""),;					//24 - Incid RPPS
												If(lRVTetop, SRV->RV_TETOP,"") })					//25 - Teto Remun
						
						EndIf
					EndIf

					//----------------------
					//| Liquido da Rescis„o
					//| Se a verba corrente tiver o ID de Calculo igual
					//| a 0126 O Sistema receber· o valor lÌquido da rescis„o
					//--------------------------------------------------------
					If RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126"
						nValor := oGrid:GetValue("RR_VALOR")
					EndIf

					//---------------------
					//| Pens„o Alimenticia
					//| Se a verba corrente tiver valor de DIRF igual aos informados
					//| Realizar· a soma do montante pago de pens„o Alimenticia
					//-----------------------------------------------------------
					If ( ( cVersaoEnv < "2.6.00" .And. SubStr(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "51|52|53|54|55" ) .Or.;
						( cVersaoEnv >= "2.6.00" .And. RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ) $ "51  |52  |53  |54  |55  " ) )
						nPensao += oGrid:GetValue("RR_VALOR")
					EndIf

					//------------------------------
					//| Verba de Multiplos Vinculos
					//| Se a verba corrente, tiver seu ID de Calculo igual a 0318
					//| realizar· a procura dos multiplos vÌnculos do funcion·rio
					//------------------------------------------------------------
					If RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0318"
						aAreaRAZ := GetArea()
						DBSelectArea("RAZ")
						RAZ->(DbSetOrder(1))
						If( RAZ->( dbSeek( xFilial("RAZ") + oGrid:GetValue("RR_MAT") ) ) )
							aDadosRAZ := GetMulVin(oGrid:GetValue("RR_FILIAL") , oGrid:GetValue("RR_MAT"), oModelSRG:GetValue("RG_PERIODO") , .T.)
						EndIf
						RestArea(aAreaRJ5)
						RestArea(aAreaCTT)
						RestArea(aAreaRJ3)
					EndIf

					//Restaura a verba no grid
					If lAltPd
						oGrid:LoadValue("RR_PD", cPdBkp)
					EndIf

					//Restaura o centro de custo no grid
					If lAltCC
						oGrid:SetValue("RR_CC", cCCAnt)
					EndIf

					//Identifica nos valores da rescis„o se houve c·lculo com a deduÁ„o simplificada
					If oGrid:GetValue("RR_TRIBIR") == "2" .And. RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, 'RV_CODFOL' ) $ "0010|0015|0016|0027|0100"
						lDedSimpl := .T.
					EndIf
				Next nI

				//Tratando o Log
				cMsg:= ""
				If( Len(aErrosComp) > 1 ) //Maior que 1 pois sempre vai existir o cabeÁalho do log de erros
					For nx:=1 to Len(aErrosComp)
						cMsg+= aErrosComp[Nx]
					Next
					aAdd(aErros, cMsg)
					//Interrompe apenas se n„o for a geraÁ„o do relatÛrio
					If !lRel
						If !IsInCallStack("fEnvLote")
							Help( ,, OemToAnsi(STR0001) ,, cMsg, 1, 0, , , , , , {OemToAnsi(STR0416)})
						EndIf
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf
				EndIf
				cMsg:= ""
				If( Len(aErrosVb) > 1 ) //Maior que 1 pois sempre vai existir o cabeÁalho do log de erros
					aAdd(aErrosVb, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0056 ) ) //"est„o sem cÛdigo de rubrica cadastrada (RV_NATUREZ)." "N„o ser· possÌvel integraÁ„o com o TAF e a efetivaÁ„o da rescis„o."
					For nx:=1 to Len(aErrosVb)
						cMsg+= aErrosVb[Nx]
					Next
					aAdd(aErros, cMsg)
					//Interrompe apenas se n„o for a geraÁ„o do relatÛrio
					If !lRel
						If !IsInCallStack("fEnvLote")
							Help( ,, OemToAnsi(STR0001) ,, cMsg, 1, 0 )//"AtenÁ„o"
						EndIf
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf
				EndIf

				//Tratando o Log
				cMsg:= ""
				If( Len(aErrosINCCP) > 1 ) //Maior que 1 pois sempre vai existir o cabeÁalho do log de erros
					For nx:=1 to Len(aErrosINCCP)
						cMsg+= aErrosINCCP[nx] + CRLF
					Next
					aAdd(aErros, cMsg)
					//Interrompe apenas se n„o for a geraÁ„o do relatÛrio
					If !lRel
						If !IsInCallStack("fEnvLote")
							Help( ,, OemToAnsi(STR0001) ,, cMsg, 1, 0, , , , , , {OemToAnsi(STR0416)})   //"Preencha os cadastros e tente novamente "
						EndIf
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf
				EndIf

				If !Empty(SRA->RA_CC) .AND. Len(aCC) > 0
					nPosLot := aScan(aCC, {|x| x[1] == FWxFilial("CTT") .AND. x[2] == SRA->RA_CC} )
					If nPosLot > 0
						cTpInscr := aCC[nPosLot,3]
						cInscr := aCC[nPosLot,4]
					EndIf
				EndIf

				If Empty(cTpInscr) .OR. Empty(cInscr)
					nPosEstb := eVal(bEstab)
					If nPosEstb > 0
						cTpInscr := aEstb[nPosEstb,3]
						cInscr := aEstb[nPosEstb,2]
					EndIf
				EndIf

				If !lMiddleware
					fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				EndIf

				If Empty(cFilEnv)
					cFilEnv:= cFilAnt
				EndIf

				fBusCadBenef(@aCodBenef,"FOL")
				For nI := 1 to len(aCodBenef)
					If Valtype( aCodBenef[nI,27]) == "N"
						nPerPens += aCodBenef[nI,27] //Percentual FGTS
					EndIf
				Next nI

				nI := 0

				//Carrega Dados da Tabela S037, passando a data da Demiss„o como par‚metro.
				fCarrTab( @aTabS037, "S037", dDataRes, .T. , , , SRA->RA_FILIAL)
				nCntS037 := aScan( aTabS037, {|x| x[2] == cFilAnt .And. x[3] == AnoMes(M->RG_DATADEM) } )
				If nCntS037 == 0
					nCntS037 := aScan( aTabS037, {|x| x[2] == cFilAnt .And. Empty(Alltrim(x[3])) } )
					If nCntS037 == 0
						nCntS037 := aScan( aTabS037, {|x| Empty(Alltrim(x[2])) .And. x[3] == AnoMes(M->RG_DATADEM) } )
						If nCntS037 == 0
							nCntS037 := aScan( aTabS037, {|x| Empty(Alltrim(x[2])) .And. Empty(Alltrim(x[3])) } )
						EndIf
					EndIf
				EndIf
				If nCntS037 > 0
					cSimples := aTabS037[nCntS037,11] // Simples Nacional
					If cSimples == "1"
						cIndSimp := aTabS037[nCntS037,18] // Indicador do Tipo de Simples Nacional.
					EndIf
				EndIf

				If AllTrim(aIncRes[02]) $ "I/A" .Or. (aIncRes[02] == "T" .And. oModelSRG:GetValue("RG_DAVIND") > 0)
					dDtProj := oModelSRG:GetValue("RG_DTPROAV")
				EndIf

				If lMiddleware
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStat2299 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt, Nil, Nil, .T. )

					//Retorno pendente impede o cadastro
					If cStat2299 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
					EndIf
					//Inclus„o
					If nOperation != 5
						//Evento de exclus„o sem transmiss„o impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
						ElseIf cStat2299 == "99"
							cMsgRJE 	:= STR0146//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o pendente para transmiss„o"
						//N„o existe na fila, ser· tratado como inclus„o
						ElseIf cStat2299 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento sem transmiss„o, ir· sobrescrever o registro na fila
						ElseIf cStat2299 $ "1/3"
							cOperNew 	:= cOper2299
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclus„o transmitido, ser· tratado como inclus„o
						ElseIf cOper2299 == "E" .And. cStat2299 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					//Exclus„o
					Else
						//Evento de exclus„o sem transmiss„o impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
						//Evento diferente de exclus„o transmitido ir· gerar uma exclus„o
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
					If !Empty(cMsgRJE)
						aAdd(aErros, cMsgRJE)
						If !lRel
							If !IsInCallStack("fEnvLote")
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" n„o enviado(a) ao Middleware. Erro: "
							EndIf
							lGravou := .F.
							DisarmTransaction()
							Break
						EndIf
					EndIf
					If cRetfNew == "2"
						If cStat2299 == "4"
							cRecibXML 	:= cRecib2299
							cRecibAnt	:= cRecib2299
							cRecib2299	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2299", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2299, cRecibAnt } )
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtDeslig/v" + cVersMw + "'>"
					cXML += 	"<evtDeslig Id='" + cId + "'>"
					fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cGpeAmbe, 1, "12" }, IIf(Len(aInfos) == 5 .And. aInfos[5] $ "21*22",cVersaoEnv,Nil) )
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Else
					//-------------------
					//| Inicio do XML
					//-------------------
					cXml := "<eSocial>"
					cXml += "	<evtDeslig>"
				EndIf

				//Consulta se existe a geraÁ„o do evento S-2299 para confirmar se gera o prefixo do ideDmDev
				If cStat2299 == "-1" .And. Empty(cPrefixo)
					lGeraPre := .T.
				EndIf

				//Pesquisa pelo prefixo na tabela RU8
				If lNewDmDev
					cPrefixo := fGetPrefixo(SRA->RA_FILIAL, SRA->RA_MAT, M->RG_PERIODO, SRA->RA_CIC, lGeraPre)
				EndIf

				//Dados do Trabalhador
				cXml += "		<ideVinculo>"
				cXml += "			<cpfTrab>" + AllTrim(SRA->RA_CIC) + "</cpfTrab>"
				If cVersaoEnv < "9.0.00"
					cXml += "			<nisTrab>" + AllTrim(SRA->RA_PIS) + "</nisTrab>"
				Endif

				If !Empty(SRA->RA_CODUNIC)
					cMatricula := If(!lMiddleware, StrTran(SRA->RA_CODUNIC, "&","&#38;" ),SRA->RA_CODUNIC )
				EndIf

				cXml += "			<matricula>" + AllTrim(cMatricula) + "</matricula>"
				cXml += "		</ideVinculo>"

				//Dados do Desligamento
				cXml += "		<infoDeslig>"
				cXml += "			<mtvDeslig>" + cCodDslg + "</mtvDeslig>"
				If !lMiddleware
					cXml += "			<dtDeslig>" + Dtos(M->RG_DATADEM) + "</dtDeslig>"
				Else
					cXml += "			<dtDeslig>" + SubStr( dToS(M->RG_DATADEM), 1, 4 ) + "-" + SubStr( dToS(M->RG_DATADEM), 5, 2 ) + "-" + SubStr( dToS(M->RG_DATADEM), 7, 2 ) + "</dtDeslig>"
				EndIf

				If cVersaoEnv >= "9.0.00"
					If !lMiddleware
						cXml += "			<dtAvPrv>" + Dtos(M->RG_DTAVISO) + "</dtAvPrv>"
					Else
						cXml += "			<dtAvPrv>" + SubStr( dToS(M->RG_DTAVISO), 1, 4 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 5, 2 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 7, 2 ) + "</dtAvPrv>"
					Endif
				Endif

				cXml += "			<indPagtoAPI>" + IIf(AllTrim(aIncRes[02]) $ "I/A" .Or. (aIncRes[02] == "T" .And. oModelSRG:GetValue("RG_DAVIND") > 0),"S","N") + "</indPagtoAPI>"
				If !Empty(dDtProj) .And. (AllTrim(aIncRes[02]) $ "I/A" .Or. aIncRes[02] == "T" .And. oModelSRG:GetValue("RG_DAVIND") > 0)
					If !lMiddleware
						cXml +=			'<dtProjFimAPI>' + Dtos(dDtProj) + '</dtProjFimAPI>'
					Else
						cXml +=			'<dtProjFimAPI>' + SubStr( dToS(dDtProj), 1, 4 ) + "-" + SubStr( dToS(dDtProj), 5, 2 ) + "-" + SubStr( dToS(dDtProj), 7, 2 ) + '</dtProjFimAPI>'
					EndIf
				EndIf
				If cVersaoEnv < "9.0.00" .Or. (cVersaoEnv >= "9.0.00" .And. nTpRegTrab == 0 )					//Pensao Alimenticia
					if nPerPens > 0
						cXml +=				'<pensAlim>1</pensAlim>'
					else
						cXml +=				'<pensAlim>0</pensAlim>'
					Endif
				Endif
				//Percentual Alimenticio
				if nPerPens <> 0
					cXml +=				'<percAliment>' + Alltrim(Str(nPerPens)) + '</percAliment>'
				endif

				If cVersaoEnv < "9.0.00"
					//Numero Certidao Obito
					If Iif(cVersaoEnv >= '2.5.00', cCodDslg $ "10", cCodDslg $ "09*10") .And. !Empty(AllTrim(M->RG_OBITO))
						cXml +=			'<nrCertObito>' + AllTrim(M->RG_OBITO) + '</nrCertObito>'
					EndIf
				Endif


				//Numero Processo Trabalhista
				If !Empty(AllTrim(M->RG_NPROC))
					cXml +=			'<nrProcTrab>' + AllTrim(M->RG_NPROC) + '</nrProcTrab>'
				EndIf
				//Indicativo ades„o a Programa de Demiss„o Volunt·ria
				If cVersaoEnv >= "9.2" .And. lCpoPDV .And. oModelSRG:GetValue("RG_PDV")
					cXml +=			'<indPDV>S</indPDV>'
				EndIf

				If cVersaoEnv < "9.0.00"
					//Detalhes Indicador Cumprimento Aviso Previo Parcial
					If cVersaoEnv >= '2.3'
						If !lNT15 .Or. !Empty(M->RG_INDAV)
							cXml += "		<indCumprParc>" + AllTrim(M->RG_INDAV) + "</indCumprParc>"
						EndIf
					Else
						cXml += "			<indCumprParc>" + If(Alltrim(cComprovou) == "Sim","1","0") + "</indCumprParc>"
					EndIf

					If lIntermit
						cXml += "			<qtdDiasInterm>" + cDiaSV7 + "</qtdDiasInterm>"
					EndIF
				Endif
				If cVersaoEnv >= "9.0.00" .And. lIntermit
					If Len(aDiasConv) > 0
						For nC := 1 to Len(aDiasConv)
							cXml +=         '<infoInterm>'
							cXml +=         '<dia>' + AllTrim(aDiasConv[nC]) + '</dia>'
							cXml +=         '</infoInterm>'
						Next nC
					Endif
				Endif

				If !Empty(AllTrim(M->RG_OBS))
					If cVersaoEnv >= "2.4.02"
						cXml +=         '<observacoes>'
							cXml +=         '<observacao>' + AllTrim(M->RG_OBS) + '</observacao>'
						cXml +=          '</observacoes>'
					Else
					cXml +=         '<observacao>' + AllTrim(M->RG_OBS) + '</observacao>'
					EndIf
				EndIf

				//Sucessao Vinculos
				If !Empty(AllTrim(M->RG_SUCES))
					cXml +=			'<sucessaoVinc>'
					If cVersaoEnv >= "9.0.00"
						cXml +=				'<nrInsc>' + AllTrim(M->RG_SUCES) +'</nrInsc>'
						IF SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInsc>' + AllTrim(M->RG_TPSU) +'</tpInsc>'
						ENDIF
					Else
						cXml +=				'<cnpjSucessora>' + AllTrim(M->RG_SUCES) +'</cnpjSucessora>'
						IF cVersaoEnv >= "2.5.00" .AND. SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInscSuc>' + AllTrim(M->RG_TPSU) +'</tpInscSuc>'
						ENDIF
					Endif
					cXml +=			'</sucessaoVinc>'
				Endif

				//SÛ gera as verbas caso o MV_FASESOC esteja igual a 2 (ManutenÁ„o, N„o PeriÛdicos e PeriÛdicos)
				//ou em casos de funcion·rio de contrato intermitente, se h· pagamento ou convocaÁ„o no perÌodo de c·lculo da rescis„o
				//N„o gera para servidor publico e Leiaute 1.0
				If lXmlVerbas .And. (!lIntermit .Or. (lIntermit .And. (lCMesAtual .Or. len(aCols) > 0 .And. !Empty(aCols[1,13])))) .And.;
					(cVersaoEnv < "9.0" .Or. nTpRegTrab == 0 ) .And.;
					!(cVersaoEnv >= "9.1.00" .And. cCodDslg == "44")
					If lMiddleware
						fExcRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2299" )
					EndIf

					//Verbas de Rescisao
					cXml += "			<verbasResc>"

					//ValidaÁ„o para verificar se gera o dmDev do Dissidio
					fDis2299( dDataRes, @cVBDiss, aDadosCCT, cIndSimp, @cInfoDiss, @cMsgDiss, @lRJ5Ok, @aErrosRJ5, cTpRes, , @cDtEfei, @cCompAc, @aRelVbDiss)
					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						aAdd(aErros, cMsgErro)
						If !lRel
							If !IsInCallStack("fEnvLote")
								Help( ,, OemToAnsi(STR0001) ,, cMsgErro, 1, 0 )//"AtenÁ„o"
							EndIf
							DisarmTransaction()
							lGravou := .F.
							Break
						EndIf
					EndIf
					If cVersaoEnv >= "9.1.00"
						lTemRRA := fBuscaRRA(cTpRes,cPdRRA)
					Endif

					//Busca a data de pagamento da rescis„o original
					If lResComp
						fGetDtHomol(SRG->RG_FILIAL, SRG->RG_MAT, @dDataHom)
					EndIf

					// Se for envio de rescis„o complementar e n„o calculada no mesmo dia da original, busca os valores pagos nas rescisıes anteriores
					If (lResComp .And. !(dDataHom == M->RG_DATAHOM)) .Or. lRetif
						fResCom(@cXml, oModel, aDadosCCT, cVBDiss, cIndSimp, lRetif, @aCols, lRJ5Ok, lRel)
					EndIf

					//Verifica se na rescisao complementar existem valores maiores que zero, se n„o existir n„o permite a gravaÁao
					If lResComp .And. !(dDataHom == M->RG_DATAHOM) .And. Len(aCols) > 0
					    lRetComp := .F.
						For nComp := 1 To Len( aDadosCCT )
							If (!lRJs .And. aScan(aCols, { |x| x[12] == aDadosCCT[nComp,1] .And. x[17] > 0 }) > 0) .Or.;
								(lRJs .And. aScan(aCols, { |x| x[7] == aDadosCCT[nComp,4] .And. x[17] > 0 }) > 0)
								lRetComp := .T.
							EndIf
						Next

						If !lRetComp
							cMsgErro += OemToAnsi(STR0389)	//"N„o ser· possÌvel efetuar a integraÁ„o da rescis„o complementar, quando existem apenas valores negativos."
							aAdd(aErros, cMsgErro )
							If !lRel
								If !IsInCallStack("fEnvLote")
									Help( ,, OemToAnsi(STR0001) ,, cMsgErro, 1, 0 ,,,,,,{ OemToAnsi(STR0390) })
								Endif
								DisarmTransaction()
								lGravou := .F.
								Break
							EndIf
						Endif
					Endif
					If cVersaoEnv >= '2.3'
						cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRG")) +  SRA->RA_MAT + If(lRetif, "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
					EndIf

					//Guarda a data de pagamento de cada DmDev
					If aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3]+x[4] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev+dtos(M->RG_DATAHOM) }) == 0
						aAdd(aDtPgtDmDev, { SRA->RA_FILIAL, SRA->RA_MAT, cIdDmDev, dtos(M->RG_DATAHOM) } )
					EndIf

					//Looping para varrer as verbas
					cXml += "				<dmDev>"
					If !lMiddleware
						cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
					Else
						cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
					Endif
					cXml += "					<infoPerApur>"

					If !Empty(cMsgDiss)
						aAdd(aErros, OemToAnsi( STR0100 ) + " " + OemToAnsi( STR0056 ) ) //"Preenchimento incorreto das tabelas S050/S126. As informaÁıes de dissÌdio n„o foram geradas."#"N„o ser· possÌvel integraÁ„o com o TAF e a efetivaÁ„o da rescis„o."
						If !lRel
							If !IsInCallStack("fEnvLote")
								Help(,,OemToAnsi(STR0001),,OemToAnsi(STR0100),1,0) //"AtenÁ„o"#"Preenchimento incorreto das tabelas S050/S126. As informaÁıes de dissÌdio n„o foram geradas."#
							EndIf
							DisarmTransaction()
							lGravou := .F.
							Break
						EndIf
					EndIf

					//Looping para detalhar os Centros de Custos que o Trab Atuou
					For nZ := 1 To Len( aDadosCCT )
						If lResComp
							If !((!lRJs .And. aScan(aCols, { |x| x[12] == aDadosCCT[nZ,1] .And. x[17] > 0 }) > 0) .Or.;
								(lRJs .And. aScan(aCols, { |x| x[7] == aDadosCCT[nZ,4] .And. x[17] > 0 }) > 0))
								Loop
							EndIf
						EndIf
						cXml += "						<ideEstabLot>"
						cXml += "							<tpInsc>" + aDadosCCT[nZ,2] + "</tpInsc>"
						cXml += "							<nrInsc>" + aDadosCCT[nZ,3] + "</nrInsc>"
						If !lMiddleware
							cXml += "							<codLotacao>" + StrTran( aDadosCCT[nZ,4], "&", "&amp;") + "</codLotacao>"
						Else
							cXml += "							<codLotacao>" + Alltrim(StrTran( aDadosCCT[nZ,4], "&", "&amp;")) + "</codLotacao>"
						Endif

						//Looping nas verbas vindas
						For nX := 1 To Len( aCols )

							// Se Rescis„o Complementar por DissÌdio for no mesmo mÍs
							// as verbas de diferenÁa s„o calculadas (Tipo 2 igual a R) com a diferenÁa entre as Rescisıes
							// Se ela existir, deve ser levada no Recibo da Complementar
							lDifINSSComp := .F.
							If (!Empty(cVBDiss) .And. aCols[nX,3] $ cVBDiss .And. aCols[nX,3] $ cDifDiss)
								nSvLinha	:= 	oGrid:GetLine()
								If oGrid:SeekLine({{"RR_PD", aCols[nX,3]},{"RR_TIPO2", "R"}}, .F., .F.)
									oGrid:GoLine(nSvLinha)
									lDifINSSComp := .T.
								EndIf
							EndIf

							//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
							If Empty(cVBDiss) .Or. lDifINSSComp .Or. (!( aCols[nX,3] $ cVBDiss ) .And. If(lTemRRA, !( aCols[nX,3] $ cVerbRRA),.T.) )  //Nao leva verbas do dissidio

								If (If(!lRJs, aCols[nX, 12] == aDadosCCT[nZ,1], aCols[nX, 7 ] == aDadosCCT[nZ, 4] ) .And. aCols[nX,17] > 0  )

									//Se n„o houver uso do modelo de deduÁ„o simplificada n„o gera a verba de incidÍncia IR 68
									If !lDedSimpl .And. AllTrim(RetValSrv( aCols[nX,3], SRA->RA_FILIAL, "RV_INCIRF" )) == "68"
										//Se for execuÁ„o do relatÛrio imprime aviso.
										If lRel
											//Verba ### do IdeDmDev ############### desprezada devido incidÍncia IR 68 e n„o haver o c·lculo com deduÁ„o simplificada.
											aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, OemToAnsi(STR0395) + aCols[nX,3] + OemToAnsi(STR0407) + cIdDmDev + OemToAnsi(STR0408)})
										EndIf
										Loop
									EndIf

									//Identifica se gravou verba de incidÍncia IR 68
									If AllTrim(RetValSrv( aCols[nX,3], SRA->RA_FILIAL, "RV_INCIRF" )) == "68"
										lGrvIR68 := .T.
									EndIf

									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aCols[nX,4] + "</ideTabRubr>"
									If !lMiddleware
										cXml += "							<qtdRubr>" + Str(aCols[nX,15]) + "</qtdRubr>"
									ElseIf lMiddleware .And. !Empty(aCols[nX,15])
										cXml += "							<qtdRubr>" + Alltrim(Str(round(aCols[nX,15],2))) + "</qtdRubr>"
									Endif
									If !lMiddleware
										cXml += "							<fatorRubr>" + AllTrim( Transform(aCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									ElseIf lMiddleware .And. !Empty(aCols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( StrTran(Transform(aCols[nX,5],"@E 999999999.99"), ",", "." )) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(aCols[nX,16]) ) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(aCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(aCols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + If(lDifINSSComp,AllTrim( Transform(aCols[nX,16],"@E 999999999.99") ) ,AllTrim( Transform(aCols[nX,17],"@E 999999999.99") )) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif

									//InformaÁıes de desconto do emprÈstimo em folha
									If cVersaoEnv >= "9.3.00"  .And. aCols[nX,19] == "9253" .And. aCols[nX,21] == "31"     //Natureza .And. RV_INCFGTS
										lEmpECon := .T.
										aEConsig := fBusEConsR(SRA->RA_FILIAL,SRA->RA_MAT, aCols[nX,3], aCols[nX,12], cPeriodo)
										If  Len(aEConsig) > 0
											cXml += '<descFolha>'
											cXml += '	<tpDesc>1</tpDesc>'
											If !Empty(aEConsig[1,5])
												cXml += '	<instFinanc>'+Alltrim(StrZero(Val(aEConsig[1,5]),3))+'</instFinanc>'
											Endif
											If !Empty(aEConsig[1,6])
												cXml += '	<nrDoc>'+ Alltrim(Substr(aEConsig[1,6], 1,15 ) ) +'</nrDoc>'
											Endif
											If !Empty(aEConsig[1,7])
												cXml += '	<observacao>' + Alltrim(aEConsig[1,7]) +'</observacao>'
											Endif
											cXml += '</descFolha>'
										Endif
									Endif

									cXml += "							</detVerbas>"
									If aCols[nX,3] $ cVbPla
										lGerPla := .T.
									EndIf
									If !lRel
										lRetIR := (lVbRelIR .And. fVbRelIR(aCols[nX, 19], ALLTRIM(aCols[nX, 22]))) //Confirma que se trata de verba de IR
										If lMiddleware .And. ( (aCols[nX, 19] == "9901" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9201" .And. aCols[nX, 20] $ "31/32") .Or. (aCols[nX, 19] == "1409" .And. aCols[nX, 20] == "51") .Or. (aCols[nX, 19] == "4050" .And. aCols[nX, 20] == "21") .Or. (aCols[nX, 19] == "4051" .And. aCols[nX, 20] == "22") .Or. (aCols[nX, 19] == "9902" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9904" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9908" .And. aCols[nX, 23] == "3") ) .Or. lRetIR							
											fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nZ, 2], aDadosCCT[nZ, 3], aDadosCCT[nZ, 4], aCols[nX, 19], aCols[nX, 23], aCols[nX, 20], aCols[nX, 21], aCols[nX, 22], aCols[nX, 17], "S-2299", , , ,aCols[nX, 24], aCols[nX, 25], cIdDmDev, M->RG_DATAHOM, aCols[nX, 3], RetValSrv( aCols[nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(M->RG_DATAHOM),,lRetIR)
										EndIf
									EndIf
								EndIf
							EndIf

							//Caso esteja gerando o relatÛrio excel incrementa o array de incosistÍncia para as verbas de dissÌdio
							If lRel .And. ( aCols[nX,3] $ cVBDiss ) .And. (nPos := aScan(aRelVbDiss, { |x| x[1] == aCols[nX,3] })) > 0
								//Verba XXX desprezada do grupo infoPerApur (RemuneraÁ„o no perÌodo de apuraÁ„o) pois est· cadastrada no campo Verba P.Diss (RV_CODCOM) da verba YYY Dessa forma, a diferenÁa de dissÌdio ser· gerada no grupo infoPerAnt (RemuneraÁ„o em PerÌodos Anteriores)"
								cMsgRelat := OemtoAnsi(STR0395) + aCols[nX,3] + OemtoAnsi(STR0396) + aRelVbDiss[nPos][2] + OemtoAnsi(STR0397)
								aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, cMsgRelat})
							EndIf
						Next

						If SRA->RA_TPPREVI == "1"
							S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
						EndIf
						If !Empty(cIndSimp)
							cXml += "						<infoSimples>"
							cXml += "							<indSimples>" + cIndSimp + "</indSimples>"
							cXml += "						</infoSimples>"
						Endif
						cXml += "						</ideEstabLot>"
					Next

					cXml += "					</infoPerApur>"

					//Transfere para o XML as informaÁıes do Dissidio calculado na rescisao
					If !Empty( cInfoDiss )
						cXml += cInfoDiss
					EndIf

					If lIntermit .And. !Empty(cCodConvoc) .And. cVersaoEnv < "9.0.00"
						cXml += "				<infoTrabInterm>"
						cXml += "					<codConv>" + cCodConvoc + "</codConv>"
						cXml += "				</infoTrabInterm>"
					Endif

					cXml += "				</dmDev>"

					//Caso haja uso do modelo de deduÁ„o simplificada e n„o tenha verba de IR 68 aviso o usu·rio no relatÛrio de InconsistÍncia
					If lRel .And. lDedSimpl .And. !lGrvIR68
						//O trabalhador possui c·lculo com deduÁ„o simplificada de IR no ideDmDev #######, mas n„o h· verba com a incidÍncia IR 68.
						//Caso necess·rio, verifique se as verbas de Id 1921, 1922, 1923 e 1924 est„o cadastradas corretamente com a incidÍncia IR 68.
						aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, OemToAnsi(STR0409) + cIdDmDev + OemToAnsi(STR0410) + OemToAnsi(STR0411)})
					EndIf

					//ValidaÁ„o para verificar se gera o dmDev do PLR pago antes da rescis„o no mesmo perÌodo
					fPLR2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes, lRel, cPrefixo)

					//ValidaÁ„o para verificar se gera o dmDev de FÈrias pagas no mes da rescis„o
					If cVersaoEnv >= "9.1"
						fFER2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes, lRel, cPrefixo)
					EndIf

					If lTemRRA
						fBuscaIDCMPL(@cCompTrab,dDataRes,@nMesRRA)
						lRetRRA := fRRA2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes,cCompTrab, nMesRRA, cTpRes, lRel)
						If lRetRRA
							//ValidaÁ„o para verificar se gera o dmDev do Dissidio
							fDisRRA2299( dDataRes, @cVBDissRRA, aDadosCCT, cIndSimp, @cInfoRRA, @cMsgDiss, @lRJ5Ok, @aErrosRJ5, cTpRes, , @cDtEfei, @cCompAc)
							//Transfere para o XML as informaÁıes do RRA calculado na rescisao
							If !Empty( cInfoRRA )
								cXml += cInfoRRA
								cXml += "				</dmDev>"
							EndIf
						Endif
					Endif

					//Busca o ˙ltimo perÌodo de pagamento fechamento do roteiro ADI
					nQtdPgto := fQtdNrPag(SRA->RA_PROCES, If(lRetif, AnoMes(M->RG_DATADEM), M->RG_PERIODO), fGetCalcRot("2"))

					//"Processa o adiantamento conforme o tanto
					For nContAdi := 1 To nQtdPgto
						aAdiCC		:= {}
						aAdiCols	:= {}
						aErrosRJ5	:= {}
						cIdDmDev	:= ""
						cSemAdi		:= StrZero(nContAdi,2)

						//ValidaÁ„o para verificar se gera o dmDev do ADI
						fADI2299( @aAdiCC, @aAdiCols, cFilEnv, @cIdDmDev, cVersaoEnv, lRetif, @aErrosRJ5, cPrefixo, lRel, cSemAdi)

						If !Empty(aErrosRJ5)
							cMsgErro := OemToAnsi(STR0114) + CRLF//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
							For nI := 1 To Len(aErrosRJ5)
								cMsgErro += aErrosRJ5[nI] + CRLF
							Next
							cMsgErro += OemToAnsi(STR0115)//" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
							aAdd(aErros, cMsgErro)
							If !lRel
								If !IsInCallStack("fEnvLote")
									Help( ,, OemToAnsi(STR0001) ,, cMsgErro, 1, 0 )//"AtenÁ„o"
								EndIf
								DisarmTransaction()
								lGravou := .F.
								Break
							EndIf
						EndIf

					//Looping para varrer as verbas
					If Len(aAdiCols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						dDtPagto := CTOD("//")
						nPosDmDev := aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev })
						If nPosDmDev > 0
							dDtPagto := STOD(aDtPgtDmDev[nPosDmDev, 4])
						EndIf

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( aAdiCC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + aAdiCC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + aAdiCC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( aAdiCC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( aAdiCC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif
							//Looping nas verbas vindas
							For nX := 1 To Len( aAdiCols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( aAdiCols[nX, 12] == aAdiCC[nZ,1] .AND. aAdiCols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aAdiCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aAdiCols[nX,4] + "</ideTabRubr>"
									If !lMiddleware
										cXml += "							<qtdRubr>" + Str(aAdiCols[nX,15]) + "</qtdRubr>"
									ElseIf lMiddleware .And. !Empty(aAdiCols[nX,15])
										cXml += "							<qtdRubr>" + AllTrim(Str(aAdiCols[nX,15])) + "</qtdRubr>"
									EndIf
									If !lMiddleware .Or. !Empty(aAdiCols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(aAdiCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(aAdiCols[nX,16])) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(aAdiCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(aAdiCols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aAdiCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aAdiCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If !lRel
										lRetIR := (lVbRelIR .And. fVbRelIR(aAdiCols[nX, 21], ALLTRIM(aAdiCols[nX, 24]))) //Confirma que se trata de verba de IR
										If lMiddleware .And. ( (aAdiCols[nX, 21] == "9901" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9201" .And. aAdiCols[nX, 22] $ "31/32") .Or. (aAdiCols[nX, 21] == "1409" .And. aAdiCols[nX, 22] == "51") .Or. (aAdiCols[nX, 21] == "4050" .And. aAdiCols[nX, 22] == "21") .Or. (aAdiCols[nX, 21] == "4051" .And. aAdiCols[nX, 22] == "22") .Or. (aAdiCols[nX, 21] == "9902" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9904" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9908" .And. aAdiCols[nX, 25] == "3") .Or. lRetIR )
											fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aAdiCC[nZ, 2], aAdiCC[nZ, 3], aAdiCC[nZ, 4], aAdiCols[nX, 21], aAdiCols[nX, 25], aAdiCols[nX, 22], aAdiCols[nX, 23], aAdiCols[nX, 24], aAdiCols[nX, 17], "S-2299" , , , , aAdiCols[nX, 26], aAdiCols[nX, 27], cIdDmDev, dDtPagto, aAdiCols[nX, 3], RetValSrv( aAdiCols[nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(dDtPagto),,lRetIR)
										EndIf
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf
				Next nContAdi

					//ValidaÁ„o para verificar se gera o dmDev do 131
					f1312299( @a131CC, @a131Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5, cVersaoEnv, cPrefixo)

					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						aAdd(aErros, cMsgErro)
						If !lRel
							If !IsInCallStack("fEnvLote")
								Help(,,OemToAnsi(STR0001),,cMsgErro,1,0) //"AtenÁ„o"
							EndIf
							DisarmTransaction()
							lGravou := .F.
							Break
						EndIf
					EndIf

					//Looping para varrer as verbas
					If Len(a131Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a131CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a131CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a131CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a131CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a131CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( a131Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a131Cols[nX, 12] == a131CC[nZ,1]  .And. a131Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a131Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a131Cols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(a131Cols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(a131Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(a131Cols[nX,16]) ) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(a131Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(a131Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a131Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a131Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (a131Cols[nX, 21] == "9901" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9201" .And. a131Cols[nX, 22] $ "31/32") .Or. (a131Cols[nX, 21] == "1409" .And. a131Cols[nX, 22] == "51") .Or. (a131Cols[nX, 21] == "4050" .And. a131Cols[nX, 22] == "21") .Or. (a131Cols[nX, 21] == "4051" .And. a131Cols[nX, 22] == "22") .Or. (a131Cols[nX, 21] == "9902" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9904" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9908" .And. a131Cols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a131CC[nZ, 2], a131CC[nZ, 3], a131CC[nZ, 4], a131Cols[nX, 21], a131Cols[nX, 25], a131Cols[nX, 22], a131Cols[nX, 23], a131Cols[nX, 24], a131Cols[nX, 17], "S-2299" , , , ,a131Cols[nX, 26], a131Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next
						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					//ValidaÁ„o para verificar se gera o dmDev do 132
					f1322299( @a132CC, @a132Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5,cVersaoEnv,aFilInTaf, lAdmPubl, cTpInsc, cNrInsc, cPrefixo)

					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						aAdd(aErros, cMsgErro)
						If !lRel
							If !IsInCallStack("fEnvLote")
								Help(,,OemToAnsi(STR0001),,cMsgErro,1,0) //"AtenÁ„o"
							EndIf
							DisarmTransaction()
							lGravou := .F.
							Break
						EndIf
					EndIf

					//Looping para varrer as verbas
					If Len(a132Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a132CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a132CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a132CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a132CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a132CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							dDtPagto := CTOD("//")
							nPosDmDev := aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev })
							If nPosDmDev > 0
								dDtPagto := STOD(aDtPgtDmDev[nPosDmDev, 4])
							EndIf

							//Looping nas verbas vindas
							For nX := 1 To Len( a132Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a132Cols[nX, 12] == a132CC[nZ,1]  .And. a132Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a132Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a132Cols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(a132Cols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(a132Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(a132Cols[nX,16])) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(a132Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(a132Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a132Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a132Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If !lRel
										lRetIR := (lVbRelIR .And. fVbRelIR(a132Cols[nX, 21], ALLTRIM(a132Cols[nX, 24]))) //Confirma que se trata de verba de IR
										If lMiddleware .And. ( (a132Cols[nX, 21] == "9901" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9201" .And. a132Cols[nX, 22] $ "31/32") .Or. (a132Cols[nX, 21] == "1409" .And. a132Cols[nX, 22] == "51") .Or. (a132Cols[nX, 21] == "4050" .And. a132Cols[nX, 22] == "21") .Or. (a132Cols[nX, 21] == "4051" .And. a132Cols[nX, 22] == "22") .Or. (a132Cols[nX, 21] == "9902" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9904" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9908" .And. a132Cols[nX, 25] == "3") .Or. lRetIR)
											fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a132CC[nZ, 2], a132CC[nZ, 3], a132CC[nZ, 4], a132Cols[nX, 21], a132Cols[nX, 25], a132Cols[nX, 22], a132Cols[nX, 23], a132Cols[nX, 24], a132Cols[nX, 17], "S-2299" , , , ,a132Cols[nX, 26], a132Cols[nX, 27], cIdDmDev, dDtPagto, a132Cols[nX, 3], RetValSrv( a132Cols[nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(dDtPagto),,lRetIR )
										EndIf
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next
						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					If M->RG_SEMANA > "01"
						//ValidaÁ„o para verificar se gera o dmDev do FOL
						fFOL2299( @aFolCC, @aFolCols, cFilEnv, @aIdDmDev, cVersaoEnv, lRetif, M->RG_SEMANA, cPrefixo)
						For nContDev := 1 To Len(aIdDmDev)
							//Looping para varrer as verbas
							If Len(aFolCols[nContDev]) > 0
								cXml += "				<dmDev>"
								If !lMiddleware
									cXml += "					<ideDmDev>" + aIdDmDev[nContDev] +  "</ideDmDev>"
								Else
									cXml += "					<ideDmDev>" + Alltrim(aIdDmDev[nContDev] ) +  "</ideDmDev>"
								Endif
								cXml += "					<infoPerApur>"

								dDtPagto := CTOD("//")
								nPosDmDev := aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+SRA->RA_MAT+aIdDmDev[nContDev] })
								If nPosDmDev > 0
									dDtPagto := STOD(aDtPgtDmDev[nPosDmDev, 4])
								EndIf

								//Looping para detalhar os Centros de Custos que o Trab Atuou
								For nZ := 1 To Len( aFolCC[nContDev] )
									cXml += "						<ideEstabLot>"
									cXml += "							<tpInsc>" + aFolCC[nContDev,nZ,2] + "</tpInsc>"
									cXml += "							<nrInsc>" + aFolCC[nContDev,nZ,3] + "</nrInsc>"
									If !lMiddleware
										cXml += "							<codLotacao>" + StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;") + "</codLotacao>"
									Else
										cXml += "							<codLotacao>" + Alltrim(StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;")) + "</codLotacao>"
									Endif
									//Looping nas verbas vindas
									For nX := 1 To Len( aFolCols[nContDev] )
										//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
										If( aFolCols[nContDev,nX, 12] == aFolCC[nContDev,nZ,1] .AND. aFolCols[nContDev,nX,17] > 0 )
											cXml += "							<detVerbas>"
											cXml += "								<codRubr>" + aFolCols[nContDev,nX,3] + "</codRubr>"
											cXml += "								<ideTabRubr>" + aFolCols[nContDev,nX,4] + "</ideTabRubr>"
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,15])
												cXml += "							<qtdRubr>" + Str(aFolCols[nContDev,nX,15]) + "</qtdRubr>"
											EndIf
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,5])
												cXml += "							<fatorRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,5],"@E 999999999.99") ) + "</fatorRubr>"
											EndIf
											If (!lMiddleware .Or. !Empty(aFolCols[nContDev,nX,16])) .And. cVersaoEnv < "9.0.00"
												If !lMiddleware
													cXml += "							<vrUnit>" + AllTrim( Transform(aFolCols[nContDev,nX,16],"@E 999999999.99") ) + "</vrUnit>"
												Else
													cXml += "							<vrUnit>" + AllTrim( Str(aFolCols[nContDev,nX,16]) ) + "</vrUnit>"
												EndIf
											EndIf
											If !lMiddleware
												cXml += "								<vrRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,17],"@E 999999999.99") ) + "</vrRubr>"
											Else
												cXml += "								<vrRubr>" + AllTrim( Str(aFolCols[nContDev,nX,17]) ) + "</vrRubr>"
											EndIf
											If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
												cXml +=         '<indApurIR>0</indApurIR>'
											Endif
											cXml += "							</detVerbas>"
											If !lRel
												lRetIR := (lVbRelIR .And. fVbRelIR(aFolCols[nContDev, nX, 21], ALLTRIM(aFolCols[nContDev, nX, 24]))) //Confirma que se trata de verba de IR
												If lMiddleware .And. ( (aFolCols[nContDev, nX, 21] == "9901" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9201" .And. aFolCols[nContDev, nX, 22] $ "31/32") .Or. (aFolCols[nContDev, nX, 21] == "1409" .And. aFolCols[nContDev, nX, 22] == "51") .Or. (aFolCols[nContDev, nX, 21] == "4050" .And. aFolCols[nContDev, nX, 22] == "21") .Or. (aFolCols[nContDev, nX, 21] == "4051" .And. aFolCols[nContDev, nX, 22] == "22") .Or. (aFolCols[nContDev, nX, 21] == "9902" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9904" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9908" .And. aFolCols[nContDev, nX, 25] == "3") .Or. lRetIR)
													fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aFolCC[nContDev, nZ, 2], aFolCC[nContDev, nZ, 3], aFolCC[nContDev, nZ, 4], aFolCols[nContDev, nX, 21], aFolCols[nContDev, nX, 25], aFolCols[nContDev, nX, 22], aFolCols[nContDev, nX, 23], aFolCols[nContDev, nX, 24], aFolCols[nContDev, nX, 17], "S-2299" , , , ,aFolCols[nContDev, nX, 26], aFolCols[nContDev, nX, 27], aIdDmDev[nContDev], dDtPagto, aFolCols[nContDev, nX, 3], RetValSrv( aFolCols[nContDev, nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(dDtPagto),,lRetIR)
												EndIf
											EndIf
										EndIf
									Next

									If SRA->RA_TPPREVI == "1"
										S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
									EndIf
									If !Empty(cIndSimp)
										cXml += "							<infoSimples>"
										cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
										cXml += "							</infoSimples>"
									Endif
									cXml += "						</ideEstabLot>"
								Next

								cXml += "					</infoPerApur>"
								cXml += "				</dmDev>"
							EndIf
						Next nContDev
					EndIf

					//InformaÁıes Multiplos Vinculos
					If ( Len( aDadosRAZ ) > 0 )
						cXml += "				<infoMV>"
						cXml += "					<indMV>" + aDadosRAZ[1,5] + "</indMV>"

						For nX := 1 To Len( aDadosRAZ )
							cXml += "					<remunOutrEmpr>"
							cXml += "						<tpInsc>" + aDadosRAZ[nX,9] + "</tpInsc>"
							cXml += "						<nrInsc>" + aDadosRAZ[nX,10] + "</nrInsc>"
							cXml += "						<codCateg>" + aDadosRAZ[nX,12] + "</codCateg>"
							cXml += "						<vlrRemunOE>" + AllTrim( Transform(aDadosRAZ[nX,11],"@E 999999999.99") ) + "</vlrRemunOE>"
							cXml += "					</remunOutrEmpr>"
						Next
						cXml += "				</infoMV>"
					EndIf

					If cVersaoEnv >= "2.4.02" .And. SRG->(ColumnPos("RG_NPROCS")) > 0 .And. !Empty(oModelSRG:GetValue("RG_NPROCS"))
						cXml += "<procCS>"
						cXml += "   <nrProcJud>"+oModelSRG:GetValue("RG_NPROCS")+"</nrProcJud>"
						cXml += "</procCS>"
					EndIf
					cXml += "			</verbasResc>"
				Endif

				If cVersaoEnv >= '9.2' .And. lQuarentena
					If !Empty(oModelSRG:GetValue("RG_TPREMAD")) .And. !Empty(oModelSRG:GetValue("RG_DTQUAR"))
						cXml += "			<remunAposDeslig>"
						cXml += "				<indRemun>"+ oModelSRG:GetValue("RG_TPREMAD")+"</indRemun>"
						cXml += "				<dtFimRemun>"+dToS(oModelSRG:GetValue("RG_DTQUAR"))+"</dtFimRemun>"
						cXml += "			</remunAposDeslig>"
					EndIf
				EndIf

				If cVersaoEnv >= '2.4' .And. (Len(aPd_Aux) > 0 .Or. (cVersaoEnv < "2.4.02"  .And. Len(aPd_Aux) == 0 ))
					cXml += "			<consigFGTS>"
					IF Len(aPd_Aux) > 0
						If fBuscConsig(aPd_Aux)
							If cVersaoEnv <= "2.4
								cXml += "             <idConsig>S</idConsig>"
							EndIf
							cXml += "				<insConsig>" + Alltrim(SRK->RK_BCOCONS )+ "</insConsig>"
							cXml += "				<nrContr>" + Alltrim(SRK->RK_NRCONTR) + "</nrContr>"
						EndIf
					EndIf
					If cVersaoEnv < "2.4.02"  .And. (Len(aPd_Aux) == 0 .Or. !("idConsig" $ cXml))
						cXml += "               <idConsig>N</idConsig>"
					EndIf
					cXml += "			</consigFGTS>"
				EndIf

				//Fechamentos de Tags
				cXml += "		</infoDeslig>"
				cXml += "	</evtDeslig>"
				cXml += "</eSocial>"
				//-------------------
				//| Final do XML
				//-------------------
			EndIf
		ElseIf (cTpRes == "2" .AND. nOperation != 5)
			//------------------------
			//| Tipo Rescisao Coletiva
			//| Caso a chamada da funcao tenha vindo da GPEM630()
			//----------------------------------------------------
			if !lMiddleware
				fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				cStat2299 := TAFGetStat( "S-2299", AllTrim(SRA->RA_CIC) + ";" + AllTrim(SRA->RA_CODUNIC), , SRA->RA_FILIAL)
				If cStat2299 == "6"
					//"AtenÁ„o"##"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o pendente para transmiss„o"
					//"Verifique o status do evento S-3000 e tente novamente."
					aAdd(aErros, OemToAnsi(STR0146)+". "+ OemToAnsi(STR0326))//"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "##" n„o est· cadastrado."
					DisarmTransaction()
					lGravou := .F.
					Break
				EndIf
			endif

			If Empty(cFilEnv)
				cFilEnv:= cFilAnt
			EndIf

			If cVersaoEnv >= '2.3'
				cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRA")) + SRA->RA_MAT
			EndIf

			//Guarda a data de pagamento de cada DmDev
			If aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3]+x[4] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev+dtos(M->RG_DATAHOM) }) == 0
				aAdd(aDtPgtDmDev, { SRA->RA_FILIAL,SRA->RA_MAT, cIdDmDev, dtos(M->RG_DATAHOM) } )
			EndIf

			//----------------
			//| Evento S-2299
			//| Inicio da geracao do evento de desligamento
			//----------------------------------------------
			If !Empty(cFilEnv)

				//------------------------
				//| Verificacao de Filial
				//| Verificar o compartilhamento das tabelas CTT/RJ5 e SRV
				//--------------------------------------------------------------
				lNovoCTT:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
				lRJs 	:= lNovoCTT .And. !lParcial

				If lRJs
					If Empty(xFilial("RJ5")) //RJ5 compartilhada
						lSemFilCTT := .T.
					EndIf
				Else
					If Empty(xFilial("CTT")) //CTT compartilhada
						lSemFilCTT := .T.
					EndIf
				Endif

				If !lMiddleware
					cTafKey := "S2299" + AnoMes(M->RG_DATADEM) + SRA->RA_CIC + SRA->RA_CODUNIC
				else
					fVersEsoc( "S2299", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					lS1000 := fVld1000( AnoMes(M->RG_DATADEM), @cStatus )
					If !lS1000 .And. cEFDAviso != "2"
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130))//"Registro do evento X-XXXX n„o localizado na base de dados"
							Case cStatus == "1" // nao enviado para o governo
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131))//"Registro do evento X-XXXX n„o transmitido para o governo"
							Case cStatus == "2" // enviado e aguardando retorno do governo
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132))//"Registro do evento X-XXXX aguardando retorno do governo"
							Case cStatus == "3" // enviado e retornado com erro
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133))//"Registro do evento X-XXXX retornado com erro do governo"
						EndCase
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf
				EndIf

				//Verifica se a ConfiguraÁ„o de Verbas foi executada
				If !Empty(dDtInFer) .And. MesAno(dDtInFer) <= MesAno(M->RG_DATAHOM)
					lDtFerSub := .T.
				Endif	

				//-----------------------------
				//| Varrendo o grid das verbas
				//| Looping para centralizar dentro do aCols as rubricas iguais
				//--------------------------------------------------------------
				For nI := 1 To Len( aPd )

					//Desconsidera as verbas deletadas
					If aPd[nI, 9] == "D"
						Loop
					EndIf

					lAltPd := .F.
					cPdBkp := ""

					//Manipula apd para considerar a verba de substituiÁ„o
					If lVbFerSub .And. (!Empty(aPd[nI,29]) .Or. (lDtFerSub .And. !Empty(RetValSrv(aPd[nI, 1], SRA->RA_FILIAL, "RV_FERXML")))) .And. aPd[nI, 7] $ "I|R"
						cPdBkp	:= aPd[nI, 1]
						lAltPd	:= .T.

						aPd[nI, 1] := Iif(Empty(aPd[nI,29]), RetValSrv(aPd[nI, 1], SRA->RA_FILIAL, "RV_FERXML"), Empty(aPd[nI,29]))
					EndIf

					lAltCC := .F.

					// CASO O PARAMETRO MV_RATESOC ESTEJA COMO .F., VAI CONSIDERAR O CENTRO DO CUSTO DO FUNCIONARIO PARA TOTALIZA«√O
					// DAS VERBAS DESCONSIDERANDO OS DEMAIS CENTROS DE CUSTOS.
					If !lGeraRat .And. (cCCAnt <> aPd[nI,2] .Or. (Empty(cPdAnt) .Or. cPdAnt <> aPd[nI,1]))
						cPdAnt	:= aPd[nI, 1]
						cCCAnt	:= aPd[nI, 2]
						lAltCC	:= .T.
						aPd[nI, 2] := SRA->RA_CC
					EndIf

					//--------------------------------
					//| Montagem da chave de pesquisa
					//| Realiza a montagem da chave de auxilio para localizar registro
					//-----------------------------------------------------------------
					cChaveCCPD	:= aPd[nI,2] + aPd[nI,1]
					cChaveCC	:= aPd[nI,2]
					lTemReg		:= .F.

					nPosCCPD	:= Ascan( @aCols,{|X| X[1] == cChaveCCPD })
					nPosCC		:= Ascan( @aCols,{|X| X[12] == cChaveCC })

					aAreaCTT := GetArea()
					aAreaRJ5 := GetArea()
					aAreaRJ3 := GetArea()

					//----------------------------------
					//| Centro de Custo x Verba/Rubrica
					//| Realiza o filtro para saber se a verba incide IRRF
					//| Seleciona a Verba dentro do SRA e pega seus respectivos dados
					//| Seleciona o CC    dentro da CTT e pega seus respectivos dados
					//----------------------------------------------------------------
					If ( ( (cVersaoEnv < "2.6.00" ) .And. !(SubStr(RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
						( (cVersaoEnv >= "9.0.00") .And. (!RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_NATUREZ" ) $ "1801|9220" ))) .And.;
						!(RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126|0303")
						//--------------------
						//| Verbas / Rubricas
						//| Guarda a area atual, entra na SRV e recupera os dados da verba
						//------------------------------------------------------------------
						aAreaSRV := GetArea()
						DBSelectArea("SRV")
						SRV->(DbSetOrder(1))
						If( SRV->( dbSeek( xFilial("SRV") + aPd[nI,1]  ) ) )
							//Tratamento de compartilhamento da tabela SRV
							If !Empty(SRV->RV_FILIAL)
								lGeraCod := .T.
							Else
								lSemFilSRV := .T.
							EndIf

							//------------------
							//| LÛgica lGeraCod
							//| .T. -> Exclusiva | .F. -> Compartilhada
							//------------------------------------------
							If lGeraCod
								cIdeRubr := Iif(!Empty(SRV->RV_FILIAL),SRV->RV_FILIAL , (xFilial("SRV"),SRV->RV_FILIAL) )
							Else
								If cVersaoEnv >= "2.3"
									cIdeRubr := cEmpAnt
								Else
									cIdeRubr := ""
								EndIf
							Endif

							If lMiddleware
								If lPrimIdT
									lPrimIdT  := .F.
									cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
									If Empty(cIdTabRub)
										aAdd(aErros, OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141))//"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "##" n„o est· cadastrado."
										DisarmTransaction()
										lGravou := .F.
										Break
									EndIf
								EndIf
								cIdeRubr := cIdTabRub
							EndIf

							cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
							If (SRV->RV_PERC - 100) < 0
								cPrcRubr :=	0	//Percent da Rubrica
							Else
								cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
							EndIf

							//----------------------------------------
							//| Recuperar a natureza da verba
							//| Se estiverem vazias, v„o para a geraÁ„o do log
							//-------------------------------------------------
							If Empty( SRV->RV_NATUREZ )
								If( Len(aErrosVb) == 0 )
									aAdd(aErrosVb, OemToAnsi( STR0054 ))
									aAdd(aErrosVb, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC ) + " ")
								Else
									aAdd(aErrosVb, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC ) + " ")
								EndIf
							ElseIf ((cVersaoEnv < '2.6.00' .And. SRV->RV_NATUREZ == "9219") .Or. cVersaoEnv >= '2.6.00') .And. !lCarrDep
								//-----------------
								//| Plano de Saude
								//| Se a verba corrente tiver natureza de rubrica '9219' de plano de saude
								//| Entra na tabela RHR - Plano de Saude, localiza o registro do funcion·rio
								//| Verifica se o registro foi integrado com a folha, se sim: alimenta array
								//---------------------------------------------------------------------------
								//se o c·lculo do plano de sa˙de estiver fechado, ler RHS, sen„o RHR
								aAreaRCH := GetArea()
								DbSelectArea("RCH")
								RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )
								cProces  := SRA->RA_PROCES
								cPeriodo := ANoMes(M->RG_DATADEM)
								cNumPag  := M->RG_SEMANA
								RCH->( dbSeek( xFilial("RCH") + cProces + cTipoPLA + cPeriodo + cNumPag ) )
								If Empty(RCH->RCH_DTFECH)
									cTabRH := "RHR"
								Else
									cTabRH := "RHS"
								EndIf
								RestArea(aAreaRCH)
								GetRAssMed( SRA->RA_FILIAL, SRA->RA_MAT, "S016", cVersaoEnv, ANoMes(M->RG_DATADEM), @aDadosTRHR, @aDadosDRHR, cTabRH, @lCPFDepOk, @aDepAgreg )
								lCarrDep := .T.
								cVbPla 	 += SRV->RV_COD + "/"
							EndIf

						EndIf
						RestArea(aAreaSRV)

						If cVersaoEnv >= "9.3"
							cCodINCIRF := RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCIRF" )
							cCodNat    := RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_NATUREZ" )
							cCodCCP15  := RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCCP" )
							cFilIRF    := SRA->RA_FILIAL
							cMatIRF    := SRA->RA_MAT
							nValorIRF  := aPd[nI,5]
							cPdIRF     := aPd[nI,1]
							cDescCod   := RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_DESC" )
							dDtPgt 	   := M->RG_DATAHOM
							//pens„o alimenticia
							If (VAL(cCodINCIRF ) >=  51 .AND. VAL(cCodINCIRF ) <= 55)
								fBenefic( cFilIRF, cMatIRF, dDtPgt, cPdIRF, nValorIRF, , ANoMes(M->RG_DATADEM), cCodINCIRF , .F.)
								If Len(aRetPensao)== 0
									cMsgPen := OemToAnsi(STR0412 ) + CRLF  //"Verba com incidÍncia de IR relacionada a Pens„o AlimentÌcia, mas n„o h· dados no Cadastro de Beneficiarios"
									If( Len(aErrosComp) == 0 )
										aAdd(aErrosComp, OemToAnsi( STR0415 ))
										aAdd(aErrosComp, cMsgPen )
									Else
										If aScan(aErrosComp,{|x| x == cMsgPen }) == 0
											aAdd(aErrosComp, cMsgPen )
										Endif
									EndIf
								Endif
							Endif
							//previdencia complementar
							If (Val(cCodINCIRF) >= 46 .And. Val(cCodINCIRF) <= 48) .Or. (Val(cCodINCIRF) >= 61 .And. Val(cCodINCIRF) <= 66) .Or. (Val(cCodINCIRF) >= 9046 .And. Val(cCodINCIRF) <= 9048) .Or. (Val(cCodINCIRF) >= 9061 .And. Val(cCodINCIRF) <= 9066)
								fGetPrev( cPdIRF, ANoMes(M->RG_DATADEM), cCodINCIRF, nValorIRF, .F. )
								If Len(aInfoPrev) == 0
									cMsgPen := OemToAnsi(STR0413) + CRLF //"Verba com incidÍncia de IR relacionada a PrevidÍncia Complementar, mas n„o h· dados no Cadastro de PrevidÍncia Complementar"
									If( Len(aErrosComp) == 0 )
										aAdd(aErrosComp, OemToAnsi( STR0415 ))
										aAdd(aErrosComp, cMsgPen)
									Else
										If aScan(aErrosComp,{|x| x == cMsgPen }) == 0
											aAdd(aErrosComp, cMsgPen)
										Endif
									EndIf
								Endif
							Endif
							//plano de saude
							If  cCodNat == "9219" .And. Val(cCodINCIRF) == 67 .And. Empty(aDadosRHS)
								cDtPesqI  := ANoMes(M->RG_DATADEM)+"01"
								cDtPesqF  := ANoMes(M->RG_DATADEM)+"31"
								adadosRHS := fGetPLS1210( cFilIRF, cMatIRF , "1", cDtPesqI, cDtPesqF, ANoMes(M->RG_DATADEM) )
								If Len(aDadosRHS) == 0
									cMsgPen := OemToAnsi(STR0414) + CRLF //"Verba com incidÍncia de IR relacionada a Plano de Sa˙de, mas n„o h· dados no Cadastro de Plano de Sa˙de Ativo"
									If( Len(aErrosComp) == 0 )
										aAdd(aErrosComp, OemToAnsi( STR0415 ))
										aAdd(aErrosComp, cMsgPen )
									Else
										If aScan(aErrosComp,{|x| x == cMsgPen }) == 0
											aAdd(aErrosComp, cMsgPen )
										Endif
									EndIf
								Endif
							Endif
							If  !Empty(cCodNat) .And. cCodCCP15  $ '15|16'
						 	    lRetIncc := fValNATINCC(cCodNat)
								If !lRetIncc
									cMsg15 := OemToAnsi(STR0436) + CRLF //"Somente podem ser aceitas rubricas com cÛdigo de incidÍncia para a PrevidÍncia Social 15 ou 16, desde que as naturezas de rubrica sejam compatÌveis,"
									cMsg15 += OemToAnsi(STR0437) + CRLF //"conforme o campo 'IncidÍncia INSS 15/16' da tabela S047-Natureza de Rubricas"
									If( Len(aErrosINCCP) == 0 )
										aAdd(aErrosINCCP, cMsg15)
										aAdd(aErrosINCCP, cPdIRF + " - " + AllTrim( cDescCod )+ ";" )
									Else
										aAdd(aErrosINCCP, cPdIRF + " - " + AllTrim( cDescCod )+ ";" )
									EndIf
								Endif
							Endif
						Endif

						if lRJs // usa controle na RJ5
						//------------------------------------------------
							//| LotaÁ„o
							//| Guarda a area atual, entra na RJ5 e recupera os dados do cc
							//---------------------------------------------------------------

							aAreaCTT := GetArea()
							aAreaRJ5 := GetArea()
							aAreaRJ3 := GetArea()

							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + aPd[nI,2]  ) ) )
								DBSelectArea("RJ5")
								RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
								If( RJ5->( dbSeek( xFilial("RJ5") + aPd[nI,2] ) ) )
									//Se o campo RJ5_FILT existe pesquisa por este registro preenchido
									If lRJ5FilT
										RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
										RJ5->(dbGoTop())
										If RJ5->( dbSeek( xFilial("RJ5") + aPd[nI,2]  + SRA->RA_FILIAL ) )
											While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5",  SRA->RA_FILIAL) .And. RJ5->RJ5_CC == aPd[nI,2] .And.;
												IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT ==  SRA->RA_FILIAL, .T.)
												If cPeriodo >= RJ5->RJ5_INI
													cCCRJ5 := RJ5->RJ5_COD
												EndIf
												RJ5->( dbSkip() )
											EndDo
										EndIf
										If Empty(cCCRJ5)
											cCCRJ5 := fBsCCRJ5(xFilial("RJ5"), aPd[nI,2], IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == SRA->RA_FILIAL, .T.), cPeriodo, @nRecnoRJ5)
											//Posiciona novamente no registro da RJ5
											IF !Empty(cCCRJ5) .And. nRecnoRJ5 > 0
												RJ5->(dbGoTo(nRecnoRJ5))
											EndIf
										EndIf
									EndIf
									If EMPTY(RJ5->RJ5_TPIO) .AND. EMPTY(RJ5->RJ5_NIO) // LOTACAO
										DBSelectArea("RJ3")
										RJ3->(DbSetOrder(2)) //RJ3_FILIAL+RJ3_COD+RJ3_INI+RJ3_TPLOT
										If( RJ3->( dbSeek( xFilial("RJ3") + cCCRJ5 ) ) )
											cCodLot  := IIf(lSemFilCTT, RJ3->RJ3_COD, RJ3->RJ3_FILIAL + RJ3->RJ3_COD )
											cTpInscr := ""
											cInscr 	 := ""
										ENDIF
									elseif !EMPTY(RJ5->RJ5_TPIO) .AND. !EMPTY(RJ5->RJ5_NIO) // OBRA PROPRIA
										cCodLot := IIf(lSemFilCTT, RJ5->RJ5_COD, RJ5->RJ5_FILIAL + RJ5->RJ5_COD )
										If RJ5->RJ5_TPIO == "4"
											cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
											cInscr 		:= RJ5->RJ5_NIO // Codigo da inscricao
											cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
										Endif
									ENDIF
								else
									aAdd(aErros, OemToAnsi(STR0116) + alltrim(aPd[nI,2]) + OemToAnsi(STR0117) + alltrim(SRA->RA_MAT) + OemToAnsi(STR0118) ) // "CC ## nao cadastrado na RJ5
									DisarmTransaction()
									lGravou := .F.
									Break
								Endif

								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr	 	:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If(nPosCC == 0)
									aAdd(aDadosCCT, {RJ5->RJ5_CC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaRJ5)
								RestArea(aAreaCTT)
								RestArea(aAreaRJ3)
							EndIf

						else
							//------------------------------------------------
							//| Centro de Custo
							//| Guarda a area atual, entra na CTT e recupera os dados do cc
							//---------------------------------------------------------------
							aAreaCTT := GetArea()
							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + aPd[nI,2]  ) ) )
								cCodLot := IIf(lSemFilCTT, CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
								cTpLot  := CTT->CTT_TPLOT	// Tipo de LotaÁ„o (?!?)
								//Verifica se eh uma obra por meio do campo CTT_TIPO2
								If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
								cTpInscr := CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
								cInscr := CTT->CTT_CEI2 // Codigo da inscricao
									cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
								Endif
								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr		:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If(nPosCC == 0)
									aAdd(aDadosCCT, {CTT->CTT_CUSTO, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaCTT)
							EndIf
						Endif

						RestArea(aAreaCTT)

						//------------------------------------------------
						//| Array de Dados
						//| Montagem do array com os dados a utilizar para o XML
						//-------------------------------------------------------
						If( nPosCCPD > 0 )
							aCols[nPosCCPD, 15] += aPd[nI,4]	//Incrementa Horas
							aCols[nPosCCPD, 17] += aPd[nI,5]	//Incrementa Valor
							aCols[nPosCCPD, 18] := aCols[nPosCCPD, 18] + 1	  	//Incrementa Contador
						Else
							aAdd(aCols, { 	aPd[nI,2]+ aPd[nI,1],;	//01 - Chave para pesquisa (CC+PD)
												"Dados da Verba",;			//02 - Separador - Verbas/Rubricas
												cCodRubr,;					//03 - Codigo da Rubrica
												cIdeRubr,;					//04 - Ident   da Rubrica
												cPrcRubr,;					//05 - Percent da Rubrica
												"Dados do CC",;				//06 - Separador - Centro de Custo
												cCodLot,;					//07 - Codigo da LotaÁ„o
												cTpInscr,;					//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
												cInscr,;					//09 - Codigo da inscricao
												cTpLot,;					//10 - Tipo de LotaÁ„o (?!?)
												"Dados da Grid",;			//11 - Separador - Centro de Custo
												aPd[nI,2],;					//12 - Centro de Custo
												aPd[nI,1],;					//13 - Verba da rescis„o
												"",;						//14 - Descricao da verba
												aPd[nI,4],;					//15 - Horas da verba
												aPd[nI,5],;					//16 - Valor da verba
												aPd[nI,5],;					//17 - Acumulado da verba (valor inicial para soma)
												1,;							//18 - Numero de registro repetidos (CC + PD)
												SRV->RV_NATUREZ,;			//19 - Natureza da verba
												SRV->RV_INCCP,;				//20 - IncidÍncia CP da verba
												SRV->RV_INCFGTS,;			//21 - IncidÍncia FGTS da verba
												SRV->RV_INCIRF,;			//22 - IncidÍncia IRRF da verba
												SRV->RV_TIPOCOD,;			//23 - Tipo da verba
												If(lRVIncop,SRV->RV_INCOP,""),;	 //24 - Incid RPPS
												If(lRVTetop,SRV->RV_TETOP,"")})  //25 - Teto Remun


						EndIf
					EndIf
					//----------------------
					//| Liquido da Rescis„o
					//| Se a verba corrente tiver o ID de Calculo igual
					//| a 0126 O Sistema receber· o valor lÌquido da rescis„o
					//--------------------------------------------------------
					If RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126"
						nValor := aPd[nI,5]
					EndIf

					//---------------------
					//| Pens„o Alimenticia
					//| Se a verba corrente tiver valor de DIRF igual aos informados
					//| Realizar· a soma do montante pago de pens„o Alimenticia
					//-----------------------------------------------------------
					If ( ( cVersaoEnv < "2.6.00" .And. SubStr(RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "51|52|53|54|55" ) .Or.;
						( cVersaoEnv >= "2.6.00" .And. RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCIRF" ) $ "51  |52  |53  |54  |55  " ) )
						nPensao += aPd[nI,5]
					EndIf

					//------------------------------
					//| Verba de Multiplos Vinculos
					//| Se a verba corrente, tiver seu ID de Calculo igual a 0318
					//| realizar· a procura dos multiplos vÌnculos do funcion·rio
					//------------------------------------------------------------
					If RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_CODFOL" ) $ "0318"
						aAreaRAZ := GetArea()
						DBSelectArea("RAZ")
						RAZ->(DbSetOrder(1))
						If( RAZ->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ) ) )
							aDadosRAZ := GetMulVin( SRA->RA_FILIAL , SRA->RA_MAT, M->RG_PERIODO, .T.)
						EndIf
						RestArea(aAreaCTT)
					EndIf

					//Restaura a verba no apd
					If lAltPd
						aPd[nI, 1] := cPdBkp
					EndIf

					//Restaura o centro de custo
					If lAltCC
						aPd[nI, 2] := cCCAnt
					EndIf

					//Identifica nos valores da rescis„o se houve c·lculo com a deduÁ„o simplificada
					If aPd[nI, 28] == "2" .And. RetValSrv( aPd[nI,1], SRA->RA_FILIAL, 'RV_CODFOL' ) $ "0010|0015|0016|0027|0100"
						lDedSimpl := .T.
					EndIf
				Next nI

				//Tratando o Log
				If( Len(aErrosComp) > 0 ) //Maior que 1 pois sempre vai existir o cabeÁalho do log de erros
					For nI := 1 To Len(aErrosComp)
						aAdd(aErros, aErrosComp[nI] )
					Next nI
					DisarmTransaction()
					lGravou := .F.
					Break
				EndIf

				//Tratando o Log
				If( Len(aErrosVb) > 1 ) //Maior que 1 pois sempre vai existir o cabeÁalho do log de erros
					For nI := 1 To Len(aErrosVb)
						aAdd(aErros, aErrosVb[nI] )
					Next nI
					aAdd(aErros, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0056 ) ) //"est„o sem cÛdigo de rubrica cadastrada (RV_NATUREZ)." "N„o ser· possÌvel integraÁ„o com o TAF e a efetivaÁ„o da rescis„o."
					DisarmTransaction()
					lGravou := .F.
					Break
				EndIf

				If( Len(aErrosINCCP) > 1 ) //Maior que 1 pois sempre vai existir o cabeÁalho do log de erros
					For nI:=1 to Len(aErrosINCCP)
						aAdd(aErros, aErrosINCCP[nI])
					Next
					DisarmTransaction()
					lGravou := .F.
					Break
				EndIf

				//Ordena o Array separando por centro de custo
				//ASORT(aCols, , , { | x,y | x[2] < y[2] } )
				If !Empty(SRA->RA_CC) .AND. Len(aCC) > 0
					nPosLot := aScan(aCC, {|x| x[1] == FWxFilial("CTT") .AND. x[2] == SRA->RA_CC} )
					If nPosLot > 0
						cTpInscr := aCC[nPosLot,3]
						cInscr := aCC[nPosLot,4]
					EndIf
				EndIf

				If Empty(cTpInscr) .OR. Empty(cInscr)
					nPosEstb := eVal(bEstab)
					If nPosEstb > 0
						cTpInscr := aEstb[nPosEstb,3]
						cInscr := aEstb[nPosEstb,2]
					EndIf
				EndIf

				if !lMiddleware
					fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				endif

				If Empty(cFilEnv)
					cFilEnv:= cFilAnt
				EndIf

				fBusCadBenef(@aCodBenef,"FOL")
				For nI := 1 to len(aCodBenef)
					If Valtype( aCodBenef[nI,27]) == "N"
						nPerPens += aCodBenef[nI,27] //Percentual FGTS
					EndIf
				Next nI

				nI := 0

				//Carregad Dados do Tabela S037, passando a data da Demiss„o como par‚metro.
				fCarrTab( @aTabS037, "S037", dDataRes, .T. , , , SRA->RA_FILIAL)
				For nCntS037 :=1 to Len(aTabS037)
					cSimples := aTabS037[nCntS037,11] // Simples Nacional
					If cSimples == "1"
						cIndSimp := aTabS037[nCntS037,18] // Indicador do Tipo de Simples Nacional.
					EndIf
				Next nCntS037

				If AllTrim(aIncRes[02]) $ "I/A"
					dDtProj := dDataRes + cDiaInde + 1
				EndIf

				//-------------------
				//| Inicio do XML
				//-------------------

				If lMiddleware
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStat2299 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt, Nil, Nil, .T. )

					//Retorno pendente impede o cadastro
					If cStat2299 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
					EndIf
					//Inclus„o
					If nOperation != 5
						//Evento de exclus„o sem transmiss„o impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
						ElseIf cStat2299 == "99"
							cMsgRJE 	:= STR0146//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o pendente para transmiss„o"
						//N„o existe na fila, ser· tratado como inclus„o
						ElseIf cStat2299 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento sem transmiss„o, ir· sobrescrever o registro na fila
						ElseIf cStat2299 $ "1/3"
							cOperNew 	:= cOper2299
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclus„o transmitido, ser· tratado como inclus„o
						ElseIf cOper2299 == "E" .And. cStat2299 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					//Exclus„o
					Else
						//Evento de exclus„o sem transmiss„o impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
						//Evento diferente de exclus„o transmitido ir· gerar uma exclus„o
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
					If !Empty(cMsgRJE)
						aAdd(aErros, cMsgRJE)
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf
					If cRetfNew == "2"
						If cStat2299 == "4"
							cRecibXML 	:= cRecib2299
							cRecibAnt	:= cRecib2299
							cRecib2299	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2299", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2299, cRecibAnt } )
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtDeslig/v" + cVersMw + "'>"
					cXML += 	"<evtDeslig Id='" + cId + "'>"
					fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cGpeAmbe, 1, "12" }, cVersaoEnv, aInfos)
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )

				else

					cXml := "<eSocial>"
					cXml += "	<evtDeslig>"
				endif

				//Consulta se existe a geraÁ„o do evento S-1200 para confirmar se gera o prefixo do ideDmDev
				If cStat2299 == "-1" .And. Empty(cPrefixo)
					lGeraPre := .T.
				EndIf

				//Pesquisa pelo prefixo na tabela RU8
				If lNewDmDev
					cPrefixo := fGetPrefixo(SRA->RA_FILIAL, SRA->RA_MAT, M->RG_PERIODO, SRA->RA_CIC, lGeraPre)
				EndIf

				//Dados do Trabalhador
				cXml += "		<ideVinculo>"
				cXml += "			<cpfTrab>" + AllTrim(SRA->RA_CIC) + "</cpfTrab>"
				If cVersaoEnv < "9.0.00"
					cXml += "			<nisTrab>" + AllTrim(SRA->RA_PIS) + "</nisTrab>"
				Endif
				If !Empty(SRA->RA_CODUNIC)
					cMatricula := If(!lMiddleware, StrTran(SRA->RA_CODUNIC, "&","&#38;" ),SRA->RA_CODUNIC )
				EndIf

				cXml += "			<matricula>" + AllTrim(cMatricula) + "</matricula>"
				cXml += "		</ideVinculo>"

				//Dados do Desligamento
				cXml += "		<infoDeslig>"
				cXml += "			<mtvDeslig>" + cCodDslg + "</mtvDeslig>"
				If !lMiddleware
					cXml += "			<dtDeslig>" + Dtos(M->RG_DATADEM) + "</dtDeslig>"
				Else
					cXml += "			<dtDeslig>" + SubStr( dToS(M->RG_DATADEM), 1, 4 ) + "-" + SubStr( dToS(M->RG_DATADEM), 5, 2 ) + "-" + SubStr( dToS(M->RG_DATADEM), 7, 2 ) + "</dtDeslig>"
				EndIf
				If cVersaoEnv >= "9.0.00"
					If !lMiddleware
						cXml += "			<dtAvPrv>" + Dtos(M->RG_DTAVISO) + "</dtAvPrv>"
					Else
						cXml += "			<dtAvPrv>" + SubStr( dToS(M->RG_DTAVISO), 1, 4 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 5, 2 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 7, 2 ) + "</dtAvPrv>"
					Endif
				Endif
				cXml += "			<indPagtoAPI>" + IIf(AllTrim(aIncRes[02]) $ "I/A","S","N") + "</indPagtoAPI>"
				If !Empty(dDtProj) .And. AllTrim(aIncRes[02]) $ "I/A"
					If !lMiddleware
						cXml +=			'<dtProjFimAPI>' + Dtos(dDtProj) + '</dtProjFimAPI>'
					Else
						cXml +=			'<dtProjFimAPI>' + SubStr( dToS(dDtProj), 1, 4 ) + "-" + SubStr( dToS(dDtProj), 5, 2 ) + "-" + SubStr( dToS(dDtProj), 7, 2 ) + '</dtProjFimAPI>'
					EndIf
				EndIf

				If cVersaoEnv < "9.0.00" .Or. (cVersaoEnv >= "9.0.00" .And. nTpRegTrab == 0 )
					//Pensao Alimenticia
					If nPerPens > 0
						cXml +=				'<pensAlim>1</pensAlim>'
					Else
						cXml +=				'<pensAlim>0</pensAlim>'
					Endif
				Endif
				//Percentual Alimenticio
				if nPerPens <>0
					cXml +=				'<percAliment>' + Alltrim(Str(nPerPens)) + '</percAliment>'
				endif

				If cVersaoEnv < "9.0.00"
					//Numero Certidao Obito
					If Iif(cVersaoEnv >= '2.5.00', cCodDslg $ "10", cCodDslg $ "09*10") .And. !Empty(AllTrim(M->RG_OBITO))
						cXml +=			'<nrCertObito>' + AllTrim(M->RG_OBITO) + '</nrCertObito>'
					EndIf
				Endif

				//Numero Processo Trabalhista
				If !Empty(AllTrim(M->RG_NPROC))
					cXml +=			'<nrProcTrab>' + AllTrim(M->RG_NPROC) + '</nrProcTrab>'
				EndIf
				//indicativo ades„o a Programa de Demiss„o Volunt·ria
				If cVersaoEnv >= "9.2" .And. lCpoPDV .And. M->RG_PDV
					cXml +=			'<indPDV>S</indPDV>'
				EndIf
				If cVersaoEnv < "9.0.00"
					//Detalhes Indicador Cumprimento Aviso Previo Parcial
					If !lNT15 .Or. !Empty(cIndAvPrv)
						cXml += "			<indCumprParc>" + AllTrim(cIndAvPrv) + "</indCumprParc>"
					EndIf
					If lIntermit
						cXml += "			<qtdDiasInterm>" + cDiaSV7 + "</qtdDiasInterm>"
					EndIF
				Endif
				If cVersaoEnv >= "9.0.00" .And. lIntermit
					If Len(aDiasConv) > 0
						cXml +=         '<infoInterm>'
						For nC := 1 to Len(aDiasConv)
							cXml +=         '<dia>' + AllTrim(aDiasConv[nC]) + '</dia>'
						Next nC
						cXml +=         '</infoInterm>'
					Endif
				Endif

				If !Empty(AllTrim(M->RG_OBS))
					cXml +=        '<observacoes>'
					cXml +=				'<observacao>' + AllTrim(M->RG_OBS) + '</observacao>'
					cXml +=			'</observacoes>'
				EndIf

				//Sucessao Vinculos
				If !Empty(AllTrim(M->RG_SUCES))
					cXml +=			'<sucessaoVinc>'
					If cVersaoEnv >= "9.0.00"
						cXml +=				'<nrInsc>' + AllTrim(M->RG_SUCES) +'</nrInsc>'
						IF SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInsc>' + AllTrim(M->RG_TPSU) +'</tpInsc>'
						ENDIF
					Else
						cXml +=				'<cnpjSucessora>' + AllTrim(M->RG_SUCES) +'</cnpjSucessora>'
						IF cVersaoEnv >= "2.5.00" .AND. SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInscSuc>' + AllTrim(M->RG_TPSU) +'</tpInscSuc>'
						ENDIF
					Endif
					cXml +=			'</sucessaoVinc>'
				Endif

				//SÛ gera as verbas caso o MV_FASESOC esteja igual a 2 (ManutenÁ„o, N„o PeriÛdicos e PeriÛdicos)
				//Para Servidor Publico e Leiaute 1.0 nao gera
				If lXmlVerbas .And. (cVersaoEnv < "9.0" .Or. nTpRegTrab == 0 )
					If lMiddleware
						fExcRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2299" )
					EndIf

					//Verbas de Rescisao
					cXml += "			<verbasResc>"

					//Looping para varrer as verbas
					cXml += "				<dmDev>"
					If !lMiddleware
						cXml += "					<ideDmDev>" + cIdDmDev + "</ideDmDev>"
					Else
						cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) + "</ideDmDev>"
					Endif
					cXml += "					<infoPerApur>"

					//ValidaÁ„o para verificar se gera o dmDev do Dissidio
					fDis2299( dDataRes, @cVBDiss, aDadosCCT, cIndSimp, @cInfoDiss, @cMsgDiss, @lRJ5Ok, @aErrosRJ5, cTpRes, aPd)
					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						aAdd(aErros, cMsgErro)
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf

					If !Empty(cMsgDiss)
						aAdd(aErros, OemToAnsi( STR0100 ) + " " + OemToAnsi( STR0056 ) ) //"Preenchimento incorreto das tabelas S050/S126. As informaÁıes de dissÌdio n„o foram geradas."#"N„o ser· possÌvel integraÁ„o com o TAF e a efetivaÁ„o da rescis„o."
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf

					If cVersaoEnv >= "9.1.00"
						lTemRRA := fBuscaRRA(cTpRes, cPdRRA,aPD)
					Endif

					//Looping para detalhar os Centros de Custos que o Trab Atuou
					For nZ := 1 To Len( aDadosCCT )
						cXml += "						<ideEstabLot>"
						cXml += "							<tpInsc>" + aDadosCCT[nZ,2] + "</tpInsc>"
						cXml += "							<nrInsc>" + aDadosCCT[nZ,3] + "</nrInsc>"
						If !lMiddleware
							cXml += "							<codLotacao>" + StrTran( aDadosCCT[nZ,4], "&", "&amp;") + "</codLotacao>"
						Else
							cXml += "							<codLotacao>" + Alltrim(StrTran( aDadosCCT[nZ,4], "&", "&amp;")) + "</codLotacao>"
						Endif
						//Looping nas verbas vindas
						For nX := 1 To Len( aCols )
							//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
							If Empty(cVBDiss) .Or. (!( aCols[nX,3] $ cVBDiss ) .And. If(lTemRRA, !( aCols[nX,3] $ cVerbRRA),.T.) )  //Nao leva verbas do dissidio

								//Se n„o houver uso do modelo de deduÁ„o simplificada n„o gera a verba de incidÍncia IR 68
								If !lDedSimpl .And. AllTrim(RetValSrv( aCols[nX,3], SRA->RA_FILIAL, "RV_INCIRF" )) == "68"
									Loop
								EndIf

								//Identifica se gravou verba de incidÍncia IR 68
								If AllTrim(RetValSrv( aCols[nX,3], SRA->RA_FILIAL, "RV_INCIRF" )) == "68"
									lGrvIR68 := .T.
								EndIf

								If( aCols[nX, 12] == aDadosCCT[nZ,1] .AND. aCols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aCols[nX,4] + "</ideTabRubr>"
									cXml += "								<qtdRubr>" + Str(aCols[nX,15]) + "</qtdRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(aCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(aCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(aCols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif

									If cVersaoEnv >= "9.3.00"  .And. aCols[nX,19] == "9253" .And. aCols[nX,21] == "31"     //Natureza .And. RV_INCFGTS
										lEmpECon := .T.
										aEConsig := fBusEConsR(SRA->RA_FILIAL,SRA->RA_MAT, aCols[nX,3],aCols[nX,12], cPeriodo)
										If  Len(aEConsig) > 0
											cXml += '<descFolha>'
											cXml += '	<tpDesc>1</tpDesc>'
											If !Empty(aEConsig[1,5])
												cXml += '	<instFinanc>'+Alltrim(StrZero(Val(aEConsig[1,5]),3))+'</instFinanc>'
											Endif
											If !Empty(aEConsig[1,6])
												cXml += '	<nrDoc>'+ Alltrim(Substr(aEConsig[1,6], 1,15 ) ) +'</nrDoc>'
											Endif
											If !Empty(aEConsig[1,7])
												cXml += '	<observacao>' + Alltrim(aEConsig[1,7]) +'</observacao>'
											Endif
											cXml += '</descFolha>'
										Endif
									Endif

									cXml += "							</detVerbas>"
									If aCols[nX,3] $ cVbPla
										lGerPla := .T.
									EndIf
									If !lRel
										lRetIR := (lVbRelIR .And. fVbRelIR(aCols[nX, 19], ALLTRIM(aCols[nX, 22]))) //Confirma que se trata de verba de IR
										If lMiddleware .And. ( (aCols[nX, 19] == "9901" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9201" .And. aCols[nX, 20] $ "31/32") .Or. (aCols[nX, 19] == "1409" .And. aCols[nX, 20] == "51") .Or. (aCols[nX, 19] == "4050" .And. aCols[nX, 20] == "21") .Or. (aCols[nX, 19] == "4051" .And. aCols[nX, 20] == "22") .Or. (aCols[nX, 19] == "9902" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9904" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9908" .And. aCols[nX, 23] == "3") .Or. lRetIR)
											fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nZ, 2], aDadosCCT[nZ, 3], aDadosCCT[nZ, 4], aCols[nX, 19], aCols[nX, 23], aCols[nX, 20], aCols[nX, 21], aCols[nX, 22], aCols[nX, 17], "S-2299" , , , ,aCols[nX, 24], aCols[nX, 25], cIdDmDev, M->RG_DATAHOM, aCols[nX, 3], RetValSrv(aCols[nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(M->RG_DATAHOM), ,lRetIR )
 										EndIf
									EndIf
								EndIf
							EndIf
						Next

						//Plano de Saude
						If Len(aDadosTRHR) > 0 .And. lGerPla .And. cVersaoEnv < "9.0.00"
							cXml += "							<infoSaudeColet>"
							For nW := 1 To Len(aDadosTRHR)
								cXml += "								<detOper>"
								cXml += "									<cnpjOper>" + aDadosTRHR[nW,6] + "</cnpjOper>"
								cXml += "									<regANS>" + aDadosTRHR[nW,7] + "</regANS>"
								If !lMiddleware
									cXml += "									<vrPgTit>" + AllTrim( Transform(aDadosTRHR[nW,8],"@E 999999999.99") ) + "</vrPgTit>"
								Else
									cXml += "									<vrPgTit>" + AllTrim( Str(aDadosTRHR[nW,8]) ) + "</vrPgTit>"
								EndIf
								If lVer2_3 .And. Len(aDadosDRHR) > 0
									For nD := 1 To Len(aDadosDRHR)
										If ( aDadosTRHR[nW][6] + aDadosTRHR[nW][7] == aDadosDRHR[nD][7] + aDadosDRHR[nD][8] ) // Chave CNPJ Fornecedor + ANS
											cXml += "								<detPlano>"
											cXml += "				                 <tpDep>"+aDadosDRHR[nD,5]+"</tpDep>"
											cXml += "									<cpfDep>" + aDadosDRHR[nD,1] + "</cpfDep>"
											cXml += "									<nmDep>" + aDadosDRHR[nD,2] + "</nmDep>"
											If !lMiddleware
												cXml += "									<dtNascto>" + aDadosDRHR[nD,3] + "</dtNascto>"
											Else
												cXml += "									<dtNascto>" + SubStr( aDadosDRHR[nD,3], 1, 4 ) + "-" + SubStr( aDadosDRHR[nD,3], 5, 2 ) + "-" + SubStr( aDadosDRHR[nD,3], 7, 2 ) + "</dtNascto>"
											EndIf
											If !lMiddleware
												cXml += "									<vlrPgDep>" + AllTrim( Transform(aDadosDRHR[nD,4],"@E 999999999.99") ) + "</vlrPgDep>"
											Else
												cXml += "									<vlrPgDep>" + AllTrim( Str(aDadosDRHR[nD,4]) ) + "</vlrPgDep>"
											EndIf
											cXml += "								</detPlano>"
										Endif
									Next
								EndIf

								cXml += "								</detOper>"
							Next
							cXml += "							</infoSaudeColet>"
							aDadosTRHR := {}
						EndIf

						If SRA->RA_TPPREVI == "1"
							S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
						EndIf
						If !Empty(cIndSimp)
							cXml += "							<infoSimples>"
							cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
							cXml += "							</infoSimples>"
						Endif
						cXml += "						</ideEstabLot>"
					Next

					cXml += "					</infoPerApur>"

					//Transfere para o XML as informaÁıes do Dissidio calculado na rescisao
					If !Empty( cInfoDiss )
						cXml += cInfoDiss
					EndIf

					cXml += "				</dmDev>"

					//ValidaÁ„o para verificar se gera o dmDev do PLR pago antes da rescis„o no mesmo perÌodo
					fPLR2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes, lRel, cPrefixo)

					//ValidaÁ„o para verificar se gera o dmDev de FÈrias pagas no mes da rescis„o
					If cVersaoEnv >= "9.1"
						fFER2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes, lRel, cPrefixo)
					EndIf

					If lTemRRA
						fBuscaIDCMPL(@cCompTrab,dDataRes, @nMesRRA)
						lRetRRA := fRRA2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes,cCompTrab, nMesRRA,cTpRes, aPd)
						//ValidaÁ„o para verificar se gera o dmDev do Dissidio
						If lRetRRA
							fDisRRA2299( dDataRes, @cVBDissRRA, aDadosCCT, cIndSimp, @cInfoRRA, @cMsgDiss, @lRJ5Ok, @aErrosRJ5, cTpRes, , @cDtEfei, @cCompAc)
							//Transfere para o XML as informaÁıes do RRA calculado na rescisao
							If !Empty( cInfoRRA )
								cXml += cInfoRRA
								cXml += "				</dmDev>"
							EndIf
						Endif
					Endif

					//Busca o ˙ltimo perÌodo de pagamento fechamento do roteiro ADI
					nQtdPgto := fQtdNrPag(SRA->RA_PROCES, If(lRetif, AnoMes(M->RG_DATADEM), M->RG_PERIODO), fGetCalcRot("2"))

					//"Processa o adiantamento conforme o tanto
					For nContAdi := 1 To nQtdPgto
						aAdiCC		:= {}
						aAdiCols	:= {}
						aErrosRJ5	:= {}
						cIdDmDev	:= ""
						cSemAdi		:= StrZero(nContAdi,2)

						//ValidaÁ„o para verificar se gera o dmDev do ADI
						fADI2299( @aAdiCC, @aAdiCols, cFilEnv, @cIdDmDev, cVersaoEnv, lRetif, @aErrosRJ5, cPrefixo, , cSemAdi)

						If !Empty(aErrosRJ5)
							aAdd( aErros, OemToAnsi(STR0114) )//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
							For nI := 1 To Len(aErrosRJ5)
								aAdd( aErros, aErrosRJ5[nI] )
							Next
							aAdd( aErros, OemToAnsi(STR0115) ) //" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
							DisarmTransaction()
							lGravou := .F.
							Break
						EndIf

					//Looping para varrer as verbas
					If Len(aAdiCols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						dDtPagto := CTOD("//")
						nPosDmDev := aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev })
						If nPosDmDev > 0
							dDtPagto := STOD(aDtPgtDmDev[nPosDmDev, 4])
						EndIf

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( aAdiCC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + aAdiCC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + aAdiCC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( aAdiCC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( aAdiCC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( aAdiCols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( aAdiCols[nX, 12] == aAdiCC[nZ,1] .AND. aAdiCols[nX, 17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aAdiCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aAdiCols[nX,4] + "</ideTabRubr>"
									cXml += "								<qtdRubr>" + Str(aAdiCols[nX,15]) + "</qtdRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(aAdiCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(aAdiCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(aAdiCols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aAdiCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aAdiCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If !lRel
										lRetIR := (lVbRelIR .And. fVbRelIR(aAdiCols[nX, 21], ALLTRIM(aAdiCols[nX, 24]))) //Confirma que se trata de verba de IR
										If lMiddleware .And. ( (aAdiCols[nX, 21] == "9901" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9201" .And. aAdiCols[nX, 22] $ "31/32") .Or. (aAdiCols[nX, 21] == "1409" .And. aAdiCols[nX, 22] == "51") .Or. (aAdiCols[nX, 21] == "4050" .And. aAdiCols[nX, 22] == "21") .Or. (aAdiCols[nX, 21] == "4051" .And. aAdiCols[nX, 22] == "22") .Or. (aAdiCols[nX, 21] == "9902" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9904" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9908" .And. aAdiCols[nX, 25] == "3") .Or. lRetIR )
											fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aAdiCC[nZ, 2], aAdiCC[nZ, 3], aAdiCC[nZ, 4], aAdiCols[nX, 21], aAdiCols[nX, 25], aAdiCols[nX, 22], aAdiCols[nX, 23], aAdiCols[nX, 24], aAdiCols[nX, 17], "S-2299" , , , , aAdiCols[nX, 26], aAdiCols[nX, 27], cIdDmDev, dDtPagto, aAdiCols[nX, 3], RetValSrv( aAdiCols[nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(dDtPagto),,lRetIR)
										EndIf
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf
				Next nContAdi

					//ValidaÁ„o para verificar se gera o dmDev do 131
					f1312299( @a131CC, @a131Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5, cVersaoEnv, cPrefixo)

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
												lGravou := .F.
						Break
					EndIf

					//Looping para varrer as verbas
					If Len(a131Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a131CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a131CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a131CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a131CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a131CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( a131Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a131Cols[nX, 12] == a131CC[nZ,1] .And. a131Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a131Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a131Cols[nX,4] + "</ideTabRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(a131Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(a131Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(a131Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a131Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a131Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (a131Cols[nX, 21] == "9901" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9201" .And. a131Cols[nX, 22] $ "31/32") .Or. (a131Cols[nX, 21] == "1409" .And. a131Cols[nX, 22] == "51") .Or. (a131Cols[nX, 21] == "4050" .And. a131Cols[nX, 22] == "21") .Or. (a131Cols[nX, 21] == "4051" .And. a131Cols[nX, 22] == "22") .Or. (a131Cols[nX, 21] == "9902" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9904" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9908" .And. a131Cols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a131CC[nZ, 2], a131CC[nZ, 3], a131CC[nZ, 4], a131Cols[nX, 21], a131Cols[nX, 25], a131Cols[nX, 22], a131Cols[nX, 23], a131Cols[nX, 24], a131Cols[nX, 17], "S-2299" , , , ,a131Cols[nX, 26], a131Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					//ValidaÁ„o para verificar se gera o dmDev do 132
					f1322299( @a132CC, @a132Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5,cVersaoEnv, aFilInTaf,lAdmPubl, cTpInsc, cNrInsc, cPrefixo)

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"N„o ser· possÌvel efetuar a integraÁ„o. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" n„o est·(„o) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						lGravou := .F.
						Break
					EndIf

					//Looping para varrer as verbas
					If Len(a132Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						dDtPagto := CTOD("//")
						nPosDmDev := aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev })
						If nPosDmDev > 0
							dDtPagto := STOD(aDtPgtDmDev[nPosDmDev, 4])
						EndIf

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a132CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a132CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a132CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a132CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a132CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( a132Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a132Cols[nX, 12] == a132CC[nZ,1] .And. a132Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a132Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a132Cols[nX,4] + "</ideTabRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(a132Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(a132Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(a132Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a132Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a132Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If !lRel
										lRetIR := (lVbRelIR .And. fVbRelIR(a132Cols[nX, 21], ALLTRIM(a132Cols[nX, 24]))) //Confirma que se trata de verba de IR
										If lMiddleware .And. ( (a132Cols[nX, 21] == "9901" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9201" .And. a132Cols[nX, 22] $ "31/32") .Or. (a132Cols[nX, 21] == "1409" .And. a132Cols[nX, 22] == "51") .Or. (a132Cols[nX, 21] == "4050" .And. a132Cols[nX, 22] == "21") .Or. (a132Cols[nX, 21] == "4051" .And. a132Cols[nX, 22] == "22") .Or. (a132Cols[nX, 21] == "9902" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9904" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9908" .And. a132Cols[nX, 25] == "3") .Or. lRetIR)
											fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a132CC[nZ, 2], a132CC[nZ, 3], a132CC[nZ, 4], a132Cols[nX, 21], a132Cols[nX, 25], a132Cols[nX, 22], a132Cols[nX, 23], a132Cols[nX, 24], a132Cols[nX, 17], "S-2299" , , , ,a132Cols[nX, 26], a132Cols[nX, 27], cIdDmDev, dDtPagto, a132Cols[nX, 3], RetValSrv( a132Cols[nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(dDtPagto),,lRetIR )
										EndIf
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					If M->RG_SEMANA > "01"
						//ValidaÁ„o para verificar se gera o dmDev do FOL
						fFOL2299( @aFolCC, @aFolCols, cFilEnv, @aIdDmDev, cVersaoEnv, lRetif, M->RG_SEMANA, cPrefixo)
						For nContDev := 1 To Len(aIdDmDev)
							//Looping para varrer as verbas
							If Len(aFolCols[nContDev]) > 0
								cXml += "				<dmDev>"
								If !lMiddleware
									cXml += "					<ideDmDev>" + aIdDmDev[nContDev] +  "</ideDmDev>"
								Else
									cXml += "					<ideDmDev>" + Alltrim(aIdDmDev[nContDev] ) +  "</ideDmDev>"
								Endif
								cXml += "					<infoPerApur>"

								dDtPagto := CTOD("//")
								nPosDmDev := aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+SRA->RA_MAT+aIdDmDev[nContDev] })
								If nPosDmDev > 0
									dDtPagto := STOD(aDtPgtDmDev[nPosDmDev, 4])
								EndIf

								//Looping para detalhar os Centros de Custos que o Trab Atuou
								For nZ := 1 To Len( aFolCC[nContDev] )
									cXml += "						<ideEstabLot>"
									cXml += "							<tpInsc>" + aFolCC[nContDev,nZ,2] + "</tpInsc>"
									cXml += "							<nrInsc>" + aFolCC[nContDev,nZ,3] + "</nrInsc>"
									If !lMiddleware
										cXml += "							<codLotacao>" + StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;") + "</codLotacao>"
									Else
										cXml += "							<codLotacao>" + Alltrim(StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;")) + "</codLotacao>"
									Endif
									//Looping nas verbas vindas
									For nX := 1 To Len( aFolCols[nContDev] )
										//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
										If( aFolCols[nContDev,nX, 12] == aFolCC[nContDev,nZ,1] .AND. aFolCols[nContDev,nX,17] > 0 )
											cXml += "							<detVerbas>"
											cXml += "								<codRubr>" + aFolCols[nContDev,nX,3] + "</codRubr>"
											cXml += "								<ideTabRubr>" + aFolCols[nContDev,nX,4] + "</ideTabRubr>"
											cXml += "								<qtdRubr>" + Str(aFolCols[nContDev,nX,15]) + "</qtdRubr>"
											cXml += "								<fatorRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,5],"@E 999999999.99") ) + "</fatorRubr>"
											If cVersaoEnv < "9.0.00"
												If !lMiddleware
													cXml += "								<vrUnit>" + AllTrim( Transform(aFolCols[nContDev,nX,16],"@E 999999999.99") ) + "</vrUnit>"
												Else
													cXml += "								<vrUnit>" + AllTrim( Str(aFolCols[nContDev,nX,16]) ) + "</vrUnit>"
												EndIf
											Endif
											If !lMiddleware
												cXml += "								<vrRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,17],"@E 999999999.99") ) + "</vrRubr>"
											Else
												cXml += "								<vrRubr>" + AllTrim( Str(aFolCols[nContDev,nX,17]) ) + "</vrRubr>"
											EndIf
											If cVersaoEnv >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
												cXml +=         '<indApurIR>0</indApurIR>'
											Endif
											cXml += "							</detVerbas>"
											If !lRel
												lRetIR := (lVbRelIR .And. fVbRelIR(aFolCols[nContDev, nX, 21], ALLTRIM(aFolCols[nContDev, nX, 24]))) //Confirma que se trata de verba de IR
												If lMiddleware .And. ( (aFolCols[nContDev, nX, 21] == "9901" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9201" .And. aFolCols[nContDev, nX, 22] $ "31/32") .Or. (aFolCols[nContDev, nX, 21] == "1409" .And. aFolCols[nContDev, nX, 22] == "51") .Or. (aFolCols[nContDev, nX, 21] == "4050" .And. aFolCols[nContDev, nX, 22] == "21") .Or. (aFolCols[nContDev, nX, 21] == "4051" .And. aFolCols[nContDev, nX, 22] == "22") .Or. (aFolCols[nContDev, nX, 21] == "9902" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9904" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9908" .And. aFolCols[nContDev, nX, 25] == "3") .Or. lRetIR)
													fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aFolCC[nContDev, nZ, 2], aFolCC[nContDev, nZ, 3], aFolCC[nContDev, nZ, 4], aFolCols[nContDev, nX, 21], aFolCols[nContDev, nX, 25], aFolCols[nContDev, nX, 22], aFolCols[nContDev, nX, 23], aFolCols[nContDev, nX, 24], aFolCols[nContDev, nX, 17], "S-2299" , , , ,aFolCols[nContDev, nX, 26], aFolCols[nContDev, nX, 27], aIdDmDev[nContDev], dDtPagto, aFolCols[nContDev, nX, 3], RetValSrv( aFolCols[nContDev, nX, 3], SRA->RA_FILIAL, "RV_CODFOL" ), anomes(dDtPagto),,lRetIR)
												EndIf
											EndIf
										EndIf
									Next

									If SRA->RA_TPPREVI == "1"
										S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
									EndIf
									If !Empty(cIndSimp)
										cXml += "							<infoSimples>"
										cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
										cXml += "							</infoSimples>"
									Endif
									cXml += "						</ideEstabLot>"
								Next

								cXml += "					</infoPerApur>"
								cXml += "				</dmDev>"
							EndIf
						Next nContDev
					EndIf

					//InformaÁıes Multiplos Vinculos
					If ( Len( aDadosRAZ ) > 0 )
						cXml += "				<infoMV>"
						cXml += "					<indMV>" + aDadosRAZ[1,5] + "</indMV>"

						For nX := 1 To Len( aDadosRAZ )
							cXml += "					<remunOutrEmpr>"
							cXml += "						<tpInsc>" + aDadosRAZ[nX,9] + "</tpInsc>"
							cXml += "						<nrInsc>" + aDadosRAZ[nX,10] + "</nrInsc>"
							cXml += "						<codCateg>" + aDadosRAZ[nX,12] + "</codCateg>"
							cXml += "						<vlrRemunOE>" + AllTrim( Transform(aDadosRAZ[nX,11],"@E 999999999.99") ) + "</vlrRemunOE>"
							cXml += "					</remunOutrEmpr>"
						Next
						cXml += "				</infoMV>"
					EndIf
					If cVersaoEnv >= "2.4.02" .And. SRG->(ColumnPos("RG_NPROCS")) > 0 .And. !Empty(M->RG_NPROCS)
						cXml += "<procCS>"
						cXml += "   <nrProcJud>"+M->RG_NPROCS+"</nrProcJud>"
						cXml += "</procCS>"
					EndIf
					cXml += "			</verbasResc>"
				Endif
				If cVersaoEnv >= '2.4' .And. (Len(aPd_Aux) > 0 .Or. (cVersaoEnv < "2.4.02"  .And. Len(aPd_Aux) == 0 ))
					cXml += "           <consigFGTS>"
					IF Len(aPd_Aux) > 0
						If fBuscConsig(aPd_Aux)
							If cVersaoEnv <= "2.4
								cXml += "             <idConsig>S</idConsig>"
							EndIf
							cXml += "               <insConsig>" + Alltrim(SRK->RK_BCOCONS )+ "</insConsig>"
							cXml += "               <nrContr>" + Alltrim(SRK->RK_NRCONTR) + "</nrContr>"
						EndIf
					EndIf
					If cVersaoEnv < "2.4.02"  .And. (Len(aPd_Aux) == 0 .Or. !("idConsig" $ cXml))
						cXml += "               <idConsig>N</idConsig>"
					EndIf
					cXml += "           </consigFGTS>"
				EndIf

				//Fechamentos de Tags
				cXml += "		</infoDeslig>"
				cXml += "	</evtDeslig>"
				cXml += "</eSocial>"
				//-------------------
				//| Final do XML
				//-------------------
			EndIf
		Else
			If !lMiddleware
				If !Empty(SRA->RA_CODUNIC)
					cMatricula := StrTran(SRA->RA_CODUNIC, "&","&#38;" )
				EndIf
				InExc3000(@cXml,'S-2299',(SRA->RA_CIC+cMatricula),SRA->RA_CIC,SRA->RA_PIS,,)
			Else
				cStatNew := ""
				cOperNew := ""
				cRetfNew := ""
				cRecibAnt:= ""
				cKeyMid	 := ""
				nRecEvt	 := 0
				lNovoRJE := .T.
				aDados	 := {}
				aInfos   := fXMLInfos()
				If Len(aInfos) >= 4
					cTpInsc  := aInfos[1]
					lAdmPubl := aInfos[4]
					cNrInsc  := aInfos[2]
					cId  	 := aInfos[3]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStat2299 	:= "-1"
				GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt, Nil, Nil, .T. )
				If cStat2299 == "2"
					aAdd(aErrosExc, STR0134)//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
				ElseIf cStat2299 == "99"
					aAdd(aErrosExc, STR0146)//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o pendente para transmiss„o"
				Else
					InExc3000(@cXml,'S-2299',cRecib2299,SRA->RA_CIC,SRA->RA_PIS, Nil, Nil, Nil, Nil, cFilAnt, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
					fExcRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2299" )
				EndIf
			EndIf
		EndIf

		If !lRel
			GrvTxtArq(alltrim(cXml), If(nOperation <> 5, "S2299", "S3000"), SRA->RA_CIC)
		EndIf

		IF lRel .And. nOperation <> 5
			//Busca a descriÁ„o do motivo de desligamento eSocial
			If Len(aIncRes) > 21
				nPosS056 := fPosTab("S056", aIncRes[22] , "=", 4 )
				If nPosS056 > 0
					//cDescMtv := Capital(Alltrim(fTabela("S056", nPosS056 , 5)))
					cDescMtv := Alltrim(fTabela("S056", nPosS056 , 5))
				EndIf
			EndIf

			//Cria array de inconsistÍncia para impress„o do relatÛrio
			For nX := 1 To Len(aErros)
				aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, aErros[nX]})
			Next nX

			//Executa a funÁ„o para criaÁ„o do relatÛrio excel
			fGeraRelat(alltrim(cXml), cDtEfei, cCompAc, cDescMtv, M->RG_DATADEM, aIncRel)

			cDescMtv := ""
		Endif

		If !lMiddleware
			fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
		EndIf

		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
		aErros := {} //Limpa o campo de erro que foi utilizado acima na validaÁ„o das verbas
		If lMiddleware .And. nOperation == 5
			aErros := aClone(aErrosExc)
		EndIf

		If !lRel
			if nOperation <> 5
				If !lMiddleware
					If ValType(cTafKey) == "C"
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2299", , "", , , , "GPE", , "" )
					Else
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2299")
					EndIf
				Else
					//ValidaÁ„o de predecessores
					If cEFDAviso != "2"
						//S-1005
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aDadosCCT, lAdmPubl, cTpInsc, cNrInsc)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aAdiCC, lAdmPubl, cTpInsc, cNrInsc)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, a131CC, lAdmPubl, cTpInsc, cNrInsc)
						For nCont := 1 To Len(aFolCC)
							fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aFolCC[nCont], lAdmPubl, cTpInsc, cNrInsc)
						Next nCont

						//S-1010
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aCols, lAdmPubl, cTpInsc, cNrInsc)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aAdiCols, lAdmPubl, cTpInsc, cNrInsc)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, a131Cols, lAdmPubl, cTpInsc, cNrInsc)
						For nCont := 1 To Len(aFolCols)
							fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aFolCols[nCont], lAdmPubl, cTpInsc, cNrInsc)
						Next nCont

						//S-1020
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aDadosCCT, lAdmPubl, cTpInsc, cNrInsc)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aAdiCC, lAdmPubl, cTpInsc, cNrInsc)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, a131CC, lAdmPubl, cTpInsc, cNrInsc)
						For nCont := 1 To Len(aFolCC)
							fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aFolCC[nCont], lAdmPubl, cTpInsc, cNrInsc)
						Next nCont
					EndIf
					If cEFDAviso $ "0/2" .Or. (lS1005 .And. lS1010 .And. lS1020)
						For nI := 1 To Len(aErros)
							cMsgHlp += aErros[nI] + CRLF
						Next
						If !Empty(cMsgHlp) .And. cEFDAviso == "0"
							Help( ,, OemToAnsi(STR0001) ,, cMsgHlp, 1, 0 )
						EndIf
						If !( nOperation == 5 .And. ((cOper2299 == "E" .And. cStat2299 == "4") .Or. cStat2299 $ "-1/1/3") )
							If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2299 ))
								aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
								DisarmTransaction()
							EndIf
						//Se for uma exclus„o e n„o for de registro de exclus„o transmitido, exclui registro de exclus„o na fila
						ElseIf nOperation == 5 .And. cStat2299 != "-1" .And. !(cOper2299 == "E" .And. cStat2299 == "4")
							If !( lRet := fExcluiRJE( nRecRJE ) )
								aAdd( aErros, OemToAnsi(STR0138) )//"Ocorreu um erro na exclus„o do registro na tabela RJE"
								DisarmTransaction()
							EndIf
						EndIf
					ElseIf cEFDAviso == "1"
						For nI := 1 To Len(aErros)
							cMsgHlp += aErros[nI] + CRLF
						Next
						aErros[1] := cMsgHlp
						aSize(aErros, 1)
						DisarmTransaction()
					EndIf
				EndIf
			Else
				If !lMiddleware
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
				ElseIf Len(aErros) == 0
					If cStat2299 != "4"
						If !( lRet := fExcluiRJE( nRec2299 ) )
							aAdd( aErros, STR0138 )//"Ocorreu um erro na exclus„o do registro na tabela RJE"
							DisarmTransaction()
						EndIf
					Else
						aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecib2299, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
						If !( lRet := fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
							aAdd( aErros, STR0138 )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
							DisarmTransaction()
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	End Transaction

	If !lRel .And. lGravou
		If Len(aErros) > 0
			FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
			lGravou:= IIF(aErros[1]!='000026',.F.,.T.)

			if aErros[1]=='000026'
				ADEL(aErros, 1)
				ASIZE(aErros,0)
				fEFDMsgErro(cMsgErro)
			Else
				aErros[1]:= cMsgErro
			EndIf

			//SÛ exibe a mensagem se for Rescis„o Simples
			If( cTpRes == "1"  .And. Len(aErros) > 0)
				If !lMiddleware
					Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + CRLF + cMsgErro,1,0)//" n„o enviado(a) ao TAF. Erro: "
				Else
					Help(,,OemToAnsi(STR0001), ,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgErro,1,0)//" n„o enviado(a) ao Middleware. Erro: "
				EndIf
			EndIf
		ElseIf nOperation <> 5 .And. !lCPFDepOk
			cMsgErro := STR0106//"O(s) dependente(s)/agregado(s) de plano de sa˙de abaixo n„o tem CPF cadastrado:"
			For nX := 1 To Len(aDepAgreg)
				cMsgErro += CRLF + aDepAgreg[nX]
			Next nX
			If cTpRes == "1"
				Aviso( OemtoAnsi(STR0001) , cMsgErro,	{ STR0038 } )
			Else
				aAdd(aErros, cMsgErro)
			EndIf
		Endif
	EndIf

	RestArea( aAreaSM0 )
	RestArea(aArea)

	// Reinicializa a vari·vel Est·tica nContRes
	nContRes := 0

Return lGravou

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥GetAssMed       ∫Autor ≥Marcos Coutinho≥ Data ≥  25/05/17   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Obtem os valores de Assistencia Medica                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPEM026C                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function GetAssMed( cFil, cMat, cTab, cFilRCC, cQual, cComp, cTabR )
Local cGetAlias  := ""
Local cRHSAlias  := GetNextAlias()
Local cChave     := ""
Local nSomaTotal := 0
Local nBusca     := 0
Local aDados     := {}

Default cFilRCC := "        "
Default cQual   := " "

cGetAlias  := GetNextAlias()

If cQual == "T"

    If cTabR == "RHR" //c·lculo do plano de sa˙de aberto
		BeginSql Alias cGetAlias
				SELECT
					RHR_FILIAL,
					RHR_MAT,
					RHR_CODFOR,
					RHR_PD,
					RHR_CODIGO,
					RHR_ORIGEM,
					RHR_TPLAN,
					RHR_TPFORN,
					RHR_VLRFUN,
					RHR_COMPPG,
					RCC_CONTEU,
					RCC_FIL,
					RCC_FILIAL
				 FROM
					%Table:RHR% RHR
				JOIN
					%Table:RCC% RCC
				ON
					RHR_CODFOR = SUBSTRING(RCC_CONTEU,1,3)
				WHERE
					RHR_FILIAL = %Exp:( cFil )% AND
					RHR_MAT = %Exp:( cMat )% AND
					RHR_COMPPG = %Exp:( cComp )% AND
					RCC.RCC_CODIGO = ( CASE WHEN RHR.RHR_TPFORN = '1' THEN 'S016' WHEN RHR.RHR_TPFORN = '2' THEN 'S017' END ) AND
					(RCC.RCC_FIL = ' ' OR RCC_FILIAL = %Exp:( cFilRCC )% ) AND
					RHR_ORIGEM = '1' AND //titular
					RHR_TPLAN = '1' OR RHR_TPLAN = '2'  AND //plano ou co-paticipacao
					RCC.%NotDel% AND
					RHR.%NotDel%
				GROUP BY
					RHR_FILIAL, RHR_MAT, RHR_CODFOR, RHR_PD, RHR_CODIGO, RHR_ORIGEM, RHR_TPLAN, RHR_TPFORN, RHR_VLRFUN, RHR_COMPPG, RCC_CONTEU, RCC_FIL, RCC_FILIAL
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RHR_FILIAL + (cGetAlias)->RHR_MAT + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 )
		   nBusca := Ascan( @aDados,{|X| X[1]+X[2]+X[3]+X[4] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 5] += (cGetAlias)->RHR_VLRFUN
	  	   Else
	  	       aAdd(aDados, { (cGetAlias)->RHR_FILIAL ,;	//Filial da RHR - Plano de Saude
				    		     (cGetAlias)->RHR_MAT		,; //Matric da RHR - Plano de ADMSaude
						  	     Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
							     Substr( (cGetAlias)->RCC_CONTEU, 168,6 )  ,; // ANS Fornecedor
							     (cGetAlias)->RHR_VLRFUN	 })
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
   Else //c·lculo do plano de sa˙de fechado
		BeginSql Alias cGetAlias
				SELECT
					RHS_FILIAL,
					RHS_MAT,
					RHS_CODFOR,
					RHS_PD,
					RHS_CODIGO,
					RHS_ORIGEM,
					RHS_TPLAN,
					RHS_TPFORN,
					RHS_VLRFUN,
					RHS_COMPPG,
					RCC_CONTEU,
					RCC_FIL,
					RCC_FILIAL
				 FROM
					%Table:RHS% RHS
				JOIN
					%Table:RCC% RCC
				ON
					RHS_CODFOR = SUBSTRING(RCC_CONTEU,1,3)
				WHERE
					RHS_FILIAL = %Exp:( cFil )% AND
					RHS_MAT = %Exp:( cMat )% AND
					RCC.RCC_CODIGO = ( CASE WHEN RHS.RHS_TPFORN = '1' THEN 'S016' WHEN RHS.RHS_TPFORN = '2' THEN 'S017' END ) AND
					(RCC.RCC_FIL = ' ' OR RCC_FILIAL = %Exp:( cFilRCC )% ) AND
					RHS_COMPPG = %Exp:( cComp )% AND
					RHS_ORIGEM = '1' AND //titular
					RHS_TPLAN = '1' OR RHS_TPLAN = '2'  AND //plano ou co-paticipacao
					RCC.%NotDel% AND
					RHS.%NotDel%
				GROUP BY
					RHS_FILIAL, RHS_MAT, RHS_CODFOR, RHS_PD, RHS_CODIGO, RHS_ORIGEM, RHS_TPLAN, RHS_TPFORN, RHS_VLRFUN, RHS_COMPPG, RCC_CONTEU, RCC_FIL, RCC_FILIAL
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RHS_FILIAL + (cGetAlias)->RHS_MAT + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 )
		   nBusca := Ascan( @aDados,{|X| X[1]+X[2]+X[3]+X[4] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 5] += (cGetAlias)->RHS_VLRFUN
	  	   Else
	  	       aAdd(aDados, { (cGetAlias)->RHS_FILIAL ,;	//Filial da RHS - Plano de Saude
				    		     (cGetAlias)->RHS_MAT		,; //Matric da RHS - Plano de ADMSaude
						  	     Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
							     Substr( (cGetAlias)->RCC_CONTEU, 168,6 )  ,; // ANS Fornecedor
							     (cGetAlias)->RHS_VLRFUN	 })
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
    EndIf
Else
    If cTabR == "RHR" //c·lculo do plano de sa˙de aberto
		BeginSql Alias cGetAlias
				SELECT
					SRB.RB_NOME,
					SRB.RB_DTNASC,
					SRB.RB_CIC,
					SRB.RB_TPDEP,
					RHR.RHR_FILIAL,
					RHR.RHR_MAT,
					RHR.RHR_CODIGO,
					RHR.RHR_ORIGEM,
					RHR.RHR_TPLAN,
					RHR.RHR_COMPPG,
					RHR.RHR_VLRFUN
			    FROM
					%Table:RHR% RHR
				JOIN
					%Table:SRB% SRB
				ON
					RHR.RHR_FILIAL = SRB.RB_FILIAL AND
					RHR.RHR_MAT    = SRB.RB_MAT    AND
					RHR.RHR_CODIGO = SRB.RB_COD //sequencia do dependente
				WHERE
					RHR.RHR_FILIAL     = %Exp:( cFil )% AND
					RHR.RHR_MAT        = %Exp:( cMat )% AND
					RHR.RHR_COMPPG     = %Exp:( cComp )% AND
					RHR.RHR_ORIGEM     IN ('2', '3')	AND //apenas dependentes e agregados
					RHR.RHR_TPLAN = '1' OR RHR.RHR_TPLAN = '2'  AND //plano ou co-paticipacao
					RHR.%NotDel%  AND
					SRB.%NotDel%
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RB_CIC
		   nBusca := Ascan( @aDados,{|X| X[1] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 4] += (cGetAlias)->RHR_VLRFUN
	      Else
	  	       aAdd(aDados, { (cGetAlias)->RB_CIC ,;
				    		     (cGetAlias)->RB_NOME,;
				    		     (cGetAlias)->RB_DTNASC,;
				    		     (cGetAlias)->RHR_VLRFUN,;
							     (cGetAlias)->RB_TPDEP})
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
    Else //c·lculo do plano de sa˙de fechado
		BeginSql Alias cGetAlias
				SELECT
					SRB.RB_NOME,
					SRB.RB_DTNASC,
					SRB.RB_CIC,
					SRB.RB_TPDEP,
					RHS.RHS_FILIAL,
					RHS.RHS_MAT,
					RHS.RHS_CODIGO,
					RHS.RHS_ORIGEM,
					RHS.RHS_TPLAN,
					RHS.RHS_COMPPG,
					RHS.RHS_VLRFUN
			    FROM
					%Table:RHS% RHS
				JOIN
					%Table:SRB% SRB
				ON
					RHS.RHS_FILIAL = SRB.RB_FILIAL AND
					RHS.RHS_MAT    = SRB.RB_MAT    AND
					RHS.RHS_CODIGO = SRB.RB_COD //sequencia do dependente
				WHERE
					RHS.RHS_FILIAL     = %Exp:( cFil )% AND
					RHS.RHS_MAT        = %Exp:( cMat )% AND
					RHS.RHS_COMPPG     = %Exp:( cComp )% AND
					RHS.RHS_ORIGEM     IN ('2','3')     AND //apenas dependentes e agregados
					RHS.RHS_TPLAN = '1' OR RHS.RHS_TPLAN = '2'  AND //plano ou co-paticipacao
					RHS.%NotDel%             AND
					SRB.%NotDel%
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RB_CIC
		   nBusca := Ascan( @aDados,{|X| X[1] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 4] += (cGetAlias)->RHS_VLRFUN
	      Else
	  	       aAdd(aDados, { (cGetAlias)->RB_CIC ,;
				    		     (cGetAlias)->RB_NOME,;
				    		     (cGetAlias)->RB_DTNASC,;
				    		     (cGetAlias)->RHS_VLRFUN,;
							     (cGetAlias)->RB_TPDEP})
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
    EndIf
EndIf
( cGetAlias )->( dbCloseArea() )

Return aDados

Function GetRAssMed( cFil, cMat, cTab, cVersao, cPer, aDadosTRHR, aDadosDRHR, cTabRH, lCPFDepOk, aDepAgreg )
Local cGetAlias  := ""
Local cRHRAlias  := GetNextAlias()
Local nSomaTotal := 0
Local nPos			:= 0
Local nX			:= 0
Local cCposSel		:= ""
Local cCposRHP		:= ""
Local cCposWhere	:= ""
Local cWhereRHP		:= ""
Local cCposGroup	:= ""
Local cGroupRHP		:= ""
Local cCposJoin		:= ""
Local cJoinRHP		:= ""
Local cTableFrom	:= ""
Local cTableRHP		:= ""
Local aTRHRBkp		:= {}

Default cTabRH		:= "RHR"
Default lCPFDepOk	:= .T.
Default aDepAgreg	:= {}

cTableFrom := "%" + RetFullName(cTabRH, cEmpAnt) + "%"
cTableRHP  := "%" + RetFullName("RHP", cEmpAnt) + "%"

cGetAlias := GetNextAlias()

cCposSel := "%"
cCposSel += cTabRH + "_FILIAL RHR_FILIAL, "
cCposSel += cTabRH + "_MAT RHR_MAT, "
cCposSel += cTabRH + "_CODFOR RHR_CODFOR, "
cCposSel += cTabRH + "_PD RHR_PD, "
cCposSel += cTabRH + "_CODIGO RHR_CODIGO, "
cCposSel += cTabRH + "_TPLAN RHR_TPLAN, "
cCposSel += cTabRH + "_ORIGEM RHR_ORIGEM, "
cCposSel += cTabRH + "_COMPPG RHR_COMPPG, "
cCposSel += cTabRH + "_TPFORN RHR_TPFORN, "
cCposSel += "SUM(" + cTabRH + "_VLRFUN) TOTAL, "
cCposSel += "RCC_CONTEU"
cCposSel += "%"

cCposWhere := "%"
cCposWhere += cTabRH + "_FILIAL = '" + xFilial(cTabRH, cFil) + "' AND "
cCposWhere += cTabRH + "_MAT = '" + cMat + "' AND "
cCposWhere += cTabRH + "_TPLAN IN ('1', '2') AND "
cCposWhere += cTabRH + "_COMPPG = '" + cPer + "' AND "
cCposWhere += "RCC.RCC_FILIAL = '" + xFilial('RCC', cFil) + "' AND "
cCposWhere += "(RCC.RCC_FIL = '' OR RCC.RCC_FIL = " + cTabRH + "_FILIAL) AND "
cCposWhere += "RCC.RCC_CODIGO = ( CASE WHEN RHR."+cTabRH+"_TPFORN = '1' THEN 'S016' WHEN RHR."+cTabRH+"_TPFORN = '2' THEN 'S017' END )"
cCposWhere += "%"

cCposGroup := "%"
cCposGroup += cTabRH + "_FILIAL, " + cTabRH + "_MAT, " + cTabRH + "_CODFOR, " + cTabRH + "_PD, "
cCposGroup += cTabRH + "_CODIGO, " + cTabRH + "_TPLAN, " + cTabRH + "_ORIGEM, " + cTabRH + "_COMPPG, "
cCposGroup += cTabRH + "_TPFORN, RCC_CONTEU "
cCposGroup += "%"

cCposJoin := "%"
cCposJoin += cTabRH + "_CODFOR = SUBSTRING(RCC_CONTEU,1,3)"
cCposJoin += "%"

cCposRHP := "%"
cCposRHP += "RHP_FILIAL RHR_FILIAL, "
cCposRHP += "RHP_MAT RHR_MAT, "
cCposRHP += "RHP_CODFOR RHR_CODFOR, "
cCposRHP += "RHP_PD RHR_PD, "
cCposRHP += "RHP_CODIGO RHR_CODIGO, "
cCposRHP += "RHP_TPLAN RHR_TPLAN, "
cCposRHP += "RHP_ORIGEM RHR_ORIGEM, "
cCposRHP += "RHP_COMPPG RHR_COMPPG, "
cCposRHP += "RHP_TPFORN RHR_TPFORN, "
cCposRHP += "SUM(RHP_VLRFUN) TOTAL, "
cCposRHP += "RCC_CONTEU"
cCposRHP += "%"

cWhereRHP := "%"
cWhereRHP += "RHP_FILIAL = '" + xFilial('RHP', cFil) + "' AND "
cWhereRHP += "RHP_MAT = '" + cMat + "' AND "
cWhereRHP += "RHP_TPLAN IN ('1', '2') AND "
cWhereRHP += "RHP_COMPPG = '" + cPer + "' AND "
cWhereRHP += "RCC.RCC_FILIAL = '" + xFilial('RCC', cFil) + "' AND "
cWhereRHP += "(RCC.RCC_FIL = '' OR RCC.RCC_FIL = RHP_FILIAL) AND "
cWhereRHP += "RCC.RCC_CODIGO = ( CASE WHEN RHP.RHP_TPFORN = '1' THEN 'S016' WHEN RHP.RHP_TPFORN = '2' THEN 'S017' END )"
cWhereRHP += "%"

cGroupRHP := "%"
cGroupRHP += "RHP_FILIAL, RHP_MAT, RHP_CODFOR, RHP_PD, "
cGroupRHP += "RHP_CODIGO, RHP_TPLAN, RHP_ORIGEM, RHP_COMPPG, "
cGroupRHP += "RHP_TPFORN, RCC_CONTEU "
cGroupRHP += "%"

cJoinRHP := "%"
cJoinRHP += "RHP_CODFOR = SUBSTRING(RCC_CONTEU,1,3)"
cJoinRHP += "%"

If cTabRH == "RHR"
	BeginSql Alias cGetAlias
		SELECT
			%exp:cCposSel%
		 FROM
			%exp:cTableFrom% RHR
		JOIN
			%Table:RCC% RCC
		ON
			%exp:cCposJoin%
		WHERE
			%exp:cCposWhere% AND
			RCC.%NotDel% AND
			RHR.%NotDel%
		GROUP BY
			%exp:cCposGroup%
	EndSql
Else
	BeginSql Alias cGetAlias
				SELECT
			%exp:cCposSel%
			    FROM
			%exp:cTableFrom% RHR
				JOIN
			%Table:RCC% RCC
				ON
			%exp:cCposJoin%
				WHERE
			%exp:cCposWhere% AND
			RCC.%NotDel% AND
			RHR.%NotDel%
		GROUP BY
			%exp:cCposGroup%
		UNION ALL
		SELECT
			%exp:cCposRHP%
		 FROM
			%exp:cTableRHP% RHP
		JOIN
			%Table:RCC% RCC
		ON
			%exp:cJoinRHP%
		WHERE
			%exp:cWhereRHP% AND
			RCC.%NotDel% AND
			RHP.%NotDel%
		GROUP BY
			%exp:cGroupRHP%
	EndSql
EndIf

	While ( (cGetAlias)->( !Eof() ) )

	//TITULAR
	if (cGetAlias)->RHR_ORIGEM == "1"
		nPos := ascan(aDadosTRHR,{|X| X[6]+x[7] == Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 ) })
		  If nPos == 0
			aAdd(aDadosTRHR, { 	(cGetAlias)->RHR_FILIAL ,;	// 1 - Filial da RHR - Plano de Saude
										(cGetAlias)->RHR_MAT		,; // 2 - Matric da RHR - Plano de Saude
										(cGetAlias)->RHR_CODFOR	,; // 3 - CodFor da RHR - Plano de Saude
										(cGetAlias)->RHR_PD		,; // 4 - Verba  da RHR - Plano de Saude
										(cGetAlias)->RHR_CODIGO	,; // 5 - Depend da RHR - Plano de Saude
										Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //6 - CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168,6 )  ,; // 7 - ANS Fornecedor
										(cGetAlias)->TOTAL	})
		  Else
			If Empty((cGetAlias)->RHR_CODIGO)
				aDadosTRHR[nPos,8] += (cGetAlias)->TOTAL
			EndIf
		  EndIf
	//DEPENDENTE
	Elseif (cGetAlias)->RHR_ORIGEM == "2"
		DbSelectArea('SRB')
		If (cGetAlias)->TOTAL > 0 .And. SRB->(DBSeek((cGetAlias)->RHR_FILIAL + (cGetAlias)->RHR_MAT + (cGetAlias)->RHR_CODIGO))
			nPos := ascan(aDadosDRHR,{|X| X[6]+x[7]+x[8]+x[9]  == SRB->(RB_COD) + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 ) + (cGetAlias)->RHR_ORIGEM })
			If cVersao >= "2.5.00" .And. Empty(SRB->RB_CIC)
				lCPFDepOk := .F.
				If aScan(aDepAgreg, { |x| x == SRB->RB_NOME }) == 0
					aAdd( aDepAgreg, SRB->RB_NOME )
				EndIf
			EndIf
	   		If nPos == 0
				AAdd ( aDadosDRHR, { SRB->(RB_CIC),;
										SRB->(RB_NOME),;
										DtoS(SRB->(RB_DTNASC)), ;
										(cGetAlias)->TOTAL,;
										fTpDep(Alltrim(SRB->(RB_TPDEP)),cVersao),;
										SRB->(RB_COD),;
									Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168,6 ),; //ANS Fornecedor
										(cGetAlias)->RHR_ORIGEM  } )  //Origem (1-Titular,2-Dependente,3-Agregado)
	  		Else
				aDadosDRHR[nPos,4] += (cGetAlias)->TOTAL
		  	EndIf
		Endif
	//AGREGADO
	Elseif (cGetAlias)->RHR_ORIGEM == "3"
		DbSelectArea('RHM')
		If (cGetAlias)->TOTAL > 0 .And. RHM->(DBSeek((cGetAlias)->RHR_FILIAL + (cGetAlias)->RHR_MAT + (cGetAlias)->RHR_TPFORN + (cGetAlias)->RHR_CODFOR + (cGetAlias)->RHR_CODIGO ))
			nPos := ascan(aDadosDRHR,{|X| X[6]+x[7]+x[8]+x[9]  == RHM->(RHM_CODIGO) + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 ) + (cGetAlias)->RHR_ORIGEM })
			If cVersao >= "2.5.00" .And. Empty(RHM->RHM_CPF)
				lCPFDepOk := .F.
				If aScan(aDepAgreg, { |x| x == RHM->RHM_NOME }) == 0
					aAdd( aDepAgreg, RHM->RHM_NOME )
				EndIf
			EndIf
			If nPos == 0
				AAdd ( aDadosDRHR, { RHM->(RHM_CPF),;
										RHM->(RHM_NOME),;
										DtoS(RHM->(RHM_DTNASC)), ;
										(cGetAlias)->TOTAL,;
										fTpDep("13",cVersao),;
										RHM->(RHM_CODIGO),;
										Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168,6 ),; //ANS Fornecedor
										(cGetAlias)->RHR_ORIGEM  } ) //Origem (1-Titular,2-Dependente,3-Agregado)
			Else
				aDadosDRHR[nPos,4] += (cGetAlias)->TOTAL
	  		EndIf
		Endif
	Endif

	  ( cGetAlias )->(DbSkip())
  EndDo
  ( cGetAlias )->( dbCloseArea() )

For nX := 1 To Len( aDadosTRHR )
	If aDadosTRHR[nX, 8] > 0 .Or. aDadosTRHR[nX, 8] == 0 .And. aScan( aDadosDRHR, { |x| x[7]+x[8] == aDadosTRHR[nX, 6]+aDadosTRHR[nX, 7] } ) > 0
		aAdd( aTRHRBkp, aClone(aDadosTRHR[nX]) )
	EndIf
Next nX

aDadosTRHR := aClone(aTRHRBkp)

Return





/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥GetMulVin       ∫Autor ≥Marcos Coutinho≥ Data ≥  25/05/17   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Obtem os Valores de Multiplos Vinculos do Funcionario       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPEM026C                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function GetMulVin( cFil, cMat, cPer , lRes132 )

Local cGetAlias  := ""
Local nSomaTotal := 0
Local aDados := {}
Local nPos132	:= 0
Local nPosRes	:= 0
Local cStat1200 := -1

DEFAULT lRes132 := .F.

	cGetAlias  := GetNextAlias()

	BeginSql Alias cGetAlias
		SELECT
			RAW_FILIAL,
			RAW_MAT,
			RAW_FOLMES,
			RAW_TPFOL,
			RAW_TPREC,
			RAW_PROCES,
			RAW_SEMANA,
			RAW_ROTEIR,
			RAZ_TPINS,
			RAZ_INSCR,
			RAZ_VALOR,
			RAZ_CATEG
		FROM
			%Table:RAW% AW
		JOIN
			%Table:RAZ% AZ
		ON
			AW.RAW_FILIAL = AZ.RAZ_FILIAL AND
			AW.RAW_MAT = AZ.RAZ_MAT AND
			AW.RAW_FOLMES = AZ.RAZ_FOLMES AND
			AW.RAW_TPFOL = AZ.RAZ_TPFOL
		WHERE
			AW.RAW_FILIAL = %Exp:( cFil )% AND
			AW.RAW_MAT = %Exp:( cMat )% AND
			AW.RAW_FOLMES = %Exp:( cPer )% AND
			AW.%NotDel% AND
			AZ.%NotDel%
	EndSql



	While ( (cGetAlias)->( !Eof() ) )


		aAdd(aDados, { 	(cGetAlias)->RAW_FILIAL ,;	//Filial Funcionario
								(cGetAlias)->RAW_MAT		,; //Matricula Funcionario
								(cGetAlias)->RAW_FOLMES	,; //Periodo de Apuracao
								(cGetAlias)->RAW_TPFOL	,; //Tipo da Folha
								(cGetAlias)->RAW_TPREC	,; //Tipo de Recolhimento
								(cGetAlias)->RAW_PROCES	,; //Codigo do Processo
								(cGetAlias)->RAW_SEMANA	,; //Numero de pagemento
								(cGetAlias)->RAW_ROTEIR	,; //Roteiro
								(cGetAlias)->RAZ_TPINS	,; //Tipo de Inscricao (CNPJ / CPF)
								(cGetAlias)->RAZ_INSCR	,; //Valor da Inscricao (N CPF ou CNPJ)
								(cGetAlias)->RAZ_VALOR	,; //Valor Pago
								(cGetAlias)->RAZ_CATEG	}) //Categoria eSocial
		DbSkip()
	EndDo

	( cGetAlias )->( dbCloseArea() )

	// Verifica se S-1200 de 13∫ foi enviado
	nPos132 := aScan(aDados, {|x| x[8] == "132" .And. x[3] == cPeriodo})
	nPosRes := aScan(aDados, {|x| x[8] == "RES" .And. x[3] == cPeriodo})
	If lRes132 .And. nPos132 > 0 .And. nPosRes > 0
		// Verifica se S-1200 de 13∫ existe
		// Se n„o existir, somar os valores na Rescis„o para garantir que eles sejam transmitidos, caso contr·rio, removo do array
		// C91_FILIAL+C91_INDAPU+C91_PERAPU+C91_CPF+C91_NOMEVE+C91_ATIVO
		cStat1200 := TAFGetStat( "S-1200", "2" + ";" + SubString(cPeriodo,1,4) + "  " + ";" + AllTrim(SRA->RA_CIC) + ";" + "S1200" + ";" + "1", , SRA->RA_FILIAL,7)
		If cStat1200 == "-1"
			aDados[nPosRes][11] += aDados[nPos132][11]
			aDel( aDados, nPos132 )
			aSize( aDados, Len( aDados ) - 1 )
		Else
			aDel( aDados, nPos132 )
			aSize( aDados, Len( aDados ) - 1 )
		EndIf

	EndIf

Return aDados

/*/{Protheus.doc} fTpDep(aDependent,lVer23)
FunÁ„o que retorna a string xml do tipo de dependente
@type  Function
@author Eduardo
@since 08/09/2017
@version 1.0
@param aDependent, array, array com o dependente
@param lVer23, boolean, Checagem da vers„o do esocial
@return cXml,String, retorno do tipo de dependente tratando as duas versıes do eSocial.
/*/
static function fTpDep(cDependent,cVersEnvio)
Local cDep:= ""

Default cVersEnvio := "2.2"

If cVersEnvio >= "2.3"
	if val(cDependent)<03
		cDep := cDependent
	elseif val(cDependent)==03 .or. val(cDependent) ==05
		cDep := '03'
	elseif val(cDependent)==04
		cDep := '04'
	elseif val(cDependent)>=06 .and. val(cDependent) <=08
		cDep := '06'
	elseif val(cDependent)==09
		cDep := '09'
	elseif val(cDependent)==10
		cDep := '10'
	elseif val(cDependent)==11
		cDep := '11'
	elseif val(cDependent)==12
		cDep := '12'
	elseif val(cDependent)==13
		cDep := '99'
	Endif
Else
	if val(cDependent)<03
		cDep := cDependent
	elseif val(cDependent)==03 .or. val(cDependent) ==05
		cDep := '03'
	elseif val(cDependent)==04
		cDep := '08'
	elseif val(cDependent)>=06 .and. val(cDependent) <=08
		cDep := '04'
	elseif val(cDependent)==09
		cDep := '05'
	elseif val(cDependent)==10
		cDep := '06'
	elseif val(cDependent)==11
		cDep := '07'
	elseif val(cDependent)==12
		cDep := '15'
	elseif val(cDependent)==13
		cDep := '99'
	Endif
EndIF
Return cDep


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥fBuscConsig     ∫Autor ≥Renan Borges   ≥ Data ≥  06/11/17   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Procura o registro da SRK com consig. com fgts.	          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPEM026C                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Function fBuscConsig(aVerbas)
Local lRet	:= .F.
Local nX	:= 0
Local aArea := GetArea()

DbSelectArea("SRK")
DbSetOrder(1)
For nx := 1 to Len(aVerbas)
	If SRK->( DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+aVerbas[nx,1]))
		If SRK->RK_CONSFGT == '1'
			lRet := .T.
			Exit
		EndIf
	EndIf
Next

RestArea(aArea)
Return lRet

/*/{Protheus.doc} fTrf2299
Funcao responsavel por realizar a integracao com o TAF na transferencia entre Grupo/Empresas diferentes
@author jose.silveira
@since 28/03/2018
@version 12.1.17
/*/
Function fTrf2299( cCodDslg, cFilEnv, cCgcPara, dDataTRF, cVersaoEnv, cMsgRet, cTpInsc )

	Local aArea 		:= GetArea()
	Local lGravou		:= .T.
	Local cMsgErro    	:= ""
	Local cTafKey    	:= ""
	Local aErros		:= {}

	Local cBkpFil	 	:= cFilAnt
	Local cEFDAviso  	:= "0"//Se nao encontrar este parametro apenas emitira alertas
	Local cVersMw	 	:= ""
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cStatus	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= Space(6)
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cStatRJE	 	:= "-1"
	Local cOper2299	 	:= "I"
	Local cRecib2299 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2299	 	:= "1"
	Local cStat2299	 	:= "-1"
	Local nRec2299   	:= 0
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local nCont			:= 0
	Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
	Local nTpRegTrab	:= 0
	Local cMatricula    := ""
	Local cFilRJE		:= ""
	Local cEmpTrsf		:= ""
	Local cFilTrsf		:= ""

	Default cVersaoEnv 	:= '2.2'
	Default cCgcPara	:= ""
	Default cTpInsc		:= If( Len(cCgcPara) == 11, "2", "1" )

	// Carrega vari·veis/par‚metros conforme Grupo de Empresa/Filial Origem
	If (Type("lEmpDif") <> "U" .And. ValType(lEmpDif) == "L" .And. lEmpDif)
		cEmpTrsf	:= If(IsInCallStack("fEnvTaf180"),cEmpD,cEmpAnt) // Empresa Origem
		cFilTrsf	:= If(IsInCallStack("fEnvTaf180"),cFilD,cFilEnv) // Filial Origem
		cEFDAviso	:= totvs.framework.company.getParameter(cEmpTrsf,cFilTrsf,"MV_EFDAVIS")
		cFilRJE		:= totvs.framework.company.xEmpFil("RJE", cEmpTrsf, cFilTrsf)
	Else
		cEmpTrsf	:= cEmpAnt // Empresa Origem
		cFilTrsf	:= cFilEnv // Filial Origem
		cEFDAviso  	:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0"))))
		cFilRJE		:= FwxFilial("RJE", cFilTrsf)
	EndIf

	nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == SRA->RA_VIEMRAI})//Retorno: 0-CLT | >0-Estatutario

	//----------------
	//| Evento S-2299
	//| Inicio da geracao do evento de desligamento
	//----------------------------------------------
	If lMiddleware
		fVersEsoc( "S2299", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
		fPosFil( cEmpAnt, SRA->RA_FILIAL )
		lS1000 := fVld1000( AnoMes(dDataTRF), @cStatus , cFilTrsf )
		If !lS1000 .And. cEFDAviso != "2"
			Do Case
				Case cStatus == "-1" // nao encontrado na base de dados
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130)//"Registro do evento X-XXXX n„o localizado na base de dados"
					Return .F.
				Case cStatus == "1" // nao enviado para o governo
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131)//"Registro do evento X-XXXX n„o transmitido para o governo"
					Return .F.
				Case cStatus == "2" // enviado e aguardando retorno do governo
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
					Return .F.
				Case cStatus == "3" // enviado e retornado com erro
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"3
					Return .F.
			EndCase
		EndIf
	EndIf

	//-------------------
	//| Inicio do XML
	//-------------------
	If lMiddleware
		aInfos   := fXMLInfos()
		IF Len(aInfos) >= 4
			cTpInsc  := aInfos[1]
			lAdmPubl := aInfos[4]
			cNrInsc  := aInfos[2]
			cId  	 := aInfos[3]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
		EndIf

		cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, fTamRJEKey(), " ")
		cStat2299 	:= "-1"
		GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt )

		//Retorno pendente impede o cadastro
		If cStat2299 == "2" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0134//"OperaÁ„o n„o ser· realizada pois o evento foi transmitido, mas o retorno est· pendente"
		EndIf
		//Evento de exclus„o sem transmiss„o impede o cadastro
		If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0135//"OperaÁ„o n„o ser· realizada pois h· evento de exclus„o que n„o foi transmitido ou com retorno pendente"
		//N„o existe na fila, ser· tratado como inclus„o
		ElseIf cStat2299 == "-1"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		//Evento sem transmiss„o, ir· sobrescrever o registro na fila
		ElseIf cStat2299 $ "1/3"
			cOperNew 	:= cOper2299
			cRetfNew	:= cRetf2299
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclus„o transmitido, ir· gerar uma retificaÁ„o
		ElseIf cOper2299 != "E" .And. cStat2299 == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		//Evento de exclus„o transmitido, ser· tratado como inclus„o
		ElseIf cOper2299 == "E" .And. cStat2299 == "4"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		If !Empty(cMsgRJE)
			cMsgRet := cMsgRJE
			Return .F.
		EndIf
		If cRetfNew == "2"
			If cStat2299 == "4"
				cRecibXML 	:= cRecib2299
				cRecibAnt	:= cRecib2299
				cRecib2299	:= ""
			Else
				cRecibXML 	:= cRecibAnt
			EndIf
		EndIf
		aAdd( aDados, { cFilRJE, cFilTrsf, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2299", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2299, cRecibAnt } )
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtDeslig/v" + cVersMw + "'>"
		cXML += 	"<evtDeslig Id='" + cId + "'>"
		fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" }, cVersaoEnv, aInfos)
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		//-------------------
		//| Inicio do XML
		//-------------------
		cXml :=	'<eSocial>'
		cXml += 	'<evtDeslig>'
	EndIf

	//Dados do Trabalhador
	cXml +=			'<ideVinculo>'
	cXml +=				'<cpfTrab>' + AllTrim(SRA->RA_CIC) + '</cpfTrab>'
	If cVersaoEnv < "9.0.00"
		cXml +=				'<nisTrab>' + AllTrim(SRA->RA_PIS) + '</nisTrab>'
	Endif

	If !Empty(SRA->RA_CODUNIC)
		cMatricula := If(!lMiddleware, StrTran(SRA->RA_CODUNIC, "&","&#38;" ), SRA->RA_CODUNIC )
	EndIf
	cXml +=				'<matricula>' + AllTrim(cMatricula) + '</matricula>'
	cXml +=			'</ideVinculo>'

	//Dados do Desligamento
	cXml += 		'<infoDeslig>'
	cXml += 			'<mtvDeslig>' + cCodDslg + '</mtvDeslig>'
	If !lMiddleware
		cXml += 			'<dtDeslig>' + Dtos(dDataTRF) + '</dtDeslig>'
	Else
		cXml += "			<dtDeslig>" + SubStr( dToS(dDataTRF), 1, 4 ) + "-" + SubStr( dToS(dDataTRF), 5, 2 ) + "-" + SubStr( dToS(dDataTRF), 7, 2 ) + "</dtDeslig>"
	EndIf

	cXml += 			'<indPagtoAPI>N</indPagtoAPI>'

	//Pensao Alimenticia => 0 - N„o existe pens„o alimentÌcia;
	If cVersaoEnv < "9.0.00" .Or. (cVersaoEnv >= "9.0.00" .And. nTpRegTrab == 0 )
		cXml +=				'<pensAlim>0</pensAlim>'
	Endif
	If cVersaoEnv < "9.0.00"
		//Indicador de cumprimento de aviso prÈvio => 4 - Aviso prÈvio indenizado ou n„o exigÌvel.
		cXml += 			'<indCumprParc>4</indCumprParc>'
	Endif
	//Sucessao Vinculos
	If !Empty(AllTrim(cCgcPara))
		cXml +=			'<sucessaoVinc>'

		If cVersaoEnv < "9.0.00"
			cXml +=				'<tpInscSuc>' + cTpInsc +'</tpInscSuc>'
			cXml +=				'<cnpjSucessora>' + AllTrim(cCgcPara) +'</cnpjSucessora>'
		Else
			cXml +=				'<tpInsc>' + cTpInsc +'</tpInsc>'
			cXml +=				'<nrInsc>' + AllTrim(cCgcPara) +'</nrInsc>'
		Endif
		cXml +=			'</sucessaoVinc>'
	Endif

	If cVersaoEnv >= '2.4' .And. cVersaoEnv < "2.4.02"
		cXml += 		'<consigFGTS>'
		cXml += 			'<idConsig>N</idConsig>'
		cXml += 		'</consigFGTS>'
	EndIf

	//Fechamentos de Tags
	cXml += 		'</infoDeslig>'
	cXml +=		'</evtDeslig>'
	cXml +=	'</eSocial>'
	//-------------------
	//| Final do XML
	//-------------------
	GrvTxtArq(alltrim(cXml), "S2299", SRA->RA_CIC)

	If !lMiddleware
		cTafKey := "S2299" + AnoMes(dDataTRF) + SRA->RA_CIC + SRA->RA_CODUNIC
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2299", , "", , , , "GPE", , "" )
	Else
		If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2299 ))
			aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravaÁ„o do registro na tabela RJE"
		EndIf
	EndIf

	If Len(aErros) > 0
		lGravou := .F.
		cMsgRet := aErros[1]
	Endif

	RestArea(aArea)

Return lGravou

/*/{Protheus.doc} fVADI2299
FunÁ„o que verifica se houve o pagamento do roteiro ADI no calculo de rescisao
@author Allyson
@since 19/07/2018
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integraÁ„o no TAF
@param cIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se È complementar por retificaÁ„o
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function fADI2299( aCC, aPds, cFilEnv, cIdDmDev, cVersaoEnv, lRetif, aErrosRJ5, cPrefixo, lRel, cSemAdi)

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local cPerSeek	:= ""
Local cRotAdi	:= fGetCalcRot("2")//ADI
Local cSRCSeek	:= ""
Local cSRDSeek	:= ""
Local cBsIRAdi	:= ""
Local lDedSimpl	:= .F.
Local lGrvIR68	:= .F.

Default cVersaoEnv	:= "2.4"
Default lRetif		:= .F.
Default aErrosRJ5	:= {}
Default cPrefixo	:= ""
Default lRel		:= .F.
Default cSemAdi		:= M->RG_SEMANA

DbSelectArea("SRC")
DbSetOrder(RetOrder("SRC", "RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

If lRetif
	cPerSeek := AnoMes(M->RG_DATADEM)
Else
	cPerSeek := M->RG_PERIODO
EndIf

//Procura a verba de Base IR Adiantamento na SRC
If Len(aCodFol) > 0
	cBsIRAdi := aCodFol[10][1]
EndIf

//Identifica se houve c·lculo com a deduÁ„o simplificada na SRC
cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + cPerSeek + cSemAdi + cBsIRAdi
If DbSeek( cSRCSeek )
	If SRC->RC_TRIBIR == "2"
		lDedSimpl := .T.
	EndIF
EndIf
SRC->(DbGoTop())

cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + cPerSeek + cSemAdi
If DbSeek( cSRCSeek )
	While SRC->(!Eof() .And. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRC->RC_PD, SRC->RC_CC, SRC->RC_HORAS, SRC->RC_VALOR, SRC->RC_DATA, SRC->RC_PERIODO, SRC->RC_ROTEIR, cVersaoEnv, @aErrosRJ5, .T., cPrefixo, @lGrvIR68, lDedSimpl, lRel)
		SRC->(DbSkip())
	EndDo
EndIf

//Procura o roteiro do adiantamento que ja foi fechado referente ao periodo de calculo da rescisao
DbSelectArea("SRD")
DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

//Identifica se houve c·lculo com a deduÁ„o simplificada na SRD
cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + cPerSeek + cSemAdi + cBsIRAdi
If DbSeek( cSRDSeek )
	If SRD->RD_TRIBIR == "2"
		lDedSimpl := .T.
	EndIF
EndIf
SRD->(DbGoTop())

cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + cPerSeek + cSemAdi
If DbSeek( cSRDSeek )
	While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, cVersaoEnv, @aErrosRJ5, .T., cPrefixo, @lGrvIR68, lDedSimpl, lRel)
		SRD->(DbSkip())
	EndDo
EndIf

//Caso haja uso do modelo de deduÁ„o simplificada e n„o tenha verba de IR 68 aviso o usu·rio no relatÛrio de InconsistÍncia
If lRel .And. lDedSimpl .And. !lGrvIR68
	//O trabalhador possui c·lculo com deduÁ„o simplificada de IR no ideDmDev #######, mas n„o h· verba com a incidÍncia IR 68.
	//Caso necess·rio, verifique se as verbas de Id 1921, 1922, 1923 e 1924 est„o cadastradas corretamente com a incidÍncia IR 68.
	aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, OemToAnsi(STR0409) + cIdDmDev + OemToAnsi(STR0410) + OemToAnsi(STR0411)})
EndIf

RestArea(aAreaCTT)
RestArea(aAreaSRV)

Return

/*/{Protheus.doc} fADI2299Pd
FunÁ„o que verifica as verbas pagas do roteiro ADI no calculo de rescisao
@author Allyson
@since 19/07/2018
@version 1.0
@param aCC 	 		- Array com os centros de custo
@param aPds	 		- Array com as verbas
@param cFilEnv		- Filial de integraÁ„o no TAF
@param cIdDmDev		- Identificador do dmDev
@param cCodPd		- CÛdigo da verba
@param cCodCC		- CÛdigo do centro de custo
@param nHoras		- Horas da verba
@param nValor		- Valor da verba
@param dDtPgto		- Data de pagamento da verba
@param cPeriodo		- Periodo da verba
@param cRoteiro		- Roteiro da verba
@param cVersaoEnv	- Vers„o de envio
@param aErrosRJ5	- Array com centros de custo sem relacionamento na RJ5
/*/
Function fADI2299Pd( aCC, aPds, cFilEnv, cIdDmDev, cCodPd, cCodCC, nHoras, nValor, dDtPgto, cPeriodo, cRoteiro, cVersaoEnv, aErrosRJ5, lRotADI, cPrefixo, lGrvIR68, lDedSimpl, lRel)

Local cCEIObra		:= ""
Local cCAEPF		:= ""
Local cChaveCC		:= ""
Local cChaveCCPD	:= ""
Local cChaveS1005	:= ""
Local cCodLot		:= ""
Local cCodRubr		:= ""
Local cIdeRubr		:= ""
Local cInscr		:= ""
Local cPrcRubr		:= ""
Local cTpInscr		:= ""
Local cTpLot		:= ""
Local cVerbIRF		:= ""
Local cIncIrf		:= ""
Local lGeraCod		:= .F.
Local lSemFilSRV	:= .F.
Local nPosCC		:= 0
Local nPosCCPD		:= 0
Local nPosEstb		:= 0
Local lPrimIdT		:= .T.
Local cIdTabRub		:= ""
Local lRJ5FilT 		:= RJ5->(ColumnPos("RJ5_FILT")) > 0
Local lTemReg		:= .F.
Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0 .And. cVersaoEnv >= "9.0"
Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0 .And. cVersaoEnv >= "9.0"

Default cVersaoEnv	:= "2.4"
Default aErrosRJ5	:= {}
Default lRotADI		:= .F.
Default cPrefixo	:= ""
Default lGrvIR68	:= .F.
Default lDedSimpl	:= .F.
Default lRel		:= .F.

cChaveCCPD	:= cCodCC + cCodPd
cChaveCC	:= cCodCC

nPosCCPD	:= Ascan( @aPds, {|X| X[1] == cChaveCCPD })
nPosCC		:= Ascan( @aPds, {|X| X[12] == cChaveCC })

SRV->(DbSetOrder(1))
If( SRV->( dbSeek( xFilial("SRV", SRA->RA_FILIAL) + cCodPd  ) ) )

	If ( cVersaoEnv < "2.6.00" .And. Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83" )
		Return()
	Endif

	//Tratamento de compartilhamento da tabela SRV
	If !Empty(SRV->RV_FILIAL)
		lGeraCod := .T.
	Else
		lSemFilSRV := .T.
	EndIf
	//------------------
	//| LÛgica lGeraCod
	//| .T. -> Exclusiva | .F. -> Compartilhada
	//------------------------------------------
	If lGeraCod
		cIdeRubr := SRV->RV_FILIAL
	Else
		If cVersaoEnv >= "2.3"
			cIdeRubr := cEmpAnt
		Else
			cIdeRubr := ""
		EndIf
	EndIf

	//Pesquisa identificador de tabela de rubrica para o Middleware
	If lMiddleware
		If lPrimIdT
			lPrimIdT  := .F.
			cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
			If Empty(cIdTabRub)
				Help(,,,OemToAnsi(STR0001), OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141),1,0) //"AtenÁ„o"##"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "##" n„o est· cadastrado."
				Return .F.
			EndIf
		EndIf
		cIdeRubr := cIdTabRub
	EndIf

	cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
	If (SRV->RV_PERC - 100) < 0
		cPrcRubr :=	0	//Percent da Rubrica
	Else
		cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
	EndIf
	If !lRotADI .Or. lRotADI .And. SRV->RV_CODFOL $ "0006*0546"//Adiantamento
		If Empty(cPrefixo)
			cIdDmDev := SRA->RA_FILIAL + dToS(dDtPgto) + cPeriodo + cRoteiro
		Else
			//cIdDmDev = PREFIXO + DATA DE PAGAMENTO + PERIODO + ROTEIRO
			cIdDmDev := cPrefixo + dToS(dDtPgto) + cPeriodo + cRoteiro
		EndIf
	EndIf

	If aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3]+x[4] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev+dtos(dDtPgto) }) == 0
		aAdd(aDtPgtDmDev, { SRA->RA_FILIAL, SRA->RA_MAT, cIdDmDev, dtos(dDtPgto) } )
	EndIf

	//Despreza verba de incidÍncia 68 para funcion·rios com c·lculo de IR no modelo completo
	If !lDedSimpl .And. Alltrim(SRV->RV_INCIRF) == "68"
		//Se for execuÁ„o do relatÛrio imprime aviso.
		If lRel
			//Verba ### do IdeDmDev ############### desprezada devido incidÍncia IR 68 e n„o haver o c·lculo com deduÁ„o simplificada.
			aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, OemToAnsi(STR0395) + SRV->RV_COD + OemToAnsi(STR0407) + cIdDmDev + OemToAnsi(STR0408)})
		EndIf
		Return()
	EndIf
EndIf

If !lVerRJ5
	CTT->(DbSetOrder(1))
	If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + cCodCC ) ) )
		cCodLot := IIf(Empty(xFilial("CTT", SRA->RA_FILIAL)), CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
		cTpLot  := CTT->CTT_TPLOT	// Tipo de LotaÁ„o (?!?)

		//Verifica se eh uma obra por meio do campo CTT_TIPO2
		If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
			cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
			cInscr   	:= CTT->CTT_CEI2  // Codigo da inscricao
			cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
		Endif
	EndIf
Else
	RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
	If RJ5->( !dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
		If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
			aAdd( aErrosRJ5, cCodCC )
		EndIf
	Else
		If lRJ5FilT
			RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
			RJ5->(dbGoTop())
			RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC + SRA->RA_FILIAL) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. RJ5->RJ5_FILT == SRA->RA_FILIAL
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					lTemReg		:= .T.
				EndIf
				RJ5->( dbSkip() )
			EndDo
			//Se n„o encontrou um registro com cÛdigo preenchido reposiciona a tabela e executa o dbseek novamente.
			If !lTemReg
				RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
				RJ5->(dbGoTop())
				RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
				While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. Empty(RJ5->RJ5_FILT)
					If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
						cTpInscr	:= RJ5->RJ5_TPIO
						cInscr  	:= RJ5->RJ5_NIO
						cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
						cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					EndIf
					RJ5->( dbSkip() )
				EndDo
			EndiF
		Else
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
		If Empty(cCodLot)
			If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
				aAdd( aErrosRJ5, cCodCC )
			EndIf
		EndIf
		nPosCCPD	:= Ascan( @aPds,{|X| X[20] == cCodLot + cCodPd })
		nPosCC		:= Ascan( @aPds,{|X| X[19] == cCodLot })
	EndIf
EndIf

//Verifica na tabela F0F se a Filial eh uma obra
If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	cCEIObra := ""
	If fBuscaOBRA( cFilEnv, @cCEIObra )
		cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
		cInscr 	 	:= cCEIObra // Codigo da inscricao
		cChaveS1005	:= cFilEnv + cInscr
	Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
		cTpInscr 	:= "3"
		cInscr	 	:= cCAEPF
		cChaveS1005	:= cFilEnv + cInscr
	EndIf
EndIf

If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	nPosEstb := eVal(bEstab)
	If nPosEstb > 0
		cTpInscr	:= aEstb[nPosEstb,3]
		cInscr		:= aEstb[nPosEstb,2]
		cChaveS1005	:= cFilEnv + cInscr
	EndIf
EndIf

If(nPosCC == 0)
	aAdd(aCC, {cCodCC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
EndIf

//Antes da montagem do array de verbas identifica se vai gerar um registro com a incidÍncia 68
If AllTrim(SRV->RV_INCIRF) == "68"
	lGrvIR68 := .T.
EndIf

//------------------------------------------------
//| Array de Dados
//| Montagem do array com os dados a utilizar para o XML
//-------------------------------------------------------
If( nPosCCPD > 0 )
	aPds[nPosCCPD, 15] += nHoras	//Incrementa Valor
	aPds[nPosCCPD, 17] += nValor	//Incrementa Valor
	aPds[nPosCCPD, 18] += 1	  		//Incrementa Contador
Else
	aAdd(aPds, { 	cCodCC + cCodPd,;	    			//01 - Chave para pesquisa (CC+PD)
					"Dados da Verba",;					//02 - Separador - Verbas/Rubricas
					cCodRubr,;							//03 - Codigo da Rubrica
					cIdeRubr,;							//04 - Ident   da Rubrica
					cPrcRubr,;							//05 - Percent da Rubrica
					"Dados do CC",;						//06 - Separador - Centro de Custo
					cCodLot,;							//07 - Codigo da LotaÁ„o
					cTpInscr,;							//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
					cInscr,;							//09 - Codigo da inscricao
					cTpLot,;							//10 - Tipo de LotaÁ„o (?!?)
					"Dados da Grid",;					//11 - Separador - Centro de Custo
					cCodCC,;							//12 - Centro de Custo
					cCodPd,;							//13 - Verba da rescis„o
					SRV->RV_DESC,;						//14 - Descricao da verba
					nHoras,;							//15 - Horas da verba
					nValor,;							//16 - Valor da verba
					nValor,;							//17 - Acumulado da verba (valor inicial para soma)
					1,;									//18 - Numero de registro repetidos (CC + PD)
					cCodLot,;							//19 - CÛdigo de lotaÁ„o
					cCodLot + cCodPd,;					//20 - Chave para pesquisa (CÛdigo LotaÁ„o+PD)
					SRV->RV_NATUREZ,;					//21 - Natureza da verba
					SRV->RV_INCCP,;						//22 - IncidÍncia CP da verba
					SRV->RV_INCFGTS,;					//23 - IncidÍncia FGTS da verba
					SRV->RV_INCIRF,;					//24 - IncidÍncia IRRF da verba
					SRV->RV_TIPOCOD,;					//25 - Tipo da verba
					If(lRVIncop, SRV->RV_INCOP,""),;	//26 - Incid RPPS
					If(lRVTetop, SRV->RV_TETOP,"") })	//27 - Teto Remun
EndIf

Return

/*/{Protheus.doc} fBuscaSV7()
FunÁ„o respons·vel por buscar o cÛdigo de convocaÁ„o ativo mediante uma data de referÍncia
Caso n„o encontre ir· buscar a ˙ltima data de convocaÁ„o.
@type function
@author Claudinei Soares
@since 21/09/2018
@version 1.0
@param cFilFun, Caracter, Filial a ser pesquisada na tabela SV7
@param cMatFun, Caracter, MatrÌcula a ser pesquisada na tabela SV7
@param dDtBusca, Date,  Data para busca
@param cCodConv, Caracter, CÛdigo de ConvocaÁ„o (Passada como referÍncia)
@param lCMesAtual, LÛgico, Retorna se tem convocaÁ„o no mÍs atual (Passada como referÍncia)
@return cCodconv
/*/

Function fBuscaSV7(cFilFun, cMatFun, dDtBusca, cCodConv, lCMesAtual)

Local aArea			:= GetArea()
Local cCodBkp		:= ""
Local dDtcgini		:= SuperGetMv("MV_DTCGINI", , cToD("//"))

Default cFilFun		:= ""
Default cMatFun		:= ""
Default dDtBusca	:= cTod("//")
Default cCodConv	:= ""
Default lCMesAtual	:= .T.

If !ChkFile("SV7")
	Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0095),1,0) //"Tabela SV7 n„o encontrada. Execute o UPDDISTR - atualizador de dicion·rio e base de dados."
	Return
Else
	dbSelectArea("SV7")
	SV7->( dbSetOrder(1) )
	SV7->(dbGoTop())

	If SV7->( dbSeek( cFilFun + cMatFun ) )
		While SV7->( !Eof() .And. SV7->V7_FILIAL == cFilFun .And. SV7->V7_MAT == cMatFun )
			If SV7->V7_DTFIM == dDtBusca
				cCodConv := SV7->V7_CONVC
				Exit
			ElseIf SV7->V7_DTINI <= dDtBusca .And. SV7->V7_DTFIM >= dDtBusca
				cCodConv := SV7->V7_CONVC
				Exit
			//Se a data de demiss„o estiver fora do perÌodo da rescis„o percorre os registros para gravar o ˙ltimo cÛdigo de convocaÁ„o
			ElseIf SV7->V7_DTINI <= dDtBusca  .And. SV7->V7_DTINI >=  dDtcgini
				cCodBkp		:= SV7->V7_CONVC
				lCMesAtual	:= .F.
			Endif
			SV7->(dbSkip())
		EndDo
		If Empty(cCodConv)
			cCodConv := cCodBkp
		EndIF
	EndIf

	RestArea(aArea)
Endif

Return( cCodconv )

/*/{Protheus.doc} fDis2299
FunÁ„o que verifica se existe calculo do dissidio no mes da rescisao
@author Marcelo Silveira
@since 05/10/2018
@version 1.0
@param dDataRes		- Data da demissao
@param cVBDiss 		- Verbas com as diferencas do dissidio
@param aDadosCCT	- Array com dados dos centros de custos
@param cIndSimp		- Indicador do Tipo de Simples Nacional.
@param cXmlAux		- XML gerado com as informacoes do dissidio
@param cMsgErro		- Mensagem de erro na validacao das tabelas S-050 e S-126
/*/
Function fDis2299( dDataRes, cVBDiss, aDadosCCT, cIndSimp, cXmlAux, cMsgErro, lRJ5Ok, aErrosRJ5, cTpRes, aPd, cDtEfei, cCompAc, aRelVbDiss)

Local cCompete	:= ""
Local cDscAc	:= ""
Local cData		:= ""
Local cDataCor	:= ""
Local cXmlAux	:= ""
Local cPerAnt	:= ""
Local cVersEnvio:= ""

Local cMes			:= StrZero( Month(dDataRes),2 )
Local cAno			:= cValToChar( Year(dDataRes) )
Local cRHHAlias		:= GetNextAlias()
Local cSRDTabRH		:= GetNextAlias()
Local lFirst		:= .T.
Local lTemVerbas	:= .F.
Local lPrimIdT		:= .T.
Local cIdeRubr		:= ""
Local cIdTbRub		:= ""
Local aTabInss		:= {}
Local cBusca 		:= ""
Local cCCAnt		:= ""
Local lAbriu19 		:= .F.
Local lAbriu20 		:= .F.
Local lFechPer 		:= .F.
Local lFechEstLot 	:= .F.
Local lFechou20 	:= .F.
Local lFirstAnt 	:= .T.
Local lGeraRes 		:= .F.
Local lGerouAnt 	:= .F.
Local lVerDINSS		:= .T.
Local aVbDiss		:= {}
Local cPerDiss		:= ""
Local nC			:= 0
Local nParDiss 		:= 1
Local nParPag		:= 0
Local nValor		:= 0
Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0
Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0
Local aTransfFun 	:= {}
Local nContTrf      := 0
Local cCposWhere    := ""
Local cFilRHH 		:= ""
Local cCCRHH 		:= ""
Local cPerIni		:= ""
Local cPerFim		:= ""
Local lPosicRHH		:= .T.
Local aFilInTaf		:= {}
Local cFilEnv 		:= ""
Local lConfig1xN	:= .F.
Local aArrayFil 	:= {}

Private cAnoBase	:= cAno
Private aCC			:= fGM23CTT()//extrai lista de c.custo da filial conectada "xfilial(CTT)" ...
Private oTmpTabl2	:= Nil
Private oTmpTabRH	:= Nil

Default cXmlAux		:= ""
Default cMsgErro	:= ""
Default	cVBDiss		:= ""
Default lRJ5Ok		:= .T.
Default	aErrosRJ5	:= {}
Default cTpRes		:= ""
Default aPd			:= {}
Default cDtEfei		:= ""
Default cCompAc		:= ""
Default aRelVbDiss	:= {}

fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)

If Len(aFilInTaf) > 0 .And. (Len(aFilInTaf[1,3]) > 1) .AND. !EMPTY(cFilEnv) //1XN
	lConfig1xN := .T.
EndIf

fBuscaDiss(@aVbDiss, cTpRes, aPd )

fTransfAll( @aTransfFun,,,.T.)

	If Len(aVbDiss) > 0
		For nC := 1 To Len(aVbDiss)
			SRK->( dbSetOrder(1) )
			If SRK->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ) )
				While SRK->( !EoF() .And. SRK->RK_FILIAL+SRK->RK_MAT == SRA->RA_FILIAL+SRA->RA_MAT  )
					If ( (Empty(SRK->RK_NUMID) .And. SRK->RK_MESDISS == SubStr(aVbDiss[nC, 2], 5, 2 ) + SubStr(aVbDiss[nC, 2], 1, 4 )) .Or. (!Empty(SRK->RK_NUMID) .And. AllTrim(SRK->RK_NUMID) == AllTrim(aVbDiss[nC, 2])) )
						cPerDiss := SRK->RK_PERINI
						nParDiss := SRK->RK_PARCELA
						nParPag  := SRK->RK_PARCPAG
						Exit
					EndIf
					SRK->( dbSkip() )
				EndDo
			EndIf
			If !Empty(cPerDiss)
				Exit
			EndIf
		Next nC
		cAno := Substr(cPerDiss,1,4)
		cMes := Substr(cPerDiss,5,2)
		cAnoBase:= cAno
	EndIf

	If Empty(cPerDiss)
		cPerDiss := cAno+cMes
	Endif

	lAchouRHH := fPesqRHH( SRA->RA_FILIAL, SRA->RA_MAT, @cPerDiss, @cPerIni, @cPerFim)
	// Caso n„o encontre a RHH verifica se o houve transferÍncia e os dados est„o na origem
	If !lAchouRHH .And. Len(aTransfFun) > 0
		For nContTrf := 1 To Len(aTransfFun)
			If aTransfFun[nContTrf, 12] >= cPerDiss
				Exit
			EndIf
		Next nContTrf
		If nContTrf <= Len(aTransfFun)
			lPosicRHH := !( fPesqRHH( aTransfFun[nContTrf, 8], aTransfFun[nContTrf, 9], @cPerDiss, @cPerIni, @cPerFim ))
		EndIf
	EndIf

	fVersEsoc( "S2299",,,, @cVersEnvio )

	If cVersEnvio < "9.0"
		lRVIncop := .F.
		lRVTetop := .F.
	Endif

	If Len(aTransfFun) > 0
		cCposWhere := "%"
		cCposWhere += "((RHH.RHH_FILIAL = '" + SRA->RA_FILIAL + "' AND "
		cCposWhere += "RHH.RHH_MAT = '" + SRA->RA_MAT + "') OR "

		For nContTrf := 1 To Len(aTransfFun)
			cCposWhere += 	"(RHH.RHH_FILIAL = '" + aTransfFun[nContTrf, 8] + "' AND "
			cCposWhere += 	"RHH.RHH_MAT = '" + aTransfFun[nContTrf, 9] + "')"
			If nContTrf < Len(aTransfFun)
				cCposWhere += 	" OR "
			EndIf
		Next nContTrf

		cCposWhere += 	") AND RHH.RHH_MESANO = '" + cAno+cMes + "' AND "
		cCposWhere += 	"RHH.RHH_INTEGR = 'S' AND "
		cCposWhere += 	"RHH.D_E_L_E_T_ = ' ' "
		cCposWhere += "%"
	Endif

	If Empty(aTransfFun) .Or. aScan(aTransfFun, { |x| x[12] >= cPerIni .And. x[12] <= (cAno+cMes) .And. (x[1] != x[4] .Or. x[8] != x[10]) }) == 0
	BeginSql alias cRHHAlias
			SELECT 	 RHH.RHH_FILIAL,RHH.RHH_MAT,RHH.RHH_MESANO,RHH.RHH_DATA,RHH.RHH_VB,RHH.RHH_CC,RHH.RHH_VERBA,RHH.RHH_DTACOR,SUM(RHH.RHH_VALOR) AS RHH_VALOR,SUM(RHH.RHH_HORAS) AS RHH_HORAS
			FROM	 %table:RHH% RHH
			WHERE 	 RHH.RHH_FILIAL =	%exp:SRA->RA_FILIAL%
			AND 	 RHH.RHH_MAT    =	%exp:SRA->RA_MAT   %
			AND 	 RHH.RHH_MESANO =	%exp:cAno+cMes%
			AND		 RHH.RHH_INTEGR = 	%exp:'S'%
			AND      RHH.%notDel%
			GROUP BY RHH_FILIAL, RHH_MAT, RHH_MESANO, RHH_DATA, RHH_VB, RHH_CC, RHH_VERBA, RHH_DTACOR
			ORDER BY 1, 2, 3, 4, 6, 5
		EndSql
	else
		BeginSql alias cRHHAlias
			SELECT 	 RHH.RHH_FILIAL,RHH.RHH_MAT,RHH.RHH_MESANO,RHH.RHH_DATA,RHH.RHH_VB,RHH.RHH_CC,RHH.RHH_VERBA,RHH.RHH_DTACOR,SUM(RHH.RHH_VALOR) AS RHH_VALOR,SUM(RHH.RHH_HORAS) AS RHH_HORAS
			FROM	 %table:RHH% RHH
			WHERE 	 %exp:cCposWhere%
			GROUP BY RHH_FILIAL, RHH_MAT, RHH_MESANO, RHH_DATA, RHH_VB, RHH_CC, RHH_VERBA, RHH_DTACOR
			ORDER BY 1, 2, 3, 4, 6, 5
		EndSql
	Endif

If lVerRJ5
	fVerRJ5B(cRHHAlias, cSRDTabRH, AnoMes(dDataRes), @lRJ5Ok, @aErrosRJ5)
EndIf

While (cRHHAlias)->(!Eof() )

		If lFirst
			cDtAco := (cRHHAlias)->RHH_DTACOR
			cTpAco := fGetTpAc(	lPosicRHH, "1", cMes+cAno, , , .T.)
			cDscAc := fGetDscAc(lPosicRHH, "1", cMes+cAno, @cDataCor, .T.)
			cDtEfei:= If(!Empty(cDataCor), dToS(cDataCor), "")
			cCompAc:= cAno +"-"+ cMes
			lFirst := .F.
			If Empty( cDscAc ) .Or. Empty( cTpAco )
				cMsgErro := OemToAnsi( STR0100 ) //"Preenchimento incorreto das tabelas S050/S126. As informaÁıes de dissÌdio n„o foram geradas."
				Exit
			EndIf
		EndIf

	If cPerAnt <> (cRHHAlias)->RHH_DATA

		lTemVerbas	:= .F.
		cPerAnt		:= (cRHHAlias)->RHH_DATA
		cCCAnt		:= ""
		nPosCC		:= Ascan( aDadosCCT, {|X| X[1] == (cRHHAlias)->RHH_CC })

		If lFechPer
			lFechPer 	:= .F.
			S1200F21 ( @cXmlAux)//idePeriodo
		EndIf
		lGeraPer 	:= .T.
		lTemVerbas	:= .F.
		lVerDINSS	:= .T.
		lGerDINSS	:= .F.
	EndIf

	If cCCAnt <> (cRHHAlias)->RHH_CC
		cTpInscr	:= ""
		cInscr		:= ""
		cCCAnt 		:= (cRHHAlias)->RHH_CC
		lFechEstLot	:= .F.
		lGeraEstLot	:= .T.
		lTemVerbas	:= .F.
		lVerDINSS	:= .T.
		lGerDINSS	:= .F.

		cFilRHH := (cRHHAlias)->RHH_FILIAL
		cCCRHH := (cRHHAlias)->RHH_CC

			If (cRHHAlias)->RHH_FILIAL <> SRA->RA_FILIAL .And. If(lConfig1xN,fGetCGC(cEmpAnt, cFilRHH) != fGetCGC(cEmpAnt, SRA->RA_FILIAL),.T.)
				cFilRHH := SRA->RA_FILIAL
				If !lVerRJ5 .And. (cRHHAlias)->RHH_CC <> SRA->RA_CC
					cCCRHH := SRA->RA_CC
				Endif
			Endif

		fEstabELot(cFilRHH, cCCRHH, @cTpInscr, @cInscr, @cBusca, Iif(lVerRJ5, (cRHHAlias)->RHH_CCBKP, ""), AnoMes(dDataRes))

		dbselectarea('CTT')
		DbsetOrder(1)
		CTT->(DBSeek( xFilial("CTT", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC )  )

		cVerIndSimples := ''
		If fOptSimp() == "1" .And. fInssEmp( (cRHHAlias)->RHH_FILIAL, @aTabInss, Nil, cAno+cMes )
			cVerIndSimples := aTabInss[31, 1]
		EndIf

	Endif

	If !((cRHHAlias)->RHH_VB == "000" .Or. (cRHHAlias)->RHH_VALOR <= 0.00)

		lTemVerbas	:= .T.
		If lFirstAnt
			lFirstAnt	:= .F.
			lGerouAnt	:= .T.
			If !lAbriu19
				S1200A19(@cXmlAux,.F.)//infoPerAnt
				lAbriu19 := .T.
			Endif
			If !lAbriu20
				cXmlAux += "					<ideADC>"
				If cVersEnvio < "9.0.00" .Or. (cTpAco $ "A|B|C|D|E")
					If !lMiddleware
						cXmlAux += "						<dtAcConv>" + cDtAco + "</dtAcConv>"
					Else
						cXmlAux += "						<dtAcConv>" + SubStr( cDtAco, 1, 4 ) + "-" + SubStr( cDtAco, 5, 2 ) + "-" + SubStr( cDtAco, 7, 2 ) + "</dtAcConv>"
					EndIf
				Endif
				cXmlAux += "						<tpAcConv>" + cTpAco + "</tpAcConv>"

				If cVersEnvio < "9.0.00"
					If !lMiddleware .Or. (!Empty(cAno) .And. !Empty(cMes))
						cXmlAux += "					<compAcConv>" + cAno +"-"+ cMes + "</compAcConv>"
					EndIf
					If !lMiddleware
						cXmlAux += "						<dtEfAcConv>" + dToS(cDataCor) + "</dtEfAcConv>"
					Else
						cXmlAux += "						<dtEfAcConv>" + SubStr( dToS(cDataCor), 1, 4 ) + "-" + SubStr( dToS(cDataCor), 5, 2 ) + "-" + SubStr( dToS(cDataCor), 7, 2 ) + "</dtEfAcConv>"
					EndIf
				Endif
				cXmlAux += "						<dsc>" + cDscAc + "</dsc>"
				lAbriu20 := .T.
			Endif
		EndIf
		If lGeraPer
			lFechPer	:= .T.
			lGeraPer 	:= .F.
			S1200A21(@cXmlAux, { SubStr((cRHHAlias)->RHH_DATA,1,4) + "-" + SubStr((cRHHAlias)->RHH_DATA,5,2) })//idePeriodo
		EndIf
		If lGeraEstLot
			lFechEstLot := .T.
			lGeraEstLot	:= .F.
			S1200A12 ( @cXmlAux, {cTpInscr,cInscr,cBusca, /*vazio nao enviar mesmo*/ }, .F.) //IdeEstabLot
		EndIf

		cVBDiss	+= If( (cRHHAlias)->RHH_VERBA $ cVBDiss, "", (cRHHAlias)->RHH_VERBA + "/" )
		aAdd(aRelVbDiss, {(cRHHAlias)->RHH_VERBA, (cRHHAlias)->RHH_VB})


		//Posiciona na verba
		PosSrv( (cRHHAlias)->RHH_VB,cFilRHH)

		If SRV->RV_CODFOL $ "0064/0065" .And. lVerDINSS
			lVerDINSS := .F.
			aAreaSRV := SRV->( GetArea() )
			cVerbBus := ""
			SRV->( dbSetOrder(2) )
			If SRV->RV_CODFOL == "0064"
				If SRV->( dbSeek( xFilial("SRV", (cRHHAlias)->RHH_FILIAL ) + "0065" ) )
					cVerbBus := SRV->RV_COD
				EndIf
			ElseIf SRV->RV_CODFOL == "0065"
				If SRV->( dbSeek( xFilial("SRV", (cRHHAlias)->RHH_FILIAL ) + "0064" ) )
					cVerbBus := SRV->RV_COD
				EndIf
			EndIf
			RHH->( dbSetOrder(1) )
			If !Empty(cVerbBus) .And. RHH->( dbSeek( (cRHHAlias)->RHH_FILIAL + (cRHHAlias)->RHH_MAT + (cRHHAlias)->RHH_MESANO + (cRHHAlias)->RHH_DATA + cVerbBus + (cRHHAlias)->RHH_CC ) )
				If (cRHHAlias)->RHH_VALOR + RHH->RHH_VALOR > 0
					lGerDINSS := .T.
				EndIf
			Else
				If (cRHHAlias)->RHH_VALOR > 0
					lGerDINSS := .T.
				Endif
			EndIf
			RestArea(aAreaSRV)
		Endif

		nValor :=  (cRHHAlias)->RHH_VALOR

		If !(SRV->RV_CODFOL $ "0064/0065") .Or. (SRV->RV_CODFOL $ "0064/0065" .And. lGerDINSS)
			If nParDiss > 0
				nValor := NoRound( (nValor / nParDiss) * (nParDiss - nParPag) , 2 )
			Endif
		EndIf

		cIdTbRub := If( ! Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, cEmpAnt )
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

		If lMiddleware
			If lPrimIdT
				lPrimIdT  := .F.
				cIdeRubr := fGetIdRJF( SRV->RV_FILIAL, cIdTbRub )
			EndIf
			cIdTbRub := cIdeRubr
		EndIf

		If  ( ( (cVersEnvio < "2.6.00" .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83")) .Or. cVersEnvio >= "9.0" ) ) .And.;
			(!(SRV->RV_CODFOL $ "0064/0065") .Or. (SRV->RV_CODFOL $ "0064/0065" .And. lGerDINSS)) .And. nValor > 0
			cXmlAux += "								<detVerbas>"
			cXmlAux += "									<codRubr>" + (cRHHAlias)->RHH_VB + "</codRubr>"
			cXmlAux += "									<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
			If !lMiddleware .Or. !Empty((cRHHAlias)->RHH_HORAS)
				cXmlAux += "								<qtdRubr>" + Iif(lMiddleware, AllTrim(Str((cRHHAlias)->RHH_HORAS)), Str((cRHHAlias)->RHH_HORAS)) + "</qtdRubr>"
			EndIf
			If !lMiddleware .Or. !Empty(nPercRub)
				cXmlAux += "								<fatorRubr>" + Iif(lMiddleware, AllTrim(StrTran(Transform(nPercRub,"@E 999.99"), ",", "." )), Transform(nPercRub,"@E 999.99")) + "</fatorRubr>" 
			EndIf
			If (!lMiddleware .Or. !Empty(nValor)) .And. cVersEnvio < "9.0.00"
				If !lMiddleware
					cXmlAux += "								<vrUnit>" + AllTrim( Transform(nValor,"@E 999999999.99") ) + "</vrUnit>"
				Else
					cXmlAux += "								<vrUnit>" + AllTrim( Str(nValor ) ) + "</vrUnit>"
				EndIf
			EndIf
			If !lMiddleware
				cXmlAux += "									<vrRubr>" + AllTrim( Transform(nValor,"@E 999999999.99") ) + "</vrRubr>"
			Else
				cXmlAux += "									<vrRubr>" + AllTrim( Str(nValor ) ) + "</vrRubr>"
			EndIf
			If cVersEnvio >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
				cXmlAux +=         '<indApurIR>0</indApurIR>'
			Endif
			cXmlAux += "								</detVerbas>"
			If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") )
				fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, cTpInscr, cInscr, cBusca, SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, nValor, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""))
			EndIf
		EndIf
	EndIf

	(cRHHAlias)->(dbSkip())

	If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. cPerAnt <> (cRHHAlias)->RHH_DATA .And. lFechPer
		If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
			cOcorren := fGrauExp()
			S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
			S1200F18 ( @cXmlAux)
		EndIf
		lFechPer := .F.
		S1200F12 ( @cXmlAux )//ideEstabLot
		S1200F21 ( @cXmlAux)//idePeriodo
		Loop
	EndIf
	If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. cCCAnt <> (cRHHAlias)->RHH_CC .And. cPerAnt == (cRHHAlias)->RHH_DATA .And. lFechEstLot
		If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
			cOcorren := fGrauExp()
			S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
			S1200F18 ( @cXmlAux)
		EndIf
		lFechEstLot := .F.
		S1200F12 ( @cXmlAux )//ideEstabLot
	Endif
End

If !lVerRJ5
	(cRHHAlias)->( dbCloseArea() )
Else
	oTmpTabl2:Delete()
	oTmpTabRH:Delete()
	oTmpTabl2 := Nil
	oTmpTabRH := Nil
EndIf

If lTemVerbas
	If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
		cOcorren := fGrauExp()
		S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
		S1200F18 ( @cXmlAux)
	EndIf
	If lFechPer .And. lFechEstLot
		S1200F12 ( @cXmlAux )//ideEstabLot
		S1200F21 ( @cXmlAux)//idePeriodo
	ElseIf lFechPer
		S1200F21 ( @cXmlAux)//idePeriodo
	EndIf
EndIf
If lGerouAnt .Or. (!lGerouAnt .And. !lTemVerbas .And. lGeraRes .And. lAbriu20 .And. !lFechou20)
	S1200F20(@cXmlAux)//ideADC
	S1200F19(@cXmlAux)//infoPerAnt
EndIf

Return

/*/{Protheus.doc} fPLR2299
Crias as Tags no XML do Evento S-2299 com as verbas pagas no Roteiro de PLR
@author CÌcero Alves
@since 11/10/2018
@version 12.1.17
@Param cXml, Caracter, String com o XML que ser· enviado para o TAF - Deve ser passada por referÍncia
@param oModel, Object, Objeto com as informaÁıes da rescis„o
@Param aDadosCTT, Array, InformaÁıes dos estabelecimentos / lotaÁıes
@Param cIndSimp, Caracter, Indicador do Tipo de Simples Nacional.
/*/
Function fPLR2299( cXml, oModel, aDadosCCT, cIndSimp, dDataRes, lRel, cPrefixo)

	Local cAliasPLR	:= GetNextAlias()
	Local dLastDate	:= ""
	Local cIdTbRub	:= If(! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local cVersEnvio:= ""
	Local nPosCC	:= 0
	Local nPercRub	:= 0
	Local aArea		:= GetArea()
	Local lRVIncop	:= SRV->(ColumnPos("RV_INCOP"))> 0
	Local lRVTetop 	:= SRV->(ColumnPos("RV_TETOP"))> 0
	Local lRetIR	:= .F.

	Default lRel	 := .F.
	Default cPrefixo := ""

	fVersEsoc( "S2299",,,, @cVersEnvio )

	If cVersEnvio < "9.0"
		lRVIncop := .F.
		lRVTetop := .F.
	Endif
	If lMiddleware
		cIdTbRub := fGetIdRJF( xFilial("SRV", SRA->RA_FILIAL), cIdTbRub )
	EndIf

	dDataRes		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATADEM"), dDataRes)
	cProcess		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_PROCES"), SRA->RA_PROCES)

	BeginSQL Alias cAliasPLR
		SELECT 	 SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATARQ, SRD.RD_CC, SRD.RD_PD, SRD.RD_PERIODO, SRD.RD_ROTEIR, SUM(SRD.RD_HORAS) RD_HORAS, SUM(SRD.RD_VALOR) RD_VALOR, MAX(SRD.RD_DATPGT) RD_DATPGT, MAX(SRD.R_E_C_N_O_) RECNO, 'SRD' AS TAB
		FROM	 %table:SRD% SRD
		WHERE 	 SRD.RD_FILIAL =	%exp:SRA->RA_FILIAL%
		AND 	 SRD.RD_MAT    =	%exp:SRA->RA_MAT%
		AND 	 SRD.RD_DATARQ =	%exp:AnoMes(dDataRes)%
		AND 	 SRD.RD_ROTEIR =	'PLR'
		AND      SRD.%notDel%
		GROUP BY RD_FILIAL, RD_MAT, RD_DATARQ, RD_CC, RD_PD, RD_PERIODO, RD_ROTEIR
		UNION ALL
		SELECT 	 SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PERIODO, SRC.RC_CC, SRC.RC_PD, SRC.RC_PERIODO, SRC.RC_ROTEIR, SUM(SRC.RC_HORAS) RD_HORAS, SUM(SRC.RC_VALOR) RD_VALOR, MAX(SRC.RC_DATA) RD_DATPGT, MAX(SRC.R_E_C_N_O_) RECNO, 'SRC' AS TAB
		FROM	 %table:SRC% SRC
		WHERE 	 SRC.RC_FILIAL 	=	%exp:SRA->RA_FILIAL%
		AND 	 SRC.RC_MAT		=	%exp:SRA->RA_MAT%
		AND 	 SRC.RC_PERIODO =	%exp:AnoMes(dDataRes)%
		AND 	 SRC.RC_ROTEIR 	=	'PLR'
		AND      SRC.%notDel%
		GROUP BY RC_FILIAL, RC_MAT, RC_PERIODO, RC_CC, RC_PD, RC_PERIODO, RC_ROTEIR
		ORDER BY 1, 2, 3, 4, 5
	EndSQL

	While ! (cAliasPLR)->(Eof())

		// Verifica se a data houve integraÁ„o do perÌodo de PLR
		// Se foi integrado n„o gera o pagamento separado
		If ! Empty(Posicione("RCH", 1, (cAliasPLR)->(xFilial("RCH", RD_FILIAL) + cProcess + RD_PERIODO + "01" + "PLR"), "RCH_DTINTE" ))
			EXIT
		EndIf

		If dLastDate != (cAliasPLR)->RD_DATPGT

			dLastDate := (cAliasPLR)->RD_DATPGT

			//Quando o prefixo est· preenchido significa que deve gerar o ideDmDev em novo formato
			//Caso esteja em branco gera no formato anterior
			If Empty(cPrefixo)
				cIdDmDev := SRA->RA_FILIAL + (cAliasPLR)->RD_DATPGT + (cAliasPLR)->RD_PERIODO + (cAliasPLR)->RD_ROTEIR
			Else
				//cIdDmDev = PREFIXO +   DATA DE PAGAMENTO     +     PERIODO             +          ROTEIRO
				cIdDmDev := cPrefixo + (cAliasPLR)->RD_DATPGT + (cAliasPLR)->RD_PERIODO + (cAliasPLR)->RD_ROTEIR
			EndIf

			nPosCC := Ascan( aDadosCCT, { |X| X[1] == (cAliasPLR)->RD_CC })

			//Guarda a data de pagamento de cada DmDev
			If aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3]+x[4] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev+(cAliasPLR)->RD_DATPGT }) == 0
				aAdd(aDtPgtDmDev, { SRA->RA_FILIAL, SRA->RA_MAT, cIdDmDev, (cAliasPLR)->RD_DATPGT } )
			EndIf

			cXml += "<dmDev>"
			cXml += "<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
			cXml += "<infoPerApur>"
			cXml += "<ideEstabLot>"
			cXml += "<tpInsc>" + aDadosCCT[nPosCC, 2] + "</tpInsc>"
			If !lMiddleware
				cXml += "<nrInsc>"+ aDadosCCT[nPosCC,3] + " </nrInsc>"
			Else
				cXml += "<nrInsc>"+ Alltrim(aDadosCCT[nPosCC,3]) + "</nrInsc>"
			Endif
			cXml += "<codLotacao>" + StrTran( aDadosCCT[nPosCC,4], "&", "&amp;") + "</codLotacao>"

		EndIf

		PosSrv( (cAliasPLR)->RD_PD, (cAliasPLR)->RD_FILIAL )
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )
		//N„o leva as verbas de IR
		If ( ( cVersEnvio < "2.6.00" .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or. cVersEnvio >= "9.0" ) .And. (cAliasPLR)->RD_VALOR > 0
			cXml += "<detVerbas>"
			cXml += 	"<codRubr>" + (cAliasPLR)->RD_PD + "</codRubr>"
			cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
			If !lMiddleware .Or. !Empty((cAliasPLR)->RD_HORAS)
				cXml += "<qtdRubr>" + Iif(lMiddleware, AllTrim(Str((cAliasPLR)->RD_HORAS)), Str((cAliasPLR)->RD_HORAS)) + "</qtdRubr>"
			EndIf
			If !lMiddleware .Or. !Empty(nPercRub)
				cXml += "<fatorRubr>" + Iif(lMiddleware, AllTrim(StrTran(Transform(nPercRub,"@E 999.99"), ",", "." )), Transform(nPercRub,"@E 999.99")) + "</fatorRubr>"
			EndIf
			If (!lMiddleware .Or. !Empty((cAliasPLR)->RD_VALOR) ) .And. cVersEnvio < "9.0.00"
				If !lMiddleware
					cXml += "<vrUnit>" + AllTrim( Transform((cAliasPLR)->RD_VALOR, "@E 999999999.99") ) + "</vrUnit>"
				Else
					cXml += "<vrUnit>" + AllTrim( Str((cAliasPLR)->RD_VALOR) ) + "</vrUnit>"
				EndIf
			EndIf
			If !lMiddleware
				cXml += 	"<vrRubr>" + AllTrim( Transform((cAliasPLR)->RD_VALOR, "@E 999999999.99") ) + "</vrRubr>"
			Else
				cXml += 	"<vrRubr>" + AllTrim( Str((cAliasPLR)->RD_VALOR) ) + "</vrRubr>"
			EndIf
			If cVersEnvio >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
				cXml +=         '<indApurIR>0</indApurIR>'
			Endif
			cXml += "</detVerbas>"
			If !lRel
				lRetIR := (lVbRelIR .And. fVbRelIR(SRV->RV_NATUREZ, ALLTRIM(SRV->RV_INCIRF))) //Confirma que se trata de verba de IR
				If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") .Or. lRetIR)
					fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nPosCC, 2], aDadosCCT[nPosCC, 3], aDadosCCT[nPosCC, 4], SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, (cAliasPLR)->RD_VALOR, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""), cIdDmDev, STOD((cAliasPLR)->RD_DATPGT), SRV->RV_COD, SRV->RV_CODFOL, anomes(STOD((cAliasPLR)->RD_DATPGT)),,lRetIR)
				EndIf
			EndIf
		EndIf

		(cAliasPLR)->(dbSkip())

		If dLastDate != (cAliasPLR)->RD_DATPGT .Or. (cAliasPLR)->(Eof())
			If SRA->RA_TPPREVI == "1"
				S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
			EndIf
			If ! Empty(cIndSimp)
				cXml += "<infoSimples>"
				cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			cXml += "</infoPerApur>"
			cXml += "</dmDev>"
		EndIf

	EndDo

	(cAliasPLR)->(dbCloseArea())

	RestArea(aArea)

Return

/*/{Protheus.doc} function
description
@author CÌcero Alves
@since 16/10/2018
@version 12.1.17
@param cXml, Caracter, String com as informaÁıes que ser„o enviadas para o TAF - Deve ser passada por referÍncia
@param oModel, Object, Modelo de dados com as informaÁıes da rescs„o (GPEM040)
@param aDadosCCT, Array, InformaÁıes dos estabelecimentos / LotaÁıes
@param cVBDiss, Caracter, Verbas que foram pagas no dissÌdio
@Param cIndSimp, Caracter, Indicador do Tipo de Simples Nacional.
@param lRetif, Logico, Indica se È retificaÁ„o
@param aColsRes, Array, InformaÁıes das verbas geradas nas rescis„o atual
/*/
Static Function fResCom(cXml, oModel, aDadosCCT, cVBDiss, cIndSimp, lRetif, aColsRes,lRJ5Ok, lRel)

	Local aPdResCom	:= {}
	Local cAliasSRR := GetNextAlias()
	Local cSRRTabRH	:= GetNextAlias()
	Local dLastDate	:= ""
	Local cIdTbRub	:= If( ! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local cVersEnvio:= ""
	Local nContCols	:= 0
	Local nContPd	:= 0
	Local nPosCC	:= 0
	Local nPosPD	:= 0
	Local nPercRub	:= 0
	Local oModelSRG	:= oModel:GetModel("GPEM040_MSRG")
	Local cCCAnt	:= ""
	Local cTpInscr	:= ""
	Local cInscr	:= ""
	Local cBusca	:= ""
	Local nValorRub := 0
	Local lRVIncop	:= SRV->(ColumnPos("RV_INCOP"))> 0
	Local lRVTetop 	:= SRV->(ColumnPos("RV_TETOP"))> 0
	Local dDataRes	:= oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATADEM")
	Local lRetIR	:= .F.
	Local lRetifAnt	:= .F.

	Private aCC			:= fGM23CTT()//extrai lista de c.custo da filial conectada "xfilial(CTT)" ...
	Private oTmpTabRR	:= Nil
	Private oTmpTabRR2	:= Nil

	Default lRetif  	:= .F.
	Default lRJ5Ok		:= .T.
	Default lRel		:= .F.

	fVersEsoc( "S2299",,,, @cVersEnvio )

	If cVersEnvio < "9.0"
		lRVIncop := .F.
	 	lRVTetop := .F.
	Endif
	If lMiddleware
		cIdTbRub := fGetIdRJF( xFilial("SRV", SRA->RA_FILIAL), cIdTbRub )
	EndIf

	BeginSQL Alias cAliasSRR
		SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PD, SUM(SRR.RR_HORAS) RR_HORAS, SUM(SRR.RR_VALOR) RR_VALOR, MAX(SRR.RR_DATA) RR_DATA, SRR.RR_PERIODO, SRR.RR_ROTEIR, MAX(SRR.R_E_C_N_O_) RECNO, SRR.RR_DATAPAG
		FROM %Table:SRR% SRR
		WHERE SRR.RR_FILIAL = %Exp: oModelSRG:GetValue("RG_FILIAL")% AND
		SRR.RR_MAT = %Exp: oModelSRG:GetValue("RG_MAT")% AND
		SRR.RR_TIPO3 = 'R' AND
		SRR.RR_DATA < %Exp:dToS(oModelSRG:GetValue("RG_DTGERAR"))% AND
		SRR.%NotDel%
		GROUP BY RR_FILIAL, RR_MAT, RR_DATA, RR_CC, RR_PD, RR_PERIODO, RR_ROTEIR, RR_DATAPAG
		ORDER BY 1, 2, 7, 3, 4
	EndSQL

	If lVerRJ5 .And. !(cAliasSRR)->(Eof())
		fVerRJ5R(@cAliasSRR, @cSRRTabRH, AnoMes(dDataRes))
	EndIf

	While !(cAliasSRR)->(Eof())

		If dLastDate != (cAliasSRR)->RR_DATA
			dLastDate 	:= (cAliasSRR)->RR_DATA
			cCCAnt 		:= ""
			lRetifAnt	:= fRetifAnt( (cAliasSRR)->RR_FILIAL, (cAliasSRR)->RR_MAT, (cAliasSRR)->RR_DATA )
			cIdDmDev 	:= "R" + cEmpAnt + AllTrim(oModelSRG:GetValue("RG_FILIAL")) + (cAliasSRR)->RR_MAT + If(lRetifAnt, "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
			nPosCC 		:= Ascan( aDadosCCT, { |X| X[1] == (cAliasSRR)->RR_CC })

			cXml += "<dmDev>"
			cXml += "<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
			cXml += "<infoPerApur>"

			//Guarda a data de pagamento de cada DmDev
			If aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3]+x[4] == (cAliasSRR)->RR_FILIAL+(cAliasSRR)->RR_MAT+cIdDmDev+(cAliasSRR)->RR_DATAPAG }) == 0
				aAdd(aDtPgtDmDev, { (cAliasSRR)->RR_FILIAL, (cAliasSRR)->RR_MAT, cIdDmDev, (cAliasSRR)->RR_DATAPAG } )
			EndIf
		EndIf

		If dLastDate != (cAliasSRR)->RR_DATA .Or. cCCAnt <> (cAliasSRR)->RR_CC
			cTpInscr	:= ""
			cInscr		:= ""
			cCCAnt 		:= (cAliasSRR)->RR_CC
			fEstabELot((cAliasSRR)->RR_FILIAL, (cAliasSRR)->RR_CC, @cTpInscr, @cInscr, @cBusca, "", AnoMes((cAliasSRR)->RR_DATA))

			If lVerRJ5
				cBusca :=  IIf(lSemFilCTT, (cAliasSRR)->RR_CC, xFilial("RJ5",(cAliasSRR)->RR_FILIAL) + (cAliasSRR)->RR_CC )
			Else
				nPosCC := Ascan( aDadosCCT, { |X| X[1] == (cAliasSRR)->RR_CC })
				If nPosCC > 0
					cBusca := aDadosCCT[nPosCC,4]
				Endif
			EndIf

			cXml += "<ideEstabLot>"
			cXml += "<tpInsc>" + cTpInscr + "</tpInsc>"
			cXml += "<nrInsc>"+ cInscr + "</nrInsc>"
			cXml += "<codLotacao>" + AllTrim(StrTran( cBusca, "&", "&amp;")) + "</codLotacao>"
		EndIf

		PosSrv( (cAliasSRR)->RR_PD, (cAliasSRR)->RR_FILIAL )
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

		// N„o leva as verbas de desconto de IR pois ser„o informadas no evento S-1210
		// As  do roteriro de PLR devem ser levadas em um pagamento (DmDev) diferente
		If (cAliasSRR)->RR_ROTEIR != "PLR" .And. (cAliasSRR)->RR_VALOR > 0 .And.;
			 ( ( (cVersEnvio < "2.6.00" .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83")) .Or. cVersEnvio >= "9.0" ) ) .And.;
			!(SRV->RV_CODFOL $ "0126|0303")

			nValorRub	:= (cAliasSRR)->RR_VALOR

			If ( nPosPd := aScan( aPdResCom, { |x| x[1] + x[2] == (cAliasSRR)->RR_CC + (cAliasSRR)->RR_PD } ) ) == 0
				//Adiciona no array aPdResCom somente as verbas que precisam deduzir do valor
				//Ocorre no caso de mais de um rescis„o complementar no mesmo perÌodo.
				If SUBSTR((cAliasSRR)->RR_DATA,1,6) == AnoMes(oModelSRG:GetValue("RG_DTGERAR"))
					aAdd( aPdResCom, { (cAliasSRR)->RR_CC, (cAliasSRR)->RR_PD, (cAliasSRR)->RR_HORAS, (cAliasSRR)->RR_VALOR, Iif(lVerRJ5, (cAliasSRR)->RR_CCBKP, (cAliasSRR)->RR_CC) } )
				EndIf
			Else
				nValorRub			 := ( (cAliasSRR)->RR_VALOR - aPdResCom[nPosPD, 4])
				aPdResCom[nPosPD, 3] := (cAliasSRR)->RR_HORAS
				aPdResCom[nPosPD, 4] := (cAliasSRR)->RR_VALOR
			EndIf

			If nValorRub > 0
				cXml += "<detVerbas>"
				cXml += 	"<codRubr>" + (cAliasSRR)->RR_PD + "</codRubr>"
				cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
				If !lMiddleware .Or. !Empty((cAliasSRR)->RR_HORAS)
					cXml += "<qtdRubr>" + AllTrim(Str((cAliasSRR)->RR_HORAS)) + "</qtdRubr>"
				EndIf
				If !lMiddleware .Or. !Empty(nPercRub)
					cXml += "<fatorRubr>" + Transform(nPercRub,"@E 999.99") + "</fatorRubr>"
				EndIf
				If (!lMiddleware .Or. !Empty((cAliasSRR)->RR_VALOR)) .And. cVersEnvio < "9.0.00"
					If !lMiddleware
						cXml += "<vrUnit>" + AllTrim( Transform(nValorRub, "@E 999999999.99") ) + "</vrUnit>"
					Else
						cXml += "<vrUnit>" + AllTrim( Str(nValorRub) ) + "</vrUnit>"
					EndIf
				EndIf
				If !lMiddleware
					cXml += 	"<vrRubr>" + AllTrim( Transform(nValorRub, "@E 999999999.99") ) + "</vrRubr>"
				Else
					cXml += 	"<vrRubr>" + AllTrim( Str(nValorRub) ) + "</vrRubr>"
				EndIf
				If cVersEnvio >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
					cXml +=         '<indApurIR>0</indApurIR>'
				Endif
				//InformaÁıes de desconto do emprÈstimo em folha
				If cVersEnvio >= "9.3.00"  .And. SRV->RV_NATUREZ == "9253" .And. SRV->RV_INCFGTS == "31"     //Natureza .And. RV_INCFGTS
					lEmpECon := .T.
					aEConsig := fBusEConsR(SRA->RA_FILIAL,SRA->RA_MAT, (cAliasSRR)->RR_PD, (cAliasSRR)->RR_CC, cPeriodo)
					If  Len(aEConsig) > 0
						cXml += '<descFolha>'
						cXml += '	<tpDesc>1</tpDesc>'
						If !Empty(aEConsig[1,5])
							cXml += '	<instFinanc>'+Alltrim(StrZero(Val(aEConsig[1,5]),3))+'</instFinanc>'
						Endif
						If !Empty(aEConsig[1,6])
							cXml += '	<nrDoc>'+ Alltrim(Substr(aEConsig[1,6], 1,15 ) ) +'</nrDoc>'
						Endif
						If !Empty(aEConsig[1,7])
							cXml += '	<observacao>' + Alltrim(aEConsig[1,7]) +'</observacao>'
						Endif
						cXml += '</descFolha>'
					Endif
				Endif

				cXml += "</detVerbas>"
				If !lRel
					lRetIR := (lVbRelIR .And. fVbRelIR(SRV->RV_NATUREZ, ALLTRIM(SRV->RV_INCIRF))) //Confirma que se trata de verba de IR
					If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") .Or. lRetIR)
						fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, cTpInscr, cInscr, cBusca, SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, nValorRub, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""), cIdDmDev, STOD((cAliasSRR)->RR_DATAPAG), SRV->RV_COD, SRV->RV_CODFOL, ANOMES(STOD((cAliasSRR)->RR_DATAPAG)), ,lRetIR)
					EndIf
				EndIf
			EndIf
		EndIf

		(cAliasSRR)->(dbSkip())

		If dLastDate != (cAliasSRR)->RR_DATA .Or. (cAliasSRR)->(Eof())
			If SRA->RA_TPPREVI == "1"
				S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
			EndIf
			If ! Empty(cIndSimp)
				cXml += "<infoSimples>"
				cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			cXml += "</infoPerApur>"
			cXml += "</dmDev>"
		EndIf
		If dLastDate == (cAliasSRR)->RR_DATA .And. cCCAnt <> (cAliasSRR)->RR_CC
			If SRA->RA_TPPREVI == "1"
				S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
			EndIf
			If ! Empty(cIndSimp)
				cXml += "<infoSimples>"
				cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			lFirst := .F.
		EndIf

	EndDo

	(cAliasSRR)->(dbCloseArea())

	If !lRetif
		For nContPd := 1 To Len(aColsRes)
			For nContCols := 1 To Len(aPdResCom)
				If !lVerRJ5
					If aColsRes[nContPd, 12] + aColsRes[nContPd, 3] == aPdResCom[nContCols, 1] + aPdResCom[nContCols, 2]
						aColsRes[nContPd, 15] -= aPdResCom[nContCols, 3]
						aColsRes[nContPd, 16] -= aPdResCom[nContCols, 4]
						aColsRes[nContPd, 17] -= aPdResCom[nContCols, 4]
					Endif
				Else
					If aColsRes[nContPd, 12] + aColsRes[nContPd, 3] == aPdResCom[nContCols, 5] + aPdResCom[nContCols, 2]
						aColsRes[nContPd, 15] -= aPdResCom[nContCols, 3]
						aColsRes[nContPd, 16] -= aPdResCom[nContCols, 4]
						aColsRes[nContPd, 17] -= aPdResCom[nContCols, 4]
					Endif
				EndIf
			Next nContCols
		Next nContPd
	EndIf

	If lVerRJ5
		oTmpTabRR:Delete()
		oTmpTabRR2:Delete()
		oTmpTabRR := Nil
		oTmpTabRR2 := Nil
	EndIf

Return

/*/{Protheus.doc} f1312299
FunÁ„o que verifica se houve o pagamento do roteiro 131 no calculo de rescisao
@author Allyson
@since 06/12/2018
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integraÁ„o no TAF
@param cIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se È complementar por retificaÁ„o
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function f1312299( aCC, aPds, cFilEnv, cIdDmDev, lRetif, aErrosRJ5, cVersaoEnv, cPrefixo)

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local cPerSeek	:= ""
Local cRot131	:= fGetCalcRot("5")//131
Local cSRCSeek	:= ""
Local cSRDSeek	:= ""

Default lRetif		:= .F.
Default aErrosRJ5	:= {}
Default cVersaoEnv  := "2.4"
Default cPrefixo	:= ""

DbSelectArea("SRC")
DbSetOrder(RetOrder("SRC", "RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

If lRetif
	cPerSeek := AnoMes(M->RG_DATADEM)
Else
	cPerSeek := M->RG_PERIODO
EndIf

cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot131 + cPerSeek + M->RG_SEMANA
cIdDmDev := ""
If DbSeek( cSRCSeek )
	While SRC->(!Eof() .And. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRC->RC_PD, SRC->RC_CC, SRC->RC_HORAS, SRC->RC_VALOR, SRC->RC_DATA, SRC->RC_PERIODO, SRC->RC_ROTEIR, cVersaoEnv, @aErrosRJ5, , cPrefixo)
		SRC->(DbSkip())
	EndDo
EndIf

//Procura o roteiro do adiantamento que ja foi fechado referente ao periodo de calculo da rescisao
DbSelectArea("SRD")
DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot131 + cPerSeek + M->RG_SEMANA
If DbSeek( cSRDSeek )
	While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, Nil, @aErrosRJ5, , cPrefixo)
		SRD->(DbSkip())
	EndDo
EndIf

RestArea(aAreaCTT)
RestArea(aAreaSRV)

Return

/*/{Protheus.doc} f1322299
FunÁ„o que verifica se houve o pagamento do roteiro 132 no calculo de rescisao
@author Allyson
@since 24/04/2020
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integraÁ„o no TAF
@param cIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se È complementar por retificaÁ„o
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function f1322299( aCC, aPds, cFilEnv, cIdDmDev, lRetif, aErrosRJ5,cVersaoEnv ,aFilInTaf, lAdmPubl, cTpInsc, cNrInsc, cPrefixo)

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local aAreaRCH	:= RCH->( GetArea() )
Local cPerSeek	:= ""
Local cRot132	:= fGetCalcRot("6")//132
Local cSRCSeek	:= ""
Local cSRDSeek	:= ""
Local dDtPgto	:= cToD("//")
Local dDtPgto12	:= cToD("//")
Local nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )
Local aStatC91      := {}
Local cStatC91      := "-1"

Private nQtdeFol	:= 1
Private lTemEmp		:= !Empty(FWSM0Layout(cEmpAnt, 1))
Private lTemGC		:= fIsCorpManage( FWGrpCompany() )
Private cLayoutGC	:= FWSM0Layout(cEmpAnt)
Private nIniEmp 	:= At("E", cLayoutGC)
Private nTamEmp		:= Len(FWSM0Layout(cEmpAnt, 1))

Default lRetif		:= .F.
Default aErrosRJ5	:= {}
Default cVersaoEnv  := "2.4"
Default aFilInTaf   := {}
Default lAdmPubl	:= .F.
Default cTpInsc		:= ""
Default cNrInsc     := ""
Default cPrefixo	:= ""

aStatC91 := fVerStat( 1, @cFilEnv, M->RG_PERIODO, aClone(aFilInTaf), "2",,,,,,,,lAdmPubl, cTpInsc, cNrInsc  )
cStatC91 := aStatC91[1]

//Obtem a data de pagamento do roteiro 132 em dezembro
RCH->( dbSetOrder(nRchIndex) )
If RCH->( dbSeek( xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + iF(lRetif, AnoMes(M->RG_DATADEM), M->RG_PERIODO) + M->RG_SEMANA + cRot132 ) )
	dDtPgto12 := RCH->RCH_DTPAGO
EndIf

//Ajuste indice para procurar em qual mÍs vem houve pagamento de 13∫ - Decimo terceiro
nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_ANO+RCH_MES" )
RCH->( dbSetOrder(nRchIndex) ) //RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_ANO+RCH_MES
RCH->( dbGoTop() )
RCH->( dbSeek( xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + cRot132 + iF(lRetif, cValToChar(ANO(M->RG_DATADEM)), Substr(M->RG_PERIODO, 1, 4))) )

While RCH->RCH_FILIAL+RCH->RCH_PROCES+RCH->RCH_ROTEIR+RCH->RCH_ANO == xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + cRot132 + iF(lRetif, cValToChar(ANO(M->RG_DATADEM)), Substr(M->RG_PERIODO, 1, 4))
	dDtPgto 	:= RCH->RCH_DTPAGO
	cPerSeek	:= RCH->RCH_PER

	//Rescis„o diferente do mÍs 12 - Dezembro
	//ou Rescis„o em dezembro antes da data de pagamento do 13 e sem integraÁ„o do 1200 anual
	If SUBSTR(DTOS(M->RG_DATADEM),5,2) <> "12" ;
		.Or. (SUBSTR(DTOS(M->RG_DATADEM),5,2) == "12" .And. cStatC91 == "-1" .And. M->RG_DATADEM < dDtPgto12)

		DbSelectArea("SRC")
		DbSetOrder(RetOrder("SRC", "RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

		cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot132 + cPerSeek + M->RG_SEMANA
		If DbSeek( cSRCSeek )
			cIdDmDev := ""
			While SRC->(!Eof() .And. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
				fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRC->RC_PD, SRC->RC_CC, SRC->RC_HORAS, SRC->RC_VALOR, SRC->RC_DATA, SRC->RC_PERIODO, SRC->RC_ROTEIR, cVersaoEnv, @aErrosRJ5, ,cPrefixo)
				SRC->(DbSkip())
			EndDo
		EndIf

		//Procura o roteiro do adiantamento que ja foi fechado referente ao periodo de calculo da rescisao
		DbSelectArea("SRD")
		DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

		cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot132 + cPerSeek + M->RG_SEMANA
		If DbSeek( cSRDSeek )
			cIdDmDev := ""
			While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
				fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, cVersaoEnv, @aErrosRJ5, ,cPrefixo)
				SRD->(DbSkip())
			EndDo
		EndIf
	EndIf
	RCH->(DbSkip())
EndDo

RestArea(aAreaCTT)
RestArea(aAreaSRV)
RestArea(aAreaRCH)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEstabELot
FunÁ„o respons·vel por buscar identifcaÁ„o do estabelecimento e
lotaÁ„o, retornando nos par‚metros passados por referÍncia ( cTpInscr
, cInscr e codLotacao)
@author  Rafael Reis
@since   17/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function fEstabELot(cFil, cCentroC, cTpInscr, cInscr, codLotacao, cCCOrig, cCompete)
Local cFilLocCTT := FWxFilial("CTT", cFil)
Local cFilLocRJ5 := ""
Local cFilTrb	 := ""
Local nPosLot 	 := 0
Local nPosEstb 	 := 0
Local cCEIObra 	 := ""
Local cCAEPF 	 := ""
Local lRJ5FilT	 := RJ5->(ColumnPos("RJ5_FILT")) > 0
Local lTemReg	 := .F.

//Vari·veis private aEstb e aCC declaradas no inÌcio da Faz1200

If !lVerRJ5
	If !Empty(cCentroC) .AND. Len(aCC) > 0
		nPosLot := aScan(aCC,{|x| x[1] == cFilLocCTT .AND. x[2] == cCentroC })
		If nPosLot > 0
			//CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
			If aCC[nPosLot,6] == "01" .And. aCC[nPosLot,3] == "4" .And. aCC[nPosLot,8] == "2"
				cTpInscr	:= aCC[nPosLot,3]
				cInscr		:= aCC[nPosLot,4]
			EndIf
		EndIf
	Endif
Else
	If lRJ5FilT
		//Pesquisa utilizando o novo campo RJ5_FILT
		RJ5->( dbSetOrder(5) )//RJ5_FILIAL+RJ5_COD+RJ5_CC+RJ5_INI
		RJ5->(dbGoTop())
		If RJ5->( dbSeek( xFilial("RJ5", cFil) + cCentroC + cCCOrig ) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_COD == cCentroC .And. RJ5->RJ5_CC == cCCOrig .And. RJ5->RJ5_FILT == cFil
				If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					lTemReg		:= .T.
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
		If !lTemReg
			RJ5->( dbSetOrder(5) )//RJ5_FILIAL+RJ5_COD+RJ5_CC+RJ5_INI
			RJ5->(dbGoTop())
			If RJ5->( dbSeek( xFilial("RJ5", cFil) + cCentroC + cCCOrig ) )
				While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_COD == cCentroC .And. RJ5->RJ5_CC == cCCOrig .And. EMPTY(RJ5->RJ5_FILT)
					If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
						cTpInscr	:= RJ5->RJ5_TPIO
						cInscr  	:= RJ5->RJ5_NIO
					EndIf
					RJ5->( dbSkip() )
				EndDo
			EndIf
		EndIf
	Else
		RJ5->( dbSetOrder(5) )//RJ5_FILIAL+RJ5_COD+RJ5_CC+RJ5_INI
		If RJ5->( dbSeek( xFilial("RJ5", cFil) + cCentroC + cCCOrig ) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_COD == cCentroC .And. RJ5->RJ5_CC == cCCOrig
				If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
	EndIf
EndIf

If Empty(cTpInscr) .OR. Empty(cInscr)
	If fBuscaOBRA( cFil, @cCEIObra )
		cTpInscr := "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
		cInscr 	 := cCEIObra // Codigo da inscricao
	Elseif fBuscaCAEPF( cFil, @cCAEPF )
		cTpInscr := "3"
		cInscr	 := cCAEPF
	Else
		nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFil)})
		If nPosEstb > 0
			cTpInscr	:= aEstb[nPosEstb,3]
			cInscr		:= aEstb[nPosEstb,2]
		EndIf
	EndIf
Endif


cCentroC := StrTran(cCentroC, "&", "&amp;")

If !lVerRJ5
	cFilTrb		:= cFilLocCTT
Else
	cFilLocRJ5 	:= FWxFilial("RJ5", cFil)
	cFilTrb		:= cFilLocRJ5
EndIf
If !Empty(cFilTrb)
	codLotacao := ( cFilTrb + cCentroC )
Else
	codLotacao	:= cCentroC
EndIf

Return

/*/{Protheus.doc} fGrauExp
FunÁ„o que retorna valor para a tag <grauExp>
@author Allyson
@since 14/09/2018
@version 1.0
@return cCod  - CÛdigo de grau de exposiÁ„o
/*/
Static Function fGrauExp()

Local cCod := "1"

If AllTrim(SRA->RA_OCORREN) $ "02#03#04#06#07#08"
	If AllTrim(SRA->RA_OCORREN) $ "02#06"
		cCod := "2"
	ElseIf AllTrim(SRA->RA_OCORREN) $ "03#07"
		cCod := "3"
	Else
		cCod := "4"
	EndIf
EndIf

Return cCod

/*/{Protheus.doc} fFol2299
FunÁ„o que verifica se houve o pagamento do roteiro FOL no calculo de rescisao
@author Allyson
@since 31/07/2019
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integraÁ„o no TAF
@param aIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se È complementar por retificaÁ„o
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function fFOL2299( aCC, aPds, cFilEnv, aIdDmDev, cVersaoEnv, lRetif, cSemana, cPrefixo)

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local cDmDev	:= ""
Local cPerSeek	:= ""
Local cRotFol	:= Iif(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"), fGetRotOrdinar())
Local cSRDSeek	:= ""
Local aCCAux	:= {}
Local aPDsAux	:= {}
Local dDtPgto	:= cToD("//")
Local nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )
Local aErrosRJ5	:= {}

Default cVersaoEnv := "2.4"
Default lRetif 	   := .F.
Default cSemana    := "02"
Default cPrefixo   := ""

If lRetif
	cPerSeek := AnoMes(M->RG_DATADEM)
Else
	cPerSeek := M->RG_PERIODO
EndIf

RCH->( dbSetOrder(nRchIndex) )

//Procura o roteiro da folha que ja foi fechado referente ao periodo de calculo da rescisao
DbSelectArea("SRD")
DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

cSemana := StrZero( Val( cSemana ) - 1, 2 )

While Val(cSemana) > 0
	cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotFol + cPerSeek + cSemana
	If SRD->( DbSeek( cSRDSeek ) )
		While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
			fFOL2299Pd( @aCCAux, @aPDsAux, cFilEnv, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, cVersaoEnv, @aErrosRJ5 )
			SRD->(DbSkip())
		EndDo
	EndIf
	If !Empty(aPDsAux)
		If RCH->( dbSeek( xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + cPerSeek + cSemana + cRotFol ) )
			dDtPgto := RCH->RCH_DTPAGO
		EndIf
		If Empty(cPrefixo)
			cDmDev := SRA->RA_FILIAL + dToS(dDtPgto) + cPerSeek + cRotFol
		Else
			cDmDev := cPrefixo + dToS(dDtPgto) + cPerSeek + cRotFol
		EndIf

		aAdd( aIdDmDev, cDmDev )
		aAdd( aCC, aClone(aCCAux) )
		aAdd( aPds, aClone(aPDsAux) )

		//Guarda a data de pagamento de cada DmDev
		If aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3]+x[4] == SRA->RA_FILIAL+SRA->RA_MAT+cDmDev+dToS(dDtPgto) }) == 0
			aAdd(aDtPgtDmDev, { SRA->RA_FILIAL, SRA->RA_MAT, cDmDev, dToS(dDtPgto) } )
		EndIf
	EndIf
	cSemana := StrZero( Val( cSemana ) - 1, 2 )
	aCCAux  := {}
	aPDsAux := {}
EndDo

RestArea(aAreaCTT)
RestArea(aAreaSRV)

Return

/*/{Protheus.doc} fFOL2299Pd
FunÁ„o que verifica as verbas pagas do roteiro FOL no calculo de rescisao
@author Allyson
@since 31/07/2019
@version 1.0
@param aCC 	 		- Array com os centros de custo
@param aPds	 		- Array com as verbas
@param cFilEnv		- Filial de integraÁ„o no TAF
@param aIdDmDev		- Identificador do dmDev
@param cCodPd		- CÛdigo da verba
@param cCodCC		- CÛdigo do centro de custo
@param nHoras		- Horas da verba
@param nValor		- Valor da verba
@param dDtPgto		- Data de pagamento da verba
@param cPeriodo		- Periodo da verba
@param cRoteiro		- Roteiro da verba
@param cVersaoEnv	- Vers„o de envio
@param aErrosRJ5	- Array com centros de custo sem relacionamento na RJ5
/*/
Function fFOL2299Pd( aCC, aPds, cFilEnv, cCodPd, cCodCC, nHoras, nValor, dDtPgto, cPeriodo, cRoteiro, cVersaoEnv, aErrosRJ5 )

Local cCEIObra		:= ""
Local cCAEPF		:= ""
Local cChaveCC		:= ""
Local cChaveCCPD	:= ""
Local cChaveS1005	:= ""
Local cCodLot		:= ""
Local cCodRubr		:= ""
Local cIdeRubr		:= ""
Local cInscr		:= ""
Local cPrcRubr		:= ""
Local cTpInscr		:= ""
Local cTpLot		:= ""
Local cVerbIRF		:= ""
Local cIncIrf		:= ""
Local lGeraCod		:= .F.
Local lSemFilSRV	:= .F.
Local nPosCC		:= 0
Local nPosCCPD		:= 0
Local nPosEstb		:= 0
Local lRJ5FilT 		:= RJ5->(ColumnPos("RJ5_FILT")) > 0
Local lTemReg		:= .F.
Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0 .And. cVersaoEnv >= "9.0"
Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0 .And. cVersaoEnv >= "9.0"


Default cVersaoEnv	:= "2.4"
Default aErrosRJ5	:= {}

cChaveCCPD	:= cCodCC + cCodPd
cChaveCC	:= cCodCC

nPosCCPD	:= Ascan( @aPds, {|X| X[1] == cChaveCCPD })
nPosCC		:= Ascan( @aPds, {|X| X[12] == cChaveCC })

SRV->(DbSetOrder(1))
If( SRV->( dbSeek( xFilial("SRV", SRA->RA_FILIAL) + cCodPd  ) ) )

	If ( cVersaoEnv < "2.6.00" .And. Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83" )
		Return()
	Endif

	//Tratamento de compartilhamento da tabela SRV
	If !Empty(SRV->RV_FILIAL)
		lGeraCod := .T.
	Else
		lSemFilSRV := .T.
	EndIf
	//------------------
	//| LÛgica lGeraCod
	//| .T. -> Exclusiva | .F. -> Compartilhada
	//------------------------------------------
	If lGeraCod
		cIdeRubr := SRV->RV_FILIAL
	Else
		If cVersaoEnv >= "2.3"
			cIdeRubr := cEmpAnt
		Else
			cIdeRubr := ""
		EndIf
	EndIf
	If lMiddleware
		cIdeRubr := fGetIdRJF( SRV->RV_FILIAL, cIdeRubr )
	EndIf
	cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
	If (SRV->RV_PERC - 100) < 0
		cPrcRubr :=	0	//Percent da Rubrica
	Else
		cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
	EndIf
EndIf

If !lVerRJ5
	CTT->(DbSetOrder(1))
	If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + cCodCC ) ) )
		cCodLot := IIf(Empty(xFilial("CTT", SRA->RA_FILIAL)), CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
		cTpLot  := CTT->CTT_TPLOT	// Tipo de LotaÁ„o (?!?)

		//Verifica se eh uma obra por meio do campo CTT_TIPO2
		If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
			cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
			cInscr   	:= CTT->CTT_CEI2  // Codigo da inscricao
			cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
		Endif
	EndIf
Else
	RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
	If RJ5->( !dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
		If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
			aAdd( aErrosRJ5, cCodCC )
		EndIf
	Else
		If lRJ5FilT
			RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
			RJ5->(dbGoTop())
			RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC + SRA->RA_FILIAL) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. RJ5->RJ5_FILT == SRA->RA_FILIAL
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					lTemReg		:= .T.
				EndIf
				RJ5->( dbSkip() )
			EndDo
			//Se n„o encontrou um registro com cÛdigo preenchido reposiciona a tabela e executa o dbseek novamente.
			If !lTemReg
				RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
				RJ5->(dbGoTop())
				RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
				While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. EMPTY(RJ5->RJ5_FILIAL)
					If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
						cTpInscr	:= RJ5->RJ5_TPIO
						cInscr  	:= RJ5->RJ5_NIO
						cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
						cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					EndIf
					RJ5->( dbSkip() )
				EndDo
			EndiF
		Else
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
		If Empty(cCodLot)
			If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
				aAdd( aErrosRJ5, cCodCC )
			EndIf
		EndIf
		nPosCCPD	:= Ascan( @aPds,{|X| X[20] == cCodLot + cCodPd })
		nPosCC		:= Ascan( @aPds,{|X| X[19] == cCodLot })
	EndIf
EndIf

//Verifica na tabela F0F se a Filial eh uma obra
If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	cCEIObra := ""
	If fBuscaOBRA( cFilEnv, @cCEIObra )
		cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
		cInscr 	 	:= cCEIObra // Codigo da inscricao
		cChaveS1005 := cFilEnv+cInscr
	Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
		cTpInscr 	:= "3"
		cInscr	 	:= cCAEPF
		cChaveS1005 := cFilEnv+cInscr
	EndIf
EndIf

If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	nPosEstb := eVal(bEstab)
	If nPosEstb > 0
		cTpInscr	:= aEstb[nPosEstb,3]
		cInscr		:= aEstb[nPosEstb,2]
		cChaveS1005 := SRA->RA_FILIAL+cInscr
	EndIf
EndIf

If(nPosCC == 0)
	aAdd(aCC, {cCodCC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
EndIf

//------------------------------------------------
//| Array de Dados
//| Montagem do array com os dados a utilizar para o XML
//-------------------------------------------------------
If( nPosCCPD > 0 )
	aPds[nPosCCPD, 15] += nHoras	//Incrementa Valor
	aPds[nPosCCPD, 17] += nValor	//Incrementa Valor
	aPds[nPosCCPD, 18] += 1	  		//Incrementa Contador
Else
	aAdd(aPds, { 	cCodCC + cCodPd,;	    			//01 - Chave para pesquisa (CC+PD)
					"Dados da Verba",;					//02 - Separador - Verbas/Rubricas
					cCodRubr,;							//03 - Codigo da Rubrica
					cIdeRubr,;							//04 - Ident   da Rubrica
					cPrcRubr,;							//05 - Percent da Rubrica
					"Dados do CC",;						//06 - Separador - Centro de Custo
					cCodLot,;							//07 - Codigo da LotaÁ„o
					cTpInscr,;							//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
					cInscr,;							//09 - Codigo da inscricao
					cTpLot,;							//10 - Tipo de LotaÁ„o (?!?)
					"Dados da Grid",;					//11 - Separador - Centro de Custo
					cCodCC,;							//12 - Centro de Custo
					cCodPd,;							//13 - Verba da rescis„o
					SRV->RV_DESC,;						//14 - Descricao da verba
					nHoras,;							//15 - Horas da verba
					nValor,;							//16 - Valor da verba
					nValor,;							//17 - Acumulado da verba (valor inicial para soma)
					1,;									//18 - Numero de registro repetidos (CC + PD)
					cCodLot,;							//19 - CÛdigo de lotaÁ„o
					cCodLot + cCodPd,;					//20 - Chave para pesquisa (CÛdigo LotaÁ„o+PD)
					SRV->RV_NATUREZ,;					//21 - Natureza da verba
					SRV->RV_INCCP,;						//22 - IncidÍncia CP da verba
					SRV->RV_INCFGTS,;					//23 - IncidÍncia FGTS da verba
					SRV->RV_INCIRF,;					//24 - IncidÍncia IRRF da verba
					SRV->RV_TIPOCOD,;					//25 - Tipo da verba
					If(lRVIncop, SRV->RV_INCOP,""),;	//26 - Incid RPPS
					If(lRVTetop, SRV->RV_TETOP,"") })	//27 - Teto Remun


EndIf

Return

/*/{Protheus.doc} fVerRJ5B()
FunÁ„o que verifica o relacionamento da tabela RJ5 e utiliza o centro de custo informado em RJ5_COD
A troca È efetuada manualmente pois cada centro de custo pode ter um relacionamento diferente, com
inÌcio de validade diferente, o que impossibilita o "Inner Join" na query dos lanÁamentos
@type function
@author allyson.mesashi
@since 03/04/2019
@version 1.0
@param cRHHAlias	= Alias da tabela tempor·ria principal
@param cRHHRJ5		= Alias da tabela tempor·ria auxiliar
@param cPeriod		= PerÌodo para verificaÁ„o da validade
@param lRJ5Ok		= Flag de cadastro do relacionamento na RJ5
@param aErrosRJ5	= Array com os centros de custo que n„o foram encontrados
/*/
Static Function fVerRJ5B(cRHHAlias, cRHHRJ5, cPeriod, lRJ5Ok, aErrosRJ5)
	Local aColumns	 := {}
	Local cKeyAux	 := ""
	Local cCCAnt	 := ""
	Local cCCRJ5	 := ""
	Local lNovo		 := .F.
	Local lRJ5FilT	 := RJ5->(ColumnPos("RJ5_FILT")) > 0
	Local lTemReg    := .F.

	aAdd( aColumns, { "RHH_FILIAL"	,"C",FwGetTamFilial,0 })
	aAdd( aColumns, { "RHH_MAT"		,"C",nTamMat,0})
	aAdd( aColumns, { "RHH_MESANO"	,"C",6,0})
	aAdd( aColumns, { "RHH_DATA"	,"C",6,})
	aAdd( aColumns, { "RHH_VB"		,"C",nTamVb,0})
	aAdd( aColumns, { "RHH_CC"		,"C",nTamCC,0})
	aAdd( aColumns, { "RHH_VERBA"	,"C",nTamVb,0})
	aAdd( aColumns, { "RHH_DTACOR"	,"C",8,0})
	aAdd( aColumns, { "RHH_VALOR"	,"N",nTamVal,nDecVal})
	aAdd( aColumns, { "RHH_HORAS"	,"N",nTamHor,nDecHor})
	aAdd( aColumns, { "RHH_CCBKP"	,"C",nTamCC,0})

	//Cria uma tabela tempor·ria auxiliar
	oTmpTabRH := FWTemporaryTable():New(cRHHRJ5)
	oTmpTabRH:SetFields( aColumns )
	oTmpTabRH:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabRH:Create()

	//Percorre o resultado da query da SRD/SRC e verifica o relacionamento na RJ5, efetuando troca do RD_CC por RJ5_COD
	//gravando o resultado na tabela tempor·ria auxiliar
	While (cRHHAlias)->(!Eof())
		lNovo	:= (cRHHRJ5)->( !dbSeek( (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT+(cRHHAlias)->RHH_MESANO+(cRHHAlias)->RHH_DATA+(cRHHAlias)->RHH_CC+(cRHHAlias)->RHH_VB ) )
		lTemReg	:= .F.
		If RecLock(cRHHRJ5, lNovo)
			If lNovo
				(cRHHRJ5)->RHH_FILIAL 	:= (cRHHAlias)->RHH_FILIAL
				(cRHHRJ5)->RHH_MAT 		:= (cRHHAlias)->RHH_MAT
				(cRHHRJ5)->RHH_MESANO 	:= (cRHHAlias)->RHH_MESANO
				(cRHHRJ5)->RHH_DATA 	:= (cRHHAlias)->RHH_DATA
				(cRHHRJ5)->RHH_VB 		:= (cRHHAlias)->RHH_VB

				If cCCAnt != (cRHHAlias)->RHH_CC
					cCCAnt := (cRHHAlias)->RHH_CC
					cCCRJ5 := ""
					//Se possui o campo RJ5_FILT pesquisa na RJ5 com este campo preenchido
					If lRJ5FilT
						RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC + (cRHHAlias)->RHH_FILIAL) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC .And. RJ5->RJ5_FILT == (cRHHAlias)->RHH_FILIAL
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 	:= RJ5->RJ5_COD
									lTemReg	:= .T.
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
						//Se n„o encontrou registro refaz a pesquisa da forma antiga
						If !lTemReg
							RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
							RJ5->(dbGoTop())
							If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC) )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC .And. EMPTY(RJ5->RJ5_FILT)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						EndIf
						If Empty(cCCRJ5)
							lRJ5Ok 	:= .F.
							If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
								aAdd( aErrosRJ5, cCCAnt )
							EndIf
						EndIf
					Else
						RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
						If Empty(cCCRJ5)
							lRJ5Ok 	:= .F.
							If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
								aAdd( aErrosRJ5, cCCAnt )
							EndIf
						EndIf
					EndiF
				EndIf

				(cRHHRJ5)->RHH_CC 		:= cCCRJ5
				(cRHHRJ5)->RHH_VERBA 	:= (cRHHAlias)->RHH_VERBA
				(cRHHRJ5)->RHH_DTACOR 	:= (cRHHAlias)->RHH_DTACOR
				(cRHHRJ5)->RHH_CCBKP	:= cCCAnt
			EndIf
			(cRHHRJ5)->RHH_VALOR	+= (cRHHAlias)->RHH_VALOR
			(cRHHRJ5)->RHH_HORAS	+= (cRHHAlias)->RHH_HORAS

			(cRHHRJ5)->(MsUnlock())
		EndIf
		(cRHHAlias)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbCloseArea() )
	(cRHHRJ5)->( dbGoTop() )

	//Cria uma tabela tempor·ria com o mesmo alias da query da SRD/SRC
	oTmpTabl2 := FWTemporaryTable():New(cRHHAlias)
	oTmpTabl2:SetFields( aColumns )
	oTmpTabl2:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabl2:Create()

	//Percorre a tabela tempor·rio auxiliar gravando o resultado na tabela tempor·ria com o mesmo alias da query da SRD/SRC
	While (cRHHRJ5)->(!Eof())
		lNovo	:= (cRHHAlias)->( !dbSeek( (cRHHRJ5)->RHH_FILIAL+(cRHHRJ5)->RHH_MAT+(cRHHRJ5)->RHH_MESANO+(cRHHRJ5)->RHH_DATA+(cRHHRJ5)->RHH_CC+(cRHHRJ5)->RHH_VB ) )
		If RecLock(cRHHAlias, lNovo)
			If lNovo
				(cRHHAlias)->RHH_FILIAL := (cRHHRJ5)->RHH_FILIAL
				(cRHHAlias)->RHH_MAT 	:= (cRHHRJ5)->RHH_MAT
				(cRHHAlias)->RHH_MESANO := (cRHHRJ5)->RHH_MESANO
				(cRHHAlias)->RHH_DATA	:= (cRHHRJ5)->RHH_DATA
				(cRHHAlias)->RHH_VB		:= (cRHHRJ5)->RHH_VB
				(cRHHAlias)->RHH_CC		:= (cRHHRJ5)->RHH_CC
				(cRHHAlias)->RHH_VERBA	:= (cRHHRJ5)->RHH_VERBA
				(cRHHAlias)->RHH_DTACOR	:= (cRHHRJ5)->RHH_DTACOR
				(cRHHAlias)->RHH_CCBKP	:= (cRHHRJ5)->RHH_CCBKP
			EndIf
			(cRHHAlias)->RHH_VALOR	+= (cRHHRJ5)->RHH_VALOR

			(cRHHAlias)->(MsUnlock())
		EndIf
		(cRHHRJ5)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fIntResLot()
Cria um browse que permite a seleÁ„o dos funcion·rios para a integraÁ„o em lote do desligamento para eSocial
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Function fIntResLot(lRel)

Local aArea			:= GetArea()
Local aAreaSRA		:= SRA->( GetArea() )
Local aAreaSRG		:= SRG->( GetArea() )
Local aAreaSX3		:= SX3->( GetArea() )
Local aFieldFilt	:= {}
Local aSeek			:= {}
Local oTmpTable		:= Nil
Local lLibAtu		:= (GetApoInfo("FWFORMBROWSE.PRW")[4] > sToD("20200401"))

Private aMarcSRG	:= {}
Private _MarcReg	:= {}
Private aGpm040Log	:= {}
Private cAliasMark 	:= "TABAUX"
Private aSrgStruct	:= SRG->(DBSTRUCT())
Private oExcel		:= Nil

Default lRel 		:= .F. //Indica se foi executada a rotina de geraÁ„o do relatÛrio S-2299

Static _Marcados	:= {}

fCriaTmp(@oTmpTable, @aSrgStruct, @aFieldFilt, lRel)
aColsMark:= fMntColsMark(aSrgStruct)

aAdd(aSeek, {STR0213,{{"", "C", FwGetTamFilial+TamSX3("RG_MAT")[1]+8, 0, "RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)", "@!"}} } )//"Filial + Matricula + Data Geracao"

oBrowse := FWMarkBrowse():New()
oBrowse:SetAlias((cAliasMark))
oBrowse:SetFields(aColsMark)
oBrowse:SetFieldMark("RG_OKTRANS")
oBrowse:SetMenuDef('')
oBrowse:AddButton(If(lRel, OemToAnsi(STR0328), OemToAnsi(STR0196)), {|| ProcGpe( {|lEnd| fEnvLote(lRel)}, "" )},,,, .F., 2 ) //"Gerar RelatÛrio" "Integrar"
oBrowse:SetDescription(If(lRel,  OemToAnsi(STR0329), OemToAnsi(STR0197))) //"Rescisıes" | "GeraÁ„o RelatÛrio Excel S-2299"

//Se a lib estiver atualizada libera a utilizaÁ„o de filtro padr„o na MarkBrowse
If lLibAtu
	oBrowse:SetFieldFilter(aFieldFilt)
Else
	Aviso(OemToAnsi(STR0001), OemToAnsi(STR0243), {OemToAnsi(STR0038)})
EndIf

oBrowse:SetSeek(.T., aSeek)
oBrowse:SetAfterMark({|| fMarca() })
oBrowse:SetAllMark({|| fMarkAll() })
oBrowse:Activate()

If ValType(oTmpTable) == "O"
	oTmpTable:Delete()
EndIf
_Marcados := {}
RestArea(aArea)
RestArea(aAreaSRA)
RestArea(aAreaSRG)
RestArea(aAreaSX3)

Return

/*/{Protheus.doc} fCriaTmp()
Efetua filtro dos registros da tabela SRG aptos a serem integrados
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fCriaTmp(oTmpTable, aColumns, aFldFilter, lRel)

Local cAliasSRG	:= GetNextAlias()
Local cValidFil	:= ""
Local nCont		:= 0
Local nPos		:= 0
Local cTrabSvinc:= fCatTrabEFD("TSV")

Default lRel := .F.

// Filtro das filiais que o usu·rio tem acesso
If Len(fValidFil()) <= 2000
	cValidFil := "(AllTrim(SRG->RG_FILIAL) $ '" + fValidFil() + "')"
Else
	cValidFil := "(!AllTrim(SRG->RG_FILIAL) $ '" + fValidFil(, .T.) + "')"
EndIf

aAdd( aColumns, { "RG_OKTRANS","C",02,00 })

If (nPos := aScan( aColumns, { |x| x[1] == "RG_MAT" } )) > 0
	aAdd( aColumns )
	aIns( aColumns, nPos+1 )
	aColumns[nPos+1] := { "RG_NOME","C",TamSx3("RG_NOME")[1],00 }
	aAdd( aColumns )
	aIns( aColumns, nPos+2 )
	aColumns[nPos+2] := { "RA_CATEFD","C",3,00 }
EndIf
If (nPos := aScan( aColumns, { |x| x[1] == "RG_TIPORES" } )) > 0
	aAdd( aColumns )
	aIns( aColumns, nPos+1 )
	aColumns[nPos+1] := { "RG_DESCTPR","C",TamSx3("RG_DESCTPR")[1],00 }
EndIf
If (nPos := aScan( aColumns, { |x| x[1] == "RA_NOME" } )) > 0
	aDel( aColumns, nPos )
	aSize( aColumns, Len(aColumns)-1)
EndIf

//Efetua a criacao do arquivo temporario
oTmpTable := FWTemporaryTable():New(cAliasMark)
oTmpTable:SetFields( aColumns )
oTmpTable:AddIndex( "TABAUX1", {"RG_FILIAL","RG_MAT", "RG_DTGERAR"} )
oTmpTable:Create()

cWhere := "SRG.RG_EFETIVA = 'S' "
cWhere += "AND SRG.D_E_L_E_T_ = ' '"
cWhere := "% " + cWhere + " %"

BeginSql alias cAliasSRG
	SELECT  R_E_C_N_O_ AS RECNOSRG
	FROM %table:SRG% SRG
	WHERE %exp:cWhere%
	ORDER BY SRG.RG_FILIAL, SRG.RG_MAT, SRG.RG_DTGERAR
EndSql

SRA->(dbSetOrder(1))
While (cAliasSRG)->(!Eof())
	SRG->( dbGoto( (cAliasSRG)->RECNOSRG ) )
	If !( &( cValidFil ) )
		(cAliasSRG)->(dbSkip())
		Loop
	EndIf
	If SRA->( dbSeek( SRG->RG_FILIAL+SRG->RG_MAT ) ) .And. (!lRel .Or. (lRel .And. !(SRA->RA_CATEFD $ cTrabSVinc) .And. !Empty(SRA->RA_CATEFD)))
		If RecLock(cAliasMark,.T.)
			(cAliasMark)->RG_FILIAL 	:= SRG->RG_FILIAL
			(cAliasMark)->RG_MAT 		:= SRG->RG_MAT
			(cAliasMark)->RG_NOME	 	:= SRA->RA_NOME
			(cAliasMark)->RA_CATEFD	 	:= SRA->RA_CATEFD
			(cAliasMark)->RG_EFETIVA	:= SRG->RG_EFETIVA
			(cAliasMark)->RG_SABDOM 	:= SRG->RG_SABDOM
			(cAliasMark)->RG_TIPORES	:= SRG->RG_TIPORES
			(cAliasMark)->RG_DESCTPR	:= fDescRCC("S043",SRG->RG_TIPORES,1,2,3,30)
			(cAliasMark)->RG_DTAVISO 	:= SRG->RG_DTAVISO
			(cAliasMark)->RG_DAVISO  	:= SRG->RG_DAVISO
			(cAliasMark)->RG_DAVCUM 	:= SRG->RG_DAVCUM
			(cAliasMark)->RG_DAVIND 	:= SRG->RG_DAVIND
			(cAliasMark)->RG_DATADEM 	:= SRG->RG_DATADEM
			(cAliasMark)->RG_DATAHOM	:= SRG->RG_DATAHOM
			(cAliasMark)->RG_DTGERAR	:= SRG->RG_DTGERAR
			(cAliasMark)->RG_DTPROAV	:= SRG->RG_DTPROAV
			(cAliasMark)->RG_MEDATU 	:= SRG->RG_MEDATU
			(cAliasMark)->RG_DFERVEN	:= SRG->RG_DFERVEN
			(cAliasMark)->RG_DFERPRO 	:= SRG->RG_DFERPRO
			(cAliasMark)->RG_DFERAVI  	:= SRG->RG_DFERAVI
			(cAliasMark)->RG_NORMAL  	:= SRG->RG_NORMAL
			(cAliasMark)->RG_DESCANS 	:= SRG->RG_DESCANS
			(cAliasMark)->RG_SALMES  	:= SRG->RG_SALMES
			(cAliasMark)->RG_SALDIA 	:= SRG->RG_SALDIA
			(cAliasMark)->RG_SALHORA	:= SRG->RG_SALHORA
			(cAliasMark)->RG_PROCES 	:= SRG->RG_PROCES
			(cAliasMark)->RG_COMPRAV 	:= SRG->RG_COMPRAV
			(cAliasMark)->RG_JTCUMPR	:= SRG->RG_JTCUMPR
			(cAliasMark)->RG_IDCMPL  	:= SRG->RG_IDCMPL
			(cAliasMark)->RG_RESCDIS	:= SRG->RG_RESCDIS
			(cAliasMark)->RG_RRA    	:= SRG->RG_RRA
			(cAliasMark)->RG_TPAVISO 	:= SRG->RG_TPAVISO
			(cAliasMark)->RG_RHEXP    	:= SRG->RG_RHEXP
			(cAliasMark)->RG_NPROC   	:= SRG->RG_NPROC
			(cAliasMark)->RG_OBITO   	:= SRG->RG_OBITO
			(cAliasMark)->RG_PERIODO 	:= SRG->RG_PERIODO
			(cAliasMark)->RG_ROTEIR 	:= SRG->RG_ROTEIR
			(cAliasMark)->RG_SUCES  	:= SRG->RG_SUCES
			(cAliasMark)->RG_OBS    	:= SRG->RG_OBS
			(cAliasMark)->RG_SEMANA  	:= SRG->RG_SEMANA
			(cAliasMark)->RG_TPDIR  	:= SRG->RG_TPDIR
			(cAliasMark)->RG_INDAV   	:= SRG->RG_INDAV
			(cAliasMark)->RG_NPROCS   	:= SRG->RG_NPROCS
			(cAliasMark)->RG_TPSU     	:= SRG->RG_TPSU
			(cAliasMark)->RG_PDRESC  	:= SRG->RG_PDRESC
			If SRG->(ColumnPos("RG_NOVSUBS")) > 0
				(cAliasMark)->RG_NOVSUBS  	:= SRG->RG_NOVSUBS
			EndIf
			If SRG->(ColumnPos("RG_CTOBRA")) > 0
				(cAliasMark)->RG_CTOBRA  	:= SRG->RG_CTOBRA
			EndIf
			(cAliasMark)->(MsUnlock())
		EndIf
	EndIf
	(cAliasSRG)->( dbSkip() )
EndDo
(cAliasSRG)->( dbCloseArea() )

For nCont := 1 To Len(aColumns)
	aAdd( aFldFilter, { aColumns[nCont, 1], FWX3Titulo( aColumns[nCont, 1] ), aColumns[nCont, 2], aColumns[nCont, 3], aColumns[nCont, 4], X3Picture( aColumns[nCont, 1] ) } )
Next nCont

Return

/*/{Protheus.doc} FMntColsMark
Carrega tabela tempor·ria com dados para exibiÁ„o na MarkBrowse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fMntColsMark(aCampos)

Local aArea		:= GetArea()
Local aColsAux 	:=`{}
Local aColsSX3	:= {}
Local nX		:= 0

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCampos)
	If SX3->( dbSeek(aCampos[nX,1]) )
		aColsSX3 := {X3Titulo(), &("{||(cAliasMark)->"+(aCampos[nX,1])+"}"), SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
		aAdd(aColsAux,aColsSX3)
		aColsSX3 := {}
	EndIf
Next nX

RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} fMarca
Realiza a marcaÁ„o de um registro no browse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fMarca()

Local cKey := (cAliasMark)->RG_FILIAL + (cAliasMark)->RG_MAT + dToS((cAliasMark)->RG_DTGERAR)
Local nPos := aScan( aMarcSRG, { |x| ( x[1] == cKey )})

If oBrowse:IsMark()
	Aadd( aMarcSRG, { (cAliasMark)->RG_FILIAL + (cAliasMark)->RG_MAT + dToS((cAliasMark)->RG_DTGERAR) } )
	Aadd(_Marcados, oBrowse:At())
Else
	If ( nPos > 0 )
		nLastSize := Len( aMarcSRG )
		aDel( aMarcSRG, nPos )
		aDel(_Marcados, nPos)
		aSize( aMarcSRG, ( nLastSize - 1 ))
		aSize(_Marcados, ( nLastSize - 1 ))
	EndIF
EndIf

Return

/*/{Protheus.doc} fMarkAll
Faz a marcaÁ„o de todos os registros do browse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fMarkAll()

Local nUltimo

oBrowse:GoBottom(.F.)
nUltimo := oBrowse:At()
oBrowse:GoTop()

While .T.
	oBrowse:MarkRec()
	If nUltimo == oBrowse:At()
		oBrowse:GoTop()
		Exit
	EndIf
	oBrowse:GoDown()
EndDo

Return

/*/{Protheus.doc} fClear
Limpa as marcaÁıes do browse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fClear()

While Len(_Marcados) >= 1
	oBrowse:GoTo(_Marcados[1])
	oBrowse:MarkRec()
EndDo

oBrowse:Refresh(.T.)

Return

/*/{Protheus.doc} fEnvLote()
Efetua validaÁ„o e envio do desligamento ao eSocial
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fEnvLote(lRel)

Local aErros	:= {}
Local aLogTitle	:= { STR0198 }//"Rescisıes Processadas:"
Local aLogFile	:= {}
Local aTpAlt 	:= {.F.,.F.,.F.}
Local cBkpFil	:= cFilAnt
Local cTrabVincu:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
Local cStatus0 	:= "-1"
Local cVersEnvio:= ""
Local lGravou	:= .T.
Local lResComp	:= .F.
Local lRetif	:= .F.
Local lGeraMat	:= .F.
Local lTemMat	:= SRA->(ColumnPos("RA_DESCEP")) > 0
Local nCont		:= 0
Local nX		:= 0
Local nI		:= 0
Local oModel	:= Nil
Local oModelSRG	:= Nil
Local oGrid		:= Nil
Local cBkpTpRes	:= ""
Local cArquivo	:= "RELATORIO_S2299.xls"
Local cDefPath	:= GetSrvProfString( "StartPath", "\system\" )
Local cPath		:= ""

Private aIncRes		:= {}
Private aPd_Aux		:= {}
Private dDataDem1	:= cToD("//")
Private aInfoC		:= {}
Private cTpInsc  	:= ""
Private lAdmPubl 	:= .F.
Private cNrInsc  	:= "0"
Private cChaveMid	:= ""
Private cErro		:= "0"

Default lRel	:= .F. //Indica se foi executada a rotina de geraÁ„o do relatÛrio S-2299

//Pergunta ao usu·rio o local de gravaÁ„o do relatÛrio.
If lRel
	cPath	:= cGetFile( OemToAnsi(STR0335) + "|*.*", OemToAnsi(STR0336), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )//"DiretÛrio"##"Selecione um diretÛrio para a geraÁ„o do relatÛrio"
	//Cancela execuÁ„o do relatÛrio se n„o for selecionado um diretÛrio
	If Empty(cPath)
		Return()
	ElseIf !ExistDir(cPath)
		MsgAlert(OemToAnsi(STR0335) + cPath + OemToAnsi(STR0376), OemToAnsi(STR0001))  //"DiretÛrio inv·lido"
		cPath := ""
		Return()
	EndIf
EndIf

If Len(aMarcSRG) < 1
	Help(' ', 1, STR0020, , STR0199, 1, 0) //"AtenÁ„o"##"Nenhuma rescis„o foi selecionada."
	Return
EndIf
GPProcRegua( Len(aMarcSRG) )
oBrowse:Refresh(.T.)
fVersEsoc( "S2299", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME
(cAliasMark)->( dbSetOrder(1) )//RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
SRG->( dbSetOrder(1) )//RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
For nCont := 1 To Len(aMarcSRG)
	(cAliasMark)->( dbSeek( aMarcSRG[nCont, 1] ) )
	SRG->( dbSeek( aMarcSRG[nCont, 1] ) )
	SRA->( dbSeek( (cAliasMark)->RG_FILIAL+(cAliasMark)->RG_MAT ) )
	GPIncProc(STR0009 + SRA->RA_FILIAL + SRA->RA_MAT )//"MatrÌcula: "
	aErros		:= {}
	aErroRes	:= {}
	aTpAlt 		:= {.F.,.F.,.F.}
	cFilAnt		:= SRA->RA_FILIAL
	lGravou 	:= .T.
	lResComp 	:= .F.
	lRet		:= .T.
	lRetif		:= .F.
	lGeraMat	:= Iif(lTemMat, SRA->RA_DESCEP == "1", .F.)
	nI			:= 0

	oModel 		:= FWLoadModel("GPEM040")
	oModelSRG	:= oModel:GetModel('GPEM040_MSRG')
	oGrid 		:= oModel:GetModel('GPEM040_MGET')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	fUpdAtBrw(.F.)
	oModel:Activate()

	If fResCompl(Nil ,.T., Nil, @lResComp, @lRetif, lRel)
		cCdEFD := fM40TPRES( oModelSRG:GetValue("RG_TIPORES"), , oModelSRG:GetValue("RG_TIPORES") <> cBkpTpRes,oModelSRG:GetValue("RG_DATADEM") )
		cBkpTpRes :=  oModelSRG:GetValue("RG_TIPORES")
		lRet := fM40VLRES( 	AllTrim( oModelSRG:GetValue("RG_TPAVISO") ),;	//Tipo Aviso
								cCdEFD,;									//Tipo Rescisao eSocial
								oModelSRG:GetValue("RG_DATADEM"),;				//Data de Demissao
								oModelSRG:GetValue("RG_OBITO"),;				//Certidao Obito (n„o tem esse codigo)
								"1",;										//Rescisao Coletiva (1=Rescisao Simples / 2=Rescisao Coletiva)
								oModelSRG:GetValue("RG_INDAV"),;				//
								@aErroRes,;									//Erro na persistÍncia dos dados da rescisao
								.F.,;
								cVersEnvio,;
								Nil,;
								.T.,;
								lRel)
		If !lRet
			lGravou := .F.
		EndIf
		If lGravou
			If SRA->RA_CATEFD $ cTrabVincu
				cCPF := AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
			Else
				If !lMiddleware
					If cVersEnvio >= "9.0"
						cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					Else
						cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					EndIf
				Else
					cCPF := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
				EndIf
			EndIf
			If SRA->RA_CATEFD $ cTrabVincu
				If !lMiddleware
					cStatus1 := TAFGetStat( "S-2200", cCPF)
				Else
					cStatus1 := "-1"
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					aInfoC   := fXMLInfos()
					If LEN(aInfoC) >= 4
						cTpInsc  := aInfoC[1]
						lAdmPubl := aInfoC[4]
						cNrInsc  := aInfoC[2]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStatus1 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStatus1 )
				EndIf
			Else
				If !lMiddleware
					cStatus1 := TAFGetStat( "S-2300", cCPF)
				Else
					fPosFil( cEmpAnt, cFilAnt )
					aInfoC   := fXMLInfos()
					If LEN(aInfoC) >= 4
						cTpInsc  := aInfoC[1]
						lAdmPubl := aInfoC[4]
						cNrInsc  := aInfoC[2]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
					cStatus1 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStatus1 )
				EndIf
			EndIf
			If cStatus0 == '2' .OR. cStatus1 == '2'
				cErro := "2"
			ElseIf cStatus0 == '3' .OR. cStatus1 == '3' .OR. cStatus0 == ' ' .OR. cStatus1 == ' ' .OR. cStatus0 == '1' .OR. cStatus1 == '1'
				cErro := " |1|3"
			ElseIf cStatus0 == '-1' .AND. cStatus1 == '-1'
				cErro := "-1"
			ElseIf cStatus0 == '-1' .AND. cStatus1 == '6'
				cErro := "6"
			ElseIf cStatus0 == '-1' .AND. cStatus1 == '7'
				cErro := "7"
			Else
				fStatusTAF(@aTpAlt,cStatus0,cStatus1,/*cFuncaoPai*/, /*aContainer*/)
			EndIf
			If aTpAlt[3] .Or. lRel
				If SRA->RA_CATEFD $ cTrabVincu
					If !lMiddleware
						cStatus1 := TAFGetStat( "S-2299", cCPF)
					Else
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, fTamRJEKey(), " ")
						cStatus1 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus1 )
					EndIf
				Else
					If !lMiddleware
						cStatus1 := TAFGetStat( "S-2399", SubStr(cCPF, 1, 11)+";;")
					Else
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr( AllTrim(SRA->RA_CIC)+AllTrim(SRA->RA_CATEFD)+dToS(SRA->RA_ADMISSA), fTamRJEKey(), " ")
						cStatus1 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus1 )
					EndIf
				EndIf
				If cStatus1 != "2" .Or. lRel
					If lRel
						For nX := 1 To Len( aErroRes )
							aAdd( aErros, aErroRes[nX] )
						Next
					EndIf
					RegToMemory(cAliasMark, .F., .F., .F., "fEnvLote")
					If SRA->RA_CATEFD $ cTrabVincu
						lRet := fInt2299( oModel, @aErros, "S2299", cCdEFD, "1", Nil, oModelSRG:GetValue("RG_DATADEM"), Nil, cVersEnvio, Nil, lResComp, lRetif, Nil, .T., lRel )
					Else
						dDataDem1 := (cAliasMark)->RG_DATADEM
						lRet := fInt2399New( oModel, @aErros, "S2399", cCdEFD, "1", Nil, oModelSRG:GetValue("RG_DATADEM"), Nil, cVersEnvio, Nil, lResComp, lRetif )
					EndIf
					If lRet .And. !lRel
						If SRA->RA_CATEFD $ cTrabVincu
							aAdd( aLogfile, OemToAnsi(STR0200) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento foi gerado com sucesso para o funcion·rio: "
						Else
							aAdd( aLogfile, OemToAnsi(STR0201) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento foi gerado com sucesso para o funcion·rio: "
						EndIf
						For nX := 1 To Len( aErros )
							aAdd( aLogfile, STR0204 + "#" + cValToChar(nX) + ": " + aErros[ nX ] )//"Aviso"
							nI++
						Next
						If Len( aErroRes ) > 0
							aAdd( aLogfile, STR0204 + "#" + cValToChar(nI + 1) + ": " + aErroRes[1] )//"Aviso"
						EndIf
						aAdd( aLogfile, "" ) //Quebra de Linha
					ElseIf lRet .And. lRel
						If SRA->RA_CATEFD $ cTrabVincu
							aAdd( aLogfile, OemToAnsi(STR0330) + SRA->RA_FILIAL + " - " + SRA->RA_MAT ) //"RelatÛrio do evento S-2299 gerado para o funcion·rio "
						EndIf
					Else
						If SRA->RA_CATEFD $ cTrabVincu
							aAdd( aLogfile, OemToAnsi(STR0202) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento n„o foi gerado para o funcion·rio: "
						Else
							aAdd( aLogfile, OemToAnsi(STR0203) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento n„o foi gerado para o funcion·rio: "
						EndIf
						For nX := 1 To Len( aErros )
							aAdd( aLogfile, STR0205 + "#" + cValToChar(nX) + ": " + aErros[ nX ] )//"Erro"
							nI++
						Next
						If Len( aErroRes ) > 0
							aAdd( aLogfile, STR0205 + "#" + cValToChar(nI + 1) + ": " + aErroRes[1] )//"Aviso"
						EndIf
						aAdd( aLogfile, "" ) //Quebra de Linha
					EndIf
				Else
					If SRA->RA_CATEFD $ cTrabVincu
						aAdd( aLogfile, OemToAnsi(STR0202) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento n„o foi gerado para o funcion·rio: "
					Else
						aAdd( aLogfile, OemToAnsi(STR0203) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento n„o foi gerado para o funcion·rio: "
					EndIf
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0214)  ) //"Erro"##"Registro de Desligamento do Funcion·rio est· em tr‚nsito TAF x RET. Verifique no sistema TAF."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0215)  ) //"Erro"##"Registro de Desligamento do Funcion·rio est· em tr‚nsito ao RET. Verifique no Middleware."
					EndIf
					aAdd( aLogfile, "" ) //Quebra de Linha
				EndIf
			Else
				If SRA->RA_CATEFD $ cTrabVincu
					aAdd( aLogfile, OemToAnsi(STR0202) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento n„o foi gerado para o funcion·rio: "
				Else
					aAdd( aLogfile, OemToAnsi(STR0203) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento n„o foi gerado para o funcion·rio: "
				EndIf
				If cErro $ "2"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0216)  ) //"Erro"##"Registro de Admiss„o do Funcion·rio est· em tr‚nsito TAF x RET. Verifique no sistema TAF. A rescis„o n„o ser· efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0219)  ) //"Erro"##"Registro de Admiss„o do Funcion·rio est· em tr‚nsito ao RET. Verifique no Middleware. A rescis„o n„o ser· efetivada."
					EndIf
				ElseIf cErro $ " |1|3"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0217)  ) //"Erro"##"Registro de Admiss„o do Funcion·rio ainda n„o foi transmitido ao RET ou consta inconsistÍncias. Verifique no sistema TAF. A rescis„o n„o ser· efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0220)  ) //"Erro"##"Registro de Admiss„o do Funcion·rio ainda n„o foi transmitido ao RET ou consta inconsistÍncias. Verifique no Middleware. A rescis„o n„o ser· efetivada."
					EndIf
				ElseIf cErro $ "-1"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0218)  ) //"Erro"##"O funcion·rio ainda n„o possui integraÁ„o com o TAF. Realize a sua integraÁ„o para poder gerar a rescis„o. A rescis„o n„o ser· efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0221)  ) //"Erro"##"O funcion·rio ainda n„o possui integraÁ„o com o Middleware. Realize a sua integraÁ„o para poder gerar a rescis„o. A rescis„o n„o ser· efetivada."
					EndIf
				ElseIf cErro == "6"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0256)  ) //"Erro"##"Registro de Exclus„o da Admiss„o do Funcion·rio est· em tr‚nsito TAF x RET. Verifique no sistema TAF. A rescis„o n„o ser· efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0257)  ) //"Erro"##"Registro de Exclus„o da Admiss„o do Funcion·rio est· em tr‚nsito ao RET. Verifique no Middleware. A rescis„o n„o ser· efetivada."
					EndIf
				ElseIf cErro == "7"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0258)  ) //"Erro"##"O funcion·rio teve seu registro excluido no TAF. Necess·rio integrar o trabalhador(S-2200) antes de integrar a rescis„o. A rescis„o n„o ser· efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0259)  ) //"Erro"##"O funcion·rio teve seu registro excluido no Middleware. Necess·rio integrar o trabalhador(S-2200) antes de integrar a rescis„o. A rescis„o n„o ser· efetivada."
					EndIf
				EndIf
				aAdd( aLogfile, "" ) //Quebra de Linha
			EndIf
		Else
			aAdd( aLogfile, STR0206 + SRA->RA_FILIAL + " - " + SRA->RA_MAT )//"Foram encontrados inconsistÍncias para o funcion·rio: "
			For nX := 1 To Len( aErroRes )
				aAdd( aLogfile, STR0205 + "#" + cValToChar(nX) + ": " + aErroRes[ nX ] )//"Erro"
				aAdd( aLogfile, "" ) //Quebra de Linha
			Next
		EndIf
	Else
		If SRG->RG_DATADEM < dDtcgini
			aAdd( aLogFile, If(lRel, STR0378, STR0254) + SRA->RA_FILIAL + STR0208 + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) )//"Rescis„o n„o enviada/RelatÛrio n„o foi gerado por ser anterior ao perÌodo informado no par‚metro MV_DTCGINI -> Filial: "##" MatrÌcula: "##" Data de GeraÁ„o: "
			aAdd( aLogFile, "" )
		Else
			aAdd( aLogFile, If(lRel, STR0377, STR0207) + SRA->RA_FILIAL + STR0208 + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) )//"Rescis„o n„o foi enviada/RelatÛrio n„o foi gerado por ser complementar em perÌodo seguinte -> Filial: "##" MatrÌcula: "##" Data de GeraÁ„o: "
			aAdd( aLogFile, "" )
		EndIf
	EndIf
	oModel:DeActivate()
	fUpdAtBrw(.T.)
Next nCont

//Caso seja geraÁ„o do relatÛrio
If lRel .And. oExcel != Nil
	If !Empty(oExcel:aWorkSheet)
		oExcel:Activate() //ATIVA O EXCEL
		oExcel:GetXMLFile(cArquivo)

		If cDefPath != cPath
			CpyS2T(cDefPath+cArquivo, cPath)
		EndIf

		If ApOleClient( "MSExcel" )
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
			oExcelApp:SetVisible(.T.)
		EndIf
		oExcel:DeActivate()
		oExcel := Nil
	EndIf
EndIf

fMakeLog( {aLogFile}, aLogTitle, NIL, NIL, STR0211, STR0212, NIL, NIL, NIL, .F. ) //"Lote"##"Log de OcorrÍncias"

fClear()

cFilAnt := cBkpFil

Return()

/*/{Protheus.doc} fGeraPD()
Guarda os registros da tabela SRR no array aPd
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fGeraPD()

Private aPD			:= {}
Private aPDV		:= {}
Private aSalBase	:= {}
Private cTipoRot	:= "4"
Private nOrdGrPd	:= 0

SRR->( dbSetOrder(1) )//RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC+RR_PROCES
If SRR->( dbSeek( (cAliasMark)->RG_FILIAL+(cAliasMark)->RG_MAT+"R"+dToS((cAliasMark)->RG_DTGERAR) ) )
	While SRR->( !EoF() ) .And. SRR->RR_FILIAL+SRR->RR_MAT+SRR->RR_TIPO3+dToS(SRR->RR_DATA) == (cAliasMark)->RG_FILIAL+(cAliasMark)->RG_MAT+"R"+dToS((cAliasMark)->RG_DTGERAR)
		SRR->( fMatriz(RR_PD, RR_VALOR, Iif(SRR->RR_TIPO1 == "H", fConvHoras(SRR->RR_HORAS, "1") ,SRR->RR_HORAS), RR_SEMANA, RR_CC, RR_TIPO1, RR_TIPO2, 0, "", (cAliasMark)->RG_DATAHOM, NIL, RR_SEQ,,,,Iif(RR_TIPO2 <> "G", RR_NUMID, Nil),,, (cAliasMark)->RG_DTGERAR ) )
		SRR->( dbSkip() )
	EndDo
EndIf

Return aPd

/*/{Protheus.doc} fIntegraTAF
FunÁ„o chamada ao clicar no bot„o de integraÁ„o com o TAF dentro do visualizar
@type class
@author marcos.coutinho
@since 15/03/2018
@version 1.0
/*/
Function fIntegraTAF( lIntegra, oModelSRG, oGrid, oModel, lResComp, lRetif, aPd_SRK, lRel )
Local aErros 		:= {}
Local oModel		:= Nil
Local oModelSRG		:= Nil
Local oGrid			:= Nil

Private aPd_Aux		:= aPd_SRK
Private oExcel		:= Nil

Default lIntegra 	:= .F.
Default lResComp	:= .F.
Default lRetif		:= .F.
Default lRel		:= .F.

If lIntegra
	oModel 		:= FWLoadModel("GPEM040")
	oModelSRG	:= oModel:GetModel('GPEM040_MSRG')
	oGrid 		:= oModel:GetModel('GPEM040_MGET')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	fUpdAtBrw(.F.)
	oModel:Activate()

	//------------------------------------------------------------
	//| Caso esteja vindo do bot„o de integraÁ„o manual com o TAF
	//------------------------------------------------------------
	fIncRes(SRA->RA_FILIAL,oModelSRG:GetValue("RG_TIPORES"),@aIncRes,@nPercFgts,@cRescrais,@cAfasfgts,@Cod_Am) //Carrega "aIncRes"
	fGeraIntegracao( oModelSRG, oGrid, .T., @aErros, oModel, lResComp, lRetif, lRel)
Else
	//"AtenÁ„o" ## "Para que seja possivel realizar a integraÁ„o com o TAF, È necess·rio que os par‚metros MV_RHTAF esteja definido como verdadeiro (.T.) e MV_FASESOC esteja configurado para eventos N„o PeriÛdicos ou PeriÛdicos (1 ou 2)"
	Help( ,,OemToAnsi(STR0001),, OemToAnsi(STR0222), 1, 0 )//"AtenÁ„o"##"Para que seja possivel realizar a integraÁ„o com o TAF, È necess·rio que os par‚metros MV_RHTAF esteja definido como verdadeiro (.T.) e MV_FASESOC esteja configurado para eventos N„o PeriÛdicos ou PeriÛdicos (1 ou 2)"
EndIf

Return

/*/{Protheus.doc} fGeraIntegracao
FunÁ„o centralizadora para gerar o evento de Rescis„o S-2299
@type class
@author marcos.coutinho
@since 15/03/2018
@param lResComp, Logical, Indica se È o envio de uma rescis„o complementar calculada no mesmo mÍs da rescis„o original
@param lRetif, Logical, Indica se È o envio de uma rescis„o complementar de retificaÁ„o
@version 1.0
/*/
Function fGeraIntegracao( oModelSRG, oGrid, lRet, aErros, oModel, lResComp, lRetif, lRel)

Local cStatus0		:= ""
Local cStatus1		:= ""
Local aTpAlt		:= { .F., .F., .F., .F., .F.}
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local cFilEnv 		:= ""
Local cCPF			:= ""
Local lFVerESoc		:= FindFunction("fVersEsoc")
Local lExbAlert		:= .T.
Local aRet			:= array(2)
Local cVersEnvio	:= ""
Local cVersGPE		:= ""
Local cTrabVinc 	:= fCatTrabEFD("TCV") //Retorna todos os Trab. Com VÌnculo
Local cTrabSVinc	:= fCatTrabEFD("TSV") //Retorna todos os Trab. Sem VÌnculo
Local lTrabVinc		:= .F.
Local lTrabSVinc	:= .F.
Local cCdEFD		:= ""
Local cCatTSV		:= SuperGetMv( "MV_NTSV", .F., "701|711|712|741|" )
Local lNT15
Local cEFDAviso  	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas
Local cFasEsoc		:= SuperGetMv("MV_FASESOC", Nil, " ")
Local lTemResc		:= ".F."
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"

Default lResComp 	:= .F.
Default lRetif 		:= .F.
Default lRel		:= .F.

lTrabVinc 	:= SRA->RA_CATEFD $ cTrabVinc
lTrabSVinc	:= SRA->RA_CATEFD $ cTrabSVinc

//ValidaÁ„o TAFXERP e TAFST2
If FindFunction("fVldTaf") .And. !fVldTaf()
	lRet := .F.
	Return lRet
EndIf

If lFVerESoc
	If lTrabSVinc
		lRet := fVersEsoc( 'S2399', lExbAlert, , @aRet, @cVersEnvio, @cVersGPE, Nil, @lNT15 )
	Else
		lRet := fVersEsoc( 'S2299', lExbAlert, , @aRet, @cVersEnvio, @cVersGPE, Nil, @lNT15 )
	EndIf
	If Empty(cVersGPE)
		cVersGPE := cVersEnvio
	EndIf
Else
	lRet := .T.
EndIf

If lRet .And. !lTrabVinc .And. !lTrabSVinc
	Help(/*1*/,/*2*/,OemToAnsi(STR0001),,OemToAnsi(STR0223),1,0)//"AtenÁ„o"##"O campo RA_CATEFD n„o est· preenchido. Efetue o preenchimento antes de efetuar o c·lculo da rescis„o"
	lRet := .F.
EndIf

If lRet .And. ANOMES(oModelSRG:GetValue("RG_DTGERAR")) > oModelSRG:GetValue("RG_PERIODO") .And. oModelSRG:GetValue("RG_RESCDIS") == "0"
	//A data de geraÁ„o da rescis„o È maior que o perÌodo de c·lculo (Data de demiss„o), desta forma ser„o apresentadas inconsistÍncias na geraÁ„o dos eventos S-2299/S-2399 e S-1200 e na apuraÁ„o das bases de INSS e FGTS.
	Help(/*1*/,/*2*/,OemToAnsi(STR0001),,OemToAnsi(STR0269),1,0,Nil, Nil, Nil, Nil, Nil, {OemToAnsi(STR0270)})//
	lRet := .F.
EndIf

If lRet

	//Verifica se o registro do funcionario existe e esta integrado com TAF com sucesso
	If lTrabVinc .OR.  lTrabSVinc
		If !lMiddleware
			fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
		EndIf
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf

		If lTrabSVinc
			If !lMiddleware
				If cVersEnvio >= "9.0"
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
				Else
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
				EndIf
				cStatus0 := cStatus1 := TAFGetStat( "S-2300", cCPF, cEmpAnt, cFilEnv )
			Else
				cCPF := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
				fPosFil( cEmpAnt, cFilAnt )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
				cStatus0 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus0 )
				cStatus1	:= cStatus0
			EndIf
		Else
			cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CODUNIC )
			If !lMiddleware
				cStatus0 := cStatus1 := TAFGetStat( "S-2200", cCPF, cEmpAnt, cFilEnv )
			Else
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStatus0 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus0 )
				cStatus1	:= cStatus0
			EndIf
		EndIf
	EndIf

	If SRA->RA_CATEFD $ cCatTSV .And. cStatus1 == "-1"
		Return .T.
	EndIf
	//--------------------------------------
	//| Recupera o tipo de rescisao eSocial
	//| Realiza o De/Para do Tipo de Rescisao informada no
	//| sistema para o tipo de rescisao que o eSocial reconhece
	//-----------------------------------------------------------
	cCdEFD := fM40TPRES( oModelSRG:GetValue("RG_TIPORES"),,,oModelSRG:GetValue("RG_DATADEM") )

		//------------------------------------
		//| Validacoes diversas para Rescisao
		//| Realiza a validacao dos dados de Aviso Previo, Cert ”bito,
		//-----------------------------------------------------------
		lRet := fM40VLRES( 	AllTrim(oModelSRG:GetValue("RG_TPAVISO")),;	//Tipo Aviso
									cCdEFD,;													//Tipo Rescisao eSocial
									oModelSRG:GetValue("RG_DATADEM"),;				//Data de Demissao
									oModelSRG:GetValue("RG_OBITO"),;					//Certidao Obito
									"1",; 												  //Rescisao Simples
									Iif(lIndAv,oModelSRG:GetValue("RG_INDAV"),""),; //Indicador de cunprimento de aviso prÈvio
									@aErros,;
									.T.,;
									cVersGPE,;
									oModel:GetOperation(),;
									lNT15,;
									lRel)

		If( !lRet )
			Help(/*1*/,/*2*/,OemToAnsi(STR0001),,aErros[1],1,0)//"AtenÁ„o"
			If cEFDAviso == "1"
				Return()
			EndIf
		EndIf

	//Verifica dados complementares do eSocial
	If lTrabVinc .OR.  lTrabSVinc
		If !lFVerESoc
			If lTrabSVinc
				//Validacao se TAF esta instalado
				aRet:= TafExisEsc('S2399')
			Else
				//Validacao se TAF esta instalado
				aRet:= TafExisEsc('S2299')
			EndIf

			If aRet[2] <= '2.2'
				Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0224) + " " + OemToAnsi(STR0225)+" "+ OemToAnsi(STR0226),1,0) //##"Ambiente TAF desatualizado."##"Assim esta rotina n„o poder· ser utilizada."##"Entre em contato com o Administrador do Sistema."##"Atencao"
				lRet := .F.
				Return( lRet )
			Endif
		Endif

		//Fixa valor para .F. e aguarda verificaÁ„o real
		lRet := .F.

		IF ( cStatus0 == "0" .OR. cStatus1 == "0")
			Help(,,OemToAnsi(STR0001),,OemToAnsi(STR0126),1,0)//"O registro de admiss„o est· pendente de transmiss„o para o RET. Verifique no sistema TAF. A rescis„o n„o ser· efetivada."
		ELSEIF ( cStatus0 == "2" .OR. cStatus1 == "2")
			If !lMiddleware
				Help(,,OemToAnsi(STR0228),,OemToAnsi(STR0187),1,0)//"Registro de Admiss„o do Funcion·rio est· em tr‚nsito TAF x RET. Verifique no sistema TAF. A rescis„o n„o ser· efetivada."
			Else
				Help(,,OemToAnsi(STR0228),,OemToAnsi(STR0219),1,0)//"Registro de Admiss„o do Funcion·rio est· em tr‚nsito ao RET. Verifique no Middleware. A rescis„o n„o ser· efetivada."
			EndIf
		ELSEIF (cStatus0 == "6" .OR. cStatus1 == "6")
			Help(,,OemToAnsi(STR0228),,OemToAnsi(STR0108),1,0)//"Registro de exclus„o do Funcion·rio est· em tr‚nsito TAF x RET. Verifique no sistema TAF. A rescis„o n„o ser· efetivada."
		ElseIf ((cStatus0 == '3') .OR. (cStatus1 == '3') .OR. (cStatus0 == ' ') .OR. (cStatus1 == ' ') .OR. (cStatus0 == '1') .OR. (cStatus1 == '1') )
			If !lMiddleware
				Help(,,OemToAnsi(STR0229),,OemToAnsi(STR0217),1,0)//"Registro de Admiss„o do Funcion·rio ainda n„o foi transmitido ao RET ou consta inconsistÍncias. Verifique no sistema TAF. A rescis„o n„o ser· efetivada."
			Else
				Help(,,OemToAnsi(STR0229),,OemToAnsi(STR0227),1,0)//"Registro de Admiss„o do Funcion·rio possui inconsistÍncias. Verifique no Middleware. A rescis„o n„o ser· efetivada."
			EndIf
		ElseIf( (cStatus0 == '-1') .AND. (cStatus1 == '-1') )
			If !lMiddleware
				Help(,,OemToAnsi(STR0001),,OemToAnsi(STR0218),1,0)//"O funcion·rio ainda n„o possui integraÁ„o com o TAF. Realize a sua integraÁ„o para poder gerar a rescis„o. A rescis„o n„o ser· efetivada.
			Else
				Help(,,OemToAnsi(STR0001),,OemToAnsi(STR0221),1,0)//"O funcion·rio ainda n„o possui integraÁ„o com o Middleware. Realize a sua integraÁ„o para poder gerar a rescis„o. A rescis„o n„o ser· efetivada."
			EndIf
		Else
			//ForÁa a valida do Tipo de AlteraÁ„o
			aTpAlt := {.F., .F., .F., .F., .F.}
			fStatusTAF(@aTpAlt,cStatus0,cStatus1,/*cFuncaoPai*/, /*aContainer*/)
		EndIf

		//Verifica se pode ou n„o gerar Rescis„o
		If ( aTpAlt[3] )
			lRet := .T.
		EndIf

		//Verifica se h· rescis„o integrada com alteraÁ„o na data de demiss„o
		IF !lMiddleware .And. cCompl == "N" .And. !Empty(SRG->RG_DATADEM) .And. SRG->RG_DATADEM <> M->RG_DATADEM .And. oModel:GetOperation() == 3
			//Pesquisa no TAF se tem rescis„o calculada no perÌodo
			lTemResc := fPesCMD(cFilEnv, SRA->RA_CIC, SRA->RA_CODUNIC, SRG->RG_DATADEM)
			If lTemResc
				If cEFDAviso == "1"
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0242), 1, 0 )//OperaÁ„o de rec·lculo n„o integrada ao TAF pois houve alteraÁ„o na data de demiss„o, para este cen·rio È preciso excluir a rescis„o e realizar novo c·lculo"
					Return .F.
				Else
					MsgInfo( OemToAnsi(STR0242), OemToAnsi(STR0001))//OperaÁ„o de rec·lculo n„o integrada ao TAF pois houve alteraÁ„o na data de demiss„o, para este cen·rio È preciso excluir a rescis„o e realizar novo c·lculo
				EndIf
			EndIf
		EndIf

		If lRet .And. (!lRetif .Or. cFasEsoc == "1" .Or. (lRetif .And. cFasEsoc == "2" .And. AnoMes(oModelSRG:GetValue("RG_DATADEM")) >= MesAno( MonthSum(dDtcgini, IIF(AnoMes(dDtcgini) == "201803", 2, 3) ) ) ) )
			If !lTrabSVinc
				//Realiza por fim a geracao do evento S-2299
				lRet := fInt2299( oModel,; 	//Dados vindo da tela de rescisao (SRG e SRR)
										aErros,;							// Vari·vel de erros para alimentacao
										"S2299",;							// Evento desejado - Desligamento
										cCdEFD,;							// Categoria de Rescisao do eSocial
										"1" ,;								// Tipo de Rescisao (1 = Simples / 2 = Coletiva)
										,;									// aPd
										oModelSRG:GetValue("RG_DATADEM"),;	// Data da rescis„o
										,;									// Dias de aviso indenizado
										cVersEnvio,;						// Vers„o eSocial para envio
										,;
										lResComp,;							// Rescis„o complementar
										lRetif,;							// Rescis„o complementar por retificaÁ„o
										Nil,;
										lNT15,;
										lRel)
			Else
				//Realiza por fim a geracao do evento S-2299
				lRet := fInt2399New( oModel,; 	//Dados vindo da tela de rescisao (SRG e SRR)
										aErros,;							// Variavel de erros para alimentacao
										"S2399",;							// Evento desejado - Desligamento
										cCdEFD,;							// Categoria de Rescisao do eSocial
										"1" ,;								// Tipo de Rescisao (1 = Simples / 2 = Coletiva)
										,;									// aPd
										,;									// Data da rescis„o
										,;									// Dias de aviso indenizado
										cVersEnvio,;
										,;
										lResComp,;							// Rescis„o complementar
										lRetif)								// Rescis„o complementar por retificaÁ„o
			EndIf
			If( lRet .And. !lRel)
				fEFDMsg()
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} fResCompl
FunÁ„o respons·vel pela definiÁ„o se a rescis„o complementar ser· ou n„o enviada
@author Eduardo
@since 22/03/2018
@version 1.0
/*/
Function fResCompl(lGera, lOffline, nOperacao, lResComp, lRetif, lLote, cOpcCompl, lRel)

	Local aAreaSRG		:= SRG->( GetArea() )
	Local aCabSRG		:= {}
	Local lRet      	:= .F.
	Local lPLR			:= .F.
	Local lGer2299		:= .F.
	Local lPLRoutrPD	:= .F. // na rescis„o complementar a verba de PLR est· sendo paga junto com outras verbas
	Local lTemComp		:= .F.
	Local dDtCarga  	:= SuperGetMv("MV_DTCGINI",, StoD("//"))
	Local dDemiss   	:= IIF(lLote .Or. Empty(dDataDem1),SRG->RG_DATADEM,dDataDem1)
	Local dDtGer		:= Iif(lOffline .Or. nOperacao == 5, SRG->RG_DTGERAR, M->RG_DTGERAR )
	Local nCont			:= 0

	Default lGera		:= .T.
	Default lOffline	:= .F.
	Default nOperacao	:= 3
	Default lResComp	:= .F.
	Default lRetif		:= .F.
	Default lLote		:= .F.
	Default cOpcCompl	:= ""
	Default lRel		:= .F.

	If cPaisLoc == "BRA" .And. (lOffline .Or. nOperacao == 5)
		cCompl 	  	:= Iif(SRG->RG_RESCDIS $ " /0", "N", "S")
		lProxMes  	:= AnoMes(SRG->RG_DATADEM) != AnoMes(SRG->RG_DTGERAR)
		lRescDis  	:= (SRG->RG_RESCDIS == "2")
		lRetif    	:= (SRG->RG_RESCDIS == "3")
		aPdResc		:= {}
		aSrgRecnos	:= {}
		If SRG->( dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
			While SRG->( !Eof() .And. SRG->RG_FILIAL+SRG->RG_MAT == SRA->RA_FILIAL+SRA->RA_MAT )
				nRegSrg := SRG->( Recno() )
				nPos	:= aScan( aSrgRecnos, { |x| MesAno( x[2] ) == MesAno( SRG->RG_DTGERAR ) } )
				If MesAno( SRG->RG_DTGERAR ) == MesAno( SRG->RG_DATADEM ) .and. nPos > 0.00
					aSrgRecnos[ nPos , 01 ] := nRegSrg
					aSrgRecnos[ nPos , 02 ] := SRG->RG_DTGERAR
					aSrgRecnos[ nPos , 03 ] := SRG->RG_DATADEM
				Else
					aAdd( aSrgRecnos, { nRegSrg, SRG->RG_DTGERAR, SRG->RG_DATADEM } )
				EndIf
				SRG->( dbSkip() )
			EndDo
		EndIf
	EndIf

	If cCompl == "S"
		lResComp := .T.
		If !lOffline .And. nOperacao != 5
			lRetif	 := (cOpcCompl == "3")
		EndIf
	EndIf

	If dDemiss >= dDtCarga
		//Se n„o for retificaÁ„o, o mÍs diferente, n„o for Res. complementar e for integraÁ„o offline
		IF !lRetif .AND. lOffline .AND. lProxMes .AND. cCompl == "N"
			lRet := .T.
		ElseIf !lRetif .And. (lProxMes .Or. cCompl == "S")
			For nCont := 2 To Len(aSrgRecnos)
				If AnoMes(aSrgRecnos[nCont, 2]) > AnoMes(aSrgRecnos[nCont, 3]) .And. aSrgRecnos[nCont, 2] != dDtGer
					SRG->( dbGoTo(aSrgRecnos[nCont, 1]) )
					aAdd( aCabSRG, { SRG->RG_DTGERAR, SRG->RG_RESCDIS } )
					lTemComp	:= .T.
				EndIf
			Next nCont
			If !lTemComp
				//Verifica se È complementar com pagamento de PLR, e se existem outras verbas sendo pagas.
				If !lRescDis
					lPLRoutrPD := fBuscaPLR(@lPLR)
				EndIf

				//Se for complementar para pagamento de PLR n„o gera o evento S-2299/S-2399.
				If lPLR
					lRet := .F.
					//Se for complementar com pagamento de PLR e outras verbas, pergunta se ir· gerar o evento S-2299/S-2399.
					If lPLRoutrPd
						If !IsBlind() .And. !lLote .And. !lRel
							lGera := MsgYesNo( OemToAnsi( STR0230 ) + CRLF + OemToAnsi( STR0231 ) , OemToAnsi( STR0232) ) //IntegraÁ„o com o TAF. Ser· gerado um evento S-2299 retificador com todas as verbas incluÌdas, porÈm, alertamos que, de acordo com as regras do eSocial, seria necess·rio gerar uma rescis„o complementar para o PLR e outra Rescis„o complementar para as demais verbas, confirma a geraÁ„o?
							lRet := lGera
						Else
							lRet := .T.
						Endif
					Endif
				//Se n„o for complementar com PLR e for em perÌodo seguinte n„o gera o evento S-2299/S-2399.
				ElseIf lProxMes
					lRet := .F.

				// Se for rescis„o complementar no mesmo perÌodo da rescis„o original deve gerar o evento S-2299/S-2399
				Else
					lRet := lGera := .T.
				Endif
			Else
				lGer2299 := (aCabSRG[Len(aCabSRG), 2] == "3") .And. lOffline //Retificar gera S-2299
				If !lGer2299
					lRet := .F.
				Else
					lRet := lGera := .T.
				EndIf
			EndIf
		Else
			//Se n„o for complementar ou for complementar de retificaÁ„o, gera o evento S-2299/S-2399
			lRet := .T.
		EndIf
	EndIf

	RestArea( aAreaSRG )

Return lRet

/*/{Protheus.doc} fBuscaPLR
Verifica se a verba de PLR foi lanÁada na rescis„o complementar
e se existe outra verba alÈm dela na Rescis„o.
@author claudinei.soares
@since 14/05/2018
/*/
Static Function fBuscaPLR(lPLR)
Local oModel	:= FWModelActive()
Local oGrid		:= oModel:GetModel("GPEM040_MGET")
Local nG		:= 0
Local lPLRePD	:= .F.
Local lRet		:= .F.
Local lRvCpoPlr		:= SRV->(Columnpos("RV_REFPLR") > 0)
Local nValor	:= 0

Default lPLR	:= .F.

For nG := 1 To oGrid:Length()
	oGrid:GoLine(nG)
	cVerba := oGrid:GetValue("RR_PD")
	cNumId := oGrid:GetValue("RR_NUMID")
	nValor := oGrid:GetValue("RR_VALOR")
	//Verifica se possui a verba de PLR lanÁada na Rescis„o
	If (cVerba $ ( aCodFol[151,1] + "/" + aCodFol[152,1] + "/" + aCodFol[835,1] + "/" + aCodFol[836,1] + "/" + aCodFol[300,1] + "/" + aCodFol[1328,1] ) .Or. RetValSrv( cVerba, SRA->RA_FILIAL, 'RV_INCIRF', 1 ) == "54") .And. nValor > 0
		lPLR := .T.
	ElseIf !Empty(cVerba) .And. !(cVerba $ aCodFol[318,1] + "/" + aCodFol[126,1] + "/" + aCodFol[303,1] + "/" + aCodFol[120,1] + "/" + aCodFol[297,1]) .And. Empty(cNumId) .and. (!lRvCpoPlr .Or. (lRvCpoPlr .And. !(RetValSRV(cVerba, SRA->RA_FILIAL, 'RV_REFPLR') == "S"))) .And. nValor > 0
		lPLRePD := .T.
	EndIf
Next nG

//Possui a verba de PLR e alguma outra no mesmo c·lculo
lRet := lPLR .And. lPLRePD

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥fValEfdM040∫Autor  ≥ Emerson Campos    ∫ Data ≥  20/09/2013 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao para validar todos os campos do eSocial			  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ cObs Campo observaÁ„o da aba eSocial			  			  ∫±±
±±∫          ≥ cAtOb Campo Atestado de obito da aba eSocial			      ∫±±
±±∫          ≥ cTpRes Campo Tipo de rescisao da aba eSocial			      ∫±±
±±∫          ≥ cNrProc Campo nro do processo trabalhista da aba eSocial	  ∫±±
±±∫          ≥ cCnpj Campo CNPJ da sucessora da aba eSocial			  	  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPEM040 			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fValEfdM040(cObs, cAtOb, cTpRes, cNrProc, cNroCnpj, cTpSuc, cMsg)
Local lRet		:= .T.

Default cMsg	:= ""

	/*
	 * Descricao:
	 * 	Numero que identifica o registro do atestado de obito.
	 * 	Campo preenchido no caso de desligamento por morte.
	 * Validacao:
	 * 	Deve ser preenchido se o motivo de desligamento for igual a [09|10]
	 * 	Motivo de dsligamento e o item X32_MOTDES da tabela X32 que e
	 *  selecionado atravÍs do campo de tela cTipRes
	 */
	If lRet
		lRet := fObtVldM040(AllTrim(cAtOb), cTpRes)
	EndIf

	/*
	 * Descricao:
	 *  Preencher com o CNPJ/CPF da empresa sucessora.
	 * Validacao:
	 *  Deve ser um CNPJ/CPF valido, com raiz diferente do CNPJ do declarante.
	 */
	If lRet
		lRet := fVldInsM040(AllTrim(cNroCnpj), cTpRes, cTpSuc, @cMsg)
	EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥fObtVldM040∫Autor ≥ Emerson Campos     ∫ Data ≥  20/09/2013 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao para validar o ca				  					  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPEM040 			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fObtVldM040(cAtObito, cTipR)

Local lRet		:= .T.
Local nPos		:= 0
Local cMotEF	:= ""
Local cEFDAviso := If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

	If cEFDAviso <> "2"
		nPos := fPosTab("S043", cTipR , "=", 4 )
		If nPos > 0
			 cMotEF := FTabela("S043", nPos, 33)
		EndIf
		If !Empty(AllTrim(cAtObito)) .And. !(AllTrim(cMotEF) $ ("A"))
			// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
			// "Atencao" ### "O campo 'Atestado de obito' so devera ser preenchido se o motivo de desligamento for igual a 10. Selecione um tipo de rescisao que o motivo seja diferente de desligamento devido a morte."
			If cEFDAviso == "1"
				Help( , ,OemToAnsi(STR0001), , OemToAnsi(STR0233), 1, 0 )//"O campo 'Atestado de ”bito' sÛ dever· ser preenchido se o motivo de desligamento for igual a A. Selecione um tipo de rescis„o que o motivo seja diferente de desligamento devido a morte."
				lRet	:= .F.
			ElseIf cEFDAviso == "0"
				Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0233)+ CRLF + OemToAnsi(STR0234),,1,0 )//"O campo 'Atestado de ”bito' sÛ dever· ser preenchido se o motivo de desligamento for igual a A. Selecione um tipo de rescis„o que o motivo seja diferente de desligamento devido a morte."##
			EndIf
		EndIf

	EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥fVldInsM040 ∫Autor ≥ Emerson Campos    ∫ Data ≥  26/09/2013 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao para limitar em 255 caractreres no campo memo		  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPEM040 			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fVldInsM040(cCnpj, cTipR, cTpSuc, cMsg)
Local 	aArea		:= GetArea()
Local 	aAreaSM0	:= SM0->( GetArea() )
Local 	cMotEF		:= ""
Local 	lRet		:= .T.
Local	nPos		:= 0
Local 	lTpSuces	:= SRG->(ColumnPos("RG_TPSU")) > 0
Local	cVersEnvio	:= ""
Local   cEFDAviso 	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

Default cMsg 	:= ""

	fVersEsoc("S2299", .F.,,,@cVersEnvio)
	If !lMiddleware .And. Right(cVersEnvio,1) == "."
		cMsg :=  OemToAnsi(STR0253) //"Revise o preenchimento do par‚metro MV_TAFVLES certificando que ele esteja conforme o padr„o. Ex: 02_05_00."
		lRet := .F.
	EndIf

	nPos := fPosTab("S043", cTipR , "=", 4 )
	If nPos > 0
		 cMotEF := FTabela("S043", nPos, 33)
	EndIf

	//Valida se foi preenchido o novo campo RG_TPSU
	If cVersEnvio >= '2.5.00' .And. lTpSuces
		//Valida se o tipo de desligamento for B ou C e n„o preencheu o tipo de inscriÁ„o
		If (cMotEF $ ("B|C|T")) .And. Empty(cTpSuc)
			If cEFDAviso == "1"
				cMsg :=  OemToAnsi(STR0235) //"O campo 'Tp.InscriÁ„o' È de preenchimento obrigatÛrio se o motivo de desligamento for igual a B, C ou T."
				lRet := .F.
			Endif
		Endif

		//Valida se o tipo de desligamento N√O for B ou C e preencheu o tipo de inscriÁ„o
		If !Empty(cCnpj) .And. !(cMotEF $ ("B|C|T"))
			If cEFDAviso == "1"
				cMsg :=  OemToAnsi(STR0236) //"O campo 'Tp.InscriÁ„o' sÛ dever· ser preenchido se o tipo de rescis„o for relacionado a TransferÍncia de empregado para outra empresa do mesmo grupo ou por sucess„o ou por redistribuiÁ„o, opÁıes B, C ou T de motivos de desligamentos."
				lRet := .F.
			Endif
		Endif
	Endif

	// Obtem o CGC da Empresa de Origem
	If lRet .And. !Empty(cCnpj) .And. (cMotEF $ ("B|C|T"))
		//Caso se o campo Motido de Afastamento - S056 for igual a 11, 12 ou 29 nao pode ser vazio, tem que ser um n˙mero de inscriÁ„o v·lido.
		If ( lRet := SM0->( dbSeek( cEmpAnt + SRA->RA_FILIAL ) ) )
			If cEFDAviso <> "2"
				If SM0->M0_CGC == cCnpj
					//"O n˙mero de inscriÁ„o informado deve ser diferente do n˙mero de inscriÁ„o da filial de cadastro do participante."
					// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
					If cEFDAviso == "1"
						Help( , , 'HELP', , OemToAnsi(STR0237), 1, 0 ) //"O n˙mero de inscriÁ„o informado deve ser diferente do n˙mero de inscriÁ„o da filial de cadastro do participante."
						cMsg :=  OemToAnsi(STR0237)//"O n˙mero de inscriÁ„o informado deve ser diferente do n˙mero de inscriÁ„o da filial de cadastro do participante."
						lRet	:= .F.
					ElseIf cEFDAviso == "0"
						Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0237)+ CRLF + OemToAnsi(STR0234),,1,0 )//"O n˙mero de inscriÁ„o informado deve ser diferente do n˙mero de inscriÁ„o da filial de cadastro do participante."##"Entretanto n„o ser· impeditivo para gravaÁ„o conforme configuraÁ„o do par‚metro MV_EFDAVIS."
					EndIf
				EndIf
				If lRet .And. cCnpj == "00000000000000"
					 //"O n˙mero de InscriÁ„o informado n„o È v·lido!"
					// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
					If cEFDAviso == "1"
						Help( , , 'HELP', , OemToAnsi(STR0238), 1, 0 )//"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "
						If Empty(cMsg)
							cMsg :=  OemToAnsi(STR0238)//"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "
						Else
							cMsg += CRLF + OemToAnsi(STR0238)//"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "
						Endif
						lRet	:= .F.
					ElseIf cEFDAviso == "0"
						Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0238)+ CRLF + OemToAnsi(STR0234),,1,0 )//"N„o ser· possÌvel efetuar a integraÁ„o. O identificador de tabela de rubrica do cÛdigo: "##"Entretanto n„o ser· impeditivo para gravaÁ„o conforme configuraÁ„o do par‚metro MV_EFDAVIS."
					EndIf
				EndIf
				If lRet
					// Valida se o n˙mero de inscriÁ„o È v·lido
					lRet :=  If( (cTpSuc == "2" .And. cVersEnvio >= '2.5.00' ), ChkCPF( Alltrim(cCnpj) ) , CGC( Alltrim(cCnpj) ) )
					If cEFDAviso == "0" .And. !lRet
						lRet	:= .T.
					ElseIf cEFDAviso == "1" .And. !lRet
						cMsg += CRLF + OemToAnsi(STR0239) //"O n˙mero de inscriÁ„o da empresa sucessora informado È inv·lido"
					EndIf
				EndIf
			EndIf
		EndIF
	EndIf

	If lRet .And. cEFDAviso <> "2"
		If  !Empty(cCnpj) .And. !(cMotEF $ ("B|C|T"))
			//"O campo 'Insc.Emp.Suc' sÛ dever· ser preenchido se o tipo de rescis„o for relacionado a TransferÍncia de empregado para outra empresa do mesmo grupo ou por sucess„o. OpÁıes 11 ou 12 de motivos de desligamentos."
			// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
			If cEFDAviso == "1"
				Help( , , 'HELP', , OemToAnsi(STR0240), 1, 0 )//"O campo 'Insc.Emp.Suc' sÛ dever· ser preenchido se o tipo de rescis„o for relacionado a TransferÍncia de empregado para outra empresa do mesmo grupo ou por sucess„o ou por RedistribuiÁ„o. OpÁıes 11, 12 ou 29 de motivos de desligamentos."
				lRet	:= .F.
				If Empty(cMsg)
					cMsg :=  OemToAnsi(STR0240)//"O campo 'Insc.Emp.Suc' sÛ dever· ser preenchido se o tipo de rescis„o for relacionado a TransferÍncia de empregado para outra empresa do mesmo grupo ou por sucess„o ou por RedistribuiÁ„o. OpÁıes 11, 12 ou 29 de motivos de desligamentos."
				Else
					cMsg += CRLF + OemToAnsi(STR0240)//"O campo 'Insc.Emp.Suc' sÛ dever· ser preenchido se o tipo de rescis„o for relacionado a TransferÍncia de empregado para outra empresa do mesmo grupo ou por sucess„o ou por RedistribuiÁ„o. OpÁıes 11, 12 ou 29 de motivos de desligamentos."
				Endif
			ElseIf cEFDAviso == "0"
				Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0240)+ CRLF + OemToAnsi(STR0234),,1,0 )
				//"O campo 'Insc.Emp.Suc' sÛ dever· ser preenchido se o tipo de rescis„o for relacionado a TransferÍncia de empregado para outra empresa do mesmo grupo ou por sucess„o ou por RedistribuiÁ„o. OpÁıes 11, 12 ou 29 de motivos de desligamentos."//"Entretanto n„o ser· impeditivo para gravaÁ„o conforme configuraÁ„o do par‚metro MV_EFDAVIS."
			EndIf
		EndIf

		If  lRet .And. Empty(cCnpj) .And. (cMotEF $ ("B|C|T"))
			//"O campo 'Insc.Emp.Suc' È um campo obrigatÛrio se o motivo de desligamento for igual a B ou C. Informe uma n˙mero de InscriÁ„o v·lido e diferente do n˙mero de inscriÁ„o do declarante."
			// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
			If cEFDAviso == "1"
				Help( , , 'HELP', , OemToAnsi(STR0241), 1, 0 )//"O campo 'Insc.Emp.Suc' È um campo obrigatÛrio se o motivo de desligamento for igual a B, C ou T. Informe uma n˙mero de InscriÁ„o v·lido e diferente do n˙mero de inscriÁ„o do declarante."
				lRet	:= .F.
				If Empty(cMsg)
					cMsg :=  OemToAnsi(STR0241)//"O campo 'Insc.Emp.Suc' È um campo obrigatÛrio se o motivo de desligamento for igual a B, C ou T. Informe uma n˙mero de InscriÁ„o v·lido e diferente do n˙mero de inscriÁ„o do declarante."
				Else
					cMsg += CRLF + OemToAnsi(STR0241)//"O campo 'Insc.Emp.Suc' È um campo obrigatÛrio se o motivo de desligamento for igual a B, C ou T. Informe uma n˙mero de InscriÁ„o v·lido e diferente do n˙mero de inscriÁ„o do declarante."
				Endif
			ElseIf cEFDAviso == "0"
				Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0241)+ CRLF + OemToAnsi(STR0234),,1,0 )//"O campo 'Insc.Emp.Suc' È um campo obrigatÛrio se o motivo de desligamento for igual a B, C ou T. Informe uma n˙mero de InscriÁ„o v·lido e diferente do n˙mero de inscriÁ„o do declarante."##"Entretanto n„o ser· impeditivo para gravaÁ„o conforme configuraÁ„o do par‚metro MV_EFDAVIS."
			EndIf
		EndIf
	EndIf

	// Restaura os Dados de Entrada
	RestArea( aAreaSM0 )
	RestArea( aArea )

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fM40TPRES   ∫Autor  ≥Rh ManutenÁ„o      ∫ Data ≥  31/05/17  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Baseado no tipo de rescisao informado, realiza um de/para na∫±±
±±∫          ≥ tabela do eSocial e retorna a opcao selecionada            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Rescisao Simples e Rescisao Coletiva                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fM40TPRES( cCodTpRes, cTpAvs, laIncRes, dDtDemissa)
Local cTab56	:= "S056"
Local cTpEFD	:= ""
Local cCdEFD	:= ""
Local aAreaRCC	:= GetArea()
Local dDtValid	:= CTOD("//")
Local nPos		:= 0
Local nPos1 	:= 0
Local cDtValid  := ""
Local lRet 		:= .F.

Default cTpAvs 		:= ""
Default laIncRes	:= .F.
Default dDtDemissa  := CTOD("//")

If Empty(dDtDemissa) .And. type("dDataRes") == "D" .And. !Empty(dDataRes)
   dDtDemissa := dDataRes
Endif

If Type("aIncRes") <> "A"
	aIncRes := {}
EndIf

If Empty(aIncRes) .Or. laIncRes
	fIncRes(SRA->RA_FILIAL, cCodTpRes, @aIncRes)
EndIf
If Len(aIncRes) > 1
	cTpEFD	:= aIncRes[22]
	cTpAvs	:= aIncRes[02]
EndIf

//Valida se a data de validade ja foi criada
dbSelectArea( "RCC" )
dbSetOrder(1)
dbSeek(xFilial("RCC",SRA->RA_FILIAL) + cTab56)
While !Eof() .and. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC",SRA->RA_FILIAL)+cTab56
	If RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC",SRA->RA_FILIAL)+cTab56
		cDtValid := Substr(RCC->RCC_CONTEU,203,8)
		If !Empty(cDtValid)
			lRet := .T.
		Endif
	EndIf
	RCC->(dBSkip())
EndDo

If !Empty(dDtDemissa) .And. lRet
	//Verifica se a data de demissao È menor/igual a data de validade
	nPos:= FPOSTAB("S056",cTpEFD,"=", 4 , dDtDemissa, "<= ", 6  )
	If nPos > 0
		cCdEFD := FTABELA("S056",nPos,5)
		cCdEFD := Alltrim(Substr(cCdEFD,1,2))
	Else
		//Busca o motivo de desligamento  sem data de validade
		nPos1:= FPOSTAB("S056",cTpEFD,"=", 4 , dDtValid, "= ", 6  )
		If nPos1 > 0
			cCdEFD := FTABELA("S056",nPos1,5)
			cCdEFD := Alltrim(Substr(cCdEFD,1,2))
		Endif
	Endif
Else
	nPos1:= FPOSTAB("S056",cTpEFD,"=", 4 )
	If nPos1 > 0
		cCdEFD := FTABELA("S056",nPos1,5)
		cCdEFD := Alltrim(Substr(cCdEFD,1,2))
	Endif
Endif

RestArea(aAreaRCC)
Return cCdEFD

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fM40VLRES   ∫Autor  ≥Rh ManutenÁ„o      ∫ Data ≥  31/05/17  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Realiza a validacoes dos dados enviados para rescisao do    ∫±±
±±∫          ≥ funcionario corrente                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Realiza a validacao dos registros setados em memoria       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Param     ≥ cTpAviso   : Tipo de Aviso do funcion·rio                  ∫±±
±±∫          ≥ cCdEFD     : Tipo Rescisao do eSocial                      ∫±±
±±∫          ≥ dDtDemissa : Data de demissao do desligamento              ∫±±
±±∫          ≥ cCodObito  : Numero de certidao de obito do funcionario    ∫±±
±±∫          ≥ cTpRes     : 1 = Rescisao Simples / 2 = Rescisao Coletiva  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fM40VLRES( cTpAviso, cCdEFD, dDtDemissa, cCodObito, cTpRes, cIndAv, aErroRes, lAviso, cVersEnvio, nOper, lNT15, lRel)
Local lRet			:= .T.
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
Local lNewMotDes	:= If(dDtDemissa >= Ctod("19/07/2021"),.T.,.F.)

Default cTpRes		:= "1"
Default aErroRes	:= {}
Default lAviso		:= .T.
Default cVersEnvio	:= "2.2"
Default nOper		:= 3
Default lNT15		:= .F.
Default lRel		:= .F.

If cPaisLoc == "BRA" .And. nOper != 5
	//Se o tipo de aviso for trabalhado ou termino de contrato
	If ( ( AllTrim( cTpAviso ) $ "T*B" .AND. ( cCdEFD $ '03*04*06' ) ) .AND. ( dDtDemissa + 1 < dDataBase ) .And. SRA->RA_CATEFD $ cTrabVincu ) .And. !lRel
		If lAviso
			Aviso(OemToAnsi(STR0001), OemToAnsi(STR0041)) //##"Atencao."##"O prazo de envio deste evento foi ultrapassado. PassÌvel de multa"
		Else
			aAdd(aErroRes,  OemToAnsi(STR0041) )
		EndIf
	ElseIf ( dDtDemissa + 10 < dDataBase ) .And. (SRA->RA_CATEFD $ cTrabVincu .Or. cVersEnvio >= "9.0") .And. !lRel
		If lAviso
			Aviso(OemToAnsi(STR0001), OemToAnsi(STR0041)) //##"Atencao."##"O prazo de envio deste evento foi ultrapassado. PassÌvel de multa"
		Else
			aAdd(aErroRes,  OemToAnsi(STR0041) )
		EndIf
	EndIf

	If Empty(cCdEFD) .AND. (SRA->RA_CATEFD $ cTrabVincu .Or. SRA->RA_CATEFD == "721")
		aAdd(aErroRes,  OemToAnsi(STR0248) )	//##"Atencao."##"Verifique o preenchimento ou a data de vigencia do Motivo de desligamento do eSocial. InformaÁ„o obrigatÛria "
		lRet := .F.
	Endif

	If !lNewMotDes
		//ValidaÁ„o para o tipo de Rescis„o e Categoria eSocial do Funcion·rio
		If ( ( cCdEFD $ "18*19*20*21*22*23*24*25" ) .AND. ( SRA->RA_CATEFD < "301" .OR. SRA->RA_CATEFD > "309" ) )
			lRet := .F.
			aAdd(aErroRes,  OemToAnsi(STR0249) )	//"Motivos de desligamento v·lidos apenas para Agentes P˙blicos."
		EndIf
	Else
		If cCdEFD $ "21*22*32" .And.  SRA->RA_CATEFD <> "307"
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD $ "23*24" .And.  !(SRA->RA_CATEFD  $ "301*302*303*306*307*309*310*312")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "25" .And.  !(SRA->RA_CATEFD  $ "301*307")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "29" .And. !(SRA->RA_CATEFD  $ "301*303*306*307*309")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "37" .And. !(SRA->RA_CATEFD  $ "301*306*307*309")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "38" .And. !(SRA->RA_CATEFD  $ "101*301*302*312")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "39" .And. !(SRA->RA_CATEFD  $ "301*306*309")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "40" .And. SRA->RA_CATEFD  <> "303"
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD $ "41*42" .And. SRA->RA_CATEFD  <> "103"
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento n„o È valido para essa categoria do eSocial"
			lRet := .F.
		Endif
	Endif

	//Se o tipo de aviso for trabalhado ou termino de contrato
	If lIndAv
		If !lNT15 .And. ( ( ( cCdEFD $ "02*03*04*07" ) .And. Empty(cIndAv) .And. SRA->RA_CATEFD $ cTrabVincu  ) .Or. ( Empty(cIndAv) .And. cVersEnvio > "2.3" .And. SRA->RA_CATEFD $ cTrabVincu ) )
			lRet := .F.
			aAdd(aErroRes,  If(cVersEnvio > "2.3", OemToAnsi(STR0252) ,OemToAnsi(STR0196)) )	//"Quando o tipo de rescis„o for 02, 03, 04 ou 07, È obrigatÛrio o preenchimento do campo 'Ind.Cum.Av.P'."
		EndIf
	EndIf
EndIf

//Deixa o retorno com .T. se for geraÁ„o do relatÛrio
If lRel
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} fPesCMD
FunÁ„o respons·vel por pesquisar se h· um registro na tabela CMD em determinada data.
@author lidio.oliveira
@since 29/05/2020
@version 1.0
/*/
Static Function fPesCMD(cFilEnv, cCPF, cCodUnic, dDtDem)

Local aArea 	:= GetArea()
Local lRet		:= .F.
Local cIdFunc	:= ""

Default cStatus 	:= "-1"
Default cCPF		:= ""
Default cCodUnic	:= ""
Default dDtDem 		:= CTOD("//")

	//A pesquisa ser· realizada apenas se os par‚metros foram informados
	If !Empty(dDtDem) .And. !Empty(cCPF) .And. !Empty(cCodUnic) .And. !Empty(dDtDem)

		//Encontra o Id do funcion·rio na tabela C9V
		DBSelectArea("C9V")
		C9V->(DBSetOrder(10)) //C9V_FILIAL + C9V_CPF + C9V_MATRIC + C9V_NOMEVE + C9V_ATIVO
		If C9V->(DBSEEK(cFilEnv + cCPF + cCodUnic + "S2200"))
			cIdFunc := C9V->C9V_ID
		EndIf

		//Pesquisa na CMD se h· registro de demiss„o na data solicitada
		If !Empty(cIdFunc)
			dDtDem := DTOS(dDtDem)
			DBSelectArea("CMD")
			CMD->(DBSetOrder(2)) //CMD_FILIAL + CMD_FUNC + DTOS(CMD_DTDESL) + CMD_ATIVO
			If CMD->(DBSEEK(cFilEnv + cIdFunc + dDtDem))
				lRet := .T.
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fBuscaDiss
Verifica se existem verbas de dissidio
@author staguti
@since 03/12/2020
/*/
Static Function fBuscaDiss(aVbDiss, cTpRes, aPd)
Local aArea		:= GetArea()
Local oModelDis	AS Object
Local oGridDis	:= Nil
Local nG		:= 0
Local lDissPD	:= .F.
Local lRet		:= .T.
Local cFilDis	:= ""
Local cMatDis	:= ""
Local cVerba	:= ""
Local cNumId	:= ""
Local aVbDiss	:= {}

Default cTpRes	:= ""
Default aPd		:= {}

If cTpRes == "1"
 	oModelDis	:= FWModelActive()
 	oGridDis	:= oModelDis:GetModel("GPEM040_MGET")

	For nG := 1 To oGridDis:Length()
		oGridDis:GoLine(nG)
		cFilDis := oGridDis:GetValue("RR_FILIAL")
		cMatDis := oGridDis:GetValue("RR_MAT")
		cVerba 	:= oGridDis:GetValue("RR_PD")
		cNumId 	:= oGridDis:GetValue("RR_NUMID")

 		If oGridDis:GetValue("RR_TIPO3") == "R" .And. (Empty(cNumId) .Or. (" - " $ cNumId))
			//Caso o N˙mero de Id esteja em branco e a verba tenha origem G pesquisa na tabela SRK para validar se trata-se de dissÌdio.
			If oGridDis:GetValue("RR_TIPO2") == "G"
				cNumId := fNumId(cFilDis + cMatDis + cVerba)
				If !Empty(cNumId)
					aAdd( aVbDiss, { cVerba, cNumId } )
				Else
					lGeraVbDis	:= .T.
				EndIf
			Else
				lGeraVbDis	:= .T.
			EndIf
		EndIf
		If !Empty(oGridDis:GetValue("RR_NUMID")) .And. !(" - " $ cNumId) .And. !("RG1" $ cNumId) .And. !("SR8" $ cNumId)
			aAdd( aVbDiss, { cVerba, oGridDis:GetValue("RR_NUMID") } )
		EndIf
	Next nG
Else

	For nG := 1 To Len(aPd)
		cFilDis := xFilial("SRR")
		cMatDis := SRR->RR_MAT
		cVerba := aPd[nG, 1]
		cNumId := aPd[nG, 15]

		If Empty(cNumId)
			//Caso o N˙mero de Id esteja em branco e a verba tenha origem G pesquisa na tabela SRK para validar se trata-se de dissÌdio.
			If aPd[nG, 7] == "G"
				cNumId := fNumId(cFilDis + cMatDis + cVerba)
				If !Empty(cNumId)
					aAdd( aVbDiss, { cVerba, cNumId } )
				Else
					lGeraVbDis	:= .T.
				EndIf
			Else
				lGeraVbDis	:= .T.
			EndIf
		EndIf
		If !Empty(cNumId) .And. !(" - " $ cNumId) .And. !("RG1" $ cNumId) .And. !("SR8" $ cNumId)
			aAdd( aVbDiss, { cVerba, cNumId} )
		EndIf
	Next nG

Endif

RestArea(aArea)

Return lRet


/*/{Protheus.doc} fNumId()
FunÁ„o que busca NumID na SRK
@type function
@author staguti
@since 04/12/2020
@version 1.0
@param cChave		= Filial + MatrÌcula + Verba
@param cDataMin		= Data de mÌnima de pesquisa
@return cNumId		= Retorna NumID
/*/
Static Function fNumId( cChave)

Local cNumId	:= ""
Local aArea		:= GetArea()

DEFAULT cChave		:= ""

dbSelectArea( "SRK" )
SRK->(dbSetOrder(1))
If SRK->( Dbseek( cChave ) )
	While SRK->(!EoF()) .And. SRK->(RK_FILIAL+RK_MAT+RK_PD) == cChave
		If !Empty(SRK->RK_NUMID) .And. !Empty(SRK->RK_MESDISS) .And. SRK->RK_STATUS <> "3"
			cNumId := SRK->RK_NUMID
		EndIf
		SRK->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return cNumId


/*/{Protheus.doc} fDiasConv()
FunÁ„o que retorna os dias de convocaÁ„o no mes da rescisao
@type function
@author staguti
@since 26/04/2021
@version 1.0
@param dDataDe		= Data Inicial do Periodo
@param dDataMin		= Data Final do Periodo/Data Rescis„o
@return aDiasConv	= Retorna array com todos os dias de convocaÁ„o
/*/

Function fDiasConv(dDataDe, dDataAte)

Local aConvoc 		:= {}
Local nDiaConv 		:= 0
Local aDiasConv 	:= {}
Local nC			:= 0
Local nInt 			:= 0
Default dDataDe 	:= Ctod("")
Default dDataAte 	:= Ctod("")

	aConvoc := BuscaConv(dDataDe, dDataAte)

	If Len(aConvoc) > 0
		For nC := 1 to Len(aConvoc)
			nDiaConv := Day(aConvoc[nC,2])
			aAdd( aDiasConv, StrZero(nDiaConv,2) )
			If aConvoc[nC,5] > 0
				For nInt:= 1 to aConvoc[nC,5]
					If nDiaConv+1 <= Day(aConvoc[nC,3])
						nDiaConv := nDiaConv+1
						aAdd( aDiasConv, StrZero(nDiaConv,2) )
					Endif
				Next nInt
			Endif
		Next nC
	Endif

Return aDiasConv

/*/{Protheus.doc} fGetDtHomol
FunÁ„o respons·vel por retornar a data de pagamento da rescis„o original
@author lidio.oliveira
@since 15/01/2021
@version 1.0
/*/
Static Function fGetDtHomol(cFilSRG, cMatSRG, dDtHomol)

Local aAreaSRG	:= SRG->(GetArea())

Default cFilSRG := ""
Default cMatSRG	:= ""
Default dDtHomol:= CTOD("//")

	//A pesquisa ser· realizada apenas se os par‚metros foram informados
	If !Empty(cFilSRG) .And. !Empty(cMatSRG)

		//Retorna data da rescis„o original
		DBSelectArea("SRG")
		SRG->(DBSetOrder(1))
		If SRG->(DBSEEK(cFilSRG + cMatSRG))
			dDtHomol := SRG->RG_DATAHOM
		EndIf

	EndIf

	RestArea(aAreaSRG)

Return


/*/{Protheus.doc} fGeraRelat
FunÁ„o que gera o relatÛrio em Excel
@author lidio.oliveira
@since 24/02/2023
@version 1.0
/*/
Static Function fGeraRelat(cXML, cDtEfei, cCompAc, cDescMtv, dDtGerDem, aRelIncons)

	Local cArquivo  	:= ""
	Local cDefPath		:= ""
	Local cPath     	:= ""
	Local cCabec		:= "/eSocial/evtDeslig/"
	Local oXml 			:= tXmlManager():New()
	Local oExcelApp 	:= Nil
	Local lExecLot		:= IsInCallStack("fEnvLote")
	Local nPosDmDev		:= 0
	Local dDtPagto		:= CTOD("//")

	//Vari·veis utilizadas para criaÁ„o das abas
	Local cAba1   := OemToAnsi(STR0331)//"Demonstrativo Verbas"
	Local cAba2   := OemToAnsi(STR0332)//"Dem. Meses Anteriores"
	Local cAba3   := OemToAnsi(STR0333)//"MV - Outras Empresas"
	Local cAba4   := OemToAnsi(STR0334)//"Legenda"
	Local cAba5	  := OemToAnsi(STR0386)//"Dem. Verbas + Dem. Meses Anteriores"
	Local cAba6   := OemToAnsi(STR0398)//"InconsistÍncias"

	//Vari·veis utilizadas na criaÁ„o das tabelas
	Local cTabela1 := OemToAnsi(STR0331)//"Demonstrativo Verbas"
	Local cTabela2 := OemToAnsi(STR0332)//"Dem. Meses Anteriores"
	Local cTabela3 := OemToAnsi(STR0333)//"MV - Outras Empresas"
	Local cTabela4 := OemToAnsi(STR0334)//"Legenda"
	Local cTabela5 := OemToAnsi(STR0386)//"Dem. Verbas + Dem. Meses Anteriores"
	Local cTabela6 := OemToAnsi(STR0398)//"InconsistÍncias"

	//Vari·veis utilizadas nas impressÍs das linhas
	Local cCodFil		:= ""
	Local cCodMat		:= ""
	Local cCatEFD		:= ""
	Local cNome			:= ""
	Local cCPF			:= ""
	Local cideDmDev		:= ""
	Local ctpInsc		:= ""
	Local cnrInsc 		:= ""
	Local ccodLotacao	:= ""
	Local cMateSocial	:= ""
	Local ccodRubr		:= ""
	Local cideTabRubr	:= ""
	Local nfatorRubr	:= ""
	Local nqtdRubr		:= ""
	Local nvrRubr		:= ""
	Local nindApurIR	:= ""
	Local cCodFol		:= ""
	Local cTpCod		:= ""
	Local cCodNat		:= ""
	Local cCodINCCP 	:= ""
	Local cCodINCIRF 	:= ""
	Local cCodINCFGT 	:= ""
	Local cCodINPIS		:= ""
	Local cIncINS 		:= ""
	Local cIncIRF 		:= ""
	Local cIncFGT 		:= ""
	Local cIncPIS		:= ""
	Local cindSimples	:= ""
	Local cdtAcConv		:= ""
	Local ctpAcConv		:= ""
	Local cdsc			:= ""
	Local cDescCod		:= ""

	//Vari·veis utilizadas nos Whiles do XML
	Local cideVinculo	:= ""
	Local ninfoDeslig	:= 0
	Local cinfoDeslig	:= ""
	Local nverbasResc 	:= 0
	Local cverbasResc 	:= ""
	Local ndmDev 		:= 0
	Local cdmDev 		:= ""
	Local ninfoPerApur	:= 0
	Local cinfoPerApur	:= ""
	Local nideEstabLot	:= 0
	Local cideEstabLot	:= ""
	Local ndetVerbas 	:= 0
	Local cdetVerbas 	:= ""
	Local ninfoPerAnt 	:= 0
	Local cinfoPerAnt 	:= ""
	Local nideADC 		:= 0
	Local cideADC 		:= ""
	Local nidePeriodo 	:= 0
	Local cidePeriodo 	:= ""
	Local nCntIncons	:= 0

	Default cXML		:= ""
	Default cDtEfei		:= ""
	Default cCompAc		:= ""
	Default cDescMtv	:= ""
	Default dDtGerDem	:= CTOD("//")
	Default aRelIncons	:= {}

	//Grava no mesmo diretÛrio do XML
	If !IsBlind() .And. !lExecLot
		cArquivo  	:= "RELATORIO_S2299.xls"
		cDefPath	:= GetSrvProfString( "StartPath", "\system\" )
		cPath		:= cGetFile( OemToAnsi(STR0335) + "|*.*", OemToAnsi(STR0336), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )//"DiretÛrio"##"Selecione um diretÛrio para a geraÁ„o do relatÛrio"
	EndIf

	//Cancela execuÁ„o do relatÛrio se n„o for selecionado um diretÛrio
	If !lExecLot .And. !IsBlind()
		If Empty(cPath) .And. !lExecLot
			Return()
		ElseIf !ExistDir(cPath)
			MsgAlert(OemToAnsi(STR0335) + cPath + OemToAnsi(STR0376), OemToAnsi(STR0001))  //"DiretÛrio inv·lido"
			cPath := ""
			Return()
		EndiF
	EndIf

	If oExcel == Nil
		oExcel  := FWMSExcel():New()

		// CriaÁ„o de nova aba
		oExcel:AddworkSheet(cAba1)
		oExcel:AddworkSheet(cAba2)
		oExcel:AddworkSheet(cAba3)
		oExcel:AddworkSheet(cAba4)
		oExcel:AddworkSheet(cAba5)
		oExcel:AddworkSheet(cAba6)

		// CriaÁ„o de tabela
		oExcel:AddTable(cAba1, cTabela1)
		oExcel:AddTable(cAba2, cTabela2)
		oExcel:AddTable(cAba3, cTabela3)
		oExcel:AddTable(cAba4, cTabela4)
		oExcel:AddTable(cAba5, cTabela5)
		oExcel:AddTable(cAba6, cTabela6)

		// CriaÁ„o de colunas - Demonstrativos Verbas
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0337) ,1,1,.F.)//"Filial do Funcion·rio"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0338) ,1,1,.F.)//"CPF do Funcion·rio"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0339) ,1,1,.F.)//"Nome do Funcion·rio"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0340) ,1,1,.F.)//"Categoria eSocial"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0399) ,1,1,.F.)//"Motivo de Desligamento eSocial"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0341) ,1,1,.F.)//"ideDmDev"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0342) ,1,1,.F.)//"Estabelecimento (Tipo - Nr. InscriÁ„o)"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0343) ,1,1,.F.)//"LotaÁ„o"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0344) ,1,1,.F.)//"Matricula - MatrÌcula eSocial"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0345) ,1,1,.F.)//"Ind. Simples"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0346) ,1,1,.F.)//"Verba"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0387) ,1,1,.F.)//"DescriÁ„o"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0347) ,1,1,.F.)//"ID C·lculo"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0348) ,1,1,.F.)//"Tipo da Verba"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0349) ,1,3,.F.)//"Valor"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0350) ,1,1,.F.)//"Natureza"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0351) ,1,1,.F.)//"IncidÍncia INSS eSocial"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0352) ,1,1,.F.)//"IncidÍncia IRFF eSocial"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0353) ,1,1,.F.)//"IncidÍncia FGTS eSocial"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0417) ,1,1,.F.)//"IncidÍncia PIS eSocial"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0354) ,1,1,.F.)//"IncidÍncia INSS Folha"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0355) ,1,1,.F.)//"IncidÍncia IRRF Folha"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0356) ,1,1,.F.)//"IncidÍncia FGTS Folha"
		oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0418) ,1,1,.F.)//"IncidÍncia PIS Folha"

		// CriaÁ„o de colunas - Dem. Meses Anteriores
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0337) ,1,1,.F.)//"Filial do Funcion·rio"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0338) ,1,1,.F.)//"CPF do Funcion·rio"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0339) ,1,1,.F.)//"Nome do Funcion·rio"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0340) ,1,1,.F.)//"Categoria eSocial"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0399) ,1,1,.F.)//"Motivo de Desligamento eSocial"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0341) ,1,1,.F.)//"ideDmDev"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0357) ,1,1,.F.)//"Data do Acordo"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0358) ,1,1,.F.)//"Tipo do Acordo"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0359) ,1,1,.F.)//"CompetÍncia do Acordo"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0360) ,1,1,.F.)//"Data de Efeito"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0361) ,1,1,.F.)//"PerÌodo de ReferÍncia"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0342) ,1,1,.F.)//"Estabelecimento (Tipo - Nr. InscriÁ„o)"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0343) ,1,1,.F.)//"LotaÁ„o"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0344) ,1,1,.F.)//"Matricula - MatrÌcula eSocial"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0345) ,1,1,.F.)//"Ind. Simples"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0346) ,1,1,.F.)//"Verba"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0387) ,1,1,.F.)//"DescriÁ„o"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0347) ,1,1,.F.)//"ID C·lculo"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0348) ,1,1,.F.)//"Tipo da Verba"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0349) ,1,3,.F.)//"Valor"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0350) ,1,1,.F.)//"Natureza"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0351) ,1,1,.F.)//"IncidÍncia INSS eSocial"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0352) ,1,1,.F.)//"IncidÍncia IRFF eSocial"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0353) ,1,1,.F.)//"IncidÍncia FGTS eSocial"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0417) ,1,1,.F.)//"IncidÍncia PIS eSocial"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0354) ,1,1,.F.)//"IncidÍncia INSS Folha"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0355) ,1,1,.F.)//"IncidÍncia IRRF Folha"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0356) ,1,1,.F.)//"IncidÍncia FGTS Folha"
		oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0418) ,1,1,.F.)//"IncidÍncia PIS Folha"

		// CriaÁ„o de colunas - MV - Outras Empresas
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0337) ,1,1,.F.)//"Filial do Funcion·rio"
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0338) ,1,1,.F.)//"CPF do Funcion·rio"
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0339) ,1,1,.F.)//"Nome do Funcion·rio"
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0344) ,1,1,.F.)//"Matricula - MatrÌcula eSocial"
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0340) ,1,1,.F.)//"Categoria eSocial"
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0362) ,1,1,.F.)//"Tipo de Recolhimento"
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0363) ,1,1,.F.)//"Empresa (Tipo - Nr. InscriÁ„o)"
		oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0364) ,1,3,.F.)//"Valor RemuneraÁ„o"

		// CriaÁ„o de colunas - MV - Legendas
		oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0365) ,1,1,.F.)//"Tipo"
		oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0366) ,1,1,.F.)//"Valor"

		oExcel:AddRow(cAba4, cTabela4, { OemToAnsi(STR0367), OemToAnsi(STR0368) } )//"Tipos de Estabelecimento"##"1-CNPJ | 2-CPF | 3-CAEPF | 4-CNO | 5-CGC"
		oExcel:AddRow(cAba4, cTabela4, { OemToAnsi(STR0369), OemToAnsi(STR0370) } )//"Indicador Simples"##"1-ContribuiÁ„o SubstituÌda Integralmente | 2-ContribuiÁ„o n„o substituÌda | 3-ContribuiÁ„o n„o substituÌda concomitante com contribuiÁ„o substituÌda"
		oExcel:AddRow(cAba4, cTabela4, { OemToAnsi(STR0348), OemToAnsi(STR0371) } )//"Tipo da Verba"##"1-Provento | 2-Desconto | 3-Base (Provento) | 4-Base (Desconto)"
		oExcel:AddRow(cAba4, cTabela4, { OemToAnsi(STR0372), OemToAnsi(STR0373) } )//"Indicativo de Tipo de Recolhimento MV"##"1-O declarante aplica a alÌquota de desconto do segurado sobre a remuneraÁ„o por ele informada (o percentual da alÌquota ser· obtido considerando a remuneraÁ„o total do trabalhador)"
		oExcel:AddRow(cAba4, cTabela4, { OemToAnsi(STR0372), OemToAnsi(STR0374) } )//"Indicativo de Tipo de Recolhimento MV"##"2-O declarante aplica a alÌquota de desconto do segurado sobre a diferenÁa entre o limite m·ximo do sal·rio de contribuiÁ„o e a remuneraÁ„o de outra(s) empresa(s) para as quais o trabalhador informou que houve o desconto"
		oExcel:AddRow(cAba4, cTabela4, { OemToAnsi(STR0372), OemToAnsi(STR0375) } )//"Indicativo de Tipo de Recolhimento MV"##"3- O declarante n„o realiza desconto do segurado, uma vez que houve desconto sobre o limite m·ximo de sal·rio de contribuiÁ„o em outra(s) empresa(s)"

		// CriaÁ„o de colunas - Demonstrativos Verbas
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0337) ,1,1,.F.)//"Filial do Funcion·rio"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0338) ,1,1,.F.)//"CPF do Funcion·rio"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0339) ,1,1,.F.)//"Nome do Funcion·rio"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0340) ,1,1,.F.)//"Categoria eSocial"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0399) ,1,1,.F.)//"Motivo de Desligamento eSocial"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0341) ,1,1,.F.)//"ideDmDev"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0342) ,1,1,.F.)//"Estabelecimento (Tipo - Nr. InscriÁ„o)"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0343) ,1,1,.F.)//"LotaÁ„o"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0344) ,1,1,.F.)//"Matricula - MatrÌcula eSocial"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0345) ,1,1,.F.)//"Ind. Simples"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0346) ,1,1,.F.)//"Verba"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0387) ,1,1,.F.)//"DescriÁ„o"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0347) ,1,1,.F.)//"ID C·lculo"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0348) ,1,1,.F.)//"Tipo da Verba"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0349) ,1,3,.F.)//"Valor"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0350) ,1,1,.F.)//"Natureza"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0351) ,1,1,.F.)//"IncidÍncia INSS eSocial"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0352) ,1,1,.F.)//"IncidÍncia IRFF eSocial"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0353) ,1,1,.F.)//"IncidÍncia FGTS eSocial"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0417) ,1,1,.F.)//"IncidÍncia PIS eSocial"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0354) ,1,1,.F.)//"IncidÍncia INSS Folha"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0355) ,1,1,.F.)//"IncidÍncia IRRF Folha"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0356) ,1,1,.F.)//"IncidÍncia FGTS Folha"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0418) ,1,1,.F.)//"IncidÍncia PIS Folha"
		oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0388) ,1,1,.F.)//"Data de Pagamento"

		// CriaÁ„o de colunas - InconsistÍncias
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0337) ,1,1,.F.)//"Filial do Funcion·rio"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0344) ,1,1,.F.)//"Matricula - MatrÌcula eSocial"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0339) ,1,1,.F.)//"Nome do Funcion·rio"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0338) ,1,1,.F.)//"CPF do Funcion·rio"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0400) ,1,1,.F.)//"Data de Desligamento"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0401) ,1,1,.F.)//"Data de GeraÁ„o"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0402) ,1,1,.F.)//"Data de Pagamento"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0399) ,1,1,.F.)//"Motivo de Desligamento eSocial"
		oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0398) ,1,1,.F.)//"InconsistÍncias"
	EndIf

	//Varre o XML para preenchimento do relatÛrio
	If oXml:Parse( fMidTrPath(cXML,"eSocial") )

		//Dados do funcion·rio
		cCodFil	:= SRA->RA_FILIAL
		cCodMat	:= SRA->RA_MAT
		cCatEFD	:= SRA->RA_CATEFD
		cNome	:= SRA->RA_NOMECMP
		cCPF	:= SRA->RA_CIC

		cideVinculo := cCabec + "ideVinculo[1]"
		If oXml:XPathHasNode(cideVinculo)
			cMateSocial := oXml:XPathGetNodeValue( cideVinculo + "/matricula " )
		EndIf

		ninfoDeslig := 1
		cinfoDeslig := cCabec + "infoDeslig[" + cValToChar(ninfoDeslig) + "]"

		//InformaÁıes do desligamento
		While oXml:XPathHasNode(cinfoDeslig)
			cmtvDeslig	:= oXml:XPathGetNodeValue( cinfoDeslig + "/mtvDeslig " )
			cdtDeslig	:= oXml:XPathGetNodeValue( cinfoDeslig + "/dtDeslig " )
			cdtAvPrv	:= oXml:XPathGetNodeValue( cinfoDeslig + "/dtAvPrv " )
			cindPagtoAPI:= oXml:XPathGetNodeValue( cinfoDeslig + "/indPagtoAPI " )
			npensAlim	:= oXml:XPathGetNodeValue( cinfoDeslig + "/pensAlim " )

			//InformaÁıes verbasResc
			nverbasResc := 1
			cverbasResc := cinfoDeslig + "/verbasResc[" + cValToChar(nverbasResc) + "]"
			While oXml:XPathHasNode(cverbasResc)

				//InformaÁıes dmDev
				ndmDev := 1
				cdmDev := cverbasResc + "/dmDev[" + cValToChar(ndmDev) + "]"
				While oXml:XPathHasNode(cdmDev)

					dDtPagto := CTOD("//")
					cideDmDev := oXml:XPathGetNodeValue( cdmDev + "/ideDmDev " )
					nPosDmDev := aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3] == cCodFil+cCodMat+cideDmDev })
					If nPosDmDev > 0
						dDtPagto := STOD(aDtPgtDmDev[nPosDmDev, 4])
					EndIf

					//InformaÁıes infoPerApur
					ninfoPerApur := 1
					cinfoPerApur := cdmDev + "/infoPerApur[" + cValToChar(ninfoPerApur) + "]"
					While oXml:XPathHasNode(cinfoPerApur)

						//InformaÁıes ideEstabLot
						nideEstabLot := 1
						cideEstabLot := cinfoPerApur + "/ideEstabLot[" + cValToChar(nideEstabLot) + "]"
						While oXml:XPathHasNode(cideEstabLot)

							ctpInsc	 	:= cValToChar(oXml:XPathGetNodeValue( cideEstabLot + "/tpInsc " ))
							cnrInsc	 	:= oXml:XPathGetNodeValue( cideEstabLot + "/nrInsc " )
							ccodLotacao	:= oXml:XPathGetNodeValue( cideEstabLot + "/codLotacao " )

							cindSimples := oXml:XPathGetNodeValue( cideEstabLot + "/infoSimples[1]/indSimples" )

							//InformaÁıes detVerbas
							ndetVerbas := 1
							cdetVerbas := cideEstabLot + "/detVerbas[" + cValToChar(ndetVerbas) + "]"
							While oXml:XPathHasNode(cdetVerbas)

								ccodRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/codRubr " )
								cideTabRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/ideTabRubr " )
								nfatorRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/fatorRubr " )
								nqtdRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/qtdRubr " )
								nvrRubr		:= oXml:XPathGetNodeValue( cdetVerbas + "/vrRubr " )
								nvrRubr		:= Val(StrTran(nvrRubr,",","."))
								nindApurIR	:= oXml:XPathGetNodeValue( cdetVerbas + "/indApurIR " )

								//Dados do Cadastro de Verbas
								cDescCod	:= RetValSrv( ccodRubr, cCodFil, 'RV_DESC' )
								cCodFol		:= RetValSrv( ccodRubr, cCodFil, 'RV_CODFOL' )
								cTpCod		:= RetValSrv( ccodRubr, cCodFil, 'RV_TIPOCOD' )
								cCodNat		:= RetValSrv( ccodRubr, cCodFil, 'RV_NATUREZ' )
								cCodINCCP 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCCP' )
								cCodINCIRF 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCIRF' )
								cCodINCFGT 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCFGTS' )
								cCodINPIS 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCPIS' )
								cIncINS 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INSS' )
								cIncIRF 	:= RetValSrv( ccodRubr, cCodFil, 'RV_IR' )
								cIncFGT 	:= RetValSrv( ccodRubr, cCodFil, 'RV_FGTS' )
								cIncPIS 	:= RetValSrv( ccodRubr, cCodFil, 'RV_PIS' )

								//Identifica verbas com natureza descontinuada para fÈrias
								If cCodNat $ "1020|1021"
									//Verba de cÛdigo XXX possui a natureza 0000 e deve ser substituÌda por 1016, 1017, 1018 ou 1019. Verba presente no grupo infoPerApur do demonstrativo
									aAdd(aRelIncons,{cCodFil, cCPF, STOD(cdtDeslig), dDtGerDem, dDtPagto, OemtoAnsi(STR0403) + ccodRubr + OemtoAnsi(STR0404) + cCodNat + OemtoAnsi(STR0405) + cideDmDev})
								EndIf

								//Cria linha na Aba 1 - Demonstrativo Verbas
								oExcel:AddRow(cAba1, cTabela1, { cCodFil, cCPF, cNome, cCatEFD, cDescMtv, cideDmDev, ctpInsc + " - " + cnrInsc, ccodLotacao, cCodMat + " - " + cMateSocial, cindSimples, ccodRubr, cDescCod, cCodFol, cTpCod, nvrRubr, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cCodINPIS, cIncINS, cIncIRF, cIncFGT, cIncPIS} )
								oExcel:AddRow(cAba5, cTabela5, { cCodFil, cCPF, cNome, cCatEFD, cDescMtv, cideDmDev, ctpInsc + " - " + cnrInsc, ccodLotacao, cCodMat + " - " + cMateSocial, cindSimples, ccodRubr, cDescCod, cCodFol, cTpCod, nvrRubr, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cCodINPIS, cIncINS, cIncIRF, cIncFGT, cIncPIS, dDtPagto } )

								ndetVerbas ++
								cdetVerbas := cideEstabLot + "/detVerbas[" + cValToChar(ndetVerbas) + "]"
							EndDo

							nideEstabLot ++
							cideEstabLot := cinfoPerApur + "/ideEstabLot[" + cValToChar(nideEstabLot) + "]"
						EndDo

						ninfoPerApur ++
						cinfoPerApur := cideDmDev + "/infoPerApur[" + cValToChar(ninfoPerApur) + "]"
					EndDo

					//InformaÁıes infoPerAnt
					ninfoPerAnt := 1
					cinfoPerAnt := cdmDev + "/infoPerAnt[" + cValToChar(ninfoPerAnt) + "]"
					While oXml:XPathHasNode(cinfoPerAnt)

						//InformaÁıes ideADC
						nideADC := 1
						cideADC := cinfoPerAnt + "/ideADC[" + cValToChar(nideADC) + "]"
						While oXml:XPathHasNode(cideADC)

							cdtAcConv	:= oXml:XPathGetNodeValue( cideADC + "/dtAcConv " )
							ctpAcConv	:= oXml:XPathGetNodeValue( cideADC + "/tpAcConv " )
							cdsc		:= oXml:XPathGetNodeValue( cideADC + "/dsc " )

							//InformaÁıes idePeriodo
							nidePeriodo := 1
							cidePeriodo := cideADC + "/idePeriodo[" + cValToChar(nidePeriodo) + "]"
							While oXml:XPathHasNode(cidePeriodo)

								cperRef := oXml:XPathGetNodeValue( cidePeriodo + "/perRef " )

								//InformaÁıes ideEstabLot
								nideEstabLot := 1
								cideEstabLot := cidePeriodo + "/ideEstabLot[" + cValToChar(nideEstabLot) + "]"
								While oXml:XPathHasNode(cideEstabLot)

									ctpInsc	 	:= cValToChar(oXml:XPathGetNodeValue( cideEstabLot + "/tpInsc " ))
									cnrInsc	 	:= oXml:XPathGetNodeValue( cideEstabLot + "/nrInsc " )
									ccodLotacao	:= oXml:XPathGetNodeValue( cideEstabLot + "/codLotacao " )

									//InformaÁıes detVerbas
									ndetVerbas := 1
									cdetVerbas := cideEstabLot + "/detVerbas[" + cValToChar(ndetVerbas) + "]"
									While oXml:XPathHasNode(cdetVerbas)

										ccodRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/codRubr " )
										cideTabRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/ideTabRubr " )
										nfatorRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/fatorRubr " )
										nqtdRubr	:= oXml:XPathGetNodeValue( cdetVerbas + "/qtdRubr " )
										nvrRubr		:= oXml:XPathGetNodeValue( cdetVerbas + "/vrRubr " )
										nvrRubr		:= Val(StrTran(nvrRubr,",","."))
										nindApurIR	:= oXml:XPathGetNodeValue( cdetVerbas + "/indApurIR " )

										//Dados do Cadastro de Verbas
										cDescCod	:= RetValSrv( ccodRubr, cCodFil, 'RV_DESC' )
										cCodFol		:= RetValSrv( ccodRubr, cCodFil, 'RV_CODFOL' )
										cTpCod		:= RetValSrv( ccodRubr, cCodFil, 'RV_TIPOCOD' )
										cCodNat		:= RetValSrv( ccodRubr, cCodFil, 'RV_NATUREZ' )
										cCodINCCP 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCCP' )
										cCodINCIRF 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCIRF' )
											cCodINCFGT 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCFGTS' )
										cCodINPIS 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INCPIS' )
										cIncINS 	:= RetValSrv( ccodRubr, cCodFil, 'RV_INSS' )
										cIncIRF 	:= RetValSrv( ccodRubr, cCodFil, 'RV_IR' )
										cIncFGT 	:= RetValSrv( ccodRubr, cCodFil, 'RV_FGTS' )
										cIncPIS 	:= RetValSrv( ccodRubr, cCodFil, 'RV_PIS' )

										If cCodNat $ "1020|1021"
											//Verba de cÛdigo XXX possui a natureza 0000 e deve ser substituÌda por 1016, 1017, 1018 ou 1019. Verba presente no grupo infoPerAnt do demonstrativo
											aAdd(aRelIncons,{cCodFil, cCPF, STOD(cdtDeslig), dDtGerDem, dDtPagto, OemtoAnsi(STR0403) + ccodRubr + OemtoAnsi(STR0404) + cCodNat + OemtoAnsi(STR0406) + cideDmDev})
										EndIf

										//Cria linha na Aba 2 - Dem. Meses Anteriores
										oExcel:AddRow(cAba2, cTabela2, { cCodFil, cCPF, cNome, cCatEFD, cDescMtv, cideDmDev, stod(replace(cdtAcConv,"-","")), ctpAcConv, cCompAc, stoD(cDtEfei), cperRef, ctpInsc + " - " + cnrInsc, ccodLotacao, cCodMat + " - " + cMateSocial, cindSimples, ccodRubr, cDescCod, cCodFol, cTpCod, nvrRubr, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cCodINPIS, cIncINS, cIncIRF, cIncFGT, cIncPIS } )
										oExcel:AddRow(cAba5, cTabela5, { cCodFil, cCPF, cNome, cCatEFD, cDescMtv, cideDmDev, ctpInsc + " - " + cnrInsc, ccodLotacao, cCodMat + " - " + cMateSocial, cindSimples, ccodRubr, cDescCod, cCodFol, cTpCod, nvrRubr, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cCodINPIS, cIncINS, cIncIRF, cIncFGT, cIncPIS, dDtPagto } )

										ndetVerbas ++
										cdetVerbas := cideEstabLot + "/detVerbas[" + cValToChar(ndetVerbas) + "]"
									EndDo

									//InformaÁıes ideEstabLot
									nideEstabLot ++
									cideEstabLot := cideADC + "/ideEstabLot[" + cValToChar(nideEstabLot) + "]"
								EndDo

								nidePeriodo ++
								cidePeriodo := cideADC + "/idePeriodo[" + cValToChar(nidePeriodo) + "]"
							EndDo

							nideADC ++
							cideADC := cinfoPerAnt + "/ideADC[" + cValToChar(nideADC) + "]"
						EndDo

						ninfoPerAnt ++
						cinfoPerAnt := cideDmDev + "/infoPerAnt[" + cValToChar(ninfoPerAnt) + "]"
					EndDo

					ndmDev ++
					cdmDev := cverbasResc + "/dmDev[" + cValToChar(ndmDev) + "]"
				EndDo

				//InformaÁıes infoMV
				ninfoMV := 1
				cinfoMV := cverbasResc + "/infoMV[" + cValToChar(ninfoMV) + "]"
				While oXml:XPathHasNode(cinfoMV)

					cindMV := oXml:XPathGetNodeValue( cinfoMV + "/indMV " )

					//InformaÁıes remunOutrEmpr
					nremunOutrEmpr := 1
					cremunOutrEmpr := cinfoMV + "/remunOutrEmpr[" + cValToChar(nremunOutrEmpr) + "]"
					While oXml:XPathHasNode(cremunOutrEmpr)

						ctpInsc	 	:= cValToChar(oXml:XPathGetNodeValue( cremunOutrEmpr + "/tpInsc " ))
						cnrInsc	 	:= oXml:XPathGetNodeValue( cremunOutrEmpr + "/nrInsc " )
						ccodCateg	:= oXml:XPathGetNodeValue( cremunOutrEmpr + "/codCateg " )
						cvlrRemunOE	:= oXml:XPathGetNodeValue( cremunOutrEmpr + "/vlrRemunOE " )
						cvlrRemunOE	:= Val(StrTran(cvlrRemunOE,",","."))

						oExcel:AddRow(cAba3, cTabela3, { cCodFil, cCPF, cNome, cCodMat + " - " + cMateSocial, ccodCateg, cindMV, ctpInsc + " - " + cnrInsc, cvlrRemunOE } )

						nremunOutrEmpr ++
						cremunOutrEmpr := cinfoMV + "/remunOutrEmpr[" + cValToChar(nremunOutrEmpr) + "]"
					EndDo

					ninfoMV ++
					cinfoMV := cverbasResc + "/infoMV[" + cValToChar(ninfoMV) + "]"
				EndDo

				nverbasResc ++
				cverbasResc := cinfoDeslig + "/verbasResc[" + cValToChar(nverbasResc) + "]"
			EndDo

			ninfoDeslig ++
			cinfoDeslig := cCabec + "/infoDeslig[" + cValToChar(ninfoDeslig) + "]"
		EndDo
	EndIf

	//InformaÁ„o de inconsistÍncias
	For nCntIncons := 1 To Len(aRelIncons)
		oExcel:AddRow(cAba6, cTabela6, { aRelIncons[nCntIncons, 1], cCodMat + " - " + cMateSocial, cNome, aRelIncons[nCntIncons, 2], aRelIncons[nCntIncons, 3], aRelIncons[nCntIncons, 4], aRelIncons[nCntIncons, 5], cDescMtv, aRelIncons[nCntIncons, 6] } )
	Next nCntIncons

	If !Empty(oExcel:aWorkSheet) .And. !lExecLot
		oExcel:Activate() //ATIVA O EXCEL
		oExcel:GetXMLFile(cArquivo)

		IF !IsBlind() .And. cDefPath != cPath
			CpyS2T(cDefPath+cArquivo, cPath)
		EndIf

		If !IsBlind()
			If ApOleClient( "MSExcel" )
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
				oExcelApp:SetVisible(.T.)
			EndIf
		EndIf

		oExcel:DeActivate()
		oExcel := Nil
	EndIf

Return

/*/{Protheus.doc} fRRA2299
GeraÁ„o de verbas de RRA no evento S-2299
@author Silvia Taguti
@since 13/03/2023
/*/

Function fRRA2299( cXml, oModel, aDadosCCT, cIndSimp, dDataRes,cCompTrab, nMesRRA, cTipo, aPdRRA, lRel )

	Local dLastDate	:= ctod("")
	Local cIdTbRub	:= If(! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local cVersEnvio:= ""
	Local nPosCC	:= 0
	Local nPercRub	:= 0
	Local aArea		:= GetArea()
	Local nB        := 0
	Local oGrid
	Local dDataGer  := ctod("")
	Local aInfoRRA  := {}
	Local lRet      := .F. //Indica se iniciou o bloco do RRA
	Local lRVIncop	:= SRV->(ColumnPos("RV_INCOP")) > 0
	Local lRVTetop 	:= SRV->(ColumnPos("RV_TETOP")) > 0
	Local lRetIR	:= .F. //Identifica as verbas que possuem configuraÁ„o de IR (uso para gravar RJO - RelatÛrio de IRRF)
	Local lPerApur	:= .F. //Identifica que gerou o infoPerApur do RRA
	Local lRRASemIR := SuperGetMv("MV_RRASIR", , .F.) //Indica se deve considerar demais verbas de RRA e n„o apenas o recolhimento de IR

	Default cCompTrab 	:= ""
	Default cIndSimp	:= ""
	Default aDadosCCT   := {}
	Default cXML 		:= ""
	Default nMesRRA     := 1
	Default cTipo       := "1"
	Default aPdRRA		:= {}
	Default lRel		:= .F.

	If lRRASemIR
		cPdRRA := ("'"+aCodFol[0974,1]+"','"+aCodFol[0975,1]+"','"+aCodFol[0976,1]+"','"+aCodFol[0977,1]+"','"+aCodFol[0978,1]+"','"+aCodFol[0979,1]+"','"+aCodFol[0980,1]+"','"+aCodFol[0981,1]+"','"+aCodFol[0982,1]+"','"+aCodFol[0983,1]+"','"+aCodFol[0986,1]+"','"+aCodFol[0987,1]+"'")
			cVerbRRA := (aCodFol[0974,1]+"/"+aCodFol[0975,1]+"/"+aCodFol[0976,1]+"/"+aCodFol[0977,1]+"/"+aCodFol[0978,1]+"/"+aCodFol[0979,1]+"/"+aCodFol[0980,1]+"/"+aCodFol[0981,1]+"/"+aCodFol[0982,1]+"/"+aCodFol[0983,1]+"/"+aCodFol[0986,1]+"/"+aCodFol[0987,1])
	Else
		cPdRRA:= ("'"+aCodFol[0978,1]+"'")
	EndIf

	fVersEsoc( "S2299",,,, @cVersEnvio )

	If lMiddleware
		cIdTbRub := fGetIdRJF( xFilial("SRV", SRA->RA_FILIAL), cIdTbRub )
	EndIf

	If !Empty(cCompTrab)
		aInfoRRA := fInfoRRA(cCompTrab)
	Endif

	If cTipo == "1"
		oGrid		:= oModel:GetModel("GPEM040_MGET")
		dDataRes		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATADEM"), dDataRes)
		dDataGer		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DTGERAR"), dDataRes)

		For nB := 1 To oGrid:Length()
			oGrid:GoLine(nB)

			If Dtos(oGrid:GetValue("RR_DATA")) <= dToS(dDataGer) .And. oGrid:GetValue("RR_ROTEIR") == 'RES' .And.;
				oGrid:GetValue("RR_TIPO3") == 'R' .And. oGrid:GetValue("RR_PD") $ cPdRRA

				lRet := .T.
				If dLastDate != dDataGer
					cIdDmDev := "DRRA"+ cEmpAnt + Alltrim(xFilial("SRG")) + oModel:GetModel("GPEM040_MSRG"):GetValue("RG_MAT")
					nPosCC := Ascan( aDadosCCT, { |X| X[1] == oGrid:GetValue("RR_CC")})
					cXml += "<dmDev>"
					cXml += "<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
					If Len(aInfoRRA) > 0
						S1200A28(@cXml, aInfoRRA,nMesRRA)
					Endif
				EndIf

				//Inicia o grupo infoPerApur somente para a verba de IR sobre RRA
				If oGrid:GetValue("RR_PD") $ aCodFol[0978,1] .And. !lPerApur
					cXml += "<infoPerApur>"
					cXml += "<ideEstabLot>"
					cXml += "<tpInsc>" + aDadosCCT[nPosCC, 2] + "</tpInsc>"
					cXml += "<nrInsc>"+ Iif(!lMiddleware,aDadosCCT[nPosCC,3],Alltrim(aDadosCCT[nPosCC,3]) ) + "</nrInsc>"
					cXml += "<codLotacao>" + Iif(!lMiddleware,StrTran( aDadosCCT[nPosCC,4], "&", "&amp;"), Alltrim(StrTran( aDadosCCT[nPosCC,4], "&", "&amp;")))  + "</codLotacao>"
					lPerApur := .T.
				EndIf

				dLastDate := dDataGer
				PosSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL )
				nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

				If oGrid:GetValue("RR_PD") $ aCodFol[0978,1] .And. oGrid:GetValue("RR_VALOR") > 0
					cXml += "<detVerbas>"
					cXml += 	"<codRubr>" + oGrid:GetValue("RR_PD")+ "</codRubr>"
					cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
					If !Empty(oGrid:GetValue("RR_HORAS"))
						cXml += "<qtdRubr>" + Iif(!lMiddleware,Str(oGrid:GetValue("RR_HORAS")),Alltrim(Str(round(oGrid:GetValue("RR_HORAS"),2))) ) + "</qtdRubr>"
					EndIf
					If !Empty(nPercRub)
						cXml += "<fatorRubr>" + Iif(!lMiddleware, Transform(nPercRub,"@E 999.99"),AllTrim(StrTran(Transform(nPercRub,"@E 999.99"),",", "." )) )+ "</fatorRubr>"
					EndIf
					cXml += 	"<vrRubr>" + Iif(!lMiddleware,AllTrim( Transform(oGrid:GetValue("RR_VALOR"), "@E 999999999.99") ),AllTrim( Str(oGrid:GetValue("RR_VALOR"))) )+ "</vrRubr>"

					If cVersEnvio >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
						cXml +=         '<indApurIR>0</indApurIR>'
					Endif
					cXml += "</detVerbas>"
					If !lRel .And. lMiddleware
						lRetIR := (lVbRelIR .And. fVbRelIR(SRV->RV_NATUREZ, ALLTRIM(SRV->RV_INCIRF))) //Confirma que se trata de verba de IR
						If lRetIR
							fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nPosCC, 2], aDadosCCT[nPosCC, 3], aDadosCCT[nPosCC,4], SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, oGrid:GetValue("RR_VALOR"), "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""), cIdDmDev, oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATAHOM"), oGrid:GetValue("RR_PD"), SRV->RV_CODFOL, ANOMES(oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATAHOM")), ,lRetIR)
						EndIf
					EndIf
				EndIf
			Endif
		Next nB
	else
		dDataGer		:=  M->RG_DTGERAR

		For nB := 1 To Len( aPdRRA )
			If cRoteiro == 'RES' .And. aPdRRA[nB,1] $ cPdRRA
				If dLastDate != dDataGer
					cIdDmDev := "DRRA"+ cEmpAnt + Alltrim(xFilial("SRG")) + SRA->RA_MAT
					nPosCC := Ascan( aDadosCCT, { |X| X[1] == aPdRRA[nB,2]})

					cXml += "<dmDev>"
					cXml += "<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
					If Len(aInfoRRA) > 0
						S1200A28(@cXml, aInfoRRA,nMesRRA)
					Endif
				EndIf

				//Inicia o grupo infoPerApur somente para a verba de IR sobre RRA
				If aPdRRA[nB,1] $ aCodFol[0978,1] .And. !lPerApur
					cXml += "<infoPerApur>"
					cXml += "<ideEstabLot>"
					cXml += "<tpInsc>" + aDadosCCT[nPosCC, 2] + "</tpInsc>"
					cXml += "<nrInsc>"+ Iif(!lMiddleware,aDadosCCT[nPosCC,3],Alltrim(aDadosCCT[nPosCC,3])) + " </nrInsc>"
					cXml += "<codLotacao>" +Iif(!lMiddleware,StrTran( aDadosCCT[nPosCC,4], "&", "&amp;"),Alltrim(StrTran( aDadosCCT[nPosCC,4], "&", "&amp;")) ) + "</codLotacao>"
					lPerApur := .T.
				EndIf

				dLastDate := dDataGer
				PosSrv( aPdRRA[nB,1], SRA->RA_FILIAL )
				nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

				If aPdRRA[nB,1] $ aCodFol[0978,1] .And. aPdRRA[nB,5] > 0
					cXml += "<detVerbas>"
					cXml += 	"<codRubr>" + aPdRRA[nB,1]+ "</codRubr>"
					cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
					If !Empty(aPdRRA[nB,4])
						cXml += "<qtdRubr>" + Iif(!lMiddleware,Str(aPdRRA[nB,4]), Alltrim(Str(round(aPdRRA[nB,4],2)))  ) + "</qtdRubr>"
					EndIf
					If !Empty(nPercRub)
						cXml += "<fatorRubr>" + Iif(!lMiddleware,Transform(nPercRub,"@E 999.99"),AllTrim(StrTran(Transform(nPercRub,"@E 999.99"),",", "." )))+ "</fatorRubr>"
					EndIf
					cXml += 	"<vrRubr>" + Iif(!lMiddleware, AllTrim(Transform(aPdRRA[nB,5], "@E 999999999.99")), AllTrim( Str(aPdRRA[nB,5]) )) + "</vrRubr>"

					If cVersEnvio >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
						cXml +=         '<indApurIR>0</indApurIR>'
					Endif
					cXml += "</detVerbas>"
					If !lRel .And. lMiddleware
						lRetIR := (lVbRelIR .And. fVbRelIR(SRV->RV_NATUREZ, ALLTRIM(SRV->RV_INCIRF))) //Confirma que se trata de verba de IR
						If lRetIR
							fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nPosCC, 2], aDadosCCT[nPosCC, 3], aDadosCCT[nPosCC,4], SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, aPdRRA[nB,5], "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""), cIdDmDev, M->RG_DATAHOM, aPdRRA[nB,1], SRV->RV_CODFOL, ANOMES(M->RG_DATAHOM), ,lRetIR)
						EndIf
					EndIf
				EndIf
				lRet := .T.
			Endif
		Next nB
	Endif

	If lPerApur
		If SRA->RA_TPPREVI == "1"
			S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
		EndIf
		If !Empty(cIndSimp)
			cXml += "<infoSimples>"
			cXml += "<indSimples>" + cIndSimp + "</indSimples>"
			cXml += "</infoSimples>"
		EndIf
		cXml += "</ideEstabLot>"
		cXml += "</infoPerApur>"
	Endif

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fDisRRA2299
FunÁ„o que verifica se existe calculo de RRA no mes da rescisao
@author Silvia Taguti
@since 13/03/2023
@version 1.0
@param dDataRes		- Data da demissao
@param cVBDiss 		- Verbas com as diferencas do dissidio
@param aDadosCCT	- Array com dados dos centros de custos
@param cIndSimp		- Indicador do Tipo de Simples Nacional.
@param cXmlAux		- XML gerado com as informacoes do dissidio
@param cMsgErro		- Mensagem de erro na validacao das tabelas S-050 e S-126
/*/
Function fDisRRA2299( dDataRes, cVBDiss, aDadosCCT, cIndSimp, cXmlAux, cMsgErro, lRJ5Ok, aErrosRJ5, cTpRes, aPd, cDtEfei, cCompAc)

Local cDscAc	:= ""
Local cDataCor	:= ""
Local cPerAnt	:= ""
Local cVersEnvio:= ""

Local cMes			:= StrZero( Month(dDataRes),2 )
Local cAno			:= cValToChar( Year(dDataRes) )
Local cRHHAlias		:= GetNextAlias()
Local cSRDTabRH		:= GetNextAlias()
Local lFirst		:= .T.
Local lTemVerbas	:= .F.
Local cIdTbRub		:= ""
Local aTabInss		:= {}
Local cBusca 		:= ""
Local cCCAnt		:= ""
Local lAbriu19 		:= .F.
Local lAbriu20 		:= .F.
Local lFechPer 		:= .F.
Local lFechEstLot 	:= .F.
Local lFechou20 	:= .F.
Local lFirstAnt 	:= .T.
Local lGeraRes 		:= .F.
Local lGerouAnt 	:= .F.
Local lVerDINSS		:= .T.
Local nValor		:= 0
Local cRRAData		:= ""
Local nMesRRA		:= 0
Local cCodFol 		:= ""
Local cTpCod 		:= ""
Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0
Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0

Private cAnoBase	:= cAno
Private aCC			:= fGM23CTT()//extrai lista de c.custo da filial conectada "xfilial(CTT)" ...

Default cXmlAux		:= ""
Default cMsgErro	:= ""
Default	cVBDiss		:= ""
Default lRJ5Ok		:= .T.
Default	aErrosRJ5	:= {}
Default cTpRes		:= ""
Default aPd			:= {}
Default cDtEfei		:= ""
Default cCompAc		:= ""

fVersEsoc( "S2299",,,, @cVersEnvio )

BeginSql alias cRHHAlias
SELECT 	RHH.RHH_FILIAL,RHH.RHH_MAT,RHH.RHH_MESANO,RHH.RHH_DATA, RHH.RHH_VB,RHH.RHH_CC,RHH.RHH_IDCMPL,RHH.RHH_GRRA,RHH.RHH_RRA,
        RHH.RHH_DTACOR,RHH.RHH_VERBA,RHH.RHH_HORAS,SUM(RHH.RHH_VALOR) AS RHH_VALOR
FROM  	%table:RHH% RHH
WHERE 	RHH.RHH_FILIAL =	%exp:SRA->RA_FILIAL%
AND 	RHH.RHH_MAT    =	%exp:SRA->RA_MAT   %
AND 	RHH.RHH_MESANO =	%exp:cAno+cMes%
AND  	RHH.RHH_COMPL_ = 'S'
AND 	RHH.RHH_GRRA = '1'
AND		RHH.RHH_RRA = '1'
AND      RHH.%notDel%
	GROUP BY RHH_FILIAL, RHH_MAT, RHH_MESANO, RHH_DATA, RHH_VB, RHH_CC ,RHH_IDCMPL, RHH_GRRA, RHH_RRA,RHH_DTACOR, RHH_VERBA, RHH_HORAS
	ORDER BY 1, 2, 3, 4, 6, 5
EndSql

If(lVerRJ5, fVerRJ5B(cRHHAlias, cSRDTabRH, AnoMes(dDataRes), @lRJ5Ok, @aErrosRJ5), .T.)

While (cRHHAlias)->(!Eof() .And. (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT+(cRHHAlias)->RHH_MESANO == SRA->RA_FILIAL+SRA->RA_MAT+cAno+cMes )

	If lFirst .And. FindFunction("fTpAco") .And. FindFunction("fDscAc") //As funcoes mudaram o escopo no arquivo GPEM036. Retirar essa verificacao no proximo release.
		cDtAco := (cRHHAlias)->RHH_DTACOR
		cTpAco := fTpAco(.T., "1", cMes+cAno, , , .T.)
		cDscAc := fDscAc(.T., "1", cMes+cAno, @cDataCor, .T.)
		cDtEfei:= If(!Empty(cDataCor), dToS(cDataCor), "")
		cCompAc:= cAno +"-"+ cMes
		lFirst := .F.
	EndIf

	If cPerAnt <> (cRHHAlias)->RHH_DATA

		lTemVerbas	:= .F.
		cPerAnt		:= (cRHHAlias)->RHH_DATA
		cCCAnt		:= ""
		nPosCC		:= Ascan( aDadosCCT, {|X| X[1] == (cRHHAlias)->RHH_CC })

		If(lFechPer,S1200F21 ( @cXmlAux), .T.)
		If(lFechPer,lFechPer 	:= .F.,.T.)

		lGeraPer 	:= .T.
		lTemVerbas	:= .F.
		lVerDINSS	:= .T.
		lGerDINSS	:= .F.
	EndIf

	If cCCAnt <> (cRHHAlias)->RHH_CC
		cTpInscr	:= ""
		cInscr		:= ""
		cCCAnt 		:= (cRHHAlias)->RHH_CC
		lFechEstLot	:= .F.
		lGeraEstLot	:= .T.
		lTemVerbas	:= .F.
		lVerDINSS	:= .T.
		lGerDINSS	:= .F.

		fEstabELot((cRHHAlias)->RHH_FILIAL, (cRHHAlias)->RHH_CC, @cTpInscr, @cInscr, @cBusca, Iif(lVerRJ5, (cRHHAlias)->RHH_CCBKP, ""), AnoMes(dDataRes))

		dbselectarea('CTT')
		DbsetOrder(1)
		CTT->(DBSeek( xFilial("CTT", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC )  )

		cVerIndSimples := ''
		If fOptSimp() == "1" .And. fInssEmp( (cRHHAlias)->RHH_FILIAL, @aTabInss, Nil, cAno+cMes )
			If Len(aTabInss) > 0
				cVerIndSimples := aTabInss[31, 1]
			Endif
		EndIf
	Endif

	If !((cRHHAlias)->RHH_VB == "000" .Or. (cRHHAlias)->RHH_VALOR <= 0.00)

		lTemVerbas	:= .T.
		If cRRAData <> (cRHHAlias)->RHH_DATA .And. (cRHHAlias)->RHH_MESANO > (cRHHAlias)->RHH_DATA
			cRRAData 	:= (cRHHAlias)->RHH_DATA
			nMesRRA		+= 1
		EndIf

		If lFirstAnt
			lFirstAnt	:= .F.
			lGerouAnt	:= .T.
			If !lAbriu19
				S1200A19(@cXmlAux,.F.)//infoPerAnt
				lAbriu19 := .T.
			Endif
			If !lAbriu20
				cXmlAux += "					<ideADC>"
				If cTpAco $ "A|B|C|D|E"
					cXmlAux += "						<dtAcConv>" + Iif(!lMiddleware, dToS(cDataCor),SubStr(dToS(cDataCor),1,4)+"-"+SubStr(dToS(cDataCor),5,2)+"-"+SubStr(dToS(cDataCor),7,2 )) + "</dtAcConv>"
				Endif
				cXmlAux += "						<tpAcConv>" + cTpAco + "</tpAcConv>"
				cXmlAux += "						<dsc>RRA</dsc>"
				lAbriu20 := .T.
			Endif
		EndIf
		If lGeraPer
			lFechPer	:= .T.
			lGeraPer 	:= .F.
			S1200A21(@cXmlAux, { SubStr((cRHHAlias)->RHH_DATA,1,4) + "-" + SubStr((cRHHAlias)->RHH_DATA,5,2) })//idePeriodo
		EndIf
		If lGeraEstLot
			lFechEstLot := .T.
			lGeraEstLot	:= .F.
			S1200A12 ( @cXmlAux, {cTpInscr,cInscr,cBusca, /*vazio nao enviar mesmo*/ }, .F.) //IdeEstabLot
		EndIf

		cVBDiss	+= If( (cRHHAlias)->RHH_VERBA $ cVBDiss, "", (cRHHAlias)->RHH_VERBA + "/" )

		//Posiciona na verba
		PosSrv( (cRHHAlias)->RHH_VB, SRA->RA_FILIAL )
		// Posiciona na verba em trabalho
		cCodFol 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_CODFOL' )
		cTpCod 		:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_TIPOCOD' )

		nValor :=  (cRHHAlias)->RHH_VALOR

		cIdTbRub := If( ! Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, cEmpAnt )

		If lMiddleware
			cIdTbRub := fGetIdRJF( SRV->RV_FILIAL, cIdTbRub )
		EndIf
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

		cVerbRFC := fGetVerbRRA(cCodFol,cTpCod)

		If  cVersEnvio >= "9.1" .And.  nValor > 0 .And. !Empty(cVerbRFC)
			cXmlAux += "								<detVerbas>"
			cXmlAux += "									<codRubr>" + cVerbRFC + "</codRubr>"
			cXmlAux += "									<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
			If !Empty((cRHHAlias)->RHH_HORAS)
				cXmlAux += "								<qtdRubr>" + Iif(!lMiddleware,Str((cRHHAlias)->RHH_HORAS),Alltrim(Str((cRHHAlias)->RHH_HORAS)) )+ "</qtdRubr>"
			EndIf
			If !Empty(nPercRub)
				cXmlAux += "								<fatorRubr>" + Iif(!lMiddleware,Transform(nPercRub,"@E 999.99"), AllTrim( StrTran(Transform(nPercRub,"@E 999.99"), ",", "." ))) + "</fatorRubr>"
			EndIf
			cXmlAux += "									<vrRubr>" + Iif(!lMiddleware,AllTrim( Transform(nValor,"@E 999999999.99")),AllTrim( Str(nValor))) + "</vrRubr>"
			If cVersEnvio >= "9.0.00" .And. cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
				cXmlAux +=         '<indApurIR>0</indApurIR>'
			Endif
			cXmlAux += "								</detVerbas>"
			If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") )
				fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, cTpInscr, cInscr, cBusca, SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, nValor, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""))
			EndIf
		EndIf
	EndIf
	(cRHHAlias)->(dbSkip())

	If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT == SRA->RA_FILIAL+SRA->RA_MAT .And. cPerAnt <> (cRHHAlias)->RHH_DATA .And. lFechPer
		If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
			cOcorren := fGrauExp()
			S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
			S1200F18 ( @cXmlAux)
		EndIf
		lFechPer := .F.
		S1200F12 ( @cXmlAux )//ideEstabLot
		S1200F21 ( @cXmlAux)//idePeriodo
		Loop
	EndIf
	If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT == SRA->RA_FILIAL+SRA->RA_MAT .And. cCCAnt <> (cRHHAlias)->RHH_CC .And. cPerAnt == (cRHHAlias)->RHH_DATA .And. lFechEstLot
		If SRA->RA_TPPREVI == "1"
			cOcorren := fGrauExp()
			S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
			S1200F18 ( @cXmlAux)
		EndIf
		lFechEstLot := .F.
		S1200F12 ( @cXmlAux )//ideEstabLot
	Endif
End

(cRHHAlias)->( dbCloseArea() )

If lTemVerbas
	If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
		cOcorren := fGrauExp()
		S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
		S1200F18 ( @cXmlAux)
	EndIf

	If(lFechPer .And. lFechEstLot, S1200F12( @cXmlAux ),.T. )//ideEstabLot
	If(lFechPer, S1200F21 ( @cXmlAux), .T.)//idePeriodo

EndIf
If lGerouAnt .Or. (!lGerouAnt .And. !lTemVerbas .And. lGeraRes .And. lAbriu20 .And. !lFechou20)
	S1200F20(@cXmlAux)//ideADC
	S1200F19(@cXmlAux)//infoPerAnt
EndIf

Return

/*/{Protheus.doc} fBuscaRRA
Verifica se possui valores de RRA na Rescis„o
@author staguti
@since 13/03/2023
/*/
Static Function fBuscaRRA(cTipo, cPdRRA, aPDRRA)
Local oModel	:= FWModelActive()
Local nG		:= 0
Local lRet		:= .F.
Local nValor	:= 0
Local oGrid
Local cVerba 	:= ""

Default cPdRRA	:= ""
Default aPDRRA  := {}
Default cTipo   := "1"

If cTipo = "1"
	oGrid	:= oModel:GetModel("GPEM040_MGET")
	For nG := 1 To oGrid:Length()
		oGrid:GoLine(nG)
		cVerba := oGrid:GetValue("RR_PD")
		nValor := oGrid:GetValue("RR_VALOR")

		If cVerba $ cPdRRA  .And. nValor > 0
			lRet := .T.
		Endif
	Next nG
else
	For nG := 1 To Len( aPDRRA )
		cVerba := aPDRRA[nG, 1]
		nValor := aPDRRA[nG, 5]

		If cVerba $ cPdRRA  .And. nValor > 0
			lRet := .T.
		Endif
	Next nG
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaIDCMPL
ObtÈm o Complemento Trabalhista
@author  Silvia Taguti
@since   14/03/2023
@version 0.1
/*/
//-------------------------------------------------------------------
Static Function fBuscaIDCMPL(cCompTrab,dDataRes,nMesRRA)

	Local aArea			:= GetArea()
	Local cAliasQry		:= GetNextAlias()
	Local cAliasQr1 	:= GetNextAlias()
	Local cMes			:= ""
	Local cAno			:= ""
	Local lRet			:= .F.

	Default	cCompTrab	:= ""
	Default nMesRRA     := 1
	Default dDataRes   	:= CTOD("//")

	cMes			:= StrZero( Month(dDataRes),2 )
	cAno			:= cValToChar( Year(dDataRes) )

	BeginSql Alias cAliasQry
		SELECT RHH_FILIAL, RHH_MAT,RHH_IDCMPL, RHH_MESANO, Count(RHH_DATA) MESES
		FROM %table:RHH% RHH
		WHERE 	RHH.RHH_FILIAL =	%exp:SRA->RA_FILIAL%
		AND 	RHH.RHH_MAT    =	%exp:SRA->RA_MAT   %
		AND 	RHH.RHH_MESANO =	%exp:cAno+cMes%
		AND  	RHH.RHH_COMPL_ = 'S'
		AND 	RHH.RHH_GRRA = '1'
		AND		RHH.RHH_RRA = '1'
		AND      RHH.%notDel%
		GROUP BY RHH_FILIAL, RHH_MAT,RHH_IDCMPL, RHH_MESANO
		ORDER BY RHH_FILIAL, RHH_MAT,RHH_IDCMPL, RHH_MESANO
	EndSql

	If !(cAliasQry)->(Eof())
		cCompTrab	:= (cAliasQry)->RHH_IDCMPL
		lRet 	:= .T.
	EndIf
	(cAliasQry)->(DbCloseArea())

	BeginSql Alias cAliasQr1
		SELECT DISTINCT RHH_DATA
		FROM %table:RHH% RHH
		WHERE 	RHH.RHH_FILIAL =	%exp:SRA->RA_FILIAL%
		AND 	RHH.RHH_MAT    =	%exp:SRA->RA_MAT   %
		AND 	RHH.RHH_MESANO =	%exp:cAno+cMes%
		AND  	RHH.RHH_COMPL_ = 'S'
		AND 	RHH.RHH_GRRA = '1'
		AND		RHH.RHH_RRA = '1'
		AND      RHH.%notDel%
	EndSql
	nMesRRA := 0
	While (cAliasQr1)->(!Eof())
		nMesRRA	+= 1
		(cAliasQr1)->(dbSkip())
	EndDo

	(cAliasQr1)->(DbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} fVerRJ5R()
FunÁ„o que verifica o relacionamento da tabela RJ5 e utiliza o centro de custo informado em RJ5_COD
A troca È efetuada manualmente pois cada centro de custo pode ter um relacionamento diferente, com
inÌcio de validade diferente, o que impossibilita o "Inner Join" na query dos lanÁamentos
@type function
@author raquel.andrade
@since 23/03/2023
@version 1.0
@param cSRRAlias	= Alias da tabela tempor·ria principal
@param cSRRRJ5		= Alias da tabela tempor·ria auxiliar
@param cPeriod		= PerÌodo para verificaÁ„o da validade
/*/
Static Function fVerRJ5R(cSRRAlias, cSRRRJ5, cPeriod)
	Local aColumns	 := {}
	Local cCCAnt	 := ""
	Local cCCRJ5	 := ""
	Local lNovo		 := .F.
	Local lRJ5FilT	 := RJ5->(ColumnPos("RJ5_FILT")) > 0
	Local lTemReg    := .F.

	aAdd( aColumns, { "RR_FILIAL"	,"C",FwGetTamFilial,0 })
	aAdd( aColumns, { "RR_MAT"		,"C",nTamMat,0})
	aAdd( aColumns, { "RR_CC"		,"C",nTamCC,0})
	aAdd( aColumns, { "RR_PD"		,"C",nTamVb,0})
	aAdd( aColumns, { "RR_HORAS"	,"N",nTamVal,nDecVal})
	aAdd( aColumns, { "RR_VALOR"	,"N",nTamHor,nDecHor})
	aAdd( aColumns, { "RR_DATA"		,"C",8,0})
	aAdd( aColumns, { "RR_ROTEIR"	,"C",nTamRot,0})
	aAdd( aColumns, { "RR_PERIODO"	,"C",6,0})
	aAdd( aColumns, { "RR_CCBKP"	,"C",nTamCC,0})
	aAdd( aColumns, { "RR_DATAPAG"	,"C",nTamDtPag,0})

	//Cria uma tabela tempor·ria auxiliar
	oTmpTabRR := FWTemporaryTable():New(cSRRRJ5)
	oTmpTabRR:SetFields( aColumns )
	oTmpTabRR:AddIndex( "IND", { "RR_FILIAL", "RR_MAT", "RR_DATA", "RR_CC", "RR_PD", "RR_PERIODO", "RR_ROTEIR" } )
	oTmpTabRR:Create()

	//Percorre o resultado da query da SRR e verifica o relacionamento na RJ5, efetuando troca do RR_CC por RJ5_COD
	//gravando o resultado na tabela tempor·ria auxiliar
	While (cSRRAlias)->(!Eof())
		lNovo	:= (cSRRRJ5)->( !dbSeek( (cSRRAlias)->RR_FILIAL+(cSRRAlias)->RR_MAT+(cSRRAlias)->RR_DATA+(cSRRAlias)->RR_CC+(cSRRAlias)->RR_PD+(cSRRAlias)->RR_PERIODO+(cSRRAlias)->RR_ROTEIR ) )
		lTemReg	:= .F.
		If RecLock(cSRRRJ5, lNovo)
			If lNovo
				(cSRRRJ5)->RR_FILIAL 	:= (cSRRAlias)->RR_FILIAL
				(cSRRRJ5)->RR_MAT 		:= (cSRRAlias)->RR_MAT
				(cSRRRJ5)->RR_DATA 		:= (cSRRAlias)->RR_DATA
				(cSRRRJ5)->RR_PERIODO	:= (cSRRAlias)->RR_PERIODO
				(cSRRRJ5)->RR_ROTEIR 	:= (cSRRAlias)->RR_ROTEIR

				If cCCAnt != (cSRRAlias)->RR_CC
					cCCAnt := (cSRRAlias)->RR_CC
					cCCRJ5 := ""
					//Se possui o campo RJ5_FILT pesquisa na RJ5 com este campo preenchido
					If lRJ5FilT
						RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cSRRAlias)->RR_FILIAL) + (cSRRAlias)->RR_CC + (cSRRAlias)->RR_FILIAL) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cSRRAlias)->RR_FILIAL) .And. RJ5->RJ5_CC == (cSRRAlias)->RR_CC .And. RJ5->RJ5_FILT == (cSRRAlias)->RR_FILIAL
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 	:= RJ5->RJ5_COD
									lTemReg	:= .T.
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
						//Se n„o encontrou registro refaz a pesquisa da forma antiga
						If !lTemReg
							RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
							RJ5->(dbGoTop())
							If RJ5->( dbSeek( xFilial("RJ5", (cSRRAlias)->RR_FILIAL) + (cSRRAlias)->RR_CC) )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cSRRAlias)->RR_FILIAL) .And. RJ5->RJ5_CC == (cSRRAlias)->RR_CC .And. EMPTY(RJ5->RJ5_FILT)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						EndIf
					Else
						RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cSRRAlias)->RR_FILIAL) + (cSRRAlias)->RR_CC) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cSRRAlias)->RR_FILIAL) .And. RJ5->RJ5_CC == (cSRRAlias)->RR_CC
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
					EndiF
				EndIf

				(cSRRRJ5)->RR_CC 	:= cCCRJ5
				(cSRRRJ5)->RR_PD	:= (cSRRAlias)->RR_PD
				(cSRRRJ5)->RR_CCBKP	:= cCCAnt
			EndIf
			(cSRRRJ5)->RR_VALOR	+= (cSRRAlias)->RR_VALOR
			(cSRRRJ5)->RR_HORAS	+= (cSRRAlias)->RR_HORAS

			(cSRRRJ5)->RR_DATAPAG 	:= (cSRRAlias)->RR_DATAPAG

			(cSRRRJ5)->(MsUnlock())
		EndIf
		(cSRRAlias)->(DbSkip())
	EndDo

	(cSRRAlias)->( dbCloseArea() )
	(cSRRRJ5)->( dbGoTop() )

	//Cria uma tabela tempor·ria com o mesmo alias da query da SRR
	oTmpTabRR2 := FWTemporaryTable():New(cSRRAlias)
	oTmpTabRR2:SetFields( aColumns )
	oTmpTabRR2:AddIndex( "IND", { "RR_FILIAL", "RR_MAT", "RR_DATA", "RR_CC", "RR_PD", "RR_PERIODO", "RR_ROTEIR" } )
	oTmpTabRR2:Create()

	//Percorre a tabela tempor·rio auxiliar gravando o resultado na tabela tempor·ria com o mesmo alias da query da SRD/SRC
	While (cSRRRJ5)->(!Eof())
		lNovo	:= (cSRRAlias)->(!MsSeek( (cSRRRJ5)->RR_FILIAL+(cSRRRJ5)->RR_MAT+(cSRRRJ5)->RR_DATA+(cSRRRJ5)->RR_CCBKP+(cSRRRJ5)->RR_PD+(cSRRRJ5)->RR_PERIODO+(cSRRRJ5)->RR_ROTEIR ) )
		If RecLock(cSRRAlias, lNovo)
			If lNovo
				(cSRRAlias)->RR_FILIAL 	:= (cSRRRJ5)->RR_FILIAL
				(cSRRAlias)->RR_MAT		:= (cSRRRJ5)->RR_MAT
				(cSRRAlias)->RR_DATA 	:= (cSRRRJ5)->RR_DATA
				(cSRRAlias)->RR_CC		:= (cSRRRJ5)->RR_CC
				(cSRRAlias)->RR_CCBKP	:= (cSRRRJ5)->RR_CCBKP
				(cSRRAlias)->RR_PD		:= (cSRRRJ5)->RR_PD
				(cSRRAlias)->RR_PERIODO	:= (cSRRRJ5)->RR_PERIODO
				(cSRRAlias)->RR_ROTEIR	:= (cSRRRJ5)->RR_ROTEIR

			EndIf
			(cSRRAlias)->RR_VALOR	+= (cSRRRJ5)->RR_VALOR
			(cSRRAlias)->RR_HORAS	+= (cSRRRJ5)->RR_HORAS

			(cSRRAlias)->RR_DATAPAG	:= (cSRRRJ5)->RR_DATAPAG

			(cSRRAlias)->(MsUnlock())
		EndIf
		(cSRRRJ5)->(DbSkip())
	EndDo

	(cSRRAlias)->( dbGoTop() )

Return


/*/{Protheus.doc} fFER2299
Crias as Tags no XML do Evento S-2299 com as verbas pagas no Roteiro FER
@author lidio.oliveira
@since 19/06/2023
@version 1.1
@Param cXml, Caracter, String com o XML que ser· enviado para o TAF - Deve ser passada por referÍncia
@param oModel, Object, Objeto com as informaÁıes da rescis„o
@Param aDadosCTT, Array, InformaÁıes dos estabelecimentos / lotaÁıes
@Param cIndSimp, Caracter, Indicador do Tipo de Simples Nacional.
/*/
Function fFER2299( cXml, oModel, aDadosCCT, cIndSimp, dDataRes, lRel, cPrefixo)

	Local aArea		:= GetArea()
	Local cIdTbRub	:= If(! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local cVersEnvio:= ""
	Local dLastDate	:= ""
	Local nPosCC	:= 0
	Local nPercRub	:= 0
	Local nY		:= 0
	Local nYOld		:= 0
	Local nZ		:= 0
	Local aDadosFer	:= {}
	Local lRVIncop	:= SRV->(ColumnPos("RV_INCOP")) > 0
	Local lRVTetop 	:= SRV->(ColumnPos("RV_TETOP")) > 0
	Local lRetIR	:= .F.
	Local lGrvIR68	:= .F.
	Local cLisVbCp      := "1870*1871*1872*1969"  //Verbas de contrapartida que n„o devem ser geradas, quando existe substituiÁ„o

	Default lRel	:= .F.
	Default cPrefixo:= ""

	fVersEsoc( "S2299",,,, @cVersEnvio )

	If lMiddleware
		cIdTbRub := fGetIdRJF( xFilial("SRV", SRA->RA_FILIAL), cIdTbRub )
	EndIf

	dDataRes	:= If(!Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATADEM"), dDataRes)

	//Busca as fÈrias do Funcion·rio no perÌodo
	aDadosFer := fGetFer(SRA->RA_FILIAL, SRA->RA_MAT, DTOS(firstday(dDataRes)), DTOS(lastday(dDataRes)))

	If Len(aDadosFer) > 0
		lVbContr	:= .F.
		For nY := 1 to len(aDadosFer)
			lGrvIR68 := .F. //Indica se gravou a verba de IR 68 para funcion·rios que possuem a deduÁ„o simplificada
			If lVbFerSub 
	       		If Ascan(aDadosFer[nY,6], {|X| X[13] <> ""}) > 0
   					lVbContr := .T.
				Endif
			Endif	
			For nZ := 1 to len(aDadosFer[nY, 6])
				If lVbContr .And. RetValSrv( aDadosFer[nY,6,nZ,3], SRA->RA_FILIAL, 'RV_CODFOL' ) $ cLisVbCp //"1870*1871*1872*1969" Verbas de contrapartida que n„o devem ser geradas, quando existe substituiÁ„o
					Loop
				Endif

				//Finaliza o bloco dmDev dentro do laÁo
				If nYOld != nY .And. nY > 1
					If SRA->RA_TPPREVI == "1"
						S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
					EndIf
					If !Empty(cIndSimp)
						cXml += "<infoSimples>"
							cXml += "<indSimples>" + cIndSimp + "</indSimples>"
						cXml += "</infoSimples>"
					EndIf
					cXml += "</ideEstabLot>"
					cXml += "</infoPerApur>"
					cXml += "</dmDev>"
				EndIf

				//Monta novo grupo dmDev encontrar um segundo c·lculo de fÈrias no perÌodo
				If nYOld != nY
					nYOld 		:= nY

					If Empty(cPrefixo)
						//cIdDmDev = FILIAL + MATRÕCULA + DATA DE PAGAMENTO + ROTEIRO + SEQUENCIAL (Gerado apenas se a data de pagamento for igual)
						cIdDmDev := SRA->RA_FILIAL + SRA->RA_MAT + aDadosFer[nY, 6, nZ, 8] + aDadosFer[nY, 6, nZ, 10] + If(nY > 1 .And. dLastDate == aDadosFer[nY, 6, nZ, 8], cvaltochar(nY), "")
						//Altera o ideDmDev se o tamanho for superior a 30
						If Len(cIdDmDev) > 30
						//cIdDmDev = FILIAL + DATA DE PAGAMENTO + PERIODO + ROTEIRO + SEQUENCIAL (Gerado apenas se a data de pagamento for igual)
							cIdDmDev := SRA->RA_FILIAL + aDadosFer[nY, 6, nZ, 8] + aDadosFer[nY, 6, nZ, 4] + "FER" + If(nY > 1 .And. dLastDate == aDadosFer[nY, 6, nZ, 8], cvaltochar(nY), "")
						EndIf
					Else
						//cIdDmDev = PREFIXO +   DATA DE PAGAMENTO     +     PERIODO             +          ROTEIRO         +     SEQUENCIAL (Gerado apenas se a data de pagamento for igual)
						cIdDmDev := cPrefixo + aDadosFer[nY, 6, nZ, 8] + aDadosFer[nY, 6, nZ, 4] + aDadosFer[nY, 6, nZ, 10] + If(nY > 1 .And. dLastDate == aDadosFer[nY, 6, nZ, 8], cvaltochar(nY), "")
					EndIf

					nPosCC 		:= Ascan( aDadosCCT, { |X| X[1] == aDadosFer[nY, 6, nZ, 2] })
					dLastDate	:= aDadosFer[nY, 6, nZ, 8]

					If aScan(aDtPgtDmDev, { |x| x[1]+x[2]+x[3]+x[4] == SRA->RA_FILIAL+SRA->RA_MAT+cIdDmDev+aDadosFer[nY, 6, nZ, 8] }) == 0
						aAdd(aDtPgtDmDev, { SRA->RA_FILIAL, SRA->RA_MAT, cIdDmDev, aDadosFer[nY, 6, nZ, 8] } )
					EndIf

					cXml += "<dmDev>"
					cXml += "<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
					cXml += "<infoPerApur>"
					cXml += "<ideEstabLot>"
					cXml += "<tpInsc>" + IIf(nPosCC > 0, aDadosCCT[nPosCC, 2], "") + "</tpInsc>"
					cXml += "<nrInsc>"+ IIf(nPosCC > 0, Alltrim(aDadosCCT[nPosCC,3]), "") + " </nrInsc>"
					cXml += "<codLotacao>" + IIf(nPosCC > 0, StrTran(aDadosCCT[nPosCC,4], "&", "&amp;"), "") + "</codLotacao>"
				EndIf

				PosSrv( aDadosFer[nY, 6, nZ, 3], SRA->RA_FILIAL )
				nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

				//Despreza verba de incidÍncia 68 para funcion·rios com c·lculo de IR no modelo completo
				If !aDadosFer[nY, 7] .And. Alltrim(SRV->RV_INCIRF) == "68"
					If lRel
						//Verba ### do IdeDmDev ############### desprezada devido incidÍncia IR 68 e n„o haver o c·lculo com deduÁ„o simplificada.
						aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, OemToAnsi(STR0395) + SRV->RV_COD + OemToAnsi(STR0407) + cIdDmDev + OemToAnsi(STR0408)})
					EndIf
					Loop
				ElseIf aDadosFer[nY, 7] .And. Alltrim(SRV->RV_INCIRF) == "68"
					lGrvIR68 := .T.
				EndIf

				cXml += "<detVerbas>"
				If lVbFerSub .And. !Empty(aDadosFer[nY, 6, nZ, 13])
					cXml += 	"<codRubr>" + aDadosFer[nY, 6, nZ, 13] + "</codRubr>"
				Else
					cXml += 	"<codRubr>" + aDadosFer[nY, 6, nZ, 3] + "</codRubr>"
				Endif	
				cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
				If !Empty(aDadosFer[nY, 6, nZ, 6])
					cXml += "<qtdRubr>" + Str(aDadosFer[nY, 6, nZ, 6]) + "</qtdRubr>"
				EndIf
				If !Empty(nPercRub)
					cXml += "<fatorRubr>" + Transform(nPercRub,"@E 999.99") + "</fatorRubr>"
				EndIf
				If !lMiddleware
					cXml += 	"<vrRubr>" + AllTrim( Transform(aDadosFer[nY, 6, nZ, 7], "@E 999999999.99") ) + "</vrRubr>"
				Else
					cXml += 	"<vrRubr>" + AllTrim( Str(aDadosFer[nY, 6, nZ, 7] )) + "</vrRubr>"
				EndIf
				If cValToChar( MesAno(M->RG_DATADEM) ) >= "202107"
					cXml +=         '<indApurIR>0</indApurIR>'
				Endif
				cXml += "</detVerbas>"
				If !lRel .And. lMiddleware
					lRetIR := (lVbRelIR .And. fVbRelIR(SRV->RV_NATUREZ, ALLTRIM(SRV->RV_INCIRF))) //Confirma que se trata de verba de IR
					If lRetIR
						fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nPosCC, 2], aDadosCCT[nPosCC, 3], aDadosCCT[nPosCC, 4], SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, aDadosFer[nY, 6, nZ, 7], "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""), cIdDmDev, STOD(aDadosFer[nY, 6, nZ, 8]), SRV->RV_COD, SRV->RV_CODFOL, anomes(STOD(aDadosFer[nY, 6, nZ, 8])),,lRetIR)
					EndIf
				EndIf
			Next nZ
			//Caso nas fÈrias haja uso do modelo de deduÁ„o simplificada e n„o tenha verba de IR 68 aviso o usu·rio no relatÛrio de InconsistÍncia
			If lRel .And. aDadosFer[nY, 7] .And. !lGrvIR68
				//O trabalhador possui c·lculo com deduÁ„o simplificada de IR no ideDmDev #######, mas n„o h· verba com a incidÍncia IR 68.
				//Caso necess·rio, verifique se as verbas de Id 1921, 1922, 1923 e 1924 est„o cadastradas corretamente com a incidÍncia IR 68.
				aAdd(aIncRel, {SRA->RA_FILIAL, SRA->RA_CIC, M->RG_DATADEM, M->RG_DTGERAR, M->RG_DATAHOM, OemToAnsi(STR0409) + cIdDmDev + OemToAnsi(STR0410) + OemToAnsi(STR0411)})
			EndIf
		Next nY

		//Finaliza o bloco dmDev apÛs o laÁo
		If nYOld != nY
			If SRA->RA_TPPREVI == "1"
				S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
			EndIf
			If !Empty(cIndSimp)
				cXml += "<infoSimples>"
					cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			cXml += "</infoPerApur>"
			cXml += "</dmDev>"
		EndIf
	EndIf

	RestArea(aArea)
Return


/*/{Protheus.doc} fGetFer
FunÁ„o respons·vel por pesquisar e gerar os dados de ferias das tabelas SRH e SRR para geracao do evento S-2299
@Author.....: Lidio Oliveira
@Since......: 19/06/2023
@Version....: 1.0
@Param......: (char) - cFilFun - Filial do funcionario para a pesquisa nas tabelas SRH e SRR
@Param......: (char) - cMatFun - Matricula do funcionario para a pesquisa
@Param......: (char) - cDtPesqI - PerÌodo inicial de pesquisa
@Param......: (char) - cDtPesqF - PerÌodo final de pesquisa
@Return.....: (array) - aFer - Array de retorno com os dados de ferias do funcionario
/*/
Static Function fGetFer( cFilFun, cMatFun, cDtPesqI, cDtPesqF)

Local cAliasSRH	:= "QSRHFERRES"
Local nNumReg	:= 0
Local aFer		:= {}
Local nPos		:= 0
Local lDedSimpl	:= .F.
Local lDtFerSub := .F.

If __oSt1 == Nil
	__oSt1 := FWPreparedStatement():New()
	cQrySt := "SELECT Count(*) AS NUMREG "
	cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
	cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
	cQrySt += 		"SRH.RH_MAT = ? AND "
	cQrySt += 		"SRH.RH_DTRECIB BETWEEN ? AND ? AND "
	cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
	cQrySt := ChangeQuery(cQrySt)
	__oSt1:SetQuery(cQrySt)
EndIf
__oSt1:SetString(1, cFilFun)
__oSt1:SetString(2, cMatFun)
__oSt1:SetString(3, cDtPesqI)
__oSt1:SetString(4, cDtPesqF)
cQrySt := __oSt1:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

nNumReg := (cAliasSRH)->NUMREG
( cAliasSRH )->( dbCloseArea() )

If nNumReg > 0
	If __oSt2 == Nil
		__oSt2 := FWPreparedStatement():New()
		cQrySt := "SELECT RH_FILIAL,RH_MAT,RH_PROCES,RH_PERIODO,RH_ROTEIR,RH_DTRECIB,RH_DFERIAS,RH_DATAINI,RH_DTRECIB "
		cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
		cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
		cQrySt += 		"SRH.RH_MAT = ? AND "
		cQrySt += 		"SRH.RH_DTRECIB BETWEEN ? AND ? AND "
		cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
		cQrySt := ChangeQuery(cQrySt)
		__oSt2:SetQuery(cQrySt)
	EndIf
	__oSt2:SetString(1, cFilFun)
	__oSt2:SetString(2, cMatFun)
	__oSt2:SetString(3, cDtPesqI)
	__oSt2:SetString(4, cDtPesqF)
	cQrySt := __oSt2:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

	DbSelectArea("SRR")
	DbSetOrder(RetOrder("SRR","RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC"))

	While (cAliasSRH)->(!Eof())

		aAdd( aFer, { cFilFun, cMatFun, SRA->RA_CIC, (cAliasSRH)->(RH_DATAINI), (cAliasSRH)->(RH_DTRECIB), {}, lDedSimpl} )
		//Verifica se a ConfiguraÁ„o de Verbas foi executada
		If !Empty(dDtInFer) .And. MesAno(dDtInFer) <= Substr((cAliasSRH)->(RH_DTRECIB),1,6)
			lDtFerSub := .T.
		Endif	

		If SRR->( DbSeek( (cAliasSRH)->RH_FILIAL + (cAliasSRH)->RH_MAT + "F" + (cAliasSRH)->(RH_DATAINI) ) )

			nPos := Len(aFer)

			While SRR->(!Eof() .and. RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA) == (cAliasSRH)->RH_FILIAL+(cAliasSRH)->RH_MAT+"F"+(cAliasSRH)->RH_DATAINI )

				//N„o inclui a verba de lÌquido no array de fÈrias.
				If RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_CODFOL' ) == "0102"
					SRR->(DbSkip())
					Loop
				EndIf

				//Identifica se houve uso do modelo simplificado do IR 2 - Simplificado e 1 - Completo
				If SRR->RR_TRIBIR == "2" .And. RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_CODFOL' ) $ "0010|0015|0016|0027|0100"
					lDedSimpl := .T.
				EndIf

				aAdd(aFer[nPos,6],{ SRR->RR_PERIODO, SRR->RR_CC, SRR->RR_PD, SRR->RR_PERIODO, SRR->RR_ROTEIR, SRR->RR_HORAS, SRR->RR_VALOR, dtos(SRR->RR_DATAPAG), 0, "FER", "01", SRR->RR_NUMID, If(lVbFerSub .And. lDtFerSub, SRR->RR_FERSUB,"") })

				SRR->(DbSkip())
			EndDo

			aFer[nPos,7] := lDedSimpl

		EndIf

		lDedSimpl := .F.

		(cAliasSRH)->(DbSkip())
	EndDo

	( cAliasSRH )->( dbCloseArea() )
EndIf

Return( aFer )

/*/{Protheus.doc} fPesqRHH()
FunÁ„o que verifica se encontrou c·lculo na tabela RHH
@type function
@author staguti
@since 16/11/2023
@version 1.0
@param cFilRHH		= CÛdigo da filial
@param cMatRHH		= CÛdigo da matrÌcula
@param cPerRHH		= PerÌodo de busca na RHH
@param cPerIni		= PerÌodo inicial de c·lculo do dissÌdio na RHH
@param cPerFim		= PerÌodo final de c·lculo do dissÌdio na RHH
@return lAchou		= Indica se encontrou c·lculo na RHH
/*/
Static Function fPesqRHH( cFilRHH, cMatRHH, cPerRHH, cPerIni, cPerFim )

Local aArea		:= GetArea()
Local lAchou	:= .F.
Local cRHHAlias	:= ""

DEFAULT cFilRHH	:= ""
DEFAULT cMatRHH	:= ""
DEFAULT cPerRHH	:= ""
DEFAULT cPerIni	:= ""
DEFAULT cPerFim	:= ""

lAchou 	:= RHH->( dbSeek( cFilRHH + cMatRHH + cPerRHH ) )

If lAchou
	cRHHAlias	:= GetNextAlias()
	cPerIni		:= RHH->RHH_DATA
	If __oSt3 == Nil
		__oSt3 := FWPreparedStatement():New()
		cQrySt := "SELECT RHH.RHH_DATA "
		cQrySt += "FROM " + RetSqlName('RHH') + " RHH "
		cQrySt += "WHERE RHH.RHH_FILIAL = ? AND "
		cQrySt += 		"RHH.RHH_MAT = ? AND "
		cQrySt += 		"RHH.RHH_MESANO = ? AND "
		cQrySt += 		"RHH.RHH_VB = '000' AND "
		cQrySt += 		"RHH.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY RHH_DATA "
		cQrySt += "ORDER BY 1"
		cQrySt := ChangeQuery(cQrySt)
		__oSt3:SetQuery(cQrySt)
	EndIf
	__oSt3:SetString(1, cFilRHH)
	__oSt3:SetString(2, cMatRHH)
	__oSt3:SetString(3, cPerRHH)
	cQrySt := __oSt3:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cRHHAlias,.T.,.T.)
	While (cRHHAlias)->( !EoF() )
		cPerFim		:= (cRHHAlias)->RHH_DATA
		(cRHHAlias)->( dbSkip() )
	EndDo
	(cRHHAlias)->( dbCloseArea() )
EndIf

RestArea(aArea)
Return lAchou

/*/{Protheus.doc} fGetCGC()
Retorno o CGC do filial informada
@author lidio.oliveira
@since 16/04/2024
@Param......: (char) - cCodEmp - CÛdigo do Grupo de Empresa
@Param......: (char) - cCodFil - CÛdigo da Filial
@Param......: (logical) - lRaiz - Indica de deve retonar somente a Raiz
@Return.....: (char) - cCGC - Retorna o valor do campo M0_CGC
/*/
Static Function fGetCGC(cCodEmp, cCodFil, lRaiz)

	Local cCGC		:= ""
	Local nPos		:= 0

	Default cCodEmp	:= ""
	Default cCodFil := ""
	Default lRaiz 	:= .T.

	//Pesquisa o CGC conforme o grupo e filial
	//aSM0 est· declara no inicio do programa como Private
	If Len(aSM0) > 0
		nPos := aScan( aSM0, { |x| x[1] == cCodEmp .And. x[2] == cCodFil} )
		If nPos > 0
			cCGC := aSM0[nPos][18]
			If lRaiz
				cCGC := SubStr(cCGC, 1, 8)
			EndIf
		EndIf
	EndIf

Return cCGC

/*/{Protheus.doc} fBusEConsR
FunÁ„o respons·vel por buscar InformaÁıes eConsignado
@author  Silvia Taguti
@since   20/08/24
@version 1
/*/

Static Function fBusEConsR(cFilSRK, cMatSRK, cVerbSRK, cLotSRK, cPerSRK )

Local aArea		:= GetArea()
Local aEConsig  := {}
Local lRKObs	:= SRK->(ColumnPos("RK_OBSECON"))> 0
Local cObsEcon  := ""
Local lChkEConsig := cPaisLoc == "BRA" .And. ChkFile("RUO")
Local cCompet :=     "" 

Default cFilSRK 	:= ""
Default cMatSRK 	:= ""
Default cVerbSRK	:= ""
Default cLotSRK	:= ""
Default cPerSRK     := ""

	SRK->( dbSetOrder(1) )
	If SRK->( dbSeek( cFilSRK + cMatSRK + cVerbSRK ) )
		While SRK->( !EoF() .And. SRK->RK_FILIAL+SRK->RK_MAT + SRK->RK_PD == cFilSRK + cMatSRK+ cVerbSRK )
			If SRK->RK_STATUS == '2' .And. cLotSRK == SRK->RK_CC
				cObsEcon := If(lRKObs,SRK->RK_OBSECON,"")
				aAdd( aEConsig, { cFilSRK, cMatSRK, cVerbSRK, cLotSRK, SRK->RK_BCOCONS,SRK->RK_NRCONTR, cObsEcon  } )
			EndIf
			SRK->( dbSkip() )
		EndDo
	EndIf

If 	lChkEConsig .And. Len(aEConsig) == 0
	cCompet := SubStr(cPerSRK,5,2)+SubStr(cPerSRK,1,4)
	RUO->(DbSetOrder(4))
	If RUO->( dbSeek( cFilSRK + cMatSRK + cVerbSRK ) )
		While RUO->( !EoF() .And. RUO->RUO_FILIAL+RUO->RUO_MAT + RUO->RUO_PD == cFilSRK + cMatSRK+ cVerbSRK )
			If cCompet == RUO->RUO_COMPET
				cObsEcon := If(lRKObs,SRK->RK_OBSECON,"")
				aAdd( aEConsig, { cFilSRK, cMatSRK, cVerbSRK, cLotSRK, RUO->RUO_BCOCON, RUO->RUO_NRCONT, cObsEcon  } )
			Endif	
			RUO->(dbSkip())
		EndDo
	EndIf
Endif

RestArea(aArea)

Return aEConsig

/*/{Protheus.doc} fRetifAnt
Verifica se rescisıes anteriores s„o retificaÁıes
@author isabel.noguti
@since 20/02/2025
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
/*/
Static Function fRetifAnt(cFilSRR, cMatSRR, cDtGer)
	Local aArea		:= GetArea()
	Local aAreaSRG	:= SRG->( GetArea() )
	Local lRet		:= .F.

	Default cFilSRR	:= SRA->RA_FILIAL
	Default cMatSRR	:= SRA->RA_MAT
	Default cDtGer	:= ""

	SRG->( dbSetOrder(1) ) //RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
	If SRG->( dbSeek( cFilSRR + cMatSRR + cDtGer ))
		lRet := SRG->RG_RESCDIS == "3"
	EndIf

	RestArea(aAreaSRG)
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} fUltNrPag
Verifica qual a ˙ltima semana de um roteiro que foi fechado
@author lidio.oliveira
@since 24/05/2025
@Param......: (char) - cProces - CÛdigo do Processo
@Param......: (char) - cPeriodo - CÛdigo do PerÌodo
@Param......: (char) - cRoteiro - CÛdigo do Roteiro
@Return.....: (numeric) - nNrPagto - Retorna a quantidade de pagamentos fechados
/*/
Static Function fQtdNrPag(cProces, cPeriodo, cRoteiro)

	Local aArea			:= GetArea()
	Local aAreaRCH		:= RCH->( GetArea() )
	Local nNrPagto		:= Val(M->RG_SEMANA)

	Default cProces		:= ""
	Default cPeriodo	:= ""
	Default cRoteiro	:= ""

	RCH->( dbsetOrder( 4 ) ) //RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG
	If RCH->( dbSeek( xFilial("RCH") + cProces + cRoteiro + cPeriodo ) )
		While RCH->RCH_FILIAL+RCH->RCH_PROCES+RCH->RCH_ROTEIR+RCH->RCH_PER == xFilial("RCH") + cProces + cRoteiro + cPeriodo
			If !Empty(RCH->RCH_DTFECH)
				nNrPagto := Val(RCH->RCH_NUMPAG)
			EndIf
			RCH->( dbSkip() )
		EndDo
	EndIf

	RestArea(aAreaRCH)
	RestArea(aArea)

Return nNrPagto

/*/{Protheus.doc} fValNATINCC
Verifica se a Natureza permite a Incidencia INSS 15/16
@author staguti
@since 28/08/2025
/*/
Function fValNATINCC(cNatVerba)

Local lRet 			:= .T.
Default cNatVerba   := ""

	DbSelectArea("RCC")
	DbSetOrder(1)
	dbSeek(xFilial("RCC") + "S047")
	While RCC->(!EOF()) .AND. xFilial('RCC') + "S047" == RCC->RCC_FILIAL+RCC->RCC_CODIGO
		If AllTrim(Substr(RCC->RCC_CONTEU,1,4)) == cNatVerba
			If AllTrim(Substr(RCC->RCC_CONTEU,221,1)) == "N"
				lRet:= .F.
				Exit
			Endif
		EndIf
		RCC->(DbSkip())
	EndDo

Return lRet
