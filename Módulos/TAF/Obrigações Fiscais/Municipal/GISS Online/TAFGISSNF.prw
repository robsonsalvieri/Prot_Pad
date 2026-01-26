#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFGISSNF

Esta rotina tem como objetivo a geração dos documentos fiscais de serviço da
GISSONLINE

@Param
 aWizard - Informações da Wizard
 
@Author francisco.nunes
@Since 01/02/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFGISSNF(aWizard, aIndLay, lCanBulk, cTBulk, oBulk, oTT, cAliasTT)

	Local cMesRefer := Substr(aWizard[1][3],1,2)  // Mês Referência
	Local cAnoRefer := Iif(ValType(aWizard[1][4])=="N",LTRIM(STR(aWizard[1][4])),AllTrim(aWizard[1][4]))  // Ano Referência

	Local cDtIniRef := CtoD("01/"+cMesRefer+"/"+cAnoRefer)
	Local cDtFimRef := Lastday(stod(cAnoRefer+cMesRefer+'01'),0)

	Local cIndicador as char
	Local cLayout    as char
	Local cDtEmissNF as char
	Local cDocNFInic as char
	Local cDocSerie  as char
	Local cDocNFFin  as char
	Local cTpDOCNF   as char
	Local nValDOCNF  as Numeric
	Local nBaseCalc  as Numeric
	Local cCodAtivid as char
	Local cPrToEstab as char
	Local cLocalPres as char
	Local cRazaoSoc  as char
	Local cCNPJCPF   as char
	Local cTipoCadas as char
	Local cInscMunic as char
	Local cInscMunDV as char
	Local cInscEstad as char
	Local cTipoLog   as char
	Local cTituloLog as char
	Local cLogradour as char
	Local cCompLogr  as char
	Local cNumLograd as char
	Local cCEP       as char
	Local cBairro    as char
	Local cEstado    as char
	Local cCidade    as char
	Local cPais      as char
	Local cObservac  as char
	Local cPlanoCont as char
	Local cObra    as char
	Local cIcEnquad  as char
	Local cPlaConPai as char
	Local cRecolImp  as char
	Local nValAliq   as Numeric
	Local cIsentoIns as char
	Local cPresSimpl as char
	Local cMunEstab  as char
	Local cIndOper   as char
	Local lImposto	 as Logical
	Local nValIsent  as Numeric 
	Local nValOutr   as Numeric 
	Local cCodTribut as char	
	Local cMes		 as char
	Local cAno		 as char

	Local aIndMov	   as array
	Local aReg      as array
	Local cAliasDoc as char
	Local cAliasImp as char	
	Local cAliasRec as char
	Local lNovObra	as logical
	Local nAuxCodAti as Numeric

	Default aIndLay  := {}
	Default lCanBulk := .F.
	Default cTBulk 	 := ''
	Default oBulk 	 := Nil
	Default oTT 	 := Nil
	Default cAliasTT := ''

	cAliasImp := GetNextAlias()
	cIndicador := ""
	cLayout    := ""
	cDtEmissNF := ""
	cDocNFInic := ""
	cDocSerie  := ""
	cDocNFFin  := ""
	cTpDOCNF   := ""
	nValDOCNF  := 0
	nBaseCalc  := 0
	cCodAtivid := ""
	cPrToEstab := ""
	cLocalPres := ""
	cRazaoSoc  := ""
	cCNPJCPF   := ""
	cTipoCadas := ""
	cInscMunic := ""
	cInscMunDV := ""
	cInscEstad := ""
	cTipoLog   := ""
	cTituloLog := ""
	cLogradour := ""
	cCompLogr  := ""
	cNumLograd := ""
	cCEP       := ""
	cBairro    := ""
	cEstado    := ""
	cCidade    := ""
	cPais      := ""
	cObservac  := ""
	cPlanoCont := ""
	cObra    := ""
	cIcEnquad  := ""
	cPlaConPai := ""
	cRecolImp  := ""
	nValAliq   := 0
	cIsentoIns := ""
	cPresSimpl := ""
	cIndOper   := ""
	
	nValIsent  := 0 
	nValOutr   := 0
	cCodTribut := ""
	lNovObra   := .F.
	nAuxCodAti := 0 
	aReg       := {}
	
	Begin Sequence
		cAliasDoc := TAFSQLServ(cDtIniRef, cDtFimRef)
		
		cMunEstab  := Posicione('SM0', 1, SM0->M0_CODIGO + xFilial("C20"), "M0_CODMUN")
			
		If ( !Empty(cMunEstab) .And. len(cMunEstab) > 5)
		
			cMunEstab := Substr(cMunEstab, 3, 5)
		
		EndIf

		DbSelectArea("C21")
		
		If TAFColumnPos( "T9C_INDTER" )
			lNovObra := .T.
			DbSelectArea("T9C")
		Else
			DbSelectArea("C92")
		Endif

		//************************************************************************
		// Busca serviços com documento
		//************************************************************************		
		While (cAliasDoc)->(!Eof())
		
			//Busca os Impostos do Documento 01 - ISS / 16 - ISS Retido
			cAliasImp := RetImptDoc((cAliasDoc)->DC_CHVNF)
			
			//Valida se encontrou algum registro na query
			lImposto := Iif( !Empty( AllTrim( (cAliasImp)->DC_TRIBUT ) ) , .T., .F. ) 
			
			nBaseCalc  := 0  //Valor da Base
			nValAliq   := 0  //Valor da Alíquota			
			nValIsent  := 0  //Valor de Isentas
			nValOutr   := 0  //Valor de Outros
			cCodTribut := "" //Código do Tributo 01 ou 16
			
			If (lImposto)
				nBaseCalc  := (cAliasImp)->DC_VLBASE //Valor da Base
				nValAliq   := (cAliasImp)->DC_VLALIQ //Valor da Alíquota			
				nValIsent  := (cAliasImp)->DC_VLISEN //Valor de Isentas
				nValOutr   := (cAliasImp)->DC_VLOUTR //Valor de Outros
				cCodTribut := (cAliasImp)->DC_TRIBUT //Código do Tributo 01 ou 16
			EndIf
			
			(cAliasImp)->(DbCloseArea())
			
			//==========================================
			
			//Busca a descrição do registro C110 do SPED
			C21->(DbSetOrder(1))
			If C21->( MsSeek( xFilial( "C21" ) + (cAliasDoc)->DC_CHVNF ) )
				cObservac = C21->C21_DESCRI
			EndIf
			//==========================================

			//Busca o código da Obra na Tabela De Obra TAFA489		
			cObra := ""			

			If (cAliasDoc)->DC_INDOPE == "0" //Tomador

				If !Empty(AllTrim(SM0->M0_CGC)) .And. Len(AllTrim(SM0->M0_CGC)) != 11 .And. Len(AllTrim(SM0->M0_CGC)) != 14				
					cObra := AllTrim(SM0->M0_CGC)
				EndIf

			Else //Prestador
				if lNovObra
					/* ALTERADO O F3 DO C20_CODOBR DA C92 PARA T9C / OBS C20_CODOBR POSSUI TAMANHO 15 */
					T9C->(DbSetOrder(2)) //T9C_FILIAL+T9C_NRINSC
					If !Empty((cAliasDoc)->DC_CODOBRA) .And. T9C->(MsSeek(xFilial("T9C") + AllTrim((cAliasDoc)->DC_CODOBRA))) .And. T9C->T9C_TPINSC == "4" //CNO
						cObra := AllTrim(T9C->T9C_NRINSC)
					EndIf				
				else
					C92->(DbSetOrder(1)) //C92_FILIAL+C92_ID+C92_VERSAO
					If !Empty( AllTrim((cAliasDoc)->DC_CODOBRA) ) .And. C92->( MsSeek( xFilial( "C92" ) + AllTrim((cAliasDoc)->DC_CODOBRA) ) ) .And. C92->C92_TPINSC == "4" //CNO
						cObra := AllTrim(C92->C92_NRINSC)			
					EndIf				
				endif
			Endif

			//==========================================		
			
			cInscMunic := Iif(Upper((cAliasDoc)->PT_IM) == "ISENTO", " ", (cAliasDoc)->PT_IM)
			//Alimenta as variáveis de geração do arquivo	
			cDtEmissNF := Substr( (cAliasDoc)->DC_DTDOC, 7, 2) + "/" + Substr( (cAliasDoc)->DC_DTDOC, 5, 2) + "/" + Substr( (cAliasDoc)->DC_DTDOC, 1, 4)
			cDocNFInic := (cAliasDoc)->DC_NUMDOC
			cDocSerie  := (cAliasDoc)->DC_SERIE
			cDocNFFin  := (cAliasDoc)->DC_NUMDOC
			nValDOCNF  := (cAliasDoc)->DC_VLDOC
			cCodAtivid := Iif ( Empty( (cAliasDoc)->DC_NFSRVMUN), (cAliasDoc)->DC_SRVMUN, (cAliasDoc)->DC_NFSRVMUN)
			cPrToEstab := Iif(cMunEstab == (cAliasDoc)->PT_CODMUN, "S", "N")
			cLocalPres := Iif ( cMunEstab == (cAliasDoc)->DC_LOCPRE, "D", "F")
			cRazaoSoc  := (cAliasDoc)->PT_NOME
			cCNPJCPF   := Iif ( !Empty((cAliasDoc)->PT_CNPJ), (cAliasDoc)->PT_CNPJ, (cAliasDoc)->PT_CPF ) 
			cTipoCadas := (cAliasDoc)->PT_TPPES
			cInscMunDV := Iif(At("-",cInscMunic) > 0, SUBSTR(cInscMunic,AT("-", cInscMunic) + 1, Len(cInscMunic)), Iif(Len(cInscMunic)>10, SUBSTR (cInscMunic,11,Len(cInscMunic))," ")  )
			cInscMunic := Iif(At("-",cInscMunic) > 0, SUBSTR(cInscMunic,1, AT("-", cInscMunic) - 1), SUBSTR(cInscMunic,1,10) )
			cInscEstad := StrTran( StrTran( StrTran( (cAliasDoc)->PT_IE, ".", ""), "-", ""), "/", "")
			cTipoLog   := Iif ( len((cAliasDoc)->PT_DESLGD) > 5, (cAliasDoc)->PT_CESLGD, (cAliasDoc)->PT_DESLGD )
			cTituloLog := ""
			cLogradour := (cAliasDoc)->PT_END
			cCompLogr  := (cAliasDoc)->PT_COMPL
			cNumLograd := (cAliasDoc)->PT_NUM
			cCEP       := (cAliasDoc)->PT_CEP
			cBairro    := (cAliasDoc)->PT_BAIRRO
			cEstado    := Iif( (cAliasDoc)->PT_PAIS != "BR", "", (cAliasDoc)->PT_UF)
			cCidade    := Iif( (cAliasDoc)->PT_PAIS != "BR", "", (cAliasDoc)->PT_MUNPIO)
			cPais      := (cAliasDoc)->PT_PAIS	
			cPlanoCont := (cAliasDoc)->DC_CTACTB
			cPlaConPai := (cAliasDoc)->DC_CTAPAI
			cIcEnquad  := (cAliasDoc)->PT_ENQSIM			
			cRecolImp  := ""
			cIsentoIns := Iif ( Empty( (cAliasDoc)->PT_IE ) .Or. Upper( (cAliasDoc)->PT_IE ) == "ISENTO", "S", "N")  
			cPresSimpl := Iif((cAliasDoc)->PT_SIMPLS == "1", "S", "N")
			//==============================================================			
			
			//Identifica o tipo do documento
			Do Case		
			
				//Se a situação da nota fiscal for cancelada (02, 03) – 2 (Cancelada)
				Case(cAliasDoc)->DC_SITUAC == "02" .Or. (cAliasDoc)->DC_SITUAC == "03"
					cTpDOCNF := "2"
					
				//Se existir o tributo de ISS_RET (Tipo Imp. 16) – 5 (Retida)
				Case lImposto .And. cCodTribut == "16"
					cTpDOCNF := "5"
					
				//Se a nota fiscal for entrada e não possuir ISS/ISS_RET - 1 (Não Retida)
				Case ((cAliasDoc)->DC_INDOPE == "0" .And. !lImposto )
					cTpDOCNF := "1"
					
				//Se o valor de isenta ou Outras do ISS/ISS_RET da NF for maior que 0 – 4 (Isenta)
				Case lImposto .And. nValIsent > 0 .Or. nValOutr > 0
					cTpDOCNF := "4"
				
				//Se for NF de saída e o valor do tributo de ISS (Tipo Imp. 01) da NF for maior que 0 – 1 (Tributada)
				Case ((cAliasDoc)->DC_INDOPE == "1" .And. lImposto .And. cCodTribut == "01" .And. (cAliasDoc)->DC_VLDOC > 0)
					cTpDOCNF := "1"
					
				//Se a nota fiscal for entrada e possuir o tributo ISS - 6 (Pagamento pelo prestador)
				Case (cAliasDoc)->DC_INDOPE == "0" .And. lImposto .And. cCodTribut == "01"
					cTpDOCNF := "6"
			
			EndCase
			//==========================================
			
			//Classifica o Indicador e Layout do registro
			aIndMov := RetIndMov((cAliasDoc)->DC_INDOPE, cPais, cTipoCadas, (cAliasDoc)->DC_VLABSU, (cAliasDoc)->DC_VLABMT, cObra, (cAliasDoc)->IT_SVRSPED)
			
			If (len(aIndMov) > 0)
				cIndicador := aIndMov[1][1]
				cLayout    := aIndMov[1][2]
			EndIf
			//==========================================
			
			//Verifico a quantidade de caracteres no campo C30_SRVMUN para impressão correta na posição 10 do arquivo TXT
			nAuxCodAti := len(Alltrim(cCodAtivid))

			if aScan( aIndLay , (cIndicador + '|' + cLayout) ) == 0
				aadd( aIndLay , (cIndicador + '|' + cLayout) )
			endif
			cMes := substr(dtos(ctod(cDtEmissNF)),5,2)
			cAno := substr(dtos(ctod(cDtEmissNF)),1,4)
			aadd(aReg,{	cIndicador,;												// Col01 Indicador de Registro	
						cLayout,;    												// Col02 Indicador do Tipo do Layout
						cDtEmissNF,;	 											// Col03 Data da Prestação do Serviço
						AllTrim(cDocNFInic),;		 								// Col04 Número da Nota Fiscal Inicial
						AllTrim(cDocSerie) ,;  						 				// Col05 Série da Nota Fiscal
						AllTrim(cDocNFFin),;		  								// Col06 Número da Nota Fiscal Final
						cTpDOCNF,;   												// Col07 Tipo da Nota Fiscal
						AllTrim(Str(nValDOCNF * 100)),;				 				// Col08 Valor da Nota Fiscal
						AllTrim(Str(nBaseCalc * 100)),;				 				// Col09 Base de Cálculo
						Padl(Lower(AllTrim(cCodAtivid)),nAuxCodAti,''),;			// Col10 Atividade ou Serviço prestado
						AllTrim(cPrToEstab),; 										// Col11 Prestador/Tomador estabelecido no município
						AllTrim(cLocalPres),;										// Col12 Local de prestação do serviço
						AllTrim(cRazaoSoc),; 										// Col13 Razão social do Prestador/Tomador
						AllTrim(cCNPJCPF),; 										// Col14 CNPJ/CPF
						cTipoCadas,; 												// Col15 Tipo de cadastro (Pessoa Física ou Pessoa Jurídica)
						AllTrim(cInscMunic),;										// Col16 Inscrição municipal
						AllTrim(cInscMunDV),;										// Col17 Dígito da inscrição municipal
						AllTrim(cInscEstad),;										// Col18 Inscrição estadual
						AllTrim(cTipoLog),;   										// Col19 Tipo do logradouro
						AllTrim(cTituloLog),; 										// Col20 Título do logradouro
						AllTrim(cLogradour),; 										// Col21 Logradouro
						AllTrim(cCompLogr),;  										// Col22 Complemento do logradouro
						AllTrim(cNumLograd),;										// Col23 Número do logradouro
						AllTrim(cCEP),;      										// Col24 CEP referente ao logradouro
						AllTrim(cBairro),;   										// Col25 Bairro referente ao logradouro
						AllTrim(cEstado),;    										// Col26 Estado (UF) referente ao logradouro
						AllTrim(cCidade),;    										// Col27 Cidade referente ao logradouro
						AllTrim(cPais),;      										// Col28 Sigla do país
						AllTrim(cObservac),;  										// Col29 Informações gerais sobre a empresa
						AllTrim(cPlanoCont),; 										// Col30 Código do item do plano de contas
						AllTrim(cObra),;											// Col31 Código da obra
						"R",;            											// Col32 Origem dos Dados (Valor Fixo 'R')
						AllTrim(cIcEnquad),;   						 				// Col33 Tabela de Enquadramento
						AllTrim(cPlaConPai),; 										// Col34 Código da conta mestre no primeiro grau de contas
						AllTrim(cRecolImp),;  										// Col35 Recolhe Imposto
						Iif(cPresSimpl == "S" .And. nValAliq>0, AllTrim(Strzero(nValAliq,6,3)), ""),;// Col36 Valor alíquota
						AllTrim(cIsentoIns),; 										// Col37 Isenção de Inscrição Estadual
						AllTrim(cPresSimpl),;       								// Col38 Prestador optante pelo simples nacional
						cMes,;													    // Col39 Mes
						cAno } )												    // Col40 Ano

			TafIncTT( @aReg, lCanBulk, @oBulk, @oTT, @cAliasTT )

			(cAliasDoc)->(DbSkip())
		EndDo
		(cAliasDoc)->(DbCloseArea())
		
		C21->(DbCloseArea())
		C92->(DbCloseArea())

		//************************************************************************
		// Busca serviços sem documento
		//************************************************************************		
		if TAFAlsInDic( "LEM",.F. )		
			
			cAliasRec := TAFRecibosServ(cDtIniRef, cDtFimRef)
			
			While (cAliasRec)->(!Eof())
			
				cAliasImp := TAFRecibISS((cAliasRec)->LEM_ID)
				
				If((cAliasImp)->T52_BASECA == 0)
				 	cTpDOCNF := '4' //isento
				ElseIf ((cAliasImp)->C3S_CODIGO == '16')
					cTpDOCNF := '5' //retido
				Else
					cTpDOCNF := '1' //tributado
				EndIf	
				
				nBaseCalc := (cAliasImp)->T52_BASECA
				nValAliq  := (cAliasImp)->T52_ALIQ
				
				cDtEmissNF := Substr( (cAliasRec)->LEM_DTEMIS, 7, 2) + "/" + Substr( (cAliasRec)->LEM_DTEMIS, 5, 2) + "/" + Substr( (cAliasRec)->LEM_DTEMIS, 1, 4)				
				cIndicador := "P"
				cLayout    := IIF((cAliasRec)->C08_SIGLA2 == 'BR', '2','3')				
				cDocNFInic := (cAliasRec)->LEM_NUMERO
				cDocSerie  := ""
				cDocNFFin  := (cAliasRec)->LEM_NUMERO
				nValDOCNF  := (cAliasRec)->LEM_VLBRUT
				cCodAtivid := (cAliasRec)->LEM_SRVMUN
				cRazaoSoc  := (cAliasRec)->C1H_NOME
				cPrToEstab := Iif(cMunEstab == (cAliasRec)->C07_CODIGO, "S", "N")
				cLocalPres := Iif ( cMunEstab == (cAliasRec)->LEM_CODLOC, "D", "F")
				cCNPJCPF   := Iif ( !Empty((cAliasRec)->C1H_CNPJ), (cAliasRec)->C1H_CNPJ, (cAliasRec)->C1H_CPF )				 
				cTipoCadas := (cAliasRec)->C1H_PPES
				cInscMunic := Iif(Upper((cAliasRec)->C1H_IM) == "ISENTO", " ", (cAliasRec)->C1H_IM)
				cInscMunDV := Iif(At("-",cInscMunic) > 0, SUBSTR(cInscMunic,AT("-", cInscMunic) + 1, Len(cInscMunic)), " " )
				cInscMunic := Iif(At("-",cInscMunic) > 0, SUBSTR(cInscMunic,1, AT("-", cInscMunic) - 1), cInscMunic )
				cInscEstad := (cAliasRec)->C1H_IE
				cTipoLog   := Iif ( len(AllTrim((cAliasRec)->C06_DESCRI)) > 5, (cAliasRec)->C06_CESOCI, (cAliasRec)->C06_DESCRI )
				cTituloLog := ""
				cLogradour := (cAliasRec)->C1H_END
				cCompLogr  := (cAliasRec)->C1H_COMPL
				cNumLograd := (cAliasRec)->C1H_NUM
				cCEP       := (cAliasRec)->C1H_CEP
				cBairro    := (cAliasRec)->C1H_BAIRRO
				cEstado    := Iif( (cAliasRec)->C08_SIGLA2 != "BR", "", (cAliasRec)->C09_UF)
				cCidade    := Iif( (cAliasRec)->C08_SIGLA2 != "BR", "", (cAliasRec)->C07_DESCRI)
				cPais      := (cAliasRec)->C08_SIGLA2
				cObservac  := ""	
				cObservac  := ""	
				cPlanoCont := ""
				cPlaConPai := ""
				cObra      := ""
				cIcEnquad  := ""			
				cRecolImp  := ""
				cIsentoIns := Iif ( Empty( (cAliasRec)->C1H_IE ) .Or. Upper( (cAliasRec)->C1H_IE ) == "ISENTO", "S", "N")  
				cPresSimpl := Iif((cAliasRec)->C1H_SIMPLS == "1", "S", "N")

				if aScan( aIndLay , (cIndicador + '|' + cLayout) ) == 0
					aadd( aIndLay , (cIndicador + '|' + cLayout) )
				endif
				cMes := substr(dtos(ctod(cDtEmissNF)),5,2)
				cAno := substr(dtos(ctod(cDtEmissNF)),1,4)
				aadd(aReg,{	cIndicador,;												//Col01 Indicador de Registro
							cLayout,;    												//Col02 Indicador do Tipo do Layout
							cDtEmissNF,;	 											//Col03 Data da Prestação do Serviço
							AllTrim(cDocNFInic),;		 								//Col04 Número da Nota Fiscal Inicial
							AllTrim(cDocSerie),;   										//Col05 Série da Nota Fiscal
							AllTrim(cDocNFFin),;		  								//Col06 Número da Nota Fiscal Final
							cTpDOCNF,;   												//Col07 Tipo da Nota Fiscal
							AllTrim(Str(nValDOCNF * 100)),;								//Col08 Valor da Nota Fiscal
							AllTrim(Str(nBaseCalc * 100)),;								//Col09 Base de Cálculo
							Padl(Lower(AllTrim(cCodAtivid)),nAuxCodAti,''),;			//Col10 Atividade ou Serviço prestado
							AllTrim(cPrToEstab),; 										//Col11 Prestador/Tomador estabelecido no município
							AllTrim(cLocalPres),; 										//Col12 Local de prestação do serviço
							AllTrim(cRazaoSoc),; 										//Col13 Razão social do Prestador/Tomador
							AllTrim(cCNPJCPF),; 										//Col14 CNPJ/CPF
							cTipoCadas,; 												//Col15 Tipo de cadastro (Pessoa Física ou Pessoa Jurídica)
							AllTrim(cInscMunic),;										//Col16 Inscrição municipal
							AllTrim(cInscMunDV),; 										//Col17 Dígito da inscrição municipal
							AllTrim(cInscEstad),;										//Col18 Inscrição estadual
							AllTrim(cTipoLog),;   										//Col19 Tipo do logradouro
							AllTrim(cTituloLog),; 										//Col20 Título do logradouro
							AllTrim(cLogradour),; 										//Col21 Logradouro
							AllTrim(cCompLogr),;  										//Col22 Complemento do logradouro
							AllTrim(cNumLograd),;										//Col23 Número do logradouro
							AllTrim(cCEP),;      										//Col24 CEP referente ao logradouro
							AllTrim(cBairro),;    										//Col25 Bairro referente ao logradouro
							AllTrim(cEstado),;    										//Col26 Estado (UF) referente ao logradouro
							AllTrim(cCidade),;    										//Col27 Cidade referente ao logradouro
							AllTrim(cPais),;      										//Col28 Sigla do país
							AllTrim(cObservac),;  										//Col29 Informações gerais sobre a empresa
							AllTrim(cPlanoCont),; 										//Col30 Código do item do plano de contas
							AllTrim(cObra),;   											//Col31 Código da obra
							"R",;            											//Col32 Origem dos Dados (Valor Fixo 'R')
							AllTrim(cIcEnquad),;   										//Col33 Tabela de Enquadramento
							AllTrim(cPlaConPai),; 										//Col34 Código da conta mestre no primeiro grau de contas
							AllTrim(cRecolImp),;  										//Col35 Recolhe Imposto
							Iif(cPresSimpl == "S" .And. nValAliq > 0, AllTrim(Strzero(nValAliq,6,3)), ""),;//Col36 Valor alíquota
							AllTrim(cIsentoIns),; 	    								//Col37 Isenção de Inscrição Estadual
							AllTrim(cPresSimpl),;       								//Col38 Prestador optante pelo simples nacional
							cMes,;														//Col39 Mes
							cAno } )													//Col40 Ano

				TafIncTT( @aReg, lCanBulk, @oBulk, @oTT, @cAliasTT )

				(cAliasImp)->(DbCloseArea())
				(cAliasRec)->(DbSkip())
			EndDo
			(cAliasRec)->(DbCloseArea())
			
		EndIf	
	 		
	Recover	
	
	End Sequence	
	
Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFSQLServ

