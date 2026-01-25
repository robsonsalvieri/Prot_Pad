#INCLUDE 'protheus.ch'

#DEFINE cEnt Chr(13)+Chr(10)
#DEFINE TIPO_BOLETO 1
#DEFINE TIPO_EXTRATO 2
#DEFINE cCodigosPF "104,116,117,123,124,125,127,134,137,138,139,140,141,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,182,183"
#DEFINE cArqlog "plsmobile.log"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobFinMod

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Class PMobFinMod

	Data message
	Data parametersMap
	Data lMultiContract 	
	Data lLoginByCPF		
	Data chaveBeneficiario	
	Data tituloCodigo
	Data tituloId
	
	Data oConfig
	
	Data listaDebitosMap
	Data detalheDebitoMap
	Data boletoPdfMap
	Data extratoPdfMap
	Data cBinaryFile
	Data cURLFile
	
	Method New() constructor 

	// Lista boletos 
	Method listaDebitos()
	Method getListaDebitos()

	// Detalhe do boleto
	Method detalheDebito()
	Method getDetalheDebito()
	
	// Boleto em PDF
	Method boletoPdf()
	Method getBoletoPdf()
	
	// Extrato em PDF
	Method extratoFaturaPdf()
	Method getExtratoFaturaPdf()

	// Apoio à regra de negocio
	Method setDebitoRel(nTipo)
	Method setCutomerMap()
	Method getMessage()
	Method getSituacao(nValorBase, dVencto, nTituloId)
	Method getTipoCobranca(cFormRec, nTituloId)
	Method getLinhaDigitavel(cPrefixo,cNumero,cParcela,cTipo,cFormRec,cBanco,cAgencia,cConta,cDigito,cNossoNum,nValLiqui,cCart,cMoeda,cEspec,cAceite,nTituloId)
	Method getMatTit()

Endclass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method New(parametersMap) class PMobFinMod

	self:parametersMap		:= parametersMap	
	self:message			:= ""
	
	self:oConfig 			:= nil

	// Lista débitos
	self:listaDebitosMap	:= jSonObject():New() 
	self:listaDebitosMap['debitos'] := {}
	
	// Detalhe do débito
	self:detalheDebitoMap	:= jSonObject():New()
	self:detalheDebitoMap['detalhes'] := {}
	
	// boleto em PDF
	self:boletoPdfMap	:= jSonObject():New()
	
	// Extrato em PDF
	self:extratoPdfMap	:= jSonObject():New()
	
	self:cBinaryFile	:= nil
	self:cURLFile       := nil
	
	self:lMultiContract 	:= self:parametersMap['multiContract']
	self:lLoginByCPF		:= self:parametersMap['chaveBeneficiarioTipo'] == 'CPF'
	self:chaveBeneficiario	:= self:parametersMap['chaveBeneficiario']
	self:tituloCodigo		:= self:parametersMap['tituloCodigo']
	self:tituloId			:= self:parametersMap['tituloId']

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} listaDebitos

