#Include 'Protheus.ch' 
#Include 'TOPConn.ch' 
#Include 'COMXCOL.ch'
#Include "FILEIO.CH"
#Include "TbiConn.ch"
#Include 'RwMake.ch'
#Include "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'FWLIBVERSION.CH'
#INCLUDE 'MATA140I.ch'
#INCLUDE 'COMXCOL2.ch'   
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpXMLErr
Atualiza Erro durante importação do XML

@author	Rodrigo M Pontes
@since 14/05/22
/*/
//------------------------------------------------------------------- 

Function ImpXMLErr(lJob,cFile,aErros,cMsgJob,cMsgAviso,cMsgSolJob,cCodErr,aErroErp,cFonte)

Default cCodErr := ""
Default cFonte	:= "ImpXMLNFsT"

If lJob 
	aAdd(aErros,{cFile,cMsgJob,cMsgSolJob})
Else
	Aviso(STR0082,cMsgAviso,{STR0004},2,cFonte)
EndIf

If !Empty(cCodErr)
	aAdd(aErroErp,{cFile,cCodErr})
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ImpXMLNFsT
Importar NFS para CKO

@author	Rodrigo M Pontes
@since 14/05/22
/*/
//------------------------------------------------------------------- 


Function ImpXMLNFsT(cFile,lJob,aProc,aErros,oFullXML,aErroERP)

Local cError     	:= ""
Local cCGCTT		:= ""
Local cCGCTP		:= ""
Local cCodigo 		:= ""
Local cLoja			:= ""
Local cNomeFor		:= ""
Local cCodServ		:= ""
Local cMunServ		:= ""
Local cDescServ		:= ""
Local cDoc			:= ""
Local cSerie		:= ""  
Local cRPS			:= ""
Local cCodNFE		:= ""
Local cHrEmis		:= "" 
Local cNFsVersao	:= ""
Local cUFTom		:= ""
Local cQry			:= ""
Local cFiltro		:= ""
Local cUFForn		:= ""
Local lUFForn  		:= SuperGetMV("MV_UFNFSF",.F.,.F.)
Local dDtEmis		:= StoD("")
Local nX			:= 0
Local nY			:= 0
Local lProces    	:= .T.
Local aItens     	:= {}
Local aHeadSDS		:= {}
Local aItemSDT		:= {}
Local aDirFilial	:= {}
Local cMT140ISV		:= ""
Local nAlqISS		:= 0
Local nVlrISS		:= 0
Local nVlrPIS		:= 0
Local nVlrCSLL		:= 0
Local nVlrIR		:= 0
Local nVlrCOF		:= 0
Local lISSIt		:= .F.
Local lUnidMed		:= SDT->(FieldPos("DT_UM")) > 0 .And. SDT->(FieldPos("DT_SEGUM")) > 0 .And. SDT->(FieldPos("DT_QTSEGUM")) > 0
Local lConvUM		:= .F.
Local cUM			:= ""
Local cSEGUM		:= ""
Local nQtSEGUM		:= 0
Local lFatorConv	:= .F.
Local cMsgAviso		:= ""
Local cMsgJob		:= ""
Local cMsgSolJob	:= ""
Local cCodErr		:= ""
Local aImpCadAut	:= ""
Local cStatusAut	:= ""
Local cTxtErro		:= ""
Local nPosVIR 		:= SDT->(FieldPos("DT_XMLVIR"))
Local nPosVCSL		:= SDT->(FieldPos("DT_XMLVCSL"))
Local lA2Blql		:= SA2->(FieldPos("A2_MSBLQL")) > 0
Local cMotQry		:= ""
Local cAliTmp		:= GetNextAlias()
Local oQry			:= FWPreparedStatement():New()
Local nQCNPJ		:= 0
Local lAchouForn    := .F.
Local lA140IFOR	    := ExistBlock("A140IFOR")
Local aFornec		:= {}
Local lNatRen       := SDT->(FieldPos("DT_NATREN")) > 0  //Natureza de Rendimento
Local cNatRen       := "" //Codigo da natureza de rendimento
Local cRSocial		:= ""
Local cMotivo	 	:= ""
Local ncStat	 	:= 0
Local nValMTot 		As Numeric
Local aNewDoc   	:= {}
Local cDocEletr		:= ""
Local oObjImp   	:= ComTransmite():New()
Local lComNFSNewDoc	:= FindFunction("ComNFSNewDoc")
Local lTabDKM		:= ChkFile("DKM")
Local lAtuDKM 		:= .F.
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
Local oCBSIBSRps	:= Nil
Local oCBSIBSVlr	:= Nil
Local oCBSIBSTot	:= Nil
Local cItemSDT		:= ""
Local aColsDT		:= {}
Local aHeadDT		:= {}

Private lImpXTra	:= ImpXTra()
Private lMsErroAuto	:= .F.

Default lJob   	 	:= .T.
Default cFile		:= ""
Default aProc		:= {}
Default aErros		:= {}
Default oFullXML	:= NIL

nValMTot 			:= 0

//-- Verifica erro na sintaxe do XML
If Empty(oFullXML) .Or. !Empty(cError)
	//"Erro de sintaxe no arquivo XML: "#"Entre em contato com o emissor do documento e comunique a ocorrência."
	ImpXMLErr(lJob,cFile,@aErros,STR0101+cError,cError,STR0102,"",@aErroERP)
	lProces := .F.
Else
	oFullXML	:= XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")

	cCGCTT  	:= Iif(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_TOMADOR,"_CNPJTOM") # NIL,;
						oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_TOMADOR:_CNPJTOM:TEXT,;
						oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_TOMADOR:_CPFTOM:TEXT)

	cCGCTP		:= Iif(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_CNPJPREST") # NIL,;
							oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_CNPJPREST:TEXT,;
							oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_CPFPREST:TEXT)
EndIf

