#INCLUDE 'Protheus.ch'   
#INCLUDE 'MATA116I.ch'  

Static oCTeFis	:= Nil

/*/{Protheus.doc}ImpXML_Cte
Faz o processamento do arquivo xml CT-e no diretorio NEW para 
gravar os registros do arquivo XML nas tabelas SDS e SDT.

@param	cFile: caminho do Arquivo XML.
@param	lJob: indica se a rotina esta sendo executada via JOB.
@param	aProc: grava msgs de sucesso no array aProc durante a importacao.
@param	aErros: grava msg de falha no array durante a importacao.
@param	oXML: objeto com o conteudo XML do documento.

@return lRet: indica se a importacao foi feita com sucesso.

@author Rodrigo de Toledo Silva
@since  16/05/12
/*/

Function ImpXML_Cte(cFile,lJob,aProc,aErros,oXml,aErroErp,oXMLCanc,lCTeSimp)
Local cQuery		As Character
Local cAliasQry 	As Character
Local nOrder		As Numeric
Local oQry      	As Object
Local cPrdFrete  	:= ""
Local lRet       	:= .T.
Local lRemet 	 	:= .F.
Local lToma3Dest 	:= .F.
Local lToma3Rec	 	:= .F.
Local lDevSemSF1 	:= .F.
Local lToma4	 	:= .F.
Local nX		 	:= 0
Local nPesoBruto 	:= 0
Local nPesoLiqui 	:= 0    
Local nY		 	:= 0
Local nPos			:= 0
Local cError     	:= ""
Local cCNPJ_CT	 	:= ""
Local cCNPJ_CF	 	:= ""
Local cFornCTe   	:= ""
Local cLojaCTe   	:= ""
Local cNomeCTe   	:= ""
Local cCodiRem   	:= ""
Local cLojaRem   	:= ""
Local cChaveNF   	:= ""
Local cTES_CT 	 	:= ""
Local cCPag_CT 	 	:= ""
Local cTipoFrete 	:= ""
Local cTagDest	 	:= ""
local cTagRem	 	:= ""
Local cTagExped	 	:= ""
Local cIEExped	 	:= ""
Local cIEReceb	 	:= ""
Local cIEEmit 	 	:= ""
Local cIEDest	 	:= ""
Local cIEDestT4  	:= ""
Local cRetPrd	 	:= ""
Local cMotivo		:= ""
Local cTxtErro		:= ""
Local aDadosAux  	:= {}
Local aDadosFor  	:= Array(2) //-- 1- Codigo; 2-Loja
Local aDadosCli  	:= Array(2) //-- 1- Codigo; 2-Loja
Local aCabec116	 	:= {}
Local aItens116	 	:= {}
Local aAux		 	:= {}
Local aEspecVol  	:= {}
Local aAux1		 	:= {}
Local aAuxCliFor 	:= {}
Local aParamPE	 	:= {}
Local aChave	 	:= {}
Local lMt116XmlCt	:= ExistBlock("MT116XMLCT")
Local lA116ITPCT 	:= ExistBlock("A116ITPCT")
Local lA116ICHV	 	:= ExistBlock("A116ICHV")
Local lA116iComp 	:= ExistBlock("A116ICOMP")
Local lA116ICTEN 	:= ExistBlock("A116ICTEN")
Local cVersao	 	:= oXML:_InfCte:_Versao:Text
Local nTamFil	 	:= 0
Local lComp			:= .F. // Indica se CTe é do tipo complementar
Local cTpCte 		:= ""
Local lDevBen		:= .F. // Devolução ou Beneficiamento
Local cDoc			:= ""
Local cSerie		:= ""
Local aA116IDOC		:= {}
Local cChvNFOr		:= ""
Local nDevOri		:= 0
Local nNorOri		:= 0
Local lFornOri 		:= .T.
Local aFornChv		:= {}
Local nPFornChv		:= 0
Local aExcStat 		:= {"100","102","103","104","105","106","107","108","109","110","111","112","113","114","134","135","136","301"}
Local cHrEmis		:= ""
Local lVlrFrtZero	:= .F.
Local nVlrFrt		:= 0
Local cCFBN			:= SuperGetMv("MV_XMLCFBN",.F.,"")
Local lRateiaDev	:= SuperGetMv("MV_XMLRATD",.F.,.T.)
Local cUFOrigem		:= ""
Local cMunOrigem	:= ""
Local cUFDestino	:= ""
Local cMunDestin	:= ""
Local lVerifChvNF   := SuperGetMV("MV_COLVCHV",.F.,.T.)
Local lDocSerNF     := SuperGetMV("MV_COLVDCS",.F.,.F.)

//lPreNota = .T. (Não Classificado), lPreNota = .F. (Classificado)
//MV_CTECLAS = .F. (Não Classificado), MV_CTECLAS = .T. (Classificado)
Local lPreNota		:= !SuperGetMV("MV_CTECLAS",.F.,.F.) 
// Variaveis para apuracao do ICMS
Local oICMS
Local oICMSTipo
Local oICMSNode
Local nZ			:= 0
Local nBaseICMS 	:= 0
Local nValICMS		:= 0
Local nAliqICMS		:= 0
Local lBaseICMS 	:= .F.
Local lValICMS		:= .F.
Local lAliqICMS		:= .F.
Local lT4DifDest	:= .F.
Local lT3Exped		:= .F.
Local lT3Remet		:= .F.
Local lDSNotF1		:= .F.
Local cCSTClas		:= ""
Local lDTClasFis	:= SDT->(FieldPos("DT_CLASFIS")) > 0
Local cCodCfop  	:= ""
Local aImpCadAut	:= {}
Local cStatusAut	:= ""
Local lVlrCte		:= SuperGetMv("MV_VLRCTE",.F.,.F.)
local lNatRen   	:= SDT->(FieldPos("DT_NATREN")) > 0  //Natureza de Rendimento
local cNatRen   	:= ""
Local lIcmsStRet	:= .F.
Local cInfoCTeSimp	:= ""
Local aGrvCTeSimp	:= {}
Local aChvF2		:= {}
Local aChvQryF2		:= {}
Local aRota			:= {}
Local lDTObsDoc		:= SDT->(FieldPos("DT_MOBSDOC")) > 0
Local lTabDKM		:= ChkFile("DKM")
Local aDadosDKM		:= {}
Local cClassTrib	:= ""
Local cCSTCBSIBS	:= ""
Local nBIBSCBS		:= 0
Local nAIBSUF 		:= 0
Local nVIBSUF		:= 0
Local nADIFIBSUF	:= 0
Local nVDIFIBSUF	:= 0
Local nVDEVIBSUF	:= 0
Local nAREDIBSUF	:= 0
Local nAREEIBSUF	:= 0
Local nAIBSMUN		:= 0
Local nVIBSMUN		:= 0
Local nADIFIBSMUN	:= 0
Local nVDIFIBSMUN	:= 0
Local nVDEVIBSMUN	:= 0
Local nAREDIBSMUN	:= 0
Local nAREEIBSMUN	:= 0
Local nACBS			:= 0
Local nVCBS			:= 0
Local nADIFCBS		:= 0
Local nVDIFCBS		:= 0
Local nVDEVCBS		:= 0
Local nAREDCBS		:= 0
Local nAREECBS		:= 0
Local cCSTReg		:= ""
Local cClasReg		:= ""
Local nAIBSUFReg	:= 0
Local nVIBSUFReg	:= 0
Local nAIBSMunReg	:= 0
Local nVIBSMunReg	:= 0
Local nACBSReg		:= 0
Local nVCBSReg		:= 0
Local cCredPreIBS	:= ""
Local nAlCrePrIBS	:= 0
Local nVlCrePrIBS	:= 0
Local cCredPreCBS	:= ""
Local nAlCrePrCBS	:= 0
Local nVlCrePrCBS	:= 0
Local nItemSDT		:= 0
Private lImpXML	  	:= SuperGetMv("MV_IMPXML",.F.,.F.)
Private lImpXTra	:= Iif(FindFunction("ImpXTra"),ImpXTra(),.F.)
Private cEspecie	:= ""

Default lJob    	:= .T.
Default aProc   	:= {}
Default aErros  	:= {} 
Default aErroERP 	:= {}
Default lCTeSimp	:= .F. 

//-- Verifica se o arquivo pertence a filial corrente
lRet := CTe_VldEmp(oXML,SM0->M0_CGC,@lToma3Dest,@lToma4,lJob,cFile,,,@lT4DifDest,@lT3Exped,@lT3Remet,@aErros,@aErroERP,.F.,@cTipoFrete,@lToma3Rec,lCTeSimp)

//Verifica se XML é Cancelado ou Rejeitado.
If lRet .And. ValType(oXMLCanc) <> "U"
	If Valtype(XmlChildEx(oXMLCanc:_infProt,"_CSTAT")) <> "U"
		//Chave CT-e
		cChaveCte	:= Right(AllTrim(oXML:_InfCte:_Id:Text),44)
		
		//Motivo rejeição
		If Valtype(XmlChildEx(oXMLCanc:_infProt,"_XMOTIVO")) <> "U"
			cMotivo := ConvASC(oXMLCanc:_infProt:_xMotivo:Text)  
		Endif
		
		//Busca status
		nPos := aScan(aExcStat,AllTrim(oXMLCanc:_infProt:_cStat:Text))
		
		//Status de cancelado ou rejeitado
		If nPos == 0
			If AllTrim(oXMLCanc:_infProt:_cStat:Text) == "101" //Cancelado
				If !lJob
					Aviso(STR0001,"CT-e cancelado: " + cChaveCte,{"OK"},2,"ImpXML_CTe")//"Erro"#"CT-e cancelado
				EndIf
				
				aAdd(aErros,{cFile,"COM036 - CT-e cancelado: " + cChaveCte,""})
				aAdd(aErroErp,{cFile,"COM036"})
				
				lRet := .F.
			Else //Rejeitado
				If !lJob
					Aviso(STR0001,"CT-e rejeitado: " + cChaveCte + " - Motivo: " + cMotivo,{"OK"},2,"ImpXML_CTe")//"Erro"#"CT-e cancelado
				EndIf
				
				aAdd(aErros,{cFile,"COM037 - CT-e rejeitado: " + cChaveCte + " - Motivo: " + cMotivo,""})
				aAdd(aErroErp,{cFile,"COM037"})
				lRet := .F.
			Endif	
		Endif
	Endif
	
	If Valtype(XmlChildEx(oXMLCanc:_infProt,"_DHRECBTO")) <> "U"
		cHrEmis := Substr(oXMLCanc:_infProt:_DhRecbto:Text,12)
	Endif
Endif
                                      
//-- Verifica se o ID ja foi processado
If lRet
	SDS->(dbSetOrder(2))
	If lRet .And. SDS->(dbSeek(xFilial("SDS")+Right(AllTrim(oXML:_InfCte:_Id:Text),44)))
		If lJob
			aAdd(aErros,{cFile,"COM019 - " + STR0003 +SDS->(DS_DOC+"/"+SerieNfId('SDS',2,'DS_SERIE')); //"ID de CT-e já registrado na NF "
							+ STR0004 + " (" +SDS->(DS_FORNEC +"/" +DS_LOJA)+ ").",STR0005}) //"do Fornecedor/Cliente "#"Exclua o documento registrado na ocorrência."
		Else 
			Aviso(STR0001,STR0003 +SDS->(DS_DOC+"/"+SerieNfId('SDS',2,'DS_SERIE'));
								+ STR0004 + SDS->(DS_FORNEC+"/"+DS_LOJA) +".",{"OK"},2,"ImpXML_CTe")
		EndIf
		aAdd(aErroErp,{cFile,"COM019"}) 
		lRet := .F.
	EndIf
EndIf

//-- Verifica se CTe é do tipo complementar
If lRet .And. Valtype(XmlChildEx(oXml:_InfCte,"_INFCTECOMP")) != "U"
	lComp := .T.
EndIf

//-- Verifica se o fornecedor do conhecimento esta cadastrado no sistema.
If lRet
	If ValType(XmlChildEx(oXML:_InfCte:_Emit,"_CNPJ")) <> "U"
		cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CNPJ:Text)
	Else
		cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CPF:Text)
	EndIf

	If ValType(XmlChildEx(oXML:_InfCte:_Emit,"_IE")) <> "U"
		cIEEmit := AllTrim(oXML:_InfCte:_Emit:_IE:Text)
	Endif
	
	// Envio das letras E, D ou R pela funcao A116ICLIFOR. E = Emitente, D = Destinatario e R = Remetente.
	// Essa informacao sera utilizada no P.E. A116IFOR.
	aDadosAux := A116ICLIFOR(cCNPJ_CT,cIEEmit,"SA2",,oXML,'E')
	
	If Len(aDadosAux) == 0
		If lImpXTra .And. FindFunction("ImpCadAutF")
			aImpCadAut	:= ImpCadAutF(oXML,"116I","N")
			lRet 	:= aImpCadAut[1]

			If !lRet
				//"Fornecedor/Cliente"#"inexistente na base."#"Gere cadastro para este fornecedor/cliente."
				ImpXMLErr(lJob,cFile,@aErros,"COM007 - " + STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007 + aImpCadAut[5],STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007,STR0008,"COM007",@aErroErp,"ImpXML_CTe")
			Else
				cFornCTe 	:= aImpCadAut[2]
				cLojaCTe 	:= aImpCadAut[3]
				cNomeCTe	:= aImpCadAut[4]
				cStatusAut	:= "B"
			Endif
		Else
			lRet := .F.
			//"Fornecedor/Cliente"#"inexistente na base."#"Gere cadastro para este fornecedor/cliente."
			ImpXMLErr(lJob,cFile,@aErros,"COM007 - " + STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007 ,STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007,STR0008,"COM007",@aErroErp,"ImpXML_CTe")
		Endif
	ElseIf !aDadosAux[1,1] .And. aDadosAux[1,5] // Se encontrou o cadastro e o mesmo esta bloqueado.
		cTxtErro := "COM030 - " + STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0037 + STR0038 //"Fornecedor"#"bloqueado."#"Realize o desbloqueio"
		
		ImpXmlErr(lJob , cFile , @aErros,; 
		cTxtErro,cTxtErro,cTxtErro,;
		"COM030",@aErroErp,"ImpXML_CTe")

		lRet := .F.
	Elseif !aDadosAux[1,1]
		cTxtErro := "COM028 - " + STR0032 + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") + STR0033 + STR0034
			
		ImpXmlErr(lJob , cFile , @aErros,; 
		cTxtErro,cTxtErro,cTxtErro,;
		"COM028",@aErroErp,"ImpXML_CTe")

		lRet := .F.
	Else
		cFornCTe := aDadosAux[1,2]
		cLojaCTe := aDadosAux[1,3]
		cNomeCTe := Posicione("SA2",1,xFilial("SA2") + cFornCTe + cLojaCTe,"A2_NOME")
	Endif
EndIf

//Identifica se a empresa foi remetente das notas fiscais contidas no conhecimento:

//Se sim, significa que as notas contidas no conhecimento sao notas de saida, podendo ser
//notas de venda, devolucao de compras ou devolucao de remessa para beneficiamento.

