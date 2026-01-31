#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBTEF.CH"

Static oTEF := Nil		// Objeto TEF2.0
Static lAltParcTef :=  GetAPOInfo("LOJXFUNB.PRX")[4] >= cTOd("02/02/2018") .AND. GetAPOInfo("LOJA1926.PRW")[4] >= cTOd("02/02/2018")


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetTEF
Retorna objeto TEF

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  lRet				Retorna objeto TEF  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetTef()

Return oTEF


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetTef
Seta objeto TEF

@param   oObjTEF			Objeto Tef a ser setado   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return   
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetTef(oObjTEF)

LjGrvLog("[TPD]","STBSetTef - seta obajeto oTEF - ProcName " , ProcName(1) ) 				
LjGrvLog("[TPD]","STBSetTef - seta obajeto oTEF - ProcLine " , ProcLine(1) ) 				

oTEF := oObjTEF

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBFunAdm
Abre Funcoes administrativas do TEF CLisitef

@param   oObjTEF			Objeto Tef a ser setado   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return   
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBFunAdm(oObjTEF, lSTDSatRecovery, aVendaTEF, lRetTRN)

Local oRetTran			:= Nil				//Retorno da transacao 
Local oDados 			:= Nil				//Dados da Instancia da classe
Local aDadosCanc		:= {}
Local nOpcao			:= 0				//Guarda qual opção para abrir a tela Sitef ou Payment Hub
Local lPaytHub			:= ExistFunc("LjUsePayHub") .And. LjUsePayHub()
Local lIsPagDig			:= .F.
Local lRet				:= .F. 				// Retorna .T. caso oRetTran:oRetorno:lTransOk retornar .T. 

Default oObjTEF 		:= Nil				//Objeto TEF
Default lSTDSatRecovery	:= NIL
Default aVendaTEF		:= {}
Default lRetTRN			:=.F. 

If oObjTEF == Nil
	oObjTEF		:= LJC_TEF():New(cEstacao) 
EndIf

lIsPagDig := Iif( lPaytHub, oObjTEF:oConfig:ISPgtoDig() , .F. )

oDados := LJCDadosTransacaoADM():New(0,0, Date(), Time(), .T.)

