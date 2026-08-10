#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFXFUNDIC.CH"

Static __aAliasInDic
Static __aIdIndex
Static __cFilTrab  := Nil
Static __lLay0205  := TafLayESoc("02_05_00")
Static cRetNTrab   := ""
Static lLaySimplif := TafLayESoc("S_01_00_00")
Static lSimpl0103  := TAFLayESoc("S_01_03_00",.T.,.T.)


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXFUNDIC
Fonte com funçoes genericas do TAF relacionadas a dicionario de dados

@author Denis R. de Oliveira
@since 13/08/2015
@version 1.0

@Return ( Nil )

/*/       
                                                                                                                              
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAlsInDic

Indica se um determinado alias está presente no dicionário de dados

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@return lRet  - .T. -> Validacao OK
				  .F. -> Nao Valido

/*/
//---------------------------------------------------------------------
Function TAFAlsInDic( cAlias as Character, lHelp as Logical )

	Local aArea    as Array
	Local aAreaSX2 as Array
	Local aAreaSX3 as Array
	Local lRet     as Logical
	Local nAt      as Numeric

	Default __aAliasInDic := {}

	aArea    := {}
	aAreaSX2 := {}
	aAreaSX3 := {}
	lRet     := .F.
	nAt      := Ascan( __aAliasInDic, {|x| x[1]==cAlias})

	If ( nAt == 0 )

		aArea		:= GetArea()
		aAreaSX2	:= SX2->( GetArea() )
		aAreaSX3	:= SX3->( GetArea() )
		
		Default lHelp	:= .F.
		
		SX2->( DbSetOrder( 1 ) )
		SX3->( DbSetOrder( 1 ) )
		
		lRet := ( SX2->( dbSeek( cAlias ) ) .And. SX3->( dbSeek( cAlias ) ) )

		Aadd(__aAliasInDic, {cAlias,lRet})
		
		SX3->( RestArea( aAreaSX3 ) )
		SX2->( RestArea( aAreaSX2 ) )
		RestArea( aArea )

	Else 

		lRet := __aAliasInDic[nAt][2]

	EndIf

	If !lRet .And. lHelp
		Help( "", 1, "ALIASINDIC",,cAlias )
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafColumnPos
Verifica se existe o campo no dicionário de dados levando em consideração a versão corrente do release
do cliente.


@Author	Rodrigo Aguilar
@Since		01/12/2015
@Version	1.0

@return lFindCmp ( Indica se o campo existe ou não no dicionário de dados )

/*/
//---------------------------------------------------------------------
Function TafColumnPos( cCampo )

	Local cReleaseAtu := Substr( alltrim( GetRpoRelease() ), 1, 2 )
	Local cAliasAtu   := Substr( alltrim( cCampo ), 1, 3 ) 
	Local lFindCmp    := .F.

	//De acordo com a versão corrente do release do cliente utilizo a funçao correta para saber se o campo
	//existe ou não no dicionário de dados
	if (TAFAlsInDic(cAliasAtu))
		dbSelectArea( cAliasAtu )
		if  cReleaseAtu <> '12'
			lFindCmp := ( FieldPos( cCampo ) > 0 )  
		else
			lFindCmp := ( ColumnPos( cCampo ) > 0 )
		endif
	endIf

Return ( lFindCmp )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafIndexInDic
Verifica se existe o indice no dicionário de dados e no banco de dados

@param	cAlias		-> Alias da tabela
@param	uIdIndex	-> Número ou Id caracter do indice

@Author	Felipe Rossi Moreira
@Since		12/01/2018
@Version	1.0

@return lRet (indica se existe o indice e pode ser usado)

/*/
//---------------------------------------------------------------------
Function TafIndexInDic(cAlias, uIdIndex, lHelp)

	Local lRet := .F.
	Local cIndex := ""
	Local cAliasSQLName := ""

	Default lHelp := .F.

	if TAFAlsInDic(cAlias, lHelp)
		//Verifica o Id do indice e converte para formato caracter caso numérico
		if ValType(uIdIndex) == 'C'
			cIndex := uIdIndex
		elseif ValType(uIdIndex) == 'N'
			if uIdIndex > 9
				cIndex := Chr(65+uIdIndex-10)
			else
				cIndex := AllTrim(Str(uIdIndex))
			endif
		endif

		//Nome da tabela no banco para validação da existência do indice no banco de dados
		cAliasSQLName := RetSQLName(cAlias)

		//lRet := !Empty(cIndex) .and. !Empty(Posicione("SIX",1,cAlias+cIndex,"CHAVE")) .and. TcCanOpen(cAliasSQLName,cAliasSQLName+cIndex)

		If TcCanOpen(cAliasSQLName,cAliasSQLName+cIndex)
			lRet := !Empty(cIndex) .and. !Empty(Posicione("SIX",1,cAlias+cIndex,"CHAVE"))
		Else
			DbSelectArea(cAlias)
			lRet := !Empty(cIndex) .and. !Empty(Posicione("SIX",1,cAlias+cIndex,"CHAVE")) .and. TcCanOpen(cAliasSQLName,cAliasSQLName+cIndex)
		EndIf

		If !lRet .And. lHelp
			MsgInfo( STR0069+CRLF+STR0070+cAlias+CRLF+STR0071+cIndex, STR0072 ) //"O seguinte indice não está disponível na dicionário de dados:" ## "Tabela: " ## "Indice: " ## "Ambiente Desatualizado!"
		EndIf
	endif

