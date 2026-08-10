#include 'totvs.ch'
#include 'OFCNHPrimPedido.ch'

function OFCNH0019();Return

/*/{Protheus.doc} OFCNHPrimPedido
	Classe de pedido para manutencao do SC7 em conjunto com RICEC
	
	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/ 
Class OFCNHPrimPedido
	Data oStateMachine As Object
	Data oSqlHelper As Object
	Data oLogger As Object

	Data cPedNum As Char
	Data cPedFab As Char

	Method New() CONSTRUCTOR
	Method Atualizar()
	Method pedidoNovo()
	Method criaPedido()
	Method podeImportar()
	Method SetaImport()
	Method atualizaPedido()
	Method atualizaFab()
	Method CriarPecas()
EndClass 

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method New() Class OFCNHPrimPedido
	Local aMap := {} As Array
	AADD(aMap, OFDMSMachineState():New(STR0001 , 'Q', {}))		//#'FATURADO'
	AADD(aMap, OFDMSMachineState():New(STR0002 , 'A', {}))		//#'CANCELADO'
	AADD(aMap, OFDMSMachineState():New(STR0003 , 'I', {STR0001, STR0002}))		//#'EMBALADO'	#'FATURADO'		#'CANCELADO'
	AADD(aMap, OFDMSMachineState():New(STR0004 , 'E', {STR0002, STR0005, STR0003, STR0001}))	//#'ATRIBUIDO'	#'CANCELADO'	#'PENDENTE'		#'EMBALADO'		#'FATURADO'
	AADD(aMap, OFDMSMachineState():New(STR0005 , 'N', {STR0002, STR0004, STR0003, STR0001}))	//#'PENDENTE'	#'CANCELADO'	#'ATRIBUIDO'	#'EMBALADO'		#'FATURADO'
	AADD(aMap, OFDMSMachineState():New(STR0006 , 'M', {STR0005, STR0002, STR0004, STR0003, STR0001}))		//#'RESERVADO'		#'PENDENTE'		#'CANCELADO'	#'ATRIBUIDO'	#'EMBALADO'		#'FATURADO'
	AADD(aMap, OFDMSMachineState():New(STR0007 , 'S', {STR0006, STR0002, STR0005, STR0004, STR0003, STR0001}))	//#'SUSPENSO'	#'RESERVADO'	#'CANCELADO'	#'PENDENTE'		#'ATRIBUIDO'	#'EMBALADO'		#'FATURADO'
	AADD(aMap, OFDMSMachineState():New(STR0008 , 'P', {STR0006, STR0007, STR0005, STR0002, STR0004, STR0003, STR0001}))		//#'CONFIRMADO'		#'RESERVADO'	#'SUSPENSO'		#'PENDENTE'		#'CANCELADO'	#'ATRIBUIDO'	#'EMBALADO'		#'FATURADO'
	::oStateMachine := OFDMSStateMachine():New(aMap)
	::oSqlHelper    := DMS_SqlHelper():New()
	::oLogger       := DMS_Logger():New()
Return SELF

/*/{Protheus.doc} OFCNHPrimPedido
	Cria/Atualiza pedido SC7 de acordo com arquivo
	
	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method Atualizar(cCodArq As Char, lRic150 As Logical) Class OFCNHPrimPedido	
	If self:podeImportar(cCodArq)
		if ! self:atualizaPedido(cCodarq, lRic150)
			return .f.
		endif
	else
		return .f.
	endif

	self:SetaImport(cCodArq)
return .t.

/*/{Protheus.doc} SetaImport
	Flaga o VBEpara demonstrar que o arquivo foi importado para o protheus

	@type function
	@author Vinicius Gati
	@since 05/04/2018
/*/
Method SetaImport(cCodArq As Char) Class OFCNHPrimPedido
	local cQuery := " UPDATE " + RetSQLName('VBE') As Char
	cQuery += " SET    VBE_FLGPRC = '1' "
	cQuery += " WHERE  VBE_FILIAL = '"+FWxFilial('VBE')+"' "
	cQuery += " AND    VBE_CODARQ = '"+cCodArq+"' "
	cQuery += " AND    D_E_L_E_T_ = ' ' "
Return TcSqlExec(cQuery) >= 0

