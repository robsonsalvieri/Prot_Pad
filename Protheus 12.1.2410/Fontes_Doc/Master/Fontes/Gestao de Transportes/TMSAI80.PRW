#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI80.CH"
#INCLUDE "FWMVCDEF.CH"

Static nFolderAtu := 1

/*{Protheus.doc} TMSAI80
Configuração das Integrações
@type Function
@author Valdemar Roberto Mognon
@since 23/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI80()
(examples)
@see (links_or_references)
*/
Function TMSAI80()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DN0")
oBrowse:SetMenuDef("TMSAI80")
oBrowse:SetDescription(STR0001)	//-- Configuração das Integrações
oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/02/2022
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//-- Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI80" OPERATION 2 ACCESS 0	//-- Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAI80" OPERATION 3 ACCESS 0	//-- Incluir
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAI80" OPERATION 4 ACCESS 0	//-- Alterar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAI80" OPERATION 5 ACCESS 0	//-- Excluir

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 23/02/2022
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/

Static Function ModelDef()
Local oModel	:= Nil
Local oStruDN0	:= FwFormStruct(1,"DN0")
Local oStruDN1	:= FwFormStruct(1,"DN1")
Local oStruDND	:= Nil
Local oStruDNM	:= Nil
Local oStruDNS  := Nil
Local oStruDNT  := Nil
Local lDND		:= AliasInDic("DND")

If lDND
	oStruDND := FwFormStruct(1,"DND")
EndIf

