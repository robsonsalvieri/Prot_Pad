#INCLUDE 'TOTVS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA752.CH'

Static lFin752 := .F.

/*/{Protheus.doc} GTPA752
H6F   Processo de extravio
H6G   Itens processo de extravio
@type  Function
@author SIGAGTP
@since 03/10/2022
@version 1.0
@return oBrowse, Object, Objeto do Browse

/*/
Function GTPA752()
    
Local oBrowse    := Nil
Local aFieldsH6F := {}
Local aFieldsH6G := {}
Local cMsgErro   := ""

If ( !FindFunction("GTPHASACCESS") .Or.; 
    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    oBrowse    := FWMBrowse():New()

    aFieldsH6F := {'H6F_FILIAL','H6F_CODIGO','H6F_CODEXT','H6F_CODGI2','H6F_CODGID','H6F_DTVTIT',;
                'H6F_DTVIAG','H6F_CODGIC','H6F_NOMEPS','H6F_TELEFO','H6F_EMAIL',;
                'H6F_DTOCOR','H6F_DTSLA','H6F_JUSTIF','H6F_STATUS','H6F_VLREMB','H6F_QUANTI','H6F_VALOR','H6F_DTORGS','H6F_DTVTIT'}
    
    aFieldsH6G := {'H6G_FILIAL','H6G_CODIGO','H6G_SEQ','H6G_CODH6C','H6G_QUANTI','H6G_VALOR','H6G_VLREMB','H6G_STATUS'}

    If GTPxVldDic("H6F",aFieldsH6F,.T.,.T.,@cMsgErro) .AND. GTPxVldDic("H6G",aFieldsH6G,.T.,.T.,@cMsgErro)
        
        oBrowse:SetAlias('H6F')
        oBrowse:SetDescription(STR0001)//Processo de extravio
        
        oBrowse:AddLegend("H6F_STATUS == '1'", "BLUE",      STR0002, "H6F_STATUS"   )//"Aberto"
        oBrowse:AddLegend("H6F_STATUS == '2'", "RED",       STR0039, "H6F_STATUS"   )//"Rejeitado" -> Todos Itens Rejeitados
        oBrowse:AddLegend("H6F_STATUS == '3'", "GREEN",     STR0004, "H6F_STATUS"   )//"Resolvido" -> Itens Encontrados ou Título Gerado
        oBrowse:AddLegend("H6F_STATUS == '4'", "YELLOW",    STR0017, "H6F_STATUS")//"Criar Título Reembolso"
        oBrowse:AddLegend("H6F_STATUS == '5'", "ORANGE",    STR0040, "H6F_STATUS")//"Título Reembolso Gerado"    

        If !isBlind()
            oBrowse:Activate()
        EndIf

        oBrowse:Destroy()

    EndIf

EndIf

Return()
//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author henrique.toyada
@since 03/10/2022
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0005        ACTION 'VIEWDEF.GTPA752'    OPERATION OP_VISUALIZAR     ACCESS 0 // "Visualizar" 
    ADD OPTION aRotina TITLE STR0006        ACTION 'VIEWDEF.GTPA752'    OPERATION OP_INCLUIR	    ACCESS 0 // "Incluir"    
    ADD OPTION aRotina TITLE STR0007        ACTION "VIEWDEF.GTPA752"    OPERATION OP_ALTERAR	    ACCESS 0 // "Alterar"    
    ADD OPTION aRotina TITLE STR0008        ACTION 'VIEWDEF.GTPA752'    OPERATION OP_EXCLUIR	    ACCESS 0 // "Excluir"    
   
    ADD OPTION aRotina TITLE STR0038        ACTION "GA752FimEx"         OPERATION OP_ALTERAR	    ACCESS 0 // "Finalizar Extravio"     
    ADD OPTION aRotina TITLE STR0019        ACTION "GA752ConTT"         OPERATION OP_ALTERAR	    ACCESS 0 // "" 
    ADD OPTION aRotina TITLE STR0017        ACTION "GA752GerTT"         OPERATION OP_ALTERAR	    ACCESS 0 // "" 

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} 
Função responsavel pela definição do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrH6F	:= nil
Local oStrH6G	:= nil
Local oStrTot 	:= nil
Local oStrRemb 	:= nil
Local oStrPass  := nil
Local bPreLine  := {|oModel,nLine,cAction,cField,uValue| VldPreLine(oModel,nLine,cAction,cField,uValue)}
Local aFieldsH6F:= {'H6F_FILIAL','H6F_CODIGO','H6F_CODEXT','H6F_CODGI2','H6F_CODGID',;
                    'H6F_DTVIAG','H6F_CODGIC','H6F_NOMEPS','H6F_TELEFO','H6F_EMAIL',;
                    'H6F_DTOCOR','H6F_DTSLA','H6F_JUSTIF','H6F_STATUS'}
Local aFieldsH6G := {'H6G_FILIAL','H6G_CODIGO','H6G_SEQ','H6G_CODH6C','H6G_QUANTI','H6G_VALOR'}
Local cMsgErro   := ""
Local bPosValid  := {|oModel| GA752PosValid(oModel) }

