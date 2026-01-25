#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static cDocPed 	:= "" //Armazena o L1_DOCPED da venda
Static cDocRPS 	:= "" //Cancelamento RPS
Static cSerRPS 	:= "" //Cancelamento RPS
Static lPdvOn	:= ExistFunc("STFPdvOn") .AND. STFPdvOn() 	// Verifica se é PDV-Online

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSChkRes
Verifica se existe reserva para todos itens da Venda

@param   cNumSale				Numero da Venda
@param   cNumOrig				Numero da Original da SL1
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se a venda está em andamento ou não
/*/
//-------------------------------------------------------------------
Function STDCSChkRes( cNumSale, sNumOrig )
Local lRet		:=	.F.					// Retorna se existe  item com reserva
Local aArea		:= GetArea()			// Guarda Area
Local aAreaSL2	:= {}
Local cFilSL2	:= ""

Default cNumSale:= ""
Default sNumOrig:= ""

LjGrvLog(cNumSale,"Validação se venda possui reserva para permitir cancelamento")

DbSelectArea("SL2")
aAreaSL2 := SL2->(GetArea())	// Guarda area do SL2
SL2->( DbSetOrder(1) )//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
cFilSL2 := xFilial("SL2")
LjGrvLog(cNumSale," Itens a serem procurados - Dados: L2_FILIAL [" + cFilSL2 + "] || L2_NUM [" + cNumSale + "]")

If SL2->( DbSeek( cFilSL2 + cNumSale ) )
	If lPdvOn .AND. !Empty(sNumOrig)
		lRet := STDValIRes(sNumOrig)
	Else 
		LjGrvLog(cNumSale,"Achou os itens da venda",cFilSL2 + cNumSale)
		While SL2->( !EOF() ) .AND. (SL2->L2_FILIAL + SL2->L2_NUM == cFilSL2 + cNumSale)
			LjGrvLog(cNumSale,"SL2->L2_ENTREGA",SL2->L2_ENTREGA)
			LjGrvLog(cNumSale,"SL2->L2_RESERVA",SL2->L2_RESERVA)
			If !Empty(AllTrim(SL2->L2_ENTREGA)) .AND. !(SL2->L2_ENTREGA == "2") .AND. !Empty(AllTrim(SL2->L2_RESERVA))
				lRet := .T.		
				Exit
			EndIf
			SL2->( DbSkip() )
		EndDo
	Endif  

	If lRet
		LjGrvLog(cNumSale,"Existe item com reserva, não permite cancelar a venda pelo Totvs Pdv - lRet = .T.",lRet)
	Endif 

Else
	LjGrvLog(cNumSale,"Numero de orçamento não encontrado - L1_NUM [" + cNumSale + "]")
	lRet := .F.
EndIf	

RestArea(aAreaSL2)
RestArea(aArea)               

Iif(lRet,LjGrvLog(cNumSale,"Existe(m) produto(s) de reserva - venda não pode ser cancelada"),NIL)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSLastSale
Busca Numero do Ultimo Orçamento

@param   cRetField - Nome do campo no dicionario de dados da tabela SL1
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cNumSale - Retorna o Numero ou outro campo da tabela SL1 da Ultima Venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSLastSale(cRetField, cGetSerie)

Local cNumSale	:= ""										// Retorna o Numero da Ultima Venda ou o campo do parametro
Local nRecnoL1	:= 0									  	// Armazena Recno do ultimo registro físico da SL1
Local aArea		:= {}									  	// Armazena Area corrente
Local lReImp	:= IsInCallStack("LjNFCeReImp")				// É Reimpressão de Cupom? 

Default cRetField := "L1_NUM"
Default cGetSerie := STFGetStation("SERIE")

aArea 		:= SL1->(GetArea())

// Posiciona o SL1 na ultima venda
DbSelectArea("SL1")

If lPdvOn .And. !lReImp
	cNumSale := STDLastPdvOn(cRetField, @cGetSerie)
Else
	SL1->(DbSetOrder(1))
	nRecnoL1 := SL1->(LASTREC())
	SL1->(DbGoto(nRecnoL1))
	While !BOF() .And. SL1->( Deleted() )
		SL1->(DbSkip(-1))
	EndDo 
	cNumSale := &("SL1->("+cRetField+")")

	If !Empty(SL1->L1_SERIE)
		cGetSerie :=SL1->L1_SERIE 
	Endif	 

	If !Empty(STDGtDocRPS()) .And. FWSIXUtil():ExistIndex( "SL1" , "O" )	
		//Este indice está cadastrado somemte para o Brasil. 
		SL1->(DbSetOrder(24)) // L1_FILIAL+L1_DOCRPS+L1_SERRPS+L1_PDV 
		If DbSeek(xFilial("SL1")+STDGtDocRPS()+STDGtSERRPS())
			cNumSale := &("SL1->("+cRetField+")")
		EndIf	
	EndIf
EndIf


LjGrvLog( "STDCSLastSale", "Ultimo registro da SL1 posicionado:"+cRetField,cNumSale)

RestArea(aArea)

Return cNumSale


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSDoc
Busca o DOC da venda

@param   cNumSale				Numero da Venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cDoc					Retorna o L1_DOC da Venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
// 
Function STDCSDoc( cNumSale )

Local cDoc 		:= ""										// Retorna o L1_DOC da Venda
Local aArea		:= {}										// Armazena Area corrente
Local aAreaSL1	:= {}										// Armazena Area SL1

Default cNumSale:= ""

aArea 		:= GetArea()
aAreaSL1 	:= SL1->(GetArea())

DbSelectArea("SL1")
DbSetOrder(1)//L1_FILIAL+L1_NUM
If lPdvOn == .T.
	SL1->(DbSeek(xFilial("SL1")+cNumSale))	// Posiciona na SL1 retornada da query
EndIf

If (xFilial("SL1") == SL1->L1_FILIAL) .AND. (SL1->L1_NUM == cNumSale) // Ja posicionado

	cDocPed := SL1->L1_DOCPED
	cDocRPS := SL1->L1_DOCRPS
 	cSerRPS := SL1->L1_SERRPS

	If !Empty(SL1->L1_DOC)
		cDoc := SL1->L1_DOC	
	Endif 

	STDSPBasket("SL1","L1_CLIENTE"	,SL1->L1_CLIENTE)
	STDSPBasket("SL1","L1_LOJA"		,SL1->L1_LOJA	)
	STDSPBasket("SL1","L1_CGCCLI"	,SL1->L1_CGCCLI	)

Else 

	If DbSeek( xFilial("SL1") + cNumSale )

		cDocPed := SL1->L1_DOCPED

		If !Empty(SL1->L1_DOC)
			cDoc := SL1->L1_DOC	
		Endif 
		//Alimenta o codigo e o nome do cliente na cesta
		STDSPBasket("SL1","L1_CLIENTE"	,SL1->L1_CLIENTE)
		STDSPBasket("SL1","L1_LOJA"	,SL1->L1_LOJA)
		STDSPBasket("SL1","L1_CGCCLI"	,SL1->L1_CGCCLI)
	EndIf
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return cDoc


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSNum
Busca L1_NUM a partir do DOC/PDV

@param   cNumDoc				Numero do documento (L1_DOC)
@param   cPDV					Numero do PDV
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cNum					Retorna o numero da vendaa L1_NUM
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSNum( cNumDoc , cPDV, lDocNf, cSerie, cL1Num )

Local cNum 			:= ""						// Retorna L1_NUM
Local aArea 			:= GetArea()				// Armazena Area corrente
Local aAreaSL1 		:= SL1->(GetArea())		// Armazena Area SL1
Local cSerNf		:= "" //Serie nao fiscal
Local cDocNf		:= "" //Numero do documento nao fiscal

Default cNumDoc  	:= ""
Default cPDV  		:= ""
Default lDocNf		:= .F.
Default cSerie		:= STFGetStation("SERIE")	// Serie da estaçao, acrescentado para cancelamento NF-e
Default cL1Num 		:= ""						// L1_NUM, utilizar somente quando é cancelamento de venda TOTVS ONLINE

cSerie	:= PadR( cSerie, SL1->(TamSx3("L1_SERIE"))[1] )
cNumDoc := PadR( cNumDoc, SL1->(TamSx3("L1_DOC"))[1] )
cPDV	:= Padr( cPDV, Len(CriaVar("L1_PDV",.F.)),'' )

DbSelectArea("SL1")

If lPdvOn .AND. !Empty(cL1Num)
	cNum = cL1Num
ElseIf !lDocNf
	SL1->( DbSetOrder(2) )	//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
	If SL1->( DbSeek(xFilial("SL1") + cSerie + cNumDoc + cPDV) )
		cNum := SL1->L1_NUM
	Else
		SL1->(DbSetOrder(11)) //L1_FILIAL+L1_SERPED+L1_DOCPED
		If SL1->( DbSeek(xFilial("SL1")+cSerie+cNumDoc))  .AND. AllTrim(SL1->L1_PDV) == Alltrim(cPDV)
				cNum := SL1->L1_NUM
		ElseIf FWSIXUtil():ExistIndex( "SL1" , "O" )                     
			//Este indice está cadastrado somemte para o Brasil.                           
			SL1->(DbSetOrder(24)) //L1_FILIAL+L1_DOCRPS+L1_SERRPS+L1_PDV  
			If SL1->(DbSeek(xFilial("SL1")+cNumDoc+cSerie+AllTrim(cPDV)))
				cNum 	:= SL1->L1_NUM
				cDocRPS := SL1->L1_DOCRPS
				cSerRPS := SL1->L1_SERRPS
			EndIf	
		EndIf                                                                                 
	EndIf
Else
	If !Empty(cDocRPS) .AND. !Empty(cSerRPS) .AND. SL1->L1_DOCRPS == cDocRPS .AND. SL1->L1_SERRPS == cSerRPS   //Cancelamento RPS
		cNum := SL1->L1_NUM
	Else
		cSerNf	:= PadR( STFGetStation("SERNFIS"), SL1->(TamSx3("L1_SERPED"))[1] )
		cDocNf	:= PadR( cNumDoc, SL1->(TamSx3("L1_DOCPED"))[1] )

		SL1->(DbSetOrder(11)) //L1_FILIAL+L1_SERPED+L1_DOCPED
		If SL1->( DbSeek(xFilial("SL1")+cSerNf+cDocNf))  .AND. AllTrim(SL1->L1_PDV) == Alltrim(cPDV)
			cNum := SL1->L1_NUM
		EndIf
	Endif 
Endif 


RestArea(aAreaSL1)
RestArea(aArea)

Return cNum


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSFactura
Busca Dados da venda para análide se Factura Global

@param   cNumDoc				Numero do documento (L1_DOC)
@param   cPDV					Numero do PDV
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1]				L1_DOC
@return  aRet[2]				L1_SERIE
@return  aRet[3]				L1_CLIENTE
@return  aRet[4]				L1_LOJA
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSFactura( cNumDoc , cPDV )

Local aRet 		:= {}					// Array de retorno
Local aArea 	:= GetArea()			// Armazena Area corrente
Local aAreaSL1 	:= SL1->(GetArea())	// Armazena Area SL1

Default cNumDoc := ""
Default cPDV  	:= ""

SL1->(DbSetOrder(8))//L1_FILIAL+L1_PDV+L1_DOC
If SL1->(DbSeek(xFilial("SL1") + cPDV + cNumDoc))
	aRet := { SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_CLIENTE, SL1->L1_LOJA }
EndIf

RestArea(aAreaSL1)
RestArea(aArea)
	
Return aRet

 
//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSRefsh
Desposiciona e reposiciona no mesmo registro. Utilizado em caso de registro alterado por outra thread

@param   cTab				Tabela do registro a ser atualizado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSRefsh(cTab)

Local nRecno := 0			// Numero do recno

Default cTab := ""

If !Empty(cTab)
	nRecno := (cTab)->(RecNo())
	(cTab)->(DbSkip())
	(cTab)->(DbGoto(nRecno))
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSDeleteSale
Realiza a deleção do SL1, SL2 e SL4 e SE5

@param   cNumSale				Numero da Venda
@param   lDelChange			Define se deleta SE5 (Troco para localizações)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se deletou venda	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSDeleteSale( cNumSale , lDelChange, cNumOrig )

Local lRet			:= .T.						// Retorna se deletou venda
Local aArea 		:= GetArea()				// Armazena Area corrente
Local aAreaSL1 		:= SL1->(GetArea())			// Armazena Area SL1
Local lCancVenda	:= .T.
Local lUseSat		:= STFGetCfg("lUseSAT", .F.)// Utiliza SAT
Local lMobile		:= STFGetCfg("lMobile", .F.)// Utiliza SAT
Local lCancPdvOn	:= .F.

Default cNumSale  	:= ""
Default lDelChange	:= .F.
Default cNumOrig  	:= ""

If ValType(lMobile) <> "L"
	lMobile := .F.
EndIf

/*
Indica que a venda deverá ser cancelada, porém no caso de uma NFC-e rejeitada,
ela deve ser subir para a retaguarda como uma venda normal, por isso não a cancelamos.
O flag (_STORC = "A") indica que ela deverá ser inutilizada pelo LjGrvBatch, 
por esse motivo ela não gera SLI e os campos ficarao dessa forma: L1_SITUA = 00 e L1_STORC = "A"	 
*/
If !lMobile
	If lPdvOn .And. (!Empty(cNumOrig) .Or. (STBIsImpOrc() .And. STBCSIsProgressSale()))
		lCancVenda 	:= .F.
		lCancPdvOn	:= .T. 
		If ExistFunc("STBDelItAS")  
			STBDelItAS()
		Endif
	Else
		lCancVenda := !( STBGetNFCE() .AND. STBCSIsProgressSale() .AND. !lUseSAT .AND. STDGPBasket("SL1","L1_SITUA") == '65' )
	EndIf
