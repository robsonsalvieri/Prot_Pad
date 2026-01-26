#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FILEIO.CH"

Static s_CRIRAT		:= SuperGetMv("MV_CRIRAT",,"1")

//--------------------------------------------------------------------
/*{Protheus.doc} GFEA110B

EDI - NotFis 5.0

- Geração de um arquivo com as notas da faixa por transportador

Estrutura do arquivo:
.................................................
000 [Transportador]
500
 | 501 [Emissor] (max 100) 
 |  | 502
 |  |-> 503 [Destinatário] (max 500)
 |       |   504
 |       |-> 505 [Documentos de carga] (max 500) 
 |            |   506
 |            |   507
 |            |-> 508 (max 50)
 |            |-> 509 (max 50)
 |       	  |-> 511 (max 5.000)
 |       	  |   513
 |       	  |   514
 |       	  |   515
519
.................................................

@author Israel Alcantara Possoli
@since 24/10/2014
@version 1.0
*///--------------------------------------------------------------------

Static lPEA1108   := ExistBlock("GFEA1108")
Static lPEA1109   := ExistBlock("GFEA1109")
Static lPEB11010  := ExistBlock("GFE11010")
Static lPEB11011  := ExistBlock("GFE11011")
Static lPEA11009  := ExistBlock("GFE11009")

Function GFEA110B()
	Local lRetPE := .F.
	Private cFilialDe
	Private cFilialAte
	Private cSerieDe
	Private cSerieAte
	Private cNrDocDe
	Private cNrDocAte
	Private dDtSaiDe
	Private dDtSaiAte 
	Private dDtEmisDe 
	Private dDtEmisAte
	Private cGrpEmit  
	Private cTranspDe 
	Private cTranspAte
	Private nEmbarcado
	Private cRomDe    
	Private cRomAte   
	Private nEnvSemDt 
	Private nAgrpItem
	Private nReenvDoc 
	Private cDiretorio
	Private cEnvEmail
	Private oProcess

	Private GFEResult 	:= GFEViewProc():New()
	
	Private cFileTemplate := "EDI_NOTFIS_50_<TRANSP>_<DATA>.txt"
	Private lCompGU3 := FWModeAccess("GU3", 3) == "C"
	
	If !IsBlind()
		// Ponto de entrada para substituir o grupo de perguntas padrão
		If lPEB11010
			lRetPE := ExecBlock("GFE11010",.F.,.F.)
			If ValType(lRetPE) != "L" .And. !lRetPE
				Return Nil
			EndIf
		Else
			If !Pergunte("GFEA110B",.T.)
				Return Nil
			EndIf
		EndIf		
	EndIf	

	If lPEA11009
		lRetPE := ExecBlock("GFE11009",.f.,.f.)
		If ValType(lRetPE) != "L" .And. !lRetPE
			Return Nil
		EndIf
	EndIf

	cFilialDe  := MV_PAR01
	cFilialAte := MV_PAR02 
	cSerieDe   := MV_PAR03 
	cSerieAte  := MV_PAR04 
	cNrDocDe   := MV_PAR05 
	cNrDocAte  := MV_PAR06 
	dDtSaiDe   := MV_PAR07 
	dDtSaiAte  := MV_PAR08 
	dDtEmisDe  := MV_PAR09 
	dDtEmisAte := MV_PAR10 
	cTranspDe  := MV_PAR11
	cTranspAte := MV_PAR12
	cGrpEmit   := MV_PAR13
	nEmbarcado := MV_PAR14 
	cRomDe     := MV_PAR15 
	cRomAte    := MV_PAR16 
	nEnvSemDt  := MV_PAR17 
	nAgrpItem  := MV_PAR18 
	nReenvDoc  := MV_PAR19 
	cDiretorio := AllTrim(MV_PAR20)
	cEnvEmail  := MV_PAR21

	If IsBlind()
		Processamento()	
	Else
		oProcess := MsNewProcess():New( { || Processamento() }, "Exportação de NotFis", "Iniciando processo..." )
		oProcess:Activate()
	EndIf
	
	If !IsBlind() 
		GFEResult:Show("Exportação NotFis 5.0", "Detalhes", "Detalhes", "Alguns documentos encontrados na faixa de parâmetros não puderam ser enviados. Clique no botão 'Detalhes' para mais detalhes:")
	EndIf
Return

//--------------------------------------------------------------------
// Processamento
//  - aDados505
//		[1] CFOP
//		[2] Tipo de Lotação
//		[3] Tabela de Frete
//  - aDadosNF
//		[1] (Branco)
//		[2] Qtdade Total de Volumes
//		[3] Peso bruto total da Mercadoria/Nota
//		[4] Peso Líquido total da mercadoria
//		[5] Peso Densidade/Cubagem          
//		[6] Peso Cubado                     
//		[7] Incide ICMS? [S/N/I]
//		[8] Seguro efetuado? [S/N]?
//		[9] Valor a ser cobrado do cliente
//		...
//	- aDadosCalc
//--------------------------------------------------------------------
Static Function Processamento()
	Local nTotalSQL
	Local cChaveTransp
	Local cChaveEmissor
	Local cChaveDestinatario
	Local cChaveEntrega
	Local lValDC				:= .T.
	Local nQtdValDC				:= 0
	
	Private aDados505[5]
	Private aDadosNF[26]
	Private aDadosCalc[29]
	Private aDados519[3]
	Private aItens
	Private nRedespachoId		// Armazena o RecNo do Redespachante (próximo trecho)
	Private cAliasSQL
	Private nSeq000 	:= 0
	Private nSeq500 	:= 0
	Private nSeq313		:= 0
	Private lRomaneio := .F.
	Private aLinhas 	:= {}
	Private cErrosResult
	Private aEndEnt 	:= {}
	Private nEndEnt 	:= ''
	Private GFELog110	:= GFELog():New("EDI_NotFis_Exportacao", "EDI NotFis 5.0", SuperGetMV('MV_GFEEDIL',,'1'))
	Private p_ERPINT 	:= SuperGetMV("MV_ERPGFE",,'1')
	Private cFil     := ""
	
	If !IsBlind()
		GFELog110:ShowParameters("GFEA110B")
	EndIf
	
	BuscaSQL()
	
	GFELog110:NewLine(2)
	
	nTotalSQL := 0
	While !(cAliasSQL)->(Eof())
		nTotalSQL++
		(cAliasSQL)->(dbSkip())
	EndDo
	
	If oProcess != Nil
		oProcess:setRegua1(nTotalSQL)
	EndIf
	
	nQtdValDC := 0
	
	(cAliasSQL)->(dbGoTop())
	
	If lCompGU3
		cFil := xFilial("GU3")
	Else
		cFil := (cAliasSQL)->GW1_FILIAL
	EndIf

	While !(cAliasSQL)->(Eof())
		cErrosResult := ""
		lValDC	     := .T.
		
		If oProcess != Nil
			oProcess:incRegua1("Transp: " + AllTrim((cAliasSQL)->GWU_CDTRP) + ", Série: " + AllTrim((cAliasSQL)->GWU_SERDC) + ", Número: " + AllTrim((cAliasSQL)->GWU_NRDC))
			oProcess:setRegua2(2) // Régua 2 para o caso de estar parametrizado para envio de e-mail
		EndIf
		
		// Romaneio -----		
		GWN->(dbSetOrder(1))
		If GWN->(dbSeek((cAliasSQL)->GW1_FILIAL + (cAliasSQL)->GW1_NRROM))
			lRomaneio := .T.
		Else
			lRomaneio := .F.
		EndIf
		
		// Quebra por arquivo por Transportador - 000
		If cChaveTransp != (cAliasSQL)->GWU_CDTRP
			If !Empty(cChaveTransp)
				GFEResult:Add("")
			EndIf
			GFEResult:Add("TRANSPORTADOR: " + (cAliasSQL)->GWU_CDTRP)
			
			cChaveTransp  		:= (cAliasSQL)->GWU_CDTRP
			cChaveEmissor 		:= ""
			cChaveDestinatario  := ""
			cChaveEntrega		:= ""
			nSeq313		  		:= 0
			aFill(aDados519, 0)
			
			Reg000()
			Reg500()
		EndIf
		
		GFEResult:Add("> Filial: " + AllTrim((cAliasSQL)->GWU_FILIAL) + ", Tipo Doc: " + AllTrim((cAliasSQL)->GWU_CDTPDC) + ", Emissor: " + AllTrim((cAliasSQL)->GWU_EMISDC) + ", Série: " + AllTrim((cAliasSQL)->GWU_SERDC) + ", Número: " + AllTrim((cAliasSQL)->GWU_NRDC), 1)
		GFELog110:Add("> Filial: " + (cAliasSQL)->GWU_FILIAL + ", Tipo Doc: " + (cAliasSQL)->GWU_CDTPDC + ", Emissor: " + (cAliasSQL)->GWU_EMISDC + ", Série: " + (cAliasSQL)->GWU_SERDC + ", Número: " + (cAliasSQL)->GWU_NRDC, 1)
		
		lValDC := ValidGW1()
		
		If lValDC
			nQtdValDC++
			
			// Quebra por Emissor - 501
			If cChaveEmissor != (cAliasSQL)->GW1_EMISDC
				cChaveEmissor 	  	:= (cAliasSQL)->GW1_EMISDC
				ChaveDestinatario 	:= ""
				cChaveEntrega		:= ""
				
				Reg501()
				Reg502()
			EndIf
			
			If ChaveDestinatario != (cAliasSQL)->GW1_CDDEST .OR. cChaveEntrega != (cAliasSQL)->GW1_ENTNRC
				ChaveDestinatario 	:= (cAliasSQL)->GW1_CDDEST
				cChaveEntrega		:= (cAliasSQL)->GW1_ENTNRC
				
				Reg503()	// Destinatário
				Reg504()	// Local da entrega (Quando for diferente do destinatário)
			Else
				//verifica se o Endereço do Alias é diferente dos demais Endereços de Entrega
				nEndEnt := aScan(aEndEnt, {|x|  AllTrim(x[1]) ==  AllTrim((cAliasSQL)->GW1_ENTEND)})
			    If !nEndEnt 
					Reg503() 				   					
					Reg504()
				EndIf			
			EndIf
			
			// Informações dos itens
			BuscaDadosNF()
			
			Reg505()	// Nota Fiscal
			Reg506()	// Valores da Nota Fiscal
			Reg507()	// Cálculo do Frete
			Reg508()	// Identificação da Carga
			Reg509()	// Dados de entreda casada
			Reg511()	// Itens da Nota
			Reg513()	// Consignatário da Nota
			Reg514()	// Redespachante da nota
			Reg515()	// Responsável pelo Frete
		EndIf
		
		CheckErros()
		
		(cAliasSQL)->(dbSkip())
		
		// Salva o arquivo
		If nQtdValDC != 0 
			If ((cAliasSQL)->(Eof()) .OR. cChaveTransp != (cAliasSQL)->GWU_CDTRP)
				SalvarEDI(cChaveTransp)
			EndIf
		EndIf
	EndDo
	
	If nTotalSQL == 0 .Or. nQtdValDC == 0 
		GFELog110:Add("Nenhum arquivo exportado.",1)
		GFELog110:Add("Possíveis causas",1)
		GFELog110:Add("- Tipo de Documento de Carga não configurado para enviar por EDI (GV5_EDI).",1)
		GFELog110:Add("- Parametros informados em tela não correspondem a documentos registrados no sistema.",1)
		GFELog110:Add("- Os documentos de Carga já foram exportados. Para serem exportados novamente, o parametro em tela 'Reenvia Documentos' deve estar como 'Sim'.",1)
		GFELog110:Add("- Os documentos de Carga estão com a situação (GW1_SIT) Bloqueados.",1)
		GFELog110:Add("- Habilitando o Log do EDI (MV_GFEEDIL) outras informações são geradas, incluise o comando SQL utilizado para encontrar os Documentos de Carga a serem exportados.",1)
		GFEResult:AddDetail("Nenhum arquivo exportado.",1)
		GFEResult:AddDetail("Possíveis causas",1)
		GFEResult:AddDetail("- Tipo de Documento de Carga não configurado para enviar por EDI (GV5_EDI).",1)
		GFEResult:AddDetail("- Parametros informados em tela não correspondem a documentos registrados no sistema.",1)
		GFEResult:AddDetail("- Os documentos de Carga já foram exportados. Para serem exportados novamente, o parametro em tela 'Reenvia Documentos' deve estar como 'Sim'.",1)
		GFEResult:AddDetail("- Os documentos de Carga estão com a situação (GW1_SIT) Bloqueados.",1)
		GFEResult:AddDetail("- Habilitando o Log do EDI (MV_GFEEDIL) outras informações são geradas, incluise o comando SQL utilizado para encontrar os Documentos de Carga a serem exportados.",1)
		GFEResult:SetWarningIcon()
	EndIf
	
	GFELog110:EndLog()
Return


//--------------------------------------------------------------------
// ValidGW1 - Validação do Documento de Carga
//--------------------------------------------------------------------
Static Function ValidGW1()
 	Local lRet := .T.
	
	// Tipo de Frete
	If (cAliasSQL)->GW1_TPFRET != "1" .AND. (cAliasSQL)->GW1_TPFRET != "2" .AND. GW1->GW1_TPFRET == "3" .AND. GW1->GW1_TPFRET == "4"
		lRet := .F.
		AddError("Tipo de Frete inválido para exportação do EDI: " + (cAliasSQL)->GW1_TPFRET)
	EndIF		
	
	// Tipo do Documento de Carga
    GV5->(dbSetOrder(1))		
    If GV5->(dbSeek(xFilial("GV5") + (cAliasSQL)->GW1_CDTPDC) )
    	If GV5->GV5_EDI == "2" // Envia EDI? 1: Sim, 2: Não
    		lRet := .F.
			AddError("Tipo do documento de carga cadastrado para não enviar arquivo EDI", 1)
		Endif
	Endif
		 
Return lRet

