#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA985.CH'

Static __lTemClas As Logical

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA985 
Cadastro dos complementos dos impostos - tabela FKE

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FINA985()
	Local oBrowse As Object

	//inicializa as variaveis estaticas.
	F985IniVar()
	
	DBSelectArea("FKE")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FKE')
	oBrowse:SetDescription(STR0001) //'Complemento do imposto'
	oBrowse:Activate()
	
	FWFreeObj(oBrowse)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef 
Definição de menu da rotina de cadastro dos complementos dos impostos

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FINA985' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FINA985' OPERATION 3 ACCESS 0 //'Incluir' 
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FINA985' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FINA985' OPERATION 5 ACCESS 0 //'Excluir' 
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FINA985' OPERATION 8 ACCESS 0 //'Imprimir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef 
Definição do modelo de dados da rotina de cadastro dos complementos 
dos impostos

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oStruFKE As Object
	Local oModel As Object

	//inicializa as variaveis estaticas.
	F985IniVar()

	oStruFKE := FWFormStruct( 1, 'FKE', /*bAvalCampo*/,/*lViewUsado*/ )
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('FKEMODEL', /*bPreValidacao*/, {||F985VldGrv(oModel)}, /*bCommit*/, /*bCancel*/ )

	//Bloqueia a edição do campo de Tipo de Imposto quando o dicionario não estiver atualizado (mantem o legado)
	oStruFKE:SetProperty( "FKE_TPIMP", MODEL_FIELD_WHEN, {|| __lTemClas } )
		
	//Validação para selecão da carteira (1=Pagar/2=Receber/3=Ambos)
	oStruFKE:SetProperty("FKE_CARTEI", MODEL_FIELD_VALID, {||( F985VldCpo(oModel, "FKE_CARTEI") )})

	//Valida o campo Ação (1=Subtração/2=Adição/3=Informativo)
    oStruFKE:SetProperty("FKE_DEDACR", MODEL_FIELD_VALID, {||( F985VldCpo(oModel, "FKE_DEDACR") )})
	
	If __lTemClas //Proteção de dicionário - REINF 2.1.1
		//Bloqueia a edicao do campo FKE_CLASSI quando o imposto nao for IR
		oStruFKE:SetProperty( "FKE_CLASSI", MODEL_FIELD_WHEN, {|oModel| Alltrim( M->FKE_TPIMP ) == "IRF" } )
		//Inicializa o preenchimento do FKE_CLASSI quando o imposto for IR
		oStruFKE:AddTrigger( "FKE_TPIMP", "FKE_CLASSI" , { || .T. }, {|oModel| F985Trigger("FKE_TPIMP", "FKE_CLASSI") } )
		//Limpa o campo 'Tipo Ação' e sua descrição quando alterar a classificacao do IR (FKE_CLASSI)
		oStruFKE:AddTrigger( "FKE_CLASSI", "FKE_TPATRB" , { || .T. }, {|oModel| "" } )
		oStruFKE:AddTrigger( "FKE_CLASSI", "FKE_DESATR" , { || .T. }, {|oModel| "" } )	
		oStruFKE:AddTrigger( "FKE_CARTEI", "FKE_CLASSI" , { || .T. }, {|oModel| F985Trigger("FKE_CARTEI", "FKE_CLASSI", oModel) } )	
		oStruFKE:AddTrigger( "FKE_CARTEI", "FKE_TPATRB" , { || .T. }, {|oModel| F985Trigger("FKE_CARTEI", "FKE_TPATRB", oModel) } )			
	Else
		//Inicializador padrão a ser executado quando o dicionario não estiver atualizado (mantem o legado)
		oStruFKE:SetProperty( "FKE_TPIMP", MODEL_FIELD_INIT,{||'INSS'} )
	EndIf

	//Preenchimento automatico do campo Aplicação = 'Base' quando o imposto for IR ou PCC
	oStruFKE:AddTrigger( "FKE_TPIMP", "FKE_APLICA" , { || .T. }, {|oModel| F985Trigger("FKE_TPIMP", "FKE_APLICA") } )

	//Preenchimento automatico do campo Calcula = 'Valor' quando o imposto for IR ou PCC
	oStruFKE:AddTrigger( "FKE_TPIMP", "FKE_CALCUL" , { || .T. }, {|oModel| F985Trigger("FKE_TPIMP", "FKE_CALCUL") } )

	//Bloqueia a edição do campo APLICACAO quando o impsoto for IR/PCC (ref. REINF bloco 40). Será preenchido pelo gatilho acima
	oStruFKE:SetProperty( 'FKE_APLICA' , MODEL_FIELD_WHEN, {|| Alltrim( M->FKE_TPIMP ) == "INSS" })
	
	//Bloqueia a edição do campo CALCULA quando o impsoto for IR/PCC (ref. REINF bloco 40). Será preenchido pelo gatilho acima
	oStruFKE:SetProperty( 'FKE_CALCUL' , MODEL_FIELD_WHEN, {|| Alltrim( M->FKE_TPIMP ) == "INSS" })
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'FKEMASTER', /*cOwner*/, oStruFKE, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	oModel:SetActivate ()
	
	oModel:SetPrimaryKey( { "FKE_FILIAL", "FKE_IDFKE" } )
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0007 ) //'Cadastro de Complemento do Imposto'
	
	oModel:GetModel( 'FKEMASTER' ):SetDescription(STR0001) //"Complemento do Imposto"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef 