If GTPxVldDic("H6F",aFieldsH6F,.T.,.T.,@cMsgErro) .AND. GTPxVldDic("H6G",aFieldsH6G,.T.,.T.,@cMsgErro)
	oStrH6F	    := FWFormStruct(1,'H6F')
	oStrH6G	    := FWFormStruct(1,'H6G')
	oStrTot 	:= FWFormStruct(1,'H6F',{|cCampo| (AllTrim(cCampo) $ "H6F_VALOR,H6F_VLREMB,H6F_QUANTI")})
 	oStrRemb 	:= FWFormStruct(1,'H6F',{|cCampo| (AllTrim(cCampo) $ "H6F_PREFIX,H6F_FORNEC,H6F_LOJA,H6F_FILORI,H6F_NUMTIT,H6F_CNATUR,H6F_DTGTIT,H6F_HRGTIT,H6F_NOMFOR,H6F_USGTIT,H6F_DTVTIT")})
	oStrPass    := FWFormStruct(1,'H6F',{|cCampo| (AllTrim(cCampo) $ "H6F_NOMEPS,H6F_TELEFO,H6F_EMAIL,H6F_JUSTIF,H6F_RGPASS,H6F_ENDPAS,H6F_CPENPS,H6F_CEPPAS")})
	SetModelStruct(oStrH6F,oStrH6G,oStrTot,oStrPass,oStrRemb)
	
    oModel := MPFormModel():New('GTPA752', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields('H6FMASTER',/*cOwner*/     ,oStrH6F)
	oModel:AddGrid  ('H6GDETAIL','H6FMASTER'    ,oStrH6G,bPreLine,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
	oModel:AddFields("TOTDETAIL","H6FMASTER"    ,oStrTot    ,/*bPre*/,/*bPos*/,{||})
	oModel:AddFields("VIEW_H6F_PASS","H6FMASTER",oStrPass   ,/*bPre*/,/*bPos*/,{||})
	oModel:AddFields("VIEW_H6F_REMB","H6FMASTER",oStrRemb   ,/*bPre*/,/*bPos*/,{||})
	
	oModel:SetRelation('H6GDETAIL',      { { 'H6G_FILIAL', 'xFilial( "H6G" )' }, {'H6G_CODIGO' , 'H6F_CODIGO' } }, H6G->( IndexKey( 1 ) ) )
	oModel:SetRelation('TOTDETAIL' ,     { { 'H6F_FILIAL', 'xFilial( "H6F" )' }, { 'H6F_CODIGO', 'H6F_CODIGO' } }, H6F->( IndexKey( 1 ) ) )
    oModel:SetRelation('VIEW_H6F_PASS' , { { 'H6F_FILIAL', 'xFilial( "H6F" )' }, { 'H6F_CODIGO', 'H6F_CODIGO' } }, H6F->( IndexKey( 1 ) ) )
    oModel:SetRelation('VIEW_H6F_REMB' , { { 'H6F_FILIAL', 'xFilial( "H6F" )' }, { 'H6F_CODIGO', 'H6F_CODIGO' } }, H6F->( IndexKey( 1 ) ) )
    
    oModel:GetModel('TOTDETAIL'    ):SetOnlyQuery ( .T. )
    oModel:GetModel('VIEW_H6F_PASS'):SetOnlyQuery ( .T. )

	oModel:GetModel("TOTDETAIL" ):SetOptional( .F. )
	oModel:GetModel("TOTDETAIL" ):SetDescription(STR0009)//"Totalizadores"
	
	oModel:SetDescription(STR0001)//"Processo de extravio"
	
	oModel:SetPrimaryKey({'H6F_FILIAL','H6F_CODIGO'})
EndIf

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
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrH6F,oStrH6G,oStrTot,oStrPass,oStrRemb)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bFldVld	:= {|oMdl,cField,uVal,nLine,uOldValue| FieldValid(oMdl,cField,uVal,nLine,uOldValue)}
Local bFldWhen  := {|oMdl,cField,uVal|FieldWhen(oMdl,cField,uVal) } 

    oStrH6F:SetProperty	('H6F_CNATUR', MODEL_FIELD_WHEN, bFldWhen)
    
    oStrH6F:AddTrigger	('H6F_CODEXT', 'H6F_CODEXT',  { || .T. }, bTrig )
    
    oStrH6F:AddTrigger	('H6F_CODGI2', 'H6F_CODGI2',  { || .T. }, bTrig ) 
    
    oStrH6F:SetProperty	('H6F_CODIGO', MODEL_FIELD_WHEN, {||.F.} )
    
    oStrH6F:SetProperty	('H6F_DESEXT', MODEL_FIELD_INIT, bInit)
    
    oStrH6F:SetProperty	('H6F_DESGI2', MODEL_FIELD_INIT, bInit)
    
    oStrH6F:AddTrigger	('H6F_DTOCOR', 'H6F_DTOCOR',  { || .T. }, bTrig ) 
    
    oStrH6F:SetProperty	('H6F_DTVTIT', MODEL_FIELD_WHEN, bFldWhen)
    
    oStrH6F:AddTrigger	('H6F_FORNEC', 'H6F_FORNEC',  { || .T. }, bTrig ) 
    
    oStrH6F:SetProperty	('H6F_FORNEC', MODEL_FIELD_WHEN, bFldWhen)
    
    oStrH6F:SetProperty	('H6F_LOJA'  , MODEL_FIELD_WHEN, bFldWhen)
    oStrH6F:AddTrigger	('H6F_LOJA', 'H6F_LOJA',  { || .T. }, bTrig ) 
    
    oStrH6F:SetProperty	('H6F_NOMEPS', MODEL_FIELD_OBRIGAT, .T.)
    
    oStrH6F:SetProperty	('H6F_NOMFOR', MODEL_FIELD_INIT, bInit)
    
    oStrH6F:SetProperty	('H6F_NUMTIT', MODEL_FIELD_WHEN, {||.F.} )
    
    oStrH6F:SetProperty	('H6F_PREFIX', MODEL_FIELD_INIT, bInit)
    oStrH6F:SetProperty	('H6F_PREFIX', MODEL_FIELD_WHEN, bFldWhen)
    
    oStrH6F:SetProperty ("H6F_STATUS", MODEL_FIELD_VALUES ,{'1=' + STR0002,'2=' + STR0039,'3=' + STR0004,'4=' + STR0017,'5=' + STR0040})

    oStrH6G:AddTrigger	('H6G_CODH6C', 'H6G_CODH6C',  { || .T. }, bTrig ) 
    
    oStrH6G:SetProperty	('H6G_CODIGO', MODEL_FIELD_INIT, bInit)
    oStrH6G:SetProperty	('H6G_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
    
    oStrH6G:SetProperty	('H6G_DESH6C', MODEL_FIELD_INIT, bInit)
    
    oStrH6G:AddTrigger	('H6G_QUANTI', 'H6G_QUANTI',  { || .T. }, bTrig ) 
    
    oStrH6G:SetProperty	('H6G_STATUS' , MODEL_FIELD_VALID,       bFldVld)
    oStrH6G:AddTrigger	('H6G_STATUS', 'H6G_STATUS',  { || .T. },  bTrig ) 
    
    oStrH6G:AddTrigger	('H6G_VALOR', 'H6G_VALOR',  { || .T. }, bTrig ) 
    
    oStrH6G:SetProperty	('H6G_VLREMB' , MODEL_FIELD_VALID,      bFldVld)
    oStrH6G:AddTrigger	('H6G_VLREMB', 'H6G_VLREMB',  { || .T. }, bTrig ) 

Return 

/*/{Protheus.doc} VldPreLine
(long_description)
@type function
@author henrique.toyada
@since 25/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uValue, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldPreLine(oMdl,nLine,cAction,cField,uValue)
Local lRet		 := .T.
Local oModel     := oMdl:GetModel()
Local cMdlId	 := oMdl:GetId()
Local nTotAdic   := 0
Local nTotCustos := 0
Local nTotReemb := 0

If cMdlId == "H6GDETAIL"

	IF (cAction == "DELETE")

        nTotAdic   := oModel:GetModel('TOTDETAIL'):GetValue('H6F_QUANTI')
        nTotCustos := oModel:GetModel('TOTDETAIL'):GetValue('H6F_VALOR')
        nTotReemb  := oModel:GetModel('TOTDETAIL'):GetValue('H6F_VLREMB')

        nTotAdic   := nTotAdic - oModel:GetModel('H6GDETAIL'):GetValue('H6G_QUANTI',nLine)
        nTotCustos := nTotCustos - oModel:GetModel('H6GDETAIL'):GetValue('H6G_VALOR',nLine)
        nTotReemb  := nTotReemb - oModel:GetModel('H6GDETAIL'):GetValue('H6G_VLREMB',nLine)


        oModel:GetModel('TOTDETAIL'):SetValue('H6F_QUANTI', nTotAdic)
	    oModel:GetModel('TOTDETAIL'):SetValue('H6F_VALOR', nTotCustos)
        oModel:GetModel('TOTDETAIL'):SetValue('H6F_VLREMB', nTotReemb)

        oModel:GetModel('H6FMASTER'):LoadValue('H6F_QUANTI', nTotAdic)
        oModel:GetModel('H6FMASTER'):LoadValue('H6F_VALOR', nTotCustos)
        oModel:GetModel('H6FMASTER'):LoadValue('H6F_VLREMB', nTotReemb)

    ELSEIF (cAction == "UNDELETE") 
        nTotAdic   := oModel:GetModel('TOTDETAIL'):GetValue('H6F_QUANTI')
        nTotCustos := oModel:GetModel('TOTDETAIL'):GetValue('H6F_VALOR')
        nTotReemb  := oModel:GetModel('TOTDETAIL'):GetValue('H6F_VLREMB')

        nTotAdic   := nTotAdic + oModel:GetModel('H6GDETAIL'):GetValue('H6G_QUANTI',nLine)
        nTotCustos := nTotCustos + oModel:GetModel('H6GDETAIL'):GetValue('H6G_VALOR',nLine)
        nTotReemb  := nTotReemb + oModel:GetModel('H6GDETAIL'):GetValue('H6G_VLREMB',nLine)
        
        oModel:GetModel('TOTDETAIL'):SetValue('H6F_QUANTI', nTotAdic)
	    oModel:GetModel('TOTDETAIL'):SetValue('H6F_VALOR' , nTotCustos)
        oModel:GetModel('TOTDETAIL'):SetValue('H6F_VLREMB', nTotReemb)

        oModel:GetModel('H6FMASTER'):LoadValue('H6F_QUANTI', nTotAdic)
        oModel:GetModel('H6FMASTER'):LoadValue('H6F_VALOR', nTotCustos)
        oModel:GetModel('H6FMASTER'):LoadValue('H6F_VLREMB', nTotReemb)
    EndIf    

Endif

Return lRet 

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
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
Local aArea     := GetArea()

Do Case 
    Case cField == "H6G_CODIGO"
		uRet := If(lInsert,M->H6F_CODIGO,H6F->H6F_CODIGO)
    Case cField == "H6F_DESEXT"
        uRet := If(!lInsert,Posicione('H6D',1,xFilial('H6D') + H6F->H6F_CODEXT,'H6D_DESCRI'),'')
    Case cField == "H6F_DESGI2"
        uRet := If(!lInsert,TPNomeLinh(H6F->H6F_CODGI2),'')
    Case cField == "H6G_DESH6C"
        uRet := If(!lInsert,Posicione('H6C',1,xFilial('H6C') + H6G->H6G_CODH6C,'H6C_DESCRI'),'')
    Case cField == "H6F_NOMFOR"
        uRet := If(!lInsert,Posicione("SA2",1,xFilial("SA2")+H6F->H6F_FORNEC+H6F->H6F_LOJA,"A2_NOME"),'')
    Case cField == "H6F_PREFIX"
        uRet := GTPGetRules('REMBPREFI',,,"")
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
Local oModelH6F := oModel:GetModel("H6FMASTER")
Local oModelH6G := oModel:GetModel("H6GDETAIL")
Local oView     := FwViewActive()
Local nValItem  := 0
Local cMsgErro  := ""
Local cSolucao  := ""

	Do Case 
        Case cField == "H6F_CODEXT"
            CargaExtravio(oMdl,uVal,@cMsgErro)
            oMdl:SetValue("H6F_DESEXT",Posicione('H6D',1,xFilial('H6D') + uVal,'H6D_DESCRI'))
        Case cField == "H6G_CODH6C"
            SetFieldH6C(oMdl,uVal)
            CalcTotal(oMdl)
            oModelH6G:LoadValue("H6G_QUANTI", 1)
        Case cField == "H6G_QUANTI"
            If !(EMPTY(oModelH6G:GetValue("H6G_CODH6C")))
                nValItem := POSICIONE("H6C",1,XFILIAL("H6C")+oModelH6G:GetValue("H6G_CODH6C"),"H6C_VALOR")
            EndIf
            oModelH6G:LoadValue("H6G_VALOR", nValItem *uVal)
            CalcTotal(oMdl)
        Case cField == "H6F_CODGI2" 
            oMdl:SetValue("H6F_DESGI2",TPNomeLinh(uVal))
        Case cField == "H6F_DTOCOR"
            CalculaSla(oMdl,uVal,@cMsgErro,@cSolucao)
            CalcORGSLA(oMdl,uVal,@cMsgErro,@cSolucao)
        Case cField == "H6G_VALOR"
            CalcTotal(oMdl)
        Case cField == "H6G_VLREMB"
            CalcTotal(oMdl)
            If oModelH6G:GetValue("H6G_VLREMB") > 0
                oModelH6G:SetValue("H6G_STATUS", '2')    
            EndIf
        Case cField == 'H6F_FORNEC'
            oModelH6F:LoadValue("H6F_NOMFOR", Posicione("SA2",1,xFilial("SA2")+oModelH6F:GetValue('H6F_FORNEC')+oModelH6F:GetValue('H6F_LOJA'),"A2_NOME"))
        Case cField == 'H6F_LOJA'
            oModelH6F:LoadValue("H6F_NOMFOR", Posicione("SA2",1,xFilial("SA2")+oModelH6F:GetValue('H6F_FORNEC')+oModelH6F:GetValue('H6F_LOJA'),"A2_NOME"))    
        Case cField == 'H6G_STATUS'    
            If uVal <> '2'
                oModelH6G:SetValue("H6G_VLREMB", 0)

            ElseIf uVal == '2'
                If oModelH6G:GetValue("H6G_VLREMB") <= 0
                    MsgAlert(STR0041, STR0042)//'O Valor do Reembolso deve ser maior que 0' - 
                    oModelH6G:SetValue("H6G_STATUS", '')   
                EndIf
            EndIf
	EndCase 
    
    If !Empty(cMsgErro)
        FwAlertHelp(cMsgErro,cSolucao)
    Endif

oView:Refresh()
Return uVal

/*/{Protheus.doc} FieldWhen
	(long_description)
	@type  Static Function
	@author user
	@since 19/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function FieldWhen(oMdl,cField,uVal)

Local oModel	:= oMdl:GetModel()
Local oModelH6F := oModel:GetModel("H6FMASTER")
Local lRet      := .T.

Do Case
	Case cField == "H6F_PREFIX"
        lRet := Empty(Alltrim(GTPGetRules('REMBPREFI',,,""))) .And. Empty((Alltrim(oModelH6F:GetValue('H6F_NUMTIT'))))
    Case cField $ "H6F_CNATUR|H6F_FORNEC|H6F_LOJA|H6F_DTVTIT"
        lRet :=  Empty((Alltrim(oModelH6F:GetValue('H6F_NUMTIT'))))

EndCase

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetFieldH6C
Função responsavel pelo preenchimento dos campos do tipo de item
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@param cCodH6C, character, (Descrição do parâmetro)
@return nil, retorna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetFieldH6C(oMdl,cCodH6C)
Local aAreaH6C  := H6C->(GetArea())

H6C->(DbSetOrder(1))//H6C_FILIAL+H6C_CODIGO
If H6C->(DbSeek(xFilial('H6C')+cCodH6C))

    oMdl:SetValue('H6G_DESH6C',H6C->H6C_DESCRI)
    If oMdl:GetValue("H6G_QUANTI") > 0
        oMdl:SetValue('H6G_VALOR' ,H6C->H6C_VALOR * oMdl:GetValue("H6G_QUANTI") )
    Else
        oMdl:SetValue('H6G_VALOR' ,H6C->H6C_VALOR)
    EndIf
Endif

RestArea(aAreaH6C)
GtpDestroy(aAreaH6C)
Return nil

/*/{Protheus.doc} CalculaSla
    Efetua o calculo do sla
    @type  Static Function
    @author user
    @since 06/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CalculaSla(oMdl,uVal,cMsgErro,cSolucao)
Local dDtFim    := uVal
Local cTpVigen  := ""
Local nTempVig  := 0
Local cCodH6D   := oMdl:GetValue("H6F_CODEXT")

If !(EMPTY(cCodH6D))

    H6D->(DBSETORDER(1))
    If H6D->(DBSEEK(XFILIAL("H6D") + cCodH6D))
        cTpVigen := H6D->H6D_PERIOD
        nTempVig := H6D->H6D_QTDPE

        Do Case
            Case cTpVigen == "3" //Dia
                dDtFim  := DaySum(uVal,nTempVig)
            Case cTpVigen == "2" //Mes
                dDtFim  := MonthSum(uVal,nTempVig)
            Case cTpVigen == "1" //Ano
                dDtFim  := YearSum(uVal,nTempVig)
        EndCase
    Else
        cMsgErro := STR0010 //"Código do extravio do extravio selecionado não foi encontrado!"
        cSolucao := STR0011 //"Selecione um código de tipo de extravio válido!"
    EndIf
Else
    cMsgErro := STR0012 //"Código do extravio não preenchido!"
    cSolucao := STR0013 //"Selecione um código de tipo de extravio válido!"
EndIf

oMdl:SetValue('H6F_DTSLA ' ,dDtFim)

Return 

/*/{Protheus.doc} CargaExtravio
    Carrega a grid de itens do extravio 
    @type  Static Function
    @author user
    @since 06/10/2022
    @version version
    @param oMdl, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CargaExtravio(oMdl,uVal,cMsgErro)
Local lRet 			:= .T.
Local cAliasTmp		:= GetNextAlias()
Local oView         := FwViewActive()
Local oMdlGrid		:= oView:GetModel():GetModel('H6GDETAIL')
Local nTotCustos    := 0
Local nQuantidade   := 1

BeginSql  Alias cAliasTmp

    SELECT H6E.H6E_SEQ, H6E.H6E_CODH6C, H6C.H6C_DESCRI, H6E.H6E_VALH6C
    FROM %Table:H6D% H6D
    INNER JOIN %Table:H6E% H6E
        ON H6E.H6E_FILIAL = H6D.H6D_FILIAL
        AND H6E.H6E_CODIGO = H6D.H6D_CODIGO
        AND H6E.%NotDel%
    INNER JOIN %Table:H6C% H6C
        ON H6C.H6C_FILIAL = %xFilial:H6C%
        AND H6C.H6C_CODIGO = H6E.H6E_CODH6C
        AND H6C.%NotDel%
    WHERE H6D.H6D_FILIAL = %xFilial:H6D%
        AND H6D.H6D_CODIGO = %Exp:uVal%
        AND H6D.%NotDel%

EndSql

If !(cAliasTmp)->(Eof()) .AND. !(oMdlGrid:IsEmpty())
    FwAlertWarning(STR0014, STR0015)//"Os dados carregados sobrescreverão os atuais itens" , "Aviso"
    oMdlGrid:DelAllLine(.T.)
EndIf

While !(cAliasTmp)->(Eof())

    If !(oMdlGrid:IsEmpty())
        oMdlGrid:AddLine()
    Endif

    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6G_SEQ"   })[1],(cAliasTmp)->H6E_SEQ)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6G_CODH6C"})[1],(cAliasTmp)->H6E_CODH6C)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6G_DESH6C"})[1],(cAliasTmp)->H6C_DESCRI)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6G_VALOR" })[1],(cAliasTmp)->H6E_VALH6C)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6G_QUANTI"})[1],1)
    
    nTotCustos += (cAliasTmp)->H6E_VALH6C
    oView:GetModel():GetModel('TOTDETAIL'):LoadValue('H6F_VALOR', nTotCustos)
    oView:GetModel():GetModel('TOTDETAIL'):LoadValue('H6F_QUANTI', nQuantidade++)

    (cAliasTmp)->(dbSkip())

