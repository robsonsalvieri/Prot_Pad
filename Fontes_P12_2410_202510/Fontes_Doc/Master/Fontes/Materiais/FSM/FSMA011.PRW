#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE EM_ATENDIMENTO "01"
#DEFINE EM_ABERTO "02"
#DEFINE EM_PAUSA "03"
#DEFINE ENCERRADO "04"
#DEFINE CANCELADO "05"
#DEFINE EM_DESLOCAMENTO "06"
#DEFINE FIM_DESLOCAMENTO "07"
#DEFINE AGUARDANDO_CLIENTE "08"
#DEFINE ATENDIMENTO_IMPRODUTIVO "09"
#DEFINE ATENDIMENTO_PENDENTE '10'
#DEFINE RETORNO_PENDENCIA '11'
#DEFINE ATRASO '12'

PUBLISH MODEL REST NAME FSMAGENDAS source FSMA011 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

Local oModel	:= Nil
Local oStruJN6	:= FWFormStruct(1,"JN6")
Local oStruJNJ	:= FWFormStruct(1,"JNJ")
Local oStruJNV	:= FWFormStruct(1,"JNV")
Local oStruJNY	:= FWFormStruct(1,"JNY")

Local oCommit :=  FSMA011CMT():New()

oStruJN6:AddField("Codigo do Supervisor"      ,"Codigo"  ,"JN6_SUPERV","C",TamSx3('AA1_CODTEC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStruJN6:AddField("Nome do Supervisor"        ,"Supervisor"    ,"JN6_NOMSUP","C",TamSx3('AA1_NOMTEC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStruJN6:AddField("Chave OS","Chave OS"       ,"JN6_PKOS"  ,"C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)									
oStruJN6:AddField("Nome do Tecnico"           ,"Tecnico"      ,"JN6_NOMTEC","C",TamSx3('AA1_NOMTEC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStruJN6:AddField("Base de Atendimento"       ,"Base"      ,"JN6_BASE","C",TamSx3('AA3_CODPRO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN6:AddField("Chave Agenda"              ,"Chave Agenda","JN6_PKAG"  ,"C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN6:AddField("Nome do Atendente"         ,"Nome do Atendente","JN6_DSCAA1","C",TamSx3('AA1_NOMTEC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStruJNV:AddField("Chave Apontamento"         ,"Chave Apontamento","JNV_PKAPON"  ,"C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJNY:AddField("Chave Laudo"               ,"Chave Laudo","JNY_PKLAUD"  ,"C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)									

oModel := MPFormModel():New('FSMA011', /*bLinePre*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields('JN6MASTER',/*cOwner*/,oStruJN6)
oModel:AddGrid( 'JNJDETAIL', 'JN6MASTER', oStruJNJ)
oModel:AddGrid( 'JNVDETAIL', 'JN6MASTER', oStruJNV)
oModel:AddGrid( 'JNYDETAIL', 'JN6MASTER', oStruJNY)

oModel:getModel('JN6MASTER'):SetDescription("Agendas")
oModel:getModel('JNJDETAIL'):SetDescription("Atendimento")
oModel:getModel('JNVDETAIL'):SetDescription("Apontamento de Horas")
oModel:getModel('JNYDETAIL'):SetDescription("Laudo")

oModel:SetRelation('JNJDETAIL', {{'JNJ_FILIAL', 'xFilial("JNJ")'},;
                                 {'JNJ_CODJN6', 'JN6_CODIGO'}},;
                                JNJ->(IndexKey(2)))

oModel:SetRelation('JNVDETAIL', {{'JNV_FILIAL', 'xFilial("JNV")'},;
                                 {'JNV_CODJN6', 'JN6_CODIGO'}},;
                                 JNV->(IndexKey(2)))

 oModel:SetRelation('JNYDETAIL', {{'JNY_FILIAL', 'xFilial("JNY")'},;
                                 {'JNY_CODJN6', 'JN6_CODIGO'}},;
                                 JNY->(IndexKey(2)))                                

oModel:SetDescription('Agendas dos atendentes')

oModel:InstallEvent(" FSMA011CMT", /*cOwner*/, oCommit)

oStruJN6:SetProperty("JN6_DSCAA1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getNomeAA1("AA1_NOMTEC")'))

oStruJN6:SetProperty( 'JN6_PKOS' , MODEL_FIELD_INIT,;
                    {|| Encode64(JN6->JN6_FILIAL+JN6->JN6_CODJN3)})

oStruJN6:SetProperty( 'JN6_PKAG' , MODEL_FIELD_INIT,;
                    {|| Encode64(JN6->JN6_FILIAL+JN6->JN6_CODIGO)})

oStruJN6:SetProperty("JN6_NOMTEC",MODEL_FIELD_INIT,;
                      FwBuildFeature(STRUCT_FEATURE_INIPAD,'getPosic("AA1_NOMTEC")'))

oStruJN6:SetProperty("JN6_BASE",MODEL_FIELD_INIT,;
                      FwBuildFeature(STRUCT_FEATURE_INIPAD,'getPosicOS("JN3_CODPRO")'))

oStruJN6:SetProperty("JN6_NOMSUP",MODEL_FIELD_INIT,;
                      FwBuildFeature(STRUCT_FEATURE_INIPAD,'GetNomeSup()'))

oStruJNJ:SetProperty("JNJ_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNJ","JNJ_CODIGO")'))

oStruJNV:SetProperty("JNV_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNV","JNV_CODIGO")'))

oStruJNY:SetProperty("JNY_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNY","JNY_CODIGO")'))

oStruJNV:SetProperty( 'JNV_PKAPON' , MODEL_FIELD_INIT,;
                    {|| Encode64(JNV->JNV_FILIAL+JNV->JNV_CODIGO)})

oStruJNY:SetProperty( 'JNY_PKLAUD' , MODEL_FIELD_INIT,;
                    {|| Encode64(JNY->JNY_FILIAL+JNY->JNY_CODIGO)})

oModel:GetModel("JNJDETAIL"):SetOptional(.T.)

oModel:GetModel("JNVDETAIL"):SetOptional(.T.)

oModel:GetModel("JNYDETAIL"):SetOptional(.T.)


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA011CMT()
/*/
//-------------------------------------------------------------------


Class FSMA011CMT From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method BeforeTTS()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA011CMT()
/*/
//-------------------------------------------------------------------


Method New() Class FSMA011CMT
	
Return Nil	


//-------------------------------------------------------------------
/*/{Protheus.doc} getPosic()
 Retorna o conteudo do posicione. Utilizado GetArea e RestArea para 
 nao desposicionar
/*/
//-------------------------------------------------------------------


Function getPosic(cCampo)

Local cRetorno
Local aAreaAA1  := AA1->( GetArea() )
 
    cRetorno := alltrim(Posicione("AA1",1,xFilial("AA1")+JN6->JN6_CODAA1,cCampo))
 
RestArea(aAreaAA1)

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} getPosic()
 Retorna o conteudo do posicione. Utilizado GetArea e RestArea para 
 nao desposicionar
/*/
//-------------------------------------------------------------------


Function getPosicOS(cCampo)

Local cRetorno
Local aAreaJN6  := JN6->( GetArea() )
 
    cRetorno := alltrim(Posicione("JN3",1,xFilial("JN3")+JN6->JN6_CODJN3,cCampo))
 
RestArea(aAreaJN6)

Return cRetorno


//-------------------------------------------------------------------
/*/{Fonte} - 
@author Flavio Martins
@since 07/10/2024
@version 1.0
*/
//-------------------------------------------------------------------

Static Function GerCheckOS(oModel)
Local lRet      := .T.
Local cCodigo   := oModel:GetValue('JN6MASTER','JN6_CODIGO')
Local cCodAtend := oModel:GetValue('JN6MASTER','JN6_CODAA1')
Local aCodRet   := {}
Local aAreaJN3  := JN3->(GetArea())
Local cAtdInt   := ''

JN3->(dbSetOrder(1))

If JN3->(dbSeek(xFilial('JN3')+oModel:GetValue('JN6MASTER','JN6_CODJN3')))
    cAtdInt := JN3->JN3_ATEINT
Endif

If (oModel:GetValue('JN6MASTER','JN6_SITUAC') == '06' .And. cAtdInt == '2') .Or.;
    (oModel:GetValue('JN6MASTER','JN6_SITUAC') == '01' .And. cAtdInt == '1')

    lRet := FSMX002(cCodigo, cCodAtend,, @aCodRet)

Endif

RestArea(aAreaJN3)

Return lRet

//-------------------------------------------------------------------
/*/{Fonte} - FSMStAg
@author Vitor Kwon
@since 26/01/2025
@version 1.0
*/
//-------------------------------------------------------------------


Function FSMStAg()
Local aArea   := GetArea()
Local cOpcoes := ""
 
cOpcoes += "01=EM_ATENDIMENTO 01;"
cOpcoes += "02=EM_ABERTO 02;"
cOpcoes += "03=EM_PAUSA 03;"
cOpcoes += "04=ENCERRADO 04;"
cOpcoes += "05=CANCELADO 05;"
cOpcoes += "06=EM_DESLOCAMENTO 06;"
cOpcoes += "07=FIM_DESLOCAMENTO 07;"
cOpcoes += "08=AGUARDANDO_CLIENTE 08;"
cOpcoes += "09=ATENDIMENTO_IMPRODUTIVO 09;"
cOpcoes += "10=ATENDIMENTO_PENDENTE 10;"
cOpcoes += "11=RETORNO_PENDENCIA 11;"
cOpcoes += "12=ATRASO 12;"

RestArea(aArea)
Return cOpcoes


//-------------------------------------------------------------------
/*/{Fonte} - BeforeTTS
@author Vitor Kwon
@version 1.0
04/02/2025
*/
//-------------------------------------------------------------------


Method BeforeTTS(oModel, cModelId) Class FSMA011CMT

Local lRet := .F.

    lRet := GerCheckOS(oModel)

    oModel:GetModel("JNJDETAIL"):SetValue('JNJ_CODUSU',__cUserId)

    cSequen := FSMA011Seq(oModel:GetModel("JN6MASTER"):GetValue("JN6_CODIGO"),oModel:GetModel("JN6MASTER"):GetValue("JN6_CODAA1"))

    oModel:GetModel("JNJDETAIL"):SetValue('JNJ_SEQUEN',cSequen )

    CheckJN3(oModel)

    CheckJO4(oModel)

Return lRet



//-------------------------------------------------------------------
/*/{Fonte} - CheckJO4
@author Vitor Kwon
@version 1.0
10/06/2025
*/
//-------------------------------------------------------------------

Static Function CheckJO4(oModel)

Local aArea 	:= GetArea()
Local lRet      	:= .F.
Local cAliasTmp		:= GetNextAlias()
Local cQry := ''
local oQry
Local nQuant      := 0
Local nQuantTot   := 0
local nI          := 0
LOCAL nX          := 0
local oModelJN3   := Nil
local oModelJO4   := Nil
local cNumOS      := ''

    cNumOS  := oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3")

    For nI := 1 to 2

        cQry := " SELECT COUNT(*) QUANT "
        cQry += " from "+RetSqlName("JO4")+"  JO4 "
        cQry += " WHERE JO4.D_E_L_E_T_ = ' ' "
        cQry += " AND JO4.JO4_FILIAL  = ? "
        cQry += " AND JO4_CODJN3 = ? " 

        if nI == 2
            cQry += " AND JO4_LIBEST IN ('3','5','6') "
        Endif   

        oQry := FwPreparedStatement():New(cQry)
        oQry:SetString(1, xFilial("JO4"))
        oQry:SetString(2, cNumOS)
        cQry := oQry:GetFixQuery()
        MPSysOpenQuery(cQry, cAliasTmp)

        if nI == 1
            nQuant := (cAliasTmp)->QUANT
        Else
            nQuantTot := (cAliasTmp)->QUANT
        Endif    

    Next 

    If nQuant == nQuantTot

        If JN3->(MsSeek(xFilial("JN3")+oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3")))

            oModelJN3 := FwLoadModel('FSMA008')
            oModelJN3:SetOperation(MODEL_OPERATION_UPDATE)
            oModelJN3:Activate()

            oModelJO4 := oModelJN3:GetModel("JO4DETAIL")

            if oModel:getModel('JN6MASTER'):GetValue("JN6_SITUAC") = "04"
                For nX := 1 To oModelJO4:Length()
                    oModelJO4:GoLine(nX)
                    IF oModelJO4:GetValue("JO4_LIBEST") == '5' .or.  oModelJO4:GetValue("JO4_LIBEST") == '3' 
                        oModelJO4:setValue('JO4_STATUS', '2')  
                    Endif     
                Next nX	 
            Endif      

            If oModelJN3:VldData()            
                    oModelJN3:CommitData()  
            Endif

            oModelJN3:DeActivate()

        Endif    

    Endif

(cAliasTmp)->(dbCloseArea())

oQry:Destroy()

FwFreeObj( oQry )

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Fonte} - CheckJN3
@author Vitor Kwon
@version 1.0
04/02/2025
*/
//-------------------------------------------------------------------

Static function CheckJN3(oModel)

local cStatus   := ''
local lStaInic  := .F.
lOCAL cDtEnce := ''
lOCAL cHrEnce := ''
LOCAL lStaPaus := .F.
       

If JN3->(MsSeek(xFilial("JN3")+oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3")))

        cStatus := oModel:getModel('JN6MASTER'):GetValue('JN6_SITUAC')

             If cStatus == EM_DESLOCAMENTO
                cStatus :=   EM_ATENDIMENTO
            Elseif cStatus == ENCERRADO
            if isInCallStack('PUT_ENCERRAMENTO')
                lStaInic := FSMASJN3(oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3"),cStatus) 
            Else    
                lStaInic := FSMAStOS(oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3")) 
            Endif    
                IF lStaInic
                    cStatus := ENCERRADO
                Else    
                    cStatus := EM_ATENDIMENTO
                Endif 
            ElseIf cStatus == EM_PAUSA 
               lStaPaus := FSMAStOS(oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3"),cStatus) 
               if lStaPaus
                cStatus := EM_PAUSA 
               Else 
                cStatus := EM_ATENDIMENTO 
               Endif      
            ElseIf cStatus == EM_ATENDIMENTO 
               lStaPaus := FSMAStOS(oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3"),cStatus) 
               if lStaPaus
                cStatus :=  EM_PAUSA
               Else 
                cStatus := EM_ATENDIMENTO                
               Endif 
            Elseif cStatus == ATENDIMENTO_IMPRODUTIVO   
                if isInCallStack('PUT_VISITAIMPRODUTIVA')
                    lStaInic := FSMASJN3(oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3"),cStatus) 
                Else    
                    lStaInic := FSMAStOS(oModel:getModel('JN6MASTER'):GetValue("JN6_CODJN3")) 
                Endif    
                    IF lStaInic
                        cStatus := ENCERRADO
                    Else    
                        cStatus := EM_ATENDIMENTO
                    Endif          
            EndIf    



           If lStaInic 
               cStatus := ENCERRADO
               cDtEnce := date()
               cHrEnce := time()
           Endif


            if cStatus $ '01|02|03|04' //01 - EM_ATENDIMMENTO,03=EM_PAUSA ,05=ENCERRADO

                if !Empty(cDtEnce) 
                    JN3->(RecLock("JN3",.F.)) 
                        JN3->JN3_SITUAC := cStatus
                        JN3->JN3_DTENCE := cDtEnce
                        JN3->JN3_HRENCE := cHrEnce
                    JN3->(MsUnLock())
                Else    
                    JN3->(RecLock("JN3",.F.)) 
                        JN3->JN3_SITUAC := cStatus
                    JN3->(MsUnLock())       
                Endif
            Endif    
   

Endif       

Return

//-------------------------------------------------------------------
/*/{Fonte} - 
@author Vitor Kwon
@since 12/09/2024
@Return - Verifica a situa  o da OS
@version 1.0
*/
//-------------------------------------------------------------------
Static Function FSMAStOS(cNumOS, cStatus)

Local aArea 	:= GetArea()
Local lRet      	:= .F.
Local cAliasTmp		:= GetNextAlias()
Local cQry := ''
local oQry
Local nQuant      := 0
Local nQuantTot   := 0
local nI          := 0

    For nI := 1 to 2

        cQry := " SELECT COUNT(*) QUANT "
        cQry += " from "+RetSqlName("JN6")+"  JN6 "
        cQry += " WHERE JN6.D_E_L_E_T_ = ' ' "
        cQry += " AND JN6.JN6_FILIAL  = ? "
        cQry += " AND JN6_CODJN3 = ? " 

        if nI == 2
                if cStatus == '03'
                    cQry += " AND JN6_SITUAC IN ('03','01') "
                Elseif cStatus == '01
                    cQry += " AND JN6_SITUAC IN ('01') " 
                Else
                    cQry += " AND JN6_SITUAC IN ('01','04','09') " 
                Endif
        Endif   

        oQry := FwPreparedStatement():New(cQry)
        oQry:SetString(1, xFilial("JN6"))
        oQry:SetString(2, cNumOS)
        cQry := oQry:GetFixQuery()
        MPSysOpenQuery(cQry, cAliasTmp)

        if nI == 1
            nQuant := (cAliasTmp)->QUANT
        Else
            nQuantTot := (cAliasTmp)->QUANT
        Endif    

    Next 

    If nQuant == nQuantTot
      lRet := .T.
    Endif

(cAliasTmp)->(dbCloseArea())

oQry:Destroy()

FwFreeObj( oQry )

RestArea(aArea)

Return lRet






//-------------------------------------------------------------------
/*/{Fonte} - 
@author Vitor Kwon
@since 12/09/2024
@Return - Sequencial do campo JNJ_SEQUEN para controle
@version 1.0
*/
//-------------------------------------------------------------------
Static Function FSMA011Seq(cNumOS,cCodAtd)

Local cAliasTmp		:= GetNextAlias()
Local cQry := ''
local oQry
Local cSequen := ""

    cQry := " SELECT MAX(JNJ_SEQUEN) SEQUENCIA"
    cQry += " from "+RetSqlName("JNJ")+"  JNJ "
    cQry += " WHERE JNJ.D_E_L_E_T_ = ' ' "
    cQry += " AND JNJ.JNJ_FILIAL  = ? "
    cQry += " AND JNJ_CODJN6 =  ? " 
    cQry += " AND JNJ_CODATD =  ? " 


    oQry := FwPreparedStatement():New(cQry)
    oQry:SetString(1, xFilial("JNJ"))
    oQry:SetString(2, cNumOS)
    oQry:SetString(3, cCodAtd)
    cQry := oQry:GetFixQuery()
    MPSysOpenQuery(cQry, cAliasTmp)

    if Empty((cAliasTmp)->SEQUENCIA) 
        cSequen := '001'
    Else
        cSequen := val((cAliasTmp)->SEQUENCIA)
        cSequen := cSequen + 1
        cSequen := StrZero(cSequen, 3)
    Endif

(cAliasTmp)->(dbCloseArea())

oQry:Destroy()

FwFreeObj( oQry )

Return cSequen


//-------------------------------------------------------------------
/*/{Protheus.doc} getPosiAA1

@author	Vitor Kwon
@since	22/07/2024
/*/
//-------------------------------------------------------------------

Function getNomeAA1(cCampo)

Local cRetorno
Local aAreaAA1  := AA1->( GetArea() )
 
    cRetorno := Posicione("AA1",1,xFilial("AA1")+JN6->JN6_CODAA1,cCampo)
 
RestArea(aAreaAA1)


Return cRetorno



//-------------------------------------------------------------------
/*/{Fonte} - 
@author Vitor Kwon
@since 12/09/2024
@Return - Verifica a situa  o da OS
@version 1.0
*/
//-------------------------------------------------------------------
Static Function FSMASJN3(cNumOS,cStatus)

Local aArea 	:= GetArea()
Local lRet      	:= .F.
Local cAliasTmp		:= GetNextAlias()
Local cQry := ''
local oQry
Local nQuant      := 0
local nQuantTot := 0
Local nI          := 0

  For nI := 1 to 2

        cQry := " SELECT COUNT(*) QUANT "
        cQry += " from "+RetSqlName("JN6")+"  JN6 "
        cQry += " WHERE JN6.D_E_L_E_T_ = ' ' "
        cQry += " AND JN6.JN6_FILIAL  = ? "
        cQry += " AND JN6_CODJN3 = ? "

        if nI == 2
            if cStatus == '04'
                cQry += " AND JN6_SITUAC not IN ('04') " 
            ElseIf cStatus == '09' 
            cQry += " AND JN6_SITUAC not IN ('09') "   
            Endif
        Endif   
       
        oQry := FwPreparedStatement():New(cQry)
        oQry:SetString(1, xFilial("JN6"))
        oQry:SetString(2, cNumOS)
        cQry := oQry:GetFixQuery()
        MPSysOpenQuery(cQry, cAliasTmp)

        if nI == 1
            nQuant := (cAliasTmp)->QUANT
        Else
            nQuantTot := (cAliasTmp)->QUANT + 1
        Endif   

        If (nQuant == nQuantTot) .OR. (nQuant != nQuantTot .aND. nQuant == 1 )
            lRet := .T.
        Endif

 Next       


(cAliasTmp)->(dbCloseArea())

oQry:Destroy()

FwFreeObj( oQry )

RestArea(aArea)

Return lRet

Function getNomeSup()
Local cCodSuper  := ''
Local cNomeSuper := ''
Local aAreaAA1  := AA1->( GetArea() )
 
    cCodSuper  := Posicione("AA1",1,xFilial("AA1")+JN6->JN6_CODAA1,'AA1_CODSUP')
    cNomeSuper := Posicione("AA1",1,xFilial("AA1")+cCodSuper,'AA1_NOMTEC')
 
RestArea(aAreaAA1)

Return cNomeSuper
