#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA424.CH'

/*/{Protheus.doc} GTPA424
Visualização de valores gerados entre empresas
@type  Function
@author henrique.toyada
@since 21/11/2022
@version version
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA424()
Local oBrowse	:= Nil

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) )

    If ValidTabCmp()
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("H6O")
        oBrowse:AddLegend("H6O_STATUS == '1'", "WHITE",  STR0028, "H6O_STATUS") //"Titulos não gerados"
        oBrowse:AddLegend("H6O_STATUS == '2'", "ORANGE", STR0029, "H6O_STATUS") //"Títulos gerados parcialmente
        oBrowse:AddLegend("H6O_STATUS == '3'", "GREEN",  STR0030, "H6O_STATUS") //"Títulos gerados"
        oBrowse:SetDescription(STR0003) //"Ajuste de caixa empresas
        oBrowse:Activate()
    EndIf

EndIf

Return()

/*/{Protheus.doc} ValidTabCmp
    (long_description)
    @type  Static Function
    @author user
    @since 25/11/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ValidTabCmp()
Local lRet       := .F.
Local cMsgErro   := ""
Local aFieldsH6O := {'H6O_FILIAL','H6O_CODIGO','H6O_CODEMP','H6O_DATADE','H6O_DATAAT','H6O_VALTOT','H6O_STATUS'}
Local aFieldsH6P := {'H6P_FILIAL','H6P_CODIGO','H6P_SEQ','H6P_STATUS','H6P_CODEMP','H6P_VALITM','H6P_CODSA2',;
                     'H6P_LOJSA2','H6P_FILTIT','H6P_PRETIT','H6P_NUMTIT','H6P_PARTIT','H6P_TIPTIT','H6P_EMPDES',;
                     'H6P_DSCDES','H6P_CODG6T'}

If GTPxVldDic("H6O",aFieldsH6O,.T.,.T.,@cMsgErro) .AND. GTPxVldDic("H6P",aFieldsH6P,.T.,.T.,@cMsgErro)
    lRet := .T.
EndIf

If !(EMPTY(cMsgErro))
    FwAlertWarning(cMsgErro)
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA424'   OPERATION OP_VISUALIZAR	ACCESS 0  //"Visualizar"
    ADD OPTION aRotina TITLE STR0005 ACTION 'GTP424MENU()'      OPERATION OP_INCLUIR	ACCESS 0  //"Incluir"
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA424'   OPERATION OP_ALTERAR	ACCESS 0  //"Alterar"
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GTPA424'   OPERATION OP_EXCLUIR	ACCESS 0  //"Excluir"
    ADD OPTION aRotina TITLE STR0008 ACTION 'GTPA424A(3)'       OPERATION OP_ALTERAR	ACCESS 0  //"Gerar Título"
    ADD OPTION aRotina TITLE STR0009 ACTION 'GTPA424A(5)'       OPERATION OP_ALTERAR	ACCESS 0  //"Estornar Título"

Return aRotina

/*/{Protheus.doc} GTP424MENU
    (long_description)
    @type  Function
    @author henrique.toyada
    @since 21/11/2022
    @version version
    @param , param_type, param_descr
    @return , return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTP424MENU()
Local oModel := NIL
Local lRet   := .F.

    If Pergunte("GTPA424",.T.) 
        If Empty(MV_PAR01)
            FwAlertWarning(STR0011, STR0010) //"Atenção" //"Informe a data inicial para o processamento do caixa"
            Return
        EndIf

        If Empty(MV_PAR02)
            FwAlertWarning(STR0012, STR0010) //"Atenção" //"Informe a data final para o processamento do caixa"
            Return
        EndIf

        oModel := FwLoadModel('GTPA424')

        oModel:SetOperation(MODEL_OPERATION_INSERT)

        FwMsgRun(,{|| lRet := LoadDados(oModel, MV_PAR01, MV_PAR02)}, STR0014, STR0013) //"Buscando dados do caixa..." //"Aguarde"
        If lRet
            FwExecView(STR0015, "VIEWDEF.GTPA424", MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, ,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel) //"Abertura"
        Else
            FwAlertWarning(STR0016, STR0010) //"Atenção" //"Não foi encontrado registros para as datas informadas"
        EndIf
    EndIf
Return 

/*/{Protheus.doc} LoadDados
    (long_description)
    @type  Static Function
    @author user
    @since 21/11/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function LoadDados(oModel, dDataIni, dDataFim)
Local cAliasTmp := GetNextAlias()
Local oMdlH6O   := oModel:GetModel('H6OMASTER')
Local oMdlH6P   := oModel:GetModel('H6PDETAIL')
Local lRet      := .F.
Local nValTot   := 0