//--------------------------------------------------------------------
// Reg000 - Cabeçalho de Intercâmbio
//--------------------------------------------------------------------
Static Function Reg000()
	Local cLinha
	Local cCgcSMO
	
	GFELog110:NewLine()
	GFELog110:Add("Gerando informações para o arquivo do transportador: " + AllTrim((cAliasSQL)->GWU_CDTRP))
	
	cCgcSMO := GetAdvFVal('SM0', 'M0_CGC', cEmpAnt + cFilAnt, 1, '')
	cCgcSMO := StrTran ( cCgcSMO,"-","")
	GFELog110:Add(" - CNPJ da filial corrente: " + cCgcSMO)
	
	nSeq000++
	
	cLinha := "000"
	cLinha += FormatCampo(POSICIONE("GU3", 11, xFilial("GU3") + cCgcSMO               , "GU3_CXEDI"), 35)
	cLinha += FormatCampo(POSICIONE("GU3",  1, xFilial("GU3") + (cAliasSQL)->GWU_CDTRP, "GU3_CXEDI"), 35)
	cLinha += FormatCampo(DDATABASE, 6, 'D')
	cLinha += FormatCampo(Time(), 4, 'H')
	cLinha += "NOT50" + FormatCampo(DDATABASE, 4, 'D') + FormatCampo(nSeq000, 3, 'N')
	cLinha += FormatCampo("", 225)
	
	aADD(aLinhas, cLinha)
Return


//--------------------------------------------------------------------
// Reg500 - Cabeçalho de Documento
//--------------------------------------------------------------------
Static Function Reg500()
	Local cLinha
	
	nSeq500++
	
	cLinha := "500"
	cLinha += "NOTAS50" + FormatCampo(DDATABASE, 4, 'D') + FormatCampo(nSeq500, 3, 'N')
	cLinha += FormatCampo("", 303)
	
	aADD(aLinhas, cLinha)
Return


//--------------------------------------------------------------------
// Reg501 - Dados da Embarcadora
// Registro para identificar o emitente da Nota Fiscal
//--------------------------------------------------------------------
Static Function Reg501()
	Local cLinha
	Local cAliGU3 := GetNextAlias()

	// Verifica se o emitente do Documento de Carga é uma filial
	BEGINSQL Alias cAliGU3
		SELECT GU3.R_E_C_N_O_ AS RECNUM
		FROM %Table:GU3% GU3
		WHERE GU3.%NotDel%
		AND GU3.GU3_FILIAL = %Exp:cFil% 
		AND GU3.GU3_CDEMIT = %Exp:(cAliasSQL)->GW1_EMISDC%
		AND GU3.%NotDel% 
	ENDSQL
	If (cAliGU3)->(!EoF())
		GU3->(dbSetOrder(1))
		GU3->(dbGoTo( (cAliGU3)->RECNUM ))
	Else
		AddError("501 :: Emitente não encontrado com o CNPJ da filial corrente. Verifique se o cadastro do emitente do Documento de Carga esta indicado como FILIAL.")
		Return .F.
	EndIf
	(cAliGU3)->(dbCloseArea())

	GU7->(dbSetOrder(1))
	If !GU7->(dbSeek(xFilial("GU7") + GU3->GU3_NRCID))
		AddError("501 :: Cidade da filial não encontrada. Emitente: " + GU3->GU3_CDEMIT + ", Cidade: " + GU3->GU3_NRCID)
		Return .F.
	EndIf

	cLinha := "501"										//  1. Identificador de Registro
	cLinha += FormatCampo(GU3->GU3_NMEMIT 	, 50)		//  2. Razão Social
	cLinha += FormatCampo(GU3->GU3_IDFED 	, 14, 'N')	//  3. CNPJ (CGC)
	cLinha += FormatCampo(GFEFormIE(GU3->GU3_IE), 15)	//  4. Inscrição Estadual
	cLinha += FormatCampo(""   		     	, 15) 		//  5. Inscrição Estadual do Substituto Tributário
	cLinha += FormatCampo(GU3->GU3_IM     	, 15) 		//  6. Inscrição Municipal
	cLinha += FormatCampo(GU3->GU3_ENDER 	, 50)		//  7. Endereço
	cLinha += FormatCampo(GU3->GU3_BAIRRO	, 35)		//  8. Bairro
	cLinha += FormatCampo(GU7->GU7_NMCID 	, 35)		//  9. Cidade
	cLinha += FormatCampo(GU3->GU3_CEP		,  9)		// 10. CEP
	cLinha += FormatCampo(GU7->GU7_NRCID 	,  9)		// 11. Código da Cidade/Município
	cLinha += FormatCampo(GU7->GU7_CDUF  	,  9)		// 12. UF

	If lRomaneio
		cLinha += FormatCampo(GWN->GWN_DTIMPL,  8, 'D')	// 13. Data do Embarque das mercadorias
	Else
		cLinha += FormatCampo(""			,  8)	// 13. Data do Embarque das mercadorias
	EndIf

	cLinha += FormatCampo(""				,  4)		// 14. Área de Frete
	cLinha += FormatCampo(""				, 25)		// 15. Contato para Emergência
	cLinha += FormatCampo(""				, 24)		// 16. (Filler)

	aADD(aLinhas, cLinha)
Return .T.


//--------------------------------------------------------------------
// Reg502 - Dados do Local de Coleta/Retirada
// Registro para identificar o local de Coleta/Retirada da Nota Fiscal
// Gerado apenas quando for redespacho (Local de coleta diferente do emissor)
//--------------------------------------------------------------------
Static Function Reg502()
	Local cLinha
	Local nSeq
	Local cSeq
	
	If Empty((cAliasSQL)->GWU_SEQ) .OR. IsAlpha((cAliasSQL)->GWU_SEQ)
		AddError("502 :: Sequência do trecho inválida. Transp: " + (cAliasSQL)->GWU_CDTRP + ", Seq: " + (cAliasSQL)->GWU_SEQ)
	EndIf
	
	If AllTrim((cAliasSQL)->GWU_SEQ) == "01"
		Return .T.
	EndIf

	nSeq := Val(AllTrim((cAliasSQL)->GWU_SEQ))
	cSeq := PadL(AllTrim(Str(nSeq)), 2, "0")
	
	GWU->(dbSetOrder(1)) // GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
	If GWU->(dbSeek((cAliasSQL)->GWU_FILIAL + (cAliasSQL)->GWU_CDTPDC + (cAliasSQL)->GWU_EMISDC + (cAliasSQL)->GWU_SERDC + (cAliasSQL)->GWU_NRDC + cSeq))

		GU3->(dbSetOrder(1))
		If !GU3->(dbSeek(xFilial("GU3") + GWU->GWU_CDTRP))
			AddError("502 :: Emitente (transportador) não encontrado: " + GWU->GWU_CDTRP)
			Return .F.
		EndIf
	
		GU7->(dbSetOrder(1))
		If !GU7->(dbSeek(xFilial("GU7") + GU3->GU3_NRCID))
			AddError("502 :: Cidade do transportador não encontrada. Transportador: " + GWU->GWU_CDTRP + ", Cidade: " + GU3->GU3_NRCID)
			Return .F.
		EndIf		
		
		cLinha := "502"										//  1. Identificador de Registro
		cLinha += FormatCampo(GU3->GU3_NMEMIT 	, 50)		//  2. Razão Social
		cLinha += FormatCampo(GU3->GU3_IDFED 	, 14, 'N')	//  3. CNPJ (CGC)
		cLinha += FormatCampo(GU3->GU3_ENDER 	, 50)		//  4. Endereço
		cLinha += FormatCampo(GU3->GU3_BAIRRO	, 35)		//  5. Bairro
		cLinha += FormatCampo(GU7->GU7_NMCID 	, 35)		//  6. Cidade
		cLinha += FormatCampo(GU3->GU3_CEP		,  9)		//  7. CEP
		cLinha += FormatCampo(GU7->GU7_NRCID 	,  9)		//  8. Código da Cidade/Município
		cLinha += FormatCampo(GU7->GU7_CDUF  	,  9)		//  9. UF
		cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
						      GU3->GU3_FONE2	,  35)		// 10. Número de comunicação (Telefone)
		cLinha += FormatCampo(""				,  4)		// 11. Área de Frete
		cLinha += FormatCampo(""				,  67)		// 12. (Filler)
		aADD(aLinhas, cLinha)
	Else
		AddError("502 :: Não foi possível identificar o trecho anterior ao da sequência '" + (cAliasSQL)->GWU_SEQ + "'")
	EndIf
Return


//--------------------------------------------------------------------
// Reg503 - Dados do Destinatário da Nota
//--------------------------------------------------------------------
Static Function Reg503()
	Local cLinha

	GU3->(dbSetOrder(1))
	If !GU3->(dbSeek(cFil + (cAliasSQL)->GW1_CDDEST))
		AddError("503 :: Emitente (destinatário) não encontrado: " + (cAliasSQL)->GW1_CDDEST)
		Return .F.
	EndIf

	GU7->(dbSetOrder(1))
	If !GU7->(dbSeek(xFilial("GU7") + GU3->GU3_NRCID))
		AddError("503 :: Cidade do destinatário não encontrada. Destinatário: " + (cAliasSQL)->GW1_CDDEST + ", Cidade: " + GU3->GU3_NRCID)
		Return .F.
	EndIf

	
	cLinha := "503"												//  1. Identificador de Registro
	cLinha += FormatCampo(GU3->GU3_NMEMIT 			, 50)		//  2. Razão Social
	cLinha += FormatCampo(GU3->GU3_IDFED 			, 14, 'N')	//  3. CNPJ (CGC)
	cLinha += FormatCampo(GFEFormIE(GU3->GU3_IE)	, 15)		//  4. Inscrição Estadual
	cLinha += FormatCampo(""   		     			, 15) 		//  5. Inscrição na Suframa
	cLinha += FormatCampo(GU3->GU3_ENDER 			, 50)		//  6. Endereço
	cLinha += FormatCampo(GU3->GU3_BAIRRO			, 35)		//  7. Bairro
	cLinha += FormatCampo(GU7->GU7_NMCID 			, 35)		//  8. Cidade
	cLinha += FormatCampo(GU3->GU3_CEP				,  9)		//  9. CEP
	cLinha += FormatCampo(GU7->GU7_NRCID 			,  9)		// 10. Código da Cidade/Município
	cLinha += FormatCampo(GU7->GU7_CDUF  			,  9)		// 11. UF
	cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
					      GU3->GU3_FONE2			,  35)		// 12. Número de comunicação (Telefone)
	cLinha += FormatCampo(PaisBacen(GU7->GU7_CDPAIS),  4)		// 13. Código de País
	cLinha += FormatCampo(""						,  4)		// 14. Área de Frete
	cLinha += FormatCampo(TipoIdent(GU3->GU3_NATUR)	,  1)		// 15. Tipo de Identificação do Destinatário (1: CNPJ, 2: CPF)
	cLinha += FormatCampo(""						,  1)		// 16. Tipo do Estabelecimento destino da mercadoria
	cLinha += FormatCampo(""						, 31)		// 17.
	aADD(aLinhas, cLinha)
Return