//Se nao, significa que as notas contidas no conhecimento sao notas de entrada, podendo ser
//notas de compra, devolucao de vendas ou remessa para beneficiamento.
If lRet
	If !lCTeSimp
		aDadosAux := {}
		cTagRem := If(ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O",If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF"),"")

		//TOMA3 = 0 -> REMETENTE
		If ( lRemet := (SM0->M0_CGC == If(!Empty(cTagRem),(AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)),"")) .And. !lToma3Dest .And. lT3Remet )

			cCNPJ_CF	:= ""
			cIERem		:= ""
			
			If ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O"
				cCNPJ_CF	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)
				
				cIERem := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_IE")) == "O",AllTrim(XmlChildEx(oXML:_InfCte:_Rem,"_IE"):Text),"")			
			Endif
			
			If !Empty(cCNPJ_CF)
				//Fornecedor
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIERem,"SA2",,oXML,'R')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"F"}),aAdd(aDadosAux,aAuxCliFor[1]))
				
				//Cliente
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIERem,"SA1",,oXML,'R')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"C"}),aAdd(aDadosAux,aAuxCliFor[1]))
			Endif
			
			// Verifica a TAG <TpCte> para analisar se a nota eh complementar.
			cTpCte := If(ValType(XmlChildEx(oXML:_InfCte,"_IDE")) == "O",AllTrim(oXML:_InfCte:_Ide:_tpCTe:Text),"") //-- Armazena o tipo do CT-e.
			
			// Opcoes para <TpCte>:
			// 0 - CT-e Normal;
			// 1 - CT-e de Complemento de Valores;
			// 2 - CT-e de Anulação de Valores;
			// 3 - CT-e Substituto.
			
			If cTpCte == '1' // CT-e de Complemento de Valores
				lRemet := .F.
			EndIf
			
		ElseIf lToma3Rec //TOMA3 = 2 -> RECEBEDOR

			cCNPJ_CF	:= ""
			cIEReceb	:= ""

			If ValType(XmlChildEx(oXML:_InfCte,"_RECEB")) == "O"
				cTagExped := If(ValType(XmlChildEx(oXML:_InfCte:_Receb,"_CNPJ")) == "O","_CNPJ","_CPF")
				cCNPJ_CF	:= AllTrim(XmlChildEx(oXML:_InfCte:_Receb,cTagExped):Text)
				
				cIEReceb := If(ValType(XmlChildEx(oXML:_InfCte:_Receb,"_IE")) == "O", AllTrim(XmlChildEx(oXML:_InfCte:_Receb,"_IE"):Text), "")
			Endif
			
			If !Empty(cCNPJ_CF)
				//Fornecedor
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEReceb,"SA2",,oXML,'B')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"F"}),aAdd(aDadosAux,aAuxCliFor[1]))
				
				//Cliente
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEReceb,"SA1",,oXML,'B')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"C"}),aAdd(aDadosAux,aAuxCliFor[1]))
			Endif

		ElseIf lToma4 //TOMA4 -> DESTINATÁRIO/REMETENTE

			cCNPJ_CF	:= ""
			cIEDestT4	:= ""

			If ValType(XmlChildEx(oXML:_InfCte:_IDE:_TOMA4,"_CNPJ")) == "O" .OR. ValType(XmlChildEx(oXML:_InfCte:_IDE:_TOMA4,"_CPF")) == "O"

				cTagExped 	:= If(ValType(XmlChildEx(oXML:_InfCte:_IDE:_TOMA4,"_CNPJ")) == "O","_CNPJ","_CPF")
				cCNPJ_CF	:= AllTrim(XmlChildEx(oXML:_InfCte:_IDE:_TOMA4,cTagExped):Text)
				
				If ValType(XmlChildEx(oXML:_InfCte:_IDE:_TOMA4,"_IE")) == "O"
					cIEDestT4 := AllTrim(XmlChildEx(oXML:_InfCte:_IDE:_TOMA4,"_IE"):Text)
				Endif
			Endif
			
			If !Empty(cCNPJ_CF)
				//Fornecedor
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEDestT4,"SA2",,oXML,'T')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"F"}),aAdd(aDadosAux,aAuxCliFor[1]))
				
				//Cliente
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEDestT4,"SA1",,oXML,'T')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"C"}),aAdd(aDadosAux,aAuxCliFor[1]))
			EndIf
			
		Elseif lT3Exped //TOMA3 = 1 -> EXPEDIDOR

			cCNPJ_CF	:= ""
			cIEExped	:= ""

			If ValType(XmlChildEx(oXML:_InfCte,"_EXPED")) == "O"

				cTagExped := If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
				cCNPJ_CF	:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,cTagExped):Text)
				
				If ValType(XmlChildEx(oXML:_InfCte:_Exped,"_IE")) == "O"
					cIEExped		:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,"_IE"):Text)
				Endif
			Endif
			
			If !Empty(cCNPJ_CF)
				//Fornecedor
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEExped,"SA2",,oXML,'X')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"F"}),aAdd(aDadosAux,aAuxCliFor[1]))
				
				//Cliente
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEExped,"SA1",,oXML,'X')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"C"}),aAdd(aDadosAux,aAuxCliFor[1]))
			Endif

		Else //TOMA3 = 3 -> DESTINATÁRIO

			cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_DEST,"_CNPJ")) == "O","_CNPJ","_CPF")
			cIEDest	 := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_IE")) == "O",AllTrim(oXML:_InfCte:_Dest:_IE:Text),"")
			cCNPJ_CF := AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
			
			If !Empty(cCNPJ_CF) 
				//Fornecedor
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEDest,"SA2",,oXML,'D')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"F"}),aAdd(aDadosAux,aAuxCliFor[1]))
				
				//Cliente
				aAuxCliFor := A116ICLIFOR(cCNPJ_CF,cIEDest,"SA1",,oXML,'D')
				
				If(Len(aAuxCliFor) == 0,aAdd(aDadosAux,{.T.,"","",.F.,.F.,"C"}),aAdd(aDadosAux,aAuxCliFor[1]))
			EndIf
			
		Endif
	Endif
	
	// Verifica a TAG <TpCte> para analisar se a nota eh de Anulacao de Valores.
	If cTpCte <> '1'
		cTpCte := If(ValType(XmlChildEx(oXML:_InfCte,"_IDE")) == "O",AllTrim(oXML:_InfCte:_Ide:_tpCTe:Text),"") //-- Armazena o tipo do CT-e.
	EndIf

	If cCodCfop == ""
		cCodCfop := If(ValType(oXML:_InfCte:_IDE:_CFOP) == "O",AllTrim(oXML:_InfCte:_Ide:_CFOP:Text),"") //-- Armazena o CFOP do CT-e.
	EndIf	

	If lComp
		aAux1 := If(ValType(oXML:_InfCte:_InfCTeComp) == "O",{oXML:_InfCte:_InfCTeComp},oXML:_InfCte:_InfCTeComp)
	ElseIf cTpCte == '2'
		If ValType(XmlChildEx(oXML:_InfCte:_infCteAnu,"_INFDOC")) != "U" .And. ValType(XmlChildEx(oXML:_InfCte:_infCteAnu:_InfDoc,"_INFNF")) != "U"
			aAux := If(ValType(oXML:_InfCte:_infCteAnu:_InfDoc:_INFNF) == "O",{oXML:_InfCte:_infCteAnu:_InfDoc:_INFNF},oXML:_InfCte:_infCteAnu:_InfDoc:_INFNF)
		EndIf
	Elseif cTpCTe == "5" .And. lCTeSimp //CTe Simplificado
		aAux1 := IIF(ValType(oXML:_InfCte:_Det) == "O",{oXML:_InfCte:_Det},oXML:_InfCte:_Det)	
	ElseIf cVersao >= "2.00"
		If Valtype(XmlChildEx(oXml:_InfCte,"_INFCTENORM")) != "U"
			If ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm,"_INFDOC")) != "U" .And. ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc,"_INFNF")) != "U"
				aAux := If(ValType(oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF) == "O",{oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF},oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF)
			ElseIf ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm,"_INFDOC")) != "U" .And. ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc,"_INFNFE")) != "U"
				aAux1 := If(ValType(oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE) == "O",{oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE},oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE)
			EndIf
		EndIf
	Else
		If ValType(XmlChildEx(oXML:_InfCte:_Rem,"_INFNF")) != "U"
			aAux := If(ValType(oXML:_InfCte:_Rem:_INFNF) == "O",{oXML:_InfCte:_Rem:_INFNF},oXML:_InfCte:_Rem:_INFNF)
		ElseIf ValType(XmlChildEx(oXML:_InfCte:_Rem,"_INFNFE")) != "U"
			aAux1 := If(ValType(oXML:_InfCte:_Rem:_INFNFE) == "O",{oXML:_InfCte:_Rem:_INFNFE},oXML:_InfCte:_Rem:_INFNFE)
		EndIf
	EndIf
	
	If Len(aAux) > 0 .Or. (Len(aAux) == 0 .And. Len(aAux1) == 0)
		If Len(aAux) > 0
			cCodiRem 		:= CriaVar("A2_COD",.F.)
			cLojaRem 		:= CriaVar("A2_LOJA",.F.)
			aDadosFor[1]	:= CriaVar("A2_COD",.F.)
			aDadosFor[2]	:= CriaVar("A2_LOJA",.F.)
			aDadosCli[1]	:= CriaVar("A1_COD",.F.)
			aDadosCli[2]	:= CriaVar("A1_LOJA",.F.)
		Endif
		
		If lRet //Validou fornecedor ou cliente
			
			SF2->(dbClearFilter())
			SF2->(dbSetOrder(1))
			
			SF1->(dbClearFilter())
			SF1->(dbSetOrder(1))
			
			SDS->(dbClearFilter())
			SDS->(dbSetOrder(1))
			
			For nX := 1 To Len(aAux)
				lDSNotF1 := .F.
				//Verifica CFOP para saber se documento origem é Beneficamento
				lNFOriBen	:= aAux[nX]:_nCFOP:Text $ cCFBN
				
				cChaveNF :=	PadL(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F1_DOC")[1], "0") +;
								PadR(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F1_SERIE")[1])
					
				//Ponto de entrada para manipulaça da chave(nº do doc + serie) do doc de origem
				If lA116ICHV
					aChave := ExecBlock("A116ICHV",.F.,.F.,{AllTrim(aAux[nX]:_nDoc:Text),AllTrim(aAux[nX]:_Serie:Text)})
					If ValType(aChave) == "A" .And. Len(aChave) >= 2
						cChaveNF :=	Padr(AllTrim(aChave[1]),TamSX3("F1_DOC")[1],) +;
										Padr(AllTrim(aChave[2]),TamSX3("F1_SERIE")[1])   
					EndIf
				EndIf
					
				If lNFOriBen
					//Busca documento de origem (beneficiamento)
					aDadosCli := A116IFOCL(aDadosAux,"C")
					
					If aDadosCli[1] .And. !Empty(aDadosCli[2])
						If SF1->(dbSeek(xFilial("SF1")+cChaveNF+aDadosCli[2]+aDadosCli[3]))
							cCodiRem := aDadosCli[2]
							cLojaRem := aDadosCli[3]
						Else
							If SDS->(dbSeek(xFilial("SDS")+cChaveNF+aDadosCli[2]+aDadosCli[3]))
								lDSNotF1 := .T.
							Endif
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					Endif
				Else
					//Não sabe o tipo do documento, busca pelo fornecedor e/ou cliente
					aDadosFor := A116IFOCL(aDadosAux,"F")
					
					If aDadosFor[1] .And. !Empty(aDadosFor[2])
						If SF1->(dbSeek(xFilial("SF1")+cChaveNF+aDadosFor[2]+aDadosFor[3]))
							cCodiRem := aDadosFor[2]
							cLojaRem := aDadosFor[3]
						Else
							If SDS->(dbSeek(xFilial("SDS")+cChaveNF+aDadosFor[2]+aDadosFor[3]))
								lDSNotF1 := .T.
							Endif
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					Endif
					
					If !lRet
						aDadosCli := A116IFOCL(aDadosAux,"C")
					
						If aDadosCli[1] .And. !Empty(aDadosCli[2])
							If SF1->(dbSeek(xFilial("SF1")+cChaveNF+aDadosCli[2]+aDadosCli[3]))
								cCodiRem := aDadosCli[2]
								cLojaRem := aDadosCli[3]
								lRet := .T.
							Else
								If SDS->(dbSeek(xFilial("SDS")+cChaveNF+aDadosCli[2]+aDadosCli[3]))
									lDSNotF1 := .T.
								Endif
								lRet := .F.
							EndIf
						Else
							lRet := .F.
						Endif
					Endif
				Endif
				
				If !lRet
					// Tratamento para CTe de devolucao quando o cliente nao aceitou receber a mercadoria
					// Neste caso a transportadora emite um novo CTe referenciando as notas de venda, as notas estarao em SF2 e nao SF1
					cChaveNF :=	Padr(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F2_DOC")[1]) +;
									Padr(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F2_SERIE")[1])
									
					aDadosCli := A116IFOCL(aDadosAux,"C") 
					
					If aDadosCli[1] .And. !Empty(aDadosCli[2])
						If SF2->(dbSeek(xFilial("SF2")+cChaveNF+aDadosCli[2]+aDadosCli[3]))
							cCodiRem := aDadosCli[2]
							cLojaRem := aDadosCli[3]
						
							aErros	:= {}
							cTipoFrete := "D"
							lDevSemSF1 := .T.
						Else
							If SDS->(dbSeek(xFilial("SDS")+cChaveNF+aDadosCli[2]+aDadosCli[3]))
								lDSNotF1 := .T.
							Endif
						EndIf
					Else
						lRet := .F.
					Endif
				Endif
				
				//-- Registra notas que farao parte do conhecimento
				If lRet
					nTamFil := Len(xFilial("SF1"))
					cChvNFOr := SF1->F1_CHVNFE
					aAdd(aItens116,{{"PRIMARYKEY",SubStr(SF1->&(IndexKey()),nTamFil+1), cCodiRem, cLojaRem}})
					
					lDevBen	:= SF1->F1_TIPO $ "D*B"
					
					If lDevBen
						nDevOri++
					Else
						nNorOri++
					Endif
					
					If nDevOri > 0 .And. nNorOri > 0
						lFornOri := .F.
					Endif
				Else
					If lT3Exped .Or. lT4DifDest .Or. lT3Remet .Or. lDevSemSF1 .Or. (!lDSNotF1 .And. lDocSerNF)
						lRet := .T.
					Else
						If lDSNotF1
							If lJob
								aAdd(aErros,{cFile,"COM044 - " + STR0011 + cChaveNF + STR0049,STR0050}) //"Documento de entrada existente no monitor. Processe o recebimento deste documento de entrada para importar o CTE corretamente"
							Else
								Aviso(STR0001,STR0011 + cChaveNF + STR0049 + STR0050,2,"ImpXML_CTe") //"Documento de entrada existente no monitor. Processe o recebimento deste documento de entrada para importar o CTE corretamente"
							EndIf
							aAdd(aErroErp,{cFile,"COM044"})							
						Else
							if !lDocSerNF
								ImpXMLErr(lJob,cFile,@aErros,"COM020 - " + STR0011 +STR0053+ cChaveNF + " "+STR0007,STR0011 + cChaveNF + STR0007 + STR0012,STR0012,"COM020",@aErroErp)
							endif 	
						Endif
						Exit
					Endif
				EndIf
			Next nX
		Endif
	Endif
	
	If lRet .And. Len(aAux1) > 0
		For nX := 1 To Len(aAux1)
			If !lCTeSimp
				lDSNotF1 := .F.
				SDS->(dbSetOrder(2))
				
				SF1->(dbSetOrder(8))
				
				If ValType(XmlChildEx(aAux1[nX],"_CHAVE")) == "O"
					cChaveNF := Padr(AllTrim(aAux1[nX]:_chave:Text),TamSX3("F1_CHVNFE")[1])
				ElseIf ValType(XmlChildEx(aAux1[nX],"_CHCTE")) == "O"
					cChaveNF := Padr(AllTrim(aAux1[nX]:_chCTE:Text),TamSX3("F1_CHVNFE")[1])
				EndIf
				
				//Verifica existência da nota
				If SF1->(dbSeek(xFilial("SF1")+cChaveNF)) .And. !Empty(cChaveNF) //Se nota existir, preenche informações do Remetente com dados da nota
					cCodiRem 	:= SF1->F1_FORNECE
					cLojaRem 	:= SF1->F1_LOJA
					lDevBen	:= SF1->F1_TIPO $ "D*B"
					
					If lDevBen
						nDevOri++
					Else
						nNorOri++
					Endif
					
					//Se as chaves nfe pertencem a mais de 1 fornecedor, ao incluir o documento de frente
					//não deve ser filtrado pelo fornecedor.
					nPFornChv := aScan(aFornChv,{|x| x == cCodiRem+cLojaRem})
					If nPFornChv == 0
						aAdd(aFornChv,cCodiRem+cLojaRem)
					Endif
					
					If (nDevOri > 0 .And. nNorOri > 0) .Or. Len(aFornChv) > 1
						lFornOri := .F.
					Endif
					
					//-- Registra notas que farao parte do conhecimento
					SF1->(dbSetOrder(1))
					nTamFil := Len(xFilial("SF1"))
					cChvNFOr := SF1->F1_CHVNFE
					aAdd(aItens116,{{"PRIMARYKEY",SubStr(SF1->&(IndexKey()),nTamFil+1), cCodiRem, cLojaRem}})
				Else
					If SDS->(dbSeek(xFilial("SDS")+cChaveNF))
						lDSNotF1 := .T.
						lRet	 := .F.
						If lJob
							aAdd(aErros,{cFile,"COM044 - " + STR0011 + cChaveNF + " existente no monitor.","Processe o recebimento deste documento de entrada para importar o CTE corretamente"}) //"Documento de entrada existente no monitor. Processe o recebimento deste documento de entrada para importar o CTE corretamente"
						Else
							Aviso(STR0001,STR0011 + cChaveNF + " existente no monitor." + "Processe o recebimento deste documento de entrada para importar o CTE corretamente",2,"ImpXML_CTe") //"Documento de entrada existente no monitor. Processe o recebimento deste documento de entrada para importar o CTE corretamente"
						EndIf
						aAdd(aErroErp,{cFile,"COM044"})
						Exit
					Endif
					
					SF2->(dbClearFilter())
					SF2->(dbSetOrder(1))
					
					cQuery 		:= ""
					cAliasQry 	:= GetNextAlias()
					nOrder 		:= 1  
					oQry 		:= Nil
				
					cQuery := " SELECT RECNO"
					cQuery += " FROM ( "
					cQuery += " SELECT R_E_C_N_O_ AS RECNO,ROW_NUMBER() OVER (ORDER BY R_E_C_N_O_ DESC) AS LINHA "
					cQuery += " FROM ?"
					cQuery += " WHERE F2_FILIAL = ?"  
					cQuery += "	AND  F2_CHVNFE = ?"
					cQuery += " AND D_E_L_E_T_ = ?"
					cQuery += "	) SF12"
					cQuery += " WHERE LINHA = 1"
					
					oQry := FWPreparedStatement():New()
					oQry:SetQuery(cQuery)

					oQry:SetNumeric(nOrder++,RetSqlName("SF2"))
					oQry:SetString(nOrder++,xFilial("SF2"))
					oQry:SetString(nOrder++,cChaveNF)
					oQry:SetString(nOrder++,Space(1) )

					cQuery      := oQry:GetFixQuery()
					cAliasQry := MpSysOpenQuery(cQuery,cAliasQry)

					FreeObj(oQry)
					
					If (cAliasQry)->(!Eof())
						aErros	:= {}
						lDevSemSF1 := .T.
					elseif !lVerifChvNF
						ImpXMLErr(lJob,cFile,@aErros,"COM020 - " + STR0011 +STR0053+ cChaveNF + " "+STR0007,STR0011 + cChaveNF + STR0007 + STR0012,STR0012,"COM020",@aErroErp)
						lRet := .F.
					EndIf
					(cAliasQry)->(DbCloseArea())
				EndIf
			Elseif lCTeSimp //CTe Simplificado
				
				cInfoCTeSimp := ""

				If nX == 1
					cInfoCTeSimp := "Rota|UF|Município|Cod. Município Origem|UF|Município|Cod. Município Final|Valor Frete"
					cInfoCTeSimp += CRLF + "	Rota|Chaves NFs Origem"
					cInfoCTeSimp += CRLF + Replicate("-",80) + CRLF
				Endif
				
				cInfoCTeSimp += CRLF + AllTrim(StrZero(nX,3)) //Rota

				//UF/Municipio/Codigo Municipio Origem
				If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_UFINI")) != "U" .And. ValType(XmlChildEx(aAux1[nX],"_XMUNINI")) == "O" .And. ValType(XmlChildEx(aAux1[nX],"_CMUNINI")) == "O"
					cInfoCTeSimp += DecodeUTF8("|" + AllTrim(oXML:_InfCte:_Ide:_UFINI:Text) + "|" + AllTrim(aAux1[nX]:_XMUNINI:Text)+ "|" + AllTrim(aAux1[nX]:_CMUNINI:Text))
				Endif

				//UF/Municipio/Codigo Municipio Fim
				If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_UFFIM")) != "U" .And. ValType(XmlChildEx(aAux1[nX],"_XMUNFIM")) == "O" .And. ValType(XmlChildEx(aAux1[nX],"_CMUNFIM")) == "O"
					cInfoCTeSimp += DecodeUTF8("|" + AllTrim(oXML:_InfCte:_Ide:_UFFIM:Text) + "|" + AllTrim(aAux1[nX]:_XMUNFIM:Text)+ "|" + AllTrim(aAux1[nX]:_CMUNFIM:Text))
				Endif

				//Valor da Prestação ou Valor a Receber
				//lVlrCTe = T (Valor da Prestação) / F (Valor a Receber)

				If lVlrCTe
					If ValType(XmlChildEx(aAux1[nX],"_VPREST")) == "O"
						cInfoCTeSimp += "|" + AllTrim(Transform(Val(aAux1[nX]:_VPREST:Text),X3Picture("DT_TOTAL")))
					Endif
				Else
					//Valor a receber
					If ValType(XmlChildEx(aAux1[nX],"_VREC")) == "O"
						cInfoCTeSimp += "|" + AllTrim(Transform(Val(aAux1[nX]:_VREC:Text),X3Picture("DT_TOTAL")))
					Endif
				Endif

				If ValType(XmlChildEx(oXML:_InfCte,"_DET")) != "U" 
					aRota := IIF(ValType(oXML:_InfCte:_Det) == "O",{oXML:_InfCte:_Det},oXML:_InfCte:_Det) 

					//Ler apenas rota "nX"
					If ValType(XmlChildEx(aRota[nX],"_INFNFE")) != "U"
						aChvF2	  := IIF(ValType(aRota[nX]:_InfNFE) == "O",{aRota[nX]:_InfNFE},aRota[nX]:_InfNFE)
						aChvQryF2 := {}
						
						For nY := 1 To Len(aChvF2)
							cInfoCTeSimp += CRLF+"	" + AllTrim(StrZero(nX,3))  + "|" + AllTrim(aChvF2[nY]:_CHNFE:Text)
							aAdd(aChvQryF2,AllTrim(aChvF2[nY]:_CHNFE:Text))
						Next nY				
					Endif
				Endif

				cInfoCTeSimp += CRLF+Replicate("-",80)+CRLF 

				SF2->(dbClearFilter())
				SF2->(dbSetOrder(1))
				
				cQuery 		:= ""
				cAliasQry 	:= GetNextAlias()
				nOrder 		:= 1  
				oQry 		:= Nil
			
				cQuery := " SELECT RECNO"
				cQuery += " FROM ( "
				cQuery += " SELECT R_E_C_N_O_ AS RECNO,ROW_NUMBER() OVER (ORDER BY R_E_C_N_O_ DESC) AS LINHA "
				cQuery += " FROM ?"
				cQuery += " WHERE F2_FILIAL = ?"  
				cQuery += "	AND  F2_CHVNFE IN (?)"
				cQuery += " AND D_E_L_E_T_ = ?"
				cQuery += "	) SF12"
				cQuery += " WHERE LINHA = 1"
				
				oQry := FWPreparedStatement():New()
				oQry:SetQuery(cQuery)

				oQry:SetNumeric(nOrder++,RetSqlName("SF2"))
				oQry:SetString(nOrder++,xFilial("SF2"))
				oQry:SetIn(nOrder++,aChvQryF2)
				oQry:SetString(nOrder++,Space(1) )

				cQuery      := oQry:GetFixQuery()
				cAliasQry := MpSysOpenQuery(cQuery,cAliasQry)

				FreeObj(oQry)
				
				If (cAliasQry)->(!Eof())
					aErros	:= {}
					lDevSemSF1 := .T.

					aAdd(aGrvCTeSimp,cInfoCTeSimp) //Por rota
				EndIf
				(cAliasQry)->(DbCloseArea())
			Endif			
		Next nX
	Endif

	If lDevBen .And. !lRateiaDev
		aItens116 := {}
	EndIf

	If lToma4 .And. Len(aItens116) == 0 
		lToma4NFOri := .F.
	Endif

	If lRet .And. (Len(aAux1) == 0 .And. Len(aAux) == 0) .Or. lDevSemSF1 .Or. Len(aItens116) == 0
		//-- Ponto de entrada para mudar o produto frete
 		If ExistBlock("A116PRDF")
			cPrdFrete := ExecBlock("A116PRDF",.F.,.F.,{oXML})
			If ValType(cPrdFrete) <> "C" .Or. !SB1->(dbSeek(xFilial("SB1")+cPrdFrete))
				cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
				If At(";",cPrdFrete) > 0
					cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
				EndIf
				cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])
			EndIf
		Elseif lA116ITPCT
			aParamPE := If(Len(aAux) > 0,aAux,aAux1)
			cRetPrd := ExecBlock("A116ITPCT",.F.,.F.,{aParamPE, oXML})
			If ValType(cRetPrd) == "C" .And. SB1->(dbSeek(xFilial("SB1")+cRetPrd))
				cPrdFrete := PadR(cRetPrd,TamSX3("B1_COD")[1])
				cTipoFrete := "D"
				lRemet := .T.
			Else
				cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
				If At(";",cPrdFrete) > 0
					cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
				EndIf
				cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])	
			EndIf
		Else
			cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
			If At(";",cPrdFrete) > 0
				cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
			EndIf
			cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])
		EndIf
	
		If Empty(cPrdFrete) .Or. !SB1->(dbSeek(xFilial("SB1")+cPrdFrete))
			If lJob
				aAdd(aErros,{cFile,"COM023 - " + STR0017,STR0018}) //"Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente."#"Verifique a configuração do parâmetro."
			Else
				Aviso(STR0001,STR0017+STR0018,2,"ImpXML_CTe")
			EndIf
			aAdd(aErroErp,{cFile,"COM023"})
			lRet := .F.
		Else
			lRemet := .T.
		EndIf
	Elseif lRet .And. Len(aItens116) > 0 .And. lA116ICTEN
		aParamPE := If(Len(aAux) > 0,aAux,aAux1)
		cRetPrd := ExecBlock("A116ICTEN",.F.,.F.,{aParamPE, oXML})
		If ValType(cRetPrd) == "C" .And. SB1->(dbSeek(xFilial("SB1")+cRetPrd))
			cPrdFrete := PadR(cRetPrd,TamSX3("B1_COD")[1])
			cTipoFrete := "D"
			lRemet := .T.
		Else
			cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
			If At(";",cPrdFrete) > 0
				cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
			EndIf
			cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])	
		EndIf
	Endif
	
	//-- Obtem TES e cond. pagto para utilizacao no CT-e
	CTe_RetTES(oXML,@cTES_CT,@cCPag_CT)
	
	//-- Valida existencia da TES a utilizar no CTe
	If lRet .And. !lPreNota .And. (Empty(cTES_CT) .Or. !SF4->(dbSeek(xFilial("SF4")+cTES_CT))) 
 		If lJob
			aAdd(aErros,{cFile,"COM021 - " + STR0013,STR0014}) //"TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente."
		Else
			Aviso(STR0001,STR0013 + STR0014,2,"ImpXML_CTe")
		EndIf
		aAdd(aErroErp,{cFile,"COM021"})
		lRet := .F.
	EndIf
	
	//-- Valida se o TES esta desbloqueado.
	If lRet
		If SF4->F4_MSBLQL == '1' .And. !lPreNota // TES bloqueado.
	 		If lJob
				aAdd(aErros,{cFile,"COM029 - " + STR0035 + SF4->F4_CODIGO,STR0036}) //"TES bloqueado. Codigo: "#"Verifique a configuração do cadastro."
			Else
				Aviso(STR0001,STR0035 + SF4->F4_CODIGO + Space(1) + STR0036,2,"ImpXML_CTe")
			EndIf
			aAdd(aErroErp,{cFile,"COM029"})
			lRet := .F.
		EndIf
	EndIf
	
	//-- Se TES gera dup., valida existencia da cond. pgto a utilizar no CTe
	If lRet .And. SF4->F4_DUPLIC == "S" .And. (Empty(cCPag_CT) .Or. !SE4->(dbSeek(xFilial("SE4")+cCPag_CT)))
 		If lJob
			aAdd(aErros,{cFile,"COM022 - " + STR0015,STR0016}) //"Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro.
		Else
			Aviso(STR0001,STR0015+STR0016,2,"ImpXML_CTe") //"Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro.
		EndIf
		lRet := .F.
		aAdd(aErroErp,{cFile,"COM022"})
	EndIf