End

oMdlGrid:GoLine(1)

(cAliasTmp)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
    Local oView		:= FWFormView():New()
    Local oModel	:= FwLoadModel('GTPA752')
    Local oStrH6F	:= FWFormStruct(2, 'H6F',{|cCampo| !(AllTrim(cCampo) $ "H6F_VALOR,H6F_VLREMB,H6F_QUANTI,H6F_PREFIX,H6F_FORNEC,H6F_LOJA,H6F_FILORI,H6F_NUMTIT,H6F_CNATUR,H6F_DTGTIT,H6F_HRGTIT,H6F_USGTIT,H6F_NOMFOR,H6F_NOMEPS,H6F_TELEFO,H6F_EMAIL,H6F_JUSTIF,H6F_RGPASS,H6F_ENDPAS,H6F_CPENPS,H6F_CEPPAS,H6F_DTVTIT")})
    Local oStrH6G	:= FWFormStruct(2, 'H6G')
    Local oStrTot 	:= FWFormStruct(2, 'H6F',{|cCampo| (AllTrim(cCampo) $ "H6F_VALOR,H6F_VLREMB,H6F_QUANTI")})
    Local oStrRemb 	:= FWFormStruct(2, 'H6F',{|cCampo| (AllTrim(cCampo) $ "H6F_PREFIX,H6F_FORNEC,H6F_LOJA,H6F_FILORI,H6F_NUMTIT,H6F_CNATUR,H6F_DTGTIT,H6F_HRGTIT,H6F_USGTIT,H6F_NOMFOR,H6F_DTVTIT")})
    Local oStrPass  := FWFormStruct(2, 'H6F',{|cCampo| (AllTrim(cCampo)  $ "H6F_NOMEPS,H6F_TELEFO,H6F_EMAIL,H6F_JUSTIF,H6F_RGPASS,H6F_ENDPAS,H6F_CPENPS,H6F_CEPPAS")})

    SetViewStruct(oStrH6F,oStrH6G,oStrTot,oStrPass,oStrRemb,oModel)

    oView:SetContinuousForm(.F.)
    oView:SetModel(oModel)

    oView:AddField('VIEW_H6F'     ,oStrH6F, 'H6FMASTER')
    oView:AddField('VIEW_H6F_PASS',oStrPass,'H6FMASTER')
    oView:AddField('VIEW_H6F_REMB',oStrRemb,'H6FMASTER')
    oView:AddGrid('VIEW_H6G'      ,oStrH6G, 'H6GDETAIL')
    
    oView:AddField('VW_TOTDETAIL' , oStrTot,'TOTDETAIL')
        
    oView:CreateFolder("FOLDER")
    //Aba01
    oView:AddSheet("FOLDER", "ABA01", 'Dados do Extravio')
    
    oView:CreateHorizontalBox('UPPER' , 50,,,"FOLDER", "ABA01")
    oView:CreateHorizontalBox('BOTTOM', 30,,,"FOLDER", "ABA01")
    oView:CreateHorizontalBox('TOTAL' , 20,,,"FOLDER", "ABA01")

    //Aba02
    oView:AddSheet("FOLDER", "ABA02", 'Dados do Passageiro')
    oView:CreateHorizontalBox('UPPER_PASS', 100,,,"FOLDER", "ABA02")

    //Aba03
    oView:AddSheet("FOLDER", "ABA03", 'Dados de Reembolso')
    oView:CreateHorizontalBox('UPPER_REMB' , 100,,,"FOLDER", "ABA03")
   
    oView:SetOwnerView('H6FMASTER','UPPER')
    oView:SetOwnerView('VIEW_H6F','UPPER')
    oView:SetOwnerView('VIEW_H6F_PASS','UPPER_PASS')
    oView:SetOwnerView('VIEW_H6F_REMB','UPPER_REMB')
    oView:SetOwnerView('VIEW_H6G','BOTTOM')
    oView:SetOwnerView('VW_TOTDETAIL','TOTAL')

    oView:SetDescription(STR0001) //"Processo de extravio"

    oView:EnableTitleView('VW_TOTDETAIL' , STR0009) //"Totalizadores"

    oView:AddIncrementField('VIEW_H6G','H6G_SEQ')

    oView:SetViewCanActivate( { || GA752VValid(oView)})
    
    oView:SetAfterViewActivate( { || AfterActiv(oView)})
  

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
Static Function SetViewStruct(oStrH6F,oStrH6G,oStrTot,oStrPass,oStrRemb,oMdl)
Local aCmpH6FFim    := {'H6F_STATUS'}
Local aCmpH6GFim    := {'H6G_STATUS','H6G_VLREMB'}
Local aCmpPassFim   := {'H6F_JUSTIF'}
Local nCmpo         := 0
Local aCmposH6F     := {}
Local aCmposPass    := {}
Local aCmposH6G     := {}
Local oModel	    := oMdl:GetModel()
Local nOper752      := oModel:GetOperation()

