#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE EM_ABERTO "01"
#DEFINE ANALISE "02"
#DEFINE APROVADO "03"
#DEFINE REPROVADO "04"
#DEFINE CORRECAO "05"
#DEFINE ARQUIVADO "06"
#DEFINE AUTOMATICO "07"
#DEFINE ISENTO "08"

#DEFINE ANALISE "09"

#DEFINE PARCIAL "10"

#DEFINE TOTAL "11"



PUBLISH MODEL REST NAME FSMPREREQUISICAO source FSMA030 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil
Local oStruJO3	:= FWFormStruct(1,"JO3")
Local oModelEvent :=  FSMA030Event():New()

oStruJO3:AddField("Valor.Produto","Valor.Produto"      ,"JO3_PRCVEN","C",TamSx3('B1_PRV1')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	

oModel := MPFormModel():New('FSMA030', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)

oModel:InstallEvent(" FSMA030Event", /*cOwner*/, oModelEvent)

oModel:AddFields('JO3MASTER',/*cOwner*/,oStruJO3)

oModel:getModel('JO3MASTER'):SetDescription("Pré-requisção")
                        
oModel:SetDescription("Pré-requisção")

oStruJO3:SetProperty("JO3_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JO3","JO3_CODIGO")'))

oStruJO3:SetProperty("JO3_PRCVEN",MODEL_FIELD_INIT,;
                    FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JO3->JO3_CODPRO,"B1_PRV1"),"")'))


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA030Event()
/*/
//-------------------------------------------------------------------


Class FSMA030Event From FwModelEvent 
	Method New() CONSTRUCTOR
	Method ModelPosVld()
EndClass

Method New() Class FSMA030Event
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} atdPreReq()
 Retorna o conteudo do posicione. Utilizado GetArea e RestArea para 
 nao desposicionar
/*/
//-------------------------------------------------------------------


Function atdPreReq(cCampo)

Local cRetorno
Local aAreaAA1  := AA1->( GetArea() )
 
    cRetorno := alltrim(Posicione("AA1",4,xFilial("AA1")+__cUserId,cCampo))
 
RestArea(aAreaAA1)

Return cRetorno


//-------------------------------------------------------------------
/*/{Fonte} - ModelPosVld
@author Vitor Kwon
@version 1.0
04/02/2025
*/
//-------------------------------------------------------------------

Method ModelPosVld(oModel, cModelId) Class FSMA030Event

Local lRet      := .T.
Local cMsgErro  := ''

        lRet := InsertSCP(oModel, @cMsgErro)

        If !(lRet)
           	oModel:SetErrorMessage('JO3MASTER', ,'JO3MASTER',, "InsertSCP", cMsgErro, '') 
        Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At890INum

Função de inicializador padrão de auto numeração com confirmação de gravação

@author Vitor Kwon
@since 19/04/22
/*/
//-------------------------------------------------------------------

Static Function FSM30INum(cAlias, cCampo, nQualndex)

Local aArea     := GetArea()
Local aAreaTmp  := (cAlias)->(GetArea())
Local cProxNum  := ""

Default nQualndex := 1
         
cProxNum  := GetSx8Num(cAlias, cCampo,, nQualndex)

dbSelectArea(cAlias)
dbSetOrder(nQualndex)
  
While dbSeek( xFilial( cAlias ) + cProxNum )
    If ( __lSx8 )
        ConfirmSX8()
    EndIf
    cProxNum := GetSx8Num(cAlias, cCampo,, nQualndex)
End

RestArea(aAreaTmp)
RestArea(aArea)

Return(cProxNum)



//-------------------------------------------------------------------
/*/{Protheus.doc} InsertSCP

Grava a requisicao no estoque

