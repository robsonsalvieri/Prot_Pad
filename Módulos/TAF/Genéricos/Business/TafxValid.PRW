#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFXVALID.CH"
#INCLUDE "TOPCONN.CH"

Static dIniESoc := TAFGetIniESocial()
Static dIniNPer := TAFGetIniNPeriod()

//------------------------------------------------------------------
/*/{Protheus.doc} xValRegTab
Função responsavel por validar os registros filhos ou
consulta padrão das respectivas tabelas

@Param
cAlias    - Alias da tabela filho
cChave    - Chave de busca na tabela filho
nInd      - Indice da tabela filho
aCampos   - Array com os campos da tabela filho
aLogErro  - Array com Log de erros
dDataVal  - Data do evento a ser comparada com a data de validade dos registros filhos
aInfoPai  - Array com informacoes referentes ao registro de origem da validacao

@Return
( lRet )  -> Indica se o registro foi encontrado ou nao


@author Fabio V. Santana
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xValRegTab( cAlias, cChave, nInd, aCampos, aLogErro, dDataVal, aInfoPai )

Local cDescTab	:=	""
Local cDesCod	:=	""
Local dDtIni	:=	""
Local dDtFim	:=	""
Local nX		:=	0
Local lRet		:=	.F.
Local lNt1519   := FindFunction("TafNT1519") .And. TafNT1519()

Default aCampos	:=	{}
Default aLogErro	:=	{}
Default dDataVal	:= CTod( " / / " )
Default aInfoPai	:=	{ "", "", 0, "", "" }

//Verifico se a chave de busca foi informada
If !Empty( cChave )

	DbSelectArea(cAlias)
	(cAlias)->( DBSetOrder( nInd ) )

	If cAlias $ "C1G"
		If ( cAlias )->( FieldPos( ( cAlias + "_NUMPRO" ) ) ) > 0
			cDesCod := AllTrim( Posicione( cAlias, nInd, xFilial( cAlias ) + cChave, cAlias + "_NUMPRO" ) )
		EndIf
	Else
		If ( cAlias )->( FieldPos( ( cAlias + "_CODIGO" ) ) ) > 0
			cDesCod := AllTrim( Posicione( cAlias, nInd, xFilial( cAlias ) + cChave, cAlias + "_CODIGO" ) )
		EndIf
	EndIf

	cDescTab := NomeTab( cAlias )

	//Busco a chave informada
	If (cAlias)->( MsSeek(xFilial( cAlias ) + cChave) )

	   	lRet := .T.

		//Verifico se o campo de Status existe no registro filho
	    If (cAlias)->( FieldPos( ( cAlias + "_STATUS" ) ) ) > 0

			//Verifico se a consulta padrao eh um registro valido
			If !( &( cAlias + "->" + cAlias + "_STATUS" ) $ ( "0234" ) ) .And. (!lNt1519 .Or. (lNt1519 .And. cAlias <> "C1G")) // A partir da NT 15/2019, a transmissão do S-1070 para utilização em outras tabelas deixou de ser obrigatório
				Aadd( aLogErro,{ aInfoPai[2], "000592", aInfoPai[1], aInfoPai[3],"000591", cDesCod, cDescTab} ) //"STR0591
		    EndIf
	    EndIf

		//Verifico a data de vigencia da consulta padrao
	    If ( FieldPos( ( cAlias + "_VALIDA" ) ) ) > 0

	        //Caso a data de referencia esteja vazia todos os registros da cosulta padrao sao validos
			If !Empty( dDataVal )
				If !Empty( &( cAlias + "->" + cAlias + "_VALIDA" ) ) .And. ( ( DTos( &( cAlias + "->" + cAlias + "_VALIDA" ) ) ) < DTos( dDataVal ) )
					Aadd( aLogErro,{ aInfoPai[2], "000427" , aInfoPai[1], aInfoPai[3] } ) //STR0427 - A Consulta padrão deste campo possui a data de vigência expirada"
				EndIf
			EndIf
		EndIf

		//Verifico se existem mais validações
		If !Empty( aCampos )

			For nX := 1 to Len( aCampos )

				//Validacao do CPF/CNPJ
				If aCampos[nX][2] == 1

					If !CGC( &( cAlias + "->" + aCampos[nX][1]),,.F. )

						//REGRA_CAT_IDENTIFICACAO_TRABALHADOR
		   				If cAlias == "C9V"
					    	If (cAlias)->&( cAlias + "_NOMEVE" ) <> "S2600"
								Aadd( aLogErro,{ aCampos[nX][1], "000011", aInfoPai[1], aInfoPai[3] } ) //STR00011 O {cpfTrab} informado no evento deve existir na base de dados do RET (como empregado ou como TSV), e deve estar ativo na data do acidente.   Caso contrário, as informações de {infoAdicionais} deverão ser preenchidas, e a categoria informada deve ser relativa a trabalhador não sujeito a evento de admissão ou de início de trabalhador sem vínculo (atualmente categorias 701, 702, 703, 711, 712, 713)
						    EndIf
						Else
							Aadd( aLogErro,{ aCampos[nX][1], "000005", aInfoPai[1], aInfoPai[3] } ) //STR0005 "CPF/CNPJ Inconsistente"
						EndIf
					EndIf

				//Valida as opcoes possiveis de um combo
				//Na terceira posicao passar as opcoes possiveis
	    		ElseIf aCampos[nX][2] == 2

	    			If !( AllTrim( &( cAlias + "->" + aCampos[nX][1] ) ) $( aCampos[nX][3] ) )
						Aadd( aLogErro,{ aCampos[nX][1], "000006", aInfoPai[1], aInfoPai[3] } ) //STR0006 "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

				//Valida se os campos estao preenchidos
		   		ElseIf aCampos[nX][2] == 3

		    		If Empty( cAlias + "->" + aCampos[nX][1] )
						If cAlias == "C9V"
							If Empty( (cAlias)->C9V_DTINES ) //Identificacao de estagiario
								aAdd( aLogErro, { aCampos[nX][1], "000011", aInfoPai[1], aInfoPai[3] } ) //O {cpfTrab} informado no evento deve existir na base de dados do RET (como empregado ou como TSV), e deve estar ativo na data do acidente.   Caso contrário, as informações de {infoAdicionais} deverão ser preenchidas, e a categoria informada deve ser relativa a trabalhador não sujeito a evento de admissão ou de início de trabalhador sem vínculo (atualmente categorias 701, 702, 703, 711, 712, 713)
							EndIf
						Else
							Aadd( aLogErro,{ aCampos[nX][1], "000010", aInfoPai[1], aInfoPai[3] } ) //STR0010 "Campo Inconsistente ou Vazio"
						EndIf
					EndIf

				//Valida se a hora eh valida
	    		Elseif aCampos[nX][2] == 4

		    		If !( xFunVldHor( "'" + cAlias + "->" + aCampos[nX][1] + "'" ) )
						Aadd( aLogErro,{ aCampos[nX][1], "000007", aInfoPai[1], aInfoPai[3] } ) //STR0007 "Hora Inconsistente ou Vazia"
	    			EndIf

			    EndIf
			Next Nx
		EndIf
	Else
		Aadd( aLogErro,{ aInfoPai[2], "000008", aInfoPai[1], aInfoPai[3], "000028", cChave, cDescTab } ) //STR0008 - "Consulta padrão inválida."
	EndIf
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldRegra

Validacao das regras genericas do layout e-Social

@Param:
cAlias     - Alias posicionado
cRegra     - Regra do layout a ser veriricada
aLogErro   - Array com log de erros
aDadosUtil - Array com informacoes(conteudo) adicionais caso necessitem ser comparadas
cAliasPai  - Alias do cadastro de origem da validacao

@Return:

@author Felipe C. Seolin
@since 07/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xVldRegra( cAlias, cRegra, aLogErro, aDadosUtil, cAliasPai, lErro )

Local cChvId		:=	xFilial( cAlias ) + ( cAlias )->( &( cAlias + "_ID" ) + &( cAlias + "_VERANT" ) )
Local cChvApp		:=	""
Local cChave		:=	""
Local cTpChv		:=	""
Local cCmpChv		:=	""
Local cCodCat		:=	""
Local cIndApu		:=	""
Local cCodNatJur	:=	""
Local cPerApu		:=	""
Local cNomEve		:=	""
Local cClasTrib		:=	""
Local cIdFunc		:=	""
Local cDtIni		:=	""
Local cDtFim		:=	""
Local cAliasRot		:=	""
Local cFldData		:=	""
Local cFldIdTrab	:=	""
Local cTpEvento		:=	""
Local cQuery		:=	""
Local cAliasQry		:=	""
Local cTpRegPrev	:=	""
Local cAux			:=	""
Local cCateg		:=	""
Local cPeriodo		:=	""
Local cFiltro		:=	""
Local cFilTAFC1E	:=	""
Local nOrdId		:=	1
Local nOrdChv		:=	2
Local nI			:=	0
Local nRecno		:=	( cAlias )->( Recno() )
Local nRotinas		:=	0
Local aCampos		:=	{}
Local aArea			:=	{}
Local aAux			:=	{}
Local lRet			:=	.T.
Local lAchou		:=	.F.
Local lVincAtv		:=	.F.
Local l3Letras		:=	.F.
Local lVldSkC1E		:=	.F.
Local nQtdEnvio		:=	0
Local dDtSolic		:=	Date()
Local dDtPerApu		:=	Date()
Local dDTAdm		:=	Date()
Local cIdTrab		:=	""
Local cCategOrig	:=	""
Local cTpPrevOri	:=	""
Local cCodCatOr		:=	""
Local cVersao		:=	""
Local dDtFGTS		:=	Nil
Local dDtAdmissao	:=	Nil

Default aLogErro	:=	{}
Default aDadosUtil	:=	{}
Default cAliasPai	:=	""
Default lErro		:=	.F.

Do case
	Case cAlias == "C1G"
		nOrdId	:= 3
	Case cAlias == "C1E"
		nOrdId	:= 2
	Otherwise
	 	nOrdId := 1
End Case

If Empty( cAliasPai )
	cAliasPai := cAlias
EndiF

//Variavel para indicar se as chaves da tabela seguem o padrao ou sao especificas
If (cAlias $ "C8W|C8R|C92|C1G|CM9|CRI|C1E|CRK|CM6|CRF|CRE|CRH|CM5|C9V|CMN|CMD|C91|CMX|CRC|CRD|C8Q|CMR|C9B|CRV|CUO|CRR|C8B|CM0|T3B|CM8|T5T|T62|T1U|T1V|T0F|T72|T87")
	cTpChv := cAlias
Else
	cTpChv := "DEFAULT"
EndIf

//De/Para da chave da aplicacao, pois em alguns casos podem ser diferenciados
If cTpChv == "DEFAULT" .And. (cAlias $ "C99|C8V|C8X|C90|T04|T5K|C93")
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CODIGO + " + cAlias + "_DTINI "
	cCmpChv := cAlias + "_CODIGO"

ElseIf cTpChv == "DEFAULT"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CODIGO + DToS(" + cAlias + "_DTINI)"// + DToS(" + cAlias + "_DTFIN)"
	cCmpChv := cAlias + "_CODIGO"

ElseIf cTpChv == "C8W"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CNPJOP + " + cAlias + "_DTINI"// + " + cAlias + "_DTFIN"
	cCmpChv := cAlias + "_CNPJOP"

ElseIf cTpChv == "C8R"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CODRUB + " + cAlias + "_DTINI "
	cCmpChv := cAlias + "_CODRUB"

ElseIf cTpChv == "C92"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_TPINSC + " + cAlias + "_NRINSC + " + cAlias + "_DTINI "
	cCmpChv := cAlias + "_TPINSC + " + cAlias + "_NRINSC"

ElseIf cTpChv == "C1G"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_TPPROC + " + cAlias + "_NUMPRO + " + cAlias + "_DTINI "
	cCmpChv := cAlias + "_TPPROC + " + cAlias + "_NUMPRO"

ElseIf cTpChv == "CM9"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_FUNC + " +  cAlias + "_TPCOND"
	cCmpChv := cAlias + "_FUNC + " + cAlias + "_TPCOND"

ElseIf cTpChv == "CRI"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_FUNC + " +  cAlias + "_TPCOND"
	cCmpChv := cAlias + "_FUNC + " + cAlias + "_TPCOND"

ElseIf cTpChv == "C1E"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CODFIL"
	cCmpChv := cAlias + "_CODFIL"

ElseIf cTpChv == "CRK"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CODFUN + DToS(" + cAlias + "_DTALDE)"
	cCmpChv := cAlias + "_CODFUN + DToS(" + cAlias + "_DTALDE)"

ElseIf cTpChv == "CRC"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CODTRA + DToS(" + cAlias + "_DALTSV)"
	cCmpChv := cAlias + "_CODTRA + DToS(" + cAlias + "_DALTSV)"

ElseIf cTpChv == "CRD"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_CODTRA + DToS(" + cAlias + "_DTERAV)"
	cCmpChv := cAlias + "_CODTRA + DToS(" + cAlias + "_DTERAV)"

ElseIf cTpChv == "C9B"
	cChvApp := "xFilial('" + cAlias + "') + " + cAlias + "_INDAPU + " + cAlias + "_PERAPU"
	cCmpChv := cAlias + "_INDAPU + " + cAlias + "_PERAPU"

EndIf

/*---------------------------------------------------------------------------------------
Array com os campos utilizados na rotina, com as posicoes referentes a cada funcao
A posicao 2 de cada Array contem o valor original de cada campo

1 - Campos da chave(exceto datas de vigencia)
2 - Data inicial de vigencia
3 - Data final de vigencia
4 - Status do registro
---------------------------------------------------------------------------------------*/

//A tabela CRK não possui DTINI/DTFIN e utiliza a validação "EXISTE_CAT_OBITO_ANTERIOR",
//para evitar errorlog não deixo macro executar esses campos que não existem (e não farão diferença no caso)
If !(cTpChv $ "CRK|CM6|CRE|CRF|CRH|CM5|C9V|CM9|CRI|CMN|CMD|C91|CMX|CRC|CRD|C8Q|CMR|C9B|CRR|CRV|CUO|CM8|T3V|CM0|T1U|T1V|T0F|T3B|CM8|T5T|T62|T72|T87")
	aCampos := { { cCmpChv           , (cAlias)->&(cCmpChv)            },;
                 { cAlias + "_DTINI" , Iif(Len((cAlias)->&(cAlias + "_DTINI")) > 6, (cAlias)->&(cAlias + "_DTINI"), CtoD("01/" + Substr((cAlias)->&(cAlias + "_DTINI"),1,2) + "/" + Substr((cAlias)->&(cAlias + "_DTINI"),3,4)))  },;
                 { cAlias + "_DTFIN" , Iif(Len((cAlias)->&(cAlias + "_DTFIN")) > 6, (cAlias)->&(cAlias + "_DTFIN"), LastDate(CtoD("01/" + Substr((cAlias)->&(cAlias + "_DTFIN"),1,2) + "/" + Substr((cAlias)->&(cAlias + "_DTFIN"),3,4))))  },;//(cAlias)->&(cAlias + "_DTFIN")  },;
                 { cAlias + "_STATUS", (cAlias)->&(cAlias + "_STATUS") } }

	cChave  := (cAlias)->&(cChvApp)
EndIf

If cRegra == "REGRA_EXISTE_INFO_EMPREGADOR"

	/*---------------------------------------------------------------------------------------------
	//³O evento somente pode ser recepcionado se existir evento de informações cadastrais do
	//³empregador vigente para a data do evento, ou seja, a data do evento (ou período de
	//³apuração, no caso de evento de folha de pagamentos) deve estar compreendida entre a
	//³{dtIniValidade} e {dtFimValidade} do evento de informações do empregador)
	-----------------------------------------------------------------------------------------------*/

		//Quando a tabela tiver só 1 data passar a posição 2 em branco..
		C1E->( DBSetOrder( 3 ) )
		If C1E->( MsSeek( xFilial( 'C1E' ) + cFilAnt ) )
			If ( !( C1E->C1E_STATUS $ " 1" ) .Or. ( C1E->C1E_ATIVO $ "1" ) )

				cDtIni := CtoD( "01/" + Substr( C1E->C1E_DTINI, 1, 2 ) + "/" + Substr( C1E->C1E_DTINI, 3, 4 ) )
				cDtFim := LastDate( CtoD( "01/" + Substr( C1E->C1E_DTFIN, 1, 2 ) + "/" + Substr( C1E->C1E_DTFIN, 3, 4 ) ) )

				If Empty( aDadosUtil[1,2] )
			   		If !( ( DtoS( aDadosUtil[1,1] ) >= DtoS( cDtIni ) ) .And. ( Empty( C1E->C1E_DTFIN ) .Or. ( DtoS( aDadosUtil[1,1] ) <= DtoS(cDtFim ) ) ) )
			   			aAdd(aLogErro,{ "C1E_ID", "000345", cAlias, C1E->( Recno() ), cAliasPai,,"" } ) //"O período de validade de informações cadastrais do empregador não está de acordo com a data do evento, ou seja, a data do evento deve estar compreendida entre o {iniValid} e {fimValid} do evento de informações do empregador. Verifique o cadastro de complemento de empresa."
			   		Endif

				ElseIf !Empty(cDtFim)
					If (DTos( cDtIni ) > DTos( aDadosUtil[1,1] )) .Or. (DTos( cDtFim ) < DTos( aDadosUtil[1,2] ))
						aAdd( aLogErro,{"C1E_ID", "000345", cAlias, C1E->( Recno() ), cAliasPai,,"" } )  //"O período de validade de informações cadastrais do empregador não está de acordo com a data do evento, ou seja, a data do evento deve estar compreendida entre o {iniValid} e {fimValid} do evento de informações do empregador. Verifique o cadastro de complemento de empresa."
			   		Endif
				Else
					If (DTos( cDtIni ) > DTos( aDadosUtil[1,1] ))
						aAdd( aLogErro,{"C1E_ID", "000345", cAlias, C1E->( Recno() ), cAliasPai,,"" } )  //"O período de validade de informações cadastrais do empregador não está de acordo com a data do evento, ou seja, a data do evento deve estar compreendida entre o {iniValid} e {fimValid} do evento de informações do empregador. Verifique o cadastro de complemento de empresa."
			   		Endif
				EndIF
			Else
				aAdd( aLogErro,{ "C1E_ID", "000345", cAlias, C1E->( Recno() ), cAliasPai,,"" })  //"O período de validade de informações cadastrais do empregador não está de acordo com a data do evento, ou seja, a data do evento deve estar compreendida entre o {iniValid} e {fimValid} do evento de informações do empregador. Verifique o cadastro de complemento de empresa."
			Endif
		Else
			aAdd( aLogErro,{ "C1E_ID", "000345", cAlias, C1E->( Recno() ), cAliasPai,,"" })  //"O período de validade de informações cadastrais do empregador não está de acordo com a data do evento, ou seja, a data do evento deve estar compreendida entre o {iniValid} e {fimValid} do evento de informações do empregador. Verifique o cadastro de complemento de empresa."
		Endif

ElseIf cRegra == "REGRA_TABGERAL_EXISTE_REGISTRO_EXCLUIDO"

	//Pesquisar versao anterior e verificar se foi transmitido e se a chave continua a mesma
	(cAlias)->( DBSetOrder( nOrdId ) )
	If (cAlias)->( MsSeek( cChvId ) )
		If &( cChvApp ) <> cChave .or. !( &( aCampos[4,1] ) == "4" )
			aAdd( aLogErro,{ cAlias, "000088", cAlias, nRecno, cAliasPai,,"" }) //"Em caso de exclusão, deve existir o registro na tabela com o mesmo código e período de validade informados no evento."
		EndIf
	Else
		aAdd( aLogErro,{ cAlias, "000088", cAlias, nRecno, cAliasPai,,"" } ) //"Em caso de exclusão, deve existir o registro na tabela com o mesmo código e período de validade informados no evento."
	EndIf

ElseIf cRegra == "REGRA_TABGERAL_EXISTE_REGISTRO_ALTERADO"

	//Pesquisar versao anterior e verificar se foi transmitido e se a chave continua a mesma
	(cAlias)->( DBSetOrder( nOrdId ) )
	If (cAlias)->( MsSeek( cChvId + "2" ) )
		If &( cChvApp ) <> cChave .or. !( &( aCampos[4,1] ) == "4" )
			aAdd( aLogErro,{ cAlias, "000090", cAlias, nRecno, cAliasPai,,"" } ) //"Em caso de alteração, deve existir registro na tabela com o mesmo código e período de validade informados no evento."
		EndIf
	Else
		aAdd(aLogErro,{ cAlias, "000090", cAlias, nRecno, cAliasPai,,"" }) //"Em caso de alteração, deve existir registro na tabela com o mesmo código e período de validade informados no evento."
	EndIf

ElseIf cRegra == "REGRA_TABGERAL_INCLUSAO_PERIODO_CONFLITANTE"

	/*---------------------------------------------------------
	Pesquisar a chave(sem vigencia)
	Verificar se existe a mesma chave transmitida
	Verificar se existe conflitos de vigencia
	---------------------------------------------------------*/
	(cAlias)->( DBSetOrder( nOrdChv ) )
	If (cAlias)->( MsSeek( xFilial(cAlias) + aCampos[1,2] ) )

		While (cAlias)->(!Eof()) .And. (cAlias)->&( aCampos[1,1] ) == aCampos[1,2]

			//Nao comparar com o registro posionado
			If (cAlias)->(Recno()) <> nRecno .And. (cAlias)->&( aCampos[4,1] ) == "4"

				cDtIni := Iif(Len((cAlias)->&(aCampos[2,1])) > 6, (cAlias)->&(aCampos[2,1]), CtoD("01/" + Substr((cAlias)->&(aCampos[2,1]),1,2) + "/" + Substr((cAlias)->&(aCampos[2,1]),3,4)))
				cDtFim := Iif(Len((cAlias)->&(aCampos[3,1])) > 6, (cAlias)->&(aCampos[3,1]), LastDate(CtoD("01/" + Substr((cAlias)->&(aCampos[3,1]),1,2) + "/" + Substr((cAlias)->&(aCampos[3,1]),3,4))))

				If !xVldPer( aCampos[2,2], aCampos[3,2], cDtIni, cDtFim  )
					Aadd( aLogErro,{ cAlias + "_ID", "000091", cAlias, nRecno, cAliasPai,,"" } ) //"Em caso de inclusão,  não deve existir outro registro na tabela com o mesmo código de identificação (chave) em período de vigência conflitante com o período informado no registro atual."
				EndIf

			EndIf

			(cAlias)->(DBSkip())
		EndDo

	EndIf

ElseIf cRegra == "REGRA_TABGERAL_ALTERACAO_PERIODO_CONFLITANTE"

	//Pesquisar versao anterior, verificar se houve alteracao de vigencia e validar se existe conflitos de vigencia
	(cAlias)->( DBSetOrder( nOrdId ) )
	If (cAlias)->( MsSeek( cChvId ) )

		cDtIni := Iif(Len((cAlias)->&(aCampos[2,1])) > 6, (cAlias)->&(aCampos[2,1]), CtoD("01/" + Substr((cAlias)->&(aCampos[2,1]),1,2) + "/" + Substr((cAlias)->&(aCampos[2,1]),3,4)))
		cDtFim := Iif(Len((cAlias)->&(aCampos[3,1])) > 6, (cAlias)->&(aCampos[3,1]), LastDate(CtoD("01/" + Substr((cAlias)->&(aCampos[3,1]),1,2) + "/" + Substr((cAlias)->&(aCampos[3,1]),3,4))))

		If ( DToS(aCampos[2,2]) + DToS(aCampos[3,2]) ) <> ( DToS( cDtIni) + DToS( cDtFim ) ) .And. ((cAlias)->&(cAlias+'_ATIVO') == '1')

			If !xVldPer( aCampos[2,2], aCampos[3,2], cDtIni, cDtFim )
				aAdd(aLogErro,{ cAlias, "000019", cAlias, nRecno, cAliasPai,,"" } ) //"Em caso de {inclusao} ou {alteração}, verificar a existência de outro registro em período de vigência conflitante."
			EndIf

		EndIf

	EndIf

ElseIf cRegra == "REGRA_INFO_EMP_PERIODO_CONFLITANTE"

	//Pesquisar versao anterior e verificar se existe conflitos de vigencia
	(cAlias)->( DBSetOrder( nOrdChv ) )
	If (cAlias)->( MsSeek( cChvId ) )
		cDtIni := Iif(Len((cAlias)->&(aCampos[2,1])) > 6, (cAlias)->&(aCampos[2,1]), CtoD("01/" + Substr((cAlias)->&(aCampos[2,1]),1,2) + "/" + Substr((cAlias)->&(aCampos[2,1]),3,4)))
		cDtFim := Iif(Len((cAlias)->&(aCampos[3,1])) > 6, (cAlias)->&(aCampos[3,1]), LastDate(CtoD("01/" + Substr((cAlias)->&(aCampos[3,1]),1,2) + "/" + Substr((cAlias)->&(aCampos[3,1]),3,4))))

		If !xVldPer( aCampos[2,2], aCampos[3,2],  cDtIni, cDtFim ) .And. ((cAlias)->C1E_ATIVO == '1')
			aAdd(aLogErro,{ cAlias, "000019", cAlias, nRecno, cAliasPai,,"" }) //"Em caso de {inclusao} ou {alteração}, verificar a existência de outro registro em período de vigência conflitante."
		EndIf

	EndIf

ElseIf cRegra == "REGRA_EXISTE_CAT_OBITO_ANTERIOR"

	//Validacao da regra REGRA_EXISTE_CAT_OBITO_ANTERIOR
	CM0->( DBSetOrder( 4 ) )

	// Procura na tabela de CAT se existe alguma CAT para o trabalhador.
	If CM0->( MsSeek( xFilial("CM0") + aDadosUtil[1,1]) )
		While !CM0->(EOF()) .And. ( CM0->CM0_TRABAL == aDadosUtil[1,1] )

			//Pesquisa em todas as CATs se alguma indica óbito e com data do acidente anterior a data do evento.
			If (CM0->CM0_INDOBI == "1") .And. (DTos( CM0->CM0_DTACID ) < DToS( aDadosUtil[1,2] ) )
				Aadd( aLogErro,{ "CM0", "000303", "CM0", CM0->( Recno() ), cAliasPai,,"" } ) 	//STR0303 - "Não é possível validar o evento pois o funcionário possui uma CAT que indica óbito com data anterior ao do evento."
			EndIf
			CM0->( DbSkip() )
		EndDo
	EndIf

ElseIf cRegra == "REGRA_EXISTE_VINCULO"

	//Validacao da regra REGRA_EXISTE_VINCULO
	If Len(aDadosUtil[1,1]) = 6
		//Se usar ID
		C9V->( DBSetOrder( 2 ) )
	Else
		//Se usar o CPF (Por exemplo, caso do S-2206)
		C9V->( DBSetOrder( 3 ) )
	EndIf

	// Procura na tabela de trabalhador se existe algum trabalhador ativo
	If C9V->( MsSeek( xFilial("C9V") + aDadosUtil[1,1]) )
		cIdFunc := C9V->C9V_ID
		//Percorro a C9V verificando se existe algum registro já transmitido (independente de ativo ou não no TAF)
		While C9V->(!Eof()) .And. C9V->C9V_ID == cIdFunc
			If (C9V->C9V_STATUS == "4")
					lVincAtv := .T.
				EndIf
				C9V->(DbSkip())
		EndDo
		If !lVincAtv
			Aadd( aLogErro,{ "C9V_ID", "000304", "C9V", C9V->( Recno() ), cAliasPai,,"" } )	//STR0304 - "Não existe vínculo ativo para o trabalhador."
		EndIf
	Else
		Aadd( aLogErro,{ "C9V_ID", "000304", "C9V", C9V->( Recno() ), cAliasPai,,"" } )	//STR0304 - "Não existe vínculo ativo para o trabalhador."
	EndIf

ElseIf cRegra == "REGRA_VINCULO_ATIVO_NA_DTEVENTO"

	//Validacao da regra REGRA_VINCULO_ATIVO_NA_DTEVENTO
	C9V->( DBSetOrder( 3 ) )
	CUP->( DBSetOrder( 1 ) )

	// Procura na tabela de trabalhador se existe algum trabalhador ativo
	If C9V->( MsSeek( xFilial("C9V") + aDadosUtil[1,1] + "1") )
		If CUP->( MsSeek( xFilial("CUP") + C9V->C9V_ID + C9V->C9V_VERSAO ) )

			//Verifica se a data do evento está compreendida entre a data de admissão e de término de contrato.
			If ( DTOS( CUP->CUP_DTADMI ) > DTOS(aDadosUtil[1,2])) .Or. (!Empty(CUP->CUP_DTTERM) .And. DTOS(CUP->CUP_DTTERM) < DTOS(aDadosUtil[1,2]))
				AADD(aLogErro,{ "C9V", "000304", "C9V", C9V->( Recno() ), cAliasPai,,"" }) 	//STR0304 - "Não existe vínculo ativo para o trabalhador."
			EndIf

			if TafLayESoc("02_04_02")
				if (!Empty(CUP->CUP_DTINVI) .And. DTOS(CUP->CUP_DTINVI) < DTOS(aDadosUtil[1,2]))
					AADD(aLogErro,{ "C9V", "000304", "C9V", C9V->( Recno() ), cAliasPai,,"" }) 	//STR0304 - "Não existe vínculo ativo para o trabalhador."
				endif
			endif

		EndIf
	EndIf

ElseIf cRegra == "REGRA_TSV_ATIVO_NA_DTEVENTO"

	//Validacao da regra REGRA_TSV_ATIVO_NA_DTEVENTO
	C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL+C9V_ID+C9V_ATIVO

	// Procura na tabela de trabalhador se existe algum trabalhador ativo
	If C9V->( MsSeek( xFilial("C9V") + aDadosUtil[1,1] + "1") )

		// If !Empty(C9V->C9V_DTINAV)
		// 	If (DTOS(C9V->C9V_DTINAV) > DTOS(aDadosUtil[1,2])) .Or. (!Empty(C9V->C9V_DTERAV) .And. (DTOS(C9V->C9V_DTERAV) < DTOS(aDadosUtil[1,2])))
		// 		AADD(aLogErro,{ "C9V","000338","C9V", C9V->( Recno() )}) 	//STR0338 - "A data do evento deve estar compreendida entre a data de início e de término indicadas nos eventos de "Trabalhador Sem Vínculo"."
		// 	EndIf
		// Else

		//Verifica se a data do evento está compreendida entre a data de admissão e de término de contrato.
		If !Empty(C9V->C9V_DTINIV)
			If (DTOS(C9V->C9V_DTINIV) > DTOS(aDadosUtil[1,2])) .Or. (!Empty(C9V->C9V_DTERCI) .And. (DTOS(C9V->C9V_DTERCI) < DTOS(aDadosUtil[1,2])))
				AADD(aLogErro,{"C9V","000338","C9V", C9V->( Recno() ) }) 	//STR0338 - "A data do evento deve estar compreendida entre a data de início e de término indicadas nos eventos de "Trabalhador Sem Vínculo"."
			EndIf

		ElseIf !Empty(C9V->C9V_DTINSP)
			If (DTOS(C9V->C9V_DTINSP) > DTOS(aDadosUtil[1,2])) .Or. (!Empty(C9V->C9V_DTTESP) .And. (DTOS(C9V->C9V_DTTESP) < DTOS(aDadosUtil[1,2])))
				AADD(aLogErro,{"C9V","000338","C9V", C9V->( Recno() ) }) 	//STR0338 - "A data do evento deve estar compreendida entre a data de início e de término indicadas nos eventos de "Trabalhador Sem Vínculo"."
			EndIf

		ElseIf !Empty(C9V->C9V_DTINDS)
			If (DTOS(C9V->C9V_DTINDS) > DTOS(aDadosUtil[1,2])) .Or. (!Empty(C9V->C9V_DTTEDS) .And. (DTOS(C9V->C9V_DTTEDS) < DTOS(aDadosUtil[1,2])))
				AADD(aLogErro,{"C9V","000338","C9V", C9V->( Recno() ) }) 	//STR0338 - "A data do evento deve estar compreendida entre a data de início e de término indicadas nos eventos de "Trabalhador Sem Vínculo"."
			EndIf

		ElseIf !Empty(C9V->C9V_DTINES)
			If (DTOS(C9V->C9V_DTINES) > DTOS(aDadosUtil[1,2])) .Or. (!Empty(C9V->C9V_DTTEES) .And. (DTOS(C9V->C9V_DTTEES) < DTOS(aDadosUtil[1,2])))
				AADD(aLogErro,{"C9V","000338","C9V", C9V->( Recno() ) }) 	//STR0338 - "A data do evento deve estar compreendida entre a data de início e de término indicadas nos eventos de "Trabalhador Sem Vínculo"."
			EndIf

		Else
			AADD(aLogErro,{"C9V","000338","C9V", C9V->( Recno() ) }) //STR0338 - "A data do evento deve estar compreendida entre a data de início e de término indicadas nos eventos de "Trabalhador Sem Vínculo"."

		EndIf
	EndIf

