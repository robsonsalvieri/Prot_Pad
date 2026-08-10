#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH"    
#INCLUDE "APWIZARD.CH"
#INCLUDE "COLORS.CH" 
#INCLUDE "TAFINIT.CH"
#Include 'DbTree.ch'
#Include "FWBROWSE.CH"

Static cEnter 	   := Chr(13) + Chr(10)
//							nome.arquivo    Hdle    nome.arquivo    Hdle
Static aTAFInUse   := { { 'TAFINUSE1' + cEmpAnt + '.lck', 0 }, { 'TAFINUSE2' + cEmpAnt + '.lck', 0 } }	//Variavel static para controle de semaforos de acessso ao TAF
Static cDtTabTAFSD := '20220101' // Data da ultima alteração da estrutura das tabelas compartilhadas do TAF no fonte TAFXINTEG.
Static lAtuTabTAF  := .F.
Static oCSS		   := totvs.framework.css.ProtheusTheme():New()

//-------------------------------------------------------------------
/*/{Protheus.doc} FGravaSx6
Rotina de inicialização dos assistentes de validação e configuração do ambiente

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return lRet - (.T.) Ok ou (.F.) NOK 
/*/
//-------------------------------------------------------------------
Function TAFInit(lAutomato)
Local 	lTafWizard
Local	lRet
Local 	lCallWiz
Local	cTAFLck
Local	lInitTAF
Local	lTAFLdCpl
Local	lTAFLdTbls
//Local	nHandle
Local	cTexto
Local	aTAFVldAC
Local 	cVerLayout
Local   lTAFISch

Default lAutomato := .f.

If cPaisLoc <> "BRA"
	Final( STR0147 ) //"TOTVS Automação Fiscal está disponível somente para o Brasil!"
EndIf

lCallWiz   			:= Upper( Substr( Alltrim( FunDesc() ), 1, 3 ) ) == 'WIZ' .Or. lAutomato
cTexto				:= ''
cTAFLck				:= 'TAFINIT.lck'
lRet				:= .T.
lTafWizard  		:= GetNewPar( 'MV_TAFWIZ', .T. )
cVerLayout			:= GetMv('MV_TAFVLES',.F.,"02_05_00") 

//Computa lock de acessos ao TAF - Não deve computar quando chamado via menu
If !lCallWiz
	TAFUseLck()
EndIf

//Variaveis que recebem alguma divergencia da estrutura; quando alguma delas estiverem como .T., significa que alguma inconsistencia foi encontrada.
//	Antes de chamar a funcao que avaliar o ambiente, verifica se alguem ja acessou o TAF; se SIM, significa que nao tem mais inconsistencias, ja que o TAF soh libera acesso a qualquer usuario quando tudo estiver OK para todas as EMPRESAS.
lInitTAF	:= TAFInUse() .Or. InitTAF( .T. )
lTAFLdCpl	:= TAFInUse() .Or. TAFLdCplEmpresa( .T. )
aTAFVldAC	:= TAFVldAC()
lTAFLdTbls	:= TAFInUse() .Or. aTAFVldAC[ 2 ]
lST2Stru	:= TAFST2Vld()
lVldComplem	:= VldComplem()
lTAFISch	:= (/*GetRPORelease() == "12.1.2410" .Or.*/ SuperGetMv("MV_TAFDEV",, .F.)) .And. Empty(GetMV("MV_TAFISCH",, "")) // O valor default do parâmetro MV_TAFISCH não pode ser "0" neste caso, pois se o mesmo estiver em branco, o Wizard de Configuração do TAF é executado quando o sistema é aberto no release 12.1.2410 ou caso o parâmetro MV_TAFDEV esteja habilitado independente das autocontidas ou demais configurações do TAF estarem atualizadas ou não.
lProcWiz	:= lCallWiz .Or. ((!lInitTAF .Or. !lTAFLdCpl .Or. !lTAFLdTbls .Or. !lST2Stru .Or. lTAFISch) .And. lTafWizard)
//Chamada para cachear a array aFils e melhorar a perfomance do monitor po ui reinf
WsLoadFil( ) //utiliza parametros default lJob := .F. cFilterFil := ".T."

//Qualquer configuração somente pode ser executada pelo ADMIN
If ( lCallWiz .And. !FWIsAdmin( __cUserID ) ) .Or.;
	( !lCallWiz .And. lProcWiz .And. !FWIsAdmin( __cUserID ) ) 
	If lCallWiz
		lRet	:=	.F.
		MsgInfo( STR0001 + FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" ) + STR0002, STR0003 )	//'Somente usuários com perfil de Administradores possuem acesso a esta funcionalidade; este( '###' ) em questão não tem este perfil, entre em contato com o administrador do sistema para que libere o acesso se necessário.'###'Somente usuários Administradores...'
		
	//Em caso de alguma inconsistencia no ambiente, o acesso ao TAF somente é liberado após a regularização.
	Else
		lRet	:=	.F.
		Final( STR0004 )	//'Ambinente inconsistente, ACESSE COMO ADMINISTRADOR para mais detalhes!'
	EndIf
EndIf
	
If lRet .And. lCallWiz
	If TAFInUse() 	//Caso tenha mais de um usuário conectado e o wizard for acionado, não deve permitir executar; somente em modo exclusivo. 
		cTexto	:=	STR0006			//'O assistente de configuração do TAF NÃO PODE SER INICIADO NO MOMENTO porque NÃO CONSEGUE obter acesso EXCLUSIVO ao sistema; por se tratar de um processamento inicial importante para o correto funcionamento do TAF, que inclusive altera a estrutura do produto, será necessário aguardar o seu término.'
		lRet	:=	.F.
	EndIf
EndIf

If lRet .And.  !( LockUpdAC() ) //( nHandle := TAFLck( cTAFLck ) ) < 0	//Caso haja alguma manuntenção no ambiente, devo travar qualquer entrada de outro usuário até que termina a atualização
	cTexto	:=	STR0005			//'O assistente de configuração do TAF ESTÁ EM EXECUÇÃO por outro usuário; trata-se de um processamento EXCLUSIVO e muito importante para o correto funcionamento do produto, será NECESSÁRIO AGUARDAR o término do outro processo.'
	lRet	:=	.F.	
EndIf
 	
If !lRet .And. !Empty( cTexto )  		
	If !IsBlind()				
		MsgAlert( cTexto )	
		If !lCallWiz
			Final( STR0124 )	//'Acesso ao TAF bloqueado - processo EXCLUSIVO em execução!'
		EndIf
	Else
		TAFConOut( DToS( Date() ) + ' ' + Time() + ' -> TAFINIT.PRW: ' + cTexto,2,.T.,"AUTCONT" )	//'O assistente de configuração do TAF já está sendo executado por outro usuário, por se tratar de um processamento inicial importante para o correto funcionamento do TAF, que inclusive altera a estrutura do produto, será necessário aguardar o seu término.'
	EndIf
EndIf

//Executar somente quando a chamada vier através do MENU ou na inicialização quando houver alguma inconsistencia no ambiente
If (lRet .And. lProcWiz) .Or. lAutomato

	If !IsBlind() .and. !lAutomato
		//Assistente de inicialização que valida o resultado do diagnóstico
		If !lInitTAF .And. !lCallWiz	//Somente executa na chamada do menu o assistente para processamento das autocontidas e criação das tabelas de controle
			lRet := InitTAF( .F. )
		EndIf
		
		//Assistente que valida o complemente de empresa para as empresas cadastradas no sigamat. 
		If( lRet .And. !lTAFLdCpl ) .And. !lCallWiz	//Somente executa na chamada do menu o assistente para processamento das autocontidas e criação das tabelas de controle
			lRet := TAFLdEmpresas( )
		EndIf
		
		//Assistente que valida as autocontidas e atualiza as tabelas do SGBD e integração			
		If (lRet .And. !lTAFLdTbls) .Or. lCallWiz .Or. !lST2Stru .Or. lTAFISch
			lRet := TAFLdTbls( lCallWiz, aTAFVldAC )
		EndIf
		
	Else	//Caso haja algum problema, este deve ser analisado em modo interface e nao em job
		If ( !lInitTAF .Or. !lTAFLdCpl .Or. !lTAFLdTbls .OR. lAutomato )
			TAFConOut( DToS( Date() ) + ' ' + Time() + ' -> TAFINIT.PRW: ' + STR0007,3,.T.,"AUTCONT" )	//'Ambinente inconsistente; para maiores detalhes, acessar utilizando interface visual e seguir as orientações apresentadas!'
			if !lAutomato ;KillApp(.T.);Endif
		EndIf			
	EndIf
EndIf

If lRet
	//Libera o sistema para os outros usuários
	//TAFUnLck( nHandle, cTAFLck )
	UnLockUpdAC()
EndIf

If lAutomato
	lRet := lProcWiz
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} InitTAF
Funcao que permite validar a infra-estrutura do TAF ( binario, rpo, autocontidas, layoutTOTVS, integração, dbAccess, autoincremento, CLOB)

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam lVldOnly, flag de chamada de funcao de forma a efetuar somente uma validação de ambiente; (.T.) ambiente OK, ou (.F.) ambiente com inconsistencia;	

@return lRet, (.T.) OK ou (.F.) NOK 
/*/
//-------------------------------------------------------------------
Static Function InitTAF( lVldOnly )
Local	cTitulo
Local	cMensagem
Local	aDiag
Local	nX
Local	cMsgDiag
Local	nOpcAv
Local	aBotoes
Local	lRet

nX					:=	0
cMsgDiag			:=	''  
lRet				:=	.T.
aDiag				:=	TAFVldStart()/*	[01] - Totvs Application Server
  										[02] - Totvs DbAccess (TopConnect)
  										[03] - LIB
  										[04] - Chave TopMemoMega no .INI
    									[05] - Auto Recno
    									[06] - CLOB
    									[07] - Dicionário
    									[08] - RPO
    									[09] - layout.def
    									[10] - autocontidas.taf*/

For nX := 1 To Len( aDiag )
	If nX==5
		If !Empty( aDiag[ nX ] )
			cMsgDiag := STR0008	//'Auto Recno( recno incremental )'
		EndIf
	ElseIf nX==7 .or. nX==8
		If AllTrim( aDiag[8] ) <> AllTrim( StrTran( aDiag[7], "Dicionário maior ou igual a ", "" ) )
			If AllTrim( aDiag[8] ) >= "08/2021" .and. AllTrim( aDiag[7] ) == "Desatualizado - Anterior a 05/2021"
				If FindFunction( "EngRefTaf" ) //Esta função não é gerada no D-1, com isso o ambiente pode ficar em loop informando divergência de Dicionário e Repositório.
					cMsgDiag := STR0009 //"Dicionário do TAF está incompatível com o Repositório de Objetos( RPO )"
				EndIf
			EndIf
		EndIf
		nX += 1
	ElseIf nX==9 .Or. nX==6 .Or. nX==13
	ElseIf ( !aDiag[ nX ] )
		Do case
			Case nX==1; cMsgDiag := STR0010	//'Totvs Application Server'
			Case nX==2;	cMsgDiag := STR0011	//'Totvs DbAccess (TopConnect)'
			Case nX==3;	cMsgDiag := 'LIB'
			Case nX==4;	cMsgDiag := STR0012	//'Chave TopMemoMega no .INI'
			Case nX==9;	cMsgDiag := STR0013	//'Layout de integração'
			//Nao valido a autocontida aqui porque faco o processamento depois, dentro da funcao TAFLdTbls()
			//Case nX==10;cMsgDiag := 'Tabelas Autocontidas'
			Case nX==11;cMsgDiag := 'Uso de SGBD Homologado'
		End
		Exit
	EndIf
Next nX

//No de necessitar somente se ha problema ou nao, esta variavel estará com o.T. 
If lVldOnly
	If !Empty( cMsgDiag )
		lRet	:=	.F.
	EndIf

Else
	nOpcAv				:=	0
	aBotoes   			:= 	{ STR0014 , STR0015 }	//'Diagnóstico'###'Sair'
	cTitulo 			:=  STR0016	//'Inicialização do TAF' 
	cMensagem 			:= 	STR0017 + cEnter	//'BEM VINDO'
	cMensagem 			+= 	STR0018 + cEnter + cEnter	//'ao assistente de inicialização do TAF.'
	cMensagem 			+= 	STR0019 + cEnter + cEnter	//'Este processamento realiza uma checagem do ambiente e permite efetuar as atualizações necessárias para o correto funcionamento da aplicação.'
	If !Empty( cMsgDiag )
		While nOpcAv==0
			cMensagem 	+= 	STR0020 + cEnter + cEnter	//'Idenficamos que os pré-requisitos de infra-estrutura da aplicação não estão atendidos corretamente, isso se deve a alguma falha no processo de atualização.'
			cMensagem 	+= 	STR0021 + Upper( cMsgDiag ) + '>>' + cEnter + cEnter	//'Pré-requisito identificado: <<'
			cMensagem 	+= 	STR0022	//'A opção "Diagnóstico" pode ser utilizada para se obter mais detalhes, inclusive emitir um extrato técnico do ambiente para análise. Maiores detalhes também estão disponíveis no TDN( http://tdn.totvs.com/pages/releaseview.action?pageId=198934697 ).'
			nOpcAv		:=	Aviso( cTitulo, cMensagem, aBotoes, 3 )
			If nOpcAv==1
				TAFDIAG()
				nOpcAv	:=	0
				
			ElseIf nOpcAv==2
			 	Exit
			EndIf
		End
		Final( STR0023 )	//'Não será possível o acesso sem ajustar a(s) incompatibiliade(s).'
	EndIf
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLdEmpresas
Funcao que monta um assistente que permite efetuar o cadastramento dos estabelecimentos e a amarracao com o complemento de empresas.

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@return lRet, (.T.) OK ou (.F.) NOK 
/*/
//-------------------------------------------------------------------
Static Function TAFLdEmpresas( )
Local	cTitObj1
Local	cTitObj2
Local	aTxtApre
Local	aPaineis
Local	aItens1
Local	aItens2
Local	lRet
Local 	lBackIni
Local 	nPos
Local	nX
Local	lProc
Local	nTamCmpDlg
Local	lChkEntendi
//Local	oLinkMDet

lChkEntendi			:=	.F.
cTitObj1			:=	""
cTitObj2			:=	""
aTxtApre			:=	{}
aPaineis			:=	{}
aItens1				:=	{}
aItens2				:=	{}
lRet				:=	.T.
lBackIni			:= 	.T.
nPos				:=	0
nX 	  				:= 	0
lProc				:=	.F.
nTamCmpDlg			:=	115
nLargLin			:=	270
nAltLinha			:=	10
lRet 				:=	.F. 

Define WIZARD oWizard;
	TITLE STR0024;				//'Configuração Iniciais do TAF'
	HEADER '';
	MESSAGE STR0025;			//"Preencha corretamente as informações solicitadas."
	TEXT STR0026 + '<br>' + ;	//"Este assistente é apresentado quando <b>detectado uma divergência entre os estabelecimentos cadastrados no TAF e suas informações complementares</b>. Visa possibilitar uma revisão cadastral e ajustes das divergências."
		 STR0027 + '<br><br>' + ;	//"Em um primero momento, antes da apresentação deste assistente, uma análise de toda a infraestrutura foi executada e tudo está conforme estabelecido pela TOTVS, permitindo assim prosseguir com as configurações complementares para o correto funcionamento do TAF."
		 STR0028;				//"<b>Itens avaliados com SUCESSO:</b><ul><li>Binário<li>Recno incremental<li>DBAccess<li>Release de Dicionário x RPO</ul>"
	NEXT { || .T. };
	FINISH { || .T. };
	NOTESC

//CREATE PANEL oWizard;
//		HEADER STR0043;		//"Siga corretamente os procedimentos indicados abaixo."
//		MESSAGE STR0044;	//"Criação da infraestrutura do sistema baseado nas empresas configuradas."
//		BACK { || .T. };
//		NEXT { || TAFLdMsg( 5, lChkEntendi, Nil, Nil, Nil, Nil ) };
//		FINISH { || .T. }
		
//		nLinha		:=	10
//		nColuna		:=	10
//		nAltLinha	:=	10	
//		oPnl		:= 	TPanel():New( 0, 0, , oWizard:oMPanel[ 2 ],, .F., .F.,,, nLargLin, 138, .T., .F. )
//		TSay():New( nLinha, nColuna, { || '<b>' + STR0045 + '<b>' }, oPnl,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'IMPORTANTE:'
//		
//		nLinha	+=	10
//		TSay():New( nLinha, nColuna, { || STR0046 }, oPnl,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha+20,,,,,,.T. )	//'A execução deste assistente permite ajustar os códigos complementares de integração para cada um dos estabelecimentos cadastrados no TAF. Após estes ajustes, <b>é necessário efetuar um primeiro acesso em cada um dos grupos de estabelecimentos</b> criados para que todos os recursos sistêmicos sejam instanciados e habilitados para operação.'
//
//		nLinha	+=	30
//		TSay():New( nLinha, nColuna, { || STR0142 }, oPnl,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha+30,,,,,,.T. )	//'Tais como:<ul><li>Dicionário de dados<li>Tabelas autocontidas<li>Componentes de integração</ul><br>[i] Os estabelecimentos que não possuírem os recursos sistêmicos instanciados, <b>não poderão seguir com as configurações</b> necessárias para o correto funcionamento.'		
//		
//		nLinha	+=	40
//		TSay():New( nLinha, nColuna, { || STR0143 }, oPnl,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha+10,,,,,,.T. )	//'(i) Este assistente permite efetuar uma configuração básica ( 1 x 1 ), porém para necessidades mais específicas, deve-se utilizar a opção diretamente no menu do TAF.'
//
//		nLinha	+=	20
//		TCheckBox():New( nLinha, nColuna, STR0125,{|| lChkEntendi }, oWizard:oMPanel[ 2 ], nLargLin, nAltLinha,,{|| lChkEntendi := !lChkEntendi },,,,,, .T.,,)	//'Li e entendi que DEVO INICIALIZAR O SISTEMA PARA TODOS OS GRUPOS DE EMPRESAS CADASTRADOS.'
//		
//		nLinha	+=	15
//		oLinkMDet	:=	TSay():New( nLinha, nColuna, { || '<b>' + STR0144 + '<b>' }, oPnl,,,,,, .T., CLR_RED,, nLargLin, nAltLinha,,,,,,.T. )	//'Para mais detalhes sobre esta funcionalidade, clique aqui.'
//		oLinkMDet:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com.br/pages/viewpage.action?pageId=248579940","","",1) }
		
CREATE PANEL oWizard;
		HEADER STR0043;		//"Siga corretamente os procedimentos indicados abaixo."
		MESSAGE STR0044;	//"Criação da infraestrutura do sistema baseado nas empresas configuradas."
		BACK { || .T. };
		NEXT { || lRet := TAFLdCplEmpresa( .F. ) };
		FINISH { || lRet := TAFLdCplEmpresa( .F. ) }

		nLinha		:=	10
		nColuna		:=	10
		nLargLin	:=	160
		nAltLinha	:=	20
		
		//TSay():New( nLinha, nColuna, { || STR0031 }, oWizard:oMPanel[ 3 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )		//"Estrutura dos Estabelecimentos"
		//TSay():New( nLinha, nColuna+120, { || STR0032 }, oWizard:oMPanel[ 3 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//"As opções abaixo são utilizadas para estruturar os estabelecimentos."
		//
		//nLinha		+=	20
		//TButton():New( nLinha, nColuna, STR0033, oWizard:oMPanel[ 3 ], {|| FWCADGRPCO()}, nTamCmpDlg, 15,,,, .T. )						//"Grupo de Empresas"
		//TSay():New( nLinha, nColuna+120, { || STR0034 }, oWizard:oMPanel[ 3 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//"Representa um Grupo de Empresas."
		//
		//nLinha		+=	20
		//TButton():New( nLinha, nColuna, STR0035, oWizard:oMPanel[ 3 ], {|| FWCADCOMPA()}, nTamCmpDlg, 15,,,, .T. )						//"Empresas"
		//TSay():New( nLinha, nColuna+120, { || STR0036 }, oWizard:oMPanel[ 3 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//"Deve representar as Empresas vinculadas ao Grupo de Empresas."
		//
		//nLinha		+=	20
		//TButton():New( nLinha, nColuna, STR0037, oWizard:oMPanel[ 3 ], {|| FWCADUNIDN()}, nTamCmpDlg, 15,,,, .T. )						//"Unidade de Negócios"
		//TSay():New( nLinha, nColuna+120, { || STR0038 }, oWizard:oMPanel[ 3 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//"Uma empresa pode ter várias Unidades de Negócios."
		
		//nLinha		+=	20
		//TButton():New( nLinha, nColuna, STR0039, oWizard:oMPanel[ 3 ], {|| FWCADFILIA()}, nTamCmpDlg, 15,,,, .T. )						//"Filial"
		//TSay():New( nLinha, nColuna+120, { || STR0040 }, oWizard:oMPanel[ 3 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//"Para cada Unidade de Negócio pode-se haver diversas Filiais vinculadas."
		
		// ---- backup do painel 3
		//nLinha		+=	20
		//TButton():New( nLinha, nColuna, STR0041, oWizard:oMPanel[ 3 ], {|| TAFLdCplEmpresa( .F. )}, nTamCmpDlg, 15,,,, .T. )			//"Efetuar amarração dos Estabelecimentos"
		//TSay():New( nLinha, nColuna+120, { || STR0042 }, oWizard:oMPanel[ 3 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha+5,,,,,,.T. )	//"Permite efetuar as amarrações de todos os Estabelecimento cadastrados com a as informações complementares exigidas nos processamentos do TAF."
		
		nLinha		+=	20
		TButton():New( nLinha, nColuna, STR0041, oWizard:oMPanel[ 2 ], {|| TAFLdCplEmpresa( .F. )}, nTamCmpDlg, 15,,,, .T. )			//"Efetuar amarração dos Estabelecimentos"
		TSay():New( nLinha, nColuna+120, { || STR0042 }, oWizard:oMPanel[ 2 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha+5,,,,,,.T. )	//"Permite efetuar as amarrações de todos os Estabelecimento cadastrados com a as informações complementares exigidas nos processamentos do TAF."
		
		nLargLin	:=	280
		
		nLinha		+=	40
		cTxt1 := "Após finalizar a amarração dos estabelecimentos, você pode incluir nova estrutura de Empresas através da opção de menu: Atualizações -> Empresa -> Cadastro."
		TSay():New( nLinha, nColuna, { || cTxt1 }, oWizard:oMPanel[ 2 ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )		//"Estrutura dos Estabelecimentos"
 		
Activate WIZARD oWizard Centered 				

If !lRet 
	Final( STR0047 )	//'Configurações inconsistentes, não será possível acessar o TAF.'
Else
	Final( STR0048 )	//'Configurações executadas COM SUCESSO, reinicialização obrigatória.'
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLdCplEmpresa
Funcao que efetua a validacao dos estabelecimentos cadastrados x complemento de empresa; também permite fazer a amarracao automatica.

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam lVldOnly, flag de chamada de funcao de forma a efetuar somente uma validação das amarracoes SIGAMAT X C1E; (.T.) ambiente OK, ou (.F.) amarracao com inconsistencia;	

@return lRet, (.T.) OK ou (.F.) NOK  
/*/
//-------------------------------------------------------------------
Function TAFLdCplEmpresa( lVldOnly )
Local	oDlg
Local	oLayer
Local	oPanel
Local	oBrowse
Local	oBrowseSM0
Local	aSM0
Local	nX
Local	aMsg
Local	aMsg2
Local	lAjuste
Local	cXFilialC1E
Local	lSeekC1E
Local	aUseC1E
Local	bOk
Local	bCancel
Local	aButEnc
Local 	TmCodFil := TamSX3( "C1E_CODFIL" )[1]
//Local	lInconsist