Return(lRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetIdIndex

Função que retorna a ordem do indice do ID conforme alias solicitado

@param	cAliasTAF	-> Alias do TAF
@param	cFieldId	-> Campo considerado ID

@Author		Luccas Curcio
@Since		06/04/2016
@Version	1.0

@return nIdIndex - Ordem do Indice do ID da tabeça

/*/
//---------------------------------------------------------------------
function TAFGetIdIndex( cAliasTAF , cFieldId )

	Local	nIdIndex	:=	0
	Local	nPosIndex	:=	0
	Local	aAreaSIX	:=	{}
	Local	nTamFldId	:=	0
	Local	nTamFldCod	:=	0 //Criação da variável que verifica o tamanho que o campo _CODIGO 
	Local	cFieldCodi	:=	"_CODIGO" //Criação da variável que verifica o nomedo campo que o campo que será o índice
	Local 	nPosic		:= 15

	Default	__aIdIndex	:=	{}
	Default	cFieldId	:=	"_ID"


	nTamFldId	:=	iif( cFieldId  == "_CHVNF" , 6 , 3 )
	nTamFldCod	:= 	iif( cFieldCodi == "_CODIGO" , 7 , 3 )//Definição de tamanho da varável que receberá o índice  

	If cAliasTAF $ 'C0A|C8A'
		//Caso o Alias seja C8A / Fpas, modifico o campo pois não existe _CODIGO
		If cAliasTAF == "C8A"
			cFieldCodi := "_CDFPAS"
			nTamFldCod := 7
		ElseIf cAliasTAF == "C0A"
			cFieldId := "_CODIGO"
			nTamFldId := 7
		EndIf

	ElseIf cAliasTAF $ 'V75|V76|V77|V78'
		nPosic 	 :=  22
		cFieldId := "_VERSAO"
		nTamFldId := 7	
	EndIf

	//Verifico se ja tenho em cache o indice deste alias
	If ( nPosIndex := aScan( __aIdIndex , { |x| x[1] == cAliasTAF } ) ) > 0
		nIdIndex	:=	__aIdIndex[ nPosIndex , 2 ]

	Else
		
		aAreaSIX	:=	SIX->( getArea() )
		
		//Caso o alias nao tenha sido utilizado anteriormente, posiciono no primeiro indice do Alias no dicionario SIX
		If SIX->( msSeek( cAliasTAF ) )
		
			//Procuro apenas nos indices do proprio alias
			While SIX->( !eof() ) .and. allTrim( SIX->INDICE ) == ( cAliasTAF )
				
				//Se encontrar algum indice que o segundo campo da chave seja o código posso sair do laço e utilizar este indice (DSERTAF2-777/DSERTAF2-776 
				//Todas os indices onde o segundo campo é CODIGO começam com: "XXX_FILIAL+XXX" e depois "_CODIGO" ( XXX_FILIAL+XXX_CODIGO ). Por isso procuro da posicao 11 em diante 
				If cAliasTAF $ ('C3Z|C1A|C6U|C8Z|C8A|CHY|C1U|T71|CUF|CMM') .And. !IsInCallStack("FAtuTabTAF")  
					If substr( SIX->CHAVE , 15 , nTamFldCod ) == cFieldCodi 
						nIdIndex	:=	val( SIX->ORDEM ) 
						//Guardo este alias e chave no array estático para agilizar futuras pesquisas do mesmo alias 
						aAdd( __aIdIndex , { cAliasTAF , nIdIndex } ) 
						Exit	 
					Endif 					
				Else			  
					//Se encontrar algum indice que o segundo campo da chave seja ID posso sair do laço e utilizar este indice
					//Todas os indices onde o segundo campo é ID começam com: "XXX_FILIAL+XXX" e depois "_ID" ( XXX_FILIAL+XXX_ID ). Por isso procuro da posicao 15 em diante
					If substr( SIX->CHAVE , nPosic , nTamFldId ) == cFieldId
						nIdIndex	:=	val( SIX->ORDEM )
						//Guardo este alias e chave no array estático para agilizar futuras pesquisas do mesmo alias
						aAdd( __aIdIndex , { cAliasTAF , nIdIndex } )
						Exit
					Endif
				Endif 
				SIX->( dbSkip() )
			Enddo
		Endif
		
		restArea( aAreaSIX )
		
	Endif

Return nIdIndex

//---------------------------------------------------------------------
/*/{Protheus.doc} TafVldAmb
Função tem como objetivo realizar a validação do dicionário de dados, verificando se o TAF
esta em uma versão compatível com a execução da integração Online.

Para a versão 12 essa função não tem sentido pois sempre que utilizada a integração online
o dicionário do cliente estará atualizado devido a execução do upddistr, porém com a nova estruturação 
dos fontes o módulo SIGAFIS irá possuir fontes únicos (MATXFIS, por exemplo), assim devemos manter 
a função para que na versão 12 sempre retorne .T., indicando que o dicionário está atualizado.

@Author     Rodrigo Aguilar
@Since       10/10/2016
@Version    1.0

@param cEscopo   - Compatibilidade com a versão 11
       cIdentity - Compatibilidade com a versão 11 

@return .T. 

/*/
//---------------------------------------------------------------------
Function TafVldAmb( cEscopo , cIdentity )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} TafAmbInvMsg

Retorna mensagem padrão informando que o ambiente TAF está desatualizado.

@Return	cMensagem

@Author	Anderson Costa
@Since		01/12/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafAmbInvMsg()

	Local cEnter		
	Local cMensagem	
	Local cVersion	

	cEnter		:=	Chr( 13 ) + Chr( 10 )
	cMensagem	:=	""
	cVersion	:=	SubStr( GetRpoRelease(), 1, 2 )

	cMensagem := STR0001 + cEnter + cEnter //"Inconsistência:"
	cMensagem += STR0002 + cEnter + cEnter //"O ambiente do TAF está com o dicionário de dados incompatível com a versão dos fontes existentes no repositório de dados, este problema ocorre devido a não execução dos compatibilizadores do produto."

	If cVersion == "11"
		cMensagem += STR0003 + cEnter + cEnter //"Será necessário executar o UPDDISTR e em seguida o UPDTAF com o último arquivo diferencial ( SDFBRA ) disponível no portal do cliente."
	ElseIf cVersion == "12"
		cMensagem += STR0007 + cEnter + cEnter //"Será necessário executar o UPDDISTR com o último arquivo diferencial ( SDFBRA ) disponível no portal do cliente."
	EndIf

	cMensagem += STR0004 + cEnter //"Siga as instruções do link abaixo para realizar a atualização:"

	If cVersion == "11"
		cMensagem += STR0005 + cEnter + cEnter //"http://tdn.totvs.com.br/pages/releaseview.action?pageId=187534210"
	ElseIf cVersion == "12"
		cMensagem += STR0008 + cEnter + cEnter //"http://tdn.totvs.com.br/pages/releaseview.action?pageId=198935223"
	EndIf

	cMensagem += STR0006 + cEnter //"Após seguir os passos acima o acesso ao TAF será liberado!"

Return( cMensagem )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafLock
Função criada para realizar a gravação das tabelas do TAF, ou seja, em termos práticos
ela substitui o RECLOCK(), realizando o controle de concorrência de gravação na tabela
que sera manutenida.

Conceito:

Gravação sem lSimpleLock: O próprio Reclock() trava o usuário na tela dizendo que o registro a ser
alterado está preso com outro usuário, a cada 5 segundos tenta novamente realizar a operação e assim
fica até conseguir efetivar a operação.

Gravação com lSimpleLock: São realizadas 5 tentativas de reservar o registro na tabela com simplelock(), tratar
o retorno como da função para saber se o registro está reservado ou não

@Author  Rodrigo Aguilar
@Since   11/11/2016
@Version 1.0

@param cAlias       - Alias a ser gravado/alterado
        lInclui      - .T. - Inclui/ .F. Altera/Exclui 
        lSimpleLock  - Indica se deve realizar o simplelock antes do reclock

@return .T. 

/*/
//---------------------------------------------------------------------
Function TafLock( cAlias, lInclui, lSimpleLock ) 

	Local lLock  := .F.
	Local nLock  := 0

	//---------------------------------------------------
	//Realizo a tentativa de reservar o registro 5 vezes
	//---------------------------------------------------
	for nLock := 1 to 5

		//Quando o processamento não possuir tela verifico com simplelock se conseguirei reservar o Alias
		//a ser reservado e se a operação é de Alteração/Exclusão	
		if lSimpleLock .and. !lInclui
			if ( lLock := ( cAlias )->( SimpleLock() ) )
				RecLock( cAlias , lInclui )
			endIf
		//Para gravação em tela apenas realizo a operação desejada
		else
			RecLock( cAlias , lInclui )
			lLock := .T.
		endIf
		//Se nao conseguir fazer LOCK, aguarda um 1 segundo e tento de novo, esse tempo vai sendo exponencial a medida que for tentando.
		if !lLock
			Conout( 'TAF - Aguardando liberação do registro ( concorrencia ) ' +  alltrim( str( nLock ) ) )
			Sleep( 1000 * nLock )
		else
			exit
		endIf

	next nLock

Return lLock

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFObrVldEnv

Função que valida o ambiente para geração da obrigação fiscal

@param	aFields -> Campos que devem ser validados
@param	aTables -> Tabelas que devem ser validadas

@author Luccas Curcio
@since 21/11/2016
@version 1.0
/*/
//---------------------------------------------------------------------
function TAFObrVldEnv( aFields, aTables)

	Local	nX			
	Local	nOpc		
	Local	cCmpNoEx	
	Local	cTblNoEx	
	Local	cMsg		
	Local	lRet		

	Default	aFields	:=	{}
	Default	aTables	:=	{}

	nX		:=	0
	nOpc	:=	0
	cCmpNoEx:=	""
	cTblNoEx:=	""
	lRet	:=	.T.
	//"O sistema identificou a ausência de componentes neste ambiente que influenciam no resultado final do processo.
	//Para mais informações sobre a atualização de ambiente acesse: 
	//http://tdn.totvs.com/pages/viewpage.action?pageId=198935223."
	cMsg := STR0009 + STR0008 + CRLF + CRLF

	if !empty( aTables )

		for nX := 1 to len( aTables )
			
			//Verifico se a tabela existe no ambiente. Caso não exista adiciono na string que fará o alerta no final da função.
			if !( tafAlsInDic( aTables[ nX ] ) )
				cTblNoEx += aTables[ nX ] + "(" + allTrim( FWX2Nome( aTables[ nX ] ) ) + "), "
			endif
		
		next nX
		
		if !empty( cTblNoEx )

			//Retiro ", " do final da string
			cTblNoEx := subStr( cTblNoEx , 1 , len( cTblNoEx ) - 2 )
		endif
		
		cMsg += STR0010 + CRLF + CRLF + cTblNoEx + CRLF + CRLF //"Tabelas:"

	endif

	if !empty( aFields )

		for nX := 1 to len( aFields )
			
			//Verifico se o campo existe no ambiente. Caso não exista adiciono na string que fará o alerta no final da função.
			if !( tafColumnPos( aFields[ nX ] ) )
				cCmpNoEx += aFields[ nX ] + "(" + allTrim( FWX2Nome( subStr( aFields[ nX ] , 1 , 3 ) ) ) + "), "
			endif
		
		next nX
		
		if !empty( cCmpNoEx )
			//Retiro ", " do final da string
			cCmpNoEx := subStr( cCmpNoEx , 1 , len( cCmpNoEx ) - 2 )
		endif
		
		cMsg += STR0011 + CRLF + CRLF + cCmpNoEx + CRLF + CRLF //"Campos:"

	endif

	if !empty( cCmpNoEx ) .or. !empty( cTblNoEx )
		nOpc := tafAviso( STR0012 , cMsg  , { STR0013 , STR0014 } , 3 ) //"Ambiente desatualizado" ## "Continuar" ## "Encerrar"
	endif

	if nOpc == 2
		lRet :=	.F.
	endif

return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CboTpAdmiss()

Função que retorna as opções do CBO do evento S-2200

@author Ricardo Lovrenovic
@since 07/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboTpAdmiss()

	Local cString := ""

	cString := "1=" + STR0015 + ";" 							// "Admissão"
	cString += "2=" + IIf(!lLaySimplif, STR0016, STR0180) + ";" // "Transferência de empresa do mesmo grupo econômico" // "Transferência de empresa do mesmo grupo econômico ou transferência entre órgãos do mesmo Ente Federativo"
	cString += "3=" + STR0017 + ";" 							// "Transferência de empresa consorciada ou de consórcio"
	cString += "4=" + STR0018 + ";" 							// "Transferência por motivo de sucessão, incorporação, cisão ou fusão"
	cString += "5=" + STR0019 + ";" 							// "Transferência do empregado doméstico para outro representante da mesma unidade familiar"
	cString += "6=" + STR0083 + ";" 							// "Mudança de CPF"
	
	If lLaySimplif
		cString += "7=" + STR0181 + ";" 						// "Transferência quando a empresa sucedida é considerada inapta por inexistência de fato"
	EndIf
	
Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} CboTpRegJ

Função que retorna as opções do CBO do evento S-2200 e S-2206
Campos: CUP_TPREGJ e T1V_TPREGJ
Tag: tpRegJor
Definição: Identifica o regime de jornada do empregado

@author Ricardo Lovrenovic / Felipe Rossi Moreira
@since 07/11/2017 / 21/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboTpRegJ()

	Local cString 

	cString := "1="+STR0020+";" //"Submetidos a Horário de Trabalho (Cap. II da CLT)"
	cString += "2="+STR0021+";" //"Atividade Externa especificada no Inciso I do Art. 62 da CLT"
	cString += "3="+STR0022+";" //"Funções especificadas no Inciso II do Art. 62 da CLT"
	cString += "4="+STR0023 //"Teletrabalho, previsto no Inciso III do Art. 62 da CLT"

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} CbotpPgto

Função que retorna as opções do CBO do evento S-1210
Campos: T3Q_TPPGTO
Tag: tpPgto
Definição: Informar o tipo de pagamento

@author Felipe Rossi Moreira
@since 30/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CbotpPgto()

	Local cString 

	If !lLaySimplif

		cString := "1="+STR0024+";" // "Pagamento de remuneração, conforme apurado em {dmDev} do S-1200"
		cString += "2="+STR0025+";" // "Pagamento de verbas rescisórias conforme apurado em {dmDev} do S-2299"
		cString += "3="+STR0026+";" // "Pagamento de verbas rescisórias conforme apurado em {dmDev} do S-2399"
		cString += "5="+STR0027+";" // "Pagamento de remuneração conforme apurado em {dmDev} do S-1202"
		cString += "6="+STR0028+";" // "Pagamento de Benefícios Previdenciários, conforme apurado em {dmDev} do S-1207"
		cString += "7="+STR0029+";" // "Recibo de férias"
		cString += "9="+STR0030 	// "Pagamento relativo a competências anteriores ao início de obrigatoriedade dos eventos periódicos para o contribuinte"
	
	Else

		cString := "1="+STR0164+";" // "Pagamento de remuneração, conforme apurado em {ideDmDev} do S-1200"
		cString += "2="+STR0165+";" // "Pagamento de verbas rescisórias conforme apurado em {ideDmDev} do S-2299"
		cString += "3="+STR0166+";" // "Pagamento de verbas rescisórias conforme apurado em {ideDmDev} do S-2399"
		cString += "4="+STR0167+";" // "Pagamento de remuneração conforme apurado em {ideDmDev} do S-1202"
		cString += "5="+STR0168 	// "Pagamento de benefícios previdenciários, conforme apurado em {ideDmDev} do S-1207"

	EndIf

Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} CboIndCum

Função que retorna as opções do CBO do evento S-2299
Campos: CMD_INDCUM
Tag: indCumprParc
Definição: Indicador de cumprimento de aviso prévio:

@author Felipe Rossi Moreira
@since 19/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboIndCum()

	Local cString 

	cString := "0="+STR0031+";" //Cumprimento total
	cString += "1="+STR0032+";" //Cumprimento parcial em razão de obtenção de novo emprego pelo empregado
	cString += "2="+STR0033+";" //Cumprimento parcial por iniciativa do empregador
	cString += "3="+STR0034+";" //Outras hipóteses de cumprimento parcial do aviso prévio
	cString += "4="+STR0035		//Aviso prévio indenizado ou não exigível

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} CboCodAjus

Função que retorna as opções de combo do código de ajuste 
Campos: T9T_CODAJU
Tag: CodAjuste
Definição: Código de Ajuste da contribuição apurada no período

@author anieli.rodrigues
@since 29/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboCodAjus()
	
	Local cString 
	
	cString := "01="+STR0058+";" //Ajuste da CPRB: Adoção do Regime de Caixa
	cString += "02="+STR0059+";" //Ajuste da CPRB: Diferimento de Valores a recolher no período
	cString += "03="+STR0060+";" //Adição de valores Diferidos em Período(s) Anteriores(es)
	cString += "04="+STR0061+";" //Exportações diretas
	cString += "05="+STR0062+";" //Transporte internacional de cargas
	cString += "06="+STR0063+";" //Vendas canceladas e os descontos incondicionais concedidos
	cString += "07="+STR0064+";" //IPI, se incluído na receita bruta
	cString += "08="+STR0065+";" //ICMS, quando cobrado pelo vendedor dos bens ou prestador dos serviços na condição de substituto tributário
	cString += "09="+STR0066+";" //Receita bruta reconhecida pela construção, recuperação, reforma, ampliação ou melhoramento da infraestrutura, cuja contrapartida seja ativo intangível representativo de direito de exploração, no caso de contratos de concessão de serviços públicos
	cString += "10="+STR0067+";" //O valor do aporte de recursos realizado nos termos do art 6 §3 inciso III da Lei 11.079/2004
	cString += "11="+STR0068 //Demais ajustes oriundos da Legislação Tributária, estorno ou outras situações.

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} CboIndAqu

Função que retorna as opções de combo do indicativo de aquisição 
Campos: CMT_INDAQU
Tag: indAquis
Definição: Indicativo de aquisição de produto

@author ricardo.prandi	
@since 08/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboIndAqu()
	
	Local cString 
	
	cString := "1="+STR0073+";" //Aquisição produtor rural PF
	cString += "2="+STR0074+";" //Aquisição produtor rural PF por entidade PAA
	cString += "3="+STR0075+";" //Aquisição produtor rural PJ por entidade PAA
	cString += "4="+STR0076+";" //Aquisição produtor rural PF - Produção Isenta (Lei 13.606/2018)
	cString += "5="+STR0077+";" //Aquisição produtor rural PF por entidade PAA - Produção Isenta (Lei 13.606/2018)
	cString += "6="+STR0078     //Aquisição produtor rural PJ por Entidade PAA - Produção Isenta (Lei 13.606/2018)

Return(cString)


//---------------------------------------------------------------------
/*/{Protheus.doc} CboOrdExa

Função que retorna as opções de combo da Ordem do Exame
Campos: C9W_ORDEXA
Tag: ordExame
Definição: Ordem do Exame

@author Karyna.martins
@since 10/01/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboOrdExa()
	
	Local cString 
	
	If __lLay0205
		cString := "1="+STR0082+";" //Inicial		
	Else
		cString := "1="+STR0080+";" //Referencial
	EndIf

	cString += "2="+STR0081+";" //Sequencial
	
Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFPic

Ajusta a picture variável dos campos de período dos totalizadores 5003 e 5013, alterandno entre o formato MM-AAAA e AAAA.

@author Leandro.dourado
@since 12/02/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFPic( cCampo )

	Local cRet   := ""
	Local cValor := ""

	If cCampo $ 'V2P_PERAPU|V2Z_PERAPU'
		cValor := StrTran(AllTrim(FWFLDGET(cCampo)),"-","")
		
		If Empty(cValor)
			cValor := AllTrim(&(SubStr(cCampo,1,3) + "->" + cCampo))
		EndIf
		
		cRet := IIF(Len(cValor) == 6, '@R 99-9999', '@R 9999')
	EndIf

Return cRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} C9VHFil
Consulta Especifica de trabalhadores S-2190, S-2200,S-2205,S-2300 e TAUTO.