Endif

// Verifica existência de documento com mesma numeração.
If lRet	
	cDoc	:= PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0")
	cSerie	:= PadR(oXML:_InfCte:_Ide:_Serie:Text,SerieNfId("SF1",6,"F1_SERIE")) 
	
	If ExistBlock("A116IDOC") //Manipula numero e serie do documento
		aA116IDOC := ExecBlock("A116IDOC",.F.,.F.,{cDoc, cSerie, cFornCTe, cLojaCTe})
		If ValType(aA116IDOC) == 'A' .And. Len(aA116IDOC) >= 2
			cDoc	:= aA116IDOC[1]
			cSerie := aA116IDOC[2]
		EndIf
	EndIf
	
	dbSelectArea("SDS")
	dbSetorder(1)
	If msSeek(xFilial("SDS")+cDoc+cSerie+cFornCTe+cLojaCTe)
		If lJob
			aAdd(aErros,{cFile,"COM025 - " + STR0026+" "+cDoc+", "+STR0027+" "+cSerie+" , "+STR0028,STR0029}) //Documento cdoc, serie cSerie, já cadastrado. verifique se o documento já foi importado para o ERP. 
		Else
			Aviso(STR0001,STR0026+" "+cDoc+", "+STR0027+""+cSerie+" , "+STR0028+" "+STR0029,2,"ImpXML_CTe")
		EndIf
		aAdd(aErroErp,{cFile,"COM025"})
		lRet := .F.
	EndIf
EndIf

If lRet
	If !lCTeSimp
		//-- Separa secao que contem as notas do conhecimento para laco
		If ValType(XmlChildEx(oXML:_InfCte,"_INFCTENORM")) <> "U"
			aAux := If(ValType(oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ) == "O",{oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ},oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ)
		EndIf
		For nX := 1 To Len(aAux)
			If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO BRUTO"
				nPesoBruto := Val(aAux[nX]:_QCARGA:Text)
			EndIf
			If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO LíQUIDO"
				nPesoLiqui := Val(aAux[nX]:_QCARGA:Text)
			EndIf
			If !("PESO" $ Upper(aAux[nX]:_TPMED:Text)) .And. Len(aEspecVol) < 5
				aAdd(aEspecVol,{AllTrim(aAux[nX]:_TPMED:Text),Val(aAux[nX]:_QCARGA:Text)})
			EndIf
		Next nX
	Elseif lCTeSimp
		If ValType(XmlChildEx(oXML:_InfCte,"_INFCARGA")) <> "U"
			aAux := If(ValType(oXML:_InfCte:_InfCarga:_InfQ) == "O",{oXML:_InfCte:_InfCarga:_InfQ},oXML:_InfCte:_InfCarga:_InfQ)
		EndIf

		For nX := 1 To Len(aAux)
			If !("PESO" $ Upper(aAux[nX]:_TPMED:Text)) .And. Len(aEspecVol) < 5
				aAdd(aEspecVol,{AllTrim(aAux[nX]:_TPMED:Text),Val(aAux[nX]:_QCARGA:Text)})
			EndIf
		Next nX
		//CBS e IBS
		If lTabDKM
			If ValType(XmlChildEx(oXML:_InfCte:_imp,"_IBSCBS")) == "O"
				cCSTCBSIBS	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS,"_CST")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_CST:Text,"")
				cClassTrib	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS,"_CCLASSTRIB")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_CCLASSTRIB:Text,"")

				If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS,"_GIBSCBS")) == "O"
					nBIBSCBS	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_VBC")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_vBC:Text), 0)	

					//IBSUF
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GIBSUF")) == "O"
						nAIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_PIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_PIBSUF:Text), 0)	
						nVIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_VIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_VIBSUF:Text), 0)

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_GDIF")) == "O"
							nADIFIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF,"_PDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF:_PDIF:Text), 0)
							nVDIFIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF,"_VDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF:_VDIF:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_GDEVTRIB")) == "O"
							nVDEVIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDEVTRIB,"_VDEVTRIB")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDEVTRIB:_VDEVTRIB:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_GRED")) == "O"
							nAREDIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED,"_PREDALIQ")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED:_PREDALIQ:Text), 0)
							nAREEIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED,"_PALIQEFET")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED:_PALIQEFET:Text), 0)
						Endif
					Endif

					//IBSMun
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GIBSMUN")) == "O"
						nAIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_PIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_PIBSMUN:Text), 0)	
						nVIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_VIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_VIBSMUN:Text), 0)

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_GDIF")) == "O"
							nADIFIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF,"_PDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF:_PDIF:Text), 0)
							nVDIFIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF,"_VDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF:_VDIF:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_GDEVTRIB")) == "O"
							nVDEVIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDEVTRIB,"_VDEVTRIB")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDEVTRIB:_VDEVTRIB:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_GRED")) == "O"
							nAREDIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED,"_PREDALIQ")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED:_PREDALIQ:Text), 0)
							nAREEIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED,"_PALIQEFET")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED:_PALIQEFET:Text), 0)
						Endif
					Endif

					//CBS
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GCBS")) == "O"
						nACBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_PCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_PCBS:Text), 0)	
						nVCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_VCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_VCBS:Text), 0)

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_GDIF")) == "O"
							nADIFCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF,"_PDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF:_PDIF:Text), 0)
							nVDIFCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF,"_VDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF:_VDIF:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_GDEVTRIB")) == "O"
							nVDEVCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDEVTRIB,"_VDEVTRIB")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDEVTRIB:_VDEVTRIB:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_GRED")) == "O"
							nAREDCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED,"_PREDALIQ")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED:_PREDALIQ:Text), 0)
							nAREECBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED,"_PALIQEFET")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED:_PALIQEFET:Text), 0)
						Endif
					Endif

					//CBS e IBS Como seria tributação caso não cumprida a condição resolutória/suspensiva
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GTRIBREGULAR")) == "O"
						cCSTReg	    := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_CSTREG")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_CSTREG:Text, "")
						cClasReg    := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_CCLASSTRIBREG")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_CCLASSTRIBREG:Text, "")
						nAIBSUFReg  := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_PALIQEFETREGIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_PALIQEFETREGIBSUF:Text), 0)
						nVIBSUFReg  := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_VTRIBREGIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_VTRIBREGIBSUF:Text), 0)
						nAIBSMunReg := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_PALIQEFETREGIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_PALIQEFETREGIBSMUN:Text), 0)
						nVIBSMunReg := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_VTRIBREGIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_VTRIBREGIBSMUN:Text), 0)
						nACBSReg	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_PALIQEFETREGCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_PALIQEFETREGCBS:Text), 0)
						nVCBSReg	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_VTRIBREGCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_VTRIBREGCBS:Text), 0)
					Endif

					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GIBSCREDPRES")) == "O"
						cCredPreIBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES,"_CCREDPRES")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES:_CCREDPRES:Text, "")
						nAlCrePrIBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES,"_PCREDPRES")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES:_PCREDPRES:Text), 0)
						nVlCrePrIBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES,"vCredPresCondSus")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES:vCredPresCondSus:Text), 0)
					Endif

					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GCBSCREDPRES")) == "O"
						cCredPreCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES,"_CCREDPRES")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES:_CCREDPRES:Text, "")
						nAlCrePrCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES,"_PCREDPRES")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES:_PCREDPRES:Text), 0)
						nVlCrePrCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES,"_VCREDPRES")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES:_VCREDPRES:Text), 0)
					Endif

				Endif
			Endif
		Endif
	Endif
	// Apuracao do ICMS para as diversas situacoes tributarias
	If ValType(XmlChildEx(oXML:_InfCte:_imp,"_ICMS")) <> "U" 
		If ( oICMS := oXML:_INFCTE:_IMP:_ICMS ) != Nil 
			If ( oICMSTipo := XmlGetChild( oICMS, 1 )) != Nil 
				lIcmsStRet := .F.
				For nZ := 1 To 5	// O nivel maximo para descer dentro da tag que define o tipo do ICMS para obter tanto base quanto valor é 5, conforme manual de orientacao do CTe
					If ( oICMSNode := XmlGetChild( oICMSTipo, nZ )) != Nil
						If "vBC" $ oICMSNode:REALNAME
							nBaseICMS := Val(oICMSNode:TEXT)
							lBaseICMS := .T.
						ElseIf "vICMS" $ oICMSNode:REALNAME
							nValICMS := Val(oICMSNode:TEXT)
							lValICMS := .T.
						ElseIf "pICMS" $ oICMSNode:REALNAME
							nAliqICMS := Val(oICMSNode:TEXT)
							lAliqICMS := .T.
						ElseIf "CST" $ oICMSNode:REALNAME
							cCSTClas	:= oICMSNode:TEXT
						Endif
						If "vICMSSTRet" $ oICMSNode:REALNAME
							lIcmsStRet	:= .T.
						EndIf
						If lBaseICMS .And. lValICMS .And. lAliqICMS
							Exit
						EndIf
					EndIf
				Next nZ
			EndIf
		EndIf

		lRet := !COMXIMPVLD({{nAliqICMS,">=100"}})
		If !lRet
			cTxtErro := "COM043 - " + STR0046 + STR0047 //"Foi identificada uma alíquota de impostos igual ou superior a 100%." | " Por favor, confira a origem do XML ou valide a configuração dos campos de alíquotas (tamanho e decimais) ou insira o documento manualmente."
			ImpXmlErr(lJob , cFile , @aErros, cTxtErro, cTxtErro, cTxtErro, "COM043" , @aErroErp, "ImpXML_CTe")
		Endif
	EndIf
Endif

// Ponto de entrada utilizado para manipular a gravacao dos itens da nota de frete
// Exemplo: Desmembrar o valor do frete entre seus componentes (tags <vPrest><Comp>)
If lRet .And. lA116iComp
	If (lRemet .And. !lToma4) .Or. lDevSemSF1 .Or. (lToma4 .And. !lToma4NFOri)
		aItensComp := ExecBlock("A116ICOMP",.F.,.F.,{oXml})
		If ValType(aItensComp) == "A" .And. Len(aItensComp) > 0
			For nX := 1 To Len(aItensComp)
				If	aScan(aItensComp[nX],{|x| x[1] == "DT_ITEM" })	> 0 .And.;
					aScan(aItensComp[nX],{|x| x[1] == "DT_COD" })	> 0 .And.;
					aScan(aItensComp[nX],{|x| x[1] == "DT_VUNIT" })	> 0 .And.;
					aScan(aItensComp[nX],{|x| x[1] == "DT_TOTAL" })	> 0
					lRet := .T.
				Else
					lRet := .F.
					Exit
				EndIf
			Next nX
		Else
			lRet := .F.
		EndIf
		If !lRet
			aAdd(aErros,{cFile,"COM032 - A116ICOMP - " + STR0039, STR0040}) //"Retorno do ponto de entrada A116ICOMP inconsistente." - "Verifique a documentacao do mesmo no portal TDN."
			aAdd(aErroErp,{cFile,"COM032"})
		EndIf
	EndIf
EndIf

//Valor do frete
If !lCTeSimp
	If lRet .And. ValType(XmlChildEx(oXML:_InfCte,"_VPREST")) <> "U"
		If ValType(XmlChildEx(oXML:_InfCte:_vPrest,"_VREC")) <> "U" .And. ValType(XmlChildEx(oXML:_InfCte:_vPrest,"_VTPREST")) <> "U"
			If Val(oXML:_InfCte:_VPrest:_VRec:Text) == 0 .And. Val(oXML:_InfCte:_VPrest:_vTPrest:Text) == 0
				
				If cTpCte == "1" //Complemento de imposto, pois não tem valor de prestação e valor recolhido.
					lRet := .F.
					aAdd(aErros,{cFile,"COM047 - Complemento de imposto não é tratado pelo Totvs Colaboração/Importador. Gere o documento manualmente.", STR0040})
					aAdd(aErroErp,{cFile,"COM047"})
				Endif
				
				lVlrFrtZero := .T.
			Elseif Val(oXML:_InfCte:_VPrest:_VRec:Text) == 0 .And. Val(oXML:_InfCte:_VPrest:_vTPrest:Text) > 0
				nVlrFrt := Val(oXML:_InfCte:_VPrest:_vTPrest:Text)
				lVlrFrtZero := .T.
			Elseif lVlrCte .And. Val(oXML:_InfCte:_VPrest:_vTPrest:Text) > 0
				nVlrFrt := Val(oXML:_InfCte:_VPrest:_vTPrest:Text)
			Else
				nVlrFrt := Val(oXML:_InfCte:_VPrest:_VRec:Text)
			Endif
		Endif
	Endif
Elseif lCTeSimp
	If lRet .And. ValType(XmlChildEx(oXML:_InfCte,"_TOTAL")) <> "U"
		If ValType(XmlChildEx(oXML:_InfCte:_Total,"_VTREC")) <> "U" .And. ValType(XmlChildEx(oXML:_InfCte:_Total,"_VTPREST")) <> "U"
			If lVlrCte .And. Val(oXML:_InfCte:_Total:_vTPrest:Text) > 0
				nVlrFrt := Val(oXML:_InfCte:_Total:_vTPrest:Text)
			Else
				nVlrFrt := Val(oXML:_InfCte:_Total:_VTRec:Text)
			Endif
		Endif
	Endif
Endif