aCmposH6F   := oStrH6F:GetFields()
aCmposPass  := oStrPass:GetFields()
aCmposH6G   := oStrH6G:GetFields()


If lFin752 
    //INATIVOS
    For nCmpo :=1 To Len(aCmposH6F)
            oStrH6F:SetProperty(aCmposH6F[nCmpo][1]	 , MVC_VIEW_CANCHANGE , .F. )
    Next
    
    For nCmpo :=1 To Len(aCmposPass)
            oStrPass:SetProperty(aCmposPass[nCmpo][1]  , MVC_VIEW_CANCHANGE , .F. )
    Next

    For nCmpo :=1 To Len(aCmposH6G)

            oStrH6G:SetProperty(aCmposH6G[nCmpo][1]	 , MVC_VIEW_CANCHANGE , .F. )
    Next
      
    // ATIVOS
    For nCmpo :=1 To Len(aCmpH6FFim)
            oStrH6F:SetProperty(aCmpH6FFim[nCmpo]	 , MVC_VIEW_CANCHANGE , .T. )
    Next

    For nCmpo :=1 To Len(aCmpPassFim)
            oStrPass:SetProperty(aCmpPassFim[nCmpo]	 , MVC_VIEW_CANCHANGE , .T. )
    Next
    
    For nCmpo :=1 To Len(aCmpH6GFim)
            oStrH6G:SetProperty(aCmpH6GFim[nCmpo]  , MVC_VIEW_CANCHANGE , .T. )
    Next