@author Henrique Cesar
@since 06/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Function C9VHFil(cEvtTrab as Character, cEvento as Character)

	Local aCols       as Array
	Local aColSizes   as Array
	Local aCoord      as Array
	Local aFil        as Array
	Local aHeader     as Array
	Local aSm0        as Array
	Local aWindow     as Array
	Local cAliasquery as Character
	Local cCall       as Character
	Local cCPF        as Character
	Local cFilTrab    as Character
	Local cFiltro     as Character
	Local cNome       as Character
	Local cNrinsc     as Character
	Local cQuery      as Character
	Local cTitulo     as Character
	Local cFilfab     as Character
	Local cComp       as Character
	Local lLGPDperm   as Logical
	Local nItem       as Numeric
	Local nX          as Numeric
	Local nXan        as Numeric
	Local oArea       as Object
	Local oButt1      as Object
	Local oButt2      as Object
	Local oButt3      as Object
	Local oList       as Object
	Local oListBox    as Object

	Default cEvtTrab  := ""
	Default cEvento   := ""

	Private __cEvtPos := ""

	aCols       := {}
	aColSizes   := { 35, 80, 25, 15 }
	aCoord      := {}
	aFil        := {}
	aHeader     := { "ID", "Nome", "CPF", "Evento" }
	aSm0        := FWLoadSM0()
	aWindow     := {}
	cAliasquery := GetNextAlias()
	cCall       := "C9VHFil"
	cCPF        := ""
	cFilTrab    := ""
	cFiltro     := Space(50)
	cNome       := ""
	cNrinsc     := ""
	cQuery      := ""
	cTitulo     := ""
	cFilfab     := FWCodFil()
	cComp       := VldTabTAF("C9V")
	lC9VDFil    := IsInCallStack("C9VDFil")
	lLGPDperm   := IIf(FindFunction("PROTDATA"),ProtData(),.T.)
	nItem       := 0
	nX          := 0
	nXan        := 0
	oArea       := Nil
	oButt1      := Nil
	oButt2      := Nil
	oButt3      := Nil
	oList       := Nil
	oListBox    := Nil
        
	__cFilTrab := UUIDRandomSeq()

	If cComp == "EEE"
		AaDD( aFil, FWCodFil()  )
	ElseIf cComp == "CEE"
		AaDD( aFil, FWxFilial("C9V",FWCodFil(), "E", "E", "C" ) )
	Else
		AaDD( aFil, FWxFilial("C9V",FWCodFil(), "C", "C", "C" ) )
	EndIf
				
	cFilTrab := TAFCacheFil("C9V",aFil,,, __cFilTrab)
	
	If Type("cNomEve") == "U" .Or. ValType(cNomEve) == "U"
		cEvento := IIf(IsInCallStack("TAFA413"), "S1202", IIF(IsInCallStack("TAFA608") .Or. IsInCallStack("TAF608Inc") , "S2500", ""))
	Else
		cEvento := cNomEve
	EndIf

	If Upper(ReadVar()) == 'CFILPERG01' .And. Type(ReadVar()) <> 'C'
		CFILPERG01 := Space(TamSX3('C9V_ID')[1])
	EndIf

	cRetNTrab := &(ReadVar())
	
	If Empty(cEvtTrab)
		
		cQuery := " SELECT C9V.C9V_FILIAL Filial, C9V.C9V_ID Id, C9V.C9V_NOME Nome, C9V.C9V_CPF CPF, C9V.C9V_NOMEVE AS EVENTO "
		cQuery += " FROM " + RetSQLName("C9V") + " C9V "
		cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' "
		cQuery += " AND C9V.C9V_FILIAL IN ( "
		cQuery += "				SELECT FILIAIS.FILIAL "
		cQuery += "					FROM " + cFilTrab + " FILIAIS "	
		cQuery += "				) " 
		cQuery += " AND C9V.C9V_ATIVO = '1' "
		
		If cEvento $ "S1210|S2221|S2230|S2231|S2298|S2299|S2500|S2399" .Or. lC9VDFil

			If cEvento $ "S2231|S2298|S2299"
				cQuery += " AND C9V.C9V_NOMEVE = 'S2200' "
			ElseIf cEvento $ "S2399"
				cQuery += " AND C9V.C9V_NOMEVE = 'S2300' "
			Else
				cQuery += " AND C9V.C9V_NOMEVE <> 'TAUTO' "
			EndIf

		EndIf

		If !cEvento $ "S2221"

			cQuery += " OR C9V.R_E_C_N_O_ IN ( "
			cQuery += " SELECT DISTINCT C9V.R_E_C_N_O_"
			cQuery += " FROM " + RetSQLName("C9V") + " C9V "
			cQuery += " INNER JOIN " + RetSQLName("T1U") + " T1U ON (T1U.T1U_FILIAL = C9V.C9V_FILIAL AND T1U.T1U_ID = C9V.C9V_ID) "
			cQuery += " WHERE T1U.D_E_L_E_T_ = ' ') "

		EndIf	

		If !cEvento $ "S1200|S1210"

			If cEvento $ "S2298"

				cQuery += " AND (EXISTS (SELECT CUP.CUP_DTDESL "
				cQuery += "	FROM " + RetSQLName("CUP") + " CUP "
				cQuery += "	WHERE CUP.CUP_FILIAL = C9V.C9V_FILIAL AND CUP.CUP_ID = C9V.C9V_ID AND CUP.CUP_VERSAO = C9V.C9V_VERSAO AND CUP.D_E_L_E_T_ = ' ' AND CUP.CUP_DTDESL <> ' ') "

				cQuery += " OR EXISTS "

			ElseIf cEvento $ "S2221"

				cQuery += " AND (EXISTS (SELECT CUP.CUP_DTTERM "
				cQuery += "	FROM " + RetSQLName("CUP") + " CUP "
				cQuery += "	WHERE CUP.CUP_FILIAL = C9V.C9V_FILIAL " 
				cQuery += "	AND CUP.CUP_ID = C9V.C9V_ID " 
				cQuery += "	AND CUP.CUP_VERSAO = C9V.C9V_VERSAO " 
				cQuery += "	AND CUP.D_E_L_E_T_ = '' " 
				cQuery += "	AND (CUP.CUP_DTTERM = '' OR CUP.CUP_DTTERM >= '" + DtoS(Date()) + "' )) "
				cQuery += "	OR EXISTS ( SELECT T1V.T1V_DTTERM " 	
			 	cQuery += "	FROM " + RetSQLName("T1V") + " T1V " 	
			 	cQuery += "	WHERE T1V.T1V_FILIAL = C9V.C9V_FILIAL " 
			 	cQuery += "	AND T1V.T1V_ID = C9V.C9V_ID " 
			 	cQuery += "	AND T1V.D_E_L_E_T_ = '' " 
			 	cQuery += "	AND (T1V.T1V_DTTERM = '' OR T1V.T1V_DTTERM >= '" + DtoS(Date()) + "'))) "

				cQuery += " AND (NOT EXISTS "

			Else

				cQuery += " AND (NOT EXISTS "

			EndIf

			cQuery += " (SELECT CMD.CMD_FUNC "
			cQuery += "	FROM " + RetSQLName("CMD") + " CMD "
			cQuery += "	WHERE CMD.CMD_FILIAL = C9V.C9V_FILIAL AND CMD.CMD_FUNC = C9V.C9V_ID AND CMD.CMD_ATIVO = '1' AND CMD.D_E_L_E_T_ = ' ' )) "

		EndIf	

		cQuery += " UNION "
		cQuery += " SELECT T1U.T1U_FILIAL FILIAL, T1U.T1U_ID ID, T1U.T1U_NOME NOME, T1U.T1U_CPF CPF, C9V.C9V_NOMEVE AS EVENTO "
		cQuery += " FROM " + RetSQLName("T1U") + " T1U "
		cQuery += " INNER JOIN " + RetSQLName("C9V") +  " C9V "  
		cQuery += " ON C9V.C9V_FILIAL = T1U.T1U_FILIAL AND C9V.C9V_ID = T1U.T1U_ID AND C9V.D_E_L_E_T_ = ' '
		
		If cEvento $ "S2231|S2299"
			cQuery += " AND C9V.C9V_NOMEVE = 'S2200' "
		EndIf

		If cEvento $ "S2399"
			cQuery += " AND C9V.C9V_NOMEVE = 'S2300' "
		EndIf

		cQuery += " WHERE T1U.D_E_L_E_T_ = ' ' "
		cQuery += " AND T1U.T1U_FILIAL IN ( "
		cQuery += "				SELECT FILIAIS.FILIAL "
		cQuery += "					FROM " + cFilTrab + " FILIAIS "	
		cQuery += "				) "  
		cQuery += " AND T1U.T1U_ATIVO = '1'"
		cQuery += " AND T1U.T1U_DTALT = (SELECT MAX(CPF.T1U_DTALT) FROM " + RetSQLName("T1U") + " CPF WHERE T1U.T1U_CPF = CPF.T1U_CPF ) "

		If cEvento $ "S2221"

			cQuery += " UNION "
			cQuery += " SELECT T3A.T3A_FILIAL Filial, T3A.T3A_ID Id, 'TRABALHADOR PRELIMINAR' Nome, T3A.T3A_CPF CPF, 'S2190' EVENTO "
			cQuery += " FROM " + RetSQLName("T3A") + " T3A "
			cQuery += " WHERE T3A.D_E_L_E_T_ = ' ' "
			cQuery += " AND T3A.T3A_FILIAL IN ( "
			cQuery += "				SELECT FILIAIS.FILIAL "
			cQuery += "					FROM " + cFilTrab + " FILIAIS "	
			cQuery += "				) " 
			cQuery += " AND T3A.T3A_ATIVO = '1' "
			cQuery += " AND T3A.T3A_EVENTO <> 'E' "
			cQuery += " AND NOT EXISTS ( "
			cQuery += " SELECT C9V.C9V_ID " 
			cQuery += " FROM " + RetSQLName("C9V") + " C9V "
			cQuery += " INNER JOIN " + RetSQLName("CUP") + " CUP "
			cQuery += " ON CUP.D_E_L_E_T_ = ' ' AND CUP.CUP_ID = C9V.C9V_ID AND CUP.CUP_VERSAO = C9V.C9V_VERSAO "
			cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V.C9V_ATIVO = '1' AND C9V.C9V_CPF = T3A.T3A_CPF AND C9V.C9V_MATRIC = T3A.T3A_MATRIC AND (C9V.C9V_CATCI = T3A.T3A_CODCAT OR CUP.CUP_CODCAT = T3A.T3A_CODCAT)) "
			
		EndIf

		If lLaySimplif .And. !cEvento $ "S1202|S2500|S2221"

			If (cEvento $ "S1210|S2230" .Or. lC9VDFil) .And. !cEvento $ "S2231|S2298|S2299|S2399"

				cQuery += " UNION "
				cQuery += " SELECT V73.V73_FILIAL Filial, V73.V73_ID Id, V73.V73_NOMEB Nome, V73.V73_CPFBEN CPF, V73.V73_NOMEVE EVENTO "
				cQuery += " FROM " + RetSQLName("V73") + " V73 "
				cQuery += " WHERE V73.D_E_L_E_T_ = ' ' "
				cQuery += " AND V73.V73_FILIAL IN ( "
				cQuery += "				SELECT FILIAIS.FILIAL "
				cQuery += "					FROM " + cFilTrab + " FILIAIS "	
				cQuery += "				) "   
				cQuery += " AND V73.V73_ATIVO = '1' "
				cQuery += " AND V73.V73_NOMEVE <> 'S2405' "

				cTitulo := STR0185 // "Consulta Beneficiário - S-2190/S-2200/S-2300/S-2400"

			ElseIf cEvento $ "S2298"

				cTitulo := STR0212 // "Consulta Trabalhador Com Vínculo Desligado - S-2200"

			ElseIf cEvento $ "S2231|S2299"

				cTitulo := STR0211 // "Consulta Trabalhador Com Vínculo - S-2200"

			ElseIf cEvento $ "S2399"

				cTitulo := STR0210 // "Consulta Trabalhador Sem Vínculo - S-2300"

			Else

				cTitulo := STR0186 // "Consulta Trabalhador Com/Sem Vínculo - S-2190/S-2200/S-2300/Autônomo"

			EndIf

			If !cEvento $ "S2231|S2298|S2299|S2399"

				cQuery += " UNION "
				cQuery += " SELECT T3A.T3A_FILIAL Filial, T3A.T3A_ID Id, 'TRABALHADOR PRELIMINAR' Nome, T3A.T3A_CPF CPF, 'S2190' EVENTO "
				cQuery += " FROM " + RetSQLName("T3A") + " T3A "
				cQuery += " WHERE T3A.D_E_L_E_T_ = ' ' "
				cQuery += " AND T3A.T3A_FILIAL IN ( "
				cQuery += "				SELECT FILIAIS.FILIAL "
				cQuery += "					FROM " + cFilTrab + " FILIAIS "	
				cQuery += "				) " 
				cQuery += " AND T3A.T3A_ATIVO = '1' "
				cQuery += " AND T3A.T3A_EVENTO <> 'E' "
				cQuery += " AND NOT EXISTS ( "
				cQuery += " SELECT C9V.C9V_ID " 
				cQuery += " FROM " + RetSQLName("C9V") + " C9V "
				cQuery += " INNER JOIN " + RetSQLName("CUP") + " CUP "
				cQuery += " ON CUP.D_E_L_E_T_ = ' ' AND CUP.CUP_ID = C9V.C9V_ID AND CUP.CUP_VERSAO = C9V.C9V_VERSAO "
				cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V.C9V_ATIVO = '1' AND C9V.C9V_CPF = T3A.T3A_CPF AND C9V.C9V_MATRIC = T3A.T3A_MATRIC AND (C9V.C9V_CATCI = T3A.T3A_CODCAT OR CUP.CUP_CODCAT = T3A.T3A_CODCAT)) "
			
			EndIf

		Else

			If (cEvento $ "S1210|S2221|S2230|S2231|S2299" .Or. lC9VDFil) .And. !cEvento $ "S2298"
				cTitulo := STR0187 // "Consulta Beneficiário - S-2200/S-2300"
			ElseIf cEvento $ "S2298"
				cTitulo := STR0212 // "Consulta Trabalhador Com Vínculo Desligado - S-2200"
			ElseIf cEvento $ "S2500"
				cTitulo := STR0208 // "Consulta Trabalhador Com/Sem Vínculo - S-2200/S-2300"
			ElseIf cEvento $ "S2399"
				cTitulo := STR0210 // "Consulta Trabalhador Sem Vínculo - S-2300"
			Else
				cTitulo := STR0188 // "Consulta Trabalhador Com/Sem Vínculo - S-2200/S-2300/Autônomo"
			EndIf

		EndIf

	ElseIf cEvtTrab == "TAUTO"

		cTitulo   := "Consulta Trabalhador Autônomo" 
	
		cQuery := " SELECT C9V_FILIAL FILIAL, C9V_ID ID, C9V_NOME NOME, C9V_CPF CPF, C9V_NOMEVE AS EVENTO "
		cQuery += " FROM "+RetSQLName("C9V")+" C9V "
		cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' "
		cQuery += " AND C9V.C9V_FILIAL IN ( "
		cQuery += "				SELECT FILIAIS.FILIAL "
		cQuery += "					FROM " + cFilTrab + " FILIAIS "	
		cQuery += "				) "  
		cQuery += " AND C9V.C9V_ATIVO = '1' "
		cQuery += " AND C9V.C9V_NOMEVE = 'TAUTO' "

	ElseIf cEvtTrab $ "ORIEVE"
		
		If lLaySimplif .And. !cEvento $ "S1202"
			cTitulo   := "Consulta Trabalhador Com/Sem Vínculo - S2190/S2200/S2300/Autônomo" 
		Else
			cTitulo   := "Consulta Trabalhador Com/Sem Vínculo - S2200/S2300/Autônomo" 
		EndIf

		If M->C91_ORIEVE $ "S2190"	

			cQuery += " SELECT T3A_FILIAL Filial, T3A_ID Id, 'TRABALHADOR PRELIMINAR' AS Nome, T3A_CPF CPF, 'S2190' as EVENTO "
			cQuery += " FROM " + RetSQLName("T3A") + " T3A "
			cQuery += " WHERE T3A.D_E_L_E_T_ = ' ' "
			cQuery += " AND T3A_FILIAL IN ( "
			cQuery += "				SELECT FILIAIS.FILIAL "
			cQuery += "					FROM " + cFilTrab + " FILIAIS "	
			cQuery += "				) "   
			cQuery += " AND T3A.T3A_ATIVO = '1' " 
			cQuery += " AND T3A.T3A_EVENTO <> 'E' " 
			cQuery += " AND T3A.T3A_CPF = '" + substr(M->C91_DTRABA,1,At(' ',M->C91_DTRABA)-1) + "'"
		
		Else

			cQuery := " SELECT C9V_FILIAL FILIAL, C9V_ID ID, C9V_NOME NOME, C9V_CPF CPF, C9V_NOMEVE AS EVENTO "
			cQuery += " FROM " + RetSQLName("C9V") + " C9V "
			cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' "
			cQuery += " AND C9V.C9V_FILIAL IN ( "
			cQuery += "				SELECT FILIAIS.FILIAL "
			cQuery += "					FROM " + cFilTrab + " FILIAIS "	
			cQuery += "				) "   
			cQuery += " AND C9V.C9V_ATIVO = '1' " 
			cQuery += " AND C9V.C9V_CPF = '" + substr(M->C91_DTRABA,1,At(' ',M->C91_DTRABA)-1) + "'"
		
		EndIf

	ElseIf cEvtTrab $ "SST|ORGPBL"

		cTitulo   := "Consulta Trabalhador Com/Sem Vínculo (2190/2200/2300/TAUTO) e Trabalhador Preliminar"

		cQuery := " SELECT C9V_FILIAL Filial, C9V_ID Id, C9V_NOME Nome, C9V_CPF CPF, C9V_NOMEVE AS EVENTO "
		cQuery += " FROM "+RetSQLName("C9V")+" C9V "
		cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' "
		cQuery += " AND C9V_FILIAL IN ( "
		cQuery += "				SELECT FILIAIS.FILIAL "
		cQuery += "					FROM " + cFilTrab + " FILIAIS "	
		cQuery += "				) "
		cQuery += " AND C9V.C9V_ATIVO = '1' OR C9V.R_E_C_N_O_ IN ("
		cQuery += " SELECT DISTINCT C9V.R_E_C_N_O_"
		cQuery += " FROM "+RetSQLName("C9V")+" C9V "
		cQuery += " INNER JOIN "+RetSQLName("T1U")+" T1U ON (T1U.T1U_FILIAL = C9V.C9V_FILIAL AND T1U.T1U_ID = C9V.C9V_ID) "
		cQuery += " WHERE T1U.D_E_L_E_T_ = '') "
		cQuery += " AND NOT EXISTS (SELECT CMD.CMD_FUNC "
		cQuery += "	FROM " + RetSQLName("CMD") + " CMD "
		cQuery += "	WHERE CMD.CMD_FILIAL =  C9V.C9V_FILIAL AND CMD.CMD_FUNC = C9V.C9V_ID AND CMD.CMD_ATIVO = '1' AND CMD.D_E_L_E_T_ = '' ) "
		cQuery += " UNION "
		cQuery += " SELECT T1U_FILIAL FILIAL,T1U_ID ID,T1U_NOME NOME,T1U_CPF CPF, C9V_NOMEVE AS EVENTO "
		cQuery += " FROM " + RetSQLName("T1U") + " T1U "
		cQuery += " INNER JOIN " + RetSQLName("C9V") +  " C9V "  
		cQuery += " ON C9V.C9V_FILIAL = T1U.T1U_FILIAL AND C9V.C9V_ID = T1U.T1U_ID AND C9V.D_E_L_E_T_ = ''
		cQuery += " WHERE  T1U.D_E_L_E_T_ = ' ' AND T1U_FILIAL = '" + xFilial("T1U") + "' AND T1U.T1U_ATIVO = '1'  AND T1U_DTALT = (SELECT MAX(T1U_DTALT) FROM "+RetSQLName("T1U")+" CPF WHERE T1U.T1U_CPF = CPF.T1U_CPF AND T1U.D_E_L_E_T_ = '')

		If cEvtTrab == "SST"

			cQuery += " AND C9V.C9V_NOMEVE IN ('S2200', 'S2300') "
			cQuery += " UNION "
			cQuery += " SELECT T3A_FILIAL FILIAL, T3A_ID ID, 'TRABALHADOR PRELIMINAR' AS NOME, T3A_CPF CPF, 'S2190' AS EVENTO "
			cQuery += " FROM "+RetSQLName("T3A")+" T3A "
			cQuery += " WHERE T3A.D_E_L_E_T_ = '' " 
			cQuery += " AND T3A_FILIAL IN ( "
			cQuery += "				SELECT FILIAIS.FILIAL "
			cQuery += "					FROM " + cFilTrab + " FILIAIS "	
			cQuery += "				) " 
			cQuery += " AND T3A.T3A_ATIVO = '1' " 
			cQuery += " AND T3A.T3A_EVENTO <> 'E' "

		ElseIf cEvtTrab == "ORGPBL"

			cQuery += " AND C9V.C9V_NOMEVE IN ('S2200') "

		EndIf	 		                                                                                                                                                                        

	EndIf
	
	cQuery := ChangeQuery(cQuery)

	QueenWindow(cQuery , cTitulo, , cCall, cEvento )

