#include 'totvs.ch'
#include 'OFCNHPrimRicec.ch'

Function OFCNH0070();Return

/*/{Protheus.doc} OFCNHPrimRicec
	Classe que vai importar e dar manutenção em pedidos atravez de arquivos ricec 150 e 151
	
	@type function
	@author Vinicius Gati
	@since 09/03/2018
/*/ 
Class OFCNHPrimRicec
	Data aDados As Array
	
	Data cTipoMov As Char
	Data cCodMer As Char
	Data cCodUnidd As Char
	Data cCodGer As Char
	Data cNumPed As Char
	Data cNumLin As Char
	Data cNumSubLin As Char
	Data cTipPed As Char
	Data cDocRemessa As Char
	Data cNumVol As Char
	Data cCodItem As Char
	Data cCodSubs As Char
	Data cStatusSublinha As Char
	Data cNumPedProtheus As Char
	Data cEndReme As Char
	Data cLocacao As Char
	Data cTrackNum As Char
	Data cFlagED As Char
	Data cNumNf As Char
	Data cCodArq As Char
	Data cFilePath As Char
	Data cTipo As Char

	Data dDatPed As Date
	Data dDataDocRem As Date
	
	Data nQuant As Numeric
	Data nPreco As Numeric
	Data nQtdPed As Numeric
	Data nDesconto As Numeric
	Data nQtdAten As Numeric
	Data aPedERP As Array

	Method New() CONSTRUCTOR
	Method Processa()
	Method ProcessaLinha()
	Method Salvar()
	Method GetDecimal()
EndClass 

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Vinicius Gati
	@since 09/03/2018
/*/
Method New(cArqAbs As Char) Class OFCNHPrimRicec
	Default cArqAbs := ''
	::cFilePath     := cArqAbs
	::aDados        := {}
	::aPedERP       := {}
Return SELF

/*/{Protheus.doc} Processa
	Processa o arquivo

	@type function
	@author Vinicius Gati
	@since 02/03/2018
/*/
Method Processa(oLogger As Object, cFileId As Char) Class OFCNHPrimRicec
	local lRic150 := .F. As Logical
	Default oLogger := DMS_Logger():New()

	if "RICEC150" $ self:cFilePath
		lRic150 := .T.
	endif

	if FWGetRunSchedule()
		nAt   := AT('protheus_data', lower(self:cFilePath)) + 13
		nSize := len(self:cFilePath)
		self:cFilePath := SUBSTR(self:cFilePath, nAt, (nSize-nAt)+1)
	endif

	oFile := FWFileReader():New(self:cFilePath)
	if oFile:Open()
		while oFile:HasLine()
			cLinha := oFile:GetLine()
			self:ProcessaLinha(cLinha, lRic150)
		end
		oFile:Close()
	endif

	FWFreeobj(oFile)

	self:Salvar(cFileId)

	oPedido    := OFCNHPrimPedido():New()
	if oPedido:Atualizar(cFileId, lRic150)
		cFileTp    := IIF(lRic150, 'RIC150', 'RIC151')
		cTblLogCod := oLogger:LogToTable({;
			{'VQL_AGROUP' , 'PRIM'                                                  },;
			{'VQL_TIPO'   , cFileTp                                                 },;
			{'VQL_DADOS'  , cFileTp + ' ' +STR0001+' ['+self:cFilePath+']' } ;		//#"importado com sucesso"
		})
		oLogger:CloseOpened(cTblLogCod)
		FWFreeobj(oPedido)
		return .t.
	endif
Return .f. // dados de criacao de arquivo

/*/{Protheus.doc} ProcessaLinha
	Processa linha do arquivo coletando dados pertinentes somente

	@type function
	@author Vinicius Gati
	@since 02/03/2018