ElseIf cRegra == "REGRA_EXISTE_EVENTO_TSV_INICIO"

	//Validacao da regra REGRA_EXISTE_EVENTO_TSV_INICIO³
	C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL+C9V_ID+C9V_ATIVO

	// Procura na tabela de trabalhador se existe algum trabalhador ativo
	If C9V->( MsSeek( xFilial("C9V") + aDadosUtil[1,1] + "1") )
		// If !Empty(C9V->C9V_DTINAV)
		// 	If (DTOS(C9V->C9V_DTINAV) > DTOS(aDadosUtil[1,2]))
		// 		AADD(aLogErro,{"C9V","000340","C9V", C9V->( Recno() )}) 	//STR0340 - "Deve existir evento de "início" de trabalhador sem vínculo informado em data igual ou anterior a data do evento"
		// 	EndIf
		// Else

		//Verifica se a data do evento está compreendida entre a data de admissão e de término de contrato.
		If !Empty(C9V->C9V_DTINIV)
			If (DTOS(C9V->C9V_DTINIV) > DTOS(aDadosUtil[1,2]))
				AADD(aLogErro,{"C9V","000340","C9V", C9V->( Recno() )}) 	//STR0340 - "Deve existir evento de "início" de trabalhador sem vínculo informado em data igual ou anterior a data do evento"
			EndIf
		ElseIf !Empty(C9V->C9V_DTINSP)
			If (DTOS(C9V->C9V_DTINSP) > DTOS(aDadosUtil[1,2]))
				AADD(aLogErro,{"C9V","000340","C9V", C9V->( Recno() )}) 	//STR0340 - "Deve existir evento de "início" de trabalhador sem vínculo informado em data igual ou anterior a data do evento"
			EndIf
		ElseIf !Empty(C9V->C9V_DTINDS)
			If (DTOS(C9V->C9V_DTINDS) > DTOS(aDadosUtil[1,2]))
				AADD(aLogErro,{"C9V","000340","C9V", C9V->( Recno() )}) 	//STR0340 - "Deve existir evento de "início" de trabalhador sem vínculo informado em data igual ou anterior a data do evento"
			EndIf
		ElseIf !Empty(C9V->C9V_DTINES)
			If (DTOS(C9V->C9V_DTINES) > DTOS(aDadosUtil[1,2]))
				AADD(aLogErro,{"C9V","000340","C9V", C9V->( Recno() )}) 	//STR0340 - "Deve existir evento de "início" de trabalhador sem vínculo informado em data igual ou anterior a data do evento"
			EndIf
		Else
			AADD(aLogErro,{"C9V","000340","C9V", C9V->( Recno() )}) 	//STR0340 - "Deve existir evento de "início" de trabalhador sem vínculo informado em data igual ou anterior a data do evento"

		EndIf
	EndIf

ElseIf cRegra == "REGRA_EXIBE_ALERTA_EVENTO_FORA_DO_PRAZO"

	//Para as situacoes abaixo, emitir aviso de que o evento esta sendo informado fora do prazo:
	//No caso do Evento de Desligamento, caso o evento esteja sendo informado fora do prazo
	//estabelecido (nos dez dias que sucedem a data de desligamento, inclusive).
	//No caso do Evento de Admissao, caso o evento seja informado a partir do dia seguinte a data de admissao.

	//aDadosUtil:
	//[1,1] -> Indica qual condicao sera processada
	//[1,2] -> Campo Data para comparacao com data do evento

		// Regra desabilitada temporariamente para melhor entendimento
		/*If aDadosUtil[1,1] == "DESLIGAMENTO"

		If dDataBase > (cAlias)->&( aDadosUtil[1,2] ) + 10
			aAdd(aLogErro,{ aDadosUtil[1,2], "000084", cAlias, nRecno }) //STR0084 + STR0085 + STR0086 - ##"Para as situações abaixo, emitir aviso de que o evento está sendo informado fora do prazo:" ##"- No caso do Evento de Desligamento, caso o evento esteja sendo informado fora do prazo estabelecido (nos dez dias que sucedem à data de desligamento, inclusive)." ##"- No caso do Evento de Admissão, caso o evento seja informado a partir do dia seguinte à data de admissão."
		EndIf

	ElseIf aDadosUtil[1,1] == "ADMISSAO"

		If dDataBase > (cAlias)->&( aDadosUtil[1,2] )
			aAdd(aLogErro,{ aDadosUtil[1,2], "000084", cAlias, nRecno }) //STR0084 + STR0085 + STR0086 - ##"Para as situações abaixo, emitir aviso de que o evento está sendo informado fora do prazo:" ##"- No caso do Evento de Desligamento, caso o evento esteja sendo informado fora do prazo estabelecido (nos dez dias que sucedem à data de desligamento, inclusive)." ##"- No caso do Evento de Admissão, caso o evento seja informado a partir do dia seguinte à data de admissão."
		EndIf

	EndIf
*/

ElseIf cRegra == "REGRA_TABESTAB_VALIDA_ESTABELECIMENTO"

	//Para empregador cuja natureza jurídica seja igual a [102-3, 103-1, 105-8, 106-6, 108-2, 117-1, 118-0, 119-8, 120-1, 121-0, 123-6, 124-4],
	//o número de inscrição do estabelecimento informado deve pertencer ao mesmo EFR - Ente Federativo Responsável do Empregador (definido em S-1000)
	//no cadastro CNPJ da RFB

	//aDadosUtil[1,1] - Filial
	//aDadosUtil[1,2] - Nr Inscricao
	//aDadosUtil[1,3] - Alias (Tabela)

	DbSelectArea("C1E")
	C1E->( DBSetOrder(3) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
	If	C1E->( MsSeek( xFilial("C1E") + ( aDadosUtil[1,3] )->&( aDadosUtil[1,1] ) + "1" ) )
	cCodNatJur	:= POSICIONE( "C8P", 1, xFilial("C8P") + C1E->C1E_NATJUR, "C8P_CODIGO" )
	If cCodNatJur $ "1023|1031|1058|1066|1082|1171|1180|1198|1201|1210|1236|1244"
		If !( SubStr( C1E->C1E_CPNJER, 1, 8 ) == SubStr( ( aDadosUtil[1,3] )->&( aDadosUtil[1,2] ), 1, 8 ) ) // validação pela raiz (8 primeiros digitos) do CNPJ
			aAdd( aLogErro, { aDadosUtil[1,2], "000945", aDadosUtil[1,3], nRecno } )	 //O numero de inscrição do estabelecimento deve pertencer ao mesmo EFR - Ente Federativo Responsável do Empregador (definido em S-1000) no cadastro CNPJ da RFB.
		EndIf
	EndIf
	EndIf

ElseIf cRegra == "REGRA_RETIFICA_MESMO_VINCULO"

	//Em caso de retificacao, o evento retificador deve referir-se ao mesmo vinculo (CPF + Matricula) do evento original.

	//aDadosUtil[1,1] - Evento
	//aDadosUtil[1,2] - Campo do Id do trabalhador
	//aDadosUtil[1,3] - Id do registro
	//aDadosUtil[1,3] - Versao do registro

	If cAlias == "C9V"

		//Posicionar no vinculo do registro atual e guardar dados do trabalhador + vinculo
		If CUP->( MsSeek( xFilial("CUP") + C9V->( C9V_ID + C9V_VERSAO ) ) )
			aAdd( aAux, { C9V->C9V_CPF, CUP->CUP_MATRIC } )
			//Posicionar na versao anterior
			If C9V->( MsSeek( xFilial("C9V") + aDadosUtil[1,3] + aDadosUtil[1,4] ) )
				//Posicionar no vinculo do registro atual e guardar dados do trabalhador + vinculo
				If CUP->( MsSeek( xFilial("CUP") + C9V->( C9V_ID + C9V_VERSAO ) ) )
					//Verificar se houve alteracao nos dados do trabalhador + vinculo
					If aAux[1,1] <> C9V->C9V_CPF .or. aAux[1,2] <> CUP->CUP_MATRIC
						aAdd( aLogErro, { cAlias, "000037", cAlias, nRecno, cAliasPai,,"" } ) //"Em caso de retificação, o evento retificador deve referir-se ao mesmo vínculo (CPF + Matricula) do evento original;"
					EndIf
				EndIf
			EndIf
		EndIf

	Else

		If aDadosUtil[1,1] == "A"
			If !Empty( ( aDadosUtil[1,2] ) )

				//Posicionar no trabalhador do registro atual
				C9V->( DBSetOrder( 2 ) )
				If C9V->( MsSeek( xFilial("C9V") + ( aDadosUtil[1,2] ) + "1") )
					nRecno := C9V->( Recno() )

					//Posicionar no vinculo do registro atual e guardar dados do trabalhador + vinculo
					If CUP->( MsSeek( xFilial("CUP") + C9V->( C9V_ID + C9V_VERSAO ) ) )
						aAdd( aAux, { C9V->C9V_CPF, CUP->CUP_MATRIC } )

						aArea	:= (cAlias)->(GetArea()) //Pego a area para voltar após o seek
						//Posicionar na versao anterior
						If (cAlias)->( MsSeek( xFilial( cAlias ) + AllTrim( aDadosUtil[1,3] + aDadosUtil[1,4] ) ) )
							//Posicionar no trabalhador	do registro anterior
							If C9V->( MsSeek( xFilial("C9V") + ( aDadosUtil[1,2] ) + "1" ) )
								//Posicionar no vinculo do registro anterior e guardar dados do trabalhador + vinculo
								If CUP->( MsSeek( xFilial("CUP") + C9V->( C9V_ID + C9V_VERSAO ) ) )
									//Verificar se houve alteracao nos dados do trabalhador + vinculo
									If aAux[1,1] <> C9V->C9V_CPF .or. aAux[1,2] <> CUP->CUP_MATRIC
										aAdd( aLogErro, { "C9V", "000037", "C9V", nRecno, cAliasPai,,"" } ) ////"Em caso de retificação, o evento retificador deve referir-se ao mesmo vínculo (CPF + Matricula) do evento original;"
									EndIf
								EndIf
							EndIf
						EndIf
						RestArea(aArea)

					EndIf
					nRecno  := (cAlias)->(Recno())
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf cRegra == "REGRA_EVETRAB_VALIDA_OPCAO_FGTS"

	If !(FindFunction("TafNT1519") .And. TafNT1519())

		// 2.4.01
		// A data de opção do trabalhador pelo FGTS deve ser uma data igual ou posterior à data de admissão do empregado ou data de início do TSVE, observando o que segue:
		// 1. Se a data de admissão/data de início é posterior a 04/10/1988, a data de opção deve ser igual à data de admissão/data de início, exceto categorias [104] e [721];
		// 2. Se a data de admissão/data de início é entre 01/01/1967 e 04/10/1988, a data de opção deve ser entre a data de admissão/data de início e 05/10/1988, exceto categorias [104] e [721];
		// 3. Se a data de admissão/data de início é anterior a 01/01/1967, a data de opção deve ser entre 01/01/1967 e 05/10/1988, exceto categorias [104] e [721];
		// 4. Para a categoria [104] (doméstico), a data de opção deve ser igual ou posterior à data de admissão e nunca anterior a 01/03/2000;
		// 5. Para a categoria [721] (diretor não empregado, com FGTS), a data de opção deve ser igual ou posterior à data de início e nunca anterior a 02/06/1981.

		//aDadosUtil:
		//[1,1] -> Campo Data do FGTS             Exemplo: "CUP_DTFGTS"
		//[1,2] -> Campo Categoria do Trabalhador Exemplo: "CUP_CODCAT"
		//[1,3] -> Campo Data de Admissao         Exemplo: "CUP_DTADMI"
		//[1,4] -> Alias referente ao Vinculo

		If C87->( MsSeek( xFilial("C87") + ( aDadosUtil[1,4] )->&( aDadosUtil[1,2] ) ) )
			cCodCat := AllTrim(C87->C87_CODIGO)
		EndIf

		If aDadosUtil[1,1] == "CUU_DTFGCI"
			dDtFGTS := CUU->&( aDadosUtil[1,1] )
		Else
			dDtFGTS := ( aDadosUtil[1,4] )->&( aDadosUtil[1,1] )
		EndIf

		dDtAdmissao := ( aDadosUtil[1,4] )->&( aDadosUtil[1,3] )

		If dDtFGTS < dDtAdmissao
			aAdd(aLogErro,{ aDadosUtil[1,1], "000064", cAlias, nRecno}) //"A data de opção do trabalhador pelo FGTS deve ser uma data igual ou posterior à data de admissão do empregado ou data de início do TSVE."
		Else
			If !(cCodCat $ "104|721")
				If dDtAdmissao > CToD("04/10/1988") .And. dDtFGTS <> dDtAdmissao
					aAdd(aLogErro,{ aDadosUtil[1,1], "000065", cAlias, nRecno}) //"1. Se a data de admissão/data de início é posterior a 04/10/1988, a data de opção deve ser igual à data de admissão/data de início, exceto categorias [104] e [721]."
				ElseIf dDtAdmissao >= CToD("01/01/1967") .And. dDtAdmissao <= CToD("04/10/1988") .And. !( dDtFGTS >= dDtAdmissao .And. dDtFGTS <= CToD("05/10/1988") )
					aAdd(aLogErro,{ aDadosUtil[1,1], "000066", cAlias, nRecno}) //"2. Se a data de admissão/data de início é entre 01/01/1967 e 04/10/1988, a data de opção deve ser entre a data de admissão/data de início e 05/10/1988, exceto categorias [104] e [721]."
				Elseif dDtAdmissao < CToD("01/01/1967") .And. !( dDtFGTS >= CToD("01/01/1967") .And. dDtFGTS <= CToD("05/10/1988") )
					aAdd(aLogErro,{ aDadosUtil[1,1], "000067", cAlias, nRecno}) //"3. Se a data de admissão/data de início é anterior a 01/01/1967, a data de opção deve ser entre 01/01/1967 e 05/10/1988, exceto categorias [104] e [721]."
				EndIf
			ElseIf cCodCat == "104" // 4. Para a categoria [104] (doméstico)
				If dDtAdmissao >= CToD("01/10/2015") .And. dDtFGTS <> dDtAdmissao
					aAdd(aLogErro,{ aDadosUtil[1,1], "001144", cAlias, nRecno}) // "Para a categoria [104] (doméstico), se a data de admissão é igual ou posterior a 01/10/2015, a data de opção deve ser igual à data de admissão!"
				ElseIf (dDtAdmissao >= CToD("01/03/2000")  .And. dDtAdmissao < CToD("01/10/2015")) .And. !(dDtFGTS >= dDtAdmissao .And. dDtFGTS <= CToD("01/10/2015"))
					aAdd(aLogErro,{ aDadosUtil[1,1], "001145", cAlias, nRecno}) // "Para a categoria [104] (doméstico), se a data de admissão é entre 01/03/2000 e 30/09/2015, a data de opção deve ser entre a data de admissão e 01/10/2015!"
				ElseIf dDtAdmissao < CToD("01/03/2000") .And. !(dDtFGTS >= CToD("01/03/2000") .And. dDtFGTS <= CToD("01/10/2015"))
					aAdd(aLogErro,{ aDadosUtil[1,1], "001146", cAlias, nRecno}) // "Para a categoria [104] (doméstico), se a data de admissão é anterior a 01/03/2000, a data de opção deve ser entre 01/03/2000 e 01/10/2015!"
				EndIf
			ElseIf cCodCat == "721" .And. (dDtFGTS < dDtAdmissao .Or. dDtFGTS< CToD("02/06/1981"))
				aAdd(aLogErro,{ aDadosUtil[1,1], "000069", cAlias, nRecno}) //"5. Para a categoria [721] (diretor não empregado, com FGTS), a data de opção deve ser igual ou posterior à data de início e nunca anterior a 02/06/1981."
			EndIf
		EndIf

	ElseIf !(C9V->C9V_CADINI == '2' .And. ( CUP->CUP_TPADMI == '1' .Or. CUP->CUP_TPADMI == '6' )) .And. (FindFunction("TafNT1519") .And. TafNT1519())

		// 2.4.01
		// A data de opção do trabalhador pelo FGTS deve ser uma data igual ou posterior à data de admissão do empregado ou data de início do TSVE, observando o que segue:
		// 1. Se a data de admissão/data de início é posterior a 04/10/1988, a data de opção deve ser igual à data de admissão/data de início, exceto categorias [104] e [721];
		// 2. Se a data de admissão/data de início é entre 01/01/1967 e 04/10/1988, a data de opção deve ser entre a data de admissão/data de início e 05/10/1988, exceto categorias [104] e [721];
		// 3. Se a data de admissão/data de início é anterior a 01/01/1967, a data de opção deve ser entre 01/01/1967 e 05/10/1988, exceto categorias [104] e [721];
		// 4. Para a categoria [104] (doméstico), a data de opção deve ser igual ou posterior à data de admissão e nunca anterior a 01/03/2000;
		// 5. Para a categoria [721] (diretor não empregado, com FGTS), a data de opção deve ser igual ou posterior à data de início e nunca anterior a 02/06/1981.

		//aDadosUtil:
		//[1,1] -> Campo Data do FGTS             Exemplo: "CUP_DTFGTS"
		//[1,2] -> Campo Categoria do Trabalhador Exemplo: "CUP_CODCAT"
		//[1,3] -> Campo Data de Admissao         Exemplo: "CUP_DTADMI"
		//[1,4] -> Alias referente ao Vinculo

		If C87->( MsSeek( xFilial("C87") + ( aDadosUtil[1,4] )->&( aDadosUtil[1,2] ) ) )
			cCodCat := AllTrim(C87->C87_CODIGO)
		EndIf

		If aDadosUtil[1,1] == "CUU_DTFGCI"
			dDtFGTS := CUU->&( aDadosUtil[1,1] )
		Else
			dDtFGTS := ( aDadosUtil[1,4] )->&( aDadosUtil[1,1] )
		EndIf

		dDtAdmissao := ( aDadosUtil[1,4] )->&( aDadosUtil[1,3] )

		If dDtFGTS < dDtAdmissao
			aAdd(aLogErro,{ aDadosUtil[1,1], "000064", cAlias, nRecno}) //"A data de opção do trabalhador pelo FGTS deve ser uma data igual ou posterior à data de admissão do empregado ou data de início do TSVE."
		Else
			If !(cCodCat $ "104|721")
				If dDtAdmissao > CToD("04/10/1988") .And. dDtFGTS <> dDtAdmissao
					aAdd(aLogErro,{ aDadosUtil[1,1], "000065", cAlias, nRecno}) //"1. Se a data de admissão/data de início é posterior a 04/10/1988, a data de opção deve ser igual à data de admissão/data de início, exceto categorias [104] e [721]."
				ElseIf dDtAdmissao >= CToD("01/01/1967") .And. dDtAdmissao <= CToD("04/10/1988") .And. !( dDtFGTS >= dDtAdmissao .And. dDtFGTS <= CToD("05/10/1988") )
					aAdd(aLogErro,{ aDadosUtil[1,1], "000066", cAlias, nRecno}) //"2. Se a data de admissão/data de início é entre 01/01/1967 e 04/10/1988, a data de opção deve ser entre a data de admissão/data de início e 05/10/1988, exceto categorias [104] e [721]."
				Elseif dDtAdmissao < CToD("01/01/1967") .And. !( dDtFGTS >= CToD("01/01/1967") .And. dDtFGTS <= CToD("05/10/1988") )
					aAdd(aLogErro,{ aDadosUtil[1,1], "000067", cAlias, nRecno}) //"3. Se a data de admissão/data de início é anterior a 01/01/1967, a data de opção deve ser entre 01/01/1967 e 05/10/1988, exceto categorias [104] e [721]."
				EndIf
			ElseIf cCodCat == "104" // 4. Para a categoria [104] (doméstico)
				If dDtAdmissao >= CToD("01/10/2015") .And. dDtFGTS <> dDtAdmissao
					aAdd(aLogErro,{ aDadosUtil[1,1], "001144", cAlias, nRecno}) // "Para a categoria [104] (doméstico), se a data de admissão é igual ou posterior a 01/10/2015, a data de opção deve ser igual à data de admissão!"
				ElseIf (dDtAdmissao >= CToD("01/03/2000")  .And. dDtAdmissao < CToD("01/10/2015")) .And. !(dDtFGTS >= dDtAdmissao .And. dDtFGTS <= CToD("01/10/2015"))
					aAdd(aLogErro,{ aDadosUtil[1,1], "001145", cAlias, nRecno}) // "Para a categoria [104] (doméstico), se a data de admissão é entre 01/03/2000 e 30/09/2015, a data de opção deve ser entre a data de admissão e 01/10/2015!"
				ElseIf dDtAdmissao < CToD("01/03/2000") .And. !(dDtFGTS >= CToD("01/03/2000") .And. dDtFGTS <= CToD("01/10/2015"))
					aAdd(aLogErro,{ aDadosUtil[1,1], "001146", cAlias, nRecno}) // "Para a categoria [104] (doméstico), se a data de admissão é anterior a 01/03/2000, a data de opção deve ser entre 01/03/2000 e 01/10/2015!"
				EndIf
			ElseIf cCodCat == "721" .And. (dDtFGTS < dDtAdmissao .Or. dDtFGTS< CToD("02/06/1981"))
				aAdd(aLogErro,{ aDadosUtil[1,1], "000069", cAlias, nRecno}) //"5. Para a categoria [721] (diretor não empregado, com FGTS), a data de opção deve ser igual ou posterior à data de início e nunca anterior a 02/06/1981."
			EndIf
		EndIf

	EndIf

ElseIf cRegra == "REGRA_ADMISSAO_VALIDA_DTADMISSAO"

	//A data de admissao do trabalhador:
	//Para a categoria [103] (aprendiz), deve ser maior ou igual a [20/12/2000]

	//aDadosUtil[1,1] -> Campo Data de Admissao         Exemplo: "CUP_DTADMI"
	//aDadosUtil[1,2] -> Campo Categoria do Trabalhador Exemplo: "CUP_CODCAT"
	//aDadosUtil[1,3] -> Alias referente ao Vinculo

	If C87->( MsSeek( xFilial("C87") + ( aDadosUtil[1,3] )->&( aDadosUtil[1,2] ) ) )
		cCodCat := AllTrim(C87->C87_CODIGO)
	EndIf

	If cCodCat == "103"
		If ( aDadosUtil[1,3] )->&( aDadosUtil[1,1] ) < CToD("20/12/2000")
			aAdd( aLogErro, { aDadosUtil[1,1], "000267", cAlias, nRecno, cAliasPai,,"" } ) //"A data de admissão do trabalhador:"
		EndIf
	EndIf

ElseIf cRegra == "REGRA_ADMISSAO_VALIDA_MATRICULA"

	//Foi definido que a chave de identificacao de cada vinculo trabalhista na empresa (CNPJ base)
	//eh a MATRICULA, que eh atribuida pelo Empregador. Nao podera existir no RET, para a mesma
	//empresa, trabalhador com mesmo numero de matricula do trabalhador a ser admitido (Recusar Evento)

	//aDadosUtil[1,1] - Campo de matricula do trabalhador
	//aDadosUtil[1,2] - Id do registro
	//aDadosUtil[1,3] - Versao do registro
	//aDadosUtil[1,4] - Alias referente ao Vinculo
	aAdd( aAux, { ( aDadosUtil[1,4] )->&( aDadosUtil[1,1] ) } )

	CUP->( DBSetOrder( 3 ) )
	If CUP->( MsSeek( xFilial("CUP") + aAux[1,1] ) )
		While CUP->( !Eof() ) .and. CUP->( CUP_FILIAL + CUP_MATRIC ) == xFilial("CUP") + aAux[1,1]
			If CUP->( CUP_ID + CUP_VERSAO ) <> aDadosUtil[1,2] + aDadosUtil[1,3]
				If C9V->( MsSeek( xFilial("C9V") + CUP->( CUP_ID + CUP_VERSAO ) ) )
					If C9V->C9V_ATIVO == "1"
						aAdd( aLogErro, { aDadosUtil[1,1], "000071", cAlias, nRecno, cAliasPai,,"" } ) //"Foi definido que a chave de identificação de cada vínculo trabalhista na empresa (CNPJ base) é a MATRICULA, que é atribuída pelo Empregador. Não poderá existir no RET, para a mesma empresa, trabalhador com mesmo número de matrícula do trabalhador a ser admitido (Recusar Evento);"
						Exit
					EndIf
				EndIf
			EndIf
			CUP->( DBSkip() )
		EndDo
	EndIf

ElseIf cRegra == "REGRA_EVE_FOPAG_EXIGE_ABERTURA"

	cIndApu := (cAlias)->&( aDadosUtil[1,1] )
	cPerApu := (cAlias)->&( aDadosUtil[1,2] )

	aArea := C8Y->(GetArea())

	C8Y->(DBSetOrder(2))

	// Localiza abertura de folha para o período
	If C8Y->(MsSeek(xFilial("C8Y") + cIndApu + cPerApu + "1"))
		// Verifica se já foi transmitida
		If !C8Y->C8Y_STATUS == "4"
			//REGRA_EVE_FOPAG_EXIGE_ABERTURA
			AADD(aLogErro,{ "C8Y", "000042", "C8Y", C8Y->( Recno() ),cAliasPai,,""}) //STR0042 - "Para recepção do evento é necessário que já tenha sido enviado o evento de 'abertura' da folha de pagamentos(original ou com indicativo de retificação) para o período de apuração indicado no evento."
		EndIf
	Else
		//REGRA_EVE_FOPAG_EXIGE_ABERTURA
		AADD(aLogErro,{aDadosUtil[1,2],"000042",cAlias,nRecno,cAliasPai,,""}) //STR0042 - "Para recepção do evento é necessário que já tenha sido enviado o evento de 'abertura' da folha de pagamentos(original ou com indicativo de retificação) para o período de apuração indicado no evento."
	EndIf

	RestArea(aArea)

ElseIf cRegra == "REGRA_EVE_FOPAG_INFO_COMPAT_CLASSTRIB"

	cNomEve := aDadosUtil[1,1]

	aArea := C1E->(GetArea())

	C1E->(DBSetOrder(3)) // (C1E_FILIAL+C1E_FILTAF)

	// Localiza a empresa contribuinte
	If C1E->(MsSeek(xFilial('C1E') + (cAlias)->(&(cAlias + "_FILIAL"))))
		// Obtem a classificação tributaria
		cClasTrib := Posicione("C8D",1,xFilial("C8D") + C1E->C1E_CLAFIS,"C8D_CODIGO")
	EndIf

	RestArea(aArea)

	If cNomEve == "S1320" .And. cClasTrib $ ("21|22")
		AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai,,""}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."

	ElseIf cNomEve == "S1340" .And. !(cClasTrib  == "99")
		AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai,,""}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."

	ElseIf cNomEve == "S1250" .And. cClasTrib  == "22"
		AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai,,""}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."

	ElseIf cNomEve == "S1360" .And. !(cClasTrib  $ ("06|07|21|22"))
		AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai,,""}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."

	ElseIf cNomEve == "S1370" .And. cClasTrib  $ ("21|22")
		AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai,,""}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."
	//Comentei os if's abaixo pois na versão 1.1 não existe a regra. Porém existe para a 1.2;
	// SQA validando ainda 1.1; Quando liberarmos a 1.2 descomentar.
	//Leandro Prado - 07/05/2014
	//ElseIf cNomEve == "S1380" .And. !(cClasTrib  == "05")
	//		AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."

	//ElseIf cNomEve == "S1390" .And. !(cClasTrib  == "03")
		//AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."
	ElseIf cNomEve == "S1280" .and. ( !( cClasTrib $ ( "02|03|09|99" ) ) .or. ( cClasTrib $ ( "02|99" ) .and. C1E->C1E_DESFOL <> "1" ) )
		aAdd( aLogErro, { cAlias, "000779", cAlias, nRecno, cAliasPai,, "" } ) //"O evento S-1280 - Informações Complementares aos Eventos Periódicos é permitido apenas se {classTrib} = [03,09] ou ({classTrib} = [02,99] e {indDesFolha} = [1])."

	ElseIf cNomEve == "S1260" .And. !(cClasTrib  $ ("21|22"))
		AADD(aLogErro,{cAlias,"000336",cAlias,nRecno,cAliasPai,,""}) //STR0336 - "Tipo de evento é incompatível com a classificação tributária do contribuinte."
	EndIf

ElseIf cRegra == "REGRA_EXISTE_EVENTO_AFASTAMENTO"

	//aDadosUtil[1,1] - Id do Trabalhador
	//aDadosUtil[1,2] - Data da Alteração do Afastamento
	//aDadosUtil[1,3] - Motivo do Afastamento
	CM6->(DbSetOrder(6))
	If CM6->(MsSeek(xFilial("CM6") + aDadosUtil[1][1] + "1"))
		If aDadosUtil[1][1] <> CM6->CM6_FUNC
			aAdd(aLogErro,{cAlias + "_FUNC","000351",cAlias,nRecno,cAliasPai,,""}) //Trabalhador do afastamento anterior diferente do trabalhador do afastamento atual
		EndIf

		If CM6->CM6_DTAFAS > aDadosUtil[1][2]
			If cAlias <> 'CRF'
		 		aAdd(aLogErro,{cAlias + "_DTALTM","000352",cAlias,nRecno,cAliasPai,,""}) //Data do afastamento superior a data da alteração do afastamento
		 	Else
		 		aAdd(aLogErro,{cAlias + "_DTRETO","000363",cAlias,nRecno,cAliasPai,,""}) //Data do afastamento superior a data de retorno do afastamento
		 	EndIf
		Else
		   //Não pode haver evento de retorno para o vínculo
		   	If cAlias <> 'CRF'
				dbSelectArea("CRF")
			   	dbSetOrder(2)
		           	If CRF->(MsSeek(xFilial("CRF")+aDadosUtil[1][1]+aDadosUtil[1][3]))
		           		aAdd(aLogErro,{"CRF","000353","CRF",CRF->( Recno() ), cAliasPai,,""}) //Encontrado evento de retorno de afastamento vinculado ao evento e trabalhador
		           	EndIf
		    EndIf
		EndIf
	EndIf
ElseIf cRegra == "REGRA_EXISTE_EVENTO_INICIO_CDT"

	//Para aceitacao do evento de termino de condicao diferenciada de trabalho e necessaria a existencia de
	//evento de INICIO para o mesmo vinculo e com o mesmo {tpCondicao} em data anterior a data do evento, e
	//para o qual ainda nao conste o respectivo evento de TERMINO. Alem disso, se {tpCondicao} igual a [03],
	//o {codAgente} informado no evento de termino tambem deve ser igual ao {codAgente} indicado no evento
	//de inicio.

	//aDadosUtil[1,1] - C - Id do trabalhador
	//aDadosUtil[1,2] - C - Tipo de condicao diferenciada de trabalho
	//aDadosUtil[1,3] - D - Data final da condicao diferenciada de trabalho
	//aDadosUtil[1,4] - A - Codigo do(s) agente(s) nocivo(s)

	CM9->(DBSetOrder(2))
	If CM9->(MsSeek(xFilial("CM9") + aDadosUtil[1,1] + aDadosUtil[1,2] + "1"))
		If CM9->CM9_STATUS == "4"
			If CM9->CM9_DTINI > aDadosUtil[1,3]
				aAdd(aLogErro, { "CM9", "000370", "CM9", CM9->( Recno() ),cAliasPai,,""}) //STR0370 - "Para aceitação do evento de término de condição diferenciada de trabalho é necessária a existência de evento de INÍCIO para o mesmo vínculo e com o mesmo {tpCondicao} em data anterior a data do evento, e para o qual ainda não conste o respectivo evento de TÉRMINO. Além disso, se {tpCondicao} igual a [03], o {codAgente} informado no evento de término também deve ser igual ao {codAgente} indicado no evento de início."

			ElseIf !Empty(aDadosUtil[1,4])
				CUN->(DBSetOrder(1))
				If CUN->(MsSeek(xFilial("CUN") + aDadosUtil[1,2]))
					If CUN->CUN_CODIGO == "03"
						CMA->(DBSetOrder(1))
						If CMA->(MsSeek(xFilial("CMA") + CM9->(CM9_ID + CM9_VERSAO)))

							C98->(DBSetOrder(1))
							While CMA->(!Eof()) .and. xFilial("CMA") + CM9->(CM9_ID + CM9_VERSAO) == CMA->(CMA_FILIAL + CMA_ID + CMA_VERSAO)
								If C98->(MsSeek(xFilial("C98") + CMA->CMA_CODAGE))
									aAdd(aAux, C98->C98_CODIGO)
								EndIf
								CMA->(DBSkip())
							EndDo

							If Len(aAux) <> Len(aDadosUtil[1,4])
								aAdd(aLogErro, { cAlias, "000370", cAlias, nRecno,cAliasPai,,""}) //STR0370 - "Para aceitação do evento de término de condição diferenciada de trabalho é necessária a existência de evento de INÍCIO para o mesmo vínculo e com o mesmo {tpCondicao} em data anterior a data do evento, e para o qual ainda não conste o respectivo evento de TÉRMINO. Além disso, se {tpCondicao} igual a [03], o {codAgente} informado no evento de término também deve ser igual ao {codAgente} indicado no evento de início."
							Else

								aSort(aAux)
								aSort(aDadosUtil[1,4])

								For nI := 1 to Len(aAux)
									If aAux[nI] <> aDadosUtil[1,4,nI]
										aAdd(aLogErro, {cAlias, "000370", cAlias, nRecno,cAliasPai,,""}) //STR0370 - "Para aceitação do evento de término de condição diferenciada de trabalho é necessária a existência de evento de INÍCIO para o mesmo vínculo e com o mesmo {tpCondicao} em data anterior a data do evento, e para o qual ainda não conste o respectivo evento de TÉRMINO. Além disso, se {tpCondicao} igual a [03], o {codAgente} informado no evento de término também deve ser igual ao {codAgente} indicado no evento de início."
										Exit
									EndIf
								Next nI

							EndIf

						EndIf
					EndIf
				EndIf
			EndIf
		Else
			aAdd(aLogErro, {cAlias, "000370", cAlias, nRecno,cAliasPai,,""}) //STR0370 - "Para aceitação do evento de término de condição diferenciada de trabalho é necessária a existência de evento de INÍCIO para o mesmo vínculo e com o mesmo {tpCondicao} em data anterior a data do evento, e para o qual ainda não conste o respectivo evento de TÉRMINO. Além disso, se {tpCondicao} igual a [03], o {codAgente} informado no evento de término também deve ser igual ao {codAgente} indicado no evento de início."
		EndIf
	Else
		aAdd(aLogErro, {cAlias, "000370", cAlias, nRecno,cAliasPai,,""}) //STR0370 - "Para aceitação do evento de término de condição diferenciada de trabalho é necessária a existência de evento de INÍCIO para o mesmo vínculo e com o mesmo {tpCondicao} em data anterior a data do evento, e para o qual ainda não conste o respectivo evento de TÉRMINO. Além disso, se {tpCondicao} igual a [03], o {codAgente} informado no evento de término também deve ser igual ao {codAgente} indicado no evento de início."
	EndIf

