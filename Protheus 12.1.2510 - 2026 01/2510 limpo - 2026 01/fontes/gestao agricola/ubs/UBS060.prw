#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TopConn.ch"
#INCLUDE "ubs060.ch"

/** {Protheus.doc} UBS060
Rotina de Registro de Campo
@author	Equipe Agroindustria
@since 01/2022
@Uso SIGAAGR - Originação de Grãos
@type function **/
Function UBS060()

	Local oMBrowse	:= Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNM" )
    oMBrowse:SetDescription( STR0001 ) //"Registro de Campos de Produção"
	oMBrowse:SetMenuDef( 'UBS060' ) // Define de que fonte virão os botoes deste browse
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( )   

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina
@return array, aRotina - Array com os itens do menu
@author	Equipe Agroindustria
@since 08/09/2023
@type function **/
Static Function MenuDef()
	Local aRotina	:= {}

	aAdd( aRotina, { STR0002, "PesqBrw"				, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.UBS060"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "ViewDef.UBS060"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005, "ViewDef.UBS060"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006, "ViewDef.UBS060"	, 0, 5, 0, Nil } ) //"Excluir"
	
Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@return object, 	oModel - Modelo de dados
@author Equipe Agroindustria
@since 08/09/2023
@type function **/
Static Function ModelDef()
	Local oStruNNM	:= FWFormStruct( 1, "NNM" )
	Local oModel

    oModel := MPFormModel():New( "UBS060", /*bPre*/ , /*{| oModel | PosModelo( oModel ) } */, /*{| oModel | GrvModelo( oModel ) } */, /*bCancel*/  )

	oModel:SetDescription( STR0001 ) //##//"Registro de Campos de Produção"
	oModel:AddFields( "OMODEL_NNM", /*cOwner*/, oStruNNM, {|oFieldModel, cAction, cIDField, xValue|PreValNNM(oFieldModel, cAction, cIDField, xValue)}, /*bPost*/, /*bLoad */ )
	oModel:GetModel( "OMODEL_NNM" ):SetDescription( STR0007 ) // 'Mapa Produção'

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
@return object, oView - View do modelo de dados
@author	Equipe Agroindustria
@since 08/09/2023
@type function **/
Static Function ViewDef()
	Local oStruNNM	:= FWFormStruct( 2, "NNM" )
	Local oModel		:= FWLoadModel( "UBS060" )
	Local oView			:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( "VIEW_NNM", oStruNNM, "OMODEL_NNM" )
	
	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 100, "TELANOVA" )

	oView:SetOwnerView( "VIEW_NNM", "SUPERIOR" )

	oView:EnableTitleView( "VIEW_NNM" )

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} fCriaPrx
Função que retorna a proxima sequencia
@param cTabela, Character, ALIAS DA TABELA 
@param cCampo, Character, campo da tabela 
@param cCondic, Character, condicao para filtro query 
@return numerico, cNumSeq bbb
@author	Equipe Agroindustria
@since 08/09/2023
@type function **/
function UBS060SQ(cTabela, cCampo, cCondic)
	Local aArea   := getArea()
	Local cNumSeq := ""
	Local cQuery  := ""
	Local aReg    := {}
	Local nTam    := TamSx3(cCampo)[1]
    
	Default cCondic := ""

	cQuery := "SELECT MAX("+cCampo+") "+cCampo+" "
	cQuery += "FROM "+RetSqlName(cTabela)+" "+cTabela+" "
	cQuery += "WHERE " + RetSqlCond(cTabela)+" "
	IF !Empty(cCondic)
		cQuery += cCondic
	EndIF

	aReg	:= MntArray(cQuery)

	IF Len(aReg) > 0
		IF Empty(aReg[1,1])
			cNumSeq := StrZero(1,nTam)
		Else
			cNumSeq := soma1(alltrim(aReg[1,1]))
		EndIF
	EndIf

	RestArea(aArea)

    //Verifica se esta na memoria, sendo usado
	While !	MayIUseCode( xFilial("NNM")+"NNM_SEQ"+cNumSeq ) 	    
	   cNumSeq := Soma1(cNumSeq)			 					
    EndDo

return cNumSeq

/** {Protheus.doc} static Function MntArray(cQuery)
Montar o Array a partir do Select
@param cQuery, Character, Query que ser executada
@return array, aRet 
@author	Equipe Agroindustria
@since 08/09/2023
@type function **/
static Function MntArray(cQuery)
    Local aRet    := {}
	Local aRet1   := {}
	Local nRegAtu := 0
	Local x       := 0

	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "_TRB"

	dbSelectArea("_TRB")
	aRet1   := Array(Fcount())
	nRegAtu := 1

	While !Eof()
		For x:=1 To Fcount()
			aRet1[x] := FieldGet(x)
		Next
		Aadd(aRet,aclone(aRet1))

		dbSkip()
		nRegAtu += 1
	Enddo

	dbSelectArea("_TRB")
	_TRB->(DbCloseArea())

