#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURIRM.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JiRmInTiPg()
Prepara as informações para integrar\cancelar o titulo a pagar com o RM.
A partir de informações do SE2

@param	 nOper 	 	- Tipo da operação executada
@param	 aCabSE2 	- Dados do Titulo
@return  cChaveRm 	- id do lançamento incluído no RM

@author	 Rafael Tenorio da Costa
@since 	 05/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JiRmInTiPg(nOper, aCabSE2)

Local aEmpRm	:= {}
Local cXml		:= ""
Local cChaveRm 	:= ""
Local nPosPref	:= Ascan(aCabSE2, {|x| x[1] == "E2_PREFIXO"	})
Local nPosNum	:= Ascan(aCabSE2, {|x| x[1] == "E2_NUM"		})
Local nPosForn	:= Ascan(aCabSE2, {|x| x[1] == "E2_FORNECE"	})
Local nPosLoja	:= Ascan(aCabSE2, {|x| x[1] == "E2_LOJA"	})
Local nPosParc	:= Ascan(aCabSE2, {|x| x[1] == "E2_PARCELA"	})
Local nPosEmis	:= Ascan(aCabSE2, {|x| x[1] == "E2_EMISSAO"	})
Local nPosVenc	:= Ascan(aCabSE2, {|x| x[1] == "E2_VENCREA"	})
Local nPosVal	:= Ascan(aCabSE2, {|x| x[1] == "E2_VALOR"	})
Local nPosMoe	:= Ascan(aCabSE2, {|x| x[1] == "E2_MOEDA"	})
Local nPosHist	:= Ascan(aCabSE2, {|x| x[1] == "E2_HIST"	})
Local nPosNat	:= Ascan(aCabSE2, {|x| x[1] == "E2_NATUREZ"	})
Local nPosTipo	:= Ascan(aCabSE2, {|x| x[1] == "E2_TIPO"	})
Local nPosCCusto:= Ascan(aCabSE2, {|x| x[1] == "E2_CCUSTO"	})
Local nPosIdMov := Ascan(aCabSE2, {|x| x[1] == "E2_IDMOV"	})
Local cValInt 	:= ""
Local cMoeda	:= ""
Local cFornec 	:= ""
Local cCCusto	:= ""
Local cNaturez 	:= ""
Local cIdLan	:= "-1"
Local cErro		:= ""
Local cCmpOpc	:= ""
Local xCmpOpc   := NIL
Local cTagPai   := ""
Local lPtoOld   := .F. // Indica se o retorno do pto de entrada é string, se for, é o retorno antigo
Local cXmlTag   := ""
Local lAddCmpOpc:= .F.

	//Pega dados da empresa RM		\\XXD_REFER+XXD_EMPPRO+XXD_FILPRO
	aEmpRm := FWEAIEMPFIL( cEmpAnt, cFilAnt, 'RM', .T.)

	If Len(aEmpRm) > 0 .And. !Empty(aEmpRm[1])

		//Carrega Id do lançamento do RM para alteração\exclusão
		If nOper <> MODEL_OPERATION_INSERT
			cIdLan :=  AllTrim(aCabSE2[nPosIdMov][2])
		EndIf

		If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE

			//Busca codigo da moeda RM no de\para do EAI
			cMoeda 	:= StrZero(aCabSE2[nPosMoe][2], TamSx3("CTO_MOEDA")[1])
			cValInt := IntMoeExt(/*cEmpresa*/, /*cFilial*/, cMoeda, /*cVersao*/)[2]
			cMoeda  := CFGA070Ext("RM", "CTO", "CTO_MOEDA", cValInt)
			cMoeda	:= JurEncUTF8(cMoeda)

			If Empty(cMoeda)
				cErro += I18n(STR0001, {STR0002}) + CRLF	//"Não foi encontrado o de\para de #1"		//"Moeda"
			EndIf

			//Busca codigo do forncedor RM no de\para do EAI
			cValInt := IntForExt(/*cEmpresa*/, /*cFilial*/, aCabSE2[nPosForn][2], aCabSE2[nPosLoja][2], /*cVersao*/)[2]
			cFornec := CFGA070Ext("RM", "SA2", "A2_COD", cValInt)

			If Empty(cFornec)
				cErro += I18n(STR0001, {STR0003}) + CRLF	//"Não foi encontrado o de\para de #1"		//"Fornecedor"
			EndIf

			//Busca codigo do centro de custo RM no de\para do EAI
			cValInt := IntCusExt(/*cEmpresa*/, /*cFilial*/, aCabSE2[nPosCCusto][2], /*cVersao*/)[2]
			cCCusto := CFGA070Ext("RM", "CTT", "CTT_CUSTO", cValInt)

			If Empty(cCCusto)
				cErro += I18n(STR0001, {STR0004}) + CRLF	//"Não foi encontrado o de\para de #1"		//"Centro de Custo"
			EndIf

			//Busca codigo da natureza RM no de\para do EAI
			cValInt := F10MontInt(xFilial("SED"), aCabSE2[nPosNat][2])
			cNaturez:= CFGA070Ext("RM", "SED", "ED_CODIGO", cValInt)

			If Empty(cNaturez)
				cErro += I18n(STR0001, {STR0005}) + CRLF	//"Não foi encontrado o de\para de #1"		//"Natureza"
			EndIf

			If Empty(cErro)

				cXml := "<![CDATA["
				cXml +=     "<FinLAN>"

				//Informações do titulo
				cXmlTag +=     "<FLAN>"
				cXmlTag +=         "<CODCOLIGADA>"         + TrataCmp(aEmpRm[1])               + "</CODCOLIGADA>"         //Coligada(empresa)
				cXmlTag +=         "<PAGREC>2</PAGREC>"                                                                   //2=Conta a pagar
				cXmlTag +=         "<IDLAN>"               + cIdLan                            + "</IDLAN>"	              //Id do lançamento do RM, irá gerar automaticamente quando = -1
				cXmlTag +=         "<CODFILIAL>"           + TrataCmp(aEmpRm[2])               + "</CODFILIAL>"           //Filial
				cXmlTag +=         "<SERIEDOCUMENTO>"      + aCabSE2[nPosPref][2]              + "</SERIEDOCUMENTO>"      //Serie
				cXmlTag +=         "<NUMERODOCUMENTO>"     + aCabSE2[nPosNum][2]               + "</NUMERODOCUMENTO>"     //Numero do documento
				cXmlTag +=         "<PARCELA>"             + TrataCmp(aCabSE2[nPosParc][2])    + "</PARCELA>"             //Parcela
				cXmlTag +=         "<CODCOLCFO>"           + TrataCmp(Separa(cFornec, "|")[1]) + "</CODCOLCFO>"           //Coligada(empresa) do fornecedor
				cXmlTag +=         "<CODCFO>"              + TrataCmp(Separa(cFornec, "|")[2]) + "</CODCFO>"              //Fornecedor
				cXmlTag +=         "<DATAEMISSAO>"         + TrataCmp(aCabSE2[nPosEmis][2])    + "</DATAEMISSAO>"         //Emissão
				cXmlTag +=         "<DATAVENCIMENTO>"      + TrataCmp(aCabSE2[nPosVenc][2])    + "</DATAVENCIMENTO>"      //Vencimento
				cXmlTag +=         "<CODMOEVALORORIGINAL>" + TrataCmp(cMoeda)                  + "</CODMOEVALORORIGINAL>" //Simbolo da moeda
				cXmlTag +=         "<VALORORIGINAL>"       + TrataCmp(aCabSE2[nPosVal][2])     + "</VALORORIGINAL>"       //Valor
				cXmlTag +=         "<CODTDO>"              + TrataCmp(aCabSE2[nPosTipo][2])    + "</CODTDO>"              //Tipo do titulo

				If !Empty(cCCusto)
					cXmlTag +=         "<CODCOLCCUSTO>" + TrataCmp(Separa(cCCusto, "|")[1]) + "</CODCOLCCUSTO>" //Coligada(empresa) Centro de custo
					cXmlTag +=         "<CODCCUSTO>"    + TrataCmp(Separa(cCCusto, "|")[2]) + "</CODCCUSTO>"    //Centro de custo
				EndIf

				cXmlTag +=         "<TIPOCONTABILLAN>3</TIPOCONTABILLAN>"                          //0=Não Contábil; 1=Contábil; 2=Baixa Contábil; 3=A Contabilizar; 6=Contábil Baixa a Contabilizar; 7=Baixa a contabilizar
				cXmlTag +=         "<HISTORICO>" + TrataCmp(aCabSE2[nPosHist][2]) + "</HISTORICO>" //Historico
				cXmlTag +=         "<CODCOLCXA>0</CODCOLCXA>"                                      //Coligada(empresa) do caixa

				//Campos Opcionais
				//Ponto de entrada para inserir campos opcionais ao XML enviado ao RM dentro da entidade FLAN
				If ExistBlock("JRMCOXML")
					cTagPai := "<FLAN>"
					xCmpOpc := Execblock("JRMCOXML", .F., .F., {aCabSE2, cTagPai})

					If ValType(xCmpOpc) == "A" .And. Len(xCmpOpc) > 0
						If cTagPai == xCmpOpc[1]
							cCmpOpc := xCmpOpc[2]
							// Trata os campos do ponto de entrada, dentro da tag pai
							TrataTagFLAN(@cCmpOpc, @cXmlTag)
							// Adiciona os campos tratados no XML
							cXml += cXmlTag
							cXml += cCmpOpc
							lPtoOld := .F.
							// Limpa variaveis
							cCmpOpc := ""
							cXmlTag := ""
							lAddCmpOpc:= .T.
						EndIf
					ElseIf ValType(xCmpOpc) == "C" .And. !Empty(xCmpOpc)
						cCmpOpc := xCmpOpc
						// Trata os campos do ponto de entrada, dentro da tag pai
						TrataTagFLAN(@cCmpOpc, @cXmlTag)
						// Adiciona os campos tratados no XML
						cXml += cXmlTag
						cXml += cCmpOpc
						lPtoOld := .T.
						// Limpa variaveis
						cXmlTag := ""
						lAddCmpOpc:= .T.
					EndIf
				EndIf

				If !lAddCmpOpc
					// Adiciona o conteúdo da tag no XML
					cXml += cXmlTag
					cXmlTag := ""
				EndIf

				cXml +=     "</FLAN>"

				//Rateio por centro de custo
				cXmlTag +=     "<FLANRATCCU>"
				cXmlTag +=         "<IDRATCCU>-1</IDRATCCU>"                                //Codido do lançamento do rateio
				cXmlTag +=         "<CODCOLIGADA>" + TrataCmp(aEmpRm[1]) + "</CODCOLIGADA>" //Coligada(empresa)
				cXmlTag +=         "<IDLAN>-1</IDLAN>"                                      //Id do lançamento do RM, irá pegar do acima

				If !Empty(cCCusto)
					cXmlTag +=         "<CODCCUSTO>" + TrataCmp(Separa(cCCusto, "|")[2]) + "</CODCCUSTO>" //Centro de custo
				EndIf

				cXmlTag +=         "<VALOR>" + TrataCmp(aCabSE2[nPosVal][2]) + "</VALOR>"   //Valor

				If !Empty(cNaturez)
					cXmlTag +=         "<CODCOLNATFINANCEIRA>" + TrataCmp(Separa(cNaturez, "|")[1]) + "</CODCOLNATFINANCEIRA>" //Coligada(empresa Natureza Financeira
					cXmlTag +=         "<CODNATFINANCEIRA>"    + TrataCmp(Separa(cNaturez, "|")[2]) + "</CODNATFINANCEIRA>"    //Natureza Financeira
				EndIf

				lAddCmpOpc:= .F.
				// Se for a nova versão do ponto de parada (retorna array)
				If !lPtoOld .And. ExistBlock("JRMCOXML")
					cTagPai := "<FLANRATCCU>"
					xCmpOpc := Execblock("JRMCOXML", .F., .F., {aCabSE2, cTagPai})

					If ValType(xCmpOpc) == "A" .And. Len(xCmpOpc) > 0
						If cTagPai == xCmpOpc[1]
							cCmpOpc := xCmpOpc[2]
							// Trata os campos do ponto de entrada, dentro da tag pai
							TrataTagFLAN(@cCmpOpc, @cXmlTag)
							// Adiciona os campos tratados no XML
							cXml += cXmlTag
							cXml += cCmpOpc
							// Limpa variaveis
							cCmpOpc := ""
							cXmlTag := ""
							lAddCmpOpc:= .T.
						EndIf
					EndIf
				EndIf

				If !lAddCmpOpc
					// Adiciona o conteúdo da tag no XML
					cXml += cXmlTag
					cXmlTag := ""
				EndIf

				cXml +=     "</FLANRATCCU>"

				// Se for a nova versão do ponto de parada (retorna array)
				If !lPtoOld .And. ExistBlock("JRMCOXML")
					cTagPai := "<FinLAN>"
					xCmpOpc := Execblock("JRMCOXML", .F., .F., {aCabSE2, cTagPai})

					If !lPtoOld .And. ValType(xCmpOpc) == "A" .And. Len(xCmpOpc) > 0
						If cTagPai == xCmpOpc[1]
							// Adiciona a nova tag no XML
							cXml += xCmpOpc[2]
							cCmpOpc := ""
						EndIf
					EndIf
				EndIf


				cXml +=     "</FinLAN>"
				cXml += "]]>"
				//Envia o titulo para o RM
				cChaveRm := JiRmSaveRe("FinLanDataTBC", cXml)
			EndIf

		Else

			cXml := "<![CDATA["
			cXml +=     "<FinLanCancelamentoParamsProc>"
			cXml +=         "<CodColigada>"      + TrataCmp(aEmpRm[1])                              + "</CodColigada>"
			cXml +=         "<DataCancelamento>" + TrataCmp(dDataBase)                              + "</DataCancelamento>"
			cXml +=         "<Historico>"        + TrataCmp(aCabSE2[nPosHist][2]) + " - " + STR0016 + "</Historico>" //"CANCELADO"
			cXml +=         "<ListaDeLancamentos>"
			cXml +=             "<int>"          + SubStr(cIdLan, At(";", cIdLan)+ 1)               + "</int>"
			cXml +=         "</ListaDeLancamentos>"
			cXml +=     "</FinLanCancelamentoParamsProc>"
			cXml += "]]>"
			//Cancela o titulo para o RM
			JiRmExWiPa("FinLanCancelamentoData", cXml)
		EndIf

	Else

		cErro := STR0006	//"Não foi encontrada a empresa RM no de\para de Empresas"
	EndIf

	If !Empty(cErro)
		MsgAlert(STR0007 + CRLF + cErro, STR0008)	//"Não será possível gerar o tÍtulo a pagar no RM."		//"Integração com RM"
	EndIf

