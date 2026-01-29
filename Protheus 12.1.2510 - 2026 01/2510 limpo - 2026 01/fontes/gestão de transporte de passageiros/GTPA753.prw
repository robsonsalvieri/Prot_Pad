#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA753
H6I	Movimentações da bagagem
H6J	Itens Movimento
@type  Function
@author henrique.toyada
@since 03/10/2022
@version version
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA753()
    
    Local oBrowse    := Nil
    
    If ( !FindFunction("GTPHASACCESS") .Or.; 
	    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
    
        oBrowse    := FWMBrowse():New()
        
        If ( VldDic() )
            
            PreencH6IStatus()

            oBrowse:SetAlias('H6I')
            //1=Iniciado;2=Em transito;3=Recebido;4=Retirado
            oBrowse:AddLegend("H6I_STATUS == '1'", "WHITE" , "Iniciado"     , "H6I_STATUS"   )
            oBrowse:AddLegend("H6I_STATUS == '2'", "YELLOW", "Em transito"  , "H6I_STATUS"   )
            oBrowse:AddLegend("H6I_STATUS == '3'", "GREEN" , "Recebido"     , "H6I_STATUS"   )
            oBrowse:AddLegend("H6I_STATUS == '4'", "BLUE"  , "Retirado"     , "H6I_STATUS"   )
            oBrowse:AddLegend("H6I_STATUS == '5'", "RED"   , "Doc. Retirada Impresso"     , "H6I_STATUS"   )

            oBrowse:SetDescription("Movimentações da bagagem")
            
            If !isBlind()
                oBrowse:Activate()
            EndIf

            oBrowse:Destroy()
            
            R753CloseWord() //Fecha o Link com o word
            
        EndIf

    EndIf

Return()

/*/{Protheus.doc} PreencH6IStatus
    (long_description)
    @type  Static Function
    @author user
    @since 17/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function PreencH6IStatus()
Local aArea     := GetArea() 
Local dDataHoje := DATE()

    H6I->(DBGOTOP())
    WHILE H6I->(!(EOF()))
        If H6I->H6I_STATUS == '1' .And. dDataHoje > H6I->H6I_DTPROC
            RecLock("H6I", .F.)
            H6I->H6I_STATUS := '2'    
            H6I->(MsUnlock())
        EndIf
        H6I->(DBSKIP())
    END
RESTAREA(aArea)
Return 

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

    ADD OPTION aRotina TITLE "Visualizar"       ACTION 'VIEWDEF.GTPA753' OPERATION OP_VISUALIZAR    ACCESS 0 
    ADD OPTION aRotina TITLE "Incluir"          ACTION 'VIEWDEF.GTPA753' OPERATION OP_INCLUIR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Alterar"          ACTION 'VIEWDEF.GTPA753' OPERATION OP_ALTERAR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Excluir"          ACTION 'VIEWDEF.GTPA753' OPERATION OP_EXCLUIR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Recebimento"      ACTION 'GTP753Receb'     OPERATION OP_ALTERAR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Retirada"         ACTION 'GTP753Retira'    OPERATION OP_ALTERAR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Doc. Retirada"    ACTION 'GTP753DocPrt'    OPERATION OP_ALTERAR	    ACCESS 0 

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTP753DocPrt
Função responsavel pela definição do menu
@type Static Function
@author henrique.toyada
@since 03/10/2022
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Function GTP753DocPrt()

    Local oMdl753 := FwLoadModel("GTPA753")

    Local cMsg  := ""

    Local lOk   := .F.

    If ( H6I->H6I_STATUS $ '4|5')
        
        lOk := GTPR753(H6I->H6I_CODH6F,H6I->H6I_CODIGO,.F.) 
        
        If ( lOk .And. H6I->H6I_STATUS == "4" )
            
            oMdl753:SetOperation(MODEL_OPERATION_UPDATE)
            oMdl753:Activate()    
            
            oMdl753:GetModel("H6IMASTER"):SetValue("H6I_STATUS","5")
            
            If lOk .AND. oMdl753:VldData()
                lOk := oMdl753:CommitData()
            EndIf
        
            oMdl753:DeActivate()    
        
        EndIf

    Else
        
        cMsg := "Somente as movimentações de bagagens que foram ou "
        cMsg += "'4-Recebida' ou '5-Doc. Impressa' poderão ter os documentos impresso."

        FwAlertWarning(cMsg)
    
    EndIf    

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
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
Local oStrH6I	:= nil
Local oStrH6J	:= nil
Local bPreLine  := {|oModel,nLine,cAction,cField,uValue| VldPreLine(oModel,nLine,cAction,cField,uValue)}
Local bPosValid := {|oModel| PosValid(oModel)}
Local bLinePost := {|oGrid| LinePost(oGrid)}


    oStrH6I	:= FWFormStruct(1,'H6I')
    oStrH6J	:= FWFormStruct(1,'H6J')

    SetModelStruct(oStrH6I,oStrH6J)

    oModel := MPFormModel():New('GTPA753', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
    oModel:SetVldActivate({|| VldDic()})
    
    oModel:AddFields('H6IMASTER',/*cOwner*/,oStrH6I)
    oModel:AddGrid('H6JDETAIL','H6IMASTER',oStrH6J,bPreLine,bLinePost, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)

    oModel:SetRelation('H6JDETAIL',{{ 'H6J_FILIAL','xFilial("H6J")'},{'H6J_CODIGO','H6I_CODIGO' }},H6J->(IndexKey(1)))

    oModel:SetDescription("Movimentações da bagagem")

    oModel:SetPrimaryKey({'H6I_FILIAL','H6I_CODIGO'})