Lista os debitos do cliente 
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method listaDebitos() class PMobFinMod

	Local cSql := ""
	Local oMatric := NIL 
	Local aMatric := {}
	Local cDescricao := ""
	Local cQueryPE := NIL
	Local nX := 0
	Local cBancoDados := AllTrim(TCGetDB())
	Local lPMOBFI05 := ExistBlock("PMOBFI05")

	cSql := " SELECT " + cEnt
	cSql += "	SE1.E1_PREFIXO, " + cEnt
	cSql += "	SE1.E1_NUM, 	" + cEnt
	cSql += "	SE1.E1_TIPO, 	" + cEnt
	cSql += "	SE1.E1_PARCELA, " + cEnt
	cSql += "	SE1.R_E_C_N_O_ tituloId,	" + cEnt

	If cBancoDados $ "ORACLE|DB2|POSTGRES"
        cSql += "	SE1.E1_CODINT || SE1.E1_CODEMP || SE1.E1_MATRIC codigoContrato, " + cEnt
    Else
        cSql += "	SE1.E1_CODINT + SE1.E1_CODEMP + SE1.E1_MATRIC codigoContrato, " + cEnt
    EndIf

	cSql += "	SE1.E1_EMISSAO, " + cEnt	
	cSql += "	SE1.E1_VENCREA, " + cEnt
	cSql += "	SE1.E1_VENCTO, 	" + cEnt	
	cSql += "	SE1.E1_FORMREC, 	" + cEnt
	cSql += "	SE1.E1_VALOR, 	" + cEnt
	cSql += "	SE1.E1_SALDO, 	" + cEnt	
	cSql += "	SE1.E1_FILIAL, " + cEnt
	cSql += "	SE1.E1_PORTADO, " + cEnt
	cSql += "	SE1.E1_AGEDEP, 	" + cEnt
	cSql += "	SE1.E1_CONTA 	" + cEnt
	
	If self:lLoginByCPF .Or. self:lMultiContract	// Login por CPF ou Login por matricula + multicontrato
		//Busca todas as matriculas para o CPF
		aMatric := self:getMatTit()

		cSql += " FROM " + cEnt
		cSql += "	" + RetSqlName("SE1") + " SE1 " + cEnt
		cSql += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND " + cEnt

		For nX := 1 To Len(aMatric)
			If nX == 1
				cSql += " ( " + cEnt
			EndIf 
			
			cSql += "  (SE1.E1_CODINT = '"+aMatric[nX, 1]+"' AND " + cEnt
			cSql += "   SE1.E1_CODEMP = '"+aMatric[nX, 2]+"' AND " + cEnt
			cSql += "   SE1.E1_MATRIC = '"+aMatric[nX, 3]+"') " + cEnt

			If nX == Len(aMatric)
				cSql += " ) " + cEnt
			Else
				cSql += " OR " + cEnt
			EndIf
		Next nX
		
	Else
		// Fragmenta a matricula do usuário
		oMatric := PMobSplMat(self:chaveBeneficiario)

		cSql += " FROM " + cEnt
		cSql += "	" + RetSqlName("SE1") + " SE1 " + cEnt
		cSql += " WHERE SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' " + cEnt		
		cSql += "	AND SE1.E1_CODINT 	= '"+oMatric['codInt']+"' " + cEnt
		cSql += "	AND SE1.E1_CODEMP 	= '"+oMatric['codEmp']+"' " + cEnt
		cSql += "	AND SE1.E1_MATRIC 	= '"+oMatric['matric']+"' " + cEnt

	Endif

	// Prefixo contém
	If !Empty(self:oConfig['financeiro']['prefixosIn'])
		cSql += "	AND SE1.E1_PREFIXO 	in ("+self:oConfig['financeiro']['prefixosIn']+") " + cEnt
	Endif
	
	// Tipo contém
	If !Empty(self:oConfig['financeiro']['tiposIn'])
		cSql += "	AND SE1.E1_TIPO IN ("+self:oConfig['financeiro']['prefixosIn']+") " + cEnt
	Endif
	
	// Tipo não contém
	If !Empty(self:oConfig['financeiro']['tiposNotIn'])
		cSql += "	AND SE1.E1_TIPO NOT IN ("+self:oConfig['financeiro']['tiposNotIn']+") " + cEnt
	Endif
 
	// Se não for para exibir os pagos, considera apenas títulos em aberto
	If !self:oConfig['financeiro']['exibePagos']
		cSql += "	AND SE1.E1_SALDO  > 0 " 	+ cEnt
	Endif
	
	cSql += "	AND SE1.E1_SITUACA  > '0' " 	+ cEnt
	
	cSql += "	AND SE1.D_E_L_E_T_ 	= ' ' " + cEnt
	cSql += " ORDER BY codigoContrato, E1_VENCTO " + cEnt //Ordenando por: Matricula e Data de Vencimento.

	// Ponto de entrada para modificar a query do serviço
	If ExistBlock("PMOBFI04")
		cQueryPE := Execblock("PMOBFI04", .F., .F., {cSql, self:lMultiContract, self:lLoginByCPF, self:chaveBeneficiario})
		If Valtype(cQueryPE) == "C"
			cSql := cQueryPE
		Endif
	Endif
	
	// Manda bala.
	PlsQuery(cSql, "TRB1")

	If TRB1->( eof() )
		self:message := "Não existe débito à ser visualizado"

		TRB1->( dbCloseArea() )
		Return .F.
	Endif

	While !TRB1->( Eof() )
		// Prepara o objeto para receber a lista de debitos 
		Aadd(self:listaDebitosMap['debitos'], jSonObject():New())
		nLen := Len(self:listaDebitosMap['debitos'])

		self:listaDebitosMap['debitos'][nLen]['tituloCodigo']	:= TRB1->(E1_PREFIXO)+"|"+TRB1->(E1_NUM)+"|"+ TRB1->(E1_PARCELA)+"|"+TRB1->(E1_TIPO)
		self:listaDebitosMap['debitos'][nLen]['tituloId']		:= TRB1->tituloId
		self:listaDebitosMap['debitos'][nLen]['codigoContrato']	:= Alltrim(TRB1->codigoContrato)
		self:listaDebitosMap['debitos'][nLen]['dataEmissao']	:= Alltrim(Transform(Dtos(TRB1->E1_EMISSAO), "@R 9999-99-99"))
		self:listaDebitosMap['debitos'][nLen]['dataVencimento']	:= Alltrim(Transform(Dtos(TRB1->E1_VENCREA), "@R 9999-99-99"))

		
		self:listaDebitosMap['debitos'][nLen]['situacao'] 		:= self:getSituacao(TRB1->E1_SALDO, TRB1->E1_VENCTO, TRB1->tituloId)		
		self:listaDebitosMap['debitos'][nLen]['tipoCobranca'] 	:= self:getTipoCobranca(TRB1->E1_FORMREC, TRB1->tituloId)
		self:listaDebitosMap['debitos'][nLen]['valor']			:= Iif(TRB1->E1_SALDO != 0, TRB1->E1_SALDO, TRB1->E1_VALOR) 
		
		// Ponto de entrada para definir mensagens do boleto
		if lPMOBFI05
			cDescricao := Execblock("PMOBFI05", .F., .F. , {TRB1->(E1_PREFIXO),TRB1->(E1_NUM),TRB1->(E1_PARCELA),TRB1->(E1_TIPO)} )
		endIf
				
		self:listaDebitosMap['debitos'][nLen]['descricao'] := cDescricao

		TRB1->( dbSkip() )
	Enddo

	TRB1->( dbCloseArea() )
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} getListaDebitos

