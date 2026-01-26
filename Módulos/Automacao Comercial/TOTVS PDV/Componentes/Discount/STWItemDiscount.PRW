#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STWITEMDISCOUNT.CH"

static lAtivMotor	:= ExistFunc("PshAtivMTP") .AND. PshAtivMTP()

//-------------------------------------------------------------------
/*/{Protheus.doc} STWItemDiscount
Função desconto no item

@param   nItemLine			Numero do item na venda
@param   nValDisc			Valor do Desconto
@param   cTypeDisc			Tipo do desconto. P - Percentual , V - Valor
@param   cTypeItem			Tipo do Item. "KIT" - Item de KIT , "IMOP" - Item de Importação de Orçamento
@param   lItemFiscal		Indica se o Item é fiscal. Impresso em cupom fiscal
@param   cTime				Configuração se desconto antes ou depois de registrar o item
@param	 nQuantProd			numerico, Quantidade do produto na venda
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet					Retorna se aplicou desconto
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWItemDiscount( 	nItemLine	, nValDisc 	, cTypeDisc 	, cTypeItem	, ;
							lItemFiscal	, cTime		, nQuantProd	)

Local lRet				:= .F.			// Retorna se Aplicou desconto
Local lContinue			:= .T.			// Fluxo função
Local aRuleDiscount		:= {}			// Armazena retorno regra de desconto por item
Local aDiscount			:= {}			// Armazena Desconto via Usuário
Local cConfig			:= ""			// Configuração se utiliza desconto via usuário, via regra ou ambos
Local cCodSup			:= ""			// Código do Supervisor que liberou o desconto
Local lCRdesItTt 		:= SuperGetMv("MV_LJRGDES",,.F.) .AND. SuperGetMV("MV_LJCRDPT",,"0") == "1" .AND. FindFunction("totvs.protheus.retail.desconto.RegraDescProdutoTotal.LjCallCalcRegDescProdTotal", .T.)	// Verifica se o calculo do desconto por item esta sendo feito no final da venda

Default nItemLine 		:= 0
Default nValDisc 		:= 0
Default cTypeDisc 		:= ""
Default cTypeItem 		:= ""
Default lItemFiscal 	:= .F.
Default cTime		 	:= ""
Default nQuantProd		:= 0

ParamType 0 Var  nItemLine		As Numeric		Default 0
ParamType 1 Var  nValDisc		As Numeric		Default 0
ParamType 2 Var  cTypeDisc 		As Character	Default ""
ParamType 3 Var  cTypeItem		As Character 	Default ""
ParamType 4 Var  lItemFiscal	As Logical 		Default .F.
ParamType 5 Var  cTime			As Character 	Default ""

If !lAtivMotor .Or. (nValDisc == 0 .And. STBGetItDiscount()[1] == 0)
	/*/
		Item de importação de orçamento
	/*/
	If Upper(cTypeItem) == "IMP"

		/*/
			Validações
		/*/
		If ( nValDisc <= 0 ) .OR. ( cTypeDisc <> "V" ) .OR. ( nItemLine <= 0 )
			lContinue := .F.
		EndIf


		/*/
			Para importação de orçamento, é passado tipo de desconto por Valor,
			Por isso faço um TaxAlt direto
		/*/
		If lContinue
			STBTaxAlt(	"IT_DESCONTO" , nValDisc ,	nItemLine )
			lRet := .T.
		EndIf

	/*/
		Item tipo KIT
	/*/
	ElseIf AllTrim(Upper(cTypeItem)) $ "KIT|BON"

		lRet := STBIDApply( 	nItemLine	, nValDisc 	, cTypeDisc , lItemFiscal	, ;
								"A"										)
	Else

		/*/
			Get da configuração de desconto no item:
			"U" - Usuário
			"R" - Regra de Desconto
			"A" - Ambos
		/*/
		cConfig := STDIDUseDiscountFrom()

		Do Case

			/*/
				Apenas via usuário
			/*/
			Case cConfig == "U"

				//Busca desconto do usuario
				aDiscount := STBGetItDiscount()
			
				If aDiscount[1] > 0 //se usuario digitou desconto, considera ele 	 
					lRet := STBIDUser( nItemLine , cTime , lItemFiscal )
				Else	
				//se nao digitou desconto , aplica regra de desconto varejo.	
					aRuleDiscount := STWRuleItem( 	nItemLine	)
		
					If aRuleDiscount[LRULEAPPLY]
		
						lRet := STBIDApply( nItemLine , aRuleDiscount[NDESCTOTAL] , "V" , lItemFiscal , "A" )
		
						If lRet
		
								STWRsnDesc( nItemLine	, STR0001	,	STR0002 ) // "REGRA DE DESCONTO"
		
						EndIf
		
					Else
		
						lRet := .F. // Desconto nenhum foi aplicado
		
					EndIf

				EndIf

			/*/
				Apenas via regra de desconto
			/*/
			Case cConfig == "R"

				aRuleDiscount := STWRuleItem( 	nItemLine	)

				If aRuleDiscount[LRULEAPPLY]

					lRet := STBIDApply( nItemLine , aRuleDiscount[NDESCTOTAL] , "V" , lItemFiscal , "A" )

					If lRet

							STWRsnDesc( nItemLine	, STR0001	,	STR0002 ) // "REGRA DE DESCONTO"

					EndIf

				Else

					lRet := .F. // Desconto nenhum foi aplicado

				EndIf

			/*/
				Ambos
			/*/
			Case cConfig == "A"

				If !lCRdesItTt .OR. ( lCRdesItTt .AND. nQuantProd > 0 )
					/*/
						Aplica primeiro a de Regra de desconto, depois a de usuário, no formato desconto sobre desconto
					/*/
					aRuleDiscount := STWRuleItem( 	nItemLine, , , nQuantProd )
				
				EndIf

				If (ValType(aRuleDiscount) == "A" .AND. Len(aRuleDiscount) > 0 ) .AND. aRuleDiscount[LRULEAPPLY]

					/*/
						Get do desconto dado via usuário
					/*/
					aDiscount := STBGetItDiscount()

					If Empty(cTime)

						cTime := STDIDTime()

					EndIf

					/*/
						Se vier desconto via usuário,
						Validar o desconto de usuário em relação ao novo total*.
						Total descontado da Regra de Desconto
					/*/
					lRet := STBIDValid( 	nItemLine 		, aDiscount[1] 				, aDiscount[2] , .T.	, ;
											cTime			, aRuleDiscount[NNEWTOTAL] 							)

					If lRet

						lRet := STBIDBothApply( nItemLine , aRuleDiscount , aDiscount , lItemFiscal , cTime )

					Else

						If STBTaxRet( nItemLine , "IT_DESCONTO" ) <= 0 // Caso não tenha sido aplicado desconto nenhm, aplica o desconto de Regra apenas.
							lRet := STBIDApply( nItemLine , aRuleDiscount[NDESCTOTAL] , "V" , lItemFiscal , "A" )
							If lRet
								If ( aDiscount[1] > 0 ) .AND. ( aDiscount[2] $ "V|P" )	// Indica intenção de desconto via usuário
									STFMessage("STItemDiscount","ALERT", STR0003) //"Foi aplicado apenas desconto via Regra de Deconto"
								EndIf
							EndIf
						EndIf

						If ( aDiscount[1] > 0 ) .AND. ( aDiscount[2] $ "V|P" )	// Indica intenção de desconto via usuário
							STFMessage("STItemDiscount","ALERT",STR0004) //"Desconto não aplicado"
						EndIf

						STFShowMessage("STItemDiscount")

					EndIf

				Else
					lRet := STBIDUser( nItemLine , cTime , lItemFiscal, @cCodSup )
				EndIf

		EndCase

	EndIf

	If lRet .AND. Upper(cTypeItem) != "IMP"
		If cConfig <> "R" // Para regra de desconto já chamado(sem interface) logo após aplicar a regra
			STWRsnDesc( nItemLine , , , , cCodSup ) // Chamada Motivo de Desconto
		EndIf
	EndIf
Else
	lRet := .F.
	STFMessage("STFMTPRO","POPUP", STR0008 )//"Não é Possível Aplicar Desconto Manual, o Motor de Promoções está ativado"
	STFShowMessage("STFMTPRO")
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWIDAfter
Avalia desconto aplicado via usuário depois do item

@param   nDiscount			Valor para desconto
@param   cTypeDisc			Tipo de desconto, se "V" - Valor ou "P" - Percentual
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet					Retorna se Efetuou o Desconto
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWIDAfter( nDiscount , cTypeDisc )

Local lRet			:= .F.			// Retorna se efetuou o desconto
Local cTime			:= ""			// Configuração se desconto antes ou depois de registrar o item
Local cConfig			:= ""			// Configuração de desconto se via usuário, regra ou ambos
Local nItemLine		:= 0			// Linha do item
Local lItemFiscal	:= .F.			// Indica se o item deve ser registrado em impressora fiscal

Default nDiscount		 		:= 0
Default cTypeDisc		 		:= ""

ParamType 0 Var  nDiscount 			As Numeric		Default 0
ParamType 1 Var  cTypeDisc 			As Character	Default ""

/*/
	Get configuração se desconto antes ou depois de registrar o item