Return .T.

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosNTrab
Função para retornar o registro na consulta especifica SXB.
do trabalhador.

@author Henrique Cesar
@since 08/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Function PosNTrab()

Return (cRetNTrab)

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosicTrab
Função responsavel por realizar o posicionamento no registro selecionado na consulta do trabalhador.

@author Henrique Cesar
@since 06/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Static Function PosicTrab(cIdTrab as character, cTipo as character, cEvent as character, cFil as character)

	Local aButtons as array
	Local aEvent   as array
	Local lExec    as logical

	Default cIdTrab := ""
	Default cTipo   := ""
	Default cEvent  := ""
	Default cFil    := ""

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	lExec    := .T.
	cRetNTrab := ""

	DbSelectArea("C9V")

	C9V->( DbSetOrder( 1 ) )
	T3A->( DbSetOrder( 3 ) )
    
	If C9V->( DBSeek(xFilial("C9V", cFil )+ cIdTrab)) .AND. (cEvent $ "S2200|S2300|S2205|TAUTO")

		cRetNTrab := C9V->C9V_ID	

	ElseIf cEvent == "S2190" .AND. T3A->( DBSeek(xFilial("T3A", cFil )+ cIdTrab + "1"))

		cRetNTrab := T3A->T3A_ID	

	ElseIf cEvent $ "S2400|S2405"

		V73->( DbSetOrder( 1 ) )
		V73->( DBSeek(xFilial("V73", cFil )+ cIdTrab)) 
		cRetNTrab := V73->V73_ID	

	EndIf

	// Grava o evento	
	cEvtPosic	:= cEvent
	aEvent      := TAFRotinas(strtran(cEvent,"S","S-"),4,.F.,2)

	lExec := MPUserHasAccess(aEvent[20], 1, RetCodUsr())
	
	If cTipo == "1" .AND. lExec

		FWExecView("", aEvent[1], MODEL_OPERATION_VIEW, , { || .T. }, , ,aButtons )
		cRetNTrab := ""

	ElseIf cTipo == "1" .AND. !lExec

		msgAlert(STR0218,STR0219)

	EndIf

Return()

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFilF
Função responsavel por realizar a pesquisa por Nome e/ou CPF do trabalhador.

@author Henrique Cesar
@since 06/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Static Function CheckFilF(oListBox,cFiltro)

	Local nPos  	 := 0
	Local lRet  	 := .F.
	Local ni		 := 1
	Local lPosPesq	 := .F.
	Local lCPF 		 := .F.

	Default oListBox := Nil
	Default cFiltro	 := ""

	cFiltro := AllTrim(cFiltro)

	// Faz um scan no objeto para encontrar a posição e posicionar no browser
	If Valtype(cFiltro) = "C" .And. !Empty(cFiltro)
		nPos := aScan( oListBox:aArray, {|x| x[2] == cFiltro } )
		If nPos == 0
			nPos := aScan( oListBox:aArray, {|x| x[3] == cFiltro } )
			lCPF := .T.
		EndIf

		If nPos > 0
			oListBox:GoPosition(nPos)
			oListBox:Refresh()
			lRet  := .T.
		EndIf

		// Pesquisa parcial
		If !lRet .and. lCPF
			For ni := 1 to Len(oListBox:aArray)
				lPosPesq := cFiltro $ oListBox:aArray[ni][2]
				If lPosPesq
					Exit
				EndIf
			Next ni
			If lPosPesq
				oListBox:GoPosition(ni)
				oListBox:Refresh()
			EndIf
		EndIf
	EndIf

	If nPos == 0 .And. !lPosPesq
		MsgAlert("Não foi possível encontrar o trabalhador " + cFiltro + " na pesquisa.")
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} codIncFGTS

Função que retorna as opções de combo do código de ajuste 
Campos: C8R_CINTFG
Tag: codIncFGTS
Definição: Código de Ajuste da contribuição apurada no período

@author jose.riquelmo
@since 13/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function codIncFGTS()
	
	Local cString := ""
		
	If !lLaySimplif
		cString := "00="+STR0084+";" //Não é Base de Cálculo do FGTS
		cString += "11="+STR0098+";" //Base de cálculo do FGTS.
		cString += "12="+STR0086+";" //Base Cálculo 13º
		cString += "21="+STR0099+";" //Base de Cálculo do FGTS Rescisório (aviso prévio).
		cString += "91="+STR0100     //Incidência suspensa em decorrência de decisão judicial.
	Else
		cString := "00="+STR0084+";" //Não é Base de Cálculo do FGTS
		cString += "11="+STR0085+";" //Base de cálculo do FGTS mensal.
		cString += "12="+STR0086+";" //Base Cálculo 13º
		cString += "21="+STR0087+";" //Base de cálculo do FGTS aviso prévio indenizado.
		cString += "31="+STR0239+";" //"Desconto eConsignado"
		cString += "71="+STR0250+";" //"Valores apurados pela Auditoria-Fiscal do Trabalho, que integram a base de cálculo do FGTS"
		cString += "91="+STR0088+";" //Incidência suspensa em decorrência de decisão judicial - FGTS mensal
		cString += "92="+STR0089+";" //Incidência suspensa em decorrência de decisão judicial - FGTS 13º salário
		cString += "93="+STR0090     //Incidência suspensa em decorrência de decisão judicial - FGTS aviso prévio indenizado
	EndIf 
	
Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} codIncCPRP

Função que retorna as opções de combo do código de ajuste 
Campos: C8R_CICPRP 
Tag: codIncCPRP
Definição: Código de Ajuste da contribuição apurada no período