Retorna o Map da lista de débitos
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getListaDebitos() class PMobFinMod
Return(self:listaDebitosMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} detalheDebito

Retorna o detalhe de um debito selecionado 
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method detalheDebito() class PMobFinMod

	Local cSql := ""
	Local cCart		:= ""
	Local cAceite		:= ""
	Local cMoeda		:= "9"
	Local cEspec		:= "R$"
	Local cLinhaDigitavel	:= ""
	Local aMatTitulo    := StrTokArr(self:tituloCodigo,'|')

	if len(aMatTitulo) > 3

		cSql := " SELECT "
		// Contas a receber 
		cSql += " E1_PREFIXO, E1_NUM, E1_TIPO, E1_PARCELA, E1_PORTADO, E1_AGEDEP, E1_NUMBOR, E1_CODINT, E1_CODEMP, E1_MATRIC, E1_FORMREC, " + cEnt	
		cSql += " E1_VENCTO,E1_VENCREA, E1_BAIXA, E1_VALOR, E1_SALDO, E1_IRRF,  " 
		cSql += " SE1.R_E_C_N_O_ tituloId,	" + cEnt

		// Contas bancarias
		cSql += " A6_COD, A6_AGENCIA, A6_NUMCON, A6_DVCTA, A6_DVAGE, " + cEnt

		// Operadoras
		cSql += "	BA0.BA0_CGC, " + cEnt
		cSql += "	BA0.BA0_NOMINT, " + cEnt
		cSql += "	BA0.BA0_END, " + cEnt
		cSql += "	BA0.BA0_BAIRRO, BA0.BA0_CIDADE, BA0.BA0_EST, BA0.BA0_CEP " + cEnt

		cSql += " FROM "+RetSqlName("SE1")+" SE1 " + cEnt
		cSql += " LEFT JOIN "+RetSqlName("SA6")+" SA6 ON A6_FILIAL = '"+xFilial("SA6")+"' " + cEnt
		cSql += " AND SA6.A6_COD = SE1.E1_PORTADO " + cEnt
		cSql += " AND SA6.A6_AGENCIA = SE1.E1_AGEDEP " + cEnt
		cSql += " AND SA6.A6_NUMCON = SE1.E1_CONTA " + cEnt

		cSql += " AND SA6.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN "+RetSqlName("BA0")+" BA0 ON BA0_FILIAL = '"+xFilial("BA0")+"' "+ cEnt
		cSql += " AND BA0.BA0_CODIDE+BA0.BA0_CODINT = SE1.E1_CODINT "
		cSql += " AND BA0.D_E_L_E_T_  = ' ' " + cEnt
	
		cSql += " INNER JOIN "+RetSqlName("FK7")+" FK7 ON FK7.FK7_FILIAL = '"+xFilial("FK7")+"' "+ cEnt
		cSql += " AND FK7.FK7_FILTIT = SE1.E1_FILIAL AND FK7.FK7_PREFIX = SE1.E1_PREFIXO AND FK7.FK7_NUM = SE1.E1_NUM AND FK7.FK7_PARCEL = SE1.E1_PARCELA AND FK7.FK7_TIPO = SE1.E1_TIPO AND FK7.FK7_CLIFOR = SE1.E1_CLIENTE AND FK7.FK7_LOJA = SE1.E1_LOJA AND FK7.D_E_L_E_T_ = ' '"+ cEnt
		cSql += " LEFT JOIN "+RetSqlName("FK1")+" FK1 ON FK1.FK1_FILIAL = '"+xFilial("FK1")+"' "+ cEnt
		cSql += " AND FK1.FK1_IDDOC  = FK7.FK7_IDDOC AND FK1_MOTBX NOT IN ('DAC','CAN') AND  FK1.D_E_L_E_T_ = ' '

		cSql += " WHERE E1_FILIAL = '"+xFilial('SE1')+"' "
		cSql += " AND E1_PREFIXO = '"+aMatTitulo[1]+"' "
		cSql += " AND E1_NUM = '"    +aMatTitulo[2]+"' "
		cSql += " AND E1_PARCELA = '"+aMatTitulo[3]+"' "
		cSql += " AND E1_TIPO = '"   +aMatTitulo[4]+"' "
		cSql += " AND SE1.D_E_L_E_T_ = ' ' "
		PlsQuery(cSql, "TRB1")

		If TRB1->( eof() )
			self:message := "Não foi possível Localizar os detalhes do débito selecionado"

			TRB1->( dbCloseArea() )
			Return .F.	
		Endif

			Aadd(self:detalheDebitoMap['detalhes'], jSonObject():New())

			self:detalheDebitoMap['detalhes'][1]['cedenteNome'] 	:= Alltrim(TRB1->BA0_NOMINT)
			self:detalheDebitoMap['detalhes'][1]['dataVencimento'] 	:= Alltrim(Transform(Dtos(TRB1->E1_VENCREA), "@R 9999-99-99"))
			self:detalheDebitoMap['detalhes'][1]['dataPagamento'] 	:= Iif(!Empty(TRB1->E1_BAIXA),Alltrim(Transform(Dtos(TRB1->E1_BAIXA), "@R 9999-99-99")), "")
			self:detalheDebitoMap['detalhes'][1]['valor'] 			:= Iif(TRB1->E1_SALDO != 0, TRB1->E1_SALDO, TRB1->E1_VALOR)
			self:detalheDebitoMap['detalhes'][1]['situacao'] 		:= self:getSituacao(TRB1->E1_SALDO, TRB1->E1_VENCTO, TRB1->tituloId)
			self:detalheDebitoMap['detalhes'][1]['tipoCobranca'] 	:= self:getTipoCobranca(TRB1->E1_FORMREC, TRB1->tituloId)

			// Só calcula a linha digitavel se o tipo for BOLETO e não estiverr Baixado
			If self:detalheDebitoMap['detalhes'][1]['tipoCobranca'] == "B" .and. self:detalheDebitoMap['detalhes'][1]['situacao'] != "B" 

				// Calcula a linha digitável 
				cLinhaDigitavel := self:getLinhaDigitavel(;
										TRB1->E1_PREFIXO, TRB1->E1_NUM, TRB1->E1_PARCELA, TRB1->E1_TIPO, TRB1->E1_FORMREC,;
										TRB1->A6_COD, TRB1->A6_AGENCIA, TRB1->A6_NUMCON, TRB1->A6_DVCTA,;	
										TRB1->(E1_NUM+E1_PARCELA), TRB1->(E1_VALOR-E1_IRRF),;
										cCart, cMoeda, cEspec, cAceite, TRB1->tituloId)

				self:detalheDebitoMap['detalhes'][1]['imprimeBoleto'] 		:= "S"
				self:detalheDebitoMap['detalhes'][1]['linhaDigitavel'] 		:= cLinhaDigitavel
				self:detalheDebitoMap['detalhes'][1]['valorAtualizado'] 	:= {}

			Else
				self:detalheDebitoMap['detalhes'][1]['imprimeBoleto'] 		:= "N"
				self:detalheDebitoMap['detalhes'][1]['linhaDigitavel'] 		:= ""
				self:detalheDebitoMap['detalhes'][1]['valorAtualizado'] 	:= {}

			Endif

			self:detalheDebitoMap['detalhes'][1]['observacao'] 			:= ""
			self:detalheDebitoMap['detalhes'][1]['textoConfirmacao'] 	:= ""

			TRB1->( dbCloseArea() )	
	else
		self:message := "Não foi possível encontrar o título informado."
		Return .F.
	endIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} getDetalheDebito

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getDetalheDebito() class PMobFinMod
Return(self:detalheDebitoMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} boletoPdf

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method boletoPdf() class PMobFinMod

	If self:setDebitoRel(TIPO_BOLETO)

		//Verifica se o retorno foi preenchido corretamente
		if self:oConfig['financeiro']['pdfMode'] == "1" .And. Empty(self:cURLFile) .Or. ;		
		   self:oConfig['financeiro']['pdfMode'] != "1" .And. Empty(self:cBinaryFile)

			self:message := "Não foi possível processar o PDF do boleto"
			Return .F.
		endIf

		self:boletoPdfMap['base64'] := self:cBinaryFile
		self:boletoPdfMap['url']    := self:cURLFile	
	else
		Return .F.
	endIf

	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} getBoletoPdf

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getBoletoPdf() class PMobFinMod
Return(self:boletoPdfMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} extratoFaturaPdf

