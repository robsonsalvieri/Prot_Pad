#INCLUDE "TOTVS.CH"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TOPConn.ch"
//#INCLUDE "GTPA320.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA320
'Cadastro de Reclamacões'
@type Function
@author Yuri Porto
@since 26/08/2024
@version 1.0
@return nil, retorna nulo
/*/
//------------------------------------------------------------------------------
Function GTPA320()

Local oBrowse := Nil

    If !GU320VldDic()
        Return()
    ENDIF
    
    If ( !FindFunction("GTPHASACCESS") .Or.; 
        ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        oBrowse       := FWMBrowse():New()
        oBrowse:SetAlias('H7T')
        oBrowse:SetMenuDef('GTPA320')
        oBrowse:SetDescription('Cadastro de Reclamações')//'Cadastro de Reclamações'
                
        oBrowse:AddLegend('H7T->H7T_STATUS=="A"',  "RED",   "Aberta")       //"Aberta"
        oBrowse:AddLegend('H7T->H7T_STATUS=="E"',  "GREEN", "Encerrada")    //"Encerrada"

        oBrowse:Activate()
        oBrowse:Destroy()

        GTPDestroy(oBrowse)

    EndIf

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author Yuri Porto
@since 26/08/2024
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPA320'      OPERATION 2	    ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.GTPA320'      OPERATION 3		ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE "Alterar"    ACTION 'GU320VldOp(4)'        OPERATION 4		ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE "Excluir"    ACTION 'GU320VldOp(5)'        OPERATION 5		ACCESS 0 // "Excluir"
    ADD OPTION aRotina TITLE "Reabrir"    ACTION 'GT3200STATUS("R")'    OPERATION 4		ACCESS 0 // "Reabrir"
    ADD OPTION aRotina TITLE "Encerrar"   ACTION 'GT3200STATUS("E")'    OPERATION 4		ACCESS 0 // "Reabrir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author Yuri Porto
@since 26/08/2024
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	    := nil
Local oStrH7T	    := FWFormStruct(1,'H7T')
Local bFieldTrig    := {|oModel,cField,uVal| FieldTrigger(oModel,cField,uVal)}
Local bCommit	    := {|oModel|GTP302Grv(oModel)}

    //GATILHOS
    oStrH7T:AddTrigger("H7T_TPOCOR" , "H7T_TPOCOR"   , {||.T.}, bFieldTrig)
    oStrH7T:AddTrigger('H7T_VIAGEM'	,'H7T_VIAGEM'	 , {||.T.}, bFieldTrig)
    oStrH7T:AddTrigger('H7T_LOCORI' ,'H7T_LOCORI'    , {||.T.}, bFieldTrig)
    oStrH7T:AddTrigger('H7T_LOCDES'	,'H7T_LOCDES'	 , {||.T.}, bFieldTrig)
    oStrH7T:AddTrigger('H7T_CODVEI'	,'H7T_CODVEI'	 , {||.T.}, bFieldTrig)
    oStrH7T:AddTrigger('H7T_COLCOD'	,'H7T_COLCOD'	 , {||.T.}, bFieldTrig)
    
    oModel := MPFormModel():New('GTPA320', /*bPreValidacao*/,/*bPosValid*/, bCommit, /*bCancel*/ )
    oModel:AddFields('H7TMASTER',/*cOwner*/,oStrH7T)
    oModel:SetDescription('Cadastro de Reclamações') //'Cadastro de Reclamações'
    oModel:GetModel('H7TMASTER'):SetDescription('Cadastro de Reclamações') //'Cadastro de Reclamações'
    oModel:SetPrimaryKey({'H7T_FILIAL','H7T_CODIGO'})

Return oModel




//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Yuri Porto
@since 26/08/2024
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA320')
Local oStrH7T	:= FWFormStruct(2, 'H7T')

    oStrH7T:removeField("H7T_STATUS")
    oStrH7T:removeField("H7T_USRPRT")

    oView:SetModel(oModel)
    oView:AddField('VIEW_H7T' ,oStrH7T,'H7TMASTER')
    oView:CreateHorizontalBox('TELA', 100)
    oView:SetOwnerView('VIEW_H7T','TELA')
    oView:SetDescription('Cadastro de Reclamações') //'Cadastro de Reclamações'


Return oView





/*/{Protheus.doc} GU320VldDic
(long_description)
@type  Static Function
@author Yuri Porto
@since 26/08/2024
/*/
Static Function GU320VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'G6Q'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'G6Q_TIPOOC','G6Q_SLAOCO'}

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

If Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet




/*/
{Protheus.doc} FieldTrigger()
@author Yuri Porto
@since 26/08/2024
@version 1.0
@return uVal
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local uRet
Local oModel	:= oMdl:GetModel()

    Do Case
        Case cField == 'H7T_TPOCOR'
            uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("H7TMASTER"):GetValue("H7T_TPOCOR"),"G6Q_DESCRI")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_NMTPOC', uRet)
            
            If oModel:GetOperation()==3 
                oModel:GetModel("H7TMASTER"):SetValue('H7T_DATA',   dDataBase)
                oModel:GetModel("H7TMASTER"):SetValue('H7T_HORA',   Time())
            EndIf

            //Ajusta SLA
            If FwAlertYesNo("Deseja recalcular o prazo final com o novo SLA ?", "Atenção") // "Deseja recalcular o prazo final com o novo SLA ?","Atenção"
                uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("H7TMASTER"):GetValue("H7T_TPOCOR"),"G6Q_TIPOOC")
                iF ValType(uRet) =="C" .And. uRet$"2|3"
                    uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("H7TMASTER"):GetValue("H7T_TPOCOR"),"G6Q_SLAOCO")
                    oModel:GetModel("H7TMASTER"):SetValue('H7T_SLAOCO', uRet)
                    iF ValType(uRet) =="N" .And. uRet>0
                        oModel:GetModel("H7TMASTER"):SetValue('H7T_SLAFIM', DaySum(dDatabase, uRet)) 
                    EndIf
                EndIf
            EndIf

        Case cField == 'H7T_VIAGEM'
            uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("H7TMASTER"):GetValue("H7T_VIAGEM"),"GYN_DTINI")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_DTVIAG',uRet)
            uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("H7TMASTER"):GetValue("H7T_VIAGEM"),"GYN_LOCORI")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_LOCORI',uRet)
            uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("H7TMASTER"):GetValue("H7T_VIAGEM"),"GYN_LOCDES")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_LOCDES',uRet)


        Case cField == 'H7T_LOCORI'
            uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oModel:GetModel("H7TMASTER"):GetValue("H7T_LOCORI"),"GI1_DESCRI")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_NMLOCA',uRet)
            
        Case cField == 'H7T_LOCDES'
            uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oModel:GetModel("H7TMASTER"):GetValue("H7T_LOCDES"),"GI1_DESCRI")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_NMDEST',uRet)

        Case cField == 'H7T_CODVEI'
            uRet := POSICIONE("ST9",1,XFILIAL("ST9") + oModel:GetModel("H7TMASTER"):GetValue("H7T_CODVEI"),"T9_NOME")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_DCODVE',uRet)
            uRet := POSICIONE("ST9",1,XFILIAL("ST9") + oModel:GetModel("H7TMASTER"):GetValue("H7T_CODVEI"),"T9_PLACA")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_EPPLAC',uRet)

        Case cField == "H7T_COLCOD"
            uRet := POSICIONE("GYG",1,XFILIAL("GYG") + oModel:GetModel("H7TMASTER"):GetValue("H7T_COLCOD"),"GYG_NOME")
            oModel:GetModel("H7TMASTER"):SetValue('H7T_COLNOM',uRet)

    EndCase


Return uVal





/*/{Protheus.doc} GT3200STATUS
//TODO Descrição auto-gerada.
@author Yuri Porto
@since 28/08/2024
@version 1.0
@return ${return}, ${return_description}
@param cStatus, numeric, descricao
@type function
/*/
Function GT3200STATUS(cStatus)
Local oModel  := FwLoadModel("GTPA320")
Local oMdl    := oModel:GetModel("H7TMASTER")
Local lRet := .T.

Default cStatus := ""

    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    IF oModel:Activate()
        Begin Transaction
        If cStatus == "R"
            IF FwAlertYesNo("Deseja reabrir a reclamação ? ", "Atenção") // "Deseja reabrir a reclamação ? ","Atenção"
                cStatus := 'A'
            EndIf
        Elseif cStatus$'A|E'
            cStatus :=cStatus
        EndIf

        oMdl:SetValue("H7T_USRPRT", RetCodUsr()) 
        oMdl:SetValue("H7T_STATUS",cStatus)                    
        
        If oModel:VldData()
            lRet := oModel:CommitData()
        EndIf

        lRet := IIF( (lRet),.T.,DisarmTransaction())
        
        oModel:DeActivate()
        End Transaction 
    EndIf

Return lRet




/*/{Protheus.doc} GU320VldOp
(long_description)
@type Function
@author YURI pORTO
@since 28/08/2024
@version 1.0@param , param_type, param_descr
/*/
Function GU320VldOp(nOperation)
Local lRet      := .T.


    If nOperation == MODEL_OPERATION_UPDATE

        If (H7T->H7T_STATUS =='E')
            lRet := .F.
            FwAlertInfo("Status atual não permite a alteração") // "Status atual do caixa não permite a alteração"
        Endif

    ElseIf nOperation == MODEL_OPERATION_DELETE

        If (H7T->H7T_STATUS == 'E')
            lRet := .F.
            FwAlertInfo("Status atual  não permite a exclusão") // "Status atual do caixa não permite a exclusão"
        Endif

    Endif

    If lRet 
        FwExecView("Cadastro de Reclamações", "VIEWDEF.GTPA320", nOperation,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/) // "Cadastro de Reclamações"
    Endif

Return 






//------------------------------------------------------------------------------
/* /{Protheus.doc} GTP302Grv
@type Static Function
@author Yuri Porto
@since 02/09/2024
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function GTP302Grv(oModel)
Local lRet	        := .T.
Local oDadosEmail   := Nil
Local aEmail        := {}
Local cMail         := Lower(AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_CLIMAI")))

    
    IF oModel:GetOperation() == 3 .And. !FwIsInCallStack('GT3200STATUS')
        oModel:GetModel("H7TMASTER"):SetValue("H7T_STATUS", "A")        
        oModel:GetModel("H7TMASTER"):SetValue("H7T_USRPRT", RetCodUsr())
    EndIf

    If oModel:VldData()
        Begin Transaction
        lRet := FwFormCommit(oModel)
        lRet := IIF(lRet,.T. ,DisarmTransaction() )
        End Transaction 
    EndIF
        
    
    If lRet .And. (oModel:GetOperation() = 3 .or. oModel:GetOperation() = 4) .And. !(FwIsInCallStack('GT3200STATUS')) .And. IsEmail(cMail) 
    
        oDadosEmail := JsonObject():new()
        oDadosEmail["H7T_CODIGO"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_CODIGO"))
        oDadosEmail["H7T_NMTPOC"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_NMTPOC"))
        oDadosEmail["H7T_DATA"]        := oModel:GetModel("H7TMASTER"):GetValue("H7T_DATA")
        oDadosEmail["H7T_CLINOM"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_CLINOM"))
        oDadosEmail["H7T_SLAFIM"]      := oModel:GetModel("H7TMASTER"):GetValue("H7T_SLAFIM")
        oDadosEmail["H7T_DTVIAG"]      := oModel:GetModel("H7TMASTER"):GetValue("H7T_DTVIAG")
        oDadosEmail["H7T_VIAGEM"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_VIAGEM"))
        oDadosEmail["H7T_NMLOCA"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_NMLOCA"))
        oDadosEmail["H7T_NMDEST"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_NMDEST"))
        oDadosEmail["H7T_DCODVE"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_DCODVE"))
        oDadosEmail["H7T_EPPLAC"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_EPPLAC"))
        oDadosEmail["H7T_MEMO"]        := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_MEMO"  ))
        oDadosEmail["H7T_COLNOM"]      := AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_COLNOM"))
        oDadosEmail["H7T_CLIMAI"]      := Lower(AllTrim(oModel:GetModel("H7TMASTER"):GetValue("H7T_CLIMAI")))

        aAdd(aEmail,oDadosEmail)
        
        SendMail(aEmail)
    EndIf

return lRet













/* /{Protheus.doc} SendMail(aEmail)
@type Static Function
@author Yuri Porto
@since 02/09/2024
@version 1.0
/*/
Static Function SendMail(aEmail)
Local n1        := 0
Local cFrom     := "noreplay@totvs.com.br"
Local cTo       := ""
Local cCc       := ""
Local cBcc      := ""
Local cSubject  := "Controle de reclamações"
Local cBody     := ""
Local aAnexos   := {}
Local aRet      := {}
Local lRet      := .T.

    If FwAlertYesNo("Deseja enviar a interação via e-mail ao passageiro ?","Atenção!!")  //"Deseja enviar a interação ao passageiro ?","Atenção!!"
        If GxVldParEmail()  
            For n1 := 1 to Len(aEmail)
                cTo     := aEmail[n1]["H7T_CLIMAI"]
                cBody   := GetBodyEmail(aEmail[n1])
                aRet    := GTPXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, aAnexos)
                lRet    := IIf(!aRet[1],FwAlertHelp("Erro ao enviar o e-mail",aRet[2],"Atenção!!"),.T. ) //"Parâmetros de email não cadastrados","Informe-os para realizar o envio de email","Atenção!!"
            Next
        Else
            FwAlertHelp("Parâmetros de email não cadastrados","Informe-os para realizar o envio de email","Atenção!!")//"Parâmetros de email não cadastrados","Informe-os para realizar o envio de email","Atenção!!"
        Endif
    EndIf