/*/
cTime := STDIDTime()

/*/
	Get da Configuração de desconto se via usuário, regra ou ambos
/*/
cConfig := STDIDUseDiscountFrom()

If cConfig <> "R" // Via Regra de Desconto

	If cTime <> "D" // Desconto depois de registrado o Item

		If nDiscount >= 0 .AND. !Empty(cTypeDisc) // Indica intenção de desconto

			STFMessage("STWIDAfter","ALERT", STR0005) //"A configuração nao permite desconto após o item"

		EndIf

	Else

		nItemLine := STDPBLength("SL2") // Ultimo item

		If nItemLine > 0

			/*/
				Set Desconto
			/*/
			STBSetItDiscount( nDiscount , cTypeDisc )

			lItemFiscal := STDGPBasket( "SL2" , "L2_FISCAL" , nItemLine )

			lRet := STWItemDiscount( nItemLine , Nil , Nil , ""	, lItemFiscal , "D" )

		EndIf

	EndIf

Else

	If nDiscount >= 0 .AND. !Empty(cTypeDisc) // Indica intenção de desconto

		STFMessage("STWIDAfter","ALERT", STR0006) //"A configuração não permite desconto via usuário"

	EndIf

EndIf

STFShowMessage("STWIDAfter")

/*/
	Set default desconto usuário