If lRet
	//Estado de origem do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_UFINI")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_UFIni:Text)
		cUFOrigem := oXML:_InfCte:_Ide:_UFIni:Text		
	Else
		cUFOrigem := Posicione("SA2",1,xFilial("SA2")+cFornCTe+cLojaCTe,"A2_EST")
	Endif
	
	//Codigo Municipio de origem do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_CMUNINI")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_cMunIni:Text)
		cMunOrigem := SubStr(oXML:_InfCte:_Ide:_cMunIni:Text,3,5)
	Endif
	
	//Estado de destino do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_UFFIM")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_UFFim:Text)
		cUFDestino := oXML:_InfCte:_Ide:_UFFim:Text
	Endif
	
	//Codigo Municipio de destino do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_CMUNFIM")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_cMunFim:Text)
		cMunDestin := SubStr(oXML:_InfCte:_Ide:_cMunFim:Text,3,5)
	Endif

	If !lCTeSimp
		DbSelectArea("CC2")
		CC2->(DbSetOrder(1))
		If !CC2->(DbSeek(xfilial("CC2")+cUFOrigem+cMunOrigem))
			lRet := .F.
			aAdd(aErros,{cFile,"COM051 - Codigo do municipio inexistente. Est: " + cUFOrigem + " Mun: " + cMunOrigem, STR0039})
			aAdd(aErroErp,{cFile,"COM051"})
		Endif

		If lRet
			If !CC2->(DbSeek(xfilial("CC2")+cUFDestino+cMunDestin))
				lRet := .F.
				aAdd(aErros,{cFile,"COM051 - Codigo do municipio inexistente. Est: " + cUFDestino + " Mun: " + cMunDestin, STR0039})
				aAdd(aErroErp,{cFile,"COM051"})
			Endif
		Endif
	Endif
Endif

If lRet
	Begin Transaction
	cEspecie := "CTE"	
	//-- Grava cabeca do conhecimento de transporte
	RecLock("SDS",.T.)
	SDS->DS_FILIAL	:= xFilial("SDS")																					// Filial			
    SDS->DS_CNPJ	:= cCNPJ_CT																						// CGC
    SDS->DS_DOC		:= cDoc																							// Numero do Documento
    SDS->DS_FORNEC	:= cFornCTe																						// Fornecedor do Conhecimento de transporte
    SDS->DS_LOJA	:= cLojaCTe																						// Loja do Fornecedor do Conhecimento de transporte
    SDS->DS_EMISSA	:= StoD(StrTran(AllTrim(oXML:_InfCte:_Ide:_Dhemi:Text),"-",""))							// Data de Emissão
    SDS->DS_EST		:= cUFOrigem																			// Estado de emissao da NF
    SDS->DS_TIPO	:= "T"													 											// Tipo da Nota
    SDS->DS_FORMUL	:= "N" 																							// Formulario proprio
    SDS->DS_ESPECI	:= cEspecie															  								// Especie
    SDS->DS_ARQUIVO	:= AllTrim(cFile)																					// Arquivo importado
    SDS->DS_CHAVENF	:= Right(AllTrim(oXML:_InfCte:_Id:Text),44)													// Chave de Acesso da NF
    SDS->DS_VERSAO	:= AllTrim(oXML:_InfCte:_Versao:Text) 															// Versão
    SDS->DS_USERIMP	:= IIf(!lJob,cUserName,Iif(lImpXML,STR0054,STR0055))											// Usuario na importacao -- Importador XML # Totvs Colaboração
    SDS->DS_DATAIMP	:= dDataBase																						// Data importacao do XML
    SDS->DS_HORAIMP	:= SubStr(Time(),1,5)																			// Hora importacao XML
    SDS->DS_VALMERC	:= nVlrFrt																	  						// Valor Mercadoria
	SDS->DS_TOTAL	:= nVlrFrt
    SDS->DS_TPFRETE	:= cTipoFrete																						// Tipo de Frete
    SDS->DS_PBRUTO	:= nPesoBruto																						// Peso Bruto
    SDS->DS_PLIQUI	:= nPesoLiqui																						// Peso Liquido
    
    For nX := 1 To Len(aEspecVol)
    	SDS->&("DS_ESPECI" +Str(nX,1)) := aEspecVol[nX,1]							 							// Especie
		SDS->&("DS_VOLUME" +Str(nX,1)) := aEspecVol[nX,2]							 							// Volume
	Next nX
	
	If !lIcmsStRet
		If lBaseICMS
			SDS->DS_BASEICM := nBaseICMS
		EndIf
	
		If lValICMS
			SDS->DS_VALICM := nValICMS
		EndIf
	EndIf

	SDS->DS_TPCTE := TIPOCTE116(oXML:_InfCte:_Ide:_tpCTe:Text)
	
	//Chave da Nota de Origem
    SDS->DS_CHVNFOR		:= cChvNFOr
    
   	If !Empty(cHrEmis)
		SDS->DS_HORNFE := cHrEmis
	Endif
	
	//Valor a pagar igual a 0
	If lVlrFrtZero
		SDS->DS_FRETE := Iif(nVlrFrt==0,1,nVlrFrt)
	Endif
	
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_MODAL")) <> "U"
		SDS->DS_MODAL := AllTrim(oXML:_InfCte:_Ide:_modal:Text)
	Endif
	
	//Estado/Municipio de Origem e Destino do CTE
	If !lCTeSimp .And. !Empty(cUFOrigem)  .And. !Empty(cMunOrigem) .And. !Empty(cUFDestino) .And. !Empty(cMunDestin)
		SDS->DS_UFDESTR := cUFDestino
		SDS->DS_MUDESTR := cMunDestin
		SDS->DS_UFORITR := cUFOrigem
		SDS->DS_MUORITR := cMunOrigem
	Endif

	If !Empty(cStatusAut)
		SDS->DS_STATUS := cStatusAut
	Endif
	
	SerieNfId("SDS",1,"DS_SERIE",SDS->DS_EMISSA,SDS->DS_ESPECI,cSerie) 
	
	SDS->(MsUnlock())
	
	//Se for remetente mas a notas de origem existem no sistema
	If (lRemet .And. !lToma4) .And. Len(aItens116) > 0
		lRemet := .F.
	Endif
	
	//-- Grava itens do conhecimento de transporte
	If (lRemet .And. !lToma4) .Or. lDevSemSF1 .Or. (lToma4 .And. !lToma4NFOri) .Or. (lA116ICTEN .And. !Empty(cPrdFrete))
		If lA116iComp
			For nX := 1 To Len(aItensComp)
				RecLock("SDT",.T.)
				SDT->DT_FILIAL:= xFilial("SDT")
				SDT->DT_DOC	:= cDoc
				SDT->DT_SERIE	:= cSerie
				SDT->DT_FORNEC:= cFornCTe
				SDT->DT_LOJA	:= cLojaCTe
				SDT->DT_CNPJ	:= SDS->DS_CNPJ
				SDT->DT_QUANT	:= 1
				For nY := 1 To Len(aItensComp[nX])
					&("SDT->"+AllTrim(aItensComp[nX][nY][1])) := aItensComp[nX][nY][2]
				Next nY
				SDT->(MsUnlock())
			Next nX
		Else
			RecLock("SDT",.T.)
			SDT->DT_FILIAL		:= xFilial("SDT")											// Filial
			SDT->DT_ITEM		:= StrZero(1,TamSX3("DT_ITEM")[1])				   		// Item
			SDT->DT_COD			:= cPrdFrete												// Codigo do produto
			SDT->DT_FORNEC		:= cFornCTe													// Forncedor
			SDT->DT_LOJA		:= cLojaCTe												// Loja
			SDT->DT_DOC			:= cDoc														// Docto
			SDT->DT_SERIE		:= cSerie 					   							// Serie
			SDT->DT_CNPJ		:= SDS->DS_CNPJ											// Cnpj do Fornecedor
			SDT->DT_QUANT		:= 1													// Quantidade
			SDT->DT_VUNIT		:= nVlrFrt												// Valor Unitário 			
			SDT->DT_TOTAL		:= nVlrFrt										   		// Vlor Total 			 	
			SDT->DT_CODCFOP     := cCodCfop

			If !lIcmsStRet
				If SDT->(FieldPos("DT_XBASICM")) > 0 .And. lBaseICMS
					SDT->DT_XBASICM := nBaseICMS
				EndIf

				If lAliqICMS
					SDT->DT_PICM := nAliqICMS
					SDT->DT_XALQICM := nAliqICMS
				EndIf

				If lValICMS
					SDT->DT_XMLICM := nValICMS
				Endif
			ElseIf lIcmsStRet
				If lBaseICMS
					SDT->DT_BASNDES := nBaseICMS
				EndIf

				If lAliqICMS
					SDT->DT_ALQNDES := nAliqICMS
				EndIf

				If lValICMS
					SDT->DT_ICMNDES := nValICMS
				EndIf
			EndIf

			SDT->DT_UM		:= GetAdvFVal("SB1","B1_UM",xFilial("SB1")+cPrdFrete,1)
			SDT->DT_SEGUM	:= GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+cPrdFrete,1)
				
			If !Empty(SDT->DT_SEGUM)
				SDT->DT_QTSEGUM := Iif(COLVLSEGUM(cPrdFrete),ConvUM(cPrdFrete,1,1,2),0)
			Endif
			
			if lNatRen .and. FindFunction("A103GetNat")
				cNatRen := A103GetNat(cPrdFrete)
				if !empty(cNatRen)
					SDT->DT_NATREN:= cNatRen
				endif
			endif

			If lCTeSimp .And. lDTObsDoc
				cInfoCTeSimp := ""
				For nY := 1 To Len(aGrvCTeSimp)
					cInfoCTeSimp += aGrvCTeSimp[nY]
				Next nY

				SDT->DT_MOBSDOC := cInfoCTeSimp
			Endif

			SDT->(MsUnlock())
			If lTabDKM
				nItemSDT := StrZero(1,TamSX3("DT_ITEM")[1])

				//IBSUF
				aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000060' )	
								{"DKM_DOC"		,cDoc},;			// Numero Documento             
								{"DKM_SERIE"	,cSerie},;			// Serie                    
								{"DKM_FORNEC"	,cFornCTe},;		// Fornecedor / Cliente     
								{"DKM_LOJA"		,cLojaCTe},;		// Loja                     
								{"DKM_TIPO"		, "T"	},;			// Tipo Nota                
								{"DKM_ESPECI"	,cEspecie},;			// Especie                  
								{"DKM_ITEM"		,nItemSDT	},;		// Item NF                  
								{"DKM_COD"		,cPrdFrete},;		// Produto                  
								{"DKM_TRIB"		,"IBSUF"},;			// Tributo / Imposto        
								{"DKM_XMLBAS"	,nBIBSCBS},;		// Base CBS/IBS NO XML	
								{"DKM_XMLALQ"	,nAIBSUF},;			// Aliquota IBS UF NO XML	
								{"DKM_XMLVLR"	,nVIBSUF},;			// Valor IBS UF NO XML	
								{"DKM_BASE"		,0},;				// Base CBS/IBS	
								{"DKM_ALIQ"		,0},;				// Aliquota IBS UF	
								{"DKM_VALOR"	,0},;				// Valor IBS UF	
								{"DKM_PDIF"		,nADIFIBSUF},;		// Aliquota Diferencial IBS UF	
								{"DKM_VDIF"		,nVDIFIBSUF},;		// Valor Diferencial IBS UF	
								{"DKM_VDEV"		,nVDEVIBSUF},;		// Valor Devolvido IBS UF	
								{"DKM_PREDAL"	,nAREDIBSUF},;		// Aliquota Reduzida Classifição Tributaria	
								{"DKM_PALIEF"	,nAREEIBSUF},;		// Aliquota Efetiva	
								{"DKM_CST"		,cCSTCBSIBS},;		// CST CBS/IBS	
								{"DKM_CLASTR"	,cClassTrib},;		// Classificação Tributaria	
								{"DKM_CSTRE"	,cCSTReg},;			// CST Regular (Seria se fosse)	
								{"DKM_CLAREG"	,cClasReg},;		// Classificação Tributaria (Seria se fosse)	
								{"DKM_ALQEFE"	,nAIBSUFReg},;		// Aliquota IBS UF (Seria se fosse)	
								{"DKM_VLREFE"	,nVIBSUFReg},;		// Valor IBS UF (Seria se fosse)	
								{"DKM_CODCRE"	,cCredPreIBS},;		// Codigo Credito Presumido IBS	
								{"DKM_ALQPRE"	,nAlCrePrIBS},;		// Aliquota Credito Presumido IBS	
								{"DKM_VLRPRE"	,nVlCrePrIBS},;		// Valor Credito Presumido IBS	
								{"DKM_VSPRE"	,0},;				// Vlr Suspensao Cred Presum
									{"DKM_ORIGEM"   ,"COMXCOL" }})		// Origem do lancamento		
		
				//IBSMun
				aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000061' )	
								{"DKM_DOC"		,cDoc},;			// Numero Documento             
								{"DKM_SERIE"	,cSerie},;			// Serie                    
								{"DKM_FORNEC"	,cFornCTe},;		// Fornecedor / Cliente     
								{"DKM_LOJA"		,cLojaCTe},;		// Loja                      
								{"DKM_TIPO"		, "T"	},;			// Tipo Nota                
								{"DKM_ESPECI"	,cEspecie},;			// Especie                  
								{"DKM_ITEM"		,nItemSDT	},;		// Item NF                  
								{"DKM_COD"		,cPrdFrete},;		// Produto                  
								{"DKM_TRIB"		,"IBSMun"},;		// Tributo / Imposto        
								{"DKM_XMLBAS"	,nBIBSCBS},;		// Base CBS/IBS NO XML	
								{"DKM_XMLALQ"	,nAIBSMun},;			// Aliquota IBS UF NO XML	
								{"DKM_XMLVLR"	,nVIBSMun},;			// Valor IBS UF NO XML	
								{"DKM_BASE"		,0},;				// Base CBS/IBS	
								{"DKM_ALIQ"		,0},;				// Aliquota IBS UF	
								{"DKM_VALOR"	,0},;				// Valor IBS UF	
								{"DKM_PDIF"		,nADIFIBSMun},;		// Aliquota Diferencial IBS UF	
								{"DKM_VDIF"		,nVDIFIBSMun},;		// Valor Diferencial IBS UF	
								{"DKM_VDEV"		,nVDEVIBSMun},;		// Valor Devolvido IBS UF	
								{"DKM_PREDAL"	,nAREDIBSMun},;		// Aliquota Reduzida Classifição Tributaria	
								{"DKM_PALIEF"	,nAREEIBSMun},;		// Aliquota Efetiva	
								{"DKM_CST"		,cCSTCBSIBS},;		// CST CBS/IBS	
								{"DKM_CLASTR"	,cClassTrib},;		// Classificação Tributaria	
								{"DKM_CSTRE"	,cCSTReg},;			// CST Regular (Seria se fosse)	
								{"DKM_CLAREG"	,cClasReg},;		// Classificação Tributaria (Seria se fosse)	
								{"DKM_ALQEFE"	,nAIBSMunReg},;		// Aliquota IBS UF (Seria se fosse)	
								{"DKM_VLREFE"	,nVIBSMunReg},;		// Valor IBS UF (Seria se fosse)	
								{"DKM_CODCRE"	,""},;		// Codigo Credito Presumido IBS	
								{"DKM_ALQPRE"	,0},;		// Aliquota Credito Presumido IBS	
								{"DKM_VLRPRE"	,0},;		// Valor Credito Presumido IBS	
								{"DKM_VSPRE"	,0},;				// Vlr Suspensao Cred Presum
								{"DKM_ORIGEM"   ,"COMXCOL" }})		// Origem do lancamento		

				//CBS
				aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000062' )	
								{"DKM_DOC"		,cDoc},;			// Numero Documento             
								{"DKM_SERIE"	,cSerie},;			// Serie                    
								{"DKM_FORNEC"	,cFornCTe},;		// Fornecedor / Cliente     
								{"DKM_LOJA"		,cLojaCTe},;		// Loja                        
								{"DKM_TIPO"		, "T"},;			// Tipo Nota                
								{"DKM_ESPECI"	,cEspecie},;			// Especie                  
								{"DKM_ITEM"		,nItemSDT	},;		// Item NF                  
								{"DKM_COD"		,cPrdFrete},;		// Produto                  
								{"DKM_TRIB"		,"CBS"},;			// Tributo / Imposto        
								{"DKM_XMLBAS"	,nBIBSCBS},;		// Base CBS/IBS NO XML	
								{"DKM_XMLALQ"	,nACBS},;			// Aliquota IBS UF NO XML	
								{"DKM_XMLVLR"	,nVCBS},;			// Valor IBS UF NO XML	
								{"DKM_BASE"		,0},;				// Base CBS/IBS	
								{"DKM_ALIQ"		,0},;				// Aliquota IBS UF	
								{"DKM_VALOR"	,0},;				// Valor IBS UF	
								{"DKM_PDIF"		,nADIFCBS},;		// Aliquota Diferencial IBS UF	
								{"DKM_VDIF"		,nVDIFCBS},;		// Valor Diferencial IBS UF	
								{"DKM_VDEV"		,nVDEVCBS},;		// Valor Devolvido IBS UF	
								{"DKM_PREDAL"	,nAREDCBS},;		// Aliquota Reduzida Classifição Tributaria	
								{"DKM_PALIEF"	,nAREECBS},;		// Aliquota Efetiva	
								{"DKM_CST"		,cCSTCBSIBS},;		// CST CBS/IBS	
								{"DKM_CLASTR"	,cClassTrib},;		// Classificação Tributaria	
								{"DKM_CSTRE"	,cCSTReg},;			// CST Regular (Seria se fosse)	
								{"DKM_CLAREG"	,cClasReg},;		// Classificação Tributaria (Seria se fosse)	
								{"DKM_ALQEFE"	,nACBSReg},;		// Aliquota IBS UF (Seria se fosse)	
								{"DKM_VLREFE"	,nVCBSReg},;		// Valor IBS UF (Seria se fosse)	
								{"DKM_CODCRE"	,cCredPreCBS},;		// Codigo Credito Presumido IBS	
								{"DKM_ALQPRE"	,nAlCrePrCBS},;		// Aliquota Credito Presumido IBS	
								{"DKM_VLRPRE"	,nVlCrePrCBS},;		// Valor Credito Presumido IBS	
								{"DKM_VSPRE"	,0},;				// Vlr Suspensao Cred Presum
								{"DKM_ORIGEM"   ,"COMXCOL" }})		// Origem do lancamento		
							
			Endif
			SDT->(DbSetOrder(8))
			If SDT->(DbSeek(xFilial("SDT")+cFornCTe+cLojaCTe+cDoc+cSerie+nItemSDT))
				For nX := 1 to len(aDadosDKM)
					AADD(aDadosDKM[nX], {"DKM_UIDSDT",SDT->DT_MSUID})
				Next
				If Len(aDadosDKM) > 0
					COMNEWIMP(aDadosDKM)
				Endif
			Endif

		EndIf	

		//Atualizar CLASFIS
		If lDTClasFis .And. !Empty(cCSTClas)
			A116ICLASFIS(cDoc,cSerie,cFornCTe,cLojaCTe,cCSTClas)
		Endif

		If lMt116XmlCt
			ExecBlock("Mt116XmlCt",.F.,.F.,{oXML,cDoc,cSerie,cFornCTe,cLojaCTe,"T","PF"})
		EndIf
	Else
		aAdd(aCabec116,{"",dDataBase-90})       												// Data inicial para filtro das notas
		aAdd(aCabec116,{"",dDataBase})          												// Data final para filtro das notas
		aAdd(aCabec116,{"",2})                  												// 2-Inclusao ; 1=Exclusao
		aAdd(aCabec116,{"",Space(TamSx3("F1_FORNECE")[1])}) 									// Rementente das notas contidas no conhecimento
		aAdd(aCabec116,{"",Space(TamSx3("F1_LOJA")[1])})
		aAdd(aCabec116,{"",IIf(lDevBen,2,1)})                  									// Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
		aAdd(aCabec116,{"",2})                  												// 1=Aglutina itens ; 2=Nao aglutina itens
		aAdd(aCabec116,{"F1_EST",""})  		  													// UF das notas contidas no conhecimento
		aAdd(aCabec116,{"",nVlrFrt}) 															// Valor do conhecimento
		aAdd(aCabec116,{"F1_FORMUL",1})															// Formulario proprio: 1=Nao ; 2=Sim
		aAdd(aCabec116,{"F1_DOC",PadR(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1])})		// Numero da nota de conhecimento
		aAdd(aCabec116,{"F1_SERIE",PadR(oXML:_InfCte:_Ide:_Serie:Text,SerieNfId("SF1",6,"F1_SERIE"))})	// Serie da nota de conhecimento
		aAdd(aCabec116,{"F1_FORNECE",cFornCTe}) 												// Fornecedor da nota de conhecimento
		aAdd(aCabec116,{"F1_LOJA",cLojaCTe})													// Loja do fornecedor da nota de conhecimento
		aAdd(aCabec116,{"",cTES_CT})															// TES a ser utilizada nos itens do conhecimento
		aAdd(aCabec116,{"F1_BASERET",nBaseICMS})												// Valor da base de calculo do ICMS retido
		aAdd(aCabec116,{"F1_ICMRET",nValICMS})													// Valor do ICMS retido
		aAdd(aCabec116,{"F1_COND",cCPag_CT})											   		// Condicao de pagamento
		aAdd(aCabec116,{"F1_EMISSAO",SToD(Substr(StrTran(oXML:_InfCte:_Ide:_dhEmi:Text,"-",""),1,8))}) // Data de emissao do conhecimento
		aAdd(aCabec116,{"F1_ESPECIE","CTE"})															 // Especie do documento
		aAdd(aCabec116,{"COLAB","S"})	
		
		If lAliqICMS
			aAdd(aCabec116,{"DT_PICM",nAliqICMS})
		EndIf												   				 // Chave para tratamentos especificos
		
		aAdd(aCabec116,{"F1_TPCTE",TIPOCTE116(oXML:_InfCte:_Ide:_tpCTe:Text)})				// Tipo do CT-e.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a ExecAuto do MATA116 para gravar os itens com o valor de frete rateado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lMsErroAuto    := .F.
		lAutoErrNoFile := .T.
		MsExecAuto({|x,y,z| MATA116(x,y,,z)},aCabec116,aItens116,lPreNota)
		
		If lMsErroAuto
			//-- Desfaz transacao
			DisarmTran()
	 		If lJob
	 			aAux := GetAutoGRLog()
	 			For nX := 1 To Len(aAux)
		 			cError += aAux[nX]
		 		Next nX
		 		aAdd(aErros,{cFile,"COM024 - " + cError,STR0019}) //"Corrija a inconsistência apontada no log."
			Else
				MostraErro()
			EndIf
			aAdd(aErroErp,{cFile,"COM024"})
			lRet := .F.
		Else
			//Atualizar CLASFIS
			If lDTClasFis .And. !Empty(cCSTClas)
				A116ICLASFIS(cDoc,cSerie,cFornCTe,cLojaCTe,cCSTClas)
			Endif

			if lNatRen
				A116GrvNat(cDoc,cSerie,cFornCTe,cLojaCTe,cChaveNF)
			endif

			If lMt116XmlCt
				ExecBlock("Mt116XmlCt",.F.,.F.,{oXML,cDoc,cSerie,cFornCTe,cLojaCTe,"T","PN"})
			EndIf
		EndIf
	EndIf
	
	End Transaction
