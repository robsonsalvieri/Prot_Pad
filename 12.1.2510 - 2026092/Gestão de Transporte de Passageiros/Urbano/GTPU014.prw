#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU014.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPU014

    @type Static Function
    @author flavio.martins
    @since 03/06/2024
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Function GTPU014()

	Local oBrowse   := Nil
	Local cMsgErro  := ''

	If GU014VldDic(@cMsgErro)   

		Processa({|| GTPU014Load()})

	    oBrowse := FwMBrowse():New()
	    oBrowse:SetAlias('H7O')
	    oBrowse:SetDescription(STR0001) // "Tipos de Receitas e Despesa - Urbano"	
		oBrowse:SetCacheView(.F.)	
	    oBrowse:Activate()
	Else
	    FwAlertHelp(cMsgErro, STR0002) // "Banco de dados desatualizado, não será possível iniciar a rotina"
	Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

    @type Static Function
    @author flavio.martins
    @since 03/06/2024
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPU014' OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina TITLE "Incluir" ACTION 'VIEWDEF.GTPU014' OPERATION 3 ACCESS 0	//'Incluir'
	ADD OPTION aRotina TITLE "Alterar" ACTION 'VIEWDEF.GTPU014' OPERATION 4 ACCESS 0	//'Alterar'
	ADD OPTION aRotina TITLE "Excluir" ACTION 'VIEWDEF.GTPU014' OPERATION 5 ACCESS 0	//'Excluir'
	    
Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    @type Static Function
    @author flavio.martins
    @since 03/06/2024
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel     := Nil
	Local oStruH7O   := FwFormStruct(1, 'H7O' )
	Local lH86       := AliasInDic('H86')
	Local oStH86     := IIF( lH86, FWFormStruct(1, 'H86' ), Nil)
	Local bPosValid  := {|oModel| GU014PosVld(oModel)}
	Local bFieldTrig := {|oMdl, cField, uVal| FieldTrigger(oMdl,cField,uVal)}
	Local aTrigAux   := {}


	oStruH7O:AddTrigger("H7O_TIPO", "H7O_TIPO", {||.T.}, bFieldTrig)

	oModel := MPFormModel():New('GTPU014',, bPosValid)
	oModel:SetVldActivate({|oModel| GU014VldAct(oModel)})

	oModel:AddFields('H7OMASTER',, oStruH7O)

	oModel:SetDescription(STR0001) // "Tipos de Receitas e Despesa - Urbano"
	oModel:GetModel('H7OMASTER'):SetDescription(STR0001) // "Tipos de Receitas e Despesa - Urbano"

	If lH86
		oModel:AddGrid('H86DETAIL','H7OMASTER',oStH86,/*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/) 
		oModel:SetRelation("H86DETAIL", {{'H86_FILIAL' ,  "xFilial('H86')"}, {'H86_CODH7O' ,  'H7O_CODIGO' }}, H86->( IndexKey( 1 ))) 
		oModel:GetModel('H86DETAIL'):SetDescription(STR0014) // 'Receita/Despesa por tipo da linha' 
		
		aTrigAux := FwStruTrigger("H86_TIPLIN", "H86_DESCTL", "GetAdvFval('GQC','GQC_DESCRI',xFilial('GQC') + FwFldGet('H86_TIPLIN'),1)")
		oStH86:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])
	EndIf

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author flavio.martins
    @since 03/06/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := ModelDef()
	Local oStruH7O := FwFormStruct(2, 'H7O' )
	Local oView    := Nil
	Local nI       := 1
	Local lH86     := AliasInDic('H86')
	Local oStH86   := IIF( lH86, FWFormStruct(2, 'H86'), Nil)

	oStruH7O:AddGroup('GERAIS',  STR0011, '', 2 ) 	//Cadastrais
	oStruH7O:AddGroup('RECEITA', STR0012, '', 2 )	//Receita
	oStruH7O:AddGroup('DESPESA', STR0013, '', 2 )	//Despesa

	For nI := 1 To Len(oStruH7O:aFields)
		If (oStruH7O:aFields[nI][1] $ 'H7O_NATREC|H7O_PREREC|')
			oStruH7O:SetProperty(oStruH7O:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "RECEITA" )
		ElseIf (oStruH7O:aFields[nI][1] $ 'H7O_NATDES|H7O_PREDES|')
			oStruH7O:SetProperty(oStruH7O:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "DESPESA" )
		Else
			oStruH7O:SetProperty(oStruH7O:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "GERAIS" )
		EndIf
	Next

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_H7O', oStruH7O, 'H7OMASTER')

	oView:CreateHorizontalBox('VIEWTOTAL',40)
	oView:SetOwnerView('VIEW_H7O','VIEWTOTAL') 

	oStruH7O:SetProperty( 'H7O_PROPRI', MVC_VIEW_CANCHANGE, .F. )
	oStruH7O:SetProperty( 'H7O_INCMAN', MVC_VIEW_CANCHANGE, .F. )

	If lH86
		oView:CreateHorizontalBox('VIEWGRID1',60)		
		oView:AddGrid('VIEW_H86' , oStH86, 'H86DETAIL')
		oView:SetOwnerView('VIEW_H86', 'VIEWGRID1')
		oView:EnableTitleView('VIEW_H86', STR0014) 	//'Receita/Despesa por tipo da linha'
		oStH86:RemoveField("H86_FILIAL")
		oStH86:RemoveField("H86_CODH7O")
	EndIf

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} GU014VldAct

    @type Static Function
    @author flavio.martins
    @since 03/06/2024
    @version 1.0
 	@return lógico, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function GU014VldAct(oModel)

	Local lRet      := .T.
	Local cMsgErro  := ''
	Local cMsgSol   := ''

	If !GU014VldDic(@cMsgErro)
	    lRet := .F.
	    cMsgSol :=  STR0003 // "Atualize o dicionário para utilizar esta rotina"
	    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GU014VldAct", cMsgErro, cMsgSol) 
	    Return .F.
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GU014VldDic

    @type Static Function
    @author flavio.martins
    @since 03/06/2024
    @version 1.0
 	@return lógico, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function GU014VldDic(cMsgErro)

	Local lRet          := .T.
	Local aTables       := {'H7O','H86'}
	Local aFields       := {}
	Local nX            := 0
	Default cMsgErro    := ''

	aFields := {'H7O_CODIGO','H7O_DESCRI','H7O_TIPO  ','H7O_PROPRI',;
				'H7O_INCMAN','H7O_GERTIT','H7O_BXATIT','H7O_PREREC',;
				'H7O_NATREC','H7O_PREDES','H7O_NATDES'}

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

//------------------------------------------------------------------------------
/*/{Protheus.doc} GU014PosVld

    @type Static Function
    @author flavio.martins
    @since 03/06/2024
    @version 1.0
 	@return lógico, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function GU014PosVld(oModel)
	Local aAreaH7O := H7O->(GetArea())
	Local lRet     := .T.
	Local lH86     := AliasInDic('H86')
	Local oMdlH86  := Nil
	Local nCnt     := 0
	Local nPos     := 0
	Local aPos	   := {}
	Local cMsg     := ''

	If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. oModel:GetValue('H7OMASTER','H7O_PROPRI') == 'S'
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GU014PosVld", STR0004) // "Registros criados pelo sistema não podem ser excluídos"
	Endif

	If oModel:GetOperation() == MODEL_OPERATION_INSERT 

		H7O->(DbSetOrder(1)) //H7O_FILIAL+H7O_CODIGO                                                                                                                                                                                                                                                                                    
		If H7O->(DBSEEK( xFilial("H7O") + oModel:GetModel():GetValue('H7OMASTER', 'H7O_CODIGO') )) 
			
			lRet := .F.
			oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GU014PosVld", STR0009, STR0010) // "O código de Tipo de Receita/Despesa já existe", "É necessário informar um código de Tipo de Receita/Despesa diferente "

		EndIf

	Endif

	If lRet .And. lH86
		oMdlH86:= oModel:GetModel('H86DETAIL')
		For nCnt :=1 To oMdlH86:Length()
			oMdlH86:GoLine(nCnt)
			If !oMdlH86:IsDeleted() 
				If !Empty(oMdlH86:GetValue('H86_PREREC'))
					If (nPos:= Ascan(aPos,{|z| z == 'REC'+oMdlH86:GetValue('H86_PREREC')+oMdlH86:GetValue('H86_TIPLIN') })) == 0
						Aadd( aPos, 'REC'+oMdlH86:GetValue('H86_PREREC')+oMdlH86:GetValue('H86_TIPLIN') )
					Else 
						lRet := .F. 
						cMsg := '['+Substr(aPos[nPos],4,3) + '] campo Prefixo Receita'
						nCnt +=	oMdlH86:Length() + 1				
					EndIf 
				EndIf 
				If lRet .And. !Empty(oMdlH86:GetValue('H86_PREDES'))
					If (nPos:= Ascan(aPos,{|z| z == 'DES'+oMdlH86:GetValue('H86_PREDES')+oMdlH86:GetValue('H86_TIPLIN') })) == 0
						Aadd( aPos, 'DES'+oMdlH86:GetValue('H86_PREDES')+oMdlH86:GetValue('H86_TIPLIN') )
					Else 
						lRet := .F. 
						cMsg := '['+Substr(aPos[nPos],4,3) + '] campo Prefixo Despesa'
						nCnt +=	oMdlH86:Length() + 1				
					EndIf 
				EndIf 
				If lRet //.And. !Empty(oMdlH86:GetValue('H86_TIPLIN'))
					If (nPos:= Ascan(aPos,{|z| z == 'LIN'+oMdlH86:GetValue('H86_TIPLIN')})) == 0
						Aadd( aPos, 'LIN'+oMdlH86:GetValue('H86_TIPLIN') )
					Else 
						lRet := .F. 
						cMsg := '['+ Substr(aPos[nPos],4,3)+ '] campo Tipo Linha'
						nCnt +=	oMdlH86:Length() + 1				
					EndIf 
				EndIf
			EndIf 
		Next nCnt 

		If !lRet 
			oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GU014PosVld", 'UNIQUELINE', 'Linha Duplicada ou vazia. Verifique '+cMsg+' da linha anterior.')
		EndIF 
	EndIf 

	RestArea(aAreaH7O)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPU014Load

    @type Function
    @author flavio.martins
    @since 12/06/2024
    @version 1.0
 	@return lógico, return_type, return_description
/*/
//------------------------------------------------------------------------------
Function GTPU014Load()

	Local lRet      := .T.
	Local aArea     := GetArea()
	Local oModel	:= FwLoadModel('GTPU014')
	Local oMdlH7O	:= oModel:GetModel('H7OMASTER')
	Local aDados	:= {}
	Local nX		:= 0

	aAdd(aDados,{StrZero(01,TamSx3('H7O_CODIGO')[1]), 'TARIFA'			 , '1', 'S', '2', '2', '2'})
	aAdd(aDados,{StrZero(02,TamSx3('H7O_CODIGO')[1]), 'PEDAGIO'			 , '1', 'S', '2', '2', '2'})
	aAdd(aDados,{StrZero(03,TamSx3('H7O_CODIGO')[1]), 'GTV'				 , '2', 'S', '1', '2', '2'})              
	aAdd(aDados,{StrZero(04,TamSx3('H7O_CODIGO')[1]), 'FURTO/ROUBO'		 , '2', 'S', '1', '2', '2'})           
	aAdd(aDados,{StrZero(05,TamSx3('H7O_CODIGO')[1]), 'ABONO'			 , '2', 'S', '1', '2', '2'})         
	aAdd(aDados,{StrZero(06,TamSx3('H7O_CODIGO')[1]), 'DESCONTO EM FOLHA', '2', 'S', '1', '2', '2'})             
	aAdd(aDados,{StrZero(07,TamSx3('H7O_CODIGO')[1]), 'VALE TRANSPORTE'	 , '2', 'S', '1', '2', '2'})               

	H7O->(dbSetOrder(1))
	For nX := 1 to Len(aDados)
		If !H7O->(dbSeek(xFilial('H7O')+aDados[nX][1]))

			oModel:SetOperation(MODEL_OPERATION_INSERT)

			If oModel:Activate()
				oMdlH7O:LoadValue('H7O_CODIGO'	,aDados[nX][1])
				oMdlH7O:LoadValue('H7O_DESCRI'	,aDados[nX][2])
				oMdlH7O:LoadValue('H7O_TIPO'	,aDados[nX][3])
				oMdlH7O:LoadValue('H7O_PROPRI'	,aDados[nX][4])
				oMdlH7O:LoadValue('H7O_INCMAN'	,aDados[nX][5])
				oMdlH7O:LoadValue('H7O_GERTIT'	,aDados[nX][6])
				oMdlH7O:LoadValue('H7O_BXATIT'	,aDados[nX][7])

	            If oModel:VldData() 
					oModel:CommitData()
				EndIf

			EndIf

			oModel:Deactivate()

		EndIf
	Next

	oModel:Destroy()
	RestArea(aArea)
	GtpDestroy(aDados)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger

    @type Function
    @author Silas Gomes
    @since 31/07/2024
    @version 1.0
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl, cField, uVal)

	If FwFldGet('H7O_TIPO') == '1'
		oMdl:ClearField("H7O_NATDES")
		oMdl:ClearField("H7O_PREDES")

	ElseIf FwFldGet('H7O_TIPO') == '2'
		oMdl:ClearField("H7O_NATREC")
		oMdl:ClearField("H7O_PREREC")
	
	EndIf

Return uVal