Esta rotina tem como objetivo executar a consulta no banco de dados para 
retornar os documentos fiscais de serviço para GISSONLINE

@Param
 cDtIniRef - Data inicial do período
 cDtFimRef - Data final do período
 
@Author jean.espindola
@Since 01/02/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFSQLServ(cDtIniRef, cDtFimRef)

 Local cAliasDoc as char
 Local cJoin as char
 Local cCompC1H as char
 Local cCompC1L as char
 Local aInfoEUF as array

 aInfoEUF	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
 cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
 cCompC1L	:= Upper(AllTrim(FWModeAccess("C1L",1)+FWModeAccess("C1L",2)+FWModeAccess("C1L",3)))

 cJoin :=  + RetSqlName("C20") + " C20"
 cJoin += " INNER JOIN " + RetSqlName("C0U") + " C0U ON C0U.C0U_FILIAL = '" + xFilial("C0U") + "'"
 cJoin += " AND C0U.C0U_ID	 = C20.C20_TPDOC  AND C0U.C0U_CODIGO = '06' AND C0U.D_E_L_E_T_ = ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C02") + " C02 ON C02.C02_FILIAL = '" + xFilial("C02") + "'"
 cJoin += " AND C02.C02_ID = C20.C20_CODSIT AND C02.D_E_L_E_T_= ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C30") + " C30 ON C30.C30_FILIAL = C20.C20_FILIAL  AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.D_E_L_E_T_= ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C1L") + " C1L ON C1L.C1L_ID = C30.C30_CODITE AND C1L.C1L_SRVMUN <> ' ' "
 If cCompC1L=="EEE"
	cJoin += " AND C1L.C1L_FILIAL=C30.C30_FILIAL " 
 Else
	If cCompC1L == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoin += " AND SUBSTRING(C1L.C1L_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C30.C30_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
	ElseIf cCompC1L == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
		cJoin += " AND SUBSTRING(C1L.C1L_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C30.C30_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
	Else
		cJoin += " AND C1L.C1L_FILIAL = '" + xFilial("C1L") + "'"	
	endif
 Endif
 cJoin += " AND C1L.D_E_L_E_T_= ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR "
 If cCompC1H=="EEE"
	cJoin += " AND C1H.C1H_FILIAL=C20.C20_FILIAL " 
 Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoin += " AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
		cJoin += " AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
	Else
		cJoin += " AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"	
	endif
 Endif
 cJoin += " AND C1H.D_E_L_E_T_= ' ' "
 cJoin += " LEFT JOIN " + RetSqlName("C06") + " C06 ON C06.C06_FILIAL = '" + xFilial("C06") + "'"
 cJoin += " AND C06.C06_ID = C1H.C1H_TPLOGR AND C06.D_E_L_E_T_= ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C07") + " C07C1H ON C07C1H.C07_FILIAL = '" + xFilial("C07") + "'"  
 cJoin += " AND C07C1H.C07_ID = C1H.C1H_CODMUN AND C07C1H.D_E_L_E_T_= ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C07") + " C07C20 ON C07C20.C07_FILIAL = '" + xFilial("C07") + "'"  
 cJoin += " AND C07C20.C07_ID = C20.C20_CODLOC AND C07C20.D_E_L_E_T_= ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C08") + " C08 ON C08.C08_FILIAL = '" + xFilial("C08") + "'"   
 cJoin += " AND C08.C08_ID = C1H.C1H_CODPAI AND C08.D_E_L_E_T_= ' ' "
 cJoin += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "'"   
 cJoin += " AND C09.C09_ID = C1H.C1H_UF     AND C09.D_E_L_E_T_= ' ' "
 cJoin += " LEFT  JOIN " + RetSqlName("C1O") + " C1  ON C1.C1O_FILIAL  = '" + xFilial("C1O") + "'"  
 cJoin += " AND C1.C1O_ID = C30.C30_CTACTB AND C1.D_E_L_E_T_= ' ' "
 cJoin += " LEFT  JOIN "+ RetSqlName("C1O") + " C2  ON C2.C1O_FILIAL  = '" + xFilial("C1O") + "'" 
 cJoin += " AND C2.C1O_ID = C1.C1O_CTASUP  AND C2.D_E_L_E_T_= ' ' "
 cJoin += " LEFT  JOIN "+ RetSqlName("C0B") + " C0B ON C0B.C0B_FILIAL = '" + xFilial("C0B") + "'"
 cJoin += " AND C0B.C0B_ID = C1L.C1L_CODSER AND C0B.D_E_L_E_T_= ' ' "

 cJoin := "%" + cJoin + "%"

 cAliasDoc := GetNextAlias()

 BeginSql Alias cAliasDoc

		SELECT C20_FILIAL         DC_FILIAL,
			   C20_CHVNF	       DC_CHVNF,
			   C20_DTDOC	       DC_DTDOC,
			   C20_INDOPE	      DC_INDOPE,
	           C20_NUMDOC	      DC_NUMDOC,
	           C20_SERIE           DC_SERIE,
	           C20_TPDOC	       DC_TPDOC,
	           C20_VLDOC	 	   DC_VLDOC,
	           C07C20.C07_CODIGO  DC_LOCPRE,	                      
		       C20_IDOBR	     DC_CODOBRA,         
	           SUM(C20_VLABMT)    DC_VLABMT,
	           SUM(C20_VLABSU)    DC_VLABSU,	         
	           C1H_CODPAR	      PT_CODIGO,
	           C1H_NOME		        PT_NOME,
	           C1H_CNPJ	     	    PT_CNPJ,
	           C1H_CPF	     	     PT_CPF,
	           C1H_IE		 	      PT_IE,
	           C1H_IM		 	      PT_IM,
	           C1H_PPES      	   PT_TPPES,
	           C1H_TPLOGR    	  PT_TPLOGR,
	           C1H_END		 	     PT_END,
	           C1H_COMPL	       PT_COMPL,
	           C1H_NUM		         PT_NUM,
	           C1H_CEP		         PT_CEP,
	           C06_DESCRI	      PT_DESLGD,
	           C06_CESOCI	      PT_CESLGD,
	           C1H_BAIRRO	      PT_BAIRRO,
	           C09_UF		          PT_UF,
	           C07C1H.C07_DESCRI  PT_MUNPIO,
	           C07C1H.C07_CODIGO  PT_CODMUN,
	           C08_SIGLA2	        PT_PAIS,
	           C1L_SRVMUN	      DC_SRVMUN,
	           C30_SRVMUN	    DC_NFSRVMUN,	           
	           C02_CODIGO	      DC_SITUAC,
	           C1H_SIMPLS         PT_SIMPLS,
	           C1H_ENQSIM         PT_ENQSIM,
	           MAX(C1.C1O_CODIGO) DC_CTACTB,
	           MAX(C2.C1O_CODIGO) DC_CTAPAI,
	           C0B_CODIGO	     IT_SVRSPED

		FROM 
			%EXP:cJoin%	

		WHERE C20_FILIAL = %xFilial:C20%
		  AND C20.C20_DTDOC BETWEEN %Exp:cDtIniRef% AND %Exp:cDtFimRef%
		  AND C20.%NotDel%

		GROUP BY C20_FILIAL,
				 C20_CHVNF,
				 C20_DTDOC,
				 C20_INDOPE,
		         C20_NUMDOC,
		         C20_SERIE,
		         C20_TPDOC,
		         C20_VLDOC,
		         C07C20.C07_CODIGO,
		         C20_IDOBR,
		         C1H_CODPAR,
		         C1H_NOME,
		         C1H_CNPJ,
		         C1H_CPF,
		         C1H_IE,
		         C1H_IM,
			     C1H_PPES,
		         C1H_TPLOGR,
		         C1H_END,
		         C1H_COMPL,
		         C1H_NUM,
		         C1H_CEP,
		         C06_DESCRI,
		         C06_CESOCI,
		         C1H_BAIRRO,
		         C09_UF,
		         C07C1H.C07_DESCRI,
		         C07C1H.C07_CODIGO,
		         C08_SIGLA2,
		         C1L_SRVMUN,
		         C30_SRVMUN,
		         C02_CODIGO,
 	           	 C1H_SIMPLS,
	           	 C1H_ENQSIM,
	 	         C0B_CODIGO
		    ORDER BY C20_INDOPE, C20_DTDOC
	EndSql

	DbSelectArea(cAliasDoc)
	(cAliasDoc)->(DbGoTop())