Retorna o Map do extrato do débito
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method extratoFaturaPdf() class PMobFinMod

	if self:setDebitoRel(TIPO_EXTRATO)
		
		//Verifica se o retorno foi preenchido corretamente
		if self:oConfig['financeiro']['pdfMode'] == "1" .And. Empty(self:cURLFile) .Or. ;		
		   self:oConfig['financeiro']['pdfMode'] != "1" .And. Empty(self:cBinaryFile)

			self:message := "Não foi possível processar o PDF do Extrato da Fatura"
			Return .F.
		endIf

		self:extratoPdfMap['base64'] := self:cBinaryFile
		self:extratoPdfMap['url']    := self:cURLFile	
	else
		Return .F.
	endIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} getExtratoFaturaPdf

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getExtratoFaturaPdf() class PMobFinMod
Return(self:extratoPdfMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} setDebitoRel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method setDebitoRel(nTipo) CLASS PMobFinMod

	Local cSql := ""
	Local __RELIMP := PLSMUDSIS(getWebDir() + getSkinPls() + "\relatorios\")
	Local cFileName := ""
	Local aMatTitulo := StrTokArr(self:tituloCodigo,'|')
	Local cQryPrefix := ""
	Local cQryNumero := ""
	Local cQryParcel := ""
	Local cQryTipo := ""
	Local lRet := .T.
	Local nElapsed := 0
	Local cAliasTemp := ""
	Local lCarteira := .T. // Considera E1_SITUACA? 

	PlsLogFil("["+Time()+"] Titulo Recebido: "+self:tituloCodigo, cArqlog)

	if len(aMatTitulo) <= 3 
		self:message := "Não foi possível encontrar o título informado"
		lRet := .F.
	else
		cAliasTemp := GetNextAlias()
		cSql := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_BAIXA FROM "+RetSqlName("SE1")
		cSql += " WHERE E1_FILIAL = '"+xFilial('SE1')+"' "
		cSql += " AND E1_PREFIXO = '"+aMatTitulo[1]+"' "
		cSql += " AND E1_NUM = '"    +aMatTitulo[2]+"' "
		cSql += " AND E1_PARCELA = '"+aMatTitulo[3]+"' "
		cSql += " AND E1_TIPO = '"   +aMatTitulo[4]+"' "
		cSql += " AND D_E_L_E_T_ = ' ' "
		DbUseArea(.T.,"TOPCONN", TcGenQry(,,cSql), cAliasTemp, .T., .T.)

		if !(cAliasTemp)->( eof() )
			cQryPrefix := (cAliasTemp)->E1_PREFIXO
			cQryNumero := (cAliasTemp)->E1_NUM
			cQryParcel := (cAliasTemp)->E1_PARCELA
			cQryTipo   := (cAliasTemp)->E1_TIPO
		else
			self:message := "Não foi possível Localizar os detalhes do débito selecionado"
			lRet := .F.
		endIf
		(cAliasTemp)->( dbCloseArea() )

		if lRet

			if nTipo == TIPO_BOLETO
				cFileName := PLSR580(NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL,;
								NIL, NIL, NIL, NIL, NIL, NIL, 1, 1, NIL, 1, 2, 1, 1,1,;
								.T., cQryPrefix, cQryNumero, cQryParcel, cQryTipo, __RELIMP)
			else
				cFileName := PLSR580(NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL,;
								NIL, NIL, NIL, NIL, NIL, NIL, 1, 1, NIL, 2, 1, 2, 2, 2,;
								.T., cQryPrefix, cQryNumero, cQryParcel, cQryTipo, __RELIMP, .T., , , lCarteira)
			endIf
						
			if Empty(cFileName)
				self:message := "Não foi possível gerar o PDF do " + iif(nTipo==TIPO_BOLETO,"Boleto","Extrato de Fatura")
				lRet := .F.
			endIf

			if lRet .And. !File(__RELIMP+cFileName)
				self:message := "Não foi possível localizar o PDF do " + iif(nTipo==TIPO_BOLETO,"Boleto","Extrato de Fatura")
				lRet := .F.
			endIf
			
			if lRet
				//Retorna a URL do arquivo para download
				if self:oConfig['financeiro']['pdfMode'] == "1"
					self:cURLFile    := lower(self:oConfig['security']['pdfUrl']+cFileName)
					self:cBinaryFile := ''
				
				//Retorna o base64 do arquivo
				else
					self:cURLFile    := ''
					nStart := Seconds()
					self:cBinaryFile := PMobFile64(__RELIMP+cFileName) // Converte o arquivo em base64
					nElapsed := (Seconds() - nStart)
					PlsLogFil("*** Conversao do PDF, tempo gasto no processamento: "+cValtoChar(nElapsed), cArqlog)
				endIf
			endIf
		endIf
	endIf

	PlsLogFil("*** Mensagem: "+IIf(!lRet, self:message, "Processado com sucesso!"), cArqlog)
	PlsLogFil("*** Arquivo Gerado: "+IIf(!Empty(cFileName), cFileName, "Nenhum Arquivo"), cArqlog)
	PlsLogFil("", cArqlog)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} getMessage

