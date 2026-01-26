#include "totvs.ch"
#include "fwMVCDef.ch"
#include "OFCNHA06.ch"
#include "FWEVENTVIEWCONSTS.CH"

static OFCNHA06ModStru

/*/{Protheus.doc} OFCNHA06
Classe de Configuracao do ERP Prim CNH
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Function OFCNHA06()
Private oArHlp  := DMS_ArrayHelper():New()
Private oConfig := OFCNHPrimConfig():New()
Private oCfgAtu := oConfig:GetConfig()
Private oModel2 := GetModel02()
Private oModel3 := GetModel03()

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0001 )	// #"Configurao ERP"
	oExecView:setSource("OFCNHA06")
	oExecView:setOK({ |oModel| OA5080012_Confirmar(oModel) })
	oExecView:setCancel({ || .T. })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
Return .T.


/*/{Protheus.doc} OA5080012_Confirmar
Salva os dados e fecha janela de configurao
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
static function OA5080012_Confirmar(oForm)
local oMaster    := oForm:GetModel("MASTER")
Local oGrdLocais := oForm:GetModel("LOCAIS")
Local oGrdSenhas := oForm:GetModel("SENHAS")
local aFiliais   := oConfig:aFiliais
local aDados     := {}
local nI
local oJSON

	oCfgAtu := JsonObject():New()
	oCfgAtu["MOEDA"]         := AllTrim(oMaster:GetValue("MOEDA"))
	oCfgAtu["DIR_IN"]        := AllTrim(oMaster:GetValue("DIR_IN"))
	oCfgAtu["DIR_OUT"]       := AllTrim(oMaster:GetValue("DIR_OUT"))
  	oCfgAtu["DIR_LIDOS"]     := AllTrim(oMaster:GetValue("DIR_LIDOS"))
	oCfgAtu["EMAIL_SERVER"]  := AllTrim(oMaster:GetValue("EMAIL_SERVER"))
	oCfgAtu["EMAIL_USER"]    := AllTrim(oMaster:GetValue("EMAIL_USER"))
	oCfgAtu["EMAIL_PASS"]    := AllTrim(oMaster:GetValue("EMAIL_PASS"))
	oCfgAtu["EMAIL_SENDER"]  := AllTrim(oMaster:GetValue("EMAIL_SENDER"))
	oCfgAtu["EMAIL_OCORREN"] := AllTrim(oMaster:GetValue("EMAIL_OCORREN"))
	oCfgAtu["EMAIL_AUTH"]    := alltrim(oMaster:GetValue("EMAIL_AUTH"))
	oCfgAtu["EMAIL_SECURE"]  := alltrim(oMaster:GetValue("EMAIL_SECURE"))
	oCfgAtu["AMBIENTE"]      := AllTrim(oMaster:GetValue("AMBIENTE"))
	oCfgAtu["LOGS"]          := AllTrim(oMaster:GetValue("LOGS"))
	oCfgAtu["GRUPO"]         := AllTrim(oMaster:GetValue("GRUPO"))
	oCfgAtu["CONDPAGTO"]     := AllTrim(oMaster:GetValue("CONDPAGTO"))
	oCfgAtu["CODCLIRECOMP"]  := AllTrim(oMaster:GetValue("CODCLIRECOMP"))
	oCfgAtu["LOJCLIRECOMP"]  := AllTrim(oMaster:GetValue("LOJCLIRECOMP"))

	for nI := 1 to oGrdLocais:Length()
		oGrdLocais:GoLine(nI)
		if ! oGrdLocais:IsDeleted()
			oJSON := JsonObject():New()
			oJSON["GRUPO"]     := alltrim( oGrdLocais:GetValue('GRUPO') )
			oJSON["DESCRICAO"] := alltrim( oGrdLocais:GetValue('DESCRICAO') )
			oJSON["WAREHOUSE"] := alltrim( oGrdLocais:GetValue('WAREHOUSE') )
			aAdd(aDados, oJSON)
		endif
	next
	oCfgAtu["LOCAIS"] := aDados

	aDados := {}
	for nI := 1 to oGrdSenhas:Length()
		oGrdSenhas:GoLine(nI)
		if ! oGrdSenhas:IsDeleted()
			oJSON := JsonObject():New()
			oJSON["FILIAL"]         := alltrim( oGrdSenhas:GetValue('FILIAL') )
			oJSON["USUARIO"]        := alltrim( oGrdSenhas:GetValue('USUARIO') )
			oJSON["SENHA"]          := alltrim( oGrdSenhas:GetValue('SENHA') )
			oJSON["DEALERCODE"]     := alltrim( oGrdSenhas:GetValue('DEALERCODE') )
			oJSON["MERCADO"]        := alltrim( oGrdSenhas:GetValue('MERCADO') )
			oJSON["D1NUMSEQ"]       := iif( len(aFiliais) >= nI, aFiliais[nI][2], "" )
			oJSON["D2NUMSEQ"]       := iif( len(aFiliais) >= nI, aFiliais[nI][3], "" )
			oJSON["D3NUMSEQ"]       := iif( len(aFiliais) >= nI, aFiliais[nI][4], "" )
			oJSON["NROTRANSMISSAO"] := iif( len(aFiliais) >= nI, aFiliais[nI][5], "" )
			aAdd(aDados, oJSON)

			if ! empty( oJSON["DEALERCODE"] )
				oCfgAtu["DIR_IN"]  := criaArvore( oJSON["DEALERCODE"], oCfgAtu["DIR_IN"] )
				oCfgAtu["DIR_OUT"] := criaArvore( oJSON["DEALERCODE"], oCfgAtu["DIR_OUT"] )
		        oCfgAtu["DIR_LIDOS"] := criaArvore( oJSON["DEALERCODE"], oCfgAtu["DIR_LIDOS"] )
			endif
		endif
	next
	oCfgAtu["SENHAS"]         := aDados

	oConfig:SaveConfig(oCfgAtu)

	OA060004C_log( "PRIM" /*cAgroup*/ , "CONFIG SALVO" /*cTipo*/, FGX_JSONform( oCfgAtu:toJson(), .T., , .T. ) /*cDados*/, .T. )