If oObjTEF <> Nil .AND. oObjTEF:lAtivo .AND. ( oObjTEF:oConfig:ISCCCD() .Or. lIsPagDig ) // Caso o TEF nao esteja ativo

	If STFProFile(17,,,,,,.T.)[1]

		If !FWIsInCallStack("STWCSFinalized") .AND. !FWIsInCallStack("ReverseDropTitles")
			If lIsPagDig .AND. oObjTEF:oConfig:ISCCCD()
				nOpcao := Aviso(STR0010,STR0011,{STR0012,STR0013}) // "Escolha uma opção" ##"Qual das opções abaixo deseja abrir ##"Gerencial Sitef" ##"Gerencial Pag. Digital"
			ElseIf lIsPagDig
				nOpcao := 2 // TOTVS Pagamento Digital
			Else
				nOpcao := 1 // TEF Gerencial 
			EndIf
		EndIf

		LjGrvLog( "STBTEF" , "TEF Ativo" )
		
		STIBtnDeActivate()	

		If nOpcao == 2 .OR. ( lIsPagDig .AND. Len(aVendaTEF) > 6 .AND. IsPDOrPix(aVendaTEF[7]))
			oRetTran := oObjTEF:PgtoDigital():FuncoesAdm(oDados,aVendaTEF)
		Else
			oRetTran := oObjTEF:Cartao():FuncoesAdm(oDados,aVendaTEF)
		EndIf	
		
		STIBtnActivate()
		
		LjGrvLog(,"STBTEF - Retorno do que foi solicitado pelo TEF-GERENCIAIS oRetTran", oRetTran)

		If oRetTran:oRetorno:lTransOk  
		
			LjGrvLog(,"STBTEF - Valida se nao esta vazio os valores cViacliente e cViaCaixa para impressao")
			LjGrvLog(,"STBTEF - oRetTran:oRetorno:cViacliente",oRetTran:oRetorno:cViacliente)
			LjGrvLog(,"STBTEF - oRetTran:oRetorno:cViaCaixa",oRetTran:oRetorno:cViaCaixa)
			
			If !Empty(oRetTran:oRetorno:cViacliente) .OR. !Empty(oRetTran:oRetorno:cViaCaixa)
				
				LjGrvLog(,"STBTEF - Prepara para imprimir")
				LjGrvLog(,"STBTEF - oRetTran:oRetorno:oViaCaixa",oRetTran:oRetorno:oViaCaixa)
				LjGrvLog(,"STBTEF - oRetTran:oRetorno:oViaCliente",oRetTran:oRetorno:oViaCliente)
					
				oObjTEF:Cupom():Inserir("G"	,	oRetTran:oRetorno:oViaCaixa	, oRetTran:oRetorno:oViaCliente	, "A"	,;
										""	,		""							, oRetTran:nValor					, 1		,;
											0	)
				
				If oObjTEF:Cupom():Imprimir(,lSTDSatRecovery)
						oObjTEF:Confirmar()
				Else
					//Para transacoes administrativas de cancelamento tem q reimprimir o ultimo  
					//comprovante em caso de erro de impressao e confirmar a transacao mesmo com erro de impressao.
					If !Empty(oRetTran:oRetorno:cDocCanc)
						oObjTEF:Confirmar()
						STFMessage("TEF", "POPUP", STR0001 )//"Transação TEF comfirmada. Favor reimprimir ultimo comprovante."
						STFShowMessage( "TEF")			 	
					Else		
						oObjTEF:Desfazer()
						STFMessage("TEF", "POPUP", STR0002 )  //"Transação não foi efetuada. Favor reter o cupom."
						STFShowMessage( "TEF")	
					EndIf	
				EndIf
			
			Else
				
				//Confirma transacoes OK que nao tem impressao
				oObjTEF:Confirmar()
			
			EndIf  

			If Len(aVendaTEF) > 0 .ANd. AttIsMemberOf(oRetTran:oRetorno,"cDocCanc",.T.) .AND. AttIsMemberOf(oRetTran:oRetorno,"dDataCanc",.T.) .AND. AttIsMemberOf(oRetTran:oRetorno,"cHora",.T.)
				
				If FWIsInCallStack("ReverseDropTitles") 
					
					AAdd( aDadosCanc, { "LV_DOCCANC", oRetTran:oRetorno:cDocCanc } )
					If ValType(oRetTran:oRetorno:dDataCanc) == "D"
						AAdd( aDadosCanc, { "LV_DATCANC", StrTran( DToC(oRetTran:oRetorno:dDataCanc), "/") } )
					Endif 
					AAdd( aDadosCanc, { "LV_HORCANC", StrTran( oRetTran:oRetorno:cHora, ":") } )
					
					If  !Empty(aDadosCanc[1][2]) .And. !Empty(aDadosCanc[2][2])
						STBRemoteExecute( "STESTSLV",{aDadosCanc,aVendaTEF[9]},Nil,.F.,Nil)
					EndIf
					lRetTRN := .T. 
				Else 

					AAdd( aDadosCanc, { "L4_DOCCANC", oRetTran:oRetorno:cDocCanc } )
					If ValType(oRetTran:oRetorno:dDataCanc) == "D"
						AAdd( aDadosCanc, { "L4_DATCANC", StrTran( DToC(oRetTran:oRetorno:dDataCanc), "/") } )
					Endif 
					AAdd( aDadosCanc, { "L4_HORCANC", StrTran( oRetTran:oRetorno:cHora, ":") } )
					
					If ExistFunc("STDUpdDocC") .AND. !Empty(aDadosCanc[1][2]) .And. !Empty(aDadosCanc[2][2])
						STDUpdDocC(aDadosCanc,aVendaTEF[8])
					EndIf

				Endif 
			EndIf  
			lRet:= .T. 
		Else
			oObjTEF:Desfazer()
		EndIf 

		oRetTran 	:= FreeObj(oRetTran)

	Endif