ElseIf STBGetNFCE() .AND. !STBCSIsProgressSale() .And. !lUseSat
	//nao cancela para a venda subir e cancelar no gravabatch (piloto PDV Mobile)
	lCancVenda := .F.
EndIf

LjGrvLog( "STDCSDeleteSale", "lCancVenda ",lCancVenda)

DbSelectArea("SL1")
DbSetOrder(1) //L1_FILIAL+L1_NUM
If DbSeek( xFilial("SL1") + cNumSale )
	If !RecLock( "SL1", .F. )
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

LjGrvLog( "STDCSDeleteSale", " Registro da SL1 lRet = ",lRet)

If lRet
	DbSelectArea("SL4")
	DbSetOrder(1)//L4_FILIAL+L4_NUM+L4_ORIGEM
	DbSeek(xFilial("SL4")+cNumSale)
	While ( ( SL4->L4_FILIAL + SL4->L4_NUM ) == ( xFilial("SL1") + cNumSale ) ) .AND. !EOF()
		If lCancVenda
			RecLock("SL4",.F.)
			SL4->( DbDelete() )
			MsUnlock()
		EndIf
		SL4->( DbSkip() )
	EndDo
	
	DbSelectArea("SL2")
	DbSetOrder(1)//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	DbSeek(xFilial("SL2") + cNumSale)
	While ( (SL2->L2_FILIAL + SL2->L2_NUM) == (xFilial("SL1") + cNumSale) ) .AND. !EOF()
		If lCancVenda
			RecLock("SL2", .F.)
			SL2->( DbDelete() )
			MsUnLock()
			LjGrvLog( "STDCSDeleteSale", "SL2 deletado",cNumSale)
		EndIf			
		SL2->( DbSkip() )
	EndDo

	If lDelChange
		DbSelectArea("SE5")
		DbSetOrder(2)//E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
		If DbSeek(xFilial("SE5") + "VL" + SL1->L1_SERIE + SL1->L1_DOC)	    	
			While !EOF() .AND.  ( xFilial("SE5") + "VL" + SE5->E5_PREFIXO + SE5->E5_NUMERO ) == ( xFilial("SE5") + "VL" + SL1->L1_SERIE + SL1->L1_DOC )
				If (Empty(SE5->E5_TIPO) 					.AND. ;
					SE5->E5_MOEDA == "TC" 				.AND. ;
					SE5->E5_RECPAG == "P" 				.AND. ;
				   (SE5->E5_CLIFOR == SL1->L1_CLIENTE)	.AND. ;
				   (SE5->E5_LOJA == SL1->L1_LOJA)		)
				   				   
					RecLock("SE5",.F.)
					DbDelete()
					MsUnLock()				
				EndIf
				DbSkip()
			EndDo
		EndIf
	EndIf

	DbSelectArea("SL1")
	RecLock("SL1", .F.)
	If lCancPdvOn .AND. !lCancVenda
		Replace SL1->L1_SITUA 	with ""
		Replace SL1->L1_STORC 	with ""
		Replace SL1->L1_DOC 	with ""
		Replace SL1->L1_SERIE 	with ""
		Replace SL1->L1_PDV 	with ""
		Replace SL1->L1_EMISNF 	with SToD("")
		Replace SL1->L1_OPERADO	with ""
		Replace SL1->L1_NUMORIG	with ""
		Replace SL1->L1_NUMMOV	with ""
		Replace SL1->L1_TPORC	with ""
	Else
		If lCancVenda
			Replace SL1->L1_SITUA with "07"
			SL1->( DbDelete() )
		Else			
			Replace SL1->L1_SITUA with "00"
			Replace SL1->L1_STORC with "A"			
		EndIf
	EndIf
	SL1->( MsUnLock() )

EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return  lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSGiftVoucher
Busca Vale Presentes a serem estornados

@param   cNumSale				Numero da Venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet				Retorna info do vale presente utilizado

@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSGiftVoucher( cNumsale )

Local aRet			:= {}					// Retorna VPs a serem estornados
Local aArea 			:= GetArea()			// Armazena Area corrente

Default cNumSale  	:= ""

ParamType 0 Var  cNumSale 	As Character	 Default ""

// Busca se foi utilizado VP na venda como forma de pagamento
DbSelectArea("SL4")
DbSetOrder(1)//L4_FILIAL+L4_NUM+L4_ORIGEM
If DbSeek(xFilial("SL4") + cNumsale) 
	While (!SL4->(EOF())) .AND. (SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + cNumsale)
		If AllTrim(SL4->L4_FORMA) == "VP"	
   			AADD(aRet,{AllTrim(SL4->L4_CODVP),"2"})
		EndIf
		DbSkip()
	EndDo
EndIf

// Busca se foi vendido algum VP na venda
DbSelectArea("SL2")
DbSetOrder(1)//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
If DbSeek(xFilial("SL2") + cNumsale) 
	While !SL2->(Eof()) .AND. (SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + cNumsale)
		If SL2->(FieldPos("L2_VALEPRE")) > 0 .AND. !Empty(SL2->L2_VALEPRE)
   			AADD(aRet,{AllTrim(SL2->L2_VALEPRE),"1"})
		EndIf
		DbSkip()
	EndDo
EndIf

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSTotalSale
Busca o total da venda a ser cancelada

@param   cNumSale			Numero da Venda(L1_NUM)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  nTotalSale			Retorna o valor total da venda

@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSTotalSale(cNumSale)

Local nTotalSale		:= 0					// Retorna o valor total da venda
Local aArea 			:= GetArea()			// Armazena Area corrente
Local aAreaSL1 			:= SL1->(GetArea())		// Armazena Area SL1

Default cNumSale  	:= ""

ParamType 0 Var  cNumSale 		As Character	 Default ""

DbSelectArea("SL1")
DbSetOrder(1) //L1_FILIAL+L1_NUM
If SL1->(DbSeek(xFilial("SL1") + cNumSale))
	nTotalSale := SL1->L1_VLRTOT
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return nTotalSale


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCSRequestCancel
Busca informações para solicitação de cancelamento

@param   cNumSale		Numero da Venda(L1_NUM)
@param 	  lCancVenc 	Cancela vendas vencidas 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRequest			Retorna se realizou a solicitação de cancelamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSRequestCancel( cNumSale , lCancVenc, cNFisCanc )

Local lRet				:= .T.						// Retorna se realizou a solicitação de cancelamento
Local aArea				:= GetArea()				// Armazena area corrente
Local aAreaSL1			:= SL1->(GetArea())			// Armazena Area SL
Local aSL1				:= {}						// Array Gravação SL1
Local cLiMsg 			:= ""						// Msg SLI para cancelamento
Local cStation			:= ""						// SLI_Estacao
Local cPAFMD5			:= ""
Local lFirst			:= .F. 						// Integra com First?
Local cIntegration		:= "DEFAULT" 				// Tipo de Integração
Local lConfStatus		:= .F.						// Valida se populou SL1 atualizando STORC
Local cAliasAtu			:= ""	
Local lUseSat			:= STFGetCfg("lUseSAT", .F.)//Utiliza SAT			
Local lCentPDV			:= LjGetCPDV()[1]			//Server é Central de Pdv - 

Default cNumSale  		:= ""
Default lCancVenc   	:= .F.
Default cNFisCanc		:= ""

If Findfunction("STFCfgIntegration")
	cIntegration := STFCfgIntegration()
ElseIf SuperGetMv("MV_LJRMS",,.F.)
	cIntegration := "RMS"	
EndIf

lFirst := cIntegration == "FIRST"

//Por seguranca, valida se SL1 está posicionado na venda que sera cancelada
If xFilial("SL1") + cNumSale <> SL1->L1_FILIAL + SL1->L1_NUM 
	LjGrvLog( cNumSale,"Venda nao estava posicionada, sera realizado Seek para posicionar. L1_NUM atual:",SL1->L1_NUM )
	
	//armazena o Alias corrente
	cAliasAtu := Alias()

	DbSelectArea("SL1")
	SL1->( DbSetOrder(1) )
	lRet := SL1->( DbSeek(xFilial("SL1") + cNumSale) )
	aAreaSL1 := SL1->( GetArea() )

	//se o Alias for SL1, entao pegamos a Area novamente, pois a restauracao posicionaria ele no registro errado
	If cAliasAtu == "SL1"
		aArea := aClone(aAreaSL1)
	EndIf 

	LjGrvLog( cNumSale,"Apos Seek para posicionar. L1_NUM atual:",SL1->L1_NUM )
EndIf
                 
If lRet
	
	LjGrvLog( cNumSale,"Situacao atual da venda, no momento do cancelamento :",SL1->L1_SITUA )  //Gera LOG
		
	If !lFirst	
		If !Empty(cNFisCanc) .AND. !(lPdvOn .AND. lCentPDV .AND. lUseSat) //Acrescentado a serie para que o cancelamento ocorra na nota certa
			cLiMsg := SL1->L1_NUMORIG + "|" + SL1->L1_DOC + "|" + SL1->L1_PDV + "|" + cNFisCanc + Iif (lPdvOn, "| |" + SL1->L1_NUM, "")
		Else			
			If!Empty(SL1->L1_SERRPS) .AND. !Empty(SL1->L1_DOCRPS) //Cancelamento de Venda com RPS
				cLiMsg := SL1->L1_NUMORIG + "|" + SL1->L1_DOC + "|" + SL1->L1_PDV + "| |" + SL1->L1_SERRPS + "|" + SL1->L1_NUM   	
			Else 	
				cLiMsg := SL1->L1_NUMORIG + "|" + SL1->L1_DOC + "|" + SL1->L1_PDV + "| |" + SL1->L1_SERIE 	+ Iif (lPdvOn, "|" + SL1->L1_NUM, "")
			Endif 
		EndIf			
	
		LjGrvLog( cNumSale,"Dados armazenados para cancelamento via SLI: ",cLiMsg )  //Gera LOG
		
		cStation := Space(TamSX3("LI_ESTACAO")[1])
		lRet := STFSLICreate(	cStation	, "CAN" , cLiMsg	, "NOVO" )
		
		//Se registro em uso, rotina STFSaveTab tem controle padrao para aguardar liberacao. Nao compromete o processo, quando cancelamento sobe, tambem atualiza o STORC
		//Cenario pouco provavel: Registro em uso nesse momento + retaguarda fora + fechamento de caixa. Impacto: Venda será considerada no movimento do caixa.
		If !lPdvOn .OR. (lPdvOn .AND. lCentPDV .AND. lUseSat)
			aSL1 := {{"L1_STORC" , "C"}} //Atualiza STORC, Situa sera atualizado no STDUPDATA quando subir o cancelamento
			lConfStatus := STFSaveTab( "SL1" , aSL1 )	  
			LjGrvLog( cNumSale,"Atualização Statua(L1_STORC):",lConfStatus )  //Gera LOG
		Endif 		
	Else
		LjGrvLog( cNumSale,"Habilitado Integracao com FIRST(MV_LJRETIN)",cLiMsg )  //Gera LOG
	
		aSL1 := {{"L1_SITUA" , "C0"}}	//C0 - Solicitado o cancelamento de cupom enviado
		STFSaveTab( "SL1" , aSL1 )
	
		//Atualiza MD5(hash) utilizado no PAF-ECF para identificar alteracao de registro 
		If STBIsPaf() .AND. SL1->(FieldPos("L1_PAFMD5")) > 0
			cPAFMD5 := STBPAFMD5("SL1")
			aSL1 := {{"L1_PAFMD5",	cPAFMD5}}
			lRet := STFSaveTab( "SL1" , aSL1 )
		EndIf
		EndIf
		
	EndIf