@author jose.riquelmo
@since 13/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function codIncCPRP()
	
	Local cString := ""
	
	cString := "00="+STR0091+";" //Não é base de cálculo de contribuições devidas ao RPPS/regime militar
	cString += "11="+STR0092+";" //Base de cálculo de contribuições devidas ao RPPS/regime militar
	cString += "12="+STR0093+";" //Base de cálculo de contribuições devidas ao RPPS/regime militar - 13º salário
	cString += "31="+STR0094+";" //Contribuição descontada do segurado e beneficiário
	cString += "32="+STR0095+";" //Contribuição descontada do segurado e beneficiário - 13º salário
	cString += "91="+STR0096+";" //Suspensão de incidência em decorrência de decisão judicial
	cString += "92="+STR0184     //Suspensão de incidência em decorrência de decisão judicial - 13º salário

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} CondIng

Função que retorna as opções de combo do código de ajuste 
Campos: C9V_CNDING 
Tag: CondIng
Definição: Condição de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function CondIng()
	
	Local cString := ""

	cString := "1="+STR0101+";" // Refugiado
	cString += "2="+STR0102+";" // Solicitante de refúgio
	cString += "3="+STR0103+";" // Permanência no Brasil em razão de reunião familiar 
	cString += "4="+STR0104+";" // Beneficiado pelo acordo entre países do Mercosul
	cString += "5="+STR0105+";" // Dependente de agente diplomático e/ou consular de países que mantêm acordo de reciprocidade para o exercício de atividade remunerada no Brasil 
	cString += "6="+STR0106+";" // Beneficiado pelo Tratado de Amizade, Cooperação e Consulta entre a República Federativa do Brasil e a República Portuguesa 
	cString += "7="+STR0107 	// Outra condição

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} ctpProv

Função que retorna as opções de combo do código de ajuste 
Campos: TIPPRO 
Tag: tpProv

@author jose.riquelmo
@since 26/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function cTpProv()
	
	Local cString as character

	If !lLaySimplif
		
		cString := "1="+STR0123+";" //Nomeação em cargo efetivo 
		cString += "2="+STR0124+";" //Nomeação em cargo em comissão 
		cString += "3="+STR0125+";" //Incorporação (militar)
		cString += "4="+STR0126+";" //Matrícula (militar); 
		cString += "5="+STR0127+";" //Reinclusão (militar)
		cString += "6="+STR0128+";" //Diplomação	
		cString += "99="+STR0129    //Outros não relacionados acima 

	Else 
		
		cString := "1=" + STR0123 + ";" 	// Nomeação em cargo efetivo 
		cString += "2=" + STR0140 + ";" 	// Nomeação exclusivamente em cargo em comissão 
		cString += "3=" + STR0141 + ";" 	// Incorporação ou matrícula (militar)
		cString += "5=" + STR0183 + ";" 	// Redistribuição ou Reforma Administrativa
		cString += "6=" + STR0128 + ";" 	// Diplomação
		cString += "7=" + STR0130 + ";" 	// Contratação por tempo determinado 
		cString += "8=" + STR0131 + ";" 	// Remoção (em caso de alteração do órgão declarante)
		cString += "9=" + STR0132 + ";" 	// Designação 
		cString += "10=" + STR0133 + ";"	// Mudança de CPF
		cString += "11=" + STR0182 + ";"	// Estabilizados - Art. 19 do ADCT 	
		cString += "99=" + STR0129 + ";"	// Outros não relacionados acima 
	
	EndIf 

Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} tpJornada

Função que retorna as opções de combo do código de ajuste 
Campos: CUP_TPJORN/T1V_TPJORN
Tag: CondIng
Definição: Condição de ingresso do trabalhador imigrante. 

@author Silas Gomes
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpJornada()

	Local cString := ""

	If !lLaySimplif // 2.5
		cString := "1="+STR0112+";" // Jornada com horário diário e folga fixos.
		cString += "2="+STR0113+";" // Jornada 12 x 36 (12 horas de trabalho seguidas de 36 horas ininterruptas de descanso).
		cString += "3="+STR0114+";" // Jornada com horário diário fixo e folga variável.
		cString += "9="+STR0115+";" // Demais tipos de jornada.
	Else
		cString := "2="+STR0116+";" // Jornada 12 x 36 (12 horas de trabalho seguidas de 36 horas ininterruptas de descanso)
		cString += "3="+STR0117+";" // Jornada com horário diário fixo e folga variável.
		cString += "4="+STR0118+";" // Jornada com horário diário fixo e folga fixa (no domingo).
		cString += "5="+STR0119+";" // Jornada com horário diário fixo e folga fixa (exceto no domingo).
		cString += "6="+STR0120+";" // Jornada com horário diário fixo e folga fixa (em outro dia da semana), com folga adicional periódica no domingo.
		cString += "7="+STR0121+";" // Turno ininterrupto de revezamento.
		cString += "9="+STR0122+";" // Demais tipos de jornada.
	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpPlanRP

Função que retorna as opções de combo do código de ajuste 
Campos: CUP_TPLASM /T1V_TPLASM
Tag: tpPlanRP
Definição: Condição de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpPlanRP()

	Local cString := ""

	If !lLaySimplif // 2.5
		cString := "1="+STR0109+";" // Plano previdenciário ou único
		cString += "2="+STR0110+";" // Plano financeiro
	Else
		cString := "0="+STR0108+";" // Sem segregação da massa
		cString += "1="+STR0134+";" // Fundo em capitalização
		cString += "2="+STR0135+";" // Fundo em repartição
		cString += "3="+STR0111+";" // Mantido pelo Tesouro
	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpProc

Função que retorna as opções de combo do código de ajuste 
Campos: C1G_TPPROC
Tag: tpProc
Definição: Condição de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpProc()

	Local cString := ""
	
	cString := "1="+STR0137+";" // Judicial - Tem que ser invertido com o administrativo devido a ser compartilhado com o fiscal, é ajustado na geração do XML
	cString += "2="+STR0136+";" // Administrativo - Tem que ser invertido com o judicial devido a ser compartilhado com o fiscal, é ajustado na geração do XML
	
	If !lLaySimplif // 2.5
		cString += "3="+STR0138+";" // Número de Benefício (NB) do INSS
	EndIf

	cString += "4="+STR0139+";" // Processo FAP de exercício anterior a 2019		
	
Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpProc

Função que retorna as opções de combo do código de ajuste 
Campos: T3A_UNSLFX
Tag: tpProc
Definição: Condição de ingresso do trabalhador imigrante. 

@author Rodrigo Nicolino
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpUnidSal()

	Local cString := ""

	If lLaySimplif // Simplificado
			
		cString := "1="+STR0143+";" // Por hora
		cString += "2="+STR0144+";" // Por dia
		cString += "3="+STR0145+";" // Por semana
		cString += "4="+STR0146+";" // Por quinzena
		cString += "5="+STR0147+";" // Por mês
		cString += "6="+STR0148+";" // Por tarefa
		cString += "7="+STR0149+";" // Não aplicável - Salário exclusivamente variável

	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpRegPrev

Função que retorna as opções de combo do código de ajuste 
Campos: CUU_TPRPRE
Tag: tpRegPrev
Definição: Condição de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpRegPrev(cCampo as character)

	Local cString 			as character
	Local lExibeOpcPadrao  	as Logical

	Default  cCampo 		:=  ""

	lExibeOpcPadrao  := !(ValType(cCampo) != 'U' .and. cCampo $ "CUP_TPREGP|T1V_TPREGP|CUU_TPREGP|T0F_TPREGP")

	If lExibeOpcPadrao
		cString := "1="+STR0150+";" // Regime Geral de Previdência Social - RGPS 
		cString += "2="+STR0151+";"	// Regime Próprio de Previdência Social - RPPS ou Sistema de Proteção Social dos Militares 
		cString += "3="+STR0152+";"	// Regime de Previdência Social no exterior 
	Else 		
		cString := "1="+STR0150+";" // Regime Geral de Previdência Social - RGPS 
		cString += "2="+STR0151+";"	// Regime Próprio de Previdência Social - RPPS ou Sistema de Proteção Social dos Militares 
		cString += "3="+STR0152+";"	// Regime de Previdência Social no exterior 
		cString += "4="+STR0225+";"	// Sistema de Proteção Social dos Militares das Forças Armadas - SPSMFA 
	EndIf

Return(cString)


//---------------------------------------------------------------------
/*/{Protheus.doc} tpTrib

Função que retorna as opções de combo do código de ajuste 
Campos: T3H_TPTRIB
Tag: tpTrib
Definição: Tipo tributo/Contribuição. 

@author Bruno de Oliveira
@since 05/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpTrib()

	Local cString := ""

	If !lLaySimplif // 2.5
		cString := "1="+STR0153+";" // IRRF
		cString += "2="+STR0154+";" // Contribuições sociais do trabalhador
		cString += "3="+STR0155+";" // FGTS
		cString += "4="+STR0156+";" // Contruibuição Sindical		
	Else		
		cString := "1="+STR0153+";" // IRRF
		cString += "2="+STR0154+";" // Contribuições sociais do trabalhador
	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} ComTpCon

Função que retorna as opções de combo do código de ajuste 
Campos: V6I_TPCON
Tag: ComTpCon
Definição: Tipo tributo/Contribuição. 

@author José Riquelmo
@since 23/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function ComTpCon()

	Local cString as character

	cString := "A=" + STR0157 + ";" // Acordo Coletivo de Trabalho  
	cString += "B=" + STR0158 + ";" // Legislação federal, estadual, municipal ou distrital 
	cString += "C=" + STR0159 + ";" // Convenção Coletiva de Trabalho 
	cString += "D=" + STR0160 + ";" // Sentença normativa - Dissídio 			
	cString += "E=" + STR0161 + ";" // Conversão de licença saúde em acidente de trabalho 
	cString += "F=" + STR0162 + ";" // Outras verbas de natureza salarial ou não salarial devidas após o desligamento 
	cString += "G=" + STR0163 + ";" // Antecipação de diferenças de acordo, convenção ou dissídio coletivo 
	cString += "H=" + STR0169 + ";"	// Declaração de base de cálculo de FGTS anterior ao início do FGTS Digital
	cString += "I=" + STR0224 + ";"	// Sentença judicial (exceto reclamatória trabalhista)
	cString += "J=" + STR0238 + ";" // Tipo relativo a parcelas complementares conhecidas após o fechamento da folha
	
Return (cString)
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GatMatC91
Criação da trigger
@author  Alexandre lima S.
@since   08/03/2021
@version 1
/*/
//-------------------------------------------------------------------
Function GatMatC91(cAlias as character, cIdFunc as character)

	Local cRet 			as character
	Local cEvent		as character

	Default cAlias 		:= ""
	Default cIdFunc 	:= ""

	cRet	:= ""
	cEvent 	:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)

	If Empty(cEvent) .AND. ALLTRIM(FunName()) == "TAFA549"
		cEvent := C9V->C9V_NOMEVE
	EndIf

	If cAlias == "C91"	

		If !Empty(cEvent) .AND. (INCLUI .OR. ALTERA)
			FWFldPut(cAlias +"_ORIEVE", cEvent)
		Else
			cEvent := C91->C91_ORIEVE
		EndIf

			If	cEvent == 'S2190'
				cNome := "TRABALHADOR PRELIMINAR"
				cCPF  := Posicione("T3A", 3, xFilial("T3A")  + cIdFunc + "1", "T3A_CPF")
				cRet  := cCPF + " - " + cNome
			
			ElseIf cEvent == 'S2200'
				cNome := Posicione("T1U", 2, xFilial("T1U")  + cIdFunc + "1", "T1U_NOME")
				cCPF  := T1U->T1U_CPF
				cRet  := cCPF + " - " + cNome
			Else
				cNome := Posicione("T1V", 2, xFilial("T1V")  + cIdFunc + "1", "T1V_NOME")
				cCPF  := T1V->T1V_CPF
				cRet  := cCPF + " - " + cNome
			EndIf

			If Empty(cNome) .OR. Empty(cCPF)
				cNome := Posicione("C9V", 2, xFilial("C9V") + cIdFunc + "1", "C9V_NOME")
				cCPF  := C9V->C9V_CPF
				cRet  := cCPF + " - " + cNome
			EndIf

	ElseIf cEvent == "S2190"
		If INCLUI .OR. ALTERA
			FWFldPut(cAlias +"_NOMEVE", cEvent)
		EndIf
		cIdFunc := T3A->T3A_ID 
		T3A->( DBSetOrder(3) )
		If T3A->(dbseek(xFilial("T3A") + cIdFunc + "1"))
			cRet := Alltrim(T3A->T3A_MATRIC)
		EndIf

	Else
		If INCLUI .OR. ALTERA
			FWFldPut(cAlias +"_NOMEVE", cEvent)
		EndIf

		If Empty(cIdFunc)
			cIdFunc := C9V->C9V_ID
		EndIf

		C9V->(DBSetOrder(2))

		If C9V->(dbseek(xFilial("C9V") + cIdFunc + "1"))
			If  cEvent == "S2200"
				cRet := Alltrim(C9V->C9V_MATRIC)
			Else
				cRet := AllTrim(C9V->C9V_MATTSV)    
			EndIf
		EndIf
	EndIf

	cEvtPosic := ""

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} tpisnc