/*/
STBDefItDiscount()

Return  lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWIDBefore
Avalia desconto aplicado via usuário antes/junto do item

@param   nDiscount			Valor para desconto
@param   cTypeDisc			Tipo de desconto, se "V" - Valor ou "P" - Percentual
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWIDBefore( nDiscount , cTypeDisc, cTime )

//Local cTime			:= ""			// Configuração se desconto antes ou depois de registrar o item
Local cConfig			:= ""			// Configuração de desconto se via usuário, regra ou ambos

Default nDiscount		 		:= 0
Default cTypeDisc		 		:= ""
Default cTime					:= "" // Configuração se desconto antes ou depois de registrar o item

ParamType 0 Var  nDiscount 			As Numeric		Default 0
ParamType 1 Var  cTypeDisc 			As Character	Default ""
ParamType 2 Var  cTime	 			As Character	Default ""

/*/
	Get configuração se desconto antes ou depois de registrar o item
/*/
If Empty(cTime)
	cTime 	:= STDIDTime()
EndIf

/*/
	Get da Configuração de desconto se via usuário, regra ou ambos
/*/
cConfig := STDIDUseDiscountFrom()

If cConfig <> "R" // Via Regra de Desconto

	If cTime <> "A" // Antes|Junto com registro de Item

		If nDiscount > 0 .AND. !Empty(cTypeDisc) // Indica intenção de desconto

			STFMessage("STWIDBefore","ALERT", STR0007) //"A configuração não permite desconto antes do item"

		EndIf

	Else

		/*/
			Set Desconto
		/*/
		STBSetItDiscount( nDiscount , cTypeDisc )

		/*/
			Após o set, o desconto deve ser efetuado via chamado do registro de item
		/*/

	EndIf

Else

	If nDiscount > 0 .AND. !Empty(cTypeDisc) // Indica intenção de desconto

		STFMessage("STWIDBefore","ALERT", STR0006) //"A configuração não permite desconto via usuário"

	EndIf

EndIf

STFShowMessage("STWIDBefore")

Return Nil
