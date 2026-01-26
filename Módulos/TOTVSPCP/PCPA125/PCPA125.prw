#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PCPA125.ch'

/*/{Protheus.doc} PCPA125
//Rotina de Programa x Usuarios
@author Thiago Zoppi
@since 12/05/2018
@version 1.0
/*/
Function PCPA125()
	Local oBrowse

	If !AliasInDic("SOX") .Or. !AliasInDic("SOY") .Or. !AliasInDic("SOZ")
		Help( ,, 'PCPA125',, STR0007, 1, 0 ) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	Else
		If !A125UPDATE()
			Help(,,'PCPA125',,STR0052,1,0,,,,,,{STR0053}) //"Não foi possível atualizar os cadastros dos formulários." "Contate o administrador do sistema."
			Return
		EndIf
		oBrowse := BrowseDef()
		oBrowse:Activate()
	EndIf
Return 

//PARA ADAPTAR AO MVC LOCALIZADO 
Static Function BrowseDef()
	Local oBrowse := FWMBrowse():New()	

	oBrowse:SetAlias('SOX')
	oBrowse:SetDescription(STR0040) //Formulários do APP Minha Produção
	oBrowse:SetMenuDef('PCPA125')
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0023 ACTION 'VIEWDEF.PCPA125' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0024 ACTION 'VIEWDEF.PCPA125' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0025 ACTION 'VIEWDEF.PCPA125' OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina TITLE STR0026 ACTION 'VIEWDEF.PCPA125' OPERATION 2 ACCESS 0 // Visualizar
Return aRotina  

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Thiago Zoppi
@since 11/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local cIndSMC    := "MC_FILIAL+MC_CODFORM"
	Local oModel     := Nil
	Local oStruHZT   := Nil
	Local oStruSOX   := FWFormStruct(1,'SOX')
	Local oStruSOY   := FWFormStruct(1,'SOY')
	Local oStruSOZ   := FWFormStruct(1,'SOZ')
	Local oStruSOYL	 := FWFormStruct(1, "SOY", {|x| "|" + AllTrim(x) + "|" $ "|OY_POSIC|OY_DESCAMP|"})
	Local oStruSMJL	 := FWFormStruct(1, "SMJ", {|x| "|" + AllTrim(x) + "|" $ "|MJ_POSIC|MJ_DESCAMP|"})
	Local oStruHWS   := Nil
	Local oStruHWSC  := Nil
	Local oStruSMC   := Nil
	Local oStruSMJ   := Nil
	Local oStrSMJPms := Nil
	Local oEvent     := PCPA125EVDEF():New()	

	oModel := MPFormModel():New('PCPA125')
	oModel:SetDescription(STR0001) //Formulario do Apontamento de Producao 

	oStruSOX:SetProperty('OX_PRGAPON', MODEL_FIELD_NOUPD  , .T.)
	oStruSOX:SetProperty('OX_FORM'   , MODEL_FIELD_OBRIGAT, .T.)
	oStruSOX:SetProperty('OX_IMAGEM' , MODEL_FIELD_OBRIGAT, .T.)
	oStruSOX:SetProperty('OX_DESCR'  , MODEL_FIELD_OBRIGAT, .T.)
	oStruSOX:SetProperty('OX_PRGAPON', MODEL_FIELD_VALID  , { || VldPrgApon(oModel)} )
	oStruSOX:SetProperty('OX_PRGAPON', MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnPRG(a,b)"))
	If SOX->(FieldPos("OX_FORMPER")) > 0
		oStruSOX:SetProperty('OX_FORMPER', MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnFPr(a,b)"))
	EndIf

	oStruSOY:SetProperty('OY_CODFORM', MODEL_FIELD_OBRIGAT, .F.)
	oStruSOY:SetProperty('OY_CODBAR' , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSOY(a,b)"))
	oStruSOY:SetProperty('OY_EDITA'  , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSOY(a,b)"))
	oStruSOY:SetProperty('OY_VALPAD' , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSOY(a,b)"))

	oStruSOZ:SetProperty('OZ_CODFORM', MODEL_FIELD_OBRIGAT, .F.)
	oStruSOZ:SetProperty('OZ_DESCGRP', MODEL_FIELD_OBRIGAT, .F.)

	oModel:addFields('OXMASTER',, oStruSOX)
	oModel:getModel('OXMASTER'):SetDescription(STR0003) //Cabecalho 
	
	oModel:addGrid('DETAIL_SOY', 'OXMASTER', oStruSOY)
	oModel:addGrid('DETAIL_SOZ', 'OXMASTER', oStruSOZ)
	oModel:getModel('DETAIL_SOY'):SetDescription(STR0004) //Detalhes de Campos
	oModel:getModel('DETAIL_SOZ'):SetDescription(STR0005) //Detalhes Usuarios
	oModel:getModel('DETAIL_SOY'):SetNoInsertLine(.T.)
	oModel:getModel('DETAIL_SOY'):SetNoDeleteLine(.T.)

	/*LAYOUT*/
	oModel:AddGrid("PCPA125_SOY_CAMPOS"  ,"OXMASTER",oStruSOYL, , , , , {|| A125LoadC(oModel)})
	oModel:getModel('PCPA125_SOY_CAMPOS'):SetOptional(.T.)
	oStruSOYL:SetProperty('OY_DESCAMP' , MODEL_FIELD_TAMANHO, 50 )
	oModel:getModel('PCPA125_SOY_CAMPOS'):SetOnlyQuery(.T.)
	oModel:SetRelation('PCPA125_SOY_CAMPOS', {{'OY_FILIAL' , 'xFilial("SOY")'}, {'OY_CODFORM', 'OX_FORM'}})

	oModel:AddGrid("PCPA125_SMJ_EMPENHOS"  ,"OXMASTER",oStruSMJL, , , , ,{|| A125LoadE(oModel)})
	oModel:getModel('PCPA125_SMJ_EMPENHOS'):SetOptional(.T.)
	oStruSMJL:SetProperty('MJ_DESCAMP' , MODEL_FIELD_TAMANHO, 50 )
	oModel:getModel('PCPA125_SMJ_EMPENHOS'):SetOnlyQuery(.T.)
	oModel:SetRelation('PCPA125_SMJ_EMPENHOS', {{'MJ_FILIAL', 'xFilial("SMJ")'}, {'MJ_CODFORM', 'OX_FORM'}})

	oStruHWS := FWFormModelStruct():New()
	
	oStruHWS:AddTable("HWS", {"HWS_CDMQ"}, STR0008 ) //"Máquina"
	oStruHWS:AddIndex(1, "01", "HWS_CDMQ", STR0008, "", "", .T. ) //"Máquina"
	
	oStruHWS:AddField(""     ,"" , "MARCA"   , "L", 1 , 0, Nil, Nil     , Nil, Nil, {|| .F.}, Nil, Nil, .T.)
	oStruHWS:AddField(STR0008, "", "HWS_CDMQ", "C", 10, 0, Nil, {|| .F.}, Nil, Nil, {|| .F.}, Nil, Nil, .T.) //"Máquina"
	oStruHWS:AddField(STR0009, "", "HWS_DSMQ", "C", 40, 0, Nil, {|| .F.}, Nil, Nil, {|| .F.}, Nil, Nil, .T.) //"Descrição"

	oModel:addGrid('DETAIL_HWS', 'OXMASTER', oStruHWS,,,,, {||LoadHWS(.F.)} )

	oModel:getModel('DETAIL_HWS'):SetDescription(STR0010) //"Detalhes Maquina"
	oModel:getModel('DETAIL_HWS'):SetOnlyQuery(.T.)
	oModel:getModel('DETAIL_HWS'):SetOptional(.T.)

	oModel:getModel('DETAIL_HWS'):SetNoInsertLine(.T.)
	oModel:getModel('DETAIL_HWS'):SetNoDeleteLine(.T.)

	If AliasInDic("HZT")
		oStruHZT := FWFormModelStruct():New()

		oStruHZT:AddField(STR0065                   ,;	// [01] C Titulo do campo //"Integra CRP?"                                    		        
			STR0065                                 ,;	// [02] C ToolTip do campo                                                           
			"INT_CRP"                               ,;	// [03] C Id do Field                                                                
			"L"                                     ,;	// [04] C Tipo do campo                                                              
			1       	                            ,;	// [05] N Tamanho do campo                                                           
			NIL  	                                ,;	// [06] N Decimal do campo                                                           
			NIL	                                    ,;	// [07] B Code-block de validação do campo                                           
			NIL	                                    ,;	// [08] B Code-block de validação When do campo                                      
			{}                      		        ,;	// [09] A Lista de valores permitido do campo
			.F.                                     ,;	// [10] L Indica se o campo tem preenchimento obrigatório                            
			NIL		                                ,;	// [11] B Code-block de inicializacao do campo                            
			NIL                                     ,;	// [12] L Indica se trata-se de um campo chave                                       
			.F.                                     ,;	// [13] L Indica se o campo pode receber valor em uma operação de update             
			.T.					   					;	// [14] L Indica se o campo é virtual
			)

		oStruHZT:AddField(STR0066                   ,;	// [01] C Titulo do campo //"Operações Programadas"
			STR0066                                 ,;	// [02] C ToolTip do campo                                                           
			"OP_PROGR"                              ,;	// [03] C Id do Field                                                                
			"C"                                     ,;	// [04] C Tipo do campo                                                              
			1                                       ,;	// [05] N Tamanho do campo                                                           
			0                                       ,;	// [06] N Decimal do campo                                                           
			NIL   			                        ,;	// [07] B Code-block de validação do campo                                           
			{||A125WhnCRP()}                        ,;	// [08] B Code-block de validação When do campo 
			{"1="+STR0067,"2="+STR0068,"3="+STR0069},;	// [09] A Lista de valores permitido do campo
			.F.                                     ,;	// [10] L Indica se o campo tem preenchimento obrigatório                            
			{||"3"}                                 ,;	// [11] B Code-block de inicializacao do campo                            
			NIL                                     ,;	// [12] L Indica se trata-se de um campo chave                                       
			.F.                                     ,;	// [13] L Indica se o campo pode receber valor em uma operação de update
			.T.					   					;	// [14] L Indica se o campo é virtual
			)

		oStruHZT:AddField(STR0073                   ,;	// [01] C Titulo do campo //"Exige sequência programada?"   
			STR0073                                 ,;	// [02] C ToolTip do campo                                                           
			"EX_PROGR"                               ,;	// [03] C Id do Field                                                                
			"L"                                     ,;	// [04] C Tipo do campo                                                              
			1                                       ,;	// [05] N Tamanho do campo                                                           
			NIL                                     ,;	// [06] N Decimal do campo                                                           
			NIL					                    ,;	// [07] B Code-block de validação do campo                                           
			{||A125WhnCRP()}                        ,;	// [08] B Code-block de validação When do campo 
			{}                      		        ,;	// [09] A Lista de valores permitido do campo
			.F.                                     ,;	// [10] L Indica se o campo tem preenchimento obrigatório                            
			NIL                                     ,;	// [11] B Code-block de inicializacao do campo                            
			NIL                                     ,;	// [12] L Indica se trata-se de um campo chave                                       
			.F.                                     ,;	// [13] L Indica se o campo pode receber valor em uma operação de update
			.T.					   					;	// [14] L Indica se o campo é virtual
			)

		oStruHZT:AddField(STR0075                   ,;	// [01] C Titulo do campo //"Setup Inicial"
			STR0075                                 ,;	// [02] C ToolTip do campo                                                           
			"SETUP_INICIAL"                         ,;	// [03] C Id do Field                                                                
			"L"                                     ,;	// [04] C Tipo do campo                                                              
			1                                       ,;	// [05] N Tamanho do campo                                                           
			NIL                                     ,;	// [06] N Decimal do campo                                                           
			NIL					                    ,;	// [07] B Code-block de validação do campo                                           
			{||A125WhnCRP()}                        ,;	// [08] B Code-block de validação When do campo 
			{}                      		        ,;	// [09] A Lista de valores permitido do campo
			.F.                                     ,;	// [10] L Indica se o campo tem preenchimento obrigatório                            
			NIL                                     ,;	// [11] B Code-block de inicializacao do campo                            
			NIL                                     ,;	// [12] L Indica se trata-se de um campo chave                                       
			.F.                                     ,;	// [13] L Indica se o campo pode receber valor em uma operação de update
			.T.					   					;	// [14] L Indica se o campo é virtual
			)

		oStruHZT:AddField(STR0076                   ,;	// [01] C Titulo do campo //"Produção"
			STR0076                                 ,;	// [02] C ToolTip do campo                                                           
			"PRODUCAO"                              ,;	// [03] C Id do Field                                                                
			"L"                                     ,;	// [04] C Tipo do campo                                                              
			1                                       ,;	// [05] N Tamanho do campo                                                           
			NIL                                     ,;	// [06] N Decimal do campo                                                           
			NIL					                    ,;	// [07] B Code-block de validação do campo                                           
			{||A125WhnCRP()}                        ,;	// [08] B Code-block de validação When do campo 
			{}                      		        ,;	// [09] A Lista de valores permitido do campo
			.F.                                     ,;	// [10] L Indica se o campo tem preenchimento obrigatório                            
			NIL                                     ,;	// [11] B Code-block de inicializacao do campo                            
			NIL                                     ,;	// [12] L Indica se trata-se de um campo chave                                       
			.F.                                     ,;	// [13] L Indica se o campo pode receber valor em uma operação de update
			.T.					   					;	// [14] L Indica se o campo é virtual
			)

		oStruHZT:AddField(STR0077                   ,;	// [01] C Titulo do campo //"Finalização"
			STR0077                                 ,;	// [02] C ToolTip do campo                                                           
			"FINALIZACAO"                           ,;	// [03] C Id do Field                                                                
			"L"                                     ,;	// [04] C Tipo do campo                                                              
			1                                       ,;	// [05] N Tamanho do campo                                                           
			NIL                                     ,;	// [06] N Decimal do campo                                                           
			NIL					                    ,;	// [07] B Code-block de validação do campo                                           
			{||A125WhnCRP()}                        ,;	// [08] B Code-block de validação When do campo 
			{}                      		        ,;	// [09] A Lista de valores permitido do campo
			.F.                                     ,;	// [10] L Indica se o campo tem preenchimento obrigatório                            
			NIL                                     ,;	// [11] B Code-block de inicializacao do campo                            
			NIL                                     ,;	// [12] L Indica se trata-se de um campo chave                                       
			.F.                                     ,;	// [13] L Indica se o campo pode receber valor em uma operação de update
			.T.					   					;	// [14] L Indica se o campo é virtual
			)	

		oStruHZT:AddField(STR0078                   ,;	// [01] C Titulo do campo //"Remoção"
			STR0078                                 ,;	// [02] C ToolTip do campo                                                           
			"REMOCAO"                               ,;	// [03] C Id do Field                                                                
			"L"                                     ,;	// [04] C Tipo do campo                                                              
			1                                       ,;	// [05] N Tamanho do campo                                                           
			NIL                                     ,;	// [06] N Decimal do campo                                                           
			NIL					                    ,;	// [07] B Code-block de validação do campo                                           
			{||A125WhnCRP()}                        ,;	// [08] B Code-block de validação When do campo 
			{}                      		        ,;	// [09] A Lista de valores permitido do campo
			.F.                                     ,;	// [10] L Indica se o campo tem preenchimento obrigatório                            
			NIL                                     ,;	// [11] B Code-block de inicializacao do campo                            
			NIL                                     ,;	// [12] L Indica se trata-se de um campo chave                                       
			.F.                                     ,;	// [13] L Indica se o campo pode receber valor em uma operação de update
			.T.					   					;	// [14] L Indica se o campo é virtual
			)

		oModel:addFields("HZTFIELDS","OXMASTER", oStruHZT, , ,{|| A125LoadHZT(oModel)})
		oModel:getModel("HZTFIELDS"):SetDescription(STR0073) //CRP

		oStruHWSC := FWFormModelStruct():New()
		
		oStruHWSC:AddTable("HWS", {"HWS_CDMQ"}, STR0082 ) //"Recurso"
		oStruHWSC:AddIndex(1, "01", "HWS_CDMQ", STR0082, "", "", .T. ) //"Recurso"
		
		oStruHWSC:AddField(""     ,"" , "MARCA"   , "L", 1 , 0, Nil, {||A125WhnCRP()}, Nil, Nil, {|| .F.}, Nil, Nil, .T.)
		oStruHWSC:AddField(STR0082, "", "HWS_CDMQ", "C", 10, 0, Nil, {|| .F.}        , Nil, Nil, {|| .F.}, Nil, Nil, .T.) //"Recurso"
		oStruHWSC:AddField(STR0009, "", "HWS_DSMQ", "C", 40, 0, Nil, {|| .F.}        , Nil, Nil, {|| .F.}, Nil, Nil, .T.) //"Descrição"

		oModel:addGrid('DETAIL_HWSC', 'OXMASTER', oStruHWSC,,,,, {||LoadHWS(.F.)} )

		oModel:getModel('DETAIL_HWSC'):SetDescription(STR0083) //"Detalhes Recurso"
		oModel:getModel('DETAIL_HWSC'):SetOnlyQuery(.T.)
		oModel:getModel('DETAIL_HWSC'):SetOptional(.T.)

		oModel:getModel('DETAIL_HWSC'):SetNoInsertLine(.T.)
		oModel:getModel('DETAIL_HWSC'):SetNoDeleteLine(.T.)
	EndIf

	oStruSMC := FWFormStruct(1, 'SMC')
	AltMdlSMC(@oStruSMC)
	
	oModel:addGrid('DETAIL_SMC', 'OXMASTER', oStruSMC,, {|| LinePosSMC(oModel)},, {|| LinePosSMC(oModel)})
	oModel:getModel('DETAIL_SMC'):SetDescription(STR0019) //Detalhes de Campos customizaveis

	oModel:getModel('DETAIL_SMC'):SetNoInsertLine(.T.)
	oModel:getModel('DETAIL_SMC'):SetNoDeleteLine(.T.)
	oModel:GetModel("DETAIL_SMC"):SetUniqueLine({"MC_CODFORM","MC_CAMPO"})

	//Struct do formulário de empenhos com os campos de permissão
	oStrSMJPms := FWFormStruct(1, 'SMJ', {|x| "|"+AllTrim(x)+"|" $ "|MJ_VISUAL|MJ_INCLUI|MJ_ALTERA|MJ_EXCLUI|"})
	
	oStrSMJPms:AddTrigger("MJ_INCLUI", "MJ_VISUAL", , {|oModel, cCmpOrigem, cValor| atuVisEmp(oModel, cCmpOrigem, cValor)})
	oStrSMJPms:AddTrigger("MJ_ALTERA", "MJ_VISUAL", , {|oModel, cCmpOrigem, cValor| atuVisEmp(oModel, cCmpOrigem, cValor)})
	oStrSMJPms:AddTrigger("MJ_EXCLUI", "MJ_VISUAL", , {|oModel, cCmpOrigem, cValor| atuVisEmp(oModel, cCmpOrigem, cValor)})
	
	oModel:addFields('SMJ_PERMISSAO',"OXMASTER", oStrSMJPms)
	oModel:getModel('SMJ_PERMISSAO'):SetDescription(STR0029) //"Formulário de empenhos - Permissões"
	oModel:getModel('SMJ_PERMISSAO'):SetOnlyQuery(.T.)

	//Struct do formulário de empenhos com os campos do formulário.
	oStruSMJ := FWFormStruct(1, 'SMJ')
	oStruSMJ:SetProperty('MJ_CODFORM', MODEL_FIELD_OBRIGAT, .F.)

	oModel:addGrid('DETAIL_SMJ', 'OXMASTER', oStruSMJ)
	oModel:getModel('DETAIL_SMJ'):SetOptional(.T.)
	//Altera propriedades de validação/edição da tabela SMJ
	A125PropMJ(oModel:getModel('DETAIL_SMJ'), oStruSMJ, "ADICIONAR")

	oModel:getModel('DETAIL_SMJ'):SetDescription(STR0030)

	oModel:SetPrimaryKey({'OX_FILIAL','OX_FORM' })
	oModel:SetRelation('DETAIL_SOZ', { { 'OZ_FILIAL' , 'xFilial("SOZ")'	}, { 'OZ_CODFORM', 'OX_FORM' } }, SOZ->(IndexKey(1)) )
	oModel:SetRelation('DETAIL_SOY', { { 'OY_FILIAL' , 'xFilial("SOY")'	}, { 'OY_CODFORM', 'OX_FORM' } }, SOY->(IndexKey(1)) )
	
	oModel:SetRelation('DETAIL_HWS', { { 'HWS_FILIAL', 'xFilial("HWS")'	}, { 'HWS_FORM'  , 'OX_FORM' } }, HWS->(IndexKey(1)) )
	
	If SMC->(FieldPos("MC_POSIC")) > 0
		cIndSMC := "MC_FILIAL+MC_CODFORM+MC_TPFORM+MC_VISIVEL+MC_POSIC+MC_TIPO"
	EndIf
	oModel:SetRelation('DETAIL_SMC', { { 'MC_FILIAL' , 'xFilial("SMC")'	}, { 'MC_CODFORM', 'OX_FORM' } }, cIndSMC )

	oModel:SetRelation('DETAIL_SMJ'   , { { 'MJ_FILIAL' , 'xFilial("SMJ")'	}, { 'MJ_CODFORM', 'OX_FORM' } }, SMJ->(IndexKey(2)) )
	oModel:SetRelation('SMJ_PERMISSAO', { { 'MJ_FILIAL' , 'xFilial("SMJ")'	}, { 'MJ_CODFORM', 'OX_FORM' } }, SMJ->(IndexKey(1)) )

	//ATIVAR EVENTOS
	oModel:InstallEvent("PCPA125EVDEF", /*cOwner*/, oEvent)
	oModel:SetActivate( {|oModel| LoadHWS(.T.) } )

Return oModel

/*/{Protheus.doc} A125WhnFPr
Função de avaliação de WHEN para o campo OX_FORMPER.

@type Function
@author renan.roeder
@since 13/05/2024
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnFPr(oModel, cCampo)
	Local lRet := .F.

	If oModel:GetValue("OX_PRGAPON") $ "|1|3|"
		lRet := .T.
	EndIf
Return lRet

/*/{Protheus.doc} A125WhnCRP
Função de avaliação de WHEN.
@type  Function
@author juliana.oliveira
@since 06/08/2025
@version P12
@return lOk, Logico, Retorna se utiliza ou não a integração.
/*/
Function A125WhnCRP()
	Local cValue     := ""
	Local lOk        := .T.
	Local oModel     := FWModelActive()
	Local oMdlHZT    := Nil

	oMdlHZT   := oModel:getModel("HZTFIELDS")
	cValue    := oMdlHZT:GetValue("INT_CRP")

	If Empty(cValue) .Or. !cValue 
		lOk := .F.
	EndIf

Return lOk 

/*/{Protheus.doc} A125WhnPRG
Função de avaliação de WHEN para o campo OX_PRGAPON.

@type Function
@author renan.roeder
@since 12/03/2024
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnPRG(oModel, cCampo)
	Local lRet := .T.

	If !Empty(oModel:GetValue("OX_PRGAPON"))
		lRet := .F.
	EndIf
Return lRet

Static Function AltMdlSMC(oStruSMC)
	oStruSMC:SetProperty('MC_CODFORM', MODEL_FIELD_OBRIGAT, .F.)
	oStruSMC:SetProperty('MC_TIPO'   , MODEL_FIELD_OBRIGAT, .F.)
	oStruSMC:SetProperty('MC_TABELA' , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSMC(a,b)"))
	oStruSMC:SetProperty('MC_VALPAD' , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "A125VldPAD(a,b,c,d)"))
	If oStruSMC:HasField("MC_POSIC")
		oStruSMC:SetProperty('MC_CAMPO' , MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSMC(a,b)"))
		oStruSMC:SetProperty('MC_CODBAR', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSMC(a,b)"))
		oStruSMC:SetProperty('MC_EDITA' , MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSMC(a,b)"))
		oStruSMC:SetProperty('MC_VALPAD', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnSMC(a,b)"))
	Else
		oStruSMC:AddField(STR0047                                  ,; // [01] C Titulo do campo //"Tp. Form."
						  ""                                       ,; // [02] C ToolTip do campo
						  "TPFORM"                                 ,; // [03] C Id do Field
						  "C"                                      ,; // [04] C Tipo do campo
						  1                                        ,; // [05] N Tamanho do campo
						  0                                        ,; // [06] N Decimal do campo
						  NIL                                      ,; // [07] B Code-block de validação do campo
						  NIL                                      ,; // [08] B Code-block de validação When do campo
						  {"1="+STR0043,"2="+STR0042,"3="+STR0044} ,; // [09] A Lista de valores permitido do campo {1=Apontamento,2=Empenho,3=Cadastro OP}
						  .F.                                      ,; // [10] L Indica se o campo tem preenchimento obrigatório
						  FwBuildFeature(STRUCT_FEATURE_INIPAD,"A125INITPF()"),; // [11] B Code-block de inicializacao do campo
						  NIL                                      ,; // [12] L Indica se trata-se de um campo chave
						  NIL                                      ,; // [13] L Indica se o campo pode receber valor em uma operação de update
						  .T.                                      )  // [14] L Indica se o campo é virtual
	EndIf
Return

Function A125INITPF()
	Local cAlias := SUBSTR(SMC->MC_CAMPO,1,aT("_",SMC->MC_CAMPO))
	Local cRet   := ""
    
	If cAlias == "D4_"
		cRet := "2"
	Else
		If cAlias == "C2_"
			cRet := "3"
		Else
			cRet := "1"
		EndIf
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Thiago Zoppi
@since 11/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel( 'PCPA125' )
	Local oStruHZT   := Nil
	Local oStruSOX   := FWFormStruct(2, 'SOX')
	Local oStruSOY   := FWFormStruct(2, 'SOY')
	Local oStruSOZ   := FWFormStruct(2, 'SOZ')
	Local oStruHWS   := Nil
	Local oStruHWSC  := Nil
	Local oStruSMC   := Nil
	Local oStruSMJ   := Nil
	Local oStrSMJPms := Nil
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_SOX', oStruSOX, 'OXMASTER'  )
	oView:AddGrid('VIEW_SOY' , oStruSOY, 'DETAIL_SOY')
	oView:AddGrid('VIEW_SOZ' , oStruSOZ ,'DETAIL_SOZ')
	
	//REMOVER CAMPOS
	oStruSOY:RemoveField('OY_CODFORM')
	oStruSOZ:RemoveField('OZ_CODFORM')

	//ALTERAR PROPRIEDADES DOS CAMPOS 
	oStruSOY:SetProperty('OY_CAMPO'	 , MVC_VIEW_CANCHANGE, .F.)
	If oStruSOY:HasField("OY_POSIC")
		oStruSOY:SetProperty('OY_POSIC'  , MVC_VIEW_ORDEM    , '01')
		oStruSOY:SetProperty("OY_DESCAMP", MVC_VIEW_PICT, "")
	EndIf
	oStruSOX:SetProperty('OX_IMAGEM' , MVC_VIEW_TITULO   , STR0002) // Titulo do campo Imagem "Icone" 
	oStruSOX:SetProperty('OX_PRGAPON', MVC_VIEW_TITULO   , STR0041) // "Tipo Formul."	

	If AliasInDic("HZT")
		oStruHZT := FWFormViewStruct():New()

		oStruHZT:AddGroup('GRP_HZT_INT', '', '', 2) //"CRP"
		oStruHZT:AddGroup('GRP_HZT_ALO', STR0079, '', 2) //"Tipos de alocação"

		oStruHZT:AddField(                           ;
			"INT_CRP"                               ,;	// [01]  C   Id do campo
			"10"                                    ,;	// [02]  C   Ordem
			STR0065                                 ,;	// [03]  C   Titulo do campo    //"Integra CRP?"
			STR0071                                 ,;	// [04]  C   Descricao do campo //"Formulário integrado ao CRP?"
			NIL                                     ,;	// [05]  A   Array com Help
			"L"                                     ,;	// [06]  C   Tipo do campo
			Nil                                     ,;	// [07]  C   Picture do campo
			NIL                                     ,;	// [08]  B   Bloco de Picture Var
			NIL                                     ,;	// [09]  C   Consulta F3
			.T.                                     ,;	// [10]  L   Indica se o campo é alteravel
			NIL                                     ,;	// [11]  C   Pasta do campo
			"GRP_HZT_INT"                           ,;	// [12]  C   Agrupamento do campo
			{}   			                        ,;	// [13]  A   Lista de valores permitido do campo (Combo)
			0                                       ,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL                                     ,;	// [15]  C   Inicializador de Browse
			.T.                                     ,;	// [16]  L   Indica se o campo é virtual
			NIL                                     ,;	// [17]  C   Picture Variavel
			.F.                                      ;  // [18]  L   Indica pulo de linha após o campo
		)

		oStruHZT:AddField(                           ;
			"OP_PROGR"                              ,;	// [01]  C   Id do campo
			"11"                                    ,;	// [02]  C   Ordem
			STR0066                                 ,;	// [03]  C   Titulo do campo    //"Operações Programadas"
			STR0072                                 ,;	// [04]  C   Descricao do campo //"Serão exibidas as operações disponíveis programadas pelo CRP."
			NIL                                     ,;	// [05]  A   Array com Help
			"C"                                     ,;	// [06]  C   Tipo do campo
			Nil                                     ,;	// [07]  C   Picture do campo
			NIL                                     ,;	// [08]  B   Bloco de Picture Var
			NIL                                     ,;	// [09]  C   Consulta F3
			.T.                                     ,;	// [10]  L   Indica se o campo é alteravel
			NIL                                     ,;	// [11]  C   Pasta do campo
			"GRP_HZT_INT"                           ,;	// [12]  C   Agrupamento do campo
			{"1="+STR0067,"2="+STR0068,"3="+STR0069},;	// [13]  A   Lista de valores permitido do campo (Combo)
			0                                       ,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL                                     ,;	// [15]  C   Inicializador de Browse
			.T.                                     ,;	// [16]  L   Indica se o campo é virtual
			NIL                                     ,;	// [17]  C   Picture Variavel
			.F.                                      ;  // [18]  L   Indica pulo de linha após o campo
		)

		oStruHZT:AddField(                           ;
			"EX_PROGR"                              ,;	// [01]  C   Id do campo
			"12"                                    ,;	// [02]  C   Ordem
			STR0073                                 ,;	// [03]  C   Titulo do campo    //"Exige sequencia programada?"
			STR0070                                 ,;	// [04]  C   Descricao do campo //"Exige apontamento na sequência programada?"
			NIL                                     ,;	// [05]  A   Array com Help
			"L"                                     ,;	// [06]  C   Tipo do campo
			Nil                                     ,;	// [07]  C   Picture do campo
			NIL                                     ,;	// [08]  B   Bloco de Picture Var
			NIL                                     ,;	// [09]  C   Consulta F3
			.T.                                     ,;	// [10]  L   Indica se o campo é alteravel
			NIL                                     ,;	// [11]  C   Pasta do campo
			"GRP_HZT_INT"                           ,;	// [12]  C   Agrupamento do campo
			{}			                            ,;	// [13]  A   Lista de valores permitido do campo (Combo)
			0                                       ,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL                                     ,;	// [15]  C   Inicializador de Browse
			.T.                                     ,;	// [16]  L   Indica se o campo é virtual
			NIL                                     ,;	// [17]  C   Picture Variavel
			.F.                                      ;  // [18]  L   Indica pulo de linha após o campo
		)

		oStruHZT:AddField(                           ;
			"SETUP_INICIAL"                         ,;	// [01]  C   Id do campo
			"13"                                    ,;	// [02]  C   Ordem
			STR0075                                 ,;	// [03]  C   Titulo do campo    //"Setup Inicial"
			STR0075                                 ,;	// [04]  C   Descricao do campo //"Setup Inicial"
			NIL                                     ,;	// [05]  A   Array com Help
			"L"                                     ,;	// [06]  C   Tipo do campo
			Nil                                     ,;	// [07]  C   Picture do campo
			NIL                                     ,;	// [08]  B   Bloco de Picture Var
			NIL                                     ,;	// [09]  C   Consulta F3
			.T.                                     ,;	// [10]  L   Indica se o campo é alteravel
			NIL                                     ,;	// [11]  C   Pasta do campo
			"GRP_HZT_ALO"                           ,;	// [12]  C   Agrupamento do campo
			{}			                            ,;	// [13]  A   Lista de valores permitido do campo (Combo)
			0                                       ,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL                                     ,;	// [15]  C   Inicializador de Browse
			.T.                                     ,;	// [16]  L   Indica se o campo é virtual
			NIL                                     ,;	// [17]  C   Picture Variavel
			.F.                                      ;  // [18]  L   Indica pulo de linha após o campo
		)

		oStruHZT:AddField(                           ;
			"PRODUCAO"                    		    ,;	// [01]  C   Id do campo
			"14"                                    ,;	// [02]  C   Ordem
			STR0076                                 ,;	// [03]  C   Titulo do campo    //"Produção"
			STR0076                                 ,;	// [04]  C   Descricao do campo //"Produção"
			NIL                                     ,;	// [05]  A   Array com Help
			"L"                                     ,;	// [06]  C   Tipo do campo
			Nil                                     ,;	// [07]  C   Picture do campo
			NIL                                     ,;	// [08]  B   Bloco de Picture Var
			NIL                                     ,;	// [09]  C   Consulta F3
			.T.                                     ,;	// [10]  L   Indica se o campo é alteravel
			NIL                                     ,;	// [11]  C   Pasta do campo
			"GRP_HZT_ALO"                           ,;	// [12]  C   Agrupamento do campo
			{}			                            ,;	// [13]  A   Lista de valores permitido do campo (Combo)
			0                                       ,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL                                     ,;	// [15]  C   Inicializador de Browse
			.T.                                     ,;	// [16]  L   Indica se o campo é virtual
			NIL                                     ,;	// [17]  C   Picture Variavel
			.F.                                      ;  // [18]  L   Indica pulo de linha após o campo
		)

		oStruHZT:AddField(                           ;
			"FINALIZACAO"                    	    ,;	// [01]  C   Id do campo
			"15"                                    ,;	// [02]  C   Ordem
			STR0077                                 ,;	// [03]  C   Titulo do campo    //"Finalização"
			STR0077                                 ,;	// [04]  C   Descricao do campo //"Finalização"
			NIL                                     ,;	// [05]  A   Array com Help
			"L"                                     ,;	// [06]  C   Tipo do campo
			Nil                                     ,;	// [07]  C   Picture do campo
			NIL                                     ,;	// [08]  B   Bloco de Picture Var
			NIL                                     ,;	// [09]  C   Consulta F3
			.T.                                     ,;	// [10]  L   						
			NIL                                     ,;	// [11]  C   Pasta do campo
			"GRP_HZT_ALO"                           ,;	// [12]  C   Agrupamento do campo
			{}			                            ,;	// [13]  A   Lista de valores permitido do campo (Combo)
			0                                       ,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL                                     ,;	// [15]  C   Inicializador de Browse
			.T.                                     ,;	// [16]  L   Indica se o campo é virtual
			NIL                                     ,;	// [17]  C   Picture Variavel
			.F.                                      ;  // [18]  L   Indica pulo de linha após o campo
		)

		oStruHZT:AddField(                           ;
			"REMOCAO"                    		    ,;	// [01]  C   Id do campo
			"16"                                    ,;	// [02]  C   Ordem
			STR0078                                 ,;	// [03]  C   Titulo do campo    //"Remoção"
			STR0078                                 ,;	// [04]  C   Descricao do campo //"Remoção"
			NIL                                     ,;	// [05]  A   Array com Help
			"L"                                     ,;	// [06]  C   Tipo do campo
			Nil                                     ,;	// [07]  C   Picture do campo
			NIL                                     ,;	// [08]  B   Bloco de Picture Var
			NIL                                     ,;	// [09]  C   Consulta F3
			.T.                                     ,;	// [10]  L   Indica se o campo é alteravel
			NIL                                     ,;	// [11]  C   Pasta do campo
			"GRP_HZT_ALO"                           ,;	// [12]  C   Agrupamento do campo
			{}			                            ,;	// [13]  A   Lista de valores permitido do campo (Combo)
			0                                       ,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL                                     ,;	// [15]  C   Inicializador de Browse
			.T.                                     ,;	// [16]  L   Indica se o campo é virtual
			NIL                                     ,;	// [17]  C   Picture Variavel
			.F.                                      ;  // [18]  L   Indica pulo de linha após o campo
		)

		oView:AddField('VIEW_HZT', oStruHZT, 'HZTFIELDS')

		oStruHWSC := FWFormViewStruct():New()

		oStruHWSC:AddField("MARCA"   ,"01", ""     , ""     , {}, "L", "@BMP", Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
		oStruHWSC:AddField("HWS_CDMQ","02", STR0082, ""     , {}, "C", "@!"  , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.) //"Recurso"
		oStruHWSC:AddField("HWS_DSMQ","03", STR0009, STR0084, {}, "C", "@!"  , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.) //"Descrição" ###"Descrição do Recurso"
		
		oView:AddGrid('VIEW_HWSC', oStruHWSC, 'DETAIL_HWSC')
		oView:EnableTitleView('VIEW_HWSC', STR0082) //"Recurso"
	EndIf

	oView:addUserButton('Layout', "", {|oView| layout(oView, oView:GetValue("OXMASTER","OX_PRGAPON")) }, STR0054, /*[ nShortCut ]*/, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW}, .F.) //"Visualizar layout do formulário"

	oStruHWS := FWFormViewStruct():New()

	oStruHWS:AddField("MARCA"   ,"01", ""     , ""     , {}, "L", "@BMP", Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
	oStruHWS:AddField("HWS_CDMQ","02", STR0008, ""     , {}, "C", "@!"  , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.) //"Máquina"
	oStruHWS:AddField("HWS_DSMQ","03", STR0009, STR0011, {}, "C", "@!"  , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.) //"Descrição" ###"Descrição da Maquina"
	
	oView:AddGrid('VIEW_HWS', oStruHWS, 'DETAIL_HWS')
	
	oStruSMC := FWFormStruct(2, 'SMC')
	AltViewSMC(@oStruSMC)
	oView:AddGrid('VIEW_SMC', oStruSMC, 'DETAIL_SMC')

	//Struct do formulário de empenhos com os campos de permissão
	oStrSMJPms := FWFormStruct(2, 'SMJ', {|x| "|" + AllTrim(x) + "|" $ "|MJ_VISUAL|MJ_INCLUI|MJ_ALTERA|MJ_EXCLUI|"})
	oView:AddField('VIEW_SMJ_PERM', oStrSMJPms, 'SMJ_PERMISSAO')

	//Struct do formulário de empenhos com os campos do formulário.
	oStruSMJ := FWFormStruct(2, 'SMJ')
	oStruSMJ:RemoveField('MJ_VISUAL')
	oStruSMJ:RemoveField('MJ_INCLUI')
	oStruSMJ:RemoveField('MJ_ALTERA')
	oStruSMJ:RemoveField('MJ_EXCLUI')
	oStruSMJ:RemoveField('MJ_CODFORM')
	If oStruSMJ:HasField("MJ_POSIC")
		oStruSMJ:SetProperty('MJ_POSIC', MVC_VIEW_ORDEM, '01')
	EndIf

	oView:AddGrid('VIEW_SMJ', oStruSMJ, 'DETAIL_SMJ')

	oView:CreateHorizontalBox( 'BOX2', 210, , .T.) //Define o tamanho deste box como PIXELS
	oView:CreateHorizontalBox( 'BOX1', 100)
	oView:CreateVerticalBox( 'BOX_MESTRE', 100, 'BOX2')
	
	oView:CreateFolder('FOLDER5', 'BOX1')
	oView:AddSheet('FOLDER5', 'SHEET_CAMPOS'  , STR0017) //"Campos"
	oView:AddSheet('FOLDER5', 'SHEET_USUARIOS', STR0018) //"Usuarios"
	
	oView:CreateHorizontalBox('BOX_USUARIOS', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_USUARIOS')
	oView:CreateHorizontalBox('BOX_CAMPOS'  , 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_CAMPOS')
	
	oView:SetOwnerView('VIEW_SOX', 'BOX_MESTRE')
	oView:SetOwnerView('VIEW_SOZ', 'BOX_USUARIOS')
	oView:SetOwnerView('VIEW_SOY', 'BOX_CAMPOS')
	
	oView:AddSheet('FOLDER5', 'SHEET_MAQUINAS', STR0016) //"Maquinas"
	oView:CreateHorizontalBox('BOX_MAQUINAS', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_MAQUINAS')
	oView:SetOwnerView('VIEW_HWS', 'BOX_MAQUINAS')

	oView:AddSheet('FOLDER5', 'SHEET_CMP_CUSTOM', STR0020) //"Campos Customizados"
	oView:CreateHorizontalBox('BOX_CMP_CUSTOM', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'SHEET_CMP_CUSTOM')
	oView:SetOwnerView('VIEW_SMC', 'BOX_CMP_CUSTOM')

	oView:AddSheet('FOLDER5', 'SHEET_EMPENHOS', STR0031) //"Empenhos"

	oView:CreateHorizontalBox('BOX_EMPENHOS_PERM', 70, /*"owner"*/, .T., 'FOLDER5', 'SHEET_EMPENHOS')
	oView:SetOwnerView('VIEW_SMJ_PERM','BOX_EMPENHOS_PERM')
	
	oView:CreateHorizontalBox('BOX_EMPENHOS_FORM', 100, /*"owner"*/, .F., 'FOLDER5', 'SHEET_EMPENHOS')
	oView:SetOwnerView('VIEW_SMJ','BOX_EMPENHOS_FORM')

	If AliasInDic("HZT")
		oView:AddSheet('FOLDER5', 'SHEET_CRP', STR0074) //"CRP"
		oView:CreateHorizontalBox('BOX_CRP', 40, /*owner*/, .F., 'FOLDER5', 'SHEET_CRP')
		oView:SetOwnerView('VIEW_HZT', 'BOX_CRP')
		oView:CreateHorizontalBox('BOX_MAQUINAS_CRP', 60, /*owner*/, .F., 'FOLDER5', 'SHEET_CRP')
		oView:SetOwnerView('VIEW_HWSC', 'BOX_MAQUINAS_CRP')
	EndIf

	oView:SetAfterViewActivate({|oView| avalShtFld(oView)})

Return oView

Static Function AltViewSMC(oStruSMC)
	oStruSMC:RemoveField('MC_CODFORM')
	oStruSMC:SetProperty("MC_DESCAMP", MVC_VIEW_PICT, "")

	If oStruSMC:HasField("MC_POSIC")
		oStruSMC:SetProperty("MC_TPFORM", MVC_VIEW_CANCHANGE, .F.)
		oStruSMC:SetProperty("MC_TPFORM", MVC_VIEW_ORDEM, "01")
		oStruSMC:SetProperty("MC_POSIC" , MVC_VIEW_ORDEM, "02")
	Else
		oStruSMC:AddField("TPFORM"                              ,;	// [01]  C   Nome do Campo
						"01"                                    ,;	// [02]  C   Ordem
						STR0047                                 ,;	// [03]  C   Titulo do campo    //"Tp. Form."
						STR0048                                 ,;	// [04]  C   Descricao do campo //"Tipo Formulário"
						NIL                                     ,;	// [05]  A   Array com Help
						"C"                                     ,;	// [06]  C   Tipo do campo
						Nil                                     ,;	// [07]  C   Picture
						NIL                                     ,;	// [08]  B   Bloco de Picture Var
						NIL                                     ,;	// [09]  C   Consulta F3
						.F.                                     ,;	// [10]  L   Indica se o campo é alteravel
						NIL                                     ,;	// [11]  C   Pasta do campo
						NIL                                     ,;	// [12]  C   Agrupamento do campo
						{"1="+STR0043,"2="+STR0042,"3="+STR0044},;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                     ,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL                                     ,;	// [15]  C   Inicializador de Browse
						.T.                                     ,;	// [16]  L   Indica se o campo é virtual
						NIL                                     ,;	// [17]  C   Picture Variavel
						NIL                                      )  // [18]  L   Indica pulo de linha após o campo
	EndIf
Return

// ---------------------------------------------------------
/*/{Protheus.doc} loadMachines
Carrega máquinas de acordo com tipo do formulário
@author Parffit Jim Balsanelli
@since 01/09/2025
@version 1.0
/*/
// ---------------------------------------------------------
Static Function loadMachines(cFormType)
	Local aLoad      := {}
	Local cAliasTmp  := ""
	Local cQuery     := ""
	Local nField     := 0
	Local oModel     := FwModelActive()

	cAliasTmp := GetNextAlias()
	HWS->(dbSetOrder(1))

	If cFormType == "3"
		cQuery := " SELECT SH1.H1_CODIGO cdMaq, SH1.H1_DESCRI dsMaq"
		cQuery +=   " FROM " + RetSQLName("SH1") + " SH1 "
		cQuery +=  " WHERE SH1.H1_FILIAL = '" + xFilial("SH1") + "'"
		cQuery +=    " AND SH1.D_E_L_E_T_ = ' '"
	ElseIf cFormType == "4"
		cQuery := " SELECT CYB.CYB_CDMQ cdMaq, CYB.CYB_DSMQ dsMaq"
		cQuery +=   " FROM " + RetSQLName("CYB") + " CYB "
		cQuery +=  " WHERE CYB.CYB_FILIAL = '" + xFilial("CYB") + "'"
		cQuery +=    " AND CYB.D_E_L_E_T_ = ' '"
	EndIf
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTmp, .F., .T.)
	
	While (cAliasTmp)->(!EoF())
		nField++
		aAdd(aLoad,{ nField ,{} })

		If oModel:GetOperation() == 3
			aAdd(aLoad[nField, 2], .F.)
		Else				
			If HWS->(dbSeek(xFilial('HWS')+SOX->OX_FORM+(cAliasTmp)->cdMaq))
				aAdd(aLoad[nField][2], .T. )
			Else
				aAdd(aLoad[nField][2], .F. )
			EndIf
		EndIf

		AAdd(aLoad[nField][2], (cAliasTmp)->cdMaq )
		AAdd(aLoad[nField][2], (cAliasTmp)->dsMaq )

		(cAliasTmp)->(DbSkip())
	EndDO
	(cAliasTmp)->(dbCloseArea())
Return aLoad

// ---------------------------------------------------------
/*/{Protheus.doc} loadGridHWS
Carrega tabela HWS no modelo para inclusão
@author Parffit Jim Balsanelli
@since 01/09/2025
@version 1.0
/*/
// ---------------------------------------------------------
Static Function loadGridHWS(cComponentId, aLoad)
	Local nI         := 0
	Local oModel     := FwModelActive()
	Local oModelGrd  := oModel:GetModel(cComponentId)

	For nI := 1 to Len(aLoad)
		oModelGrd:SetNoInsertLine(.F.)
		oModelGrd:SetNoDeleteLine(.F.)

		oModelGrd:InitLine()
		oModelGrd:GoLine(1)

		If nI > 1
			oModelGrd:AddLine()
		Endif

		oModelGrd:GoLine(oModelGrd:Length())
		oModelGrd:LoadValue("MARCA"    ,aLoad[nI][2][1])
		oModelGrd:LoadValue("HWS_CDMQ" ,SubStr(aLoad[nI][2][2],1,10))
		oModelGrd:LoadValue("HWS_DSMQ" ,aLoad[nI][2][3])

		oModelGrd:SetNoInsertLine(.T.)
		oModelGrd:SetNoDeleteLine(.T.)
		oModelGrd:GoLine(1)
	Next
Return .T.

// ---------------------------------------------------------
/*/{Protheus.doc} LoadHWS
Carrega grid para edica das informacoes
@author Marcos Wagner Jr.
@since 12/05/2020
@version 1.0
/*/
// ---------------------------------------------------------
Static Function LoadHWS(lActivate)
	Local aLoad      := {}
	Local oModel     := FwModelActive()

	If lActivate .Or. oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") == "3" .Or. oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") == "4"
		If oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON") $ "|3|4|"
			aLoad := loadMachines(oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON"))
		Else
			IF oModel:GetOperation() == 3
				If AliasInDic("HZT")
					aLoad := loadMachines("3")
					loadGridHWS('DETAIL_HWSC', aLoad)
				EndIf

				aLoad := loadMachines("4")
				loadGridHWS('DETAIL_HWS', aLoad)
			EndIf
		EndIf
	EndIf
Return aLoad

Static Function VldPrgApon(oModel)
	Local aFolder    := {}
	Local cProgApont := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local cFolderAtu := ""
	Local oView      := FwViewActive()

	aFolder    := oView:GetFolderActive("FOLDER5", 2)
	cFolderAtu := aFolder[2]
	If cProgApont == "3"
		oView:SelectFolder("FOLDER5", STR0074, 2) //"CRP"		
	Else
		oView:HideFolder("FOLDER5", STR0074, 2) //"CRP"
	EndIf
	If cProgApont == "4"		
		oView:SelectFolder("FOLDER5", STR0016, 2) //"Maquinas"
	Else
		oView:HideFolder( "FOLDER5", STR0016, 2) //"Maquinas"
	EndIf
	If cProgApont == "6" .Or. cProgApont == "7"
		oView:HideFolder( "FOLDER5", STR0031, 2) //"Empenhos"
	Else
		oView:SelectFolder("FOLDER5", STR0031, 2) //"Empenhos"
	EndIf
	oView:SelectFolder("FOLDER5", STR0017, 2) //"Campos"
Return .T.

Function PCPA125EPa()
	Local lRet       := .F.
	Local oModel     := FWModelActive()
	Local cProgApont := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")

	If cProgApont == "3" .Or. cProgApont == "4"
		lRet := .T.
	EndIf
Return lRet

Function PCPA125ETp()
	Local lRet       := .T.
	Local oModel     := FWModelActive()

	If oModel:GetModel("OXMASTER"):GetValue("OX_CRONOM") != '1'
		lRet := .F.
		oModel:GetModel("OXMASTER"):ClearField("OX_TPPROG")
	EndIf
Return lRet

/*/{Protheus.doc} LinePosSMC
Validação de obrigatoriedade do campo descrição.
@type  Static Function
@author Christopher.miranda
@since 19/10/2020
/*/
Static Function LinePosSMC(oModel)
	Local lRet 		:= .T.
	Local oMdlSMC	:= oModel:GetModel("DETAIL_SMC")

	If oMdlSMC:GetValue("MC_VISIVEL") == "1" .And. Empty(oMdlSMC:GetValue("MC_DESCAMP"))
		Help(' ',1,"Help" ,,STR0021,2,0,,,,,,{STR0022})
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} atuVisEmp
Função chamada pela trigger dos campos MJ_INCLUI, MJ_ALTERA e MJ_EXCLUI para atualizar o valor do campo MJ_VISUAL

@type  Static Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel    , Object   , Referência do modelo de dados
@param cCmpOrigem, Character, Campo de origem que executou a trigger
@param cValor    , Character, Conteúdo do campo de origem
@return cValVisu , Character, Valor para o campo MJ_VISUAL
/*/
Static Function atuVisEmp(oModel, cCmpOrigem, cValor)
	Local cValVisu := oModel:GetValue("MJ_VISUAL")
	If cValor == "1" .And. cValVisu == "2"
		cValVisu := "1" 
	EndIf
Return cValVisu

/*/{Protheus.doc} A125WhnEmp
Função de avaliação de WHEN para o campo MJ_EDITA.

@type  Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnEmp(oModel, cCampo)
	Local lRet := .T.

	If "|" + AllTrim(oModel:GetValue("MJ_CAMPO")) + "|" $ "|D4_DTVALID|D4_OPORIG|D4_POTENCI|D4_PRODUTO|"
		lRet := .F.
	EndIf

	If lRet .And. ;
	   cCampo == "MJ_VALPAD" .And.;
	   AllTrim(oModel:GetValue("MJ_CAMPO")) == "D4_OPERAC" .And.;
	   oModel:GetModel():GetModel("OXMASTER"):GetValue("OX_PRGAPON") $ "|1|5|"
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} A125VldEmp
Função de validação para o campo MJ_EDITA.

@type  Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cField, Character, Campo que está sendo validado
@param cValue, Character, Valor do campo que está sendo validado
@param nLine , Numeric  , Linha da grid que está sendo manipulada
@return lRet , Logic    , Indica se o conteúdo do campo está válido ou não
/*/
Function A125VldEmp(oModel, cField, cValue, nLine)
	Local cTipoApon := oModel:GetModel():GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local lRet      := .T.

	If AllTrim(oModel:GetValue("MJ_CAMPO")) == "D4_OPERAC" .And. cValue == "1" .And. cTipoApon $ "|1|5|"
		Help(' ', 1, "Help",, STR0032,; //"Propriedade 'Editável' inválida para o campo 'D4_OPERAC'."
		     2, 0, , , , , , {STR0033}) //"O campo 'D4_OPERAC' somente pode ser editável quando o tipo de programa de apontamento for diferente de 'Produção simples' e 'Produção por item'."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} A125PropMJ
Adiciona ou remove as propriedades de validação da estrutura de dados da tabela SMJ.

@type  Function
@author lucas.franca
@since 03/03/2021
@version P12
@param oModel , Object   , Objeto do modelo de dados
@param oStruct, Object   , Objeto da estrutura de dados 
@param cOperac, Character, Indica se deve REMOVER ou ADICIONAR as propriedades.
@Return Nil
/*/
Function A125PropMJ(oModel, oStruct, cOperac)
	If cOperac == "ADICIONAR"
		oStruct:SetProperty('MJ_CAMPO' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".F.") )
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnEmp(a,b)"))
		oStruct:SetProperty('MJ_VALPAD', MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , "A125WhnEmp(a,b)"))
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "A125VldEmp(a,b,c,d)")) 

		oModel:SetNoInsertLine(.T.)
		oModel:SetNoDeleteLine(.T.)

	ElseIf cOperac == "REMOVER"
		oStruct:SetProperty('MJ_CAMPO' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
		oStruct:SetProperty('MJ_VALPAD', MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
		oStruct:SetProperty('MJ_EDITA' , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, ".T."))

		oModel:SetNoInsertLine(.F.)
		oModel:SetNoDeleteLine(.F.)
	EndIf
Return Nil

/*/{Protheus.doc} avalShtFld
Avalia a exibição da folder de Máquinas na abertura da VIEW

@type  Function
@author lucas.franca
@since 03/03/2021
@version P12
@param oView , Object   , Objeto da view
@Return Nil
/*/
Static Function avalShtFld(oView)
	Local cProgApont := oView:GetModel("OXMASTER"):GetValue("OX_PRGAPON")

	If !Empty(cProgApont)
		If cProgApont $ "|1|3|6|7|"
			oView:HideFolder("FOLDER5", STR0016, 2) //"Maquinas"
		EndIf
		If cProgApont $ "|6|7|"
			oView:HideFolder("FOLDER5", STR0031, 2) //"Empenhos"
		EndIf
		If cProgApont $ "|1|4|6|7|"
			oView:HideFolder("FOLDER5", STR0074, 2) //"CRP"
		EndIf
	Else
		oView:HideFolder("FOLDER5", STR0016, 2) //"Maquinas"
		oView:HideFolder("FOLDER5", STR0031, 2) //"Empenhos"
		oView:HideFolder("FOLDER5", STR0074, 2) //"CRP"
	EndIf
	oView:SelectFolder("FOLDER5", STR0017, 2) //"Campos"
Return

/*/{Protheus.doc} A125VldPAD
Função de validação para o campo MC_VALPAD.

@type  Function
@author renan.roeder
@since 03/11/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cField, Character, Campo que está sendo validado
@param cValue, Character, Valor do campo que está sendo validado
@param nLine , Numeric  , Linha da grid que está sendo manipulada
@return lRet , Logic    , Indica se o conteúdo do campo está válido ou não
/*/
Function A125VldPAD(oModel, cField, cValue, nLine)
	Local lRet      := .T.
	Local cTabela   := ""
	Local aDadosSX5 := {}

	If "CustomFieldList" $ oModel:GetValue("MC_TIPO", nLine)
		cTabela   := AllTrim(oModel:GetValue("MC_TABELA", nLine))
		aDadosSX5 := FWGetSX5(cTabela, RTrim(cValue))

		If !Empty(cTabela) .And. Len(aDadosSX5) == 0
			Help(' ',1,"Help" ,, STR0035 + "'" + RTrim(cValue) + "'" + STR0036 + "'" + cTabela + "'.",; //"O Valor Padrão '" + AllTrim(cValue) + "' não pertence a Tabela '" + cTabela + "'."
					2,0,,,,,,{STR0037})	//"O Valor Padrão deve pertencer a tabela selecionada."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} A125UPDATE
Atualiza o cadastro dos formulários com novas funcionalidades
@type Function
@author renan.roeder
@since 25/07/2023
@version P12
@return lRet, lógico, Indica se as atualizações foram feitas
/*/
Function A125UPDATE()
	Local aCampos    := {}
	Local bErrorBloc := ErrorBlock({|e| A125BERROR(e), Break(e) })
	Local cAlias     := GetNextAlias()
	Local cAliasTab  := ""
	Local cTpForm    := ""
	Local lRet       := .T.
	Local nIndice    := 0
	Local nSOYPosic  := 0
	Local nSMJPosic  := 0

	Begin Transaction
		Begin Sequence
			LOADEMPSMC()
			aAdd(aCampos,{"CustomFieldButton01","_CCBT01"})
			aAdd(aCampos,{"CustomFieldButton02","_CCBT02"})
			aAdd(aCampos,{"CustomFieldButton03","_CCBT03"})
			aAdd(aCampos,{"CustomFieldButton04","_CCBT04"})
			aAdd(aCampos,{"CustomFieldButton05","_CCBT05"})
			dbSelectArea("SOY")
			If FieldPos("OY_POSIC") > 0
				SMC->(dbSetOrder(3))
				If !SMC->(dbSeek(xFilial("SMC")+"CustomFieldButton01"))
					BeginSql Alias cAlias
						SELECT DISTINCT SMC.MC_FILIAL, SMC.MC_CODFORM, SOX.OX_PRGAPON
						FROM %Table:SMC% SMC
						INNER JOIN %Table:SOX% SOX ON SOX.OX_FILIAL = %xFilial:SOX% AND SOX.OX_FORM = SMC.MC_CODFORM
						WHERE SMC.MC_FILIAL = %xFilial:SMC%
						AND SMC.%NotDel%
						ORDER BY SMC.MC_FILIAL,SMC.MC_CODFORM
					EndSql
					While (cAlias)->(!Eof())
						nSOYPosic := 0
						nSMJPosic := 0
						cTpForm   := IIF((cAlias)->OX_PRGAPON $ "12345","1","3")
						cAliasTab := RETALIASTB((cAlias)->OX_PRGAPON,cTpForm)				
						For nIndice := 1 To Len(aCampos)
							INSERTSMC((cAlias)->MC_CODFORM,aCampos[nIndice][1],cAliasTab+aCampos[nIndice][2],cTpForm)
							If cTpForm == "1"
								INSERTSMC((cAlias)->MC_CODFORM,aCampos[nIndice][1],"D4"+aCampos[nIndice][2],"2")
							EndIf
						Next nIndice
						If cTpForm == "1"
							lRet := UPDSMJPOS((cAlias)->MC_CODFORM,@nSMJPosic)
						EndIf
						If lRet				
							lRet := UPDSOYPOS((cAlias)->MC_CODFORM,(cAlias)->OX_PRGAPON,@nSOYPosic)
							If lRet
								lRet := UPDSMCPTF((cAlias)->MC_CODFORM,(cAlias)->OX_PRGAPON,nSOYPosic,nSMJPosic)
							EndIf
						EndIf
						If !lRet
							DisarmTransaction()
							Exit
						EndIf			
						(cAlias)->(dbSkip())
					End
					(cAlias)->(DbCloseArea())
				EndIf
			EndIf
		Recover
			lRet := .F.
		End Sequence
	End Transaction
	ErrorBlock(bErrorBloc)
	FwFreeArray(aCampos)
Return lRet

Static Function A125REGLOG(cFuncao,cErro,cContexto)
	Local cMessage := AllTrim(cFuncao) + CHR(10) + AllTrim(cErro)
	
	LogMsg("PCPA125", 0, 0, 1, '', '', Replicate("-",70) + CHR(10) + cMessage + CHR(10) + Replicate("-",70))
Return

/*/{Protheus.doc} A125BERROR
Função executada quando a transação cai em exceção
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param	e, objeto, Objeto com os dados do erro
@return Nil
/*/
Static Function A125BERROR(e)
	Local cMessage := AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack)
	
    LogMsg("PCPA125", 0, 0, 1, '', '', Replicate("-",70) + CHR(10) + cMessage + CHR(10) + Replicate("-",70))
	If InTransact()
		DisarmTransaction()
	EndIf
Return

/*/{Protheus.doc} UPDSMJPOS
Atualiza o conteúdo do campo MJ_POSIC
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cCodForm , caracter, Código do formulário
@param  nSMJPosic, numérico, Última posição dos campos de empenho
@return lRet     , lógico  , Indica se as atualizações foram feitas
/*/
Static Function UPDSMJPOS(cCodForm,nSMJPosic)
	Local aCampos := {}
	Local lRet    := .T.
	Local nIndice := 0
	
	aCampos := {"D4_COD"    ,"D4_LOCAL"  ,"D4_DATA"   ,"D4_QTDEORI","D4_QUANT"  ,"D4_TRT",;
	            "D4_LOTECTL","D4_NUMLOTE","D4_DTVALID","D4_OPORIG" ,"D4_QTSEGUM","D4_POTENCI",;
			    "D4_SEQ"    ,"D4_EMPROC" ,"D4_PRODUTO","D4_OPERAC" ,"D4_PRDORG"}

	For nIndice := 1 To Len(aCampos)
		nSMJPosic := nIndice * 10
		cSql := " UPDATE " + RetSqlName("SMJ") + " SET "
		cSql += "  MJ_POSIC = " + cValToChar(nSMJPosic) + " "
		cSql += " WHERE "
		cSql += "  MJ_FILIAL = '"+xFilial("SMJ")+"' AND "
		cSql += "  MJ_CODFORM = '"+cCodForm+"' AND "
		cSql += "  MJ_CAMPO = '"+aCampos[nIndice]+"' "
		If TCSQLExec(cSql) < 0
			A125REGLOG("UPDSMJPOS",TCSQLError())
			lRet := .F.
			Exit
		EndIf	
	Next nIndice
	FwFreeArray(aCampos)
Return lRet

/*/{Protheus.doc} UPDSMCPTF
Realiza a gestão da Atualização dos campos MC_TPFORM e MC_POSIC
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cCodForm , caracter, Código do formulário
@param  cPrgApon , caracter, Código do programa de apontamento
@param  nSOYPosic, numérico, Última posição dos campos padrões
@param  nSMJPosic, numérico, Última posição dos campos de empenho
@return lRet     , lógico  , Indica se as atualizações foram feitas
/*/
Static Function UPDSMCPTF(cCodForm,cPrgApon,nSOYPosic,nSMJPosic)
	Local lRet := .T.
	//REFATORAR
	Do Case
		Case cPrgApon == "1"
			lRet := EXECUPDSMC(cCodForm, "D3",nSOYPosic)
			If lRet
				lRet := EXECUPDSMC(cCodForm, "D4",nSMJPosic)
			EndIf
		Case cPrgApon == "3"
			lRet := EXECUPDSMC(cCodForm, "H6",nSOYPosic)
			If lRet
				lRet := EXECUPDSMC(cCodForm, "D4",nSMJPosic)
			EndIf
		Case cPrgApon == "4"
			lRet := EXECUPDSMC(cCodForm, "CYV",nSOYPosic)
			If lRet
				lRet := EXECUPDSMC(cCodForm, "D4",nSMJPosic)
			EndIf
		Case cPrgApon == "6"
			lRet := EXECUPDSMC(cCodForm, "C2",nSOYPosic)
	EndCase
Return lRet

/*/{Protheus.doc} UPDSMCPTF
Atualiza o conteúdo dos campos MC_TPFORM e MC_POSIC
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cCodForm , caracter, Código do formulário
@param  cAlias   , caracter, Alias da tabela que relaciona ao tipo de formulário
@param  nUltPosic, numérico, Posição onde os campos customizados devem começar
@return lRet     , lógico  , Indica se as atualizações foram feitas
/*/
Static Function EXECUPDSMC(cCodForm,cAlias,nUltPosic)
	Local cAliasQry  := GetNextAlias()
	Local cTpForm    := ""
	Local cVisivel   := "1"
	Local lRet       := .T.

	cTpForm := RETTPFORM(cAlias)
	cSql := " UPDATE " + RetSqlName("SMC") + " SET "
	cSql += "  MC_TPFORM = '" + cTpForm + "' "
	cSql += " WHERE "
	cSql += "  MC_FILIAL = '" + xFilial("SMC") + "' AND "
	cSql += "  MC_CODFORM = '" + cCodForm + "' AND "
	cSql += "  MC_CAMPO LIKE '" + cAlias + "%' AND "
	cSql += "  D_E_L_E_T_ = ' ' "
	If TCSQLExec(cSql) < 0
		A125REGLOG("EXECUPDSMC",TCSQLError())
		lRet := .F.
	EndIf
	If lRet
		BeginSql Alias cAliasQry
			SELECT SMC.R_E_C_N_O_ AS RECNO
			FROM %Table:SMC% SMC
			WHERE SMC.MC_FILIAL = %xFilial:SMC%
			AND SMC.MC_CODFORM = %Exp:cCodForm%
			AND SMC.MC_TPFORM = %Exp:cTpForm%
			AND SMC.MC_VISIVEL = %Exp:cVisivel%
			AND SMC.%NotDel%
			ORDER BY %Order:SMC,1%
		EndSql
		SMC->(dbSelectArea("SMC"))
		While (cAliasQry)->(!Eof())
			nUltPosic += 10
			SMC->(dbGoTo((cAliasQry)->RECNO))
			RecLock("SMC",.F.)
			SMC->MC_POSIC := nUltPosic
			SMC->(MsUnLock())
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(DbCloseArea())
	EndIf
Return lRet

/*/{Protheus.doc} UPDSOYPOS
Atualiza o conteúdo do campo OY_POSIC
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cCodForm , caracter, Código do formulário
@param  cPrgApon , caracter, Código do programa de apontamento
@param  nUltPosic, numérico, Posição onde os campos customizados devem começar
@return lRet     , lógico  , Indica se as atualizações foram feitas
/*/
Static Function UPDSOYPOS(cCodForm,cPrgApon,nUltPosic)
	Local aCampos := {}
	Local cSql    := ""
	Local lRet    := .T.
	Local nIndice := 0

	A125CMPPAD(cPrgApon,@aCampos)
	If cPrgApon $ "|1|3|4|6|"
		For nIndice := 1 To Len(aCampos)
			If !Empty(aCampos[nIndice])
				nUltPosic := nIndice * 10
				cSql := " UPDATE " + RetSqlName("SOY") + " SET "
				cSql += "  OY_POSIC = " + cValToChar(nUltPosic) + " "
				cSql += " WHERE "
				cSql += "  OY_FILIAL = '"+xFilial("SOY")+"' AND "
				cSql += "  OY_CODFORM = '"+cCodForm+"' AND "
				cSql += "  OY_CAMPO = '"+aCampos[nIndice]+"' "
				If TCSQLExec(cSql) < 0
					A125REGLOG("UPDSOYPOS",TCSQLError())
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nIndice
	EndIf
	FwFreeArray(aCampos)
Return lRet

/*/{Protheus.doc} INSERTSMC
Insere os registros do tipo CustomFieldButton na tabela
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cCodForm, caracter, Código do formulário
@param  cTipo   , caracter, Tipo do campo customizado
@param  cCampo  , caracter, Nome do campos customizado na tabela
@param  cTpForm , caracter, Tipo do formulário customizado
@return Nil
/*/
Static Function INSERTSMC(cCodForm,cTipo,cCampo,cTpForm)
	RecLock('SMC',.T.)
		SMC->MC_FILIAL  := xFilial("SMC")
		SMC->MC_CODFORM := cCodForm
		SMC->MC_TIPO    := cTipo
		SMC->MC_CAMPO   := cCampo
		SMC->MC_DESCAMP := ""
		SMC->MC_CODBAR  := "2"
		SMC->MC_VISIVEL := "2"
		SMC->MC_EDITA   := "2"
		SMC->MC_VALPAD  := ""
		SMC->MC_TABELA  := ""
		If !Empty(cTpForm)
			SMC->MC_TPFORM  := cTpForm
			SMC->MC_POSIC   := 0
		EndIf
	SMC->(MsUnlock())
Return

/*/{Protheus.doc} RETTPFORM
Retorna o tipo do formulário - 1-Apontamento/2-Empenho/3-OP
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cAlias , caracter, Alias da tabela que relaciona ao tipo de formulário
@return cTpForm, caracter, Tipo do formulário (MC_TPFORM)
/*/
Static Function RETTPFORM(cAlias)
	Local cTpForm := ""
	
	Do Case
		Case cAlias $ "D3|H6|CYV"
			cTpForm := "1"
		Case cAlias == "D4"
			cTpForm := "2"
		Otherwise
			cTpForm := "3"
	EndCase
Return cTpForm

/*/{Protheus.doc} RETALIASTB
Retorna o alias da tabela na lista de campos customizados
@type Static Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cPrgApon, caracter, Código do programa de apontamento
@param  cTpForm , caracter, Tipo do formulário customizado
@return cAlias  , caracter, Alias da tabela
/*/
Static Function RETALIASTB(cPrgApon,cTpForm)
	Local cAlias := ""

	If cTpForm == "1"
		If cPrgApon == "1" .Or. cPrgApon == "5"
			cAlias := "D3"
		ElseIf cPrgApon == "2" .Or. cPrgApon == "3"
			cAlias := "H6"
		Else
			cAlias := "CYV"		
		EndIf
	Else
		cAlias := "C2"
	EndIf
Return cAlias

/*/{Protheus.doc} LOADEMPSMC
Inclui na base de dados os registros customizados para o formulário de empenhos, caso não exista
@type Static Function
@author renan.roeder
@since 31/07/2023
@version P12
@return Nil
/*/
Static Function LOADEMPSMC()
	Local aCamposSMC := {}
	Local nIndice    := 0
	Local cAlias     := GetNextAlias()	
	Local cQuery     := ""

	ARRCAMPSMC(@aCamposSMC)
	cQuery := " SELECT "
	cQuery += " 	SOX.OX_FILIAL,SOX.OX_FORM,SOX.OX_PRGAPON "
	cQuery += " FROM "+RetSqlName("SOX")+" SOX "
	cQuery += " WHERE SOX.OX_FILIAL = '"+xFilial("SOX")+"' "
	cQuery += "   AND (SOX.OX_PRGAPON <> '6' AND SOX.OX_PRGAPON <> '7') "
	cQuery += "   AND SOX.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NOT EXISTS (SELECT SMC.MC_CAMPO FROM "+RetSqlName("SMC")+" SMC WHERE SMC.MC_FILIAL = '"+xFilial("SMC")+"' AND SMC.MC_CODFORM = SOX.OX_FORM AND SMC.MC_CAMPO LIKE 'D4_%' AND SMC.D_E_L_E_T_ = ' ') "
	cQuery += " ORDER BY SOX.OX_FILIAL,SOX.OX_FORM "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
	While (cAlias)->(!Eof())
		For nIndice := 1 To Len(aCamposSMC)
			INSERTSMC((cAlias)->OX_FORM,aCamposSMC[nIndice][1],aCamposSMC[nIndice][2])
		Next nIndice
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())
	FwFreeArray(aCamposSMC)
Return

/*/{Protheus.doc} ARRCAMPSMC
Inclui no array a lista de campos customizados para o formulário de empenhos
@type Static Function
@author renan.roeder
@since 31/07/2023
@version P12
@param  aCamposSMC, Array, Array passado por referência para receber a lista de campos
@return Nil
/*/
Static Function ARRCAMPSMC(aCamposSMC)
	Aadd(aCamposSMC, {"CustomFieldCharacter01","D4_CCCA01"})
	Aadd(aCamposSMC, {"CustomFieldCharacter02","D4_CCCA02"})
	Aadd(aCamposSMC, {"CustomFieldCharacter03","D4_CCCA03"})
	Aadd(aCamposSMC, {"CustomFieldCharacter04","D4_CCCA04"})
	Aadd(aCamposSMC, {"CustomFieldCharacter05","D4_CCCA05"})
	Aadd(aCamposSMC, {"CustomFieldDecimal01"  ,"D4_CCDE01"})
	Aadd(aCamposSMC, {"CustomFieldDecimal02"  ,"D4_CCDE02"})
	Aadd(aCamposSMC, {"CustomFieldDecimal03"  ,"D4_CCDE03"})
	Aadd(aCamposSMC, {"CustomFieldDecimal04"  ,"D4_CCDE04"})
	Aadd(aCamposSMC, {"CustomFieldDecimal05"  ,"D4_CCDE05"})
	Aadd(aCamposSMC, {"CustomFieldDate01"	  ,"D4_CCDA01"})
	Aadd(aCamposSMC, {"CustomFieldDate02"	  ,"D4_CCDA02"})
	Aadd(aCamposSMC, {"CustomFieldDate03"	  ,"D4_CCDA03"})
	Aadd(aCamposSMC, {"CustomFieldDate04"	  ,"D4_CCDA04"})
	Aadd(aCamposSMC, {"CustomFieldDate05"	  ,"D4_CCDA05"})
	Aadd(aCamposSMC, {"CustomFieldLogical01"  ,"D4_CCLO01"})
	Aadd(aCamposSMC, {"CustomFieldLogical02"  ,"D4_CCLO02"})
	Aadd(aCamposSMC, {"CustomFieldLogical03"  ,"D4_CCLO03"})
	Aadd(aCamposSMC, {"CustomFieldLogical04"  ,"D4_CCLO04"})
	Aadd(aCamposSMC, {"CustomFieldLogical05"  ,"D4_CCLO05"})
	Aadd(aCamposSMC, {"CustomFieldList01"	  ,"D4_CCLI01"})
	Aadd(aCamposSMC, {"CustomFieldList02"	  ,"D4_CCLI02"})
	Aadd(aCamposSMC, {"CustomFieldList03"	  ,"D4_CCLI03"})
	Aadd(aCamposSMC, {"CustomFieldList04"	  ,"D4_CCLI04"})
	Aadd(aCamposSMC, {"CustomFieldList05"	  ,"D4_CCLI05"})
Return

Function A125COBERT()
	EXECUPDSMC("COBERTURA","COBERTURA",0)
Return

/*/{Protheus.doc} getEmpenho
Monta array com os empenhos e campos customizados do tipo empenho, adicionando na grid de layout
@type Static Function
@author douglas.heydt
@since 10/11/2023
@version P12
@return Nil
/*/
Static Function getEmpenho()
	Local aCampos   := {}
	Local nX        := 0
	Local oModel    := FwModelActive()
	Local oGrdSMJ   := oModel:GetModel('DETAIL_SMJ')
	Local oGrdSMC   := oModel:GetModel('DETAIL_SMC')
	Local oGrdEmp   := oModel:GetModel('PCPA125_SMJ_EMPENHOS')
	Local nLinesSMJ := oGrdSMJ:Length(.T.)
	Local nLinesSMC := oGrdSMC:Length(.T.)
	
	For nX := 1 To nLinesSMJ
		If oGrdSMJ:GetValue("MJ_VISIVEL", nX) == "1"
			aAdd(aCampos, {oGrdSMJ:GetValue("MJ_POSIC", nX), oGrdSMJ:GetValue("MJ_DESCAMP", nX)})
		EndIf
	Next nX

	For nX := 1 To nLinesSMC
		If oGrdSMC:GetValue("MC_VISIVEL", nX) == "1" .AND. oGrdSMC:GetValue("MC_TPFORM", nX) == "2"
			If "Button" $ oGrdSMC:GetValue("MC_TIPO", nX)
				aAdd(aCampos, {oGrdSMC:GetValue("MC_POSIC", nX), STR0055+oGrdSMC:GetValue("MC_DESCAMP ", nX)}) //"Botão "
			else
				aAdd(aCampos, {oGrdSMC:GetValue("MC_POSIC", nX), oGrdSMC:GetValue("MC_DESCAMP ", nX)})
			EndIf
		EndIf
	Next nX

	aSort(aCampos, , , {|x, y| x[1] < y[1]})

	For nX := 1 To Len(aCampos)
		oGrdEmp:LoadValue("MJ_POSIC", aCampos[nX][1])
		oGrdEmp:LoadValue("MJ_DESCAMP", aCampos[nX][2])
		If nX < Len(aCampos)
			oGrdEmp:AddLine()
		EndIf
	Next nX
Return

/*/{Protheus.doc} getCampos
Monta array com os campos padrões e campos customizados que sejam visíveis, adicionando na grid de layout
@type Static Function
@author douglas.heydt
@since 31/07/2023
@version P12
@return Nil
/*/
Static Function getCampos()
	Local aCampos    := {}
	Local nX         := 0
	Local oModel     := FwModelActive()
	Local oGrdSOY    := oModel:GetModel('DETAIL_SOY')
	Local oGrdSMC    := oModel:GetModel('DETAIL_SMC')
	Local oGrdLayout := oModel:GetModel('PCPA125_SOY_CAMPOS')
	Local nLinesSOY  := oGrdSOY:Length(.T.)
	Local nLinesSMC  := oGrdSMC:Length(.T.)

	For nX := 1 To nLinesSOY
		If oGrdSOY:GetValue("OY_VISIVEL", nX) == "1"
			aAdd(aCampos, {oGrdSOY:GetValue("OY_POSIC", nX), oGrdSOY:GetValue("OY_DESCAMP", nX)})
		EndIf
	Next nX

	For nX := 1 To nLinesSMC
		If oGrdSMC:GetValue("MC_VISIVEL", nX) == "1" .AND. oGrdSMC:GetValue("MC_TPFORM", nX) != "2"
			If "Button" $ oGrdSMC:GetValue("MC_TIPO", nX)
				aAdd(aCampos, {oGrdSMC:GetValue("MC_POSIC", nX), STR0055+oGrdSMC:GetValue("MC_DESCAMP ", nX)}) //"Botão "
			else
				aAdd(aCampos, {oGrdSMC:GetValue("MC_POSIC ", nX) , oGrdSMC:GetValue("MC_DESCAMP ", nX)})
			EndIf
		EndIf
	Next nX

	aSort(aCampos, , , {|x, y| x[1] < y[1]})

	For nX := 1 To Len(aCampos)
		oGrdLayout:LoadValue("OY_POSIC", aCampos[nX][1])
		oGrdLayout:LoadValue("OY_DESCAMP", aCampos[nX][2])
		If nX < Len(aCampos)
			oGrdLayout:AddLine()
		EndIf
	Next nX
Return

/*/{Protheus.doc} layout
Cria grid Layout para exibir a ordem dos campos criados no app
@type Static Function
@author douglas.heydt
@since 10/11/2023
@version P12
@param  oViewPai, FWFormView, View geral da tela
@param cPrgApon , caracter  , Tipo de formulário selecionado
@return lRet    , Logico    , Indica se conseguiu exibir a tela
/*/
Static Function layout(oViewPai, cPrgApon)
	Local oStruSOY  := FWFormStruct(2, "SOY", {|x| "|" + AllTrim(x) + "|" $ "|OY_POSIC|OY_DESCAMP|"})
	Local oStruSMJ  := FWFormStruct(2, "SMJ", {|x| "|" + AllTrim(x) + "|" $ "|MJ_POSIC|MJ_DESCAMP|"})
	
	Local oView 	:= Nil
	Local oViewExec := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	
	If oModel:GetOperation() != MODEL_OPERATION_VIEW
		oModel:GetModel("PCPA125_SOY_CAMPOS"):ClearData(.F.,.T.)
		oModel:GetModel("PCPA125_SMJ_EMPENHOS"):ClearData(.F.,.T.)
	EndIf

	If cPrgApon == "6" .Or. cPrgApon == "7"
		oView:AddGrid("LAYOUT_SOY", oStruSOY, "PCPA125_SOY_CAMPOS")
		oView:EnableTitleView("LAYOUT_SOY", setTitulo(oView:GetValue("OXMASTER","OX_PRGAPON")))
		oView:CreateVerticalBox("BOX_LAYOUT_SOY",100,,.F.)
		oView:SetOwnerView("LAYOUT_SOY", 'BOX_LAYOUT_SOY')
		oStruSOY:SetProperty('OY_POSIC', MVC_VIEW_ORDEM, '01')
		oStruSOY:SetProperty("OY_DESCAMP", MVC_VIEW_WIDTH, 150)
		oStruSOY:SetProperty("OY_DESCAMP", MVC_VIEW_PICT, "")

		If oModel:GetOperation() != MODEL_OPERATION_VIEW
			getCampos()
		EndIf

		oModel:getModel('PCPA125_SOY_CAMPOS'):SetNoInsertLine(.T.)
		oModel:getModel('PCPA125_SOY_CAMPOS'):SetNoUpdateLine(.T.)
	Else
		oView:AddGrid("LAYOUT_SOY", oStruSOY, "PCPA125_SOY_CAMPOS")
		oView:AddGrid("LAYOUT_SMJ", oStruSMJ, "PCPA125_SMJ_EMPENHOS")

		oView:EnableTitleView("LAYOUT_SOY", setTitulo(oView:GetValue("OXMASTER","OX_PRGAPON")))
		oView:EnableTitleView("LAYOUT_SMJ", STR0031) //"Empenhos"

		oView:CreateVerticalBox("BOX_LAYOUT_SOY",49,,.F.)
		oView:CreateVerticalBox("ESPACO",2,,.F.)
		oView:CreateVerticalBox("BOX_LAYOUT_SMJ",49,,.F.)

		oView:SetOwnerView("LAYOUT_SOY", 'BOX_LAYOUT_SOY')
		oView:SetOwnerView("LAYOUT_SMJ", 'BOX_LAYOUT_SMJ')

		oStruSOY:SetProperty('OY_POSIC', MVC_VIEW_ORDEM, '01')
		oStruSMJ:SetProperty('MJ_POSIC', MVC_VIEW_ORDEM, '01')

		oStruSOY:SetProperty("OY_DESCAMP", MVC_VIEW_WIDTH, 150)
		oStruSMJ:SetProperty('MJ_DESCAMP', MVC_VIEW_WIDTH, 150)

		oStruSOY:SetProperty("OY_DESCAMP", MVC_VIEW_PICT, "")
		
		If oModel:GetOperation() != MODEL_OPERATION_VIEW
			getCampos()
			getEmpenho()
		EndIf
		
		/*trava e edição das grids*/
		oModel:getModel('PCPA125_SOY_CAMPOS'):SetNoInsertLine(.T.)
		oModel:getModel('PCPA125_SMJ_EMPENHOS'):SetNoInsertLine(.T.)
		oModel:getModel('PCPA125_SOY_CAMPOS'):SetNoUpdateLine(.T.)
		oModel:getModel('PCPA125_SMJ_EMPENHOS'):SetNoUpdateLine(.T.)
	EndIf
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	 	oViewExec:setModel(oModel)
	  	oViewExec:setView(oView)
	  	oViewExec:setTitle(STR0063) //"Lista"
	  	oViewExec:setReduction(70)
	  	oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0062},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Fechar"
	  	oViewExec:SetCloseOnOk({|| .T.})
	  	oViewExec:SetModal(.T.)
	  	oViewExec:openView(.F.)
		
		/*libera a edição das grids */
		If cPrgApon == "6" .Or. cPrgApon == "7"
			oModel:GetModel('PCPA125_SOY_CAMPOS'):SetNoInsertLine(.F.)
			oModel:GetModel('PCPA125_SOY_CAMPOS'):SetNoUpdateLine(.F.)
		Else
			oModel:GetModel('PCPA125_SOY_CAMPOS'):SetNoInsertLine(.F.)
			oModel:GetModel('PCPA125_SMJ_EMPENHOS'):SetNoInsertLine(.F.)
			oModel:GetModel('PCPA125_SOY_CAMPOS'):SetNoUpdateLine(.F.)
			oModel:GetModel('PCPA125_SMJ_EMPENHOS'):SetNoUpdateLine(.F.)
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} setTitulo
Retorna o string de título para grid de layout de campos
@type Static Function
@author douglas.heydt
@since 10/11/2023
@version P12
@param  cPrgApon, Caracter, Codigo do tipo de apontamento
@return cTitulo , Caracter, Titulo do tipo de apontamento
/*/
Static Function setTitulo(cPrgApon)
	Local cTitulo := ""

	Do Case
        Case cPrgApon == "1"
            cTitulo := STR0056 //"Produção Simples"
        Case cPrgApon == "3"
            cTitulo := STR0058 //"Produção Pcp Mod2"
        Case cPrgApon == "4"
			cTitulo := STR0059 //"Produção Chão de Fabrica"
		Case cPrgApon == "6"
			cTitulo := STR0061 //"Ordem de Produção"
		Case cPrgApon == "7"
			cTitulo := STR0064 //"Apontamento da perda"
    EndCase
Return cTitulo

/*/{Protheus.doc} A125LoadC
Função para carregar a grid de campos da opção Layout
@author douglas.heydt
@param  oModel, Modelo da rotina
@since 20/12/2023
@version 1.0
/*/
Static Function A125LoadC(oModel)
	Local aCampos    := {}
	Local aLoad      := {}
	Local cAliasCamp := GetNextAlias()
	Local cAliasCust := GetNextAlias()
	Local cCodForm   := ""
	Local cQueryCamp := ""
	Local cQueryCust := ""
	Local nX         := 0

	If oModel != Nil
		cCodForm   := Alltrim(oModel:GetValue("OXMASTER","OX_FORM"))
		cQueryCamp := " SELECT  OY_FILIAL,OY_CODFORM, OY_DESCAMP, OY_POSIC FROM "+RetSqlName("SOY")+" "
		cQueryCamp += "   WHERE OY_FILIAL = '"+xFilial("SOY")+"' "
		cQueryCamp += "     AND OY_CODFORM = '"+cCodForm+"' "
		cQueryCamp += "     AND OY_VISIVEL = '1' "
		cQueryCamp += "     AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCamp),cAliasCamp,.T.,.T.)
		While (cAliasCamp)->(!Eof())
			aadd(aCampos, {(cAliasCamp)->OY_DESCAMP, (cAliasCamp)->OY_POSIC} )
			(cAliasCamp)->(dbSkip())
		End
		(cAliasCamp)->(dbCloseArea())

		cQueryCust := " SELECT MC_FILIAL, MC_CODFORM, MC_DESCAMP, MC_TPFORM, MC_POSIC, MC_TIPO FROM "+RetSqlName("SMC")+" "
		cQueryCust += "   WHERE MC_FILIAL = '"+xFilial("SMC")+"' "
		cQueryCust += "     AND MC_CODFORM = '"+cCodForm+"' "
		cQueryCust += "     AND MC_VISIVEL = '1' "
		cQueryCust += "     AND MC_TPFORM <> '2' "
		cQueryCust += "     AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCust),cAliasCust,.T.,.T.)
		While (cAliasCust)->(!Eof())
			If "Button" $ (cAliasCust)->MC_TIPO
				aadd(aCampos, {STR0055+(cAliasCust)->MC_DESCAMP, (cAliasCust)->MC_POSIC} )
			Else
				aadd(aCampos, {(cAliasCust)->MC_DESCAMP, (cAliasCust)->MC_POSIC} )
			EndIf
			(cAliasCust)->(dbSkip())
		End
		(cAliasCust)->(dbCloseArea())
		aSort(aCampos, , , {|x, y| x[2] < y[2]})
		For nX := 1 To Len(aCampos)
			aadd(aLoad, {0, aCampos[nX]}  )
		Next nX
	EndIf
Return aLoad

/*/{Protheus.doc} A125LoadE
Função para carregar a grid de empenhos da opção Layout
@author douglas.heydt
@param  oModel, Modelo da rotina
@since 20/12/2023
@version 1.0
/*/
Static Function A125LoadE(oModel)
	Local aLoad      := {}
	Local aEmpenhos  := {}
	Local cAliasCust := GetNextAlias()
	Local cAliasEmp  := GetNextAlias()
	Local cCodForm   := ""
	Local cQueryCust := ""
	Local cQueryEmp  := ""
	Local nX         := 0

	If oModel != Nil
		cCodForm   := Alltrim(oModel:GetValue("OXMASTER","OX_FORM"))
		cQueryEmp := " SELECT MJ_FILIAL, MJ_CODFORM, MJ_DESCAMP, MJ_POSIC, MJ_VISIVEL FROM "+RetSqlName("SMJ")+" "
		cQueryEmp += "   WHERE MJ_FILIAL = '"+xFilial("SMJ")+"' "
		cQueryEmp += "     AND MJ_CODFORM = '"+cCodForm+"' "
		cQueryEmp += "     AND MJ_VISIVEL = '1' "
		cQueryEmp += "     AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryEmp),cAliasEmp,.T.,.T.)
		While (cAliasEmp)->(!Eof())
			aadd(aEmpenhos, {(cAliasEmp)->MJ_DESCAMP, (cAliasEmp)->MJ_POSIC} )
			(cAliasEmp)->(dbSkip())
		End
		(cAliasEmp)->(dbCloseArea())

		cQueryCust := " SELECT MC_FILIAL, MC_CODFORM, MC_DESCAMP, MC_TPFORM, MC_POSIC, MC_TIPO FROM "+RetSqlName("SMC")+" "
		cQueryCust += "   WHERE MC_FILIAL = '"+xFilial("SMC")+"' "
		cQueryCust += "     AND MC_CODFORM = '"+cCodForm+"' "
		cQueryCust += "     AND MC_VISIVEL = '1' "
		cQueryCust += "     AND MC_TPFORM = '2' "
		cQueryCust += "     AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCust),cAliasCust,.T.,.T.)
		While (cAliasCust)->(!Eof())
			If "Button" $ (cAliasCust)->MC_TIPO
				aadd(aEmpenhos, {STR0055+(cAliasCust)->MC_DESCAMP, (cAliasCust)->MC_POSIC} )
			Else
				aadd(aEmpenhos, {(cAliasCust)->MC_DESCAMP, (cAliasCust)->MC_POSIC} )
			EndIf
			(cAliasCust)->(dbSkip())
		End
		(cAliasCust)->(dbCloseArea())
		aSort(aEmpenhos, , , {|x, y| x[2] < y[2]})
		For nX := 1 To Len(aEmpenhos)
			aadd(aLoad, {0, aEmpenhos[nX]}  )
		Next nX
	EndIf
Return aLoad

/*/{Protheus.doc} A125LoadH
Função para carregar os parâmetros do CRP
@author juliana.oliveira
@param  oModel, Modelo da rotina
@since 07/08/2025
@version 1.0
/*/
Static Function A125LoadHZT(oModel)
	Local aLoad      := {}
	Local cAlias     := GetNextAlias()
	Local cCodForm   := ""
	Local cOpProg    := ""
	Local cQuery     := ""
	Local lExProg    := .F.
	Local lIntCRP    := .F.
	Local lSetIni    := .F.
	Local lProd      := .F.
	Local lFinaliz   := .F.
	Local lRemocao    := .F.
	
	If oModel != Nil .And. AliasInDic("HZT")
		cCodForm   := Alltrim(oModel:GetValue("OXMASTER","OX_FORM"))
		cQuery := " SELECT HZT_FILIAL, HZT_FORM, HZT_PARAM, HZT_VALOR FROM "+RetSqlName("HZT")+" "
		cQuery += "   WHERE HZT_FILIAL = '"+xFilial("HZT")+"' "
		cQuery += "     AND HZT_FORM = '"+cCodForm+"' "
		cQuery += "     AND HZT_PARAM in ('INT_CRP', 'OP_PROGR','EX_PROGR','SETUP_INICIAL', 'PRODUCAO', 'FINALIZACAO', 'REMOCAO')
		cQuery += "     AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		While (cAlias)->(!Eof())
			If Alltrim((cAlias)->HZT_PARAM) == "INT_CRP"
				lIntCRP := vldTipoPar(Alltrim((cAlias)->HZT_VALOR))
			EndIf
			If Alltrim((cAlias)->HZT_PARAM) == "OP_PROGR"
				cOpProg := vldTipoPar(Alltrim((cAlias)->HZT_VALOR))
			EndIf
			If Alltrim((cAlias)->HZT_PARAM) == "EX_PROGR"
				lExProg := vldTipoPar(Alltrim((cAlias)->HZT_VALOR))
			EndIf
			If Alltrim((cAlias)->HZT_PARAM) == "SETUP_INICIAL"
				lSetIni := vldTipoPar(Alltrim((cAlias)->HZT_VALOR))
			EndIf
			If Alltrim((cAlias)->HZT_PARAM) == "PRODUCAO"
				lProd := vldTipoPar(Alltrim((cAlias)->HZT_VALOR))
			EndIf
			If Alltrim((cAlias)->HZT_PARAM) == "FINALIZACAO"
				lFinaliz := vldTipoPar(Alltrim((cAlias)->HZT_VALOR))
			EndIf
			If Alltrim((cAlias)->HZT_PARAM) == "REMOCAO"
				lRemocao := vldTipoPar(Alltrim((cAlias)->HZT_VALOR))
			EndIf
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

		aadd(aLoad, {lIntCRP, cOpProg, lExProg, lSetIni, lProd, lFinaliz, lRemocao})
		aAdd(aLoad, 1) //recno
	EndIf

Return aLoad

/*/{Protheus.doc} vldTipoPar
Valida os tipo dos parâmetros e faz a conversão do que está salvo na tabela para o tipo correto.
@type  Static Function
@author Juliana de Oliveira
@since 07/08/2025
@version P12
@param 01 cValor   , Any     , Valor do parâmetro que irá validar, retorna por referencia o valor convertido se lConverte == .T.
@return lOk, Logico, Retorna se o parâmetro está correto.
/*/
Static Function vldTipoPar(cValor)
	Local xValorHZT 

	If cValor == "true"
		xValorHZT := .T.
	ElseIf cValor == "false"
		xValorHZT := .F.
	Else
		xValorHZT := cValor
	EndIf

Return xValorHZT