/*/
Method ProcessaLinha(cLinhaDados As Char, lRic150 As Logical) Class OFCNHPrimRicec
	local oRicec := OFCNHPrimRicec():New() As Object
	local cQuery as char
	local cC7Num as char

	if Empty(cLinhaDados)
		return .F.
	endif

	// pelo que entendi até agora o 150 é o arquivo de atualizacao de pedido
	// o 151 é de importação inicial, por iss oele não tem qtdatendida, sempre vai ser zero
	// é só de entrada de pedido
	if lRic150 
		oRicec:nQtdAten      := VAL(Substr(cLinhaDados, 139,  8))//Quantidade de itens atendidos (Summary Quantity)
		oRicec:cTipo         := '0'
	else
		oRicec:nQtdAten      := 0 //Quantidade de itens pendentes (Summary Quantity)
		oRicec:cTipo         := '1'
	endif
	oRicec:cTipoMov        := Substr(cLinhaDados,   1,  2)//Tipo de Movimento (Movement Type)
	oRicec:cCodMer         := Substr(cLinhaDados,   3,  4)//Código do Mercado (Market Code)
	oRicec:cCodUnidd       := Substr(cLinhaDados,   7,  7)//Código de concessionário (Dealer Code)
	oRicec:cCodGer         := Substr(cLinhaDados,  14,  7)//Código de gerenciamento (Management code)
														  //Empresa (Company)
	oRicec:cNumPed         := Substr(cLinhaDados,  23,  7)//Número de pedido (Order Number)
	oRicec:cNumLin         := Substr(cLinhaDados,  30,  5)//Número da linha de pedido (Order line number) 
	oRicec:cNumSubLin      := Substr(cLinhaDados,  35,  5)//Número da sublinha (Split line number)
	oRicec:dDatPed         := STOD("20" + Substr(cLinhaDados,  40,  6))//Data do pedido (Order date)
	oRicec:cCodItem        := Substr(cLinhaDados,  46, 20)//Código do item (Part Number)
	oRicec:nQuant          := Val( Substr(cLinhaDados,  66,  8) )//Quantidade (Quantity)
	oRicec:nPreco          := self:GetDecimal( Substr(cLinhaDados,  74,  9), 2 )//Preço  (Price)
	oRicec:cTipPed         := Substr(cLinhaDados,  83,  2)//Tipo de pedido (Order type)
	oRicec:nQtdPed         := Val(Substr(cLinhaDados,  85,  8))//Quantidade inicial de pedidos (Initial order quantity)
	oRicec:nDesconto       := self:GetDecimal( Substr(cLinhaDados,  93,  6), 2 )//Desconto (Discount)
	oRicec:cDocRemessa     := Substr(cLinhaDados,  99, 10)//Número do documento de remessa (Shipping document number)
	oRicec:cNumVol         := Substr(cLinhaDados, 109, 10)//Número do volume (Box number)
	oRicec:cCodSubs        := Substr(cLinhaDados, 119, 20)//Item descontinuado  (Replaced Item)
	//oRicec:nQtdAten      := VAL(Substr(cLinhaDados, 139,  8))//Quantidade de itens atendidos (Summary Quantity)																												  
														  //IVA% (V.A.T. %)
														  //Código da Razão  (Reason code)
														  //Códigos saldo pendente de entrega (Summary code)
	oRicec:cStatusSublinha := Substr(cLinhaDados, 154,  1)//Status da sublinha do pedido  (Split order line status)
	oRicec:cNumPedProtheus := Substr(cLinhaDados, 155,  13)//Número do pedido do concessionário (DMS order number)
														   //Quantidade processada (Processed quantity)
	oRicec:dDataDocRem     := STOD("20" + Substr(cLinhaDados, 176,  6))//Data do documento de remessa (Shipping document date)
	oRicec:cEndReme        := Substr(cLinhaDados, 182,  4)//Endereço para remessa  (Shipping address)
	oRicec:cLocacao        := Substr(cLinhaDados, 186,  8)//Locação do item no armazém (Customer location)
	oRicec:cTrackNum       := Substr(cLinhaDados, 194, 15)//Número de conhecimento de transporte (Tracking Number)
														  //Campo livre (Filler)
	oRicec:cFlagED         := 'N' 						  //Indicador de pedidos entrega direta (flg_ord_dfs)
	oRicec:cNumNf          := Substr(cLinhaDados, 222, 15)//Número da Nota fiscal (Invoice Number)

	cQuery := "select C7_NUM from " + retSqlname("SC7")
	cQuery += " where C7_FILIAL='"+xFilial("SC7")+"'"
	cQuery += " and C7_PRODUTO='"+ oRicec:cCodItem +"'"
	cQuery += " and C7_PEDFAB='"+ oRicec:cNumPed +"'"
	cQuery += " and C7_ITEPED='"+ cValToChar(val(oRicec:cNumLin))+"'"
	cQuery += " and C7_SLITPED='"+cValToChar(val(oRicec:cNumSubLin))+"'"
	cQuery += " and D_E_L_E_T_=' '"
	if ! empty( cC7Num := FM_SQL( cQuery ) )
		oRicec:cNumPedProtheus := cC7Num
	endif

	if ! empty( oRicec:cNumPedProtheus ) .and. aScan( ::aPedERP, oRicec:cNumPedProtheus ) == 0
		aAdd( ::aPedERP, oRicec:cNumPedProtheus )
	endif

Return Aadd(self:aDados, oRicec)

/*/{Protheus.doc} Salvar
	Salva o arquivo no banco e identifica os registros prim2 errados

	@type function
	@author Vinicius Gati
	@since 02/03/2018