Return(aRet)

/*/{Protheus.doc} UBS060VLD()
Efetua a validação dos dados e bloqueio da alteração do mesmo caso estejam na tabela SB5 .
@author Agroindustria
@since 11/09/2023
@Uso: dicionario SX3
@type function **/
Function UBS060VLD()
    Local oModel    := FwModelActive()
	Local lRetorno 	:= .T.
    Local cMensa    := ' '
    
	
	If AllTrim(ReadVar()) $ "M->NNM_CTVAR" //cultivar - NP4		
		lRetorno := ExistCpo("NP4")         

	ElseIf AllTrim(ReadVar()) $ "M->NNM_CATEG" //categoria - K1		
		lRetorno := ExistCpo('SX5','K1'+M->NNM_CATEG)		
	
	ElseIf AllTrim(ReadVar()) $ "M->NNM_TALHAO"
		IF M->NNM_TIPO = '1' 
			oModel:LoadValue("OMODEL_NNM","NNM_FAZ","") //limpa fazenda para garantir que irá gatilhar a fazenda do talhao, senão ficará vazio
			If !Empty(M->NNM_TALHAO) 
				lRetorno := ExistCpo("NN3",M->(NNM_CODSAF+NNM_CODPROD+NNM_TALHAO),6)                                                                  		
				IF !lRetorno
					cMensa:= STR0011 //##"Talhão informado não encontrado para produção própria, safra e produto informado."
				Else
					lRetorno := ExistCpo("NN2",M->(NNM_CODENT+NNM_LOJENT)+NN3->NN3_FAZ,3) //NN3 ja posicionado devido ExistCpo() mais acima    
					IF !lRetorno
						cMensa:= STR0010 //###"Fornecedor da fazenda do talhao difere-se do Produtor informado."
					EndIF	
				EndIF
			EndIF
		ENDIF		
	ElseIf AllTrim(ReadVar()) $ "M->NNM_FAZ"
		IF M->NNM_TIPO = '1'  
			lRetorno := ExistCpo("NN2",M->(NNM_CODENT+NNM_LOJENT+NNM_FAZ),3)      
			IF !lRetorno
				cMensa:= STR0012 //##"Fazenda informada não encontrada para produção própria, produtor e loja informada."
			elseIF !Empty(M->NNM_TALHAO)
				lRetorno := ExistCpo("NN3",M->(NNM_CODSAF+NNM_FAZ+NNM_CODPRO+NNM_TALHAO),3)                                                                  		
				IF !lRetorno
					cMensa:= STR0013 //###"Fazenda informada não encontrada para produção própria, safra, produto e talhão informado."
				EndIF
			EndIF
		EndIF
	
	EndIf

    If !Empty(cMensa) 
		Help(,1,"HELP",,cMensa,1,0)
		lRetorno := .f.
	EndIf

Return lRetorno

/*/{Protheus.doc} PreValNNM
Pre-Validação do valor xValue que será inserido no campo conforme campo cIDField e ação cAction antes de gravar no modelo
@type function
@version  P12
@author claudineia.reinert
@since 2/2/2024
@param oFieldModel, object, modelo de dados 
@param cAction, character, ação executada CANSETVALUE|SETVALUE
@param cIDField, character, campo atual que disparou a ação
@param xValue, variant, valor informado no campo cIDField
@return logical, valor logico .T. ou .F. se o campo pode receber o valor informado
/*/
Static Function PreValNNM(oFieldModel, cAction, cIDField, xValue)
	Local lRet := .T.

	If cAction == "SETVALUE"
		If cIDField $ "NNM_TIPO"
			IF xValue == '1'  
				//limpa para garantir que ira informar dados validos conforme entidade, safra e produto
				oFieldModel:LoadValue("NNM_TALHAO","") 
				oFieldModel:LoadValue("NNM_FAZ","") 
				oFieldModel:LoadValue("NNM_AREA",0) 
			EndIf		
		ElseIf cIDField $ "NNM_CODENT|NNM_LOJENT|NNM_CODSAF|NNM_CODPRO" 
			IF oFieldModel:GetValue("NNM_TIPO") == '1'  
				//limpa para garantir que ira informar dados validos conforme entidade, safra e produto
				oFieldModel:LoadValue("NNM_TALHAO","") 
				oFieldModel:LoadValue("NNM_FAZ","") 
				oFieldModel:LoadValue("NNM_AREA",0) 
			EndIf
		EndIf
	EndIf

Return lRet