return .T.


/*/{Protheus.doc} ViewDef
Definio da tela principal
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Static Function ViewDef()
local oModel  := Modeldef()
local oView   := FWFormView():New()
local oStr1   := OFCNHA06ModStru:GetView()
local oModel2 := GetModel02()
local oModel3 := GetModel03()
local oStr2   := oModel2:GetView()
local oStr3   := oModel3:GetView()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox('TELA', 100)
	oView:CreateFolder('FOLDER', 'TELA')

	oView:AddSheet('FOLDER', 'SHEET1', STR0002)		// #Principal
	oView:AddSheet('FOLDER', 'SHEET2', STR0003)		// #'Grupos e Armazéns'

	oView:CreateHorizontalBox('BOX1',  50,,,'FOLDER', 'SHEET1')
	oView:CreateHorizontalBox('BOX2',  50,,,'FOLDER', 'SHEET1')
	oView:CreateHorizontalBox('BOX3', 100,,,'FOLDER', 'SHEET2')

	oStr1:AddGroup("ACC", STR0002,"FOLDER",2)	// #Principal
	oStr1:AddGroup("EMA", STR0004,"FOLDER",2)	// #E-mail

	oView:AddField('FORM1', oStr1, 'MASTER')
	oView:AddGrid('GRID2' , oStr2, 'SENHAS')
	oView:AddGrid('GRID3' , oStr3, 'LOCAIS')

	oView:EnableTitleView('FORM1', STR0005)		// #Configuração
	oView:EnableTitleView('GRID2', STR0006)		// #Senhas
	oView:EnableTitleView('GRID3', STR0007)		// #Grupos e Depósitos

	oView:SetOwnerView('FORM1','BOX1')
	oView:SetOwnerView('GRID2','BOX2')
	oView:SetOwnerView('GRID3','BOX3')

	oView:AddUserButton( STR0008,'PARAMETROS',{|| FWMsgRun(, {|oObj| tstConn(oObj) }, STR0009, STR0010 ) })		// #Conectar	#Conexão com PRIM CNH	#Aguarde, tentando conexão
	oView:AddUserButton( STR0013,'PARAMETROS',{|| OFCNHA07()})	// #Log
Return oView


/*/{Protheus.doc} ModelDef
Modelo
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Static Function Modeldef()
Local oModel  := MPFormModel():New('OFCNHA06')
Local oModel2 := GetModel02()
Local oModel3 := GetModel03()
Local oStr1
Local oStr2   := oModel2:GetModel()
Local oStr3   := oModel3:GetModel()

	if OFCNHA06ModStru == NIL
		OFCNHA06ModStru := GetModel01()
	endif
	
	oStr1 := OFCNHA06ModStru:GetModel()


	oModel:SetDescription( STR0014 )	// #Integração ERP
	
	oModel:AddFields("MASTER",,oStr1,,,{|| OA060001C_Load01Dados() })

	oModel:AddGrid("LOCAIS", "MASTER", oStr3,;
		{|oMdl, nLin, cAction, cAttr, uVal1, uVal2| OA060002C_OnChange(oMdl, nLin, cAction, cAttr, uVal1, uVal2) },;
		,,, {|| Load03Dados() })

	oModel:AddGrid("SENHAS", "MASTER", oStr2,;
		{|oMdl, nLin, cAction, cAttr, uVal1, uVal2| OA060002C_OnChange(oMdl, nLin, cAction, cAttr, uVal1, uVal2) },;
		,,, {|| Load02Dados() })

	oModel:getModel("MASTER"):SetDescription( STR0005 )	// #Configuração
	oModel:getModel("LOCAIS"):SetDescription( STR0007 )	// #Grupos e Depósitos
	oModel:getModel("SENHAS"):SetDescription( STR0006 )	// #Senhas

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("OFCNHA06", /*cOwner*/, OFCNHA06EVDEF():New() )
Return oModel


