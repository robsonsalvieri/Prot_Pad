#include "GTPC300O.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
	MVC - KM Viagens
*/

Function GTPC300O()

	Local aButtons      := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"
	FWExecView( STR0001, 'VIEWDEF.GTPC300O', MODEL_OPERATION_INSERT, , { || .T. },{ || FWMsgRun(/*oComponent*/, { || G300OSave()  }, STR0007, STR0009 ) },,aButtons,{|| GC300OFech()} )//"Ajustar KM Realizado"#"Consulta"
 
Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Definição do Modelo do MVC

@return: 
	oModel:	Object. Objeto da classe MPFormModel

@sample: oModel := ModelDef()

@author GTP

@since 29/04/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStrCab	:= FWFormStruct(1,"GYN")
Local oStrGrd	:= FWFormStruct(1,"GYN")

Local aRelation	:= {}

GC300OSetStruct(@oStrCab, @oStrGrd, .T.)

oModel := MPFormModel():New("GTPC300O")

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("GYNMASTER", , oStrCab)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("GYNDETAIL", "GYNMASTER", oStrGrd, , , , , /*{|oMdl| G300ESetTable(oMdl)}*/)

aRelation	:= {{"GYN_FILIAL","xFilial('GYN')"},;
				{"GYN_CODIGO","GYN_CODIGO"}}

oModel:SetRelation("GYNDETAIL", aRelation, GYN->(IndexKey(1)))


oModel:SetDescription(STR0002)//"KM Viagens"


oModel:GetModel("GYNMASTER"):SetDescription(STR0003)//"Filtro"
oModel:GetModel("GYNDETAIL"):SetDescription(STR0004)//"Viagens"

//Somente Leitura
oModel:GetModel("GYNMASTER"):SetOnlyQuery(.t.)
oModel:GetModel("GYNDETAIL"):SetOnlyQuery(.t.)

//Opcional
oModel:GetModel("GYNDETAIL"):SetOptional(.t.)

//Bloqueia inserção e exclusão de linhas
oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

Return(oModel)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef

Definição da View do MVC

@return: 
	oView:	Object. Objeto da classe FWFormView

@sample: oView := ViewDef()

@author GTP

@since 29/04/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef()
Local oView		:= Nil
Local oStrCab	:= FWFormStruct(2,"GYN")
Local oStrGrd	:= FWFormStruct(2,"GYN")

GC300OSetStruct(@oStrCab, @oStrGrd, .F.)

oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VW_GYNMASTER', oStrCab, 'GYNMASTER')
oView:AddGrid('VW_GYNDETAIL', oStrGrd, 'GYNDETAIL')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('CABEC', 30)
oView:CreateHorizontalBox('CORPO', 70)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VW_GYNMASTER', 'CABEC')
oView:SetOwnerView('VW_GYNDETAIL', 'CORPO')

//habilita o filtro e a pesquisa
oView:SetViewProperty("GYNDETAIL", "GRIDSEEK"	, {.T.})
oView:SetViewProperty("GYNDETAIL", "GRIDFILTER"	, {.T.})


//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView('VW_GYNMASTER')
oView:EnableTitleView('VW_GYNDETAIL')
		
//Adiciona Botoes (Items em Acoes Relacionadas)
oView:AddUserButton(STR0005,"",{|oView| FWMsgRun(/*oComponent*/, { || G300OSetTable(oView) }, STR0007, STR0008) } ,,VK_F5) //"Executar Filtro"
oView:AddUserButton(STR0006,"",{|oView| FWMsgRun(/*oComponent*/, { || G300OSave(oView)  }, STR0007, STR0009 ) } ,,VK_F10) //"Executar Filtro"

Return(oView)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300OSetStruct

Função responsável pela definição das estruturas utilizadas no Model ou na View.

@Params: 
	oStrCab:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do parâmetro lModel 	
	oStrGrd:	Objeto da Classe FwFormStruct.
	lModel:		Lógico. .t. - Será criado/atualizado a estrutura do Model; .f. - será criado/atualizado a
	estrutura da View
	
@sample: GC300OSetStruct(oStrCab, oStrGrd, lModel)

@author GTP

@since 29/04/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GC300OSetStruct(oStrCab, oStrGrd, lModel)

Local aFields	:= {}

Local cFields	:= ""
Local aComboBox := {"1=Normal","2=Extraordinária","3=Fret. Contínuo","4=Todas"}
Local nI		:= 0
Local aOrdem	:= {}
Default lModel := .t.