EndIf

If lRet
	aAdd(aProc,{	PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0"),;
					PadR(oXML:_InfCte:_Ide:_Serie:Text,SerieNfId("SF1",6,"F1_SERIE")),;
					cNomeCTe})
Endif

oXML := Nil

FwFreeArray(aGrvCTeSimp)
FwFreeArray(aChvF2)
FwFreeArray(aChvQryF2)
FwFreeArray(aRota)

DelClassIntf()

DisarmTran()
Return lRet

/*/{Protheus.doc}CTe_VldEmp
Verifica se o XML deve ser processado pela empresa.

@param	oXml: XML do arquivo CTe.
@param	cCNPJ_CPF: CNPJ/CPF da empresa que ira processar.

@return lRet: indica se o arquivo deve ser processado.

@author Andre Anjos
@since  08/06/12
/*/

Function CTe_VldEmp(oXML,cCNPJ_CPF,lToma3Dest,lToma4,lJob,cFile,aErros,aErroErp,lT4DifDest,lT3Exped,lT3Remet,aErros,aErroErp,lCTeOS,cTipoFrete,lToma3Rec,lCTeSimp)
Local lRet 	   	:= .T.
Local cTagRem  	:= If(ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O", If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF"),"")
Local cTagDest 	:= If(ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O",If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF"),"")
Local cIERem   	:= If(ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O", If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_IE")) == "O","_IE",""),"")
Local cIEDest  	:= If(ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O",If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_IE")) == "O","_IE",""),"")
Local cTagToma4	:= ""
Local cTagRec	:= ""
Local cTagExp	:= ""
Local aDirFilial:= {}
Local cTag		:= ""
Local cIE		:= ""
Local cT4DstCNPJ:= ""
Local cT4DstIE	:= ""
Local cT4RemCNPJ:= ""
Local cT4RemIE	:= ""
Local cTagToma3	:= ""
Local cTgTom3	:= ""
Local lTpFrete		:= .F.
Local cT3DstCNPJ	:= ""
Local cT3DstIE		:= ""
Local cT3RemCNPJ	:= ""
Local cT3RemIE		:= ""

DEFAULT lToma3Dest	:= .F.
DEFAULT lToma3Rec 	:= .F.
DEFAULT lToma4	 	:= .F.
DEFAULT aErros		:= {}
DEFAULT aErroErp	:= {}
DEFAULT lCteOS		:= .F.
DEFAULT lCTeSimp	:= .F.

If ValType(oXML) == "U"
	lRet := .F.
Endif

If lRet .And. !lCteOS .And. !lCTeSimp
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA03")) <> "U"
		cTagToma3	:= AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text)
		cTgTom3	:= "_TOMA03"
	Elseif ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA3")) <> "U"
		cTagToma3	:= AllTrim(oXML:_InfCte:_Ide:_Toma3:_TOMA:Text)
		cTgTom3	:= "_TOMA3"
	Endif
	
	If lRet
		If ValType(XmlChildEx(oXML:_InfCte:_Ide,cTgTom3)) <> "U" 
			If cTagToma3 == "0" //Remetente
				If ValType(XmlChildEx(oXML:_InfCte:_Rem,cTagRem)) == "O"
					cTag 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)
				EndIf
				
				If ValType(XmlChildEx(oXML:_InfCte:_Rem,cIERem)) == "O"
					cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text)
				EndIf
				lT3Remet := .T.
				cTipoFrete := "R"
			ElseIf cTagToma3 == "1" //Expedidor
				cTagExp := If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
				
				If ValType(XmlChildEx(oXML:_InfCte:_Exped,cTagExp)) == "O"
					cTag 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,cTagExp):Text)
				EndIf
				
				If ValType(XmlChildEx(oXML:_InfCte:_Exped,"_IE")) == "O"
					cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,"_IE"):Text)
				EndIf
				lT3Exped := .T.

				//Valida se Expedidor é igual a Destinatario e/ou Remetente
				If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
					cT3DstCNPJ	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
				EndIF
				
				If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
					cT3DstIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
				EndIF

				If ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Rem,cTagRem)) == "O"
					cT3RemCNPJ	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)
				EndIF
				
				If ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Rem,cIERem)) == "O"
					cT3RemIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text)			
				EndIF

				If !Empty(cT3DstCNPJ) .And. !Empty(cT3DstIE)
					If cTag == cT3DstCNPJ .And. cIE == cT3DstIE
						cTipoFrete := "D"
						lTpFrete := .T.
					Endif
				Endif

				If !Empty(cT3RemCNPJ) .And. !Empty(cT3RemIE)
					If cTag == cT3RemCNPJ .And. cIE == cT3RemIE
						cTipoFrete := "R"
						lTpFrete := .T.
					Endif
				Endif

				If !lTpFrete
					cTipoFrete := "T" //Terceiros
				Endif
			ElseIf cTagToma3 == "2" //Recebedor
				cTagRec := If(ValType(XmlChildEx(oXML:_InfCte:_Receb,"_CNPJ")) == "O","_CNPJ","_CPF")
				
				If ValType(XmlChildEx(oXML:_InfCte:_Receb,cTagRec)) == "O"
					cTag 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Receb,cTagRec):Text)
				EndIf
				
				If ValType(XmlChildEx(oXML:_InfCte:_Receb,"_IE")) == "O"
					cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Receb,"_IE"):Text)
				EndIf

				//Valida se Expedidor é igual a Destinatario e/ou Remetente
				If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
					cT3DstCNPJ	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
				EndIF
				
				If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
					cT3DstIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
				EndIF

				If ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Rem,cTagRem)) == "O"
					cT3RemCNPJ	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)
				EndIF
				
				If ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Rem,cIERem)) == "O"
					cT3RemIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text)			
				EndIF

				lToma3Rec := .T.

				If !Empty(cT3DstCNPJ) .And. !Empty(cT3DstIE)
					If cTag == cT3DstCNPJ .And. cIE == cT3DstIE
						cTipoFrete := "D"
						lTpFrete := .T.
					Endif
				Endif

				If !Empty(cT3RemCNPJ) .And. !Empty(cT3RemIE)
					If cTag == cT3RemCNPJ .And. cIE == cT3RemIE
						cTipoFrete := "R"
						lTpFrete := .T.
					Endif
				Endif

				If !lTpFrete
					cTipoFrete := "T" //Terceiros
				Endif
			ElseIf cTagToma3 == "3" //Destinatario
				lToma3Dest := .T.	// Destinatario da nota no processo de transferencia entre filiais
				
				If ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
					cTag 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
				EndIF
				
				If ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
					cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
				EndIF
				cTipoFrete := "D"
			EndIf
		ElseIf ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA4")) <> "U"
			If AllTrim(oXML:_InfCte:_Ide:_Toma4:_TOMA:Text) == "4"
				cTagToma4 := If(ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_CNPJ")) == "O","_CNPJ","_CPF")
				lToma4 := .T.
				
				If ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4)) == "O"
					cTag 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4):Text)
				EndIf
				
				If ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_IE")) == "O"
					cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_IE"):Text)
				EndIf
				
				//Valida se Toma4 é igual a Destinatario
				If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
					cT4DstCNPJ	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
				EndIF
				
				If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
					cT4DstIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
				EndIF

				If ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Rem,cTagRem)) == "O"
					cT4RemCNPJ	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)
				EndIF
				
				If ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Rem,cIERem)) == "O"
					cT4RemIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text)			
				EndIF
				
				If !Empty(cT4DstCNPJ)
					If cTagDest == "_CNPJ" .OR. Empty(cTagDest)
						If cTag <> cT4DstCNPJ .Or. cIE <> cT4DstIE
							lT4DifDest := .T.
						Endif
					Else//CPF 
						If cTag <> cT4DstCNPJ
							lT4DifDest := .T.
						Endif
					Endif

					If cTag == cT4DstCNPJ .And. cIE == cT4DstIE
						cTipoFrete := "D"
						lTpFrete := .T.
					Endif
				Endif

				If !Empty(cT4RemCNPJ) .And. !Empty(cT4RemIE)
					If cTag == cT4RemCNPJ .And. cIE == cT4RemIE
						cTipoFrete := "R"
						lTpFrete := .T.
					Endif
				Endif

				If !lTpFrete
					cTipoFrete := "T" //Terceiros
				Endif
			EndIf
		Else //Se o xml não possui as tags Toma3 e Toma4, o documento será processado na filial do destinatario
			If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
				cTag 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
			EndIF
			
			If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
				cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
			EndIF
			cTipoFrete := "D"
		EndIf
		
		aDirFilial := DirFilial(cFile,cTag,cIE,lJob)
		
		If !aDirFilial[1]
			If !aDirFilial[2]	
				If !lJob
					If aDirFilial[3]
						Aviso(STR0001,STR0044,{"OK"},2,"ImpXML_CTe")	//"Erro"#""Existe mais de uma Empresa/Filial para este XML." "#"OK"
					ElseIf aDirFilial[4]
						Aviso(STR0001,STR0051,{"OK"},2,"ImpXML_CTe")	//"Erro"#""Este XML não pertence a nenhuma empresa/filial e não podera ser processado.""#"OK"
					Else
						Aviso(STR0001,STR0002,{"OK"},2,"ImpXML_CTe")	//"Erro"#""Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente." "#"OK"
					EndIf
				Else
					If aDirFilial[3]
						aAdd(aErros,{cFile,"COM042 - " + STR0044,Iif(lImpXML,STR0048,STR0045)}) // Existe mais de uma Empresa/Filial para este XML. // Selecione a Empresa/Filial deste XML através da rotina Reprocessar no Monitor do TOTVS Colaboração.
						aAdd(aErroErp,{cFile,"COM042"})
					ElseIf aDirFilial[4]
						aAdd(aErros,{cFile,"COM052 - " + STR0051,STR0052}) //"Este XML não pertence a nenhuma empresa/filial e não podera ser processado." //"Verificar se XML pertence a empresa"
						aAdd(aErroErp,{cFile,"COM052"})
					Else
						aAdd(aErros,{cFile,"COM002 - " + STR0002,STR0043}) // Este XML pertence a outra empresa/filial e não poderá ser processado na empresa/filial corrente. // Importe na Empresa/Filial correta.
						aAdd(aErroErp,{cFile,"COM002"})  
					EndIf
				EndIf
				lRet := .F.	
			Else
				aAdd(aErros,{cFile,"COM002 - " + STR0002,STR0043}) // Este XML pertence a outra empresa/filial e não poderá ser processado na empresa/filial corrente. // Importe na Empresa/Filial correta.
				aAdd(aErroErp,{cFile,"COM002"})
				lRet := .F.
			Endif
		Else
			lRet := .T.
		Endif
	Endif
	
	//Valida se o CT-e deve ser importado na filial remetente ou na filial destinataria
	//para o caso de ser uma operacao de transferencia entre filiais
	
	//Validacao efetuada pela tag TOMA03 conforme Manual do Conhecimento de Transporte Eletronico
	//Versao 1.0.4c - Abril/2012, que identifica quem e o tomador do servico, sendo:
	//0-Remetente
	//1-Expedidor
	//2-Recebedor
	//3-Destinatario
	
	If ValType(oXML) == "U"
		lRet := .F.
	Endif
	If lRet
		If ValType(XmlChildEx(oXML:_InfCte:_Ide,cTgTom3)) <> "U"
			If cTagToma3 == "0"
				If AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text) == AllTrim(cCNPJ_CPF)
					lRet := .T.
				Else 
					lRet := .F.
				EndIf
			ElseIf cTagToma3 == "1"
				cTagExp := If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
				If AllTrim(XmlChildEx(oXML:_InfCte:_Exped,cTagExp):Text) == AllTrim(cCNPJ_CPF)
					lRet := .T.
				Else 
					lRet := .F.
				EndIf
			ElseIf cTagToma3 == "2"
				cTagRec := If(ValType(XmlChildEx(oXML:_InfCte:_Receb,"_CNPJ")) == "O","_CNPJ","_CPF")
				If AllTrim(XmlChildEx(oXML:_InfCte:_Receb,cTagRec):Text) == AllTrim(cCNPJ_CPF)
					lRet := .T.
				Else 
					lRet := .F.
				EndIf
			ElseIf cTagToma3 == "3"
				lToma3Dest := .T.					// Destinatario da nota no processo de transferencia entre filiais
				If AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) != AllTrim(cCNPJ_CPF)
					lRet := .F.
				EndIf
			EndIf
		EndIf
		
		//Validacao para tag TOMA4 quando a empresa nao e Remetente, Expedidor, Recebedor nem
		//Destinatario
		If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA4")) <> "U"
			If AllTrim(oXML:_InfCte:_Ide:_Toma4:_TOMA:Text) == "4"
				cTagToma4 := If(ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_CNPJ")) == "O","_CNPJ","_CPF")
				lToma4 := .T.
				If AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4):Text) == AllTrim(cCNPJ_CPF)
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf
		
		If !lRet
			If !lJob
				Aviso(STR0001,STR0002,{"OK"},2,"ImpXML_CTe")//"Erro"#"Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente."
			EndIf
			aAdd(aErros,{cFile,"COM002 - " + STR0002,""})
			aAdd(aErroErp,{cFile,"COM002"})
		Endif
	Endif
	
Elseif lRet .And. (lCteOS .Or. lCTeSimp)
	If ValType(XmlChildEx(oXML:_InfCte,"_TOMA")) <> "U"
		cTagCGC := If(ValType(XmlChildEx(oXML:_InfCte:_Toma,"_CNPJ")) == "O","_CNPJ","_CPF")
			
		If ValType(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC)) == "O"
			cTag 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC):Text)
		EndIf
		
		If ValType(XmlChildEx(oXML:_InfCte:_Toma,"_IE")) == "O"
			cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,"_IE"):Text)
		EndIf

		If lCteOS
			cTipoFrete := "D"
		Elseif lCTeSimp
			If ValType(XmlChildEx(oXML:_InfCte:_Toma,"_TOMA")) <> "U" 
				If AllTrim(oXML:_InfCte:_Toma:_Toma:Text) $ "1|2|4"
					cTipoFrete := "T"
				Elseif AllTrim(oXML:_InfCte:_Toma:_Toma:Text) = "0"
					cTipoFrete := "R"
				Elseif AllTrim(oXML:_InfCte:_Toma:_Toma:Text) = "3"
					cTipoFrete := "D"
				Endif
			Endif
		Endif
	EndIf

	aDirFilial := DirFilial(cFile,cTag,cIE,lJob)
	
	If !aDirFilial[1] 
		If !aDirFilial[2]
			cMsgAviso 	:= Iif(aDirFilial[3],STR0044,Iif(aDirFilial[4],STR0051,STR0002))
			cMsgJob 	:= Iif(aDirFilial[3],"COM042 - " + STR0044,Iif(aDirFilial[4],"COM052 - " + STR0051,"COM002 - " + STR0002))
			cMsgSolJob	:= Iif(aDirFilial[3],Iif(lImpXML,STR0048,STR0045),Iif(aDirFilial[4],STR0052,STR0043))
			cCodErr		:= Iif(aDirFilial[3],"COM042",Iif(aDirFilial[4],"COM052","COM002"))

			ImpXMLErr(lJob,cFile,@aErros,cMsgJob,cMsgAviso,cMsgSolJob,cCodErr,@aErroERP)

			//lJob = F
			//aDirFilial[3] -> "Erro"#""Existe mais de uma Empresa/Filial para este XML." "#"OK"
			//aDirFilial[4] -> "Erro"#""Este XML não pertence a nenhuma empresa/filial e não podera ser processado." "#"OK"
			//"Erro"#""Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente." "#"OK"

			//lJob = T
			//aDirFilial[3] -> Existe mais de uma Empresa/Filial para este XML. // Selecione a Empresa/Filial deste XML através da rotina Reprocessar no Monitor do TOTVS Colaboração.
			//aDirFilial[4] -> "Este XML não pertence a nenhuma empresa/filial e não podera ser processado." //"Verificar se XML pertence a empresa"
			// Este XML pertence a outra empresa/filial e não poderá ser processado na empresa/filial corrente. // Importe na Empresa/Filial correta.
			lProces:= .F. 
		Else
			// Este XML pertence a outra empresa/filial e não poderá ser processado na empresa/filial corrente. // Importe na Empresa/Filial correta.
			ImpXMLErr(lJob,cFile,@aErros,"COM002 - " + STR0002,"",STR0043,"COM002",@aErroERP)
			lProces  := .F.
		Endif
	Endif