EndIf

oStrH6F:RemoveField("H6F_STATUS")
oStrH6G:RemoveField('H6G_CODIGO')
 
Return

/*/{Protheus.doc} AfterActiv
//TODO Descrição auto-gerada.
@author GTP
@since 16/11/2020
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function AfterActiv(oView)
    Local oModel := oView:GetModel()

    CalcTotal(oModel)

    oView:Refresh()

Return

/*/{Protheus.doc} CalcTotal
@author GTP
@since 12/11/2020
@version undefined
@param oModel, object, descricao
@param nTotalAtual, numeric, descricao
@param xValor, , descricao
@param lSomando, logical, descricao
@param cCampo, characters, descricao
@type function
/*/
Static Function CalcTotal(oMdl)
Local nX			:= 0
Local aSaveLines	:= FWSaveRows()
Local nTotAdic      := 0
Local nTotCustos    := 0
Local nTotReemb     := 0
Local nTotal        := 0
Local oModel	    := oMdl:GetModel()
Local oView         := FwViewActive()

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
    
    oModel:GetModel('H6FMASTER'):LoadValue('H6F_QUANTI', nTotAdic)
    oModel:GetModel('H6FMASTER'):LoadValue('H6F_VALOR', nTotCustos)
    oModel:GetModel('H6FMASTER'):LoadValue('H6F_VLREMB', nTotReemb)

    oModel:GetModel('TOTDETAIL'):LoadValue('H6F_QUANTI', nTotAdic)
    oModel:GetModel('TOTDETAIL'):LoadValue('H6F_VALOR', nTotCustos)
    oModel:GetModel('TOTDETAIL'):LoadValue('H6F_VLREMB', nTotReemb)

	For nX := 1 to oModel:GetModel('H6GDETAIL'):Length() //Custo Cadastral
        If !(oModel:GetModel('H6GDETAIL'):IsDeleted(nX))
            nTotAdic   += oModel:GetModel('H6GDETAIL'):GetValue('H6G_QUANTI',nX)
            nTotCustos += oModel:GetModel('H6GDETAIL'):GetValue('H6G_VALOR',nX)
            nTotReemb  += oModel:GetModel('H6GDETAIL'):GetValue('H6G_VLREMB',nX)
        EndIf
    Next nX 

    oModel:GetModel('H6FMASTER'):LoadValue('H6F_QUANTI', nTotAdic)
    oModel:GetModel('H6FMASTER'):LoadValue('H6F_VALOR', nTotCustos)
    oModel:GetModel('H6FMASTER'):LoadValue('H6F_VLREMB', nTotReemb)

	oModel:GetModel('TOTDETAIL'):LoadValue('H6F_QUANTI', nTotAdic)
	oModel:GetModel('TOTDETAIL'):LoadValue('H6F_VALOR', nTotCustos)
	oModel:GetModel('TOTDETAIL'):LoadValue('H6F_VLREMB', nTotReemb)

EndIf

FWRestRows(aSaveLines)
oView:Refresh()
Return nTotal

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author marcelo.adente
@since 21/10/2022
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
    
    Case cField == "H6G_VLREMB" .Or. cField == "H6G_VALOR"
        If  uNewValue < 0
            lRet     := .F.
            cMsgErro := STR0023 //'O valor deve ser positivo'
            cMsgSol  := STR0024//'Insira um valor positivo'
        Endif
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} CalcORGSLA
    (Calcula SLA do Orgão apartir do critério cadastrado no cadastro do Orgão)
    @type  Static Function
    @author marcelo.adente
    @since 25/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CalcORGSLA(oMdl,dDtOcorr,cMsgErro,cSolucao)
Local aArea     := GetArea()
Local CAlias    := GetNextAlias()
Local cSQL      := ''
Local nTempVig  := ''
Local cTpPeriod := ''
Local cLinha    := '' 
Local dDtFim    := ''

cLinha := oMDL:GetValue('H6F_CODGI2')

If ValType(oMdl) == 'O' .AND. !Empty(Alltrim(cLinha))

    cSQL += "SELECT "
    cSQL += "    GI0.GI0_TPPERI, "
    cSQL += "    GI0.GI0_PERIOD  "
    cSQL += "FROM "
    cSQL +=      RetSqlName('GI2') + " GI2 "
    cSQL += "    INNER JOIN " + RetSqlName('GI0')  + " GI0 ON GI0.GI0_COD = GI2.GI2_ORGAO "
    cSQL += "    AND GI0.GI0_FILIAL = " + ValToSQL(xFilial('GI0')) 
    cSQL += "    AND GI2.D_E_L_E_T_ = ' ' "
    cSQL += "WHERE "
    cSQL += "        GI2.GI2_COD = " + ValtoSQL(cLinha)
    cSQL += "    AND GI2.GI2_FILIAL = " + ValtoSQL(xFilial('GI2'))
    cSQL += "    AND GI2.D_E_L_E_T_ = ' ' "

    cSQL := ChangeQuery(cSQL) 
        
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAlias,.T.,.T.)

    nTempVig  := (cAlias)->GI0_PERIOD 
    cTpPeriod :=(cAlias)->GI0_TPPERI

        If !(EMPTY((cAlias)->GI0_PERIOD)) .AND. !(EMPTY((cAlias)->GI0_TPPERI))

            Do Case
                Case cTpPeriod == '1' //Ano
                    dDtFim  := YearSum(dDtOcorr,nTempVig)
                Case cTpPeriod == '2' //Mes
                    dDtFim  := MonthSum(dDtOcorr,nTempVig)
                Case cTpPeriod == '3' //Dia
                    dDtFim  := DaySum(dDtOcorr,nTempVig)
            EndCase
            oMdl:SetValue('H6F_DTORGS' ,dDtFim)
        Else
            cMsgErro := STR0025 //"Somente será preenchido o campo SLA Orgão se existir uma Linha selecionada"
            cSolucao := STR0026 //"Preencha o campo Linha com uma Linha válida"
        EndIf
EndIf

RestArea(aArea)

Return 

/*/{Protheus.doc} GA752GerTT
    (Gera Título a Pagar de Reembolso)
    @type  Static Function
    @author user
    @since 31/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA752GerTT(cStaH6F,oModel)