aSM0				:=	FWLoadSM0( !lVldOnly )
nX					:=	0
aMsg				:=	{}
aMsg2				:=	{}
lAjuste				:=	.F.
cXFilialC1E			:=	''
aUseC1E				:=	{}
bOk					:=	{|| TAFInGrv( aMsg ), oDlg:End() }
bCancel				:=	{|| oDlg:End() }
bAjCompl			:=	{|| TAFInMk( aMsg, oBrowseSM0, .F. ) }
bAjNPI				:=	{|| TAFInMk( aMsg, oBrowseSM0, .T. ) }
aButEnc				:=	{   { '', bAjCompl, OemToAnsi( STR0127 + ' <F8>...' ), OemToAnsi( STR0127 ) },; //'Ajustar Código Complementar'###'Ajustar Código Complementar'
 							{ '', bAjNPI, OemToAnsi( STR0126 + ' <F9>...' ), OemToAnsi( STR0126 ) }}	//'Ajustar Cód. Complementar NPI'###'Ajustar Cód. Complementar NPI'

dbSelectArea("C1E")
dbSetOrder(3)
cXFilialC1E	:=	Space( FWGETTAMFILIAL )

For nX := 1 To Len( aSM0 )
	If aSM0[ nX , SM0_USEROK ] .And. ( ValType( aSM0[ nX , SM0_EMPOK] ) == "U" .Or. aSM0[ nX , SM0_EMPOK ] )
		//aAdd( aMsg, { Space( TamSx3( 'C1E_CODFIL' )[ 1 ]), aSM0[ nX , SM0_GRPEMP ], aSM0[ nX , SM0_DESCGRP ], aSM0[ nX , SM0_CODFIL ], aSM0[ nX , SM0_NOME ], aSM0[ nX , SM0_NOMRED ] } )

		If aSM0[ nX , SM0_GRPEMP ] == cEmpAnt
			cAlsC1E	:=	'C1E'
			
			aAdd( aMsg, { Space( TmCodFil ), aSM0[ nX , SM0_GRPEMP ], aSM0[ nX , SM0_DESCGRP ], aSM0[ nX , SM0_CODFIL ], aSM0[ nX , SM0_NOME ], aSM0[ nX , SM0_NOMRED ] } )
			/*
		Else
			cAlsC1E	:=	'C1E' + aSM0[ nX , SM0_GRPEMP ]
			
			If aScan( aUseC1E, {|aX| aX == cAlsC1E } ) == 0
				aAdd( aUseC1E, cAlsC1E )
				lInconsist	:=	.T.
				
				OpenSxs( ,,,, aSM0[ nX , SM0_GRPEMP ], "SIXTAF", "SIX",, .F.,, .T., .F. )
				
				If Select( "SIXTAF" ) > 0

					lInconsist	:=	.F.
					
					dbUseArea( .T., 'TOPCONN', cAlsC1E + '0', cAlsC1E, .F., .F. )
					
					If Select( cAlsC1E ) > 0

						SIXTAF->(DbSetOrder(1))
						//Realiza o Seek no SIX aberto pela OpenSxs, para ver se existe o índice. 
						If SIXTAF->(DbSeek('C1E3'))  
							( cAlsC1E )->( dbSetIndex( cAlsC1E + '03' ) )
						Else					
							lInconsist	:=	.T.
						EndIf					
					Else
						lInconsist	:=	.T.
					Endif
					SIXTAF->( dbCloseArea() )
				Else
					lInconsist	:=	.T.
				Endif
			EndIf
			
			If lInconsist
				aMsg[ Len( aMsg ), 1]	:=	STR0128	//"Ambiente inconsistente"
			EndIf
		EndIf*/
 
		If Select( cAlsC1E ) > 0 .And. ( cAlsC1E )->( IndexOrd() ) > 0
			
			/*// A abertura da SX3 em cada empresa analisada por este assistente eh necessaria para garantir o seek
			//que sera realizado abaixo na tabela C1E.
			// A variavel cXFilialC1E eh definida no inicio deste processo com base do tamamnho do campo _FILIAL da empresa
			//logada, porem pode acontecer de cada empresa (ou grupo de empresa) possuir um tamanho distinto para o campo _FILIAL.
			// Neste caso preciso obter o tamanho deste campo em cada empresa ou grupo de empresa.
			OpenSxs( ,,,, aSM0[ nX , SM0_GRPEMP ], "SX3TAF", "SX3",, .F.,, .T., .F. )
			
			//define o indice "X3_CAMPO"
			SX3TAF->( dbSetOrder( 2 ) )
			//posiciona em registro conhecido da SX3 -> campo C1E_FILIAL
			SX3TAF->( msSeek( "C1E_FILIAL" ) )
			//obtem o tamanho do campo _FILIAL
			cXFilialC1E := Space( SX3TAF->X3_TAMANHO )
			*/
			lSeekC1E	:=	( cAlsC1E )->( MsSeek( cXFilialC1E + PadR( aSM0[ nX , SM0_CODFIL ], len( cXFilialC1E ) ) ) )
			If !lSeekC1E
				lAjuste		:=	.T.
			Else
				aMsg[ Len( aMsg ), 1]	:=	( cAlsC1E )->C1E_CODFIL
			EndIf
			
			//SX3TAF->( dbCloseArea() )
			
		//ElseIf lInconsist
			//lAjuste		:=	.T.
			
		Else
			lAjuste		:=	.T.
			
		EndIf
		
		If lAjuste .And. lVldOnly	//Caso esta funcao esteja sendo chamada somente para validar se ha divergencia, posso sair do laco quando encontrar, pois exisitindo uma ou várias, a tela deve ser aberta da mesma forma!
			Exit
		EndIf
	EndIf
	Endif		
Next nX

If Len( aUseC1E ) > 0
	For nX := 1 To Len( aUseC1E )
		If Select( aUseC1E[ nX ] ) > 0
			( aUseC1E[ nX ] )->( dbClearIndex() ) 
			( aUseC1E[ nX ] )->( dbCloseArea() )
		EndIf
	Next nX
EndIf
 
//Esse trecho se faz necessário para liberar o acesso exclusivo que é feito na SIX no momento em que os índices
//do dicionário de dados são criados no start do Protheus.
//Durante testes de atualização de ambiente, identificamos que todos os arquivos de índices são apagados na execução do UPDDISTR
//e são recriados apenas na reinicialização do sistema ( para cada grupo de empresa )
//if select("SIX") > 0
//	SIX->( dbCloseArea() )
//	OpenSxs( ,,,, aSM0[ 1 , SM0_GRPEMP ], "SIX", "SIX",, .F.,, .T., .F. )
//endif

If !lVldOnly .And. lAjuste
	aSizeWindow 	:= 	MsAdvSize()
	nLinIni   		:= 	aSizeWindow[7] //Definindo a Linha Inicial da tela inicial que será criada
	nLinFin   		:= 	aSizeWindow[6] //Definindo a Linha  Final da tela inicial que será criada
	nColIni   		:= 	aSizeWindow[2] //Definindo a Coluna Inicial da tela inicial que será criada
	nColFin   		:= 	aSizeWindow[5] //Definindo a Coluna Final da tela inicial que será criada
	
	oDlg 			:= 	MsDialog():New( nLinIni, nColIni, nLinFin-100, nColFin-100, STR0049,,,,,,,,,.T.,,,,.F. )	//"Análise das amarrações dos Estabelecimentos com os Complementos"
	oLayer 			:= 	FWLayer():New()
	oLayer:Init( oDlg, .T. )
	
	oLayer:AddLine( 'TITULO', 30 )
	oLayer:AddCollumn( 'BOX_TITULO', 100,, 'TITULO' )
	oLayer:AddWindow ( 'BOX_TITULO', 'PANEL00', STR0050, 100, .F.,,, 'TITULO' )	//"Apresentação..."
	oPanel0			:=	oLayer:GetWinPanel ( 'BOX_TITULO' , 'PANEL00', 'TITULO' )
	oSay			:= 	TPanel():New( 0, 0, "", oPanel0,, .F., .F.,,, 0, 0, .T., .F. )
	oSay:Align		:= 	CONTROL_ALIGN_ALLCLIENT
	TSay():New( 01, 1, {|u| STR0051+'<br><br>'+STR0141 }, oSay,,,,,, .T.,,, nLinFin-30, 60,,,,,, .T.)	//'Foi <b>identificado a falta de amarrações complementares</b> para algum(ns) Estabelecimento(s). É necessário que as configurações básicas estejam adequadas para o correto funcionamento do sistema.<br>Nesta interface é(são) apresentado(s) todos os Estabelecimentos cadastrados no sistema, com o Código Complementar da amarração na primeira coluna.<br>As opções para ajustes são:' ###'(F8) | Amarração 1 x 1 entre os Estabelecimentos cadastrados e os Complementos necessários<br>(F9) | Atribuição de "NPI" (Não Possui Integração) aos Estabelecimentos ainda com pendência<br>(Duplo Clique) | Inverte a atribuição atual'
	
	oLayer:AddLine( 'ESTSEM' , 60 )
	oLayer:AddCollumn( 'BOX', 100	,, 'ESTSEM' )
	oLayer:AddWindow ( 'BOX', 'PANEL00', STR0052, 100, .F.,,, 'ESTSEM' )	//"Estabelecimentos sem Complementos"
	oPanel  		:= 	oLayer:GetWinPanel ( 'BOX' , 'PANEL00', 'ESTSEM' )
	oBrowse 		:= 	TPanel():New( 0, 0, "", oPanel,, .F., .F.,,, 0, 0, .T., .F. )
	oBrowse:Align 	:= 	CONTROL_ALIGN_ALLCLIENT
	oBrowseSM0 		:= 	FWBrowse():New()
	oBrowseSM0:SetOwner( oBrowse )
	oBrowseSM0:SetDataArray()
	oBrowseSM0:DisableFilter()
	oBrowseSM0:DisableConfig()
	oBrowseSM0:DisableReport()
	oBrowseSM0:SetDBFFilter()
	oBrowseSM0:SetUseFilter()
	oBrowseSM0:SetArray( aMsg )
	oBrowseSM0:SetDoubleClick( {|| TAFInInvMk( aMsg, oBrowseSM0 ) } )
	oBrowseSM0:SetColumns( {{ STR0053, 	{ || aMsg[oBrowseSM0:nAt][1] },"C",,,020,0,.F.,,.F.,}})	//"Código Complementar"
	oBrowseSM0:SetColumns( {{ STR0054,	{ || aMsg[oBrowseSM0:nAt][2] },"C",,,020,0,.F.,,.F.,}})	//"Grupo de Empresa"
	oBrowseSM0:SetColumns( {{ STR0055,	{ || aMsg[oBrowseSM0:nAt][3] },"C",,,060,0,.F.,,.F.,}})	//"Descrição do Grupo"
	oBrowseSM0:SetColumns( {{ STR0056, 	{ || aMsg[oBrowseSM0:nAt][4] },"C",,,020,0,.F.,,.F.,}})	//"Filial"
	oBrowseSM0:SetColumns( {{ STR0057,	{ || aMsg[oBrowseSM0:nAt][5] },"C",,,060,0,.F.,,.F.,}})	//"Nome Filial"
	oBrowseSM0:SetColumns( {{ STR0058,	{ || aMsg[oBrowseSM0:nAt][6] },"C",,,060,0,.F.,,.F.,}})	//"Nome Filial Reduzido"
	oBrowseSM0:Activate()

	SetKey( VK_F8 , bAjCompl )
	SetKey( VK_F9 , bAjNPI )
	
	Activate MsDialog oDlg On Init EnchoiceBar( oDlg, bOk, bCancel,, aButEnc ) CENTERED
	
	SetKey( VK_F8 , Nil )
	SetKey( VK_F9 , Nil )
EndIf

Return !lAjuste

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInMk
Função que efetua a marca das linhas no grid

@Param	aMsg, empresas a serem processadas
		oBrowse, objeto do browse para refresh

@Return .t.

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Function TAFInMk( aMsg, oBrowse, lNPI )
Local	nX

MsgInfo( STR0129 + STR0130, STR0131 )	//'Para garantir a integridade das informações, somente os Estabelecimentos com <Código Complementar> em branco serão ajustados;###' NÃO É RECOMENDADO a troca de um código por outro, a sugestão é incluí-los no folder <Filiais> do cadastro de <Complemento do Estabelecimento>, executando-o através da opção do Menu!'###'Códigos Complementares existentes...'

For nX := 1 To Len( aMsg )
	If Empty( aMsg[ nX, 1 ] ) .Or. SubStr(aMsg[ nX, 1 ], 1, 1) == '*'
		If lNPI
			aMsg[ nX, 1 ]	:=	'*<NPI>'
		Else
			aMsg[ nX, 1 ]	:=	'*' + aMsg[ nX, 2 ] + aMsg[ nX, 4 ]
		EndIf
	EndIf		
Next nX
oBrowse:Refresh()

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInInvMk
Função que efetua a marca Inversa das linhas no grid

@Param	aMsg, empresas a serem processadas
		oBrowse, objeto do browse para refresh

@Return .t.

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Function TAFInInvMk( aMsg, oBrowseSM0 )

If Empty( aMsg[ oBrowseSM0:nAt, 1 ] ) .Or. Left( aMsg[ oBrowseSM0:nAt, 1 ], 1 ) == '*'
	If aMsg[ oBrowseSM0:nAt, 1 ] == '*<NPI>'
		aMsg[ oBrowseSM0:nAt, 1 ]	:=	'*' + aMsg[ oBrowseSM0:nAt, 2 ] + aMsg[ oBrowseSM0:nAt, 4 ]
	Else
		aMsg[ oBrowseSM0:nAt, 1 ]	:=	'*<NPI>'
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInGrv
Função de processamento da inclusão das amarracoes com a C1E

@Param	aMsg, empresas a serem processadas

@Return .t.

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Function TAFInGrv( aMsg )
Local	oProcess

oProcess 			:= 	TAFProgress():New( { |lEnd| TAFIncC1E( lEnd, oProcess, aMsg ) }, STR0132, .F. )	//'Aguarde o término do processamento...'
oProcess:Activate()

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIncC1E
Função de inclusão das amarracoes com a C1E

@Param	lEnd, flag de controle de cancelamento tratado na TAFProgress
		oProcess, objeto de controle da regua de processamento
		aMsg, empresas a serem processadas

@Return nHandle, Handle do arquivo criado

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Static Function TAFIncC1E( lEnd, oProcess, aMsg )
Local	nX	
Local	nUnLck
Local	nLoop
Local	aGrvC1E
Local	aEmp
Local	nPosEmp
Local	nSleep
aEmp				:=	{}
aGrvC1E				:=	{}
nPosEmp				:=	0
nSleep				:=	0
nUnLck				:=	0
nLoop				:=	0