If ( !lModel ) //VIEW

		oStrCab:AddField(;
			"GYNCODCLI",;						// [01]  C   Nome do Campo
			"60",;							// [02]  C   Ordem
			"Cod.Cliente",;							// [03]  C   Titulo do campo // "Data de"
			"Cod.Cliente",;						// [04]  C   Descricao do campo // "Data de"
			{"Cod.Cliente"},;				// [05]  A   Array com Help // "Data de"
			"GET",;							// [06]  C   Tipo do campo
			"@!",;						// [07]  C   Picture
			Nil,;							// [08]  B   Bloco de Picture Var
			"SA1",;							// [09]  C   Consulta F3
			.T.,;							// [10]  L   Indica se o campo é alteravel
			Nil,;							// [11]  C   Pasta do campo
			"",;							// [12]  C   Agrupamento do campo
			Nil,;							// [13]  A   Lista de valores permitido do campo (Combo)
			Nil,;							// [14]  N   Tamanho maximo da maior opção do combo
			Nil,;							// [15]  C   Inicializador de Browse
			.T.,;							// [16]  L   Indica se o campo é virtual
			Nil,;							// [17]  C   Picture Variavel
			.F.) 							// [18]  L   Indica pulo de linha após o campo

		oStrCab:AddField(;
			"GYNLOJA",;						// [01]  C   Nome do Campo
			"61",;							// [02]  C   Ordem
			"Lj.Cliente",;							// [03]  C   Titulo do campo // "Data de"
			"Lj.Cliente",;						// [04]  C   Descricao do campo // "Data de"
			{"Loja Cliente"},;				// [05]  A   Array com Help // "Data de"
			"GET",;							// [06]  C   Tipo do campo
			"@!",;						// [07]  C   Picture
			Nil,;							// [08]  B   Bloco de Picture Var
			"",;							// [09]  C   Consulta F3
			.T.,;							// [10]  L   Indica se o campo é alteravel
			Nil,;							// [11]  C   Pasta do campo
			"",;							// [12]  C   Agrupamento do campo
			Nil,;							// [13]  A   Lista de valores permitido do campo (Combo)
			Nil,;							// [14]  N   Tamanho maximo da maior opção do combo
			Nil,;							// [15]  C   Inicializador de Browse
			.T.,;							// [16]  L   Indica se o campo é virtual
			Nil,;							// [17]  C   Picture Variavel
			.F.) 							// [18]  L   Indica pulo de linha após o campo

	aFields := aClone(oStrCab:GetFields())	
	cFields := "GYN_TIPO|GYN_LINCOD|GYN_DTINI|GYN_DTFIM|GYN_LOCORI|GYN_DSCORI|GYN_LOCDES|GYN_DSCDES|GYN_NUMSRV|GYNCODCLI|GYNLOJA"
	
	For nI := 1 to Len(aFields)
		
		If ( !(aFields[nI,1] $ cFields) )
		
			If ( oStrCab:HasField(aFields[nI,1]) )
				oStrCab:RemoveField(aFields[nI,1])
			EndIf
				
		EndIf	
		
	Next nI
	
	oStrCab:SetProperty("GYN_TIPO",		MVC_VIEW_COMBOBOX,	aComboBox )
	oStrCab:SetProperty("GYN_LINCOD",	MVC_VIEW_LOOKUP,	"GI2")
	oStrCab:SetProperty("GYN_LOCORI",	MVC_VIEW_LOOKUP,	"GI1")   
	oStrCab:SetProperty("GYN_LOCDES",	MVC_VIEW_LOOKUP,	"GI1") 		                                              
	
	aFields := aClone(oStrGrd:GetFields())	
	cFields := "GYN_CODIGO|GYN_TIPO|GYN_LINCOD|GYN_DTINI|GYN_HRINI|GYN_DTFIM|GYN_HRFIM|GYN_LOCORI|GYN_DSCORI|GYN_LOCDES|GYN_DSCDES|GYN_NUMSRV|GYN_KMPROV|GYN_KMREAL"
	
	For nI := 1 to Len(aFields)
		
		If ( !(aFields[nI,1] $ cFields) )
		
			If ( oStrGrd:HasField(aFields[nI,1]) )
				oStrGrd:RemoveField(aFields[nI,1])
			EndIf
				
		EndIf	
		
	Next nI	
	
	oStrGrd:SetProperty("*",			MVC_VIEW_CANCHANGE,.F.)
	oStrGrd:SetProperty("GYN_KMREAL",	MVC_VIEW_CANCHANGE,.T.)	
		
	aAdd(aOrdem,{"GYN_CODIGO","GYN_KMPROV"})
	aAdd(aOrdem,{"GYN_KMPROV","GYN_KMREAL"})	
	GTPOrdVwStruct(oStrGrd,aOrdem)	
	