/*/{Protheus.doc} GetModel01
Dados base do funcionamento
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
Static Function GetModel01()
Local oMd1 := OFDMSStruct():New()

	oMd1:AddField({;
		{'cTitulo'     , STR0015 },;	// #Moeda
		{'nTamanho'    , 3},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'MOEDA'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@!'},;
		{'cTooltip'    , STR0015};		// #Moeda
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0016},;		// #Diretório Entrada
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'DIR_IN'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'bValid'      , {|oMdl, cAttr, uValAnt| chkDir( oMdl:GetValue(cAttr) )}},;
		{'cTooltip'    , STR0016};		// #Diretório Entrada
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0017},;		// #Diretório Saída
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'DIR_OUT'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'bValid'      , {|oMdl, cAttr, uValAnt| chkDir( oMdl:GetValue(cAttr) )}},;
		{'cTooltip'    , STR0017};		// #Diretório Saída
	})

  oMd1:AddField({;
		{'cTitulo'     , STR0103},;		// #Diretório Lidos
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'DIR_LIDOS'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'bValid'      , {|oMdl, cAttr, uValAnt| chkDir( oMdl:GetValue(cAttr) )}},;
		{'cTooltip'    , STR0103};		// #Diretório Lidos
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0018},;		// #Servidor E-mail
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'EMAIL_SERVER'},;
		{'cGroup'      , "EMA"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0019};		// #'Endereço e porta do servidor de e-mail'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0020},;		// #Conta E-mail
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'EMAIL_USER'},;
		{'cGroup'      , "EMA"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0021};		// #'Usuário de conexão com servidor de e-mail'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0022},;		// #'Senha E-mail'
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'EMAIL_PASS'},;
		{'cGroup'      , "EMA"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0023};		// #'Senha do usuário de conexão com servidor de e-mail'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0024},;		// #'E-mail de envio'
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'EMAIL_SENDER'},;
		{'cGroup'      , "EMA"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0025};		// #'Conta de e-mail que enviará as notificações'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0026},;		// #'E-mail ocorrências'
		{'nTamanho'    , 80},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'EMAIL_OCORREN'},;
		{'cGroup'      , "EMA"},;
		{'lObrigat'    , .T.},;
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0027};		//#'Conta de e-mail que receberá as notificações'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0028},;		//#'Autenticação'
		{'nTamanho'    , 1},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'EMAIL_AUTH'},;
		{'cGroup'      , "EMA"},;
		{'lObrigat'    , .T.},;
		{'aComboValues', {STR0029,STR0030} },;		// #'1=Sim'		#'2=Não'
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0031};		//#'Servidor exige autenticação?'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0032},;		// #'Segurança'
		{'nTamanho'    , 1},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'EMAIL_SECURE'},;
		{'cGroup'      , "EMA"},;
		{'lObrigat'    , .T.},;
		{'aComboValues', {STR0033,STR0034,STR0035} },;		// #'1=SSL'		#'2=TLS'		#'3=SSL+TLS'
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0036};		// #'Protocolos de segurança na conexão'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0037},;		//#'Ambiente'
		{'nTamanho'    , 4},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'AMBIENTE'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'aComboValues', {STR0038,STR0039} },;		//#'TEST=Teste'		#'PROD=Produção'
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0040};		//#'Ambiente de conexão Prim na CNH'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0041},;		//#'Gera Logs'
		{'nTamanho'    , 4},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'LOGS'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'aComboValues', {STR0042,STR0029} },;		// #'1=Sim'		#'0=Não'
		{'cPicture'    , '@X'},;
		{'cTooltip'    , STR0043};		//#'Maior detalhamento no log'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0062},;		//#'Grupo'
		{'nTamanho'    , FWTamSX3('BM_GRUPO')[1]},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'GRUPO'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'f3'          , "SBM"},;
		{'bValid'      , {|oMd3, cAttr, uValAnt| empty(oMd3:GetValue(cAttr)) .OR. ValidaGrupo(oMd3:GetValue(cAttr))}},;
		{'cPicture'    , '@!'},;
		{'cTooltip'    , STR0063};		//#'Código do grupo Protheus-SBM'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0106},;		//#'Cond. Pagamento'
		{'nTamanho'    , FWTamSX3('E4_CODIGO')[1]},;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'CONDPAGTO'},;
		{'cGroup'      , "ACC"},;
		{'lObrigat'    , .T.},;
		{'f3'          , "SE4"},;
		{'bValid'      , {|oMd3, cAttr, uValAnt| empty(oMd3:GetValue(cAttr)) .OR. ExistCpo("SE4",oMd3:GetValue(cAttr)) }},;
		{'cPicture'    , '@!'},;
		{'cTooltip'    , STR0107};			//#'Código da condição de pagamento Protheus-SE4'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0044     },;		//#'Cliente Recompra'
		{'nTamanho'    , FWTamSX3('A1_COD')[1] },;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'CODCLIRECOMP'},;
		{'cGroup'      , "ACC"},;
		{'lCanChange'  , .T.         },;
		{'lObrigat'    , .T.         },;
		{'f3'          , "SA1"       },;
		{'bValid'      , {|oMdl, cAttr, uValAnt| empty(oMdl:GetValue(cAttr)) .or. OA060005C_validCliente( oMdl:GetValue(cAttr), nil ) }},;
		{'cTooltip'    , STR0045} ;		//#'Código do cliente Protheus-SA1'
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0046     },;		//#'Loja Cli Recompra'
		{'nTamanho'    , FWTamSX3('A1_LOJA')[1] },;
		{'cFolder'     , 'GER'},;
		{'cIdField'    , 'LOJCLIRECOMP'},;
		{'cGroup'      , "ACC"},;
		{'lCanChange'  , .T.         },;
		{'lObrigat'    , .T.         },;
		{'bValid'      , {|oMdl, cAttr, uValAnt| empty(oMdl:GetValue(cAttr)) .or. OA060005C_validCliente( nil, oMdl:GetValue(cAttr) ) }},;
		{'cTooltip'    , STR0047} ;		//#'Loja do cliente Protheus-SA1'
	})
return oMd1


/*/{Protheus.doc} OA060001C_Load01Dados
Dados da entidade principal
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
static function OA060001C_Load01Dados()
Return {{;
	PadR(oCfgAtu['MOEDA']        , 3),;
	PadR(oCfgAtu['DIR_IN']       ,80),;
	PadR(oCfgAtu['DIR_OUT']      ,80),;
  	PadR(oCfgAtu['DIR_LIDOS']    ,80),;
	PadR(oCfgAtu['EMAIL_SERVER'] ,80),;
	PadR(oCfgAtu['EMAIL_USER']   ,80),;
	PadR(oCfgAtu['EMAIL_PASS']   ,80),;
	PadR(oCfgAtu['EMAIL_SENDER'] ,80),;
	PadR(oCfgAtu['EMAIL_OCORREN'],80),;
	PadR(oCfgAtu['EMAIL_AUTH']   , 1),;
	PadR(oCfgAtu['EMAIL_SECURE'] , 1),;
	PadR(oCfgAtu['AMBIENTE']     , 4),;
	PadR(oCfgAtu['LOGS']         , 1),;
	PadR(oCfgAtu['GRUPO']        , FWTamSX3('BM_GRUPO')[1]),;
	PadR(oCfgAtu['CONDPAGTO']    , FWTamSX3('E4_CODIGO')[1]),;
	PadR(oCfgAtu['CODCLIRECOMP'] , FWTamSX3('A1_COD')[1]) ,;
	PadR(oCfgAtu['LOJCLIRECOMP'] , FWTamSX3('A1_LOJA')[1]) ;
} , 0}


