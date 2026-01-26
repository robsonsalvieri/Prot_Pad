#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFVLDECF.CH"

//------------------------------------------------------------------
/*/{Protheus.doc} xVldECFTab
Função responsavel por validar os registros filhos ou 
consulta padrao das respectivas tabelas

@Param  
cAlias    - Alias da tabela filho
cChave    - Chave de busca na tabela filho
nInd      - Indice da tabela filho 
aCampos   - Array com os campos da tabela filho
aLogErro  - Array com Log de erros
aInfoPai  - Array com informacoes referentes ao registro de origem da validacao

@Return 
( lRet )  -> Indica se o registro foi encontrado ou nao

@author Aderson Costa
@since 04/06/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function xVldECFTab( cAlias, cChave, nInd, aCampos, aLogErro, aInfoPai )

Local cDescTab	as character
Local cDesCod		as character
Local cNomeCmp	as character
Local nX			as numeric
Local lRet			as logical

Default aCampos	:=	{}
Default aLogErro	:=	{}
Default aInfoPai	:=	{ "", "", 0, "", "" }

cDescTab	:=	""
cDesCod	:=	""
cNomeCmp	:=	""
nX			:=	0
lRet		:=	.F.

//Verifico se a chave de busca foi informada
If !Empty( cChave )  

	DbSelectArea( cAlias )
	( cAlias )->( DBSetOrder( nInd ) )

	//Tratamento para o nome do campo de codigo, visto que nem todas tabelas utilizam o padrao "_CODIGO"
	If cAlias == "C1P"
		cNomeCmp := "_CODCUS"
	Elseif cAlias == "C1H"
		cNomeCmp := "_CODPAR"
	Elseif cAlias == "C1G"
		cNomeCmp := "_NUMPRO"
	Else
		cNomeCmp := "_CODIGO"
	EndIf

	If ( cAlias )->( FieldPos( ( cAlias + cNomeCmp ) ) ) > 0
		cDesCod	:= AllTrim( Posicione( cAlias, nInd, xFilial( cAlias ) + cChave, cAlias + cNomeCmp ) )
	EndIf

	cDescTab := NomeTab( cAlias )

	//Busco a chave informada
	If (cAlias)->( MsSeek(xFilial( cAlias ) + cChave) )  
	   	
	   	lRet := .T. 
	   	
		//Verifico se o campo de Status existe no registro filho                                
	    If (cAlias)->( FieldPos( ( cAlias + "_STATUS" ) ) ) > 0  
	    	    		
			//Verifico se a consulta padrao eh um registro valido	   	
		   	If !( (cAlias)->&( cAlias + "_STATUS") $ ( "0|4" ) ) 
				Aadd( aLogErro,{ aInfoPai[2], "000005", aInfoPai[1], aInfoPai[3], "000027", cDesCod, cDescTab} ) // STR0005 - "A consulta padrão deste campo possui um registro não validado." 
		    EndIf	        
	    EndIf
			
		//Verifico se existem mais validações 
		If !Empty( aCampos )
	
			For nX := 1 to Len( aCampos ) 
	
				//Validacao do CPF/CNPJ
				If aCampos[nX][2] == 1
	
					If !CGC( &( cAlias + "->" + aCampos[nX][1]),,.F. ) 
						Aadd( aLogErro,{ aCampos[nX][1], "000006", aInfoPai[1], aInfoPai[3] } ) //STR0006 - "CPF/CNPJ inconsistente."   						
					EndIf   			                           
					
				//Valida as opcoes possiveis de um combo
				//Na terceira posicao passar as opcoes possiveis   			
	    		ElseIf aCampos[nX][2] == 2 
	    		
	    			If !( AllTrim( &( cAlias + "->" + aCampos[nX][1] ) ) $( aCampos[nX][3] ) )
						Aadd( aLogErro,{ aCampos[nX][1], "000002", aInfoPai[1], aInfoPai[3] } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
					EndIf	    			
					
				//Valida se os campos estao preenchidos
		   		ElseIf aCampos[nX][2] == 3 
	    		
		    		If Empty( cAlias + "->" + aCampos[nX][1] )	
						Aadd( aLogErro,{ aCampos[nX][1], "000001", aInfoPai[1], aInfoPai[3] } ) //STR0001 - "Campo inconsistente ou vazio."
					EndIf
	
				//Valida se a hora eh valida
	    		Elseif aCampos[nX][2] == 4 
	    		   
		    		If !( xFunVldHor( "'" + cAlias + "->" + aCampos[nX][1] + "'" ) ) 
						Aadd( aLogErro,{ aCampos[nX][1], "000007", aInfoPai[1], aInfoPai[3] } ) //STR0007 - "Hora inconsistente ou vazia."     	    		
	    			EndIf
				
				EndIf			   		
			Next Nx			
		EndIf	    	 
	Else 
		Aadd( aLogErro,{ aInfoPai[2], "000004", aInfoPai[1], aInfoPai[3], "000028", cDesCod, cDescTab } ) //STR0004 - "Consulta padrão inválida."    	    		
	EndIf
EndIf

Return ( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldECFReg

Validacao das regras genericas do layout ECF

@Param:
cAlias     - Alias posicionado
cRegra     - Regra do layout a ser verificada
aLogErro   - Array com log de erros
aDadosUtil - Array com informacoes(conteudo) adicionais caso necessitem ser comparadas
cAliasPai  - Alias do cadastro de origem da validacao

@Return:

@author Anderson Costa
@since 04/06/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xVldECFReg( cAlias, cRegra, aLogErro, aDadosUtil, cAliasPai )

Local cIdPer		as character
Local cMesIni		as character
Local cMesFim		as character
Local cFormPer	as character
Local cOpcApu		as character
Local cTribPer	as character
Local nRecno		as numeric
Local lRet			as logical
Local lAchou		as logical
Local lValidaT	as logical
Local lValidaA	as logical
Local lA00			as logical

Default aLogErro		:=	{}
Default aDadosUtil	:=	{}
Default cAliasPai		:=	""

cIdPer		:=	""
cMesIni	:=	""
cMesFim	:=	""
cFormPer	:=	""
cOpcApu	:=	""
cTribPer	:=	""
nRecno		:=	( cAlias )->( Recno() )
lRet		:=	.T.
lAchou		:=	.F.
lValidaT	:=	.F.
lValidaA	:=	.F.
lA00		:=	.F.

If Empty( cAliasPai )
	cAliasPai := cAlias 
EndiF

/*

// Modelo basico de validacao
If cRegra == "XXX_XXX_XXX"

	XXX->( DBSetOrder( Indice ) )
	If ()
		aAdd( aLogErro,{ cAlias, "000000", cAlias, nRecno, cAliasPai }) //""
	EndIf	
	
EndIf

*/