Endif

Return lRet

/*/{Protheus.doc}CTe_RetTES
Funcao que retorna TES e cond. pagto para utilizacao no CTe

@param	oXml: objeto com o XML do CTe
@param	cTES_CT: variavel que recebera o codigo da TES (referencia)
@param	cCPag_CT: variavel que recebera o codigo da cond pagto.

@author Andre Anjos
@since  06/08/12
/*/

Function CTe_RetTES(oXML,cTES_CT,cCPag_CT)
Local aAux 	   := {}

Default oXML   	 := NIL 
Default cTES_CT  := ""
Default cCPag_CT := ""

cTES_CT  := PadR(SuperGetMV("MV_XMLTECT",.F.,""),TamSX3("F4_CODIGO")[1])
cCPag_CT := PadR(SuperGetMV("MV_XMLCPCT",.F.,""),TamSX3("E4_CODIGO")[1])

SF4->(dbSetOrder(1))
SDS->(dbSetOrder(2))

//-- Ponto de entrada para alterar a TES a utilizar no CTe
If ExistBlock("A116TECT")
	aAux := ExecBlock("A116TECT",.F.,.F.,{oXML})
	If ValType(aAux[1]) == "C" .And. !Empty(aAux[1]) .And. SF4->(dbSeek(xFilial("SF4")+aAux[1]))
		cTES_CT := aAux[1]
	EndIf
	If ValType(aAux[2]) == "C" .And. !Empty(aAux[2]) .And. SE4->(dbSeek(xFilial("SE4")+aAux[2]))
		cCPag_CT := aAux[2]
	EndIf
EndIf

Return 

/*/{Protheus.doc}A116ICLIFOR
Verifica o fornecedor do conhecimento de frete

@param	c116CNPJ: CNPJ
@param	c116INSC: IE
@param	c116Alias: Alias (SA2 ou SA1)
@param	aFilDest: Filiais destino
@param	oXML: oXML do CT-e
@param	cBusca116: CNPJ/CPF da empresa que ira processar.

@author Andre Anjos
@since  08/06/12
/*/

Static Function A116ICLIFOR(c116CNPJ,c116INSC,c116Alias,aFilDest,oXML,cBusca116)

Local aRet			:= {}
Local aAuxFor		:= {}
Local aArea			:= {}
Local c116Fil		:= xFilial(c116Alias)
Local cCodigo		:= ""
Local cLoja			:= ""
Local cNomeFor		:= ""
Local nQCNPJ		:= 0
Local nQINSC		:= 0
Local lAchoCliFor	:= .F.
Local lCliente		:= .F.
Local nBloq			:= 0
Local lBloq      	:= .F.
Local cCodBlq		:= ""
Local cLojBlq		:= ""
Local cNomFBlq		:= ""
Local cCliFor		:= ""

Default cBusca116 := ''

aArea := GetArea()

If c116Alias == "SA2"
	cCliFor := "F"
Elseif c116Alias == "SA1"
	cCliFor := "C"
Endif

DbSelectArea(c116Alias)
(c116Alias)->(DbSetOrder(3))

If (c116Alias)->(DbSeek(c116Fil+c116CNPJ))
	While !(c116Alias)->(EOF()) .And. c116CNPJ $ A140ICAES((c116Alias)->&(Substr(c116Alias,2,2)+"_CGC"))
		// Validacao para cliente ou fornecedor bloqueado.
		If (c116Alias)->&(Substr(c116Alias,2,2)+"_MSBLQL") == "1" .And. (A140INSC(c116INSC,(c116Alias)->&(Substr(c116Alias,2,2)+"_INSCR")) .Or. Empty(A140ICAES(Alltrim((c116Alias)->&(Substr(c116Alias,2,2)+"_INSCR")))))
			cCodBlq		:= (c116Alias)->&(Substr(c116Alias,2,2)+"_COD")
			cLojBlq		:= (c116Alias)->&(Substr(c116Alias,2,2)+"_LOJA")
			cNomFBlq	:= (c116Alias)->&(Substr(c116Alias,2,2)+"_NOME")
			nBloq++
		ElseIf (c116Alias)->&(Substr(c116Alias,2,2)+"_MSBLQL") <> "1" .And. (A140INSC(c116INSC,(c116Alias)->&(Substr(c116Alias,2,2)+"_INSCR")) .Or. Empty(A140ICAES(Alltrim((c116Alias)->&(Substr(c116Alias,2,2)+"_INSCR")))))
			If A140INSC(c116INSC,(c116Alias)->&(Substr(c116Alias,2,2)+"_INSCR"))  
				cCodigo 	:= (c116Alias)->&(Substr(c116Alias,2,2)+"_COD")
				cLoja   	:= (c116Alias)->&(Substr(c116Alias,2,2)+"_LOJA")
				cNomeFor 	:= (c116Alias)->&(Substr(c116Alias,2,2)+"_NOME")
				nQCNPJ++
				nQINSC++
				lAchoCliFor := .T.
			ElseIf Empty(A140ICAES(Alltrim((c116Alias)->&(Substr(c116Alias,2,2)+"_INSCR")))) .And. nQINSC = 0
				cCodigo	:= (c116Alias)->&(Substr(c116Alias,2,2)+"_COD")
				cLoja		:= (c116Alias)->&(Substr(c116Alias,2,2)+"_LOJA")
				cNomeFor 	:= (c116Alias)->&(Substr(c116Alias,2,2)+"_NOME")
				nQCNPJ++
				lAchoCliFor := .T.
			ElseIf Empty(A140ICAES(Alltrim((c116Alias)->&(Substr(c116Alias,2,2)+"_INSCR")))) .And. nQINSC <> 0 
				nQCNPJ++
				lAchoCliFor := .T.
			ElseIf Empty(c116INSC) // Caso nao tenha a TAG <IE> no XML ou a mesma venha vazia.
				cCodigo		:= (c116Alias)->&(Substr(c116Alias,2,2)+"_COD")
				cLoja		:= (c116Alias)->&(Substr(c116Alias,2,2)+"_LOJA")
				cNomeFor 	:= (c116Alias)->&(Substr(c116Alias,2,2)+"_NOME")
				nQCNPJ++
				lAchoCliFor := .T.
			EndIf
		EndIf
		(c116Alias)->(DbSkip())
	EndDo
	
	If nQCNPJ > 1 .And. nQINSC <> 1 .And. ExistBlock("A116IFor")
		aAuxFor := ExecBlock("A116IFor",.F.,.F.,{oXML, c116Alias, cBusca116})
		If	Len(aAuxFor) == 3 .And.;
			ValType(aAuxFor[1]) == "C" .And. !Empty(aAuxFor[1]) .And. (aAuxFor[1] $ "SA1#SA2") .And.;
			ValType(aAuxFor[2]) == "C" .And. !Empty(aAuxFor[2]) .And.;
			ValType(aAuxFor[3]) == "C" .And. !Empty(aAuxFor[3])
			
			c116Alias	:= aAuxFor[1]
			cCodigo		:= Padr(aAuxFor[2],TamSX3("A2_COD")[1])
			cLoja		:= Padr(aAuxFor[3],TamSX3("A2_LOJA")[1])
			
			If c116Alias == "SA1" .Or. c116Alias == "SA2"
				(c116Alias)->(dbSetOrder(1))
				If (c116Alias)->(dbSeek(xFilial(c116Alias)+cCodigo+cLoja))
					If c116Alias $ "SA1"
						cCodigo		:= SA1->A1_COD
						cLoja		:= SA1->A1_LOJA
						lCliente	:= .T.
						nQCNPJ 		:= 1
						nQINSC 		:= 1
						lAchoCliFor	:= .T.
					Else
						cCodigo		:= SA2->A2_COD
						cLoja		:= SA2->A2_LOJA
						nQCNPJ		:= 1
						nQINSC		:= 1
						lAchoCliFor	:= .T.
					EndIf
				EndIf
			EndIf
		EndIf
	Endif
Endif

If !lAchoCliFor .And. nBloq > 0
	lBloq		:= .T.
	cCodigo	:= cCodBlq
	cLoja		:= cLojBlq
Endif

If (nQCNPJ > 1 .And. nQINSC <> 1) .Or. lBloq
	aAdd(aRet,{.F.,cCodigo,cLoja,lCliente,lBloq,cCliFor})
ElseIf lAchoCliFor
	aAdd(aRet,{.T.,cCodigo,cLoja,lCliente,lBloq,cCliFor})
EndIf

RestArea(aArea)

Return aRet

/*/{Protheus.doc}TIPOCTE116
Converte as opcoes do campo F1_TPCTE em relacao ao XML do CT-e

@author Ciro Pedreira Data
@since  16/05/2016
/*/

Function TIPOCTE116(cTpCte)

Local cRet := ''
Local aOpc := {}
Local nPos := 0

// Neste momento é realizado um De/Para das opcoes, pois o XML da Fazenda trabalha com numeros
// e o Protheus com letras no campo F1_TPCTE.
AAdd(aOpc, {'0', 'N'})
AAdd(aOpc, {'1', 'C'})
AAdd(aOpc, {'2', 'A'})
AAdd(aOpc, {'3', 'S'})
AAdd(aOpc, {'5', 'R'}) //CTE Simplificado

nPos := AScan(aOpc, {|o| o[1] == AllTrim(cTpCte) })

If nPos > 0
	
	cRet := aOpc[nPos][2]
	
EndIf 

Return cRet

/*/{Protheus.doc}A116IFOCL
Busca pelo fornecedor/cliente da nf origem.

@param	aDadosAux: Array com os dados do fornecedor/cliente
@param	cTipo: "F" - Fornecedor, "C" - Cliente

@return aRet: array com os dados do fornecedor ou cliente

@author Rodrigo Pontes
@since  16/05/17
/*/

Static Function A116IFOCL(aDadosAux,cTipo)

Local aRet	:= {}
Local nPos	:= 0

nPos := aScan(aDadosAux,{|x| x[6] == cTipo})
If nPos > 0
	aRet := aDadosAux[nPos]
Endif

Return aRet

Function ImpXMLCteOS(cFile,lJob,aProc,aErros,oXml,aErroErp,oXMLCanc)

Local cPrdFrete  	:= ""
Local lRet       	:= .T.
Local nX		 	:= 0
Local nPesoBruto 	:= 0
Local nPesoLiqui 	:= 0    
Local nPos			:= 0
Local cCNPJ_CT	 	:= ""
Local cFornCTe  	:= ""
Local cLojaCTe   	:= ""
Local cNomeCTe   	:= ""
Local cTES_CT 	 	:= ""
Local cCPag_CT 	 	:= ""
Local cTipoFrete 	:= ""
Local cRetPrd	 	:= ""
Local cMotivo		:= ""
Local cTxtErro		:= ""
Local aDadosAux  	:= {}
Local aAux		 	:= {}
Local aEspecVol  	:= {}
Local aAux1		 	:= {}
Local aParamPE	 	:= {}
Local lMt116XmlCt	:= ExistBlock("MT116XMLCT")
Local lA116ITPCT 	:= ExistBlock("A116ITPCT")
Local cTpCte 		:= ""
Local cDoc			:= ""
Local cSerie		:= ""
Local aA116IDOC		:= {}
Local cChvNFOr		:= ""
Local aExcStat 		:= {"100","102","103","104","105","106","107","108","109","110","111","112","113","114","134","135","136","301"}
Local cHrEmis		:= ""
Local lVlrFrtZero	:= .F.
Local nVlrFrt		:= 0
Local cUFOrigem		:= ""
Local cMunOrigem	:= ""
Local cUFDestino	:= ""
Local cMunDestin	:= ""
Local lPreNota		:= !SuperGetMV("MV_CTECLAS",.F.,.F.) 
Local nZ			:= 0
Local nBaseICMS 	:= 0
Local nValICMS		:= 0
Local nAliqICMS		:= 0
Local lBaseICMS 	:= .F.
Local lValICMS		:= .F.
Local lAliqICMS		:= .F.
Local lUnidMed		:= SDT->(ColumnPos("DT_UM")) > 0 .And. SDT->(ColumnPos("DT_SEGUM")) > 0 .And. SDT->(ColumnPos("DT_QTSEGUM")) > 0
Local oICMS
Local oICMSTipo
Local oICMSNode
Local cCSTClas		:= ""
Local lDTClasFis	:= SDT->(FieldPos("DT_CLASFIS")) > 0
Local lVlrCte		:= SuperGetMv("MV_VLRCTE",.F.,.F.)
local lNatRen       := SDT->(FieldPos("DT_NATREN")) > 0  //Natureza de Rendimento
Local lTabDKM		:= ChkFile("DKM")
Local nItemSDT		:= 0
Local aDadosDKM		:= {}
Local cClassTrib	:= ""
Local cCSTCBSIBS	:= ""
Local nBIBSCBS		:= 0
Local nAIBSUF 		:= 0
Local nVIBSUF		:= 0
Local nADIFIBSUF	:= 0
Local nVDIFIBSUF	:= 0
Local nVDEVIBSUF	:= 0
Local nAREDIBSUF	:= 0
Local nAREEIBSUF	:= 0
Local nAIBSMUN		:= 0
Local nVIBSMUN		:= 0
Local nADIFIBSMUN	:= 0
Local nVDIFIBSMUN	:= 0
Local nVDEVIBSMUN	:= 0
Local nAREDIBSMUN	:= 0
Local nAREEIBSMUN	:= 0
Local nACBS			:= 0
Local nVCBS			:= 0
Local nADIFCBS		:= 0
Local nVDIFCBS		:= 0
Local nVDEVCBS		:= 0
Local nAREDCBS		:= 0
Local nAREECBS		:= 0
Local cCSTReg		:= ""
Local cClasReg		:= ""
Local nAIBSUFReg	:= 0
Local nVIBSUFReg	:= 0
Local nAIBSMunReg	:= 0
Local nVIBSMunReg	:= 0
Local nACBSReg		:= 0
Local nVCBSReg		:= 0
Local cCredPreIBS	:= ""
Local nAlCrePrIBS	:= 0
Local nVlCrePrIBS	:= 0
Local cCredPreCBS	:= ""
Local nAlCrePrCBS	:= 0
Local nVlCrePrCBS	:= 0


Private lImpXML	 	:= SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Private lImpXTra	:= Iif(FindFunction("ImpXTra"),ImpXTra(),.F.)

Default lJob    	:= .T. 
Default aProc   	:= {}
Default aErros  	:= {} 
Default aErroERP 	:= {} 

//-- Verifica se o arquivo pertence a filial corrente
lRet := CTe_VldEmp(oXML,SM0->M0_CGC,.F.,.F.,lJob,cFile,,,.F.,.F.,.F.,@aErros,@aErroERP,.T.,@cTipoFrete)

//Verifica se XML é Cancelado ou Rejeitado.
If lRet .And. ValType(oXMLCanc) <> "U"
	If Valtype(XmlChildEx(oXMLCanc:_infProt,"_CSTAT")) <> "U"
		//Chave CT-e
		cChaveCte	:= Right(AllTrim(oXMLCanc:_infProt:_chCte:Text),44)
		
		//Motivo rejeição
		If Valtype(XmlChildEx(oXMLCanc:_infProt,"_XMOTIVO")) <> "U"
			cMotivo := ConvASC(oXMLCanc:_infProt:_xMotivo:Text)  
		Endif
		
		//Busca status
		nPos := aScan(aExcStat,AllTrim(oXMLCanc:_infProt:_cStat:Text))
		
		//Status de cancelado ou rejeitado
		If nPos == 0
			If AllTrim(oXMLCanc:_infProt:_cStat:Text) == "101" //Cancelado
				If !lJob
					Aviso(STR0001,"CTEOS cancelado: " + cChaveCte,{"OK"},2,"ImpXML_CTe")//"Erro"#"CT-e cancelado
				EndIf
				
				aAdd(aErros,{cFile,"COM045 - CTEOS cancelado: " + cChaveCte,""})
				aAdd(aErroErp,{cFile,"COM045"})
				
				lRet := .F.
			Else //Rejeitado
				If !lJob
					Aviso(STR0001,"CTEOS rejeitado: " + cChaveCte + " - Motivo: " + cMotivo,{"OK"},2,"ImpXML_CTe")//"Erro"#"CT-e cancelado
				EndIf
				
				aAdd(aErros,{cFile,"COM046 - CTEOS rejeitado: " + cChaveCte + " - Motivo: " + cMotivo,""})
				aAdd(aErroErp,{cFile,"COM046"})
				lRet := .F.
			Endif	
		Endif
	Endif
	
	If Valtype(XmlChildEx(oXMLCanc:_infProt,"_DHRECBTO")) <> "U"
		cHrEmis := Substr(oXMLCanc:_infProt:_DhRecbto:Text,12)
	Endif
Endif
                                      
//-- Verifica se o ID ja foi processado
If lRet
	SDS->(dbSetOrder(2))
	If lRet .And. SDS->(dbSeek(xFilial("SDS")+Right(AllTrim(oXML:_InfCte:_Id:Text),44)))
		If lJob
			aAdd(aErros,{cFile,"COM019 - " + STR0003 +SDS->(DS_DOC+"/"+SerieNfId('SDS',2,'DS_SERIE')); //"ID de CT-e já registrado na NF "
							 + STR0004 + " (" +SDS->(DS_FORNEC +"/" +DS_LOJA)+ ").",STR0005}) //"do Fornecedor/Cliente "#"Exclua o documento registrado na ocorrência."
		Else 
			Aviso(STR0001,STR0003 +SDS->(DS_DOC+"/"+SerieNfId('SDS',2,'DS_SERIE'));
								 + STR0004 + SDS->(DS_FORNEC+"/"+DS_LOJA) +".",{"OK"},2,"ImpXML_CTe")
		EndIf
		aAdd(aErroErp,{cFile,"COM019"})
		lRet := .F.
	EndIf
EndIf