/*/{Protheus.doc} OA060002C_OnChange
Função utilizada para preencher os relacionamentos e campos virtuais no caso
a descrição do depósito
@type function
@author Vinicius Gati
@since 31/01/2018
/*/
Static Function OA060002C_OnChange(oMdl, nLin, cAction, cAttr, uValNovo, uValAnt)
local nLinAtu := oMdl:getLine()
local nI

	if cAttr == "FILIAL" .and. ! empty( cValtoChar(uValNovo) )
		for nI := 1 to oMdl:Length()
			oMdl:GoLine(nI)
			if ! oMdl:isDeleted() .and. nI != nLinAtu
				if alltrim(uValNovo) == alltrim( oMdl:GetValue("FILIAL") )
					oMdl:GoLine(nLinAtu)
					FMX_HELP("OFCNHA06", STR0048, STR0049)		//#"Filial em duplicidade"		#"Favor observar os demais registros"
					return .F.
				endif
			endif
		next
		oMdl:GoLine(nLinAtu)

		if ! FILCHKNEW( cEmpAnt , alltrim(uValNovo) )
			FMX_HELP("OFCNHA06", STR0050, STR0051)		//#"Filial não encontrada"		#"Favor verificar as filiais utilizando a consulta F3"
			return .F.
		endif
	endif

	if cAttr == "GRUPO" .and. ! empty( cValtoChar(uValNovo) )

		for nI := 1 to oMdl:Length()
			oMdl:GoLine(nI)
			if ! oMdl:isDeleted() .and. nI != nLinAtu
				if alltrim(uValNovo) == alltrim( oMdl:GetValue("GRUPO") )
					oMdl:GoLine(nLinAtu)
					FMX_HELP("OFCNHA06", STR0052, STR0053)		//#"Grupo de produto em duplicidade"		#"Favor observar os demais registros"
					return .F.
				endif
			endif
		next
		oMdl:GoLine(nLinAtu)

		dbSelectArea('SBM')
		dbSetOrder(1)
		if msSeek(xFilial('SBM') + cValtoChar(uValNovo))
			oMdl:SetValue('DESCRICAO', SBM->BM_DESC)
		else
			oMdl:SetValue('DESCRICAO', "")
		endif
	endif
return .T.