Else

	If !oObjTEF:lAtivo 
		STFMessage("TEF", "ALERT", STR0004 )//"TEF não está ativo."
		STFShowMessage( "TEF")
		LjGrvLog( "STBTEF" , STR0004 )
	ElseIf !oObjTEF:oConfig:ISCCCD()
		STFMessage("TEF", "ALERT", STR0005 )//"TEF não habilitada forma de pagamento cartão débito/crédito."
		STFShowMessage( "TEF")
		LjGrvLog( "STBTEF" , STR0005 )//"TEF não habilitada forma de pagamento cartão débito/crédito."		
	Else
		STFMessage("TEF", "ALERT", STR0003 )//"TEF não configurado para a estação."
		STFShowMessage( "TEF")
		LjGrvLog( "STBTEF" , STR0003 )//"TEF não configurado para a estação."
	EndIf	 	
	
EndIf	       

//Seta a quantidade de cartoes da venda para zero
//usado na homologacao TEF
STISetUsedCard()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldParc
Funcao de validacao da Qtde de parcelas informada na tela do TEF.

@param      	
@author  Varejo
@version P12
@since   02/04/2015
@return  .T. se a parcela digitada for válida / .F. Se a parcela digitada NÃO for válida.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBVldParc( cGetValue, cAdmFin, cRede, cTpCartao, nParcAnt, nValor )
Local lRet 	:= .T.
Local lImport   := STBIsImpOrc()		//Verifica se eh importacao de orcamento

If ExistBlock("STTefPar")
	lRet := ExecBlock("STTefPar",.F.,.F.,{cGetValue, cAdmFin, cRede, cTpCartao})
	
	If ValType(lRet) <> "L"
		MsgStop("Retorno inválido no Ponto de Entrada 'STTefPar'. Informe ao administrador do sistema.")
		lRet := .T. //Caso o tipo de retorno venha inválido por erro de programação da customização, força o retorno .T. (true)
	EndIf
Endif

If lRet
	lRet := STBValParc(cGetValue, nValor)
EndIf

If lRet .AND. lImport .AND. lAltParcTef
	If Val(cGetValue) != nParcAnt
		If STFPROFILE(44)[1]
			lRet := .T.
		Else
			lRet := .F.
			STFMessage("TEF", "POPUP", STR0006 + CHR(13) +; //"Não é permitido alterar o numero de parcelas. "
			STR0007)//"Para alterar as parcelas verifique as configurações de perfil de caixa do usuário ou altere as parcelas através do orçamento."
	   		STFShowMessage( "TEF")	
		EndIF
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValParc
Funcao para validar o valor das parcelas conforme a quantidade de parcelas que o usuario informou

@param	 nParcelas -> Numero de parcela informado na venda
@param	 nValor -> Valor da transacao
@author  Varejo
@version Bruno Almeida
@since   26/07/2019
@return  .T. se a parcela digitada for válida / .F. Se a parcela digitada NÃO for válida.
/*/
//-------------------------------------------------------------------
Function STBValParc(nParcelas, nValor)

Local nMvValParc := SuperGetMv("MV_LJVALPA",,0) //Parametro que informar o valor minimo das parcelas
Local nVrParc	 := 0 //Variavel para receber a divisão do valor da transação dividido pela quantidade de parcelas
Local lRet		 := .T. //Variavel de retorno

Default nParcelas := 1
Default nValor := 0

If IsNumeric(nParcelas) .AND. IsNumeric(nMvValParc)

	If ValType(nMvValParc) == 'C'
		nMvValParc := Val(nMvValParc)
	EndIf

	If ValType(nParcelas) == 'C'
		nParcelas := Val(nParcelas)
	EndIf

	If nMvValParc > 0 .AND. nParcelas > 1 .AND. nValor > 0

		nVrParc := STBArred( nValor / nParcelas )

		If nMvValParc > nVrParc
			STFMessage("TEF", "POPUP", STR0008 + Str(nMvValParc,10,2) + CHR(13) + CHR(13) + STR0009 ) //"O valor minimo para cada parcela deve ser de R$ " # " Por favor, verifique a quantidade de parcelas informado!"
			STFShowMessage( "TEF")			
			lRet := .F.
		EndIf

	EndIf
Else
	LjGrvLog( "STBTEF" , "Os valores informados no parametro MV_LJVALPA ou no campo de parcelas nao sao numericos, neste caso nao houve a validacao do valor minimo de parcelas" )
EndIf

Return lRet