/*/{Protheus.doc} podeImportar
	Verificar se eh possivel importar o arquivo RICEC, pois eles tem ordem correta
	se algum falou para todo o processo pois pode conter erros

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method podeImportar(cCodArq As Char) Class OFCNHPrimPedido
	local cQuery1 := "" As Char
	local cQuery2 := "" As Char
	cQuery1 += "  SELECT COUNT(*) "
	cQuery1 += "    FROM " + RetSQLName('VBE')
	cQuery1 += "   WHERE VBE_FILIAL = '"+FWxFilial('VBE')+"' "
	cQuery1 += "     AND VBE_CODARQ < '"+cCodArq+"' " // codigo do arquivo menor que atual
	cQuery1 += "     AND VBE_FLGPRC = '0' " // nao importado
	cQuery1 += "     AND D_E_L_E_T_ = ' ' "

	cQuery2 += "  SELECT COUNT(*) "
	cQuery2 += "    FROM " + RetSQLName('VBE')
	cQuery2 += "   WHERE VBE_FILIAL = '"+FWxFilial('VBE')+"' "
	cQuery2 += "     AND VBE_CODARQ = '"+cCodArq+"' " // codigo do arquivo igual
	cQuery2 += "     AND VBE_FLGPRC = '1' " // ja importado
	cQuery2 += "     AND D_E_L_E_T_ = ' ' "

	If FM_SQL(cQuery1) > 0 .OR. FM_SQL(cQuery2) > 0
		return .F.
	EndIf
return .T.

/*/{Protheus.doc} atualizaPedido
	Altera o pedido de acordo com as alteracoes enviadas pelo arquivo ricec

	@type function
	@author Vinicius Gati
	@since 14/03/2018
/*/
Method atualizaPedido(cCodArq As Char, lRic150 As Logical) Class OFCNHPrimPedido
	local nY       := 1 As Numeric
	local lRet 	   := .t.
	local cQuery   := '' As Char
	Local cKeyFab:= GetNewPar('MV_MIL0006') As Char
	
	local aPedidos := {} As Array

	PRIVATE cFornec	:= '' As Char
	PRIVATE cLojaFor:= '' As Char

	PRIVATE oPrimCfg	:= OFCNHPrimConfig():New(.T.) As Object

	cKeyFab := Padr(cKeyFab, FWTamSX3('VE4_PREFAB')[1])

	cFornec := Posicione('VE4',1 ,FWxFilial('VE4') + cKeyFab, 'VE4_CODFOR')
	cLojaFor := VE4->VE4_LOJFOR

	cFornec := Padr(cFornec, FWTamSX3('A2_COD')[1])
	cLojaFor:= Padr(cLojaFor, FWTamSX3('A2_LOJA')[1])

	cQuery += "   SELECT VBE_PEDFAB "
	cQuery += "     FROM "+RetSqlName('VBE')
	cQuery += "    WHERE VBE_FILIAL = '"+FWxFilial('VBE')+"' "
	cQuery += "      AND VBE_CODARQ = '"+cCodArq+"' "
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY VBE_PEDFAB "
	aPedidos := self:oSqlHelper:GetSelectArray(cQuery)
	begin transaction
		for nY := 1 to len(aPedidos)
			if ! self:atualizaFab(cCodArq, aPedidos[nY])
				disarmTransaction()
				lRet := .f.
				break
			endif
		next
	end transaction
	if lRet
		self:SetaImport(cCodArq)
	endif
	FWFreeArray(aPedidos)
Return lRet

/*/{Protheus.doc} atualizaFab
	Atualiza pedido realmente por pedfab, froi criada pois atualização<br/> 
	geralmente tem mais de 1 pedido.

	@type function
	@author Vinicius Gati
	@since 05/04/2018
