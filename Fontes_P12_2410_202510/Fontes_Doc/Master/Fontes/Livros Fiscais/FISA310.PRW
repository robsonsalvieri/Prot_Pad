#INCLUDE "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA310.CH"

Static c310EmpF3 := ""
Static c310FilF3 := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA310()

Rotina para cadastro de valores dos quadros do Anexo 6 do SCANC REF

@author Delleon Fernandes
@since 13/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function FISA310()

	Local oBrowse := Nil

	//Verifico se as tabelas existem antes de prosseguir
	IF ChkFile("CJO")
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("CJO")
		oBrowse:SetDescription(STR0001) // "Detalhamento de quadros"
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help",STR0002,1,0) // "Dicionário desatualizado, favor verificar atualizações do fiscal."
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Delleon Fernandes
@since 13/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA310" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro de quadros do SCANC REF

@author Delleon Fernandes
@since 13/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local cCampCabec := "CJO_ANEXO|CJO_QUADRO|CJO_SUBQUA|CJO_MESANO"

	//Criação do objeto do modelo de dados
	Local oModel := Nil

	//Estrutura Pai do cabeçalho da rotina
	Local oCabecalho := FWFormStruct(1,"CJO",{|cCampo| AllTrim(cCampo) $ cCampCabec})

	//Estrutura do grid
	Local oItem := FWFormStruct(1,"CJO",{|cCampo| !(AllTrim(cCampo) $ cCampCabec)})

	Local bPos := {|oModel| FISA310POS(oModel)}

	//Instanciando o modelo
	oModel := MPFormModel():New('FISA310', /*bPre*/, bPos, /*bCommit*/, /*bCancel*/)

	//Atribuindo cabeçalho para o modelo
	oModel:AddFields("FISA310",/*cOwner*/,oCabecalho,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	//Adicionando o grid das variações do tributo
	oModel:AddGrid( 'FISA310ITEM', 'FISA310', oItem,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	// oItem:RemoveField("CJO_COMUNI")
	A310Remove(oItem)

	//Não permite alterar o conteúdo dos campos
	oCabecalho:SetProperty('CJO_ANEXO'  , MODEL_FIELD_WHEN, {|| ( .F. ) })
	oCabecalho:SetProperty('CJO_QUADRO' , MODEL_FIELD_WHEN, {|| ( .F. ) })
	oCabecalho:SetProperty('CJO_SUBQUA' , MODEL_FIELD_WHEN, {|| ( .F. ) })
	oItem:SetProperty('CJO_CLIFOR' , MODEL_FIELD_WHEN, {|| ( WhenCliFor(oModel) ) })
	oItem:SetProperty('CJO_LOJA'   , MODEL_FIELD_WHEN, {|| ( WhenCliFor(oModel) ) })
	oItem:SetProperty('CJO_CODEMP' , MODEL_FIELD_WHEN, {|| ( WhenCodFil(oModel) ) })
	oItem:SetProperty('CJO_CODFIL' , MODEL_FIELD_WHEN, {|| ( WhenCodFil(oModel) ) })

	// Adiciono validação nos campos
	oCabecalho:SetProperty('CJO_MESANO' , MODEL_FIELD_VALID , {|| ValidCpo("CJO_MESANO") })
	oItem:SetProperty('CJO_TPCHV' , MODEL_FIELD_VALID , {|| ValidCpo("CJO_TPCHV" ) })
	oItem:SetProperty('CJO_CLIFOR', MODEL_FIELD_VALID , {|| ValidCpo("CJO_CLIFOR") })
	oItem:SetProperty('CJO_LOJA'  , MODEL_FIELD_VALID , {|| ValidCpo("CJO_LOJA"  ) })
	oItem:SetProperty('CJO_CODEMP', MODEL_FIELD_VALID , {|| ValidCpo("CJO_CODEMP") })
	oItem:SetProperty('CJO_CODFIL', MODEL_FIELD_VALID , {|| ValidCpo("CJO_CODFIL") })


	//Adicionando descrição ao modelo
	oModel:SetDescription(STR0003) // "Detalhamento do quadro"

	//Relacionamento entre a tabela com o Grid
	oModel:SetRelation( 'FISA310ITEM', { ;
		{ 'CJO_FILIAL', 'xFilial("CJO")' },;
		{ 'CJO_ANEXO' , 'CJO_ANEXO'      },;
		{ 'CJO_QUADRO', 'CJO_QUADRO'     },;
		{ 'CJO_SUBQUA', 'CJO_SUBQUA'     },;
		{ 'CJO_MESANO', 'CJO_MESANO'     };
		}, CJO->( IndexKey( 1 ) ) )

	oModel:SetPrimaryKey( {"CJO_FILIAL", "CJO_ANEXO", "CJO_QUADRO", "CJO_SUBQUA", "CJO_MESANO", "CJO_TPCHV", "CJO_CLIFOR", "CJO_LOJA", "CJO_CODEMP", "CJO_CODFIL"} )

	oModel:GetModel('FISA310ITEM'):SetUniqueLine({"CJO_TPCHV", "CJO_CLIFOR", "CJO_LOJA", "CJO_CODEMP", "CJO_CODFIL"} )

	oModel:SetActivate({|oModel| A310Active( oModel )})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Delleon Fernandes
@since 13/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local cCampCabec := "CJO_ANEXO|CJO_QUADRO|CJO_SUBQUA|CJO_MESANO"

	//Criação do objeto do modelo de dados da Interface do Cadastro
	Local oModel     := FWLoadModel( "FISA310" )

	//Criação da estrutura de dados utilizada na interface do cadastro
	Local oCabecalho := FWFormStruct(2,"CJO",{|cCampo| AllTrim(cCampo) $ cCampCabec})
	Local oItem      := FWFormStruct(2,"CJO",{|cCampo| !(AllTrim(cCampo) $ cCampCabec)})
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel( oModel )

	// Atribuo consulta padrão para os campos
	oItem:SetProperty("CJO_CODEMP", MVC_VIEW_LOOKUP, "CJOEMP")
	oItem:SetProperty("CJO_CODFIL", MVC_VIEW_LOOKUP, "SM0")
	oItem:SetProperty("CJO_CLIFOR", MVC_VIEW_LOOKUP, {|| A310ChgF3(oModel)})

	//Picture dos campos
	oCabecalho:SetProperty('CJO_MESANO' , MVC_VIEW_PICT, "999999")

	//Atribuindo formulários para interface
	oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA310' )
	oView:AddGrid(  'VIEW_ITEM'      , oItem      , 'FISA310ITEM' )

	//Habilitando opções de filtros
	oView:SetViewProperty('VIEW_ITEM', "GRIDFILTER", {.T.})
	oView:SetViewProperty('VIEW_ITEM', "GRIDSEEK", {.T.})

	//Cria dois box, 30% e 70%
	oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
	oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

	//Faz vínculo do box com a view
	oView:SetOwnerView( 'VIEW_CABECALHO' , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_ITEM'      , 'INFERIOR' )

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_CABECALHO' , STR0004 ) // "Cadastro de detalhamento do quadro"
	oView:EnableTitleView('VIEW_ITEM'      , STR0003 ) // "Detalhamento do quadro"

	//	Associa os componentes
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )

	//Retirando campo da view.
	// oItem:RemoveField("CJO_COMUNI")
	A310Remove(oItem)

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} A310Active
Função que trata informações especificas por quadros do SCANC.

@author Delleon Fernandes
@since 14/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function A310Active(oModel)

	Local oCabecalho := oModel:GetModel("FISA310")
	Local nOper		 := oModel:GetOperation()
	Local lFisa309   := Type("c309Quadro") == "C"
	Local a309Quadro := {}

	//Atualiza os valores dos campos
	If nOper == MODEL_OPERATION_INSERT

		If lFisa309
			a309Quadro := StrTokArr(c309Quadro, "#")
			If Len(a309Quadro) == 3
				//Cabeçalho
				oCabecalho:LoadValue("CJO_ANEXO"  , a309Quadro[1])
				oCabecalho:LoadValue("CJO_QUADRO" , a309Quadro[2])
				oCabecalho:LoadValue("CJO_SUBQUA" , a309Quadro[3])
			EndIf
		EndIf
	EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} WhenCliFor
	(Controle edição do campo, 
	Somente quando o campo CJO_TPCHV for Fornecedor/Cliente)

	@type  Static Function
	@author Delleon Fernandes
	@since 15/02/2023