Definição da view da rotina de cadastro dos complementos 
dos impostos

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oStruFKE As Object
	Local oView As Object
	
	oModel := FWLoadModel( 'FINA985' )
	oStruFKE := FWFormStruct( 2, 'FKE' )
	
	oStruFKE:SetProperty( 'FKE_IDFKE'  , MVC_VIEW_ORDEM, '02' )
	oStruFKE:SetProperty( 'FKE_DESCR'  , MVC_VIEW_ORDEM, '03' )
	oStruFKE:SetProperty( 'FKE_TPIMP'  , MVC_VIEW_ORDEM, '04' )

	If __lTemClas //Proteção de dicionário - REINF 2.1.1
		oStruFKE:SetProperty( 'FKE_CLASSI'  , MVC_VIEW_ORDEM, '05' )
	Endif

	oStruFKE:SetProperty( 'FKE_DEDACR' , MVC_VIEW_ORDEM, '06' )
	oStruFKE:SetProperty( 'FKE_APLICA' , MVC_VIEW_ORDEM, '07' )
	oStruFKE:SetProperty( 'FKE_CARTEI' , MVC_VIEW_ORDEM, '08' )
	oStruFKE:SetProperty( 'FKE_CALCUL' , MVC_VIEW_ORDEM, '09' )
	oStruFKE:SetProperty( 'FKE_PERCEN' , MVC_VIEW_ORDEM, '10' )
	oStruFKE:SetProperty( 'FKE_TPATRB' , MVC_VIEW_ORDEM, '11' )
	oStruFKE:SetProperty( 'FKE_DESATR' , MVC_VIEW_ORDEM, '12' )
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_FKE', oStruFKE, 'FKEMASTER' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F985VldATRB 
Função que valida o FKE_TPATRB para usar apenas os tipos
que podem ser por base ou por valor

@return lRet

@author Pâmela Bernardo
@since 15/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F985VldATRB() As Logical
	Local lRet As Logical 
	Local cFiltro As Char
	
	lRet := .T.
	cFiltro := F985FilImp()

	If !(M->FKE_TPATRB $ cFiltro)
		lRet := .F.
		Help(" ",1,"TPACAOINVAL")
	Endif	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F985FilImp 
Filtro da consulta SXB 0D do campo FKE_TPATRB para trazer somente os tipos
que podem ser por base ou por valor