/*/
Method atualizaFab(cCodArq As Char, cPedFab As Char) Class OFCNHPrimPedido
	local cQuery    := "" As Char
	local cItem     := StrZero(0,FWTamSX3("C7_ITEM")[1]) As Char
	local cPedNum   := '' As Char
	local cProdut   := nil As Char
	Local cLog		:= '' As Char

	local nX        := 1 As Numeric
	local nIdx      := 1 As Numeric
	local nModBck   := nModulo As Numeric
	local nOpcao    := 3 As Nmeric // novo
	Local nLog		:= 0 As Numeric
	
	Local oPeca     := DMS_Peca():New() As Object
	local oReg      := Nil As Object

	local aItem     := {} As Array
	local aItemAlt  := {} As Array
	local aItePed   := {} As Array
	local aBloquear := {} As Array
	Local aLogAuto	:= {} As Array

	Private lMSHelpAuto     := .T.
	Private lAutoErrNoFile  := .T.
	Private lMsErroAuto     := .F.

	cQuery := "    SELECT VBE_PRODUT "
	cQuery += "      FROM " + RetSQLName('VBE') + " VBE "
	cQuery += "     WHERE VBE_FILIAL = '"+FWxFilial('VBE')+"' "
	cQuery += "       AND VBE_CODARQ = '"+cCodArq+"' "
	cQuery += "       AND VBE_PEDFAB = '"+cPedFab+"' "
	cQuery += "       AND VBE.D_E_L_E_T_ = ' ' "
	aItePed := self:oSqlHelper:GetSelectArray(cQuery)
	if len(aItePed) > 0
		if ! self:CriarPecas(aItePed)
			OA060004C_log( "PRIM" /*cAgroup*/ , "RICEC" /*cTipo*/, STR0009 + '-' + STR0010 /*cDados*/, .T. ) //#'CRIACAO_PEDIDO'		#"Erro ao criar produto, não existe entrada de pedido."
			return .f.
		endif
	endif

	cQuery := "    SELECT VBE_PEDFAB,VBE_LINHAP,VBE_SUBLIN,VBE_DATPED,VBE_PRODUT,"
	cQuery += "           VBE_QTDLIN,VBE_TIPPED,VBE_QTDINI,VBE_VALDES,B1_UM,"
	cQuery += "           VBE_PRDSUB,VBE_QTDATE,VBE_STSUBL,VBE_NUMPED,B1_PRV1,B1_LOCPAD,"
	cQuery += "           C7_QUANT,C7_PRECO,C7_VLDESC,C7_ITEM,C7_NUM "
	cQuery += "      FROM " + self:oSqlHelper:Nolock('VBE')
	cQuery += "      JOIN " + self:oSqlHelper:Nolock('SB1') + " ON B1_FILIAL = '"+FWxFilial('SB1')+"' AND B1_COD = VBE_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + self:oSqlHelper:Nolock('SC7') + " ON C7_FILIAL = '"+FWxFilial('SC7')+"' "
	cQuery += "       AND C7_NUM = VBE_NUMPED AND C7_SLITPED = VBE_SUBLIN AND C7_ITEPED = VBE_LINHAP AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE VBE_FILIAL = '"+FWxFilial('VBE')+"' "
	cQuery += "       AND VBE_CODARQ = '"+cCodArq+"' "
	cQuery += "       AND VBE_PEDFAB = '"+cPedFab+"' "
	cQuery += "       AND VBE.D_E_L_E_T_ = ' ' "
	aItePed := self:oSqlHelper:getSelect({;
		{'campos', {'VBE_PEDFAB','VBE_LINHAP','VBE_SUBLIN','VBE_DATPED','VBE_PRODUT','VBE_QTDLIN','VBE_TIPPED','VBE_QTDINI','VBE_VALDES','B1_UM','VBE_PRDSUB','VBE_QTDATE','VBE_STSUBL','B1_PRV1','B1_LOCPAD', 'C7_QUANT','C7_PRECO'/*,'C7_STATUS'*/,'C7_VLDESC', 'C7_NUM', 'C7_ITEM'}},;
		{'query' , cQuery} ;
	})

	aCab := {}
	AADD(aCab, {"C7_EMISSAO" , dDatabase                 , Nil}) // Data de Emissao
	AADD(aCab, {"C7_FORNECE" , cFornec      			 , Nil}) // Fornecedor
	AADD(aCab, {"C7_LOJA"    , cLojaFor  				 , Nil}) // Loja do Fornecedor
	AADD(aCab, {"C7_COND"    , oPrimCfg:oConfig['CONDPAGTO'] , Nil}) // Condicao de pagamento
	AADD(aCab, {"C7_CONTATO" , ""                        , Nil}) // Contato
	AADD(aCab, {"C7_FILENT"  , ""                        , Nil}) // Filial Entrega

	cPedNum := iif( empty( aItePed[01]:gv('C7_NUM') ), GetSXENum('SC7', 'C7_NUM'), aItePed[01]:gv('C7_NUM') )

	aAdd(aCab, {"C7_NUM"  , cPedNum                        , Nil}) // Pedido

	For nX:= 1 to Len(aItePed)
		oReg    := aItePed[nX]

		if Empty(oReg:gv('VBE_PRDSUB', ''))
			cProdut := oReg:gv('VBE_PRODUT')
		else
			cProdut := oReg:gv('VBE_PRDSUB')
		endif

		if oPeca:Bloqueado(cProdut,,,.F.)
			if oPeca:Desbloquear(cProdut)
				AADD(aBloquear, cProdut) // grava para desbloquear depois do pedido gerado
			end 
		end
		/*altera*/
		if ! Empty( oReg:gv('C7_NUM') ) 
			aItemAlt := {}
			nOpcao    := 4
			AADD(aItemAlt , {"C7_NUM"     , cPedNum               , NIL })
			AADD(aItemAlt , {"C7_ITEM"    , oReg:gv('C7_ITEM')    , NIL })
			AADD(aItemAlt , {'C7_PRODUTO' , cProdut               , Nil                })
			AADD(aItemAlt , {'C7_QUANT'   , oReg:gv('VBE_QTDLIN') , Nil                })
			AADD(aItemAlt , {'C7_PRECO'   , oReg:gv('B1_PRV1')    , Nil                })
			AADD(aItemAlt , {'C7_VLDESC'  , oReg:gv('VBE_VALDES') , Nil                })
			
			IF AllTrim(oReg:gv('VBE_STSUBL')) == 'A'
				aAdd(aItemAlt, {'C7_RESIDUO', 'S', NIL})
			EndIF
			
			AADD(aItemAlt , {'LINPOS'     , "C7_ITEM"             , oReg:gv('C7_ITEM') })
			AADD(aItemAlt , {'AUTDELETA'  , "N"                   , NIL })

			AADD(aItem, aItemAlt)
		else
			/*Novo*/
			cItem   := Soma1(cItem)
			AADD(aItem, {;
				{ "C7_ITEM"    , cItem                       , Nil },;  // Numero do Item
				{ "C7_PRODUTO" , cProdut                     , Nil },;  // Codigo do Produto
				{ "C7_UM"      , oReg:gv('B1_UM')            , Nil },;  // Unidade de Medida
				{ "C7_QUANT"   , oReg:gv('VBE_QTDLIN')  	 , Nil },;  // Quantidade
				{ "C7_PRECO"   , oReg:gv('B1_PRV1')          , Nil },;  // Preco
				{ "C7_DATPRF"  , stod(oReg:gv('VBE_DATPED')) , Nil },;  // Data De Entrega
				{ "C7_LOCAL"   , oReg:gv('B1_LOCPAD')        , Nil },;  // Localizacao
				{ "C7_PEDFAB"  , oReg:gv('VBE_PEDFAB')       , Nil },;  // Pedido
				{ "C7_ITEPED"  , alltrim(str(val(oReg:gv('VBE_LINHAP', '0')))) , Nil },;  // Item do pedido
				{ "C7_SLITPED" , alltrim(str(val(oReg:gv('VBE_SUBLIN', '0')))) , Nil },;  // Sublinha do Item do pedido
				{ "C7_VLDESC"  , oReg:gv('VBE_VALDES')       , Nil },;  // desconto? VBE_VALDES
				{ "C7_TIPPED"  , oReg:gv('VBE_TIPPED')       , Nil },;  // tipo de pedido, nao temos tabela, vem direto do csps da cnh
				{ "C7_FLUXO"   , "S"                         , Nil } ;  // Fluxo de Caixa (S/N)
			})
		endif
	Next

	lMsErroAuto := .f.
	nModulo     := 2 // compras
	SetFunName("OFJD10I")
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,nOpcao)
	nModulo     := nModBck

	cPedNum := SC7->C7_NUM

	if lMsErroAuto
		Self:oLogger:LogSysErr('prim_erro_pedido_ric150.log', .F.)

		aLogAuto := GetAutoGRLog()
		For nLog := 1 To Len(aLogAuto)
			cLog += aLogAuto[nLog] + CRLF
		Next

		OA060004C_log( "PRIM" /*cAgroup*/ , "RICEC" /*cTipo*/, STR0012 + '-' + cLog /*cDados*/, .T. ) //#'ALTERACAO_PEDIDO'

		RollBackSX8()
	else
		cQuery := " UPDATE "+RetSqlName('VBE')
		cQuery += "    SET VBE_NUMPED = '"+SC7->C7_NUM+"' "
		cQuery += "  WHERE VBE_FILIAL = '"+FWxFilial('VBE')+"' "
		cQuery += "    AND VBE_PEDFAB = '"+cPedFab+"' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		if TcSqlExec(cQuery) < 0
			OA060004C_log( "PRIM" /*cAgroup*/ , "RICEC" /*cTipo*/, STR0009 + '-' + STR0011 /*cDados*/, .T. ) //#'CRIACAO_PEDIDO'		#"Erro em query interna, verificar email."
			return .f.
		endif

		for nIdx := 1 to LEN(aBloquear)
			oPeca:Bloquear(aBloquear[nIdx])
		next

		if nOpcao == 3
			ConfirmSX8()
			OA060004C_log( "PRIM" /*cAgroup*/ , "RICEC" /*cTipo*/, STR0009 + '-' + STR0013 + '-' + cPedNum /*cDados*/, .T. ) //#'CRIACAO_PEDIDO'		#"Pedido número : "
		else
			OA060004C_log( "PRIM" /*cAgroup*/ , "RICEC" /*cTipo*/, STR0012 + '-' + STR0013 + '-' + cPedNum /*cDados*/, .T. ) //#'ALTERACAO_PEDIDO'	#"Pedido número : "
		endif
	endif

	FWFreeObj(oPeca)
	FWFreeObj(oReg)

	FWFreeArray(aItem)
	FWFreeArray(aItemAlt)
	FWFreeArray(aItePed)
	FWFreeArray(aBloquear)