Return cChaveRm

//-------------------------------------------------------------------
/*/{Protheus.doc} JiRmBxTiPg()
Consulta o status do titulo a pagar no RM e atualiza o titulo a pagar(SE2) no Protheus.

@param	 cIdMov	 	- Código do lançamento no RM - (SE2_IDMOV)
@param	 nRecnoSE2 	- Recno SE2 que será atualizado
@return

@author	 Rafael Tenorio da Costa
@since 	 14/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JiRmBxTiPg(cIdMov, nRecnoSE2)

	Local aArea		:= GetArea()
	Local aAreaSE2	:= SE2->( GetArea() )
	Local oTituloRM := JiRmReadRe("FinLanDataTBC", "<FLAN>", cIdMov)	//Retorna informações do titulo
	Local nValorBx  := 0
	Local cDataBx	:= ""

	//Atualiza titulo para baixado
	If oTituloRM <> Nil

		DbSelectArea("SE2")
		SE2->( DbGoTo(nRecnoSE2) )
		If !SE2->( Eof() )

			If XmlChildEx(oTituloRM, "_VALORBAIXADO") <> Nil
				nValorBx := Val(oTituloRM:_VALORBAIXADO:TEXT)
			EndIf

			If XmlChildEx(oTituloRM, "_DATABAIXA") <> Nil
				cDataBx := SubStr( StrTran(oTituloRM:_DATABAIXA:TEXT, "-", ""), 1, 8 )
			EndIf

			RecLock("SE2", .F.)
				SE2->E2_SALDO := IIF(nValorBx > 0, SE2->E2_VALOR - nValorBx, SE2->E2_VALOR)
				SE2->E2_BAIXA := StoD(cDataBx)
			SE2->( MsUnLock() )
		EndIf
	EndIf

	FreeObj(oTituloRM)

	RestArea(aAreaSE2)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JiRmReadRe()
Executa o metodo ReadRecord do serviço wsDataServer.
Retorn informações do DataServer consultado.

@param	cDtSrvName 	- Nome do DataServer que será consultado
@param	cChaveRm	- Chave unica que será consultada

@return	oXml 		- Objeto xml com o retorno

@author  Rafael Tenorio da Costa
@since 	 02/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JiRmReadRe(cDtSrvName, cTagRet, cChaveRm)

	Local oWsdl		:= Nil
 	Local xRet		:= Nil
	Local cErro		:= ""
	Local cAviso	:= ""
	Local aSimple	:= {}
	Local nPos		:= 0
	Local cMsg		:= ""
	Local oXmlOri	:= Nil
	Local oXml		:= Nil
	Local cTagIni	:= cTagRet
	Local cTagFim	:= StrTran(cTagRet, "<", "</")

	cTagRet := StrTran(cTagRet, "<", "_")
	cTagRet := StrTran(cTagRet, ">", "" )

	//Cria e conecta no Wsdl
	cErro := ConectaRM(@oWsdl, "/wsDataServer/mex?WSDL","ReadRecord",@xRet)

	If Empty(cErro)

		//Define a operação
	  //	xRet := oWsdl:SetOperation("ReadRecord")
	  	If xRet
			aSimple := oWsdl:SimpleInput()
		Else
	    	cErro := I18n(STR0009, {STR0012}) + oWsdl:cError //"Erro ao definir #1 " //"metodo: "
		EndIf

		If Empty(cErro) .And. ( nPos := aScan(aSimple, {|x| x[2] == "DataServerName"}) ) > 0
		  	xRet := oWsdl:SetValue( aSimple[nPos][1], cDtSrvName ) //Ex: "FinLanDataTBC"
		  	If !xRet
		    	cErro := I18n(STR0009, {"tag DataServerName: "}) + oWsdl:cError //"Erro ao definir #1 "
		  	EndIf
		EndIf

		If Empty(cErro) .And. ( nPos := aScan(aSimple, {|x| x[2] == "PrimaryKey"}) ) > 0
			xRet := oWsdl:SetValue( aSimple[nPos][1], cChaveRm ) //Ex: "1;6947"
			If !xRet
				cErro := I18n(STR0009, {"tag PrimaryKey: "}) + oWsdl:cError //"Erro ao definir #1 "
			EndIf
		EndIf

		nPos := aScan( aSimple, {|x| x[2] == "Contexto" } )
		xRet := oWsdl:SetValue( aSimple[nPos][1], " ") //Ex: "CODCOLIGADA=1;CODUSUARIO=guilherme;CODSISTEMA=F"
		If !xRet
			cErro := I18n(STR0009, {"tag Contexto: "}) + oWsdl:cError //"Erro ao definir #1 "
		EndIf

		If Empty(cErro)

			//Pega a mensagem que sera enviada para Web Service
			cMsg := oWsdl:GetSoapMsg()

			//Envia a mensagem SOAP ao servidor
			xRet := oWsdl:SendSoapMsg(cMsg)

			If xRet
				//Pega a mensagem de resposta
				xRet := oWsdl:GetSoapResponse()

				//Obtem somente Result Tag do XML de retorno
				xRet := SubStr(xRet, At("<ReadRecordResult>" , xRet), Len(xRet))
				xRet := Left(xRet  , At("</ReadRecordResult>", xRet) + 18)

				//Pega o retorno da <ReadRecordResult>
				oXmlOri := XmlParser(xRet, "_", @cErro, @cAviso)

				If oXmlOri <> Nil .And. XmlChildEx(oXmlOri, "_READRECORDRESULT") <> Nil

					//Obtem retorno do xml como string
					xRet := oXmlOri:_READRECORDRESULT:TEXT
					FreeObj(oXmlOri)

					//Obtem somente Result Tag do XML de retorno
					xRet := SubStr(xRet, At(cTagIni, xRet), Len(xRet)) //Ex: "<FLAN>"
					xRet := Left(xRet  , At(cTagFim,xRet) + 6) //Ex: "</FLAN>"

					//Pega o retorno do <FinLAN> Titulo
					oXmlOri := XmlParser(xRet, "_", @cErro, @cAviso)

					//Pega apenas os dados do titulo no RM
					oXml 	:= XmlChildEx(oXmlOri, cTagRet) //Ex: "_FLAN"
				Else

					cErro := I18n(STR0010, {AllTrim(cErro), AllTrim(oWsdl:cError), AllTrim(cAviso)}) //"Erro ao receber retorno do XML: #1 \ #2 \ #3"
				EndIf

			Else
				cErro := STR0011 + CRLF + oWsdl:cError //"Erro ao enviar mensagem: "
			EndIf
		EndIf

	EndIf

	If !Empty(cErro)
		cErro := AllTrim( DecodeUTF8(cErro) )
		MsgAlert(cErro, STR0008) //"Integração com RM"
		FreeObj(oXml)
		oXml := Nil
	Endif

	FreeObj(oXmlOri)

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} JiRmSaveRe()
Executa o metodo SaveRecord do serviço wsDataServer.
Insere informações no DataServer informado.

@param	cDtSrvName 	- Nome do DataServer que será utilizado
@param	cXml 		- Xml no com dados do registro que será inserido

@return	cChaveRm	- Chave do registro que foi gerado no RM

@author  Rafael Tenorio da Costa
@since 	 02/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JiRmSaveRe(cDtSrvName, cXml)

Local oWsdl     := Nil
Local xRet      := Nil
Local cErro     := ""
Local cAviso    := ""
Local aSimple   := {}
Local nPos      := 0
Local cMsg      := ""
Local oXml      := Nil
Local cChaveRm	:= ""

	//Cria e conecta no Wsdl
	cErro := ConectaRM(@oWsdl, "/wsDataServer/mex?WSDL","SaveRecord",@xRet)

	If Empty(cErro)

		//Define a operação
		If xRet
			aSimple := oWsdl:SimpleInput()
		Else
			cErro := I18n(STR0009, {STR0012}) + oWsdl:cError		//"Erro ao definir #1 "		//"método: "
		EndIf
		If Empty(cErro) .And. ( nPos := aScan(aSimple, {|x| x[2] == "DataServerName"}) ) > 0
			xRet := oWsdl:SetValue( aSimple[nPos][1], cDtSrvName )	//Ex: "FinLanDataTBC"
			If !xRet
				cErro := I18n(STR0009, {"tag DataServerName: "}) + oWsdl:cError		//"Erro ao definir #1 "
			EndIf
		EndIf
		If Empty(cErro) .And. ( nPos := aScan(aSimple, {|x| x[2] == "XML"}) ) > 0
			xRet := oWsdl:SetValue( aSimple[nPos][1], cXml )
			If !xRet
				cErro := I18n(STR0009, {"tag XML: "}) + oWsdl:cError		//"Erro ao definir #1 "
			EndIf
		EndIf
		nPos := aScan( aSimple, {|x| x[2] == "Contexto" } )
		xRet := oWsdl:SetValue( aSimple[nPos][1], " ")				//Ex: "CODCOLIGADA=1;CODUSUARIO=guilherme;CODSISTEMA=F"
		If !xRet
			cErro := I18n(STR0009, {"tag Contexto: "}) + oWsdl:cError		//"Erro ao definir #1 "
		EndIf
		If Empty(cErro)

			//Pega a mensagem que sera enviada para Web Service
			cMsg := oWsdl:GetSoapMsg()

			If GetSrvProfString( "Trace", "0" ) == "1" //Grava XML de envio no Log
				JurConOut("Envio RM:" + cMsg)
			EndIf

			//Envia a mensagem SOAP ao servidor
			xRet := oWsdl:SendSoapMsg(cMsg)

			If xRet
				//Pega a mensagem de resposta
				xRet := oWsdl:GetSoapResponse()

				If GetSrvProfString( "Trace", "0" ) == "1" //Grava XML de retorno no Log
					JurConOut("Recebimento RM:" + xRet)
				EndIf

				If At("<SaveRecordResult>"  , xRet) > 0 //validar no else a exception que o RM manda que não esta no formato esperado.
					//Obtem somente Result Tag do XML de retorno
					xRet := SubStr(xRet, At("<SaveRecordResult>"  , xRet), Len(xRet))
					xRet := Left(xRet  , At("</SaveRecordResult>" , xRet) + 18)

					//Pega o retorno da <SaveRecordResult>
					oXml := XmlParser(xRet, "_", @cErro, @cAviso)

					If oXml <> Nil .And. XmlChildEx(oXml, "_SAVERECORDRESULT") <> Nil

						//Obtem retorno do xml como string
						xRet := AllTrim(oXml:_SAVERECORDRESULT:TEXT)
						If Len(xRet) <= 10 .And. At(";", xRet) > 0
							cChaveRm := xRet
						Else
							cErro	 := xRet
						EndIf
					Else

						cErro := I18n(STR0010, {AllTrim(cErro), AllTrim(oWsdl:cError), AllTrim(cAviso)})	//"Erro ao receber retorno do XML: #1 \ #2 \ #3"
					EndIf
				Else
					cErro := I18n(STR0010, {AllTrim(cErro), AllTrim(oWsdl:cError), AllTrim(cAviso)})	//"Erro ao receber retorno do XML: #1 \
					JurConOut("Erro RM:" + cValToChar (xRet) + CRLF + cErro)
				EndIf

			Else
				cErro := STR0011 + CRLF + oWsdl:cError		//"Erro ao enviar mensagem:"
				JurConOut("Erro RM:" + cErro)
			EndIf
		EndIf
	EndIf
	
	If !Empty(cErro)
		IF At("===", cErro) > 1
			cErro := Left(cErro, At("===", cErro)-1)	//Retira informações tecnicas caso existam
		EndIf
		MsgAlert(cErro, STR0008)	//"Integração com RM"
	EndIf

	FreeObj(oXml)

Return cChaveRm

//-------------------------------------------------------------------
/*/{Protheus.doc} JiRmExWiPa()
Executa o metodo ExecuteWithParams do serviço wsProcess do processo informado.