oModel:Activate()

If oModel:GetOperation() == MODEL_OPERATION_INSERT
    oMdlH6O:SetValue('H6O_DATADE', dDataIni)
    oMdlH6O:SetValue('H6O_DATAAT', dDataFim)
Endif

BeginSql Alias cAliasTmp

    SELECT GI6.GI6_EMPRJI,
    	   GIC.GIC_EMPRJI,
           G6T.G6T_CODIGO,
    	   SUM(GIC.GIC_VALTOT) VLRTOTAL
    FROM %Table:G6T% G6T
    INNER JOIN %Table:G6X% G6X
    ON G6X.G6X_FILIAL = G6T.G6T_FILIAL
        AND G6X.G6X_AGENCI = G6T.G6T_AGENCI
        AND G6X.G6X_CODCX = G6T.G6T_CODIGO
        AND G6X.%NotDel%
    INNER JOIN %Table:GI6% GI6
    ON GI6.GI6_FILIAL = %xFilial:GI6%
        AND GI6.GI6_CODIGO = G6X.G6X_AGENCI
        AND GI6.GI6_EMPRJI != ''
        AND GI6.%NotDel%
    INNER JOIN %Table:GZG% GZG
    ON GZG.GZG_FILIAL = G6X.G6X_FILIAL
        AND GZG.GZG_AGENCI = G6X.G6X_AGENCI
        AND GZG.GZG_NUMFCH = G6X.G6X_NUMFCH
        AND GZG.GZG_COD IN ('030')
        AND GZG.%NotDel%
    INNER JOIN %Table:GIC% GIC 
    ON GIC.GIC_FILIAL = %xFilial:GIC%
        AND GIC.GIC_NUMFCH = G6X.G6X_NUMFCH
        AND GIC.GIC_EMPRJI <> GI6.GI6_EMPRJI
        AND GIC.%NotDel%
    WHERE G6T.G6T_FILIAL = %xFilial:G6T%
        AND G6T.G6T_DTOPEN BETWEEN %Exp:DtoS(dDataIni)% AND %Exp:DtoS(dDataFim)%
        AND G6T.G6T_STATUS IN ('2')
        AND G6T.G6T_CODH6O = ''
        AND G6T.%NotDel%
    GROUP BY GI6.GI6_EMPRJI,
    		 GIC.GIC_EMPRJI,
             G6T.G6T_CODIGO
EndSql

If (cAliasTmp)->(!Eof())

    While (cAliasTmp)->(!Eof())

        If !Empty(oMdlH6P:GetValue('H6P_CODEMP'))
            oModel:GetModel("H6PDETAIL"):SetNoInsertLine(.F.)   
            oMdlH6P:AddLine()
        Endif

        oMdlH6P:SetValue("H6P_SEQ",StrZero(oMdlH6P:Length(),TamSx3('H6P_SEQ')[1]))
        oMdlH6P:SetValue("H6P_CODEMP",alltrim((cAliasTmp)->GI6_EMPRJI))
        oMdlH6P:SetValue("H6P_EMPDES",alltrim((cAliasTmp)->GIC_EMPRJI))
        oMdlH6P:SetValue("H6P_VALITM",(cAliasTmp)->VLRTOTAL)
        oMdlH6P:SetValue("H6P_STATUS",'2')
        oMdlH6P:SetValue("H6P_CODG6T",(cAliasTmp)->G6T_CODIGO)
        oMdlH6P:SetValue("LEGENDA","BR_VERMELHO")

        nValTot += (cAliasTmp)->VLRTOTAL

        (cAliasTmp)->(dbSkip())

    EndDo

EndIf

(cAliasTmp)->(dbCloseArea())

oMdlH6O:SetValue("H6O_VALTOT",nValTot)

If oModel:VldData()
    oMdlH6P:SetNoDeleteLine(.T.)
    oMdlH6P:SetNoInsertLine(.T.)
    lRet := .T.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local aRelation := {}
Local oStrH6O	:= FWFormStruct(1,'H6O')
Local oStrH6P	:= FWFormStruct(1,'H6P')
Local bCommit	:= {|oModel|GTPA424Grv(oModel)}

SetModelStruct(oStrH6O,oStrH6P)