/*/
//-----------------------------------------------------------------------
Static Function WhenCliFor(oModel)
	Local cTpChv := oModel:GetValue('FISA310ITEM', "CJO_TPCHV")
Return cTpChv $ "1#2"

//-----------------------------------------------------------------------
/*/{Protheus.doc} WhenCodFil
	(Controle edição do campo, 
	Somente quando o campo CJO_TPCHV for Filial)

	@type  Static Function
	@author Delleon Fernandes
	@since 15/02/2023
/*/
//-----------------------------------------------------------------------
Static Function WhenCodFil(oModel)
	Local cTpChv := oModel:GetValue('FISA310ITEM', "CJO_TPCHV")
Return cTpChv == "3"

//-----------------------------------------------------------------------
/*/{Protheus.doc} A310ChgF3
	(Função responsável por informar a consulta padrão)

	@type  Function
	@author Delleon Fernandes
	@since 15/02/2023
	@version 12.1.2210
/*/
//-----------------------------------------------------------------------
Static Function A310ChgF3(oModel)

	Local cTpChv := oModel:GetValue('FISA310ITEM', "CJO_TPCHV")
	Local cRet   := ""

	If cTpChv == "1"
		cRet := "SA2"
	ElseIf cTpChv == "2"
		cRet := "SA1"
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A310Remove
(Remove campo de acordo com o quadro posicionado)

@author Delleon Fernandes
@since 15/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function A310Remove( oItem )

	Local lFisa309   := Type("c309Quadro") == "C"
	Local a309Quadro := {}

	If lFisa309
		a309Quadro := StrTokArr(c309Quadro, "#")
		If Len(a309Quadro) == 3
			If !((Alltrim(a309Quadro[1]) $"#A6#") .And. (Alltrim(a309Quadro[2]) $ "#Q4#Q6#Q7#Q9#") .And. (Alltrim(a309Quadro[3]) $"#3#"))
				oItem:RemoveField("CJO_COMUNI")
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA310F3
Função para consulta padrão F3 do campo CJO_CODEMP.

Atenção!
Esta consulta padrão só deve ser utilizada aqui neste fonte.

@author Delleon Fernandes
@since 16/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function FISA310F3()
	Local aAreaSM0 := SM0->(GetArea())
	Local aAreaCJO := CJO->(GetArea())
	Local oDlg, oLbx
	Local aCpos  := {}
	Local aRet   := {}
	Local lRet   := .F.

	DbSelectArea("SM0")
	SM0->(DbGotop())
	While SM0->(!Eof())
		aAdd(aCpos,{SM0->M0_CODIGO, SM0->M0_NOME, SM0->M0_CODFIL, SM0->M0_FILIAL})
		SM0->(dbSkip())
	EndDo

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 340,740 PIXEL // "SCANC REF - Consulta Empresa/Filial"

	@ 10,10 LISTBOX oLbx FIELDS HEADER STR0006, STR0007, STR0008, STR0009 SIZE 350,130 OF oDlg PIXEL // "Empresa", "Nome Empresa", "Filial", "Nome Filial"

	oLbx:SetArray( aCpos )
	oLbx:bLine      := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4]}}
	oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4]}}}

	DEFINE SBUTTON FROM 150,165 TYPE 1 ;
		ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4]});
		ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTER

	If Len(aRet) > 0 .And. lRet
		c310EmpF3 := aRet[1]
		c310FilF3 := aRet[3]
	Else
		c310EmpF3 := ""
		c310FilF3 := ""
	EndIf

	RestArea(aAreaSM0)
	RestArea(aAreaCJO)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FS310EmpF3
Função que trabalha em conjunto com a função FISA310F3 para consulta padrão .
Atenção!
Esta consulta padrão só deve ser utilizada aqui neste fonte.

@author Delleon Fernandes
@since 16/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function FS310EmpF3()
Return {c310EmpF3, c310FilF3}


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCpo
Validação de campos.

@author Delleon Fernandes
@since 16/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ValidCpo(cCampo)

	Local aArea   := GetArea()
	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local oItens  := oModel:GetModel("FISA310ITEM")
	Local cTpChv  := oModel:GetValue('FISA310ITEM', "CJO_TPCHV")
	Local cCliFor := ""
	Local cLoja   := ""
	Local cCodEmp := ""
	Local cCodFil := ""

	Do Case
	Case cCampo $ "CJO_CLIFOR"

		cCliFor := oModel:GetValue('FISA310ITEM', "CJO_CLIFOR")
		cLoja   := oModel:GetValue('FISA310ITEM', "CJO_LOJA"  )

		If cTpChv $ "1/2"

			If cTpChv == "1" .And. !Empty(cCliFor)
				If !Empty(cLoja)
					cCliFor += cLoja
				EndIf
				SA2->(DbSetOrder(1))
				lRet := SA2->(DbSeek(xFilial("SA2") + cCliFor ))
				If lRet .And. Empty(cLoja)
					oItens:LoadValue('CJO_LOJA', SA2->A2_LOJA )
				EndIf

			ElseIf cTpChv == "2" .And. !Empty(cCliFor)
				If !Empty(cLoja)
					cCliFor += cLoja
				EndIf
				SA1->(DbSetOrder(1))
				lRet := SA1->(DbSeek(xFilial("SA1") + cCliFor))
				If lRet .And. Empty(cLoja)
					oItens:LoadValue('CJO_LOJA', SA1->A1_LOJA )
				EndIf
			EndIf
		EndIf

	Case cCampo $ "CJO_LOJA"

		cCliFor := oModel:GetValue('FISA310ITEM', "CJO_CLIFOR")
		cLoja   := oModel:GetValue('FISA310ITEM', "CJO_LOJA"  )

		If cTpChv $ "1/2"

			If cTpChv == "1" .And. !Empty(cLoja)
				SA2->(DbSetOrder(1))
				lRet := SA2->(DbSeek(xFilial("SA2") + cCliFor + cLoja))

			ElseIf cTpChv == "2" .And. !Empty(cLoja)
				SA1->(DbSetOrder(1))
				lRet := SA1->(DbSeek(xFilial("SA1") + cCliFor + cLoja))

			EndIf
		EndIf

	Case cCampo $ "CJO_CODEMP"

		aAreaSM0 := SM0->(GetArea())
		cCodEmp  := oModel:GetValue('FISA310ITEM', "CJO_CODEMP")
		If !Empty(cCodEmp)
			lRet := SM0->(DbSeek(cCodEmp))
		EndIf
		RestArea(aAreaSM0)

	Case cCampo $ "CJO_CODFIL"

		aAreaSM0 := SM0->(GetArea())

		cCodEmp  := oModel:GetValue('FISA310ITEM', "CJO_CODEMP")
		cCodFil	 := oModel:GetValue('FISA310ITEM', "CJO_CODFIL")
		If !Empty(cCodFil)
			lRet     := SM0->(DbSeek(cCodEmp + cCodFil))
		EndIf

		RestArea(aAreaSM0)

	Case cCampo $ "CJO_MESANO"

		cChave := oModel:GetValue('FISA310', "CJO_ANEXO" )
		cChave += oModel:GetValue('FISA310', "CJO_QUADRO")
		cChave += oModel:GetValue('FISA310', "CJO_SUBQUA")
		cChave += oModel:GetValue('FISA310', "CJO_MESANO")

		If Len(Alltrim(oModel:GetValue('FISA310', "CJO_MESANO"))) < 6
			lRet := .F.
			oModel:SetErrorMessage('FISA310', 'CJO_MESANO', 'FISA310', 'CJO_MESANO', "Erro", STR0010, STR0011) // "Mês/Ano informado inválido",  "Informe o Mês e Ano no formato MMAAAA."
		Else
			CJO->(DbSetOrder(1))
			If CJO->(DbSeek(xFilial("CJO") + cChave))
				lRet := .F.
				oModel:SetErrorMessage('FISA310', 'CJO_ANEXO', 'FISA310', 'CJO_ANEXO', "Erro", STR0012, STR0013) // "Registro já encontrado na base de dados.", "Verifique o registro já cadastrado."
			EndIf
		EndIf

	Case cCampo $ "CJO_TPCHV"

		// Quando alterar o conteudo do campo CJO_TPCHV, limpo os campos abaixo
		oItens:LoadValue('CJO_CODEMP', Criavar("CJO_CODEMP") )
		oItens:LoadValue('CJO_CODFIL', Criavar("CJO_CODFIL") )
		oItens:LoadValue('CJO_CLIFOR', Criavar("CJO_CLIFOR") )
		oItens:LoadValue('CJO_LOJA'  , Criavar("CJO_LOJA"  ) )

	EndCase

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA310POS
Validação de campos caso estejam vazios (Tudo OK).

@author Delleon Fernandes
@since 16/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function FISA310POS(oModel)

	Local lRet := .T.
	Local nOperation
	Local oModelItem
	Local nX := 0
	Local cIdFieldErr := ""
	Local nLinAtu

	If oModel <> NIL
		nOperation := oModel:GetOperation()
		oModelItem := oModel:GetModel("FISA310ITEM")
		nLinAtu	   := oModelItem:GetLine()

		If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT

			For nX := 1 To oModelItem:Length()
				oModelItem:GoLine(nX)
				If !oModelItem:isDeleted()

					cTpChv 	:= oModel:GetValue( 'FISA310ITEM', 'CJO_TPCHV'  )
					cCliFor := oModel:GetValue( 'FISA310ITEM', 'CJO_CLIFOR' )
					cLoja	:= oModel:GetValue( 'FISA310ITEM', 'CJO_LOJA'   )
					cCodEmp	:= oModel:GetValue( 'FISA310ITEM', 'CJO_CODEMP' )
					cCodFil	:= oModel:GetValue( 'FISA310ITEM', 'CJO_CODFIL' )

					If cTpChv $ "1#2" .And. (Empty(cCliFor) .Or. Empty(cLoja))
						If Empty(cCliFor)
							cIdFieldErr := "CJO_CLIFOR"
						ElseIf Empty(cLoja)
							cIdFieldErr := "CJO_LOJA"
						EndIf
						lRet := .F.
						Exit

					ElseIf cTpChv $ "3" .And. (Empty(cCodEmp) .Or. Empty(cCodFil))
						If Empty(cCodEmp)
							cIdFieldErr := "CJO_CODEMP"
						ElseIf Empty(cCodFil)
							cIdFieldErr := "CJO_CODFIL"
						EndIf
						lRet := .F.
						Exit
					EndIf
				EndIf

			Next nX

			oModelItem:GoLine(nLinAtu)

			If !lRet
				oModel:SetErrorMessage('FISA310', 'CJO_TPCHV', 'FISA310ITEM', cIdFieldErr, "Erro", STR0014, STR0015) // "Existem campo(s) em branco(s) no 'Detalhamento do quadro'.", "Necessário preencher os campos vazios."
			EndIf
		EndIf

	EndIf

Return lRet