oModel := MpFormModel():New("TMSAI80", /*bPreValidacao*/, /*bPreValidacao*/, /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription(STR0001)	//-- Configuração das Integrações

//-- Cabeçalho
oModel:AddFields("MdFieldDN0",,oStruDN0,,,)
oModel:SetPrimaryKey({"DN0_CODIGO"})
oModel:GetModel("MdFieldDN0"):SetDescription(STR0001)	//-- Configuração das Integrações

//-- Coleta/Entrega
oModel:AddGrid("MdGridDN1","MdFieldDN0",oStruDN1,,,, {|oMdl| TMSAI80Vld(oMdl) } )
oModel:SetRelation("MdGridDN1",{{"DN1_FILIAL","xFilial('DN1')"},;
								{"DN1_CODCON","DN0_CODIGO"}},;
								DN1->(IndexKey(1)))
oModel:GetModel("MdGridDN1"):SetDescription( STR0029 ) //-- "Autorização"
oModel:GetModel("MdGridDN1"):SetUniqueLine({"DN1_SEQUEN"})
oModel:GetModel('MdGridDN1'):SetOptional(.T.)

If lDND
	//-- Portal Logistico
	oModel:AddGrid( "MdGridDND", "MdFieldDN0", oStruDND, , , , { |oMdl| TMSAI80Vld(oMdl) } )
	oModel:SetRelation("MdGridDND", {	{ "DND_FILIAL", "xFilial('DND')"},;
										{ "DND_CODCON", "DN0_CODIGO"	} },;
									DND->( IndexKey(1) ) )
	oModel:GetModel("MdGridDND"):SetDescription(STR0023)	//-- Portal Logistico
	oModel:GetModel("MdGridDND"):SetUniqueLine({"DND_SEQUEN"})
	oModel:GetModel('MdGridDND'):SetOptional(.T.)
EndIf

If AliasInDic("DNM")
	//-- Here
	oStruDNM := FwFormStruct(1,"DNM")
	oModel:AddGrid("MdGridDNM","MdFieldDN0",oStruDNM, , , , {|oMdl| TMSAI80Vld(oMdl)})
	oModel:SetRelation("MdGridDNM",{{"DNM_FILIAL","xFilial('DNM')"},;
									{"DNM_CODCON","DN0_CODIGO"}},;
									DNM->(IndexKey(1)))
	oModel:GetModel("MdGridDNM"):SetDescription(STR0024)	//-- Here
	oModel:GetModel("MdGridDNM"):SetUniqueLine({"DNM_SEQUEN"})
	oModel:GetModel("MdGridDNM"):SetOptional(.T.)
EndIf

If AliasInDic("DNS")
	//-- YMS
	oStruDNS := FwFormStruct(1,"DNS")
	oModel:AddGrid("MdGridDNS","MdFieldDN0",oStruDNS, , , , {|oMdl| TMSAI80Vld(oMdl)})
	oModel:SetRelation("MdGridDNS",{{"DNS_FILIAL","xFilial('DNS')"},;
									{"DNS_CODCON","DN0_CODIGO"}},;
									DNS->(IndexKey(1)))
	oModel:GetModel("MdGridDNS"):SetDescription("YMS")	//-- YMS
	oModel:GetModel("MdGridDNS"):SetUniqueLine({"DNS_SEQUEN"})
	oModel:GetModel("MdGridDNS"):SetOptional(.T.)
EndIf

If AliasInDic("DNT")
	//-- Agendamento
	oStruDNT := FwFormStruct( 1, "DNT" )
	oModel:AddGrid(	"MdGridDNT", "MdFieldDN0", oStruDNT, , , , {|oMdl| TMSAI80Vld(oMdl)})
	oModel:SetRelation( "MdGridDNT", {	{ "DNT_FILIAL", "xFilial('DNT')"},;
										{ "DNT_CODCON", "DN0_CODIGO"	}	},;
									 DNT->( IndexKey(1) ) )
	oModel:GetModel("MdGridDNT"):SetDescription( STR0025 )	//-- Agendamento
	oModel:GetModel("MdGridDNT"):SetUniqueLine( { "DNT_SEQUEN" } )
	oModel:GetModel("MdGridDNT"):SetOptional( .T. )
EndIf

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 23/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/

Static Function ViewDef()
Local oModel	:= FwLoadModel("TMSAI80")
Local oStruDN0	:= FwFormStruct(2,"DN0")
Local oStruDN1	:= FwFormStruct(2,"DN1")
Local oView		:= Nil
Local oStruDND	:= Nil
Local oStruDNM	:= Nil
Local oStruDNS	:= Nil
Local oStruDNT	:= Nil
Local lDND		:= AliasInDic("DND")

If lDND
	oStruDND := FwFormStruct(2,"DND")
EndIf

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define o tamanho da tela principal
oView:CreateHorizontalBox("Cabecalho",025)
oView:CreateHorizontalBox("Itens"    ,075)

//-- Cria área da tabela pai
oView:AddField("VwFieldDN0",oStruDN0,"MdFieldDN0") 
oView:EnableTitleView("VwFieldDN0",STR0001)	//-- Configuração das Integrações
oView:SetOwnerView("VwFieldDN0","Cabecalho")

//-- Cria o Folder dos Itens
oView:CreateFolder("Folder1","Itens")

//-- Cria Abas do Folder dos Itens
oView:AddSheet("Folder1","Sheet1_Folder1", STR0029 ) //-- Autorização

If lDND
	oView:AddSheet("Folder1","Sheet2_Folder1",STR0023)	//-- Portal Logístico
EndIf

If AliasInDic("DNM")
	oView:AddSheet("Folder1","Sheet3_Folder1",STR0024)	//-- Here
EndIf

If AliasInDic("DNS")
	oView:AddSheet("Folder1","Sheet4_Folder1","YMS")	//-- YMS
EndIf

If AliasInDic("DNT")
	oView:AddSheet("Folder1","Sheet5_Folder1",STR0025)	//-- Agendamento
EndIf

//-- Define os Boxes das Abas do Folder dos Itens
oView:CreateHorizontalBox("BoxItensDN1",100,,,"Folder1","Sheet1_Folder1")

If lDND
	oView:CreateHorizontalBox("BoxItensDND",100,,,"Folder1","Sheet2_Folder1")
EndIf

If AliasInDic("DNM")
	oView:CreateHorizontalBox("BoxItensDNM",100,,,"Folder1","Sheet3_Folder1")
EndIf

If AliasInDic("DNS")
	oView:CreateHorizontalBox("BoxItensDNS",100,,,"Folder1","Sheet4_Folder1")
EndIf

If AliasInDic("DNT")
	oView:CreateHorizontalBox("BoxItensDNT",100,,,"Folder1","Sheet5_Folder1")
EndIf

//-- Coleta/Entrega
oView:AddGrid("VwGridDN1",oStruDN1,"MdGridDN1")
oView:EnableTitleView("VwGridDN1",STR0008)	//-- Coleta/Entrega
oView:SetOwnerView("VwGridDN1","BoxItensDN1")
oView:AddIncrementField("VwGridDN1","DN1_SEQUEN")

If lDND
	//-- Portal Logistica
	oView:AddGrid( "VwGridDND", oStruDND, "MdGridDND" )
	oView:EnableTitleView( "VwGridDND", STR0023 )	//-- Portal Logístico
	oView:SetOwnerView( "VwGridDND", "BoxItensDND" )
	oView:AddIncrementField( "VwGridDND", "DND_SEQUEN" )
EndIf

If AliasInDic("DNM")
	//-- Here
	oStruDNM := FwFormStruct(2,"DNM")
	oView:AddGrid("VwGridDNM",oStruDNM,"MdGridDNM")
	oView:EnableTitleView("VwGridDNM",STR0024)	//-- Here
	oView:SetOwnerView("VwGridDNM","BoxItensDNM")
	oView:AddIncrementField("VwGridDNM","DNM_SEQUEN")
EndIf

If AliasInDic("DNS")
	//-- YMS
	oStruDNS := FwFormStruct(2,"DNS")
	oStruDNS:RemoveField("DNS_QTDENV")
	oView:AddGrid("VwGridDNS",oStruDNS,"MdGridDNS")
	oView:EnableTitleView("VwGridDNS","YMS")	//-- YMS
	oView:SetOwnerView("VwGridDNS","BoxItensDNS")
	oView:AddIncrementField("VwGridDNS","DNS_SEQUEN")
EndIf

If AliasInDic("DNT")
	//-- Agendamento
	oStruDNT := FwFormStruct(2,"DNT")
	oStruDNT:RemoveField("DNT_QTDENV")
	oView:AddGrid("VwGridDNT",oStruDNT,"MdGridDNT")
	oView:EnableTitleView("VwGridDNT",STR0025)	//-- "Agendamento"
	oView:SetOwnerView("VwGridDNT","BoxItensDNT")
	oView:AddIncrementField("VwGridDNT","DNT_SEQUEN")
EndIf

oView:SetVldFolder({|cID,nOldSheet, nSelSheet| TMSAI80Tst(cID,nOldSheet,nSelSheet)})

oView:AddUserButton( STR0009, "", { |oView| TMSAI80BTo(oModel) }, , , { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } )	//-- Teste Token

Return oView

/*{Protheus.doc} TMSAI80BTo
Definição do Botão do Teste do Token
@type Static Function
@author Valdemar Roberto Mognon
@since 24/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI80BTo()
(examples)
@see (links_or_references)
*/
Static Function TMSAI80BTo(oModel)
Local aResult := {}
Local cAlias  := ""
Local oToken
Local cClientID,cSecret,cACRval,cUserName,cPass,cUrlToke
Local oModelAtu

DEFAULT oModel := FWModelActive()

	cAlias := oModel:aAllSubModels[nFolderAtu + 1]:cOrderBy
	If At("_",cAlias) > 0
		cAlias := Left(cAlias,At("_",cAlias) - 1)
	EndIf

	If cAlias $ "DN1:DND:DNM:DNS:DNT"

		oModelAtu := oModel:GetModel("MdGrid" + cAlias)

		If cAlias != "DNM"
			cClientID := AllTrim( oModelAtu:GetValue( cAlias + "_ID"		) )
			cSecret   := AllTrim( oModelAtu:GetValue( cAlias + "_SECRET"	) )
			cACRval   := AllTrim( oModelAtu:GetValue( cAlias + "_TENANT"	) )
		EndIf
		cUserName := AllTrim( oModelAtu:GetValue( cAlias + "_USER"		) )
		cPass     := AllTrim( oModelAtu:GetValue( cAlias + "_PASSW"	) )
		cUrlToke  := AllTrim( oModelAtu:GetValue( cAlias + "_URLTOK"	) )

		oToken := TMSBCACOLENT():New(cAlias)
		Processa({|lEnd| aResult := oToken:GetToken(cClientID,cSecret,cACRval,cUserName,cPass,cUrlToke,.F.) },,STR0010,.T.)	//-- Processando...

		If aResult[1]		
			MsgInfo(STR0011 + SubStr(aResult[2],1,50),STR0012)	//-- Resultado
		Else
			MsgStop(oToken:last_error + CRLF + oToken:desc_error,STR0012)	//-- Resultado
		EndIf

	EndIf

Return

/*{Protheus.doc} TMSAI80VlA
Valida ativação de configuração.
Não pode haver mais de uma configuração ativa para o mesmo módulo (por filial no caso de exclusivo)
@author Carlos A. Gomes Jr.
@since 18/03/2022
*/
Function TMSAI80VlA()
Local aAreas  := { GetArea("DN0"), GetArea() }
Local lRet    := .T.

	If M->DN0_ATIVO == "1"
		DN0->(DbSetOrder(2))
		If DN0->(MsSeek(xFilial("DN0")+StrZero(M->DN0_CODMOD,TamSX3("DN0_CODMOD")[1])+"1")) .And. M->DN0_CODIGO != DN0->DN0_CODIGO
			Help( '', 1, "TMSAI8001", , STR0014, 1,,,,,,, {STR0015 + DN0->DN0_CODIGO + STR0016} )	//-- "Não pode haver mais de uma configuração ativa para o mesmo módulo." # "Desative a configuração: " # " antes de continuar."
			lRet := .F.
		EndIf
	EndIf
	
	AEval( aAreas, {|aArea| RestArea(aArea) } )

Return lRet

/*{Protheus.doc} TMSAI80Vld()
Validação 
@author Carlos A. Gomes Jr.
@since 18/03/2022
*/
Function TMSAI80Vld(oModel)
	Local nLin      := 0
	Local lRet      := .T.
	Local nQtdAtivo := 0
	Local cFolder   := ""
	Local lDefEsp   := DN1->(ColumnPos("DN1_DEFESP")) > 0
	Local aDefEsp   := {}

	If oModel:cID == "MdGridDN1"
		cFolder := STR0029 //-- "Autorização"
		If !lDefEsp
			cAlias  := "DN1"
		EndIf
	ElseIf oModel:cID == "MdGridDND"
		cAlias  := "DND"
		cFolder := STR0023	//-- "Portal Logístico"
	ElseIf oModel:cID == "MdGridDNM"
		cAlias  := "DNM"
		cFolder := STR0024	//-- "Here"
	ElseIf oModel:cID == "MdGridDNS"
		cAlias  := "DNS"
		cFolder := "YMS"	//-- YMS
	ElseIf oModel:cID == "MdGridDNT"
		cAlias  := "DNT"
		cFolder := STR0025	//-- "Agendamento"
	EndIf

	If oModel:cID == "MdGridDN1" .And. lDefEsp
		For nLin := 1 To oModel:Length()
			oModel:GoLine(nLin)
			If !oModel:IsDeleted() .And. oModel:GetValue("DN1_MSBLQL") == "2"
				If AScan( aDefEsp, {|x| x == oModel:GetValue("DN1_CODFON") } ) == 0
					AAdd( aDefEsp, oModel:GetValue("DN1_CODFON") )
				Else
					Help( '', 1, "TMSAI8012", , STR0030, 1,,,,,,, {STR0020 + cFolder + STR0021 + oModel:GetValue("DN1_SEQUEN")  + STR0022} )	//-- "Não pode haver mais de uma sequência não bloqueada para o mesmo Código Fonte." # "Na Pasta " # " ative o bloqueio da sequencia: " # " para continuar."
					lRet := .F.
					Exit
				Endif
			EndIf
		Next
	Else
		For nLin := 1 To oModel:Length()
			oModel:GoLine(nLin)
			If !oModel:IsDeleted()
				If oModel:GetValue(cAlias+"_MSBLQL") == "2"
					nQtdAtivo++
				EndIf
			EndIf
			If nQtdAtivo > 1
				Help( '', 1, "TMSAI8002", , STR0019, 1,,,,,,, {STR0020 + cFolder + STR0021 + oModel:GetValue(cAlias+"_SEQUEN")  + STR0022} )	//-- "Não pode haver mais de uma seuquencia não bloqueada." # "Na Pasta " # " ative o bloqueio da sequencia: " # " para continuar."
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf


Return lRet

/*{Protheus.doc} TMSAI80Val
Valida campos
@type Static Function
@author Valdemar Roberto Mognon
@since 03/05/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI80Val()
(examples)
@see (links_or_references)
*/
Function TMSAI80Val(cCampo)
Local lRet     := .T.
Local cContVar := ""
Default cCampo := ReadVar()

	If !Vazio() .And. cCampo $ "M->DN1_OCOENT:M->DN1_OCNFEC:M->DN1_OCNAVA:M->DN1_OCNFAL:M->DN1_OCNREC:M->DN1_OCNOUT:M->DN1_OCOCOL:M->DN1_OCNCOL"
		DT2->(DbSetOrder(1))
		cContVar := &(cCampo)
		If DT2->(MsSeek(xFilial("DT2")+cContVar))
			If DT2->DT2_ATIVO == StrZero(2,Len(DT2->DT2_ATIVO))
				Help("",1,"TMSAI8001")	//-- A ocorrência deve estar ativa.
				lRet := .F.
			ElseIf DT2->DT2_CATOCO == StrZero(2,Len(DT2->DT2_CATOCO))
				Help("",1,"TMSAI8003")	//-- A ocorrência deve ser da categoria por viagem.
				lRet := .F.
			ElseIf DT2->DT2_SERTMS == StrZero(2,Len(DT2->DT2_SERTMS))
				Help("",1,"TMSAI8010")	//-- Somente são aceitas ocorrências de coleta ou de entrega.
				lRet := .F.
			ElseIf !Empty(DT2->DT2_SERTMS) .And. (DT2->DT2_SERTMS == StrZero(1,Len(DT2->DT2_SERTMS)) .Or. DT2->DT2_SERTMS == StrZero(3,Len(DT2->DT2_SERTMS)))
				If cCampo $ "M->DN1_OCOCOL:M->DN1_OCNCOL"
					If DT2->DT2_SERTMS == StrZero(3,Len(DT2->DT2_SERTMS))
						Help("",1,"TMSAI8009")	//-- A ocorrência deve ser de coleta.
						lRet := .F.
					EndIf
				ElseIf DT2->DT2_SERTMS == StrZero(1,Len(DT2->DT2_SERTMS))
					Help("",1,"TMSAI8002")	//-- A ocorrência deve ser de entrega.
					lRet := .F.
				EndIf
			EndIf
			
			If lRet
				If cCampo $ "M->DN1_OCOENT:M->DN1_OCOCOL" .And. DT2->DT2_TIPOCO != StrZero(1,Len(DT2->DT2_TIPOCO))
					Help("",1,"TMSAI8004")	//-- A ocorrência deve ser do tipo que encerra processo.
					lRet := .F.
				ElseIf cCampo $ "M->DN1_OCNFEC:M->DN1_OCNOUT:M->DN1_OCNCOL" .And. DT2->DT2_TIPOCO != StrZero(4,Len(DT2->DT2_TIPOCO))
					Help("",1,"TMSAI8005")	//-- A ocorrência deve ser do tipo que retorna documento.
					lRet := .F.
				ElseIf cCampo $ "M->DN1_OCNAVA:M->DN1_OCNFAL:M->DN1_OCNREC"
					If DT2->DT2_TIPOCO != StrZero(6,Len(DT2->DT2_TIPOCO))
						Help("",1,"TMSAI8011")	//-- A ocorrência deve ser do tipo gera pendência.
						lRet := .F.
					ElseIf cCampo $ "M->DN1_OCNFAL" .And. DT2->DT2_TIPPND != StrZero(1,Len(DT2->DT2_TIPPND))
						Help("",1,"TMSAI8006")	//-- A ocorrência deve ser do tipo que gera pendência com tipo de pendência igual a "falta".
						lRet := .F.
					ElseIf cCampo $ "M->DN1_OCNAVA" .And. DT2->DT2_TIPPND != StrZero(2,Len(DT2->DT2_TIPPND))
						Help("",1,"TMSAI8007")	//-- A ocorrência deve ser do tipo que gera pendência e com tipo de pendência igual a avaria.
						lRet := .F.
					ElseIf cCampo $ "M->DN1_OCNREC" .And. DT2->DT2_TIPPND != StrZero(4,Len(DT2->DT2_TIPPND))
						Help("",1,"TMSAI8008")	//-- A ocorrência deve ser do tipo que gera pendência e com tipo de pendência igual a "retorno ao cliente".
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} TMSAI80Tst
Valida a Mudança de Folder
@type Function
@author Valdemar Roberto Mognon
@since 12/02/2025
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI80Tst()
(examples)
@see (links_or_references)
*/
Function TMSAI80Tst(cID,nOldSheet,nSelSheet)

nFolderAtu := nSelSheet

Return .T.