/*/{Protheus.doc} GetModel02
	Definição dos dados que serão configurados modelo 2
	
	@type function
	@author Vinicius Gati
	@since 31/01/2018
/*/
Static Function GetModel02()
Local oMd2 := OFDMSStruct():New()

	oMd2:AddSimple( STR0054, "C", 100,,"FILIAL",'SM0_01')	//#Filial
	oMd2:AddSimple( STR0055, "C", 100,,"USUARIO")			//#Usuário
	oMd2:AddSimple( STR0056, "C", 20 ,,"SENHA",,"")			//#Senha
	oMd2:AddField({;
		{'cTitulo'     , STR0057 },;		//#'DealerCode'
		{'nTamanho'    , 7        },;
		{'cIdField'    , 'DEALERCODE'},;
		{'cPicture'    , '@!'     },;
		{'lObrigat'    , .T.      },;
		{'bValid'      , {|oMdl, cAttr, uValAnt| ! Empty(oMdl:GetValue(cAttr)) }},;
		{'cTooltip'    , STR0057} ;		//#DealerCode
	})
	oMd2:AddField({;
		{'cTitulo'     , STR0058 },;		//#Mercado
		{'nTamanho'    , 4         },;
		{'cIdField'    , 'MERCADO' },;
		{'lObrigat'    , .T.       },;
		{'aComboValues', {STR0059, STR0060} },;		//#'BR11=Construção'	#'BR13=Agrícola'
		{'bValid'      , {|oMdl, cAttr, uValAnt| ! Empty(oMdl:GetValue(cAttr)) }},;
		{'cTooltip'    , STR0061} ;		//#'Código de mercado'
	})
return oMd2


/*/{Protheus.doc} GetModel03
Definição dos dados de depósitos que serão configurados
@type function
@author Vinicius Gati
@since 31/01/2018
/*/
Static Function GetModel03()
Local oMd3 := OFDMSStruct():New()

	oMd3:AddField({;
		{'cTitulo'     , STR0062     },;		//#'Grupo'
		{'nTamanho'    , FWTamSX3('BM_GRUPO')[1] },;
		{'cIdField'    , 'GRUPO'   },;
		{'lCanChange'  , .T.         },;
		{'lObrigat'    , .T.         },;
		{'f3'          , "SBM"       },;
		{'bValid'      , {|oMdl, cAttr, uValAnt| empty(oMdl:GetValue(cAttr)) .or. existCpo("SBM",oMdl:GetValue(cAttr))}},;
		{'cTooltip'    , STR0063} ;		//#'Código do grupo Protheus-SBM'
	})
	oMd3:AddField({;
		{'cTitulo'     , STR0064 },;		//#'Descrição'
		{'cIdField'    , 'DESCRICAO'   },;
		{'lCanChange'  , .F.         },;
		{'cTooltip'    , STR0065} ;		//#'Descrição do grupo'
	})
	oMd3:AddField({;
		{'cTitulo'     , STR0066 },;		//#'Warehouse'
		{'nTamanho'    , 3           },;
		{'cIdField'    , 'WAREHOUSE'   },;
		{'lCanChange'  , .T.         },;
		{'aComboValues', {STR0067, STR0068, STR0069} },;		//#'F01=Gerenciado'		#'D01=Não gerenciado'	#'N01=Direct Shipment'
		{'cTooltip'    , STR0070} ;		//#'Depósito concessionário'
	})
return oMd3


/*/{Protheus.doc} Load02Dados
	Traz os dados de filiais configuradas atualmente para o PRIM
	
	@type function
	@author Vinicius Gati
	@since 31/01/2018
/*/
Static Function Load02Dados()
local oSenhas := oCfgAtu["SENHAS"]

	if empty( oSenhas )
		return { { 0, {;
			space(len(cFilAnt)),;
			space(20),;
			space(20),;
			space( 7),;
			space( 4);
			} } }
	endif

return oArHlp:Map( oSenhas, {|oEl| {0, {;
	PADR(oEl["FILIAL"]          , len(cFilAnt) ),;
	PADR(oEl["USUARIO"]         , 20 ),;
	PADR(oEl["SENHA"]           , 20 ),;
	PADR(oEl["DEALERCODE"]      ,  7 ),;
	PADR(oEl["MERCADO"]         ,  4 ) ;
}}})


/*/{Protheus.doc} Load03Dados
Traz os dados de depósitos configurados para envio ao PRIM
@type function
@author Vinicius Gati
@since 31/01/2018
/*/
Static Function Load03Dados()
local oLocais := oCfgAtu["LOCAIS"]

	if empty( oLocais )
		return { { 0, {;
			space( FWTamSX3('BM_GRUPO')[1] ),;
			space( FWTamSX3('BM_DESC' )[1] ),;
			space( 3);
			} } }
	endif

return oArHlp:Map( oCfgAtu["LOCAIS"], {|oEl| {0, {;
	PADR(oEl["GRUPO"]    , FWTamSX3('BM_GRUPO')[1]),;
	PADR(oEl["DESCRICAO"], FWTamSX3('BM_DESC' )[1]),;
	PADR(oEl["WAREHOUSE"], 3) ;
}}})