Return oModel

Static Function VldDic()

    Local lRet  := .T.
    
    Local aFieldsH6I := {'H6I_CODIGO','H6I_DESCRI','H6I_AGEORI','H6I_AGEDES','H6I_DTPROC','H6I_CODH6F','H6I_STATUS',;
                        'H6I_DTRECE','H6I_HRRECE','H6I_USRECE','H6I_DTRETI','H6I_HRRETI','H6I_USRETI'}
    Local aFieldsH6J := {'H6J_CODIGO','H6J_SEQ','H6J_LINHA','H6J_SERVIC','H6J_AGEORI','H6J_LOCORI','H6J_AGEDES','H6J_LOCDES','H6J_DTPREV'}
    
    Local cMsgErro   := ""

    lRet := GTPxVldDic("H6I",aFieldsH6I,.T.,.T.,@cMsgErro) .AND. GTPxVldDic("H6J",aFieldsH6J,.T.,.T.,@cMsgErro)
    
    If ( !lRet )
        FwAlertWarning(cMsgErro)
    EndIf

Return(lRet)

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
Static Function SetModelStruct(oStrH6I,oStrH6J)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

    oStrH6I:SetProperty('H6I_DESCRI', MODEL_FIELD_OBRIGAT, .T.)
    oStrH6I:SetProperty('H6I_AGEORI', MODEL_FIELD_OBRIGAT, .T.)
    oStrH6I:SetProperty('H6I_DTPROC', MODEL_FIELD_OBRIGAT, .T.)

    oStrH6J:SetProperty('H6J_CODIGO', MODEL_FIELD_INIT, bInit )
    oStrH6I:SetProperty('H6I_DESORI', MODEL_FIELD_INIT, bInit )
    oStrH6I:SetProperty('H6I_DESDES', MODEL_FIELD_INIT, bInit )
    oStrH6I:SetProperty('H6I_NMPASS', MODEL_FIELD_INIT, bInit )
    oStrH6J:SetProperty('H6J_DESAOR', MODEL_FIELD_INIT, bInit )
    oStrH6J:SetProperty('H6J_DESADE', MODEL_FIELD_INIT, bInit )
    oStrH6J:SetProperty('H6J_DESLOR', MODEL_FIELD_INIT, bInit )
    oStrH6J:SetProperty('H6J_DESLDE', MODEL_FIELD_INIT, bInit )
    oStrH6J:SetProperty('H6J_DESGI2', MODEL_FIELD_INIT, bInit )

    oStrH6I:AddTrigger('H6I_AGEORI', 'H6I_AGEORI',  { || .T. }, bTrig )
    oStrH6I:AddTrigger('H6I_AGEDES', 'H6I_AGEDES',  { || .T. }, bTrig ) 
    oStrH6J:AddTrigger('H6J_AGEORI', 'H6J_AGEORI',  { || .T. }, bTrig ) 
    oStrH6J:AddTrigger('H6J_AGEDES', 'H6J_AGEDES',  { || .T. }, bTrig ) 
    oStrH6I:AddTrigger('H6I_CODH6F', 'H6I_CODH6F',  { || .T. }, bTrig ) 
    oStrH6I:AddTrigger('H6I_DTPROC', 'H6I_DTPROC',  { || .T. }, bTrig ) 
    oStrH6I:AddTrigger('H6I_STATUS', 'H6I_STATUS',  { || .T. }, bTrig ) 
    oStrH6J:AddTrigger('H6J_LOCORI', 'H6J_LOCORI',  { || .T. }, bTrig ) 
    oStrH6J:AddTrigger('H6J_LOCDES', 'H6J_LOCDES',  { || .T. }, bTrig ) 
    oStrH6J:AddTrigger('H6J_LINHA' , 'H6J_LINHA' ,  { || .T. }, bTrig ) 

    oStrH6I:SetProperty("H6I_AGEORI" , MODEL_FIELD_VALID, bFldVld)
    oStrH6I:SetProperty("H6I_AGEDES" , MODEL_FIELD_VALID, bFldVld)
    oStrH6J:SetProperty("H6J_LINHA"  , MODEL_FIELD_VALID, bFldVld)

    oStrH6J:SetProperty("H6J_SERVIC" , MODEL_FIELD_VALID, bFldVld)
    oStrH6J:SetProperty("H6J_AGEORI" , MODEL_FIELD_VALID, bFldVld)
    oStrH6J:SetProperty("H6J_AGEDES" , MODEL_FIELD_VALID, bFldVld)
    oStrH6J:SetProperty("H6J_LOCORI" , MODEL_FIELD_VALID, bFldVld)

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
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
Local aArea     := GetArea()