//Preparo o array de empressas e as informações a serem gravadas na C1E
For nX := 1 To Len( aMsg )
	If SubStr( aMsg[ nX, 1 ], 1, 1 ) == '*'
	
		cScan	:=	aMsg[ nX, 2 ] + aMsg[ nX, 4 ]
		If ( nPosEmp := aScan( aEmp, {|aX| aX[ 1 ] + aX[ 2 ] == cScan } ) ) == 0			
			aAdd( aEmp, { aMsg[ nX, 2 ], aMsg[ nX, 4 ], 'TAFINIT_' + aMsg[ nX, 2 ] + aMsg[ nX, 4 ] } )
			aAdd( aGrvC1E, {})
			nPosEmp	:=	Len( aGrvC1E )	
		EndIf
		aAdd( aGrvC1E[ nPosEmp ], { { "C1E_FILTAF" , aMsg[ nX, 4 ] },;
			          			    { "C1E_CODFIL" , SubStr( aMsg[ nX, 1 ], 2 ) } } )
	EndIf		
Next nX

oProcess:Set1Progress( Len( aEmp ) )
oProcess:Set2Progress( Len( aEmp ) )

//Inicio os startjobs de processamento para atualização das empresas via TAFA050
For nX := 1 To Len( aEmp )
	oProcess:Inc1Progress( STR0133 + aEmp[ nX, 1 ] + ' / ' + aEmp[ nX, 2 ] )	//'Iniciando processamento: Estabelecimento: '
	StartJob( "A050Insert", GetEnvServer(), .F., .T., aEmp[ nX, 1 ], aEmp[ nX, 2 ], aEmp[ nX, 3 ], aGrvC1E[ nX ] )
	
	nSleep++
	If nSleep == 5
		nSleep	:=	0
		Sleep( 10000 )
	Else
		Sleep( 2500 )
	EndIf
	If lEnd
		Exit
	EndIf
Next nX
If lEnd
	oProcess:Inc1Progress( STR0134 )	//'Processamento cancelado!'
Else
	oProcess:Inc1Progress( STR0135 )	//'Todos os estabelecimentos iniciados - em processamento...'
EndIf

//Tratamento wait até o ultimo job ser finalizado 
While !lEnd .And. nUnLck <= Len( aEmp ) .And. nLoop <= 1000
	For nX := 1 To Len( aEmp )	
		If !File( aEmp[ nX, 3 ] )
			oProcess:Inc2Progress( STR0136 + aEmp[ nX, 1 ] + ' / ' + aEmp[ nX, 2 ] )	//'Concluindo processamento do Estabelecimento: '
			nUnLck++
		EndIf
	Next nX
	nLoop++
	If lEnd
		Exit
	EndIf
End
If lEnd
	oProcess:Inc2Progress( STR0134 )	//'Processamento cancelado!'
Else
	oProcess:Inc2Progress( STR0137 )	//'Todos os estabelecimentos processados com sucesso...'
EndIf
Sleep( 10000 )	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLdTbls
Funcao que monta um assistente para selecao das empresas haptas a serem executadas ( que possuem os dicionários criados), permite efeutar a atualização das autocontidas e a criacao das tabelas de sistema do taf.

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam lCallWiz, flag de chamada da funcao do menu; (.T.) pelo menu, ou (.F.) no init do TAF;	

@return lRet, (.T.) OK ou (.F.) NOK  
/*/
//-------------------------------------------------------------------
Static Function TAFLdTbls( lCallWiz, aTAFVldAC )
Local lRet
Local oWizard
Local oFont
Local oPanel
Local oLayer
Local oBrowse
Local oBrowse2
Local aSM0
Local aNEmps
Local nX
Local nY
Local aEmps
Local aTAFAtuDin
Local nPainel
Local nAltLinha
Local lChkLay
Local lChkSGBD
Local lChkWS
Local oChkLay
Local oChkSGBD
Local oLinkInt
Local cGetAlias
Local aItSGBD
Local cCmbSGDB
Local nGetPort
Local aTopInfo
Local nHdlLink
Local lConnect
Local aRetConex
Local cMsgRes
Local oButProc
Local oMeter
Local nMeter
Local cMultGet
Local lOk
Local lCancWiz
Local aTAFLdRes
Local nPosAC
Local oLinkWS
Local cRemotePath
Local nAt
Local cBinPath
Local nGetPortWS
Local lSrvInstall
Local aIni
Local aOpcao
Local cAmbiente
Local aParChck
Local Nw
//Local 	oListEnd
Local lSmart
Local lTafModulo
Local cFormatos
Local lStmpC20 := TAFColumnPos("C20_STAMP")
Local lBdHmg
Local cMsgIA
Local cMsgIntSch
Local oIntSchSay
Local xTAFIsch

Private lChkIntSch
Private lAntChkISh
Private lChkIA
Private lAntChkIA
Private nClickInSc
Private nClickIA
Private oChkIntSch
Private oChkIA

nPosAC         := 0
nClickInSc	   := 0
nClickIA	   := 0
aTAFLdRes      := {'', .F.}
lCancWiz       := .T.
lOk            := .F.
cMultGet       := ''
nMeter         := 0
cMsgRes        := ''
aRetConex      := {'', ''}
lConnect       := .F.
nHdlLink       := 0
aTopInfo       := FWGetTopInfo()
lRet           := .T.
aSM0           := FWLoadSM0()
aEmps          := {}
aNEmps         := {}
aTAFAtuDin     := {  , ''}
lChkLay        := .F.
lChkSGBD       := .T.
lChkWS         := .F.
nGetPort       := GetNewPar( 'MV_TAFPORT' , aTopInfo[ 3 ] )
cGetAlias      := PadR( GetNewPar( 'MV_TAFTALI' , aTopInfo[ 5 ] ), 50 )
cCmbSGDB       := PadR( GetNewPar( 'MV_TAFTDB' , aTopInfo[ 4 ] ), 50 )
nLargLin       := 280
nAltLinha      := 10
aItSGBD        := {}
cRemotePath    := GetRemoteIniName()
nAt            := At( '\BIN' ,Upper(cRemotePath))
cBinPath       := Substr(cRemotePath,1,nAt) + 'bin\app\appserver.ini'
nGetPortWS     := getWSRestPort( 'HTTPREST' , , cBinPath )
lSrvInstall    := File(cBinPath)
cAmbiente      := ""
aIni           := GetINISessions(cBinPath)
aOpcao         := {}

cTmpWzd        := "tafinit_load.wzd"
aParChck       := {}
aMap           := {}
lSmart         := .F.
lTafModulo     := TemRegSFT() //Verifica se usa o TAF como módulo do Protheus
cFormatos      := iif(lTafModulo, '4' , '3' )

oChkIA         := Nil
oChkIntSch	   := Nil
oIntSchSay	   := Nil
lChkIA         := .F. // Integracao Ativa
lChkIntSch     := .F.
cMsgIA         := STR0163 + CRLF + STR0164 // "Esse formato permitirá configurar um Schedule para fazer integração automática entre o SIGAFIS e o TAF " // "sem que haja a necessidade de intervenção humana periódica para geração dos dados."
cMsgIntSch	   := STR0165 + STR0164 // "Esse formato irá iniciar a integração automática entre os Livros Fiscais e o TAF utilizando o serviço Smart Schedule " // "sem que haja a necessidade de intervenção humana periódica para geração dos dados."

lBdHmg         := Alltrim( Upper( TcGetDb( ) ) ) $ "ORACLE|POSTGRES|MSSQL|MSSQL7"

AAdd(aParChck, {"lChkLay", "L",	lChkLay})
AAdd(aParChck, {"lChkSGBD", "L", lChkSGBD})
AAdd(aParChck, {"lChkWS", "L", lChkWS})
AAdd(aParChck, {"lChkIA", "L", lChkIA})

If LoadTmpWiz(cTmpWzd, 1, @aParChck)
	For Nw := 1 To Len(aParChck)
		cEndVar		:= aParChck[Nw][01]
		&cEndVar  	:= aParChck[Nw][03]
	Next
EndIf

If SuperGetMv("MV_TAFDEV",, .F.) //.or. GetRPORelease() == "12.1.2410"
	cFormatos	:= Soma1(cFormatos)
	xTAFIsch	:= GetMV( "MV_TAFISCH",, "0" )

	Do Case
		Case ValType( xTAFIsch ) == "C"
			lChkIntSch := IIf( xTAFIsch == "1", .T., .F. )
		Case ValType( xTAFIsch ) == "L"
			lChkIntSch := xTAFIsch
	EndCase

	lChkIA := !lChkIntSch
EndIf

aAdd (aItSGBD, ''			)												
aAdd (aItSGBD, "MSSQL"   	)				
aAdd (aItSGBD, "MSSQL7"    	)
aAdd (aItSGBD, "ORACLE"   	)
aAdd (aItSGBD, "DB2"	   	)	
aAdd (aItSGBD, "INFORMIX" 	)	
aAdd (aItSGBD, "SYBASE"   	)	
aAdd (aItSGBD, "POSTGRES" 	)	
aAdd (aItSGBD, "MYSQL"    	)
aAdd (aItSGBD, "OPENEDGE" 	)

//Garanto o processamento das empresas que tenham dicionário criado/ 
For nX := 1 To Len( aSM0 )
//	If ( ( lCallWiz .And. aSM0[ nX , SM0_GRPEMP ] == cEmpAnt ) .Or.;
//		!lCallWiz ) .And. aSM0[ nX , SM0_USEROK ] .And. ( ValType( aSM0[ nX , SM0_EMPOK] ) == "U" .Or. aSM0[ nX , SM0_EMPOK ] )
	If aSM0[ nX , SM0_USEROK ] .And. ( ValType( aSM0[ nX , SM0_EMPOK] ) == "U" .Or. aSM0[ nX , SM0_EMPOK ] ) .and. ( aSM0[ nX , SM0_GRPEMP ] == cEmpAnt )
		If aScan( aEmps, {|aX| aX[2]==aSM0[ nX , SM0_GRPEMP ] }) == 0 .And. aScan( aNEmps, {|aX| aX[2]==aSM0[ nX , SM0_GRPEMP ] }) == 0
			
			lEmpAC	:=	.F.
			If ( nPosAC := aScan( aTAFVldAC[ 1 ], {|aX| aX[ 1 ] == aSM0[ nX , SM0_GRPEMP ] } ) ) > 0
				lEmpAC	:=	aTAFVldAC[ 1, nPosAC, 2 ]
			EndIf	
			
			//Faço a abertura da tabela apenas para as empresas que não estou logado, pois na empresa corrente sei
			//que o dicionário já está aberto
			If !( aSM0[ nX , SM0_GRPEMP ] == cEmpAnt )
				OpenSxs( ,,,,aSM0[ nX , SM0_GRPEMP ],"SX6TAF","SX6",,.F.,,.T.,.F. )
				If Select( 'SX6TAF' ) > 0
					SX6TAF->( dbCloseArea() )
					aAdd( aEmps , { .F., aSM0[ nX , SM0_GRPEMP ], aSM0[ nX , SM0_DESCGRP ], aSM0[ nX , SM0_CODFIL ], lEmpAC } )
				Else
					aAdd( aNEmps, { .F., aSM0[ nX , SM0_GRPEMP ], aSM0[ nX , SM0_DESCGRP ], aSM0[ nX , SM0_CODFIL ], lEmpAC } )
				EndIf
			Else
				aAdd( aEmps , { .F., aSM0[ nX , SM0_GRPEMP ], aSM0[ nX , SM0_DESCGRP ], aSM0[ nX , SM0_CODFIL ], lEmpAC } )
			Endif
		EndIf		
	EndIf		
Next nX

//Verifico se as tabelas compartilhadas do TAF estão atualizadas.
atuTabTAF(aEmps)

// Para ambiente Smart ERP, das opções de integração deve habilitar somente a opção de uso do TSI, não deve ser apresentado a tela de configuração de conexão com o banco.
If xTafSmtERP( ) .Or. isTAFInCloud()
	lSmart    := .t.
	lChkLay   := .f.
	lChkSGBD  := .f.
	lChkWS    := .f.
	cCmbSGDB  := aTopInfo[4] 
	cGetAlias := aTopInfo[5]
	nGetPort  := aTopInfo[3]
EndIf

Define FONT oFont NAME "Arial" SIZE 00,-11 BOLD

Define WIZARD oWizard;
	TITLE STR0024;	//'Configuração Iniciais do TAF'
	HEADER STR0063;	//'Apresentação do processo'
	MESSAGE '';
	TEXT STR0064;	//'Este assistente tem como objetivo concluir os procedimentos de configuração do TAF de forma a disponibilizar um ambiente totalmente íntegro para uso; especificamente neste passo, será tratado do processo de:<br><ul><li>Atualização das Tabelas Autocontidas;<li>Criação dos componentes de integração;</ul>'
	NEXT { || .T. };
	FINISH { || .T. };
	NOTESC

CREATE PANEL oWizard;
		HEADER 'Seleção do Grupo para processamento...';	//'Seleção do(s) Grupo(s) para processamento...'
		MESSAGE 'Selecione o Grupo de Empresa que deverá ter as Tabelas Autocontidas criadas automaticamente; essas tabelas são as pré-populadas fornecidas pelo Governo para atender as Obrigações Fiscais.';	//'Selecione o(s) Grupo(s) de Empresa(s) que deverão ter as Tabelas Autocontidas criadas automaticamente; essas tabelas são as pré-populadas fornecidas pelo Governo para atender as Obrigações Fiscais.'
		BACK { || .T. };
		NEXT { || Iif( TAFLdMsg( 2, Nil, Nil, aEmps, Nil, Nil ), .T., .F. ) };
		FINISH { || .T. }
		
		nPainel			:=	2		
		oLayer 			:= 	FWLayer():New()
		oLayer:Init( oWizard:oMPanel[ nPainel ], .T. )
		oLayer:AddLine( 'BROW' , 100 ) 
		oLayer:AddCollumn( 'BOX_BROW'	, 100	,, 'BROW' )
		oLayer:AddWindow ( 'BOX_BROW', 'PANEL00', STR0067, 100, .F.,,, 'BROW' )	//"Empresas habilitadas para processamento..."
		oPanel  		:= 	oLayer:GetWinPanel ( 'BOX_BROW' , 'PANEL00', 'BROW' )
		oBrowse 		:= 	TPanel():New( 0, 0, "", oPanel,, .F., .F.,,, 0, 0, .T., .F. )
		oBrowse:Align 	:= 	CONTROL_ALIGN_ALLCLIENT
		oBrowse2 		:= 	FWBrowse():New()
		oBrowse2:SetOwner( oBrowse )
		oBrowse2:SetDataArray()
		oBrowse2:DisableFilter()
		oBrowse2:DisableConfig()
		oBrowse2:DisableReport()
		oBrowse2:SetDBFFilter()
		oBrowse2:SetUseFilter()
		oBrowse2:SetArray( aEmps )
		oBrowse2:AddMarkColumns( {|| Iif( aEmps[oBrowse2:nAt][1], "LBOK","LBNO" ) },{ || Iif(aEmps[oBrowse2:nAt][1], aEmps[oBrowse2:nAt][1] := .F., aEmps[oBrowse2:nAt][1] := .T.) }, { || oBrowse2:Refresh(), .T. } )
		oBrowse2:SetColumns( {{"Status Autocontidas",               { || Iif( aEmps[oBrowse2:nAt][5], 'Atualizada', 'NÃO Atualizada' ) },"C",,,015,0,.F.,,.F.,}})
		oBrowse2:SetColumns( {{"Status Tabelas Compartilhadas TAF", { || Iif( lAtuTabTAF, 'NÃO Atualizadas', 'Atualizadas' ) },"C",,,018,0,.F.,,.F.,}})
		oBrowse2:SetColumns( {{"Grp. Empresa",			            { || aEmps[oBrowse2:nAt][2] },"C",,,010,0,.F.,,.F.,}})
		oBrowse2:SetColumns( {{"Descrição",   			            { || aEmps[oBrowse2:nAt][3] },"C",,,060,0,.F.,,.F.,}})
		oBrowse2:Activate()
			
CREATE PANEL oWizard;
		HEADER STR0068;	//"Preencha corretamente as informações solicitadas."
		MESSAGE STR0069;	//"Configuração adicional da integração..."
		BACK { || .T. };
		NEXT { || Iif( TAFLdMsg( 1, lChkLay, lChkSGBD, Nil, Nil, Nil , lChkWS, lChkIA, lSmart, lChkIntSch ), (oWizard:nPanel:= changePanel( 'next|typeInteg' , lChkSGBD , lChkWS ) , .T. ), .F. ) };
		EXEC {|| ModSmrtSch()};
		FINISH { || .T. }

		nPainel++
		nLinha		:=	2
		nColuna		:=	10
		TSay():New( nLinha, nColuna, { || STR0070 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'O TAF é um produto TOTVS totalmente independente, e possui uma interface padrão de integração, disponível'
		nLinha	+=	nAltLinha
		//TSay():New( nLinha, nColuna, { || STR0071 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'em 2 formatos:'
		TSay():New( nLinha, nColuna, { || 'em '+cFormatos+' formatos:' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'em 2 formatos:'
		
		nLinha	+=	nAltLinha+nAltLinha
		oChkLay := TCheckBox():New( nLinha, nColuna, '',{|| lChkLay }, oWizard:oMPanel[ nPainel ], 10, nAltLinha,,{|| lChkLay := !lChkLay },,,,,, .T.,,,{||!lSmart})
		TSay():New( nLinha, nColuna+10, { || '<b>' + STR0072 + '</b>' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin-10, nAltLinha,,,,,,.T. )	//'Importação de arquivos no Layout TOTVS'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { || STR0073 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Este formato é próprio para tratar integrações com produtos NÃO TOTVS, onde precisa-se criar extratores no'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { || STR0074 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'sistema legado respeitando o layout padrão de mensagem do TAF( layout TOTVS ).'
		
		nLinha	+=	nAltLinha+nAltLinha
		oChkSGBD := TCheckBox():New( nLinha, nColuna, '',{|| lChkSGBD }, oWizard:oMPanel[ nPainel ], 10, nAltLinha,,{|| lChkSGBD := !lChkSGBD },,,,,, .T.,,,{||!lSmart})
		TSay():New( nLinha, nColuna+10, { || '<b>' + STR0075 + '</b>' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin-10, nAltLinha,,,,,,.T. )	//'Layout TOTVS ou Tabela Compartilhada no SGBD (Importação de arquivos ou integração via ODBC)'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { || STR0076 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Este formato é mais abrangente, além de tratar o anterior, permite-se efetuar integrações via dbAccess/ODBC'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { || STR0077 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'com qualquer SGBD homologado pela TOTVS; <b>integrações com produtos TOTVS</b> utilizam nativamente este'
		//nLinha	+=	nAltLinha
		//TSay():New( nLinha, nColuna, { || STR0078 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'modêlo; sendo o caso, <b>É OBRIGATÓRIO MARCAR</b> esta opção.'
		
		nLinha	+=	nAltLinha+nAltLinha
		oChkSGBD := TCheckBox():New( nLinha, nColuna, '',{|| lChkWS }, oWizard:oMPanel[ nPainel ], 10, nAltLinha,,{|| lChkWS := !lChkWS },,,,,, .T.,,,{||!lSmart})
		TSay():New( nLinha, nColuna+10, { || '<b>' + 'Layout TOTVS ou Web Service (Importação de arquivos ou integração via WS)' + '</b>' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin-10, nAltLinha,,,,,,.T. )
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { || 'Este formato permite efetuar integrações via Serviço Web (Arquitetura REST).' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Este formato é mais abrangente, além de tratar o anterior, permite-se efetuar integrações via dbAccess/ODBC'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { || '<b>Integrações com produtos TOTVS</b> utilizam nativamente este serviço para integração do eSocial.' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'com qualquer SGBD homologado pela TOTVS; <b>integrações com produtos TOTVS</b> utilizam nativamente este'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { || 'No caso de utilizar o TAF para entrega desta obrigação, <b>É OBRIGATÓRIO MARCAR</b> esta opção.' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'modêlo; sendo o caso, <b>É OBRIGATÓRIO MARCAR</b> esta opção.'
		
		If lBdHmg .and. lTafModulo .And. lStmpC20 //Apenas libera o uso do TSI, se o banco for homologado, existir registros na SFT e se já tiver sido criado os S_T_A_M_P_ do lado do ERP
			//Integração Ativa.
			nLinha += nAltLinha + nAltLinha
			oChkIA := TCheckBox():New(nLinha, nColuna, "", &("{|u| If(PCount() == 0, lChkIA, lChkIA := u)}"), oWizard:oMPanel[nPainel], 10, nAltLinha,, {|| ChkIntIA()},,,,,, .T.,,, {|| VldIntAtv(@cMsgIA,, lTafModulo)}) 
	
			TSay():New(nLinha, nColuna + 10, {|| "<b>" + STR0153 + "</b>" }, oWizard:oMPanel[nPainel],,,,,, .T.,,, nLargLin, nAltLinha,,,,,, .T.)	// "TSI - TAF SERVICE INTEGRATION"
			
			nLinha += nAltLinha
			
			TSay():New(nLinha, nColuna, {|| cMsgIA}, oWizard:oMPanel[nPainel],,,,,, .T.,,, nLargLin, nAltLinha + 15,,,,,, .T.)
		EndIf
		
		If (/*GetRPORelease() == "12.1.2410" .Or.*/ SuperGetMv("MV_TAFDEV",, .F.)) .And. lBdHmg .And. lTafModulo
			nLinha		+= nAltLinha + nAltLinha + 6
			oChkIntSch 	:= TCheckBox():New(nLinha, nColuna, "", &("{|u| If(PCount() == 0, lChkIntSch, lChkIntSch := u)}"), oWizard:oMPanel[nPainel], 10, nAltLinha,, {|| ChkIntSch()},,,,,, .T.,,, {|| VldIntSch(@cMsgIA,, lTafModulo)}) // "Prezado cliente," / "Ao selecionar a opção INTEGRAÇÃO SCHEDULE, você estará fazendo uma escolha definitiva. Por favor, esteja ciente de que, uma vez selecionada essa opção, não será possível voltar para a configuração anterior." / "Atenção"
	
			oIntSchSay := TSay():New(nLinha, nColuna + 10, {|| "<b>" + STR0152 + "</b>"}, oWizard:oMPanel[nPainel],,,,,, .T.,,, nLargLin, nAltLinha,,,,,, .T.) // "INTEGRAÇÃO SCHEDULE"
			
			oIntSchSay:SetCss("TSay { color: " + oCSS:oTheme:brand01Dark + "; }")

			nLinha += nAltLinha

			TSay():New(nLinha, nColuna, {|| cMsgIntSch}, oWizard:oMPanel[nPainel],,,,,, .T.,,, nLargLin, nAltLinha + 15,,,,,, .T.)
		EndIf

		//Link com detalhes.
		nLinha	+=	nAltLinha*3
		oLinkInt := TSay():New( nLinha, nColuna, { || '<b>' + STR0079 + '</b>' }, oWizard:oMPanel[ nPainel ],,,,,, .T., CLR_RED,, nLargLin, nAltLinha,,,,,,.T. )	//'Maiores detalhes sobre a integração.'
		oLinkInt:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/pages/releaseview.action?pageId=233757223","","",1) }
		
		If SuperGetMv("MV_TAFDEV",, .F.) //.or. GetRPORelease() == "12.1.2410"
			oLinkInt:SetCss("TSay { color: " + oCSS:oTheme:brand01Dark + "; }")
		EndIf
		