Local aArea         := GetArea()
Local aTitulo       := {}
Local aCamposVld    := {'H6F_PREFIX','H6F_FORNEC','H6F_LOJA','H6F_CNATUR','H6F_DTVTIT'}
Local nCamposVld    := 0
Local cParc         := StrZero(1,TamSx3('E2_PARCELA')[1])
Local GtpTitNum     := ''
Local cTipo         := 'TF'
Local cCodigo       := ''
Local cPrefixo      := ''
Local cTitulo       := ''
Local cFornec       := ''
Local cLoja         := ''
Local dVenc         := ''
Local nVlRemb       := 0
Local lRet          := .T.
Local lGerTit       := .F.
Local cPath     := GetSrvProfString("StartPath","")
Local cFile     := ""
Private lMsErroAuto := .F.

Default  oModel        := ''
If   Len(cStaH6F) > 1
    cStaH6F := H6F->H6F_STATUS
EndIf

If ValType(oModel) <> 'O'
     oModel:=FwLoadModel("GTPA752")
     oModel:SetOperation(MODEL_OPERATION_UPDATE)
     oModel:Activate() 
EndIf
    cCodigo   :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_CODIGO')
    cPrefixo  :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_PREFIX')
    cTitulo   :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_NUMTIT')
    cNatureza :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_CNATUR') 
    cFornec   :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_FORNEC') 
    cLoja     :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_LOJA'  ) 
    dVenc     :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_DTVTIT') 
    nVlRemb   :=  oModel:GetModel('H6FMASTER'):GetValue('H6F_VLREMB') 