@return cFiltro, retorna os códigos a serem exibidos no campo FKE_TPATRB

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F985FilImp() As Char
	Local cFiltro As Char
	
	cFiltro := ""
	If Alltrim(M->FKE_TPIMP) == "INSS"
		If M->FKE_APLICA == "1" // BASE
			cFiltro := "001   |002   |003   |006   "
		Else
			cFiltro := "004   |005   |006   |007   |008   |009   "
		EndIf
	ElseIf Alltrim(M->FKE_TPIMP) == "IRF"
		If __lTemClas //Proteção de dicionário - REINF 2.1.1
			If M->FKE_CARTEI == "1"
				If M->FKE_CLASSI == "2" //Dedução
					cFiltro := "010   |011   |012   |013   |024   "
				Elseif M->FKE_CLASSI == "3" //Suspensão 
					cFiltro := "004   "	
				Else
					//Isenção
					cFiltro := "006   |015   |016   |017   |018   |019   |020   |021   |022   |023   |025   |026   |027   "
					If Empty(M->FKE_CLASSI)
						cFiltro	+= "|028   " // Dedução do IR Aluguel
					EndIf
				EndIf
			Else
				cFiltro := "004   "	 //Suspensão 
			Endif
		Else
			cFiltro := "013   |" //legado
		Endif
	ElseIf Alltrim(M->FKE_TPIMP) $ "PIS|COF|CSL"
		cFiltro := "004   "
	Else
		cFiltro := "001   |002   |003   |004   |005   |006   |007   |008   |009   "
	EndIf
		
	If Existblock("FA985TPA",)
		cFiltro += ExecBlock("FA985TPA",.F.,.F.)
	EndIf
Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} F985Fil0C 
Função que determina quais opções serão apresentadas na consulta do campo FKE_TPIMP
*Utilizado na consulta padrão (SXB) "SX50C"

@return cRet, opções válidas para o campo FKE_TPIMP

@author Fabio Casagrande Lima
@since 01/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Function F985Fil0C() As Char
	Local cRet As Char	
	cRet := "INSS  |IRF   |PIS   |COF   |CSL   |"
Return cRet

//-------------------------------------------------------------------
/*/
{Protheus.doc} F985Trigger
Gatilho dos campos da rotina.

@param1	cCpoOri - Campo de origem do gatilho
@param2	cCpoDes - Campo de destino do gatilho

@return	cRet - Retorna o conteudo do campo destino

@author Fabio Casagrande Lima
@since 10/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------

Function F985Trigger(cCpoOri As Character, cCpoDes As Character, oModel As Object) As Character

	Local cRet 		As Character
	Local cTpImp	As Character
	Local cCart 	As Character
	Local oSubMod	As Object
	Local lModel	As Logical

	Default cCpoOri := ""
	Default cCpoDes := ""
	Default	oModel	:= FWModelActive()

	lModel	:= .F.
	
	If "FKEMODEL" $ oModel:cID
		oSubMod	:= oModel:GetModel("FKEMASTER")
	ElseIf "FKEMASTER" $ oModel:cID
		oSubMod	:= oModel
	EndIf

	lModel	:= ( ValType(oSubMod) == 'O' )

	If !Empty(cCpoDes) .And. lModel
		cRet	:= oSubMod:GetValue(cCpoDes)
		cTpImp	:= AllTrim(oSubMod:GetValue("FKE_TPIMP"))
		cCart	:= AllTrim(oSubMod:GetValue("FKE_CARTEI"))
	Else
		cRet	:= M->&cCpoDes
		cTpImp	:= AllTrim(M->FKE_TPIMP)
		cCart	:= AllTrim(M->FKE_CARTEI)
	EndIf
	
	If cCpoOri == 'FKE_TPIMP'
		If cCpoDes == "FKE_CLASSI"
			If cTpImp == "IRF"
				cRet := "1"
			EndIf
		ElseIf cCpoDes == "FKE_APLICA"
			If cTpImp <> "INSS"
				cRet := "1"
			EndIf
		ElseIf cCpoDes == "FKE_CALCUL"
			If cTpImp <> "INSS"
				cRet := "1"
			EndIf
		EndIf
	ElseIf cCpoOri == 'FKE_CARTEI'
		If cCpoDes == "FKE_CLASSI"
			If cTpImp == "IRF" .and. cCart == "2"
				cRet := "3"
			EndIf
		ElseIf cCpoDes == "FKE_TPATRB"
			If cTpImp == "IRF" .and. cCart == "2"
				cRet := "004"
			EndIf
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F985VldTp 
Função que valida o FKE_TPIMP para usar apenas os tipos
de impostos validos na consulta padrão "SX50C"

@return lRet

@author Fabio Casagrande Lima
@since 18/02/2018
@version P11
/*/
//-------------------------------------------------------------------
Function F985VldTp() As Logical
	Local lRet As Logical
	Local cFiltro As Char
	
	lRet := .T.
	cFiltro := F985Fil0C()
	
	If Alltrim(M->FKE_CARTEI) == "1" .Or. Empty(M->FKE_CARTEI) //Pagar
		If !M->FKE_TPIMP $ cFiltro
			lRet := .F.
			HELP(' ',1,"FA985CARTP",,STR0010,2,0,,,,,,{STR0009}) //"O tipo de imposto selecionado não está habilitado para a carteira a pagar." ## "Revise a carteira ou o tipo de imposto selecionado." 
		Endif
	Else
		If ALLTRIM(M->FKE_TPIMP) <> "INSS"
			lRet := .F.
			HELP(' ',1,"FA985CARTR" ,,STR0008,2,0,,,,,, {STR0009})	//"O tipo de imposto selecionado não está habilitado para a carteira a receber." ## "Revise a carteira ou o tipo de imposto selecionado."
		Endif
		
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F985IniVar
Inicializa as vari veis staticas

