#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFAWIZD.CH" 
#INCLUDE "APWIZARD.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAWizd

Configura o TSS para o e-Social 
*Função Original: SpedNFeCFG (Eduardo Rieira - 18.06.2007)

@author Evandro dos Santos Oliveira
@since 28/03/2014
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
Function TAFAWizd()  
	Local aTxtApre    := {}
	Local aPaineis    := {}
	Local aItens      := {}
	Local aItDere     := {}
	Local lRet        := .T.
	Local cNomWiz     := "TAFAWIZD" + StrTran(cEmpAnt," ","") + StrTran(cFilAnt," ","")
	Local cMsgAux     := ""
	Local cURLTSS     := IIf( FindFunction( "TafGetUrlTSS" ), PadR(TafGetUrlTSS(),250), PadR(GetNewPar("MV_TAFSURL",""),250) ) // Utiliza função padronizada com compertilhamento de empresa
	Local cAmbeSocial := AllTrim(GetNewPar( "MV_TAFAMBE", "2" ))
	Local cAmbReinf   := ""
	Local cAmbDere    := ''
	Local dIniEs      := Stod(AllTrim(GetNewPar( "MV_TAFINIE", Space(8) )) )
	Local nAmbeSocial := 0
	Local nAmbReinf   := 0
	Local nAmbDere    := 0
	Local lDicDere    := AliasInDic('T7T') //valida se o dicionário referente as alterações da DERE foi aplicado.

	SuperGetMv()
	cAmbReinf	 := AllTrim(GetNewPar( "MV_TAFAMBR", "2" ))	
	cAmbDere	 := AllTrim(GetNewPar( "MV_TAFAMBD", ' ' ))	
	
	aAdd ( aTxtApre , STR0047 ) //"Rotina de Configuração do Ambiente TAF - Totvs Automação Fiscal"
	aAdd ( aTxtApre , "" )	
	aAdd ( aTxtApre , STR0002 ) //"Preencha corretamente as informações solicitadas."
	aAdd ( aTxtApre , STR0037 ) //"Esta rotina tem como objetivo ajuda-lo na configuração da integração com o Protheus/TAF com o serviço Totvs Services SOA. "
	
	
	//==================
	//|Montando Wizard |
	//==================	
	aAdd ( aPaineis , {} )
	nPos	:=	Len ( aPaineis )
	aAdd ( aPaineis[nPos] , STR0049 + " - " + STR0002 ) //"Parâmetros de Ambiente - Preencha corretamente as informações solicitadas."
	aAdd ( aPaineis[nPos] , STR0050 ) //"Informe a URL do servidor TSS e o ambiente do RET que o mesmo deve se conectar."
	aAdd ( aPaineis[nPos] , {} )
	
	aItens:= {STR0011,STR0051} //"1-Produção"#"2-Pré Produção"
	nAmbeSocial	:= aScan( aItens,{ |x| Left(x,1) == AllTrim( cAmbeSocial )} )
	nAmbReinf	:= aScan( aItens,{ |x| Left(x,1) == AllTrim( cAmbReinf )} ) 
	
	// O ambiente do Dere pode nao estar configurado, por isso o combo recebe
	// uma primeira opcao em branco, sem numeracao. 
	aItDere		:= { "", STR0011, STR0051 }
	nAmbDere	:= aScan( aItDere,{ |x| Left(x,1) == AllTrim( cAmbDere )} ) 
	
	If nAmbeSocial	== 0
		nAmbeSocial	:= 2
	EndIf
	If nAmbReinf == 0
		nAmbReinf := 2
	EndIf	

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {1,STR0033 + " e-Social",,,,,,});		aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,,,,,,,,,,nAmbeSocial}) //Ambiente
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd(aPaineis[nPos][3], {1,STR0056,,,,,,});				aAdd(aPaineis[nPos][3], {2,,,3,,,,,,,,,,,,,,,,,,dIniEs}) //'Data de Inicio da Empresa no eSocial'
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd(aPaineis[nPos][3], {1,STR0053,,,,,,});	 			aAdd (aPaineis[nPos][3], {0,"",,,,,,})		//"Url Totvs Service SOA"

	aAdd(aPaineis[nPos][3], {2,,,1,,,,150,,,,{ "xValWizCmp",11,{"",""}},,,,,,.T.,,,,cURLTSS});		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,STR0033 + " Reinf",,,,,,});	aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,,,,,,,,,,nAmbReinf}) //Ambiente

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,STR0033 + " Dere",,,,,,});	aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItDere),,,,,,,,,,,,,,,,nAmbDere,lDicDere}) //Ambiente (posicao 23 = WHEN: habilitado somente se o dicionario T7T existir)
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Espacamento apos combo Dere (evita out-of-bounds no VALID)
	
	aAdd ( aPaineis , {} )
	nPos := Len (aPaineis)
	aAdd (aPaineis[nPos], STR0002)
	aAdd (aPaineis[nPos], STR0054)
	aAdd (aPaineis[nPos], {})
	
	aItens:= {STR0014,STR0015,STR0016,"KeyStore"} //"Formato Apache (.pem)"#"Formato PFX (*.pfx ou *.p12)"#"HSM"       
	
	aAdd (aPaineis[nPos][3], {1,STR0013,,,,,,});										aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,, {"xFunVldWiz","CFG-CERTIFICADO"}}) //"Tipo de certificado digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0017,,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 	//"Nome do arquivo do certificado digital"
	aAdd (aPaineis[nPos][3], {2,,,1,,,,,,.T.,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0018,,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 	//"Informe o nome do arquivo do private key"
	aAdd (aPaineis[nPos][3], {2,,,1,,,,,,.T.,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0019,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100}) 	//"Slot do certificado digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0020,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100}) 	//"Label do certificado digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0021,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,,,.T.,.F.}) //"Senha do arquivo digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0022,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,/*{ "xValWizCmp",12,{"",""}}*/,,,,,}) //"Caminho e arquivo do módulo HSM" 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0057,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,/*{ "xValWizCmp",12,{"",""}}*/,,,,,}) //"ID Hexadecimal" 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,"Hostname",,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,"Issuer",,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,"Subject",,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aItens:= {"1-MY","2-Root","3-Trust","4-CA"} 
	aAdd (aPaineis[nPos][3], {1,"Path",,,,,,});											aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aItens:= {"1-LocalMachine","2-Default"} 
	aAdd (aPaineis[nPos][3], {1,"System",,,,,,});										aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aItens:= {"1-WinStore","2-LinuxStore"} 
	aAdd (aPaineis[nPos][3], {1,"Type",,,,,,});											aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	// TAFColumnPos( "C1E_CNPJTR" ) ****** VALIDAR SE EXISTE ESSE CAMPO NO COMEÇO DA WIZARD

	//Obs: Esta validação valida todos os campos no Next da Wizard
	cIniCnpj := Posicione("C1E",3,xFilial( "C1E" ) + PadR( SM0->M0_CODFIL , TamSX3( 'C1E_FILTAF' )[1] ) + '1' ,"C1E_CNPJTR")		
	aAdd (aPaineis[nPos][3], {1,STR0058,,,,,,})	//"CNPJ/CPF Transmissor (Diferente do Empregador)"
	aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,{ "xValWizCmp",12,{"",""}},,,,,,,,,,cIniCnpj})

	aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	// Se o Ambiente Dere (combo do painel 1, indice 26) estiver vazio, pula o painel
	// de credenciais (painel 3) e vai direto para a conclusao (painel 4).
	aAdd( aPaineis[nPos], 'iif( DereVazio( aVarPaineis ), ( oWizard:nPanel := 4, .t. ), .t. )' )

	//Painel de credenciais para geração de token e acesso ao Dere
	aAdd ( aPaineis , {} )
	nPos := Len (aPaineis)
	aAdd (aPaineis[nPos], STR0002) //"Preencha corretamente as informações solicitadas."
	aAdd (aPaineis[nPos], 'Informe as credenciais para geração de token e acesso ao Dere.')
	aAdd (aPaineis[nPos], {})

	aAdd (aPaineis[nPos][3], {1,'Client ID',,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.,.t.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,'Client Secret',,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.,.t.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	//Valid de saida do painel de credenciais (botao Avancar): valida Client ID e Client Secret
	//de uma unica vez, em vez de campo a campo. Executado pelo bNext apos o xValWizd (vide xFunWizard).
	aAdd (aPaineis[nPos], 'VldCredent( aVarPaineis )')

	aAdd ( aPaineis , {} )
	nPos := Len (aPaineis)
	aAdd (aPaineis[nPos], "")
	aAdd (aPaineis[nPos], STR0001)
	aAdd (aPaineis[nPos], {})
	
	cMsgAux := STR0046 //"Você concluíu com sucesso a configuração da integração do Protheus/TAF para o Totvs Services SOA."
	aAdd (aPaineis[nPos][3], {8,,,,,,,,,,,,,,,,,,.F.,.F.,cMsgAux})

	// Voltar (posicao 5) do painel de conclusao: se o Ambiente Dere (combo do painel 1,
	// indice 26) estiver na opcao vazia, retorna ao painel de certificado (painel 2)
	// pulando o painel de credenciais (painel 3). O framework decrementa 1 apos avaliar
	// o bBack, por isso seta-se 4 para chegar no painel 3 (vide xValWizB / padrao AF175Back).
	aAdd( aPaineis[nPos], Nil )
	aAdd( aPaineis[nPos], 'iif( DereVazio( aVarPaineis ), ( oWizard:nPanel := 4, .t. ), .t. )' )

	lRet	:=	XFUNWizard ( aTxtApre , aPaineis , cNomWiz,,,, { || GrParamAmb(), GrParamIniEs(), GrTafAmbRe(), GrvAmbDere() } )
	
Return Nil  

//-------------------------------------------------------------------
/*/{Protheus.doc} DereVazio
Indica se o combo Ambiente Dere (painel 1, componente 26) esta na opcao
vazia (primeira opcao do combo, cujo aItDere e { "", ... }).

O TComboBox armazena em aVarPaineis[1,26,1] o INDICE NUMERICO do item
selecionado (vide TControl:bSetGet). Como a opcao vazia e a primeira do
array aItDere, o combo esta vazio quando o indice e 1. O tratamento por
ValType cobre o caso de reinicializacao via profile, em que o valor pode
vir como texto (ex.: "" para a opcao vazia).

@type Function
@author silva.carlos
@since 02/09/2026
@param aVarPan - Array aVarPaineis do wizard (conteudos dos componentes)
@return lVazio - .T. se o Ambiente Dere estiver na opcao vazia
/*/
//-------------------------------------------------------------------
Function DereVazio( aVarPan )

	Local lVazio	:= .T.
	Local cConteudo	:= ''

	Default aVarPan := {}

	// Protege contra o array ainda nao montado (out-of-bounds)
	If Len( aVarPan ) >= 1 .And. Len( aVarPan[1] ) >= 26 .And. ValType( aVarPan[1,26] ) == "A" .And. Len( aVarPan[1,26] ) >= 1
		cConteudo := aVarPan[1,26,1]
		lVazio := Empty(cConteudo)
	EndIf

Return lVazio

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCredent
Valida, na saida do painel de credenciais (botao Avancar), se o Client ID
e o Client Secret foram preenchidos. Substitui a validacao campo a campo
que era feita pelos casos 15 e 16 da xValWizCmp.

A funcao PRECISA ser publica (Function), e nao Static, porque e referenciada
na posicao 4 do painel e compilada via macro &() dentro da xFunWizard (fonte
TAFXFUN.PRW). A macro resolve o nome em runtime no escopo daquela funcao, onde
uma Static Function deste fonte nao seria visivel (mesmo motivo de DereVazio).

Quando o Ambiente Dere esta na opcao vazia, a navegacao (posicao 4 do painel
de certificado) ja pula o painel de credenciais, de modo que esta funcao so e
executada quando o painel e efetivamente exibido.

Indices em aVarPainel (painel 3, na ordem dos componentes montados):
   [3][3][1] -> conteudo do MSGET Client ID
   [3][9][1] -> conteudo do MSGET Client Secret

@type Function
@author silva.carlos
@since 02/09/2026
@param aVarPainel - Array aVarPaineis do wizard (conteudos dos componentes)
@return lRet   - .T. quando as credenciais estao validas
/*/
//-------------------------------------------------------------------
Function VldCredent( aVarPainel )

	Local lRet		 := .t.
	Local cClientId	 := ''
	Local cClientSec := ''
	Local cResponse  := ''

	Default aVarPainel := {}

	//Protege contra o array ainda nao montado (out-of-bounds)
	If Len( aVarPainel ) >= 3 .And. Len( aVarPainel[3] ) >= 9
		cClientId	:= AllTrim( cValToChar( aVarPainel[3,3,1] ) )
		cClientSec	:= AllTrim( cValToChar( aVarPainel[3,9,1] ) )
	EndIf

	If Empty( cClientId )
		MsgInfo( STR0059 ) //'O campo Client ID deve ser preenchido.'
		lRet := .f.
	ElseIf Empty( cClientSec )
		MsgInfo( STR0060 ) //'O campo Client Secret deve ser preenchido.'
		lRet := .f.
	else
		if !GrvCredent(cClientId, cClientSec, @cResponse)
			MsgInfo( STR0061 + cResponse ) //'Credenciais não pudeream ser gravadas: '
			lRet := .f.
		else
			MsgInfo( STR0062 + cResponse ) //'Credenciais gravadas com sucesso!!! '
		endif
	endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrParamAmb
O objetivo da function é gravar o valor configurado na wizard para 
o parâmetro de ambiente do eSocial. 

@author Vitor Siqueira
@since 06/02/2017
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
Static Function GrParamAmb() 
Local aWizard := {}	
Local cConteudo := ""
Local cNomWiz := "TAFAWIZD" + StrTran(cEmpAnt," ","") + StrTran(cFilAnt," ","")
	
	//Carrega os dados preenchidos na wizard
	XFUNLoadProf( cNomWiz , @aWizard )	
	If Len( aWizard ) > 0 .And. Len( aWizard[1] ) > 0
		cConteudo := SubStr(aWizard[1][1],1,1)
			
		//Altera o conteudo do parâmetro
		If GetMV("MV_TAFAMBE",.T.)
			PutMv('MV_TAFAMBE', cConteudo)
		Endif
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrParamIniEs
O objetivo da function é gravar o valor configurado na wizard para 
o parâmetro de data de inicio da empresa no eSocial

@author Luccas Curcio
@since 26/05/2017
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
static function GrParamIniEs() 

local aWizard	as	array
local cConteudo	as	char
Local cNomWiz	as char

aWizard := {}	
cConteudo := ""
cNomWiz := "TAFAWIZD" + StrTran(cEmpAnt," ","") + StrTran(cFilAnt," ","")
	
//Carrega os dados preenchidos na wizard
XFUNLoadProf( cNomWiz , @aWizard )	

If Len( aWizard ) > 0 .And. Len( aWizard[1] ) > 1

	cConteudo := allTrim( Dtos(aWizard[ 1 , 2 ]) )

	//Altera o conteudo do parâmetro
	If GetMV("MV_TAFINIE",.T.)
		PutMv('MV_TAFINIE', cConteudo)
	Endif

EndIf
return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrTafAmbRe
O objetivo da function é gravar o valor configurado na wizard para 
o parâmetro de ambiente do Reinf

@author anieli.rodrigues
@since 20/03/2017
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
Static Function GrTafAmbRe() 

	Local aWizard	as	array
	Local cConteudo	as	char
	Local cNomWiz	as	char
 
	aWizard 	:= {}	
	cConteudo 	:= ""
	cNomWiz 	:= "TAFAWIZD" + StrTran(cEmpAnt," ", "") + StrTran(cFilAnt, " ", "")
		
	//Carrega os dados preenchidos na wizard
	XFUNLoadProf( cNomWiz , @aWizard )	

	If Len( aWizard ) > 0 .And. Len( aWizard[1] ) > 3
			
		cConteudo := SubStr(aWizard[1][4],1,1)

		//Altera o conteudo do parâmetro
		If GetMV("MV_TAFAMBR",.T.)
			PutMv('MV_TAFAMBR', cConteudo)
		Endif
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvAmbDere
O objetivo da function é gravar o valor configurado na wizard para 
o parâmetro de ambiente do Dere

@author silva.carlos
@since 01/09/2026
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
Static Function GrvAmbDere() 

	Local aWizard	as	array
	Local cConteudo	as	char
	Local cNomWiz	as	char
 
	aWizard 	:= {}	
	cConteudo 	:= ""
	cNomWiz 	:= "TAFAWIZD" + StrTran(cEmpAnt," ", "") + StrTran(cFilAnt, " ", "")
		
	//Carrega os dados preenchidos na wizard
	XFUNLoadProf( cNomWiz , @aWizard )	

	If Len( aWizard ) > 0 .And. Len( aWizard[1] ) > 4
			
		cConteudo := SubStr(aWizard[1][5],1,1)

		//Altera o conteudo do parâmetro
		If GetMV("MV_TAFAMBD",.T.)
			PutMv('MV_TAFAMBD', cConteudo)
		Endif
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCredent
O objetivo da function e gravar as credenciais (Client ID e Client
Secret) informadas na wizard, enviando-as ao TSS pela operacao
CFGCREDENTIALS do servico SPEDCFGNFE atraves da classe TWsdlManager.

@author silva.carlos
@since 01/09/2026
@version 1.0

@return Nil
/*/
//-------------------------------------------------------------------
Static Function GrvCredent(cClientId, cClientSec, cResponse)

	Local oWsdl		:= TWsdlManager():New() 
	Local aSimple	:= {}
	Local cURL		:= AllTrim(GetNewPar( 'MV_TAFSURL', '' ) )
	Local cXmlRet	:= ''
	Local nPos		:= 0
	Local lRet		:= .f.

	//Parse do WSDL do servico de configuracao
	if oWsdl:ParseURL( Lower( cURL ) + '/SPEDCFGNFE.apw?WSDL' )
		//Define a operacao de configuracao das credenciais
		lRet := oWsdl:SetOperation( 'CFGCREDENTIALS' )
	EndIf

	//Preenche os campos de entrada do tipo simples pelo nome
	If lRet
		aSimple := oWsdl:SimpleInput()

		nPos := aScan( aSimple, { |x| AllTrim( Upper( x[2] ) ) == 'USERTOKEN' } )
		If nPos > 0
			oWsdl:SetValue( aSimple[nPos][1], 'TOTVS' )
		EndIf

		nPos := aScan( aSimple, { |x| AllTrim( Upper( x[2] ) ) == 'ID_ENT' } )
		If nPos > 0
			oWsdl:SetValue( aSimple[nPos][1], AllTrim( TAFRIdEnt() ) )
		EndIf

		nPos := aScan( aSimple, { |x| AllTrim( Upper( x[2] ) ) == 'CLIENT_ID' } )
		If nPos > 0
			oWsdl:SetValue( aSimple[nPos][1], cClientId )
		EndIf

		nPos := aScan( aSimple, { |x| AllTrim( Upper( x[2] ) ) == 'CLIENT_SECRET' } )
		If nPos > 0
			oWsdl:SetValue( aSimple[nPos][1], cClientSec )
		EndIf

		//Envia a mensagem SOAP
		lRet := oWsdl:SendSoapMsg()
	EndIf

	//Le a resposta do servico
	If lRet
		cXmlRet := oWsdl:GetSoapResponse()
		lRet	:= !Empty( cXmlRet )
	else
		cResponse := DecodeUTF8(oWsdl:cFaultString)
	EndIf

	FreeObj( oWsdl )

Return lRet