Retorna mensagens de erro 
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getMessage() CLASS PMobFinMod
Return(self:message)


//-------------------------------------------------------------------
/*/{Protheus.doc} getSituacao

Retorna a situação do titulo
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getSituacao(nValorBase, dVencto, nTituloId) CLASS PMobFinMod

	Local cSituacao := nil

	if ExistBlock("PMOBFI02")
		cSituacao := ExecBlock("PMOBFI02", .F., .F.,{nValorBase, dVencto, nTituloId})
	else
		if nValorBase == 0
			cSituacao := "B"
		elseIf dVencto < dDataBase
			cSituacao := "A"
		else
			cSituacao := "P"
		endIf
	endIf
	/* --- Opcoes Mobile ---
	P = A Vencer (em aberto porém ainda não está vencido)
	A = Atrasado (em aberto, porém já vencido)
	B = Baixado (já foi pago) */

Return(cSituacao)


//-------------------------------------------------------------------
/*/{Protheus.doc} getTipoCobranca

Retorna o tipo de cobranca
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getTipoCobranca(cFormRec, nTituloId) CLASS PMobFinMod

	Local cTipoCobranca := nil

	If ExistBlock("PMOBFI01")
		cTipoCobranca := ExecBlock("PMOBFI01", .F., .F., { cFormRec, nTituloId })
	Else
		BQL->(DbSetOrder(1)) //BQL_FILIAL+BQL_CODIGO
		If BQL->(DbSeek(xFilial('BQL')+cFormRec))
			
			Do Case
				Case BQL->BQL_CODMOB == '1'
					cTipoCobranca := 'C'
				
				Case BQL->BQL_CODMOB == '2'
					cTipoCobranca := 'B'

				Case BQL->BQL_CODMOB == '3'
					cTipoCobranca := 'D'
			EndCase

		EndIf
		/* 
		---- Opcoes Mobile ----
		C = Consignação / desconto em folha.
		B = Boleto.
		D = Débito em conta.

		---- Opcoes PLS ----
		1=Consignacao / Desconto em folha
		2=Boleto
		3=Debito em conta */
	Endif

	// Protege a integridade da informação
	If ValType(cTipoCobranca) <> "C"
		cTipoCobranca := ""
	Endif