LjGrvLog( cNumSale,"Retorno do cancelamento ",lRet )  //Gera LOG

RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDCSShopCard
Tratamento para Cancelamento Shop Card

@param   cNumSale					Numero da Venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STDCSShopCard( cNumSale )
Local aArea				:= GetArea()
Local aParam			:= {}			// 

Default cNumSale  		:= ""

ParamType 0 Var  cNumSale 	As Character	 Default ""  

If lLjcFid .AND. !Empty(cNumSale)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Cartão Fidelidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjcFid			
		DbSelectArea("SL1")
		SL1->(DbSetOrder())
		SL1->(DbSeek(xFilial("SL1")+cNumSale))
				
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))
		If DbSeek(xFilial("SL2")+cNumSale) 
			While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+cNumSale)				
				If STBAvalShopCard(SL2->L2_PRODUTO) .AND. !Empty(SL2->L2_NUMCFID) .AND. !Empty(SL2->L2_DTSDFID) .AND. (SL2->L2_VLRCFID > 0)	
					aParam := {SL2->L2_NUMCFID,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,"4"}			 	
		 	   		//Cancelamento de venda de recarga de cartao fidelidade
		 	   		If STBRemoteExecute("CA280ESLD" ,aParam, NIL,.T.	,@uResult)
		 	   			If ValType(uResult) == "L" .AND. !uResult
		 	   				aSL1 := {{"L1_SITUA",	"00"}}				// Retira a solicitação de cancelamento
							STFSaveTab( "SL1" , aSL1 )					// Salva na tabela a alteracao
		 	   			EndIf
		 	   		Else
		 	   			// TO DO: Gerar contingencia
		 	   		EndIf
		 			Exit
		 		EndIf
		 		SL2->(DbSkip())
		 	End
		 EndIf
		 
 		//Cancelamento de venda com forma de pagamamento FID - Cartao fidelidade
		DbSelectArea("SL4")				 		
		DbSetOrder (1)
		If DbSeek (xFilial("SL4")+cNumSale)
			While SL4->(!Eof()) .AND. SL4->L4_NUM == cNumSale
				If Alltrim(SL4->L4_FORMA) == "FID"							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
					//³Se a venda foi paga com cartao fidelidade, entao o ³
					//³movimento de saida sera estornado da tabela MBN    ³
					//³e o valor devolvido ao respectivo saldo.           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aParam := {SL2->L2_NUMCFID,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,"3"}
					If STBRemoteExecute("CA280ESLD" ,aParam, NIL,.T.	,@uResult)
						If ValType(uResult) == "L" .AND. !uResult
							aSL1 := {{"L1_SITUA",	"00"}}				// Retira a solicitação de cancelamento
							STFSaveTab( "SL1" , aSL1 )					// Salva na tabela a alteracao
						EndIf
					Else
						// TO DO: Gerar contingencia
					EndIf					
 					Exit
 				EndIf 
 				SL4->(DbSkip())							
			End						
		EndIf					
	EndIf
EndIf	

RestArea(aArea)		

Return 