Return ! lMsErroAuto


/*/{Protheus.doc} atualizaFab
	Atualiza pedido realmente por pedfab, froi criada pois atualização<br/> 
	geralmente tem mais de 1 pedido.

	@type function
	@author Vinicius Gati
	@since 05/04/2018
/*/
Method CriarPecas(aPecas As Array) Class OFCNHPrimPedido
	Local oPrimCfg	:= OFCNHPrimConfig():New(.T.) As Object
	local oPeca   	:= DMS_Peca():New() As Object

	local nX      	:= 1 As Numeric
	
	Local cGrupo	:= oPrimCfg:oConfig['GRUPO'] As Char
	
	local cB1Cod 	:= '' As Char
	
	local aB1Data 	:= Nil As Array
	
	local lExiste 	:= .F. As Logical
	
	INCLUI := .T.
	ALTERA := .F.

	For nX := 1 to Len(aPecas)
		cB1Cod  := alltrim(aPecas[nX])
		lExiste := FM_SQL(" SELECT COUNT(*) FROM " + RetSQLName('SB1') + " WHERE B1_FILIAL = '"+FWxFilial('SB1')+"' AND B1_COD = '"+cB1Cod+"' AND D_E_L_E_T_ = ' '  ") > 0
		if ! lExiste
			aB1Data := {;
				{ "B1_FILIAL"  , FWxFilial("SB1")       , Nil },;
				{ "B1_COD"     , cB1Cod                 , Nil },;
				{ "B1_CODITE"  , cB1Cod                 , Nil },;
				{ "B1_GRUPO"   , cGrupo                 , Nil },; // joga peça criada em um grupo JD mas o 1o que encontrar, esse registro vai precisar de manutenção
				{ "B1_DESC"    , cB1Cod +" GERAUTOPRIM" , Nil },;
				{ "B1_TIPO"    , "ME"                   , Nil },;
				{ "B1_UM"      , "UN"                   , Nil },;
				{ "B1_PRV1"    , 1.0                    , Nil },;
				{ "B1_LOCPAD"  , "01"                   , Nil } ;
			}

			if ! oPeca:CriaPeca( cB1Cod, 3, aB1Data, 'PRIMPE001' /*ExistBlock*/)
				return .F.
			endif
		endif
	Next
	FWFreeObj(oPeca)
	FWFreeArray(aB1Data)
return .T.