@param	cPrSrvName 	- Nome do Processo que será executado
@param	cXml 		- Xml no com dados do registro que será inserido

@return	cChaveRm	- Chave do registro que foi gerado no RM

@author  Rafael Tenorio da Costa
@since 	 02/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JiRmExWiPa(cPrSrvName, cXml)

	Local oWsdl		:= Nil
 	Local xRet		:= Nil
	Local cErro		:= ""
	Local cAviso	:= ""
	Local aSimple	:= {}
	Local nPos		:= 0
	Local cMsg		:= ""
	Local oXml		:= Nil

	//Cria e conecta no Wsdl
	cErro := ConectaRM(@oWsdl, "/wsProcess/mex?WSDL","ExecuteWithParams",@xRet)

	If Empty(cErro)

		//Define a operação
//	  	xRet := oWsdl:SetOperation("ExecuteWithParams")
	  	If xRet
			aSimple := oWsdl:SimpleInput()
		Else
	    	cErro := I18n(STR0009, {STR0012}) + oWsdl:cError		//"Erro ao definir #1 "		//"método: "
		EndIf

		If Empty(cErro) .And. ( nPos := aScan(aSimple, {|x| x[2] == "ProcessServerName"}) ) > 0
		  	xRet := oWsdl:SetValue( aSimple[nPos][1], cPrSrvName )	//Ex: "FinLanCancelamentoParamsProc"
		  	If !xRet
		    	cErro := I18n(STR0009, {"tag ProcessServerName: "}) + oWsdl:cError		//"Erro ao definir #1 "
		  	EndIf
		EndIf

		If Empty(cErro) .And. ( nPos := aScan(aSimple, {|x| x[2] == "strXmlParams"}) ) > 0
		  	xRet := oWsdl:SetValue( aSimple[nPos][1], cXml )
		  	If !xRet
		    	cErro := I18n(STR0009, {"tag strXmlParams: "}) + oWsdl:cError		//"Erro ao definir #1 "
		  	EndIf
		EndIf

		If Empty(cErro)

			//Pega a mensagem que sera enviada para Web Service
		    cMsg := oWsdl:GetSoapMsg()

			//Envia a mensagem SOAP ao servidor
		  	xRet := oWsdl:SendSoapMsg(cMsg)

		  	If xRet
			  	//Pega a mensagem de resposta
			  	xRet := oWsdl:GetSoapResponse()

				//Obtem somente Result Tag do XML de retorno
			    xRet := SubStr(xRet, At("<ExecuteWithParamsResult>"  , xRet), Len(xRet))
			    xRet := Left(xRet  , At("</ExecuteWithParamsResult>" , xRet) + 25)

			  	//Pega o retorno da <SaveRecordResult>
			  	oXml := XmlParser(xRet, "_", @cErro, @cAviso)

			  	If oXml <> Nil .And. XmlChildEx(oXml, "_EXECUTEWITHPARAMSRESULT") <> Nil

					//Obtem retorno do xml como string
			  		xRet := AllTrim(oXml:_EXECUTEWITHPARAMSRESULT:TEXT)

			  		If xRet <> "1"
				  		cErro := I18n(STR0014, {"ExecuteWithParams", cPrSrvName}) + CRLF + STR0015 + xRet		//"Erro ao executar metodo #1 com o processo #2."		//"Mensagem de retorno: "
				  	EndIf
			  	Else

			  		cErro := I18n(STR0010, {AllTrim(cErro), AllTrim(oWsdl:cError), AllTrim(cAviso)})	//"Erro ao receber retorno do XML: #1 \ #2 \ #3"
			  	EndIf

			Else
				cErro := STR0011 + CRLF + oWsdl:cError		//"Erro ao enviar mensagem:"
		  	EndIf
	  	EndIf

	EndIf

	If !Empty(cErro)
		cErro := AllTrim( DecodeUTF8(cErro) )
		MsgAlert(cErro, STR0008)	//"Integração com RM"
	Endif

	FreeObj(oXml)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ConectaRM()
