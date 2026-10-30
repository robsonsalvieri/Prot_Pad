#include "MATA489.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH" 

//------------------------------------------------------------------------------
/*/{Protheus.doc} MATA489
Registro de Destinatarios relacionados al Cliente (AIT)
@author 	luis.enriquez
@param	    cAlias - Caracter - Alias de la Tabla
@param	    nReg - Numérico - No. de Registro (Recno)
@param	    nOperation - Numérico - No de Operación (Insert, Delete, Update)
@return		Nil
@since 		10/07/2023
@version	12.1.33 / Superior
/*/
//------------------------------------------------------------------------------
Function MATA489( cAlias, nReg, nOperation)
	Local aArea 			:= GetArea()
	Local oExecView			:= Nil 
	Local oModel			:= Nil
	Local aLoad             := {}
	Local cCod              := "" 
	Local cLoja             := ""
	Local cNomCli           := ""
	
	Default cAlias  		:= Alias()
	Default nReg	  		:= (cAlias)->(RecNo()) 
	Default nOperation		:= 1
	
	dbSelectArea("SA1")
	SA1->(MsGoto(nReg))
	cCod    := SA1->A1_COD 
	cLoja   := SA1->A1_LOJA
	cNomCli := SA1->A1_NOME
	
	AAdd(aLoad,xFilial("AIT"))
	AAdd(aLoad,cCod)
	AAdd(aLoad,cLoja)
	AAdd(aLoad,cNomCli)
	
	oModel := FWLoadModel("MATA489")
	oModel:SetOperation(nOperation)
	oModel:GetModel("AITMASTER"):bLoad := {|| aLoad}
	oModel:Activate() 
	
	oView := FWLoadView("MATA489")
	oView:SetModel(oModel)
	oView:SetOperation(nOperation) 
			  	
	oExecView := FWViewExec():New()
	oExecView:SetTitle("SAT") 
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:SetCloseOnOK({|| .T. })
	oExecView:SetOperation(nOperation)
	oExecView:OpenView(.T.)
	
	oModel:DeActivate()
	
	RestArea(aArea)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definición del modelo de datos