//-- Verifica se o fornecedor do conhecimento esta cadastrado no sistema.
If lRet
	If ValType(XmlChildEx(oXML:_InfCte:_Emit,"_CNPJ")) <> "U"
		cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CNPJ:Text)
	Else
		cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CPF:Text)
	EndIf
	
	// Envio das letras E, D ou R pela funcao A116ICLIFOR. E = Emitente, D = Destinatario e R = Remetente.
	// Essa informacao sera utilizada no P.E. A116IFOR.
	aDadosAux := A116ICLIFOR(cCNPJ_CT,AllTrim(oXML:_InfCte:_Emit:_IE:Text),"SA2",,oXML,'E')
	
	If Len(aDadosAux) == 0 
		If lImpXTra .And. FindFunction("ImpCadAutF")
			aImpCadAut	:= ImpCadAutF(oXML,"116IO","N")
			lRet 	:= aImpCadAut[1]

			If !lRet
				//"Fornecedor/Cliente"#"inexistente na base."#"Gere cadastro para este fornecedor/cliente."
				ImpXMLErr(lJob,cFile,@aErros,"COM007 - " + STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007 + aImpCadAut[5],STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007,STR0008,"COM007",@aErroErp,"ImpXMLCTeOS")
			Else
				cFornCTe 	:= aImpCadAut[2]
				cLojaCTe 	:= aImpCadAut[3]
				cNomeCTe	:= aImpCadAut[4]
				cStatusAut	:= "B"
			Endif
		Else
			lRet := .F.
			//"Fornecedor/Cliente"#"inexistente na base."#"Gere cadastro para este fornecedor/cliente."
			ImpXMLErr(lJob,cFile,@aErros,"COM007 - " + STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007,STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0007,STR0008,"COM007",@aErroErp,"ImpXMLCTeOS")
		Endif
	ElseIf !aDadosAux[1,1] .And. aDadosAux[1,5] // Se encontrou o cadastro e o mesmo esta bloqueado.
		cTxtErro := "COM030 - " + STR0006 + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0037 + STR0038 //"Fornecedor"#"bloqueado."#"Realize o desbloqueio"
		
		ImpXmlErr(lJob , cFile , @aErros,; 
		cTxtErro,cTxtErro,cTxtErro,;
		"COM030",@aErroErp,"ImpXMLCteOS")

		lRet := .F.
	Elseif !aDadosAux[1,1]
		cTxtErro := "COM028 - " + STR0032 + Transform(cCNPJ_CT,"@R! NN.NNN.NNN/NNNN-99") + STR0033 + STR0034
			
		ImpXmlErr(lJob , cFile , @aErros,; 
		cTxtErro,cTxtErro,cTxtErro,;
		"COM028",@aErroErp,"ImpXMLCteOS")
		
		lRet := .F.
	Else
		cFornCTe := aDadosAux[1,2]
		cLojaCTe := aDadosAux[1,3]
		cNomeCTe := Posicione("SA2",1,xFilial("SA2") + cFornCTe + cLojaCTe,"A2_NOME")
	Endif
EndIf

If lRet
	// Verifica a TAG <TpCte> para analisar se a nota eh de Anulacao de Valores.
	If cTpCte <> '1'
		cTpCte := If(ValType(XmlChildEx(oXML:_InfCte,"_IDE")) == "O",AllTrim(oXML:_InfCte:_Ide:_tpCTe:Text),"") //-- Armazena o tipo do CT-e.
	EndIf
		
	If lRet
		//-- Ponto de entrada para mudar o produto frete
 		If ExistBlock("A116PRDF")
			cPrdFrete := ExecBlock("A116PRDF",.F.,.F.,{oXML})
			If ValType(cPrdFrete) <> "C" .Or. !SB1->(dbSeek(xFilial("SB1")+cPrdFrete))
				cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
				If At(";",cPrdFrete) > 0
					cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
				EndIf
				cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])
			EndIf
		Elseif lA116ITPCT
			aParamPE := If(Len(aAux) > 0,aAux,aAux1)
			cRetPrd := ExecBlock("A116ITPCT",.F.,.F.,{aParamPE, oXML})
			If ValType(cRetPrd) == "C" .And. SB1->(dbSeek(xFilial("SB1")+cRetPrd))
				cPrdFrete := PadR(cRetPrd,TamSX3("B1_COD")[1])
				cTipoFrete := "D"
			Else
				cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
				If At(";",cPrdFrete) > 0
					cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
				EndIf
				cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])	
			EndIf
		Else
			cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
			If At(";",cPrdFrete) > 0
				cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
			EndIf
			cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])
		EndIf
	
		If Empty(cPrdFrete) .Or. !SB1->(dbSeek(xFilial("SB1")+cPrdFrete))
			If lJob
				aAdd(aErros,{cFile,"COM023 - " + STR0017,STR0018}) //"Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente."#"Verifique a configuração do parâmetro."
			Else
				Aviso(STR0001,STR0017+STR0018,2,"ImpXML_CTe")
			EndIf
			aAdd(aErroErp,{cFile,"COM023"})
			lRet := .F.
		Else
			cTipoFrete := "D"
		EndIf
	Endif 
	
	//-- Obtem TES e cond. pagto para utilizacao no CT-e
	If lRet
		CTe_RetTES(oXML,@cTES_CT,@cCPag_CT)
	Endif
	
	//-- Valida existencia da TES a utilizar no CTe
	If lRet .And. !lPreNota .And. (Empty(cTES_CT) .Or. !SF4->(dbSeek(xFilial("SF4")+cTES_CT))) 
 		If lJob
			aAdd(aErros,{cFile,"COM021 - " + STR0013,STR0014}) //"TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente."
		Else
			Aviso(STR0001,STR0013 + STR0014,2,"ImpXML_CTe")
		EndIf
		aAdd(aErroErp,{cFile,"COM021"})
		lRet := .F.
	EndIf
	
	//-- Valida se o TES esta desbloqueado.
	If lRet
		If SF4->F4_MSBLQL == '1' .And. !lPreNota // TES bloqueado.
	 		If lJob
				aAdd(aErros,{cFile,"COM029 - " + STR0035 + SF4->F4_CODIGO,STR0036}) //"TES bloqueado. Codigo: "#"Verifique a configuração do cadastro."
			Else
				Aviso(STR0001,STR0035 + SF4->F4_CODIGO + Space(1) + STR0036,2,"ImpXML_CTe")
			EndIf
			aAdd(aErroErp,{cFile,"COM029"})
			lRet := .F.
		EndIf
	EndIf
	
	//-- Se TES gera dup., valida existencia da cond. pgto a utilizar no CTe
	If lRet .And. SF4->F4_DUPLIC == "S" .And. (Empty(cCPag_CT) .Or. !SE4->(dbSeek(xFilial("SE4")+cCPag_CT)))
 		If lJob
			aAdd(aErros,{cFile,"COM022 - " + STR0015,STR0016}) //"Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro.
		Else
			Aviso(STR0001,STR0015+STR0016,2,"ImpXML_CTe") //"Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro.
		EndIf
		lRet := .F.
		aAdd(aErroErp,{cFile,"COM022"})
	EndIf
Endif

// Verifica existência de documento com mesma numeração.
If lRet	
	cDoc	:= PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0")
	cSerie	:= PadR(oXML:_InfCte:_Ide:_Serie:Text,SerieNfId("SF1",6,"F1_SERIE")) 
	
	If ExistBlock("A116IDOC") //Manipula numero e serie do documento
		aA116IDOC := ExecBlock("A116IDOC",.F.,.F.,{cDoc, cSerie, cFornCTe, cLojaCTe})
		If ValType(aA116IDOC) == 'A' .And. Len(aA116IDOC) >= 2
			cDoc	:= aA116IDOC[1]
			cSerie := aA116IDOC[2]
		EndIf
	EndIf
	
	dbSelectArea("SDS")
	dbSetorder(1)
	If msSeek(xFilial("SDS")+cDoc+cSerie+cFornCTe+cLojaCTe)
		If lJob
			aAdd(aErros,{cFile,"COM025 - " + STR0026+" "+cDoc+", "+STR0027+" "+cSerie+" , "+STR0028,STR0029}) //Documento cdoc, serie cSerie, já cadastrado. verifique se o documento já foi importado para o ERP. 
		Else
			Aviso(STR0001,STR0026+" "+cDoc+", "+STR0027+""+cSerie+" , "+STR0028+" "+STR0029,2,"ImpXML_CTe")
		EndIf
		aAdd(aErroErp,{cFile,"COM025"})
		lRet := .F.
	EndIf
EndIf

If lRet
	//-- Separa secao que contem as notas do conhecimento para laco
	If ValType(XmlChildEx(oXML:_InfCte,"_INFCTENORM")) <> "U"
		If ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm,"_INFCARGA")) <> "U"
			If ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm:_InfCarga,"_INFQ")) <> "U"
				If ValType(oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ) == "O"
					aAux := {oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ}
				Else
					aAux := oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ
				Endif
			Endif
		Endif
	EndIf
	
 	For nX := 1 To Len(aAux)
		If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO BRUTO"
			nPesoBruto := Val(aAux[nX]:_QCARGA:Text)
		EndIf
		
		If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO LíQUIDO"
			nPesoLiqui := Val(aAux[nX]:_QCARGA:Text)
		EndIf
		
		If !("PESO" $ Upper(aAux[nX]:_TPMED:Text)) .And. Len(aEspecVol) < 5
			aAdd(aEspecVol,{AllTrim(aAux[nX]:_TPMED:Text),Val(aAux[nX]:_QCARGA:Text)})
		EndIf
	Next nX
	
	// Apuracao do ICMS para as diversas situacoes tributarias
	If ValType(XmlChildEx(oXML:_InfCte:_imp,"_ICMS")) <> "U"
		If ( oICMS := oXML:_INFCTE:_IMP:_ICMS ) != Nil
			If ( oICMSTipo := XmlGetChild( oICMS, 1 )) != Nil
				For nZ := 1 To 5	// O nivel maximo para descer dentro da tag que define o tipo do ICMS para obter tanto base quanto valor é 5, conforme manual de orientacao do CTe
					If ( oICMSNode := XmlGetChild( oICMSTipo, nZ )) != Nil
						If "vBC" $ oICMSNode:REALNAME
							nBaseICMS := Val(oICMSNode:TEXT)
							lBaseICMS := .T.
						ElseIf "vICMS" $ oICMSNode:REALNAME
							nValICMS := Val(oICMSNode:TEXT)
							lValICMS := .T.
						ElseIf "pICMS" $ oICMSNode:REALNAME
							nAliqICMS := Val(oICMSNode:TEXT)
							lAliqICMS := .T.
						EndIf
						If "CST" $ oICMSNode:REALNAME
							cCSTClas := oICMSNode:TEXT
						Endif
						If lBaseICMS .And. lValICMS .And. lAliqICMS
							Exit
						EndIf
					EndIf
				Next nZ
			EndIf
		EndIf
		//CBS e IBS
		If lTabDKM
			If ValType(XmlChildEx(oXML:_InfCte:_imp,"_IBSCBS")) == "O"
				cCSTCBSIBS	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS,"_CST")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_CST:Text,"")
				cClassTrib	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS,"_CCLASSTRIB")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_CCLASSTRIB:Text,"")

				If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS,"_GIBSCBS")) == "O"
					nBIBSCBS	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_VBC")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_vBC:Text), 0)	

					//IBSUF
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GIBSUF")) == "O"
						nAIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_PIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_PIBSUF:Text), 0)	
						nVIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_VIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_VIBSUF:Text), 0)

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_GDIF")) == "O"
							nADIFIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF,"_PDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF:_PDIF:Text), 0)
							nVDIFIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF,"_VDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDIF:_VDIF:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_GDEVTRIB")) == "O"
							nVDEVIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDEVTRIB,"_VDEVTRIB")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GDEVTRIB:_VDEVTRIB:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF,"_GRED")) == "O"
							nAREDIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED,"_PREDALIQ")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED:_PREDALIQ:Text), 0)
							nAREEIBSUF := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED,"_PALIQEFET")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSUF:_GRED:_PALIQEFET:Text), 0)
						Endif
					Endif

					//IBSMun
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GIBSMUN")) == "O"
						nAIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_PIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_PIBSMUN:Text), 0)	
						nVIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_VIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_VIBSMUN:Text), 0)

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_GDIF")) == "O"
							nADIFIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF,"_PDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF:_PDIF:Text), 0)
							nVDIFIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF,"_VDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDIF:_VDIF:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_GDEVTRIB")) == "O"
							nVDEVIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDEVTRIB,"_VDEVTRIB")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GDEVTRIB:_VDEVTRIB:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN,"_GRED")) == "O"
							nAREDIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED,"_PREDALIQ")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED:_PREDALIQ:Text), 0)
							nAREEIBSMUN := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED,"_PALIQEFET")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSMUN:_GRED:_PALIQEFET:Text), 0)
						Endif
					Endif

					//CBS
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GCBS")) == "O"
						nACBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_PCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_PCBS:Text), 0)	
						nVCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_VCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_VCBS:Text), 0)

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_GDIF")) == "O"
							nADIFCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF,"_PDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF:_PDIF:Text), 0)
							nVDIFCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF,"_VDIF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDIF:_VDIF:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_GDEVTRIB")) == "O"
							nVDEVCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDEVTRIB,"_VDEVTRIB")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GDEVTRIB:_VDEVTRIB:Text), 0)
						Endif

						If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS,"_GRED")) == "O"
							nAREDCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED,"_PREDALIQ")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED:_PREDALIQ:Text), 0)
							nAREECBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED,"_PALIQEFET")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBS:_GRED:_PALIQEFET:Text), 0)
						Endif
					Endif

					//CBS e IBS Como seria tributação caso não cumprida a condição resolutória/suspensiva
					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GTRIBREGULAR")) == "O"
						cCSTReg	    := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_CSTREG")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_CSTREG:Text, "")
						cClasReg    := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_CCLASSTRIBREG")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_CCLASSTRIBREG:Text, "")
						nAIBSUFReg  := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_PALIQEFETREGIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_PALIQEFETREGIBSUF:Text), 0)
						nVIBSUFReg  := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_VTRIBREGIBSUF")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_VTRIBREGIBSUF:Text), 0)
						nAIBSMunReg := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_PALIQEFETREGIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_PALIQEFETREGIBSMUN:Text), 0)
						nVIBSMunReg := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_VTRIBREGIBSMUN")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_VTRIBREGIBSMUN:Text), 0)
						nACBSReg	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_PALIQEFETREGCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_PALIQEFETREGCBS:Text), 0)
						nVCBSReg	:= If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR,"_VTRIBREGCBS")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GTRIBREGULAR:_VTRIBREGCBS:Text), 0)
					Endif

					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GIBSCREDPRES")) == "O"
						cCredPreIBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES,"_CCREDPRES")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES:_CCREDPRES:Text, "")
						nAlCrePrIBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES,"_PCREDPRES")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES:_PCREDPRES:Text), 0)
						nVlCrePrIBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES,"vCredPresCondSus")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GIBSCREDPRES:vCredPresCondSus:Text), 0)
					Endif

					If ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS,"_GCBSCREDPRES")) == "O"
						cCredPreCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES,"_CCREDPRES")) == "O",  oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES:_CCREDPRES:Text, "")
						nAlCrePrCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES,"_PCREDPRES")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES:_PCREDPRES:Text), 0)
						nVlCrePrCBS := If(ValType(XmlChildEx( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES,"_VCREDPRES")) == "O", Val( oXML:_InfCte:_imp:_IBSCBS:_GIBSCBS:_GCBSCREDPRES:_VCREDPRES:Text), 0)
					Endif

				Endif
			Endif
		Endif

		lRet := !COMXIMPVLD({{nAliqICMS,">=100"}})
		If !lRet
			cTxtErro := "COM043 - " + STR0046 + STR0047 //"Foi identificada uma alíquota de impostos igual ou superior a 100%." | " Por favor, confira a origem do XML ou valide a configuração dos campos de alíquotas (tamanho e decimais) ou insira o documento manualmente."
			ImpXmlErr(lJob , cFile , @aErros, cTxtErro, cTxtErro, cTxtErro, "COM043" , @aErroErp, "ImpXML_CTeOS")
		Endif

	EndIf
Endif

//Valor do frete
If lRet .And. ValType(XmlChildEx(oXML:_InfCte,"_VPREST")) <> "U"
	If ValType(XmlChildEx(oXML:_InfCte:_vPrest,"_VREC")) <> "U" .And. ValType(XmlChildEx(oXML:_InfCte:_vPrest,"_VTPREST")) <> "U"
		If Val(oXML:_InfCte:_VPrest:_VRec:Text) == 0 .And. Val(oXML:_InfCte:_VPrest:_vTPrest:Text) == 0
			lVlrFrtZero := .T.
		Elseif Val(oXML:_InfCte:_VPrest:_VRec:Text) == 0 .And. Val(oXML:_InfCte:_VPrest:_vTPrest:Text) > 0
			nVlrFrt := Val(oXML:_InfCte:_VPrest:_vTPrest:Text)
			lVlrFrtZero := .T.
		Elseif lVlrCte .And. Val(oXML:_InfCte:_VPrest:_vTPrest:Text) > 0
			nVlrFrt := Val(oXML:_InfCte:_VPrest:_vTPrest:Text)
		Else
			nVlrFrt := Val(oXML:_InfCte:_VPrest:_VRec:Text)
		Endif
	Endif
Endif

If lRet
	//Estado de origem do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_UFINI")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_UFIni:Text)
		cUFOrigem := oXML:_InfCte:_Ide:_UFIni:Text		
	Else
		cUFOrigem := Posicione("SA2",1,xFilial("SA2")+cFornCTe+cLojaCTe,"A2_EST")
	Endif
	
	//Codigo Municipio de origem do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_CMUNINI")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_cMunIni:Text)
		cMunOrigem := SubStr(oXML:_InfCte:_Ide:_cMunIni:Text,3,5)
	Endif
	
	//Estado de destino do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_UFFIM")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_UFFim:Text)
		cUFDestino := oXML:_InfCte:_Ide:_UFFim:Text
	Endif
	
	//Codigo Municipio de destino do CTE
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_CMUNFIM")) <> "U" .And. !Empty(oXML:_InfCte:_Ide:_cMunFim:Text)
		cMunDestin := SubStr(oXML:_InfCte:_Ide:_cMunFim:Text,3,5)
	Endif
Endif