Cria e conecta no TWsdlManager e seta usuario e senha para acesso ao serviço.

@param	oWsdl 		- Objeto TWsdlManager
@param	cServico	- Nome do serviço que será executado

@return	cErro - Descrição do erro

@author  Rafael Tenorio da Costa
@since 	 09/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConectaRM(oWsdl, cServico,cOperation,xRet)
Local cErro    := ""
Local cUrl     := SuperGetMv("MV_JURLRM", , "")	//Ex:	"http://spon010108549:8051"
Local cUsuario := SuperGetMv("MV_JUSRRM", , "")	//Ex:	"mestre"
Local cSenha   := SuperGetMv("MV_JPSWRM", , "")	//ex:	"totvs"

Default cOperation := ""
Default xRet := NIL


	If !Empty(cUrl).And. !Empty(cUsuario) .And. !Empty(cSenha)

		//Carrega o url com o serviço
		cUrl := cUrl + cServico

		//Cria e conecta no Wsdl
		oWsdl := JurConWsdl(cUrl, @cErro,cUsuario, cSenha)

		If Empty(cErro)
			oWsdl:SetAuthentication(cUsuario, cSenha)

			If !Empty(cOperation)
				xRet := oWsdl:SetOperation(cOperation)
			EndIf

			//Authenticate pre-emptively
			oWsdl:AddHttpHeader( "Authorization", "Basic " + Encode64(cUsuario + ":" + cSenha) )

		EndIf
	Else

		cErro := I18n(STR0013, {"MV_JURLRM", "MV_JUSRRM", "MV_JPSWRM"})		//"Não foi possível conectar ao web service RM, verifique os parâmetros #1 / #2 / #3"
	EndIf





Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataCmp()
Formata os campos que serão enviados para o RM para o formato que o XML espera.