If  cStaH6F <> '4'
    MsgAlert(STR0043,STR0044) //'Status Inválido para geração do Título','Status Inválido'
    lGerTit:= .F.
ElseIf !Empty(cTitulo)
    MsgAlert(STR0028 + ' [' + cTitulo + '] ' + STR0045 ,STR0031) //'O Título [' + cTitulo + '] já foi gerado.',Reembolso
    lGerTit:= .F.
Else
    If MsgYesNo(STR0027, STR0028)
        For nCamposVld :=1 To Len(aCamposVld)
            If Empty(oModel:GetModel('H6FMASTER'):GetValue(aCamposVld[nCamposVld]))
                MsgAlert(STR0029 + RTRIM(GetSx3Cache(aCamposVld[nCamposVld],"X3_DESCRIC")) + STR0030 , STR0031 )//'O campo ' ... ' não foi preenchido.'  'Reembolso'
                lGerTit:= .F.
                Exit
            Else
                lGerTit:= .T.
            EndIf
        Next
    Else
        oModel:GetModel('H6FMASTER'):LoadValue('H6F_STATUS', '4' )
    EndIf
EndIf
    
If lGerTit
    Begin Transaction
            CursorWait()
        
            GtpTitNum := GtpTitNum('SE2', cPrefixo, cParc, cTipo)
    
            aAdd( aTitulo,	{"E2_PREFIXO" 	, cPrefixo                                  	, NIL 	} ) 
            aAdd( aTitulo,	{"E2_NUM" 	    , GtpTitNum  				                    , NIL 	} )
            aAdd( aTitulo,	{"E2_TIPO" 	    , cTipo 				 	                    , NIL 	} )  
            aAdd( aTitulo,	{"E2_PARCELA" 	, cParc				                            , NIL 	} )
            aAdd( aTitulo,	{"E2_NATUREZ" 	, cNatureza                                     , NIL 	} ) 
            aAdd( aTitulo,	{"E2_FORNECE"	, cFornec                                       , NIL 	} )
            aAdd( aTitulo,	{"E2_LOJA"   	, cLoja                                         , NIL 	} )
            aAdd( aTitulo,	{"E2_EMISSAO"	, dDataBase			                            , NIL 	} )
            aAdd( aTitulo,	{"E2_VENCTO" 	, dVenc                                         , NIL 	} )			                        
            aAdd( aTitulo, 	{"E2_VENCREA" 	, dVenc                                         , NIL 	} )			                        
            aAdd( aTitulo,	{"E2_MOEDA" 	, 1					                            , NIL 	} )
            aAdd( aTitulo,	{"E2_VALOR" 	, nVlRemb                                       , NIL 	} )
            aAdd( aTitulo,	{"E2_HIST"	    , xFilial('H6F')+cCodigo+STR0032            	, NIL   } ) // "_REEMBOLSO_EXTRAVIO"
            aAdd( aTitulo,	{"E2_ORIGEM" 	, 'GTPA752'		                                , NIL 	} )

            MsExecAuto( { |x,y| FINA050(x,y)} , aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão

            If lMsErroAuto
                lRet := .F.
                cMsgTit := MostraErro(cPath,cFile) + CRLF
                MsgAlert(cMsgTit)
                DisarmTransaction()
            ElseIf oModel:Activate() 
                oModel:GetModel('H6FMASTER'):LoadValue('H6F_DTGTIT', dDataBase  )
                oModel:GetModel('H6FMASTER'):LoadValue('H6F_HRGTIT', Substr(Time(),1,5))
                oModel:GetModel('H6FMASTER'):LoadValue('H6F_USGTIT', cUserName  )
                oModel:GetModel('H6FMASTER'):LoadValue('H6F_NUMTIT', GtpTitNum  )
                oModel:GetModel('H6FMASTER'):LoadValue('H6F_FILORI', xFilial('SE2')  )
                oModel:GetModel('H6FMASTER'):LoadValue('H6F_STATUS', '5'          )
                MsgInfo(STR0033 + ' [' + GtpTitNum + '] ' +  STR0034, STR0035) // 'Título a pagar' + ' gerado com Sucesso!' + 'Título Gerado'
                If( oModel:VldData() )
                    lRet:= oModel:CommitData()
                EndIf
            EndIf
    End Transaction           
EndIf
RestArea(aArea)
   
Return lRet

/*/{Protheus.doc} GA752ConTit
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
Function GA752ConTT()
Local cFilTit   := ""
Local cNumTit	:= ""				
Local cPreTit	:= ""		
Local aArea     := GetArea()		

cFilTit := H6F->H6F_FILORI
cPreTit := H6F->H6F_PREFIX
cNumTit := H6F->H6F_NUMTIT
 
If !Empty(cNumTit) .AND. !Empty(cPreTit) .AND. !Empty(cFilTit) 

	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))
	
	If SE2->(dbSeek( cFilTit + cPreTit + cNumTit ))
		Fc050Con()	
	EndIf
Else	
	MsgInfo(STR0037 ,STR0033 ) //'Título não foi gerado'
EndIf

RestArea(aArea)

Return 

/*/{Protheus.doc} GA752FimEx
    (Valida Dados do Fornecedor para Geração do Título a Pagar)
    @type  Static Function
    @author marcelo.adente
    @since 31/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
/*/
Function GA752FimEx()
lFin752 := .T.

If H6F->H6F_STATUS == '1' .OR. H6F->H6F_STATUS == '4'
    FWExecView(STR0038,"GTPA752",MODEL_OPERATION_UPDATE,,{|| .T.})// Finaliza Extravio
EndIf

lFin752 := .F.
Return

/*/{Protheus.doc} GA752PREValid
    (Valida Dados no carregamento da view)
    @type  Static Function
    @author marcelo.adente
    @since 31/10/2022
    @version 1.0
    @param oModel, Object, Modelo GTPA752
    @return lRet, boolean, Retorna validação da execução
/*/
Static Function GA752VValid(oView)
Local lRet      := .F.
Local oModel	:= oView:GetModel()
Local cStaH6F   := ''

If oModel:Activate()
    cStaH6F:= oModel:GetModel('H6FMASTER'):GetValue('H6F_STATUS')

    If oModel:GetOperation() == MODEL_OPERATION_DELETE .AND. (cStaH6F == '2' .OR. cStaH6F == '5' .OR. cStaH6F == '3')
        MsgAlert(STR0050,STR0051)//'Não é possível excluir um processo já finalizado','Exclusão de Processo de Extravio de Bagagem')
        lRet:= .F.
    Else
        lRet:= .T.
    EndIF
    oModel:DeActivate()
EndIf

Return lRet

/*/{Protheus.doc} GA752PosValid
    (Valida Dados após a inserção, qualificando Status do Extravio de Bagagem)
    @type  Static Function
    @author marcelo.adente
    @since 31/10/2022
    @version 1.0
    @param oModel, Object, Modelo GTPA752
    @return lRet, boolean, Retorna validação da execução
/*/
Static Function GA752PosValid(oModel)
Local lRet      := .T.
Local oModelH6F	:= oModel:GetModel("H6FMASTER")
Local oModelH6G	:= oModel:GetModel("H6GDETAIL")
Local cStatH6F  := oModelH6F:GetValue("H6F_STATUS")
Local cTitulo   := oModelH6F:GetValue("H6F_NUMTIT")
Local nI        := 0
Local cItensH6G := ''

If lFin752 
    If cStatH6F == '1'
        For nI	:= 1 To  oModelH6G:Length()
            oModelH6G:GoLine(nI)
            If Empty(oModelH6G:GetValue("H6G_STATUS"))
                oModel:SetErrorMessage(oModel:GetId(),"H6G_STATUS",oModel:GetId(),"H6G_STATUS","GA752PosValid",STR0047,STR0046) ////'Preencha o Status de todos os itens.', 'Itens não Avaliados'
                lRet:= .F.
                Exit
            Else
                cItensH6G += oModelH6G:GetValue("H6G_STATUS")
            EndIf
        Next
        // 1=Aberto;2=Rejeitado;3=Resolvido;4=Gerar Título;5=Título Gerado - H6F
        //1=Encontrado;2=Reembolsar;3=Recusado - H6G
        Do Case
            CASE '3' $ cItensH6G .AND.  !('1' $ cItensH6G ) .AND.  !('2' $ cItensH6G ) 
                cStatH6F := '2'
            CASE '2' $ cItensH6G 
                cStatH6F := '4'
            CASE '1' $ cItensH6G 
                cStatH6F := '3'
        EndCase
        
        If cStatH6F == '4' 
            lRet:= GA752GerTT(cStatH6F,oModel)
        ElseIf lRet
            lRet:= oModel:GetModel('H6FMASTER'):LoadValue('H6F_STATUS',cStatH6F)
        EndIf
    ElseIf Empty(cTitulo) .AND. (cStatH6F <> '1' )
        MsgAlert(STR0048,STR0049) //'O processo já foi finalizado ou aguarda a geração de título' , 'Fechamento Extravio de Bagagem'
    EndIf
EndIf


Return lRet