/*/
Method Salvar(cFileId As Char) Class OFCNHPrimRicec
	local nX := 0 As Numeric

	local dDateRec := date() As Date
	
	local oRicec As Object

	Local cLib As Char
	Local cMsg As Char

	Local nErro As Numeric
	Local nRemote := GetRemoteType(@cLib) As Numeric
	
	confirmSx8()
	
	cDel := " UPDATE " + RetSqlName('VBE')
	cDel += "    SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	cDel += "  WHERE VBE_FILIAL = '"+FWxFilial('VBE')+"' "
	cDel += "    AND ( VBE_CODARQ = '"+cFileId+"' "
	if len( ::aPedERP ) > 0
		cDel += " OR VBE_NUMPED IN ('"+ arrTokStr( ::aPedERP, "','" )+"') 
	endif
	cDel += ")"
	cDel += "    AND VBE_FLGPRC = ' ' " // só não importados
	cDel += "    AND D_E_L_E_T_ = ' ' "
	
	/*executa a transacao...*/
	nErro := TcSqlExec(cDel) // remove lixos não importados

	/*se houver erro impede a transacao...*/
	IF nErro != 0
		cMsg := 'Erro na execução SQL: ' + TCSqlError()
		IF nRemote == -1
			QOUT(cMsg)
		ELSEIF (nRemote == 1 .OR. nRemote == 2)
			FWAlertWarning(cMsg, 'Erro SQL')
		EndIF
	EndIF

	begin transaction
	For nX:= 1 to Len(self:aDados)
		oRicec := self:aDados[nX]

		reclock('VBE', .t.)
		VBE->VBE_FILIAL := FWxFilial('VBE')
		VBE->VBE_CODIGO := GetSxeNum('VBE', 'VBE_CODIGO'); confirmSx8()
		VBE->VBE_CODARQ := cFileId
		VBE->VBE_DATREC := dDateRec
		VBE->VBE_TIPO   := oRicec:cTipo
		VBE->VBE_PEDFAB := oRicec:cNumPed
		VBE->VBE_NUMPED := oRicec:cNumPedProtheus
		VBE->VBE_LINHAP := cValToChar( val( oRicec:cNumLin ) )
		VBE->VBE_SUBLIN := cValToChar( val( oRicec:cNumSubLin ) )
		VBE->VBE_DATPED := oRicec:dDatPed
		VBE->VBE_PRODUT := oRicec:cCodItem
		VBE->VBE_QTDLIN := oRicec:nQuant
		VBE->VBE_VLRTOT := oRicec:nPreco
		VBE->VBE_TIPPED := oRicec:cTipPed
		VBE->VBE_QTDINI := oRicec:nQtdPed
		VBE->VBE_VALDES := oRicec:nDesconto
		VBE->VBE_NUMVOL := oRicec:cNumVol
		VBE->VBE_PRDSUB := oRicec:cCodSubs
		// 150 => atendidos
		// 151 => pendentes => não usado
		VBE->VBE_QTDATE := oRicec:nQtdAten
		VBE->VBE_STSUBL := oRicec:cStatusSublinha
		VBE->VBE_DTPRCR := oRicec:dDataDocRem
		VBE->VBE_DOCREM := oRicec:cDocRemessa
		VBE->VBE_ENDREM := oRicec:cEndReme
		VBE->VBE_LOCCAO := oRicec:cLocacao
		VBE->VBE_TRANUM := oRicec:cTrackNum
		VBE->VBE_FLGEND := oRicec:cFlagED
		//VBE->VBE_NUMNFI := oRicec:cNumNf
		VBE->VBE_INVNUM := oRicec:cNumNf
		
		VBE->(MsUnlock())
	Next

	end transaction
	self:cCodArq := cFileId
	FWFreeobj(oRicec)
Return .T.

/*/{Protheus.doc} GetDecimal
	Pega valor em string e devolve o valor fazer o decimal conforme parametros

	@type function
	@author Vinicius Gati
	@since 12/03/2018
/*/
Method GetDecimal(cVal As Char, nDec As Numeric) Class OFCNHPrimRicec
	nSizeInt := Len(cVal) - nDec
Return &( Left(cVal, nSizeInt ) + "." + Right(cVal, nDec) )
