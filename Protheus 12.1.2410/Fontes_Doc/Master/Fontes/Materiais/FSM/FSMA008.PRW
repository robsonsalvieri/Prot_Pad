#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA008

Tipos de Servicos
@author Vitor kwon
@since 27/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
PUBLISH MODEL REST NAME FSMORDEM source FSMA008 RESOURCE OBJECT FsmRestModel
Static Function Modeldef()

Local oModel  := NIL
Local oStrJN3 := FWFormStruct( 1, "JN3" )
Local oStrJN4 := FWFormStruct( 1, "JN4" )
Local oStrJN5 := FWFormStruct( 1, "JN5" )
Local oStrJN6 := FWFormStruct( 1, "JN6" )
Local oStrJO4 := FWFormStruct( 1, "JO4" )

Local oModelEvent :=  FSMA008Event():New()


oStrJN3:AddField("CPF\CGC"  ,"Documento","JN3_DOCUME"  ,"C",TamSx3('A1_CGC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStrJN3:AddField("Contato"  ,"Contato"  ,"JN3_CONTATO" ,"C",TamSx3('A1_CONTATO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)										
oStrJN3:AddField("Nome"     ,"Nome"     ,"JN3_NOME"    ,"C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJN3:AddField("Razão"    ,"Razão"    ,"JN3_FANTAS"  ,"C",TamSx3('A1_NREDUZ')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJN3:AddField("E-mail"   ,"E-mail"   ,"JN3_EMAIL"   ,"C",TamSx3('A1_EMAIL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN3:AddField("Telefome" ,"Telefome" ,"JN3_TELEFO"  ,"C",TamSx3('A1_TEL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStrJN3:AddField("ChaveOS"  ,"Chave  OS"          ,"JN3_PKOS"     ,"C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStrJN3:AddField("ChaveOrigem"   ,"Chave OS Origem","JN3_PKORI"    ,"C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStrJN3:AddField("Atendimento"   ,"Endereço"      ,"JN3_ENDATD"  ,"C",TamSx3('A1_END')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN3:AddField("Complemento"   ,"Complemento"   ,"JN3_CPLATD"  ,"C",TamSx3('A1_COMPLEM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN3:AddField("Bairro"        ,"Bairro"        ,"JN3_BAIATD"  ,"C",TamSx3('A1_BAIRRO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN3:AddField("Estado"        ,"Estado"        ,"JN3_ESTATD"  ,"C",TamSx3('A1_EST')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN3:AddField("Municipio"     ,"Municipio"     ,"JN3_MUNATD"  ,"C",TamSx3('A1_MUN')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN3:AddField("Nome Usuário","Nome Usuário","JN3_NOMUSU","C",40,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN3:AddField("Nome Cidade","Nome Cidade","JN3_DESCID","C",TamSx3('CC2_MUN')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN4:AddField("Descr.Servico","Descr.Servico","JN4_DSCJN1","C",TamSx3('JN1_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJN4:AddField("Valor.Serviço","Valor.Serviço","JN4_VALSER","C",TamSx3('B1_PRV1')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJN5:AddField("Descr.Produto","Descr.Produto","JN5_DSCSB1","C",TamSx3('B1_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)			
oStrJN5:AddField("Valor.Produto","Valor.Produto","JN5_VLRPRD","C",TamSx3('B1_PRV1')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStrJN5:AddField("Unidade de Medida","UM"           ,"JN5_UNIMED","C",TamSx3('B1_UM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStrJN5:AddField("Segunda UM"       ,"2UM"          ,"JN5_SEGUM","C" ,TamSx3('B1_SEGUM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStrJN5:AddField("Fator Conversão"  ,"Conversão"     ,"JN5_FATOR","C" ,TamSx3('B1_CONV')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStrJN5:AddField("Valor.Produto"    ,"Valor.Produto","JN5_TPCONV","C",TamSx3('B1_TIPCONV')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStrJN6:AddField("Nome","Nome","JN6_DSCAA1","C",TamSx3('AA1_NOMTEC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)

oModel:= MPFormModel():New( "FSMA008", /*Pre-Validacao*/, /*Pos-Validacao*/,,/*Commit*/,/*Cancel*/)

oModel:AddFields( "JN3MASTER", NIL, oStRJN3, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:AddGrid( 'JN4DETAIL', 'JN3MASTER', oStrJN4)

oModel:AddGrid( 'JN5DETAIL', 'JN4DETAIL', oStrJN5)

oModel:AddGrid( 'JN6DETAIL', 'JN4DETAIL', oStrJN6)

oModel:AddGrid( 'JO4DETAIL', 'JN4DETAIL', oStrJO4)

oModel:InstallEvent(" FSMA008Event", /*cOwner*/, oModelEvent)

oModel:SetRelation('JN4DETAIL', {{'JN4_FILIAL', 'xFilial("JN4")'},;
                                 {'JN4_CODJN3', 'JN3_CODIGO'}},;
                                 JN4->(IndexKey(2)))

oModel:SetRelation('JN5DETAIL', {{'JN5_FILIAL', 'xFilial("JN5")'},;
                                 {'JN5_CODJN4', 'JN4_CODIGO'}},;
                                 JN5->(IndexKey(2)))

oModel:SetRelation('JN6DETAIL', {{'JN6_FILIAL', 'xFilial("JN6")'},;
                                 {'JN6_CODJN4', 'JN4_CODIGO'}},;
                                 JN6->(IndexKey(4)))

oModel:SetRelation('JO4DETAIL', {{'JO4_FILIAL', 'xFilial("JO4")'},;
                                 {'JO4_CODJN4', 'JN4_CODIGO'},;
                                 {'JO4_CODJN3', 'JN4_CODJN3'}},;
                                 JO4->(IndexKey(2)))
                                 
oStrJN3:SetProperty("JN3_DOCUME",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"A1_CGC"),"")'))

oStrJN3:SetProperty("JN3_CONTATO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"A1_CONTATO"),"")'))

oStrJN3:SetProperty("JN3_NOME",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"A1_NOME"),"")'))

oStrJN3:SetProperty("JN3_FANTAS",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"A1_NREDUZ"),"")'))

oStrJN3:SetProperty("JN3_EMAIL",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"A1_EMAIL"),"")'))

oStrJN3:SetProperty("JN3_TELEFO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"A1_TEL"),"")'))

oStrJN3:SetProperty("JN3_NOMUSU",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,FwGetUserName(JN3->JN3_USUINC),"")'))

oStrJN3:SetProperty("JN3_DESCID",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'IF(!INCLUI,Posicione("CC2",1,XFILIAL("CC2")+JN3->JN3_ESTADO+JN3->JN3_CIDADE, "CC2_MUN"),"")'))

oStrJN4:SetProperty("JN4_DSCJN1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN1",1,xFilial("JN1")+JN4->JN4_CODJN1,"JN1_DESCRI"),"")'))

oStrJN4:SetProperty("JN4_VALSER",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN1",1,xFilial("JN1")+JN4->JN4_CODJN1,"JN1_VALOR"),"")'))                     

oStrJN5:SetProperty("JN5_DSCSB1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JN5->JN5_CODPRO,"B1_DESC"),"")'))

oStrJN5:SetProperty("JN5_VLRPRD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JN5->JN5_CODPRO,"B1_PRV1"),"")'))

oStrJN5:SetProperty("JN5_UNIMED",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JN5->JN5_CODPRO,"B1_UM"),"")'))  

oStrJN5:SetProperty("JN5_SEGUM",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JN5->JN5_CODPRO,"B1_SEGUM"),"")'))   

oStrJN5:SetProperty("JN5_FATOR",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JN5->JN5_CODPRO,"B1_CONV"),"")'))   

oStrJN5:SetProperty("JN5_TPCONV",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JN5->JN5_CODPRO,"B1_TIPCONV"),"")'))   

oStrJN5:SetProperty("JN5_REQUIS",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'2'))

oStrJN6:SetProperty("JN6_STATUS",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'1'))

oStrJN6:SetProperty("JN6_SITUAC",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,"'02'"))

oStrJN6:SetProperty("JN6_DSCAA1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getPosiAA1("AA1_NOMTEC")'))
            
oStrJN3:SetProperty( 'JN3_PKOS' , MODEL_FIELD_INIT,;
                    {|| Encode64(JN3->JN3_FILIAL+JN3->JN3_CODIGO)})
                
oStrJN3:SetProperty( 'JN3_PKORI' , MODEL_FIELD_INIT,;
                    {|| Encode64(JN3->JN3_FILIAL+JN3->JN3_CODORI)})

oStrJN3:SetProperty("JN3_ENDATD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN0",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"JN0_END"),"")'))

oStrJN3:SetProperty("JN3_CPLATD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN0",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"JN0_COMPL"),"")'))

oStrJN3:SetProperty("JN3_BAIATD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN0",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"JN0_BAIRRO"),"")'))

oStrJN3:SetProperty("JN3_ESTATD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN0",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"JN0_ESTADO"),"")'))