Função que retorna as opções de combo do código de ajuste 
Campos: C9K_TPINSC
Tag: tpisnc
Definição: Tipo de inscrição. 

@author Karyna Martins
@since 18/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpisnc()

	Local cString := ""

	cString := "1=CNPJ;" 

	If !lLaySimplif
		cString += "2=CPF;"
	EndIf

	cString += "3=CAEPF;"
	cString += "4=CNO;" 
	

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} VrfPatch

Função que retorna as opções de combo do código de ajuste 
Campos: C9K_TPINSC
Tag: VrfPatch
Definição: Verifica Patch. 

@author Karyna Martins
@since 18/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function VrfPatch()

	Local cRet:= ""

	If lLaySimplif
		cRet:= GatMatC91("C91", M->C91_TRABAL)
	Else
		cRet:= TAFNMTRAB(XFILIAL("C9V"),M->C91_TRABAL)  
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GatMatSST

Gatilho para considerar C9V quando leiaute 2.5 e C9V/T3A quando 1.0 

@return cIdFunc - ID do funcionario (2200/2300/2190)
@return lView - Passado True quando função for chamada de um inicializador browse
@return cAlias - Alias da tabela que esta utilizando o gatilho

@author Fabio S Mendonca / Alexandre Santos / Karyna Martins / José Riquelmo / Silas Gomes
@since 26/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function GatMatSST(cIdFunc as character, lView as logical, cAlias as character, lBenef as logical)                                                                                                                             

	Local cRet        	as character
	Local cCPF        	as character
	Local cNome       	as character
	Local cEvent		as character
	Local cFilEvt		as character
	Local lFldPut		as logical

	Default cIdFunc   	:= ""
	Default cAlias    	:= ""
	Default lView     	:= .F.
	Default lBenef	  	:= .F.

	cRet    := ""
	cCPF    := ""
	cNome	:= ""
	cFilEvt	:= ""
	cEvent	:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)
	lFldPut	:= .F.

	If lView 
		cEvent := (cAlias)->&(cAlias + "_NOMEVE")

		If !lBenef
			If cEvent <> "S2190"
				cFilEvt := IIf(Empty(xFilial("C9V", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("C9V"), xFilial("C9V", (cAlias)->&(cAlias + "_FILIAL")))

				C9V->(DbSetOrder(2))

				If C9V->(MsSeek(cFilEvt + cIdFunc + "1"))
					cCPF  := C9V->C9V_CPF
					cNome := TAFGetNT1U(cCPF,,cFilEvt)
					
					If Empty(cNome)
						cNome := C9V->C9V_NOME
					EndIf
				EndIf
			Else
				cFilEvt := IIf(Empty(xFilial("T3A", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("T3A"), xFilial("T3A", (cAlias)->&(cAlias + "_FILIAL")))

				T3A->(DbSetOrder(3))

				If T3A->(MsSeek(cFilEvt + cIdFunc + "1"))
					cNome	:= STR0209 // "TRABALHADOR PRELIMINAR"
					cCPF	:= T3A->T3A_CPF
				EndIf
			EndIf
		Else
			cFilEvt := IIf(Empty(xFilial("V73", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("V73"), xFilial("V73", (cAlias)->&(cAlias + "_FILIAL")))

			V73->(DbSetOrder(4))

			If V73->(MsSeek(cFilEvt + cIdFunc + "1"))
				cEvent	:= V73->V73_NOMEVE
				cNome 	:= V73->V73_NOMEB
				cCPF  	:= V73->V73_CPFBEN

				V73->(DBSetOrder(3))

				If V73->(MsSeek(cFilEvt + cCPF + "S2405" + "1"))
					cNome := V73->V73_NOMEB
				EndIf	
			EndIf
		EndIf

		cRet := cCPF + " - " + AllTrim(cNome)
	Else
		// Verifica se a chamada foi da função genérica de exclusão.
		// Neste caso não tenho as variáveis INCLUI e ALTERA
		// Proteção para exclusão pelo monitor TAF Full
		If FwIsInCallStack('XTAFVEXC') 
			INCLUI := .F.
			ALTERA := .F.
		EndIf
		
		If tafColumnPos(cAlias + "_NOMEVE")

			If !Empty(cEvent) .And. (INCLUI .OR. ALTERA)
				FWFldPut(cAlias + "_NOMEVE", cEvent)	
			ElseIf !INCLUI
				cEvent := (cAlias)->&(cAlias + "_NOMEVE")
			EndIf
		EndIf	
		
		If Empty(cEvent)
			lFldPut := .T.
		EndIf

		cFilEvt := FWCodFil(,(cAlias)->&(cAlias + "_FILIAL"))

		If lBenef

			V73->(DbSetOrder(4))

			If V73->(MsSeek(cFilEvt + cIdFunc + "1"))
				cEvent	:= V73->V73_NOMEVE
				cNome 	:= V73->V73_NOMEB
				cCPF  	:= V73->V73_CPFBEN

				V73->(DBSetOrder(3))

				If V73->(MsSeek(cFilEvt + cCPF + "S2405" + "1"))
					cNome := V73->V73_NOMEB
				EndIf	
			EndIf
		Else

			C9V->(DbSetOrder(2))

			If C9V->(MsSeek(cFilEvt + cIdFunc + "1"))
				cEvent	:= C9V->C9V_NOMEVE
				cCPF  	:= C9V->C9V_CPF
				cNome 	:= TAFGetNT1U(cCPF)
				
				If Empty(cNome)
					cNome := C9V->C9V_NOME
				EndIf
			Else

				T3A->(DbSetOrder(3))

				If T3A->(MsSeek(cFilEvt + cIdFunc + "1"))
					cEvent	:= "S2190"
					cNome	:= STR0209 // "TRABALHADOR PRELIMINAR"
					cCPF	:= T3A->T3A_CPF
				EndIf
			EndIf
		EndIf
		
		If !Empty(cCPF)

			If cAlias == 'V3B' .And. (INCLUI .Or. ALTERA)
				cRet := AllTrim(cNome)
			Else
				cRet := cCPF + " - " + AllTrim(cNome)
				
				If lFldPut .And. (INCLUI .Or. ALTERA)
					FWFldPut(cAlias + "_NOMEVE", cEvent)
				EndIf
			EndIf
		EndIf
	EndIf

	cEvtPosic := ""

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CbTpExam

Função que retorna as opções de combobox 
Campos: C8B_TPEXAM

@author Fabio S Mendonca
@since 26/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function CbTpExam()

	Local cString := ""

	cString := "0="+STR0170+";" // Exame admissional
	cString += "1="+STR0171+";" // Exame periódico
	cString += "2="+STR0172+";" // Exame retorno trab 	
	cString += "3="+STR0174+";" // Exame mudança função ou mudança risco ocupacional			
	cString += "4="+STR0175+";" // Exame Monit. Pontual
	cString += "9="+STR0176+";" // Exame demissional 

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIniMat
Retorna a Matrícula do trabalhador conforme Nome do Evento e ID
para o inicializador padrão

@param cNomeEve - Nome do Evento
@param cIDFunc - ID do funcionário

@author Melkz Siqueira
@since 23/04/2021
@version 1.0		

@return cRet - Matrícula do trabalhador
/*/
//-------------------------------------------------------------------
Function TAFIniMat(cNomeEve, cIDTrab)

	Local cRet			:= ""
	Local lOpc			:= Iif(Type("INCLUI") == "U", .F., INCLUI)

	Default cNomeEve 	:= ""
	Default cIDTrab		:= ""

	If !Empty(cIDTrab) .AND. !lOpc
		Do Case
			Case cNomeEve == "S2300"
				cRet := Posicione("C9V", 2, xFilial("C9V") + cIDTrab + "1", "C9V_MATTSV")

			Case cNomeEve == "S2190"
				cRet := Posicione("T3A", 3, xFilial("C9V") + cIDTrab + "1", "T3A_MATRIC")
				
			OtherWise
				cRet := Posicione("C9V", 2, xFilial("C9V") + cIDTrab + "1", "C9V_MATRIC")
		EndCase
	EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XC91Valid
Rotina p/ executar os valids presentes no dicionário de dados em virtude
do campo X3_VALID não possuir caracteres suficientes
@author  Diego Santos
@since   15-06-2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function XC91Valid(cCampo as character)

	Local aTabFunc	as array 
	Local cEvento	as character
	Local cOrigem	as character
	Local lRet		as logical
	Local lAlert	as logical

	Default cCampo	:= ""

	cOrigem		:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)
	aTabFunc	:= IIf(cOrigem == "S2190", {"T3A", 3}, {"C9V", 2})
	cEvento		:= IIf(Type("cNomEve") == "U" .Or. ValType(cNomEve) == "U", "", cNomEve)
	lRet		:= .T.
	lAlert		:= .F.	

	If !lLaySimplIf 
		If AllTrim(cCampo) == "C91_INDAPU" .AND. !Empty(M->C91_INDAPU) .AND. !Empty(FWFLDGET("C91_TRABAL"))
			If cEvento == "S1200"
				If Pertence(" 12")
					lAlert := !XFUNVldUni("C91", 7, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + Posicione("C9V", 2, xFilial("C9V") + FWFLDGET("C91_TRABAL") + "1", "C9V_CPF") + cEvento + "1")
				Else
					lRet := .F.
				EndIf
			Else
				lRet := (Pertence(" 12") .AND. XFUNVldUni("C91", 2, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TRABAL") + cEvento + "1"))
			EndIf
		ElseIf AllTrim(cCampo) == "C91_PERAPU"
			lRet := .T.
		ElseIf AllTrim(cCampo) == "C91_TRABAL" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200"
				If XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.)
					lAlert := !XFUNVldUni("C91", 7, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + Posicione("C9V", 2, xFilial("C9V") + M->C91_TRABAL + "1", "C9V_CPF") + cEvento + "1")	
				Else
					lRet := .F.
				EndIf
			Else
				lRet := (XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.) .AND. XFUNVldUni("C91", 2, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TRABAL + cEvento + "1"))	
			EndIf
		ElseIf AllTrim(cCampo) == "C91_DTRABA" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200"
				lAlert := !XFUNVldUni("C91", 7, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + Posicione("C9V", 2, xFilial("C9V") + M->C91_TRABAL + "1", "C9V_CPF") + cEvento + "1")
			Else
				lRet := XFUNVldUni("C91", 2, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TRABAL + cEvento + '1')	
			EndIf
		EndIf
	Else
		If AllTrim(cCampo) == "C91_INDAPU" .AND. !Empty(M->C91_INDAPU) .AND. !Empty(FWFLDGET("C91_TRABAL"))
			If cEvento == "S1200" 
				If Pertence(" 12")
					cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), FWFLDGET("C91_ORIEVE"), cOrigem)
					lAlert 	:= !XFUNVldUni("C91", 10, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + TafGetCPF(, FWFLDGET("C91_TRABAL"),,, cOrigem) + cEvento + "1")
				Else
					lRet := .F.
				EndIf
			Else
				lRet := (Pertence(" 12") .AND. XFUNVldUni("C91", 11, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + FWFLDGET("C91_TRABAL") + cEvento + "1"))
			EndIf
		ElseIf AllTrim(cCampo) == "C91_PERAPU"
			lRet := .T.
		ElseIf AllTrim(cCampo) == "C91_TRABAL" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200" 
				If XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.)
					cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), M->C91_ORIEVE, cOrigem)
					lAlert 	:= !XFUNVldUni("C91", 10, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + TafGetCPF(, M->C91_TRABAL,,, cOrigem) + cEvento + "1")	
				Else
					lRet := .F.					
				EndIf
			Else
				lRet := (XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.) .AND. XFUNVldUni("C91", 11, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + M->C91_TRABAL + cEvento + "1"))	
			EndIf
		ElseIf AllTrim(cCampo) == "C91_DTRABA" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200"
				cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), M->C91_ORIEVE, cOrigem)
				lAlert 	:= !XFUNVldUni("C91", 10, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + TafGetCPF(, M->C91_TRABAL,,, cOrigem) + cEvento + "1")
			Else	
				lRet := XFUNVldUni("C91", 11, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") +	 FWFLDGET("C91_TPGUIA") + M->C91_TRABAL + cEvento + '1')
			EndIf
		ElseIf AllTrim(cCampo) == "C91_TPGUIA" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(FWFLDGET("C91_TRABAL")) 
			If cEvento == "S1200"
				cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), FWFLDGET("C91_ORIEVE"), cOrigem)
				lAlert 	:= !XFUNVldUni("C91", 10, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TPGUIA + TafGetCPF(, FWFLDGET("C91_TRABAL"),,, cOrigem) + cEvento + "1")
			Else	
				lRet := XFUNVldUni("C91", 11, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TPGUIA + FWFLDGET("C91_TRABAL") + cEvento + '1')
			EndIf
		EndIf
	EndIf

	If lAlert
		MsgAlert(STR0177, STR0178) // "Esse CPF já possui uma Folha de Pagamento incluída para este período." / "Atenção!"
		
		lRet := .F.
	EndIf

Return lRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafNameBen
Funcao chamada do campo virtual de nome do beneficiário para exibir o último nome com status 4
@author Lucas A. dos Passos
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TafNameBen(cFil as character, cAlias as character, cCPFTrab as character, cIdTrab as character, lNrCpf as character)

	Local aAreaV73	 as array
	Local cRet       as character
    Local cNome      as character

	Default cIdTrab  := ""
	Default cCPFTrab := ""
    Default cAlias   := "V73"
	Default cFil	 := xFilial(cAlias)
	Default lNrCpf   := .F.

	aAreaV73	:= V73->(GetArea())
	cRet		:= ""
	cNome       := ""

    If !Empty(cCPFTrab) .And. Empty(cIdTrab)
		V73->(DBSetOrder(3))

		If V73->(MsSeek(xFilial("V73", cFil) + cCPFTrab + "S2400" + "1"))
			cNome := V73->V73_NOMEB

			If ExistS2405(.T., cFil, V73->V73_ID, .T.)
				cNome := V73->V73_NOMEB
			EndIf
		EndIf
	EndIf

	If !Empty(cIdTrab)
		If ExistS2405(.T., cFil, cIdTrab, .T.)
			cNome 		:= V73->V73_NOMEB
			cCPFTrab  	:= V73->V73_CPFBEN
		Else
			V73->(DbSetOrder(4))

			If V73->(MsSeek(xFilial("V73", cFil) + cIdTrab + "1"))
				cNome 		:= V73->V73_NOMEB
				cCPFTrab  	:= V73->V73_CPFBEN
			EndIf
		EndIf
	EndIf

	cRet := IIF(lNrCpf, cCPFTrab + " - ", "") + AllTrim(cNome)

	RestArea(aAreaV73)

Return cRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} V73Sxb
Funcao chamada da consulta específica V73
@author Lucas A. dos Passos
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
function V73Sxb()

	Local aCols  		as array
	Local aCoord		as array
	Local aWindow		as array
	Local aHeader   	as array
	Local aColSizes 	as array
	Local cTitulo   	as character
	Local cFiltro		as character
	Local cAlias		as character
	Local lLGPDperm 	as logical
	Local Nx 			as numeric
	Local oListBox		as object
	Local oArea			as object
	Local oList			as object
	Local oButt1 		as object
	Local oButt2 		as object
	Local oButt3 		as object

	Private __cEvtPos	as character

	aCols  		:= {}
	aCoord		:= {}
	aWindow		:= {}
	aHeader   	:= {"ID", "Nome", "CPF", "Evento"}
	aColSizes 	:= {35, 80, 25, 15}
	__cEvtPos	:= ""
	cTitulo   	:= "Consulta Beneficiário (S-2400)" 
	cFiltro		:= Space(50)
	cAlias		:= GetNextAlias()
	lLGPDperm 	:= IIf(FindFunction("PROTDATA"), ProtData(), .T.)
	Nx 			:= 0
	oListBox	:= Nil
	oArea		:= Nil
	oList		:= Nil
	oButt1 		:= Nil
	oButt2 		:= Nil
	oButt3 		:= Nil

	BeginSql Alias cAlias
	
		SELECT V73_FILIAL FILIAL, V73_ID ID, V73_CPFBEN CPF, V73_NOMEB NOME, V73_STATUS, V73_DTALTE DATAALTERACAO, 'S2400' AS EVENTO
		FROM %Table:V73% V73
		WHERE 
			V73.%NotDel% 
			AND V73_ATIVO = '1'
			AND V73_FILIAL = %xfilial:V73%
			AND ( (V73_NOMEVE = 'S2400' AND V73_ID NOT IN 
					( SELECT V73_ID
						FROM %Table:V73% V731
						WHERE 
						V731.%NotDel%
						AND V731.V73_NOMEVE = 'S2405'
						AND V731.V73_ATIVO = '1' 
						AND V731.V73_STATUS = '4' 
						AND V731.V73_FILIAL = V73.V73_FILIAL
					)
				  ) 
					OR
					(V73_NOMEVE = 'S2405' 
						AND V73.V73_STATUS = '4'
						AND V73_ID NOT IN 
						( SELECT V73_ID
						FROM %Table:V73% V732
						WHERE V732.%NotDel%
						AND V73_ATIVO = '1' 
						AND V732.V73_DTALTE > V73.V73_DTALTE
						AND V732.V73_STATUS = '4' 
						AND V732.V73_FILIAL = V73.V73_FILIAL
						)
					)
				)
	EndSql

	QueenWindow( , cTitulo , cAlias )

Return .T.

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} C9VDFil
Consulta Especifica de trabalhadores S-2200,S-2300 e s-2400.

@author Daniel Aguilar / Karyna Rainho
@since 06/04/2022
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Function C9VDFil()

	Local lRet := C9VHFil()

Return lRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TelaEspec
Monta a tela da consulta específica

@param cTitulo 	- Título da consulta específica
@param aHeader 	- Array do cabeçalho 
@param aCols 	- Array das colunas

@author Daniel Aguilar / Karyna Rainho
@since 06/04/2022
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Function TelaEspec(cTitulo, aHeader, aCols)

	Local oListBox		:= Nil
	Local oArea			:= Nil
	Local oList			:= Nil
	Local oButt1 		:= Nil
	Local oButt2 		:= Nil
	Local oButt3 		:= Nil	
	Local aColSizes 	:= { 35, 80, 25, 15 }
	Local aCoord		:= {}
	Local aWindow		:= {}		
	Local cFiltro		:= Space(50)
	Local Nx 			:= 0
	Local lLGPDperm 	:= IIF(FindFunction("PROTDATA"),ProtData(),.T.)

	Default cTitulo	:= "Consulta Específica"
	Default aHeader	:= {}
	Default aCols  	:= {}	

	aCoord 	:= {000,000,400,800}
	aWindow := {020,073}

	oArea := FWLayer():New()
	oFather := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oArea:Init(oFather,.F., .F. )

	oArea:AddLine("L01",100,.T.)

	oArea:AddCollumn("L01C01",99,.F.,"L01")
	oArea:AddWindow("L01C01","TEXT","Ações",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oText	:= oArea:GetWinPanel("L01C01","TEXT","L01")

	TSay():New(005,002,{||'Pesquisa Nome/CPF:'},oText,,,,,,.T.,,,200,20)
	TGet():New(003,057,{|u| if( PCount() > 0, cFiltro := u, cFiltro ) },oText,130,009,"@!",,,,,,,.T.,,,,.T.,,,.F.,,"","cFiltro",,,,.T.,.T.)
	oButt3 := tButton():New(003,190,"Pesquisar",oText,{||CheckFilF(oListBox,cFiltro)}, 45,11,,,.F.,.T.,.F.,,.F.,,,.F. )

	oArea:AddWindow("L01C01","LIST","Trabalhador",aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

	oButt2 := tButton():New(003,239,"&Visualizar",oText,{||PosicTrab(aCols[oListBox:nAt,1],"1",aCols[oListBox:nAt,4])},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButt1 := tButton():New(003,290,"&OK",oText,{||PosicTrab(aCols[oListBox:nAt,1],,aCols[oListBox:nAt,4]), oFather:End()},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButt3 := tButton():New(003,340,"&Sair",oText,{|| oFather:End()},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )

	oFather:lEscClose := .T.

	nTamCol := Len(aCols[01])
	bLine 	:= "{|| {"
	For Nx := 1 To nTamCol
		bLine += "aCols[oListBox:nAt]["+StrZero(Nx,3)+"]"
		If Nx < nTamCol
			bLine += ","
		EndIf
	Next
	bLine += "} }"

	oListBox := TCBrowse():New(0,0,386,130,,aHeader,,oList,'Fonte')
	oListBox:SetArray( aCols )
	oListBox:bLine := &bLine

	If !lLGPDperm
		oListBox:aObfuscatedCols :={.F.,.T.,.T.}
	EndIf

	If !Empty( aColSizes )
		oListBox:aColSizes := aColSizes
	EndIf
	oListBox:SetFocus()	

	oFather:Activate(,,,.T.,/*valid*/,,/*On Init*/)

Return 

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GatBenT3P
Gatilho do beneficiário

@param cAlias 	- Alias da tabela
@param cIdBen 	- Id do beneficiário

@author Daniel Aguilar / Karyna Rainho
@since 06/04/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function GatBenT3P(cAlias as character, cIdBen as character)      

	Local cCPF    	as character
	Local cEvent	as character
	Local cNome   	as character
	Local cRet    	as character

	Default cAlias 	:= ""
	Default cIdBen 	:= ""

	cCPF    := ""
	cNome   := ""
	cRet    := ""
	cEvent	:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)

	If !Empty(cEvent) .And. (INCLUI .OR. ALTERA)

		FWFldPut(cAlias +"_ORIEVE", cEvent)

	ElseIf TafColumnPos("T3P_ORIEVE")

		cEvent := T3P->T3P_ORIEVE
		
	EndIf

	If cEvent == 'S2200'

		cNome := Posicione("T1U", 2, xFilial("T1U")  + cIdBen + "1", "T1U_NOME")
		cCPF  := T1U->T1U_CPF

	ElseIf cEvent == 'S2400'

		cNome := Posicione("V73", 4, xFilial("V73")  + cIdBen + "1", "V73_NOMEB")
		cCPF  := V73->V73_CPFBEN

	Else
		
		cNome := Posicione("T1V", 2, xFilial("T1V")  + cIdBen + "1", "T1V_NOME")
		cCPF  := T1V->T1V_CPF

	EndIf

	If Empty(cNome) .OR. Empty(cCPF)

		cNome := Posicione("C9V", 2, xFilial("C9V") + cIdBen + "1", "C9V_NOME")
		cCPF  := C9V->C9V_CPF	

	EndIf

	cRet  := cCPF + " - " + cNome
	cEvtPosic := ""

Return cRet
    
//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} tpCont
Combobox do tpCont

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function tpCont()    

	Local cString  as string
	
	cString := "1="+STR0202+";" // Trabalhador com vínculo formalizado, sem alteração nas datas de admissão e de desligamento
	cString += "2="+STR0203+";" // Trabalhador com vínculo formalizado, com alteração na data de admissão
	cString += "3="+STR0204+";" // Trabalhador com vínculo formalizado, com inclusão ou alteração de data de desligamento
	cString += "4="+STR0205+";" // Trabalhador com vínculo formalizado, com alteração na data de admissão e inclusão ou alteração de data de desligamento
	cString += "5="+STR0206+";" // Empregado com reconhecimento de vínculo
	cString += "6="+STR0207+";" // Trabalhador sem vínculo de emprego/estatutário (TSVE), sem reconhecimento de vínculo empregatício
	cString += "7="+STR0226+";" // Trabalhador com vínculo de emprego formalizado em período anterior ao eSocial
	cString += "8="+STR0227+";" // Responsabilidade indireta
	cString += "9="+STR0228+";" // Trabalhador cujos contratos foram unificados (unicidade contratual)

Return cString

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} tpAcConv
Combobox do tpAcConv

@author Rodrigo Nicolino
@since 23/01/2024
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function tpAcConv()    

	Local cString  as string
	
	cString := "E="+STR0235+";" //Conversão de licença saúde em acidente de trabalho
	cString += "H="+STR0236+";" //Declaração de base de cálculo de FGTS anterior ao início do FGTS Digital
	cString += "I="+STR0237+";" //Sentença judicial (exceto reclamatória trabalhista)

Return cString
            
//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFTpRegT
Gatilho do TAFTpRegT

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function TAFTpRegT()  

	Local cString  as string
	
	cString := "1="+STR0190+";" // CLT - Consolidação das Leis de Trabalho e legislações trabalhistas específicas
	cString += "2="+STR0191+";" // Estatutário/legislações específicas (servidor temporário, militar, agente político, etc.)

Return cString

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFTpRegP
Gatilho do TAFTpRegP

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function TAFTpRegP()    

	Local cString  as string
	
	cString := "1="+STR0192+";" // Regime Geral de Previdência Social - RGPS
	cString += "2="+STR0193+";" // Regime Próprio de Previdência Social - RPPS ou Sistema de Proteção Social dos Militares
	cString += "3="+STR0194+";" // Regime de Previdência Social no exterior

Return cString

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMotTSV
Gatilho do TAFMotTSV

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function TAFMotTSV()         

	Local cString  as string
	
	cString := "01="+STR0195+";" // Exoneração do diretor não empregado sem justa causa, por deliberação da assembleia, dos sócios cotistas ou da autoridade competente
	cString += "02="+STR0196+";" // Término de mandato do diretor não empregado que não tenha sido reconduzido ao cargo
	cString += "03="+STR0197+";" // Exoneração a pedido de diretor não empregado
	cString += "04="+STR0198+";" // Exoneração do diretor não empregado por culpa recíproca ou força maior
	cString += "05="+STR0199+";" // Morte do diretor não empregado
	cString += "06="+STR0200+";" // Exoneração do diretor não empregado por falência, encerramento ou supressão de parte da empresa
	cString += "99="+STR0201+";" // Outros

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} GatMatV9U
Gatilho
@author  Karyna / Silas
@since   25/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function GatMatV9U()

	Default cEvtPosic := ''

Return cEvtPosic

//-----------------------------------------------------------------------
/*/{Protheus.doc} xFunVldAnual
	@type  X3_VALID
	@author Lucas Passos
	@since 23/01/2023
	@param cPerApu - Periodo de apuração informado em memoria
/*/
//-----------------------------------------------------------------------
Function xFunVldAnual(cPerApu as character)

	Local lOk as Logical
	
	lOk := .T.

	If Len(Alltrim(cPerApu)) < 6
		Help( ,,"TAFVLDANUAL",,, 1, 0 ,,,,,,{STR0213})
		lOk := .F.
	EndIF
	
Return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} QueenWindow
	@author Alexandre lima / Karyna Rainho
	@since 01/03/2023
	@param cQuery  - Query para ser aplicada no filtro
	@param cTitulo - Título da rotina
/*/
//-----------------------------------------------------------------------
Function QueenWindow(cQuery as character, cTitulo as character, cAliasQry as character, cCall as character, cEvento as character)

    Local aStruct    	as Array 
    Local aColumns   	as Array 
    Local aFilter    	as Array 
	Local aSeek     	as Array
	LocaL aValue        as Array
	Local cCPF 			as character
	Local cNome 		as character
	Local cAliasTmp     as character
	Local cEveUnic      as character
	Local cFilEEE       as character 
	Local cFilCEE       as character
	Local cFilCCC       as character 
	Local cFields       as character
	Local cTCAlias      as character
    Local nX         	as Numeric 
	Local oTempTable 	as object
	Local oFWFilter 	as object
	Local oBrowse   	as object
	Local oDlg      	as object
	Local oBulk         as object	
	Local bCancel       as logical
	Local bOk           as logical
	Local bVil          as logical

	Default cEvento := ""
	Default cCall   := ""
	
	aStruct 	:= {}   
    aColumns  	:= {} 
    aFilter     := {}
	aSeek       := {}
    nX          := 1
	oTempTable  := nil
	oFWFilter   := nil
	oBrowse     := nil
	oDlg        := nil
	oBulk       := nil
	cCPF 		:= ""
	cNome 	    := ""
	cAliasTmp   := ""
	cFilEEE     := FWCodFil()
	cFilCEE     := FWxFilial("C9V",FWCodFil(), "E", "E", "C" )
	cFilCCC     := FWxFilial("C9V",FWCodFil(), "C", "C", "C" )
	
	cEveUnic := Iif( cEvento $ "S2298|S2299", "S2200", Iif( cEvento $ "S2399",  "S2300",  ""))
	
	If FunName() == "TAFA591" .AND. cCall == "C9VHFil"

		cEveUnic := "S2200"
		cEvento  := "S2400"
		cTitulo  := STR0211

	ElseIf FunName() $ "TAFA261"

		cEveUnic := "S2200|S2300"
		cTitulo  := STR0208

	ElseIf FunName() $ "TAFA264|TAFA258|TAFA407|TAFA257"

		cEveUnic := "S2200|S2300|S2190|S2400"
		cTitulo  := STR0223

	EndIf

    AaDD(aStruct, {"FILIAL"	, "C", TamSx3( "C9V_FILIAL" )[1], 	0, "!@"})
	AaDD(aStruct, {"ID"		, "C", TamSx3( "C9V_ID" )[1]	, 	0, "!@"})
	AaDD(aStruct, {"NOME"	, "C", TamSx3( "C9V_NOME" )[1]	, 	0, "!@"})
	AaDD(aStruct, {"CPF"	, "C", TamSx3( "C9V_CPF" )[1]	, 	0, "!@"})
	AaDD(aStruct, {"EVENTO"	, "C", TamSx3( "C9V_NOMEVE" )[1], 	0, "!@"})
 
    //Set Columns
    aColumns := {}
    aFilter  := {}

	cFields := ""

    For nX := 1 To Len(aStruct)

        //Columns
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStruct[nX][1])
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
		aColumns[Len(aColumns)]:SetID(aStruct[nX][1])

        //Filters
        aAdd(aFilter, {aStruct[nX][1], aStruct[nX][1], aStruct[nX][2], aStruct[nX][3], aStruct[nX][4], "!@"} )
		cFields += aStruct[nX][1] + ","//Nome do campo

    Next nX

	cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula
 
    //Instance of Temporary Table
    oTempTable := FWTemporaryTable():New()

    //Set Fields
    oTempTable:SetFields(aStruct)
	
    //Set Indexes
    oTempTable:AddIndex("INDEX1", {"FILIAL"} )
    oTempTable:AddIndex("INDEX2", {"ID"} )
	oTempTable:AddIndex("INDEX3", {"NOME"} )
    oTempTable:AddIndex("INDEX4", {"CPF"} )
	oTempTable:AddIndex("INDEX5", {"EVENTO"} )

    //Create
    oTempTable:Create()
	cTCAlias := oTempTable:GetTableNameForTCFunctions()
    cAliasTMP := oTemptable:GetAlias()
 
    aHeadCols := {}
    oBrowse   := NIL
    aAccounts := {}

	oBulk := FwBulk():New(cTCAlias)
	oBulk:SetFields(aFilter)

	If Empty(cAliasQry)

		cAliasQry := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
    	MpSysOpenQuery(cQuery, cAliasQry)
		
	EndIf

	(cAliasQry)->(DbGoTop())

	While !(cAliasQry)->(EOF())
		
		aValue := {}
		
		cCPF := (cAliasQry)->CPF

		If ( Empty(cEveUnic) .OR. Alltrim((cAliasQry)->EVENTO) $ cEveUnic ) .and. (cAliasQry)->FILIAL $ cFilEEE + "|" + cFilCEE + "|" + cFilCCC

			aadd( aValue , (cAliasQry)->FILIAL )
			aadd( aValue , (cAliasQry)->ID )
			aadd( aValue , (cAliasQry)->NOME )
			aadd( aValue , (cAliasQry)->CPF )
			aadd( aValue , (cAliasQry)->EVENTO )

			oBulk:AddData(aValue)

		EndIf

		(cAliasQry)->(DbSkip())

	EndDo

	oBulk:Flush()
	oBulk:Close()
	oBulk:Destroy()
	oBulk := Nil

	DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 To 500,1000 OF oMainWnd PIXEL

    oBrowse := FWMBrowse():New()
 
    oBrowse:SetAlias(cAliasTMP) //Temporary Table Alias
	oBrowse:SetMenuDef( 'TAFXFUNDIC' )
	oBrowse:SetDescription(cTitulo)
    oBrowse:SetTemporary(.T.) //Using Temporary Table
    oBrowse:SetUseFilter(.T.) //Using Filter
    oBrowse:OptionReport(.F.) //Disable Report Print
    oBrowse:SetColumns(aColumns)
    oBrowse:SetFieldFilter(aFilter) //Set Filters
	oBrowse:SetOwner(oDlg)
	
	aAdd( aSeek, { "Filial"	, { { "", "C",	TamSx3( "C9V_FILIAL" )[1],  0, "FILIAL",	"@!", } } } )
	aAdd( aSeek, { "Id"		, { { "", "C",	TamSx3( "C9V_ID" )[1],   	0, "ID", 		"@!", } } } )
	aAdd( aSeek, { "Nome"	, { { "", "C", 	TamSx3( "C9V_NOME" )[1],  	0, "NOME", 		"@!", } } } )
	aAdd( aSeek, { "Cpf"	, { { "", "C", 	TamSx3( "C9V_CPF" )[1],  	0, "CPF", 		"@!", } } } )
	aAdd( aSeek, { "Evento"	, { { "", "C", 	TamSx3( "C9V_NOMEVE" )[1],  0, "EVENTO", 	"@!", } } } )

	oBrowse:SetSeek(.T., aSeek)
	oBrowse:SetIgnoreARotina(.T.)
	oBrowse:AddButton(STR0220 , bOk := {||  __cEvtPos := Alltrim((cAliasTMP)->EVENTO), PosicTrab(Alltrim((cAliasTMP)->ID),,Alltrim((cAliasTMP)->EVENTO ),(cAliasTMP)->FILIAL ),oDlg:End()})
	oBrowse:AddButton(STR0221 , bVil := {||  PosicTrab(Alltrim((cAliasTMP)->ID),"1",Alltrim((cAliasTMP)->EVENTO ),(cAliasTMP)->FILIAL)})
    oBrowse:AddButton(STR0221 , bCancel := {|| oDlg:End() })
    oBrowse:Activate(/*oDlg*/) //Caso deseje incluir em um componente de Tela (Dialog, Panel, etc), informar como parâmetro o objeto
	
	(cAliasQry)->( DbCloseArea() )

	ACTIVATE MSDIALOg oDlg CENTERED

    //Delete Temporary Table
    oTempTable:Delete()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author karyna Rainho