Do Case 
    Case cField == "H6J_CODIGO"
		uRet := If(lInsert,M->H6I_CODIGO,H6I->H6I_CODIGO)
    Case cField == "H6I_DESORI"
        uRet := If(!lInsert,Posicione("GI6",1,xFilial("GI6")+H6I->H6I_AGEORI,"GI6_DESCRI"),'')
    Case cField == "H6I_DESDES"
        uRet := If(!lInsert,Posicione("GI6",1,xFilial("GI6")+H6I->H6I_AGEDES,"GI6_DESCRI"),'')
    Case cField == "H6J_DESAOR"
        uRet := If(!lInsert,Posicione("GI6",1,xFilial("GI6")+H6J->H6J_AGEORI,"GI6_DESCRI"),'')
    Case cField == "H6J_DESADE"
        uRet := If(!lInsert,Posicione("GI6",1,xFilial("GI6")+H6J->H6J_AGEDES,"GI6_DESCRI"),'')
    Case cField == "H6I_NMPASS"
        uRet := If(!lInsert,Posicione("H6F",1,xFilial("H6F")+H6I->H6I_CODH6F,"H6F_NOMEPS"),'')
    Case cField == "H6J_DESLOR"
        uRet := If(!lInsert,Posicione("GI1",1,xFilial("GI1")+H6J->H6J_LOCORI,"GI1_DESCRI"),'')
    Case cField == "H6J_DESLDE"
        uRet := If(!lInsert,Posicione("GI1",1,xFilial("GI1")+H6J->H6J_LOCDES,"GI1_DESCRI"),'')
    Case cField == "H6J_DESGI2"
        uRet := If(!lInsert,TPNomeLinh(H6J->H6J_LINHA),'')
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
Local dDataHoje := DATE()
Local oView     := FwViewActive()
Local oMdlGrid	:= nil

	Do Case 
        Case cField == "H6I_AGEORI"
            oMdl:SetValue("H6I_DESORI",Posicione("GI6",1,xFilial("GI6")+uVal,"GI6_DESCRI"))
            //Caso alterado limpará os campos e a grid de processo
            oMdl:LoadValue("H6I_CODH6F","")
            oMdl:LoadValue("H6I_NMPASS","")
            oMdlGrid	:= oView:GetModel():GetModel('H6JDETAIL')
            If !(oMdlGrid:IsEmpty())
                oMdlGrid:DelAllLine(.T.)
            EndIf
        Case cField == "H6I_AGEDES"
            oMdl:SetValue("H6I_DESDES",Posicione("GI6",1,xFilial("GI6")+uVal,"GI6_DESCRI"))
            //Caso alterado limpará os campos e a grid de processo
            oMdl:LoadValue("H6I_CODH6F","")
            oMdl:LoadValue("H6I_NMPASS","")
            oMdlGrid	:= oView:GetModel():GetModel('H6JDETAIL')
            If !(oMdlGrid:IsEmpty())
                oMdlGrid:DelAllLine(.T.)
            EndIf
        Case cField == "H6J_AGEORI"
            oMdl:SetValue("H6J_DESAOR",Posicione("GI6",1,xFilial("GI6")+uVal,"GI6_DESCRI"))
        Case cField == "H6J_AGEDES"
            oMdl:SetValue("H6J_DESADE",Posicione("GI6",1,xFilial("GI6")+uVal,"GI6_DESCRI"))
        Case cField == "H6I_CODH6F"
            oMdl:SetValue("H6I_NMPASS",Posicione("H6F",1,xFilial("H6F")+uVal,"H6F_NOMEPS"))
            PreencheH6J(oMdl,uVal)
        Case cField == "H6J_LOCORI"
            oMdl:SetValue("H6J_DESLOR",Posicione("GI1",1,xFilial("GI1")+uVal,"GI1_DESCRI"))
        Case cField == "H6J_LOCDES"
            oMdl:SetValue("H6J_DESLDE",Posicione("GI1",1,xFilial("GI1")+uVal,"GI1_DESCRI"))
        Case cField == "H6J_LINHA"
            oMdl:SetValue("H6J_DESGI2",TPNomeLinh(uVal))
        Case cField == "H6I_DTPROC"
            If dDataHoje > H6I->H6I_DTPROC
                oMdl:SetValue("H6I_STATUS",'2')
            EndIf
        Case cField == "H6I_STATUS"
            If uVal != '1'
                AltStatusH6F(oMdl,uVal)
            EndIf
	EndCase 