oStrJN3:SetProperty("JN3_MUNATD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN0",1,xFilial("SA1")+JN3->JN3_CLIENT+JN3->JN3_LOJA,"JN0_CIDADE"),"")'))

oModel:SetPrimaryKey({"JN3_CODIGO"})

oModel:SetDescription( 'Ordem de Serviço' ) 

oModel:GetModel( "JN3MASTER" ):SetDescription( 'Ordem de Serviço' ) 

oModel:GetModel("JN4DETAIL"):SetOptional(.T.)

oModel:GetModel("JN5DETAIL"):SetOptional(.T.)

oModel:GetModel("JN6DETAIL"):SetOptional(.T.)

oModel:GetModel("JO4DETAIL"):SetOptional(.T.)

oStrJN3:SetProperty('JN3_CODPRO',MODEL_FIELD_OBRIGAT, .F.)

oStrJN3:SetProperty('JN3_NUMSER',MODEL_FIELD_OBRIGAT, .F.)

oStrJN4:SetProperty("JN4_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JN4","JN4_CODIGO")'))

oStrJN5:SetProperty("JN5_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JN5","JN5_CODIGO")'))

oStrJN6:SetProperty("JN6_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JN6","JN6_CODIGO")'))

Return oModel


/*/{Protheus.doc} FSMA008Event()
/*/
//-------------------------------------------------------------------


