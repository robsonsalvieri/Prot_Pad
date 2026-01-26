#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPC300X.CH'

/*/{Protheus.doc} GTPC300X
(long_description)
@type  Static Function
@author flavio.martins
@since 15/10/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300X(aMsgErro)
Private aErros  := aMsgErro

If ( Len(aMsgErro) > 0 )
  FwExecView(STR0001, "VIEWDEF.GTPC300X", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, 40,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) // "Validação Documentos Operacionais"
EndIf

UpdMsgErro(@aMsgErro)

Return

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStruCab	:= FwFormModelStruct():New() 
	Local oStruMsg	:= FwFormModelStruct():New() 
	Local bLoad		:= {|oModel| GC300XLoad(oModel)}

	oModel := MPFormModel():New("GTPC300X",/*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

	SetMdlStru(oStruCab, oStruMsg)

	oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
	oModel:AddGrid("GRIDMSG", "HEADER", oStruMsg,,,,, bLoad)

	oModel:SetDescription(STR0001) // "Validação Documentos Operacionais"
	oModel:GetModel("HEADER"):SetDescription("Header")
	oModel:GetModel("GRIDMSG"):SetDescription(STR0002) // "Mensagens"
	oModel:SetPrimaryKey({})

	oModel:GetModel("GRIDMSG"):SetMaxLine(99999)	

  oModel:GetModel("GRIDMSG"):SetNoInsertLine(.T.)
  oModel:GetModel("GRIDMSG"):SetNoDeleteLine(.T.)
  
Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 15/10/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel("GTPC300X")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruMsg 	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FwFormView():New()

SetViewStru(oStruCab, oStruMsg)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Validação Documentos Operacionais"

oView:AddGrid('VIEW_GRID', oStruMsg, 'GRIDMSG')

//oView:CreateHorizontalBox('HEADER', 35)
oView:CreateHorizontalBox('GRID', 100)

//oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID','GRID')

//oView:EnableTitleView("VIEW_HEADER", "")
oView:EnableTitleView("VIEW_GRID", STR0002) // "Mensagens"

oView:AddUserButton(STR0010, "", {|oModel| SetConfirm(oView, .T.)})	// "Marcar Todos"
oView:AddUserButton(STR0011, "", {|oModel| SetConfirm(oView, .F.)})	// "Desmarcar Todos"

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 15/10/2022
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruCab, oStruMsg)
Local bFldVld  := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrg  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

oStruCab:AddTable("   ",{" "}," ")
oStruCab:AddField("COL", "COL", "COLUNA" ,"C", 10 ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)    

oStruMsg:AddField(STR0015, STR0015,	"MARK","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)                                  // "Confirmar"
oStruMsg:AddField("", "", "LEG", "BT", 15,0, Nil, Nil, Nil, .F., {|| .T.}, .F., .F., .T.)
oStruMsg:AddField(STR0003, STR0003, "TYPE_ERROR" ,"C", 20 ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)                        // "Tipo Erro"	
oStruMsg:AddField(STR0010, STR0010, "CODRECURSO" ,"C", TamSx3('GQE_RECURS')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)   // "Cód. Recurso"	
oStruMsg:AddField(STR0013, STR0013, "CODVIAGEM" ,"C", TamSx3('GYN_CODIGO')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)    // "Cód. Viagem"	
oStruMsg:AddField(STR0014, STR0014, "DATAREF"	 ,"D", 8  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	                        // "Data Referência"
oStruMsg:AddField(STR0004, STR0004, "CODDOCTO" ,"C", TamSx3('G6U_CODIGO')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Cód. Docto."
oStruMsg:AddField(STR0005, STR0005, "DESDOCTO" ,"C", TamSx3('G6U_DESCRI')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Descr. Docto."
oStruMsg:AddField(STR0006, STR0006, "DATAINI"	 ,"D", 8  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	                        // "Data Inicial"
oStruMsg:AddField(STR0007, STR0007, "DATAFIM"	 ,"D", 8  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)                          // "Data Final"
oStruMsg:AddField(STR0008, STR0008, "DATAMAX" ,"D", 8  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)                           // "Data Máxima"
oStruMsg:AddField(STR0009, STR0009, "MENSAGEM" ,"C", 100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)                          // "Mensagem"

oStruMsg:SetProperty('MARK', MODEL_FIELD_VALID, bFldVld)
oStruMsg:AddTrigger("MARK","MARK", {||.T.}, bFldTrg)

Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 15/10/2022
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruMsg)

oStruCab:AddField("COL","01","COL", "COL",{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 

oStruMsg:AddField("MARK"      ,"01",STR0015, STR0015,{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)   // "Confirmar"
oStruMsg:AddField("LEG"       ,"02","","",{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) 
oStruMsg:AddField("TYPE_ERROR","03",STR0003, STR0003,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Tipo Erro"
oStruMsg:AddField("CODRECURSO","04",STR0012, STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Cód. Recurso"
oStruMsg:AddField("CODVIAGEM" ,"05",STR0013, STR0013,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Cód. Viagem"
oStruMsg:AddField("DATAREF"   ,"06",STR0014, STR0014,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // ""Data Referência""
oStruMsg:AddField("CODDOCTO"  ,"07",STR0004, STR0004,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	  // "Cód. Docto."
oStruMsg:AddField("DESDOCTO"  ,"08",STR0005, STR0005,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	  // "Descr. Docto."
oStruMsg:AddField("DATAINI"   ,"09",STR0006, STR0006,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Data Inicial"
oStruMsg:AddField("DATAFIM"   ,"10",STR0007, STR0007,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	  // "Data Final"
oStruMsg:AddField("DATAMAX"   ,"11",STR0008, STR0008,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)   // "Data Máxima"
oStruMsg:AddField("MENSAGEM"  ,"12",STR0009, STR0009,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Mensagem"

Return

/*/{Protheus.doc} GC300XLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 15/10/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GC300XLoad(oModel)
Local aLoad 	:= {}
Local nX        := 0        