Else //MODEL

	oStrCab:AddField('Cod.Cliente','Cod.Cliente',"GYNCODCLI","C",06,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
	oStrCab:AddField('Lj.Cliente','Lj.Cliente',"GYNLOJA","C",02,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)

	oStrCab:SetProperty('GYN_TIPO',MODEL_FIELD_VALUES,aComboBox)
	oStrCab:SetProperty('GYN_TIPO' , MODEL_FIELD_VALID, {||.T.})
	oStrGrd:SetProperty("*",		MODEL_FIELD_OBRIGAT,.F.)	

Endif

Return

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} G300OSetTable()
Realiza a caraga das viagens
 
@Params:
	oSubMdl:	O Sub modelo

@Return
		 						
@author GTP

@since 29/04/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function G300OSetTable(oView)

	Local oModel     := oView:GetModel()
	Local oMdlCAB    := oView:GetModel( 'GYNMASTER' )
	Local oMdlGYN    := oView:GetModel( 'GYNDETAIL' )
	Local aFldGYN    := {}
	Local cAliasFilt := GetNextAlias()
	Local nI         := 0
	Local cExpressao := "%"

	If !Empty( oMdlCAB:GetValue("GYN_TIPO") ) .And. oMdlCAB:GetValue("GYN_TIPO") <> '4'
		cExpressao	+= "AND GYN_TIPO = '" + oMdlCAB:GetValue("GYN_TIPO") + "' "
	EndIf

	If GYN->(FieldPos("GYN_APUCON")) > 0
		cExpressao	+= "AND GYN_APUCON = '" + '' + "'"
	EndIf

	If !Empty( oMdlCAB:GetValue("GYN_LINCOD") )
		cExpressao	+= "AND GYN_LINCOD = '" + oMdlCAB:GetValue("GYN_LINCOD") + "'"
	EndIf

	If !Empty( oMdlCAB:GetValue("GYN_DTINI") )
		cExpressao	+= "AND GYN_DTINI >= '" + DTOS( oMdlCAB:GetValue("GYN_DTINI") )+ "'"
	EndIf

	If !Empty( oMdlCAB:GetValue("GYN_DTFIM") )
		cExpressao	+= "AND GYN_DTFIM <= '" + DTOS( oMdlCAB:GetValue("GYN_DTFIM") ) + "'"
	EndIf

	If !Empty( oMdlCAB:GetValue("GYN_LOCORI") )
		cExpressao	+= "AND GYN_LOCORI = '" + oMdlCAB:GetValue("GYN_LOCORI") + "'"
	EndIf

	If !Empty( oMdlCAB:GetValue("GYN_LOCDES") )
		cExpressao	+= "AND GYN_LOCDES = '" + oMdlCAB:GetValue("GYN_LOCDES") + "'"
	EndIf

	If !Empty( oMdlCAB:GetValue("GYN_NUMSRV") )
		cExpressao	+= "AND GYN_NUMSRV = '" + oMdlCAB:GetValue("GYN_NUMSRV") + "'"
	EndIf

	If !Empty( oMdlCAB:GetValue("GYNCODCLI") )
		cExpressao	+= "AND ( "
		cExpressao	+= "	 ( GY0_CLIENT = '" + oMdlCAB:GetValue("GYNCODCLI") + "'  "
		cExpressao	+= "	   AND GY0_LOJACL = '" + oMdlCAB:GetValue("GYNLOJA") + "' ) "
		cExpressao	+= "	 OR ( G6R_SA1COD = '" + oMdlCAB:GetValue("GYNCODCLI") + "'  "
		cExpressao	+= "	  AND G6R_SA1LOJ = '" + oMdlCAB:GetValue("GYNLOJA") + "' ) "
		cExpressao	+= " ) "
	EndIf

	//final da expressão
	cExpressao	+= "%"

	oMdlGYN:ClearData()

	//Desbloqueia inserção e exclusão de linhas
	oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.F.)
	oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.F.)

	BeginSql Alias cAliasFilt
	
		SELECT GYN_CODIGO,GYN_TIPO,GYN_LINCOD,GYN_DTINI,GYN_HRINI,GYN_DTFIM,GYN_HRFIM,GYN_LOCORI,GYN_LOCDES,GYN_NUMSRV,GYN_KMPROV,GYN_KMREAL
		FROM %Table:GYN% GYN		
		LEFT JOIN %Table:GY0% GY0 ON GY0.GY0_FILIAL = GYN.GYN_FILIAL
			AND GY0.GY0_NUMERO = GYN.GYN_CODGY0
			AND GY0.GY0_ATIVO = '1'
			AND GY0.%NotDel%
		LEFT JOIN %Table:G6R% G6R ON G6R.G6R_FILIAL = %xFilial:G6R%
			AND G6R.G6R_CODIGO = GYN.GYN_CODG6R
			AND G6R.G6R_STATUS = '2'
			AND G6R.%NotDel%
		WHERE
			GYN_FILIAL = %xFilial:GYN%
			%Exp:cExpressao%	
			AND GYN.%NotDel%
		ORDER BY 
			GYN_CODIGO,GYN_TIPO,GYN_LINCOD,GYN_DTINI,GYN_HRINI,GYN_DTFIM,GYN_HRFIM,GYN_LOCORI,GYN_LOCDES,GYN_NUMSRV,GYN_KMPROV,GYN_KMREAL			
	
	EndSql
	
	
	If (cAliasFilt)->(!EOF())
		aFldGYN := (cAliasFilt)->(DbStruct())
	EndIf
	
	While (cAliasFilt)->(!EOF())						
			
		If !oMdlGYN:IsEmpty()
			 oMdlGYN:AddLine()
		EndIf
				
		For nI := 1 to Len(aFldGYN)	
			oMdlGYN:LoadValue( aFldGYN[nI][1], GTPCastType((cAliasFilt)->&(aFldGYN[nI][1]), TamSx3(aFldGYN[nI][1])[3]) )
			If 	aFldGYN[nI][1] == 'GYN_LOCORI'
				oMdlGYN:LoadValue( 'GYN_DSCORI',Posicione('GI1', 1, xFilial('GI1')+(cAliasFilt)->&(aFldGYN[nI][1]), 'GI1_DESCRI') )
			ElseIf aFldGYN[nI][1] == 'GYN_LOCDES'
				oMdlGYN:LoadValue( 'GYN_DSCDES',Posicione('GI1', 1, xFilial('GI1')+(cAliasFilt)->&(aFldGYN[nI][1]), 'GI1_DESCRI') )
			EndIf	
		Next		
				
		(cAliasFilt)->(DbSkip())
	EndDo	
	
	(cAliasFilt)->(DbCloseArea())	