//-------------------------------------------------------------------
/*{Protheus.doc} STDLogCanc
Apos cancelamento do cupom grava SLX
A gravacao da SLX no Totvs Pdv foi feita devido a integracao com a RMS

@param   
@author  Varejo
@version P11.8
@since   29/07/2014
@return
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STDLogCanc(lIsItem	,	nItem	, cSuper	, lImportSale,;
 					lDocNf	,	lCancCF	)
Local lRet			:= .T. 						//Variavel de retorno
Local lLX_SITTRI	:= SLX->(ColumnPos("LX_SITTRIB")) > 0
Local lSTBIsPAF		:= STBIsPAF()
Local lVendaRecup	:= ExistFunc("STWRSVerRe") .And. STWRSVerRe()
Local cPdv			:= STFGetStat( "PDV" )		//Codigo da estacao
Local cCaixa		:= xNumCaixa()				//Codigo do caixa
Local cSerie		:= STFGetStat( "Serie" )	//Serie
Local aInfCan		:= STIGetCancel()			//Informacoes do cancelamento
Local aArea			:= {}
Local oModelCesta	:= STDGPBModel()			//Model da cesta
Local cSupervisor	:= "" 						// Supervisor
Local nI			:= 0
Local cSerNf		:= ""						//Armazena a serie nao fiscal
Local cAux			:= ""
Local cItem			:= ""
Local cDoc			:= ""
Local cFilSLX		:= ""
Local cLXItem		:= ""
Local lFoundSLX		:= .F.
Local cSerNFe		:= PadR( GetNewPar("MV_LOJANF",""), len(cSerie) ) //Ajuste para NFe
Local lEmitNfce		:= Iif(FindFunction("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e
Local lCancRPS		:= .F. 						// Cancelamento de venda somente RPS

Default lIsItem 	:= .F.
Default nItem		:= 0 
Default cSuper		:= ""
Default lImportSale := .F.						//Controla se houve importação de orçamento.
Default lDocNf		:= .F.
Default lCancCF		:= .F.

If !(lImportSale .AND. lSTBIsPAF)				//Se for orçamento importado e ambiente PAF, não pede a autorização novamente.
	If Empty(cSuper)
		cSupervisor 	:= STFProFile(7)[2] 	// Supervisor, aqui chamara a tela de supervisor
	Else
		cSupervisor 	:= cSuper 				// Supervisor vindo da rotina STWItemCancel.Protecao para nao chamar a tela supervisor duas vezes
	EndIf	
Endif

Aadd(aArea,GetArea())
DbSelectArea("SLX")
Aadd(aArea,SLX->(GetArea()))
Aadd(aArea,SL2->(GetArea()))
Aadd(aArea,SL1->(GetArea()))

//Cancelamento Item
If lIsItem
	
	oModelCesta := oModelCesta:GetModel("SL2DETAIL")
	oModelCesta:GoLine(nItem)
	
	cSerie 	:= IIF(!lDocNf,Iif( cSerie <> cSerNFe,cSerie, cSerNFe ),cSerNf)

	If lSTBIsPAF
		cDoc  := Right(SL1->L1_DOC, TamSX3("LX_CUPOM")[1])
	Else
		cDoc 	:= PadL( Iif( lEmitNFCE .AND. Empty(AllTrim(SL1->L1_DOC)), oModelCesta:GetValue("L2_DOC"), AllTrim(SL1->L1_DOC)), TamSX3("LX_CUPOM")[1] , "0" )
		cDoc 	:= STDTrataDoc( PADR(cPDV,TamSX3("LX_PDV")[1]) + PADR(cDoc,TamSX3("LX_CUPOM")[1]) + PADR(cSerie,TamSX3("LX_SERIE")[1]) + PADR(oModelCesta:GetValue("L2_ITEM"),TamSX3("LX_ITEM")[1]) + SubStr(Time(),1,5) ,cDoc) 
	Endif 

	SLX->(RecLock("SLX", .T.))
	REPLACE SLX->LX_FILIAL  WITH xFilial("SLX")
	REPLACE SLX->LX_PDV     WITH cPDV
	REPLACE SLX->LX_OPERADO WITH cCaixa 
	REPLACE SLX->LX_DTMOVTO WITH dDatabase
	REPLACE SLX->LX_HORA    WITH Time()
		
	//Tratamento para Totvs PDV com NFe					 			
	REPLACE SLX->LX_SERIE   WITH cSerie
							 			
	REPLACE SLX->LX_CUPOM   WITH cDoc
	REPLACE SLX->LX_ITEM    WITH oModelCesta:GetValue("L2_ITEM")
	REPLACE SLX->LX_TPCANC  WITH "I"
	
	If SLX->(ColumnPos("LX_VRUNIT")) > 0
		REPLACE SLX->LX_VRUNIT  WITH oModelCesta:GetValue("L2_VRUNIT")
	EndIf
	
	REPLACE SLX->LX_VALOR   WITH oModelCesta:GetValue("L2_VLRITEM") + oModelCesta:GetValue("L2_VALDESC")
	REPLACE SLX->LX_PRODUTO WITH oModelCesta:GetValue("L2_PRODUTO")
	REPLACE SLX->LX_QTDE    WITH oModelCesta:GetValue("L2_QUANT")
	REPLACE SLX->LX_SUPERVI WITH cSupervisor
	REPLACE SLX->LX_SITUA 	WITH "00"

	If SLX->(ColumnPos("LX_PRCTAB")) > 0
		REPLACE SLX->LX_PRCTAB 	WITH oModelCesta:GetValue("L2_PRCTAB")
	EndIf
	
	If lSTBIsPAF
		REPLACE SLX->LX_CONTDOC WITH STBRetCoD()
	EndIf
	    		
	cAux := AllTrim(oModelCesta:GetValue("L2_SITTRIB"))
	If !Empty(cAux) .And. Substr(cAux,1,1) == "T" //somente grava se for aliquota de ICMS
		REPLACE SLX->LX_ALIQICM WITH Val(Substr(cAux,2,Len(cAux)))/100
	EndIf
	
	If lLX_SITTRI
		REPLACE SLX->LX_SITTRIB WITH cAux
	EndIf
	
	REPLACE SLX->LX_DESCON 	WITH oModelCesta:GetValue("L2_VALDESC")

	SLX->(MsUnlock())

	// Seto o numero do registro da SLX no item da SL2
	If oModelCesta:HasField("L2_REGSLX")
		STDSPBasket( "SL2" , "L2_REGSLX" ,  SLX->(Recno()))
	Endif	
Else //Cancelamento Cupom
	
	oModelCesta := oModelCesta:GetModel("SL2DETAIL")
	//Se houverem itens na cesta, cancelamento de cupom aberto
	If oModelCesta:Length() > 0 .And. !Empty(oModelCesta:GetValue("L2_PRODUTO"))
		
		//Quando PAF-ECF e cancelamento de venda no meio da venda
		//esta duplicando caso o registro ja tenha sido cancelado
		If lCancCF
			//Como abaixo serão criados todos os itens de novo, eu apago caso já exista algum
			SLX->(DbSetOrder( 1 )) 	//LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM
			
			cAux := xFilial("SLX") + PadR(cPDV, TamSX3("LX_PDV")[1]) + ;
						PadR(AllTrim(SL1->L1_DOC), TamSX3("LX_CUPOM")[1]) + PadR(cSerie, TamSX3("LX_SERIE")[1])
	
			If SLX->(DbSeek(cAux))
				While !SLX->(Eof()) .And. SLX->(LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE) == cAux
				 	IF !(AllTrim(SLX->LX_ITEM) == "00")
				 		RecLock("SLX",.F.)
						SLX->(DbDelete())
						SLX->(MsUnlocK())
				 	EndIf
				 	SLX->(DbSkip())
				End
			EndIf
		EndIf
		
		For nI := 1 To oModelCesta:Length()
			oModelCesta:GoLine(nI)																 									
			
			cItem := oModelCesta:GetValue("L2_ITEM")
			cDoc  := Right(SL1->L1_DOC, TamSX3("LX_CUPOM")[1])
			
			SLX->(DbSetOrder(1)) //LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, LX_ITEM, LX_HORA
			
			/*
			Valido se é uma venda recuperada pois se efetuo um cancelamento do ultimo
			cupom e houve itens cancelados eu devo considerar todos os itens novos pois
			há um reordenamento do numero do item
			*/
			If lVendaRecup .And. SLX->(DbSeek(xFilial("SLX") + cPDV + cDoc + cSerie + cItem))
				//-- Essa situação é um item cancelado de um cupom cancelado que existe na SL2 e SLX
				If SLX->LX_TPCANC == "I"
					LjGrvLog( NIL, "Item [" + AllTrim(cItem) + "] já foi gravado na SLX [Num. Doc:" + AllTrim(cDoc) + ;
							"] com cancelamento de item - não sera gravado no cancelamento total")
				Else
					SLX->(RecLock("SLX", .F.))
					REPLACE SLX->LX_TPCANC  WITH "A" //Insiro "A" para que não seja acumulado duas vezes no XML do PAF
					SLX->(MsUnlock())
				EndIf
			Else
				SLX->(RecLock("SLX", .T.))
				REPLACE SLX->LX_FILIAL  WITH xFilial("SLX")
				REPLACE SLX->LX_PDV     WITH cPDV
				REPLACE SLX->LX_OPERADO WITH cCaixa 
				REPLACE SLX->LX_DTMOVTO WITH dDatabase
				REPLACE SLX->LX_HORA    WITH Time()
				
				//Tratamento para Totvs PDV com NFe
				REPLACE SLX->LX_SERIE   WITH IIF(!lDocNf,;
												iif( cSerie <> cSerNFe,cSerie, GetMV("MV_LOJANF") ),;
												cSerNf)
	
				REPLACE SLX->LX_CUPOM   WITH cDoc	
				REPLACE SLX->LX_ITEM    WITH cItem
				REPLACE SLX->LX_TPCANC  WITH "A"	
				REPLACE SLX->LX_VRUNIT  WITH oModelCesta:GetValue("L2_VRUNIT")
				REPLACE SLX->LX_VALOR   WITH oModelCesta:GetValue("L2_VLRITEM") + oModelCesta:GetValue("L2_VALDESC")
				REPLACE SLX->LX_PRODUTO WITH oModelCesta:GetValue("L2_PRODUTO")
				REPLACE SLX->LX_QTDE    WITH oModelCesta:GetValue("L2_QUANT")
				REPLACE SLX->LX_SUPERVI WITH cSupervisor
				REPLACE SLX->LX_SITUA WITH "00"
				If SLX->(ColumnPos("LX_PRCTAB")) > 0
					REPLACE SLX->LX_PRCTAB 	WITH oModelCesta:GetValue("L2_PRCTAB")
				EndIf
				
				If lSTBIsPAF
		    		REPLACE SLX->LX_CONTDOC WITH STBRetCoD()
		    	EndIf
				
				cAux := AllTrim(oModelCesta:GetValue("L2_SITTRIB"))
				If !Empty(cAux) .And. Substr(cAux,1,1) == "T" //somente grava se for aliquota de ICMS
					REPLACE SLX->LX_ALIQICM WITH Val(Substr(cAux,2,Len(cAux)))/100
				EndIf
				
				If lLX_SITTRI
					REPLACE SLX->LX_SITTRIB WITH cAux
				EndIf
				
				REPLACE SLX->LX_DESCON 	WITH oModelCesta:GetValue("L2_VALDESC")
	
				SLX->(MsUnlock())
			EndIf
		Next nI
	Else
		//Cancelamento de cupom encerrado
		SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
		SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))

		If lDocNf
			If !Empty(SL1->L1_DOCRPS) .AND. !Empty(SL1->L1_SERRPS) //Cancelamento RPS
				cSerNf := SL1->L1_SERRPS
				lCancRPS:= .T. 
			Else 
				cSerNf := PadR( STFGetStation("SERNFIS"), SL1->(TamSx3("L1_SERPED"))[1] )
			Endif 
		Elseif SL1->L1_IMPNF .AND. !Empty(cSerNFe) 
			cSerie := PadR(cSerNFe, len(SL1->L1_SERIE))
		EndIf

		cFilSLX := xFilial("SLX")
		While SL2->(!EOF()) .And. SL2->L2_FILIAL == SL1->L1_FILIAL .And. SL2->L2_NUM == SL1->L1_NUM

			SLX->(DbSetOrder(1)) //LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, LX_ITEM, LX_HORA
			/*
			Valido se é uma venda recuperada pois se efetuo um cancelamento do ultimo
			cupom e houve itens cancelados eu devo considerar todos os itens novos pois
			há um reordenamento do numero do item
			*/
			If lVendaRecup .And. SLX->(DbSeek(cFilSLX + SL2->L2_PDV + SL2->L2_DOC + SL2->L2_SERIE + SL2->L2_ITEM))
				//-- Essa situação é um item cancelado de um cupom cancelado que existe na SL2 e SLX
				If SLX->LX_TPCANC == "I"
					LjGrvLog( NIL, "Item [" + AllTrim(SL2->L2_ITEM) + "] já foi gravado na SLX [Num. Doc:" + AllTrim(SL2->L2_DOC) +;
					 			"] com cancelamento de item - não sera gravado no cancelamento total")
				Else
					SLX->(RecLock("SLX", .F.))
					REPLACE SLX->LX_TPCANC  WITH "A" //Insiro "A" para que não seja acumulado duas vezes no XML do PAF
					SLX->(MsUnlock())
				EndIf
			Else
				
				/*Ajuste para o SQLite:
				- quando se tem um deletado e um item vendido o L2_ITEM muda e
				com isso ao cancelar a venda em cupom finalizado deve-se alterar
				o LX_ITEM para evitar erro de chave duplicada aqui na SLX*/
				nI := 0
				cLXItem := ""
				lFoundSLX := SLX->(DbSeek(cFilSLX + SL2->L2_PDV + SL2->L2_DOC + SL2->L2_SERIE + SL2->L2_ITEM)) 
				While lFoundSLX
					nI += 1
			
					If Len(AllTrim(Str(nI))) == 1
						cLXItem := '0' + AllTrim(Str(nI))
					Else
						cLXItem := AllTrim(Str(nI))
					EndIf			
					
					If Val(cLXItem) > 99
						cLXItem := STBPegaIT(Val(cLXItem))
					EndIf
					
					cLXItem := AllTrim(cLXItem)
					lFoundSLX := SLX->(DbSeek(cFilSLX + SL2->L2_PDV + SL2->L2_DOC + SL2->L2_SERIE + PadR(cLXItem,TamSX3("L2_ITEM")[1])))
				End
				
				SLX->(RecLock("SLX", .T.))
				REPLACE SLX->LX_FILIAL  WITH xFilial("SLX")
				REPLACE SLX->LX_PDV     WITH cPDV
				REPLACE SLX->LX_OPERADO WITH cCaixa 
				REPLACE SLX->LX_DTMOVTO WITH dDatabase
				REPLACE SLX->LX_HORA    WITH Time()
				REPLACE SLX->LX_SERIE   WITH IIF(!lDocNf, cSerie, cSerNf)
				REPLACE SLX->LX_CUPOM   WITH IIF(!lDocNf, Right(SL1->L1_DOC, TamSX3("LX_CUPOM")[1]), Iif(lCancRPS, SL1->L1_DOCRPS, Right(STDGetDocP(), TamSX3("LX_CUPOM")[1])) ) 	
				REPLACE SLX->LX_ITEM    WITH IIF(Empty(cLXItem),SL2->L2_ITEM,cLXItem)
				REPLACE SLX->LX_TPCANC  WITH "A"	
				REPLACE SLX->LX_VRUNIT  WITH SL2->L2_VRUNIT
				IF lSTBIsPAF
					REPLACE SLX->LX_VALOR   WITH SL2->L2_VLRITEM + SL2->L2_VALDESC + SL2->L2_DESCPRO 
				Else
					REPLACE SLX->LX_VALOR   WITH SL2->L2_VLRITEM + SL2->L2_VALDESC
				EndIf
				REPLACE SLX->LX_PRODUTO WITH SL2->L2_PRODUTO
				REPLACE SLX->LX_QTDE    WITH SL2->L2_QUANT
				
				If ValType(aInfCan) == "A" .AND. Len(aInfCan) > 0
					REPLACE SLX->LX_SUPERVI WITH aInfCan[3]
				EndIf
				
				REPLACE SLX->LX_SITUA WITH "00"
				
				If SLX->(ColumnPos("LX_PRCTAB")) > 0
					REPLACE SLX->LX_PRCTAB 	WITH SL2->L2_PRCTAB
				EndIf
				
				If lSTBIsPAF
		    		REPLACE SLX->LX_CONTDOC WITH STBRetCoD()
		    	EndIf
		    	
				cAux := AllTrim(SL2->L2_SITTRIB)
				If !Empty(cAux) .And. Substr(cAux,1,1) == "T" //somente grava se for aliquota de ICMS
					REPLACE SLX->LX_ALIQICM WITH Val(Substr(cAux,2,Len(cAux)))/100
				EndIf
				
				If lLX_SITTRI
					REPLACE SLX->LX_SITTRIB WITH cAux
				EndIf
				
				If lSTBIsPAF
					REPLACE SLX->LX_DESCON 	WITH SL2->L2_VALDESC + SL2->L2_DESCPRO
				Else
					REPLACE SLX->LX_DESCON 	WITH SL2->L2_VALDESC 
				Endif 
				
				SLX->(MsUnlock())
			EndIf
			
			SL2->(dbSkip())
		EndDo
	EndIf		