Return cAliasDoc

//----------------------------------------------------------------------------
/*/{Protheus.doc} RetImptDoc

RetIndMov() - Retorna Impostos ISS/ISSRetid

@Author Jean Battista Grahl Espindola
@Since 07/02/2017
@Version 1.0
/*/
//----------------------------------------------------------------------------
static function RetImptDoc(cChaveDoc as Char)

Local cAliasDoc as char

 cAliasDoc := GetNextAlias()

 	BeginSql Alias cAliasDoc

 		SELECT 
 			C3S_CODIGO DC_TRIBUT,
 			C2F_BASE   DC_VLBASE,
	        C2F_ALIQ   DC_VLALIQ,
	        C2F_VLISEN DC_VLISEN,
	        C2F_VLOUTR DC_VLOUTR
 		
 		FROM %table:C2F% C2F		
	 		INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xFilial:C3S%   AND C3S.C3S_ID    = C2F.C2F_CODTRI AND C3S.C3S_CODIGO IN (%Exp:'01'%, %Exp:'16'%) AND C3S.%NotDel% //TIPO DE TRIBUTO ISS/ISS RETID (C3S)	
 		
 		WHERE C2F.C2F_FILIAL = %xFilial:C2F%
 		  AND C2F.C2F_CHVNF  = %Exp:cChaveDoc%
 		  AND C2F.%NotDel% 		
 		
		EndSql

	DbSelectArea(cAliasDoc)
	(cAliasDoc)->(DbGoTop())