@author Vitor Kwon
@since 03/04/2025
/*/
//-------------------------------------------------------------------

Static Function InsertSCP(oModel, cMsgErro)

Local lRet      := .T.
Local aCab := {}
Local aItens := {}
Local aAreaJN3  := JN3->( GetArea() )
Local aAreaJN4  := JN4->( GetArea() )
Local aAreaJN5  := JN5->( GetArea() )
Local aAreaJN7  := JN7->( GetArea() )
Local aAreaJN9  := JN9->( GetArea() )
Local aAreaJNA  := JNA->( GetArea() )

Private lMsErroAuto := .F. 

if !Empty(oModel:GetModel("JO3MASTER"):GetValue('JO3_CODORI'))

    begin Transaction

        if oModel:getOperation() == MODEL_OPERATION_UPDATE

            if JO3->JO3_STATUS == CORRECAO

                 cItem   :=   JO3->JO3_ITEM
                 cOrigem :=   JO3->JO3_ORIGEM 
                 cCodori :=   JO3->JO3_CODORI 
                 cCodPro :=   JO3->JO3_CODPRO 
                 cLocal  :=   JO3->JO3_LOCAL 
                 cQuanti :=   JO3->JO3_QUANTI  
                 cStatus :=   JO3->JO3_STATUS 
                 cCodUSR :=   JO3->JO3_CODUSR 
                 cEmissa :=   JO3->JO3_EMISSA 
                 cAlias  :=   JO3->JO3_ALIAS 
                 cCodAA1 :=   JO3->JO3_CODAA1 
                 cCodJN7 :=   JO3->JO3_CODJN7
                 cCodSer :=   JO3->JO3_CODJN1 
                 cServi  :=   JO3->JO3_CODJN4
                 cCodJO4 :=   JO3->JO3_CODJO4 

                JO3->(Reclock("JO3",.t.))
                    JO3->JO3_FILIAL :=   xFilial("JO3")
                    JO3->JO3_CODIGO := FSM30INum("JO3",'JO3_CODIGO',1)
                    JO3->JO3_ITEM   := cItem
                    JO3->JO3_ORIGEM := cOrigem
                    JO3->JO3_CODORI := cCodori
                    JO3->JO3_QUANTI := oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                    JO3->JO3_CODPRO := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO')
                    JO3->JO3_LOCAL  := cLocal
                    JO3->JO3_STATUS := oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS')
                    JO3->JO3_CODUSR := cCodUSR
                    JO3->JO3_EMISSA := cEmissa
                    JO3->JO3_ALIAS  := cAlias
                    JO3->JO3_CODAA1 := cCodAA1
                    JO3->JO3_CODJN7 := cCodJN7
                    JO3->JO3_CODJN1 := cCodSer
                    JO3->JO3_CODJN4 := cServi
                    JO3->JO3_CODJO4 := cCodJO4
                JO3->(msUnLock()) 

                JO4->(DbSetOrder(1))

                IF JO4->(MsSeek(xFilial("JO4")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJO4')))
                    JO4->(Reclock("JO4",.f.))
                        JO4->JO4_CODPRO = oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO')
                        JO4->JO4_QTDPRO = oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                    JO4->(msUnLock()) 
                EndIF 

                oModel:GetModel("JO3MASTER"):SetValue('JO3_STATUS',ARQUIVADO)  
                oModel:GetModel("JO3MASTER"):SetValue('JO3_QUANTI',cQuanti)  

            Elseif JO3->JO3_STATUS == EM_ABERTO

                JO4->(DbSetOrder(1))

                IF JO4->(MsSeek(xFilial("JO4")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJO4')))
                    JO4->(Reclock("JO4",.f.))
                        JO4->JO4_CODPRO = oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO')
                        JO4->JO4_QTDPRO = oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                    JO4->(msUnLock()) 
                EndIF  

            Endif     
    
            if oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS')  == APROVADO
                oModel:GetModel('JO3MASTER'):setValue('JO3_STATUS', APROVADO)  

                DbSelectArea("SCP")
                SCP->(DbSetorder(1))

                Aadd( aCab,{ "CP_EMISSAO",oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})

                Aadd(aItens,{})

                Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,oModel:GetModel("JO3MASTER"):GetValue('JO3_ITEM')  ,nil})
                Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO'),nil})
                Aadd(aItens[Len(aItens)],{"CP_UM"      ,oModel:GetModel("JO3MASTER"):GetValue('JO3_UNIMED'),nil})
                Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_NUMOS"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODIGO'),nil})              
                Aadd(aItens[Len(aItens)],{"CP_SEGUM"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_SEGUM'),nil})             
                Aadd(aItens[Len(aItens)],{"CP_QTSEGUM" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QTDSUM'),nil})                    
                Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_LOCAL') ,nil})  


                MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 3)

                If lMsErroAuto
                        disarmTransaction()
                Else
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_NUMSCP',SCP->CP_NUM)   
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_ITSCP' ,SCP->CP_ITEM)   

                    JO4->(DbSetOrder(1))

                    IF JO4->(MsSeek(xFilial("JO4")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJO4')))
                        JO4->(Reclock("JO4",.f.))
                            JO4->JO4_LIBEST := '1'
                            JO4->JO4_NUMSCP := SCP->CP_NUM
                            JO4->JO4_ITESCP := SCP->CP_ITEM
                        JO4->(msUnLock()) 
                    Endif

                EndIf
            Endif

        Elseif oModel:getOperation() == MODEL_OPERATION_INSERT

            If JN3->(MsSeek(xFilial("JN3")+oModel:getModel('JO3MASTER'):GetValue("JO3_CODORI")))

                JN5->(DbSetOrder(1))
                JO4->(DbSetOrder(1))

                If JO4->(MsSeek(xFilial("JO4")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJO4'))) 
                    JO4->(Reclock("JO4",.f.))
                        JO4->JO4_QTDPRO := oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                        JO4->JO4_LIBEST := '1'
                        JO4->JO4_REQUIS := '1'
                    JO4->(msUnLock()) 
                Else
                    JO4->(Reclock("JO4",.t.))
                        JO4->JO4_FILIAL := xFilial("JN5")
                        JO4->JO4_CODIGO := FSM30INum("JO4",'JO4_CODIGO',1)
                        JO4->JO4_CODJN4 := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJN4')
                        JO4->JO4_TPAPON := '00'
                        JO4->JO4_CODPRO := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO')
                        JO4->JO4_QTDPRO := oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                        JO4->JO4_STATUS := '1'
                        JO4->JO4_CODAA3 := JN3->JN3_CODPRO
                        JO4->JO4_NUMSER := JN3->JN3_NUMSER
                        JO4->JO4_CODJN3 := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODORI')
                        JO4->JO4_CODJN5 := JN5->JN5_CODIGO
                        JO4->JO4_LIBEST := '1'
                        JO4->JO4_REQUIS := '1'
                    JO4->(msUnLock()) 

                Endif
             
            Endif     
  
            if oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS') $ '07|08'   

                if oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS') == AUTOMATICO
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_STATUS',AUTOMATICO) 
                Else
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_STATUS',ISENTO) 
                Endif    

                DbSelectArea("SCP")
                SCP->(DbSetorder(1))

                Aadd( aCab,{ "CP_EMISSAO",oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})

                Aadd(aItens,{})

                Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,oModel:GetModel("JO3MASTER"):GetValue('JO3_ITEM')  ,nil})
                Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO'),nil})
                Aadd(aItens[Len(aItens)],{"CP_UM"      ,oModel:GetModel("JO3MASTER"):GetValue('JO3_UNIMED'),nil})
                Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_NUMOS"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODIGO'),nil})              
                Aadd(aItens[Len(aItens)],{"CP_SEGUM"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_SEGUM'),nil})             
                Aadd(aItens[Len(aItens)],{"CP_QTSEGUM" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QTDSUM'),nil})                    
                Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_LOCAL') ,nil})                   

                MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 3)

                If lMsErroAuto
                    disarmTransaction()		
                Else
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_NUMSCP',SCP->CP_NUM)   
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_ITSCP' ,SCP->CP_ITEM)   
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_DTAPRV',dDataBase)  
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_HRAPRV',SubStr(time(),1,5))
                    
                JO4->(DbSetOrder(1))

                    IF JO4->(MsSeek(xFilial("JO4")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJO4')))
                        JO4->(Reclock("JO4",.f.))
                            JO4->JO4_LIBEST := '1'
                            JO4->JO4_NUMSCP := SCP->CP_NUM
                            JO4->JO4_ITESCP := SCP->CP_ITEM
                        JO4->(msUnLock()) 
                    Endif
                EndIf    
            Else
               oModel:GetModel("JO3MASTER"):SetValue('JO3_STATUS',EM_ABERTO)  
            Endif    
        ElseIF oModel:getOperation() == MODEL_OPERATION_DELETE
                Reclock("JO3",.f.)
                JO3->(Reclock("JO3",.f.))
                    JO3->JO3_DTEXCL := dtos(dDatabase)
                    JO3->JO3_HREXCL := SubStr(time(),1,5)
                    JO3->JO3_CODUSR := __cUserId
                JO3->(msUnLock())

                JO4->(DbSetOrder(1))

               IF JO4->(MsSeek(xFilial("JO4")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJO4')))
                    JO4->(Reclock("JO4",.f.))
                        JO4->JO4_REQUIS := '2'
                    JO4->(msUnLock()) 
                Endif
                
        Endif  
    
    RestArea(aAreaJN3)
    RestArea(aAreaJN4)
    RestArea(aAreaJN5)

    End Transaction

Else

    begin Transaction

        if oModel:getOperation() == MODEL_OPERATION_UPDATE

            if JO3->JO3_STATUS == CORRECAO

                 cItem   :=   JO3->JO3_ITEM
                 cOrigem :=   JO3->JO3_ORIGEM 
                 cCodori :=   JO3->JO3_CODORI 
                 cCodPro :=   JO3->JO3_CODPRO 
                 cLocal  :=   JO3->JO3_LOCAL 
                 cQuanti :=   JO3->JO3_QUANTI  
                 cStatus :=   JO3->JO3_STATUS 
                 cCodUSR :=   JO3->JO3_CODUSR 
                 cEmissa :=   JO3->JO3_EMISSA 
                 cAlias  :=   JO3->JO3_ALIAS 
                 cCodAA1 :=   JO3->JO3_CODAA1 
                 cCodJN7 :=   JO3->JO3_CODJN7
                 cCodSer :=   JO3->JO3_CODJN1 
                 cServi  :=   JO3->JO3_CODJN4
                 cCodJO4 :=   JO3->JO3_CODJO4 

                JO3->(Reclock("JO3",.t.))
                    JO3->JO3_FILIAL :=   xFilial("JO3")
                    JO3->JO3_CODIGO := FSM30INum("JO3",'JO3_CODIGO',1)
                    JO3->JO3_ITEM   := cItem
                    JO3->JO3_ORIGEM := cOrigem
                    JO3->JO3_CODORI := cCodori
                    JO3->JO3_QUANTI := oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                    JO3->JO3_CODPRO := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO')
                    JO3->JO3_LOCAL  := cLocal
                    JO3->JO3_STATUS := oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS')
                    JO3->JO3_CODUSR := cCodUSR
                    JO3->JO3_EMISSA := cEmissa
                    JO3->JO3_ALIAS  := cAlias
                    JO3->JO3_CODAA1 := cCodAA1
                    JO3->JO3_CODJN7 := cCodJN7
                    JO3->JO3_CODJN1 := cCodSer
                    JO3->JO3_CODJN4 := cServi
                    JO3->JO3_CODJO4 := cCodJO4
                JO3->(msUnLock())    

                oModel:GetModel("JO3MASTER"):SetValue('JO3_STATUS',ARQUIVADO)  
                oModel:GetModel("JO3MASTER"):SetValue('JO3_QUANTI',cQuanti)

            Endif       
    
            if oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS')  == APROVADO
                oModel:GetModel('JO3MASTER'):setValue('JO3_STATUS', APROVADO)  

                DbSelectArea("SCP")
                SCP->(DbSetorder(1))

                Aadd( aCab,{ "CP_EMISSAO",oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})

                Aadd(aItens,{})

                Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,oModel:GetModel("JO3MASTER"):GetValue('JO3_ITEM')  ,nil})
                Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO'),nil})
                Aadd(aItens[Len(aItens)],{"CP_UM"      ,oModel:GetModel("JO3MASTER"):GetValue('JO3_UNIMED'),nil})
                Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_NUMOS"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODIGO'),nil})              
                Aadd(aItens[Len(aItens)],{"CP_SEGUM"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_SEGUM'),nil})             
                Aadd(aItens[Len(aItens)],{"CP_QTSEGUM" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QTDSUM'),nil})                    
                Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_LOCAL') ,nil})                                        

                MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 3)

                If lMsErroAuto
                    disarmTransaction()		
                Else
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_NUMSCP',SCP->CP_NUM)   
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_ITSCP' ,SCP->CP_ITEM)   
                EndIf
            Endif

        Elseif oModel:getOperation() == MODEL_OPERATION_INSERT
 
            If JN7->(MsSeek(xFilial("JN7")+oModel:getModel('JO3MASTER'):GetValue("JO3_CODJN7")))


                JN9->(DbSetOrder(1))

                iF JNA->(MsSeek(xFilial("JNA")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJNA'))) .And. JO3->JO3_STATUS != CORRECAO
                    JNA->(Reclock("JNA",.f.))
                        JNA->JNA_QUANTI := oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                        JNA->JNA_REQUIS := '1'
                        JNA->JNA_DTREQU := dDataBase
                    JNA->(msUnLock()) 

                Else
                        JNA->(Reclock("JNA",.T.))
                            JNA->JNA_FILIAL := xFilial("JNA")
                            JNA->JNA_CODIGO := FSM30INum("JNA",'JNA_CODIGO',1)
                            JNA->JNA_PRODUT := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO')
                            JNA->JNA_QUANTI := oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI')
                            JNA->JNA_CODAA1 := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODAA1')
                            JNA->JNA_CODJN9 := oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJN9')
                            JNA->JNA_DTREQU := dDataBase
                            JNA->JNA_ORIGEM := '2'
                            JNA->JNA_REQUIS := '1'
                        JNA->(msUnLock()) 

                        if Empty(oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJNA')) 
                            oModel:GetModel("JO3MASTER"):SetValue('JO3_CODJNA',JNA->JNA_CODIGO)   
                        Endif
            
                Endif  
            Endif     

   
            if oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS') $ '07|08'   

                if oModel:GetModel("JO3MASTER"):GetValue('JO3_STATUS') == AUTOMATICO
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_STATUS',AUTOMATICO) 
                Else
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_STATUS',ISENTO) 
                Endif    

                DbSelectArea("SCP")
                SCP->(DbSetorder(1))

                Aadd( aCab,{ "CP_EMISSAO",oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})

                Aadd(aItens,{})

                Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,oModel:GetModel("JO3MASTER"):GetValue('JO3_ITEM')  ,nil})
                Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODPRO'),nil})
                Aadd(aItens[Len(aItens)],{"CP_UM"      ,oModel:GetModel("JO3MASTER"):GetValue('JO3_UNIMED'),nil})
                Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QUANTI'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_NUMOS"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_CODIGO'),nil})              
                Aadd(aItens[Len(aItens)],{"CP_SEGUM"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_SEGUM'),nil})             
                Aadd(aItens[Len(aItens)],{"CP_QTSEGUM" ,oModel:GetModel("JO3MASTER"):GetValue('JO3_QTDSUM'),nil})                    
                Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,oModel:GetModel("JO3MASTER"):GetValue('JO3_EMISSA'),nil})   
                Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,oModel:GetModel("JO3MASTER"):GetValue('JO3_LOCAL') ,nil})                                       

                MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 3)

                If lMsErroAuto
                    disarmTransaction()		
                Else
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_NUMSCP',SCP->CP_NUM)   
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_ITSCP' ,SCP->CP_ITEM)   
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_DTAPRV',dDataBase)  
                    oModel:GetModel("JO3MASTER"):SetValue('JO3_HRAPRV',SubStr(time(),1,5))

                EndIf    
            Endif
        ElseIF oModel:getOperation() == MODEL_OPERATION_DELETE
                Reclock("JO3",.f.)
                JO3->(Reclock("JO3",.f.))
                    JO3->JO3_DTEXCL := dtos(dDatabase)
                    JO3->JO3_HREXCL := SubStr(time(),1,5)
                    JO3->JO3_CODUSR := __cUserId
                JO3->(msUnLock())

                IF JNA->(MsSeek(xFilial("JNA")+oModel:GetModel("JO3MASTER"):GetValue('JO3_CODJNA')))
                    JNA->(Reclock("JNA",.f.))
                        JNA->JNA_REQUIS := '2'
                    JNA->(msUnLock()) 
                Endif     
        Endif  

    RestArea(aAreaJN7)
    RestArea(aAreaJN9)
    RestArea(aAreaJNA)

    End Transaction

Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} geraDadSCP()
 Retorna o conteudo do posicione. Utilizado GetArea e RestArea para 
 nao desposicionar
/*/
//-------------------------------------------------------------------


Function geraDadSCP(cCampo)

Local cRetorno
Local aAreaSCP  := SCP->( GetArea() )
 
    cRetorno := Posicione("SCP",2,xFilial("SCP")+JO3->JO3_CODPRO+JO3->JO3_NUMSCP,cCampo)
 
RestArea(aAreaSCP)

Return cRetorno



    //-------------------------------------------------------------------
/*/{Protheus.doc} FSMStOs

@author	Vitor Kwon
@since	26/01/2025
/*/
//-------                                                                                                            

Function FSMStEsto()
Local aArea   := GetArea()
Local cOpcoes := ""
 
cOpcoes += "01=EM_ABERTO 01;"
cOpcoes += "02=ANALISE 02;"
cOpcoes += "03=APROVADO 03;"
cOpcoes += "04=REPROVADO 04;"
cOpcoes += "05=CORRECAO 05;"
cOpcoes += "06=ARQUIVADO 06;"
cOpcoes += "07=AUTOMATICO 07;"
cOpcoes += "08=ISENTO 08;"

RestArea(aArea)

Return cOpcoes