//Verifica se NFS-e está cancelado
if lProces .And. ValType(oFullXML) <> "U" .And. Valtype(XmlChildEx(oFullXML,"_TRANSMITE"))== "O" .And.;
		     					   Valtype(XmlChildEx(oFullXML:_TRANSMITE,"_RETTRANSMITENFSE"))== "O" .And.;
								   Valtype(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_CSTAT"))== "O" //NFS-E
	
	ncStat := VAL(AllTrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_cStat:Text))
	
	cChaveNFe :=  Alltrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_dtEmisNFSe:text)+"|"+;
				  Iif(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_CNPJPREST") # NIL,;
							Alltrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_CNPJPREST:TEXT),;
							Alltrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_CPFPREST:TEXT))+"|"+;
				  Alltrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_nNFSe:text)
	
	if ncStat == 101 .Or. ncStat == 151 .Or. ncStat > 200
		lProces	:= .F. 
		
		//Motivo 
		if Valtype(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_XMOTIVO")) <> "U"
			cMotivo := ConvASC(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_xMotivo:Text)  
		endif
	
		if ncStat == 101 .Or. ncStat == 151 //Cancelado
			
			aAdd(aErros,{cFile,"COM057 - " +STR0025 + cChaveNFe + STR0026 + " " + cMotivo,""}) //NFS-e cancelada: # Motivo
			aAdd(aErroErp,{cFile,"COM057"})				
		else //Rejeitado
			
			aAdd(aErros,{cFile,"COM058 - "+ STR0027 + cChaveNFe + STR0026 + " " +cMotivo,""})//"NFS-e rejeitada: # Motivo
			aAdd(aErroErp,{cFile,"COM058"})
		endif

		ImpXMLErr(lJob,cFile,@aErros,cMsgJob,cMsgAviso,cMsgSolJob,cCodErr,@aErroERP)	
	endif
endif

If lProces
	aDirFilial := DirFilial(cFile,cCGCTT,"",lJob)
	If !aDirFilial[1] 
		If !aDirFilial[2]
			cMsgAviso 	:= Iif(aDirFilial[3],STR0244,Iif(aDirFilial[4],STR0254,STR0085))
			cMsgJob 	:= Iif(aDirFilial[3],"COM042 - " + STR0244,Iif(aDirFilial[4],"COM052 - " + STR0254,"COM002 - " + STR0085))
			cMsgSolJob	:= Iif(aDirFilial[3],STR0245,Iif(aDirFilial[4],STR0255,STR0246))
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
			ImpXMLErr(lJob,cFile,@aErros,"COM002 - " + STR0085,"",STR0246,"COM002",@aErroERP)
			lProces  := .F.
		Endif
	Endif
Endif
	
If lProces
	If XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_PRESTADOR,"_RSOCIALPREST") # NIL 
		cRSocial := oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_PRESTADOR:_RSOCIALPREST:TEXT
	Endif

	SA2->(dbSetOrder(3))
	If !SA2->(dbSeek(xFilial('SA2')+AllTrim(cCGCTP)))
		If lImpXTra .And. FindFunction("ImpCadAutF")
			aImpCadAut	:= ImpCadAutF(oFullXML,"140ITS","N")
			lProces 	:= aImpCadAut[1]

			If !lProces
				//Verifica se está cadastrado o prestador de servico
				ImpXMLErr(lJob,cFile,@aErros,"COM007 - " + STR0040 + cRSocial  +" [" + Transform(cCGCTP,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0109 + aImpCadAut[5],STR0208,STR0110,"COM007",@aErroERP)
			Else
				cCodigo 	:= aImpCadAut[2]
				cLoja	 	:= aImpCadAut[3]
				cNomeFor	:= aImpCadAut[4]
				cStatusAut	:= "B"
			Endif
		Else
			lProces := .F.
			//Verifica se está cadastrado o prestador de servico
			ImpXMLErr(lJob,cFile,@aErros,"COM007 - " + STR0040 + cRSocial  +" [" + Transform(cCGCTP,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0109,STR0208,STR0110,"COM007",@aErroERP)
		Endif
	Else
		cMotQry := "SELECT A2_CGC,A2_COD,A2_LOJA,A2_NOME "
		cMotQry += " FROM "+RetSqlName("SA2")+" SA2 	 "
		cMotQry += " WHERE SA2.A2_FILIAL  = ?       	 "
		cMotQry += " AND SA2.A2_CGC       = ? 			 "
		if lA2Blql
			cMotQry += "AND SA2.A2_MSBLQL <> '1' 		 "		
		endif 
		cMotQry += " AND D_E_L_E_T_= ' '      			 "
		cMotQry := ChangeQuery(cMotQry)
		
		oQry:SetQuery(cMotQry) 
		
		oQry:SetString(1,xFilial("SA2"))
		oQry:SetString(2,cCGCTP)
		
		cMotQry := oQry:GetFixQuery()
		MpSysOpenQuery(cMotQry,cAliTmp) 

		While !(cAliTmp)->(Eof()) .And. Alltrim((cAliTmp)->(A2_CGC)) == AllTrim(cCGCTP) 
			if !lAchouForn
				cCodigo  := (cAliTmp)->A2_COD
				cLoja 	 := (cAliTmp)->A2_LOJA
				cNomeFor := (cAliTmp)->A2_NOME
				lAchouForn := .T.
			endif 	
			
			nQCNPJ++
			(cAliTmp)->(dbSkip())

		EndDo
		
		(cAliTmp)->(DbCloseArea())

		if nQCNPJ > 1 .And. lA140IFOR
			aFornec := ExecBlock("A140IFOR",.F.,.F.,{"SA2",cCGCTP,"",oFullXML})
			If ValType(aFornec) == "A" .And. Len(aFornec) >= 3
				cCodigo  := aFornec[1]
				cLoja 	 := aFornec[2]
				cNomeFor := aFornec[3]
				nQCNPJ   := 1
			endif 
		endif  

		If Empty(cCodigo)
			lProces := .F.
			//Verifica se está cadastrado o prestador de servico
			ImpXMLErr(lJob,cFile,@aErros,"COM007 - " + STR0040 + cRSocial  +" [" + Transform(cCGCTP,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0109,STR0208,STR0110,"COM007",@aErroERP)
		EndIf

		if lProces .And. nQCNPJ > 1 
			ImpXMLErr(lJob,cFile,@aErros,"COM028 - " + STR0227 + cRSocial  +" [" + Transform(cCGCTP,"@R! NN.NNN.NNN/NNNN-99") +"] "+ STR0228,STR0260,STR0229,"COM028",@aErroERP)
		 endif 
	EndIf
EndIf

//Nesse ponto, pois assim ja tera o Fornecedor cadastrado via cadastro automatico ou por ja existe fornecedor no ambiente
If lProces .And. !Empty(cCodigo) 
	cUFForn := GetAdvFVal("SA2","A2_EST",xFilial("SA2")+cCodigo+cLoja,1)
Endif

If lProces	
	If ValType(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_NNFSE")) == "O"
		//Tratamento para completar com os zeros a esquerda apenas se o documento for numerico
		If IsNumeric(AllTrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_NNFSE:TEXT))
			cDoc	:= StrZero(Val(AllTrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_NNFSE:TEXT)),TamSx3("F1_DOC")[1])
		Else 
			cDoc	:= AllTrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_NNFSE:TEXT)
		EndIf 

		cSerie	:= Replicate(" ", TamSx3("F1_SERIE")[1])

		If lComNFSNewDoc
			aNewDoc := ComNFSNewDoc(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_NNFSE:TEXT,oFullXML,"COL",cFile)
			If Len(aNewDoc) > 0
				cDoc 		:= aNewDoc[1]
				cDocEletr	:= aNewDoc[2]
			Endif
		Endif

		If ValType(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_DTEMISNFSE")) == "O"
			dDtEmis	:= StoD(StrTran(AllTrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_DTEMISNFSE:TEXT),"-",""))
			cHrEmis	:= Substr(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_DTEMISNFSE:TEXT,12)
		Else
			ImpXMLErr(lJob,cFile,@aErros,"COM034 - " + STR0240,STR0240,STR0241,"COM034",@aErroErp)
			//lJob = F -> Erro#Tag _DTEMISNFSE não encontrada#OK 
			//lJob = T -> Tag _DTEMISNFSE não encontrada#Verificar com quem originou o XML.
			lProces := .F.
		Endif

		If lProces
			If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_TOMADOR,"_UFTOM")) == "O" .And.;
				!Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_TOMADOR:_UFTOM:TEXT)
				cUFTom := oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_TOMADOR:_UFTOM:TEXT

				If lUFForn .And. !Empty(cUFForn) //Utilizar ESTADO (UF) do Fornecedor = T / Utiliza ESTADO (UF) do Tomador = F (Default)
					cUFTom := cUFForn
				Endif
			Else
				ImpXMLErr(lJob,cFile,@aErros,"COM038 - " + STR0243,STR0243,STR0241,"COM038",@aErroErp)
				//lJob = F -> Erro#Tag _UFTOM nao encontrada#OK
				//lJob = T -> Tag _UFTOM nao encontrada#Verificar com quem originou o XML.
				lProces := .F.
			EndIf
		Endif

		If lProces .And. ValType(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_NRPS")) == "O"
			cRPS := Alltrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_NRPS:TEXT)		
		Endif
		
		If lProces .And. ValType(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_CVERIFICANFSE")) == "O"
			cCodNFE := Alltrim(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_cVerificaNFSe:TEXT)
		Endif		 
	Else
		ImpXMLErr(lJob,cFile,@aErros,"COM035 - " + STR0242,STR0242,STR0241,"COM035",@aErroErp)
		//lJob = F -> Erro#Tag _NNFSE não encontrada#OK
		//lJob = T -> Tag _NNFSE não encontrada#Verificar com quem originou o XML.
		lProces	 := .F.
	Endif
Endif

If lProces
	DbSelectArea("SDS")
	SDS->(DbSetOrder(1))
	If (SDS->(DbSeek(xFilial("SDS")+cDoc+cSerie+cCodigo+cLoja)))//Filial + RPS + SERIE RPS + FORNECEDOR + LOJA  
		cTxtErro := "COM025 - " + STR0223+" "+cDoc+", "+STR0224+" "+cSerie+" , " + STR0225 + " " + STR0226 //"Documento cDoc, Serie cSerie, já processado. |  Verifique se o documento já foi importado para o ERP. 
		ImpXmlErr(lJob , cFile , @aErros, cTxtErro, cTxtErro, cTxtErro, "COM025" , @aErroErp, "ImpXMLNFsT")   
		lProces	 := .F.
	EndIf
Endif
  
If lProces 
	If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS,"_ITEM" )) == "A"
		aItens := oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM
		
		If Len(aItens) > 0
			// Codigo de servico
			cCodServ := Iif(ValType(aItens[1]:_CODIGOITEMLISTASERVICO) == "O" .And. !Empty(aItens[1]:_CODIGOITEMLISTASERVICO:TEXT),;
							aItens[1]:_CODIGOITEMLISTASERVICO:TEXT,;
							Iif(ValType(aItens[1]:_CITEMLISTASERVICO) == "O" .And. !Empty(aItens[1]:_CITEMLISTASERVICO:TEXT),;
								aItens[1]:_CITEMLISTASERVICO:TEXT,;
								Iif(ValType(aItens[1]:_CODIGOCFPS) == "O" .And. !Empty(aItens[1]:_CODIGOCFPS:TEXT),;
									aItens[1]:_CODIGOCFPS:TEXT,;
									Iif(ValType(aItens[1]:_CTRIBUTMUN) == "O" .And. !Empty(aItens[1]:_CTRIBUTMUN:TEXT),;
										aItens[1]:_CTRIBUTMUN:TEXT,""))))
			 
			//ISS pela tag ITEM
			If ValType(XmlChildEx(aItens[1],"_ALISS")) == "O" .And. !Empty(aItens[1]:_ALISS:TEXT)
				nAlqISS		:= Val(aItens[1]:_ALISS:TEXT)
			Endif

			If ValType(XmlChildEx(aItens[1],"_VLISS")) == "O" .And. !Empty(aItens[1]:_VLISS:TEXT)
				nVlrISS		:= Val(aItens[1]:_VLISS:TEXT)
			Endif
			
			lISSIt := .T.
		Endif
	Elseif ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS,"_ITEM" )) == "O"
		//Verifica existencia do grupo Itens
        If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_VLUNIT" )) == "O" .And.;
            ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_VLITEM" )) == "O" .And.;
            ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_QTDE" )) == "O"

            aItens := {oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM}
        Endif

        If Len(aItens) > 0
			// Codigo de servico
			cCodServ := Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_CODIGOITEMLISTASERVICO")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CODIGOITEMLISTASERVICO:TEXT),;
							oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CODIGOITEMLISTASERVICO:TEXT ,;
							Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_CITEMLISTASERVICO")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CITEMLISTASERVICO:TEXT),;
								oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CITEMLISTASERVICO:TEXT,;
								Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_CODIGOCFPS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CODIGOCFPS:TEXT),;
									oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CODIGOCFPS:TEXT,;
									Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_CTRIBUTMUN")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CTRIBUTMUN:TEXT),;
										oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_CTRIBUTMUN:TEXT,""))))

            //ISS pela tag ITEM
            If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_ALISS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_ALISS:TEXT)
                nAlqISS		:= Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_ALISS:TEXT)
            Endif
            
            If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM,"_VLISS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_VLISS:TEXT)
                nVlrISS		:= Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_ITEM:_VLISS:TEXT)
            Endif

			If nVlrISS > 0 .And. nAlqISS > 0
				lISSIt := .T.
			EndIf
        Endif
	EndIf

	// Codigo de servico
	If Empty(cCodServ)
		cCodServ := Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_ITEMLISTASERV")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_ITEMLISTASERV:TEXT),;
						oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_ITEMLISTASERV:TEXT,;
						Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_CODIGOCFPS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_CODIGOCFPS:TEXT),;
							oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_CODIGOCFPS:TEXT,;
							Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_CTRIBUTMUN")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_CTRIBUTMUN:TEXT),;
								oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_CTRIBUTMUN:TEXT,"")))
	Endif

	//ISS pela tag SERVICO
    If !lISSIt
        If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_ALISS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_ALISS:TEXT)
            nAlqISS := Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_ALISS:TEXT)
        Endif
        
        If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_VLISS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLISS:TEXT)
            nVlrISS := Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLISS:TEXT)
        Endif
    Endif

	//PIS pela tag SERVICO
	If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_VLPIS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLPIS:TEXT)
		nVlrPIS := Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLPIS:TEXT)
	Endif 
	
	//CSLL pela tag SERVICO
	If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_VICSLL")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VICSLL:TEXT)
		nVlrCSLL := Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VICSLL:TEXT)
	Endif

	//IR pela tag SERVICO
	If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_VLIR")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLIR:TEXT)
		nVlrIR := Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLIR:TEXT)
	Endif

	//COFINS pela tag SERVICO
	If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_VLCOFINS")) == "O" .And. !Empty(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLCOFINS:TEXT)
		nVlrCOF := Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLCOFINS:TEXT)
	Endif
    
    // Descricao do servico
    If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_DESCRICAO,"_DESRPS")) == "O"
        cDescServ	:= oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_DESCRICAO:_DESRPS:TEXT			
    EndIf
    
    // Municipio do servico
    If ValType(XmlChildEx(oFUllXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_CMUNSERV")) == "O"
        cMunServ	:= Right(oFUllXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_CMUNSERV:TEXT,7)
    EndIf

	//CBSIBS
	If lTabDKM
		If ValType(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE,"_IBSCBS")) == "O" .And. ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS,"_IBSCBS")) == "O"
			If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_IBSCBS,"_VALORES")) == "O" .And. ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_IBSCBS:_VALORES,"_TRIB")) == "O" .And. ;
				ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_IBSCBS:_VALORES:_TRIB,"_GIBSCBS")) == "O"
				oCBSIBSRps	:= oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_IBSCBS:_VALORES:_TRIB:_GIBSCBS
			Endif	

			If ValType(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_IBSCBS,"_VALORES")) == "O"
				oCBSIBSVlr := oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_IBSCBS:_VALORES
			Endif

			If ValType(XmlChildEx(oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_IBSCBS,"_TOTCIBS")) == "O"
				oCBSIBSTot := oFullXML:_TRANSMITE:_RETTRANSMITENFSE:_IBSCBS:_TOTCIBS
			Endif

			If ValType(oCBSIBSRps) == "O" .And. ValType(oCBSIBSVlr) == "O"	.And. ValType(oCBSIBSTot) == "O"

				cCSTCBSIBS	:= If(ValType(XmlChildEx(oCBSIBSRps,"_CST")) == "O", oCBSIBSRps:_CST:Text,"")
				cClassTrib	:= If(ValType(XmlChildEx(oCBSIBSRps,"_CCLASSTRIB")) == "O", oCBSIBSRps:_CCLASSTRIB:Text,"")

				If ValType(XmlChildEx(oCBSIBSVlr,"_VBC")) == "O"
					nBIBSCBS	:= If(ValType(XmlChildEx(oCBSIBSVlr,"_VBC")) == "O", Val(oCBSIBSVlr:_vBC:Text), 0)	

					//IBSUF - Aliquota
					//IBSUF - % Red Aliq
					//IBSUF - % Aliq Efet
					If ValType(XmlChildEx(oCBSIBSVlr,"_UF")) == "O"
						nAIBSUF    := If(ValType(XmlChildEx(oCBSIBSVlr:_UF,"_PIBSUF")) == "O", Val(oCBSIBSVlr:_UF:_PIBSUF:Text), 0)
						nAREDIBSUF := If(ValType(XmlChildEx(oCBSIBSVlr:_UF,"_PREDALIQUF")) == "O", Val(oCBSIBSVlr:_UF:_PREDALIQUF:Text), 0)
						nAREEIBSUF := If(ValType(XmlChildEx(oCBSIBSVlr:_UF,"_PALIQEFETUF")) == "O", Val(oCBSIBSVlr:_UF:_PALIQEFETUF:Text), 0)
					Endif

					//IBSUF - Valor
					If ValType(XmlChildEx(oCBSIBSTot,"_GIBS")) == "O" .And. ValType(XmlChildEx(oCBSIBSTot:_GIBS,"_GIBSUFTOT")) == "O"
						nVIBSUF := If(ValType(XmlChildEx(oCBSIBSTot:_GIBS:_GIBSUFTOT,"_VIBSUF")) == "O", Val(oCBSIBSTot:_GIBS:_GIBSUFTOT:_VIBSUF:Text), 0)
					Endif

					//IBSUF - Aliquota Dif
					If ValType(XmlChildEx(oCBSIBSRps,"_GDIF")) == "O"
						nADIFIBSUF := If(ValType(XmlChildEx(oCBSIBSRps:_GDIF,"_PDIFUF")) == "O", Val(oCBSIBSRps:_GDIF:_PDIFUF:Text), 0)
					Endif

					//IBSUF - Valor Dif
					If ValType(XmlChildEx(oCBSIBSTot,"_GIBS")) == "O" .And. ValType(XmlChildEx(oCBSIBSTot:_GIBS,"_GIBSUFTOT")) == "O"
						nVDIFIBSUF := If(ValType(XmlChildEx(oCBSIBSTot:_GIBS:_GIBSUFTOT,"_VDIFUF")) == "O", Val(oCBSIBSTot:_GIBS:_GIBSUFTOT:_VDIFUF:Text), 0)
					Endif

					//IBSMun - Aliquota
					//IBSMun - % Red Aliq
					//IBSMun - % Aliq Efet
					If ValType(XmlChildEx(oCBSIBSVlr,"_MUN")) == "O"
						nAIBSMUN    := If(ValType(XmlChildEx(oCBSIBSVlr:_MUN,"_PIBSMUN")) == "O", Val(oCBSIBSVlr:_MUN:_PIBSMUN:Text), 0)
						nAREDIBSMUN := If(ValType(XmlChildEx(oCBSIBSVlr:_MUN,"_PREDALIQMUN")) == "O", Val(oCBSIBSVlr:_MUN:_PREDALIQMUN:Text), 0)
						nAREEIBSMUN := If(ValType(XmlChildEx(oCBSIBSVlr:_MUN,"_PALIQEFETMUN")) == "O", Val(oCBSIBSVlr:_MUN:_PALIQEFETMUN:Text), 0)
					Endif

					//IBSMun - Valor
					If ValType(XmlChildEx(oCBSIBSTot,"_GIBS")) == "O" .And. ValType(XmlChildEx(oCBSIBSTot:_GIBS,"_GIBSMUNTOT")) == "O"
						nVIBSMUN := If(ValType(XmlChildEx(oCBSIBSTot:_GIBS:_GIBSMUNTOT,"_VIBSMUN")) == "O", Val(oCBSIBSTot:_GIBS:_GIBSMUNTOT:_VIBSMUN:Text), 0)
					Endif

					//IBSMun - Aliquota Dif
					If ValType(XmlChildEx(oCBSIBSRps,"_GDIF")) == "O"
						nADIFIBSMUN := If(ValType(XmlChildEx(oCBSIBSRps:_GDIF,"_PDIFMUN")) == "O", Val(oCBSIBSRps:_GDIF:_PDIFMUN:Text), 0)
					Endif

					//IBSMun - Valor Dif
					If ValType(XmlChildEx(oCBSIBSTot,"_GIBS")) == "O" .And. ValType(XmlChildEx(oCBSIBSTot:_GIBS,"_GIBSMUNTOT")) == "O"
						nVDIFIBSMUN := If(ValType(XmlChildEx(oCBSIBSTot:_GIBS:_GIBSMUNTOT,"_VDIFMUN")) == "O", Val(oCBSIBSTot:_GIBS:_GIBSMUNTOT:_VDIFMUN:Text), 0)
					Endif 

					//CBS - Aliquota
					//CBS - % Red Aliq
					//CBS - % Aliq Efet
					If ValType(XmlChildEx(oCBSIBSVlr,"_FED")) == "O"
						nACBS    := If(ValType(XmlChildEx(oCBSIBSVlr:_FED,"_PCBS")) == "O", Val(oCBSIBSVlr:_FED:_PCBS:Text), 0)
						nAREDCBS := If(ValType(XmlChildEx(oCBSIBSVlr:_FED,"_PREDALIQCBS")) == "O", Val(oCBSIBSVlr:_FED:_PREDALIQCBS:Text), 0)
						nAREECBS := If(ValType(XmlChildEx(oCBSIBSVlr:_FED,"_PALIQEFETCBS")) == "O", Val(oCBSIBSVlr:_FED:_PALIQEFETCBS:Text), 0)
					Endif

					//CBS - Valor
					If ValType(XmlChildEx(oCBSIBSTot,"_GCBS")) == "O"
						nVCBS := If(ValType(XmlChildEx(oCBSIBSTot:_GCBS,"_VCBS")) == "O", Val(oCBSIBSTot:_GCBS:_VCBS:Text), 0)
					Endif

					//CBS - Aliquota Dif
					If ValType(XmlChildEx(oCBSIBSRps,"_GDIF")) == "O"
						nADIFCBS := If(ValType(XmlChildEx(oCBSIBSRps:_GDIF,"_PDIFCBS")) == "O", Val(oCBSIBSRps:_GDIF:_PDIFCBS:Text), 0)
					Endif

					//CBS - Valor Dif
					If ValType(XmlChildEx(oCBSIBSTot,"_GCBS")) == "O"
						nVDIFCBS := If(ValType(XmlChildEx(oCBSIBSTot:_GCBS,"_VDIFCBS")) == "O", Val(oCBSIBSTot:_GCBS:_VDIFCBS:Text), 0)
					Endif

					//CBS e IBS Como seria tributação caso não cumprida a condição resolutória/suspensiva
					If ValType(XmlChildEx(oCBSIBSRps,"_GTRIBREGULAR")) == "O"
						cCSTReg	    := If(ValType(XmlChildEx(oCBSIBSRps:_GTRIBREGULAR,"_CSTREG")) == "O", oCBSIBSRps:_GTRIBREGULAR:_CSTREG:Text, "")
						cClasReg    := If(ValType(XmlChildEx(oCBSIBSRps:_GTRIBREGULAR,"_CCLASSTRIBREG")) == "O", oCBSIBSRps:_GTRIBREGULAR:_CCLASSTRIBREG:Text, "") 
					Endif

					//CBS e IBS Como seria tributação caso não cumprida a condição resolutória/suspensiva
					If ValType(XmlChildEx(oCBSIBSTot,"_GTRIBREGULAR")) == "O"
						nAIBSUFReg  := If(ValType(XmlChildEx(oCBSIBSTot:_GTRIBREGULAR,"_PALIQEFEREGIBSUF")) == "O", Val(oCBSIBSTot:_GTRIBREGULAR:_PALIQEFEREGIBSUF:Text), 0)
						nVIBSUFReg  := If(ValType(XmlChildEx(oCBSIBSTot:_GTRIBREGULAR,"_VTRIBREGIBSUF")) == "O", Val(oCBSIBSTot:_GTRIBREGULAR:_VTRIBREGIBSUF:Text), 0)
						nAIBSMunReg := If(ValType(XmlChildEx(oCBSIBSTot:_GTRIBREGULAR,"_PALIQEFEREGIBSMUN")) == "O", Val(oCBSIBSTot:_GTRIBREGULAR:_PALIQEFEREGIBSMUN:Text), 0)
						nVIBSMunReg := If(ValType(XmlChildEx(oCBSIBSTot:_GTRIBREGULAR,"_VTRIBREGIBSMUN")) == "O", Val(oCBSIBSTot:_GTRIBREGULAR:_VTRIBREGIBSMUN:Text), 0)
						nACBSReg	:= If(ValType(XmlChildEx(oCBSIBSTot:_GTRIBREGULAR,"_PALIQEFEREGCBS")) == "O", Val(oCBSIBSTot:_GTRIBREGULAR:_PALIQEFEREGCBS:Text), 0)
						nVCBSReg	:= If(ValType(XmlChildEx(oCBSIBSTot:_GTRIBREGULAR,"_VTRIBREGCBS")) == "O", Val(oCBSIBSTot:_GTRIBREGULAR:_VTRIBREGCBS:Text), 0)
					Endif

					//Codigo Credito Presumido
					cCredPreIBS := If(ValType(XmlChildEx(oCBSIBSRps,"_CCREDPRES")) == "O", oCBSIBSRps:_CCREDPRES:Text, "")
					cCredPreCBS := If(ValType(XmlChildEx(oCBSIBSRps,"_CCREDPRES")) == "O", oCBSIBSRps:_CCREDPRES:Text, "")
					
					//Aliquota/Valor Credito Presumido IBS
					If ValType(XmlChildEx(oCBSIBSTot,"_GIBS")) == "O" .And. ValType(XmlChildEx(oCBSIBSTot:_GIBS,"_GIBSCREDPRES")) == "O"
						nAlCrePrIBS := If(ValType(XmlChildEx(oCBSIBSTot:_GIBS:_GIBSCREDPRES,"_PCREDPRESIBS")) == "O", Val(oCBSIBSTot:_GIBS:_GIBSCREDPRES:_PCREDPRESIBS:Text), 0)
						nVlCrePrIBS := If(ValType(XmlChildEx(oCBSIBSTot:_GIBS:_GIBSCREDPRES,"_VCREDPRESIBS")) == "O", Val(oCBSIBSTot:_GIBS:_GIBSCREDPRES:_VCREDPRESIBS:Text), 0)
					Endif

					//Aliquota/Valor Credito Presumido CBS
					If ValType(XmlChildEx(oCBSIBSTot,"_GCBS")) == "O" .And. ValType(XmlChildEx(oCBSIBSTot:_GCBS,"_GCBSCREDPRES")) == "O"
						nAlCrePrCBS := If(ValType(XmlChildEx(oCBSIBSTot:_GCBS:_GCBSCREDPRES,"_PCREDPRESCBS")) == "O", Val(oCBSIBSTot:_GCBS:_GCBSCREDPRES:_PCREDPRESCBS:Text), 0)
						nVlCrePrCBS := If(ValType(XmlChildEx(oCBSIBSTot:_GCBS:_GCBSCREDPRES,"_VCREDPRESCBS")) == "O", Val(oCBSIBSTot:_GCBS:_GCBSCREDPRES:_VCREDPRESCBS:Text), 0)
					Endif
				Endif
			Endif
		Endif
	Endif
	
	//Ponto de entrada para manipular o código do serviço
	IF ExistBlock("MT140ISV")
		cMT140ISV 	:= ExecBlock("MT140ISV",.F.,.F.,{cCodServ, cMunServ, cCGCTT, cCGCTP})
		cCodServ	:= Iif(ValType(cMT140ISV) == "C" .And. !Empty(cCodServ),cMT140ISV,cCodServ)
	Endif
	                      
	//Pesquisa um produto que possui amarração com fornecedor do XML e possui o codigo de servico correto.                    
	cQry	:= " SELECT SB1.B1_COD, SB1.B1_DESC"
	cQry	+= " FROM " + RetSqlName("SB1") + " SB1"
	cQry	+= " INNER JOIN " + RetSqlName("SA5") + " SA5 ON SA5.A5_PRODUTO = SB1.B1_COD AND SA5.D_E_L_E_T_ = ''"
	cQry	+= " INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_COD = SA5.A5_FORNECE AND SA2.A2_LOJA = SA5.A5_LOJA AND SA2.D_E_L_E_T_ = ''"
	cQry	+= " LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ''"
	cQry	+= " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	
	If ExistBlock("MT140FSV")
		cFiltro := ExecBlock("MT140FSV",.F.,.F.,{cCodServ, cMunServ, cCGCTT, cCGCTP})
		cFiltro := Iif(ValType(cFiltro) <> "C","",cFiltro)
	Endif
		
	cQry	+= " AND (SB1.B1_CODISS = '" + cCodServ + "' OR SBZ.BZ_CODISS = '" + cCodServ + "' OR SA5.A5_CODPRF = '" + cCodServ + "' " + cFiltro + " )"
	cQry	+= " AND SA2.A2_COD = '" + cCodigo + "' AND SA2.A2_LOJA = '" + cLoja +"'"
	cQry	+= " AND SB1.D_E_L_E_T_ = ''"
			
	cQry := ChangeQuery(cQry)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"SB1TMP", .T., .T.)                   
        
    If SB1TMP->(!Eof()) //Verifica se possui pelo menos uma ocorrencia do codigo de serviço do XML 
		cProduto:= SB1TMP->B1_COD
	Elseif lImpXTra .And. FindFunction("ImpCadAutP")
		cProduto 	:= ImpCadAutP(oFUllXML,"140ITS")
		cStatusAut	:= "B"
	Else  
		//Nao processa XML de outra empresa/filial
		ImpXMLErr(lJob,cFile,@aErros,"COM018 - " + STR0214+cCodServ+STR0215+SA2->A2_NOME+" ["+cCGCTP+"]. "+STR0217+cDescServ+".",STR0209,STR0216,"COM018",@aErroErp)

		//lJob = F ->"Erro"#"""Este XML possui um codigo de Serviço que não está cadastrado em um produto na empresa/filial corrente."#"OK"
		//lJob = T ->"Código de serviço "+cCodServ+" não cadastrado em um produto, na empresa/filial corrente, e/ou produto não possui amarração com o fornecedor "+SA2->A2_NOME+cCGC. Descrição do serviço:+cDescServ.
		lProces  := .F.
	EndIf  
	SB1TMP->(dbCloseArea())