@param	 xConteudo	- Conteúdo a ser formatado
@return  xConteudo 	- Conteúdo formatado

@author	 Rafael Tenorio da Costa
@since 	 05/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TrataCmp(xConteudo)

	Local cTipo := ValType(xConteudo)

	Do Case
		Case cTipo == "C"
			xConteudo := EncodeUTF8(AllTrim(xConteudo))

		Case cTipo == "D"
			xConteudo := cValToChar( Year(xConteudo) ) + "-" + StrZero( Month(xConteudo), 2) + "-" + StrZero( Day(xConteudo), 2)

		Case cTipo == "N"
			xConteudo := cValToChar(xConteudo)
	End Case

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataTagFLAN(cCmpOpc, cXml)
Trata os campos  opcionais, substituindo os campos padrões e/ou adicionando novos.

@param	 cCmpOpc	- Campos opcionais (passados por referência)
@return  cXml 	    - Corpo XML final (passados por referência)

@since 	 14/05/2020
/*/
//-------------------------------------------------------------------
Static Function TrataTagFLAN(cCmpOpc, cXml)
Local nTemp      := 1
Local cTag       := ""

	While nTemp < len(cCmpOpc)
		// Separa a tag inicial
		cTag := SubStr(cCmpOpc,At("<",cCmpOpc,nTemp),At(">",cCmpOpc,nTemp)-At("<",cCmpOpc,nTemp)+1)
		If (!Empty(cTag)) .And. ("<" != cTag)
			nTemp := At(">",cCmpOpc,nTemp) //posição onde acaba a tag inicial
			If At(cTag,cXml) > 0 //se a tag do primeiro campo já existir
				// faz a substituição da tag no cXml
				cXml := replace(cXml,SubStr(substr(cXml,At(cTag,cXml)),1,At(Replace(cTag,"<","</"),substr(cXml,At(cTag,cXml)))+len(Replace(cTag,"<","</"))-1),SubStr(substr(cCmpOpc,At(cTag,cCmpOpc)),1,At(Replace(cTag,"<","</"),substr(cCmpOpc,At(cTag,cCmpOpc)))+len(Replace(cTag,"<","</"))-1)) 
				// retira a tag usada na substituição dos campos opcionais
				cCmpOpc := replace(cCmpOpc,SubStr(substr(cCmpOpc,At(cTag,cCmpOpc)),1,At(Replace(cTag,"<","</"),substr(cCmpOpc,At(cTag,cCmpOpc)))+len(Replace(cTag,"<","</"))-1),'')
				nTemp := nTemp - (len(substr(cCmpOpc,At(cTag,cCmpOpc)))+len(Replace(cTag,"<","</"))-1)
				If nTemp<0
					nTemp := 1
				EndIf
			EndIf
		Else
			nTemp := len(cCmpOpc) + 1 //tamanho da tag restante que não existe no paddrão + 1
		EndIf
	End

Return .T.