EndIf

For nI:=1 to Len(aArea)
	RestArea(aArea[nI])
Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSitDoc
Retorna o L1_SITUA a partir do L1_SERIE + L1_DOC + L1_PDV

@param   cSerie			Numero de Série
@param   cNumDoc		Numero do Documento Fiscal
@param   cPDV			Numero do PDV
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cSitua			Campo L1_SITUA da venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSitDoc( cNumSerie, cNumDoc, cPDV, lDocNf, lDocRPS, cL1Num )

Local aArea 		:= GetArea()			// Armazena Area corrente
Local aAreaSL1 		:= SL1->(GetArea())		// Armazena Area SL1
Local aRet			:= {}
Local cDocNf		:= "" //Documento nao fiscal
Local cSerNf		:= "" //Serie nao fiscal

Default cNumSerie 	:= ""
Default cNumDoc 	:= ""
Default cPDV 		:= ""
Default lDocNf 		:= .F.
Default lDocRPS 	:= .F.
Default cL1Num		:= ""


If !lDocNf
	If lDocRPS //Cancelamento RPS
		cL1Num := PadR( cL1Num, SL1->(TamSx3("L1_NUM"))[1] )
		aRet := GetAdvFVal(	"SL1", {"L1_SITUA", "L1_STORC"}, (xFilial("SL1")+cL1Num), 1, {"404", ""}, .T. )
	Else 
		IF lPdvOn .AND. !Empty(cL1Num )//Cancelamento NFC-e do PDV Online
			cL1Num := PadR( cL1Num, SL1->(TamSx3("L1_NUM"))[1] )
			aRet := GetAdvFVal(	"SL1", {"L1_SITUA", "L1_STORC"}, (xFilial("SL1")+cL1Num), 1, {"404", ""}, .T. )
		Else 
			cNumSerie	:= PadR( cNumSerie	, SL1->(TamSx3("L1_SERIE"))[1] )
			cNumDoc	  	:= PadR( cNumDoc	, SL1->(TamSx3("L1_DOC")  )[1] )
			cPDV		:= Padr( cPDV		, SL1->(TamSx3("L1_PDV")  )[1] )
			//o ultimo parametro indica se deve usar o valor default (penultimo parametro) caso nao encontre o registro (nao documento no TDN)
			aRet := GetAdvFVal(	"SL1", {"L1_SITUA", "L1_STORC"}, (xFilial("SL1")+cNumSerie+cNumDoc+cPDV), 2, {"404", ""}, .T. )
		Endif 
	Endif 
Else
	cDocNf := PadR( cNumDoc, SL1->(TamSx3("L1_DOCPED"))[1] )
	cSerNf := PadR( STFGetStation("SERNFIS"), SL1->(TamSx3("L1_SERPED"))[1] )
	aRet := GetAdvFVal(	"SL1", {"L1_SITUA", "L1_STORC"}, (xFilial("SL1")+cSerNf+cDocNf), 11, {"404", ""}, .T. )
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCancTef
Verifica se existe transação TEF ou em POS para cancelar a venda

@param   cLastNum		Numero do orçamento
@author  Varejo
@version P11.8
@since   22/10/2015
@return  lRet			.T.->Venda com TEF/POS/ .F.->Venda sem TEF/POS
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCancTef(cLastNum,lTemCCCD,lTemPD)
Local lRet		:= .F.
Local aSl4Ord	:= {}
Local lCmpsIdTRN	:= SL4->(ColumnPos("L4_TRNID")) > 0 .And. SL4->(ColumnPos("L4_TRNPCID")) > 0 .And. SL4->(ColumnPos("L4_TRNEXID")) > 0 //Verifica se existem os campos que guardam os IDs das transações TEF

Default lTemCCCD := .F.
Default lTemPD   := .F.

If AllTrim(STDCSLastSale("L1_SITUA")) <> "07" 
	
	aSl4Ord	:= SL4->(GetArea())
	
	SL4->(DbSetOrder(1))
	If SL4->(DbSeek(xFilial("SL4") + cLastNum))			
		While !SL4->(Eof()) .AND. AllTrim(SL4->L4_FILIAL)+AllTrim(SL4->L4_NUM) == AllTrim(xFilial("SL4"))+AllTrim(cLastNum)
			
			If (Alltrim(SL4->L4_FORMA) == "CC" .OR. Alltrim(SL4->L4_FORMA) == "CD") .And. ( ( !Empty(SL4->L4_DOCTEF) .And. !Empty(SL4->L4_HORATEF) ) .Or. (lCmpsIdTRN .AND. !Empty(SL4->L4_TRNPCID)))		
				lTemCCCD := .T.
			Endif

			If Alltrim(SL4->L4_FORMA) $ "PD/PIX"
				lTemPD := .T.
			Endif 

			SL4->(DbSkip())
		Enddo
	EndIf

	RestArea(aSl4Ord)
	
