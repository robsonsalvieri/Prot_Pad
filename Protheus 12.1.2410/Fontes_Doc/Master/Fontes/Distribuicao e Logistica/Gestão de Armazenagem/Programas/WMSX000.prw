#INCLUDE "WMSX000.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aFldCnvToL := {} // Array de campos convertidos para lógico de S/N para .T./.F.
Static aFldInfCmp := {} // Array com informações complementares dos campos {Folder,F3,Picture}

//-------------------------------------------------------------------
/*/{Protheus.doc} WMSX000
//Função que cria uma tela aonde se pode ser incluidos ou alterados os parametros que existem na base
@author felipe.m
@since 22/01/2018
@version 2.0
@return return, Nulo
/*/
//-------------------------------------------------------------------
Function WMSX000()
	FWExecView(STR0001, 'WMSX000', 3, , {|| .T. } ) //-- Parâmetros do WMS
Return NiL
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel   := Nil
Local oStruct  := FWFormModelStruct():New()
Local cFilVazia:= Space(FwSizeFilial())
Local lWmsNew  := SuperGetMV('MV_WMSNEW',.F.,.F.)

	DbSelectArea("SX6")
	SX6->( dbSetOrder(1) )
	// ----------------------------------------------------------------------------------------------------------------------------
	// WMS Geral 
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldCnvToL,"MV_INTDL")
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0002, ; //-- Integração Logística
		GetHelp("MV_INTDL",cFilVazia),"MV_INTDL", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_INTDL',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
		
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0154, ; //-- Integração WMS
		GetHelp("MV_INTWMS",cFilVazia),"MV_INTWMS", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_INTWMS',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldCnvToL,"MV_WMSATDT")
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0005, ; //-- Data do Protheus diferente da data do sistema
		GetHelp("MV_WMSATDT",cFilVazia),"MV_WMSATDT", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_WMSATDT',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldCnvToL,"MV_WMSMABP")
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0006, ; //-- Reabastecimento até completar o picking
		GetHelp("MV_WMSMABP",cFilVazia),"MV_WMSMABP", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_WMSMABP',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldCnvToL,"MV_WMSMULP")
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0007, ; //-- Considera Multiplas Endereços de Picking
		GetHelp("MV_WMSMULP",cFilVazia),"MV_WMSMULP", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_WMSMULP',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	If !lWmsNew
		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0014, ; //-- Habilita vallidações no estorno do serviço WMS na rotina Exec. de serviços
			GetHelp("MV_WMSVLDE",cFilVazia),"MV_WMSVLDE", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSVLDE',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
		
		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0015, ; //-- Habilita validação do movimento do WMS na rotina de transferência
			GetHelp("MV_WMSVLDT",cFilVazia),"MV_WMSVLDT", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSVLDT',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	EndIf

	If lWmsNew
		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0136, ; //-- Bloqueia saldo ate encerramento do endereçamento
			GetHelp("MV_WMSBLQE",cFilVazia),"MV_WMSBLQE", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSBLQE',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0146, ; //-- Utiliza sequencia automática no romaneio de embarque
			GetHelp("MV_WMSROA",cFilVazia),"MV_WMSROA", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSROA',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0186, ; //-- Execução automática somente para pedido completo 
			GetHelp("MV_WMSEASC",cFilVazia),"MV_WMSEASC", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSEASC',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	EndIf
	
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0179, ; //-- Utiliza job nas integrações de serviços com execução automática
		GetHelp("MV_WMSEXJB",cFilVazia),"MV_WMSEXJB", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSEXJB',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0181, ; //-- Visualizar busca de saldo para o apanhe
		GetHelp("MV_WMSRLSA",cFilVazia),"MV_WMSRLSA", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSRLSA',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0182, ; //-- Visualizar busca de endereços para a armazenagem
		GetHelp("MV_WMSRLEN",cFilVazia),"MV_WMSRLEN", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSRLEN',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0183, ; //-- Exibir as mensagens de reabastecimento
		GetHelp("MV_WMSEMRE",cFilVazia),"MV_WMSEMRE", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSEMRE',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
		
	AAdd(aFldInfCmp,{"WMSGer",Nil,"@E 9999999999"})
	oStruct:AddField(STR0190, ; //-- Limite de endereços de picking ocupados
		GetHelp("MV_WMSNRPO",cFilVazia),"MV_WMSNRPO", "N", ;
		10,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSNRPO',.F.,10)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"WMSGer",Nil,"@E 9999999999"})
	oStruct:AddField(STR0009, ; //-- Refresh do monitor de serviços (em segundos)
		GetHelp("MV_WMSREFS",cFilVazia),"MV_WMSREFS", "N", ;
		10,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSREFS',.F.,10)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0018, ; //-- Número sequencial das etiquetas de volume
		GetHelp("MV_WMSNVOL",cFilVazia),"MV_WMSNVOL", "C", ;
		10,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSNVOL',.F.,'')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0023, ; //-- Campos da tabela SB5 que devem ser considerados pelo Wizard de Complemento Produtos
		GetHelp("MV_WMSWCP",cFilVazia),"MV_WMSWCP", "C", ;
		250,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSWCP',.F.,'')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0052, ; //-- Diretório dos documentos/logs
		GetHelp("MV_WMSDOC",cFilVazia),"MV_WMSDOC", "C", ;
		50,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSDOC',.F.,'')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	If lWmsNew
		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0135, ; //-- Efetua Automaticamente a Distribuição Produto com Pedido Compra
			GetHelp("MV_WMSDPCA",cFilVazia),"MV_WMSDPCA", "C", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0160,STR0161,STR0162,STR0163,STR0164},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSDPCA',.F.,'0')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) // 0=Não Utiliza | 1=Rateio Direto | 2=Rateio Proporcional | 3=Rateio Unidade + Proporcional | 4=Rateio Direto Pedido de Venda + Proporcional Plano de Distribuição

		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0144, ; //-- Sequencial romaneio de embarque
			GetHelp("MV_WMSROM",cFilVazia),"MV_WMSROM", "C", ;
			TamSx3("DCU_ROMEMB")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSROM',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
		oStruct:AddField(STR0145, ; //-- Restringir romaneio de embarque por cliente e loja
			GetHelp("MV_WMSRRCL",cFilVazia),"MV_WMSRRCL", "C", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0165,STR0166,STR0167,STR0168},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSRRCL',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) // 0=Não Valida;1= Validar Ant Faturamento;2=Validar Pos Faturamento;3=Ambos
	EndIf

	AAdd(aFldInfCmp,{"WMSGer",Nil,Nil})
	oStruct:AddField(STR0174, ; //-- Tipo padrão ao encerrar uma ocorrência
		GetHelp("MV_WM300EN",cFilVazia),"MV_WM300EN", "C", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0175,STR0176,STR0177},.F./*lOBRIG*/,{||SuperGetMV('MV_WM300EN',.F.,'1')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) // 1=Documento de Entrada;2=Documento de Saída;3=Movimento Interno

	// ----------------------------------------------------------------------------------------------------------------------------
	// Radio Frequência
	// ----------------------------------------------------------------------------------------------------------------------------
	If !lWmsNew
		AAdd(aFldCnvToL,"MV_RADIOF")
		AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
		oStruct:AddField(STR0041, ; //-- Utiliza Rádio Frequência
			GetHelp("MV_RADIOF",cFilVazia),"MV_RADIOF", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_RADIOF',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	EndIf
	
	AAdd(aFldCnvToL,"MV_WMSRDST")
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0024, ; //-- Execução de serviços RDMAKE via rádio frequência, deve alterar o status do serviço
		GetHelp("MV_WMSRDST",cFilVazia),"MV_WMSRDST", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_WMSRDST',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
 	AAdd(aFldCnvToL,"MV_REINAUT")
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0026, ; //-- Reinicio automatico das tarefas interrompidas
		GetHelp("MV_REINAUT",cFilVazia),"MV_REINAUT", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_REINAUT',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldCnvToL,"MV_RFINFAZ")
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0044, ; //-- Informa localização ao acessar opção de Convocação RF
		GetHelp("MV_RFINFAZ",cFilVazia),"MV_RFINFAZ", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_RFINFAZ',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0046, ; //-- Solicita confirmação do lote nas operações com RF
		GetHelp("MV_WMSLOTE",cFilVazia),"MV_WMSLOTE", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSLOTE',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0059, ; //-- Apresenta descricao do produto no coletor RF para os processos de conferência
		GetHelp("MV_WMSVSTC",cFilVazia),"MV_WMSVSTC", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSVSTC',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0189, ; //-- Apresenta descricao do produto no coletor RF para os processos de movimentação
		GetHelp("MV_WMSVSTE",cFilVazia),"MV_WMSVSTE", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSVSTE',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0137, ; //-- Permite suprimir mensagens ao operador nas atividades de separação através de coletor RF.
		GetHelp("MV_WMSAPAN",cFilVazia),"MV_WMSAPAN", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSAPAN',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0061, ; //-- Finaliza separação/reabastecimento
		GetHelp("MV_WMSFSEP",cFilVazia),"MV_WMSFSEP", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSFSEP',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0068, ; //-- Determina a ordem de separação somente após a conclusão da carga/documento
		GetHelp("MV_WMSCOMP",cFilVazia),"MV_WMSCOMP", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_WMSCOMP',.F.,'F')=='T',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0180, ; // Não efetua convocação quando não encontrar regra de convocação definida
		GetHelp("MV_WMSNREG",cFilVazia),"MV_WMSNREG", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSNREG',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	If lWmsNew
		AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
		oStruct:AddField(STR0147, ; //-- Solicitar função do Recurso na Convocação
			GetHelp("MV_WMSFUNC",cFilVazia),"MV_WMSFUNC", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSFUNC',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
		AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
		oStruct:AddField(STR0178, ; //-- Retorna sempre para primeira função do operador na busca das atividades pendentes
			GetHelp("MV_WMSPFUN",cFilVazia),"MV_WMSPFUN", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSPFUN',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
		AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
		oStruct:AddField(STR0187, ; // Permite gerar o embarque de expedição via coletor
			GetHelp("MV_WMSGEEX",cFilVazia),"MV_WMSGEEX", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSGEEX',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	EndIf
	
	If !lWmsNew
		AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
		oStruct:AddField(STR0028, ; //-- Permite selecionar multiplas tarefas
			GetHelp("MV_WMSMTEA",cFilVazia),"MV_WMSMTEA", "C", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0029, STR0030, STR0031, STR0032},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSMTEA',.F.,"0")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //-- 0=Nenhum"###"1=Apanhe"###"2=Endereçar"###"3=Ambos"
	EndIf
	
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0033, ; //-- Método de descarga quando utiliza multiplas tarefas
		GetHelp("MV_WMSMDES",cFilVazia),"MV_WMSMDES", "C", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0034,STR0035},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSMDES',.F.,"0")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //-- 0=End.Destino+Produto+Lote+SubLote"###"1=Inverso da Carga,com produtos,lotes com mesmo endereço de destino"

	AAdd(aFldInfCmp,{"RadFre",Nil,"@E 99"})
	oStruct:AddField(STR0036, ; //-- Nível Final do Endereço a ser mostrado nas rotinas de RF
		GetHelp("MV_ENDFIRF",cFilVazia),"MV_ENDFIRF", "N", ;
		2,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_ENDFIRF',.F.,0)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,"@E 99"})
	oStruct:AddField(STR0037, ; //-- Nível Inicial do Endereço a ser mostrado nas rotinas de RF
		GetHelp("MV_ENDINRF",cFilVazia),"MV_ENDINRF", "N", ;
		2,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_ENDINRF',.F.,0)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0038, ; //-- Número de contagens que o conferente pode executar
		GetHelp("MV_MAXCONT",cFilVazia),"MV_MAXCONT", "C", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_MAXCONT',.F.,'3')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,"@E 999999999999"})
	oStruct:AddField(STR0042, ; //-- Tempo em milissegundos em que o sistema ficará em pausa hibernando
		GetHelp("MV_RFIDLES",cFilVazia),"MV_RFIDLES", "N", ;
		12,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_RFIDLES',.F.,5000)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,"@E 999999999999"})
	oStruct:AddField(STR0043, ; //-- Tempo em mili-segundos em que o sistema ficará em pausa acordado
		GetHelp("MV_RFIDLEW",cFilVazia),"MV_RFIDLEW", "N", ;
		12,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_RFIDLEW',.F.,1000)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"RadFre",Nil,"@E 999999999999"})
	oStruct:AddField(STR0045, ; //-- Ativa Tratamento de Hibernação
		GetHelp("MV_RFSLEEP",cFilVazia),"MV_RFSLEEP", "N", ;
		12,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_RFSLEEP',.F.,0)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	If !lWmsNew
		AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
		oStruct:AddField(STR0047, ; //-- Unidade de medida utilizada
			GetHelp("MV_WMSUMI",cFilVazia),"MV_WMSUMI", "C", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0048, STR0049, STR0050, STR0051},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSUMI',.F.,'1')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //-- 1=1a.UM"###"2=2a.UM"###"3=Unitizador"###"4=UMI"
	EndIf
	
	AAdd(aFldInfCmp,{"RadFre",Nil,"@E 999999999999"})
	oStruct:AddField(STR0060, ; //-- Quantidade de tolerância para separação a maior
		GetHelp("MV_WMSQSEP",cFilVazia),"MV_WMSQSEP", "N", ;
		12,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSQSEP',.F.,0)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0062, ; //-- Permite alterar nro lote na separação RF
		GetHelp("MV_WMSALOT",cFilVazia),"MV_WMSALOT", "C",;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0063,STR0064,STR0065},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSALOT',.F.,'S')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //-- 1=Não"###"2=Sim"###"3=Confirmação"
	
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0066, ; //-- Sequencial para determinar a sequencia de execução dos serviços
		GetHelp("MV_WMSSQPR",cFilVazia),"MV_WMSSQPR", "C", ;
		50,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSSQPR',.F.,'000000')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0067, ; //-- Regra para compor a prioridade de convocação
		GetHelp("MV_WMSPRIO",cFilVazia),"MV_WMSPRIO", "C", ;
		250,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSPRIO',.F.,Iif(!lWmsNew,'SDB->(DB_CARGA+DB_DOC)','D12->(D12_CARGA+D12_DOC)'))}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"RadFre",Nil,Nil})
	oStruct:AddField(STR0069, ; //-- Tipo de convocação para rádio frequência
		GetHelp("MV_TPCONVO",cFilVazia),"MV_TPCONVO", "C", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0070, STR0071, STR0072},.F./*lOBRIG*/,{||SuperGetMV('MV_TPCONVO',.F.,'1')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) // 1=Atividade // 2=Tarefa/Produto // 3=Tarefa/Completa

	// ----------------------------------------------------------------------------------------------------------------------------
	// Qualidade
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldInfCmp,{"Qualid","NNR",Nil})
	oStruct:AddField(STR0073, ; //-- Local (Almoxarifado) Controle de Qualidade
		GetHelp("MV_CQ",cFilVazia),"MV_CQ", "C", ;
		TamSx3("NNR_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_CQ',.F.,'98')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Qualid",Nil,Nil})
	oStruct:AddField(STR0074, ; //-- Amarração entre almoxarifado e localização
		GetHelp("MV_DISTAUT",cFilVazia),"MV_DISTAUT", "C", ;
		TamSx3("NNR_CODIGO")[1]+TamSx3("BE_LOCALIZ")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_DISTAUT',.F.,'')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	AAdd(aFldInfCmp,{"Qualid",Nil,Nil})
	oStruct:AddField(STR0075, ; //-- Numero documento transferência automática
		GetHelp("MV_DOCTRAN",cFilVazia),"MV_DOCTRAN", "C", ;
		50,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_DOCTRAN',.F.,'SK0002')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	// ----------------------------------------------------------------------------------------------------------------------------
	// Log
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldCnvToL,"MV_LOGMOV")
	AAdd(aFldInfCmp,{"Log",Nil,Nil})
	oStruct:AddField(STR0076, ; //-- Ativa a verificação de movimentações para Produtos com Rastro e/ou Localização
		GetHelp("MV_LOGMOV",cFilVazia),"MV_LOGMOV", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_LOGMOV',.F.,'N')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	// ----------------------------------------------------------------------------------------------------------------------------
	// Faturamento 
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldInfCmp,{"Fatura",Nil,Nil})
	oStruct:AddField(STR0077, ; //-- Aglutina itens do mesmo lote e sub-lote
		GetHelp("MV_WMSAGLU",cFilVazia),"MV_WMSAGLU", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSAGLU',.F.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	If !lWmsNew
		AAdd(aFldInfCmp,{"Fatura",Nil,Nil})
		oStruct:AddField(STR0078, ; //-- Realiza a reliberação do pedido para o último endereço
			GetHelp("MV_WMSRELI",cFilVazia),"MV_WMSRELI", "C", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0063, STR0064},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSRELI',.F.,'1')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //-- 1=Não"###"2=Sim"
	EndIf

	// ----------------------------------------------------------------------------------------------------------------------------
	// Estoque
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldCnvToL,"MV_ESTNEG")
	AAdd(aFldInfCmp,{"Estoqu",Nil,Nil})
	oStruct:AddField(STR0079, ; //-- Permite saldo negativo
		GetHelp("MV_ESTNEG",cFilVazia),"MV_ESTNEG", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_ESTNEG',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Estoqu",Nil,"@E 99999"})
	oStruct:AddField(STR0080, ; //-- Tolerância para cálculos com a 1 UM
		GetHelp("MV_NTOL1UM",cFilVazia),"MV_NTOL1UM", "N", ;
		5,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_NTOL1UM',.F.,0)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Estoqu",Nil,Nil})
	oStruct:AddField(STR0081, ; //-- Data último fechamento do estoque
		GetHelp("MV_ULMES",cFilVazia),"MV_ULMES", "D", ;
		10,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_ULMES',.F.,'19970101')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	If lWmsNew
		AAdd(aFldInfCmp,{"Estoqu","SF5",Nil})
		oStruct:AddField(STR0169, ; //-- "Tipo de movimentação produção para montagem WMS"
			GetHelp("MV_WMSTMMT",cFilVazia),"MV_WMSTMMT", "C", ;
			TamSx3("F5_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTMMT',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Estoqu","SF5",Nil})
		oStruct:AddField(STR0171, ; //-- "Tipo de movimentação de requisição para produção na montagem WMS"
			GetHelp("MV_WMSTMRQ",cFilVazia),"MV_WMSTMRQ", "C", ;
			TamSx3("F5_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTMRQ',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Estoqu","SF5",Nil})
		oStruct:AddField(STR0173, ; //-- "Tipo de movimentação de baixa de requisição na separação WMS"
			GetHelp("MV_WMSTMBR",cFilVazia),"MV_WMSTMBR", "C", ;
			TamSx3("F5_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTMBR',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Estoqu","SF5",Nil})
		oStruct:AddField(STR0184, ; //-- "Tipo de movimentação de requisição para pedidos gerados automaticamente a partir de volumes crossdocking"
			GetHelp("MV_WMSTPOP",cFilVazia),"MV_WMSTPOP", "C", ;
			TamSx3("F5_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTPOP',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Estoqu","SF4",Nil})
		oStruct:AddField(STR0185, ; //-- "TES de saída para pedidos gerados automaticamente a partir de volumes crossdocking"
			GetHelp("MV_WMSTMCR",cFilVazia),"MV_WMSTMCR", "C", ;
			TamSx3("F4_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTMCR',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	EndIf

	// ----------------------------------------------------------------------------------------------------------------------------
	// Controle de Lote 
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldInfCmp,{"CntLot",Nil,Nil})
	oStruct:AddField(STR0083, ; //-- Utiliza conceito de lote único
		GetHelp("MV_LOTEUNI",cFilVazia),"MV_LOTEUNI", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_LOTEUNI',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldCnvToL,"MV_LOTVENC")
	AAdd(aFldInfCmp,{"CntLot",Nil,Nil})
	oStruct:AddField(STR0084, ; //-- Utiliza Lotes/Sub-Lotes com a data de validade vencida
		GetHelp("MV_LOTVENC",cFilVazia),"MV_LOTVENC", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_LOTVENC',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldCnvToL,"MV_RASTRO")
	AAdd(aFldInfCmp,{"CntLot",Nil,Nil})
	oStruct:AddField(STR0085, ; //-- Utiliza Rastreabilidade dos Lotes de Producao
		GetHelp("MV_RASTRO",cFilVazia),"MV_RASTRO", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_RASTRO',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"CntLot",Nil,Nil})
	oStruct:AddField(STR0082, ; //-- Codigo da formula default utilizada para preenchimento dos lotes
		GetHelp("MV_FORMLOT",cFilVazia),"MV_FORMLOT", "C", ;
		50,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_FORMLOT',.F.,'')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	
	// ----------------------------------------------------------------------------------------------------------------------------
	// Controle de Endereço 
	// ----------------------------------------------------------------------------------------------------------------------------
	If !lWmsNew
		AAdd(aFldInfCmp,{"CntEnd",Nil,Nil})
		oStruct:AddField(STR0088, ; //-- Avalia capacidade dos endereços
			GetHelp("MV_CAPLOCA",cFilVazia),"MV_CAPLOCA", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_CAPLOCA',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	EndIf

	AAdd(aFldCnvToL,"MV_GERABLQ")
	AAdd(aFldInfCmp,{"CntEnd",Nil,Nil})
	oStruct:AddField(STR0090, ; //-- Gera bloqueio de estoque para produtos que controlam rastro ou localização
		GetHelp("MV_GERABLQ",cFilVazia),"MV_GERABLQ", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_GERABLQ',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldCnvToL,"MV_LOCALIZ")
	AAdd(aFldInfCmp,{"CntEnd",Nil,Nil})
	oStruct:AddField(STR0091, ; //-- Produtos podem usar controle de localização física
		GetHelp("MV_LOCALIZ",cFilVazia),"MV_LOCALIZ", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_LOCALIZ',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"CntEnd",Nil,Nil})
	oStruct:AddField(STR0079, ; //-- Permite saldo negativo
		GetHelp("MV_MT300NG",cFilVazia),"MV_MT300NG", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_MT300NG',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"CntEnd",Nil,Nil})
	oStruct:AddField(STR0089, ; //-- Descrição do endereço para endereços gerados
		GetHelp("MV_DESCEND",cFilVazia),"MV_DESCEND", "C", ;
		50,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_DESCEND',.F.,'')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"CntEnd",Nil,Nil})
	oStruct:AddField(STR0092, ; //-- Ao ocorrer um estorno de movimento com controle de localização deve-se
		GetHelp("MV_PDEVLOC",cFilVazia),"MV_PDEVLOC", "C", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0093,STR0094,STR0095},.F./*lOBRIG*/,{||SuperGetMV('MV_PDEVLOC',.F.,'2')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //-- 0=Redistribuir"###"1=Localização Original"###"2=Perguntar"

	// ----------------------------------------------------------------------------------------------------------------------------
	// Carga
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldCnvToL,"MV_WMSACAR")
	AAdd(aFldInfCmp,{"Carga",Nil,Nil})
	oStruct:AddField(STR0096, ; //-- Realiza processos WMS considerando carga
		GetHelp("MV_WMSACAR",cFilVazia),"MV_WMSACAR", "L", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||Iif(SuperGetMV('MV_WMSACAR',.F.,'S')=='S',.T.,.F.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Carga",Nil,Nil})
	oStruct:AddField(STR0148, ; //-- "Aglutinação da carga"
		GetHelp("MV_WMSACEX",cFilVazia),"MV_WMSACEX", "C", ;
		1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,{STR0149,STR0150,STR0151},.F./*lOBRIG*/,{||SuperGetMV('MV_WMSACEX',.F.,'0')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //"0=Não Aglutina","1=Aglutina por Carga","2=Aglutina por Carga/Cliente"

	// ----------------------------------------------------------------------------------------------------------------------------
	// Recebimento
	// ----------------------------------------------------------------------------------------------------------------------------
	AAdd(aFldInfCmp,{"Recebi","NNR",Nil})
	oStruct:AddField(STR0138, ; //-- Armazém de falta da conferência recebimento
		GetHelp("MV_WMSLCFT",cFilVazia),"MV_WMSLCFT", "C", ;
		TamSx3("NNR_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSLCFT',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Recebi","SBE",Nil})
	oStruct:AddField(STR0140, ; //-- Endereço de falta da conferência de recebimento
		GetHelp("MV_WMSENFT",cFilVazia),"MV_WMSENFT", "C", ;
		TamSx3("BE_LOCALIZ")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSENFT',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Recebi","NNR",Nil})
	oStruct:AddField(STR0139, ; //-- Armazém de excesso da conferência de recebimento
		GetHelp("MV_WMSLCEX",cFilVazia),"MV_WMSLCEX", "C", ;
		TamSx3("NNR_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSLCEX',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Recebi","SBE",Nil})
	oStruct:AddField(STR0159, ; //-- Endereço de excesso da conferência de recebimento
		GetHelp("MV_WMSENEX",cFilVazia),"MV_WMSENEX", "C", ;
		TamSx3("BE_LOCALIZ")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSENEX',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Recebi","DC5",Nil})
	oStruct:AddField(STR0158, ; //-- "Serviço para movimento de entrada no armazém de falta"
		GetHelp("MV_WMSSRFT",cFilVazia),"MV_WMSSRFT", "C", ;
		TamSx3("DC5_SERVIC")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSSRFT',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	AAdd(aFldInfCmp,{"Recebi","DC5",Nil})
	oStruct:AddField(STR0142, ; //-- Serviço para movimentos de entrada no armazém de excesso
		GetHelp("MV_WMSSREX",cFilVazia),"MV_WMSSREX", "C", ;
		TamSx3("DC5_SERVIC")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSSREX',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
		
	If lWmsNew
		AAdd(aFldInfCmp,{"Recebi","DC5",Nil})
		oStruct:AddField(STR0156, ; //-- "Serviço para movimento de retirada do armazém atual"
			GetHelp("MV_WMSSRRE",cFilVazia),"MV_WMSSRRE", "C", ;
			TamSx3("DC5_SERVIC")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSSRRE',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Recebi","SF5",Nil})
		oStruct:AddField(STR0157, ; //-- "Tipo de movimentação de entrada no armazém de falta"
			GetHelp("MV_WMSTMFT",cFilVazia),"MV_WMSTMFT", "C", ;
			TamSx3("F5_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTMFT',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Recebi","SF5",Nil})
		oStruct:AddField(STR0141, ; //-- Tipo de movimentação de entrada no armazém de excesso
			GetHelp("MV_WMSTMEX",cFilVazia),"MV_WMSTMEX", "C", ;
			TamSx3("F5_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTMEX',.F.,' ')}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Recebi","SF5",Nil})
		oStruct:AddField(STR0155, ; //-- "Tipo de movimentação de retirada do armazém atual"
			GetHelp("MV_WMSTMRE",cFilVazia),"MV_WMSTMRE", "C", ;
			TamSx3("F5_CODIGO")[1],/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSTMRE',.F.,"")}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
		
		AAdd(aFldInfCmp,{"Recebi",Nil,Nil})
		oStruct:AddField(STR0191, ; //-- Bloquear conferência de produtos não informados na pre-nota ou documento de entrada.
			GetHelp("MV_WMSNPCP",cFilVazia),"MV_WMSNPCP", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSNPCP',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

		AAdd(aFldInfCmp,{"Recebi",Nil,Nil})
		oStruct:AddField(STR0192, ; //-- Solicitar a data de validade do lote na conferência caso não encontre-se previamente informada.
			GetHelp("MV_WMSDTCF",cFilVazia),"MV_WMSDTCF", "L", ;
			1,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*aValues*/,.F./*lOBRIG*/,{||SuperGetMV('MV_WMSDTCF',.F.,.T.)}/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)

	EndIf

	oModel := MPFormModel():New("WMSX000", /*bPre*/, /*bPost*/, {|oModel|WMSX000COM(oModel)} /*bCommit*/, /*bCancel*/)
	oModel:AddFields("WMSX000_01", Nil, oStruct, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetDescription(STR0107) //-- Parâmetros
	oModel:GetModel("WMSX000_01"):SetDescription(STR0108) //-- Parâmetros WMS
	oModel:SetPrimaryKey({"MV_INTDL"})

Return oModel
//------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView    := Nil
Local oStruct  := FWFormViewStruct():New()
Local oModel   := FWLoadModel("WMSX000")
Local cOrdem   := "00"
Local oModelPF := oModel:GetModel('WMSX000_01')
Local nCont    := 0
Local aCamposPF:= oModelPF:GetStruct():GetFields()

	oStruct:AddFolder("WMSGer", STR0109) //-- WMS Geral
	oStruct:AddFolder("RadFre", STR0110) //-- RF (Rádio Frequência)
	oStruct:AddFolder("CntEnd", STR0111) //-- Controle de Endereço
	oStruct:AddFolder("CntLot", STR0113) //-- Controle de Lote
	oStruct:AddFolder("Estoqu", STR0114) //-- Estoque
	oStruct:AddFolder("Recebi", STR0170) //-- Recebimento
	oStruct:AddFolder("Fatura", STR0115) //-- Faturamento
	oStruct:AddFolder("Carga",  STR0116) //-- Carga
	oStruct:AddFolder("Qualid", STR0117) //-- Qualidade
	oStruct:AddFolder("Log",    STR0118) //-- Log
	//oStruct:AddGroup("GrpAtv" , STR0153, "RadFre", 2) // "Atividades"

	For nCont := 1 To Len(aCamposPF)
		cOrdem := Soma1(cOrdem)
		oStruct:AddField(aCamposPF[nCont][3],; // Código Parâmetro
			cOrdem,;               // Ordem
			aCamposPF[nCont][1],;  // Título
			aCamposPF[nCont][2],;  // Lookup
			/*aHelp*/,;            // Help
			aCamposPF[nCont][4],;  // Tipo
			aFldInfCmp[nCont][3],; // Picture
			/*cPictVar*/,;         // PictVar
			aFldInfCmp[nCont][2],; // F3
			/*lCanChange*/,;       // lCanChange
			aFldInfCmp[nCont][1],; // Folder
			/*cGroup*/,;           // Grupo
			aCamposPF[nCont][9])   // Opções combo
	Next nCont

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "WMSX000_01" , oStruct, /*cLinkID*/ )
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:SetOwnerView("WMSX000_01","MASTER")
Return oView
//------------------------------------------------------------------------------------------------
Static Function WMSX000COM(oModel)
Local oModelPF  := oModel:GetModel('WMSX000_01')
Local aCamposPF := oModelPF:GetStruct():GetFields()
Local xConteudo := Nil
Local nCont     := 0

	For nCont := 1 To Len(aCamposPF)
		// Tratamento para gravar T e F
		If AllTrim(aCamposPF[nCont][3]) == "MV_WMSCOMP"
			If oModel:GetValue("WMSX000_01",aCamposPF[nCont][3])
				xConteudo := "T"
			Else
				xConteudo := "F"
			EndIf
		Else
			// Tratamento para gravar conteúdo S e N nos parâmetos da lista
			If aScan(aFldCnvToL,{|x| AllTrim(x) == AllTrim(aCamposPF[nCont][3])})
				If oModel:GetValue("WMSX000_01",aCamposPF[nCont][3])
					xConteudo := "S"
				Else
					xConteudo := "N"
				EndIf
			Else
				xConteudo := oModel:GetValue("WMSX000_01",aCamposPF[nCont][3])
			EndIf
		EndIf
		
		PUTMV(aCamposPF[nCont][3],xConteudo)
	Next nCont
Return .T.
//------------------------------------------------------------------------------------------------
Static Function GetHelp(cParam,cFilVazia)
Local cDesc := ""

	If SX6->( dbSeek(cFilAnt+cParam) ) .Or. (SX6->( dbSeek(cFilVazia+cParam) ))
		cDesc := AllTrim(X6Descric())+" "+AllTrim(X6Desc1())+" "+AllTrim(X6Desc2())
	EndIf

Return cParam+" | "+cDesc