@since 01/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
static function MenuDef()

	Local aRotina as array

	aRotina := {}

Return aRotina

/*/{Protheus.doc} CboTpDedu
@author lucas.passos
@since 21/09/2023

ComboBox indTpDeducao - Indicativo do tipo de dedução.
/*/
Function CboTpDedu()
	
	Local cString as Character

	cString := ""
	
	cString := "1="+STR0229+";" //Previdência oficial
	cString += "2="+STR0230+";" //Previdência privada
	cString += "3="+STR0231+";" //Fundo de Aposentadoria Programada Individual - FAPI
	cString += "4="+STR0232+";" //Fundação de Previdência Complementar do Servidor Público - Funpresp
	cString += "5="+STR0233+";" //Pensão alimentícia
	cString += "7="+STR0234     //Dependentes

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} TpConCom

Função que retorna as opções de combo do código de ajuste 
Campos: T5I_TPACCO
Tag: ComTpCon
Definição: Tipo Acordo

@author Daniele Sakamoto
@since 27/02/2024
@version 1.0
/*/
//---------------------------------------------------------------------
Function TpConCom()

	Local cString as character

	cString := "1=" + STR0157 + ";" // Acordo Coletivo de Trabalho  
	cString += "2=" + STR0158 + ";" // Legislação federal, estadual, municipal ou distrital 
	cString += "3=" + STR0159 + ";" // Convenção Coletiva de Trabalho 
	cString += "4=" + STR0160 + ";" // Sentença normativa - Dissídio 			
	cString += "5=" + STR0161 + ";" // Conversão de licença saúde em acidente de trabalho 
	cString += "6=" + STR0162 + ";" // Outras verbas de natureza salarial ou não salarial devidas após o desligamento 
	cString += "7=" + STR0163 + ";" // Antecipação de diferenças de acordo, convenção ou dissídio coletivo 
	cString += "8=" + STR0169 + ";"	// Declaração de base de cálculo de FGTS anterior ao início do FGTS Digital
	cString += "9=" + STR0224 + ";"	// Sentença judicial (exceto reclamatória trabalhista)
	cString += "A=" + STR0238 + ";" // Tipo relativo a parcelas complementares conhecidas após o fechamento da folha
	
Return (cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} codIncPISP

Função que retorna as opções de combo do código de ajuste 
Campos: C8R_CIPIPA
Tag: codIncPisPasep
Definição: Código de Ajuste da contribuição apurada no período

@author Daniele Sakamoto
@since 11/07/2024
@version 1.0
/*/
//---------------------------------------------------------------------
Function codIncPISP()
	
	Local cString 	as Character 

	cString := ""
	
	cString := "00="+STR0240+";" //Não é base de cálculo do PIS/PASEP
	cString += "11="+STR0241+";" //Base de cálculo do PIS/PASEP mensal
	cString += "12="+STR0242+";" //Base de cálculo do PIS/PASEP 13° salário
	cString += "91="+STR0243+";" //Incidência suspensa em decorrência de decisãojudicial - PIS/PASEP mensal
	cString += "92="+STR0244     //Incidência suspensa em decorrência de decisãojudicial - PIS/PASEP 13º salário