EndIf

If lProces 	
	// Versao layout
	cNFsVersao := Iif(ValType(XmlChildEx(oFullXML,"_VERSAO")) == "O",;
					  oFullXML:_VERSAO:TEXT,;
					  Iif(ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS,"_VERSAO")) == "O",;
					  	  oFullXML:_TRANSMITE:_TRANSMITERPS:_VERSAO:TEXT,""))
	
	//Valor Total da Mercadoria 
	If ValType(XmlChildEx(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO,"_VLSERVICOS")) == "O"
		nValMTot := Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLSERVICOS:TEXT)
	EndIf

	//Grava os Dados do Cabecalho - SDS
	DbSelectArea("SDS")
	AADD(aHeadSDS,{{"DS_FILIAL"	    ,xFilial("SDS")																	    },; //Filial
				    {"DS_CNPJ"		,cCGCTP																				},; //CGC
				    {"DS_DOC"		,cDoc 																				},; //Numero do Documento
				    {"DS_SERIE"		,cSerie 																			},; //Serie
				    {"DS_FORNEC"	,cCodigo																			},; //Fornecedor
				    {"DS_LOJA"		,cLoja 																				},; //Loja do Fornecedor
				    {"DS_NOMEFOR"	,cNomeFor																			},; //Nome do Fornecedor
				    {"DS_EMISSA"	,dDtEmis										 						   			},; //Data de Emissão
				    {"DS_EST"		,cUFTom																				},; //Estado de emissao da NF
				    {"DS_TIPO"		,"N"																				},; //Tipo da Nota
				    {"DS_FORMUL"	,"N" 																		 		},; //Formulario proprio
				    {"DS_CHAVENF"	,xFilial("SDS")+cDoc+cSerie+cCodigo+cLoja											},; //Chave de Acesso da NF
				    {"DS_ESPECI"	,"NFS"																		  		},; //Especie
				    {"DS_ARQUIVO"	,AllTrim(cFile)																   		},; //Arquivo importado
				    {"DS_STATUS"	,"" 			 																	},; //Status
				    {"DS_VERSAO"	,cNFsVersao																			},; //Versao
				    {"DS_USERIMP"	,IIf(!lJob,cUserName,"Importador XML")														},; //Usuario na importacao
				    {"DS_DATAIMP"	,dDataBase																			},; //Data importacao do XML
				    {"DS_HORAIMP"	,SubStr(Time(),1,5)															   		},; //Hora importacao XML
				   	{"DS_CODNFE" 	,cCodNFE																			},; //Codigo de verificaçao na NFe
					{"DS_NUMRPS"	,cRPS																				},; //Numero do RPS
					{"DS_HORNFE"	,cHrEmis																			},; ////Hora de emissao da NFe
					{"DS_VALMERC"	,nValMTot																			},;	//Valor Mercadoria
					{"DS_TOTAL"		,nValMTot																			}}) //Valor Total da Nota Fiscal 

	If !Empty(cDocEletr) .And. oObjImp:lCpoNewDoc
		aAdd(aHeadSDS[Len(aHeadSDS)],{"DS_NFELETR" , cDocEletr})
	Endif

	//Dados dos Itens - SDT
	If Len(aItens) > 0
		For nX := 1 To Len(aItens)
			nQtdeIt	:= Val(aItens[nX]:_QTDE:TEXT)
			nPrcIt	:= Val(aItens[nX]:_VLUNIT:TEXT)	
			nTotIt	:= Val(aItens[nX]:_VLITEM:TEXT)
			cNatRen := ""

			If lUnidMed
				cUmNfe := GetAdvFVal("SA5","A5_UMNFE",xFilial("SA5")+cCodigo+cLoja+cCodServ,14," ") //Unidade de medida da NF para o produto do fornecedor

				If Empty(cUmNfe)
					cUmNfe := GetAdvFVal("SA5","A5_UMNFE",xFilial("SA5")+cCodigo+cLoja+cProduto,1," ") //Unidade de medida da NF
				EndIf

				lConvUM 	:= cUmNfe == "2" //Segunda unidade de medida
				
				cUM			:= GetAdvFVal("SB1","B1_UM",xFilial("SB1")+cProduto,1)
				cSEGUM		:= GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+cProduto,1)
				nQtSEGUM	:= 0
				lFatorConv	:= COLVLSEGUM(cProduto,cSEGUM)

				If !Empty(cSEGUM)
					If lConvUM
						//Produto não possui fator de conversão e não tem como converter para primeira
						//unidade de medida
						If !lFatorConv
							//"Não foi possivel converter para 1ª unidade de medida, pois o produto não possui fator de conversão. "
							lProces := .F.
							ImpXMLErr(lJob,cFile,@aErros,"COM050 - " + STR0253 + cProduto,"",STR0198,"COM050",@aErroErp)
						Else
							nQtSEGUM := nQtdeIt
							nQtdeIt	 := ConvUM(cProduto,nQtdeIt,nQtdeIt,1)
							nPrcIt	 := nTotIt / nQtdeIt
						Endif
					Else
						nQtSEGUM := Iif(lFatorConv,ConvUM(cProduto,nQtdeIt,nQtdeIt,2),0)
					Endif
				Endif
			Endif

			DbSelectArea("SDT")                                               
			aAdd(aItemSDT,{{"DT_FILIAL" 	,xFilial("SDT")														},; //Filial
							{"DT_CNPJ"		,cCGCTP																},; //CGC Tag Prestador
			 				{"DT_COD"		,cProduto															},; //Codigo do produto
			 				{"DT_PRODFOR"	,cCodServ															},; //Cdgo do pduto do Fornecedor
		 					{"DT_DESCFOR"	,aItens[nX]:_DISSERV:TEXT											},; //Dcao do pduto do Fornecedor
		 					{"DT_ITEM"   	,PadL(cValToChar(nX),TamSX3("D1_ITEM")[1],"0")						},; //Item
		 					{"DT_QUANT"  	,nQtdeIt                									   		},; //Qtde
			 				{"DT_VUNIT"		,nPrcIt                     										},; //Vlor Unitário
			 				{"DT_FORNEC"	,cCodigo															},; //Forncedor
			 				{"DT_LOJA"   	,cLoja																},; //Lja
				 			{"DT_DOC"    	,cDoc																},; //DocmTo
		 					{"DT_SERIE"		,cSerie							   									},; //Serie
		 					{"DT_TOTAL"		,nTotIt                     										}}) //Vlor Total
		 					
						 	If ValType(XmlChildEx(aItens[nX],"_ALISS")) == "O" .And. !Empty(aItens[nX]:_ALISS:TEXT)
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALQISS"  , Val(aItens[nX]:_ALISS:TEXT)})
							Elseif nAlqISS > 0 .And. Len(aItens) == 1
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALQISS"  , nAlqISS})
							Endif
							
							If ValType(XmlChildEx(aItens[nX],"_VLISS")) == "O" .And. !Empty(aItens[nX]:_VLISS:TEXT)
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLISS"  , Val(aItens[nX]:_VLISS:TEXT)})
							Elseif nVlrISS > 0 .And. Len(aItens) == 1
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLISS"  , nVlrISS})
							Endif

							If ValType(XmlChildEx(aItens[nX],"_VLPIS")) == "O" .And. !Empty(aItens[nX]:_VLPIS:TEXT)
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLPIS"  , Val(aItens[nX]:_VLPIS:TEXT)}) 
							Elseif nVlrPIS > 0 .And. Len(aItens) == 1
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLPIS"  , nVlrPIS})
							Endif

							If ValType(XmlChildEx(aItens[nX],"_VLCOFINS")) == "O" .And. !Empty(aItens[nX]:_VLCOFINS:TEXT)
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLCOF"  , Val(aItens[nX]:_VLCOFINS:TEXT)}) 
							Elseif nVlrCOF > 0 .And. Len(aItens) == 1
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLCOF"  , nVlrCOF})
							Endif

							If nPosVIR > 0 .and. nVlrIR > 0
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLVIR"  , nVlrIR})
							Endif

							If nPosVCSL > 0 .and. nVlrCSLL > 0
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLVCSL"  , nVlrCSLL})
							EndIf

							If lUnidMed
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_UM"  		, cUM})
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_SEGUM"  	, cSEGUM})
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_QTSEGUM"  , nQtSEGUM})
							Endif

							if lNatRen .And. FindFunction("A103GetNat")
								cNatRen := A103GetNat(cProduto)
								if !empty(cNatRen)
									aAdd(aItemSDT[Len(aItemSDT)],{"DT_NATREN", cNatRen})
								endif
							endif
		Next nX
	Else
		nQtdeIt	:= 1
		nPrcIt	:= Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLSERVICOS:TEXT)
		nTotIt	:= Val(oFullXML:_TRANSMITE:_TRANSMITERPS:_RPS:_SERVICO:_VLSERVICOS:TEXT)
		cNatRen := ""
		
		If lUnidMed
			cUmNfe := GetAdvFVal("SA5","A5_UMNFE",xFilial("SA5")+cCodigo+cLoja+cCodServ,14," ") //Unidade de medida da NF para o produto do fornecedor

			If Empty(cUmNfe)
				cUmNfe := GetAdvFVal("SA5","A5_UMNFE",xFilial("SA5")+cCodigo+cLoja+cProduto,1," ") //Unidade de medida da NF
			EndIf

			lConvUM 	:= cUmNfe == "2" //Segunda unidade de medida
			
			cUM			:= GetAdvFVal("SB1","B1_UM",xFilial("SB1")+cProduto,1)
			cSEGUM		:= GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+cProduto,1)
			nQtSEGUM	:= 0
			lFatorConv	:= COLVLSEGUM(cProduto,cSEGUM)

			If !Empty(cSEGUM)
				If lConvUM
					//Produto não possui fator de conversão e não tem como converter para primeira
					//unidade de medida
					If !lFatorConv 
						//"Não foi possivel converter para 1ª unidade de medida, pois o produto não possui fator de conversão. "
						lProces := .F.
						ImpXMLErr(lJob,cFile,@aErros,"COM050 - " + STR0253 + cProduto,"",STR0198,"COM050",@aErroErp)
					Else
						nQtSEGUM := nQtdeIt
						nQtdeIt	 := ConvUM(cProduto,nQtdeIt,nQtdeIt,1)
						nPrcIt	 := nTotIt / nQtdeIt
					Endif
				Else
					nQtSEGUM := Iif(lFatorConv,ConvUM(cProduto,nQtdeIt,nQtdeIt,2),0) 
				Endif
			Endif
		Endif

		DbSelectArea("SDT")                                               
   		aAdd(aItemSDT,{{"DT_FILIAL"		,xFilial("SDT")																},; //Filial
						{"DT_CNPJ"		,cCGCTP																		},; //CGC Tag Prestador
		 				{"DT_COD"		,cProduto																	},; //Codigo do produto
		 				{"DT_PRODFOR"	,cCodServ																	},; //Cdgo do pduto do Fornecedor
	 					{"DT_ITEM"		,PadL("1",TamSX3("D1_ITEM")[1],"0")											},; //Item
	 					{"DT_QUANT" 	,1									   										},; //Qtde
		 				{"DT_VUNIT"		,nPrcIt																		},; //Vlor Unitário
		 				{"DT_FORNEC"	,cCodigo																	},; //Forncedor
		 				{"DT_LOJA"   	,cLoja																		},; //Lja
			 			{"DT_DOC"    	,cDoc																		},; //DocmTo
	 					{"DT_SERIE"		,cSerie							   											},; //Serie
	 					{"DT_TOTAL"		,nPrcIt																		},; //Vlor Total
	 					{"DT_XALQISS"	,nAlqISS																	},; //Aliquota ISS
	 					{"DT_XMLISS"	,nVlrISS																	},; //Valor ISS
						{"DT_XMLPIS"	,nVlrPIS																	},; //Valor PIS
						{"DT_XMLCOF"	,nVlrCOF			 														}}) //Valor COF

						if nPosVIR > 0 .and. nVlrIR > 0
							aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLVIR"  	,nVlrIR})
						endif 

						if nPosVCSL > 0 .and. nVlrCSLL > 0
							aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLVCSL" ,nVlrCSLL})
						endif
						

						If lUnidMed 
							aAdd(aItemSDT[Len(aItemSDT)],{"DT_UM"  		, cUM})
							aAdd(aItemSDT[Len(aItemSDT)],{"DT_SEGUM"  	, cSEGUM})
							aAdd(aItemSDT[Len(aItemSDT)],{"DT_QTSEGUM"  , nQtSEGUM})
						Endif 

						if lNatRen .And. FindFunction("A103GetNat")
							cNatRen := A103GetNat(cProduto)
							if !empty(cNatRen)
								aAdd(aItemSDT[Len(aItemSDT)],{"DT_NATREN", cNatRen})
							endif
						endif
	EndIf								 			 						

	//Grava os dados do cabeçalho e itens da nota importada do XML
	If lProces
		Begin Transaction	
			aHeadSDS:=aHeadSDS[1]
			//--Grava cabeçalho
			RecLock("SDS",.T.)
			For nX:=1	To Len(aHeadSDS)
				If AllTrim(aHeadSDS[nX][1]) == "DS_STATUS" .And. !Empty(cStatusAut)
					SDS->&(aHeadSDS[nX][1]):= cStatusAut
				Else
					SDS->&(aHeadSDS[nX][1]):= aHeadSDS[nX][2]
				Endif
			Next nX
			SDS->(dbCommit())
			SDS->(MsUnlock())
			//--Grava Itens
			For nX:=1 To Len(aItemSDT)
				RecLock("SDT",.T.)
				For nY:=1 To Len(aItemSDT[nX])
					SDT->&(aItemSDT[nX][nY][1]):= aItemSDT[nX][nY][2]
				Next nY
				SDT->(dbCommit())
				SDT->(MsUnlock())
			Next nX
			aAdd(aProc,{cDoc,cSerie,cNomeFor})
			lAtuDKM := .T.					
		End Transaction
	Endif     