If oModel:GetId() == 'HEADER'
  //  aAdd(aLoad,{0,{'','',0}})
ElseIf oModel:GetId() == 'GRIDMSG'

   For nX := 1 To Len(aErros)

        Aadd(aLoad,{0,{ aErros[nX][1],;
                        aErros[nX][2],;
                        aErros[nX][3],;
                        aErros[nX][4],;
                        aErros[nX][5],;
                        aErros[nX][6],;
                        aErros[nX][7],;
                        aErros[nX][8],;
                        aErros[nX][9],;
                        aErros[nX][10],;
                        aErros[nX][11],;
                        aErros[nX][12]}})

   Next
 
Endif

Return aLoad

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author flavio.martins
@since 18/04/2023
@version 1.0
@param oModel, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If cField == 'MARK'

  If oMdl:GetValue('LEG') == 'UPDERROR' .And. uNewValue
      lRet        := .F.
      cMsgErro    := STR0016 // "Documentos vencidos e fora da data limite não podem ser confirmados"
      cMsgSol     := STR0017 // "Verifique ou atualize a documentação do recurso"
  Endif

Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
(long_description)
@type  Static Function
@author flavio.martins
@since 18/04/2023
@version 1.0
@param oModel, param_type, param_descr
@return uVal, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

If cField == 'MARK'
  aErros[oMdl:GetLine()][1] := uVal
Endif

Return uVal

Static Function SetConfirm(oView, lConf)
Local oGridMsg	:= oView:GetModel('GRIDMSG')
Local nX		    := 0

For nX := 1 To oGridMsg:Length()

  oGridMsg:GoLine(nX)

  If oGridMsg:GetValue('LEG') == 'UPDWARNING'
    oGridMsg:SetValue('MARK', lConf)  
  Endif

Next

oGridMsg:GoLine(1)

Return

/*/{Protheus.doc} UpdMsgErro
(long_description)
@type  Static Function
@author flavio.martins
@since 18/04/2023
@version 1.0
@param oModel, param_type, param_descr
@return uVal, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function UpdMsgErro(aMsgErro)
Local nX := 0

For nX := 1 To Len(aMsgErro)

  aMsgErro[nX][1] := aErros[nX][1]

Next

Return