CREATE PANEL oWizard;
		HEADER STR0068;	//"Preencha corretamente as informações solicitadas."
		MESSAGE STR0069;	//"Configuração adicional da integração..."
		BACK { || .T. };
		NEXT { || cMultGet := '', ( oWizard:nPanel:= changePanel( 'next|st1' , lChkSGBD , lChkWS ) ) , .T. };
		FINISH { || .T. }

		nPainel++
		nLinha	:=	2
		nColuna	:=	10			
		TSay():New( nLinha, nColuna, { | | STR0081 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Informe os dados da conexão criada previamente no ODBC/dbAccess que refere-se a origem da integração; essas'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { | | STR0082 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'informações correspondem ao SGBD/Schema que a tabela TAFST1 será criada, e de onde o TAF busca as'
		nLinha	+=	nAltLinha
		TSay():New( nLinha, nColuna, { | | STR0083 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'movimentações.'
		nLinha	+=	nAltLinha+nAltLinha
		TSay():New( nLinha, nColuna, { | | STR0084 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Nome da conexão ODBC/dbAccess'
		TGet():New( nLinha, nColuna+100, { |u| Iif( PCount() == 0, cGetAlias, cGetAlias := u ) }, oWizard:oMPanel[ nPainel ], nLargLin-100, nAltLinha,,,,,,,, .T.,,,,,,, .F.,,,,,,,,,,,1)
		nLinha	+=	nAltLinha+nAltLinha
		TSay():New( nLinha, nColuna, { | | STR0085 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Selecione o SGBD'
		TCombobox():New( nLinha, nColuna+100, { |u| Iif( PCount() == 0, cCmbSGDB, cCmbSGDB := u ) }, aItSGBD, nLargLin-100, nAltLinha, oWizard:oMPanel[ nPainel ],,,,,, .T. )
		nLinha	+=	nAltLinha+nAltLinha
		TSay():New( nLinha, nColuna, { | | STR0086 }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Porta de conexão do dbAccess'
		TGet():New( nLinha, nColuna+100, { |u| Iif( PCount() == 0, nGetPort, nGetPort := u ) }, oWizard:oMPanel[ nPainel ], nLargLin-100, nAltLinha,'99999',,,,,,, .T.,,,,,,, .F.,,,,,,,,,,,1)		
				
CREATE PANEL oWizard;
		HEADER STR0068;	//"Preencha corretamente as informações solicitadas."
		MESSAGE STR0069;	//"Configuração adicional da integração..."
		BACK { || ( oWizard:nPanel:= changePanel( 'back|ws' , lChkSGBD , lChkWS ) ) , .T. };
		NEXT { || cMultGet := '', .T. };
		FINISH { || .T. }

		nPainel++
		nLinha	:=	2
		nColuna	:=	10			
		TSay():New( nLinha, nColuna, { | | 'Informe os dados para criação do Web Service que será utilizado para integração com o TAF.' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	//'Informe os dados para criação do Web Service que será utilizado para integração com o TAF.'
		nLinha	+=	nAltLinha+nAltLinha
		
		oLinkWS	:=	TSay():New( nLinha, nColuna, { || '<b>' + STR0144 + '<b>' }, oWizard:oMPanel[ nPainel ],,,,,, .T., CLR_RED,, nLargLin, nAltLinha,,,,,,.T. )	//'Para mais detalhes sobre esta funcionalidade, clique aqui.'
		oLinkWS:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/pages/viewpage.action?pageId=270904682","","",1) }
		nLinha	+=	nAltLinha+nAltLinha
		
		TSay():New( nLinha, nColuna, { | | 'Porta de conexão do Web Service' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )
		TGet():New( nLinha, nColuna+100, { |u| Iif( PCount() == 0, nGetPortWS, nGetPortWS := u ) }, oWizard:oMPanel[ nPainel ], nLargLin-100, nAltLinha,'99999',,,,,,, .T.,,,,,,, .F.,,,,,,,,,,,1)

		If lSrvInstall

			//Carrego a lista de ambientes
			For nY := 1 to Len(aIni)
				If Len(GetPvProfString( aIni[nY], "SourcePath", "",cBinPath,nil,nil)) > 0
					If aIni[nY] <> "PATCH"  
						aAdd(aOpcao,aIni[nY])
					EndIf	
				EndIf
			Next nY

			nLinha	+=	nAltLinha+nAltLinha
			
			TSay():New( nLinha, nColuna, { | | 'Informar o Ambiente:' }, oWizard:oMPanel[ nPainel ],,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )
			TCombobox():New(nLinha,nColuna + 100,{|u| if( PCount()>0, cAmbiente:=u, cAmbiente )},aOpcao,nLargLin-100,nAltLinha,oWizard:oMPanel[ nPainel ],,,,,,.T.,,,,)	

		EndIf

CREATE PANEL oWizard;
		HEADER STR0080;	//'Resumo do processamento com base nas configurações realizadas'
		MESSAGE STR0145;	//'Abaixo será apresentado um resumo dos processamentos realizados por escopo de atualização'
		BACK { || Iif( lSmart, oWizard:nPanel := 4, oWizard:nPanel:= changePanel( 'back|resumo' , lChkSGBD , lChkWS ) ), lCancWiz := .F. , .T. };
		NEXT { || lCancWiz := .F. };
		FINISH { || Iif( TAFLdMsg( 3, Nil, Nil, Nil, cMultGet, Nil ) .And. TAFLdMsg( 4, Nil, Nil, Nil, Nil, lOk ), ( lCancWiz := .F., .T. ), .F. ) }

		nPainel++
		nLinha				:=	2
		nColuna				:=	10
		oButProc 			:=	TButton():New( nLinha, nColuna, OemToAnsi( STR0087 ), oWizard:oMPanel[ nPainel ], {|| cMultGet := '', aTAFLdRes := TAFLdRes( @lOk, aEmps, lChkLay, lChkSGBD, cGetAlias, cCmbSGDB, nGetPort, oResumo, oMeter, oButProc , lChkWS , nGetPortWS, cBinPath, cAmbiente, lSmart, lChkIA, lChkIntSch ), aTAFLdRes[ 1 ] }, nLargLin, nAltLinha*2,,, .F., .T., .F.,, .F.,,, .F. )	//"Processar as configurações realizadas neste asssistente..."
		nLinha				+=	nAltLinha*2
        oMeter 				:= 	TMeter():New( nLinha+3, nColuna, { |u| Iif( Pcount() > 0, nMeter := u, nMeter ) }, 10, oWizard:oMPanel[ nPainel ], nLargLin, nAltLinha,,.T.)
		nLinha				+=	nAltLinha+6		
		oResumo 			:= 	TMultiGet():New( nLinha, nColuna, { |u| Iif( pCount() > 0, cMultGet := u, cMultGet ) }, oWizard:oMPanel[ nPainel ], nLargLin, nLinha+55,,,,,, .T.,,,,,,.T.,,,, .T., /*lVScroll*/,, 1,, )
		oResumo:lWordWrap 	:= 	.T.
		
Activate WIZARD oWizard Centered

//Salva os parametros que a Wizard não grava
aParChck := {}

AAdd(aParChck, {"lChkLay", "L",	lChkLay})
AAdd(aParChck, {"lChkSGBD", "L", lChkSGBD})
AAdd(aParChck, {"lChkWS", "L", lChkWS})
AAdd(aParChck, {"lChkIA", "L", lChkIA})

LoadTmpWiz( cTmpWzd , 2, aParChck )

If lCallWiz
	If !lCancWiz .And. aTAFLdRes[ 2 ]

		TafFilEvt()      // Chamada da função para exclusão dos registros referente ao evento S-2100 - Graziella
		MsgInfo( 'Processamento executado COM SUCESSO.', 'Conclusão do processamento...' )

		FWMsgRun(,{||verificaIdsBase()},"Diagnóstico de Base","Verificando Integridade dos Eventos ...")

		If ApMsgYesNo("Deseja abrir a tela de diagnóstico?","Deseja abrir a tela de diagnóstico?")
			TAFDIAG()
		EndIf
	EndIf
Else
	//Tratamento para dar final caso o processamento seja cancelado e não tenha ido até o final
	If lCancWiz .And. !aTAFLdRes[ 2 ]
		Final( STR0047 )	//'Configurações inconsistentes, não será possível acessar o TAF.'
	Else
		TafFilEvt()      // Chamada da função para exclusão dos registros referente ao evento S-2100 - Graziella
		Final( STR0048 )	//'Configurações executadas COM SUCESSO, reinicialização obrigatória.'
	EndIf

	FWMsgRun(,{||verificaIdsBase()},"Diagnóstico de Base","Verificando Integridade dos Eventos ...")
EndIf


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLdMsg
Funcao genérica para montagem de mensagens

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam nOpc, flag de chamada da funcao do menu; (.T.) pelo menu, ou (.F.) no init do TAF;
		lChk1, Flag de Checkbox para processamento através de layout TOTVS;
		lChk2, Flag de Checkbox para processamento através SGBD;
		aEmps, Empresas a serem processadas;
		cMultGet, GET com o resultado final do processamento;
		lOk, flag de conclusão do processamento sem inconsistencias;
		lChk3, Flag de Checkbox para processamento através WS;
		lChk4, Flag de Checkbox para integracao ativa (TSI);
		LcHK5, Flag identifica se é ambiente SmartERP ou Cloud

@return lRet, (.T.) OK ou (.F.) NOK  
/*/
//-------------------------------------------------------------------
Static Function TAFLdMsg( nOpc, lChk1, lChk2, aEmps, cMultGet, lOk , lChk3, lChk4, lChk5, lChk6  )
Local	lRet
Local	nX	

Default	lChk1		:=	.T.
Default	lChk2		:=	.T.
Default	aEmps		:=	{}
Default	cMultGet	:=	''
Default	lOk			:=	.T.
Default lChk4		:=	.t. 
Default lChk5		:=	.f. 
Default lChk6		:= .T.

lRet	:=	.T.

If nOpc == 1
	If !lChk1 .And. !lChk2 .And. !lChk3 .and. !lChk4 .and. !lChk5 .And. !lChk6
		MsgStop( STR0088, STR0089 )	//'Ao menos uma opção deve ser selecionada, escolha a que atenda melhor a necessidade entre as disponíveis!'###'Seleção obrigatória...'
		lRet	:=	.F.
	EndIf
ElseIf nOpc == 2
	lRet	:=	.F.
	For nX := 1 To Len( aEmps )
		If aEmps[ nX, 1 ]
			lRet	:=	.T.
			Exit
		EndIf
	Next nX
	If !lRet
		MsgStop( STR0090, STR0089 )	//'Ao menos um Grupo de Empresa deve ser selecionado para prosseguir com o processamento!'###'Seleção obrigatória...'
	EndIf
ElseIf nOpc == 3
	If Empty( cMultGet )
		lRet	:=	.F.
		MsgStop( STR0091 + ' <' + STR0087 + '> ' + STR0092, STR0089 )	//'A finalização deste assistente necessida da execução do processamento conforme as configurações selecionadas; para isso selecionar o botão'###'Processar as configurações realizadas neste asssistente...'###'e aguardar o resultado.'###'Seleção obrigatória...'
	EndIf
ElseIf nOpc == 4
	If !lOk
		lRet	:=	.F.
		MsgStop( STR0093, STR0094 )	//'Houve alguma inconsistência no processo de atualização; verificar o histórico apresentada e tomar as ações necessárias. Somentes as opções <Cancelar> e/ou <Voltar> são válidas.'###'Análise necessária...'
	EndIf
ElseIf nOpc == 5
	If !lChk1
		lRet	:=	.F.
		MsgStop( STR0138, STR0139 )	//'É necessário LER e ENTENDER as orientações apresentadas neste assistente. Leia com atenção e marque a opção confirmando o entendimento.'###'Entendi...'
	EndIf	
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLdRes
Funcao de processamento de todas as configurações informadas e montagem de um resumo ao final para o usuário

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam lOk, flag de conclusão do processamento sem inconsistencias;
		aEmps, Empresas a serem processadas;
		lLayTOTVS, Flag que determina de o checkbox de integração via layoutTOTVS foi marcado; .T. = marcado, .F. NAO marcado
		lSGBD, Flag que determina de o checkbox de integração via SGBD foi marcado; .T. = marcado, .F. NAO marcado
		cGetAlias, Alias de conexão do TOP
		cCmbSGDB, SGBD de conexão do TOP
		nGetPort, Porta de conexão do TOP
		oResumo, objeto do resumo final de processamento apresentado ao usuario
		oMeter, objeto do regrua de processamento apresentado ao usuario
		oButProc, objeto do botao de processamento pressionado pelo usuario
		lWS, Flag que determina de o checkbox de integração via web service; .T. = marcado, .F. NAO marcado
		nWSPort, porta informada para conexão do web service
		lSmart, Flag que determina se o ambiente é SmartERP .T. = sim, .F. = não
		lChkIA, Flag que determin se serão criados campos para integração ativa SIGAFIS/TAF.

@return lRet, (.T.) OK ou (.F.) NOK  
/*/
//-------------------------------------------------------------------
Static Function TAFLdRes( 	lOk,;
							aEmps,;
							lLayTOTVS,;
							lSGBD,;
							cGetAlias,;
							cCmbSGDB,;
							nGetPort,;
							oResumo,;
							oMeter,;
							oButProc,;
							lWS,;
							nWSPort,;
							cBinPath,;
							cAmbiente,;
							lSmart,;
							lChkIA,;
							lChkIntSch )
							
Local	cMsg	
Local	aRetorno
Local	lConnect
Local   lST1
Local	nHdlLink
Local	lAutCon	
Local	nX		
Local	aEmpresas
Local	nMeter	
Local	lAtuSped
Local	lAtuECF	
Local	lAtuCTL	
Local	lAtuXERP
Local	lAtuST2	
Local	cErrorSped
Local	cErrorECF
Local 	cRpoRelease
Local	lSX6Ok	
Local	nOldWSPort

aRetorno			:=	{}
lSX6Ok				:=	.F.
cRpoRelease 		:= 	GetRpoRelease()
nMeter				:=	0
nHdlLink			:=	-1
cMsg				:=	''
aEmpresas			:=	{}
cErrorSped			:=	''
cErrorECF			:=	''
oMeter:SetTotal( 12 )
oButProc:lActive	:=	.F.	//Desabilito o botao para nao permitir clicar enquanto a execução estiver em andamento

//Montagem da parte inicial onde apresenta um resumo das opeções selecionadas
cMsg				:=	'>> ' + STR0095 + cEnter	//'Resumo dos parametros configurados:'
cMsg		+=	'      - ' + STR0096 + cEnter	//'Grupo de Empresas selecionadas:'
For nX := 1 to Len( aEmps )
	If aEmps[ nX, 1 ]
		aAdd( aEmpresas, { aEmps[nX,2], aEmps[nX,4], aEmps[nX,3] } )
		cMsg	+=	'      ' + aEmps[nX,2] + ' | ' + aEmps[nX,4] + ' | ' + aEmps[nX,3] + cEnter	
	EndIf
Next nX
cMsg		+=	cEnter + '      - ' + STR0097 + cEnter	//'Configuração adicional da integração:'
cMsg		+=	'      [ ' + Iif( lLayTOTVS, 'X', '  ' ) + ' ] ' + STR0098 + cEnter	//'Layout TOTVS'
cMsg		+=	'      [ ' + Iif( lSGBD    , 'X', '  ' ) + ' ] ' + STR0099 + cEnter	//'Layout TOTVS ou Tabela Compartilhada no SGBD'
cMsg		+=	'      [ ' + Iif( lWS      , 'X', '  ' ) + ' ] ' + 'Layout TOTVS ou Web Service' + cEnter	//

// Por questões de segurança da informação, no ambiente SmartErp não será apresentado as informações de conexões
If !lSmart
	cMsg		+=	cEnter + '      - ' + STR0100 + cEnter	//'Informações da conexão para integração via SGBD:'
	If lSGBD
		cMsg	+=	'      ' + STR0101 + '[ ' + AllTrim( cGetAlias ) + ' ]' + cEnter	//Nome da conexão ODBC/dbAccess
		cMsg	+=	'      SGBD[ ' + AllTrim( cCmbSGDB ) + ' ]' + cEnter
		cMsg	+=	'      ' + STR0086 + '[ ' + Str( nGetPort, 4 ) + ' ]' + cEnter	//Porta de conexão do dbAccess
	Else
		cMsg	+=	'      ' + STR0102 + cEnter	//Não se aplica, pois não foi selecionada a opção anterior referente a este modelo de integração.'
	EndIf

	cMsg		+=	cEnter + '      - ' + 'Informações da conexão para integração via Web Service:' + cEnter //
	If lWS
		cMsg	+=	'      ' + 'Porta de conexão ao Web Service' + '[ ' + AllTrim( Str( nWSPort ) ) + ' ]' + cEnter	//'Porta de conexão ao Web Service'
		
		If File(cBinPath)
			cMsg	+=	'      ' + 'Ambiente configurado no Web Service' + '[ ' + AllTrim( cAmbiente ) + ' ]' + cEnter	//'Ambiente configurado no Web Service'
		Endif

	Else
		cMsg	+=	'      ' + STR0102 + cEnter	//Não se aplica, pois não foi selecionada a opção anterior referente a este modelo de integração.'
	EndIf
EndIf

cMsg		+=	cEnter + '>> ' + STR0103 + cEnter	//'Resumo do processamento...'	
oResumo:AppendText( cMsg )

//Montagem da mensagem de resultado do processamento das autocontidas
lAutCon 	:= TAFInAC( aEmpresas, @aRetorno )
cMsg		:=	'- ' + aRetorno[ 1 ] + '  >>  ' + aRetorno[ 2 ] + cEnter + cEnter
oResumo:AppendText( cMsg )
oMeter:SetTotal( nMeter++ )

If lAtuTabTAF
	//Montagem da mensagem de resultado do processamento de criacao das tabelas por empresa
	MsgRUN( STR0146, 'TAFSPED...', { || TAFInSPED( aEmpresas, @lAtuSped, @cErrorSped, @lAtuECF, @cErrorECF ) } )	//'Criando componentes de integração...'
	cErrorSped	:=	Iif( Empty( cErrorSped ), STR0104, STR0105 + cEnter + cErrorSped )	//'Processamento realizado COM SUCESSO para todas as empresas selecionadas!'###'Processo de criação realizado SEM SUCESSO; inconsistência apresentada: '
	cErrorECF	:=	Iif( Empty( cErrorECF ) , STR0104, STR0105 + cEnter + cErrorECF )	//'Processamento realizado COM SUCESSO para todas as empresas selecionadas!'###'Processo de criação realizado SEM SUCESSO; inconsistência apresentada: '
	cMsg		:=	'- TAFSPED | ' + STR0106 + '  >>  ' + cErrorSped + cEnter + cEnter	//Criação de tabelas
	cMsg		+=	'- TAFECF | ' + STR0106 + '  >>  ' + cErrorECF + cEnter + cEnter	//Criação de tabelas
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )

	//Montagem da mensagem de resultado do processamento de criacao da tabela de controle interno do taf
	cMsg	:=	''
	MsgRUN( STR0146, 'TAFGERCTL...', { || lAtuCTL := FAtuTabSD( 'TAFGERCTL', @cMsg ) } )	//'Criando componentes de integração...'
	cMsg	:=	Iif( Empty( cMsg ), STR0104, STR0105 + cEnter + cMsg )	//'Processamento realizado COM SUCESSO para todas as empresas selecionadas!'###'Processo de criação realizado SEM SUCESSO; inconsistência apresentada: '
	cMsg	:=	'- TAFGERCTL | ' + STR0106 + '  >>  ' + cMsg + cEnter + cEnter	//Criação de tabelas
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )

	//Montagem da mensagem de resultado do processamento de criacao da tabela TAFST2
	cMsg		:=	''
	MsgRUN( STR0146, 'TAFST2...', { || lAtuST2 := FAtuTabSD( 'TAFST2', @cMsg ) } )	//'Criando componentes de integração...'
	cMsg	:=	Iif( Empty( cMsg ), STR0104, STR0105 + cEnter + cMsg )	//'Processamento realizado COM SUCESSO para todas as empresas selecionadas!'###'Processo de criação realizado SEM SUCESSO; inconsistência apresentada: '
	cMsg	:=	'- TAFST2 | ' + STR0106 + '  >>  ' + cMsg + cEnter + cEnter	//Criação de tabelas
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )

	//Montagem da mensagem de resultado do processamento de criacao da tabela TAFXERP
	cMsg		:=	''
	MsgRUN( STR0146, 'TAFXERP...', { || lAtuXERP := FAtuTabSD( "TAFXERP", @cMsg ) } )	//'Criando componentes de integração...'
	cMsg	:=	Iif( Empty( cMsg ), STR0104, STR0105 + cEnter + cMsg )	//'Processamento realizado COM SUCESSO para todas as empresas selecionadas!'###'Processo de criação realizado SEM SUCESSO; inconsistência apresentada: '
	cMsg	:=	'- TAFXERP | ' + STR0106 + '  >>  ' + cMsg + cEnter + cEnter	//Criação de tabelas
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )
else
	lAtuSped := .T.
	lAtuECF  := .T.
	lAtuCTL  := .T.
	lAtuST2  := .T.
	lAtuXERP := .T.
	cMsg		:=	'- ' + 'Criação de tabelas TAF |' + '  >>  ' + 'A estrutura das tabelas TAFST1, TAFST2, TAFXERP, TAFSPED, TAFECF e TAFGERCTL estão atualizadas, por isso, não serão recriadas.' + cEnter + cEnter
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )
Endif

If lSmart .And. lAtuTabTAF
	cMsg		:=	''
	MsgRUN( STR0146, 'TAFST1...', { || lST1 := FAtuTabSD( 'TAFST1', @cMsg ) } )	//'Criando componentes de integração...'
	cMsg	:=	Iif( Empty( cMsg ), STR0104, STR0105 + cEnter + cMsg )	//'Processamento realizado COM SUCESSO para todas as empresas selecionadas!'###'Processo de criação realizado SEM SUCESSO; inconsistência apresentada: '
	cMsg	:=	'- TAFST1 | ' + STR0106 + '  >>  ' + cMsg + cEnter + cEnter	//Criação de tabelas
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )

	lConnect := lST1

//Tratamento para efetuar o processamento somente quanto a integração via SGBD estiver selecionada
ElseIf lSGBD
	//Tratamento para validar a conexao baseado nas inforcoes do assistente
	lConnect 	:= TAFLdConn( cGetAlias, cCmbSGDB, nGetPort, @nHdlLink, @aRetorno )
	cMsg		:=	'- ' + aRetorno[ 1 ] + '  >>  ' + aRetorno[ 2 ] + cEnter + cEnter
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )
	
	If lAtuTabTAF
		//Montagem da mensagem de resultado do processamento de criacao da tabela TAFST1
		lST1		:=	TAFLdST1( nHdlLink, @aRetorno, lConnect )
		cMsg		:=	'- ' + aRetorno[ 1 ] + '  >>  ' + aRetorno[ 2 ] + cEnter + cEnter
		oResumo:AppendText( cMsg )
		oMeter:SetTotal( nMeter++ )
	else
		lST1 := .T.
	EndIf
Else
	lConnect	:=	.T.
	lST1		:=	.T.
EndIf

//Tratamento para efetuar o processamento somente quanto a integração via Web Service estiver selecionada
// Quando for SmartErp, não ira gravar informações de WebService no arquivo .ini
If lWS .and. !lSmart
	//verifica a necessidade de criação das seções e chaves do web service. Se retornar .T. é porque foram criadas, se retornar .F.
	//é porque a configuração de WS com socket HTTPREST já existe no ambiente
	if wrtWSAppSrvIni( nOldWSPort := getWSRestPort( 'HTTPREST' , nWSPort, cBinPath ), cBinPath, cAmbiente )
		
		//Montagem da mensagem de resultado do processamento de criacao das configurações do web service
		cMsg		:=	'- ' + 'WEB SERVICE|' + '  >>  ' + 'Os parâmetros de conexão para WS REST no arquivo de configuração do servidor foram criados COM SUCESSO! Porta HTTP: ' + allTrim( str( nOldWSPort ) ) + '.' + cEnter + cEnter
		oResumo:AppendText( cMsg )
		oMeter:SetTotal( nMeter++ )
	
	else
		//Montagem da mensagem de resultado do processamento de criacao das configurações do web service
		cMsg		:=	'- ' + 'WEB SERVICE|' + '  >>  ' + 'Foram identificados parâmetros de conexão para WS REST já existentes no arquivo de configuração do servidor. Os parâmetros não serão recriados e o serviço de integração do TAF poderá ser utilizado através da configuração existente. Porta HTTP: ' + allTrim( str( nOldWSPort ) ) + '.' + cEnter + cEnter
		oResumo:AppendText( cMsg )
		oMeter:SetTotal( nMeter++ )
	endif
EndIf

//Montagem da mensagem de resultado do processamento de criacao do campo S_T_A_M_P_ nas tabelas de integração.
If lChkIA .Or. lChkIntSch
	cMsg :=	""
	
	MsgRUN(STR0154, IIf(lChkIntSch, STR0155, STR0156), {|| IntAtiva(@cMsg)}) // "S_T_A_M_P_" / "Integração Schedule..." / "Integração Ativa..." / "Criando campos S_T_A_M_P_ nas tabelas de integração"
	
	cMsg :=	STR0157 + cMsg + CRLF + CRLF // "- S_T_A_M_P_ | Criação de campo >> " / "Criação de tabelas"
	
	oResumo:AppendText(cMsg)
	oMeter:SetTotal(nMeter++)
EndIf

//Ajusta  Itens com Protocolo e status diferente de 4 *** Verificar periodicamente a necessidade desta rotina.
FWMsgRun(,{|oMsgRun|TAFMAJREC(.F.,oMsgRun)}," Ajuste de Status Autorizado","Realizando Processamento ...")
cMsg		:=	'- ' + 'STATUS DOS EVENTOS |' + '  >>  ' + 'Realizado verificação de eventos e-Social, todos os eventos com protocolo estão com status de autorizado.' + cEnter + cEnter
oResumo:AppendText( cMsg )
oMeter:SetTotal( nMeter++ )

//Verifico se as configurações foram realizaras com sucesso para atualizar os parametros no dicionário de dados
If lAutCon .And. lConnect .And. lST1 .And. lAtuSped .And. lAtuECF .And. lAtuCTL .And. lAtuST2 .And. lAtuXERP
	lOk			:=	.T.
	lSX6Ok		:=	TAFAtuSx6( lSGBD, cGetAlias, cCmbSGDB, nGetPort, cRpoRelease, @aRetorno, lChkIntSch )
	cMsg		:=	'- ' + aRetorno[ 1 ] + '  >>  ' + aRetorno[ 2 ] + cEnter + cEnter
	oResumo:AppendText( cMsg )
	oMeter:SetTotal( nMeter++ )
Endif 

oMeter:SetTotal( nMeter++ )
oButProc:lActive	:=	.T.	//Habilito o botao na conclusao do processamento
Return { cMsg, lSX6Ok }
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInAC
Funcao de validação e processamento da atualização das tabelas autocontidas

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam aEmps, Empresas a serem processadas;
		aRets, mensagem de retorno a ser apresentado na tela de resumo 

@return lRet, (.T.) OK ou (.F.) NOK  
/*/
//-------------------------------------------------------------------
Static Function TAFInAC( aXEmpresas, aRet )
Local	lRet	
Local	cError	
Local	oProcess

cError				:=	''

oProcess 			:= 	TAFProgress():New( { |lEnd| lRet := FTafAutCon( aXEmpresas, @oProcess, @cError, .F. ) }, STR0140, .F. )	//'Iniciando Atualização do Ambiente...'
oProcess:Activate()

If lRet
	aRet	:=	{ STR0107, STR0104 }	//'Autocontidas | Criação das Tabelas'###'Processamento realizado COM SUCESSO para todas as empresas selecionadas!'
Else
	aRet	:=	{ STR0107, STR0108 + ' [' + cError + ']. ' + STR0109 }	//'Autocontidas | Criação das Tabelas'###'Processamento concluído SEM SUCESSO; verificar as inconsistências apresentadas e entrar em contato com a TOTVS:###'Utilize a opção <Voltar> para selecionar uma empresa e continuar o processamento, ou <Cancelar> para abortar.'
	lRet	:=	.F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInSPED
Funcao para criacao da tabela SPED por empresa

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam aEmpresas, array de empresas
		lAtuSped, flag de falha de criacao em alguma empresa
		cErrorSped, mensagem de erro da tabela sped
		lAtuECF, flag de falha de criacao em alguma empresa
		cErrorECF, mensagem de erro da tabela ECF 

@return Nil  
/*/
//-------------------------------------------------------------------
Static Function TAFInSPED( aEmpresas, lAtuSped, cErrorSped, lAtuECF, cErrorECF )
Local	nX		

lAtuSped			:=	.T.
lAtuECF				:=	.T.

For nX := 1 to Len( aEmpresas )
	//Atualizando a tabela TAFSPED
	If !FAtuTabSD( 'TAFSPED' + '_' + aEmpresas[nX,1], @cErrorSped )
		lAtuSped	:=	.F.	
	EndIf
	
	//Atualizando a tabela TAFECF
	If !FAtuTabSD( 'TAFECF' + '_' + aEmpresas[nX,1], @cErrorECF )
		lAtuECF		:=	.F.
	EndIf 
Next nX

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLdConn
Funcao que valida a conexao com o dbAcces para criacao da TAFST1

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam cGetAlias, Alias de conexão do TOP
		cCmbSGDB, SGBD de conexão do TOP
		nGetPort, Porta de conexão do TOP
		nHdlLink, link da conexão com a TAFST1;
		aRetorno, mensagem de retorno a ser apresentado na tela de resumo 

@return lRet, (.T.) OK ou (.F.) NOK  
/*/
//-------------------------------------------------------------------
Static Function TAFLdConn( cGetAlias, cCmbSGDB, nGetPort, nHdlLink, aRetorno )
Local	lConnect

MsgRUN( STR0110, STR0111, { || lConnect := FConectTAF( AllTrim( cGetAlias ), AllTrim( cCmbSGDB ), nGetPort, .F., @nHdlLink, .F., {} ) } )	//'Checando as informações configuradas...'###'Validando conexão'

If lConnect
	//MsgInfo( 'As informações fornecidas para conexão foram validadas com SUCESSO. Clique em fechar para prosseguir com as configurações.', 'Resultado da validação...' )
	aRetorno	:=	{ STR0112, STR0113 }	//'TAFST1 | Validação da conexão'###'As informações fornecidas para conexão foram validadas com SUCESSO.'	
Else
	//MsgStop( 'As informações fornecidas para conexão NÃO FORAM VALIDADAS; será necessário informar valores válidos para prosseguir com esta configuração.', 'Resultado da validação...' )
	aRetorno	:=	{ STR0112, STR0114 }	//'TAFST1 | Validação da conexão'###'As informações fornecidas para conexão NÃO FORAM VALIDADAS; será necessário <Voltar>, informar valores corretos e validar novamente.'	
EndIf 

Return lConnect
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLdST1
Funcao que valida e executa a criaca da TAFST1

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam nHdlLink, link da conexão com a TAFST1;
		aRetorno, mensagem de retorno a ser apresentado na tela de resumo
		lConnect, informa se a conexão foi bem sucedida

@return lRet, (.T.) OK ou (.F.) NOK  
/*/
//-------------------------------------------------------------------
Static Function TAFLdST1( nHdlLink, aRetorno, lConnect )
Local 	lRet      
Local	cDesErr
Local	cError

cError  := ""
cDesErr := ""
lRet    := .f.

If lConnect
	lRet		:=	FAtuTabSD( 'TAFST1', @cError, @cDesErr )
EndIf

//Encerra a Conexão após a criação da tabela TAFST1
If nHdlLink >= 0	
	TCUnlink( nHdlLink )
Else
	cError	:=	STR0115	//'Não foi possivel utilizar a conexão ODBC/dbAccess fornecida; avaliar a inconsistência apresentada no item anterior "Validação de Conexão".'
	cDesErr	:=	STR0116	//'Sem informações complementares'
EndIf
				
//Verifica se não ocorreram problemas na criação da tabela TAFST1
If !lRet
	aRetorno	:=	{ STR0117, STR0118 +' [' + cError + '] >> [' + cDesErr + ']' }	//'TAFST1 | Criação da tabela'###'Encontrada uma inconsistência na criação da interface de integração TAFST1:
Else
	aRetorno	:=	{ STR0117, STR0119 }	//'TAFST1 | Criação da tabela'###'Interface de integração TAFST1 criada com SUCESSO!'
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAtuSx6
Função criada para atualizar o dicionário de dados

@Param	lUsaIntTaf - Indica se usuário utiliza integração banco a banco
		cMVTafTali - Alias de Conexão com a TAFST1
		cMVTafTDB  - Banco da tabela TAFST1
		nMVTafPort - Porta do Top para conexão com a TAFST1
		aEmpresas   - informa as empresas validas a serem processadas
		cRpoRelease, informa o release do RPO
		aRetorno, mensagem de retorno a ser apresentado na tela de resumo

@author Rodrigo Aguilar
@since 27/03/2015
@version 1.1     

/*/
//-------------------------------------------------------------------
Function TAFAtuSx6(lUsaIntTaf, cMVTafTali, cMVTafTDB, nMVTafPort,  cRpoRelease, aRetorno, lChkIntSch)
Local cMVError 		:= ''
Local cMVTAFISCH	:= IIf(lChkIntSch, "1", "0")
Local xTAFIsch		:= GetMV( "MV_TAFISCH",, "0" )

// Mando alterar o conteudo do parâmetro MV_DTABTAF e verifico se a alteração ocorreu corretamente.
If GetMV( "MV_DTABTAF",.T.)
	PUTMV("MV_DTABTAF", AllTrim(cDtTabTAFSD))
Else
	cMVError	+=	cEmpAnt + '-' + Iif( 'MV_DTABTAF'$cMVError, '', 'MV_DTABTAF/' )
Endif

If GetMV( "MV_TAFINT",.T.)
	PutMv('MV_TAFINT', iif( lUsaIntTaf, '.t.', '.f.' ))
Else
	cMVError	+=	cEmpAnt + '-' + Iif( 'MV_TAFINT'$cMVError, '', 'MV_TAFINT/' )
Endif

If GetMV( "MV_TAFVER",.T.)
	PutMv('MV_TAFVER', Alltrim( cRpoRelease ))
Else
	cMVError	+=	cEmpAnt + '-' + Iif( 'MV_TAFVER'$cMVError, '', 'MV_TAFVER/' )
EndIf

If lUsaIntTaf
	If GetMV( "MV_TAFTALI",.T.)
		PutMv('MV_TAFTALI', cMVTafTali)
	Else
		cMVError	+=	cEmpAnt + '-' + Iif( 'MV_TAFTALI'$cMVError, '', 'MV_TAFTALI/' )
	Endif

	If GetMV( "MV_TAFTDB",.T.)
		PutMv('MV_TAFTDB', cMVTafTDB)
	Else
		cMVError	+=	cEmpAnt + '-' + Iif( 'MV_TAFTDB'$cMVError, '', 'MV_TAFTDB/' )
	Endif

	If GetMV( "MV_TAFPORT",.T.)
		PutMv('MV_TAFPORT', Alltrim( Str( nMVTafPort ) ))
	Else
		cMVError	+=	cEmpAnt + '-' + Iif( 'MV_TAFPORT'$cMVError, '', 'MV_TAFPORT/' )
	Endif	
Endif

Do Case
	Case ValType( xTAFIsch ) == "C"
		xTAFIsch := cMVTAFISCH
	Case ValType( xTAFIsch ) == "L"
		xTAFIsch := IIf( cMVTAFISCH == "1", .T., .F. )
EndCase
 
If SuperGetMv("MV_TAFDEV",, .F.) //.or. GetRPORelease() == "12.1.2410"
	If GetMV("MV_TAFISCH", .T.)
		PutMV( "MV_TAFISCH", xTAFIsch )
	Else
		cMVError +=	cEmpAnt + "-" + IIf("MV_TAFISCH" $ cMVError, "", "MV_TAFISCH/")
	EndIf
	If !SuperGetMv("MV_HISTTAB",, .F.)
		PutMV("MV_HISTTAB", .T.)
	Endif
ElseIf GetMV("MV_TAFISCH", .T.)
	PutMV( "MV_TAFISCH", xTAFIsch )
EndIf 

If Empty( cMVError )
	aRetorno	:=	{ STR0120, STR0121 }	//'Atualização dos Parâmetros de controles'###'Atualização dos controles internos efetuado COM SUCESSO!'
Else
	aRetorno	:=	{ STR0120, STR0122 + ' (' + cMVError + '); ' + STR0123}	//'Atualização dos Parâmetros de controles'###'Não foi possível efetuar atualização dos controles internos'###'atualização SEM SUCESSO!'
EndIf

SuperGetMV() //Limpa o cache de parametros - nao retirar

Return Empty( cMVError )
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLck
Função de controle de acesso enquando a atualização esta em andamento

@Param	cFile, nome do arquivo semaforo

@Return nHandle, Handle do arquivo criado

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Static Function TAFLck( cFile )
Local	nHandle

If File( cFile )	
	FErase( cFile )
EndIf
nHandle := FCreate( cFile )

Return nHandle
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFUnLck
Função de controle de acesso enquando a atualização esta em andamento

@Param	nHandle, handle do arquivo de controle criado
		cFile, nome do arquivo semaforo
		
@Return lRet, .T. - informando a liberação para acesso; 
			  .F. - determina que o acesso ainda está bloqueado

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Static Function TAFUnLck( nHandle, cFile )
Local	lRet
lRet	:=	.F.

FClose( nHandle )
If FErase( cFile ) # -1
	lRet	:=	.T.
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInUse
Função de controle que valida se o taf esta em uso por mais de uma conexão; esta funcao trabalha com base em semaforos criados no system( ..1 para um usuario, ...2 para 2 ou mais usuarios)

@Param	Nil
		
@Return lRet, .T. - indica que tem mais de um usuario conectados no sistema 
			  .F. - indica que somente o chamados esta conectado no sistema

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Function TAFInUse()
Local	lRet
lRet				:=	.F.

//Cria semafor para informar o uso do taf por outro usuário
If ( File( aTAFInUse[ 1, 1 ] ) .And. FErase( aTAFInUse[ 1, 1 ] ) == -1 ) .And.;
	( File( aTAFInUse[ 2, 1 ] ) .And. FErase( aTAFInUse[ 2, 1 ] ) == -1 ) 
	lRet	:=	.T.
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFUseLck
Função que cria os semaforos conforme as conexoes estabelecidas; os controles ficam na variavel static ate o final da conexao.

@Param	Nil
		
@Return Nil

@author Gustavo G. Rueda
@since 02/09/2016
@version 1.1     
/*/
//-------------------------------------------------------------------
Function TAFUseLck()

//Cria semafor para informar o uso do taf por outro usuário
aTAFInUse[ 1, 2 ]	:=	TAFLck( aTAFInUse[ 1, 1 ] )
If aTAFInUse[ 1, 2 ] < 0
	aTAFInUse[ 2, 2 ]	:=	TAFLck( aTAFInUse[ 2, 1 ] )
EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getWSRestPort
Função que procura no appserver.ini a porta configurada para o serviço informado
no parâmetro cSocketREST. Caso não encontre, retorna a porta padrão para
serviços HTTP - 8080.

@Param	cSocketREST, Socket de conexão em que a porta será pesquisada, default = HTTPREST
@param  nWSPort, porta de conexão default caso nenhuma seja encontrada, default = 8080
		
@Return nPort, porta de conexão

@author Luccas Curcio
@since 15/05/2017
@version 1.1
/*/
//-------------------------------------------------------------------
static function getWSRestPort( cSocketREST, nWSPort, cBinPath )

local	nPort		 	:=	0
local	cSocket	 	:=	"" 
local	cWSPort	  	:=	""

default cSocketREST	:= 'HTTPREST'
default nWSPort		:= 8080
default cBinPath    := ""

cSocket	:=	getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , If (File(cBinPath),cBinPath,getAdv97()), Nil, Nil )
cSocket :=	subStr( cSocket , 1 , at( cSocket , ',' ) )

if !empty( cSocketREST )
	cSocket := cSocketREST
endif

cWSPort	:=	getPvProfString( cSocket , 'PORT' , '' , If(File(cBinPath),cBinPath,getAdv97()), Nil, Nil )

if !empty( cWSPort )
	nPort := val( cWSPort )
else
	nPort := nWSPort
endif

return nPort

//-------------------------------------------------------------------
/*/{Protheus.doc} changePanel
Função que retorna o painel que a wizard deverá executar na sequencia, 
conforme comandos do bloco de código.

@Param	cTpOper, informa o painel de origem da chamada, default = 'back|resumo'
@param  lChkSGBD, flag que indica se a opção de integração via SGBD foi selecionada, default = .f.
@param  lChkWS, flag que indica se a opção de integração via web service foi selecionada, default = .f.
		
@Return nPanel, próximo painel da wizard que será aberto

@author Luccas Curcio
@since 15/05/2017
@version 1.1
/*/
//-------------------------------------------------------------------
static function changePanel( cTpOper, lChkSGBD, lChkWS )

local	nPanel

default	cTpOper		:= 'back|resumo'
default	lChkSGBD	:= .F.
default	lChkWS		:= .F.

nPanel := 0

if cTpOper == 'next|typeInteg'

	nPanel := iif( lChkSGBD, 3, iif( lChkWS , 4 , 5) )
	
elseif cTpOper == 'next|st1'
	
	nPanel := iif( lChkWS, 4, 5 )

elseif cTpOper == 'back|ws'
	
	nPanel := iif( lChkSGBD, 5 , 4 )

elseif cTpOper == 'back|resumo'

	nPanel := iif( lChkWS , 6 , iif( lChkSGBD , 5 , 4 ) )

endif

return nPanel

//-------------------------------------------------------------------
/*/{Protheus.doc} wrtWSAppSrvIni
Função que edita o arquivo appserver.ini com as configurações do serviço web
REST. Caso não seja necessário, ou seja, já exista um serviço web REST disponpivel
no ambiente, a função vai retornar .F.

@param  nWSPort, porta de conexão do serviço web rest, default = 0
		
@Return nPort, porta de conexão

@author Luccas Curcio
@since 15/05/2017
@version 1.1
/*/
//-------------------------------------------------------------------
static function wrtWSAppSrvIni( nWSPort, cBinPath, cAmbiente )

local	lRet		
local	cString		
local	cIniFile	
local	cOldJobs	
Local	lConnSrv	
Local 	nAt			
Local 	cRemotePath	
Local 	cServerPath	
Local 	cConexao	

default	nWSPort	  := 0
default cBinPath  := ""
default cAmbiente := "TAF_WS"

cString		:=	''
lRet		:= .F.
lConnSrv	:= .F.
cRemotePath	:=  GetRemoteIniName()
nAt 	 	:=  At('\BIN',Upper(cRemotePath))
cServerPath	:=  Substr(cRemotePath,1,nAt) + 'bin\serverpatch\appserver.ini'
cConexao	:= "PATCH_WS"

If File(cServerPath)
	cConexao := "WS"
EndIf

//Se existir o  arquivo referente ao cBinPath, foi criado via instalador.
If File(cBinPath)

	cIniFile := cBinPath

	// Conecta no server onde será aplicado o patch para verificar a data dos fontes.
	oRpcSrv := TRpc():New( AllTrim(cAmbiente) )

	If (oRpcSrv:Connect( GetPvProfString( cConexao, 'Server', '', GetRemoteIniName() , Nil, Nil ), Val(GetPvProfString( cConexao, 'PORT', '', GetRemoteIniName() , Nil, Nil )) ))
		lConnSrv := .T.
	EndIf

	//verifica se o arquivo de configuração do servidor já possui um Socket 'HTTPREST'. Se já existir, assumo que essa parametrização
	//pode ser utilizada para o serviço do TAF.
	If lConnSrv .And. nWSPort > 0 .and. !( 'HTTPREST' $ getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , cIniFile, Nil, Nil) )
	
		//tentativa de escrita no arquivo de configuração do server, para criar a seção [HTTPV11]
		If (oRpcSrv:CallProc("writePProString", 'HTTPV11' , 'SOCKETS' , 'HTTPREST' , cIniFile))
		
			//habilita a seção [HTTPV11]
			oRpcSrv:CallProc("writePProString", 'HTTPV11'	, 'ENABLE' 		, '1' , cIniFile)
			
			//criação e edição da seção [HTTPREST]
			oRpcSrv:CallProc("writePProString", 'HTTPREST' , 'Port' 		, allTrim( str( nWSPort ) ) , cIniFile )
			oRpcSrv:CallProc("writePProString", 'HTTPREST' , 'URIs' 		, 'HTTPURI' 				, cIniFile)
			oRpcSrv:CallProc("writePProString", 'HTTPREST' , 'Security'	, '1' 						, cIniFile )
			
			//criação e edição da seção [HTTPURI]
			oRpcSrv:CallProc("writePProString", 'HTTPURI' 	, 'URL' 		, '/rest' 					, cIniFile)
			
			//Com as mudanças em relação a arquitetura do WS ( tivemos que criar o TAF_CFGJOB para garantir que as threads não consumam licenças ), a chave abaixo foi retirada
			//writePProString( 'HTTPURI' 	, 'PrepareIn' 	, 'All' 					, cIniFile )
			
			oRpcSrv:CallProc("writePProString", 'HTTPURI' 	, 'Instances' 	, '2,2' 					, cIniFile)
			oRpcSrv:CallProc("writePProString", 'HTTPURI' 	, 'CORSEnable'	, '1' 						, cIniFile)
			
			oRpcSrv:CallProc("writePProString", 'HTTPURI' 	, 'AllowOrigin' , '*' 						, cIniFile )
			
			//verifica a necessidade de incluir HTTP_START na chave MAIN da seção [HTTPJOB]

			oRpcSrv:CallProc("writePProString", 'HTTPURI' 	, 'AllowOrigin' , '*' 						, cIniFile )

			if !( 'HTTP_START' $ getPvProfString( 'HTTPJOB' , 'MAIN' , '' , cIniFile , Nil, Nil) )
				oRpcSrv:CallProc("writePProString", 'HTTPJOB' , 'MAIN' 		, 'HTTP_START' 		, cIniFile )
				oRpcSrv:CallProc("writePProString", 'HTTPJOB' , 'ENVIRONMENT' 	, cAmbiente	, cIniFile )
			endif
			
			//verifica a necessidade de incluir HTTPJOB na chave JOBS da seção [OnStart]
			if !( 'HTTPJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile, Nil, Nil) )
				
				//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
				cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile , Nil, Nil)
				cOldJobs += iif( !empty( cOldJobs ) , ',HTTPJOB' , 'HTTPJOB' )
				
				oRpcSrv:CallProc("writePProString", 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile  )
				
				//crio a chave de RefreshRate apenas se não existir
				if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile, Nil, Nil ) )					
					oRpcSrv:CallProc("writePProString", 'OnStart' , 'RefreshRate' 	, '120'		, cIniFile  ) 
				endif
				
			endif
			
			//verifica a necessidade de incluir TAF_CFGJOB na chave JOBS da seção [OnStart]
			if !( 'TAF_CFGJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile, Nil, Nil) )
				
				//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
				cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile, Nil, Nil )
				cOldJobs += iif( !empty( cOldJobs ) , ',TAF_CFGJOB' , 'TAF_CFGJOB' )
							
				oRpcSrv:CallProc("writePProString", 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile)
				
				//crio a chave de RefreshRate apenas se não existir
				if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile, Nil, Nil) )					
					oRpcSrv:CallProc("writePProString", 'OnStart' , 'JOBS' 	, cOldJobs 		, cIniFile )
				endif
			
			endif
		else
			lRet := .T.
		endif
		
		//tentativa de escrita no arquivo de configuração do server, para criar a seção [TAF_CFGJOB]
		if (oRpcSrv:CallProc("writePProString", 'TAF_CFGJOB' , 'MAIN' , 'TAF_CFGJOB' , cIniFile))
			//criação e edição da seção [TAF_CFGJOB]
			oRpcSrv:CallProc("writePProString", 'TAF_CFGJOB' , 'Instances' 	, '3,10,3,1'		, cIniFile )
			oRpcSrv:CallProc("writePProString", 'TAF_CFGJOB' , 'PrepareIn'		, cEmpAnt		, cIniFile)
			oRpcSrv:CallProc("writePProString", 'TAF_CFGJOB' , 'Environment'	, cAmbiente		, cIniFile)
			oRpcSrv:CallProc("writePProString", 'TAF_CFGJOB' , 'RefreshRate'	, '120'			, cIniFile)
		else
			lRet := .T.
		endif

	else
	
		//verifica a necessidade de incluir HTTPJOB na chave JOBS da seção [OnStart]
		if !( 'HTTPJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile, Nil, Nil) )
			
			//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
			cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile , Nil, Nil)
			cOldJobs += iif( !empty( cOldJobs ) , ',HTTPJOB' , 'HTTPJOB' )
			
			oRpcSrv:CallProc("writePProString", 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile  )
			
			//crio a chave de RefreshRate apenas se não existir
			if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile, Nil, Nil ) )					
				oRpcSrv:CallProc("writePProString", 'OnStart' , 'RefreshRate' 	, '120'		, cIniFile  ) 
			endif
			
		endif
		
		//verifica a necessidade de incluir TAF_CFGJOB na chave JOBS da seção [OnStart]
		if !( 'TAF_CFGJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile, Nil, Nil) )
			
			//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
			cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile, Nil, Nil )
			cOldJobs += iif( !empty( cOldJobs ) , ',TAF_CFGJOB' , 'TAF_CFGJOB' )
						
			oRpcSrv:CallProc("writePProString", 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile)
			
			//crio a chave de RefreshRate apenas se não existir
			if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile, Nil, Nil) )					
				oRpcSrv:CallProc("writePProString", 'OnStart' , 'JOBS' 	, cOldJobs 		, cIniFile )
			endif
		
		endif
	
	endif
	
	oRpcSrv:Disconnect()

Else

	cIniFile :=	getAdv97()

	//verifica se o arquivo de configuração do servidor já possui um Socket 'HTTPREST'. Se já existir, assumo que essa parametrização
	//pode ser utilizada para o serviço do TAF.
	/*
		Caso o cliente nao tenha a pasta app ( Estrutura do Taf pelo instalador ),
		o comportamento da função getPvProfString muda dependendo do conteudo da variavel cIniFile.
		Ex:
		-> quando existe a pasta app:
		cInifile -> "C:\TOTVS\TAF\bin\app\appserver.ini"
		getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , cIniFile, Nil, Nil ) -> retorno -> "HTTPREST"

		-> quando não existe a pasta app:
		cIniFile -> appserver.ini
		getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , cIniFile, Nil, Nil) -> retorno -> ""
		
		Quando não existe a pasta app, o retorno da função getPvProfString só funcionou desse modo:
		getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , cIniFile ) -> retorno -> "HTTPREST"

	*/
	//if nWSPort > 0 .and. !( 'HTTPREST' $ getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , cIniFile, Nil, Nil ) )
	if nWSPort > 0 .and. !( 'HTTPREST' $ getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , cIniFile ) ) .And. File(cBinPath)
		
		//tentativa de escrita no arquivo de configuração do server, para criar a seção [HTTPV11]
		if writePProString( 'HTTPV11' , 'SOCKETS' , 'HTTPREST' , cIniFile )
		
			//habilita a seção [HTTPV11]
			writePProString( 'HTTPV11'	, 'ENABLE' 		, '1' , cIniFile )
			
			//criação e edição da seção [HTTPREST]
			writePProString( 'HTTPREST' , 'Port' 		, allTrim( str( nWSPort ) ) , cIniFile )
			writePProString( 'HTTPREST' , 'URIs' 		, 'HTTPURI' 				, cIniFile )
			writePProString( 'HTTPREST' , 'Security'	, '1' 						, cIniFile )
			
			//criação e edição da seção [HTTPURI]
			writePProString( 'HTTPURI' 	, 'URL' 		, '/rest' 					, cIniFile )
			
			//Com as mudanças em relação a arquitetura do WS ( tivemos que criar o TAF_CFGJOB para garantir que as threads não consumam licenças ), a chave abaixo foi retirada
			//writePProString( 'HTTPURI' 	, 'PrepareIn' 	, 'All' 					, cIniFile )
			
			writePProString( 'HTTPURI' 	, 'Instances' 	, '2,2' 					, cIniFile )
			writePProString( 'HTTPURI' 	, 'CORSEnable'	, '1' 						, cIniFile )
			writePProString( 'HTTPURI' 	, 'AllowOrigin' , '*' 						, cIniFile )
			
			//verifica a necessidade de incluir HTTP_START na chave MAIN da seção [HTTPJOB]
			if !( 'HTTP_START' $ getPvProfString( 'HTTPJOB' , 'MAIN' , '' , cIniFile ) )
				writePProString( 'HTTPJOB' , 'MAIN' 		, 'HTTP_START' 		, cIniFile )
				writePProString( 'HTTPJOB' , 'ENVIRONMENT' 	, getEnvServer()	, cIniFile )
			endif
			
			//verifica a necessidade de incluir HTTPJOB na chave JOBS da seção [OnStart]
			if !( 'HTTPJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile ) )
				
				//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
				cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile )
				cOldJobs += iif( !empty( cOldJobs ) , ',HTTPJOB' , 'HTTPJOB' )
				
				writePProString( 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile )
				
				//crio a chave de RefreshRate apenas se não existir
				if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile ) )
					writePProString( 'OnStart' , 'RefreshRate' 	, '120'		, cIniFile )
				endif
				
			endif
			
		else
			lRet := .T.
		endif
		
	endif
EndIf

return lRet

/*/{Protheus.doc} LockUpdAC
Controle de semáforo para controlar acesso exclusivo na atualização das tabelas autocontidas.
@author Victor Andrade
@since 24/06/2017
@version undefined
@type function
/*/
Static Function LockUpdAC()

Local cGrpCompany	:= FWGrpCompany()
Local cSemaphore	:= "TAFINIT" + cGrpCompany

Return( LockByName(cSemaphore, .F., .F.) )

/*/{Protheus.doc} UnLockUpdAC
Desabilita o semáforo de acesso exclusivo na atualização das tabelas autocontidas.
@author Victor Andrade
@since 24/06/2017
@version undefined

@type function
/*/
Static Function UnLockUpdAC()

Local cGrpCompany	:= FWGrpCompany()
Local cSemaphore	:= "TAFINIT" + cGrpCompany

Return( UnLockByName(cSemaphore, .F., .F.) )

/*/{Protheus.doc} LoadTmpWiz
Carrega as configurações extras do Wizard
@author Roberto Souza
@since 10/01/2018
@version undefined

@type function
/*/

Static Function LoadTmpWiz( cFileRef, nOpcx, aParChck )
	Local lRet
	
	If FindFunction( "TafTmpWiz" )
		lRet :=	TafTmpWiz( cFileRef, nOpcx, @aParChck )
	Else
		lRet := .F.
	EndIf
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFST2Vld
Retorna se os campos da tabela TAFST2 estão atualizados de acordo com a xTafGetStru
@author  Victor A. Barbosa
@since   17/05/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFST2Vld()

Local lRet 			
Local aNewStru		
Local aErros		
Local cTable
Local nX			

cTable				:= "TAFST2"
aNewStru			:= xTafGetStru( cTable )
lRet 				:= .T.
aErros 				:=	{}

If !MSFile( RetArq( __CRDD, cTable, .T. ), ,__CRDD )	
	xTAFCriaTB(,,"TAFST2" ,cTable,,,,,,,,@aErros )
EndIf

If !Empty( aErros ) ; TAFConOut( "Erro Criação Tabela TAFST2: " + aErros[1,6],3,.T.,"AUTCONT") ; Else ;

	If Select(cTable) == 0
		//Abre tabela em modo exclusivo para buscar a sua estrutura atual            
		Use &( cTable ) Alias &( cTable ) SHARED NEW Via __CRDD			
	EndIf
			
	aArqStru := (cTable)->( dbStruct() )

	For nX := 1 To Len( aNewStru[1] )
		If aScan( aArqStru, { |x| x[1] == aNewStru[1][nX][1] } ) == 0
			lRet := .F.
			Exit
		EndIf
	Next nX

	(cTable)->( dbCloseArea() )

EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} verificaIdsBase
Verifica se o ambiente esta com Ids Duplicados (eventos de cadastro)

@author  Evandro dos Santos Oliveira
@since   03/08/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function verificaIdsBase()

	Local aIdsDuplicados := {}
	Local aBotoes := {}
	Local cMensagem := ""
	Local cTitulo := ""
	Local nOpc := 0

	cMensagem := "Prezado cliente, a rotina de diagnóstico do TAF constatou que existe um problema "
	cMensagem += " a ser analisado pelo suporte da TOTVS em seu ambiente, pedimos que abra um ticket "
	cMensagem += " mencionando a exibição dessa mensagem para que os procedimentos necessários para "
	cMensagem += " correção sejam adotados. "

	aBotoes := {"Sair"}	

	aIdsDuplicados := TafGetIdDup("C")

	If Len(aIdsDuplicados) > 0
		nOpc := Aviso( cTitulo, cMensagem, aBotoes, 3 )
	EndIf 

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldComplem
Válida a amarração C1E x CR9 e se necessário invoca uma interface para 
que usuário possa efetuar a correção
@author  Victor A. Barbosa
@since   10/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function VldComplem()

Local cNextAlias 	:= GetNextAlias()
Local lRet		 	:= .F.
Local lCR9Priority	:= GetNewPar( "MV_TAFCFGE", .F. )

If lCR9Priority

	If Select(cNextAlias) > 0
		(cNextAlias)->( dbCloseArea() )
	EndIf

	// Se possuir mais de um registro na C1E para o mesmo código com status ativo, então está errado
	// Se possuir mais de um registro na CR9 para o mesmo código com status ativo, então está errado 
    BeginSQL Alias cNextAlias
		SELECT CODFIL, QUANTIDADE, ALIAS FROM (
			
			SELECT C1E_CODFIL CODFIL, COUNT(C1E_CODFIL) QUANTIDADE, 'C1E' ALIAS
			FROM %table:C1E% C1E 
			WHERE C1E_FILIAL = %xFilial:C1E% 
			AND C1E_ATIVO = '1' 
			AND C1E.%notdel% 
			AND C1E.C1E_CODFIL <> '<NPI>'
			GROUP BY C1E_CODFIL 
			HAVING COUNT(C1E_CODFIL) > 1
			
			UNION

			SELECT CR9_CODFIL CODFIL, COUNT(CR9_CODFIL) QUANTIDADE, 'CR9' ALIAS 
			FROM %table:CR9% CR9
			INNER JOIN %table:C1E% C1E
			ON CR9_FILIAL = C1E_FILIAL AND CR9_ID = C1E_ID AND CR9_VERSAO = C1E_VERSAO AND C1E_ATIVO = '1'
			WHERE CR9_FILIAL = %xFilial:CR9%
			AND	CR9_ATIVO = '1'
			AND	CR9.%notdel% 
			AND C1E.%notdel% 
			GROUP BY CR9_CODFIL
			HAVING COUNT(CR9_CODFIL) > 1
		) TAB
	EndSQL

	(cNextAlias)->( dbGoTop() )

	If (cNextAlias)->( !Eof() )
		MontaTela(cNextAlias)
	Else
		lRet := .T.
	EndIf


EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTela
Monta a tela para efetuar o ajuste do complemento cadastral
@author  Victor A. Barbosa
@since   10/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function MontaTela(cNextAlias)

Local oDlgComp 		:= Nil
Local oSize			:= Nil
Local oPanelTree	:= Nil
Local oTree			:= Nil

// Private para facilitar a interação com os componentes gráficos
Private oBrowseC1E	:= Nil
Private oBrowseCR9	:= Nil
Private oPanelMsg	:= Nil
Private oPanelC1E	:= Nil
Private oPanelCR9	:= Nil

// 2 - Layers necessários por conta da página informativa.
Private oLayerPai	:= Nil
Private oLayerRight	:= Nil

// Private pois precisa ser de escopo "global" no programa em questão para tratativas dos dados
Private aC1EData	:= {}
Private aCR9Data	:= {}

// Guarda o cargo atual para caso precise deletar o registro
Private cCargoAtu	:= "#PAI"

// Utilizado no label da janela
Private cCadastro	:= "Complemento Cadastral"

oSize := FwDefSize():New(.T.)

oDlgComp := MsDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3]-100 ,oSize:aWindSize[4]-100, "Complemento cadastral",,,,,,,,,.T.)