/*/{Protheus.doc} tstConn
Teste de conexão com API da CNH
@type function
@author Cristiam Rossi
@since 06/02/2025
/*/
static function tstConn( oDlg )
local   oPrim        := OFCNHPrimWsConnect():new()
local   oModel       := FWModelActive()
local   oSenhas      := oModel:GetModel("SENHAS")
local   oMaster      := oModel:GetModel("MASTER")
local   lConnect     := .F.
local   cErro        := STR0071		//#"Erro indeterminado"
local   cMsg         := STR0072		//#"Sucesso na conexão com API"
local   cFilSel      := ""
local   cUser        := ""
local   cPass        := ""
local   cEnvironment := allTrim(oMaster:GetValue("AMBIENTE"))
private cMsgLog      := ""
private lDebug       := alltrim(oMaster:GetValue("LOGS")) == "1"

	if oSenhas:Length() > 0 .and. ! oSenhas:IsDeleted()
		cFilSel := alltrim( oSenhas:GetValue('FILIAL') )
		cUser   := alltrim( oSenhas:GetValue('USUARIO') )
		cPass   := alltrim( oSenhas:GetValue('SENHA') )
	endif

	if lDebug
		cMsgLog += "--------------------" + CRLF
		cMsgLog += "    "+STR0073 + CRLF			// #Credenciais
		cMsgLog += "--------------------" + CRLF
		cMsgLog += STR0074 + cEnvironment + CRLF		//#"Ambiente: "
		cMsgLog += STR0075 + cFilSel + CRLF		//#"Filial: "
		cMsgLog += STR0076 + cUser + CRLF		//#"User: "
		cMsgLog += STR0077 + cPass + CRLF + CRLF		//#"Pass: "
	endif

	if empty( cUser )
		msgStop( STR0078, STR0079 )		//#"Favor cadastrar o usuário e senha desta filial"		#"Teste de conexão com API"
		return .F.
	endif

	oDlg:cCaption := STR0074 + cEnvironment + STR0080 + cFilSel		//#"ambiente: "		#" - contatando filial: "

	oPrim:setUser( cUser, cPass )
	oPrim:setEnvironment( cEnvironment )

	lConnect := oPrim:Connect()

	if ! lConnect
		cErro := iif( oPrim:cCodeRet == "-1", STR0081, iif( oPrim:cCodeRet == "-2", STR0082, STR0086+oPrim:cCodeRet) )		//#"Usuário bloqueado, contatar responsável na CNH"		#"Senha expirada, favor trocar"		#" - code: "
		cMsg := STR0083 +CRLF+ STR0084 + CRLF + cErro		//#Retorno:		#"Falha na conexão com API: "
	endif

	msgInfo( cMsg, STR0085 )		//#"Teste de conexão com API"
	cMsg := cMsgLog + cMsg

	OA060004C_log( "PRIM" /*cAgroup*/, STR0087 /*cTipo*/, cMsg /*cDados*/, .t. )	//#"TESTE CONEXÃO"
return nil