Return lRet



/*/
@type Static Function
@author Yuri Porto
@since 02/09/2024
@version 1.0
/*/
Static Function GetBodyEmail(oDadosEmail)
Local cBody := ""

cBody += '<!doctype html>'
cBody += '<html lang="BR">'
cBody += '<body>'

cBody += "<br>"
cBody += "<p>"  
cBody += "<center>"
cBody += "<H1><b>" +"Controle de reclamações"+"</b></H1>"
cBody += "</center>"
cBody += "<br>"

cBody += "<br>"
cBody += "<b>" +"Notificação de interação na reclamação :         "+oDadosEmail["H7T_CODIGO"]+" - "+oDadosEmail["H7T_NMTPOC"]+"</b>"
cBody += "<br>"

cBody += "<br>"
cBody += "<b>" +"Data de abertura:                                "+DTOC(oDadosEmail["H7T_DATA"])+"</b>"
cBody += "<br>"


cBody += "<br>"
cBody += "<b>" +"SLA previsto:                                    "+DTOC(oDadosEmail["H7T_SLAFIM"])+"</b>"
cBody += "</p>"
cBody += "<br>"



//****************************************************************************
//Dados do passageiro
cBody += "<hr/>"
cBody += "<br>"
cBody += "<p>"  
cBody += "</H2><b>" +"Dados do passageiro:"+"</b></H2>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Passageiro:                             "+ oDadosEmail["H7T_CLINOM"]+"</b>"
cBody += "</p>"  
cBody += "<br>"