ElseIf cRegra == "REGRA_ADMISSAO_ANTERIOR_INICIO_ESOCIAL"


	//aDadosUtil[1,1] - C - Campo data de admissao do trabalhador
	//aDadosUtil[1,2] - C - Campo data de exercício do trabalhador
	//aDadosUtil[1,3] - C - Alias referente ao Vinculo

	//A data de Admissão/Exercício informada no evento "Cadastramento Inicial do Vínculo", nos campos {dtAdm} e {dtExercicio}
	//deve ser anterior à data de início da obrigatoriedade do contribuinte no eSocial.

	If !Empty(aDadosUtil[1,1])
		If !(( aDadosUtil[1,3] )->&( aDadosUtil[1,1] ) < dIniESoc)
			aAdd( aLogErro, { aDadosUtil[1,1], "000377", cAlias, nRecno, cAliasPai,,"" } ) //STR0377 - "A data de admissão informada no evento de cadastro inicial do vínculo deve ser anterior a data de início da e-Social"
		EndIf
	EndIf

	If !Empty(aDadosUtil[1,2])
		If !(( aDadosUtil[1,3] )->&( aDadosUtil[1,2] ) < dIniESoc)
			aAdd( aLogErro, { aDadosUtil[1,2], "000946", cAlias, nRecno, cAliasPai,,"" } ) //STR0946 - "A data de exercício informada no evento de cadastro inicial do vínculo deve ser anterior a data de início da e-Social"
		EndIf
	EndIf

ElseIf cRegra == "REGRA_ADMISSAO_VALIDA_DT_ADM"

	//A data de admissão do trabalhador, informada no campo {dtAdm} não pode ser superior a 30 (trinta) dias a partir da data atual.
	//Para a categoria [103] (aprendiz), deve ser maior ou igual a [20/12/2000].

	//aDadosUtil[1,1] - ID
	//aDadosUtil[1,2] - Versao
	//aDadosUtil[1,3] - Nome Evento
	//aDadosUtil[1,4] - Alias (Tabela)

	CUP->(DBSetOrder(4)) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC
	If CUP->( MsSeek( xFilial("CUP") + aDadosUtil[1,1] + aDadosUtil[1,2] + aDadosUtil[1,3] ) )
		If	!Empty( CUP->CUP_DTADMI )
			If (CUP->CUP_DTADMI > dDataBase) .And. DateDiffDay(CUP->CUP_DTADMI, dDataBase) > 30
				//campo {dtAdm} não pode ser superior a 30 (trinta) dias a partir da data atual
				aAdd( aLogErro, { "CUP_DTADMI", "000948", aDadosUtil[1,4], nRecno } ) //STR0948 - "A Data de Admissão não pode ser superior a 30 dias da Data Atual."
			EndIf
			cCodCat := Posicione("C87",1,xFilial("C87") + CUP->CUP_CODCAT,"C87_CODIGO")
			If cCodCat == "103"
				If	!(CUP->CUP_DTADMI >= CToD("20/12/2000"))
					aAdd( aLogErro, { "CUP_DTADMI", "000949", aDadosUtil[1,4], nRecno } ) //A Data de Admissão deve ser maior ou igual a [20/12/2000] para a categoria [103] (aprendiz).
				EndIf
			EndIf
			If cCodCat == "105"
				If	!(CUP->CUP_DTADMI >= CToD("22/01/1998"))
					aAdd( aLogErro, { "CUP_DTADMI", "001214", aDadosUtil[1,4], nRecno } ) //A Data de Admissão deve ser maior ou igual a [22/01/1998] para a categoria [105] (contrato a termo firmado nos termos da Lei 9601/98).
				EndIf
			EndIf
			If cCodCat == "107" .OR. cCodCat == "108"
				If	!(CUP->CUP_DTADMI <= CToD("20/04/2020"))
					aAdd( aLogErro, { "CUP_DTADMI", "001215", aDadosUtil[1,4], nRecno } ) //A Data de Admissão deve ser igual ou anterior a [20/04/2020] para categorias [107] e [108].
				EndIf
			EndIf
		EndIf
		if TafLayESoc("02_04_02")
			if !Empty(CUP->CUP_DTINVI) //Nos casos de sucessão, a data da transferência do trabalhador, informada no campo {sucessaoVinc/dtTransf}, não pode ser superior a 30 (trinta) dias a partir da data atual.
				If (CUP->CUP_DTINVI > dDataBase) .And. DateDiffDay(CUP->CUP_DTINVI, dDataBase) > 30
					//campo {dtAdm} não pode ser superior a 30 (trinta) dias a partir da data atual
					aAdd( aLogErro, { "CUP_DTINVI", "001129", aDadosUtil[1,4], nRecno } ) //STR1129 - "Nos casos de sucessão, a data da transferência do trabalhador, informada no campo {sucessaoVinc/dtTransf}, não pode ser superior a 30 (trinta) dias a partir da data atual."
				EndIf
			endif
		endif
	EndIf

ElseIf cRegra == "REGRA_ADMISSAO_POSTERIOR_INICIO_ESOCIAL"

	//A data de admissao informada no evento de admissao deve ser igual ou posterior a data de inicio da e-Social

	//aDadosUtil[1,1] - C - Campo data de admissao do trabalhador
	//aDadosUtil[1,2] - C - Campo data de exercício do trabalhador
	//aDadosUtil[1,3] - C - Alias referente ao Vinculo

	//A data de Admissão/Exercício, campos {dtAdm} ou {dtExercicio} informada no evento de admissão deve ser igual ou posterior à data de início da obrigatoriedade do contribuinte no eSocial.

	If !Empty(( aDadosUtil[1,3] )->&( aDadosUtil[1,1] ))
		If !(( aDadosUtil[1,3] )->&( aDadosUtil[1,1] ) >= dIniESoc)
			aAdd( aLogErro, { aDadosUtil[1,1], "000382", cAlias, nRecno, cAliasPai,,"" } ) //STR0382 - "A data de admissão informada no evento de admissão deve ser igual ou posterior a data de início da e-Social"
		EndIf
	EndIf

	If !Empty(( aDadosUtil[1,3] )->&( aDadosUtil[1,2] ) )
		If !(( aDadosUtil[1,3] )->&( aDadosUtil[1,2] ) >= dIniESoc)
			aAdd( aLogErro, { aDadosUtil[1,2], "000947", cAlias, nRecno, cAliasPai,,"" } ) //STR0947 - "A data de exercício informada no evento de admissão deve ser igual ou posterior a data de início da e-Social"
		EndIf
	EndIf

ElseIf cRegra == "REGRA_ADMISSAO_TRABALHADOR_CEDIDO"

	//O evento de admissao de trabalhador cedido ({tpAdmissao} = [4]) deve atender as seguintes regras:
	//1) somente pode ser enviado por empregador cuja natureza juridica informada no evento de informacoes
	//   do empregador seja relativa a administracao publica (natureza juridica iniciada por [1])
	//2) A informacao da origem do trabalhador cedido, prestada no evento de admissao
	//   por cessao (tipo de admissao igual a 4), devera ser validada no RET se a dtAdmissaoCedente
	//   for igual ou superior a data de inicio de vigencia da e-Social (deve existir o vinculo do
	//   trabalhador na empresa cedente - cnpjCedente + cpf + matriculacedente + dtAdmissaoCedente).
	//3) No caso anterior, deve existir tambem o respectivo afastamento pelo motivo de "Cessao"
	//   em data igual ou anterior a data de admissao na empresa cessionaria

	//aDadosUtil[1,1] - C - Campo tipo de admissao do trabalhador
	//aDadosUtil[1,2] - C - Filial de registro
	//aDadosUtil[1,3] - C - Alias referente ao Vinculo

	If ( aDadosUtil[1,3] )->&( aDadosUtil[1,1] ) == "4"
		C1E->( DBSetOrder( 3 ) )
		If C1E->( MsSeek( xFilial("C1E") + aDadosUtil[1,2] ) )
			C8P->( DBSetOrder( 2 ) )
			If C8P->( MsSeek(xFilial("C8P") + C1E->C1E_NATJUR ) )
				If SubStr( C8P->C8P_CODIGO, 1, 1 ) == "1"
					aAdd( aLogErro, { "C8P", "000378", "C8P", C8P->( Recno() ), cAliasPai,,"" } ) //"O evento de admissão de trabalhador cedido ({tpAdmissao} = [4]) deve atender as seguintes regras:"
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf cRegra=="REGRA_PAGTO_TRABALHADOR_EXISTENTE_RET"

	//Se o {codRendimento} for igual a [0561], o trabalhador identificado pelo cpf informado em nrInscBeneficiario deve existir no RET.
     dbSelectArea("C9V")
     C9V->(dbSetOrder(3))
     If C9V->(dbSeek(xFilial("C9V") + Alltrim(aDadosUtil[1][1]) +"1"))
     	lAchou := .F.
     	While C9V->(!Eof()) .And. C9V->C9V_CPF == aDadosUtil[1][1]
     		If C9V->C9V_STATUS == "4"
     			lAchou := .T.
     		Endif
     		C9V->(DbSkip())
     	EndDo
     	If !lAchou
     		aAdd( aLogErro, { "CRW_NRINSC", "000385", "C9V", CRW->( Recno() ), cAliasPai,,"" } ) //"O trabalhador identificado pelo cpf informado em 'Nr.Insc. Ben' deve existir no RET."
     	Endif
     Else
     	aAdd( aLogErro, { "CRW_NRINSC", "000385", "C9V", CRW->( Recno() ), cAliasPai,,"" } ) //"O trabalhador identificado pelo cpf informado em 'Nr.Insc. Ben' deve existir no RET."
     Endif

ElseIf cRegra=="REGRA_ADMISSAO_VALIDA_DURACAO_CONTRATO"

	//Se o {tpContr} for igual a [2] e a categoria do trabalhador for igual a [102], a
	//{dtTerm} não pode ser superior a 60 (sessenta) dias em relação a data de
	//admissão.

	nDifData:= aDadosUtil[1,1]
	cCatTrab:= aDadosUtil[1,2]
	dbSelectArea("CUP")
	CUP->(dbSetOrder(1))
	If CUP->(dbSeek(xFilial("CUP") + aDadosUtil[1,3] + aDadosUtil[1,4]  +"1"))
	IF CUP->CUP_TPCONT == '2' .AND. Alltrim(cCatTrab) == '102'
		If nDifData > 60
			aAdd( aLogErro, { "CUP_CODCAT", "000601", "C9V", nRecno } ) //"O Tipo Contrato for igual a '2' e a Categ. Trabalhador igual a '102' a Data Term. do contrato não deve ser superior a 60 dias em relação a Data. Admissão"		,
		Endif
	Endif
	EndIf

ElseIf cRegra=="REGRA_COMPATIB_CATEG_EVENTO"

	//O evento S-2200 é permitido apenas para as categorias de trabalhadores [101,102, 103, 104, 105, 106, 301, 302, 303, 306, 307, 309].
	//O evento S-2300 é permitido apenas para as categorias de trabalhadores [201, 202, 305, 308, 401, 410, 701, 711, 712, 721, 722, 723, 731, 734,
	//738, 741, 751, 761, 771, 781, 901, 902, 903, 904, 905].

	//Para aceitação do evento devem ser observadas as seguintes regras de compatibilidade entre a categoria de
	//trabalhador e o evento utilizado:

	//Layout - aDadosUtil[1][1]
	//Categoria do Trabalhador - aDadosUtil[1][2]

	cLayoutReg := Rtrim(aDadosUtil[1][1])
	nCatReg := Rtrim(aDadosUtil[1][2])

	if cLayoutRegn == "S2200"

	if !(nCatReg $ "101|102|103|104|105|106|111|301|302|303|306|307|309|107|108")
		aAdd( aLogErro, { "CUP_CODCAT", "000709", "C9V", CUP->( Recno() ), cAliasPai,,"" } ) //"O evento S-2200 só é aceito para as categorias de trabalhadores igual a [101, 102, 103, 104,
																										 // 105, 106, 107, 108, 111, 301, 302, 303, 306, 307, 309]"
	EndIf


ElseIf cLayoutRegn == "S2300"

	if !(nCatReg $ "201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903|904|905")
		aAdd( aLogErro, { "C9V_CATCI", "000710", "C9V", C9V->( Recno() ), cAliasPai,,"" } ) //"O evento S-2300 somente é aceito para as categorias de trabalhadores igual a [201, 202, 305, 401, 410, 701,
																										 //711, 712, 721, 722, 723, 731, 734, 738, 741, 751, 761, 771, 781, 901, 902, 903, 904, 905]."
	EndIf

EndIf



ElseIf cRegra=="REGRA_GERAL_VALIDA_NOME"

	cNomeTab := NomeTab( aDadosUtil[3] )

	//a) Não pode começar com espaço;
	//b) Não pode ter mais de um espaço entre palavras;
	//c) A primeira parte do nome deve ter pelo menos dois caracteres;
	//d) Não pode ter mais de 3 letras isoladas (abreviações) em
	//   sequência.

	cPalavra := RTrim(aDadosUtil[1])
	lControl := .F.
	nCnt 	 := 0
	nControl := 0
	cLetter  := ""

	//a) Não pode começar com espaço;
	If Substr(cPalavra, 1, 1) == " "
		aAdd( aLogErro, { aDadosUtil[2], "000639", cAliasPai, ( cAliasPai )->( Recno() ), "000591", cPalavra, cNomeTab } ) //"O Nome não pode começar com espaço."
	EndIf

	//b) Não pode ter mais de um espaço entre palavras;
	while(nCnt < Len(cPalavra))

		If Substr(cPalavra,nCnt, 2) == "  "
			lControl := .T.
		EndIf

		nCnt++
	EndDo

	If lControl
		aAdd( aLogErro, { aDadosUtil[2], "000640", cAliasPai, ( cAliasPai )->( Recno() ), "000591", cPalavra, cNomeTab } ) //"O Nome não pode ter mais de um espaço entre as palavras."
	EndIf

	//d) A primeira parte do nome deve ter pelo menos dois caracteres;
    If Len(AllTrim(Substr(cPalavra,1, 2))) < 2
     	aAdd( aLogErro, { aDadosUtil[2], "000641", cAliasPai, ( cAliasPai )->( Recno() ), "000591", cPalavra, cNomeTab } ) //"A primeira parte do nome deve ter pelo menos dois caracteres."

    Else

    	//c) Não pode conter mais que três letras iguais consecutivas;
    	//e) Não pode ter mais de 2 letras isoladas ( abreviações ) em sequência.
    	nCnt := 0
    	cLetter := ""

    	While ( nCnt < Len( cPalavra ) .and. nControl < 3 )
    		nCnt ++

    		cLetter := SubStr( cPalavra, nCnt, 1 )

    		If cLetter == SubStr( cAux, 1, 1 )
    			cAux += cLetter
    		Else
    			cAux := cLetter
    		EndIf

    		If Len( cAux ) > 3
    			l3Letras := .T.
    		EndIf

    		If cLetter == " "
    			//Verificação para abreviações com uma letra e um ponto ("S.") e com uma letra ("S")
    			If Len( AllTrim( SubStr( cPalavra, ( nCnt + 1 ), 3 ) ) ) == 2 .or. Len( AllTrim( SubStr( cPalavra, ( nCnt + 1 ), 2 ) ) ) == 1
    				nControl ++
    			Else
    				nControl := 0
    			EndIf
    		EndIf
    	EndDo

    	If l3Letras
    		aAdd( aLogErro, { aDadosUtil[2], "001008", cAliasPai, ( cAliasPai )->( Recno() ), "000591", cPalavra, cNomeTab } ) //"O Nome não pode conter mais que três letras iguais consecutivas."
    	EndIf

    	//Verifica se existem mais de 2 abreviações seguidas
    	If nControl > 2
    		aAdd( aLogErro, { aDadosUtil[2], "000642", cAliasPai, ( cAliasPai )->( Recno() ), "000591", cPalavra, cNomeTab } ) //"O Nome não pode ter mais de 2 letras isoladas ( abreviações ) em sequência."
    	EndIf

	EndIf

ElseIf cRegra=="REGRA_EXCLUI_EVENTO_AFASTAMENTO"

	If aDadosUtil[1][2] == 'E'
		CM6->( DbSetOrder( 1 ) )
		If CM6->( MsSeek( xFilial( 'CM6' ) + Alltrim(aDadosUtil[1][1]) + '2' ) )

			If !Empty(CM6->CM6_ADTAFA)
				aAdd( aLogErro, { "CM6_ADTAFA", "000714", "CM6", CM6->( Recno() ), cAliasPai,,"" } ) //"Não deve ser aceita a exclusão do evento de afastamento se já houver evento de alteração de motivo ou de retorno respectivo"
			EndIf

			If !Empty(CM6->CM6_DTFAFA)
				aAdd( aLogErro, { "CM6_DTFAFA", "000714", "CM6", CM6->( Recno() ), cAliasPai,,"" } ) //"Não deve ser aceita a exclusão do evento de afastamento se já houver evento de alteração de motivo ou de retorno respectivo"
			EndIf

			If !Empty(CM6->CM6_EFRETR)
				aAdd( aLogErro, { "CM6_EFRETR", "000714", "CM6", CM6->( Recno() ), cAliasPai,,"" } ) //"Não deve ser aceita a exclusão do evento de afastamento se já houver evento de alteração de motivo ou de retorno respectivo"
			EndIf

		EndIf
	EndIf

ElseIf cRegra == "REGRA_PERMITE_ALT_MOT_AFASTAMENTO"

	If aDadosUtil[1][3] == 'A'
		lIgual := .F.

		DO CASE
			CASE Alltrim(aDadosUtil[1][1]) == '01' .AND. Alltrim(aDadosUtil[1][2]) == '03'
				lIgual := .T.
			CASE Alltrim(aDadosUtil[1][1]) == '01' .AND. Alltrim(aDadosUtil[1][2]) == '06'
				lIgual := .T.
			CASE Alltrim(aDadosUtil[1][1]) == '02' .AND. Alltrim(aDadosUtil[1][2]) == '06'
				lIgual := .T.
			CASE Alltrim(aDadosUtil[1][1]) == '03' .AND. Alltrim(aDadosUtil[1][2]) == '01'
				lIgual := .T.
			CASE Alltrim(aDadosUtil[1][1]) == '03' .AND. Alltrim(aDadosUtil[1][2]) == '06'
				lIgual := .T.
			CASE Alltrim(aDadosUtil[1][1]) == '04' .AND. Alltrim(aDadosUtil[1][2]) == '06'
				lIgual := .T.
			OTHERWISE
				lIgual := .F.
		ENDCASE

		If !lIgual
			aAdd( aLogErro, { "CM6_MOTVAF", "000722", "CM6", CM6->( Recno() ), cAliasPai,,"" } ) //"A alteração do motivo de afastamento é permitida desde que evento de afastamento tenha ocorrido pelos motivos (01 para 03), (01 para 06), (02 para 06), (03 para 01), (03 para 06) ou (04 para 06)."
		EndIf
	EndIf

ElseIf cRegra == "REGRA_BLOQUEIA_USO_CPF_EMPREGADOR"
//Em evento de admissão, cadastramento inicial do vínculo e de remuneração,gerado por empregador pessoa física,
//o cpf do trabalhador indicado no arquivo não pode ser o mesmo cpf do empregador.

     dbSelectArea("C9V")
     C9V->(dbSetOrder(3))
     If C9V->(dbSeek(xFilial("C9V") + Alltrim(aDadosUtil[1][1]) + "1"))

     	If AllTrim(SM0->M0_CGC) == aDadosUtil[1][1]
     		aAdd( aLogErro, { "C9V_CPF", "000765", "C9V", C9V->( Recno() ), cAliasPai,,"" } ) //"O CPF do trabalhador indicado no cadastramento inicial do vínculo, não pode ser o mesmo CPF do empregador."
     	Endif

     Endif

ElseIf cRegra == "REGRA PERMITE EVENTO ANTERIOR INICIO ESOCIAL"
     dbSelectArea("C9V")
     C9V->(dbSetOrder(3))
     If C9V->(dbSeek(xFilial("C9V") + Alltrim(aDadosUtil[1][1]) + "1"))
     	dbSelectArea("CUP")
     	CUP->(dbSetOrder(1))
     	cIdVersao := C9V->C9V_ID + C9V->C9V_VERSAO
     	IF CUP->( dbSeek(xFilial("CUP")+cIdVersao ) )
			If !(aDadosUtil[1][2] > CUP->CUP_DTADMI .AND. Empty(CUP->CUP_DTDESL))
     	   		aAdd( aLogErro, { aDadosUtil[1][3], "000773", cAlias, &(cAlias)->( Recno() ), cAliasPai,,"" } ) //"A data de ocorrência do evento deve ser posterior a data de admissão do funcionário com data de desligamento em branco."
     		Endif
     	Endif
     Endif

ElseIf cRegra == "REGRA_COMPATIB_REGIME_PREV"

	 cEvtTrab   := POSICIONE("C9V",2, xFilial("C9V")+aDadosUtil[1][1]+'1',"C9V_NOMEVE")
	 cVersao := POSICIONE("C9V",2, xFilial("C9V")+aDadosUtil[1][1]+'1',"C9V_VERSAO")
	
	 If cEvtTrab == "S2200"
	 	cCodCat    := POSICIONE("CUP",1, xFilial("CUP")+aDadosUtil[1][1]+cVersao,"CUP_CODCAT")
		cTpRegPrev := POSICIONE("CUP",1, xFilial("CUP")+aDadosUtil[1][1]+cVersao,"CUP_TPREGP")
		cCodCat := POSICIONE("C87",1, xFilial("C87")+cCodCat,"C87_CODIGO")
	
	 ElseIf cEvtTrab == "S2300"
	 	cCodCat := C9V->C9V_CATCI
		//dados do vinculo da empresa cedente
		cCategOrig := POSICIONE("CUU",1, xFilial("CUP")+aDadosUtil[1][1]+cVersao,"CUU_CATSP")
		cTpPrevOri := POSICIONE("CUU",1, xFilial("CUP")+aDadosUtil[1][1]+cVersao,"CUU_TPREGP")
		cCodCatOr := POSICIONE("C87",1, xFilial("C87")+cCategOrig,"C87_CODIGO")
		cCodCat := POSICIONE("C87",1, xFilial("C87")+cCodCat,"C87_CODIGO")
	 EndIf
	
	
	If isInCallStack("TAFA250")
	
		If cEvtTrab == "S2200"
			If cCodCat $ "301|302|303|304|305|306|307|308|309" .AND. cTpRegPrev <> '1'
				aAdd( aLogErro, { "C91_TRABAL", "000812", "C9V", C91->( Recno() ), cAliasPai,,"" } ) //"Para trabalhadores com categorias iguais a [301|302|303|304|305|306|309|410], {TpRegPrev} do trabalhador deve ser igual a [1]."
			Endif
		Endif
		If cEvtTrab == "S2300"
			If cCodCat == "410" .AND. cTpPrevOri <> '1' 
				If !(cTpPrevOri == '3' .And. !(cCodCatOr  $ "301|302|303|304|305|306|307|308|309")) 
					aAdd( aLogErro, { "C91_TRABAL", "001154", "C9V", C91->( Recno() ), cAliasPai,,"" } ) //"Para trabalhadores com categorias iguais a [410], o {TpRegPrev} relativo ao contrato de trabalho firmado com a empresa cedente/de origem for igual a [1]."
		    	EndIf
		    EndIf
		EndIf
		 
	ElseIf isInCallStack("TAFA413")
		
		If cEvtTrab == "S2200"
			If cCodCat $ "301|302|303|304|305|306|307|308|309|410" .AND. (cTpRegPrev <> '2' .And. cTpRegPrev <> '3')
				aAdd( aLogErro, { "C91_TRABAL", "001156", "C9V", C91->( Recno() ), cAliasPai,,"" } ) //"Para trabalhadores com categorias iguais a [301|302|303|304|305|306|309|410], {TpRegPrev} do trabalhador deve ser igual a [1]."
			Endif
		Endif
		If cEvtTrab == "S2300"
			If cCodCat == "410" .AND. cTpPrevOri <> '2' 
				If !(cTpPrevOri == '3' .And. !(cCodCatOr  $ "301|302|303|304|305|306|307|308|309")) 
					aAdd( aLogErro, { "C91_TRABAL", "001155", "C9V", C91->( Recno() ), cAliasPai,,"" } ) //"Para trabalhadores com categorias iguais a [410], o {TpRegPrev} relativo ao contrato de trabalho firmado com a empresa cedente/de origem for igual a [1]."
		    	EndIf
		    EndIf
	    EndIf
	EndIf

ElseIf cRegra == "REGRA_VALIDA_FECHAMENTO_FOPAG"
	cDtIni		:= aDadosUtil[1][2]
	cDtFim		:= LastDate(aDadosUtil[1][2])
	cPeriodo	:= SubStr(DToS(aDadosUtil[1][2]),1,6)
	cFiltro		:= ""

	DbSelectArea("C9V")
	C9V->(dbSetOrder(1))

	DbSelectArea("CUP")
	CUP->(dbSetOrder(4))

	DbSelectArea("CUU")
	CUU->(dbSetOrder(1))

	DbSelectArea("C91")
	C91->(dbSetOrder(4))

	DbSelectArea("CM6")
	CM6->(dbSetOrder(2))

	DbSelectArea("T3A")

	DbSelectArea("C1E")
	C1E->( DBSetOrder( 3 ) )

	//	Regra A
	//	Não deve existir evento de admissão parcial (S-2190) sem o correspondente evento
	//	de admissão (S-2200) cuja "data de admissão" seja anterior ou igual ao período
	//	de apuração da folha de pagamento.

	cFiltro		:= " T3A->T3A_FILIAL == xFilial('T3A') .And. T3A->T3A_ATIVO == '1' .And. T3A->T3A_STATUS == '4' .And. DToS(T3A->T3A_DTADMI) <= '" + DToS(cDtFim) + "' "

	T3A->(DbSetFilter( {||&(cFiltro)},cFiltro ))
	T3A->(DbGoTop())

	While T3A->(!EOF())

		cIdTrab := POSICIONE("C9V",3, xFilial("C9V") + T3A->T3A_CPF + "1","C9V_ID")

		If Empty(cIdTrab)
			AADD(aLogErro,{ "T1S_ID","001030", "T1S", nRecno }) //"Não deve existir evento de admissão parcial (S-2190) sem o correspondente evento de admissão (S-2200) cuja 'data de admissão' seja anterior ou igual ao período de apuração da folha de pagamento."
			Exit
		EndIf

		T3A->(dbSkip())
	EndDo

	T3A->(dbClearFilter())


 	// 	Regra B1
	// 	Todos os trabalhadores admitidos em período igual ou anterior ao período de apuração que não estejam
	// 	desligados ou cujo desligamento seja posterior ao período de apuração, devem possuir o respectivo
	// 	evento de remuneração já encaminhado para o mesmo período de apuração, exceto se o trabalhador estiver
	// 	afastado durante todo o período de apuração em um dos seguintes códigos de afastamento
	// 	[03,05,06,07,11,12,13,14,21,22,23,24,25,27,28,30,31,37];

	// Verifica folha dos trabalhadores (com/sem vínculo) ativos
	cFiltro		:= " C9V->C9V_FILIAL == xFilial('C9V') .And. C9V->C9V_ATIVO == '1' .And. C9V->C9V_STATUS == '4' .And. C9V->C9V_NOMEVE $ 'S2200|S2300' "

	C9V->(DbSetFilter( {||&(cFiltro)},cFiltro ))

	C9V->(DbGoTop())

 	While C9V->(!EOF())
		lVldFolha	:= .F.

		// 	Cadastro do trabalhador (com vínculo)
		If C9V->C9V_NOMEVE == 'S2200'

			IF CUP->(dbSeek(xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO + C9V_NOMEVE)))
	     		IF CUP->CUP_DTADMI < cDtIni .And. ( Empty(CUP->CUP_DTDESL)  .Or. (CUP->CUP_DTDESL >= cDtIni) )

			    	// Verifica se existe Folha de pagamento para o trabalhador
			    	IF C91->(dbSeek(xFilial("C91") + C9V->C9V_ID ))
			    		lVldFolha := ( C91->C91_STATUS == '4' .And. C91->C91_PERAPU == cPeriodo .And. C91->C91_INDAPU == aDadosUtil[1][3] )
			    	Endif
			    Else
			    	lVldFolha := .T.
			    EndIf
			EndIf

		// 	Cadastro do trabalhador (sem vínculo)
		Else
			IF CUU->(dbSeek(xFilial("CUU") + C9V->(C9V_ID + C9V_VERSAO + C9V_NOMEVE)))
	     		IF C9V->C9V_DTINIV < cDtIni .And. ( Empty(CUU->CUU_DTERAV)  .Or. (CUU->CUU_DTERAV >= cDtIni) )

			    	// Verifica se existe Folha de pagamento para o trabalhador
			    	IF C91->(dbSeek(xFilial("C91") + C9V->C9V_ID ))
			    		lVldFolha := ( C91->C91_STATUS == '4' .And. C91->C91_PERAPU == cPeriodo .And. C91->C91_INDAPU == aDadosUtil[1][3] )
			    	Endif
			    Else
			    	lVldFolha := .T.
			    EndIf
			EndIf
		EndIf

		// Se não econtrou folha, verifica se possui afastamento
		// nas categorias |03|05|06|07|11|12|13|14|21|22|23|24|25|27|28|30|31|
		If !lVldFolha
			IF CM6->(dbSeek(xFilial("CM6" + C9V->C9V_ID)))
				cCateg := Posicione("C8N",2,xFilial("C8N") + CM6->CM6_MOTVAF,"C8N_CODIGO")

				IF !(cCateg $ "|03|05|06|07|11|12|13|14|21|22|23|24|25|27|28|30|31|37|")
					AADD(aLogErro,{ "C9V_ID","000824", "C9V", nRecno }) //"O trabalhador deve possuir evento de remuneração(S-1200) já encaminhado para o mesmo período de apuração."
					lErro	:= .T.
					Exit
				EndIf
			Else
				AADD(aLogErro,{ "C9V_ID","000824", "C9V", nRecno }) //"O trabalhador deve possuir evento de remuneração(S-1200) já encaminhado para o mesmo período de apuração."
				lErro	:= .T.
				Exit
			EndIf
		EndIf

		C9V->(dbSkip())
	EndDo


	C9V->(dbClearFilter())

	//	Regra C
	//	O FAP informado em S-1005 deve corresponder ao constante no cadastro do empregador na
	// 	RFB (CNPJ) para cada estabelecimento. Divergências só são aceitas se houver informações
	// 	de processo relativo ao FAP.

	If C1E->( MsSeek( xFilial( 'C1E' ) + aDadosUtil[1,5] ) )
		If ( !( C1E->C1E_STATUS $ " 1" ) .Or. ( C1E->C1E_ATIVO $ "1" ) )
			If aDadosUtil[1,4] == "2"
				If !(Posicione("C1G",8,xFilial("C1G") + C1E->C1E_PRFFAP + "1","C1G_TPPROC") == "2")
					AADD(aLogErro,{ "C1E_PRFFAP","000401", "C1E", nRecno }) //"O campo Forma FAP somente pode ser igual a [2] se houver informação sobre a existência de processo judicial relativo ao FAP nas informações do empregador."
					lErro	:= .T.
				EndIf
			EndIf
		EndIf
	EndIf
Elseif cRegra == "REGRA_ADMISSAO_RETIFICA_DT_ADM"

	aRotinas := TAFRotinas( , , .T. , 2 )

	for nRotinas := 1 to len( aRotinas )

		//posição 3 do array TAFRotinas - alias
		cAliasRot := aRotinas[ nRotinas , 3 ]
		//posição 6 do array TAFRotinas - data
		cFldData := aRotinas[ nRotinas , 6 ]
		//posição 11 do array TAFRotinas - campo de id do trab
		cFldIdTrab := aRotinas[ nRotinas , 11 ]
		//posição 12 do array TAFRotinas - tipo do evento
		cTpEvento := aRotinas[ nRotinas , 12 ]

		if	!empty( cAliasRot ) .and.;
			!empty( cFldData ) .and.;
			!empty( cFldIdTrab ) .and.;
			!empty( cTpEvento ) .and.;
			cTpEvento == 'E'			// somente para eventos não periódicos

			cQuery:="SELECT " +  cFldData +;
					" FROM " + RetSqlName( cAliasRot ) +;
					" WHERE " +  cAliasRot + "_FILIAL = '" + xFilial( cAliasRot ) + "' AND " +;
						cFldIdTrab + " = '" + aDadosUtil[ 2 ] + "' AND " +;
						cFldData + " <= '" + DToS( aDadosUtil[ 1 ] ) + "' AND " +;
						cAliasRot + "_ATIVO = '1' AND D_E_L_E_T_ = ''"

			//Executa a query
			cAliasQry := GetNextAlias()
			cQuery := ChangeQuery( cQuery )
			TcQuery cQuery New Alias &cAliasQry

			if !( cAliasQry )->( eof() )
				aAdd( aLogErro , { cFldData , "000965" , cAlias , nRecno } ) //Somente é possível retificar o evento de admissão se não existirem eventos não periódicos anteriores à data de admissão
			endif

			( cAliasQry )->( dbCloseArea() )

		endif

	next nRotinas

