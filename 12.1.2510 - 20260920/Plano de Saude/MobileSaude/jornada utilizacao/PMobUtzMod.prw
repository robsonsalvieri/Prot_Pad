#INCLUDE 'protheus.ch'
#DEFINE cEnt Chr(13)+Chr(10)
#DEFINE TIPO_BOLETO 1
#DEFINE TIPO_EXTRATO 2
#DEFINE cCodigosPF "104,116,117,123,124,125,127,134,137,138,139,140,141,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,182,183"


//-------------------------------------------------------------------
/*/{Protheus.doc} PMobUtzMod

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Class PMobUtzMod

	Data message
	Data parametersMap
	Data lMultiContract 	
	Data lLoginByCPF		
	Data chaveBeneficiario		
	Data tipoUsuario
	Data ano
	Data mes

	Data oConfig

	Data extratoMap

	Method New() constructor

	// Extrato de utilização
	Method extrato()
	Method getExtrato()

	// Apoio à regra de negocio
	Method getMessage()
	Method getQuery()	
	Method picValStr(nValue)
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method New(parametersMap) class PMobUtzMod

	self:parametersMap		:= parametersMap	
	self:message			:= ""

	self:oConfig 			:= nil

	// Extrato em lista
	self:extratoMap	        := jSonObject():New()
	self:extratoMap['extrato'] := {}

	self:lMultiContract 	:= self:parametersMap['multiContract']
	self:lLoginByCPF		:= self:parametersMap['chaveBeneficiarioTipo'] == 'CPF'
	self:chaveBeneficiario	:= self:parametersMap['chaveBeneficiario']
	self:ano				:= self:parametersMap['ano']
	self:mes				:= self:parametersMap['mes']
	self:tipoUsuario		:= self:parametersMap['tipoUsuario']

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} extrato

Retorna a lista o extrato de utilizacao com base em um periodo previamente selecionado
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method extrato() class PMobUtzMod

	Local cSql := ""
	Local lOcultaValor := self:oConfig['utilizacao']['ocultaVlr']

	// Busca query de um ponto único
	cSql := self:getQuery() 

	PlsQuery(cSql, "TRB1")

	If TRB1->( Eof() )
		self:message := "Não existe movimentação no periodo informado"

		TRB1->( dbCloseArea() )
		Return .F.
	Endif

	While !TRB1->( Eof() )
		// Prepara o objeto para receber a lista de extrato de utilização
		Aadd(self:extratoMap['extrato'], jSonObject():New())
		nLen := Len(self:extratoMap['extrato'])

		self:extratoMap['extrato'][nLen]['nomeBeneficiario']		:= Alltrim(TRB1->BA1_NOMUSR)
		self:extratoMap['extrato'][nLen]['matriculaBeneficiario']	:= TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

		self:extratoMap['extrato'][nLen]['codigoEvento']			:= Alltrim(TRB1->BD6_CODPRO)
		self:extratoMap['extrato'][nLen]['descricaoEvento']		    := Alltrim(TRB1->BD6_DESPRO)

		self:extratoMap['extrato'][nLen]['dataAtendimento']		    := Transform(dtos(TRB1->BD6_DATPRO), "@R 9999-99-99")
		self:extratoMap['extrato'][nLen]['codigoExecutante']		:= TRB1->BD6_CODRDA
		self:extratoMap['extrato'][nLen]['nomeExecutante']			:= Alltrim(TRB1->BD6_NOMRDA)
		self:extratoMap['extrato'][nLen]['cpfCnpjExecutante']		:= Val(TRB1->BAU_CPFCGC)
		self:extratoMap['extrato'][nLen]['codigoTipoServico']		:= Alltrim(TRB1->BD6_TPEVCT)
		self:extratoMap['extrato'][nLen]['descricaoTipoServico']	:= IIf(FindFunction("PLGetTpEvDesc"), Upper(PLGetTpEvDesc(TRB1->BD6_TPEVCT)), "SEM DESCRIÇÃO")
		self:extratoMap['extrato'][nLen]['quantidade']				:= self:picValStr(TRB1->BD6_QTDPRO)
		self:extratoMap['extrato'][nLen]['codigoContrato']			:= Alltrim(TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC))
		
		If !lOcultaValor
			self:extratoMap['extrato'][nLen]['valorServico']			:= self:picValStr(TRB1->BD6_VLRPAG)
			self:extratoMap['extrato'][nLen]['valorCoparticipacao']		:= self:picValStr(0)
		EndIf		

		//Se houver coparticipacao, repito o registro indicando o valor
		if TRB1->BD6_VLRTPF > 0
			Aadd(self:extratoMap['extrato'], jSonObject():New())
			nLen := Len(self:extratoMap['extrato'])

			self:extratoMap['extrato'][nLen]['nomeBeneficiario']		:= Alltrim(TRB1->BA1_NOMUSR)
			self:extratoMap['extrato'][nLen]['matriculaBeneficiario']	:= TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

			self:extratoMap['extrato'][nLen]['codigoEvento']			:= Alltrim(TRB1->BD6_CODPRO)
			self:extratoMap['extrato'][nLen]['descricaoEvento']		    := Alltrim(TRB1->BD6_DESPRO)

			self:extratoMap['extrato'][nLen]['dataAtendimento']		    := Transform(dtos(TRB1->BD6_DATPRO), "@R 9999-99-99")
			self:extratoMap['extrato'][nLen]['codigoExecutante']		:= TRB1->BD6_CODRDA
			self:extratoMap['extrato'][nLen]['nomeExecutante']			:= Alltrim(TRB1->BD6_NOMRDA)
			self:extratoMap['extrato'][nLen]['cpfCnpjExecutante']		:= Val(TRB1->BAU_CPFCGC)
			self:extratoMap['extrato'][nLen]['codigoTipoServico']		:= Alltrim(TRB1->BD6_TPEVCT)
			self:extratoMap['extrato'][nLen]['descricaoTipoServico']	:= IIf(FindFunction("PLGetTpEvDesc"), Upper(PLGetTpEvDesc(TRB1->BD6_TPEVCT)), "SEM DESCRIÇÃO")
			self:extratoMap['extrato'][nLen]['quantidade']				:= self:picValStr(TRB1->BD6_QTDPRO)
			self:extratoMap['extrato'][nLen]['codigoContrato']			:= Alltrim(TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC))

			If !lOcultaValor
				self:extratoMap['extrato'][nLen]['valorServico']			:= self:picValStr(TRB1->BD6_VLRPAG)			
				self:extratoMap['extrato'][nLen]['valorCoparticipacao']		:= self:picValStr(TRB1->BD6_VLRTPF)
			EndIf
			
		endIf

		TRB1->( dbSkip() )
	Enddo

	TRB1->( dbCloseArea() )

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} getExtrato

Retorna a lista do extrato de utilização
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getExtrato() class PMobUtzMod
Return(self:extratoMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} getMessage

Retorna mensagens de erro 
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getMessage() CLASS PMobUtzMod
Return(self:message)


//-------------------------------------------------------------------
/*/{Protheus.doc} getQuery