//--------------------------------------------------------------------
// Reg504 - Dados do Local de Entrega
// Registro para identificar o local de Entrega
//--------------------------------------------------------------------
Static Function Reg504()
	Local cLinha
	
	nRedespachoId := 0
	
	GWU->(dbSetOrder(1))
	If GWU->(dbSeek((cAliasSQL)->GWU_FILIAL + (cAliasSQL)->GWU_CDTPDC + (cAliasSQL)->GWU_EMISDC + (cAliasSQL)->GWU_SERDC + (cAliasSQL)->GWU_NRDC + (cAliasSQL)->GWU_SEQ))
		GWU->(dbSkip())
		
		// Quando não for o último trecho, usa as informações do próximo transportador
		// como dados do local de entrega
		If GWU->GWU_FILIAL == (cAliasSQL)->GWU_FILIAL .AND. ;
		   GWU->GWU_CDTPDC == (cAliasSQL)->GWU_CDTPDC .AND. ;
		   GWU->GWU_EMISDC == (cAliasSQL)->GWU_EMISDC .AND. ;
		   GWU->GWU_SERDC  == (cAliasSQL)->GWU_SERDC  .AND. ;
		   GWU->GWU_NRDC   == (cAliasSQL)->GWU_NRDC
		   
		   nRedespachoId := GWU->(RecNo())
		   
			GFELog110:Add("- 504 :: Local de entrega será o próximo trecho. Seq. Atual: " + (cAliasSQL)->GWU_SEQ + ", Seq. Próximo Trecho: " + GWU->GWU_SEQ, 2)
		   
			GU3->(dbSetOrder(1))
			If !GU3->(dbSeek(xFilial("GU3") + GWU->GWU_CDTRP))
				AddError("504 :: Emitente (transportador) não encontrado: " + GWU->GWU_CDTRP)
				Return .F.
			EndIf

			GU7->(dbSetOrder(1))
			If !GU7->(dbSeek(xFilial("GU7") + GU3->GU3_NRCID))
				AddError("504 :: Cidade do transportador não encontrada. Transportador: " + GWU->GWU_CDTRP + ", Cidade: " + GU3->GU3_NRCID)
				Return .F.
			EndIf
			
			// Quando a cidade destino do trecho atual for igual a cidade do transportador de destino do (próximo trecho)
			// Informa todos os dados do cadastro de emitente
			If GU3->GU3_NRCID == (cAliasSQL)->GWU_NRCIDD
			
				cLinha := "504"												//  1. Identificador de Registro
				cLinha += FormatCampo(GU3->GU3_NMEMIT 			, 50)		//  2. Razão Social
				cLinha += FormatCampo(GU3->GU3_IDFED 			, 14, 'N')	//  3. CNPJ (CGC)
				cLinha += FormatCampo(GFEFormIE(GU3->GU3_IE)	, 15)		// 18. Inscrição Estadual
				cLinha += FormatCampo(GU3->GU3_ENDER 			, 50)		//  4. Endereço
				cLinha += FormatCampo(GU3->GU3_BAIRRO			, 35)		//  5. Bairro
				cLinha += FormatCampo(GU7->GU7_NMCID 			, 35)		//  6. Cidade
				cLinha += FormatCampo(GU3->GU3_CEP				,  9)		//  7. CEP
				cLinha += FormatCampo(GU7->GU7_NRCID 			,  9)		//  8. Código da Cidade/Município
				cLinha += FormatCampo(GU7->GU7_CDUF  			,  9)		//  9. UF
				cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
								      GU3->GU3_FONE2			,  35)		// 10. Número de comunicação (Telefone)
				cLinha += FormatCampo(PaisBacen(GU7->GU7_CDPAIS),  4)	// 11. Código de País
				cLinha += FormatCampo(""						,  4)		// 12. Área de Frete
				cLinha += FormatCampo(TipoIdent(GU3->GU3_NATUR),  1)		// 13. Tipo de Identificação do Destinatário (1: CNPJ, 2: CPF)
				cLinha += FormatCampo(""						,  1)		// 14. Tipo do Estabelecimento destino da mercadoria
				cLinha += FormatCampo(""						, 46)		// 15. (Filler)
				aADD(aLinhas, cLinha)
			Else
				// Quando a cidade do trecho for DIFERENTE da cidade do transportador
				// Informa apenas os dados essenciais, não informando endereço, bairro e outras informações
				dbSelectArea("GU7")
				dbSetOrder(1)
				If !dbSeek(xFilial("GU7") + (cAliasSQL)->GWU_NRCIDD)
					AddError("504 :: Cidade do trecho não encontrada. Seq: " + GWU->GWU_SEQ + ", Cidade: " + GWU->GWU_NRCIDD )
					Return .F.
				EndIf
				
				GFELog110:Add("- 504 :: Cidade de destino está diferente do cadastro do transportador de redespacho (próximo trecho), endereço/bairro/cep não serão informados. Cidade destino: " + GWU->GWU_NRCIDD + ", Cidade transp: " + GU3->GU3_NRCID, 2)
				
				cLinha := "504"												//  1. Identificador de Registro
				cLinha += FormatCampo(GU3->GU3_NMEMIT 			, 50)		//  2. Razão Social
				cLinha += FormatCampo(GU3->GU3_IDFED 			, 14, 'N')	//  3. CNPJ (CGC)
				cLinha += FormatCampo(GFEFormIE(GU3->GU3_IE)	, 15)		// 18. Inscrição Estadual
				cLinha += FormatCampo(""						, 50)		//  4. Endereço
				cLinha += FormatCampo(""						, 35)		//  5. Bairro
				cLinha += FormatCampo(GU7->GU7_NMCID 			, 35)		//  6. Cidade
				cLinha += FormatCampo(""						,  9)		//  7. CEP
				cLinha += FormatCampo(GU7->GU7_NRCID 			,  9)		//  8. Código da Cidade/Município
				cLinha += FormatCampo(GU7->GU7_CDUF  			,  9)		//  9. UF
				cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
								      GU3->GU3_FONE2			,  35)		// 10. Número de comunicação (Telefone)
				cLinha += FormatCampo(PaisBacen(GU7->GU7_CDPAIS),  4)  // 11. Código de País
				cLinha += FormatCampo(""						,  4)		// 12. Área de Frete
				cLinha += FormatCampo(TipoIdent(GU3->GU3_NATUR),  1)		// 13. Tipo de Identificação do Destinatário (1: CNPJ, 2: CPF)
				cLinha += FormatCampo(""						,  1)		// 14. Tipo do Estabelecimento destino da mercadoria
				cLinha += FormatCampo(""						, 46)		// 15. (Filler)
				aADD(aLinhas, cLinha)
			EndIf
		Else
			// Quando houver cidade de entrega no cabeçalho do Documento de Carga
			If !Empty((cAliasSQL)->GW1_ENTNRC)
		   
		   		GFELog110:Add("- 504 :: Documento de carga possui endereço de entrega diferente do cadastro do destinatário.", 2)
		   		
				dbSelectArea("GU3")
				dbSetOrder(1)
				If !dbSeek(xFilial("GU3") + (cAliasSQL)->GW1_CDDEST)
					AddError("504 :: Emitente (destinatário) não encontrado: " + (cAliasSQL)->GW1_CDDEST)
					Return .F.
				EndIf
							
				dbSelectArea("GU7")
				dbSetOrder(1)
				If !dbSeek(xFilial("GU7") + (cAliasSQL)->GW1_ENTNRC)
					AddError("504 :: Cidade de entrega não encontrada no cadastro de cidades: " + GWU->GWU_NRCIDD)
					Return .F.
				EndIf
							
				cLinha := "504"												//  1. Identificador de Registro
				cLinha += FormatCampo(GU3->GU3_NMEMIT 			, 50)		//  2. Razão Social
				cLinha += FormatCampo(GU3->GU3_IDFED 			, 14, 'N')	//  3. CNPJ (CGC)
				cLinha += FormatCampo(GFEFormIE(GU3->GU3_IE)	, 15)		// 18. Inscrição Estadual
				cLinha += FormatCampo((cAliasSQL)->GW1_ENTEND 	, 50)		//  4. Endereço
				cLinha += FormatCampo((cAliasSQL)->GW1_ENTBAI	, 35)		//  5. Bairro
				cLinha += FormatCampo(GU7->GU7_NMCID 			, 35)		//  6. Cidade
				cLinha += FormatCampo((cAliasSQL)->GW1_ENTCEP	,  9)		//  7. CEP
				cLinha += FormatCampo(GU7->GU7_NRCID 			,  9)		//  8. Código da Cidade/Município
				cLinha += FormatCampo(GU7->GU7_CDUF  			,  9)		//  9. UF
				cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
								      GU3->GU3_FONE2			,  35)		// 10. Número de comunicação (Telefone)
				cLinha += FormatCampo(PaisBacen(GU7->GU7_CDPAIS),  4)		// 11. Código de País
				cLinha += FormatCampo(""						,  4)		// 12. Área de Frete
				cLinha += FormatCampo(TipoIdent(GU3->GU3_NATUR),  1)		// 13. Tipo de Identificação do Destinatário (1: CNPJ, 2: CPF)
				cLinha += FormatCampo(""						,  1)		// 14. Tipo do Estabelecimento destino da mercadoria
				cLinha += FormatCampo(""						, 46)		// 15. (Filler)
				aADD(aLinhas, cLinha)
			EndIf
		EndIf
	EndIf
	AADD(aEndEnt,{(cAliasSQL)->GW1_ENTEND, (cAliasSQL)->GW1_ENTBAI, GU7->GU7_NMCID, (cAliasSQL)->GW1_ENTCEP, GU7->GU7_NRCID, GU7->GU7_CDUF } ) //salva os endereços de entrega
Return


//--------------------------------------------------------------------
// Reg505 - Dados da Nota Fiscal
//--------------------------------------------------------------------
Static Function Reg505()
	Local cLinha
	Local cMeioTransp
	Local cTpPeriodoEnt
	Local dDataEntrega
	Local cHoraEntrega
	Local cAcaoDoc    := "I"
	Local aRet109     := {}
	Local cPedVenda   := ''
	Local cIdEmbarque := ''
	Local cAliGXP     := Nil
	Local cRomaneio   := (cAliasSQL)->GW1_NRROM
	Local cPlanoCarga := ''
	Local lTMSAtivo   := SuperGetMv("MV_INTTMS", .F., .F.) == .T.
	
	nSeq313++

	If lPEA1109	
		aRet109 := ExecBlock("GFEA1109",.f.,.f.,{(cAliasSQL)->GW1_FILIAL, (cAliasSQL)->GW1_CDTPDC, (cAliasSQL)-> GW1_EMISDC, (cAliasSQL)->GW1_SERDC, (cAliasSQL)->GW1_NRDC})
		
		If !Empty(aRet109[1])
			cPedVenda := aRet109[1]
		EndIf
		If !Empty(aRet109[2])
			cRomaneio := aRet109[2]
		EndIf
		If !Empty(aRet109[3])
			cIdEmbarque := aRet109[3]
		EndIf
		If !Empty(aRet109[4])
			cPlanoCarga := aRet109[4]
		EndIf
	EndIf
	
	//	8. Meio de Transporte
	//		GU3_MODAL	=> 1: Nao-informado, 2: Rodoviario, 3: Ferroviario, 4: Aereo  , 5: Aquaviario , 6: Dutoviario, 7: Multimodal
	//		EDI       	=> 1: Rodoviário   , 2: Aéreo	  , 3: Marítimo   , 4: Fluvial, 5: Ferroviário, 6: Multimodal
	cMeioTransp  := "1"
	
	If (cAliasSQL)->GU3_MODAL == "3"		// Ferroviario
		cMeioTransp := "5"
	ElseIf (cAliasSQL)->GU3_MODAL == "4"	// Aereo
		cMeioTransp := "2"
	ElseIf (cAliasSQL)->GU3_MODAL == "5"	// Aquaviario
		cMeioTransp := "4"
	ElseIf (cAliasSQL)->GU3_MODAL == "7"	// Multimodal
		cMeioTransp := "6"
	EndIf
	
	//Ação do Documento
	If (cAliasSQL)->GW1_SIT == '7' .And. (cAliasSQL)->GW1_ENVEDI == '1'
		cAcaoDoc := "E"
	Else
		cAcaoDoc := "I"
	EndIf

	// 27. Tipo Período Entrega
	cTpPeriodoEnt := '0'
	cHoraEntrega  := "0000"
	If !Empty((cAliasSQL)->GWU_DTENT)
		cTpPeriodoEnt := '1'
		dDataEntrega := SToD((cAliasSQL)->GWU_DTENT)
		cHoraEntrega := (cAliasSQL)->GWU_HRENT
	ElseIf !Empty((cAliasSQL)->GWU_DTPENT)
		cTpPeriodoEnt := '3'
		dDataEntrega := SToD((cAliasSQL)->GWU_DTPENT)
		cHoraEntrega := (cAliasSQL)->GWU_HRPENT
	EndIf

	GW1->( DbGoTo((cAliasSQL)->RECNOGW1) )
	cAliGXP := GFEA110GXP({(cAliasSQL)->GW1_FILIAL, (cAliasSQL)->GW1_CDTPDC, (cAliasSQL)-> GW1_EMISDC, (cAliasSQL)->GW1_SERDC, (cAliasSQL)->GW1_NRDC})	// Listagem de dados das NFs em Tabela GXP
	If Empty(GW1->GW1_DANFE) .And. lTMSAtivo .And. (cAliGXP)->(!EoF())	// Busca documentos de coleta por integração TMS
		While (cAliGXP)->(!EoF())

			cLinha := "505"														//  1. Identificador de Registro
			cLinha += FormatCampo((cAliGXP)->SERNFC		 ,  3)					//  2. Série
			cLinha += FormatCampo((cAliGXP)->NUMNFC		 ,  9)					//  3. Número da Nota Fiscal
			cLinha += FormatCampo(SToD((cAliGXP)->EMINFC),  8, 'D')				//  4. Data de Emissão
			cLinha += FormatCampo(NatuMercad()			 , 15)					//  5. Natureza (Tipo) da Mercadoria
			cLinha += FormatCampo((cAliasSQL)->GW1_DSESP , 15)					//  6. Espécie de Acondicionamento
			cLinha += FormatCampo((cAliasSQL)->GW1_NRREG ,  7)					//  7. Código da Rota
			cLinha += FormatCampo(cMeioTransp			 ,  1)					//  8. Meio de Transporte [1: Rodoviário, 2: Aéreo, 3 Marítimo, 4: Fluvial, 5: Ferroviário, 6: Multimodal]
			cLinha += FormatCampo(aDados505[2]			 ,  1)					//  9. Tipo do Transporte da Carga [1: Carga Fechada, 2: Carga Fracionada]
			cLinha += FormatCampo("2"					 ,  1)					// 10. Tipo de Carga [1: Fria, 2: Seca, 3: Mista]
			cLinha += FormatCampo(CondFrete()			 ,  1)					// 11. Condição de Frete [C: CIF, F: FOB]
			If lRomaneio														// 12. Data do Embarque das mercadorias
				cLinha += FormatCampo(GWN->GWN_DTSAI,  8, 'D')
			Else
				cLinha += FormatCampo(""			,  8)
			EndIf
			cLinha += FormatCampo(""							, 10)			// 13. Desdobro
			cLinha += FormatCampo(cPlanoCarga					,  1)			// 14. Plano de Carga Rápida [S: Sim, N: Não]
			cLinha += FormatCampo(TipoDocFis()					,  1)			// 15. Tipo do Documento Fiscal [0: Entrada, 1: Saída]
			cLinha += FormatCampo(""							,  1)			// 16. Indicação de Bonificação [S: Sim, N: Não]
			cLinha += FormatCampo(aDados505[1]					,  4)			// 17. Código Fiscal de Operação (CFOP)
			cLinha += FormatCampo(UFEmit((cAliasSQL)->GW1_CDREM),  2)			// 18. Sigla do estado do fato gerador (Remetente)
			cLinha += FormatCampo(""							,  1)			// 19. Cálculo de Frete Diferenciado? (S/N)
			cLinha += FormatCampo(aDados505[3]					, 10)			// 20. Tabela de Frete
			cLinha += FormatCampo(""							,  2)			// 21. Modalidade de Frete
			
			cLinha += FormatCampo(cPedVenda	 , 20)								// 22. Identificação do Pedido do Cliente
			cLinha += FormatCampo(cRomaneio  , 20)								// 23. Número Romaneio, Ordem de Coleta, Resumo de Carga (Identificação do Embarque)
			cLinha += FormatCampo(cIdEmbarque, 20)								// 24. Identificação do Embarque #1 (Livre)
			
			cLinha += FormatCampo(""							 , 20)			// 25. Identificação do Embarque #2 (Livre)
			cLinha += FormatCampo(""							 , 20)			// 26. Identificação do Embarque #3 (Livre)
			cLinha += FormatCampo(cTpPeriodoEnt					 , 1)			// 27. Tipo de Período de Entrega [0: Sem data, 1: Na Data, 2: Até a Data, 3: A partir de, 4: Período]
			cLinha += FormatCampo(dDataEntrega					 , 8, 'D')		// 28. Data Inicial de Entrega
			cLinha += FormatCampo(cHoraEntrega					 , 4, 'H')		// 29. Hora Inicial de Entrega
			cLinha += FormatCampo("00000000"					 , 8)			// 30. Data Final de Entrega
			cLinha += FormatCampo("0000"						 , 4)			// 31. Hora Final de Entrega
			cLinha += FormatCampo(SubStr((cAliGXP)->DANFE, 36, 8), 9)			// 32. Código numérico que compõe a chave de acesso da nota na SEFAZ
			cLinha += FormatCampo((cAliGXP)->DANFE				 , 45)			// 33. Chave (44) + Dígito verificador (1) para acesso a nota na sefaz
			cLinha += FormatCampo(""							 , 15)			// 34. Número do protocolo da NF-e
			cLinha += FormatCampo(cAcaoDoc						 , 1)			// 35. Ação do Documento [I: Inclusão, E: Exclusão]
			cLinha += FormatCampo(""							 , 21)			// 36. (Filler)

			aADD(aLinhas, cLinha)

			(cAliGXP)->(dbSkip())
		EndDo

	Else
		cLinha := "505"															//  1. Identificador de Registro
		cLinha += FormatCampo((cAliasSQL)->GW1_SERDC		,  3)				//  2. Série
		cLinha += FormatCampo((cAliasSQL)->GW1_NRDC			,  9)				//  3. Número da Nota Fiscal
		cLinha += FormatCampo(SToD((cAliasSQL)->GW1_DTEMIS)	,  8, 'D')			//  4. Data de Emissão
		cLinha += FormatCampo(NatuMercad()					, 15)				//  5. Natureza (Tipo) da Mercadoria
		cLinha += FormatCampo((cAliasSQL)->GW1_DSESP		, 15)				//  6. Espécie de Acondicionamento
		cLinha += FormatCampo((cAliasSQL)->GW1_NRREG		,  7)				//  7. Código da Rota
		cLinha += FormatCampo(cMeioTransp					,  1)				//  8. Meio de Transporte [1: Rodoviário, 2: Aéreo, 3 Marítimo, 4: Fluvial, 5: Ferroviário, 6: Multimodal]
		cLinha += FormatCampo(aDados505[2]					,  1)				//  9. Tipo do Transporte da Carga [1: Carga Fechada, 2: Carga Fracionada]
		cLinha += FormatCampo("2"							,  1)				// 10. Tipo de Carga [1: Fria, 2: Seca, 3: Mista]
		cLinha += FormatCampo(CondFrete()					,  1)				// 11. Condição de Frete [C: CIF, F: FOB]
		If lRomaneio															// 12. Data do Embarque das mercadorias
			cLinha += FormatCampo(GWN->GWN_DTSAI 			,  8, 'D')
		Else
			cLinha += FormatCampo(""						,  8)
		EndIf
		cLinha += FormatCampo(""							, 10)				// 13. Desdobro
		cLinha += FormatCampo(cPlanoCarga					,  1)				// 14. Plano de Carga Rápida [S: Sim, N: Não]
		cLinha += FormatCampo(TipoDocFis()					,  1)				// 15. Tipo do Documento Fiscal [0: Entrada, 1: Saída]
		cLinha += FormatCampo(""							,  1)				// 16. Indicação de Bonificação [S: Sim, N: Não]
		cLinha += FormatCampo(aDados505[1]					,  4)				// 17. Código Fiscal de Operação (CFOP)
		cLinha += FormatCampo(UFEmit((cAliasSQL)->GW1_CDREM),  2)				// 18. Sigla do estado do fato gerador (Remetente)
		cLinha += FormatCampo(""							,  1)				// 19. Cálculo de Frete Diferenciado? (S/N)
		cLinha += FormatCampo(aDados505[3]					, 10)				// 20. Tabela de Frete
		cLinha += FormatCampo(""							,  2)				// 21. Modalidade de Frete
		
		cLinha += FormatCampo(cPedVenda							, 20)			// 22. Identificação do Pedido do Cliente
		cLinha += FormatCampo(cRomaneio							, 20)			// 23. Número Romaneio, Ordem de Coleta, Resumo de Carga (Identificação do Embarque)
		cLinha += FormatCampo(cIdEmbarque						, 20)			// 24. Identificação do Embarque #1 (Livre)
		
		cLinha += FormatCampo(""							, 20)				// 25. Identificação do Embarque #2 (Livre)
		cLinha += FormatCampo(""							, 20)				// 26. Identificação do Embarque #3 (Livre)
		cLinha += FormatCampo(cTpPeriodoEnt					,  1)				// 27. Tipo de Período de Entrega [0: Sem data, 1: Na Data, 2: Até a Data, 3: A partir de, 4: Período]
		cLinha += FormatCampo(dDataEntrega					,  8, 'D')			// 28. Data Inicial de Entrega
		cLinha += FormatCampo(cHoraEntrega					,  4, 'H')			// 29. Hora Inicial de Entrega
		cLinha += FormatCampo("00000000"					,  8)				// 30. Data Final de Entrega
		cLinha += FormatCampo("0000"						,  4)				// 31. Hora Final de Entrega
		cLinha += FormatCampo(SubStr((cAliasSQL)->GW1_DANFE, 36, 8), 9)			// 32. Código numérico que compõe a chave de acesso da nota na SEFAZ
		cLinha += FormatCampo((cAliasSQL)->GW1_DANFE		, 45)				// 33. Chave (44) + Dígito verificador (1) para acesso a nota na sefaz
		cLinha += FormatCampo(""							, 15)				// 34. Número do protocolo da NF-e
		cLinha += FormatCampo(cAcaoDoc							,  1)			// 35. Ação do Documento [I: Inclusão, E: Exclusão]
		cLinha += FormatCampo(""							, 21)				// 36. (Filler)

		aADD(aLinhas, cLinha)
	EndIf

	If Select( cAliGXP ) > 0
		(cAliGXP)->(dbCloseArea())
	EndIf