Elseif cRegra == "REGRA_TOTALIZ_CONTING"
//O evento S-1295 é destinado a solicitar totalização de contribuições sociais devidas pelo contribuinte em situações de contingência, quando não se pode fazer o encerramento dos eventos periódicos através do evento S-1299.
//Portanto, sua utilização é restrita e está sujeito às seguintes regras:

	//a) Somente pode ser enviado até três (3) vezes por período de apuração;
	DbSelectArea("T72")
	T72->( dbSetOrder(1) )
	T72->( dbGoTop() )

	If T72->( MsSeek( xFilial( 'T72' ) + aDadosUtil[1][1] ) )

		While T72->(!Eof()) .AND. T72->( T72_FILIAL + T72_ID ) == xFilial("T72") + aDadosUtil[1][1]

			If ! Empty(T72->T72_PROTUL) .AND. T72->T72_STATUS == "4"
				nQtdEnvio++

				If nQtdEnvio > 3
					AADD(aLogErro,{ "T72_ID","001001", "T72", nRecno }) //"O evento S-1295 somente pode ser enviado até três (3) vezes por período de apuração."
					Exit
				EndIf
			EndIf
			T72->( DbSkip() )

		EndDo

	EndIf

	//b) Sua aceitação só é possível caso não sejam satisfeitas as regras estabelecidas para o evento S-1299 - REGRA_VALIDA_FECHAMENTO_FOPAG
	If !lErro
		AADD(aLogErro,{ "T72_ID","001004", "T72", nRecno }) //"A aceitação do evento S-1295 só é possível caso não sejam satisfeitas as regras estabelecidas para o evento S-1299 [REGRA_VALIDA_FECHAMENTO_FOPAG]."
	EndIf

	//c) Só é aceito entre os dias 01 e 20 do mês subsequente ao do período de apuração, no caso de apuração mensal ({perApur} no formato 'AAAA-MM') e entre os dias 01 e 20 de dezembro,
	//no caso de folha de pagamento anual ({perApur} no formato 'AAAA').
	dDtPerApu := STOD( Alltrim(aDadosUtil[1][3]) + Iif(aDadosUtil[1][2] == "1","01","0101") )

	If aDadosUtil[1][2] == "1"
		If Day(dDtSolic) > 20 .OR. dDtSolic <= dDtPerApu   .OR. !DateDiffMonth( dDtSolic , dDtPerApu ) == 1
			AADD(aLogErro,{ "T72_PERAPU","001002", "T72", nRecno }) //"No caso de apuração mensal {perApur} no formato 'AAAA-MM', somente é aceito solicitações entre os dias 01 e 20 do mês subsequente ao do período de apuração."
		EndIf
	Else
		If Day(dDtSolic) > 20 .OR. ! Month(dDtSolic) == 12
			AADD(aLogErro,{ "T72_PERAPU","001003", "T72", nRecno }) //"No caso de folha de pagamento anual {perApur} no formato 'AAAA', somente é aceito solicitações entre os dias 01 e 20 de dezembro."
		EndIf
	EndIf

Elseif cRegra == "REGRA_TSV_RETIFICA_EVENTO_INICIO"
//Em caso de retificação do evento "Trabalhador Sem Vínculo de Emprego/Estatutário - Início", o evento retificador deve se referir ao mesmo CPF e "categoria" informado
//no evento original. Por integrar a "chave" de identificação para este tipo de evento, a "categoria" não pode ser objeto de retificação. Caso tenha sido informado
//incorretamente, o evento de início deve ser excluído e um novo evento com a categoria correta deve ser enviado.

	cCPFAnt 	:= POSICIONE("C9V",1, xFilial("C9V") + aDadosUtil[1,1] + aDadosUtil[1,2] + "S2300","C9V_CPF")
	//cCategAnt 	:= POSICIONE("CUU",1, xFilial("CUU") + aDadosUtil[1,1] + aDadosUtil[1,2] + "S2300","CUU_CATAV")
	cCategAnt	:= C9V->C9V_CATCI

	If !cCPFAnt == aDadosUtil[1,3] .OR. !cCategAnt == aDadosUtil[1,4]
		AADD(aLogErro,{ "C9V_CATCI","001027", "C9V", nRecno }) //"o evento retificador deve se referir ao mesmo CPF e "categoria" informado no evento original. Por integrar a "chave" de identificação para este tipo de evento, a "categoria" não pode ser objeto de retificação. Caso tenha sido informado incorretamente, o evento de início deve ser excluído e um novo evento com a categoria correta deve ser enviado."
	EndIf

ElseIf cRegra == "REGRA_EXISTE_CAT_ORIGEM"
	cFilialSM0	:= PadR(AllTrim(aDadosUtil[1,1]),FWSizeFilial())
	cNrCat		:= PadR(AllTrim(aDadosUtil[1,2]),TamSX3('CM0_NRCAT ')[1])
	dDtCat		:= aDadosUtil[1,3]
	cTrabal		:= PadR(AllTrim(aDadosUtil[1,4]),TamSX3('CM0_TRABAL')[1])
	lErro		:= .F.
	
	// Procura na tabela de CAT se já existe a CAT Original para o trabalhador
	// caso CAT inicial seja informado
	If !Empty(cNrCat)
		lErro	:= .T.
		CM0->(DBSetOrder(1)) // CM0_FILIAL+CM0_ID+CM0_VERSAO
		
		If CM0->(MsSeek( cFilialSM0 + cNrCat))
			While !CM0->(EOF()) .And. CM0->CM0_FILIAL == cFilialSM0 .And. CM0->CM0_ID == cNrCat
				If CM0->CM0_ATIVO == "1" .And. CM0->CM0_TRABAL == cTrabal .And. CM0->CM0_DTACID == dDtCat .And. CM0->CM0_STATUS == '4'
					lErro := .F.
					Exit
				EndIf
				CM0->( DbSkip() )
			EndDo
		EndIf
		
		If lErro
			AADD(aLogErro,{ "CM0_NRCAT","001171", "CM0", nRecno }) //"Se {nrRecCatOrig} for informado, deve existir no RET e ser relativo ao trabalhador (CPF + matrícula, no caso de empregado; ou CPF + categoria, no caso de TSVE)."
		EndIf
	EndIf
EndIf

(cAlias)->( DBGoTo( nRecno ) )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldPer

Validacao de periodo de vigencia conflitante

@Param:
dDataIni  - Data inicial posicionada
dDataFin  - Data final posicionada
dDtIniOri - Data inicial original para comparacao
dDtFinOri - Data final original para comparacao

@Return:
lRet - Indica o resultado das comparacoes

@author Felipe C. Seolin
@since 08/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function xVldPer( dDataIni, dDataFin, dDtIniOri, dDtFinOri )

Local lRet	:=	.T.

If dDataIni >= dDtIniOri .and. dDataIni <= dDtFinOri
	lRet := .F.

ElseIf dDataFin >= dDtIniOri .and. dDataFin <= dDtFinOri
	lRet := .F.

ElseIf dDtIniOri >= dDataIni .and. dDtIniOri <= dDataFin
	lRet := .F.

ElseIf dDtFinOri >= dDataIni .and. dDtFinOri <= dDataFin
	lRet := .F.

EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xIniESoc

Retorna data base de inicio da e-Social

@param:

@return:
dIniESoc - Data base definida para implantacao da e-Social

@author Evandro dos Santos Oliveira
@since 17/01/2014
@version 1.0
/*/
Function xIniESoc()

Return( dIniESoc )

//------------------------------------------------------------------------
/*/{Protheus.doc} xVldRegCpo

Valida regra de campo (x3_valid) e exibe um help específico

@Param:
cCampo - Campo a ser validado

@Return:
lRet - Indica o resultado das comparacoes

@author Felipe C. Seolin
@since 08/10/2013
@version 1.0