If cRegra == "REGRA_MES_FORA_PERIODO"
	/*--------------------------------------*
	 | Validações conforme Layout Dez/14    |
	 | Responsável: Evandro dos S. Oliveira |
	 | Data: 09/02/2014					     |
	 *--------------------------------------*/ 
	 
	//aDadosUtil[1] - Periodo
	//aDadosUtil[2] - Mes

	cIdPer := TAFEcfPer(aDadosUtil[1])
	
	/*REGRA_MES_FORA_PERIOD*/
	If !Empty(cIdPer)
	
		dbSelectArea("CHD")
		dbSetOrder(1)
		MsSeek(xFilial("CHD")+cIdPer)
		cMesIni := Month2Str(CHD->CHD_PERINI) 
		cMesFim := Month2Str(CHD->CHD_PERFIN)
		
		If !(&(cAlias+"->"+cAlias+"_MES") >= cMesIni .And. &(cAlias+"->"+cAlias+"_MES") <= cMesFim)
			aAdd(aLogErro,{cAlias + "_MES","000203",cAlias, nRecno}) //STR0203 - O Campo 'Mês' está fora do intervalo entre as Datas Inicial e Final do bloco de abertura (Registro 0000)
		EndIf
		
	Else
		aAdd(aLogErro,{cAlias + "_PERIOD","000194",cAlias, nRecno}) //STR0194 - "Período não encontrado na tabela de parâmetros ECF (Bloco de Abertura, registro 0000)"         
	EndIf

	ElseIf cRegra == "VALIDA_PERIODO"

		/*---------------------------------------------------*
		 | Validações conforme PCREQ-3522/PDR_SER_TAF001-206 |
		 | Responsável: Evandro dos S. Oliveira              |
		 | Data: 13/02/2014				      				    |
		 *---------------------------------------------------*/ 
		//aDadosUtil[1] - Data Inicial do Saldo
		//aDadosUtil[2] - Data Final do Saldo	
		//aDadosUtil[3] - Id Periodo Apuração

		cIdPer  := aDadosUtil[3]
		cMesIni := IIf(ValType(aDadosUtil[1]) == "D",DTOS(aDadosUtil[1]),aDadosUtil[1])
		cMesFim := IIf(ValType(aDadosUtil[2]) == "D",DTOS(aDadosUtil[2]),aDadosUtil[2])
		
		dbSelectArea("CAH")
		dbSetOrder(1)
		MsSeek(xFilial("CAH")+cIdPer)

		If !Empty(AllTrim(cMesIni)) .And. !Empty(AllTrim(cMesFim))
					
			If TAFSeekPer(cMesIni,cMesFim)
				cFormPer := Substr(AllTrim(CAH->CAH_CODIGO),2,2)
				cOpcApu := Substr(AllTrim(CAH->CAH_CODIGO),1,1)
				
				/*--------------------------------------------------*
				 | Verifica se os Códigos de Tributação são válidos |
				 *--------------------------------------------------*/ 
				If !StrIsInt(cOpcApu,cFormPer)
					aAdd(aLogErro,{cAlias + "_DTINI","000212",cAlias, nRecno}) //STR0212 - "Perído compreendido entre a 'Dt Saldo Ini' e 'Dt Saldo Fin' não encontrado no cadastro de abertura (Bloco 0 - Parâmetros de Abertura)" 
				EndIf
		
				/*------------------------------*
				 | Validação para período Anual |
				 *------------------------------*/ 
				If AllTrim(CHD->CHD_APIRCS) == "2" .AND. AllTrim(CHD->CHD_FORTRB) <> "2" 
				
					If cOpcApu != "A"
						aAdd(aLogErro,{cAlias + "_PERAPU","000208",cAlias, nRecno}) //STR0208 - "O Periodo de apuração do registro não corresponde com a Forma de Apuração 'Apur IRPJ/CS' do cadastro de abertura (Bloco 0 - Parâmetros de Abertura)" 
					EndIf
	
					If Substr(CHD_APUEST,Val(cFormPer),1) != "B" .And. AllTrim(CAH->CAH_CODIGO) <> "A00"
						aAdd(aLogErro,{cAlias + "_PERAPU","000209",cAlias, nRecno}) //STR0209 - "O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar preenchido com B na posição destinada ao perído informado em 'Per Apuração'" 
					EndIf
				
				/*-----------------------------------*
				 | Validação para período Trimestral |
				 *-----------------------------------*/ 
				ElseIf (AllTrim(CHD->CHD_APIRCS) == "1") .OR. (AllTrim(CHD->CHD_APIRCS) == "2" .AND. AllTrim(CHD->CHD_FORTRB) == "2") //Trimestral
				
					If cOpcApu != "T" 
						aAdd(aLogErro,{cAlias + "_PERAPU","000208",cAlias, nRecno}) //STR0208 - "O Periodo de apuração do registro não corresponde com a Forma de Apuração 'Apur IRPJ/CS' do cadastro de abertura (Bloco 0 - Parâmetros de Abertura)"  	
					EndIf
				
					If Substr(CHD->CHD_TRBPER,Val(cFormPer),1) !=  "R"
						aAdd(aLogErro,{cAlias + "_PERAPU","000210",cAlias, nRecno}) //STR0210 - "O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar preenchido com R na posição destinada ao perído informado em 'Per Apuração'" 
					EndIf
				Else
					aAdd(aLogErro,{cAlias + "_PERAPU","000213",cAlias, nRecno}) //STR0213 - "O campo  'Apur IRPJ/CS' (Bloco 0 - Cadastro de Parâmetros de Abertura) deve estar preenchido corretamente para validação do período de apuração deste registro"                	
				EndIf
			Else			
				aAdd(aLogErro,{cAlias + "_PERAPU","000211",cAlias, nRecno}) //STR0211 - "Período de Apuração Inválido"   
			EndIf

		Else
		
			If Empty(AllTrim(cMesIni))
				aAdd(aLogErro,{cAlias + "_DTINI","000001",cAlias, nRecno}) //STR0001 - "Campo inconsistente ou vazio."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
			Else
				aAdd(aLogErro,{cAlias + "_DTFIN","000001",cAlias, nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
			EndIf
			
		EndIf
		
	ElseIf cRegra == "VALIDA_PERIODO_TRIMESTRAL"

		/*---------------------------------------------------*
		 | Validações conforme PCREQ-3522/PDR_SER_TAF001-206 |
		 | Responsável: Evandro dos S. Oliveira              |
		 | Data: 13/02/2014				      				    |
		 *---------------------------------------------------*/ 
		//aDadosUtil[1] - Data Inicial do Saldo
		//aDadosUtil[2] - Data Final do Saldo	
		//aDadosUtil[3] - Id Periodo Apuração
		//aDadosUtil[4] - Forma Tributação Período
		//aDadosUtil[5] - Valida Registro A00
		
		cTribPer := IIf(Len(aDadosUtil) > 3,aDadosUtil[4],"") 
		lA00	  := IIf(Len(aDadosUtil) > 4,aDadosUtil[5],.F.)
		
		cIdPer  := aDadosUtil[3]
		cMesIni := IIf(ValType(aDadosUtil[1]) == "D",DTOS(aDadosUtil[1]),aDadosUtil[1])
		cMesFim := IIf(ValType(aDadosUtil[2]) == "D",DTOS(aDadosUtil[2]),aDadosUtil[2])
		
		dbSelectArea("CAH")
		dbSetOrder(1)
		MsSeek(xFilial("CAH")+cIdPer)

		If !Empty(AllTrim(cMesIni)) .And. !Empty(AllTrim(cMesFim))
		
			If TAFSeekPer(cMesIni,cMesFim)
		
				cFormPer := Substr(AllTrim(CAH->CAH_CODIGO),2,2)
				cOpcApu := Substr(AllTrim(CAH->CAH_CODIGO),1,1)
				
				/*--------------------------------------------------*
				 | Verifica se os Códigos de Tributação são válidos |
				 *--------------------------------------------------*/ 
				If !StrIsInt(cOpcApu,cFormPer)
					aAdd(aLogErro,{cAlias + "_DTINI","000212",cAlias, nRecno}) //STR0212 - "Perído compreendido entre a 'Dt Saldo Ini' e 'Dt Saldo Fin' não encontrado no cadastro de abertura (Bloco 0 - Parâmetros de Abertura)" 
				EndIf
		
				/*-----------------------------------*
				 | Validação para período Trimestral |
				 *-----------------------------------*/ 
				If (AllTrim(CHD->CHD_APIRCS) == "1") .OR. (AllTrim(CHD->CHD_APIRCS) == "2" .AND. AllTrim(CHD->CHD_FORTRB) == "2") //Trimestral
				
					If cOpcApu != "T" 
						If (lA00 .And. AllTrim(CAH->CAH_CODIGO) <> "A00")
							aAdd(aLogErro,{cAlias + "_PERAPU","000214",cAlias, nRecno}) //STR0214 - "Perído de Apuração Inválido. Registros permitidos 'A00,T01,T02,T03 e T04'"
						EndIf					
					EndIf
					
					If !Empty(cTribPer) .And. Substr(CHD->CHD_TRBPER,Val(cFormPer),1) !=  cTribPer 
						If (cTribPer == "A")
							aAdd(aLogErro,{cAlias + "_PERAPU","000216",cAlias, nRecno}) //STR0216 - "O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar preenchido com 'A' na posição destinada ao perído informado em 'Per Apuração'"                                                                                                                                                                                                                                                                                                                                                        
						ElseIf (cTribPer == "P")	
							aAdd(aLogErro,{cAlias + "_PERAPU","000217",cAlias, nRecno}) //STR0217 - "O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar preenchido com 'P' na posição destinada ao perído informado em 'Per Apuração'"
						Else
							aAdd(aLogErro,{cAlias + "_PERAPU","000218",cAlias, nRecno}) //STR0218 - "O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar de acordo com o campo 'Per Apuração' de acordo com as regras estabelecidas para esse campo" 
						EndIf
					EndIf
				Else
					aAdd(aLogErro,{cAlias + "_PERAPU","000215",cAlias, nRecno}) //STR0215 - "Para validação desse registro o Bloco 0 (Cadastro de Parâmetros de Abertura) deve conter uma dessas configurações: Campo 'Apur IRPJ/CS' igual '1' (Trimestral) Ou Campo 'Apur IRPJ/CS' igual a '2-Anual' e o campo  'Forma Trib' igual a '2-Luc Real/Arb'"                	
				EndIf
			Else			
				aAdd(aLogErro,{cAlias + "_PERAPU","000211",cAlias, nRecno}) //STR0211 - "Período de Apuração Inválido"   
			EndIf

		Else
		
			If Empty(AllTrim(cMesIni))
				aAdd(aLogErro,{cAlias + "_DTINI","000001",cAlias, nRecno}) //STR0001 - "Campo inconsistente ou vazio."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
			Else
				aAdd(aLogErro,{cAlias + "_DTFIN","000001",cAlias, nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
			EndIf
			
		EndIf
	
	EndIf
	
	(cAlias)->( DBGoTo( nRecno ) )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} VldECFLog

@param aLogErro - Array contendo as caracteristicas do erro 
@return (cString)
                
Função responsavel por retornar quantidade de erros na tela

@author Fabio V. Santana
@since 05/09/2013
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function VldECFLog( aLogErro )

Local cMsgErro	as character
Local nX			as numeric

cMsgErro	:=	""
nX			:=	0

cMsgErro := "Este registro possui " + AllTrim( Str( Len( aLogErro ) ) ) + " Inconsistência(s)" + CRLF + CRLF

For nX := 1 to Len( aLogErro )
	If Len( aLogErro[nX] ) > 4
		cMsgErro += AllTrim( Str( nX ) ) + "º Inconsistência : " + AllTrim( TitSX3( aLogErro[nX,1] )[1] ) + " - (" + aLogErro[nX,1] + ")" + " - " + AllTrim( aLogErro[nX,6]) + ". " + xVldECFStr( aLogErro[nX,2]) + CRLF
		cMsgErro += xVldECFStr( aLogErro[nX,5] ) + RTrim( aLogErro[nX,7] ) + "." + CRLF + CRLF
	Else
		cMsgErro += AllTrim( Str( nX ) ) + "º Inconsistência : " + AllTrim( TitSX3( aLogErro[nX,1] )[1] ) + " - (" + aLogErro[nX,1] + ") " + " - " + xVldECFStr( aLogErro[nX,2] ) + CRLF + CRLF
	EndIf
Next nX

Aviso( "Log de Validação", cMsgErro, { "Fechar" }, 3 )

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldECFStr

@param 
nOpcValid - Numero do erro
 
@return (cString)
                
Função responsavel por retornar a descrição do erro.

@author Anderson Costa
@since 04/06/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function xVldECFStr( cOpcValid )

Local cString	as character

Default cOpcValid	:=	""

cString	:=	""

Do Case
       
	Case cOpcValid == "000001"
		cString := STR0001 //"Campo inconsistente ou vazio."	
	Case cOpcValid == "000002"
		cString := STR0002 //"Conteúdo do campo não condiz com as opções possíveis."	
	Case cOpcValid == "000003"
		cString := STR0003 //"Data inconsistente ou vazia."	
	Case cOpcValid == "000004"
		cString := STR0004 //"Consulta padrão inválida."	
	Case cOpcValid == "000005"
		cString := STR0005 //"A consulta padrão deste campo possui um registro não validado."	
	Case cOpcValid == "000006"
		cString := STR0006 //"CPF/CNPJ inconsistente."	
	Case cOpcValid == "000007"
		cString := STR0007 //"Hora inconsistente ou vazia."	
	Case cOpcValid == "000008"
		cString := STR0008 //"Quando o campo Nível for maior que 1, é obrigatório preencher o campo Conta Sup."	
	Case cOpcValid == "000009"
		cString := STR0009 //"O período deve estar compreendido entre a data de início e data fim do período."	
	Case cOpcValid == "000010"
		cString := STR0010 //"A data de fim do período dever ser maior ou igual a data de início do período." 	
	Case cOpcValid == "000011"
		cString := STR0011 //"A totalização do campo nos Registros Filhos não confere com o total no Registro Pai."
	Case cOpcValid == "000012"
		cString := STR0012 //"Registro já existente."
	Case cOpcValid == "000013"
		cString := STR0013 //"O campo CNPJ deve ser nulo caso o país não seja Brasil." 
	Case cOpcValid == "000014"
		cString := STR0014 //"A data de encerramento deve ser maior ou igual a data de abertura." 
	Case cOpcValid == "000015"
		cString := STR0015 //"O campo receita do consórcio deve ser nulo caso a condição do declarante do consórcio seja igual a participante." 
	Case cOpcValid == "000016"
		cString := STR0016 //"O campo receita do participante deve ser nulo caso a condição do declarante do consórcio seja igual a participante." 
	Case cOpcValid == "000017"
		cString := STR0017 //"Registro já validado." 					
	Case cOpcValid == "000018"
		cString := STR0018 //"O valor do campo 'Cta Contabil' deve ser igual a '01' (Contas do Ativo), '2' (Contas do Passivo) ou '3' (Contas do Patrimônio Líquido)." 					
	Case cOpcValid == "000019"
		cString := STR0019 //"A soma do campo 'Vl.Saldo Ini' deve ser igual a 0 (zero) para o período." 					
	Case cOpcValid == "000020"
		cString := STR0020 //"A soma do campo 'Vl.Saldo Fin' deve ser igual a 0 (zero) para o período." 					
	Case cOpcValid == "000021"
		cString := STR0021 //"A soma do campo 'Vl.Debito' deve ser igual a soma do campo 'Vl.Credito' para o período." 					
	Case cOpcValid == "000022"
		cString := STR0022 //"A soma do campo 'Vl.Cta.Ref.' deve ser igual aa campo 'Vl.Saldo Fin'." 					
	Case cOpcValid == "000023"
		cString := STR0023 //"O valor do campo 'Cta Contabil' deve ser igual a '04' (Contas do Resultado)." 					
	Case cOpcValid == "000024"
		cString := STR0024 //"Quando 'Tp. Relaciona' for igual a '1' ou '3', o valor do campo 'Vl. Lancam.' deve ser igual ao valor do Lançamento da Parte B." 					
	Case cOpcValid == "000025"
		cString := STR0025 //"Quando 'Tp. Relaciona' for igual a '2', o valor do campo 'Vl. Lancam.' deve ser igual ao valor da Cta Contabil Parte A." 
	Case cOpcValid == "000026"
		cString := STR0026	//"Qualificação inválida para o registro. Selecione entre as seguintes opções:
								//10 - Administrador sem Vínculo Empregatício;11 - Diretor sem Vínculo Empregatício;/12 - Presidente sem Vínculo Empregatício;
								//13 - Administrador com Vínculo Empregatício;14 - Conselheiro de Administração ou Fiscal;15 - Diretor com Vínculo Empregatício;
								//16 - Fundador;17 - Presidente com Vínculo Empregatício" 
	Case cOpcValid == "000027"
		cString := STR0027 //"Favor validar o registro no cadastro - " 
	Case cOpcValid == "000028"
		cString := STR0028 //"Favor verificar - " 
	Case cOpcValid == "000029"
		cString := STR0029 //"Quando o 'Ind. Pessoa' for igual a '2-Pessoa Jurídica', as opções possiveis para este campo são '1-Procurador' ou '6-Outros' "
	Case cOpcValid == "000030"
		cString := STR0030 //"Lucros disponibilizados são inferiores ao lucro antes do imposto de renda somando ao lucro arbitrado no período de apuração antes do imposto, informados em 'Participações no Exterior - Resultado do Período de Apuração'."
	Case cOpcValid == "000031"
		cString := STR0031	//Registro do ECF selecionado não condiz com o tipo de lançamento. Selecione o registro da seguinte forma:
								//Para lançamentos do tipo e-Lalur:
								//1=e-Lalur - M300A	
								//2=e-Lalur - M300B
								//3=e-Lalur - M300C
								//Para lançamentos do tipo e-Lacs:
								//4=e-Lacs - M350A
								//5=e-Lacs - M350B
								//6=e-Lacs - M350C
	Case cOpcValid == "000032"
		cString := STR0032 //"A data de saldo final dever ser maior ou igual a data saldo inicial."
	Case cOpcValid == "000033"
		cString := STR0033 //"A data de período final dever ser maior ou igual a data de período inicial."
	Case cOpcValid == "000034"
		cString := STR0034 //"Para contas com 'Nível da Conta' igual a '1', a 'Cta Superior' não se aplica."
	Case cOpcValid == "000035"
		cString := STR0035 //"Deve existir ao menos um registro de Conta Referencial, para Plano de Contas do tipo Analítico e Codigo da Natureza igual a '01','02','03' ou '04'" 
	Case cOpcValid == "000036"
		cString := STR0036 //"Para Cadastro de Plano de Contas com Nível Superior a '1' o Tipo da Conta Superior deve ser Sintético ('1')." 
	Case cOpcValid == "000037"
		cString := STR0037 //"Para Plano de Contas com Nível maior que 2, o Codigo de Natureza da Conta Superior deve ser igual ao Codigo da Natureza da SubConta." 
	Case cOpcValid == "000038"
		cString := STR0038 //"O Nível da Conta deve ser maior que o Nível da Conta Superior"
	Case cOpcValid == "000039"
		cString := STR0039 //"A 'Conta Referencial' informada deve ser Sintetica"
	Case cOpcValid == "000040"
		cString := STR0040 //"A 'Natureza' da conta referencial deve ser o mesmo do 'Plano de Contas'"
	Case cOpcValid == "000041"
		cString := STR0041 //"Se o campo Indicador de Situação Especial for igual a "6" (Cisão Parcial), o campo deve ser preenchido obrigatoriamente." 	
	Case cOpcValid == "000042"
		cString := STR0042 //"Se o campo Indicador de Situação Especial for diferente de "6" (Cisão Parcial), o campo deve está em branco." 				
	Case cOpcValid == "000043"
		cString := STR0043 //"Se o campo Indicador de Situação Especial for preenchido, o campo deve ser preenchido obrigatoriamente." 
	Case cOpcValid == "000044"
		cString := STR0044 //"Se o campo Indicador de Situação Especial for igual a "0" (Normal = sem situação especial no período), o campo deve está em branco." 		
	Case cOpcValid == "000045"
		cString := STR0045 //"A data de Período Inicial deve ser maior que 01/01/2014." 	
	Case cOpcValid == "000046"
		cString := STR0046 //"O ano informado no período final deve ser igual ao ano informado no período inicial."
	Case cOpcValid == "000047"
		cString := STR0047 //"Se o campo Indicador de Situação Especial for igual a "0" (Normal), o dia e o mês no Período Final deve ser igual a 31/12." 
	Case cOpcValid == "000048"
		cString := STR0048 //"Se o campo Indicador de Situação Especial for igual a "1"(Extinção),"2"(Fusão),"3"(Incorporação/Incorporada),"4"(Incorporação/Incorporadora),"5"(Cisão Total) ou "6"(Cisão Parcial), o Período Final deve ser igual a Data da Situação Especial."		
	Case cOpcValid == "000049"
		cString := STR0049 //"Se o campo Indicador de Situação Especial for igual a "7"(Transformação),"8"(Desenquadramento de Imune e Isenta ou "9"(Inclusão no SimplesNacional), o Período Final deve ser igual a Data da Situação Especial - 1."
	Case cOpcValid == "000050"
		cString := STR0050 //"Se o campo Tipo da ECF for igual a "2" (ECF da SCP), o campo deve ser preenchido obrigatoriamente."
	Case cOpcValid == "000051"
		cString := STR0051 //"Se o campo Tipo da ECF for igual a "0" (ECF de empresa não participante de SCP como sócio ostensivo) ou "1" (ECF de empresa participante de SCP como sócio ostensivo), o campo não deve ser preenchido."	
	Case cOpcValid == "000052"
		cString := STR0052 //"O código da SCP deve conter exatamente 14 números." 
	Case cOpcValid == "000053"
		cString := STR0053 //"Deve haver ao menos um registro de lançamento da Parte B quando Indicador de Relacionamento do Lançamento da Parte A for igual a '1' ou '3'."   
	Case cOpcValid == "000054"
		cString := STR0054 //"Deve haver ao menos um registro de conta contábil da Parte A quando Indicador de Relacionamento do Lançamento da Parte A for igual a '2' ou '3'."     
	Case cOpcValid == "000055"
		cString := STR0055 //"Quando 'Tp. Relaciona' no Lançamento da Parte A for igual a '3', o valor do campo 'Vl. Lancam.' deve ser igual ao valor do Lançamento da Parte B e o somatório do valor da Cta Contabil Parte A."  
	Case cOpcValid == "000056"
		cString := STR0056 //"O Valor Percentual deve estar compreendido entre 0 e 100" 
	Case cOpcValid == "000057"
		cString := STR0057 //"O 'Val. FINOR' deve corresponder ao resultado da multiplicação de 'Perc. FINOR' por 'B.de Calculo' " 
	Case cOpcValid == "000058"
		cString := STR0058 //"Valor do 'Subtotal' deve corresponder a Soma do 'Val. FINOR' e o 'Val. FINAM' "
	Case cOpcValid == "000059"
		cString := STR0059 //"O 'Val. FINAM' deve corresponder ao resultado da multiplicação de 'Perc. FINAM' por 'B.de Calculo'" 
	Case cOpcValid == "000060"
		cString := STR0060 //"O 'Val. FUNRES' deve corresponder ao resultado da multiplicação de 'Perc. FUNRES' por 'B.de Calculo' "
	Case cOpcValid == "000061"
		cString := STR0061 //"O 'Total' deve corresponder a soma dos valores de 'Val. FINOR', 'Val. FINAM' e 'Val. FUNRES' " 			
	Case cOpcValid == "000062"
		cString := STR0062 //"Se o campo Período de Apuração do IRPJ e CSLL igual a 2-'A' (Anual), a Forma de Tributação do Lucro deve ser igual a '1' (Lucro Real), '2' (Lucro Real/Arbitrado) ou '3' (Lucro Presumido/Real), '4' (Lucro Presumido/Real/Arbitrado) com o Indicador de Optante pelo Refis igual '1'-Sim"
	Case cOpcValid == "000063"
		cString := STR0063 //"Se o campo Período de Apuração do IRPJ e CSLL igual a 1-'T' (Trimestral), a Forma de Tributação do Lucro deve ser igual a '1' (Lucro Real), '2' (LucroReal/Arbitrado), '3' (Lucro Presumido/Real), '4' (Lucro Presumido/Real/Arbitrado), '5' (Lucro Presumido), '6' (Lucro Arbitrado) ou '7' (Lucro Presumido/Arbitrado).
	Case cOpcValid == "000064"
		cString := STR0064 //"Se o campo Forma de Tributação do Lucro for igual a '3' (Lucro Presumido/Real) ou '4' (Lucro/Presumido/Real/Arbitrado) ou '5' (Lucro Presumido) ou '7' (Lucro Presumido/Arbitrado), a Qualificação da Pessoa Jurídica deve ser igual a '01' (PJ em geral).
	Case cOpcValid == "000065"
		cString := STR0065 //"Se o campo 'Forma Trib' for igual a '8 - Imune IRPJ' ou '9 - Isento IPRJ', o campo 'Trib Per' não deve ser preenchido."
	Case cOpcValid == "000066"
		cString := STR0066 //"Se o campo 'Forma Trib' for igual a '1 - Luc Real', o campo 'Trib Per' deve ser preenchido com '0' ou 'R'."
	Case cOpcValid == "000067"
		cString := STR0067 //"Se o campo 'Forma Trib' for igual a '2 - Luc Real/Arb', o campo 'Trib Per' deve ser preenchido com '0', 'R' ou 'A'."
	Case cOpcValid == "000068"
		cString := STR0068 //"Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real' e 'Optante Refi' igual '2 - Não', o campo 'Trib Per' deve ser preenchido com '0', 'P' ou 'R'."
	Case cOpcValid == "000069"
		cString := STR0069 //"Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '2 - Anual', o campo 'Trib Per' deve ser preenchido com '0', 'E' ou 'P'."
	Case cOpcValid == "000070"
		cString := STR0070 //"Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '1 - Trimestral', o campo 'Trib Per' deve ser preenchido com '0', 'R' ou 'P'."
	Case cOpcValid == "000071"
		cString := STR0071 //"Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb' e 'Optante Refi' igual '2 - Não', o campo 'Trib Per' deve ser preenchido com '0', 'A', 'P' ou 'R'."
	Case cOpcValid == "000072"
		cString := STR0072 //"Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '2 - Anual', o campo 'Trib Per' deve ser preenchido com '0', 'A', 'E' ou 'P'."
	Case cOpcValid == "000073"
		cString := STR0073 //"Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb', 'Optante Refi' igual '1 - Sim' e 'Apur IRPJ/CS' igual a '1 - Trimestral', o campo 'Trib Per' deve ser preenchido com '0', 'A', 'R' ou 'P'."
	Case cOpcValid == "000074"
		cString := STR0074 //"Se o campo 'Forma Trib' for igual a '5 - Luc Pres', o campo 'Trib Per' deve ser preenchido com '0' ou 'P'."
	Case cOpcValid == "000075"
		cString := STR0075 //"Se o campo 'Forma Trib' for igual a '6 - Luc Arb', o campo 'Trib Per' deve ser preenchido com '0' ou 'A'."
	Case cOpcValid == "000076"
		cString := STR0076 //"Se o campo 'Forma Trib' for igual a '7 - Luc Pres/Arb', o campo 'Trib Per' deve ser preenchido com '0', 'A' ou 'P'."
	Case cOpcValid == "000077"
		cString := STR0077 //"Se o campo 'Forma Trib' for igual a '8 - Imune IRPJ', o campo 'Trib Per' não deve ser preenchido."
	Case cOpcValid == "000078"
		cString := STR0078 //"Se o campo 'Forma Trib' for igual a '9 - Isento IRPJ', o campo 'Trib Per' não deve ser preenchido."
	Case cOpcValid == "000079"
		cString := STR0079 //"Se o campo 'Forma Trib' for igual a '2 - Luc Real/Arb', o campo 'Trib Per' deve possuir 'R' ou 'A'."
	Case cOpcValid == "000080"
		cString := STR0080 //"Se o campo 'Forma Trib' for igual a '3 - Luc Pres/Real', o campo 'Trib Per' deve possuir 'P' ou 'R'."
	Case cOpcValid == "000081"
		cString := STR0081 //"Se o campo 'Forma Trib' for igual a '4 - Luc Pres/Real/Arb', o campo 'Trib Per' deve possuir 'P', 'R' ou 'A'."
	Case cOpcValid == "000082"
		cString := STR0082 //"Se o campo 'Forma Trib' for igual a '7 - Luc Pres/Arb', o campo 'Trib Per' deve possuir 'P' ou 'A'."
	Case cOpcValid == "000083"
		cString := STR0083 //"Se o campo Período de Apuração do IRPJ e CSLL for igual a 2-'A' (Anual), o campo deve ser preenchido obrigatoriamente." 
	Case cOpcValid == "000084"
		cString := STR0084 //"Se o campo Período de Apuração do IRPJ e CSLL for igual a 1-'T' (Trimestre), o campo não deve ser preenchido." 
	Case cOpcValid == "000085"
		cString := STR0085 //"Se o campo Forma de Tributação no Período for diferente de 'R' ou 'E', o campo Indicação da Forma de Apuração da Estimativa deve ser preenchido com '0'. 
	Case cOpcValid == "000086"
		cString := STR0086 //"Se o campo Forma de Tributação no Período for igual a 'R' ou 'E', o campo Indicação da Forma de Apuração da Estimativa deve ser preenchido com '0', 'E' ou 'B'. 
	Case cOpcValid == "000087"
		cString := STR0087 //"Se o campo Forma de Tributação do Lucro for igual a '3' (Lucro Presumido/Real), '4' (Lucro/Presumido/Real/Arbitrado), '5' (Lucro Presumido), '7' (Lucro Presumido/Arbitrado), '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido obrigatoriamente." 
	Case cOpcValid == "000088"
		cString := STR0088 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido obrigatoriamente. 
	Case cOpcValid == "000089"
		cString := STR0089 //"Se o campo Atividade Tributada pelo IRPJ e CSLL para Imunes ou Isentas for igual a 3-'D'(Desobrigado), o campo Atividade Tributada pelo IRPJ e CSLL para Imunes ou Isentas deve ser igual ao campo Apuração da CSLL para Imunes e Isentas. 
	Case cOpcValid == "000090"
		cString := STR0090 //"Se o campo Forma de Tributação do Lucro for igual a '6' (Lucro Arbitrado), '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo deve ser preenchido com 2-Não. 
	Case cOpcValid == "000091"
		cString := STR0091 //"Se o campo Tipo da ECF for igual a '0' (ECF de empresa não participante de SCP como sócio ostensivo) ou '2' (ECF da SCP), o campo não deve ser preenchido." 
	Case cOpcValid == "000092"
		cString := STR0092 //"Se o campo Tipo da ECF for igual a '1' (ECF de empresa participante de SCP como sócio ostensivo), o campo deve ser preenchido obrigatoriamente." 
	Case cOpcValid == "000093"
		cString := STR0093 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou o Tipo de Entidade é diferente de '06' (Entidade Fechada de Previdência Complementar), '11' (Associação de Poupança e Empréstimo) e '12'(Entidade Aberta de Previdência Complementar Sem Fins Lucrativos), o campo deve ser preenchido obrigatoriamente." 
	Case cOpcValid == "000094"
		cString := STR0094 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Participações em Consórcios de Empresas deve ser igual a 2-Não." 
	Case cOpcValid == "000095"
		cString := STR0095 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Operações com o Exterior deve ser igual a 2-Não." 
	Case cOpcValid == "000096"
		cString := STR0096 //"Se o campo Operações com o Exterior for igual a 2-Não, o campo Operações com Pessoa Vinculada/Interposta Pessoa/País com Tributação Favorecida também deve ser igual a 2-Não." 
	Case cOpcValid == "000097"
		cString := STR0097 //"Se o campo Operações com o Exterior for igual a 2-Não, o campo PJ Enquadrada nos artigos 48 ou 49 da IN RFB no 1.312/2012 também deve ser igual a 2-Não." 
	Case cOpcValid == "000098"
		cString := STR0098 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Participações no Exterior deve ser igual a 1-Sim." 
	Case cOpcValid == "000099"
		cString := STR0099 //"Se o campo Forma de Tributação do Lucro for igual a '5' (Lucro Presumido) ou '7' (Lucro Presumido/Arbitrado) e Indicador de Optante pelo Refis igual a 2-Não, o campo Participações no Exterior deve ser igual a 1-Sim." 
	Case cOpcValid == "000100"
		cString := STR0100 //"Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral) e a Forma de Tributação do Lucro for diferente de '1' (Lucro Real), '2' (Lucro Real/Arbitrado), '3' (Lucro Presumido/Real) ou '4' (Lucro Presumido/Real/Arbitrado), o campo Atividade Rural deve ser igual a 2-Não." 
	Case cOpcValid == "000101"
		cString := STR0101 //"Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral) e a Forma de Tributação do Lucro for diferente de '1' (Lucro Real), '2' (Lucro Real/Arbitrado), '3' (Lucro Presumido/Real) ou '4' (Lucro Presumido/Real/Arbitrado), o campo Lucro da Exploração deve ser igual a 2-Não." 
	Case cOpcValid == "000102"
		cString := STR0102 //"Se o campo Indicador de Optante pelo Refis for diferente de 1-Sim ou a Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral) ou a Forma de Tributação do Lucro for diferente de '5' (Lucro Presumido) ou '7' (Lucro Presumido/Arbitrado), o campo Isenção e Redução do Imposto para Lucro Presumido deve ser igual a 2-Não." 
	Case cOpcValid == "000103"
		cString := STR0103 //"Se o campo Forma de Tributação do Lucro for diferente de '1' (Lucro Real), '2' (Lucro Real/Arbitrado), '3' (Lucro Presumido/Real) ou '4' (Lucro Presumido/Real/Arbitrado), o campo FINOR/FINAM/FUNRES deve ser igual a 2-Não." 
	Case cOpcValid == "000104"
		cString := STR0104 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Doações a Campanhas Eleitorais deve ser igual a 2-Não." 
	Case cOpcValid == "000105"
		cString := STR0105 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Participação Permanente em Coligadas ou Controladas deve ser igual a 2-Não." 
	Case cOpcValid == "000106"
		cString := STR0106 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Vendas a Empresa Comercial Exportadora deve ser igual a 2-Não." 
	Case cOpcValid == "000107"
		cString := STR0107 //"Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral), o campo Vendas a Empresa Comercial Exportadora deve ser igual a 2-Não." 
	Case cOpcValid == "000108"
		cString := STR0108 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Rendimentos do Exterior ou de Não Residentes deve ser igual a 2-Não." 
	Case cOpcValid == "000109"
		cString := STR0109 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Ativos no Exterior deve ser igual a 2-Não." 
	Case cOpcValid == "000110"
		cString := STR0110 //"Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral), o campo Ativos no Exterior deve ser igual a 2-Não."
	Case cOpcValid == "000111"
		cString := STR0111 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo PJ Comercial Exportadora deve ser igual a 2-Não." 
	Case cOpcValid == "000112"
		cString := STR0112 //"Se o campo Qualificação da Pessoa Jurídica for diferente de '00' (PJ em Geral), o campo PJ Comercial Exportadora deve ser igual a 2-Não." 
	Case cOpcValid == "000113"
		cString := STR0113 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Pagamentos ao Exterior ou a Não Residentes deve ser igual a 2-Não." 
	Case cOpcValid == "000114"
		cString := STR0114 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Comércio Eletrônico e Tecnologia da Informação deve ser igual a 2-Não." 
	Case cOpcValid == "000115"
		cString := STR0115 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Royalties Recebidos do Brasil e do Exterior deve ser igual a 2-Não." 
	Case cOpcValid == "000116"
		cString := STR0116 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Royalties Pagos a Beneficiários do Brasil e do Exterior deve ser igual a 2-Não." 
	Case cOpcValid == "000117"
		cString := STR0117 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Rendimentos Relativos a Serviços, Juros e Dividendos Recebidos do Brasil e do Exterior deve ser igual a 2-Não." 
	Case cOpcValid == "000118"
		cString := STR0118 //"Se o campo Tipo de Entidade for igual a '13' (Fifa e Entidades Relacionadas), o campo Pagamentos ou Remessas a Título de Serviços, Juros e Dividendos a Beneficiários do Brasil e do Exterior deve ser igual a 2-Não." 
	Case cOpcValid == "000119"
		cString := STR0119 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Inovação Tecnológica e Desenvolvimento Tecnológico deve ser igual a 2-Não." 
	Case cOpcValid == "000120"
		cString := STR0120 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Capacitação de Informática e Inclusão Digital deve ser igual a 2-Não." 
	Case cOpcValid == "000121"
		cString := STR0121 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo PJ Habilitada deve ser igual a 2-Não." 
	Case cOpcValid == "000122"
		cString := STR0122 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Pólo Industrial de Manaus e Amazônia Ocidental deve ser igual a 2-Não." 
	Case cOpcValid == "000123"
		cString := STR0123 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Zonas de Processamento de Exportação deve ser igual a 2-Não." 																						
	Case cOpcValid == "000124"
		cString := STR0124 //"O campo 'Cta Contabil' deve representar uma conta analítica." 
	Case cOpcValid == "000125"
		cString := STR0125 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ), o campo Áreas de Livre Comércio deve ser igual a 2-Não." 																																	
	Case cOpcValid == "000126"
		cString := STR0126 //"Deve existir ao menos um Mapeamento Referencial do Saldo Final para o Saldo Contábil Depois do Encerramento do Período." 																																	
	Case cOpcValid == "000127"
		cString := STR0127 //"Se o campo Qualificação do Assinante for igual a 900 (Contador ou Contabilista), o campo Inscrição Contabilista deve ser preenchido obrigatoriamente." 																																	
	Case cOpcValid == "000128"
		cString := STR0128 //"Se o campo Qualificação do Assinante for igual a 900 (Contador ou Contabilista), o campo E-mail do signatário deve ser preenchido obrigatoriamente." 																																	
	Case cOpcValid == "000129"
		cString := STR0129 //"Se o campo Qualificação do Assinante for igual a 900 (Contador ou Contabilista), o campo DDD do signatário deve ser preenchido obrigatoriamente." 																																	
	Case cOpcValid == "000130"
		cString := STR0130 //"Se o campo Qualificação do Assinante for igual a 900 (Contador ou Contabilista), o campo Telefone do signatário deve ser preenchido obrigatoriamente."
	Case cOpcValid == "000131"
		cString := STR0131 //"O campo 'Qualif. do Repres. Legal' é obrigatório quando preenchido o CPF do Representante Legal."
	Case cOpcValid == "000132"
		cString := STR0132 //"O campo Valor do Saldo Societário da Conta não pode ser negativo."
	Case cOpcValid == "000133"
		cString := STR0133 //"O campo Valor do Saldo Fiscal da Conta não pode ser negativo."
	Case cOpcValid == "000134"
		cString := STR0134 //"O valor do campo Diferença de Saldos deve ser igual o valor da subtração entre os campos (Saldo Societário - Saldo Fiscal)."
	Case cOpcValid == "000135"
		cString := STR0135 //"Resultado do Período de Apuração difere do Lucro Líquido Antes do Imposto de Renda somado ao Lucro Arbitrado no Período de Apuração Antes do Imposto (Lei nº 9.430/1996, art. 16, II)"
	Case cOpcValid == "000136"
		cString := STR0136 //"Para registro de 'País' Brasil e 'Ind. Pessoa' igual a '1' (Pessoa Física) o código da 'Qualificação' deve ser 01, 02, 09, 10, 11, 12, 13, 14, 15 ou 17"																																	
	Case cOpcValid == "000137"
		cString := STR0137 //"Para registro de 'País' Brasil e 'Ind. Pessoa' igual a '2' (Pessoa Jurídica) o código da 'Qualificação' deve ser 03 ou 04"    																																	
	Case cOpcValid == "000138"
		cString := STR0138 //"Para registro de 'País' diferente de Brasil e 'Ind. Pessoa' igual a '1' (Pessoa Física) o código da 'Qualificação' deve ser 05 ou 06"  																																	
	Case cOpcValid == "000139"
		cString := STR0139 //"Para registro de 'País' diferente de Brasil e 'Ind. Pessoa' igual a '2' (Pessoa Jurídica) o código da 'Qualificação' deve ser 07 ou 08" 																																	
	Case cOpcValid == "000140"
		cString := STR0140 //"Para registro de 'Pais' Brasil e 'Ind. Pessoa' igual a '1' (Pessoa Física) o código da 'Qualificação' deve ser 01, 02 ou 09" 																																	
	Case cOpcValid == "000141"
		cString := STR0141 //"Para registro de 'Pais' Brasil e 'Ind. Pessoa' igual a '2' (Pessoa Jurídica) o código da 'Qualificação' deve ser 03 ou 04"
	Case cOpcValid == "000142"
		cString := STR0142 //"Para registro de 'Pais' diferente de Brasil e 'Ind. Pessoa' igual a '1' (Pessoa Física) o código da 'Qualificação' deve ser 05 ou 06"
	Case cOpcValid == "000143"
		cString := STR0143 //"Para registro de 'Pais' diferente de Brasil e 'Ind. Pessoa' igual a '2' (Pessoa Jurídica) o código da 'Qualificação' deve ser 07 ou 08" 
	Case cOpcValid == "000144"
		cString := STR0144 //"O saldo final do ativo deve ser igual ao saldo final do passivo, caso o Período de Apuração seja igual a “A00” ou “A12” ou “T04”."
	Case cOpcValid == "000145"
		cString := STR0145 //"O saldo inicial do ativo deve ser igual ao saldo inicial do passivo, caso o Período de Apuração seja igual a “A00” ou “A01” ou “A02” ou “A03” ou “A04” ou “A05” ou “A06” ou “A07” ou “A08” ou “A09” ou “A10” ou “A11” ou “A12” ou “T01”."                                                                                                                                                                                                                                  
	Case cOpcValid == "000146"
		cString := STR0146 // "Para 'Cod. Qualif' '900' o 'Tipo Estab.' deve ser igual a '1' e possuir um CPF válido" 	
	Case cOpcValid == "000147"
		cString := STR0147 // "O valor do 'Perc Subtotal' difere do resultado do 'SubTotal' pelo 'B.de Calculo' "
	Case cOpcValid == "000148"
		cString := STR0148 //"Se o tipo de relacionamento for igual a '1' (com conta da parte B), o Valor deve ser menor que o Valor Total dos Lançamentos da Conta da Parte B."
	Case cOpcValid == "000149"
		cString := STR0149 //"Se o tipo de relacionamento for igual a '2' (com conta contábil), o Valor deve ser menor que o somatório do Valor da Conta."
	Case cOpcValid == "000150"
		cString := STR0150 //"Se o tipo de relacionamento for igual a '3' (com conta da parte B e conta contábil), o Valor deve ser menor que o Valor Total dos Lançamentos e menor que o somatório do Valor da Conta." 
	Case cOpcValid == "000151"
		cString := STR0151 //"Se o tipo do lançamento for igual a 'P' (compensação de prejuízo), o tipo de relacionamento deve ser igual a '1' (com conta da parte B)."
	Case cOpcValid == "000152"
		cString := STR0152 //"O campo Histórico do lançamento no e-Lalur não deve está preenchido quando o Tipo de Lançamento for igual a 'E'-Exclusão."                                                                                                                                                               	
	Case cOpcValid == "000153"
		cString := STR0153 //"Conteúdo do campo não condiz com as opções possiveis ('01,02,03,04,06,08,09,10,11 ou 99')"
	Case cOpcValid == "000154"
		cString := STR0154 //"Conteúdo do campo não condiz com as opções possíveis ('07 ou 99')"
	Case cOpcValid == "000155"
		cString := STR0155 //"Conteúdo do campo não condiz com as opções possíveis ('1, 2, 3, 4 ou 99')"
	Case cOpcValid == "000156"
		cString := STR0156 //"Conteúdo do campo não condiz com as opções possíveis ('1, ou 99')"
	Case cOpcValid == "000157"
		cString := STR0157 //"Conteúdo do campo não condiz com as opções possíveis ('3, 5 ou 99')"   
	Case cOpcValid == "000158"
		cString := STR0158 //"Conteúdo do campo não condiz com as opções possíveis ('3 ou 99')"
	Case cOpcValid == "000159"
		cString := STR0159 //"Conteúdo do campo não condiz com as opções possíveis ('5 ou 99')"   
	Case cOpcValid == "000160"
		cString := STR0160 //"Conteúdo do campo não condiz com as opções possíveis ('99')"
	Case cOpcValid == "000161"
		cString := STR0161 //"Saldo do Ativo deve ser Igual ao Passivo (soma dos campos 'Saldo Ini' e 'Saldo Fin' devem ser iguais de acordo com a natureza) para o periodo T01"
	Case cOpcValid == "000162"
		cString := STR0162 //"Saldo do Ativo deve ser Igual ao Passivo (soma dos campos 'Saldo Ini' e 'Saldo Fin' devem ser iguais de acordo com a natureza) para o periodo T04"
	Case cOpcValid == "000163"
		cString := STR0163 //"O valor do campo deve ser diferente do CNPJ do declarante." 
	Case cOpcValid == "000164"
		cString := STR0164 //"Quando campo 'Org.Pub' for igual a 'Sim', o valor do campo 'Cod.Receita' deve ser igual a 4085 ou 4397 ou 5928 ou 5936 ou 5944 ou 6147 ou 6175 ou 6188 ou 6190 ou 6228 ou 6256 ou 8739 ou 8767 ou 8850 ou 8863 ou 9060 ou 9997."
	Case cOpcValid == "000165"
		cString := STR0165 //"Quando campo 'Org.Pub' for igual a 'Não', o valor do campo 'Cod.Receita' deve ser igual a 0916 ou 0924 ou 1708 ou 3277 ou 3426 ou 5204 ou 5232 ou 5273 ou 5557 ou 5706 ou 5928 ou 5936 ou 5944 ou 5952 ou 5987 ou 6800 ou 6813 ou 8045 ou 8468 ou 9385 ou 9998 ou 9999."
	Case cOpcValid == "000166"
		cString := STR0166 //"Quando o campo 'IR.Ret.Fonte' está preenchido, o valor do campo 'Cod.Receita' deve ser igual a 5928 ou 5936 ou 5944 ou 6147 ou 6175 ou 6188 ou 6190 ou 6256 ou 8739 ou 8767 ou 8850 ou 8863 ou 9060 ou 9997 ou 0916 ou 0924 ou 1708 ou 3277 ou 3426 ou 5204 ou 5232 ou 5273 ou 5557 ou 5706 ou 5928 ou 5936 ou 5944 ou 6800 ou 6813 ou 8045 ou 8468 ou 9385 ou 9999."
	Case cOpcValid == "000167"
		cString := STR0167 //"Quando o campo 'CSLL.Ret.Fon' está preenchido, o valor do campo 'Cod.Receita' deve ser igual a 4085 ou 4397 ou 5928 ou 5936 ou 5944 ou 6147 ou 6175 ou 6188 ou 6190 ou 6228 ou 8739 ou 8767 ou 8850 ou 8863 ou 9060 ou 9997 ou 5952 ou 5987 ou 9998."
	Case cOpcValid == "000168"
		cString := STR0168 //"O 'Lucro Bruto' corresponde ao resultado da operação substração 'Rec. Líquida' por 'Valor Custos' "
	Case cOpcValid == "000169"
		cString := STR0169 //"O 'Lucro Oper' não corresponde ao resultado da operação 'Lucro Bruto' + 'Rec Auf + Rec Oper - Desp Fin - Desp Oper'"
	Case cOpcValid == "000170"
		cString := STR0170 //"O 'Lucro Ant IR' não corresponde ao resultado da operação 'Lucro Oper' + 'Rec Part' + 'Outras Rec' - 'Outras Desp'"
	Case cOpcValid == "000171"
		cString := STR0171 //"O 'Lucro Per Ap' não corresponde ao resultado da operação 'Lucro Ant IR' - 'Imp Devido'"
	Case cOpcValid == "000172"
		cString := STR0172 //"O 'Luc apos Imp' não corresponde ao resultado da operação 'Luc ant Imp' - 'Imp Dev Arb'" 
	Case cOpcValid == "000173"
		cString := STR0173 //"Não deve existir registros de 'Demonstrativo de Resultados Imp. Pg.Exterior', para 'Ind. Controle' igual a '6'"
	Case cOpcValid == "000174"
		cString := STR0174 //"Quando o valor em 'Res Invest' for positivo e maior que o valor em 'Res Neg', o campo 'Res a Tribut' deve corresponder ao resultado da subtração 'Res Invest' por 'Res Neg'" 
	Case cOpcValid == "000175"
		cString := STR0175 //"Quando o valor em 'Res Invest' for negativo ou possuir valor menor ou igual ao valor em 'Res Neg', o campo 'Res a Tribut' deve corresponder a zero"
	Case cOpcValid == "000176"
		cString := STR0176 //"Não deve existir registros de 'Demonstrativo de Res. Ext. Colig. Regime Caixa', para 'Ind. Controle' diferente de '6'"
	Case cOpcValid == "000177"
		cString := STR0177 //"Não deve existir registros de 'Demonstrativo de Consolidação', para 'Ind. Controle' igual a '6' ou 'Ind. Consolid.' igual a '2' "
	Case cOpcValid == "000178"
		cString := STR0178 //"Não deve existir registros de 'Demonstrativo de Rendas Ativas e Passivas', para 'Ind. Controle' igual '6'"
	Case cOpcValid == "000179"
		cString := STR0179 //"O valor da 'Renda Ativa' não corresponde ao resultado da subtração 'Renda Total' por 'Rend Passiva'"
	Case cOpcValid == "000180"
		cString := STR0180 //"O valor da 'Rend Ativa R' não corresponde ao resultado da subtração 'Renda Tot Re' por 'Rend P.Reais'"
	Case cOpcValid == "000181"
		cString := STR0181 //"O valor da 'Percentual' não corresponde ao resultado da divisão 'Renda Ativa' por 'Renda Total' "
	Case cOpcValid == "000182"
		cString := STR0182 //"Não deve existir registros de 'Demonstrativo de Estrutura Societária', para 'Ind. Controle' igual '6'"
	Case cOpcValid == "000183"
		cString := STR0183 //'O Campo "Num Reg Cart" deve ser preenchido quando "Sum Cartorio" for igual a "1-Sim".'       
	Case cOpcValid == "000184"
		cString := STR0184 //'O Campo "Num Reg Cart" não deve ser preenchido quando "Sum Cartorio" for igual a "2-Não".'    
	Case cOpcValid == "000185"
		cString := STR0185 //'O Campo "Nome Cartor" deve ser preenchido quando "Sum Cartorio" for igual a "1-Sim".'        
	Case cOpcValid == "000186"
		cString := STR0186 //'O Campo "Num Cartor" não deve ser preenchido quando "Sum Cartorio" for igual a "2-Não".'   
	Case cOpcValid == "000187"
		cString := STR0187 //"O valor de Vl.Saldo Fin deve ser igual ao valor de Vl.Saldo Ini somado aos valores dos campos Vl.Debito e Vl.Credito, considerando os indicadores de saldo devedor e credor do saldo inicial e do saldo final."                                                                                                                                                                                                                                                                                                    
	Case cOpcValid == "000188"
		cString := STR0188 //'O Campo "Num Processo" deve ser preenchido quando "Laudo RFB" for igual a "1-Sim".'    
	Case cOpcValid == "000189"
		cString := STR0189 //'O Campo "Num Processo" não deve ser preenchido quando "Laudo RFB" for igual a "2-Não".'    
	Case cOpcValid == "000190"
		cString := STR0190 //"Não deve existir registros de 'Demonstrativo de Prejuízos Acumulados', para 'Ind. Controle' igual '6'"
	Case cOpcValid == "000191"
		cString := STR0191 //'O campo "Dt Abertura" não pode ser maior que o campo "Dt Encerram"'                    
	Case cOpcValid == "000192"
		cString := STR0192 //'O campo CNPJ está diferente do cadastro de empresas (SM0).'      
	Case cOpcValid == "000193"
		cString := STR0193 //"O Campo Res. Patrim. deve ser vazio quando a Forma de Tributação for Igual a 5-Presumido,6-Arbitrado,7-Presumido/Arbitrado"        
	Case cOpcValid == "000194"
		cString := STR0194 //"Período não encontrado na tabela de parâmetros ECF (CHD)"   
	Case cOpcValid == "000195"
		cString := STR0195 //"O campo CNPJ Líder está diferente do cadastro de empresas (SM0)."          
	Case cOpcValid == "000196"
		cString := STR0196 //'O campo "Rec Declaran" deve ser maior que o campo "Rec Consórc"'    
	Case cOpcValid == "000197"
		cString := STR0197 //'Quando o Campo "Cond. Decla" for igual a "1-Líder" deve obrigatoriamente existir registros na Grid "Participantes do Consórcio"'    
	Case cOpcValid == "000198"
		cString := STR0198 //"O somatório do campo 'Rec Particip' + campo 'Rec Declaram' deve ser igual ao valor do campo 'Rec. Consórc.'"
	Case cOpcValid == "000199"
		cString := STR0199 //"A Soma dos Campos 'Título Vlr S' e 'Vlr Sld Fis' deve ser igual ao campo 'Vlr Dif Sld'"
	Case cOpcValid == "000200"
		cString := STR0200 //'O campo "Cod SubConta" deve ser preenchido quando "Método Ctl" for igual a 1-Contr.subcta ou 2-Contr.subct,3º/4º art. 11'
	Case cOpcValid == "000201"
		cString := STR0201 //'O campo "Cod SubConta" não deve ser preenchido quando "Método Ctl" for igual a 3-Não contr. subcta, 5º art. 11 ou 4-Não contr. subconta-s/ ajustes'            
	Case cOpcValid == "000202"
		cString := STR0202 //'O campo "C Custo Sub" não deve ser preenchido quando "Método Ctl" for igual a 3-Não contr. subcta, 5º art. 11 ou 4-Não contr. subconta-s/ ajustes'                                                                                                                                                                                                                                                                                                                                                             
	Case cOpcValid == "000203"
		cString := STR0203 //"O Campo 'Mês' está fora do intervalo entre as Datas Inicial e Final do bloco de abertura (Registro 0000)"                                                                                                                                                                                                                                                                                                                                                                                                         
	Case cOpcValid == "000204"
		cString := STR0204 //"O Campo 'Tipo' só pode ser igual a '1 - Rendimentos recebidos' quando o campo 'Rend Exter' do bloco de abertura (Registro 0020) for igual a '1 - Sim'."                                                                                                                                                                                                                                                                                                                                                                                                         
	Case cOpcValid == "000205"
		cString := STR0205 //"O Campo 'Tipo' só pode ser igual a '2 - Pagamentos' quando o campo 'Pag Exterior' do bloco de abertura (Registro 0020) for igual a '1 - Sim'."                                                                                                                                                                                                                                                                                                                                                                                                         
	Case cOpcValid == "000206"
		cString := STR0206 //"O Campo 'Forma' só pode ser igual a '4 - Depósito' quando o campo 'Tipo' for igual a '2 - Rendimentos recebidos'."                                                                                                                                                                                                                                                                                                                                                                                                         
	Case cOpcValid == "000207"
		cString := STR0207 //"O Campo 'Forma' só pode ser igual a '5 - Utilização de Recursos Mantidos no Exterior' quando o campo 'Tipo' for igual a '1 - Pagamentos'."
	Case cOpcValid == "000208"
		cString := STR0208 //"O Periodo de apuração do registro não corresponde com a Forma de Apuração 'Apur IRPJ/CS' do cadastro de abertura (Bloco 0 - Parâmetros de Abertura)"    
	Case cOpcValid == "000209"
		cString := STR0209 //"O campo 'Apur Est' (cadastro de parâmetros de abertura) deve estar preenchido com B na posição destinada ao perído informado em 'Per Apuração'" 
	Case cOpcValid == "000210"
		cString := STR0210 //"O campo 'Apur Est' (cadastro de parâmetros de abertura) deve estar preenchido com R na posição destinada ao perído informado em 'Per Apuração'"   
	Case cOpcValid == "000211"
		cString := STR0211 //"Período de Apuração Inválido"           
	Case cOpcValid == "000212"
		cString := STR0212 //"Perído compreendido entre a 'Dt Saldo Ini' e 'Dt Saldo Fin' não encontrado no cadastro de abertura (Bloco 0 - Parâmetros de Abertura)"        
	Case cOpcValid == "000213"
		cString := STR0213 //"O campo  'Apur IRPJ/CS' (Bloco 0 - Cadastro de Parâmetros de Abertura) deve estar preenchido para validação do período de apuração deste registro" 
	Case cOpcValid == "000214"
		cString := STR0214 //"Perído de Apuração Inválido. Registros permitidos 'A00,T1,T2,T3 e T4'"  
	Case cOpcValid == "000215"
		cString := STR0215 //"Para validação desse registro o Bloco 0 (Cadastro de Parâmetros de Abertura) deve conter uma dessas configurações: Campo 'Apur IRPJ/CS' igual '1' (Trimestral) Ou Campo 'Apur IRPJ/CS' igual a '2-Anual' e o campo  'Forma Trib' igual a '2-Luc Real/Arb'"   
	Case cOpcValid == "000216"
		cString := STR0216 //"O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar preenchido com 'A' na posição destinada ao perído informado em 'Per Apuração'"   
	Case cOpcValid == "000217"
		cString := STR0217 //"O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar preenchido com 'P' na posição destinada ao perído informado em 'Per Apuração'"  
	Case cOpcValid == "000218"
		cString := STR0218 //"O campo 'Apur Est' (Bloco 0 - Cadastro de Parâmetros de abertura) deve estar de acordo com o campo 'Per Apuração' de acordo com as regras estabelecidas para esse campo"  
	Case cOpcValid == "000219"
		cString := STR0219 //"O Campo 'Forma' só pode ser igual a '5 - Utilização de Recursos Mantidos no Exterior' quando o campo 'Tipo' for igual a '1 - Pagamentos'."
	Case cOpcValid == "000220"
		cString := STR0220 //"Não deve haver um registro de lançamento da Parte B quando Indicador de Relacionamento do Lançamento da Parte A for igual a '2' ou '4'."
	Case cOpcValid == "000221"
		cString := STR0221 //"Não deve haver registro de conta contábil da Parte A quando Indicador de Relacionamento do Lançamento da Parte A for igual a '1' ou '4'."
	Case cOpcValid == "000222"
		cString := STR0222 //"O campo 'Qual. Representante Legal' não deve ser preenchido caso 'CPF Representante Legal' não seja preenchido." 
	Case cOpcValid == "000223"
		cString := STR0223 //"O campo 'Valor' deve ser preenchido obrigatoriamente quando o Código de Lançamento possuir o tipo da linha diferente de 'R'."
	Case cOpcValid == "000224"
		cString := STR0224 //"O campo 'Fim da Vigência' deve ser maior ou igual ao campo 'Início da Vigência'."
	Case cOpcValid == "000225"
		cString := STR0225 //"Quando o campo Indicador de Consolidação for igual a '2 - N=Não', o campo Motivo da Não Consolidação deve ser preenchido obrigatoriamente."
	Case cOpcValid == "000226"
		cString := STR0226 //"Quando o campo Indicador de Consolidação for igual a '1 - S=Sim', o campo Motivo da Não Consolidação não deve ser preenchido."
	Case cOpcValid == "000227"
		cString := STR0227 //"Para 'Tipo Estab.' igual a '2' o CNPJ deve ser  válido e o campo CPF não deve ser informado" 
	Case cOpcValid == "000228"
		cString := STR0228 //"O campo 'Hist Lcto' deve ser preenchido somente quando o Código do Lançamento do e-Lalur possuir o 'Tipo de Lançamento' igual a 'E'-Exclusão." 
	Case cOpcValid == "000229"
		cString := STR0229 //"O registro Subcontas Correlatas(J053) deve existir somente quando o Tipo da Conta Contábil for igual a 'A'-Analítica." 
	Case cOpcValid == "000230"
		cString := STR0230 //"A 'Subcta Corr' deve pertencer a uma única conta no plano de contas 'Código'(J050)." 
	Case cOpcValid == "000231"
		cString := STR0231 //"Essa conta(J050) possui registros filhos(J053) e já foi subconta em outro grupo 'Cod. Grupo'."
	Case cOpcValid == "000232"
		cString := STR0232 //"O campo 'Vlr Tot Lcto' do registro M355 deve ser menor ou igual ao saldo disponível (Soma do campo 'Vl. Lançam.' referente a mesma Cta Lançam.) do mesmo período de apuração informada no registro M410."
	Case cOpcValid == "000233"
		cString := STR0233 //"O campo 'Hist Lcto' deve ser preenchido somente quando o Código do Lançamento do e-Lalur possuir o 'Tipo de Lançamento' igual a 'E'-Exclusão e o 'Tipo Relac' igual a '4'-Sem Relacionamento." 
	Case cOpcValid == "000234"
		cString := STR0234 //"Deve existir somente uma 'Nat Subcta' '90' ou '91' ou '92' ou '93' ou '95' para cada conta(J050)." 
	Case cOpcValid == "000235"
		cString := STR0235 //"O campo Dif FCONT deve estar preenchido quando o campo Op Ext RTT for igual a '1 - Sim'."
	Case cOpcValid == "000236"
		cString := STR0236 //"Os valores 'R' e 'E' não devem aparecer simultaneamente em 'Trib Per'."
	Case cOpcValid == "000237"
		cString := STR0237 //"O valor 'P' deve aparecer primeiro quando existir 'R', 'E' ou 'P' em 'Trib Per'."
	Case cOpcValid == "000238"
		cString := STR0238 //"Os trimestres fora do período de escrituração devem ser preenchidos com '0' em 'Trib Per'."
	Case cOpcValid == "000239"
		cString := STR0239 //"O campo 'Trib Per' deve estar preenchido quando 'Forma Trib' for diferente de '8 - Imune IRPJ' ou '9 - Isento IRPJ'."
	Case cOpcValid == "000240"
		cString := STR0240 //"O campo 'Data de Início de Ato' deve ser menor ou igual ao campo 'Período Final' da Escrituração( TAFA372 - Parâmetros de Abertura ECF )."
	Case cOpcValid == "000241"
		cString := STR0241 //"O campo 'Data de Início de Ato' deve ser menor ou igual ao campo 'Data Final de Ato'."
	Case cOpcValid == "000242"
		cString := STR0242 //"O campo 'Data Final de Ato' deve ser menor ou igual ao campo 'Período Final' da Escrituração( TAFA372 - Parâmetros de Abertura ECF )."
	Case cOpcValid == "000243"
		cString := STR0243 //"O campo 'Ano-calendário Inicial' deve ser menor ou igual ao campo 'Ano-calendário Final'."
	Case cOpcValid == "000244"
		cString := STR0244 //"O campo 'Beneficiários Ger Pas Ter' deve estar preenchido quando o campo 'Geração Passivo Terceiros' estiver preenchido com '1 - Sim'."
	Case cOpcValid == "000245"
		cString := STR0245 //"O campo 'Percentual Redução Ativos' deve estar preenchido quando o campo 'Redução de Ativos' estiver preenchido com '1 - Sim'."
	Case cOpcValid == "000246"
		cString := STR0246 //"O campo 'Percentual Redução Ativos' deve ser preenchido com um valor maior que zero."
	Case cOpcValid == "000247"
		cString := STR0247 //"O campo 'Data Final Apuração Lucro' deve ser menor que o campo 'Período Inicial' da Escrituração( TAFA372 - Parâmetros de Abertura ECF )."
	Case cOpcValid == "000248"
		cString := STR0248 //"Esta filial é uma SCP e por isso não pode ser parametrizada como matriz."
	Case cOpcValid == "000249"
		cString := STR0249 //"Já existe uma Filial cadastrada como Matriz e só é permitida uma Filial Matriz por empresa."
	Case cOpcValid == "000250"
		cString := STR0250 //"Esta filial já esta configurada como SCP de outra filial."
	Case cOpcValid == "000251"
		cString := STR0251 //"A filial SCP precisa ser da mesma empresa da filial do sócio ostensivo."
	Case cOpcValid == "000252"
		cString := STR0252 //"A filial matriz não pode ser relacionada como SCP."
	Case cOpcValid == "000253"
		cString := STR0253 //"Esta filial não pode ser associada como SCP dela mesma."
	Case cOpcValid == "000254"
		cString := STR0254 //"Uma filial sócio ostensivo não pode ser associada como filial SCP."
	Case cOpcValid == "000255"
		cString := STR0255 //"Uma filial SCP não pode ser sócio ostensivo de outra filial SCP."
	Case cOpcValid == "000256"
		cString := STR0256 //"Somente o valor de entrada ou de saída deverá estar preenchido"
	Case cOpcValid == "000257"
		cString := STR0257 // "Se 0010.COD_QUALIF_PJ == 02 (PJ Componente do Sistema Financeiro) ou 03 Sociedades Seguradoras, de Capitalização ou Entidade Aberta de Previdência Complementar) obrigatoriamente 0020.IND_ATIV_RURAL deve ser NÃO "
	Case cOpcValid == "000258"
		cString := STR0258 // "Se o Tipo de entidade for (CIO e Entidades Relacionadas). Obrigatóriamente o campo CHD_FORTRB Forma de tributação deve ser igual a 9 - Isenta IRPJ" 
	Case cOpcValid == "000259"
		cString := STR0259 // "Se o tipo de entidade for (CIO e Entidades Relacionadas). Obrigatóriamente o campo CHD_INDPJH Pj Habilidada deve ser 1-SIM"
	Case cOpcValid == "000260"
	   cString := STR0260 //"Se Se X40.PAIS igual a “105” (Brasil), o campo X340.CNPJ deve estar preenchido"
	Case cOpcValid == "000261"
		cString := STR0261 //"Se X340.CNPJ estiver preenchido, X340.NIF deve estar preenchido."
	Case cOpcValid == "000262"
		cString := STR0262 //"Se o campo Forma de Tributação do Lucro for igual a '8' (Imune de IRPJ) ou '9' (Isento do IPRJ) e o campo Apur CSLL Imunes/Isentas for igual a '3' (Desobrigada), o campo não pode ser preenchido, obrigatoriamente deve estar em branco.
	Case cOpcValid == "000263"
	 	cString := STR0263 //Se o Campo W100.IND_CONTROLADORA é igual a “S” (Sim) o Campo NOME_CONTROLADORA não deve ser preecnhido.
	Case cOpcValid == "000264"
	  	cString := STR0264 //Se o Campo W100.IND_CONTROLADORA é igual a “S” (Sim) o Campo JURISDICAO_CONTROLADORA não deve estar preecnhido.
	Case cOpcValid == "000265"
	  	cString := STR0265 //Se o Campo W100.IND_CONTROLADORA é igual a “S” (Sim) o Campo TIN_CONTROLADORA não deve estar preecnhido.
	Case cOpcValid == "000266"
	  	cString := STR0266 //Se o Campo JURISDICAO_CONTROLADORA é igual a “BR” (Sim) o Campo TIN_CONTROLADORA deve estar preecnhido com um CNPJ
	Case cOpcValid == "000267"
	  	cString := STR0267 //Se o Campo W100.IND_CONTROLADORA é igual a “N” o campo W100.IND_ENTREGA não vede estar preechido
	Case cOpcValid == "000268"
	  	cString := STR0268 //Se o campo W100.JURISDICAO_CONTROLADORA for igual a 'BR' (Brasil), o campo W100.IND_ENTREGA deve ser igual a "1" ou "2"
	Case cOpcValid == "000269"
	  	cString := STR0269 //Se o campo W100.IND_CONTROLADORA for igual a 'S'(Sim), o campo W100.IND_ENTREGA deve ser igual a "1" ou "2" 
	Case cOpcValid == "000270"
	  	cString := STR0270 //Se o campo W100.IND_ENTREGA for igual a '3' (Própria entidade declarante) ou '4' (Outra entidade), o campo W100.IND_MODALIDADE deve estar preenchido.
	Case cOpcValid == "000271"
	  	cString := STR0271 //Se o campo W100.IND_ENTREGA for igual '1' o campo W100.IND_MODALIDADE não deve estar preenchido.
	Case cOpcValid == "000272"
	  	cString := STR0272 //Se o campo W100.IND_ENTREGA for igual a '4' (Outra entidade), o campo W100.NOME_SUBSTITUTA deve estar preenchido."
	Case cOpcValid == "000273"
	  	cString := STR0273 //Se o campo W100.IND_ENTREGA for diferente de '4' (Outra entidade), o campo W100.NOME_SUBSTITUTA não deve estar preenchido."
	Case cOpcValid == "000274"
	  	cString := STR0274 //Se o campo W100.IND_ENTREGA for igual a '4' (Outra entidade), o campo W100.JURISDICAO_SUBSTITUTA deve estar preenchido.
	Case cOpcValid == "000275"
	  	cString := STR0275 //Se o campo W100.IND_ENTREGA for diferente de '4' (Outra entidade), o campo W100.JURISDICAO_SUBSTITUTA não deve estar preenchido.
	Case cOpcValid == "000276"
	  	cString := STR0276 //Se o campo W100.IND_ENTREGA for igual a '4' (Outra entidade) e W100.IND_MODALIDADE for igual a '2' (Preenchimento local), o W100.JURISDICAO_SUBSTITUTA deve ser igual a 'BR' Brasil.
	Case cOpcValid == "000277"
	  	cString := STR0277 //Se o campo W100.IND_ENTREGA for igual a '4' (Outra entidade) e W100.JURISDICAO_SUBSTITUTA for igual a 'Brasil', o campo W100.TIN_SUBSTITUTA deve estar preenchido.
	Case cOpcValid == "000278"
	  	cString := STR0278 //Se o campo W100.IND_ENTREGA for diferente de "4" (Outra entidade) ou W100.JURISDICAO_SUBSTITUTA for diferente de “Brasil”, o campo W100.TIN_SUBSTITUTA não deve estar preenchido.
	Case cOpcValid == "000279"
	  	cString := STR0279 //Se o campo W100.JURISDICAO_CONTROLADORA for igual a 'BR' (Brasil), e o campo W100.TIN_SUBSTITUTA estiver preenchido com um CNPJ. O CNPJ básico informado deve ser igual ao CNPJ básico do declarante da ECF, informado em 0000.CNPJ."
	Case cOpcValid == "000280"
	  	cString := STR0280 //Se o campo [W100.IND_CONTROLADORA for igual a 'S' (Sim) e W100.IND_ENTREGA for igual a "2" (Controladora final do grupo multinacional)] ou [W100.IND_ENTREGA é igual a “3” (Própria entidade declarante da ECF) e W100.IND_MODALIDADE está preenchido], se o campo W100.DT_INI está preenchido.
	Case cOpcValid == "000281"
	  	cString := STR0281 //Se o campo [W100.IND_CONTROLADORA for igual a "N" (Não) ou W100.IND_ENTREGA for diferente de "2"] e [W100.IND_ENTREGA for diferente de '3' (Própria entidade declarante da ECF) ou W100.IND_MODALIDADE não estiver preenchido], se o campo W100.DT_INI não deve estar preenchido.
	Case cOpcValid == "000282"
	  	cString := STR0282 //A diferença entre W100.DT_FIN e W100.DT_INI não pode ser maior que 366 dias (O período da Declaração País-a-País deve ser menor ou igual a 1 ano).
	Case cOpcValid == "000283"
	  	cString := STR0283 //Se o campo W100.IND_CONTROLADORA for igual a 'S' (Sim) ou [W100.IND_ENTREGA for igual a '3' (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver preenchido], o campo W100.DT_FIN deve estar preenchido.
	Case cOpcValid == "000284"
	  	cString := STR0284 //Se o campo W100.IND_CONTROLADORA estiver igual a "N" (Não) e [W100.IND_ENTREGA for diferente de '3' (Própria entidade declarante da ECF) ou W100.IND_MODALIDADE não estiver preenchido], o campo W100.DT_FIN não deve estar preenchido.
	Case cOpcValid == "000285"
	  	cString := STR0285 //O campo W100.DT_FIN deve ser maior ou igual a W100.DT_INI"
	Case cOpcValid == "000286" 
	  	cString := STR0286 //Se o campo W100.IND_CONTROLADORA for igual a 'S' (Sim) ou (W100.IND_ENTREGA for igual a '3' (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver preenchido), o campo W100.TIP_MOEDA deve estar preenchido.
	Case cOpcValid == "000287"
	  	cString := STR0287 //Se o campo W100.IND_CONTROLADORA for igual a "N" (Não) ou (W100.IND_ENTREGA for diferente de '3' (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver vazio), o campo W100.TIP_MOEDA não deve estar preenchido.
	Case cOpcValid == "000288"
	  	cString := STR0288 //Se o campo W100.IND_CONTROLADORA for igual a 'S' (Sim) ou (W100.IND_ENTREGA for igual a '3' (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver preenchido), o campo W100.IND_IDIOMA deve estar preenchido."
	Case cOpcValid == "000289"
	  	cString := STR0289 //Se o campo W100.IND_CONTROLADORA for igual a "N" (Não) ou (W100.IND_ENTREGA for diferente de '3' (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver vazio), o campo W100.IND_IDIOMA não deve estar preenchido."		
	Case cOpcValid == "000290"
	  	cString := STR0290 //Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_REC_NAO_REL_EST não deve estar preenchido.
	Case cOpcValid == "000291"
	  	cString := STR0291 //Se o campo W100.JURISDICAO_CONTROLADORA for igual a 'BR' (Brasil), o campo W100.TIN_CONTROLADORA deve conter o CNPJ básico igual ao o informado em 0000.CNPJ.
	Case cOpcValid == "000292"
	  	cString := STR0292 //Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_REC_NAO_REL_EST não deve estar preenchido.
	Case cOpcValid == "000293"
	  	cString := STR0293 //Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_REC_REL_EST não deve estar preenchido.
	Case cOpcValid == "000294"
	  	cString := STR0294 //O campo W200.VL_REC_TOTAL_EST deve ser igual ao somatório dos campos W200.VL_REC_NAO_REL_EST e W200.VL_REC_REL_EST.
	Case cOpcValid == "000295"
	  	cString := STR0295 //O campo W200.VL_REC_TOTAL deve ser igual ao somatório dos campos W200.VL_REC_NAO_REL_EST e W200.VL_REC_REL_EST."
	Case cOpcValid == "000296"
	  	cString := STR0296 //Se o campo W100.TIP_MOEDA for diferente de "Reais", o campo W200.VL_LUC_PREJ_ANTES_IR_EST deve estar preenchido."
	Case cOpcValid == "000297"
	  	cString := STR0297 //Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_LUC_PREJ_ANTES_IR_EST não deve estar preenchido
	Case cOpcValid == "000298"
	  	cString := STR0298 // Se o campo W100.TIP_MOEDA for diferente de 'Reais',  o campo W200.VL_IR_PAGO_EST deve estar preenchido.
	Case cOpcValid == "000299"
	  	cString := STR0299 //Se o campo W100.TIP_MOEDA for igual a 'Reais', o campo W200.VL_IR_PAGO_EST não deve estar preenchido. 
	Case cOpcValid == "000300"
	  	cString := STR0300 //Se o campo W100.TIP_MOEDA for diferente de 'Reais', o campo W200.VL_IR_DEVIDO_EST deve estar preenchido.
	Case cOpcValid == "000301"
	  	cString := STR0301 //Se o campo W100.TIP_MOEDA for igual a 'Reais', o campo W200.VL_IR_DEVIDO_EST não deve estar preenchido.
	Case cOpcValid == "0003021"
	  	cString := STR0302 //Se o campo W100.TIP_MOEDA for diferente de 'Reais', o campo W200.VL_CAP_SOC_EST deve estar preenchido.
	Case cOpcValid == "000303"
	  	cString := STR0303 //Se o campo W100.TIP_MOEDA for igual a 'Reais', o campo W200.VL_CAP_SOC_EST não deve estar preenchido.
	Case cOpcValid == "000304"
	  	cString := STR0304 //Se o campo W100.TIP_MOEDA for diferente de 'Reais', se o campo W200.VL_LUC_ACUM_EST deve estar preenchido.
	Case cOpcValid == "000305"
	  	cString := STR0305 //Se o campo W100.TIP_MOEDA for igual a 'Reais', o campo W200.VL_LUC_ACUM_EST não deve estar preenchido.
	Case cOpcValid == "000306"
	  	cString := STR0306 //Se o campo W100.TIP_MOEDA for diferente de 'Reais', o campo W200.VL_ATIV_TANG_EST deve estar preenchido.
	Case cOpcValid == "000307"
	  	cString := STR0307 //Se o campo W100.TIP_MOEDA for igual a 'Reais', o campo W200.VL_ATIV_TANG_EST não deve estar preenchido.
	Case cOpcValid == "000308"
	  	cString := STR0308 //Deve existir apenas 1 registro W250 com o TIN informado em W250.TIN. A regra não é executada caso W250.TIN seja igual a 'NOTIN'.
	Case cOpcValid == "000309"
	  	cString := STR0309 //Se o campo W250.JURISDICAO_TIN for igual a 'BR' (Brasil),  o campo W250.TIN deve conter um  CNPJ válido.
	Case cOpcValid == "000310"
	  	cString := STR0310 //Se o campo for W250.TIN for diferente de 'NOTIN', o campo W250.JURISDICAO_TIN deve estar com conteúdo
	Case cOpcValid == "000311"
	  	cString := STR0311 //Se o campo for W250.TIN for igual 'NOTIN', o campo W250.JURISDICAO_TIN não deve estar com preenchido
	Case cOpcValid == "000312"
	  	cString := STR0312 //Se o campo W250.NI estiver preenchido,  o campo W250.JURISDICAO_NI também deve estar preenchido.
	Case cOpcValid == "000313"
	  	cString := STR0313 //Se o campo W250.NI não estiver preenchido,  o campo W250.JURISDICAO_NI também não deve estar preenchido.
	Case cOpcValid == "000314"
	  	cString := STR0314 //Se o campo W250.NI estiver preenchido, o campo W250.TIPO_NI deve estar preenchido
	Case cOpcValid == "000315"
	  	cString := STR0315 //Se o campo W250.NI não estiver preenchido, o campo W250.TIPO_NI não deve estar preenchido
	Case cOpcValid == "000316"
	  	cString := STR0316 // Se o campo W250.ATIV_13 for igual a 'S' (Sim), o campo W250.DESC_OUTROS deve estar preenchido.
	Case cOpcValid == "000317"
	  	cString := STR0317 //Se o campo W250.ATIV_13 for igual a 'N' (Não), o campo W250.DESC_OUTROS não deve estar preenchido.
	Case cOpcValid == "000318"
		cString := STR0318 //Houve indicação de vendas a comercial exportadora com fins específicos de exportação (campo IND_VEND_EXP do registro 0020) não condizente com os valores declarados como receita de vendas a comercial exportadora nas linhas "3.01.01.01.01.02" e "3.11.01.01.01.02" do registro L300
	Case cOpcValid == "000319"
		cString := STR0319 //Houve indicação de royalltes recebidos ou pagos a beneficiários do Brasil e do exterior (campo IND_ROY_PAG do registro 0020) não condizente com os valores declarados nas linhas "3.01.01.07.01.32" e "3.11.01.07.01.32" do registro L300
	Case cOpcValid == "000320"
		cString := STR0320 //Houve indicação de participações avaliadas pelo método de equivalência patrimonial (campo IND_PART_COLIG do registro 0020) não condizente com os valores declarados nas linhas "3.01.01.05.01.06", "3.01.01.05.01.07", "3.01.01.09.01.09", "3.01.01.09.01.10", "3.11.01.05.01.06", "3.11.01.05.01.07", "3.11.01.09.01.09" e 3.11.01.09.01.10 do registro L300.
	Case cOpcValid == "000321"
		cString := STR0321 //Se X340.IND_CONTROLE igual a '10', não deve existir outro registro X340 com X340.IND_CONTROLE igual a '4' ou '6'."
	Case cOpcValid == "000322"
		cString := STR0322 //Se X340.IND_CONTROLE igual a '4' ou '6', não deve existir outro registro X340 com X340.IND_CONTROLE igual a '10'.
	Case cOpcValid == "000323"
		cString := STR0323 //Se W100.IND_ENTREGA for igual a “1” e W100.JURISDICAO_CONTROLADORA for diferente de “Brasil”, o país informado no campo W100.JURISDICAO_CONTROLADORA deve constar na tabela de Acordo de Autoridades Competentes
	Case cOpcValid == "000324"
		cString := STR0324 //Se W100.IND_ENTREGA for igual a “1” e W100.JURISDICAO_CONTROLADORA for diferente de “Brasil”, o país informado no campo W100.JURISDICAO_CONTROLADORA não deve constar na tabela de falhas sistemicas
	Case cOpcValid == "000325"
		cString := STR0325 //Se o campo W100.IND_ENTREGA for igual a "4" (Outra entidade) e W100.IND_MODALIDADE for igual a "1" (Entidade substituta) e o W100.JURISDICAO_SUBSTITUTA for diferente de "Brasil", o país informado no campo W100.JURISDICAO_SUBSTITUTA deve constar na tabela de Acordo de Autoridades Competentes
	Case cOpcValid == "000326"
		cString := STR0326 //"Se o campo W100.IND_ENTREGA for igual a '4' (Outra entidade) e W100.IND_MODALIDADE for igual a '1' (Entidade substituta) e o W100.JURISDICAO_SUBSTITUTA for diferente de 'Brasil', o país informado no campo W100.JURISDICAO_SUBSTITUTA não deve constar na tabela de Falha Sistemica"
	Case cOpcValid == "000327"
		cString := STR0327 //"Caso a Escrituração seja informada com 'L' (Livro Caixa), o Registro P100 (Balanço Patrimonial) não deve ser preenchido, exceto se estiver parametrizado como Regime de Competência, quando este registro será obrigatório, mesmo que a empresa não tenha entregue/recuperado a ECD."
	Case cOpcValid == "000328"
		cString := STR0328 //"Caso a Escrituração seja informada com 'L' (Livro Caixa), o Registro P150 (Demonstrativo do Resultado Líquido no Período Fiscal) não deve ser preenchido, exceto se estiver parametrizado como Regime de Competência, quando este registro será obrigatório, mesmo que a empresa não tenha entregue/recuperado a ECD."
	Case cOpcValid == "000329"
		cString := STR0329 //"O país deve ser informado conforme tabela 'EFDFINANCEIRA_PAISES'."
	Case cOpcValid == "000330"
		cString := STR0330 //"O país informado deve ser diferente de 'BR' ( Brasil )."
	Case cOpcValid == "000331"
		cString := STR0331 //"A moeda deve ser informada conforme tabela 'SPEDECF_CBC_MOEDA'."
	Case cOpcValid == "000332"
		cString := STR0332 //"O código de lançamento deve ser informado conforme tabela 'SPEDECF_V100'."
	Case cOpcValid == "000333"
		cString := STR0333 //"O valor total dos débitos deve ser igual ao somatório dos débitos informados nos registro K156."
	Case cOpcValid == "000334"
		cString := STR0334 //"O valor total dos créditos deve ser igual ao somatório dos créditos informados nos registro K156.		
	Case cOpcValid == "000335"
        cString := STR0335 //"Não deve existir registros de 'Investidoras Diretas', para 'Ind. Controle' igual a '5'"
EndCase
	  
Return(cString)

//-------------------------------------------------------------------
/*/{Protheus.doc} NomeTab

Função responsável por retornar a descrição ( X2_DESCRIC ) da tabela corrente.

@Param		cAlias

@Return	cRet

@Author	Denis R. de Oliveira
@Since		01/07/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Function NomeTab( cAlias )

Local cRet		as character
Local aArea	as array

cRet	:=	""
aArea	:=	GetArea()

DBSelectArea( "SX2" )
DBSetOrder( 1 )

If DBSeek( cAlias )
	cRet := AllTrim( X2Nome() )
EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValPerEcf

Função responsável por retornar a descrição ( X2_DESCRIC ) da tabela corrente.

@Param		xPerIni
			xPerFim
			cPerApur
			cAlias

@Return	Nil

@Author
@Since
@Version
/*/
//-------------------------------------------------------------------
Function ValPerEcf( xPerIni, xPerFim, cPerApur, cAlias )

Local cDataIni	as character
Local cDataFim	as character

cDataIni	:=	""
cDataFim	:=	""

cDataIni := Iif( ValType( xPerIni ) == "D", DToS( xPerIni ), xPerIni )
cDataFim := Iif( ValType( xPerFim ) == "D", DToS( xPerFim ), xPerFim )

If !Empty( cDataIni ) .and. !Empty( cDataFim )
	If !TAFSeekPer( cDataIni, cDataIni )
		MsgAlert( "Período não Encontrado" )
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} StrIsInt

Verifica se na string contém apenas números inteiros.

@Param		cOpcApu	- Opção de Apuração A - Anual, T - Trimestral
			cString	- String a ser avalidada

@Return	lRet		- Retorno lógico da rotina

@Author	Evandro dos Santos Oliveira
@Since		13/02/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function StrIsInt( cOpcApu, cString )

Local nX	as numeric
Local lRet	as logical

nX		:=	0
lRet	:=	.T.

For nX := 0 to Len( cString )
	If !( SubStr( cString, nX, 1 ) $ "0123456789" )
		cRet := .F.
		Exit
	EndIf
Next nX

If lRet
	If cOpcApu == "T"
		lRet := Iif( Val( cString ) > 4 .and. Val( cString ) <> 0, .F., .T. )
	ElseIf cOpcApu == "A"
		lRet := Iif( Val( cString ) > 12, .F., .T. )
	Else
		lRet := .F.
	EndIf
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVPerA

Função para validação de Período Anual/Trimestral
de acordo com a regra VALIDA_PERIODO.

@Param		xDataIni	- Data Inicial Saldo
			xDataFim	- Data Final Saldo
			cCodPer	- Código do Período

@Return	.T.			- Retorna true para não impedir o cadastro

@Author	Evandro dos Santos Oliveira
@Since		13/02/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFVPerA( xDataIni, xDataFim, cCodPer )

Local cAlias		as character
Local cAviso		as character
Local cIdPer		as character
Local nX			as numeric
Local nPos			as numeric
Local aMsgErro	as array
Local aAreaCAH	as array

cAlias		:=	""
cAviso		:=	""
cIdPer		:=	""
nX			:=	0
nPos		:=	0
aMsgErro	:=	{}
aAreaCAH	:=	CAH->( GetArea() )

If Type( "lMILE" ) == "U" .or. ( Type( "lMILE" ) == "L" .and. !lMILE )
	If !Empty( AllTrim( cCodPer ) ) .and. !Empty( xDataIni ) .and. !Empty( xDataFim )
		nPos := At( ">", ReadVar() )

		cAlias := SubStr( ReadVar(), nPos + 1, 3 )

		cIdPer := Posicione( "CAH", 2, xFilial( "CAH" ) + cCodPer, "CAH_ID" )

		xVldECFReg( cAlias, "VALIDA_PERIODO", @aMsgErro, { xDataIni, xDataFim, cIdPer } )

		For nX := 1 to Len( aMsgErro )
			cAviso += "- " + xVldECFStr( aMsgErro[nX,2] ) + CRLF + CRLF
		Next nX

		If !Empty( cAviso )
			Aviso( "Validação de Período", cAviso, { "Fechar" }, 2 )
		EndIf
	EndIf
EndIf

RestArea( aAreaCAH )

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVPerT

Função para validação de Período Trimestral
de acordo com a regra VALIDA_PERIODO_TRIMESTRAL.

@Param		xDataIni	- Data Inicial Saldo
			xDataFim	- Data Final Saldo
			cCodPer	- Código do Período

@Return	.T.			- Retorna true para não impedir o cadastro

@Author	Evandro dos Santos Oliveira
@Since		13/02/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFVPerT( xDataIni, xDataFim, cCodPer )

Local cAlias		as character
Local cAviso		as character
Local cIdPer		as character
Local nX			as numeric
Local nPos			as numeric
Local aMsgErro	as array
Local aAreaCAH	as array

cAlias		:=	""
cAviso		:=	""
cIdPer		:=	""
nX			:=	0
nPos		:=	0
aMsgErro	:=	{}
aAreaCAH	:=	CAH->( GetArea() )

If Type( "lMILE" ) == "U" .or. ( Type( "lMILE" ) == "L" .and. !lMILE ) //!FUNNAME() == "CFGA600"
	If !Empty( AllTrim( cCodPer ) ) .and. !Empty( xDataIni ) .and. !Empty( xDataFim )
		nPos := At( ">", ReadVar() )

		cAlias := SubStr( ReadVar(), nPos + 1, 3 )

		cIdPer := Posicione( "CAH", 2, xFilial( "CAH" ) + cCodPer, "CAH_ID" )

		xVldECFReg( cAlias, "VALIDA_PERIODO_TRIMESTRAL", @aMsgErro, { xDataIni, xDataFim, cIdPer } )

		For nX := 1 to Len( aMsgErro )
			cAviso += "- " + xVldECFStr( aMsgErro[nX,2] ) + CRLF + CRLF
		Next nX

		If !Empty( cAviso )
			Aviso( "Validação de Período", cAviso, { "Fechar" }, 2 )

		EndIf
	EndIf
EndIf

RestArea( aAreaCAH )

Return( .T. )