Return


//--------------------------------------------------------------------
// Reg506 - Valores da Nota Fiscal
//--------------------------------------------------------------------
Static Function Reg506()
	Local cLinha
	Local cAliGXP   := Nil
	Local lTMSAtivo := SuperGetMv("MV_INTTMS", .F., .F.) == .T.

	GW1->( DbGoTo((cAliasSQL)->RECNOGW1) )
	cAliGXP := GFEA110GXP({(cAliasSQL)->GW1_FILIAL, (cAliasSQL)->GW1_CDTPDC, (cAliasSQL)-> GW1_EMISDC, (cAliasSQL)->GW1_SERDC, (cAliasSQL)->GW1_NRDC})	// Listagem de dados das NFs em Tabela GXP
	If Empty(GW1->GW1_DANFE) .And. lTMSAtivo .And. (cAliGXP)->(!EoF())	// Busca documentos de coleta por integração TMS
		While (cAliGXP)->(!EoF())
			cLinha := "506"												//  1. Identificador de Registro
			cLinha += FormatCampo((cAliGXP)->QTDD		,  6, 'N', 2)	//  2. Qtde total de volumes/embalagens
			cLinha += FormatCampo((cAliGXP)->PESO		,  6, 'N', 3)	//  3. Peso bruto total da mercadoria/Nota
			cLinha += FormatCampo((cAliGXP)->PESO		,  6, 'N', 3)	//  4. Peso Líquido total da mercadoria 
			cLinha += FormatCampo((cAliGXP)->PESOM3		,  6, 'N', 4)	//  5. Peso Densidade/Cubagem           
			cLinha += FormatCampo((cAliGXP)->PESOM3		,  6, 'N', 4)	//  6. Peso Cubado                      
			cLinha += FormatCampo(aDadosNF[7]			,  1)			//  7. Incide ICMS? [S/N/I]
			cLinha += FormatCampo(aDadosNF[8]			,  1)			//  8. Seguro efetuado? [S/N]?
			cLinha += FormatCampo(aDadosNF[9]			, 13, 'N', 2)	//  9. Valor a ser cobrado do cliente
			cLinha += FormatCampo((cAliGXP)->VALOR		, 13, 'N', 2)	// 10. Valor total da nota
			cLinha += FormatCampo((cAliGXP)->VALSEG		, 13, 'N', 2)	// 11. Valor total do seguro
			cLinha += FormatCampo(aDadosNF[12]			, 13, 'N', 2)	// 12. Valor total do desconto
			cLinha += FormatCampo(aDadosNF[13]			, 13, 'N', 2)	// 13. Valor total outras despesas acessórias
			cLinha += FormatCampo((cAliGXP)->BASICM		, 13, 'N', 2)	// 14. Base de Cálculo do ICMS
			cLinha += FormatCampo((cAliGXP)->VALICM		, 13, 'N', 2)	// 15. Valor total do ICMS
			cLinha += FormatCampo((cAliGXP)->BASESU		, 13, 'N', 2)	// 16. Base de cálculo do ICMS Subst. Tributária
			cLinha += FormatCampo((cAliGXP)->VALIST		, 13, 'N', 2)	// 17. Valor total do ICMS Subst
			cLinha += FormatCampo((cAliGXP)->ICMRET		, 13, 'N', 2)	// 18. Valor do ICMS retido
			cLinha += FormatCampo(aDadosNF[19]			, 13, 'N', 2)	// 19. Valor total do imposto de importação
			cLinha += FormatCampo(aDadosNF[20]			, 13, 'N', 2)	// 20. Valor total do IPI
			cLinha += FormatCampo(aDadosNF[21]			, 13, 'N', 2)	// 21. Valor total do PIS
			cLinha += FormatCampo(aDadosNF[22]			, 13, 'N', 2)	// 22. Valor total do COFINS
			cLinha += FormatCampo(aDadosNF[23]			, 13, 'N', 2)	// 23. Valor total Calculado do Frete * 
			cLinha += FormatCampo(aDadosNF[24]			, 11, 'N', 2)	// 24. Valor total do ICMS do Frete * 
			cLinha += FormatCampo(aDadosNF[25]			, 11, 'N', 2)	// 25. Valor total ICMS-Subst Tributária do Frete *
			cLinha += FormatCampo(aDadosNF[26]			, 11, 'N', 2)	// 26. Valor total do ISS do frete *
			cLinha += FormatCampo(""					,  5)			// 27. (Filler)
			// * Apenas se não gerar registro 507 - Cálculo de Frete

			aADD(aLinhas, cLinha)

			(cAliGXP)->(dbSkip())
		EndDo

	Else
		cLinha := "506"												//  1. Identificador de Registro
		cLinha += FormatCampo(aDadosNF[2]			,  6, 'N', 2)	//  2. Qtde total de volumes/embalagens
		cLinha += FormatCampo(aDadosNF[3]			,  6, 'N', 3)	//  3. Peso bruto total da mercadoria/Nota
		cLinha += FormatCampo(aDadosNF[4]			,  6, 'N', 3)	//  4. Peso Líquido total da mercadoria 
		cLinha += FormatCampo(aDadosNF[5]			,  6, 'N', 4)	//  5. Peso Densidade/Cubagem           
		cLinha += FormatCampo(aDadosNF[6]			,  6, 'N', 4)	//  6. Peso Cubado                      
		cLinha += FormatCampo(aDadosNF[7]			,  1)			//  7. Incide ICMS? [S/N/I]
		cLinha += FormatCampo(aDadosNF[8]			,  1)			//  8. Seguro efetuado? [S/N]?
		cLinha += FormatCampo(aDadosNF[9]			, 13, 'N', 2)	//  9. Valor a ser cobrado do cliente
		cLinha += FormatCampo(aDadosNF[10]			, 13, 'N', 2)	// 10. Valor total da nota
		cLinha += FormatCampo(aDadosNF[11]			, 13, 'N', 2)	// 11. Valor total do seguro
		cLinha += FormatCampo(aDadosNF[12]			, 13, 'N', 2)	// 12. Valor total do desconto
		cLinha += FormatCampo(aDadosNF[13]			, 13, 'N', 2)	// 13. Valor total outras despesas acessórias
		cLinha += FormatCampo(aDadosNF[14]			, 13, 'N', 2)	// 14. Base de Cálculo do ICMS
		cLinha += FormatCampo(aDadosNF[15]			, 13, 'N', 2)	// 15. Valor total do ICMS
		cLinha += FormatCampo(aDadosNF[16]			, 13, 'N', 2)	// 16. Base de cálculo do ICMS Subst. Tributária
		cLinha += FormatCampo(aDadosNF[17]			, 13, 'N', 2)	// 17. Valor total do ICMS Subst
		cLinha += FormatCampo(aDadosNF[18]			, 13, 'N', 2)	// 18. Valor do ICMS retido
		cLinha += FormatCampo(aDadosNF[19]			, 13, 'N', 2)	// 19. Valor total do imposto de importação
		cLinha += FormatCampo(aDadosNF[20]			, 13, 'N', 2)	// 20. Valor total do IPI
		cLinha += FormatCampo(aDadosNF[21]			, 13, 'N', 2)	// 21. Valor total do PIS
		cLinha += FormatCampo(aDadosNF[22]			, 13, 'N', 2)	// 22. Valor total do COFINS
		cLinha += FormatCampo(aDadosNF[23]			, 13, 'N', 2)	// 23. Valor total Calculado do Frete * 
		cLinha += FormatCampo(aDadosNF[24]			, 11, 'N', 2)	// 24. Valor total do ICMS do Frete * 
		cLinha += FormatCampo(aDadosNF[25]			, 11, 'N', 2)	// 25. Valor total ICMS-Subst Tributária do Frete *
		cLinha += FormatCampo(aDadosNF[26]			, 11, 'N', 2)	// 26. Valor total do ISS do frete *
		cLinha += FormatCampo(""					,  5)			// 27. (Filler)
		// * Apenas se não gerar registro 507 - Cálculo de Frete

		aADD(aLinhas, cLinha)
	EndIf

	If Select( cAliGXP ) > 0
		(cAliGXP)->(dbCloseArea())
	EndIf
Return