Return uVal

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
Local oView      := FwViewActive()
Local oMdlGrid	 := oView:GetModel():GetModel('H6JDETAIL')
Local cMdlId	 := oMdl:GetId()
Local oModel	    := oMdl:GetModel()
Local cMsgSol    := ""
Local cMsgErro   := ""

Local nI            := 0
Local nQtdDeleted   := 0

Local lRestDeleted  := .F.

If cMdlId == "H6JDETAIL"

    For nI := nLine+1 to oMdlGrid:Length()
        
        If (oMdlGrid:IsDeleted(nI))
            nQtdDeleted++
        EndIf    

    Next nI

    lRestDeleted := nQtdDeleted == (oMdlGrid:Length() - nLine)

	IF (cAction == "DELETE") 
        
        If !(oMdlGrid:IsEmpty()) .AND. !lRestDeleted //nLine != oMdlGrid:Length() .And. !oMdlGrid:IsDeleted(oMdlGrid:Length())
            lRet := .F.
            cMsgSol    := "Para modificar o cadastro delete a partir da ultima linha"
            cMsgErro   := "Não é possível excluir sem ser ultima linha"
        EndIf
        
    ELSEIF (cAction == "UNDELETE") 

        If !(oMdlGrid:IsEmpty()) .AND. !lRestDeleted //nLine != oMdlGrid:Length() .And. !oMdlGrid:IsDeleted(oMdlGrid:Length())
            lRet := .F.
            cMsgSol    := "Para modificar o cadastro voltar o registro a partir da ultima linha"
            cMsgErro   := "Não é possível voltar o registro sem ser ultima linha"
        EndIf        

    EndIf    

    
    If !lRet .and. !Empty(cMsgErro)
        oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,)
    Endif

Endif

Return lRet 