oLayerPai	:= 	FWLayer():New()
oLayerRight	:= 	FWLayer():New()

oLayerPai:Init(oDlgComp, .T.)

oLayerPai:AddCollumn("TREE"		, 30, .F., )
oLayerPai:AddCollumn("RIGHT"	, 70, .F., )

oLayerPai:AddWindow("TREE"		, "WNDTREE"		, "Filiais Inconsistentes"	, 95	, .F., .F., , )
oPanelTree	:= oLayerPai:GetWinPanel("TREE", "WNDTREE", )

oPanelRight := oLayerPai:GetColPanel("RIGHT")
oLayerRight:Init(oPanelRight, .T.)
oLayerRight:AddCollumn("DATA"	, 100, .F., )
oLayerRight:AddWindow("DATA"	, "WNDC1E", "Centralizadoras"	, 65 , .F., .F., , )
oLayerRight:AddWindow("DATA"	, "WNDCR9", "Subsidiárias", 30 , .F., .F., , )

oPanelC1E := oLayerRight:GetWinPanel("DATA", "WNDC1E")
oPanelCR9 := oLayerRight:GetWinPanel("DATA", "WNDCR9")

// Adiciona a grid com os dados da C1E
AddGridC1E()

// Adiciona a grid com os dados da CR9
AddGridCR9()