Return(cString)

/*/{Protheus.doc} comboNValid
	Indicativo de não validação das regras de fechamento S-1299
	@type  Function
	@author Lucas Passos
	@since 01/08/2024
	/*/
Function comboNValid()
	Local cString 	as Character 

	cString := "1=Sim"

	If lSimpl0103
		cString += ";2=Não"
	EndIf 

Return (cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} codIndResp

Função que retorna as opções de combo do código de ajuste 
Campos: V7H_INDREP
Tag: codIncPisPasep
Definição: Indicativo de repercussão do processo trabalhista ou 
de demanda submetida à CCP ou ao NINTER

@author Daniele Sakamoto
@since 13/08/2024
@version 1.0
/*/
//---------------------------------------------------------------------
Function codIndResp()
	
	Local cString 	as Character 

	cString := ""
	
	cString := "1="+STR0245+";" //Decisão com repercussão tributária e/ou FGTS com rendimentos informados em S-2501
	cString += "2="+STR0246+";" //Decisão sem repercussão tributária ou FGTS
	cString += "3="+STR0247+";" //Decisão com repercussão exclusiva para declaração de rendimentos para fins de Imposto de Renda com rendimentos informados em S-2501
	cString += "4="+STR0248+";" //Decisão com repercussão exclusiva para declaração de rendimentos para fins de Imposto de Renda com pagamento através de depósito judicial
	cString += "5="+STR0249     //Decisão com repercussão tributária e/ou FGTS com pagamento através de depósito judicial

Return(cString)