//--------------------------------------------------------------------
// Reg507 - Cálculo do Frete
//--------------------------------------------------------------------
Static Function Reg507()
	Local cLinha
	
	cLinha := "507"												//  1. Identificador de Registro
	cLinha += FormatCampo(aDadosCalc[2]		,  6, 'N', 2)	//  2. Quantidade Total de Volumes/Embalagens
	cLinha += FormatCampo(aDadosCalc[3]		,  6, 'N', 3)	//  3. Peso Total Transportado (Peso Bruto)
	cLinha += FormatCampo(aDadosCalc[4]		,  6, 'N', 4)	//  4. Peso Total Cubado
	cLinha += FormatCampo(aDadosCalc[5]		,  6, 'N', 4)	//  5. Peso Densidade/Cubagem
	cLinha += FormatCampo(aDadosCalc[6]		, 13, 'N', 2)	//  6. Valor Total do Frete
	cLinha += FormatCampo(aDadosCalc[7]		, 13, 'N', 2)	//  7. Frete Peso/Volume 
	cLinha += FormatCampo(aDadosCalc[8]		, 13, 'N', 2)	//  8. Frete Valor
	cLinha += FormatCampo(aDadosCalc[9]		, 13, 'N', 2)	//  9. 
	cLinha += FormatCampo(aDadosCalc[10]		, 13, 'N', 2)	// 10. 
	cLinha += FormatCampo(aDadosCalc[11]		, 13, 'N', 2)	// 11. 
	cLinha += FormatCampo(aDadosCalc[12]		, 13, 'N', 2)	// 12. 
	cLinha += FormatCampo(aDadosCalc[13]		, 13, 'N', 2)	// 13. Pedágio
	cLinha += FormatCampo(aDadosCalc[14]		, 13, 'N', 2)	// 14. 
	cLinha += FormatCampo(aDadosCalc[15]		, 13, 'N', 2)	// 15. Taxas
	cLinha += FormatCampo(aDadosCalc[16]		, 13, 'N', 2)	// 16. 
	cLinha += FormatCampo(aDadosCalc[17]		,  3, 'N', 2)	// 17. 
	cLinha += FormatCampo(aDadosCalc[18]		, 13, 'N', 2)	// 18. 
	cLinha += FormatCampo(aDadosCalc[19]		, 1)			// 19. Substituição Tributária? [1: Sim, 2: Não, 3: Isento, operação dentro do estado]
	cLinha += FormatCampo(aDadosCalc[20]		, 13, 'N', 2)	// 20. 
	cLinha += FormatCampo(aDadosCalc[21]		,  3, 'N', 2)	// 21. % ICMS - Substituição Tributária
	cLinha += FormatCampo(aDadosCalc[22]		, 13, 'N', 2)	// 22. 
	cLinha += FormatCampo(aDadosCalc[23]		, 13, 'N', 2)	// 23. 
	cLinha += FormatCampo(aDadosCalc[24]		,  3, 'N', 2)	// 24. % ISS
	cLinha += FormatCampo(aDadosCalc[25]		, 13, 'N', 2)	// 25. 
	cLinha += FormatCampo(aDadosCalc[26]		, 13, 'N', 2)	// 26. 
	cLinha += FormatCampo(aDadosCalc[27]		,  3)			// 27. Direito Fiscal [IC3: Exportação, Z23: Com Substituição Tributária, IC0: Sem Subst. Tributária]
	cLinha += FormatCampo(aDadosCalc[28]		,  4)			// 28. Tipo de Imposto [ICM3: Exportação, ICM3: Com Subst. Tributária, ICM1: Sem Subst. Tributária]
	cLinha += FormatCampo(aDadosCalc[29]		,  2)			// 29. Sigla do estado (UF) do fato gerador do ICMS
	cLinha += FormatCampo(""					,  1)			// 30. (Filler)
	// * Apenas se não gerar registro 507 - Cálculo de Frete

	aADD(aLinhas, cLinha)
Return



//--------------------------------------------------------------------
// Reg508 - Dados de Identificação da Carga
//--------------------------------------------------------------------
Static Function Reg508()
	Local cLinha
	Local cDsUnit
	
	If p_ERPINT == "1"
		If(AllTrim((cAliasSQL)->GW1_DSESP) != "")
			cLinha := "508"												//  1. Identificador de Registro
			cLinha += FormatCampo((cAliasSQL)->GW1_DSESP	, 50)	    //  2. Espécie de Acondicionamento do Item
			cLinha += FormatCampo(""		, 50)						//  3. Numeração dos Volumes Transportados
			cLinha += FormatCampo(""		, 50)		         		//  4. Número dos lacres
			cLinha += FormatCampo(""		, 167)	  					//  5. (Filler)
			aADD(aLinhas, cLinha)
		EndIf
	Else
		GWB->(dbSetOrder(2))
		GWB->(dbSeek((cAliasSQL)->GW1_FILIAL + (cAliasSQL)->GW1_CDTPDC + (cAliasSQL)->GW1_EMISDC + (cAliasSQL)->GW1_SERDC + (cAliasSQL)->GW1_NRDC))
		While !GWB->(Eof()) .AND. ;
		       GWB->GWB_FILIAL == (cAliasSQL)->GW1_FILIAL .AND. ;
		       GWB->GWB_CDTPDC == (cAliasSQL)->GW1_CDTPDC .AND. ;
		       GWB->GWB_EMISDC == (cAliasSQL)->GW1_EMISDC .AND. ;
		       GWB->GWB_SERDC  == (cAliasSQL)->GW1_SERDC .AND. ;
		       GWB->GWB_NRDC   == (cAliasSQL)->GW1_NRDC
		    
		 	cDsUnit := POSICIONE("GUG",1, xFilial("GUG") + GWB->GWB_CDUNIT, "GUG_DSUNIT")
			cLinha := "508"												//  1. Identificador de Registro
			cLinha += FormatCampo(cDsUnit	, 50)  				    	//  2. Marca dos Volumes Transportados
			cLinha += FormatCampo(""		, 50)						//  3. Numeração dos Volumes Transportados
			cLinha += FormatCampo(""		, 50)		         		//  4. Número dos lacres
			cLinha += FormatCampo(""		, 167)	  					//  5. (Filler)
		       
			aADD(aLinhas, cLinha)
			
			GWB->(dbSkip())
		EndDo
	EndIf
Return

//--------------------------------------------------------------------
// Reg509 - Dados de Entrega Casada
//--------------------------------------------------------------------
Static Function Reg509()
	// Informação não existente no GFE	       
Return


//--------------------------------------------------------------------
// Reg511 - Item da Nota Fiscal
//--------------------------------------------------------------------
Static Function Reg511()
	Local nI
	
	If nAgrpItem == 2
		Return
	EndIf
	
	For nI := 1 To Len(aItens)
		aADD(aLinhas, aItens[nI])
	Next
Return


//--------------------------------------------------------------------
// Reg513 - Dados do Consignatário da Nota
//--------------------------------------------------------------------
Static Function Reg513()
	Local cLinha

	dbSelectArea("GU3")
	dbSetOrder(1)

	If !dbSeek(cFil + (cAliasSQL)->GW1_CDDEST)
		AddError("513 :: Emitente (consignatário) não encontrado: " + (cAliasSQL)->GW1_CDDEST)
		Return .F.
	EndIf

	dbSelectArea("GU7")
	dbSetOrder(1)
	If !dbSeek(xFilial("GU7") + GU3->GU3_NRCID)
		AddError("513 :: Cidade do consignatário não encontrada. Emitente: " + GU3->GU3_CDEMIT + ", Cidade: " + GU3->GU3_NRCID)
		Return .F.
	EndIf	
	
	cLinha := "513"											//  1. Identificador de Registro
	cLinha += FormatCampo(GU3->GU3_NMEMIT		,  50)		//  2. Nome do Consignatário
	cLinha += FormatCampo(GU3->GU3_IDFED		,  14, 'N')	//  3. CNPJ
	cLinha += FormatCampo(GFEFormIE(GU3->GU3_IE),  15)		//  4. Inscrição Estadual
	cLinha += FormatCampo(GU3->GU3_ENDER + " " + ;
					  AllTrim(GU3->GU3_COMPL)	,  50)		//  5. Endereço
	cLinha += FormatCampo(GU3->GU3_BAIRRO		,  35)		//  6. Bairro
	cLinha += FormatCampo(GU7->GU7_NMCID		,  35)		//  7. Cidade
	cLinha += FormatCampo(GU3->GU3_CEP			,  9)		//  8. CEP
	cLinha += FormatCampo(GU3->GU3_NRCID		,  9)		//  9. Código de Município
	cLinha += FormatCampo(GU7->GU7_CDUF			,  9)		// 10. Código de Sigla de Estado
	cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
						GU3->GU3_FONE2			, 35)		// 11. Número de Comunicação
	cLinha += FormatCampo(""					, 56)		// 12. (Filler)

	aADD(aLinhas, cLinha)
Return


//--------------------------------------------------------------------
// Reg514 - Dados do Redespacho da Nota
//--------------------------------------------------------------------
Static Function Reg514()
	Local cLinha
	
	If nRedespachoId == 0
		Return
	EndIf
	
	dbSelectArea("GWU")
	dbSetOrder(1)
	dbGoTo(nRedespachoId)

	dbSelectArea("GU3")
	dbSetOrder(1)
	If !dbSeek(xFilial("GU3") + GWU->GWU_CDTRP)
		AddError("514 :: Emitente (redespachamte) não encontrado: " + GWU->GWU_CDTRP)
		Return .F.
	EndIf
	
	dbSelectArea("GU7")
	dbSetOrder(1)
	If !dbSeek(xFilial("GU7") + GU3->GU3_NRCID)
		AddError("514 :: Cidade do redespachante não encontrada. Emitente: " + GU3->GU3_CDEMIT + ", Cidade: " + GU3->GU3_NRCID)
		Return .F.
	EndIf	
	
	cLinha := "514"											//  1. Identificador de Registro
	cLinha += FormatCampo(GU3->GU3_NMEMIT		,  50)		//  2. Nome do Redespachante
	cLinha += FormatCampo(GU3->GU3_IDFED		,  14, 'N')	//  3. CNPJ
	cLinha += FormatCampo(GFEFormIE(GU3->GU3_IE),  15)		//  4. Inscrição Estadual
	cLinha += FormatCampo(GU3->GU3_ENDER + " " + ;
					  AllTrim(GU3->GU3_COMPL)	,  50)		//  5. Endereço
	cLinha += FormatCampo(GU3->GU3_BAIRRO		,  35)		//  6. Bairro
	cLinha += FormatCampo(GU7->GU7_NMCID		,  35)		//  7. Cidade
	cLinha += FormatCampo(GU3->GU3_CEP			,  9)		//  8. CEP
	cLinha += FormatCampo(GU3->GU3_NRCID		,  9)		//  9. Código de Município
	cLinha += FormatCampo(GU7->GU7_CDUF			,  9)		// 10. Código de Sigla de Estado
	cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
						GU3->GU3_FONE2			, 35)		// 11. Número de Comunicação
	cLinha += FormatCampo(""					, 4)		// 12. Área de Frete
	cLinha += FormatCampo(""					, 52)		// 13. (Filler)

	aADD(aLinhas, cLinha)
Return


//--------------------------------------------------------------------
// Reg515 - Dados do responsável pelo frete
//--------------------------------------------------------------------
Static Function Reg515()
	Local cLinha
	Local cCdEmit  := ""
	Local cIe      := ""
	Local cFilCons := (cAliasSQL)->GW1_FILIAL
	Local s_INTTMS := SuperGetMv("MV_INTTMS", .F., .F.)
	
	If lCompGU3
		cFilCons := xFilial("GU3")
	EndIf

	// Quando integrado com o TMS Protheus, é um transportador que utiliza o GFE
	// Desta forma, os dados do responsável pelo frete é a propria filial
	If s_INTTMS == .T.

		If Empty(cFilCons) .And. !lCompGU3
			cFilCons := cFilAnt
		EndIf

		GFELog110:Add("- Parametro (MV_INTTMS) habilitado. Registro 515 será exportado com os dados da filial " + cFilCons, 1)

		SM0->(dbSetOrder(1)) // CÓDIGO + Cod. Filial
		If SM0->( dbSeek(FWGrpCompany() + cFilCons) )  // Pesquisa com Código + Cód. Filial selecionado.
			GU3->(dbSetOrder(11))
			If GU3->(dbSeek(cFilCons + SM0->M0_CGC))
				cCdEmit	:= GU3->GU3_CDEMIT
			Else
				GFEResult:AddDetail("Registro 317 não gerado pois o CNPJ da filial "+cFilCons+" não está cadastrado no cadastro de emitentes (GU3).",1)
				GFELog110:Add("Registro 317 não gerado pois o CNPJ da filial "+cFilCons+" não está cadastrado no cadastro de emitentes (GU3).")
			EndIf
		EndIf
	Else
		If (cAliasSQL)->GW1_TPFRET     == "1" .OR. (cAliasSQL)->GW1_TPFRET == "2"
			cCdEmit := (cAliasSQL)->GW1_CDREM
		ElseIf (cAliasSQL)->GW1_TPFRET == "3" .OR. (cAliasSQL)->GW1_TPFRET == "4"
			cCdEmit := (cAliasSQL)->GW1_CDDEST
		Else
			Return .F.
		EndIf
	EndIf

	If lPEA1108
		cRet := ExecBlock("GFEA1108",.f.,.f.,{515})
		if !Empty(cRet)
			cCdEmit := cRet
		Endif
	EndIf

	dbSelectArea("GU3")
	dbSetOrder(1)
	If !dbSeek(cFilCons + cCdEmit)
		AddError("515 :: Emitente (pagador do frete) não encontrado: " + cCdEmit)
		Return .F.
	EndIf
	
	dbSelectArea("GU7")
	dbSetOrder(1)
	If !dbSeek(xFilial("GU7") + GU3->GU3_NRCID)
		AddError("515 :: Cidade do pagador do frete não encontrada. Emitente: " + GU3->GU3_CDEMIT + ", Cidade: " + GU3->GU3_NRCID)
		Return .F.
	EndIf	
	
	cIe := GFEFormIE(GU3->GU3_IE)
	
	If ExistBlock("GFEA1107")
		cRet := ExecBlock("GFEA1107",.f.,.f.,{(cAliasSQL)->GW1_FILIAL,;
			(cAliasSQL)->GW1_CDTPDC,(cAliasSQL)->GW1_EMISDC,;
			(cAliasSQL)->GW1_SERDC,(cAliasSQL)->GW1_NRDC})
			
		If !Empty(cRet)
			cIe := cRet
		EndIf
	EndIf			
	
	
	cLinha := "515"											//  1. Identificador de Registro
	cLinha += FormatCampo(GU3->GU3_NMEMIT		,  50)		//  2. Nome do Redespachante
	cLinha += FormatCampo(GU3->GU3_IDFED		,  14, 'N')	//  3. CNPJ
	cLinha += FormatCampo(cIe,  15)		//  4. Inscrição Estadual
	cLinha += FormatCampo(GU3->GU3_ENDER + " " + ;
					  AllTrim(GU3->GU3_COMPL)	,  50)		//  5. Endereço
	cLinha += FormatCampo(GU3->GU3_BAIRRO		,  35)		//  6. Bairro
	cLinha += FormatCampo(GU7->GU7_NMCID		,  35)		//  7. Cidade
	cLinha += FormatCampo(GU3->GU3_CEP			,  9)		//  8. CEP
	cLinha += FormatCampo(GU3->GU3_NRCID		,  9)		//  9. Código de Município
	cLinha += FormatCampo(GU7->GU7_CDUF			,  9)		// 10. Código de Sigla de Estado
	cLinha += FormatCampo(GU3->GU3_FONE1 + " " + ;
						GU3->GU3_FONE2			, 35)		// 11. Número de Comunicação
	cLinha += FormatCampo(""					, 56)		// 13. (Filler)

	aADD(aLinhas, cLinha)