// Adiciona o Tree na tela
AddTree(oPanelTree, @oTree, cNextAlias)

oPanelMsg	:= tPanel():New(01,01,"",oPanelRight,,.T.,,,CLR_WHITE, oPanelRight:nHeight, oPanelRight:nWidth)
oLayerRight:Hide()
ShowMessage()

Activate MsDialog oDlgComp On Init EnchoiceBar( oDlgComp,; 
				{|| FWMsgRun(, {|| GrvNewComp(.F., oTree) }, "Processando", "Atualizando De/Para..."), oDlgComp:End() }, {|| oDlgComp:End() },,,,,,,.F. ) CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddTree
Adiciona o Tree com as filiais no seu devido painel
@author  Victor A. Barbosa
@since   11/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function AddTree(oPanelTree, oTree, cNextAlias)

Local cMsgItem		:= ""
Local cTituloFil	:= PadR("Filiais", 100)
Local nTamCargo		:= 4 + TamSX3("C1E_CODFIL")[1]
Local cCargoPai		:= PadR( "#PAI", nTamCargo )

DEFINE DBTREE oTree FROM 00,00 TO oPanelTree:nHeight, oPanelTree:nWidth OF oPanelTree ON CHANGE {|| ChangeTree(oTree) } CARGO

DBADDTREE oTree PROMPT cTituloFil OPEN RESOURCE "TAF_GRP_EMPRESAS" CARGO cCargoPai