Return cAliasDoc
//----------------------------------------------------------------------------

/*/{Protheus.doc} RetIndMov

RetIndMov() - Retorna os indicadores de movimentação (Registro e Tipo do Layout)

@Author Francisco Kennedy Nunes Pinheiro
@Since 03/02/2017
@Version 1.0
/*/
//----------------------------------------------------------------------------
static function RetIndMov(cIndOper as char, cPais as char, cTipoCadas as char,  nAbatSub as numeric, nAbatMat as numeric, cObra as char, cServSPED as char)

	Local aIndMov as array

	aIndMov :=	{}

	DbSelectArea("C1E")

	C1E->(DbSetOrder(3))
	C1E->( MsSeek( xFilial( "C1E" ) + cFilAnt + "1" ) )

	If AllTrim(C1E->C1E_SEGMEN) == "1" //1 - Instituições Financeiras (Bancos) (A1)
		AADD(aIndMov,{"A", "1"})
	EndIf

	If AllTrim(C1E->C1E_SEGMEN) == "2" //2 - Orgãos Públicos (D1)
		AADD(aIndMov,{"D", "1"})
	EndIf

	If AllTrim(C1E->C1E_SEGMEN) == "3" //3 - Portos (CODESP) (S1, S2, S3)

		Do Case
			// Serviço Prestado para Tomador Fora do País Serviço Prestado para Pessoa Física (S2)
			Case cIndOper == "1" .and. cPais != "BR"
				AADD(aIndMov,{"S", "2"})
				
			// Serviço Prestado para Pessoa Física (S1)
			Case cIndOper == "1" .and. cTipoCadas == "1"
				AADD(aIndMov,{"S", "1"})
				
			// Serviço Prestado para Pessoa Física (S3)
			Case cIndOper == "1" .and. cTipoCadas == "2"
				AADD(aIndMov,{"S", "3"})
			
		EndCase

	EndIf
	
	If AllTrim(C1E->C1E_SEGMEN) == "4" // 4 - Construção Civil - Empreiteiras
	
		Do Case
		
			// Serviço Prestado para Tomador Pessoa Física – Sem Obra (G1)
		   Case cIndOper == "1" .and. cTipoCadas == "1" .and. Empty(cObra)
		   		AADD(aIndMov,{"G", "1"})		   
		
			// Serviço Prestado para Tomador Pessoa Física – Sem Obra (G1)
		   Case cIndOper == "1" .and. cTipoCadas == "1" .and. Empty(cObra)
		   		AADD(aIndMov,{"G", "1"})
		   
		   // Serviço Prestado para Tomador Pessoa Jurídica – Sem Obra (G2)
		   Case cIndOper == "1" .and. cTipoCadas == "2" .and. Empty(cObra) 
		   		AADD(aIndMov,{"G", "2"})
		   		   		  
		   // Serviço Prestado para Tomador Pessoa Física – Com Obra (X4)
		   Case cIndOper == "1" .and. cTipoCadas == "1" .and. !Empty(cObra)
		   		AADD(aIndMov,{"X", "4"})
		   
		   // Serviço Prestado para Tomador Pessoa Jurídica – Com Obra (X5)
		   Case cIndOper == "1" .and. cTipoCadas == "2" .and. !Empty(cObra)
		   		AADD(aIndMov,{"X", "5"})	   
		  			
		EndCase	
				
	EndIf

	If Len(aIndMov) == 0
		Do Case
		   
		   //Abatimento de Sub-empreitada
		   Case cIndOper == "1" .And. nAbatSub > 0  
		   	  AADD(aIndMov,{"2", "2"})
		   
		   //Abatimento de Materiais	  
		   Case cIndOper == "1" .And. nAbatMat > 0  
		   	  AADD(aIndMov,{"1", "1"})
		   	  
		   // Serviço Tomado de Prestador Residente no País Com Nota Fiscal – Sem Obra (I3)
		   //Case cIndOper == "0" .and. cPais == "BR" .and. Substr(cServSPED,1,1) == "7" .and. Empty(cObra)
		   //	  AADD(aIndMov,{"I", "3"})	   
		   			   		   	 
		   // Serviço Prestado para Pessoa Física (C1)
		   Case cIndOper == "1" .and. cPais == "BR" .and. cTipoCadas == "1"
		      AADD(aIndMov,{"C", "1"})

		   // Serviço Prestado para Tomador Fora do País (C2)
		   Case cIndOper == "1" .and. cPais != "BR"
		      AADD(aIndMov,{"C", "2"})

		   // Serviço Prestado para Pessoa Jurídica (C3)
		   Case cIndOper == "1" .and. cPais == "BR" .and. cTipoCadas == "2"
		      AADD(aIndMov,{"C", "3"})
		      
		      // Serviço Tomado de Prestador Residente no País Com Nota Fiscal – Com Obra (H6)
		   Case cIndOper == "0" .and. cPais == "BR" .and. !Empty(cObra)
		   	  AADD(aIndMov,{"H", "6"})

		   // Serviço Tomado de Prestador Residente no País Com Nota Fiscal (T1)
		   Case cIndOper == "0" .and. cPais == "BR"
		      AADD(aIndMov,{"T", "1"})

		   // Serviço Tomado de Prestador Residente Fora do País Com Nota Fiscal (F4)
		   Case cIndOper == "0" .and. cPais != "BR"
		      AADD(aIndMov,{"F", "4"})	      
	       
		EndCase
	EndIf