/*/{Protheus.doc} criaArvore
criação da arvore de diretórios em Protheus_Data
@type function
@author Cristiam Rossi
@since 06/02/2025
/*/
static function criaArvore( cDealerCode, cPath )
local nI
local aAux
local cAux
local cFullPath := ""
local cRetorno

	cRetorno := strTran( cPath, "\", "/" )
	if left(cRetorno,1) != "/"
		cRetorno := "/" + cRetorno
	endif
	if right(cRetorno,1) != "/"
		cRetorno := cRetorno + "/"
	endif

	cAux := lower( "/CNH/" + cDealerCode + cRetorno )

	aAux := strTokArr2( cAux, "/" )

	for nI := 1 to len( aAux )
		if ! empty( aAux )
			cFullPath += "/" + aAux[nI]
			makeDir( cFullPath )
		endif
	next
return lower( cRetorno )


/*/{Protheus.doc} chkDir
valida diretorio
@type function
@author Cristiam Rossi
@since 06/02/2025
/*/
static function chkDir( cPath )
local cAux := strTran( cPath, "\", "/" )

	if AT( "//", cAux ) > 0 .or. AT( ":", cAux ) > 0
		FMX_HELP("OFCNHA06", STR0093, STR0094)		//#"Pasta inválida, não informar : ou //"		#"Verifique a pasta informada"
		return .F.
	endif

return .T.


/*/{Protheus.doc} OA060003C_sendMail
rotina de sendMail
@type function
@author Cristiam Rossi
@since 07/02/2025
/*/
function OA060003C_sendMail( cAssunto, cCorpo, oModel )
local   oMaster
local   oConfig
local   oCfgAtu
local   oServer   := tMailManager():New()
local   oMessage
local   nErr      := 0
local   nPos
local   cSMTPAddr
local   nSMTPPort := 465
local   cUser
local   cPass
local   nSMTPTime := 60
local   cFrom
local   cTo
local   cAmbiente
local   lAuth     := .F.
local   lSSL      := .F.
local   lTLS      := .F.
default oModel    := FWModelActive()

	if valtype( oModel ) == "U" .or. oModel:cID != "OFCNHA06"
		oConfig := OFCNHPrimConfig():New()
		oCfgAtu := oConfig:GetConfig()
		cSMTPAddr := oCfgAtu["EMAIL_SERVER"]
		cUser     := oCfgAtu["EMAIL_USER"]
		cPass     := oCfgAtu["EMAIL_PASS"]
		cFrom     := oCfgAtu["EMAIL_SENDER"]
		cTo       := oCfgAtu["EMAIL_OCORREN"]
		cAmbiente := oCfgAtu["AMBIENTE"]
		lAuth     := oCfgAtu["EMAIL_AUTH"] == "1"
		lSSL      := oCfgAtu["EMAIL_SECURE"] $ "1;3"
		lTLS      := oCfgAtu["EMAIL_SECURE"] $ "2;3"
	else
		oMaster   := oModel:GetModel("MASTER")
		cSMTPAddr := AllTrim(oMaster:GetValue("EMAIL_SERVER"))
		cUser     := AllTrim(oMaster:GetValue("EMAIL_USER"))
		cPass     := AllTrim(oMaster:GetValue("EMAIL_PASS"))
		cFrom     := AllTrim(oMaster:GetValue("EMAIL_SENDER"))
		cTo       := AllTrim(oMaster:GetValue("EMAIL_OCORREN"))
		cAmbiente := AllTrim(oMaster:GetValue("AMBIENTE"))
		lAuth     := AllTrim(oMaster:GetValue("EMAIL_AUTH")) == "1"
		lSSL      := AllTrim(oMaster:GetValue("EMAIL_SECURE")) $ "1;3"
		lTLS      := AllTrim(oMaster:GetValue("EMAIL_SECURE")) $ "2;3"
	endif

	if ( nPos := AT( ":", cSMTPAddr ) ) > 0
		nSMTPPort := val( subStr( cSMTPAddr, nPos+1 ) )
		cSMTPAddr := left( cSMTPAddr, nPos-1)
	endif

	oServer:setUseSSL( lSSL )
	oServer:setUseTLS( lTLS )
	oServer:init( "", cSMTPAddr, cUser, cPass, 0, nSMTPPort )

	oServer:SetSMTPTimeout(nSMTPTime)

	if ( nErr := oServer:smtpConnect() ) != 0
		msgInfo(STR0096 + oServer:getErrorString(nErr))		//#"[ERROR]Falha ao conectar: "
		oServer:smtpDisconnect()
		return .F.
	endif

	if lAuth .and. ( nErr := oServer:smtpAuth(cUser, cPass) ) != 0
		MsgInfo(STR0097 + oServer:getErrorString(nErr))		//#"[ERROR]Falha ao autenticar: "
		oServer:smtpDisconnect()
		return .F.
	endif

	oMessage := tMailMessage():new()
	oMessage:clear()
	oMessage:cFrom    := cFrom
	oMessage:cTo      := cTo
	oMessage:cSubject := "["+cAmbiente+"]"+cAssunto
	oMessage:cBody    := "<pre>" + strTran( cCorpo, CRLF, "<br />" ) + "</pre>"
	oMessage:MsgBodyType( "text/html" )

	if ( nErr := oMessage:send(oServer) ) <> 0
		MsgInfo(STR0098 + oServer:getErrorString(nErr))		//#"[ERROR]Falha ao enviar: "
		oServer:smtpDisconnect()
		return .F.
//	Else
//		MsgInfo("Mensagem Enviada com Sucesso!!!")
	EndIf

	oServer:smtpDisconnect()
return .T.


/*/{Protheus.doc} OA060004C_log
rotina de registro de logs
@type function
@author Cristiam Rossi
@since 07/02/2025
/*/
function OA060004C_log( cAgroup, cTipo, cDados, lSendMail )
local   oLogger  := DMS_Logger():New()
default cAgroup  := "PRIM"
default cTipo    := "OFCNHA06"
default cDados   := ""
default lSendMail := .F.

	oLogger:LogToTable({;
		{'VQL_AGROUP', cAgroup },;
		{'VQL_TIPO'  , cTipo   },;
		{'VQL_MSGLOG', cDados  } ;
	})
	FWFreeObj(oLogger)

	if lSendMail
		lRet := OA060003C_sendMail( cTipo /*cAssunto*/, cDados /*cCorpo*/ )
	endif
return nil


/*/{Protheus.doc} OA060005C_validCliente
rotina de registro de logs
@type function
@author Cristiam Rossi
@since 07/02/2025
/*/
function OA060005C_validCliente( cCodCli, cLojCli )
local   oModel     := FWModelActive()
local   oMaster    := oModel:GetModel("MASTER")
default cCodCli    := AllTrim(oMaster:GetValue("CODCLIRECOMP"))
default cLojCli    := AllTrim(oMaster:GetValue("LOJCLIRECOMP"))

	cCodCli := padR( cCodCli, len(SA1->A1_COD) )
	if ! empty( cLojCli )
		cLojCli := padR( cLojCli, len(SA1->A1_LOJA) )
	endif

	SA1->( dbSetOrder(1) )
	if SA1->( dbSeek( xFilial("SA1") + cCodCli + cLojCli ) )
		return .T.
	endif

	FMX_HELP("OA060005C_validCliente", STR0099, STR0100)		//#"Cliente recompra não encontrado"	#"Favor utilize a consulta F3"
return .F.


/*/{Protheus.doc} OA060006C_prettyXML
Função que serve para quebrar um XML e deixá-lo indentado para o usuário
@author CristiamRossi apoiado no fonte do Atilio
@since 28/03/2025
@version 1.0
@type function
@param cTextoOrig, characters, descricao
@return character, texto identado
/*/
Function OA060006C_prettyXML(cTextoOrig)
Local cTextoNovo := ""
Local aLinhas    := {}
Local cEspaco    := ""
Local nAbriu     := 0
Local nAtual     := 0
Local aLinNov    := {}

    If ! Empty(cTextoOrig) //.And. '<?xml version=' $ cTextoOrig
        cTextoNovo := StrTran(cTextoOrig, "</",                "zPrettyXML_QUEBR")
        cTextoNovo := StrTran(cTextoNovo, "<",                 CRLF + "<")
        cTextoNovo := StrTran(cTextoNovo, ">",                 ">" + CRLF)
        cTextoNovo := StrTran(cTextoNovo, "zPrettyXML_QUEBR",  CRLF + "</")

        aLinhas := StrTokArr(cTextoNovo, CRLF)

        For nAtual := 1 To Len(aLinhas)
			If "<" $ aLinhas[nAtual] .And. ! "<?" $ aLinhas[nAtual] .And. ! "</" $ aLinhas[nAtual] .And. ! "/>" $ aLinhas[nAtual]
				nAbriu += 1
			EndIf

			cEspaco := ""
			If nAbriu > 0
				cEspaco := Replicate(' ', 2 * (nAbriu + Iif(! "<" $ aLinhas[nAtual], 1, 0)) )
			EndIf

			aAdd(aLinNov, cEspaco + aLinhas[nAtual])

			If "</" $ aLinhas[nAtual] .And. At('<', SubStr(aLinhas[nAtual], 2, Len(aLinhas[nAtual]))) == 0
				nAbriu -= 1
			EndIf
        Next

        cTextoNovo := ""
        For nAtual := 1 TO Len(aLinNov)
            cTextoNovo += aLinNov[nAtual] + CRLF
        Next
    EndIf

Return cTextoNovo


/*/{Protheus.doc} OFCNHA06EVDEF
Classe de validação dos Grid do model Config
@author CristiamRossi
@since 09/04/2025
@version 1.0
@type class
@return object, classe instanciada
/*/
CLASS OFCNHA06EVDEF FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
ENDCLASS


/*/{Protheus.doc} New
Método de instanciação - construtor
@author CristiamRossi
@since 09/04/2025
@version 1.0
@type method
@return logical, sempre .T.
/*/
METHOD New() CLASS OFCNHA06EVDEF
RETURN .T.


/*/{Protheus.doc} GridLinePreVld
Método para validação das grids
@author CristiamRossi
@since 09/04/2025
@version 1.0
@type function
@return logical, se confirma ou não a ação no Grid
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFCNHA06EVDEF
//local oView := FWViewActive()
local lRet  := .T.
local nI
local cCpoChave := iif( cModelID == "LOCAIS", "GRUPO", "FILIAL" )
local cValue    := oSubModel:getValue( cCpoChave )
local nPos

	if cAction == "UNDELETE"
		nPos := oSubModel:GetLine()
		for nI := 1 to oSubModel:Length()
			oSubModel:GoLine(nI)
			if ! oSubModel:IsDeleted() .and. nI != nLine
				if alltrim( oSubModel:getValue( cCpoChave ) ) == alltrim( cValue )
					FMX_HELP("OFCNHA06-"+cCpoChave, STR0101, STR0102)	//#"Chave existente, não poderá ser reativado"	#"Observe que existe outro registro ativo com a mesma chave"
					lRet := .F.
				endif
			endif
		next
		oSubModel:GoLine(nPos)
	endif

return lRet

/*/{Protheus.doc} ValidaGrupo
Função utilizada para validar que o grupo da guia principal deve estar contigo entre os
grupos de armazens
@type function
@author Rodrigo
@since 06/2025
/*/
function ValidaGrupo(cGrupo As Char) As Logical
	Local oModel    := FWModelActive() As Object
	Local oLocais	:= oModel:GetModel('LOCAIS') As Object

	Local nLinAtu	:= oLocais:GetLine() As Numeric
	Local nI 		:= 0 As Numeric

	Local lRet		:= .F. As Logical

	For nI := 1 To oLocais:Length()
		oLocais:GoLine(nI)
		IF !oLocais:isDeleted()
			IF Alltrim(cGrupo) == Alltrim(oLocais:GetValue('GRUPO'))
				lRet := .T.
				Exit
			Endif
		Endif
	Next

	oLocais:GoLine(nLinAtu)

	IF !lRet
		FMX_HELP('ValidaGrupo', STR0104, STR0105) //# Grupo Inválido # Favor utilizar o grupo relacionado aos locais de estoque
	EndIF
Return lRet