Retorna a String da query a ser executada pelo EndPoint 
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getQuery() CLASS PMobUtzMod

	Local cSql := ""
	Local cCpf := ""
	Local cModel := 'utilizacao'
	Local oMatric
	Local dDataIni := self:ano+self:mes+'01'
	Local dDataFim := Dtos(LastDate( StoD(dDataIni)))
	Local cCodLDP := GetNewPar("MV_PLEXDAC", "")
	Local cFase := self:oConfig[cModel]['faseIn']


	cSql := " SELECT " + cEnt
	cSql += " BAU_CPFCGC,"
	cSql += " BD6_CODLDP,"
	cSql += " BD6_CODPEG,"
	cSql += " BD6_NUMERO,"
	cSql += " BD6_ORIMOV,"
	cSql += " BD6_SEQUEN,"
	cSql += " BD6_CODRDA,"
	cSql += " BD6_NOMRDA,"
	cSql += " BD6_CODESP,"
	cSql += " BD6_CODLOC,"
	cSql += " BD6_LOCAL,"
	cSql += " BD6_DESLOC,"
	cSql += " BD6_FASE,"
	cSql += " BD6_CONCOB,"
	cSql += " BD6_QUACOB,"
	cSql += " BD6_CODPAD,"
	cSql += " BD6_CODPRO,"
	cSql += " BD6_DESPRO,"
	cSql += " BD6_DATPRO,"
	cSql += " BD6_QTDPRO,"
	cSql += " BD6_TPGRV,"
	cSql += " BD6_GUIACO,"
	cSql += " BD6_TPPF,"
	cSql += " BD6_SITUAC,"
	cSql += " BD6_BLOCPA,"
	cSql += " BD6_STATUS,"
	cSql += " BD6_TIPGUI,"
	cSql += " BD6_VLRPAG, "
	cSql += " BD6_VLRTPF,"
	cSql += " BD6_TPEVCT,"

	cSql += " BA1.BA1_CODINT," 
	cSql += " BA1.BA1_CODEMP, "
	cSql += " BA1.BA1_MATRIC, "
	cSql += " BA1.BA1_TIPREG,"
	cSql += " BA1.BA1_DIGITO,"
	cSql += " BA1.BA1_NOMUSR"

	// Essas amarrações só entram quANDo for multi-contrato
	If self:lLoginByCPF .or. self:lMultiContract
		cSql += ",TIT.BA1_CPFUSR, "
		cSql += " TIT.BA1_NOMUSR TITULAR, "
		cSql += " TIT.BA1_NREDUZ"
	Endif

	cSql += " FROM "
	cSql += RetSqlName("BD6")+" BD6, "
	cSql += RetSqlName("BAU")+" BAU, "

	// Essas amarrações só entram quANDo for multi-contrato
	If self:lLoginByCPF .or. self:lMultiContract
		cSql += RetSqlName("BA1")+" TIT, "
		cSql += RetSqlName("BA1")+" BEN, "
	Endif

	cSql += RetSqlName("BA1")+" BA1, "
	cSql += RetSqlName("BR8")+" BR8 "
	cSql += " WHERE "

	// Filtros do bD6, indiferente a questoes de contrato
	cSql += " BD6.BD6_FILIAL = '" + xFilial("BD6") +"' "	
	//Seguindo os mesmos paramentros do relatorio plsr022
	cSql += " AND BD6_DATPRO >= '"+dDataIni+"' "
	cSql += " AND BD6_DATPRO <= '"+dDataFim+"' "


	cSql += " AND BD6_AUDITA <> '1' " 
	cSql += " AND BD6_LIBERA <> '1' " //cSql += "AND ( bd6_libera <> '1' AND bd6_codldp = '0000' ) "
	cSql += " AND BD6_SITUAC <> '2' " 

	// Considera estas fases
	If !Empty(cFase)

		If At("/", cFase)
			cSql += " AND BD6_FASE IN " + FormatIn(cFase,"/") 
		ElseIf At(",",cFase)
			cSql += " AND BD6_FASE IN " + FormatIn(cFase,",")
		Else
			cSql += " AND BD6_FASE = '" + cFase + "'
		EndIf

	EndIf

	// Desconsidera locais setados no parâmetro MV_PLEXDAC
	If !Empty(cCodLDP)
		cCodLDP := ConvStrRel(cCodLDP)
		cSQL += " AND BD6_CODLDP NOT IN ('" + PLSRETLDP(4) + "','" + PLSRETLDP(9) + "'" + cCodLDP + " ) "
	endIf

	// Exclui guias com pagamento bloqueado ? 
	If self:oConfig[cModel]['excluiPagBloq']
		cSQL += " AND BD6_BLOCPA <> '1' "
	Endif 

	// Relacionamnto com prestador (BAU), indiferente a questoes de contrato
	cSql += " AND BAU_FILIAL = BD6_FILIAL "
	cSql += " AND BAU_CODIGO = BD6_CODRDA "
	cSql += " AND BAU.D_E_L_E_T_ = ' ' "

	// Relacionamento com o procedimento na tabela padrão
	cSql += "AND BR8.BR8_FILIAL = '" + xFilial("BA1")+"' "
	cSql += "AND BR8.BR8_CODPSA = BD6.BD6_CODPRO "
	cSql += "AND BR8.BR8_CODPAD = BD6.BD6_CODPAD "
	cSql += "AND BR8.D_E_L_E_T_ = ' ' "
	
	If (self:lLoginByCPF .or. self:lMultiContract) ; // Se o login for por cartão e for multi-contrato ou se o login login por CPF		
		// Pega todos os contratos onde este usuário é o titular. 
		// Nos contratos onde o usuário é o titular, deve analisar se os dependentes serão impressos junto.
		cSql += " AND BD6_FILIAL = BEN.BA1_FILIAL "
		cSql += " AND BD6_OPEUSR = BEN.BA1_CODINT "
		cSql += " AND BD6_CODEMP = BEN.BA1_CODEMP "
		cSql += " AND BD6_MATRIC = BEN.BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BEN.BA1_TIPREG "
		cSql += " AND BD6.D_E_L_E_T_ = ' ' "

		cSql += " AND (BEN.R_E_C_N_O_ = BA1.R_E_C_N_O_ ) "
		cSql += " AND TIT.BA1_FILIAL = BA1.BA1_FILIAL "
		cSql += " AND TIT.BA1_CODINT = BA1.BA1_CODINT "
		cSql += " AND TIT.BA1_CODEMP = BA1.BA1_CODEMP "
		cSql += " AND TIT.BA1_MATRIC = BA1.BA1_MATRIC "

		//Procura o CPF do beneficiario
		if self:lLoginByCPF 
			cCpf := self:chaveBeneficiario
		else
			BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
			if BA1->(DbSeek(xFilial('BA1')+self:chaveBeneficiario))
				cCpf := Alltrim(BA1->BA1_CPFUSR)
			else
				cCpf := Replicate('9',TamSx3("BA1_CPFUSR")[1])
			endIf
		endIf

		// Se não for permitido imprimir os dependentes, força a chave completa do beneficiário para pegar apenas os dados do usuário logado
		If !self:oConfig[cModel]['imprimeDependentes'] .or. self:tipoUsuario <> self:oConfig['beneficiary']['typeUsrTitular']
			cSql += " AND TIT.BA1_TIPREG = BA1.BA1_TIPREG "
			cSql += " AND TIT.BA1_DIGITO = BA1.BA1_DIGITO "
		Endif
		cSql += " AND TIT.BA1_CPFUSR = '"+cCpf+"' "
		cSql += " AND TIT.D_E_L_E_T_ = ' ' "

	Else	// Caso contrário, imprime apenas o usuário do contrato atual
		oMatric := PMobSplMat(self:chaveBeneficiario)
		cSql += " AND BA1.BA1_CODINT = '"+oMatric['codInt']+"' "
		cSql += " AND BA1.BA1_CODEMP = '"+oMatric['codEmp']+"' "
		cSql += " AND BA1.BA1_MATRIC = '"+oMatric['matric']+"' "

		// Se o usuário logado for um itular, deve deve analisar se os dependentes serão impressos junto. 
		If !self:tipoUsuario == self:oConfig['beneficiary']['typeUsrTitular'] .Or.;	// Usuário não é um titular, então imprime apenas ele 
			(self:tipoUsuario == self:oConfig['beneficiary']['typeUsrTitular'] .And.;
			 	!self:oConfig[cModel]['imprimeDependentes'])	// É titular mas não deve imprimir os dependentes

			cSql += " AND BA1.BA1_TIPREG = '"+oMatric['tipReg']+"' "
			cSql += " AND BA1.BA1_DIGITO = '"+oMatric['digito']+"' "	
		Endif	
	Endif
	cSql += " AND BA1.BA1_FILIAL = '" + xFilial("BA1")+"' "
	cSql += " AND BA1.D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BA1.BA1_TIPUSU DESC, BA1.BA1_TIPREG, BD6_CODPEG, BD6_NUMERO, BD6_SEQUEN "

Return(cSql)


//-------------------------------------------------------------------
/*/{Protheus.doc} picValStr

Classe de apoio para formatacao dos campos numericos que devem ser 
retornados como String na API
@author  Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method picValStr(nValue) CLASS PMobUtzMod
Return StrTran(Alltrim(Transform(nValue, "@E 999999999.99")),",",".")