Return( aIndMov )
//----------------------------------------------------------------------------

/*/{Protheus.doc} TAFRecibosServ

TAFRecibosServ() - Retorna os pagamentos de recibos.
@Param
 cDtIniRef - Data inicial
 cDtFimRef - Data final

@Return
cAliasQry - Alias da consulta

@Author Rafael Völtz
@Since 03/02/2017
@Version 1.0
/*/
//----------------------------------------------------------------------------
Function TAFRecibosServ(cDtIniRef, cDtFimRef)
 
 Local cAliasQry as char
 
 cAliasQry := GetNextAlias()
 
 BeginSql Alias cAliasQry
 	
 SELECT LEM_ID, 
 	   LEM_NUMERO,
       LEM_DTEMIS,
       LEM_VLBRUT,
       LEM_SRVMUN,
       C1H_PPES,
       C08_SIGLA2,
       C1H_CODPAR,
       C1H_NOME,
	   C1H_CNPJ,
	   C1H_CPF,
	   C1H_IE,
	   C1H_IM,
	   C1H_TPLOGR,
	   C1H_END,
	   C1H_COMPL,
	   C1H_NUM,
	   C1H_CEP,
	   C1H_SIMPLS,
	   C06_DESCRI,
	   C06_CESOCI,
	   C1H_BAIRRO,
	   C09_UF,
	   C07_DESCRI,
	   C07_CODIGO,	   
	   LEM_CODLOC	   
  FROM %table:LEM% LEM
  INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = LEM.LEM_FILIAL  AND C1H.C1H_ID	 = LEM.LEM_IDPART AND C1H.%NotDel%  //CADASTRO DE PARTICIPANTE (C1H)
  LEFT  JOIN %table:C06% C06 ON C06.C06_FILIAL = %xFilial:C06%   AND C06.C06_ID  = C1H.C1H_TPLOGR AND C06.%NotDel%  //TIPO DE LOGRADOURO DO PARTICIPANTE (C06)
  INNER JOIN %table:C07% C07 ON C07.C07_FILIAL = %xFilial:C07%   AND C07.C07_ID  = C1H.C1H_CODMUN AND C07.%NotDel%  //CADASTRO DE MUNICIPIOS (C07)
  INNER JOIN %table:C08% C08 ON C08.C08_FILIAL = %xFilial:C08%   AND C08.C08_ID  = C1H.C1H_CODPAI AND C08.%NotDel%  //CADASTRO DE PAISES (C08)
  INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xFilial:C09%   AND C09.C09_ID  = C1H.C1H_UF     AND C09.%NotDel%  //CADASTRO DE ESTADOS (C09)

  WHERE LEM.LEM_FILIAL = %xFilial:LEM% 
    AND LEM_DTEMIS BETWEEN %Exp:cDtIniRef% AND %Exp:cDtFimRef%
    AND LEM_NATTIT = %Exp: '0' % //a pagar
    AND LEM_TPRECF = %Exp: '3'%   //doc avulso
    AND LEM_SRVMUN IS NOT NULL AND LEM_SRVMUN <> ' '
    AND LEM.%NotDel% 
   
 EndSql

 DbSelectArea(cAliasQry)
 (cAliasQry)->(DbGoTop())
 