While (cNextAlias)->( !Eof() )
	
	cMsgItem := "Filial: " + AllTrim( (cNextAlias)->CODFIL ) + " - " + (cNextAlias)->ALIAS + " Duplicada."
	DBADDITEM oTree PROMPT cMsgItem RESOURCE "TAF_FILIAL" CARGO (cNextAlias)->ALIAS + "." + (cNextAlias)->CODFIL

	(cNextAlias)->( dbSkip() )
EndDo

DBENDTREE oTree

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddGridC1E
Adiciona o Grid com os dados da C1E
@author  Victor A. Barbosa
@since   11/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function AddGridC1E()

DEFINE FWBROWSE oBrowseC1E DATA ARRAY ARRAY aC1EData NO SEEK NO CONFIG NO REPORT NO LOCATE Of oPanelC1E

oBrowseC1E:SetChange( { || ChangeLine( oBrowseC1E:At() ) } )

ADD MARKCOLUMN oColumn DATA { || IIf( aC1EData[oBrowseC1E:At(),1],'LBOK','LBNO') } DOUBLECLICK { || InvMarkC1E( oBrowseC1E:At(), "C1E" ) } Of oBrowseC1E
ADD COLUMN oColumn DATA { || aC1EData[oBrowseC1E:At(), 2] } Title "Id Registro"	PICTURE    SIZE 8  Of oBrowseC1E
ADD COLUMN oColumn DATA { || aC1EData[oBrowseC1E:At(), 3] } Title "Filial ERP"	PICTURE    SIZE 8  Of oBrowseC1E
ADD COLUMN oColumn DATA { || aC1EData[oBrowseC1E:At(), 4] } Title "Filial TAF"	PICTURE    SIZE 10 Of oBrowseC1E

ACTIVATE FWBrowse oBrowseC1E

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddGridCR9
Adiciona o Grid com os dados da CR9
@author  Victor A. Barbosa
@since   11/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function AddGridCR9()

DEFINE FWBROWSE oBrowseCR9 DATA ARRAY ARRAY aCR9Data NO SEEK NO CONFIG NO REPORT NO LOCATE Of oPanelCR9

ADD COLUMN oColumn DATA { || aCR9Data[oBrowseCR9:At(), 1] } Title "Id Registro"	PICTURE    SIZE 8  Of oBrowseCR9
ADD COLUMN oColumn DATA { || aCR9Data[oBrowseCR9:At(), 2] } Title "Filial ERP"	PICTURE    SIZE 8  Of oBrowseCR9
ADD COLUMN oColumn DATA { || aCR9Data[oBrowseCR9:At(), 3] } Title "Filial TAF"	PICTURE    SIZE 10 Of oBrowseCR9

ACTIVATE FWBrowse oBrowseCR9

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddGrid
Conteúdo apresentado quando está posicionado no item "Pai" da Tree
@author  Victor A. Barbosa
@since   11/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function ShowMessage()

Local cTextHtml	:= ""
Local oFont		:= TFont():New('Courier new',,-18,.T.)

// Monta o Texto no formato HTML
cTextHtml := '<font size="4" color="#0c9abe"><b>Atenção</b></font>'
cTextHtml += '<br/>'
cTextHtml += '<br/>'
cTextHtml += '<font size="3" color="#888">Foram encontradas inconsistências no <b>De/Para de Filiais</b> '
cTextHtml += 'cadastrado no TAF.</font>'
cTextHtml += '<br/>'
cTextHtml += '<br/>'
cTextHtml += '<font size="3" color="#888">Para maiores Detalhes acesse o link abaixo </font>'
cTextHtml += '<br/>'
cTextHtml += '<font size="2" color="#000"><a href="tdninterno.totvs.com">Documentação da Rotina</a></u></font>'
cTextHtml += '<br/>'
cTextHtml += '<br/>'
cTextHtml += '<br/>'
cTextHtml += '<br/>'
cTextHtml += '<br/>'
cTextHtml += '<font size="3" color="#FF0000"><b>Observação:</b> '
cTextHtml += '<br/>'
cTextHtml += '<font size="3" color="#FF0000">A utilização incorreta dessa funcionalidade pode gerar <b>inconsistências críticas</b> '
cTextHtml += '<font size="3" color="#FF0000">na ferramenta.</font>'

TSay():New(05,05,{||cTextHtml},oPanelMsg,,oFont,,,,.T.,,,400,300,,,,,,.T.)

oPanelMsg:Show()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeTree
Função executada na troca de objeto posicionado do tree
@author  Victor A. Barbosa
@since   11/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function ChangeTree(oTree)

Local cCargo 		:= ""
Local cCodFil		:= ""
Local cTabDupl		:= ""
Local lHasRegMark	:= .F.

If oTree <> Nil
	
	cCargo := oTree:GetCargo()

	If "#PAI" $ cCargo
		oLayerRight:Hide()
		ShowMessage()
	Else

		lHasRegMark := aScan( aC1EData, {|x| x[1] } ) > 0 .Or. aScan( aCR9Data, {|x| x[1] } ) > 0
		cCodFil 	:= SubStr( cCargo, At(".", cCargo) + 1 )
		cTabDupl	:= SubStr( cCargo, 1, 3 )

		// Se foi marcado registro, então persiste o registro gravado no banco
		If lHasRegMark
			If MsgYesNo( "Deseja efetivar as alterações realizadas?" + Chr(10) + Chr(13) + "Caso seja selecionada a opção <b>Não</b> as alterações serão descartadas." )
				FWMsgRun(, {|| GrvNewComp( .T., oTree ) }, "Processando", "Atualizando De/Para...")
			EndIf
		EndIf

		FWMsgRun(, {|| MontaArray(cCodFil, cTabDupl) }, "Filtrando", "Filtrando Registros...")
		oPanelMsg:Hide()
		oLayerRight:Show()
	EndIf

	// Atualiza a variável private, para se houver a necessidade de excluir o registro "anteriormente" posicionado em GrvNewComp
	cCargoAtu := cCargo

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaArray
Monta os arrays que serão utilizados nas interfaces gráficas
@author  Victor A. Barbosa
@since   14/01/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MontaArray(cFilShow, cTabDupl)

// Limpa os arrays declarados como private na chamada principal
aC1EData := {}

GetC1EData(cFilShow, cTabDupl)
ChangeLine(1)

oBrowseC1E:SetArray(aC1EData)
oBrowseC1E:Refresh()

oBrowseC1E:GoTop()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeLine
Função executada na troca de linha
@author  Victor A. Barbosa
@since   14/01/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function ChangeLine(nPos)

Local cAliasCR9 := "CR9ALIAS"
Local cFilCR9	:= ""

aCR9Data := {}
aSize(aCR9Data, 0)

If Len(aC1EData) > 0

	cFilCR9 := aC1EData[nPos][3]

	If Select(cAliasCR9) > 0
		(cAliasCR9)->( dbCloseArea() )
	EndIf

	BeginSQL Alias cAliasCR9
		SELECT C1E_ID ID, C1E_FILTAF FILTAF, CR9_CODFIL CODFIL, CR9.R_E_C_N_O_ RECNO FROM %table:CR9% CR9
		INNER JOIN %table:C1E% C1E
		ON CR9_FILIAL = C1E_FILIAL AND CR9_ID = C1E_ID AND CR9_VERSAO = C1E_VERSAO 
		WHERE C1E_FILTAF = %exp:cFilCR9%
		AND CR9_ATIVO = '1'
		AND C1E_ATIVO = '1'
		AND C1E_FILIAL = %xFilial:C1E%
		AND CR9.%notdel%
		AND C1E.%notdel%
	EndSQL

	While (cAliasCR9)->( !Eof() )

		aAdd( aCR9Data, { 	(cAliasCR9)->ID,; 
							(cAliasCR9)->FILTAF,;
							(cAliasCR9)->CODFIL,;
							(cAliasCR9)->RECNO})

		(cAliasCR9)->( dbSkip() )

	EndDo

EndIf

If Len(aCR9Data) == 0
	aAdd(aCR9Data, { "", "", "",} )
EndIf

If oBrowseCR9 <> Nil
	oBrowseCR9:SetArray(aCR9Data)
	oBrowseCR9:Refresh()
	oBrowseCR9:GoTop()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetC1EData
Retorna as filiais da C1E de acordo com o código passado
@author  Victor A. Barbosa
@since   14/01/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function GetC1EData(cFilC1E, cTabDupl)

Local cAliasC1E := "C1EALIAS"

If Select(cAliasC1E) > 0
	(cAliasC1E)->( dbCloseArea() )
EndIf

If cTabDupl == "C1E"

	BeginSQL Alias cAliasC1E
		SELECT C1E_ID ID, C1E_VERSAO, C1E_FILTAF FILTAF, C1E_CODFIL CODFIL, C1E.R_E_C_N_O_ RECNO FROM %table:C1E% C1E
		WHERE C1E_CODFIL = %exp:cFilC1E%
		AND C1E_CODFIL <> '<NPI>'
		AND C1E_FILIAL = %xFilial:C1E%
		AND C1E_ATIVO = '1'
		AND C1E.%notdel%
	EndSQL