Return



//--------------------------------------------------------------------
// Reg519 - Totais do Arquivo
//--------------------------------------------------------------------
Static Function Reg519()
	Local cLinha
	
	cLinha := "519"											//  1. Identificador de Registro
	cLinha += FormatCampo(aDados519[1]	,  13, 'N', 2)		//  2. Valor total das notas fiscais
	cLinha += FormatCampo(aDados519[2]	,  13, 'N', 2)		//  3. Peso bruto total das notas fiscais
	cLinha += FormatCampo(aDados519[3]	,  13, 'N', 2)		//  4. Quantidade total de volumes
	cLinha += FormatCampo(nSeq313		,  10, 'N')			//  5. Número de notas
	cLinha += FormatCampo(""			,  262)				//  5. Número de notas

	aADD(aLinhas, cLinha)
	
	// Zera acumuladores
	cChaveTransp  		:= ""
	cChaveEmissor 		:= ""
	cChaveDestinatario  := ""
	nSeq313		  		:= 0
	aFill(aDados519, 0)	
Return


//--------------------------------------------------------------------
// BuscaDadosNF
// Busca as informações do Documentos de Carga e armazena no array aDadosNF
//--------------------------------------------------------------------
Static Function BuscaDadosNF()
Local nQtdVolPE := 0
Local nFretPes := 0
Local nFretVal := 0
Local nTaxas := 0
Local nPedag := 0
Local aAreaGWH := {}
Local aValRat[4]
Local aRatFUNF[3]
Local nQtdeGW8 := 0

	aValRat[1] := 0
	aValRat[2] := 0
	aValRat[3] := 0
	aValRat[4] := 0

	aFill(aDados505, "")
	aFill(aDadosNF, 0)
	aFill(aDadosCalc, 0)
	aItens := {}
	
	// ------------------------------------------------
	// Dados da Nota Fiscal
	// ------------------------------------------------
	aDadosNF[1] := ""
	
	// 506 :: 2. Qtdade Total de Volumes
	aDadosNF[2] := (cAliasSQL)->GW1_QTVOL
	
	// PE para alterar a quantidade total de volumes
	If ExistBlock("GFEA1104")
		GW1->(DbGoTo((cAliasSQL)->RECNOGW1))
		nQtdVolPE := ExecBlock("GFEA1104",.F.,.F.)
		If ValType(nQtdVolPE) == 'N'
			aDadosNF[2] := nQtdVolPE
		EndIf
	EndIf
	
	// 	506 :: 7. Incide ICMS? [S/N/I]
	// 		EDI			=> S: Sim, N: Não, I: Isento
	// 		GW1_ICMSDC	=> 1:Sim, 2:Nao
	If (cAliasSQL)->GW1_ICMSDC == '1'
		aDadosNF[7] := "S"
	Else
		aDadosNF[7] := "N"
	EndIf
	
	// 506 :: 8. Seguro efetuado? [S/N]?
	aDadosNF[8] := ""
	

	// ------------------------------------------------
	// Dados dos Itens
	// ------------------------------------------------
	dbSelectArea("GW8")
	dbSetOrder(1)
	dbSeek((cAliasSQL)->GWU_FILIAL + (cAliasSQL)->GWU_CDTPDC + (cAliasSQL)->GWU_EMISDC + (cAliasSQL)->GWU_SERDC + (cAliasSQL)->GWU_NRDC)
	While !GW8->(Eof()) .AND. ;
	       GW8->GW8_FILIAL == (cAliasSQL)->GW1_FILIAL .AND. ;
	       GW8->GW8_CDTPDC == (cAliasSQL)->GW1_CDTPDC .AND. ;
	       GW8->GW8_EMISDC == (cAliasSQL)->GW1_EMISDC .AND. ;
	       GW8->GW8_SERDC  == (cAliasSQL)->GW1_SERDC  .AND. ;
	       GW8->GW8_NRDC   == (cAliasSQL)->GW1_NRDC
	
		// CFOP
		If Empty(aDados505[1]) .AND. !Empty(GW8->GW8_CFOP)
			aDados505[1] := GW8->GW8_CFOP
		EndIf
		
		aDadosNF[3]  += GW8->GW8_PESOR			// 506 :: 3. Peso Bruto Total
		aDadosNF[4]  += GW8->GW8_PESOR			// 506 :: 4. Peso Líquido total da mercadoria
		aDadosNF[5]  += GW8->GW8_VOLUME			// 506 :: 5. Peso Densidade/Cubagem
		aDadosNF[6]  += GW8->GW8_PESOC			// 506 :: 6. Peso Cubado
		aDadosNF[10] += GW8->GW8_VALOR			// 506 :: 10. Valor total da nota
		nQtdeGW8 += GW8->GW8_QTDE
		
		If nAgrpItem == 1
			DadosItens()
		EndIf
		
		GW8->(dbSkip())
	EndDo
	
	aDadosNF[3]  := Round(aDadosNF[3],3)
	aDadosNF[4]  := Round(aDadosNF[4],3)
	aDadosNF[5]  := Round(aDadosNF[5],4)
	aDadosNF[6]  := Round(aDadosNF[6],4)
	
	If Empty(aDados505[1])
		AddWarning("505 :: CFOP está em branco nos itens do documento.", 2)
	EndIf
	
	// ------------------------------------------------
	// 507 :: Dados dos Cálculo de Frete
	// ------------------------------------------------	
	aDadosCalc[2] := aDadosNF[2]
	aDadosCalc[3] := aDadosNF[3]
	aDadosCalc[4] := aDadosNF[6]
	aDadosCalc[5] := aDadosNF[5]
	aDadosCalc[19] := ''
	aDadosCalc[27] := ''
	aDadosCalc[28] := ''
	aDadosCalc[29] := ''
	
	GWH->(dbSetOrder(2))
	GWH->(dbSeek((cAliasSQL)->GW1_FILIAL + (cAliasSQL)->GW1_CDTPDC + (cAliasSQL)->GW1_EMISDC + (cAliasSQL)->GW1_SERDC + (cAliasSQL)->GW1_NRDC))
	While !GWH->(Eof()) .AND. ;
	       GWH->GWH_FILIAL == (cAliasSQL)->GW1_FILIAL .AND. ;
	       GWH->GWH_CDTPDC == (cAliasSQL)->GW1_CDTPDC .AND. ;
	       GWH->GWH_EMISDC == (cAliasSQL)->GW1_EMISDC .AND. ;
	       GWH->GWH_SERDC  == (cAliasSQL)->GW1_SERDC .AND. ;
	       GWH->GWH_NRDC   == (cAliasSQL)->GW1_NRDC
	    
	    If GWH->GWH_TRECHO == (cAliasSQL)->GWU_SEQ 

			GWG->(dbSetOrder(1))
			If GWG->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC))
				// 505 :: 9. Tipo Lotação	
				aDados505[3] := AllTrim(GWG->GWG_CDEMIT) + ";" + AllTrim(GWG->GWG_NRTAB) + ";" + AllTrim(GWG->GWG_NRNEG)
				
				GV9->(dbSetOrder(1))
				If GV9->(dbSeek(GWG->GWG_FILIAL + GWG->GWG_CDEMIT + GWG->GWG_NRTAB + GWG->GWG_NRNEG))
					// 505 :: 20. Tabela de Frete
					//		GV9_TPLOTA	=> 1: Carga Fracionada, 2: Carga Fechada, 3: Veiculo Dedicado
					//		EDI			=> 1: Carga Fechada   , 2: Carga Fracionada				
					If GV9->GV9_TPLOTA == "1"
						aDados505[2] := "2"
					ElseIf GV9->GV9_TPLOTA == "2"
						aDados505[2] := "2"
					EndIf
				EndIf
			EndIF
			
			
			GWF->(dbSetOrder(1))
			If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC))
				If GWF->GWF_TPCALC == '1' .Or. GWF->GWF_TPCALC == '6' // normal e redespacho
					// 1=Tributado;2=Isento/Não-tributado;3=Subs Tributária;4=Diferido;5=Reduzido;6=Outros;7=Presumido
					aDadosNF[14] += 000000000000000 		// 14. Base de Cálculo do ICMS
					aDadosNF[15] += 000000000000000			// 15. Valor total do ICMS
			
					If GWF->GWF_TPTRIB == '3'
						aDadosNF[16] += 000000000000000 	// 16. Base de cálculo do ICMS Subst. Tributária
						aDadosNF[17] += 000000000000000 	// 17. Valor total do ICMS Subst
					EndIf
			
					aDadosNF[18] += 000000000000000 		// 18. Valor do ICMS retido
					aDadosNF[21] += 000000000000000			// 21. Valor total do PIS
					aDadosNF[22] += 000000000000000 		// 22. Valor total do COFINS
					
					aAreaGWH := GWH->( GetArea() )
					
					//Realiza a soma de todos os criterios de rateio do DC
					GWH->( dbSetOrder(01) )
					GWH->( dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC) )
					While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL;
										  .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
						
						GW8->( dbSetOrder(01) )
						GW8->( dbSeek(GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC) ) )
						While !GW8->( Eof() ) .And. GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC) ==;
													GW8->(GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC)
							
							aValRat[1] += GW8->GW8_PESOR
							aValRat[2] += GW8->GW8_VOLUME
							aValRat[3] += GW8->GW8_VALOR
							aValRat[4] += GW8->GW8_QTDE
							
							GW8->( dbSkip() )
						EndDo
						
						GWH->( dbSkip() )
					EndDo
					
					RestArea(aAreaGWH)
					
					GWI->(dbSetOrder(1))
					GWI->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
					While !GWI->(Eof()) .AND. ;
					       GWI->GWI_FILIAL == GWF->GWF_FILIAL .AND. ;
					       GWI->GWI_NRCALC == GWF->GWF_NRCALC 
					    
					    GV2->(dbSetOrder(1))
					    GV2->(dbSeek(xFilial("GV2") + GWI->GWI_CDCOMP))
					    // Conforme combinado com Estela/Israel, não foi determinado o motivo da regra adotada até
					    // então, que usava também GV2_ATRCAL para determinar onde somar a variável. Por este motivo
					    // adotou-se a mesma regra do layout 3.1 e também usado na conferência de frete (GFEA066).
					    // GV2_CATVAL	=> 1: Frete Unidade, 2: Frete Valor, 3: Taxas, 4: Pedagio

						Do Case 
							Case GV2->GV2_CATVAL == '1'	.And. !(UPPER(Alltrim(GV2->GV2_CDCOMP)) $ "PEDAGIO")	// Valor do Frete por Peso/Volume
								nFretPes += GWI->GWI_VLFRET	
							Case GV2->GV2_CATVAL == '2'				// Frete Valor
								nFretVal += GWI->GWI_VLFRET
							Case GV2->GV2_CATVAL == '3'				//Taxas
								nTaxas += GWI->GWI_VLFRET						
							Case GV2->GV2_CATVAL == '4'	.Or. UPPER(Alltrim(GV2->GV2_CDCOMP)) $ "PEDAGIO"		// Pedágio
								nPedag += GWI->GWI_VLFRET
						EndCase
						
						GWI->(dbSkip())
					EndDo
					
					//Rateia o valor dos componentes pelo critério de rateio e Documento de Carga
					Do Case 
						//Peso
						Case s_CRIRAT == "1"
							aDadosCalc[7] := Round(( aDadosNF[3] / aValRat[1] ) * nFretPes, 2) //Valor do Frete por Peso/Volume
							aDadosCalc[8] := Round(( aDadosNF[3] / aValRat[1] ) * nFretVal, 2) //Frete Valor
							aDadosCalc[15] := Round(( aDadosNF[3] / aValRat[1] ) * nTaxas, 2) //Taxas
							aDadosCalc[13] := Round(( aDadosNF[3] / aValRat[1] ) * nPedag, 2) //Pedágio
						//Valor
						Case s_CRIRAT == "2"
							aDadosCalc[7] := Round(( aDadosNF[10] / aValRat[3] ) * nFretPes, 2) //Valor do Frete por Peso/Volume
							aDadosCalc[8] := Round(( aDadosNF[10] / aValRat[3] ) * nFretVal, 2) //Frete Valor
							aDadosCalc[15] := Round(( aDadosNF[10] / aValRat[3] ) * nTaxas, 2) //Taxas
							aDadosCalc[13] := Round(( aDadosNF[10] / aValRat[3] ) * nPedag, 2) //Pedágio
						//Quantidade
						Case s_CRIRAT == "3"
							aDadosCalc[7] := Round(( nQtdeGW8 / aValRat[4] ) * nFretPes, 2) //Valor do Frete por Peso/Volume
							aDadosCalc[8] := Round(( nQtdeGW8 / aValRat[4] ) * nFretVal, 2) //Frete Valor
							aDadosCalc[15] := Round(( nQtdeGW8 / aValRat[4] ) * nTaxas, 2) //Taxas
							aDadosCalc[13] := Round(( nQtdeGW8 / aValRat[4] ) * nPedag, 2) //Pedágio
						//Volume
						Case s_CRIRAT == "4"
							aDadosCalc[7] := Round(( aDadosNF[5] / aValRat[2] ) * nFretPes, 2) //Valor do Frete por Peso/Volume
							aDadosCalc[8] := Round(( aDadosNF[5] / aValRat[2] ) * nFretVal, 2) //Frete Valor
							aDadosCalc[15] := Round(( aDadosNF[5] / aValRat[2] ) * nTaxas, 2) //Taxas
							aDadosCalc[13] := Round(( aDadosNF[5] / aValRat[2] ) * nPedag, 2) //Pedágio
					EndCase
					
					aRatFUNF := GFERatDocCarga({GWH->GWH_FILIAL, GWH->GWH_CDTPDC, GWH->GWH_EMISDC, GWH->GWH_SERDC, GWH->GWH_NRDC}, {GWF->GWF_FILIAL, GWF->GWF_NRCALC}, s_CRIRAT,2)
					
					//Valor de Frete Rateado
					aDadosCalc[6] := aRatFUNF[1]
					aDadosCalc[16] += GWF->GWF_BASICM	// 16. Base ICMS	
					aDadosCalc[17] += GWF->GWF_PCICMS	// 17. % ICMS
					aDadosCalc[18] := aRatFUNF[3]		// 18. ICMS
					
					// GWF_TPTRIB				=> 1: Tributado, 2: Isento/Não-tributado, 3: Subs Tributária, 4: Diferido, 5: Reduzido, 6: Outros, 7: Presumido
					// 507 :: 19. Sub. Trib.	=> 1: Sim, 2: Não, 3: Isento, Operação dentro do estado
					If GWF->GWF_TPTRIB == '3'
						aDadosCalc[19] := '1'
						aDadosCalc[20] += GWF->GWF_BASICM	// 20. Base ICMS
						aDadosCalc[21] += GWF->GWF_PCICMS	// 21. % ICMS
						aDadosCalc[22] := aRatFUNF[3]		// 22. ICMS
							
						aDadosCalc[27] := 'Z23'				// 27. Direito Fiscal
						aDadosCalc[28] := 'ICM3'			// 28. Com Substituição Tributária
					Else
						aDadosCalc[19] := '2'
						aDadosCalc[27] := 'IC0'				// 27. Direito Fiscal
						aDadosCalc[28] := 'ICM1'			// 28. Sem Substituição Tributária
					EndIf
						
					aDadosCalc[23] := GWF->GWF_BASISS		// 20. Base ISS
					aDadosCalc[24] := GWF->GWF_PCISS		// 21. % ISS
					aDadosCalc[25] := aRatFUNF[2]			// 22. ISS
				EndIf
				aDadosCalc[29] := POSICIONE("GU7", 1, xFilial("GU7") + GWF->GWF_CIDORI, "GU7_CDUF")
			EndIf
			
		aValRat[1] := 0
		aValRat[2] := 0
		aValRat[3] := 0
		aValRat[4] := 0
			
		nFretPes := 0
		nFretVal := 0
		nTaxas := 0
		nPedag := 0
	EndIf
		
	GWH->(dbSkip())
	EndDo
	
	
	
	// ------------------------------------------------
	// 519 :: Total geral do arquivo
	// ------------------------------------------------	
	aDados519[1] += aDadosNF[10]		// 2. Valor total das notas fiscais      
	aDados519[2] += aDadosNF[3]       	// 3. Peso bruto total das notas fiscais 
	aDados519[3] += aDadosNF[2]       	// 4. Quantidade total de volumes        