Return cAliasQry


//----------------------------------------------------------------------------

/*/{Protheus.doc} TAFRecibosServ

TAFRecibosServ() - Retorna os pagamentos de recibos.
@Param
 cDtIniRef - Data inicial
 cDtFimRef - Data final

@Return
cAliasQry - Alias da consulta

@Author Rafael Völtz
@Since 03/02/2017
@Version 1.0
/*/
//----------------------------------------------------------------------------
static function TAFRecibISS(cIdRec as char)
 
 Local cAliasQry as char
 
 cAliasQry := GetNextAlias()
 
 BeginSql Alias cAliasQry
 	
 	SELECT T52_BASECA,
	       T52_ALIQ,
	       T52_VLTRIB,
	       C3S_CODIGO 
	  FROM %table:T52% T52
	  INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = T52.T52_CODTRI AND C3S.%NotDel%
	  
	 WHERE T52.T52_FILIAL = %xFilial:T52%
	   AND T52.T52_ID 	  = %Exp: cIdRec %	   
	   AND C3S.C3S_CODIGO IN ( %Exp: '01' %, %Exp: '16' %)  //ISS
	   AND T52.%NotDel%
   
 EndSql

 DbSelectArea(cAliasQry)
 (cAliasQry)->(DbGoTop())
 