oMdlGYN:GoLine(1)
GTPDestroy(aFldGYN)

//Bloqueia inserção e exclusão de linhas
oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)

oView:Refresh()

Return



//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300ODsc

Função responsável para buscar a descrição 

@Param
			oMdlGQE	- O modelo recurso da viagem

@Return 	cDescri - Descrição do campo
		
@sample GTPC300O()
@author GTP

@since 30042019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Function GC300ODsc(oMdl,cCampo)
	Local cDescri	:= ""
	
	cDescri := Posicione('GI1', 1, xFilial('GI1')+oMdl:GetValue(cCampo), 'GI1_DESCRI')	

Return(cDescri)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GC300OFech

Função executada através do bloco de Cancelamento da Tela. Configura a View
como se não tivesse sido alterada.

@param		Nenhum
@since		29/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function GC300OFech() 

Local oView	:= FwViewActive()
		
oView:SetModified(.f.)
	
Return(.t.)

/*/{Protheus.doc} G300OSave
//TODO Descrição auto-gerada.
@author osmar.junior
@since 30/04/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Function G300OSave(oViewAux)
Local oView		:= Iif(oViewAux <> Nil, oViewAux:GetModel(), FwViewActive() )
Local oMdlGYN	:= oView:GetModel('GYNDETAIL')
Local oMdl300	:= FwLoadModel('GTPA300')
Local n			:= 0

DbSelectArea("GYN")
GYN->(DbSetOrder(1))

For n := 1 To oMdlGYN:Length()
	oMdlGYN:GoLine(n)
	If GYN->(DbSeek(xFilial("GYN")+oMdlGYN:GetValue('GYN_CODIGO')))
		If GYN->GYN_KMREAL <> oMdlGYN:GetValue('GYN_KMREAL') // Somente Faz ajuste de KM se valor diferente (Performance)
			oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
			oMdl300:Activate()
			oMdl300:GetModel('GYNMASTER'):LoadValue('GYN_KMREAL', oMdlGYN:GetValue('GYN_KMREAL') )
			If oMdl300:VldData()
				If FwFormCommit(oMdl300)
					oMdl300:DeActivate()				
				EndIf
			Else
				JurShowErro( oMdl300:GetModel():GetErrormessage() )									
			EndIf	
		EndIf
	EndIf	
Next n			

oMdlGYN:GoLine(1)
oMdl300:Destroy()

Return
