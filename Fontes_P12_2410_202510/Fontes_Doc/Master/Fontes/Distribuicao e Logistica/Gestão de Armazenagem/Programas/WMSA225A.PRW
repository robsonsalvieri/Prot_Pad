#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSA225A.CH"

Static nOperation := WMSA225OPT()
Static lPermTrfBlq := SuperGetMv("MV_WMSTRBL",.F.,.F.)
//-------------------------------------
/*/{Protheus.doc} WMSA225A
Tranferencia entre endereços e entre armazéns por Unitizador
@author felipe.m
@since 26/05/2017
@version 1.0
/*/
//-------------------------------------
Function WMSA225ADUMMY()
Return
//-------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@author felipe.m
@since 26/05/2017
@version 1.0
/*/
//-------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStrDCF := FWFormStruct(1,"DCF")
Local oStrUnit := FWFormModelStruct():New()
Local oStrPrdUni := FWFormModelStruct():New()
Local oStrSel := FWFormModelStruct():New()
Local aColsSx3 := {}
Local cDocto := ""

	oModel := MPFormModel():New("WMSA225A",,{|oModel| WMS225VMdl(oModel) },{|oModel| WMS225Cmmt(oModel) })
	oModel:AddFields("DCFMASTER",,oStrDCF)
	oModel:SetDescription(STR0001) // Tranferência WMS
	oModel:GetModel("DCFMASTER"):SetDescription(STR0001) // Tranferência WMS

	oStrDCF:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)

	If nOperation == MODEL_OPERATION_INSERT
		oStrUnit:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)
		oStrPrdUni:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)
		oStrDCF:SetProperty("DCF_DOCTO",MODEL_FIELD_INIT,{|| cDocto := GetSX8Num("DCF","DCF_DOCTO"),Iif(__lSX8,ConfirmSX8(),Nil),cDocto })

		// Monta Struct dos unitizadores no estoque
		oStrUnit:AddTable("UNITIZ", {"IDUNIT"},STR0035) // Unitizador Estoque
		oStrUnit:AddIndex(1,"1","IDUNIT",STR0002,"","",.T.)

		buscarSX3("D14_OK",,aColsSX3);     oStrUnit:AddField(aColsSX3[1],""     ,"OK"     ,"L",aColsSX3[3],aColsSX3[4],{|A,B,C,D| SetAfter(A,B,C,D,oModel)},{||.T.},Nil,.F.,,.F.,.F.,.F.) // cTitulo ,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid // Unitizador
		buscarSX3("D14_IDUNIT",,aColsSX3); oStrUnit:AddField(aColsSX3[1],STR0002,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
		buscarSX3("D14_CODUNI",,aColsSX3); oStrUnit:AddField(aColsSX3[1],STR0003,"CODUNI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Tipo Unitizador
		buscarSX3("D14_LOCAL",,aColsSX3);  oStrUnit:AddField(aColsSX3[1],STR0004,"LOCAL"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Armazém
		buscarSX3("D14_ENDER",,aColsSX3);  oStrUnit:AddField(aColsSX3[1],STR0005,"ENDER"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Endereço
		buscarSX3("D14_ESTFIS",,aColsSX3); oStrUnit:AddField(aColsSX3[1],STR0006,"ESTFIS" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Estrutura Física
		buscarSX3("D14_PRIOR",,aColsSX3);  oStrUnit:AddField(aColsSX3[1],STR0007,"PRIOR"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Prioridade

		oModel:AddGrid("UNITIZ","DCFMASTER",oStrUnit)
		oModel:GetModel('UNITIZ'):SetOptional(.T.)
		oModel:GetModel('UNITIZ'):SetOnlyQuery(.T.)
		oModel:GetModel("UNITIZ"):SetNoInsertLine(.T.)
		oModel:GetModel("UNITIZ"):SetNoDeleteLine(.T.)

		// Monta Struct dos produtos do unitizador
		oStrPrdUni:AddTable("PRDUNI", {"PRODUT+LOTECT+NUMLOT+PRDORI"},STR0036) // Produtos Unitizador
		oStrPrdUni:AddIndex(1,"1","IDUNIT",STR0002,"","",.T.)

		buscarSX3("D14_IDUNIT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0002,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
		buscarSX3("D14_FILIAL",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0008,"FILIAL" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Filial do Sistema
		buscarSX3("D14_PRODUT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0009,"PRODUT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Produto
		buscarSX3("D14_LOTECT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0010,"LOTECT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Lote
		buscarSX3("D14_NUMLOT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0011,"NUMLOT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Sub-Lote
		buscarSX3("D14_DTVALD",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0012,"DTVALD" ,"D",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Data de Validade
		buscarSX3("D14_DTFABR",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0013,"DTFABR" ,"D",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Data de Fabricação
		buscarSX3("D14_QTDEST",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0014,"QTDEST" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade em Estoque
		buscarSX3("D14_QTDES2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0015,"QTDES2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Qt Estoque 2 UM
		buscarSX3("D14_QTDEPR",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0016,"QTDEPR" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Entrada Prevista
		buscarSX3("D14_QTDEP2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0017,"QTDEP2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Ent. Prev. 2UM
		buscarSX3("D14_QTDSPR",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0018,"QTDSPR" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Saída Prevista
		buscarSX3("D14_QTDSP2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0019,"QTDSP2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Saída Prev 2UM
		buscarSX3("D14_QTDEMP",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0020,"QTDEMP" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Empenho
		buscarSX3("D14_QTDEM2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0021,"QTDEM2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Empenho 2UM
		buscarSX3("D14_QTDBLQ",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0022,"QTDBLQ" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Bloqueada
		buscarSX3("D14_QTDBL2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0023,"QTDBL2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Bloqueada 2UM
		buscarSX3("D14_QTDPEM",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0024,"QTDPEM" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Empenho Prevista
		buscarSX3("D14_QTDPE2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0025,"QTDPE2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Qtd Empenho Previsto 2UM
		buscarSX3("D14_PRDORI",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0026,"PRDORI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Produto Origem
		buscarSX3("D14_CODVOL",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0027,"CODVOL" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Código do Volume
		buscarSX3("D14_IDVOLU",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0028,"IDVOLU" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Identificador Volume

		oModel:AddGrid("PRDUNI","UNITIZ",oStrPrdUni)
		oModel:SetRelation("PRDUNI",{{"IDUNIT","IDUNIT"}})
		oModel:GetModel('PRDUNI'):SetOptional(.T.)
		oModel:GetModel('PRDUNI'):SetOnlyQuery(.T.)
		oModel:GetModel("PRDUNI"):SetNoInsertLine(.T.)
		oModel:GetModel("PRDUNI"):SetNoUpdateLine(.T.)
		oModel:GetModel("PRDUNI"):SetNoDeleteLine(.T.)

		// Monta Struct das multiplas DCFs
		oStrSel:AddTable("SELECAO", {"IDUNIT"},STR0037) // Unitizadores selecionados
		oStrSel:AddIndex(1,"1","IDUNIT",STR0002,"","",.T.)

		buscarSX3("D14_IDUNIT",,aColsSX3); oStrSel:AddField(aColsSX3[1],STR0002,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // cTitulo ,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid // Unitizador
		buscarSX3("DCF_QUANT",,aColsSX3);  oStrSel:AddField(aColsSX3[1],STR0029,"QUANT"  ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Quantidade
		buscarSX3("B5_SERVINT",,aColsSX3); oStrSel:AddField(aColsSX3[1],STR0030,"SERVIC" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Serviço de Transferência
		buscarSX3("D14_LOCAL",,aColsSX3);  oStrSel:AddField(aColsSX3[1],STR0031,"LOCAL"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Armazém Origem
		buscarSX3("D14_ENDER",,aColsSX3);  oStrSel:AddField(aColsSX3[1],STR0032,"ENDER"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Endereço Destino
		buscarSX3("DCF_LOCDES",,aColsSX3); oStrSel:AddField(aColsSX3[1],STR0033,"LOCDES" ,"C",aColsSX3[3],aColsSX3[4],{|A,B,C,D,E| WMS225VFld(A,B,C,D,E) },{||.T.},Nil,.F.,,.F.,.T.,.F.) // Armazém Destino
		buscarSX3("DCF_ENDDES",,aColsSX3); oStrSel:AddField(aColsSX3[1],STR0034,"ENDDES" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Endereço Destino
		buscarSX3("DCF_UNIDES",,aColsSX3); oStrSel:AddField(aColsSX3[1],STR0039,"UNIDES" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
		buscarSX3("D14_CODUNI",,aColsSX3); oStrSel:AddField(aColsSX3[1],STR0041,"CODUNI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Tipo Unitizador

		oModel:AddGrid("SELECAO","DCFMASTER",oStrSel)
		oModel:GetModel("SELECAO"):SetOnlyQuery(.T.)
		oModel:GetModel("SELECAO"):SetOptional(.T.)
		oModel:GetModel("SELECAO"):SetNoInsertLine(.T.)
		oModel:GetModel("SELECAO"):SetNoDeleteLine(.T.)
	EndIf
	oModel:SetActivate({|oModel| ActiveModel(oModel) } )
Return oModel
//-------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author felipe.m
@since 26/05/2017
@version 1.0
/*/
//-------------------------------------
Static Function ViewDef()
Local nI := 1
Local oModel :=  ModelDef()
Local oStrDCF := FWFormStruct(2,"DCF")
Local oStrUnit := FWFormViewStruct():New()
Local oStrPrdUni := FWFormViewStruct():New()
Local oStrSel := FWFormViewStruct():New()
Local oView := Nil
Local aColsSX3 := {}

	oView := FWFormView():New()
	oView:SetModel(oModel)

	If nOperation == MODEL_OPERATION_INSERT
		// Monta Struct dos unitizadores no estoque
		buscarSX3("D14_OK",,aColsSX3);     oStrUnit:AddField("OK"    ,"01",""         ,""     ,Nil,"GET",aColsSX3[2],Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted
		buscarSX3("D14_IDUNIT",,aColsSX3); oStrUnit:AddField("IDUNIT","02",aColsSX3[1],STR0002,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Unitizador
		buscarSX3("D14_CODUNI",,aColsSX3); oStrUnit:AddField("CODUNI","03",aColsSX3[1],STR0003,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Tipo Unitizador
		buscarSX3("D14_LOCAL",,aColsSX3);  oStrUnit:AddField("LOCAL" ,"04",aColsSX3[1],STR0004,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Armazém
		buscarSX3("D14_ENDER",,aColsSX3);  oStrUnit:AddField("ENDER" ,"05",aColsSX3[1],STR0005,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Endereço
		buscarSX3("D14_ESTFIS",,aColsSX3); oStrUnit:AddField("ESTFIS","06",aColsSX3[1],STR0006,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Estrutura Física
		buscarSX3("D14_PRIOR",,aColsSX3);  oStrUnit:AddField("PRIOR" ,"07",aColsSX3[1],STR0007,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Prioridade

		// Monta Struct dos produtos do unitizador
		buscarSX3("D14_FILIAL",,aColsSX3); oStrPrdUni:AddField("FILIAL","01",aColsSX3[1],STR0008,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Filial do Sistema
		buscarSX3("D14_PRODUT",,aColsSX3); oStrPrdUni:AddField("PRODUT","02",aColsSX3[1],STR0009,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Produto
		buscarSX3("D14_LOTECT",,aColsSX3); oStrPrdUni:AddField("LOTECT","03",aColsSX3[1],STR0010,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Lote
		buscarSX3("D14_NUMLOT",,aColsSX3); oStrPrdUni:AddField("NUMLOT","04",aColsSX3[1],STR0011,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Sub-Lote
		buscarSX3("D14_DTVALD",,aColsSX3); oStrPrdUni:AddField("DTVALD","05",aColsSX3[1],STR0012,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Data de Validade
		buscarSX3("D14_DTFABR",,aColsSX3); oStrPrdUni:AddField("DTFABR","06",aColsSX3[1],STR0013,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Data de Fabricação
		buscarSX3("D14_QTDEST",,aColsSX3); oStrPrdUni:AddField("QTDEST","07",aColsSX3[1],STR0014,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade em Estoque
		buscarSX3("D14_QTDES2",,aColsSX3); oStrPrdUni:AddField("QTDES2","08",aColsSX3[1],STR0015,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Qt Estoque 2 UM
		buscarSX3("D14_QTDEPR",,aColsSX3); oStrPrdUni:AddField("QTDEPR","09",aColsSX3[1],STR0016,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Entrada Prevista
		buscarSX3("D14_QTDEP2",,aColsSX3); oStrPrdUni:AddField("QTDEP2","10",aColsSX3[1],STR0017,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Ent. Prev. 2UM
		buscarSX3("D14_QTDSPR",,aColsSX3); oStrPrdUni:AddField("QTDSPR","11",aColsSX3[1],STR0018,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Saída Prevista
		buscarSX3("D14_QTDSP2",,aColsSX3); oStrPrdUni:AddField("QTDSP2","12",aColsSX3[1],STR0019,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Saída Prev 2UM
		buscarSX3("D14_QTDEMP",,aColsSX3); oStrPrdUni:AddField("QTDEMP","13",aColsSX3[1],STR0020,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Empenho
		buscarSX3("D14_QTDEM2",,aColsSX3); oStrPrdUni:AddField("QTDEM2","14",aColsSX3[1],STR0021,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Empenho 2UM
		buscarSX3("D14_QTDBLQ",,aColsSX3); oStrPrdUni:AddField("QTDBLQ","15",aColsSX3[1],STR0022,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Bloqueada
		buscarSX3("D14_QTDBL2",,aColsSX3); oStrPrdUni:AddField("QTDBL2","16",aColsSX3[1],STR0023,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade Bloqueada 2UM
		buscarSX3("D14_QTDPEM",,aColsSX3); oStrPrdUni:AddField("QTDPEM","17",aColsSX3[1],STR0024,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Qtde Empenho Prevista
		buscarSX3("D14_QTDPE2",,aColsSX3); oStrPrdUni:AddField("QTDPE2","18",aColsSX3[1],STR0025,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd Empenho Previsto 2UM
		buscarSX3("D14_PRDORI",,aColsSX3); oStrPrdUni:AddField("PRDORI","19",aColsSX3[1],STR0026,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Produto Origem
		buscarSX3("D14_CODVOL",,aColsSX3); oStrPrdUni:AddField("CODVOL","20",aColsSX3[1],STR0027,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Código do Volume
		buscarSX3("D14_IDVOLU",,aColsSX3); oStrPrdUni:AddField("IDVOLU","21",aColsSX3[1],STR0028,Nil,"GET",aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Identificador Volume

		// Monta Struct da Seleção
		buscarSX3("D14_IDUNIT",,aColsSX3); oStrSel:AddField("IDUNIT","01",aColsSX3[1],STR0002,Nil,"GET",aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Código do Produto
		buscarSX3("DCF_QUANT",,aColsSX3);  oStrSel:AddField("QUANT" ,"02",aColsSX3[1],STR0029,Nil,"GET",aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade
		buscarSX3("B5_SERVINT",,aColsSX3); oStrSel:AddField("SERVIC","03",aColsSX3[1],STR0030,Nil,"GET",aColsSX3[2],Nil,"DC5",.T.,Nil,Nil,Nil,Nil,Nil,.F.) // Serviço de Transferência
		buscarSX3("D14_LOCAL",,aColsSX3);  oStrSel:AddField("LOCAL" ,"04",aColsSX3[1],STR0031,Nil,"GET",aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) //  Armazém Origem
		buscarSX3("D14_ENDER",,aColsSX3);  oStrSel:AddField("ENDER" ,"05",aColsSX3[1],STR0032,Nil,"GET",aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) //  Endereço Origem
		buscarSX3("DCF_LOCDES",,aColsSX3); oStrSel:AddField("LOCDES","06",aColsSX3[1],STR0033,Nil,"GET",aColsSX3[2],Nil,"NNR",.T.,Nil,Nil,Nil,Nil,Nil,.F.) //  Armazém Destino
		buscarSX3("DCF_ENDDES",,aColsSX3); oStrSel:AddField("ENDDES","07",aColsSX3[1],STR0034,Nil,"GET",aColsSX3[2],Nil,"SBE",.T.,Nil,Nil,Nil,Nil,Nil,.F.) //  Endereço Destino
		buscarSX3("DCF_UNIDES",,aColsSX3); oStrSel:AddField("UNIDES","08",aColsSX3[1],STR0039,Nil,"GET",aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Código do Produto

		For nI := 1 To Len(oStrDCF:aFields)
			If nI > Len(oStrDCF:aFields)
				Exit
			EndIf
			// Campos que podem aparecer em tela
			If oStrDCF:aFields[nI][1] $ "DCF_DOCTO/DCF_ORIGEM/DCF_DATA"
				Loop
			EndIf

			oStrDCF:RemoveField(oStrDCF:aFields[nI][1])
			nI--
		Next nI
	EndIf

	oStrDCF:SetProperty("*" ,MVC_VIEW_ORDEM,"99")
	oStrDCF:SetProperty("DCF_DOCTO" ,MVC_VIEW_ORDEM,"01")
	oStrDCF:SetProperty("DCF_ORIGEM",MVC_VIEW_ORDEM,"02")
	oStrDCF:SetProperty("DCF_DATA"  ,MVC_VIEW_ORDEM,"03")

	If nOperation == MODEL_OPERATION_INSERT
		oStrDCF:SetProperty("DCF_DOCTO" ,MVC_VIEW_CANCHANGE,.F.)
		oStrDCF:SetProperty("DCF_ORIGEM",MVC_VIEW_CANCHANGE,.F.)
		oStrDCF:SetProperty("DCF_DATA"  ,MVC_VIEW_CANCHANGE,.F.)
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		oStrDCF:SetProperty("*" ,MVC_VIEW_CANCHANGE,.F.)
	EndIf

	oView:AddField("DCFFORM",oStrDCF,"DCFMASTER")

	If nOperation == MODEL_OPERATION_INSERT
		oView:AddGrid("UNITIZ",oStrUnit,"UNITIZ")
		oView:EnableTitleView("UNITIZ", STR0035) // Unitizadores no Estoque

		oView:AddGrid("PRDUNI",oStrPrdUni,"PRDUNI")
		oView:EnableTitleView("PRDUNI", STR0036) // Produtos do Unitizador

		oView:AddGrid("SELECAO",oStrSel,"SELECAO")
		oView:EnableTitleView("SELECAO", STR0037) // Produtos Selecionados

		oView:CreateHorizontalBox("UP",10)
		oView:CreateHorizontalBox("MID",40)
		oView:CreateHorizontalBox("DOWN",50)

		oView:CreateVerticalBox("MIDLEFT",40,"MID")
		oView:CreateVerticalBox("MIDRIGHT",60,"MID")

		oView:SetOwnerView("DCFFORM","UP")
		oView:SetOwnerView("UNITIZ","MIDLEFT")
		oView:SetOwnerView("PRDUNI","MIDRIGHT")
		oView:SetOwnerView("SELECAO","DOWN")
		oView:AddUserButton(STR0038,'',{ |oModel| Processa({ || ProcRegua(0),MarkAll(oModel) },STR0040+"..."), oView:Refresh() }) // Marca/Desmarca todos
	Else
		oView:CreateHorizontalBox("DCFFIELDS",100)
		oView:SetOwnerView("DCFFORM","DCFFIELDS")
	EndIf
Return oView
//--------------------------------------------------
Static Function LoadUnitiz()
Local oModel    := FWModelActive()
Local cAliasQry := Nil
Local cWhere    := ""

	oModel:GetModel("UNITIZ"):SetNoInsertLine(.F.)
	oModel:GetModel("UNITIZ"):SetNoDeleteLine(.F.)
	oModel:GetModel("UNITIZ"):ClearData()
	oModel:GetModel("UNITIZ"):InitLine()
	oModel:GetModel("UNITIZ"):GoLine(1)
	
	cWhere := "%"
	If lPermTrfBlq
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR+D14.D14_QTDEMP)) > 0"
	Else
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR+D14.D14_QTDEMP+D14.D14_QTDBLQ)) > 0"
	EndIf
	cWhere += "%"

	cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT COUNT(DISTINCT D14_IDUNIT) TOTAL
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL >= %Exp:MV_PAR01% AND D14.D14_LOCAL <= %Exp:MV_PAR02%
		AND D14.D14_PRODUT >= %Exp:MV_PAR03% AND D14.D14_PRODUT <= %Exp:MV_PAR04%
		AND D14.D14_ENDER >= %Exp:MV_PAR05% AND D14.D14_ENDER <= %Exp:MV_PAR06%
		AND D14.D14_IDUNIT >= %Exp:MV_PAR07% AND D14.D14_IDUNIT <= %Exp:MV_PAR08%
		AND D14.D14_IDUNIT <> ' '
		AND D14.%NotDel%
		AND EXISTS (SELECT 1 
					FROM %Table:NNR% NNR
					WHERE NNR.NNR_FILIAL = %xFilial:NNR%
					AND NNR.NNR_CODIGO = D14.D14_LOCAL
					AND NNR.NNR_AMZUNI = '1'
					AND NNR.%NotDel%)
		%Exp:cWhere%
	EndSql

	If (cAliasQry)->TOTAL > oModel:GetModel("UNITIZ"):GetMaxLines()
		oModel:GetModel("UNITIZ"):SetMaxLine((cAliasQry)->TOTAL)
	EndIf

	(cAliasQry)->(dbCloseArea())

	BeginSql Alias cAliasQry
		SELECT D14.D14_IDUNIT,
				D14.D14_CODUNI,
				D14.D14_LOCAL,
				D14.D14_ENDER,
				D14.D14_ESTFIS,
				D14.D14_PRIOR
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL >= %Exp:MV_PAR01% AND D14.D14_LOCAL <= %Exp:MV_PAR02%
		AND D14.D14_PRODUT >= %Exp:MV_PAR03% AND D14.D14_PRODUT <= %Exp:MV_PAR04%
		AND D14.D14_ENDER >= %Exp:MV_PAR05% AND D14.D14_ENDER <= %Exp:MV_PAR06%
		AND D14.D14_IDUNIT >= %Exp:MV_PAR07% AND D14.D14_IDUNIT <= %Exp:MV_PAR08%
		AND D14.D14_IDUNIT <> ' '
		AND D14.%NotDel%
		AND EXISTS (SELECT 1 
					FROM %Table:NNR% NNR
					WHERE NNR.NNR_FILIAL = %xFilial:NNR%
					AND NNR.NNR_CODIGO = D14.D14_LOCAL
					AND NNR.NNR_AMZUNI = '1'
					AND NNR.%NotDel% )
		%Exp:cWhere%
		GROUP BY D14.D14_IDUNIT,
					D14.D14_CODUNI,
					D14.D14_LOCAL,
					D14.D14_ENDER,
					D14.D14_ESTFIS,
					D14.D14_PRIOR
		ORDER BY D14.D14_IDUNIT
	EndSql
	Do While (cAliasQry)->(!Eof())
		If !Empty(oModel:GetModel("UNITIZ"):GetValue("IDUNIT", oModel:GetModel("UNITIZ"):Length()))
			oModel:GetModel("UNITIZ"):AddLine()
			oModel:GetModel("UNITIZ"):GoLine(oModel:GetModel("UNITIZ"):Length())
		EndIf

		oModel:GetModel("UNITIZ"):LoadValue("OK",    .F. )
		oModel:GetModel("UNITIZ"):LoadValue("IDUNIT",(cAliasQry)->D14_IDUNIT )
		oModel:GetModel("UNITIZ"):LoadValue("CODUNI",(cAliasQry)->D14_CODUNI )
		oModel:GetModel("UNITIZ"):LoadValue("LOCAL" ,(cAliasQry)->D14_LOCAL )
		oModel:GetModel("UNITIZ"):LoadValue("ENDER" ,(cAliasQry)->D14_ENDER )
		oModel:GetModel("UNITIZ"):LoadValue("ESTFIS",(cAliasQry)->D14_ESTFIS )
		oModel:GetModel("UNITIZ"):LoadValue("PRIOR" ,(cAliasQry)->D14_PRIOR )

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	oModel:GetModel("UNITIZ"):SetNoInsertLine(.T.)
	oModel:GetModel("UNITIZ"):SetNoDeleteLine(.T.)
	oModel:GetModel("UNITIZ"):GoLine(1)
Return Nil
//--------------------------------------------------
Static Function LoadProdut()
Local oModel    := FWModelActive()
Local cAliasQry := Nil

	oModel:GetModel("PRDUNI"):SetNoInsertLine(.F.)
	oModel:GetModel("PRDUNI"):SetNoUpDateLine(.F.)
	oModel:GetModel("PRDUNI"):SetNoDeleteLine(.F.)
	oModel:GetModel("PRDUNI"):ClearData()
	oModel:GetModel("PRDUNI"):InitLine()
	oModel:GetModel("PRDUNI"):GoLine(1)

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT Count(1)	TOTAL
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:oModel:GetModel("UNITIZ"):GetValue("IDUNIT")%
		AND D14.%NotDel%
	EndSql

	If (cAliasQry)->TOTAL > oModel:GetModel("PRDUNI"):GetMaxLines()
		oModel:GetModel("PRDUNI"):SetMaxLine((cAliasQry)->TOTAL)
	EndIf

	(cAliasQry)->(dbCloseArea())

	BeginSql Alias cAliasQry
		SELECT D14.D14_IDUNIT,
				D14.D14_FILIAL,
				D14.D14_PRODUT,
				D14.D14_LOTECT,
				D14.D14_NUMLOT,
				D14.D14_DTVALD,
				D14.D14_DTFABR,
				D14.D14_QTDEST,
				D14.D14_QTDES2,
				D14.D14_QTDEPR,
				D14.D14_QTDEP2,
				D14.D14_QTDSPR,
				D14.D14_QTDSP2,
				D14.D14_QTDEMP,
				D14.D14_QTDEM2,
				D14.D14_QTDBLQ,
				D14.D14_QTDBL2,
				D14.D14_QTDPEM,
				D14.D14_QTDPE2,
				D14.D14_PRDORI,
				D14.D14_CODVOL,
				D14.D14_IDVOLU
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:oModel:GetModel("UNITIZ"):GetValue("IDUNIT")%
		AND D14.%NotDel%
		ORDER BY D14.D14_IDUNIT
	EndSql
	Do While (cAliasQry)->(!Eof())
		If !Empty(oModel:GetModel("PRDUNI"):GetValue("IDUNIT", oModel:GetModel("PRDUNI"):Length()))
			oModel:GetModel("PRDUNI"):AddLine()
			oModel:GetModel("PRDUNI"):GoLine(oModel:GetModel("PRDUNI"):Length())
		EndIf
		oModel:GetModel("PRDUNI"):LoadValue("IDUNIT",(cAliasQry)->D14_IDUNIT)
		oModel:GetModel("PRDUNI"):LoadValue("FILIAL",(cAliasQry)->D14_FILIAL)
		oModel:GetModel("PRDUNI"):LoadValue("PRODUT",(cAliasQry)->D14_PRODUT)
		oModel:GetModel("PRDUNI"):LoadValue("LOTECT",(cAliasQry)->D14_LOTECT)
		oModel:GetModel("PRDUNI"):LoadValue("NUMLOT",(cAliasQry)->D14_NUMLOT)
		oModel:GetModel("PRDUNI"):LoadValue("DTVALD",StoD((cAliasQry)->D14_DTVALD))
		oModel:GetModel("PRDUNI"):LoadValue("DTFABR",StoD((cAliasQry)->D14_DTFABR))
		oModel:GetModel("PRDUNI"):LoadValue("QTDEST",(cAliasQry)->D14_QTDEST)
		oModel:GetModel("PRDUNI"):LoadValue("QTDES2",(cAliasQry)->D14_QTDES2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEPR",(cAliasQry)->D14_QTDEPR)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEP2",(cAliasQry)->D14_QTDEP2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDSPR",(cAliasQry)->D14_QTDSPR)
		oModel:GetModel("PRDUNI"):LoadValue("QTDSP2",(cAliasQry)->D14_QTDSP2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEMP",(cAliasQry)->D14_QTDEMP)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEM2",(cAliasQry)->D14_QTDEM2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDBLQ",(cAliasQry)->D14_QTDBLQ)
		oModel:GetModel("PRDUNI"):LoadValue("QTDBL2",(cAliasQry)->D14_QTDBL2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDPEM",(cAliasQry)->D14_QTDPEM)
		oModel:GetModel("PRDUNI"):LoadValue("QTDPE2",(cAliasQry)->D14_QTDPE2)
		oModel:GetModel("PRDUNI"):LoadValue("PRDORI",(cAliasQry)->D14_PRDORI)
		oModel:GetModel("PRDUNI"):LoadValue("CODVOL",(cAliasQry)->D14_CODVOL)
		oModel:GetModel("PRDUNI"):LoadValue("IDVOLU",(cAliasQry)->D14_IDVOLU)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	oModel:GetModel("PRDUNI"):SetNoInsertLine(.T.)
	oModel:GetModel("PRDUNI"):SetNoUpDateLine(.T.)
	oModel:GetModel("PRDUNI"):SetNoDeleteLine(.T.)
	oModel:GetModel("PRDUNI"):GoLine(1)
Return Nil

Static Function SetAfter(oMdlGrid,cCampo,lMark,nLine,oModel)
Local aAreaAnt := GetArea()
Local oView := FWViewActive()
Local nI := 0
Local aSelecao := {}

	oModel:GetModel("SELECAO"):SetNoInsertLine(.F.)
	oModel:GetModel("SELECAO"):SetNoDeleteLine(.F.)
	If lMark
		If !oModel:GetModel("SELECAO"):SeekLine( { {"IDUNIT",oMdlGrid:GetValue("IDUNIT",nLine)} } )
			If !Empty(oModel:GetModel("SELECAO"):GetValue("IDUNIT"))
				oModel:GetModel("SELECAO"):AddLine()
			EndIf

			oModel:GetModel("SELECAO"):LoadValue("IDUNIT",oMdlGrid:GetValue("IDUNIT",nLine) )
			oModel:GetModel("SELECAO"):LoadValue("QUANT" ,1 )
			oModel:GetModel("SELECAO"):LoadValue("SERVIC",Posicione("SB5",1,xFilial("SB5")+oModel:GetModel("PRDUNI"):GetValue("PRODUT",1),"B5_SERVINT") )
			oModel:GetModel("SELECAO"):LoadValue("LOCAL" ,oMdlGrid:GetValue("LOCAL",nLine) )
			oModel:GetModel("SELECAO"):LoadValue("ENDER" ,oMdlGrid:GetValue("ENDER",nLine) )
			oModel:GetModel("SELECAO"):LoadValue("CODUNI",oMdlGrid:GetValue("CODUNI",nLine) )
			oModel:GetModel("SELECAO"):LoadValue("UNIDES",oMdlGrid:GetValue("IDUNIT",nLine) )
			oModel:GetModel("SELECAO"):SetValue("LOCDES" ,oMdlGrid:GetValue("LOCAL",nLine) )
		EndIf
	Else
		If oModel:GetModel("SELECAO"):SeekLine( { {"IDUNIT",oMdlGrid:GetValue("IDUNIT",nLine)} } )
			oModel:GetModel("SELECAO"):DeleteLine()
		EndIf

		For nI := 1 To oModel:GetModel("SELECAO"):Length()
			oModel:GetModel("SELECAO"):GoLine(nI)
			If !oModel:GetModel("SELECAO"):IsDeleted()
				aAdd(aSelecao,{ oModel:GetModel("SELECAO"):GetValue("IDUNIT",nI),;
								  oModel:GetModel("SELECAO"):GetValue("QUANT" ,nI),;
								  oModel:GetModel("SELECAO"):GetValue("SERVIC",nI),;
								  oModel:GetModel("SELECAO"):GetValue("LOCAL" ,nI),;
								  oModel:GetModel("SELECAO"):GetValue("ENDER" ,nI),;
								  oModel:GetModel("SELECAO"):GetValue("LOCDES",nI),;
								  oModel:GetModel("SELECAO"):GetValue("ENDDES",nI),;
								  oModel:GetModel("SELECAO"):GetValue("UNIDES",nI),;
								  oModel:GetModel("SELECAO"):GetValue("CODUNI",nI)})
			EndIf
		Next nI

		oModel:GetModel("SELECAO"):ClearData()
		oModel:GetModel("SELECAO"):InitLine()
		oModel:GetModel("SELECAO"):GoLine(1)

		For nI := 1 To Len(aSelecao)
			If !Empty(oModel:GetModel("SELECAO"):GetValue("IDUNIT"))
				oModel:GetModel("SELECAO"):AddLine()
				oModel:GetModel("SELECAO"):GoLine(nI)
			EndIf

			oModel:GetModel("SELECAO"):LoadValue("IDUNIT",aSelecao[nI][1])
			oModel:GetModel("SELECAO"):LoadValue("QUANT" ,aSelecao[nI][2])
			oModel:GetModel("SELECAO"):LoadValue("SERVIC",aSelecao[nI][3])
			oModel:GetModel("SELECAO"):LoadValue("LOCAL" ,aSelecao[nI][4]) 	
			oModel:GetModel("SELECAO"):LoadValue("ENDER" ,aSelecao[nI][5])
			oModel:GetModel("SELECAO"):LoadValue("LOCDES",aSelecao[nI][6])
			oModel:GetModel("SELECAO"):LoadValue("ENDDES",aSelecao[nI][7])
			oModel:GetModel("SELECAO"):LoadValue("UNIDES",aSelecao[nI][8])
			oModel:GetModel("SELECAO"):LoadValue("CODUNI",aSelecao[nI][9])
		Next nI
	EndIf

	oModel:GetModel("SELECAO"):SetNoInsertLine(.T.)
	oModel:GetModel("SELECAO"):SetNoDeleteLine(.T.)
	oModel:GetModel("SELECAO"):GoLine(1)

	oView:Refresh()
	RestArea(aAreaAnt)
Return .T.

Static Function ActiveModel(oModel)
Local nI := 0
	If nOperation == MODEL_OPERATION_INSERT
		// O modelo precisa sofrer alteração
		oModel:LoadValue("DCFMASTER","DCF_DOCTO",oModel:GetValue("DCFMASTER","DCF_DOCTO"))
		// Carrega a Grid dos Unitizadores em Estoque
		LoadUnitiz()
		For nI := 1 To oModel:GetModel("UNITIZ"):Length()
			oModel:GetModel("UNITIZ"):GoLine(nI)
			// Carrega a Grid dos Produtos do Unitizador
			If !Empty(oModel:GetModel("UNITIZ"):GetValue("IDUNIT"))
				LoadProdut()
			EndIf
		Next nI
		oModel:GetModel("UNITIZ"):GoLine(1)
	EndIf
Return .T.

Static lMarkAll := .F.
Static Function MarkAll(oModel)
Local oView := FWViewActive()
Local nI := 1

	lMarkAll := Iif(lMarkAll,.F.,.T.)
	For nI := 1 To oModel:GetModel("UNITIZ"):Length()
		oModel:GetModel("UNITIZ"):GoLine(nI)
		oModel:GetModel("UNITIZ"):SetValue("OK",lMarkAll)
	Next nI
	oModel:GetModel("UNITIZ"):GoLine(1)
	oModel:GetModel("SELECAO"):GoLine(1)
	oView:Refresh()
Return .T.