Class FSMA008Event From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method ModelPosVld()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA011CMT()
/*/
//-------------------------------------------------------------------


Method New() Class FSMA008Event
	
Return Nil	
//-------------------------------------------------------------------
/*/{Protheus.doc} getPosiAA1

@author	Vitor Kwon
@since	22/07/2024
/*/
//-------------------------------------------------------------------

Function getPosiAA1(cCampo)

Local cRetorno
Local aAreaAA1  := AA1->( GetArea() )
 
    cRetorno := Posicione("AA1",1,xFilial("AA1")+JN6->JN6_CODAA1,cCampo)
 
RestArea(aAreaAA1)

Return cRetorno




     //-------------------------------------------------------------------
/*/{Protheus.doc} FSMStOs

@author	Vitor Kwon
@since	26/01/2025
/*/
//-------                                                                                                            

Function FSMStOs()
Local aArea   := GetArea()
Local cOpcoes := ""
 
cOpcoes += "00=SEM_ALOCACAO 00;"
cOpcoes += "01=EM_ATENDIMENTO 01;"
cOpcoes += "02=EM_ABERTO 02;"
cOpcoes += "03=EM_PAUSA 03;"
cOpcoes += "04=ENCERRADO 04;"
cOpcoes += "05=CANCELADO 05;"

RestArea(aArea)
Return cOpcoes


//-------------------------------------------------------------------
/*/{Fonte} - ModelPosVld
@author Vitor Kwon
@version 1.0
04/02/2025
*/
//-------------------------------------------------------------------

Method ModelPosVld(oModel, cModelId) Class FSMA008Event

Local lRet := .T.
local nX := 0
local nI := 0
local oModJO4 := oModel:GetModel("JO4DETAIL")
local oModJN5 := oModel:GetModel("JN5DETAIL")
local oModJN4 := oModel:GetModel("JN4DETAIL")

IF !isincallstack("PUT_ENCERRAMENTO") 
    if oModel:getOperation() != MODEL_OPERATION_DELETE
        IF !Empty(oModel:GetModel("JN5DETAIL"):getValue("JN5_CODPRO"))
            for nI := 1 to oModJN4:Length()  
                oModJN4:goLine(nI)
                For nX := 1 To oModel:GetModel("JN5DETAIL"):Length()
                    oModJN5:GoLine(nX)
                    oModJO4:GoLine(nX)
                    oModJO4:SetValue("JO4_CODJN5",oModel:GetModel("JN5DETAIL"):getValue("JN5_CODIGO"))
                    if oModJO4:GetValue('JO4_LIBEST') == '5'
                        oModJO4:SetValue("JO4_LIBEST",'5')
                    Else
                        oModJO4:SetValue("JO4_LIBEST",'3')
                    Endif
                Next nX	   
            Next nI 
        Endif     
    Endif
EndIf

Return lRet