@author Fabio Casagrande Lima
@since 24/04/2019
/*/
//-------------------------------------------------------------------
Static Function F985IniVar() 

	If __lTemClas == NIL
		__lTemClas := FKE->(ColumnPos("FKE_CLASSI")) > 0  //Proteção de dicionário - REINF 2.1.1
	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} F985VldCpo
Valida preenchimento do campo passado por parâmetro

@param1	oModel - Modelo de Dados
@param2	cCampo - Campo a ser validado

@return	lRet - Indica se O conteudo do campo é valido

@author	Fabio Casagrande Lima
@since	10/10/2022
/*/
//-------------------------------------------------------------------
Static Function F985VldCpo(oModel As Object, cCampo As Character) As Logical

	Local lRet    As Logical
	Local cGetCpo As Character
	Local cClass  As Character
	Local cTpImp  As Character

	Default oModel	:= FWModelActive()
	Default cCampo	:= ""

	cClass := ""
	cTpImp := ""

 	lRet    := .T.
	cGetCpo := oModel:GetValue('FKEMASTER', cCampo) 

	If !Empty(cGetCpo)
		If cCampo == "FKE_DEDACR"
			If oModel:GetValue('FKEMASTER', "FKE_TPIMP") <> "INSS" .and. cGetCpo == "2"
				lRet := .F.
				//"A ação ADIÇÃO não é permitida para o imposto selecionado." ## "Revise a ação ou o tipo de imposto selecionado."
				HELP(' ',1,"F985VlAcao" ,,STR0012,2,0,,,,,, {STR0011})
			Endif
		ElseIf cCampo == "FKE_CARTEI"
			cTpImp := Alltrim(oModel:GetValue('FKEMASTER', "FKE_TPIMP"))
			If __lTemClas
				cClass := Alltrim(oModel:GetValue('FKEMASTER', "FKE_CLASSI"))
			EndIf
			
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F985VldGrv 
Função que valida o conteúdo do campo FKE_DEDACR.

Para situação onde ocorrer a combinação abaixo:

Tipo = IRF, Classif. IR = Dedução, Ação = Subtração, Carteira = Pagar, Tipo Ação = Dependente

O sistema deverá impedir a inclusão/alteração do cadastro, visto que para esta situação o conteúdo
do campo Ação deve ser "Informativo".

@return lRet

@author Douglas de Oliveira 
@since 24/10/2022
@version P12
/*/
//-------------------------------------------------------------------
Function F985VldGrv(oModel As Object) As Logical
	
	Local lRet    As Logical
	Local cTpImp  As Character	
	Local cTpatr  As Character	
	Local cDedac  As Character
	
	Default oModel	:= FWModelActive()
			
	lRet := .T.
	cTpImp := Alltrim(oModel:GetValue('FKEMASTER', "FKE_TPIMP"))
	cTpatr := Alltrim(oModel:GetValue('FKEMASTER', "FKE_TPATRB"))
	cDedac := Alltrim(oModel:GetValue('FKEMASTER', "FKE_DEDACR"))
	
	If !Empty(cTpImp)
		If cTpImp == "IRF" .and. cTpatr == "024" .and. cDedac <> '3'
			lRet := .F.
			HELP(' ',1,"F985VldGrv",,STR0013,2,0,,,,,,{STR0014}) //"No campo Ação foi selecionada uma opção que não pode ser utilizada com o Tipo de Ação Dependentes." ## "No campo Ação utilize a opção Informativo." 			
		Endif
	Endif

Return lRet
