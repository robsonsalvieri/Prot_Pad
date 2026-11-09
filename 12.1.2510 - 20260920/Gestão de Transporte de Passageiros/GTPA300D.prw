#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA300D.CH'

Static aErros  := {}

/*/{Protheus.doc} GTPA300D
Logs de exclusão de viagens
@type  Static Function
@author João Pires
@since 04/08/2026
/*/
Function GTPA300D(aMsgErro)

aErros  := aMsgErro

If ( Len(aMsgErro) > 0 )
  FwExecView(STR0001, "VIEWDEF.GTPA300D", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, 40,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) // "Exclusão de viagens"
EndIf

Return

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author João Pires
@since 04/08/2026
@version 1.0
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStruCab	:= FwFormModelStruct():New() 
	Local oStruMsg	:= FwFormModelStruct():New() 
	Local bLoad		:= {|oModel| GA300DLoad(oModel)}

	oModel := MPFormModel():New("GTPA300D",/*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

	SetMdlStru(oStruCab, oStruMsg)

	oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
	oModel:AddGrid("GRIDMSG", "HEADER", oStruMsg,,,,, bLoad)

	oModel:SetRelation( 'GRIDMSG', { { 'FILIAL', 'XFILIAL("GYN")' } }   )

	oModel:SetDescription(STR0001) // "Exclusão de viagens"
	oModel:GetModel("HEADER"):SetDescription(STR0002) //"Cabeçalho"
	oModel:GetModel("GRIDMSG"):SetDescription(STR0003) // "Mensagens"
	oModel:SetPrimaryKey({})

	oModel:GetModel("GRIDMSG"):SetMaxLine(99999)	

  oModel:GetModel("GRIDMSG"):SetNoInsertLine(.T.)
  oModel:GetModel("GRIDMSG"):SetNoDeleteLine(.T.)
  
Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author João Pires
@since 04/08/2026
@version 1.0
/*/
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel("GTPA300D")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruMsg 	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FwFormView():New()

SetViewStru(oStruCab, oStruMsg)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Exclusão de viagens"

oView:AddGrid('VIEW_GRID', oStruMsg, 'GRIDMSG')

oView:CreateHorizontalBox('GRID', 100)

oView:SetOwnerView('VIEW_GRID','GRID')

oView:EnableTitleView("VIEW_GRID", STR0003) // "Mensagens"

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author João Pires
@since 04/08/2026
@version 1.0
/*/
Static Function SetMdlStru(oStruCab, oStruMsg)

	If ValType( oStruCab ) == "O"
		oStruCab:AddTable("   ",{" "}," ")    
		oStruCab:AddField(STR0008, STR0008, "FILIAL" ,"C", TamSx3('GYN_FILIAL')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  //"Filial"
	Endif

	If ValType( oStruMsg ) == "O"
		oStruMsg:AddField(STR0004, STR0004, "CONTRATO" ,"C", TamSx3('GYN_CODGY0')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  //"Contrato"
		oStruMsg:AddField(STR0005, STR0005, "VIAGEM"   ,"C", TamSx3('GYN_CODIGO')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  // "Viagem"	
		oStruMsg:AddField(STR0006, STR0006, "STATUS"   ,"C", 7 						 ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  // "Status"	
		oStruMsg:AddField(STR0007, STR0007, "MENSAGEM" ,"C", 100					 ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  //"Descrição"                       // "Mensagem"
	Endif



Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author João Pires
@since 15/10/2022

/*/
Static Function SetViewStru(oStruCab, oStruMsg)

oStruMsg:AddField("CONTRATO","01",STR0004, STR0004,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Contrato"
oStruMsg:AddField("VIAGEM"  ,"02",STR0005, STR0005,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Viagem"
oStruMsg:AddField("STATUS"  ,"03",STR0006, STR0006,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Status"
oStruMsg:AddField("MENSAGEM","04",STR0007, STR0007,{""},"GET",""  ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Descrição"

Return

/*/{Protheus.doc} GA300DLoad
(long_description)
@type  Static Function
@author João Pires
@since 04/08/2026
/*/
Static Function GA300DLoad(oModel)
Local aLoad 	:= {}
Local nX        := 0        

If oModel:GetId() == 'GRIDMSG'

   For nX := 1 To Len(aErros)

        Aadd(aLoad,{0,{ aErros[nX][1],;
                        aErros[nX][2],;
                        aErros[nX][3],;
                        aErros[nX][4],;
                    }})

   Next
 
Endif

Return aLoad