/*/{Protheus.doc} PreencheH6J
    efetua o processo de preenchimento da primeira linha do h6j deletando o valor anterior
    @type  Static Function
    @author user
    @since 14/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function PreencheH6J(oMdl,uVal)
Local lRet 			:= .T.
Local cAliasTmp		:= GetNextAlias()
Local oView         := FwViewActive()
Local oModel	    := oMdl:GetModel()
Local oModelH6I     := oModel:GetModel('H6IMASTER')
Local oMdlGrid		:= oView:GetModel():GetModel('H6JDETAIL')
Local cAgeOriH6I    := oModelH6I:GetValue('H6I_AGEORI')
Local cAgeDesH6I    := oModelH6I:GetValue('H6I_AGEDES')
Local cDesOriH6I    := ""
Local cLocOriH6I    := ""
Local cDesLocOri    := ""
Local cDesDesH6I    := ""
Local cLocDesH6I    := ""
Local cDesLocDes    := ""

//Dados da agência de origem
GI6->(DbSetOrder(1))
GI6->(DbSeek(xFilial("GI6")+cAgeOriH6I))
cDesOriH6I    := GI6->GI6_DESCRI
cLocOriH6I    := GI6->GI6_LOCALI
cDesLocOri    := Posicione("GI1",1,xFilial("GI1")+cLocOriH6I,"GI1_DESCRI")

//Dados da agência de destino
GI6->(DbSetOrder(1))
GI6->(DbSeek(xFilial("GI6")+cAgeDesH6I))
cDesDesH6I    := GI6->GI6_DESCRI
cLocDesH6I    := GI6->GI6_LOCALI
cDesLocDes    := Posicione("GI1",1,xFilial("GI1")+cLocDesH6I,"GI1_DESCRI")

BeginSql  Alias cAliasTmp
    SELECT H6F.H6F_CODGI2,H6F.H6F_CODGID,H6F.H6F_DTSLA
    FROM %Table:H6F% H6F
    WHERE H6F.H6F_FILIAL = %xFilial:H6F%
        AND H6F.H6F_CODIGO = %Exp:uVal%
        AND H6F.%NotDel%
EndSql

If !(cAliasTmp)->(Eof()) .AND. !(oMdlGrid:IsEmpty())
    oMdlGrid:DelAllLine(.T.)
EndIf

While !(cAliasTmp)->(Eof())

    If !(oMdlGrid:IsEmpty())
        oMdlGrid:AddLine()
    Endif

    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_SEQ"   })[1],'001')
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_LINHA" })[1],(cAliasTmp)->H6F_CODGI2)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_DESGI2"})[1],TPNomeLinh((cAliasTmp)->H6F_CODGI2))
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_SERVIC"})[1],(cAliasTmp)->H6F_CODGID)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_DTPREV"})[1],STOD((cAliasTmp)->H6F_DTSLA))
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_AGEORI"})[1],cAgeOriH6I)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_DESAOR"})[1],cDesOriH6I)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_LOCORI"})[1],cLocOriH6I)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_DESLOR"})[1],cDesLocOri)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_AGEDES"})[1],cAgeDesH6I)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_DESADE"})[1],cDesDesH6I)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_LOCDES"})[1],cLocDesH6I)
    oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"H6J_DESLDE"})[1],cDesLocDes)
    
    (cAliasTmp)->(dbSkip())

End

oMdlGrid:GoLine(1)

(cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} AltStatusH6F
    Altera status da H6F
    @type  Static Function
    @author user
    @since 17/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AltStatusH6F(oMdl,uVal)

Local oModel	    := oMdl:GetModel()
Local oModelH6I     := oModel:GetModel('H6IMASTER')
Local cCodH6f       := oModelH6I:GetValue("H6I_CODH6F")
Local cStatus       := ""

    H6F->(DbSetOrder(1))
    If H6F->(DbSeek(XFILIAL("H6F") + cCodH6f))
        DO CASE
            Case Alltrim(uVal) $ '2|3'    //2-Em transporte ou 3-Recebido na Agência
                cStatus := '1'  //Aberto
            Case Alltrim(uVal) $ '4|5'    //4-Retirado pelo passageiro ou 5-Doc. Retirada Impresso
                cStatus := '3'  //Resolvido
        ENDCASE

        If !(EMPTY(cStatus))
            RecLock("H6F", .F.)
            H6F->H6F_STATUS := cStatus
            H6F->(MsUnlock())
        EndIf
    EndIf

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldValid

@type Static Function
@author 
@since 27/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
// Local lAlt      := .F.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local oView     := FwViewActive()
Local oMdlGrid	:= oView:GetModel():GetModel('H6JDETAIL')
Local cMsgErro	:= ""
Local cMsgSol	:= ""
// Local nTamGrid  := 0
Local n1        := 0
Local nLine     := oMdlGrid:GetLine()

Local lDeleted := oMdlGrid:IsDeleted(nLine)

Do Case 
    Case Empty(uNewValue)
        lRet := .T.
    Case cField == 'H6I_AGEORI' .or. cField == 'H6I_AGEDES'
        IF !GTPExistCpo('GI6',uNewValue)
            lRet        := .F.
            cMsgErro	:= "Agencia selecionada não encontrada ou se encontra inativa"
            cMsgSol	    := "Selecione uma agencia valida"
        ElseIf cField == 'H6I_AGEORI' .and. !ValidUserAg(oMdl,cField,uNewValue,uOldValue)
            lRet        := .F.    
        Endif
    Case cField == 'H6J_LINHA' .And. !lDeleted 
        IF  !GTPExistCpo('GI2',uNewValue+'2',4)
            lRet        := .F.
            cMsgErro	:= "Linha selecionada não encontrada ou se encontra inativa"
            cMsgSol	    := "Selecione uma Linha valida"
        Endif
    Case cField == 'H6J_SERVIC' .And. !lDeleted
        IF  !GTPExistCpo('GID',uNewValue+'2',4)
            lRet        := .F.
            cMsgErro	:= "Serviço selecionado não encontrado ou se encontra inativo"
            cMsgSol	    := "Selecione um Serviço valida"
        Endif
    Case cField == 'H6J_AGEORI' .or. cField == 'H6J_AGEDES' .And. !lDeleted
        IF  !GTPExistCpo('GI6',uNewValue)
            lRet        := .F.
            cMsgErro	:= "Agencia selecionada não encontrada ou se encontra inativa"
            cMsgSol	    := "Selecione uma agencia valida"
        ElseIf cField == 'H6J_AGEORI'
            
            If !(oMdlGrid:IsEmpty()) .AND. !(EMPTY(uNewValue))
                
                If ( nLine > 1 )
                
                    For n1 := nLine - 1 to 1 step -1
                        
                        If (!oMdlGrid:IsDeleted(n1) )
                            
                            If ( uNewValue != oMdlGrid:GetValue('H6J_AGEDES',n1) .And. !lDeleted )    

                                lRet        := .F.
                                
                                cMsgErro	:= "Agência diferente da agência destino da linha anterior!"
                                cMsgSol	    := "Selecione a agência igual da linha anterior"
                            
                                Exit
                            Else
                                Exit
                            EndiF
                       
                        EndIf                        

                    Next n1

                EndIf

            EndIf
  
        Endif
  
    Case cField == 'H6J_LOCORI' .And. !lDeleted
        
        If !(oMdlGrid:IsEmpty()) .AND. !(EMPTY(uNewValue))
        
            If ( nLine > 1 )
            
                For n1 := nLine - 1 to 1 step -1
                    
                    If (!oMdlGrid:IsDeleted(n1) )
                    
                        If ( uNewValue != oMdlGrid:GetValue('H6J_LOCDES',n1) )
                        
                            lRet        := .F.
                            
                            cMsgErro	:= "Localidade diferente da localidade final da linha anterior!"
                            cMsgSol	    := "Selecione a localidade igual da linha anterior"

                            Exit
                        Else
                            Exit
                        EndIf

                    EndIf

                Next n1

            EndIf            

        EndIf
EndCase 

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

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
Local oModel	:= FwLoadModel('GTPA753')
Local oStrH6I	:= FWFormStruct(2, 'H6I')
Local oStrH6J	:= FWFormStruct(2, 'H6J')

SetViewStruct(oStrH6I,oStrH6J)

oView:SetModel(oModel)

oView:AddField('VIEW_H6I'   ,oStrH6I,'H6IMASTER')
oView:AddGrid('VIEW_H6J'    ,oStrH6J,'H6JDETAIL')

oView:CreateHorizontalBox('UPPER'   , 40)
oView:CreateHorizontalBox('BOTTOM'  , 60)

oView:SetOwnerView('VIEW_H6I','UPPER')
oView:SetOwnerView('VIEW_H6J','BOTTOM')

oView:SetDescription("Movimentações da bagagem")

If H6J->(FIELDPOS("H6J_SEQ")) > 0
    oView:AddIncrementField('VIEW_H6J','H6J_SEQ')
EndIf

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
Static Function SetViewStruct(oStrH6I,oStrH6J)

    oStrH6I:RemoveField('H6I_STATUS')
    oStrH6I:RemoveField('H6I_DTRECE')
    oStrH6I:RemoveField('H6I_HRRECE')
    oStrH6I:RemoveField('H6I_USRECE')
    oStrH6I:RemoveField('H6I_DTRETI')
    oStrH6I:RemoveField('H6I_HRRETI')
    oStrH6I:RemoveField('H6I_USRETI')
    oStrH6J:RemoveField('H6J_CODIGO')

    oStrH6J:setpropert('H6J_SERVIC',MVC_VIEW_LOOKUP , "GIDFIL")
    
Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} PosValid

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function PosValid(oModel)
Local lRet      := .T.
Local cMdlId	:= oModel:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE 
    IF !(valAgServ(oModel,@cMsgErro,@cMsgSol))
        lRet        := .F.
    EndIf
EndIf

If !lRet .and. !Empty(cMsgErro)
    oModel:SetErrorMessage(cMdlId,,cMdlId,,"PosValid",cMsgErro,cMsgSol)
Endif

Return lRet


/*/{Protheus.doc} valAgServ
    (long_description)
    @type  Static Function
    @author henrique.toyada
    @since 27/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function valAgServ(oModel,cMsgErro,cMsgSol)
    
    Local lRet      := .T.
    
    Local oMdlH6I   := oModel:GetModel('H6IMASTER')
    Local oMdlH6J   := oModel:GetModel('H6JDETAIL')
    
    Local cAgEmis   := oMdlH6I:GetValue('H6I_AGEORI')
    Local cAgRece   := oMdlH6I:GetValue('H6I_AGEDES')

    Local nI        := 0
    Local nLastLine := 0
    Local nFirstLine:= 0

    
    //Busca pela primeira linha não excluída
    For nI := 1 to oMdlH6J:Length()
        
        If ( !oMdlH6J:IsDeleted(nI) )
            nFirstLine := nI
            Exit
        EndIf

    Next nI

    If nFirstLine > 0 .And. (oMdlH6J:GetValue('H6J_AGEORI',nFirstLine) != cAgEmis)
        lRet := .F.
        cMsgErro := 'Na aba de serviços o campo de agência origem da primeira linha diferente da agência emissora.'
        cMsgSol := 'Agência origem deve conter o mesmo valor que a emissora.'
    EndIf
    
    //Busca pela última linha não excluída
    For nI := oMdlH6J:Length() to 1 step -1
        
        If ( !oMdlH6J:IsDeleted(nI) )
            nLastLine := nI
            Exit
        EndIf

    Next nI    

    If lRet .AND.( nLastLine > 0 .And. (oMdlH6J:GetValue('H6J_AGEDES',nLastLine) != cAgRece) )
        lRet := .F.
        cMsgErro := 'Na aba de serviços o campo de agência destino da ultima linha difere da agência recebedora'
        cMsgSol := 'Agência destino deve conter o mesmo valor que a recebedora.'
    EndIf

Return lRet

Function GTP753Receb()
    
    Local aInput    := {H6I->H6I_AGEDES,H6I->H6I_DTPROC,H6I->H6I_DTPROC}
    
    GA754SetInput(aInput)
    GTPA754()
    
Return()

Function GTP753Retira()

    Local aInput    := {H6I->H6I_AGEDES,H6I->H6I_DTRECE,H6I->H6I_DTRECE}
    
    GA755SetInput(aInput)
    GTPA755()

Return()

Static Function LinePost(oGrid)

    Local nLine := oGrid:GetLine()
    Local lRet  := .T.
    
    lRet := FieldValid(oGrid,"H6J_AGEORI",oGrid:GetValue("H6J_AGEORI",nLine),oGrid:GetValue("H6J_AGEORI",nLine)) .And.;
            FieldValid(oGrid,"H6J_LOCORI",oGrid:GetValue("H6J_LOCORI",nLine),oGrid:GetValue("H6J_LOCORI",nLine))

Return(lRet)