Return(cTipoCobranca)


//-------------------------------------------------------------------
/*/{Protheus.doc} getLinhaDigitavel

Retorna a linha digitavel
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getLinhaDigitavel(cPrefixo,cNumero,cParcela,cTipo,cFormRec,cBanco,cAgencia,cConta,cDigito,cNossoNum,nValLiqui,cCart,cMoeda,cEspec,cAceite,nTituloId) CLASS PMobFinMod
	
	Local cCodBar		:= ""

	// Este ponto de entrada e obrigatorio
	if ExistBlock("PMOBFI03")
		cCodBar := Execblock("PMOBFI03", .F., .F., {cPrefixo,cNumero,cParcela,cTipo,cBanco,cFormRec,cAgencia,cConta,cDigito,cNossoNum,nValLiqui,cCart,cMoeda,cEspec,cAceite,nTituloId} )
	endIf


Return(cCodBar)


//-------------------------------------------------------------------
/*/{Protheus.doc} getMatTit

Retorna campos para busca de títulos quando selecionado CPF
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method getMatTit() CLASS PMobFinMod
	
	local cSql := "" as character
	local cCpf := "" as character
	local cCodInt := "" as character
	local cCodEmp := "" as character
	local cMatric := "" as character
	local aRet := {} as array
	local cHolderType := getNewPar("MV_PLCDTIT", "T") as character
	local cAlias as character

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

	cSql += " SELECT BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_DATBLO, BA1.BA1_CONSID, BG3.BG3_LOGIN, BG1.BG1_LOGIN "

	cSql += " FROM " + retSqlName("BA1") + " BA1 "

	cSql += " LEFT JOIN " + retSqlName("BG3") + " BG3 ON "
	cSql += "		BG3.BG3_FILIAL = '" + xFilial("BG3") + "' AND "
	cSql += "		BG3.BG3_CODBLO = BA1.BA1_MOTBLO AND "
	cSql += "		BG3.D_E_L_E_T_ = ' ' "
	
	cSql += " LEFT JOIN " + retSqlName("BG1") + " BG1 ON "
	cSql += "    	BG1.BG1_FILIAL = '" + xFilial("BG1") + "' AND "
	cSql += "		BG1.BG1_CODBLO = BA1.BA1_MOTBLO AND "
	cSql += "		BG1.D_E_L_E_T_ = ' ' "

	cSql += " WHERE BA1.BA1_FILIAL = '" + xFilial("BA1") + "' AND "
	cSql += " 		BA1.BA1_CPFUSR = '" + cCpf + "' AND "
	cSql += " 		(BA1_RESFAM = '1' OR BA1_TIPUSU = '" + cHolderType + "') AND "
	cSql += "		BA1.D_E_L_E_T_ = ' ' "

	cAlias := getNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), cAlias, .T., .F.)
    
	if !(cAlias)->(Eof())
		while !(cAlias)->(Eof())

			if !empty((cAlias)->BA1_DATBLO) .and. (stod((cAlias)->BA1_DATBLO) < dDataBase)
				if ((cAlias)->BA1_CONSID == "U" .and. (cAlias)->BG3_LOGIN == "2") .or. ((cAlias)->BA1_CONSID == "F" .and. (cAlias)->BG1_LOGIN == "2") // 2 = Impede login
					(cAlias)->(dbSkip())
					loop
				endif
			endif

			cCodInt := Alltrim((cAlias)->BA1_CODINT)
			cCodEmp := Alltrim((cAlias)->BA1_CODEMP)
			cMatric := Alltrim((cAlias)->BA1_MATRIC)

			aAdd(aRet, {cCodInt, cCodEmp, cMatric})

			(cAlias)->(dbSkip())
		enddo
	endif

	if len(aRet) == 0
		aAdd(aRet, {"XX", "XXXX", "XXXXXX"})
	endif

	(cAlias)->(dbClosearea())

return aRet