EndIf

lRet :=  lTemCCCD .Or. lTemPD

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDLastSat
Busca Numero do Ultimo Orçamento SAT

@param   cRetField - Nome do campo no dicionario de dados da tabela SL1
@author  Varejo
@version P11.8
@since   02/12/2015
@return  cNumSale - Retorna o Numero ou outro campo da tabela SL1 da Ultima Venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDLastSat(cRetField, cRetSerie)

Local cNumSale		:= ""									  // Retorna o Numero da Ultima Venda ou o campo do parametro

Default cRetField	:= "L1_NUM"
Default cRetSerie	:= Nil 			//Tratamento por conta da NFe

// Posiciona o SL1 na ultima venda
DbSelectArea("SL1")

If lPdvOn
	cNumSale := STDLastPdvOn(cRetField, @cRetSerie)
Else
	SL1->( DbSetOrder(1) ) //L1_FILIAL+L1_NUM	
	If SL1->( DbSeek(xFilial("SL1")) )
		SL1->(DbGoBottom()) 
	
		//Macrosubstituicao consome muito recurso
		cNumSale := SL1->( FieldGet( ColumnPos(cRetField) ) )

		//Tratamento por conta da NFe
		if cRetSerie <> Nil
			cRetSerie := SL1->L1_SERIE
		endif
	EndIf
EndIf

Return cNumSale

/*/{Protheus.doc} STDDelPay
Reseta e/ou apaga os pagamentos ja realizados no BD
@type		function
@param		cNumSale, caracter, numero do orcamento
@author  	Varejo
@version 	P12
@since   	14/10/2016
@return  	logico, os pagamentos foram resetados/excluidos da BD
/*/
Function STDDelPay(cNumSale)

Local cL4Origem	:= Space( TamSX3("L4_ORIGEM")[1] )
Local lRet		:= .F.				//indica se excluiu algum pagamento
Local lExcNCC	:= .F.				//indica se zerou o campo L1_CREDITO (NCC)
Local lExcSL4	:= .F.				//indica se excluiu algum pagamento presente na SL4
Local aSL1Area	:= SL1->(GetArea())	//armazena a area da SL1
Local aSL4Area	:= SL4->(GetArea())	//armazena a area da SL4
Local aArea		:= GetArea()		//armazena a area corrente

Default cNumSale := "" 

DbSelectArea("SL1")
SL1->( DbSetOrder(1) )	//L4_FILIAL + L4_NUM
If SL1->( DbSeek(xFilial("SL1") + cNumSale) )
	If SL1->L1_CREDITO > 0
		RecLock("SL1",.F.)
		Replace SL1->L1_CREDITO with 0
		SL1->( MsUnlock() )
		
		lExcNCC := .T.
	EndIf
EndIf

DbSelectArea("SL4")
SL4->( DbSetOrder(1) )	//L4_FILIAL + L4_NUM + L4_ORIGEM
lExcSL4 := SL4->( DbSeek(xFilial("SL4") + cNumSale + cL4Origem) ) 
If lExcSL4
	While SL4->( !EoF() ) .AND. xFilial("SL4") + cNumSale + cL4Origem == SL4->L4_FILIAL + SL4->L4_NUM + SL4->L4_ORIGEM
		RecLock("SL4",.F.)
		SL4->( DbDelete() )
		SL4->( MsUnlock() )

		SL4->( DbSkip() )
	End
EndIf

RestArea(aSL1Area)
RestArea(aSL4Area)
RestArea(aArea)

//se excluiu a NCC ou os pagamentos da SL4
If lExcNCC .OR. lExcSL4
	lRet := .T.
Else
	LJGrvLog(cNumSale, "Nenhum pagamento (L1_CREDITO ou SL4) foi resetado")
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDAjstSLX
Função responsavel por ajustar o campo LX_CUPOM para os casos de
item cancelado ou cupom cancelado em ambiente que utilize impressora
nao-fiscal, no caso de NFC-e.

@param   
@author  Varejo
@version P12.17
@since   05/03/2018
@return
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STDAjstSLX(cNumDOC)
Local cPdv		:= STFGetStat( "PDV" )		//Codigo da estacao
Local cSerie	:= STFGetStat( "Serie" )	//Serie
Local nX 		:= 0
Local nTamCupom := TamSX3("LX_CUPOM")[1]
Local nTamPdv 	:= TamSX3("LX_PDV")[1]
Local aSlxArea  := SLX->(GetArea()) //armazena a area da tabela SLX
Local aArea		:= GetArea()		//armazena a area corrente
Local oModelCesta	:= STDGPBModel()			//Model da cesta

Default cNumDOC := ""

If !Empty(cNumDOC) .And. AllTrim(Upper(cNumDOC)) != "NFCE"

	oModelCesta := oModelCesta:GetModel("SL2DETAIL")
		
	For nX := 1 To oModelCesta:Length() 
		oModelCesta:GoLine(nX)																 									

		If oModelCesta:HasField("L2_REGSLX")
			If oModelCesta:GetValue('L2_REGSLX') > 0
				SLX->(DbGoTo(oModelCesta:GetValue('L2_REGSLX'))) //Posiciona no Registro a ser atualizado
		
				If AllTrim(Upper(SLX->LX_CUPOM)) == "NFCE"
					RecLock("SLX", .F.)
					SLX->LX_CUPOM := cNumDOC
					SLX->(MsUnLock())
				EndIf
			Endif	
		Endif
	Next nX

Else
	//Se nao foi passado o numero do DOC, entao os registros temporarios na SLX devem ser excluidos (Cujo DOC = "NFCe")
	DbSelectArea("SLX")
	SLX->( DbSetOrder(1) ) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
	While SLX->( DbSeek( xFilial("SLX")+PadR(cPdv,nTamPdv)+PadR("NFCE",nTamCupom)+cSerie ) )
		RecLock("SLX", .F.)
		SLX->(DbDelete())
		SLX->(MsUnLock())
	End
EndIf

RestArea(aSLxArea)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STDGetDocP()
Retorna o numero do Doc Ped caso seja uma venda de cupom nao fiscal (venda entrega/vale presente)

@param   
@author  Bruno Almeida
@version P12
@since   17/06/2019
@return  cDocPed -> Retorna o Doc Ped de uma venda nao fiscal
/*/
//------------------------------------------------------------------- 
Function STDGetDocP()
Return cDocPed

//-------------------------------------------------------------------
/*{Protheus.doc} STDUpdDocC()
Realiza a gravação dos campos (DOCCANC, DATCANC, HORCANC) referentes ao cancelamento do TEF.

@param   
@author  Lucas Novais (lnovais@)
@version P12+
@since   28/08/2020
@param cChave, Caracter, Chave para busca na tabela SL4
@param aDados, Array, Dados para gravação na SL4, array com a seguinte estrutura
	{
		{
			"Nome do campo",
			"Conteudo do campo"
		}
	}

@param aRecnos, Array, Recnos da SL4 ou SLV que devem ser atualizados com as informações passadas no array aDados.
@param cAliasTab, Caractere, Alias da tabela a ser atualizada (SL4 ou SLV).

@return  Null, Nulo
/*/
//------------------------------------------------------------------- 
Function STDUpdDocC(aDados,aRecnos,cAliasTab)
	Local nX 	:= 0
	Local nY	:= 0
	
	Default aDados 		:= {}
	Default aRecnos 	:= {}
	Default cAliasTab 	:= "SL4"
	
	If Len(aDados) > 0 .And. Len(aRecnos) > 0	
		DbSelectArea(cAliasTab)

		For nX:=1 To Len(aRecnos)
			(cAliasTab)->(DbGoTo(aRecnos[nX]))
			RecLock(cAliasTab,.F.)
			For nY:=1 To Len(aDados)
				&(aDados[nY][1]) := aDados[nY][2]
			Next nY
			(cAliasTab)->(MsUnLock())
		Next nX
	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STDTrataDoc()
Realiza o tratamento para o campo LX_CUPOM verificando o se ja existe a chave e caso exista inclua um sequencial no LX_CUPOM.