oModel := MPFormModel():New('GTPA424', /*bPreValidacao*/,/*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:SetCommit(bCommit)

oModel:AddFields('H6OMASTER',/*cOwner*/,oStrH6O)
oModel:AddGrid('H6PDETAIL','H6OMASTER',oStrH6P, /*bPreValid*/, /*bPosLValid*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

aRelation := {{"H6P_FILIAL","xFilial('H6P')"},;
			  {"H6P_CODIGO","H6O_CODIGO"}}

oModel:SetRelation("H6PDETAIL", aRelation, H6P->(IndexKey(1)))

oModel:SetDescription(STR0017) //"Ajuste de Caixas entre Empresas"

oModel:SetPrimaryKey({'H6O_FILIAL','H6O_CODIGO'})

//oModel:GetModel("H6PDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("H6PDETAIL"):SetNoDeleteLine( .T. )
oModel:GetModel("H6PDETAIL"):SetNoInsertLine(.T.)

oModel:SetVldActivate({|| ValidTabCmp()})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oStrH6A, object, (Descrição do parâmetro)
@param oStrH6B, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrH6O,oStrH6P)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue| FieldValid(oMdl,cField,uNewValue,uOldValue) }


    oStrH6O:SetProperty('H6O_CODIGO', MODEL_FIELD_INIT, bInit )
    oStrH6O:SetProperty('H6O_CODEMP', MODEL_FIELD_INIT, bInit )
    oStrH6O:SetProperty('H6O_DESEMP', MODEL_FIELD_INIT, bInit )

    oStrH6P:SetProperty('H6P_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
    
    oStrH6P:SetProperty('H6P_CODIGO', MODEL_FIELD_INIT, bInit )
    oStrH6P:SetProperty('H6P_DESEMP', MODEL_FIELD_INIT, bInit )
    oStrH6P:SetProperty('H6P_DESSA2', MODEL_FIELD_INIT, bInit )
    
    oStrH6P:AddTrigger('H6P_CODEMP', 'H6P_CODEMP',  { || .T. }, bTrig ) 
    oStrH6P:AddTrigger('H6P_EMPDES', 'H6P_EMPDES',  { || .T. }, bTrig ) 
    oStrH6P:AddTrigger('H6P_CODSA2', 'H6P_CODSA2',  { || .T. }, bTrig ) 
    oStrH6P:AddTrigger('H6P_LOJSA2', 'H6P_LOJSA2',  { || .T. }, bTrig ) 

    oStrH6P:AddField(	"",;									// 	[01]  C   Titulo do campo
					 		"LEGENDA",;									// 	[02]  C   ToolTip do campo	//"Legenda"
					 		"LEGENDA",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		15,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
	
	oStrH6P:SetProperty('LEGENDA'   , MODEL_FIELD_INIT, bInit)
    oStrH6P:SetProperty("H6P_CODSA2", MODEL_FIELD_VALID, bFldVld)
    oStrH6P:SetProperty("H6P_LOJSA2", MODEL_FIELD_VALID, bFldVld)

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

@type Function
@author henrique.toyada 
@since 02/08/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)

Local uRet      := nil
Local aAux      := {}
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
Local aArea     := GetArea()

Do Case 
    Case cField == "H6O_CODIGO"
        If lInsert
            uRet := GETSXENUM("H6O","H6O_CODIGO")
        EndIf
    Case cField == "H6O_CODEMP"
        uRet := FWEAIEMPFIL(cEmpAnt, cFilAnt, 'TOTALBUS', .T.)[1]
    Case cField == "H6O_DESEMP"
        aAux := FWEAIEMPFIL(ALLTRIM(oModel:GETMODEL("H6OMASTER"):GETVALUE("H6O_CODEMP")),,'TOTALBUS')
        If Len(aAux) > 0
            uRet := FWFilialName(aAux[1],aAux[2])
        EndIf
    Case cField == "H6P_CODIGO"
		uRet := If(lInsert,M->H6O_CODIGO,H6O->H6O_CODIGO)
    Case cField == "H6P_DESEMP"
            uRet := ""
    Case cField == "H6P_DESSA2"
        uRet := If(!lInsert,POSICIONE("SA2",1,XFILIAL("SA2")+H6P->H6P_CODSA2+H6P->H6P_LOJSA2,"A2_NOME"),'')
    Case cField == "LEGENDA"
		uRet := If(!lInsert,IF(H6P->H6P_STATUS == '2',"BR_VERMELHO","BR_VERDE"),"BR_VERMELHO")
EndCase 

RestArea(aArea)

Return uRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função que preenche trigger

@sample	GA850ATrig()

@author henrique.toyada
@since 02/08/2022
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

    Local oModel	:= oMdl:GetModel()
    //Local oModelH6O := oModel:GetModel("H6OMASTER")
    Local oModelH6P := oModel:GetModel("H6PDETAIL")
    Local aAux := {}

	Do Case 
        Case cField == "H6P_CODEMP"
            aAux := FWEAIEMPFIL(uVal,,'TOTALBUS')
            If Len(aAux) > 0
                oModelH6P:SetValue("H6P_DESEMP",SUBSTR(FWFilialName(aAux[1],aAux[2]),0,TamSX3("H6P_DESEMP")[1]))
            Endif
        Case cField == "H6P_EMPDES"
            aAux := FWEAIEMPFIL(uVal,,'TOTALBUS')
            If Len(aAux) > 0
                oModelH6P:SetValue("H6P_DSCDES",SUBSTR(FWFilialName(aAux[1],aAux[2]),0,TamSX3("H6P_DSCDES")[1]))
            Endif
        Case cField == "H6P_CODSA2"
            oModelH6P:LoadValue("H6P_DESSA2", POSICIONE("SA2",1,XFILIAL("SA2")+uVal+oModelH6P:GETVALUE("H6P_LOJSA2"),"A2_NOME")) 
        Case cField == "H6P_LOJSA2"
            oModelH6P:LoadValue("H6P_DESSA2", POSICIONE("SA2",1,XFILIAL("SA2")+oModelH6P:GETVALUE("H6P_CODSA2")+uVal,"A2_NOME")) 
	EndCase 

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA424')
Local oStrH6O	:= FWFormStruct(2, 'H6O')
Local oStrH6P	:= FWFormStruct(2, 'H6P')
Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}

SetViewStruct(oStrH6O,oStrH6P)

oView:SetModel(oModel)

oView:AddField('VIEW_H6O',oStrH6O,'H6OMASTER')
oView:AddGrid("VIEW_H6P" ,oStrH6P,"H6PDETAIL")

oView:CreateHorizontalBox('SUPERIOR', 40)
oView:CreateHorizontalBox('INFERIOR', 60)

oView:SetOwnerView("VIEW_H6O", "SUPERIOR")
oView:SetOwnerView("VIEW_H6P", "INFERIOR")

oView:SetDescription(STR0003) //"Caixa entre Empresas"

oView:AddIncrementField( 'VIEW_H6P', 'H6P_SEQ' )

oView:AddUserButton( STR0018, "", {|| GTP424H6P()} ) //"Legenda"
oView:AddUserButton( STR0019, "", {|| GA424ConTT()} ) //"Visualiza Titulo"
oView:AddUserButton( STR0020, "", {|| GTPA424B()} ) //"Bilhetes"
oView:SetViewProperty("VIEW_H6P", "GRIDDOUBLECLICK",bDblClick)

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oStrH6A, object, (Descrição do parâmetro)
@param oStrH6B, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrH6O,oStrH6P)
Local cFldsH6P := 'LEGENDA|H6P_SEQ|H6P_CODEMP|H6P_DESEMP|H6P_EMPDES|H6P_DSCDES|H6P_VALITM|H6P_CODSA2|H6P_LOJSA2|H6P_DESSA2'
Local nX       := 0

    oStrH6O:RemoveField('H6O_STATUS')

    oStrH6P:RemoveField('H6P_CODIGO')
    oStrH6P:RemoveField('H6P_STATUS')
    oStrH6P:RemoveField('H6P_FILTIT')
    oStrH6P:RemoveField('H6P_PRETIT')
    oStrH6P:RemoveField('H6P_NUMTIT')
    oStrH6P:RemoveField('H6P_PARTIT')
    oStrH6P:RemoveField('H6P_TIPTIT')
    
    oStrH6P:AddField(	"LEGENDA",;					// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        "",;						// [03]  C   Titulo do campo
	                        STR0018,;						// [04]  C   Descricao do campo	//STR0018 //"Legenda"
	                        {STR0018},;				// [05]  A   Array com Help // "Selecionar"	//STR0018 //"Legenda"
	                        "GET",;						// [06]  C   Tipo do campo
	                        "@BMP",;					// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo

For nX := 1 To Len(StrToKarr(cFldsH6P,"|"))
    oStrH6P:SetProperty(StrToKarr(cFldsH6P,"|")[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

Return

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2022
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)

If cField == 'LEGENDA'
    GTP424H6P()
Endif

Return .T.


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP424H6P()
Monta Legenda
@return nil
@author henrique.toyada
@since 24/05/2022
@version 

/*/
//------------------------------------------------------------------------------------------------------
Function GTP424H6P()

	oLegenda := FwLegend():New()
	//If(!lInsert,IF(EMPTY(H62->H62_PROTOC),"BR_VERMELHO","BR_VERDE"),"BR_VERMELHO")
	oLegenda:Add( "LEGENDA", "BR_VERMELHO" ,STR0021) //"Não Gerado"
	oLegenda:Add( "LEGENDA", "BR_VERDE"    ,STR0022    ) //"Gerado"

	oLegenda:Activate()
	
	oLegenda:View()
	oLegenda:DeActivate()

Return(Nil)

/*/{Protheus.doc} GA424ConTT
    (Valida Dados do Fornecedor para Geração do Título a Pagar)
    @type  Static Function
    @author marcelo.adente
    @since 31/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA424ConTT()
Local cFilTit   := ""
Local cNumTit	:= ""				
Local cPreTit	:= ""		
Local aArea     := GetArea()	
Local oView     := FwViewActive()	
Local oMdlGrid  := nil
Local nLine     := 0


oMdlGrid	:= oView:GetModel():GetModel('H6PDETAIL')
nLine := oMdlGrid:GetLine()

cFilTit := oMdlGrid:GetValue("H6P_FILTIT",nLine)
cPreTit := oMdlGrid:GetValue("H6P_PRETIT",nLine)
cNumTit := oMdlGrid:GetValue("H6P_NUMTIT",nLine)
 
If !Empty(cNumTit) .AND. !Empty(cPreTit) .AND. !Empty(cFilTit) 

	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))
	
	If SE2->(dbSeek( cFilTit + cPreTit + cNumTit ))
		Fc050Con()	
	EndIf
Else	
	MsgInfo(STR0023 ,STR0010 ) // //"Atenção" //'Título não foi gerado'
EndIf

RestArea(aArea)

Return 

/*/{Protheus.doc} GTPA424Grv
    (long_description)
    @type  Static Function
    @author user
    @since 25/11/2022
    @version version
    @param oModel, param_type, param_descr
    @return lRet, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GTPA424Grv(oModel)

Local lRet := .T.
Local oMdlH6O   := oModel:GetModel('H6OMASTER')
Local oMdlH6P   := oModel:GetModel('H6PDETAIL')
Local cMdlId	:= oModel:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""
Local nX        := 0 

If oModel:VldData()
    FwFormCommit(oModel)
Endif

dbSelectArea('G6T')
G6T->(dbSetOrder(3))

For nX := 1 to oMdlH6P:Length()

    If G6T->(dbSeek(xFilial('G6T')+oMdlH6P:GetValue('H6P_CODG6T', nX)))

        RecLock("G6T", .F.)

            If oModel:GetOperation() != MODEL_OPERATION_DELETE
                G6T->G6T_CODH6O := oMdlH6O:GetValue("H6O_CODIGO")
            Else
                G6T->G6T_CODH6O := ""
            Endif

        G6T->(MsUnlock())

    Endif

Next

If oModel:GetOperation() != MODEL_OPERATION_DELETE
    If MsgYesNo(STR0025, STR0024) //"Atenção!" //"Deseja gerar os titulos agora?"
        GTPA424A(3)
    EndIf
Else
    If oMdlH6O:GetValue("H6O_STATUS") != '1'
        lRet := .F.
        cMsgErro := STR0026 //"Não é possível excluir registros com títulos gerados"
        cMsgSol  := STR0027 //"Realize o estorno antes de deletar o registro!"
        oModel:SetErrorMessage(cMdlId,,cMdlId,,"GTPA424Grv",cMsgErro,cMsgSol,,)
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------  
/*/{Protheus.doc} FieldValid()
Função de validação de campos
@type function
@author flavio.martins
@since 16/02/2023
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------  
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If cField == 'H6P_CODSA2'

    If !Empty(uNewValue)

        SA2->(dbSetOrder(1))

        If !(SA2->(dbSeek(xFilial('SA2')+uNewValue)))
            lRet     := .F.
            cMsgErro := 'Fornecedor não encontrado'
            cMsgSol  := 'Verifique o código do fornecedor informado'
        Endif

    Endif

Endif 

If cField == 'H6P_LOJSA2' 

    If !Empty(uNewValue)

        If Empty(oMdl:GetValue('H6P_CODSA2'))
            lRet     := .F.
            cMsgErro :=  'Código do Fornecedor não preenchido'
            cMsgSol  := 'Informe o código do fornecedor antes de informar a loja'
        Else
            SA2->(dbSetOrder(1))

            If !(SA2->(dbSeek(xFilial('SA2')+oMdl:GetValue('H6P_CODSA2')+oMdl:GetValue('H6P_LOJSA2'))))
                lRet     := .F.
                cMsgErro := 'Fornecedor/loja não encontrado'
                cMsgSol  := 'Verifique os dados informados'
            Endif
        Endif    

    Endif

Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
