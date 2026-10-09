#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA120.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA120
Motivo de inventário

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA120()

	Local   oBrowse
	//Private EAI_MESSAGE_MVC := ""

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("F0Q")
		oBrowse:SetDescription(STR0001) //Motivo de inventário
		oBrowse:Activate()

	Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA120' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA120' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA120' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA120' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0008 ACTION 'Fsa120Per' OPERATION 3 ACCESS 0 //Regras - Motivo Inventário 05
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct(1,"F0Q")    
	
	oModel	:=	MPFormModel():New('FISA120MOD',,{ |oModel| ValidForm(oModel) })
	
	oModel:AddFields('FISA120MOD',,oStructCAB)	   
	
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("FISA120")
	Local oStructCAB := FWFormStruct(2,"F0Q")	

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCAB,'FISA120MOD')	

	oView:CreateHorizontalBox("CABEC",100)

	oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author Rafael dos Santos
@since 30.03.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local cCod	  :=	oModel:GetValue('FISA120MOD','F0Q_CODIGO')
Local cMotInv :=	oModel:GetValue('FISA120MOD','F0Q_MOTINV')
Local dDtfec  :=	oModel:GetValue('FISA120MOD','F0Q_DTFECH')
Local nOp	  :=	oModel:GetOperation()
Local lRet		:=	.T.
	
	
	//SX2//F0Q_FILIAL+DTOS(F0Q_DTFECH)+F0Q_CODIGO+F0Q_MOTINV+ID
	//SIX//F0Q_FILIAL+DTOS(F0Q_DTFECH)+F0Q_CODIGO+F0Q_MOTINV
	
If nOp == 3   //Inclusão
	DbSelectArea ("F0Q")  //Valores de exclusão de PIS e Cofins para sociedade cooperativa.
	F0Q->(DbSetOrder (1))
	If F0Q->(DbSeek(xFilial("F0Q")+Dtos(dDtfec)+cCod+cMotInv))
		Help(" ",2,"Help","Help","Registro já cadastrado",1,0)//Registro já cadastrado
		Return .F.
	EndIF		
EndIF

dbSelectArea("F0Q")
cRegisto    := F0Q->(RECNO())
    
If nOp == 4 // Alterando registro   
	F0Q->(DbSetOrder (1))
	If F0Q->(DbSeek(xFilial("F0Q")+Dtos(dDtfec)+cCod+cMotInv))
		 IF F0Q->(RECNO()) <> cRegisto
			Help(" ",1,"Help","Help","Registro já cadastrado",1,0)//Registro já cadastrado
			Return .F.
		 EndIf   
	EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa120Per
Pergunta para processamento das regras do motivo de inventário 05

@author Jose Felipe
@since 03/03/2026
@version 1.0

/*/
//-------------------------------------------------------------------
Function Fsa120Per()
	Local oProcess := Nil	     as object
	Local cDescric := STR0009    as character //Importando regras

	If Pergunte("FISA120", .T.)
		oProcess := FISProgress():New({|| Fsa120M05(@oProcess,cDescric)}, STR0008, .T.) //Regras - Motivo Inventário 05
		oProcess:Activate()
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa120Per
Processamento das regras do motivo de inventário 05

@author Jose Felipe
@since 03/03/2026
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Fsa120M05(oProcess,cDescric)
	Local oBulkF0Q   := Nil                  as object
	Local aArea  	 := GetArea()	         as array
	Local aFieldBulk := {}                   as array
	Local cAliBLH    := ""                   as character
	Local cFilF0Q    := xFilial("F0Q")       as character
	Local cFilSB1    := xFilial("SB1")       as character
	Local cProduto   := ""                   as character
	Local cCodMotiv  := "05"                 as character
	Local cMsg       := ""                   as character
	Local dDtFech    := CtoD("")			 as date
	Local cDtFech    := ""       			 as character 
	Local cPeriod    := ""		 			 as character 
	Local lAchouF0Q  := .F.                  as logical
	Local lEnd       := .F.                  as logical
	Local nMVA       := 0                    as numeric
	Local nTamProd   := 0                    as numeric
	Local nQtdFlush  := 400                  as numeric
	Local lAutomato  := IsBlind() 			 as logical

	dDtFech	:= MV_PAR01	
	cDtFech := DTOS(dDtFech)
	cPeriod := StrZero(Month(dDtFech), 2) + StrZero(Year(dDtFech), 4)
	nTamProd := FWSX3Util():GetFieldStruct("B1_COD")[3]

	DBSelectArea("F0Q")
	F0Q->(DBSetOrder(1))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	SPDBlocH(@cAliBLH, dDtFech, dDtFech)

	If !lAutomato
		oProcess:Inc1Progress(STR0010)//Concluído
	Endif

	If Empty(cAliBLH)
		Alert(STR0011)//Não foram encontrados dados para o processamento das regras.
		lEnd := .T.
	Else	
		DBSelectArea(cAliBLH)
		(cAliBLH)->(DbGoTop()) 
	Endif

	If !lEnd
		If !lAutomato
			oProcess:Inc1Progress(cDescric)
			oProcess:Inc2Progress(STR0012)//Processando Regras...
		Endif

		oBulkF0Q := FwBulk():New(RetSQLName("F0Q"),nQtdFlush)

		aFieldBulk := { {'F0Q_FILIAL'}, {'F0Q_DTFECH'}, {'F0Q_CODIGO'}, {'F0Q_MOTINV'}, ;
		                {'F0Q_ID'},     {'F0Q_PERIOD'}, {'F0Q_MVA'} }

		oBulkF0Q:SetFields(aFieldBulk)

		While !(cAliBLH)->(Eof())

			nMVA := 0
			cProduto  := PadR(Alltrim((cAliBLH)->COD_ITEM), nTamProd)
			lAchouF0Q := F0Q->(MsSeek(cFilF0Q + cDtFech + cProduto + cCodMotiv))

			If !lAchouF0Q

				If SB1->(MsSeek(cFilSB1 + cProduto)) .And. SB1->B1_PICMENT > 0
					nMVA := SB1->B1_PICMENT
				EndIf

				oBulkF0Q:AddData( {;
					cFilF0Q,;
					dDtFech,;
					cProduto,;
					cCodMotiv,;
					FWUUID("FISA120"),;
					cPeriod,;
					nMVA;
				})				

			EndIf	

			(cAliBLH)->(dbSkip())

		EndDo

		If !lAutomato
			oProcess:Inc1Progress(STR0010)//Concluído
			oProcess:Inc2Progress(STR0010)//Concluído
		Endif
		
		IF !lEnd
			MsgInfo(STR0016)//Processamento concluído
		EndIf
		
		(cAliBLH)->(dbCloseArea())
		SB1->(dbCloseArea())

	EndIf

	If !oBulkF0Q == Nil
		If !Empty(oBulkF0Q:GetError()) .or. !oBulkF0Q:Close()
			cMsg += Alltrim(oBulkF0Q:GetError())
			FwLogMsg(STR0013, , STR0014, STR0014, "", STR0015, cMsg , , , )//INFO - FISA120 - "Ocorrencia Bulk: "
		EndIf	
		oBulkF0Q:Destroy()
		oBulkF0Q := Nil
		aSize(aFieldBulk,0) 
	EndIf

	RestArea(aArea)

Return