Return

//--------------------------------------------------------------------
// DadosItens
// Registro 511 - Cria as informações dos Itens e preenche o array aItens
// Requer que a tabela GW8 esteja posicionada
//--------------------------------------------------------------------
Static Function DadosItens()
	Local cItem
	Local cDsUnit
	
	cItem := "511"												//  1. Identificador de Registro
	cItem += FormatCampo(GW8->GW8_QTDE,  6, 'N', 2)				//  2. Quantidade de Volumes
	If p_ERPINT == "1"
		GWB->(dbSetOrder(2))
		If GWB->(dbSeek((cAliasSQL)->GW1_FILIAL + (cAliasSQL)->GW1_CDTPDC + (cAliasSQL)->GW1_EMISDC + (cAliasSQL)->GW1_SERDC + (cAliasSQL)->GW1_NRDC))
			cDsUnit := POSICIONE("GUG",1, xFilial("GUG") + GWB->GWB_CDUNIT, "GUG_DSUNIT")
			cItem += FormatCampo(cDsUnit, 15)	        		//  3. Marca dos Volumes Transportados
		Else 
			cItem += FormatCampo("", 15)	        			
		EndIf
	Else
		cItem += FormatCampo((cAliasSQL)->GW1_DSESP	, 15)		//  3. Espécie de Acondicionamento do Item
	EndIf
	cItem += FormatCampo(GW8->GW8_ITEM			, 20)			//  4. Código do Item
	cItem += FormatCampo(GW8->GW8_DSITEM		, 50)			//  5. Descrição do Item
	cItem += FormatCampo(GW8->GW8_CFOP			,  4)			//  6. CFOP do Item
	cItem += FormatCampo(""						, 20)			//  7. Lote do Item
	cItem += FormatCampo(0						, 8, 'N')		//  8. Data de validade do Item
	cItem += FormatCampo(""						, 50)			//  9. Marca dos volumes Transportados
	cItem += FormatCampo(""						, 50)			// 10. Numeração dos volumes transportados
	cItem += FormatCampo(""						, 50)			// 11. Númeração dos lacres
	cItem += FormatCampo(""						, 20)			// 12. Identificação dopedido do cliente
	cItem += FormatCampo(""						, 22)			// 13. (Filler)
	
	aADD(aItens, cItem)
Return


//--------------------------------------------------------------------
// CondFrete
// Retorna a condiçlão de frete (C: CIF ou F: FOB)
// GW1_TPFRET => 1=CIF; 2=CIF Redesp.; 3=FOB; 4=FOB Redesp.; 5=Consignado; 6=Consig. Redesp.
//--------------------------------------------------------------------
Static Function CondFrete()
	If (cAliasSQL)->GW1_TPFRET == "1" .OR. (cAliasSQL)->GW1_TPFRET == "2"
		Return ("C")
	EndIf

	If (cAliasSQL)->GW1_TPFRET == "3" .OR. (cAliasSQL)->GW1_TPFRET == "4"
		Return ("F")
	EndIf
	
	AddWarning("505 :: Tipo de Frete inválido, condição de frete ficará em branco. Tipo de Frete: " + (cAliasSQL)->GW1_TPFRET)
Return(" ")


//--------------------------------------------------------------------
// NatuMercad
// Retorna a natureza da Mercadoria
//--------------------------------------------------------------------
Static Function NatuMercad()
	Local cRet
	If Empty((cAliasSQL)->GW1_USO)
		Return ""
	EndIf
	
	cRet := StrTokArr(Posicione("SX3", 2, "GW1_USO", "X3_CBOX"), ';')[val((cAliasSQL)->GW1_USO)]
	
	cRet := SubStr(cRet, 3)
Return(cRet)


// TipoDocFis
// Retorna o tipo do documento fiscal [0: Entrada, 1: Saída]
// GV5_SENTID => 0=Indiferente; 1=Entrada; 2=Saida; 3=Externo; 4=Interno
//--------------------------------------------------------------------
Static Function TipoDocFis()
	Local cSentido
	
	cSentido := Posicione("GV5", 1, xFilial("GV5") + (cAliasSQL)->GW1_CDTPDC, "GV5_SENTID")
	
	// Entrada
	If cSentido == "1"
		Return ("0")
	EndIf

	// Saída
	If cSentido == "2"
		Return ("1")
	EndIf

	AddWarning("505 :: Tipo do Documento de Carga inválido, tipo do documento fiscal ficará em branco. Tipo Doc. Carga: " + (cAliasSQL)->GW1_CDTPDC)
Return (" ")


//--------------------------------------------------------------------
// PaisBacen
// Retorna o código do país de acordo com a tabela do Banco Central (Bacen)
//--------------------------------------------------------------------
Static Function PaisBacen(cCdPais)
	If cCdPais == "105"
		Return ("1058")
	EndIf
Return(cCdPais)


//--------------------------------------------------------------------
// UFEmit
// UF do Emitente
//--------------------------------------------------------------------
Static Function UFEmit(cCdEmit)
	Local cCid
	
	cCid  := Posicione("GU3", 1, xFilial("GU3") + cCdEmit, "GU3_NRCID")
	cUF	  := Posicione("GU7", 1, xFilial("GU7") + cCid   , "GU7_CDUF")
	
Return(cUF)


//--------------------------------------------------------------------
// TipoIdent
// Retorna o tipo de identificação do Emitente
// 1: CNPJ, 2: CPF
//--------------------------------------------------------------------
Static Function TipoIdent(cNatureza)
	If cNatureza == "F"
		Return ("2")
	EndIf
Return("1")

//--------------------------------------------------------------------
// AddWarning
//--------------------------------------------------------------------
Static Function AddWarning(cMsg, nIdent)
	GFELog110:AddDebug("** " + cMsg, nIdent)
Return


//--------------------------------------------------------------------
// AddError
//--------------------------------------------------------------------
Static Function AddError(cMsg, nIdent)
	Default nIdent := 2
	
	cErrosResult += "   ** " + cMsg + CHR(13) + CHR(10)
	
	GFELog110:Add("** " + cMsg, nIdent)
Return


//--------------------------------------------------------------------
// CheckErros
//--------------------------------------------------------------------
Static Function CheckErros()
	If Empty(cErrosResult)
		dbSelectArea("GW1")
		dbSetOrder(1)
		If dbSeek((cAliasSQL)->GWU_FILIAL + (cAliasSQL)->GWU_CDTPDC + (cAliasSQL)->GWU_EMISDC + (cAliasSQL)->GWU_SERDC + (cAliasSQL)->GWU_NRDC)
			RecLock("GW1",.F.)
				GW1->GW1_ENVEDI := "1"
			MsUnLock("GW1")	
		Else
			AddError("Documento de Carga não encontrado. Filial: " + (cAliasSQL)->GWU_FILIAL + ", Tipo Doc: " + (cAliasSQL)->GWU_CDTPDC + ", Emissor: " + (cAliasSQL)->GWU_EMISDC + ", Série: " + (cAliasSQL)->GWU_SERDC + ", Número: " + (cAliasSQL)->GWU_NRDC)
		EndIf
	Else
		GFEResult:AddErro("> Filial: " + AllTrim((cAliasSQL)->GWU_FILIAL) + ", Tipo Doc: " + AllTrim((cAliasSQL)->GWU_CDTPDC) + ", Emissor: " + AllTrim((cAliasSQL)->GWU_EMISDC) + ", Série: " + AllTrim((cAliasSQL)->GWU_SERDC) + ", Número: " + AllTrim((cAliasSQL)->GWU_NRDC))
		GFEResult:AddErro(cErrosResult)
	EndIf
Return