EndIf

If lProces .And. lTabDKM .And. lAtuDKM
	cItemSDT := StrZero(1,TamSX3("DT_ITEM")[1])

	//IBSUF
	aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000060' )	
					{"DKM_DOC"		,cDoc},;			// Numero Documento             
					{"DKM_SERIE"	,cSerie},;			// Serie                    
					{"DKM_FORNEC"	,cCodigo},;			// Fornecedor / Cliente     
					{"DKM_LOJA"		,cLoja},;			// Loja                     
					{"DKM_TIPO"		, "N"	},;			// Tipo Nota                
					{"DKM_ESPECI"	,"NFS"},;			// Especie                  
					{"DKM_ITEM"		,cItemSDT	},;		// Item NF                  
					{"DKM_COD"		,""},;				// Produto                  
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
					{"DKM_FORNEC"	,cCodigo},;			// Fornecedor / Cliente     
					{"DKM_LOJA"		,cLoja},;			// Loja                     
					{"DKM_TIPO"		, "N"	},;			// Tipo Nota                
					{"DKM_ESPECI"	,"NFS"},;			// Especie                  
					{"DKM_ITEM"		,cItemSDT	},;		// Item NF                  
					{"DKM_COD"		,""},;				// Produto                  
					{"DKM_TRIB"		,"IBSMun"},;		// Tributo / Imposto        
					{"DKM_XMLBAS"	,nBIBSCBS},;		// Base CBS/IBS NO XML	
					{"DKM_XMLALQ"	,nAIBSMun},;		// Aliquota IBS Mun NO XML	
					{"DKM_XMLVLR"	,nVIBSMun},;		// Valor IBS Mun NO XML	
					{"DKM_BASE"		,0},;				// Base IBS Mun	
					{"DKM_ALIQ"		,0},;				// Aliquota IBS Mun
					{"DKM_VALOR"	,0},;				// Valor IBS Mun
					{"DKM_PDIF"		,nADIFIBSMun},;		// Aliquota Diferencial IBS Mun
					{"DKM_VDIF"		,nVDIFIBSMun},;		// Valor Diferencial IBS Mun	
					{"DKM_VDEV"		,nVDEVIBSMun},;		// Valor Devolvido IBS Mun
					{"DKM_PREDAL"	,nAREDIBSMun},;		// Aliquota Reduzida Classifição Tributaria	
					{"DKM_PALIEF"	,nAREEIBSMun},;		// Aliquota Efetiva	
					{"DKM_CST"		,cCSTCBSIBS},;		// CST IBS Mun
					{"DKM_CLASTR"	,cClassTrib},;		// Classificação Tributaria	
					{"DKM_CSTRE"	,cCSTReg},;			// CST Regular (Seria se fosse)	
					{"DKM_CLAREG"	,cClasReg},;		// Classificação Tributaria (Seria se fosse)	
					{"DKM_ALQEFE"	,nAIBSMunReg},;		// Aliquota IBS Mun (Seria se fosse)	
					{"DKM_VLREFE"	,nVIBSMunReg},;		// Valor IBS Mun (Seria se fosse)	
					{"DKM_CODCRE"	,""},;				// Codigo Credito Presumido IBS	
					{"DKM_ALQPRE"	,0},;				// Aliquota Credito Presumido IBS	
					{"DKM_VLRPRE"	,0},;				// Valor Credito Presumido IBS	
					{"DKM_VSPRE"	,0},;				// Vlr Suspensao Cred Presum
					{"DKM_ORIGEM"   ,"COMXCOL" }})		// Origem do lancamento
	
	//CBS
	aAdd(aDadosDKM,{{"DKM_FILIAL"	,XFILIAL("DKM")},;	// Filial do Sistema                      Tributo    ( ID TOTVS = '000062' )	
					{"DKM_DOC"		,cDoc},;			// Numero Documento             
					{"DKM_SERIE"	,cSerie},;			// Serie                    
					{"DKM_FORNEC"	,cCodigo},;			// Fornecedor / Cliente     
					{"DKM_LOJA"		,cLoja},;			// Loja                       
					{"DKM_TIPO"		, "N"},;			// Tipo Nota                
					{"DKM_ESPECI"	,"NFS"},;			// Especie                  
					{"DKM_ITEM"		,cItemSDT	},;		// Item NF                  
					{"DKM_COD"		,""},;				// Produto                  
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
	
	If Len(aDadosDKM) > 0
		COMNEWIMP(aDadosDKM)
	
		//Atualiza UIDFK e TABELA
		COLUPDDKM(,2,"SDT",cDoc,cSerie,cCodigo,cLoja,"NFS")	

		//Busca total de itens do NFS
		aColsDT := {}
		A116IDocIt(cDoc,cSerie,cCodigo,cLoja,@aColsDT,@aHeadDT) 

		//Atualiza DKM - Rateando conforme necessidade
		COLUPDDKM(aColsDT,1,,,,,,"NFS",aHeadDT) 

		//Atualiza UIDFK e TABELA
		COLUPDDKM(,2,"SDT",cDoc,cSerie,cCodigo,cLoja,"NFS")	
	Endif
Endif

// ------------------------------------------------------------------------------------------ //
// Limpa o objeto oFullXMl, conforme orientado pelo Framework, se faz necessário a utilizacao //
// do DelClassIntf para que o objeto realmente seja limpo.                                    //
// Caso contrario, em situacoes onde existir um grande numero de XMLs Parseados, ocorrera a   //
// mensagem: XML dynamic Nodes Overflow                                                       //
// Antes de executar o comando: DesClassIntf, coloque o objeto como NIL                       //
// ------------------------------------------------------------------------------------------ //
oFullXML := Nil
DelClassIntf()

Return lProces

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCadAutF
Automação cadastral de fornecedor/cliente

@param	oXML		XML sendo importado
@param	cPrw		Rotina sendo executada
@param	cTipoDoc	DB - Cliente | CN - Fornecedor

@author	Rodrigo M Pontes
@since 14/05/22
/*/
//------------------------------------------------------------------- 

Function ImpCadAutF(oXML,cPrw,cTipoDoc)

Local lPJ			:= .F.
Local lSA2			:= .F.
Local lFindApi		:= .F.
Local lApiFor   	:= SuperGetMv("MV_APIFOR", .F., .F.) .And. FindFunction("APIFORCLI")
Local cTabEmit		:= ""
Local cCpoEmit		:= ""
Local cCpoTipo		:= ""
Local cCGC			:= ""
Local cCod			:= ""
Local cEnd			:= ""
Local cNumEnd		:= ""
Local cDDD			:= ""
Local cTEL			:= ""
Local cRet			:= ""
Local cIniCdFC		:= ""
Local cIniLjFC		:= ""
Local aRetJson		:= {}
Local aDadosFC		:= {}
Local aTel			:= {}
Local aRet			:= {}
Local aErroMVC		:= {}
Local aAreaSA1		:= SA1->(GetArea())
Local cErroMVC		:= ""
Local nI			:= 0
Local oJson  		:= Nil
Local oCadModel		:= Nil
Local oXMLForCli	:= Nil
Local oXMLEnd		:= Nil
Local oCmplCli		:= Nil 
Local lAI0Origem 	:= CHKFile("AI0") .And. AI0->(FieldPos("AI0_CADORI")) > 0

If cTipoDoc $ "DB"
	cTabEmit := "SA1"
	cCpoEmit := Substr(cTabEmit,2,2)
	cCpoTipo := "_PESSOA"
Else
	cTabEmit := "SA2"
	cCpoEmit := Substr(cTabEmit,2,2)
	lSA2	 := .T.
	cCpoTipo := "_TIPO"
Endif

cIniCdFC := GetAdvFVal("SX3","X3_RELACAO",Padr(cCpoEmit+'_COD', 10),2)
cIniLjFC := GetAdvFVal("SX3","X3_RELACAO",Padr(cCpoEmit+'_LOJA', 10),2)

If cPrw == "140I" //NFe
	oXMLForCli 	:= oXML:_infNFe:_EMIT
	oXMLEnd		:= oXML:_infNFe:_EMIT:_enderEmit
Elseif cPrw == "116I" //CTe
	oXMLForCli 	:= oXML:_infCTe:_EMIT
	oXMLEnd		:= oXML:_infCTe:_EMIT:_enderEmit
Elseif cPrw == "116IO" //CTeOS
	oXMLForCli 	:= oXML:_infCTe:_EMIT
	oXMLEnd		:= oXML:_infCTe:_EMIT:_enderEmit
Elseif cPrw == "140ITS" //NFs Transmite
	oXMLForCli 	:= oXML:_Transmite:_TransmiteRPS:_RPS:_PRESTADOR
	oXMLEnd		:= oXML:_Transmite:_TransmiteRPS:_RPS:_PRESTADOR
Endif

//CODIGO - Se possuir inicializador padrão não precisa adicionar o campo A2_COD/A1_COD 
//ou A030INICPD esta contido, pois este inicializador padrão é utilizado apenas pela RM
If Empty(cIniCdFC) .Or. "A030INICPD" $ cIniCdFC
	cCod := GetSxeNum(cTabEmit,cCpoEmit+'_COD') 
    (cTabEmit)->(dbSetOrder(1))
   
    While (cTabEmit)->(MsSeek(xFilial(cTabEmit)+cCod)) 
        ConfirmSX8() 
        cCod := GetSxeNum(cTabEmit,cCpoEmit+'_COD') 
    EndDo 

	aAdd(aDadosFC,{cCpoEmit+'_COD',cCod})
Endif

//LOJA -  Se possuir inicializador padrão não precisa adicionar o campo A2_LOJA/A1_LOJA
If Empty(cIniLjFC)
	aAdd(aDadosFC,{cCpoEmit+'_LOJA',"01"})
Endif

If XmlChildEx(oXMLForCli,"_CNPJ") # NIL .And. !Empty(oXMLForCli:_CNPJ:TEXT)
	lPJ := .T.
	cCGC	:= PadR(AllTrim(oXMLForCli:_CNPJ:TEXT),TamSX3(cCpoEmit+"_CGC")[1])
	aAdd(aDadosFC,{cCpoEmit+"_CGC",cCGC})
	aAdd(aDadosFC,{cCpoEmit+cCpoTipo,"J"})
Elseif XmlChildEx(oXMLForCli,"_CNPJPREST") # NIL .And. !Empty(oXMLForCli:_CNPJPREST:TEXT)
	lPJ := .T.
	cCGC	:= PadR(AllTrim(oXMLForCli:_CNPJPREST:TEXT),TamSX3(cCpoEmit+"_CGC")[1])
	aAdd(aDadosFC,{cCpoEmit+"_CGC",cCGC})
	aAdd(aDadosFC,{cCpoEmit+cCpoTipo,"J"})
Elseif XmlChildEx(oXMLForCli,"_CPF") # NIL .And. !Empty(oXMLForCli:_CPF:TEXT)
	aAdd(aDadosFC,{cCpoEmit+"_CGC",PadR(AllTrim(oXMLForCli:_CPF:TEXT),TamSX3(cCpoEmit+"_CGC")[1])})
	aAdd(aDadosFC,{cCpoEmit+cCpoTipo,"F"})
Elseif XmlChildEx(oXMLForCli,"_CPFPREST") # NIL .And. !Empty(oXMLForCli:_CPFPREST:TEXT)
	aAdd(aDadosFC,{cCpoEmit+"_CGC",PadR(AllTrim(oXMLForCli:_CPFPREST:TEXT),TamSX3(cCpoEmit+"_CGC")[1])})
	aAdd(aDadosFC,{cCpoEmit+cCpoTipo,"F"})
EndIf	

If XmlChildEx(oXMLForCli,"_IE") # NIL .And. !Empty(oXMLForCli:_IE:TEXT)
	aAdd(aDadosFC,{cCpoEmit+"_INSCR",PadR(AllTrim(oXMLForCli:_IE:TEXT),TamSX3(cCpoEmit+"_INSCR")[1])})
Elseif XmlChildEx(oXMLForCli,"_CIE") # NIL .And. !Empty(oXMLForCli:_CIE:TEXT)
	aAdd(aDadosFC,{cCpoEmit+"_INSCR",PadR(AllTrim(oXMLForCli:_CIE:TEXT),TamSX3(cCpoEmit+"_INSCR")[1])})
EndIf

If lPJ .And. lApiFor
	oJson  	:= JsonObject():New() 

	aRetJson := APIFORCLI(cCGC)
	oJson:FromJson(aRetJson[2])
	cRet := oJson:GetJsonObject("hits")

	If cRet <> Nil .And. Len(cRet) > 0 .And. aRetJson[1]
		lFindApi := .T.
		aAdd(aDadosFC,{cCpoEmit+"_NOME"	 , PadR(AllTrim(Upper(DecodeUTF8(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmname"]))),TamSX3(cCpoEmit+"_NOME")[1])})
		aAdd(aDadosFC,{cCpoEmit+"_NREDUZ", PadR(AllTrim(Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmdba"])),TamSX3(cCpoEmit+"_NREDUZ")[1])})
		aAdd(aDadosFC,{cCpoEmit+"_EST"   , oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmstate"]})
		aAdd(aDadosFC,{cCpoEmit+"_CEP"   , oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmzipcode"]})
		
		If ValType(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress3"]) == "C"
			aAdd(aDadosFC,{cCpoEmit+"_BAIRRO", PadR(AllTrim(Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress3"])),TamSX3(cCpoEmit+"_BAIRRO")[1])})
		Endif

		If ValType(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmcity"]) == "C"
			aAdd(aDadosFC,{cCpoEmit+"_MUN"   , PadR(AllTrim(Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmcity"])),TamSX3(cCpoEmit+"_MUN")[1])})
		Endif

		If ValType(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress1"]) == "C"
			aAdd(aDadosFC,{cCpoEmit+"_END"   , PadR(AllTrim(Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress1"])),TamSX3(cCpoEmit+"_END")[1])})
		Endif		
		
		aAdd(aDadosFC,{cCpoEmit+"_CNAE"  , oJson["hits"][1]["mdmGoldenFieldAndValues"]["cnaebr"]})
		cTel := oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmphone"][2]["mdmphonenumber"]
		If !Empty(cTel) 
			aTel := RemDddTel(cTel)
			aAdd(aDadosFC,{cCpoEmit+"_DDD"   , aTel[2]})
			aAdd(aDadosFC,{cCpoEmit+"_TEL"   , aTel[1]})
		EndIf
	Endif
Endif

If !lPJ .Or. (lPJ .And. !lApiFor) .Or. !lFindApi
	If XmlChildEx(oXMLForCli,"_XNOME") # NIL .And. !Empty(oXMLForCli:_XNOME:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_NOME"  ,PadR(AllTrim(Upper(oXMLForCli:_XNOME:TEXT)),TamSX3(cCpoEmit+"_NOME")[1])})
	Elseif XmlChildEx(oXMLForCli,"_RSOCIALPREST") # NIL .And. !Empty(oXMLForCli:_RSOCIALPREST:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_NOME"  ,PadR(AllTrim(Upper(oXMLForCli:_RSOCIALPREST:TEXT)),TamSX3(cCpoEmit+"_NOME")[1])})
	EndIf

	If XmlChildEx(oXMLForCli,"_XFANT") # NIL .And. !Empty(oXMLForCli:_XFANT:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_NREDUZ",PadR(AllTrim(Upper(oXMLForCli:_XFANT:TEXT)),TamSX3(cCpoEmit+"_NREDUZ")[1])})
	Elseif XmlChildEx(oXMLForCli,"_NFANTASIAPREST") # NIL .And. !Empty(oXMLForCli:_NFANTASIAPREST:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_NREDUZ",PadR(AllTrim(Upper(oXMLForCli:_NFANTASIAPREST:TEXT)),TamSX3(cCpoEmit+"_NREDUZ")[1])})
	EndIf
	
	If XmlChildEx(oXMLEnd,"_UFPREST") # NIL .And. !Empty(oXMLEnd:_UFPREST:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_EST"  ,PadR(oXMLEnd:_UFPREST:TEXT,TamSX3(cCpoEmit+"_EST")[1])})
	ElseIf XmlChildEx(oXMLEnd,"_UF") # NIL .And. !Empty(oXMLEnd:_UF:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_EST"  ,PadR(oXMLEnd:_UF:TEXT,TamSX3(cCpoEmit+"_EST")[1])})
	EndIf

	If XmlChildEx(oXMLEnd,"_CMUNPREST") # NIL .And. !Empty(oXMLEnd:_CMUNPREST:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_COD_MUN"  ,PadR(SubStr(oXMLEnd:_CMUNPREST:TEXT,3),TamSX3(cCpoEmit+"_COD_MUN")[1])})
	ElseIf XmlChildEx(oXMLEnd,"_CMUN") # NIL .And. !Empty(oXMLEnd:_CMUN:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_COD_MUN"  ,PadR(SubStr(oXMLEnd:_CMUN:TEXT,3),TamSX3(cCpoEmit+"_COD_MUN")[1])})
	EndIf

	If XmlChildEx(oXMLEnd,"_XMUN") # NIL .And. !Empty(oXMLEnd:_XMUN:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_MUN"  ,PadR(AllTrim(Upper(oXMLEnd:_XMUN:TEXT)),TamSX3(cCpoEmit+"_MUN")[1])})
	EndIf

	If XmlChildEx(oXMLEnd,"_XBAIRRO") # NIL .And. !Empty(oXMLEnd:_XBAIRRO:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_BAIRRO"  ,PadR(AllTrim(Upper(oXMLEnd:_XBAIRRO:TEXT)),TamSX3(cCpoEmit+"_BAIRRO")[1])})
	ElseIf XmlChildEx(oXMLEnd,"_BPREST") # NIL .And. !Empty(oXMLEnd:_BPREST:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_BAIRRO"  ,PadR(AllTrim(Upper(oXMLEnd:_BPREST:TEXT)),TamSX3(cCpoEmit+"_BAIRRO")[1])})
	EndIf

	If XmlChildEx(oXMLEnd,"_NRO") # NIL .And. !Empty(oXMLEnd:_NRO:TEXT)
		cNumEnd := AllTrim(oXMLEnd:_NRO:TEXT)
	Elseif XmlChildEx(oXMLEnd,"_NPREST") # NIL .And. !Empty(oXMLEnd:_NPREST:TEXT)
		cNumEnd := AllTrim(oXMLEnd:_NPREST:TEXT)
	EndIf

	If XmlChildEx(oXMLEnd,"_XLGR") # NIL .And. !Empty(oXMLEnd:_XLGR:TEXT)
		cEnd := AllTrim(Upper(oXMLEnd:_XLGR:TEXT)) + Iif(!Empty(cNumEnd),", " + cNumEnd,"")
		aAdd(aDadosFC,{cCpoEmit+"_END"  ,PadR(cEnd,TamSX3(cCpoEmit+"_END")[1])})
	Elseif XmlChildEx(oXMLEnd,"_ENDPREST") # NIL .And. !Empty(oXMLEnd:_ENDPREST:TEXT)
		cEnd := AllTrim(Upper(oXMLEnd:_ENDPREST:TEXT)) + Iif(!Empty(cNumEnd),", " + cNumEnd,"")
		aAdd(aDadosFC,{cCpoEmit+"_END"  ,PadR(cEnd,TamSX3(cCpoEmit+"_END")[1])})
	EndIf

	If XmlChildEx(oXMLEnd,"_CEP") # NIL .And. !Empty(oXMLEnd:_CEP:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_CEP"  ,PadR(oXMLEnd:_CEP:TEXT,TamSX3(cCpoEmit+"_CEP")[1])})
	Elseif XmlChildEx(oXMLEnd,"_CEPPREST") # NIL .And. !Empty(oXMLEnd:_CEPPREST:TEXT)
		aAdd(aDadosFC,{cCpoEmit+"_CEP"  ,PadR(oXMLEnd:_CEPPREST:TEXT,TamSX3(cCpoEmit+"_CEP")[1])})
	EndIf

	If XmlChildEx(oXMLEnd,"_FONE") # NIL .And. !Empty(oXMLEnd:_FONE:TEXT)
		cDDD	:= SubStr(oXMLEnd:_FONE:TEXT,1,2)
		cTEL	:= SubStr(oXMLEnd:_FONE:TEXT,3)

		aAdd(aDadosFC,{cCpoEmit+"_DDD"  ,PadR(cDDD,TamSX3(cCpoEmit+"_DDD")[1])})
		aAdd(aDadosFC,{cCpoEmit+"_TEL"  ,PadR(cTEL,TamSX3(cCpoEmit+"_TEL")[1])})
	Elseif XmlChildEx(oXMLEnd,"_TELPREST") # NIL .And. !Empty(oXMLEnd:_TELPREST:TEXT)
		cDDD	:= SubStr(oXMLEnd:_TELPREST:TEXT,1,2)
		cTEL	:= SubStr(oXMLEnd:_TELPREST:TEXT,3)

		aAdd(aDadosFC,{cCpoEmit+"_DDD"  ,PadR(cDDD,TamSX3(cCpoEmit+"_DDD")[1])})
		aAdd(aDadosFC,{cCpoEmit+"_TEL"  ,PadR(cTEL,TamSX3(cCpoEmit+"_TEL")[1])})
	EndIf
Endif	

If Len(aDadosFC) > 0
	If (cTabEmit)->(FieldPos(cCpoEmit+"_MSBLQL")) > 0
		aAdd(aDadosFC,{cCpoEmit+"_MSBLQL"   , "2"})
	Endif

	If !lSA2
		aAdd(aDadosFC,{"A1_TIPO","F"})
	Endif

	aDadosFC := FWVetByDic(aDadosFC,cTabEmit,.F.)

	If lSA2
		cModel 		:= "MATA020"
		cIdModel	:= "SA2MASTER"
	Else 
		cModel 		:= "CRMA980"
		cIdModel	:= "SA1MASTER"
	Endif

	oCadModel := FWLoadModel(cModel)
	oCadModel:SetOperation(MODEL_OPERATION_INSERT)
	oCadModel:Activate()

	For nI := 1 To Len(aDadosFC)
		oCadModel:SetValue(cIdModel,aDadosFC[nI,1],aDadosFC[nI,2])
	Next nI

	INCLUI := .T.
	If oCadModel:VldData()
		oCadModel:CommitData()
		aAdd(aRet,.T.)
		aAdd(aRet,FwFldGet(cCpoEmit+'_COD'))
		aAdd(aRet,FwFldGet(cCpoEmit+'_LOJA'))
		aAdd(aRet,FwFldGet(cCpoEmit+"_NOME"))

		If !lSA2 .And. lAI0Origem
			
			// Posiciona no Cliente
			DbSelectArea("SA1")
			SA1->(DbSetOrder(01)) // A1_FILIAL + A1_COD + A1_LOJA 
			If (SA1->(DbSeek(FWxFilial('SA1') + FwFldGet(cCpoEmit+'_COD') + FwFldGet(cCpoEmit+'_LOJA') )))
				
				//Inclui Complemento de Cliente
				oCmplCli := FWLoadModel('MATA030A')
				oCmplCli:SetOperation(MODEL_OPERATION_INSERT)
				oCmplCli:Activate()

				oCmplCli:LoadValue("AI0MASTER","AI0_CADORI","1") //Imp/Cadastro
				
				If oCmplCli:VldData()
					oCmplCli:CommitData()
				EndIf 

				oCmplCli:DeActivate()
				oCmplCli:Destroy()

			EndIf 

			RestArea(aAreaSA1)
		EndIf 	
	Else
		aAdd(aRet,.F.)
		aAdd(aRet,"")
		aAdd(aRet,"")
		aAdd(aRet,"")

		aErroMVC := oCadModel:GetErrorMessage()
		cErroMVC += CRLF + CRLF
		cErroMVC += STR0004	+ aErroMVC[4] + CRLF
		cErroMVC += STR0005	+ aErroMVC[5] + CRLF
		cErroMVC += STR0006	+ aErroMVC[6] + CRLF
		aAdd(aRet,cErroMVC)
	Endif

	oCadModel:DeActivate()
	oCadModel:Destroy()
Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCadAutP
Automação cadastral de produto

@param	oXML		XML sendo importado
@param	cPrw		Rotina sendo executada

@author	Rodrigo M Pontes
@since 14/05/22
/*/
//------------------------------------------------------------------- 

Function ImpCadAutP(oXML,cPrw)

Local cRet	:= PadR("",TamSX3("B1_COD")[1])

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCadAutA
Automação cadastral de produto e/ou amarração produto x fornecedor
ou produto x cliente

@author	Rodrigo M Pontes
@since 14/05/22
/*/
//------------------------------------------------------------------- 

Function ImpCadAutA()

Local cCodProd		:= ""
Local nPrdFor		:= 0
Local nDescB1		:= 0
Local nDTUM			:= 0
Local nDTSEGUM		:= 0
Local nDTQTSEGUM	:= 0
Local nDTQuant		:= 0
Local cPrdFor		:= ""
Local cFornCli		:= ""
Local cLjFoCli		:= ""
Local cTabEmit		:= ""
Local cTabAmar		:= ""
Local cCpoEmit		:= ""
Local cCpoAmar		:= ""
Local cModel		:= ""
Local cIdModel		:= ""
Local cIdGModel		:= ""
Local nI			:= 0
Local aCpoAmar		:= {}
Local aErroMVC		:= {}
Local cErroMVC		:= ""
Local oCadPAModel	:= Nil
Local lRet			:= .T.
Local lRetAma		:= .T.

If SDS->DS_STATUS == "B" .And. !IsBlind() .And. !(SubStr(SDS->DS_ARQUIVO,1,3) $ "214|273")
	cCodProd	:= PadR(&(ReadVar()),TamSX3("B1_COD")[1])
	nPrdFor		:= GdFieldPos("DT_PRODFOR")
	nDescB1		:= GdFieldPos("DT_DESC")
	nDTUM		:= GdFieldPos("DT_UM")
	nDTSEGUM	:= GdFieldPos("DT_SEGUM")
	nDTQTSEGUM	:= GdFieldPos("DT_QTSEGUM")
	nDTQuant	:= GdFieldPos("DT_QTSEGUM")

	If ExistCpo("SB1",cCodProd,1)
		If nPrdFor > 0
			cPrdFor := aCols[n,nPrdFor] 
		Endif

		If !Empty(cPrdFor) .Or. (SubStr(SDS->DS_ARQUIVO,1,3) == "319" .And. Empty(cPrdFor))

			If SDS->DS_TIPO $ "D|B"
				lRetAma := COLPRDAMA("SA7",cCodProd,SDS->DS_FORNEC,SDS->DS_LOJA)
			Else
				lRetAma := COLPRDAMA("SA5",cCodProd,SDS->DS_FORNEC,SDS->DS_LOJA,cPrdFor)
			Endif

			If !lRetAma
				If MsgYesNo(STR0014 + AllTrim(cCodProd) + STR0015) //"O produto: " #" selecionado esta correto para criação da amarração do produto?"
					If SDS->DS_TIPO $ "D|B"
						cTabEmit := "SA1"
						cTabAmar := "SA7"
						cCpoEmit := Substr(cTabEmit,2,2)
						cCpoAmar := Substr(cTabAmar,2,2)
						aCpoAmar := {{"A7_PRODUTO",cCodProd},{"A7_FILIAL",fwxFilial(cTabAmar)},{"A7_CLIENTE",},{"A7_LOJA",},{"A7_CODCLI",cPrdFor},{"A7_MSBLQL","2"}}
						cModel	 := "MATA370"
						cIdModel := "SA7MASTER"
					Else
						cTabEmit := "SA2"
						cTabAmar := "SA5"
						cCpoEmit := Substr(cTabEmit,2,2)
						cCpoAmar := Substr(cTabAmar,2,2)
						aCpoAmar := {{"A5_PRODUTO",cCodProd},{"A5_FILIAL",fwxFilial(cTabAmar)},{"A5_FORNECE",},{"A5_LOJA",},{"A5_CODPRF",cPrdFor},{"A5_MSBLQL","2"}}
						cModel	 := "MATA061"
						cIdModel := "MdFieldSA5"
						cIdGModel:= "MdGridSA5"
					Endif

					cFornCli := PadR(SDS->DS_FORNEC,TamSX3(cCpoEmit+"_COD")[1])
					aCpoAmar[3,2] := cFornCli
					cLjFoCli := PadR(SDS->DS_LOJA,TamSX3(cCpoEmit+"_LOJA")[1])	
					aCpoAmar[4,2] := cLjFoCli

					aCpoAmar := FWVetByDic(aCpoAmar,cTabAmar,.F.)

					oCadPAModel := FWLoadModel(cModel)
				
					oCadPAModel:SetOperation(MODEL_OPERATION_INSERT)
					oCadPAModel:Activate()

					If cModel == "MATA370"
						For nI := 1 To Len(aCpoAmar)
							If aCpoAmar[nI,1] == cCpoAmar+"_MSBLQL" .And. (cTabAmar)->(FieldPos(cCpoAmar+"_MSBLQL")) > 0
								oCadPAModel:SetValue(cIdModel,aCpoAmar[nI,1],aCpoAmar[nI,2])
							Elseif aCpoAmar[nI,1] <> cCpoAmar+"_MSBLQL"
								oCadPAModel:SetValue(cIdModel,aCpoAmar[nI,1],aCpoAmar[nI,2])
							Endif
						Next nI
					Elseif cModel == "MATA061"
						//Cabeçalho
						oCadPAModel:SetValue(cIdModel,'A5_PRODUTO',cCodProd)
						oCadPAModel:SetValue(cIdModel,'A5_NOMPROD',GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+cCodProd,1))
						
						//Grid
						oCadPAModel:SetValue(cIdGModel,'A5_FORNECE',cFornCli)
						oCadPAModel:SetValue(cIdGModel,'A5_LOJA' ,cLjFoCli)
						oCadPAModel:SetValue(cIdGModel,'A5_NOMEFOR', GetAdvFVal("SA2","A2_NREDUZ",xFilial("SA2")+cFornCli+cLjFoCli,1))
						oCadPAModel:SetValue(cIdGModel,'A5_CODPRF', cPrdFor)
					Endif

					INCLUI := .T.
					If oCadPAModel:VldData()
						oCadPAModel:CommitData()
					Else
						aErroMVC := oCadPAModel:GetErrorMessage()
						cErroMVC += STR0004	+ aErroMVC[4] + CRLF
						cErroMVC += STR0005	+ aErroMVC[5] + CRLF
						cErroMVC += STR0006	+ aErroMVC[6] + CRLF
						
						Aviso(STR0010,STR0011 + CRLF + STR0012,{STR0013},2)

						If RecLock("SDS",.F.) 
							SDS->DS_DOCLOG := cErroMVC
							SDS->(MsUnLock())
						Endif
					Endif

					oCadPAModel:DeActivate()
					oCadPAModel:Destroy()
				Else
					lRet := .F.
				Endif
			Endif
		Endif
	Else
		lRet := .F.
	Endif
Endif

If lRet .And. !Empty(cCodProd)
	If nDescB1 > 0
		oGetDados:aCols[oGetDados:nAt,nDescB1] := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+cCodProd,1)
	Endif
	
	If nDTUM > 0 .And. nDTSEGUM > 0 .And. nDTQTSEGUM > 0 .And. nDTQuant > 0
		oGetDados:aCols[oGetDados:nAt,nDTUM] 	:= GetAdvFVal("SB1","B1_UM",xFilial("SB1")+cCodProd,1)
		oGetDados:aCols[oGetDados:nAt,nDTSEGUM] := GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+cCodProd,1)
		
		If !Empty(oGetDados:aCols[oGetDados:nAt,nDTSEGUM])
			oGetDados:aCols[oGetDados:nAt,nDTQTSEGUM] 	:= ConvUM(cCodProd,oGetDados:aCols[oGetDados:nAt,nDTQuant],oGetDados:aCols[oGetDados:nAt,nDTQuant],2)
		Endif
	Endif
	aCols		:= aClone(oGetDados:aCols)
	oGetDados:Refresh()
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpXTra
Verificar se esta habilitado Importador XML x TOTVS Transmite

@author	Rodrigo M Pontes
@since 14/05/22
/*/
//------------------------------------------------------------------- 

Function ImpXTra(nOpc)

Local lRet			:= .F.
Local lValida		:= .F.
Local lImpXML       := .F.
Local cTraCID       := SuperGetMv("MV_XMLCID",.F.,"")
Local cTraCSEC      := SuperGetMv("MV_XMLCSEC",.F.,"")
Local cApiTran	    := SuperGetMv("MV_APITRAN",.F.,"")
Local lCadAut	    := SuperGetMv("MV_XMLCAUT",.F.,.T.)
Local oComTransmite := Nil

Default nOpc := 0 

If nOpc == 0
	lImpXML       := SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Elseif nOpc == 1
	lImpXML       := SuperGetMv("MV_IMPXML",.F.,.F.)
Endif

//Valida integracao importador x transmite + cadastro automatico
If nOpc == 0 .And. lImpXML .And. lCadAut .And. !Empty(cTraCID) .And. !Empty(cTraCSEC) .And. !Empty(cApiTran)
	lValida := .T.
//Valida integracao importador x transmite
Elseif nOpc == 1 .And. lImpXML .And. !Empty(cTraCID) .And. !Empty(cTraCSEC) .And. !Empty(cApiTran)
	lValida := .T. 
Endif

//Verificar se esta habilitado Importador XML x TOTVS Transmite
If lValida
	oComTransmite := ComTransmite():New() 
	If oComTransmite:TokenTotvsTransmite()
    	lRet := .T.
    Endif
	FreeObj(oComTransmite)
Endif 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataLanc
Pega a data do lancamento
@param  cChv     Chave da Nfe
@param  cfilCko  Filial

@author	Valter Silva
@since 19/04/2022
/*/
//------------------------------------------------------------------- 

Function GetDataLanc(cChv,cfilCko)
Local aAreaSF1	:= SF1->(GetArea())
Local cDataLanc  := ''

DEFAULT cChv	:= ""
DEFAULT cfilCko := ""

//Busca pela chave do documento
If cChv <> ""
	DbSelectArea("SF1")
	SF1->(DbSetOrder(8))
	If SF1->(DbSeek(fwxfilial("SF1",cfilCko)+cChv))
        If !Empty(SF1->F1_DTDIGIT) .and. !Empty(SF1->F1_HORA)
            cDataLanc := FWTimeStamp(5,SF1->F1_DTDIGIT,SF1->F1_HORA)
        Endif
    Endif
Endif

RestArea(aAreaSF1)
Return cDataLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodFil
Pega o codigo da Filial do Transmite
@param cEmp codigo da empresa
@param cFil codigo da filial
@Return cRet codigo da filial do transmite	
@author	Valter Silva
@since 19/04/2022
/*/
//------------------------------------------------------------------- 
Function GetCodFil(cEmp,cFil)

Local cAliasImp := GetNextAlias()
Local oQryDHW   := Nil
Local cQryStat  := ""
Local cRet		:= ""

oQryDHW := FWPreparedStatement():New()  

cQry := " SELECT DHW_GRPEMP, DHW_FILEMP, DHW_CODFIL"
cQry += " FROM " + RetSqlName("DHW")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += " AND DHW_GRPEMP = ?"
cQry += " AND DHW_FILEMP = ?"

cQry := ChangeQuery(cQry)

oQryDHW:SetQuery(cQry)

oQryDHW:SetString(1,cEmp)
oQryDHW:SetString(2,cFil)

cQryStat := oQryDHW:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

If (cAliasImp)->(!EOF())
    cRet := (cAliasImp)->DHW_CODFIL
Endif

(cAliasImp)->(DbCloseArea())

Return cRet

/*/{Protheus.doc} ComNatVLD
	(Valid do campo DT_NATREN)
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/11/2023
/*/
Function A103NATSDT(cNatRen)

Local lRet		 := .T.
Local cVldNatRen := M->DT_NATREN

Default cNatRen	:= ""

If !Empty(cNatRen)
	cVldNatRen	:= cNatRen
Endif

//Verifica se existe natureza de rendimento
lRet := (Empty(cVldNatRen) .Or. ExistCpo("FKX",cVldNatRen,1))

//valida se fornecedor pode ser vinculado a natureza de rendimento
If lRet .And. FindFunction("VldNatRen") .and. !Empty(cVldNatRen) .And. Empty(cNatRen)
	lRet := VldNatRen(cVldNatRen,"1",M->DS_FORNEC,M->DS_LOJA) 
Endif

Return lRet


/*/{Protheus.doc} ColAtNFCan
	(Verifica se a nota cancelada ja teve entrada na CKO 
	e atualizar a mesma.)
	@type  Static Function
	@author Thiago Rodrigues
	@since 20/02/2024
	@param Xml,Nome do arquivo
	@Return {Logico}
/*/
Function ColNTCan(cXml,cNameArq,lFind)
local ncStat    := 0
local oProc     := Nil 
local oXmlCan   := Nil
local lRet      := .F.
Local cErro     := ""
Local cAviso    := ""
local cChaveNFe := ""
local cTpArq    := "" 
local cEventID  := "052" // Evento de Inconsistencia da importação NF-e/CT-e 
local cMensagem := ""
local aEnvErros := {}
local cMsgEmail := ""
Local aArea	    := GetArea()

Default lFind := .F.

oXmlCan := xmlParser( cXml,"_",@cErro,@cAviso )
cTpArq  := AllTrim(SubStr(cNameArq,1,3))

if ValType(oXmlCan) == "O" 

	//Verifica qual tipo de arquivo
	Do Case
		case cTpArq == "109" //NF-e
			if  ValType(XmlChildEx(oXmlCan,"_NFEPROC")) == "O"
				if  ValType(XmlChildEx(oXmlCan:_NFEPROC,"_PROTNFE")) =="O" .And.; 
					ValType(XmlChildEx(oXmlCan:_NFEPROC:_PROTNFE,"_INFPROT")) == "O"

					oProc := XmlChildEx(oXmlCan:_NFEPROC:_PROTNFE,"_INFPROT")
					cChaveNFe :=  Alltrim(oProc:_CHNFE:text)

				elseif ValType(XmlChildEx(oXmlCan:_NFEPROC,"_RETCANCNFE")) == "O" .and.;
					ValType(XmlChildEx(oXmlCan:_NFEPROC:_RETCANCNFE,"_INFCANC")) == "O"  

					oProc := XmlChildEx(oXmlCan:_NFEPROC:_RETCANCNFE,"_INFCANC")
					cChaveNFe := Alltrim(oProc:_CHNFE:text)

				endif
			endif

		case cTpArq == "214" .And.  ValType(XmlChildEx(oXmlCan,"_CTEPROC")) == "O" .And.; 
									ValType(XmlChildEx(oXmlCan:_CTEPROC,"_PROTCTE")) == "O" .And.;
									ValType(XmlChildEx(oXmlCan:_CTEPROC:_PROTCTE,"_INFPROT")) == "O" //Cte

			oProc := XmlChildEx(oXmlCan:_CTEPROC:_PROTCTE,"_INFPROT")
			cChaveNFe :=  Alltrim(oProc:_CHCTE:text)

		case cTpArq == "273" .And. Valtype(XmlChildEx(oXmlCan,"_CTEOSPROC"))== "O" .And.;
								   Valtype(XmlChildEx(oXmlCan:_CTEOSPROC,"_PROTCTE"))== "O" .And.;
		     					   Valtype(XmlChildEx(oXmlCan:_CTEOSPROC:_PROTCTE,"_INFPROT"))== "O" //CteOS

			oProc := XmlChildEx(oXmlCan:_CTEOSPROC:_PROTCTE,"_INFPROT")
			cChaveNFe :=  Alltrim(oProc:_CHCTE:text)	

		case cTpArq == "319" .and. Valtype(XmlChildEx(oXmlCan,"_PROCTRANSMITENFSE"))== "O" .And.;
								   Valtype(XmlChildEx(oXmlCan:_PROCTRANSMITENFSE,"_TRANSMITE"))== "O" .And.;
		     					   Valtype(XmlChildEx(oXmlCan:_PROCTRANSMITENFSE:_TRANSMITE,"_RETTRANSMITENFSE"))== "O" .And.;
								   Valtype(XmlChildEx(oXmlCan:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE,"_CSTAT"))== "O" //NFS-E

			oProc := XmlChildEx(oXmlCan:_PROCTRANSMITENFSE:_TRANSMITE,"_RETTRANSMITENFSE")


			cChaveNFe :=  Alltrim(oProc:_dtEmisNFSe:text)+"|"+Iif(Valtype(XmlChildEx(oProc,"_CNPJPREST")) == "O",Alltrim(oProc:_CNPJPREST:text),Alltrim(oProc:_CPFPREST:text))+"|"+Alltrim(oProc:_nNFSe:text)
	EndCase 

	//pega o status
	if Valtype(oProc) == "O" .And. Valtype(XmlChildEx(oProc,"_CSTAT")) == "O" .And. !Empty(oProc:_cStat:Text)
		ncStat := VAL(AllTrim(oProc:_cStat:Text))
	endif

	//Verifica o status é de cancelado
	IF ncStat == 101 .Or. ncStat == 151 .Or. ncStat > 200
		
		if Valtype(XmlChildEx(oProc,"_XMOTIVO")) == "O" .And. !Empty(oProc:_xMotivo:Text)
			cMotivo := ConvASC(oProc:_xMotivo:Text)  //Motivo
		endif
	
		//Valida se existe documento original, se lFind ja vem com CKO Posicionada
		lRet := iif(lFind,.t.,ColGetCKO(cXML,cChaveNFe))

		if lRet

			Begin Transaction
			
			Reclock("CKO",.F.) //Grava erro no arquivo original

				if cTpArq == "319" // NFS-e
					CKO->CKO_CODERR:= "COM057"
					CKO->CKO_MSGERR:= "COM057 - "+ STR0024 //"COM057 - NFS-e importada e cancelada."
				else
					CKO->CKO_CODERR:= iif(cTpArq == "109",STR0016,STR0017)
					CKO->CKO_MSGERR:= iif(cTpArq == "109",STR0016+ " - " + STR0018 , STR0017 + " - " +  STR0019) //COM055 - NFe importada e cancelada, COM056 - CTe importada e cancelada
				endif
			CKO->( msUnlock() )

			End Transaction
			
			cMsgEmail := STR0020 + cChaveNFe + STR0021 + cMotivo // A Nota: xxxx  recebeu cancelamento. Motivo: xxx 
			aAdd(aEnvErros,{Alltrim(CKO->CKO_ARQUIV),cMsgEmail, STR0022})  //"Verifique se o arquivo importado, gerou pré-nota ou documento de entrada e realize o cancelamento no sitema."
 
			//Dispara e-mail
			dbSelectarea("SXI")
			dbsetorder(2)
			If MsSeek ('002' + '001' + cEventID)
				cMensagem := MSGTOTCOL(cEventID,aEnvErros)
				EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0023,cMensagem,.f./*lPublic*/) //"Evento de Inconsistencia da importação NF-e/CT-e [TOTVS COLABORAÇÃO]"
			Endif

		endif
	endif	
endif

RestArea(aArea)
Return lRet

/*/{Protheus.doc} ColAtNFCan
	(Verifica se a nota cancelada ja teve entrada na CKO 
	para atualizar a mesma.)
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/02/2024
	@param Array com dados de busca
/*/
Function ColGetCKO(cXML,cChaveNFe)
local oFindCKO 		:= Nil
local lRet     		:= .F.
local cAlias   		:= GetNextAlias()
local cQuery   		:= "" 
Local cQueryST 		:= ""
local aCkoOri  		:= {}
Local oComTransmite := ComTransmite():New()

//Tenta encontrar através da chave
If oFindCKO == nil 
	oFindCKO := FWPreparedStatement():New()

	cQuery := " SELECT R_E_C_N_O_ REC FROM " + RetSqlName("CKO") + " CKO"
	cQuery += " WHERE CKO.CKO_CHVDOC = ? "
	cQuery += " AND D_E_L_E_T_ = ?"
	cQuery := ChangeQuery(cQuery)

	oFindCKO:SetQuery(cQuery) 
EndIf 
oFindCKO:SetString(1,cChaveNFe)
oFindCKO:SetString(2,Space(1))

cQuerySt := oFindCKO:GetFixQuery()
MpSysOpenQuery(cQuerySt,cAlias)

If !(cAlias)->(eof())
	CKO->( dbGoTo( (cAlias)->REC) )
	lRet:=.T.
Endif

(cAlias)->(DbCloseArea())

oFindCKO := NIL
cQuerySt := ""

//Caso não encontre busca pelo  DOC, Serie e NOMFOR
If !lRet
	/* aCKODados
	[1] - Chave Doc
	[2] - Numero Doc
	[3] - Serie Doc
	[4] - Nome Fornecedor
	[5] - Empresa
	[6] - Filial
	[7] - Numero Doc NFS
	*/
	aCkoOri := oComTransmite:GetDadosXML(cXML)
		
	if Len(aCkoOri) > 0

		oFindCKO := FWPreparedStatement():New()
		cQuery := " SELECT R_E_C_N_O_ REC"
		cQuery += " FROM " + RetSqlName("CKO")
		cQuery += " WHERE CKO_DOC    = ?"
		cQuery += " AND   CKO_SERIE  = ?"
		cQuery += " AND   CKO_NOMFOR = ?"
		cQuery += " AND   CKO_FLAG   = ?"
		cQuery += " AND   D_E_L_E_T_ = ?"
		cQuery := ChangeQuery(cQuery)
		oFindCKO:SetQuery(cQuery) 
		
		oFindCKO:SetString(1,aCkoOri[2])
		oFindCKO:SetString(2,aCkoOri[3])
		oFindCKO:SetString(3,SubStr(aCkoOri[4],1,TAMSX3("CKO_NOMFOR")[1]))
		oFindCKO:SetString(4,"1")
		oFindCKO:SetString(5,Space(1))

		cQuerySt := oFindCKO:GetFixQuery()
		cAlias   := GetNextAlias()
		MpSysOpenQuery(cQuerySt,cAlias) 

		if !(cAlias)->(eof())
			CKO->( dbGoTo( (cAlias)->REC) )
			lRet:=.T.
		endif
		(cAlias)->(DbCloseArea())
	endif
endif

FreeObj(oComTransmite)
FwFreeArray(aCkoOri)

return lRet

/*/{Protheus.doc} COMValNat
	Valida natureza financeira na classificação em lote

	@type  Static Function
	@author rodrigo.mpontes
	@since 21/02/2024
/*/

Function COMValNat(cNatureza)

Local aArea			:= GetArea()
Local lRet 			:= .T.

DbSelectArea("SED")
SED->(DbSetOrder(1))
If SED->(DbSeek(xFilial("SED") + cNatureza))
	lRet := FinVldNat(.F.,cNatureza,2) .And. RegistroOk("SED")
Endif

RestArea(aArea)
FwFreeArray(aArea)

Return (lRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ComNFSNewDoc
Verificar se documento NFS esta com numeração de documento maior
que 9 digitos

@author	Rodrigo M Pontes
@since 14/08/23
/*/
//------------------------------------------------------------------- 

Function ComNFSNewDoc(cDocXML,oFullXML,cOpc,cNameFile)

Local aRet			:= {}
Local aClasObj		:= {}
Local aFindMethod	:= {"NEWNFSDOC","NEWNUMDOC"}
Local nI			:= 0
Local nFindMethod	:= 0
Local nPos			:= 0
Local oObjImp		:= Nil

Default cNameFile	:= ""

oObjImp := ComTransmite():New()

If oObjImp <> Nil
	aClasObj := ClassMethArr(oObjImp,.T.)  

	//Verifica se metodo existe
	For nI := 1 To Len(aFindMethod)
		nPos := aScan(aClasObj,{|x| AllTrim(Upper(x[1])) == aFindMethod[nI]})
		If nPos > 0
			nFindMethod++ 
		Endif
	Next nI

	If Len(aFindMethod) == nFindMethod
		aRet := oObjImp:NewNFsDoc(cDocXML,oFullXML,cOpc,cNameFile) 
	Endif

	FwFreeArray(aFindMethod)
	FwFreeArray(aClasObj)
	FreeObj(oObjImp)	
EndIf

Return aRet

Function COMNEWIMP(aDadosDKM)

Local aDocDKM 	:= {}
Local aGrvDKM	:= {}
Local aDKMBulk	:= {} 
Local oBulkDKM 	:= FwBulk():New(RetSqlName("DKM"),100)
Local nI		:= 0
Local nX		:= 0

For nI := 1 To Len(aDadosDKM[1])
	aAdd(aDKMBulk,{aDadosDKM[1][nI][1]})
Next nI

oBulkDKM:setFields(aDKMBulk)

For nI := 1 To Len(aDadosDKM)
	aGrvDKM := {}

	For nX := 1 To Len(aDadosDKM[nI])
		aAdd(aGrvDKM,aDadosDKM[nI][nX][2])
	Next nX

	oBulkDKM:addData(aGrvDKM)
Next nI

oBulkDKM:Close()
oBulkDKM:Destroy()

FreeObj(oBulkDKM)
FwFreeArray(aDocDKM)
FwFreeArray(aGrvDKM)
FwFreeArray(aDKMBulk)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MtTribNf
Monta Json com os tributos da tabela DKM, para ser enviado para ser utilizado no metodo
TaxOperandIntegrator

@author	Leandro Nishihata
@since 10/11/25
/*/
//------------------------------------------------------------------- 

Function MtTribNf()
Local cIdTotvs := ""
Local aAreaDKM	:= DKM->(GetArea())
Local cPosItem := ALLTRIM(str(VAL(DKM->DKM_ITEM)))
Local jTribGen := JsonObject():New()
Local CItem	   := ""
Local cWhile   := ""
Local lCalcol  := FwIsInCallStack("ProcDocs") 
Local nItem    := 0 
Local nposTes  := 0
Local nposItem := 0
Local lAtutrbgen := readvar() == 'M->D1_TES' .OR. readvar() == 'M->D1_CF'
Local nTamD1It	:= 0
Local lFindFuEIC := findfunction("comex.generics.eic.getTribDKMImport")

If Type("l103Class") == "U"
	Private l103Class := .F.
EndIf

If Type("l103Exclui") == "U"
	Private l103Exclui := .F.
EndIf

IF lCalcol
	DbSelectArea("DKM")
	DbSetOrder(1)
	MsSeek(xFilial("DKM")+SDS->(DS_DOC+DS_SERIE+DS_FORNEC+DS_LOJA)) // DKM_FILIAL, DKM_DOC, DKM_SERIE, DKM_FORNEC, DKM_LOJA, DKM_ESPECI, DKM_ITEM, DKM_COD, DKM_TRIB, R_E_C_N_O_, D_E_L_E_T_
	cWhile := "SDS->DS_FORNEC== DKM->DKM_FORNEC .AND. SDS->DS_LOJA==DKM->DKM_LOJA .AND. SDS->DS_DOC==DKM->DKM_DOC .AND. SDS->DS_SERIE==DKM->DKM_SERIE"
Else
	nposTes  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"} )
	nPosItem := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"} )
	nTamD1It := TamSX3("D1_ITEM")[1]
	DbSelectArea("DKM")
	DbSetOrder(1)
	MsSeek(xFilial("DKM")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) // DKM_FILIAL, DKM_DOC, DKM_SERIE, DKM_FORNEC, DKM_LOJA, DKM_ESPECI, DKM_ITEM, DKM_COD, DKM_TRIB, R_E_C_N_O_, D_E_L_E_T_
	cWhile := "SF1->F1_FORNECE== DKM->DKM_FORNEC .AND. SF1->F1_LOJA==DKM->DKM_LOJA .AND. SF1->F1_DOC==DKM->DKM_DOC .AND. SF1->F1_SERIE==DKM->DKM_SERIE"

Endif
// Monta o JSON com dados dos tributos
While DKM->(!eof()) .and. &cWhile 
	
	If lCalCol .Or. (l103Class .AND. !lAtutrbgen .And. StrZero(n,nTamD1It) == DKM->DKM_ITEM) .Or. (l103Class .And. lAtutrbgen .And. nPosItem>0 .And. aCols[n,nPosItem] == DKM->DKM_ITEM)
		cIdTotvs := ""

		Do Case
			Case upper(alltrim(DKM->DKM_TRIB)) ==  'IBSUF'
				cIdTotvs := '000060'
			Case upper(alltrim(DKM->DKM_TRIB)) == 'IBSMUN'
				cIdTotvs := '000061'
			Case upper(alltrim(DKM->DKM_TRIB)) == 'CBS'
				cIdTotvs := '000062'
			Case upper(alltrim(DKM->DKM_TRIB)) == 'IS'
				cIdTotvs := '000063'
			Otherwise
				cIdTotvs := GetAdvFVal("F2E","F2E_IDTRIB",xFilial("F2E")+DKM->DKM_IDTRIB,1)
		EndCase	
			
		If !Empty(cIdTotvs)

			If !Empty(cIdTotvs)
				If  CItem <> DKM->DKM_ITEM
					CItem := DKM->DKM_ITEM
					cPosItem := Iif(lCalCol,ALLTRIM(str(VAL(DKM->DKM_ITEM))),AllTrim(Str(n)))
					jTribGen[cPosItem] := JsonObject():New()
				Endif
				jTribGen[cPosItem][cIdTotvs] := JsonObject():New()		

				If lFindFuEIC .And. DKM->DKM_TABELA == "SWN" //Valor da DKM gerado pelo Módulo do SIGAEIC (Easy Import Control)
					comex.generics.eic.getTribDKMImport(@jTribGen, cPosItem, cIdTotvs)
				Else
					If DKM->DKM_VALOR > 0
						jTribGen[cPosItem][cIdTotvs]["base_valor"] := DKM->DKM_BASE
						jTribGen[cPosItem][cIdTotvs]["aliquota"] := DKM->DKM_ALIQ
						jTribGen[cPosItem][cIdTotvs]["valor"] := DKM->DKM_VALOR
					Else
						jTribGen[cPosItem][cIdTotvs]["base_valor"] := DKM->DKM_XMLBAS
						jTribGen[cPosItem][cIdTotvs]["aliquota"] := DKM->DKM_XMLALQ
						jTribGen[cPosItem][cIdTotvs]["valor"] := DKM->DKM_XMLVLR
					Endif														

					jTribGen[cPosItem][cIdTotvs]["base_um"] := ""
					jTribGen[cPosItem][cIdTotvs]["esc_CST"] := DKM->DKM_CST
					jTribGen[cPosItem][cIdTotvs]["esc_CCT"] := Right(DKM->DKM_CLASTR, 3) //DKM_CLASTR-junção CST+CCT, sendo que os três primeiros são CST e os três últimos são relativos CCT

					If DKM->DKM_VALOR > 0
						jTribGen[cPosItem][cIdTotvs]["esc_vl_tributado"] := DKM->DKM_VALOR
					Else
						jTribGen[cPosItem][cIdTotvs]["esc_vl_tributado"] := DKM->DKM_XMLVLR
					Endif
					
					jTribGen[cPosItem][cIdTotvs]["esc_vl_isento"] := 0
					jTribGen[cPosItem][cIdTotvs]["esc_vl_outros"] := 0
					jTribGen[cPosItem][cIdTotvs]["esc_vl_diferido"] := DKM->DKM_VDIF
					jTribGen[cPosItem][cIdTotvs]["esc_pc_diferido"] := DKM->DKM_PDIF
					jTribGen[cPosItem][cIdTotvs]["esc_pc_reducao_base"] := 0
					jTribGen[cPosItem][cIdTotvs]["esc_base_original"] := DKM->DKM_XMLBAS
					jTribGen[cPosItem][cIdTotvs]["esc_pc_reducao_aliq"] := DKM->DKM_PREDAL
					jTribGen[cPosItem][cIdTotvs]["esc_aliquota_original"] := DKM->DKM_ALQEFE
				Endif
			Endif
		Endif
	Endif

DKM->(dbskip())
EndDo
RestArea(aAreaDKM)

Return jTribGen