Return cAliasQry

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafIncTT
Insercao na tabela temporaria tratamento para objeto Bulk ou temp table.
@Param
@Return
@Author Denis Souza
@Since 18/10/2021
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function TafIncTT( aReg, lCanBulk, oBulk, oTT, cAliasTT )

Default aReg	 := {}
Default lCanBulk := .F.
Default oBulk	 := Nil
Default oTT	 	 := Nil
Default cAliasTT := ''

if lCanBulk //Importante sera comitado o lote quando efetuar o oBulk:Close() na funcao TAFENCGISS (TAFXGISS.PRW)
	oBulk:AddData( aReg[1] )
elseif !Empty( cAliasTT )
	RecLock(cAliasTT,.T.)
	(cAliasTT)->INDICADOR	:= aReg[1][01] 	//#col01 "CD_INDICADOR"              ||T
	(cAliasTT)->LAYOUT	 	:= aReg[1][02] 	//#col02 "NR_LAYOUT"                 ||1
	(cAliasTT)->EMISSAO	 	:= aReg[1][03] 	//#col03 "DT_EMISSAO_NF"             ||01/10/2018
	(cAliasTT)->DOCINI	 	:= aReg[1][04] 	//#col04 "NR_DOC_NF_INICIAL"         ||0003267
	(cAliasTT)->DOCSERIE	:= aReg[1][05] 	//#col05 "NR_DOC_NF_SERIE"           ||E
	(cAliasTT)->DOCFIN	 	:= aReg[1][06] 	//#col06 "NR_DOC_NF_FINAL"			 ||0003267
	(cAliasTT)->TPDOCNF	 	:= aReg[1][07] 	//#col07 "TP_DOC_NF"                 ||1
	(cAliasTT)->VLDOCNF	 	:= aReg[1][08]	//#col08 "VL_DOC_NF"      			 ||307000
	(cAliasTT)->VLBSCALC	:= aReg[1][09]	//#col09 "VL_BASE_CALCULO"			 ||0
	(cAliasTT)->ATIVIDADE	:= aReg[1][10]	//#col10 "CD_ATIVIDADE"              ||1701
	(cAliasTT)->CDPTESTAB	:= aReg[1][11]	//#col11 "CD_PREST_TOM_ESTABELECIDO" ||S
	(cAliasTT)->LOCALPREST 	:= aReg[1][12]	//#col12 "CD_LOCAL_PRESTACAO"        ||F
	(cAliasTT)->RAZAOSOC 	:= aReg[1][13]	//#col13 "NM_RAZAO_SOCIAL"           ||AIR E COMPRESS COMERCIO DE COMPRESSORES GERADORES PECAS E SE
	(cAliasTT)->NRCNPJCPF	:= aReg[1][14]	//#col14 "NR_CNPJ_CPF"	             ||02621808000111
	(cAliasTT)->TIPOCADAST 	:= aReg[1][15]	//#col15 "CD_TIPO_CADASTRO"          ||2
	(cAliasTT)->INSCMUN	 	:= aReg[1][16]	//#col16 "NR_INSCRICAO_MUNICIPAL"    ||02122590011
	(cAliasTT)->INSCMUNDV	:= aReg[1][17]	//#col17 "NM_INSCRICAO_MUNICIPAL_DV" ||01
	(cAliasTT)->INSCESTAD	:= aReg[1][18]	//#col18 "NR_INSCRICAO_ESTADUAL"     ||278107240118
	(cAliasTT)->TIPOLOGRAD 	:= aReg[1][19]	//#col19 "NM_TIPO_LOGRADOURO"        ||AME
	(cAliasTT)->TITLOGRAD	:= aReg[1][20]	//#col20 "NM_TITULO_LOGRADOURO"      ||Avenida Marginal Esquerda
	(cAliasTT)->LOGRADOURO 	:= aReg[1][21]	//#col21 "NM_LOGRADOURO"             ||AV MARIA SOCORRO E SILVA BEZERRA
	(cAliasTT)->COMPLOGRAD 	:= aReg[1][22]	//#col22 "NM_COMPL_LOGRADOURO"       ||APTO
	(cAliasTT)->NRLOGRAD	:= aReg[1][23]	//#col23 "NR_LOGRADOURO"             ||1660
	(cAliasTT)->CEP		 	:= aReg[1][24]	//#col24 "CD_CEP"                    ||05305003
	(cAliasTT)->BAIRRO	 	:= aReg[1][25]	//#col25 "NM_BAIRRO"                 ||ARUJA CENTRO RESIDENCIAL
	(cAliasTT)->ESTADO	 	:= aReg[1][26]	//#col26 "CD_ESTADO"                 ||SP
	(cAliasTT)->CIDADE	 	:= aReg[1][27]	//#col27 "NM_CIDADE"                 ||SAO PAULO
	(cAliasTT)->PAIS		:= aReg[1][28]	//#col28 "CD_PAIS"                   ||BR
	(cAliasTT)->OBS		 	:= aReg[1][29]	//#col29 "NM_OBSERVACAO"             ||?
	(cAliasTT)->PLCONTA	 	:= aReg[1][30]	//#col30 "CD_PLANO_CONTA"            ||11310001
	(cAliasTT)->ALVARA	 	:= aReg[1][31]	//#col31 "CD_ALVARA"				 ||?
	(cAliasTT)->ORIGEM	 	:= aReg[1][32]	//#col32 "IC_ORIGEM_DADOS"           ||R
	(cAliasTT)->ENQUAD	 	:= aReg[1][33]	//#col33 "IC_ENQUADRAMENTO"          ||?
	(cAliasTT)->PLCONTAPAI 	:= aReg[1][34]	//#col34 "CD_PLANO_CONTA_PAI"        ||11310000
	(cAliasTT)->RECIMPOSTO 	:= aReg[1][35]	//#col35 "IC_RECOLHE_IMPOSTO"        ||?
	(cAliasTT)->ALIQ 		:= aReg[1][36]  //#col36 "VL_ALIQUOTA" 				 ||5099
	(cAliasTT)->ISENTO	 	:= aReg[1][37]	//#col37 "FL_ISENTO"                 ||S
	(cAliasTT)->SIMPLES	 	:= aReg[1][38]	//#col38 "FL_SIMPLES"         	     ||N
	(cAliasTT)->MESNF		:= aReg[1][39]	//#col39 "MESNF" 	 				 ||01
	(cAliasTT)->ANONF		:= aReg[1][40]	//#col40 "ANONF" 					 ||2021
	(cAliasTT)->(MsUnLock())
endif

//Apos Insercao limpa array de referencia
aSize( aReg , 0 )
aReg := {}

Return Nil