Else

	If Select(cAliasC1E) > 0
		(cAliasC1E)->( dbCloseArea() )
	EndIf

	BeginSQL Alias cAliasC1E
		SELECT C1E_ID ID, C1E_VERSAO, C1E_FILTAF FILTAF, C1E_CODFIL CODFIL, C1E.R_E_C_N_O_ RECNO FROM %table:CR9% CR9
		INNER JOIN %table:C1E% C1E
		ON CR9_FILIAL = C1E_FILIAL AND CR9_ID = C1E_ID AND CR9_VERSAO = C1E_VERSAO
		WHERE CR9_CODFIL = %exp:cFilC1E% 		
		AND CR9_ATIVO = '1'
		AND C1E_ATIVO = '1'
		AND C1E_FILIAL = %xFilial:C1E%
		AND CR9.%notdel%
		AND C1E.%notdel%
	EndSQL

EndIf

(cAliasC1E)->( dbGoTop() )

While (cAliasC1E)->( !Eof() )

	aAdd( aC1EData, { 	.F.,;
						(cAliasC1E)->ID,;
						(cAliasC1E)->FILTAF,;
						(cAliasC1E)->CODFIL,;
						(cAliasC1E)->RECNO,; 
						(cAliasC1E)->C1E_VERSAO} )

	(cAliasC1E)->( dbSkip() )

EndDo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InvMarkC1E
Inverte a marcação do registro ao efetuar um duplo click
@author  Victor A. Barbosa
@since   15/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function InvMarkC1E(nPos)

Local lHasMark := aScan( aC1EData, {|x| x[1] } ) > 0

If !aC1EData[nPos][1]
	If !lHasMark
		aC1EData[nPos][1] := .T.
	Else
		MsgAlert("Só é possuir uma filial válida")
	EndIf
Else
	aC1EData[nPos][1] := .F.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvNewComp
Efetua a gravação do complemento de empresa
@author  Victor A. Barbosa
@since   16/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function GrvNewComp(lDelNode, oTree)

Local nPosMark	:= 0
Local aArea		:= GetArea()
Local cCargo	:= oTree:GetCargo()
Local cFilInat	:= PadR(AllTrim(SubStr(cCargo, At(".", cCargo) + 1)), TamSX3("CR9_CODFIL")[1])
Local cTabInat	:= SubStr( cCargo, 1, 3 )

Default lDelNode	:= .F.

dbSelectArea("C1E")
dbSelectArea("CR9")
CR9->( dbSetOrder(1) )

If cTabInat == "C1E"
	For nPosMark := 1 To Len(aC1EData)
		C1E->( dbGoTo( aC1EData[nPosMark][5] ) )
		If RecLock( "C1E", .F. )
			C1E->C1E_ATIVO := Iif( aC1EData[nPosMark][1], "1", "2" )
			C1E->( MsUnlock() )
		EndIf

		CR9->(DbSetOrder(4))
		If CR9->( MsSeek( C1E->( C1E_FILIAL + C1E_ID + C1E_VERSAO ) ) )
			While CR9->( CR9_FILIAL + CR9_ID + CR9_VERSAO ) == C1E->( C1E_FILIAL + C1E_ID + C1E_VERSAO )
				RecLock( "CR9", .F. )
					CR9->CR9_ATIVO := Iif( aC1EData[nPosMark][1], "1", "2" )
				CR9->(DbSkip())
			End
		EndIf

	Next nX
Else
	For nPosMark := 1 To Len(aC1EData)
		If CR9->( dbSeek( xFilial("CR9") + aC1EData[nPosMark][2] + cFilInat + aC1EData[nPosMark][6]) )
			If RecLock( "CR9", .F. )
				CR9->CR9_ATIVO := Iif( aC1EData[nPosMark][1], "1", "2" )
				CR9->( MsUnlock() )
			EndIf
		EndIf
	Next nPosMark
EndIf


If lDelNode

	// --> Volta o posicionamento para o node anterior, que acabou de ser excluído o nó
	If oTree:TreeSeek( cCargoAtu )
		
		oTree:DelItem()
		oTree:PTRefresh()

		// Força o posicionamento no node que foi clicado
		oTree:TreeSeek( oTree:GetCargo() )

	EndIf
EndIf

RestArea(aArea)

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldIntAtv
@type			function
@description	Valida se as versões do sistema suportam a criação do campo de controle 
				(S_T_A_M_P_) nas tabelas de integração entre SIGAFIS e TAF.
@Parametros    - cMsgIA, cLink: Mensagem e link que são ajustados por referência
               - lTafModule: Variável que garante que o TAF está como módulo, 
			     Se a visão for do Protheus para o TAF, usamos a função TemRegC1E()
				 Se a visão do do TAF para o PRotheus, usamos a função TemRegSFT() 
				 parâmetro MV_TAFFPRO. Ver documentação no tdn

@author			Carlos Eduardo
@since			15/05/2020
/*/
//-------------------------------------------------------------------------------------\-----------
Function VldIntAtv(cMsgIA, cLink, lTafModule ) 
Local lRet 		 := .t.
Local aGetBuild	 := strtokarr(GetBuild( .f.),'-')
Local cDbAcesBld := TCGetBuild()//TCAPIBuild()
Local cMsg		 := ''
/*
	A função TCCONFIG tem que ser macro executada, pois estava causando erro de Invalid function type. Please check RPO file
	Detalhes em https://tdn.totvs.com/x/B4eUD
*/
Local cFn        := "TCCONFIG"

Default cLink := ' '
Default lTafModule := .f.   

if lTafModule
	cMsg := 'Para modelo de integração TSI - TAF SERVICE INTEGRATION, será necessário atualização dos itens abaixo: '
	if aGetBuild[1] < '7.00.191205P' .or. (aGetBuild[1] >= '7.00.191205P' .and. aGetBuild[2] < '20190923') 
		cMsg += CRLF + '- TOTVS Server Application.'
		cLink := 'https://tdn.totvs.com/pages/viewpage.action?pageId=233757223#ModeloseProcessosdeIntegra%C3%A7%C3%A3o-Vers%C3%A3oTOTVSServerApplication'
		lRet := .f. 
	endif
	//if substr(cDbAcesBld,1,8) < '20191119' .or. ( substr(cDbAcesBld,1,8) >= '20191119' .and. substr(cDbAcesBld,10,8) < '20191206' )
	if cDbAcesBld < '20191119' 
		cMsg += CRLF + '- TOTVS DbAccess.'
		cLink := 'https://tdn.totvs.com/pages/viewpage.action?pageId=233757223#ModeloseProcessosdeIntegra%C3%A7%C3%A3o-Vers%C3%A3oTOTVSDbAccess'
		lRet := .f.
	endif
	if lRet .and. FindFunction( cFn )
		if &cFn.('SETAUTOSTAMP=ON') == 'NOT_SUPPORTED'
			cMsg := 'Seu banco de dados não possui suporte para integração TSI - TAF SERVICE INTEGRATION'
			cLink := 'https://tdn.totvs.com/pages/viewpage.action?pageId=233757223#ModeloseProcessosdeIntegra%C3%A7%C3%A3o-Bancodedadospossuisuporte?'
			lRet := .f.
			// Se o banco não tiver suporte, mesmo os requisitos de atualização ba base
			// forem atendidos, não iremos mostrar o botão no extrator fiscal, seto lTafModule := .f. 
			// para não exibir o botão.
			lTafModule := .f. // variável passada por referêcnia
		else
			&cFn.('SETAUTOSTAMP=OFF')"
			
		endif	
	endif 
		
	if !lRet; cMsgIA := cMsg; endif

endif

return lRet

/*/{Protheus.doc} VldIntSch
@description Valida se as versões do sistema suportam a criação do campo de controle 
				S_T_A_M_P_ nas tabelas de integração entre SIGAFIS e TAF.
@parameter cMsgNewSch
@parameter cLink
@parameter lTafModule
@return logical, .T. - OK, .F. - NOK
@type function
@author Melkz Siqueira
@since 09/05/2024
/*/
Function VldIntSch(cMsgIA as character, cLink as character, lTafModule as logical)

	Local cFn        	:= ""	as character
	Local cMsg			:= ""	as character
	Local lRet 		 	:= .T.	as logical

	Default cMsgIA		:= ""   
	Default cLink		:= ""   
	Default lTafModule	:= .F.   

	If lTafModule
		cMsg 	:= "Para modelo de INTEGRAÇÃO SMART SCHEDULE, será necessário atualização dos itens abaixo: "
		cFn 	:= "TCCONFIG" // A função TCCONFIG tem que ser macro executada, pois estava causando erro de Invalid function type. Please check RPO file. Detalhes em https://tdn.totvs.com/x/B4eUD
		
		If FindFunction(cFn)
			If &cFn.('SETAUTOSTAMP=ON') == "NOT_SUPPORTED"; lRet := .F.; lTafModule := .F.; cMsg := "Seu banco de dados não possui suporte para INTEGRAÇÃO SMART SCHEDULE"; cLink := "https://tdn.totvs.com/pages/viewpage.action?pageId=233757223#ModeloseProcessosdeIntegra%C3%A7%C3%A3o-Bancodedadospossuisuporte?"; Else; &cFn.("SETAUTOSTAMP=OFF"); EndIf
		EndIf 
	EndIf

	If !lRet; cMsgIA := cMsg; EndIf

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistStamp
@type			function
@description	Valida se todos os campos necessários STAMP estão criados em suas
				respectivas tabelas.
@author			Henrique Pereira
@since			18/05/2020
/*/
//-------------------------------------------------------------------------------------\-----------
function ExistStamp(cMsg, cLink, cTab)
Local aTables 		:= {}
Local nTable		:= 0
Local lRet 			:= .t.
Local nLenTbl   	:= 0
Local nCountTbls	:= 0

Default cMsg	:= ''
Default cLink	:= ''  
Default cTab	:= ''

//Se verificação de STAMP for unitária, defino array com tamanho 1
if !Empty(cTab)
	aTables  := {cTab} 
	nLenTbl  := 1
else
	aTables  := getTblTSI()
	nLenTbl  := len(aTables) 
endif

for nTable := 1 to nLenTbl
	if Ascan( TCStruct(RetSqlName( aTables[nTable] )), {|x| x[1] == 'S_T_A_M_P_' }) == 0
		nCountTbls++ 
		if nCountTbls == 1
			lRet := .f.
			cMsg += 'Modelo de integração TSI - TAF SERVICE INTEGRATION indisponível. Não foi encontrado o campo S_T_A_M_P_ para as tabelas: '
			cMsg += CRLF + aTables[nTable] 
		elseif nCountTbls > 1 .and. nTable < nLenTbl
			cMsg += ', ' + aTables[nTable] 
		elseif nTable == nLenTbl
			cMsg += ' e ' + aTables[nTable] +' clique para maiores informações' 
		endif  
		cLink	:=	'https://tdn.totvs.com/pages/viewpage.action?pageId=233757223#ModeloseProcessosdeIntegra%C3%A7%C3%A3o-Erronacria%C3%A7%C3%A3odocampoS_T_A_M_P_'
	endif 
next

return lRet 
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTblTSI
@type			static function
@description	Retorna todas as tabelas que necessítam do stamp
@author			Henrique Pereira
@since			18/05/2020
/*/
//-------------------------------------------------------------------------------------\-----------
Function getTblTSI()
Local cTbls := 'SB1|SFT|SF4|SB5|SA1|SA2|SA4|SAH|CT1|F2Q|CDN|SE1|SE2|CCF|SF1|SF2|SF3|CCE|SYD|CDH|CKX|SON|CDT|CDG|CTT|CD1|'
Local aRet 	:= STRTOKARR(cTbls,'|' )

return aRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuTabTAF
	@descriptionVerifica se existe a necessidade de atualiar a estrutura das tabelas compartilhadas do TAF.
	@type  Static Function
	@author Rafael Leme
	@since 08/02/2022
/*/
//---------------------------------------------------------------------------------------------------------
Static Function atuTabTAF(aEmps)

Local nX := 0

Default aEmps := {}

// Verifico se existe diferença entre a data no fonte TAFINIT e a data no parâmetro MV_DTABTAF.
// Caso o parâmetro não exista, será retornado '20220101'.
	lAtuTabTAF := Iif(GetNewPar( "MV_DTABTAF", StoD('20220101')) <> StoD(cDtTabTAFSD), .T., .F.)

	If !lAtuTabTAF

		lAtuTabTAF := Iif (!TcCanOpen( "TAFST1"  ) .And. lAtuTabTAF == .F., .T., lAtuTabTAF)
		lAtuTabTAF := Iif (!TcCanOpen( "TAFST2"  ) .And. lAtuTabTAF == .F., .T., lAtuTabTAF)
		lAtuTabTAF := Iif (!TcCanOpen( "TAFXERP" ) .And. lAtuTabTAF == .F., .T., lAtuTabTAF)
		
		For nX := 1 to Len(aEmps)
			lAtuTabTAF := Iif (!TcCanOpen( "TAFECF"  + "_" + AllTrim(aEmps[nX, 2]) ) .And. lAtuTabTAF == .F., .T., lAtuTabTAF)
			lAtuTabTAF := Iif (!TcCanOpen( "TAFSPED" + "_" + AllTrim(aEmps[nX, 2]) ) .And. lAtuTabTAF == .F., .T., lAtuTabTAF)
		Next nX

		lAtuTabTAF := Iif (!TcCanOpen( "TAFGERCTL" ) .And. lAtuTabTAF == .F., .T., lAtuTabTAF)

	Endif

Return

/*{Protheus.doc} ChkIntIA
Realiza a checagem da seleção do checkbox do TSI - TOTVS SERVICE INTEGRATION
@return Nil
@type static function
@author Melkz Siqueira
@since 14/05/2024
*/
Static Function ChkIntIA()

	Local lBkpChkISh := lChkIntSch as logical
 
	lChkIntSch := .F.

	If oChkIntSch != Nil
		oChkIntSch:Refresh()
	EndIf

	oChkIA:SetFocus()

	If lAntChkIA == Nil
		lAntChkIA := !lChkIA
	EndIf
	
	If lChkIA .And. (lBkpChkISh .Or. (lAntChkISh != Nil .And. lAntChkISh)) .And.;
		!FWAlertNoYes(STR0161 + CRLF + CRLF + STR0166 + CRLF + CRLF + STR0167, STR0160) // "Prezado cliente," / "A opção INTEGRAÇÃO SMART SCHEDULE estava selecionada. Não é possível utilizar a integração via Smart Schedule e TSI simultaneamente. Uma vez selecionada essa opção, não recomendamos voltar para a integração via TSI." / "Deseja continuar?" / "Atenção!"
		lChkIA 		:= .F.
		lAntChkIA	:= lChkIA

		oChkIA:Refresh()
		
		If lBkpChkISh
			lChkIntSch := .T.
		EndIf
		
		If oChkIntSch != Nil
			oChkIntSch:Refresh()
		EndIf

		oChkIA:SetFocus()
	EndIf

Return

/*{Protheus.doc} ChkIntSch
Realiza a checagem da seleção do checkbox da INTEGRAÇÃO SMART SCHEDULE
@return Nil
@type static function
@author Melkz Siqueira
@since 14/05/2024
*/
Static Function ChkIntSch()

	Local lBkpChkIA := lChkIA as logical
 
	lChkIA := .F.

	If oChkIA != Nil
		oChkIA:Refresh()
	EndIf

	oChkIntSch:SetFocus()

	If lAntChkISh == Nil
		lAntChkISh := !lChkIntSch
	EndIf

	If lChkIntSch .And. (lBkpChkIA .Or. (lAntChkIA != Nil .And. lAntChkIA)) .And.;
		!FWAlertYesNo(STR0161 + CRLF + CRLF + STR0162 + CRLF + CRLF + STR0167, STR0160) // "Prezado cliente," / "Ao selecionar a opção INTEGRAÇÃO SMART SCHEDULE, a integração via TSI será desabilitada e toda sua integração será feita via Smart Schedule. Não será possível utilizar o TSI e a integração via Smart Schedule simultaneamente. Uma vez selecionada essa opção não recomendamos voltar para a integração via TSI." / "Deseja continuar?" / "Atenção!"
		lChkIntSch := .F.
		lAntChkISh := lChkIntSch

		oChkIntSch:Refresh()
		
		If lBkpChkIA
			lChkIA := .T.
		EndIf
		
		If oChkIA != Nil
			oChkIA:Refresh()
		EndIf
		
		oChkIntSch:SetFocus()
	EndIf

Return

/*/{Protheus.doc} ModSmrtSch
Função responsável por renderizar o modal com as informações sobre a integração via Smart Schedule
@type static function
@author Melkz Siqueira
@since 07/08/2024
@version 1.0
@return Boolean, .T.
/*/
Static Function ModSmrtSch()

	Local cWarning		as character
	Local cDisclaimer	as character
	Local cLink     	as character
	Local oModal 		as object
	Local oWarning		as object
	Local oDisclaimer	as object
	Local oContainer	as object
	Local xTAFIsch		as variant

	xTAFIsch := GetMV( "MV_TAFISCH",, "0" )

	If ValType( xTAFIsch ) == "L"
		xTAFIsch := IIf( xTAFIsch, "1", "0" )
	EndIf

	If ( /*GetRpoRelease() == "12.1.2410" .or.*/ SuperGetMv( "MV_TAFDEV",, .F. ) ) .and. xTAFIsch != "1"
	 	cLink	:= "https://tdn.totvs.com/pages/viewpage.action?pageId=862102269"
		oModal 	:= FWDialogModal():New()

		oModal:SetEscClose(.T.)
		oModal:SetTitle(STR0168) // "Integração Livros Fiscais X TAF"
		oModal:SetSubTitle(STR0169) // "Novo método de integração"
		oModal:SetSize(150, 250)
		oModal:CreateDialog()
		oModal:AddCloseButton(Nil, STR0170) // "Fechar"

		oContainer := TPanel():New(000, 000,, oModal:GetPanelMain(),, .T.,,,, 249, 091,, .T.)

		cWarning := '<p>' + STR0171 + '</p>' // O Smart Schedule está disponível como um novo método de integração entre os Livros Fiscais e TAF. Com ele, a integração será feita de forma mais rápida e eficiente.
		cWarning += '<p>' + STR0172 + ' <strong>"' + STR0173 + '"</strong> ' + STR0174 + '</p>' // Para usar este novo método de integração, basta selecionar a opção // "INTEGRAÇÃO SMART SCHEDULE" // e concluir a configuração do Wizard.

		oWarning := TSay():New(002, 002, {|| cWarning}, oContainer,,,,,, .T.,,, 240, 090,,,,,, .T., 3)

		oWarning:SetCss("TSay { font-size: 12px; }")

		cDisclaimer := '<p>' + STR0175 + '</p>' // Para mais informações, acesse a documentação no TDN.

		oDisclaimer := TSay():New(050, 002, {|| cDisclaimer}, oContainer,,,,,, .T.,,, 240, 090,,,,,, .T., 2)

		oDisclaimer:SetCss("TSay { font-size: 12px; color: " + oCSS:oTheme:brand01Dark + "; }")

		THButton():New(065, 060, STR0176, oContainer, {|| ShellExecute("open", cLink, "", "", 1)}, 120, 010,, cLink) // "Clique aqui para acessar a documentação."

		oModal:Activate()
	EndIf

Return .T.