//--------------------------------------------------------------------
// BuscaSQL
// Realiza a busca dos documentos de carga de acordo com os parâmetros
//--------------------------------------------------------------------
Static Function BuscaSQL()
	Local cQuery    := ""
	Local aCpPE     := {}
	Local aRetQuery := {}
	
	// GW1 > Filial
	// GW1 > Série
	// GW1 > Número
	// GW1 > Data Saída
	// GW1 > Data Emissão
	// GW1 > GWU > Transportador
	// GW1 > GWU > GU3 > Grupo Emitente
	// GW1 > Romaneio	
	
	// Início Ponto de Entrada
	If lPEB11011
		aCpPE := ExecBlock("GFE11011",.f.,.f.)
		If ValType(aCpPE) == "A" .And. !Empty(aCpPE)
			aRetQuery := aCpPE
		EndIf
	EndIf
	
	cQuery :=        "SELECT GWU.GWU_FILIAL,"
	cQuery +=              " GWU.GWU_CDTPDC,"
	cQuery +=              " GWU.GWU_EMISDC,"
	cQuery +=              " GWU.GWU_SERDC,"
	cQuery +=              " GWU.GWU_NRDC,"
	cQuery +=              " GWU.GWU_CDTRP,"
	cQuery +=              " GWU.GWU_CDTRP,"
	cQuery +=              " GWU.GWU_SEQ,"
	cQuery +=              " GWU.GWU_NRCIDD,"
	cQuery +=              " GWU.GWU_DTENT,"
	cQuery +=              " GWU.GWU_HRENT,"
	cQuery +=              " GWU.GWU_DTPENT,"
	cQuery +=              " GWU.GWU_HRPENT,"
	cQuery +=              " GW1.GW1_NRREG,"
	cQuery +=              " GW1.GW1_CDREM,"
	cQuery +=              " GW1.GW1_DANFE,"
	cQuery +=              " GU3.GU3_MODAL,"
	cQuery +=              " GW1.GW1_CDTPDC,"
	cQuery +=              " GW1.GW1_FILIAL,"
	cQuery +=              " GW1.GW1_NRROM,"
	cQuery +=              " GW1.GW1_TPFRET,"
	cQuery +=              " GW1.GW1_EMISDC,"
	cQuery +=              " GW1.GW1_ENTNRC,"
	cQuery +=              " GW1.GW1_CDDEST,"
	cQuery +=              " GW1.GW1_USO,"
	cQuery +=              " GW1.GW1_ICMSDC,"
	cQuery +=              " GW1.GW1_DTEMIS,"
	cQuery +=              " GW1.GW1_DSESP,"
	cQuery +=              " GW1.GW1_QTVOL,"
	cQuery +=              " GW1.GW1_ENTCEP,"
	cQuery +=              " GW1.GW1_ENTBAI,"
	cQuery +=              " GW1.GW1_ENTEND,"
	cQuery +=              " GW1.GW1_SERDC,"
	cQuery +=              " GW1.GW1_NRDC,"
	cQuery +=              " GW1.GW1_ENVEDI,"
	cQuery +=              " GW1.GW1_SIT,"
	cQuery +=              " GW1.R_E_C_N_O_ RECNOGW1"
	cQuery +=        " FROM "+RetSQLName("GWU")+" GWU"	
	cQuery +=       " INNER JOIN "+RetSQLName("GW1")+" GW1"
	cQuery +=          " ON GW1.GW1_FILIAL = GWU.GWU_FILIAL"
	cQuery +=         " AND GW1.GW1_CDTPDC = GWU.GWU_CDTPDC"
	cQuery +=         " AND GW1.GW1_EMISDC = GWU.GWU_EMISDC"
	cQuery +=         " AND GW1.GW1_SERDC = GWU.GWU_SERDC"
	cQuery +=         " AND GW1.GW1_NRDC = GWU.GWU_NRDC"
	// Faixa por data de saída
	If nEnvSemDt == 2
		If !Empty(dDtSaiDe)
			cQuery += " AND GW1.GW1_DTSAI >= '"+DToS(dDtSaiDe)+"'"
		EndIf
		If !Empty(dDtSaiAte)
			cQuery += " AND GW1.GW1_DTSAI <= '"+DToS(dDtSaiAte)+"'"
		EndIf
	EndIf
	// Faixa por data de emissão
	If !Empty(dDtEmisDe)
		cQuery +=     " AND GW1.GW1_DTEMIS >= '"+DToS(dDtEmisDe)+"'"
	EndIf
	If !Empty(dDtEmisAte)
		cQuery +=     " AND GW1.GW1_DTEMIS <= '"+DToS(dDtEmisAte)+"'"
	EndIf
	// Documentos que não estejam bloqueados
	cQuery +=         " AND GW1.GW1_SIT <> '2'"
	 // Reenvia documentos
	If nReenvDoc == 2
		cQuery +=     " AND GW1.GW1_ENVEDI = '2'"
	EndIf
	// Somente embarcados
	If nEmbarcado == 1
		cQuery +=     " AND GW1.GW1_NRROM <> ' '"
	EndIf
	// Faixa de Romaneios
	If !Empty(cRomDe)
		cQuery +=     " AND GW1.GW1_NRROM >= '"+AllTrim(cRomDe)+"'"
	EndIf
	If !Empty(cRomAte)
		cQuery +=     " AND GW1.GW1_NRROM <= '"+AllTrim(cRomAte)+"'"
	EndIf
	cQuery +=         " AND GW1.D_E_L_E_T_ = ' '"	
	cQuery +=       " INNER JOIN "+RetSQLName("GV5")+" GV5"
	cQuery +=          " ON GV5.GV5_FILIAL = '"+xFilial("GV5")+"'"
	cQuery +=         " AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC"
	cQuery +=         " AND GV5.GV5_EDI <> '2'"
	cQuery +=         " AND GV5.D_E_L_E_T_ = ' '" 

	cQuery +=        "INNER JOIN "+RetSQLName("GU3")+" GU3"
	cQuery +=          " ON GU3.GU3_FILIAL = '"+xFilial("GU3")+"'"
	cQuery +=         " AND GU3.GU3_CDEMIT = GWU.GWU_CDTRP"
	
	If !Empty(cGrpEmit)
		cQuery +=     " AND GU3.GU3_CDGRED = '" + cGrpEmit + "'"
	EndIf
	cQuery +=         " AND GU3.D_E_L_E_T_ = ' '"

	// Ponto de Entrada
	If !Empty(aRetQuery)
		If !Empty(aRetQuery[1])
			cQuery += aRetQuery[1] // Caracter - Irá retornar comandos JOIN para serem adicionados ao comando SQL original para referenciar a tabela GWU.
		EndIf
	EndIf
	
	cQuery +=       " WHERE GWU.D_E_L_E_T_ = ' '"
	// Faixa por Filial
	If !Empty(cFilialDe)
		cQuery +=     " AND GWU.GWU_FILIAL >= '"+AllTrim(cFilialDe)+ "'"
	EndIf

	If !Empty(cFilialAte)
		cQuery +=     " AND GWU.GWU_FILIAL <= '"+AllTrim(cFilialAte)+"'"
	EndIf
	// Faixa por Serie
	If !Empty(cSerieDe)
		cQuery +=     " AND GWU.GWU_SERDC >= '"+cSerieDe+"'"
	EndIf
	If !Empty(cSerieAte)
		cQuery +=     " AND GWU.GWU_SERDC <= '"+cSerieAte+"'"
	EndIf
	// Faixa Documento de Carga
	If !Empty(cNrDocDe)
		cQuery +=     " AND GWU.GWU_NRDC >= '"+AllTrim(cNrDocDe)+"'"
	EndIf
	If !Empty(cNrDocAte)
		cQuery +=     " AND GWU.GWU_NRDC <= '"+AllTrim(cNrDocAte)+"'"
	EndIf
	// Faixa Transportador
	If Empty(cGrpEmit)
		If !Empty(cTranspDe)
			cQuery += " AND GWU.GWU_CDTRP >= '"+AllTrim(cTranspDe)+"'"
		EndIf
		If !Empty(cTranspAte)
			cQuery += " AND GWU.GWU_CDTRP <= '"+AllTrim(cTranspAte)+"'"
		EndIf
	EndIf
	cQuery += " AND (GV5.GV5_EDI = '1' AND GWU.GWU_PAGAR = '1' OR GV5.GV5_EDI = '3' AND GWU.GWU_PAGAR IN ('1','2'))"
	
	// Ponto de Entrada
	If !Empty(aRetQuery)
		If !Empty(aRetQuery[2])
			cQuery += aRetQuery[2] // Caracter - Irá retornar comandos SQL que serão adicionadas a clausula WHERE do comando SQL original.
		EndIf
	EndIf
	
	cQuery +=       " ORDER BY GWU.GWU_CDTRP,"
	cQuery +=                " GWU.GWU_FILIAL,"
	cQuery +=                " GWU_EMISDC,"
	cQuery +=                " GW1.GW1_CDDEST,"
	cQuery +=                " GW1.GW1_ENTNRC,"
	cQuery +=                " GWU_CDTPDC,"
	cQuery +=                " GWU.GWU_SERDC,"
	cQuery +=                " GWU.GWU_NRDC"
	
	GFELog110:AddDebug("Query SQL ------------------------------------- ")
	GFELog110:AddDebug(cQuery)
	GFELog110:AddDebug("----------------------------------------------- ")
	
	cAliasSQL := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSQL, .F., .T.)
Return Nil
//--------------------------------------------------------------------
// SalvarEDI
// Salva os dados do arquivo acumulados em aLinhas
//--------------------------------------------------------------------
Static Function SalvarEDI(cTransp)
	Local nI
	Local cFilename
	Local cFile
	Local nHdl

	If oProcess != Nil
		oProcess:incRegua2("Salvando arquivo...")
	EndIf
	
	Reg519()
	
	If Rat("\",Alltrim(cDiretorio)) > Rat("/",Alltrim(cDiretorio))
		If !(Substr(cDiretorio, Len(cDiretorio), 1) == "\")
			cDiretorio += "\"
		EndIf
	Else
		If !(Substr(cDiretorio, Len(cDiretorio), 1) == "/")
			cDiretorio += "/"
		EndIf
	EndIf
		
	cFilename := cFileTemplate
	cFilename := AllTrim(StrTran(cFilename, "<TRANSP>", AllTrim(cTransp)))
	cFilename := AllTrim(StrTran(cFilename, "<DATA>", AllTrim(GFENOW())))
	cFile     := cDiretorio + cFilename
	
	nHdl := fCreate(cFile)
	
	If nHdl == -1
		AddError("Arquivo não pode ser criado. " + AllTrim(Str(Ferror())))
		GFELog110:AddDebug("Arquivo não pode ser criado. (" + cFile + ")",1)
		fClose(nHdl)
		Return .F.
	EndIf

	For nI := 1 To Len(aLinhas)
		fWrite(nHdl, aLinhas[nI], Len(aLinhas[nI]))
		fWrite(nHdl, CHR(13) + CHR(10), Len(CHR(13) + CHR(10)))
	Next	
	
	fClose(nHdl)
	
	GFELog110:Add("Arquivo EDI criado: " + cFile)
	GFEResult:Add("ARQUIVO EDI: " + cFile)
	
	// Envia um e-mail com o arquivo criado para a transportadora
	If cEnvEmail == 1
		SendNotFis(cTransp,cFilename)
	EndIf
	
	// Início Ponto de Entrada
	If ExistBlock("GFEA1103")
		ExecBlock("GFEA1103",.F.,.F.,{cFile,cTransp})
	EndIf
	// Fim Ponto de Entrada	
	
	aLinhas := {}
Return


//--------------------------------------------------------------------
// FormatCampo
// Formata o campo da linha, preenchendo com espaços ou zeros
//
// cTipo:
//		C  	: Caracter
//		N  	: Numérico
//		D	: Data (DDMMAA ou DDMMAAAA, depende do tamanho)
//		H	: Hora
//--------------------------------------------------------------------
Static Function FormatCampo(uValor, nTamanho, cTipo, nDec, cAlign)
	Local cPadChar := ' '
	Local cValor := uValor
	Default nTamanho := 0
	Default cAlign 	:= 'L'
	Default cTipo 	:= 'C'
	Default nDec 	:= 0
	
	If cTipo == 'N'
		nTamanho := nTamanho + nDec
		cPadChar := '0'
		cAlign   := 'R'
		
		If ValType(uValor) == 'N'
			uValor := NoRound(uValor, nDec)
		EndIf
		
		cValor := AllTrim(Transform(uValor, Replicate("9", nTamanho) + "." + Replicate("9", nDec)))
		cValor := StrTran(cValor, ',', '')
		cValor := StrTran(cValor, '.', '')
	ElseIf cTipo == 'H'
		cValor := StrTran(cValor, ':', '')
		cValor := Substring(cValor, 1, nTamanho)
	ElseIf cTipo == 'D'
		If !Empty(uValor)
			cValor := DTOS(uValor)
		Else
			cValor := "00000000"
		EndIf
		
		If nTamanho = 4
			cValor := Substring(cValor,7,2) + Substring(cValor,5,2)
		EndIf
		
		If nTamanho = 6
			cValor := Substring(cValor,7,2) + Substring(cValor,5,2) + Substring(cValor,3,2)
		EndIf
		
		If nTamanho = 8
			cValor := Substring(cValor,7,2) + Substring(cValor,5,2) + Substring(cValor,1,4)
		EndIf
	EndIf
	
	// Remove espaços e converte para maiúscula
	cValor := AllTrim(Upper(cValor))
	
	// Preenche com espaços ou zeros a direita/esquerda
	If nTamanho > 0
		If cAlign == 'L'
			cValor := PadR(cValor, nTamanho, cPadChar)
		Else
			cValor := PadL(cValor, nTamanho, cPadChar)
		EndIf
	EndIf

Return (cValor)

//--------------------------------------------------------------------
/*/{Protheus.doc} SendNotFis()
Efetua o envio de um e-mail com o arquivo gerado para a transportadora.

@author  Guilherme A. Metzger
@since   15/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SendNotFis(cTransp,cFilename)
Local aAreaGU3  := GU3->(GetArea())
Local aRetEmail := {}
Local cNome     := ""
Local cEmail    := ""

	If oProcess != Nil
		oProcess:incRegua2("Enviando e-mail...")
	EndIf

	GU3->(DbSetOrder(1)) //GU3_FILIAL+GU3_CDEMIT)
	If GU3->(DbSeek(xFilial("GU3")+cTransp))
		// Busca o nome e o e-mail do transportador
		cNome  := GU3->GU3_NMEMIT
		cEmail := GU3->GU3_EMAIL

		If Empty(cEmail)
			GFELog110:Add("** FALHA NO ENVIO DO E-MAIL: O transportador '"+AllTrim(cNome)+"' não possui um endereço de e-mail cadastrado.",1)
			GFEResult:AddErro(CRLF + "** FALHA NO ENVIO DO E-MAIL: O transportador '"+AllTrim(cNome)+"' não possui um endereço de e-mail cadastrado.",1)
			Return
		EndIf

		// Para ser enviado por e-mail, o arquivo deve estar gravado no RootPath
		Copy File &(cDiretorio + cFilename) To &("\"+cFilename)

		// Realiza o envio do e-mail
		aRetEmail := GFEMail(cEmail,"EDI NOTFIS 5.0","Segue em anexo a este e-mail o arquivo EDI com as informações das notas fiscais.",.F.,{"\"+cFilename})

		If aRetEmail[1]
			GFELog110:Add("** O arquivo foi enviado com sucesso para o e-mail '"+AllTrim(cEmail)+"' do transportador '"+AllTrim(cNome)+"'.",1)
		Else
			GFELog110:Add("** FALHA NO ENVIO DO E-MAIL: Não foi possível enviar o arquivo para o e-mail '"+AllTrim(cEmail)+"' do transportador '"+AllTrim(cNome)+"'." + CRLF + aRetEmail[2],1)
			GFEResult:AddErro(CRLF + "** FALHA NO ENVIO DO E-MAIL: Não foi possível enviar o arquivo para o e-mail '"+AllTrim(cEmail)+"' do transportador '"+AllTrim(cNome)+"'." + CRLF + aRetEmail[2],1)
		EndIf

		// Remove o arquivo criado anteriormente no RootPath
		FErase("\"+cFilename)
	EndIf

RestArea(aAreaGU3)
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} SchedDef()

Função chamada na execução do schedule.

/*/
//-------------------------------------------------------------------

Static Function SchedDef()
	Local aParam
	Local aOrd := {}
	aParam := {;
				"P"                                ,;  // Tipo: R para relatorio P para processo
				"GFEA110B"						   ,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
				"GW1"                              ,;  // Alias
				aOrd                               ,;  // Array de ordens
			  }

Return aParam