@author  Lucas Novais (lnovais@)
@version P12+
@since   18/09/2020
@param   cChave, Caracter, Chave para busca
@param   cDocEnt, Caracter, LX_CUPOM Sem tratamento
@return  cDocSai, Caracter, LX_CUPOM Tratado
/*/
//------------------------------------------------------------------- 

Static Function STDTrataDoc(cChave,cDocEnt)
	Local aSlxArea  := {} 
	Local aArea		:= {} 
	Local nX		:= 1
	Local cDocSai 	:= cDocEnt
	Local cDocAux	:= ""
	
	If  "NFCE" $ cDocEnt 
		aSlxArea  := SLX->(GetArea()) //armazena a area da tabela SLX
	    aArea	  := GetArea()	

		DbSelectArea("SLX")
		SLX->( DbSetOrder(1) ) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
		
		While SLX->(DbSeek(xFilial("SLX") + cChave)) .AND. nX <= 99999 // Maximo 99999
	
			nLenDoc := TamSX3("L1_DOC")[1] - 4
			
			cDocAux := STRZero(nX,nLenDoc) + "NFCE"
			cChave 	:= StrTran(cChave,cDocEnt,cDocAux)
			cDocEnt := cDocAux
			
			If SLX->(DbSeek(xFilial("SLX") + cChave))
				nX++
				Loop
			Else
				cDocSai := cDocEnt
				Exit
			EndIf  
	
		End

		RestArea(aSLxArea)
		RestArea(aArea)

	EndIf 

Return cDocSai

 
/*/{Protheus.doc} STDGtDocRPS
	Retorna o numero do DOCRPS
	@since 15/02/2023
	@author caio.okamoto
	@version 12.1.33
	@return cDocRPS, caractere, número do documento do RPS
	/*/
Function STDGtDocRPS()	
Return cDocRPS

/*/{Protheus.doc} STDGtSerRPS
	Retorna o numero do SERRPS
	@since 15/02/2023
	@author caio.okamoto
	@version 12.1.33
	@return cSerRPS, caractere, série do RPS
	/*/
Function STDGtSerRPS()	
Return cSerRPS

/*/{Protheus.doc} STDLastPdvOn
	Retorna a ultima numeração para cancelamento no TOTVS PDV on-line. 
	@author Jeferson Mondeki
	@since 19/05/2023
	@version 12.1.33
	@param cRetField, caracter, nome do campo
	@param cRetSerie, caracter, numero da serie
	@return return_cNumSale, caracter , Retorna a numeração da ultima venda
/*/
Function STDLastPdvOn(cRetField, cRetSerie)
Local cNumSale		:= ""																// Numeração que será retornado
Local cPdv			:= PadR(STFGetStation("PDV"), TamSX3("L1_PDV")[1])					// Numero do PDV
Local cAliasSL1 	:= GetNextAlias()													// Guarda a workarea corrente
Local aDados 		:= {}																// Guarda os dados da venda	
Local cRotina		:= ProcName(1)														// Informa a rotina que chamou
Local cQry 			:= ""																// Query para realizar a busca do ultimo orçamento na SL1 	
Local cSgbd 		:= Upper(AllTrim(TcGetDB()))										// Retorna o banco que está sendo utilizado  

Default cRetField	:= "L1_NUM"
Default cRetSerie	:= STFGetStation("SERIE") 											// Serie padrão da SLG

//Cria a query
cQry := "SELECT "

If cSgbd $ "MSSQL"
	cQry += "TOP 1 L1_FILIAL,L1_NUM,L1_SERIE,L1_DOC " 
Else
	cQry += "L1_FILIAL,L1_NUM,L1_SERIE,L1_DOC "
EndIf

cQry += "FROM " + RetSqlName("SL1") 
cQry += " WHERE "
cQry += " L1_FILIAL  = '" + xFilial("SL1") +"' "
cQry += " AND L1_PDV = '"+ cPdv +"' "
cQry += " AND D_E_L_E_T_ = ' ' "
cQry += " AND L1_SITUA NOT IN ('X0','X1','X2','X3', 'PR', 'FR') "
cQry += " AND (L1_DOC <> ' ' OR L1_DOCRPS<> ' ') "


Do Case
	Case cSgbd $ "MSSQL"
		cQry += "ORDER BY R_E_C_N_O_ DESC"
	Case cSgbd $ "POSTGRES"
		cQry += "ORDER BY R_E_C_N_O_ DESC LIMIT 1"
	Case cSgbd $ "ORACLE"
		cQry += "ORDER BY R_E_C_N_O_ DESC "
		cQry += "FETCH FIRST ROW ONLY"
EndCase

cQry := ChangeQuery(cQry)

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry),cAliasSL1,.T.,.F.)

If !(cAliasSL1)->(EOF()) 
	
	aAdd(aDados,{L1_NUM,L1_DOC,L1_SERIE})
	
	DbSelectArea("SL1")
	SL1->( DbSetOrder(1)) // L1_FILIAL+L1_NUM
	SL1->(DbSeek(xFilial("SL1")+aDados[1][1])) // Ultima numeração na SL1, posiciona na SL1 retornada da query

	If cRetField == "L1_NUM" .And. (cRotina == Upper("STDCSLastSale") .Or. cRotina == Upper("STDLastSat"))
		cNumSale  := aDados[1][1] // Ultima numeração na SL1
		cRetSerie := aDados[1][3] // Numero da ultima Serie na SL1
	Else  
		cNumSale  := aDados[1][2] // Numero do ultimo Documento na SL1
		cRetSerie := aDados[1][3] // Numero da ultima Serie na SL1
	Endif
EndIf 

(cAliasSL1)->(DBCloseArea())

Return cNumSale 

/*/{Protheus.doc} STDValIRes
	Rotina para verificar se existe item com Reserva quando PDVonline 
	@type  Static Function
	@author caio.okamoto
	@since 15/08/2023
	@version 12
	@param cNumOrig, caracteer, numero do Numorig
	@return lRet, lógico, se existe item com reserva retorna .T.
/*/
Static Function STDValIRes(cNumOrig)
Local cPdv			:= PadR(STFGetStation("PDV"), TamSX3("L1_PDV")[1])					// Numero do PDV
Local cQry 			:= ""																// Query para realizar a busca do ultimo orçamento na SL1 	
Local lRet 			:= .F. 
Local oPrepared 	:= Nil  

If !Empty(cNumOrig)

	cQry := "SELECT COUNT(L2_NUM) RESERVA "
	cQry += " FROM " + RetSqlName("SL2") + " WHERE "
	cQry += " L2_FILIAL  = ?"
	cQry += " AND L2_PDV = ?"
	cQry += " AND L2_NUMORIG = ?"
	cQry += " AND L2_RESERVA <> ' ' "
	cQry += " AND L2_ENTREGA <> '2' "
	cQry += " AND L2_ENTREGA <> ' ' "
	cQry += " AND D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)

	oPrepared:=FWPreparedStatement():New(cQry)
	oPrepared:SetString(1, xFilial('SL2'))
	oPrepared:SetString(2, cPdv)
	oPrepared:SetString(3, cNumOrig)

	cQry :=oPrepared:GetFixQuery()

	lRet := !Empty(MpSysExecScalar(cQry,"RESERVA"))

	If oPrepared != NIL
		oPrepared:Destroy()
		oPrepared := NIL
	Endif

Endif 

Return  lRet


/*/{Protheus.doc} STDRestCanL1
Após cancelamento ou desistencia do cancelamento voltamos os campos para seu estado padrão. 
@author Jeferson Mondeki
@since 30/04/2025
@version 12
@return Nil, Nulo 
/*/
Function STDRestCanL1()

Local cMVCliPad  := SuperGetMV("MV_CLIPAD")
Local cMVLojaPad := SuperGetMV("MV_LOJAPAD")
Local oModelCli  := Nil		// Model do cliente selecionado

If !Empty(cMVCliPad) .And. !Empty(cMVLojaPad)
	oModelCli := STWCustomerSelection(cMVCliPad+cMVLojaPad)
	STDSPBasket("SL1","L1_CLIENTE"	,oModelCli:GetValue("SA1MASTER","A1_COD"))
	STDSPBasket("SL1","L1_LOJA"		,oModelCli:GetValue("SA1MASTER","A1_LOJA"))
	STDSPBasket("SL1","L1_TIPOCLI"	,oModelCli:GetValue("SA1MASTER","A1_TIPO"))
	STDSPBasket("SL1","L1_CGCCLI"	,"")
	STDSPBasket("SL1","L1_PFISICA"	,"")
EndIf

Return Nil