//****************************************************************************************************
//Dados Viagem
cBody += "<hr/>"
cBody += "<br>"
cBody += "<p>"  
cBody += "</H2><b>" +"Dados Viagem"+"</b></H2>"
cBody += "</p>"


cBody += "<p>"  
cBody += "<b>" +"Data:                                      "+ DTOC(oDadosEmail["H7T_DTVIAG"])+"</b>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Viagem:                                    "+ oDadosEmail["H7T_VIAGEM"]+"</b>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Origem:                                    "+ oDadosEmail["H7T_NMLOCA"]+"</b>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Destino:                                   "+ oDadosEmail["H7T_NMDEST"]+"</b>"
cBody += "</p>"
cBody += "<br>"

//****************************************************************************************************
//Dados Veiculo
cBody += "<hr/>"
cBody += "<br>"
cBody += "<p>"  
cBody += "</H2><b>" +"Dados Veiculo:"+"</b></H2>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Veiculo:                                       "+ oDadosEmail["H7T_DCODVE"]+"</b>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Placa:                                          "+ oDadosEmail["H7T_EPPLAC"]+"</b>"
cBody += "</p>"
cBody += "<br>"

//****************************************************************************************************
//Dados Colaborador
cBody += "<hr/>"
cBody += "<br>"
cBody += "<p>"  
cBody += "</H2><b>" +"Dados Colaborador:"+"</b></H2>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Colaborador:                                       "+ oDadosEmail["H7T_COLNOM"]+"</b>"
cBody += "</p>"
cBody += "<br>"

//****************************************************************************************************
//Descrição da reclamação
cBody += "<hr/>"
cBody += "<br>"
cBody += "<p>"  
cBody += "</H2><b>" +"Descrição da reclamação:"+"</b></H2>"
cBody += "</p>"

cBody += "<p>"  
cBody += "<b>" +"Descrição:                                       "+ oDadosEmail["H7T_MEMO"]+"</b>"
cBody += "</p>"
cBody += "<br>"
//******************************************************************************************************

cBody += '</body>'
cBody += '</html>'

Return cBody