/*/
//------------------------------------------------------------------------
Function xVldRegCpo( cCampo )

Local cCpo	:=	SubStr( ReadVar(), 4 )
Local lRet	:=	.T.

if cCpo == "CRR_VLRTOT"
	If (M->CRR_VLRTOT < FWFLDGET("CRR_VLREXP"))
   		lRet:= .F.
   		Help( ,,"TAF239RECBRUTO",,, 1, 0 )
	EndIf
Endif

if cCpo == "CRR_VLTRIB"
	If (M->CRR_VLTRIB > FWFLDGET("CRR_VLRTOT"))
   		lRet:= .F.
   		Help( ,,"TAF239VLTRIB",,, 1, 0 )
	EndIf
Endif

If cCpo == "CRR_ALIQPA"
	If FWFLDGET("CRR_INDSUB")=='1' .and. M->CRR_ALIQPA<>0
		lRet:= .F.
		Help( ,,"TAF239VLALIQPA",,, 1, 0 )
	EndIf
Endif

If cCpo == "CRV_TOTMES"
	If FWFLDGET("CRV_INDAPU")=="2" .and. M->CRV_TOTMES<>0
   		lRet:= .F.
		Help( ,,"TAF292TOTMES",,, 1, 0 )
	EndIf
Endif

If cCpo == "CRV_TOTANO"
	If M->CRV_TOTANO < FWFLDGET("CRV_TOTMES")
   		lRet:= .F.
		Help( ,,"TAF292TOTANO",,, 1, 0 )
	EndIf
Endif

If cCpo == "CRV_ASSMES"
	If FWFLDGET("CRV_INDAPU")=="2" .and. M->CRV_ASSMES<>0
   		lRet:= .F.
		Help( ,,"TAF292TOTMES",,, 1, 0 )
	EndIf
Endif

If cCpo == "CRV_ASSANO"
    If M->CRV_ASSANO < FWFLDGET("CRV_ASSMES")
   		lRet:= .F.
		Help( ,,"TAF292TOTANO",,, 1, 0 )
	EndIf
Endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xValLogEr

@param aLogErro - Array contendo as caracteristicas do erro
@return (cString)

Função responsavel por retornar quantidade de erros na tela

@author Fabio V. Santana
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xValLogEr( aLogErro )

Local cMsgErro	:= ""
Local nX		:= 0
Local nPos		:= 0

//Quando se tratar da mensagem 000305 não se é erro mas sim alerta de registro já validado anteriormente
nPos := aScan( aLogErro, { |x| x[2] == '000305' } )

if nPos <= 0
	cMsgErro := "Este registro possui " + AllTrim(STR(Len(aLogErro)))+ " Inconsistência(s):" + CRLF + CRLF
else
	cMsgErro := "Este registro possui 0 Inconsistência(s):" + CRLF + CRLF
endif

For nX := 1 to Len(aLogErro)
	If Len(aLogErro[nX]) > 4
		If Len(aLogErro[nX][1]) <= 3
			cMsgErro += iif( nPos > 0, '' , AllTrim(Str(nX)) + "º Inconsistencia : " + Alltrim(FWX2Nome(aLogErro[nX][1]))+" - ("+ aLogErro[nX][1] +")" +" - " ) + Alltrim(aLogErro[nX][6]) +". " + xValStrEr(aLogErro[nX][2])+ CRLF// + CRLF
		Else
			cMsgErro += iif( nPos > 0, '' , AllTrim(Str(nX)) + "º Inconsistencia : " + AllTrim( TitSX3(aLogErro[nX][1])[1]) +" - ("+ aLogErro[nX][1] +")" +" - " ) + Alltrim(aLogErro[nX][6]) +". " + xValStrEr(aLogErro[nX][2])+ CRLF// + CRLF
		EndIf
		cMsgErro += xValStrEr(aLogErro[nX][5]) + RTRIM(aLogErro[nX][7]) + "." + CRLF + CRLF

   	Else
		cMsgErro += iif( nPos > 0, '' , AllTrim(Str(nX)) + "º Inconsistencia : " + AllTrim(TitSX3(aLogErro[nX][1])[1]) +" - ("+ aLogErro[nX][1] +")" + " - " ) + xValStrEr(aLogErro[nX][2]) + CRLF + CRLF
	EndIf
Next nX

if nPos <= 0 .and. Len(aLogErro) > 0
	cMsgErro += CRLF
	cMsgErro += "As inconsistências apresentadas acima não impedem a transmissão deste evento ao Governo por parte do TAF. Estas mensagens são referentes a uma pré validação das regras de transmissão constantes no layout do eSocial." + CRLF
	cMsgErro += "Salientamos a importância de corrigi-las para evitar a rejeição deste evento por parte do Governo após a transmissão." 
EndIf

Aviso("Log de Validação",cMsgErro,{"Fechar"},3)

Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} xValStrEr
Função responsavel por retornar a descrição do erro.

@param nOpcValid - Numero do erro

@return (cString)

@author Fabio V. Santana
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xValStrEr( cOpcValid )

	Local cString	:=	""

	Default cOpcValid	:=	""

	Do Case

		Case cOpcValid == "000001"
			cString := STR0001	//"Verifique o Status do Evento, para que este seja um registro valido, o STATUS deve ser igual a 0, 2, 3 ou 4"
		Case cOpcValid == "000002"
			cString := STR0002   //"Verifique a data de vigência do registro."
		Case cOpcValid == "000003"
			cString := STR0003   //"Verifique a data Inicial do Registro."
		Case cOpcValid == "000004"
			cString := STR0004   //"Verifique a data Final do Registro."
		Case cOpcValid == "000005"
			cString := STR0005	//"CPF/CNPJ Inconsistente."
		Case cOpcValid == "000006"
			cString := STR0006	//"Conteúdo do campo não condiz com as opções possíveis."
		Case cOpcValid == "000007"
			cString := STR0007  //"Hora Inconsistente ou Vazia."
		Case cOpcValid == "000008"
			cString := STR0008   //"Registro não encontrado na tabela."
		Case cOpcValid == "000009"
			cString := STR0009  //"Data Inconsistente ou Vazia."
		Case cOpcValid == "000010"
			cString :=	STR0010  //"Campo Inconsistente ou Vazio."
		Case cOpcValid == "000011"
			cString :=	STR0011  //"O {cpfTrab} informado no evento deve existir na base de dados do RET (como empregado ou como TSV), e deve estar ativo na data do acidente.   Caso contrário, as informações de {infoAdicionais} deverão ser preenchidas, e a categoria informada deve ser relativa a trabalhador não sujeito a evento de admissão ou de início de trabalhador sem vínculo (atualmente categorias 701, 702, 703, 711, 712, 713)."
		Case cOpcValid == "000012"
			cString :=	STR0012  //"Se informado nrCatOrigem e a dtCatOrigem for posterior ao início da e-Social, o nrCatOrigem informado deve existir no RET e ser relativo ao vínculo."
		Case cOpcValid == "000013"
			cString :=	STR0013  //"Em caso de retificação do evento de ASO para alterar a {dtAcidente}, verificar a existência de evento subsequente de afastamento em decorrência de acidente de trabalho, de forma a evitar inconsistência na cronologia dos eventos. (ex: acidente em jan/201x, afastamento em jan/201x por acidente de trabalho, depois tenta alterar a data do acidente do evento para mar/201x)."
		Case cOpcValid == "000014"
			cString := STR0014 //"Neste caso, ou seja, se houver evento de afastamento temporário por acidente de trabalho, a dtAcidente somente poderá ser retificada para uma data anterior a dtAfastamento)."
		Case cOpcValid == "000016"
			cString :=	STR0016  //"O preenchimento é obrigatório se o Indicativo de Contratação de Aprendiz for igual a 1 ou 2"
		Case cOpcValid == "000017"
			cString :=	STR0017  //"O preenchimento é obrigatório se o Indicativo de Contratação de Aprendiz for igual a 1"
		Case cOpcValid == "000019"
			cString := STR0019 //"Em caso de {inclusao} ou {alteração}, verificar a existência de outro registro em período de vigência conflitante."
		Case cOpcValid == "000037"
			cString := STR0037 //"Em caso de retificação, o evento retificador deve referir-se ao mesmo vínculo (CPF + Matricula) do evento original;"
		Case cOpcValid == "000042"
			cString := STR0042 //"Para recepção do evento é necessário que já tenha sido enviado o evento de 'abertura' da folha de pagamentos(original ou com indicativo de retificação) para o período de apuração indicado no evento."
		Case cOpcValid == "000064"
			cString := STR0064 //"A data de opção do trabalhador pelo FGTS deve ser uma data igual ou posterior à data de admissão do empregado ou data de início do TSVE."
		Case cOpcValid == "000065"
			cString := STR0065 //"1. Se a data de admissão/data de início é posterior a 04/10/1988, a data de opção deve ser igual à data de admissão/data de início, exceto categorias [104] e [721]."
		Case cOpcValid == "000066"
			cString := STR0066 //"2. Se a data de admissão/data de início é entre 01/01/1967 e 04/10/1988, a data de opção deve ser entre a data de admissão/data de início e 05/10/1988, exceto categorias [104] e [721]."
		Case cOpcValid == "000067"
			cString := STR0067 //"3. Se a data de admissão/data de início é anterior a 01/01/1967, a data de opção deve ser entre 01/01/1967 e 05/10/1988, exceto categorias [104] e [721]."
		Case cOpcValid == "000068"
			cString := STR0068 //"4. Para a categoria [104] (doméstico), a data de opção deve ser igual ou posterior à data de admissão e nunca anterior a 01/03/2000."
		Case cOpcValid == "000069"
			cString := STR0069 //"5. Para a categoria [721] (diretor não empregado, com FGTS), a data de opção deve ser igual ou posterior à data de início e nunca anterior a 02/06/1981."
		Case cOpcValid == "000071"
			cString := STR0071 //"Foi definido que a chave de identificação de cada vínculo trabalhista na empresa (CNPJ base) é a MATRICULA, que é atribuída pelo Empregador. Não poderá existir no RET, para a mesma empresa, trabalhador com mesmo número de matrícula do trabalhador a ser admitido (Recusar Evento);"
		Case cOpcValid == "000084"
			cString := STR0084 + STR0085 + STR0086 //STR0084 + STR0085 + STR0086 - ##"Para as situações abaixo, emitir aviso de que o evento está sendo informado fora do prazo:" ##"- No caso do Evento de Desligamento, caso o evento esteja sendo informado fora do prazo estabelecido (nos dez dias que sucedem à data de desligamento, inclusive)." ##"- No caso do Evento de Admissão, caso o evento seja informado a partir do dia seguinte à data de admissão."
		Case cOpcValid == "000088"
			cString := STR0088 //"Em caso de exclusão, deve existir o registro na tabela com o mesmo código e período de validade informados no evento."
		Case cOpcValid == "000090"
			cString := STR0090 //"Em caso de alteração, deve existir registro na tabela com o mesmo código e período de validade informados no evento."
		Case cOpcValid == "000091"
			cString := STR0091 //"Em caso de inclusão,  não deve existir outro registro na tabela com o mesmo código de identificação (chave) em período de vigência conflitante com o período informado no registro atual."
		Case cOpcValid == "000093"
			cString := STR0093 //"Em caso de alteração de período de validade das informações, não deve existir outro registro na tabela com o mesmo código de identificação (chave) em período de vigência conflitante com o novo período de validade informado."
		Case cOpcValid == "000098"
			cString := STR0098 //"O código do CBO atribuído ao cargo deve existir na tabela de CBO."
		Case cOpcValid == "000176"
			cString := STR0176 //"No evento de remuneração, caso o registro de identificação do estabelecimento indique um número de CNPJ ou CNO, verificar a existência do estabelecimento indicado na tabela de ESTABELECIMENTOS/OBRAS, com o preenchimento da respectiva informação de FPAS."
		Case cOpcValid == "000188"
			cString := STR0188 //""A categoria indicada no registro de remuneração de trabalhadores sujeitos ao RET (segurado empregado ou trabalhador sem vínculo) deve ser igual àquela existente no RET para o referido vínculo (matrícula) ou tipo de trabalhador.""
		Case cOpcValid == "000190"
			cString := STR0190 //"O {nrCno} não deve ser informado se {indObra} = [0]. Se {indObra} for igual a 1 (Empreitada Total), o {nrCNO} informado deve ser de propriedade do {ideEstabPrestador}. Se {indObra} for igual a 2 (Empreitada Parcial), o {nrCNO} informado deve ser de propriedade do contratante indicado em {ideContratante}. Se {indObra} for igual a 3 (Subempreitada), o {nrCNO} informado deve ser de propriedade do {proprietarioCNO}"
		Case cOpcValid == "000193"
			cString := STR0193 //"Com base na categoria indicada no registro superior ao qual a rubrica está vinculada, analisar:"
		Case cOpcValid == "000202"
			cString :=	 STR0202 //"Se {indApuracao} for igual a [2] (décimo terceiro salário), são permitidas apenas as rubricas cujo {codIncCP} da tabela de Rubricas seja igual a [00, 01, 12, 22, 26, 32, 92, 94] e cujo {codIncIRRF} seja igual a [00, 01, 12, 14, 16, 32, 42, 47, 52, 57, 62, 64, 71, 77, 81, 82, 83, 92]."
		Case cOpcValid == "000203"
			cString :=	 STR0203 //"Se a categoria indicada no registro de remuneração ({remunPeriodoApuracao} ou {remunPeriodoAnterior}) ao qual a rubrica encontra-se vinculada for relativa a SEGURADO EMPREGADO, e o mesmo encontre-se afastado durante o mês inteiro pelos motivos [01,02,03,04], não é permitida a inclusão de rubrica cujo {codIncidCP} seja diferente de [00]."
		Case cOpcValid == "000204"
			cString :=	 STR0204 //"Quando a categoria indicada no registro de remuneração ({remunPeriodoApuracao} ou {remunPeriodoAnterior}) indicar 'segurado empregado', verificar no RET a informação prestada no campo {tpRegimePrev} do evento de admissão (e respectivas alterações), pois se {tpRegimePrev} igual a [2,3] somente podem ser incluídas rubricas com {codIncidCP} igual a [00]."
		Case cOpcValid == "000213"
			cString :=	 STR0213 //"O evento deve apresentar preenchimento em pelo menos um dos grupos de informação: {infoRecursoRecebido} ou {infoRecurosRepassado}"
		Case cOpcValid == "000267"
			cString := STR0267 //"A data de admissão do trabalhador:"
			cString += Chr(13) + Chr(10) + STR0268 //"* Para a categoria [103] (aprendiz), deve ser maior ou igual a [20/12/2000]"
		Case cOpcValid == "000294"
			cString :=	 STR0294 //A Data Final ( Se Informada ) deve ser posterior a Data Inicial
		Case cOpcValid == "000295"
			cString :=	STR0295  //Informação obrigatória para geração do arquivo XML
		Case cOpcValid == "000296"
			cString := STR0296   //O Indicador de Cooperativa não pode ser diferentes de ( 0, 1, 2, 3 )
		Case cOpcValid == "000297"
			cString :=	STR0297  //O Indicativo de Construtora não pode ser diferentes de ( 0, 1 )
		Case cOpcValid == "000298"
			cString :=	STR0298  //Data Inicial não informada
		Case cOpcValid == "000299"
			cString :=	STR0299  //O Ministério / Lei que concedeu o certificado não pode ser diferente de ( CNAS, MEC, MS, MDS, LEI )
		Case cOpcValid == "000300"
			cString :=	STR0300   //O tipo da conta bancária não pode ser diferente de ( 1, 2 )
		Case cOpcValid == "000301"
			cString :=	STR0301  //A informação não pode ser diferente de ( S, N )
		Case cOpcValid == "000302"
			cString :=	STR0302  //A classificação tributária 70 ( Base Alcântara ) somente pode ser utilizada se o tipo de inscrição for CNPJ e o número da inscrição iniciar com 07752497
		Case cOpcValid == "000303"
			cString :=	STR0303  //Não é possível validar o evento pois o funcionário possui uma CAT que indica óbito com data anterior ao do evento.
		Case cOpcValid == "000304"
			cString :=	STR0304  //"Não existe vínculo ativo para o trabalhador."
		Case cOpcValid == "000305"
			cString :=	STR0305  //"Registros que já foram transmitidos ao Fisco, não podem ser validados."
		Case cOpcValid == "000306"
			cString := STR0306 //"Quando Tipo de Intervalo for igual a 1, preencher apenas Início e Término do intervalo. Quando for igual a 2, preencher apenas a Duraçao do intervalo"
		Case cOpcValid == "000307"
			cString := STR0307 //"O mês e/ou ano da data deve ser igual ao período de apuração"
		Case cOpcValid == "000308"
			cString := STR0308 //"Data do exame deve ser anterior ou igual a data do ASO"
		Case cOpcValid == "000309"
			cString := STR0309 //"Registro Duplicado"
		Case cOpcValid == "000310"
			cString := STR0310 //"Evento em Branco ou Inválido. Eventos válidos: S-2820 e S-1100 a S-1500"
		Case cOpcValid == "000311"
			cString := STR0311 //"O valor da contribui‡Æo destinada ao SENAR deve correponder a 0,2% sobre o valor bruto da nota"
		Case cOpcValid == "000312"
			cString := STR0312 //"O valor da contribui‡Æo destinada ao financiamento dos benef¡cios concedidos em razÆo do grau de incidˆncia da incapacidade laborativa decorrente dos riscos ambientais do trabalho deve corresponder a 0,1% sobre o valor bruto da nota"
		Case cOpcValid == "000313"
			cString := STR0313 //"O valor da Contribui‡Æo Previdenci ria deve correponder a 2% sobre o valor bruto da nota"
		Case cOpcValid == "000314"
			cString := STR0314 //"Se {indAquisicao} do registro correspondente for igual a [2] ou [3], preencher com zero."
		Case cOpcValid == "000315"
			cString := STR0315 //"Se houver detalhamento das notas fiscais, o valor deve corresponder a soma do campo correspondente dos registros vinculados."
		Case cOpcValid == "000316"
			cString := STR0316 //"Deve corresponder a soma de {vlrBruto} dos registros vinculados."
		Case cOpcValid == "000317"
			cString := STR0317 //"Os indicativos [2,3] somente podem ser utilizados se o declarante for Pessoa Juridica."
		Case cOpcValid == "000318"
			cString := STR0318 //"Informar o mês/ano (formato AAAA-MM) de referência das informações, se {indApuracao} for igual a [1], ou apenas o ano (formato AAAA), se {indApuracao} for igual a [2]."
		Case cOpcValid == "000319"
			cString := STR0319 //"A Data do Aviso Previo deve ser posterior a data de admissao do funcionario"
		Case cOpcValid == "000320"
			cString := STR0320 //"Data projetada para o afastamento deve ser posterior a data do Aviso Previo"
		Case cOpcValid == "000321"
			cString := STR0321 //"A Data do cancelamento do aviso Previo deve ser posterior a data do aviso previo"
		Case cOpcValid == "000322"
			cString := STR0322 //"Receita bruta total de vendas de bens e serviços deve ser superior a receita bruta da venda de serviços para o mercado externo"
		Case cOpcValid == "000323"
			cString := STR0323 //"Valor dos impostos e contribuições incidentes sobre a receita bruta de venda deve ser inferior a receita bruta total de vendas de bens e serviços"
		Case cOpcValid == "000324"
			cString := STR0324 //"A quantidade de meses em atividade deve ser igual ou menor a 12"
		Case cOpcValid == "000325"
			cString := STR0325 //"Percentual de redução a ser aplicado na alíquota da contribuição previdenciária patronal não corresponde a Rec.Brut.Ven.Serv.Merc.Ex / (Receita Bruta Total da venda de Bens e serviços para o mercado externo - Vlr.Imp.Contr.Inc.RecBrut)] x 0,1 x 100"
		Case cOpcValid == "000326"
			cString := STR0326 //"Receita bruta total ano deve ser superior a receita bruta total mes"
		Case cOpcValid == "000327"
			cString := STR0327 //"Receita bruta da atividade sem substituição acumulada deve ser superior a receita bruta da atividade sem substituição no mês"
		Case cOpcValid == "000328"
			cString := STR0328 //"Fator do Mês deve ser igual a Rec.Bruta Atividade Mês / Rec.Bruta Total Mês"
		Case cOpcValid == "000329"
			cString := STR0329 //"Fator do 13º Salário deve ser igual a Rec.Bruta Atividade Ano / Rec.Bruta Total Ano"
		Case cOpcValid == "000330"
			cString := STR0330 //"Número de inscrição incompatível com o numero de inscrição do registro pai"
		Case cOpcValid == "000331"
			cString := STR0331 //"O Vr. Retido Prod. Rural não pode ser superior a Vr Bruto Comercialização quando o numero de inscrição for igual a 2 (CPF)"
		Case cOpcValid == "000332"
			cString := STR0332 //"Se Ind. de Comercialização for igual a [3,8], o campo Vlr Tot Comercialização deve ser igual a soma dos registros Vr Bruto Comercialização vinculados a ele."
		Case cOpcValid == "000333"
			cString := STR0333 //"Não existe registro correspondente na tabela de estabelecimentos."
		Case cOpcValid == "000334"
			cString := STR0334 //"Não existe registro correspondente na tabela de operadores portuários."
		Case cOpcValid == "000335"
			cString := STR0335 //"A data de admissão deve ser anterior a data de início do e-Social."
		Case cOpcValid == "000336"
			cString := STR0336//"Tipo de evento é incompatível com a classificação tributária do contribuinte."
		Case cOpcValid == "000337"
			cString := STR0337 //"A classificação tributária [70] (Base Alcântara) somente pode ser utilizada se {tpInscricao} = [1] (Cnpj) e {nrInscricao} iniciar com 07752497"
		Case cOpcValid == "000338"
			cString := STR0338 //"A data do evento deve estar compreendida entre a data de início e de término indicadas nos eventos de "Trabalhador Sem Vínculo"."
		Case cOpcValid == "000339"
			cString := STR0339 //"O envio do desligamento do trabalhador necessita que a data dos demais eventos seja inferior a data do desligamento"
		Case cOpcValid == "000340"
			cString := STR0340 //"Deve existir evento de "início" de trabalhador sem vínculo informado em data igual ou anterior a data do evento"
		Case cOpcValid == "000341"
			cString := STR0341 //"A CAT de origem deve ser diferente da CAT que esta sendo cadastrada"
		Case cOpcValid == "000342"
			cString := STR0342 //"A descrição do tipo de jornada somente deve ser preenchida se o tipo da jornada for igual a '99 - Outros'."
		Case cOpcValid == "000343"
			cString := STR0343 //"Quando o tipo de jornada for igual a '99 - Outros' é necessário preencher o campo de descrição do tipo de jornada."
		Case cOpcValid == "000344"
			cString := STR0344 //"O preenchimento do campo é exclusivo para empregador PJ."
		Case cOpcValid == "000345"
			cString := STR0345 //"Não existe evento de informações cadastrais do empregador vigente para a data do evento, verifique o cadastro de complemento de empresa."
		Case cOpcValid == "000346"
			cString := STR0346 //"Não é permitido o envio de evento de aquisição de estabilidade se já houver evento idêntico para o mesmo vínculo com data anterior e sem o respectivo evento indicando o retorno da estabilidade."
		Case cOpcValid == "000347"
			cString := STR0347 //"Para aceitação do evento de término de estabilidade é necessária a existência de evento de início de estabilidade para o mesmo vínculo e com o mesmo motivo em data anterior a data do evento"
		Case cOpcValid == "000348"
			cString := STR0348 //"A data do término da estabilidade deve ser igual ou anterior a data atual."
		Case cOpcValid == "000349"
			cString := STR0349 //"Data da CAT superior a data do afastamento"
		Case cOpcValid == "000350"
			cString := STR0350 //"Não foi encontrado uma CAT ativa para o trabalhador"
		Case cOpcValid == "000351"
			cString := STR0351 //"Trabalhador do afastamento anterior diferente do trabalhador do afastamento atual"
		Case cOpcValid == "000352"
			cString := STR0352 //"Data do afastamento superior a data da alteração do afastamento"
		Case cOpcValid == "000353"
			cString := STR0353 //"Encontrado evento de retorno de afastamento vinculado ao evento e trabalhador"
		Case cOpcValid == "000354"
			cString := STR0354 //"Motivo do afastamento anterior diferente do motivo de afastamento atual"
		Case cOpcValid == "000355"
			cString := STR0355 //"Alteração do motivo de afastamento deve conter os valores 03 ou 14 quando o motivo de afastamento for igual a 01"
		Case cOpcValid == "000356"
			cString := STR0356 //"Alteração do motivo de afastamento deve conter os valores 01 ou 14 quando o motivo de afastamento for igual a 03"
		Case cOpcValid == "000357"
			cString := STR0357 //"Motivo de afastamento diferente 01 ou 03"
		Case cOpcValid == "000358"
			cString := STR0358 //"Este evento não pode ser preenchido por ser exclusivo para empresa enquadrada na classificação fiscal 05 ou 12."
		Case cOpcValid == "000359"
			cString := STR0359 //"Não pode ser inferior ao valor informado em {recBrutaExp12m}"
		Case cOpcValid == "000360"
			cString := STR0360 //"Não pode ser superior ao valor informado em {recBrutaTot12m}"
		Case cOpcValid == "000361"
			cString := STR0361 //"Se preenchido, deve estar entre 1 e 12."
		Case cOpcValid == "000362"
			cString := STR0362 //"Deve corresponder ao resultado da operação: [recBrutaExp12m / (recBrutaTot12m - vlrTribRecBruta)] x 0,1 x 100"	Case cOpcValid == "000363"		cString := STR0363 //Data do afastamento superior a data de retorno do afastamento"
		Case cOpcValid == "000363"
			cString := STR0363 //"Data do afastamento superior a data de retorno do afastamento"
		Case cOpcValid == "000364"
			cString := STR0364 //"Motivo do de retorno de afastamento  do evento não corresponde com o motivo de afastamento ativo do trabalhador trabalhador"
		Case cOpcValid == "000365"
			cString := STR0365 //"Não é possível haver desligamento com motivo igual a 'dispensa sem justa causa', se o trabalhador estiver na condição de estável na data do desligamento."
		Case cOpcValid == "000366"
			cString := STR0366 //"No caso de sucessão de vínculo trabalhista (motivos de desligamento [11,12]), a data de desligamento não deverá ser preenchida."
		Case cOpcValid == "000367"
			cString := STR0367 //"A data do desligamento não pode ser superior à data atual (data do envio do evento) acrescida de 10 dias corridos."
		Case cOpcValid == "000368"
			cString := STR0368 //"Informar ZERO se {indSubstPatr} = 1. Caso contrário, preencher com o percentual correspondente."
		Case cOpcValid == "000369"
			cString := STR0369 //"A exclusão de evento deve ser rejeitada em caso de desligamento cujo motivo seja igual a [11,12], e já exista evento de admissão por sucessão para o mesmo trabalhador na empresa indicada no campo CNPJ Sucessora."
		Case cOpcValid == "000370"
			cString := STR0370 //"Para aceitação do evento de término de condição diferenciada de trabalho é necessária a existência de evento de INÍCIO para o mesmo vínculo e com o mesmo {tpCondicao} em data anterior a data do evento, e para o qual ainda não conste o respectivo evento de TÉRMINO. Além disso, se {tpCondicao} igual a [03], o {codAgente} informado no evento de término também deve ser igual ao {codAgente} indicado no evento de início."
		Case cOpcValid == "000371"
			cString := STR0371 //"Deve corresponder a 5% do valor bruto.
		Case cOpcValid == "000372"
			cString := STR0372 //"No caso de folha de pagamento relativa ao 13º Salário, o valor deve ser informado como zero."
		Case cOpcValid == "000373"
			cString := STR0373 //"Campo 'Total Ano' não pode ser inferior ao valor informado no campo 'Total Mês'."
		Case cOpcValid == "000374"
			cString := STR0374 //"Campo 'Sem Sub Ano' não pode ser inferior ao valor informado no campo 'Sem Sub Mes' "
		Case cOpcValid == "000375"
			cString := STR0375 //"Deve corresponder ao resultado da divisão entre a 'Sem Sub Mes' e 'Total Mês'."
		Case cOpcValid == "000376"
			cString := STR0376  //"Deve corresponder ao resultado da divisão entre a 'Sem Sub Ano' e 'Total Ano' ."
		Case cOpcValid == "000377"
			cString := STR0377 //"A data de admissão informada no evento de cadastro inicial do vínculo deve ser anterior a data de início da e-Social."
		Case cOpcValid == "000378"
			cString := STR0378 //"O evento de admissão de trabalhador cedido ({tpAdmissao} = [4]) deve atender as seguintes regras:"
			cString += Chr(13) + Chr(10) + STR0379 //"1) somente pode ser enviado por empregador cuja natureza juridica informada no evento de informações do empregador seja relativa a administração pública (natureza juridica iniciada por [1])"
			cString += Chr(13) + Chr(10) + STR0380 //"2) A informação da origem do trabalhador cedido, prestada no evento de admissão por cessão (tipo de admissão igual a 4), deverá ser validada no RET se a dtAdmissaoCedente for igual ou superior a data de início de vigência da e-Social (deve existir o vínculo do trabalhador na empresa cedente - cnpjCedente + cpf + matriculacedente + dtAdmissaoCedente)."
			cString += Chr(13) + Chr(10) + STR0381 //"3) No caso anterior, deve existir também o respectivo afastamento pelo motivo de 'Cessão' em data igual ou anterior a data de admissão na empresa cessionária"
		Case cOpcValid == "000382"
			cString := STR0382 //"A data de admissão informada no evento de admissão deve ser igual ou posterior a data de início da e- Social"
		Case cOpcValid == "000383"
			cString := STR0383 //"Não é possível excluir o vínculo, pois existem um ou mais eventos para esse mesmo vínculo."
		Case cOpcValid == "000384"
			cString := STR0384  //"A data deve ser anterior ou igual ao período de apuração ao qual se refere o arquivo."
		Case cOpcValid == "000385"
			cString := STR0385  //"O trabalhador identificado pelo cpf informado em 'Nr.Insc. Ben' deve existir no RET."
		Case cOpcValid == "000386"
			cString := STR0386 //"Para Segurado Empregado o estabelecimento/lotação da remuneração deve ser igual ao informado nos dados do funcionário"
		Case cOpcValid == "000387"
			cString := STR0387  //"A 'Data de Pgto' deve estar compreendida no período de apuração ao qual se refere o arquivo."
		Case cOpcValid == "000388"
			cString := STR0388  //"Campo pode ser igual a [Sim] apenas se 'Cod.Rend.' = [0561, 0588, 3208, 3223, 3533, 3540, 3556, 3579, 3277, 5204, 5936, 9385, 1895, 5928]"
		Case cOpcValid == "000389"
			cString := STR0389  //"Campo pode ser igual a [Sim] apenas se 'Cod.Rend.' = [0561,0588,3533,3540,5565,5936,1895]"
		Case cOpcValid == "000390"
			cString := STR0390  //" 'Per. Ref.' deve ser igual a [S] se 'Ind. Dec Ter' = [N] e deve ser igual a [N] se  'Ind. Dec Ter' = [S]."
		Case cOpcValid == "000391"
			cString := STR0391  //"Formato período incorreto. Deve estar no formato MMAAAA se 'Per. Ref.' = [1], ou no formato AAAA se 'Per. Ref.' = [2]"
		Case cOpcValid == "000392"
			cString := STR0392  //"Soma dos  'Vlr Rend.' dos itens de detalhamento de competencia divergem do valor informado no campo 'Vlr Rend Tri' referente ao Pgto do Benf."
		Case cOpcValid == "000393"
			cString := STR0393  //"O tipo [08] somente pode ser utilizado se 'Cod.Rend.' for igual a [0561,1889,5936,1895,5928,5936]"
		Case cOpcValid == "000394"
			cString := STR0394  //"O tipo [11] somente pode ser utilizado se 'Cod.Rend.' for igual a [3540, 3556, 3579]"
		Case cOpcValid == "000395"
			cString := STR0395  //"O 'Id. Tp Isen.' escolhido somente pode ser utilizado se 'Cod.Rend.' for igual a [0473, 0561]"
		Case cOpcValid == "000396"
			cString := STR0396  //""O 'Id. Tp Isen.' escolhido somente pode ser utilizado se 'Cod.Rend.' for igual a [0561, 0588, 3533]"
		Case cOpcValid == "000397"
			cString := STR0397  //"Somente pode ser utilizado por empresa hablitada ao gozo de benefícios fiscais referentes à realização da Copa Conf. 2013 e Copa Mundo 2014."
		Case cOpcValid == "000398"
			cString := STR0398  //"O 'Id. Tp Isen.' somente pode ser utilizado se 'Cod.Rend.' for igual a [0561, 0588]"
		Case cOpcValid == "000399"
			cString := STR0399  //"O campo 'Vlr Ano Cal.' deverá ser preenchido apenas se o 'Cod.Rend.' for igual a [0561,0588,3208,3277,5204,5936,9385]"
		Case cOpcValid == "000400"
			cString := STR0400  //" 'Vlr Ano Ant.' devera ser preenchido apenas se o 'Cod.Rend.' for igual a [0561,0588,3208,3277,5204,5936,9385]"
		Case cOpcValid == "000401"
			cString := STR0401  //"O campo Forma FAP somente pode ser igual a [2] se houver informação sobre a existência de processo judicial relativo ao FAP nas informações do empregador."
		Case cOpcValid == "000402"
			cString := STR0402  //"A data de admissão deve ser posterior à data de nascimento do trabalhador."
		Case cOpcValid == "000403"
			cString := STR0403  //"A data de início do vínculo trabalhista deve ser anterior à data de admissão do trabalhador."
		Case cOpcValid == "000404"
			cString := STR0404  //"A data de admissão do trabalhador no empregador de origem (Cedente) deve ser uma data anterior à data de admissão do trabalhador."
		Case cOpcValid == "000420"
			cString := STR0420  //"O valor informado no campo deve corresponder a soma do {vlrAdvogado} informado nos registros vinculados"
		Case cOpcValid == "000421"
			cString := STR0421  //"A data de retorno deve ser igual ou anterior a data atual."
		Case cOpcValid == "000422"
			cString := STR0422  //"É necessário que exista um aviso prévio ativo e transmitido."
		Case cOpcValid == "000423"
			cString := STR0423  //"Protocolo não encontrado. Para excluir um evento, é necessário que o protocolo encontre-se na base de dados."
		Case cOpcValid == "000424"
			cString := STR0424  //"Trabalhador informado difere do trabalhador referente ao evento que está sendo excluído."
		Case cOpcValid == "000425"
			cString := STR0425  //"Existem um ou mais afastamentos sem seu(s) respectivo(s) retorno(s). Não é possível transmitir outro afastamento sem que o trabalhador esteja em atividade."
		Case cOpcValid == "000426"
			cString := STR0426 //"A consulta padrão deste campo possui o Status inválido, deve ser igual a 0, 2, 3 ou 4"
		Case cOpcValid == "000427"
			cString := STR0427 //"A Consulta padrão deste campo possui a data de vigência expirada"
		Case cOpcValid == "000428"
			cString := STR0428 //Para trabalhador admitido a partir De 04/10/1988, o campo deve ser preenchido como "Optante"
		Case cOpcValid == "000429"
			cString := STR0429 //"A data de opção deve ser sempre igual ou posterior a data de admissão."
		Case cOpcValid == "000430"
			cString := STR0430 //"Quando a data de admissão for posterior a 04/10/1988, a data de opção do FGTS deve ser igual à data de admissão."
		Case cOpcValid == "000431"
			cString := STR0431 //A data do afastamento deve ser maior do que a data de início do eSocial.
		Case cOpcValid == "000432"
			cString := STR0432 //O valor do campo difere do formato esperado.
		Case cOpcValid == "000433"
			cString := STR0433 //O inicio da estabilidade referente a este término está pendente de transmissão do Fisco
		Case cOpcValid == "000434"
			cString := STR0434 //Não está refletindo a real situação do evento para o período solicitado
		Case cOpcValid == "000435"
			cString := STR0435 //A data de término da monitoração biológica deve ser superior a data de início da monitoração.
		Case cOpcValid == "000436"
			cString := STR0436 //A data de início da monitoração biológica deve ser superior a data de admissão do funcionário.
		Case cOpcValid == "000437"
			cString := STR0437 //Se a classificação Tributária for igual a [06,07] o campo deverá permitir apenas [0,2].
		Case cOpcValid == "000438"
			cString := STR0438 //Somente pode ser diferente de ZERO se a classicação tributária for igual a [05, 06, 07, 99].
		Case cOpcValid == "000439"
			cString := STR0439 //"O valor do campo deve corresponder ao resultado da multiplicação dos campos Alíquota RAT e FAP."
		Case cOpcValid == "000440"
			cString := STR0440 //"Somente um documento pode ser informado, CPF ou CNPJ"
		Case cOpcValid == "000441"
			cString := STR0441 //"A data Término do contrato não pode ser inferior a data de admissão."
		Case cOpcValid == "000442"
			cString := STR0442 //O valor informado não corresponde a um mês válido.
		Case cOpcValid == "000501"
			cString := STR0501  //"O valor informado não existe na tabela 'Cadastro de Unidade de Medida(C1J)' "
		Case cOpcValid == "000502"
			cString := STR0502  //"O valor informado no campo não existe na Tabela “Gênero do Item de Mercadoria/Serviço"
		Case cOpcValid == "000503"
			cString := STR0503  //"O valor informado no campo não existe na Tabela “ANP"
		Case cOpcValid == "000504"
			cString := STR0504  //"Se não for informado valor no campo 'Num. DA' obrigatoriamente, o campo 'Aut Bancaria' deve ser informado"
		Case cOpcValid == "000505"
			cString := STR0505  //"O Valor do campo 'Vlr. Acum Tot.' deve ser a Soma do 'Vlr. Operação' "
		Case cOpcValid == "000506"
			cString := STR0506  //"O valor informado no campo 'Valor Total' deve ser igual à soma do campo 'Valor Item' dos registros"
		Case cOpcValid == "000507"
			cString := STR0507  //"O campo Vlr.Grd.TFin deve ser maior ou igual ao campo Vlr. Bruto, exceto se houver reinício de operação."
		Case cOpcValid == "000508"
			cString := STR0508  //"Valor do 'Sld Devedor' deve igual a 'Zero', quando o saldo credor corresponder a um valor negativo"
		Case cOpcValid == "000509"
			cString := STR0509  //"Valor do 'Sld Credor' deve corresponder ao valor absoluto da expressão: (('Val Deb.' + 'Outros Debitos') - ('Crd Anterior' + 'Val Crédito' + 'Outros Créditos'))"
		Case cOpcValid == "000510"
			cString := STR0510  //"Valor do campo deve corresponder a soma dos créditos no campo 'Val. IPI' "
		Case cOpcValid == "000511"
			cString := STR0511  //"Valor do campo deve corresponder a soma dos débitos no campo 'Val. IPI' "
		Case cOpcValid == "000512"
			cString := STR0512  //"Valor do campo deve corresponder a soma dos créditos no campo 'Val. Ajuste' dos registros de Ajuste de Apuração."
		Case cOpcValid == "000513"
			cString := STR0513  //"Valor do campo deve corresponder a soma dos debitos no campo 'Val. Ajuste' dos registros de Ajuste de Apuração."
		Case cOpcValid == "000514"
			cString := STR0514  //"Valor do campo deve corresponder ao valor da expressão ('Vl.Tot.Ctr'  + 'Vlr.Aj.Ac' - 'Vlr.Aj.Rd' – 'Vl.Ctr.Df' + 'VCtr.PAnt')"
		Case cOpcValid == "000515"
			cString := STR0515  //"Não pode ser informado dois ou mais registros com a mesma combinação de valores dos campos COD_MOD, ECF_MOD e ECF_FAB."
		Case cOpcValid == "000516"
			cString := STR0516  //"O campo possui caracteres especiais"
		Case cOpcValid == "000517"
			cString := STR0517  //"Inscrição Estadual Inválida"
		Case cOpcValid == "000518"
			cString := STR0518  //"O valor informado no campo deve estar entre o período inicial da validade e o período final da validade do complemento de empresa"
		Case cOpcValid == "000519"
			cString := STR0519  //"O valor dos campos Cod Unidade e Descr UM. não podem possuir o mesmo conteúdo."
		Case cOpcValid == "000520"
			cString := STR0520  //"O valor informado no campo deve ser maior que 0 (zero)"
		Case cOpcValid == "000521"
			cString := STR0521  //"O valor informado no campo unidade de conversão deve existir no campo unidade de medida"
		Case cOpcValid == "000522"
			cString := STR0522  //"O valor informado neste campo deve ser igual ao somatório do campo Tot.Cr.Util"
		Case cOpcValid == "000523"
			cString := STR0523  //"O valor desse campo deve ser igual à soma dos valores dos campos Sld.Crd.Fisc, Tot.Crd.Apr. e Tot.Crd.Rec. diminuido do valor do campo Tot.Crd.Uti."
		Case cOpcValid == "000524"
			cString := STR0524  //"O valor do PIS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do PIS."
		Case cOpcValid == "000525"
			cString := STR0525  //"O valor do COFINS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do COFINS."
		Case cOpcValid == "000526"
			cString := STR0526  //"A base de PIS deve corresponder à subtração de 'Vlr. Enc. Depr.' menos 'Par. Vlr. Enc.'."
		Case cOpcValid == "000527"
			cString := STR0527  //"A base de COFINS deve corresponder à subtração de 'Vlr. Enc. Depr.' menos 'Par. Vlr. Enc.'."
		Case cOpcValid == "000528"
			cString := STR0528  //"A base de PIS deve corresponder à subtração de 'Vlr. Aq. Bem.' menos 'Par. Vlr. Aqs.'."
		Case cOpcValid == "000529"
			cString := STR0529  //"A base de COFINS deve corresponder à subtração de 'Vlr. Aq. Bem.' menos 'Par. Vlr. Aqs.'."
		Case cOpcValid == "000530"
			cString := STR0530  //"A base de Cálculo do Estoque deve corresponder à subtração de 'Vl. Tot. Est.' menos 'Vl. Est. Imp.'."
		Case cOpcValid == "000531"
			cString := STR0531  //"A base de Cálculo Mensal deve corresponder a 1/12 avos de 'Vl. Base Est.'."
		Case cOpcValid == "000532"
			cString := STR0532  //"O valor informado deve ser menor ou igual ao valor informado no campo 'V. Tot. Saidas'."
		Case cOpcValid == "000533"
			cString := STR0533  //"O índice deve corresponder ao resultado da divisão do campo 'Vl. Trib. Exp.' pelo campo 'V. Tot. Saidas'."
		Case cOpcValid == "000534"
			cString := STR0534  //"O valor deve corresponder à multiplicação do campo 'Som. Par. ICMS' pelo índice calculado no campo 'Par. S. Trb. Exp.'"
		Case cOpcValid == "000535"
			cString := STR0535  //"O índice deve corresponder ao resultado da divisão do campo 'Vl. Sd. Trb. Exp.' pelo campo 'Vl. Said. Trib.'."
		Case cOpcValid == "000536"
			cString := STR0536  //"O valor deve ser menor ou igual ao resultado da multiplicação do campo 'Vlr. Parc. Icm' pelo índice 'Ind. Part. Val'."
		Case cOpcValid == "000537"
			cString := STR0537  //"O valor deve corresponder ao somatório de todos os valores informados no campo 'Vl. Par. Apr.' (C4S_VLPRPS)."
		Case cOpcValid == "000538"
			cString := STR0538  //"O valor deve corresponder ao somatório de todos os valores informados no campo 'Vlr. Out. Crd.' (C4T_VLOTCR)."
		Case cOpcValid == "000539"
			cString := STR0539  //"O valor deve corresponder à subtração de 'Contrib. Apur.' menos 'Crd. Descont.'."
		Case cOpcValid == "000540"
			cString := STR0540  //"O valor deve corresponder ao campo 'Vl. Tot. Bc.' multiplicado pela alíquota do PIS."
		Case cOpcValid == "000541"
			cString := STR0541  //"O valor deve corresponder à soma dos campos 'Vlr. Crd. Apur.' e 'Vlr. Crd. Ext.'."
		Case cOpcValid == "000542"
			cString := STR0542  //"O valor deve corresponder à subtração do campo 'Vl. Cred. Apur.' menos os campos 'Vlr. Crd. Des. Ant.', 'Vl. Crd. Res. Ant.' e 'Vl. Crd. Comp. Ant.'."
		Case cOpcValid == "000543"
			cString := STR0543  //"O valor deve corresponder à subtração do campo 'Sld. Crd. Disp.' menos os campos 'Vlr. Crd. Des. Atu.', 'Vl. Crd. Res. Atu.', 'Vl. Crd. Comp. Atu.', 'Vlr. Out. Crd.'."
		Case cOpcValid == "000544"
			cString := STR0544  //"O valor deve corresponder ao somatório de todos os valores informados no campo 'Vlr. Pis/Cof.' (C6P_VLRPC)."
		Case cOpcValid == "000545"
			cString := STR0545  //"O campo 'Reg. Export.' deve ser preenchido se o campo 'Tp Documento' for '0' (zero)."
		Case cOpcValid == "000546"
			cString := STR0546  //"O campo 'Dt. Reg. Exp.' deve ser preenchido se o campo 'Tp Documento' for '0' (zero)."
		Case cOpcValid == "000547"
			cString := STR0547  //"O campo 'Chave da NFE' deve ser preenchido se o 'Modelo da Nota Fiscal' for '55 - Nota Fiscal Eletrônica'."
		Case cOpcValid == "000548"
			cString := STR0548  //"O valor deve corresponder à soma dos campos 'Estq. Aberto' e 'Vol. Recebido'."
		Case cOpcValid == "000549"
			cString := STR0549  //"O valor deve corresponder à soma dos campos 'Vol. Disponiv' e 'Vol. Saida'."
		Case cOpcValid == "000550"
			cString := STR0550  //"O valor deve corresponder à subtração do campo 'Val. Fechamen.' menos os campos 'Val. Abertura' e 'Val. Aferição.'."
		Case cOpcValid == "000551"
			cString := STR0551  //"O valor deve corresponder à soma dos campos 'Rec. Recebida' e 'Rec. Financ.'."
		Case cOpcValid == "000552"
			cString := STR0552  //"O valor deve corresponder à subtração de 'Rec. Bruta' menos 'Val. Exclu.'."
		Case cOpcValid == "000553"
			cString := STR0553  //"Se a soma dos campos 'Val. Debitos' e 'Out. Debitos' menos a soma dos campos 'Crd. Anterior', 'Val. Creditos' e 'Out. Creditos' for menor que '0' (zero), então o campo 'Sld. Credor' deve ser igual ao valor absoluto da expressão, e o valor do campo 'Sld. Devedor' deve ser igual a '0' (zero). Entretanto, se a soma for maior ou igual a '0' (zero), então o campo 'Sld. Devedor' deve ser igual ao resultado da expressão, e o valor do campo 'Sld. Credor' deve ser igual a '0' (zero)."
		Case cOpcValid == "000554"
			cString := STR0554  //"Informar o mês/ano (formato MMAAAA)"
		Case cOpcValid == "000555"
			cString := STR0555  //"O valor deve corresponder à soma dos campos 'Valor BCC' e 'Parcela BCC'."
		Case cOpcValid == "000556"
			cString := STR0556  //"O valor deve corresponder ao campo 'Vl. Tot. Ctr.' mais 'Vlr. Aj. Ac.' menos 'Vlr. Aj. Rd.' mais 'V. Ctr. P. Ant.'."
		Case cOpcValid == "000557"
			cString := STR0557  //"O valor deve corresponder à subtração do campo 'Vlr. Bs. Cal.' menos 'Vlr. Exc. Es.' menos 'Vlr. Exc. Bc.'."
		Case cOpcValid == "000558"
			cString := STR0558  //"O valor deve corresponder à soma dos campos 'Sld. Crd. Fisc.', 'Tot. Crd. Apr.' e 'Tot. Crd. Rec.' menos o campo 'Tot. Crd. Uti.'."
		Case cOpcValid == "000559"
			cString := STR0559  //"O campo só pode ser preenchido quando o campo 'Vl. Cont. Ext. Pa.' for maior que 0 (zero)."
		Case cOpcValid == "000560"
			cString := STR0560  //"O valor deve corresponder ao somatório do campo 'Vlr. Crd. Des.' (C5L_VLCRED)."
		Case cOpcValid == "000561"
			cString := STR0561  //"O valor deve corresponder à soma dos campos 'Vl. Carga' e 'Vl. Pass.'."
		Case cOpcValid == "000562"
			cString := STR0562  //"O valor deve corresponder à divisão do campo 'Vl. Carga' por 'Vl. Fat.'."
		Case cOpcValid == "000563"
			cString := STR0563  //"O valor deve corresponder à multiplicação do campo 'Ind. Rateio' por 'Vl. Crd. ICMS'."
		Case cOpcValid == "000564"
			cString := STR0564  //"O valor deve corresponder à multiplicação do campo 'Ind. Rateio' por 'Vl. Base ICMS'."
		Case cOpcValid == "000565"
			cString := STR0565  //"O intervalo de valor inicial e final está incorreto."
		Case cOpcValid == "000566"
			cString := STR0566  //"O intervalo de data inicial e final está incorreto."
		Case cOpcValid == "000573"
			cString := STR0573 //"O valor deve corresponder à soma dos campos 'Vlr Merc', 'Vlr Serviços', 'Vlr Frete', 'Vlr Seguro', 'Vlr Desp' e 'Vlr Out.Desp' subtraindo os campos 'Vlr Desc' e 'Vlr Abat NT'."
		Case cOpcValid == "000574"
			cString := STR0574 //"O valor deve corresponder ao percentual de 'Alq ICMS' aplicado em 'Bs ICMS'."
		Case cOpcValid == "000575"
			cString := STR0575 //"O Código da Classe de Consumo informado somente é válido para documentos fiscais com modelo de emissão 06, 28 ou 29. Caso contrário, deixar em branco."
		Case cOpcValid == "000576"
			cString := STR0576 //"O Código de Situação Tributária (CST) somente é necessária para os tributos ICMS, IPI, ISS, PIS/Pasep e/ou Cofins. Se não for o caso, deixá-lo em branco."
		Case cOpcValid == "000577"
			cString := STR0577 //"CFOP incorreto ao tipo de documento(Deve ser 123 para Entrada ou 567 para Saida)."
		Case cOpcValid == "000578"
			cString := STR0578 //"Data inicial deve ser menor que Data final."
		Case cOpcValid == "000579"
			cString := STR0579 //"Período fiscal divergente de data inicial ou final."
		Case cOpcValid == "000580"
			cString := STR0580 //"O valor deve corresponder à subtração do campo 'Vlr. Item' menos 'Vlr. Desc.'."
		Case cOpcValid == "000581"
			cString := STR0581 //"O código do CFOP informado deve inciar por 1,2 ou 3 quando se tratar de Documentos Fiscais Recebidos (Entrada) ou 5,6 e 7 quando se tratar de Documentos Fiscais Emitidos (Saída)."
		Case cOpcValid == "000582"
			cString := STR0582 //"A Modalidade de determinação da Base de Calculo somente é necessária para o ICMS. Se não for o caso, deixar em branco."
		Case cOpcValid == "000583"
			cString := STR0583 //"Se a identificação do tipo de mercadoria for 'componente'('Cod.Ident' igual a '2'), este campo deve obrigatoriamente estar preenchido com o código do bem principal."
		Case cOpcValid == "000584"
			cString := STR0584 //"O conteúdo deste campo deve se referir a outro registro não cadastrado com identificação do tipo de mercadoria 'componente'('Cod.Ident' igual a '2')."
		Case cOpcValid == "000585"
			cString := STR0585 //"O conteúdo informado deve ser conta do ativo ('Cod.Nat' igual a '01') do cadastro de Plano de Contas Contábeis."
		Case cOpcValid == "000586"
			cString := STR0586 //  "O ano informado não pode ser maior do que 2049"
		Case cOpcValid == "000587"
			cString := STR0587 //  "O campo CPF deve ser vazio para o tipo de pessoa jurídica"
		Case cOpcValid == "000588"
			cString := STR0588 // "O campo CNPJ deve ser vazio para o tipo de pessoa física"
		Case cOpcValid == "000589"
			cString := STR0589 //"O valor da contribuição apurada deve ser igual a soma dos valores do campo Vlr. PC"
		Case cOpcValid == "000590"
			cString := STR0590 //"Campo sem conteúdo / Vazio"
		Case cOpcValid == "000591"
			cString := STR0591 // "Favor validar o registro no cadastro - "
		Case cOpcValid == "000592"
			cString := STR0592 // "A consulta padrão deste campo possui um registro não validado."
		Case cOpcValid == "000593"
			cString := STR0593 //"Para a validação da alíquota de 4% ou de 3%, deve a pessoa jurídica informar o CST '01 – Operação Tributável com Alíquota Básica', no campo 'Cst Pis/Cof ' "
		Case cOpcValid == "000594"
			cString := STR0594 //"Campo 'Num. Item' deve iniciar com '1' e incrementada de '1' "
		Case cOpcValid == "000595"
			cString := STR0595 // "Formato de e-mail não é válido"
		Case cOpcValid == "000596"
			cString := STR0596 // "Para 'Cod. Qualif' '900' o 'Tipo Estab.' deve ser igual a '1' e possuir um CPF válido"
		Case cOpcValid == "000597"
			cString := STR0597 // "O código atribuído não pode conter a expressão 'eSocial' nas 7 (sete) primeiras posições."
		Case cOpcValid == "000598"
			cString := STR0598 // "Valor 'Ini. Interv.' deve ser maior ou igual a '00:00', menor ou igual a '23:59' e a segunda parte dos números que indica os minutos deve ser menor ou igual a '59'. "
		Case cOpcValid == "000599"
			cString := STR0599 // "Valor 'Fim. Interv.' deve ser maior ou igual a '00:00', menor ou igual a '23:59' e a segunda parte dos números que indica os minutos deve ser menor ou igual a '59'. "
		Case cOpcValid == "000600"
			cString := STR0600 // "O campo não deve ser preenchido se Id.TpLotacao for igual a 01, 10, 21, 24, 90, 91."
		Case cOpcValid == "000601"
			cString := STR0601 // "O Tipo Contrato for igual a '2' e a Categ. Trabalhador igual a '102' a Data Term. do contrato não deve ser superior a 60 dias em relação a Data. Admissão."
		Case cOpcValid == "000602"
			cString := STR0602 // "Em arquivo gerado por empregador PF, não pode ser igual ao CPF do empregdor."
		Case cOpcValid == "000603"
			cString := STR0603 // "Os códigos [18,19,20,21,22,23,24,25] de motivo de desligamento só podem ser utilizados para desligamento de trabalhador pertencente à categoria de servidor público (301 a 306)."
		Case cOpcValid == "000604"
			cString := STR0604 // "Deve ser uma data posterior a data de admissão do trabalhador e não pode ser superior à data atual."
		Case cOpcValid == "000605"
			cString := STR0605 // "Deve ser preenchido se {tpReint} for igual a [2]. Neste caso, deve ser um dos valores válidos para o campo, conforme lista."
		Case cOpcValid == "000606"
			cString := STR0606 // "Deve ser uma data válida, igual ou posterior a data de desligamento do trabalhador."
		Case cOpcValid == "000607"
			cString := STR0607 // "Se o motivo de desligamento for por morte deve ser preenchido o campo de atestado de obito. "
		Case cOpcValid == "000608"
			cString := STR0608 // "Se o motivo de desligamento for por decisão judicial deve ser preenchido o campo de número de processo trabalhista."
			Case cOpcValid == "000609"
			cString := STR0609 // "Os arquivos de folha de pagamento porventura enviados para períodos iguais ou posteriores a Data Efeito serão marcados como inconsistentes, devendo ser objeto de retificação pela empresa. Verificar o Periodo de Apuraçao da Folha de Pagamento, que deve ser anterior a Data de Efeito."
		Case cOpcValid == "000610"
			cString := STR0610 // "Se o campo Ind. Pagto Juizo for igual a Sim (1), a situação em que não há o envio de evento de remuneração para o período compreendido entre a data do desligamento e a data de retorno. Verificar o Periodo Apuração da Folha de Pagamento, que deve ser anterior a Data de Desligamento."
		Case cOpcValid == "000611"
			cString := STR0611 // "Deve ser um CNPJ diferente do CNPJ da base do empregador."
		Case cOpcValid == "000612"
			cString := STR0612 // "Deve ser um CNPJ diferente dos estabelecimentos informados no cadastro da tabela de estabelecimentos."
		Case cOpcValid == "000614"
			cString := STR0614 // "Para Tipos de Admissão igual a 2,3 ou 4 é obrigatório o preenchimento dos campos CNPJ Emp Ant, Matr Ant e Dt. Ini. Vinc."
		Case cOpcValid == "000615"
			cString := STR0615 // "Tipos de Provimentos 3,4 e 5 são permitidos apenas para natureza juridica do declarante (Evento S-1000 - {natJurid}) igual a [101-5, 104-0, 107-4, 116-3]"
		Case cOpcValid == "000616"
			cString := STR0616 // "Data de Nomeação deve ser posterior a data de nascimento do trabalhador"
		Case cOpcValid == "000617"
			cString := STR0617 // "Data da Posse do servidor deve ser igual ou posterior a Data de Nomeação do servidor"
		Case cOpcValid == "000618"
			cString := STR0618 //"Data Entr. Exercício deve ser igual ou superior a Data da Posse"
		Case cOpcValid == "000619"
			cString := STR0619 //"Deve ser igual ou posterior à data de admissão."
		Case cOpcValid == "000620"
			cString := STR0620 //"Para trabalhador com informações do Local de Trabalho Domestico, não deve ser preenchido os campos refente ao Local de Trabalho (Tp. Inscrição, Nr. Inscrição,Desc. Compl.) "
		Case cOpcValid == "000621"
			cString := STR0621 //"Se o Tipo Inscrição for um CNPJ ou CNO, deve constar na tabela S- 1005. Se for um CAEPF, deve constar na tabela S-1020 - Lotações Tributárias"
		Case cOpcValid == "000624"
			cString := STR0624 // "O (Cd.Inc.Tr.IR) da tabela de rubricas só pode indicar (23, 24, 61) se o trabalhador tiver como (codCategoria) de (301 a 306) e (Tp Reg Prev) do vínculo seja igual (2)."
		Case cOpcValid == "000625"
			cString := STR0625 // "É necessario que este campo seja preenchido."
		Case cOpcValid == "000626"
			cString := STR0626 // "Deve ser uma data posterior a data de término do contrato."
		Case cOpcValid == "000627"
			cString := STR0627 //"O preenchimento do campo é obrigatório se o país do nascimento for igual a Brasil."
		Case cOpcValid == "000628"
			cString := STR0628 //"A data deve ser posterior a data de expedição."
		Case cOpcValid == "000632"
			cString := STR0632 //"Se não houver número a ser informado, preencher com "S/N"
		Case cOpcValid == "000639"
			cString := STR0639 //"O Nome não pode começar com espaço."
		Case cOpcValid == "000640"
			cString := STR0640 //"O Nome não pode ter mais de um espaço entre as palavras."
		Case cOpcValid == "000641"
			cString := STR0641 //"A primeira parte do nome deve ter pelo menos dois caracteres."
		Case cOpcValid == "000642"
			cString := STR0642 //"O Nome não pode ter mais de 2 letras isoladas (abreviações) em sequência."
		Case cOpcValid == "000643"
			cString := STR0643 //"A data informada deve ser maior que 01/01/1900 e anterior à data atual"
		Case cOpcValid == "000644"
			cString := STR0644 //"O preenchimento do CPF é obrigatório se o dependente for maior 12 anos"
		Case cOpcValid == "000645"
			cString := STR0645 //"Não pode haver mais de um dependente com o mesmo número do CPF."
		Case cOpcValid == "000646"
			cString := STR0646 //"O CPF é inválido."
		Case cOpcValid == "000647"
			cString := STR0647 //"O Email é inválido."
		Case cOpcValid == "000648"
			cString := STR0648 //"A Matricula informada não pode iniciar com 'eSocial'"
		Case cOpcValid == "000649"
			cString := STR0649 //"Se Tp. Admissão for igual a (2,3,4) é obrigatório o preenchimento do registro de Sucessão de Vínculo Trabalhista."
		Case cOpcValid == "000650"
			cString := STR0650 //"Deve ser um mês maior ou igual a 01 e menor ou igual a 12."
		Case cOpcValid == "000651"
			cString := STR0651 //"O CNPJ é inválido."
		Case cOpcValid == "000652"
			cString := STR0652 //"Para trabalhador admitido a partir de 04/10/1988, o campo deve ser preenchido com (1-Optante)."
		Case cOpcValid == "000653"
			cString := STR0653 //"Preenchimento obrigatório em caso de trabalhador '1-Optante' pelo FGTS."
		Case cOpcValid == "000654"
			cString := STR0654 //"O preenchimento do campo é obrigatório se o Mtv Contr for igual a (1)."
		Case cOpcValid == "000655"
			cString := STR0655	//"Se Und Sal Fixo for igual a (7), o campo deve ser preenchido com 0."
		Case cOpcValid == "000656"
			cString := STR0656  //"Deve ser uma data posterior a data de admissão."
		Case cOpcValid == "000657"
			cString := STR0657	//"Este campo deve ser preenchido se tpJornada = 2."
		Case cOpcValid == "000658"
			cString := STR0658	//"Se um desses campos 'Iden.Min/Lei', 'Nr Certif.', 'Dt.Emis.Cert' ou 'Dt.Venc.Cert' for preenchido, todos os mesmos tornam-se obrigatórios para geração do XML da session 'dadosIsencao'."
		Case cOpcValid == "000659"
			cString := STR0659	//"A matrícula informada deve se referir a um trabalhador registrado no RET, cujo CPF seja o informado no campo {cpfTrabSubst}."
		Case cOpcValid == "000660"
			cString := STR0660	//"Deve ser um CPF existente no cadastramento inicial do vínculo do trabalhador, que já foi enviado ao RET ou teve seu conteúdo validado."
		Case cOpcValid == "000661"
			cString := STR0661// "Informação obrigatória para trabalhadores das categorias 'empregados' e 'servidores públicos'. Deve corresponder à matrícula informada pelo empregador no evento S-2200 do respectivo vínculo trabalhista."
		Case cOpcValid == "000662"
			cString := STR0662 // "Vigência da Rúbrica inconsistente para este Período de apuração."
		Case cOpcValid == "000663"
			cString := STR0663 // "O Código de Rúbrica informado não existe na Tabela de Rúbricas."
		Case cOpcValid == "000664"
			cString := STR0664 // "O Código de Incidência Tributária para a Previdência Szocial da tabela de Rubricas só pode indicar [23, 24, 61] se o trabalhador tiver Cód. Categoria Cate igual a [301,302,303,304,305,306] e Tipo Regime Previdenciário do vínculo seja igual [2-RPPS]."
		Case cOpcValid == "000665"
			cString := STR0665 // "O valor da rúbrica deve ser maior que 0(Zero)"
		Case cOpcValid == "000666"
			cString := STR0666 // "Informações sobre beneficiários de pensão alimentícia. Só preencher este grupo de informações se houver Cód. Rúbrica, cuja natureza indicada seja igual a [9213]."
		Case cOpcValid == "000667"
			cString := STR0667 // "CPF do beneficiário Inválido."
		Case cOpcValid == "000668"
			cString := STR0668 // "A data da assinatura do acordo Deve ser igual ou anterior ao período de apuração."
		Case cOpcValid == "000669"
			cString := STR0669 // "Se o Tipo de Lotação [C99_TPLOT] da respectiva lotação for igual a [21, 23], o número da inscrição [C9J_NRINSC] deve ser igual a inscrição da lotação tributária [C99_NRINCT] definida em S-1020."
		Case cOpcValid == "000670"
			cString := STR0670 // "O código de Lotação deve ser um código existente em S-1020 - Tabela deLotações Tributárias."
		Case cOpcValid == "000671"
			cString := STR0671 //"Deve corresponder à matrícula informada pelo empregador no evento S-2200 [CUP] do respectivo vínculo trabalhista."
		Case cOpcValid == "000672"
			cString := STR0672 // "Deve ser preenchido apenas no caso de remuneração de trabalhador com vínculo empregatício (empregado, servidor público)."
		Case cOpcValid == "000673"
			cString := STR0673 // "Se Indicativo de Apuração for igual a [1] (Mensal), o evento periódico somente pode ser enviado se o mês/ano do período de apuração for igual ou inferior ao mês/ano corrente."
		Case cOpcValid == "000674"
			cString := STR0674 // "Se Indicativo de Apuração for igual a [2] (Décimo Terceiro), o evento periódico pode ser enviado se ano do período de apuração for igual ou inferior ao ano corrente."
		Case cOpcValid == "000675"
			cString := STR0675 // "O valor informado deve corresponder ao valor informado no Campo (Vlr. Item) menos as exclusões de base de cálculo informadas no Campo (Vl. Excl/Desc)"
		Case cOpcValid == "000676"
			cString := STR0676 // "A data do estoque deve ser igual à data final do período de apuração."
		Case cOpcValid == "000677"
			cString := STR0677 // "Somente podem ser informados nesse campo valores de COD_ITEM cujos tipos sejam iguais a 00, 01, 02, 03, 04, 05, 06 e 10."
		Case cOpcValid == "000678"
			cString := STR0678 // "Se preenchido com valor ‘1’ (posse de terceiros) ou ‘2’ (propriedade de terceiros), o campo COD_PART será obrigatório."
		Case cOpcValid == "000679"
			cString := STR0679 // "A data deve estar compreendida no período informado nos campos DT_INI e DT_FIN do Registro K100."
		Case cOpcValid == "000680"
			cString := STR0680 // "O valor informado deve ser diferente do ID. Item Ori."
		Case cOpcValid == "000681"
			cString := STR0681 // "A data deve estar compreendida dentre o período de apuração do registro K100"
		Case cOpcValid == "000682"
			cString := STR0682 // "O código do item componente/insumo deve ser diferente do código do produto resultante no Registro K230"
		Case cOpcValid == "000683"
			cString := STR0683 // "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 03(Produto em Processo) ou 04(Produto Acabado)."
		Case cOpcValid == "000684"
			cString := STR0684 // "O código do item componente/insumo deve ser diferente do código do produto resultante no Registro K250"
		Case cOpcValid == "000685"
			cString := STR0685 // "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05 e 10."
		Case cOpcValid == "000686"
			cString := STR0686 // "A Unidade de medida do Item de Origem é diferente da unidade de medida do Item de destino, portando deve ser cadastrado um fator de conversão para a unidade de medida do item de Origem."
		Case cOpcValid == "000687"
			cString := STR0687 // "Para o Modelos de Documento Fiscal com o código igual a 55,57 ou 65 o campo de se torna de preenchimento obrigatório com apenas três posições para NF-e"
		Case cOpcValid == "000688"
			cString := STR0688 // "Se não existir Série para NF-e ou NFC-e informar 000."
		Case cOpcValid == "000689"
			cString := STR0689 // "Código do Regime da Empresa Inválido"
		Case cOpcValid == "000690"
			cString := STR0690 // "Tipo de Dedução Inválido."
		Case cOpcValid == "000691"
			cString := STR0691 // "Código do Motivo da Referência Inválido."
		Case cOpcValid == "000692"
			cString := STR0692 // "Se empregador PJ, o campo tipo de inscrição deve ser CNPJ (1)."
		Case cOpcValid == "000693"
			cString := STR0693 // "Se o Local Amb. for proprio do empresador ({localAmb} = [1]), o estabelecimento deve pertencer ao empregador e constar da tabela S-1005."
		Case cOpcValid == "000694"
			cString := STR0694 // "Se o Local Amb. de terceiros ({localAmb} = [2]), a raiz do CNPJ pode ser diferente da constante no S-1000, porém deve constar na Tabela de Lotações Tributárias (S-1020)."
		Case cOpcValid == "000695"
			cString := STR0695 // "Se o campo 'Indicador de Suspensão' for igual a '90', preencher obrigatoriamente o campo 'Indicador Depósito' com '2=Não'."
		Case cOpcValid == "000696"
			cString := STR0696 // "Se empregador PF, o campo tipo de inscrição deve ser CAEPF (3)."
		Case cOpcValid == "000697"
			cString := STR0697	//"Para Tp. Lotacao igual a 2, a aba de Informações Complementares deve ser preenchida"
		Case cOpcValid == "000698"
			cString := STR0698	//Se Unidade de pagamento ({undSalFixo}) for igual a [7], preencher Salário fixo do trabalhador (vrSalFx) com 0 (zero).
		Case cOpcValid == "000699"
			cString := STR0699	//"A data de admissão deve ser posterior à data de nascimento do trabalhador"
		Case cOpcValid == "000700"
			cString := STR0700	//"Campo não deve ser preenchido pela Pessoa Fisica (Tp. Inscrição igual a '3')"
		Case cOpcValid == "000701"
			cString := STR0701	//"Número de inscrição não válido. Faça a validação do registro S-1020 (Tabela de Lotações Tributárias)."
		Case cOpcValid == "000702"
			cString := STR0702	//Só é possível alteração de categoria de trabalhadores nas seguintes opções: de [102, 105, 106] para [101].
		Case cOpcValid == "000703"
			cString := STR0703	//"Se o Tipo de Contrato ({tpContr}) for igual a [2] e a categoria do trabalhador for igual a [102], a Data Termino de Contrato ({dtTerm}) não pode ser superior a 60 (sessenta) dias em relação a data de admissão."
		Case cOpcValid == "000704"
			cString := STR0704	//"O número de inscrição não consta na tabela S-1005(Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos)."
		Case cOpcValid == "000705"
			cString := STR0705	//"Preenchimento obrigatório em caso de trabalhador optante pelo FGTS."
		Case cOpcValid == "000706"
			cString := STR0706	//"Deve ser uma data igual ou posterior à data  de admissão."
		Case cOpcValid == "000707"
			cString := STR0707	//"Se a data de admissão for posterior a 04/10/1988, a data de opção deverá ser igual à data de admissão, exceto para empregado doméstico."
		Case cOpcValid == "000708"
			cString := STR0708	//"Se a data de admissão for anterior a 05/10/1988, a data de opção fica limitada a 05/10/1988."
		Case cOpcValid == "000709"
			cString := STR0709	//"O evento S-2200 só é aceito para as categorias de trabalhadores igual a [101, 102, 103, 104, 105, 106, 107, 108, 301, 302, 303, 306, 309]"
		Case cOpcValid == "000710"
			cString := STR0710	//"O evento S-2300 somente é aceito para as categorias de trabalhadores igual a [201, 202, 305, 401, 410, 701, 711, 721, 722, 723, 731, 734, 738, 741, 751, 761, 771, 781, 901, 902, 903, 904, 905]."
		Case cOpcValid == "000711"
			cString := STR0711	//"A aba de Informações Complementares só deve ser preenchida se o tipo de lotação for igual a 2."
		Case cOpcValid == "000712"
			cString := STR0712	//"Se Tp. Reintegr for diferente de 1 a data de efeito deve ser igual a data de retorno."
		Case cOpcValid == "000713"
			cString := STR0713 //"Deve ser uma data igual ou anterior à data do efetivo retorno ao trabalho e posterior à data do desligamento."
		Case cOpcValid == "000714"
			cString := STR0714 //"Não deve ser aceita a exclusão do evento de afastamento se já houver evento de alteração de motivo ou de retorno respectivo."
		Case cOpcValid == "000715"
			cString := STR0715 //"A matrícula deve informada pelo empregador no evento S-2200 do respectivo vínculo trabalhista. Se o trabalhador não está sujeito a esse evento (S-2200), a matrícula não deve ser informada, porém, o trabalhador deve ter sido registrado como TSVE - Trabalhador Sem Vínculo de Emprego/Estatutário, através do evento S-2300."
		Case cOpcValid == "000716"
			cString := STR0716 //"A data deve ser posterior a data de admissão do vínculo ao qual se refere o evento, e não pode ser superior a data atual."
		Case cOpcValid == "000717"
			cString := STR0717 //É necessário que a data de início do afastamento seja menor que a data de desligamento do trabalhador
		Case cOpcValid == "000718"
			cString := STR0718 //"Deve ser um CNPJ diferente do CNPJ do empregador."
		Case cOpcValid == "000719"
			cString := STR0719 //"Deve ser um CNPJ diferente dos estabelecimentos informados através do evento S-1005(Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos)"
		Case cOpcValid == "000720"
			cString := STR0720 //"Deve ser uma data igual ou posterior a data do afastamento que está sendo alterado e menor que a data de término do afastamento, caso esta já tenha sido informada."
		Case cOpcValid == "000721"
			cString := STR0721 //"Deve ser uma data igual ou posterior a data de início do afastamento do trabalhador."
		Case cOpcValid == "000722"
			cString := STR0722 //"A alteração do motivo de afastamento é permitida desde que evento de afastamento tenha ocorrido pelos motivos (01 para 03), (01 para 06), (02 para 06), (03 para 01), (03 para 06) ou (04 para 06)"
		Case cOpcValid == "000723"
			cString := STR0723 //"O número de telefone com DDD deve conter apenas números e com o mínimo de dez dígitos."
		Case cOpcValid == "000724"
			cString := STR0724	//"Número de inscrição não válido. Faça a validação do registro S-1005 (Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos)."
		Case cOpcValid == "000725"
			cString := STR0725 //"Deve ser um NIS válido e pertencente ao trabalhador"
		Case cOpcValid == "000726"
			cString := STR0726 //"Não existe um registro de desligamento relacionado a este funcionario ou a data de desligamento está vazia ou inválida."
		Case cOpcValid == "000727"
			cString := STR0727 //"Registro não pode ser alterado. Aguardando processo da transmissão."
		Case cOpcValid == "000728"
			cString :=STR0728 //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
		Case cOpcValid == "000729"
			cString := STR0729 //"Os códigos [18,19,20,21,22,23,24,25] só podem ser utilizados para desligamento de trabalhador pertencente à categoria de agente público (301 a 309)."
		Case cOpcValid == "000730"
			cString := STR0730 //"Deve ser uma data posterior ou igual a data de admissão do trabalhador."
		Case cOpcValid == "000731"
			cString := STR0731 //"O {codIncCP} da tabela de rubricas só pode indicar [23, 24, 61] se o trabalhador tiver como {codCateg} igual a [301,302,303,305,306,309] e {tpRegPrev} do vínculo seja igual [2]."
		Case cOpcValid == "000732"
			cString := STR0732 //"Se {classTrib} igual a [21,22], exceto empregador doméstico, o Indice Contribuição Substituída deve ser igual [3,4]."
		Case cOpcValid == "000733"
			cString := STR0733 //"Se empregador doméstico o Indice Contribuição Substituída deve ser igual a [2]."
		Case cOpcValid == "000734"
			cString := STR0734 //"Nos casos de ({classTrib} <> [21,22]) o Indice Contribuição Substituída deveser igual a [1,4]."
		Case cOpcValid == "000735"
			cString := STR0735 //"'Data de Inicio' deve ser maior ou igual a data de admissão do funcionário."
		Case cOpcValid == "000736"
			cString := STR0736 //"A'Data de Alteracao' deve ser igual ou posterior a 'Dt. Inicio'"
		Case cOpcValid == "000737"
			cString := STR0737 //"A 'Data Final' deve ser uma data igual ou posterior a data de início ou, quando também existir evento de alteração da condição, a data deve ser posterior a data de alteração indicada."
		Case cOpcValid == "000738"
			cString := STR0738 //"Para aceitação do evento de alteração ou de término de Condições Ambientais do Trabalho é necessária a existência do respectivo evento de INÍCIO para o mesmo vínculo."
		Case cOpcValid == "000739"
			cString := STR0739 //"Se o 'Tipo de inscrição' for igual a '1-CNPJ', deve ser um número de CNPJ válido, caso o 'Tipo de inscrição' for igual a '2-CPF', deve ser um CPF válido."
		Case cOpcValid == "000740"
			cString := STR0740 //"O código informado deve constar na Tabela de Cargos/Empregos Públicos - S-1030."
		Case cOpcValid == "000741"
			cString := STR0741 //"Número de inscrição não válido. Faça a validação do registro do S-1030 (Tabela de Cargos/Empregos Públicos)."
		Case cOpcValid == "000742"
			cString := STR0742 //"O código informado deve constar na Tabela de Funções/Cargos em Comissão - S-1040."
		Case cOpcValid == "000743"
			cString := STR0743 //"Número de inscrição não válido. Faça a validação do registro do S-1040 (Tabela de Funções/Cargos em Comissão)."
		Case cOpcValid == "000744"
			cString := STR0744 //"O código informado deve existir na Tabela de Categorias de Trabalhadores (tabela 1)."
		Case cOpcValid == "000745"
			cString := STR0745 //"Deve ser informado um CNPJ com raiz diferente do CNPJ do declarante."
		Case cOpcValid == "000746"
			cString := STR0746 //"A data do Atestado de Saúde Ocupacional - ASO Admissional, deve ser posterior a data de nascimento do trabalhador."
		Case cOpcValid == "000747"
			cString := STR0747 //"Número de inscrição não válido. Faça a validação do registro S-1005 (Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos)."
		Case cOpcValid == "000748"
			cString := STR0748 //"Para incluir um novo registro para este trabalhador é necessario que todos os outros registros ativos estejam com a data de termino preenchida."
		Case cOpcValid == "000749"
			cString := STR0749 //"Não é possível realizar alterações em registros já transmitidos."
		Case cOpcValid == "000750"
			cString := STR0750 //"As informações de CPF, Data de Nascimento e Data de Admissão informadas no evento de admissão preliminar (S-2190), devem ser iguais às informações prestadas neste evento (S-2200) - Admissão de Trabalhador."
		Case cOpcValid == "000751"
			cString := STR0751 //"Foi encontrado um registro de evento de admissão preliminar (S-2190) para o mesmo CPF, favor informar o número do recibo do evento S-2190(Admissão de Trabalhador - Registro Preliminar) correspondente ao evento de admissão."
		Case cOpcValid == "000752"
			cString := STR0752 //"O CPF do dependente deve ser diferente do CPF do declarante."
		Case cOpcValid == "000753"
			cString := STR0753 //"Registro não pode ser excluído, pois o evento de exclusão já se encontra na base do RET."
		Case cOpcValid == "000754"
			cString := STR0754 //"Exclusão de Registro"
		Case cOpcValid == "000755"
			cString := STR0755 //"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?"
		Case cOpcValid == "000756"
			cString := STR0756 //"Excluir"
		Case cOpcValid == "000757"
			cString := STR0757 //"Manter"
		Case cOpcValid == "000758"
			cString := STR0758 //"Na admissão de menores de 14 anos, o preechimentos do campo 'Id Proc Jud'(Dados do Alvará Judicial) é obrigatório."
		Case cOpcValid == "000759"
			cString := STR0759 //"Na admissão de menores com a idade entre 14 e 16 anos, com 'Id. Categoria'(Categoria) diferente de 'Aprendiz', o preechimentos do campo 'Id Proc Jud'(Dados do Alvará Judicial) é obrigatório."
		Case cOpcValid == "000760"
			cString := STR0760 //"Registro não pode ser excluído, pois o evento de exclusão já se encontra na base do RET"
		Case cOpcValid == "000761"
			cString := STR0761 //"Não pode ser alterado o número do recibo e o tipo de evento."
		Case cOpcValid == "000762"
			cString := STR0762 //"O motivo de desligamento não deve ser preenchido quando o código da categoria for diferente de 721 ou 771."
		Case cOpcValid == "000763"
			cString := STR0763 //"O Cd.Inc.Tr.Pr (codIncCP) da tabela de rubricas não pode indicar [23, 24, 61]."
		Case cOpcValid == "000764"
			cString := STR0764 //"Não deve ser preenchido a Natureza da Atividade para as categorias diretor não empregado (721 e 722), servidor público indicado a conselho (305), membro de conselho tutelar e estagiário (901)."
		Case cOpcValid == "000765"
			cString := STR0765 //"O CPF do trabalhador indicado no cadastramento inicial do vínculo, não pode ser o mesmo CPF do empregador."
		Case cOpcValid == "000766"
			cString := STR0766 //"O somatório dos valores informados em Valor Pagto(vlrPgto) deve corresponder ao somatório dos valores dos vencimentos ({tpRubr} = [1]) e ({tpRubr} = [2]) deduzidos do somatório dos descontos."
		Case cOpcValid == "000767"
			cString := STR0767 //"O somatório dos valores informados em Valor Pagto(vlrPgto) deve corresponder ao somatório dos valores dos vencimentos ({tpRubr} = [1]) e ({tpRubr} = [2]) deduzidos do somatório dos descontos."
		Case cOpcValid == "000768"
			cString := STR0768 //"Deve ser uma categoria diferente de Dirigente Sindical."
		Case cOpcValid == "000769"
			cString := STR0769 //"Os códigos válidas para preencher a Categoria de Origem do Trabalhador Cedido são: 101, 301, 302 e 306."
		Case cOpcValid == "000770"
			cString := STR0770 //"Deve ser uma data anterior a data de início informada no evento."
		Case cOpcValid == "000771"
			cString := STR0771 //"Deve ser uma data posterior a data de início do estágio."
		Case cOpcValid == "000772"
			cString := STR0772 //"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
		Case cOpcValid == "000773"
			cString := STR0773 //"A data de ocorrência do evento deve ser posterior a data de admissão do funcionário com data de desligamento em branco."
		Case cOpcValid == "000774"
			cString := STR0774 //"As categorias de Avulsom (201 e 202) somente podem ser utilizadas se a classificação tributária do empregador for igual a [09] ou [10]."
		Case cOpcValid == "000775"
			cString := STR0775 //"As categorias de Cooperado (731, 734 e 738) somente podem ser utilizadas se o Indicativo de Cooperativa definido no evento de informações cadastrais do empregador for diferente de zero."
		Case cOpcValid == "000776"
			cString := STR0776 //"A categoria Dirigente Sindical (401) somente pode ser utilizado se a classificação tributária for igual a [10] ou [14]."
		Case cOpcValid == "000777"
			cString := STR0777 //"A categoria Diretor não empregado (721, 722 e 771) e Servidor Público indicado (305) somente podem ser utilizados se {tpInsc} do empregador for igual a [1] (PJ)."
		Case cOpcValid == "000778"
			cString := STR0778 //"A categoria Diretor não empregado (721, 722 e 771) e Servidor Público indicado (305) somente podem ser utilizados se {tpInsc} do empregador for igual a [1] (PJ)."
		Case cOpcValid == "000779"
			cString := STR0779 //"O evento S-1280 - Informações Complementares aos Eventos Periódicos é permitido apenas se {classTrib} = [03,09] ou ({classTrib} = [02,99] e {indDesFolha} = [1])."
		Case cOpcValid == "000780"
			cString := STR0780 //"Informar 0 (zero) se {indSubstPatrOpPort} = 1. Caso contrário, preencher com o percentual correspondente."
		Case cOpcValid == "000781"
			cString := STR0781 //"Preenchido exclusivamente pelo OGMO ({classTrib}=[09]) relativamente a seus Operadores Portuários."
		Case cOpcValid == "000783"
			cString := STR0783 //"Registro não pode ser excluído, pois o evento já se encontra base do RET"
		Case cOpcValid == "000784"
			cString := STR0784 //"Opção de Consulta igual à 2 ou 4,o formato do Período de Solicitação deve ser AAAA-MM (Ano e Mês)."
		Case cOpcValid == "000785"
			cString := STR0785 //"Opção de Consulta igual à 1 ou 3,o formato do Período de Solicitação deve ser AAAA (Ano)."
		Case cOpcValid == "000786"
			cString := STR0786 //"O CPF do Trabalhador só deve ser informado quando a Opção de Consulta for 1 ou 2."
		Case cOpcValid == "000787"
			cString := STR0787 //"O CPF do Trabalhador deve ser informado quando a Opção de Consulta for 1 ou 2."
		Case cOpcValid == "000788"
			cString := STR0788 //"Informar um CPF válido, para o qual tenha sido enviado evento de remuneração (S-1200 ou S-1202) e/ou de pagamento (S-1210)."
		Case cOpcValid == "000789"
			cString := STR0789 //"A data informada não pode ser posterior à data atual."
		Case cOpcValid == "000790"
			cString := STR0790 //"O CPF do Trabalhador é inválido"
		Case cOpcValid == "000791"
			cString := STR0791 //"O número de inscrição do contribuinte é igual ao número de inscrição do empregador"
		Case cOpcValid == "000792"
			cString := STR0792 //"Deve preencher o campo com um número entre 1 e 31."
		Case cOpcValid == "000793"
			cString := STR0793 //"Deve corresponder ao somatório das rubricas {codRubr} de vencimento ({tpRubr=1}) deduzido do somatório das rubricas de descontos ({tpRubr=2}), dos registros inferiores, não podendo ser menor que 0(zero)."
		Case cOpcValid == "000794"
			cString := STR0794 //"Se {classTrib} igual a [21,22], deve ser igual [3,4]."
		Case cOpcValid == "000795"
			cString := STR0795 //"Se {classTrib} <> [21,22]) deve ser igual a [1,4]."
		Case cOpcValid == "000796"
			cString := STR0796 //"Informação obrigatória para trabalhadores das categorias "empregados" e "agentes públicos"."
		Case cOpcValid == "000797"
			cString := STR0797 //"Informação obrigatória no caso de {classTrib} = [3]."
		Case cOpcValid == "000798"
			cString := STR0798 //"O {codIncCP} da tabela de rubricas só pode indicar [23, 24, 61] se o trabalhador tiver como {codCateg} = [301, 303, 305, 410]."
		Case cOpcValid == "000799"
			cString := STR0799 //"O preenchimento do campo é exclusivo e obrigatório apenas quando {multTabRubricas} for igual a [S]."
		Case cOpcValid == "000800"
			cString := STR0800 //"O valor deve ser maior que zero."
		Case cOpcValid == "000801"
			cString := STR0801 //"O preenchimento é obrigatório se for maior de dezoito anos."
		Case cOpcValid == "000802"
			cString := STR0802 //"Só preencher este grupo de informações se houver {codRubr} em {itensRemun}, cujo {codIncIRRF} seja igual a [51, 52, 53, 54, 55]."
		Case cOpcValid == "000803"
			cString := STR0803 //"Permite o valor igual a zero apenas se {indMV} do registro superior for igual a [3]. Nos demais casos o valor deve ser maior que zero."
		Case cOpcValid == "000804"
			cString := STR0804 //"O campo só pode ser preenchido se {classTrib} = [22] e exista remuneração exclusivamente na categoria [701]."
		Case cOpcValid == "000805"
			cString := STR0805 //"Deve ser um mês/ano válido e estar no formato AAAA-MM (Ano-Mês)."
		Case cOpcValid == "000806"
			cString := STR0806 //"A data informada deve estar compreendida dentro do período de apuração."
		Case cOpcValid == "000807"
			cString := STR0807 //"A data informada deve ser igual ou anterior à data atual."
		Case cOpcValid == "000808"
			cString := STR0808 //"O Valor do reajuste deve corresponder ao Vlr. Liquido dividido por 0,65."
		Case cOpcValid == "000809"
			cString := STR0809 //"Só preencher este campo se houver {codRubr} em {itensRemun}, cuja natureza de rubrica {natRubr} indicada = gual a [9219]."
		Case cOpcValid == "000810"
			cString := STR0810 //"Deve ser uma data igual ou anterior ao período de apuração, informado em {perApur}."
		Case cOpcValid == "000811"
			cString := STR0811 //"A categoria deste trabalhador não é válida para o evento S-1200 "
		Case cOpcValid == "000812"
			cString := STR0812 //"Para trabalhadores com categorias iguais a [301|302|303|304|305|306|309|410], {TpRegPrev} do trabalhador deve ser igual a [1]."
		Case cOpcValid == "000813"
			cString := STR0813 //"Para trabalhadores com categorias iguais a [301|302|303|304|305|306|309|410], {TpRegPrev} do trabalhador deve ser igual a [1]."
		Case cOpcValid == "000814"
			cString := STR0814 //"Para recepção do evento de Reabertura, é necessário que já exista evento de Encerramento (S-1299) para o mesmo período de apuração na base do RET."
		Case cOpcValid == "000815"
			cString := STR0815 //"Deve ser um mês/ano válido, igual ou posterior a implementação do eSocial."
		Case cOpcValid == "000816"
			cString := STR0816 //"Informar o mês/ano (formato AAAA-MM) de referência das informações, se {indApuracao} for igual a [1], ou apenas o ano (formato AAAA), se {indApuracao} for igual a [2]"
		Case cOpcValid == "000817"
			cString := STR0817 //"O Processo Judicial deve existir na Tabela de Processos (S-1070)."
		Case cOpcValid == "000818"
			cString := STR0818 //"Número de inscrição não válido. Faça a validação do registro S-1070 (Tabela de Processos Administrativos/Judiciais)."
		Case cOpcValid == "000819"
			cString := STR0819 //"Se Indicativo de Comercialização for igual a [3],o tipo de inscrição da identificação dos adquirentes da produção deve ser igual a [1,2]."
		Case cOpcValid == "000820"
			cString := STR0820 //"Se Indicativo de Comercialização for igual a [8], o tipo de inscrição da identificação dos adquirentes da produção deve ser igual a [1]."
		Case cOpcValid == "000821"
			cString := STR0821 //"Indicativo de período de apuração(Ind.Per.Apur) igual à 1, o formato do Período de Solicitação(Per.Apuração) deve ser AAAA-MM (Ano e Mês)."
		Case cOpcValid == "000822"
			cString := STR0822 //"Indicativo de período de apuração(Ind.Per.Apur) igual à 2, o formato do Período de Solicitação(Per.Apuração) deve ser AAAA (Ano)."
		Case cOpcValid == "000823"
			cString := STR0823//"Preenchimento obrigatório quando os campos Remuneração, Pagto Diver, Pag.Benefic, Aq.Prd.Rural, Com.Produção, Cont.NãoPort, InfoComplPer forem todos preenchidos com Não"
		Case cOpcValid == "000824"
			cString := STR0824 //"O trabalhador deve possuir evento de remuneração(S-1200) já encaminhado para o mesmo período de apuração."
		Case cOpcValid == "000825"
			cString := STR0825 //"Deve ser um CNPJ diferente do CNPJ do base do empregador e diferente dos informados na Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos (S-1005)."
		Case cOpcValid == "000826"
			cString := STR0826 //"O Código de FPAS deve ser preenchido com 515 ou 507, conforme o Sindicato por intermédio do qual os trabalhadores avulsos foram contratados esteja vinculado a Indústria ou ao Comércio."
		Case cOpcValid == "000827"
			cString := STR0827 //"O código de terceiros informado deve ser compatível com o código de FPAS informado, conforme tabela 4."
		Case cOpcValid == "000828"
			cString := STR0828 //"Conteúdo do campo inválido, pois para órgão público a opção 5 deve ser selecionada."
		Case cOpcValid == "000829"
			cString := STR0829 //"O Identificador de Recibo de Pgto deve ser um valor atribuído pela empresa em S-1207"
		Case cOpcValid == "000830"
			cString := STR0830 //"O Valor de Pgto Efetuado deve corresponder ao Valor do Recibo do Demonstrativo informado do Recibo de Pgto em S-1200 ou S-1202."
		Case cOpcValid == "000831"
			cString := STR0831 //"Se Tipo de Pagameno for igual a 2, o valor atribuído ao campo deve existir no evento S-2299."
		Case cOpcValid == "000832"
			cString := STR0832 //"Se Tipo de Pagameno for igual a 3, o valor atribuído ao campo deve existir no evento S-2399."
		Case cOpcValid == "000833"
			cString := STR0833 //"O valor atribuído ao campo deve existir no evento S-2299."
		Case cOpcValid == "000834"
			cString := STR0834 //"O valor atribuído ao campo deve existir no evento S-2399."
		Case cOpcValid == "000835"
			cString := STR0835 //"Código da Tabela de Processos Inválido."
		Case cOpcValid == "000836"
			cString := STR0836 //"O valor da contribuição sindical devida deve ser maior que 0 (zero)."
		Case cOpcValid == "000837"
			cString := STR0837 //"Preencher com o número do CPF do trabalhador."
		Case cOpcValid == "000838"
			cString := STR0838 //"Se indApuracao = [2], tpCR = 108221, 108222, 108223, 108224."
		Case cOpcValid == "000839"
			cString := STR0839 //"Os tipos de código da receita validos são {108201,108202,108203,108204,108221,108222,108223,108224,109901,109902}."
		Case cOpcValid == "000840"
			cString := STR0840 //"Esta linha de registro não é coerente com nenhum registro informado no evento S-1200."
		Case cOpcValid == "000841"
			cString := STR0841 //"Se {indApuracao} = [2], preencher com [1]."
		Case cOpcValid == "000842"
			cString := STR0842 //"Deve corresponder ao somatório dos valores informados no campo {vrRubr} em S-1200, nos grupos {remunPerApur} e {remunPerAnt}, e também em S-2299 e S-2399."
		Case cOpcValid == "000843"
			cString := STR0843 //"Os tipos de código da receita validos são {121802,122102}."
		Case cOpcValid == "000844"
			cString := STR0844 //"O valor deve ser a somatória de {valor}, se {tpCR} = {121802} quando {tpValor}=[11,12,13,14], do grupo {infoBaseCS} multiplicado pela alíquota de 1.5% e se categoria {codCateg} = [711]- Transportador Autônomo."
		Case cOpcValid == "000845"
			cString := STR0845 //"O valor deve ser a somatória de {valor}, se {tpCR} = {122102} quando {tpValor}=[11,12,13,14], do grupo {infoBaseCS} multiplicado pela alíquota de 1.0% e se categoria {codCateg} = [711]- Transportador Autônomo."
		Case cOpcValid == "000846"
			cString := STR0846 //"O preenchimento do campo é obrigatório quando ({classTrib} do evento S-1000 -Informações do Empregador = [03]). Para os demais empregadores, não deve ser informado."
		Case cOpcValid == "000847"
			cString := STR0847 //"Preenchimento obrigatório se Tp.Acidente for igual 1 ou 3."
		Case cOpcValid == "000848"
			cString := STR0848 //"Se o Tipo de CAT for igual a 3-Comunicação de Óbito, o campo deverá sempre ser preenchido com "S"."
		Case cOpcValid == "000849"
			cString := STR0849 //"O campo Indic. CAT não pode ser preenchido quando o Tipo Registrador for Diferente de 1- Empregador. "
		Case cOpcValid == "000850"
			cString := STR0850 //"O Preenchimento do campo CNPJ Local é Obrigatório quando o Tipo do Registrador for igual a 1, Tipo do Local igual 1 ou 2 e Tipo de Inscrição do grupo Identificação do empregador for igual a 1."
		Case cOpcValid == "000851"
			cString := STR0851 //"Deve ser um CNPJ válido informado através do evento S-1005 se Tipo Local for  igual a 1."
		Case cOpcValid == "000852"
			cString := STR0852 //"Não deve ser um CNPJ informado através do evento S-1005 quando o Tipo Local for  igual a 2."
		Case cOpcValid == "000853"
			cString := STR0853 //"Os tipos de código da receita validos são { 056107,056108,056109,058806,061001,328006,356201,206301 }."
		Case cOpcValid == "000854"
			cString := STR0854 //"Existe um Evento de Afastamento Temporário com Data Anterior a Data de Acidente Informada."
		Case cOpcValid == "000855"
			cString := STR0855 //"Código de receita inválido."
		Case cOpcValid == "000856"
			cString := STR0856 //"O código não correspondente à classificação tributária do contribuinte."
		Case cOpcValid == "000857"
			cString := STR0857 //"Se Natureza da informação ({natInfo}) for igual a [3], deve corresponder a um recibo de arquivo correspondente ao leiaute S-1299. O recibo não é válido."
		Case cOpcValid == "000858"
			cString := STR0858 //"Se Natureza da informação ({natInfo}) for igual a 1 ou 2, deve corresponder a um recibo de arquivo correspondente ao leiaute S-4000. O recibo não é válido."
		Case cOpcValid == "000859"
			cString := STR0859 //"O Código de Lotação não é válido."
		Case cOpcValid == "000860"
			cString := STR0860 //"O Código relativo ao FPAS não é válido."
		Case cOpcValid == "000861"
			cString := STR0861 //"Deve ser preenchido com um número de 8 posições."
		Case cOpcValid == "000862"
			cString := STR0862 //"O e-mail deve possuir o caractere '@' e este não pode estar no início e no fim do e-mail. Deve possuir no mínimo um caractere '.' depois do @ e não pode estar no fim do e-mail."
		Case cOpcValid == "000863"
			cString := STR0863 //"O Código de Terceiro não é valido."
		Case cOpcValid == "000864"
			cString := STR0864 //"O Código da Categoria do Trabalhador não é valido."
		Case cOpcValid == "000865"
			cString := STR0865 //Deve ser um recibo de entrega válido correspondente um arquivo no leiaute S-4000.
		Case cOpcValid == "000866"
			cString := STR0866 //"Deve corresponder ao informado pelo empregador no evento de origem (S-4000, campo {perSolicit})."
		Case cOpcValid == "000867"
			cString := STR0867 //"Deve ser preenchido com o código da categoria do trabalhador igual ao Cadastramento Inicial do Vínculo ou Admissão de Trabalhador."
		Case cOpcValid == "000868"
			cString := STR0868 //"Deve ser preenchido com o código da categoria do trabalhador igual a Folha de Pagamento."
		Case cOpcValid == "000869"
			cString := STR0869 //"Deve ser preenchido com o código da categoria do trabalhador igual a Remuneração do Trabalhador."
		Case cOpcValid == "000870"
			cString := STR0870 //"Valor da base de cálculo Divergente."
		Case cOpcValid == "000871"
			cString := STR0871 //"Os tipos de código da receita validos são {056107,056108,056109,058806,061001,328006,356201}"
		Case cOpcValid == "000872"
			cString := STR0872 //Valor de IRRF de Desconto está Divergente.
		Case cOpcValid == "000873"
			cString := STR0873 //"Fap Informado deve ser um número maior ou igual a 0,5000 e menor ou igual a 2,0000"
		Case cOpcValid == "000874"
			cString := STR0874 //Código de Terceiro informado não é compatível com o código de FPAS informado na Identificação do Sindicato"
		Case cOpcValid == "000875"
			cString := STR0875  //Deve ser uma data compreendida no período de apuração informada em {perApur}.
		Case cOpcValid == "000876"
			cString := STR0876  //Deve ser um número maior ou igual a 0,5000 e menor ou igual a 2,0000, de acordo com o estabelecido pelo Ministério do Trabalho e Previdência Social. A divergência só é permitida se houver processo informado em {procAdmJudFap}.
		Case cOpcValid == "000877"
			cString := STR0877  //"A transmissão deste evento o Número de Inscrição (nrInsc) do empregador deve corresponder a um CPF válido."
		Case cOpcValid == "000878"
			cString := STR0878  //"O valor total da aquisição deve corresponder a soma do valor bruto dos registros vinculados"
		Case cOpcValid == "000879"
			cString := STR0879 //"O campo 'Indicativo de depósito do Montante Legal (C1G_INDDEP)' só pode ser 1=Sim quando  'Indicativo da auditoria da ação fiscal (C1G_INDAUT)' for igual a 1"
		Case cOpcValid == "000880"
			cString := STR0880 //"Se {tpPgto} = [2] deve ser um recibo de arquivo gerado no leiaute S-2299."
		Case cOpcValid == "000881"
			cString := STR0881 //"Se {tpPgto} = [3], deve ser um recibo de arquivo gerado no leiaute S-2399."
		Case cOpcValid == "000882"
			cString := STR0882 //"O código informado deve existir na tabela S-1010 - Tabela de Rubricas."
		Case cOpcValid == "000883"
			cString := STR0883 //"Deve ser um ano válido e estar no formato AAAA (Ano)."
		Case cOpcValid == "000884"
			cString := STR0884  //Se "ClassTrib" é igual 21 (evento S-1000) o tipo de inscrição deve ser 3 ou 4 (grupo "ideEstabLot")
		Case cOpcValid == "000885"
			cString := STR0885  //Se "ClassTrib" é igual 22 (evento S-1000) o tipo de inscrição deve ser igual a 3 (grupo "ideEstabLot")
		Case cOpcValid == "000886"
			cString := STR0886  //Se "ClassTrib" é diferente de 21 ou 22 (evento S-1000) o tipo de inscrição deve ser igual a 1 ou 4 (grupo "ideEstabLot")
		Case cOpcValid == "000887"
			cString := STR0887  //Para empregador doméstico o tipo de inscrição deve ser 2 (grupo "ideEstabLot")
		Case cOpcValid == "000888"
			cString := STR0888  //"Só pode ser utilizada rubrica cujo 'codIncIRRF' em S-1010 seja igual a 31,32,33,34,35,51,52,53,54,55,56,57,58,81,82 ou 83."
		Case cOpcValid == "000889"
			cString := STR0889  //"O código da rúbrica deve existir na tabela S-1010"
		Case cOpcValid == "000890"
			cString := STR0890 //"O CPF do Trabalhador é inválido, não existe trabalhador sem vínculo com esse número."
		Case cOpcValid == "000891"
			cString := STR0891 //"O CPF é inválido."
		Case cOpcValid == "000892"
			cString := STR0892 //"O CPF não consta no evento de cadastro do trabalhador (S-2200, S-2205 ou S-2300)"
		Case cOpcValid == "000893"
			cString := STR0893 //"Esta filial é uma SCP e por isso não pode ser parametrizada como matriz."
		Case cOpcValid == "000894"
			cString := STR0894 //"Já existe uma Filial cadastrada como Matriz e só é permitida uma Filial Matriz por empresa."
		Case cOpcValid == "000895"
			cString := STR0895 //"Esta filial já esta configurada como SCP de outra filial."
		Case cOpcValid == "000896"
			cString := STR0896 //"A filial SCP precisa ser da mesma empresa da filial do sócio ostensivo."
		Case cOpcValid == "000897"
			cString := STR0897 //"A filial matriz não pode ser relacionada como SCP."
		Case cOpcValid == "000898"
			cString := STR0898 //"Esta filial não pode ser associada como SCP dela mesma."
		Case cOpcValid == "000899"
			cString := STR0899 //"Uma filial sócio ostensivo não pode ser associada como filial SCP."
		Case cOpcValid == "000900"
			cString := STR0900 //"Uma filial SCP não pode ser sócio ostensivo de outra filial SCP."
		Case cOpcValid == "000901"
			cString := STR0901 //"A data informada deve ser menor ou igual a DT_FIN do registro K100."
		Case cOpcValid == "000902"
			cString := STR0902 //"O código informado deve ser diferente do campo COD_ITEM_ORI do Registro K210."
		Case cOpcValid == "000903"
			cString := STR0903 //"A data deve estar compreendida no período de apuração – K100 e ser maior que DT_SAÍDA."
		Case cOpcValid == "000904"
			cString := STR0904 //"O código da mercadoria deve ser diferente do código do produto/insumo reprocessado/ reparado (COD_ITEM do Registro K260)."
		Case cOpcValid == "000905"
			cString := STR0905 //"Os campos QTD_COR_POS e QTD_COR_NEG não podem ser preenchidos consecutivamente."
		Case cOpcValid == "000906"
			cString := STR0906 //"Este campo somente pode existir quando a origem da correção de apontamento for dos tipos 1 ou 2 (campo ORIGEM do Registro K270)."
		Case cOpcValid == "000907"
			cString := STR0907 //"A data do estoque deve ser anterior à data inicial do período de apuração – campo DT_FIN do Registro K100."
		Case cOpcValid == "000908"
			cString := STR0908 //"Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05, 06 e 10."
		Case cOpcValid == "000909"
			cString := STR0909 //"O código do produto deve ser diferente do código de insumo."
		Case cOpcValid == "000910"
			cString := STR0910 //"O registro 1310 (Movimentação diária de combustíveis por tanque) é obrigatório para a geração do 1300 no arquivo magnético do SPED Fiscal."
		Case cOpcValid == "000911"
			cString := STR0911 //"Já existe um registro para esse produto que esta compreendido entre a data inicial e data final."
		Case cOpcValid == "000912"
			cString := STR0912 //"'Valor DA' difere da soma de 'Vl.Principal' + 'Multa' + 'Juros' + 'Atual.Monet.' - 'Desconto' - 'Compensado'."
		Case cOpcValid == "000913"
			cString := STR0913 //"O Código Combinado dos Terceiros para os quais o recolhimento está suspenso, não confere com a soma dos códigos informados na Grid 'Processos Judiciais de Terceiros'."
		Case cOpcValid == "000914"
			cString := STR0914 //"Deve ser uma data posterior a data do aviso prévio que está sendo cancelado."
		Case cOpcValid == "000915"
			cString := STR0915 //"Para beneficiário residente no Brasil, não informar 'Nome Cid Ext'".
		Case cOpcValid == "000916"
			cString := STR0916 //"Para beneficiário residente no Brasil, não informar 'Caixa Postal'".
		Case cOpcValid == "000917"
			cString := STR0917 //"Para beneficiário residente no Exterior, não informar 'Id. Tp. Log.'".
		Case cOpcValid == "000918"
			cString := STR0918 //"Para beneficiário residente no Exterior, não informar 'CEP'".
		Case cOpcValid == "000919"
			cString := STR0919 //"Para beneficiário residente no Exterior, não informar 'Id. UF End.'".
		Case cOpcValid == "000920"
			cString := STR0920 //"Para beneficiário residente no Exterior, não informar 'Id. Mun. End'".
		Case cOpcValid == "000921"
			cString := STR0921 //"O campo 'Dt Fim Benef' não pode ser informado na operação de inclusão, somente no término do benefício previdenciário."
		Case cOpcValid == "000922"
			cString := STR0922 //"O campo 'Motivo Fim' não pode ser informado na operação de inclusão, somente no término do benefício previdenciário."
		Case cOpcValid == "000923"
			cString := STR0923 //"A data informada deve ser igual ou posterior à data de início na condição de exposição."
		Case cOpcValid == "000924"
			cString := STR0924 //"A data informada deve ser uma data igual ou posterior a data de início da condição ou a data de alteração de condição quando for informada."
		Case cOpcValid == "000925"
			cString := STR0925 //"O CPF do Trabalhador é inválido, não existe trabalhador com vínculo com esse número."
		Case cOpcValid == "000926"
			cString := STR0926 //"A informação prestada deve estar de acordo com o que foi informado no evento S-1070."
		Case cOpcValid == "000927"
			cString := STR0927 //"Se {opcConsult} = [2,4], formato deve ser AAAA-MM."
		Case cOpcValid == "000928"
			cString := STR0928 //"O período informado deve ser anterior ou igual ao período atual, e igual ou posterior à data de início do eSocial."
		Case cOpcValid == "000929"
			cString := STR0929 //"O período de apuração informado deve ser igual ou posterior a implementação do eSocial."
		Case cOpcValid == "000930"
			cString := STR0930 //"Conteúdo do campo não condiz. Se a Indicativo da Aquisição for igual a 1,2,4 ou 5 o  Tipo do Produto deve ser 2."
		Case cOpcValid == "000931"
			cString := STR0931 //"Conteúdo do campo não condiz. Se a Indicativo da Aquisição for igual a 3 ou 6, o Tipo do Produto deve ser 1."
		Case cOpcValid == "000932"
			cString := STR0932 //"Não pode ser superior à data atual exceto se {codMotAfast} = [15] (férias), situação em que pode ser até 60 dias superior à data atual."
		Case cOpcValid == "000933"
			cString := STR0933 //"O campo é de preenchimento obrigatório apenas para Pessoa Jurídica."
		Case cOpcValid == "000934"
			cString := STR0934 //"Se {indSusp} = [02, 03] preencher obrigatoriamente com [S]."
		Case cOpcValid == "000935"
			cString := STR0935 //"Este campo só pode ser preenchido com [S], se {indAutoria} = [1]."
		Case cOpcValid == "000936"
			cString := STR0936 //"O valor do campo deve ser igual a 1, 2 ou 3."
		Case cOpcValid == "000937"
			cString := STR0937 //"Lançamento de Rúbricas, o somatório dos Proventos deve ser maior ou igual ao somatório dos Descontos"
		Case cOpcValid == "000938"
			cString := STR0938 //"O valor total das rúbricas não pode ser negativo"
		Case cOpcValid == "000939"
			cString := STR0939 //"O preenchimento é obrigatório se for maior de doze anos. "
		Case cOpcValid == "000940"
			cString := STR0940 //"Só pode ser utilizada rubrica cujo {codIncIRRF} em S-1010 seja igual a [00, 01, 13, 33, 43, 46, 53, 63, 75, 93]."
		Case cOpcValid == "000941"
			cString := STR0941 //"Não existem processos relacionados ao campo  Cod Ter Susp {codTercsSusp} "
		Case cOpcValid == "000942"
			cString := STR0942 //"O preenchimento do CPF é obrigatório se o dependente possuir doze anos ou mais."
		Case cOpcValid == "000943"
			cString := STR0943 //"A Data de Pagamento deve ser igual ou anterior à data atual."
		Case cOpcValid == "000944"
			cString := STR0944 //"A Data de Pagamento deve estar compreendida dentro do período de apuração."
		Case cOpcValid == "000945"
			cString := STR0945 //"O numero de inscrição do estabelecimento deve pertencer ao mesmo EFR - Ente Federativo Responsável do Empregador (definido em S-1000) no cadastro CNPJ da RFB."
		Case cOpcValid == "000946"
			cString := STR0946 //"A data de exercício informada no evento de cadastro inicial do vínculo deve ser anterior a data de início da e-Social"
		Case cOpcValid == "000947"
			cString := STR0947 //"A data de exercício informada no evento de admissão deve ser igual ou posterior a data de início da e-Social"
		Case cOpcValid == "000948"
			cString := STR0948 //"A Data de Admissão não pode ser superior a 30 dias da Data Atual."
		Case cOpcValid == "000949"
			cString := STR0949 //"A Data de Admissão deve ser maior ou igual a [20/12/2000] para a categoria [103] (aprendiz)."
		Case cOpcValid == "000950"
			cString := STR0950 //"Se {tpPgto} = [1,5] a data de pagamento não pode ser anterior a {perRef} informado no grupo {detPgtoFl}. Se {tpPgto} = [2] a data de pagamento não pode ser anterior ao mês da data informada em {dtDeslig} informada no evento S-2299; Se {tpPgto} = [3] a data de pagamento não pode ser anterior ao mês da data informada em {dtTerm} informada no evento S-2399."
		Case cOpcValid == "000951"
			cString := STR0951 //"O evento de pagamento somente pode ser enviado se o mês/ano do período de apuração {perApur} for igual ou inferior ao mês/ano corrente."
		Case cOpcValid == "000952"
			cString := STR0952 //"A Informação é obrigatória se {tpPgto} = [1,5].Caso contrário não deve haver informação nesse campo."
		Case cOpcValid == "000953"
			cString := STR0953	//"A Informação É obrigatória se {tpPgto} = [2,3].Caso contrário não deve haver informação nesse campo."
		Case cOpcValid == "000954"
			cString := STR0954	//"O valor apresentado nesse campo não deve ser negativo."
		Case cOpcValid == "000955"
			cString := STR0955 //"Este campo deve corresponder ao somatório dos valores de vencimentos e descontos descritos em {detRubrFer}."
		Case cOpcValid == "000957"
			cString := STR0957 //"O Tipo de Contrato indicado no evento de admissão/cadastro inicial do respectivo vínculo deve ser igual a [2] (prazo determinado), e a data de desligamento deve ser igual a Data de Término do Contrato"
		Case cOpcValid == "000958"
			cString := STR0958 //"O Tipo de Contrato indicado no evento de admissão/cadastro inicial do respectivo vínculo deve ser igual a [2] (prazo determinado), e a data de desligamento deve anterior a Data de Término do Contrato"
		Case cOpcValid == "000959"
			cString := STR0959 //""Deve ser posterior a data de expedição {dtExped}."
		Case cOpcValid == "000960"
			cString := STR0960 //"Se não houver número a ser informado, preencher com 'S/N'."
		Case cOpcValid == "000961"
			cString := STR0961 //"Deve ser uma data posterior à data de início do estágio."
		Case cOpcValid == "000962"
			cString := STR0962 //"Só é possível alteração de categoria de trabalhadores nas seguintes opções: de 102, 103, 105, 106 para 101."
		Case cOpcValid == "000963"
			cString := STR0963 //"O parâmetro MV_TAFINIE (Data de Inicio da Empresa do eSocial) não foi encontrado no ambiente, por este motivo a data padrão assumida pelo sistema será "
		Case cOpcValid == "000964"
			cString := STR0964 //"Data de Inicio eSocial"
		Case cOpcValid == "000965"
			cString := STR0965 //"Somente é possível retificar o evento de admissão se não existirem eventos não periódicos anteriores à data de admissão"
		Case cOpcValid == "000966"
			cString := STR0966 //"Essa informação deve ser prestada apenas no estabelecimento 'Matriz'."
		Case cOpcValid == "000967"
			cString := STR0967 //"Informação obrigatória se {contPCD} = [1]."
		Case cOpcValid == "000968"
			cString := STR0968 //Não pode haver mais de um dependente com o mesmo número do CPF.
		Case cOpcValid == "000969"
			cString := STR0969 //"Informação obrigatória se {codLotacao} possuir {tpLotacao} = [8, 9]. Se informado deve ser um número maior que zero"
		Case cOpcValid == "000970"
			cString := STR0970 //"O valor liquido do registro não corresponde a operação aritmética da soma dos proventos menos a soma dos descontos."
		Case cOpcValid == "000971"
			cString := STR0971 //"Para as rubricas cujo {codIncCP} = [31, 32, 34, 35], o somatório do valor das rubricas cujo ({tpRubr} = [2,4]) deverá ser maior ou igual ao somatório do valor das rubricas cujo ({tpRubr} = [1,3])."
		Case cOpcValid == "000972"
			cString := STR0972 //"O somatório dos Vencimentos deve ser maior ou igual ao somatório dos Descontos."
		Case cOpcValid == "000973"
			cString := STR0973 //"Pagamento de remuneração informado, porém não foi encontrado um pagamento correspondente (S-1200)."
		Case cOpcValid == "000974"
			cString := STR0974 //"Pagamento de verbas rescisórias informado, porém não foi encontrado um pagamento correspondente (S-2299)."
		Case cOpcValid == "000975"
			cString := STR0975 //"Pagamento de verbas rescisórias informado, porém não foi encontrado um pagamento correspondente (S-2399)."
		Case cOpcValid == "000976"
			cString := STR0976 //Pagamento de remuneração informado, porém não foi encontrado um pagamento correspondente (S-1202)."
		Case cOpcValid == "000977"
			cString := STR0977 //"Pagamento de benefícios previdenciários informado, porém não foi encontrado um pagamento correspondente (S-1207)."
		Case cOpcValid == "000978"
			cString := STR0978 //"Pagamento relativo a competências anteriores informado porém a data é superior ao período de obrigatoriedade do eSocial."
		Case cOpcValid == "000979"
			cString := STR0979 //"Preenchimento obrigatório quando a empresa contrata e aprendiz por intermédio de entidade educativa."
		Case cOpcValid == "000980"
			cString := STR0980 //"Informar um número de processo cadastrado através do evento S-1070, cujo indicativo da matéria do processo seja igual a 1."
		Case cOpcValid == "000981"
			cString := STR0981 //"O campo Iden. Tab. Rub. não pode conter a expressão "eSocial" nas 7 (sete) primeiras posições."
		Case cOpcValid == "000982"
			cString := STR0982 //"A data de admissão do trabalhador deve ser igual ou posterior à data de início da obrigatoriedade do empregador ao eSocial."
		Case cOpcValid == "000983"
			cString := STR0983 //"Se {codCateg} = [104], deve ser preenchido com [1]."
		Case cOpcValid == "000984"
			cString := STR0984 //"Se {cadIni} = [S], deve ser anterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador no eSocial."
		Case cOpcValid == "000985"
			cString := STR0985 //"Se {cadIni} = [N], deve ser igual ou posterior à data de início da obrigatoriedade do empregador no eSocial."
		Case cOpcValid == "000986"
			cString := STR0986 //"O preenchimento é obrigatório se {tpContr} = [2,3]. Não preencher se {tpContr} = [1]."
		Case cOpcValid == "000987"
			cString := STR0987 //"Deve ser igual ou posterior à data de admissão/exercício do trabalhador."
		Case cOpcValid == "000988"
			cString := STR0988	//"O campo {tpAdmissao} deve ser igual a [2, 3, 4]."
		Case cOpcValid == "000989"
			cString := STR0989 // "O campo {tpAdmissao} deve ser igual a [2, 3, 4]."
		Case cOpcValid == "000990"
			cString := STR0990	//"Deve ser uma data igual ou posterior à data de admissão e anterior ao início da obrigatoriedade dos eventos não periódicos para o empregador no eSocial."
		Case cOpcValid == "000991"
			cString := STR0991 // "Se o {tpJornada} for diferente de '9', o preenchiento da Grid 'Horario' é obrigatório."
		Case cOpcValid == "000992"
			cString := STR0992 // "Se a data de admissão for entre 01/01/1967 e 04/10/1988, a data de opção deverá ser igual ou maior que 01/01/1967 e menor ou igual a 04/10/1988."
		Case cOpcValid == "000993"
			cString := STR0993	//"Caso a data de admissão seja anterior a 01/01/1967, a data de opção deve ser maior ou igual a 01/01/1967."
		Case cOpcValid == "000994"
			cString := STR0994 //"Informar um número de processo judicial cujo indicativo da matéria do processo ou alvará judicial seja igual a '1 - Tributária ou relativa a FGTS'."
		Case cOpcValid == "000995"
			cString := STR0995	//"Não pode ser utilizada rubrica cuja natureza de rubrica seja 1409 (salário família), 1009 (salário família complemento), 4050 (salário maternidade) e 4051 (salário maternidade-13º salário), para os trabalhadores classificados nas categorias de contribuinte individual e bolsistas da tabela 01."
		Case cOpcValid == "000996"
			cString := STR0996	//"A rubrica deve possuir um período vigente indicado em {perApur}."
		Case cOpcValid == "000997"
			cString := STR0997	//"A rubrica deve possuir um período vigente indicado em {perRef}."
		Case cOpcValid == "000998"
			cString := STR0998	//"Se existir no RET evento de desligamento para o trabalhador/vínculo ao qual se refere a remuneração, cuja data de desligamento seja anterior ou compreendida em {perApur}, não deve existir 'remuneração' para o referido vínculo. Exceto se atender a regra do eSocial 'REGRA_REMUN_JA_EXISTE_DESLIGAMENTO'."
		Case cOpcValid == "000999"
			cString := STR0999	//"O campo {ideTabRubr} deve ser preenchido para a rubrica informada."
		Case cOpcValid == "001000"
			cString := STR1000	//"Deve ser maior ou igual ao período de apuração informado em {perApur}."
		Case cOpcValid == "001001"
			cString := STR1001	//"O evento S-1295 somente pode ser enviado até três (3) vezes por período de apuração."
		Case cOpcValid == "001002"
			cString := STR1002	//"No caso de apuração mensal {perApur} no formato 'AAAA-MM', somente é aceito solicitações entre os dias 01 e 20 do mês subsequente ao do período de apuração."
		Case cOpcValid == "001003"
			cString := STR1003	//"No caso de folha de pagamento anual {perApur} no formato 'AAAA', somente é aceito solicitações entre os dias 01 e 20 de dezembro."
		Case cOpcValid == "001004"
			cString := STR1004	//"A aceitação do evento S-1295 só é possível caso não sejam satisfeitas as regras estabelecidas para o evento S-1299 [REGRA_VALIDA_FECHAMENTO_FOPAG]."
		Case cOpcValid == "001005"
			cString := STR1005	//"Se o tipo de inscrição {tpInsc} = [1](CNPJ), o grupo de TAGs {ideRespInf}(Responsável pelas informações) é obrigatório."
		Case cOpcValid == "001006"
			cString := STR1006 //"O CPF do Responsável é inválido."
		Case cOpcValid == "001007"
			cString := STR1007 //"O Telefone do Responsável deve conter apenas números, com o mínimo de dez dígitos."
		Case cOpcValid == "001008"
			cString := STR1008 //"O Nome não pode conter mais que três letras iguais consecutivas."
		Case cOpcValid == "001009"
			cString := STR1009 //"Deve ser um CPF enviado anteriormente em S-2190."
		Case cOpcValid == "001010"
			cString := STR1010 //"A matrícula informada nesta campo, deve corresponder a mesma informada pelo empregador no evento S-2200."
		Case cOpcValid == "001011"
			cString := STR1011 //"Se o código da categoria do trabalhador {codCateg} for igual a '106', o preenchimento do campo é obrigatório."
		Case cOpcValid == "001012"
			cString := STR1012 //"Se o tipo de registro do trabalhador {tpRegTrab} for igual a '2', o preenchimento do campo é obrigatório."
		Case cOpcValid == "001013"
			cString := STR1013 //"Se a categoria do trabalhador pertencer ao grupo 'agente público' (301,302,303,304,305,306,307,308,309), o preenchimento do campo 'Motivo Alter' é obrigatório."
		Case cOpcValid == "001014"
			cString := STR1014 //"Em caso de sucessão trabalhista, o campo 'Data Efeito' deve ser igual ou posterior à data de início do vínculo."
		Case cOpcValid == "001015"
			cString := STR1015 //"O conteúdo do campo 'Data Efeito' deve ser uma data válida, igual ou posterior à data de admissão."
		Case cOpcValid == "001016"
			cString := STR1016 //"Informar se o trabalhador preenche cota de pessoas com deficiência habilitadas ou de beneficiários reabilitados apenas para trabalhadores da categoria 'Empregados'. Não informar nos demais casos."
		Case cOpcValid == "001017"
			cString := STR1017 //"Se o código da categoria do trabalhador {codCateg} for igual a '104', o campo deve ser preenchido com [1]."
		Case cOpcValid == "001018"
			cString := STR1018 //"Deve ser um CNPJ diferente do CNPJ do empregador."
		Case cOpcValid == "001019"
			cString := STR1019 //"Deve ser um CNPJ diferente dos estabelecimentos informados através do evento S-1005 (Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos)."
		Case cOpcValid == "001020"
			cString := STR1020 //"O campo {CodCat} só deve ser informado se o trabalhador tiver sido registrado como TSVE - Trabalhador Sem Vínculo de Emprego/Estatutário, através do evento S-2300. Não deve ser informado nos demais casos."
		Case cOpcValid == "001021"
			cString := STR1021 //"Somente pode ser preenchido se {codMotAfast} = [01, 03]."
		Case cOpcValid == "001022"
			cString := STR1022 //"Número do processo só pode ser informado para Reintegração por Determinação Judicial."
		Case cOpcValid == "001023"
			cString := STR1023 //"Em arquivo de empregador Pessoa Física, deve ser diferente do CPF informado em {ideEmpregador}."
		Case cOpcValid == "001024"
			cString := STR1024 //"Deve ser igual ou posterior à data de início do afastamento do trabalhador."
		Case cOpcValid == "001025"
			cString := STR1025 //"Deve ser uma data compreendida no mês em que ocorreu o desligamento conforme informado no campo 'Data Desligamento' ou em mês anterior."
		Case cOpcValid == "001026"
			cString := STR1026 //Se a data de admissão for anterior a 01/01/1967, a data de opção deve ser maior ou igual a 01/01/1967.
		Case cOpcValid == "001027"
			cString := STR1027 //"O evento retificador deve se referir ao mesmo CPF e 'Categoria' informado no evento original. Por integrar a 'chave' de identificação para este tipo de evento, a 'Categoria' não pode ser objeto de retificação. Caso tenha sido informado incorretamente, o evento de início deve ser excluído e um novo evento com a categoria correta deve ser enviado."
		Case cOpcValid == "001028"
			cString := STR1028 //"O preenchimento do Código do Indicativo da Suspensão, atribuído pelo empregador em S-1070, é obrigatório."
		Case cOpcValid == "001029"
			cString := STR1029 //"A Rubrica deve possuir um período vigente no mês da data do término, informada no campo {dtTerm}."
		Case cOpcValid == "001030"
			cString := STR1030 //"Não deve existir evento de admissão parcial (S-2190) sem o correspondente evento de admissão (S-2200) cuja 'data de admissão' seja anterior ou igual ao período de apuração da folha de pagamento."
		Case cOpcValid == "001031"
			cString := STR1031 //"Se o cadastramento inicial de vínculo {cadIni} for igual a '2' = Não, o preenchimento do campo 'Matr. Ant.' é obrigatório."
		Case cOpcValid == "001032"
			cString := STR1032 //"O mês/ano da emissão da nota fiscal deve ser igual ao mês/ano indicado no registro de abertura do arquivo."
		Case cOpcValid == "001033"
			cString := STR1033 //"O ano da emissão da nota fiscal deve ser igual ao ano indicado no registro de abertura do arquivo."
		Case cOpcValid == "001034"
			cString := STR1034 //"Deve ser um CPF válido e diferente do CPF do declarante e do empregado."
		Case cOpcValid == "001035"
			cString := STR1035 //"Campo obrigatório em caso de Código de Motivo de Desligamento [34]."
		Case cOpcValid == "001036"
			cString := STR1036 //"O valor informado deve existir no evento 'Convocação para Trabalho Intermitente - S-2260'."
		Case cOpcValid == "001037"
			cString := STR1037 //"Deve ser indicado as Informações da(s) convocação(ões) de trabalho intermitente em caso de categoria do trabalhador '111'."
		Case cOpcValid == "001038"
			cString := STR1038 //"Informar um número de processo cadastrado através do evento S-1070, cujo indicativo da matéria do processo seja igual a 1 ou 7."
		Case cOpcValid == "001039"
			cString := STR1039 //"Informar um número de processo cadastrado através do evento S-1070, cujo indicativo da matéria do processo seja igual a 8."
		Case cOpcValid == "001040"
			cString := STR1040 //"O código [34] só pode ser utilizado para desligamento de trabalhador pertencente à categoria de doméstico (104)."
		Case cOpcValid == "001041"
			cString := STR1041 //"Deve ser maior ou igual ao mês/ano informado em 'Data Desligamento'."
		Case cOpcValid == "001042"
			DBSelectArea( "SX3" )
			DBSetOrder( 2 )
			If SX3->( MsSeek( "T3H_TPTRIB" ) )
				cString := I18N( STR1042, { AllTrim( X3Titulo() ) } ) //"Informar um número de processo cadastrado através do evento S-1070, cujo indicativo da matéria do processo seja igual a: [1] se #1 = [1,2]; [1,7] se #1 = [3]; [8] se #1 = [4]."
			EndIf
		Case cOpcValid == "001043"
			cString := STR1043 //"Grau de exposição a agentes nocivos deve ser preenchido com os valores [1], [2], [3] ou [4]."
		Case cOpcValid == "001044"
			cString := STR1044 //"Se o tipo do processo for igual a '3 - Número de Beneficio', o campo Indicativo da matéria do processo deve ser igual a '6 - Conversão de Licenças Saúde em Acidente de Trabalho'"
		Case cOpcValid == "001045"
			cString := STR1045 //"Deve ser uma data válida e igual ou posterior à data de início da obrigatoriedade do empregador no eSocial."
		Case cOpcValid == "001046"
			cString := STR1046 //"Deve ser uma data valida e igual ou posterior a {dtInicio}."
		Case cOpcValid == "001047"
			cString := STR1047 //"O preenchimento é obrigatório se {codHorContrat} não for preenchido."
		Case cOpcValid == "001048"
			cString := STR1048 //"O preenchimento é obrigatório se {dscJornada} não for preenchido."
		Case cOpcValid == "001049"
			cString := STR1049 //"O preenchimento é obrigatório, exceto se o código de categoria do trabalhador for igual a [901, 903, 904]."
		Case cOpcValid == "001050"
			cString := STR1050 //"Se {cadIni} = [N] e {tpAdmissao} = [1], deve ser igual ou posterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador no eSocial."
		Case cOpcValid == "001051"
			cString := STR1051 //"Preenchimento obrigatório se {undSalFixo} for igual a [6, 7]."
		Case cOpcValid == "001052"
			cString := STR1052 //"Se {cadIni} = [S], deve ser anterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador."
		Case cOpcValid == "001053"
			cString := STR1053 //{tmpParc} O código [1] só é válido se {codCateg} = [104].
		Case cOpcValid == "001054"
			cString := STR1054 //{tmpParc} Os códigos [2, 3] não são válidos se {codCateg} = [104].
		Case cOpcValid == "001055"
			cString := STR1055 //"Se {cadIni} = [S], deve ser anterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador."
		Case cOpcValid == "001056"
			cString := STR1056 //"Se {cadIni} = [N], deve ser igual ou posterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador."
		Case cOpcValid == "001057"
			cString := STR1057 //"Não pode ser utilizada rubrica cujo {codIncIRRF} em S-1010 seja igual a [31, 32, 33, 34, 35, 51, 52, 53, 54, 55, 81, 82, 83]."
		Case cOpcValid == "001058"
			cString := STR1058 //"Informar um número de processo judicial cadastrado através do evento S-1070, cujo indicativo da matéria do processo seja igual a 1."
		Case cOpcValid == "001059"
			cString := STR1059 //"Informar um número de processo judicial cadastrado através do evento S-1070, cujo indicativo da matéria do processo seja igual a 1 ou 7."
		Case cOpcValid == "001060"
			cString := STR1060 //"Informar um número de processo judicial cadastrado através do evento S-1070, cujo indicativo da matéria do processo seja igual a 8."
		Case cOpcValid == "001061"
			cString := STR1061 //"Não pode ser utilizada rubrica, cujo {codIncCP} em S-1010 seja igual a [25|26|51] se {codCateg} pertencer a um dos grupos 'contribuinte individual' ou 'bolsistas' da Tabela 01 (Categoria de Trabalhadores)."
		Case cOpcValid == "001062"
			cString := STR1062 //"Deve ser uma data igual ou anterior ao período de apuração, informado em {perApur}. Deve ser informado no formato AAAA-MM."
		Case cOpcValid == "001063"
			cString := STR1063 //"O CPF informado deve ter registro de desligamento do mesmo {cpfTrab}, com campo {cpfSubstituto} preenchido com o CPF do declarante."
		Case cOpcValid == "001064"
			cString := STR1059 //"Deve ser o dia imediatamente seguinte à data de desligamento no CPF substituído."
		Case cOpcValid == "001065"
			cString := STR1065 //"Existe um afastamento vigente no TAF e pendente de envio ao Governo, até que o envio seja realizado não é possível a inclusão de um novo afastamento para esse trabalhador."
		Case cOpcValid == "001066"
			cString := STR1066 //"É necessário que o trabalhador esteja com status igual a '4'(Transmitido ao RET), antes que seja incluído um evento de afastamento."
		Case cOpcValid == "001067"
			cString := STR1067 //"Campo preenchido exclusivamente para os trabalhadores enquadrados nas categorias relativas a Empregado, Servidor Público, Avulso ou categorias com os codigos 731,734 ou 738."
		Case cOpcValid == "001068"
			cString := STR1068 //"O preenchimento do campo 'NIS' é obrigatório, exceto se o código de categoria do trabalhador for igual a [901, 903, 904]."
		Case cOpcValid == "001069"
			cString := STR1069 //"Se o 'Código do Motivo de Afastamento' {codMotAfast} for igual a [01,03], o preechimento do grupo 'infoAtestado' é obrigatório."
		Case cOpcValid == "001070"
			cString := STR1070 //"O preenchimento obrigatório caso {codMotAfast} seja retificado de [01] para [03] ou de [03] para [01]."
		Case cOpcValid == "001071"
			cString := STR1071 //"O preenchimento é obrigatório se a categoria de origem do trabalhador corresponder a 'empregado' ou 'avulso'."
		Case cOpcValid == "001072"
			cString := STR1072 //"O preenchimento do campo é obrigatório para {origRetif} = [2, 3]."
		Case cOpcValid == "001073"
			cString := STR1073 //"O código [1] só é válido se{codCateg} = [104]."
		Case cOpcValid == "001074"
			cString := STR1074 //Preenchimento obrigatório se {indEtt} = [S]. Não pode ser informado nos demais casos.
		Case cOpcValid == "001075"
			cString := STR1075 //Apenas números são aceitos {1234567890}
		Case cOpcValid == "001076"
			cString := STR1076 //Preenchimento permitido apenas se {indEtt} = [S]
		Case cOpcValid == "001077"
			cString := STR1077 //"Para os registros que já foram transmitidos ao Fisco ou validados, não é necessário refazer o processo de validação."
		Case cOpcValid == "001078"
			cString := STR1078 //Deve ser um ano válido e estar no formato AAAA(Ano).
		Case cOpcValid == "001079"
			cString := STR1079 //Preenchimento {InfoComplementares} CUU_CARCI e/ou CUU_FUNCI só são permitidos para Trabalhador Avulso, Diretor não empregado, Cooperado e Servidor Público Indicado a Conselho.
		Case cOpcValid == "001080"
			cString := STR1080 //Preenchimento obriatório {InfoComplementares} CUU_CARCI e/ou CUU_FUNCI  para Trabalhador Avulso, Diretor não empregado, Cooperado e Servidor Público Indicado a Conselho.
		Case cOpcValid == "001081"
			cString := STR1081 //"Existe um evento S-2306 transmitido, portanto o evento S-2300 não pode ser retificado. É necessário realizar a exclusão deste evento S-2306."
		Case cOpcValid == "001082"
			cString := STR1082 //"Não pode ser utilizada rubrica, cujo {codIncCP} em S-1010 seja igual a [23|24|61]."
		Case cOpcValid == "001083"
			cString := STR1083 //"Deve ser uma data não superior à data atual acrescida de 10 dias corridos, exceto se {codMotAfast} = [15] (férias), situação em que pode ser superior à data atual em até 60 dias."
		Case cOpcValid == "001084"
			cString := STR1084 //"Na retificação do afastamento, o motivo de afastamento {codMotAfast} somente pode ser alterado de 01 para 03 ou 03 para 01."
		Case cOpcValid == "001085"
			cString := STR1085 //"O parâmetro MV_TAFININ (Data de Inicio da obrigatoriedade dos eventos não periódicos para o empregador.) não foi encontrado no ambiente, por este motivo a data padrão assumida pelo sistema será "
		Case cOpcValid == "001086"
			cString := STR1086 //"Data de Inicio eventos não periódicos"
		Case cOpcValid == "001087"
			cString := STR1087 //"A data de admissão do trabalhador deve ser igual ou posterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador."
		Case cOpcValid == "001088"
			cString := STR1088 //"O CEP deve ser preenchido apenas com números."
		Case cOpcValid == "001089"
			cString := STR1089 //"Deve ser uma data válida e igual ou posterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador no eSocial."
		Case cOpcValid == "001090"
			cString := STR1090 //"Somente é permitido o envio de evento de desligamento para trabalhador afastado temporariamente se o motivo de desligamento for igual a (10, 11, 12, 13, 14, 26, 34)."
		Case cOpcValid == "001091"
			cString := STR1091 //"Existe um evento de afastamento temporário atrelado ao trabalhado a ser desligado, porém ainda não transmitido, verifique se o evento de afastamento temporário deve ser transmitido, antes do envio do desligamento."
		Case cOpcValid == "001092"
			cString := STR1092 //"Se o trabalhador foi desligado antes do início dos eventos não periódicos para o empregador no eSocial, é necessária a existência do evento S-2200 com o preenchimento do campo {dtDeslig}."
		Case cOpcValid == "001093"
			cString := STR1093 //"Número do recibo não encontrado no evento."
		Case cOpcValid == "001094"
			cString := STR1094 //"Este campo só é obrigatório se o motivo de desligamento não for igual a (11|12|13|25|28|29|30|34)."
		Case cOpcValid == "001095"
			cString := STR1095 //"Campo NIS não deve ser preenchido no caso de exclusão de pagamento de rendimentos do trabalho (S-1210) ou de admissão preliminar (S-2190)."
		Case cOpcValid == "001096"
			cString := STR1096 //"Podem ser excluídos apenas os eventos relacionados a Não periódicos (S-2190 a S-2400) e os Periódicos (S-1200 a S-1280 e S-1300)."
		Case cOpcValid == "001097"
			cString := STR1097 //"O evento do recibo não deve constar como excluído ou retificado."
		Case cOpcValid == "001098"
			cString := STR1098 //"Número do recibo não encontrado no evento."
		Case cOpcValid == "001099"
			cString := STR1099 //"Não é possível realizar a exclusão de um registro já transmitido."
		Case cOpcValid == "001100"
			cString := STR1100 //"Registro não pode ser excluído, pois se encontra em processo da transmissão."
		Case cOpcValid == "001101"
			cString := STR1101 //"Registro não pode ser excluído. Aguardando processo de transmissão do evento de exclusão S-3000."
		Case cOpcValid == "001102"
			cString := STR1102 //"Registro não pode ser excluído, pois o evento de exclusão já se encontra na base do RET."
		Case cOpcValid == "001103"
			cString := STR1103 //"Se {cadIni} = [N], deve ser igual ou posterior à data de início da obrigatoriedade dos eventos não periódicos para o empregador no eSocial."
		Case cOpcValid == "001104"
			cString := STR1104 //"Se {cadIni} = [N], deve ser anterior à data da transferência do empregado ({sucessaoVinc\dtTransf} ou {transfDom\dtTransf}). Não informar se {tpAdmissao} = [1]."
		Case cOpcValid == "001105"
			cString := STR1105 //"O preenchimento é obrigatório se {tpEvento} corresponder a um dos dos eventos não periódicos (S-2190 a S-2400), ou um dos eventos periódicos (S-1200, S-1202 ou S-1210)."
		Case cOpcValid == "001106"
			cString := STR1106 //"O campo não pode ser preenchido se {tpEvento} for diferente dos eventos não periódicos (S-2190 a S-2400), ou um dos eventos periódicos (S-1200, S-1202 ou S-1210)."
		Case cOpcValid == "001107"
			cString := STR1107 //"O preenchimento é obrigatório se {tpEvento} corresponder a um dos eventos periódicos (S-1200 a S-1280 e S-1300)."
		Case cOpcValid == "001108"
			cString := STR1108 //"O campo não pode ser preenchido se {tpEvento} for diferente dos eventos periódicos (S-1200 a S-1280 e S-1300)."
		Case cOpcValid == "001109"
			cString := STR1109 //"N (se {dtTerm} for anterior ao início de obrigatoriedade dos eventos periódicos para o empregador E {tpAmb} = [1]) OC (nos demais casos)."
		Case cOpcValid == "001110"
			cString := STR1110 //"A Data de início do afastamento deve ser igual ou posterior à data de início do TSVE."
		Case cOpcValid == "001111"
			cString := STR1111 //"A Data do término deve ser igual ou posterior à data de início do TSVE."
		Case cOpcValid == "001112"
			cString := STR1112 //"Deve ser um código existente na tabela de motivo de afastamento temporário."
		Case cOpcValid == "001113"
			cString := STR1113 //"Opções válidas no {cadIni} = [S] ou [N]."
		Case cOpcValid == "001114"
			cString := STR1114 //"A Identificação do Estabelecimento/Lotação {ideEstabLot} é obrigatório se houver demonstrativo de valores {dmDev} informado."
		Case cOpcValid == "001115"
			cString := STR1115 //"As informações relativas às Verbas Rescisórias do trabalhador {detVerbas} é obrigatório se houver a identificação do Estabelecimento/Lotação {ideEstabLot} informado."
		Case cOpcValid == "001116"
			cString := STR1116 //"A remuneração recebida pelo trabalhador em outras empresas ou atividades {remunOutrEmpr} é obrigatório se houver Múltiplos Vínculos {infoMV} informado."
		Case cOpcValid == "001117"
			cString := STR1117 + Chr(13) + Chr(10) + STR1118 //Este registro de exclusão, já foi transmitido ao governo. Não será possível altera-lo, somente visualiza-lo.
		Case cOpcValid == "001119"
			cString := STR1119 //"Não é permitido incluir extemporâneo para eventos não trasmitidos com sucesso ao RET."
		Case cOpcValid == "001120"
			cString := STR1120 //"Se {tpProc} = [1], o número de processo/benefício deve possuir 17 (dezessete) ou 21 (vinte e um) algarismos."
		Case cOpcValid == "001121"
			cString := STR1121 //"Se {tpProc} = [2], o número de processo/benefício deve possuir 20 (vinte) algarismos."
		Case cOpcValid == "001122"
			cString := STR1122 //"Se {tpProc} = [3], o número de processo/benefício deve possuir 10 (dez) algarismos."
		Case cOpcValid == "001123"
			cString := STR1123 //"Se {tpProc} = [4], o número de processo/benefício deve possuir 16 (dezesseis) algarismos."
		Case cOpcValid == "001124"
			cString := STR1124 //"O preenchimento é obrigatório se for maior de 8 anos."
		Case cOpcValid == "001125"
			cString := STR1125 //"Este campo só é obrigatório quando a ({dtDeslig} for anterior ao início de obrigatoriedade dos eventos periódicos para o empregador."
		Case cOpcValid == "001126"
			cString := STR1126 //"Só pode ser utilizada rubrica cujo {codIncIRRF} em S-1010 seja igual a [00, 01, 09, 13, 33, 43, 46, 53, 63, 75, 93]."
		Case cOpcValid == "001127"
			cString := STR1127 //"Caso haja registro de término, não deve haver regsitro de afastamento preenchido"
		Case cOpcValid == "001128"
			cString := STR1128 //"Caso haja registro de afastamento, não deve haver regsitro de término preenchido"
		Case cOpcValid == "001129"
			cString := STR1129 //"Nos casos de sucessão, a data da transferência do trabalhador, informada no campo {sucessaoVinc/dtTransf}, não pode ser superior a 30 (trinta) dias a partir da data atual."
		Case cOpcValid == "001130"
			cString := STR1130 //"Caso haja registro de afastamento, não deve haver registro de desligamento preenchido"
		Case cOpcValid == "001131"
			cString := STR1131 //"Caso haja registro de desligamento, não deve haver registro de afastamento preenchido"
		Case cOpcValid == "001132"
			cString := STR1132 //"Se {indApuracao} for igual a [2] (décimo terceiro salário), são permitidas apenas as rubricas cujo {codIncCP} da tabela de Rubricas seja igual a [00, 01, 12, 22, 26, 32, 92, 94] e cujo {codIncIRRF} seja igual a [00, 01, 09, 12, 14, 32, 42, 47, 52, 62, 64, 71, 77, 81, 82, 83, 92]."
		Case cOpcValid == "001133"
			cString := STR1133 //"Se {tpProc} = [1,4], deve ser preenchido com os códigos [03, 14, 90, 92]."
		Case cOpcValid == "001134"
			cString := STR1134 //"Se {tpProc} = [2], deve ser preenchido com [01, 02, 04, 05, 08, 09, 10, 11, 12, 13, 90, 92]."
		Case cOpcValid == "001135"
			cString := STR1135 //"Deve ser uma certidão de óbito válida, de acordo com o padrão de certidões estabelecido para Registro Civil das Pessoas Naturais. O 15° dígito deve ser igual a [4, 7]."
		Case cOpcValid == "001136"
			cString := STR1136 //"Deve ser um número de processo judicial válido e existente na Tabela de Processos (S-1070), com {indMatProc} = [1,7]."
		Case cOpcValid == "001137"
			cString := STR1137 //"Registro não pode ser alterado. Este funcionário encontra-se transferido para outra Filial."
		Case cOpcValid == "001138"
			cString := STR1138 //"Não foi localizado evento de informações cadastrais do contribuinte, verifique o cadastro de complemento de empresa e efetue a apuração do evento R-1000."
		Case cOpcValid == "001139"
			cString := STR1139 //"O período de validade de informações cadastrais do contribuinte não está de acordo com o período do evento, ou seja, o período do evento deve estar compreendido entre o {iniValid} e {fimValid} do evento de informações do contribuinte. Verifique o cadastro de complemento de empresa e efetue uma nova apuração do evento R-1000."
		Case cOpcValid == "001140"
			cString := STR1140 //"A data da ordem de produção deve ser superior à data inicial do período de apuração – campo DT_INI do Registro K100."
		Case cOpcValid == "001141"
			cString := STR1141 //"Se o tipo de processo for 'Administrativo', o indicativo de suspensão deve ser preenchido com [03, 14, 92]."
		Case cOpcValid == "001142"
			cString := STR1142 //"Se o tipo de processo for 'Judicial', o indicativo de suspensão deve ser preenchido com [01, 02, 04, 05, 08, 09, 10, 11, 12, 13, 90, 92]. "
		Case cOpcValid == "001143"
			cString := STR1143 //"Se o tipo de processo for 'Processo FAP', o indicativo de suspensão deve ser preenchido com [14]."
		Case cOpcValid == "001144"
			cString := STR1144 //"Para a categoria [104] (doméstico), se a data de admissão é igual ou posterior a 01/10/2015, a data de opção deve ser igual à data de admissão!"
		Case cOpcValid == "001145"
			cString := STR1145 //"Para a categoria [104] (doméstico), se a data de admissão é entre 01/03/2000 e 30/09/2015, a data de opção deve ser entre a data de admissão e 01/10/2015!"
		Case cOpcValid == "001146"
			cString := STR1146 //"Para a categoria [104] (doméstico), se a data de admissão é anterior a 01/03/2000, a data de opção deve ser entre 01/03/2000 e 01/10/2015!"
		Case cOpcValid == "001147"
			cString := STR1147 //"A identificação de demonstrativo de valores é uma informação obrigatória e não foi informada"
		Case cOpcValid == "001148"
			cString := STR1148 //"O Mês/Ano de apuração deve ser maior ou igual a Maio de 2018, data de início da obrigatoriedade do envio do evento ao e-Social"
		Case cOpcValid == "001149"
			cString := STR1149	//"A Data do óbito no CAT deve ser igual ou maior a data do acidente" 
		Case cOpcValid == "001150"
			cString := STR1150	//"O CPF do trabalhador informado no evento deve existir na base de dados do RET, exceto se o evento for referente à um TSVE e de uma competência anterior ao início de obrigatoriedade dos eventos periódicos."
		Case cOpcValid == "001151"
			cString := STR1151	//"Se o 'Código do Motivo de Afastamento' (Tag {codMotAfast} - Título Id.Mot.Afast - Campo CM6_MOTVAF) for igual a [01,03,35], o preenchimento do grupo Informações do Atestado ('infoAtestado') é obrigatório."
		Case cOpcValid == "001152"
			cString := STR1152	//"Se possui PLR na Remuneração do Trabalhador (Tag {remunPerApur} - Campo C8R_NATRUB = '000033'), deve haver ao menos uma rúbrica do tipo Vencimento (Tag {tpRubr} - Campo C8R_INDTRB, = '1') e Código de Incidência Tributária de IRRF (Cd.Inc.Tr.IR) referente 'Base de Cálculo do IRRF - PLR' (Tag {codIncIRRF} = [14] - Campo C8R_CINTIR = '000005')."
		Case cOpcValid == "001153"
			cString := STR1153 //"Só é permitida Remuneração para trabalhador que esteja em 'quarentena' quando a Data do Final da Quarentena (Tag {dtFimQuar} - Campo CMD_DTQUA) for superior ou igual ao período de apuração indicado no evento de remuneração (Campo C91_PERAPU - último dia do mês)."
		Case cOpcValid == "001154"
			cString := STR1154 //"Para trabalhadores com categoria igual a [410], o {TpRegPrev} relativo ao contrato com a empresa cedente/de origem deve ser igual a [1] ou [3] e, caso {TpRegPrev} = [3] a categoria do trabalhador na empresa cedente/de origem deve ser diferente de 301|302|303|304|305|306|307|308|309"
		Case cOpcValid == "001155"
			cString := STR1155 //"Para trabalhadores com categoria igual a [410], o {TpRegPrev} relativo ao contrato com a empresa cedente/de origem deve ser igual a [2] ou [3] e, caso {TpRegPrev} = [3] a categoria do trabalhador na empresa cedente/de origem deve ser igual a 301|302|303|304|305|306|307|308|309"
		Case cOpcValid == "001156"
			cString := STR1156 //"Para trabalhadores com categoria igual a [301|302|303|304|305|306|307|308|309|410] , o {TpRegPrev} deve ser igual a [2] ou [3]"
		Case cOpcValid == "001157"
			cString := STR1157 //"Para rúbricas com o código de incidência tributária para Previdência Social {codIncCP} igual a 34 ou 35, não é permitido a utilização para trabalhador beneficiário com categoria Avulsa ou segurado empregado (códigos 201 ou 202)"
		Case cOpcValid == "001158"
			cString := STR1158 //"Para rúbricas com o código de incidência tributária para Previdência Social {codIncCP} igual a 12, 21, 22, 32, 51, 92, 93 ou 94, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701,711,712,721,722,723,731,734,738,741,751,761 ou 781"
		Case cOpcValid == "001159"
			cString := STR1159 //"Para rúbricas com o código de incidência tributária para IRRF {codIncIRRF} igual a 12,13,32,33,42,43,47,52,53,62,63,64,71,92 ou 93, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701,711,721,722,723,731,734,738,741,751,761 ou 781"
		Case cOpcValid == "001160"
			cString := STR1160 //"Para rúbricas com o código de incidência tributária para Previdência Social {codIncCP} igual a 34 ou 35, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701,721,722,723,731,738,741,751,761,771 ou 781"
		Case cOpcValid == "001161"
			cString := STR1161 //"Para rúbricas com o código de incidência tributária para Previdência Social {codIncCP} igual a 31 e estabelicimento com classificação fiscal igual a 21 ou 22, não é permitido a utilização da mesma para trabalhador contribuinte individual (7XX)"
		Case cOpcValid == "001162"
			cString := STR1162 //"Para trabalhador com categoria igual à estagiário, não podem ser aceitas rubricas cujo {codIncCP} seja diferente de 00 e 01 ou {codIncFGTS} seja diferente de [00]"
		Case cOpcValid == "001163"
			cString := STR1163 //"Campo vazio ou inscrição inexistente na tabela de estabelecimentos (TAFA253 - Evento S-1005)"
		Case cOpcValid == "001164"
			cString := STR1164 //"O campo deve ser igual ou posterior a data de inicio da obrigatoriedade dos eventos de SST"
		Case cOpcValid == "001165"
			cString := STR1165 //Se T04_LOCAMB (Local Amb) 1 ou 3, o campo tipo de inscrição nao pode ser CPF (2).
		Case cOpcValid == "001166"
			cString := STR1166 //Número de inscrição não válido. Deve ser um registro que não consta na tabela S-1005 (Tabela de Estabelecimentos e Obras).
		Case cOpcValid == "001167"
			cString := STR1167 //"Não deve ser preenchido se o motivo do desligamento for diferente de '10'."
		Case cOpcValid == "001168"
			cString := STR1168 //"Para rúbricas com o código de incidência tributária para IRRF {codIncIRRF} igual a 14,34,54 ou 94, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701, 711, 712, 741, 751 ou 781."
		Case cOpcValid == "001169"
			cString := STR1169 //"Se {codCateg} = [101, 102, 103, 105, 106, 111], não pode ser preenchido com [2]."
		Case cOpcValid == "001170"
			cString := STR1170 //"Se {categOrig} for relativa a Empregado, não pode ser preenchido com [2]."
		Case cOpcValid == "001171"
			cString := STR1171 //"Se {nrRecCatOrig} for informado, deve existir no RET e ser relativo ao trabalhador (CPF + matrícula, no caso de empregado; ou CPF + categoria, no caso de TSVE)."
		Case cOpcValid == "001172"
			cString := "Não é permitida a utilização dos códigos 402-2 e 412-0."
		Case cOpcValid == "001173"
			cString := "Não preencher se ({classTrib} <> [07, 08, 21])."
		Case cOpcValid == "001174"
			cString := STR1174 //Se Tp. Admissão for igual a (6) é obrigatório o preenchimento do registro de Sucessão de Vínculo Trabalhista.
		Case cOpcValid == "001175"
			cString := STR1175 //(CUP_OBJDET) {objDet} O preenchimento é obrigatório e exclusivo se (CUP_TPCONT) {tpContr} = [3]. 
		Case cOpcValid == "001176"
			cString := STR1176  //Campo {tpInscAnt} Inconsistente ou Vazio
		Case cOpcValid == "001177"
			cString := STR1177  //Conteúdo do campo {tpInscAnt} não condiz com as opções possíveis, 1-Sim / 2-Não.
		Case cOpcValid == "001178"
			cString := STR1178  //Campo {cnpjEmpregAnt} CNPJ não corresponde com a quantidade de caracteres (14).
		Case cOpcValid == "001179"
			cString := STR1179  //Número de inscrição {cnpjEmpregAnt} inválido, já existe registro no evento S-1005 com o mesmo número de inscrição.
		Case cOpcValid == "001180"
			cString := STR1180  //Campo {cnpjEmpregAnt} CPF não corresponde com a quantidade de caracteres (11). 
		Case cOpcValid == "001181"
			cString := STR1181  //Conteúdo do campo {tpInscAnt} somente pode ser 5-CGC se {dtTransf} for igual ou anterior a 01/07/1998.  
		Case cOpcValid == "001182"
			cString := STR1182  //"{pensAlim} Informação obrigatória se {codCateg} = [201, 202, 721]. "  
		Case cOpcValid == "001183"
			cString := STR1183  //"{pensAlim} Valores válidos: 0, 1, 2, 3."  
		Case cOpcValid == "001184"
			cString := STR1184  //"{percAliment}  Deve ser maior que 0 (zero) e menor ou igual a 100 (cem). "
		Case cOpcValid == "001185"
			cString := STR1185  //"{percAliment} Informação obrigatória se {pensAlim} = [1,3]. Não pode ser preenchido nos demais casos."
		Case cOpcValid == "001186"
			cString := STR1186  //"{vrAlim} Informação obrigatória se {pensAlim} = [2,3]. Não pode ser preenchido nos demais casos."
		Case cOpcValid == "001187"
			cString := STR1187  //"{clauAssec} O preenchimento é obrigatório se {tpContr} = [2]. Não preencher se {tpContr} = [1]."
		Case cOpcValid == "001188"
			cString := STR1188  //"{clauAssec} Não preencher se {tpContr} = [1] "
		Case cOpcValid == "001189"
			cString := STR1189 //"A data informada deve ser maior que 01/01/1890 e anterior à data atual"
		Case cOpcValid == "001190"
			cString := STR1190 //"O Preenchimento do campo CEP é Obrigatório quando o Tipo de Local de Acidente é igual a 1,3 ou 5"
		Case cOpcValid == "001191"
			cString := STR1191 //"O Preenchimento do campo Cod. Municipio é Obrigatório quando o Tipo de Local de Acidente é igual a 1, 3, 4 ou 5"
		Case cOpcValid == "001192"
			cString := STR1192 //"O Preenchimento do campo UF é Obrigatório quando o Tipo de Local de Acidente é igual a 1, 3, 4 ou 5"
		Case cOpcValid == "001193"
			cString := STR1193 //"O Preenchimento do campo País é Obrigatório quando o Tipo de Local de Acidente é igual a 2"
		Case cOpcValid == "001194"
			cString := STR1194 //"Deve representar neste campo o tipo de logradouro, conforme tabela 20"
		Case cOpcValid == "001195"
			cString := STR1195 //"Deve ser um CPF válido."
		Case cOpcValid == "001196"
			cString := STR1196 //"A matrícula deve corresponder à informada pelo empregador no evento S-2200 do respectivo vínculo trabalhista."
		Case cOpcValid == "001197"
			cString := STR1197 //"Identificar a atividade desempenhada dentre as descritas na Tabela 28"
		Case cOpcValid == "001198"
			cString := STR1198 //"Não informar se tpAval = 2."
		Case cOpcValid == "001199"
			cString := STR1199 //"Somente preencher se tpAval = 1 e codFatRis = 02.01.687 ou 02.01.788."
		Case cOpcValid == "001200"
			cString := STR1200 //"Preenchimento obrigatório se tpAval = 1. Não informar se tpAval = 2. "
		Case cOpcValid == "001201"
			cString := STR1201 // "Preenchimento obrigatório se tpAval = 1 e codFatRis = 02.01.687 ou 02.01.788."
		Case cOpcValid == "001202"
			cString := STR1202 // "Preenchimento obrigatório se {tpAval} = [1]"
		Case cOpcValid == "001203"
			cString := STR1203
		Case cOpcValid == "001204" 
			cString := STR1204 // "O grupo de informações {ideProfResp} é de preenchimento obrigatório quando a tag {codTreiCap} for diferente dos valores: 1006 ou 1207."
		Case cOpcValid == "001205"
			cString := STR1205 // "Esse campo não deve ser preenchido quando a tag {codTreiCap} for igual a 1006 ou 1207."
		Case cOpcValid == "001206"
			cString := STR1206 // "Preenchimento obrigatório e exclusivo se {utilizEPC} = [2]"
		Case cOpcValid == "001209"
			cString := STR1209 // "Existe um evento S-2206 transmitido, portanto o evento S-2200 não pode ser retificado. É necessário realizar a exclusão do evento S-2206."
		Case cOpcValid == "001210"
			cString := STR1210 // "Em caso de Reabertura/Óbito, a CAT só deve ser enviada através do E-Social se a data da ocorrência for superior a Julho/2019."
		Case cOpcValid == "001211"
			cString := STR1211 // "O preenchimento é obrigatório se {depIRRF} = [S]."
		Case cOpcValid == "001212"
			cString := STR1212 // Campo {cnpjEmpregAnt} CNPJ não corresponde com a quantidade de caracteres (12).
		Case cOpcValid == "001213"
			cString := STR1213 // Conteúdo do campo {tpInscAnt} somente pode ser 6-CEI se {dtTransf} for igual ou anterior a 31/12/2011.
		Case cOpcValid == "001214"
			cString := STR1214 //A Data de Admissão deve ser maior ou igual a [22/01/1998] para a categoria [105] (contrato a termo firmado nos termos da Lei 9601/98).
		Case cOpcValid == "001215"
			cString := STR1215 //A Data de Admissão deve ser igual ou anterior a [20/04/2020] para categorias [107] e [108].
		Case cOpcValid == "001216"
			cString := STR1216 //Registro posicionado não pode ser um S-2200 ou S-2300
		Case cOpcValid == "001217"
			cString := STR1217 //"Última alteração cadastral (S-2205) ou contratual (S-2206 ou S-2306) não pode ser retificada via extemporâneo!"

	EndCase

Return( cString )

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldFormDt
Validacao do Formato da data

@Param:
cData - A data que deseja validar o formato.
cFormato - O formato esperado (MMAAAA/AAAA)

@Return:
lRet - Indica o resultado das comparacoes

@author Leandro Prado
@since 05/08/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function xVldFormDt( cData, cFormato )

Local cMes	:=	""
Local lRet	:=	.T.

If Len(AllTrim(cData)) == Len(AllTrim(cFormato))
	If cFormato == "MMAAAA"
		// Se o formato for MMAAAA verifico se o mês está compreendido entre 01 e 12
		cMes := Substr(cData,1,2)
		If (Val(cMes) < 1) .Or. (Val(cMes) > 12)
			lRet := .F.
		EndIf
	ElseIf cFormato == "AAAAMM"
		// Se o formato for AAAAMM verifico se o mês está compreendido entre 01 e 12
		cMes := Substr(cData,5,2)
		If (Val(cMes) < 1) .Or. (Val(cMes) > 12)
			lRet := .F.
		EndIf
	EndIf
Else
	// Se o tamanho do formato e da data informada forem diferentes já retorna falso.
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetIniESocial

Retorna data de inicio da empresa no eSocial, com base no parâmetro MV_TAFINIE.
Se o parâmetro não existir ou não estiver preenchido, assume a data prevista de inicio
do eSocial informada pelo Governo.

@param
lAlert	->	Informa se deseja alerta o usuário sobre a ausência do parâmetro MV_TAFINIE

@Return:
dDtIniESocial - Data de inicio da empresa no eSocial

@author Luccas Curcio
@since 26/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
function TAFGetIniESocial( lAlert )

Local cMvDate		:=	""
Local dDtIniEsocial	:=	CToD( '  /  /  ' )

Default lAlert	:=	.F.

if empty( cMvDate := getNewPar( 'MV_TAFINIE' , '' ) )

	if lAlert
		MsgInfo( STR0963 + '01/01/2018.' , STR0964 ) //'O parâmetro MV_TAFINIE (Data de Inicio da Empresa do eSocial) não foi encontrado no ambiente, por este motivo a data padrão assumida pelo sistema será ' ## 'Data de Inicio eSocial'
	endif

	dDtIniEsocial := SToD( "20180101" ) //Data prevista para o início do eSocial.
else
	dDtIniEsocial := SToD( cMvDate )
endif

return dDtIniEsocial

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetIniNPeriod

Retorna data de inicio da empresa no eSocial, com base no parâmetro MV_TAFININ.
Se o parâmetro não existir ou não estiver preenchido, assume a data de início
da obrigatoriedade dos eventos não periódicos para o empregador.

@param
lAlert	->	Informa se deseja alerta o usuário sobre a ausência do parâmetro MV_TAFININ

@Return:
dDtIniNPeriod - Data de início não periódico

@author Denis Naves
@since 01/12/2017
@version 1.0

/*/
//-------------------------------------------------------------------
function TAFGetIniNPeriod( lAlert )

Local cMvDate		:=	""
Local dDtIniNPeriod	:=	CToD( '  /  /  ' )

Default lAlert	:=	.F.

if empty( cMvDate := getNewPar( 'MV_TAFININ' , '' ) )

	if lAlert
		MsgInfo( STR1085 + '01/03/2018.' , STR1086 ) //'O parâmetro MV_TAFININ (Data de Inicio da obrigatoriedade dos eventos não periódicos para o empregador.) não foi encontrado no ambiente, por este motivo a data padrão assumida pelo sistema será ' ## 'Data de Inicio eventos não periódicos'
	endif

	dDtIniNPeriod := SToD( "20180301" ) //Data prevista para o início dos eventos não periódicos.
else
	dDtIniNPeriod := SToD( cMvDate )
endif

return dDtIniNPeriod

//-------------------------------------------------------------------
/*/{Protheus.doc} xIniESoc

Retorna data base de início dos eventos não periódicos

@return:
dIniNPer - Data base definida para implantacao do início dos eventos não periódicos

@author Denis Naves
@since 01/12/2017
@version 1.0
/*/
function xIniNPer()

return( dIniNPer )