@author 	luis.enriquez
@return		oModel objeto del Model
@since 		10/07/2023
@version	12.1.33 / Superior
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 		:= Nil
	Local cModAITCab	:= "AIT_FILIAL|AIT_CODCLI|AIT_LOJA|AIT_NOMCLI"
	Local bMCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ cModAITCab}
	Local oStructMST 	:= FWFormStruct(1,"AIT",bMCpoCab)
	Local oStructAIT 	:= FWFormStruct(1,"AIT")
	Local aPrimKey      := {}
	Local aSetUniq      := {}

	oStructMST:AddField(	AllTrim(STR0002)			,; 	// [01] C Titulo do campo //"Nombre"
						AllTrim(STR0003)	            ,; 	// [02] C ToolTip do campo //"Nombre del cliente"
						"AIT_NOMCLI" 					,; 	// [03] C identificador (ID) do Field
						"C" 							,; 	// [04] C Tipo do campo
						40 								,; 	// [05] N Tamanho do campo
						0 								,; 	// [06] N Decimal do campo
						Nil 							,; 	// [07] B Code-block de validação do campo
						Nil								,; 	// [08] B Code-block de validação When do campo
						Nil					 			,; 	// [09] A Lista de valores permitido do campo
						Nil 							,; 	// [10] L Indica se o campo tem preenchimento obrigatório
						Nil		 			   			,;  // [11] B Code-block de inicializacao do campo
						Nil 							,; 	// [12] L Indica se trata de um campo chave
						Nil				 				,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
						Nil )	
						
	oModel := MPFormModel():New("MATA489",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)	
	
	
	oModel:AddFields("AITMASTER",/*cOwner*/,oStructMST,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/) 
	oModel:AddGrid("AITCONTDET","AITMASTER",oStructAIT, ,/*bPosValidacao*/,/*bCarga*/)
	
	oModel:GetModel("AITCONTDET"):SetOptional( .T. )
	
	aPrimKey := {"AIT_FILIAL","AIT_CODCLI","AIT_LOJA","AIT_CODRES"}
	aSetUniq := {"AIT_CODRES"}

	
	oModel:GetModel("AITCONTDET"):SetUniqueLine(aSetUniq)
	oModel:GetModel("AITCONTDET"):SetUseOldGrid()
	oModel:GetModel("AITCONTDET"):SetOptional( .T. )
	
	oModel:SetRelation("AITCONTDET",{ {"AIT_FILIAL","AIT_FILIAL"},;
	                                  {"AIT_CODCLI","AIT_CODCLI"},;
	                                  {"AIT_LOJA","AIT_LOJA"}; 
	                                },AIT->( IndexKey(1)))
	oModel:SetPrimaryKey(aPrimKey)	
	oModel:SetPrimaryKey( {} )								
    oModel:SetDescription(STR0001) //"Destinatarios"

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface del modelo de datos de configuración de Destinatarios del Cliente.
@param		Nenhum
@return		oView objeto del View
@author 	luis.enriquez
@since 		10/07/2023
@version	12.1.33 / Superior
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView 		:= Nil
	Local oModel		:= FwLoadModel("MATA489")
	Local cVITCab	:= "AIT_FILIAL|AIT_CODCLI|AIT_LOJA|AIT_NOMCLI"
	Local bVCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ cVITCab}
	Local oStructMST 	:= FWFormStruct(2,"AIT",bVCpoCab)
	Local oStructAIT 	:= FWFormStruct(2,"AIT")
	Local nOrden        := 0

	//Campos no ediatbles
	oStructMST:SetProperty("AIT_CODCLI",MVC_VIEW_CANCHANGE,.F.)
	oStructMST:SetProperty("AIT_LOJA",MVC_VIEW_CANCHANGE,.F.)

	nOrden	:= M489ORD("AIT")
	
	oStructMST:AddField(	"AIT_NOMCLI" 			,;	// [01] C Nome do Campo
							Str(nOrden) 		    ,; 	// [02] C Ordem
							STR0002	                ,; 	// [03] C Titulo do campo //"Nombre"
							STR0003					,; 	// [04] C Descrição do campo//"Nombre del cliente"
							{} 	   					,; 	// [05] A Array com Help
							"C" 					,; 	// [06] C Tipo do campo
							"@!" 					,; 	// [07] C Picture
							Nil 					,; 	// [08] B Bloco de Picture Var
							Nil 					,; 	// [09] C Consulta F3
							.F. 					,;	// [10] L Indica se o campo é evitável
							Nil 					,; 	// [11] C Pasta do campo
							Nil 					,;	// [12] C Agrupamento do campo
							Nil 					,; 	// [13] A Lista de valores permitido do campo (Combo)
							Nil 					,;	// [14] N Tamanho Maximo da maior opção do combo
							Nil 					,;	// [15] C Inicializador de Browse
							Nil 					,;	// [16] L Indica se o campo é virtual
							Nil )

	//Campos removididos del grid												
	oStructAIT:RemoveField("AIT_FILIAL")
	oStructAIT:RemoveField("AIT_CODCLI")
	oStructAIT:RemoveField("AIT_LOJA")

	//Campos No Editables
	oStructAIT:SetProperty("AIT_CODRES" , MVC_VIEW_CANCHANGE, .F. )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	 
	oView:AddField("VIEW_MST",oStructMST,"AITMASTER")
	oView:AddGrid("VIEW_AIT",oStructAIT, "AITCONTDET")
	
	oView:CreateHorizontalBox("VIEW_TOP",20)
	oView:SetOwnerView("VIEW_MST","VIEW_TOP")
	
	oView:CreateHorizontalBox("VIEW_DET",80)
	oView:SetOwnerView("VIEW_AIT","VIEW_DET")

	oView:EnableTitleView('VIEW_AIT',"Destinos") 

	oView:AddIncrementField( 'VIEW_AIT', 'AIT_CODRES' ) //Número de ítem
Return(oView)

/*/{Protheus.doc} M489ORD
Obtiene el siguiente orden de una tabla 
@author luis.enriquez
@return		nProxOrdem
@since 10/07/2023
@version 12.1.33 o Superior
/*/
Static Function M489ORD(cTabla)
	Local nProxOrdem:= 0
	Local aAreaSX3  := GetArea()
	Local nOrden    := 0
	Local cOrden	:= "00"
	Local aSX3      := {}
	Local _i        := 0
	
	// Verificando a ultima ordem utilizada
	aSX3 := FWSX3Util():GetAllFields(cTabla, .T.)
	for _i := 1 to len(aSX3)
		cOrden := GetSx3Cache(aSX3[_i], "X3_ORDEM")
	next _i

	RestArea(aAreaSX3)
	
	nOrden    := RetAsc(cOrden,3,.F.)   //A0 -> 100
	nProxOrdem:= VAL(nOrden)+ 1
Return nProxOrdem