If lRet
	Begin Transaction
	cEspecie := "CTEOS"	
	//-- Grava cabeca do conhecimento de transporte
	RecLock("SDS",.T.)
	SDS->DS_FILIAL	:= xFilial("SDS")																					// Filial			
    SDS->DS_CNPJ	:= cCNPJ_CT																						// CGC
    SDS->DS_DOC		:= cDoc																							// Numero do Documento
    SDS->DS_FORNEC	:= cFornCTe																						// Fornecedor do Conhecimento de transporte
    SDS->DS_LOJA	:= cLojaCTe																						// Loja do Fornecedor do Conhecimento de transporte
    SDS->DS_EMISSA	:= StoD(StrTran(AllTrim(oXML:_InfCte:_Ide:_Dhemi:Text),"-",""))							// Data de Emissão
    SDS->DS_EST		:= cUFOrigem																			// Estado de emissao da NF
    SDS->DS_TIPO	:= "T"													 											// Tipo da Nota
    SDS->DS_FORMUL	:= "N" 																							// Formulario proprio
    SDS->DS_ESPECI	:= cEspecie														  								// Especie
    SDS->DS_ARQUIVO	:= AllTrim(cFile)																					// Arquivo importado
    SDS->DS_CHAVENF	:= Right(AllTrim(oXML:_InfCte:_Id:Text),44)													// Chave de Acesso da NF
    SDS->DS_VERSAO	:= AllTrim(oXML:_InfCte:_Versao:Text) 															// Versão
    SDS->DS_USERIMP	:= IIf(!lJob,cUserName,Iif(lImpXML,STR0054,STR0055))											// Usuario na importacao -- Importador XML # Totvs Colaboração
    SDS->DS_DATAIMP	:= dDataBase																						// Data importacao do XML
    SDS->DS_HORAIMP	:= SubStr(Time(),1,5)																			// Hora importacao XML
    SDS->DS_VALMERC	:= nVlrFrt																	  						// Valor Mercadoria
    SDS->DS_TPFRETE	:= cTipoFrete																						// Tipo de Frete
    SDS->DS_PBRUTO	:= nPesoBruto																						// Peso Bruto
    SDS->DS_PLIQUI	:= nPesoLiqui																						// Peso Liquido
    
    For nX := 1 To Len(aEspecVol)
    	If SDS->(ColumnPos("DS_ESPECI" +Str(nX,1))) > 0
		    SDS->&("DS_ESPECI" +Str(nX,1)) := aEspecVol[nX,1]							 							// Especie
			SDS->&("DS_VOLUME" +Str(nX,1)) := aEspecVol[nX,2]							 							// Volume
		EndIf
	Next nX

	If SDS->(ColumnPos("DS_BASEICM")) > 0 .And. lBaseICMS
		SDS->DS_BASEICM := nBaseICMS
	EndIf
	
	If SDS->(ColumnPos("DS_VALICM")) > 0 .And. lValICMS
		SDS->DS_VALICM := nValICMS
	EndIf

	If SDS->(ColumnPos('DS_TPCTE')) > 0
		SDS->DS_TPCTE := TIPOCTE116(cTpCte)
	EndIf
	
	//Chave da Nota de Origem
    If SDS->(ColumnPos("DS_CHVNFOR")) > 0
    	SDS->DS_CHVNFOR		:= cChvNFOr
    Endif
    
   	If !Empty(cHrEmis)
		SDS->DS_HORNFE := cHrEmis
	Endif
	
	//Valor a pagar igual a 0
	If lVlrFrtZero
		SDS->DS_FRETE := Iif(nVlrFrt==0,1,nVlrFrt)
	Endif
	
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_MODAL")) <> "U" .And. SDS->(ColumnPos("DS_MODAL")) > 0
		SDS->DS_MODAL := AllTrim(oXML:_InfCte:_Ide:_modal:Text)
	Endif
	
	//Estado/Municipio de Origem e Destino do CTE
	If SDS->(ColumnPos("DS_UFDESTR")) > 0 .And. SDS->(ColumnPos("DS_MUDESTR")) > 0 .And. SDS->(ColumnPos("DS_UFORITR")) > 0 .And. SDS->(ColumnPos("DS_MUORITR")) > 0
		SDS->DS_UFDESTR := cUFDestino
		SDS->DS_MUDESTR := cMunDestin
		SDS->DS_UFORITR := cUFOrigem
		SDS->DS_MUORITR := cMunOrigem
	Endif
		
	SerieNfId("SDS",1,"DS_SERIE",SDS->DS_EMISSA,SDS->DS_ESPECI,cSerie) 
	
	SDS->(MsUnlock())
	
	//-- Grava itens do conhecimento de transporte
	If !Empty(cPrdFrete)
		RecLock("SDT",.T.)
		SDT->DT_FILIAL		:= xFilial("SDT")					// Filial
		SDT->DT_ITEM		:= StrZero(1,TamSX3("DT_ITEM")[1])	// Item
		SDT->DT_COD			:= cPrdFrete						// Codigo do produto
		SDT->DT_FORNEC		:= cFornCTe							// Forncedor
		SDT->DT_LOJA		:= cLojaCTe							// Loja
		SDT->DT_DOC			:= cDoc								// Docto
		SDT->DT_SERIE		:= cSerie 					   		// Serie
		SDT->DT_CNPJ		:= SDS->DS_CNPJ						// Cnpj do Fornecedor
		SDT->DT_QUANT		:= 1								// Quantidade
		SDT->DT_VUNIT		:= nVlrFrt							// Valor Unitário 			
		SDT->DT_TOTAL		:= nVlrFrt				   			// Valor Total 			 	

		If SDT->(FieldPos("DT_PICM")) > 0 .And. SDT->(FieldPos("DT_XALQICM")) > 0 .And. lAliqICMS
			SDT->DT_PICM := nAliqICMS
			SDT->DT_XALQICM := nAliqICMS
		EndIf

		If SDT->(FieldPos("DT_XMLICM")) > 0 .And. lValICMS
			SDT->DT_XMLICM := nValICMS
		Endif
		
		If lUnidMed
			SDT->DT_UM		:= GetAdvFVal("SB1","B1_UM",xFilial("SB1")+cPrdFrete,1)
			SDT->DT_SEGUM	:= GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+cPrdFrete,1)
			
			If !Empty(SDT->DT_SEGUM)
				SDT->DT_QTSEGUM := ConvUM(cPrdFrete,1,1,2)
			Endif
		Endif
		
		if lNatRen .And. FindFunction("A103GetNat")
			cNatRen := A103GetNat(cPrdFrete)
			if !empty(cNatRen)
				SDT->DT_NATREN:= cNatRen
			endif
		endif

		SDT->(MsUnlock())
		
		If lTabDKM
				nItemSDT := StrZero(1,TamSX3("DT_ITEM")[1])

				//IBSUF
				aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000060' )	
								{"DKM_DOC"		,cDoc},;			// Numero Documento             
								{"DKM_SERIE"	,cSerie},;			// Serie                    
								{"DKM_FORNEC"	,cFornCTe},;		// Fornecedor / Cliente     
								{"DKM_LOJA"		,cLojaCTe},;		// Loja                     
								{"DKM_TIPO"		, "T"	},;			// Tipo Nota                
								{"DKM_ESPECI"	,cEspecie},;			// Especie                  
								{"DKM_ITEM"		,nItemSDT	},;		// Item NF                  
								{"DKM_COD"		,cPrdFrete},;		// Produto                  
								{"DKM_TRIB"		,"IBSUF"},;			// Tributo / Imposto        
								{"DKM_XMLBAS"	,nBIBSCBS},;		// Base CBS/IBS NO XML	
								{"DKM_XMLALQ"	,nAIBSUF},;			// Aliquota IBS UF NO XML	
								{"DKM_XMLVLR"	,nVIBSUF},;			// Valor IBS UF NO XML	
								{"DKM_BASE"		,0},;				// Base CBS/IBS	
								{"DKM_ALIQ"		,0},;				// Aliquota IBS UF	
								{"DKM_VALOR"	,0},;				// Valor IBS UF	
								{"DKM_PDIF"		,nADIFIBSUF},;		// Aliquota Diferencial IBS UF	
								{"DKM_VDIF"		,nVDIFIBSUF},;		// Valor Diferencial IBS UF	
								{"DKM_VDEV"		,nVDEVIBSUF},;		// Valor Devolvido IBS UF	
								{"DKM_PREDAL"	,nAREDIBSUF},;		// Aliquota Reduzida Classifição Tributaria	
								{"DKM_PALIEF"	,nAREEIBSUF},;		// Aliquota Efetiva	
								{"DKM_CST"		,cCSTCBSIBS},;		// CST CBS/IBS	
								{"DKM_CLASTR"	,cClassTrib},;		// Classificação Tributaria	
								{"DKM_CSTRE"	,cCSTReg},;			// CST Regular (Seria se fosse)	
								{"DKM_CLAREG"	,cClasReg},;		// Classificação Tributaria (Seria se fosse)	
								{"DKM_ALQEFE"	,nAIBSUFReg},;		// Aliquota IBS UF (Seria se fosse)	
								{"DKM_VLREFE"	,nVIBSUFReg},;		// Valor IBS UF (Seria se fosse)	
								{"DKM_CODCRE"	,cCredPreIBS},;		// Codigo Credito Presumido IBS	
								{"DKM_ALQPRE"	,nAlCrePrIBS},;		// Aliquota Credito Presumido IBS	
								{"DKM_VLRPRE"	,nVlCrePrIBS},;		// Valor Credito Presumido IBS	
								{"DKM_VSPRE"	,0},;				// Vlr Suspensao Cred Presum
								{"DKM_ORIGEM"   ,"COMXCOL" }})		// Origem do lancamento		

				//IBSMun
				aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000061' )	
								{"DKM_DOC"		,cDoc},;			// Numero Documento             
								{"DKM_SERIE"	,cSerie},;			// Serie                    
								{"DKM_FORNEC"	,cFornCTe},;		// Fornecedor / Cliente     
								{"DKM_LOJA"		,cLojaCTe},;		// Loja                      
								{"DKM_TIPO"		, "T"	},;			// Tipo Nota                
								{"DKM_ESPECI"	,cEspecie},;			// Especie                  
								{"DKM_ITEM"		,nItemSDT	},;		// Item NF                  
								{"DKM_COD"		,cPrdFrete},;		// Produto                  
								{"DKM_TRIB"		,"IBSMun"},;		// Tributo / Imposto        
								{"DKM_XMLBAS"	,nBIBSCBS},;		// Base CBS/IBS NO XML	
								{"DKM_XMLALQ"	,nAIBSMun},;			// Aliquota IBS UF NO XML	
								{"DKM_XMLVLR"	,nVIBSMun},;			// Valor IBS UF NO XML	
								{"DKM_BASE"		,0},;				// Base CBS/IBS	
								{"DKM_ALIQ"		,0},;				// Aliquota IBS UF	
								{"DKM_VALOR"	,0},;				// Valor IBS UF	
								{"DKM_PDIF"		,nADIFIBSMun},;		// Aliquota Diferencial IBS UF	
								{"DKM_VDIF"		,nVDIFIBSMun},;		// Valor Diferencial IBS UF	
								{"DKM_VDEV"		,nVDEVIBSMun},;		// Valor Devolvido IBS UF	
								{"DKM_PREDAL"	,nAREDIBSMun},;		// Aliquota Reduzida Classifição Tributaria	
								{"DKM_PALIEF"	,nAREEIBSMun},;		// Aliquota Efetiva	
								{"DKM_CST"		,cCSTCBSIBS},;		// CST CBS/IBS	
								{"DKM_CLASTR"	,cClassTrib},;		// Classificação Tributaria	
								{"DKM_CSTRE"	,cCSTReg},;			// CST Regular (Seria se fosse)	
								{"DKM_CLAREG"	,cClasReg},;		// Classificação Tributaria (Seria se fosse)	
								{"DKM_ALQEFE"	,nAIBSMunReg},;		// Aliquota IBS UF (Seria se fosse)	
								{"DKM_VLREFE"	,nVIBSMunReg},;		// Valor IBS UF (Seria se fosse)	
								{"DKM_CODCRE"	,""},;		// Codigo Credito Presumido IBS	
								{"DKM_ALQPRE"	,0},;		// Aliquota Credito Presumido IBS	
								{"DKM_VLRPRE"	,0},;		// Valor Credito Presumido IBS	
								{"DKM_VSPRE"	,0},;				// Vlr Suspensao Cred Presum
								{"DKM_ORIGEM"   ,"COMXCOL" }})		// Origem do lancamento		

				//CBS
				aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000062' )	
								{"DKM_DOC"		,cDoc},;			// Numero Documento             
								{"DKM_SERIE"	,cSerie},;			// Serie                    
								{"DKM_FORNEC"	,cFornCTe},;		// Fornecedor / Cliente     
								{"DKM_LOJA"		,cLojaCTe},;		// Loja                        
								{"DKM_TIPO"		, "T"},;			// Tipo Nota                
								{"DKM_ESPECI"	,cEspecie},;			// Especie                  
								{"DKM_ITEM"		,nItemSDT	},;		// Item NF                  
								{"DKM_COD"		,cPrdFrete},;		// Produto                  
								{"DKM_TRIB"		,"CBS"},;			// Tributo / Imposto        
								{"DKM_XMLBAS"	,nBIBSCBS},;		// Base CBS/IBS NO XML	
								{"DKM_XMLALQ"	,nACBS},;			// Aliquota IBS UF NO XML	
								{"DKM_XMLVLR"	,nVCBS},;			// Valor IBS UF NO XML	
								{"DKM_BASE"		,0},;				// Base CBS/IBS	
								{"DKM_ALIQ"		,0},;				// Aliquota IBS UF	
								{"DKM_VALOR"	,0},;				// Valor IBS UF	
								{"DKM_PDIF"		,nADIFCBS},;		// Aliquota Diferencial IBS UF	
								{"DKM_VDIF"		,nVDIFCBS},;		// Valor Diferencial IBS UF	
								{"DKM_VDEV"		,nVDEVCBS},;		// Valor Devolvido IBS UF	
								{"DKM_PREDAL"	,nAREDCBS},;		// Aliquota Reduzida Classifição Tributaria	
								{"DKM_PALIEF"	,nAREECBS},;		// Aliquota Efetiva	
								{"DKM_CST"		,cCSTCBSIBS},;		// CST CBS/IBS	
								{"DKM_CLASTR"	,cClassTrib},;		// Classificação Tributaria	
								{"DKM_CSTRE"	,cCSTReg},;			// CST Regular (Seria se fosse)	
								{"DKM_CLAREG"	,cClasReg},;		// Classificação Tributaria (Seria se fosse)	
								{"DKM_ALQEFE"	,nACBSReg},;		// Aliquota IBS UF (Seria se fosse)	
								{"DKM_VLREFE"	,nVCBSReg},;		// Valor IBS UF (Seria se fosse)	
								{"DKM_CODCRE"	,cCredPreCBS},;		// Codigo Credito Presumido IBS	
								{"DKM_ALQPRE"	,nAlCrePrCBS},;		// Aliquota Credito Presumido IBS	
								{"DKM_VLRPRE"	,nVlCrePrCBS},;		// Valor Credito Presumido IBS	
								{"DKM_VSPRE"	,0},;				// Vlr Suspensao Cred Presum
								{"DKM_ORIGEM"   ,"COMXCOL" }})		// Origem do lancamento		
							
			Endif
			SDT->(DbSetOrder(8))
			If SDT->(DbSeek(xFilial("SDT")+cFornCTe+cLojaCTe+cDoc+cSerie+nItemSDT))
				For nX := 1 to len(aDadosDKM)
					AADD(aDadosDKM[nX], {"DKM_UIDSDT",SDT->DT_MSUID})
				Next
				If Len(aDadosDKM) > 0
					COMNEWIMP(aDadosDKM)
				Endif
			Endif		
		//Atualizar CLASFIS
		If lDTClasFis .And. !Empty(cCSTClas)
			A116ICLASFIS(cDoc,cSerie,cFornCTe,cLojaCTe,cCSTClas)
		Endif

		If lMt116XmlCt
			ExecBlock("Mt116XmlCt",.F.,.F.,{oXML,cDoc,cSerie,cFornCTe,cLojaCTe,"T","PF"})
		EndIf

	EndIf
	
	End Transaction
EndIf

If lRet
	aAdd(aProc,{	PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0"),;
					PadR(oXML:_InfCte:_Ide:_Serie:Text,SerieNfId("SF1",6,"F1_SERIE")),;
					cNomeCTe})
Endif

oXML := Nil
DelClassIntf()

DisarmTran()
Return lRet

/*/{Protheus.doc}A116ICLASFIS
Gravação CLASFIS para conhecimento de frete

@author Rodrigo Pontes
@since  16/05/22
/*/

Static Function A116ICLASFIS(cDoc,cSerie,cFornCTe,cLojaCTe,cCSTClas)

Local lMVSTFRETE:= SuperGetMV("MV_STFRETE",.F.,.F.)
Local cClasFis	:= ""
Local cOrigClas	:= " "
Local cQry		:= ""
Local cQryStat	:= ""
Local cAliasTmp	:= GetNextAlias()
Local aArea		:= GetArea()

If oCTeFis == Nil
    oCTeFis := FWPreparedStatement():New()

    cQry := " SELECT DT_COD, R_E_C_N_O_ RECNO"
    cQry += " FROM " + RetSqlName("SDT")
    cQry += " WHERE DT_DOC = ?"
    cQry += " AND DT_SERIE = ?"
	cQry += " AND DT_FORNEC = ?"
	cQry += " AND DT_LOJA = ?"
	cQry += " AND D_E_L_E_T_ = ' '"
    cQry := ChangeQuery(cQry)

    oCTeFis:SetQuery(cQry)
Endif

oCTeFis:SetString(1,cDoc)
oCTeFis:SetString(2,cSerie)
oCTeFis:SetString(3,cFornCTe)
oCTeFis:SetString(4,cLojaCTe)

cQryStat := oCTeFis:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasTmp) 

While (cAliasTmp)->(!EOF())
	cClasFis := ""
	//lMVSTFRETE -> T = Origem Zero (0) / F = Origem SB1
	If lMVSTFRETE
		cOrigClas := "0"
	Else
		cOrigClas := GetAdvFVal("SB1","B1_ORIGEM",xFilial("SB1")+(cAliasTmp)->DT_COD,1)
	Endif
	
	cClasFis := cOrigClas+cCSTClas
	
	If !Empty(cClasFis)
		SDT->(DbGoto((cAliasTmp)->RECNO))
		If RecLock("SDT",.F.)
			SDT->DT_CLASFIS := cClasFis
			SDT->(MsUnlock())
		Endif
	Endif
	(cAliasTmp)->(DbSkip())
Enddo

(cAliasTmp)->(DbCloseArea())

RestArea(aArea)

Return



/*/{Protheus.doc} A116GrvNat
	(Grava a natureza de Rendimento (DT_NATREN) conforme nota de origem)
	@type  Static Function
	@author Thiago Rodrigues
	@since 17/11/2023
	@see (links_or_references)
/*/
Static Function A116GrvNat(cDoc,cSerie,cFornCTe,cLojaCTe,cChaveNF)
Local aArea		:= GetArea()
Local cAliasSDT	:= GetNextAlias()
local oObjQuery := nil
local cQryStat  := ""

Default cDoc := ""
Default cSerie := ""
Default cFornCTe := ""
Default cLojaCTe := ""
Default cChaveNF := ""

SF1->(dbSetOrder(8))
SDT->(dbSetOrder(8))
If SF1->(dbSeek(xFilial("SF1")+cChaveNF)) 
	
	If oObjQuery == Nil
		oObjQuery := FWPreparedStatement():New()

		cQry := " SELECT DT_ITEMORI ITEM,R_E_C_N_O_ RECNO "
		cQry += " FROM " + RetSqlName("SDT")
		cQry += " WHERE DT_DOC = ?"
		cQry += " AND DT_SERIE = ?"
		cQry += " AND DT_FORNEC = ?"
		cQry += " AND DT_LOJA = ?"
		cQry += " AND D_E_L_E_T_ = ' '"
		cQry := ChangeQuery(cQry)

		oObjQuery:SetQuery(cQry)
	Endif

	oObjQuery:SetString(1,cDoc)
	oObjQuery:SetString(2,cSerie)
	oObjQuery:SetString(3,cFornCTe)
	oObjQuery:SetString(4,cLojaCTe)

	cQryStat := oObjQuery:GetFixQuery()
	MpSysOpenQuery(cQryStat,cAliasSDT) 

	////Grava a DT_NATREN conforme a nota de origem
	While !(cAliasSDT)->(Eof())
		If DHR->(DbSeek(xFilial("DHR")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+(cAliasSDT)->ITEM))
			SDT->(DbGoto((cAliasSDT)->RECNO))
			If RecLock("SDT",.F.)
				SDT->DT_NATREN := DHR->DHR_NATREN
				SDT->(MsUnlock())
			Endif
		endif
		(cAliasSDT)->(DbSkip())
	end
	(cAliasSDT)->(DbCloseArea())

endif

RestArea(aArea)
Return 
